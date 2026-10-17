# DIP TOP OSCILATOR  Divergence

- url: https://www.tradingview.com/script/EmDKoLic/
- type: indicator
- pine_id: PUB;795534669bc64a9fa8a2199b56f6e337
- version: 1.0

## Description

## English

**Stable Cycle Core  Chop Filter & Divergence**

A clean, lower-panel cycle oscillator built around a normalized momentum of EMA, smoothed by a short signal line. The goal is to read the market's rhythm without the noise of standard oscillators.

**How it works**
- **Cycle line (black):** EMA momentum normalized by ATR — adapts to volatility automatically, so readings stay comparable across timeframes and instruments.
- **Signal line (orange):** Smoothed cycle. Crossovers print **green dots (buy)** and **red dots (sell)** directly on the oscillator — WaveTrend-style, but cleaner.
- **Zero line:** Bias reference. Above zero = bullish momentum, below zero = bearish.

**Chop / Fake-Signal Filter (on the price chart)**
Choppy markets often produce buy → sell → buy in just a few bars. To avoid acting on those fakes, the script counts signals over a short window. If too many fire too quickly:
- The current bar is locked as a range, with a **green ATR line above** and a **red ATR line below** the price.
- The background turns light yellow to mark the chop zone.
- The first **break of either band is treated as the real direction**, marked by a green/red triangle.
- Outside chop conditions, no bands are drawn — the chart stays clean.

**Divergence (lower panel)**
Pivot-based divergence detection between price and the cycle oscillator:
- **Bullish:** price prints a lower low while the oscillator prints a higher low → green line + label.
- **Bearish:** price prints a higher high while the oscillator prints a lower high → red line + label.

**Alerts available**
Buy / Sell / Chop Break Up / Chop Break Down / Bullish Divergence / Bearish Divergence.

**Recommended use**
- Trade with the dots only when the market is trending (bands are not drawn).
- In sideways action, ignore the dots and **wait for an ATR band break** for direction.
- Use divergences as confirmation, not as standalone entries.
- Works on any market and any timeframe; ATR normalization handles the rest.

Not financial advice. Always combine with your own risk management.

---

## Türkçe

**Stable Cycle Core — WaveStyle Clean + Chop Filtresi & Uyumsuzluk**

Sade bir alt panel döngü osilatörüdür. Çekirdeğinde EMA momentumunun ATR ile normalize edilmiş hâli vardır; üstüne kısa bir sinyal hattı eklenmiştir. Amaç, klasik osilatörlerin gürültüsü olmadan piyasanın ritmini okumaktır.

**Nasıl çalışır?**
- **Cycle (siyah çizgi):** ATR ile normalize edilmiş EMA momentumu. Volatiliteye otomatik uyum sağladığı için farklı zaman dilimi ve enstrümanlarda değerler karşılaştırılabilir kalır.
- **Signal (turuncu çizgi):** Cycle'ın yumuşatılmış hâli. Kesişimler doğrudan osilatör üzerinde **yeşil nokta (al)** ve **kırmızı nokta (sat)** olarak işlenir — WaveTrend mantığında ama daha temiz.
- **Sıfır çizgisi:** Yön referansı. Üstü pozitif momentum, altı negatif momentum.

**Chop / Sahte Sinyal Filtresi (ana grafik üzerinde)**
Sıkışık (testere) piyasalarda al-sat-al şeklinde art arda sinyaller gelir. Bu fakelere kapılmamak için script, kısa bir pencerede sinyal sayısını izler. Sinyaller çok sık gelirse:
- O ANDA fiyatın üstüne **yeşil ATR çizgisi**, altına **kırmızı ATR çizgisi** kilitlenir.
- Arka plan hafif sarıya döner — "burası karışık bölge" demektir.
- **Hangi bant önce kırılırsa gerçek yön orasıdır** ve yeşil/kırmızı üçgenle işaretlenir.
- Karışıklık yoksa hiçbir bant çizilmez, grafik temiz kalır.

**Divergence (alt panelde)**
Pivot bazlı uyumsuzluk tespiti, fiyat ile osilatör arasında:
- **Boğa uyumsuzluğu:** fiyat daha düşük dip yaparken osilatör daha yüksek dip yapar → yeşil çizgi + etiket.
- **Ayı uyumsuzluğu:** fiyat daha yüksek tepe yaparken osilatör daha düşük tepe yapar → kırmızı çizgi + etiket.

**Alarmlar**
Buy / Sell / Chop Break Up / Chop Break Down / Boğa Uyumsuzluğu / Ayı Uyumsuzluğu.

**Önerilen kullanım**
- Trend piyasada (bant çizilmediğinde) noktaları takip et.
- Yatay/sıkışık piyasada noktaları yoksay, **ATR bantlarından birinin kırılmasını bekle**, yön orasıdır.
- Uyumsuzlukları tek başına giriş değil, **teyit aracı** olarak kullan.
- Her enstrüman ve her zaman diliminde çalışır; ATR normalizasyonu adaptasyonu otomatik sağlar.

Bu paylaşım yatırım tavsiyesi değildir. Her zaman kendi risk yönetiminle birleştir.

## Source Code

````pine
//@version=6
indicator("Stable Cycle Core (WaveStyle Clean) + Chop & Divergence", overlay=false)

//━━━━━━━━━━━━━━
// INPUT
//━━━━━━━━━━━━━━
len            = input.int(14, "Length")

atrLen         = input.int(14,  "ATR Length",                group="Chop Filter")
atrMult        = input.float(1.5,"ATR Multiplier (Bands)",   group="Chop Filter", step=0.1)
chopLookback   = input.int(8,   "Chop Lookback (bars)",      group="Chop Filter", tooltip="Bu kadar bar içindeki sinyal sayısına bakılır")
chopThreshold  = input.int(3,   "Min Signals = Chop",        group="Chop Filter", tooltip="Bu kadar veya daha fazla sinyal art arda gelirse karışık piyasa kabul edilir")

divLookback    = input.int(5,   "Divergence Pivot Lookback", group="Divergence")
divRange       = input.int(60,  "Divergence Max Bar Range",  group="Divergence")

//━━━━━━━━━━━━━━
// CORE PRICE
//━━━━━━━━━━━━━━
src = close
ema = ta.ema(src, len)

//━━━━━━━━━━━━━━
// CYCLE LOGIC
//━━━━━━━━━━━━━━
momentum  = ema - ema[1]
cycle     = ta.ema(momentum, 3)
atr       = ta.atr(len)
cycleNorm = cycle / atr
signalL   = ta.ema(cycleNorm, 5)

//━━━━━━━━━━━━━━
// ZERO LINE
//━━━━━━━━━━━━━━
hline(0, "Zero", color=color.gray)

//━━━━━━━━━━━━━━
// MAIN LINES (CLEAN STYLE)
//━━━━━━━━━━━━━━
plot(cycleNorm, "Cycle",  color=color.black,  linewidth=2)
plot(signalL,   "Signal", color=color.orange)

//━━━━━━━━━━━━━━
// WAVETREND STYLE DOTS
//━━━━━━━━━━━━━━
buy  = ta.crossover(cycleNorm,  signalL)
sell = ta.crossunder(cycleNorm, signalL)

plotshape(buy  ? cycleNorm : na, title="Buy Dot",  style=shape.circle, location=location.absolute, color=color.lime, size=size.tiny)
plotshape(sell ? cycleNorm : na, title="Sell Dot", style=shape.circle, location=location.absolute, color=color.red,  size=size.tiny)

//━━━━━━━━━━━━━━
// CHOP / FAKE-SIGNAL FILTER
// Son chopLookback bar içinde sinyal (buy+sell) sayısı
// chopThreshold'u geçerse "karışık piyasa"
//━━━━━━━━━━━━━━
sigCount = math.sum((buy or sell) ? 1 : 0, chopLookback)
isChop   = sigCount >= chopThreshold

priceAtr = ta.atr(atrLen)

// chop başladığı an ATR bantları kilitlenir, kırılana kadar sabit kalır
var float chopHi     = na
var float chopLo     = na
var bool  chopActive = false

if isChop and not chopActive
    chopHi     := high + priceAtr * atrMult
    chopLo     := low  - priceAtr * atrMult
    chopActive := true

// kırılım = yön bulundu
breakUp   = chopActive and not na(chopHi) and close > chopHi
breakDown = chopActive and not na(chopLo) and close < chopLo

// kırılım olunca veya sıklık biterse bantları kapat
if breakUp or breakDown
    chopActive := false
    chopHi     := na
    chopLo     := na
else if not isChop and chopActive and (bar_index - ta.valuewhen(isChop and not isChop[1], bar_index, 0)) > chopLookback * 2
    // sinyal sıklığı çok uzun süredir gelmiyorsa pasifle (opsiyonel güvenlik)
    chopActive := false
    chopHi     := na
    chopLo     := na

// Ana grafiğe çiz (force_overlay)
plot(chopActive ? chopHi : na, "Chop Upper (ATR)", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr, force_overlay=true)
plot(chopActive ? chopLo : na, "Chop Lower (ATR)", color=color.new(color.red,   0), linewidth=2, style=plot.style_linebr, force_overlay=true)

plotshape(breakUp,   "Break Up",   shape.triangleup,   location.belowbar, color.green, force_overlay=true, size=size.small, text="UP")
plotshape(breakDown, "Break Down", shape.triangledown, location.abovebar, color.red,   force_overlay=true, size=size.small, text="DN")

// arka plan: chop sırasında hafif sarı uyarı
bgcolor(chopActive ? color.new(color.yellow, 90) : na, title="Chop Zone BG")

//━━━━━━━━━━━━━━
// DIVERGENCE (alt panel)
// cycleNorm pivotları + price pivotları karşılaştırılır
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
        // bearish: fiyat HH, osilatör LH
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
        // bullish: fiyat LL, osilatör HL
        if curPrice < lastPLPrice and pl > lastPL
            bullDiv := true
            line.new(lastPLBar, lastPL, curBar, pl, color=color.green, width=2)
            label.new(curBar, pl, "Bull Div", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)
    lastPL      := pl
    lastPLBar   := curBar
    lastPLPrice := curPrice

//━━━━━━━━━━━━━━
// ALARMS
//━━━━━━━━━━━━━━
alertcondition(buy,       "Buy Signal",      "Cycle Buy")
alertcondition(sell,      "Sell Signal",     "Cycle Sell")
alertcondition(breakUp,   "Chop Break Up",   "ATR Üst Bant Kırıldı (Long Yön)")
alertcondition(breakDown, "Chop Break Down", "ATR Alt Bant Kırıldı (Short Yön)")
alertcondition(bullDiv,   "Bullish Div",     "Boğa Uyumsuzluk")
alertcondition(bearDiv,   "Bearish Div",     "Ayı Uyumsuzluk")
````
