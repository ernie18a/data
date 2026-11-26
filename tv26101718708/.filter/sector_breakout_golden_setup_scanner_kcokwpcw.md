# Sector Breakout + Golden Setup Scanner

- url: https://www.tradingview.com/script/KcoKwPcw-Sector-Breakout-Golden-Setup-Scanner/
- type: indicator
- pine_id: PUB;95975c3c99d941219232f60ac767b63b
- version: 1.0

## Description

Visual Meaning Rarity Light blue background BASING — consolidation forming Common🟠 Diamond "ER" EARLY ROTATION — RS strong, price still in base Uncommon🟢 Triangle "BO" EMERGING BREAKOUT — pivot break + RS + volume Uncommon🟢 Large triangle "CBO"CONFIRMED BREAKOUT — full Stage-2 break Rare🟡 Yellow background + huge "GOLDEN SETUP" label All 10 strict criteria met Very rare🟠 Small "8+" triangle Near-Golden (8 of 10) — watchlist trigger Uncommon
The key insight: GOLDEN SETUP is a special case of EARLY ROTATION. It fires only when the early signal is also passing all 10 strict tests. Most Early Rotations won't qualify as Golden Setups — that's the point.
The Unified Label Shows Everything
STAGE: EARLY ROTATION (or GOLDEN SETUP if all 10 pass)
Score: 72/100   Pass: 9/10

==========================
TIER 1 - RS LEADERSHIP
[Y] RS at New High
[Y] RS Slope 8.45% (need >5%)
[Y] Mansfield 4.21 (need >0)
[N] Accel 1M=4.5% / 3M=18.2%     <- this is why it's not Golden yet

==========================
TIER 2 - BASE QUALITY
[Y] Valid Base Structure
[Y] ATR Contracting
[Y] Base Range 11.5% (need 8-15%)
[Y] Dist Pivot -1.20% (need -2 to 0%)

==========================
TIER 3 - CONFIRMATION
[Y] Volume 1.82x (need >1.5x)
[Y] Stage-2 Trend
[Y] Score >= 65

==========================
Pivot: 23,450.00
Stop: 21,200.00
VCP Pattern: YES
Color of the label box itself tells you status at a glance:

Yellow box = Golden Setup ACTIVE
Green box = Confirmed Breakout
Lime box = Emerging Breakout
Orange box = Early Rotation or Near-Golden (8+/10)
Dark box = Waiting / Basing / Trending

How to Read It in Practice
Scenario A — Stage shows "EARLY ROTATION" but Golden = 6/10:
Setup is forming but missing key criteria. Watchlist only — don't size in yet.
Scenario B — Stage shows "EARLY ROTATION" + Golden = 9/10:
Almost there. Identify the one missing criterion (label will tell you). When it flips, this is your high-conviction entry.
Scenario C — Stage shows "GOLDEN SETUP" (Pass 10/10):
This is the trade. Yellow background, huge label on chart, alert fires. Score will be 70+. Take the trade with stops at the Support level shown.
Scenario D — Stage shows "EMERGING BO" but Golden was never triggered:
The breakout fired without the strict pre-conditions. Lower conviction — could work but no Golden-grade signal beforehand.
Scenario E — Stage shows "CONFIRMED BO" + Golden was triggered earlier:
You missed the early entry. The Confirmed signal here is "extension" territory — still valid but lower R:R.
Alert Strategy
Set these alerts in priority order:

GOLDEN SETUP TRIGGERED — highest priority, fires rarely
Near Golden Setup (8+/10) — gives you early heads-up
EARLY ROTATION — catches setups that may not become Golden but still tradeable
CONFIRMED BREAKOUT — entry confirmation if you missed the early signal

Quick Reminders

Sector indices (CNXFMCG, CNXPHARMA, etc.): Turn OFF "Require Volume Surge" — no volume data
ETFs and individual stocks: Leave volume check ON
Weekly timeframe is the sweet spot for this framework — daily produces too many noisy signals; monthly too few
The Golden Setup is designed to be rare (maybe 1-2 sectors at a time across the entire NSE universe). If you see it firing on many sectors simultaneously, the broader market is in strong accumulation — itself a useful signal.

This is now your complete tactical scanner: stage detection for context, Golden Setup for conviction trades, all on one chart with no toggling between scripts.

## Source Code

````pine
//@version=5
// =============================================================================
// SECTOR BREAKOUT + GOLDEN SETUP MERGED SCANNER
// Combines: v2 Stage Detection (Early/Emerging/Confirmed Breakouts)
//         + Golden Setup 10-Point Strict Checklist
// 
// HIERARCHY:
//   WAITING < BASING < TRENDING < EARLY ROTATION < EMERGING BO < CONFIRMED BO
//   GOLDEN SETUP = strictest layer (all 10 boxes ticked, fires WITHIN Early stage)
//
// Sector indices: turn OFF "Require Volume Surge" (no volume data on indices)
// ETFs & stocks: leave volume check ON
// =============================================================================
indicator("Sector Breakout + Golden Setup Scanner", shorttitle="SBO+GS", overlay=true, max_labels_count=500)

// ===== INPUTS: RELATIVE STRENGTH =====
grpRS = "1. Relative Strength"
benchmark = input.symbol("NSE:CNX500", "Benchmark Index", group=grpRS)
rsNHLookback = input.int(63, "RS New-High Lookback (bars)", minval=20, maxval=252, group=grpRS)
rsSlopeLen = input.int(20, "RS Slope Period (bars)", minval=5, group=grpRS)
mansfieldLen = input.int(52, "Mansfield MA Length", minval=20, group=grpRS)

// ===== INPUTS: GOLDEN SETUP STRICT THRESHOLDS =====
grpGold = "2. Golden Setup Strict Thresholds"
rsSlopeMin = input.float(5.0, "Min RS Slope %", minval=0.0, group=grpGold)
mansfieldMin = input.float(0.0, "Min Mansfield RS", group=grpGold)
baseRangeMinPct = input.float(8.0, "Min Base Range %", minval=1.0, group=grpGold)
baseRangeMaxPct = input.float(15.0, "Max Base Range % (Golden)", minval=5.0, group=grpGold)
distPivotMin = input.float(-2.0, "Min Dist from Pivot %", group=grpGold)
distPivotMax = input.float(0.0, "Max Dist from Pivot %", group=grpGold)
minScoreGolden = input.int(65, "Min Composite Score", minval=0, maxval=100, group=grpGold)

// ===== INPUTS: BASE / CONSOLIDATION (general) =====
grpBase = "3. Base Detection (Stage Signals)"
baseMinWeeks = input.int(8, "Min Base Length (weeks)", minval=4, maxval=52, group=grpBase)
baseMaxWeeks = input.int(20, "Max Base Length (weeks)", minval=8, maxval=104, group=grpBase)
atrContractionPct = input.float(0.75, "ATR Contraction Ratio", minval=0.3, maxval=1.0, step=0.05, group=grpBase)
maxBaseRangeStage = input.float(25.0, "Max Base Range % (Stage)", minval=5.0, maxval=50.0, group=grpBase)

// ===== INPUTS: BREAKOUT & VOLUME =====
grpBO = "4. Breakout & Volume"
volMultiplier = input.float(1.5, "Volume Multiplier vs Avg", minval=1.0, group=grpBO)
volLookback = input.int(50, "Volume Average Lookback", minval=10, group=grpBO)
breakoutBufferPct = input.float(0.0, "Pivot Buffer %", minval=0.0, group=grpBO)
useVolume = input.bool(false, "Require Volume Surge (off for indices)", group=grpBO)

// ===== INPUTS: TREND FILTER =====
grpTrend = "5. Stage-2 Trend Filter"
useTrendFilter = input.bool(true, "Require Stage-2 Trend for Confirmed BO & Golden", group=grpTrend)
maFastLen = input.int(50, "Fast MA", group=grpTrend)
maSlowLen = input.int(200, "Slow MA", group=grpTrend)

// ===== INPUTS: VISUALIZATION =====
grpVis = "6. Visualization"
displayMode = input.string("Floating Label (tracks chart)", "Metrics Display", options=["Floating Label (tracks chart)","Fixed Table (pinned corner)","Both","None"], group=grpVis)
tablePos = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpVis)
labelVertAnchor = input.string("Top of visible range", "Label Vertical Anchor", options=["Top of visible range","Bottom of visible range","Above last bar","Below last bar"], group=grpVis)
labelSampleBars = input.int(50, "Bars for Vertical Anchor", minval=10, group=grpVis)
labelVertOffset = input.float(2.0, "Vertical ATR Offset", minval=0.0, group=grpVis)
labelSize = input.string("Normal", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpVis)
showPivot = input.bool(true, "Show Pivot Lines", group=grpVis)
showStageSignals = input.bool(true, "Show Stage Signals on Chart", group=grpVis)
showGoldenBg = input.bool(true, "Background Tint on Golden Setup", group=grpVis)

// ===== TIMEFRAME AWARENESS =====
barsPerWeek = timeframe.isweekly ? 1 : timeframe.isdaily ? 5 : timeframe.ismonthly ? 1 : 5
baseMinBars = math.max(int(baseMinWeeks * barsPerWeek), 5)
baseMaxBars = math.max(int(baseMaxWeeks * barsPerWeek), baseMinBars + 5)

// ===== RELATIVE STRENGTH =====
benchClose = request.security(benchmark, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
rsLine = benchClose > 0 ? close / benchClose : 0.0
rsHighRef = ta.highest(rsLine, rsNHLookback)
rsAtNewHigh = rsLine >= rsHighRef * 0.998
rsSlope = rsLine[rsSlopeLen] != 0 ? (rsLine - rsLine[rsSlopeLen]) / rsLine[rsSlopeLen] * 100 : 0.0
rsMA = ta.sma(rsLine, mansfieldLen)
mansfieldRS = rsMA != 0 ? ((rsLine / rsMA) - 1) * 100 : 0.0

// ===== RELATIVE PERFORMANCE =====
m1Bars = math.max(int(21 * (barsPerWeek / 5)), 1)
m3Bars = math.max(int(63 * (barsPerWeek / 5)), 1)
m6Bars = math.max(int(126 * (barsPerWeek / 5)), 1)
relPerf1M = rsLine[m1Bars] != 0 ? (rsLine / rsLine[m1Bars] - 1) * 100 : 0.0
relPerf3M = rsLine[m3Bars] != 0 ? (rsLine / rsLine[m3Bars] - 1) * 100 : 0.0
relPerf6M = rsLine[m6Bars] != 0 ? (rsLine / rsLine[m6Bars] - 1) * 100 : 0.0

// ===== BASE / CONSOLIDATION =====
basePivot = ta.highest(high[1], baseMinBars)
baseSupport = ta.lowest(low[1], baseMinBars)
basePctRange = baseSupport > 0 ? (basePivot - baseSupport) / baseSupport * 100 : 100.0
atrShort = ta.atr(14)
atrLong = ta.atr(baseMinBars)
atrContracting = atrShort < atrLong * atrContractionPct
atrW1 = ta.atr(10)
atrW2 = ta.atr(10)[10]
atrW3 = ta.atr(10)[20]
vcpPattern = atrW1 < atrW2 and atrW2 < atrW3
distFromPivot = basePivot > 0 ? (close - basePivot) / basePivot * 100 : -100.0
isInValidBase = atrContracting and basePctRange < maxBaseRangeStage and close < basePivot * 1.005 and close > baseSupport * 0.98

// ===== STAGE-2 TREND =====
maFast = ta.sma(close, maFastLen)
maSlow = ta.sma(close, maSlowLen)
isStage2 = close > maFast and maFast > maSlow and ta.rising(maSlow, 5)

// ===== VOLUME =====
volAvg = ta.sma(volume, volLookback)
volRatio = volAvg > 0 ? volume / volAvg : 0.0
volSurge = volume > volAvg * volMultiplier

// ===== STAGE SIGNALS (from v2 framework) =====
pivotWithBuffer = basePivot * (1 + breakoutBufferPct / 100)
priceCrossUp = ta.crossover(close, pivotWithBuffer)
earlyRotation = rsAtNewHigh and isInValidBase and close < basePivot and rsSlope > 0 and mansfieldRS > 0
emergingBreakout = priceCrossUp and rsAtNewHigh and volSurge
confirmedBreakout = priceCrossUp and rsAtNewHigh and volSurge and rsSlope > 0 and (not useTrendFilter or isStage2) and mansfieldRS > 0

// ===== GOLDEN SETUP - 10 STRICT CHECKS =====
c1_rsHigh = rsAtNewHigh
c2_rsSlope = rsSlope >= rsSlopeMin
c3_mansfield = mansfieldRS > mansfieldMin
c4_accelerating = relPerf1M > 0 and relPerf3M > 0 and relPerf1M > (relPerf3M / 3.0)
c5_validBase = isInValidBase
c6_atrContracting = atrContracting
c7_baseRangeOK = basePctRange >= baseRangeMinPct and basePctRange <= baseRangeMaxPct
c8_distPivotOK = distFromPivot >= distPivotMin and distFromPivot <= distPivotMax
c9_volumeOK = not useVolume or volRatio >= volMultiplier
c10_trendOK = not useTrendFilter or isStage2

// ===== COMPOSITE SCORE (0-100) =====
score = (c1_rsHigh ? 20 : 0) + (c2_rsSlope ? 15 : 0) + (c3_mansfield ? 10 : 0) + (c4_accelerating ? 10 : 0) + (c5_validBase ? 15 : 0) + (c6_atrContracting ? 5 : 0) + (c7_baseRangeOK ? 10 : 0) + (c8_distPivotOK ? 10 : 0) + (c10_trendOK ? 5 : 0)
c11_scoreOK = score >= minScoreGolden

// ===== GOLDEN SETUP TRIGGER =====
goldenSetup = c1_rsHigh and c2_rsSlope and c3_mansfield and c4_accelerating and c5_validBase and c6_atrContracting and c7_baseRangeOK and c8_distPivotOK and c9_volumeOK and c10_trendOK and c11_scoreOK
passCount = (c1_rsHigh ? 1 : 0) + (c2_rsSlope ? 1 : 0) + (c3_mansfield ? 1 : 0) + (c4_accelerating ? 1 : 0) + (c5_validBase ? 1 : 0) + (c6_atrContracting ? 1 : 0) + (c7_baseRangeOK ? 1 : 0) + (c8_distPivotOK ? 1 : 0) + (c9_volumeOK ? 1 : 0) + (c10_trendOK ? 1 : 0)

// ===== COMBINED STAGE LABEL =====
stageTxt = goldenSetup ? "*** GOLDEN SETUP ***" : confirmedBreakout ? "CONFIRMED BO" : emergingBreakout ? "EMERGING BO" : earlyRotation ? "EARLY ROTATION" : isInValidBase ? "BASING" : isStage2 ? "TRENDING" : "NEUTRAL"
stageCol = goldenSetup ? color.yellow : confirmedBreakout ? color.green : emergingBreakout ? color.lime : earlyRotation ? color.orange : isInValidBase ? color.blue : isStage2 ? color.teal : color.gray

// ===== PLOTTING =====
plot(showPivot ? basePivot : na, "Pivot (Resistance)", color=color.new(color.orange, 0), linewidth=2, style=plot.style_linebr)
plot(showPivot ? baseSupport : na, "Support (Stop)", color=color.new(color.aqua, 0), linewidth=1, style=plot.style_linebr)
plot(maFast, "Fast MA", color=color.new(color.blue, 50), linewidth=1)
plot(maSlow, "Slow MA", color=color.new(color.red, 50), linewidth=1)

// ===== BACKGROUND TINTING =====
bgcolor(showGoldenBg and goldenSetup ? color.new(color.yellow, 75) : isInValidBase and not priceCrossUp and not goldenSetup ? color.new(color.blue, 92) : na, title="Stage Background")

// ===== SIGNAL SHAPES ON CHART =====
plotshape(showStageSignals and earlyRotation and not goldenSetup, "Early Rotation", style=shape.diamond, location=location.belowbar, color=color.new(color.orange, 0), size=size.small, text="ER")
plotshape(showStageSignals and emergingBreakout, "Emerging BO", style=shape.triangleup, location=location.belowbar, color=color.new(color.lime, 0), size=size.normal, text="BO")
plotshape(showStageSignals and confirmedBreakout, "Confirmed BO", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 0), size=size.large, text="CBO")
plotshape(goldenSetup and not goldenSetup[1], "GOLDEN SETUP TRIGGER", style=shape.labelup, location=location.belowbar, color=color.new(color.yellow, 0), textcolor=color.black, size=size.huge, text="GOLDEN\nSETUP")
plotshape(passCount >= 8 and not goldenSetup and (na(passCount[1]) or passCount[1] < 8), "Near Setup 8+", style=shape.triangleup, location=location.abovebar, color=color.new(color.orange, 0), size=size.small, text="8+")

// ===== LABEL SIZE MAPPING =====
lblSize = labelSize == "Tiny" ? size.tiny : labelSize == "Small" ? size.small : labelSize == "Normal" ? size.normal : labelSize == "Large" ? size.large : size.huge

// ===== DYNAMIC VERTICAL POSITION =====
recentHigh = ta.highest(high, labelSampleBars)
recentLow = ta.lowest(low, labelSampleBars)
recentATR = ta.atr(14)
labelY = labelVertAnchor == "Top of visible range" ? recentHigh + (recentATR * labelVertOffset) : labelVertAnchor == "Bottom of visible range" ? recentLow - (recentATR * labelVertOffset) : labelVertAnchor == "Above last bar" ? high + (recentATR * labelVertOffset) : low - (recentATR * labelVertOffset)
labelStyle = labelVertAnchor == "Bottom of visible range" or labelVertAnchor == "Below last bar" ? label.style_label_upper_right : label.style_label_lower_right

// ===== DISPLAY MODE FLAGS =====
useLabel = displayMode == "Floating Label (tracks chart)" or displayMode == "Both"
useTable = displayMode == "Fixed Table (pinned corner)" or displayMode == "Both"

// ===== FLOATING LABEL =====
if useLabel and barstate.islast
    var label infoLbl = na
    label.delete(infoLbl)
    rightVisTime = chart.right_visible_bar_time
    anchorTime = not na(rightVisTime) ? rightVisTime : time
    scoreLine = "Score: " + str.tostring(score) + "/100   Pass: " + str.tostring(passCount) + "/10"
    txt = "STAGE: " + stageTxt + "\n" + scoreLine + "\n" + "==========================\n" + "TIER 1 - RS LEADERSHIP\n" + (c1_rsHigh ? "[Y] " : "[N] ") + "RS at New High\n" + (c2_rsSlope ? "[Y] " : "[N] ") + "RS Slope " + str.tostring(rsSlope, "#.##") + "% (need >" + str.tostring(rsSlopeMin) + "%)\n" + (c3_mansfield ? "[Y] " : "[N] ") + "Mansfield " + str.tostring(mansfieldRS, "#.##") + " (need >" + str.tostring(mansfieldMin) + ")\n" + (c4_accelerating ? "[Y] " : "[N] ") + "Accel 1M=" + str.tostring(relPerf1M, "#.#") + "% / 3M=" + str.tostring(relPerf3M, "#.#") + "%\n" + "==========================\n" + "TIER 2 - BASE QUALITY\n" + (c5_validBase ? "[Y] " : "[N] ") + "Valid Base Structure\n" + (c6_atrContracting ? "[Y] " : "[N] ") + "ATR Contracting\n" + (c7_baseRangeOK ? "[Y] " : "[N] ") + "Base Range " + str.tostring(basePctRange, "#.##") + "% (need " + str.tostring(baseRangeMinPct) + "-" + str.tostring(baseRangeMaxPct) + "%)\n" + (c8_distPivotOK ? "[Y] " : "[N] ") + "Dist Pivot " + str.tostring(distFromPivot, "+#.##;-#.##") + "% (need " + str.tostring(distPivotMin) + " to " + str.tostring(distPivotMax) + "%)\n" + "==========================\n" + "TIER 3 - CONFIRMATION\n" + (c9_volumeOK ? "[Y] " : "[N] ") + "Volume " + str.tostring(volRatio, "#.##") + "x" + (useVolume ? " (need >" + str.tostring(volMultiplier) + "x)" : " (off)") + "\n" + (c10_trendOK ? "[Y] " : "[N] ") + "Stage-2 Trend" + "\n" + (c11_scoreOK ? "[Y] " : "[N] ") + "Score >= " + str.tostring(minScoreGolden) + "\n" + "==========================\n" + "Pivot: " + str.tostring(basePivot, format.mintick) + "\n" + "Stop : " + str.tostring(baseSupport, format.mintick) + "\n" + "VCP Pattern: " + (vcpPattern ? "YES" : "NO")
    bgClr = goldenSetup ? color.new(color.yellow, 5) : confirmedBreakout ? color.new(color.green, 10) : emergingBreakout ? color.new(color.lime, 15) : earlyRotation ? color.new(color.orange, 15) : passCount >= 8 ? color.new(color.orange, 25) : color.new(color.black, 15)
    txtClr = goldenSetup ? color.black : color.white
    infoLbl := label.new(anchorTime, labelY, txt, xloc=xloc.bar_time, yloc=yloc.price, color=bgClr, textcolor=txtClr, style=labelStyle, size=lblSize, textalign=text.align_left)

// ===== FIXED TABLE =====
tablePosition = tablePos == "Top Left" ? position.top_left : tablePos == "Top Right" ? position.top_right : tablePos == "Bottom Left" ? position.bottom_left : position.bottom_right

if useTable and barstate.islast
    var table t = table.new(tablePosition, 2, 14, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.gray, 50))
    table.cell(t, 0, 0, "METRIC", bgcolor=color.new(color.navy, 0), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 0, "VALUE", bgcolor=color.new(color.navy, 0), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 1, "STAGE", bgcolor=stageCol, text_color=color.black, text_size=size.small)
    table.cell(t, 1, 1, stageTxt, bgcolor=stageCol, text_color=color.black, text_size=size.small)
    scoreColor = score >= 75 ? color.green : score >= 50 ? color.orange : color.red
    table.cell(t, 0, 2, "Score", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 2, str.tostring(score) + "/100", bgcolor=scoreColor, text_color=color.white, text_size=size.small)
    table.cell(t, 0, 3, "Golden Pass", text_color=color.white, text_size=size.small)
    passColor = passCount == 10 ? color.yellow : passCount >= 8 ? color.orange : color.gray
    table.cell(t, 1, 3, str.tostring(passCount) + "/10", bgcolor=passColor, text_color=color.black, text_size=size.small)
    table.cell(t, 0, 4, "RS New High", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 4, c1_rsHigh ? "Y" : "N", bgcolor=c1_rsHigh ? color.green : color.red, text_color=color.white, text_size=size.small)
    table.cell(t, 0, 5, "RS Slope", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 5, str.tostring(rsSlope, "#.##") + "%", bgcolor=c2_rsSlope ? color.new(color.green, 40) : color.new(color.red, 40), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 6, "Mansfield", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 6, str.tostring(mansfieldRS, "#.##"), bgcolor=c3_mansfield ? color.new(color.green, 40) : color.new(color.red, 40), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 7, "Accelerating", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 7, c4_accelerating ? "Y" : "N", bgcolor=c4_accelerating ? color.green : color.red, text_color=color.white, text_size=size.small)
    table.cell(t, 0, 8, "Valid Base", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 8, c5_validBase ? "Y" : "N", bgcolor=c5_validBase ? color.green : color.red, text_color=color.white, text_size=size.small)
    table.cell(t, 0, 9, "Base Range %", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 9, str.tostring(basePctRange, "#.##") + "%", bgcolor=c7_baseRangeOK ? color.new(color.green, 40) : color.new(color.red, 40), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 10, "Dist Pivot", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 10, str.tostring(distFromPivot, "+#.##;-#.##") + "%", bgcolor=c8_distPivotOK ? color.new(color.green, 40) : color.new(color.red, 40), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 11, "Stage-2 Trend", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 11, c10_trendOK ? "Y" : "N", bgcolor=c10_trendOK ? color.green : color.red, text_color=color.white, text_size=size.small)
    table.cell(t, 0, 12, "Pivot Level", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 12, str.tostring(basePivot, format.mintick), text_color=color.yellow, text_size=size.small)
    table.cell(t, 0, 13, "Stop Level", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 13, str.tostring(baseSupport, format.mintick), text_color=color.red, text_size=size.small)

// ===== ALERTS =====
alertcondition(goldenSetup and not goldenSetup[1], title="GOLDEN SETUP TRIGGERED", message="GOLDEN SETUP on {{ticker}}: All 10 criteria aligned. Highest conviction early breakout.")
alertcondition(confirmedBreakout, title="CONFIRMED BREAKOUT", message="CONFIRMED BREAKOUT on {{ticker}}: Full Stage-2 break with RS + volume + trend.")
alertcondition(emergingBreakout, title="EMERGING BREAKOUT", message="EMERGING BREAKOUT on {{ticker}}: Price broke pivot with RS confirmation.")
alertcondition(earlyRotation, title="EARLY ROTATION", message="EARLY ROTATION on {{ticker}}: RS at new high while still in base.")
alertcondition(passCount >= 8 and not goldenSetup, title="Near Golden Setup (8+/10)", message="Near-golden setup on {{ticker}}: 8 or more conditions met.")
````
