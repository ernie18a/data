# SPX/SPY Weighted Sector Tape Quality Dashboard

- url: https://www.tradingview.com/script/lmywkd98-SPX-SPY-Weighted-Sector-Tape-Quality-Dashboard/
- type: indicator
- pine_id: PUB;dc3510b0342c41a19189e4500f035398
- version: 2.0

## Description

SPY/SPX Weighted Sector Tape Quality Dashboard

- Purpose:
Provides a real-time view of SPY/SPX sector participation using sector ETF movement and approximate S&P 500 sector weights.

- Weighted Sector Impact:
Calculates each sector’s contribution by multiplying the sector’s percent move by its market weight.

- Real-Time Sector Table:
Displays each sector in a TradingView table with sector name, weight, percent move, weighted impact, and quick read.

- Color-Coded Heatmap:
Uses green/red shading to show positive or negative contribution. Brighter colors indicate stronger impact.

- Sortable Sector View:
Allows sorting by SPX weight, absolute contribution, or directional contribution.

- Editable Sector Weights:
Sector weights can be adjusted in settings as S&P 500 sector weights change over time.

- Move Calculation Options:
Supports Today From Open, Bar-to-Bar, and custom Lookback calculations.

- Weighted Positive Participation:
Shows how much of the S&P 500 by sector weight is participating positively.

- Positive Sector Count:
Tracks how many of the 11 major sectors are positive.

- Cyclical vs Defensive Score:
Compares risk-on sectors against defensive sectors to identify market tone.

- Mega-Cap Concentration:
Measures whether the move is being driven mainly by Technology, Communication Services, and Consumer Discretionary.

- VIX Confirmation:
Uses VIX movement as a confirmation or warning signal for tape quality.

- Tape Quality Score:
Combines weighted participation, breadth, cyclicals vs defensives, and VIX behavior into one quick score.

- Tape Classification:
Labels the tape as Broad Risk-On, Narrow Mega-Cap Bid, Defensive Rotation, Fake Breakout Risk, Broad Liquidation, Risk-Off, or Mixed/Chop.

- Compact Mode:
Offers a smaller, faster-read table layout for active trading screens.

- Adjustable Table Size:
Allows changing table text size from Tiny to Huge.

- Moveable Table Location:
Supports nine table positions across the chart: top, middle, bottom, and left, center, or right.

- Top 6 Mode:
Optionally shows only the six highest-ranked sectors to reduce screen clutter.

- Mini Plot:
Optional plot of net weighted sector contribution and tape quality score.

- Best Use Case:
Designed for intraday ES, SPX, and SPY traders who want to quickly see whether price action is broadly supported or narrowly driven.

- Important Note:
This tool estimates sector participation using SPDR sector ETFs and editable S&P 500 sector weights. It is intended as a market internals and participation read, not a buy or sell signal by itself.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © normantrades908

//@version=6
indicator("SPY/SPX Weighted Sector Tape Quality Dashboard v1.1", overlay=true, max_labels_count=500)

//----------------------------------------------------
// Symbols
//----------------------------------------------------
symXLK  = input.symbol("AMEX:XLK",  "Technology - XLK")
symXLF  = input.symbol("AMEX:XLF",  "Financials - XLF")
symXLV  = input.symbol("AMEX:XLV",  "Healthcare - XLV")
symXLY  = input.symbol("AMEX:XLY",  "Consumer Discretionary - XLY")
symXLC  = input.symbol("AMEX:XLC",  "Communication Services - XLC")
symXLI  = input.symbol("AMEX:XLI",  "Industrials - XLI")
symXLP  = input.symbol("AMEX:XLP",  "Consumer Staples - XLP")
symXLE  = input.symbol("AMEX:XLE",  "Energy - XLE")
symXLU  = input.symbol("AMEX:XLU",  "Utilities - XLU")
symXLB  = input.symbol("AMEX:XLB",  "Materials - XLB")
symXLRE = input.symbol("AMEX:XLRE", "Real Estate - XLRE")

// Optional confirmation symbols
symVIX = input.symbol("CBOE:VIX", "VIX Confirmation")
symSPY = input.symbol("AMEX:SPY", "SPY / Market Reference")

//----------------------------------------------------
// Editable SPX sector weights
//----------------------------------------------------
wXLK  = input.float(29.0, "Technology Weight %", step=0.1)
wXLF  = input.float(13.0, "Financials Weight %", step=0.1)
wXLV  = input.float(11.0, "Healthcare Weight %", step=0.1)
wXLY  = input.float(10.0, "Consumer Discretionary Weight %", step=0.1)
wXLC  = input.float(9.0,  "Communication Services Weight %", step=0.1)
wXLI  = input.float(8.0,  "Industrials Weight %", step=0.1)
wXLP  = input.float(6.0,  "Consumer Staples Weight %", step=0.1)
wXLE  = input.float(4.0,  "Energy Weight %", step=0.1)
wXLU  = input.float(2.5,  "Utilities Weight %", step=0.1)
wXLB  = input.float(2.0,  "Materials Weight %", step=0.1)
wXLRE = input.float(2.0,  "Real Estate Weight %", step=0.1)

//----------------------------------------------------
// Display settings
//----------------------------------------------------
tablePosInput = input.string("Top Right", "Table Position",
     options=[
         "Top Left", "Top Center", "Top Right",
         "Middle Left", "Middle Center", "Middle Right",
         "Bottom Left", "Bottom Center", "Bottom Right"
     ])

tableTextSizeInput = input.string("Small", "Table Text Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"])

compactMode = input.bool(false, "Compact Table Mode")

sortMode = input.string("SPX Weight", "Sort Table By",
     options=["SPX Weight", "Absolute Contribution", "Contribution"])

moveMode = input.string("Today From Open", "Move Calculation",
     options=["Today From Open", "Bar-to-Bar", "Lookback"])

lookbackBars = input.int(20, "Lookback Bars", minval=1)
showOnlyTop  = input.bool(false, "Show Only Top 6 Sectors")
showMiniPlot = input.bool(true, "Show Net Participation Mini Plot")

// Tape score tuning
scoreSmoothLen = input.int(3, "Tape Score Smoothing", minval=1)
megaCapThreshold = input.float(0.55, "Mega-Cap Concentration Threshold", step=0.05)

//----------------------------------------------------
// Table position
//----------------------------------------------------
tablePos =
     tablePosInput == "Top Left" ? position.top_left :
     tablePosInput == "Top Center" ? position.top_center :
     tablePosInput == "Top Right" ? position.top_right :
     tablePosInput == "Middle Left" ? position.middle_left :
     tablePosInput == "Middle Center" ? position.middle_center :
     tablePosInput == "Middle Right" ? position.middle_right :
     tablePosInput == "Bottom Left" ? position.bottom_left :
     tablePosInput == "Bottom Center" ? position.bottom_center :
     position.bottom_right

//----------------------------------------------------
// Table text size
//----------------------------------------------------
tableTextSize =
     tableTextSizeInput == "Tiny" ? size.tiny :
     tableTextSizeInput == "Small" ? size.small :
     tableTextSizeInput == "Normal" ? size.normal :
     tableTextSizeInput == "Large" ? size.large :
     size.huge

//----------------------------------------------------
// Data helpers
//----------------------------------------------------
getClose(sym) =>
    request.security(sym, timeframe.period, close)

getDayOpen(sym) =>
    request.security(sym, "D", open)

pctMove(sym) =>
    c = getClose(sym)
    dOpen = getDayOpen(sym)

    todayMove = dOpen != 0 ? ((c / dOpen) - 1) * 100 : 0
    barMove   = c[1] != 0 ? ((c / c[1]) - 1) * 100 : 0
    lbMove    = c[lookbackBars] != 0 ? ((c / c[lookbackBars]) - 1) * 100 : 0

    moveMode == "Today From Open" ? todayMove :
     moveMode == "Bar-to-Bar" ? barMove :
     lbMove

//----------------------------------------------------
// Sector moves
//----------------------------------------------------
mXLK  = pctMove(symXLK)
mXLF  = pctMove(symXLF)
mXLV  = pctMove(symXLV)
mXLY  = pctMove(symXLY)
mXLC  = pctMove(symXLC)
mXLI  = pctMove(symXLI)
mXLP  = pctMove(symXLP)
mXLE  = pctMove(symXLE)
mXLU  = pctMove(symXLU)
mXLB  = pctMove(symXLB)
mXLRE = pctMove(symXLRE)

// Market and VIX moves
mVIX = pctMove(symVIX)
mSPY = pctMove(symSPY)

//----------------------------------------------------
// Weighted contribution
//----------------------------------------------------
cXLK  = mXLK  * wXLK  / 100
cXLF  = mXLF  * wXLF  / 100
cXLV  = mXLV  * wXLV  / 100
cXLY  = mXLY  * wXLY  / 100
cXLC  = mXLC  * wXLC  / 100
cXLI  = mXLI  * wXLI  / 100
cXLP  = mXLP  * wXLP  / 100
cXLE  = mXLE  * wXLE  / 100
cXLU  = mXLU  * wXLU  / 100
cXLB  = mXLB  * wXLB  / 100
cXLRE = mXLRE * wXLRE / 100

//----------------------------------------------------
// Summary calculations
//----------------------------------------------------
netWeighted =
     cXLK + cXLF + cXLV + cXLY + cXLC + cXLI +
     cXLP + cXLE + cXLU + cXLB + cXLRE

positiveCount =
     (cXLK > 0 ? 1 : 0) +
     (cXLF > 0 ? 1 : 0) +
     (cXLV > 0 ? 1 : 0) +
     (cXLY > 0 ? 1 : 0) +
     (cXLC > 0 ? 1 : 0) +
     (cXLI > 0 ? 1 : 0) +
     (cXLP > 0 ? 1 : 0) +
     (cXLE > 0 ? 1 : 0) +
     (cXLU > 0 ? 1 : 0) +
     (cXLB > 0 ? 1 : 0) +
     (cXLRE > 0 ? 1 : 0)

weightedPositive =
     (cXLK > 0 ? wXLK : 0) +
     (cXLF > 0 ? wXLF : 0) +
     (cXLV > 0 ? wXLV : 0) +
     (cXLY > 0 ? wXLY : 0) +
     (cXLC > 0 ? wXLC : 0) +
     (cXLI > 0 ? wXLI : 0) +
     (cXLP > 0 ? wXLP : 0) +
     (cXLE > 0 ? wXLE : 0) +
     (cXLU > 0 ? wXLU : 0) +
     (cXLB > 0 ? wXLB : 0) +
     (cXLRE > 0 ? wXLRE : 0)

cyclicalScore  = cXLK + cXLF + cXLY + cXLC + cXLI + cXLE + cXLB
defensiveScore = cXLV + cXLP + cXLU
riskTone       = cyclicalScore - defensiveScore

megaCapImpact = cXLK + cXLC + cXLY
megaCapAbs    = math.abs(cXLK) + math.abs(cXLC) + math.abs(cXLY)

totalAbsImpact =
     math.abs(cXLK) + math.abs(cXLF) + math.abs(cXLV) + math.abs(cXLY) + math.abs(cXLC) +
     math.abs(cXLI) + math.abs(cXLP) + math.abs(cXLE) + math.abs(cXLU) + math.abs(cXLB) + math.abs(cXLRE)

megaCapConcentration = totalAbsImpact == 0 ? 0 : megaCapAbs / totalAbsImpact

//----------------------------------------------------
// Tape Quality Score
//----------------------------------------------------
// Components:
// 1. netWeighted: direction/strength of weighted sector contribution
// 2. weightedPositive: how much of SPX sector weight is positive
// 3. positiveCount: broad participation
// 4. riskTone: cyclicals vs defensives
// 5. VIX confirmation: falling VIX helps bullish tape; rising VIX hurts it

netComponent =
     netWeighted > 0.40 ? 25 :
     netWeighted > 0.15 ? 15 :
     netWeighted > 0.00 ? 7 :
     netWeighted < -0.40 ? -25 :
     netWeighted < -0.15 ? -15 :
     netWeighted < 0.00 ? -7 :
     0

weightedBreadthComponent =
     weightedPositive >= 75 ? 25 :
     weightedPositive >= 60 ? 15 :
     weightedPositive >= 50 ? 5 :
     weightedPositive <= 25 ? -25 :
     weightedPositive <= 40 ? -15 :
     weightedPositive < 50 ? -5 :
     0

sectorBreadthComponent =
     positiveCount >= 9 ? 20 :
     positiveCount >= 7 ? 12 :
     positiveCount >= 6 ? 5 :
     positiveCount <= 2 ? -20 :
     positiveCount <= 4 ? -12 :
     positiveCount <= 5 ? -5 :
     0

riskToneComponent =
     riskTone > 0.20 ? 15 :
     riskTone > 0.05 ? 8 :
     riskTone < -0.20 ? -15 :
     riskTone < -0.05 ? -8 :
     0

vixComponent =
     mVIX < -1.00 ? 15 :
     mVIX < -0.25 ? 8 :
     mVIX > 1.00 ? -15 :
     mVIX > 0.25 ? -8 :
     0

rawTapeScore = netComponent + weightedBreadthComponent + sectorBreadthComponent + riskToneComponent + vixComponent
tapeScore = ta.ema(rawTapeScore, scoreSmoothLen)

//----------------------------------------------------
// Tape classification
//----------------------------------------------------
broadRiskOn =
     tapeScore >= 55 and
     weightedPositive >= 70 and
     positiveCount >= 8 and
     riskTone > 0 and
     mVIX <= 0

narrowMegaCapBid =
     netWeighted > 0 and
     weightedPositive < 65 and
     positiveCount <= 6 and
     megaCapConcentration >= megaCapThreshold and
     megaCapImpact > 0

defensiveRotation =
     defensiveScore > cyclicalScore and
     defensiveScore > 0

fakeBreakoutRisk =
     mSPY > 0 and
     netWeighted > 0 and
     positiveCount <= 5 and
     weightedPositive < 55 and
     mVIX > 0

broadLiquidation =
     tapeScore <= -55 and
     weightedPositive <= 35 and
     positiveCount <= 4 and
     netWeighted < 0

broadRiskOff =
     tapeScore < -25 and
     netWeighted < 0 and
     positiveCount <= 5

tapeRead =
     broadRiskOn ? "BROAD RISK-ON" :
     fakeBreakoutRisk ? "FAKE BREAKOUT RISK" :
     narrowMegaCapBid ? "NARROW MEGA-CAP BID" :
     defensiveRotation ? "DEFENSIVE ROTATION" :
     broadLiquidation ? "BROAD LIQUIDATION" :
     broadRiskOff ? "RISK-OFF" :
     "MIXED / CHOP"

tapeReadCompact =
     broadRiskOn ? "RISK-ON" :
     fakeBreakoutRisk ? "FAKE?" :
     narrowMegaCapBid ? "MEGA" :
     defensiveRotation ? "DEF" :
     broadLiquidation ? "LIQ" :
     broadRiskOff ? "OFF" :
     "CHOP"

tapeColor =
     broadRiskOn ? color.green :
     fakeBreakoutRisk ? color.orange :
     narrowMegaCapBid ? color.yellow :
     defensiveRotation ? color.purple :
     broadLiquidation ? color.red :
     broadRiskOff ? color.maroon :
     color.gray

//----------------------------------------------------
// Older regime logic, still useful as secondary read
//----------------------------------------------------
broadBull  = netWeighted > 0 and positiveCount >= 8 and riskTone > 0
narrowBull = netWeighted > 0 and positiveCount <= 5
riskOff    = netWeighted > 0 and defensiveScore > cyclicalScore
broadBear  = netWeighted < 0 and positiveCount <= 3

regime =
     broadBull ? "BROAD BULL" :
     narrowBull ? "NARROW RALLY" :
     riskOff ? "DEFENSIVE BID" :
     broadBear ? "BROAD SELLING" :
     "MIXED"

regimeCompact =
     broadBull ? "BULL" :
     narrowBull ? "NARROW" :
     riskOff ? "DEF" :
     broadBear ? "BEAR" :
     "MIX"

regimeColor =
     broadBull ? color.green :
     narrowBull ? color.orange :
     riskOff ? color.purple :
     broadBear ? color.red :
     color.gray

//----------------------------------------------------
// Color helper
//----------------------------------------------------
impactColor(value, maxAbs) =>
    ratio = maxAbs == 0 ? 0 : math.min(math.abs(value) / maxAbs, 1)
    transparency = 88 - int(ratio * 78)

    value > 0 ? color.new(color.green, transparency) :
     value < 0 ? color.new(color.red, transparency) :
     color.new(color.gray, 80)

scoreColor(score) =>
    score >= 55 ? color.green :
     score >= 25 ? color.new(color.green, 35) :
     score <= -55 ? color.red :
     score <= -25 ? color.new(color.red, 35) :
     color.gray

//----------------------------------------------------
// Sector label arrays
//----------------------------------------------------
namesFull = array.from(
     "XLK Tech",
     "XLF Fin",
     "XLV Health",
     "XLY Disc",
     "XLC Comm",
     "XLI Ind",
     "XLP Stap",
     "XLE Energy",
     "XLU Util",
     "XLB Mat",
     "XLRE RE"
)

namesCompact = array.from(
     "XLK",
     "XLF",
     "XLV",
     "XLY",
     "XLC",
     "XLI",
     "XLP",
     "XLE",
     "XLU",
     "XLB",
     "XLRE"
)

names = compactMode ? namesCompact : namesFull

weights = array.from(
     wXLK,
     wXLF,
     wXLV,
     wXLY,
     wXLC,
     wXLI,
     wXLP,
     wXLE,
     wXLU,
     wXLB,
     wXLRE
)

moves = array.from(
     mXLK,
     mXLF,
     mXLV,
     mXLY,
     mXLC,
     mXLI,
     mXLP,
     mXLE,
     mXLU,
     mXLB,
     mXLRE
)

contribs = array.from(
     cXLK,
     cXLF,
     cXLV,
     cXLY,
     cXLC,
     cXLI,
     cXLP,
     cXLE,
     cXLU,
     cXLB,
     cXLRE
)

//----------------------------------------------------
// Sort values
//----------------------------------------------------
sortValues = array.new_float()

for i = 0 to 10
    contrib = array.get(contribs, i)
    weight  = array.get(weights, i)

    key =
         sortMode == "SPX Weight" ? weight :
         sortMode == "Absolute Contribution" ? math.abs(contrib) :
         contrib

    array.push(sortValues, key)

sortIndex = array.sort_indices(sortValues, order.descending)

//----------------------------------------------------
// Max contribution magnitude for brightness
//----------------------------------------------------
maxAbsContrib = 0.0

for i = 0 to 10
    maxAbsContrib := math.max(maxAbsContrib, math.abs(array.get(contribs, i)))

//----------------------------------------------------
// Table
//----------------------------------------------------
rowsToShow = showOnlyTop ? 6 : 11
var table t = table.new(tablePos, 6, 16, border_width=1)

if barstate.islast
    // Tape Quality Row
    table.cell(t, 0, 0, compactMode ? "Tape" : "Tape Quality", text_color=color.white, bgcolor=color.black, text_size=tableTextSize)
    table.cell(t, 1, 0, compactMode ? tapeReadCompact : tapeRead, text_color=color.white, bgcolor=tapeColor, text_size=tableTextSize)
    table.cell(t, 2, 0, "Score", text_color=color.white, bgcolor=color.black, text_size=tableTextSize)
    table.cell(t, 3, 0, str.tostring(tapeScore, "#"), text_color=color.white, bgcolor=scoreColor(tapeScore), text_size=tableTextSize)
    table.cell(t, 4, 0, "VIX", text_color=color.white, bgcolor=color.black, text_size=tableTextSize)
    table.cell(t, 5, 0, str.tostring(mVIX, "#.##") + "%", text_color=color.white, bgcolor=mVIX <= 0 ? color.green : color.red, text_size=tableTextSize)

    // Regime row
    table.cell(t, 0, 1, compactMode ? "Reg" : "Sector Regime", text_color=color.white, bgcolor=color.black, text_size=tableTextSize)
    table.cell(t, 1, 1, compactMode ? regimeCompact : regime, text_color=color.white, bgcolor=regimeColor, text_size=tableTextSize)
    table.cell(t, 2, 1, "Net", text_color=color.white, bgcolor=color.black, text_size=tableTextSize)
    table.cell(t, 3, 1, str.tostring(netWeighted, "#.###"), text_color=color.white, bgcolor=impactColor(netWeighted, math.max(maxAbsContrib, math.abs(netWeighted))), text_size=tableTextSize)
    table.cell(t, 4, 1, compactMode ? "Br" : "Breadth", text_color=color.white, bgcolor=color.black, text_size=tableTextSize)
    table.cell(t, 5, 1, str.tostring(positiveCount) + "/11", text_color=color.white, bgcolor=positiveCount >= 8 ? color.green : positiveCount <= 4 ? color.red : color.orange, text_size=tableTextSize)

    // Summary row
    table.cell(t, 0, 2, compactMode ? "W+" : "Weighted +", text_color=color.white, bgcolor=color.black, text_size=tableTextSize)
    table.cell(t, 1, 2, str.tostring(weightedPositive, "#.0") + "%", text_color=color.white, bgcolor=weightedPositive >= 70 ? color.green : weightedPositive <= 40 ? color.red : color.orange, text_size=tableTextSize)
    table.cell(t, 2, 2, compactMode ? "Cyc" : "Cyclical", text_color=color.white, bgcolor=color.black, text_size=tableTextSize)
    table.cell(t, 3, 2, str.tostring(cyclicalScore, "#.###"), text_color=color.white, bgcolor=impactColor(cyclicalScore, math.max(maxAbsContrib, math.abs(cyclicalScore))), text_size=tableTextSize)
    table.cell(t, 4, 2, compactMode ? "Def" : "Defensive", text_color=color.white, bgcolor=color.black, text_size=tableTextSize)
    table.cell(t, 5, 2, str.tostring(defensiveScore, "#.###"), text_color=color.white, bgcolor=impactColor(defensiveScore, math.max(maxAbsContrib, math.abs(defensiveScore))), text_size=tableTextSize)

    // Mega-cap row
    table.cell(t, 0, 3, compactMode ? "Mega" : "Mega-Cap", text_color=color.white, bgcolor=color.black, text_size=tableTextSize)
    table.cell(t, 1, 3, str.tostring(megaCapImpact, "#.###"), text_color=color.white, bgcolor=impactColor(megaCapImpact, math.max(maxAbsContrib, math.abs(megaCapImpact))), text_size=tableTextSize)
    table.cell(t, 2, 3, compactMode ? "Conc" : "Concentration", text_color=color.white, bgcolor=color.black, text_size=tableTextSize)
    table.cell(t, 3, 3, str.tostring(megaCapConcentration * 100, "#.0") + "%", text_color=color.white, bgcolor=megaCapConcentration >= megaCapThreshold ? color.orange : color.gray, text_size=tableTextSize)
    table.cell(t, 4, 3, "SPY", text_color=color.white, bgcolor=color.black, text_size=tableTextSize)
    table.cell(t, 5, 3, str.tostring(mSPY, "#.##") + "%", text_color=color.white, bgcolor=mSPY >= 0 ? color.green : color.red, text_size=tableTextSize)

    // Header
    table.cell(t, 0, 4, "#", text_color=color.white, bgcolor=color.rgb(20, 20, 20), text_size=tableTextSize)
    table.cell(t, 1, 4, compactMode ? "Sec" : "Sector", text_color=color.white, bgcolor=color.rgb(20, 20, 20), text_size=tableTextSize)
    table.cell(t, 2, 4, compactMode ? "Wt" : "Weight", text_color=color.white, bgcolor=color.rgb(20, 20, 20), text_size=tableTextSize)
    table.cell(t, 3, 4, compactMode ? "%" : "% Move", text_color=color.white, bgcolor=color.rgb(20, 20, 20), text_size=tableTextSize)
    table.cell(t, 4, 4, compactMode ? "Imp" : "Impact", text_color=color.white, bgcolor=color.rgb(20, 20, 20), text_size=tableTextSize)
    table.cell(t, 5, 4, compactMode ? "R" : "Read", text_color=color.white, bgcolor=color.rgb(20, 20, 20), text_size=tableTextSize)

    // Sector rows
    for row = 0 to rowsToShow - 1
        idx = array.get(sortIndex, row)

        nm = array.get(names, idx)
        wt = array.get(weights, idx)
        mv = array.get(moves, idx)
        ct = array.get(contribs, idx)

        bg = impactColor(ct, maxAbsContrib)

        readFull =
             ct > 0 and wt >= 8 ? "Heavy +"
             : ct < 0 and wt >= 8 ? "Heavy -"
             : ct > 0 ? "Support"
             : ct < 0 ? "Drag"
             : "Flat"

        readCompact =
             ct > 0 and wt >= 8 ? "H+"
             : ct < 0 and wt >= 8 ? "H-"
             : ct > 0 ? "+"
             : ct < 0 ? "-"
             : "0"

        read = compactMode ? readCompact : readFull

        table.cell(t, 0, row + 5, str.tostring(row + 1), text_color=color.white, bgcolor=color.black, text_size=tableTextSize)
        table.cell(t, 1, row + 5, nm, text_color=color.white, bgcolor=bg, text_size=tableTextSize)
        table.cell(t, 2, row + 5, str.tostring(wt, "#.0") + "%", text_color=color.white, bgcolor=bg, text_size=tableTextSize)
        table.cell(t, 3, row + 5, str.tostring(mv, "#.##") + "%", text_color=color.white, bgcolor=bg, text_size=tableTextSize)
        table.cell(t, 4, row + 5, str.tostring(ct, "#.###"), text_color=color.white, bgcolor=bg, text_size=tableTextSize)
        table.cell(t, 5, row + 5, read, text_color=color.white, bgcolor=bg, text_size=tableTextSize)

//----------------------------------------------------
// Optional mini plot
//----------------------------------------------------
plot(showMiniPlot ? netWeighted : na, title="Net Weighted Sector Contribution", color=color.white, linewidth=2)
plot(showMiniPlot ? tapeScore / 100 : na, title="Tape Quality Score / 100", color=color.yellow, linewidth=2)
hline(0, "Zero", color=color.gray)
````
