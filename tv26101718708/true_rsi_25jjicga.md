# True RSI

- url: https://www.tradingview.com/script/25JJiCGa-True-RSI/
- type: indicator
- pine_id: PUB;2ebf4f47248f46f0b82e236b0d5a13fa
- version: 1.0

## Description

True RSI | MisinkoMaster

The True RSI is a sophisticated reimagining of classical momentum. While the standard Relative Strength Index has served as a cornerstone of technical analysis for decades, it possesses a fundamental limitation: it treats all price movements equally, regardless of the time elapsed since the market made its last major peak or trough. The True RSI solves this structural blind spot by merging price magnitude with temporal trend strength, weighting gains and losses according to their cyclical maturity.

By dynamically scaling price changes against the time-distance of local extremes, this indicator filters out lateral market noise, reduces false overbought and oversold readings during strong trends, and delivers highly responsive execution signals.

How It Works (The Core Architecture)

Instead of relying solely on arithmetic averages of upward and downward price closes, True RSI filters raw market data through a multi-dimensional momentum matrix:

    Temporal Trend Weighting: The algorithm continuously tracks how recently the market has formed local highs and lows. Gains are mathematically weighted against the strength of the upward cycle, while losses are weighted against the strength of the downward cycle.

    Cycle-Weighted Ratio: The accumulated, time-weighted gains and losses are calculated over your lookback period to establish a true relative strength ratio. If gains occur during an actively surging upward cycle, they are heavily amplified; if they occur during a dying trend, they are heavily discounted.

    Smoothing and Normalization: This ratio is translated into a normalized scale bounded between 0 and 100, providing an incredibly smooth yet responsive oscillator curve alongside a secondary momentum velocity histogram.

Key Features

    Time-Weighted Velocity: True RSI prevents premature exhaustion signals during strong, healthy trends because it understands the cyclical age of the current market move.

    On-Chart Candle Morphing: The system automatically tracks the oscillator state and alters the colors of your main price bars to keep you visually aligned with the macro trend.

    Overlay Execution Labels: Prints pristine Long and Short labels directly on your price pane the moment the underlying structural momentum shifts past your designated thresholds.

    Internal Divergence Histogram: Built directly behind the main oscillator is a custom acceleration histogram that monitors the rate of change of the index, pinpointing hidden momentum shifts before they reflect in the price.

Input Parameters & Optimization Guide

    Lookback Period: Controls the baseline window for both the cycle-strength calculations and the price change evaluations. A default of 21 bars balances macro trend stability with immediate short-term utility.

    Long / Short Thresholds: The structural boundaries that dictate trend shifts. By default, crossing above 50 signals a bullish regime, while dropping below 50 initiates a bearish regime.

    Overbought / Oversold Thresholds: Tailored extremes designed to isolate true premium and discount zones. The default 80 and 20 boundaries act as high-probability mean-reversion targets.

Trading Strategies & Execution

    Trend Regime Shift
    When momentum builds structural backing, the indicator updates its trend state:

    A crossing of the True RSI above the Long Threshold triggers a green Long label on the chart, changing candle colors to vibrant green.

    A crossing of the True RSI below the Short Threshold triggers a pink Short label, shifting candle colors to pink.

    Exhaustion Reversals
    Because price movement is weighted against cycle time, entering the overbought (80) or oversold (20) zones represents a market that is genuinely overstretched both in terms of price velocity and time. Reversals from these zones carry high statistical significance for counter-trend scalps or trailing-stop targets.

    Acceleration Divergences
    Watch the central histogram centered around the 50 line. When the price is grinding flat but the histogram starts to rise or fall aggressively, it shows that the internal speed of the True RSI is accelerating. This hidden momentum often foreshadows explosive breakout expansions.

Disclaimer: Trading financial markets involves high risk. This technical script is designed as an informational analytical tool to support your rule-based mechanical execution system and does not constitute financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MisinkoMaster

//@version=6
indicator("True RSI", "True RSI | MisinkoMaster", overlay = false)
/////////////////////////////////////////////////////////////////////
//Import Libaries
import TradingView/ta/13
/////////////////////////////////////////////////////////////////////
//Get User Defined Inputs
src = input.source(close, "Source",
     group = "True RSI | MisinkoMaster")
len = input.int(21, "Lookback Period", step = 1, minval = 2,
     tooltip = "Changes the lookback for the calculation.",
     group = "True RSI | MisinkoMaster")


ut = input.int(50, "Long Treshold", step = 1,
     tooltip = "Changes the Upper Treshold for RSI Longs",
     group = "Tresholds")
lt = input.int(50, "Short Treshold", step = 1,
     tooltip = "Changes the Lower Treshold for RSI Shorts",
     group = "Tresholds")

obt = input.int(80, "Overbought Treshold", step = 1, minval = 55,
     tooltip = "Changes the Overbought Treshold for catching low value zones",
     group = "Tresholds")
ost = input.int(20, "Oversold Treshold", step = 1, maxval = 45,
     tooltip = "Changes the Oversold Treshold for catching high value zones",
     group = "Tresholds")
/////////////////////////////////////////////////////////////////////
//Calculations
[up, dn] = ta.aroon(len)

gain = math.max(src-src[1], 0)
loss = math.abs(math.min(src-src[1], 0))

tg = 0.0
tl = 0.0
for i = 0 to len-1
    tg += gain[i]*up[i]
    tl += loss[i]*dn[i]
tg := tg/len
tl := tl/len

trs = tg/tl
trsi = 100 - 100 / (1+trs)
c = trsi-trsi[1]
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Trend Logic
var trend = 0

L = trsi > ut
S = trsi < lt

if L
    trend := 1
if S
    trend := -1
////////////////////////////////////////////////////////////////////////////////////////////////////
//Plotting
divergence = 50+c

var col = color.rgb(72, 72, 72)
var colT = color.rgb(72, 72, 72, 50)
if trend == 1
    col := color.rgb(0, 255, 187)
    colT := color.rgb(0, 255, 187, 50)
if trend == -1
    col := color.rgb(255, 0, 157)
    colT := color.rgb(255, 0, 157, 50)

var colD = color.rgb(0, 255, 187, 70)
if divergence > 50
    colD := color.rgb(0, 255, 187, 70)
if divergence < 50
    colD := color.rgb(255, 0, 157, 70)

bc = trsi > obt
sc = trsi < ost

plotshape(trend == 1 and trend[1] != 1 ? src : na, style = shape.labelup, location = location.belowbar, size = size.normal, color = color.rgb(0, 255, 187), display = display.pane, force_overlay = true, text = "𝓛𝓸𝓷𝓰", textcolor = color.rgb(7, 114, 86))
plotshape(trend == -1 and trend[1] != -1 ? src : na, style = shape.labeldown,location = location.abovebar, size = size.normal,color = color.rgb(255, 0, 157), display = display.pane, force_overlay = true, text = "𝓢𝓱𝓸𝓻𝓽", textcolor = color.rgb(95, 11, 63))

var colOB = trsi > obt ? color.rgb(255, 0, 157, 70) : color.rgb(0, 0, 0, 100)
var colOS = trsi > obt ? color.rgb(255, 0, 157, 70) : color.rgb(0, 0, 0, 100)


bgcolor(colOB, force_overlay = true)
bgcolor(colOB, force_overlay = false)
bgcolor(colOS, force_overlay = true)
bgcolor(colOS, force_overlay = false)

lp = plot(ut, title = "Long Treshhold", color = color.rgb(71, 70, 70), display = display.pane, linewidth = 3)
sp = plot(lt, title = "Short Treshhold", color = color.rgb(71, 70, 70), display = display.pane, linewidth = 3)
obp = plot(obt, title = "OB Treshhold", color = color.rgb(0, 255, 187), display = display.pane, linewidth = 3)
osp = plot(ost, title = "OS Treshhold", color = color.rgb(255, 0, 157), display = display.pane, linewidth = 3)

fill(sp, osp, color.rgb(255, 0, 157, 85))
fill(lp, obp, color.rgb(0, 255, 187, 85))
fill(lp, sp, color.rgb(71, 70, 70, 75))

plotcandle(open, high, low, close, bordercolor = col, color = col, force_overlay = true, display = display.pane)

rsip = plot(trsi, "Self-Correcting RSI | MisinkoMaster", color = col, linewidth = 2)
plot(divergence, "Divergence", color = colD, style = plot.style_histogram, histbase = 50)

fill(rsip, obp, colOB)
fill(rsip, osp, colOS)
````
