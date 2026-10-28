# Relative Strength vs Gold

- url: https://www.tradingview.com/script/tbwAzTSe-Relative-Strength-vs-Gold/
- type: indicator
- pine_id: PUB;875e8c879bbe430cba35f38f958cf3d9
- version: 1.0

## Description

This indicator compares the active chart against Gold over a selected lookback period

It calculates the percentage return of the active asset and subtracts the percentage return of Gold over the same period

Above zero means the active asset is outperforming Gold
Below zero means the active asset is underperforming Gold

The neutral zone helps filter very small differences around the zero line

The table automatically shows the active chart ticker versus Gold and displays the relative performance percentage in green, red, or gray

By default, the benchmark is TVC:GOLD

If you use another Gold feed, such as OANDA:XAUUSD, you may see small differences due to exchange and price feed variations

For the cleanest comparison, set the Gold benchmark input to match the Gold symbol you use on your chart

This is not a buy or sell signal, only a relative strength tool

## Source Code

````pine
//@version=6
indicator("Relative Strength vs Gold", overlay=false)

lookback = input.int(30, "Lookback period")
goldSymbol = input.symbol("TVC:GOLD", "Gold benchmark")
neutralZone = input.float(0.05, "Neutral zone in %")

assetClose = close
goldClose = request.security(goldSymbol, timeframe.period, close)

assetReturn = ((assetClose / assetClose[lookback]) - 1) * 100
goldReturn = ((goldClose / goldClose[lookback]) - 1) * 100

relativePerformance = assetReturn - goldReturn

isOutperforming = relativePerformance > neutralZone
isUnderperforming = relativePerformance < -neutralZone
isNeutral = not isOutperforming and not isUnderperforming

plot(relativePerformance, title="Relative performance vs Gold", linewidth=2)

hline(0, "Gold line", color=color.gray, linestyle=hline.style_dashed)
hline(neutralZone, "Neutral upper", color=color.new(color.gray, 70))
hline(-neutralZone, "Neutral lower", color=color.new(color.gray, 70))

bgcolor(
     isOutperforming ? color.new(color.green, 88) :
     isUnderperforming ? color.new(color.red, 88) :
     color.new(color.gray, 92)
)

var table infoTable = table.new(position.top_right, 1, 3)

currentAsset = syminfo.ticker

statusText = isOutperforming ? "Outperforming Gold" :
     isUnderperforming ? "Underperforming Gold" :
     "Neutral vs Gold"

relativeColor = isOutperforming ? color.green :
     isUnderperforming ? color.red :
     color.gray

if barstate.islast
    table.cell(
         infoTable, 0, 0,
         currentAsset + " vs Gold",
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
