# Liquidity Cartography [JOAT]

- url: https://www.tradingview.com/script/x83ZeugE-Liquidity-Cartography-JOAT/
- type: indicator
- pine_id: PUB;5340ba5d157c4ec09d83e390ad8b471a
- version: 1.0

## Description

[b]JOAT Liquidity Cartography [JOAT][/b]

[b]Introduction[/b]

JOAT Liquidity Cartography is an open-source liquidity mapping overlay built to organize where price has swept obvious pools, where imbalance still exists, and where repricing blocks remain active.

It combines prior-day and prior-week references, equal-high and equal-low clustering, sweep-state persistence, displacement logic, imbalance arrays, repricing block arrays, and confluence scoring.

The problem it solves is fragmented liquidity analysis.

Many traders watch prior highs and lows separately from fair value gaps, separately from equal highs and lows, and separately from displacement.

This script turns those references into one coordinated chart map.

That makes it easier to judge whether the market is merely tapping a level, actually sweeping it, or accepting away from it with structure and participation.

The script is useful because it tracks the sequence, not just the level.

A prior-day low by itself is only a reference.

A sweep below it is more informative.

A sweep followed by displacement and structure recovery is a different condition again.

Liquidity Cartography is built around those transitions.

The box system is managed over time.

Zones are extended, aged, and deleted when invalidated or expired.

That keeps the chart focused on currently relevant liquidity rather than permanent drawings.

[image]https://www.tradingview.com/x/Kn5OvERi/[/image]

[b]Core Concepts[/b]

[b]1. Daily and Weekly Reference Liquidity[/b]

The script tracks PDH, PDL, PWH, and PWL.

These are the major reference pools used to judge whether price is probing obvious liquidity.

[pine]
[priorDayHigh, priorDayLow] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[priorWeekHigh, priorWeekLow] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[/pine]

[b]2. Equal-High and Equal-Low Tracking[/b]

Confirmed pivots are compared in ATR terms to identify clustered highs and lows.

[b]3. Sweep-State Persistence[/b]

Sweeps remain active for a configurable confirmation window.

That allows follow-through logic to validate the narrative.

[b]4. Displacement Validation[/b]

The script checks whether the reaction away from a pool is meaningful through body expansion and gap behavior.

[b]5. Imbalance Management[/b]

Imbalance zones are stored and extended as long as they remain active.

[b]6. Repricing Block Management[/b]

Order-block style repricing areas are created after structural breaks and managed over time.

[b]7. Filter Stack[/b]

Trend, RVOL, RSI, and session filters can refine signal quality.

[b]8. Confluence Scoring[/b]

The indicator counts alignment across the active liquidity narrative.

[b]Features[/b]

[list]
[*][b]Prior-day and prior-week levels:[/b] major reference pools are tracked
[*][b]Equilibrium levels:[/b] daily and weekly range centers are shown
[*][b]Equal-high / equal-low detection:[/b] clustered pools are identified
[*][b]Sweep persistence:[/b] active sweep context remains available for confirmation
[*][b]Displacement checks:[/b] strong rejection is separated from weak noise
[*][b]Imbalance boxes:[/b] active FVG-style zones extend until mitigation or expiry
[*][b]Repricing blocks:[/b] revisit zones are stored and managed
[*][b]Filter stack:[/b] trend, RVOL, RSI, and session alignment are available
[*][b]Confluence scoring:[/b] current liquidity alignment is summarized
[*][b]Dashboard:[/b] active pool, trend, confluence, and signal state are displayed
[/list]

[b]Input Parameters[/b]

[b]Reference Levels:[/b]

[list]
[*]Show Prior Day Levels
[*]Show Prior Week Levels
[*]Show Equilibrium
[*]Track Weekly Sweeps
[/list]

[b]Sweep / Zone Logic:[/b]

[list]
[*]Structure Length
[*]Sweep Reset Bars
[*]Zone Extension
[*]Equal Pool Tolerance ATR
[*]Zone Max Age
[*]History Limits
[/list]

[b]Validation:[/b]

[list]
[*]Require Displacement
[*]Displacement Multiplier
[*]Use Trend Filter
[*]Use RVOL Filter
[*]Use RSI Filter
[*]Use Session Filter
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Identify the active daily or weekly liquidity pool.

[b]Step 2:[/b] Check whether price only touched the pool or actually swept it.

[b]Step 3:[/b] Look for displacement and structure response after the sweep.

[b]Step 4:[/b] Watch active imbalances and repricing blocks for later revisits.

[b]Step 5:[/b] Use the confluence count to separate weak narratives from stronger ones.

[b]Indicator Limitations[/b]

[list]
[*]Obvious liquidity pools can be tapped or swept multiple times before direction resolves
[*]Object-heavy overlays may appear dense on low timeframes if many zones remain active
[*]Pivot-based pool detection confirms after the swing completes, which is intentional non-repainting behavior
[*]Zones are analytical references, not guarantees of reversal or continuation
[/list]

[b]Originality Statement[/b]

This script is original in how it combines sweep persistence, equal-pool detection, imbalance inventory, repricing blocks, and confluence scoring into one coordinated liquidity framework.

The components are integrated because they all describe the same process:

price probing liquidity, taking it, and either failing or accepting beyond it.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only.

It is not financial advice.

Liquidity reactions can fail.

Sweeps can repeat.

No level or zone guarantees a directional outcome.

Always use independent judgment and risk management.

[b]Best Use Cases[/b]

[list]
[*]Mapping where obvious daily and weekly liquidity is likely resting
[*]Studying how price behaves after a confirmed sweep
[*]Tracking whether displacement and imbalance support the sweep narrative
[*]Marking revisit zones after structural repricing
[/list]

[b]Interpretation Notes[/b]

A sweep by itself is only the beginning of the story.

The more useful sequence is sweep, displacement, structural response, and active zone support.

Equal-high and equal-low references are helpful because they often identify where liquidity may accumulate before the sweep occurs.

The confluence score should be interpreted as a narrative-strength read, not a promise of reversal.

[b]Publication Notes[/b]

This script is intended to be published with a clean chart that clearly shows the active liquidity pool, the current sweep state, and one or two relevant active zones.

Do not overload the publication chart with unrelated drawings.

The value of the visual example should come from clarity rather than chart decoration.

-Made with passion by jackofalltrades

[b]Chart Reading Framework[/b]

[b]1.[/b] Start with the active daily or weekly pool.

[b]2.[/b] Determine whether price only touched or truly swept the pool.

[b]3.[/b] Check displacement, break state, and confluence.

[b]4.[/b] Review active imbalances and repricing blocks for the next revisit path.

[b]5.[/b] Use the dashboard to verify whether the liquidity narrative is strengthening or fading.

[b]Why This Matters[/b]

Liquidity logic becomes much more useful when it is organized as a process instead of a list of disconnected levels.

This indicator is meant to help the user see that process clearly.

[b]Open-Source Notes[/b]

This script is published open source so users can inspect how sweep persistence, imbalance management, and zone aging are handled.

[b]Who This Is For[/b]

This indicator is for traders who want a structured liquidity map rather than isolated levels.

It is especially useful for users who think in terms of sweeps, repricing, and revisit zones.

[b]Summary[/b]

JOAT Liquidity Cartography turns scattered liquidity references into one organized live framework.

Its main value is clarity.

[b]Additional Notes[/b]

The strongest use of this script comes from following the sequence of events rather than reacting to a single box or line in isolation.

Clean publication images should make that sequence obvious.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Liquidity Cartography [JOAT]", shorttitle = "LCT [JOAT]", overlay = true, max_boxes_count = 500, max_lines_count = 180, max_labels_count = 90, max_bars_back = 5000)

string groupLevels = "Reference Levels"
string groupSweep = "Sweep Logic"
string groupConfirmation = "Confirmation"
string groupDisplay = "Display"
string groupDashboard = "Dashboard"

bool showDailyLevels = input.bool(true, "Show Prior Day Levels", group = groupLevels)
bool showWeeklyLevels = input.bool(true, "Show Prior Week Levels", group = groupLevels)
bool showEquilibrium = input.bool(true, "Show Equilibrium Levels", group = groupLevels)
bool trackWeeklySweeps = input.bool(true, "Track Weekly Sweeps", group = groupLevels)
float equalPoolToleranceAtr = input.float(0.20, "Equal Pool Tolerance ATR", minval = 0.05, step = 0.01, group = groupLevels)

int swingLen = input.int(5, "Structure Length", minval = 2, group = groupSweep)
int confirmationBars = input.int(10, "Confirmation Window", minval = 1, maxval = 30, group = groupSweep)
int zoneExtension = input.int(24, "Zone Extension", minval = 4, group = groupSweep)
int zoneMaxAge = input.int(120, "Zone Max Age", minval = 20, group = groupSweep)
int boxHistoryLimit = input.int(24, "Object History", minval = 5, maxval = 80, group = groupSweep)
bool requireDisplacement = input.bool(true, "Require Displacement", group = groupConfirmation)
float displacementFactor = input.float(1.20, "Displacement Multiplier", minval = 0.5, step = 0.05, group = groupConfirmation)
bool requireFvgConfirmation = input.bool(false, "Require Imbalance Confirmation", group = groupConfirmation)
bool useTrendFilter = input.bool(true, "Use Trend Filter", group = groupConfirmation)
int trendLen = input.int(89, "Trend Baseline", minval = 10, group = groupConfirmation)
string htfTrendTf = input.timeframe("240", "HTF Trend Timeframe", group = groupConfirmation)
bool useVolumeFilter = input.bool(true, "Use RVOL Filter", group = groupConfirmation)
int volumeLen = input.int(20, "RVOL Length", minval = 5, group = groupConfirmation)
float rvolThreshold = input.float(1.15, "RVOL Threshold", minval = 0.5, step = 0.05, group = groupConfirmation)
bool useRsiFilter = input.bool(true, "Use RSI Filter", group = groupConfirmation)
int rsiLen = input.int(14, "RSI Length", minval = 2, group = groupConfirmation)
float bullRsiFloor = input.float(52.0, "Bull RSI Floor", minval = 0.0, maxval = 100.0, step = 0.5, group = groupConfirmation)
float bearRsiCeiling = input.float(48.0, "Bear RSI Ceiling", minval = 0.0, maxval = 100.0, step = 0.5, group = groupConfirmation)
bool useSessionFilter = input.bool(true, "Use Session Filter", group = groupConfirmation)
string executionSession = input.session("0930-1600", "Execution Session", group = groupConfirmation)

bool showSweepZones = input.bool(true, "Show Sweep Zones", group = groupDisplay)
bool showOrderBlocks = input.bool(true, "Show Repricing Blocks", group = groupDisplay)
bool showFvg = input.bool(true, "Show Imbalance Zones", group = groupDisplay)
bool showStateLabel = input.bool(true, "Show State Label", group = groupDisplay)
bool tintBars = input.bool(true, "Tint Bars", group = groupDisplay)
bool showBackdrop = input.bool(true, "Show Context Backdrop", group = groupDisplay)
bool showDashboard = input.bool(true, "Show Dashboard", group = groupDashboard)

color dailyHighColor = input.color(color.rgb(218, 168, 72), "Prior Day High", group = groupDisplay)
color dailyLowColor = input.color(color.rgb(76, 142, 212), "Prior Day Low", group = groupDisplay)
color weeklyHighColor = input.color(color.rgb(166, 118, 226), "Prior Week High", group = groupDisplay)
color weeklyLowColor = input.color(color.rgb(81, 192, 174), "Prior Week Low", group = groupDisplay)
color equilibriumColor = input.color(color.rgb(136, 149, 174), "Equilibrium", group = groupDisplay)
color bidSweepColor = input.color(color.rgb(29, 181, 139), "Bid Sweep Zone", group = groupDisplay)
color offerSweepColor = input.color(color.rgb(209, 82, 108), "Offer Sweep Zone", group = groupDisplay)
color bullImbalanceColor = input.color(color.rgb(90, 122, 213), "Bull Imbalance", group = groupDisplay)
color bearImbalanceColor = input.color(color.rgb(139, 95, 189), "Bear Imbalance", group = groupDisplay)
color bullBlockColor = input.color(color.rgb(44, 115, 95), "Bull Block", group = groupDisplay)
color bearBlockColor = input.color(color.rgb(144, 60, 80), "Bear Block", group = groupDisplay)
color panelBg = input.color(color.rgb(13, 18, 28), "Dashboard Background", group = groupDashboard)
color panelBorder = input.color(color.rgb(36, 50, 71), "Dashboard Border", group = groupDashboard)

f_in_session(string sessionSpec) =>
    not na(time(timeframe.period, sessionSpec))

f_non_repaint_ema(string tf, int len) =>
    request.security(syminfo.tickerid, tf, ta.ema(close, len)[1], lookahead = barmerge.lookahead_on)

f_context_text(int side) =>
    side == 1 ? "Sell-Side Capture" :
     side == -1 ? "Buy-Side Capture" :
     "Inactive"

f_signal_text(bool longSignal, bool shortSignal) =>
    longSignal ? "Long Qualified" :
     shortSignal ? "Short Qualified" :
     "Monitoring"

float atrValue = ta.atr(14)
float trendBase = ta.ema(close, trendLen)
float htfTrendBase = f_non_repaint_ema(htfTrendTf, trendLen)
float bodySize = math.abs(close - open)
float averageBody = ta.sma(bodySize, 20)
float averageVolume = ta.sma(volume, volumeLen)
float relativeVolume = averageVolume > 0 ? volume / averageVolume : 1.0
float rsiValue = ta.rsi(close, rsiLen)

[priorDayHigh, priorDayLow, priorDayClose] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
[priorWeekHigh, priorWeekLow] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)

float dayEquilibrium = (priorDayHigh + priorDayLow) * 0.5
float weekEquilibrium = (priorWeekHigh + priorWeekLow) * 0.5

float pivotHigh = ta.pivothigh(high, swingLen, swingLen)
float pivotLow = ta.pivotlow(low, swingLen, swingLen)

var float lastStructureHigh = na
var float lastStructureLow = na
var int lastStructureHighBar = na
var int lastStructureLowBar = na
var float priorStructureHigh = na
var float priorStructureLow = na
var int priorStructureHighBar = na
var int priorStructureLowBar = na
var line equalHighLine = na
var line equalLowLine = na

if not na(pivotHigh)
    if not na(lastStructureHigh)
        priorStructureHigh := lastStructureHigh
        priorStructureHighBar := lastStructureHighBar
    lastStructureHigh := pivotHigh
    lastStructureHighBar := bar_index - swingLen
    if not na(priorStructureHigh) and math.abs(lastStructureHigh - priorStructureHigh) <= atrValue * equalPoolToleranceAtr
        if na(equalHighLine)
            equalHighLine := line.new(priorStructureHighBar, priorStructureHigh, lastStructureHighBar, lastStructureHigh, color = color.new(weeklyHighColor, 10), width = 2, extend = extend.right)
        else
            line.set_xy1(equalHighLine, priorStructureHighBar, priorStructureHigh)
            line.set_xy2(equalHighLine, lastStructureHighBar, lastStructureHigh)
            line.set_extend(equalHighLine, extend.right)
            line.set_color(equalHighLine, color.new(weeklyHighColor, 10))

if not na(pivotLow)
    if not na(lastStructureLow)
        priorStructureLow := lastStructureLow
        priorStructureLowBar := lastStructureLowBar
    lastStructureLow := pivotLow
    lastStructureLowBar := bar_index - swingLen
    if not na(priorStructureLow) and math.abs(lastStructureLow - priorStructureLow) <= atrValue * equalPoolToleranceAtr
        if na(equalLowLine)
            equalLowLine := line.new(priorStructureLowBar, priorStructureLow, lastStructureLowBar, lastStructureLow, color = color.new(weeklyLowColor, 10), width = 2, extend = extend.right)
        else
            line.set_xy1(equalLowLine, priorStructureLowBar, priorStructureLow)
            line.set_xy2(equalLowLine, lastStructureLowBar, lastStructureLow)
            line.set_extend(equalLowLine, extend.right)
            line.set_color(equalLowLine, color.new(weeklyLowColor, 10))

bool bullishBreak = not na(lastStructureHigh) and close > lastStructureHigh and close[1] <= lastStructureHigh
bool bearishBreak = not na(lastStructureLow) and close < lastStructureLow and close[1] >= lastStructureLow

bool bullTrend = close > trendBase and close > htfTrendBase
bool bearTrend = close < trendBase and close < htfTrendBase
bool displacementUp = close > open and bodySize > averageBody * displacementFactor
bool displacementDown = close < open and bodySize > averageBody * displacementFactor
bool gapUp = low > high[1]
bool gapDown = high < low[1]
bool bullDisplacementValid = displacementUp or gapUp
bool bearDisplacementValid = displacementDown or gapDown
bool sessionAllowed = not useSessionFilter or f_in_session(executionSession)
bool bullRsi = rsiValue >= bullRsiFloor
bool bearRsi = rsiValue <= bearRsiCeiling

bool dayUpperSweep = showDailyLevels and not na(priorDayHigh) and high > priorDayHigh and close < priorDayHigh
bool dayLowerSweep = showDailyLevels and not na(priorDayLow) and low < priorDayLow and close > priorDayLow
bool weekUpperSweep = trackWeeklySweeps and showWeeklyLevels and not na(priorWeekHigh) and high > priorWeekHigh and close < priorWeekHigh
bool weekLowerSweep = trackWeeklySweeps and showWeeklyLevels and not na(priorWeekLow) and low < priorWeekLow and close > priorWeekLow

var int activeSweepSide = 0
var float activeSweepLevel = na
var float activeSweepExtreme = na
var int activeSweepBar = na
var string activeSweepReference = ""

var array<box> sweepBoxes = array.new_box()
var array<int> sweepSides = array.new_int()
var array<int> sweepBirthBars = array.new_int()

var array<box> imbalanceBoxes = array.new_box()
var array<int> imbalanceSides = array.new_int()
var array<int> imbalanceBirthBars = array.new_int()

var array<box> blockBoxes = array.new_box()
var array<int> blockSides = array.new_int()
var array<int> blockBirthBars = array.new_int()

create_sweep_zone(int side, float topPrice, float bottomPrice) =>
    if showSweepZones
        color zoneColor = side == 1 ? bidSweepColor : offerSweepColor
        box zone = box.new(bar_index - 1, topPrice, bar_index + zoneExtension, bottomPrice, border_color = color.new(zoneColor, 0), bgcolor = color.new(zoneColor, 83))
        array.push(sweepBoxes, zone)
        array.push(sweepSides, side)
        array.push(sweepBirthBars, bar_index)
        if array.size(sweepBoxes) > boxHistoryLimit
            box.delete(array.shift(sweepBoxes))
            array.shift(sweepSides)
            array.shift(sweepBirthBars)

create_imbalance(int side, float topPrice, float bottomPrice) =>
    if showFvg
        color zoneColor = side == 1 ? bullImbalanceColor : bearImbalanceColor
        box zone = box.new(bar_index - 2, topPrice, bar_index + zoneExtension, bottomPrice, border_color = color.new(zoneColor, 0), bgcolor = color.new(zoneColor, 86))
        array.push(imbalanceBoxes, zone)
        array.push(imbalanceSides, side)
        array.push(imbalanceBirthBars, bar_index)
        if array.size(imbalanceBoxes) > boxHistoryLimit
            box.delete(array.shift(imbalanceBoxes))
            array.shift(imbalanceSides)
            array.shift(imbalanceBirthBars)

create_block(int side, int sourceOffset) =>
    if showOrderBlocks and sourceOffset <= bar_index
        float topPrice = high[sourceOffset]
        float bottomPrice = low[sourceOffset]
        color zoneColor = side == 1 ? bullBlockColor : bearBlockColor
        box zone = box.new(bar_index - sourceOffset, topPrice, bar_index + zoneExtension, bottomPrice, border_color = color.new(zoneColor, 0), bgcolor = color.new(zoneColor, 85))
        array.push(blockBoxes, zone)
        array.push(blockSides, side)
        array.push(blockBirthBars, bar_index)
        if array.size(blockBoxes) > boxHistoryLimit
            box.delete(array.shift(blockBoxes))
            array.shift(blockSides)
            array.shift(blockBirthBars)

if barstate.isconfirmed and (dayUpperSweep or weekUpperSweep or dayLowerSweep or weekLowerSweep)
    int newSweepSide = dayLowerSweep or weekLowerSweep ? 1 : -1
    float newSweepLevel = dayLowerSweep ? priorDayLow : weekLowerSweep ? priorWeekLow : dayUpperSweep ? priorDayHigh : priorWeekHigh
    float newSweepExtreme = newSweepSide == 1 ? low : high
    string newSweepReference = dayLowerSweep ? "PDL" : weekLowerSweep ? "PWL" : dayUpperSweep ? "PDH" : "PWH"
    activeSweepSide := newSweepSide
    activeSweepLevel := newSweepLevel
    activeSweepExtreme := newSweepExtreme
    activeSweepBar := bar_index
    activeSweepReference := newSweepReference
    float zoneTop = newSweepSide == 1 ? newSweepLevel : newSweepExtreme
    float zoneBottom = newSweepSide == 1 ? newSweepExtreme : newSweepLevel
    create_sweep_zone(newSweepSide, zoneTop, zoneBottom)

bool activeSweepValid = not na(activeSweepBar) and bar_index - activeSweepBar <= confirmationBars
if not activeSweepValid and activeSweepSide != 0
    activeSweepSide := 0
    activeSweepLevel := na
    activeSweepExtreme := na
    activeSweepBar := na
    activeSweepReference := ""

bool bullishImbalance = low > high[2]
bool bearishImbalance = high < low[2]

if bullishImbalance and barstate.isconfirmed and (activeSweepSide == 1 or bullishBreak)
    create_imbalance(1, low, high[2])
if bearishImbalance and barstate.isconfirmed and (activeSweepSide == -1 or bearishBreak)
    create_imbalance(-1, low[2], high)

if bullishBreak and barstate.isconfirmed
    int bullSourceOffset = 1
    for i = 1 to 6
        if close[i] < open[i]
            bullSourceOffset := i
            break
    create_block(1, bullSourceOffset)

if bearishBreak and barstate.isconfirmed
    int bearSourceOffset = 1
    for i = 1 to 6
        if close[i] > open[i]
            bearSourceOffset := i
            break
    create_block(-1, bearSourceOffset)

int bullImbalanceCount = 0
int bearImbalanceCount = 0
if array.size(imbalanceBoxes) > 0
    int i = array.size(imbalanceBoxes) - 1
    while i >= 0
        box currentBox = array.get(imbalanceBoxes, i)
        int side = array.get(imbalanceSides, i)
        int bornBar = array.get(imbalanceBirthBars, i)
        box.set_right(currentBox, bar_index + zoneExtension)
        float topValue = box.get_top(currentBox)
        float bottomValue = box.get_bottom(currentBox)
        bool mitigated = side == 1 ? low <= bottomValue : high >= topValue
        bool expired = bar_index - bornBar > zoneMaxAge
        if mitigated or expired
            box.delete(currentBox)
            array.remove(imbalanceBoxes, i)
            array.remove(imbalanceSides, i)
            array.remove(imbalanceBirthBars, i)
        else
            bullImbalanceCount += side == 1 ? 1 : 0
            bearImbalanceCount += side == -1 ? 1 : 0
        i -= 1

int bullBlockCount = 0
int bearBlockCount = 0
if array.size(blockBoxes) > 0
    int i = array.size(blockBoxes) - 1
    while i >= 0
        box currentBlock = array.get(blockBoxes, i)
        int side = array.get(blockSides, i)
        int bornBar = array.get(blockBirthBars, i)
        box.set_right(currentBlock, bar_index + zoneExtension)
        float blockTop = box.get_top(currentBlock)
        float blockBottom = box.get_bottom(currentBlock)
        bool invalidated = side == 1 ? close < blockBottom : close > blockTop
        bool expired = bar_index - bornBar > zoneMaxAge
        if invalidated or expired
            box.delete(currentBlock)
            array.remove(blockBoxes, i)
            array.remove(blockSides, i)
            array.remove(blockBirthBars, i)
        else
            bullBlockCount += side == 1 ? 1 : 0
            bearBlockCount += side == -1 ? 1 : 0
        i -= 1

int bullSweepCount = 0
int bearSweepCount = 0
if array.size(sweepBoxes) > 0
    int i = array.size(sweepBoxes) - 1
    while i >= 0
        box currentZone = array.get(sweepBoxes, i)
        int side = array.get(sweepSides, i)
        int bornBar = array.get(sweepBirthBars, i)
        box.set_right(currentZone, bar_index + zoneExtension)
        float zoneTop = box.get_top(currentZone)
        float zoneBottom = box.get_bottom(currentZone)
        bool invalidated = side == 1 ? close < zoneBottom : close > zoneTop
        bool expired = bar_index - bornBar > zoneMaxAge
        if invalidated or expired
            box.delete(currentZone)
            array.remove(sweepBoxes, i)
            array.remove(sweepSides, i)
            array.remove(sweepBirthBars, i)
        else
            bullSweepCount += side == 1 ? 1 : 0
            bearSweepCount += side == -1 ? 1 : 0
        i -= 1

bool bullImbalanceActive = bullImbalanceCount > 0
bool bearImbalanceActive = bearImbalanceCount > 0
bool bullBlockActive = bullBlockCount > 0
bool bearBlockActive = bearBlockCount > 0

bool longFiltersPass = (not requireDisplacement or bullDisplacementValid) and (not useTrendFilter or bullTrend) and (not useVolumeFilter or relativeVolume >= rvolThreshold) and (not useRsiFilter or bullRsi) and sessionAllowed and (not requireFvgConfirmation or bullImbalanceActive)
bool shortFiltersPass = (not requireDisplacement or bearDisplacementValid) and (not useTrendFilter or bearTrend) and (not useVolumeFilter or relativeVolume >= rvolThreshold) and (not useRsiFilter or bearRsi) and sessionAllowed and (not requireFvgConfirmation or bearImbalanceActive)

bool longQualified = activeSweepSide == 1 and activeSweepValid and bullishBreak and longFiltersPass
bool shortQualified = activeSweepSide == -1 and activeSweepValid and bearishBreak and shortFiltersPass

int longConfluence = 0
longConfluence += activeSweepSide == 1 ? 1 : 0
longConfluence += activeSweepValid ? 1 : 0
longConfluence += bullishBreak ? 1 : 0
longConfluence += bullDisplacementValid ? 1 : 0
longConfluence += bullTrend ? 1 : 0
longConfluence += relativeVolume >= rvolThreshold ? 1 : 0
longConfluence += bullRsi ? 1 : 0
longConfluence += bullImbalanceActive ? 1 : 0

int shortConfluence = 0
shortConfluence += activeSweepSide == -1 ? 1 : 0
shortConfluence += activeSweepValid ? 1 : 0
shortConfluence += bearishBreak ? 1 : 0
shortConfluence += bearDisplacementValid ? 1 : 0
shortConfluence += bearTrend ? 1 : 0
shortConfluence += relativeVolume >= rvolThreshold ? 1 : 0
shortConfluence += bearRsi ? 1 : 0
shortConfluence += bearImbalanceActive ? 1 : 0

string activeReferenceText = activeSweepSide == 0 ? "None" : activeSweepReference + " | " + f_context_text(activeSweepSide)
color signalTone = longQualified ? bidSweepColor : shortQualified ? offerSweepColor : activeSweepSide == 1 ? color.new(bidSweepColor, 30) : activeSweepSide == -1 ? color.new(offerSweepColor, 30) : na
color backdropTone = not showBackdrop ? na : activeSweepSide == 1 ? color.new(bidSweepColor, 94) : activeSweepSide == -1 ? color.new(offerSweepColor, 94) : na

plotDayHigh = plot(showDailyLevels ? priorDayHigh : na, "Prior Day High", color = color.new(dailyHighColor, 10), linewidth = 2, style = plot.style_linebr)
plotDayLow = plot(showDailyLevels ? priorDayLow : na, "Prior Day Low", color = color.new(dailyLowColor, 10), linewidth = 2, style = plot.style_linebr)
fill(plotDayHigh, plotDayLow, color.new(color.rgb(71, 90, 120), 94), title = "Daily Range Fill")

plotWeekHigh = plot(showWeeklyLevels ? priorWeekHigh : na, "Prior Week High", color = color.new(weeklyHighColor, 18), linewidth = 2, style = plot.style_linebr)
plotWeekLow = plot(showWeeklyLevels ? priorWeekLow : na, "Prior Week Low", color = color.new(weeklyLowColor, 18), linewidth = 2, style = plot.style_linebr)
fill(plotWeekHigh, plotWeekLow, color.new(color.rgb(70, 58, 96), 96), title = "Weekly Range Fill")

plot(showEquilibrium and showDailyLevels ? dayEquilibrium : na, "Day Equilibrium", color = color.new(equilibriumColor, 35), linewidth = 1, style = plot.style_linebr)
plot(showEquilibrium and showWeeklyLevels ? weekEquilibrium : na, "Week Equilibrium", color = color.new(equilibriumColor, 55), linewidth = 1, style = plot.style_linebr)
plot(trendBase, "Trend Baseline", color = color.new(activeSweepSide == 1 ? bidSweepColor : activeSweepSide == -1 ? offerSweepColor : equilibriumColor, 30), linewidth = 2)

barcolor(tintBars ? signalTone : na)
bgcolor(backdropTone)

var label stateLabel = na
if showStateLabel and barstate.islast
    if na(stateLabel)
        stateLabel := label.new(bar_index, high, "", style = label.style_label_left, color = color.new(panelBg, 10), textcolor = color.white)
    float labelY = high + atrValue * 0.9
    string stateText = activeReferenceText + " | " + f_signal_text(longQualified, shortQualified)
    label.set_xy(stateLabel, bar_index, labelY)
    label.set_text(stateLabel, stateText)
    label.set_color(stateLabel, color.new(longQualified ? bidSweepColor : shortQualified ? offerSweepColor : equilibriumColor, 72))
    label.set_textcolor(stateLabel, color.white)

var table dash = table.new(position.top_right, 2, 9, bgcolor = color.new(panelBg, 8), frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Cartography", text_color = color.rgb(160, 172, 191), bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dash, 1, 0, "State", text_color = color.rgb(160, 172, 191), bgcolor = color.new(panelBg, 0), text_size = size.normal)

    table.cell(dash, 0, 1, "Active Pool", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 1, activeReferenceText, text_color = activeSweepSide == 1 ? bidSweepColor : activeSweepSide == -1 ? offerSweepColor : equilibriumColor, text_size = size.normal)

    table.cell(dash, 0, 2, "Break State", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 2, bullishBreak ? "Bull Break" : bearishBreak ? "Bear Break" : "Contained", text_color = bullishBreak ? bidSweepColor : bearishBreak ? offerSweepColor : equilibriumColor, text_size = size.normal)

    table.cell(dash, 0, 3, "Trend", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 3, bullTrend ? "Aligned Up" : bearTrend ? "Aligned Down" : "Balanced", text_color = bullTrend ? bidSweepColor : bearTrend ? offerSweepColor : equilibriumColor, text_size = size.normal)

    table.cell(dash, 0, 4, "RVOL / RSI", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 4, str.tostring(relativeVolume, "#.00") + " / " + str.tostring(rsiValue, "#.0"), text_color = relativeVolume >= rvolThreshold ? color.rgb(236, 189, 88) : equilibriumColor, text_size = size.normal)

    table.cell(dash, 0, 5, "Imbalance", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 5, str.tostring(bullImbalanceCount) + " / " + str.tostring(bearImbalanceCount), text_color = bullImbalanceActive ? bidSweepColor : bearImbalanceActive ? offerSweepColor : equilibriumColor, text_size = size.normal)

    table.cell(dash, 0, 6, "Blocks", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 6, str.tostring(bullBlockCount) + " / " + str.tostring(bearBlockCount), text_color = bullBlockActive ? bidSweepColor : bearBlockActive ? offerSweepColor : equilibriumColor, text_size = size.normal)

    table.cell(dash, 0, 7, "Confluence", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 7, str.tostring(longConfluence) + " / " + str.tostring(shortConfluence), text_color = longConfluence >= shortConfluence ? bidSweepColor : offerSweepColor, text_size = size.normal)

    table.cell(dash, 0, 8, "Signal", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 8, f_signal_text(longQualified, shortQualified), text_color = longQualified ? bidSweepColor : shortQualified ? offerSweepColor : equilibriumColor, text_size = size.normal)

bool longSignalConfirmed = barstate.isconfirmed and longQualified
bool shortSignalConfirmed = barstate.isconfirmed and shortQualified
bool buySideSweepConfirmed = barstate.isconfirmed and (dayUpperSweep or weekUpperSweep)
bool sellSideSweepConfirmed = barstate.isconfirmed and (dayLowerSweep or weekLowerSweep)

alertcondition(longSignalConfirmed, "Cartography Long Qualification", "JOAT Liquidity Cartography long qualification confirmed on {{ticker}}")
alertcondition(shortSignalConfirmed, "Cartography Short Qualification", "JOAT Liquidity Cartography short qualification confirmed on {{ticker}}")
alertcondition(buySideSweepConfirmed, "Cartography Buy-Side Sweep", "JOAT Liquidity Cartography buy-side sweep confirmed on {{ticker}}")
alertcondition(sellSideSweepConfirmed, "Cartography Sell-Side Sweep", "JOAT Liquidity Cartography sell-side sweep confirmed on {{ticker}}")

plot(relativeVolume, "Relative Volume", color = color.new(color.white, 100), display = display.data_window)
plot(rsiValue, "RSI", color = color.new(color.white, 100), display = display.data_window)
plot(activeSweepSide, "Active Sweep Side", color = color.new(color.white, 100), display = display.data_window)
plot(longConfluence, "Long Confluence", color = color.new(color.white, 100), display = display.data_window)
plot(shortConfluence, "Short Confluence", color = color.new(color.white, 100), display = display.data_window)
plot(priorDayClose, "Prior Day Close", color = color.new(color.white, 100), display = display.data_window)
````
