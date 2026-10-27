# Operebem VolumePRO

- url: https://www.tradingview.com/script/vdeVLJ5B-Operebem-VolumePRO/
- type: indicator
- pine_id: PUB;bb55db65a4b1497a9730bdb5c80c7e0b
- version: 1.0

## Description

Operebem VolumePRO
Volume Participation Indicator for TradingView
Version: 1
Pine Script: v6
Type: Indicator (no automatic order execution)
DESCRIPTION
Operebem VolumePRO is a volume analysis indicator that classifies traded participation into four distinct regimes: Quiet, Normal, Expansion, and Climax.
It was designed to help traders quickly identify whether current volume is below recent behavior, within a normal range, above the short-term average, or in a statistically unusual concentration.
The indicator does not provide entries, exits, stop-loss, take-profit, or buy/sell recommendations. It should be used as additional context for price action, trend, market structure, and risk management.
HOW THE INDICATOR CALCULATES PARTICIPATION
The user can choose between three volume calculation modes:

Exchange Volume — Uses the raw volume series provided by the asset and broker on TradingView.
Financial Volume — Multiplies volume by the selected price (default: Close). Formula: volume × price.
Normalized Financial Volume — Multiplies volume by price and divides by the user-defined normalization divisor (default: 1,000,000).

The price source for Financial modes is customizable. The choice of mode should consider the asset type, the volume unit displayed by the data source, and the trader’s analytical objective.
IMPORTANT NOTES ON VOLUME DATA
TradingView’s volume series can vary significantly depending on the asset, exchange, broker, and market. In many Forex pairs and some CFDs, volume often represents ticks or provider activity rather than consolidated global financial volume.
For this reason, absolute values should not be directly compared across different assets, brokers, or instruments. Relative regime readings are generally more meaningful than absolute number comparisons.
BASELINES AND REFERENCES
The indicator calculates two dynamic references:

Fast Baseline: Exponential Moving Average of participation (default period: 21). Used for short-term expansion and quiet detection.
Slow Baseline: Simple Moving Average of participation (default period: 233). Provides broader context and can optionally dim bars below it visually.

Both periods are fully customizable. Shorter periods react faster but generate more regime changes; longer periods smooth the reading but respond more slowly.
PARTICIPATION REGIMES

Quiet — Current participation is below the configured relative threshold to the Fast Baseline (default: 0.75 → below 75% of the fast average).
Normal — Default regime when the bar does not meet Quiet, Expansion, or Climax criteria.
Expansion — Current participation is equal to or above the configured relative threshold to the Fast Baseline (default: 1.25 → 125% or more of the fast average).
Climax — Triggered when the log-volume z-score reaches or exceeds the configured threshold (default: 2.50). Identifies statistically extreme participation.

Priority: When a bar meets both Climax and Expansion criteria, it is classified as Climax.
LOG-VOLUME Z-SCORE
To detect extreme spikes, the indicator applies the natural logarithm to participation (log(participation + 1)), then calculates the mean and standard deviation over a configurable lookback period (default: 50 bars).
Formula:
textz-score = (logVolume - mean(logVolume)) / stdev(logVolume)
The logarithm reduces the disproportionate influence of isolated extreme bars. The z-score is a relative measure of exceptionality, not a probability, and does not guarantee reversals or continuations.
VISUAL ELEMENTS

Columns represent the calculated participation in the chosen mode.
Colors:
Quiet: Gray
Normal: Blue
Expansion: Green
Climax: Orange


The Fast Baseline can be displayed as a solid line. The Slow Baseline can be shown as a dotted line with circles. When enabled, bars below the Slow Baseline have reduced visual intensity (purely cosmetic — does not affect calculations).
CLIMAX MARKERS
When enabled, confirmed Climax bars are marked with the text CLX. The maximum number of on-chart markers is configurable. Older markers are automatically removed when the limit is reached to optimize Pine Script object usage.
Markers are only placed after bar close to avoid false confirmations during live bar formation.
INFORMATION TABLE (Optional)
The table displays:

Current Regime
Relative Volume (vs Fast Baseline)
Relative Volume (vs Slow Baseline)
Log-Volume Z-Score

Table position is customizable.
ALERTS
Two configurable alerts are available:

Participation Expansion — Triggers when entering a new Expansion regime.
Participation Climax — Triggers when entering a new Climax regime.

Alerts are disabled by default. Enable them in the settings and create the alert via TradingView’s menu. “Alerts only after bar close” is enabled by default and strongly recommended.
RECOMMENDED STARTING SETTINGS

Volume Mode: Financial Volume
Price Source: Close
Normalization Divisor: 1,000,000
Fast Baseline Length: 21
Slow Baseline Length: 233
Log-Volume Z-Score Length: 50
Quiet Below Relative Volume: 0.75
Expansion Above Relative Volume: 1.25
Climax Z-Score Trigger: 2.50

These values are not universal — adjust according to the asset, timeframe, liquidity, and your trading methodology.
INTERPRETATION WITH PRICE ACTION
Expansion or Climax can confirm increased participation, but does not indicate whether buyers or sellers are in control. Always analyze in conjunction with:

Bar close direction
Market structure (highs/lows)
Key support/resistance levels
Subsequent price behavior

A Climax bar near resistance, support, or at the end of a move can have very different implications. The indicator does not automatically detect absorption, distribution, or institutional intent.
Quiet regimes indicate relatively lower participation but do not necessarily mean consolidation or an imminent volatility explosion.
LIMITATIONS

Depends on the quality and availability of TradingView’s volume data.
Regimes are relative to the asset’s recent history and should not be treated as universal classifications.
The indicator is descriptive, not predictive. It does not eliminate market risk or replace a solid trading plan.
No backtesting or performance guarantees.

RESPONSIBLE USE
Use Operebem VolumePRO as a contextual tool. Always validate readings with price action, liquidity, trading session, costs, volatility, and your own strategy rules. Test thoroughly on your preferred assets and timeframes before using with real capital.
This indicator is for educational and informational purposes only. It does not constitute investment advice, solicitation, or any promise of financial return.

Authorship & Originality
Operebem VolumePRO was developed in Pine Script v6 to provide a clean, organized view of relative volume participation. The description above documents the published implementation and should remain consistent with future code updates.

## Source Code

````pine
//@version=6
indicator("Operebem VolumePRO", shorttitle="OB VolumePRO", overlay=false, format=format.volume, precision=2, max_labels_count=300)

string groupVolume = "01. Participation"
string volumeMode = input.string("Financial volume", "Volume mode", options=["Exchange volume", "Financial volume", "Normalized financial volume"], group=groupVolume)
priceSource = input.source(close, "Price source for financial volume", group=groupVolume)
float normalizeDivisor = input.float(1000000.0, "Normalization divisor", minval=1.0, step=1000.0, group=groupVolume)

string groupBaseline = "02. Baselines"
int fastLength = input.int(21, "Fast baseline length", minval=1, group=groupBaseline)
int slowLength = input.int(233, "Slow baseline length", minval=2, group=groupBaseline)
int zLength = input.int(50, "Log-volume z-score length", minval=5, group=groupBaseline)

string groupRegime = "03. Regime thresholds"
float quietMax = input.float(0.75, "Quiet below relative volume", minval=0.05, step=0.05, group=groupRegime)
float expansionMin = input.float(1.25, "Expansion above relative volume", minval=0.10, step=0.05, group=groupRegime)
float climaxZ = input.float(2.50, "Climax z-score trigger", minval=0.10, step=0.05, group=groupRegime)

string groupDisplay = "04. Display"
bool showFastBaseline = input.bool(true, "Show fast baseline", group=groupDisplay)
bool showSlowBaseline = input.bool(true, "Show slow baseline", group=groupDisplay)
bool dimBelowSlow = input.bool(true, "Dim every regime below slow baseline", group=groupDisplay)
int dimTransparency = input.int(55, "Dim transparency", minval=0, maxval=100, group=groupDisplay)
bool showClimaxLabels = input.bool(true, "Mark climax bars", group=groupDisplay)
int maxClimaxLabels = input.int(120, "Maximum climax labels", minval=10, maxval=300, group=groupDisplay)
float labelOffsetPct = input.float(8.0, "Label offset above bar (%)", minval=0.0, maxval=100.0, step=0.5, group=groupDisplay)
bool showInfoTable = input.bool(true, "Show regime table", group=groupDisplay)
string tablePosition = input.string("Middle Left", "Table position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=groupDisplay)

string groupColors = "05. Colors"
color quietColor = input.color(color.rgb(156, 163, 175), "Quiet", group=groupColors)
color normalColor = input.color(color.rgb(96, 165, 250), "Normal", group=groupColors)
color expansionColor = input.color(color.rgb(34, 197, 94), "Expansion", group=groupColors)
color climaxColor = input.color(color.rgb(245, 158, 11), "Climax", group=groupColors)
color fastColor = input.color(color.rgb(30, 41, 59), "Fast baseline", group=groupColors)
color slowColor = input.color(color.rgb(100, 116, 139), "Slow baseline", group=groupColors)
color tableTextColor = input.color(color.white, "Table text", group=groupColors)
color tableHeaderColor = input.color(color.rgb(30, 41, 59), "Table header", group=groupColors)
color tableValueColor = input.color(color.rgb(71, 85, 105), "Table values", group=groupColors)
color labelTextColor = input.color(color.black, "Climax label text", group=groupColors)

string groupAlerts = "06. Alerts"
bool alertExpansion = input.bool(false, "Alert on expansion regime", group=groupAlerts)
bool alertClimax = input.bool(false, "Alert on climax regime", group=groupAlerts)
bool alertsOnCloseOnly = input.bool(true, "Alerts only after bar close", group=groupAlerts)

participationVolume = switch volumeMode
    "Financial volume" => volume * priceSource
    "Normalized financial volume" => volume * priceSource / normalizeDivisor
    => volume

fastBaseline = ta.ema(participationVolume, fastLength)
slowBaseline = ta.sma(participationVolume, slowLength)
logVolume = math.log(participationVolume + 1.0)
logMean = ta.sma(logVolume, zLength)
logStdDev = ta.stdev(logVolume, zLength)
relativeFast = fastBaseline > 0.0 ? participationVolume / fastBaseline : na
relativeSlow = slowBaseline > 0.0 ? participationVolume / slowBaseline : na
volumeZ = logStdDev > 0.0 ? (logVolume - logMean) / logStdDev : 0.0

isClimax = volumeZ >= climaxZ
isExpansion = not isClimax and relativeFast >= expansionMin
isQuiet = not isClimax and relativeFast < quietMax
regimeName = isClimax ? "Climax" : isExpansion ? "Expansion" : isQuiet ? "Quiet" : "Normal"
baseColor = isClimax ? climaxColor : isExpansion ? expansionColor : isQuiet ? quietColor : normalColor
isBelowSlow = not na(slowBaseline) and participationVolume < slowBaseline
regimeColor = dimBelowSlow and isBelowSlow ? color.new(baseColor, dimTransparency) : baseColor

plot(participationVolume, "Participation volume", color=regimeColor, style=plot.style_columns, linewidth=2)
plot(showFastBaseline ? fastBaseline : na, "Fast participation baseline", color=fastColor, linewidth=1)
plot(showSlowBaseline ? slowBaseline : na, "Slow participation baseline", color=slowColor, linewidth=1, style=plot.style_circles)
plot(relativeFast, "Relative volume vs fast baseline", color=regimeColor, display=display.data_window)
plot(relativeSlow, "Relative volume vs slow baseline", color=regimeColor, display=display.data_window)
plot(volumeZ, "Log-volume z-score", color=regimeColor, display=display.data_window)

var array<label> climaxLabels = array.new_label()
if showClimaxLabels and isClimax and barstate.isconfirmed
    labelY = participationVolume * (1.0 + labelOffsetPct / 100.0)
    array.push(climaxLabels, label.new(bar_index, labelY, "CLX", style=label.style_label_down, color=climaxColor, textcolor=labelTextColor, size=size.small))
    if array.size(climaxLabels) > maxClimaxLabels
        label.delete(array.shift(climaxLabels))

confirmed = alertsOnCloseOnly ? barstate.isconfirmed : true
enteredExpansion = isExpansion and isExpansion[1] != true
enteredClimax = isClimax and isClimax[1] != true
alertcondition(alertExpansion and confirmed and enteredExpansion, "Participation expansion", "Operebem VolumePRO: expansion regime on {{ticker}} {{interval}}.")
alertcondition(alertClimax and confirmed and enteredClimax, "Participation climax", "Operebem VolumePRO: log-volume climax on {{ticker}} {{interval}}.")

tableAnchor = switch tablePosition
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Top Right" => position.top_right
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right" => position.middle_right
    "Bottom Left" => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

var table regimeTable = table.new(tableAnchor, 2, 4, frame_color=tableHeaderColor, frame_width=1, border_color=tableHeaderColor, border_width=1)
if barstate.islast
    table.clear(regimeTable, 0, 0, 1, 3)
    if showInfoTable
        table.cell(regimeTable, 0, 0, "VolumePRO", text_color=tableTextColor, bgcolor=tableHeaderColor)
        table.cell(regimeTable, 1, 0, regimeName, text_color=labelTextColor, bgcolor=baseColor)
        table.cell(regimeTable, 0, 1, "RelVol fast", text_color=tableTextColor, bgcolor=tableHeaderColor)
        table.cell(regimeTable, 1, 1, str.tostring(relativeFast, "#.00x"), text_color=tableTextColor, bgcolor=tableValueColor)
        table.cell(regimeTable, 0, 2, "RelVol slow", text_color=tableTextColor, bgcolor=tableHeaderColor)
        table.cell(regimeTable, 1, 2, str.tostring(relativeSlow, "#.00x"), text_color=tableTextColor, bgcolor=tableValueColor)
        table.cell(regimeTable, 0, 3, "Log z-score", text_color=tableTextColor, bgcolor=tableHeaderColor)
        table.cell(regimeTable, 1, 3, str.tostring(volumeZ, "#.00"), text_color=tableTextColor, bgcolor=tableValueColor)
````
