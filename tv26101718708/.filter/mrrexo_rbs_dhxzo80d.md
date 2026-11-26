# MrRexo RBS

- url: https://www.tradingview.com/script/DhXZo80D/
- type: indicator
- pine_id: PUB;c2218fc37eb249b4ae6b108d251c55ad
- version: 3.0

## Description

# MrRexo Setup

MrRexo Setup is an open-source market structure and setup-mapping indicator for TradingView. It combines higher-timeframe bias, previous-period levels, all-time high tracking, BOS, FVG, price GAPs, high/low moving average bands, and optional entry markers in one chart overlay.

The script is designed for a dark, technical chart layout and is intended to help traders quickly read directional context, structure breaks, imbalance zones, and potential continuation setups without stacking multiple separate indicators.

## What This Indicator Shows

MrRexo Setup focuses on several core areas:

- Higher-timeframe bias for daily, weekly, and monthly context.
- Previous day, week, and month high/low levels.
- All-time high based on the chart history available to the script.
- Break of Structure levels.
- Fair Value Gaps.
- Candle-to-candle price GAPs.
- Distance and estimated closure probability for the nearest FVG and GAP above and below price.
- Fast and slow high/low moving average bands.
- Optional LONG/SHORT setup markers based on band behavior.

## Bias Panel

The compact panel shows directional bias for:

- D - daily bias
- W - weekly bias
- M - monthly bias

Bias can be calculated using either:

- close versus previous range,
- fast/slow moving average relationship.

The panel also shows the nearest FVG and GAP distance in both directions, together with a heuristic closure probability.

## Previous-Period Levels

The indicator can draw:

- PDH - previous day high
- PDL - previous day low
- PWH - previous week high
- PWL - previous week low
- PMH - previous month high
- PML - previous month low
- ATH - all-time high from available chart history

Each group has configurable colors, labels, line style, line width, and extension behavior.

## Market Structure

Break of Structure is detected using pivot-based structure levels. BOS labels are placed directly on the structure line to keep them visually different from entry markers.

Bullish and bearish BOS colors can be configured independently.

## FVG and GAP Zones

The script detects both Fair Value Gaps and candle-to-candle price GAPs.

FVG features:

- wick or body based definition,
- minimum size in ticks,
- right extension,
- optional hide-after-fill behavior,
- configurable expiration in days,
- label with date and size in ticks.

GAP features:

- minimum size in ticks,
- right extension,
- optional hide-after-fill behavior,
- configurable expiration in days,
- label with date and size in ticks,
- partial consumption: the GAP zone shrinks as price fills it and disappears after full closure.

## Moving Average Bands

MrRexo Setup includes fast and slow high/low bands. Each band is calculated from high and low prices, not just close.

Supported average types:

- EMA
- SMA
- SMMA
- WMA

Default band settings:

- Fast band: 33
- Slow band: 144
- Band type: WMA

## Entry Markers

The indicator can show optional LONG/SHORT setup markers. These are not strategy orders and do not execute trades.

Supported signal types:

- Cross through band
- Return to band
- Bounce from band

Each entry marker is displayed as:

- L for long setups,
- S for short setups,
- a vertical line from the signal candle upward,
- a tooltip with the full signal type, such as SHORT BOUNCE F or LONG RETURN S.

Entry labels can be positioned using:

- Dynamic top
- Range top
- Fixed price

This makes it possible to keep markers visually aligned at the top of the chart.

## Default Settings

Default values are tuned for a clean, technical layout:

- Fast/slow bands: 33/144
- Band type: WMA
- Minimum FVG size: 80 ticks
- Minimum GAP size: 150 ticks
- FVG/GAP expiration: 14 days
- Entry signal spacing: 15 minutes
- Bias background: disabled by default
- GAP and FVG zones: extended to the right by default

All key colors, labels, line widths, visibility toggles, and zone settings can be adjusted from the indicator settings panel.

## Important Notes

This is an indicator, not a strategy. It does not place orders, run backtests, or provide financial advice.

ATH is calculated from the historical data available to the script on the current TradingView chart. It may differ depending on symbol type, chart history, futures contract settings, continuous contract adjustments, and available data.

The closure probability shown for GAPs and FVGs is a heuristic model based on distance and zone age. It is not a statistical guarantee.

Use this tool as part of a broader trading plan, with your own confirmation process and risk management.

## Suggested Tags

market structure, bias, BOS, FVG, gap, price action, support resistance, trend, WMA, EMA, multi timeframe, liquidity, trading setup

## Source Code

````pine
//@version=6
indicator("MrRexo RBS", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)
// RBS version: 0.6.3

// -----------------------------------------------------------------------------
// Settings
// -----------------------------------------------------------------------------
generalGroup = "General"
visibilityGroup = "Visibility"
showPanel = input.bool(true, "Show bias panel", group=visibilityGroup)
showBiasBackground = input.bool(false, "Show daily bias background", group=visibilityGroup)
showFastBand = input.bool(true, "Show fast H/L band", group=visibilityGroup)
showSlowBand = input.bool(true, "Show slow H/L band", group=visibilityGroup)
showEmaStack = input.bool(false, "Show EMA stack", group=visibilityGroup)
showEntrySignals = input.bool(false, "Show entry signals", group=visibilityGroup)
showCurrentDayLevels = input.bool(true, "Show current day high/low", group=visibilityGroup)
showDailyLevels = input.bool(true, "Show previous day high/low", group=visibilityGroup)
showWeeklyLevels = input.bool(true, "Show previous week high/low", group=visibilityGroup)
showMonthlyLevels = input.bool(false, "Show previous month high/low", group=visibilityGroup)
showAthLevel = input.bool(true, "Show all-time high", group=visibilityGroup)
showSessionFib = input.bool(true, "Show session Fibonacci", group=visibilityGroup)
showSydneyFib = input.bool(false, "Show Sydney Fibonacci", group=visibilityGroup)
showTokyoFib = input.bool(false, "Show Tokyo Fibonacci", group=visibilityGroup)
showLondonFib = input.bool(true, "Show London Fibonacci", group=visibilityGroup)
showNewYorkFib = input.bool(true, "Show New York Fibonacci", group=visibilityGroup)
showBos = input.bool(true, "Show BOS", group=visibilityGroup)
showFvg = input.bool(false, "Show FVG", group=visibilityGroup)
showGaps = input.bool(true, "Show GAPs", group=visibilityGroup)
showEstimatedCvd = input.bool(false, "Show estimated CVD", group=visibilityGroup)
showDeltaProfile = input.bool(false, "Show estimated delta profile", group=visibilityGroup)

panelPositionInput = input.string("Top right", "Panel position", options=["Top right", "Middle right", "Bottom right", "Top left", "Middle left", "Bottom left"], group=generalGroup)
panelSizeInput = input.string("Normal", "Panel size", options=["Tiny", "Small", "Normal", "Large"], group=generalGroup)
panelTextColor = input.color(color.new(color.lime, 0), "Panel text color", group=generalGroup)
panelBgColor = input.color(color.new(color.black, 8), "Panel background color", group=generalGroup)

biasGroup = "Bias and trend"
biasMethod = input.string("Fast/slow average", "Bias method", options=["Close vs previous range", "Fast/slow average"], group=biasGroup)
maType = input.string("EMA", "Average type", options=["EMA", "SMA", "SMMA", "WMA"], group=biasGroup)
fastMaLength = input.int(33, "Fast average", minval=1, group=biasGroup)
slowMaLength = input.int(144, "Slow average", minval=1, group=biasGroup)
bullishBiasColor = input.color(color.new(color.lime, 88), "Bullish bias color", group=biasGroup)
bearishBiasColor = input.color(color.new(color.red, 88), "Bearish bias color", group=biasGroup)
neutralBiasColor = input.color(color.new(color.gray, 92), "Neutral bias color", group=biasGroup)

bandsGroup = "High/low average bands"
bandMaType = input.string("WMA", "Band average type", options=["EMA", "SMA", "SMMA", "WMA"], group=bandsGroup)
fastBandLength = input.int(33, "Fast band length", minval=1, group=bandsGroup)
slowBandLength = input.int(144, "Slow band length", minval=1, group=bandsGroup)
fastBandFillColor = input.color(color.new(color.red, 88), "Fast band color", group=bandsGroup)
slowBandFillColor = input.color(color.new(color.blue, 90), "Slow band color", group=bandsGroup)
bandLineWidth = input.int(1, "Band line width", minval=1, maxval=5, group=bandsGroup)

emaStackGroup = "EMA stack"
emaFastLength = input.int(9, "Fast EMA length", minval=1, group=emaStackGroup)
emaMidLength = input.int(21, "Middle EMA length", minval=1, group=emaStackGroup)
emaSlowLength = input.int(50, "Slow EMA length", minval=1, group=emaStackGroup)
emaFastColor = input.color(color.new(color.lime, 0), "Fast EMA color", group=emaStackGroup)
emaMidColor = input.color(color.new(color.orange, 0), "Middle EMA color", group=emaStackGroup)
emaSlowColor = input.color(color.new(color.aqua, 0), "Slow EMA color", group=emaStackGroup)
emaStackLineWidth = input.int(1, "EMA line width", minval=1, maxval=5, group=emaStackGroup)

entryGroup = "Entry signals"
enableLongSignals = input.bool(true, "Enable LONG signals", group=entryGroup)
enableShortSignals = input.bool(true, "Enable SHORT signals", group=entryGroup)
enableCrossSignals = input.bool(true, "Enable entry: cross through band", group=entryGroup)
enableReturnSignals = input.bool(true, "Enable entry: return to band", group=entryGroup)
enableBounceSignals = input.bool(true, "Enable entry: bounce from band", group=entryGroup)
enableBetweenBandsSignals = input.bool(true, "Enable entry: move between bands", group=entryGroup)
entrySignalBands = input.string("Both", "Signal bands", options=["Fast", "Slow", "Both"], group=entryGroup)
sameBarPriority = input.string("Fast", "Same-bar priority", options=["Fast", "Slow"], group=entryGroup)
signalSpacingMinutes = input.int(15, "Minimum spacing between signals in minutes", minval=0, group=entryGroup)
minBandGapTicks = input.int(0, "Minimum gap between bands in ticks", minval=0, group=entryGroup)
trendLookbackBars = input.int(5, "Trend filter lookback bars", minval=1, group=entryGroup)
maxBarsToCrossBand = input.int(10, "Max bars to cross signal band", minval=1, group=entryGroup)
maxBarsToReturnBand = input.int(20, "Max bars to return to band", minval=1, group=entryGroup)
entrySignalLineWidth = input.int(1, "Entry signal line width", minval=1, maxval=5, group=entryGroup)
entrySignalLabelPlacement = input.string("Range top", "Entry label placement", options=["Dynamic top", "Range top", "Fixed price"], group=entryGroup)
entrySignalTopLookbackBars = input.int(150, "Entry label top range bars", minval=10, maxval=1000, group=entryGroup)
entrySignalTopAtrOffset = input.float(0.5, "Entry label top ATR offset", minval=0.0, maxval=10.0, step=0.1, group=entryGroup)
entrySignalFixedPrice = input.float(0.0, "Entry label fixed price", minval=0.0, step=0.25, group=entryGroup)
maxEntrySignalMarks = input.int(120, "Maximum entry signal marks", minval=1, maxval=300, group=entryGroup)
longSignalBgColor = input.color(color.new(color.green, 15), "LONG label background", group=entryGroup)
longSignalTextColor = input.color(color.white, "LONG signal text", group=entryGroup)
shortSignalBgColor = input.color(color.new(color.red, 15), "SHORT label background", group=entryGroup)
shortSignalTextColor = input.color(color.white, "SHORT signal text", group=entryGroup)

levelsGroup = "Period levels"
showLevelLabels = input.bool(true, "Show level labels", group=levelsGroup)
levelExtendInput = input.string("Left", "Level extension", options=["None", "Left", "Right", "Both"], group=levelsGroup)
levelWidth = input.int(1, "Level line width", minval=1, maxval=5, group=levelsGroup)
levelStyleInput = input.string("Dotted", "Level line style", options=["Solid", "Dashed", "Dotted"], group=levelsGroup)
currentDayLevelColor = input.color(color.new(color.teal, 0), "Current day line and label color", group=levelsGroup)
currentDayLabelTextColor = input.color(color.white, "Current day label text", group=levelsGroup)
dailyLevelColor = input.color(color.new(color.lime, 0), "Daily line and label color", group=levelsGroup)
dailyLabelTextColor = input.color(color.white, "Daily label text", group=levelsGroup)
weeklyLevelColor = input.color(color.new(color.aqua, 0), "Weekly line and label color", group=levelsGroup)
weeklyLabelTextColor = input.color(color.white, "Weekly label text", group=levelsGroup)
monthlyLevelColor = input.color(color.new(color.fuchsia, 0), "Monthly line and label color", group=levelsGroup)
monthlyLabelTextColor = input.color(color.white, "Monthly label text", group=levelsGroup)
athLevelColor = input.color(color.new(color.yellow, 0), "ATH line and label color", group=levelsGroup)
athLabelTextColor = input.color(color.black, "ATH label text", group=levelsGroup)

sessionFibGroup = "Session Fibonacci"
sessionFibTimezone = input.string("Etc/UTC", "Fibonacci sessions timezone", group=sessionFibGroup)
sydneyFibSession = input.session("2100-0600", "Sydney session", group=sessionFibGroup)
sydneyFibColor = input.color(color.new(color.aqua, 0), "Sydney Fibonacci color", group=sessionFibGroup)
tokyoFibSession = input.session("0000-0900", "Tokyo session", group=sessionFibGroup)
tokyoFibColor = input.color(color.new(color.lime, 0), "Tokyo Fibonacci color", group=sessionFibGroup)
londonFibSession = input.session("0700-1600", "London session", group=sessionFibGroup)
londonFibColor = input.color(color.new(color.yellow, 0), "London Fibonacci color", group=sessionFibGroup)
newYorkFibSession = input.session("1330-2200", "New York session", group=sessionFibGroup)
newYorkFibColor = input.color(color.new(color.fuchsia, 0), "New York Fibonacci color", group=sessionFibGroup)
showSessionFibLabels = input.bool(true, "Show Fibonacci labels", group=sessionFibGroup)
sessionFibTextColor = input.color(color.black, "Fibonacci label text", group=sessionFibGroup)
sessionFibLabelBgColor = input.color(color.new(color.yellow, 0), "Fibonacci label background", group=sessionFibGroup)
sessionFibLineWidth = input.int(1, "Fibonacci line width", minval=1, maxval=5, group=sessionFibGroup)
sessionFibStyleInput = input.string("Dotted", "Fibonacci line style", options=["Solid", "Dashed", "Dotted"], group=sessionFibGroup)

bosGroup = "BOS - Break of Structure"
bosPivotLength = input.int(5, "BOS pivot length", minval=1, maxval=50, group=bosGroup)
showBosLines = input.bool(true, "Show BOS lines", group=bosGroup)
showBosLabels = input.bool(true, "Show BOS labels", group=bosGroup)
bullishBosColor = input.color(color.new(color.lime, 0), "Bullish BOS color", group=bosGroup)
bearishBosColor = input.color(color.new(color.red, 0), "Bearish BOS color", group=bosGroup)
bullishBosLabelTextColor = input.color(color.white, "Bullish BOS text", group=bosGroup)
bearishBosLabelTextColor = input.color(color.white, "Bearish BOS text", group=bosGroup)
maxBosMarks = input.int(80, "Maximum BOS marks", minval=1, maxval=200, group=bosGroup)

fvgGroup = "FVG - Fair Value Gap"
fvgMode = input.string("Wicks", "FVG definition", options=["Wicks", "Bodies"], group=fvgGroup)
minFvgTicks = input.int(80, "Minimum FVG size in ticks", minval=0, group=fvgGroup)
extendFvg = input.bool(true, "Extend active FVGs to the right", group=fvgGroup)
hideFilledFvg = input.bool(true, "Hide FVG after fill", group=fvgGroup)
fvgExpiryDays = input.int(14, "FVG validity in days (0 = no limit)", minval=0, group=fvgGroup)
showFvgLabels = input.bool(true, "Show FVG label with date", group=fvgGroup)
bullishFvgColor = input.color(color.new(color.lime, 88), "Bullish FVG color", group=fvgGroup)
bearishFvgColor = input.color(color.new(color.red, 88), "Bearish FVG color", group=fvgGroup)
fvgBorderColor = input.color(color.new(color.lime, 62), "FVG border color", group=fvgGroup)
fvgLabelBgColor = input.color(color.new(color.black, 15), "FVG label background", group=fvgGroup)
fvgLabelTextColor = input.color(color.white, "FVG label text", group=fvgGroup)
maxFvgBoxes = input.int(12, "Maximum FVG zones", minval=1, maxval=200, group=fvgGroup)

gapGroup = "GAPs"
minGapTicks = input.int(150, "Minimum GAP size in ticks", minval=0, group=gapGroup)
extendGaps = input.bool(true, "Extend active GAPs to the right", group=gapGroup)
hideFilledGaps = input.bool(true, "Hide GAP after fill", group=gapGroup)
gapExpiryDays = input.int(14, "GAP validity in days (0 = no limit)", minval=0, group=gapGroup)
showGapLabels = input.bool(true, "Show GAP label with date", group=gapGroup)
bullishGapColor = input.color(color.new(color.aqua, 88), "Bullish GAP color", group=gapGroup)
bearishGapColor = input.color(color.new(color.fuchsia, 88), "Bearish GAP color", group=gapGroup)
gapBorderColor = input.color(color.new(color.aqua, 62), "GAP border color", group=gapGroup)
gapLabelBgColor = input.color(color.new(color.black, 15), "GAP label background", group=gapGroup)
gapLabelTextColor = input.color(color.white, "GAP label text", group=gapGroup)
maxGapBoxes = input.int(8, "Maximum GAP zones", minval=1, maxval=200, group=gapGroup)

probabilityGroup = "Distance and closure probability"
showDistanceRows = input.bool(true, "Show distance to nearest zones", group=probabilityGroup)
probabilityMaxDistanceTicks = input.int(200, "Distance for lowest probability in ticks", minval=1, group=probabilityGroup)
probabilityAgeBars = input.int(150, "Zone age for lowest probability in bars", minval=1, group=probabilityGroup)
probabilityMin = input.float(10.0, "Minimum closure probability (%)", minval=0.0, maxval=100.0, step=1.0, group=probabilityGroup)
probabilityMax = input.float(85.0, "Maximum closure probability (%)", minval=0.0, maxval=100.0, step=1.0, group=probabilityGroup)
probabilityDistanceWeight = input.float(70.0, "Distance weight in model (%)", minval=0.0, maxval=100.0, step=5.0, group=probabilityGroup)

cvdGroup = "Estimated CVD"
cvdResetMode = input.string("Daily", "CVD reset", options=["Daily", "None"], group=cvdGroup)
cvdLookbackBars = input.int(150, "CVD normalization lookback bars", minval=20, maxval=2000, group=cvdGroup)
cvdHeightPercent = input.float(12.0, "CVD overlay height (% of range)", minval=2.0, maxval=50.0, step=1.0, group=cvdGroup)
cvdBottomOffsetPercent = input.float(5.0, "CVD bottom offset (% of range)", minval=0.0, maxval=50.0, step=1.0, group=cvdGroup)
cvdUpColor = input.color(color.new(color.lime, 0), "Positive CVD color", group=cvdGroup)
cvdDownColor = input.color(color.new(color.red, 0), "Negative CVD color", group=cvdGroup)
cvdZeroColor = input.color(color.new(color.gray, 55), "CVD zero line color", group=cvdGroup)

deltaProfileGroup = "Estimated Delta Profile"
deltaProfileLookbackBars = input.int(250, "Profile lookback bars", minval=20, maxval=1000, group=deltaProfileGroup)
deltaProfileLevels = input.int(40, "Profile price levels", minval=10, maxval=120, group=deltaProfileGroup)
deltaProfileOffsetBars = input.int(8, "Profile offset bars", minval=1, maxval=200, group=deltaProfileGroup)
deltaProfileMaxWidthBars = input.int(35, "Profile maximum width bars", minval=5, maxval=200, group=deltaProfileGroup)
deltaProfileUpColor = input.color(color.new(color.lime, 72), "Positive delta profile color", group=deltaProfileGroup)
deltaProfileDownColor = input.color(color.new(color.red, 72), "Negative delta profile color", group=deltaProfileGroup)
deltaProfileBorderColor = input.color(color.new(color.gray, 100), "Delta profile border color", group=deltaProfileGroup)

// -----------------------------------------------------------------------------
// Helper functions
// -----------------------------------------------------------------------------
f_extend(_choice) =>
    switch _choice
        "Left" => extend.left
        "Right" => extend.right
        "Both" => extend.both
        => extend.none

f_lineStyle(_choice) =>
    switch _choice
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_panelPosition(_choice) =>
    switch _choice
        "Middle right" => position.middle_right
        "Bottom right" => position.bottom_right
        "Top left" => position.top_left
        "Middle left" => position.middle_left
        "Bottom left" => position.bottom_left
        => position.top_right

f_textSize(_choice) =>
    switch _choice
        "Tiny" => size.tiny
        "Normal" => size.normal
        "Large" => size.large
        => size.small

f_biasText(_bias) =>
    _bias > 0 ? "↑" : _bias < 0 ? "↓" : "→"

f_biasColor(_bias) =>
    _bias > 0 ? color.new(color.lime, 0) : _bias < 0 ? color.new(color.red, 0) : color.new(color.gray, 0)

f_ma(_source, _length) =>
    switch maType
        "SMA" => ta.sma(_source, _length)
        "SMMA" => ta.rma(_source, _length)
        "WMA" => ta.wma(_source, _length)
        => ta.ema(_source, _length)

f_bandMa(_source, _length) =>
    switch bandMaType
        "SMA" => ta.sma(_source, _length)
        "SMMA" => ta.rma(_source, _length)
        "WMA" => ta.wma(_source, _length)
        => ta.ema(_source, _length)

f_bias(_tf) =>
    _closeValue = request.security(syminfo.tickerid, _tf, close, barmerge.gaps_off, barmerge.lookahead_off)
    _previousHigh = request.security(syminfo.tickerid, _tf, high[1], barmerge.gaps_off, barmerge.lookahead_off)
    _previousLow = request.security(syminfo.tickerid, _tf, low[1], barmerge.gaps_off, barmerge.lookahead_off)
    _fastMa = request.security(syminfo.tickerid, _tf, f_ma(close, fastMaLength), barmerge.gaps_off, barmerge.lookahead_off)
    _slowMa = request.security(syminfo.tickerid, _tf, f_ma(close, slowMaLength), barmerge.gaps_off, barmerge.lookahead_off)
    biasMethod == "Fast/slow average" ? (_fastMa > _slowMa ? 1 : _fastMa < _slowMa ? -1 : 0) : (_closeValue > _previousHigh ? 1 : _closeValue < _previousLow ? -1 : 0)

f_setLevel(_line, _label, _price, _text, _color, _labelBgColor, _labelTextColor, _show) =>
    line _resultLine = _line
    label _resultLabel = _label
    if _show and not na(_price)
        if na(_resultLine)
            _resultLine := line.new(bar_index, _price, bar_index + 1, _price, extend=f_extend(levelExtendInput), color=_color, style=f_lineStyle(levelStyleInput), width=levelWidth)
        else
            line.set_xy1(_resultLine, bar_index, _price)
            line.set_xy2(_resultLine, bar_index + 1, _price)
            line.set_extend(_resultLine, f_extend(levelExtendInput))
            line.set_color(_resultLine, _color)
            line.set_style(_resultLine, f_lineStyle(levelStyleInput))
            line.set_width(_resultLine, levelWidth)
        if showLevelLabels
            if na(_resultLabel)
                _resultLabel := label.new(bar_index, _price, _text, style=label.style_label_left, textcolor=_labelTextColor, color=_labelBgColor, size=size.small)
            else
                label.set_xy(_resultLabel, bar_index, _price)
                label.set_text(_resultLabel, _text)
                label.set_textcolor(_resultLabel, _labelTextColor)
                label.set_color(_resultLabel, _labelBgColor)
        else if not na(_resultLabel)
            label.delete(_resultLabel)
            _resultLabel := na
    else
        if not na(_resultLine)
            line.delete(_resultLine)
            _resultLine := na
        if not na(_resultLabel)
            label.delete(_resultLabel)
            _resultLabel := na
    [_resultLine, _resultLabel]

f_trimBoxes(_boxes, _limit) =>
    while array.size(_boxes) > _limit
        _oldBox = array.shift(_boxes)
        box.delete(_oldBox)

f_trimBoxesWithLabels(_boxes, _labels, _createdTimes, _limit) =>
    while array.size(_boxes) > _limit
        _oldBox = array.shift(_boxes)
        box.delete(_oldBox)
        if array.size(_labels) > 0
            _oldLabel = array.shift(_labels)
            if not na(_oldLabel)
                label.delete(_oldLabel)
        if array.size(_createdTimes) > 0
            array.shift(_createdTimes)

f_trimLines(_lines, _labels, _limit) =>
    while array.size(_lines) > _limit
        _oldLine = array.shift(_lines)
        if not na(_oldLine)
            line.delete(_oldLine)
        if array.size(_labels) > 0
            _oldLabel = array.shift(_labels)
            if not na(_oldLabel)
                label.delete(_oldLabel)

f_updateZoneBoxes(_boxes, _isBullish, _extendRight, _hideFilled) =>
    if array.size(_boxes) > 0
        i = array.size(_boxes) - 1
        while i >= 0
            _b = array.get(_boxes, i)
            if _extendRight
                box.set_right(_b, bar_index)
            _top = box.get_top(_b)
            _bottom = box.get_bottom(_b)
            _filled = _isBullish ? low <= _bottom : high >= _top
            if _hideFilled and _filled
                box.delete(_b)
                array.remove(_boxes, i)
            i -= 1

f_updateZoneBoxesWithLabels(_boxes, _labels, _createdTimes, _isBullish, _extendRight, _hideFilled, _showLabels, _expiryDays, _consumeZone) =>
    if array.size(_boxes) > 0
        i = array.size(_boxes) - 1
        while i >= 0
            _b = array.get(_boxes, i)
            _label = array.size(_labels) > i ? array.get(_labels, i) : na
            _createdTime = array.size(_createdTimes) > i ? array.get(_createdTimes, i) : time
            if _extendRight
                box.set_right(_b, bar_index)
            _top = box.get_top(_b)
            _bottom = box.get_bottom(_b)
            _filled = _isBullish ? low <= _bottom : high >= _top
            _expired = _expiryDays > 0 and time - _createdTime >= _expiryDays * 24 * 60 * 60 * 1000
            if (_hideFilled and _filled) or _expired
                box.delete(_b)
                array.remove(_boxes, i)
                if not na(_label)
                    label.delete(_label)
                if array.size(_labels) > i
                    array.remove(_labels, i)
                if array.size(_createdTimes) > i
                    array.remove(_createdTimes, i)
            else
                if _consumeZone
                    if _isBullish and low < _top and low > _bottom
                        box.set_top(_b, low)
                        _top := low
                    if not _isBullish and high > _bottom and high < _top
                        box.set_bottom(_b, high)
                        _bottom := high
                if not na(_label)
                    if _showLabels
                        label.set_xy(_label, box.get_right(_b), (_top + _bottom) / 2.0)
                    else
                        label.delete(_label)
                        array.set(_labels, i, na)
            i -= 1

f_nearestZone(_boxes, _isBullish, _direction) =>
    float _nearestDistanceTicks = na
    int _nearestAgeBars = na
    if array.size(_boxes) > 0
        for i = 0 to array.size(_boxes) - 1
            _b = array.get(_boxes, i)
            _top = box.get_top(_b)
            _bottom = box.get_bottom(_b)
            _filled = _isBullish ? low <= _bottom : high >= _top
            _distancePrice = _direction > 0 ? _bottom - close : close - _top
            if not _filled and _distancePrice >= 0
                _distanceTicks = _distancePrice / syminfo.mintick
                if na(_nearestDistanceTicks) or _distanceTicks < _nearestDistanceTicks
                    _nearestDistanceTicks := _distanceTicks
                    _nearestAgeBars := bar_index - box.get_left(_b)
    [_nearestDistanceTicks, _nearestAgeBars]

f_pickNearest(_distanceA, _ageA, _distanceB, _ageB) =>
    float _distance = na
    int _age = na
    if na(_distanceA) and na(_distanceB)
        _distance := na
        _age := na
    else if na(_distanceB) or (not na(_distanceA) and _distanceA <= _distanceB)
        _distance := _distanceA
        _age := _ageA
    else
        _distance := _distanceB
        _age := _ageB
    [_distance, _age]

f_closeProbability(_distanceTicks, _ageBars) =>
    if na(_distanceTicks) or na(_ageBars)
        na
    else
        _minProbability = math.min(probabilityMin, probabilityMax)
        _maxProbability = math.max(probabilityMin, probabilityMax)
        _distanceScore = 1.0 - math.min(_distanceTicks / probabilityMaxDistanceTicks, 1.0)
        _ageScore = 1.0 - math.min(_ageBars / probabilityAgeBars, 1.0)
        _distanceWeight = probabilityDistanceWeight / 100.0
        _score = _distanceScore * _distanceWeight + _ageScore * (1.0 - _distanceWeight)
        math.min(_maxProbability, math.max(_minProbability, _minProbability + (_maxProbability - _minProbability) * _score))

f_formatOpportunity(_distanceTicks, _probability) =>
    na(_distanceTicks) or na(_probability) ? "none" : str.format("{0} t | {1}%", str.tostring(math.round(_distanceTicks)), str.tostring(math.round(_probability)))

f_drawEntryMark(_title, _tooltip, _isLong, _top) =>
    _style = label.style_label_down
    _bgColor = _isLong ? longSignalBgColor : shortSignalBgColor
    _textColor = _isLong ? longSignalTextColor : shortSignalTextColor
    _lineStart = math.min(high, _top)
    _line = line.new(bar_index, _lineStart, bar_index, _top, extend=extend.none, color=_bgColor, width=entrySignalLineWidth)
    _label = label.new(bar_index, _top, _title, style=_style, textcolor=_textColor, color=_bgColor, size=size.small, tooltip=_tooltip)
    [_line, _label]

// -----------------------------------------------------------------------------
// High/low MA bands
// -----------------------------------------------------------------------------
fastBandHigh = f_bandMa(high, fastBandLength)
fastBandLow = f_bandMa(low, fastBandLength)
slowBandHigh = f_bandMa(high, slowBandLength)
slowBandLow = f_bandMa(low, slowBandLength)

fastBandHighPlot = plot(showFastBand ? fastBandHigh : na, "Fast H", color=fastBandFillColor, linewidth=bandLineWidth)
fastBandLowPlot = plot(showFastBand ? fastBandLow : na, "Fast L", color=fastBandFillColor, linewidth=bandLineWidth)
slowBandHighPlot = plot(showSlowBand ? slowBandHigh : na, "Slow H", color=slowBandFillColor, linewidth=bandLineWidth)
slowBandLowPlot = plot(showSlowBand ? slowBandLow : na, "Slow L", color=slowBandFillColor, linewidth=bandLineWidth)

fill(fastBandHighPlot, fastBandLowPlot, color=showFastBand ? fastBandFillColor : na, title="Fast H/L band")
fill(slowBandHighPlot, slowBandLowPlot, color=showSlowBand ? slowBandFillColor : na, title="Slow H/L band")

// -----------------------------------------------------------------------------
// EMA stack
// -----------------------------------------------------------------------------
emaFast = ta.ema(close, emaFastLength)
emaMid = ta.ema(close, emaMidLength)
emaSlow = ta.ema(close, emaSlowLength)

plot(showEmaStack ? emaFast : na, "EMA fast", color=emaFastColor, linewidth=emaStackLineWidth)
plot(showEmaStack ? emaMid : na, "EMA middle", color=emaMidColor, linewidth=emaStackLineWidth)
plot(showEmaStack ? emaSlow : na, "EMA slow", color=emaSlowColor, linewidth=emaStackLineWidth)

// -----------------------------------------------------------------------------
// Estimated CVD
// -----------------------------------------------------------------------------
cvdDelta = close > open ? volume : close < open ? -volume : 0.0
dailyTimeChange = ta.change(time("D"))
cvdReset = cvdResetMode == "Daily" and dailyTimeChange != 0
var float estimatedCvd = na
estimatedCvd := cvdReset or na(estimatedCvd) ? cvdDelta : estimatedCvd + cvdDelta

cvdMin = ta.lowest(estimatedCvd, cvdLookbackBars)
cvdMax = ta.highest(estimatedCvd, cvdLookbackBars)
cvdRange = math.max(cvdMax - cvdMin, 1.0)
cvdPriceLow = ta.lowest(low, cvdLookbackBars)
cvdPriceHigh = ta.highest(high, cvdLookbackBars)
cvdPriceRange = math.max(cvdPriceHigh - cvdPriceLow, syminfo.mintick)
cvdBottom = cvdPriceLow + cvdPriceRange * cvdBottomOffsetPercent / 100.0
cvdTop = cvdBottom + cvdPriceRange * cvdHeightPercent / 100.0
cvdPlot = cvdBottom + (estimatedCvd - cvdMin) / cvdRange * (cvdTop - cvdBottom)
cvdZeroPlot = cvdBottom + (0.0 - cvdMin) / cvdRange * (cvdTop - cvdBottom)
cvdColor = estimatedCvd >= nz(estimatedCvd[1], estimatedCvd) ? cvdUpColor : cvdDownColor

plot(showEstimatedCvd ? cvdPlot : na, "Estimated CVD", color=cvdColor, linewidth=2)
plot(showEstimatedCvd ? cvdZeroPlot : na, "Estimated CVD zero", color=cvdZeroColor, linewidth=1)

// -----------------------------------------------------------------------------
// Estimated delta profile
// -----------------------------------------------------------------------------
var array<box> deltaProfileBoxes = array.new<box>()
deltaProfileLow = ta.lowest(low, deltaProfileLookbackBars)
deltaProfileHigh = ta.highest(high, deltaProfileLookbackBars)

if barstate.islast
    while array.size(deltaProfileBoxes) > 0
        _oldProfileBox = array.pop(deltaProfileBoxes)
        box.delete(_oldProfileBox)

    if showDeltaProfile
        _profileLow = deltaProfileLow
        _profileHigh = deltaProfileHigh
        _profileRange = math.max(_profileHigh - _profileLow, syminfo.mintick)
        _profileStep = _profileRange / deltaProfileLevels
        _profileValues = array.new<float>(deltaProfileLevels, 0.0)
        _barsToScan = math.min(deltaProfileLookbackBars, bar_index + 1)

        for i = 0 to _barsToScan - 1
            _barPrice = hlc3[i]
            _rawIndex = math.floor((_barPrice - _profileLow) / _profileStep)
            _levelIndex = int(math.max(0, math.min(deltaProfileLevels - 1, _rawIndex)))
            _barDelta = close[i] > open[i] ? volume[i] : close[i] < open[i] ? -volume[i] : 0.0
            array.set(_profileValues, _levelIndex, array.get(_profileValues, _levelIndex) + _barDelta)

        _maxAbsDelta = 0.0
        for level = 0 to deltaProfileLevels - 1
            _maxAbsDelta := math.max(_maxAbsDelta, math.abs(array.get(_profileValues, level)))

        if _maxAbsDelta > 0
            _anchorBar = bar_index + deltaProfileOffsetBars
            for level = 0 to deltaProfileLevels - 1
                _levelDelta = array.get(_profileValues, level)
                _levelWidth = int(math.max(1, math.round(math.abs(_levelDelta) / _maxAbsDelta * deltaProfileMaxWidthBars)))
                _top = _profileLow + _profileStep * (level + 1)
                _bottom = _profileLow + _profileStep * level
                _left = _levelDelta >= 0 ? _anchorBar : _anchorBar - _levelWidth
                _right = _levelDelta >= 0 ? _anchorBar + _levelWidth : _anchorBar
                _profileColor = _levelDelta >= 0 ? deltaProfileUpColor : deltaProfileDownColor
                _profileBox = box.new(left=_left, top=_top, right=_right, bottom=_bottom, bgcolor=_profileColor, border_color=deltaProfileBorderColor)
                array.push(deltaProfileBoxes, _profileBox)

// -----------------------------------------------------------------------------
// Entry signals
// -----------------------------------------------------------------------------
fastMid = (fastBandHigh + fastBandLow) / 2.0
slowMid = (slowBandHigh + slowBandLow) / 2.0
fastBandAllowed = entrySignalBands == "Fast" or entrySignalBands == "Both"
slowBandAllowed = entrySignalBands == "Slow" or entrySignalBands == "Both"

var int lastEntrySignalTime = na
entrySpacingOk = signalSpacingMinutes == 0 or na(lastEntrySignalTime) or time - lastEntrySignalTime >= signalSpacingMinutes * 60 * 1000

bandsOverlap = fastBandLow <= slowBandHigh and fastBandHigh >= slowBandLow
bandGapTicks = fastBandLow > slowBandHigh ? (fastBandLow - slowBandHigh) / syminfo.mintick : slowBandLow > fastBandHigh ? (slowBandLow - fastBandHigh) / syminfo.mintick : 0.0
consolidationActive = bandsOverlap or bandGapTicks < minBandGapTicks

longTrendOk = fastMid > slowMid and fastMid > fastMid[trendLookbackBars] and slowMid > slowMid[trendLookbackBars]
shortTrendOk = fastMid < slowMid and fastMid < fastMid[trendLookbackBars] and slowMid < slowMid[trendLookbackBars]
generalEntryOk = showEntrySignals and entrySpacingOk and not consolidationActive

var int fastLongCrossStartBar = na
var int fastShortCrossStartBar = na
var int slowLongCrossStartBar = na
var int slowShortCrossStartBar = na
var int fastLongBreakoutBar = na
var int fastShortBreakoutBar = na
var int slowLongBreakoutBar = na
var int slowShortBreakoutBar = na

if close < fastBandLow
    fastLongCrossStartBar := bar_index
if close > fastBandHigh
    fastShortCrossStartBar := bar_index
if close < slowBandLow
    slowLongCrossStartBar := bar_index
if close > slowBandHigh
    slowShortCrossStartBar := bar_index

fastLongCrossRaw = not na(fastLongCrossStartBar) and bar_index - fastLongCrossStartBar <= maxBarsToCrossBand and close > fastBandHigh
fastShortCrossRaw = not na(fastShortCrossStartBar) and bar_index - fastShortCrossStartBar <= maxBarsToCrossBand and close < fastBandLow
slowLongCrossRaw = not na(slowLongCrossStartBar) and bar_index - slowLongCrossStartBar <= maxBarsToCrossBand and close > slowBandHigh
slowShortCrossRaw = not na(slowShortCrossStartBar) and bar_index - slowShortCrossStartBar <= maxBarsToCrossBand and close < slowBandLow

if not na(fastLongCrossStartBar) and bar_index - fastLongCrossStartBar > maxBarsToCrossBand
    fastLongCrossStartBar := na
if not na(fastShortCrossStartBar) and bar_index - fastShortCrossStartBar > maxBarsToCrossBand
    fastShortCrossStartBar := na
if not na(slowLongCrossStartBar) and bar_index - slowLongCrossStartBar > maxBarsToCrossBand
    slowLongCrossStartBar := na
if not na(slowShortCrossStartBar) and bar_index - slowShortCrossStartBar > maxBarsToCrossBand
    slowShortCrossStartBar := na

if fastLongCrossRaw
    fastLongBreakoutBar := bar_index
    fastLongCrossStartBar := na
if fastShortCrossRaw
    fastShortBreakoutBar := bar_index
    fastShortCrossStartBar := na
if slowLongCrossRaw
    slowLongBreakoutBar := bar_index
    slowLongCrossStartBar := na
if slowShortCrossRaw
    slowShortBreakoutBar := bar_index
    slowShortCrossStartBar := na

fastLongReturnRaw = not na(fastLongBreakoutBar) and bar_index > fastLongBreakoutBar and bar_index - fastLongBreakoutBar <= maxBarsToReturnBand and low <= fastBandHigh and close >= fastBandLow
fastShortReturnRaw = not na(fastShortBreakoutBar) and bar_index > fastShortBreakoutBar and bar_index - fastShortBreakoutBar <= maxBarsToReturnBand and high >= fastBandLow and close <= fastBandHigh
slowLongReturnRaw = not na(slowLongBreakoutBar) and bar_index > slowLongBreakoutBar and bar_index - slowLongBreakoutBar <= maxBarsToReturnBand and low <= slowBandHigh and close >= slowBandLow
slowShortReturnRaw = not na(slowShortBreakoutBar) and bar_index > slowShortBreakoutBar and bar_index - slowShortBreakoutBar <= maxBarsToReturnBand and high >= slowBandLow and close <= slowBandHigh

fastLongBounceRaw = low <= fastBandHigh and close > fastBandHigh
fastShortBounceRaw = high >= fastBandLow and close < fastBandLow
slowLongBounceRaw = low <= slowBandHigh and close > slowBandHigh
slowShortBounceRaw = high >= slowBandLow and close < slowBandLow
longBetweenBandsRaw = fastBandHigh < slowBandLow and close[1] <= fastBandHigh[1] and close > fastBandHigh and close < slowBandLow
shortBetweenBandsRaw = fastBandLow > slowBandHigh and close[1] >= fastBandLow[1] and close < fastBandLow and close > slowBandHigh

if fastLongReturnRaw or (not na(fastLongBreakoutBar) and bar_index - fastLongBreakoutBar > maxBarsToReturnBand)
    fastLongBreakoutBar := na
if fastShortReturnRaw or (not na(fastShortBreakoutBar) and bar_index - fastShortBreakoutBar > maxBarsToReturnBand)
    fastShortBreakoutBar := na
if slowLongReturnRaw or (not na(slowLongBreakoutBar) and bar_index - slowLongBreakoutBar > maxBarsToReturnBand)
    slowLongBreakoutBar := na
if slowShortReturnRaw or (not na(slowShortBreakoutBar) and bar_index - slowShortBreakoutBar > maxBarsToReturnBand)
    slowShortBreakoutBar := na

fastLongCrossCandidate = generalEntryOk and enableLongSignals and enableCrossSignals and fastBandAllowed and longTrendOk and fastLongCrossRaw
slowLongCrossCandidate = generalEntryOk and enableLongSignals and enableCrossSignals and slowBandAllowed and longTrendOk and slowLongCrossRaw
fastShortCrossCandidate = generalEntryOk and enableShortSignals and enableCrossSignals and fastBandAllowed and shortTrendOk and fastShortCrossRaw
slowShortCrossCandidate = generalEntryOk and enableShortSignals and enableCrossSignals and slowBandAllowed and shortTrendOk and slowShortCrossRaw

fastLongReturnCandidate = generalEntryOk and enableLongSignals and enableReturnSignals and fastBandAllowed and longTrendOk and fastLongReturnRaw
slowLongReturnCandidate = generalEntryOk and enableLongSignals and enableReturnSignals and slowBandAllowed and longTrendOk and slowLongReturnRaw
fastShortReturnCandidate = generalEntryOk and enableShortSignals and enableReturnSignals and fastBandAllowed and shortTrendOk and fastShortReturnRaw
slowShortReturnCandidate = generalEntryOk and enableShortSignals and enableReturnSignals and slowBandAllowed and shortTrendOk and slowShortReturnRaw

fastLongBounceCandidate = generalEntryOk and enableLongSignals and enableBounceSignals and fastBandAllowed and longTrendOk and fastLongBounceRaw
slowLongBounceCandidate = generalEntryOk and enableLongSignals and enableBounceSignals and slowBandAllowed and longTrendOk and slowLongBounceRaw
fastShortBounceCandidate = generalEntryOk and enableShortSignals and enableBounceSignals and fastBandAllowed and shortTrendOk and fastShortBounceRaw
slowShortBounceCandidate = generalEntryOk and enableShortSignals and enableBounceSignals and slowBandAllowed and shortTrendOk and slowShortBounceRaw

longBetweenBandsCandidate = generalEntryOk and enableLongSignals and enableBetweenBandsSignals and longBetweenBandsRaw
shortBetweenBandsCandidate = generalEntryOk and enableShortSignals and enableBetweenBandsSignals and shortBetweenBandsRaw

longCrossFastSelected = fastLongCrossCandidate and (not slowLongCrossCandidate or sameBarPriority == "Fast")
longCrossSlowSelected = slowLongCrossCandidate and (not fastLongCrossCandidate or sameBarPriority == "Slow")
shortCrossFastSelected = fastShortCrossCandidate and (not slowShortCrossCandidate or sameBarPriority == "Fast")
shortCrossSlowSelected = slowShortCrossCandidate and (not fastShortCrossCandidate or sameBarPriority == "Slow")

longReturnFastSelected = fastLongReturnCandidate and (not slowLongReturnCandidate or sameBarPriority == "Fast")
longReturnSlowSelected = slowLongReturnCandidate and (not fastLongReturnCandidate or sameBarPriority == "Slow")
shortReturnFastSelected = fastShortReturnCandidate and (not slowShortReturnCandidate or sameBarPriority == "Fast")
shortReturnSlowSelected = slowShortReturnCandidate and (not fastShortReturnCandidate or sameBarPriority == "Slow")

longBounceFastSelected = fastLongBounceCandidate and (not slowLongBounceCandidate or sameBarPriority == "Fast")
longBounceSlowSelected = slowLongBounceCandidate and (not fastLongBounceCandidate or sameBarPriority == "Slow")
shortBounceFastSelected = fastShortBounceCandidate and (not slowShortBounceCandidate or sameBarPriority == "Fast")
shortBounceSlowSelected = slowShortBounceCandidate and (not fastShortBounceCandidate or sameBarPriority == "Slow")

longCrossSignal = longCrossFastSelected or longCrossSlowSelected
shortCrossSignal = shortCrossFastSelected or shortCrossSlowSelected
longReturnSignal = longReturnFastSelected or longReturnSlowSelected
shortReturnSignal = shortReturnFastSelected or shortReturnSlowSelected
longBounceSignal = longBounceFastSelected or longBounceSlowSelected
shortBounceSignal = shortBounceFastSelected or shortBounceSlowSelected
longBetweenBandsSignal = longBetweenBandsCandidate
shortBetweenBandsSignal = shortBetweenBandsCandidate

var array<line> entrySignalLines = array.new<line>()
var array<label> entrySignalLabels = array.new<label>()
entrySignalRangeTopY = ta.highest(high, entrySignalTopLookbackBars) + ta.atr(14) * entrySignalTopAtrOffset
entrySignalTopY = entrySignalLabelPlacement == "Fixed price" and entrySignalFixedPrice > 0 ? entrySignalFixedPrice : entrySignalRangeTopY

if entrySignalLabelPlacement != "Dynamic top" and array.size(entrySignalLines) > 0
    for i = 0 to array.size(entrySignalLines) - 1
        _entryLine = array.get(entrySignalLines, i)
        if not na(_entryLine)
            line.set_y2(_entryLine, entrySignalTopY)
        if array.size(entrySignalLabels) > i
            _entryLabel = array.get(entrySignalLabels, i)
            if not na(_entryLabel)
                label.set_y(_entryLabel, entrySignalTopY)

if longCrossSignal
    _entryText = longCrossFastSelected ? "LONG CROSS F" : "LONG CROSS S"
    [_entryLine, _entryLabel] = f_drawEntryMark("L", _entryText, true, entrySignalTopY)
    array.push(entrySignalLines, _entryLine)
    array.push(entrySignalLabels, _entryLabel)
if shortCrossSignal
    _entryText = shortCrossFastSelected ? "SHORT CROSS F" : "SHORT CROSS S"
    [_entryLine, _entryLabel] = f_drawEntryMark("S", _entryText, false, entrySignalTopY)
    array.push(entrySignalLines, _entryLine)
    array.push(entrySignalLabels, _entryLabel)
if longReturnSignal
    _entryText = longReturnFastSelected ? "LONG RETURN F" : "LONG RETURN S"
    [_entryLine, _entryLabel] = f_drawEntryMark("L", _entryText, true, entrySignalTopY)
    array.push(entrySignalLines, _entryLine)
    array.push(entrySignalLabels, _entryLabel)
if shortReturnSignal
    _entryText = shortReturnFastSelected ? "SHORT RETURN F" : "SHORT RETURN S"
    [_entryLine, _entryLabel] = f_drawEntryMark("S", _entryText, false, entrySignalTopY)
    array.push(entrySignalLines, _entryLine)
    array.push(entrySignalLabels, _entryLabel)
if longBounceSignal
    _entryText = longBounceFastSelected ? "LONG BOUNCE F" : "LONG BOUNCE S"
    [_entryLine, _entryLabel] = f_drawEntryMark("L", _entryText, true, entrySignalTopY)
    array.push(entrySignalLines, _entryLine)
    array.push(entrySignalLabels, _entryLabel)
if shortBounceSignal
    _entryText = shortBounceFastSelected ? "SHORT BOUNCE F" : "SHORT BOUNCE S"
    [_entryLine, _entryLabel] = f_drawEntryMark("S", _entryText, false, entrySignalTopY)
    array.push(entrySignalLines, _entryLine)
    array.push(entrySignalLabels, _entryLabel)
if longBetweenBandsSignal
    _entryText = "LONG BETWEEN"
    [_entryLine, _entryLabel] = f_drawEntryMark("L", _entryText, true, entrySignalTopY)
    array.push(entrySignalLines, _entryLine)
    array.push(entrySignalLabels, _entryLabel)
if shortBetweenBandsSignal
    _entryText = "SHORT BETWEEN"
    [_entryLine, _entryLabel] = f_drawEntryMark("S", _entryText, false, entrySignalTopY)
    array.push(entrySignalLines, _entryLine)
    array.push(entrySignalLabels, _entryLabel)

anyEntrySignal = longCrossSignal or shortCrossSignal or longReturnSignal or shortReturnSignal or longBounceSignal or shortBounceSignal or longBetweenBandsSignal or shortBetweenBandsSignal
if anyEntrySignal
    lastEntrySignalTime := time
    f_trimLines(entrySignalLines, entrySignalLabels, maxEntrySignalMarks)

// -----------------------------------------------------------------------------
// BIAS M/W/D
// -----------------------------------------------------------------------------
dailyBias = f_bias("D")
weeklyBias = f_bias("W")
monthlyBias = f_bias("M")

bgcolor(showBiasBackground ? (dailyBias > 0 ? bullishBiasColor : dailyBias < 0 ? bearishBiasColor : neutralBiasColor) : na)

var table biasPanel = table.new(f_panelPosition(panelPositionInput), 2, 8, bgcolor=panelBgColor, frame_color=color.new(color.lime, 45), border_color=color.new(color.lime, 70), border_width=1)

// -----------------------------------------------------------------------------
// Current and previous period high/low
// -----------------------------------------------------------------------------
currentDailyHigh = request.security(syminfo.tickerid, "D", high, barmerge.gaps_off, barmerge.lookahead_off)
currentDailyLow = request.security(syminfo.tickerid, "D", low, barmerge.gaps_off, barmerge.lookahead_off)
previousDailyHigh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
previousDailyLow = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_off)
previousWeeklyHigh = request.security(syminfo.tickerid, "W", high[1], barmerge.gaps_off, barmerge.lookahead_off)
previousWeeklyLow = request.security(syminfo.tickerid, "W", low[1], barmerge.gaps_off, barmerge.lookahead_off)
previousMonthlyHigh = request.security(syminfo.tickerid, "M", high[1], barmerge.gaps_off, barmerge.lookahead_off)
previousMonthlyLow = request.security(syminfo.tickerid, "M", low[1], barmerge.gaps_off, barmerge.lookahead_off)
var float allTimeHigh = na
allTimeHigh := na(allTimeHigh) ? high : math.max(allTimeHigh, high)

var line dailyHighLine = na
var line dailyLowLine = na
var line currentDailyHighLine = na
var line currentDailyLowLine = na
var line weeklyHighLine = na
var line weeklyLowLine = na
var line monthlyHighLine = na
var line monthlyLowLine = na
var line athLine = na
var label dailyHighLabel = na
var label dailyLowLabel = na
var label currentDailyHighLabel = na
var label currentDailyLowLabel = na
var label weeklyHighLabel = na
var label weeklyLowLabel = na
var label monthlyHighLabel = na
var label monthlyLowLabel = na
var label athLabel = na

[_updatedCurrentDailyHighLine, _updatedCurrentDailyHighLabel] = f_setLevel(currentDailyHighLine, currentDailyHighLabel, currentDailyHigh, "CDH", currentDayLevelColor, currentDayLevelColor, currentDayLabelTextColor, showCurrentDayLevels)
currentDailyHighLine := _updatedCurrentDailyHighLine
currentDailyHighLabel := _updatedCurrentDailyHighLabel
[_updatedCurrentDailyLowLine, _updatedCurrentDailyLowLabel] = f_setLevel(currentDailyLowLine, currentDailyLowLabel, currentDailyLow, "CDL", currentDayLevelColor, currentDayLevelColor, currentDayLabelTextColor, showCurrentDayLevels)
currentDailyLowLine := _updatedCurrentDailyLowLine
currentDailyLowLabel := _updatedCurrentDailyLowLabel

[_updatedDailyHighLine, _updatedDailyHighLabel] = f_setLevel(dailyHighLine, dailyHighLabel, previousDailyHigh, "PDH", dailyLevelColor, dailyLevelColor, dailyLabelTextColor, showDailyLevels)
dailyHighLine := _updatedDailyHighLine
dailyHighLabel := _updatedDailyHighLabel
[_updatedDailyLowLine, _updatedDailyLowLabel] = f_setLevel(dailyLowLine, dailyLowLabel, previousDailyLow, "PDL", dailyLevelColor, dailyLevelColor, dailyLabelTextColor, showDailyLevels)
dailyLowLine := _updatedDailyLowLine
dailyLowLabel := _updatedDailyLowLabel
[_updatedWeeklyHighLine, _updatedWeeklyHighLabel] = f_setLevel(weeklyHighLine, weeklyHighLabel, previousWeeklyHigh, "PWH", weeklyLevelColor, weeklyLevelColor, weeklyLabelTextColor, showWeeklyLevels)
weeklyHighLine := _updatedWeeklyHighLine
weeklyHighLabel := _updatedWeeklyHighLabel
[_updatedWeeklyLowLine, _updatedWeeklyLowLabel] = f_setLevel(weeklyLowLine, weeklyLowLabel, previousWeeklyLow, "PWL", weeklyLevelColor, weeklyLevelColor, weeklyLabelTextColor, showWeeklyLevels)
weeklyLowLine := _updatedWeeklyLowLine
weeklyLowLabel := _updatedWeeklyLowLabel
[_updatedMonthlyHighLine, _updatedMonthlyHighLabel] = f_setLevel(monthlyHighLine, monthlyHighLabel, previousMonthlyHigh, "PMH", monthlyLevelColor, monthlyLevelColor, monthlyLabelTextColor, showMonthlyLevels)
monthlyHighLine := _updatedMonthlyHighLine
monthlyHighLabel := _updatedMonthlyHighLabel
[_updatedMonthlyLowLine, _updatedMonthlyLowLabel] = f_setLevel(monthlyLowLine, monthlyLowLabel, previousMonthlyLow, "PML", monthlyLevelColor, monthlyLevelColor, monthlyLabelTextColor, showMonthlyLevels)
monthlyLowLine := _updatedMonthlyLowLine
monthlyLowLabel := _updatedMonthlyLowLabel
[_updatedAthLine, _updatedAthLabel] = f_setLevel(athLine, athLabel, allTimeHigh, "ATH", athLevelColor, athLevelColor, athLabelTextColor, showAthLevel)
athLine := _updatedAthLine
athLabel := _updatedAthLabel

// -----------------------------------------------------------------------------
// Session Fibonacci
// -----------------------------------------------------------------------------
var array<float> sessionFibRatios = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0)
var array<string> sessionFibNames = array.from("0%", "23.6%", "38.2%", "50%", "61.8%", "78.6%", "100%")

f_updateSessionFib(_enabled, _sessionName, _session, _timezone, _sessionOpen, _sessionStartBar, _sessionHigh, _sessionLow, _sessionColor, _lines, _labels) =>
    _inSession = not na(time(timeframe.period, _session, _timezone))
    _newSession = _inSession and not _inSession[1]
    float _nextOpen = _sessionOpen
    int _nextStartBar = _sessionStartBar
    float _nextHigh = _sessionHigh
    float _nextLow = _sessionLow

    if _newSession or (_inSession and na(_nextOpen))
        _nextOpen := open
        _nextStartBar := bar_index
        _nextHigh := high
        _nextLow := low
    else if _inSession
        _nextHigh := na(_nextHigh) ? high : math.max(_nextHigh, high)
        _nextLow := na(_nextLow) ? low : math.min(_nextLow, low)

    _target = close >= _nextOpen ? _nextHigh : _nextLow
    _ready = showSessionFib and _enabled and _inSession and not na(_nextOpen) and not na(_nextStartBar) and not na(_target)

    if _ready
        for i = 0 to array.size(sessionFibRatios) - 1
            _ratio = array.get(sessionFibRatios, i)
            _name = array.get(sessionFibNames, i)
            _price = _nextOpen + (_target - _nextOpen) * _ratio
            _fibLine = array.get(_lines, i)
            if na(_fibLine)
                _fibLine := line.new(_nextStartBar, _price, bar_index + 1, _price, extend=extend.none, color=_sessionColor, style=f_lineStyle(sessionFibStyleInput), width=sessionFibLineWidth)
                array.set(_lines, i, _fibLine)
            else
                line.set_xy1(_fibLine, _nextStartBar, _price)
                line.set_xy2(_fibLine, bar_index + 1, _price)
                line.set_color(_fibLine, _sessionColor)
                line.set_style(_fibLine, f_lineStyle(sessionFibStyleInput))
                line.set_width(_fibLine, sessionFibLineWidth)

            _fibLabel = array.get(_labels, i)
            _fibText = _sessionName + " FIB " + _name
            if showSessionFibLabels
                if na(_fibLabel)
                    _fibLabel := label.new(_nextStartBar, _price, _fibText, style=label.style_label_right, textcolor=sessionFibTextColor, color=sessionFibLabelBgColor, size=size.small)
                    array.set(_labels, i, _fibLabel)
                else
                    label.set_xy(_fibLabel, _nextStartBar, _price)
                    label.set_style(_fibLabel, label.style_label_right)
                    label.set_text(_fibLabel, _fibText)
                    label.set_textcolor(_fibLabel, sessionFibTextColor)
                    label.set_color(_fibLabel, sessionFibLabelBgColor)
            else if not na(_fibLabel)
                label.delete(_fibLabel)
                array.set(_labels, i, na)
    else if not showSessionFib or not _enabled
        for i = 0 to array.size(_lines) - 1
            _fibLine = array.get(_lines, i)
            if not na(_fibLine)
                line.delete(_fibLine)
                array.set(_lines, i, na)
            _fibLabel = array.get(_labels, i)
            if not na(_fibLabel)
                label.delete(_fibLabel)
                array.set(_labels, i, na)

    [_nextOpen, _nextStartBar, _nextHigh, _nextLow]

f_refreshSessionFibLabels(_enabled, _sessionName, _lines, _labels) =>
    if showSessionFib and _enabled and showSessionFibLabels
        for i = 0 to array.size(_lines) - 1
            _fibLine = array.get(_lines, i)
            if not na(_fibLine)
                _oldLabel = array.get(_labels, i)
                if not na(_oldLabel)
                    label.delete(_oldLabel)
                _fibText = _sessionName + " FIB " + array.get(sessionFibNames, i)
                _newLabel = label.new(line.get_x1(_fibLine), line.get_y1(_fibLine), _fibText, style=label.style_label_right, textcolor=sessionFibTextColor, color=sessionFibLabelBgColor, size=size.small)
                array.set(_labels, i, _newLabel)

var float sydneyFibOpen = na
var float tokyoFibOpen = na
var float londonFibOpen = na
var float newYorkFibOpen = na
var float sydneyFibHigh = na
var float tokyoFibHigh = na
var float londonFibHigh = na
var float newYorkFibHigh = na
var float sydneyFibLow = na
var float tokyoFibLow = na
var float londonFibLow = na
var float newYorkFibLow = na
var int sydneyFibStartBar = na
var int tokyoFibStartBar = na
var int londonFibStartBar = na
var int newYorkFibStartBar = na
var array<line> sydneyFibLines = array.new<line>(7)
var array<line> tokyoFibLines = array.new<line>(7)
var array<line> londonFibLines = array.new<line>(7)
var array<line> newYorkFibLines = array.new<line>(7)
var array<label> sydneyFibLabels = array.new<label>(7)
var array<label> tokyoFibLabels = array.new<label>(7)
var array<label> londonFibLabels = array.new<label>(7)
var array<label> newYorkFibLabels = array.new<label>(7)

[_updatedSydneyFibOpen, _updatedSydneyFibStartBar, _updatedSydneyFibHigh, _updatedSydneyFibLow] = f_updateSessionFib(showSydneyFib, "SYD", sydneyFibSession, sessionFibTimezone, sydneyFibOpen, sydneyFibStartBar, sydneyFibHigh, sydneyFibLow, sydneyFibColor, sydneyFibLines, sydneyFibLabels)
sydneyFibOpen := _updatedSydneyFibOpen
sydneyFibStartBar := _updatedSydneyFibStartBar
sydneyFibHigh := _updatedSydneyFibHigh
sydneyFibLow := _updatedSydneyFibLow
[_updatedTokyoFibOpen, _updatedTokyoFibStartBar, _updatedTokyoFibHigh, _updatedTokyoFibLow] = f_updateSessionFib(showTokyoFib, "TYO", tokyoFibSession, sessionFibTimezone, tokyoFibOpen, tokyoFibStartBar, tokyoFibHigh, tokyoFibLow, tokyoFibColor, tokyoFibLines, tokyoFibLabels)
tokyoFibOpen := _updatedTokyoFibOpen
tokyoFibStartBar := _updatedTokyoFibStartBar
tokyoFibHigh := _updatedTokyoFibHigh
tokyoFibLow := _updatedTokyoFibLow
[_updatedLondonFibOpen, _updatedLondonFibStartBar, _updatedLondonFibHigh, _updatedLondonFibLow] = f_updateSessionFib(showLondonFib, "LDN", londonFibSession, sessionFibTimezone, londonFibOpen, londonFibStartBar, londonFibHigh, londonFibLow, londonFibColor, londonFibLines, londonFibLabels)
londonFibOpen := _updatedLondonFibOpen
londonFibStartBar := _updatedLondonFibStartBar
londonFibHigh := _updatedLondonFibHigh
londonFibLow := _updatedLondonFibLow
[_updatedNewYorkFibOpen, _updatedNewYorkFibStartBar, _updatedNewYorkFibHigh, _updatedNewYorkFibLow] = f_updateSessionFib(showNewYorkFib, "NY", newYorkFibSession, sessionFibTimezone, newYorkFibOpen, newYorkFibStartBar, newYorkFibHigh, newYorkFibLow, newYorkFibColor, newYorkFibLines, newYorkFibLabels)
newYorkFibOpen := _updatedNewYorkFibOpen
newYorkFibStartBar := _updatedNewYorkFibStartBar
newYorkFibHigh := _updatedNewYorkFibHigh
newYorkFibLow := _updatedNewYorkFibLow

// -----------------------------------------------------------------------------
// BOS
// -----------------------------------------------------------------------------
var float lastPivotHigh = na
var int lastPivotHighBar = na
var float lastPivotLow = na
var int lastPivotLowBar = na
var array<line> bosLines = array.new<line>()
var array<label> bosLabels = array.new<label>()

pivotHighBos = ta.pivothigh(high, bosPivotLength, bosPivotLength)
pivotLowBos = ta.pivotlow(low, bosPivotLength, bosPivotLength)

if not na(pivotHighBos)
    lastPivotHigh := pivotHighBos
    lastPivotHighBar := bar_index - bosPivotLength

if not na(pivotLowBos)
    lastPivotLow := pivotLowBos
    lastPivotLowBar := bar_index - bosPivotLength

bullishBosCross = ta.crossover(close, lastPivotHigh)
bearishBosCross = ta.crossunder(close, lastPivotLow)
bullishBos = showBos and not na(lastPivotHigh) and bullishBosCross
bearishBos = showBos and not na(lastPivotLow) and bearishBosCross

if bullishBos
    line newBullishBosLine = na
    label newBullishBosLabel = na
    bosLabelBar = math.round((lastPivotHighBar + bar_index) / 2)
    bosLabelPrice = lastPivotHigh
    if showBosLines
        newBullishBosLine := line.new(lastPivotHighBar, lastPivotHigh, bar_index, lastPivotHigh, color=bullishBosColor, width=2)
    if showBosLabels
        newBullishBosLabel := label.new(bosLabelBar, bosLabelPrice, "BOS ↑", style=label.style_none, textcolor=bullishBosLabelTextColor, color=color.new(color.black, 100), size=size.small)
    array.push(bosLines, newBullishBosLine)
    array.push(bosLabels, newBullishBosLabel)
    lastPivotHigh := na
    f_trimLines(bosLines, bosLabels, maxBosMarks)

if bearishBos
    line newBearishBosLine = na
    label newBearishBosLabel = na
    bosLabelBar = math.round((lastPivotLowBar + bar_index) / 2)
    bosLabelPrice = lastPivotLow
    if showBosLines
        newBearishBosLine := line.new(lastPivotLowBar, lastPivotLow, bar_index, lastPivotLow, color=bearishBosColor, width=2)
    if showBosLabels
        newBearishBosLabel := label.new(bosLabelBar, bosLabelPrice, "BOS ↓", style=label.style_none, textcolor=bearishBosLabelTextColor, color=color.new(color.black, 100), size=size.small)
    array.push(bosLines, newBearishBosLine)
    array.push(bosLabels, newBearishBosLabel)
    lastPivotLow := na
    f_trimLines(bosLines, bosLabels, maxBosMarks)

// -----------------------------------------------------------------------------
// FVG
// -----------------------------------------------------------------------------
var array<box> bullishFvgBoxes = array.new<box>()
var array<box> bearishFvgBoxes = array.new<box>()
var array<label> bullishFvgLabels = array.new<label>()
var array<label> bearishFvgLabels = array.new<label>()
var array<int> bullishFvgCreatedTimes = array.new<int>()
var array<int> bearishFvgCreatedTimes = array.new<int>()

fvgMin = minFvgTicks * syminfo.mintick
fvgSourceHigh = fvgMode == "Bodies" ? math.max(open, close) : high
fvgSourceLow = fvgMode == "Bodies" ? math.min(open, close) : low
fvgSourceHigh2 = fvgMode == "Bodies" ? math.max(open[2], close[2]) : high[2]
fvgSourceLow2 = fvgMode == "Bodies" ? math.min(open[2], close[2]) : low[2]

newBullishFvg = showFvg and bar_index >= 2 and fvgSourceLow > fvgSourceHigh2 and (fvgSourceLow - fvgSourceHigh2) >= fvgMin
newBearishFvg = showFvg and bar_index >= 2 and fvgSourceHigh < fvgSourceLow2 and (fvgSourceLow2 - fvgSourceHigh) >= fvgMin
fvgDateText = str.format("{0,date,yyyy-MM-dd}", time)
bullishFvgSizeTicks = (fvgSourceLow - fvgSourceHigh2) / syminfo.mintick
bearishFvgSizeTicks = (fvgSourceLow2 - fvgSourceHigh) / syminfo.mintick
bullishFvgLabelText = "FVG ↑ " + fvgDateText + " | " + str.tostring(math.round(bullishFvgSizeTicks)) + "t"
bearishFvgLabelText = "FVG ↓ " + fvgDateText + " | " + str.tostring(math.round(bearishFvgSizeTicks)) + "t"

if newBullishFvg
    _fvgBox = box.new(left=bar_index - 2, top=fvgSourceLow, right=bar_index, bottom=fvgSourceHigh2, bgcolor=bullishFvgColor, border_color=fvgBorderColor)
    _fvgLabel = showFvgLabels ? label.new(bar_index, (fvgSourceLow + fvgSourceHigh2) / 2.0, bullishFvgLabelText, style=label.style_label_left, textcolor=fvgLabelTextColor, color=fvgLabelBgColor, size=size.small, textalign=text.align_right) : na
    array.push(bullishFvgBoxes, _fvgBox)
    array.push(bullishFvgLabels, _fvgLabel)
    array.push(bullishFvgCreatedTimes, time)
    f_trimBoxesWithLabels(bullishFvgBoxes, bullishFvgLabels, bullishFvgCreatedTimes, maxFvgBoxes)

if newBearishFvg
    _fvgBox = box.new(left=bar_index - 2, top=fvgSourceLow2, right=bar_index, bottom=fvgSourceHigh, bgcolor=bearishFvgColor, border_color=fvgBorderColor)
    _fvgLabel = showFvgLabels ? label.new(bar_index, (fvgSourceLow2 + fvgSourceHigh) / 2.0, bearishFvgLabelText, style=label.style_label_left, textcolor=fvgLabelTextColor, color=fvgLabelBgColor, size=size.small, textalign=text.align_right) : na
    array.push(bearishFvgBoxes, _fvgBox)
    array.push(bearishFvgLabels, _fvgLabel)
    array.push(bearishFvgCreatedTimes, time)
    f_trimBoxesWithLabels(bearishFvgBoxes, bearishFvgLabels, bearishFvgCreatedTimes, maxFvgBoxes)

if showFvg
    f_updateZoneBoxesWithLabels(bullishFvgBoxes, bullishFvgLabels, bullishFvgCreatedTimes, true, extendFvg, hideFilledFvg, showFvgLabels, fvgExpiryDays, false)
    f_updateZoneBoxesWithLabels(bearishFvgBoxes, bearishFvgLabels, bearishFvgCreatedTimes, false, extendFvg, hideFilledFvg, showFvgLabels, fvgExpiryDays, false)

// -----------------------------------------------------------------------------
// Gaps
// -----------------------------------------------------------------------------
var array<box> bullishGapBoxes = array.new<box>()
var array<box> bearishGapBoxes = array.new<box>()
var array<label> bullishGapLabels = array.new<label>()
var array<label> bearishGapLabels = array.new<label>()
var array<int> bullishGapCreatedTimes = array.new<int>()
var array<int> bearishGapCreatedTimes = array.new<int>()

gapMin = minGapTicks * syminfo.mintick
newBullishGap = showGaps and bar_index > 0 and open > close[1] and (open - close[1]) >= gapMin
newBearishGap = showGaps and bar_index > 0 and open < close[1] and (close[1] - open) >= gapMin
gapDateText = str.format("{0,date,yyyy-MM-dd}", time)
bullishGapSizeTicks = (open - close[1]) / syminfo.mintick
bearishGapSizeTicks = (close[1] - open) / syminfo.mintick
bullishGapLabelText = "GAP ↑ " + gapDateText + " | " + str.tostring(math.round(bullishGapSizeTicks)) + "t"
bearishGapLabelText = "GAP ↓ " + gapDateText + " | " + str.tostring(math.round(bearishGapSizeTicks)) + "t"

if newBullishGap
    _gapBox = box.new(left=bar_index - 1, top=open, right=bar_index, bottom=close[1], bgcolor=bullishGapColor, border_color=gapBorderColor)
    _gapLabel = showGapLabels ? label.new(bar_index, (open + close[1]) / 2.0, bullishGapLabelText, style=label.style_label_left, textcolor=gapLabelTextColor, color=gapLabelBgColor, size=size.small, textalign=text.align_right) : na
    array.push(bullishGapBoxes, _gapBox)
    array.push(bullishGapLabels, _gapLabel)
    array.push(bullishGapCreatedTimes, time)
    f_trimBoxesWithLabels(bullishGapBoxes, bullishGapLabels, bullishGapCreatedTimes, maxGapBoxes)

if newBearishGap
    _gapBox = box.new(left=bar_index - 1, top=close[1], right=bar_index, bottom=open, bgcolor=bearishGapColor, border_color=gapBorderColor)
    _gapLabel = showGapLabels ? label.new(bar_index, (close[1] + open) / 2.0, bearishGapLabelText, style=label.style_label_left, textcolor=gapLabelTextColor, color=gapLabelBgColor, size=size.small, textalign=text.align_right) : na
    array.push(bearishGapBoxes, _gapBox)
    array.push(bearishGapLabels, _gapLabel)
    array.push(bearishGapCreatedTimes, time)
    f_trimBoxesWithLabels(bearishGapBoxes, bearishGapLabels, bearishGapCreatedTimes, maxGapBoxes)

if showGaps
    f_updateZoneBoxesWithLabels(bullishGapBoxes, bullishGapLabels, bullishGapCreatedTimes, true, extendGaps, hideFilledGaps, showGapLabels, gapExpiryDays, true)
    f_updateZoneBoxesWithLabels(bearishGapBoxes, bearishGapLabels, bearishGapCreatedTimes, false, extendGaps, hideFilledGaps, showGapLabels, gapExpiryDays, true)

f_refreshSessionFibLabels(showSydneyFib, "SYD", sydneyFibLines, sydneyFibLabels)
f_refreshSessionFibLabels(showTokyoFib, "TYO", tokyoFibLines, tokyoFibLabels)
f_refreshSessionFibLabels(showLondonFib, "LDN", londonFibLines, londonFibLabels)
f_refreshSessionFibLabels(showNewYorkFib, "NY", newYorkFibLines, newYorkFibLabels)

// -----------------------------------------------------------------------------
// Nearest open FVG and gap distance
// -----------------------------------------------------------------------------
[bullishFvgUpDistance, bullishFvgUpAge] = f_nearestZone(bullishFvgBoxes, true, 1)
[bearishFvgUpDistance, bearishFvgUpAge] = f_nearestZone(bearishFvgBoxes, false, 1)
[fvgUpDistance, fvgUpAge] = f_pickNearest(bullishFvgUpDistance, bullishFvgUpAge, bearishFvgUpDistance, bearishFvgUpAge)
[bullishFvgDownDistance, bullishFvgDownAge] = f_nearestZone(bullishFvgBoxes, true, -1)
[bearishFvgDownDistance, bearishFvgDownAge] = f_nearestZone(bearishFvgBoxes, false, -1)
[fvgDownDistance, fvgDownAge] = f_pickNearest(bullishFvgDownDistance, bullishFvgDownAge, bearishFvgDownDistance, bearishFvgDownAge)

[bullishGapUpDistance, bullishGapUpAge] = f_nearestZone(bullishGapBoxes, true, 1)
[bearishGapUpDistance, bearishGapUpAge] = f_nearestZone(bearishGapBoxes, false, 1)
[gapUpDistance, gapUpAge] = f_pickNearest(bullishGapUpDistance, bullishGapUpAge, bearishGapUpDistance, bearishGapUpAge)
[bullishGapDownDistance, bullishGapDownAge] = f_nearestZone(bullishGapBoxes, true, -1)
[bearishGapDownDistance, bearishGapDownAge] = f_nearestZone(bearishGapBoxes, false, -1)
[gapDownDistance, gapDownAge] = f_pickNearest(bullishGapDownDistance, bullishGapDownAge, bearishGapDownDistance, bearishGapDownAge)

fvgUpProbability = f_closeProbability(fvgUpDistance, fvgUpAge)
fvgDownProbability = f_closeProbability(fvgDownDistance, fvgDownAge)
gapUpProbability = f_closeProbability(gapUpDistance, gapUpAge)
gapDownProbability = f_closeProbability(gapDownDistance, gapDownAge)

if barstate.islast
    if showPanel
        table.set_position(biasPanel, f_panelPosition(panelPositionInput))
        table.cell(biasPanel, 0, 0, "PERIOD", text_color=panelTextColor, bgcolor=color.new(color.lime, 88), text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 1, 0, "RESULT", text_color=panelTextColor, bgcolor=color.new(color.lime, 88), text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 0, 1, "D", text_color=panelTextColor, bgcolor=panelBgColor, text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 1, 1, f_biasText(dailyBias), text_color=f_biasColor(dailyBias), bgcolor=panelBgColor, text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 0, 2, "W", text_color=panelTextColor, bgcolor=panelBgColor, text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 1, 2, f_biasText(weeklyBias), text_color=f_biasColor(weeklyBias), bgcolor=panelBgColor, text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 0, 3, "M", text_color=panelTextColor, bgcolor=panelBgColor, text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 1, 3, f_biasText(monthlyBias), text_color=f_biasColor(monthlyBias), bgcolor=panelBgColor, text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 0, 4, "FVG ↑", text_color=panelTextColor, bgcolor=color.new(color.lime, 92), text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 1, 4, showDistanceRows ? f_formatOpportunity(fvgUpDistance, fvgUpProbability) : "-", text_color=color.new(color.lime, 0), bgcolor=panelBgColor, text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 0, 5, "FVG ↓", text_color=panelTextColor, bgcolor=color.new(color.red, 92), text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 1, 5, showDistanceRows ? f_formatOpportunity(fvgDownDistance, fvgDownProbability) : "-", text_color=color.new(color.red, 0), bgcolor=panelBgColor, text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 0, 6, "GAP ↑", text_color=panelTextColor, bgcolor=color.new(color.aqua, 92), text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 1, 6, showDistanceRows ? f_formatOpportunity(gapUpDistance, gapUpProbability) : "-", text_color=color.new(color.aqua, 0), bgcolor=panelBgColor, text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 0, 7, "GAP ↓", text_color=panelTextColor, bgcolor=color.new(color.fuchsia, 92), text_size=f_textSize(panelSizeInput))
        table.cell(biasPanel, 1, 7, showDistanceRows ? f_formatOpportunity(gapDownDistance, gapDownProbability) : "-", text_color=color.new(color.fuchsia, 0), bgcolor=panelBgColor, text_size=f_textSize(panelSizeInput))
    else
        table.clear(biasPanel, 0, 0, 1, 7)

// -----------------------------------------------------------------------------
// Technical alerts
// -----------------------------------------------------------------------------
alertcondition(bullishBos, "Bullish BOS", "MrRexo RBS: bullish Break of Structure detected.")
alertcondition(bearishBos, "Bearish BOS", "MrRexo RBS: bearish Break of Structure detected.")
alertcondition(newBullishFvg, "Bullish FVG", "MrRexo RBS: bullish FVG detected.")
alertcondition(newBearishFvg, "Bearish FVG", "MrRexo RBS: bearish FVG detected.")
alertcondition(newBullishGap, "Bullish GAP", "MrRexo RBS: bullish GAP detected.")
alertcondition(newBearishGap, "Bearish GAP", "MrRexo RBS: bearish GAP detected.")
alertcondition(longCrossSignal, "LONG - cross through band", "MrRexo RBS: LONG signal after crossing through the band.")
alertcondition(shortCrossSignal, "SHORT - cross through band", "MrRexo RBS: SHORT signal after crossing through the band.")
alertcondition(longReturnSignal, "LONG - return to band", "MrRexo RBS: LONG signal after returning to the band.")
alertcondition(shortReturnSignal, "SHORT - return to band", "MrRexo RBS: SHORT signal after returning to the band.")
alertcondition(longBounceSignal, "LONG - bounce from band", "MrRexo RBS: LONG signal after bouncing from the band.")
alertcondition(shortBounceSignal, "SHORT - bounce from band", "MrRexo RBS: SHORT signal after bouncing from the band.")
alertcondition(longBetweenBandsSignal, "LONG - move between bands", "MrRexo RBS: LONG signal after price moves upward between the bands.")
alertcondition(shortBetweenBandsSignal, "SHORT - move between bands", "MrRexo RBS: SHORT signal after price moves downward between the bands.")
````
