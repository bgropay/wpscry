#!/bin/bash
# Installer wpscry otomatis
# Dibuat oleh Ropay
#
# Jika ada bug atau masalah saat proses instalasi
# laporkan di 'https://github.com/bgropay/bash4hacking/issues'

# Path untuk menyimpan semua tools yang diperlukan oleh wpscry.
path_app="/opt"

error=()

r="\e[0m"
m="\e[1;31m"
h="\e[1;32m"
b="\e[1;34m"
p="\e[1;37m"

# Fungsi untuk memeriksa apakah script dijalankan sebagai root.
function cek_root(){
        if [[ "$EUID" -ne 0 ]]; then
                echo -e "${m}[-] ${p}Script ini harus dijalankan sebagai root.${r}"
                exit 1
        fi
}

function konfirmasi(){
        clear
        echo "--------------------------------------------------------------------"
        echo "Script ini merupakan script untuk menginstal wpscry secara otomatis."
        echo "--------------------------------------------------------------------" 
        echo ""
        while true; do
                read -p "Apakah Anda ingin menginstal wpscry (iya/tidak): " nanya
                if [[ "${nanya}" == "iya" ]]; then
                        break
                elif [[ "${nanya}" == "tidak" ]]; then
                        exit 0
                else
                        echo -e "${m}[-] ${p}Masukkan salah. Harap masukkan 'iya' atau 'tidak'.${r}"
                        continue

                fi
        done
}

# Fungsi untuk mengecek apakah Anda memiliki koneksi internet atau tidak.
function cek_koneksi_internet(){
        echo -e "${b}[*] ${p}Mengecek koneksi internet...${r}"
        sleep 3
        if ping -c 1 8.8.8.8 >> /dev/null; then
                echo -e "${h}[+] ${p}Anda memiliki koneksi internet.${r}"
                sleep 3
	else
                echo -e "${m}[-] ${p}Anda tidak memiliki koneksi internet.${r}"
		((error+=1))
                sleep 3
        fi
}

# Fungsi untuk mengecek apakah Anda sudah menginstal git atau belum.
function cek_git(){
        echo -e "${b}[*] ${p}Mengecek git...${r}"
        sleep 3
	if command -v git >> /dev/null; then
                echo -e "${h}[+] ${p}Git sudah terinstal.${r}"
                sleep 3
	else
		echo -e "${m}[-] ${p}Git belum terinstal.${r}"
                sleep 3
                echo -e "${b}[*] ${p}Menginstal git...${r}"
		sleep 3
                apt-get install git -y >> /dev/null
		if [[ $? -eq 0 ]]; then
                        echo -e "${h}[+] ${p}Git berhasil diinstal.${r}"
                        sleep 3
		else
                        echo -e "${m}[-] ${p}Git gagal diinstal.${r}"
			((error+=1))
                        sleep 3
                fi
	fi
}

# Fungsi untuk pindah ke folder '/opt'
function pindah_folder(){
        # Pindah ke folder '/opt'
        cd "${path_app}"
}

# Fungsi untuk menginstal tools reaver.
function instal_reaver(){
        url_reaver="https://github.com/t6x/reaver-wps-fork-t6x"
        path_reaver="reaver-wps-fork-t6x"

        # list dependensi yang diperlukan oleh reaver.
        daftar_dependensi_reaver=(
                "wireless-tools"
                "build-essential"
                "libpcap-dev"
        	# "pixiewps"
	        # "aircrack-ng"
	        "libsdl2-2.0-0"
        )

        # Menginstal seluruh dependensi yang diperlukan oleh reaver 
        for dependensi_reaver in "${daftar_dependensi_reaver[@]}"; do
	        echo -e "${b}[*] ${p}Menginstal dependensi '${dependensi_reaver}'...${r}"
                sleep 3
	        apt-get install "${dependensi_reaver}" -y >> /dev/null
	        if [[ $? -eq 0 ]]; then
	                echo -e "${h}[+] ${p}Dependensi '${dependensi_reaver}' berhasil diinstal.${r}"
                        sleep 3
		else
			echo -e "${m}[-] ${p}Dependensi '${dependensi_reaver}' gagal diinstal.${r}"
                        ((error+=1))
                        sleep 3
                fi
        done

        # Instal reaver.
        echo -e "${b}[*] ${p}Mengkloning reaver dari github...${r}"
        sleep 3
        git clone "${url_reaver}" >> /dev/null

        if [[ $? -eq 0 ]]; then
                echo -e "${h}[+] ${p}Reaver berhasil dikloning dari github.${r}"
                sleep 3
        else
                echo -e "${m}[-] ${p}Reaver gagal dikloning dari github.${r}"
		((error+=1))
                sleep 3
        fi

        cd "${path_reaver}/src"
        echo -e "${b}[*] ${p}Menghasilkan file Makefile...${r}"
        sleep 3
        ./configure >> /dev/null

        if [[ $? -eq 0 ]]; then
                echo -e "${h}[+] ${p}File Makefile berhasil dihasilkan.${r}"
                sleep 3
        else
                echo -e "${h}[-] ${p}File Makefile gagal dihasilkan. Proses instalasi dihentikan.${r}"
		((error+=1))
                sleep 3
        fi

        echo -e "${b}[*] ${p}Mengkompilasi reaver...${r}"
        sleep 3
        make >> /dev/null

        if [[ $? -eq 0 ]]; then
                echo -e "${h}[+] ${p}reaver berhasil dikompilasi.${r}"
                sleep 3
        else
                echo -e "${m}[-] ${p}reaver gagal dikompilasi.${r}"
		((error+=1))
                sleep 3
        fi

        echo -e "${b}[*] ${p}Menginstal reaver...${r}"
        sleep 3
        make install >> /dev/null

        if [[ $? -eq 0 ]]; then
                echo -e "${h}[+] ${p}reaver berhasil diinstal.${r}"
                sleep 3
        else
                echo -e "${m}[-] ${p}reaver gagal diinstal.${r}"
		((error+=1))
                sleep 3
        fi    
	
	cd ../../ # kembali ke direktori '/opt'
}

function instal_pixiewps(){
        url_pixiewps="https://github.com/wiire-a/pixiewps"
        path_pixiewps="pixiewps"

        # List dependensi yang diperlukan oleh pixiewps.
        # daftar_dependensi_pixiewps=(
        #         "build-essential"
        # )

        # Menginstal seluruh dependensi yang diperlukan oleh pixiewps 
        # for dependensi_pixiewps in "${daftar_dependensi_pixiewps[@]}"; do
        #        apt-get install "${dependensi_pixiewps}"
        # done

        # Instal pixiewps
        echo "[*] Mengkloning pixiewps dari github..."
        sleep 3
        git clone "${url_pixiewps}" >> /dev/null

        if [[ $? -eq 0 ]]; then
                echo "[+] pixiewps berhasil dikloning dari github."
                sleep 3
        else
                echo "[-] pixiewps gagal dikloning dari github."
		((error+=1))
                sleep 3
        fi

        cd "${path_pixiewps}"

        echo "[*] Mengkompilasi pixiewps..."
        sleep 3
        make >> /dev/null

        if [[ $? -eq 0 ]]; then
                echo "[+] pixiewps berhasil dikompilasi."
                sleep 3
        else
                echo "[-] pixiewps gagal dikompilasi."
		((error+=1))
                sleep 3
        fi

        echo "[*] Menginstal pixiewps..."
        sleep 3
        make install >> /dev/null

        if [[ $? -eq 0 ]]; then
                echo "[+] pixiewps berhasil diinstal."
                sleep 3
        else
                echo "[-] pixiewps gagal diinstal."
		((error+=1))
                sleep 3
        fi

        cd ../ # kembali ke direktori '/opt'
}

function instal_aircrack(){
        url_aircrack="https://github.com/aircrack-ng/aircrack-ng"
        path_aircrack="aircrack-ng"
        
        # List dependensi yang diperlukan oleh aircrack-ng.
        daftar_dependensi_aircrack=(
                # "build-essential" 
        	"autoconf"
                "automake"
        	"libtool"
                "pkg-config"
        	"libnl-3-dev"
                "libnl-genl-3-dev"
        	"libssl-dev"
	        "ethtool"
                "libssl-dev"
                "shtool"
        	"rfkill"
                "zlib1g-dev"
        	# "libpcap-dev"
                "libsqlite3-dev"
        	"libpcre2-dev"
                "libhwloc-dev"
        	"libcmocka-dev"
                "hostapd"
        	"wpasupplicant"
                "tcpdump"
        	"screen"
                "iw"
        	"usbutils"
                "expect"
       )

        # Menginstal seluruh dependensi yang diperlukan oleh aircrack-ng
        for dependensi_aircrack in "${daftar_dependensi_aircrack[@]}"; do
                echo "[*] Menginstal dependensi '${dependensi_aircrack}'..."
                sleep 3
                apt-get install "${dependensi_aircrack}" -y >> /dev/null
                if [[ $? -eq 0 ]]; then
                        echo "[+] Dependensi '${dependensi_aircrack}' berhasil diinstal."
                        sleep 3
                else
                        echo "[-] Dependensi '${dependensi_aircrack}' gagal diinstal."
			((error+=1))
                        sleep 3
                fi
        done

        # Instal aircrack-ng
        echo "[*] Mengkloning aircrack-ng dari github..."
        sleep 3
        git clone "${url_aircrack}" >> /dev/null

        if [[ $? -eq 0 ]]; then
                echo "[+] aircrack-ng berhasil dikloning dari github."
                sleep 3
        else
                echo "[-] aircrack-ng gagal dikloning dari github."
		((error+=1))
                sleep 3
        fi

        cd "${path_aircrack}"

        echo "[*] Menghasilkan file configure..."
        sleep 3
        autoreconf -i >> /dev/null

        if [[ $? -eq 0 ]]; then
                echo "[+] File configure berhasil dihasilkan."
                sleep 3
        else
                echo "[-] File configure gagal dihasilkan."
		((error+=1))
                sleep 3
        fi

        echo "[*] Menghasilkan file Makefile..."
        sleep 3
        ./configure --with-experimental >> /dev/null

        if [[ $? -eq 0 ]]; then
                echo "[+] File Makefile berhasil dihasilkan."
                sleep 3
        else
                echo "[-] File Makefile gagal dihasilkan."
		((error+=1))
                sleep 3
        fi

        echo "[*] Mengkompilasi aircrack-ng..."
        sleep 3
        make >> /dev/null

        if [[ $? -eq 0 ]]; then
                echo "[+] aircrack-ng berhasil dikompilasi."
                sleep 3
        else
                echo "[-] aircrack-ng gagal dikompilasi."
		((error+=1))
                sleep 3
        fi

        echo "[*] Menginstal aircrack-ng..."
        sleep 3
        make install >> /dev/null

        if [[ $? -eq 0 ]]; then
                echo "[+] aircrack-ng berhasil diinstal."
                sleep 3
        else
                echo "[-] aircrack-ng gagal diinstal."
		((error+=1))
                sleep 3
        fi

        echo "[*] Mengatur path library..."
        sleep 3
        ldconfig >> /dev/null

        if [[ $? -eq 0 ]]; then
                echo "[+] Path library berhasil diatur."
                sleep 3
        else
                echo "[-] Path library gagal diatur."
		((error+=1))
                sleep 3
        fi

        cd ../ # kembali ke direktori '/opt'
}

function cek_error(){
        if [[ "${#error[@]}" -ne 0 ]]; then
	        echo "--------------------------------------------------------------------"
                echo "[-] wpscry gagal diinstal."
		echo "--------------------------------------------------------------------"
	        sleep 3
	        exit 1
	else
                echo "--------------------------------------------------------------------"
                echo "[+] wpscry berhasil diinstal."
		sleep3
                echo "[+] Ketikkan 'wpscry' untuk menjalankannya."
		sleep 3
		echo "--------------------------------------------------------------------"
	        sleep 3
	        exit 0
	fi
  
}

# Fungsi untuk menginstal wpscray.
function instal_wpscry(){
        cek_root
        konfirmasi
        cek_koneksi_internet
	cek_git
        pindah_folder
        instal_reaver
	instal_pixiewps
        instal_aircrack
	cek_error
}

# Memanggil fungsi instal_wpscry.
instal_wpscry
