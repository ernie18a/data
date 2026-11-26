# Pymander's MA Suite

- url: https://www.tradingview.com/script/J50LbAnZ-Pymander-s-MA-Suite/
- type: indicator
- pine_id: PUB;350d3375e1cd48519f57394a530dd163
- version: 1.0

## Description

Pymander's MA Suite is a versatile and all-in-one toolkit designed to give you total control over your trend analysis. Whether you’re a scalper looking for quick crossovers or a swing trader tracking long-term trends, this suite is built to be the only moving average indicator you’ll ever need.

What makes it unique?
Unlike standard MA ribbons that lock you into one type of calculation, EZ MA Suite gives you 5 fully independent slots. You can mix and match different lengths, sources, and—most importantly—12 different MA types in a single indicator. We’ve also cleaned up the visuals with "premium" signal placement and modern icons so your chart stays professional and clutter-free.

The Powerhouse MA Selection
You have access to a massive library of moving averages to fit any strategy:

The Classics: SMA, EMA, WMA, RMA, VWMA.
The Smooth & Fast: HMA (Hull), ALMA (Arnaud Legoux), and LSMA (Least Squares).
The Lag-Killers: DEMA (Double), TEMA (Triple), and ZLEMA (Zero Lag).
The Adaptive: KAMA (Kaufman), which adjusts itself based on market noise!

Stay on the Right Side of the Move
We’ve integrated a smart Buy/Sell Signal engine based on crossovers. You simply pick which of your 5 MAs is the "Fast" one and which is the "Slow" one.

But here’s the game-changer: The Trend Filter.
To help you avoid "choppy" fakeouts, you can enable a trend filter using a third MA (like a 200 SMA). When active, the suite will only show Buy signals if you're in an uptrend and Sell signals if you're in a downtrend. It’s all about keeping you aligned with the "big money" flow!

💬 We want to hear from you!
I built this to make our trading lives easier, but I’d love to know how you’re using it. Do you have a favorite MA combination? Is there a specific feature you’d like to see next? Drop your feedback and let’s keep improving this suite together!

Wishing you all lots of luck and many, many green days!! 

— Pymander

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ 
// © LuxAlgo

//@version=6
indicator("Pymander's MA Suite", "EZ MA Suite", overlay = true, max_lines_count = 500, max_labels_count = 500)

// --- Constants ---
var string SMA   = "SMA"
var string EMA   = "EMA"
var string WMA   = "WMA"
var string RMA   = "RMA"
var string VWMA  = "VWMA"
var string HMA   = "HMA"
var string ALMA  = "ALMA"
var string LSMA  = "LSMA"
var string DEMA  = "DEMA"
var string TEMA  = "TEMA"
var string KAMA  = "KAMA"
var string ZLEMA = "ZLEMA"

// --- Functions ---
zlema(src, len) =>
    int lag = math.floor((len - 1) / 2)
    float data = src + (src - src[lag])
    ta.ema(data, len)

dema(src, len) =>
    float e1 = ta.ema(src, len)
    2 * e1 - ta.ema(e1, len)

tema(src, len) =>
    float e1 = ta.ema(src, len)
    float e2 = ta.ema(e1, len)
    float e3 = ta.ema(e2, len)
    3 * (e1 - e2) + e3

kama(src, len) =>
    float er = math.abs(src - src[len]) / math.sum(math.abs(src - src[1]), len)
    float sc = math.pow(er * (2.0 / 3.0 - 2.0 / 31.0) + 2.0 / 31.0, 2)
    float kamaVal = 0.0
    kamaVal := nz(kamaVal[1]) + sc * (src - nz(kamaVal[1]))
    kamaVal

getMA(type, src, len) =>
    switch type
        SMA   => ta.sma(src, len)
        EMA   => ta.ema(src, len)
        WMA   => ta.wma(src, len)
        RMA   => ta.rma(src, len)
        VWMA  => ta.vwma(src, len)
        HMA   => ta.hma(src, len)
        ALMA  => ta.alma(src, len, 0.85, 6)
        LSMA  => ta.linreg(src, len, 0)
        DEMA  => dema(src, len)
        TEMA  => tema(src, len)
        KAMA  => kama(src, len)
        ZLEMA => zlema(src, len)
        => na

// --- Inputs ---
// Group 1
ma1_On      = input.bool(true, "Moving Average 1", inline = "ma1", group = "MA 1 Settings")
ma1_Type    = input.string(SMA, "", options = [SMA, EMA, WMA, RMA, VWMA, HMA, ALMA, LSMA, DEMA, TEMA, KAMA, ZLEMA], inline = "ma1", group = "MA 1 Settings")
ma1_Len     = input.int(20, "", minval = 1, inline = "ma1", group = "MA 1 Settings")
ma1_Src     = input.source(close, "", inline = "ma1", group = "MA 1 Settings")
ma1_Col     = input.color(#5b9cf6, "", inline = "ma1", group = "MA 1 Settings")

// Group 2
ma2_On      = input.bool(true, "Moving Average 2", inline = "ma2", group = "MA 2 Settings")
ma2_Type    = input.string(EMA, "", options = [SMA, EMA, WMA, RMA, VWMA, HMA, ALMA, LSMA, DEMA, TEMA, KAMA, ZLEMA], inline = "ma2", group = "MA 2 Settings")
ma2_Len     = input.int(50, "", minval = 1, inline = "ma2", group = "MA 2 Settings")
ma2_Src     = input.source(close, "", inline = "ma2", group = "MA 2 Settings")
ma2_Col     = input.color(#e91e63, "", inline = "ma2", group = "MA 2 Settings")

// Group 3
ma3_On      = input.bool(false, "Moving Average 3", inline = "ma3", group = "MA 3 Settings")
ma3_Type    = input.string(SMA, "", options = [SMA, EMA, WMA, RMA, VWMA, HMA, ALMA, LSMA, DEMA, TEMA, KAMA, ZLEMA], inline = "ma3", group = "MA 3 Settings")
ma3_Len     = input.int(100, "", minval = 1, inline = "ma3", group = "MA 3 Settings")
ma3_Src     = input.source(close, "", inline = "ma3", group = "MA 3 Settings")
ma3_Col     = input.color(#ff9800, "", inline = "ma3", group = "MA 3 Settings")

// Group 4
ma4_On      = input.bool(false, "Moving Average 4", inline = "ma4", group = "MA 4 Settings")
ma4_Type    = input.string(SMA, "", options = [SMA, EMA, WMA, RMA, VWMA, HMA, ALMA, LSMA, DEMA, TEMA, KAMA, ZLEMA], inline = "ma4", group = "MA 4 Settings")
ma4_Len     = input.int(200, "", minval = 1, inline = "ma4", group = "MA 4 Settings")
ma4_Src     = input.source(close, "", inline = "ma4", group = "MA 4 Settings")
ma4_Col     = input.color(#4caf50, "", inline = "ma4", group = "MA 4 Settings")

// Group 5
ma5_On      = input.bool(false, "Moving Average 5", inline = "ma5", group = "MA 5 Settings")
ma5_Type    = input.string(SMA, "", options = [SMA, EMA, WMA, RMA, VWMA, HMA, ALMA, LSMA, DEMA, TEMA, KAMA, ZLEMA], inline = "ma5", group = "MA 5 Settings")
ma5_Len     = input.int(500, "", minval = 1, inline = "ma5", group = "MA 5 Settings")
ma5_Src     = input.source(close, "", inline = "ma5", group = "MA 5 Settings")
ma5_Col     = input.color(#9c27b0, "", inline = "ma5", group = "MA 5 Settings")

// Signals
showSignals = input.bool(true, "Show Crossover Signals", group = "Signal Settings")
fastIdx     = input.int(1, "Fast MA Index", minval = 1, maxval = 5, group = "Signal Settings", tooltip = "Select which MA (1-5) to use as the Fast component.")
slowIdx     = input.int(2, "Slow MA Index", minval = 1, maxval = 5, group = "Signal Settings", tooltip = "Select which MA (1-5) to use as the Slow component.")

// Trend Filter
filter_On   = input.bool(false, "Enable Trend Filter", group = "Trend Filter Settings", tooltip = "When enabled, signals only trigger if the Fast MA is in the correct trend relative to the Filter MA.")
filter_Idx  = input.int(4, "Filter MA Index", minval = 1, maxval = 5, group = "Trend Filter Settings", tooltip = "Select which MA (1-5) to use as the Trend Filter (e.g., a 200 SMA).")

bullCol     = input.color(#089981, "Bullish Signal Color", group = "Style Settings")
bearCol     = input.color(#f23645, "Bearish Signal Color", group = "Style Settings")

// --- Calculations ---
val1 = ma1_On ? getMA(ma1_Type, ma1_Src, ma1_Len) : na
val2 = ma2_On ? getMA(ma2_Type, ma2_Src, ma2_Len) : na
val3 = ma3_On ? getMA(ma3_Type, ma3_Src, ma3_Len) : na
val4 = ma4_On ? getMA(ma4_Type, ma4_Src, ma4_Len) : na
val5 = ma5_On ? getMA(ma5_Type, ma5_Src, ma5_Len) : na

getVal(idx) =>
    switch idx
        1 => val1
        2 => val2
        3 => val3
        4 => val4
        5 => val5
        => na

fastVal   = getVal(fastIdx)
slowVal   = getVal(slowIdx)
filterVal = getVal(filter_Idx)

// Trend Logic
trendBull = not filter_On or (fastVal > filterVal)
trendBear = not filter_On or (fastVal < filterVal)

crossUp   = ta.crossover(fastVal, slowVal) and trendBull
crossDown = ta.crossunder(fastVal, slowVal) and trendBear

// --- Visuals ---
plot(val1, "MA 1", ma1_Col, 2, plot.style_linebr)
plot(val2, "MA 2", ma2_Col, 2, plot.style_linebr)
plot(val3, "MA 3", ma3_Col, 2, plot.style_linebr)
plot(val4, "MA 4", ma4_Col, 2, plot.style_linebr)
plot(val5, "MA 5", ma5_Col, 2, plot.style_linebr)

plotshape(showSignals and crossUp, "Bullish Signal", shape.xcross, location.belowbar, bullCol, size = size.small, text = "BUY", textcolor = bullCol)
plotshape(showSignals and crossDown, "Bearish Signal", shape.xcross, location.abovebar, bearCol, size = size.small, text = "SELL", textcolor = bearCol)
````
