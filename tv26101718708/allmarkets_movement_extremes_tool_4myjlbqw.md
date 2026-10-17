# All-Markets Movement Extremes Tool

- url: https://www.tradingview.com/script/4MyJLBqW-All-Markets-Movement-Extremes-Tool/
- type: indicator
- pine_id: PUB;405b7ab7ca574d8394627578ce022e56
- version: 1.0

## Description

A causal all-markets movement tool for identifying retained terminal PEAK/TROUGH extremes and exposing the earliest available confirmation of those extrema after the required price structure develops.

[b]Name:[/b]
All-Markets Movement Extremes Tool

[b]Searchable Name:[/b]
All-Markets Movement Extremes Tool

[b]Technical Name:[/b]
All-Markets Non-Repainting Terminal-to-Causal Directional Movement Extremes Tool

[b]Short title:[/b]
Movement Extremes

[b]Summary[/b]
All-Markets Movement Extremes Tool identifies terminal peaks and troughs within developing directional movement and preserves the causal confirmation that makes each retained extreme available.

The central difficulty is that a completed extreme and the [b]generated signal[/b] capable of establishing that extreme are not necessarily available at the same time.

A trough can already exist before enough upward structure has developed to confirm that the downward movement terminated there.

A peak can already exist before enough downward structure has developed to confirm that the upward movement terminated there.

Price can therefore move meaningfully away from the terminal before the corresponding confirmation becomes available.

The tool is [b]built around that separation.[/b]

During an active directional leg, the current extreme remains provisional and can be replaced by a newer same-side high or low.

Once the required opposite structure confirms, the retained extreme becomes:

[list]
[*][b]TROUGH[/b] for the completed low of the prior downward movement
[*][b]PEAK[/b] for the completed high of the prior upward movement
[/list]

The terminal marker remains attached to the retained movement extreme.

The causal confirmation remains attached to the later bar where that extreme became confirmable.

This keeps two important references visible at the same time:

[b]where the directional movement terminated[/b]

and

[b]where the corresponding confirmation became available[/b]

[b]The confirmed PEAK/TROUGH stream can therefore provide context for directional-movement trading, filtering, confirmation, and broader trading decisions, while the stream itself represents confirmed movement extremes and their causal availability rather than a complete standalone buy/sell signal.[/b]

The result is a directional-movement tool that provides:

[list]
[*]movement direction and transition context
[*]terminal peak/trough identification
[*]directional-movement trading context
[*]confirmation and filtering context
[*]entry/exit context
[*]movement-cycle review
[*]and comparison of completed movement with what became causally available
[/list]

[b]Terminal extremes[/b]
The script follows an active directional leg and retains its strongest extreme.

During an upward leg, the highest retained high remains the potential terminal PEAK.

During a downward leg, the lowest retained low remains the potential terminal TROUGH.

A newer same-side extreme can replace the previous candidate while that directional movement remains active.

The extreme becomes confirmed only after the required opposite structure develops.

This prevents a temporary move away from a high or low from automatically being treated as the completed terminal.

[b]Causal confirmation[/b]

Every confirmed terminal has two important locations.

[b]Terminal[/b]

The retained PEAK or TROUGH belonging to the completed directional movement.

[b]Causal confirmation[/b]

The later confirmed-bar event where enough completed structure exists to establish that terminal.

The terminal shows where the completed movement ended.

The causal confirmation shows when the script could establish that terminal through its forward process.

Those two points can be close together or separated by several bars.

The optional Causal Confirmation Comparison makes that difference visible directly on the chart.

[b]Earliest available confirmation[/b]

The tool attempts to expose a retained terminal on the first confirmed transition that satisfies its active structural requirements.

That does not move the historical terminal forward.

The PEAK or TROUGH remains attached to the completed movement extreme, while the causal marker remains attached to the later confirmation event.

This is what allows the tool to preserve both the final movement location and its actual causal availability.

[b]Directional movement[/b]

The PEAK/TROUGH sequence forms a continuing directional structure.

A confirmed TROUGH establishes the completed low of the preceding downward movement.

A confirmed PEAK establishes the completed high of the preceding upward movement.

Consecutive opposite terminals describe the completed movement between retained extrema.

The tool can display those relationships with HOLD paths and directional backgrounds so the broader directional movement remains visible rather than reducing the chart to isolated labels.

[b]Directional-movement trading context[/b]

The confirmed extremes and their causal transitions provide directional-movement context that can be examined alongside confirmation rules, filtering, entry/exit context, or other market-state methods.

The value of the output is the movement structure it establishes:

[b]terminal extreme → causal confirmation → directional movement context[/b]

That structure remains available for broader trading-related evaluation without changing what the PEAK/TROUGH stream itself represents.

[b]Movement cycles[/b]

Consecutive opposite confirmed extrema form completed directional cycles.

The tool keeps two reference systems available.

[b]Terminal-to-terminal[/b]

The completed movement between retained extrema.

[b]Confirmation-to-confirmation[/b]

The corresponding directional movement between the causal confirmation points.

These measurements can differ substantially because part of the terminal movement can occur before confirmation becomes available.

[b]Last capture / confirm gap[/b]

The Movement Cycle page shows [b]Last capture / confirm gap[/b] for the most recent completed cycle.

The capture value compares the latest completed terminal-to-terminal directional result with the corresponding confirmation-to-confirmation result when the terminal movement is positive.

The confirm gap shows the difference between those two completed-cycle results.

Together, they provide a compact comparison between the retained movement extremes and the corresponding causal confirmation references.

[b]Unconfirmed context[/b]

Not every developing extreme becomes the retained terminal.

An earlier high can be superseded by a higher high.

An earlier low can be superseded by a lower low.

When enabled, the tool can expose this context separately from the confirmed PEAK/TROUGH sequence.

The optional Minimum Reversal Filter can also reject structural transitions that do not meet the selected movement requirement.

[b]Current movement[/b]

For the latest confirmed extreme, the tool can compare:

[list]
[*]terminal price
[*]confirmation close
[*]current price
[*]terminal-to-confirm move
[*]price change from confirmation to current
[*]directional move from confirmation to current
[*]best move after confirmation
[*]and bars since confirmation
[/list]

This provides a current directional reference after the extreme has been established.

[b]Status pages[/b]

The tool includes four compact status pages:

[list]
[*][b]Summary[/b]
[*][b]Movement Cycle[/b]
[*][b]Timing[/b]
[*][b]Guide[/b]
[/list]

Summary provides the broad state of confirmed extrema and completed movement cycles.

Movement Cycle focuses on the latest terminal, its confirmation, current movement, and the previous completed cycle.

Timing focuses on terminal-to-confirmation separation and structural timing.

Guide provides a compact interpretation of the active PEAK/TROUGH framework.

[b]Alerts[/b]

Optional alerts are available for confirmed PEAK and TROUGH events.

The alert occurs when the causal confirmation becomes available.

The terminal remains attached to the retained movement extreme, while the alert reflects the later confirmation event.

This preserves the difference between terminal location and causal availability.

[b]Features[/b]
[list]
[*]all-markets directional movement framework
[*]retained terminal PEAK identification
[*]retained terminal TROUGH identification
[*]causal confirmed-bar operation
[*]terminal-versus-confirmation separation
[*]Causal Confirmation Comparison
[*]Confirmed Hold Path
[*]Confirmed Hold Background
[*]movement-cycle tracking
[*]terminal-to-current directional movement
[*]confirm-to-current directional movement
[*]best move after confirm
[*]Last capture / confirm gap
[*]Unconfirmed Extreme Context
[*]Minimum Reversal Filter
[*]compact Summary, Movement Cycle, Timing, and Guide pages
[*]confirmed PEAK/TROUGH alerts
[/list]
[b]Strengths[/b]

[b]Terminal Extreme Preservation[/b] — the completed PEAK/TROUGH remains anchored to the retained movement endpoint.

[b]Causal Availability[/b] — the corresponding confirmation remains separately visible where it actually became available.

[b]Directional Context[/b] — the output describes continuing directional movement rather than isolated bar labels.

[b]All-Markets Use[/b] — the framework can be applied across different markets because it is based on directional price structure.

[b]Early Causal Exposure[/b] — the tool attempts to establish the retained terminal on the first qualifying confirmed transition.

[b]Terminal-versus-Causal Comparison[/b] — completed movement and causally available movement remain directly comparable.

[b]Broader Trading Context[/b] — the confirmed extrema provide directional, confirmation, filtering, and entry/exit context while retaining their underlying movement-extreme meaning.

[b]Weaknesses[/b]

[b]Confirmation Delay[/b] — the terminal can exist before enough opposite structure develops to confirm it.

[b]Movement Before Confirmation[/b] — part of the next directional movement can occur before the causal confirmation becomes available.

[b]Superseded Extremes[/b] — developing terminal candidates can be replaced by newer same-side extremes.

[b]Standalone Trade Outcome Variability[/b] — confirmed PEAK/TROUGH extremes can remain structurally reliable movement references while the result of directly trading every confirmation as its own buy/sell action can vary substantially across market conditions.

[b]Structural Dependence[/b] — confirmation timing depends on the selected structural requirements.

[b]No Complete Trade Management[/b] — position sizing, risk management, stop placement, profit targets, and wider trade-management logic are separate from the movement-extreme output.

[b]Who it’s for[/b]

This tool is suited for users interested in:
[list]
[*]terminal market peaks and troughs
[*]directional movement trading
[*]movement-transition confirmation
[*]structural filtering
[*]entry/exit context
[*]causal versus completed movement
[*]terminal-to-terminal cycles
[*]confirmation timing
[*]Last capture / confirm gap
[*]and incorporating confirmed extrema into broader trading methods
[/list]

It is especially relevant when the question is not only:

[b]“Where did the movement terminate?”[/b]

but also:

[b]“When did that terminal become causally available?”[/b]

[b]Known limitations[/b]

The final retained extreme cannot be confirmed until enough opposite structure has developed.

Some movement can therefore occur before confirmation.

Some developing terminal candidates can be superseded.

Some confirmation-to-confirmation cycles can be non-positive.

The distinction between the terminal and the causal confirmation is therefore explicitly preserved as part of the tool's output.

[b]Final note[/b]

All-Markets Movement Extremes Tool identifies retained terminal PEAK/TROUGH extremes and exposes the causal confirmation of those extrema.

The terminal remains attached to the completed movement extreme.

The causal confirmation remains attached to the point where the required structure becomes available.

The relationship between those two references provides directional movement context for confirmation, filtering, cycle comparison, and broader trading-related evaluation.

## Source Code

````pine
// © AceInfinity
// All-Markets Movement Extremes Tool
// All-markets directional-movement tool for confirmed terminal peaks and troughs.
// The active leg retains its running extreme until a confirmed opposite structure break establishes the completed movement terminal.
// Flip Confirm Bars defines the opposite structure window immediately preceding the current bar. An UP leg confirms a PEAK when the current confirmed close breaks below that prior-window low; a DOWN leg confirms a TROUGH when it breaks above that prior-window high.
// Flip Confirm Bars = 1 uses only the immediately prior bar. Larger values use a wider already-closed structure window and therefore require a broader break.
// Optional Minimum Reversal Filter is OFF by default. When enabled, a PEAK also requires the retained leg high-to-confirmation-bar low reversal to meet Minimum Reversal %, and a TROUGH requires the retained leg low-to-confirmation-bar high reversal to meet Minimum Reversal %.
// One terminal extreme is retained per active leg. New same-side extremes update that terminal until the opposite structure break confirms it and starts the next leg.
// Primary PEAK/TROUGH labels are anchored to the retained terminal bar at that bar's high/low. Optional Causal Confirmation Comparison shows the actual closed confirmation bar and connects it to the terminal.
// False context records unconfirmed terminal candidates replaced by newer same-side extremes and structure-break attempts rejected by the optional Minimum Reversal Filter.
// Consecutive confirmed opposite movement terminals define completed terminal-to-terminal cycles. HOLD visuals connect those retained extremes and can add a low-opacity directional background across the interval.
// Terminal-to-terminal result measures the retained movement extreme-to-extreme change. Causal result measures the corresponding confirmation-close-to-confirmation-close directional change. Opportunity Capture compares those completed-cycle results when the terminal movement is positive.
// The script runs in causal confirmed-bar mode. It identifies retained terminal PEAK/TROUGH extremes and exposes their earliest available causal confirmation from the completed price structure.
// Its output describes confirmed movement extremes and directional structure rather than a complete standalone buy/sell signal.
// This script is experimental and intended for inspection, testing, and personal use. It is not financial advice.
//@version=6
indicator("All-Markets Movement Extremes Tool", shorttitle="Movement Extremes", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=200, max_bars_back=5000)

//==================================================================================================
// SECTION 1 — MOVEMENT EXTREMES, REVERSAL FILTER, AND DISPLAY INPUTS
//==================================================================================================
pivotLength = input.int(10, "Pivot Length (Initial Leg Seed)", minval=1, tooltip="Confirmed-bar lookback used to establish the initial active leg before leg-flip confirmation begins.")
flipConfirmBars = input.int(5, "Flip Confirm Bars", minval=1, tooltip="Number of already-closed bars immediately preceding the current bar that define the flip structure. UP → DOWN confirms when the current closed bar finishes below their lowest low. DOWN → UP confirms when it finishes above their highest high. 1 uses the immediately prior bar.")
useMinReversalFilter = input.bool(false, "Use Minimum Reversal Filter", tooltip="When enabled, a structural flip is accepted only when the terminal-to-confirmation-bar reversal also meets Minimum Reversal %.")
minReversalPct = input.float(0.20, "Minimum Reversal %", minval=0.0, step=0.05, tooltip="Used only when Use Minimum Reversal Filter is ON. PEAK measures terminal high → confirmation-bar low. TROUGH measures terminal low → confirmation-bar high.")

extendLines = input.bool(true, "Extend Trendlines", tooltip="Extends the latest confirmed PEAK terminal-high line and TROUGH terminal-low line to the right.")
labelDistance = input.float(1.0, "Vertical Distance (Labels)", minval=0.1, tooltip="Reserved minimum-tick spacing for optional secondary annotations. Signal labels themselves remain anchored to bar highs/lows.")

showSignals = input.bool(true, "Show Confirmed Peaks / Troughs", tooltip="Shows confirmed PEAK/TROUGH labels at their retained terminal extremes.")
showSignalCanvas = input.bool(true, "Show Signal Canvas", tooltip="Applies a neutral full-chart background behind the terminal, hold, and confirmation visuals.")
signalCanvasTransparency = input.int(92, "Signal Canvas Transparency", minval=86, maxval=97)

showHoldPath = input.bool(true, "Show Confirmed Hold Path", tooltip="Connects each confirmed terminal to the next confirmed opposite terminal.")
showHoldBackground = input.bool(true, "Show Confirmed Hold Background", tooltip="Adds the low-opacity green/red hold zone behind each displayed confirmed terminal-to-terminal interval.")
showHoldLabel = input.bool(true, "Show Hold Label", tooltip="Shows the completed terminal-to-terminal structural result on the hold path.")

showCausalComparison = input.bool(false, "Show Causal Confirmation Comparison", tooltip="Shows CAUSAL TROUGH/PEAK on the actual closed flip-confirmation bar, anchored to that bar's low/high, with a dashed connector back to the retained terminal. The normal terminal marker remains at the retained extreme.")
showFalseContext = input.bool(false, "Show Unconfirmed Extreme Context", tooltip="Shows terminal candidates superseded before confirmation and structural flip attempts blocked by the optional reversal filter.")
falseContextDisplay = input.string("X Markers", "Unconfirmed Extreme Display", options=["X Markers", "Labels"])
maxFalseContextToDraw = input.int(160, "Maximum False Context To Draw", minval=10, maxval=300)
maxCyclesToDraw = input.int(24, "Maximum Hold Cycles To Draw", minval=1, maxval=80)
signalLabelTransparency = input.int(12, "Signal Label Transparency", minval=0, maxval=75)

enableSignalAlerts = input.bool(false, "Enable Confirmed Peak / Trough Alerts", tooltip="Emits a dynamic alert only when a PEAK or TROUGH is confirmed by a closed-bar leg flip. Confirmation close, terminal bar/price, and confirmation delay are included.")

showStatus = input.bool(true, "Show Status Table")
statusPage = input.string("Summary", "Status Table Page", options=["Summary", "Movement Cycle", "Timing", "Guide"])

//==================================================================================================
// SECTION 2 — HELPERS
//==================================================================================================
eps = math.max(syminfo.mintick, 1e-6)

f_fmtPct(float _v) =>
    na(_v) ? "n/a" : str.tostring(_v, "#.00") + "%"

f_statusCell(table _t, int _row, string _left, string _right) =>
    table.cell(_t, 0, _row, _left, text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(_t, 1, _row, _right, text_color=color.white, bgcolor=color.new(color.black, 20))

// Direction-adjusted movement result:
// TROUGH: positive when price is above the start price.
// PEAK: positive when price is below the start price.
f_cycleReturn(int _dir, float _entry, float _exit) =>
    na(_entry) or na(_exit) or math.abs(_entry) <= eps ? na : _dir * (_exit - _entry) * 100.0 / math.abs(_entry)

f_trimLabels(label[] _a, int _max) =>
    while array.size(_a) > _max
        label.delete(array.shift(_a))

f_trimLines(line[] _a, int _max) =>
    while array.size(_a) > _max
        line.delete(array.shift(_a))

f_trimBoxes(box[] _a, int _max) =>
    while array.size(_a) > _max
        box.delete(array.shift(_a))

//==================================================================================================
// SECTION 3 — PERSISTENT LEG ENGINE AND STRUCTURAL FLIP SOURCE
//==================================================================================================
// legDir:
//   +1 = active UP leg. Its retained terminal candidate is legHigh and the next confirmed terminal is PEAK.
//   -1 = active DOWN leg. Its retained terminal candidate is legLow and the next confirmed terminal is TROUGH.
//    0 = not yet seeded.
var int legDir = 0
var float legHigh = na
var int legHighBar = na
var float legLow = na
var int legLowBar = na

// Latest confirmed terminal levels used only for the horizontal terminal trendlines.
var float lastPivotHigh = na
var int lastPivotHighBar = na
var float lastPivotLow = na
var int lastPivotLowBar = na
var line upperTrendline = na
var line lowerTrendline = na

// False-context de-duplication for repeated reversal-filter failures against the same terminal.
var int lastBlockedFilterDir = 0
var int lastBlockedFilterTerminalBar = na

// Initial seed establishes the first active leg from confirmed structural highs/lows. Confirmed PEAK/TROUGH generation begins from subsequent leg flips.
bool seedPotentialHigh = barstate.isconfirmed and ta.highestbars(high, pivotLength) == 0
bool seedPotentialLow = barstate.isconfirmed and ta.lowestbars(low, pivotLength) == 0

if barstate.isconfirmed and legDir == 0
    if seedPotentialHigh and not seedPotentialLow
        legDir := 1
        legHigh := high
        legHighBar := bar_index
        legLow := low
        legLowBar := bar_index
    else if seedPotentialLow and not seedPotentialHigh
        legDir := -1
        legLow := low
        legLowBar := bar_index
        legHigh := high
        legHighBar := bar_index
    else
        legHigh := na(legHigh) ? high : math.max(legHigh, high)
        legLow := na(legLow) ? low : math.min(legLow, low)
        legHighBar := na(legHighBar) ? bar_index : legHighBar
        legLowBar := na(legLowBar) ? bar_index : legLowBar

// The flip structure is the lowest low / highest high of the N bars immediately preceding the current bar. The current closed bar is then tested against that fixed prior structure.
float priorFlipLow = ta.lowest(low, flipConfirmBars)[1]
float priorFlipHigh = ta.highest(high, flipConfirmBars)[1]

bool upFlipToDown =
     barstate.isconfirmed and
     legDir == 1 and
     not na(priorFlipLow) and
     close < priorFlipLow

bool downFlipToUp =
     barstate.isconfirmed and
     legDir == -1 and
     not na(priorFlipHigh) and
     close > priorFlipHigh

// Minimum Reversal % is evaluated from the retained terminal that exists after the current bar's
// same-side extreme update, so the filter and the stored reversal statistic use the same terminal identity.

// Per-bar confirmed signal output.
// +1 = TROUGH from confirmed DOWN → UP flip.
// -1 = PEAK from confirmed UP → DOWN flip.
int signalDirNow = 0
int signalTerminalBarNow = na
float signalTerminalPriceNow = na
int signalConfirmBarNow = na
float signalConfirmCloseNow = na
float signalConfirmVisualPriceNow = na
float signalReversalPctNow = na

// Per-bar false-context outputs.
// Superseded terminal context and reversal-filter rejection are tracked independently so both states can be recorded when they occur on the same bar.
bool supersededContextNow = false
int supersededContextDirNow = 0
int supersededContextBarNow = na
float supersededContextPriceNow = na

bool reversalFilteredContextNow = false
int reversalFilteredContextDirNow = 0
int reversalFilteredContextBarNow = na
float reversalFilteredContextPriceNow = na

// Preserve the leg direction present at the start of the bar so one confirmed structure break produces one leg transition on that bar.
int legDirAtBarStart = legDir

if barstate.isconfirmed and legDirAtBarStart == 1
    // A newer same-side high replaces the still-unconfirmed PEAK terminal candidate.
    if na(legHigh) or high > legHigh + eps
        if not na(legHigh) and not na(legHighBar)
            supersededContextNow := true
            supersededContextDirNow := -1
            supersededContextBarNow := legHighBar
            supersededContextPriceNow := legHigh

        legHigh := high
        legHighBar := bar_index

    if na(legLow) or low < legLow - eps
        legLow := low
        legLowBar := bar_index

    float sellReversalPctNow = not na(legHigh) and math.abs(legHigh) > eps ? (legHigh - low) * 100.0 / math.abs(legHigh) : na
    bool sellReversalOkNow = not useMinReversalFilter or (not na(sellReversalPctNow) and sellReversalPctNow >= minReversalPct)

    if upFlipToDown
        if sellReversalOkNow
            signalDirNow := -1
            signalTerminalBarNow := legHighBar
            signalTerminalPriceNow := legHigh
            signalConfirmBarNow := bar_index
            signalConfirmCloseNow := close
            signalConfirmVisualPriceNow := high
            signalReversalPctNow := sellReversalPctNow

            // Confirmed PEAK terminal trendline.
            lastPivotHigh := legHigh
            lastPivotHighBar := legHighBar
            if not na(upperTrendline)
                line.delete(upperTrendline)
            upperTrendline := line.new(lastPivotHighBar, lastPivotHigh, lastPivotHighBar + 1, lastPivotHigh, xloc=xloc.bar_index, color=color.red, width=2, extend=extendLines ? extend.right : extend.none)

            // Start the DOWN leg from the current confirmed flip bar.
            legDir := -1
            legLow := low
            legLowBar := bar_index
            legHigh := high
            legHighBar := bar_index
            lastBlockedFilterDir := 0
            lastBlockedFilterTerminalBar := na
        else
            // One false-context record per retained terminal identity for reversal-filter rejection.
            bool newBlockedIdentity = lastBlockedFilterDir != -1 or na(lastBlockedFilterTerminalBar) or lastBlockedFilterTerminalBar != legHighBar
            if newBlockedIdentity
                reversalFilteredContextNow := true
                reversalFilteredContextDirNow := -1
                reversalFilteredContextBarNow := legHighBar
                reversalFilteredContextPriceNow := legHigh
                lastBlockedFilterDir := -1
                lastBlockedFilterTerminalBar := legHighBar

else if barstate.isconfirmed and legDirAtBarStart == -1
    // A newer same-side low replaces the still-unconfirmed TROUGH terminal candidate.
    if na(legLow) or low < legLow - eps
        if not na(legLow) and not na(legLowBar)
            supersededContextNow := true
            supersededContextDirNow := 1
            supersededContextBarNow := legLowBar
            supersededContextPriceNow := legLow

        legLow := low
        legLowBar := bar_index

    if na(legHigh) or high > legHigh + eps
        legHigh := high
        legHighBar := bar_index

    float buyReversalPctNow = not na(legLow) and math.abs(legLow) > eps ? (high - legLow) * 100.0 / math.abs(legLow) : na
    bool buyReversalOkNow = not useMinReversalFilter or (not na(buyReversalPctNow) and buyReversalPctNow >= minReversalPct)

    if downFlipToUp
        if buyReversalOkNow
            signalDirNow := 1
            signalTerminalBarNow := legLowBar
            signalTerminalPriceNow := legLow
            signalConfirmBarNow := bar_index
            signalConfirmCloseNow := close
            signalConfirmVisualPriceNow := low
            signalReversalPctNow := buyReversalPctNow

            // Confirmed TROUGH terminal trendline.
            lastPivotLow := legLow
            lastPivotLowBar := legLowBar
            if not na(lowerTrendline)
                line.delete(lowerTrendline)
            lowerTrendline := line.new(lastPivotLowBar, lastPivotLow, lastPivotLowBar + 1, lastPivotLow, xloc=xloc.bar_index, color=color.green, width=2, extend=extendLines ? extend.right : extend.none)

            // Start the UP leg from the current confirmed flip bar.
            legDir := 1
            legHigh := high
            legHighBar := bar_index
            legLow := low
            legLowBar := bar_index
            lastBlockedFilterDir := 0
            lastBlockedFilterTerminalBar := na
        else
            bool newBlockedIdentity = lastBlockedFilterDir != 1 or na(lastBlockedFilterTerminalBar) or lastBlockedFilterTerminalBar != legLowBar
            if newBlockedIdentity
                reversalFilteredContextNow := true
                reversalFilteredContextDirNow := 1
                reversalFilteredContextBarNow := legLowBar
                reversalFilteredContextPriceNow := legLow
                lastBlockedFilterDir := 1
                lastBlockedFilterTerminalBar := legLowBar

bool buySignalNow = signalDirNow > 0
bool sellSignalNow = signalDirNow < 0

//==================================================================================================
// SECTION 4 — EXTREME LEDGER, UNCONFIRMED CONTEXT, CYCLE METRICS, AND VISUALS
//==================================================================================================
var int[] signalDir = array.new_int()
var int[] signalTerminalBar = array.new_int()
var float[] signalTerminalPrice = array.new_float()
var int[] signalConfirmBar = array.new_int()
var float[] signalConfirmClose = array.new_float()
var float[] signalReversalPct = array.new_float()

var label[] primaryLabels = array.new_label()
var label[] secondaryLabels = array.new_label()
var label[] falseLabels = array.new_label()
var line[] holdLines = array.new_line()
var line[] causalLines = array.new_line()
var box[] holdBoxes = array.new_box()

var int confirmedSignalCount = 0
var int confirmedBuyCount = 0
var int confirmedSellCount = 0
var int completedCycleCount = 0
var int positiveCycleCount = 0
var int nonPositiveCycleCount = 0

var int falseContextCount = 0
var int supersededCandidateCount = 0
var int reversalFilteredCount = 0

var float latestReferenceResult = na
var float latestCausalResult = na
var float latestOpportunityCapture = na
var float latestConfirmationLoss = na
var int latestTerminalCycleBars = na
var int latestCausalCycleBars = na
var int latestConfirmDelay = na
var float latestMoveBeforeConfirm = na
var float latestSignalReversalPct = na

var float totalConfirmDelay = 0.0
var int maxConfirmDelay = 0

// Open-signal state is separate from completed-cycle statistics.
// Best post-confirm movement starts at the confirmation close. After that bar, BUY tracks the
// highest high reached and SELL tracks the lowest low reached on subsequent confirmed bars.
// The percentage is measured from confirmation close to that best favorable high/low.
var int openSignalDir = 0
var int openSignalConfirmBar = na
var float openSignalConfirmPrice = na
var float openSignalBestFavorablePrice = na

// False context records each unconfirmed terminal replacement and each reversal-filter rejection independently.
if supersededContextNow and not na(supersededContextBarNow) and not na(supersededContextPriceNow)
    falseContextCount += 1
    supersededCandidateCount += 1

    if showFalseContext
        bool falseBuy = supersededContextDirNow > 0
        if falseContextDisplay == "X Markers"
            label falseMark = label.new(supersededContextBarNow, supersededContextPriceNow, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_xcross, textcolor=color.red, color=color.new(color.red, 0), size=size.large)
            array.push(falseLabels, falseMark)
        else
            string falseText = "UNCONFIRMED " + (falseBuy ? "TROUGH" : "PEAK") + "\nSUPERSEDED BEFORE FLIP"
            label falseLabel = label.new(supersededContextBarNow, supersededContextPriceNow, falseText, xloc=xloc.bar_index, yloc=yloc.price, style=falseBuy ? label.style_label_up : label.style_label_down, textcolor=color.white, color=color.new(color.red, 18), size=size.small)
            array.push(falseLabels, falseLabel)

if reversalFilteredContextNow and not na(reversalFilteredContextBarNow) and not na(reversalFilteredContextPriceNow)
    falseContextCount += 1
    reversalFilteredCount += 1

    if showFalseContext
        bool falseBuy = reversalFilteredContextDirNow > 0
        if falseContextDisplay == "X Markers"
            label falseMark = label.new(reversalFilteredContextBarNow, reversalFilteredContextPriceNow, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_xcross, textcolor=color.red, color=color.new(color.red, 0), size=size.large)
            array.push(falseLabels, falseMark)
        else
            string falseText = "UNCONFIRMED " + (falseBuy ? "TROUGH" : "PEAK") + "\nREVERSAL FILTER"
            label falseLabel = label.new(reversalFilteredContextBarNow, reversalFilteredContextPriceNow, falseText, xloc=xloc.bar_index, yloc=yloc.price, style=falseBuy ? label.style_label_up : label.style_label_down, textcolor=color.white, color=color.new(color.red, 18), size=size.small)
            array.push(falseLabels, falseLabel)

if showFalseContext
    f_trimLabels(falseLabels, maxFalseContextToDraw)

// A confirmed movement extreme is written on the first closed bar satisfying the opposite structure break and, when enabled, the minimum reversal requirement. Its primary marker remains anchored to the retained terminal extreme.
if signalDirNow != 0 and not na(signalTerminalBarNow) and not na(signalTerminalPriceNow)
    int previousCount = array.size(signalDir)

    array.push(signalDir, signalDirNow)
    array.push(signalTerminalBar, signalTerminalBarNow)
    array.push(signalTerminalPrice, signalTerminalPriceNow)
    array.push(signalConfirmBar, signalConfirmBarNow)
    array.push(signalConfirmClose, signalConfirmCloseNow)
    array.push(signalReversalPct, signalReversalPctNow)

    confirmedSignalCount += 1
    if buySignalNow
        confirmedBuyCount += 1
    else
        confirmedSellCount += 1

    // Exact plotted-bar delay: confirmation bar_index minus terminal label bar_index.
    latestConfirmDelay := signalConfirmBarNow - signalTerminalBarNow
    latestSignalReversalPct := signalReversalPctNow
    totalConfirmDelay += latestConfirmDelay
    maxConfirmDelay := math.max(maxConfirmDelay, latestConfirmDelay)

    latestMoveBeforeConfirm :=
         buySignalNow ?
         (signalConfirmCloseNow - signalTerminalPriceNow) * 100.0 / math.max(math.abs(signalTerminalPriceNow), eps) :
         (signalTerminalPriceNow - signalConfirmCloseNow) * 100.0 / math.max(math.abs(signalTerminalPriceNow), eps)

    openSignalDir := signalDirNow
    openSignalConfirmBar := signalConfirmBarNow
    openSignalConfirmPrice := signalConfirmCloseNow
    openSignalBestFavorablePrice := signalConfirmCloseNow

    if showSignals
        color signalColor = buySignalNow ? color.green : color.red
        string signalText = buySignalNow ? "Trough" : "Peak"
        label primaryLabel = label.new(signalTerminalBarNow, signalTerminalPriceNow, signalText, xloc=xloc.bar_index, yloc=yloc.price, style=buySignalNow ? label.style_label_up : label.style_label_down, textcolor=color.white, color=color.new(signalColor, math.min(signalLabelTransparency, 12)), size=size.small)
        array.push(primaryLabels, primaryLabel)

    // Optional confirmation comparison. Terminal identity is unchanged; only the actual knowable bar is
    // exposed. The label is anchored to that confirmation bar's low for BUY and high for SELL.
    if showCausalComparison
        int causalDelay = signalConfirmBarNow - signalTerminalBarNow
        color causalColor = buySignalNow ? color.rgb(46, 74, 112) : color.rgb(176, 82, 64)
        string causalText = buySignalNow ? "Causal Trough" : "Causal Peak"
        if causalDelay > 0
            causalText += "\n+" + str.tostring(causalDelay) + " bar" + (causalDelay == 1 ? "" : "s")

        label causalLabel = label.new(signalConfirmBarNow, signalConfirmVisualPriceNow, causalText, xloc=xloc.bar_index, yloc=yloc.price, style=buySignalNow ? label.style_label_up : label.style_label_down, textcolor=color.white, color=color.new(causalColor, 12), size=size.small)
        array.push(secondaryLabels, causalLabel)

        if signalConfirmBarNow != signalTerminalBarNow or math.abs(signalConfirmVisualPriceNow - signalTerminalPriceNow) > eps
            line causalLine = line.new(signalTerminalBarNow, signalTerminalPriceNow, signalConfirmBarNow, signalConfirmVisualPriceNow, xloc=xloc.bar_index, extend=extend.none, color=color.new(causalColor, 48), width=2, style=line.style_dashed)
            array.push(causalLines, causalLine)

    // Every confirmed flip naturally alternates because the confirmed terminal also changes the active leg.
    // Consecutive signals therefore define one completed hold/cycle.
    if previousCount > 0
        int prevIndex = previousCount - 1
        int prevDir = array.get(signalDir, prevIndex)
        int prevTerminalBar = array.get(signalTerminalBar, prevIndex)
        float prevTerminalPrice = array.get(signalTerminalPrice, prevIndex)
        int prevConfirmBar = array.get(signalConfirmBar, prevIndex)
        float prevConfirmClose = array.get(signalConfirmClose, prevIndex)

        if prevDir != signalDirNow
            completedCycleCount += 1

            latestReferenceResult := f_cycleReturn(prevDir, prevTerminalPrice, signalTerminalPriceNow)
            latestCausalResult := f_cycleReturn(prevDir, prevConfirmClose, signalConfirmCloseNow)
            latestOpportunityCapture :=
                 not na(latestReferenceResult) and latestReferenceResult > 0.0 ?
                 math.max(0.0, math.min(100.0, nz(latestCausalResult, 0.0) * 100.0 / latestReferenceResult)) :
                 na
            latestConfirmationLoss :=
                 not na(latestReferenceResult) and not na(latestCausalResult) ?
                 latestReferenceResult - latestCausalResult :
                 na

            latestTerminalCycleBars := signalTerminalBarNow - prevTerminalBar
            latestCausalCycleBars := signalConfirmBarNow - prevConfirmBar

            bool positiveCycle = not na(latestCausalResult) and latestCausalResult > 0.0
            if positiveCycle
                positiveCycleCount += 1
            else
                nonPositiveCycleCount += 1

            color holdColor = prevDir > 0 ? color.green : color.red

            if showHoldPath
                line holdLine = line.new(prevTerminalBar, prevTerminalPrice, signalTerminalBarNow, signalTerminalPriceNow, xloc=xloc.bar_index, extend=extend.none, color=color.new(holdColor, 12), width=3)
                array.push(holdLines, holdLine)

            if showHoldBackground
                float zonePad = math.max(math.abs(signalTerminalPriceNow - prevTerminalPrice) * 0.10, syminfo.mintick * 10.0)
                float zoneTop = math.max(prevTerminalPrice, signalTerminalPriceNow) + zonePad
                float zoneBottom = math.min(prevTerminalPrice, signalTerminalPriceNow) - zonePad
                box holdBox = box.new(prevTerminalBar, zoneTop, signalTerminalBarNow, zoneBottom, xloc=xloc.bar_index, border_color=color.new(holdColor, 76), border_width=1, bgcolor=color.new(holdColor, 92))
                array.push(holdBoxes, holdBox)

            // HOLD is a path annotation rather than a signal marker, so it stays centered on the path
            // to preserve the first-file visual language without displacing BUY/SELL terminal labels.
            if showHoldLabel
                int holdLabelBar = prevTerminalBar + int(math.floor(float(signalTerminalBarNow - prevTerminalBar) * 0.5))
                float holdLabelPrice = prevTerminalPrice + (signalTerminalPriceNow - prevTerminalPrice) * 0.5
                string holdText = "HOLD\n" + f_fmtPct(latestReferenceResult)
                label holdLabel = label.new(holdLabelBar, holdLabelPrice, holdText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, textcolor=color.white, color=color.new(color.rgb(32, 36, 43), 0), size=size.small)
                array.push(secondaryLabels, holdLabel)

// Bars after confirmation update the best favorable excursion for the currently open signal.
// TROUGH uses the highest high reached after confirmation; PEAK uses the lowest low reached.
// The confirmation bar itself is excluded because the signal is not known until that bar closes.
if openSignalDir != 0 and not na(openSignalConfirmBar) and bar_index > openSignalConfirmBar
    if openSignalDir > 0
        openSignalBestFavorablePrice := na(openSignalBestFavorablePrice) ? high : math.max(openSignalBestFavorablePrice, high)
    else
        openSignalBestFavorablePrice := na(openSignalBestFavorablePrice) ? low : math.min(openSignalBestFavorablePrice, low)

// Visual history limits control the number of retained chart objects.
f_trimLabels(primaryLabels, math.max(maxCyclesToDraw * 2 + 2, 20))
f_trimLabels(secondaryLabels, math.max(maxCyclesToDraw * 3 + 6, 24))
f_trimLines(holdLines, maxCyclesToDraw)
f_trimLines(causalLines, math.max(maxCyclesToDraw * 2 + 2, 20))
f_trimBoxes(holdBoxes, maxCyclesToDraw)

//==================================================================================================
// SECTION 5 — PRESENTATION CANVAS AND CONFIRMED EXTREME ALERTS
//==================================================================================================
color signalCanvasColor = color.rgb(70, 66, 74)
bgcolor(showSignalCanvas ? color.new(signalCanvasColor, signalCanvasTransparency) : na)

alertcondition(buySignalNow, "Confirmed TROUGH", "All-Markets Movement Extremes Tool: confirmed TROUGH")
alertcondition(sellSignalNow, "Confirmed PEAK", "All-Markets Movement Extremes Tool: confirmed PEAK")

if enableSignalAlerts and buySignalNow
    alert("{\"event\":\"TROUGH\",\"price\":" + str.tostring(signalConfirmCloseNow, format.mintick) + ",\"terminal_bar\":" + str.tostring(signalTerminalBarNow) + ",\"terminal_price\":" + str.tostring(signalTerminalPriceNow, format.mintick) + ",\"confirm_bar\":" + str.tostring(signalConfirmBarNow) + ",\"delay_bars\":" + str.tostring(signalConfirmBarNow - signalTerminalBarNow) + ",\"flip_confirm_bars\":" + str.tostring(flipConfirmBars) + "}", alert.freq_once_per_bar_close)

if enableSignalAlerts and sellSignalNow
    alert("{\"event\":\"PEAK\",\"price\":" + str.tostring(signalConfirmCloseNow, format.mintick) + ",\"terminal_bar\":" + str.tostring(signalTerminalBarNow) + ",\"terminal_price\":" + str.tostring(signalTerminalPriceNow, format.mintick) + ",\"confirm_bar\":" + str.tostring(signalConfirmBarNow) + ",\"delay_bars\":" + str.tostring(signalConfirmBarNow - signalTerminalBarNow) + ",\"flip_confirm_bars\":" + str.tostring(flipConfirmBars) + "}", alert.freq_once_per_bar_close)

//==================================================================================================
// SECTION 6 — STATUS TABLE
//==================================================================================================
var table statusTable = table.new(position.top_right, 2, 15, border_width=1)

if barstate.islast
    for r = 0 to 14
        table.cell(statusTable, 0, r, "", bgcolor=color.new(color.black, 100))
        table.cell(statusTable, 1, r, "", bgcolor=color.new(color.black, 100))

    if showStatus
        color defaultHeaderColor = color.rgb(42, 52, 64)
        color activeHeaderColor = color.rgb(168, 126, 46)

        table.cell(statusTable, 0, 0, "All-Markets Movement Extremes Tool", text_color=color.white, bgcolor=color.new(showSignals ? activeHeaderColor : defaultHeaderColor, 0))
        table.cell(statusTable, 1, 0, statusPage, text_color=color.white, bgcolor=color.new(showSignals ? activeHeaderColor : defaultHeaderColor, 0))

        int signalCountStatus = array.size(signalDir)
        int latestIndex = signalCountStatus > 0 ? signalCountStatus - 1 : na
        int latestDir = not na(latestIndex) ? array.get(signalDir, latestIndex) : 0
        int latestTerminalBarStatus = not na(latestIndex) ? array.get(signalTerminalBar, latestIndex) : na
        float latestTerminalPriceStatus = not na(latestIndex) ? array.get(signalTerminalPrice, latestIndex) : na
        int latestConfirmBarStatus = not na(latestIndex) ? array.get(signalConfirmBar, latestIndex) : na
        float latestConfirmCloseStatus = not na(latestIndex) ? array.get(signalConfirmClose, latestIndex) : na
        float latestReversalPctStatus = not na(latestIndex) ? array.get(signalReversalPct, latestIndex) : na
        int latestConfirmDelayStatus =
             not na(latestTerminalBarStatus) and not na(latestConfirmBarStatus) ?
             latestConfirmBarStatus - latestTerminalBarStatus :
             na

        float positiveCycleRate = completedCycleCount > 0 ? positiveCycleCount * 100.0 / completedCycleCount : na
        float averageConfirmDelay = confirmedSignalCount > 0 ? totalConfirmDelay / confirmedSignalCount : na

        // Current-result statistics use the chart's current price. These rows are display statistics;
        // signal confirmation itself remains closed-bar only.
        float statusPrice = close
        int statusBar = bar_index
        float openTerminalResult =
             latestDir != 0 and not na(latestTerminalPriceStatus) and not na(statusPrice) ?
             f_cycleReturn(latestDir, latestTerminalPriceStatus, statusPrice) :
             na
        float openCausalResult =
             latestDir != 0 and not na(latestConfirmCloseStatus) and not na(statusPrice) ?
             f_cycleReturn(latestDir, latestConfirmCloseStatus, statusPrice) :
             na
        float confirmToCurrentPriceChange =
             not na(latestConfirmCloseStatus) and not na(statusPrice) and math.abs(latestConfirmCloseStatus) > eps ?
             (statusPrice - latestConfirmCloseStatus) * 100.0 / math.abs(latestConfirmCloseStatus) :
             na
        float bestCausalMove =
             openSignalDir != 0 and not na(openSignalConfirmPrice) and not na(openSignalBestFavorablePrice) ?
             f_cycleReturn(openSignalDir, openSignalConfirmPrice, openSignalBestFavorablePrice) :
             na
        int openBarsSinceConfirm =
             latestDir != 0 and not na(latestConfirmBarStatus) and not na(statusBar) ?
             math.max(statusBar - latestConfirmBarStatus, 0) :
             na

        string currentLegText =
             legDir > 0 ?
             "UP • NEXT PEAK" :
             legDir < 0 ?
             "DOWN • NEXT TROUGH" :
             "WAITING FOR SEED"

        string reversalFilterText =
             useMinReversalFilter ?
             "ON • " + str.tostring(minReversalPct, "#.##") + "%" :
             "OFF"

        string latestSignalText =
             latestDir > 0 ?
             "TROUGH" :
             latestDir < 0 ?
             "PEAK" :
             "NONE"

        string falseDisplayText = showFalseContext ? "VISIBLE" : "HIDDEN"
        string holdDisplayText = showHoldPath ? (showHoldBackground ? "PATH + BACKGROUND" : "PATH") : (showHoldBackground ? "BACKGROUND" : "HIDDEN")

        if statusPage == "Summary"
            f_statusCell(statusTable, 1, "Confirmed extremes", str.tostring(confirmedSignalCount))
            f_statusCell(statusTable, 2, "Trough count / Peak count", str.tostring(confirmedBuyCount) + " / " + str.tostring(confirmedSellCount))
            f_statusCell(statusTable, 3, "Completed movement cycles", str.tostring(completedCycleCount))
            f_statusCell(statusTable, 4, "Positive / non-positive cycles", str.tostring(positiveCycleCount) + " / " + str.tostring(nonPositiveCycleCount))
            f_statusCell(statusTable, 5, "Positive confirm cycles %", completedCycleCount > 0 ? f_fmtPct(positiveCycleRate) : "WAITING FOR CYCLE")
            f_statusCell(statusTable, 6, "Filtered/unconfirmed events", str.tostring(falseContextCount))
            f_statusCell(statusTable, 7, "Superseded terminals", str.tostring(supersededCandidateCount))
            f_statusCell(statusTable, 8, "Reversal-filter rejections", str.tostring(reversalFilteredCount))
            f_statusCell(statusTable, 9, "Latest confirmed extreme", latestSignalText)
            f_statusCell(statusTable, 10, "Current leg", currentLegText)
            f_statusCell(statusTable, 11, "Flip confirm bars", str.tostring(flipConfirmBars))
            f_statusCell(statusTable, 12, latestSignalText + " terminal→current move", f_fmtPct(openTerminalResult))
            f_statusCell(statusTable, 13, latestSignalText + " confirm→current move", f_fmtPct(openCausalResult))
            f_statusCell(statusTable, 14, "Current price", str.tostring(statusPrice, format.mintick))

        else if statusPage == "Movement Cycle"
            f_statusCell(statusTable, 1, "Latest confirmed extreme", latestSignalText)
            f_statusCell(statusTable, 2, "Terminal price", na(latestTerminalPriceStatus) ? "n/a" : str.tostring(latestTerminalPriceStatus, format.mintick))
            f_statusCell(statusTable, 3, "Confirm close", na(latestConfirmCloseStatus) ? "n/a" : str.tostring(latestConfirmCloseStatus, format.mintick))
            f_statusCell(statusTable, 4, "Current price", str.tostring(statusPrice, format.mintick))
            f_statusCell(statusTable, 5, "Terminal→confirm bars", na(latestConfirmDelayStatus) ? "n/a" : str.tostring(latestConfirmDelayStatus) + " bars")
            f_statusCell(statusTable, 6, latestSignalText + " terminal→confirm move", f_fmtPct(latestMoveBeforeConfirm))
            f_statusCell(statusTable, 7, "Confirm-bar reversal from terminal", f_fmtPct(latestReversalPctStatus))
            f_statusCell(statusTable, 8, "Price change confirm→current", f_fmtPct(confirmToCurrentPriceChange))
            f_statusCell(statusTable, 9, latestSignalText + " directional move→current", f_fmtPct(openCausalResult))
            f_statusCell(statusTable, 10, latestSignalText + " best move after confirm", f_fmtPct(bestCausalMove))
            f_statusCell(statusTable, 11, "Last cycle terminal→terminal", f_fmtPct(latestReferenceResult))
            f_statusCell(statusTable, 12, "Last cycle confirm→confirm", f_fmtPct(latestCausalResult))
            f_statusCell(statusTable, 13, "Last capture / confirm gap", f_fmtPct(latestOpportunityCapture) + " / " + f_fmtPct(latestConfirmationLoss))
            f_statusCell(statusTable, 14, "Bars since confirm", na(openBarsSinceConfirm) ? "n/a" : str.tostring(openBarsSinceConfirm))

        else if statusPage == "Timing"
            f_statusCell(statusTable, 1, "Flip confirm bars", str.tostring(flipConfirmBars))
            f_statusCell(statusTable, 2, "Prior N-bar low", na(priorFlipLow) ? "n/a" : str.tostring(priorFlipLow, format.mintick))
            f_statusCell(statusTable, 3, "Prior N-bar high", na(priorFlipHigh) ? "n/a" : str.tostring(priorFlipHigh, format.mintick))
            f_statusCell(statusTable, 4, "Latest terminal bar", na(latestTerminalBarStatus) ? "n/a" : str.tostring(latestTerminalBarStatus))
            f_statusCell(statusTable, 5, "Latest confirm bar", na(latestConfirmBarStatus) ? "n/a" : str.tostring(latestConfirmBarStatus))
            f_statusCell(statusTable, 6, "Confirm bar − terminal bar", na(latestConfirmDelayStatus) ? "n/a" : str.tostring(latestConfirmDelayStatus))
            f_statusCell(statusTable, 7, "Terminal→confirm bars", na(latestConfirmDelayStatus) ? "n/a" : str.tostring(latestConfirmDelayStatus) + " bars")
            f_statusCell(statusTable, 8, "Average terminal→confirm bars", na(averageConfirmDelay) ? "n/a" : str.tostring(averageConfirmDelay, "#.00") + " bars")
            f_statusCell(statusTable, 9, "Maximum terminal→confirm bars", confirmedSignalCount > 0 ? str.tostring(maxConfirmDelay) + " bars" : "n/a")
            f_statusCell(statusTable, 10, latestSignalText + " terminal→confirm move", f_fmtPct(latestMoveBeforeConfirm))
            f_statusCell(statusTable, 11, "Confirm-bar reversal from terminal", f_fmtPct(latestSignalReversalPct))
            f_statusCell(statusTable, 12, "Last terminal→terminal duration", na(latestTerminalCycleBars) ? "n/a" : str.tostring(latestTerminalCycleBars) + " bars")
            f_statusCell(statusTable, 13, "Last confirm→confirm duration", na(latestCausalCycleBars) ? "n/a" : str.tostring(latestCausalCycleBars) + " bars")
            f_statusCell(statusTable, 14, "Current leg", currentLegText)

        else
            f_statusCell(statusTable, 1, "Extreme source", "CONFIRMED LEG FLIP")
            f_statusCell(statusTable, 2, "UP → DOWN", "CLOSE < PRIOR N-BAR LOW")
            f_statusCell(statusTable, 3, "DOWN → UP", "CLOSE > PRIOR N-BAR HIGH")
            f_statusCell(statusTable, 4, "Flip Confirm Bars", "PRIOR STRUCTURE WINDOW")
            f_statusCell(statusTable, 5, "Reversal filter", "TERMINAL → CONFIRM MOVE %")
            f_statusCell(statusTable, 6, "TROUGH terminal", "RETAINED DOWN-LEG LOW")
            f_statusCell(statusTable, 7, "PEAK terminal", "RETAINED UP-LEG HIGH")
            f_statusCell(statusTable, 8, "Directional result", "POSITIVE = FAVORABLE MOVE")
            f_statusCell(statusTable, 9, "Current-result price", "LIVE CHART PRICE")
            f_statusCell(statusTable, 10, "Unconfirmed context", "SUPERSEDED / FILTERED")
            f_statusCell(statusTable, 11, "Hold path", "TERMINAL → TERMINAL")
            f_statusCell(statusTable, 12, "Use", "ANALYSIS • NOT TRADE SYSTEM")
            f_statusCell(statusTable, 13, "Extreme mode", "CAUSAL CONFIRMED-BAR")
            f_statusCell(statusTable, 14, "Alerts", "CONFIRMED PEAK / TROUGH")
````
