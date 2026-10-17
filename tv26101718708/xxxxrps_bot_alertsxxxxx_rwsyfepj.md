# xxxx!!!!!RPS Bot Alertsxxxxx!!!!

- url: https://www.tradingview.com/script/RwsyfepJ-xxxx-RPS-Bot-Alertsxxxxx/
- type: indicator
- pine_id: PUB;a9dc9cf117a1400aadd9fa75450e9e80
- version: 1.0

## Description

RPS BOT ALTER for cyprto - Bitcoin, Solana, Etherium etc.

70-80% accuracy.

Trading time frame is 1 HR

## Source Code

````pine
//@version=5

// ============================================================
// UT Bot Alerts — Original: HPotter / Yo_adriiiiaan / QuantNomad
// Modified: Trailing Line Fixed
// ============================================================

indicator(title='xxxx!!!!!RPS Bot Alertsxxxxx!!!!', overlay=true)

// ============================================================
// INPUTS — ORIGINAL
// ============================================================
a = input(2,     title="Key Vaule. 'This changes the sensitivity'")
c = input(10,    title="ATR Period")
h = input(false, title="Signals from Heikin Ashi Candles")

// ============================================================
// CORE LOGIC — ORIGINAL
// ============================================================
xATR  = ta.atr(c)
nLoss = a * xATR

src = h ? request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close, lookahead=barmerge.lookahead_off) : close

xATRTrailingStop = 0.0
xATRTrailingStop := src > nz(xATRTrailingStop[1], 0) and src[1] > nz(xATRTrailingStop[1], 0) ? math.max(nz(xATRTrailingStop[1]), src - nLoss) : src < nz(xATRTrailingStop[1], 0) and src[1] < nz(xATRTrailingStop[1], 0) ? math.min(nz(xATRTrailingStop[1]), src + nLoss) : src > nz(xATRTrailingStop[1], 0) ? src - nLoss : src + nLoss

pos = 0
pos := src[1] < nz(xATRTrailingStop[1], 0) and src > nz(xATRTrailingStop[1], 0) ? 1 : src[1] > nz(xATRTrailingStop[1], 0) and src < nz(xATRTrailingStop[1], 0) ? -1 : nz(pos[1], 0)

ema_ut  = ta.ema(src, 1)
above   = ta.crossover(ema_ut, xATRTrailingStop)
below   = ta.crossover(xATRTrailingStop, ema_ut)

buy     = src > xATRTrailingStop and above
sell    = src < xATRTrailingStop and below
barbuy  = src > xATRTrailingStop
barsell = src < xATRTrailingStop

// ============================================================
// ✅ TRAILING LINE — FIXED (single line, color changes)
// ============================================================
plot(xATRTrailingStop, title="UT Trail", color=barbuy ? color.green : color.red, linewidth=2)

// ============================================================
// ORIGINAL PLOTS
// ============================================================
plotshape(buy,  title="Buy",  text='Buy',  style=shape.labelup,   location=location.belowbar, color=color.new(color.green, 0), textcolor=color.new(color.white, 0), size=size.tiny)
plotshape(sell, title="Sell", text='Sell', style=shape.labeldown, location=location.abovebar, color=color.new(color.red,   0), textcolor=color.new(color.white, 0), size=size.tiny)

barcolor(barbuy  ? color.green : na)
barcolor(barsell ? color.red   : na)

// ============================================================
// ALERTS — ORIGINAL
// ============================================================
alertcondition(buy,  "UT Long",  "UT Long")
alertcondition(sell, "UT Short", "UT Short")
````
