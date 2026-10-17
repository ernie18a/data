# DCA Calculator v10

- url: https://www.tradingview.com/script/3ONwsaRB/
- type: indicator
- pine_id: PUB;c576bd293a41437f914160d7b69adfb8
- version: 1.0

## Description

1. User Inputs (input.*)

This section creates the settings menu you see when you click the gear icon in TradingView.

Timeframe Settings: Determines when the script is active. It can automatically detect the first available data point (i_autoStart) or wait for a specific year (i_startYear). It also features a stopping mechanism (i_autoStop / i_stopYear) so you can simulate an investment period that ended in the past while tracking its value up to today.

EMA Filter Settings: This is the trend-following toggle (i_useEMA). If activated, it calculates an Exponential Moving Average (ta.ema).

Interest Settings: Allows you to define an annual percentage yield (i_interestRate) for the cash waiting on the sidelines.

2. Variables (var)

In Pine Script, using var means the variable is initialized only once on the very first bar and then remembers its value from bar to bar.

totalInvested: The total money transferred from your "bank" into the strategy.

totalShares: The fractional amount of the asset you actually own.

savedCash: The uninvested money sitting on the sidelines when the price is below the EMA.

totalInterestEarned: A tracker just to see how much of your final value came purely from interest.

3. The Core Logic: Time and Interest

Before making any trades, the script checks two things on every single bar (day):

Is it time to invest? isValidTimeForInvest checks if the current date falls between your chosen start and stop years.

Do we get interest? If you have savedCash > 0, it calculates exactly how many milliseconds have passed since the last bar, converts that to days, applies the daily interest rate, and adds the free money to your cash pile.

4. The Investment Logic

If the current date is within your active timeframe, the script looks for two specific events to deploy capital:

Event A: A New Month begins (isNewMonth).

It adds your i_monthlyInvestment to your totalInvested pool.

Check the EMA: If the EMA filter is ON and the current price is below the EMA line, it refuses to buy. Instead, it adds the money to savedCash.

Otherwise: It takes the monthly money PLUS any savedCash you've accumulated, divides it by the current closing price to calculate how many shares you get, and sets savedCash back to 0. It also draws a green label.

Event B: The Crossover (crossesOverEma).

If the price shoots up and crosses the EMA line from below to above, a new uptrend is signaled.

If you have a mountain of savedCash waiting, the script instantly buys shares with all of it on that exact day (drawing a blue label) instead of waiting for the 1st of the next month.

5. The Drawdown Logic

This block runs on every bar to find out how bad the psychological pain of the strategy was.

It calculates your currentPortfolioValue (the value of your shares + your uninvested cash).

It updates peakValue if your portfolio hits a new all-time high.

If the portfolio drops below the peakValue, it calculates the percentage drop. If this drop is worse than the previous maxDD (Maximum Drawdown), it records the new worst percentage and the exact date (maxDD_time).

6. The Results Table (table.*)

This part only executes on the very last bar of the chart (if barstate.islast).

It calculates your final Return on Investment (roi) and absolute net profit (profitAbs).

It dynamically builds the header text using syminfo.ticker (so it knows if you are looking at QQQ or GBTC) and your actual start/stop dates.

Finally, it draws the dark, semi-transparent box on the middle-right of your screen and populates all the rows with the final numbers, using green for profits and red for drawdowns to make it easy to read.

## Source Code

````pine
//@version=5
indicator("DCA Calculator v10", overlay=true, max_labels_count=500)

// --- User Inputs ---
i_monthlyInvestment = input.float(1000, title="Monthly Investment", minval=1)

grp_time = "Timeframe Settings"
i_autoStart = input.bool(true, title="Auto-start from chart beginning?", group=grp_time)
i_startYear = input.int(2003, title="Start Year (if not auto)", minval=1900, maxval=2100, group=grp_time)
i_autoStop = input.bool(true, title="Run until current day?", group=grp_time)
i_stopYear = input.int(2024, title="Stop Year for new investments", minval=1900, maxval=2100, group=grp_time)

// --- EMA Filter Inputs ---
grp_ema = "EMA Filter Settings"
i_useEMA = input.bool(false, title="Use EMA Filter to hold cash?", group=grp_ema)
i_emaLength = input.int(200, title="EMA Length", minval=1, step=5, group=grp_ema)

// --- Interest Settings ---
grp_int = "Interest Settings"
i_interestRate = input.float(2.0, title="Annual Interest on Cash (%)", minval=0.0, step=0.5, group=grp_int)

// --- Label Inputs ---
grp_vis = "Visual Settings"
i_showLabels = input.bool(true, title="Show Purchase Labels on Chart?", group=grp_vis)

// --- Variables for Calculation ---
var float totalInvested = 0.0
var float totalShares = 0.0
var float savedCash = 0.0
var float totalInterestEarned = 0.0
var int actualStartYear = na
var int actualStartMonth = na

// --- Variables for Drawdown ---
var float peakValue = 0.0
var float maxDD = 0.0
var int maxDD_time = na

// --- Indicators ---
emaVal = ta.ema(close, i_emaLength)
plot(i_useEMA ? emaVal : na, color=color.orange, title="Trend Filter EMA")
crossesOverEma = ta.crossover(close, emaVal)

// --- Time Check ---
isAfterStart = i_autoStart or (year(time) >= i_startYear)
isBeforeStop = i_autoStop or (year(time) <= i_stopYear)
isValidTimeForInvest = isAfterStart and isBeforeStop

isNewMonth = ta.change(time("M")) != 0
isFirstBar = barstate.isfirst

// --- Interest Logic (Executes on EVERY bar if cash exists) ---
if bar_index > 0 and savedCash > 0
    float daysPassed = (time - time[1]) / 86400000 
    float dailyRate = i_interestRate / 100 / 365
    float interestForBar = savedCash * dailyRate * daysPassed
    
    savedCash := savedCash + interestForBar
    totalInterestEarned := totalInterestEarned + interestForBar

// --- Investment Logic (Executes ONLY during valid timeframe) ---
if isValidTimeForInvest
    // 1. Regular Monthly Injection Logic
    if isNewMonth or isFirstBar
        if na(actualStartYear)
            actualStartYear := year(time)
            actualStartMonth := month(time)
        
        totalInvested := totalInvested + i_monthlyInvestment
        
        if i_useEMA and not na(emaVal) and close < emaVal
            savedCash := savedCash + i_monthlyInvestment
        else
            amountToInvest = i_monthlyInvestment + savedCash
            savedCash := 0.0 
            
            totalShares := totalShares + (amountToInvest / close)
            
            if i_showLabels and amountToInvest > 0
                label.new(bar_index, low, str.tostring(amountToInvest, "#"), color=color.new(color.green, 40), textcolor=color.white, style=label.style_label_up, size=size.small)
                
    // 2. Intra-Month Crossover Logic
    if i_useEMA and crossesOverEma and savedCash > 0
        amountToInvest = savedCash
        savedCash := 0.0 
        
        totalShares := totalShares + (amountToInvest / close)
        
        if i_showLabels and amountToInvest > 0
            label.new(bar_index, low, str.tostring(amountToInvest, "#"), color=color.new(color.blue, 40), textcolor=color.white, style=label.style_label_up, size=size.small)
            
// --- Drawdown Logic (Executes on EVERY bar to track full history) ---
if totalInvested > 0
    currentPortfolioValue = (totalShares * close) + savedCash
    
    if currentPortfolioValue > peakValue
        peakValue := currentPortfolioValue
        
    currentDD = peakValue > 0 ? ((currentPortfolioValue - peakValue) / peakValue) * 100 : 0.0
    
    if currentDD < maxDD
        maxDD := currentDD
        maxDD_time := time

// --- Results Table ---
var table dcaTable = table.new(position.middle_right, columns=2, rows=8, bgcolor=color.new(color.black, 70), border_width=1, border_color=color.gray)

if barstate.islast
    currentPortfolioValue = (totalShares * close) + savedCash
    profitAbs = currentPortfolioValue - totalInvested
    roi = totalInvested > 0 ? (profitAbs / totalInvested) * 100 : 0
    
    // Format Header Text to include End Date
    endText = i_autoStop ? "Today" : str.tostring(i_stopYear)
    startText = na(actualStartYear) ? "No Data" : syminfo.ticker + " DCA: " + str.tostring(actualStartMonth) + "/" + str.tostring(actualStartYear) + " - " + endText
    ddDateStr = na(maxDD_time) ? "" : " (" + str.tostring(year(maxDD_time)) + "-" + str.tostring(month(maxDD_time)) + "-" + str.tostring(dayofmonth(maxDD_time)) + ")"
    
    // Header
    table.cell(dcaTable, 0, 0, startText, text_color=color.white, text_halign=text.align_left, bgcolor=color.blue)
    table.cell(dcaTable, 1, 0, "", bgcolor=color.blue)
    
    // Data Rows
    table.cell(dcaTable, 0, 1, "Total Invested:", text_color=color.white, text_halign=text.align_left)
    table.cell(dcaTable, 1, 1, str.tostring(totalInvested, "#.##"), text_color=color.white, text_halign=text.align_right)
    
    table.cell(dcaTable, 0, 2, "Cash Reserve:", text_color=color.white, text_halign=text.align_left)
    table.cell(dcaTable, 1, 2, str.tostring(savedCash, "#.##"), text_color=color.yellow, text_halign=text.align_right)
    
    table.cell(dcaTable, 0, 3, "Interest Earned:", text_color=color.white, text_halign=text.align_left)
    table.cell(dcaTable, 1, 3, str.tostring(totalInterestEarned, "#.##"), text_color=color.aqua, text_halign=text.align_right)
    
    table.cell(dcaTable, 0, 4, "Current Value:", text_color=color.white, text_halign=text.align_left)
    table.cell(dcaTable, 1, 4, str.tostring(currentPortfolioValue, "#.##"), text_color=color.lime, text_halign=text.align_right)
    
    table.cell(dcaTable, 0, 5, "Net Profit:", text_color=color.white, text_halign=text.align_left)
    table.cell(dcaTable, 1, 5, str.tostring(profitAbs, "#.##"), text_color=profitAbs >= 0 ? color.lime : color.red, text_halign=text.align_right)
    
    table.cell(dcaTable, 0, 6, "Return (ROI):", text_color=color.white, text_halign=text.align_left)
    table.cell(dcaTable, 1, 6, str.tostring(roi, "#.##") + " %", text_color=roi >= 0 ? color.lime : color.red, text_halign=text.align_right)
    
    table.cell(dcaTable, 0, 7, "Max Drawdown:", text_color=color.white, text_halign=text.align_left)
    table.cell(dcaTable, 1, 7, str.tostring(maxDD, "#.##") + " %" + ddDateStr, text_color=color.red, text_halign=text.align_right)
````
