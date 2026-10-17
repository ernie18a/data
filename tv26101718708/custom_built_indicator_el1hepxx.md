# Custom Built Indicator

- url: https://www.tradingview.com/script/El1hepXx-Custom-Built-Indicator/
- type: indicator
- pine_id: PUB;4afcb3c601dd4baea7980192ffb93f4f
- version: 1.0

## Description

Custom Built Indicator | MisinkoMaster

Trading is often viewed as a purely mathematical or technical discipline, but the truth is that successful trading requires immense creativity. There are thousands of brilliant traders who have incredible, unique structural concepts in their minds but feel held back because they do not know how to write code. The Custom Built Indicator (CBI) was created to bridge that gap.

This indicator acts as a blank, programmable canvas designed to unlock your inner quantitative designer. It is a fully modular trading framework that allows you to build, test, and personalize your own technical systems without touching a single line of code. By giving you absolute control over the baseline foundation, the volatility wrapper, the smoothing layer, and the conditional trend logic, CBI makes algorithmic design accessible to everyone. Think of it as trading art—a sandbox where you can bring your most detailed visual concepts to life, spark your curiosity, and perhaps even inspire you to take your first steps into learning Pine Script development.

How It Works: The Modular Sandbox

Instead of trapping you inside a single, rigid formula, CBI breaks down technical analysis into five independent, hot-swapping algorithmic layers:

    Baseline Settings: This establishes the gravitational core of your asset's price action. You can set this baseline using standard moving averages, advanced low-lag options, mathematical centerpoints like the median or statistical mode, or even a pure historical price offset.

    Volatility Settings: This dictates how your system measures market expansion and compression. You can wrap your baseline using standard range tools, pure standard deviation, or robust absolute deviation models to map out precise market extremes.

    Smoothing Settings: A unique layer that allows you to smooth out the upper and lower boundary bands independently of the central baseline. Applying secondary smoothing allows you to create highly tailored, fluid bands that conform uniquely to market noise.

    Trend Logic Settings: The brain of your strategy. Here, you decide exactly what constitutes a market regime shift. You can define trend conditions based on price breaking the outer channels, crossing the baseline, or even pure momentum acceleration.

    Confirmation Filters: To minimize false signals, you can apply secondary algorithmic checks—such as volume verification, rate of change agreement, or candle validation—before any structural trend shift is confirmed.

An Ocean of Creative Possibilities

To understand just how massive this sandbox is, we can calculate the exact number of unique logical setups available. If we completely ignore all numerical values (like lookback periods or band multipliers) and only look at the dropdown menus, the sheer volume of structural combinations is staggering:

    Baseline Type: 11 options

    Volatility Type: 5 options

    Upper Band Smoothing Type: 11 options

    Lower Band Smoothing Type: 11 options

    Long Signal Logic: 3 options

    Short Signal Logic: 3 options

    Confirmation Type: 4 options

The Custom Built Indicator provides exactly 239,580 unique, without numerical inputs, meaning everyone will have a completely unique layout that fits them and their style.

When you factor in that the crossover and crossunder source inputs can also be independently assigned to any price data point, the mathematical possibilities soar into the millions. Every single trader can find, name, and perfect a structural footprint that is entirely their own.

Key System Features

    On-Chart Canvas Synchronization: The system automatically tracks your custom logical state and dynamically projects it back onto the screen, shifting candle colors and painting custom visual envelopes to represent your unique market regime.

    Asymmetric Modeling: Because the upper and lower multipliers and smoothing options are completely separated, you can build asymmetric strategies—such as tight, highly sensitive upper boundaries for fast momentum breakouts combined with wide, volatile lower boundaries to catch major macroscopic market drops.

    Forward-Looking Integration: The conditional logic allows you to experiment with advanced structural confirmations, such as requiring two consecutive breakout bars or demanding expanding volume before confirming a trend pivot.

Input Parameters Layout

General & Baseline Settings

    Source: The primary price feed running into your system core.

    Baseline Type & Lookback: Chooses the foundational trend line, offering options ranging from traditional SMA, EMA, and WMA, to advanced zero-lag options like TEMA, HMA, ALMA, or statistical Mode and Median.

Volatility & Smoothing Settings

    Volatility Type & Lookback: Defines the range measurement matrix (Average True Range, Median True Range, Standard Deviation, Mean Absolute Deviation, or Median Absolute Deviation).

    Upper & Lower Multipliers: Independently scales the distance of the bands from the baseline.

    Additional Smoothing Type & Lookback: Provides an extra filtering pass specifically for the outer bands to eliminate jagged lines and smooth out execution zones.

Trend Logic Settings

    Crossover/Crossunder Source: Selects the specific price sources required to breach the upper and lower boundaries.

    Long/Short Signal Logic: Sets the core activation condition (breaking bands, crossing the baseline, or tracking positive/negative rate of change).

    Confirmation Type: Applies an optional secondary validation layer (Volume, Baseline ROC, or Extra Bar validation).

Embrace the Art of Strategy Design

The ultimate goal of the Custom Built Indicator is to prove that technical analysis doesn't have to be rigid or intimidating. It is a playground for your ideas. Load it onto your chart, test out your most unconventional theories, mix architectures that traditional packages keep separate, and discover what works for your unique visual style. If you find a combination that speaks to you, use that spark to look under the hood—because the journey from clicking options to writing your own custom scripts is much shorter than you think.

Disclaimer: Trading financial markets involves high risk. This technical script is designed as an educational and informational tool to support your rule-based mechanical execution system and does not constitute financial advice.

[b]
Final Note: If you find any bugs, errors, contact me either through DMs or in the comments, and I will fix them and update the script.[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MisinkoMaster

//@version=6
indicator("Custom Built Indicator", "CBI | MisinkoMaster", overlay = true, behind_chart = false)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Import Libraries
import TradingView/ta/13
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Group
gs = "General Settings"
bsg = "Baseline Settings"
vs = "Volatility Settings"
ss = "Smoothing Settings"
tls = "Trend Logic Settings"
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Get User Defined Inputs
src = input.source(close, "Source", group = gs)

baseline_type = input.string("EMA", "Baseline Type",
     options = ["RMA", "SMA", "EMA", "DEMA", "TEMA", "WMA", "HMA", "ALMA", "Median", "Mode", "Previous Source"],
     group = bsg)
baseline_len = input.int(14, "Baseline Lookback", step = 1, minval = 2,
     group = bsg)

volatility_type = input.string("Average TR", "Volatility Type",
     options = ["Average TR", "Median True Range", "Standard Deviation", "Mean Absolute Deviation",
     "Median Absolute Deviation"],
     group = vs)
volatility_len = input.int(14, "Volatility Lookback", step = 1, minval = 2,
     group = vs)

upper_multiplier = input.float(2.25, "Upper Band Multiplier", step = 0.05, minval = 0,
     group = vs)
lower_multiplier = input.float(1.75, "Lower Band Multiplier", step = 0.05, minval = 0,
     group = vs)

extra_smoothing_u = input.string("None", "Use Additional Smoothing For Upper Band?",
     options = ["None", "RMA", "SMA", "EMA", "DEMA", "TEMA", "WMA", "HMA", "ALMA", "Median", "Mode"],
     group = ss)
extra_smoothing_l = input.string("None", "Use Additional Smoothing For Lower Band?",
     options = ["None", "RMA", "SMA", "EMA", "DEMA", "TEMA", "WMA", "HMA", "ALMA", "Median", "Mode"],
     group = ss)
extra_smoothing_len = input.int(7, "Extra Smoothing Lookback", step = 1, minval = 1,
     group = ss)

crossover_source = input.source(close, "Crossover Source",
     tooltip = "The source that needs to cross the Upper Band in order to trigger a long signal.",
     group = tls)
crossunder_source = input.source(close, "Crossunder Source",
     tooltip = "The source that needs to cross the Lower Band in order to trigger a short signal.",
     group = tls)

long_signal = input.string("Source > Upper", "Long Signal Logic",
     options = ["Source > Upper", "Source > Baseline", "+ ROC Baseline"],
     group = tls)
short_signal = input.string("Source < Lower", "Short Signal Logic",
     options = ["Source < Lower", "Source < Baseline", "- ROC Baseline"],
     group = tls)

confirmation_type = input.string("None", "Confirmation?",
     options = ["None", "Volume", "Baseline ROC", "Extra Bar"],
     group = tls)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Calculations

//Baseline
baseline = switch baseline_type
    "RMA" => ta.rma(src, baseline_len)
    "SMA" => ta.rma(src, baseline_len)
    "EMA" => ta.rma(src, baseline_len)
    "DEMA" => ta.rma(src, baseline_len)
    "TEMA" => ta.rma(src, baseline_len)
    "WMA" => ta.rma(src, baseline_len)
    "HMA" => ta.rma(src, baseline_len)
    "ALMA" => ta.alma(src, baseline_len, 0.85, 6)
    "Median" => ta.median(src, baseline_len)
    "Mode" => ta.mode(src, baseline_len)
    "Previous Source" => src[1]

//Volatility
sma = ta.sma(src, volatility_len)
mad = 0.0
for i = 0 to volatility_len-1
    mad += math.abs(src[i] - sma)
mad := mad/volatility_len

med = ta.median(src, volatility_len)
mead = 0.0
for i = 0 to volatility_len-1
    mead += math.abs(src[i] - med)
mead := mead/volatility_len

volatility = switch volatility_type
    "Average TR" => ta.atr(volatility_len)
    "Median TR" => ta.median(ta.tr(true), volatility_len)
    "Standard Deviation" => ta.stdev(src, volatility_len)
    "Mean Absolute Deviation" => mad
    "Median Absolute Deviation" => mead

//Band Construction
upperband_ = baseline+volatility*upper_multiplier
lowerband_ = baseline-volatility*lower_multiplier

upperband = switch extra_smoothing_u
    "None" => upperband_
    "RMA" => ta.rma(upperband_, extra_smoothing_len)
    "SMA" => ta.sma(upperband_, extra_smoothing_len)
    "EMA" => ta.ema(upperband_, extra_smoothing_len)
    "DEMA" => ta.dema(upperband_, extra_smoothing_len)
    "TEMA" => ta.tema(upperband_, extra_smoothing_len)
    "WMA" => ta.wma(upperband_, extra_smoothing_len)
    "HMA" => ta.hma(upperband_, extra_smoothing_len)
    "ALMA" => ta.alma(upperband_, extra_smoothing_len, 0.85, 6)
    "Median" => ta.median(upperband_, extra_smoothing_len)
    "Mode" => ta.mode(upperband_, extra_smoothing_len)

lowerband = switch extra_smoothing_l
    "None" => lowerband_
    "RMA" => ta.rma(lowerband_, extra_smoothing_len)
    "SMA" => ta.sma(lowerband_, extra_smoothing_len)
    "EMA" => ta.ema(lowerband_, extra_smoothing_len)
    "DEMA" => ta.dema(lowerband_, extra_smoothing_len)
    "TEMA" => ta.tema(lowerband_, extra_smoothing_len)
    "WMA" => ta.wma(lowerband_, extra_smoothing_len)
    "HMA" => ta.hma(lowerband_, extra_smoothing_len)
    "ALMA" => ta.alma(lowerband_, extra_smoothing_len, 0.85, 6)
    "Median" => ta.median(lowerband_, extra_smoothing_len)
    "Mode" => ta.mode(lowerband_, extra_smoothing_len)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Trend Logic

//Base Conditions
long_ = switch long_signal
    "Source > Upper" => crossover_source > upperband
    "Source > Baseline" => crossover_source > baseline
    "+ ROC Baseline" => baseline > baseline[1]

short_ = switch short_signal
    "Source < Lower" => crossunder_source < lowerband
    "Source < Baseline" => crossunder_source < baseline
    "- ROC Baseline" => baseline < baseline[1]

//Confirmations
conf_long = switch confirmation_type
    "None" => true
    "Volume" => volume > volume[1]
    "Baseline ROC" => baseline > baseline[1]
    "Extra Bar" => long_[1] == true and long_ == true

conf_short = switch confirmation_type
    "None" => true
    "Volume" => volume < volume[1]
    "Baseline ROC" => baseline < baseline[1]
    "Extra Bar" => short_[1] == true and short_ == true

//Final Evaluation
long = long_ and conf_long
short = short_ and conf_short

var trend = 0
if long and not short
    trend := 1
if short
    trend := -1
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Plotting
upSeries   = trend == 1  ? lowerband : na
downSeries = trend == -1 ? upperband : na

a = plot(upSeries,   "Upper", color = color.rgb(0, 255, 187), style = plot.style_linebr)
b = plot(downSeries, "Lower", color = color.rgb(255, 0, 157), style = plot.style_linebr)
c = plot(src, display = display.none, editable = false)

fill(a, c, color.rgb(0, 255, 187, 50))
fill(b, c, color.rgb(255, 0, 157, 50))

plotshape(trend > trend[1] ? upSeries : na, style = shape.diamond, location = location.absolute, size = size.normal, color = color.rgb(0, 255, 187, 50))
plotshape(trend < trend[1] ? downSeries : na, style = shape.diamond,location = location.absolute, size = size.normal,color = color.rgb(255, 0, 157, 50))
plotshape(trend > trend[1] ? upSeries : na, style = shape.diamond, location = location.absolute, size = size.small, color = color.rgb(0, 255, 187, 25))
plotshape(trend < trend[1] ? downSeries : na, style = shape.diamond,location = location.absolute, size = size.small,color = color.rgb(255, 0, 157, 25))
plotshape(trend > trend[1] ? upSeries : na, style = shape.diamond, location = location.absolute, size = size.tiny, color = color.rgb(0, 255, 187))
plotshape(trend < trend[1] ? downSeries : na, style = shape.diamond,location = location.absolute, size = size.tiny,color = color.rgb(255, 0, 157))

col = trend == 1 ? color.rgb(0, 255, 187) : trend == -1 ? color.rgb(255, 0, 157) : color.rgb(72, 72, 72)
plotcandle(open, high, low, close, color = col, wickcolor = col, bordercolor = col)
````
