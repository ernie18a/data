# Relative Strength vs BTC

- url: https://www.tradingview.com/script/W9nQk2cJ-Relative-Strength-vs-BTC/
- type: indicator
- pine_id: PUB;23ccdd7bfbe8473b9504190e9b9b7777
- version: 1.0

## Description

This indicator compares the active chart against Bitcoin over a selected lookback period

It calculates the percentage return of the active asset and subtracts the percentage return of BTC over the same period

Above zero means the active asset is outperforming BTC
Below zero means the active asset is underperforming BTC

The table automatically shows the active chart ticker versus BTC and displays the relative performance percentage in green or red

By default, the benchmark is COINBASE

If you use another BTC feed, such as BINANCE, you may see small differences due to exchange and price feed variations

For the cleanest comparison, set the BTC benchmark input to match the BTC symbol you use on your chart

This is not a buy or sell signal, only a relative strength tool

## Source Code

````pine
//@version=6
indicator("Relative Strength vs BTC", overlay=false)

lookback = input.int(30, "Lookback period")
btcSymbol = input.symbol("COINBASE:BTCUSD", "BTC benchmark")
neutralZone = input.float(0.05, "Neutral zone in %")

assetClose = close
btcClose = request.security(btcSymbol, timeframe.period, close)

assetReturn = ((assetClose / assetClose[lookback]) - 1) * 100
btcReturn = ((btcClose / btcClose[lookback]) - 1) * 100

relativePerformance = assetReturn - btcReturn

isOutperforming = relativePerformance > neutralZone
isUnderperforming = relativePerformance < -neutralZone
isNeutral = not isOutperforming and not isUnderperforming

plot(relativePerformance, title="Relative performance vs BTC", linewidth=2)

hline(0, "BTC line", color=color.gray, linestyle=hline.style_dashed)
hline(neutralZone, "Neutral upper", color=color.new(color.gray, 70))
hline(-neutralZone, "Neutral lower", color=color.new(color.gray, 70))

bgcolor(
     isOutperforming ? color.new(color.green, 88) :
     isUnderperforming ? color.new(color.red, 88) :
     color.new(color.gray, 92)
)

var table infoTable = table.new(position.top_right, 1, 3)

currentAsset = syminfo.ticker

statusText = isOutperforming ? "Outperforming BTC" :
     isUnderperforming ? "Underperforming BTC" :
     "Neutral vs BTC"

relativeColor = isOutperforming ? color.green :
     isUnderperforming ? color.red :
     color.gray

if barstate.islast
    table.cell(
         infoTable, 0, 0,
         currentAsset + " vs BTC",
         bgcolor=color.white,
         text_color=color.black,
         text_size=size.normal
    )

    table.cell(
         infoTable, 0, 1,
         "Relative: " + str.tostring(relativePerformance, "#.##") + "%",
         bgcolor=color.white,
         text_color=relativeColor,
         text_size=size.normal
    )

    table.cell(
         infoTable, 0, 2,
         statusText,
         bgcolor=color.white,
         text_color=color.black,
         text_size=size.normal
    )
````
