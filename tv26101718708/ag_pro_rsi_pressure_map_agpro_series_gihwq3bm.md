# AG Pro RSI Pressure Map [AGPro Series]

- url: https://www.tradingview.com/script/gIhWq3BM-AG-Pro-RSI-Pressure-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;696dc198981845ae968880bf46836050
- version: 8.0

## Description

[b]AG Pro RSI Pressure Map [AGPro Series][/b]

[b]OVERVIEW[/b]

AG Pro RSI Pressure Map is an overlay indicator that interprets RSI behavior as directional pressure on price rather than presenting RSI as a standalone oscillator panel. The script maps bullish and bearish pressure conditions directly on the chart, highlights confirmed pressure builds, and separates those states from release conditions and internal weakening.

The goal is not to repeat standard RSI threshold usage such as simple overbought/oversold signals. Instead, this script translates RSI persistence, slope, trend alignment, and price response efficiency into a chart-based pressure model. The result is a structure-aware visual framework that helps users evaluate whether momentum is building, fading, or attempting to reassert itself.

This tool is designed for traders who prefer price-chart context over isolated oscillator readings. By keeping the logic on the main chart, it becomes easier to observe how directional pressure develops around swings, pullbacks, transitions, and continuation attempts.

[image]https://www.tradingview.com/x/CcIsZpwZ/[/image]

[b]UNIQUE EDGE[/b]

The distinctive idea behind this script is that RSI is not treated here as a one-line trigger engine. Instead, RSI is used as a pressure input inside a multi-step state model. A bullish or bearish condition is not activated by a single threshold alone. It requires a combination of persistence, slope, trend-side alignment, and minimum response quality.

That makes this script structurally different from conventional RSI overlays or threshold markers. It does not simply mark every move above or below a level. It attempts to identify whether price is actually behaving like a pressure phase, whether that phase lasts long enough to matter, and whether the move later transitions into a release or a weakening sequence.

Another important distinction is the use of zone persistence and signal spacing. Short-lived fluctuations are filtered by minimum zone duration, paint delay, cooldown spacing, and failure-lock logic. This helps reduce repetitive chart clutter and keeps the output more focused on pressure phases that remain contextually relevant for more than a single bar.

[b]WHAT THE SCRIPT DOES[/b]

This indicator classifies chart behavior into a small number of practical states:

- Bullish Pressure
- Bearish Pressure
- Bullish Release
- Bearish Release
- Pressure Failure
- No Active Zone

Pressure zones are displayed as soft background states once a valid zone remains active long enough to pass the paint delay requirement. Signal markers and optional labels identify important transitions, including new pressure builds and release conditions. A panel summarizes the current state so users can quickly read the broader condition without scanning every marker.

The script is intended to help with context and organization. It is not limited to trend continuation use only. It can also help identify when an apparent move is weakening internally or when a previous stretch phase may be transitioning into a more constructive re-engagement.

[b]METHODOLOGY[/b]

The script combines several components into a single state engine:

1. RSI baseline calculation  
RSI is calculated from user-defined length and can optionally be smoothed. This creates the base momentum input for the pressure model.

2. RSI slope and persistence  
The script evaluates whether RSI is rising or falling, and whether that direction persists across a configurable lookback window. This helps distinguish stable directional pressure from one-bar fluctuation.

3. Trend alignment  
Price is compared against a trend EMA so the script can evaluate whether a pressure condition is aligned with the prevailing side of the market. This reduces cases where RSI alone may look strong while price structure remains inconsistent.

4. Price response efficiency  
The model checks whether recent price movement is meaningful relative to ATR. This is used to filter low-quality pressure states where RSI movement exists but price response is weak.

5. Zone state logic  
A bullish or bearish pressure state is only activated when the required conditions are present and remains active until exit logic invalidates it. Minimum zone duration and flat cooldown logic are used to reduce rapid state flipping.

6. Release logic  
Release conditions are derived from pressure transitions that also satisfy contextual requirements such as recent stretch history and price-side confirmation. This is meant to make release signals more selective than ordinary threshold crosses.

7. Failure logic  
The script can detect internal weakening inside an active zone when slope deteriorates and response quality drops. Failure-lock behavior is used to avoid excessive repetition inside the same pressure phase.

Because the model works through a state engine rather than isolated threshold events, the output is better understood as a pressure map than as a classical oscillator trigger set.

[b]SIGNALS AND ALERTS[/b]

The script provides the following event types:

- Bullish Pressure Build
- Bearish Pressure Build
- Bullish Release Confirmed
- Bearish Release Confirmed
- Pressure Failure

These alerts are meant to notify users about state transitions, not to replace trade planning or execution rules. A pressure build does not automatically imply continuation. A release does not guarantee reversal or acceleration. A failure does not guarantee collapse. Each event is best interpreted in the context of structure, liquidity, volatility, and timeframe.

[b]KEY INPUTS[/b]

RSI Length  
Controls the base RSI period.

RSI Smoothing  
Applies optional smoothing to RSI before state evaluation.

Trend EMA Length  
Defines the trend alignment reference.

Persistence Lookback / Minimum Persistence Count  
Control how stable RSI direction must be before a pressure state becomes valid.

Bull Entry RSI / Bear Entry RSI  
Set the activation thresholds for bullish and bearish pressure.

Bull Exit RSI / Bear Exit RSI  
Define when active pressure zones can terminate.

Minimum Push Efficiency  
Filters low-quality states where RSI movement is not supported by sufficient price response.

Release Lookback  
Controls how far back the script checks for recent stretch context before validating release behavior.

Minimum Zone Bars / Flat Cooldown Bars  
Reduce rapid flip behavior and help pressure zones remain more stable.

Zone Paint Delay  
Prevents immediate background painting on very early bars of a new zone.

Build Label Offset / Release Label Offset / Failure Label Offset  
Allow spacing between labels and candles for cleaner presentation.

Build Label Minimum Gap Bars / Release Label Minimum Gap Bars  
Reduce repeated labels on the same side and improve chart readability.

[b]HOW TO READ IT[/b]

A bullish pressure zone means the script currently sees persistent bullish-side momentum that remains aligned with trend-side conditions and minimum response requirements. A bearish pressure zone means the same on the downside.

A bullish release is not simply “bullish RSI.” It represents a more selective re-engagement condition built on prior context. The bearish release follows the same idea in reverse.

A pressure failure suggests that the active zone may be weakening internally. This is not a standalone reversal call. It is a cautionary state that says the current pressure phase is losing quality.

The panel should be read as a summary layer:
- RSI State shows the active state classification
- Pressure Bias shows the normalized directional bias
- Stretch Status shows whether RSI is in an extreme region
- Structure Align shows whether price and RSI are aligned
- Signal State shows the latest meaningful state event

[b]LIMITATIONS AND TRANSPARENCY[/b]

This script is not a prediction engine and should not be interpreted as one. It is a state-classification tool built from RSI behavior, EMA alignment, ATR-normalized response, and rule-based persistence logic.

Like all chart tools, it is sensitive to timeframe selection, volatility regime, and market structure. A setting combination that feels appropriate on one symbol or timeframe may be too loose or too strict on another.

The script also does not solve broader market context. It does not evaluate macro conditions, volume profile, order flow, news, or execution quality. Users should treat it as a chart-organization tool, not as a complete trading framework.

The output is intentionally selective, but any filter system involves trade-offs. More filtering may reduce noise while also delaying some transitions. Less filtering may make the script more responsive while increasing signal density.

This indicator should be used as a supporting layer for chart reading, not as a substitute for risk management, independent analysis, or confirmation from the user’s own process.

[b]WHAT THIS SCRIPT IS NOT[/b]

- Not a basic RSI overbought/oversold marker set
- Not a simple RSI 50-line crossover script
- Not a buy/sell guarantee system
- Not a replacement for execution rules
- Not a full strategy with entries, exits, and sizing logic

It is a rule-based pressure mapping tool designed to help visualize directional momentum states on price.

[b]RISK DISCLOSURE[/b]

This indicator is for analysis and chart interpretation only. It does not provide financial advice, investment advice, or guaranteed outcomes. All trading involves risk, including the risk of loss. Users should test settings, validate behavior on their own markets and timeframes, and make independent decisions based on their own methodology and risk tolerance.

## Source Code

````pine
// -------------------------------------------------
// RSI Pressure Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 3.5
//
// RSI pressure map, momentum persistence zones, bullish and bearish RSI
// pressure transitions, pressure shelf mapping, release confirmation, fade
// detection, and compact state diagnostics for overlay trading workflows.
// Built to show where RSI pressure is building, holding, stretching, and
// releasing directly on the price chart. Version 3.5 keeps one current owned
// shelf by default to eliminate clustered shelf-badge superposition.
// -------------------------------------------------

//@version=6
indicator("RSI Pressure Map [AGPro Series]",
     shorttitle = "AG Pro RSI",
     overlay = true,
     max_labels_count = 200,
     max_boxes_count = 140)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
coreGroup   = "Core Engine"
logicGroup  = "Pressure Logic"
zoneGroup   = "Zone Map"
signalGroup = "Signals & Labels"
panelGroup  = "Panel"
alertGroup  = "Alerts"

rsiLen = input.int(14, "RSI Length", minval = 2, group = coreGroup,
     tooltip = "Base RSI period used to measure directional momentum pressure.")
rsiSmoothLen = input.int(3, "RSI Smoothing", minval = 1, group = coreGroup,
     tooltip = "EMA smoothing applied to RSI. Higher values reduce noisy flips but respond more slowly.")
trendLen = input.int(34, "Trend EMA Length", minval = 2, group = coreGroup,
     tooltip = "Trend filter used to align RSI pressure states with the current price structure.")
atrLen = input.int(14, "ATR Length", minval = 1, group = coreGroup,
     tooltip = "ATR period used for label offsets, pressure shelves, and envelope width.")
pressureBasisLen = input.int(13, "Pressure Basis EMA", minval = 2, group = coreGroup,
     tooltip = "EMA centerline used to anchor the active pressure envelope around price.")

persistenceLen = input.int(5, "Persistence Lookback", minval = 2, maxval = 50, group = logicGroup,
     tooltip = "Number of bars used to evaluate whether RSI is persistently advancing or declining.")
persistNeed = input.int(3, "Minimum Persistence Count", minval = 1, maxval = 20, group = logicGroup,
     tooltip = "Minimum count of directional RSI bars required before a pressure state can activate.")
upperExtreme = input.int(68, "Upper RSI Stretch", minval = 50, maxval = 95, group = logicGroup,
     tooltip = "Upper RSI stretch threshold used to identify mature bullish pressure and release context.")
lowerExtreme = input.int(32, "Lower RSI Stretch", minval = 5, maxval = 50, group = logicGroup,
     tooltip = "Lower RSI stretch threshold used to identify mature bearish pressure and release context.")
bullEntryLevel = input.float(53.0, "Bull Entry RSI", minval = 45.0, maxval = 80.0, step = 0.5, group = logicGroup,
     tooltip = "Minimum RSI level required to start a bullish pressure state.")
bearEntryLevel = input.float(47.0, "Bear Entry RSI", minval = 20.0, maxval = 55.0, step = 0.5, group = logicGroup,
     tooltip = "Maximum RSI level allowed to start a bearish pressure state.")
bullExitLevel = input.float(48.0, "Bull Exit RSI", minval = 35.0, maxval = 55.0, step = 0.5, group = logicGroup,
     tooltip = "Bullish pressure ends when RSI weakens below this level or trend alignment breaks.")
bearExitLevel = input.float(52.0, "Bear Exit RSI", minval = 45.0, maxval = 65.0, step = 0.5, group = logicGroup,
     tooltip = "Bearish pressure ends when RSI rises above this level or trend alignment breaks.")
bullReleaseLevel = input.float(56.0, "Bull Release RSI", minval = 50.0, maxval = 80.0, step = 0.5, group = logicGroup,
     tooltip = "RSI level required to confirm bullish release after a lower-stretch context.")
bearReleaseLevel = input.float(44.0, "Bear Release RSI", minval = 20.0, maxval = 50.0, step = 0.5, group = logicGroup,
     tooltip = "RSI level required to confirm bearish release after an upper-stretch context.")
minPushEff = input.float(0.80, "Minimum Push Efficiency", minval = 0.10, maxval = 5.00, step = 0.05, group = logicGroup,
     tooltip = "Minimum ATR-normalized price displacement required to validate pressure building.")
releaseLookback = input.int(12, "Release Lookback", minval = 3, maxval = 100, group = logicGroup,
     tooltip = "Bars inspected for a prior RSI stretch before a release can be confirmed.")
minZoneBars = input.int(5, "Minimum Zone Bars", minval = 1, maxval = 50, group = logicGroup,
     tooltip = "Minimum active pressure age required before a pressure state can end normally.")
flatCooldownBars = input.int(3, "Flat Cooldown Bars", minval = 0, maxval = 20, group = logicGroup,
     tooltip = "Cooldown after a completed pressure zone before a fresh pressure state may start.")
failureMinBars = input.int(6, "Fade Minimum Zone Bars", minval = 1, maxval = 50, group = logicGroup,
     tooltip = "Minimum active pressure age before internal pressure fade logic becomes eligible.")
failureSlopeTh = input.float(0.90, "Fade RSI Slope Threshold", minval = 0.10, maxval = 5.00, step = 0.10, group = logicGroup,
     tooltip = "RSI slope deterioration required to mark internal pressure fade.")
failureEffFactor = input.float(0.85, "Fade Efficiency Factor", minval = 0.50, maxval = 1.50, step = 0.05, group = logicGroup,
     tooltip = "Pressure fade requires efficiency to drop below this fraction of the entry efficiency threshold.")

showZoneTint = input.bool(false, "Show Background Tint", group = zoneGroup,
     tooltip = "Tints the chart background during confirmed RSI pressure states.")
showPressureBoxes = input.bool(true, "Show Pressure Shelves", group = zoneGroup,
     tooltip = "Draws extended rectangular pressure shelves around active and recently completed RSI pressure zones.")
showShelfLabels = input.bool(true, "Show Active Shelf Badge", group = zoneGroup,
     tooltip = "Adds a centered Bull or Bear badge inside the active pressure shelf so the live zone is labeled.")
showPressureBand = input.bool(true, "Show Pressure Envelope", group = zoneGroup,
     tooltip = "Draws a basis line with an ATR envelope during active pressure states.")
showBarTint = input.bool(false, "Tint Bars", group = zoneGroup,
     tooltip = "Applies a subtle bullish or bearish tint to candles while a pressure state is active.")
zonePaintDelay = input.int(2, "Zone Paint Delay", minval = 1, maxval = 20, group = zoneGroup,
     tooltip = "Pressure shelves and stronger visual layers appear only after the active state survives this many bars.")
pressureBandATR = input.float(0.65, "Envelope ATR Width", minval = 0.10, maxval = 5.00, step = 0.05, group = zoneGroup,
     tooltip = "ATR width used for the active pressure envelope.")
zonePaddingATR = input.float(0.18, "Zone Padding ATR", minval = 0.00, maxval = 2.00, step = 0.02, group = zoneGroup,
     tooltip = "Extra ATR padding added above and below pressure shelves for a cleaner visual buffer.")
zoneProjectBars = input.int(12, "Zone Projection Bars", minval = 0, maxval = 100, group = zoneGroup,
     tooltip = "Projects pressure shelves to the right for better continuity without turning them into permanent levels.")
keepRecentBoxes = input.int(1, "Keep Recent Shelves", minval = 1, maxval = 6, group = zoneGroup,
     tooltip = "Maximum number of owned pressure shelves kept on the chart. The premium default keeps only the latest shelf to prevent historical shelf and badge superposition.")

showMarkers = input.bool(false, "Show Markers", group = signalGroup,
     tooltip = "Optionally displays compact build, release, and fade markers. Off by default because the filled event badges already own the same signals.")
showTextLabels = input.bool(true, "Show Text Labels", group = signalGroup,
     tooltip = "Displays selective text labels with controlled density and ATR-based offsets.")
labelMode = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Active"], group = signalGroup,
     tooltip = "Minimal keeps only the strongest labels. Balanced is the premium default. Active shows more context labels.")
showFadeTextLabels = input.bool(false, "Show Fade Text Labels", group = signalGroup,
     tooltip = "Adds text labels for internal pressure fade events. Off by default to keep the chart polished.")
labelTextSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = signalGroup,
     tooltip = "Font size used for chart text labels.")
labelShiftBars = input.int(3, "Label Shift Bars", minval = 0, maxval = 10, group = signalGroup,
     tooltip = "Moves labels to the right so they stay clear of candle bodies.")
labelAnchorLookback = input.int(3, "Label Anchor Lookback", minval = 1, maxval = 20, group = signalGroup,
     tooltip = "Uses the local swing high or low across this many bars as the label anchor before the ATR offset is applied.")
labelOffsetATR = input.float(1.30, "Build Label Offset (ATR)", minval = 0.10, maxval = 6.00, step = 0.05, group = signalGroup,
     tooltip = "ATR offset used for build labels so they do not disappear inside candles.")
releaseLabelOffsetATR = input.float(1.55, "Release Label Offset (ATR)", minval = 0.10, maxval = 6.00, step = 0.05, group = signalGroup,
     tooltip = "ATR offset used for release labels.")
fadeLabelOffsetATR = input.float(1.30, "Fade Label Offset (ATR)", minval = 0.10, maxval = 6.00, step = 0.05, group = signalGroup,
     tooltip = "ATR offset used for pressure fade labels.")
buildQualityMultiplier = input.float(1.15, "Build Label Quality Multiplier", minval = 1.00, maxval = 2.00, step = 0.05, group = signalGroup,
     tooltip = "Build labels appear only when push efficiency exceeds this multiplier over the minimum threshold.")
buildLabelGapBars = input.int(34, "Build Label Minimum Gap", minval = 0, maxval = 100, group = signalGroup,
     tooltip = "Minimum spacing between repeated build labels.")
releaseLabelGapBars = input.int(26, "Release Label Minimum Gap", minval = 0, maxval = 100, group = signalGroup,
     tooltip = "Minimum spacing between repeated release labels.")
fadeLabelGapBars = input.int(24, "Fade Label Minimum Gap", minval = 0, maxval = 100, group = signalGroup,
     tooltip = "Minimum spacing between repeated fade labels.")
signalCooldown = input.int(8, "Signal Cooldown Bars", minval = 0, maxval = 100, group = signalGroup,
     tooltip = "Prevents signal events from clustering too tightly.")
keepRecentLabels = input.int(24, "Keep Recent Text Labels", minval = 5, maxval = 100, group = signalGroup,
     tooltip = "Maximum number of text labels kept on the chart.")

showPanel = input.bool(true, "Show Panel", group = panelGroup,
     tooltip = "Shows the compact RSI pressure state panel.")
panelMode = input.string("Full", "Panel Mode", options = ["Compact", "Full"], group = panelGroup,
     tooltip = "Compact shows essential state rows. Full adds zone, phase, and stretch context.")
panelPos = input.string("Top Right", "Panel Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = panelGroup,
     tooltip = "Placement of the panel on the chart.")
themeMode = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = panelGroup,
     tooltip = "Independent theme control for the panel and labels.")
panelTextSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = panelGroup,
     tooltip = "Font size used by the panel.")

enableBullBuildAlert = input.bool(true, "Bullish Pressure Build", group = alertGroup,
     tooltip = "Enables alerts when a new bullish RSI pressure state is confirmed.")
enableBearBuildAlert = input.bool(true, "Bearish Pressure Build", group = alertGroup,
     tooltip = "Enables alerts when a new bearish RSI pressure state is confirmed.")
enableBullReleaseAlert = input.bool(true, "Bullish Release Confirmed", group = alertGroup,
     tooltip = "Enables alerts when bullish release is confirmed after lower RSI stretch context.")
enableBearReleaseAlert = input.bool(true, "Bearish Release Confirmed", group = alertGroup,
     tooltip = "Enables alerts when bearish release is confirmed after upper RSI stretch context.")
enableFadeAlert = input.bool(true, "Pressure Fade", group = alertGroup,
     tooltip = "Enables alerts when internal pressure quality deteriorates inside an active zone.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(_s) =>
    switch _s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_label_sep_atr(_s) =>
    switch _s
        "Tiny" => 1.00
        "Small" => 1.15
        "Large" => 1.55
        => 1.35

f_panel_pos(_p) =>
    switch _p
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_clamp(_x, _min, _max) =>
    math.max(_min, math.min(_max, _x))

f_reg(_x, _y, _bars, _ys) =>
    array.push(_bars, _x)
    array.push(_ys, _y)
    if array.size(_bars) > 20
        array.shift(_bars)
        array.shift(_ys)

f_resolve_y(_x, _yBase, _dir, _sep, _bars, _ys) =>
    float _y = _yBase
    bool _clash = true
    int _g = 0
    while _clash and _g < 14
        _clash := false
        if array.size(_bars) > 0
            for _i = 0 to array.size(_bars) - 1
                if math.abs(_x - array.get(_bars, _i)) <= 10 and math.abs(_y - array.get(_ys, _i)) < _sep
                    _y := _y + _dir * _sep
                    _clash := true
        _g += 1
    f_reg(_x, _y, _bars, _ys)
    _y

f_state_text(_state, _bullStretch, _bearStretch, _bullRelease, _bearRelease) =>
    string _out = "Neutral"
    if _bullRelease
        _out := "Bullish Release"
    else if _bearRelease
        _out := "Bearish Release"
    else if _bullStretch
        _out := "Bullish Stretch"
    else if _bearStretch
        _out := "Bearish Stretch"
    else if _state == 1
        _out := "Bullish Pressure"
    else if _state == -1
        _out := "Bearish Pressure"
    _out

f_signal_text(_bullBuild, _bearBuild, _bullRelease, _bearRelease, _fade) =>
    string _out = "Idle"
    if _bullRelease
        _out := "Bullish Release"
    else if _bearRelease
        _out := "Bearish Release"
    else if _bullBuild
        _out := "Bullish Build"
    else if _bearBuild
        _out := "Bearish Build"
    else if _fade
        _out := "Pressure Fade"
    _out

f_bias_text(_score) =>
    string _out = "Balanced"
    if _score >= 20
        _out := "Bullish"
    else if _score <= -20
        _out := "Bearish"
    _out

f_alignment_text(_close, _ema, _rsi) =>
    string _out = "Mixed"
    if _close > _ema and _rsi >= 50
        _out := "Bullish Alignment"
    else if _close < _ema and _rsi <= 50
        _out := "Bearish Alignment"
    _out

f_stretch_text(_rsi, _upper, _lower) =>
    string _out = "Normal"
    if _rsi >= _upper
        _out := "Upper Stretch"
    else if _rsi <= _lower
        _out := "Lower Stretch"
    _out

f_phase_text(_state, _bars, _delay, _minBars, _scoreAbs) =>
    string _out = "Flat"
    if _state != 0
        if _bars <= _delay
            _out := "Forming"
        else if _bars < _minBars
            _out := "Building"
        else if _scoreAbs >= 55
            _out := "High Quality"
        else
            _out := "Holding"
    _out

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgDark   = color.rgb(15, 23, 42)
panelBgLight  = color.rgb(248, 250, 252)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

f_text_on(_c) =>
    _lum = (color.r(_c) * 299 + color.g(_c) * 587 + color.b(_c) * 114) / 1000
    _lum >= 145 ? color.rgb(17, 24, 39) : headerText

panelBg = themeMode == "Dark" ? panelBgDark : panelBgLight
panelRowA = themeMode == "Dark" ? color.rgb(10, 18, 34) : color.rgb(255, 255, 255)
panelRowB = themeMode == "Dark" ? color.rgb(8, 15, 28) : color.rgb(241, 245, 249)
labelCol = themeMode == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
valueCol = themeMode == "Dark" ? panelValueCol : color.rgb(15, 23, 42)
rowBullBg = themeMode == "Dark" ? color.rgb(8, 56, 48) : color.rgb(209, 250, 229)
rowBearBg = themeMode == "Dark" ? color.rgb(82, 24, 54) : color.rgb(252, 231, 243)
rowNeutralBg = themeMode == "Dark" ? color.rgb(78, 60, 18) : color.rgb(254, 249, 195)
rowAccentBg = themeMode == "Dark" ? color.rgb(49, 46, 129) : color.rgb(224, 231, 255)

bullZoneBg = color.new(bullColor, 92)
bearZoneBg = color.new(bearColor, 92)
bullBoxBg = color.new(bullColor, 86)
bearBoxBg = color.new(bearColor, 86)
bullBoxBgFaded = color.new(bullColor, 92)
bearBoxBgFaded = color.new(bearColor, 92)
bullBorderFaded = color.new(bullColor, 35)
bearBorderFaded = color.new(bearColor, 35)

bullLabelBg = color.new(bullColor, 8)
bearLabelBg = color.new(bearColor, 8)
releaseBg = color.new(accentColor, 0)
fadeBg = color.new(neutralColor, 0)

bullTextOnBg = f_text_on(bullColor)
bearTextOnBg = f_text_on(bearColor)
neutralTextOnBg = f_text_on(neutralColor)
accentTextOnBg = f_text_on(accentColor)

// -------------------------------------------------
// Core Series
// -------------------------------------------------
rsiRaw = ta.rsi(close, rsiLen)
rsi = rsiSmoothLen > 1 ? ta.ema(rsiRaw, rsiSmoothLen) : rsiRaw
rsiSlope = rsi - rsi[1]
emaTrend = ta.ema(close, trendLen)
pressureBasis = ta.ema(hlc3, pressureBasisLen)
atr = ta.atr(atrLen)
atrSafe = na(atr) ? syminfo.mintick : math.max(atr, syminfo.mintick)

upPersist = math.sum(rsi > rsi[1] ? 1.0 : 0.0, persistenceLen)
dnPersist = math.sum(rsi < rsi[1] ? 1.0 : 0.0, persistenceLen)
pushEff = math.abs(close - close[persistenceLen]) / atrSafe
trendDist = (close - emaTrend) / atrSafe

bullPressureReady = rsi >= bullEntryLevel and rsiSlope > 0 and upPersist >= persistNeed and close >= emaTrend and pushEff >= minPushEff
bearPressureReady = rsi <= bearEntryLevel and rsiSlope < 0 and dnPersist >= persistNeed and close <= emaTrend and pushEff >= minPushEff

bullStretch = rsi >= upperExtreme and rsiSlope < 0
bearStretch = rsi <= lowerExtreme and rsiSlope > 0
recentOversold = ta.lowest(rsi, releaseLookback) <= lowerExtreme
recentOverbought = ta.highest(rsi, releaseLookback) >= upperExtreme

// -------------------------------------------------
// Pressure State Engine
// -------------------------------------------------
var int zoneState = 0
var int zoneBars = 0
var int lastFlatBar = na

prevZoneState = nz(zoneState[1], 0)
prevZoneBars = nz(zoneBars[1], 0)

zoneState := prevZoneState
zoneBars := prevZoneState == 0 ? 0 : prevZoneBars + 1

canEnterAfterFlat = na(lastFlatBar) or bar_index - lastFlatBar > flatCooldownBars
canEndBull = prevZoneState == 1 and prevZoneBars >= minZoneBars and (rsi < bullExitLevel or close < emaTrend or rsiSlope < 0)
canEndBear = prevZoneState == -1 and prevZoneBars >= minZoneBars and (rsi > bearExitLevel or close > emaTrend or rsiSlope > 0)

if prevZoneState == 0
    if canEnterAfterFlat and bullPressureReady and not bearPressureReady
        zoneState := 1
        zoneBars := 1
    else if canEnterAfterFlat and bearPressureReady and not bullPressureReady
        zoneState := -1
        zoneBars := 1
    else
        zoneState := 0
        zoneBars := 0
else if prevZoneState == 1
    if canEndBull
        zoneState := 0
        zoneBars := 0
    else
        zoneState := 1
        zoneBars := prevZoneBars + 1
else if prevZoneState == -1
    if canEndBear
        zoneState := 0
        zoneBars := 0
    else
        zoneState := -1
        zoneBars := prevZoneBars + 1

if prevZoneState != 0 and zoneState == 0
    lastFlatBar := bar_index

zoneStarted = zoneState != 0 and prevZoneState != zoneState
zoneEnded = prevZoneState != 0 and zoneState == 0
zoneActive = zoneState != 0

bullBuildRaw = zoneState == 1 and prevZoneState != 1
bearBuildRaw = zoneState == -1 and prevZoneState != -1
bullReleaseRaw = zoneState == 1 and zoneBars >= minZoneBars and recentOversold and ta.crossover(rsi, bullReleaseLevel) and close >= pressureBasis and close > open
bearReleaseRaw = zoneState == -1 and zoneBars >= minZoneBars and recentOverbought and ta.crossunder(rsi, bearReleaseLevel) and close <= pressureBasis and close < open

weakBullInside = zoneState == 1 and zoneBars >= failureMinBars and rsiSlope <= -failureSlopeTh and pushEff < minPushEff * failureEffFactor and close < pressureBasis
weakBearInside = zoneState == -1 and zoneBars >= failureMinBars and rsiSlope >= failureSlopeTh and pushEff < minPushEff * failureEffFactor and close > pressureBasis
pressureFadeRaw = weakBullInside or weakBearInside

// -------------------------------------------------
// Signal Cooldowns
// -------------------------------------------------
var int lastBullBuildBar = na
var int lastBearBuildBar = na
var int lastBullReleaseBar = na
var int lastBearReleaseBar = na
var int lastFadeBar = na

bullRelease = bullReleaseRaw and (na(lastBullReleaseBar) or bar_index - lastBullReleaseBar > signalCooldown)
if bullRelease
    lastBullReleaseBar := bar_index

bearRelease = bearReleaseRaw and (na(lastBearReleaseBar) or bar_index - lastBearReleaseBar > signalCooldown)
if bearRelease
    lastBearReleaseBar := bar_index

bullBuild = bullBuildRaw and not bullRelease and (na(lastBullBuildBar) or bar_index - lastBullBuildBar > signalCooldown)
if bullBuild
    lastBullBuildBar := bar_index

bearBuild = bearBuildRaw and not bearRelease and (na(lastBearBuildBar) or bar_index - lastBearBuildBar > signalCooldown)
if bearBuild
    lastBearBuildBar := bar_index

pressureFade = pressureFadeRaw and (na(lastFadeBar) or bar_index - lastFadeBar > signalCooldown)
if pressureFade
    lastFadeBar := bar_index

bullFade = pressureFade and zoneState == 1
bearFade = pressureFade and zoneState == -1

// -------------------------------------------------
// Score and State Text
// -------------------------------------------------
rsiScore = na(rsi) ? 50.0 : rsi
rsiSlopeScore = na(rsiSlope) ? 0.0 : rsiSlope
upPersistScore = na(upPersist) ? 0.0 : upPersist
dnPersistScore = na(dnPersist) ? 0.0 : dnPersist
trendDistScore = na(trendDist) ? 0.0 : trendDist
pushEffScore = na(pushEff) ? 0.0 : pushEff

bullScoreCore = ((rsiScore - 50.0) * 0.75) + (rsiSlopeScore * 4.0) + (upPersistScore * 2.2) + (trendDistScore * 5.0) + (pushEffScore * 3.0)
bearScoreCore = ((50.0 - rsiScore) * 0.75) + ((-rsiSlopeScore) * 4.0) + (dnPersistScore * 2.2) + ((-trendDistScore) * 5.0) + (pushEffScore * 3.0)
scoreRaw = bullScoreCore - bearScoreCore
pressureScore = f_clamp((scoreRaw / (30.0 + math.abs(scoreRaw))) * 100.0, -100.0, 100.0)
scoreAbs = math.abs(pressureScore)

stateText = f_state_text(zoneState, bullStretch, bearStretch, bullRelease, bearRelease)
signalText = f_signal_text(bullBuild, bearBuild, bullRelease, bearRelease, pressureFade)
biasText = f_bias_text(pressureScore)
alignmentText = f_alignment_text(close, emaTrend, rsi)
stretchText = f_stretch_text(rsi, upperExtreme, lowerExtreme)
phaseText = f_phase_text(zoneState, zoneBars, zonePaintDelay, minZoneBars, scoreAbs)

// -------------------------------------------------
// Pressure Shelf Engine
// -------------------------------------------------
var box activeZoneBox = na
var label activeZoneLabel = na
var float activeZoneHigh = na
var float activeZoneLow = na
var array<box> pressureBoxes = array.new_box()
var array<label> pressureShelfLabels = array.new_label()

if zoneStarted
    activeZoneHigh := high + atrSafe * zonePaddingATR
    activeZoneLow := low - atrSafe * zonePaddingATR
else if zoneActive
    activeZoneHigh := math.max(nz(activeZoneHigh, high), high + atrSafe * zonePaddingATR)
    activeZoneLow := math.min(nz(activeZoneLow, low), low - atrSafe * zonePaddingATR)

if showPressureBoxes
    if zoneActive and zoneBars >= zonePaintDelay
        zoneSideColor = zoneState == 1 ? bullColor : bearColor
        zoneBgColor = zoneState == 1 ? bullBoxBg : bearBoxBg
        zoneLeftBars = math.min(math.max(zoneBars - 1, 0), 5000)
        zoneLeft = bar_index - zoneLeftBars
        shelfCenterX = int((zoneLeft + bar_index + zoneProjectBars) / 2)
        shelfCenterY = (activeZoneHigh + activeZoneLow) / 2
        shelfText = (zoneState == 1 ? "BULL SHELF  " : "BEAR SHELF  ") + str.tostring(math.round(scoreAbs))
        bool newShelfCreated = false
        bool newShelfLabelCreated = false
        if na(activeZoneBox)
            activeZoneBox := box.new(
                 left = zoneLeft,
                 top = activeZoneHigh,
                 right = bar_index + zoneProjectBars,
                 bottom = activeZoneLow,
                 xloc = xloc.bar_index,
                 border_color = zoneSideColor,
                 bgcolor = zoneBgColor,
                 border_width = 1)
            newShelfCreated := true
        else
            box.set_left(activeZoneBox, zoneLeft)
            box.set_right(activeZoneBox, bar_index + zoneProjectBars)
            box.set_top(activeZoneBox, activeZoneHigh)
            box.set_bottom(activeZoneBox, activeZoneLow)
            box.set_border_color(activeZoneBox, zoneSideColor)
            box.set_bgcolor(activeZoneBox, zoneBgColor)
        if showShelfLabels
            if na(activeZoneLabel)
                activeZoneLabel := label.new(shelfCenterX, shelfCenterY, shelfText, style = label.style_label_center, color = color.new(zoneSideColor, 8), textcolor = f_text_on(zoneSideColor), size = f_size(labelTextSize), xloc = xloc.bar_index)
                newShelfLabelCreated := true
            else
                label.set_xy(activeZoneLabel, shelfCenterX, shelfCenterY)
                label.set_text(activeZoneLabel, shelfText)
                label.set_color(activeZoneLabel, color.new(zoneSideColor, 8))
                label.set_textcolor(activeZoneLabel, f_text_on(zoneSideColor))
                label.set_size(activeZoneLabel, f_size(labelTextSize))
        else
            if not na(activeZoneLabel)
                label.delete(activeZoneLabel)
                activeZoneLabel := na
                if array.size(pressureShelfLabels) > 0
                    array.set(pressureShelfLabels, array.size(pressureShelfLabels) - 1, na)
        if newShelfCreated
            array.push(pressureBoxes, activeZoneBox)
            array.push(pressureShelfLabels, activeZoneLabel)
            if array.size(pressureBoxes) > keepRecentBoxes
                oldBox = array.shift(pressureBoxes)
                oldShelfLabel = array.shift(pressureShelfLabels)
                box.delete(oldBox)
                if not na(oldShelfLabel)
                    label.delete(oldShelfLabel)
        else if newShelfLabelCreated and array.size(pressureShelfLabels) > 0
            array.set(pressureShelfLabels, array.size(pressureShelfLabels) - 1, activeZoneLabel)
    if zoneEnded
        if not na(activeZoneBox)
            box.set_right(activeZoneBox, bar_index + zoneProjectBars)
            box.set_border_color(activeZoneBox, prevZoneState == 1 ? bullBorderFaded : bearBorderFaded)
            box.set_bgcolor(activeZoneBox, prevZoneState == 1 ? bullBoxBgFaded : bearBoxBgFaded)
        if not na(activeZoneLabel)
            endedSideColor = prevZoneState == 1 ? bullColor : bearColor
            label.set_color(activeZoneLabel, color.new(endedSideColor, 22))
            label.set_textcolor(activeZoneLabel, f_text_on(endedSideColor))
            activeZoneLabel := na
        activeZoneBox := na
else
    if array.size(pressureBoxes) > 0
        for i = 0 to array.size(pressureBoxes) - 1
            oldBox = array.get(pressureBoxes, i)
            box.delete(oldBox)
        array.clear(pressureBoxes)
    if array.size(pressureShelfLabels) > 0
        for i = 0 to array.size(pressureShelfLabels) - 1
            oldShelfLabel = array.get(pressureShelfLabels, i)
            if not na(oldShelfLabel)
                label.delete(oldShelfLabel)
        array.clear(pressureShelfLabels)
    activeZoneLabel := na
    activeZoneBox := na

if zoneEnded
    activeZoneHigh := na
    activeZoneLow := na

zoneSpanPct = zoneActive and not na(activeZoneHigh) and not na(activeZoneLow) and close != 0.0 ? ((activeZoneHigh - activeZoneLow) / close) * 100.0 : na
zoneSpanText = zoneActive and not na(zoneSpanPct) ? str.tostring(zoneSpanPct, "#.##") + "%" : "Inactive"
zoneAgeText = zoneActive ? str.tostring(zoneBars) + " bars" : "Flat"

// -------------------------------------------------
// Visual Layers
// -------------------------------------------------
paintBull = showZoneTint and zoneState == 1 and zoneBars >= zonePaintDelay
paintBear = showZoneTint and zoneState == -1 and zoneBars >= zonePaintDelay
bgcolor(paintBull ? bullZoneBg : paintBear ? bearZoneBg : na)
barcolor(showBarTint ? zoneState == 1 and zoneBars >= zonePaintDelay ? color.new(bullColor, 35) : zoneState == -1 and zoneBars >= zonePaintDelay ? color.new(bearColor, 35) : na : na)

bandMid = showPressureBand and zoneActive and zoneBars >= zonePaintDelay ? pressureBasis : na
bandUpper = showPressureBand and zoneActive and zoneBars >= zonePaintDelay ? pressureBasis + atrSafe * pressureBandATR : na
bandLower = showPressureBand and zoneActive and zoneBars >= zonePaintDelay ? pressureBasis - atrSafe * pressureBandATR : na
bandEdgeColor = zoneState == 1 ? bullColor : bearColor

pMid = plot(bandMid, "Pressure Basis", color = zoneActive ? accentColor : na, linewidth = 2)
pUpper = plot(bandUpper, "Pressure Envelope Upper", color = zoneActive ? color.new(bandEdgeColor, 10) : na, linewidth = 1)
pLower = plot(bandLower, "Pressure Envelope Lower", color = zoneActive ? color.new(bandEdgeColor, 10) : na, linewidth = 1)
fill(pUpper, pLower, color = zoneState == 1 ? color.new(bullColor, 88) : zoneState == -1 ? color.new(bearColor, 88) : na)

// -------------------------------------------------
// Markers
// -------------------------------------------------
plotshape(showMarkers and bullBuild, title = "Bullish Pressure Build", style = shape.triangleup, location = location.belowbar, size = size.small, color = bullColor)
plotshape(showMarkers and bearBuild, title = "Bearish Pressure Build", style = shape.triangledown, location = location.abovebar, size = size.small, color = bearColor)
plotshape(showMarkers and bullRelease, title = "Bullish Release", style = shape.circle, location = location.belowbar, size = size.small, color = accentColor)
plotshape(showMarkers and bearRelease, title = "Bearish Release", style = shape.circle, location = location.abovebar, size = size.small, color = accentColor)
plotshape(showMarkers and bullFade, title = "Bullish Pressure Fade", style = shape.xcross, location = location.abovebar, size = size.tiny, color = neutralColor)
plotshape(showMarkers and bearFade, title = "Bearish Pressure Fade", style = shape.xcross, location = location.belowbar, size = size.tiny, color = neutralColor)

// -------------------------------------------------
// Label Engine
// -------------------------------------------------
labelLowAnchor = ta.lowest(low, labelAnchorLookback)
labelHighAnchor = ta.highest(high, labelAnchorLookback)
labelCollisionSep = atrSafe * f_label_sep_atr(labelTextSize)

var array<label> signalLabels = array.new_label()
var float[] lblBars = array.new_float()
var float[] lblYs = array.new_float()
var int lastBullBuildLabelBar = na
var int lastBearBuildLabelBar = na
var int lastBullReleaseLabelBar = na
var int lastBearReleaseLabelBar = na
var int lastBullFadeLabelBar = na
var int lastBearFadeLabelBar = na

buildGapUsed = labelMode == "Minimal" ? buildLabelGapBars + 10 : labelMode == "Balanced" ? buildLabelGapBars : math.max(6, buildLabelGapBars - 8)
releaseGapUsed = labelMode == "Minimal" ? releaseLabelGapBars + 6 : labelMode == "Balanced" ? releaseLabelGapBars : math.max(4, releaseLabelGapBars - 6)
fadeGapUsed = labelMode == "Minimal" ? fadeLabelGapBars + 8 : labelMode == "Balanced" ? fadeLabelGapBars : math.max(6, fadeLabelGapBars - 8)

strongBullBuildLabel = bullBuild and pushEff >= minPushEff * buildQualityMultiplier and trendDist >= 0.15 and rsi >= bullEntryLevel + 1.0
strongBearBuildLabel = bearBuild and pushEff >= minPushEff * buildQualityMultiplier and trendDist <= -0.15 and rsi <= bearEntryLevel - 1.0
premiumBullBuildLabel = labelMode == "Minimal" ? strongBullBuildLabel and upPersist >= persistNeed + 1 : strongBullBuildLabel
premiumBearBuildLabel = labelMode == "Minimal" ? strongBearBuildLabel and dnPersist >= persistNeed + 1 : strongBearBuildLabel

canShowBullBuildLabel = na(lastBullBuildLabelBar) or bar_index - lastBullBuildLabelBar >= buildGapUsed
canShowBearBuildLabel = na(lastBearBuildLabelBar) or bar_index - lastBearBuildLabelBar >= buildGapUsed
canShowBullReleaseLabel = na(lastBullReleaseLabelBar) or bar_index - lastBullReleaseLabelBar >= releaseGapUsed
canShowBearReleaseLabel = na(lastBearReleaseLabelBar) or bar_index - lastBearReleaseLabelBar >= releaseGapUsed
canShowBullFadeLabel = na(lastBullFadeLabelBar) or bar_index - lastBullFadeLabelBar >= fadeGapUsed
canShowBearFadeLabel = na(lastBearFadeLabelBar) or bar_index - lastBearFadeLabelBar >= fadeGapUsed

if showTextLabels and premiumBullBuildLabel and canShowBullBuildLabel
    lbl = label.new(
         x = bar_index + labelShiftBars,
         y = f_resolve_y(bar_index + labelShiftBars, labelLowAnchor - atrSafe * labelOffsetATR, -1.0, labelCollisionSep, lblBars, lblYs),
         xloc = xloc.bar_index,
         text = "Bull Pressure",
         style = label.style_label_up,
         color = bullLabelBg,
         textcolor = bullTextOnBg,
         size = f_size(labelTextSize))
    array.push(signalLabels, lbl)
    if array.size(signalLabels) > keepRecentLabels
        oldLbl = array.shift(signalLabels)
        label.delete(oldLbl)
    lastBullBuildLabelBar := bar_index

if showTextLabels and premiumBearBuildLabel and canShowBearBuildLabel
    lbl = label.new(
         x = bar_index + labelShiftBars,
         y = f_resolve_y(bar_index + labelShiftBars, labelHighAnchor + atrSafe * labelOffsetATR, 1.0, labelCollisionSep, lblBars, lblYs),
         xloc = xloc.bar_index,
         text = "Bear Pressure",
         style = label.style_label_down,
         color = bearLabelBg,
         textcolor = bearTextOnBg,
         size = f_size(labelTextSize))
    array.push(signalLabels, lbl)
    if array.size(signalLabels) > keepRecentLabels
        oldLbl = array.shift(signalLabels)
        label.delete(oldLbl)
    lastBearBuildLabelBar := bar_index

if showTextLabels and bullRelease and canShowBullReleaseLabel
    lbl = label.new(
         x = bar_index + labelShiftBars,
         y = f_resolve_y(bar_index + labelShiftBars, labelLowAnchor - atrSafe * releaseLabelOffsetATR, -1.0, labelCollisionSep, lblBars, lblYs),
         xloc = xloc.bar_index,
         text = "Bull Release",
         style = label.style_label_up,
         color = releaseBg,
         textcolor = accentTextOnBg,
         size = f_size(labelTextSize))
    array.push(signalLabels, lbl)
    if array.size(signalLabels) > keepRecentLabels
        oldLbl = array.shift(signalLabels)
        label.delete(oldLbl)
    lastBullReleaseLabelBar := bar_index

if showTextLabels and bearRelease and canShowBearReleaseLabel
    lbl = label.new(
         x = bar_index + labelShiftBars,
         y = f_resolve_y(bar_index + labelShiftBars, labelHighAnchor + atrSafe * releaseLabelOffsetATR, 1.0, labelCollisionSep, lblBars, lblYs),
         xloc = xloc.bar_index,
         text = "Bear Release",
         style = label.style_label_down,
         color = releaseBg,
         textcolor = accentTextOnBg,
         size = f_size(labelTextSize))
    array.push(signalLabels, lbl)
    if array.size(signalLabels) > keepRecentLabels
        oldLbl = array.shift(signalLabels)
        label.delete(oldLbl)
    lastBearReleaseLabelBar := bar_index

if showTextLabels and showFadeTextLabels and bullFade and canShowBullFadeLabel
    lbl = label.new(
         x = bar_index + labelShiftBars,
         y = f_resolve_y(bar_index + labelShiftBars, labelHighAnchor + atrSafe * fadeLabelOffsetATR, 1.0, labelCollisionSep, lblBars, lblYs),
         xloc = xloc.bar_index,
         text = "Pressure Fade",
         style = label.style_label_down,
         color = fadeBg,
         textcolor = neutralTextOnBg,
         size = f_size(labelTextSize))
    array.push(signalLabels, lbl)
    if array.size(signalLabels) > keepRecentLabels
        oldLbl = array.shift(signalLabels)
        label.delete(oldLbl)
    lastBullFadeLabelBar := bar_index

if showTextLabels and showFadeTextLabels and bearFade and canShowBearFadeLabel
    lbl = label.new(
         x = bar_index + labelShiftBars,
         y = f_resolve_y(bar_index + labelShiftBars, labelLowAnchor - atrSafe * fadeLabelOffsetATR, -1.0, labelCollisionSep, lblBars, lblYs),
         xloc = xloc.bar_index,
         text = "Pressure Fade",
         style = label.style_label_up,
         color = fadeBg,
         textcolor = neutralTextOnBg,
         size = f_size(labelTextSize))
    array.push(signalLabels, lbl)
    if array.size(signalLabels) > keepRecentLabels
        oldLbl = array.shift(signalLabels)
        label.delete(oldLbl)
    lastBearFadeLabelBar := bar_index

// -------------------------------------------------
// Build follow-through proof (directional)
// -------------------------------------------------
// From each pressure build, did price travel one ATR in the pressure direction
// before traveling one ATR against it? Win = pressure-side first, Loss = against
// first, neither inside the window = uncounted.
var int   pfTotal = 0
var int   pfWins  = 0
var bool  pfOpen  = false
var int   pfDir   = 0
var float pfWinLvl  = na
var float pfStopLvl = na
var int   pfBar   = na
int pfWindow = 20

if barstate.isconfirmed
    if pfOpen
        bool pfWin  = pfDir == 1 ? high >= pfWinLvl : low <= pfWinLvl
        bool pfLoss = pfDir == 1 ? low <= pfStopLvl : high >= pfStopLvl
        if pfWin and not pfLoss
            pfTotal += 1
            pfWins  += 1
            pfOpen  := false
        else if pfLoss
            pfTotal += 1
            pfOpen  := false
        else if not na(pfBar) and bar_index - pfBar > pfWindow
            pfOpen := false
    if (bullBuild or bearBuild) and not pfOpen
        pfOpen    := true
        pfDir     := bullBuild ? 1 : -1
        pfWinLvl  := bullBuild ? close + atrSafe : close - atrSafe
        pfStopLvl := bullBuild ? close - atrSafe : close + atrSafe
        pfBar     := bar_index

float pfRate = pfTotal > 0 ? pfWins / pfTotal * 100.0 : na
followText = pfTotal >= 6 ? str.tostring(math.round(pfRate)) + "%  (" + str.tostring(pfTotal) + ")" : "Building (" + str.tostring(pfTotal) + ")"
followCol = pfTotal >= 6 ? (pfRate >= 55.0 ? bullColor : pfRate >= 45.0 ? neutralColor : bearColor) : valueCol
followBg = pfTotal >= 6 ? (pfRate >= 55.0 ? rowBullBg : pfRate >= 45.0 ? rowNeutralBg : rowBearBg) : panelRowB

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = na
var string lastPanelPos = ""

if barstate.isfirst or panelPos != lastPanelPos
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPos), 2, 9, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelPos := panelPos

stateValueBg = bullRelease ? rowAccentBg : bearRelease ? rowAccentBg : zoneState == 1 ? rowBullBg : zoneState == -1 ? rowBearBg : panelRowA
stateValueCol = bullRelease or bearRelease ? accentColor : zoneState == 1 ? bullColor : zoneState == -1 ? bearColor : valueCol
biasValueBg = pressureScore >= 20 ? rowBullBg : pressureScore <= -20 ? rowBearBg : panelRowB
biasValueCol = pressureScore >= 20 ? bullColor : pressureScore <= -20 ? bearColor : valueCol
stretchValueBg = rsi >= upperExtreme or rsi <= lowerExtreme ? rowNeutralBg : panelRowA
stretchValueCol = rsi >= upperExtreme or rsi <= lowerExtreme ? neutralColor : valueCol
alignValueBg = alignmentText == "Bullish Alignment" ? rowBullBg : alignmentText == "Bearish Alignment" ? rowBearBg : panelRowB
alignValueCol = alignmentText == "Bullish Alignment" ? bullColor : alignmentText == "Bearish Alignment" ? bearColor : valueCol
zoneSpanValueBg = zoneState == 1 ? rowBullBg : zoneState == -1 ? rowBearBg : panelRowA
zoneSpanValueCol = zoneState == 1 ? bullColor : zoneState == -1 ? bearColor : valueCol
signalValueBg = bullRelease or bearRelease ? rowAccentBg : pressureFade ? rowNeutralBg : bullBuild ? rowBullBg : bearBuild ? rowBearBg : panelRowB
signalValueCol = bullRelease or bearRelease ? accentColor : pressureFade ? neutralColor : bullBuild ? bullColor : bearBuild ? bearColor : valueCol
phaseValueBg = zoneState == 1 ? rowBullBg : zoneState == -1 ? rowBearBg : panelRowB
phaseValueCol = zoneState == 1 ? bullColor : zoneState == -1 ? bearColor : valueCol

if barstate.islast and not na(panel)
    table.clear(panel, 0, 0, 1, 8)

    if showPanel
        table.cell(panel, 0, 0, "AG Pro RSI Pressure Map", text_color = headerText, text_size = f_size(panelTextSize), bgcolor = headerBg)
        table.cell(panel, 1, 0, "",                            text_color = headerText, text_size = f_size(panelTextSize), bgcolor = headerBg)
        table.merge_cells(panel, 0, 0, 1, 0)

        table.cell(panel, 0, 1, "Pressure State", text_color = labelCol, text_size = f_size(panelTextSize), bgcolor = panelRowA)
        table.cell(panel, 1, 1, stateText, text_color = stateValueCol, text_size = f_size(panelTextSize), bgcolor = stateValueBg)

        table.cell(panel, 0, 2, "Bias Score", text_color = labelCol, text_size = f_size(panelTextSize), bgcolor = panelRowB)
        table.cell(panel, 1, 2, biasText + " (" + str.tostring(math.round(pressureScore)) + ")", text_color = biasValueCol, text_size = f_size(panelTextSize), bgcolor = biasValueBg)

        table.cell(panel, 0, 3, panelMode == "Full" ? "Phase" : "Structure", text_color = labelCol, text_size = f_size(panelTextSize), bgcolor = panelRowA)
        table.cell(panel, 1, 3, panelMode == "Full" ? phaseText : alignmentText, text_color = panelMode == "Full" ? phaseValueCol : alignValueCol, text_size = f_size(panelTextSize), bgcolor = panelMode == "Full" ? phaseValueBg : alignValueBg)

        table.cell(panel, 0, 4, panelMode == "Full" ? "Stretch" : "Signal State", text_color = labelCol, text_size = f_size(panelTextSize), bgcolor = panelRowB)
        table.cell(panel, 1, 4, panelMode == "Full" ? stretchText : signalText, text_color = panelMode == "Full" ? stretchValueCol : signalValueCol, text_size = f_size(panelTextSize), bgcolor = panelMode == "Full" ? stretchValueBg : signalValueBg)

        if panelMode == "Full"
            table.cell(panel, 0, 5, "Structure", text_color = labelCol, text_size = f_size(panelTextSize), bgcolor = panelRowA)
            table.cell(panel, 1, 5, alignmentText, text_color = alignValueCol, text_size = f_size(panelTextSize), bgcolor = alignValueBg)

            table.cell(panel, 0, 6, "Shelf Span", text_color = labelCol, text_size = f_size(panelTextSize), bgcolor = panelRowB)
            table.cell(panel, 1, 6, zoneSpanText, text_color = zoneSpanValueCol, text_size = f_size(panelTextSize), bgcolor = zoneSpanValueBg)

            table.cell(panel, 0, 7, "Signal State", text_color = labelCol, text_size = f_size(panelTextSize), bgcolor = panelRowA)
            table.cell(panel, 1, 7, signalText + " | " + zoneAgeText, text_color = signalValueCol, text_size = f_size(panelTextSize), bgcolor = signalValueBg)

        followRow = panelMode == "Full" ? 8 : 5
        table.cell(panel, 0, followRow, "Follow Rate", text_color = labelCol, text_size = f_size(panelTextSize), bgcolor = panelRowB)
        table.cell(panel, 1, followRow, followText, text_color = followCol, text_size = f_size(panelTextSize), bgcolor = followBg)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(enableBullBuildAlert and bullBuild, title = "Bullish Pressure Build", message = "RSI Pressure Map: Bullish Pressure Build")
alertcondition(enableBearBuildAlert and bearBuild, title = "Bearish Pressure Build", message = "RSI Pressure Map: Bearish Pressure Build")
alertcondition(enableBullReleaseAlert and bullRelease, title = "Bullish Release Confirmed", message = "RSI Pressure Map: Bullish Release Confirmed")
alertcondition(enableBearReleaseAlert and bearRelease, title = "Bearish Release Confirmed", message = "RSI Pressure Map: Bearish Release Confirmed")
alertcondition(enableFadeAlert and pressureFade, title = "Pressure Fade", message = "RSI Pressure Map: Pressure Fade")
````
