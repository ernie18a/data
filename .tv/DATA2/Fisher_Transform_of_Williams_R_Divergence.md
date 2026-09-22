<!-- tradingview-pine-id: PUB;893ed2eebf7b476d812a8674a9125dfe -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Fisher Transform of Williams %R - Divergence

Source: https://www.tradingview.com/script/5eYf4t8I/

## Description

Fisher Transform of Williams %R — Divergence

Overview
This indicator applies John Ehlers' Fisher Transform to Larry Williams' %R oscillator, then layers a pivot-based regular/hidden divergence engine and a Fisher/Trigger crossover signal on top of it. The goal is to combine the sharp, well-defined turning points that the Fisher Transform produces with the momentum context of Williams %R, so that reversals show up as cleaner, more clearly separated peaks and troughs than the raw oscillator gives you — and then to automatically flag price/oscillator divergences at those points.

Credits

The Fisher Transform is a statistical technique introduced to trading by John F. Ehlers (see his paper "Using The Fisher Transform," Stocks & Commodities magazine). It converts an oscillator's probability distribution into a roughly Gaussian (bell-curve) distribution, which sharpens turning points and reduces the ambiguity that flat, range-bound oscillator readings normally produce.
Williams %R is a momentum oscillator developed by Larry Williams, measuring the current close relative to the high-low range over a lookback period.
This script normalizes Williams %R to a 0–1 range and runs that normalized value through Ehlers' Fisher Transform formula, rather than applying the transform to raw price or to a different oscillator. The divergence engine, cross-signal logic, zone filtering, and signal-spacing controls are original additions built for this script.

How it works

Williams %R is calculated over Williams %R Length bars: 100 × (source − highest high) / (highest high − lowest low).
That value is normalized to a 0–1 range using the highest/lowest %R over Fisher Transform Length bars, then rescaled to −1…+1.
The normalized value is smoothed (0.66 × normalized + 0.67 × previous) and clamped to ±0.999 to keep the Fisher formula well-defined.
The Fisher Transform is applied: 0.5 × ln((1+x)/(1−x)) + 0.5 × previous Fisher value. This is the plotted "Fisher %R" line.
A one-bar-delayed copy of the Fisher line acts as the Trigger line, used for crossover signals.
Divergence detection: the script finds confirmed pivot highs/lows on the Fisher line (using Pivot Left/Right Lookback), then looks back within a Min/Max Lookback Range window for a prior pivot of the same type to compare against price:
Regular Bullish: price makes a lower low while Fisher makes a higher low (potential reversal up).
Hidden Bullish: price makes a higher low while Fisher makes a lower low (trend continuation up).
Regular Bearish / Hidden Bearish: mirror logic on pivot highs.
Cross signals: independent triangle markers plot whenever the Fisher line crosses above/below its own Trigger line — a faster, divergence-independent momentum confirmation.

Parameters

Williams %R Length — lookback for the base %R calculation; shorter = more responsive, noisier.
Fisher Transform Length — lookback used to normalize %R before the transform; controls how "stretched" the Fisher output is.
Source — price input for %R (default close).
Overbought / Oversold Level — Fisher levels used for the background zone and, optionally, to filter divergence signals.
Pivot Left/Right Lookback — bars required on each side to confirm a swing high/low on the Fisher line; larger values = fewer but more reliable pivots.
Max/Min Lookback Range — bar-distance window searched for a comparable prior pivot when checking divergence.
Min Bars Between Same-Type Signals — cooldown to suppress rapid repeat signals of the same type.
Show Regular/Hidden Divergence — toggle each divergence class independently.
Require OB/OS Zone for Divergence — when on, only fires divergence signals when the relevant pivot is inside the overbought/oversold zone, cutting down low-quality mid-range signals.
Show Fisher/Trigger Cross Signals — toggle the crossover triangles.
Color inputs — purely visual, no effect on signal logic.

How to use it

Watch the Fisher line relative to the Trigger line and the OB/OS zone the way you would any oscillator, but expect sharper, more decisive turns than plain Williams %R.
Solid divergence lines/labels ("Reg Bull," "Reg Bear") mark classic reversal-warning divergences; dashed ones ("Hdn Bull," "Hdn Bear") mark continuation divergences, useful for adding to an existing trend rather than fading it.
Triangle cross signals can be used as a faster, standalone trigger, or as confirmation once a divergence has printed.
All four divergence types and both cross directions have built-in alertcondition() calls, so alerts can be set directly from the "Create Alert" dialog without any manual configuration.

What it solves / how it differs from other tools

Plain Williams %R divergence detection is noisy because %R saturates near ±100 across a wide range of price action, blurring pivots. Running it through the Fisher Transform first compresses that noise into sharper, more Gaussian-shaped peaks, giving divergence detection a cleaner signal to work from than a raw-oscillator approach.
Unlike many public Fisher Transform scripts (which typically transform price directly, or transform RSI/Stochastic), this one is specifically built on Williams %R, giving a different — often earlier — read on exhaustion at range extremes.
The zone filter and same-type signal cooldown are both configurable, letting users trade off signal frequency against signal quality, which many divergence scripts don't expose.

Notes / Disclaimer
This indicator is a technical analysis tool and does not constitute financial advice. It repaints only in the sense that divergence lines/labels are drawn after pivot confirmation (lbR bars after the pivot bar), which is standard for any pivot-based divergence tool and is by design — the underlying Fisher/Trigger plot values themselves do not repaint. As with any oscillator, past signals do not guarantee future performance; test and combine with your own risk management before live use.

---

## Source Code

````pine
//@version=6
// Fisher Transform of Williams %R with Divergence Engine and Filtered Cross Signals
// - Williams %R is rescaled over a rolling window and passed through a recursive Fisher Transform
// - Regular / hidden divergence detection on the Fisher line (pivot based, confirmed on bar close)
// - Fisher / Trigger cross signals with noise filters (OB/OS extreme, zero-line side, alternation, cooldown)
indicator("Fisher Transform of Williams %R - Divergence", shorttitle="Fish%R Div", format=format.price, precision=2, overlay=false, max_lines_count=500, max_labels_count=500)

// ================= INPUTS =================
length       = input.int(14, title="Williams %R Length", minval=1, group="Core Settings")
fisherLength = input.int(10, title="Fisher Transform Length", minval=1, group="Core Settings")
src          = input.source(close, title="Source", group="Core Settings")

obLevel      = input.float(1.5, title="Overbought Level", group="Core Settings")
osLevel      = input.float(-1.5, title="Oversold Level", group="Core Settings")

// ================= DIVERGENCE SETTINGS =================
lbR            = input.int(5, title="Pivot Right Lookback", minval=1, group="Divergence Settings", tooltip="Number of bars to the right required to confirm a pivot")
lbL            = input.int(5, title="Pivot Left Lookback", minval=1, group="Divergence Settings", tooltip="Number of bars to the left used to detect a pivot")
rangeUpper     = input.int(60, title="Max Lookback Range", minval=1, group="Divergence Settings", tooltip="Maximum bar distance between two pivots when searching for a divergence")
rangeLower     = input.int(5, title="Min Lookback Range", minval=1, group="Divergence Settings", tooltip="Minimum bar distance between two pivots when searching for a divergence")
minBarsBetween = input.int(0, title="Min Bars Between Same-Type Signals", minval=0, group="Divergence Settings", tooltip="Minimum number of bars between the pivots of two same-type divergence signals. Values at or below Min Lookback Range have no practical effect (0 = off)")
minFishDiff    = input.float(0.10, title="Min Fisher Difference", minval=0.0, step=0.05, group="Divergence Settings", tooltip="Minimum Fisher difference between two pivots. Filters out negligible divergences (0 = off)")

showRegular  = input.bool(true, title="Show Regular Divergence", group="Divergence Toggle")
showHidden   = input.bool(true, title="Show Hidden Divergence", group="Divergence Toggle")
zoneFilter   = input.bool(false, title="Require OB/OS Zone for Divergence", group="Divergence Toggle", tooltip="If enabled, divergences are only generated when the Fisher pivot is inside the overbought/oversold zone")

// ================= CROSS SIGNAL SETTINGS =================
showCross    = input.bool(true, title="Show Fisher/Trigger Cross Signals", group="Cross Signals", tooltip="Standalone confirmation signals generated when the Fisher line crosses its trigger line")
trigLen      = input.int(3, title="Trigger EMA Length (1 = Prev Bar)", minval=1, group="Cross Signals", tooltip="1 = classic Fisher[1] trigger (very noisy). 2+ = an EMA of Fisher is used as the trigger, which makes crosses less frequent")
zoneGate     = input.bool(true, title="Require Recent OB/OS Extreme", group="Cross Signals", tooltip="Buy requires Fisher to have reached the oversold zone recently; Sell requires the overbought zone")
extLookback  = input.int(8, title="Extreme Lookback Bars", minval=1, group="Cross Signals", tooltip="Number of bars to look back for an overbought/oversold extreme")
zeroSide     = input.bool(true, title="Buy Below / Sell Above Zero Line", group="Cross Signals", tooltip="Buy crosses must occur below the zero line, Sell crosses above it")
altOnly      = input.bool(true, title="Alternate Signals Only", group="Cross Signals", tooltip="Prevents repeated signals in the same direction (Buy-Sell-Buy)")
crossMinBars = input.int(3, title="Min Bars Between Cross Signals", minval=0, group="Cross Signals", tooltip="Minimum number of bars between two cross signals (0 = off)")

// ================= STYLE & COLORS =================
bullColor   = input.color(#00E676, "Bullish Divergence Color", group="Style & Colors")
bearColor   = input.color(#FF5252, "Bearish Divergence Color", group="Style & Colors")
hiddenBull  = input.color(color.new(#00E676, 40), "Hidden Bullish Color", group="Style & Colors")
hiddenBear  = input.color(color.new(#FF5252, 40), "Hidden Bearish Color", group="Style & Colors")
fisherColor = input.color(#2962FF, "Fisher Line Color", group="Style & Colors")
trigColor   = input.color(#FF6D00, "Trigger Line Color", group="Style & Colors")

// ================= WILLIAMS %R =================
hh = ta.highest(high, length)
ll = ta.lowest(low, length)
// Neutral value (-50) when the range is zero or during warm-up; 0 is the overbought extreme
percentR = (na(hh) or na(ll) or hh == ll) ? -50.0 : 100 * (src - hh) / (hh - ll)

// ================= FISHER TRANSFORM =================
highestPR = ta.highest(percentR, fisherLength)
lowestPR  = ta.lowest(percentR, fisherLength)

// Neutral value (0.5) when the range is zero -> normVal = 0
rawVal  = (highestPR == lowestPR) ? 0.5 : (percentR - lowestPR) / (highestPR - lowestPR)
normVal = 2 * (rawVal - 0.5)

// Classic Ehlers scaling: 0.66 * (raw - 0.5) = 0.33 * normVal
var float val = 0.0
val := math.max(math.min(0.33 * normVal + 0.67 * nz(val[1]), 0.999), -0.999)

var float fisher = 0.0
fisher := 0.5 * math.log((1 + val) / (1 - val)) + 0.5 * nz(fisher[1])

emaTrig = ta.ema(fisher, trigLen)
trigger = trigLen == 1 ? fisher[1] : emaTrig

// ================= PLOTS =================
plot(fisher, title="Fisher %R", color=fisherColor, linewidth=2)
plot(trigger, title="Trigger Line", color=trigColor, linewidth=1)

h1 = hline(obLevel, title="Overbought Level", color=color.gray, linestyle=hline.style_dashed)
h0 = hline(0, title="Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dotted)
h2 = hline(osLevel, title="Oversold Level", color=color.gray, linestyle=hline.style_dashed)
fill(h1, h2, color=color.new(#2962FF, 93), title="OB/OS Background")

// ================= FILTERED CROSS SIGNALS =================
crossUp   = ta.crossover(fisher, trigger)
crossDown = ta.crossunder(fisher, trigger)

wasOS = ta.lowest(fisher, extLookback)  <= osLevel
wasOB = ta.highest(fisher, extLookback) >= obLevel

rawBuy  = crossUp   and (not zoneGate or wasOS) and (not zeroSide or trigger < 0)
rawSell = crossDown and (not zoneGate or wasOB) and (not zeroSide or trigger > 0)

var int lastCrossDir = 0
var int lastCrossBar = na

cooldownOk = na(lastCrossBar) or (bar_index - lastCrossBar) >= crossMinBars

// barstate.isconfirmed: signals are only generated on bar close (no repainting, alerts fire once)
buySig  = showCross and barstate.isconfirmed and rawBuy  and cooldownOk and (not altOnly or lastCrossDir != 1)
sellSig = showCross and barstate.isconfirmed and rawSell and cooldownOk and (not altOnly or lastCrossDir != -1)

if buySig
    lastCrossDir := 1
    lastCrossBar := bar_index
if sellSig
    lastCrossDir := -1
    lastCrossBar := bar_index

plotshape(buySig  ? fisher : na, title="Buy Cross Signal",  style=shape.triangleup,   location=location.absolute, color=bullColor, size=size.tiny)
plotshape(sellSig ? fisher : na, title="Sell Cross Signal", style=shape.triangledown, location=location.absolute, color=bearColor, size=size.tiny)

// ================= DIVERGENCE ENGINE =================
pl = ta.pivotlow(fisher, lbL, lbR)
ph = ta.pivothigh(fisher, lbL, lbR)

var int lastBullBar = na
var int lastBearBar = na

bool regBullSig = false
bool hdnBullSig = false
bool regBearSig = false
bool hdnBearSig = false

pivotBar = bar_index[lbR]

// --- Bullish Divergences ---
if not na(pl) and barstate.isconfirmed
    int prevPlIndex = na
    for i = rangeLower to rangeUpper
        if not na(pl[i])
            prevPlIndex := i
            break

    if not na(prevPlIndex)
        float currentFisherLow = fisher[lbR]
        float prevFisherLow    = fisher[prevPlIndex + lbR]
        float currentPriceLow  = low[lbR]
        float prevPriceLow     = low[prevPlIndex + lbR]

        bool inZone    = not zoneFilter or currentFisherLow <= osLevel
        bool spacingOk = na(lastBullBar) or (pivotBar - lastBullBar) >= minBarsBetween
        bool diffOk    = math.abs(currentFisherLow - prevFisherLow) >= minFishDiff

        // Regular Bullish: price lower low, Fisher higher low
        if showRegular and inZone and spacingOk and diffOk and currentPriceLow < prevPriceLow and currentFisherLow > prevFisherLow
            line.new(bar_index[prevPlIndex + lbR], prevFisherLow, pivotBar, currentFisherLow, color=bullColor, width=2)
            label.new(pivotBar, currentFisherLow, "Reg Bull", color=bullColor, style=label.style_label_up, textcolor=color.white, size=size.tiny)
            lastBullBar := pivotBar
            regBullSig  := true
        // Hidden Bullish: price higher low, Fisher lower low
        else if showHidden and inZone and spacingOk and diffOk and currentPriceLow > prevPriceLow and currentFisherLow < prevFisherLow
            line.new(bar_index[prevPlIndex + lbR], prevFisherLow, pivotBar, currentFisherLow, color=hiddenBull, width=2, style=line.style_dashed)
            label.new(pivotBar, currentFisherLow, "Hdn Bull", color=hiddenBull, style=label.style_label_up, textcolor=color.white, size=size.tiny)
            lastBullBar := pivotBar
            hdnBullSig  := true

// --- Bearish Divergences ---
if not na(ph) and barstate.isconfirmed
    int prevPhIndex = na
    for i = rangeLower to rangeUpper
        if not na(ph[i])
            prevPhIndex := i
            break

    if not na(prevPhIndex)
        float currentFisherHigh = fisher[lbR]
        float prevFisherHigh    = fisher[prevPhIndex + lbR]
        float currentPriceHigh  = high[lbR]
        float prevPriceHigh     = high[prevPhIndex + lbR]

        bool inZone    = not zoneFilter or currentFisherHigh >= obLevel
        bool spacingOk = na(lastBearBar) or (pivotBar - lastBearBar) >= minBarsBetween
        bool diffOk    = math.abs(currentFisherHigh - prevFisherHigh) >= minFishDiff

        // Regular Bearish: price higher high, Fisher lower high
        if showRegular and inZone and spacingOk and diffOk and currentPriceHigh > prevPriceHigh and currentFisherHigh < prevFisherHigh
            line.new(bar_index[prevPhIndex + lbR], prevFisherHigh, pivotBar, currentFisherHigh, color=bearColor, width=2)
            label.new(pivotBar, currentFisherHigh, "Reg Bear", color=bearColor, style=label.style_label_down, textcolor=color.white, size=size.tiny)
            lastBearBar := pivotBar
            regBearSig  := true
        // Hidden Bearish: price lower high, Fisher higher high
        else if showHidden and inZone and spacingOk and diffOk and currentPriceHigh < prevPriceHigh and currentFisherHigh > prevFisherHigh
            line.new(bar_index[prevPhIndex + lbR], prevFisherHigh, pivotBar, currentFisherHigh, color=hiddenBear, width=2, style=line.style_dashed)
            label.new(pivotBar, currentFisherHigh, "Hdn Bear", color=hiddenBear, style=label.style_label_down, textcolor=color.white, size=size.tiny)
            lastBearBar := pivotBar
            hdnBearSig  := true

// ================= ALERTS =================
alertcondition(regBullSig, title="Regular Bullish Divergence", message="Fish%R Div: Regular Bullish Divergence Confirmed")
alertcondition(hdnBullSig, title="Hidden Bullish Divergence",  message="Fish%R Div: Hidden Bullish Divergence Confirmed")
alertcondition(regBearSig, title="Regular Bearish Divergence", message="Fish%R Div: Regular Bearish Divergence Confirmed")
alertcondition(hdnBearSig, title="Hidden Bearish Divergence",  message="Fish%R Div: Hidden Bearish Divergence Confirmed")
alertcondition(buySig,     title="Fisher Buy Cross",           message="Fish%R Div: Filtered BUY cross")
alertcondition(sellSig,    title="Fisher Sell Cross",          message="Fish%R Div: Filtered SELL cross")
````
