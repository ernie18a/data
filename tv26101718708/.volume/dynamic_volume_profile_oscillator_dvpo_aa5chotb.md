# Dynamic Volume Profile Oscillator (DVPO)

- url: https://www.tradingview.com/script/aa5choTB-Dynamic-Volume-Profile-Oscillator-DVPO/
- type: indicator
- pine_id: PUB;6d03fcaee3ab4440a0ca7354a98109d0
- version: 1.0

## Description

[b]WHAT IT DOES[/b]

DVPO is a volume-weighted deviation oscillator. It answers a single question on every bar: how far has price stretched away from the level where most volume has actually traded, measured against how widely volume has been distributed around that level? The result is plotted as a single line oscillating around a 50 midline, with adaptive zones that widen and narrow with the instrument's own behavior instead of relying on fixed thresholds.

[b]WHAT MAKES IT DIFFERENT[/b]

Most oscillators ignore volume, and the few that use it tend to use it loosely. RSI and CCI are built purely on price. MFI uses volume, but only to label each bar as buying or selling pressure before summing it like a volume-weighted RSI. %B and CCI both measure deviation from a mean, but the mean is unweighted and the deviation bands are either fixed (Bollinger) or based on a simple mean absolute deviation (CCI).

[b]DVPO differs on two specific points:[/b]

The reference is a volume-weighted mean, a rolling VWAP over the lookback window, so the "fair value" it measures against is anchored to where trading actually happened, not to a simple price average.
The normalization is a volume-weighted mean absolute deviation: each bar's distance from the mean is weighted by that bar's share of total volume before being averaged. Price excursions that happened on thin volume contribute little; excursions on heavy volume define the scale. The oscillator then expresses current price as a number of these volume-weighted deviations away from the mean.
On top of that, the overbought/oversold zones are not fixed lines. They are recomputed continuously as a moving average of the oscillator plus or minus a multiple of its own standard deviation, so a quiet instrument gets tight zones and a volatile one gets wide zones automatically.

[b]HOW IT WORKS[/b]

Volume-weighted mean (rolling VWAP): mean = sum(price[i] * volume[i]) / sum(volume[i]) over the lookback window.

Volume-weighted mean absolute deviation: dev = sum( |price[i] - mean| * (volume[i] / sum(volume)) ) over the same window.

Oscillator (Mean Reversion mode): value = 50 + (price - mean) / (dev * sensitivity) * 25 A reading of 50 means price sits at the volume-weighted mean. Readings pull above or below 50 as price stretches away from it, scaled so that roughly one volume-weighted deviation maps to 25 oscillator points. The value is then EMA-smoothed.

Adaptive zones: midline = moving average of the oscillator (or a fixed 50 if disabled) upper / lower zone = midline +/- standard deviation of the oscillator * zone width

Signal lines: A fast and a slow EMA of the oscillator generate crossover events for timing.

[b]TWO MODES[/b]

Mean Reversion (default): the deviation oscillator described above. Best for spotting stretched conditions and exhaustion relative to volume-defined fair value.
Volume Intensity: rescales smoothed volume inside its own recent high-low range, 0 to 100. A simpler read of whether participation is currently expanding or drying up. Useful as a context filter alongside any price tool.

[b]HOW TO USE IT[/b]

Works on any market and timeframe. A few common readings:

Price crossing above the upper zone signals an unusually strong push relative to volume-weighted fair value, which can mean breakout strength or, in a range, exhaustion. The fast/slow signal cross helps tell continuation from fade.
A return toward the midline after a zone excursion is the mean-reversion leg.
In Volume Intensity mode, fading participation under a price advance is the classic non-confirmation warning. The four built-in alerts (cross above upper zone, cross below lower zone, bullish and bearish signal cross) let you watch several symbols without staring at charts.

[b]SETTINGS[/b]

Defaults are neutral, round starting values rather than curve-fitted numbers: lookback 50, smoothing 5, sensitivity 1.0, adaptive midline period 50, zone width 1.5. Every input carries a tooltip. Bar coloring is off by default so the script does not override your chart; turn it on if you want the oscillator state mirrored on price.

[b]ORIGINALITY[/b]

This script is an original construction by SfericaTrading. It does not reuse or adapt third-party Pine code. The underlying statistical building blocks (volume-weighted mean, mean absolute deviation, standard-deviation bands) are standard, but their combination into a volume-weighted deviation oscillator with self-normalizing adaptive zones is the original contribution.

[b]DISCLAIMER[/b]

This is an educational tool for market analysis. It is not financial advice and no performance is implied or promised. Always do your own research and manage risk.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © SfericaTrading
//
// Dynamic Volume Profile Oscillator (DVPO)
// ----------------------------------------
// An original volume-weighted deviation oscillator. Rather than tracking price
// momentum, DVPO measures how far price has stretched from its VOLUME-WEIGHTED
// mean, expressed in units of volume-weighted mean absolute deviation, then
// rescaled around a 50 midline. Self-normalizing adaptive zones replace the
// fixed overbought/oversold lines used by classic oscillators.

//@version=6
indicator("Dynamic Volume Profile Oscillator (DVPO)", shorttitle = "DVPO", overlay = false)

// ———————————————————————————— Inputs ————————————————————————————

string GRP_V = "Volume Analysis"
float priceSrcInput  = input.source(close,  "Price Source",  group = GRP_V)
float volumeSrcInput = input.source(volume, "Volume Source", group = GRP_V)
int   lookbackInput  = input.int(50, "Lookback Period", minval = 10, maxval = 500, group = GRP_V,
     tooltip = "Number of bars used to build the volume-weighted mean and its deviation.")

string GRP_O = "Oscillator"
string modeInput = input.string("Mean Reversion", "Mode", options = ["Mean Reversion", "Volume Intensity"],
     group = GRP_O,
     tooltip = "Mean Reversion: distance of price from its volume-weighted mean. Volume Intensity: current volume relative to its own recent range.")
int   smoothingInput   = input.int(5, "Smoothing Length", minval = 1, maxval = 50, group = GRP_O)
float sensitivityInput = input.float(1.0, "Sensitivity", minval = 0.1, maxval = 5.0, step = 0.1, group = GRP_O,
     tooltip = "Higher values compress the oscillator toward the midline; lower values amplify deviations.")

string GRP_T = "Adaptive Zones"
bool  useAdaptiveInput   = input.bool(true, "Use Adaptive Midline", group = GRP_T,
     tooltip = "Center the zones on a moving average of the oscillator instead of a fixed 50 line.")
int   midlinePeriodInput = input.int(50, "Adaptive Midline Period", minval = 10, maxval = 200, group = GRP_T)
float zoneWidthInput     = input.float(1.5, "Zone Width Multiplier", minval = 0.5, maxval = 3.0, step = 0.1,
     group = GRP_T, tooltip = "Zone half-width, in standard deviations of the oscillator.")

string GRP_D = "Display"
bool showSignalsInput = input.bool(true,  "Show Zone Signals",     group = GRP_D)
bool colorBarsInput   = input.bool(false, "Color Price Bars",      group = GRP_D)
bool showTableInput   = input.bool(true,  "Show Status Dashboard", group = GRP_D)

color bullColor = color.rgb(0, 230, 170)
color bearColor = color.rgb(255, 70, 130)

// ———————————————————————————— Core calculation ————————————————————————————

// Volume-weighted mean and volume-weighted mean absolute deviation over the
// lookback window, recomputed on every bar. The mean is a rolling VWAP; the
// deviation weights each bar's distance from that mean by its share of total
// volume, so heavily traded prices dominate the "fair value" estimate.
calcVolStats(int len) =>
    int n = math.min(len - 1, bar_index)
    float sumVol      = 0.0
    float sumPriceVol = 0.0
    for i = 0 to n
        float v = nz(volumeSrcInput[i])
        sumVol      += v
        sumPriceVol += nz(priceSrcInput[i]) * v
    float vwMean = sumVol > 0 ? sumPriceVol / sumVol : priceSrcInput
    float sumDev = 0.0
    if sumVol > 0
        for i = 0 to n
            float w = nz(volumeSrcInput[i]) / sumVol
            sumDev += math.abs(nz(priceSrcInput[i]) - vwMean) * w
    [vwMean, sumDev]

[vwMean, vwDev] = calcVolStats(lookbackInput)

// Mode 1 — Mean Reversion: signed distance from the volume-weighted mean,
// normalized by the volume-weighted deviation and rescaled around 50.
// Guarded against a zero denominator (flat or no-volume conditions).
float denom      = vwDev * sensitivityInput
float meanRevRaw = denom > 0 ? 50.0 + (priceSrcInput - vwMean) / denom * 25.0 : 50.0

// Mode 2 — Volume Intensity: smoothed volume rescaled inside its own recent range.
float volSma   = ta.sma(volumeSrcInput, smoothingInput)
float volLo    = ta.lowest(volSma, lookbackInput)
float volHi    = ta.highest(volSma, lookbackInput)
float volRange = volHi - volLo
float volIntensityRaw = volRange > 0 ? math.min(100.0, math.max(0.0, (volSma - volLo) / volRange * 100.0)) : 50.0

float oscRaw = modeInput == "Mean Reversion" ? meanRevRaw : volIntensityRaw
float osc    = ta.ema(oscRaw, smoothingInput)

// Adaptive midline and standard-deviation zones.
float midline   = useAdaptiveInput ? ta.sma(osc, midlinePeriodInput) : 50.0
float band      = ta.stdev(osc, midlinePeriodInput) * zoneWidthInput
float upperZone = midline + band
float lowerZone = midline - band

// Signal lines and state.
float fastSignal = ta.ema(osc, 5)
float slowSignal = ta.ema(osc, 15)
bool  isBull     = osc > midline or fastSignal > slowSignal
bool  crossUp    = ta.crossover(fastSignal, slowSignal)
bool  crossDown  = ta.crossunder(fastSignal, slowSignal)
bool  enterUpper = ta.crossover(osc, upperZone)
bool  enterLower = ta.crossunder(osc, lowerZone)

// ———————————————————————————— Visuals ————————————————————————————

color oscColor = isBull ? bullColor : bearColor

hline(50, "Midline Reference", color = color.new(color.gray, 60), linestyle = hline.style_dotted)

pUpper = plot(upperZone, "Upper Zone",       color = color.new(bearColor, 60))
pLower = plot(lowerZone, "Lower Zone",       color = color.new(bullColor, 60))
pMid   = plot(midline,   "Adaptive Midline", color = color.new(color.gray, 20), linewidth = 1)
fill(pUpper, pMid, color = color.new(bearColor, 92), title = "Upper Zone Fill")
fill(pMid, pLower, color = color.new(bullColor, 92), title = "Lower Zone Fill")

plot(osc,        "DVPO",        color = oscColor,                    linewidth = 2)
plot(fastSignal, "Fast Signal", color = color.new(color.white, 40))
plot(slowSignal, "Slow Signal", color = color.new(color.orange, 40))

plotshape(showSignalsInput and enterUpper, "Upper Break", shape.triangleup,   location.bottom, bullColor, size = size.tiny)
plotshape(showSignalsInput and enterLower, "Lower Break", shape.triangledown, location.top,    bearColor, size = size.tiny)

barcolor(colorBarsInput ? oscColor : na, title = "Bar Coloring")

var table dash = table.new(position.top_right, 2, 3, bgcolor = color.new(color.black, 75),
     border_width = 1, border_color = color.new(color.gray, 70))
if barstate.islast and showTableInput
    table.cell(dash, 0, 0, "DVPO", text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 0, str.tostring(osc, "#.0"), text_color = oscColor, text_size = size.small)
    table.cell(dash, 0, 1, "Bias", text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 1, isBull ? "Bullish" : "Bearish",
         text_color = isBull ? bullColor : bearColor, text_size = size.small)
    table.cell(dash, 0, 2, "Zone", text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 2, osc > upperZone ? "Above Upper" : osc < lowerZone ? "Below Lower" : "Inside",
         text_color = color.gray, text_size = size.small)

// ———————————————————————————— Alerts ————————————————————————————

alertcondition(enterUpper, "Cross Above Upper Zone", "DVPO crossed above the upper zone on {{ticker}} ({{interval}})")
alertcondition(enterLower, "Cross Below Lower Zone", "DVPO crossed below the lower zone on {{ticker}} ({{interval}})")
alertcondition(crossUp,    "Bullish Signal Cross",   "DVPO fast/slow bullish cross on {{ticker}} ({{interval}})")
alertcondition(crossDown,  "Bearish Signal Cross",   "DVPO fast/slow bearish cross on {{ticker}} ({{interval}})")
````
