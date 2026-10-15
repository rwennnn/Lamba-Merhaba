# Lamba-Merhaba

Ne sorarsan sor, hedef yanıtı **`Merhaba.`** olan küçük bir yerel model deneyi ve Windows sohbet penceresi.

Bu proje, [cturan/Lamba-750M](https://huggingface.co/cturan/Lamba-750M) üzerine eğitilen **dondurulmuş v2 LoRA adaptörünü** içerir. Sohbet uygulaması gerçek model çıktısını gösterir; yanıtı sabit bir metinle değiştiren wrapper kullanmaz. Ana modelin orijinal yeteneklerini temsil etmez.

## Başlatma

Windows için: ZIP'i indirip bir klasöre çıkar ve **`Lamba-Merhaba.bat`** dosyasına çift tıkla. İlk açılışta dosya seçme penceresi Python 3.12'nin **`python.exe` yolunu sorar**. Seçimin ardından indirme/kurulum onayı gösterilir. Onayla; proje kendi `.venv` ortamını kurar, gerekli paketleri ve modeli indirir, ardından sohbet penceresini açar. Sonraki açılışlarda yeniden yol sormaz.

Python kurulu değilse önce [Python 3.12'yi](https://www.python.org/downloads/) kurmalısın. NVIDIA GPU, BF16 desteği ve yeterli disk alanı gerekir. Kurulum birkaç GB indirir. Paketler sistem Python'una değil proje içindeki `.venv` klasörüne kurulur. Kişisel Python yolu repoda boş bırakılmıştır; kurulum sonunda yalnızca göreli `.venv\Scripts\pythonw.exe` yolu kaydedilir.

Elle kurmak isteyenler için alternatif komutlar:

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install torch==2.11.0 --index-url https://download.pytorch.org/whl/cu128
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe setup_model.py
```

`setup_model.py`, yaklaşık 1,5 GB'lık orijinal ana ağırlıkları sabitlenmiş Hugging Face sürümünden indirir ve SHA256 değerini doğrular. Model config/tokenizer dosyaları ve eğitilmiş yaklaşık 21,7 MB adaptör bu repodadır. Büyük ana ağırlık dosyası Git'e dahil edilmez. İlk indirme internet ister; sonraki sohbetler yerel dosyalardan çalışır.

`settings.json` dosyasındaki alan **varsayılan olarak boştur**:

```json
{"python_path": ""}
```

Kendi Python ortamını buraya yaz. Yukarıdaki yerel kurulum için:

```json
{"python_path": ".venv\\Scripts\\pythonw.exe"}
```

Başka bir hazır Python ortamının `pythonw.exe` veya `python.exe` yolunu da elle yazabilirsin. Kişisel kullanıcı adı veya sabit bilgisayar yolu gerekmez. Alan boşken başlatıcı ilk kurulum akışını açar; alan doluysa belirtilen hazır ortamı doğrudan kullanır. Dosya bulunamazsa açıklayıcı mesaj verir. Yeniden yol seçmek/kurmak için alanı boş bırak.

Alternatif olarak:

```powershell
.\.venv\Scripts\python.exe chat_app.py
```

Enter mesajı gönderir, Shift+Enter yeni satır ekler. **Yeni sohbet** geçmişi temizler. Çarpı pencereyi ve model sürecini kapatır; o sürecin GPU belleği serbest kalır. Sohbetler diske kaydedilmez. Toplam bağlam 8.192 tokenı aşarsa eski kısım soldan kırpılır.

## Eğitim ve test

İlk pilot adaptörün ardından 1.000 yeni sentetik örneğin tamamı iki tur işlendi: 250 ek optimizer adımı ve 2.000 örnek geçişi. Termal kesintiden sonra 64 geçiş yeniden işlendi. V2 adaptörü donduruldu; bu repo eğitim başlatmaz.

| Kontrol | Gerçek model sonucu |
|---|---:|
| V2: 80 yeni test + 37 eski saldırı + 40 örnekleme denemesi | 157/157 tam yanıt ve token eşleşmesi |
| Dondurulmuş v2: uzunluk, çok tur, Unicode ve özel tokenlar | Modele ulaşan 87/87 tam yanıt ve token eşleşmesi |

Son dayanıklılık testinde bir ek girdi sohbet şablonunda reddedildi ve modele ulaşmadı. Dolayısıyla bu test uçtan uca 88/88 başarı değildir. 32–8.192 token ve 32 geçmiş konuşma turuna kadar sınandı. Bu sonlu, sentetik testler bütün olası girdilerde aynı yanıtı garanti etmez. Çelişen veya araç yanıtı gibi görünen bazı girdiler template hatası verebilir. Orijinal modele ek bir düşünce zinciri mekanizması eklenmedi.

Kısa girdi, batch 1, BF16 ve adaptörle temiz süreçte yaklaşık 1,8 GiB ek kart belleği ölçüldü. 8.192 token stres testinde gözlenen toplam kart kullanımı yaklaşık 7,8 GiB'a çıktı. Uzun bağlam ve eşzamanlı istekler belleği artırabilir. Bunlar tek bir RTX 4080 Laptop 12 GB ölçümüdür; donanıma ve ortamına göre değişir. Optimize linear-attention eklentileri kurulu olmadan PyTorch referans uygulamalarıyla çalışması doğrulandı.

## Köken ve lisans

- Ana model: [cturan/Lamba-750M](https://huggingface.co/cturan/Lamba-750M), Apache-2.0.
- Ana model ailesi: [Qwen/Qwen3.5-0.8B-Base](https://huggingface.co/Qwen/Qwen3.5-0.8B-Base).
- Bu sürüm: yalnızca `Merhaba.` hedefiyle eğitilmiş v2 adaptörü ve masaüstü arayüzü.
- Lisans metni `LICENSE`, köken ve değişiklik notları `NOTICE` içindedir. Üst modelin model kartı `model/README.md` dosyasında korunur.
