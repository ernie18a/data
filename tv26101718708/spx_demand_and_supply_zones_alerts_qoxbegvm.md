# SPX Demand and Supply Zones + Alerts

- url: https://www.tradingview.com/script/QOxbEgvm-SPX-Demand-and-Supply-Zones-Alerts/
- type: indicator
- pine_id: PUB;d0a779bdd8114e09974c05dbef7de810
- version: 3.0

## Description

SPX Demand and Supply zones plotted at midpoint and ability to setup alerts when zones are touched

## Source Code

````pine
//@version=6
indicator("SPX Midpoint Zones + Alerts-V1", overlay=true, max_bars_back=500)

extendBars = 300

demandColor = color.green
supplyColor = color.red

//────────────────────────────────────────────────────
// ONLY INPUTS (PASTE ZONES HERE)
//────────────────────────────────────────────────────
demandText = input.string(
     "7390-7400,7350-7360,7325-7335,7290-7300,7260-7270",
     title="Demand Zones (low-high, comma separated)"
)

supplyText = input.string(
     "7415-7425,7450-7460,7490-7500",
     title="Supply Zones (low-high, comma separated)"
)

//────────────────────────────────────────────────────
// DRAW MID LINE + LABEL
//────────────────────────────────────────────────────
drawMidLine(lowPrice, highPrice, zoneColor, zoneType) =>
    mid = (lowPrice + highPrice) / 2

    line.new(
         x1=bar_index,
         y1=mid,
         x2=bar_index + extendBars,
         y2=mid,
         color=zoneColor,
         width=2,
         extend=extend.both
    )

    label.new(
         x=bar_index,
         y=mid,
         text=zoneType + " " + str.tostring(lowPrice) + "-" + str.tostring(highPrice),
         style=label.style_label_left,
         color=zoneColor,
         textcolor=color.white,
         size=size.small
    )

//────────────────────────────────────────────────────
// PARSE TEXT INPUTS
//────────────────────────────────────────────────────
parseZones(zoneText, zoneColor, zoneType) =>
    zones = str.split(zoneText, ",")

    for i = 0 to array.size(zones) - 1
        zone = str.trim(array.get(zones, i))
        parts = str.split(zone, "-")

        if array.size(parts) == 2
            lowPrice  = str.tonumber(str.trim(array.get(parts, 0)))
            highPrice = str.tonumber(str.trim(array.get(parts, 1)))

            if not na(lowPrice) and not na(highPrice)
                drawMidLine(lowPrice, highPrice, zoneColor, zoneType)

//────────────────────────────────────────────────────
// ALERT LOGIC
//────────────────────────────────────────────────────
checkTouches(zoneText, isDemand) =>
    touched = false
    zones = str.split(zoneText, ",")

    for i = 0 to array.size(zones) - 1
        zone = str.trim(array.get(zones, i))
        parts = str.split(zone, "-")

        if array.size(parts) == 2
            lowPrice  = str.tonumber(str.trim(array.get(parts, 0)))
            highPrice = str.tonumber(str.trim(array.get(parts, 1)))

            if not na(lowPrice) and not na(highPrice)
                if isDemand
                    touched := touched or ta.crossunder(close, highPrice)
                else
                    touched := touched or ta.crossover(close, lowPrice)

    touched

demandTouch = checkTouches(demandText, true)
supplyTouch = checkTouches(supplyText, false)

alertcondition(demandTouch, title="Demand Zone Touch", message="Price entered Demand Zone")
alertcondition(supplyTouch, title="Supply Zone Touch", message="Price entered Supply Zone")

//────────────────────────────────────────────────────
// DRAW ONLY ON LAST BAR
//────────────────────────────────────────────────────
if barstate.islast
    parseZones(demandText, demandColor, "DEMAND")
    parseZones(supplyText, supplyColor, "SUPPLY")
````
