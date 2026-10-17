# EMA30 Band Breakout by EL COBER

- url: https://www.tradingview.com/script/so4mWdrN/
- type: indicator
- pine_id: PUB;6ddfdbe8c32b4a87bc38ebf674477bc7
- version: 4.0

## Description

A trend-following indicator that wraps price in a band built from two EMAs, 30-period EMA of highs and 30-period EMA of lows, and signals when price breaks out to a new swing beyond its previous one. A 200-period EMA acts as the trend filter.

How it works

The band. The space between the EMA30 High and EMA30 Low is shaded according to where price is closing:

Green: close is above the EMA30 High (bullish pressure)
Yellow: close is inside the band (neutral / consolidation)
Red: close is below the EMA30 Low (bearish pressure)

LONG signal. While price is trading above the EMA30 High, the script tracks the peak of that excursion. When it falls back inside the band, that peak is stored as the reference high. A LONG label prints when a later push above the band breaks above that previous peak, and the close is above the EMA200.

SHORT signal. The exact mirror: price trades below the EMA30 Low, the lowest point of that excursion is stored, and a SHORT label prints when a later move breaks below that previous trough, with the close below the EMA200.

Staying in the trade. A signal won’t repeat while the position is considered open. A long is considered finished only after two consecutive closes below the EMA30 Low (a short, after two consecutive closes above the EMA30 High), so single-bar dips don’t end the move early.

Small dotted lines on the chart mark the stored previous peak and trough, so you can see exactly which level a breakout has to clear.

Settings

EMA band length and trend EMA length
EMA200 trend filter on/off
Breakout confirmation by close or by high/low touch
Show/hide SHORT signals
Number of consecutive closes required to end a position
Band fill: on/off, opacity, and a custom color for each zone

Notes

Signals are calculated on bar close; the band color can change while a bar is still forming and settles when it closes.
Works on any market and timeframe, but the parameters are best tuned to the instrument you trade.
This is a charting tool, not a strategy, and it does not place orders or show backtest results.
Not financial advice. Always test on your own markets and use proper risk management.

## Source Code

````pine
//@version=6
indicator("EMA30 Band Kırılım", overlay=true)

// ───────── Girdiler ─────────
lenBand  = input.int(30,  "EMA Band Periyodu", minval=1)
len200   = input.int(200, "Trend EMA Periyodu", minval=1)
useTrend = input.bool(true, "EMA200 trend filtresi (long: üstü, short: altı)")
useClose = input.bool(true, "Kırılımı kapanışla teyit et (kapalıysa high/low)")
useShort = input.bool(true, "SHORT sinyallerini göster")
revOn    = input.bool(true, "Bant dışı kapanışla ters sinyal ver (LONG iken altında, SHORT iken üstünde)")
revBars  = input.int(2, "Ters sinyal için peşpeşe kapanış sayısı", minval=1)

fillOn   = input.bool(true, "Bant boyamasını göster", group="Bant Rengi")
fillOpac = input.int(35, "Bant opaklığı % (0 = görünmez, 100 = tam dolu)", minval=0, maxval=100, group="Bant Rengi")
colUp    = input.color(color.green, "Fiyat EMA30 high üstünde", group="Bant Rengi")
colMid   = input.color(color.yellow, "Fiyat bandın içinde",      group="Bant Rengi")
colDown  = input.color(color.red,   "Fiyat EMA30 low altında",  group="Bant Rengi")

showEma50 = input.bool(false, "EMA50 göster", group="EMA50")
lenEma50  = input.int(50, "EMA50 periyodu", minval=1, group="EMA50")
colEma50  = input.color(color.aqua, "EMA50 rengi", group="EMA50")

// ───────── Ortalamalar ─────────
emaH   = ta.ema(high,  lenBand)
emaL   = ta.ema(low,   lenBand)
ema200 = ta.ema(close, len200)

pH = plot(emaH, "EMA30 High", color=color.new(color.green, 0))
pL = plot(emaL, "EMA30 Low",  color=color.new(color.red, 0))
plot(ema200, "EMA200", color=color.new(color.orange, 0), linewidth=2)

// EMA50 (varsayılan kapalı, ayarlardan açılır)
ema50 = ta.ema(close, lenEma50)
plot(showEma50 ? ema50 : na, "EMA50", color=colEma50, linewidth=2)

// Fiyatın banda göre konumu: 1 = üstünde, -1 = altında, 0 = içinde
zone   = close > emaH ? 1 : close < emaL ? -1 : 0
transp = 100 - fillOpac
fill(pH, pL, fillOn and zone ==  1 ? color.new(colUp,   transp) : na, "Yeşil bölge")
fill(pH, pL, fillOn and zone ==  0 ? color.new(colMid,  transp) : na, "Sarı bölge")
fill(pH, pL, fillOn and zone == -1 ? color.new(colDown, transp) : na, "Kırmızı bölge")

// ───────── Bant dışı tepe/dip takibi ─────────
// Fiyat EMA30 high üstündeyken oluşan tepe (curPeak); bant içine dönünce prevPeak'e aktarılır.
aboveBand = close > emaH
belowBand = close < emaL

var float curPeak    = na
var float prevPeak   = na
var float curTrough  = na
var float prevTrough = na

if aboveBand
    curPeak := na(curPeak) ? high : math.max(curPeak, high)
else if not na(curPeak)
    prevPeak := curPeak
    curPeak  := na

if belowBand
    curTrough := na(curTrough) ? low : math.min(curTrough, low)
else if not na(curTrough)
    prevTrough := curTrough
    curTrough  := na

// ───────── Sinyaller ─────────
brkUp   = useClose ? close > prevPeak   : high > prevPeak
brkDown = useClose ? close < prevTrough : low  < prevTrough

trendUp   = not useTrend or close > ema200
trendDown = not useTrend or close < ema200

// Son sinyalin yönü: sinyaller sırayla gider (LONG, SHORT, LONG, SHORT...)
var int lastDir = 0

// Ters sinyal: son sinyal LONG iken EMA30 low altında, SHORT iken EMA30 high üstünde peşpeşe N kapanış
belowCnt = math.sum(close < emaL ? 1 : 0, revBars)
aboveCnt = math.sum(close > emaH ? 1 : 0, revBars)
revShort = revOn and useShort and lastDir ==  1 and belowCnt == revBars and trendDown
revLong  = revOn and useShort and lastDir == -1 and aboveCnt == revBars and trendUp

longSig  = (aboveBand and not na(prevPeak)   and brkUp   and trendUp   and (lastDir <= 0 or not useShort)) or revLong
shortSig = (useShort and belowBand and not na(prevTrough) and brkDown and trendDown and lastDir >= 0) or revShort

if longSig
    lastDir := 1
else if shortSig
    lastDir := -1

// ───────── Etiketler ─────────
plotshape(longSig,  "LONG",  shape.labelup,   location.belowbar, color=color.green, textcolor=color.white, text="LONG",  size=size.small)
plotshape(shortSig, "SHORT", shape.labeldown, location.abovebar, color=color.red,   textcolor=color.white, text="SHORT", size=size.small)

// Referans seviyeleri
plot(prevPeak,   "Önceki Tepe", color=color.new(color.green, 60), style=plot.style_circles)
plot(prevTrough, "Önceki Dip",  color=color.new(color.red, 60),   style=plot.style_circles)
````
