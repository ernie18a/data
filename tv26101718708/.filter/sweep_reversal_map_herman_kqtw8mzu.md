# Sweep Reversal Map+ [Herman]

- url: https://www.tradingview.com/script/kQTW8mzu-Sweep-Reversal-Map-Herman/
- type: indicator
- pine_id: PUB;e37dfc9f8483425f90066f6bd29bc6df
- version: 2.0

## Description

Sweep Reversal Map [Herman]

Sweep Reversal Map [Herman] is an open-source price-action indicator designed to identify potential reversal areas that develop after price sweeps previously confirmed swing liquidity.

The concept is inspired by liquidity-sweep and reversal principles taught within ICT methodology, including the idea that price can trade beyond a prior swing high or swing low, reclaim that liquidity level, and subsequently confirm a reversal through a break of nearby market structure.

This script provides an independent Pine Script implementation of that general concept with configurable swing detection, sweep penetration, structure confirmation, displacement filtering, developing zones, and historical reversal mapping.

HOW IT WORKS

The indicator follows a multi-stage process rather than marking every wick through a previous high or low.

1. Confirmed Swing Liquidity

The script first identifies confirmed swing highs and swing lows using the selected Swing Length.

These levels represent previously established areas of liquidity that price may later sweep.

2. Liquidity Sweep

A bearish reversal candidate begins when price trades above a confirmed swing high.

A bullish reversal candidate begins when price trades below a confirmed swing low.

The Minimum Sweep Penetration setting can optionally require price to move a specified ATR-based distance beyond the liquidity level before the event qualifies as a sweep.

3. Reclaim

After the sweep occurs, the script tracks whether price closes back through the swept liquidity level.

For a bearish setup, price must reclaim below the swept swing high.

For a bullish setup, price must reclaim above the swept swing low.

4. Local Structure Confirmation

A sweep alone does not create a confirmed reversal.

The script records nearby structure preceding the sweep and waits for price to break that structure in the opposite direction.

A bearish reversal requires a close below the relevant local structure level.

A bullish reversal requires a close above the relevant local structure level.

5. Displacement Filter

The confirmation candle can also be required to show a minimum body size relative to ATR.

This provides an optional displacement requirement and helps distinguish stronger confirmation candles from very small structure breaks.

Setting Minimum Displacement Body to 0 disables this filter.

REVERSAL ZONES

When Show Developing Reversals is enabled, a faint zone represents a sweep that has occurred but has not yet completed the full confirmation process.

The zone expands if price creates a more extreme price during the developing setup.

Once all confirmation conditions are satisfied, the zone becomes visually stronger and is retained as a historical confirmed sweep-reversal area.

If confirmation does not occur within the selected Maximum Confirmation Bars, the developing setup expires and is removed.

HOW TO INTERPRET THE MAP

A zone above price represents a confirmed bearish sweep-reversal event originating from liquidity above a previous swing high.

A zone below price represents a confirmed bullish sweep-reversal event originating from liquidity below a previous swing low.

The horizontal line identifies the liquidity level associated with the sweep.

The marker identifies the original confirmed swing from which that liquidity level was derived.

These areas are intended to provide additional price-action context. They are not automatic long or short entries and should not be interpreted as guaranteed reversal points.

SETTINGS

Swing Length
Controls how many bars on each side are required to confirm a swing. Higher values generally identify less frequent but more significant swing points.

ATR Length
Defines the ATR period used by the penetration and displacement filters.

Minimum Sweep Penetration
Determines how far beyond the swing level price must trade for the event to qualify as a sweep. A value of 0 accepts any breach.

Local Structure Length
Controls the number of preceding bars used to determine the local structure level required for reversal confirmation.

Maximum Confirmation Bars
Defines how long a developing sweep can remain active while waiting for confirmation.

Minimum Displacement Body
Requires the confirmation candle body to reach a selected fraction of ATR. A value of 0 disables the displacement requirement.

Show Developing Reversals
Displays or hides unconfirmed sweep zones while they are developing.

Confirmed Box Extension
Controls how far confirmed reversal zones extend to the right.

Historical Setups
Controls the maximum number of confirmed historical setups retained on the chart.

IMPORTANT BEHAVIOR OF SWING DETECTION

Swing highs and swing lows are confirmed only after the required number of bars has formed to the right of the potential pivot.

For example, with a Swing Length of 5, a potential swing requires five subsequent bars before it can become a confirmed liquidity level.

Once confirmed, the level is visually anchored to the bar where the swing originally occurred. This historical placement should not be interpreted as the indicator having known the swing in real time on that original bar.

A sweep can only be detected after the corresponding swing has already been confirmed.

Signals and confirmation logic are evaluated on confirmed bars.

LIMITATIONS

Liquidity sweeps and structure breaks are price-action events, not guarantees that price will continue reversing.

Different markets and timeframes can produce very different amounts of noise and therefore may require different Swing Length, structure, penetration, and displacement settings.

A developing reversal can disappear if the required confirmation does not occur before the confirmation window expires.

The indicator does not calculate expected returns, win rates, profit targets, stop-loss levels, or strategy performance.

It should therefore be used as a market-structure visualization and research tool rather than as a standalone trading system.

ORIGINAL IMPLEMENTATION

The underlying liquidity-sweep/reversal concept is an established price-action concept and is associated here with ICT educational methodology.

The original contribution of this script is its programmatic implementation and visualization workflow: confirmed swing-liquidity tracking, optional ATR-normalized sweep penetration, reclaim state tracking, local-structure confirmation, ATR-normalized displacement confirmation, developing setup management, expiration logic, configurable historical reversal zones, and confirmation alerts.

The source code is published openly so users can inspect how each condition is calculated and modify the implementation for their own research.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
//@version=6
// ============================================================================
// Sweep Reversal Map [Herman] — HTF x2 + opacity fix + TF text in boxes
// Original sweep / reclaim / structure-break logic retained.
// HTF values use ONLY completed HTF candles (no future data / no repaint).
// ============================================================================
indicator("Sweep Reversal Map [Herman]", shorttitle = "Sweep Reversal Map [Herman]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, calc_bars_count = 10000)

// --- Groups ---
const string G_DETECT = "Detection"
const string G_CONFIRM = "Confirmation"
const string G_LAYERS = "Timeframes"
const string G_STYLE = "Style / Opacity"

// --- Detection / confirmation (same defaults as the original) ---
int swingLengthInput = input.int(5, "Swing length", minval = 2, maxval = 50, group = G_DETECT, tooltip = "Bars on either side of a confirmed swing.")
int atrLengthInput = input.int(14, "ATR length", minval = 1, group = G_DETECT)
float minPenetrationInput = input.float(0.0, "Minimum sweep penetration (ATR)", minval = 0.0, step = 0.05, group = G_DETECT)
int structureLengthInput = input.int(3, "Local structure length", minval = 1, maxval = 20, group = G_CONFIRM)
int maxConfirmationBarsInput = input.int(12, "Maximum confirmation bars", minval = 1, maxval = 100, group = G_CONFIRM)
float minDisplacementInput = input.float(0.2, "Minimum displacement body (ATR)", minval = 0.0, step = 0.05, group = G_CONFIRM)

// --- Independent visibility controls ---
bool showChartInput = input.bool(true, "Chart TF reversal zones", group = G_LAYERS)
bool showHtf1Input = input.bool(true, "HTF 1 zones", inline = "htf1", group = G_LAYERS)
string htf1Input = input.timeframe("5", "", inline = "htf1", group = G_LAYERS)
bool showHtf2Input = input.bool(false, "HTF 2 zones", inline = "htf2", group = G_LAYERS)
string htf2Input = input.timeframe("15", "", inline = "htf2", group = G_LAYERS)

// --- Visuals: defaults reproduce the original on the chart TF ---
bool showDevelopingInput = input.bool(true, "Show developing reversals", group = G_STYLE)
int confirmedExtensionInput = input.int(2, "Confirmed box extension (source-TF bars)", minval = 0, maxval = 50, group = G_STYLE)
int maxHistoryInput = input.int(80, "Historical setups PER LAYER", minval = 1, maxval = 150, group = G_STYLE)
color zoneColorInput = input.color(#FF9F43, "Reversal zone color", group = G_STYLE)
color levelColorInput = input.color(#7F1D1D, "Sweep level / marker color", group = G_STYLE)
int devFillOpacityInput = input.int(88, "Developing fill opacity", minval = 0, maxval = 100, group = G_STYLE, tooltip = "0 = opaque, 100 = invisible. Also respects transparency in the color picker.")
int devBorderOpacityInput = input.int(65, "Developing border opacity", minval = 0, maxval = 100, group = G_STYLE)
int confFillOpacityInput = input.int(35, "Confirmed fill opacity", minval = 0, maxval = 100, group = G_STYLE)
int confBorderOpacityInput = input.int(5, "Confirmed border opacity", minval = 0, maxval = 100, group = G_STYLE)
int devLevelOpacityInput = input.int(75, "Developing level opacity", minval = 0, maxval = 100, group = G_STYLE)
int confLevelOpacityInput = input.int(20, "Confirmed level opacity", minval = 0, maxval = 100, group = G_STYLE)
int devMarkerOpacityInput = input.int(70, "Developing marker opacity", minval = 0, maxval = 100, group = G_STYLE)
int confMarkerOpacityInput = input.int(0, "Confirmed marker opacity", minval = 0, maxval = 100, group = G_STYLE)
// HTF origin name inside every HTF reversal box, at its right-hand edge.
bool showHtfBoxTextInput = input.bool(true, "Show HTF name inside box", group = G_STYLE)
color htfBoxTextColorInput = input.color(#7F1D1D, "HTF box text color", group = G_STYLE)
string htfBoxTextSizeInput = input.string("Small", "HTF box text size", options = ["Tiny", "Small", "Normal"], group = G_STYLE)
string htfBoxTextSize = htfBoxTextSizeInput == "Tiny" ? size.tiny : htfBoxTextSizeInput == "Normal" ? size.normal : size.small

// TradingView minute timeframes are stored as "5", "15", "60", etc.
// Convert them into concise readable labels: HTF 5min, HTF 15min, HTF 1h.
f_htfLabel(string sourceTf) =>
    float minuteNumber = str.tonumber(sourceTf)
    string displayName = "HTF " + sourceTf
    if not na(minuteNumber)
        int minutes = int(minuteNumber)
        if minutes > 0 and minutes % 60 == 0
            displayName := "HTF " + str.tostring(int(minutes / 60)) + "h"
        else
            displayName := "HTF " + str.tostring(minutes) + "min"
    displayName

// A second opacity percentage is applied *over* the opacity in input.color.
// This means edits to EITHER control actually affect rendered objects.
// With default color transparency = 0%, the values exactly match the old code.
f_opacity(color baseColor, int extraOpacity) =>
    float baseTransparency = color.t(baseColor)
    int finalTransparency = int(math.round(baseTransparency + (100.0 - baseTransparency) * extraOpacity / 100.0))
    color.new(baseColor, finalTransparency)

color devFillColor = showDevelopingInput ? f_opacity(zoneColorInput, devFillOpacityInput) : color.new(zoneColorInput, 100)
color devBorderColor = showDevelopingInput ? f_opacity(zoneColorInput, devBorderOpacityInput) : color.new(zoneColorInput, 100)
color confFillColor = f_opacity(zoneColorInput, confFillOpacityInput)
color confBorderColor = f_opacity(zoneColorInput, confBorderOpacityInput)
color devLineColor = showDevelopingInput ? f_opacity(levelColorInput, devLevelOpacityInput) : color.new(levelColorInput, 100)
color confLineColor = f_opacity(levelColorInput, confLevelOpacityInput)
color devMarkerColor = showDevelopingInput ? f_opacity(levelColorInput, devMarkerOpacityInput) : color.new(levelColorInput, 100)
color confMarkerColor = f_opacity(levelColorInput, confMarkerOpacityInput)
color labelBackground = color.new(color.black, 100)

// --- Compact state snapshot for all three independently computed timeframes ---
// Event 0 = none, 2 = reversal confirmed, 3 = candidate expired.
// Developing is determined by active == true; same-bar start+confirm is supported.
type SweepState
    int barTime = na
    int barCloseTime = na
    int bearEvent = 0
    bool bearActive = false
    int bearStartTime = na
    int bearPivotTime = na
    float bearLevel = na
    float bearExtreme = na
    int bullEvent = 0
    bool bullActive = false
    int bullStartTime = na
    int bullPivotTime = na
    float bullLevel = na
    float bullExtreme = na

// Identical state machine runs in the chart, 5m and 15m data contexts.
// Calling this function from request.security evaluates actual HTF OHLC/ATR/pivots.
f_engine() =>
    float atrValue = ta.atr(atrLengthInput)
    float pivotHighValue = ta.pivothigh(high, swingLengthInput, swingLengthInput)
    float pivotLowValue = ta.pivotlow(low, swingLengthInput, swingLengthInput)
    float priorStructureLow = ta.lowest(low, structureLengthInput)[1]
    float priorStructureHigh = ta.highest(high, structureLengthInput)[1]
    bool displacementPass = not na(atrValue) and math.abs(close - open) >= atrValue * minDisplacementInput
    float minimumPenetration = nz(atrValue) * minPenetrationInput

    var float latestSwingHigh = na
    var float latestSwingLow = na
    var int latestSwingHighTime = na
    var int latestSwingLowTime = na
    var bool swingHighAvailable = false
    var bool swingLowAvailable = false

    if not na(pivotHighValue)
        latestSwingHigh := pivotHighValue
        latestSwingHighTime := time[swingLengthInput]
        swingHighAvailable := true
    if not na(pivotLowValue)
        latestSwingLow := pivotLowValue
        latestSwingLowTime := time[swingLengthInput]
        swingLowAvailable := true

    var bool bearishActive = false
    var bool bearishReclaimed = false
    var int bearishStartBar = na
    var int bearishStartTime = na
    var int bearishPivotTime = na
    var float bearishLevel = na
    var float bearishExtreme = na
    var float bearishConfirmationLevel = na

    var bool bullishActive = false
    var bool bullishReclaimed = false
    var int bullishStartBar = na
    var int bullishStartTime = na
    var int bullishPivotTime = na
    var float bullishLevel = na
    var float bullishExtreme = na
    var float bullishConfirmationLevel = na

    int bearEvent = 0
    int bullEvent = 0

    // Bearish: confirmed high sweep -> reclaim -> close below saved structure.
    bool bearishSweep = not bearishActive and swingHighAvailable and not na(latestSwingHigh) and not na(priorStructureLow) and high >= latestSwingHigh + minimumPenetration
    if bearishSweep
        bearishActive := true
        bearishReclaimed := close < latestSwingHigh
        bearishStartBar := bar_index
        bearishStartTime := time
        bearishPivotTime := latestSwingHighTime
        bearishLevel := latestSwingHigh
        bearishExtreme := high
        bearishConfirmationLevel := priorStructureLow
        swingHighAvailable := false

    if bearishActive
        bearishExtreme := math.max(bearishExtreme, high)
        bearishReclaimed := bearishReclaimed or close < bearishLevel
        bool confirmBearish = bearishReclaimed and close < bearishConfirmationLevel and displacementPass
        bool expireBearish = bar_index - bearishStartBar > maxConfirmationBarsInput
        if confirmBearish
            bearEvent := 2
            bearishActive := false
        else if expireBearish
            bearEvent := 3
            bearishActive := false

    // Bullish: confirmed low sweep -> reclaim -> close above saved structure.
    bool bullishSweep = not bullishActive and swingLowAvailable and not na(latestSwingLow) and not na(priorStructureHigh) and low <= latestSwingLow - minimumPenetration
    if bullishSweep
        bullishActive := true
        bullishReclaimed := close > latestSwingLow
        bullishStartBar := bar_index
        bullishStartTime := time
        bullishPivotTime := latestSwingLowTime
        bullishLevel := latestSwingLow
        bullishExtreme := low
        bullishConfirmationLevel := priorStructureHigh
        swingLowAvailable := false

    if bullishActive
        bullishExtreme := math.min(bullishExtreme, low)
        bullishReclaimed := bullishReclaimed or close > bullishLevel
        bool confirmBullish = bullishReclaimed and close > bullishConfirmationLevel and displacementPass
        bool expireBullish = bar_index - bullishStartBar > maxConfirmationBarsInput
        if confirmBullish
            bullEvent := 2
            bullishActive := false
        else if expireBullish
            bullEvent := 3
            bullishActive := false

    SweepState.new(time, time_close, bearEvent, bearishActive, bearishStartTime, bearishPivotTime, bearishLevel, bearishExtreme, bullEvent, bullishActive, bullishStartTime, bullishPivotTime, bullishLevel, bullishExtreme)

// Snapshot delayed by ONE source bar; lookahead_on then provides only CLOSED HTF
// bars on the first bar of the next HTF period, in history AND in realtime.
f_confirmedHtfEngine() =>
    SweepState snapshot = f_engine()
    snapshot[1]

// Each syntactically distinct call site has its OWN persistent arrays and IDs.
// Thus chart TF, HTF1 and HTF2 maintain separate history and developing boxes.
f_render(SweepState s, bool enabled, bool gate, int projectedRight, int historyLimit, string sourceLabel) =>
    var array<box> confirmedBoxes = array.new<box>()
    var array<line> confirmedLines = array.new<line>()
    var array<label> confirmedLabels = array.new<label>()
    var box bearBox = na
    var line bearLine = na
    var label bearLabel = na
    var box bullBox = na
    var line bullLine = na
    var label bullLabel = na
    var int processedTime = na
    bool bearSignal = false
    bool bullSignal = false
    string boxCaption = showHtfBoxTextInput ? sourceLabel : ""

    if enabled and gate and not na(s) and not na(s.barTime) and (na(processedTime) or s.barTime != processedTime)
        processedTime := s.barTime
        int rightConfirmed = na(projectedRight) ? s.barTime : projectedRight
        int rightDeveloping = na(s.barCloseTime) ? s.barTime : s.barCloseTime

        // BEARISH: create/update, confirm, or remove expired developing objects.
        if s.bearEvent == 3
            if not na(bearBox)
                box.delete(bearBox)
                line.delete(bearLine)
                label.delete(bearLabel)
                bearBox := na
                bearLine := na
                bearLabel := na
        else if s.bearActive or s.bearEvent == 2
            if na(bearBox)
                bearBox := box.new(s.bearStartTime, s.bearExtreme, rightDeveloping, s.bearLevel, xloc = xloc.bar_time, bgcolor = devFillColor, border_color = devBorderColor, text = (showDevelopingInput or s.bearEvent == 2) ? boxCaption : "", text_color = htfBoxTextColorInput, text_size = htfBoxTextSize, text_halign = text.align_right, text_valign = text.align_center, text_wrap = text.wrap_none)
                bearLine := line.new(s.bearPivotTime, s.bearLevel, s.barTime, s.bearLevel, xloc = xloc.bar_time, color = devLineColor, style = line.style_dotted)
                bearLabel := label.new(s.bearPivotTime, s.bearLevel, "×", xloc = xloc.bar_time, style = label.style_label_center, color = labelBackground, textcolor = devMarkerColor, size = size.small)
            else
                box.set_top(bearBox, s.bearExtreme)
                box.set_right(bearBox, rightDeveloping)
                line.set_x2(bearLine, s.barTime)
            if s.bearEvent == 2
                bearSignal := true
                box.set_right(bearBox, rightConfirmed)
                box.set_text(bearBox, boxCaption)
                box.set_bgcolor(bearBox, confFillColor)
                box.set_border_color(bearBox, confBorderColor)
                box.set_border_width(bearBox, 1)
                line.set_color(bearLine, confLineColor)
                line.set_style(bearLine, line.style_solid)
                label.set_textcolor(bearLabel, confMarkerColor)
                array.push(confirmedBoxes, bearBox)
                array.push(confirmedLines, bearLine)
                array.push(confirmedLabels, bearLabel)
                bearBox := na
                bearLine := na
                bearLabel := na

        // BULLISH: mirror image of the bearish state machine.
        if s.bullEvent == 3
            if not na(bullBox)
                box.delete(bullBox)
                line.delete(bullLine)
                label.delete(bullLabel)
                bullBox := na
                bullLine := na
                bullLabel := na
        else if s.bullActive or s.bullEvent == 2
            if na(bullBox)
                bullBox := box.new(s.bullStartTime, s.bullLevel, rightDeveloping, s.bullExtreme, xloc = xloc.bar_time, bgcolor = devFillColor, border_color = devBorderColor, text = (showDevelopingInput or s.bullEvent == 2) ? boxCaption : "", text_color = htfBoxTextColorInput, text_size = htfBoxTextSize, text_halign = text.align_right, text_valign = text.align_center, text_wrap = text.wrap_none)
                bullLine := line.new(s.bullPivotTime, s.bullLevel, s.barTime, s.bullLevel, xloc = xloc.bar_time, color = devLineColor, style = line.style_dotted)
                bullLabel := label.new(s.bullPivotTime, s.bullLevel, "×", xloc = xloc.bar_time, style = label.style_label_center, color = labelBackground, textcolor = devMarkerColor, size = size.small)
            else
                box.set_bottom(bullBox, s.bullExtreme)
                box.set_right(bullBox, rightDeveloping)
                line.set_x2(bullLine, s.barTime)
            if s.bullEvent == 2
                bullSignal := true
                box.set_right(bullBox, rightConfirmed)
                box.set_text(bullBox, boxCaption)
                box.set_bgcolor(bullBox, confFillColor)
                box.set_border_color(bullBox, confBorderColor)
                box.set_border_width(bullBox, 1)
                line.set_color(bullLine, confLineColor)
                line.set_style(bullLine, line.style_solid)
                label.set_textcolor(bullLabel, confMarkerColor)
                array.push(confirmedBoxes, bullBox)
                array.push(confirmedLines, bullLine)
                array.push(confirmedLabels, bullLabel)
                bullBox := na
                bullLine := na
                bullLabel := na

        // Limits apply PER LAYER. One box, one line and one label per setup.
        while array.size(confirmedBoxes) > historyLimit
            box.delete(array.shift(confirmedBoxes))
            line.delete(array.shift(confirmedLines))
            label.delete(array.shift(confirmedLabels))

    [bearSignal, bullSignal]

// --- Three distinct executions of the SAME detection engine ---
SweepState chartState = f_engine()
SweepState htf1State = request.security(syminfo.tickerid, htf1Input, f_confirmedHtfEngine(), lookahead = barmerge.lookahead_on)
SweepState htf2State = request.security(syminfo.tickerid, htf2Input, f_confirmedHtfEngine(), lookahead = barmerge.lookahead_on)

// HTF overlays are intentionally shown only when the source is HIGHER than the
// chart. On an equal timeframe, enable Chart TF zones instead (no duplicates).
bool isTimeBased = timeframe.isseconds or timeframe.isminutes or timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
bool validHtf1 = isTimeBased and timeframe.in_seconds(htf1Input) > timeframe.in_seconds(timeframe.period)
bool validHtf2 = isTimeBased and timeframe.in_seconds(htf2Input) > timeframe.in_seconds(timeframe.period)

// Project right edges in SOURCE bars, not chart bars. Pine's time() projection
// also handles session boundaries better than adding fixed milliseconds.
int chartProjectedRight = time(timeframe.period, timeframe_bars_back = -confirmedExtensionInput)
int htf1ProjectedRight = time(htf1Input, timeframe_bars_back = 1 - confirmedExtensionInput)
int htf2ProjectedRight = time(htf2Input, timeframe_bars_back = 1 - confirmedExtensionInput)

// Chart signals are final at bar close. HTF data is already final on the NEXT
// HTF bar, so it is safe to draw without waiting for the chart candle to close.
[chartBear, chartBull] = f_render(chartState, showChartInput, barstate.isconfirmed, chartProjectedRight, maxHistoryInput, "")
[htf1Bear, htf1Bull] = f_render(htf1State, showHtf1Input and validHtf1, true, htf1ProjectedRight, maxHistoryInput, f_htfLabel(htf1Input))
[htf2Bear, htf2Bull] = f_render(htf2State, showHtf2Input and validHtf2, true, htf2ProjectedRight, maxHistoryInput, f_htfLabel(htf2Input))

// --- Existing alerts + optional HTF alerts ---
alertcondition(chartBear, "Bearish sweep reversal confirmed", "Bearish liquidity sweep reversal confirmed on {{ticker}} {{interval}}.")
alertcondition(chartBull, "Bullish sweep reversal confirmed", "Bullish liquidity sweep reversal confirmed on {{ticker}} {{interval}}.")
alertcondition(chartBear or chartBull, "Any sweep reversal confirmed", "Liquidity sweep reversal confirmed on {{ticker}} {{interval}}.")
alertcondition(htf1Bear or htf1Bull, "HTF 1 sweep reversal confirmed", "HTF 1 liquidity sweep reversal confirmed on {{ticker}}.")
alertcondition(htf2Bear or htf2Bull, "HTF 2 sweep reversal confirmed", "HTF 2 liquidity sweep reversal confirmed on {{ticker}}.")
alertcondition(chartBear or chartBull or htf1Bear or htf1Bull or htf2Bear or htf2Bull, "Any TF sweep reversal confirmed", "Sweep reversal confirmed on the chart or an enabled HTF for {{ticker}}.")
````
