<!-- tradingview-pine-id: PUB;8693adb4aa584abb8bb56c43e114420a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Engulfing Confirmation Signals [algotim]

Source: https://www.tradingview.com/script/V6jcTD53-Engulfing-Confirmation-Signals-algotim/

## Description

Overview
Engulfing Confirmation Signals is a two-stage price action indicator designed to distinguish basic engulfing candle formations from engulfing setups that receive additional confirmation from market context.

The script does not treat every bullish or bearish engulfing candle as a signal. First, an engulfing candle must satisfy structural requirements and pass a rule-based quality score using trend alignment, relative volume, and ATR expansion. A qualifying engulfing candle then creates a temporary confirmation zone based on its full high-low range.

The second stage waits for price to close beyond that range within a configurable number of bars. This separates the initial pattern from the subsequent breakout confirmation.

Problem Statement
A traditional engulfing detector can produce a large number of signals because the candlestick pattern itself only describes the relationship between the current candle and the previous candle.

This script adds a filtering and confirmation process around that pattern.

Instead of treating the engulfing candle as the final event, the indicator asks two separate questions:

1. Does the engulfing candle have sufficient structural and market-context quality?
2. After qualification, does price subsequently break the engulfing candle's range before the setup expires?

This creates a distinction between a qualified engulfing setup and a confirmed breakout.

Methodology
Stage 1: Engulfing Structure

A bullish engulfing candle must close above its open while the previous candle is bearish.

A bearish engulfing candle must close below its open while the previous candle is bullish.

When full-body engulfing is enabled, the current candle must also open and close beyond the previous candle's corresponding open and close.

The current candle body must be at least the configured multiple of the previous candle's body. The default minimum is 1.05 times the previous candle body.

The pattern is evaluated on the confirmed bar close.

### Stage 2: Quality Score

A qualifying engulfing candle receives a score from three rule-based components.

**Trend alignment - 40 points**

For bullish setups, the close is compared with the configured EMA. A close above the EMA receives the full 40 points. A close within the defined 0.2% proximity band receives 20 points.

For bearish setups, the corresponding relationship is reversed.

**Relative volume - 30 points**

Volume is compared with its simple moving average:

Volume ratio = Current volume / Average volume

The resulting value is converted into a score and capped at 30 points.

This allows the scoring engine to distinguish an engulfing candle occurring with relatively high participation from one occurring on comparatively weak volume.

**ATR expansion - 30 points**

Current ATR is compared with an average of ATR values.

ATR expansion contributes additional points when current volatility is above its ATR baseline, with the contribution capped at 30 points.

The three components are added together. An engulfing candle is accepted only when its total score reaches the user-defined minimum score.

The score is a rule-based filter and should not be interpreted as a probability or expected win rate.

Signal Workflow

Bullish workflow

1. Detect a bullish engulfing candle.
2. Verify the required body relationship with the previous candle.
3. Calculate trend, volume, and ATR components.
4. Add the components into the 0-100 quality score.
5. Ignore the setup if the score is below the minimum threshold.
6. If qualified, create a bullish confirmation zone using the engulfing candle's high and low.
7. Monitor subsequent bars for a close above the engulfing candle high.
8. Generate the confirmed bullish signal when that breakout occurs.
9. Expire the zone if the breakout does not occur within the configured waiting period.

Bearish workflow

1. Detect a bearish engulfing candle.
2. Verify the required body relationship with the previous candle.
3. Calculate trend, volume, and ATR components.
4. Add the components into the 0-100 quality score.
5. Ignore the setup if the score is below the minimum threshold.
6. If qualified, create a bearish confirmation zone using the engulfing candle's high and low.
7. Monitor subsequent bars for a close below the engulfing candle low.
8. Generate the confirmed bearish signal when that breakout occurs.
9. Expire the zone if the breakout does not occur within the configured waiting period.

Why This Indicator Is Different
A conventional engulfing indicator normally stops at identifying the candlestick pattern.
This script uses the engulfing candle as the beginning of a two-stage process.
The first stage evaluates whether the pattern has sufficient contextual support using three measurable conditions: its position relative to an EMA, current volume relative to average volume, and current ATR relative to its ATR baseline.

The second stage does not immediately convert a qualified engulfing candle into a confirmed breakout signal. Instead, the engulfing candle's range becomes a temporary state that is monitored for a subsequent closing breakout.

This distinction is the main purpose of the indicator: the initial engulfing event and the later range break are treated as separate analytical events.

Inputs
Engulfing Detection

**Min Body Size vs Prior Candle**

Controls how large the engulfing candle's body must be relative to the previous candle.

**Require Full Body Engulf**

When enabled, the current candle's open and close must fully engulf the previous candle's body.

Confirmation Engine

**Trend EMA Length**

Sets the EMA used for the trend-alignment component of the score.

**Volume Average Length**

Controls the moving-average baseline used to evaluate relative volume.

**ATR Length**

Controls the ATR calculation used by the volatility component.

**Minimum Quality Score**

Sets the minimum combined score required for an engulfing candle to create a confirmation zone.

Confirmation Zone

**Max Bars to Wait for Confirmation**

Defines how long an active engulfing zone remains valid while waiting for a breakout.

**Extend Zone Box While Active**

Controls whether the active zone visually extends as subsequent bars are processed.

Visual Style
The visual inputs control bullish and bearish colors, zone transparency, Stage 1 markers, and whether the numerical quality score is displayed.

Alerts

The script provides alerts for:
* Qualified bullish engulfing
* Qualified bearish engulfing
* Confirmed bullish breakout
* Confirmed bearish breakout

Qualified alerts identify the first stage of the process. Confirmed breakout alerts identify the second stage.

Practical Usage

The Stage 1 marker can be used to locate engulfing candles that have passed the configured contextual filters.

The Stage 2 confirmation marker can then be used to identify cases where price subsequently closes beyond the qualified engulfing candle's range.

Users can adjust the minimum score to control selectivity. Higher thresholds require stronger combined trend, volume, and volatility conditions and will generally produce fewer qualifying setups.

The confirmation window can also be adjusted depending on how long the user wants an engulfing setup to remain valid.

The indicator is intended for chart analysis and can be evaluated across different instruments and timeframes. Settings should be tested against the characteristics of the market being analyzed.

Limitations

The quality score is a rule-based classification and is not a statistical probability, accuracy percentage, or guarantee of future performance.

Engulfing patterns can fail, and a confirmed range breakout does not guarantee continued price movement.

Volume behavior varies between instruments, particularly where volume data is limited or represents different types of market activity.

EMA, volume, and ATR parameters can produce different results across instruments and timeframes.

Signals are generated from completed bar conditions, but the confirmation process can still produce false breakouts during volatile or ranging conditions.

The indicator does not provide trade management, position sizing, stop-loss, or take-profit recommendations.

Notes
The script is designed as a structured confirmation framework around engulfing price action.

Its output should be interpreted as analytical information rather than a standalone trading decision. Users should evaluate the indicator with their own market context, risk management, and trading methodology.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © algotim

//@version=6
indicator("Engulfing Confirmation Signals [algotim]", shorttitle="Engulf Confirm [algotim]", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ---------------------------------------------------------------------------
// INPUTS
// ---------------------------------------------------------------------------
grpDetect = "Engulfing Detection"
minBodyRatio   = input.float(1.05, "Min Body Size vs Prior Candle", minval=1.0, maxval=3.0, step=0.05, group=grpDetect, tooltip="Engulfing body must be at least this many times larger than the previous candle's body.")
requireFullEngulf = input.bool(true, "Require Full Body Engulf (Open/Close beyond prior)", group=grpDetect)

grpScore = "Confirmation Engine"
emaLen     = input.int(50, "Trend EMA Length", minval=5, maxval=400, group=grpScore, tooltip="Used to score trend alignment of the engulfing candle.")
volLen     = input.int(20, "Volume Average Length", minval=5, maxval=200, group=grpScore)
atrLen     = input.int(14, "ATR Length", minval=5, maxval=100, group=grpScore)
minScore   = input.int(60, "Minimum Quality Score (0-100)", minval=0, maxval=100, group=grpScore, tooltip="Engulfing candles below this score are ignored entirely.")

grpZone = "Confirmation Zone"
zoneMaxBars = input.int(15, "Max Bars to Wait for Confirmation", minval=1, maxval=100, group=grpZone, tooltip="If price does not break the engulfing range within this many bars, the zone expires.")
zoneExtend  = input.bool(true, "Extend Zone Box While Active", group=grpZone)

grpStyle = "Visual Style"
bullColor = input.color(color.new(#26a69a, 0), "Bullish Color", group=grpStyle)
bearColor = input.color(color.new(#ef5350, 0), "Bearish Color", group=grpStyle)
zoneOpacity = input.int(88, "Zone Transparency", minval=50, maxval=95, group=grpStyle)
showStage1 = input.bool(true, "Show Stage 1 Markers (Raw Engulf)", group=grpStyle)
showScoreLabel = input.bool(true, "Show Score on Stage 1 Marker", group=grpStyle)

// ---------------------------------------------------------------------------
// CORE CALCULATIONS
// ---------------------------------------------------------------------------
ema      = ta.ema(close, emaLen)
avgVol   = ta.sma(volume, volLen)
atrVal   = ta.atr(atrLen)
atrAvg   = ta.sma(atrVal, atrLen)

bodySize      = math.abs(close - open)
prevBodySize  = math.abs(close[1] - open[1])

// Raw engulfing structure detection (non-repainting, confirmed on bar close)
bullEngulf = close > open and close[1] < open[1] and
             (requireFullEngulf ? (close > open[1] and open < close[1]) : true) and
             bodySize >= prevBodySize * minBodyRatio

bearEngulf = close < open and close[1] > open[1] and
             (requireFullEngulf ? (close < open[1] and open > close[1]) : true) and
             bodySize >= prevBodySize * minBodyRatio

// ---------------------------------------------------------------------------
// CONFIRMATION SCORING (0-100)
// Trend Alignment (40 pts) + Relative Volume (30 pts) + ATR Expansion (30 pts)
// ---------------------------------------------------------------------------
trendScoreBull = close > ema ? 40.0 : (close > ema * 0.998 ? 20.0 : 0.0)
trendScoreBear = close < ema ? 40.0 : (close < ema * 1.002 ? 20.0 : 0.0)

volRatio = avgVol > 0 ? volume / avgVol : 1.0
volScore = math.min(volRatio * 20.0, 30.0)

atrRatio = atrAvg > 0 ? atrVal / atrAvg : 1.0
atrScore = math.min((atrRatio - 1.0) * 60.0 + 10.0, 30.0)
atrScore := math.max(atrScore, 0.0)

bullScore = trendScoreBull + volScore + atrScore
bearScore = trendScoreBear + volScore + atrScore

qualifiedBull = bullEngulf and bullScore >= minScore
qualifiedBear = bearEngulf and bearScore >= minScore

// ---------------------------------------------------------------------------
// STATE FOR CONFIRMATION ZONES (Stage 2)
// ---------------------------------------------------------------------------
var box   bullZoneBox = na
var box   bearZoneBox = na
var float bullZoneHigh = na
var float bullZoneLow  = na
var float bearZoneHigh = na
var float bearZoneLow  = na
var int   bullZoneBarsLeft = 0
var int   bearZoneBarsLeft = 0
var bool  bullZoneActive = false
var bool  bearZoneActive = false

// Outputs reset each bar
bool bullConfirmed = false
bool bearConfirmed = false
bool bullExpired   = false
bool bearExpired   = false

// --- Initialize a new bullish zone on qualified bullish engulf ---
if qualifiedBull
    bullZoneHigh := high
    bullZoneLow  := low
    bullZoneBarsLeft := zoneMaxBars
    bullZoneActive := true
    if not na(bullZoneBox)
        box.delete(bullZoneBox)
    bullZoneBox := box.new(bar_index, bullZoneHigh, bar_index + zoneMaxBars, bullZoneLow,
         border_color=color.new(bullColor, 60), bgcolor=color.new(bullColor, zoneOpacity),
         border_style=line.style_dashed, border_width=1)

// --- Initialize a new bearish zone on qualified bearish engulf ---
if qualifiedBear
    bearZoneHigh := high
    bearZoneLow  := low
    bearZoneBarsLeft := zoneMaxBars
    bearZoneActive := true
    if not na(bearZoneBox)
        box.delete(bearZoneBox)
    bearZoneBox := box.new(bar_index, bearZoneHigh, bar_index + zoneMaxBars, bearZoneLow,
         border_color=color.new(bearColor, 60), bgcolor=color.new(bearColor, zoneOpacity),
         border_style=line.style_dashed, border_width=1)

// --- Manage active bullish zone: check for breakout confirmation ---
if bullZoneActive and not qualifiedBull
    if close > bullZoneHigh
        bullConfirmed := true
        bullZoneActive := false
        if not na(bullZoneBox)
            box.set_right(bullZoneBox, bar_index)
            box.set_bgcolor(bullZoneBox, color.new(bullColor, 90))
    else
        bullZoneBarsLeft -= 1
        if zoneExtend and not na(bullZoneBox)
            box.set_right(bullZoneBox, bar_index)
        if bullZoneBarsLeft <= 0
            bullExpired := true
            bullZoneActive := false
            if not na(bullZoneBox)
                box.delete(bullZoneBox)
                bullZoneBox := na

// --- Manage active bearish zone: check for breakout confirmation ---
if bearZoneActive and not qualifiedBear
    if close < bearZoneLow
        bearConfirmed := true
        bearZoneActive := false
        if not na(bearZoneBox)
            box.set_right(bearZoneBox, bar_index)
            box.set_bgcolor(bearZoneBox, color.new(bearColor, 90))
    else
        bearZoneBarsLeft -= 1
        if zoneExtend and not na(bearZoneBox)
            box.set_right(bearZoneBox, bar_index)
        if bearZoneBarsLeft <= 0
            bearExpired := true
            bearZoneActive := false
            if not na(bearZoneBox)
                box.delete(bearZoneBox)
                bearZoneBox := na

// ---------------------------------------------------------------------------
// VISUALS — STAGE 1: Qualified Engulfing Markers
// ---------------------------------------------------------------------------
if showStage1 and qualifiedBull
    lbl = label.new(bar_index, low - atrVal * 0.5, showScoreLabel ? "Engulf " + str.tostring(math.round(bullScore)) : "Engulf",
         style=label.style_label_up, color=color.new(bullColor, 15), textcolor=color.white, size=size.small)

if showStage1 and qualifiedBear
    lbl2 = label.new(bar_index, high + atrVal * 0.5, showScoreLabel ? "Engulf " + str.tostring(math.round(bearScore)) : "Engulf",
         style=label.style_label_down, color=color.new(bearColor, 15), textcolor=color.white, size=size.small)

// ---------------------------------------------------------------------------
// VISUALS — STAGE 2: Confirmed Breakout Signals
// ---------------------------------------------------------------------------
plotshape(bullConfirmed, title="Confirmed Bullish Signal", style=shape.triangleup, location=location.belowbar,
     color=bullColor, size=size.normal, text="CONFIRM")

plotshape(bearConfirmed, title="Confirmed Bearish Signal", style=shape.triangledown, location=location.abovebar,
     color=bearColor, size=size.normal, text="CONFIRM")

// EMA plot for trend context
plot(ema, title="Trend EMA", color=color.new(color.gray, 40), linewidth=1)

// ---------------------------------------------------------------------------
// ALERTS
// ---------------------------------------------------------------------------
alertcondition(qualifiedBull, title="Qualified Bullish Engulf", message="Engulfing Confirmation Signals: Qualified BULLISH engulfing detected (score-filtered). Watching for breakout confirmation.")
alertcondition(qualifiedBear, title="Qualified Bearish Engulf", message="Engulfing Confirmation Signals: Qualified BEARISH engulfing detected (score-filtered). Watching for breakout confirmation.")
alertcondition(bullConfirmed, title="Confirmed Bullish Breakout", message="Engulfing Confirmation Signals: BULLISH engulfing CONFIRMED — price broke above engulfing range.")
alertcondition(bearConfirmed, title="Confirmed Bearish Breakout", message="Engulfing Confirmation Signals: BEARISH engulfing CONFIRMED — price broke below engulfing range.")

if qualifiedBull
    alert("Engulfing Confirmation Signals: Qualified BULLISH engulfing detected (score " + str.tostring(math.round(bullScore)) + "/100).", alert.freq_once_per_bar_close)
if qualifiedBear
    alert("Engulfing Confirmation Signals: Qualified BEARISH engulfing detected (score " + str.tostring(math.round(bearScore)) + "/100).", alert.freq_once_per_bar_close)
if bullConfirmed
    alert("Engulfing Confirmation Signals: BULLISH breakout CONFIRMED above engulfing range.", alert.freq_once_per_bar_close)
if bearConfirmed
    alert("Engulfing Confirmation Signals: BEARISH breakout CONFIRMED below engulfing range.", alert.freq_once_per_bar_close)
````
