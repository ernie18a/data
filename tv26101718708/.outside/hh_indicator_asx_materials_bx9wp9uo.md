# HH Indicator - ASX Materials

- url: https://www.tradingview.com/script/BX9WP9uO-HH-Indicator-ASX-Materials/
- type: indicator
- pine_id: PUB;2f13c4cd48f84c8ca11476b31117b5fc
- version: 2.0

## Description

[i]ASX Materials Sector HH Indicator
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
indicator('ASX Materials 40 - Top Center (Trigger)', overlay = true)

// --- 1. UNIVERSAL PIVOT LOGIC (HIGHEST BODY TOP) ---
checkTrend(ticker) =>
    // Added 'o' to the requested security data
    [o, h, l, c] = request.security(ticker, timeframe.period, [open, high, low, close], ignore_invalid_symbol = true)

    // Define the top of the candle body (ignores wicks)
    top = math.max(o, c)
    // Define the bottom of the candle body
    btm = math.min(o, c)

    // PIVOT CALCULATION: Now using 'top' and 'btm' instead of 'c'
    isManualPH = top[3] >= top[4] and top[3] >= top[5] and top[3] >= top[6] and top[3] >= top[2] and top[3] >= top[1] and top[3] >= top[0]
    isManualPL = btm[3] <= btm[4] and btm[3] <= btm[5] and btm[3] <= btm[6] and btm[3] <= btm[2] and btm[3] <= btm[1] and btm[3] <= btm[0]

    var float lastPHPrice = na
    var float lastPLPrice = na
    var float prevPLPrice = na
    var int lastPHBar = na
    var int lastTriggeredBar = na

    if isManualPH
        lastPHPrice := top[3]
        lastPHBar := bar_index[3]
        lastPHBar
    if isManualPL
        prevPLPrice := lastPLPrice
        lastPLPrice := btm[3]
        lastPLPrice

    // BREAKOUT TRIGGER: Current CLOSE vs the Last Pivot Body Top
    rawCross = ta.crossover(c, lastPHPrice) and c > lastPHPrice
    isHigherLow = lastPLPrice > prevPLPrice

    // FIX: only count this as a genuinely NEW signal if we haven't already
    // fired for this exact pivot (by bar index, not just price) - stops the
    // same stale/unconfirmed pivot level firing twice if price dips back
    // under it and re-crosses before a new pivot has had time to confirm,
    // while still allowing a real retest of the same price at a later,
    // genuinely different pivot to fire again.
    isBreakoutTrigger = rawCross and (na(lastTriggeredBar) or lastPHBar != lastTriggeredBar)

    if isBreakoutTrigger
        lastTriggeredBar := lastPHBar
        lastTriggeredBar

    isBreakoutTrigger

fillCell(tab, row, col, ticker, signal) =>
    table.cell(tab, col, row, ticker, text_color = color.white, text_size = size.normal)
    table.cell(tab, col + 1, row, signal ? 'NEW HH' : '-', bgcolor = signal ? color.new(color.green, 40) : na, text_color = color.white, text_size = size.normal)

fillHeader(tab, row, col, txt) =>
    table.merge_cells(tab, col, row, col + 1, row)
    table.cell(tab, col, row, txt, bgcolor = color.new(color.gray, 50), text_color = color.white, text_size = size.small)

// --- 2. THE TOP 40 MATERIALS TICKERS (RE-GROUPED) ---
// Column 1: Iron & Base Metals
t1 = input.symbol('ASX:BHP')
t2 = input.symbol('ASX:RIO')
t3 = input.symbol('ASX:FMG')
t4 = input.symbol('ASX:S32')
t5 = input.symbol('ASX:BSL')
t6 = input.symbol('ASX:SFR')
t7 = input.symbol('ASX:NIC')
t8 = input.symbol('ASX:ILU')
t9 = input.symbol('ASX:CIA')
t10 = input.symbol('ASX:USL')
// Column 2: Gold Giants (VAU moved here)
t11 = input.symbol('ASX:NST')
t12 = input.symbol('ASX:EVN')
t13 = input.symbol('ASX:NEM')
t14 = input.symbol('ASX:PRU')
t15 = input.symbol('ASX:RMS')
t16 = input.symbol('ASX:GMD')
t17 = input.symbol('ASX:WGX')
t18 = input.symbol('ASX:RRL')
t19 = input.symbol('ASX:OBM')
t20 = input.symbol('ASX:VAU')
// Column 3: Lithium & Battery (LKE added)
t21 = input.symbol('ASX:PLS')
t22 = input.symbol('ASX:MIN')
t23 = input.symbol('ASX:LTR')
t24 = input.symbol('ASX:IGO')
t25 = input.symbol('ASX:LYC')
t26 = input.symbol('ASX:POL')
t27 = input.symbol('ASX:WAF')
t28 = input.symbol('ASX:RSG')
t29 = input.symbol('ASX:BGL')
t30 = input.symbol('ASX:LKE')
// Column 4: Services & Specialty
t31 = input.symbol('ASX:JHX')
t32 = input.symbol('ASX:ORI')
t33 = input.symbol('ASX:GGP')
t34 = input.symbol('ASX:AMC')
t35 = input.symbol('ASX:AIS')
t36 = input.symbol('ASX:ALK')
t37 = input.symbol('ASX:PDI')
t38 = input.symbol('ASX:SMR')
t39 = input.symbol('ASX:DRR')
t40 = input.symbol('ASX:CSC')

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

// --- 4. ALERT LOGIC (RE-ADDED) ---
anySignal = s1 or s2 or s3 or s4 or s5 or s6 or s7 or s8 or s9 or s10 or s11 or s12 or s13 or s14 or s15 or s16 or s17 or s18 or s19 or s20 or s21 or s22 or s23 or s24 or s25 or s26 or s27 or s28 or s29 or s30 or s31 or s32 or s33 or s34 or s35 or s36 or s37 or s38 or s39 or s40
alertcondition(anySignal, 'Materials Trigger', 'A Materials stock JUST hit a NEW HH!')

// --- 5. TABLE GENERATION ---
var table tab = table.new(position.top_center, 8, 12, bgcolor = color.new(color.black, 0), border_width = 1, border_color = color.gray)

if barstate.islast
    table.merge_cells(tab, 0, 0, 7, 0)
    table.cell(tab, 0, 0, 'MATERIALS', bgcolor = color.new(color.gray, 20), text_color = color.white, text_size = size.normal)

    fillHeader(tab, 1, 0, 'IRON / BASE')
    fillHeader(tab, 1, 2, 'GOLD GIANTS')
    fillHeader(tab, 1, 4, 'LITHIUM / BAT')
    fillHeader(tab, 1, 6, 'SPEC / SERVICE')

    // Column 1
    fillCell(tab, 2, 0, 'BHP', s1)
    fillCell(tab, 3, 0, 'RIO', s2)
    fillCell(tab, 4, 0, 'FMG', s3)
    fillCell(tab, 5, 0, 'S32', s4)
    fillCell(tab, 6, 0, 'BSL', s5)
    fillCell(tab, 7, 0, 'SFR', s6)
    fillCell(tab, 8, 0, 'NIC', s7)
    fillCell(tab, 9, 0, 'ILU', s8)
    fillCell(tab, 10, 0, 'CIA', s9)
    fillCell(tab, 11, 0, 'USL', s10)

    // Column 2
    fillCell(tab, 2, 2, 'NST', s11)
    fillCell(tab, 3, 2, 'EVN', s12)
    fillCell(tab, 4, 2, 'NEM', s13)
    fillCell(tab, 5, 2, 'PRU', s14)
    fillCell(tab, 6, 2, 'RMS', s15)
    fillCell(tab, 7, 2, 'GMD', s16)
    fillCell(tab, 8, 2, 'WGX', s17)
    fillCell(tab, 9, 2, 'RRL', s18)
    fillCell(tab, 10, 2, 'OBM', s19)
    fillCell(tab, 11, 2, 'VAU', s20)

    // Column 3
    fillCell(tab, 2, 4, 'PLS', s21)
    fillCell(tab, 3, 4, 'MIN', s22)
    fillCell(tab, 4, 4, 'LTR', s23)
    fillCell(tab, 5, 4, 'IGO', s24)
    fillCell(tab, 6, 4, 'LYC', s25)
    fillCell(tab, 7, 4, 'POL', s26)
    fillCell(tab, 8, 4, 'WAF', s27)
    fillCell(tab, 9, 4, 'RSG', s28)
    fillCell(tab, 10, 4, 'BGL', s29)
    fillCell(tab, 11, 4, 'LKE', s30)

    // Column 4
    fillCell(tab, 2, 6, 'JHX', s31)
    fillCell(tab, 3, 6, 'ORI', s32)
    fillCell(tab, 4, 6, 'GGP', s33)
    fillCell(tab, 5, 6, 'AMC', s34)
    fillCell(tab, 6, 6, 'AIS', s35)
    fillCell(tab, 7, 6, 'ALK', s36)
    fillCell(tab, 8, 6, 'PDI', s37)
    fillCell(tab, 9, 6, 'SMR', s38)
    fillCell(tab, 10, 6, 'DRR', s39)
    fillCell(tab, 11, 6, 'CSC', s40)
````
