<!-- tradingview-pine-id: PUB;373398afa836455d9436616d6417640f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Chaikin Fisher Transform Divergence & Early Reversal

Source: https://www.tradingview.com/script/RWPqmGCy/

## Description

# 📌 CFisherDiv — Chaikin Fisher Transform Divergence & Early Reversal

## Purpose of the Indicator

This indicator combines the **Chaikin Oscillator**, a volume-based momentum oscillator, with **Fisher Transform** mathematics, which converts price/momentum extremes into sharp turning points. The goal is to take the "soft" and lagging signals produced by the classic Chaikin Oscillator and make them earlier and clearer through the Fisher transform's sharp peak/trough structure, which approximates a Gaussian distribution.

On its own, the indicator addresses:

- Removing the ambiguity in interpreting the raw Chaikin Oscillator (by offering a normalized oscillation line with defined boundaries via the Fisher transform)
- Catching trend exhaustion early through **pivot-based divergence** detection, in addition to classic crossover signals
- Giving advance notice of reversals from overbought/oversold zones with **"early reversal"** signals, before a full crossover forms

## Attribution for Methods Used

This indicator is an original synthesis of two independent, well-known technical analysis methods:

- **Chaikin Oscillator**: Developed by Marc Chaikin, this classic volume-momentum oscillator takes the difference between short- and long-period EMAs of the Accumulation/Distribution line. In this indicator it's calculated via the built-in `ta.accdist` function.
- **Fisher Transform**: Developed by John F. Ehlers, this mathematical method compresses any oscillating series into the -1 to +1 range and then applies a logarithmic transform to produce a sharp, approximately Gaussian-distributed signal. Originally applied to price, this technique is applied here to the classic Chaikin Oscillator's output instead.

The pivot-based divergence detection and "early reversal" logic are additional layers designed originally for this script; no third-party code was used as a base.

## How Is It Calculated?

1. **Chaikin Oscillator**: `ema(accdist, fast length) - ema(accdist, slow length)`
2. **Fisher Normalization**: The oscillator value is normalized into the -0.5 to +0.5 range based on the highest/lowest values within the chosen period, then smoothed with a weighted average and clamped to ±0.999.
3. **Fisher Transform**: The normalized value is logarithmically transformed via `0.5 × ln((1+x)/(1-x))`, then weighted with the previous bar's value. The result is the Fisher line (`fish`) and its one-bar-lagged trigger (`trigger`).

## Parameters

**Chaikin Oscillator**
- *Fast Length* (default 3): The short EMA period of the Accumulation/Distribution line
- *Slow Length* (default 10): The long EMA period of the Accumulation/Distribution line

**Fisher Transform**
- *Fisher Normalization Length* (default 10): The lookback window over which the oscillator's highest/lowest values are calculated. Shortening it speeds up the signal but increases noise.
- *Overbought Level* (default 1.5) / *Oversold Level* (default -1.5): Horizontal thresholds defining the Fisher line's extreme zones.

**Divergence**
- *Show Divergences*: Toggles divergence lines and labels on/off.
- *Pivot Left Bars / Pivot Right Bars* (default 4/4): The number of bars required on each side of a peak or trough for it to be confirmed as a pivot. Increasing this produces more reliable but more delayed pivots.
- *Max Bars Between Pivots* (default 60): The maximum bar distance over which divergence is searched for between two pivots; prevents meaningless pairing of pivots that are too far apart.

**Early Reversal**
- *Show Early Reversal Signals*: Toggles early signals that form on exit from an extreme zone.
- *Signal Cooldown (Bars)* (default 5): The mandatory minimum bar distance between consecutive early signals (prevents excessive signal repetition).

## How to Interpret the Signals

- **Green/Red triangle (Long/Short Crossover)**: The Fisher line crossing its own trigger up/down — a classic momentum reversal signal.
- **RegBull / RegBear (Regular Divergence)**: Price makes a new low/high while the Fisher line fails to confirm it — indicates the current trend is losing steam, a potential trend reversal.
- **HidBull / HidBear (Hidden Divergence)**: Price makes a shallower low/high while the Fisher line makes a deeper low/high — a confirmation signal that the current trend is likely to continue.
- **Cyan/Orange diamond (Early Bullish/Bearish Reversal)**: A leading signal triggered when the Fisher line begins to turn while still in the oversold/overbought zone, before a full crossover forms. Earlier than the other signals but carries a higher risk of false signals; confirmation with price action or another indicator is recommended.

## Usage Note

Since the indicator relies on volume data, it will not work on symbols that don't provide volume information (some forex pairs, indices, etc.) and will report this with an error message on the chart. The signals are designed to be used for trend following and confirmation alongside other technical/fundamental analysis tools, not as standalone buy/sell decisions. Past performance is not a guarantee of future results.

---

## Source Code

````pine
//@version=6
indicator(
     title="Chaikin Fisher Transform Divergence & Early Reversal",
     shorttitle="CFisherDiv",
     format=format.price)

// VOLUME CHECK
var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("Data provider does not supply volume information.")

grpChaikin = "Chaikin Oscillator"
shortLen   = input.int(3,  minval=1, title="Fast Length", group=grpChaikin)
longLen    = input.int(10, minval=1, title="Slow Length", group=grpChaikin)

grpFisher = "Fisher Transform"
fishLen   = input.int(10, minval=2, title="Fisher Normalization Length", group=grpFisher)
obLevel   = input.float(1.5,  title="Overbought Level", group=grpFisher)
osLevel   = input.float(-1.5, title="Oversold Level", group=grpFisher)

grpDiv     = "Divergence"
showDiv    = input.bool(true, title="Show Divergences", group=grpDiv)
pivL       = input.int(4, minval=1, title="Pivot Left Bars", group=grpDiv)
pivR       = input.int(4, minval=1, title="Pivot Right Bars", group=grpDiv)
maxPivBars = input.int(60, minval=5, title="Max Bars Between Pivots", group=grpDiv)

grpEarly  = "Early Reversal"
showEarly = input.bool(true, title="Show Early Reversal Signals", group=grpEarly)
cooldownB = input.int(5, minval=0, title="Signal Cooldown (Bars)", group=grpEarly)

// CHAIKIN OSCILLATOR
osc = ta.ema(ta.accdist, shortLen) - ta.ema(ta.accdist, longLen)

// FISHER TRANSFORM
hi = ta.highest(osc, fishLen)
lo = ta.lowest(osc, fishLen)

var float value1 = 0.0
range_ = hi - lo
rawVal = range_ != 0 ? (osc - lo) / range_ - 0.5 : 0.0
value1 := 0.33 * 2 * rawVal + 0.67 * nz(value1[1])
value1 := math.max(math.min(value1, 0.999), -0.999)

var float fish = 0.0
fish := 0.5 * math.log((1 + value1) / (1 - value1)) + 0.5 * nz(fish[1])
trigger = fish[1]

// BASE REGIME SIGNALS
longCross  = ta.crossover(fish, trigger)
shortCross = ta.crossunder(fish, trigger)

// ────────────────────────────────────────────────────────────
// PIVOT-BASED DIVERGENCE ENGINE & LINE DRAWING
// ────────────────────────────────────────────────────────────
fishPL = ta.pivotlow(fish, pivL, pivR)
fishPH = ta.pivothigh(fish, pivL, pivR)

var float prevFishLowVal   = na
var int   prevFishLowBar   = na
var float prevPriceAtLow   = na

var float prevFishHighVal  = na
var int   prevFishHighBar  = na
var float prevPriceAtHigh  = na

bool regBullDiv = false
bool hidBullDiv = false
bool regBearDiv = false
bool hidBearDiv = false

if not na(fishPL) and barstate.isconfirmed
    pivotBar    = bar_index - pivR
    priceAtLow  = low[pivR]
    if not na(prevFishLowVal) and (pivotBar - prevFishLowBar) <= maxPivBars
        if priceAtLow < prevPriceAtLow and fishPL > prevFishLowVal
            regBullDiv := true
            if showDiv
                line.new(x1=prevFishLowBar, y1=prevFishLowVal, x2=pivotBar, y2=fishPL, color=#26A69A, width=2, style=line.style_solid)
        if priceAtLow > prevPriceAtLow and fishPL < prevFishLowVal
            hidBullDiv := true
            if showDiv
                line.new(x1=prevFishLowBar, y1=prevFishLowVal, x2=pivotBar, y2=fishPL, color=color.new(#26A69A, 30), width=2, style=line.style_dashed)
    prevFishLowVal := fishPL
    prevFishLowBar := pivotBar
    prevPriceAtLow := priceAtLow

if not na(fishPH) and barstate.isconfirmed
    pivotBarH    = bar_index - pivR
    priceAtHigh  = high[pivR]
    if not na(prevFishHighVal) and (pivotBarH - prevFishHighBar) <= maxPivBars
        if priceAtHigh > prevPriceAtHigh and fishPH < prevFishHighVal
            regBearDiv := true
            if showDiv
                line.new(x1=prevFishHighBar, y1=prevFishHighVal, x2=pivotBarH, y2=fishPH, color=#EF5350, width=2, style=line.style_solid)
        if priceAtHigh < prevPriceAtHigh and fishPH > prevFishHighVal
            hidBearDiv := true
            if showDiv
                line.new(x1=prevFishHighBar, y1=prevFishHighVal, x2=pivotBarH, y2=fishPH, color=color.new(#EF5350, 30), width=2, style=line.style_dashed)
    prevFishHighVal := fishPH
    prevFishHighBar := pivotBarH
    prevPriceAtHigh := priceAtHigh

// EARLY REVERSAL SIGNALS
fishCurlUp   = fish > fish[1] and fish[1] <= fish[2]
fishCurlDown = fish < fish[1] and fish[1] >= fish[2]

earlyBullRaw = showEarly and fish[1] <= osLevel and fishCurlUp
earlyBearRaw = showEarly and fish[1] >= obLevel and fishCurlDown

var int lastEarlyBullBar = na
var int lastEarlyBearBar = na

earlyBull = earlyBullRaw and (na(lastEarlyBullBar) or (bar_index - lastEarlyBullBar) >= cooldownB)
earlyBear = earlyBearRaw and (na(lastEarlyBearBar) or (bar_index - lastEarlyBearBar) >= cooldownB)

if earlyBull
    lastEarlyBullBar := bar_index
if earlyBear
    lastEarlyBearBar := bar_index

// PLOTTING
fishColor = fish >= 0 ? #26A69A : #EF5350
plot(fish, title="Fisher", color=fishColor, linewidth=2)
plot(trigger, title="Trigger", color=#787B86, linewidth=1)

hline(0, title="Zero Line", color=#787B86, linestyle=hline.style_dashed)
hline(obLevel, title="Overbought", color=color.new(#EF5350, 60), linestyle=hline.style_dotted)
hline(osLevel, title="Oversold", color=color.new(#26A69A, 60), linestyle=hline.style_dotted)

plotshape(longCross,  title="Long Crossover",  style=shape.triangleup,   location=location.bottom, color=#26A69A, size=size.tiny)
plotshape(shortCross, title="Short Crossover", style=shape.triangledown, location=location.top,    color=#EF5350, size=size.tiny)

// PIVOT DIVERGENCE LABELS
plotshape(showDiv and regBullDiv, title="Regular Bullish Divergence", style=shape.labelup,   location=location.bottom, color=#26A69A,                text="RegBull", textcolor=color.white, size=size.small, offset=-pivR)
plotshape(showDiv and hidBullDiv, title="Hidden Bullish Divergence",  style=shape.labelup,   location=location.bottom, color=color.new(#26A69A, 30), text="HidBull", textcolor=color.white, size=size.small, offset=-pivR)
plotshape(showDiv and regBearDiv, title="Regular Bearish Divergence", style=shape.labeldown, location=location.top,    color=#EF5350,                text="RegBear", textcolor=color.white, size=size.small, offset=-pivR)
plotshape(showDiv and hidBearDiv, title="Hidden Bearish Divergence",  style=shape.labeldown, location=location.top,    color=color.new(#EF5350, 30), text="HidBear", textcolor=color.white, size=size.small, offset=-pivR)

plotshape(earlyBull, title="Early Bullish Reversal", style=shape.diamond, location=location.bottom, color=#00E5FF, size=size.tiny)
plotshape(earlyBear, title="Early Bearish Reversal", style=shape.diamond, location=location.top,    color=#FF6D00, size=size.tiny)

// ALERTS
alertcondition(longCross,  title="Fisher Long Crossover",  message="Chaikin-Fisher: Long crossover")
alertcondition(shortCross, title="Fisher Short Crossover", message="Chaikin-Fisher: Short crossover")
alertcondition(regBullDiv, title="Regular Bullish Divergence", message="Chaikin-Fisher: Regular bullish divergence")
alertcondition(regBearDiv, title="Regular Bearish Divergence", message="Chaikin-Fisher: Regular bearish divergence")
alertcondition(hidBullDiv, title="Hidden Bullish Divergence",  message="Chaikin-Fisher: Hidden bullish divergence")
alertcondition(hidBearDiv, title="Hidden Bearish Divergence",  message="Chaikin-Fisher: Hidden bearish divergence")
alertcondition(earlyBull,  title="Early Bullish Reversal", message="Chaikin-Fisher: Early bullish reversal signal")
alertcondition(earlyBear,  title="Early Bearish Reversal", message="Chaikin-Fisher: Early bearish reversal signal")
````
