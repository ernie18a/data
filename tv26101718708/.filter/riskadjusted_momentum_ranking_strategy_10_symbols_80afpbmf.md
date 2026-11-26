# Risk-Adjusted Momentum Ranking + Strategy (10 Symbols)

- url: https://www.tradingview.com/script/80aFPBmF-Risk-Adjusted-Momentum-Ranking-Strategy-10-Symbols/
- type: indicator
- pine_id: PUB;94bec38af9834a5f9599b38d4c4e6c8a
- version: 1.0

## Description

Ohejsjdj dhhdj dhhddj ejsjdj
Sjjssj
Shhssj
Dhhssj
Jdjs

## Source Code

````pine
//@version=6
indicator("Risk-Adjusted Momentum Ranking + Strategy (10 Symbols)", overlay=false)

// === INPUTS ===
lookback_return = input.int(63, "Return Lookback (3 Months)")
lookback_vol    = input.int(20, "Volatility Lookback (20 Days)")
show_performance = input.bool(true, "Show Performance Lines")
perf_line_width  = input.int(1, "Performance Line Width", minval=1, maxval=2)
perf_transparency = input.int(30, "Performance Line Transparency", minval=0, maxval=90)
show_labels = input.bool(true, "Show Symbol Labels on Lines")
show_strategy = input.bool(true, "Show Strategy Performance Line")
strategy_color = input.color(color.white, "Strategy Line Color")
strategy_width = input.int(2, "Strategy Line Width", minval=1, maxval=3)
strategy_start_capital = input.float(100.0, "Strategy Start Capital", minval=1.0)
show_holdings_table = input.bool(true, "Show Holdings History Table")
holdings_table_rows = input.int(6, "Months of History to Show", minval=1, maxval=12)
show_metrics_table = input.bool(true, "Show Performance Metrics Table")
metrics_risk_free_rate = input.float(0.02, "Risk-Free Rate (for Sharpe)", minval=0, maxval=0.1, step=0.005)

// === SYMBOL INPUTS ===
sym1  = input.symbol("SPY", "Symbol 1")
sym2  = input.symbol("QQQ", "Symbol 2")
sym3  = input.symbol("XLE", "Symbol 3")
sym4  = input.symbol("DBC", "Symbol 4")
sym5  = input.symbol("SLV", "Symbol 5")
sym6  = input.symbol("GLD", "Symbol 6")
sym7  = input.symbol("EEM", "Symbol 7")
sym8  = input.symbol("MINT", "Symbol 8")
sym9  = input.symbol("PCY", "Symbol 9")
sym10 = input.symbol("CQQQ", "Symbol 10")

// === SCORE FUNCTION ===
calcScore(string sym) =>
    float price = request.security(sym, timeframe.period, close)
    float ret = price / price[lookback_return] - 1.0
    float daily_ret = request.security(sym, timeframe.period, close / close[1] - 1.0)
    float vol = ta.stdev(daily_ret, lookback_vol)
    vol := math.max(vol, 0.0001)
    ret / vol

// === PRE-CALCULATE SCORES ===
score1  = calcScore(sym1)
score2  = calcScore(sym2)
score3  = calcScore(sym3)
score4  = calcScore(sym4)
score5  = calcScore(sym5)
score6  = calcScore(sym6)
score7  = calcScore(sym7)
score8  = calcScore(sym8)
score9  = calcScore(sym9)
score10 = calcScore(sym10)

// === GLOBAL PRICES ===
p1  = request.security(sym1, timeframe.period, close)
p2  = request.security(sym2, timeframe.period, close)
p3  = request.security(sym3, timeframe.period, close)
p4  = request.security(sym4, timeframe.period, close)
p5  = request.security(sym5, timeframe.period, close)
p6  = request.security(sym6, timeframe.period, close)
p7  = request.security(sym7, timeframe.period, close)
p8  = request.security(sym8, timeframe.period, close)
p9  = request.security(sym9, timeframe.period, close)
p10 = request.security(sym10, timeframe.period, close)

// === CUMULATIVE PERFORMANCE ===
var float firstP1 = na
var float firstP2 = na
var float firstP3 = na
var float firstP4 = na
var float firstP5 = na
var float firstP6 = na
var float firstP7 = na
var float firstP8 = na
var float firstP9 = na
var float firstP10 = na

if na(firstP1) and not na(p1)
    firstP1 := p1
if na(firstP2) and not na(p2)
    firstP2 := p2
if na(firstP3) and not na(p3)
    firstP3 := p3
if na(firstP4) and not na(p4)
    firstP4 := p4
if na(firstP5) and not na(p5)
    firstP5 := p5
if na(firstP6) and not na(p6)
    firstP6 := p6
if na(firstP7) and not na(p7)
    firstP7 := p7
if na(firstP8) and not na(p8)
    firstP8 := p8
if na(firstP9) and not na(p9)
    firstP9 := p9
if na(firstP10) and not na(p10)
    firstP10 := p10

perf1  = firstP1 != 0 ? (p1 / firstP1 - 1.0) * 100 : 0
perf2  = firstP2 != 0 ? (p2 / firstP2 - 1.0) * 100 : 0
perf3  = firstP3 != 0 ? (p3 / firstP3 - 1.0) * 100 : 0
perf4  = firstP4 != 0 ? (p4 / firstP4 - 1.0) * 100 : 0
perf5  = firstP5 != 0 ? (p5 / firstP5 - 1.0) * 100 : 0
perf6  = firstP6 != 0 ? (p6 / firstP6 - 1.0) * 100 : 0
perf7  = firstP7 != 0 ? (p7 / firstP7 - 1.0) * 100 : 0
perf8  = firstP8 != 0 ? (p8 / firstP8 - 1.0) * 100 : 0
perf9  = firstP9 != 0 ? (p9 / firstP9 - 1.0) * 100 : 0
perf10 = firstP10 != 0 ? (p10 / firstP10 - 1.0) * 100 : 0

// === DAILY RETURNS ===
dr1  = p1 / p1[1] - 1.0
dr2  = p2 / p2[1] - 1.0
dr3  = p3 / p3[1] - 1.0
dr4  = p4 / p4[1] - 1.0
dr5  = p5 / p5[1] - 1.0
dr6  = p6 / p6[1] - 1.0
dr7  = p7 / p7[1] - 1.0
dr8  = p8 / p8[1] - 1.0
dr9  = p9 / p9[1] - 1.0
dr10 = p10 / p10[1] - 1.0

// === COLORS ===
color1 = color.new(#FF5252, perf_transparency)
color2 = color.new(#448AFF, perf_transparency)
color3 = color.new(#FFD740, perf_transparency)
color4 = color.new(#7E57C2, perf_transparency)
color5 = color.new(#26A69A, perf_transparency)
color6 = color.new(#FF9800, perf_transparency)
color7 = color.new(#EC407A, perf_transparency)
color8 = color.new(#26C6DA, perf_transparency)
color9 = color.new(#AED581, perf_transparency)
color10 = color.new(#B39DDB, perf_transparency)

// === ARRAYS ===
var table rankTable = table.new(position.top_left, 3, 11, border_width=1)
string[] symbols = array.new_string()
float[] scores = array.new_float()
color[] colors = array.new_color()

array.push(symbols, sym1)
array.push(scores, score1)
array.push(colors, color1)
array.push(symbols, sym2)
array.push(scores, score2)
array.push(colors, color2)
array.push(symbols, sym3)
array.push(scores, score3)
array.push(colors, color3)
array.push(symbols, sym4)
array.push(scores, score4)
array.push(colors, color4)
array.push(symbols, sym5)
array.push(scores, score5)
array.push(colors, color5)
array.push(symbols, sym6)
array.push(scores, score6)
array.push(colors, color6)
array.push(symbols, sym7)
array.push(scores, score7)
array.push(colors, color7)
array.push(symbols, sym8)
array.push(scores, score8)
array.push(colors, color8)
array.push(symbols, sym9)
array.push(scores, score9)
array.push(colors, color9)
array.push(symbols, sym10)
array.push(scores, score10)
array.push(colors, color10)

// === SORT ===
int sz = array.size(scores)
if sz > 1
    for i = 0 to sz - 2
        for j = i + 1 to sz - 1
            if array.get(scores, j) > array.get(scores, i)
                float tmp_s = array.get(scores, i)
                array.set(scores, i, array.get(scores, j))
                array.set(scores, j, tmp_s)
                string tmp_sym = array.get(symbols, i)
                array.set(symbols, i, array.get(symbols, j))
                array.set(symbols, j, tmp_sym)
                color tmp_c = array.get(colors, i)
                array.set(colors, i, array.get(colors, j))
                array.set(colors, j, tmp_c)

// === STRATEGY ===
bool isRebalanceDay = ta.change(time("1M")) != 0
var string hSym1 = na
var string hSym2 = na
var string hSym3 = na
var string hSym4 = na
var bool strategyInitialized = false

if isRebalanceDay and barstate.isconfirmed and array.size(symbols) >= 4
    hSym1 := array.get(symbols, 0)
    hSym2 := array.get(symbols, 1)
    hSym3 := array.get(symbols, 2)
    hSym4 := array.get(symbols, 3)
    strategyInitialized := true

// === GET DAILY RETURN BY SYMBOL ===
getDailyRet(string s) =>
    float ret = na
    if s == sym1
        ret := dr1
    else if s == sym2
        ret := dr2
    else if s == sym3
        ret := dr3
    else if s == sym4
        ret := dr4
    else if s == sym5
        ret := dr5
    else if s == sym6
        ret := dr6
    else if s == sym7
        ret := dr7
    else if s == sym8
        ret := dr8
    else if s == sym9
        ret := dr9
    else if s == sym10
        ret := dr10
    ret

var float stratEquity = strategy_start_capital
var float stratFirst = na
if na(stratFirst) and strategyInitialized
    stratFirst := stratEquity

if strategyInitialized and barstate.isconfirmed
    r1 = getDailyRet(hSym1)
    r2 = getDailyRet(hSym2)
    r3 = getDailyRet(hSym3)
    r4 = getDailyRet(hSym4)
    portfolioRet = (nz(r1, 0) + nz(r2, 0) + nz(r3, 0) + nz(r4, 0)) / 4.0
    stratEquity := stratEquity * (1 + portfolioRet)

strategyPerf = strategyInitialized ? (stratEquity - strategy_start_capital) : na
stratDailyRet = strategyInitialized ? (stratEquity / stratEquity[1] - 1.0) : na

// === HOLDINGS TRACKING WITH MONTHLY PERFORMANCE ===
var string[] rebalanceDates = array.new_string()
var string[] rebalanceH1 = array.new_string()
var string[] rebalanceH2 = array.new_string()
var string[] rebalanceH3 = array.new_string()
var string[] rebalanceH4 = array.new_string()
var float[] rebalanceP1 = array.new_float()
var float[] rebalanceP2 = array.new_float()
var float[] rebalanceP3 = array.new_float()
var float[] rebalanceP4 = array.new_float()

// Track monthly start prices for performance calculation
var float monthStartP1 = na
var float monthStartP2 = na
var float monthStartP3 = na
var float monthStartP4 = na
var float monthStartP5 = na
var float monthStartP6 = na
var float monthStartP7 = na
var float monthStartP8 = na
var float monthStartP9 = na
var float monthStartP10 = na

// Store previous month's holdings for performance calculation
var string[] prevH1 = array.new_string()
var string[] prevH2 = array.new_string()
var string[] prevH3 = array.new_string()
var string[] prevH4 = array.new_string()

// Helper function to get current price by symbol name
getCurPrice(string s) =>
    float price = na
    if s == sym1
        price := p1
    else if s == sym2
        price := p2
    else if s == sym3
        price := p3
    else if s == sym4
        price := p4
    else if s == sym5
        price := p5
    else if s == sym6
        price := p6
    else if s == sym7
        price := p7
    else if s == sym8
        price := p8
    else if s == sym9
        price := p9
    else if s == sym10
        price := p10
    price

// Helper function to get month start price by symbol name
getMonthStartPrice(string s) =>
    float price = na
    if s == sym1
        price := monthStartP1
    else if s == sym2
        price := monthStartP2
    else if s == sym3
        price := monthStartP3
    else if s == sym4
        price := monthStartP4
    else if s == sym5
        price := monthStartP5
    else if s == sym6
        price := monthStartP6
    else if s == sym7
        price := monthStartP7
    else if s == sym8
        price := monthStartP8
    else if s == sym9
        price := monthStartP9
    else if s == sym10
        price := monthStartP10
    price

// On rebalance day, calculate performance for PREVIOUS month's holdings
if isRebalanceDay and barstate.isconfirmed and array.size(symbols) >= 4
    string monthStr = str.format("{0,date,MMM yyyy}", time)
    
    // Get the 4 held symbols for THIS month
    string h1 = array.get(symbols, 0)
    string h2 = array.get(symbols, 1)
    string h3 = array.get(symbols, 2)
    string h4 = array.get(symbols, 3)
    
    // Calculate monthly performance for PREVIOUS month's holdings (if they exist)
    float perf1 = na
    float perf2 = na
    float perf3 = na
    float perf4 = na
    
    if array.size(prevH1) > 0
        // Get previous month's holdings
        string prevS1 = array.get(prevH1, 0)
        string prevS2 = array.get(prevH2, 0)
        string prevS3 = array.get(prevH3, 0)
        string prevS4 = array.get(prevH4, 0)
        
        // Calculate performance using current prices vs last month's start prices
        float cP1 = getCurPrice(prevS1)
        float sP1 = getMonthStartPrice(prevS1)
        perf1 = sP1 != 0 and not na(sP1) ? (cP1 / sP1 - 1.0) * 100 : na
        
        float cP2 = getCurPrice(prevS2)
        float sP2 = getMonthStartPrice(prevS2)
        perf2 = sP2 != 0 and not na(sP2) ? (cP2 / sP2 - 1.0) * 100 : na
        
        float cP3 = getCurPrice(prevS3)
        float sP3 = getMonthStartPrice(prevS3)
        perf3 = sP3 != 0 and not na(sP3) ? (cP3 / sP3 - 1.0) * 100 : na
        
        float cP4 = getCurPrice(prevS4)
        float sP4 = getMonthStartPrice(prevS4)
        perf4 = sP4 != 0 and not na(sP4) ? (cP4 / sP4 - 1.0) * 100 : na
        
        // Store previous month's data with performance
        array.unshift(rebalanceDates, monthStr)
        array.unshift(rebalanceH1, prevS1)
        array.unshift(rebalanceH2, prevS2)
        array.unshift(rebalanceH3, prevS3)
        array.unshift(rebalanceH4, prevS4)
        array.unshift(rebalanceP1, perf1)
        array.unshift(rebalanceP2, perf2)
        array.unshift(rebalanceP3, perf3)
        array.unshift(rebalanceP4, perf4)
        
        maxHistory = holdings_table_rows + 1
        if array.size(rebalanceDates) > maxHistory
            array.pop(rebalanceDates)
            array.pop(rebalanceH1)
            array.pop(rebalanceH2)
            array.pop(rebalanceH3)
            array.pop(rebalanceH4)
            array.pop(rebalanceP1)
            array.pop(rebalanceP2)
            array.pop(rebalanceP3)
            array.pop(rebalanceP4)
    
    // Store THIS month's holdings for next month's performance calculation
    array.unshift(prevH1, h1)
    array.unshift(prevH2, h2)
    array.unshift(prevH3, h3)
    array.unshift(prevH4, h4)
    
    // Reset monthly start prices for THIS month
    monthStartP1 := p1
    monthStartP2 := p2
    monthStartP3 := p3
    monthStartP4 := p4
    monthStartP5 := p5
    monthStartP6 := p6
    monthStartP7 := p7
    monthStartP8 := p8
    monthStartP9 := p9
    monthStartP10 := p10

// === HOLDINGS TABLE WITH PERFORMANCE ===
var table holdingsTable = table.new(position.bottom_right, 9, holdings_table_rows + 1, border_width=1, frame_width=1)
if barstate.islast and show_holdings_table and array.size(rebalanceDates) > 0
    table.clear(holdingsTable, 0, 0)
    table.cell(holdingsTable, 0, 0, "Month", bgcolor=color.rgb(32, 74, 188), text_color=color.white, text_size=size.large)
    table.cell(holdingsTable, 1, 0, "#1", bgcolor=color.rgb(44, 74, 157), text_color=color.white, text_size=size.large)
    table.cell(holdingsTable, 2, 0, "%", bgcolor=color.rgb(44, 74, 157), text_color=color.white, text_size=size.large)
    table.cell(holdingsTable, 3, 0, "#2", bgcolor=color.rgb(44, 74, 157), text_color=color.white, text_size=size.large)
    table.cell(holdingsTable, 4, 0, "%", bgcolor=color.rgb(44, 74, 157), text_color=color.white, text_size=size.large)
    table.cell(holdingsTable, 5, 0, "#3", bgcolor=color.rgb(44, 74, 157), text_color=color.white, text_size=size.large)
    table.cell(holdingsTable, 6, 0, "%", bgcolor=color.rgb(44, 74, 157), text_color=color.white, text_size=size.large)
    table.cell(holdingsTable, 7, 0, "#4", bgcolor=color.rgb(44, 74, 157), text_color=color.white, text_size=size.large)
    table.cell(holdingsTable, 8, 0, "%", bgcolor=color.rgb(44, 74, 157), text_color=color.white, text_size=size.large)
    
    historyCount = math.min(array.size(rebalanceDates), holdings_table_rows)
    for i = 0 to historyCount - 1
        string m = array.get(rebalanceDates, i)
        string s1 = array.get(rebalanceH1, i)
        string s2 = array.get(rebalanceH2, i)
        string s3 = array.get(rebalanceH3, i)
        string s4 = array.get(rebalanceH4, i)
        float p1_val = array.get(rebalanceP1, i)
        float p2_val = array.get(rebalanceP2, i)
        float p3_val = array.get(rebalanceP3, i)
        float p4_val = array.get(rebalanceP4, i)
        
        bgColor = i == 0 ? color.rgb(50, 100, 200) : color.rgb(30, 50, 100)
        
        table.cell(holdingsTable, 0, i + 1, m, bgcolor=bgColor, text_color=color.white, text_size=size.normal)
        table.cell(holdingsTable, 1, i + 1, s1, bgcolor=bgColor, text_color=color.white, text_size=size.normal)
        table.cell(holdingsTable, 2, i + 1, not na(p1_val) ? str.tostring(p1_val, "#.##") : "N/A", bgcolor=bgColor, text_color=color.white, text_size=size.normal)
        table.cell(holdingsTable, 3, i + 1, s2, bgcolor=bgColor, text_color=color.white, text_size=size.normal)
        table.cell(holdingsTable, 4, i + 1, not na(p2_val) ? str.tostring(p2_val, "#.##") : "N/A", bgcolor=bgColor, text_color=color.white, text_size=size.normal)
        table.cell(holdingsTable, 5, i + 1, s3, bgcolor=bgColor, text_color=color.white, text_size=size.normal)
        table.cell(holdingsTable, 6, i + 1, not na(p3_val) ? str.tostring(p3_val, "#.##") : "N/A", bgcolor=bgColor, text_color=color.white, text_size=size.normal)
        table.cell(holdingsTable, 7, i + 1, s4, bgcolor=bgColor, text_color=color.white, text_size=size.normal)
        table.cell(holdingsTable, 8, i + 1, not na(p4_val) ? str.tostring(p4_val, "#.##") : "N/A", bgcolor=bgColor, text_color=color.white, text_size=size.normal)

// === RANKING TABLE ===
if barstate.islast
    table.clear(rankTable, 0, 0)
    table.cell(rankTable, 0, 0, "Rank", bgcolor=color.rgb(32, 74, 188), text_color=color.white, text_size=size.large)
    table.cell(rankTable, 1, 0, "Symbol", bgcolor=color.rgb(44, 74, 157), text_color=color.white, text_size=size.large)
    table.cell(rankTable, 2, 0, "Score", bgcolor=color.rgb(18, 35, 82), text_color=color.white, text_size=size.large)
    for i = 0 to array.size(scores) - 1
        float sc = array.get(scores, i)
        string sym = array.get(symbols, i)
        color rowColor = array.get(colors, i)
        color bgColor = i == 0 ? color.new(rowColor, 0) : rowColor
        table.cell(rankTable, 0, i + 1, str.tostring(i + 1), bgcolor=bgColor, text_color=color.white, text_size=size.normal)
        table.cell(rankTable, 1, i + 1, sym, bgcolor=bgColor, text_color=color.white, text_size=size.normal)
        table.cell(rankTable, 2, i + 1, str.tostring(sc, "#.##"), bgcolor=bgColor, text_color=color.white, text_size=size.normal)

// === METRICS FUNCTIONS ===
calcCAGR(float startPrice, float endPrice, int totalBars) =>
    if na(startPrice) or na(endPrice) or startPrice <= 0 or endPrice <= 0 or totalBars <= 1
        na
    else
        math.pow(endPrice / startPrice, 252.0 / totalBars) - 1.0

calcAnnVol(float[] returns, int lookback) =>
    int arrSize = array.size(returns)
    if arrSize < 2 or arrSize < lookback
        na
    else
        float sum = 0.0
        float mean = 0.0
        int count = math.min(arrSize, lookback)
        for i = 0 to count - 1
            float val = array.get(returns, i)
            mean := mean + val
        mean := mean / count
        for i = 0 to count - 1
            float val = array.get(returns, i)
            float diff = val - mean
            sum := sum + diff * diff
        math.sqrt(sum / count) * math.sqrt(252)

calcSharpe(float annReturn, float annVol, float riskFree) =>
    if na(annReturn) or na(annVol) or annVol <= 0
        na
    else
        (annReturn - riskFree) / annVol

// === TRACK RETURNS ===
var float[] rets1 = array.new_float()
var float[] rets2 = array.new_float()
var float[] rets3 = array.new_float()
var float[] rets4 = array.new_float()
var float[] rets5 = array.new_float()
var float[] rets6 = array.new_float()
var float[] rets7 = array.new_float()
var float[] rets8 = array.new_float()
var float[] rets9 = array.new_float()
var float[] rets10 = array.new_float()
var float[] stratRets = array.new_float()

addRet(float[] arr, float ret) =>
    array.unshift(arr, nz(ret, 0))
    if array.size(arr) > 252
        array.pop(arr)

if barstate.isconfirmed
    addRet(rets1, dr1)
    addRet(rets2, dr2)
    addRet(rets3, dr3)
    addRet(rets4, dr4)
    addRet(rets5, dr5)
    addRet(rets6, dr6)
    addRet(rets7, dr7)
    addRet(rets8, dr8)
    addRet(rets9, dr9)
    addRet(rets10, dr10)
    if strategyInitialized
        addRet(stratRets, nz(stratDailyRet, 0))

// === FIRST BARS ===
var int firstBar1 = na
var int firstBar2 = na
var int firstBar3 = na
var int firstBar4 = na
var int firstBar5 = na
var int firstBar6 = na
var int firstBar7 = na
var int firstBar8 = na
var int firstBar9 = na
var int firstBar10 = na
var int firstBarStrat = na

if na(firstBar1) and not na(p1)
    firstBar1 := bar_index
if na(firstBar2) and not na(p2)
    firstBar2 := bar_index
if na(firstBar3) and not na(p3)
    firstBar3 := bar_index
if na(firstBar4) and not na(p4)
    firstBar4 := bar_index
if na(firstBar5) and not na(p5)
    firstBar5 := bar_index
if na(firstBar6) and not na(p6)
    firstBar6 := bar_index
if na(firstBar7) and not na(p7)
    firstBar7 := bar_index
if na(firstBar8) and not na(p8)
    firstBar8 := bar_index
if na(firstBar9) and not na(p9)
    firstBar9 := bar_index
if na(firstBar10) and not na(p10)
    firstBar10 := bar_index
if na(firstBarStrat) and strategyInitialized
    firstBarStrat := bar_index

// === METRICS CALCULATION ===
int bars1 = not na(firstBar1) ? (bar_index - firstBar1 + 1) : 0
float totalRet1 = firstP1 != 0 ? (p1 / firstP1 - 1.0) * 100 : na
float cagr1 = calcCAGR(firstP1, p1, bars1) * 100
float vol1 = calcAnnVol(rets1, math.min(array.size(rets1), 252)) * 100
float sharpe1 = calcSharpe(cagr1 / 100, vol1 / 100, metrics_risk_free_rate)

int bars2 = not na(firstBar2) ? (bar_index - firstBar2 + 1) : 0
float totalRet2 = firstP2 != 0 ? (p2 / firstP2 - 1.0) * 100 : na
float cagr2 = calcCAGR(firstP2, p2, bars2) * 100
float vol2 = calcAnnVol(rets2, math.min(array.size(rets2), 252)) * 100
float sharpe2 = calcSharpe(cagr2 / 100, vol2 / 100, metrics_risk_free_rate)

int bars3 = not na(firstBar3) ? (bar_index - firstBar3 + 1) : 0
float totalRet3 = firstP3 != 0 ? (p3 / firstP3 - 1.0) * 100 : na
float cagr3 = calcCAGR(firstP3, p3, bars3) * 100
float vol3 = calcAnnVol(rets3, math.min(array.size(rets3), 252)) * 100
float sharpe3 = calcSharpe(cagr3 / 100, vol3 / 100, metrics_risk_free_rate)

int bars4 = not na(firstBar4) ? (bar_index - firstBar4 + 1) : 0
float totalRet4 = firstP4 != 0 ? (p4 / firstP4 - 1.0) * 100 : na
float cagr4 = calcCAGR(firstP4, p4, bars4) * 100
float vol4 = calcAnnVol(rets4, math.min(array.size(rets4), 252)) * 100
float sharpe4 = calcSharpe(cagr4 / 100, vol4 / 100, metrics_risk_free_rate)

int bars5 = not na(firstBar5) ? (bar_index - firstBar5 + 1) : 0
float totalRet5 = firstP5 != 0 ? (p5 / firstP5 - 1.0) * 100 : na
float cagr5 = calcCAGR(firstP5, p5, bars5) * 100
float vol5 = calcAnnVol(rets5, math.min(array.size(rets5), 252)) * 100
float sharpe5 = calcSharpe(cagr5 / 100, vol5 / 100, metrics_risk_free_rate)

int bars6 = not na(firstBar6) ? (bar_index - firstBar6 + 1) : 0
float totalRet6 = firstP6 != 0 ? (p6 / firstP6 - 1.0) * 100 : na
float cagr6 = calcCAGR(firstP6, p6, bars6) * 100
float vol6 = calcAnnVol(rets6, math.min(array.size(rets6), 252)) * 100
float sharpe6 = calcSharpe(cagr6 / 100, vol6 / 100, metrics_risk_free_rate)

int bars7 = not na(firstBar7) ? (bar_index - firstBar7 + 1) : 0
float totalRet7 = firstP7 != 0 ? (p7 / firstP7 - 1.0) * 100 : na
float cagr7 = calcCAGR(firstP7, p7, bars7) * 100
float vol7 = calcAnnVol(rets7, math.min(array.size(rets7), 252)) * 100
float sharpe7 = calcSharpe(cagr7 / 100, vol7 / 100, metrics_risk_free_rate)

int bars8 = not na(firstBar8) ? (bar_index - firstBar8 + 1) : 0
float totalRet8 = firstP8 != 0 ? (p8 / firstP8 - 1.0) * 100 : na
float cagr8 = calcCAGR(firstP8, p8, bars8) * 100
float vol8 = calcAnnVol(rets8, math.min(array.size(rets8), 252)) * 100
float sharpe8 = calcSharpe(cagr8 / 100, vol8 / 100, metrics_risk_free_rate)

int bars9 = not na(firstBar9) ? (bar_index - firstBar9 + 1) : 0
float totalRet9 = firstP9 != 0 ? (p9 / firstP9 - 1.0) * 100 : na
float cagr9 = calcCAGR(firstP9, p9, bars9) * 100
float vol9 = calcAnnVol(rets9, math.min(array.size(rets9), 252)) * 100
float sharpe9 = calcSharpe(cagr9 / 100, vol9 / 100, metrics_risk_free_rate)

int bars10 = not na(firstBar10) ? (bar_index - firstBar10 + 1) : 0
float totalRet10 = firstP10 != 0 ? (p10 / firstP10 - 1.0) * 100 : na
float cagr10 = calcCAGR(firstP10, p10, bars10) * 100
float vol10 = calcAnnVol(rets10, math.min(array.size(rets10), 252)) * 100
float sharpe10 = calcSharpe(cagr10 / 100, vol10 / 100, metrics_risk_free_rate)

float stratFirstP = strategyInitialized ? stratFirst : na
float stratCurrP = strategyInitialized ? stratEquity : na
int stratBars = strategyInitialized and not na(firstBarStrat) ? (bar_index - firstBarStrat + 1) : 0
float stratTotalRet = stratFirstP != 0 ? (stratCurrP / stratFirstP - 1.0) * 100 : na
float stratCAGR = calcCAGR(stratFirstP, stratCurrP, stratBars) * 100
float stratAnnVol = calcAnnVol(stratRets, math.min(array.size(stratRets), 252)) * 100
float stratSharpe = calcSharpe(stratCAGR / 100, stratAnnVol / 100, metrics_risk_free_rate)

// === METRICS TABLE ===
var table metricsTable = table.new(position.bottom_left, 6, 12, border_width=1, frame_width=1)

if barstate.islast and show_metrics_table
    table.clear(metricsTable, 0, 0)
    table.cell(metricsTable, 0, 0, "Asset", bgcolor=color.rgb(32, 74, 188), text_color=color.white, text_size=size.large)
    table.cell(metricsTable, 1, 0, "Total Ret%", bgcolor=color.rgb(44, 74, 157), text_color=color.white, text_size=size.large)
    table.cell(metricsTable, 2, 0, "CAGR%", bgcolor=color.rgb(44, 74, 157), text_color=color.white, text_size=size.large)
    table.cell(metricsTable, 3, 0, "Vol%", bgcolor=color.rgb(44, 74, 157), text_color=color.white, text_size=size.large)
    table.cell(metricsTable, 4, 0, "Sharpe", bgcolor=color.rgb(44, 74, 157), text_color=color.white, text_size=size.large)
    table.cell(metricsTable, 5, 0, "Rank", bgcolor=color.rgb(18, 35, 82), text_color=color.white, text_size=size.large)
    
    table.cell(metricsTable, 0, 1, "STRATEGY", bgcolor=strategy_color, text_color=color.black, text_size=size.normal)
    table.cell(metricsTable, 1, 1, not na(stratTotalRet) ? str.tostring(stratTotalRet, "#.##") : "N/A", bgcolor=strategy_color, text_color=color.black, text_size=size.normal)
    table.cell(metricsTable, 2, 1, not na(stratCAGR) ? str.tostring(stratCAGR, "#.##") : "N/A", bgcolor=strategy_color, text_color=color.black, text_size=size.normal)
    table.cell(metricsTable, 3, 1, not na(stratAnnVol) ? str.tostring(stratAnnVol, "#.##") : "N/A", bgcolor=strategy_color, text_color=color.black, text_size=size.normal)
    table.cell(metricsTable, 4, 1, not na(stratSharpe) ? str.tostring(stratSharpe, "#.##") : "N/A", bgcolor=strategy_color, text_color=color.black, text_size=size.normal)
    table.cell(metricsTable, 5, 1, "-", bgcolor=strategy_color, text_color=color.black, text_size=size.normal)
    
    row = 2
    for i = 0 to array.size(symbols) - 1
        string sym = array.get(symbols, i)
        color rowColor = array.get(colors, i)
        float tr = na
        float cagr = na
        float vol = na
        float sharpe = na
        
        if sym == sym1
            tr := totalRet1
            cagr := cagr1
            vol := vol1
            sharpe := sharpe1
        if sym == sym2
            tr := totalRet2
            cagr := cagr2
            vol := vol2
            sharpe := sharpe2
        if sym == sym3
            tr := totalRet3
            cagr := cagr3
            vol := vol3
            sharpe := sharpe3
        if sym == sym4
            tr := totalRet4
            cagr := cagr4
            vol := vol4
            sharpe := sharpe4
        if sym == sym5
            tr := totalRet5
            cagr := cagr5
            vol := vol5
            sharpe := sharpe5
        if sym == sym6
            tr := totalRet6
            cagr := cagr6
            vol := vol6
            sharpe := sharpe6
        if sym == sym7
            tr := totalRet7
            cagr := cagr7
            vol := vol7
            sharpe := sharpe7
        if sym == sym8
            tr := totalRet8
            cagr := cagr8
            vol := vol8
            sharpe := sharpe8
        if sym == sym9
            tr := totalRet9
            cagr := cagr9
            vol := vol9
            sharpe := sharpe9
        if sym == sym10
            tr := totalRet10
            cagr := cagr10
            vol := vol10
            sharpe := sharpe10
        
        table.cell(metricsTable, 0, row, sym, bgcolor=rowColor, text_color=color.white, text_size=size.normal)
        table.cell(metricsTable, 1, row, not na(tr) ? str.tostring(tr, "#.##") : "N/A", bgcolor=rowColor, text_color=color.white, text_size=size.normal)
        table.cell(metricsTable, 2, row, not na(cagr) ? str.tostring(cagr, "#.##") : "N/A", bgcolor=rowColor, text_color=color.white, text_size=size.normal)
        table.cell(metricsTable, 3, row, not na(vol) ? str.tostring(vol, "#.##") : "N/A", bgcolor=rowColor, text_color=color.white, text_size=size.normal)
        table.cell(metricsTable, 4, row, not na(sharpe) ? str.tostring(sharpe, "#.##") : "N/A", bgcolor=rowColor, text_color=color.white, text_size=size.normal)
        table.cell(metricsTable, 5, row, str.tostring(i + 1), bgcolor=rowColor, text_color=color.white, text_size=size.normal)
        row := row + 1

// === PLOTTING ===
hline(0, "Zero Return", color=color.gray, linestyle=hline.style_dotted)

plot(show_performance ? perf1 : na, title="Sym1_Perf", color=show_performance ? color1 : na, linewidth=perf_line_width)
plot(show_performance ? perf2 : na, title="Sym2_Perf", color=show_performance ? color2 : na, linewidth=perf_line_width)
plot(show_performance ? perf3 : na, title="Sym3_Perf", color=show_performance ? color3 : na, linewidth=perf_line_width)
plot(show_performance ? perf4 : na, title="Sym4_Perf", color=show_performance ? color4 : na, linewidth=perf_line_width)
plot(show_performance ? perf5 : na, title="Sym5_Perf", color=show_performance ? color5 : na, linewidth=perf_line_width)
plot(show_performance ? perf6 : na, title="Sym6_Perf", color=show_performance ? color6 : na, linewidth=perf_line_width)
plot(show_performance ? perf7 : na, title="Sym7_Perf", color=show_performance ? color7 : na, linewidth=perf_line_width)
plot(show_performance ? perf8 : na, title="Sym8_Perf", color=show_performance ? color8 : na, linewidth=perf_line_width)
plot(show_performance ? perf9 : na, title="Sym9_Perf", color=show_performance ? color9 : na, linewidth=perf_line_width)
plot(show_performance ? perf10 : na, title="Sym10_Perf", color=show_performance ? color10 : na, linewidth=perf_line_width)

// === LABELS ===
var label[] perfLabels = array.new_label()
if barstate.islast and show_performance and show_labels
    for lbl in perfLabels
        label.delete(lbl)
    array.clear(perfLabels)
    array.push(perfLabels, label.new(x=bar_index, y=perf1, text=sym1, style=label.style_label_left, color=color1, textcolor=color.white, size=size.small))
    array.push(perfLabels, label.new(x=bar_index, y=perf2, text=sym2, style=label.style_label_left, color=color2, textcolor=color.white, size=size.small))
    array.push(perfLabels, label.new(x=bar_index, y=perf3, text=sym3, style=label.style_label_left, color=color3, textcolor=color.white, size=size.small))
    array.push(perfLabels, label.new(x=bar_index, y=perf4, text=sym4, style=label.style_label_left, color=color4, textcolor=color.white, size=size.small))
    array.push(perfLabels, label.new(x=bar_index, y=perf5, text=sym5, style=label.style_label_left, color=color5, textcolor=color.white, size=size.small))
    array.push(perfLabels, label.new(x=bar_index, y=perf6, text=sym6, style=label.style_label_left, color=color6, textcolor=color.white, size=size.small))
    array.push(perfLabels, label.new(x=bar_index, y=perf7, text=sym7, style=label.style_label_left, color=color7, textcolor=color.white, size=size.small))
    array.push(perfLabels, label.new(x=bar_index, y=perf8, text=sym8, style=label.style_label_left, color=color8, textcolor=color.white, size=size.small))
    array.push(perfLabels, label.new(x=bar_index, y=perf9, text=sym9, style=label.style_label_left, color=color9, textcolor=color.white, size=size.small))
    array.push(perfLabels, label.new(x=bar_index, y=perf10, text=sym10, style=label.style_label_left, color=color10, textcolor=color.white, size=size.small))

plot(show_strategy and strategyInitialized ? strategyPerf : na, title="Strategy_Perf", color=show_strategy ? strategy_color : na, linewidth=strategy_width, style=plot.style_line)

if barstate.islast and show_strategy and show_labels and strategyInitialized
    label.new(x=bar_index, y=strategyPerf, text="STRATEGY", style=label.style_label_left, color=strategy_color, textcolor=color.black, size=size.small, tooltip="Top-4 Equal-Weight Monthly Rotation\nRebalances: 1st trading day of each month")
````
