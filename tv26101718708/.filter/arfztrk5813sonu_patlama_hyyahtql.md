# ARFZTRK_5-8-13_SONU PATLAMA

- url: https://www.tradingview.com/script/hYYaHTql/
- type: indicator
- pine_id: PUB;943a3f840be54820bbb18154f1f3c7ef
- version: 1.0

## Description

🇹🇷 TÜRKÇE YAYIN METNİ
Başlık: ARFZTRK 5-8-13 Volatilite Sıkışması ve Hacimli Patlama Motoru

Açıklama:
Bu indikatör, fiyatın hareketli ortalamalar (MA 5, 8, 13) altında baskılanarak enerji topladığı "volatilite daralması" evrelerini ve bu daralmanın ardından gelen "yüksek hacimli kırılımları" (Breakout) tespit etmek için tasarlanmış gelişmiş bir Price Action ve Quant tarama motorudur.

Sistem, fiyatın sadece MAların üzerine atmasına bakmaz; bu patlamanın hacimle desteklenip desteklenmediğini, geride bir kurumsal iz (FVG) bırakıp bırakmadığını ve trendin gücünü detaylı filtrelerle analiz eder.

🔥 Temel Özellikler:

Volatilite Sıkışması: Fiyatın, kırılımdan önce belirlediğiniz gün sayısı kadar tüm hareketli ortalamaların (5, 8, 13) altında ezilmiş olmasını şart koşar. (Yay ne kadar gerilirse, patlama o kadar sert olur).

Hacim Filtresi: Kırılım mumunun, son 20 günlük ortalama hacmin belirlediğiniz çarpan (örn: 1.2x) kadar üzerinde olmasını sağlar. "Boğa Tuzaklarını" (Bull Trap) eler.

SMC & FVG Onayı: İsteğe bağlı olarak, kırılımın bir "Fair Value Gap" (Boşluk) bırakarak gerçekleşmesini arar. Akıllı paranın tahtaya girdiğini doğrular.

Dinamik Stop-Loss Motoru: Sinyal geldiği an, kırılım mumuna göre belirlediğiniz % oranında (örn: %2) otomatik bir Zarar-Kes çizgisi çizer ve bunu ayarladığınız bar süresince ekranda tutar.

Gelişmiş Debug (Hata Ayıklama) Modu: Sinyal gelmediğinde grafiğe renkli noktalar basarak hangi şartın (Mavi: Baskı, Sarı: Kapanış, Mor: Hacim) eksik kaldığını gösteren eşsiz bir teşhis aracıdır.

Kullanım Tavsiyesi:
Günlük (1D) grafiklerde swing trade işlemleri için optimize edilmiştir. Eğer dipten gelen ilk sert dönüşleri yakalamak istiyorsanız ayarlardan "MA Sıralaması (5>8>13)" filtresini kapalı tutun.

🇬🇧 İNGİLİZCE YAYIN METNİ (ENGLISH)
Title: ARFZTRK 5-8-13 Volatility Squeeze & Volume Breakout Engine

Description:
This indicator is an advanced Price Action and Quant screening engine designed to detect "volatility contraction" phases—where price is suppressed below key moving averages (MA 5, 8, 13)—followed by explosive, high-volume breakouts.

The system does not merely look for price crossing above MAs; it uses strict logical filters to verify if the breakout is supported by anomalous volume, if it leaves an institutional footprint (FVG), and if the trend structure is valid.

🔥 Key Features:

Volatility Squeeze Logic: Requires the price to be trapped entirely below all three MAs (5, 8, 13) for a user-defined number of minimum days before the breakout occurs. (The tighter the spring is compressed, the harder it pops).

Relative Volume Filter: Ensures the breakout candle's volume is significantly higher than the 20-period average by a customizable multiplier (e.g., 1.2x), effectively filtering out bull traps.

SMC & FVG Confirmation: Optional Smart Money Concept filter that requires the breakout candle to leave a Fair Value Gap (Gap Up), confirming aggressive institutional buying.

Dynamic Stop-Loss Engine: Upon a valid breakout, it automatically calculates a Stop-Loss line based on your desired risk percentage (e.g., 2%) below the breakout close, keeping it plotted for a specific number of bars.

Advanced Debug Mode: A unique diagnostic tool. If a signal doesn't trigger, turning on Debug Mode plots colored dots under the candles to tell you exactly which condition failed (Blue: Squeeze, Yellow: Close, Purple: Volume).

Usage Tip:
Highly optimized for daily (1D) charts and swing trading strategies. If you want to catch early bottoms and aggressive reversals, keep the "MA Alignment (5>8>13)" filter turned OFF in the settings.

## Source Code

````pine
//@version=6
indicator("ARFZTRK_5-8-13_SONU PATLAMA", overlay=true)

// =========================================================================
// --- GİRDİLER VE ANSİKLOPEDİK TOOLTIP AÇIKLAMALARI ---
// =========================================================================

maTipi = input.string("EMA", title="MA Tipi", options=["SMA", "EMA"], 
     tooltip="Hareketli ortalamaların (MA) hesaplanma mantığıdır. EMA (Üssel), son günlerin fiyatlarına daha fazla ağırlık vererek trend dönüşlerine daha hızlı tepki verir. SMA (Basit) ise periyottaki tüm günleri eşit sayar. Fiyatın anlık patlamalarını ve ani momentumu aradığımız için EMA daha atiktir.")

hacimCarp = input.float(1.2, title="Hacim Çarpanı", step=0.1, 
     tooltip="Kırılım mumunun hacminin, geçmiş ortalama hacme göre ne kadar büyük olması gerektiğini belirler. Örneğin 1.2 değeri, hacmin ortalamadan en az %20 daha fazla olması demektir. Düşük hacimli sahte kırılımları (bull trap) filtrelemek için hayati bir quant filtresidir.")

hacimPer = input.int(20, title="Hacim Ortalama Periyodu", 
     tooltip="Kıyaslanacak ortalama hacmin kaç günlük bir periyottan hesaplanacağını belirler. 20 değeri, yaklaşık tam bir aylık işlem gününü temsil eder. Hacim patlamasının gerçekten istisnai olup olmadığını anlamak için bu referans aralığı kullanılır.")

baskiGun = input.int(2, title="Min Baskı Günü", minval=1, maxval=10, 
     tooltip="Fiyatın MA'ların altında ezildiği ve enerji topladığı (volatilite daralması) minimum gün sayısıdır. Değer 2 ise, fiyat en az 2 gün tüm MA'ların altında kalmış ve bugün sertçe üstüne atmış demektir. Yay ne kadar uzun süre gerilirse, patlama o kadar şiddetli olabilir.")

maSiralamaF = input.bool(false, title="MA Sıralaması Filtresi (5>8>13)", 
     tooltip="Kırılım anında MA'ların kusursuz bir yükseliş trendi dizilimine (5 > 8 > 13) sahip olmasını şart koşar. Düşüş trendindeki 'ölü kedi sıçramalarını' engeller. DİKKAT: Dipten gelen ilk patlamalarda, fiyat MA'ları delip geçse bile ortalamaların bu sıraya girmesi birkaç gün alacağından bu filtre çok kısıtlayıcıdır. Dipten ilk dönüşleri yakalamak istiyorsanız kapalı tutun.")

bogaMumuF = input.bool(true, title="Boğa Mumu Filtresi", 
     tooltip="Kırılım günündeki mumun kapanış fiyatının, açılış fiyatından yüksek olmasını (yeşil/boğa mumu) zorunlu kılar. Fiyat MA'ların üstüne atsa bile, gün içinde satıcıların baskın olduğu kırmızı bir mumla kapanış yapılmışsa bu sinyali iptal ederek sizi satıcı baskısından korur.")

fvgFiltresi = input.bool(false, title="SMC Filtresi: Sadece FVG (Gap) Varsa Sinyal Ver", 
     tooltip="Smart Money Concepts (SMC) tabanlı kurumsal iz filtresidir. Kırılım mumunun en alt seviyesinin, 2 bar önceki mumun en üst seviyesine değmeden arada boşluk (Gap / Fair Value Gap) bırakmasını arar. Bu durum, 'Akıllı Para'nın tahtaya çok agresif girdiğinin ve satıcılara fırsat vermeden fiyatı yukarı sürdüğünün en net kanıtıdır.")

slYuzde = input.float(2.0, title="Stop-Loss Oranı (%)", step=0.1, minval=0.1, 
     tooltip="Kırılım gerçekleştikten sonra sermayeyi korumak için otomatik hesaplanan Zarar Kes (Stop-Loss) marjıdır. Sinyal mumunun kapanış fiyatından, buraya girilen yüzde (örn: %2) kadar aşağısı matematiksel olarak hesaplanır ve grafiğe kırmızı bir savunma hattı olarak çizilir.")

slGosterimBar = input.int(15, title="S/L Çizgisi Gösterim Süresi (Bar)", minval=1, maxval=100, 
     tooltip="Hesaplanan Stop-Loss kırmızı çizgisinin, kırılım geldikten sonra grafikte sağa doğru kaç çubuk (bar) boyunca çizilmeye devam edeceğini belirler. İşlemde kaldığınız süreyi görsel olarak takip etmenizi ve stop seviyenizi unutmamanızı sağlar.")

debugModu = input.bool(false, title="HATA AYIKLAMA (Şartları Ekrana Nokta Olarak Bas)", 
     tooltip="Tarama motoru sessizliğe gömülür ve hiç sinyal üretmezse hayat kurtaran teşhis modudur. Açıldığında, mumların altına/üstüne renkli noktalar koyarak hangi koşulun (Mavi: Baskı, Sarı: Kapanış, Mor: Hacim) sağlandığını gösterir. Böylece sinyalin hangi filtreye takıldığını bulabilirsiniz. Normal kullanımda kapalı olmalıdır.")


// =========================================================================
// --- MOTOR ALTYAPISI VE HESAPLAMALAR ---
// =========================================================================

// --- MA Hesaplamaları ---
ma5  = maTipi == "EMA" ? ta.ema(close, 5)  : ta.sma(close, 5)
ma8  = maTipi == "EMA" ? ta.ema(close, 8)  : ta.sma(close, 8)
ma13 = maTipi == "EMA" ? ta.ema(close, 13) : ta.sma(close, 13)

plot(ma5,  title="MA 5",  color=color.red,    linewidth=1)
plot(ma8,  title="MA 8",  color=color.blue,   linewidth=1)
plot(ma13, title="MA 13", color=color.orange, linewidth=1)

// --- Hacim ---
ortHacim    = ta.sma(volume, hacimPer)
yuksekHacim = volume > (ortHacim * hacimCarp)

// --- Koşullar (Dikey Mimari) ---
durumAltinda = close < ma5 and 
     close < ma8 and 
     close < ma13

// [1] ile dünün sayacı sorgulanır (Kırılım mumu sayacı sıfırlamasın diye)
gecmisBaski = ta.barssince(not durumAltinda)[1] >= baskiGun

ustundeKapanis = close > ma5 and 
     close > ma8 and 
     close > ma13

maSiralama = maSiralamaF ? (ma5 > ma8 and ma8 > ma13) : true
bogaMumu   = bogaMumuF   ? (close > open)             : true

fvgVarMi = low > high[2]
bogaFVG  = fvgFiltresi ? fvgVarMi : true

// --- Nihai Sinyal ---
kirilimSarti = gecmisBaski and 
     ustundeKapanis and 
     yuksekHacim and 
     maSiralama and 
     bogaMumu and 
     bogaFVG


// =========================================================================
// --- GÖRSELLEŞTİRME VE RİSK YÖNETİMİ ---
// =========================================================================

// --- HATA AYIKLAMA (DEBUG) ÇİZİMLERİ (ALT ALTA SIRALI) ---
// Yeşil ok (belowbar) konumunu işgal etmemek için daha derin yüzdeler kullanıldı.

// 1. Baskı Şartı (Mavi Nokta)
plot(debugModu and gecmisBaski ? low * 0.980 : na, title="DBG: Baskı", color=color.blue, style=plot.style_circles, linewidth=3)

// 2. Kapanış Şartı (Sarı Nokta)
plot(debugModu and ustundeKapanis ? low * 0.970 : na, title="DBG: Kapanış", color=color.yellow, style=plot.style_circles, linewidth=3)

// 3. Hacim Şartı (Mor Nokta)
plot(debugModu and yuksekHacim ? low * 0.960 : na, title="DBG: Hacim", color=color.purple, style=plot.style_circles, linewidth=3)

// 1. Yeşil Ok (Mumun Altında)
plotshape(kirilimSarti, title="Kırılım Oku", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.normal)

// --- Dinamik Stop-Loss Hesaplaması ---
var float slSeviyesi = na
var int sonSinyalBari = na

if kirilimSarti
    slSeviyesi    := close * (1 - (slYuzde / 100))
    sonSinyalBari := bar_index

gosterimSarti  = not na(sonSinyalBari) and (bar_index - sonSinyalBari <= slGosterimBar)
gosterilecekSL = gosterimSarti ? slSeviyesi : na

// 2. Stop Çizgisi
plot(gosterilecekSL, title="Stop-Loss Çizgisi", color=color.red, style=plot.style_linebr, linewidth=2)

// 3. Bilgi Etiketi (Mumun Üstünde)
if kirilimSarti
    baslikMetni = fvgVarMi ? "🚀 FVG + PATLAMA\n" : "🚀 PATLAMA\n"
    etiketMetni = baslikMetni + str.tostring(math.round(volume / ortHacim, 1)) + "x Hacim\nSL: " + str.tostring(slSeviyesi, "#.##")
    
    label.new(
         x         = bar_index,
         y         = na,
         yloc      = yloc.abovebar,
         text      = etiketMetni,
         style     = label.style_label_down,
         color     = color.green,
         textcolor = color.white,
         size      = size.small)

// Tarama Motoru Alarmları İçin Webhook/Alert Bağlantısı
alertcondition(kirilimSarti, title="MA Sıkışma Kırılımı!", message="{{ticker}} MA 5-8-13 hacimli kırılım gerçekleştirdi.")
````
