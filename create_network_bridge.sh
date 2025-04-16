#!/run/current-system/sw/bin/bash
set -euo pipefail

BRIDGE_NAME="br0"
MACVTAP_NAME="macvtap-net"

echo "[*] Detecting active network interface..."
ACTIVE_NIC=$(nmcli -t -f DEVICE,STATE dev | grep ':connected' | grep -v '^lo' | cut -d: -f1 | head -n1)

if [ -z "$ACTIVE_NIC" ]; then
  echo "[!] No active network interface found."
  exit 1
fi

echo "[*] Active NIC: $ACTIVE_NIC"

TYPE=$(nmcli -t -f DEVICE,TYPE dev | grep "^$ACTIVE_NIC:" | cut -d: -f2)

if [ "$TYPE" = "wifi" ]; then
  echo "[⚠] Detected Wi-Fi interface ($ACTIVE_NIC). Bridge mode is not supported on Wi-Fi."
  echo "[→] Setting up libvirt macvtap network instead..."

  XML_FILE="/tmp/${MACVTAP_NAME}.xml"

  cat > "$XML_FILE" <<EOF
<network>
  <name>${MACVTAP_NAME}</name>
  <forward mode='bridge'>
    <interface dev='${ACTIVE_NIC}'/>
  </forward>
</network>
EOF

  virsh net-define "$XML_FILE"
  virsh net-autostart "$MACVTAP_NAME"
  virsh net-start "$MACVTAP_NAME"

  echo "[✔] Macvtap network '${MACVTAP_NAME}' created and ready to use in virt-manager."
  echo "[💡] In virt-manager, select this network for VM NICs. Mode: bridge, Source: $ACTIVE_NIC"
  exit 0
fi

# Otherwise, Ethernet - proceed with bridge setup
echo "[✓] Ethernet detected. Proceeding with bridge setup."

if nmcli con show "$BRIDGE_NAME" &>/dev/null; then
  echo "[!] NetworkManager bridge $BRIDGE_NAME already exists. Skipping creation."
else
  echo "[*] Creating bridge interface: $BRIDGE_NAME"
  nmcli connection add type bridge con-name "$BRIDGE_NAME" ifname "$BRIDGE_NAME"
  nmcli connection modify "$BRIDGE_NAME" ipv4.method auto ipv6.method auto

  echo "[*] Creating bridge-slave connection for $ACTIVE_NIC"
  nmcli connection add type bridge-slave ifname "$ACTIVE_NIC" master "$BRIDGE_NAME"

  echo "[*] Bringing up bridge connection..."
  nmcli connection up "$BRIDGE_NAME"
fi

Set up libvirt bridge
XML_FILE="/tmp/${BRIDGE_NAME}_libvirt.xml"

cat > "$XML_FILE" <<EOF
<network>
  <name>${BRIDGE_NAME}</name>
  <forward mode='bridge'/>
  <bridge name='${BRIDGE_NAME}'/>
</network>
EOF

virsh net-define "$XML_FILE"
virsh net-autostart "$BRIDGE_NAME"
virsh net-start "$BRIDGE_NAME"

echo "[✔] Bridge network '${BRIDGE_NAME}' created and ready to use in virt-manager."
