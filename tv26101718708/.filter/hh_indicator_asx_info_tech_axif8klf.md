# HH Indicator - ASX Info Tech

- url: https://www.tradingview.com/script/Axif8kLf-HH-Indicator-ASX-Info-Tech/
- type: indicator
- pine_id: PUB;c85337bbb8694065828d2828f601f554
- version: 2.0

## Description

[i]ASX Info Tech Sector HH Indicator
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
indicator('ASX Info Tech 40 - Bottom Center (Trigger)', overlay = true)

// --- 1. UNIVERSAL PIVOT LOGIC (HIGHEST BODY TOP) ---
checkTrend(ticker) =>
    [o, h, l, c] = request.security(ticker, timeframe.period, [open, high, low, close], ignore_invalid_symbol = true)
    top = math.max(o, c)
    btm = math.min(o, c)

    isManualPH = top[3] >= top[4] and top[3] >= top[5] and top[3] >= top[6] and top[3] >= top[2] and top[3] >= top[1] and top[3] >= top[0]
    isManualPL = btm[3] <= btm[4] and btm[3] <= btm[5] and btm[3] <= btm[6] and btm[3] <= btm[2] and btm[3] <= btm[1] and btm[3] <= btm[0]

    var float lastPHPrice = na
    var float lastPLPrice = na
    var float prevPLPrice = na

    if isManualPH
        lastPHPrice := top[3]
        lastPHPrice
    if isManualPL
        prevPLPrice := lastPLPrice
        lastPLPrice := btm[3]
        lastPLPrice

    isBreakoutTrigger = ta.crossover(c, lastPHPrice)
    isBreakoutTrigger and c > lastPHPrice

fillCell(tab, row, col, ticker, signal) =>
    table.cell(tab, col, row, ticker, text_color = color.white, text_size = size.normal)
    table.cell(tab, col + 1, row, signal ? 'NEW HH' : '-', bgcolor = signal ? color.new(color.green, 40) : na, text_color = color.white, text_size = size.normal)

fillHeader(tab, row, col, txt) =>
    table.merge_cells(tab, col, row, col + 1, row)
    table.cell(tab, col, row, txt, bgcolor = color.new(color.gray, 50), text_color = color.white, text_size = size.small)

// --- 2. THE 40 INFO TECH TICKERS ---
// Col 1: SaaS & Software
t1 = input.symbol('ASX:WTC')
t2 = input.symbol('ASX:XRO')
t3 = input.symbol('ASX:CPU')
t4 = input.symbol('ASX:TNE')
t5 = input.symbol('ASX:NXT')
t6 = input.symbol('ASX:MAQ')
t7 = input.symbol('ASX:MP1')
t8 = input.symbol('ASX:5GN')
t33 = input.symbol('ASX:IRE')
t34 = input.symbol('ASX:OCL')
// Col 2: Data & Fintech
t9 = input.symbol('ASX:DUG')
t10 = input.symbol('ASX:TYR')
t11 = input.symbol('ASX:ZIP')
t12 = input.symbol('ASX:EML')
t13 = input.symbol('ASX:IEL')
t14 = input.symbol('ASX:DTL')
t15 = input.symbol('ASX:BRN')
t16 = input.symbol('ASX:DRO')
t35 = input.symbol('ASX:APX')
t36 = input.symbol('ASX:ART')
// Col 3: Medical Tech & Electronics
t17 = input.symbol('ASX:ABB')
t18 = input.symbol('ASX:PME')
t19 = input.symbol('ASX:HSN')
t20 = input.symbol('ASX:AD8')
t21 = input.symbol('ASX:CAT')
t22 = input.symbol('ASX:VMT')
t23 = input.symbol('ASX:SDR')
t24 = input.symbol('ASX:WBT')
t37 = input.symbol('ASX:4DX')
t38 = input.symbol('ASX:DDR')
// Col 4: Emerging & Digital
t25 = input.symbol('ASX:SLC')
t26 = input.symbol('ASX:BVS')
t27 = input.symbol('ASX:FDV')
t28 = input.symbol('ASX:CCR')
t29 = input.symbol('ASX:PLY')
t30 = input.symbol('ASX:CDA')
t31 = input.symbol('ASX:NVX')
t32 = input.symbol('ASX:HUB')
t39 = input.symbol('ASX:360')
t40 = input.symbol('ASX:AV1')

// --- 3. EXECUTION ---
s1 = checkTrend(t1)
s2 = checkTrend(t2)
s3 = checkTrend(t3)
s4 = checkTrend(t4)
s5 = checkTrend(t5)
s6 = checkTrend(t6)
s7 = checkTrend(t7)
s8 = checkTrend(t8)
s33 = checkTrend(t33)
s34 = checkTrend(t34)
s9 = checkTrend(t9)
s10 = checkTrend(t10)
s11 = checkTrend(t11)
s12 = checkTrend(t12)
s13 = checkTrend(t13)
s14 = checkTrend(t14)
s15 = checkTrend(t15)
s16 = checkTrend(t16)
s35 = checkTrend(t35)
s36 = checkTrend(t36)
s17 = checkTrend(t17)
s18 = checkTrend(t18)
s19 = checkTrend(t19)
s20 = checkTrend(t20)
s21 = checkTrend(t21)
s22 = checkTrend(t22)
s23 = checkTrend(t23)
s24 = checkTrend(t24)
s37 = checkTrend(t37)
s38 = checkTrend(t38)
s25 = checkTrend(t25)
s26 = checkTrend(t26)
s27 = checkTrend(t27)
s28 = checkTrend(t28)
s29 = checkTrend(t29)
s30 = checkTrend(t30)
s31 = checkTrend(t31)
s32 = checkTrend(t32)
s39 = checkTrend(t39)
s40 = checkTrend(t40)

// --- 4. ALERT ---
anySignal = s1 or s2 or s3 or s4 or s5 or s6 or s7 or s8 or s9 or s10 or s11 or s12 or s13 or s14 or s15 or s16 or s17 or s18 or s19 or s20 or s21 or s22 or s23 or s24 or s25 or s26 or s27 or s28 or s29 or s30 or s31 or s32 or s33 or s34 or s35 or s36 or s37 or s38 or s39 or s40
alertcondition(anySignal, 'Tech Trigger', 'An Info Tech stock JUST hit a NEW HH!')

// --- 5. TABLE ---
var table tab = table.new(position.bottom_center, 8, 12, bgcolor = color.new(color.black, 0), border_width = 1, border_color = color.gray)

if barstate.islast
    table.merge_cells(tab, 0, 0, 7, 0)
    table.cell(tab, 0, 0, 'INFO TECH', bgcolor = color.new(color.purple, 30), text_color = color.white, text_size = size.normal)
    fillHeader(tab, 1, 0, 'SAAS/CLOUD')
    fillHeader(tab, 1, 2, 'FIN/DATA')
    fillHeader(tab, 1, 4, 'MED/ELEC')
    fillHeader(tab, 1, 6, 'DIGITAL')

    // Col 1
    fillCell(tab, 2, 0, 'WTC', s1)
    fillCell(tab, 3, 0, 'XRO', s2)
    fillCell(tab, 4, 0, 'CPU', s3)
    fillCell(tab, 5, 0, 'TNE', s4)
    fillCell(tab, 6, 0, 'NXT', s5)
    fillCell(tab, 7, 0, 'MAQ', s6)
    fillCell(tab, 8, 0, 'MP1', s7)
    fillCell(tab, 9, 0, '5GN', s8)
    fillCell(tab, 10, 0, 'IRE', s33)
    fillCell(tab, 11, 0, 'OCL', s34)
    // Col 2
    fillCell(tab, 2, 2, 'DUG', s9)
    fillCell(tab, 3, 2, 'TYR', s10)
    fillCell(tab, 4, 2, 'ZIP', s11)
    fillCell(tab, 5, 2, 'EML', s12)
    fillCell(tab, 6, 2, 'IEL', s13)
    fillCell(tab, 7, 2, 'DTL', s14)
    fillCell(tab, 8, 2, 'BRN', s15)
    fillCell(tab, 9, 2, 'DRO', s16)
    fillCell(tab, 10, 2, 'APX', s35)
    fillCell(tab, 11, 2, 'ART', s36)
    // Col 3
    fillCell(tab, 2, 4, 'ABB', s17)
    fillCell(tab, 3, 4, 'PME', s18)
    fillCell(tab, 4, 4, 'HSN', s19)
    fillCell(tab, 5, 4, 'AD8', s20)
    fillCell(tab, 6, 4, 'CAT', s21)
    fillCell(tab, 7, 4, 'VMT', s22)
    fillCell(tab, 8, 4, 'SDR', s23)
    fillCell(tab, 9, 4, 'WBT', s24)
    fillCell(tab, 10, 4, '4DX', s37)
    fillCell(tab, 11, 4, 'DDR', s38)
    // Col 4
    fillCell(tab, 2, 6, 'SLC', s25)
    fillCell(tab, 3, 6, 'BVS', s26)
    fillCell(tab, 4, 6, 'FDV', s27)
    fillCell(tab, 5, 6, 'CCR', s28)
    fillCell(tab, 6, 6, 'PLY', s29)
    fillCell(tab, 7, 6, 'CDA', s30)
    fillCell(tab, 8, 6, 'NVX', s31)
    fillCell(tab, 9, 6, 'HUB', s32)
    fillCell(tab, 10, 6, '360', s39)
    fillCell(tab, 11, 6, 'AV1', s40)
````
