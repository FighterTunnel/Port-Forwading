#!/bin/bash
# Isolasi DNS tanpa memutus koneksi interface fisik
# Tested on Armbian/Ubuntu 20.04+
# Modifikasi: Otomatis konfigurasi SEMUA interface aktif via NetworkManager

# 1. Hentikan layanan yang mengganggu (opsional, jika systemd-resolved menyebabkan konflik)
# sudo systemctl stop systemd-resolved 2>/dev/null
# sudo systemctl disable systemd-resolved

# 2. Setup dasar
GOOGLE_IPV4_DNS="8.8.8.8 8.8.4.4" # Google Primary & Secondary IPv4
GOOGLE_IPV6_DNS="2001:4860:4860::8888 2001:4860:4860::8844" # Google Primary & Secondary IPv6
RT_TABLE_BASE_ID=100 # ID awal untuk tabel routing

# Pastikan file rt_tables ada
sudo touch /etc/iproute2/rt_tables

# 3. Dapatkan Interface Aktif dari NetworkManager
# Cari device yang statusnya 'connected', ambil kolom pertama (DEVICE), filter 'lo'
ACTIVE_INTERFACES=$(nmcli -t -f DEVICE,STATE dev status | grep ':connected$' | cut -d: -f1 | grep -v '^lo$')

if [ -z "$ACTIVE_INTERFACES" ]; then
    echo "Tidak ada interface aktif yang ditemukan oleh NetworkManager. Keluar."
    exit 1
fi

echo "Interface aktif yang ditemukan: $ACTIVE_INTERFACES"

# 4. Konfigurasi per interface aktif
TABLE_ID_COUNTER=$RT_TABLE_BASE_ID
for IFACE in $ACTIVE_INTERFACES; do
    echo -e "\n--- Mengkonfigurasi Interface: $IFACE ---"

    # Dapatkan IP (opsional, jika rule pakai 'from')
    IFACE_IP=$(ip -4 addr show "$IFACE" | grep -oP '(?<=inet\s)\d+\.\d+\.\d+\.\d+' || echo "")
    GATEWAY=$(ip route show dev "$IFACE" | grep default | awk '{print $3}')

    if [ -z "$GATEWAY" ]; then
        echo "Gateway untuk $IFACE tidak ditemukan, dilewati..."
        continue
    fi

    TABLE_NAME="${IFACE}_dns" # Nama tabel routing (e.g., eth0_dns)
    TABLE_ID=$TABLE_ID_COUNTER # ID tabel routing
    PRIORITY=$((TABLE_ID + 10000)) # Prioritas rule, pastikan unik dan tidak konflik

    # Tambahkan definisi tabel ke rt_tables jika belum ada
    if ! grep -q "^$TABLE_ID\s$TABLE_NAME\b" /etc/iproute2/rt_tables; then
        echo "Menambahkan tabel $TABLE_ID $TABLE_NAME ke /etc/iproute2/rt_tables"
        echo -e "$TABLE_ID\t$TABLE_NAME" | sudo tee -a /etc/iproute2/rt_tables >/dev/null
    fi

    # --- Cleanup Existing Config ---
    echo "Membersihkan konfigurasi lama untuk $IFACE (Tabel: $TABLE_NAME, Prioritas: $PRIORITY)..."
    sudo ip rule del priority $PRIORITY 2>/dev/null || true # Hapus rule berdasarkan prioritas
    sudo ip rule del lookup $TABLE_NAME 2>/dev/null || true # Hapus rule berdasarkan lookup (jika prioritas berubah)
    sudo ip route flush table $TABLE_NAME 2>/dev/null || true # Flush tabel routing
    # --- End Cleanup ---

    # Buat tabel routing khusus
    echo "Membuat tabel routing $TABLE_NAME ($TABLE_ID) untuk $IFACE via $GATEWAY..."
    sudo ip route add default via "$GATEWAY" dev "$IFACE" table "$TABLE_NAME"

    # Tambahkan rule policy routing (berdasarkan output interface)
    echo "Membuat rule routing untuk $IFACE (oif) ke tabel $TABLE_NAME priority $PRIORITY..."
    sudo ip rule add oif "$IFACE" lookup "$TABLE_NAME" priority $PRIORITY

    # Konfigurasi NetworkManager
    # Dapatkan nama koneksi yang *sedang aktif* di interface ini
    CONN_NAME=$(nmcli -t -f NAME,DEVICE con show --active | grep ":$IFACE$" | cut -d: -f1 | head -n 1)

    if [ -z "$CONN_NAME" ]; then
        echo "WARN: Tidak ditemukan koneksi NetworkManager AKTIF untuk $IFACE. Mencoba mencari koneksi terkait..."
        # Jika tidak ada yg aktif, cari koneksi yg device-nya cocok (mungkin tidak aktif)
        CONN_NAME=$(nmcli -t -f NAME,DEVICE con show | grep ":$IFACE$" | cut -d: -f1 | head -n 1)
        if [ -z "$CONN_NAME" ]; then
             echo "ERROR: Tidak dapat menemukan koneksi NetworkManager untuk $IFACE. Lewati konfigurasi NM." 
             continue # Lanjut ke interface berikutnya
        else
             echo "INFO: Menemukan koneksi '$CONN_NAME' (tidak aktif) untuk $IFACE."
        fi
    else
        echo "INFO: Menggunakan koneksi aktif '$CONN_NAME' untuk $IFACE."
    fi

    echo "Mengkonfigurasi Google DNS (IPv4 & IPv6) untuk koneksi '$CONN_NAME'..."
    # Hapus DNS lama dan nonaktifkan DNS otomatis (IPv4 & IPv6)
    nmcli con mod "$CONN_NAME" ipv4.dns "" ipv6.dns ""
    nmcli con mod "$CONN_NAME" ipv4.ignore-auto-dns yes ipv6.ignore-auto-dns yes
    # Set Google DNS yang diinginkan (IPv4 & IPv6)
    nmcli con mod "$CONN_NAME" ipv4.dns "$GOOGLE_IPV4_DNS" ipv6.dns "$GOOGLE_IPV6_DNS"
    echo "Mengaktifkan ulang koneksi '$CONN_NAME'..."
    # Coba 'con up' - ini akan mengaktifkan jika tidak aktif, atau reapply jika sudah aktif
    nmcli con up "$CONN_NAME" || echo "Peringatan: Gagal mengaktifkan ulang koneksi '$CONN_NAME'. Mungkin perlu dilakukan manual."

    # Increment counter untuk tabel berikutnya
    TABLE_ID_COUNTER=$((TABLE_ID_COUNTER + 1))
done

# 5. Force /etc/resolv.conf to use Google DNS
# Overwrite resolv.conf to ensure default lookups use Google DNS,
# even if NetworkManager adds other servers based on DHCP etc.
# Policy routing handles interface-specific traffic.
echo "Forcing /etc/resolv.conf to use Google DNS..."
RESOLV_CONTENT="# Generated by DNS isolation script (forced override)
nameserver ${GOOGLE_IPV4_DNS%% *}
nameserver ${GOOGLE_IPV6_DNS%% *}"
echo "$RESOLV_CONTENT" | sudo tee /etc/resolv.conf >/dev/null

# 6. Verifikasi
echo -e "\n\033[1;36m=== Hasil Konfigurasi ===\033[0m"
echo "Tabel Routing Policy:"
ip rule show

echo -e "\nKonfigurasi DNS (/etc/resolv.conf):"
cat /etc/resolv.conf

echo -e "\nStatus Tabel Routing Custom:"
for IFACE in $ACTIVE_INTERFACES; do
    TABLE_NAME="${IFACE}_dns"
    echo "Tabel $TABLE_NAME:"
    ip route show table $TABLE_NAME
done

echo -e "\n\033[1;32mKonfigurasi DNS untuk interface aktif selesai.\033[0m"
echo "DNS yang seharusnya digunakan (via NetworkManager) - Google DNS:"
for IFACE in $ACTIVE_INTERFACES; do
    # Cari lagi nama koneksi yg mungkin sudah aktif sekarang
    CONN_NAME=$(nmcli -t -f NAME,DEVICE con show --active | grep ":$IFACE$" | cut -d: -f1 | head -n 1)
     if [ -z "$CONN_NAME" ]; then
        CONN_NAME=$(nmcli -t -f NAME,DEVICE con show | grep ":$IFACE$" | cut -d: -f1 | head -n 1)
     fi
     if [ -n "$CONN_NAME" ]; then
        DNS4_SET=$(nmcli -g ipv4.dns con show "$CONN_NAME")
        DNS6_SET=$(nmcli -g ipv6.dns con show "$CONN_NAME")
        IGNORE_AUTO4=$(nmcli -g ipv4.ignore-auto-dns con show "$CONN_NAME")
        IGNORE_AUTO6=$(nmcli -g ipv6.ignore-auto-dns con show "$CONN_NAME")
        echo "- $IFACE (Koneksi: $CONN_NAME):"
        echo "  IPv4 DNS: $DNS4_SET (Ignore Auto: $IGNORE_AUTO4)"
        echo "  IPv6 DNS: $DNS6_SET (Ignore Auto: $IGNORE_AUTO6)"
     else
         echo "- $IFACE: Tidak ditemukan koneksi NetworkManager terkait."
     fi
done

echo -e "\nTes konektivitas DNS (contoh: google.com):"
ping -c 1 google.com || echo "Ping gagal. Periksa konfigurasi jaringan."
