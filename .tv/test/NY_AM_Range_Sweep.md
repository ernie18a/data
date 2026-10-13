<!-- tradingview-pine-id: PUB;ca321df3e9e840a4ab410c95c44c6b17 -->
<!-- tradingviewscripts-format: 1 -->
# NY AM Range Sweep 

Source: https://www.tradingview.com/script/OBursyFM-NY-AM-Range-Sweep/

## Description

🎯 NY AM Range Sweep— Stop Chasing Fakeouts, Start Trading Confirmed Reversals

Every morning, the New York session sets a trap: liquidity gets swept, retail traders get faked out, and price reverses right after. NY AM Range Sweep is built to help you trade the other side of that trap — with discipline, not guesswork.

🔥 Why traders are switching to this setup:
Instead of jumping in on the first sign of a reversal, this indicator stacks three layers of confirmation before ever flashing a signal — cutting through the noise that catches most traders off guard.

⚙️ How it works:

📍 Session Range — Auto-plots the high/low of the 5:00–9:00 AM NY session, the window where the day's liquidity gets set.
💧 The Sweep — Waits for a confirmed candle close beyond that range, not just a wick fake-out.
✅ 5-Min Confirmation — Requires a full engulfing candle (body and wick) in the direction of the move.
✅ 45-Min Confirmation — Cross-checks the higher timeframe before greenlighting the trade.

Only when all three align does the indicator plot your entry, stop loss, and take profit — automatically, right on the chart.

📊 What you get on every signal:

Clear Buy/Sell labels
Dynamic stop loss tracking the true extreme of the move
Take profit mapped to the opposite side of the AM range
Built-in alerts so you never have to stare at the chart waiting

🕔 Best used on: the 5-minute chart, any instrument that respects the NY AM session — indices, forex, futures.

Trading involves risk. This tool is designed to support your decision-making process, not replace it — always manage risk responsibly.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sarduydaniel
plot(close)
//@version=6
indicator("NY AM Range Sweep ", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// Diseñado para correr en el gráfico de 5 minutos.

tz = "America/New_York"

// ---------- Inputs ----------
startHour = input.int(5, "Hora inicio del rango (NY)", minval=0, maxval=23)
endHour   = input.int(9, "Hora fin del rango (NY)", minval=0, maxval=23)

// ---------- Detección de nuevo día (NY) ----------
dateStr = str.format("{0}-{1}-{2}", year(time, tz), month(time, tz), dayofmonth(time, tz))
var string lastDateStr = ""
isNewDay = dateStr != lastDateStr
lastDateStr := dateStr

// ---------- Sesión del rango ----------
sessString = str.format("{0,number,00}00-{1,number,00}00:1234567", startHour, endHour)
inRangeSession = not na(time(timeframe.period, sessString, tz))

// ---------- Estado persistente (se resetea cada día) ----------
var float rangeHigh        = na
var float rangeLow         = na
var int   rangeStartBar    = na
var bool  rangeReady       = false
var bool  dayInvalid       = false
var int   sweepDir         = 0     // -1 = barrió el alto (sesgo venta) | 1 = barrió el bajo (sesgo compra)
var float sweepWick        = na
var bool  waitingConfirm5  = false
var bool  waitingConfirm45 = false
var bool  tradeTakenToday  = false
var box   rangeBox         = na

if isNewDay
    rangeHigh := na
    rangeLow := na
    rangeStartBar := na
    rangeReady := false
    dayInvalid
````
