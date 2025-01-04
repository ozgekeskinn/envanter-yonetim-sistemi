<h1><b>Envanter Yönetim Sistemi</b></h1>
Proje zenity araçları kullanarak geliştirilmiş bir envanter yönetim sistemidir.Bu yazılım ürünlerinizi kolayca yönetmenize ve stok durumunu takip etmenize yardımcı olur.

<h2><span style="Times New Roman">Proje Ne İşe Yarıyor?</span></h2>
Bu proje, küçük ve orta ölçekli işletmelerin envanterlerini düzenli ve verimli bir şekilde yönetmeleri için tasarlanmıştır.

<h2><span style="Times New Roman">Proje Özellikleri</span></h2>
<ul>
<li>Ürün Yönetimi sağlar.Ürün bilgilerini (isim, kategori, stok miktarı vb.) ekleme, düzenleme ve silme gibi yetkinlikler içerir.</li>
<li>Stok raporları oluşturur.</li>
<li>Zenity araçları ile basit bir grafik kullanıcı arayüzü (GUI) sunar, bu da komut satırına aşina olmayan kullanıcıların projeyi rahatça kullanmasını sağlar.</li>
<li>Proje yönetici ve kullanıcı profilleri sunarak kullanıcı çeşidine göre belirli yetkinlikler verir.Bu sistemde yönetici tam yetkiye sahiptir, kullanıcının yetkileri ise sınırlıdır.</li>
</ul>

<h2><span style="Times New Roman">Kurulum</span></h2>
<p>Proje linux ortamında çalıştırılmak üzere geliştirilmiştir.Kurulum için aşağıda belirtilen adımları izleyin:</p>
<ul>
<li>Zenity kurulumunu yapın</li>
   <p><pre>sudo apt-get install zenity</pre> komutunu terminal ortamında çalıştırın.</p>
<li>Projeyi kopyalayın</li>
   <p>Depoyu klonlayın</p>
<pre>git clone https://github.com/ozgekeskinn/envanter-yonetim-sistemi.git
cd envanter-yonetim-sistemi</pre>
<li>Zenity araçları ile basit bir grafik kullanıcı arayüzü (GUI) sunar, bu da komut satırına aşina olmayan kullanıcıların projeyi rahatça kullanmasını sağlar.</li>
<li>Proje yönetici ve kullanıcı profilleri sunarak kullanıcı çeşidine göre belirli yetkinlikler verir.Bu sistemde yönetici tam yetkiye sahiptir, kullanıcının yetkileri ise sınırlıdır.</li>
</ul>

Aşağıda verilen kullanıcı arayüzlerine göre kullanıcıların yetkinlikleri görsellerde verilmiştir:
<img src="https://github.com/user-attachments/assets/7878fce0-9eee-40f4-95d3-c83baa266308" alt="Resim1" width="150" height="150">
<img src="https://github.com/user-attachments/assets/d9aa91a2-28af-460b-a6b1-5d475bb94d3a" alt="Resim3" width="150" height="150">
<h4>Özellikler</h4>
<ol>
<li><b>Ürün Ekleme:</b> Kullanıcılar, yeni ürün bilgilerini girmek için bir form doldurarak envanterlerine yeni ürün ekleyebilir</li>
<img src="https://github.com/user-attachments/assets/9cb33a69-eff2-465f-a329-d5632361e564" alt="Resim4" width="150" height="150">
<li><b>Ürün Listeleme:</b> Tüm mevcut ürünleri görüntüleyerek envanter durumu hakkında bilgi alabilirler. Ürünler, ad, miktar ve fiyat bilgileri ile listelenir.</li>
<li><b>Ürün Güncelleme:</b></li>
   <img src="https://github.com/user-attachments/assets/189603a3-25f9-4e3a-a39c-ff72fe9fb8df" alt="Resim5" width="150" height="150">
<li><b>Ürün Silme:</b> İstenmeyen veya artık ihtiyaç duyulmayan ürünleri kolayca silerek envanterlerini temiz tutabilirler</li>
  <img src="https://github.com/user-attachments/assets/29f8a3ac-040b-42c6-aaba-5e924a06eb14" alt="Resim6" width="150" height="150">
<li><b>Rapor Al:</b> Bu kısımda stokta azalan ürünler ve en yüksek stok miktarına sahip ürünler ekrana yazdırılır.</li>
  <img src="https://github.com/user-attachments/assets/81ed6fda-1533-44d3-9fd3-ed48c01a3c7b" alt="Resim7" width="150" height="150">
</ol>
<p>Geliştirilen yazılımın bir diğer özelliği kullanıcı yönetimi panelidir.Bu kısımda aşağıda belirtilen özellikler mevcuttur:</p>
<ol>
<li><b>Yeni Kullanıcı Ekle</b></li>
  <img src="https://github.com/user-attachments/assets/a598ac8c-b2e2-48c5-98eb-fead1f5f4108" alt="Resim8" width="150" height="150">
<li><b>Kullanıcıları Listeleme:</b></li>
<li><b>Kullanıcı Güncelleme:</b></li> Kullanıcı bilgilerini güncelleyerek, erişim ve yetki ayarlarını değiştirebilirler. 
</ol>
<p>Geliştirilen yazılımda program yönetimi olarak adlandırılan bir diğer alan mevcuttur.Bu alanda aşağıdaki özellikler vardır:</p>
<ol>
<li><b>Diskteki Alanı Göster</b></li>
  <img src="https://github.com/user-attachments/assets/d0b57de8-b9a0-4f28-92da-301b63a7e573" alt="Resim9" width="150" height="150">
<li><b>Diske Yedekle:</b></li> Kullanıcı, ürün ve kullanıcı verilerini yedeklemek için “depo.csv” ve “kullanici.csv” dosyalarını diske kaydeder.
<li><b>Hata Kayıtlarını Göster:</b></li> Sistem hata kayıtlarını görüntüler.
</ol>
<p>Son olarak yazılımda kullanıcıların sistemle ilgili deneyimlerini paylaştığı geri bildirim gönderme seçeneği mevcuttur. Bu kısım uygulamanın eksik yönlerinin tamamlanması ve hataların düzeltilmesi amacıyla eklenmiştir.</p>

  <img src="https://github.com/user-attachments/assets/c4499338-b1e5-4568-8341-1a607debba37" alt="Resim10" width="150" height="150">







   
