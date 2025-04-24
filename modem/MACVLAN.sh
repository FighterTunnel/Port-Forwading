#!/bin/bash

echo "=== MACVLAN NetworkManager Setup ==="
echo ""

# List all available ethernet interfaces
interfaces=$(nmcli device status | awk '$2 == "ethernet" {print $1}')
echo "Available Ethernet Interfaces:"
echo "$interfaces"
echo ""

read -p "Pilih interface yang ingin digunakan sebagai parent (misal: eth1): " parent
if [[ -z "$parent" ]]; then
  echo "Interface tidak boleh kosong. Keluar."
  exit 1
fi

echo ""
echo "1) Tambahkan macvlan"
echo "2) Hapus semua macvlan yang dibuat untuk $parent"
read -p "Pilih aksi (1/2): " action

if [[ "$action" == "1" ]]; then
  read -p "Berapa banyak macvlan yang ingin ditambahkan? " jumlah

  for i in $(seq 1 "$jumlah"); do
    name="virtual${i}-${parent}"
    echo "➤ Menambahkan interface $name di atas $parent"
    sudo nmcli connection add type macvlan \
      con-name "$name" \
      ifname "$name" \
      dev "$parent" \
      mode bridge \
      ipv4.method auto \
      ipv6.method ignore
    sudo nmcli connection up "$name"
  done

  echo ""
  echo "✅ Selesai menambahkan $jumlah macvlan interface di atas $parent."

elif [[ "$action" == "2" ]]; then
  echo "➤ Menghapus semua koneksi macvlan dengan nama virtual*-{$parent}"
  for conn in $(nmcli connection show | grep "virtual[0-9]*-${parent}" | awk '{print $1}'); do
    echo "Menghapus koneksi: $conn"
    sudo nmcli connection delete "$conn"
  done
  echo "✅ Semua koneksi virtual*-{$parent} telah dihapus."

else
  echo "❌ Aksi tidak dikenali."
  exit 1
fi
