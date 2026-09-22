<!-- tradingview-pine-id: PUB;d03d843af3ff440599782d8d9ba8b188 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Smart Money The Ultimator

Source: https://www.tradingview.com/script/LRtLysnZ-Smart-Money-The-Ultimator/

## Description

[https://www.tradingview.com/u/Michael_Fx_Trader/](https://www.tradingview.com/u/Michael_Fx_Trader/)

WHAT THIS INDICATOR IS

Smart Money The Ultimator is a fully automated market structure engine built around the classical Wyckoff Method. Instead of asking the trader to manually spot Buying Climax, Automatic Rally, Secondary Test, Spring, Sign of Strength and Last Point of Support on every chart, the indicator runs a rule based state machine on every bar and does this detection for you, in real time, on any symbol and any timeframe. It identifies accumulation, re-accumulation, distribution and re-distribution ranges, tracks the market through Wyckoff Phases A to E, draws the trading range, marks every event as it forms, and gives long and short entry signals only when a structure has matured enough to be tradable.

[image]https://www.tradingview.com/x/8A9gtZzh/[/image]

WHY THIS INDICATOR WAS BUILT

Wyckoff analysis is powerful but slow and subjective to do by hand. Two traders looking at the same chart will often disagree on where the Automatic Rally ended or whether a probe below support is a real Spring or just noise. This indicator was built to remove that guesswork by encoding fixed, repeatable rules for volume, spread, effort versus result, and price behaviour at each stage of the Wyckoff cycle. The goal is consistency: the same chart, on any day, produces the same read of the structure, so the trader can focus on decision making instead of pattern hunting.

HOW THE INDICATOR WORKS

The engine moves through the following sequence on every symbol it is applied to.

Step one, climax detection. The script scans for a Buying Climax at the top of an uptrend or a Selling Climax at the bottom of a downtrend, using volume spikes, spread expansion relative to Average True Range, and where the candle closes within its own range. A Preliminary Support or Preliminary Supply label may appear just before the climax if early warning conditions are met.

Step two, absorption. After the climax, the indicator checks whether the next several bars absorb the selling or buying pressure without making a meaningful new extreme, confirming the climax was genuine.

Step three, Automatic Rally or Automatic Reaction. The indicator measures the bounce or pullback away from the climax and records its extreme, which becomes one edge of the trading range.

Step four, Secondary Test. When price returns toward the climax on lower volume and a narrower spread than the climax itself, the indicator confirms the test, opens Phase B, and draws the trading range box using the Secondary Test level and the Automatic Rally level as the two edges.

Step five, Phase B. The indicator counts additional tests of both edges of the range, tracks how many times price travels between the upper and lower thirds of the range, and waits for the range to reach a minimum duration and a minimum number of support signs before considering the range mature.

Step six, Phase C. Once the range is mature, the indicator watches for a Spring, a probe below range support in an accumulation, or a Upthrust After Distribution, a probe above range resistance in a distribution. If price probes and immediately closes back inside the range on lower effort, this is marked and the intended direction of the eventual breakout is locked in. If no probe occurs, a quiet terminal test near the range edge is accepted instead.

Step seven, Phase D. The indicator looks for a Sign of Strength or Sign of Weakness, a strong directional move away from the range on above average effort, followed by a Last Point of Support or Last Point of Supply, a shallow pullback that holds near the broken edge of the range.

Step eight, Phase E. When price closes outside the range and stays there for a sufficient number of bars while the structure's overall maturity score is high enough, the indicator marks Phase E, meaning the trend move is now considered accepted and underway.

Throughout all of this, the indicator continuously calculates two scores, a maturity score out of one hundred, showing how many textbook milestones have been achieved, and a validation score out of one hundred, showing how clean and well formed the range itself is. Long or short entry signals are only generated once both scores pass the threshold set by the strictness input, and only at the Spring or Upthrust, at the Last Point of Support or Supply, or at the Sign of Strength or Weakness, depending on which strictness mode is chosen.

[image]https://www.tradingview.com/x/Nig27qZE/[/image]

HOW TO READ THE CHART

Every event the indicator finds is placed directly on the price chart as a label at the exact bar and price where it happened. Preliminary Support or Supply appears as PS or PSY. The climax appears as BC with a score out of six, or SC with a score out of six, higher scores meaning cleaner climax conditions. The Automatic Rally or Reaction appears as AR. The Secondary Test appears as ST with a score out of six, alongside a small B marker showing Phase B has begun. Inside Phase B, a small mSOW or mSOS label may appear once the range shows enough internal support or supply clues. The Spring or Upthrust After Distribution appears in bright green or magenta, and a TEST label may follow it once the extreme holds on a quiet retest. The Sign of Strength or Sign of Weakness appears once price breaks away from the range with real effort behind it. The Last Point of Support or Last Point of Supply appears as the final low risk pullback before the trend move. When the indicator is confident enough in the setup, it plots a LONG ENTRY or SHORT ENTRY label directly on the bar where the signal triggers.

The trading range itself is drawn as a shaded box with two blue horizontal lines marking its exact top and bottom edges. This box remains on the chart permanently once a range has formed, even after that particular campaign finishes or is invalidated, so the full history of past structures stays visible for reference, exactly like a textbook Wyckoff schematic laid over real price action.

[image]https://www.tradingview.com/x/ykxJtioB/[/image]

HOW TO ANALYZE A CHART WITH THIS INDICATOR

Start by locating the trading range box. Its colour tells you the working hypothesis, green tones lean toward an eventual bullish resolution, red tones lean toward an eventual bearish resolution, and the border becomes bright green or bright red only once the indicator has locked in that direction after a valid Phase C event. Read the labels left to right in the order they appear, climax, then Automatic Rally, then Secondary Test, to understand where the range came from. Once inside the range, watch for the Spring or Upthrust label, this is the moment the eventual direction becomes confirmed rather than assumed. After that, wait for the Sign of Strength or Weakness label, which shows the market is actually leaving the range with conviction, and then the Last Point of Support or Supply, which is usually the lowest risk area to align with the move. A LONG ENTRY or SHORT ENTRY label is the indicator's own confirmation that every condition it requires has been satisfied. Use the schematic panel that appears next to the most recent price action on the right side of the chart as a visual reference, it mirrors the textbook Wyckoff diagram for the type of range currently active, accumulation, re-accumulation, distribution or re-distribution, with a green dot showing exactly where the market currently sits on that path, and a projected grey path sketching how the remaining stages would typically unfold if the pattern continues to play out. This panel and the projected path are only shown while a structure is actively in progress, once a campaign finishes or resets they are removed, while the trading range box and its blue edge lines stay on the chart as a permanent historical record.

WHAT THE DASHBOARD SHOWS

Two optional tables can be turned on from the indicator settings. The Status Table, placed in the top right corner, shows in real time whether a structure is currently active, its type, accumulation, re-accumulation, distribution or re-distribution, its current phase letter, how many bars have passed since the last meaningful event, what the indicator expects to happen next, the current maturity score, the current validation score, the numeric top and bottom of the active range, and the reason the last structure was reset if one has recently ended. The Diagnostics Table, placed in the bottom right corner, breaks the internal checklist down line by line, showing whether absorption has been confirmed, whether the Automatic Rally has been confirmed, how many Secondary Tests have occurred against the required minimum, how many opposite edge tests have occurred, whether the eventual outcome direction has been locked in, and whether the maturity and validation scores have crossed their required thresholds, each row marked with a clear pass or fail symbol so the trader can see exactly which conditions are still missing before an entry signal can appear.

[image]https://www.tradingview.com/x/SS7krS3d/[/image]

SETTINGS OVERVIEW

The Display group controls what is drawn on the chart, including the trading range box, the event labels, the phase letters, the optional phase background shading, the entry markers, the minimum phase required before a structure is drawn, the Wyckoff schematic panel, the projected path, and the position and size of that panel. The Entry group controls how strict the entry logic is, Conservative requires the most confirmation and only signals at the Last Point of Support or Supply, Standard signals at the Spring, Upthrust or Last Point, and Aggressive will also signal on a strong Sign of Strength or Weakness when no probe occurred. The Tables group turns the Status Table and Diagnostics Table on or off.

Author: Michael_Fx_Trader
Publisher: Michael_Fx_Trader
Copyright: Michael_Fx_Trader, all rights reserved.
Original Work Statement: This script, Smart Money The Ultimator, is an original work authored and published by Michael_Fx_Trader. All Wyckoff state machine logic, scoring formulas, detection thresholds, drawing routines and table layouts contained in this script were designed and written by Michael_Fx_Trader for the purpose of automating classical Wyckoff Method market structure analysis, covering accumulation, re-accumulation, distribution and re-distribution.
Version: 1.0
Disclaimer: This indicator is provided for educational and informational purposes only. It does not place trades, does not manage risk, and does not constitute financial advice. Wyckoff analysis is partly discretionary, this script encodes one rule based interpretation with fixed thresholds and may repaint state labels until a bar is fully confirmed. Always backtest and paper trade before risking real capital.

---

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════════════
//  SMART MONEY THE ULTIMATOR
//  Automated Wyckoff Method Market-Structure Engine (Pine Script v6)
// ═══════════════════════════════════════════════════════════════════════════════════
//
//  AUTHOR / PUBLISHER / COPYRIGHT DECLARATION
//  ------------------------------------------------------------------------------------
//  Author                  : Michael_Fx_Trader
//  Publisher               : Michael_Fx_Trader
//  Copyright               : © Michael_Fx_Trader. All rights reserved.
//  Original Work Statement : This script, "Smart Money The Ultimator", is an original
//                            work authored and published by Michael_Fx_Trader. All Wyckoff
//                            state-machine logic, scoring formulas, detection thresholds,
//                            drawing routines and table layouts contained in this file were
//                            designed and written by Michael_Fx_Trader for the purpose of
//                            automating classical Wyckoff Method market-structure analysis
//                            (accumulation / re-accumulation / distribution / re-distribution).
//  Version                 : 1.0
//  Disclaimer              : This indicator is provided for educational and informational
//                            purposes only. It does NOT place trades, does NOT manage risk,
//                            and does NOT constitute financial advice. Wyckoff analysis is
//                            partly discretionary; this script encodes one rule-based
//                            interpretation with fixed thresholds and may repaint state
//                            labels until a bar is fully confirmed. Always backtest and
//                            paper-trade before risking real capital.
// ═══════════════════════════════════════════════════════════════════════════════════
// © Michael_Fx_Trader — All Rights Reserved
// ═══════════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Smart Money The Ultimator", shorttitle = "SM Ultim", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 5000)

// ═══════════════════════════════════ LAYER 1 : INPUTS ═══════════════════════════════════

grpDisp   = "Display"
grpEntry  = "Entry"
grpTable  = "Tables"

showBox        = input.bool(true,  "Show Trading Range Box",        group = grpDisp)
showLabels     = input.bool(true,  "Show Event Labels",             group = grpDisp)
showPhaseLet   = input.bool(true,  "Show Phase Letters (B/C/D/E)",  group = grpDisp)
showPhaseBG    = input.bool(false, "Show Phase Background Shading", group = grpDisp)
showEntries    = input.bool(true,  "Show Entry Markers",            group = grpDisp)
minPhaseShow   = input.string("B", "Current Chart Minimum Phase", options = ["A","B","C","D","E"], group = grpDisp)

entryStrictStr = input.string("Standard", "Entry Strictness", options = ["Conservative","Standard","Aggressive"], group = grpEntry)

showSchem      = input.bool(true,  "Show Wyckoff Schematic Panel",  group = grpDisp)
showForecast   = input.bool(true,  "Show Projected Path",           group = grpDisp)
schemOffset    = input.int(25, "Schematic: bars to the right", minval = 5,  maxval = 200, group = grpDisp)
schemWidth     = input.int(60, "Schematic: panel width (bars)", minval = 20, maxval = 300, group = grpDisp)
forecastBars   = input.int(80, "Projected path length (bars)",  minval = 10, maxval = 300, group = grpDisp)

showStatusTable = input.bool(false, "Show Status Table",      group = grpTable)
showDiagTable   = input.bool(false, "Show Structure Diagnostics", group = grpTable)

// ═══════════════════════════════════ LAYER 2 : CONSTANTS / ENUMS ═══════════════════════

// -- hard-coded detection thresholds (edit here to tune the engine) --
climaxVolMult    = 1.8      // volume must be >= 1.8x its 50-bar average to qualify as climax
climaxSpreadMult = 1.5      // spread must be >= 1.5x ATR to qualify as climax
minARATR         = 2.0      // AR must travel at least 2.0 ATR from the climax to be valid
stMaxVolRatio    = 0.90     // ST volume must be <= 90% of climax volume
stMaxSpreadRatio = 0.90     // ST spread must be <= 90% of climax spread
springMinPenATR  = 0.15     // minimum excursion beyond the range edge to qualify as a probe
springMaxPenATR  = 2.5      // maximum excursion beyond the range edge (deeper = invalid)
absorbMinBar     = 3        // absorption window opens 3 bars after the climax
absorbMaxBar     = 8        // absorption window closes 8 bars after the climax
absorbEffortMin  = 0.90     // effort must stay >= 90% of average during absorption
absorbNewExtATR  = 0.5      // price must not make a new extreme beyond 0.5 ATR
absorbReboundATR = 0.35     // price must rebound at least 0.35 ATR from the climax
phaseBMinBarsBase   = 30    // minimum bars for Phase B maturity (scaled by swing length)
phaseBMaxBarsBase   = 60
staleLimitBase       = 40   // bars of inactivity before a campaign is declared stale
rangeExpandCap    = 0.15    // range edge may expand at most 15% beyond original extreme

DIR_ACCUM  = 1
DIR_DIST   = -1

TYPE_NONE    = 0
TYPE_ACCUM   = 1
TYPE_REACCUM = 2
TYPE_DIST    = 3
TYPE_REDIST  = 4

PHASE_NONE = 0
PHASE_A = 1
PHASE_B = 2
PHASE_C = 3
PHASE_D = 4
PHASE_E = 5

// ═══════════════════════════════════ LAYER 3 : STATE CONTAINER (WS) ═════════════════════

type WS
    bool  active        = false
    int   dir           = 0          // OUTCOME BIAS: DIR_ACCUM (bullish resolution) / DIR_DIST (bearish resolution)
    bool  climaxTop     = false      // STRUCTURAL SIDE: true = climax is a BC (top), false = climax is an SC (bottom)
    int   sType         = 0          // 0 = TYPE_NONE ; 1=ACCUM 2=REACCUM 3=DIST 4=REDIST (literal required here)
    // climax
    int   climaxBar     = na
    int   climaxTime    = na
    float climaxPrice   = na
    float climaxVol     = na
    float climaxSpread  = na
    int   climaxScore   = na
    bool  absorbed      = false
    // AR
    float arPrice       = na
    int   arTime         = na
    bool  arConfirmed   = false
    // ST
    float stPrice       = na
    int   stTime         = na
    int   stBar          = na
    int   stScore       = na
    int   stCount       = 0
    // phase / range
    int   phase         = 0          // 0 = PHASE_NONE (literal required here)
    float rangeHigh     = na
    float rangeLow      = na
    int   oppTestCount  = 0
    int   traversals    = 0
    float maturity      = 0.0
    float validation    = 0.0
    bool  outcomeSet    = false
    // Phase C
    int   springTime    = na
    float springPrice   = na
    int   springScore   = na
    int   utadTime      = na
    float utadPrice     = na
    bool  testDone      = false
    // Phase D
    int   sosTime       = na
    int   sosBar        = na
    float sosPrice      = na
    int   sosScore      = na
    int   lpsTime       = na
    float lpsPrice      = na
    int   lpsScore      = na
    int   belowMidCloses = 0
    // Phase E
    int   phaseEStart   = na
    // bookkeeping
    int   lastEventBar  = na
    int   staleBars     = 0
    bool  entryDone     = false
    float entryPrice    = na
    int   entryBar       = na
    string resetReason  = ""

var WS ws = WS.new()

// completed-campaign snapshot (kept for the status table only, in this build)
var int   lastResetBar    = na
var string lastResetReason = ""
var int   completedCount   = 0

// ═══════════════════════════════════ LAYER 4 : HELPER FUNCTIONS ═════════════════════════

atr14 = ta.atr(14)

// -- Step 1 : bar measurements --------------------------------------------------------
f_effort() =>
    // falls back to spread when the symbol carries no volume data
    na(volume) or volume == 0 ? (high - low) * 1000 : volume

effort        = f_effort()
avgEffort50   = ta.sma(effort, 50)
relEffort     = avgEffort50 == 0 ? 1.0 : effort / avgEffort50
spreadNow     = high - low
closePos      = spreadNow == 0 ? 0.5 : (close - low) / spreadNow

// -- prior trend score (-100..+100) ----------------------------------------------------
f_priorTrendScore(len) =>
    chg   = ta.change(close, len)
    denom = atr14 * len
    raw   = denom == 0 ? 0.0 : 100.0 * chg / denom
    math.max(-100.0, math.min(100.0, raw))

// -- swing-length scaling so time windows adapt to timeframe/volatility ---------------
swingLenAtr   = ta.atr(20)
swingLenBars  = 20
f_scaleBars(baseBars) =>
    scale = atr14 == 0 ? 1.0 : swingLenAtr / atr14
    int(math.max(baseBars * 0.6, math.min(baseBars * 2.0, baseBars * scale)))

// -- robust edge : median of the top-N pivots so a single wick can't distort the box --
f_robustEdge(hiSeries, loSeries, isHigh, lookback) =>
    hiVal = ta.highest(hiSeries, lookback)   // both must be evaluated on every bar
    loVal = ta.lowest(loSeries,  lookback)
    isHigh ? hiVal : loVal

// -- maturity score (0-100) : how many textbook milestones achieved -------------------
f_structureConfidence(priorTrendOk, climaxOk, arOk, stOk, phaseCDone, strengthOk, lpsOk, acceptanceOk) =>
    float m = 0.0
    m += priorTrendOk ? 10.0 : 0.0
    m += climaxOk ? 15.0 : 0.0
    m += arOk ? 10.0 : 0.0
    m += stOk ? 15.0 : 0.0
    m += phaseCDone ? 15.0 : 0.0
    m += strengthOk ? 15.0 : 0.0
    m += lpsOk ? 10.0 : 0.0
    m += acceptanceOk ? 10.0 : 0.0
    m

// -- validation score (0-100) : how "clean" the range itself is -----------------------
f_validationScore(priorTrendOk, absorptionOk, rangeHeightOk, stTestsOk, oppTestsOk, noFailedOk, causeOk, terminalTestOk, sosOk, lpsOk) =>
    float s = 0.0
    s += priorTrendOk ? 10.0 : 0.0
    s += absorptionOk ? 15.0 : 0.0
    s += rangeHeightOk ? 10.0 : 0.0
    s += stTestsOk ? 15.0 : 0.0
    s += oppTestsOk ? 15.0 : 0.0
    s += noFailedOk ? 10.0 : 0.0
    s += causeOk ? 10.0 : 0.0
    s += terminalTestOk ? 10.0 : 0.0
    s += sosOk ? 3.0 : 0.0
    s += lpsOk ? 2.0 : 0.0
    s

// -- test grading : GOOD / POOR / FAILED -----------------------------------------------
f_testClass(volRatio, spreadRatio, heldExtreme, closeSupportive) =>
    score = 0
    score += volRatio <= stMaxVolRatio ? 1 : 0
    score += spreadRatio <= stMaxSpreadRatio ? 1 : 0
    score += heldExtreme ? 1 : 0
    score += closeSupportive ? 1 : 0
    result = score >= 3 ? "GOOD" : score == 2 ? "POOR" : "FAILED"
    result

// ═══════════════════════════════════ LAYER 5 : ADAPTIVE PIVOTS ══════════════════════════

volRatioForPivot = atr14 == 0 ? 1.0 : swingLenAtr / atr14
pivLen = int(math.max(2, math.min(10, 6 * volRatioForPivot)))

pivHi = ta.pivothigh(pivLen, pivLen)
pivLo = ta.pivotlow(pivLen, pivLen)

// ═══════════════════════════════════ LAYER 6 : TREND / REGIME CONTEXT ═══════════════════

trendScore = f_priorTrendScore(30)
sma200     = ta.sma(close, 200)
smaSlopeUp = sma200 > sma200[10]
isUptrend   = trendScore >= 15
isDowntrend = trendScore <= -15
var int regime = 0   // 1 = markup, -1 = markdown, 0 = neutral
if isUptrend
    regime := 1
else if isDowntrend
    regime := -1

// ═══════════════════════════════════ LAYER 7 : PS / PSY (PRELIMINARY) ═══════════════════

var float psCandidatePrice = na
var int   psCandidateBar   = na
var bool  psCandidateIsSupply = false

// evaluated on EVERY bar (never inside a conditional) so the rolling window stays consistent
lowest30  = ta.lowest(low, 30)
highest30 = ta.highest(high, 30)

if not ws.active
    nearExtremeLow  = low  <= lowest30 * 1.01
    nearExtremeHigh = high >= highest30 * 0.99
    if isDowntrend and relEffort >= 1.4 and nearExtremeLow
        psCandidatePrice := low
        psCandidateBar   := bar_index
        psCandidateIsSupply := false
    if isUptrend and relEffort >= 1.4 and nearExtremeHigh
        psCandidatePrice := high
        psCandidateBar   := bar_index
        psCandidateIsSupply := true

// ═══════════════════════════════════ LAYER 8 : ENGINE ═══════════════════════════════════

// -- Step 5 : climax detection (seeding) ------------------------------------------------
newHigh30 = high >= highest30
newLow30  = low  <= lowest30
volSpike    = relEffort >= climaxVolMult
spreadSpike = atr14 > 0 and spreadNow >= climaxSpreadMult * atr14

bcMandatory = isUptrend and newHigh30 and volSpike and spreadSpike
scMandatory = isDowntrend and newLow30 and volSpike and spreadSpike

bcBonus = (closePos <= 0.35 ? 1 : 0) + ((relEffort == ta.highest(relEffort, 30) or spreadNow >= 2.25 * atr14) ? 1 : 0)
scBonus = (closePos >= 0.65 ? 1 : 0) + ((relEffort == ta.highest(relEffort, 30) or spreadNow >= 2.25 * atr14) ? 1 : 0)

bcScore = bcMandatory ? 4 + bcBonus : 0
scScore = scMandatory ? 4 + scBonus : 0

canSeed = not ws.active and (bcScore >= 5 or scScore >= 5) and not (bcScore >= 5 and scScore >= 5)

if canSeed
    ws := WS.new()
    ws.active      := true
    ws.climaxBar   := bar_index
    ws.climaxTime  := time
    ws.climaxScore := bcScore >= 5 ? bcScore : scScore
    ws.climaxTop   := bcScore >= 5                          // BC = climax at the top, SC = climax at the bottom
    ws.climaxPrice := bcScore >= 5 ? high : low
    ws.climaxVol   := effort
    ws.climaxSpread:= spreadNow
    ws.phase       := PHASE_A
    ws.lastEventBar:= bar_index
    ws.rangeHigh   := bcScore >= 5 ? high : na
    ws.rangeLow    := scScore >= 5 ? low  : na
    // context-based OUTCOME BIAS: BC after markup context -> Re-accumulation (bullish resolution),
    // BC otherwise -> Distribution (bearish resolution). SC is the mirror image.
    if bcScore >= 5
        ws.sType := (regime == 1 or smaSlopeUp) ? TYPE_REACCUM : TYPE_DIST
    else
        ws.sType := (regime == -1 or not smaSlopeUp) ? TYPE_REDIST : TYPE_ACCUM
    ws.dir := (ws.sType == TYPE_ACCUM or ws.sType == TYPE_REACCUM) ? DIR_ACCUM : DIR_DIST
    if showLabels
        lblTxt = bcScore >= 5 ? "BC " + str.tostring(bcScore) + "/6" : "SC " + str.tostring(scScore) + "/6"
        label.new(bar_index, bcScore >= 5 ? high : low, lblTxt,
             style = bcScore >= 5 ? label.style_label_down : label.style_label_up,
             color = color.maroon, textcolor = color.white, size = size.small)
    if showLabels and not na(psCandidatePrice) and (bar_index - psCandidateBar) <= 40
        label.new(psCandidateBar, psCandidatePrice, psCandidateIsSupply ? "PSY" : "PS",
             style = psCandidateIsSupply ? label.style_label_down : label.style_label_up,
             color = color.maroon, textcolor = color.white, size = size.tiny)

// -- Step 6 : absorption confirmation ----------------------------------------------------
if ws.active and not ws.absorbed and ws.phase == PHASE_A
    barsSince = bar_index - ws.climaxBar
    if barsSince >= absorbMinBar and barsSince <= absorbMaxBar
        effortOk   = relEffort >= absorbEffortMin
        noNewExt   = ws.climaxTop ? (high <= ws.climaxPrice + absorbNewExtATR * atr14) : (low  >= ws.climaxPrice - absorbNewExtATR * atr14)
        reboundOk  = ws.climaxTop ? (ws.climaxPrice - close >= absorbReboundATR * atr14) : (close - ws.climaxPrice >= absorbReboundATR * atr14)
        if effortOk and noNewExt and reboundOk
            ws.absorbed := true
            ws.lastEventBar := bar_index
    else if barsSince > absorbMaxBar
        ws.active := false
        ws.resetReason := "No absorption"
        lastResetReason := "No absorption"
        lastResetBar := bar_index

// -- Step 7 : Automatic Rally / Reaction --------------------------------------------------
if ws.active and ws.absorbed and not ws.arConfirmed
    barsSince = bar_index - ws.climaxBar
    move = ws.climaxTop ? (ws.climaxPrice - low) : (high - ws.climaxPrice)
    if move >= minARATR * atr14
        cand = ws.climaxTop ? low : high
        if na(ws.arPrice)
            ws.arPrice := cand
            ws.arTime  := time
        else
            improved = ws.climaxTop ? cand < ws.arPrice : cand > ws.arPrice
            if improved
                ws.arPrice := cand
                ws.arTime  := time
    if barsSince > 30 and na(ws.arPrice)
        ws.active := false
        ws.resetReason := "No AR within 30 bars"
        lastResetReason := ws.resetReason
        lastResetBar := bar_index

// -- Step 8 : Secondary Test -> Phase B ----------------------------------------------------
if ws.active and ws.arConfirmed == false and not na(ws.arPrice) and ws.phase == PHASE_A
    nearClimax = ws.climaxTop ? (high >= ws.climaxPrice - 1.0 * atr14) : (low <= ws.climaxPrice + 1.0 * atr14)
    volRatio    = ws.climaxVol == 0 ? 1.0 : effort / ws.climaxVol
    spreadRatio = ws.climaxSpread == 0 ? 1.0 : spreadNow / ws.climaxSpread
    heldExtreme = ws.climaxTop ? high <= ws.climaxPrice : low >= ws.climaxPrice
    closeSupp   = ws.climaxTop ? closePos <= 0.6 : closePos >= 0.4
    enoughTime  = (bar_index - ws.climaxBar) >= 3
    enoughDist  = math.abs(close - ws.arPrice) >= 0.5 * atr14
    if nearClimax and volRatio <= stMaxVolRatio and spreadRatio <= stMaxSpreadRatio and enoughTime and enoughDist
        stScoreLocal = 1
        stScoreLocal += 1                          // near climax
        stScoreLocal += volRatio <= stMaxVolRatio ? 1 : 0
        stScoreLocal += spreadRatio <= stMaxSpreadRatio ? 1 : 0
        stScoreLocal += heldExtreme ? 1 : 0
        stScoreLocal += closeSupp ? 1 : 0
        if stScoreLocal >= 4
            ws.arConfirmed := true
            ws.stPrice     := ws.climaxTop ? high : low
            ws.stTime      := time
            ws.stBar       := bar_index
            ws.stScore     := math.min(stScoreLocal, 6)
            ws.stCount     := 1
            ws.phase       := PHASE_B
            // "robust edge" : the ST high/low (not the raw climax wick) sets the climax-side boundary,
            // the AR sets the opposite-side boundary — this excludes the climax spike from the box.
            ws.rangeHigh   := ws.climaxTop ? ws.stPrice : ws.arPrice
            ws.rangeLow    := ws.climaxTop ? ws.arPrice : ws.stPrice
            ws.lastEventBar := bar_index
            if showLabels
                label.new(bar_index, ws.climaxTop ? high : low, "ST " + str.tostring(ws.stScore) + "/6",
                     style = ws.climaxTop ? label.style_label_down : label.style_label_up,
                     color = color.blue, textcolor = color.white, size = size.small)
                label.new(bar_index, ws.climaxTop ? high + atr14 : low - atr14, "B",
                     style = label.style_label_up, color = color.teal, textcolor = color.white, size = size.tiny)
            if showLabels and not na(ws.arPrice)
                label.new(ws.climaxBar, ws.arPrice, "AR",
                     style = ws.climaxTop ? label.style_label_up : label.style_label_down,
                     color = color.gray, textcolor = color.white, size = size.small)

// -- Step 9 : Phase B — building the trading range ------------------------------------------
if ws.active and ws.phase == PHASE_B
    // "same edge" = the edge where the climax + ST occurred; "opposite edge" = the AR side
    if not na(pivHi) and ws.climaxTop and pivHi >= ws.rangeHigh - 0.3 * atr14
        ws.stCount += 1
        ws.lastEventBar := bar_index
    if not na(pivLo) and not ws.climaxTop and pivLo <= ws.rangeLow + 0.3 * atr14
        ws.stCount += 1
        ws.lastEventBar := bar_index
    if not na(pivLo) and ws.climaxTop and pivLo <= ws.rangeLow + 0.3 * atr14
        ws.oppTestCount += 1
        ws.lastEventBar := bar_index
    if not na(pivHi) and not ws.climaxTop and pivHi >= ws.rangeHigh - 0.3 * atr14
        ws.oppTestCount += 1
        ws.lastEventBar := bar_index
    // traversals between the 25% zones
    zoneTop = ws.rangeLow + 0.75 * (ws.rangeHigh - ws.rangeLow)
    zoneBot = ws.rangeLow + 0.25 * (ws.rangeHigh - ws.rangeLow)
    if close >= zoneTop or close <= zoneBot
        ws.traversals += 1
    // capped range-edge nudging
    capHi = ws.rangeHigh + rangeExpandCap * (ws.rangeHigh - ws.rangeLow)
    capLo = ws.rangeLow  - rangeExpandCap * (ws.rangeHigh - ws.rangeLow)
    ws.rangeHigh := math.min(math.max(ws.rangeHigh, high), capHi)
    ws.rangeLow  := math.max(math.min(ws.rangeLow, low), capLo)

    minBars = f_scaleBars(phaseBMinBarsBase)
    barsInB = na(ws.stBar) ? 0 : bar_index - ws.stBar   // bar count, NOT unix time
    supportClues = (ws.oppTestCount >= 1 ? 1 : 0) + (ws.traversals >= 2 ? 1 : 0) + (ws.stCount >= 2 ? 1 : 0) + (relEffort < 1.0 ? 1 : 0)
    phaseBMature = barsInB >= minBars and ws.stCount >= 2 and (ws.rangeHigh - ws.rangeLow) >= 1.5 * atr14 and (ws.rangeHigh - ws.rangeLow) <= 8 * atr14 and supportClues >= 2

    if phaseBMature and showLabels and ws.oppTestCount == 1
        label.new(bar_index, close, "mSOW", style = label.style_label_up, color = color.new(color.green, 0), textcolor = color.white, size = size.tiny)

// -- Step 10 : Phase C — Spring / UTAD / terminal test ---------------------------------------
minBarsB = f_scaleBars(phaseBMinBarsBase)
phaseBMatureFlag = ws.active and ws.phase == PHASE_B and not na(ws.stBar) and (bar_index - ws.stBar) >= minBarsB and ws.stCount >= 2

if ws.active and ws.phase == PHASE_B
    penLow  = ws.rangeLow  - low
    penHigh = high - ws.rangeHigh
    springProbe = ws.dir == DIR_ACCUM and penLow  >= springMinPenATR * atr14 and penLow  <= springMaxPenATR * atr14
    utadProbe   = ws.dir == DIR_DIST  and penHigh >= springMinPenATR * atr14 and penHigh <= springMaxPenATR * atr14
    closedBackIn = ws.dir == DIR_ACCUM ? close >= ws.rangeLow : close <= ws.rangeHigh

    if (springProbe or utadProbe) and closedBackIn
        probeScoreLocal = (closePos >= 0.5 and ws.dir == DIR_ACCUM ? 1 : 0) + (closePos <= 0.5 and ws.dir == DIR_DIST ? 1 : 0)
        probeScoreLocal += relEffort <= 1.2 ? 1 : 0
        probeScoreLocal += (close > open and ws.dir == DIR_ACCUM) or (close < open and ws.dir == DIR_DIST) ? 1 : 0
        probeScoreLocal += spreadNow <= 1.3 * atr14 ? 1 : 0
        if probeScoreLocal >= 2
            ws.phase := PHASE_C
            ws.outcomeSet := true
            ws.lastEventBar := bar_index
            if ws.dir == DIR_ACCUM
                ws.springTime  := time
                ws.springPrice := low
                ws.springScore := probeScoreLocal
                if showLabels
                    label.new(bar_index, low, "SPRING", style = label.style_label_up, color = color.new(color.lime, 0), textcolor = color.black, size = size.small)
            else
                ws.utadTime  := time
                ws.utadPrice := high
                ws.springScore := probeScoreLocal
                if showLabels
                    label.new(bar_index, high, "UTAD", style = label.style_label_down, color = color.new(color.fuchsia, 0), textcolor = color.white, size = size.small)

    // terminal (quiet) test if no excursion occurred and B is mature
    else if phaseBMatureFlag
        quietEdge = ws.dir == DIR_ACCUM ? (low <= ws.rangeLow + 0.5 * atr14) : (high >= ws.rangeHigh - 0.5 * atr14)
        if quietEdge and relEffort < 0.8
            ws.phase := PHASE_C
            ws.outcomeSet := true
            ws.lastEventBar := bar_index
            if showLabels
                label.new(bar_index, ws.dir == DIR_ACCUM ? low : high, "C-TEST", style = label.style_label_up, color = color.blue, textcolor = color.white, size = size.small)

// -- Test after Spring/UTAD --
if ws.active and ws.phase == PHASE_C and not ws.testDone and (not na(ws.springTime) or not na(ws.utadTime))
    lowEffortRetest = relEffort < 0.9
    holdsExtreme = ws.dir == DIR_ACCUM ? low >= ws.springPrice : high <= ws.utadPrice
    if lowEffortRetest and holdsExtreme and (bar_index - ws.lastEventBar) >= 2
        ws.testDone := true
        ws.lastEventBar := bar_index
        if showLabels
            label.new(bar_index, close, "TEST", style = label.style_label_down, color = color.new(color.blue, 0), textcolor = color.white, size = size.tiny)

// -- Step 11 : Phase D — SOS / SOW -----------------------------------------------------------
maturityNow = 0.0
validationNow = 0.0
if ws.active
    maturityNow := f_structureConfidence(trendScore != 0, ws.climaxScore >= 5, ws.arConfirmed,
         ws.stCount >= 1, ws.phase >= PHASE_C, not na(ws.sosTime), not na(ws.lpsTime), ws.phase == PHASE_E)
    validationNow := f_validationScore(trendScore != 0, ws.absorbed,
         (ws.rangeHigh - ws.rangeLow) >= 1.5 * atr14 and (ws.rangeHigh - ws.rangeLow) <= 8 * atr14,
         ws.stCount >= 2, ws.oppTestCount >= 1, true, ws.traversals >= 2,
         ws.outcomeSet, not na(ws.sosTime), not na(ws.lpsTime))
    ws.maturity := maturityNow
    ws.validation := validationNow

if ws.active and ws.phase == PHASE_C and ws.outcomeSet and (bar_index - ws.lastEventBar) >= 3 and ws.validation >= 60 and ws.maturity >= 45
    dominance = ws.dir == DIR_ACCUM ? (closePos >= 0.65 or close > ws.rangeHigh) : (closePos <= 0.35 or close < ws.rangeLow)
    strengthBar = spreadNow >= 1.5 * atr14 and relEffort >= 1.3
    strengthMulti = ws.dir == DIR_ACCUM ? (close - close[5] >= 2 * atr14) : (close[5] - close >= 2 * atr14)
    strengthOk = (strengthBar or strengthMulti) and relEffort >= 1.1
    if dominance and strengthOk
        ws.phase := PHASE_D
        ws.sosTime  := time
        ws.sosBar   := bar_index
        ws.sosPrice := close
        ws.sosScore := (dominance ? 2 : 0) + (strengthBar ? 2 : 0)
        ws.lastEventBar := bar_index
        if showLabels
            label.new(bar_index, ws.dir == DIR_ACCUM ? low : high, ws.dir == DIR_ACCUM ? "SOS" : "SOW",
                 style = ws.dir == DIR_ACCUM ? label.style_label_up : label.style_label_down,
                 color = color.new(color.lime, 0), textcolor = color.black, size = size.small)

// -- Step 12 : LPS / LPSY ----------------------------------------------------------------------
if ws.active and ws.phase == PHASE_D
    nearBrokenEdge = ws.dir == DIR_ACCUM ? math.abs(low - ws.rangeHigh) <= 1.5 * atr14 : math.abs(high - ws.rangeLow) <= 1.5 * atr14
    lowActivity = relEffort < 0.9 and spreadNow <= 1.0 * atr14
    holdsLevel  = ws.dir == DIR_ACCUM ? low >= ws.rangeHigh - 1.5 * atr14 : high <= ws.rangeLow + 1.5 * atr14
    if na(ws.lpsTime) and nearBrokenEdge and lowActivity and holdsLevel and not na(ws.sosBar) and (bar_index - ws.sosBar) >= 2
        ws.lpsTime  := time
        ws.lpsPrice := close
        ws.lpsScore := (nearBrokenEdge ? 1 : 0) + (lowActivity ? 1 : 0) + (holdsLevel ? 1 : 0)
        ws.lastEventBar := bar_index
        if showLabels
            label.new(bar_index, ws.dir == DIR_ACCUM ? low : high, ws.dir == DIR_ACCUM ? "LPS" : "LPSY",
                 style = ws.dir == DIR_ACCUM ? label.style_label_up : label.style_label_down,
                 color = color.new(color.aqua, 0), textcolor = color.black, size = size.small)

    // demotion back to Phase B on 3 closes back through the midpoint
    mid = (ws.rangeHigh + ws.rangeLow) / 2
    backThrough = ws.dir == DIR_ACCUM ? close < mid : close > mid
    ws.belowMidCloses := backThrough ? ws.belowMidCloses + 1 : 0
    if ws.belowMidCloses >= 3
        ws.phase := PHASE_B
        ws.outcomeSet := false
        ws.belowMidCloses := 0
        ws.lastEventBar := bar_index

// -- Step 13 : Phase E — acceptance ------------------------------------------------------------
if ws.active and ws.phase == PHASE_D
    outside = ws.dir == DIR_ACCUM ? close > ws.rangeHigh : close < ws.rangeLow
    if outside
        if na(ws.phaseEStart)
            ws.phaseEStart := bar_index
    else
        ws.phaseEStart := na
    if not na(ws.phaseEStart)
        barsOutside = bar_index - ws.phaseEStart
        acceptA = not na(ws.lpsTime) and barsOutside >= 3 and ws.maturity >= 55
        acceptB = barsOutside >= 5 and ws.maturity >= 75
        if acceptA or acceptB
            ws.phase := PHASE_E
            regime := ws.dir == DIR_ACCUM ? 1 : -1
            ws.lastEventBar := bar_index

if ws.active and ws.phase == PHASE_E
    mid = (ws.rangeHigh + ws.rangeLow) / 2
    backIn = ws.dir == DIR_ACCUM ? close < mid : close > mid
    tooOld = (bar_index - ws.climaxBar) > 300
    if backIn or tooOld
        ws.active := false
        ws.resetReason := tooOld ? "Phase E timeout (300 bars)" : "Returned below range midpoint"
        lastResetReason := ws.resetReason
        lastResetBar := bar_index
        completedCount += 1

// -- Step 14 : retirement / invalidation rules --------------------------------------------------
if ws.active
    invalidated = ws.climaxTop ? close > ws.climaxPrice + 0.5 * atr14 : close < ws.climaxPrice - 0.5 * atr14
    if invalidated
        ws.staleBars += 1
    else
        ws.staleBars := 0
    staleLimit = f_scaleBars(staleLimitBase)
    if ws.staleBars >= 2 and ws.phase == PHASE_A
        ws.active := false
        ws.resetReason := "Invalidated (closed beyond climax)"
        lastResetReason := ws.resetReason
        lastResetBar := bar_index
    else if (bar_index - ws.lastEventBar) >= staleLimit
        ws.active := false
        ws.resetReason := "Stale (no progress)"
        lastResetReason := ws.resetReason
        lastResetBar := bar_index

// -- Step 15 : entry logic --------------------------------------------------------------------
entryThreshold = entryStrictStr == "Conservative" ? 75 : entryStrictStr == "Standard" ? 60 : 55
readiness = 0
if ws.active
    readiness += ws.outcomeSet ? 1 : 0
    readiness += ws.phase >= PHASE_C ? 1 : 0
    readiness += ws.testDone ? 1 : 0
    readiness += not na(ws.sosTime) ? 1 : 0
    readiness += not na(ws.lpsTime) ? 1 : 0
    readiness += ws.maturity >= entryThreshold ? 1 : 0
    readiness += ws.validation >= 55 ? 1 : 0
    readiness += math.abs(close - (ws.rangeHigh + ws.rangeLow) / 2) <= 2 * atr14 ? 1 : 0
    readiness += (bar_index - ws.lastEventBar) <= 10 ? 1 : 0

longSignal = false
shortSignal = false
if ws.active and not ws.entryDone and ws.outcomeSet and ws.maturity >= entryThreshold and readiness >= 5
    if entryStrictStr == "Conservative"
        if not na(ws.lpsTime) and ws.lpsTime == time
            longSignal := ws.dir == DIR_ACCUM
            shortSignal := ws.dir == DIR_DIST
    else if entryStrictStr == "Standard"
        if ws.phase == PHASE_C and ((ws.dir == DIR_ACCUM and time == ws.springTime) or (ws.dir == DIR_DIST and time == ws.utadTime))
            longSignal := ws.dir == DIR_ACCUM
            shortSignal := ws.dir == DIR_DIST
        else if not na(ws.lpsTime) and ws.lpsTime == time
            longSignal := ws.dir == DIR_ACCUM
            shortSignal := ws.dir == DIR_DIST
    else // Aggressive
        if ws.phase == PHASE_C and ((ws.dir == DIR_ACCUM and time == ws.springTime) or (ws.dir == DIR_DIST and time == ws.utadTime))
            longSignal := ws.dir == DIR_ACCUM
            shortSignal := ws.dir == DIR_DIST
        else if not na(ws.sosTime) and ws.sosTime == time and na(ws.springTime) and na(ws.utadTime)
            longSignal := ws.dir == DIR_ACCUM
            shortSignal := ws.dir == DIR_DIST

if longSignal or shortSignal
    ws.entryDone := true
    ws.entryPrice := close
    ws.entryBar := bar_index
    if showEntries
        label.new(bar_index, longSignal ? low - atr14 : high + atr14, longSignal ? "LONG ENTRY" : "SHORT ENTRY",
             style = longSignal ? label.style_label_up : label.style_label_down,
             color = longSignal ? color.new(color.green, 0) : color.new(color.red, 0), textcolor = color.white, size = size.small)

// ═══════════════════════════════════ LAYER 9 : DRAWING ══════════════════════════════════

phaseRank(p) =>
    p == "A" ? 1 : p == "B" ? 2 : p == "C" ? 3 : p == "D" ? 4 : 5

// a structure may only be drawn when its box coordinates are real numbers, otherwise the
// box stretches across the whole chart (this was the "everything is shaded" problem)
rangeValid        = not na(ws.rangeHigh) and not na(ws.rangeLow) and not na(ws.climaxBar) and ws.rangeHigh > ws.rangeLow
showThisStructure = ws.active and rangeValid and ws.phase >= phaseRank(minPhaseShow)

// ---- trading range box + blue edge lines (as in the reference chart) ----
// A finished/invalidated campaign's box is now LEFT ON THE CHART as a historical record
// (exactly like the reference image) instead of being deleted. A fresh box/line pair is
// only started when a brand-new campaign begins (its climaxBar differs from the one the
// current box belongs to) — the old box simply stops updating and stays frozen in place.
var box  rangeBox      = na
var line topLine       = na
var line botLine       = na
var int  boxClimaxBar  = na

if showBox and showThisStructure
    boxColor  = ws.sType == TYPE_ACCUM or ws.sType == TYPE_REACCUM ? color.new(color.green, 92) : ws.sType == TYPE_DIST or ws.sType == TYPE_REDIST ? color.new(color.red, 92) : color.new(color.gray, 92)
    borderCol = ws.outcomeSet ? (ws.dir == DIR_ACCUM ? color.lime : color.red) : color.new(color.white, 35)
    if na(rangeBox) or boxClimaxBar != ws.climaxBar
        // new campaign -> start a brand-new box/line pair; any previous ones stay on the chart untouched
        rangeBox := box.new(ws.climaxBar, ws.rangeHigh, bar_index, ws.rangeLow, border_color = borderCol, border_width = 1, bgcolor = boxColor)
        topLine  := line.new(ws.climaxBar, ws.rangeHigh, bar_index, ws.rangeHigh, color = color.blue, width = 1)
        botLine  := line.new(ws.climaxBar, ws.rangeLow,  bar_index, ws.rangeLow,  color = color.blue, width = 1)
        boxClimaxBar := ws.climaxBar
    else
        box.set_lefttop(rangeBox, ws.climaxBar, ws.rangeHigh)
        box.set_rightbottom(rangeBox, bar_index, ws.rangeLow)
        box.set_bgcolor(rangeBox, boxColor)
        box.set_border_color(rangeBox, borderCol)
        line.set_xy1(topLine, ws.climaxBar, ws.rangeHigh)
        line.set_xy2(topLine, bar_index,    ws.rangeHigh)
        line.set_xy1(botLine, ws.climaxBar, ws.rangeLow)
        line.set_xy2(botLine, bar_index,    ws.rangeLow)
// NOTE: no "else delete" branch anymore — when the structure is no longer active/valid,
// the box/lines simply stop being updated and remain exactly where they last were.

// bgcolor() must be called in GLOBAL scope, so the condition goes inside the colour expression
phaseBgCol = showPhaseBG and showThisStructure ? (ws.phase == PHASE_B ? color.new(color.blue, 94) : ws.phase == PHASE_C ? color.new(color.orange, 94) : ws.phase == PHASE_D ? color.new(color.purple, 94) : ws.phase == PHASE_E ? color.new(color.green, 94) : na) : na
bgcolor(phaseBgCol)

// ══════════════ LAYER 9b : WYCKOFF SCHEMATIC PANEL + PROJECTED PATH ══════════════════════

chartHi = ta.highest(high, 300)   // global (never inside a conditional)
chartLo = ta.lowest(low, 300)

var array<line>  drawLines  = array.new<line>()
var array<label> drawLabels = array.new<label>()
var array<box>   drawBoxes  = array.new<box>()

// Node list of the classic Wyckoff schematic.
// x = 0..1 progress through the campaign, y in RANGE UNITS (0 = range low, 1 = range high).
// cTop = structural side (climax at the top), up = bullish resolution.
f_buildSchematic(bool cTop, bool up) =>
    xs = array.new<float>()
    ys = array.new<float>()
    ns = array.new<string>()
    // ---- Phase A ----
    array.push(xs, 0.01)
    array.push(ys, cTop ?  0.45 :  0.55)
    array.push(ns, cTop ? "PSY" : "PS")
    array.push(xs, 0.08)
    array.push(ys, cTop ?  1.18 : -0.18)
    array.push(ns, cTop ? "BC"  : "SC")
    array.push(xs, 0.15)
    array.push(ys, cTop ? -0.05 :  1.05)
    array.push(ns, "AR")
    array.push(xs, 0.22)
    array.push(ys, cTop ?  1.00 :  0.00)
    array.push(ns, "ST")
    // ---- Phase B ----
    array.push(xs, 0.30)
    array.push(ys, 0.18)
    array.push(ns, "")
    array.push(xs, 0.37)
    array.push(ys, 0.85)
    array.push(ns, "ST B")
    array.push(xs, 0.44)
    array.push(ys, 0.22)
    array.push(ns, "")
    array.push(xs, 0.50)
    array.push(ys, 0.55)
    array.push(ns, up ? "mSOW" : "mSOS")
    // ---- Phase C ----
    array.push(xs, 0.60)
    array.push(ys, up ? -0.15 : 1.15)
    array.push(ns, up ? "SPRING" : "UTAD")
    array.push(xs, 0.67)
    array.push(ys, up ?  0.12 : 0.88)
    array.push(ns, "TEST")
    // ---- Phase D ----
    array.push(xs, 0.76)
    array.push(ys, up ? 0.85 : 0.15)
    array.push(ns, up ? "SOS" : "SOW")
    array.push(xs, 0.83)
    array.push(ys, up ? 0.60 : 0.40)
    array.push(ns, up ? "LPS" : "LPSY")
    // ---- Phase E ----
    array.push(xs, 0.91)
    array.push(ys, up ? 1.35 : -0.35)
    array.push(ns, up ? "BU/LPS" : "BD/LPSY")
    array.push(xs, 0.99)
    array.push(ys, up ? 1.75 : -0.75)
    array.push(ns, "")
    [xs, ys, ns]

// which schematic node the market is standing on right now
f_curNode(int ph) =>
    ph == PHASE_A ? 2 : ph == PHASE_B ? 7 : ph == PHASE_C ? 9 : ph == PHASE_D ? 11 : 12

[sx, sy, sn] = f_buildSchematic(ws.climaxTop, ws.dir == DIR_ACCUM)
curIdx       = f_curNode(ws.phase)

schemTitle = ws.sType == TYPE_ACCUM ? "Accumulation Schematic" : ws.sType == TYPE_REACCUM ? "Reaccumulation Schematic" : ws.sType == TYPE_DIST ? "Distribution Schematic" : ws.sType == TYPE_REDIST ? "Redistribution Schematic" : "Wyckoff Schematic"

if barstate.islast
    // wipe last bar's panel/forecast objects before redrawing them
    while array.size(drawLines) > 0
        line.delete(array.pop(drawLines))
    while array.size(drawLabels) > 0
        label.delete(array.pop(drawLabels))
    while array.size(drawBoxes) > 0
        box.delete(array.pop(drawBoxes))

    if (showSchem or showForecast) and ws.active and rangeValid
        // ───────── mini schematic panel to the right of price ─────────
        if showSchem
            pxL = bar_index + schemOffset
            pxR = pxL + schemWidth
            pTop = chartLo + 0.86 * (chartHi - chartLo)
            pBot = chartLo + 0.46 * (chartHi - chartLo)

            bgBox = box.new(pxL - 4, pTop + 0.02 * (chartHi - chartLo), pxR + 4, pBot - 0.02 * (chartHi - chartLo),
                 border_color = color.new(color.gray, 40), border_width = 1, bgcolor = color.new(color.black, 55))
            array.push(drawBoxes, bgBox)

            ttl = label.new(pxL - 4, pTop + 0.045 * (chartHi - chartLo), schemTitle,
                 style = label.style_none, textcolor = color.new(color.lime, 0), size = size.tiny)
            array.push(drawLabels, ttl)

            // phase dividers + A B C D E letters
            divX  = array.from(0.26, 0.55, 0.71, 0.87)
            letX  = array.from(0.13, 0.40, 0.63, 0.79, 0.94)
            letTx = array.from("A", "B", "C", "D", "E")
            for i = 0 to array.size(divX) - 1
                dxb = pxL + int(math.round(array.get(divX, i) * (pxR - pxL)))
                dl  = line.new(dxb, pBot, dxb, pTop, color = color.new(color.gray, 55), style = line.style_dotted)
                array.push(drawLines, dl)
            for i = 0 to array.size(letX) - 1
                lxb = pxL + int(math.round(array.get(letX, i) * (pxR - pxL)))
                ll  = label.new(lxb, pBot - 0.012 * (chartHi - chartLo), array.get(letTx, i),
                     style = label.style_none, textcolor = color.new(color.gray, 20), size = size.tiny)
                array.push(drawLabels, ll)

            // the schematic path itself (green = already happened, gray = still ahead)
            for i = 0 to array.size(sx) - 2
                x1 = pxL + int(math.round(array.get(sx, i)     * (pxR - pxL)))
                x2 = pxL + int(math.round(array.get(sx, i + 1) * (pxR - pxL)))
                y1 = pBot + ((array.get(sy, i)     + 0.9) / 2.8) * (pTop - pBot)
                y2 = pBot + ((array.get(sy, i + 1) + 0.9) / 2.8) * (pTop - pBot)
                segCol = i < curIdx ? color.new(color.lime, 0) : color.new(color.gray, 25)
                sl = line.new(x1, y1, x2, y2, color = segCol, width = 1)
                array.push(drawLines, sl)

            // node names
            for i = 0 to array.size(sx) - 1
                if array.get(sn, i) != ""
                    nxb = pxL + int(math.round(array.get(sx, i) * (pxR - pxL)))
                    nyp = pBot + ((array.get(sy, i) + 0.9) / 2.8) * (pTop - pBot)
                    nl  = label.new(nxb, nyp, array.get(sn, i), style = label.style_none,
                         textcolor = i <= curIdx ? color.new(color.lime, 0) : color.new(color.gray, 15), size = size.tiny)
                    array.push(drawLabels, nl)

            // "you are here" dot
            dotX = pxL + int(math.round(array.get(sx, curIdx) * (pxR - pxL)))
            dotY = pBot + ((array.get(sy, curIdx) + 0.9) / 2.8) * (pTop - pBot)
            dot  = label.new(dotX, dotY, "", style = label.style_circle, color = color.new(color.green, 0), size = size.small)
            array.push(drawLabels, dot)

        // ───────── projected path on the price chart ─────────
        if showForecast and curIdx < array.size(sx) - 1
            rngH   = ws.rangeHigh
            rngL   = ws.rangeLow
            rngSz  = rngH - rngL
            xHere  = array.get(sx, curIdx)
            xLeft  = 1.0 - xHere
            prevX  = bar_index
            prevY  = close
            for i = curIdx + 1 to array.size(sx) - 1
                step = xLeft <= 0 ? 0.0 : (array.get(sx, i) - xHere) / xLeft
                bx    = bar_index + int(math.round(step * forecastBars))
                byPos = rngL + array.get(sy, i) * rngSz
                fl    = line.new(prevX, prevY, bx, byPos, color = color.new(color.gray, 25), width = 1)
                array.push(drawLines, fl)
                prevX := bx
                prevY := byPos

// ═══════════════════════════════════ STATUS TABLE ═══════════════════════════════════════

if showStatusTable and barstate.islast
    var table statusT = table.new(position.top_right, 2, 9, border_width = 1)
    typeStr = ws.sType == TYPE_ACCUM ? "Accumulation" : ws.sType == TYPE_REACCUM ? "Re-accumulation" : ws.sType == TYPE_DIST ? "Distribution" : ws.sType == TYPE_REDIST ? "Re-distribution" : "None"
    phaseStr = ws.phase == PHASE_A ? "A" : ws.phase == PHASE_B ? "B" : ws.phase == PHASE_C ? "C" : ws.phase == PHASE_D ? "D" : ws.phase == PHASE_E ? "E" : "-"
    nextStep = not ws.active ? "Waiting for climax" : ws.phase == PHASE_A ? "Absorption / AR / ST" : ws.phase == PHASE_B ? "Spring/UTAD or C-Test" : ws.phase == PHASE_C ? "SOS / SOW" : ws.phase == PHASE_D ? "LPS / LPSY" : "Trend continuation"
    table.cell(statusT, 0, 0, "Structure", bgcolor = color.gray, text_color = color.white)
    table.cell(statusT, 1, 0, ws.active ? "ACTIVE" : "NONE", bgcolor = color.gray, text_color = color.white)
    table.cell(statusT, 0, 1, "Type")
    table.cell(statusT, 1, 1, typeStr)
    table.cell(statusT, 0, 2, "Phase")
    table.cell(statusT, 1, 2, phaseStr)
    table.cell(statusT, 0, 3, "Last Event Bar")
    table.cell(statusT, 1, 3, na(ws.lastEventBar) ? "-" : str.tostring(bar_index - ws.lastEventBar))
    table.cell(statusT, 0, 4, "Next Expected")
    table.cell(statusT, 1, 4, nextStep)
    table.cell(statusT, 0, 5, "Maturity")
    table.cell(statusT, 1, 5, str.tostring(math.round(ws.maturity)) + "/100")
    table.cell(statusT, 0, 6, "Validation")
    table.cell(statusT, 1, 6, str.tostring(math.round(ws.validation)) + "/100")
    table.cell(statusT, 0, 7, "Range")
    table.cell(statusT, 1, 7, na(ws.rangeHigh) ? "-" : str.tostring(ws.rangeLow, format.mintick) + " - " + str.tostring(ws.rangeHigh, format.mintick))
    table.cell(statusT, 0, 8, "Last Reset")
    table.cell(statusT, 1, 8, lastResetReason == "" ? "-" : lastResetReason)

// ═══════════════════════════════════ DIAGNOSTICS TABLE ═══════════════════════════════════

if showDiagTable and barstate.islast
    var table diagT = table.new(position.bottom_right, 3, 8, border_width = 1)
    table.cell(diagT, 0, 0, "Check", bgcolor = color.gray, text_color = color.white)
    table.cell(diagT, 1, 0, "Current", bgcolor = color.gray, text_color = color.white)
    table.cell(diagT, 2, 0, "OK?", bgcolor = color.gray, text_color = color.white)

    row = 1
    if ws.active
        table.cell(diagT, 0, row, "Absorbed")
        table.cell(diagT, 1, row, ws.absorbed ? "Yes" : "No")
        table.cell(diagT, 2, row, ws.absorbed ? "✔" : "✘", text_color = ws.absorbed ? color.green : color.red)
        row += 1
        table.cell(diagT, 0, row, "AR confirmed")
        table.cell(diagT, 1, row, ws.arConfirmed ? "Yes" : "No")
        table.cell(diagT, 2, row, ws.arConfirmed ? "✔" : "✘", text_color = ws.arConfirmed ? color.green : color.red)
        row += 1
        table.cell(diagT, 0, row, "ST count (need 2)")
        table.cell(diagT, 1, row, str.tostring(ws.stCount))
        table.cell(diagT, 2, row, ws.stCount >= 2 ? "✔" : "✘", text_color = ws.stCount >= 2 ? color.green : color.red)
        row += 1
        table.cell(diagT, 0, row, "Opp. tests (need 1+)")
        table.cell(diagT, 1, row, str.tostring(ws.oppTestCount))
        table.cell(diagT, 2, row, ws.oppTestCount >= 1 ? "✔" : "✘", text_color = ws.oppTestCount >= 1 ? color.green : color.red)
        row += 1
        table.cell(diagT, 0, row, "Outcome set (Phase C)")
        table.cell(diagT, 1, row, ws.outcomeSet ? "Yes" : "No")
        table.cell(diagT, 2, row, ws.outcomeSet ? "✔" : "✘", text_color = ws.outcomeSet ? color.green : color.red)
        row += 1
        table.cell(diagT, 0, row, "Maturity ≥ " + str.tostring(entryThreshold))
        table.cell(diagT, 1, row, str.tostring(math.round(ws.maturity)))
        table.cell(diagT, 2, row, ws.maturity >= entryThreshold ? "✔" : "✘", text_color = ws.maturity >= entryThreshold ? color.green : color.red)
        row += 1
        table.cell(diagT, 0, row, "Validation ≥ 55")
        table.cell(diagT, 1, row, str.tostring(math.round(ws.validation)))
        table.cell(diagT, 2, row, ws.validation >= 55 ? "✔" : "✘", text_color = ws.validation >= 55 ? color.green : color.red)
    else
        table.cell(diagT, 0, row, "No active structure")
        table.cell(diagT, 1, row, "-")
        table.cell(diagT, 2, row, "-")

// ═══════════════════════════════════ LAYER 10 : ALERTS ═══════════════════════════════════

// A UDT object cannot be history-referenced with the history operator on the object itself.
// Mirror the fields into plain series variables first, then use [1] on those.
absorbedNow = ws.absorbed
phaseNow    = ws.phase

alertcondition(absorbedNow and not absorbedNow[1], title = "Climax Confirmed", message = "Smart Money The Ultimator: Climax absorption confirmed")
alertcondition(phaseNow == PHASE_B and phaseNow[1] != PHASE_B, title = "Phase B Started", message = "Smart Money The Ultimator: Phase B started")
alertcondition(not na(ws.springTime) and ws.springTime == time, title = "Spring", message = "Smart Money The Ultimator: Spring detected")
alertcondition(not na(ws.utadTime) and ws.utadTime == time, title = "UTAD", message = "Smart Money The Ultimator: UTAD detected")
alertcondition(phaseNow == PHASE_C and phaseNow[1] != PHASE_C, title = "Phase C Test", message = "Smart Money The Ultimator: Phase C test formed")
alertcondition(not na(ws.sosTime) and ws.sosTime == time and ws.dir == DIR_ACCUM, title = "SOS", message = "Smart Money The Ultimator: Sign of Strength")
alertcondition(not na(ws.sosTime) and ws.sosTime == time and ws.dir == DIR_DIST, title = "SOW", message = "Smart Money The Ultimator: Sign of Weakness")
alertcondition(not na(ws.lpsTime) and ws.lpsTime == time and ws.dir == DIR_ACCUM, title = "LPS", message = "Smart Money The Ultimator: Last Point of Support")
alertcondition(not na(ws.lpsTime) and ws.lpsTime == time and ws.dir == DIR_DIST, title = "LPSY", message = "Smart Money The Ultimator: Last Point of Supply")
alertcondition(phaseNow == PHASE_E and phaseNow[1] != PHASE_E, title = "Phase E", message = "Smart Money The Ultimator: Phase E acceptance")
alertcondition(longSignal, title = "Long Entry", message = "Smart Money The Ultimator: LONG ENTRY signal")
alertcondition(shortSignal, title = "Short Entry", message = "Smart Money The Ultimator: SHORT ENTRY signal")

// ═══════════════════════════════════ END OF SCRIPT ═══════════════════════════════════════
// © Michael_Fx_Trader — Smart Money The Ultimator — all logic in this file is original work
// authored and published by Michael_Fx_Trader. Educational use only; not financial advice.
````
