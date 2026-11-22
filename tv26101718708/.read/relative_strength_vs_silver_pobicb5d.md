# Relative Strength vs Silver

- url: https://www.tradingview.com/script/pOBICB5D-Relative-Strength-vs-Silver/
- type: indicator
- pine_id: PUB;9f289f1bd2d841b4a53d786fa7d5826a
- version: 1.0

## Description

This indicator compares the active chart against Silver over a selected lookback period

It calculates the percentage return of the active asset and subtracts the percentage return of Silver over the same period

Above zero means the active asset is outperforming Silver
Below zero means the active asset is underperforming Silver

The table automatically shows the active chart ticker versus Silver and displays the relative performance percentage in green or red

By default, the benchmark is TVC:SILVER

If you use another Silver feed, such as OANDA:XAGUSD, you may see small differences due to exchange and price feed variations

For the cleanest comparison, set the Silver benchmark input to match the Silver symbol you use on your chart

This is not a buy or sell signal, only a relative strength tool

## Source Code

````pine
//@version=6
indicator("Relative Strength vs Silver", overlay=false)

lookback = input.int(30, "Lookback period")
silverSymbol = input.symbol("TVC:SILVER", "Silver benchmark")
neutralZone = input.float(0.05, "Neutral zone in %")

assetClose = close
silverClose = request.security(silverSymbol, timeframe.period, close)

assetReturn = ((assetClose / assetClose[lookback]) - 1) * 100
silverReturn = ((silverClose / silverClose[lookback]) - 1) * 100

relativePerformance = assetReturn - silverReturn

isOutperforming = relativePerformance > neutralZone
isUnderperforming = relativePerformance < -neutralZone
isNeutral = not isOutperforming and not isUnderperforming

plot(relativePerformance, title="Relative performance vs Silver", linewidth=2)

hline(0, "Silver line", color=color.gray, linestyle=hline.style_dashed)
hline(neutralZone, "Neutral upper", color=color.new(color.gray, 70))
hline(-neutralZone, "Neutral lower", color=color.new(color.gray, 70))

bgcolor(
     isOutperforming ? color.new(color.green, 88) :
     isUnderperforming ? color.new(color.red, 88) :
     color.new(color.gray, 92)
)

var table infoTable = table.new(position.top_right, 1, 3)

currentAsset = syminfo.ticker

statusText = isOutperforming ? "Outperforming Silver" :
     isUnderperforming ? "Underperforming Silver" :
     "Neutral vs Silver"

relativeColor = isOutperforming ? color.green :
     isUnderperforming ? color.red :
     color.gray

if barstate.islast
    table.cell(
         infoTable, 0, 0,
         currentAsset + " vs Silver",
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
