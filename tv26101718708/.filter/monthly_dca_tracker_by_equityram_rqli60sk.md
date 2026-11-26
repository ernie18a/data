# Monthly DCA Tracker by Equityram

- url: https://www.tradingview.com/script/rqlI60sK-Monthly-DCA-Tracker-by-Equityram/
- type: indicator
- pine_id: PUB;42509f93645e4f83a7cb4ef64566bb05
- version: 2.0

## Description

Monthly DCA Tracker by Equityram helps investors test how a simple dollar-cost averaging strategy would have performed on any chart.

The indicator simulates investing a fixed amount every month, starting from a selected date. Users can choose the monthly investment amount, preferred monthly investment day, execution price type, benchmark symbol, annual return period, and table position.

The table shows:
• Total purchases
• Total shares accumulated
• Average purchase price
• Total invested
• Current portfolio value
• Profit
• Total return
• Average annual return
• Benchmark profit
• Benchmark return
• Benchmark average annual return
• Profit and return comparison versus the selected benchmark

If the selected monthly investment day is not available on the chart, the script uses the next available trading day.

This tool is designed for educational backtesting and long-term investing analysis. It does not provide financial advice, buy/sell recommendations, or future performance predictions.

## Source Code

````pine
//@version=6
indicator("Monthly DCA Tracker by Equityram", overlay=true)

// Inputs
monthlyAmount = input.float(100, "Monthly Investment ($)")
startDate = input.time(defval=1744070400000, title="Start Date")
monthlyInvestmentDay = input.int(1, "Monthly Investment Day", minval=1, maxval=31)
priceMethod = input.string("Open", "Purchase Price", options=["Open", "Close", "High", "Low", "OHLC4", "HLC3"])
benchmarkSymbol = input.symbol("AMEX:SPY", "Benchmark")
annualPeriod = input.string("10 Years", "Average Annual Return Period", options=["5 Years", "10 Years", "20 Years", "Selected Period"])
tablePositionInput = input.string("Bottom Right", "Table Position", options=["Bottom Right", "Middle Right", "Top Right"])

// Table position
tablePosition =
     tablePositionInput == "Bottom Right" ? position.bottom_right :
     tablePositionInput == "Top Right" ? position.top_right :
     position.middle_right

// Price selection
purchasePrice =
     priceMethod == "Open" ? open :
     priceMethod == "Close" ? close :
     priceMethod == "High" ? high :
     priceMethod == "Low" ? low :
     priceMethod == "OHLC4" ? ohlc4 :
     hlc3

// Benchmark prices
benchOpen = request.security(benchmarkSymbol, timeframe.period, open)
benchHigh = request.security(benchmarkSymbol, timeframe.period, high)
benchLow = request.security(benchmarkSymbol, timeframe.period, low)
benchClose = request.security(benchmarkSymbol, timeframe.period, close)
benchOHLC4 = request.security(benchmarkSymbol, timeframe.period, ohlc4)
benchHLC3 = request.security(benchmarkSymbol, timeframe.period, hlc3)

benchPurchasePrice =
     priceMethod == "Open" ? benchOpen :
     priceMethod == "Close" ? benchClose :
     priceMethod == "High" ? benchHigh :
     priceMethod == "Low" ? benchLow :
     priceMethod == "OHLC4" ? benchOHLC4 :
     benchHLC3

// Buy logic
var int lastBuyMonth = na
var int lastBuyYear = na

alreadyBoughtThisMonth = lastBuyMonth == month(time) and lastBuyYear == year(time)

firstPurchase = time >= startDate and time[1] < startDate
monthlyPurchase = time > startDate and dayofmonth(time) >= monthlyInvestmentDay and not alreadyBoughtThisMonth

buy = firstPurchase or monthlyPurchase

// Tracking
var float totalInvested = 0
var float totalShares = 0
var float benchmarkShares = 0
var int totalPurchases = 0

if buy
    totalInvested += monthlyAmount
    totalShares += monthlyAmount / purchasePrice
    benchmarkShares += monthlyAmount / benchPurchasePrice
    totalPurchases += 1
    lastBuyMonth := month(time)
    lastBuyYear := year(time)

// Portfolio metrics
portfolioValue = totalShares * close
profit = portfolioValue - totalInvested
returnPct = totalInvested > 0 ? profit / totalInvested * 100 : na
avgCost = totalShares > 0 ? totalInvested / totalShares : na

// Benchmark metrics
benchmarkValue = benchmarkShares * benchClose
benchmarkProfit = benchmarkValue - totalInvested
benchmarkReturnPct = totalInvested > 0 ? benchmarkProfit / totalInvested * 100 : na

// Annual return period
selectedYears = (time - startDate) / 31557600000.0

annualYears =
     annualPeriod == "5 Years" ? 5.0 :
     annualPeriod == "10 Years" ? 10.0 :
     annualPeriod == "20 Years" ? 20.0 :
     math.max(selectedYears, 0.01)

avgAnnualReturn = totalInvested > 0 ? (math.pow(1 + returnPct / 100, 1 / annualYears) - 1) * 100 : na
benchmarkAvgAnnualReturn = totalInvested > 0 ? (math.pow(1 + benchmarkReturnPct / 100, 1 / annualYears) - 1) * 100 : na

// Comparison metrics
profitVsBenchmark = profit - benchmarkProfit
returnVsBenchmark = returnPct - benchmarkReturnPct
annualVsBenchmark = avgAnnualReturn - benchmarkAvgAnnualReturn

// Clean benchmark name
benchmarkName = str.replace_all(benchmarkSymbol, "AMEX:", "")
benchmarkName := str.replace_all(benchmarkName, "BATS:", "")
benchmarkName := str.replace_all(benchmarkName, "NYSEARCA:", "")
benchmarkName := str.replace_all(benchmarkName, "NASDAQ:", "")
benchmarkName := str.replace_all(benchmarkName, "NYSE:", "")

// Colors/signs
pnlColor = profit >= 0 ? color.lime : color.red
benchmarkPnlColor = benchmarkProfit >= 0 ? color.lime : color.red
comparisonColor = returnVsBenchmark >= 0 ? color.lime : color.red

profitSign = profit >= 0 ? "+" : ""
returnSign = returnPct >= 0 ? "+" : ""
annualSign = avgAnnualReturn >= 0 ? "+" : ""

benchProfitSign = benchmarkProfit >= 0 ? "+" : ""
benchReturnSign = benchmarkReturnPct >= 0 ? "+" : ""
benchAnnualSign = benchmarkAvgAnnualReturn >= 0 ? "+" : ""

profitVsSign = profitVsBenchmark >= 0 ? "+" : ""
returnVsSign = returnVsBenchmark >= 0 ? "+" : ""
annualVsSign = annualVsBenchmark >= 0 ? "+" : ""

// Buy markers
plotshape(buy, title="Buy", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)

// Table
var table dcaTable = table.new(
     tablePosition,
     2,
     21,
     border_width=1,
     frame_color=color.rgb(70, 70, 70),
     border_color=color.rgb(45, 45, 45)
)

if barstate.islast
    bg = color.rgb(12, 12, 12)
    bgAlt = color.rgb(20, 20, 20)
    headerBg = color.rgb(35, 35, 35)
    spacerBg = color.rgb(8, 8, 8)
    mutedText = color.rgb(190, 190, 190)

    table.cell(dcaTable, 0, 0, "Monthly DCA", bgcolor=headerBg, text_color=color.white, text_size=size.normal)
    table.cell(dcaTable, 1, 0, syminfo.ticker + " | " + priceMethod, bgcolor=headerBg, text_color=color.white, text_size=size.normal)

    table.cell(dcaTable, 0, 1, "Purchases", bgcolor=bgAlt, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 1, str.tostring(totalPurchases), bgcolor=bgAlt, text_color=color.white, text_size=size.normal)

    table.cell(dcaTable, 0, 2, "Total Shares", bgcolor=bg, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 2, str.tostring(totalShares, "#.####"), bgcolor=bg, text_color=color.aqua, text_size=size.normal)

    table.cell(dcaTable, 0, 3, "Average Price", bgcolor=bgAlt, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 3, "$" + str.tostring(avgCost, "#,###.##"), bgcolor=bgAlt, text_color=color.yellow, text_size=size.normal)

    table.cell(dcaTable, 0, 4, "Total Invested", bgcolor=bg, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 4, "$" + str.tostring(totalInvested, "#,###.##"), bgcolor=bg, text_color=color.lime, text_size=size.normal)

    table.cell(dcaTable, 0, 5, "Portfolio Value", bgcolor=bgAlt, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 5, "$" + str.tostring(portfolioValue, "#,###.##"), bgcolor=bgAlt, text_color=pnlColor, text_size=size.normal)

    table.cell(dcaTable, 0, 6, "Profit", bgcolor=bg, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 6, profitSign + "$" + str.tostring(profit, "#,###.##"), bgcolor=bg, text_color=pnlColor, text_size=size.normal)

    table.cell(dcaTable, 0, 7, "Return", bgcolor=bgAlt, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 7, returnSign + str.tostring(returnPct, "#.##") + "%", bgcolor=bgAlt, text_color=pnlColor, text_size=size.normal)

    table.cell(dcaTable, 0, 8, "Avg Annual Return", bgcolor=bg, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 8, annualSign + str.tostring(avgAnnualReturn, "#.##") + "%", bgcolor=bg, text_color=pnlColor, text_size=size.normal)

    table.cell(dcaTable, 0, 9, "", bgcolor=spacerBg)
    table.cell(dcaTable, 1, 9, "", bgcolor=spacerBg)

    table.cell(dcaTable, 0, 10, benchmarkName + " Profit", bgcolor=bgAlt, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 10, benchProfitSign + "$" + str.tostring(benchmarkProfit, "#,###.##"), bgcolor=bgAlt, text_color=benchmarkPnlColor, text_size=size.normal)

    table.cell(dcaTable, 0, 11, benchmarkName + " Return", bgcolor=bg, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 11, benchReturnSign + str.tostring(benchmarkReturnPct, "#.##") + "%", bgcolor=bg, text_color=benchmarkPnlColor, text_size=size.normal)

    table.cell(dcaTable, 0, 12, benchmarkName + " Avg Annual", bgcolor=bgAlt, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 12, benchAnnualSign + str.tostring(benchmarkAvgAnnualReturn, "#.##") + "%", bgcolor=bgAlt, text_color=benchmarkPnlColor, text_size=size.normal)

    table.cell(dcaTable, 0, 13, "", bgcolor=spacerBg)
    table.cell(dcaTable, 1, 13, "", bgcolor=spacerBg)

    table.cell(dcaTable, 0, 14, "Profit vs " + benchmarkName, bgcolor=bg, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 14, profitVsSign + "$" + str.tostring(profitVsBenchmark, "#,###.##"), bgcolor=bg, text_color=comparisonColor, text_size=size.normal)

    table.cell(dcaTable, 0, 15, "Return vs " + benchmarkName, bgcolor=bgAlt, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 15, returnVsSign + str.tostring(returnVsBenchmark, "#.##") + "%", bgcolor=bgAlt, text_color=comparisonColor, text_size=size.normal)

    table.cell(dcaTable, 0, 16, "Annual vs " + benchmarkName, bgcolor=bg, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 16, annualVsSign + str.tostring(annualVsBenchmark, "#.##") + "%", bgcolor=bg, text_color=comparisonColor, text_size=size.normal)

    table.cell(dcaTable, 0, 17, "", bgcolor=spacerBg)
    table.cell(dcaTable, 1, 17, "", bgcolor=spacerBg)

    table.cell(dcaTable, 0, 18, "Monthly Day", bgcolor=bgAlt, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 18, str.tostring(monthlyInvestmentDay), bgcolor=bgAlt, text_color=color.white, text_size=size.normal)

    table.cell(dcaTable, 0, 19, "Annual Period", bgcolor=bg, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 19, annualPeriod, bgcolor=bg, text_color=color.white, text_size=size.normal)

    table.cell(dcaTable, 0, 20, "Benchmark", bgcolor=bgAlt, text_color=mutedText, text_size=size.normal)
    table.cell(dcaTable, 1, 20, benchmarkName, bgcolor=bgAlt, text_color=color.aqua, text_size=size.normal)
````
