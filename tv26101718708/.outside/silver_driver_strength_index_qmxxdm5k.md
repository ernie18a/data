# Silver Driver Strength Index

- url: https://www.tradingview.com/script/qMxxDm5K-Silver-Driver-Strength-Index/
- type: indicator
- pine_id: PUB;506e125213fd4d3783b9e2ce01f244cc
- version: 1.0

## Description

Silver Driver Strength Index

This indicator compares Silver with the macro forces that often influence its move

It helps separate price strength from driver strength

Silver can rise because the backdrop is supportive
But that is not the same as Silver showing strength beyond its usual drivers

The index uses Gold, dollar strength, yields, real yields, inflation expectations, and volatility

Above 0 means Silver is showing strength beyond its drivers
Below 0 means the drivers are doing more of the work
Around 0 means Silver is moving broadly with the macro backdrop

This is not a buy or sell signal
It is a market context tool

## Source Code

````pine
//@version=6
indicator("Silver Driver Strength Index", overlay=false)

// Inputs
lookback = input.int(20, "Driver lookback", minval=1)
smoothLen = input.int(5, "Smoothing", minval=1)
neutralBand = input.float(0.25, "Neutral band", step=0.05)

silverSymbol = input.symbol("TVC:SILVER", "Silver")
goldSymbol = input.symbol("TVC:GOLD", "Gold")
dxySymbol = input.symbol("TVC:DXY", "Dollar Index")
us10ySymbol = input.symbol("TVC:US10Y", "US 10Y Yield")
realYieldSymbol = input.symbol("FRED:DFII10", "10Y Real Yield")
inflSymbol = input.symbol("FRED:T10YIE", "10Y Inflation Expectations")

showTable = input.bool(true, "Show status table")
tablePosInput = input.string("Middle Right", "Table position", options=["Top Right", "Middle Right", "Bottom Right"])

showBackground = input.bool(true, "Show background")
showZeroLine = input.bool(true, "Show zero line")

// Table position
tablePos =
     tablePosInput == "Top Right" ? position.top_right :
     tablePosInput == "Middle Right" ? position.middle_right :
     position.bottom_right

// Function
roc(src, len) =>
    100 * (src / src[len] - 1)

// Data
silver = request.security(silverSymbol, timeframe.period, close)
gold = request.security(goldSymbol, timeframe.period, close)
dxy = request.security(dxySymbol, timeframe.period, close)
us10y = request.security(us10ySymbol, timeframe.period, close)
realYield = request.security(realYieldSymbol, timeframe.period, close)
infl = request.security(inflSymbol, timeframe.period, close)

// Rate of change
silverROC = roc(silver, lookback)

goldROC = roc(gold, lookback)
dxyROC = roc(dxy, lookback)
us10yROC = roc(us10y, lookback)
realYieldROC = roc(realYield, lookback)
inflROC = roc(infl, lookback)

// Negative drivers are inverted
dxyAdj = -dxyROC
us10yAdj = -us10yROC
realYieldAdj = -realYieldROC

// Weighted driver basket
driverBasket =
     goldROC * 0.30 +
     dxyAdj * 0.25 +
     realYieldAdj * 0.20 +
     us10yAdj * 0.15 +
     inflROC * 0.10

// Silver strength versus drivers
indexRaw = silverROC - driverBasket
index = ta.ema(indexRaw, smoothLen)

// Status logic
isNeutral = math.abs(index) <= neutralBand
isPositive = index > neutralBand
isNegative = index < -neutralBand

statusText =
     isPositive ? "Silver Leads Drivers" :
     isNegative ? "Drivers Lead Silver" :
     "Balanced"

statusColor =
     isPositive ? color.new(color.green, 0) :
     isNegative ? color.new(color.red, 0) :
     color.new(color.gray, 0)

statusBgColor =
     isPositive ? color.new(color.green, 85) :
     isNegative ? color.new(color.red, 85) :
     color.new(color.gray, 85)

plotColor =
     isPositive ? color.green :
     isNegative ? color.red :
     color.gray

// Plot
hline(0, "Neutral", color=showZeroLine ? color.gray : color.new(color.gray, 100), linestyle=hline.style_dashed)

plot(index, "Silver Driver Strength", color=plotColor, linewidth=2)

bgcolor(
     showBackground ?
     isPositive ? color.new(color.green, 88) :
     isNegative ? color.new(color.red, 88) :
     color.new(color.gray, 92) :
     na
)

// Status table
var table statusTable = table.new(tablePos, 1, 3, border_width=1)

if showTable and barstate.islast
    table.cell(
         statusTable,
         0,
         0,
         "Silver Driver Index",
         text_color=color.white,
         bgcolor=color.new(color.black, 0),
         text_size=size.small
     )

    table.cell(
         statusTable,
         0,
         1,
         str.tostring(index, "#.##") + "%",
         text_color=statusColor,
         bgcolor=color.new(color.black, 0),
         text_size=size.large
     )

    table.cell(
         statusTable,
         0,
         2,
         statusText,
         text_color=statusColor,
         bgcolor=statusBgColor,
         text_size=size.small
     )
else if not showTable and barstate.islast
    table.clear(statusTable, 0, 0, 0, 2)
````
