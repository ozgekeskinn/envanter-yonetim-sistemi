#!/bin/bash
# Kullanici bilgileri dosyaları
USER_DB="kullanici.csv"
LOG_DB="log.csv"

# Rol bazlı işlemler
if [[ $ROLE == "Yönetici" ]]; then
  ACTION=$(zenity --list \
    --title="Yönetici İşlemleri" \
    --text="Bir işlem seçin:" \
    --column="İşlem" \
    "Ürün Ekle" "Ürün Güncelle" "Ürün Sil" "Kullanıcı Yönetimi" \
    --height=300 --width=400)

  case $ACTION in
    "Ürün Ekle")
      zenity --info --text="Ürün ekleme işlemi başlatılıyor..."
      urun_ekle
      ;;
    "Ürün Güncelle")
      zenity --info --text="Ürün güncelleme işlemi başlatılıyor..."
      urun_guncelle
      ;;
    "Ürün Sil")
      zenity --info --text="Ürün silme işlemi başlatılıyor..."
      urun_sil
      ;;
    "Kullanıcı Yönetimi")
      zenity --info --text="Kullanıcı yönetimi işlemi başlatılıyor..."
      kullanici_yonetim
      ;;
      *)
      zenity --error --text="Geçersiz seçim!"
      ;;
  esac

elif [[ $ROLE == "Kullanıcı" ]]; then
  ACTION=$(zenity --list \
    --title="Kullanıcı İşlemleri" \
    --text="Bir işlem seçin:" \
    --column="İşlem" \
    "Ürünleri Görüntüle" "Rapor Al" \
    --height=200 --width=300)

  case $ACTION in
    "Ürünleri Görüntüle")
      zenity --info --text="Ürünler görüntüleniyor..."
      # Bura
      ;;
    "Rapor Al")
      zenity --info --text="Rapor alınıyor..."
      rapor_al
      ;;
    *)
      zenity --error --text="Geçersiz seçim!"
      ;;
  esac

else
      echo "Geçersiz rol seçimi!">> log.csv
fi

# dosya hazırlığı
# Gerekli CSV dosyalarının oluşturulması
init_files() {
    touch depo.csv kullanici.csv log.csv
    echo "Kullanıcı dosyaları ve depo oluşturuldu."
    for file in depo.csv kullanici.csv log.csv; do
        if [ ! -f $file ]; then
            touch $file
            echo "$file oluşturuldu."
        fi
    done
}

# Ürün numarası otomatik atanması
generate_product_id() {
    if [ ! -s depo.csv ]; then
        echo 1
    else
        awk -F',' 'END {print $1 + 1}' depo.csv
    fi
}

# Pozitif değer kontrolü
validate_positive() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Boşluk kontrolü
validate_no_spaces() {
    if [[ $1 =~ \  ]]; then
        return 1
    else
        return 0
    fi
}

# Ürün isminin benzersizliği
validate_unique_product() {
    if grep -q ",$1," depo.csv; then
        return 1
    else
        return 0
    fi
}

declare -A deneme_sayisi
SYSTEM_LOCKED=false  # Sistem kilitli mi?

DEFAULT_USERS=(
    "ozge:$(echo -n '1234' | md5sum | awk '{print $1}'):Yönetici"
    "eylul:$(echo -n '7890' | md5sum | awk '{print $1}'):Kullanıcı"
)

kullanici_girisi() {
    while true; do
        # Eğer sistem kilitlenmişse, hiç bir işlem yapma
        if [[ "$SYSTEM_LOCKED" == true ]]; then
            zenity --error --text="Sistem kilitlenmiştir. Yönetici ile iletişime geçin."
            echo "$(date) | Sistem kilitli - Giriş yapılamaz" >> log.csv
            exit 1
        fi
        
        # Kullanıcı bilgilerini al
        kullanici_adi=$(zenity --entry --title="Giriş" --text="Kullanıcı Adı:")
        parola=$(zenity --password --title="Giriş")
        md5_parola=$(echo -n "$parola" | md5sum | awk '{print $1}')

        # Varsayılan kullanıcılar kontrol ediliyor
        default_user_found=false
        for user in "${DEFAULT_USERS[@]}"; do
            IFS=':' read -r username password role <<< "$user"
            if [[ "$kullanici_adi" == "$username" && "$md5_parola" == "$password" ]]; then
                zenity --info --text="Hoş geldiniz, $kullanici_adi! Rolünüz: $role"
                echo "$(date) | Başarılı giriş: $kullanici_adi (Varsayılan kullanıcı)" >> log.csv
                ana_menu "$role"
                return
            fi
        done

        # Kullanıcı CSV'de aranıyor
        user_data=$(grep "^$kullanici_adi," kullanici.csv)
        if [[ -z "$user_data" ]]; then
            zenity --error --text="Kullanıcı bulunamadı!"
            echo "$(date) | Kullanıcı bulunamadı: $kullanici_adi" >> log.csv
            ((deneme_sayisi["$kullanici_adi"]++))
            check_system_lock
            continue
        fi

        # Hesap kilitli mi?
        is_locked=$(echo "$user_data" | awk -F',' '{print $4}')
        if [[ "$is_locked" == "kilitli" ]]; then
            zenity --error --text="Bu hesap kilitlenmiştir. Yönetici ile iletişime geçin."
            echo "$(date) | Hatalı giriş: $kullanici_adi (Hesap kilitli)" >> log.csv
            exit 1
        fi

        # Şifre doğru mu?
        correct_password=$(echo "$user_data" | awk -F',' '{print $3}')
        if [[ "$md5_parola" == "$correct_password" ]]; then
            rol=$(echo "$user_data" | awk -F',' '{print $5}')
            zenity --info --text="Hoş geldiniz, $kullanici_adi! Rolünüz: $rol"
            echo "$(date) | Başarılı giriş: $kullanici_adi" >> log.csv
            
            # Hatalı giriş sayısını sıfırla
            deneme_sayisi["$kullanici_adi"]=0
            
            ana_menu "$rol"
            break
        else
            # Hatalı giriş işlemi
            ((deneme_sayisi["$kullanici_adi"]++))
            echo "$(date) | Hatalı giriş: $kullanici_adi (Deneme: ${deneme_sayisi["$kullanici_adi"]})" >> log.csv
            zenity --error --text="Hatalı şifre! Deneme: ${deneme_sayisi["$kullanici_adi"]}/3"
            check_system_lock
        fi
    done
}

# Sistem kilitleme kontrolü
check_system_lock() {
    total_failed_attempts=0
    for user in "${!deneme_sayisi[@]}"; do
        total_failed_attempts=$((total_failed_attempts + deneme_sayisi["$user"]))
    done

    if [[ $total_failed_attempts -ge 3 ]]; then
        SYSTEM_LOCKED=true
        zenity --error --text="Sistem 3 hatalı girişten sonra kilitlenmiştir. Yönetici ile iletişime geçin."
        echo "$(date) | Sistem kilitlendi: 3 hatalı girişten sonra" >> log.csv
    fi
}

yeni_kullanici_ekle() {
    bilgiler=$(zenity --forms --title="Yeni Kullanıcı Ekle" \
        --add-entry="Adı" \
        --add-entry="Soyadı" \
        --add-entry="Rol (Yönetici/Kullanıcı)" \
        --add-password="Parola")

    adi=$(echo $bilgiler | cut -d'|' -f1)
    soyadi=$(echo $bilgiler | cut -d'|' -f2)
    rol=$(echo $bilgiler | cut -d'|' -f3)
    parola=$(echo $bilgiler | cut -d'|' -f4)

    echo "$(generate_product_id),$adi,$soyadi,$rol,$(echo -n $parola | md5sum | awk '{print $1}')" >> kullanici.csv
    zenity --info --text="Yeni kullanıcı başarıyla eklendi!"
}

# Ana Menü
ana_menu() {
    rol=$1
    while true; do
        if [ "$rol" == "Yönetici" ]; then
            secim=$(zenity --list --title="Ana Menü" --column="İşlemler" \
                "Ürün Ekle" "Ürün Listele" "Ürün Güncelle" "Ürün Sil" "Rapor Al" \
                "Geri Bildirim" "Kullanıcı Yönetimi" "Program Yönetimi" "Çıkış")
        else
            secim=$(zenity --list --title="Ana Menü" --column="İşlemler" \
                "Ürün Listele" "Rapor Al" "Geri Bildirim" "Çıkış")
        fi

        case $secim in
            "Ürün Ekle") urun_ekle ;;
            "Ürün Listele") urun_listele ;;
            "Ürün Güncelle") urun_guncelle ;;
            "Ürün Sil") urun_sil ;;
            "Rapor Al") rapor_al ;;
            "Geri Bildirim") kullanici_geri_bildirim ;;
            "Kullanıcı Yönetimi") kullanici_yonetimi ;;
            "Program Yönetimi") program_yonetimi ;;
            "Çıkış") exit ;;
            *) zenity --error --text="Geçersiz seçim!" ;;
        esac
    done
}

urun_ekle() {
    id=$(generate_product_id)
    bilgiler=$(zenity --forms --title="Ürün Ekle" \
        --add-entry="Ürün Adı" \
        --add-entry="Stok Miktarı" \
        --add-entry="Birim Fiyatı" \
        --add-entry="Kategori")  # Kategori ekleme de dahil edildi

    urun_adi=$(echo $bilgiler | cut -d'|' -f1)
    stok=$(echo $bilgiler | cut -d'|' -f2)
    fiyat=$(echo $bilgiler | cut -d'|' -f3)
    kategori=$(echo $bilgiler | cut -d'|' -f4)

    # Doğrulamalar
    if ! validate_positive $stok; then
        zenity --error --text="Stok miktarı pozitif bir sayı olmalıdır!"
        echo "$(date) | Hata: Geçersiz stok miktarı" >> log.csv
        return
    fi

    if ! validate_positive $fiyat; then
        zenity --error --text="Birim fiyat pozitif bir sayı olmalıdır!"
        echo "$(date) | Hata: Geçersiz birim fiyatı" >> log.csv
        return
    fi

    if ! validate_no_spaces "$urun_adi"; then
        zenity --error --text="Ürün adında boşluk olmamalıdır!"
        echo "$(date) | Hata: Ürün adında boşluk" >> log.csv
        return
    fi

    if ! validate_unique_product "$urun_adi"; then
        zenity --error --text="Bu ürün adıyla başka bir kayıt bulunmaktadır. Lütfen farklı bir ad giriniz."
        echo "$(date) | Hata: Aynı isimde ürün eklendi" >> log.csv
        return
    fi

    # Dosyaya yaz
    echo "$id,$urun_adi,$stok,$fiyat,$kategori" >> depo.csv
    zenity --info --text="Ürün başarıyla eklendi!"
}

urun_listele() {
    if [ ! -s depo.csv ]; then
        zenity --info --text="Hiç ürün bulunmamaktadır."
        return
    fi

    # CSV'den bilgileri okuyup daha anlaşılır bir formatta bir değişkene atıyoruz
    output=""
    while IFS=',' read -r id urun_adi stok fiyat kategori; do
        # Satırın geçerli formatta olup olmadığını kontrol et
        if [[ -n "$id" && -n "$urun_adi" && -n "$stok" && -n "$fiyat" && -n "$kategori" ]]; then
            output+="Ürün ID: $id\n"
            output+="Ürün Adı: $urun_adi\n"
            output+="Stok Miktarı: $stok\n"
            output+="Birim Fiyat: $fiyat TL\n"
            output+="Kategori: $kategori\n\n"
        fi
    done < depo.csv

    if [ -z "$output" ]; then
        zenity --info --text="Hiç geçerli ürün bulunmamaktadır."
    else
        zenity --text-info --title="Ürün Listesi" --width=400 --height=300 --text="$output"
    fi
}

urun_guncelle() {
    urun_adi=$(zenity --entry --title="Ürün Güncelle" --text="Güncellenecek Ürün Adı:")
    
    if ! grep -q ",$urun_adi," depo.csv; then
        zenity --error --text="Ürün bulunamadı!"
        return
    fi

    # Mevcut ürünü oku
    mevcut_bilgi=$(grep ",$urun_adi," depo.csv)
    mevcut_id=$(echo $mevcut_bilgi | cut -d',' -f1)
    mevcut_stok=$(echo $mevcut_bilgi | cut -d',' -f3)
    mevcut_fiyat=$(echo $mevcut_bilgi | cut -d',' -f4)
    mevcut_kategori=$(echo $mevcut_bilgi | cut -d',' -f5)

    yeni_bilgiler=$(zenity --forms --title="Yeni Ürün Bilgileri" \
        --add-entry="Yeni Stok Miktarı" \
        --add-entry="Yeni Birim Fiyatı" \
        --add-entry="Yeni Kategori")

    yeni_stok=$(echo $yeni_bilgiler | cut -d'|' -f1)
    yeni_fiyat=$(echo $yeni_bilgiler | cut -d'|' -f2)
    yeni_kategori=$(echo $yeni_bilgiler | cut -d'|' -f3)

    # Dosyayı güncelle
    sed -i "/,$urun_adi,/c\\$mevcut_id,$urun_adi,$yeni_stok,$yeni_fiyat,$yeni_kategori" depo.csv

    # Okunabilir formatta çıktı oluştur
    zenity --info --text="Güncelleme Tamamlandı:\n\nÜrün Adı: $urun_adi\nYeni Stok Miktarı: $yeni_stok\nYeni Birim Fiyat: $yeni_fiyat TL\nYeni Kategori: $yeni_kategori"
}

urun_sil() {
    urun_adi=$(zenity --entry --title="Ürün Sil" --text="Silinecek Ürün Adı:")

    if ! grep -q ",$urun_adi," depo.csv; then
        zenity --error --text="Ürün bulunamadı!"
        return
    fi

    # Kullanıcıdan onay istemek için zenity ile soru sor
    if zenity --question --text="Bu ürünü silmek istediğinizden emin misiniz?"; then
        sed -i "/,$urun_adi,/d" depo.csv
        zenity --info --text="Ürün başarıyla silindi!"
    else
        zenity --info --text="Silme işlemi iptal edildi."
    fi
}

rapor_al() {
    if [ ! -s depo.csv ]; then
        zenity --info --text="Hiç ürün bulunmamaktadır."
        return
    fi

    toplam_stok=$(awk -F',' 'NR>1 {sum += $3} END {print sum}' depo.csv)
    toplam_deger=$(awk -F',' 'NR>1 {sum += $3 * $4} END {print sum}' depo.csv)
    rapor="Toplam Stok: $toplam_stok\nToplam Değer: $toplam_deger TL\n\n"

    # Eşik değerini kullanıcıdan al
    esik_degeri=$(zenity --entry --title="Eşik Değeri" --text="Stokta azalan ve en yüksek stok miktarındaki ürünler için eşik değerini girin:")

    if [[ -z "$esik_degeri" ]]; then
        zenity --error --text="Eşik değeri girmediniz."
        return
    fi

    # Stokta azalan ürünler
    azalan_urunler=$(awk -F',' -v esik="$esik_degeri" 'NR>1 && $3 < esik {print $1 ", Stok Miktarı: " $3}' depo.csv)

    if [[ -z "$azalan_urunler" ]]; then
        rapor+="Stokta azalan ürün bulunmamaktadır.\n"
    else
        rapor+="Stokta Azalan Ürünler:\n$azalan_urunler\n"
    fi

    # En yüksek stok miktarına sahip ürünler
    en_yuksek_stok_urunler=$(awk -F',' -v esik="$esik_degeri" 'NR>1 && $3 >= esik {print $1 ", Stok Miktarı: " $3}' depo.csv | sort -t',' -k3 -nr)

    if [[ -z "$en_yuksek_stok_urunler" ]]; then
        rapor+="En yüksek stok miktarına sahip ürün bulunmamaktadır.\n"
    else
        rapor+="En Yüksek Stok Miktarına Sahip Ürünler:\n$en_yuksek_stok_urunler\n"
    fi

    zenity --info --text="$rapor"
}

yeni_kullanici_ekle() {
    # Kullanıcı bilgilerini al
    kullanici_adi=$(zenity --entry --title="Yeni Kullanıcı Ekle" --text="Kullanıcı Adı:")
    if [[ -z "$kullanici_adi" ]]; then
        zenity --error --text="Kullanıcı adı boş olamaz."
        return
    fi

    soyad=$(zenity --entry --title="Yeni Kullanıcı Ekle" --text="Soyadı:")
    ad=$(zenity --entry --title="Yeni Kullanıcı Ekle" --text="Adı:")
    rol=$(zenity --list --title="Rol Seç" --column="Rol" "Yönetici" "Kullanıcı")
    parola=$(zenity --password --title="Yeni Kullanıcı Ekle" --text="Parola:")

    # MD5 şifreyi oluştur
    md5_parola=$(echo -n "$parola" | md5sum | awk '{print $1}')

    # Kullanıcıyı dosyaya ekle
    echo "$kullanici_adi,$soyad,$md5_parola,$rol" >> kullanici.csv
    zenity --info --text="Yeni kullanıcı başarıyla eklendi."
}

kullanici_sil() {
    # Kullanıcıları listele ve seç
    kullanici_adi=$(zenity --entry --title="Kullanıcı Sil" --text="Silmek istediğiniz kullanıcı adını girin:")

    # Kullanıcı adı boş olamaz
    if [[ -z "$kullanici_adi" ]]; then
        zenity --error --text="Kullanıcı adı boş olamaz."
        return
    fi

    # Kullanıcıyı dosyadan sil
    if grep -q "^$kullanici_adi," kullanici.csv; then
        # Eğer kullanıcı varsa, dosyadan sil
        sed -i "/^$kullanici_adi,/d" kullanici.csv
        zenity --info --text="Kullanıcı başarıyla silindi."
    else
        zenity --error --text="Kullanıcı bulunamadı!"
    fi
}

kullanici_listele() {
    # Kullanıcıları listele
    if [[ -f "kullanici.csv" ]]; then
        kullanici_listesi=$(cat kullanici.csv | awk -F',' '{print $1 " | " $2 " | " $3 " | " $4}')
        
        if [[ -z "$kullanici_listesi" ]]; then
            zenity --info --text="Kullanıcı bulunamadı."
        else
            zenity --text-info --title="Kullanıcı Listesi" --width=600 --height=400 --editable=false --text="$kullanici_listesi"
        fi
    else
        zenity --error --text="Kullanıcılar listelenemedi. Dosya bulunamadı!"
    fi
}

kullanici_guncelle() {
    # Kullanıcı adı al
    kullanici_adi=$(zenity --entry --title="Kullanıcı Güncelle" --text="Güncellemek istediğiniz kullanıcı adını girin:")

    # Kullanıcı adı boş olamaz
    if [[ -z "$kullanici_adi" ]]; then
        zenity --error --text="Kullanıcı adı boş olamaz."
        return
    fi

    # Kullanıcıyı dosyadan bul ve güncelle
    user_data=$(grep "^$kullanici_adi," kullanici.csv)
    if [[ -z "$user_data" ]]; then
        zenity --error --text="Kullanıcı bulunamadı!"
        return
    fi

    # Kullanıcı bilgilerini al
    soyad=$(zenity --entry --title="Kullanıcı Güncelle" --text="Yeni Soyadı:")
    ad=$(zenity --entry --title="Kullanıcı Güncelle" --text="Yeni Adı:")
    rol=$(zenity --list --title="Rol Seç" --column="Rol" "Yönetici" "Kullanıcı")
    parola=$(zenity --password --title="Kullanıcı Güncelle" --text="Yeni Parola:")

    # MD5 şifreyi oluştur
    md5_parola=$(echo -n "$parola" | md5sum | awk '{print $1}')

    # Kullanıcıyı güncelle
    sed -i "/^$kullanici_adi,/c\\$kullanici_adi,$soyad,$md5_parola,$rol" kullanici.csv
    zenity --info --text="Kullanıcı bilgileri başarıyla güncellendi."
}

kullanici_yonetimi() {
    secim=$(zenity --list --title="Kullanıcı Yönetimi" --column="İşlemler" \
        "Yeni Kullanıcı Ekle" "Kullanıcı Sil" "Kullanıcı Listele" "Kullanıcı Güncelle" "Geri Dön")

    case $secim in
        "Yeni Kullanıcı Ekle") yeni_kullanici_ekle ;;
        "Kullanıcı Sil") kullanici_sil ;;
        "Kullanıcı Listele") kullanici_listele ;;
        "Kullanıcı Güncelle") kullanici_guncelle ;;
        "Geri Dön") return ;;
        *) zenity --error --text="Geçersiz seçim!" ;;
    esac
}

program_yonetimi() {
    # Seçenekler için Zenity menüsü
    OPTION=$(zenity --list --title="Program Yönetimi" --column="Seçenek" \
    "Diskte Kapladığı Alan" \
    "Diske Yedek Alma" \
    "Hata Kayıtlarını Görüntüleme")

    case $OPTION in
        "Diskte Kapladığı Alan")
            # Ana dizinin disk kullanımını al
            total_disk_usage=$(du -sh / 2>/dev/null | awk '{print $1}')  
            # Eğer hata varsa, hata çıktısını log.csv'ye kaydedelim
            if [[ $? -ne 0 ]]; then
                echo "$(date) | Disk kullanımını alırken hata oluştu" >> log.csv
            fi
            
            # Belirtilen dosyaların disk kullanımını al
            files=("envanter_sistemi.sh" "depo.csv" "kullanici.csv" "log.csv")
            total_file_usage=0
            
            # Çıktı metnini hazırlama
            output="Toplam disk alanı: $total_disk_usage\n\n"
            
            for file in "${files[@]}"; do
                if [[ -f "$file" ]]; then
                    # Dosya boyutunu MB cinsinden al
                    file_usage=$(du -h "$file" 2>/dev/null | awk '{print $1}')  # İnsan okuyabilir biçimde al
                    total_file_usage=$((total_file_usage + $(du -b "$file" | awk '{print $1}')))  # Toplam byte cinsinden güncelle
                    output+="$file disk alanı: $file_usage\n"
                else
                    echo "$(date) | $file dosyası bulunamadı" >> log.csv  # Dosya yoksa log'a yaz
                    output+="$file disk alanı: Dosya bulunamadı\n"
                fi
            done
            
            # Toplam disk kullanımını MB cinsine çevir
            total_file_usage_human=$(echo "scale=2; $total_file_usage/1024/1024" | bc)
            output+="\nBelirtilen dosyaların toplam disk kullanımı: ${total_file_usage_human} MB"

            # Sonucu göster
            zenity --info --text="$output"
            ;;
        
        "Diske Yedek Alma")
            # Yedek almak için kullanıcıdan kaynak ve hedef dizini alıyoruz
            source_dir=$(zenity --file-selection --directory --title="Yedeklenecek Dizin Seçin")
            if [[ -z "$source_dir" ]]; then
                zenity --error --text="Yedekleme işlemi iptal edildi."
                return
            fi
            
            backup_dir="$source_dir"_backup_$(date +"%Y%m%d%H%M%S").tar.gz
            tar -czf "$backup_dir" -C "$source_dir" .  # Dizini .tar.gz formatında yedekle
            zenity --info --text="Yedekleme tamamlandı. Yedek dosyası: $backup_dir"
            ;;
        
        "Hata Kayıtlarını Görüntüleme")
            # Hata kayıtlarını görüntüle
            if [[ -f "log.csv" ]]; then
                # Hatalı giriş ve Hata içerikli satırları al
                error_logs=$(grep -E "Hatalı|Hata:" log.csv)
                if [[ -z "$error_logs" ]]; then
                    zenity --info --text="Herhangi bir hata kaydı bulunmamaktadır."
                else
                    # Hata kayıtlarını Zenity ile görüntüle
                    zenity --text-info --title="Hata Kayıtları" --width=600 --height=400 --editable=false --text="$error_logs"
                fi
            else
                zenity --error --text="Hata kayıtları dosyası bulunamadı."
            fi
            ;;
        
        *)
            zenity --error --text="Geçersiz seçenek!"
            ;;
    esac
}

kullanici_geri_bildirim() {
    # Kullanıcıdan geri bildirim almak için Zenity penceresi aç
    geri_bildirim=$(zenity --text-info --title="Geri Bildirim Gönder" --width=400 --height=300 --editable=true --ok-label="Gönder" --cancel-label="İptal" --text="Lütfen geri bildiriminizi buraya yazın:")
    
    # Kullanıcının geri bildirim vermesini kontrol et
    if [[ $? -eq 0 ]]; then
        # Geri bildirimi dosyaya ekle
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Geri Bildirim: $geri_bildirim" >> geri_bildirimler.txt
        zenity --info --text="Geri bildiriminiz başarıyla gönderildi. Teşekkür ederiz!"
    else
        zenity --info --text="Geri bildirim gönderme işlemi iptal edildi."
    fi
}

# Başlangıç
init_files
kullanici_girisi

