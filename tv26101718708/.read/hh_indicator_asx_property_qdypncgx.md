# HH Indicator - ASX Property

- url: https://www.tradingview.com/script/QdYPnCgX-HH-Indicator-ASX-Property/
- type: indicator
- pine_id: PUB;36ae31289f7b4be7a2fc37abcc7f8926
- version: 2.0

## Description

[i]ASX Property  Sector HH Indicator
[/i]
[b]Purpose
[/b]This indicator identifies when a stock closes above a previous pivot high. It can be used on any time frame.

[b]How it calculates levels:
[/b]
1. Last pivot high: The last "Pivot High" is identified when a candle is higher than (or equal to) the three candles before it and the three candles after it. This filters out non-significant peaks, but can also give false signals for peaks that are in sideways markets.

2. Price level to break: To determine the price that must be broken to make a new HH, the script takes the top of the candle body (i.e. the higher of the Open or Close) and ignores wicks.

[b]Reading the Table:
[/b]A "NEW HH" signal triggers in the indicator if the current candle closes above (or during trade, is above) the previously identified pivot high.

[b][i]Quirks[/i][/b]
1. Identifying a new HH for the 2nd time (when it isn't actually a new HH)
The indicator gives a "NEW HH" signal for a second time is if the stock closes back below the previous pivot high and then breaks out again on a later candle.

In the script, the "memory" isn't stored in a database; it’s just the math comparing Bar A to Bar B. If Bar A is under and Bar B is over, the green box turns on. If both are over, the "cross" didn't happen today, so the box stays gray.

2. Confirmation lag for new pivot highs
Because the script is waiting for 3 lower closes to mark a new pivot, there can be a delay in recording new pivot highs

## Source Code

````pine
//@version=6
indicator('ASX Property & Industrials - Bottom Right', overlay = true, max_labels_count = 500)

// --- 1. UNIVERSAL PIVOT LOGIC (HIGHEST BODY TOP) ---
checkTrend(ticker) =>
    [o, h, l, c] = request.security(ticker, timeframe.period, [open, high, low, close], ignore_invalid_symbol = true)
    top = math.max(o, c)
    btm = math.min(o, c)
    isManualPH = top[3] >= top[4] and top[3] >= top[5] and top[3] >= top[6] and top[3] >= top[2] and top[3] >= top[1] and top[3] >= top[0]
    isManualPL = btm[3] <= btm[4] and btm[3] <= btm[5] and btm[3] <= btm[6] and btm[3] <= btm[2] and btm[3] <= btm[1] and btm[3] <= btm[0]
    var float lastPHPrice = na
    if isManualPH
        lastPHPrice := top[3]
        lastPHPrice
    ta.crossover(c, lastPHPrice) and c > lastPHPrice

fillCell(tab, row, col, ticker, signal) =>
    table.cell(tab, col, row, ticker, text_color = color.white, text_size = size.normal)
    table.cell(tab, col + 1, row, signal ? 'NEW HH' : '-', bgcolor = signal ? color.new(color.green, 40) : na, text_color = color.white, text_size = size.normal)

fillHeader(tab, row, col, txt) =>
    table.merge_cells(tab, col, row, col + 1, row)
    table.cell(tab, col, row, txt, bgcolor = color.new(color.gray, 50), text_color = color.white, text_size = size.small)

// --- 2. TICKERS ---
// Col 1: Majors
t1 = input.symbol('ASX:GMG')
t2 = input.symbol('ASX:SCG')
t3 = input.symbol('ASX:DXS')
t4 = input.symbol('ASX:MGR')
t5 = input.symbol('ASX:VCX')
t6 = input.symbol('ASX:GPT')
t7 = input.symbol('ASX:CHC')
t8 = input.symbol('ASX:RGN')
t9 = input.symbol('ASX:CLW')
t10 = input.symbol('ASX:CIP')
// Col 2: Indus/Office
t11 = input.symbol('ASX:COF')
t12 = input.symbol('ASX:ARF')
t13 = input.symbol('ASX:CNI')
t14 = input.symbol('ASX:HMC')
t15 = input.symbol('ASX:HDN')
t16 = input.symbol('ASX:BWP')
t17 = input.symbol('ASX:CQE')
t18 = input.symbol('ASX:WPR')
t19 = input.symbol('ASX:GDF')
t20 = input.symbol('ASX:LLC')
// Col 3: Ret/Res
t21 = input.symbol('ASX:SGP')
t22 = input.symbol('ASX:LIC')
t23 = input.symbol('ASX:CQR')
t24 = input.symbol('ASX:RFF')
t25 = input.symbol('ASX:INA')
t26 = input.symbol('ASX:CMW')
t27 = input.symbol('ASX:REH')
t28 = input.symbol('ASX:APZ')
t29 = input.symbol('ASX:DXI')
t30 = input.symbol('ASX:SCP')
// Col 4: Industrials (combined Specialty)
t31 = input.symbol('ASX:TCL')
t32 = input.symbol('ASX:AZJ')
t33 = input.symbol('ASX:WOR')
t34 = input.symbol('ASX:BXB')
t35 = input.symbol('ASX:CWY')
t36 = input.symbol('ASX:QAN')
t37 = input.symbol('ASX:ALX')
t38 = input.symbol('ASX:DOW')
t39 = input.symbol('ASX:REH')
t40 = input.symbol('ASX:SGH')

// --- 3. EXECUTION ---
s1 = checkTrend(t1)
s2 = checkTrend(t2)
s3 = checkTrend(t3)
s4 = checkTrend(t4)
s5 = checkTrend(t5)
s6 = checkTrend(t6)
s7 = checkTrend(t7)
s8 = checkTrend(t8)
s9 = checkTrend(t9)
s10 = checkTrend(t10)
s11 = checkTrend(t11)
s12 = checkTrend(t12)
s13 = checkTrend(t13)
s14 = checkTrend(t14)
s15 = checkTrend(t15)
s16 = checkTrend(t16)
s17 = checkTrend(t17)
s18 = checkTrend(t18)
s19 = checkTrend(t19)
s20 = checkTrend(t20)
s21 = checkTrend(t21)
s22 = checkTrend(t22)
s23 = checkTrend(t23)
s24 = checkTrend(t24)
s25 = checkTrend(t25)
s26 = checkTrend(t26)
s27 = checkTrend(t27)
s28 = checkTrend(t28)
s29 = checkTrend(t29)
s30 = checkTrend(t30)
s31 = checkTrend(t31)
s32 = checkTrend(t32)
s33 = checkTrend(t33)
s34 = checkTrend(t34)
s35 = checkTrend(t35)
s36 = checkTrend(t36)
s37 = checkTrend(t37)
s38 = checkTrend(t38)
s39 = checkTrend(t39)
s40 = checkTrend(t40)

// --- 4. TABLE ---
var table tab = table.new(position.bottom_right, 8, 12, bgcolor = color.new(color.black, 0), border_width = 1, border_color = color.gray)
if barstate.islast
    table.merge_cells(tab, 0, 0, 7, 0)
    table.cell(tab, 0, 0, 'PROPERTY & INDUSTRIALS', bgcolor = color.new(color.teal, 30), text_color = color.white, text_size = size.normal)
    fillHeader(tab, 1, 0, 'MAJORS')
    fillHeader(tab, 1, 2, 'INDUS/OFF')
    fillHeader(tab, 1, 4, 'RET/RES')
    fillHeader(tab, 1, 6, 'INDUSTRIALS')

    // Column 1
    fillCell(tab, 2, 0, 'GMG', s1)
    fillCell(tab, 3, 0, 'SCG', s2)
    fillCell(tab, 4, 0, 'DXS', s3)
    fillCell(tab, 5, 0, 'MGR', s4)
    fillCell(tab, 6, 0, 'VCX', s5)
    fillCell(tab, 7, 0, 'GPT', s6)
    fillCell(tab, 8, 0, 'CHC', s7)
    fillCell(tab, 9, 0, 'RGN', s8)
    fillCell(tab, 10, 0, 'CLW', s9)
    fillCell(tab, 11, 0, 'CIP', s10)
    // Column 2
    fillCell(tab, 2, 2, 'COF', s11)
    fillCell(tab, 3, 2, 'ARF', s12)
    fillCell(tab, 4, 2, 'CNI', s13)
    fillCell(tab, 5, 2, 'HMC', s14)
    fillCell(tab, 6, 2, 'HDN', s15)
    fillCell(tab, 7, 2, 'BWP', s16)
    fillCell(tab, 8, 2, 'CQE', s17)
    fillCell(tab, 9, 2, 'WPR', s18)
    fillCell(tab, 10, 2, 'GDF', s19)
    fillCell(tab, 11, 2, 'LLC', s20)
    // Column 3
    fillCell(tab, 2, 4, 'SGP', s21)
    fillCell(tab, 3, 4, 'LIC', s22)
    fillCell(tab, 4, 4, 'CQR', s23)
    fillCell(tab, 5, 4, 'RFF', s24)
    fillCell(tab, 6, 4, 'INA', s25)
    fillCell(tab, 7, 4, 'CMW', s26)
    fillCell(tab, 8, 4, 'REH', s27)
    fillCell(tab, 9, 4, 'APZ', s28)
    fillCell(tab, 10, 4, 'DXI', s29)
    fillCell(tab, 11, 4, 'SCP', s30)
    // Column 4
    fillCell(tab, 2, 6, 'TCL', s31)
    fillCell(tab, 3, 6, 'AZJ', s32)
    fillCell(tab, 4, 6, 'WOR', s33)
    fillCell(tab, 5, 6, 'BXB', s34)
    fillCell(tab, 6, 6, 'CWY', s35)
    fillCell(tab, 7, 6, 'QAN', s36)
    fillCell(tab, 8, 6, 'ALX', s37)
    fillCell(tab, 9, 6, 'DOW', s38)
    fillCell(tab, 10, 6, 'REH', s39)
    fillCell(tab, 11, 6, 'SGH', s40)
````
