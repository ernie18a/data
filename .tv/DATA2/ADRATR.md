<!-- tradingview-pine-id: PUB;481abecdae76495883b1b1939b46afae -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ADR/ATR

Source: https://www.tradingview.com/script/Sb3ED0pz-ADR-ATR-QM-style/

## Description

A compact volatility indicator inspired by Qullamaggie’s trading approach.

ADR (20) shows the average percentage range between the daily high and low over the past 20 trading days. It helps identify stocks with enough volatility and potential movement for momentum trades.

ATR (14) shows the Average True Range over the past 14 trading days as a percentage of the current price. It accounts for gaps and helps estimate a stock’s typical movement when planning entries.

The indicator also displays ½ ATR and ⅓ ATR, providing quick reference distances for tighter entries and stop placement.

This is an independent tool inspired by Qullamaggie’s publicly discussed methods. It is not an official Qullamaggie indicator or financial advice.

---

## Source Code

````pine
//@version=6
indicator("ADR/ATR", shorttitle="ADR/ATR", overlay=false)

adrLength = input.int(20, "ADR length", minval=1)
atrLength = input.int(14, "ATR length", minval=1)

// Daily values, even when using an intraday chart
adrPercent = request.security(
     syminfo.tickerid,
     "D",
     ta.sma((high / low - 1.0) * 100.0, adrLength),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

atrPercent = request.security(
     syminfo.tickerid,
     "D",
     ta.atr(atrLength) / close * 100.0,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

halfAtrPercent = atrPercent / 2.0
thirdAtrPercent = atrPercent / 3.0

// One spacer column followed by the four values
var table values = table.new(
     position.middle_left,
     5,
     1,
     border_width=0)

if barstate.islast
    // Creates space between the indicator title and the values
    table.cell(
         values,
         0,
         0,
         "",
         width=7)

    table.cell(
         values,
         1,
         0,
         "ADR " + str.tostring(adrLength) + ": " +
         str.tostring(adrPercent, "#.##") + "%",
         text_color=color.rgb(255, 193, 7),
         text_size=size.small)

    table.cell(
         values,
         2,
         0,
         "ATR " + str.tostring(atrLength) + ": " +
         str.tostring(atrPercent, "#.##") + "%",
         text_color=color.rgb(33, 150, 243),
         text_size=size.small)

    table.cell(
         values,
         3,
         0,
         "½ ATR: " +
         str.tostring(halfAtrPercent, "#.##") + "%",
         text_color=color.rgb(76, 175, 80),
         text_size=size.small)

    table.cell(
         values,
         4,
         0,
         "⅓ ATR: " +
         str.tostring(thirdAtrPercent, "#.##") + "%",
         text_color=color.rgb(186, 104, 200),
         text_size=size.small)
````
