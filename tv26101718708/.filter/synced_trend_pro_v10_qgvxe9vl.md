# Synced Trend Pro v1.0

- url: https://www.tradingview.com/script/qGvxe9vl-Synced-Trend-Pro-v1-0/
- type: indicator
- pine_id: PUB;060408ff2e5d4094b115e4a20da0e432
- version: 1.0

## Description

Synced Trend Pro is a multi-layered trend and liquidity indicator designed to simplify market structure by combining trend, momentum, volatility, and liquidity into a single chart.

Features

• Dynamic 9 / 15 / 20 EMA trend structure.

• EMA colors automatically synchronize with the active trend following the 9/20 EMA crossover.

• ATR-based volatility bands to identify price overextensions.

• RSI (14) and RSI (200) background zones for momentum and longer-term context.

• Multi-Timeframe EMA Dashboard displaying trend alignment across:

1 Minute
3 Minute
5 Minute
15 Minute
1 Hour
4 Hour
Daily
Weekly

• Double Side Liquidity (DSL) Detection
Identifies candles that take both the previous candle's high and low. DSL labels are plotted immediately when both sides of liquidity are swept, without waiting for the candle to close, making them suitable for real-time monitoring.

Alerts
EMA 9/20 Bullish Cross
EMA 9/20 Bearish Cross
ATR Overextension Above Upper Band
ATR Overextension Below Lower Band
Double Side Liquidity (DSL)
Intended Use

This indicator is designed to help traders quickly identify:

Trend direction
Momentum alignment
Volatility extremes
Multi-timeframe confirmation
Liquidity sweeps

It is intended as a decision-support tool and should be used alongside sound risk management and your own trading plan.

Future Updates

The modular design allows additional features to be added without altering the existing core logic, making future enhancements straightforward while preserving the current functionality.

## Source Code

````pine
//@version=6
indicator("Synced 9/15/200 EMA + 2xATR Bands with RSI Zones + MTF Trend Dashboard", overlay=true)

// === INPUTS ===
ema9Length   = input.int(9, title="EMA 9 Length")
ema15Length  = input.int(15, title="EMA 15 Length")
ema20Length  = input.int(20, title="EMA 20 Length")

atrLength = input.int(14, title="ATR Length")
atrMultiplier = input.float(2.0, title="ATR Multiplier")

// === MTF DASHBOARD SETTINGS ===
showDashboard = input.bool(true, title="Show MTF EMA Trend Dashboard")
show1m = input.bool(true, title="Show 1m")
show3m = input.bool(true, title="Show 3m")   // ✅ Added 3m
show5m = input.bool(true, title="Show 5m")
show15m = input.bool(true, title="Show 15m")
show1h = input.bool(true, title="Show 1H")
show4h = input.bool(true, title="Show 4H")
show1d = input.bool(true, title="Show 1D")
show1w = input.bool(true, title="Show 1W")

// === CALCULATIONS: BASE TIMEFRAME ===
ema9   = ta.ema(close, ema9Length)
ema15  = ta.ema(close, ema15Length)
ema20  = ta.ema(close, ema20Length)
atr    = ta.atr(atrLength)

upperBand = ema9 + atr * atrMultiplier
lowerBand = ema9 - atr * atrMultiplier

// === RSI ===
rsi = ta.rsi(close, 14)
rsi200 = ta.rsi(close, 200)

// === ✅ EMA 9/20 CROSSOVER LOGIC ===
emaCrossUp   = ta.crossover(ema9, ema20)
emaCrossDown = ta.crossunder(ema9, ema20)

// Persistent trend direction based on last 9/20 cross
var int emaTrendDir = 0  // 1 = bullish, -1 = bearish, 0 = neutral (before first cross)
if emaCrossUp
    emaTrendDir := 1
else if emaCrossDown
    emaTrendDir := -1

// Dynamic EMA colors based on emaTrendDir
bullColor = color.new(color.lime, 0)
bearColor = color.new(color.red, 0)

emaColor9  = emaTrendDir == 1 ? bullColor : emaTrendDir == -1 ? bearColor : color.orange
emaColor15 = emaTrendDir == 1 ? bullColor : emaTrendDir == -1 ? bearColor : color.blue
emaColor20 = emaTrendDir == 1 ? bullColor : emaTrendDir == -1 ? bearColor : color.green

// === PLOT: EMAs + Bands (UPDATED WITH DYNAMIC COLORS) ===
ema9Plot  = plot(ema9,  title="EMA 9",  color=emaColor9,  linewidth=1)
ema15Plot = plot(ema15, title="EMA 15", color=emaColor15, linewidth=1)
ema20Plot = plot(ema20, title="EMA 20", color=emaColor20, linewidth=1)

plot(upperBand, title="Upper Band (EMA9 + 2xATR)", color=color.rgb(54, 58, 69, 90), linewidth=1)
plot(lowerBand, title="Lower Band (EMA9 - 2xATR)", color=color.rgb(54, 58, 69, 90), linewidth=1)

// ✅ Transparent fill between EMA 9 and EMA 20
fillColor = emaTrendDir == 1 ? color.new(color.lime, 85) :
           emaTrendDir == -1 ? color.new(color.red, 85)  : na
fill(ema9Plot, ema20Plot, color=fillColor)

barcolor(close > upperBand or close < lowerBand ? color.new(close >= open ? color.green : color.red, 50) : na)

// === RSI BACKGROUND ===
bgcolor(rsi > 80 ? color.new(#ff5252, 91) : rsi < 20 ? color.new(color.green, 85) : na)
bgcolor(rsi200 > 80 ? color.new(#ff5252, 88) : rsi200 < 20 ? color.new(#4caf4f, 86) : na)

// === ALERTS ===
alertcondition(close < lowerBand, title="Overextension Down", message="Price CLOSED BELOW lower band — Potential long setup")
alertcondition(close > upperBand, title="Overextension Up", message="Price CLOSED ABOVE upper band — Potential short setup")

// Dot markers on chart (kept as-is)
plotshape(emaCrossUp, title="EMA 9/20 Bullish Cross", style=shape.labelup, location=location.bottom, color=color.new(color.lime, 0), size=size.small)
plotshape(emaCrossDown, title="EMA 9/20 Bearish Cross", style=shape.xcross, location=location.bottom, color=color.new(color.red, 0), size=size.small)

// Alerts (kept as-is)
alertcondition(emaCrossUp, title="EMA 9/20 Bullish Cross", message="EMA 9 crossed ABOVE EMA 20 — Bullish crossover")
alertcondition(emaCrossDown, title="EMA 9/20 Bearish Cross", message="EMA 9 crossed BELOW EMA 20 — Bearish crossover")

// === MTF EMA TREND LOGIC (BOXES IN FIXED CANVAS LAYOUT) ===
var table mtfTable = table.new(position.bottom_right, 8, 1, border_width=1, frame_color=color.black, frame_width=1)

if bar_index == 0 and showDashboard
    table.cell(mtfTable, 0, 0, "1m", text_color=color.white, bgcolor=color.gray)
    table.cell(mtfTable, 1, 0, "3m", text_color=color.white, bgcolor=color.gray) // ✅ Added 3m
    table.cell(mtfTable, 2, 0, "5m", text_color=color.white, bgcolor=color.gray)
    table.cell(mtfTable, 3, 0, "15m", text_color=color.white, bgcolor=color.gray)
    table.cell(mtfTable, 4, 0, "1H", text_color=color.white, bgcolor=color.gray)
    table.cell(mtfTable, 5, 0, "4H", text_color=color.white, bgcolor=color.gray)
    table.cell(mtfTable, 6, 0, "1D", text_color=color.white, bgcolor=color.gray)
    table.cell(mtfTable, 7, 0, "1W", text_color=color.white, bgcolor=color.gray)

if showDashboard
    tfLabels = array.from("1", "3", "5", "15", "60", "240", "D", "W") // ✅ Added 3m
    tfIdx    = array.from(0, 1, 2, 3, 4, 5, 6, 7)
    tfChecks = array.from(show1m, show3m, show5m, show15m, show1h, show4h, show1d, show1w)

    for i = 0 to array.size(tfLabels) - 1
        if array.get(tfChecks, i)
            tf = array.get(tfLabels, i)
            idx = array.get(tfIdx, i)

            ema9_tf   = request.security(syminfo.tickerid, tf, ta.ema(close, ema9Length))
            ema15_tf  = request.security(syminfo.tickerid, tf, ta.ema(close, ema15Length))
            ema20_tf  = request.security(syminfo.tickerid, tf, ta.ema(close, ema20Length))

            colorBox = ema9_tf > ema15_tf and ema15_tf > ema20_tf ? color.green :
                       ema9_tf < ema15_tf and ema15_tf < ema20_tf ? color.red : color.gray

            table.cell(mtfTable, idx, 0, array.get(tfLabels, i) + "", text_color=color.white, bgcolor=colorBox, text_size=size.small)
        else
            table.cell(mtfTable, array.get(tfIdx, i), 0, "", text_color=color.white, bgcolor=color.new(color.gray, 90), text_size=size.small)

//======================================================
// CUSTOM EXTENSION
// DOUBLE SIDE LIQUIDITY (DSL)
// Original Script Above - Unmodified
//======================================================

// === SETTINGS ===
showDSL        = input.bool(true, "Show DSL Labels")
enableDSLAlert = input.bool(true, "Enable DSL Alerts")
maxDSLLabels   = 5

// === PERSISTENT VARIABLES ===
var bool triggeredThisBar = false
var label[] dslLabels = array.new_label()

// Reset once per new candle
if barstate.isnew
    triggeredThisBar := false

// DSL Condition (works on live candle)
dslSignal = high > high[1] and low < low[1]

// Fire only once per candle
newDSL = dslSignal and not triggeredThisBar

if newDSL
    triggeredThisBar := true

    if showDSL
        lbl = label.new(
             bar_index,
             low,
             text = "DSL",
             style = label.style_label_up,
             color = color.new(color.white, 100),     // Transparent background
             textcolor = color.black,
             size = size.small)

        array.push(dslLabels, lbl)

        // Keep only the latest 5 labels
        if array.size(dslLabels) > maxDSLLabels
            oldLabel = array.shift(dslLabels)
            label.delete(oldLabel)

// Alert
alertcondition(newDSL and enableDSLAlert,
     title = "Double Side Liquidity",
     message = "DSL detected - Previous candle High and Low have both been taken.")
````
