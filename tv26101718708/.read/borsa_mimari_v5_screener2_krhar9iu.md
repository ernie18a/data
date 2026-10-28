# Borsa Mimari v5 Screener2

- url: https://www.tradingview.com/script/kRHAR9IU/
- type: indicator
- pine_id: PUB;68c615656b66457bb10861f8c8156130
- version: 2.0

## Description

Çeşitli indikatörler ile Al sinyalleri verir. Trend çizgileri çizer. Hedef fiyatlar belirler. Hisse için tüm indikatörlere göre skor verir.

## Source Code

````pine
//@version=6
indicator("Borsa Mimarı v5 - Tam Sistem", overlay=true, max_labels_count=500, max_lines_count=300, max_bars_back=500)

// ═══════════════════════════════════════════════════════════
// BÖLÜM 1: GİRDİLER
// ═══════════════════════════════════════════════════════════

// SuperTrend
st_periyot  = input.int(10,    "SuperTrend Periyot",    group="SuperTrend")
st_carpan   = input.float(3.0, "SuperTrend Çarpan",     group="SuperTrend")

// EMA
ema89_len   = input.int(89,    "EMA Kısa",              group="EMA")
ema144_len  = input.int(144,   "EMA Uzun",              group="EMA")

// Trade Zone (Mavi Bulut - ASTOR)
tz_len      = input.int(20,    "Trade Zone Uzunluğu",   group="Trade Zone (Mavi Bulut)")
tz_carpan   = input.float(2.0, "Trade Zone Çarpan",     group="Trade Zone (Mavi Bulut)")
tz_goster   = input.bool(true, "Trade Zone Göster",     group="Trade Zone (Mavi Bulut)")

// Otomatik S/R Seviyeleri (OBAMS)
sr_len      = input.int(10,    "Pivot Uzunluğu",        group="Otomatik S/R Seviyeleri")
sr_goster   = input.bool(true, "S/R Seviyeleri Göster", group="Otomatik S/R Seviyeleri")

// Heikin-Ashi Overlay (SEYKM)
ha_goster   = input.bool(true, "HA Overlay Göster",     group="Heikin-Ashi Overlay")

// Temel Göstergeler
macd_fast   = input.int(12,    "MACD Hızlı",            group="Göstergeler")
macd_slow   = input.int(26,    "MACD Yavaş",            group="Göstergeler")
macd_sig_l  = input.int(9,     "MACD Sinyal",           group="Göstergeler")
rsi_len     = input.int(14,    "RSI Periyot",           group="Göstergeler")
adx_len     = input.int(14,    "ADX Periyot",           group="Göstergeler")
hacim_len   = input.int(20,    "Hacim Ortalama",        group="Göstergeler")
fib_len     = input.int(50,    "Fibonacci Periyot",     group="Göstergeler")

// Bölge ATR Çarpanları
dip_carpan  = input.float(2.0, "Dip Bölge ATR",        group="Bölgeler")
tepe_carpan = input.float(2.0, "Tepe Bölge ATR",       group="Bölgeler")

// Hedef ATR Çarpanları
h1_carpan   = input.float(2.0, "Hedef-1 ATR",          group="Hedefler")
h2_carpan   = input.float(4.0, "Hedef-2 ATR",          group="Hedefler")
h3_carpan   = input.float(6.0, "Hedef-3 ATR",          group="Hedefler")

// Panel konumu
panel_yer   = input.string("Sağ Üst", "Panel Konumu", options=["Sağ Üst","Sağ Alt","Sol Üst","Sol Alt"], group="Panel")

// ═══════════════════════════════════════════════════════════
// BÖLÜM 2: TEMEL HESAPLAMALAR
// ═══════════════════════════════════════════════════════════

atr = ta.atr(14)

// EMA
ema89  = ta.ema(close, ema89_len)
ema144 = ta.ema(close, ema144_len)

// MACD
[macd_l, macd_s, macd_hist] = ta.macd(close, macd_fast, macd_slow, macd_sig_l)
macd_al    = macd_l > macd_s
macd_durum = macd_al ? "AL" : "SAT"

// RSI
rsi         = ta.rsi(close, rsi_len)
rsi_bull    = rsi > 50
rsi_aasiri_al  = rsi > 70
rsi_asiri_sat  = rsi < 30
rsi_durum   = rsi_aasiri_al ? "ASIRI ALIM" : rsi_asiri_sat ? "ASIRI SATIM" : rsi_bull ? "BULL" : "BEAR"

// ADX + DMI
[dip_dmi, dim_dmi, adx_val] = ta.dmi(adx_len, adx_len)
adx_guclu  = adx_val > 20
adx_yukari = dip_dmi > dim_dmi
adx_durum  = adx_guclu and adx_yukari ? "BUY" : adx_guclu and not adx_yukari ? "SELL" : "NÖTR"

// SuperTrend
[st_val, st_dir] = ta.supertrend(st_carpan, st_periyot)
st_yukari  = st_dir < 0
st_clr     = st_yukari ? color.new(color.green, 0) : color.new(color.red, 0)

// Hacim
hacim_ort    = ta.sma(volume, hacim_len)
hacim_yuksek = volume > hacim_ort * 1.1
hacim_durum  = hacim_yuksek ? "YÜKSEK" : "NORMAL"

// EMA durumları
ema89_ust   = close > ema89
ema144_ust  = close > ema144
ema89_d     = ema89_ust ? "ÜSTÜNDE" : "ALTINDA"
ema144_d    = ema144_ust ? "ÜSTÜNDE" : "ALTINDA"

// Fibonacci
fib_high  = ta.highest(high, fib_len)
fib_low   = ta.lowest(low, fib_len)
fib_range = fib_high - fib_low
fib_236   = fib_high - fib_range * 0.236
fib_382   = fib_high - fib_range * 0.382
fib_500   = fib_high - fib_range * 0.500
fib_618   = fib_high - fib_range * 0.618
fib_786   = fib_high - fib_range * 0.786

f236 = math.abs(close - fib_236)
f382 = math.abs(close - fib_382)
f500 = math.abs(close - fib_500)
f618 = math.abs(close - fib_618)
f786 = math.abs(close - fib_786)
min_fib   = math.min(f236, math.min(f382, math.min(f500, math.min(f618, f786))))
fib_yakin = min_fib == f236 ? fib_236 : min_fib == f382 ? fib_382 : min_fib == f500 ? fib_500 : min_fib == f618 ? fib_618 : fib_786
fib_adi   = min_fib == f236 ? "0.236" : min_fib == f382 ? "0.382" : min_fib == f500 ? "0.500" : min_fib == f618 ? "0.618" : "0.786"
fib_des   = close >= fib_yakin and close < fib_yakin + atr
fib_dir   = close <= fib_yakin and close > fib_yakin - atr
fib_durum = fib_des ? "DESTEK" : fib_dir ? "DİRENÇ" : close > fib_yakin ? "ÜSTÜNDE" : "ALTINDA"

// ═══════════════════════════════════════════════════════════
// BÖLÜM 3: SKOR SİSTEMİ (7 Kriter)
// ═══════════════════════════════════════════════════════════

skor = 0
skor := skor + (macd_al ? 1 : -1)
skor := skor + (rsi_bull and not rsi_aasiri_al ? 1 : -1)
skor := skor + (adx_guclu and adx_yukari ? 1 : -1)
skor := skor + (ema89_ust ? 1 : -1)
skor := skor + (ema144_ust ? 1 : -1)
skor := skor + (st_yukari ? 1 : -1)
skor := skor + (hacim_yuksek ? 1 : -1)

genel  = skor >= 6 ? "GÜÇLÜ AL (7/7)" : skor >= 4 ? "GÜÇLÜ AL (" + str.tostring(skor) + "/7)" : skor >= 2 ? "AL (" + str.tostring(skor) + "/7)" : skor >= 0 ? "NÖTR (" + str.tostring(skor) + "/7)" : "SAT (" + str.tostring(skor) + "/7)"
gt_clr = skor >= 4 ? color.new(color.green, 0) : skor >= 2 ? color.new(color.lime, 0) : skor >= 0 ? color.new(color.gray, 0) : color.new(color.red, 0)

// ═══════════════════════════════════════════════════════════
// BÖLÜM 4: ATR BAZLI DESTEK/DİRENÇ BANTLARI
// ═══════════════════════════════════════════════════════════

dip_ust        = ema144 - atr * (dip_carpan - 0.5)
dip_alt        = ema144 - atr * (dip_carpan + 0.5)
derin_dip_ust  = ema144 - atr * (dip_carpan + 0.5)
derin_dip_alt  = ema144 - atr * (dip_carpan + 1.5)
tepe_alt       = ema89  + atr * (tepe_carpan - 0.5)
tepe_ust       = ema89  + atr * (tepe_carpan + 0.5)
asiri_alt2     = ema89  + atr * (tepe_carpan + 0.5)
asiri_ust2     = ema89  + atr * (tepe_carpan + 1.5)

dip_bolge      = close <= dip_ust and close >= dip_alt
derin_bolge    = close <= derin_dip_ust and close >= derin_dip_alt
tepe_bolge     = close >= tepe_alt and close <= tepe_ust
asiri_bolge    = close >= asiri_alt2 and close <= asiri_ust2

bolge_adi = derin_bolge ? "DERİN DİP" : dip_bolge ? "AKÜMÜLASYON" : tepe_bolge ? "DAĞITIM" : asiri_bolge ? "AŞIRI ALIM" : "NÖTR"
bolge_clr = derin_bolge ? color.new(color.green, 30) : dip_bolge ? color.new(color.teal, 50) : tepe_bolge ? color.new(color.red, 50) : asiri_bolge ? color.new(color.maroon, 30) : color.new(color.gray, 80)

bgcolor(derin_bolge ? color.new(color.green, 88) : dip_bolge ? color.new(color.yellow, 88) : tepe_bolge ? color.new(color.fuchsia, 88) : asiri_bolge ? color.new(color.maroon, 82) : na)

p_dip_ust = plot(dip_ust, color=color.new(color.teal, 75), linewidth=1, title="Dip Üst")
p_dip_alt = plot(dip_alt, color=color.new(color.teal, 75), linewidth=1, title="Dip Alt")
p_derin_ust = plot(derin_dip_ust, color=color.new(color.green, 65), linewidth=1, title="Derin Üst")
p_derin_alt = plot(derin_dip_alt, color=color.new(color.green, 65), linewidth=1, title="Derin Alt")
fill(p_dip_ust, p_dip_alt, color=color.new(color.teal, 88), title="Akümülasyon Bölge")
fill(p_derin_ust, p_derin_alt, color=color.new(color.green, 85), title="Derin Dip Bölge")

// ═══════════════════════════════════════════════════════════
// BÖLÜM 5: EMA + SUPERTREND ÇİZGİLERİ
// ═══════════════════════════════════════════════════════════

plot(ema89,  color=color.new(color.orange, 35), linewidth=2, title="EMA89")
plot(ema144, color=color.new(color.blue, 35),   linewidth=2, title="EMA144")
plot(st_val, color=st_clr, linewidth=2, title="SuperTrend")

// ═══════════════════════════════════════════════════════════
// BÖLÜM 6: TRADE ZONE - MAVİ BULUT (ASTOR FOTOGRAFI)
// ═══════════════════════════════════════════════════════════
// Bollinger Band tabanlı alım-satım bölgesi.
// Bulut daraldığında = Squeeze = patlama yakın.
// Fiyat altından içe girince = AL sinyali.

tz_basis = ta.sma(close, tz_len)
tz_std   = ta.stdev(close, tz_len)
tz_ust   = tz_basis + tz_carpan * tz_std
tz_alt   = tz_basis - tz_carpan * tz_std
tz_bw    = (tz_ust - tz_alt) / tz_basis * 100
tz_squeeze = tz_bw < ta.lowest(tz_bw, 50) * 1.15

tz_icinde  = close >= tz_alt and close <= tz_ust
tz_altinda = close < tz_alt
tz_ustunde = close > tz_ust

tz_dolgu = tz_squeeze ? color.new(color.purple, 72) : color.new(color.blue, 82)

ptz1 = plot(tz_goster ? tz_ust : na, color=color.new(color.blue, 55), linewidth=1, title="TZ Üst")
ptz2 = plot(tz_goster ? tz_alt : na, color=color.new(color.blue, 55), linewidth=1, title="TZ Alt")
fill(ptz1, ptz2, color=tz_dolgu, title="Trade Zone Mavi Bulut")

// Trade Zone giriş AL sinyali
tz_giris = tz_goster and tz_altinda[1] and tz_icinde
plotshape(tz_giris, title="TZ Giriş", style=shape.triangleup, location=location.belowbar, color=color.new(color.blue, 10), size=size.tiny, text="TZ↑", textcolor=color.white)

// Squeeze zemin uyarısı (mor)
bgcolor(tz_squeeze ? color.new(color.purple, 94) : na, title="TZ Squeeze")

// ═══════════════════════════════════════════════════════════
// BÖLÜM 7: OTOMATİK YATAY DESTEK/DİRENÇ (OBAMS FOTOGRAFI)
// ═══════════════════════════════════════════════════════════
// Pivot High = Direnç, Pivot Low = Destek.
// Renk = mesafeye göre: kırmızı (yakın), turuncu (orta), gri (uzak).
// En alt destek = Mavi yatay çizgi (OBAMS'taki mavi çizgi).

ph_p = ta.pivothigh(high, sr_len, sr_len)
pl_p = ta.pivotlow(low,  sr_len, sr_len)

var float r1 = na
var float r2 = na
var float r3 = na
var float s1 = na
var float s2 = na
var float s3 = na
var float s4 = na
var float mutlak_dip = na

if not na(ph_p)
    r3 := r2
    r2 := r1
    r1 := ph_p

if not na(pl_p)
    s4 := s3
    s3 := s2
    s2 := s1
    s1 := pl_p
    if na(mutlak_dip) or pl_p < mutlak_dip
        mutlak_dip := pl_p

// Dirençler (kırmızı tonu → turuncu → gri)
plot(sr_goster ? r1 : na, color=color.new(color.red, 40),    linewidth=1, style=plot.style_line, title="Direnç-1 (Yakın)")
plot(sr_goster ? r2 : na, color=color.new(color.orange, 45), linewidth=1, style=plot.style_line, title="Direnç-2")
plot(sr_goster ? r3 : na, color=color.new(color.gray, 55),   linewidth=1, style=plot.style_line, title="Direnç-3 (Uzak)")

// Destekler (teal → yeşil → açık yeşil)
plot(sr_goster ? s1 : na, color=color.new(color.teal, 35),   linewidth=1, style=plot.style_line, title="Destek-1 (Yakın)")
plot(sr_goster ? s2 : na, color=color.new(color.green, 40),  linewidth=1, style=plot.style_line, title="Destek-2")
plot(sr_goster ? s3 : na, color=color.new(color.lime, 55),   linewidth=1, style=plot.style_line, title="Destek-3 (Uzak)")

// Mutlak dip = Mavi yatay çizgi (OBAMS'taki mavi çizgi = en alt dip)
plot(sr_goster ? mutlak_dip : na, color=color.new(color.blue, 15), linewidth=2, style=plot.style_line, title="Mutlak Dip (Mavi)")

// ═══════════════════════════════════════════════════════════
// BÖLÜM 8: DİYAGONAL TREND ÇİZGİLERİ (OBAMS/ASTOR)
// ═══════════════════════════════════════════════════════════
// Düşen tepeler = Kırmızı kesik çizgi (düşen trend direnci)
// Yükselen dipler = Yeşil kesik çizgi (yükselen trend desteği)
// "Düşeni kıran" sinyal = Fiyat kırmızı çizgiyi yukarı geçince

var line ln_direnc = na
var line ln_destek = na

var float ph1v = na
var int   ph1b = na
var float ph2v = na
var int   ph2b = na

var float pl1v = na
var int   pl1b = na
var float pl2v = na
var int   pl2b = na

if not na(ph_p)
    ph2v := ph1v
    ph2b := ph1b
    ph1v := ph_p
    ph1b := bar_index - sr_len
    if not na(ph2v) and ph2v > ph1v
        line.delete(ln_direnc)
        egim_d = (ph1v - ph2v) / (ph1b - ph2b)
        hedef_d = ph1v + egim_d * 30
        ln_direnc := line.new(ph2b, ph2v, ph1b + 30, hedef_d, color=color.new(color.red, 25), width=2, style=line.style_dashed, extend=extend.right)

if not na(pl_p)
    pl2v := pl1v
    pl2b := pl1b
    pl1v := pl_p
    pl1b := bar_index - sr_len
    if not na(pl2v) and pl2v < pl1v
        line.delete(ln_destek)
        egim_s = (pl1v - pl2v) / (pl1b - pl2b)
        hedef_s = pl1v + egim_s * 30
        ln_destek := line.new(pl2b, pl2v, pl1b + 30, hedef_s, color=color.new(color.green, 25), width=2, style=line.style_dashed, extend=extend.right)

// Düşen trendi kıran sinyal (OBAMS'taki "düşeni kıran")
trend_kirildi = not na(ln_direnc) and close > line.get_price(ln_direnc, bar_index) and close[1] <= line.get_price(ln_direnc, bar_index - 1)
plotshape(trend_kirildi, title="Düşen Trend Kırıldı", style=shape.labelup, location=location.belowbar, color=color.new(color.yellow, 0), text="KIRILDI!", textcolor=color.black, size=size.small)

// ═══════════════════════════════════════════════════════════
// BÖLÜM 9: HEİKİN-ASHİ OVERLAY + ERKEN SİNYAL (SEYKM)
// ═══════════════════════════════════════════════════════════
// SEYKM'deki soluk yeşil/kırmızı şeffaf mum yapıları = HA overlay.
//
// ERKEN SİNYAL MANTIĞI:
//   Bir sonraki barın HA_open'ı matematiksel olarak bellidir:
//   sonraki_ha_open = (ha_open_simdi + ha_close_simdi) / 2
//   Eğer bugünkü HA_close > sonraki_ha_open  →  HA yarın yeşile dönecek
//   Bu sayede yükseliş 1 bar ÖNCE sinyalleniyor.
//   Aynı mantık tersine uygulanarak düşüş de 1 bar önce sinyalleniyor.

ha_kapat = (open + high + low + close) / 4
var float ha_ac = na
ha_ac := na(ha_ac[1]) ? (open + close) / 2 : (ha_ac[1] + ha_kapat[1]) / 2
ha_yuksek = math.max(high, math.max(ha_ac, ha_kapat))
ha_dusuk  = math.min(low,  math.min(ha_ac, ha_kapat))
ha_yukari = ha_kapat > ha_ac

// ─── ERKEN SİNYAL HESABI ───────────────────────────────────
// Bir sonraki barın tahmini HA_open değeri (kesin formül)
ha_ac_sonraki = (ha_ac + ha_kapat) / 2

// ERKEN AL: HA henüz kırmızı ama yarın yeşile dönecek
//   Koşul: HA_close > sonraki_HA_open  AND  HA hala kırmızı
erken_al  = not ha_yukari and ha_kapat > ha_ac_sonraki

// ERKEN SAT: HA henüz yeşil ama yarın kırmızıya dönecek
//   Koşul: HA_close < sonraki_HA_open  AND  HA hala yeşil
erken_sat = ha_yukari and ha_kapat < ha_ac_sonraki

// Gerçek dönüş (mevcut bar - 1 bar gecikme ile)
ha_donus_al  = ha_yukari and not ha_yukari[1]
ha_donus_sat = not ha_yukari and ha_yukari[1]

// Güçlü sinyal: fitil yok = güçlü momentum
ha_guclu_al  = ha_yukari and ha_dusuk  == ha_ac
ha_guclu_sat = not ha_yukari and ha_yuksek == ha_ac

// ─── HA OVERLAY MUMLAR (soluk renkler - SEYKM stili) ───────
ha_gov_renk = ha_yukari ? color.new(color.green, 60) : color.new(color.red, 60)
ha_fit_renk = ha_yukari ? color.new(color.green, 45) : color.new(color.red, 45)

plotcandle(ha_goster ? ha_ac : na, ha_goster ? ha_yuksek : na, ha_goster ? ha_dusuk : na, ha_goster ? ha_kapat : na, title="HA Overlay", color=ha_gov_renk, wickcolor=ha_fit_renk, bordercolor=ha_gov_renk)

// ─── ERKEN SİNYAL ŞEKİLLERİ (1 BAR ÖNCE) ──────────────────
// Sarı yıldız ↑ = "Yarın yeşile dönecek" - hareket başlamadan önce
plotshape(ha_goster and erken_al  and not erken_al[1],  title="HA Erken AL",  style=shape.diamond, location=location.belowbar, color=color.new(color.yellow, 0),  size=size.small, text="⚡AL",  textcolor=color.new(color.yellow, 0))
// Sarı yıldız ↓ = "Yarın kırmızıya dönecek" - düşüş başlamadan önce
plotshape(ha_goster and erken_sat and not erken_sat[1], title="HA Erken SAT", style=shape.diamond, location=location.abovebar, color=color.new(color.orange, 0), size=size.small, text="⚡SAT", textcolor=color.new(color.orange, 0))

// ─── DOĞRULAMA SİNYALLERİ (dönüş gerçekleşince küçük daire) ─
plotshape(ha_goster and ha_donus_al,  title="HA Dönüş AL",  style=shape.circle, location=location.belowbar, color=color.new(color.lime, 15),   size=size.tiny)
plotshape(ha_goster and ha_donus_sat, title="HA Dönüş SAT", style=shape.circle, location=location.abovebar, color=color.new(color.maroon, 15), size=size.tiny)

// ─── DASHBOARD İÇİN DEĞİŞKENLER ────────────────────────────
ha_adi = erken_al  ? "ERKEN AL ⚡" : erken_sat ? "ERKEN SAT ⚡" : ha_guclu_al ? "GÜÇLÜ AL" : ha_yukari ? "YUKARI" : ha_guclu_sat ? "GÜÇLÜ SAT" : "ASAGI"
ha_clr = erken_al  ? color.new(color.yellow, 20) : erken_sat ? color.new(color.orange, 20) : ha_guclu_al ? color.new(color.lime, 20) : ha_yukari ? color.new(color.green, 40) : ha_guclu_sat ? color.new(color.maroon, 20) : color.new(color.red, 40)

// ═══════════════════════════════════════════════════════════
// BÖLÜM 10: SİNYAL KOŞULLARI
// ═══════════════════════════════════════════════════════════

dip_kosul  = close < dip_ust
tepe_kosul = close > tepe_alt

dip_sinyal  = st_yukari and dip_kosul and macd_al and rsi_bull and not rsi_aasiri_al and skor >= 1
dip_guclu   = st_yukari and dip_kosul and macd_al and rsi_bull and hacim_yuksek and skor >= 3
tepe_sinyal = not st_yukari and tepe_kosul and not macd_al and not rsi_aasiri_al and skor <= -1
tepe_guclu  = not st_yukari and tepe_kosul and not macd_al and not rsi_bull and hacim_yuksek and skor <= -3
al_sinyal   = st_yukari and macd_al and rsi_bull and not rsi_aasiri_al and adx_guclu and adx_yukari and ema89_ust and ema144_ust and skor >= 6
sat_sinyal  = not st_yukari and not macd_al and not rsi_bull and adx_guclu and not adx_yukari and not ema89_ust and not ema144_ust and skor <= -4

// ═══════════════════════════════════════════════════════════
// BÖLÜM 11: HEDEF SİSTEMİ
// ═══════════════════════════════════════════════════════════

var float stop_sev = na
var float h1 = na
var float h2 = na
var float h3 = na
var bool  h1v = false
var bool  h2v = false
var bool  h3v = false

// ─── YENİ DİP GELİNCE: KOŞULSUZ SIFIRLA ─────────────────────
// Önceki hedefler vurulmuş olsun ya da olmasın,
// herhangi yeni bir dip sinyalinde tüm hedefler silinir ve
// yeni dip noktasından yeniden hesaplanır.
yeni_dip = (dip_sinyal and not dip_sinyal[1]) or (dip_guclu and not dip_guclu[1])
dip_baz  = ta.lowest(low, 5)

if yeni_dip
    stop_sev := st_val
    h1  := dip_baz + atr * h1_carpan
    h2  := dip_baz + atr * h2_carpan
    h3  := dip_baz + atr * h3_carpan
    h1v := false
    h2v := false
    h3v := false

// AL sinyali gelince ve hedefler yoksa veya eskiyse → mevcut fiyattan hesapla
if al_sinyal and not al_sinyal[1] and (na(h1) or h1v)
    h1  := close + atr * h1_carpan
    h2  := close + atr * h2_carpan
    h3  := close + atr * h3_carpan
    h1v := false
    h2v := false
    h3v := false

// ─── FİYAT HEDEFİ GEÇTİ Mİ? ─────────────────────────────────
// Fiyat bir hedefi geçtiyse o hedefi gizle (çizgi ve etiket yok)
if not na(h1) and not h1v and high >= h1
    h1v := true
if not na(h2) and not h2v and high >= h2
    h2v := true
if not na(h3) and not h3v and high >= h3
    h3v := true

// Tüm hedefler vurulduysa tamamen sıfırla
if h1v and h2v and h3v
    h1  := na
    h2  := na
    h3  := na
    h1v := false
    h2v := false
    h3v := false

// ─── STOP SIFIRLAMA KURALLARI ────────────────────────────────
// Kural 1: Fiyat stop'un altına düştü → pozisyon kapandı, stop sıfırla
if not na(stop_sev) and close < stop_sev
    stop_sev := na
// Kural 2: Yeni AL sinyali → stop'u mevcut ST'ye güncelle
if al_sinyal and not al_sinyal[1]
    stop_sev := st_val
// Kural 3: Trailing stop — sadece yukarı hareket
if not na(stop_sev) and st_yukari
    stop_sev := math.max(stop_sev, st_val)

// ─── HEDEF ÇİZGİLERİ ─────────────────────────────────────────
// Sadece geçilmemiş hedefler gösterilir (h1v=false → göster)
// Fiyat hedefi geçtiyse (h1v=true) o çizgi kaybolur
plot(not na(h1) and not h1v ? h1 : na, "Hedef-1", color=color.new(color.orange, 25), linewidth=1, style=plot.style_linebr)
plot(not na(h2) and not h2v ? h2 : na, "Hedef-2", color=color.new(color.green, 25),  linewidth=1, style=plot.style_linebr)
plot(not na(h3) and not h3v ? h3 : na, "Hedef-3", color=color.new(color.teal, 15),   linewidth=2, style=plot.style_linebr)
plot(not na(stop_sev) ? stop_sev : na,  "Stop",    color=color.new(color.red, 25),    linewidth=1, style=plot.style_linebr)

// ═══════════════════════════════════════════════════════════
// BÖLÜM 12: ETİKETLER
// ═══════════════════════════════════════════════════════════

var label lbl_dip   = na
var label lbl_dipg  = na
var label lbl_tepe  = na
var label lbl_tepeg = na
var label lbl_al    = na
var label lbl_sat   = na
var label lbl_h1    = na
var label lbl_h2    = na
var label lbl_h3    = na
var label lbl_stop  = na

// Sinyal etiketleri
if dip_sinyal and not dip_guclu
    label.delete(lbl_dip)
    lbl_dip := label.new(bar_index, low - atr * 0.5, "Dip", color=color.new(color.green, 20), textcolor=color.white, style=label.style_label_up, size=size.small)

if dip_guclu
    label.delete(lbl_dipg)
    lbl_dipg := label.new(bar_index, low - atr * 0.8, "G.Dip 🔥", color=color.new(color.lime, 0), textcolor=color.black, style=label.style_label_up, size=size.normal)

if tepe_sinyal and not tepe_guclu
    label.delete(lbl_tepe)
    lbl_tepe := label.new(bar_index, high + atr * 0.5, "Tepe", color=color.new(color.red, 20), textcolor=color.white, style=label.style_label_down, size=size.small)

if tepe_guclu
    label.delete(lbl_tepeg)
    lbl_tepeg := label.new(bar_index, high + atr * 0.8, "G.Tepe 🔴", color=color.new(color.maroon, 0), textcolor=color.white, style=label.style_label_down, size=size.normal)

// AL / SAT okları (küçük, üst üste gelmez)
plotshape(al_sinyal  and not al_sinyal[1],  title="AL",  style=shape.triangleup,   location=location.belowbar, color=color.new(color.green, 0), size=size.small, text="AL")
plotshape(sat_sinyal and not sat_sinyal[1], title="SAT", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0),   size=size.small, text="SAT")

// ST dönüş okları
plotshape(st_yukari and not st_yukari[1],   title="ST AL Dönüş",  style=shape.triangleup,   location=location.belowbar, color=color.new(color.green, 40), size=size.tiny)
plotshape(not st_yukari and st_yukari[1],   title="ST SAT Dönüş", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 40),   size=size.tiny)

// Sağda sabit hedef ve stop etiketleri — her zaman güncellenir
if barstate.islast
    label.delete(lbl_h1)
    label.delete(lbl_h2)
    label.delete(lbl_h3)
    label.delete(lbl_stop)
    if not na(h1) and not h1v
        lbl_h1 := label.new(bar_index + 2, h1, "H1 " + str.tostring(h1, "#.##"), color=color.new(color.orange, 20), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if not na(h2) and not h2v
        lbl_h2 := label.new(bar_index + 2, h2, "H2 " + str.tostring(h2, "#.##"), color=color.new(color.green, 20),  textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if not na(h3) and not h3v
        lbl_h3 := label.new(bar_index + 2, h3, "H3 " + str.tostring(h3, "#.##"), color=color.new(color.teal, 15),   textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if not na(stop_sev)
        lbl_stop := label.new(bar_index + 2, stop_sev, "STP " + str.tostring(stop_sev, "#.##"), color=color.new(color.red, 20), textcolor=color.white, style=label.style_label_left, size=size.tiny)

// Hedef vuruldu etiketleri
if h1v and not h1v[1]
    label.new(bar_index, h1, "H-1 Kar Al", color=color.new(color.orange, 0), textcolor=color.white, style=label.style_label_down, size=size.small)
if h2v and not h2v[1]
    label.new(bar_index, h2, "H-2 Kar Al", color=color.new(color.green, 0), textcolor=color.white, style=label.style_label_down, size=size.small)
if h3v and not h3v[1]
    label.new(bar_index, h3, "H-3 TAM KAR 🏆", color=color.new(color.teal, 0), textcolor=color.white, style=label.style_label_down, size=size.normal)

// ═══════════════════════════════════════════════════════════
// BÖLÜM 13: DASHBOARD PANEL
// ═══════════════════════════════════════════════════════════

pan_pos = panel_yer == "Sağ Üst" ? position.top_right : panel_yer == "Sağ Alt" ? position.bottom_right : panel_yer == "Sol Üst" ? position.top_left : position.bottom_left

var table pan = table.new(pan_pos, 3, 21, bgcolor=color.new(color.black, 68), border_color=color.new(color.gray, 50), border_width=1, frame_color=color.new(color.gray, 30), frame_width=1)

if barstate.islast
    // Başlık
    table.cell(pan, 0, 0, "MİMAR DEĞERLERİ", text_color=color.white, bgcolor=color.new(color.navy, 20), text_size=size.small)
    table.cell(pan, 1, 0, "DURUM",               text_color=color.white, bgcolor=color.new(color.navy, 20), text_size=size.small)
    table.cell(pan, 2, 0, "DEĞER",               text_color=color.white, bgcolor=color.new(color.navy, 20), text_size=size.small)

    // 1. MACD
    table.cell(pan, 0, 1, "MACD",       text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 1, macd_durum,   text_color=color.white, bgcolor=macd_al ? color.new(color.green,20) : color.new(color.red,20), text_size=size.small)
    table.cell(pan, 2, 1, str.tostring(macd_l, "#.##"), text_color=color.white, text_size=size.small)

    // 2. RSI
    table.cell(pan, 0, 2, "RSI",        text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 2, rsi_durum,    text_color=color.white, bgcolor=rsi_aasiri_al ? color.new(color.orange,20) : rsi_bull ? color.new(color.green,20) : color.new(color.red,20), text_size=size.small)
    table.cell(pan, 2, 2, str.tostring(rsi, "#.##"), text_color=color.white, text_size=size.small)

    // 3. ADX
    table.cell(pan, 0, 3, "ADX",        text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 3, adx_durum,    text_color=color.white, bgcolor=adx_guclu and adx_yukari ? color.new(color.green,20) : adx_guclu ? color.new(color.red,20) : color.new(color.gray,30), text_size=size.small)
    table.cell(pan, 2, 3, str.tostring(adx_val, "#.##"), text_color=color.white, text_size=size.small)

    // 4. EMA89
    table.cell(pan, 0, 4, "EMA89",      text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 4, ema89_d,      text_color=color.white, bgcolor=ema89_ust ? color.new(color.green,20) : color.new(color.red,20), text_size=size.small)
    table.cell(pan, 2, 4, str.tostring(ema89, "#.##"), text_color=color.white, text_size=size.small)

    // 5. EMA144
    table.cell(pan, 0, 5, "EMA144",     text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 5, ema144_d,     text_color=color.white, bgcolor=ema144_ust ? color.new(color.green,20) : color.new(color.red,20), text_size=size.small)
    table.cell(pan, 2, 5, str.tostring(ema144, "#.##"), text_color=color.white, text_size=size.small)

    // 6. SuperTrend
    table.cell(pan, 0, 6, "SuperTrend", text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 6, st_yukari ? "▲ AL" : "▼ AŞAĞI", text_color=color.white, bgcolor=st_yukari ? color.new(color.green,20) : color.new(color.red,20), text_size=size.small)
    table.cell(pan, 2, 6, str.tostring(st_val, "#.##"), text_color=color.white, text_size=size.small)

    // 7. Hacim
    table.cell(pan, 0, 7, "HACİM",      text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 7, hacim_durum,  text_color=color.white, bgcolor=hacim_yuksek ? color.new(color.green,20) : color.new(color.gray,40), text_size=size.small)
    table.cell(pan, 2, 7, str.tostring(volume, "#"), text_color=color.white, text_size=size.small)

    // 8. Fibonacci
    table.cell(pan, 0, 8, "FİBO " + fib_adi, text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 8, fib_durum,    text_color=color.white, bgcolor=fib_des ? color.new(color.green,20) : fib_dir ? color.new(color.red,20) : color.new(color.gray,40), text_size=size.small)
    table.cell(pan, 2, 8, str.tostring(fib_yakin, "#.##"), text_color=color.white, text_size=size.small)

    // 9. Trade Zone (YENİ)
    tz_adi = tz_squeeze ? "SQUEEZE!" : tz_icinde ? "İÇİNDE" : tz_altinda ? "ALTINDA" : "ÜSTÜNDE"
    tz_clr_d = tz_squeeze ? color.new(color.purple,20) : tz_icinde ? color.new(color.blue,30) : tz_altinda ? color.new(color.orange,20) : color.new(color.gray,40)
    table.cell(pan, 0, 9, "TRADE ZONE", text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 9, tz_adi,       text_color=color.white, bgcolor=tz_clr_d, text_size=size.small)
    table.cell(pan, 2, 9, str.tostring(tz_bw, "#.#") + "%", text_color=color.white, text_size=size.small)

    // 10. HA Sinyal (YENİ)
    table.cell(pan, 0, 10, "HA SİNYAL", text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 10, ha_adi,      text_color=color.white, bgcolor=ha_clr,   text_size=size.small)
    table.cell(pan, 2, 10, ha_yukari ? "🟢" : "🔴", text_color=color.white, text_size=size.small)

    // 11. Bölge
    table.cell(pan, 0, 11, "BÖLGE",     text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 11, bolge_adi,   text_color=color.white, bgcolor=bolge_clr, text_size=size.small)
    table.cell(pan, 2, 11, "",          text_color=color.white, text_size=size.small)

    // 12. Stop
    stop_str2 = not na(stop_sev) ? str.tostring(stop_sev, "#.##") : "—"
    table.cell(pan, 0, 12, "STOP",      text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 12, stop_str2,   text_color=color.white, bgcolor=color.new(color.red,25), text_size=size.small)
    table.cell(pan, 2, 12, "",          text_color=color.white, text_size=size.small)

    // 13-15. Hedefler
    h1s = not na(h1) and not h1v ? str.tostring(h1,"#.##") : h1v ? "✓ VURDU" : "—"
    h2s = not na(h2) and not h2v ? str.tostring(h2,"#.##") : h2v ? "✓ VURDU" : "—"
    h3s = not na(h3) and not h3v ? str.tostring(h3,"#.##") : h3v ? "✓ VURDU" : "—"
    h1c = h1v ? color.new(color.gray,40) : not na(h1) ? color.new(color.orange,20) : color.new(color.gray,60)
    h2c = h2v ? color.new(color.gray,40) : not na(h2) ? color.new(color.green,20)  : color.new(color.gray,60)
    h3c = h3v ? color.new(color.gray,40) : not na(h3) ? color.new(color.teal,15)   : color.new(color.gray,60)

    table.cell(pan, 0, 13, "HEDEF-1",   text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 13, h1s,         text_color=color.white, bgcolor=h1c, text_size=size.small)
    table.cell(pan, 2, 13, "",          text_color=color.white, text_size=size.small)

    table.cell(pan, 0, 14, "HEDEF-2",   text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 14, h2s,         text_color=color.white, bgcolor=h2c, text_size=size.small)
    table.cell(pan, 2, 14, "",          text_color=color.white, text_size=size.small)

    table.cell(pan, 0, 15, "HEDEF-3",   text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 15, h3s,         text_color=color.white, bgcolor=h3c, text_size=size.small)
    table.cell(pan, 2, 15, "",          text_color=color.white, text_size=size.small)

    // 16. Genel Trend
    table.cell(pan, 0, 16, "GENEL TREND", text_color=color.white, bgcolor=color.new(color.navy,30), text_size=size.small)
    table.cell(pan, 1, 16, genel,         text_color=color.white, bgcolor=gt_clr, text_size=size.small)
    table.cell(pan, 2, 16, "",            text_color=color.white, bgcolor=gt_clr, text_size=size.small)

// ═══════════════════════════════════════════════════════════
// BÖLÜM 14: ALARMLAR (14 Farklı Alarm)
// ═══════════════════════════════════════════════════════════

alertcondition(dip_sinyal  and not dip_sinyal[1],   "Mimar Dip",         "Mimar Dip sinyali!")
alertcondition(dip_guclu   and not dip_guclu[1],    "Güçlü Dip",            "GÜÇLÜ DİP - Hacim Yüksek!")
alertcondition(al_sinyal   and not al_sinyal[1],    "AL Sinyali 7/7",       "7/7 GÜÇLÜ AL sinyali!")
alertcondition(tepe_sinyal and not tepe_sinyal[1],  "Mimar Tepe",        "Mimar Tepe sinyali!")
alertcondition(tepe_guclu  and not tepe_guclu[1],   "Güçlü Tepe",           "GÜÇLÜ TEPE!")
alertcondition(sat_sinyal  and not sat_sinyal[1],   "SAT Sinyali",          "SAT sinyali!")
alertcondition(h1v and not h1v[1],                  "Hedef-1 Vuruldu",      "Hedef-1 VURULDU - Kar Realizasyonu!")
alertcondition(h2v and not h2v[1],                  "Hedef-2 Vuruldu",      "Hedef-2 VURULDU!")
alertcondition(h3v and not h3v[1],                  "Hedef-3 Vuruldu",      "HEDEF-3 TAM KAR!")
alertcondition(st_yukari   and not st_yukari[1],    "SuperTrend AL",        "SuperTrend AL yönüne döndü!")
alertcondition(not st_yukari and st_yukari[1],      "SuperTrend SAT",       "SuperTrend SAT yönüne döndü!")
alertcondition(tz_giris,                             "Trade Zone Giriş AL",  "Fiyat Trade Zone altından içe girdi!")
alertcondition(tz_squeeze  and not tz_squeeze[1],   "Squeeze Uyarısı",      "Trade Zone daraldı - Patlama yaklaşıyor!")
alertcondition(trend_kirildi,                        "Düşen Trend Kırıldı",  "Düşen trend yukarı kırıldı - Dikkat!")
alertcondition(ha_goster and erken_al  and not erken_al[1],  "HA Erken AL Sinyali",  "HA Erken AL - Yarin yukari donecek!")
alertcondition(ha_goster and erken_sat and not erken_sat[1], "HA Erken SAT Sinyali", "HA Erken SAT - Yarin asagi donecek!")
````
