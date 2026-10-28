# Momentum Leader ATR Risk Map

- url: https://www.tradingview.com/script/0mNOkPnT-Momentum-Leader-ATR-Risk-Map/
- type: indicator
- pine_id: PUB;7728cf3c4936497893a4edf3e2754e3a
- version: 1.0

## Description

Momentum Leader ATR Risk Map is a position-management indicator designed to help traders visualize where a leading stock is trading relative to its 50-period SMA and ATR-based extension levels.

The goal is not to generate automatic buy or sell signals. Instead, this tool provides a structured risk map for momentum leaders by combining:

• ATR extension from a configurable SMA baseline
• Positive extension bands for profit-taking and risk management
• Negative extension bands for pullback, add-zone, and damage-control reference levels
• Relative strength scoring versus a benchmark such as SPY
• SMA trend status
• Optional liquidity, sector RS, and industry RS filters
• Nearest upside and downside map levels shown directly in the table

By default, the indicator uses a Daily anchor and 50-period SMA baseline, making it suitable for swing trading and longer-term position management in momentum leaders. A 24-hour / 1440-minute anchor is also available for users who prefer to evaluate instruments with extended-hours or near-24-hour trading behavior.

Core Risk Map Levels:

Positive Extension Zones:
• +2.95x ATR: High-RS leader zone
• +4.56x ATR: Super momentum zone
• +5.27x ATR: Approximate 2σ risk zone
• +7.83x ATR: Approximate 3σ profit zone
• +10.00x ATR: Extreme / trail-only zone

Negative Extension Zones:
• -1.00x ATR: Pullback
• -2.00x ATR: Add zone
• -3.00x ATR: Deep pullback
• -4.56x ATR: Damage control
• -5.27x ATR: Washout / reclaim-needed zone

The table is designed to answer a few practical questions quickly:

• Is the stock still acting like a leader?
• Is price extended, normal, or damaged relative to the SMA/ATR map?
• Is the SMA trend still constructive?
• Is relative strength still intact across multiple lookback windows?
• Where is the nearest upside ATR map level?
• Where is the nearest downside ATR map level?

Relative Strength Logic:

The RS Score compares the current symbol against a user-selected benchmark over 21, 63, 126, and 252 anchor bars. A score of 4 of 4 means the symbol is outperforming the benchmark across all four lookback windows.

Optional Advanced Inputs:

The indicator includes optional sector and industry RS inputs for users who want to manually compare the stock against relevant ETFs such as XLK, SMH, IGV, XBI, XLE, XLF, or other sector/industry proxies. These are turned off by default to keep the tool frictionless.

A liquidity filter is also available, but it is turned off by default so the indicator can remain focused on the risk map itself.

Credit and Inspiration:

This indicator was inspired by concepts shared by several market educators and traders:

• Jeff Sun / @jfsrev
https://x.com/jfsrev

• @i_manage_risk
https://x.com/i_manage_risk

• StratLab / @StratLaboratory
https://x.com/StratLaboratory

Their publicly shared work on relative strength, momentum leadership, ATR extension frameworks, risk management, and scaling into or out of leaders helped shape the conceptual foundation for this tool.

This script is an independent implementation. It is not affiliated with, sponsored by, or endorsed by Jeff Sun, @i_manage_risk, StratLab, or @StratLaboratory, and it is not intended to replicate their complete methodologies.

Suggested Use:

This indicator is best used as a position-management overlay for stocks that have already been identified as potential leaders through a separate screening process. It can help define areas where the stock may be:

• Acting normally within a leadership trend
• Becoming extended into profit-taking zones
• Pulling back toward constructive support
• Losing momentum or entering damage-control territory

Important Notes:

ATR extension levels are reference zones, not guaranteed targets or support/resistance levels. A stock can remain extended for longer than expected, especially during strong momentum regimes. Conversely, deep pullbacks can signal deterioration rather than opportunity if leadership and trend structure are no longer intact.

Use this tool alongside broader market context, earnings risk, volume behavior, trend structure, and personal risk-management rules.

This indicator is for educational and informational purposes only and does not constitute financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Stereotypical

//@version=6
indicator("Momentum Leader ATR Risk Map", shorttitle="ML-ATR Risk Map", overlay=true, max_labels_count=100, dynamic_requests=true)

// =========================
// CORE INPUTS
// =========================

anchorTimeframe = input.timeframe("D", "Anchor Timeframe", options=["D", "1440"])
atrLength = input.int(14, "ATR Length", minval=1)
smaLength = input.int(50, "SMA Length", minval=1)
useCompletedBars = input.bool(true, "Use Completed Anchor Bars")

showSMA50 = input.bool(true, "Show SMA Baseline")
showPositiveBands = input.bool(true, "Show Positive Profit-Taking Bands")
showNegativeBands = input.bool(true, "Show Negative Dip/Add Bands")
showRightLabels = input.bool(true, "Show Right-Side Band Labels")
showRiskTable = input.bool(true, "Show Risk Map Table")

tablePosition = input.string("Top Right", "Table Position", options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"])
textSizeInput = input.string("Normal", "Table Text Size", options=["Tiny", "Small", "Normal", "Large"])

bandWidth = input.int(2, "Band Line Width", minval=1, maxval=5)
labelOffset = input.int(3, "Right Label Offset", minval=0, maxval=25)

// =========================
// DISPLAY INPUTS
// =========================

displayGroup = "Display"

showRSValuesInTable = input.bool(false, "Show Raw RS % Values", group=displayGroup)
showSMA50Label = input.bool(true, "Show SMA Label", group=displayGroup)
bandLabelSizeInput = input.string("Small", "Band Label Size", options=["Tiny", "Small", "Normal"], group=displayGroup)
bandLabelTransparency = input.int(0, "Band Label Transparency", minval=0, maxval=90, group=displayGroup)

// =========================
// LEADERSHIP / RS INPUTS
// =========================

useRSQualification = input.bool(true, "Use Relative Strength Qualification", group="Leadership Filters")
benchmarkSymbol = input.symbol("AMEX:SPY", "Primary RS Benchmark", group="Leadership Filters")

smaSlopeBars = input.int(10, "SMA Rising Lookback", minval=1, group="Leadership Filters")

// =========================
// LIQUIDITY INPUTS
// =========================

useLiquidityFilter = input.bool(false, "Use Liquidity Check", group="Liquidity")
liquidityLength = input.int(50, "Avg Dollar Volume Length", minval=1, group="Liquidity")
minAvgDollarVolume = input.float(50000000.0, "Min Avg Dollar Volume", step=1000000, group="Liquidity")

// =========================
// OPTIONAL SECTOR / INDUSTRY RS
// =========================

useSectorRS = input.bool(false, "Use Optional Sector RS", group="Optional Sector / Industry RS")
sectorSymbol = input.symbol("AMEX:XLK", "Sector ETF", group="Optional Sector / Industry RS")

useIndustryRS = input.bool(false, "Use Optional Industry RS", group="Optional Sector / Industry RS")
industrySymbol = input.symbol("NASDAQ:SMH", "Industry ETF", group="Optional Sector / Industry RS")

sectorIndustryLookback = input.int(63, "Sector / Industry RS Lookback", minval=5, group="Optional Sector / Industry RS")

// =========================
// ATR RISK MAP THRESHOLDS
// =========================

pos1 = input.float(2.95, "Positive 1: High-RS Mean", step=0.01, group="Positive Profit-Taking Bands")
pos2 = input.float(4.56, "Positive 2: Super-Momentum Mean", step=0.01, group="Positive Profit-Taking Bands")
pos3 = input.float(5.27, "Positive 3: Approx +2 Sigma", step=0.01, group="Positive Profit-Taking Bands")
pos4 = input.float(7.83, "Positive 4: Approx +3 Sigma", step=0.01, group="Positive Profit-Taking Bands")
pos5 = input.float(10.00, "Positive 5: Extreme / Trail Only", step=0.01, group="Positive Profit-Taking Bands")

neg1 = input.float(-1.00, "Negative 1: Pullback", step=0.01, group="Negative Dip/Add Bands")
neg2 = input.float(-2.00, "Negative 2: Add Zone", step=0.01, group="Negative Dip/Add Bands")
neg3 = input.float(-3.00, "Negative 3: Deep Pullback", step=0.01, group="Negative Dip/Add Bands")
neg4 = input.float(-4.56, "Negative 4: Damage Control", step=0.01, group="Negative Dip/Add Bands")
neg5 = input.float(-5.27, "Negative 5: Washout / Reclaim Needed", step=0.01, group="Negative Dip/Add Bands")

// =========================
// POSITION / SIZE HELPERS
// =========================

pos = tablePosition == "Top Right" ? position.top_right :
      tablePosition == "Top Center" ? position.top_center :
      tablePosition == "Top Left" ? position.top_left :
      tablePosition == "Middle Right" ? position.middle_right :
      tablePosition == "Middle Center" ? position.middle_center :
      tablePosition == "Middle Left" ? position.middle_left :
      tablePosition == "Bottom Right" ? position.bottom_right :
      tablePosition == "Bottom Center" ? position.bottom_center :
      position.bottom_left

txtSize = textSizeInput == "Tiny" ? size.tiny :
          textSizeInput == "Small" ? size.small :
          textSizeInput == "Large" ? size.large :
          size.normal

lblSize = bandLabelSizeInput == "Tiny" ? size.tiny :
          bandLabelSizeInput == "Small" ? size.small :
          size.normal

anchorLabel = anchorTimeframe == "D" ? "D" : anchorTimeframe == "1440" ? "x24H" : "x" + anchorTimeframe
smaDisplayName = str.tostring(smaLength) + anchorLabel + " SMA"
smaTrendName = str.tostring(smaLength) + anchorLabel + " Trend"

// =========================
// ANCHOR TIMEFRAME DATA
// =========================

atrCompleted = request.security(syminfo.tickerid, anchorTimeframe, ta.atr(atrLength)[1], barmerge.gaps_off, barmerge.lookahead_on)
smaCompleted = request.security(syminfo.tickerid, anchorTimeframe, ta.sma(close, smaLength)[1], barmerge.gaps_off, barmerge.lookahead_on)
smaRisingCompleted = request.security(syminfo.tickerid, anchorTimeframe, ta.sma(close, smaLength)[1] > ta.sma(close, smaLength)[smaSlopeBars + 1], barmerge.gaps_off, barmerge.lookahead_on)
avgDollarVolCompleted = request.security(syminfo.tickerid, anchorTimeframe, ta.sma(close * volume, liquidityLength)[1], barmerge.gaps_off, barmerge.lookahead_on)

atrLive = request.security(syminfo.tickerid, anchorTimeframe, ta.atr(atrLength), barmerge.gaps_off, barmerge.lookahead_off)
smaLive = request.security(syminfo.tickerid, anchorTimeframe, ta.sma(close, smaLength), barmerge.gaps_off, barmerge.lookahead_off)
smaRisingLive = request.security(syminfo.tickerid, anchorTimeframe, ta.sma(close, smaLength) > ta.sma(close, smaLength)[smaSlopeBars], barmerge.gaps_off, barmerge.lookahead_off)
avgDollarVolLive = request.security(syminfo.tickerid, anchorTimeframe, ta.sma(close * volume, liquidityLength), barmerge.gaps_off, barmerge.lookahead_off)

atrRaw = useCompletedBars ? atrCompleted : atrLive
smaRaw = useCompletedBars ? smaCompleted : smaLive
smaRising = useCompletedBars ? smaRisingCompleted : smaRisingLive
avgDollarVol = useCompletedBars ? avgDollarVolCompleted : avgDollarVolLive

var float anchorATR = na
var float anchorSMA = na

anchorATR := not na(atrRaw) ? atrRaw : anchorATR[1]
anchorSMA := not na(smaRaw) ? smaRaw : anchorSMA[1]

aboveSMA = not na(anchorSMA) and close > anchorSMA

// =========================
// RETURN / RS HELPERS
// =========================

f_ret(_symbol, _len) =>
    useCompletedBars ?
     request.security(_symbol, anchorTimeframe, (close[1] / close[_len + 1] - 1) * 100, barmerge.gaps_off, barmerge.lookahead_on) :
     request.security(_symbol, anchorTimeframe, (close / close[_len] - 1) * 100, barmerge.gaps_off, barmerge.lookahead_off)

stockRet21 = f_ret(syminfo.tickerid, 21)
stockRet63 = f_ret(syminfo.tickerid, 63)
stockRet126 = f_ret(syminfo.tickerid, 126)
stockRet252 = f_ret(syminfo.tickerid, 252)

benchRet21 = f_ret(benchmarkSymbol, 21)
benchRet63 = f_ret(benchmarkSymbol, 63)
benchRet126 = f_ret(benchmarkSymbol, 126)
benchRet252 = f_ret(benchmarkSymbol, 252)

rs21 = stockRet21 - benchRet21
rs63 = stockRet63 - benchRet63
rs126 = stockRet126 - benchRet126
rs252 = stockRet252 - benchRet252

stockRetSI = f_ret(syminfo.tickerid, sectorIndustryLookback)
sectorRet = f_ret(sectorSymbol, sectorIndustryLookback)
industryRet = f_ret(industrySymbol, sectorIndustryLookback)
benchRetSI = f_ret(benchmarkSymbol, sectorIndustryLookback)

sectorRS = sectorRet - benchRetSI
industryRS = industryRet - benchRetSI
stockVsSectorRS = stockRetSI - sectorRet
stockVsIndustryRS = stockRetSI - industryRet

// =========================
// ATR EXTENSION CALCULATION
// =========================

atrExtension = anchorATR > 0 and not na(anchorSMA) ? (close - anchorSMA) / anchorATR : na

f_level(mult) =>
    not na(anchorSMA) and anchorATR > 0 ? anchorSMA + anchorATR * mult : na

posLevel1 = f_level(pos1)
posLevel2 = f_level(pos2)
posLevel3 = f_level(pos3)
posLevel4 = f_level(pos4)
posLevel5 = f_level(pos5)

negLevel1 = f_level(neg1)
negLevel2 = f_level(neg2)
negLevel3 = f_level(neg3)
negLevel4 = f_level(neg4)
negLevel5 = f_level(neg5)

// =========================
// NEAREST MAP PRICES ABOVE / BELOW CURRENT PRICE
// Includes SMA as a valid target/pullback level.
// =========================

f_nearestAbove(currentBest, level) =>
    not na(level) and level > close and (na(currentBest) or level < currentBest) ? level : currentBest

f_nearestBelow(currentBest, level) =>
    not na(level) and level < close and (na(currentBest) or level > currentBest) ? level : currentBest

float nextTargetPrice = na
float nextPullbackPrice = na

nextTargetPrice := f_nearestAbove(nextTargetPrice, anchorSMA)
nextTargetPrice := f_nearestAbove(nextTargetPrice, posLevel1)
nextTargetPrice := f_nearestAbove(nextTargetPrice, posLevel2)
nextTargetPrice := f_nearestAbove(nextTargetPrice, posLevel3)
nextTargetPrice := f_nearestAbove(nextTargetPrice, posLevel4)
nextTargetPrice := f_nearestAbove(nextTargetPrice, posLevel5)
nextTargetPrice := f_nearestAbove(nextTargetPrice, negLevel1)
nextTargetPrice := f_nearestAbove(nextTargetPrice, negLevel2)
nextTargetPrice := f_nearestAbove(nextTargetPrice, negLevel3)
nextTargetPrice := f_nearestAbove(nextTargetPrice, negLevel4)
nextTargetPrice := f_nearestAbove(nextTargetPrice, negLevel5)

nextPullbackPrice := f_nearestBelow(nextPullbackPrice, anchorSMA)
nextPullbackPrice := f_nearestBelow(nextPullbackPrice, posLevel1)
nextPullbackPrice := f_nearestBelow(nextPullbackPrice, posLevel2)
nextPullbackPrice := f_nearestBelow(nextPullbackPrice, posLevel3)
nextPullbackPrice := f_nearestBelow(nextPullbackPrice, posLevel4)
nextPullbackPrice := f_nearestBelow(nextPullbackPrice, posLevel5)
nextPullbackPrice := f_nearestBelow(nextPullbackPrice, negLevel1)
nextPullbackPrice := f_nearestBelow(nextPullbackPrice, negLevel2)
nextPullbackPrice := f_nearestBelow(nextPullbackPrice, negLevel3)
nextPullbackPrice := f_nearestBelow(nextPullbackPrice, negLevel4)
nextPullbackPrice := f_nearestBelow(nextPullbackPrice, negLevel5)

// =========================
// COLORS
// =========================

whiteText = color.white
labelBg = color.rgb(35, 40, 52)
neutralBg = color.rgb(90, 96, 110)
greenBg = color.rgb(55, 135, 70)
aquaBg = color.rgb(20, 145, 165)
orangeBg = color.rgb(175, 105, 25)
redBg = color.rgb(150, 42, 55)
purpleBg = color.rgb(115, 55, 150)
borderColor = color.rgb(120, 128, 145)

smaColor = color.rgb(220, 220, 220)
smaLabelBg = color.rgb(70, 76, 90)

posColor1 = color.rgb(20, 145, 165)
posColor2 = color.rgb(55, 135, 70)
posColor3 = color.rgb(175, 105, 25)
posColor4 = color.rgb(220, 90, 30)
posColor5 = color.rgb(190, 45, 65)

negColor1 = color.rgb(90, 130, 210)
negColor2 = color.rgb(60, 105, 190)
negColor3 = color.rgb(130, 95, 185)
negColor4 = color.rgb(150, 70, 150)
negColor5 = color.rgb(150, 42, 55)

// =========================
// TEXT / FORMAT HELPERS
// =========================

f_extText(mult) =>
    mult > 0 ? "+" + str.tostring(mult, "#.##") + "x" :
     mult < 0 ? str.tostring(mult, "#.##") + "x" :
     "0.00x"

f_pctText(x) =>
    na(x) ? "N/A" : str.tostring(x, "#.##") + "%"

f_dollarText(x) =>
    na(x) ? "N/A" :
     x >= 1000000000 ? "$" + str.tostring(x / 1000000000, "#.##") + "B" :
     x >= 1000000 ? "$" + str.tostring(x / 1000000, "#.##") + "M" :
     "$" + str.tostring(x, "#")

f_priceText(x) =>
    na(x) ? "N/A" : str.tostring(x, format.mintick)

// =========================
// RISK STATE HELPERS
// =========================

f_riskState(e) =>
    na(e) ? "N/A" :
     e >= pos5 ? "Extreme / Trail" :
     e >= pos4 ? "3σ Profit Zone" :
     e >= pos3 ? "2σ Risk Zone" :
     e >= pos2 ? "Super Momentum" :
     e >= pos1 ? "High-RS Leader" :
     e <= neg5 ? "Washout / Reclaim" :
     e <= neg4 ? "Damage Control" :
     e <= neg3 ? "Deep Pullback" :
     e <= neg2 ? "Add Zone" :
     e <= neg1 ? "Pullback" :
     "Hold"

f_riskColor(e) =>
    na(e) ? neutralBg :
     e >= pos5 ? redBg :
     e >= pos4 ? orangeBg :
     e >= pos3 ? orangeBg :
     e >= pos2 ? greenBg :
     e >= pos1 ? aquaBg :
     e <= neg5 ? redBg :
     e <= neg4 ? purpleBg :
     e <= neg3 ? purpleBg :
     e <= neg2 ? aquaBg :
     e <= neg1 ? greenBg :
     neutralBg

f_leaderState(pct) =>
    na(pct) ? "N/A" :
     pct >= 85 ? "Confirmed" :
     pct >= 70 ? "Watch" :
     pct >= 50 ? "Mixed" :
     "Weak"

// =========================
// LEADERSHIP SCORE
// =========================

liqOK = not useLiquidityFilter or avgDollarVol >= minAvgDollarVolume

rs21OK = not na(rs21) and rs21 > 0
rs63OK = not na(rs63) and rs63 > 0
rs126OK = not na(rs126) and rs126 > 0
rs252OK = not na(rs252) and rs252 > 0

rsScore = (rs21OK ? 1 : 0) + (rs63OK ? 1 : 0) + (rs126OK ? 1 : 0) + (rs252OK ? 1 : 0)

int leaderScore = 0
int leaderMax = 0

leaderMax += 1
leaderScore += aboveSMA ? 1 : 0

leaderMax += 1
leaderScore += smaRising ? 1 : 0

if useRSQualification
    leaderMax += 1
    leaderScore += rs21OK ? 1 : 0

    leaderMax += 1
    leaderScore += rs63OK ? 1 : 0

    leaderMax += 1
    leaderScore += rs126OK ? 1 : 0

    leaderMax += 1
    leaderScore += rs252OK ? 1 : 0

if useLiquidityFilter
    leaderMax += 1
    leaderScore += liqOK ? 1 : 0

if useSectorRS
    leaderMax += 1
    leaderScore += sectorRS > 0 ? 1 : 0

    leaderMax += 1
    leaderScore += stockVsSectorRS > 0 ? 1 : 0

if useIndustryRS
    leaderMax += 1
    leaderScore += industryRS > 0 ? 1 : 0

    leaderMax += 1
    leaderScore += stockVsIndustryRS > 0 ? 1 : 0

leaderPct = leaderMax > 0 ? leaderScore * 100.0 / leaderMax : na

leaderState = f_leaderState(leaderPct)

leaderColor = na(leaderPct) ? neutralBg :
     leaderPct >= 85 ? greenBg :
     leaderPct >= 70 ? aquaBg :
     leaderPct >= 50 ? orangeBg :
     redBg

trendText = aboveSMA and smaRising ? "Above / Rising" :
     aboveSMA and not smaRising ? "Above / Flat" :
     not aboveSMA and smaRising ? "Below / Rising" :
     "Below / Weak"

trendColor = aboveSMA and smaRising ? greenBg :
     aboveSMA ? orangeBg :
     redBg

liqColor = not useLiquidityFilter ? neutralBg : liqOK ? greenBg : redBg

rsText = not useRSQualification ? "Off" :
     showRSValuesInTable ? f_pctText(rs21) + " / " + f_pctText(rs63) :
     str.tostring(rsScore) + " of 4"

rsColor = not useRSQualification ? neutralBg :
     rsScore >= 4 ? greenBg :
     rsScore >= 3 ? aquaBg :
     rsScore >= 2 ? orangeBg :
     redBg

// =========================
// PLOTS
// =========================

plot(showSMA50 ? anchorSMA : na, "SMA Baseline", color=smaColor, linewidth=2)

plot(showPositiveBands ? posLevel1 : na, "High-RS Mean", color=posColor1, linewidth=bandWidth)
plot(showPositiveBands ? posLevel2 : na, "Super-Momentum Mean", color=posColor2, linewidth=bandWidth)
plot(showPositiveBands ? posLevel3 : na, "+2 Sigma Risk Zone", color=posColor3, linewidth=bandWidth)
plot(showPositiveBands ? posLevel4 : na, "+3 Sigma Profit Zone", color=posColor4, linewidth=bandWidth)
plot(showPositiveBands ? posLevel5 : na, "Extreme Trail-Only Zone", color=posColor5, linewidth=bandWidth)

plot(showNegativeBands ? negLevel1 : na, "Pullback", color=negColor1, linewidth=bandWidth)
plot(showNegativeBands ? negLevel2 : na, "Add Zone", color=negColor2, linewidth=bandWidth)
plot(showNegativeBands ? negLevel3 : na, "Deep Pullback", color=negColor3, linewidth=bandWidth)
plot(showNegativeBands ? negLevel4 : na, "Damage Control", color=negColor4, linewidth=bandWidth)
plot(showNegativeBands ? negLevel5 : na, "Washout / Reclaim Needed", color=negColor5, linewidth=bandWidth)

// =========================
// RIGHT-SIDE LABELS
// =========================

var label lblSMA50 = na

var label lblPos1 = na
var label lblPos2 = na
var label lblPos3 = na
var label lblPos4 = na
var label lblPos5 = na
var label lblNeg1 = na
var label lblNeg2 = na
var label lblNeg3 = na
var label lblNeg4 = na
var label lblNeg5 = na

f_updateLabel(oldLabel, showLabel, priceLevel, labelText, labelColor) =>
    label.delete(oldLabel)
    showLabel and not na(priceLevel) ? label.new(
         bar_index + labelOffset,
         priceLevel,
         labelText,
         xloc=xloc.bar_index,
         style=label.style_label_left,
         textcolor=color.white,
         color=color.new(labelColor, bandLabelTransparency),
         size=lblSize) : na

if barstate.islast
    lblSMA50 := f_updateLabel(lblSMA50, showRightLabels and showSMA50 and showSMA50Label, anchorSMA, smaDisplayName, smaLabelBg)

    lblPos1 := f_updateLabel(lblPos1, showRightLabels and showPositiveBands, posLevel1, f_extText(pos1) + " High-RS", posColor1)
    lblPos2 := f_updateLabel(lblPos2, showRightLabels and showPositiveBands, posLevel2, f_extText(pos2) + " Super Momentum", posColor2)
    lblPos3 := f_updateLabel(lblPos3, showRightLabels and showPositiveBands, posLevel3, f_extText(pos3) + " 2σ Risk", posColor3)
    lblPos4 := f_updateLabel(lblPos4, showRightLabels and showPositiveBands, posLevel4, f_extText(pos4) + " 3σ Profit", posColor4)
    lblPos5 := f_updateLabel(lblPos5, showRightLabels and showPositiveBands, posLevel5, f_extText(pos5) + " Extreme / Trail", posColor5)

    lblNeg1 := f_updateLabel(lblNeg1, showRightLabels and showNegativeBands, negLevel1, f_extText(neg1) + " Pullback", negColor1)
    lblNeg2 := f_updateLabel(lblNeg2, showRightLabels and showNegativeBands, negLevel2, f_extText(neg2) + " Add Zone", negColor2)
    lblNeg3 := f_updateLabel(lblNeg3, showRightLabels and showNegativeBands, negLevel3, f_extText(neg3) + " Deep Pullback", negColor3)
    lblNeg4 := f_updateLabel(lblNeg4, showRightLabels and showNegativeBands, negLevel4, f_extText(neg4) + " Damage", negColor4)
    lblNeg5 := f_updateLabel(lblNeg5, showRightLabels and showNegativeBands, negLevel5, f_extText(neg5) + " Washout / Reclaim", negColor5)

// =========================
// CLEAR RISK MAP TABLE
// =========================

var table riskTable = table.new(pos, 2, 12, border_width=1, border_color=borderColor, frame_width=1, frame_color=borderColor)

if barstate.islast
    table.clear(riskTable, 0, 0, 1, 11)

    if showRiskTable
        extValue = na(atrExtension) ? "N/A" : str.tostring(atrExtension, "#.##") + "x"
        zoneText = f_riskState(atrExtension)
        zoneColor = f_riskColor(atrExtension)

        leaderText = leaderState + " " + str.tostring(leaderScore) + "/" + str.tostring(leaderMax)
        nextTargetText = f_priceText(nextTargetPrice)
        nextPullbackText = f_priceText(nextPullbackPrice)

        int row = 0

        table.cell(riskTable, 0, row, "Risk Map", text_color=whiteText, bgcolor=labelBg, text_size=txtSize, text_halign=text.align_center)
        table.cell(riskTable, 1, row, "Status", text_color=whiteText, bgcolor=labelBg, text_size=txtSize, text_halign=text.align_center)
        row += 1

        table.cell(riskTable, 0, row, "Extension", text_color=whiteText, bgcolor=labelBg, text_size=txtSize, text_halign=text.align_center)
        table.cell(riskTable, 1, row, extValue, text_color=whiteText, bgcolor=zoneColor, text_size=txtSize, text_halign=text.align_center)
        row += 1

        table.cell(riskTable, 0, row, "Zone", text_color=whiteText, bgcolor=labelBg, text_size=txtSize, text_halign=text.align_center)
        table.cell(riskTable, 1, row, zoneText, text_color=whiteText, bgcolor=zoneColor, text_size=txtSize, text_halign=text.align_center)
        row += 1

        table.cell(riskTable, 0, row, "Leader", text_color=whiteText, bgcolor=labelBg, text_size=txtSize, text_halign=text.align_center)
        table.cell(riskTable, 1, row, leaderText, text_color=whiteText, bgcolor=leaderColor, text_size=txtSize, text_halign=text.align_center)
        row += 1

        table.cell(riskTable, 0, row, smaTrendName, text_color=whiteText, bgcolor=labelBg, text_size=txtSize, text_halign=text.align_center)
        table.cell(riskTable, 1, row, trendText, text_color=whiteText, bgcolor=trendColor, text_size=txtSize, text_halign=text.align_center)
        row += 1

        table.cell(riskTable, 0, row, "RS Score", text_color=whiteText, bgcolor=labelBg, text_size=txtSize, text_halign=text.align_center)
        table.cell(riskTable, 1, row, rsText, text_color=whiteText, bgcolor=rsColor, text_size=txtSize, text_halign=text.align_center)
        row += 1

        if useLiquidityFilter
            table.cell(riskTable, 0, row, "Liquidity", text_color=whiteText, bgcolor=labelBg, text_size=txtSize, text_halign=text.align_center)
            table.cell(riskTable, 1, row, f_dollarText(avgDollarVol), text_color=whiteText, bgcolor=liqColor, text_size=txtSize, text_halign=text.align_center)
            row += 1

        if useSectorRS
            sectorText = "Sector " + f_pctText(sectorRS) + " / Stock " + f_pctText(stockVsSectorRS)
            sectorColor = sectorRS > 0 and stockVsSectorRS > 0 ? greenBg : orangeBg

            table.cell(riskTable, 0, row, "Sector RS", text_color=whiteText, bgcolor=labelBg, text_size=txtSize, text_halign=text.align_center)
            table.cell(riskTable, 1, row, sectorText, text_color=whiteText, bgcolor=sectorColor, text_size=txtSize, text_halign=text.align_center)
            row += 1

        if useIndustryRS
            industryText = "Industry " + f_pctText(industryRS) + " / Stock " + f_pctText(stockVsIndustryRS)
            industryColor = industryRS > 0 and stockVsIndustryRS > 0 ? greenBg : orangeBg

            table.cell(riskTable, 0, row, "Industry RS", text_color=whiteText, bgcolor=labelBg, text_size=txtSize, text_halign=text.align_center)
            table.cell(riskTable, 1, row, industryText, text_color=whiteText, bgcolor=industryColor, text_size=txtSize, text_halign=text.align_center)
            row += 1

        table.cell(riskTable, 0, row, "Next Target", text_color=whiteText, bgcolor=labelBg, text_size=txtSize, text_halign=text.align_center)
        table.cell(riskTable, 1, row, nextTargetText, text_color=whiteText, bgcolor=neutralBg, text_size=txtSize, text_halign=text.align_center)
        row += 1

        table.cell(riskTable, 0, row, "Next Pullback", text_color=whiteText, bgcolor=labelBg, text_size=txtSize, text_halign=text.align_center)
        table.cell(riskTable, 1, row, nextPullbackText, text_color=whiteText, bgcolor=neutralBg, text_size=txtSize, text_halign=text.align_center)
````
