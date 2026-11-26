# Versatile Scalper

- url: https://www.tradingview.com/script/DGYGVDxx-Versatile-Scalper/
- type: indicator
- pine_id: PUB;54609177be4d45b18f7e0d2dbcd255b1
- version: 1.0

## Description

[b]All In One indicator

A complete intraday trading suite built for scalpers and 0DTE options traders. Instead of cluttering your chart with 6 separate indicators this script combines everything into one clean overlay — Linear Regression, RSI candle coloring, VWAP, Supertrend signals, market structure labels and a full MA Ribbon. Every component is individually toggleable so you only see what you need.

What's inside:

Linear Regression + Signal Line

The white LinReg line shows the true underlying trend by fitting a regression curve to recent price action and cutting through noise. The signal line changes color in real time — green when momentum is rising, red when falling. The moment it changes color is your directional cue.

RSI Candle Coloring

Every candle on your chart turns lime green when RSI is above its SMA and red when below. No need to watch a separate RSI panel — momentum state is baked directly into your candles.

Session VWAP

The purple VWAP resets every session and shows where institutional traders are anchored for the day. Price above VWAP — bullish bias, look for calls. Price below — bearish bias, look for puts. Optional standard deviation bands show the normal trading range and extreme extension zones.

Supertrend Signals

Green triangle below the candle — the trend just flipped bullish. Red triangle above — bearish flip. Built in cooldown prevents the same signal from firing multiple times in a row. Fully toggleable when you don't need it.

HH / HL / LH / LL Labels

Automatically detects and labels Higher Highs, Higher Lows, Lower Highs and Lower Lows using pivot detection. Tells you the structure of the market at a glance — HH + HL pattern means uptrend intact, LH + LL means downtrend developing. Toggle on when you want structure context, toggle off for a clean chart.

MA Ribbon

Four fully customizable moving averages — choose SMA, EMA, RMA, WMA or VWMA for each one. Set any length and any color. All four default to off so you start with a clean chart and add only what you need. 

How to use it:
🟢 Bullish setup:

Candles are lime green
Signal line is green and rising
Price is above VWAP
Supertrend fires green triangle
HH and HL labels confirming structure

🔴 Bearish setup:

Candles are red
Signal line is red and falling
Price is below VWAP
Supertrend fires red triangle
LH and LL labels confirming structure


Settings:
Every component has its own settings group — Linear Regression, RSI Candle Color, VWAP Levels, Supertrend, HHLL and MA Ribbon. Toggle any component on or off without affecting the others. Built for 1 minute SPY and SPX but works on any instrument and any timeframe.[/b][b][/b]

## Source Code

````pine
//@version=6
indicator(title="LinReg + Supertrend", shorttitle="LinReg+ST", format=format.price, precision=4, overlay=true, max_labels_count=500)

// ─── LINREG INPUTS ────────────────────────────────────────────────────────────
showLinReg    = input.bool(true, title="Show Linear Regression",   group="Linear Regression")
showSignal    = input.bool(true, title="Show Signal Line",         group="Linear Regression")
signal_length = input.int(7,     title="Signal Smoothing",         group="Linear Regression", minval=1, maxval=200)
sma_signal    = input.bool(true, title="Simple MA (Signal Line)",  group="Linear Regression")
lin_reg       = input.bool(true, title="Lin Reg",                  group="Linear Regression")
linreg_length = input.int(11,    title="Linear Regression Length", group="Linear Regression", minval=1, maxval=200)
rsiLen        = input.int(14,     title="RSI Length",               group="RSI Candle Color")
smaLen        = input.int(14,    title="RSI SMA Length",           group="RSI Candle Color")

// ─── VWAP INPUTS ──────────────────────────────────────────────────────────────
showDaily  = input.bool(true,  title="Show Session VWAP",  group="VWAP Levels")
showBands  = input.bool(false, title="Show Std Dev Bands", group="VWAP Levels")
bandMult1  = input.float(1.0,  title="Band 1 Multiplier",  group="VWAP Levels")
bandMult2  = input.float(2.0,  title="Band 2 Multiplier",  group="VWAP Levels")

// ─── SUPERTREND INPUTS ────────────────────────────────────────────────────────
showST   = input.bool(true,  title="Show Supertrend",          group="Supertrend")
atrLen   = input.int(7,      title="ATR Length",               group="Supertrend")
atrMult  = input.float(0.7,  title="ATR Multiplier",           group="Supertrend", step=0.1)
cooldown = input.int(8,      title="Signal Cooldown (candles)",group="Supertrend", minval=1)
bullCol  = input.color(#089981, title="Bullish",               group="Supertrend")
bearCol  = input.color(#f23645, title="Bearish",               group="Supertrend")

// ─── HHLL INPUTS ──────────────────────────────────────────────────────────────
showHHLL   = input.bool(false, title="Show HH/HL/LH/LL",  group="HHLL")
zigzagLen  = input.int(20,     title="ZigZag Period",      group="HHLL", minval=1)
hhllSrc    = input.string("High/Low", title="Source",      group="HHLL", options=["High/Low","Close"])
upColHHLL  = input.color(color.green, title="Bullish",     group="HHLL")
dnColHHLL  = input.color(color.red,   title="Bearish",     group="HHLL")

// ─── MA RIBBON INPUTS — all off by default ────────────────────────────────────
ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source,  length)
        "EMA"        => ta.ema(source,  length)
        "SMMA (RMA)" => ta.rma(source,  length)
        "WMA"        => ta.wma(source,  length)
        "VWMA"       => ta.vwma(source, length)
        => na

show_ma1   = input(false,        "MA #1", inline="MA #1", group="MA Ribbon")
ma1_type   = input.string("SMA", "",      inline="MA #1", group="MA Ribbon", options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"])
ma1_source = input(close,        "",      inline="MA #1", group="MA Ribbon")
ma1_length = input.int(20,       "",      inline="MA #1", group="MA Ribbon", minval=1)
ma1_color  = input(#f6c309,      "",      inline="MA #1", group="MA Ribbon")

show_ma2   = input(false,        "MA #2", inline="MA #2", group="MA Ribbon")
ma2_type   = input.string("SMA", "",      inline="MA #2", group="MA Ribbon", options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"])
ma2_source = input(close,        "",      inline="MA #2", group="MA Ribbon")
ma2_length = input.int(50,       "",      inline="MA #2", group="MA Ribbon", minval=1)
ma2_color  = input(#fb9800,      "",      inline="MA #2", group="MA Ribbon")

show_ma3   = input(false,        "MA #3", inline="MA #3", group="MA Ribbon")
ma3_type   = input.string("SMA", "",      inline="MA #3", group="MA Ribbon", options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"])
ma3_source = input(close,        "",      inline="MA #3", group="MA Ribbon")
ma3_length = input.int(100,      "",      inline="MA #3", group="MA Ribbon", minval=1)
ma3_color  = input(#fb6500,      "",      inline="MA #3", group="MA Ribbon")

show_ma4   = input(false,        "MA #4", inline="MA #4", group="MA Ribbon")
ma4_type   = input.string("SMA", "",      inline="MA #4", group="MA Ribbon", options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"])
ma4_source = input(close,        "",      inline="MA #4", group="MA Ribbon")
ma4_length = input.int(200,      "",      inline="MA #4", group="MA Ribbon", minval=1)
ma4_color  = input(#f60c0c,      "",      inline="MA #4", group="MA Ribbon")

// ─── LINREG LINE ──────────────────────────────────────────────────────────────
bclose      = lin_reg ? ta.linreg(close, linreg_length, 0) : close
signal      = sma_signal ? ta.sma(bclose, signal_length) : ta.ema(bclose, signal_length)
signalColor = signal > signal[1] ? color.new(color.lime, 0) : color.new(color.red, 0)

plot(showLinReg ? bclose : na, title="Linear Regression", color=color.rgb(245, 245, 245, 100), linewidth=1)
plot(showSignal ? signal : na, title="Signal",            color=signalColor,                    linewidth=2)

// ─── RSI CANDLE COLOR ─────────────────────────────────────────────────────────
rsi    = ta.rsi(close, rsiLen)
rsiSma = ta.sma(rsi, smaLen)

var bool isBullish = false
if ta.crossover(rsi, rsiSma)
    isBullish := true
if ta.crossunder(rsi, rsiSma)
    isBullish := false

barcolor(isBullish ? color.lime : color.red)

// ─── SESSION VWAP (purple) ────────────────────────────────────────────────────
plot(showDaily ? ta.vwap(hlc3) : na, title="Session VWAP",
     color=color.new(#9C27B0, 0), linewidth=2)

// ─── STD DEV BANDS ────────────────────────────────────────────────────────────
var float sumPV  = 0.0
var float sumVol = 0.0
var float sumPV2 = 0.0

if session.isfirstbar
    sumPV  := 0.0
    sumVol := 0.0
    sumPV2 := 0.0

sumPV  += hlc3 * volume
sumVol += volume
sumPV2 += hlc3 * hlc3 * volume

vwapVal  = sumPV  / sumVol
variance = math.max(sumPV2 / sumVol - vwapVal * vwapVal, 0)
stdev    = math.sqrt(variance)

u1 = plot(showBands ? vwapVal + bandMult1 * stdev : na, title="Upper Band 1", color=color.new(color.white, 70), linewidth=1)
l1 = plot(showBands ? vwapVal - bandMult1 * stdev : na, title="Lower Band 1", color=color.new(color.white, 70), linewidth=1)
u2 = plot(showBands ? vwapVal + bandMult2 * stdev : na, title="Upper Band 2", color=color.new(color.white, 80), linewidth=1, style=plot.style_circles)
l2 = plot(showBands ? vwapVal - bandMult2 * stdev : na, title="Lower Band 2", color=color.new(color.white, 80), linewidth=1, style=plot.style_circles)

fill(u1, l1, color=color.new(color.white, 95))
fill(u2, u1, color=color.new(color.red,   97))
fill(l1, l2, color=color.new(color.lime,  97))

// ─── SUPERTREND ───────────────────────────────────────────────────────────────
[stLine, stDir] = ta.supertrend(atrMult, atrLen)

isBull = stDir < 0
isBear = stDir > 0

bullFlip = isBull and not isBull[1]
bearFlip = isBear and not isBear[1]

var int lastBuyBar  = na
var int lastSellBar = na

buyReady  = na(lastBuyBar)  or bar_index - lastBuyBar  > cooldown
sellReady = na(lastSellBar) or bar_index - lastSellBar > cooldown

buySignal  = showST and bullFlip and buyReady
sellSignal = showST and bearFlip and sellReady

if buySignal
    lastBuyBar  := bar_index
if sellSignal
    lastSellBar := bar_index

plotshape(buySignal,  title="Buy",  location=location.belowbar,
     style=shape.triangleup,   size=size.small,
     color=color.new(bullCol, 0))

plotshape(sellSignal, title="Sell", location=location.abovebar,
     style=shape.triangledown, size=size.small,
     color=color.new(bearCol, 0))

// ─── MA RIBBON ────────────────────────────────────────────────────────────────
ma1 = show_ma1 ? ma(ma1_source, ma1_length, ma1_type) : na
ma2 = show_ma2 ? ma(ma2_source, ma2_length, ma2_type) : na
ma3 = show_ma3 ? ma(ma3_source, ma3_length, ma3_type) : na
ma4 = show_ma4 ? ma(ma4_source, ma4_length, ma4_type) : na

plot(ma1, "MA #1", ma1_color, display=show_ma1 ? display.all : display.none)
plot(ma2, "MA #2", ma2_color, display=show_ma2 ? display.all : display.none)
plot(ma3, "MA #3", ma3_color, display=show_ma3 ? display.all : display.none)
plot(ma4, "MA #4", ma4_color, display=show_ma4 ? display.all : display.none)

// ─── HHLL ─────────────────────────────────────────────────────────────────────
srcHigh = hhllSrc == "High/Low" ? high : close
srcLow  = hhllSrc == "High/Low" ? low  : close

pivotHigh = ta.pivothigh(srcHigh, zigzagLen, zigzagLen)
pivotLow  = ta.pivotlow(srcLow,  zigzagLen, zigzagLen)

var float lastHigh = na
var float prevHigh = na
var float lastLow  = na
var float prevLow  = na

if not na(pivotHigh)
    prevHigh := lastHigh
    lastHigh := pivotHigh

if not na(pivotLow)
    prevLow := lastLow
    lastLow := pivotLow

isHH = not na(pivotHigh) and not na(prevHigh) and pivotHigh > prevHigh
isLH = not na(pivotHigh) and not na(prevHigh) and pivotHigh < prevHigh
isHL = not na(pivotLow)  and not na(prevLow)  and pivotLow  > prevLow
isLL = not na(pivotLow)  and not na(prevLow)  and pivotLow  < prevLow

if showHHLL and not na(pivotHigh)
    labelText = isHH ? "HH" : isLH ? "LH" : "High"
    labelCol  = isHH ? color.new(upColHHLL, 0) : color.new(dnColHHLL, 0)
    label.new(bar_index[zigzagLen], pivotHigh,
         text=labelText, color=labelCol,
         textcolor=color.white,
         style=label.style_label_down,
         size=size.small)

if showHHLL and not na(pivotLow)
    labelText = isHL ? "HL" : isLL ? "LL" : "Low"
    labelCol  = isHL ? color.new(upColHHLL, 0) : color.new(dnColHHLL, 0)
    label.new(bar_index[zigzagLen], pivotLow,
         text=labelText, color=labelCol,
         textcolor=color.white,
         style=label.style_label_up,
         size=size.small)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(buySignal,  "Supertrend Buy",  "ST — Bullish flip")
alertcondition(sellSignal, "Supertrend Sell", "ST — Bearish flip")
alertcondition(isHH, "Higher High", "HHLL — Higher High formed")
alertcondition(isLH, "Lower High",  "HHLL — Lower High formed")
alertcondition(isHL, "Higher Low",  "HHLL — Higher Low formed")
alertcondition(isLL, "Lower Low",   "HHLL — Lower Low formed")
````
