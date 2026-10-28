# Quanty | Trend Candles

- url: https://www.tradingview.com/script/BW6KpTF0-Quanty-Trend-Candles/
- type: indicator
- pine_id: PUB;c1dae814292a4d45b907425358f888d0
- version: 1.0

## Description

Most trend colouring is binary: a candle is green or red depending on which side of a moving average or a Supertrend line price sits on. That hides the question that matters, which is how much evidence there is that a trend exists at all. In a range, a binary tool keeps flipping between green and red; in a strong trend, it paints the same green as a weak one. This script colours every candle by the direction and the strength of the trend it sits in, and lets indecision look like indecision.

HOW IT IS CALCULATED

Momentum is the average of a fast and a slow exponential average of log returns (8 and 13 bars by default). Log returns make the reading independent of price level.

That momentum is then measured against what a trendless market with the same volatility would produce by chance. Volatility comes from a long window of squared returns, and the random-walk expectation is derived from the two averaging windows themselves. The result is a z-score: around 1 is ordinary noise, around 2 is a probable trend, 3 and above is a clear one. Because the reading is calibrated to each market's own noise, the same setting means the same thing on a large cap and on a thinly traded altcoin, on 15 minutes and on the daily chart.

Volume confirms, it does not create the signal. The script measures the volume-weighted share of recent bars that moved with the trend, adjusted for the effective number of bars so that one very large candle cannot fake broad participation. A move carried by many bars keeps its full colour; a move made on one thin candle fades. On symbols without volume data, bars are simply counted.

The evidence is passed through a soft S-curve, so readings below about one deviation stay near zero and strong evidence saturates toward full colour, then lightly smoothed.

READING IT

The candle stays in the neutral tone (cream or yellow) while the score is inside the indecision band. Past the band it switches to a clear trend colour and deepens as the evidence grows. A pullback inside a trend lightens the colour before it can turn it, because the fast and slow horizons disagree and partly cancel.

The score, the momentum evidence and the volume support are shown in the Data Window. Alerts fire when a trend turns strong in either direction and when a strong trend fades; they re-arm only after the score has clearly left the level, so they do not repeat while it hovers.

SETTINGS

Sensitivity sets how much evidence it takes to colour a candle. Aggressive shows more colour and more false tints in ranges; Conservative keeps ranges cleaner and colours trends later. Palette, indecision tone, band width and contrast change the look only, not the score.

NOTES AND LIMITATIONS

The colour describes the trend that exists; it does not forecast one. Strength is evidence, not speed: a steady low-volatility climb can read stronger than a violent rally of the same size.

After a sharp reversal the colour needs a few bars to reach full strength in the new direction. That is the price of keeping ranges quiet.

A parabolic move reads as the strongest trend right up to its top. Strength says nothing about how late a trend is.

By default the live candle is not coloured until it closes, so nothing repaints. Turning that off colours the forming candle, which can change until the close.

## Source Code

````pine
//@version=6
indicator("Quanty | Trend Candles", shorttitle="Quanty TREND", overlay=true)

// Paints every candle by the direction AND the strength of the trend it sits in.
// Strength is statistical evidence, not raw speed: recent log-return momentum is
// divided by what a trendless random walk with the same volatility would produce.
// A reading of 1 is ordinary noise, 2 is a likely trend, 3+ is a clear one. The
// same number means the same thing on BTC 1m and on a $0.001 altcoin on 1D.
//
// Volume does not create the signal; it can only confirm it. A move carried by
// the volume of many bars keeps its colour, a move made on one thin candle fades.
// Indecision is not a separate state: noise simply scores near zero and the
// candle fades to the neutral tone.

const string GROUP_TREND = "1. Trend"
const string GROUP_VOLUME = "2. Volume"
const string GROUP_STYLE = "3. Appearance"
const string GROUP_ALERT = "4. Alerts"

int fastLen = input.int(8, "Fast horizon (bars)", minval=2, tooltip="Reacts to fresh moves. Averaged with the slow horizon, so a pullback inside a trend lightens the colour instead of flipping it.", group=GROUP_TREND)
int slowLen = input.int(13, "Slow horizon (bars)", minval=3, tooltip="Defines how long a move must last to count as a trend.", group=GROUP_TREND)
int volLen = input.int(50, "Volatility window (bars)", minval=20, tooltip="Normal volatility is measured over this window. Longer keeps a single violent candle from washing out the colour of the trend that follows it.", group=GROUP_TREND)
string sensitivity = input.string("Balanced", "Sensitivity", options=["Conservative", "Balanced", "Aggressive"], tooltip="How much evidence it takes to paint a candle. Aggressive shows more colour and more false tints in ranges; Conservative keeps ranges cleaner but colours trends later.", group=GROUP_TREND)

bool useVolume = input.bool(true, "Volume confirmation", tooltip="When on, a move must be backed by the volume of many bars to keep full colour. Symbols without volume data fall back to counting bars.", group=GROUP_VOLUME)
float keepWithoutVolume = input.float(0.6, "Colour kept without volume support", minval=0.0, maxval=1.0, step=0.05, tooltip="Share of the colour a trend keeps when volume does not back it. 1.0 disables the volume filter, 0.0 removes all colour from unsupported moves.", group=GROUP_VOLUME)

string palette = input.string("Vivid", "Palette", options=["Vivid", "Neon", "Deep", "Custom"], tooltip="Vivid and Neon brighten as the trend strengthens; Deep darkens. Custom uses the four colours below.", group=GROUP_STYLE)
float neutralBand = input.float(0.15, "Indecision band", minval=0.0, maxval=0.5, step=0.01, tooltip="Scores (0 to 1) below this are drawn in the indecision tone. Above it the candle switches to a clear trend colour and deepens with strength.", group=GROUP_STYLE)
float contrast = input.float(0.6, "Colour contrast", minval=0.3, maxval=1.5, step=0.05, tooltip="Below 1 moves mid-strength trends toward the strong colour sooner; 1 is linear. It changes the look only, not the score.", group=GROUP_STYLE)
string tone = input.string("Cream", "Indecision tone", options=["Cream", "Yellow"], group=GROUP_STYLE)
color creamColor = input.color(color.rgb(242, 235, 220), "Cream", inline="neutral", group=GROUP_STYLE)
color yellowColor = input.color(color.rgb(240, 205, 90), "Yellow", inline="neutral", group=GROUP_STYLE)
color customWeakUp = input.color(color.rgb(110, 215, 160), "Custom up: weak", inline="cup", group=GROUP_STYLE)
color customStrongUp = input.color(color.rgb(0, 210, 105), "strong", inline="cup", group=GROUP_STYLE)
color customWeakDown = input.color(color.rgb(240, 135, 145), "Custom down: weak", inline="cdown", group=GROUP_STYLE)
color customStrongDown = input.color(color.rgb(245, 40, 65), "strong", inline="cdown", group=GROUP_STYLE)
int smoothLen = input.int(5, "Smoothing (bars)", minval=1, tooltip="Softens bar-to-bar colour changes. 1 turns smoothing off.", group=GROUP_STYLE)
bool confirmedOnly = input.bool(true, "Colour confirmed candles only", tooltip="When on, the live candle keeps the chart's own colour until it closes, so nothing repaints. When off, the live candle is coloured as it forms and may change colour until the close.", group=GROUP_STYLE)

float alertLevel = input.float(0.6, "Strong trend level", minval=0.1, maxval=0.95, step=0.05, tooltip="Score (0 to 1) at which a trend counts as strong. The alert re-arms only after the score falls back below this level minus 0.15, so it does not repeat while the score hovers.", group=GROUP_ALERT)

// Evidence (in random-walk standard deviations) that maps to a strong colour.
float zScale = sensitivity == "Conservative" ? 1.6 : sensitivity == "Aggressive" ? 1.0 : 1.25

// Pine has no tanh; the argument is clamped so exp cannot overflow.
f_tanh(float x) =>
    float xc = math.max(-20.0, math.min(20.0, x))
    float e2 = math.exp(2.0 * xc)
    (e2 - 1.0) / (e2 + 1.0)

// Log returns make the score independent of price level.
float prevClose = nz(close[1])
float ret = close > 0 and prevClose > 0 ? math.log(close / prevClose) : 0.0

// Momentum is the average of a fast and a slow EMA of returns. Under a random
// walk with per-bar deviation s this average has deviation s * nullSd, derived
// from the two EMA weightings and their overlap, so dividing by it turns the
// momentum into a z-score that is calibrated for any pair of horizons.
float alphaFast = 2.0 / (fastLen + 1)
float alphaSlow = 2.0 / (slowLen + 1)
float varFast = alphaFast / (2.0 - alphaFast)
float varSlow = alphaSlow / (2.0 - alphaSlow)
float covFastSlow = alphaFast * alphaSlow / (1.0 - (1.0 - alphaFast) * (1.0 - alphaSlow))
float nullSd = math.sqrt(0.25 * varFast + 0.25 * varSlow + 0.5 * covFastSlow)

float momentum = 0.5 * ta.ema(ret, fastLen) + 0.5 * ta.ema(ret, slowLen)
float sigma = math.sqrt(nz(ta.ema(ret * ret, volLen)))
// On tick-bound charts returns are quantised; half a tick keeps the ratio sane.
float tickFloor = syminfo.mintick > 0 and close > 0 ? 0.5 * syminfo.mintick / close : 0.0
float sigmaUsed = math.max(sigma, tickFloor)
float evidenceZ = sigmaUsed > 0 and nullSd > 0 ? nz(momentum) / (sigmaUsed * nullSd) : 0.0

// Volume support: the volume-weighted share of bars that moved with the trend,
// scaled by the effective number of bars so one huge candle cannot fake broad
// participation. Weights are capped at 5x the usual volume to tame liquidation
// spikes. Without volume data every bar weighs the same (a plain sign count).
bool hasVolume = ta.cum(nz(volume)) > 0
float barWeight = hasVolume ? nz(volume) : 1.0
float usualWeight = ta.sma(barWeight, 100)
float cappedWeight = nz(usualWeight) > 0 ? math.min(barWeight, 5.0 * usualWeight) : barWeight
float signedSum = nz(math.sum(cappedWeight * math.sign(ret), slowLen))
float weightSum = nz(math.sum(cappedWeight, slowLen))
float weightSqSum = nz(math.sum(cappedWeight * cappedWeight, slowLen))
float agreeShare = weightSum > 0 ? signedSum / weightSum : 0.0
float effectiveBars = weightSqSum > 0 ? weightSum * weightSum / weightSqSum : 0.0
float supportZ = math.sign(evidenceZ) * agreeShare * math.sqrt(effectiveBars)
float support = math.max(0.0, math.min(1.0, supportZ / 2.0))
float volumeFactor = useVolume ? keepWithoutVolume + (1.0 - keepWithoutVolume) * support : 1.0

// Soft S-curve: evidence below about one deviation stays near zero (noise reads
// as indecision), two to three deviations saturate toward full colour.
float u = math.abs(evidenceZ) / zScale
float strength = f_tanh(math.min(math.pow(u, 1.5), 20.0))
float rawScore = math.sign(evidenceZ) * strength * volumeFactor
float score = math.max(-1.0, math.min(1.0, nz(ta.ema(rawScore, smoothLen))))

// Before the volatility window has filled the score is not yet calibrated.
bool ready = bar_index >= math.max(volLen, 2 * slowLen)
bool paintable = ready and (not confirmedOnly or barstate.isconfirmed)

// Colour: indecision stays in the neutral tone; past the band the candle jumps
// to a clear weak trend colour and moves toward the strong colour with strength.
color neutralColor = tone == "Yellow" ? yellowColor : creamColor
color weakUp = palette == "Neon" ? color.rgb(90, 235, 170) : palette == "Deep" ? color.rgb(125, 215, 170) : palette == "Custom" ? customWeakUp : color.rgb(110, 215, 160)
color strongUp = palette == "Neon" ? color.rgb(0, 255, 128) : palette == "Deep" ? color.rgb(0, 150, 80) : palette == "Custom" ? customStrongUp : color.rgb(0, 210, 105)
color weakDown = palette == "Neon" ? color.rgb(255, 120, 140) : palette == "Deep" ? color.rgb(240, 145, 150) : palette == "Custom" ? customWeakDown : color.rgb(240, 135, 145)
color strongDown = palette == "Neon" ? color.rgb(255, 23, 68) : palette == "Deep" ? color.rgb(190, 20, 45) : palette == "Custom" ? customStrongDown : color.rgb(245, 40, 65)
float magnitude = math.abs(score)
float depth = magnitude <= neutralBand ? 0.0 : math.pow((magnitude - neutralBand) / (1.0 - neutralBand), contrast)
color upShade = color.from_gradient(depth, 0.0, 1.0, weakUp, strongUp)
color downShade = color.from_gradient(depth, 0.0, 1.0, weakDown, strongDown)
color trendColor = magnitude <= neutralBand ? neutralColor : score > 0 ? upShade : downShade

barcolor(paintable ? trendColor : na, title="Trend colour")

plot(ready ? score : na, "Trend score", color=trendColor, display=display.data_window)
plot(ready ? evidenceZ : na, "Momentum evidence (z)", display=display.data_window)
plot(ready ? volumeFactor : na, "Volume support", display=display.data_window)

// Alert state with hysteresis: strong only above the level, neutral again only
// once the score has dropped clearly below it.
var int regime = 0
if paintable
    regime := score >= alertLevel ? 1 : score <= -alertLevel ? -1 : math.abs(score) < alertLevel - 0.15 ? 0 : regime

bool turnedUp = regime == 1 and nz(regime[1]) != 1
bool turnedDown = regime == -1 and nz(regime[1]) != -1
bool turnedNeutral = regime == 0 and nz(regime[1]) != 0

alertcondition(turnedUp, "Quanty TREND strong uptrend", "{{ticker}} {{interval}}: trend turned strongly up. Close: {{close}}")
alertcondition(turnedDown, "Quanty TREND strong downtrend", "{{ticker}} {{interval}}: trend turned strongly down. Close: {{close}}")
alertcondition(turnedNeutral, "Quanty TREND faded", "{{ticker}} {{interval}}: strong trend faded to indecision. Close: {{close}}")
````
