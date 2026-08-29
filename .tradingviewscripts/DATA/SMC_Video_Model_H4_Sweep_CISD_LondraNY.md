<!-- tradingview-pine-id: PUB;4aec4abb313f42f59770508a38fe486d -->
<!-- tradingviewscripts-format: 1 -->
# SMC Video Model — H4 Sweep + CISD (Londra/NY)

Source: https://www.tradingview.com/script/e00EfMV0/

## Description

H4 Sweep M15/M5 cısd entry model
Mum analizi
Londra+New York
ERL to IRL
bilgi tablosu vs.

---

## Source Code

````pine
//@version=6
indicator("SMC Video Model — H4 Sweep + CISD (Londra/NY)", "SMC Video", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)
// Bu "video-model" varyantı, kaynak videodan çıkarılan ek özellikleri togglable ekler.
// SADELEŞTİRME 25 Tem 2026: doğrulanmamış/reddedilen özellikler budandı (bkz README).
// Kalan mekanik: seans + pH4 sweep + KBM CISD + k eşiği + n≥2 + chase filtresi.
// Geri kalan bağlam (HTF ERL/IRL, mum 2/3, div) yalnız BİLGİ TABLOSUNDA gösterilir.

//──────────────────────── GİRDİLER ────────────────────────
grpS     = "Seanslar (New York saati)"
instMode = input.string("Otomatik", "Enstrüman tipi", options=["Otomatik", "Forex", "Endeks"], group=grpS, tooltip="Endeks modunda NY penceresi 10:00–14:00, önceki H4 06:00–10:00 olur; SMT açılır ve k eşiği olarak kThrIx kullanılır. Otomatik: NAS100/US100/US30/SPX/US500 sembollerinde endeks modu seçilir.\n\nEndekste Londra seansı artık bu modu terk etmeye gerek kalmadan, aşağıdaki ayrı toggle ile açılır.")
useLon   = input.bool(true,  "Londra seansı (01:00–05:00 NY = 06:00–10:00 Londra)", group=grpS, tooltip="Bu pencere Londra saatine sabitlenir: Avrupa ile ABD'nin yaz saati geçişlerinin örtüşmediği haftalarda NY saatine göre kayar, H4 seviyeleri Londra'ya göre doğru hesaplanır.")
useLonIx = input.bool(true,  "  · Endekslerde de Londra", group=grpS, tooltip="27 Tem 2026, kullanıcı isteği. Açıkken endeks sembollerinde de Londra setupları gösterilir; Londra tarafı FOREXLE BİREBİR AYNI parametreleri kullanır (pencere 06:00–10:00 Londra, önceki H4 02:00–06:00 Londra, giriş deadline'ı yok). NY tarafı endeks kurallarında kalır (10:00–14:00, giriş 12:30'a kadar, pH4 06:00–10:00).\n\nBUNU AÇMANIN AMACI: aynı sonucu 'Enstrüman tipi = Forex' seçerek almak MÜMKÜNDÜ ama o yol SMT filtresini de kapatıyor (endekste faydalı olduğu ölçülmüş) ve pH4 referans mumunu 05:00–09:00'a kaydırıyordu. Bu toggle ile Otomatik modda kalıp yalnız Londra'yı kazanırsın.\n\n⚠️ ÖLÇÜM UYARISI: 26 Tem 2026 koşusunda endekste Londra NEGATİF çıktı (NAS100 M15 −0.214 / PF 0.71 · US30 M15 −0.025 · NAS100 M5 −0.230), NY ise pozitifti (NAS100 M15 +0.298). Bu toggle o kaydı geçersizleştirmez — kullanıcının bilinçli tercihidir, eleme gözle yapılır. Strateji dosyasında varsayılanı KAPALI'dır ki eski ölçümler karşılaştırılabilir kalsın.")
useNy    = input.bool(true,  "New York seansı", group=grpS, tooltip="Forex: 09:00–13:00 · Endeks: 10:00–14:00 (New York saati, yaz/kış saatini otomatik izler)")
nyEntS   = input.session("0900-1130", "NY giriş penceresi (forex)", group=grpS, tooltip="Forex'te NY girişleri yalnız bu aralıkta alınır — kural: 11:30'dan sonra giriş yok. Sweep/CISD araması 13:00'a kadar sürer ama emir konmaz.")
nyEntIdx = input.session("1000-1230", "NY giriş penceresi (endeks)", group=grpS, tooltip="Endekste NY girişleri yalnız bu aralıkta alınır — açılıştan 2,5 saat sonra (12:30) kesilir.")
pendExtN = input.int(16, "Emir ömrü — pencere kapandıktan sonra (bar)", minval=0, group=grpS, tooltip="YARI-OTOMATİK ÇALIŞMA İÇİN (26 Tem 2026, kullanıcı isteği). Eskiden pencere kapanınca bekleyen limit emri ANINDA iptal ediliyordu; 24 Tem'de Londra 05:00'te kapandı, fiyat 45 dk sonra tam giriş seviyesine döndü ve gitti — sen bunu hiç görmedin. Burası 0 ise eski davranış (pencerede iptal). >0 ise emir o kadar bar daha YAŞAR, dolarsa etiket 'AL*/SAT* ·pencere dışı' olur ve normal giriş alarmı çalar. Kararı sen verirsin. UYARI: pencere dışı dolan girişler BACKTEST EDİLMEMİŞTİR — strateji dosyasında bu ayarın varsayılanı 0'dır ki ölçüm karşılaştırılabilir kalsın. M15'te 16 bar = 4 saat.")

grpE      = "Giriş / Risk"
tradeMode = input.string("Challenge", "İşlem modu", options=["Challenge", "Fonlu (kalite)", "Manuel"], group=grpE, tooltip="ANA ANAHTAR — enstrümanı otomatik algılayıp kanıtlanmış kanunları uygular (elle SMT/k/div ayarı gerekmez): SMT ve div forexte kapalı, endekste açık. CHALLENGE: k-filtre açık, div KAPALI (endekste de) — makul frekans, düşük patlama; prop challenge sprinti için. FONLU (kalite): k-filtre açık, div endekste AÇIK — maks WR/kalite/DD, düşük frekans; fonlandıktan sonra. MANUEL: aşağıdaki SMT/k/div toggle'ları geçerli olur.")
rrMult = input.float(2.0, "TP — R katı",             minval=0.5, step=0.25, group=grpE)
beMult = input.float(1.5, "Başabaş tetiği — R katı", minval=0.1, step=0.1,  group=grpE)
useFvg = input.bool(true,  "FVG girişini kullan", group=grpE, tooltip="Açıkken giriş limiti, CISD seviyesi ile displacement FVG'sinden fiyata daha yakın olanına konur (hangisine önce değerse)")
fvgCE  = input.bool(false, "FVG orta noktasından (CE) gir", group=grpE, tooltip="Kapalıysa FVG'nin fiyata yakın kenarına limit konur")
useDP  = input.bool(true,  "Chase filtresi: FVG yalnız discount/premium'da", group=grpE, tooltip="ICT: long FVG girişi ancak pH4 aralığının DISCOUNT (alt) yarısında, short FVG ancak PREMIUM (üst) yarısında kabul edilir. Yanlış bölgedeki FVG = bitmiş hareketi kovalamak (chase) → giriş CISD retest'inde kalır. Öncelik CISD.")
useLQ  = input.bool(true,  "Likidite kalitesi filtresi (seviyeye dokunuş)", group=grpE, tooltip="Sweeplenen önceki-H4 ucu GERÇEK stop kümesi mi (eşit dip/tepe) yoksa rastgele salınım mı? Seviyeye daha önce kaç kez dokunulduğu (son 40 pivotun kaçı seviyenin ±%10 H4-aralığı bandında) sayılır; eşiğin altındaysa setup REDDEDİLİR ve AL/SAT sinyali basılmaz. Doğrulanmış (25 Tem 2026, gerçek-PnL R, 2014+): tek-dokunuş (n=1) setup'ları 6/6 bacakta NEGATİF. Filtre açıkken EUR M15 +0,047→+0,081R (MaxDD 50→24R), GBP M15 +0,061→+0,101R (36→22R), NAS100 M15 +0,202→+0,312R; çekirdek portföy +0,054→+0,092R, MaxDD 41→34R, bedeli frekans −%28.")
lqMin  = input.int(2, "  Min. dokunuş sayısı (n)", minval=1, maxval=6, group=grpE, tooltip="Kaç dokunuş gerekli. Seviyeyi yapan pivotun kendisi sayılır → n=1 'tek dokunuş' (filtre yok demek), n=2 'en az bir tekrar dokunuş' = eşit dip/tepe. Doğrulanmış eşik TAM OLARAK 2: n≥3 ek fayda vermiyor, yalnız frekans kaybettiriyor.")
kThrFx = input.float(15, "k eşiği — forex (% risk)", minval=1, step=5, group=grpE, tooltip="Forex için CISD kırılım eşiği; k bu değerin ALTINDAysa işlem alınır. Düşük = daha seçici (kalite), yüksek = daha çok işlem (frekans/sprint). Doğrulanmış (KBM CISD + chase, maliyetli 2014+): k<15 = en yüksek beklenti (~+0,08R) + en düşük DD (EUR M15 36R, GBP M15 27R), ~100 işlem/yıl. 15 = kâr+düşük-DD varsayılanı. 35 = sprint/frekans tercihi. Challenge/Fonlu ve Manuel'de geçerli.")
kThrIx = input.float(15, "k eşiği — endeks (% risk)", minval=1, step=5, group=grpE, tooltip="Endeks için CISD kırılım eşiği. Doğrulanmış: k<15 optimum (NAS100 k<25'te baz-altına iner). Değiştirmen önerilmez.")
useKQ  = input.bool(true,   "· Manuel: CISD kırılım kalite filtresi", group=grpE, tooltip="YALNIZ Manuel modda geçerli. Açıkken patlayan (chase) kırılımlar elenir; eşikler yukarıdaki forex/endeks k değerleridir. Challenge/Fonlu modda otomatik açıktır. Doğrulanmış (2014+): EURUSD PF 1,10→1,15, NAS100 1,17→1,31, US30 1,12→1,28; MaxDD ~yarıya, WR +1-3 puan.")
useDiv = input.bool(false,  "· Manuel: Swing-div teyidi", group=grpE, tooltip="YALNIZ Manuel modda geçerli. Açıkken CISD onayından önce destekleyici swing-divergence (H4-dışı SMT) şart koşulur. KANUN: forexte ZARARLI, endekste FAYDALI. Endekste k ile WR %36→%42, PF 1,3→1,7; bedeli sıklık ~1/3. Challenge'da kapalı, Fonlu'da endekste açık (otomatik).")
divMd  = input.string("Destekleyici", "· Manuel: Div yönü", options=["Destekleyici", "Herhangi"], group=grpE, tooltip="Destekleyici: yalnız işlem yönünü destekleyen divergence (biz likidite aldık, korele almadı). Herhangi: her iki yön de sayılır.")

grpM     = "SMT Divergence"
smtOn    = input.bool(true, "· Manuel: SMT filtresi", group=grpM, tooltip="YALNIZ Manuel modda geçerli. Açıkken korele sembol kendi H4 seviyesini de sweeplediyse işlem alınmaz. KANUN: forexte ZARARLI (birlikte sweep sık → iyi işlemleri bloklar), endekste FAYDALI. Challenge/Fonlu modda otomatik: forexte kapalı, endekste açık.")
smtSymIn = input.symbol("", "Korele sembol (boş = otomatik)", group=grpM, tooltip="Otomatik eşleşme: EURUSD↔GBPUSD, NAS100/US100↔US30, US30↔NAS100, SPX/US500→NAS100")

// KBM (Keysi Base Model) CISD referansı: mevcut bardan geriye tara, yönle EŞLEŞEN ilk mumu
// (long=bearish, short=bullish) bul, o ardışık seriyi geriye uzat, serinin İLK (en eski) mumunun
// open'ı = CISD seviyesi. dir=1 long (bearish seri), dir=-1 short (bullish seri). [open, time] döner.
f_findSweepLegOpen(dir) =>
    float refOpen = na
    int   refTime = na
    if dir == 1
        int anchor = na
        for i = 0 to math.min(bar_index, 15)
            if close[i] < open[i]
                anchor := i
                break
        if not na(anchor)
            int k = anchor
            while k + 1 <= bar_index and close[k + 1] < open[k + 1]
                k += 1
            refOpen := open[k]
            refTime := time[k]
    else
        int anchor = na
        for i = 0 to math.min(bar_index, 15)
            if close[i] > open[i]
                anchor := i
                break
        if not na(anchor)
            int k = anchor
            while k + 1 <= bar_index and close[k + 1] > open[k + 1]
                k += 1
            refOpen := open[k]
            refTime := time[k]
    [refOpen, refTime]

// LİKİDİTE KALİTESİ (useLQ filtresi) — swept seviyeye önceki dokunuş sayısı.
// Dizideki pivotlardan kaçı lvl'nin tol bandına düşüyor (eşit dip/tepe = gerçek stop kümesi proxy'si).
// Seviyeyi yapan pivotun kendisi de sayılır → taban ~1; asıl bilgi 2+ (tekrarlanan dokunuş).
// RET KESKİNLİĞİ (bilgi) — sweep uç mumunun ret iğnesi, mum aralığının %'si.
// dir=1 long (alt iğne), dir=-1 short (üst iğne). Yüksek = keskin ret, düşük = gövdeli/sürünen.
f_wickPct(dir) =>
    rng = math.max(high - low, syminfo.mintick)
    (dir == 1 ? math.min(open, close) - low : high - math.max(open, close)) / rng * 100

f_touchCnt(arr, lvl, tol) =>
    int c = 0
    if not na(lvl) and array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            if math.abs(array.get(arr, i) - lvl) <= tol
                c += 1
    c

// TERS KAÇIŞ birimi (bilgi tablosu): fiyat farkını okunur birime çevirir.
// Endekste ham puan; forexte pip = fark ÷ (mintick × 10) — 5 haneli kotasyonda da,
// 3 haneli JPY kotasyonunda da doğru sonuç verir.
f_advTxt(x, idx) =>
    na(x) ? "-" : str.tostring(math.max(x, 0) / (idx ? 1.0 : syminfo.mintick * 10), "#.#")

grpG     = "Görünüm"
showRef  = input.bool(true,  "pH4 H/L çizgileri", group=grpG, tooltip="Önceki H4 mumunun high/low noktasından sağa uzayan çizgi; seviye alınınca etiketi H4-X olur")
showSmt  = input.bool(true,  "SMT ibaresi (pH4 etiketinde)", group=grpG, tooltip="H4 seviyesinde divergence varsa etikete '· SMT' eklenir: sweep eden tarafta 'H4-X · SMT', sweeplemeyen tarafta 'pH4 L · SMT'. Divergence bozulursa ibare kalkar. Etiket, seviye alınmadıysa çizginin sağ ucunda, alındıysa ortasında durur.")
showDiv  = input.bool(true,  "Div (swing SMT) çizgileri", group=grpG, tooltip="Sweep ile CISD onayı arasında oluşan div'ler takip edilir; CISD onaylandığı anda yalnız EN SON div çizilir (onayı destekleyen divergence). 3-mum swing kuralı uygulanır. Sadece görsel, işlem mantığına girmez.")
showDivC = input.bool(true,  "  · Sürekli SMT çizgileri (tablodaki 'Swing div')", group=grpG, tooltip="Bilgi tablosunun 'Swing div' satırı EN SON sürekli SMT'yi anlatır; bu seçenek onu GRAFİĞE de basar (noktalı mor çizgi + 'boğa SMT' / 'ayı SMT' yazısı), böylece 'kaç bar önce' sayılmak zorunda kalmaz. Üstteki 'Div çizgileri' seçeneğinden farkı: o yalnız CISD onayını DESTEKLEYEN div'i kesikli çizgiyle çizer (pencere içi); bu ise pencere şartı olmadan izlenen sürekli akıştır. İkisi de yalnız görsel, motora girmez.")
divCN    = input.int(3, "  · Sürekli SMT — son N", minval=1, maxval=20, group=grpG, tooltip="Ekranda tutulan sürekli SMT sayısı. En yenisi = tablodaki satır.")
showEntLbl = input.bool(false, "Giriş etiketleri (AL/SAT)", group=grpG, tooltip="Girişin oluştuğu bardaki 'AL @ fiyat ·n2 ·k7' balonu. VARSAYILAN KAPALI (26 Tem, kullanıcı isteği): işlem kutuları girişi zaten gösteriyor, balon grafiği kalabalıklaştırıyor. Açarsan tek ek bilgisi şudur: pencere DIŞINDA dolan giriş yıldızla işaretlenir (AL* / SAT* · pencere dışı) — o girişler backtest edilmemiştir.")
showResLbl = input.bool(true, "Sonuç etiketleri (TP/SL/BE)", group=grpG, tooltip="Kapatılırsa işlem sonuçları yalnız TP/SL kutularından okunur, etiket basılmaz")
showVln  = input.bool(true,  "Dikey seans çizgileri", group=grpG, tooltip="Pencere açılışında düz, kapanışında kesikli çizgi; yalnız son N seans için tutulur")
vlnN     = input.int(6, "Dikey çizgi — son N seans", minval=1, maxval=30, group=grpG)
showBg   = input.bool(false, "Arka plan boyaması", group=grpG)
showCisd = input.bool(true,  "CISD çizgisi", group=grpG, tooltip="Her CISD onayında çizilir; işlem açılmayan (bloklu) setuplarda kesikli görünür")
showFvgB = input.bool(true,  "FVG kutusu (sadece işlem yeri)", group=grpG, tooltip="Yalnız giriş bölgesi olan FVG kutusu kalır: bekleyen setup'ın güncel FVG'si çizilir, giriş FVG'den olmazsa veya setup iptal olursa kutu silinir. Kutu çerçevesi saydamdır, orta nokta (CE) noktalı çizgiyle gösterilir.")
tbMode   = input.string("Tümü", "İşlem kutuları (position tool)", options=["Tümü", "Son N", "Sadece aktif"], group=grpG, tooltip="Girişten çıkışa TP + SL kutusu. BE'ye çekilince SL kutusu entry'ye daralır.")
tbN      = input.int(20, "Son N işlem sayısı", minval=1, maxval=100, group=grpG)
showTbl  = input.bool(true, "Bilgi tablosu (setup + istatistik)", group=grpG, tooltip="Canlı setup bağlamı — kapı değil, gözle eleme içindir. İki satır ayrıca dikkat ister: MUM 2/3 kendi zaman diliminde hesaplanır (M5 grafiğinde H1, M15'te H4 — kaynak videonun eşleşme tablosu), satır başlığı hangisi olduğunu yazar ve niteleyen mumun saatini gösterir. TERS KAÇIŞ, seans bloğu açılışından bu yana fiyatın işlem yönünün TERSİNE en fazla ne kadar gittiği (forexte pip, endekste puan) + blokta kalan süre; blok ters yöne çok gitmişse bağlam doğru olsa bile yöne hareket edecek yer/zaman kalmamış olabilir. İKİSİ DE ÖLÇÜLMEDİ — eşik konulmadı, kalibrasyon sende.")
tblSize  = input.string("Normal", "  Tablo yazı boyutu", options=["Küçük", "Normal", "Büyük"], group=grpG, tooltip="Tablo okunmuyorsa Büyük seç.")
tblPos   = input.string("Sağ üst", "  Tablo konumu", options=["Sağ üst", "Sağ alt", "Sol üst", "Sol alt"], group=grpG)
showHtf  = input.bool(true, "HTF (H4) swing + IRL seviyeleri", group=grpG, tooltip="ERL/IRL motorunun izlediği HTF swing high/low çizgileri ve doldurulmamış HTF FVG (IRL) kutuları. Çizgi seviyenin OLUŞTUĞU H4 barından başlar; alınana kadar sağa uzar, ALINDIĞI barda donar ve kırmızıya döner. Yani kesik çizginin uzunluğu = seviyenin ömrü. ÜÇ DURUM: canlı seviye (yazılı kesik çizgi — motorun izlediği en güncel pivot) · bekleyen (yazısız kesik çizgi — yerini yeni pivota bıraktı ama HÂLÂ EL DEĞMEMİŞ likidite; toplam son 8 tutulur) · alınmış (kırmızı, donmuş; toplam son 10). Bekleyen ve alınmış seviyeler yalnız görseldir, motora girmez. IRL (FVG) KUTUSU: fiyat bölgeye ilk dokunduğunda kutu SİLİNMEZ — kenarlığı kesikliye döner ve etiketi '· mitige · N dokunuş' olur. Kutu ancak bir H4 mumu bölgenin dışında KAPANIRSA ölür (ayı IRL için üstünde, boğa IRL için altında); sadece fitille delinmesi öldürmez. Böylece setup saatler sonra oluştuğunda IRL hâlâ ekranda olur. Motorun mitigasyon/faz mantığı bundan bağımsızdır.")
showHtfLbl = input.bool(true, "  HTF seviye yazıları", group=grpG, tooltip="Çizgilerin ucundaki 'H4 swH 1.14011' / 'H4 IRL (boğa)' yazıları. Grafik kalabalıklaşırsa kapat — çizgiler kalır.")

grpC    = "Renkler — grafik araçları"
colH4   = input.color(#546E7A, "pH4 seviye çizgisi", group=grpC)
colH4X  = input.color(#B71C1C, "H4-X (alınmış seviye)", group=grpC)
colCisd = input.color(#1565C0, "CISD çizgisi", group=grpC)
colSmt  = input.color(#8E24AA, "Div çizgisi", group=grpC)
colFvgL = input.color(#26A69A, "FVG (long)", group=grpC)
colFvgS = input.color(#EF5350, "FVG (short)", group=grpC)
colTp   = input.color(#2E7D32, "TP kutusu / kazanç", group=grpC)
colSl   = input.color(#C62828, "SL kutusu / kayıp", group=grpC)
colBe   = input.color(#EF6C00, "BE rengi", group=grpC)
colPend = input.color(#E65100, "Bekleyen giriş çizgisi", group=grpC)
colVln  = input.color(#90A4AE, "Dikey seans çizgisi", group=grpC)

// TABLO RENKLERİ AYRI TUTULUR (26 Tem, kullanıcı isteği). Gerekçe: grafikteki kutu/çizgi
// renkleri grafik temasına göre seçilir (saydam, soluk); tablo yazısı ise okunaklı olmalı.
// İkisini aynı input'a bağlamak birini bozmadan diğerini ayarlamayı imkânsız kılıyordu.
grpT    = "Renkler — bilgi tablosu"
tblUp   = input.color(#2E7D32, "Olumlu (✔)",   group=grpT, tooltip="Uyumlu bağlam, n≥2, Mum 2/3 var, hedefe yer ≥2R")
tblDn   = input.color(#C62828, "Olumsuz (✘)",  group=grpT, tooltip="Çelişkili bağlam, n=1, dar hedef, alınmış ERL seviyesi")
tblNe   = input.color(#9E9E9E, "Nötr / yok",   group=grpT, tooltip="Setup yok, veri yok, koşul sağlanmadı")
tblBg   = input.color(color.new(#808080, 82), "Tablo arka planı", group=grpT)

//──────────────────────── RİSK / LOT ────────────────────────
// Yarı-manuel kullanım için: emri KULLANICI giriyor, dolayısıyla lot hesabı alarm anında
// hazır olmalı. Hesap: risk parası ÷ (stop mesafesi × puan değeri × kur). TV'nin
// `syminfo.pointvalue` alanı 1 kontratın 1 puanlık hareketinin kotasyon para birimindeki
// değeridir → forex spotta 1, endeks CFD'sinde çoğu brokerda 1. Lot AŞAĞI yuvarlanır:
// risk tavanı (%0,5) asla aşılmasın. KAPI DEĞİL, motora girmez — yalnız gösterim.
grpR    = "Risk / lot"
acctBal = input.float(10000, "Hesap büyüklüğü", minval=0, step=100, group=grpR, tooltip="Hesap para biriminde. Prop hesabında challenge bakiyesi.")
riskPct = input.float(0.5, "İşlem başına risk (%)", minval=0.01, maxval=100, step=0.1, group=grpR, tooltip="Sprint kuralı: %0,5. Lot bu yüzdeden hesaplanır.")
qtyMode = input.string("Otomatik", "Miktar birimi", options=["Otomatik", "Lot (forex)", "Kontrat / adet"], group=grpR, tooltip="Otomatik: syminfo.type == forex ise lot, değilse kontrat.")
lotUnit = input.float(100000, "1 lot = kaç birim (forex)", minval=1, step=1000, group=grpR, tooltip="Standart lot 100.000. Broker mini/mikro lot kotalıyorsa değiştir.")
lotStep = input.float(0.01, "Min. lot/kontrat adımı", minval=0.0001, step=0.01, group=grpR, tooltip="Broker'ın kabul ettiği en küçük adım. Miktar bu adıma AŞAĞI yuvarlanır → risk tavanı aşılmaz.")
fxRate  = input.float(1.0, "Kur düzeltmesi", minval=0.0001, step=0.01, group=grpR, tooltip="Kotasyon para birimi → hesap para birimi çarpanı. USD hesapta EURUSD/GBPUSD/NAS100/US30 gibi USD-kotalı sembollerde 1 bırak. USDJPY gibi JPY-kotalı bir sembolde 1/USDJPY (ör. 0,0064) yaz — hesap bunu kendi çekmez, bilerek elle bırakıldı.")
curSym  = input.string("$", "Para birimi işareti", group=grpR)
qtyOnBox= input.bool(true, "Miktarı işlem kutusunda göster", group=grpR, tooltip="SL kutusuna lot + risk parası, TP kutusuna kazanç parası yazılır (TradingView'in position tool'u gibi). Kapatılırsa bilgi yalnız tabloda kalır.")

riskCash = acctBal * riskPct / 100
isFxQ    = qtyMode == "Lot (forex)" or (qtyMode == "Otomatik" and syminfo.type == "forex")

// Stop mesafesinden miktar (lot ya da kontrat). na → hesaplanamaz; 0 → hesap/stop için çok küçük.
f_lotV(stopDist) =>
    q = na(stopDist) or stopDist <= 0 ? na :
     riskCash / (stopDist * syminfo.pointvalue * fxRate) / (isFxQ ? lotUnit : 1.0)
    na(q) ? na : math.floor(q / lotStep) * lotStep

// Yuvarlanmış miktarın GERÇEKTEN riske ettiği para (tavan kontrolü buradan okunur).
f_cashV(lot, stopDist) =>
    na(lot) or na(stopDist) ? na : lot * (isFxQ ? lotUnit : 1.0) * stopDist * syminfo.pointvalue * fxRate

f_lotTxt(lot) =>
    na(lot) ? "-" : lot <= 0 ? "çok küçük" : str.tostring(lot, "#.##") + (isFxQ ? " lot" : " kontrat")

f_cashTxt(x) =>
    na(x) ? "-" : str.tostring(x, x >= 100 ? "#" : "#.#") + " " + curSym

//──────────────────────── SMT SEMBOLÜ ────────────────────────
tkr = syminfo.ticker
autoSym = str.contains(tkr, "EURUSD") ? "GBPUSD" :
     str.contains(tkr, "GBPUSD") ? "EURUSD" :
     str.contains(tkr, "NAS100") or str.contains(tkr, "US100") or str.contains(tkr, "NDX") ? "US30" :
     str.contains(tkr, "US30") or str.contains(tkr, "DJI") ? "NAS100" :
     str.contains(tkr, "SPX") or str.contains(tkr, "US500") ? "NAS100" : ""
corrIsSelf = autoSym == "" and smtSymIn == ""
corrSym    = smtSymIn != "" ? smtSymIn : autoSym != "" ? autoSym : syminfo.tickerid
[cH, cL] = request.security(corrSym, timeframe.period, [high, low])
// REJİM (grade için): günlük EMA50 yön → q (reversal'ın günlük trende göre uyumu). Doğrulandı: endekste q=0 zehir / q=+1 iyi.
[dEMA, dEMAup] = request.security(syminfo.tickerid, "D", [ta.ema(close, 50)[1], ta.ema(close, 50)[1] > ta.ema(close, 50)[4]], lookahead=barmerge.lookahead_off)
dTrend = close > dEMA and dEMAup ? 1 : close < dEMA and not dEMAup ? -1 : 0   // +1 günlük yukarı / -1 aşağı / 0 range

//──────────────── HTF (H4 / GÜNLÜK) ERL/IRL BAĞLAM MOTORU ────────────────
// Kaynak video tezi: algoritma ERL (swing üstü/altı likidite) ile IRL (FVG/adil değer) arasında
// fraktal olarak salınır — "context yoksa no execution". Bu blok GÜNLÜK seviyede fiyatın NE
// ARADIĞINI izler. YALNIZ BİLGİ — kapı değil (6 bacakta test edildi, endekste ters çıktı).
// STRATEJİ DOSYASIYLA BİREBİR AYNI. REPAINT YOK: günlük pivotlar 2 bar teyitli, FVG'ler
// KAPANMIŞ günlük barlardan ([1]/[3]) hesaplanır, hepsi lookahead_off.
dATR = request.security(syminfo.tickerid, "D", ta.atr(14)[1], lookahead=barmerge.lookahead_off)
// BESLEME ZAMAN DİLİMİ: video eşleşme tablosu M15→H4; kullanıcı M5'te de H4 istiyor → ≤M15 ise H4, üstü Günlük.
htfRes = timeframe.in_seconds() <= 900 ? "240" : "D"
// Swing tespiti 3 MUM KURALI ile: ortadaki mumun ucu iki komşusundan uçta (pivot gücü 1).
// dPT = pivot MUMUNUN zamanı (pivot gücü 1 → pivot bir önceki HTF barı) — çizgiler seviyenin
// OLUŞTUĞU yerden başlasın diye gerekli.
[dPH, dPL, dPT] = request.security(syminfo.tickerid, htfRes, [ta.pivothigh(high, 1, 1), ta.pivotlow(low, 1, 1), time[1]], lookahead=barmerge.lookahead_off)
// dFT = FVG'yi oluşturan 3'lünün ilk barının zamanı ([3]) — IRL kutusu oradan başlasın.
[dH1, dL1, dH3, dL3, dFT] = request.security(syminfo.tickerid, htfRes, [high[1], low[1], high[3], low[3], time[3]], lookahead=barmerge.lookahead_off)

var float dSwHi   = na    // son teyitli HTF swing high (ERL — üst likidite, 3 mum kuralı)
var float dSwLo   = na    // son teyitli HTF swing low  (ERL — alt likidite, 3 mum kuralı)
var float fvgUL   = na    // boğa HTF FVG (fiyatın altında kalan IRL) alt/üst kenar
var float fvgUH   = na
var float fvgDL   = na    // ayı HTF FVG (fiyatın üstünde kalan IRL) alt/üst kenar
var float fvgDH   = na
var int   htfSeek = 0     // fiyatın HTF'de aradığı YÖN: +1 yukarı / -1 aşağı / 0 bağlam yok
var bool  htfIRL  = false // true = IRL (FVG/adil değer) aranıyor · false = ERL (swing likiditesi) aranıyor
var int   swHiT   = na    // seviyelerin OLUŞTUĞU zaman — çizgiler oradan başlasın
var int   swLoT   = na
// NOT: eski `fvgUT`/`fvgDT` (IRL kutusunun başlangıç zamanı) silindi — kutu artık görsel
// katmanın `dspUT`/`dspDT` alanlarını kullanıyor, bunlar yazılıp hiç okunmuyordu.

if not na(dPH)
    dSwHi := dPH
    swHiT := dPT
if not na(dPL)
    dSwLo := dPL
    swLoT := dPT
// HTF FVG tespiti (3 kapanmış bar: [3],[2],[1])
// DİRİLME HATASI (26 Tem 2026, kullanıcı grafikten yakaladı): dL1/dH3 KAPANMIŞ HTF barlarından
// gelir → bir H4 mumu boyunca 16 M15 barının HEPSİNDE aynı değerdedir. Koşul her barda yeniden
// sağlandığı için tüketilen FVG (fvgUL := na) BİR SONRAKİ BARDA geri diriliyordu; ikinci kez
// tüketilemiyordu da (htfIRL zaten false yapılmıştı) → fiyatın içinden düz geçtiği boşluk
// ekranda ve tabloda sonsuza kadar "dolmamış IRL" olarak kalıyordu.
// ÇÖZÜM: tespit yalnız HTF üçlüsü GERÇEKTEN değiştiğinde (yeni HTF barı) çalışsın.
newHtfBar = not na(dFT) and (na(dFT[1]) or dFT != dFT[1])
if newHtfBar and not na(dL1) and not na(dH3) and dL1 > dH3
    fvgUL := dH3
    fvgUH := dL1
if newHtfBar and not na(dH1) and not na(dL3) and dH1 < dL3
    fvgDL := dH1
    fvgDH := dL3

// ERL alımı → sıradaki hedef IRL (ters yön)
if not na(dSwHi) and high > dSwHi
    htfSeek := -1
    htfIRL  := true
if not na(dSwLo) and low < dSwLo
    htfSeek := 1
    htfIRL  := true
// IRL mitige edildi → sıradaki hedef tekrar ERL (ters yön). Dolan FVG tüketilir.
if htfIRL and htfSeek == -1 and not na(fvgUH) and low <= fvgUH
    htfSeek := 1
    htfIRL  := false
    fvgUL   := na
    fvgUH   := na
if htfIRL and htfSeek == 1 and not na(fvgDL) and high >= fvgDL
    htfSeek := -1
    htfIRL  := false
    fvgDL   := na
    fvgDH   := na
// GEÇERSİZLEŞME — FAZDAN BAĞIMSIZ (26 Tem 2026). Yukarıdaki iki kural yalnız motor DOĞRU fazdayken
// (htfIRL + doğru yön) FVG'yi tüketir. Boşluk yanlış fazda delinirse hiç temizlenmiyordu.
// Fiyat boşluğu BOYDAN BOYA geçtiyse o IRL artık yoktur — motorun ne aradığından bağımsızdır.
if not na(fvgUL) and low <= fvgUL
    fvgUL := na
    fvgUH := na
if not na(fvgDH) and high >= fvgDH
    fvgDL := na
    fvgDH := na

// IRL ölüm kuralının ihtiyacı olan tek HTF değeri: kapanmış HTF barının kapanışı (bkz aşağıda).
// Mum 2/3 bloğu artık KENDİ zaman dilimini kullanıyor → ayrı çekiliyor.
hC1 = request.security(syminfo.tickerid, htfRes, close[1], lookahead=barmerge.lookahead_off)

// ── MUM 2 / MUM 3 KURALI (kaynak video 2) — YALNIZ BİLGİ, ölçülmedi, kapı değil ──
// HTF mumu POI'ye girdikten sonra ters yöndeki mumların OPEN'ini asarak kapanirsa swing olusur.
//   Mum 2 = son kapanan mum bir onceki ters mumun open'ini asti
//   Mum 3 = kapanis IKI ardisik ters mumun open'ini asiyor (onceki mumun POI'ye girmesi sart)
// Engulf = kapanis onceki mumun ucunu da asti. Engulf degilse mumun %50'si izlenir.
// BULUSSAL: diskresyoner kuralin yaklasik kodlanmis hali.
//
// ZAMAN DİLİMİ (26 Tem): kaynak videonun eşleşme tablosu M15→H4, **M5→H1**. Kural M5
// işlemlerinde kullanılacağı için M5 ve altında H1'e bakılır; M15 bugünkü gibi H4'te kalır.
// Bilerek `htfRes`'ten (ERL/IRL katmanı) ayrıştırıldı — tablo satırı kendi TF'ini yazar.
mumRes = timeframe.in_seconds() <= 300 ? "60" : htfRes
// mT1 = niteleyen mumun (son kapanan) açılış zamanı — tabloda "09:00 Mum 2 ✔" için gerekli.
[mH1, mL1, mC1, mT1] = request.security(syminfo.tickerid, mumRes, [high[1], low[1], close[1], time[1]], lookahead=barmerge.lookahead_off)
[mO2, mH2, mL2, mC2] = request.security(syminfo.tickerid, mumRes, [open[2], high[2], low[2], close[2]], lookahead=barmerge.lookahead_off)
[mO3, mC3]           = request.security(syminfo.tickerid, mumRes, [open[3], close[3]], lookahead=barmerge.lookahead_off)

c2Up = not na(mC1) and not na(mO2) and mC1 > mO2 and mC2 < mO2
c2Dn = not na(mC1) and not na(mO2) and mC1 < mO2 and mC2 > mO2
c3Up = c2Up and not na(mO3) and mC3 < mO3 and mC1 > mO3
c3Dn = c2Dn and not na(mO3) and mC3 > mO3 and mC1 < mO3
engU = not na(mH2) and not na(mC1) and mC1 > mH2
engD = not na(mL2) and not na(mC1) and mC1 < mL2
c50  = na(mH1) or na(mL1) ? na : math.avg(mH1, mL1)

// ── HTF SEVİYE GÖRSELLERİ: hangi H4 seviyesinin alındığı grafikte görünsün ──
var line  htfHiLn  = na
var line  htfLoLn  = na
var box   htfFvgUB = na
var box   htfFvgDB = na
var float drawnHi  = na
var float drawnLo  = na
var float drawnFvgU = na
var float drawnFvgD = na
var bool  hiTaken  = false
var bool  loTaken  = false
var label htfHiLb  = na                    // seviye ADI etiketleri: tek örnek, silinip yenilenir
var label htfLoLb  = na
var label htfFvgUL2 = na
var label htfFvgDL2 = na
// Etiketler tek örnek tutulur (silinip yenilenir) → Pine'ın 500 etiket bütçesi AL/SAT'a kalır.

// ── GÖRSEL IRL DURUMU (26 Tem 2026, kullanıcı grafikten yakaladı) — MOTORDAN BAĞIMSIZ ──
// SORUN: motor, fiyat yakın kenara ilk dokunduğunda IRL'i tüketilmiş sayar (yukarıdaki
// mitigasyon kuralı, fvgDL := na). Bu MOTOR için doğrudur — faz ERL'e döner, h telemetrisini
// besler. Ama kutu çizimi de aynı değişkene bağlıydı → fiyat bölgeye DEĞER DEĞMEZ kutu
// ekrandan siliniyordu. Oysa setup çoğu kez SAATLER sonra, bölgeye birkaç kez dokunulduktan
// sonra oluşuyor; alarm çaldığında kullanıcı IRL'i göremiyor, her seferinde elle kontrol
// gerekiyordu (bkz README 26 Tem karar kaydı, 6. satır).
// ÇÖZÜM: çizimin ömrü ayrı `dsp*` değişkenlerinde tutulur — ERL çizgilerinde kurduğumuz
// "bekleyen havuz" ayrıştırmasının aynısı. ÖLÜM KURALI (kullanıcı seçimi): IRL ancak
// HTF (H4) KAPANIŞI bölgeyi aşarsa ölür — ayıda kapanış ÜSTÜNDE, boğada ALTINDA. Fitil
// geçişi öldürmez; asıl istenen bu, çünkü setup tam da o dokunuşlarla oluşuyor.
// Motor (fvg*/htfSeek/htfIRL/htfTgt/h) bundan HİÇ etkilenmez → ölçümler aynı kalır.
var float dspUL   = na       // boğa IRL (fiyatın altındaki adil değer) — görsel kopya
var float dspUH   = na
var float dspDL   = na       // ayı IRL (fiyatın üstündeki adil değer) — görsel kopya
var float dspDH   = na
var int   dspUT   = na       // kutunun başlangıç zamanı (FVG'yi oluşturan üçlünün ilk barı)
var int   dspDT   = na
var bool  dspUMit = false    // yakın kenara dokunuldu mu — YALNIZ İŞARET, öldürmez
var bool  dspDMit = false
var int   dspUTch = 0        // bölgeye kaç ayrı temasta girildi
var int   dspDTch = 0
var bool  dspUIn  = false    // şu an bölgenin içinde mi (sayaç kenar tespiti için)
var bool  dspDIn  = false

// 1) ÖLÜM — yeni H4 barı kapandığında, KAPANIŞ bölgeyi aştıysa. `hC1` (kapanmış HTF barının
//    kapanışı, `htfRes`'ten) ve `newHtfBar` zaten elde → ek request.security gerekmez.
//    DİKKAT: `hC1` HTF katmanına (H4) bağlı kalmalı; Mum 2/3'ün `mumRes`'i ile karıştırılmaz.
//    Önce ölüm, sonra doğuş: aynı H4 barında hem eskisi geçersizleşip hem yenisi doğabilsin.
if newHtfBar and not na(hC1)
    if not na(dspUL) and hC1 < dspUL
        dspUL := na
        dspUH := na
    if not na(dspDH) and hC1 > dspDH
        dspDL := na
        dspDH := na
// 2) DOĞUŞ — motorun HTF FVG tespit koşuluyla BİREBİR aynı; yeni FVG eskisinin yerini alır
if newHtfBar and not na(dL1) and not na(dH3) and dL1 > dH3
    if na(dspUL) or dspUL != dH3 or dspUH != dL1
        dspUL   := dH3
        dspUH   := dL1
        dspUT   := dFT
        dspUMit := false
        dspUTch := 0
        dspUIn  := false
if newHtfBar and not na(dH1) and not na(dL3) and dH1 < dL3
    if na(dspDL) or dspDL != dH1 or dspDH != dL3
        dspDL   := dH1
        dspDH   := dL3
        dspDT   := dFT
        dspDMit := false
        dspDTch := 0
        dspDIn  := false
// 3) MİTİGASYON İŞARETİ + DOKUNUŞ SAYACI — her LTF barında, öldürmez
dspInU = not na(dspUL) and low <= dspUH and high >= dspUL
dspInD = not na(dspDL) and high >= dspDL and low <= dspDH
if dspInU
    dspUMit := true
    if not dspUIn
        dspUTch += 1
if dspInD
    dspDMit := true
    if not dspDIn
        dspDTch += 1
dspUIn := dspInU
dspDIn := dspInD

// ALINAN BÖLGE HAVUZU (26 Tem 2026, kullanıcı isteği). Motor aynı anda tek swing high + tek swing
// low izler; eskiden yeni pivot gelince ESKİ çizgi silinmeden bırakılıyordu → grafik gri, donmuş,
// anlamı belirsiz çizgilerle doluyordu ("alınmadı" mı "yerini yenisine bıraktı" mı belli değil).
// KURAL: seviye ALINDIĞINDA çizgi kırmızıya döner, donar ve havuza geçer; havuz high+low
// TOPLAM son TAKEN_N bölgeyi tutar, eskisi silinir.
TAKEN_N = 10
var array<line> takenLns = array.new<line>()

// ALINMAMIŞ (BEKLEYEN) SEVİYE HAVUZU (26 Tem 2026 — ikinci tur, kullanıcı grafikten yakaladı).
// Yukarıdaki kuralın ilk hâlinde "alınmadan yerini yenisine bırakan çizgi SİLİNİR" deniyordu.
// Belirsizliği çözdü ama YAN ETKİSİ ağırdı: fiyat eski low'un altına inmeden daha YUKARIDA yeni
// bir pivot low oluşursa, aşağıdaki EL DEĞMEMİŞ likidite ekrandan siliniyordu — oysa SMC'de asıl
// bakılan şey odur (fiyat sonradan gidip onu alıyor). Not: seviye gerçekten alındıysa `takeHi`/
// `takeLo` zaten ateşler ve çizgi kırmızı havuza geçer; buraya YALNIZ dokunulmamış seviye düşer.
// YENİ KURAL: yerini yenisine bırakan çizgi silinmez → bekleyen havuza girer, sağa uzamaya devam
// eder; fiyat oraya değdiğinde kırmızıya dönüp donar ve alınanlar havuzuna geçer. Havuz high+low
// TOPLAM son PEND_N seviyeyi tutar. Yazılar yalnız CANLI seviyede kalır (grafik kalabalıklaşmasın).
// Sinyal motoru (dSwHi/dSwLo → htfSeek, h telemetrisi) bundan ETKİLENMEZ — saf görsel katman.
PEND_N = 8
var array<line>  pendLns  = array.new<line>()
var array<float> pendLvls = array.new<float>()
var array<int>   pendDirs = array.new<int>()   // +1 = üst seviye (high > lvl ile alınır) · -1 = alt
var float liveHiLvl = na                       // canlı çizgilerin seviyesi (havuza devrederken lazım)
var float liveLoLvl = na

// DURUM TAKİBİ — çizimden BAĞIMSIZ çalışır (bilgi tablosu da hiTaken/loTaken kullanıyor;
// showHtf kapalıyken tablonun "✔ALINDI" işareti çalışmaya devam etsin).
// na-GÜVENLİ karşılaştırma: Pine'da `x != na` sonucu na (falsy) → drawnHi hiç atanmadığı için
// çizgi HİÇ oluşmuyordu (FVG kutusu bu değişkene bağlı olmadığından tek çalışan o olmuştu).
newHi = not na(dSwHi) and (na(drawnHi) or dSwHi != drawnHi)
newLo = not na(dSwLo) and (na(drawnLo) or dSwLo != drawnLo)
if barstate.isconfirmed
    if newHi
        drawnHi := dSwHi
        hiTaken := false
    if newLo
        drawnLo := dSwLo
        loTaken := false
takeHi = not na(drawnHi) and not hiTaken and high > drawnHi
takeLo = not na(drawnLo) and not loTaken and low < drawnLo
if barstate.isconfirmed
    if takeHi
        hiTaken := true
    if takeLo
        loTaken := true

// ÇİZİM — yalnız showHtf açıkken.
// Çizgiler seviyenin OLUŞTUĞU HTF barından başlar (xloc.bar_time), alınana kadar sağa uzar,
// ALINDIĞI barda DONAR ve kırmızıya döner. Ayrı "ERL ALINDI" etiketi YOK (kullanıcı istemedi).
htfPre = htfRes == "240" ? "H4" : "1G"
if showHtf and barstate.isconfirmed
    if newHi and not na(swHiT)
        // Elde hâlâ çizgi varsa o ALINMAMIŞ demektir (alınanlar havuza geçip htfHiLn'i na yapar)
        // → silinmez, BEKLEYEN havuza devredilir; el değmemiş likidite ekranda kalsın.
        if not na(htfHiLn) and not na(liveHiLvl)
            array.push(pendLns,  htfHiLn)
            array.push(pendLvls, liveHiLvl)
            array.push(pendDirs, 1)
        htfHiLn := line.new(swHiT, dSwHi, time, dSwHi, xloc=xloc.bar_time, color=color.new(colH4, 25), width=2, style=line.style_dashed)
        liveHiLvl := dSwHi
        label.delete(htfHiLb)
        htfHiLb := showHtfLbl ? label.new(time, dSwHi, htfPre + " swH " + str.tostring(dSwHi, format.mintick), xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(colH4, 10), size=size.small) : na
    if newLo and not na(swLoT)
        if not na(htfLoLn) and not na(liveLoLvl)
            array.push(pendLns,  htfLoLn)
            array.push(pendLvls, liveLoLvl)
            array.push(pendDirs, -1)
        htfLoLn := line.new(swLoT, dSwLo, time, dSwLo, xloc=xloc.bar_time, color=color.new(colH4, 25), width=2, style=line.style_dashed)
        liveLoLvl := dSwLo
        label.delete(htfLoLb)
        htfLoLb := showHtfLbl ? label.new(time, dSwLo, htfPre + " swL " + str.tostring(dSwLo, format.mintick), xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(colH4, 10), size=size.small) : na
    // ALINMADIYSA sağa uzat; ALINDIYSA o barda dondur (kesik çizgi oluştuğu yerden alındığı yere)
    if not na(htfHiLn) and not hiTaken
        line.set_x2(htfHiLn, time)
        if not na(htfHiLb)
            label.set_x(htfHiLb, time)
    if not na(htfLoLn) and not loTaken
        line.set_x2(htfLoLn, time)
        if not na(htfLoLb)
            label.set_x(htfLoLb, time)
    // ALINDI → dondur, kırmızıya çevir ve HAVUZA devret. Devredilen çizgi artık "canlı seviye"
    // değildir (htfHiLn := na) → bir sonraki pivotta yanlışlıkla silinmez, havuz onu tutar.
    if takeHi and not na(htfHiLn)
        line.set_x2(htfHiLn, time)
        line.set_color(htfHiLn, color.new(colH4X, 0))
        array.push(takenLns, htfHiLn)
        htfHiLn := na
    if takeLo and not na(htfLoLn)
        line.set_x2(htfLoLn, time)
        line.set_color(htfLoLn, color.new(colH4X, 0))
        array.push(takenLns, htfLoLn)
        htfLoLn := na
    // BEKLEYEN HAVUZ — her bar sağa uzat; fiyat seviyeye değdiyse kırmızıya çevirip alınanlara devret.
    // Geriye doğru dönülür: array.remove sonrası indeks kayması sorun çıkarmasın.
    if array.size(pendLns) > 0
        for i = array.size(pendLns) - 1 to 0
            pLn  = array.get(pendLns,  i)
            pLvl = array.get(pendLvls, i)
            pDir = array.get(pendDirs, i)
            line.set_x2(pLn, time)
            if (pDir == 1 and high > pLvl) or (pDir == -1 and low < pLvl)
                line.set_color(pLn, color.new(colH4X, 0))
                array.push(takenLns, pLn)
                array.remove(pendLns,  i)
                array.remove(pendLvls, i)
                array.remove(pendDirs, i)
    // high + low TOPLAM son PEND_N bekleyen seviye kalır (en eskisi düşer)
    while array.size(pendLns) > PEND_N
        line.delete(array.shift(pendLns))
        array.shift(pendLvls)
        array.shift(pendDirs)
    // high + low TOPLAM son TAKEN_N alınan bölge kalır
    while array.size(takenLns) > TAKEN_N
        line.delete(array.shift(takenLns))
    // HTF IRL (FVG) kutuları — oluştuğu HTF barından başlar, sağa uzar. ÖMÜR ARTIK MOTORDAN
    // BAĞIMSIZ (dsp* değişkenleri): ilk dokunuşta değil, ancak H4 KAPANIŞI bölgeyi aşınca ölür.
    // Dokunulmuş (mitige) kutu kesikli kenarlık + daha saydam dolgu ile ayrılır.
    if na(dspUL)
        box.delete(htfFvgUB)
        label.delete(htfFvgUL2)
        htfFvgUB  := na
        htfFvgUL2 := na
        drawnFvgU := na
    else if na(drawnFvgU) or dspUL != drawnFvgU
        box.delete(htfFvgUB)
        label.delete(htfFvgUL2)
        htfFvgUB  := box.new(na(dspUT) ? time : dspUT, dspUH, time, dspUL, xloc=xloc.bar_time, bgcolor=color.new(colFvgL, 88), border_color=color.new(colFvgL, 45))
        htfFvgUL2 := showHtfLbl ? label.new(time, dspUH, htfPre + " IRL (boğa)", xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(colFvgL, 10), size=size.small) : na
        drawnFvgU := dspUL
    if na(dspDL)
        box.delete(htfFvgDB)
        label.delete(htfFvgDL2)
        htfFvgDB  := na
        htfFvgDL2 := na
        drawnFvgD := na
    else if na(drawnFvgD) or dspDL != drawnFvgD
        box.delete(htfFvgDB)
        label.delete(htfFvgDL2)
        htfFvgDB  := box.new(na(dspDT) ? time : dspDT, dspDH, time, dspDL, xloc=xloc.bar_time, bgcolor=color.new(colFvgS, 88), border_color=color.new(colFvgS, 45))
        htfFvgDL2 := showHtfLbl ? label.new(time, dspDL, htfPre + " IRL (ayı)", xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(colFvgS, 10), size=size.small) : na
        drawnFvgD := dspDL
    // Her barda: sağa uzat + mitige durumuna göre stil/yazıyı tazele (mitigasyon kutuyu yeniden
    // yaratmaz, sadece görünümünü değiştirir → kutu ekranda kesintisiz kalır)
    if not na(htfFvgUB)
        box.set_right(htfFvgUB, time)
        box.set_border_style(htfFvgUB, dspUMit ? line.style_dashed : line.style_solid)
        box.set_bgcolor(htfFvgUB, color.new(colFvgL, dspUMit ? 93 : 88))
        if not na(htfFvgUL2)
            label.set_x(htfFvgUL2, time)
            label.set_text(htfFvgUL2, htfPre + " IRL (boğa)" + (dspUMit ? " · mitige · " + str.tostring(dspUTch) + " dokunuş" : ""))
    if not na(htfFvgDB)
        box.set_right(htfFvgDB, time)
        box.set_border_style(htfFvgDB, dspDMit ? line.style_dashed : line.style_solid)
        box.set_bgcolor(htfFvgDB, color.new(colFvgS, dspDMit ? 93 : 88))
        if not na(htfFvgDL2)
            label.set_x(htfFvgDL2, time)
            label.set_text(htfFvgDL2, htfPre + " IRL (ayı)" + (dspDMit ? " · mitige · " + str.tostring(dspDTch) + " dokunuş" : ""))

dEQ    = na(dSwHi) or na(dSwLo) ? na : math.avg(dSwHi, dSwLo)
htfTgt = htfSeek == 0 ? na :
     htfIRL ? (htfSeek == -1 ? (na(fvgUH) ? dEQ : fvgUH) : (na(fvgDL) ? dEQ : fvgDL)) :
     (htfSeek == 1 ? dSwHi : dSwLo)

//──────────────────────── ENSTRÜMAN TİPİ ────────────────────────
isIndexAuto = str.contains(tkr, "NAS100") or str.contains(tkr, "US100") or str.contains(tkr, "NDX") or str.contains(tkr, "US30") or str.contains(tkr, "DJI") or str.contains(tkr, "SPX") or str.contains(tkr, "US500")
isIndex     = instMode == "Endeks" or (instMode == "Otomatik" and isIndexAuto)
useLonEff   = useLon and (not isIndex or useLonIx)  // Endekste Londra ancak useLonIx ile açılır (27 Tem)
isM5        = timeframe.in_seconds() <= 300  // M5/M1 → grade'de FVG/div core seçimi (endeks)

// İşlem modu → efektif filtre bayrakları (kanunlar enstrümana göre otomatik)
isManual  = tradeMode == "Manuel"
smtOnEff  = isManual ? smtOn  : isIndex          // SMT: endekste açık, forexte kapalı
useKQeff  = isManual ? useKQ  : true             // k-filtre her iki hazır modda açık
useDivEff = isManual ? useDiv : (tradeMode == "Fonlu (kalite)" and isIndex)  // div: yalnız Fonlu + endeks
kThrEff   = isIndex ? kThrIx : kThrFx            // k eşiği enstrümana göre (endeks 15 / forex 15 — kâr+düşük-DD)

//──────────────────────── SEANS PENCERELERİ ────────────────────────
// NY pencereleri New York saatine (DST otomatik), Londra penceresi Londra saatine bağlıdır.
// 01:00–05:00 NY = 06:00–10:00 Londra; Avrupa-ABD yaz saati uyumsuzluk haftalarında
// Londra penceresi Londra'ya sabit kalır ve H4 seviyeleri buna göre belirlenir.
TZNY  = "America/New_York"
TZLDN = "Europe/London"
nyPrevS  = isIndex ? "0600-1000" : "0500-0900"
nyWinS   = isIndex ? "1000-1400" : "0900-1300"
nyEntUse = isIndex ? nyEntIdx : nyEntS
inLonPrev = not na(time(timeframe.period, "0200-0600", TZLDN))
inLonWin  = not na(time(timeframe.period, "0600-1000", TZLDN))
inNyPrev  = not na(time(timeframe.period, nyPrevS, TZNY))
inNyWin   = not na(time(timeframe.period, nyWinS, TZNY))
inNyEnt   = not na(time(timeframe.period, nyEntUse, TZNY))

inWin    = (useLonEff and inLonWin) or (useNy and inNyWin)
inEnt    = (useLonEff and inLonWin) or (useNy and inNyWin and inNyEnt)
winStart = inWin and not inWin[1]
winEnd   = not inWin and inWin[1]

// "Seans günü": Londra açılışından NY penceresi kapanışına — div araması bu aralıkta yapılır
daySesNY = isIndex ? "0600-1400" : "0100-1300"
inDay    = not na(time(timeframe.period, daySesNY, TZNY)) or inLonWin

// Zaman makroları (ICT, NY saati) — grade confluence'ı. Video: 2:50 (favori), 3:30–4:10, 9:30–10:10.
inMac1 = not na(time(timeframe.period, "0250-0310", TZNY))
inMac2 = not na(time(timeframe.period, "0330-0410", TZNY))
inMac3 = not na(time(timeframe.period, "0930-1010", TZNY))
macroNow = inMac1 ? 1 : inMac2 ? 2 : inMac3 ? 3 : 0
dayStart = inDay and not inDay[1]

//──────────────────────── DURUM DEĞİŞKENLERİ ────────────────────────
// Önceki H4 aralığı akümülatörleri (bizim sembol + korele sembol)
var float lonAccH  = na
var float lonAccL  = na
var float nyAccH   = na
var float nyAccL   = na
var int   lonAccHT = na
var int   lonAccLT = na
var int   nyAccHT  = na
var int   nyAccLT  = na
var float clonAccH = na
var float clonAccL = na
var float cnyAccH  = na
var float cnyAccL  = na
var bool  lonFresh = false
var bool  nyFresh  = false
// Aktif pencere referansları
var float refH  = na
var float refL  = na
var int   refHT = na
var int   refLT = na
var float crefH = na
var float crefL = na
// Likidite kalitesi (useLQ): swept seviyeye dokunuş sayısı + son 40 pivot
var int   telTchB    = 0
var float telWkB     = na   // v: sweep uç mumunun ret iğnesi %
var float telWkS     = na
var int   telTchS    = 0
var array<float> pvLo = array.new<float>()
var array<float> pvHi = array.new<float>()
// Sweep / CISD durumu
var bool  bullSwept     = false
var bool  bearSwept     = false
var bool  corrSweptLow  = false
var bool  corrSweptHigh = false
var bool  bullCisd      = false
var bool  bearCisd      = false
var float bullCand      = na
var float bearCand      = na
var int   bullCandT     = na
var int   bearCandT     = na
var float sweepLo       = na
var float sweepHi       = na
var int   sweepLoT      = na
var int   sweepHiT      = na
// Ardışık mum serisi open takibi (CISD adayı)
var float dnRunOpen = na
var float upRunOpen = na
var int   dnRunT    = na
var int   upRunT    = na
// Seans bloğu açılışı + blok boyunca koşan uçlar. Bilgi tablosundaki "Ters kaçış" satırını
// besler: blok açılışından bu yana fiyat işlem yönünün TERSİNE en fazla ne kadar gitti.
var float winOpen   = na
var float winHiRun  = na
var float winLoRun  = na
var int   winOpenT  = na   // blok açılış zamanı — kalan süre hesabı için
// SMT failure-taraf girişi: bu setup korele-sweep tetikli (failure) mi?
// Bekleyen emir / pozisyon
var int   pendDir    = 0
var float pendEntry  = na
var float pendSL     = na
var int   pendSetBar = na    // pendEntry'nin son set/taşındığı bar — fill ancak SONRAKİ barda (aynı-bar FVG lookahead'i önler)
var float fvgLvlPend = na
var float cisdLvlB   = na
var float cisdLvlS   = na
var int   armBar     = 0
// Confluence anlık görüntüsü — arming anında sabitlenir, bilgi tablosunda/etiketde gösterilir
var int   armMacro   = 0
var bool  armW1      = false
var float armK       = na    // arming anındaki k (chase ölçüsü) — fill etiketi + bilgi tablosu
var int   armTime    = na    // setup kimliği: arming zamanı (bilgi tablosu)
var bool  armIsLon   = false // setup kimliği: Londra seansı mı
var bool  armW2      = false
var int   posDir     = 0
var float posEntry   = na
var float posSL      = na
var float posTP      = na
var float posR       = na
var bool  beMoved    = false
// Çizim nesneleri
var line  cisdLn     = na
var line  cisdFreeLn = na
var box   fvgBox     = na
var line  fvgCeLn    = na
var box   tpBox      = na
var box   slBox      = na
var line  refHLn  = na
var line  refLLn  = na
var label refHLb  = na
var label refLLb  = na
var int   refHEndT = na
var int   refLEndT = na
var array<box>   boxArr  = array.new<box>()
var array<line>  vLines  = array.new<line>()
var array<label> vLabels = array.new<label>()
// Div (swing SMT) takibi — son teyitli swing + korele değerleri
var float lastPH  = na
var int   lastPHT = na
var float lastPHc = na
var float lastPL  = na
var int   lastPLT = na
var float lastPLc = na
// CISD onayından önceki son div adayı (onay anında çizilir)
var float divHiP1 = na
var int   divHiT1 = na
var float divHiP2 = na
var int   divHiT2 = na
var float divLoP1 = na
var int   divLoT1 = na
var float divLoP2 = na
var int   divLoT2 = na
// Div yön bayrağı (filtre için — çizimden bağımsız): 0 yok / 1 destekleyici / 2 ayna
var int   divHiDir = 0
var int   divLoDir = 0
var string divContTxt = "yok"   // sürekli swing-div (bilgi tablosu, pencere şartı yok)
var int    divContBar = 0
var int    divContT   = na      // ikinci pivotun zamanı — tabloda saat, grafikte etiket
// Sürekli SMT çizim havuzu (döner): son `divCN` tanesi ekranda kalır, eskisi silinir.
var line[]  dcLn = array.new_line()
var label[] dcLb = array.new_label()
// Fib-yarış: iptal seviyesi (arming'de sabitlenir)
// İstatistik
var int   wins   = 0
var int   losses = 0
var int   bes    = 0
var float netR   = 0.0

// Bu barın olayları (alarm için)
bool evArmL  = false
bool evArmS  = false
bool evFillL = false
bool evFillS = false
bool evExit  = false
// YARI-MANUEL ÇALIŞMA İÇİN (26 Tem): emri broker'da SEN kuruyorsun, dolayısıyla
// indikatörün bekleyen emri iptal ettiğini bilmen şart — yoksa broker'daki ölü limit
// TEST EDİLMEMİŞ bir girişe dolar. Aynı şekilde BE (1,5R) ölçümlerin parçası;
// alarmı olmazsa kural fiilen uygulanmaz.
bool evCancel = false
bool evBE     = false

//──────────────────────── ÖNCEKİ H4 ARALIĞI ────────────────────────
if inLonPrev
    fb = not inLonPrev[1]
    lonAccHT := fb or high > lonAccH ? time : lonAccHT
    lonAccLT := fb or low  < lonAccL ? time : lonAccLT
    lonAccH  := fb ? high : math.max(lonAccH, high)
    lonAccL  := fb ? low  : math.min(lonAccL, low)
    clonAccH := fb or na(clonAccH) ? cH : math.max(clonAccH, cH)
    clonAccL := fb or na(clonAccL) ? cL : math.min(clonAccL, cL)
    lonFresh := true
if inNyPrev
    fb = not inNyPrev[1]
    nyAccHT := fb or high > nyAccH ? time : nyAccHT
    nyAccLT := fb or low  < nyAccL ? time : nyAccLT
    nyAccH  := fb ? high : math.max(nyAccH, high)
    nyAccL  := fb ? low  : math.min(nyAccL, low)
    cnyAccH := fb or na(cnyAccH) ? cH : math.max(cnyAccH, cH)
    cnyAccL := fb or na(cnyAccL) ? cL : math.min(cnyAccL, cL)
    nyFresh := true

//──────────────────────── ARDIŞIK MUM SERİSİ OPEN'LARI ────────────────────────
if close < open
    firstDn = not (close[1] < open[1])
    dnRunOpen := firstDn ? open : dnRunOpen
    dnRunT    := firstDn ? time : dnRunT
if close > open
    firstUp = not (close[1] > open[1])
    upRunOpen := firstUp ? open : upRunOpen
    upRunT    := firstUp ? time : upRunT

//──────────────────────── PENCERE BAŞI / SONU ────────────────────────
if winStart
    winOpen   := open
    winHiRun  := high
    winLoRun  := low
    winOpenT  := time
    // Yeni seans → önceki setup'ın arming verisi BAYAT. Temizlenmezse bilgi tablosu iki farklı
    // olayın verisini karıştırıp gösterir (kullanıcı 25 Tem'de tam bunu yakaladı).
    armTime   := na
    armK      := na
    armMacro  := 0
    armW1     := false
    armW2     := false
    isLon = inLonWin
    fresh = isLon ? lonFresh : nyFresh
    refH  := fresh ? (isLon ? lonAccH  : nyAccH)  : na
    refL  := fresh ? (isLon ? lonAccL  : nyAccL)  : na
    refHT := fresh ? (isLon ? lonAccHT : nyAccHT) : na
    refLT := fresh ? (isLon ? lonAccLT : nyAccLT) : na
    crefH := fresh ? (isLon ? clonAccH : cnyAccH) : na
    crefL := fresh ? (isLon ? clonAccL : cnyAccL) : na
    if isLon
        lonFresh := false
    else
        nyFresh := false
    bullSwept     := false
    bearSwept     := false
    corrSweptLow  := false
    corrSweptHigh := false
    bullCisd      := false
    bearCisd      := false
    bullCand      := na
    bearCand      := na
    sweepLo       := na
    sweepHi       := na
    pendDir       := 0
    fvgLvlPend    := na
    divHiT1       := na
    divHiT2       := na
    divHiP1       := na
    divHiP2       := na
    divLoT1       := na
    divLoT2       := na
    divLoP1       := na
    divLoP2       := na
    divHiDir      := 0
    divLoDir      := 0
    cisdLn        := na
    cisdFreeLn    := na
    box.delete(fvgBox)
    line.delete(fvgCeLn)
    fvgBox  := na
    fvgCeLn := na
    // pH4 H/L ışınları
    refHLn := na
    refLLn := na
    refHLb := na
    refLLb := na
    refHEndT := time
    refLEndT := time
    if showRef and not na(refH) and not na(refHT)
        refHLn := line.new(refHT, refH, time, refH, xloc=xloc.bar_time, color=colH4, width=1)
        refHLb := label.new(time, refH, "pH4 H", xloc=xloc.bar_time, style=label.style_none, textcolor=colH4, size=size.small)
        refLLn := line.new(refLT, refL, time, refL, xloc=xloc.bar_time, color=colH4, width=1)
        refLLb := label.new(time, refL, "pH4 L", xloc=xloc.bar_time, style=label.style_none, textcolor=colH4, size=size.small)
    // Dikey seans çizgisi (son N seans tutulur)
    if showVln
        array.push(vLines, line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(colVln, 30), width=1))
        array.push(vLabels, label.new(bar_index, na, isLon ? "Londra" : "New York", yloc=yloc.abovebar, style=label.style_none, textcolor=color.new(colVln, 10), size=size.small))
        while array.size(vLines) > 2 * vlnN
            line.delete(array.shift(vLines))
        while array.size(vLabels) > vlnN
            label.delete(array.shift(vLabels))
if winEnd
    // pendExtN > 0 iken bekleyen emir pencere sonunda İPTAL EDİLMEZ (yarı-otomatik: göster + alarmla,
    // kararı kullanıcı verir). Ömür sınırı aşağıda `bar_index - armBar` ile uygulanır.
    if pendExtN == 0
        pendDir    := 0
        fvgLvlPend := na
        cisdLn     := na
        box.delete(fvgBox)
        line.delete(fvgCeLn)
        fvgBox  := na
        fvgCeLn := na
    cisdFreeLn := na
    refHLn  := na
    refLLn  := na
    refHLb  := na
    refLLb  := na
    if showVln
        array.push(vLines, line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(colVln, 50), style=line.style_dashed, width=1))
        while array.size(vLines) > 2 * vlnN
            line.delete(array.shift(vLines))

canSetup = inWin and not na(refH) and not na(refL)

// Kural 1: pencere içindeki koşan uçlar + açılış çizgisini uzat
if inWin
    winHiRun := na(winHiRun) ? high : math.max(winHiRun, high)
    winLoRun := na(winLoRun) ? low  : math.min(winLoRun, low)

// Pivotlar (bacak sıfırlama + swing-div için ORTAK; div bölümü de bunları kullanır)
ph = ta.pivothigh(high, 1, 1)
pl = ta.pivotlow(low, 1, 1)

// Likidite kalitesi (useLQ): son 40 pivotu sakla; dokunuş sayımı sweep anında yapılır
if not na(pl)
    array.push(pvLo, pl)
    if array.size(pvLo) > 40
        array.shift(pvLo)
if not na(ph)
    array.push(pvHi, ph)
    if array.size(pvHi) > 40
        array.shift(pvHi)

//──────────────────────── SWEEP TESPİTİ ────────────────────────
if canSetup and not bullSwept and low < refL
    bullSwept := true
    sweepLo   := low
    sweepLoT  := time
    bullCand  := dnRunOpen
    bullCandT := dnRunT
    refLEndT  := time
    telTchB   := f_touchCnt(pvLo, refL, 0.10 * math.max(refH - refL, syminfo.mintick))   // likidite kalitesi
    telWkB    := f_wickPct(1)                                                            // ret keskinliği
    if not na(refLLn)
        line.set_x2(refLLn, time)
        refLLn := na
if canSetup and not bearSwept and high > refH
    bearSwept := true
    sweepHi   := high
    sweepHiT  := time
    bearCand  := upRunOpen
    bearCandT := upRunT
    refHEndT  := time
    telTchS   := f_touchCnt(pvHi, refH, 0.10 * math.max(refH - refL, syminfo.mintick))   // likidite kalitesi
    telWkS    := f_wickPct(-1)                                                           // ret keskinliği
    if not na(refHLn)
        line.set_x2(refHLn, time)
        refHLn := na

// Alınmamış pH4 çizgileri pencere sonuna dek sağa uzar
if inWin
    if not na(refHLn)
        line.set_x2(refHLn, time)
    if not na(refLLn)
        line.set_x2(refLLn, time)

//──────────────────────── KORELE SEMBOL SWEEP DURUMU (SMT) ────────────────────────
if inWin and not corrSweptLow and not na(crefL) and cL < crefL
    corrSweptLow := true
if inWin and not corrSweptHigh and not na(crefH) and cH > crefH
    corrSweptHigh := true

// SMT geçerliliği (H4 seviyesi SMT — swing şartı yok)
smtOkLong  = not smtOnEff or corrIsSelf or not corrSweptLow
smtOkShort = not smtOnEff or corrIsSelf or not corrSweptHigh

//──────────────────────── pH4 ETİKETLERİ (H4-X / SMT ibaresi) ────────────────────────
// SMT çizgi yerine etikette gösterilir: sweep eden tarafta "H4-X · SMT",
// sweeplemeyen tarafta "pH4 L/H · SMT". Divergence bozulursa ibare kalkar.
// Etiket konumu: seviye alınmadıysa çizginin sağ ucunda, alındıysa ortasında
// SMT-failure setup'ta bearSwept/bullSwept sanal olduğu için gerçek sweep = "... and not ...Smt"
if inWin
    realBull = bullSwept
    realBear = bearSwept
    if not na(refLLb)
        if not realBull
            refLEndT := time
        smtL = showSmt and not corrIsSelf and (realBull != corrSweptLow)
        label.set_text(refLLb, (realBull ? "H4-X" : "pH4 L") + (smtL ? " · SMT" : ""))
        label.set_textcolor(refLLb, realBull ? colH4X : colH4)
        label.set_x(refLLb, realBull ? int(math.avg(refLT, refLEndT)) : refLEndT)
    if not na(refHLb)
        if not realBear
            refHEndT := time
        smtH = showSmt and not corrIsSelf and (realBear != corrSweptHigh)
        label.set_text(refHLb, (realBear ? "H4-X" : "pH4 H") + (smtH ? " · SMT" : ""))
        label.set_textcolor(refHLb, realBear ? colH4X : colH4)
        label.set_x(refHLb, realBear ? int(math.avg(refHT, refHEndT)) : refHEndT)

//──────────────────────── DIV (SWING SMT) — TAKİP (filtre + görsel) ────────────────────────
// Seans günü içinde, 3-mum kuralıyla teyitli ardışık swing uçlarında iki parite
// uyuşmazsa (biz HH korele LH, biz LH korele HH; diplerde ayna) kesikli çizgi + "div". ph/pl yukarıda hesaplandı.
if dayStart
    lastPH  := na
    lastPHT := na
    lastPHc := na
    lastPL  := na
    lastPLT := na
    lastPLc := na
// Div'ler sweep→CISD onayı arasında sessizce takip edilir, çizilmez;
// CISD onaylandığı anda yalnız EN SON div adayı çizilir (aşağıda, onay bloklarında).
// Takip her zaman yapılır (filtre için); çizim aşağıda showDiv'e bağlı kalır.

// SÜREKLİ SMT'yi grafiğe basar (26 Tem, kullanıcı: "tablo '12 bar önce' diyor, zamanım
// azken tek tek sayamam"). Havuz döner → nesne bütçesi sabit (2 × divCN). Yalnız görsel.
f_divC(t1, p1, t2, p2, txt) =>
    if showDivC
        array.push(dcLn, line.new(t1, p1, t2, p2, xloc=xloc.bar_time, color=colSmt, width=1, style=line.style_dotted))
        array.push(dcLb, label.new(int(math.avg(t1, t2)), math.avg(p1, p2), txt, xloc=xloc.bar_time, style=label.style_none, textcolor=colSmt, size=size.tiny))
        while array.size(dcLn) > divCN
            line.delete(array.shift(dcLn))
            label.delete(array.shift(dcLb))

if inDay[1] and not na(ph)
    curT = time[1]
    curC = cH[1]
    if not corrIsSelf and not na(lastPH) and inWin and bearSwept and not bearCisd
        sup = ph > lastPH and curC < lastPHc
        mir = ph < lastPH and curC > lastPHc
        if sup or mir
            divHiP1  := lastPH
            divHiT1  := lastPHT
            divHiP2  := ph
            divHiT2  := curT
            divHiDir := sup ? 1 : 2
    // SÜREKLİ div (bilgi tablosu): pencere şartı YOK — son swing salınımındaki korele uyumsuzluğu
    if not corrIsSelf and not na(lastPH)
        if ph > lastPH and curC < lastPHc
            divContTxt := "ayı SMT (biz HH, korele LH)"
            divContBar := bar_index
            divContT   := curT
            f_divC(lastPHT, lastPH, curT, ph, "▼ ayı SMT")
        else if ph < lastPH and curC > lastPHc
            divContTxt := "boğa SMT (biz LH, korele HH)"
            divContBar := bar_index
            divContT   := curT
            f_divC(lastPHT, lastPH, curT, ph, "▲ boğa SMT")
    lastPH  := ph
    lastPHT := curT
    lastPHc := curC
if inDay[1] and not na(pl)
    curT = time[1]
    curC = cL[1]
    if not corrIsSelf and not na(lastPL) and inWin and bullSwept and not bullCisd
        sup = pl < lastPL and curC > lastPLc
        mir = pl > lastPL and curC < lastPLc
        if sup or mir
            divLoP1  := lastPL
            divLoT1  := lastPLT
            divLoP2  := pl
            divLoT2  := curT
            divLoDir := sup ? 1 : 2
    if not corrIsSelf and not na(lastPL)
        if pl < lastPL and curC > lastPLc
            divContTxt := "boğa SMT (biz LL, korele HL)"
            divContBar := bar_index
            divContT   := curT
            f_divC(lastPLT, lastPL, curT, pl, "▲ boğa SMT")
        else if pl > lastPL and curC < lastPLc
            divContTxt := "ayı SMT (biz HL, korele LL)"
            divContBar := bar_index
            divContT   := curT
            f_divC(lastPLT, lastPL, curT, pl, "▼ ayı SMT")
    lastPL  := pl
    lastPLT := curT
    lastPLc := curC

//──────────────────────── CISD ADAYI GÜNCELLEME ────────────────────────
if canSetup and bullSwept and not bullCisd
    // CISD referansı = KBM sweep-leg-open (reversal öncesi son ardışık bearish serinin İLK mumu open'ı)
    [bcO, bcT] = f_findSweepLegOpen(1)
    if not na(bcO)
        bullCand  := bcO
        bullCandT := bcT
    if low < sweepLo
        sweepLoT := time
        telWkB   := f_wickPct(1)       // yeni uç → keskinlik uç bara göre
    sweepLo := math.min(sweepLo, low)
if canSetup and bearSwept and not bearCisd
    // CISD referansı = KBM sweep-leg-open (reversal öncesi son ardışık bullish serinin İLK mumu open'ı)
    [scO, scT] = f_findSweepLegOpen(-1)
    if not na(scO)
        bearCand  := scO
        bearCandT := scT
    if high > sweepHi
        sweepHiT := time
        telWkS   := f_wickPct(-1)      // yeni uç → keskinlik uç bara göre
    sweepHi := math.max(sweepHi, high)

//──────────────────────── CISD ONAYI + EMİR KURMA ────────────────────────
if canSetup and bullSwept and not bullCisd and not na(bullCand) and close > bullCand
    bullCisd := true
    cisdLvlB := bullCand
    // Onayı destekleyen son div (varsa) şimdi çizilir
    if showDiv and not na(divLoT2)
        line.new(divLoT1, divLoP1, divLoT2, divLoP2, xloc=xloc.bar_time, color=colSmt, width=1, style=line.style_dashed)
        label.new(int(math.avg(divLoT1, divLoT2)), math.avg(divLoP1, divLoP2), "div", xloc=xloc.bar_time, style=label.style_none, textcolor=colSmt, size=size.tiny)
        divLoT1 := na
        divLoT2 := na
        divLoP1 := na
        divLoP2 := na
    kValB  = (close - bullCand) / math.max(bullCand - sweepLo, syminfo.mintick) * 100
    divOkL = not useDivEff or (divMd == "Herhangi" ? divLoDir > 0 : divLoDir == 1)
    kqOkL  = not useKQeff or kValB < kThrEff
    lqOkL  = not useLQ or telTchB >= lqMin                   // Likidite kalitesi: seviye gerçek stop kümesi mi
    armedL = inEnt and posDir == 0 and smtOkLong and kqOkL and divOkL and lqOkL
    if armedL
        pendDir    := 1
        pendEntry  := cisdLvlB
        pendSL     := sweepLo
        fvgLvlPend := na
        armBar     := bar_index
        pendSetBar := bar_index
        evArmL     := true
        armMacro   := macroNow                                        // zaman makrosu (bilgi)
        armK       := kValB                                           // chase ölçüsü (bilgi)
        armTime    := time
        armIsLon   := inLonWin
        armW1      := not corrIsSelf and not corrSweptLow  // stage-1: H4-seviye divergence
        armW2      := divLoDir > 0                                     // stage-2: LTF swing-div
        if showCisd and not na(bullCandT)
            cisdLn := line.new(bullCandT, cisdLvlB, time, cisdLvlB, xloc=xloc.bar_time, color=colCisd, width=2)
    else
        // İşlem açılmayan CISD de bilgi amaçlı çizilir (kesikli)
        if showCisd and not na(bullCandT)
            cisdFreeLn := line.new(bullCandT, cisdLvlB, time, cisdLvlB, xloc=xloc.bar_time, color=colCisd, width=1, style=line.style_dashed)
if canSetup and bearSwept and not bearCisd and not na(bearCand) and close < bearCand
    bearCisd := true
    cisdLvlS := bearCand
    // Onayı destekleyen son div (varsa) şimdi çizilir
    if showDiv and not na(divHiT2)
        line.new(divHiT1, divHiP1, divHiT2, divHiP2, xloc=xloc.bar_time, color=colSmt, width=1, style=line.style_dashed)
        label.new(int(math.avg(divHiT1, divHiT2)), math.avg(divHiP1, divHiP2), "div", xloc=xloc.bar_time, style=label.style_none, textcolor=colSmt, size=size.tiny)
        divHiT1 := na
        divHiT2 := na
        divHiP1 := na
        divHiP2 := na
    kValS  = (bearCand - close) / math.max(sweepHi - bearCand, syminfo.mintick) * 100
    divOkS = not useDivEff or (divMd == "Herhangi" ? divHiDir > 0 : divHiDir == 1)
    kqOkS  = not useKQeff or kValS < kThrEff
    lqOkS  = not useLQ or telTchS >= lqMin                   // Likidite kalitesi: seviye gerçek stop kümesi mi
    armedS = inEnt and posDir == 0 and smtOkShort and kqOkS and divOkS and lqOkS
    if armedS
        pendDir    := -1
        pendEntry  := cisdLvlS
        pendSL     := sweepHi
        fvgLvlPend := na
        armBar     := bar_index
        pendSetBar := bar_index
        evArmS     := true
        armMacro   := macroNow                                         // zaman makrosu (bilgi)
        armK       := kValS                                            // chase ölçüsü (bilgi)
        armTime    := time
        armIsLon   := inLonWin
        armW1      := not corrIsSelf and not corrSweptHigh  // stage-1: H4-seviye divergence
        armW2      := divHiDir > 0                                     // stage-2: LTF swing-div
        if showCisd and not na(bearCandT)
            cisdLn := line.new(bearCandT, cisdLvlS, time, cisdLvlS, xloc=xloc.bar_time, color=colCisd, width=2)
    else
        if showCisd and not na(bearCandT)
            cisdFreeLn := line.new(bearCandT, cisdLvlS, time, cisdLvlS, xloc=xloc.bar_time, color=colCisd, width=1, style=line.style_dashed)

// Bloklu CISD çizgisi pencere boyunca sağa uzar
if not na(cisdFreeLn)
    if inWin
        line.set_x2(cisdFreeLn, time)
    else
        cisdFreeLn := na

//──────────────────────── BEKLEYEN EMİR YÖNETİMİ ────────────────────────
if pendDir == 1
    // Displacement FVG'si oluşursa girişi yakın olana taşı; kutuda yalnız güncel FVG tutulur
    if useFvg and low > high[2]
        lvl = fvgCE ? math.avg(low, high[2]) : low
        dpOkL = not useDP or na(refL) or na(refH) or lvl <= math.avg(refL, refH)   // long FVG discount'ta mı (yoksa chase → CISD retest'te kal)
        if dpOkL
            newE = math.max(cisdLvlB, lvl)
            if newE != pendEntry
                pendSetBar := bar_index    // giriş taşındı → bu barda dolma (retest sonraki barda)
            pendEntry  := newE
            fvgLvlPend := lvl
            if showFvgB
                box.delete(fvgBox)
                line.delete(fvgCeLn)
                fvgBox  := box.new(bar_index - 2, low, bar_index, high[2], bgcolor=color.new(colFvgL, 85), border_color=color.new(colFvgL, 100))
                fvgCeLn := line.new(bar_index - 2, math.avg(low, high[2]), bar_index, math.avg(low, high[2]), color=color.new(colFvgL, 40), style=line.style_dotted)
    pendSL := math.min(pendSL, low)
    if smtOnEff and not corrIsSelf and corrSweptLow
        pendDir := 0  // SMT bozuldu → iptal (failure-taraf setup'ta korele-sweep tetikleyici, iptal etme)
        evCancel := true
        cisdLn  := na
        box.delete(fvgBox)
        line.delete(fvgCeLn)
        fvgBox  := na
        fvgCeLn := na
    else if not inEnt and (pendExtN == 0 or bar_index - armBar > pendExtN)
        pendDir := 0  // giriş penceresi kapandı (+ uzatma ömrü de bitti) → iptal
        evCancel := true
        cisdLn  := na
        box.delete(fvgBox)
        line.delete(fvgCeLn)
        fvgBox  := na
        fvgCeLn := na
    else
        if not na(cisdLn)
            line.set_x2(cisdLn, time)
        if not na(fvgBox)
            box.set_right(fvgBox, bar_index)
            line.set_x2(fvgCeLn, bar_index)
        if bar_index > pendSetBar and low <= pendEntry
            posDir   := 1
            posEntry := math.min(open, pendEntry)
            posSL    := pendSL
            posR     := posEntry - posSL
            pendDir  := 0
            cisdLn   := na
            // FVG kutusu yalnız giriş FVG'den olduysa kalır
            if not (not na(fvgLvlPend) and pendEntry == fvgLvlPend)
                box.delete(fvgBox)
                line.delete(fvgCeLn)
            fvgBox  := na
            fvgCeLn := na
            if posR <= 0
                posDir := 0
            else
                posTP   := posEntry + rrMult * posR
                beMoved := false
                evFillL := true
                // Miktar kutunun İÇİNE yazılır (TV position tool mantığı): SL kutusunda lot +
                // riske edilen para, TP kutusunda kazanç. Girişte donar, sonra güncellenmez.
                qLotL   = f_lotV(posR)
                qCashL  = f_cashV(qLotL, posR)
                tpBox   := box.new(bar_index, posTP, bar_index, posEntry, bgcolor=color.new(colTp, 85), border_color=color.new(colTp, 40), text=qtyOnBox ? "+" + f_cashTxt(qCashL * rrMult) : "", text_color=colTp, text_size=size.small, text_halign=text.align_center, text_valign=text.align_center)
                slBox   := box.new(bar_index, posEntry, bar_index, posSL, bgcolor=color.new(colSl, 85), border_color=color.new(colSl, 40), text=qtyOnBox ? f_lotTxt(qLotL) + "   −" + f_cashTxt(qCashL) : "", text_color=colSl, text_size=size.small, text_halign=text.align_center, text_valign=text.align_center)
                // Pencere dışı dolan giriş BACKTEST EDİLMEMİŞTİR → etikette yıldızla işaretlenir
                if showEntLbl
                    label.new(bar_index, low, (inEnt ? "AL @ " : "AL* @ ") + str.tostring(posEntry, format.mintick) + " ·n" + str.tostring(telTchB) + " ·k" + str.tostring(math.round(armK)) + (inEnt ? "" : " ·pencere dışı"), style=label.style_label_up, color=colTp, textcolor=color.white, size=size.small)
else if pendDir == -1
    if useFvg and high < low[2]
        lvl = fvgCE ? math.avg(high, low[2]) : high
        dpOkS = not useDP or na(refL) or na(refH) or lvl >= math.avg(refL, refH)   // short FVG premium'da mı (yoksa chase → CISD retest'te kal)
        if dpOkS
            newE = math.min(cisdLvlS, lvl)
            if newE != pendEntry
                pendSetBar := bar_index    // giriş taşındı → bu barda dolma (retest sonraki barda)
            pendEntry  := newE
            fvgLvlPend := lvl
            if showFvgB
                box.delete(fvgBox)
                line.delete(fvgCeLn)
                fvgBox  := box.new(bar_index - 2, low[2], bar_index, high, bgcolor=color.new(colFvgS, 85), border_color=color.new(colFvgS, 100))
                fvgCeLn := line.new(bar_index - 2, math.avg(high, low[2]), bar_index, math.avg(high, low[2]), color=color.new(colFvgS, 40), style=line.style_dotted)
    pendSL := math.max(pendSL, high)
    if smtOnEff and not corrIsSelf and corrSweptHigh
        pendDir := 0  // SMT bozuldu → iptal (failure-taraf setup'ta korele-sweep tetikleyici, iptal etme)
        evCancel := true
        cisdLn  := na
        box.delete(fvgBox)
        line.delete(fvgCeLn)
        fvgBox  := na
        fvgCeLn := na
    else if not inEnt and (pendExtN == 0 or bar_index - armBar > pendExtN)
        pendDir := 0  // giriş penceresi kapandı (+ uzatma ömrü de bitti) → iptal
        evCancel := true
        cisdLn  := na
        box.delete(fvgBox)
        line.delete(fvgCeLn)
        fvgBox  := na
        fvgCeLn := na
    else
        if not na(cisdLn)
            line.set_x2(cisdLn, time)
        if not na(fvgBox)
            box.set_right(fvgBox, bar_index)
            line.set_x2(fvgCeLn, bar_index)
        if bar_index > pendSetBar and high >= pendEntry
            posDir   := -1
            posEntry := math.max(open, pendEntry)
            posSL    := pendSL
            posR     := posSL - posEntry
            pendDir  := 0
            cisdLn   := na
            if not (not na(fvgLvlPend) and pendEntry == fvgLvlPend)
                box.delete(fvgBox)
                line.delete(fvgCeLn)
            fvgBox  := na
            fvgCeLn := na
            if posR <= 0
                posDir := 0
            else
                posTP   := posEntry - rrMult * posR
                beMoved := false
                evFillS := true
                qLotS   = f_lotV(posR)
                qCashS  = f_cashV(qLotS, posR)
                tpBox   := box.new(bar_index, posEntry, bar_index, posTP, bgcolor=color.new(colTp, 85), border_color=color.new(colTp, 40), text=qtyOnBox ? "+" + f_cashTxt(qCashS * rrMult) : "", text_color=colTp, text_size=size.small, text_halign=text.align_center, text_valign=text.align_center)
                slBox   := box.new(bar_index, posSL, bar_index, posEntry, bgcolor=color.new(colSl, 85), border_color=color.new(colSl, 40), text=qtyOnBox ? f_lotTxt(qLotS) + "   −" + f_cashTxt(qCashS) : "", text_color=colSl, text_size=size.small, text_halign=text.align_center, text_valign=text.align_center)
                if showEntLbl
                    label.new(bar_index, high, (inEnt ? "SAT @ " : "SAT* @ ") + str.tostring(posEntry, format.mintick) + " ·n" + str.tostring(telTchS) + " ·k" + str.tostring(math.round(armK)) + (inEnt ? "" : " ·pencere dışı"), style=label.style_label_down, color=colSl, textcolor=color.white, size=size.small)

//──────────────────────── POZİSYON YÖNETİMİ ────────────────────────
// Aynı barda hem SL hem TP görülürse muhafazakâr varsayım: önce SL sayılır.
if posDir == 1
    if not na(tpBox)
        box.set_right(tpBox, bar_index)
        box.set_right(slBox, bar_index)
        box.set_bottom(slBox, beMoved ? posEntry : posSL)
    curSL = beMoved ? posEntry : posSL
    if low <= curSL
        evExit := true
        if beMoved
            bes := bes + 1
            if showResLbl
                label.new(bar_index, low, "BE ●", style=label.style_label_up, color=color.new(colBe, 20), textcolor=color.white, size=size.small)
        else
            losses := losses + 1
            netR   := netR - 1
            if showResLbl
                label.new(bar_index, low, "SL ✗ −1R", style=label.style_label_up, color=colSl, textcolor=color.white, size=size.small)
        posDir   := 0
        bullCisd := false
        bearCisd := false
        bullCand := na
        bearCand := na
    else
        if not beMoved and high >= posEntry + beMult * posR
            beMoved := true
            evBE    := true
        if high >= posTP
            evExit := true
            wins   := wins + 1
            netR   := netR + rrMult
            if showResLbl
                label.new(bar_index, high, "TP ✓ +" + str.tostring(rrMult, "#.##") + "R", style=label.style_label_down, color=colTp, textcolor=color.white, size=size.small)
            posDir   := 0
            bullCisd := false
            bearCisd := false
            bullCand := na
            bearCand := na
else if posDir == -1
    if not na(tpBox)
        box.set_right(tpBox, bar_index)
        box.set_right(slBox, bar_index)
        box.set_top(slBox, beMoved ? posEntry : posSL)
    curSL = beMoved ? posEntry : posSL
    if high >= curSL
        evExit := true
        if beMoved
            bes := bes + 1
            if showResLbl
                label.new(bar_index, high, "BE ●", style=label.style_label_down, color=color.new(colBe, 20), textcolor=color.white, size=size.small)
        else
            losses := losses + 1
            netR   := netR - 1
            if showResLbl
                label.new(bar_index, high, "SL ✗ −1R", style=label.style_label_down, color=colSl, textcolor=color.white, size=size.small)
        posDir   := 0
        bullCisd := false
        bearCisd := false
        bullCand := na
        bearCand := na
    else
        if not beMoved and low <= posEntry - beMult * posR
            beMoved := true
            evBE    := true
        if low <= posTP
            evExit := true
            wins   := wins + 1
            netR   := netR + rrMult
            if showResLbl
                label.new(bar_index, low, "TP ✓ +" + str.tostring(rrMult, "#.##") + "R", style=label.style_label_up, color=colTp, textcolor=color.white, size=size.small)
            posDir   := 0
            bullCisd := false
            bearCisd := false
            bullCand := na
            bearCand := na

// İşlem kutularının yaşam döngüsü (mod seçimine göre)
if evExit and not na(tpBox)
    if tbMode == "Sadece aktif"
        box.delete(tpBox)
        box.delete(slBox)
    else if tbMode == "Son N"
        array.push(boxArr, tpBox)
        array.push(boxArr, slBox)
        while array.size(boxArr) > 2 * tbN
            box.delete(array.shift(boxArr))
    tpBox := na
    slBox := na

//──────────────────────── ÇİZİMLER ────────────────────────
bgcolor(showBg and inWin ? color.new(colVln, 96) : na)
// BEKLEYEN GİRİŞ (limit) — yatay seviye. `style_linebr` yalnız `na`'da kırılır; seviye
// TAŞINDIĞINDA (yeni FVG fiyata daha yakın çıktı ya da yeni setup kuruldu) iki değeri
// ÇAPRAZ bir doğruyla birleştiriyordu — grafikte "eğik turuncu çizgi" olarak görünüp
// hareket ediyormuş gibi okunuyordu (26 Tem, kullanıcı sordu). Taşınma barında seri
// bilerek `na` yapılır: çapraz yerine 1 barlık boşluk kalır, seviye hep yatay okunur.
pendPx  = pendDir != 0 ? pendEntry : na
pendPlt = na(pendPx) or (not na(pendPx[1]) and pendPx != pendPx[1]) ? na : pendPx
plot(pendPlt, "Giriş (limit)", color=colPend, style=plot.style_linebr, linewidth=1)

// ─────────── DEBUG: CISD referansı (bullCand, kilitli) teşhisi — CAMGÖBEĞİ ───────────
// bullCand = long CISD referansı; artık yalnız aşağı kilitlenir. Ham legLoDnOpen'ı görmek için altta gri.

//──────────────────────── BİLGİ TABLOSU (setup + istatistik) ────────────────────────
// Grade motoru KALDIRILDI (KBM CISD sonrasi siralamiyordu). Notu goz verir; tablo HAM baglam.
tSz = tblSize == "Küçük" ? size.small : tblSize == "Büyük" ? size.large : size.normal
tPo = tblPos == "Sağ alt" ? position.bottom_right : tblPos == "Sol üst" ? position.top_left : tblPos == "Sol alt" ? position.bottom_left : position.top_right
var table tbl = table.new(tPo, 2, 12, bgcolor=tblBg, border_width=1, border_color=color.new(color.gray, 50))
if showTbl and barstate.islast
    dirNow = pendDir != 0 ? pendDir : posDir != 0 ? posDir : bullSwept and not bearSwept ? 1 : bearSwept and not bullSwept ? -1 : 0
    htfTF  = htfRes == "240" ? "H4" : "1G"
    mumTF  = mumRes == "60" ? "H1" : mumRes == "240" ? "H4" : "1G"

    // ── SETUP KİMLİĞİ ──
    // ARMED = CISD onaylandı + tüm filtreler geçti (bekleyen emir veya pozisyon var).
    // Armed DEĞİLKEN arming verisi (saat/k/SMT/div/makro) YOKTUR — bayat değer gösterilmez;
    // onun yerine sweep zamanı gösterilir. (25 Tem: tablo iki farklı olayı karıştırıyordu.)
    armed  = pendDir != 0 or posDir != 0
    durum  = posDir != 0 ? "POZİSYONDA" : pendDir != 0 ? "BEKLEYEN EMİR" : (bullSwept or bearSwept) ? "İZLEME — sweep var, CISD onayı yok" : "setup yok"
    swTime = dirNow == 1 ? sweepLoT : dirNow == -1 ? sweepHiT : na
    refTm  = armed ? armTime : swTime
    saat   = na(refTm) ? "-" : str.format_time(refTm, "dd MMM HH:mm", "America/New_York")
    seans  = na(refTm) ? "" : (armed ? (armIsLon ? " · Londra" : " · NY") : (inLonWin ? " · Londra" : " · NY"))
    idTxt  = durum + (na(refTm) ? "" : "  |  " + (armed ? "kuruldu " : "sweep ") + saat + seans)
    ePx    = pendDir != 0 ? pendEntry : posDir != 0 ? posEntry : na
    sPx    = pendDir != 0 ? pendSL    : posDir != 0 ? posSL    : na
    rNow   = na(ePx) or na(sPx) ? na : math.abs(ePx - sPx)
    entTxt = na(ePx) ? "-" : "giriş " + str.tostring(ePx, format.mintick) + "  ·  SL " + str.tostring(sPx, format.mintick) + "  ·  TP " + str.tostring(dirNow == 1 ? ePx + rrMult * rNow : ePx - rrMult * rNow, format.mintick)

    // ── RİSK / LOT: emri kullanıcı giriyor, miktar alarm anında hazır olmalı ──
    // BEKLEYEN emirde de dolu — asıl kullanım anı orası. Yuvarlama aşağı olduğu için
    // gösterilen para riski tavanın (riskCash) ALTINDA kalır, üstünde değil.
    qLot   = f_lotV(rNow)
    qCash  = f_cashV(qLot, rNow)
    lotTxt = na(rNow) ? "-" :
     f_lotTxt(qLot) + "   ·   risk " + f_cashTxt(qCash) + " / hedef +" + f_cashTxt(qCash * rrMult) +
     "   ·   stop " + f_advTxt(rNow, isIndex) + (isIndex ? " puan" : " pip")

    // ── ALINAN pH4 SEVİYESİ: fiyatıyla ──
    swLvl  = dirNow == 1 ? refL : dirNow == -1 ? refH : na
    swExt  = dirNow == 1 ? sweepLo : dirNow == -1 ? sweepHi : na
    swpPct = na(swLvl) or na(swExt) or na(refH) or na(refL) ? na : math.abs(swLvl - swExt) / math.max(refH - refL, syminfo.mintick) * 100
    nTch   = dirNow == 1 ? telTchB : telTchS
    liqTxt = na(swLvl) or na(swpPct) ? "sweep yok" :
     (dirNow == 1 ? "pH4 LOW " : "pH4 HIGH ") + str.tostring(swLvl, format.mintick) +
     "  →  uç " + str.tostring(swExt, format.mintick) + " (%" + str.tostring(math.round(swpPct)) + ")" +
     "  ·  n" + str.tostring(nTch) + (nTch >= 2 ? " ✔" : " ✘ zayıf")

    // ── HTF bağlam — YÖN en başta, açık seçik ──
    yonTxt = htfSeek == 1 ? "▲ YUKARI" : htfSeek == -1 ? "▼ AŞAĞI" : "— yön yok"
    fazTxt = htfSeek == 0 ? "bağlam yok" :
     htfIRL ? "ERL alındı, şimdi IRL (adil değer) arıyor" : "IRL doldu, şimdi ERL (likidite) arıyor"
    ctxCol = htfSeek == 0 ? tblNe : htfSeek == dirNow ? tblUp : tblDn
    ctxTxt = yonTxt + "   ·   " + fazTxt +
     (htfSeek == 0 or dirNow == 0 ? "" : htfSeek == dirNow ? "   ✔ setup ile UYUMLU" : "   ✘ setup ile ÇELİŞKİLİ")

    lvlTxt = (na(dSwHi) ? "üst yok" : "üst " + str.tostring(dSwHi, format.mintick) + (hiTaken ? " (alındı)" : " (duruyor)")) + "    " +
     (na(dSwLo) ? "alt yok" : "alt " + str.tostring(dSwLo, format.mintick) + (loTaken ? " (alındı)" : " (duruyor)"))
    // IRL satırı: FVG'nin BOĞA/AYI olması setup yönüyle ilgili DEĞİL — sadece boşluğun hangi
    // hareketin bıraktığını söyler. Kullanıcı için asıl bilgi: fiyata göre nerede + hedef mi.
    // Satır GÖRSEL değişkenlerden (dsp*) okur → kutuyla birebir aynı şeyi anlatır. Mitige olan
    // IRL "· mitige (dokunuldu, dolmadı)" ile işaretlenir: motor mitigasyonda fazı ERL'e
    // çevirdiği için üstteki bağlam satırı "IRL doldu, şimdi ERL arıyor" der — bu ibare olmadan
    // tablo kendisiyle çelişiyormuş gibi okunur. ◄ HEDEF motordan gelir (htfTgt), yani mitige
    // olmuş bir IRL'e hedef damgası BASILMAZ.
    mitU   = dspUMit ? " · mitige (dokunuldu, dolmadı)" : ""
    mitD   = dspDMit ? " · mitige (dokunuldu, dolmadı)" : ""
    fUp    = na(dspUL) ? "" : (dspUH < close ? "altta" : "üstte") + " boğa " + str.tostring(dspUL, format.mintick) + "–" + str.tostring(dspUH, format.mintick) +
     (not na(htfTgt) and not na(fvgUH) and htfTgt == fvgUH ? " ◄ HEDEF" : "") + mitU
    fDn    = na(dspDL) ? "" : (dspDL > close ? "üstte" : "altta") + " ayı " + str.tostring(dspDL, format.mintick) + "–" + str.tostring(dspDH, format.mintick) +
     (not na(htfTgt) and not na(fvgDL) and htfTgt == fvgDL ? " ◄ HEDEF" : "") + mitD
    fvgTxt = na(dspUL) and na(dspDL) ? "IRL yok" : fUp + (fUp != "" and fDn != "" ? "    " : "") + fDn

    // ── Mum 2/3 · div · confluence · hedef ──
    // Setup varken YALNIZ setup yönü sayılır. Setup YOKKEN de gösterilir (ok işaretiyle):
    // kullanıcı ek confluence'ın hazır olduğunu CISD onayı gelmeden görebilsin diye.
    mDir   = dirNow != 0 ? dirNow : (c2Up or c3Up) ? 1 : (c2Dn or c3Dn) ? -1 : 0
    c3ok   = mDir == 1 ? c3Up : mDir == -1 ? c3Dn : false
    c2ok   = mDir == 1 ? c2Up : mDir == -1 ? c2Dn : false
    eng    = mDir == 1 ? engU : mDir == -1 ? engD : false
    resp50 = na(c50) ? "" : (mDir == 1 ? (close > c50 ? "  %50 ✔" : "  %50 ✘") : (close < c50 ? "  %50 ✔" : "  %50 ✘"))
    mumOk  = c2ok or c3ok
    mumSaat= not mumOk or na(mT1) ? "" : str.format_time(mT1, "HH:mm", "America/New_York") + "  "
    // Setup yönü belliyken ok gereksiz (zaten başlıkta ▲/▼ var); yönsüzken hangi yöne
    // niteliyor bilgisi kritik → ok basılır.
    mumYon = not mumOk or dirNow != 0 ? "" : (mDir == 1 ? " ▲" : " ▼")
    mumTxt = c3ok ? (mumSaat + "Mum 3 ✔" + mumYon + (eng ? "   engulf ✔" : resp50)) :
     c2ok ? (mumSaat + "Mum 2 ✔" + mumYon + (eng ? "   engulf ✔" : resp50)) : "yok"

    // ── TERS KAÇIŞ: seans bloğu açılışından bu yana işlem yönünün TERSİNE en uzak nokta ──
    // Gerekçe (kullanıcı): blok ters yöne çok gittiyse, bağlam doğru olsa bile yöne hareket
    // edecek yer/zaman kalmamış olabilir. Veri zaten `winOpen`/`winHiRun`/`winLoRun`'da.
    // ÖLÇÜLMEDİ, kapı değil → eşik ve renk kodu YOK, ham sayı gösterilir.
    // Endekste puan (ham fark), forexte pip (= fark ÷ mintick×10; 5-hane ve JPY'de doğru).
    advU   = na(winOpen) or na(winHiRun) ? na : winHiRun - winOpen   // yukarı kaçış → SHORT'un aleyhine
    advD   = na(winOpen) or na(winLoRun) ? na : winOpen - winLoRun   // aşağı kaçış → LONG'un aleyhine
    advRaw = dirNow == 1 ? advD : dirNow == -1 ? advU : na
    birim  = isIndex ? " puan" : " pip"
    // Kalan süre: tüm bloklar tam 4 saat (Londra 01:00–05:00 NY · NY forex 09:00–13:00 ·
    // NY endeks 10:00–14:00). Blok kapandıysa uçlar dondu, bunu açıkça yaz.
    gecenDk = na(winOpenT) ? na : (time - winOpenT) / 60000
    kalanDk = na(gecenDk) ? na : math.max(240 - gecenDk, 0)
    kalanSa = na(kalanDk) ? 0 : int(math.floor(kalanDk / 60))
    kalanMn = na(kalanDk) ? 0 : int(math.round(kalanDk % 60))
    sureTxt = na(kalanDk) ? "" : not inWin ? "   ·   blok kapandı" :
     "   ·   blokta " + str.tostring(kalanSa) + "s" + (kalanMn < 10 ? "0" : "") + str.tostring(kalanMn) + "d kaldı"
    advTxt = na(winOpen) ? "-" :
     (dirNow == 0 ? "▲ " + f_advTxt(advU, isIndex) + " / ▼ " + f_advTxt(advD, isIndex) + birim :
      f_advTxt(advRaw, isIndex) + birim + " (max)") + sureTxt
    // Saat, grafikteki noktalı çizginin sağ ucuyla AYNI olayı gösterir → kullanıcı bar saymaz.
    divTxt = divContTxt + (divContBar > 0 ?
     "   ·   " + (na(divContT) ? "" : str.format_time(divContT, "HH:mm", "America/New_York") + " ") +
     "(" + str.tostring(bar_index - divContBar) + " bar önce)" : "")
    wick   = dirNow == 1 ? telWkB : telWkS
    // Kod yerine AÇIK YAZI (kullanıcı isteği). Armed değilken chase/SMT/div/makro henüz
    // belirlenmemiştir (arming anında donuyorlar) → "onay bekliyor" denir, uydurulmaz.
    dokTxt = "dokunuş " + str.tostring(nTch) + (nTch >= 2 ? " (eşit dip/tepe)" : " (tek — zayıf)")
    ignTxt = na(wick) ? "" : "  ·  ret iğnesi %" + str.tostring(math.round(wick)) + (wick >= 60 ? " (keskin)" : wick <= 25 ? " (gövdeli)" : "")
    conf   = armed ?
     dokTxt + ignTxt +
     "  ·  chase " + (na(armK) ? "-" : str.tostring(math.round(armK)) + "/" + str.tostring(math.round(kThrEff))) +
     "  ·  giriş " + (pendDir != 0 and pendEntry != (dirNow == 1 ? cisdLvlB : cisdLvlS) ? "FVG" : "CISD retest") +
     (armW1 ? "  ·  H4-SMT var" : "") + (armW2 ? "  ·  swing-div var" : "") + (armMacro > 0 ? "  ·  makro saatinde" : "") :
     dokTxt + ignTxt + "   ·   (chase / SMT / div: CISD onayı bekliyor)"
    // Emir varsa R cinsinden; emir yokken bile hedefi göster (fiyat + günlük ATR'nin kaçı)
    room   = na(htfTgt) or na(rNow) or na(ePx) or rNow <= 0 ? na : (dirNow == 1 ? htfTgt - ePx : ePx - htfTgt) / rNow
    tgtAtr = na(htfTgt) or na(dATR) or dATR <= 0 ? na : math.abs(htfTgt - close) / dATR
    tgtTxt = not na(room) ? str.tostring(room, "#.#") + "R  →  " + str.tostring(htfTgt, format.mintick) + (room >= 2 ? "  ✔" : "  ✘ dar") :
     na(htfTgt) ? "hedef yok" :
     str.tostring(htfTgt, format.mintick) + "  (emir yok · " + (na(tgtAtr) ? "-" : str.tostring(tgtAtr, "#.##") + "× gün.ATR") + ")"

    // Renkler grpT'den gelir — grafik araçlarının renklerinden BAĞIMSIZ (26 Tem).
    // Nötr yazı rengi input değil, `chart.fg_color`: temayla birlikte kendi dönsün.
    hdrC = color.new(chart.fg_color, 25)
    dirC = dirNow == 1 ? tblUp : dirNow == -1 ? tblDn : tblNe
    // Armed değilken "▲ LONG" sinyal gibi okunuyordu; izleme durumu ayrı yazılır.
    bas = dirNow == 0 ? "— SETUP YOK" : armed ? (dirNow == 1 ? "▲ LONG" : "▼ SHORT") : (dirNow == 1 ? "○ long izleniyor" : "○ short izleniyor")
    table.cell(tbl, 0, 0,  bas, text_color=armed ? dirC : color.new(dirC, 35), text_size=tSz)
    table.cell(tbl, 1, 0,  idTxt,  text_color=dirC, text_size=tSz)
    table.cell(tbl, 0, 1,  "Emir", text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 1, 1,  entTxt, text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 0, 2,  "Risk / lot", text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 1, 2,  lotTxt, text_color=na(qLot) or qLot <= 0 ? tblNe : chart.fg_color, text_size=tSz)
    table.cell(tbl, 0, 3,  "ALINAN SEVİYE", text_color=hdrC, text_size=tSz)
    table.cell(tbl, 1, 3,  liqTxt, text_color=nTch >= 2 ? tblUp : tblDn, text_size=tSz)
    table.cell(tbl, 0, 4,  htfTF + " bağlam", text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 1, 4,  ctxTxt, text_color=ctxCol, text_size=tSz)
    table.cell(tbl, 0, 5,  htfTF + " ERL (swing)", text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 1, 5,  lvlTxt, text_color=hiTaken or loTaken ? tblDn : chart.fg_color, text_size=tSz)
    table.cell(tbl, 0, 6,  htfTF + " IRL (FVG)", text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 1, 6,  fvgTxt, text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 0, 7,  mumTF + " Mum 2/3", text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 1, 7,  mumTxt, text_color=mumOk ? tblUp : tblNe, text_size=tSz)
    table.cell(tbl, 0, 8,  "Swing div", text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 1, 8,  divTxt, text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 0, 9,  "Confluence", text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 1, 9,  conf,   text_color=chart.fg_color, text_size=tSz)
    // Ters kaçış ile Hedefe yer aynı aileden ("gidecek yer kaldı mı") → yan yana duruyorlar.
    // Ters kaçışta eşik/renk YOK: hangi değerin "çok" olduğu ölçülmedi, uydurulmuş bir eşik
    // yanlış güven verir. Ham sayı gösterilir, kalibrasyon kullanıcıda.
    table.cell(tbl, 0, 10, "Ters kaçış", text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 1, 10, advTxt, text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 0, 11, "Hedefe yer", text_color=chart.fg_color, text_size=tSz)
    table.cell(tbl, 1, 11, tgtTxt, text_color=na(room) ? tblNe : room >= 2 ? tblUp : tblDn, text_size=tSz)
    // İstatistik / Net R satırları KALDIRILDI (kullanıcı isteği) — tablo canlı setup bağlamı için.

//──────────────────────── ALARMLAR ────────────────────────
// Alarm kurarken "Once Per Bar Close" seçmeniz önerilir.
alertcondition(evArmL,  "SMC: Long Setup",  "SMC Scalp — LONG setup: CISD onaylandı, limit emir seviyesi hazır")
alertcondition(evArmS,  "SMC: Short Setup", "SMC Scalp — SHORT setup: CISD onaylandı, limit emir seviyesi hazır")
alertcondition(evFillL, "SMC: Long Giriş",  "SMC Scalp — LONG girişi tetiklendi")
alertcondition(evFillS, "SMC: Short Giriş", "SMC Scalp — SHORT girişi tetiklendi")
alertcondition(evExit,  "SMC: Çıkış",       "SMC Scalp — pozisyon kapandı (TP/SL/BE)")
// Yarı-manuel akışın iki zorunlu alarmı — emri broker'da kullanıcı yönetiyor:
alertcondition(evCancel, "SMC: Setup İPTAL", "SMC Scalp — bekleyen setup İPTAL (SMT bozuldu ya da emir ömrü doldu) → broker'daki limit emri KALDIR")
alertcondition(evBE,     "SMC: Başabaş (BE)", "SMC Scalp — +1,5R görüldü → stopu girişe (başabaşa) çek")
````
