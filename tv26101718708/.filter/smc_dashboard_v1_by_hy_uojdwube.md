# SMC Dashboard V1 By Hy

- url: https://www.tradingview.com/script/uOjdWUbe-SMC-Dashboard-V1-By-Hy/
- type: indicator
- pine_id: PUB;d2b41cea6a984970acbcb92c100d50e4
- version: 1.0

## Description

Hãy để checklist làm việc và bạn sẽ tiếp kiệm được 1 khoản tiền và thời gian.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © huyassana409

//@version=6
//@version=6
indicator("SMC Dashboard V1 By Hy", overlay=true, max_labels_count=500)

//====================================================
// EMA BIAS
//====================================================

dailyEma34  = request.security(syminfo.tickerid, "D", ta.ema(close, 34))
dailyEma89  = request.security(syminfo.tickerid, "D", ta.ema(close, 89))
dailyEma200 = request.security(syminfo.tickerid, "D", ta.ema(close, 200))
dailyEma610 = request.security(syminfo.tickerid, "D", ta.ema(close, 610))

h4Ema34  = request.security(syminfo.tickerid, "240", ta.ema(close, 34))
h4Ema89  = request.security(syminfo.tickerid, "240", ta.ema(close, 89))
h4Ema200 = request.security(syminfo.tickerid, "240", ta.ema(close, 200))
h4Ema610 = request.security(syminfo.tickerid, "240", ta.ema(close, 610))

dailyBull =
     dailyEma34 > dailyEma89 and
     dailyEma89 > dailyEma200 and
     dailyEma200 > dailyEma610

dailyBear =
     dailyEma34 < dailyEma89 and
     dailyEma89 < dailyEma200 and
     dailyEma200 < dailyEma610

h4Bull =
     h4Ema34 > h4Ema89 and
     h4Ema89 > h4Ema200 and
     h4Ema200 > h4Ema610

h4Bear =
     h4Ema34 < h4Ema89 and
     h4Ema89 < h4Ema200 and
     h4Ema200 < h4Ema610

dailyBias = dailyBull ? "BULLISH" : dailyBear ? "BEARISH" : "NEUTRAL"
h4Bias    = h4Bull ? "BULLISH" : h4Bear ? "BEARISH" : "NEUTRAL"

//====================================================
// LIQUIDITY SWEEP
//====================================================

swingLen = input.int(5, "Swing Length")

prevHigh = ta.highest(high[1], swingLen)
prevLow  = ta.lowest(low[1], swingLen)

bullSweep =
     low < prevLow and
     close > prevLow

bearSweep =
     high > prevHigh and
     close < prevHigh

liquiditySweep = bullSweep or bearSweep

//====================================================
// MSS (BOS)
//====================================================

bosBull =
     close > ta.highest(high[1], swingLen)

bosBear =
     close < ta.lowest(low[1], swingLen)

mssConfirmed = bosBull or bosBear

//====================================================
// EQUILIBRIUM
//====================================================

rangeHigh = ta.highest(high, 20)
rangeLow  = ta.lowest(low, 20)

eq = (rangeHigh + rangeLow) / 2

equilibrium =
     math.abs(close - eq) / close < 0.01

//====================================================
// ICT MACRO WINDOW (VN TIME)
//====================================================

vnHour = hour(time, "Asia/Ho_Chi_Minh")

macroWindow =
     (vnHour >= 14 and vnHour < 17) or
     (vnHour >= 19 and vnHour < 22)

//====================================================
// SCORE
//====================================================

score = 0

score := score + (liquiditySweep ? 1 : 0)
score := score + (mssConfirmed ? 1 : 0)
score := score + (equilibrium ? 1 : 0)
score := score + (macroWindow ? 1 : 0)

setupStatus =
     score >= 4 ? "A+ SETUP" :
     score == 3 ? "A SETUP" :
     score == 2 ? "WATCHLIST" :
     "NO TRADE"

//====================================================
// TOP RIGHT TABLE
//====================================================

var table trendTable = table.new(
     position.top_right,
     2,
     3,
     border_width = 1)

if barstate.islast

    table.cell(trendTable, 0, 0, "SMC BIAS")
    table.cell(trendTable, 1, 0, "")

    table.cell(trendTable, 0, 1, "Daily")
    table.cell(trendTable, 1, 1, dailyBias)

    table.cell(trendTable, 0, 2, "H4")
    table.cell(trendTable, 1, 2, h4Bias)

//====================================================
// BOTTOM RIGHT TABLE
//====================================================

var table setupTable = table.new(
     position.bottom_right,
     2,
     7,
     border_width = 1)

if barstate.islast

    table.cell(setupTable, 0, 0, "SETUP CHECKLIST")
    table.cell(setupTable, 1, 0, "")

    table.cell(setupTable, 0, 1, "Liquidity Sweep")
    table.cell(setupTable, 1, 1, liquiditySweep ? "✓" : "✗")

    table.cell(setupTable, 0, 2, "MSS Confirmed")
    table.cell(setupTable, 1, 2, mssConfirmed ? "✓" : "✗")

    table.cell(setupTable, 0, 3, "Macro Window")
    table.cell(setupTable, 1, 3, macroWindow ? "✓" : "✗")

    table.cell(setupTable, 0, 4, "Equilibrium")
    table.cell(setupTable, 1, 4, equilibrium ? "✓" : "✗")

    table.cell(setupTable, 0, 5, "Score")
    table.cell(setupTable, 1, 5, str.tostring(score) + "/4")

    table.cell(setupTable, 0, 6, "Status")
    table.cell(setupTable, 1, 6, setupStatus)

//====================================================
// ALERTS
//====================================================

alertcondition(score >= 4, "A+ Setup", "SMC A+ Setup Found")
````
