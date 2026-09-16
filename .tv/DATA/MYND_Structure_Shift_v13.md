<!-- tradingview-pine-id: PUB;c817c33f109a48a88552b45979ce4e39 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MYND Structure Shift v1.3

Source: https://www.tradingview.com/script/QG1psDXa-MYND-Structure-Shift-v1-3/

## Description

MYND Structure Shift [v1.3]

A market-structure tool: HH/HL/LH/LL swing labeling, Break of Structure (BOS) and Change of Character (CHoCH) detection, and a liquidity-sweep engine that only confirms a reversal once a swept swing point is followed by a genuine displacement candle and a volume spike - now with the signal-suppressing alignment gate turned into an informational tag, a grace period for confirmations, and a base-rate tally so frequency is tunable with real data.

WHAT IT DOES

This indicator tracks market structure the way price actually prints it: every confirmed swing high/low is classified as a Higher High, Higher Low, Lower High, or Lower Low, and every break of a swing level is tagged either BOS (continuation) or CHoCH (a potential structural reversal). Separately, a liquidity-sweep engine watches for wicks that pierce a swing point and close back inside it, and only treats it as a real signal once validated by a strong-range, strong-close, high-volume displacement candle within a confirmation window.

HOW IT WORKS

Swing points confirm once enough bars have passed on both sides. A close-based break of the most recent swing level is BOS if it agrees with standing structure bias, CHoCH if it reverses it. Independently, a wick piercing a swing point and closing back inside it opens a confirmation window (extended once by the Grace Period if it would otherwise expire without Invalidating); only a subsequent displacement candle within that window turns the sweep into a Confirmed Reversal, which as of v1.3 fires regardless of Structure Bias by default.

KEY FEATURES

A live dashboard showing Structure Bias, Last Break Event, Sweep Status (with a grace-used indicator), Last Sweep Outcome, Last Signal Quality, the new Sweep Outcome Tally, Equal High/Low context, and HTF Bias/prior levels. A "(vs Structure)" tag on any confirmed reversal that runs counter to the structural bias. Independent label size/color controls. Invisible signal-export plots for wiring into other MYND tools.

HOW TO USE IT

Only act on the BUY/SELL Confirmed Reversal triangle - note whether it's tagged "vs Structure" (countertrend, weigh accordingly). If signals still feel rare, check the Sweep Outcome Tally: a lot of Expired suggests loosening the displacement/volume/window thresholds; a lot of Invalidated suggests this ticker/timeframe may not suit the tool's sweep-and-reverse premise as well as others would.

SETTINGS WORTH TUNING FIRST

Enable Confirmation Grace Period / Grace Extension Bars - gives pending sweeps more room; watch the Tally to see the effect. Require Confirmed Reversal to Align With Structure Bias (Blocking) - off by default now, only turn on if you specifically want countertrend reversals blocked outright. Enable Signal Cooldown, Filter Out Low-Quality Signals - the remaining quality/noise levers, unchanged from v1.2.

WHAT THIS TOOL DELIBERATELY DOES NOT DO

Order Block and Fair Value Gap zones remain purely visual. The Setup Quality Score is a heuristic, not a backtested probability. The Sweep Outcome Tally counts from whenever the indicator was added or its inputs last changed - it's not a fixed historical backtest total.

ALERTS

16 alerts total, unchanged from v1.1/v1.2 - v1.3 changed which signals reach those alerts (by removing the blocking gate), not the alert types themselves.

FEEDBACK WELCOME

If you've tweaked a setting, found a combination with another indicator that works well, or have an idea for what would make this more useful, I'd genuinely like to hear about it - drop a comment below (it helps other users too), or send a direct message if you'd rather keep the details private.

This tool identifies patterns in past price, volume, and structure - it is not a guarantee of future performance. This tool is provided for informational and educational purposes and does not constitute financial advice. Trading involves risk; past performance and historical patterns do not guarantee future results.

---

## Source Code

````pine
//@version=6
indicator(title="MYND Structure Shift v1.3", shorttitle="MYND SS v1.3", overlay=true, max_lines_count=300, max_labels_count=300, max_boxes_count=100)

// =====================================================================================
// MYND STRUCTURE SHIFT v1.3
// Market structure (HH/HL/LH/LL) with Break of Structure (BOS, continuation) and Change
// of Character (CHoCH, reversal) detection, plus a liquidity-sweep engine that only
// confirms a reversal once a swept swing point is followed by a displacement candle and
// a volume spike within a set window. Equal-highs/lows liquidity pools and prior-period
// higher-timeframe levels add sweep-quality context. Optional Order Block / Fair Value
// Gap shading for visual reference. Part of the MYND swing-trading tool set (companion
// to Confluence Compass, Momentum Divergence Suite, and Volatility Regime Map).

// =====================================================================================

// ---------------------------------------------------------------------------
// INPUTS - STRUCTURE
// ---------------------------------------------------------------------------
grpStruct = "Structure"
structureLeftBars  = input.int(5, "Swing Left Bars", minval=1, group=grpStruct, tooltip="Bars to the left required to confirm a swing point.")
structureRightBars = input.int(5, "Swing Right Bars", minval=1, group=grpStruct, tooltip="Bars to the right required to confirm a swing point. This is also the confirmation lag.")

// ---------------------------------------------------------------------------
// INPUTS - SWEEP & DISPLACEMENT
// ---------------------------------------------------------------------------
grpSweep = "Sweep & Displacement"
atrLen                = input.int(14, "ATR Length (shared)", minval=1, group=grpSweep, tooltip="Shared ATR used for sweep pierce tolerance, displacement sizing, and equal-level / HTF-proximity tolerance.")
sweepMinPierceATRMult = input.float(0.05, "Minimum Sweep Pierce (x ATR)", minval=0, step=0.01, group=grpSweep, tooltip="How far beyond a swing point the wick must pierce before it counts as a sweep - filters out insignificant pierces.")
displacementATRMult   = input.float(1.2, "Displacement Candle Minimum Range (x ATR)", minval=0.1, step=0.1, group=grpSweep, tooltip="The confirming candle's total range must be at least this multiple of ATR.")
displacementClosePct  = input.float(0.25, "Displacement Candle Close Position", minval=0.05, maxval=0.5, step=0.05, group=grpSweep, tooltip="The confirming candle must close within this fraction of its own range from the favorable extreme (e.g. 0.25 = top/bottom 25%).")

// ---------------------------------------------------------------------------
// INPUTS - CONFIRMATION
// ---------------------------------------------------------------------------
grpConfirm = "Confirmation"
confirmWindowBars = input.int(5, "Confirmation Window (bars)", minval=1, group=grpConfirm, tooltip="A sweep must be followed by a qualifying displacement + volume candle within this many bars (same bar counts) or the setup expires. If price instead blows through the sweep's own extreme first, the setup is Invalidated rather than left to expire.")
volAvgLen          = input.int(20, "Volume Average Length", minval=1, group=grpConfirm)
volMultiplier       = input.float(1.3, "Volume Must Be At Least (x Average)", minval=0.1, step=0.1, group=grpConfirm)
enableConfirmationGrace = input.bool(true, "Enable Confirmation Grace Period", group=grpConfirm, tooltip="When a pending sweep's Confirmation Window would otherwise expire, grants ONE one-time extension (Grace Extension Bars) before it actually expires - as long as price hasn't Invalidated the setup. Targets setups that were resolving to Expired only because the window cut them off too early, not because they genuinely failed.")
graceExtensionBars      = input.int(5, "Grace Extension Bars", minval=1, group=grpConfirm, tooltip="How many extra bars the one-time grace extension grants. Only used when Enable Confirmation Grace Period is on.")

// ---------------------------------------------------------------------------
// INPUTS - SIGNAL QUALITY & NOISE REDUCTION (v1.1)
// ---------------------------------------------------------------------------
grpQuality = "Signal Quality & Noise Reduction"
requireChochAlignment   = input.bool(false, "Require Confirmed Reversal to Align With Structure Bias (Blocking)", group=grpQuality, tooltip="OFF by default as of v1.3 - live tests showed this blocked most signals outright, even with the Staleness Window. When OFF, a confirmed reversal always fires and is instead tagged '(vs Structure)' if it disagrees with Structure Bias (informational, not blocking). Turn ON to restore the stricter v1.1/v1.2 behavior of blocking a countertrend reversal while the opposing bias is still fresh (per the Staleness Window below).")
enableQualityScore      = input.bool(true, "Show Setup Quality Score", group=grpQuality, tooltip="Grades each confirmed reversal 0-100 from sweep pierce depth, displacement strength, volume multiple, and HTF alignment. Display only unless the filter below is also enabled.")
enableQualityFilter     = input.bool(false, "Filter Out Low-Quality Signals", group=grpQuality, tooltip="When on, a confirmed reversal scoring below the minimum is blocked entirely rather than just flagged. Review typical scores with the score display first before enabling this.")
minQualityScoreToSignal = input.int(50, "Minimum Quality Score to Signal", minval=0, maxval=100, group=grpQuality, tooltip="Only used when 'Filter Out Low-Quality Signals' is on.")
enableSignalCooldown    = input.bool(true, "Enable Signal Cooldown", group=grpQuality, tooltip="Blocks a new confirmed reversal in the same direction within the cooldown window of the last one, to cut back-to-back whipsaw signals in choppy stretches.")
signalCooldownBars      = input.int(10, "Cooldown Bars", minval=1, group=grpQuality)
structureStalenessBars  = input.int(20, "Structure Staleness Window (bars)", minval=1, group=grpQuality, tooltip="'Require Confirmed Reversal to Align With Structure Bias' only blocks a countertrend reversal while the opposing bias is fresh - i.e. a break happened within this many bars. Once the standing bias hasn't been reinforced by any break in longer than this, it's treated as stale and no longer blocks the reversal. Set very high (e.g. 9999) to restore the strict always-must-already-agree v1.1 behavior.")

// ---------------------------------------------------------------------------
// INPUTS - LIQUIDITY POOLS & HTF CONTEXT
// ---------------------------------------------------------------------------
grpLiq = "Liquidity Pools & HTF Context"
eqToleranceATRMult      = input.float(0.15, "Equal Level Tolerance (x ATR)", minval=0.01, step=0.01, group=grpLiq, tooltip="Two swing points within this distance of each other are tagged as an Equal High/Low liquidity pool. Also used as the HTF-level proximity tolerance.")
htfTF                    = input.timeframe("D", "Higher Timeframe (prior H/L + bias context)", group=grpLiq)
requireHTFProximity     = input.bool(false, "Require Sweep Near Prior HTF High/Low", group=grpLiq, tooltip="When on, only sweeps that occur near the prior HTF period's high (for sweep-highs) or low (for sweep-lows) start a confirmation watch. Classic 'sweep the prior day/week high' setups.")
requireHTFBiasAgreement = input.bool(false, "Require Confirmed Reversal to Not Fight HTF Bias", group=grpLiq, tooltip="When on, a confirmed bullish reversal is blocked if the higher timeframe is clearly bearish (and vice versa).")
requireHTFBiasSlope     = input.bool(true, "Require HTF EMA Slope to Confirm Bias", group=grpLiq, tooltip="HTF Bias used to flip on a bare price-vs-EMA50 sign, which is noisy right at the EMA. When on, also requires the HTF EMA itself to be rising (for UP) or falling (for DOWN) before HTF Bias counts as anything but FLAT.")
requireHTFAdxFloor      = input.bool(true, "Require HTF ADX Minimum for Bias", group=grpLiq, tooltip="Requires the higher timeframe's own ADX to clear this floor before HTF Bias counts as UP/DOWN, instead of FLAT.")
htfAdxMin               = input.float(20, "HTF ADX Minimum", minval=0, step=1, group=grpLiq)

// ---------------------------------------------------------------------------
// INPUTS - VISUAL
// ---------------------------------------------------------------------------
grpVis = "Visual"
showStructureLabels = input.bool(true, "Show HH/HL/LH/LL Labels", group=grpVis)
showSweepMarkers     = input.bool(true, "Show Sweep / Confirmed Markers", group=grpVis)
showEqualLevels      = input.bool(true, "Show Equal High/Low Lines", group=grpVis)
showOrderBlocks      = input.bool(false, "Show Order Block Zones", group=grpVis)
showFVG              = input.bool(false, "Show Fair Value Gap Zones", group=grpVis)
enableCompactLabels  = input.bool(true, "Compact/Merge Overlapping Labels", group=grpVis, tooltip="Merges HH/LH/HL/LL labels with EQH/EQL labels when a swing point is both, instead of stacking two separate labels on the same point.")
showPendingSweepLabels = input.bool(false, "Show Pending SWEEP Labels", group=grpVis, tooltip="v1.1 always showed the orange 'SWEEP' label the moment a sweep is detected, awaiting confirmation. Off by default in v1.2 to declutter - the eventual outcome (a BUY/SELL triangle, or a gray INVALID label) still always shows. Turn on to restore the v1.1 behavior of also seeing every pending attempt.")
enableLabelSpacing   = input.bool(true, "Thin Structure Labels in Fast Chop", group=grpVis, tooltip="Suppresses a new HH/HL/LH/LL (and merged EQH/EQL) label if the last one of that type was drawn less than 'Minimum Label Spacing' bars ago - visual thinning only, does not change the underlying swing/structure calculations or any signal logic. Turn off to always show every label like v1.1 did.")
minLabelSpacingBars  = input.int(3, "Minimum Label Spacing (bars)", minval=1, group=grpVis)
labelSizeStructure   = input.string("Tiny", "Structure Label Size (HH/HL/LH/LL/EQH/EQL)", options=["Tiny","Small","Normal","Large"], group=grpVis)
labelSizeBreak       = input.string("Small", "Break Label Size (BOS/CHoCH)", options=["Tiny","Small","Normal","Large"], group=grpVis)
labelSizeSweep       = input.string("Small", "Sweep/Signal Label Size (SWEEP/INVALID/BUY/SELL)", options=["Tiny","Small","Normal","Large"], group=grpVis)
colInvalid           = input.color(color.new(color.gray, 30), "Invalidated Color", group=grpVis)
showTable            = input.bool(true, "Show Dashboard Table", group=grpVis)
tablePos             = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpVis)
tableSize            = input.string("Small", "Table Text Size", options=["Tiny","Small","Normal"], group=grpVis)
colBull              = input.color(color.new(color.lime, 0), "Bullish Color", group=grpVis)
colBear              = input.color(color.new(color.red, 0), "Bearish Color", group=grpVis)
colWarn              = input.color(color.new(color.orange, 0), "Sweep-Pending / Warning Color", group=grpVis)
colEqual             = input.color(color.new(color.purple, 0), "Equal-Level Color", group=grpVis)

// ---------------------------------------------------------------------------
// INPUTS - CROSS-TOOL SIGNAL EXPORT (v1.2)
// ---------------------------------------------------------------------------
grpExport = "Cross-Tool Signal Export"
enableSignalExport = input.bool(true, "Export Signals for Other Indicators (input.source())", group=grpExport, tooltip="Adds invisible plots (display=None on this chart) of CHoCH Bull/Bear, Confirmed Reversal Bull/Bear, and Structure Bias, so another indicator's input.source() can reference this tool's signals directly - e.g. feeding CHoCH into a Multi-Signal Exit Confluence Scorer.")

// ---------------------------------------------------------------------------
// SHARED SERIES (computed unconditionally every bar - avoids conditional history-call warnings)
// ---------------------------------------------------------------------------
atrVal = ta.atr(atrLen)
avgVol = ta.sma(volume, volAvgLen)
pierceDenom = math.max(sweepMinPierceATRMult, 0.01) * 3

sizeStructure = labelSizeStructure == "Tiny" ? size.tiny : labelSizeStructure == "Small" ? size.small : labelSizeStructure == "Normal" ? size.normal : size.large
sizeBreak     = labelSizeBreak == "Tiny" ? size.tiny : labelSizeBreak == "Small" ? size.small : labelSizeBreak == "Normal" ? size.normal : size.large
sizeSweep     = labelSizeSweep == "Tiny" ? size.tiny : labelSizeSweep == "Small" ? size.small : labelSizeSweep == "Normal" ? size.normal : size.large

htfPriorHigh = request.security(syminfo.tickerid, htfTF, high[1])
htfPriorLow  = request.security(syminfo.tickerid, htfTF, low[1])
htfBiasDiff  = request.security(syminfo.tickerid, htfTF, close - ta.ema(close, 50))
htfEmaVal    = request.security(syminfo.tickerid, htfTF, ta.ema(close, 50))
[_, _, htfAdx] = request.security(syminfo.tickerid, htfTF, ta.dmi(14, 14))

htfBiasUpRaw   = htfBiasDiff > 0
htfBiasDownRaw = htfBiasDiff < 0
htfSlopeOkUp   = not requireHTFBiasSlope or htfEmaVal > htfEmaVal[1]
htfSlopeOkDown = not requireHTFBiasSlope or htfEmaVal < htfEmaVal[1]
htfAdxOk       = not requireHTFAdxFloor or htfAdx >= htfAdxMin
htfBiasUp      = htfBiasUpRaw and htfSlopeOkUp and htfAdxOk
htfBiasDown    = htfBiasDownRaw and htfSlopeOkDown and htfAdxOk

barRange = high - low
closePos = barRange > 0 ? (close - low) / barRange : 0.5

displacementBull = barRange >= displacementATRMult * atrVal and closePos >= (1 - displacementClosePct) and close > open
displacementBear = barRange >= displacementATRMult * atrVal and closePos <= displacementClosePct and close < open
volumeOk          = volume >= volMultiplier * avgVol

// ---------------------------------------------------------------------------
// PIVOTS
// ---------------------------------------------------------------------------
ph = ta.pivothigh(high, structureLeftBars, structureRightBars)
pl = ta.pivotlow(low, structureLeftBars, structureRightBars)

// ---------------------------------------------------------------------------
// STRUCTURE STATE (persisted)
// ---------------------------------------------------------------------------
var float swingHigh      = na
var int   swingHighBar   = na
var bool  swingHighIsEQH = false
var float swingLow       = na
var int   swingLowBar    = na
var bool  swingLowIsEQL  = false
var int   structBias     = 0

var string lastEventText = "-"
var int    lastEventBar  = na

var int lastHighLabelBar = na
var int lastLowLabelBar  = na

// ---------------------------------------------------------------------------
// STEP 1: BREAK DETECTION (uses the swing levels as they stood BEFORE any new
// pivot confirms this bar, so a break is always judged against an already-
// established level).
// ---------------------------------------------------------------------------
breakAboveHigh = ta.crossover(close, swingHigh)
breakBelowLow  = ta.crossunder(close, swingLow)

bosBull   = false
bosBear   = false
chochBull = false
chochBear = false

if breakAboveHigh
    isBOS = structBias == 1
    isCHoCH = structBias == -1
    bosBull   := isBOS
    chochBull := isCHoCH
    if showSweepMarkers
        label.new(bar_index, swingHigh, isCHoCH ? "CHoCH" : (isBOS ? "BOS" : "Structure"), style=label.style_label_down, textcolor=color.white, color=colBull, size=sizeBreak)
        line.new(swingHighBar, swingHigh, bar_index, swingHigh, color=colBull, style=isCHoCH ? line.style_dashed : line.style_solid, width=2)
    lastEventText := isCHoCH ? "CHoCH Bull" : isBOS ? "BOS Bull" : "Structure Est. (Bull)"
    lastEventBar  := bar_index
    structBias := 1

if breakBelowLow
    isBOS2 = structBias == -1
    isCHoCH2 = structBias == 1
    bosBear   := isBOS2
    chochBear := isCHoCH2
    if showSweepMarkers
        label.new(bar_index, swingLow, isCHoCH2 ? "CHoCH" : (isBOS2 ? "BOS" : "Structure"), style=label.style_label_up, textcolor=color.white, color=colBear, size=sizeBreak)
        line.new(swingLowBar, swingLow, bar_index, swingLow, color=colBear, style=isCHoCH2 ? line.style_dashed : line.style_solid, width=2)
    lastEventText := isCHoCH2 ? "CHoCH Bear" : isBOS2 ? "BOS Bear" : "Structure Est. (Bear)"
    lastEventBar  := bar_index
    structBias := -1

structAlignedBull = structBias == 1
structAlignedBear = structBias == -1

barsSinceLastBreak      = na(lastEventBar) ? 999999 : bar_index - lastEventBar
structureStale          = barsSinceLastBreak >= structureStalenessBars
structAlignedOrStaleBull = structAlignedBull or structureStale
structAlignedOrStaleBear = structAlignedBear or structureStale

// ---------------------------------------------------------------------------
// STEP 2: UPDATE SWING RECORD FROM NEW PIVOTS (HH/HL/LH/LL + Equal Levels)
// ---------------------------------------------------------------------------
eqHighDetected = false
eqLowDetected  = false

if not na(ph)
    newHighBar = bar_index - structureRightBars
    newHighVal = ph
    isHH = not na(swingHigh) and newHighVal > swingHigh
    isLH = not na(swingHigh) and newHighVal < swingHigh
    eqHighDetected := not na(swingHigh) and math.abs(newHighVal - swingHigh) <= eqToleranceATRMult * atrVal
    swingTypeTextH = isHH ? "HH" : isLH ? "LH" : ""

    if showEqualLevels and eqHighDetected
        line.new(swingHighBar, swingHigh, newHighBar, newHighVal, color=colEqual, style=line.style_dotted, width=1)

    skipHighLabel = enableLabelSpacing and not na(lastHighLabelBar) and (newHighBar - lastHighLabelBar) < minLabelSpacingBars

    if enableCompactLabels
        combinedTextH  = swingTypeTextH != "" and eqHighDetected ? swingTypeTextH + " EQH" : eqHighDetected ? "EQH" : swingTypeTextH
        combinedColorH = eqHighDetected ? colEqual : (isHH ? colBull : colBear)
        if showStructureLabels and combinedTextH != "" and not skipHighLabel
            label.new(newHighBar, newHighVal, combinedTextH, style=label.style_label_down, color=color.new(color.gray, 100), textcolor=combinedColorH, size=sizeStructure)
            lastHighLabelBar := newHighBar
    else
        if showStructureLabels and (isHH or isLH) and not skipHighLabel
            label.new(newHighBar, newHighVal, isHH ? "HH" : "LH", style=label.style_label_down, color=color.new(color.gray, 100), textcolor=isHH ? colBull : colBear, size=sizeStructure)
            lastHighLabelBar := newHighBar
        if showEqualLevels and eqHighDetected and not skipHighLabel
            label.new(newHighBar, newHighVal, "EQH", style=label.style_label_down, color=color.new(color.gray, 100), textcolor=colEqual, size=sizeStructure)
            lastHighLabelBar := newHighBar

    swingHigh      := newHighVal
    swingHighBar   := newHighBar
    swingHighIsEQH := eqHighDetected

if not na(pl)
    newLowBar = bar_index - structureRightBars
    newLowVal = pl
    isHL = not na(swingLow) and newLowVal > swingLow
    isLL = not na(swingLow) and newLowVal < swingLow
    eqLowDetected := not na(swingLow) and math.abs(newLowVal - swingLow) <= eqToleranceATRMult * atrVal
    swingTypeTextL = isHL ? "HL" : isLL ? "LL" : ""

    if showEqualLevels and eqLowDetected
        line.new(swingLowBar, swingLow, newLowBar, newLowVal, color=colEqual, style=line.style_dotted, width=1)

    skipLowLabel = enableLabelSpacing and not na(lastLowLabelBar) and (newLowBar - lastLowLabelBar) < minLabelSpacingBars

    if enableCompactLabels
        combinedTextL  = swingTypeTextL != "" and eqLowDetected ? swingTypeTextL + " EQL" : eqLowDetected ? "EQL" : swingTypeTextL
        combinedColorL = eqLowDetected ? colEqual : (isHL ? colBull : colBear)
        if showStructureLabels and combinedTextL != "" and not skipLowLabel
            label.new(newLowBar, newLowVal, combinedTextL, style=label.style_label_up, color=color.new(color.gray, 100), textcolor=combinedColorL, size=sizeStructure)
            lastLowLabelBar := newLowBar
    else
        if showStructureLabels and (isHL or isLL) and not skipLowLabel
            label.new(newLowBar, newLowVal, isHL ? "HL" : "LL", style=label.style_label_up, color=color.new(color.gray, 100), textcolor=isHL ? colBull : colBear, size=sizeStructure)
            lastLowLabelBar := newLowBar
        if showEqualLevels and eqLowDetected and not skipLowLabel
            label.new(newLowBar, newLowVal, "EQL", style=label.style_label_up, color=color.new(color.gray, 100), textcolor=colEqual, size=sizeStructure)
            lastLowLabelBar := newLowBar

    swingLow      := newLowVal
    swingLowBar   := newLowBar
    swingLowIsEQL := eqLowDetected

// ---------------------------------------------------------------------------
// STEP 3: LIQUIDITY SWEEP DETECTION (uses the freshest swing levels, post-update)
// ---------------------------------------------------------------------------
nearHTFHighLevel = not na(htfPriorHigh) and math.abs(high - htfPriorHigh) <= eqToleranceATRMult * atrVal
nearHTFLowLevel  = not na(htfPriorLow)  and math.abs(low  - htfPriorLow)  <= eqToleranceATRMult * atrVal

sweepHigh = not na(swingHigh) and high > swingHigh + sweepMinPierceATRMult * atrVal and close < swingHigh
sweepLow  = not na(swingLow)  and low  < swingLow  - sweepMinPierceATRMult * atrVal and close > swingLow

sweepHighQualifies = sweepHigh and (not requireHTFProximity or nearHTFHighLevel)
sweepLowQualifies  = sweepLow  and (not requireHTFProximity or nearHTFLowLevel)

// ---------------------------------------------------------------------------
// STEP 4: CONFIRMATION STATE MACHINE (confirm / invalidate / expire)
// ---------------------------------------------------------------------------
var bool  awaitingBull        = false
var int   awaitBullLeft       = 0
var float awaitBullExtreme    = na
var float awaitBullPierceATR  = na
var bool  bullGraceUsed       = false
var bool  awaitingBear        = false
var int   awaitBearLeft       = 0
var float awaitBearExtreme    = na
var float awaitBearPierceATR  = na
var bool  bearGraceUsed       = false

var int tallyConfirmedBull   = 0
var int tallyConfirmedBear   = 0
var int tallyInvalidatedBull = 0
var int tallyInvalidatedBear = 0
var int tallyExpiredBull     = 0
var int tallyExpiredBear     = 0

var int   lastBullSignalBar   = na
var int   lastBearSignalBar   = na

var float lastQualityScoreBull    = na
var int   lastQualityScoreBullBar = na
var float lastQualityScoreBear    = na
var int   lastQualityScoreBearBar = na

var int   lastSweepOutcomeCode = 0   // 0=none,1=ConfBull,2=ConfBear,3=InvalBull,4=InvalBear,5=ExpBull,6=ExpBear
var int   lastSweepOutcomeBar  = na

var string lastBlockedText = "-"
var int    lastBlockedBar  = na

confirmedBull   = false
confirmedBear   = false
invalidatedBull = false
invalidatedBear = false

if sweepLowQualifies
    awaitingBull       := true
    awaitBullLeft      := confirmWindowBars
    awaitBullExtreme   := low
    awaitBullPierceATR := atrVal > 0 ? (swingLow - low) / atrVal : 0.0
    bullGraceUsed      := false
    if showSweepMarkers and showPendingSweepLabels
        label.new(bar_index, low, "SWEEP", style=label.style_label_up, color=colWarn, textcolor=color.white, size=sizeSweep)

if sweepHighQualifies
    awaitingBear       := true
    awaitBearLeft      := confirmWindowBars
    awaitBearExtreme   := high
    awaitBearPierceATR := atrVal > 0 ? (high - swingHigh) / atrVal : 0.0
    bearGraceUsed      := false
    if showSweepMarkers and showPendingSweepLabels
        label.new(bar_index, high, "SWEEP", style=label.style_label_down, color=colWarn, textcolor=color.white, size=sizeSweep)

if awaitingBull
    if displacementBull and volumeOk
        confirmedBull := true
        awaitingBull  := false
        pierceSubBull  = math.min(awaitBullPierceATR / pierceDenom, 1.0)
        dispSubBull    = math.min((barRange / atrVal) / (displacementATRMult * 1.5), 1.0)
        volSubBull     = avgVol > 0 ? math.min((volume / avgVol) / (volMultiplier * 1.5), 1.0) : 0.5
        htfSubBull     = htfBiasUp ? 1.0 : htfBiasDown ? 0.0 : 0.5
        lastQualityScoreBull    := (pierceSubBull + dispSubBull + volSubBull + htfSubBull) / 4 * 100
        lastQualityScoreBullBar := bar_index
        lastSweepOutcomeCode    := 1
        lastSweepOutcomeBar     := bar_index
        tallyConfirmedBull      += 1
    else if close < awaitBullExtreme
        invalidatedBull       := true
        awaitingBull          := false
        lastSweepOutcomeCode  := 3
        lastSweepOutcomeBar   := bar_index
        tallyInvalidatedBull  += 1
        if showSweepMarkers
            label.new(bar_index, low, "INVALID", style=label.style_label_up, color=colInvalid, textcolor=color.white, size=sizeSweep)
    else
        awaitBullLeft -= 1
        if awaitBullLeft <= 0
            if enableConfirmationGrace and not bullGraceUsed
                awaitBullLeft := graceExtensionBars
                bullGraceUsed := true
            else
                awaitingBull         := false
                lastSweepOutcomeCode := 5
                lastSweepOutcomeBar  := bar_index
                tallyExpiredBull     += 1

if awaitingBear
    if displacementBear and volumeOk
        confirmedBear := true
        awaitingBear  := false
        pierceSubBear  = math.min(awaitBearPierceATR / pierceDenom, 1.0)
        dispSubBear    = math.min((barRange / atrVal) / (displacementATRMult * 1.5), 1.0)
        volSubBear     = avgVol > 0 ? math.min((volume / avgVol) / (volMultiplier * 1.5), 1.0) : 0.5
        htfSubBear     = htfBiasDown ? 1.0 : htfBiasUp ? 0.0 : 0.5
        lastQualityScoreBear    := (pierceSubBear + dispSubBear + volSubBear + htfSubBear) / 4 * 100
        lastQualityScoreBearBar := bar_index
        lastSweepOutcomeCode    := 2
        lastSweepOutcomeBar     := bar_index
        tallyConfirmedBear      += 1
    else if close > awaitBearExtreme
        invalidatedBear       := true
        awaitingBear          := false
        lastSweepOutcomeCode  := 4
        lastSweepOutcomeBar   := bar_index
        tallyInvalidatedBear  += 1
        if showSweepMarkers
            label.new(bar_index, high, "INVALID", style=label.style_label_down, color=colInvalid, textcolor=color.white, size=sizeSweep)
    else
        awaitBearLeft -= 1
        if awaitBearLeft <= 0
            if enableConfirmationGrace and not bearGraceUsed
                awaitBearLeft := graceExtensionBars
                bearGraceUsed := true
            else
                awaitingBear         := false
                lastSweepOutcomeCode := 6
                lastSweepOutcomeBar  := bar_index
                tallyExpiredBear     += 1

cooldownOkBull = not enableSignalCooldown or na(lastBullSignalBar) or (bar_index - lastBullSignalBar) >= signalCooldownBars
cooldownOkBear = not enableSignalCooldown or na(lastBearSignalBar) or (bar_index - lastBearSignalBar) >= signalCooldownBars

confirmedBullReversal = confirmedBull and (not requireHTFBiasAgreement or not htfBiasDown) and (not requireChochAlignment or structAlignedOrStaleBull) and (not enableQualityFilter or lastQualityScoreBull >= minQualityScoreToSignal) and cooldownOkBull
confirmedBearReversal = confirmedBear and (not requireHTFBiasAgreement or not htfBiasUp) and (not requireChochAlignment or structAlignedOrStaleBear) and (not enableQualityFilter or lastQualityScoreBear >= minQualityScoreToSignal) and cooldownOkBear

if confirmedBullReversal
    lastBullSignalBar := bar_index
if confirmedBearReversal
    lastBearSignalBar := bar_index

// v1.3: tag (don't block, unless requireChochAlignment is manually turned back on) a
// confirmed reversal that disagrees with the current Structure Bias.
countertrendBull = confirmedBullReversal and structBias == -1
countertrendBear = confirmedBearReversal and structBias == 1

if showSweepMarkers and countertrendBull
    label.new(bar_index, low, "vs Structure", style=label.style_label_up, color=color.new(colWarn, 20), textcolor=color.white, size=sizeSweep)
if showSweepMarkers and countertrendBear
    label.new(bar_index, high, "vs Structure", style=label.style_label_down, color=color.new(colWarn, 20), textcolor=color.white, size=sizeSweep)

// ---------------------------------------------------------------------------
// STEP 4b: WHY DIDN'T A RAW CONFIRMATION BECOME A VISIBLE SIGNAL (v1.2)
// ---------------------------------------------------------------------------
if confirmedBull and not confirmedBullReversal
    reasonBull = ""
    if requireChochAlignment and not structAlignedOrStaleBull
        reasonBull := reasonBull + (reasonBull == "" ? "" : "+") + "Structure"
    if requireHTFBiasAgreement and htfBiasDown
        reasonBull := reasonBull + (reasonBull == "" ? "" : "+") + "HTF"
    if enableQualityFilter and lastQualityScoreBull < minQualityScoreToSignal
        reasonBull := reasonBull + (reasonBull == "" ? "" : "+") + "Quality"
    if not cooldownOkBull
        reasonBull := reasonBull + (reasonBull == "" ? "" : "+") + "Cooldown"
    lastBlockedText := "Bull blocked (" + reasonBull + ")"
    lastBlockedBar  := bar_index

if confirmedBear and not confirmedBearReversal
    reasonBear = ""
    if requireChochAlignment and not structAlignedOrStaleBear
        reasonBear := reasonBear + (reasonBear == "" ? "" : "+") + "Structure"
    if requireHTFBiasAgreement and htfBiasUp
        reasonBear := reasonBear + (reasonBear == "" ? "" : "+") + "HTF"
    if enableQualityFilter and lastQualityScoreBear < minQualityScoreToSignal
        reasonBear := reasonBear + (reasonBear == "" ? "" : "+") + "Quality"
    if not cooldownOkBear
        reasonBear := reasonBear + (reasonBear == "" ? "" : "+") + "Cooldown"
    lastBlockedText := "Bear blocked (" + reasonBear + ")"
    lastBlockedBar  := bar_index

// ---------------------------------------------------------------------------
// STEP 5: OPTIONAL ORDER BLOCK / FVG VISUAL ZONES
// ---------------------------------------------------------------------------
fvgBull = low > high[2]
fvgBear = high < low[2]
obBull  = displacementBull and close[1] < open[1]
obBear  = displacementBear and close[1] > open[1]

if showFVG and fvgBull
    box.new(bar_index[2], low, bar_index, high[2], border_color=color.new(colBull, 60), bgcolor=color.new(colBull, 88), extend=extend.none)
if showFVG and fvgBear
    box.new(bar_index[2], low[2], bar_index, high, border_color=color.new(colBear, 60), bgcolor=color.new(colBear, 88), extend=extend.none)

if showOrderBlocks and obBull
    box.new(bar_index[1], high[1], bar_index[1] + 20, low[1], border_color=color.new(colBull, 50), bgcolor=color.new(colBull, 90), extend=extend.none)
if showOrderBlocks and obBear
    box.new(bar_index[1], high[1], bar_index[1] + 20, low[1], border_color=color.new(colBear, 50), bgcolor=color.new(colBear, 90), extend=extend.none)

// ---------------------------------------------------------------------------
// PLOTS
// ---------------------------------------------------------------------------
// plotshape()'s size= parameter requires a compile-time "const string" - it cannot accept
// sizeSweep (an "input string" variable), unlike label.new()'s size= which accepts it fine.
// Standard Pine workaround: one call per size option, each gated so only the one matching
// the current Sweep/Signal Label Size input ever actually plots on a given bar.
plotshape(showSweepMarkers and confirmedBullReversal and labelSizeSweep == "Tiny",   title="Confirmed Bullish Reversal (Tiny)",   style=shape.triangleup,   location=location.belowbar, color=colBull, size=size.tiny,   text="BUY")
plotshape(showSweepMarkers and confirmedBullReversal and labelSizeSweep == "Small",  title="Confirmed Bullish Reversal (Small)",  style=shape.triangleup,   location=location.belowbar, color=colBull, size=size.small,  text="BUY")
plotshape(showSweepMarkers and confirmedBullReversal and labelSizeSweep == "Normal", title="Confirmed Bullish Reversal (Normal)", style=shape.triangleup,   location=location.belowbar, color=colBull, size=size.normal, text="BUY")
plotshape(showSweepMarkers and confirmedBullReversal and labelSizeSweep == "Large",  title="Confirmed Bullish Reversal (Large)",  style=shape.triangleup,   location=location.belowbar, color=colBull, size=size.large,  text="BUY")
plotshape(showSweepMarkers and confirmedBearReversal and labelSizeSweep == "Tiny",   title="Confirmed Bearish Reversal (Tiny)",   style=shape.triangledown, location=location.abovebar, color=colBear, size=size.tiny,   text="SELL")
plotshape(showSweepMarkers and confirmedBearReversal and labelSizeSweep == "Small",  title="Confirmed Bearish Reversal (Small)",  style=shape.triangledown, location=location.abovebar, color=colBear, size=size.small,  text="SELL")
plotshape(showSweepMarkers and confirmedBearReversal and labelSizeSweep == "Normal", title="Confirmed Bearish Reversal (Normal)", style=shape.triangledown, location=location.abovebar, color=colBear, size=size.normal, text="SELL")
plotshape(showSweepMarkers and confirmedBearReversal and labelSizeSweep == "Large",  title="Confirmed Bearish Reversal (Large)",  style=shape.triangledown, location=location.abovebar, color=colBear, size=size.large,  text="SELL")

// invisible export plots so other MYND tools can input.source() these signals (v1.2)
plot(enableSignalExport ? (chochBull ? 1 : 0) : na, title="Export: CHoCH Bullish", display=display.none)
plot(enableSignalExport ? (chochBear ? 1 : 0) : na, title="Export: CHoCH Bearish", display=display.none)
plot(enableSignalExport ? (confirmedBullReversal ? 1 : 0) : na, title="Export: Confirmed Bullish Reversal", display=display.none)
plot(enableSignalExport ? (confirmedBearReversal ? 1 : 0) : na, title="Export: Confirmed Bearish Reversal", display=display.none)
plot(enableSignalExport ? structBias : na, title="Export: Structure Bias (1/-1/0)", display=display.none)

// ---------------------------------------------------------------------------
// DASHBOARD TABLE
// ---------------------------------------------------------------------------
var table dash = table.new(tablePos == "Top Right" ? position.top_right : tablePos == "Top Left" ? position.top_left : tablePos == "Bottom Right" ? position.bottom_right : position.bottom_left, 2, 12, border_width=1, border_color=color.new(color.gray, 50), frame_color=color.new(color.gray, 50), frame_width=1)

tSize = tableSize == "Tiny" ? size.tiny : tableSize == "Normal" ? size.normal : size.small

if showTable and barstate.islast
    table.cell(dash, 0, 0, "MYND Structure Shift", text_color=color.white, bgcolor=color.new(color.blue, 20), text_size=tSize)
    table.cell(dash, 1, 0, "", bgcolor=color.new(color.blue, 20))

    biasText  = structBias == 1 ? "BULLISH" : structBias == -1 ? "BEARISH" : "UNDETERMINED"
    biasColor = structBias == 1 ? colBull : structBias == -1 ? colBear : color.new(color.gray, 40)
    table.cell(dash, 0, 1, "Structure Bias", text_size=tSize)
    table.cell(dash, 1, 1, biasText, text_color=color.white, bgcolor=biasColor, text_size=tSize)

    evText = na(lastEventBar) ? "-" : lastEventText + " (" + str.tostring(bar_index - lastEventBar) + "b ago)"
    table.cell(dash, 0, 2, "Last Break Event", text_size=tSize)
    table.cell(dash, 1, 2, evText, text_size=tSize)

    sweepText  = awaitingBull ? "Awaiting Bull Confirm (" + str.tostring(awaitBullLeft) + "b left" + (bullGraceUsed ? ", grace" : "") + ")" : awaitingBear ? "Awaiting Bear Confirm (" + str.tostring(awaitBearLeft) + "b left" + (bearGraceUsed ? ", grace" : "") + ")" : "None Pending"
    sweepColor = awaitingBull ? color.new(color.lime, 40) : awaitingBear ? color.new(color.red, 40) : color.new(color.gray, 60)
    table.cell(dash, 0, 3, "Sweep Status", text_size=tSize)
    table.cell(dash, 1, 3, sweepText, text_color=color.white, bgcolor=sweepColor, text_size=tSize)

    outcomeLabel = lastSweepOutcomeCode == 1 ? "Confirmed Bull" : lastSweepOutcomeCode == 2 ? "Confirmed Bear" : lastSweepOutcomeCode == 3 ? "Invalidated Bull" : lastSweepOutcomeCode == 4 ? "Invalidated Bear" : lastSweepOutcomeCode == 5 ? "Expired Bull" : lastSweepOutcomeCode == 6 ? "Expired Bear" : "-"
    outcomeColor = lastSweepOutcomeCode == 1 ? colBull : lastSweepOutcomeCode == 2 ? colBear : (lastSweepOutcomeCode == 3 or lastSweepOutcomeCode == 4) ? colWarn : (lastSweepOutcomeCode == 5 or lastSweepOutcomeCode == 6) ? color.new(color.gray, 40) : color.new(color.gray, 70)
    outcomeText  = lastSweepOutcomeCode == 0 ? "-" : outcomeLabel + " (" + str.tostring(bar_index - lastSweepOutcomeBar) + "b ago)"
    table.cell(dash, 0, 4, "Last Sweep Outcome", text_size=tSize)
    table.cell(dash, 1, 4, outcomeText, text_color=color.white, bgcolor=outcomeColor, text_size=tSize)

    qualityText = not enableQualityScore ? "Off" : (na(lastQualityScoreBullBar) and na(lastQualityScoreBearBar)) ? "-" : (nz(lastQualityScoreBullBar, -1) > nz(lastQualityScoreBearBar, -1)) ? "BULL " + str.tostring(math.round(lastQualityScoreBull)) + "/100" : "BEAR " + str.tostring(math.round(lastQualityScoreBear)) + "/100"
    table.cell(dash, 0, 5, "Last Signal Quality", text_size=tSize)
    table.cell(dash, 1, 5, qualityText, text_size=tSize)

    blockedText = lastBlockedText == "-" ? "-" : lastBlockedText + " (" + str.tostring(bar_index - lastBlockedBar) + "b ago)"
    table.cell(dash, 0, 6, "Last Blocked Signal", text_size=tSize)
    table.cell(dash, 1, 6, blockedText, text_size=tSize)

    table.cell(dash, 0, 7, "Current Swing High is EQH", text_size=tSize)
    table.cell(dash, 1, 7, swingHighIsEQH ? "YES" : "NO", text_size=tSize)

    table.cell(dash, 0, 8, "Current Swing Low is EQL", text_size=tSize)
    table.cell(dash, 1, 8, swingLowIsEQL ? "YES" : "NO", text_size=tSize)

    htfBiasText = htfBiasUp ? "UP" : htfBiasDown ? "DOWN" : "FLAT"
    table.cell(dash, 0, 9, "HTF Bias (" + htfTF + ")", text_size=tSize)
    table.cell(dash, 1, 9, htfBiasText, text_color=color.white, bgcolor=htfBiasUp ? colBull : htfBiasDown ? colBear : color.new(color.gray, 40), text_size=tSize)

    table.cell(dash, 0, 10, "HTF Prior High / Low", text_size=tSize)
    table.cell(dash, 1, 10, str.tostring(htfPriorHigh, format.mintick) + " / " + str.tostring(htfPriorLow, format.mintick), text_size=tSize)

    tallyText = "C:" + str.tostring(tallyConfirmedBull + tallyConfirmedBear) + " IV:" + str.tostring(tallyInvalidatedBull + tallyInvalidatedBear) + " EX:" + str.tostring(tallyExpiredBull + tallyExpiredBear)
    table.cell(dash, 0, 11, "Sweep Outcome Tally", text_size=tSize)
    table.cell(dash, 1, 11, tallyText, text_size=tSize)

// ---------------------------------------------------------------------------
// ALERTS
// ---------------------------------------------------------------------------
allBullishEvents    = bosBull or chochBull or confirmedBullReversal
allBearishEvents    = bosBear or chochBear or confirmedBearReversal
allSweepsAndInvalid = sweepLowQualifies or sweepHighQualifies or invalidatedBull or invalidatedBear
allSignals          = allBullishEvents or allBearishEvents or allSweepsAndInvalid or eqHighDetected or eqLowDetected

alertcondition(bosBull, title="MYND SS - BOS Bullish", message="MYND Structure Shift: Bullish Break of Structure (continuation) on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(bosBear, title="MYND SS - BOS Bearish", message="MYND Structure Shift: Bearish Break of Structure (continuation) on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(chochBull, title="MYND SS - CHoCH Bullish", message="MYND Structure Shift: Bullish Change of Character (potential reversal) on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(chochBear, title="MYND SS - CHoCH Bearish", message="MYND Structure Shift: Bearish Change of Character (potential reversal) on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(sweepLowQualifies, title="MYND SS - Liquidity Sweep Low Detected", message="MYND Structure Shift: Liquidity sweep of a swing LOW on {{ticker}} ({{interval}}) at {{close}} - awaiting confirmation")
alertcondition(sweepHighQualifies, title="MYND SS - Liquidity Sweep High Detected", message="MYND Structure Shift: Liquidity sweep of a swing HIGH on {{ticker}} ({{interval}}) at {{close}} - awaiting confirmation")
alertcondition(confirmedBullReversal, title="MYND SS - Confirmed Bullish Reversal", message="MYND Structure Shift: CONFIRMED bullish reversal (sweep + displacement + volume) on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(confirmedBearReversal, title="MYND SS - Confirmed Bearish Reversal", message="MYND Structure Shift: CONFIRMED bearish reversal (sweep + displacement + volume) on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(eqHighDetected, title="MYND SS - Equal Highs Detected", message="MYND Structure Shift: Equal Highs liquidity pool formed on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(eqLowDetected, title="MYND SS - Equal Lows Detected", message="MYND Structure Shift: Equal Lows liquidity pool formed on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(invalidatedBull, title="MYND SS - Bullish Setup Invalidated", message="MYND Structure Shift: Bullish reversal setup INVALIDATED - price broke through the sweep's own extreme before confirming on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(invalidatedBear, title="MYND SS - Bearish Setup Invalidated", message="MYND Structure Shift: Bearish reversal setup INVALIDATED - price broke through the sweep's own extreme before confirming on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(allBullishEvents, title="MYND SS - COMBO: ALL Bullish Events", message="MYND Structure Shift: Bullish event (BOS/CHoCH/Confirmed Reversal) on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(allBearishEvents, title="MYND SS - COMBO: ALL Bearish Events", message="MYND Structure Shift: Bearish event (BOS/CHoCH/Confirmed Reversal) on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(allSweepsAndInvalid, title="MYND SS - COMBO: ALL Sweeps & Invalidations", message="MYND Structure Shift: Sweep pending or setup invalidated on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(allSignals, title="MYND SS - COMBO: ALL Signals", message="MYND Structure Shift: Signal event on {{ticker}} ({{interval}}) at {{close}}")
````
