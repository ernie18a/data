# Multi-Timeframe Break of Structure Engine

- url: https://www.tradingview.com/script/3TmsqEfd-Multi-Timeframe-Break-of-Structure-Engine/
- type: indicator
- pine_id: PUB;87d52ebbdbb44d7e9a95977a9715b01d
- version: 1.0

## Description

Multi-Timeframe Break of Structure Engine is a confluence-based structure tool that detects break-of-structure events on an execution timeframe, then filters those events through two higher-timeframe trend layers before signaling.

This script is designed for traders who want structure events in context, rather than isolated break signals.

[b]What this script does[/b]

The script has four connected jobs:

1. Detects bullish and bearish break-of-structure events on a chosen structure timeframe.
2. Validates directional context with two higher-timeframe filters.
3. Tracks the active BOS level and monitors first retest behavior.
4. Emits separate event classes for raw structure events and fully aligned confluence signals.

The practical goal is to reduce low-context entries and keep the chart focused on structure levels that still matter.

[b]How the model is built[/b]

The logic is based on three directional layers plus state management:

1. [b]Macro Layer 1[/b]
This is the highest trend layer (default Daily). It uses a fast/slow moving-average relationship to define broad directional bias.

2. [b]Macro Layer 2[/b]
This is an intermediate confirmation layer (default 4H). It combines fast/slow MA direction with close relative to a short MA, so intermediate momentum must also agree with bias.

3. [b]Structure Layer[/b]
This is the execution layer (default 15m). BOS events are detected from structure-timeframe closes relative to prior structure swing references.

A BOS event becomes an aligned signal only when all three layers agree with its direction.

[b]Core BOS logic[/b]

Bullish BOS logic:
https://www.tradingview.com/x/xlBRR4uf/
- Structure close breaks above prior structure swing reference.
- Optional strength filter can require the break candle body to be larger than average by a multiplier.
- Macro and structure layers are evaluated for directional agreement.

Bearish BOS logic:
https://www.tradingview.com/x/yTRrQfBd/
- Structure close breaks below prior structure swing reference.
- Optional strength filter works symmetrically.
- Macro and structure layers are evaluated for directional agreement.

The script evaluates BOS events on structure-bar transitions, which helps avoid repeated triggers from lower-timeframe bar noise during a single structure candle.

[b]Retest logic[/b]

After a BOS level is created, the script tracks one active BOS level and evaluates first retest conditions.

Two retest modes are available:

1. Wick Touch
Retest requires direct contact with the BOS level and directional close behavior.

2. ATR Proximity
Retest can qualify within a volatility-adjusted distance from the level using structure-timeframe ATR and a user-defined multiplier.

This dual mode is useful because low-volatility instruments often respect precise touches, while high-volatility instruments may react near a level without exact contact.

[b]Validity window behavior[/b]

The optional validity window expires BOS levels that remain unretested for too long.

If enabled, validity duration is measured in structure bars. This keeps the level lifecycle aligned with the same timeframe where BOS is detected, rather than chart bars that may be faster or slower than the structure context.

[b]Why this script can be useful[/b]

The script is not a single trigger line. It combines:
- directional context from higher timeframes,
- structure break detection on execution timeframe,
- persistent level tracking,
- retest qualification,
- optional expiration logic.

This interaction is intended to reduce low-quality breakout noise and keep attention on structure events that are still contextually relevant.

[b]What is plotted[/b]

1. Optional MA overlays
- Structure fast and slow MA.
- Macro 1 fast and slow MA.
- Macro 2 price/fast/slow MA.

2. Signal markers
- BOS long/short markers for aligned BOS.
- Retest long/short markers for aligned retests.

3. Active BOS level line
- Horizontal level extends until retest or replacement by a new BOS event.
- Optional right-side BOS price label.

4. Optional alignment dashboard
- Macro 1 state.
- Macro 2 state.
- Structure state.
- Final alignment state.

[b]How to use it in a practical workflow[/b]

Example workflow:

1. Set structure timeframe for execution rhythm
Scalping-style execution usually uses lower structure values.
Intraday continuation often uses moderate structure values.
Swing continuation uses higher structure values.

2. Keep higher-timeframe context logical
A common approach is Macro 1 above Macro 2 above Structure so each layer has a distinct role.

3. Wait for alignment first
Use alignment as context. Do not treat any single output in isolation.

4. Use BOS as setup creation
A new BOS indicates potential directional continuation under confluence.

5. Use retest as conditional confirmation
Retest can help refine entries after initial break.

6. Manage invalidation separately
The script does not replace personal risk management, stop placement, or position sizing.

[b]Input groups and what they control[/b]

Structure Timeframe Settings
- Structure Timeframe: execution structure context.
- Structure MA Type: EMA or SMA for structure trend.
- Structure Fast/Slow Lengths: structure trend sensitivity.

Macro Layer 1 Settings
- Macro 1 Timeframe: broad trend context.
- Macro 1 Fast/Slow Lengths: sensitivity of broad trend filter.
- Macro 1 MA Type: EMA or SMA behavior choice.

Macro Layer 2 Settings
- Macro 2 Timeframe: intermediate filter.
- Macro 2 Fast/Slow Lengths: trend filter sensitivity.
- Macro 2 Price MA Length: participation filter via close relative to short MA.
- Macro 2 MA Type: EMA or SMA behavior choice.

Candle Close Confirmation
- Wait for candle close: event gating behavior on chart bars.

BOS Advanced Filters
- Enable BOS validity window: controls expiration behavior.
- BOS validity (structure bars): expiration duration.
- Enable BOS strength filter: optional quality threshold on break candle body.
- Min body size multiplier: strength threshold.
- Show BOS labels: level label visibility.
- Max stored BOS lines: line object management limit.

Retest Detection Settings
- Retest method: Wick Touch or ATR Proximity.
- ATR Period: volatility measurement period for proximity mode.
- ATR Proximity Factor: allowable near-level distance in ATR terms.

Display Options
- Show structure and macro MA overlays.
- Show dashboard table.

Colors and Labels
- Bullish and bearish display colors.
- BOS label text color.
- Label right offset.

[b]Alert architecture[/b]

The script provides alert conditions for:
- aligned BOS long/short,
- aligned retest long/short,
- alignment flips,
- raw BOS creation events,
- raw retest events,
- macro and structure trend flips.

This allows users to build different alert workflows:
- conservative workflow uses aligned BOS/retest alerts only,
- contextual workflow also monitors alignment flips,
- diagnostic workflow includes raw events for observation.

[b]Market and timeframe suitability[/b]

This script can be used on:
- crypto,
- forex,
- indices,
- equities,
- commodities.

[b]Execution styles it can support:[/b]

1. Scalping-style continuation
- Lower structure timeframe.
- Generally stricter retest conditions.
- Faster context changes and more signal frequency.

2. Intraday trend continuation
- Moderate structure timeframe.
- Typical use of both BOS and retest phases.
- Good balance between responsiveness and filtering.

3. Swing continuation
- Higher structure timeframe.
- Often benefits from ATR Proximity retest mode.
- Lower signal frequency, broader moves.

Style suitability depends on parameter choices and instrument volatility.

[b]Interpretation guidance and limitations[/b]

Important limitations:

1. This is a context and structure tool, not a profit guarantee tool.
2. Trend filters may lag near turning points.
3. Strength filters reduce noise but may skip early break phases.
4. ATR Proximity can become loose if multiplier is set too high.
5. BOS logic can still produce false continuation in choppy, mean-reverting conditions.

Because of this, risk management remains mandatory.

How this differs from a basic single-layer BOS script

This script does not only mark local breaks. It manages an interaction chain:
- structure event detection,
- multi-timeframe agreement,
- stateful BOS level tracking,
- retest qualification modes,
- level validity expiration.

The objective is cleaner structure context and better workflow discipline, not maximizing raw signal count.

[b]Responsible usage notes[/b]

- Start with default values, then adjust gradually.
- Test one variable at a time.
- Keep notes on which settings are used per market and session.
- Validate behavior in replay before using alerts live.

[b]Disclaimer[/b]

This script is an analytical support tool. It is not financial advice and does not guarantee outcomes. Trading involves risk. Users are responsible for trade selection, position sizing, and risk control.

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe Break of Structure Engine", shorttitle="BOS Engine", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────────────────────────────
// STRUCTURE TIMEFRAME SETTINGS
// ─────────────────────────────────────────────────────────────────────
groupStruct = "Structure Timeframe Settings"
structureTF = input.timeframe("15", "Structure Timeframe", group=groupStruct, tooltip="The timeframe used to detect Break of Structure events. This is your execution timeframe where swing highs and lows are identified and where breakouts are confirmed. Choose a timeframe equal to or higher than your chart timeframe. Default is 15 minutes.")
structMAType = input.string("EMA", "Structure MA Type", options=["EMA","SMA"], group=groupStruct, tooltip="The type of moving average used on the structure timeframe to determine short-term trend direction. EMA reacts faster to recent price changes. SMA gives equal weight to all bars in the lookback.")
structFastLen = input.int(16, "Structure Fast MA Length", minval=1, group=groupStruct, tooltip="Period for the fast moving average on the structure timeframe. When this MA is above the slow MA, the structure timeframe trend is considered bullish.")
structSlowLen = input.int(30, "Structure Slow MA Length", minval=1, group=groupStruct, tooltip="Period for the slow moving average on the structure timeframe. Acts as the baseline for structure trend direction.")

// ─────────────────────────────────────────────────────────────────────
// MACRO LAYER 1 — DAILY TREND
// ─────────────────────────────────────────────────────────────────────
groupMacro1 = "Macro Layer 1 - Daily Trend"
macro1TF = input.timeframe("D", "Macro 1 Timeframe", group=groupMacro1, tooltip="The highest timeframe in the system. Defines the dominant trend direction using a fast/slow MA crossover. Default is Daily. No aligned BOS signal fires unless this layer agrees.")
macro1MA1 = input.int(8, "Macro 1 Fast MA Length", minval=1, group=groupMacro1, tooltip="Fast MA period on the daily timeframe. When above the slow MA, the daily macro trend is bullish.")
macro1MA2 = input.int(12, "Macro 1 Slow MA Length", minval=1, group=groupMacro1, tooltip="Slow MA period on the daily timeframe. Provides the baseline for the daily trend filter.")
macro1Type = input.string("EMA", "Macro 1 MA Type", options=["EMA","SMA"], group=groupMacro1, tooltip="Moving average type for the daily macro layer.")

// ─────────────────────────────────────────────────────────────────────
// MACRO LAYER 2 — 4H CONFIRMATION
// ─────────────────────────────────────────────────────────────────────
groupMacro2 = "Macro Layer 2 - 4H Confirmation"
macro2TF = input.timeframe("240", "Macro 2 Timeframe", group=groupMacro2, tooltip="The intermediate timeframe layer. Provides trend confirmation between the daily macro direction and the structure execution timeframe. Default is 4H.")
macro2MA1 = input.int(16, "Macro 2 Fast MA Length", minval=1, group=groupMacro2, tooltip="Fast MA period on the 4H timeframe. Must be above the slow MA for bullish confirmation.")
macro2MA2 = input.int(30, "Macro 2 Slow MA Length", minval=1, group=groupMacro2, tooltip="Slow MA period on the 4H timeframe. Provides the trend baseline for the intermediate layer.")
macro2MA3 = input.int(8, "Macro 2 Price MA Length", minval=1, group=groupMacro2, tooltip="Short-period MA on the 4H timeframe used as a price filter. For bullish confirmation, the 4H close must be above this MA.")
macro2Type = input.string("EMA", "Macro 2 MA Type", options=["EMA","SMA"], group=groupMacro2, tooltip="Moving average type for all three MAs on the 4H intermediate layer.")

// ─────────────────────────────────────────────────────────────────────
// NON-REPAINTING CONFIRMATION
// ─────────────────────────────────────────────────────────────────────
groupConfirm = "Candle Close Confirmation"
waitClose = input.bool(true, "Wait for candle close (BOS only)", group=groupConfirm, tooltip="When enabled, BOS/retest event checks are gated to closed chart bars while still using confirmed structure-timeframe values. Recommended for live trading.")

// ─────────────────────────────────────────────────────────────────────
// BOS ADVANCED FILTERS
// ─────────────────────────────────────────────────────────────────────
groupBOS = "BOS Advanced Filters"
useValidityWindow = input.bool(false, "Enable BOS validity window", group=groupBOS, tooltip="When enabled, a BOS level expires after a set number of structure bars if no retest occurs.")
bosValidBars = input.int(12, "BOS validity (structure bars)", minval=1, group=groupBOS, tooltip="Number of structure bars after a BOS event during which the broken level remains valid for retest detection.")
useStrengthFilter = input.bool(false, "Enable BOS strength filter", group=groupBOS, tooltip="When enabled, a BOS event must be confirmed by a candle whose body size meets a minimum threshold relative to the recent average body size.")
strengthFactor = input.float(1.5, "Min body size multiplier", step=0.1, minval=0.1, group=groupBOS, tooltip="Minimum candle body size for a valid BOS as a multiple of the 20-bar average body size.")
showBosLabels = input.bool(true, "Show BOS Level Price Labels", group=groupBOS, tooltip="Displays the exact price level of the active BOS event as a floating label at the right end of the BOS line.")
maxStoredLines = input.int(250, "Max stored BOS lines", minval=50, maxval=490, group=groupBOS, tooltip="Maximum number of historical BOS lines to keep before deleting oldest lines, helping avoid line limit issues.")

// ─────────────────────────────────────────────────────────────────────
// RETEST DETECTION SETTINGS
// ─────────────────────────────────────────────────────────────────────
groupRetest = "Retest Detection Settings"
retestMode = input.string("Wick Touch", "Retest Detection Method", options=["Wick Touch", "ATR Proximity"], group=groupRetest, tooltip="Wick Touch requires price to physically touch the BOS level with its wick. ATR Proximity allows price to come within a configurable ATR-based distance of the level.")
atrRetestLen = input.int(14, "ATR Period (for proximity mode)", minval=1, group=groupRetest, tooltip="Structure-timeframe ATR lookback period used to calculate the proximity threshold in ATR Proximity mode.")
atrRetestMult = input.float(0.3, "ATR Proximity Factor", step=0.05, minval=0.05, maxval=2.0, group=groupRetest, tooltip="Multiplier applied to structure-timeframe ATR for proximity threshold.")

// ─────────────────────────────────────────────────────────────────────
// DISPLAY OPTIONS
// ─────────────────────────────────────────────────────────────────────
groupDisplay = "Display Options"
showStructMAs = input.bool(false, "Show Structure MAs", group=groupDisplay, tooltip="Display the fast and slow moving averages from the structure timeframe on the chart.")
showMacro1MAs = input.bool(false, "Show Macro 1 (Daily) MAs", group=groupDisplay, tooltip="Display the daily timeframe fast and slow moving averages on the chart.")
showMacro2MAs = input.bool(false, "Show Macro 2 (4H) MAs", group=groupDisplay, tooltip="Display the 4H timeframe MAs on the chart.")
showDash = input.bool(false, "Show Alignment Dashboard", group=groupDisplay, tooltip="Displays a compact table showing the current directional state of each timeframe layer and whether they are aligned.")

// ─────────────────────────────────────────────────────────────────────
// COLORS & LABELS
// ─────────────────────────────────────────────────────────────────────
groupColors = "Colors & Labels"
bosBullColor     = input.color(color.rgb(11, 241, 19), "BOS Bullish Color", group=groupColors, tooltip="Color used for bullish BOS lines and signals.")
bosBearColor     = input.color(color.rgb(248, 7, 7), "BOS Bearish Color", group=groupColors, tooltip="Color used for bearish BOS lines and signals.")
bosLabelColor    = input.color(color.white, "BOS Label Text Color", group=groupColors, tooltip="Color of the floating BOS label text.")
labelRightOffset = input.int(5, "Label Right Offset (bars)", minval=1, maxval=50, group=groupColors, tooltip="Distance in bars between the current bar and the floating BOS label.")

// ─────────────────────────────────────────────────────────────────────
// INTERNAL FLAGS
// ─────────────────────────────────────────────────────────────────────
useEMA1 = macro1Type == "EMA"
useEMA2 = macro2Type == "EMA"
useEMAS = structMAType == "EMA"

// Gate events once per new structure bar and optional closed chart bar confirmation.
chartConfirmed = waitClose ? barstate.isconfirmed : true

// ─────────────────────────────────────────────────────────────────────
// MACRO LAYER 1 — NON-REPAINTING HTF FETCH
// ─────────────────────────────────────────────────────────────────────
dMA_fast = request.security(syminfo.tickerid, macro1TF, (useEMA1 ? ta.ema(close, macro1MA1) : ta.sma(close, macro1MA1))[1], lookahead=barmerge.lookahead_on)
dMA_slow = request.security(syminfo.tickerid, macro1TF, (useEMA1 ? ta.ema(close, macro1MA2) : ta.sma(close, macro1MA2))[1], lookahead=barmerge.lookahead_on)
macro1Bull = dMA_fast > dMA_slow
macro1Bear = dMA_fast < dMA_slow

// ─────────────────────────────────────────────────────────────────────
// MACRO LAYER 2 — NON-REPAINTING HTF FETCH
// ─────────────────────────────────────────────────────────────────────
hMA_price = request.security(syminfo.tickerid, macro2TF, (useEMA2 ? ta.ema(close, macro2MA3) : ta.sma(close, macro2MA3))[1], lookahead=barmerge.lookahead_on)
hMA_fast  = request.security(syminfo.tickerid, macro2TF, (useEMA2 ? ta.ema(close, macro2MA1) : ta.sma(close, macro2MA1))[1], lookahead=barmerge.lookahead_on)
hMA_slow  = request.security(syminfo.tickerid, macro2TF, (useEMA2 ? ta.ema(close, macro2MA2) : ta.sma(close, macro2MA2))[1], lookahead=barmerge.lookahead_on)
hClose    = request.security(syminfo.tickerid, macro2TF, close[1], lookahead=barmerge.lookahead_on)
macro2Bull = hMA_fast > hMA_slow and hClose > hMA_price
macro2Bear = hMA_fast < hMA_slow and hClose < hMA_price

// ─────────────────────────────────────────────────────────────────────
// STRUCTURE LAYER — NON-REPAINTING HTF FETCH
// ─────────────────────────────────────────────────────────────────────
structFastMA = request.security(syminfo.tickerid, structureTF, (useEMAS ? ta.ema(close, structFastLen) : ta.sma(close, structFastLen))[1], lookahead=barmerge.lookahead_on)
structSlowMA = request.security(syminfo.tickerid, structureTF, (useEMAS ? ta.ema(close, structSlowLen) : ta.sma(close, structSlowLen))[1], lookahead=barmerge.lookahead_on)
structBull = structFastMA > structSlowMA
structBear = structFastMA < structSlowMA

srcHigh  = request.security(syminfo.tickerid, structureTF, high[1],  lookahead=barmerge.lookahead_on)
srcLow   = request.security(syminfo.tickerid, structureTF, low[1],   lookahead=barmerge.lookahead_on)
srcClose = request.security(syminfo.tickerid, structureTF, close[1], lookahead=barmerge.lookahead_on)
srcOpen  = request.security(syminfo.tickerid, structureTF, open[1],  lookahead=barmerge.lookahead_on)
srcTime  = request.security(syminfo.tickerid, structureTF, time[1],  lookahead=barmerge.lookahead_on)

// Compute change every bar first to avoid inconsistent-history warnings.
srcTimeChanged = ta.change(srcTime)
newStructBar = not na(srcTime) and srcTimeChanged != 0
eventGate = newStructBar and chartConfirmed

// Track structure bar count for structure-bar-based validity windows.
var int structBarCounter = 0
if newStructBar
    structBarCounter += 1

// ─────────────────────────────────────────────────────────────────────
// BOS DETECTION (TRUE STRUCTURE CONTEXT)
// ─────────────────────────────────────────────────────────────────────
structSwingHigh = request.security(syminfo.tickerid, structureTF, ta.highest(high[2], 5), lookahead=barmerge.lookahead_on)
structSwingLow  = request.security(syminfo.tickerid, structureTF, ta.lowest(low[2], 5), lookahead=barmerge.lookahead_on)

bodySize = math.abs(srcClose - srcOpen)
avgBodyStruct = request.security(syminfo.tickerid, structureTF, ta.sma(math.abs(close - open), 20)[1], lookahead=barmerge.lookahead_on)
strongBOS = bodySize >= avgBodyStruct * strengthFactor

rawBosHigh = eventGate and srcClose > structSwingHigh
rawBosLow  = eventGate and srcClose < structSwingLow
bosHigh = rawBosHigh and (not useStrengthFilter or strongBOS)
bosLow  = rawBosLow  and (not useStrengthFilter or strongBOS)

// ─────────────────────────────────────────────────────────────────────
// BOS LEVEL MANAGEMENT
// ─────────────────────────────────────────────────────────────────────
var float bosLevel = na
var int bosDir = 0
var int bosStructCounterAtCreate = na
var line currentBosLine = na
var bool bosRetested = false
var label activeBosLabel = na
var line[] bosLines = array.new_line()

// Structure-timeframe ATR for retest proximity.
atrValStruct = request.security(syminfo.tickerid, structureTF, ta.atr(atrRetestLen)[1], lookahead=barmerge.lookahead_on)

if bosHigh
    if not na(currentBosLine)
        line.set_x2(currentBosLine, bar_index)
        line.set_extend(currentBosLine, extend.none)

    if not na(activeBosLabel)
        label.delete(activeBosLabel)
        activeBosLabel := na

    bosLevel := structSwingHigh
    bosDir := 1
    bosStructCounterAtCreate := structBarCounter
    bosRetested := false

    currentBosLine := line.new(bar_index, bosLevel, bar_index + 1, bosLevel, color=bosBullColor, width=2, extend=extend.right)
    array.push(bosLines, currentBosLine)
    if array.size(bosLines) > maxStoredLines
        line.delete(array.shift(bosLines))

    if showBosLabels
        activeBosLabel := label.new(bar_index + labelRightOffset, bosLevel + (bosLevel * 0.0003), "BOS " + str.tostring(bosLevel, format.mintick), color=na, textcolor=bosLabelColor, style=label.style_none, size=size.small)

if bosLow
    if not na(currentBosLine)
        line.set_x2(currentBosLine, bar_index)
        line.set_extend(currentBosLine, extend.none)

    if not na(activeBosLabel)
        label.delete(activeBosLabel)
        activeBosLabel := na

    bosLevel := structSwingLow
    bosDir := -1
    bosStructCounterAtCreate := structBarCounter
    bosRetested := false

    currentBosLine := line.new(bar_index, bosLevel, bar_index + 1, bosLevel, color=bosBearColor, width=2, extend=extend.right)
    array.push(bosLines, currentBosLine)
    if array.size(bosLines) > maxStoredLines
        line.delete(array.shift(bosLines))

    if showBosLabels
        activeBosLabel := label.new(bar_index + labelRightOffset, bosLevel + (bosLevel * 0.0003), "BOS " + str.tostring(bosLevel, format.mintick), color=na, textcolor=bosLabelColor, style=label.style_none, size=size.small)

if showBosLabels and not na(activeBosLabel)
    label.set_x(activeBosLabel, bar_index + labelRightOffset)

if not showBosLabels and not na(activeBosLabel)
    label.delete(activeBosLabel)
    activeBosLabel := na

// ─────────────────────────────────────────────────────────────────────
// RETEST DETECTION (ONCE PER STRUCTURE BAR)
// ─────────────────────────────────────────────────────────────────────
bosIsValid = not na(bosLevel) and (not useValidityWindow or (structBarCounter - bosStructCounterAtCreate <= bosValidBars))

retestProximity = atrValStruct * atrRetestMult
retestLongWick  = eventGate and bosDir == 1 and not bosRetested and bosIsValid and srcLow <= bosLevel and srcClose > bosLevel
retestLongATR   = eventGate and bosDir == 1 and not bosRetested and bosIsValid and math.abs(srcLow - bosLevel) <= retestProximity and srcClose > bosLevel
retestLong      = retestMode == "Wick Touch" ? retestLongWick : retestLongATR

retestShortWick = eventGate and bosDir == -1 and not bosRetested and bosIsValid and srcHigh >= bosLevel and srcClose < bosLevel
retestShortATR  = eventGate and bosDir == -1 and not bosRetested and bosIsValid and math.abs(srcHigh - bosLevel) <= retestProximity and srcClose < bosLevel
retestShort     = retestMode == "Wick Touch" ? retestShortWick : retestShortATR

if retestLong or retestShort
    bosRetested := true
    if not na(currentBosLine)
        line.set_x2(currentBosLine, bar_index)
        line.set_extend(currentBosLine, extend.none)

// ─────────────────────────────────────────────────────────────────────
// SIGNALS (3-LAYER ALIGNMENT FILTERED)
// ─────────────────────────────────────────────────────────────────────
bosLongSignal     = bosHigh and macro1Bull and macro2Bull and structBull
bosShortSignal    = bosLow  and macro1Bear and macro2Bear and structBear
retestLongSignal  = retestLong  and macro1Bull and macro2Bull and structBull
retestShortSignal = retestShort and macro1Bear and macro2Bear and structBear

allAlignedLong  = macro1Bull and macro2Bull and structBull
allAlignedShort = macro1Bear and macro2Bear and structBear

// ─────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────
plot(showStructMAs ? structFastMA : na, title="Structure Fast MA", color=#1fff00, linewidth=1)
plot(showStructMAs ? structSlowMA : na, title="Structure Slow MA", color=#cb0000, linewidth=1)
plot(showMacro1MAs ? dMA_fast : na, title="Macro 1 Daily Fast MA", color=color.new(color.green, 40), linewidth=1)
plot(showMacro1MAs ? dMA_slow : na, title="Macro 1 Daily Slow MA", color=color.new(color.red, 40), linewidth=1)
plot(showMacro2MAs ? hMA_price : na, title="Macro 2 4H Price MA", color=color.new(#0539f7, 0), linewidth=1)
plot(showMacro2MAs ? hMA_fast : na, title="Macro 2 4H Fast MA", color=color.new(#ffffff, 60), linewidth=1)
plot(showMacro2MAs ? hMA_slow : na, title="Macro 2 4H Slow MA", color=color.new(#000000, 60), linewidth=1)

plotshape(bosLongSignal,     title="BOS Long",     style=shape.circle, location=location.belowbar, color=bosBullColor, size=size.tiny)
plotshape(bosShortSignal,    title="BOS Short",    style=shape.circle, location=location.abovebar, color=bosBearColor, size=size.tiny)
plotshape(retestLongSignal,  title="Retest Long",  style=shape.circle, location=location.belowbar, color=color.new(bosBullColor, 40), size=size.tiny)
plotshape(retestShortSignal, title="Retest Short", style=shape.circle, location=location.abovebar, color=color.new(bosBearColor, 40), size=size.tiny)

// ─────────────────────────────────────────────────────────────────────
// ALIGNMENT DASHBOARD
// ─────────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 4, border_width=1)
if showDash
    table.cell(dash, 0, 0, "Macro 1 (Daily):", text_color=#000000, bgcolor=color.white, text_size=size.small)
    table.cell(dash, 1, 0, macro1Bull ? "Bullish" : macro1Bear ? "Bearish" : "Neutral", text_color=#000000, bgcolor=macro1Bull ? bosBullColor : macro1Bear ? bosBearColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 1, "Macro 2 (4H):", text_color=#000000, bgcolor=color.white, text_size=size.small)
    table.cell(dash, 1, 1, macro2Bull ? "Bullish" : macro2Bear ? "Bearish" : "Neutral", text_color=#000000, bgcolor=macro2Bull ? bosBullColor : macro2Bear ? bosBearColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 2, "Structure:", text_color=#000000, bgcolor=color.white, text_size=size.small)
    table.cell(dash, 1, 2, structBull ? "Bullish" : structBear ? "Bearish" : "Neutral", text_color=#000000, bgcolor=structBull ? bosBullColor : structBear ? bosBearColor : color.gray, text_size=size.small)
    alignText = allAlignedLong ? "Aligned Long" : allAlignedShort ? "Aligned Short" : "No Alignment"
    alignColor = allAlignedLong ? bosBullColor : allAlignedShort ? bosBearColor : color.gray
    table.cell(dash, 0, 3, "Alignment:", text_color=#000000, bgcolor=color.white, text_size=size.small)
    table.cell(dash, 1, 3, alignText, text_color=#000000, bgcolor=alignColor, text_size=size.small)
else
    table.clear(dash, 0, 0, 1, 3)

// ─────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────
alertcondition(bosLongSignal,     title="BOS Long (Aligned)",       message="BOS Engine: Bullish BOS confirmed with full 3-layer alignment.")
alertcondition(bosShortSignal,    title="BOS Short (Aligned)",      message="BOS Engine: Bearish BOS confirmed with full 3-layer alignment.")
alertcondition(retestLongSignal,  title="Retest Long (Aligned)",    message="BOS Engine: Bullish retest confirmed with full 3-layer alignment.")
alertcondition(retestShortSignal, title="Retest Short (Aligned)",   message="BOS Engine: Bearish retest confirmed with full 3-layer alignment.")

alertcondition(allAlignedLong  and not allAlignedLong[1],  title="Multi-TF Alignment Long",  message="BOS Engine: All three layers aligned bullish.")
alertcondition(allAlignedShort and not allAlignedShort[1], title="Multi-TF Alignment Short", message="BOS Engine: All three layers aligned bearish.")

alertcondition(bosHigh, title="BOS Long Level Created", message="BOS Engine: Bullish BOS level created (unfiltered).")
alertcondition(bosLow,  title="BOS Short Level Created", message="BOS Engine: Bearish BOS level created (unfiltered).")

alertcondition(retestLong,  title="Retest Detected Long",  message="BOS Engine: Bullish BOS level retested (unfiltered).")
alertcondition(retestShort, title="Retest Detected Short", message="BOS Engine: Bearish BOS level retested (unfiltered).")

alertcondition(macro1Bull and not macro1Bull[1], title="Macro 1 Flipped Bullish", message="BOS Engine: Daily macro trend flipped bullish.")
alertcondition(macro1Bear and not macro1Bear[1], title="Macro 1 Flipped Bearish", message="BOS Engine: Daily macro trend flipped bearish.")
alertcondition(macro2Bull and not macro2Bull[1], title="Macro 2 Flipped Bullish", message="BOS Engine: 4H intermediate trend flipped bullish.")
alertcondition(macro2Bear and not macro2Bear[1], title="Macro 2 Flipped Bearish", message="BOS Engine: 4H intermediate trend flipped bearish.")
alertcondition(structBull and not structBull[1], title="Structure Flipped Bullish", message="BOS Engine: Structure timeframe trend flipped bullish.")
alertcondition(structBear and not structBear[1], title="Structure Flipped Bearish", message="BOS Engine: Structure timeframe trend flipped bearish.")
````
