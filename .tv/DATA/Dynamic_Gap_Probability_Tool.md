<!-- tradingview-pine-id: PUB;4a9ce9caf95e453ebbcfd283423282c0 -->
<!-- tradingviewscripts-format: 1 -->
# Dynamic Gap Probability Tool

Source: https://www.tradingview.com/script/EJMwjmDF-Dynamic-Gap-Probability-Tool/

## Description

Dynamic Gap Probability Tool measures the percentage gap between price and a chosen moving average, then analyzes your chart history to estimate the likelihood of the next candle moving up or down. It dynamically adjusts its sample size to ensure statistical robustness while focusing on the exact deviation level.

Originality and Value:
• Combines gap-based analysis with dynamic sample aggregation to balance precision and reliability.  
• Automatically extends the sample when exact matches are scarce, avoiding misleading signals on rare extreme moves.  
• Provides real “next-candle” probabilities based on historical occurrences rather than fixed thresholds or untested heuristics.  
• Adds value by giving traders an evidence-based edge: you see how similar past deviations actually played out.

How It Works:
1. Calculate gap = (close – moving average) / moving average * 100.  
2. Round the absolute gap to nearest percent (X%).  
3. Count historical bars where gap ≥ X% above or ≤ –X% below.  
4. If exact X% count is below the minimum occurrences threshold, include gaps at X+1%, X+2%, etc., until threshold is reached.  
5. Compute “next-candle” green vs. red probabilities from the aggregated sample.  
6. Display current gap, sample size, green probability, and red probability in a table.

Inputs:
• Moving Average Type (SMA, EMA, WMA, VWMA, HMA, SMMA, TMA)  
• Moving Average Period (default 200)  
• Minimum Occurrences Threshold (default 50)  
• Table position and styling options

Examples:
• If price is 3% above the 200-period SMA and 120 occurrences ≥3% are found, with 84 green next candles (70%) and 36 red (30%), the script displays “3% | 120 | 70% green | 30% red.”  
• If price is 8% below the SMA but only 20 exact matches exist, the script will include 9% and 10% gaps until it reaches 50 samples, then calculate probabilities from that broader set.

Why It’s Useful:
• Mean-reversion traders see green-probability signals at extreme overbought or oversold levels.  
• Trend-followers identify continuation likelihood when red probability is high.  
• Risk managers gauge reliability by inspecting sample size before acting on any signal.

Limitations:
• Historical probabilities do not guarantee future performance.  
• Results depend on timeframe and symbol, backtest with your data before trading.  
• Use realistic slippage and commission when overlaying on strategy scripts.

---

## Source Code

````pine
// @ Julien_Eche

//@version=6
indicator('Dynamic Gap Probability Tool', overlay=true)
maType = input.string('SMA', 'Moving Average', options=['SMA','EMA','WMA','VWMA','HMA','SMMA','TMA'], inline='MA')
averagePeriod = input(200, '', inline='MA')
maColor = input.color(color.blue, '', inline='MA')
showTable = input.bool(true, 'Display Table', inline='Position')
positionChoice = input.string('Top Right', '', options=['Top Right','Top Center','Top Left','Bottom Right','Bottom Center','Bottom Left','Middle Right','Middle Left'], inline='Position')
tableSize = input.string(size.normal, '', options=[size.auto, size.tiny, size.small, size.normal, size.large, size.huge], inline='Position')
showCandleCounter = input.bool(true, 'Show Candle Counter')
minOccurrences = input.int(50, 'Minimum Occurrences', inline='Position')

movingAverage = switch maType
    'SMA'  => ta.sma(close, averagePeriod)
    'EMA'  => ta.ema(close, averagePeriod)
    'WMA'  => ta.wma(close, averagePeriod)
    'VWMA' => ta.vwma(close, averagePeriod)
    'HMA'  => ta.hma(close, averagePeriod)
    'SMMA' => ta.rma(close, averagePeriod)
    'TMA'  => ta.sma(ta.sma(close, math.floor(averagePeriod/2)), math.ceil(averagePeriod/2))
plot(movingAverage, 'Moving Average', color=maColor, linewidth=2)

getPosition(choice) =>
    switch choice
        'Top Right'    => position.top_right
        'Top Center'   => position.top_center
        'Top Left'     => position.top_left
        'Bottom Right' => position.bottom_right
        'Bottom Center'=> position.bottom_center
        'Bottom Left'  => position.bottom_left
        'Middle Right' => position.middle_right
        'Middle Left'  => position.middle_left

var data = matrix.new<int>(1,4,0)
percentDev = (close - movingAverage) / movingAverage * 100
percentIndex = math.round(math.abs(percentDev))
above = close > movingAverage
below = close < movingAverage

if above
    idx = percentIndex
    if data.rows() <= idx
        for _ = data.rows() to idx
            data.add_row(data.rows(), array.from(0,0,0,0))
    data.set(idx, 0, data.get(idx,0) + 1)

if below
    idx = percentIndex
    if data.rows() <= idx
        for _ = data.rows() to idx
            data.add_row(data.rows(), array.from(0,0,0,0))
    data.set(idx, 1, data.get(idx,1) + 1)

if bar_index > 0
    prevAbove = above[1]
    prevBelow = below[1]
    prevDev = (close[1] - movingAverage[1]) / movingAverage[1] * 100
    prevIdx = math.round(math.abs(prevDev))
    if prevAbove
        if data.rows() <= prevIdx
            for _ = data.rows() to prevIdx
                data.add_row(data.rows(), array.from(0,0,0,0))
        data.set(prevIdx, 2, data.get(prevIdx,2) + 1)
    if prevBelow
        if data.rows() <= prevIdx
            for _ = data.rows() to prevIdx
                data.add_row(data.rows(), array.from(0,0,0,0))
        data.set(prevIdx, 3, data.get(prevIdx,3) + 1)

if showTable and barstate.islast
    var table1 = table.new(getPosition(positionChoice), 5, 2, chart.bg_color, color.black, 1, color(na), 1)
    headerColor = color.rgb(45,45,45)
    headerTextColor = color.rgb(255,255,255)
    table1.cell(0,0,'Current Deviation ' + (above ? 'Above ' : 'Below ') + maType + ' ' + str.tostring(averagePeriod), bgcolor=headerColor, text_color=headerTextColor, text_size=tableSize)
    table1.cell(1,0,'Total Occurrences in Available History', bgcolor=headerColor, text_color=headerTextColor, text_size=tableSize)
    table1.cell(2,0,'Next Green Candle Probability', bgcolor=headerColor, text_color=headerTextColor, text_size=tableSize)
    table1.cell(3,0,'Next Red Candle Probability', bgcolor=headerColor, text_color=headerTextColor, text_size=tableSize)
    x = percentIndex
    aggCount = 0
    aggGreen = 0
    aggRed = 0
    col = above ? 0 : 1
    for i = x to data.rows() - 1
        aggCount := aggCount + data.get(i, col)
        aggGreen := aggGreen + data.get(i,2)
        aggRed := aggRed + data.get(i,3)
        if aggCount >= minOccurrences
            break
    totalProbs = aggGreen + aggRed
    greenProb = totalProbs > 0 ? aggGreen/totalProbs*100 : na
    redProb = totalProbs > 0 ? aggRed/totalProbs*100 : na
    posColor = color.new(color.teal,10)
    negColor = color.rgb(230,103,103,10)
    table1.cell(0,1,str.tostring(x) + '%', bgcolor=above ? posColor : negColor, text_color=chart.fg_color, text_size=tableSize)
    table1.cell(1,1,str.tostring(aggCount), bgcolor=above ? posColor : negColor, text_color=chart.fg_color, text_size=tableSize)
    table1.cell(2,1,str.tostring(greenProb,format.percent), bgcolor=greenProb > redProb ? posColor : headerColor, text_color=chart.fg_color, text_size=tableSize)
    table1.cell(3,1,str.tostring(redProb,format.percent), bgcolor=greenProb < redProb ? negColor : headerColor, text_color=chart.fg_color, text_size=tableSize)
````
