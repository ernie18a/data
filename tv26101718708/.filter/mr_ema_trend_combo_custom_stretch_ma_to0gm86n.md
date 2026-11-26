# MR + EMA Trend Combo - Custom Stretch MA

- url: https://www.tradingview.com/script/to0gm86N-MR-EMA-Trend-Combo-Custom-Stretch-MA/
- type: indicator
- pine_id: PUB;c1e7b919c2cb4c16bc61a607b18932a2
- version: 1.0

## Description

Identifies potential long and short signals using Z score mean reversion, MA crossover to identify trend and stretch from MA to identify outlying events

## Source Code

````pine
//@version=6
indicator("MR + EMA Trend Combo - Custom Stretch MA", overlay=true, max_labels_count=500)

//============================================================
// Display
//============================================================

showMRShapes       = input.bool(true,  "Show MR Triggers", group="Display")
showEMAStuff       = input.bool(true,  "Show EMA Lines & Fill", group="Display")
showStretchMarkers = input.bool(false, "Show Stretch Markers", group="Display")
showStretchMAs     = input.bool(false, "Show Stretch MAs", group="Display")

//============================================================
// MR Reversion
//============================================================

lenMean = input.int(
     30,
     "Z-Score Mean Length",
     minval=1,
     tooltip="EMA length used in the Z-Score mean.",
     group="Mean Reversion"
)

longWeakZThreshold = input.float(
     0.6,
     "Long Weak Z Threshold",
     minval=0.1,
     step=0.1,
     group="Mean Reversion"
)

longStrongZThreshold = input.float(
     1.8,
     "Long Strong Z Threshold",
     minval=0.1,
     step=0.1,
     group="Mean Reversion"
)

shortWeakZThreshold = input.float(
     1.0,
     "Short Weak Z Threshold",
     minval=0.1,
     step=0.1,
     group="Mean Reversion"
)

shortStrongZThreshold = input.float(
     2.2,
     "Short Strong Z Threshold",
     minval=0.1,
     step=0.1,
     group="Mean Reversion"
)

hl = 20
zSmooth = 3

f_safediv(a, b) =>
    a / (b == 0.0 ? 1e-12 : b)

srcMR = close
maMR = ta.ema(srcMR, lenMean)

var float ewmaMean = na
var float ewmaVar = na

alpha = 1.0 - math.exp(-math.log(2) / hl)

ewmaMean := na(ewmaMean) ? srcMR : ewmaMean + alpha * (srcMR - ewmaMean)

devEW = srcMR - ewmaMean

ewmaVar := na(ewmaVar) ? devEW * devEW : (1 - alpha) * ewmaVar + alpha * devEW * devEW

ewmaStd = math.sqrt(math.max(ewmaVar, 1e-12))

zRaw = f_safediv(srcMR - maMR, math.max(ewmaStd, 1e-8))
z = ta.ema(zRaw, zSmooth)

//============================================================
// Weak / Strong MR Logic
//============================================================

// Long MR trigger:
// Previous Z was below the long weak threshold,
// and Z now has a pivot low.
longCondCore =
     bar_index >= 2 and
     z[1] <= -longWeakZThreshold and
     not na(ta.pivotlow(z, 1, 1))

// Short MR trigger:
// Previous Z was above the short weak threshold,
// and Z now has a pivot high.
shortCondCore =
     bar_index >= 2 and
     z[1] >= shortWeakZThreshold and
     not na(ta.pivothigh(z, 1, 1))

longStrong =
     longCondCore and
     z[1] <= -longStrongZThreshold

longWeak =
     longCondCore and
     not longStrong

shortStrong =
     shortCondCore and
     z[1] >= shortStrongZThreshold

shortWeak =
     shortCondCore and
     not shortStrong

mrLong =
     longWeak or
     longStrong

mrShort =
     shortWeak or
     shortStrong

plotshape(
     showMRShapes and longWeak,
     title="MR Long Weak",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.tiny,
     color=color.rgb(144, 238, 144),
     text="W",
     textcolor=color.black
)

plotshape(
     showMRShapes and longStrong,
     title="MR Long Strong",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.tiny,
     color=color.rgb(0, 100, 0),
     text="S",
     textcolor=color.white
)

plotshape(
     showMRShapes and shortWeak,
     title="MR Short Weak",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.tiny,
     color=color.rgb(255, 160, 160),
     text="W",
     textcolor=color.white
)

plotshape(
     showMRShapes and shortStrong,
     title="MR Short Strong",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.tiny,
     color=color.rgb(139, 0, 0),
     text="S",
     textcolor=color.white
)

//============================================================
// EMA Trend Block
//============================================================

shortLen = input.int(
     13,
     "Short EMA Length",
     minval=1,
     group="EMA Trend"
)

longLen = input.int(
     25,
     "Long EMA Length",
     minval=1,
     group="EMA Trend"
)

srcEMA = input.source(
     close,
     "EMA Price Source",
     group="EMA Trend"
)

shortEMA = ta.ema(srcEMA, shortLen)
longEMA = ta.ema(srcEMA, longLen)

trendUp = shortEMA >= longEMA
trendDown = not trendUp

fillColor = trendUp ? color.rgb(26, 147, 246, 20) : color.rgb(255, 152, 0, 20)

pShort = plot(
     showEMAStuff ? shortEMA : na,
     title="Short EMA",
     color=fillColor,
     linewidth=2
)

pLong = plot(
     showEMAStuff ? longEMA : na,
     title="Long EMA",
     color=fillColor,
     linewidth=2
)

fill(
     pShort,
     pLong,
     color=showEMAStuff ? fillColor : na,
     title="EMA Gap Fill"
)

flipUp = ta.crossover(shortEMA, longEMA)
flipDown = ta.crossunder(shortEMA, longEMA)

plotshape(
     showEMAStuff and flipUp,
     title="EMA Up Confirm",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(color.teal, 0),
     size=size.tiny,
     text="UP",
     textcolor=color.white
)

plotshape(
     showEMAStuff and flipDown,
     title="EMA Down Confirm",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(color.red, 0),
     size=size.tiny,
     text="DN",
     textcolor=color.white
)

//============================================================
// Custom MA Helper
//============================================================

f_ma(src, len, maType) =>
    switch maType
        "SMA"  => ta.sma(src, len)
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "RMA"  => ta.rma(src, len)
        "VWMA" => ta.vwma(src, len)
        "HMA"  => ta.hma(src, len)
        => ta.ema(src, len)

//============================================================
// Stretch Override Settings
//============================================================

useStretchOverride = input.bool(
     true,
     "Use Stretch Override",
     group="Stretch Override",
     tooltip="If enabled, an armed MR run can trigger an early stretch signal when price is stretched far enough from the selected custom MA. The MR run remains armed for the later EMA flip."
)

longStretchBelowPct = input.float(
     5.0,
     "Long Stretch Below MA %",
     minval=0.1,
     step=0.25,
     group="Stretch Override"
)

longStretchMAType = input.string(
     "EMA",
     "Long Stretch MA Type",
     options=["SMA", "EMA", "WMA", "RMA", "VWMA", "HMA"],
     group="Stretch Override"
)

longStretchMALen = input.int(
     50,
     "Long Stretch MA Length",
     minval=10,
     step=10,
     group="Stretch Override"
)

shortStretchAbovePct = input.float(
     5.0,
     "Short Stretch Above MA %",
     minval=0.1,
     step=0.25,
     group="Stretch Override"
)

shortStretchMAType = input.string(
     "EMA",
     "Short Stretch MA Type",
     options=["SMA", "EMA", "WMA", "RMA", "VWMA", "HMA"],
     group="Stretch Override"
)

shortStretchMALen = input.int(
     50,
     "Short Stretch MA Length",
     minval=10,
     step=10,
     group="Stretch Override"
)

longStretchMA =
     f_ma(close, longStretchMALen, longStretchMAType)

shortStretchMA =
     f_ma(close, shortStretchMALen, shortStretchMAType)

stretchPriceSource = input.string(
     "Close",
     "Stretch Price Source",
     options=["Close", "Wick"],
     group="Stretch Override",
     tooltip="Close uses candle close. Wick uses low for long stretch and high for short stretch."
)

longStretchPrice =
     stretchPriceSource == "Wick" ? low : close

shortStretchPrice =
     stretchPriceSource == "Wick" ? high : close

longStretch =
     longStretchMA > 0 and
     ((longStretchMA - longStretchPrice) / longStretchMA) * 100.0 >= longStretchBelowPct

shortStretch =
     shortStretchMA > 0 and
     ((shortStretchPrice - shortStretchMA) / shortStretchMA) * 100.0 >= shortStretchAbovePct

plot(
     showStretchMAs ? longStretchMA : na,
     title="Long Stretch MA",
     color=color.new(color.aqua, 0),
     linewidth=2
)

plot(
     showStretchMAs ? shortStretchMA : na,
     title="Short Stretch MA",
     color=color.new(color.orange, 0),
     linewidth=2
)

plotshape(
     showStretchMarkers and longStretch,
     title="Long Stretch Below Custom MA",
     style=shape.circle,
     location=location.belowbar,
     color=color.new(color.aqua, 0),
     size=size.tiny,
     text="ST",
     textcolor=color.black
)

plotshape(
     showStretchMarkers and shortStretch,
     title="Short Stretch Above Custom MA",
     style=shape.circle,
     location=location.abovebar,
     color=color.new(color.orange, 0),
     size=size.tiny,
     text="ST",
     textcolor=color.black
)

//============================================================
// Run / Flip / Stretch Logic
//============================================================

var bool inLongRun = false
var bool inShortRun = false
var int longStartIx = na
var int shortStartIx = na

var bool longStretchAlreadyTriggered = false
var bool shortStretchAlreadyTriggered = false

startLongRun =
     mrLong and trendDown

startShortRun =
     mrShort and trendUp

if startLongRun
    inLongRun := true
    longStartIx := bar_index
    longStretchAlreadyTriggered := false

if startShortRun
    inShortRun := true
    shortStartIx := bar_index
    shortStretchAlreadyTriggered := false

greenFlipSignal =
     inLongRun and
     flipUp

redFlipSignal =
     inShortRun and
     flipDown

greenStretchSignal =
     useStretchOverride and
     inLongRun and
     not longStretchAlreadyTriggered and
     longStretch

redStretchSignal =
     useStretchOverride and
     inShortRun and
     not shortStretchAlreadyTriggered and
     shortStretch

// Stretch signals are early signals only.
// They do NOT clear the MR run.
// This allows the later EMA flip signal to still fire.
if greenStretchSignal
    longStretchAlreadyTriggered := true

if redStretchSignal
    shortStretchAlreadyTriggered := true

// EMA flip is the final confirmation.
// It clears the armed MR run.
if greenFlipSignal
    inLongRun := false
    longStartIx := na
    longStretchAlreadyTriggered := false

if redFlipSignal
    inShortRun := false
    shortStartIx := na
    shortStretchAlreadyTriggered := false

longDotCond =
     inLongRun and
     trendDown and
     not na(longStartIx) and
     bar_index > longStartIx

shortDotCond =
     inShortRun and
     trendUp and
     not na(shortStartIx) and
     bar_index > shortStartIx

//============================================================
// Final Signal Plots
//============================================================

plotshape(
     greenFlipSignal,
     title="Long EMA Flip Confirmation",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.small,
     color=color.new(color.lime, 0),
     text="BUY",
     textcolor=color.white
)

plotshape(
     greenStretchSignal,
     title="Long ST Stretch Signal",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.small,
     color=color.new(color.aqua, 0),
     text="ST",
     textcolor=color.black
)

plotshape(
     redFlipSignal,
     title="Short EMA Flip Confirmation",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.small,
     color=color.new(color.red, 0),
     text="SELL",
     textcolor=color.white
)

plotshape(
     redStretchSignal,
     title="Short ST Stretch Signal",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.small,
     color=color.new(color.orange, 0),
     text="ST",
     textcolor=color.black
)

//============================================================
// Alerts
//============================================================

alertcondition(
     greenStretchSignal,
     "Long ST Stretch Signal",
     "MR long run triggered by stretch below selected custom MA. MR run remains armed for EMA flip."
)

alertcondition(
     greenFlipSignal,
     "Long EMA Flip Confirmation",
     "MR long run confirmed by EMA flip up."
)

alertcondition(
     redStretchSignal,
     "Short ST Stretch Signal",
     "MR short run triggered by stretch above selected custom MA. MR run remains armed for EMA flip."
)

alertcondition(
     redFlipSignal,
     "Short EMA Flip Confirmation",
     "MR short run confirmed by EMA flip down."
)
````
