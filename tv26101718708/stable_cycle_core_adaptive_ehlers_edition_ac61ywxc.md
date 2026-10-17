# Stable Cycle Core (Adaptive Ehlers Edition)

- url: https://www.tradingview.com/script/AC61YWxc/
- type: indicator
- pine_id: PUB;94e1597262124818af6a5bfc95096989
- version: 1.0

## Description

## English

**Stable Cycle Core — Adaptive Ehlers Edition**

A next-generation cycle oscillator that doesn't rely on a fixed length. Most oscillators (RSI, MACD, Stoch) use a hard-coded period like 14 — which is arbitrary. This script instead **measures the market's actual dominant cycle period in real time** and adapts itself to it.

**Engine: Ehlers Autocorrelation Periodogram**
Based on John F. Ehlers' work in *Cycle Analytics for Traders*. The pipeline:
1. **High-Pass filter** removes long-term trend so only the cyclical component remains.
2. **SuperSmoother** cleans high-frequency noise without lag.
3. **Pearson autocorrelation** is calculated for periods 10–48.
4. A **Discrete Fourier Transform** of those correlations reveals which period carries the most power.
5. The **dominant cycle** is computed as a power-weighted center of gravity, then halved to drive an adaptive EMA + adaptive ATR.

The result: when the market breathes faster, the indicator shortens itself. When it slows, it lengthens. No more guessing the right "length" parameter.

**Visual layout (lower panel)**
- **Black line — Cycle:** Adaptive momentum, ATR-normalized.
- **Orange line — Signal:** Smoothed cycle. Dot crossovers = entry triggers.
- **Blue / Purple — Sine Wave & Lead Sine:** Phase-based true sinusoidal cycle. Their crossovers often **lead price tops/bottoms by a few bars** — this is the real "cycle leading edge" Ehlers describes.
- **Green / Red dots:** Buy/Sell triggers from cycle-signal crossover.

**On the price chart**
- **Chop Filter:** When buy/sell signals fire too frequently in a short window, the script locks an upper green ATR line and a lower red ATR line on the chart, plus a soft yellow background to mark the choppy zone. The first **band break = real direction** (green/red triangle).
- Outside chop conditions, no bands draw — chart stays clean.

**Divergence (lower panel)**
Pivot-based bullish (green) and bearish (red) divergences between price and the cycle oscillator, drawn automatically with line + label.

**Info Table (top right)**
- Mode (Adaptive / Manual)
- Detected Dominant Cycle
- Effective length being used
- Whether the market is currently in a chop zone

**Alerts**
Buy / Sell / Chop Break Up / Chop Break Down / Bullish Divergence / Bearish Divergence.

**How to read it**
- A **stable Dom. Cycle reading** (e.g., sitting around 22 for many bars) means the market is rhythmically rotating — trade the dots and Sine crosses.
- A **jumpy Dom. Cycle** (12 → 35 → 14) means no clean cycle exists — wait for an ATR band break.
- Use **Sine + Lead Sine crossovers as early warning** (they lead price), and the cycle dots as the **trigger**.
- Divergences = confirmation, not standalone entry.

Works on every market and timeframe — the adaptive engine handles the rest.

Not financial advice. Combine with proper risk management.

---

## Türkçe

**Stable Cycle Core — Adaptif Ehlers Sürümü**

Sabit periyot kullanmayan yeni nesil bir döngü osilatörü. Klasik göstergeler (RSI, MACD, Stoch) sabit `14` gibi rastgele bir periyot kullanır. Bu script ise **piyasanın o anki gerçek dominant döngü periyodunu canlı olarak ölçer** ve kendini ona göre ayarlar.

**Motor: Ehlers Autocorrelation Periodogram**
John F. Ehlers'ın *Cycle Analytics for Traders* kitabındaki yönteme dayanır. İşlem zinciri:
1. **High-Pass filtre** uzun vadeli trendi temizler, sadece döngüsel kısım kalır.
2. **SuperSmoother** gecikme yaratmadan yüksek frekanslı gürültüyü siler.
3. **Pearson otokorelasyonu** 10–48 arasındaki her periyot için hesaplanır.
4. Bu korelasyonların **DFT (Discrete Fourier Transform)** dönüşümü, hangi periyodun en çok güç taşıdığını ortaya çıkarır.
5. **Dominant cycle**, güç-ağırlıklı bir ağırlık merkezi olarak bulunur ve yarısı adaptif EMA + adaptif ATR'ye beslenir.

Sonuç: piyasa hızlandığında gösterge kısalır, yavaşladığında uzar. "Doğru length kaç olmalı?" sorusu ortadan kalkar.

**Alt panel görseli**
- **Siyah çizgi — Cycle:** ATR ile normalize edilmiş adaptif momentum.
- **Turuncu çizgi — Signal:** Cycle'ın yumuşatılmış hâli. Kesişimler giriş tetikleyicisidir.
- **Mavi / Mor — Sine Wave ve Lead Sine:** Faz tabanlı gerçek sinüzoidal döngü. Kesişimleri çoğu zaman **fiyat tepe/diplerini birkaç bar önceden işaret eder** — Ehlers'ın bahsettiği "cycle leading edge" budur.
- **Yeşil / Kırmızı noktalar:** Cycle-Signal kesişiminden Buy/Sell tetikleri.

**Ana grafik üstünde**
- **Chop Filtresi:** Kısa bir pencerede çok sık buy/sell sinyali gelirse, fiyatın üstüne yeşil, altına kırmızı ATR çizgisi kilitlenir, arka plan hafif sarıya döner. **Hangi bant önce kırılırsa gerçek yön orasıdır** (yeşil/kırmızı üçgen ile işaretlenir).
- Karışıklık yokken hiçbir bant çizilmez, grafik temiz kalır.

**Divergence (alt panelde)**
Pivot tabanlı boğa (yeşil) ve ayı (kırmızı) uyumsuzlukları otomatik olarak çizgi + etiketle işaretlenir.

**Bilgi Tablosu (sağ üst)**
- Mod (Adaptif / Manuel)
- Tespit edilen Dominant Cycle
- Kullanılan etkili length
- Piyasa şu an chop bölgesinde mi

**Alarmlar**
Buy / Sell / Chop Break Up / Chop Break Down / Boğa Uyumsuzluğu / Ayı Uyumsuzluğu.

**Nasıl okunur**
- **Dom. Cycle değeri sabit kalıyorsa** (örn. uzun süre 22 civarında) piyasa ritmik dönüyor demektir — noktaları ve Sine kesişimlerini değerlendirebilirsin.
- **Dom. Cycle zıplıyorsa** (12 → 35 → 14) net bir döngü yok — ATR bant kırılımını beklemek mantıklı.
- **Sine + Lead Sine kesişimini erken uyarı** (fiyatı önceler), cycle noktalarını **tetikleyici** olarak kullan.
- Divergence = teyit aracı, tek başına giriş değil.

Her enstrümanda ve her zaman diliminde çalışır — adaptif motor gerisini halleder.

Bu paylaşım yatırım tavsiyesi değildir. Her zaman kendi risk yönetiminle birleştir.

## Source Code

````pine
//@version=6
indicator("Stable Cycle Core (Adaptive Ehlers Edition)", overlay=false)

//━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━
useAdaptive   = input.bool(true,  "Use Adaptive Cycle (Ehlers APO)", group="Cycle Engine")
manualLen     = input.int(14,     "Manual Length (when adaptive off)", group="Cycle Engine")
showSine      = input.bool(true,  "Show Sine / Lead Sine",            group="Cycle Engine")
showTable     = input.bool(true,  "Show Info Table",                  group="Cycle Engine")

atrLen        = input.int(14,   "ATR Length",            group="Chop Filter")
atrMult       = input.float(1.5,"ATR Multiplier",        group="Chop Filter", step=0.1)
chopLookback  = input.int(8,    "Chop Lookback (bars)",  group="Chop Filter")
chopThreshold = input.int(3,    "Min Signals = Chop",    group="Chop Filter")

divLookback   = input.int(5,    "Divergence Pivot Lookback", group="Divergence")
divRange      = input.int(60,   "Divergence Max Bar Range",  group="Divergence")

//━━━━━━━━━━━━━━
// EHLERS AUTOCORRELATION PERIODOGRAM
// Ref: J.F. Ehlers, "Cycle Analytics for Traders" (2013)
//━━━━━━━━━━━━━━
src        = close
PI         = math.pi
HP_LEN     = 48
SS_LEN     = 10
AVG_LEN    = 3
MIN_PERIOD = 10
MAX_PERIOD = 48

// 1) High-Pass (uzun trendi temizler)
alpha1 = (math.cos(0.707 * 2 * PI / HP_LEN) + math.sin(0.707 * 2 * PI / HP_LEN) - 1) / math.cos(0.707 * 2 * PI / HP_LEN)
var float hp = 0.0
hp := bar_index < 3 ? 0.0 :
       (1 - alpha1/2)*(1 - alpha1/2)*(src - 2*nz(src[1]) + nz(src[2]))
       + 2*(1 - alpha1)*nz(hp[1])
       - (1 - alpha1)*(1 - alpha1)*nz(hp[2])

// 2) SuperSmoother
a1 = math.exp(-1.414 * PI / SS_LEN)
b1 = 2 * a1 * math.cos(1.414 * PI / SS_LEN)
c2 = b1
c3 = -a1 * a1
c1 = 1 - c2 - c3
var float filt = 0.0

  

// 3) Pearson autocorrelation (10..48 lag)
corrArr = array.new_float(MAX_PERIOD + 1, 0.0)
for period = MIN_PERIOD to MAX_PERIOD
    Sx = 0.0, Sy = 0.0, Sxx = 0.0, Syy = 0.0, Sxy = 0.0
    for cnt = 0 to AVG_LEN - 1
        x = nz(filt[cnt])
        y = nz(filt[period + cnt])
        Sx  += x
        Sy  += y
        Sxx += x*x
        Syy += y*y
        Sxy += x*y
    denom = (AVG_LEN*Sxx - Sx*Sx) * (AVG_LEN*Syy - Sy*Sy)
    cVal  = denom > 0 ? (AVG_LEN*Sxy - Sx*Sy) / math.sqrt(denom) : 0.0
    array.set(corrArr, period, cVal)

// 4) Discrete Fourier Transform -> her periyodun gücü
var R = array.new_float(MAX_PERIOD + 1, 0.0)
for period = MIN_PERIOD to MAX_PERIOD
    cosPart = 0.0, sinPart = 0.0
    for n = AVG_LEN to MAX_PERIOD
        c = array.get(corrArr, n)
        cosPart += c * math.cos(2 * PI * n / period)
        sinPart += c * math.sin(2 * PI * n / period)
    sqSum = cosPart*cosPart + sinPart*sinPart
    rOld  = array.get(R, period)
    array.set(R, period, 0.2 * sqSum * sqSum + 0.8 * rOld)

// 5) Maksimum güç (decay'li)
var float maxPwr = 0.0
maxPwr := 0.995 * maxPwr
for period = MIN_PERIOD to MAX_PERIOD
    r = array.get(R, period)
    if r > maxPwr
        maxPwr := r

// 6) Dominant Cycle (yüksek güçlü periyotların ağırlıklı ortalaması)
spx = 0.0, sp = 0.0
for period = MIN_PERIOD to MAX_PERIOD
    pwr = maxPwr > 0 ? array.get(R, period) / maxPwr : 0.0
    if pwr >= 0.5
        spx += period * pwr
        sp  += pwr
domCycle = sp > 0 ? spx / sp : float(MIN_PERIOD)

//━━━━━━━━━━━━━━
// EFFECTIVE LENGTH
//━━━━━━━━━━━━━━
adaptLen = math.max(2.0, domCycle / 2.0)
effLen   = useAdaptive ? adaptLen : float(manualLen)

//━━━━━━━━━━━━━━
// ADAPTIVE EMA (length series-float kabul eder)
//━━━━━━━━━━━━━━
emaA(s, l) =>
    a = 2.0 / (math.max(1.0, l) + 1.0)
    var float v = na
    v := na(v) ? s : a * s + (1.0 - a) * nz(v[1])
    v

emaPrice = emaA(src, effLen)

// Adaptive ATR (Wilder)
trVal = ta.tr(true)
adAtr(l) =>
    a = 1.0 / math.max(1.0, l)
    var float v = na
    v := na(v) ? trVal : a * trVal + (1.0 - a) * nz(v[1])
    v
atrAdap = adAtr(effLen)

//━━━━━━━━━━━━━━
// CYCLE OSCILLATOR
//━━━━━━━━━━━━━━
momentum  = emaPrice - nz(emaPrice[1])
cycleRaw  = emaA(momentum, 3.0)
cycleNorm = atrAdap > 0 ? cycleRaw / atrAdap : 0.0
signalL   = emaA(cycleNorm, 5.0)

//━━━━━━━━━━━━━━
// SINE WAVE / LEAD SINE (gerçek salınım görüntüsü)
//━━━━━━━━━━━━━━
dcPeriodInt = math.max(2, math.min(50, int(math.round(domCycle))))
realPart = 0.0
imagPart = 0.0
for i = 0 to 49
    if i < dcPeriodInt
        realPart += math.sin(2 * PI * i / dcPeriodInt) * nz(filt[i])
        imagPart += math.cos(2 * PI * i / dcPeriodInt) * nz(filt[i])

dcPhase = 0.0
if math.abs(imagPart) > 0.001
    dcPhase := math.todegrees(math.atan(realPart / imagPart))
if imagPart < 0
    dcPhase += 180.0
dcPhase += 90.0
if dcPhase > 315.0
    dcPhase -= 360.0

sineWave = math.sin(math.toradians(dcPhase))
leadSine = math.sin(math.toradians(dcPhase + 45.0))

//━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━
hline(0, "Zero", color=color.gray)

plot(cycleNorm, "Cycle",  color=color.black,  linewidth=2)
plot(signalL,   "Signal", color=color.orange)

plot(showSine ? sineWave : na, "Sine Wave", color=color.new(color.blue,   0), linewidth=1)
plot(showSine ? leadSine : na, "Lead Sine", color=color.new(color.purple, 0), linewidth=1)

//━━━━━━━━━━━━━━
// SIGNAL DOTS
//━━━━━━━━━━━━━━
buy  = ta.crossover(cycleNorm,  signalL)
sell = ta.crossunder(cycleNorm, signalL)

plotshape(buy  ? cycleNorm : na, title="Buy Dot",  style=shape.circle, location=location.absolute, color=color.lime, size=size.tiny)
plotshape(sell ? cycleNorm : na, title="Sell Dot", style=shape.circle, location=location.absolute, color=color.red,  size=size.tiny)

//━━━━━━━━━━━━━━
// CHOP FILTER (ana grafiğe çiziyor)
//━━━━━━━━━━━━━━
sigCount = math.sum((buy or sell) ? 1 : 0, chopLookback)
isChop   = sigCount >= chopThreshold

priceAtr = ta.atr(atrLen)

var float chopHi     = na
var float chopLo     = na
var bool  chopActive = false

if isChop and not chopActive
    chopHi     := high + priceAtr * atrMult
    chopLo     := low  - priceAtr * atrMult
    chopActive := true

breakUp   = chopActive and not na(chopHi) and close > chopHi
breakDown = chopActive and not na(chopLo) and close < chopLo

if breakUp or breakDown
    chopActive := false
    chopHi     := na
    chopLo     := na

plot(chopActive ? chopHi : na, "Chop Upper (ATR)", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr, force_overlay=true)
plot(chopActive ? chopLo : na, "Chop Lower (ATR)", color=color.new(color.red,   0), linewidth=2, style=plot.style_linebr, force_overlay=true)

plotshape(breakUp,   "Break Up",   shape.triangleup,   location.belowbar, color.green, force_overlay=true, size=size.small, text="UP")
plotshape(breakDown, "Break Down", shape.triangledown, location.abovebar, color.red,   force_overlay=true, size=size.small, text="DN")

bgcolor(chopActive ? color.new(color.yellow, 90) : na, title="Chop Zone BG")

//━━━━━━━━━━━━━━
// DIVERGENCE
//━━━━━━━━━━━━━━
ph = ta.pivothigh(cycleNorm, divLookback, divLookback)
pl = ta.pivotlow(cycleNorm,  divLookback, divLookback)

var float lastPH      = na
var int   lastPHBar   = na
var float lastPHPrice = na
var float lastPL      = na
var int   lastPLBar   = na
var float lastPLPrice = na

bearDiv = false
bullDiv = false

if not na(ph)
    curBar   = bar_index - divLookback
    curPrice = high[divLookback]
    if not na(lastPH) and (curBar - lastPHBar) <= divRange
        if curPrice > lastPHPrice and ph < lastPH
            bearDiv := true
            line.new(lastPHBar, lastPH, curBar, ph, color=color.red, width=2)
            label.new(curBar, ph, "Bear Div", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
    lastPH      := ph
    lastPHBar   := curBar
    lastPHPrice := curPrice

if not na(pl)
    curBar   = bar_index - divLookback
    curPrice = low[divLookback]
    if not na(lastPL) and (curBar - lastPLBar) <= divRange
        if curPrice < lastPLPrice and pl > lastPL
            bullDiv := true
            line.new(lastPLBar, lastPL, curBar, pl, color=color.green, width=2)
            label.new(curBar, pl, "Bull Div", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)
    lastPL      := pl
    lastPLBar   := curBar
    lastPLPrice := curPrice

//━━━━━━━━━━━━━━
// INFO TABLE
//━━━━━━━━━━━━━━
var table infoTbl = table.new(position.top_right, 2, 4, border_width=1)
if showTable and barstate.islast
    table.cell(infoTbl, 0, 0, "Mode",        bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 0, useAdaptive ? "Adaptive" : "Manual", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 0, 1, "Dom. Cycle",  bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 1, str.tostring(domCycle, "#.0"),       text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 0, 2, "Eff. Length", bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 2, str.tostring(effLen,   "#.0"),       text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 0, 3, "Chop?",       bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 3, chopActive ? "YES" : "no", text_color=chopActive ? color.yellow : color.white, text_size=size.small)

//━━━━━━━━━━━━━━
// ALARMS
//━━━━━━━━━━━━━━
alertcondition(buy,       "Buy Signal",      "Cycle Buy")
alertcondition(sell,      "Sell Signal",     "Cycle Sell")
alertcondition(breakUp,   "Chop Break Up",   "ATR Üst Bant Kırıldı (Long)")
alertcondition(breakDown, "Chop Break Down", "ATR Alt Bant Kırıldı (Short)")
alertcondition(bullDiv,   "Bullish Div",     "Boğa Uyumsuzluk")
alertcondition(bearDiv,   "Bearish Div",     "Ayı Uyumsuzluk")
````
