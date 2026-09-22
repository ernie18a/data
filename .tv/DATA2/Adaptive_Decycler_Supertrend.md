<!-- tradingview-pine-id: PUB;2b4504b1f2c844f8a342028195715570 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive Decycler Supertrend

Source: https://www.tradingview.com/script/vEWWRSv8-Adaptive-Decycler-Supertrend-SchizoQuant/

## Description

Adaptive Decycler Supertrend is an adaptive trend-regime indicator that combines an efficiency-responsive Decycler, residual root-mean-square displacement, and persistent Supertrend-style trailing logic.

Rather than using ATR around a fixed trend baseline, the indicator adapts the Decycler's cutoff according to directional efficiency and uses the magnitude of price displacement around that adaptive baseline as a residual RMS volatility measure. Those residual RMS bands are then converted into a persistent trailing structure used to identify bullish and bearish regimes.

🟣 ✦ How It Works
The first stage measures directional efficiency by comparing the net movement of price over the selected Efficiency Length with the total distance travelled during the same period.

Efficiency is normalized between 0 and 1.

Higher efficiency indicates that price has travelled more directly in one direction and moves the Decycler toward the Minimum Cutoff.

Lower efficiency indicates less directional movement and moves the Decycler toward the Maximum Cutoff.

The resulting adaptive cutoff continuously changes the response of the Decycler between the user-defined limits.

🟣 ✦ Adaptive Decycler
The adaptive cutoff is converted into the Decycler's smoothing coefficient.

This creates a baseline that becomes more responsive during efficient directional movement and smoother during less efficient conditions.

The Decycler therefore serves as the central reference from which price displacement is measured.

🟣 ✦ Residual RMS Bands
The script calculates the residual between price and the adaptive Decycler:

Residual = Price - Adaptive Decycler

The squared residual is averaged over the Residual RMS Length, and the square root of that value produces the residual RMS measurement.

This represents the recent magnitude of price movement around the adaptive baseline.

The upper and lower envelopes are constructed by adding and subtracting independently scaled residual RMS values from the Decycler.

Upper Multiplier controls the upper envelope distance.

Lower Multiplier controls the lower envelope distance.

Because the two multipliers are independent, bullish and bearish reversal sensitivity can be configured separately.

🟣 ✦ Supertrend Regime Logic
The RMS envelopes are converted into a persistent trailing structure.

During a bullish regime, the lower RMS envelope acts as the basis of the trailing level. The trail can move upward with the envelope but does not move downward until the regime reverses.

During a bearish regime, the upper RMS envelope acts as the basis of the trailing level. The trail can move downward with the envelope but does not move upward until the regime reverses.

A bullish reversal occurs when the source moves above the previous bearish trailing level.

A bearish reversal occurs when the source moves below the previous bullish trailing level.

When neither reversal condition occurs, the current regime remains active.

LONG and SHORT markers therefore appear only when the persistent regime changes.

🟣 ✦ Main Settings
Minimum Cutoff / Maximum Cutoff define the response range available to the adaptive Decycler.

Efficiency Length controls the lookback used to determine how directional or inefficient recent price movement has been.

Residual RMS Length determines how much residual history is used to measure the magnitude of price displacement around the Decycler.

Upper Multiplier determines the distance of the upper RMS envelope from the adaptive baseline.

Lower Multiplier determines the distance of the lower RMS envelope from the adaptive baseline.

The visualization settings allow the adaptive Decycler, RMS envelope, LONG/SHORT markers, and candle coloring to be controlled separately. The optional envelope fill is displayed when the RMS envelope is visible.

🟣 ✦ Design Purpose
Each component serves a separate role:

Directional efficiency → Adaptive Decycler cutoff

Adaptive Decycler → Dynamic trend baseline

Price-to-Decycler residual → Baseline-relative displacement

Residual RMS → Adaptive envelope magnitude

RMS envelopes → Potential trailing levels

Persistent trail → Bullish / bearish regime

A key characteristic of this construction is that the trailing structure is derived from the residual energy around an efficiency-adaptive Decycler rather than from ATR around price or a conventional moving average.

This allows both the trend baseline and the surrounding reversal distance to respond to changing market behavior through different mechanisms.

🟣 ✦ Limitations
Adaptive Decycler Supertrend is a trend-regime indicator and not a complete trading system. LONG and SHORT markers identify changes in the indicator's internal regime and do not imply guaranteed trading outcomes or future performance.

Directional efficiency is calculated from historical price movement. Changes in recent market structure can therefore alter the Decycler's effective cutoff.

Residual RMS measures the magnitude of historical displacement around the adaptive baseline. Large recent deviations can widen the envelope and affect the distance required for subsequent regime reversals.

Like other trailing trend methods, the indicator can react later during abrupt reversals because price must cross the existing trailing level before the regime changes.

The indicator uses a Supertrend-style trailing mechanism, but its bands are based on residual RMS rather than the ATR calculation commonly used by standard Supertrend implementations.

The script does not use higher-timeframe requests or lookahead logic.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant

//@version=6
indicator("Adaptive Decycler Supertrend", overlay=true)

// USER INPUTS
string cutoffTip     = "Minimum Cutoff sets the fastest Decycler response used during cleaner directional movement, while Maximum Cutoff sets the slowest response used during noisier conditions. Lower the minimum for faster reactions or increase the maximum for stronger smoothing."
string efficiencyTip = "Sets the lookback used to measure directional efficiency by comparing net price movement with the total distance travelled. Higher efficiency moves the adaptive Decycler toward the faster cutoff, while lower efficiency moves it toward the slower cutoff."
string rmsTip        = "Sets the lookback used to measure the root-mean-square energy of price displacement from the adaptive Decycler. Increase it for steadier bands or decrease it for faster adaptation to changes in residual movement."
string bandTip       = "Upper Multiplier controls the RMS distance above the adaptive Decycler, while Lower Multiplier controls the distance below it. Increase either multiplier to widen that side of the Supertrend structure and require a larger move before a reversal."
string colorTip      = "Bullish Color represents bullish Supertrend regimes, LONG signals, and bullish visual elements, while Bearish Color represents bearish Supertrend regimes, SHORT signals, and bearish visual elements."

float src             = input.source(title="Source", defval=close, group="Adaptive Decycler", tooltip="Choose the price source used by the adaptive Decycler, efficiency calculation, residual measurement, and Supertrend regime logic.")
int   minimumCutoff   = input.int(title="Minimum Cutoff", defval=15, minval=6, group="Adaptive Decycler", inline="D1", tooltip=cutoffTip)
int   maximumCutoff   = input.int(title="Maximum Cutoff", defval=50, minval=7, group="Adaptive Decycler", inline="D1", tooltip=cutoffTip)
int   efficiencyLength = input.int(title="Efficiency Length", defval=10, minval=2, group="Adaptive Decycler", tooltip=efficiencyTip)
int   rmsLength       = input.int(title="Residual RMS Length", defval=20, minval=2, group="Supertrend Bands", tooltip=rmsTip)
float upperMultiplier = input.float(title="Upper Multiplier", defval=2.00, minval=0.10, step=0.10, group="Supertrend Bands", inline="B1", tooltip=bandTip)
float lowerMultiplier = input.float(title="Lower Multiplier", defval=2.60, minval=0.10, step=0.10, group="Supertrend Bands", inline="B1", tooltip=bandTip)
bool  showDecycler    = input.bool(title="Show Decycler", defval=true, group="Visualization", tooltip="Show or hide the adaptive Decycler baseline. Turning this off only changes the chart display and does not affect the Supertrend calculations or signals.")
bool  showEnvelope    = input.bool(title="Show RMS Envelope", defval=false, group="Visualization", tooltip="Show or hide the upper and lower residual RMS bands. Turning this off only changes the chart display and does not affect regime calculations.")
bool  showFill        = input.bool(title="Show Envelope Fill", defval=true, group="Visualization", tooltip="Show or hide the shaded region between the RMS bands when the envelope is visible. This is visual only and does not affect the indicator calculations.")
bool  showSignals     = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip="Show or hide LONG and SHORT markers whenever the active Supertrend regime changes. Turning this off does not change the underlying regime calculation.")
bool  colorBars       = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip="Color price candles according to the active Supertrend regime. Turning this off only removes candle coloring and does not affect signals.")
color longColor       = input.color(title="Bullish Color", defval=color.rgb(57, 255, 20), group="Color Settings", inline="C1", tooltip=colorTip)
color shortColor      = input.color(title="Bearish Color", defval=color.rgb(138, 43, 226), group="Color Settings", inline="C1", tooltip=colorTip)

// CALCULATIONS
int fastLimit = math.min(minimumCutoff, maximumCutoff)
int slowLimit = math.max(minimumCutoff, maximumCutoff)

float direction = math.abs(src - nz(src[efficiencyLength], src))
float noise     = 0.0

for i = 0 to efficiencyLength - 1
    noise += math.abs(nz(src[i], src) - nz(src[i + 1], src))

float efficiency = noise > 0.0 ? direction / noise : 0.0
efficiency := math.max(0.0, math.min(1.0, efficiency))

float adaptiveCutoff = float(slowLimit) - efficiency * float(slowLimit - fastLimit)

float angle       = 2.0 * math.pi / adaptiveCutoff
float cosineValue = math.cos(angle)
float alpha       = math.abs(cosineValue) > 0.000001 ? (cosineValue + math.sin(angle) - 1.0) / cosineValue : 1.0
alpha := math.max(0.0, math.min(1.0, alpha))

var float decycler = na
decycler := na(decycler[1]) ? src : alpha * 0.5 * (src + nz(src[1], src)) + (1.0 - alpha) * decycler[1]

float residual       = src - decycler
float residualEnergy = ta.sma(residual * residual, rmsLength)
float residualRMS    = math.sqrt(math.max(nz(residualEnergy, 0.0), 0.0))
residualRMS := math.max(residualRMS, syminfo.mintick)

float upperEnvelope = decycler + residualRMS * upperMultiplier
float lowerEnvelope = decycler - residualRMS * lowerMultiplier

//SIGNALS
var int SQ           = src >= decycler ? 1 : -1
var float trendTrail = na

int previousSQ      = nz(SQ[1], SQ)
float previousTrail = nz(trendTrail[1], previousSQ == 1 ? lowerEnvelope : upperEnvelope)

bool long  = previousSQ == -1 and src > previousTrail
bool short = previousSQ == 1 and src < previousTrail

if long
    SQ := 1
else if short
    SQ := -1
else
    SQ := previousSQ

if SQ == 1
    trendTrail := long ? lowerEnvelope : math.max(lowerEnvelope, previousTrail)
else
    trendTrail := short ? upperEnvelope : math.min(upperEnvelope, previousTrail)

bool longSignal  = SQ == 1 and nz(SQ[1], SQ) != 1
bool shortSignal = SQ == -1 and nz(SQ[1], SQ) != -1

// COLORS
color col = SQ == 1 ? longColor : shortColor

// PLOTS
plot(SQ == 1 ? trendTrail : na, title="Bullish Supertrend", color=longColor, linewidth=2, style=plot.style_linebr)
plot(SQ == -1 ? trendTrail : na, title="Bearish Supertrend", color=shortColor, linewidth=2, style=plot.style_linebr)
plot(showDecycler ? decycler : na, title="Adaptive Decycler", color=color.new(col, 35), linewidth=2)
upperPlot = plot(showEnvelope ? upperEnvelope : na, title="Upper RMS Band", color=color.new(shortColor, 70), linewidth=1)
lowerPlot = plot(showEnvelope ? lowerEnvelope : na, title="Lower RMS Band", color=color.new(longColor, 70), linewidth=1)
fill(upperPlot, lowerPlot, title="RMS Band Fill", color=showFill and showEnvelope ? color.new(col, 93) : na)
plot(efficiency, title="Efficiency", display=display.data_window)
plot(adaptiveCutoff, title="Adaptive Cutoff", display=display.data_window)
plot(residual, title="Decycler Residual", display=display.data_window)
plot(residualRMS, title="Residual RMS", display=display.data_window)
plotshape(showSignals and longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, size=size.small, color=longColor, text="LONG", textcolor=color.white)
plotshape(showSignals and shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, size=size.small, color=shortColor, text="SHORT", textcolor=color.white)
barcolor(colorBars ? col : na)

// ALERTS
alertcondition(longSignal, title="Long Signal", message="Adaptive Decycler Supertrend Long Signal on {{ticker}}")
alertcondition(shortSignal, title="Short Signal", message="Adaptive Decycler Supertrend Short Signal on {{ticker}}")
````
