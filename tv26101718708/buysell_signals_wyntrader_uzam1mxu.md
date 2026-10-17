# Buy/Sell Signals [WynTrader]

- url: https://www.tradingview.com/script/UzAM1mxu-Buy-Sell-Signals-WynTrader/
- type: indicator
- pine_id: PUB;36160fcf90734ce9b592cdaf7da14f6b
- version: 1.0

## Description

Buy/Sell Signals [WynTrader]

Hello dear Friend

Here is my Buy/Sell Signals [WynTrader] indicator that may help you easily run a Buy/Sell backtest Strategy, seeing, at a glance, performance results.

█ OVERVIEW

This indicator identifies trend changes and generates Buy/Sell signals as accurately as possible.  Its strength lies in the results Table, which lets you evaluate signal performance directly on the chart — compared to a simple Buy & Hold strategy — without running a full backtest.

█ CONCEPTS

This Buy/Sell Signals [WynTrader], compared to other tools that detect trend shifts, is simple, easy to use, and demonstrates its efficiency on its own, at a glance.

The Table results allow you to quickly evaluate signal performance, both on their own and compared to a Buy & Hold strategy. The Table calculations are fully s[i]ynchronized with the visible chart[/i] (WYSIWYG – What You See Is What You Get). You can also scroll the chart across different date ranges to see how a stock or product performs under various market conditions.

You can adjust the variables to suit your goals. The design is simple, with clear parameters and instant readability of Buy/Sell Signals on the chart and in the Table results, without complex interpretation needed. 

A Table shows the effectiveness of the signals on the current visible chart, providing immediate, realistic feedback performance. The Buy & Hold strategy results are also included for comparison with the Buy/Sell swing strategy. The Buy & Hold results start from the first Buy signal to ensure a fair comparison. Changing the parameters instantly updates the Table, giving a quick, immediate performance check.

█ FILTERS (Buy/Sell parameters)

This indicator generates Buy/Sell signals using optional and adjustable filters:
- Bollinger Bands Lookback Trend Filter
- High-Low vs Candle Range Threshold %
- Distance from Fast and Slow MAs Threshold %
Results are displayed in a Table on the chart, based on the currently visible start and end dates.

█ TABLE RESULTS (Buy/Sell signals performance)

The Results Calculation presented in the Table is based on the [i]Current Chart Visible Range[/i]. The Table shows the:
- Calculation Results of the Buy and Sell Signals activated on the chart
- Number of Trades (Signals)
- Winning Points
- Win Rate %
The Buy & Hold calculation starts at the first Buy encountered.

█ CAUTION

The Graal Indicator, even with AI, doesn't exist yet — maybe one day, but not now — depending on the chart product, volatility, probabilities, and unpredictable market behaviour. Don't rely on this tool to make trade decision, it's only a tool to, maybe, help assess a change of trend.

Seeing Buy/Sell signals on a chart is appealing, but assessing their performance in a Table makes it even more convincing — and without running a full backtest, you get a clear overview of performance immediately.

█ WYNTRADER

My name is WynTrader. I cumulate 24 years of experience. In 2001, I took an intensive technical analysis course taught by an exceptional friend, Cyril, who taught me everything I know.

After testing thousands of TradingView indicators over these 24 years, I've found none to be 100% accurate all the time. This Buy/Sell Signals indicator may outperform some others but is still not perfect. So, just be aware, and don't be fooled by this tool.

Enjoy!
WynTrader

## Source Code

````pine
//@version=6
indicator("Buy/Sell Signals [WynTrader]", shorttitle="Buy/Sell_wt", overlay=true)

// ~ Update 2025-11-21 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~ Optimal default parameter settings at their best (for now...)
// ~~~ Correction of calculation errors in certain situations
// ~~~ Enhancing Buy/Sell Signals Performance Efficiency
// ~ Note : the Table results represent a useful dynamic backtest at a glance
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~ SECTION TO IDENTIFY AND PLOT BUY / SELL SIGNALS ~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
source = input(close)

// ~~~ FAST and SLOW MOVING AVERAGES ~~~
Fast = input.int(26, "Fast-MA", inline="fast")
fastType = input.string("EMA", "Type", inline="fast", options=["SMA","EMA","RMA","WMA"])
Slow = input.int(35, "Slow-MA", inline="slow")
slowType = input.string("RMA", "Type", inline="slow", options=["SMA","EMA","RMA","WMA"])
getMA(src,len,typ) => typ=="EMA"?ta.ema(src,len):typ=="SMA"?ta.sma(src,len):typ=="WMA"?ta.wma(src,len):ta.rma(src,len)
FastMa = getMA(close, Fast, fastType)
SlowMa = getMA(close, Slow, slowType)

// ~~~ BOLLINGER BANDS ~~~
bb_length = input.int(7, "BB-Basis", inline="BB")
bb_mult = input.float(1.0, "Multi", minval=0.0, step=0.1, inline="BB")
basis = ta.sma(source, bb_length)
deviation = ta.stdev(source, bb_length)
Upper_band = basis + bb_mult * deviation
Lower_band = basis - bb_mult * deviation

// ~~~ BOLLINGER BANDS TREND FILTER ~~~
useBBbTrend = input.bool(true, "Bollinger Bands Lookback Trend Filter", inline="BF")
BBbLookback = input.int(2, " ", minval=0, inline="BF")
BBbUp = useBBbTrend ? Upper_band >= Upper_band[BBbLookback] : true
BBbDn = useBBbTrend ? Lower_band <= Lower_band[BBbLookback] : true

// ~~~ BAR HIGH-LOW RANGE FILTER ~~~
useRangeFilter = input.bool(true, "High-Low vs Candle Range Threshold %", inline="range")
highlowRangeFilter = input.float(0.3, " ", minval=0.0, step=0.1, inline="range")
candleRange = high - low
relDiffRange = candleRange != 0 ? math.abs(FastMa - SlowMa) / candleRange : 0.0
exceedRange = useRangeFilter ? relDiffRange >= highlowRangeFilter : true

// ~~~ DISTANCE from FAST or SLOW MAs FILTER ~~~
useDistanceFilter = input.bool(true, "Distance from Fast or Slow MAs Threshold %", inline="distance")
distancePct = input.float(5.0, " ", minval=0.0, step=0.1, inline="distance") / 100
distanceFromSlow = useDistanceFilter ? math.abs(close - SlowMa)/SlowMa >= distancePct : true
distanceFromFast = useDistanceFilter ? math.abs(close - FastMa)/FastMa >= distancePct : true

// ~~~ BUY / SELL SIGNALS LOGIC ~~~
var bool inBuy = false
var bool inSell = false
signalBuy  = (close > FastMa and close > SlowMa) and not inBuy and (BBbUp and (exceedRange or (distanceFromFast and distanceFromSlow)))
signalSell = (close < FastMa and close < SlowMa) and not inSell and (BBbDn and (exceedRange or (distanceFromFast and distanceFromSlow)))
inBuy  := signalBuy ? true : signalSell ? false : inBuy
inSell := signalSell ? true : signalBuy ? false : inSell

// ~~~ PLOT FAST / SLOW LINES and FILL IN BETWEEN ~~~
pFast = plot(FastMa, color=color.rgb(3,252,248,47), title="Fast-MA", linewidth=1, style=plot.style_stepline, display=display.none)
pSlow = plot(SlowMa, color=color.new(#f8f005,42), title="Slow-MA", linewidth=1, style=plot.style_stepline, display=display.none)
fill(pFast, pSlow, color=(FastMa > SlowMa ? color.new(#09f811, 93) : color.new(#f80a0a, 92)), title="Shading between MAs", display=display.none)

// ~~~ PLOT BUY / SELL SIGNALS ~~~
plotshape(signalBuy, title="Buy Signal", location=location.belowbar, color=color.rgb(5,213,250), style=shape.labelup, size=size.small, textcolor=color.black)
plotshape(signalSell, title="Sell Signal", location=location.abovebar, color=color.rgb(252,252,8), style=shape.labeldown, size=size.small, textcolor=color.black)
bgcolor(signalBuy ? color.rgb(2, 110, 116, 89) : signalSell ? color.rgb(146, 3, 3, 88) : na)

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~ SECTION TO CALCULATE AND PLOT TABLE PERFORMANCE RESULTS ~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// ~~~ DETERMINE ACTUAL START and END DATES ~~~
startDate = chart.left_visible_bar_time
endDate   = chart.right_visible_bar_time
inRange_time = time >= startDate and time <= endDate
isEndBar = inRange_time and time == endDate

// ~~~ INITIALIZE PROFIT/LOSS ARRAYS ~~~
var array<float> buyProfits   = array.new_float(0)
var array<float> sellProfits  = array.new_float(0)
var array<float> totalProfits = array.new_float(0)
var array<float> buyWins      = array.new_float(0)
var array<float> buyLosses    = array.new_float(0)
var array<float> sellWins     = array.new_float(0)
var array<float> sellLosses   = array.new_float(0)

// ~~~ INITIALIZE ENTRY/EXIT LOGIC VARIABLES ~~~
var bool inPos = false
var bool posBuy = false
var bool posSell = false
var float entryPrice = na
var float firstBuyPrice = na
var float firstSellPrice = na

// ~~~ CAPTURE CLOSE AT END OF RANGE ~~~
var float closeAtEnd = na
if isEndBar
    closeAtEnd := close

// ~~~ RESET ARRAYS WHEN CHART RANGE CHANGES ~~~
var int lastStartDate = na
if startDate != lastStartDate
    array.clear(buyProfits)
    array.clear(sellProfits)
    array.clear(totalProfits)
    array.clear(buyWins)
    array.clear(buyLosses)
    array.clear(sellWins)
    array.clear(sellLosses)
    inPos := false
    posBuy := false
    posSell := false
    entryPrice := na
    firstBuyPrice := na
    firstSellPrice := na
    closeAtEnd := na
    lastStartDate := startDate

// ~~~ BUY / SELL : ENTRY AND EXIT LOGIC ~~~
if inRange_time
    if inPos and ((posBuy and signalSell) or (posSell and signalBuy))
        profit = (close - entryPrice) * (posBuy ? 1 : -1)
        profit := math.round(profit, 0)
        array.push(totalProfits, profit)
        if posBuy
            array.push(buyProfits, profit)
            if profit > 0
                array.push(buyWins, profit)
            else
                array.push(buyLosses, profit)
        else
            array.push(sellProfits, profit)
            if profit > 0
                array.push(sellWins, profit)
            else
                array.push(sellLosses, profit)
        inPos := false
        entryPrice := na
        posBuy := false
        posSell := false

    if not inPos and (signalBuy or signalSell)
        entryPrice := close
        inPos := true
        posBuy := signalBuy
        posSell := signalSell
        if signalBuy and na(firstBuyPrice)
            firstBuyPrice := close
        else
            if signalSell and na(firstSellPrice)
                firstSellPrice := close

// ~~~ FINALIZE OPEN POSITION AT END DATE ~~~
var bool finalized = false
if isEndBar and inPos and not finalized
    profit = (close - entryPrice) * (posBuy ? 1 : -1)
    profit := math.round(profit, 0)
    array.push(totalProfits, profit)
    if posBuy
        array.push(buyProfits, profit)
        if profit > 0
            array.push(buyWins, profit)
        else
            array.push(buyLosses, profit)
    else
        array.push(sellProfits, profit)
        if profit > 0
            array.push(sellWins, profit)
        else
            array.push(sellLosses, profit)
    finalized := true
    inPos := false

// ~~~ RESULTS AND PERFORMANCE CALCULATION ~~~
nbBuy  = array.size(buyProfits)
nbSell = array.size(sellProfits)
nbTot  = nbBuy + nbSell
PtsBuy   = nbBuy  > 0 ? array.sum(buyProfits)  : 0.0
PtsSell  = nbSell > 0 ? array.sum(sellProfits) : 0.0
PtsTotal = nbTot  > 0 ? array.sum(totalProfits) : 0.0
BuyHoldPointsRaw = not na(firstBuyPrice) and not na(closeAtEnd) ? closeAtEnd - firstBuyPrice : 0.0
BuyHoldPoints = math.round(BuyHoldPointsRaw, 0)
BuyHold_PnL = not na(firstBuyPrice) and not na(closeAtEnd) and firstBuyPrice != 0 ? math.round(BuyHoldPoints / firstBuyPrice * 100, 0) : 0
Buy_PnL  = BuyHoldPoints != 0 ? math.round(PtsBuy / firstBuyPrice * 100, 0) : 0
Sell_PnL = BuyHoldPoints != 0 ? math.round(PtsSell / firstSellPrice * 100, 0) : 0
Tot_PnL  = BuyHoldPoints != 0 ? math.round(Buy_PnL + Sell_PnL, 0) : 0

// ~~~ FINAL VALUES AT END OF RANGE ~~~
var float finalClose     = na
var float finalPtsBuy    = na
var float finalPtsSell   = na
var float finalPtsTotal  = na
var int   finalNbBuy     = na
var int   finalNbSell    = na
var int   finalNbTot     = na
var float finalBHPts     = na
var float finalBH_PnL    = na
var float finalBuy_PnL   = na
var float finalSell_PnL  = na
var float finalTot_PnL   = na

if isEndBar
    finalClose     := closeAtEnd
    finalPtsBuy    := PtsBuy
    finalPtsSell   := PtsSell
    finalPtsTotal  := PtsTotal
    finalNbBuy     := nbBuy
    finalNbSell    := nbSell
    finalNbTot     := nbTot
    finalBHPts     := BuyHoldPoints
    finalBH_PnL    := BuyHold_PnL
    finalBuy_PnL   := Buy_PnL
    finalSell_PnL  := Sell_PnL
    finalTot_PnL   := Tot_PnL

// ~~~ TABLE DISPLAY ~~~
var table resultsBox = na
var string resultsPosition = input.string("middle_left", options=["bottom_right", "bottom_left", "top_right", "top_left", "middle_left", "middle_right"], inline="pf")
pos = resultsPosition == "bottom_right" ? position.bottom_right :
      resultsPosition == "bottom_left"  ? position.bottom_left  :
      resultsPosition == "top_right"    ? position.top_right    :
      resultsPosition == "top_left"     ? position.top_left     :
      resultsPosition == "middle_left"  ? position.middle_left  :
      position.middle_right

if na(resultsBox)
    resultsBox := table.new(pos, 5, 5, border_width=1)

if time >= endDate and not na(finalClose)
    startDateStr = str.format_time(startDate, "yy-MM-dd", "UTC")
    endDateStr   = str.format_time(endDate,   "yy-MM-dd", "UTC")

    table.cell(resultsBox, 0, 0, startDateStr + "   " + endDateStr, text_color=color.white, bgcolor=color.rgb(13,0,0,41), text_size=size.small, text_halign=text.align_right)
    table.cell(resultsBox, 1, 0, "Buy",   text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 2, 0, "Sell",  text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 3, 0, "Total", text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 4, 0, "B & H", text_color=color.white, bgcolor=color.rgb(13,0,0,41))

    table.cell(resultsBox, 0, 1, "Nb-Trades", text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 1, 1, str.tostring(finalNbBuy),  text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 2, 1, str.tostring(finalNbSell), text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 3, 1, str.tostring(finalNbTot),  text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 4, 1, "1",                       text_color=color.white, bgcolor=color.rgb(13,0,0,41))

    table.cell(resultsBox, 0, 2, "P & L Points", text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 1, 2, str.tostring(math.round(finalPtsBuy,0)),   text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 2, 2, str.tostring(math.round(finalPtsSell,0)),  text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 3, 2, str.tostring(math.round(finalPtsTotal,0)), text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 4, 2, str.tostring(finalBHPts),                  text_color=color.white, bgcolor=color.rgb(13,0,0,41))

    table.cell(resultsBox, 0, 3, "P & L %", text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 1, 3, str.tostring(finalBuy_PnL) + " %",  text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 2, 3, str.tostring(finalSell_PnL) + " %", text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 3, 3, str.tostring(finalTot_PnL) + " %",  text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 4, 3, str.tostring(finalBH_PnL) + " %",   text_color=color.white, bgcolor=color.rgb(13,0,0,41))
    table.cell(resultsBox, 4, 4)
````
