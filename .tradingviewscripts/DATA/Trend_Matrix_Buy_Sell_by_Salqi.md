<!-- tradingview-pine-id: PUB;ef4ce2f53b264d14a6b5f5eae5edd354 -->
<!-- tradingviewscripts-format: 1 -->
# Trend Matrix Buy Sell by Salqi

Source: https://www.tradingview.com/script/OfHf4CZ2-Trend-Matrix-Buy-Sell-by-Salqi/

## Description

EMA Trend Matrix Buy Sell is a multi-timeframe trend confirmation indicator that combines 9 EMA conditions across three timeframes with VWAP positioning to generate clear BUY and SELL signals.

It is designed to simplify multi-timeframe analysis into an easy-to-read trend score and actionable chart signals.

TradingView Description
Trend Matrix Buy Sell by Salqi

Trend Matrix Buy Sell is a multi-timeframe trend analysis indicator designed to identify strong directional market moves using a combination of EMA alignment, VWAP confirmation, and price momentum.

Instead of relying on a single moving average, the indicator analyzes 9 EMA conditions across three configurable timeframes:

EMA 20, 50 and 200 on Timeframe 1
EMA 20, 50 and 200 on Timeframe 2
EMA 20, 50 and 200 on Timeframe 3

These conditions are combined into a Trend Matrix Score from 0 to 9, giving a simple view of how strongly multiple timeframes agree on market direction.

🟢 BUY Signals

A BUY opportunity is generated when the required number of EMA conditions become bullish. Optional VWAP confirmation can require price to also remain above VWAP before the signal is accepted.

🔴 SELL Signals

A SELL opportunity is generated when bearish conditions dominate the Trend Matrix. With VWAP confirmation enabled, price must also be below VWAP.

⚡ Three Signal Modes

Trend Change
Detects when the Trend Matrix transitions into a bullish or bearish state.

Strong Trend Only
Uses stricter multi-timeframe agreement for more selective signals.

Breakout Confirmed
Combines Trend Matrix direction with movement beyond a configurable percentage of the previous day's close.

📊 Key Features
Multi-timeframe trend analysis
9-point EMA Trend Matrix
EMA 20 / 50 / 200 confirmation
VWAP trend confirmation
Clear BUY & SELL signals
Bullish/Bearish strength score
Strict BUY → SELL signal alternation
Candle-close confirmation
Configurable signal sensitivity
Optional EMA and VWAP display
Built-in TradingView BUY/SELL alerts
🎯 Designed for Clean Decision Making

Instead of filling the chart with multiple indicators, Trend Matrix Buy Sell brings multi-timeframe trend information together into one simple system.

9 EMA conditions. Multiple timeframes. One clear trend view.

For analytical and educational purposes. Always use appropriate risk management.

---

## Source Code

````pine
//@version=6
indicator("Trend Matrix Buy Sell by Salqi", overlay = true, max_labels_count = 500)

//====================================================================
// TREND MATRIX BUY SELL
// Multi-Timeframe EMA + VWAP Trend Strength
//====================================================================

//--------------------------------------------------------------------
// 1. TIMEFRAME SETTINGS
//--------------------------------------------------------------------
grp_tf = "Timeframes"

ema_tf  = input.timeframe("1", "EMA Timeframe 1", group = grp_tf)
ema_tf2 = input.timeframe("2", "EMA Timeframe 2", group = grp_tf)
ema_tf3 = input.timeframe("5", "EMA Timeframe 3", group = grp_tf)
vwap_tf = input.timeframe("2", "VWAP Timeframe", group = grp_tf)


//--------------------------------------------------------------------
// 2. SIGNAL SETTINGS
//--------------------------------------------------------------------
grp_sig = "Buy / Sell Signals"

showSignals       = input.bool(true, "Show Buy / Sell", group = grp_sig)
strictAlternation = input.bool(true, "Strict Buy/Sell Alternation", tooltip = "Prevents repeated BUY or repeated SELL signals.", group = grp_sig)
confirmOnClose    = input.bool(true, "Confirm On Candle Close", group = grp_sig)

bullThreshold = input.int(7, "Bullish Score Required", minval = 5, maxval = 9, group = grp_sig)
bearThreshold = input.int(7, "Bearish Score Required", minval = 5, maxval = 9, group = grp_sig)

requireVWAP = input.bool(true, "Require VWAP Confirmation", tooltip = "BUY requires price above VWAP. SELL requires price below VWAP.", group = grp_sig)

signalMode = input.string(
     "Trend Change",
     "Signal Mode",
     options = ["Trend Change", "Strong Trend Only", "Breakout Confirmed"],
     group = grp_sig)


//--------------------------------------------------------------------
// 3. BREAKOUT SETTINGS
//--------------------------------------------------------------------
grp_break = "Breakout Filter"

breakoutPct = input.float(
     0.75,
     "Previous Close Threshold (%)",
     minval = 0.0,
     step = 0.05,
     tooltip = "Used only when Signal Mode is Breakout Confirmed.",
     group = grp_break)


//--------------------------------------------------------------------
// 4. VISUAL SETTINGS
//--------------------------------------------------------------------
grp_vis = "Visuals"

showTrendLabel = input.bool(true, "Show Trend Status", group = grp_vis)
showVWAP       = input.bool(false, "Show VWAP", group = grp_vis)
showEMA        = input.bool(false, "Show Primary EMA 20/50/200", group = grp_vis)

bullColor    = input.color(#00B86B, "Bullish Color", group = grp_vis)
bearColor    = input.color(#E53935, "Bearish Color", group = grp_vis)
neutralColor = input.color(#607D8B, "Neutral Color", group = grp_vis)


//====================================================================
// DAILY REFERENCE
//====================================================================

dayHigh   = request.security(syminfo.tickerid, "D", high)
dayLow    = request.security(syminfo.tickerid, "D", low)
prevClose = request.security(syminfo.tickerid, "D", close[1])

threshold = prevClose * (breakoutPct / 100.0)

isNewHigh = high >= dayHigh
isNewLow  = low <= dayLow

highBreakout = close >= prevClose + threshold
lowBreakdown = close <= prevClose - threshold


//====================================================================
// MULTI-TIMEFRAME EMA MATRIX
//====================================================================

// Timeframe 1
ema20  = request.security(syminfo.tickerid, ema_tf, ta.ema(close, 20))
ema50  = request.security(syminfo.tickerid, ema_tf, ta.ema(close, 50))
ema200 = request.security(syminfo.tickerid, ema_tf, ta.ema(close, 200))

// Timeframe 2
ema20_2  = request.security(syminfo.tickerid, ema_tf2, ta.ema(close, 20))
ema50_2  = request.security(syminfo.tickerid, ema_tf2, ta.ema(close, 50))
ema200_2 = request.security(syminfo.tickerid, ema_tf2, ta.ema(close, 200))

// Timeframe 3
ema20_3  = request.security(syminfo.tickerid, ema_tf3, ta.ema(close, 20))
ema50_3  = request.security(syminfo.tickerid, ema_tf3, ta.ema(close, 50))
ema200_3 = request.security(syminfo.tickerid, ema_tf3, ta.ema(close, 200))


//====================================================================
// VWAP
//====================================================================

vwapValue = request.security(syminfo.tickerid, vwap_tf, ta.vwap(hlc3))

aboveVWAP = close > vwapValue
belowVWAP = close < vwapValue


//====================================================================
// TREND SCORE
//====================================================================

int bullishCount = 0

bullishCount += close > ema20    ? 1 : 0
bullishCount += close > ema50    ? 1 : 0
bullishCount += close > ema200   ? 1 : 0

bullishCount += close > ema20_2  ? 1 : 0
bullishCount += close > ema50_2  ? 1 : 0
bullishCount += close > ema200_2 ? 1 : 0

bullishCount += close > ema20_3  ? 1 : 0
bullishCount += close > ema50_3  ? 1 : 0
bullishCount += close > ema200_3 ? 1 : 0

int bearishCount = 9 - bullishCount

bool bullishTrend = bullishCount >= bullThreshold
bool bearishTrend = bearishCount >= bearThreshold

bool strongBull = bullishCount >= 8
bool strongBear = bearishCount >= 8

bool vwapBullOK = not requireVWAP or aboveVWAP
bool vwapBearOK = not requireVWAP or belowVWAP


//====================================================================
// SIGNAL ENGINE
//====================================================================

// Trend Change:
// Fires when the matrix newly enters bullish/bearish territory.
//
// Strong Trend Only:
// Requires 8/9 or 9/9 EMA agreement.
//
// Breakout Confirmed:
// Requires strong matrix direction + movement beyond previous close threshold.

bool rawBuy = false
bool rawSell = false

if signalMode == "Trend Change"
    rawBuy  := bullishTrend and not bullishTrend[1] and vwapBullOK
    rawSell := bearishTrend and not bearishTrend[1] and vwapBearOK

else if signalMode == "Strong Trend Only"
    rawBuy  := strongBull and not strongBull[1] and vwapBullOK
    rawSell := strongBear and not strongBear[1] and vwapBearOK

else
    rawBuy  := bullishTrend and highBreakout and not (bullishTrend[1] and highBreakout[1]) and vwapBullOK
    rawSell := bearishTrend and lowBreakdown and not (bearishTrend[1] and lowBreakdown[1]) and vwapBearOK


// Confirm signals only on completed candles when enabled
bool confirmationOK = not confirmOnClose or barstate.isconfirmed

rawBuy  := rawBuy and confirmationOK
rawSell := rawSell and confirmationOK


//====================================================================
// STRICT BUY / SELL ALTERNATION
//====================================================================

var int lastSignal = 0
//  1 = BUY
// -1 = SELL
//  0 = none

bool buySignal  = rawBuy  and (not strictAlternation or lastSignal != 1)
bool sellSignal = rawSell and (not strictAlternation or lastSignal != -1)

if buySignal
    lastSignal := 1
else if sellSignal
    lastSignal := -1


//====================================================================
// TREND STATUS
//====================================================================

string trendText =
     bullishCount >= 8 ? "STRONG BULLISH" :
     bullishTrend      ? "BULLISH" :
     bearishCount >= 8 ? "STRONG BEARISH" :
     bearishTrend      ? "BEARISH" :
                         "NEUTRAL"

color trendColor =
     bullishCount >= 8 ? color.new(bullColor, 0) :
     bullishTrend      ? color.new(bullColor, 20) :
     bearishCount >= 8 ? color.new(bearColor, 0) :
     bearishTrend      ? color.new(bearColor, 20) :
                         color.new(neutralColor, 10)

string vwapText =
     aboveVWAP ? "VWAP ABOVE" :
     belowVWAP ? "VWAP BELOW" :
                 "VWAP FLAT"

string scoreText = str.tostring(bullishCount) + "/9 Bull"


//====================================================================
// CLEAN TREND STATUS LABEL
//====================================================================

var label trendLabel = na

if not na(trendLabel)
    label.delete(trendLabel)

if showTrendLabel
    string labelText = trendText + "\n" + scoreText + " | " + vwapText

    trendLabel := label.new(
         bar_index,
         high,
         labelText,
         style = label.style_label_left,
         color = trendColor,
         textcolor = color.white,
         size = size.small)


//====================================================================
// OPTIONAL VISUALS
//====================================================================

plot(showVWAP ? vwapValue : na, "VWAP", color = color.orange, linewidth = 2)

plot(showEMA ? ema20 : na, "EMA 20", color = color.new(bullColor, 40))
plot(showEMA ? ema50 : na, "EMA 50", color = color.new(color.blue, 40))
plot(showEMA ? ema200 : na, "EMA 200", color = color.new(bearColor, 40))


//====================================================================
// BUY / SELL LABELS
//====================================================================

plotshape(
     showSignals and buySignal,
     title = "BUY",
     style = shape.labelup,
     location = location.belowbar,
     color = bullColor,
     text = "BUY",
     textcolor = color.white,
     size = size.small)

plotshape(
     showSignals and sellSignal,
     title = "SELL",
     style = shape.labeldown,
     location = location.abovebar,
     color = bearColor,
     text = "SELL",
     textcolor = color.white,
     size = size.small)


//====================================================================
// ALERTS
//====================================================================

alertcondition(
     buySignal,
     title = "Trend Matrix BUY",
     message = "Trend Matrix BUY on {{ticker}} at {{close}}")

alertcondition(
     sellSignal,
     title = "Trend Matrix SELL",
     message = "Trend Matrix SELL on {{ticker}} at {{close}}")

alertcondition(
     buySignal or sellSignal,
     title = "Trend Matrix BUY or SELL",
     message = "Trend Matrix signal on {{ticker}} at {{close}}")
````
