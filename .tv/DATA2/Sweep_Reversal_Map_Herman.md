<!-- tradingview-pine-id: PUB;e37dfc9f8483425f90066f6bd29bc6df -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Sweep Reversal Map [Herman]

Source: https://www.tradingview.com/script/kQTW8mzu-Sweep-Reversal-Map-Herman/

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

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0

//@version=6

// ============================================================================
// Sweep Reversal Map+ [Herman]
// Concept reference: ICT liquidity sweep / reversal framework
// ============================================================================

indicator("Sweep Reversal Map [Herman]", shorttitle = "Sweep Reversal Map [Herman]", overlay = true, max_boxes_count = 200, max_lines_count = 200, max_labels_count = 200, calc_bars_count = 10000)

// --- Constants ---
// Herman Trading — configuration and UI constants.

const string GROUP_DETECTION = "Detection"
const string GROUP_CONFIRMATION = "Confirmation"
const string GROUP_STYLE = "Style"

const string SWING_TOOLTIP = "Number of bars on each side required to confirm a swing. Higher values detect more important, but less frequent, liquidity levels."
const string PENETRATION_TOOLTIP = "Minimum distance beyond a swing level, measured as a fraction of ATR, required to register a sweep. Set to 0 to accept every breach."
const string STRUCTURE_TOOLTIP = "Number of bars preceding the sweep used to define the local structure level that price must break to confirm the reversal."
const string CONFIRM_BARS_TOOLTIP = "Maximum number of bars allowed between the initial sweep and reversal confirmation."
const string DISPLACEMENT_TOOLTIP = "Minimum confirmation-candle body as a fraction of ATR. Set to 0 to disable the displacement filter."
const string DEVELOPING_TOOLTIP = "Shows a faint zone while a detected sweep is waiting for a confirmed break of local structure."
const string EXTENSION_TOOLTIP = "Number of bars by which a confirmed reversal zone is extended to the right."
const string HISTORY_TOOLTIP = "Maximum number of confirmed historical sweep reversals retained on the chart."

const color TRANSPARENT_COLOR = #00000000

// --- Inputs ---
// Herman Trading — user controls for Sweep Reversal Map [Herman].

int swingLengthInput = input.int(5, "Swing length", minval = 2, maxval = 50, tooltip = SWING_TOOLTIP, group = GROUP_DETECTION)
int atrLengthInput = input.int(14, "ATR length", minval = 1, tooltip = "ATR period used by the sweep penetration and displacement filters.", group = GROUP_DETECTION)
float minPenetrationInput = input.float(0.0, "Minimum sweep penetration (ATR)", minval = 0.0, step = 0.05, tooltip = PENETRATION_TOOLTIP, group = GROUP_DETECTION)

int structureLengthInput = input.int(3, "Local structure length", minval = 1, maxval = 20, tooltip = STRUCTURE_TOOLTIP, group = GROUP_CONFIRMATION)
int maxConfirmationBarsInput = input.int(12, "Maximum confirmation bars", minval = 1, maxval = 100, tooltip = CONFIRM_BARS_TOOLTIP, group = GROUP_CONFIRMATION)
float minDisplacementInput = input.float(0.2, "Minimum displacement body (ATR)", minval = 0.0, step = 0.05, tooltip = DISPLACEMENT_TOOLTIP, group = GROUP_CONFIRMATION)

bool showDevelopingInput = input.bool(true, "Show developing reversals", tooltip = DEVELOPING_TOOLTIP, group = GROUP_STYLE)
int confirmedExtensionInput = input.int(2, "Confirmed box extension", minval = 0, maxval = 50, tooltip = EXTENSION_TOOLTIP, group = GROUP_STYLE)
int maxHistoryInput = input.int(80, "Historical setups", minval = 1, maxval = 150, tooltip = HISTORY_TOOLTIP, group = GROUP_STYLE)
color zoneColorInput = input.color(#ff9f43, "Reversal zone", tooltip = "Color used for developing and confirmed reversal boxes.", group = GROUP_STYLE)
color levelColorInput = input.color(#7f1d1d, "Sweep level and marker", tooltip = "Color used for confirmed liquidity levels and sweep markers.", group = GROUP_STYLE)

// --- Historical-object storage ---

var array<box> historicalBoxesArray = array.new<box>()
var array<line> historicalLinesArray = array.new<line>()
var array<label> historicalLabelsArray = array.new<label>()

trimHistory(int maximumSetups) =>
    while array.size(historicalBoxesArray) > maximumSetups
        box.delete(array.shift(historicalBoxesArray))
        line.delete(array.shift(historicalLinesArray))
        label.delete(array.shift(historicalLabelsArray))

// --- Core calculations ---
// Herman Trading — original sweep/reversal engine preserved without logic changes.

float atrValue = ta.atr(atrLengthInput)
float pivotHighValue = ta.pivothigh(high, swingLengthInput, swingLengthInput)
float pivotLowValue = ta.pivotlow(low, swingLengthInput, swingLengthInput)
float priorStructureLow = ta.lowest(low, structureLengthInput)[1]
float priorStructureHigh = ta.highest(high, structureLengthInput)[1]
float candleBody = math.abs(close - open)
bool displacementPass = not na(atrValue) and candleBody >= atrValue * minDisplacementInput

// --- Latest confirmed liquidity levels ---

var float latestSwingHigh = na
var float latestSwingLow = na
var int latestSwingHighBar = na
var int latestSwingLowBar = na
var bool swingHighAvailable = false
var bool swingLowAvailable = false

if not na(pivotHighValue)
    latestSwingHigh := pivotHighValue
    latestSwingHighBar := bar_index - swingLengthInput
    swingHighAvailable := true

if not na(pivotLowValue)
    latestSwingLow := pivotLowValue
    latestSwingLowBar := bar_index - swingLengthInput
    swingLowAvailable := true

// --- Bearish reversal state ---

var bool bearishActive = false
var bool bearishReclaimed = false
var int bearishStartBar = na
var float bearishLevel = na
var float bearishExtreme = na
var float bearishConfirmationLevel = na
var box bearishBoxId = na
var line bearishLineId = na
var label bearishLabelId = na

// --- Bullish reversal state ---

var bool bullishActive = false
var bool bullishReclaimed = false
var int bullishStartBar = na
var float bullishLevel = na
var float bullishExtreme = na
var float bullishConfirmationLevel = na
var box bullishBoxId = na
var line bullishLineId = na
var label bullishLabelId = na

bool bearishConfirmedSignal = false
bool bullishConfirmedSignal = false

if barstate.isconfirmed
    float minimumPenetration = nz(atrValue) * minPenetrationInput

    // Start a bearish candidate when price sweeps a confirmed swing high.
    bool bearishSweep = not bearishActive and swingHighAvailable and not na(latestSwingHigh) and not na(priorStructureLow) and high >= latestSwingHigh + minimumPenetration

    if bearishSweep
        bearishActive := true
        bearishReclaimed := close < latestSwingHigh
        bearishStartBar := bar_index
        bearishLevel := latestSwingHigh
        bearishExtreme := high
        bearishConfirmationLevel := priorStructureLow
        swingHighAvailable := false

        color developingFill = showDevelopingInput ? color.new(zoneColorInput, 88) : color.new(zoneColorInput, 100)
        color developingBorder = showDevelopingInput ? color.new(zoneColorInput, 65) : color.new(zoneColorInput, 100)

        bearishBoxId := box.new(bar_index, bearishExtreme, bar_index + 1, bearishLevel, xloc = xloc.bar_index, bgcolor = developingFill, border_color = developingBorder)
        bearishLineId := line.new(latestSwingHighBar, bearishLevel, bar_index, bearishLevel, xloc = xloc.bar_index, color = showDevelopingInput ? color.new(levelColorInput, 75) : color.new(levelColorInput, 100), style = line.style_dotted)
        bearishLabelId := label.new(latestSwingHighBar, bearishLevel, "×", xloc = xloc.bar_index, style = label.style_label_center, color = TRANSPARENT_COLOR, textcolor = showDevelopingInput ? color.new(levelColorInput, 70) : color.new(levelColorInput, 100), size = size.small)

    if bearishActive
        bearishExtreme := math.max(bearishExtreme, high)
        bearishReclaimed := bearishReclaimed or close < bearishLevel
        box.set_top(bearishBoxId, bearishExtreme)
        box.set_right(bearishBoxId, bar_index + 1)
        line.set_x2(bearishLineId, bar_index)

        bool confirmBearish = bearishReclaimed and close < bearishConfirmationLevel and displacementPass
        bool expireBearish = bar_index - bearishStartBar > maxConfirmationBarsInput

        if confirmBearish
            bearishConfirmedSignal := true
            box.set_right(bearishBoxId, bar_index + confirmedExtensionInput)
            box.set_bgcolor(bearishBoxId, color.new(zoneColorInput, 35))
            box.set_border_color(bearishBoxId, color.new(zoneColorInput, 5))
            box.set_border_width(bearishBoxId, 1)
            line.set_color(bearishLineId, color.new(levelColorInput, 20))
            line.set_style(bearishLineId, line.style_solid)
            label.set_textcolor(bearishLabelId, levelColorInput)

            array.push(historicalBoxesArray, bearishBoxId)
            array.push(historicalLinesArray, bearishLineId)
            array.push(historicalLabelsArray, bearishLabelId)
            trimHistory(maxHistoryInput)

            bearishActive := false
            bearishBoxId := na
            bearishLineId := na
            bearishLabelId := na

        else if expireBearish
            box.delete(bearishBoxId)
            line.delete(bearishLineId)
            label.delete(bearishLabelId)
            bearishActive := false
            bearishBoxId := na
            bearishLineId := na
            bearishLabelId := na

    // Start a bullish candidate when price sweeps a confirmed swing low.
    bool bullishSweep = not bullishActive and swingLowAvailable and not na(latestSwingLow) and not na(priorStructureHigh) and low <= latestSwingLow - minimumPenetration

    if bullishSweep
        bullishActive := true
        bullishReclaimed := close > latestSwingLow
        bullishStartBar := bar_index
        bullishLevel := latestSwingLow
        bullishExtreme := low
        bullishConfirmationLevel := priorStructureHigh
        swingLowAvailable := false

        color developingFill = showDevelopingInput ? color.new(zoneColorInput, 88) : color.new(zoneColorInput, 100)
        color developingBorder = showDevelopingInput ? color.new(zoneColorInput, 65) : color.new(zoneColorInput, 100)

        bullishBoxId := box.new(bar_index, bullishLevel, bar_index + 1, bullishExtreme, xloc = xloc.bar_index, bgcolor = developingFill, border_color = developingBorder)
        bullishLineId := line.new(latestSwingLowBar, bullishLevel, bar_index, bullishLevel, xloc = xloc.bar_index, color = showDevelopingInput ? color.new(levelColorInput, 75) : color.new(levelColorInput, 100), style = line.style_dotted)
        bullishLabelId := label.new(latestSwingLowBar, bullishLevel, "×", xloc = xloc.bar_index, style = label.style_label_center, color = TRANSPARENT_COLOR, textcolor = showDevelopingInput ? color.new(levelColorInput, 70) : color.new(levelColorInput, 100), size = size.small)

    if bullishActive
        bullishExtreme := math.min(bullishExtreme, low)
        bullishReclaimed := bullishReclaimed or close > bullishLevel
        box.set_bottom(bullishBoxId, bullishExtreme)
        box.set_right(bullishBoxId, bar_index + 1)
        line.set_x2(bullishLineId, bar_index)

        bool confirmBullish = bullishReclaimed and close > bullishConfirmationLevel and displacementPass
        bool expireBullish = bar_index - bullishStartBar > maxConfirmationBarsInput

        if confirmBullish
            bullishConfirmedSignal := true
            box.set_right(bullishBoxId, bar_index + confirmedExtensionInput)
            box.set_bgcolor(bullishBoxId, color.new(zoneColorInput, 35))
            box.set_border_color(bullishBoxId, color.new(zoneColorInput, 5))
            box.set_border_width(bullishBoxId, 1)
            line.set_color(bullishLineId, color.new(levelColorInput, 20))
            line.set_style(bullishLineId, line.style_solid)
            label.set_textcolor(bullishLabelId, levelColorInput)

            array.push(historicalBoxesArray, bullishBoxId)
            array.push(historicalLinesArray, bullishLineId)
            array.push(historicalLabelsArray, bullishLabelId)
            trimHistory(maxHistoryInput)

            bullishActive := false
            bullishBoxId := na
            bullishLineId := na
            bullishLabelId := na

        else if expireBullish
            box.delete(bullishBoxId)
            line.delete(bullishLineId)
            label.delete(bullishLabelId)
            bullishActive := false
            bullishBoxId := na
            bullishLineId := na
            bullishLabelId := na

// --- Alerts ---
// Herman Trading — Sweep Reversal Map [Herman] alert conditions.

alertcondition(bearishConfirmedSignal, "Bearish sweep reversal confirmed", "Bearish liquidity sweep reversal confirmed on {{ticker}} {{interval}}.")
alertcondition(bullishConfirmedSignal, "Bullish sweep reversal confirmed", "Bullish liquidity sweep reversal confirmed on {{ticker}} {{interval}}.")
alertcondition(bearishConfirmedSignal or bullishConfirmedSignal, "Any sweep reversal confirmed", "Liquidity sweep reversal confirmed on {{ticker}} {{interval}}.")
````
