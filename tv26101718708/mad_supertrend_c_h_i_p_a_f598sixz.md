# MAD Supertrend ~ C H I P A

- url: https://www.tradingview.com/script/f598sIXZ-MAD-Supertrend-C-H-I-P-A/
- type: indicator
- pine_id: PUB;6f8e696683cb410f9a897846988f5eec
- version: 1.0

## Description

MAD Supertrend ~ C H I P A is a custom trend-following system that replaces the standard deviation core of a classic Supertrend with Median Absolute Deviation (MAD) — a robust volatility measure that ignores outlier wicks instead of inflating on them. The result is a trail that holds steady through shakeout spikes where stdev-based bands blow out and go blind.
It uses:
A user-selectable source and MAD length
A choice of MAD estimator — true Median-of-deviations for maximum robustness, or Mean for a slightly smoother read
Independent upper and lower MAD multipliers for asymmetric band control
A selectable centerline engine: raw Source for zero lag, Single Median, or a Double Median smoother that kills staircase artefacts without adding meaningful delay
A PSAR-style exit acceleration module — each new closing extreme in the trend tightens the exit trail by a configurable step, down to a user-defined floor
Supertrend ratchet logic with persistent trend state and clean flip detection
The exit acceleration is the key behavioural difference from a standard Supertrend: fresh trends begin at full band width, giving early moves room to survive shakeouts, while mature trends that keep printing new extremes are trailed progressively tighter — so extended runs are exited far closer to their peak. The trail only ever tightens mid-trend and fully resets on each flip.
Alerts fire on confirmed trend flips in both directions.
Note: MAD Supertrend is provided "as is" without formal robustness or optimization testing. Past performance is not indicative of future results; use in live trading only after sufficient back-testing and validation.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("MAD Supertrend ~ C H I P A", overlay=false)

// > ——— Inputs ——— < \\
gg          = "!! MAD ST !!"
src         = input.source(close, "Source", group = gg)
madLen      = input.int(20, "MAD Length", minval=2, group = gg)
multUp      = input.float(1.8, "Upper MAD Multiplier", step=0.05, group = gg)
multDn      = input.float(0.7, "Lower MAD Multiplier", step=0.05, group = gg)
madMode     = input.string("Median", "MAD Estimator", options=["Median", "Mean"], tooltip = "Median = true MAD (most robust). Mean = average absolute deviation (slightly smoother).", group = gg)
smoothDev   = input.int(6, "MAD Smoothing", minval=0, tooltip = "Set to '0' to turn off", group = gg)

gc          = "!! CENTERLINE !!"
centerMode  = input.string("Double Median", "Centerline Mode", options=["Source", "Single Median", "Double Median"], group = gc)
medLen1     = input.int(45, "First Median Length", minval=1, group = gc)
medLen2     = input.int(1, "Second Median Length (Smoother)", minval=1, group = gc)

ga          = "!! EXIT ACCEL !!"
useAccel    = input.bool(true, "Accelerate exit trail with trend age", group = ga)
accelStep   = input.float(0.05, "Acceleration per new extreme", step=0.01, group = ga)
minMultFrac = input.float(0.45, "Minimum multiplier fraction", step=0.05, minval=0.1, maxval=1.0, tooltip = "Exit trail can tighten down to this fraction of its base multiplier", group = ga)

// > ——— Volatility core (MAD) ——— < \\
med       = ta.median(src, madLen)
absDev    = math.abs(src - med)
firstMed  = ta.median(src, medLen1)
dblMed    = ta.median(firstMed, medLen2)
rawMad    = madMode == "Median" ? ta.median(absDev, madLen) : ta.sma(absDev, madLen)
// 1.4826 ≈ consistency constant: scales MAD to stdev-equivalent units,
// so the multiplier behaves like the StdDev Supertrend's
madVol    = rawMad * 1.4826
vol       = smoothDev > 0 ? ta.ema(madVol, smoothDev) : madVol

// > ——— Basic bands around the selected centerline ——— < \\
basis      = centerMode == "Source" ? src : centerMode == "Single Median" ? firstMed : dblMed

// > ——— Exit trail acceleration (PSAR-style, keyed to new extremes) ——— < \\
var int   dir     = 1
var float accel   = 0.0
var float extreme = na

newExtreme = dir == 1 ? (na(extreme) or close > extreme) : (na(extreme) or close < extreme)
if newExtreme
    extreme := close
    accel   := math.min(accel + accelStep, 1.0 - minMultFrac)

tight = useAccel ? (1.0 - accel) : 1.0
effUp = dir == -1 ? multUp * tight : multUp   // exit trail when short
effDn = dir ==  1 ? multDn * tight : multDn   // exit trail when long

upperBasic = basis + effUp * vol
lowerBasic = basis - effDn * vol

// > ——— Supertrend-style trailing logic ——— < \\
var float upper = na
var float lower = na

upper := if na(upper)
    upperBasic
else
    (upperBasic < upper or close[1] > upper) ? upperBasic : upper

lower := if na(lower)
    lowerBasic
else
    (lowerBasic > lower or close[1] < lower) ? lowerBasic : lower

dir := dir == -1 and close > upper ? 1 :
       dir ==  1 and close < lower ? -1 : dir

if ta.change(dir) != 0
    accel   := 0.0
    extreme := close

trendLine = dir == 1 ? lower : upper

// > ——— Colors ——— < \\
upCol   = color.rgb(0, 180, 255)
dnCol   = color.rgb(255, 80, 60)
lineCol = dir == 1 ? upCol : dnCol
barCol  = dir == 1 ? color.new(upCol, 40) : color.new(dnCol, 60)

// > ——— Main Chart ——— < \\

// ——— Main chart: price ↔ trend fill (unique names) ———
useDir_mainFill   = input.bool(true,  "Directional color (main fill)")
atrLen_mainFill   = 80
strength_mainFill = 12

// plot handles (distinct)
pTrend_main = plot(trendLine, title="MAD Supertrend (main)", color=lineCol, linewidth=2, force_overlay = true)
pPrice_main = plot(close,     title="Price (fill ref, main)", color=color.new(color.gray, 100), force_overlay = true)  // invisible

// adaptive alpha (distinct vars)
gap_main   = math.abs(close - trendLine)
norm_main  = ta.atr(atrLen_mainFill) * strength_mainFill
ratio_main = norm_main > 0 ? math.min(1.0, gap_main / norm_main) : 0.0
alpha_main = 95 - math.round(25 * ratio_main)  // 95=faint → 70=stronger

fillColor_main = useDir_mainFill
     ? color.new(close >= trendLine ? color.new(upCol, 40) : color.new(dnCol, 60), alpha_main)
     : color.new(color.gray, alpha_main)

fill(pTrend_main, pPrice_main, fillColor_main, title="Price↔Trend fill (main)")

// > ——— Secondary Pane ——— < \\

mbu = plot(upper, title="Upper Trail", color=color.new(color.gray, 100), linewidth=1)
mbl = plot(lower, title="Lower Trail", color=color.new(color.gray, 100), linewidth=1)

atrLen   = 80
strength = 12

gap   = math.abs(upper - lower)
norm  = ta.atr(atrLen) * strength
ratio = norm > 0 ? math.min(1.0, gap / norm) : 0.0
alpha = 95 - math.round(25 * ratio)
fill(mbu, mbl, color.new(dir == 1 ? upCol : dnCol, alpha), title="Rails fade")

// ——— Robustness view: MAD vs StdDev volatility ratio ———
showVolRatio = input.bool(false, "Show MAD/StdDev ratio line", tooltip = "Below 1.0 = outliers inflating stdev; MAD is holding steady")
sdVol    = ta.stdev(src, madLen)
volRatio = sdVol > 0 ? madVol / sdVol : 1.0
plot(showVolRatio ? volRatio : na, title="MAD/StdDev Ratio", color=color.new(color.yellow, 30), linewidth=1, display=display.pane)

showPaneCandles = input.bool(true, "Draw candles in pane")
o1 = showPaneCandles ? open  : na
h1 = showPaneCandles ? high  : na
l1 = showPaneCandles ? low   : na
c1 = showPaneCandles ? close : na
plotcandle(o1, h1, l1, c1, color=barCol, bordercolor=barCol, wickcolor=barCol, title="Pane Candles", force_overlay = false)

// > ——— Alerts ——— < \\
longFlip  = barstate.isconfirmed and ta.change(dir) != 0 and dir == 1
shortFlip = barstate.isconfirmed and ta.change(dir) != 0 and dir == -1

alertcondition(longFlip,  "MAD ST flip → LONG",  "MAD Supertrend flipped to LONG")
alertcondition(shortFlip, "MAD ST flip → SHORT", "MAD Supertrend flipped to SHORT")
````
