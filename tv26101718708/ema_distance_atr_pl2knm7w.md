# EMA Distance % + ATR %

- url: https://www.tradingview.com/script/PL2kNm7W-EMA-Distance-ATR/
- type: indicator
- pine_id: PUB;eed6787e163d4ee2b29352cef38e39a4
- version: 2.0

## Description

EMA Distance % + ATR %

This indicator combines two simple but useful measurements in one pane:

• Distance from EMA (%) — shows how far the current price is trading above or below a selected EMA.
• ATR as % of Price — shows current volatility relative to the instrument's price.


EMA Distance %

The indicator calculates:

((Close - EMA) / EMA) × 100

By default, the EMA length is set to 8.

• Positive values mean price is above the EMA.
• Negative values mean price is below the EMA.
• The line is coloured green above the EMA and red below it.

This can help quickly show how extended price is relative to its short-term trend.


ATR %

ATR is calculated using the standard Average True Range and then expressed as a percentage of the current price:

(ATR / Close) × 100

The default ATR length is 20.

Expressing ATR as a percentage makes volatility easier to compare between instruments with very different prices.

For example, an ATR of $3 on a $100 stock equals an ATR of 3%.


Current Values Table

A compact table in the top-right corner displays the latest:

• Distance from the selected EMA
• ATR as a percentage of price

Both the EMA length and ATR length can be changed in the indicator settings.


Purpose

The indicator is designed as a simple visual measurement tool for assessing:

• How extended price is from its EMA
• Current volatility relative to price
• How both measurements change over time

It does not generate buy or sell signals and does not use fixed overbought or oversold thresholds.

The values are intended to provide additional market context and should be interpreted alongside your own trading strategy and analysis.

## Source Code

````pine
//@version=6
indicator("EMA Distance % + ATR % (Clean View)", shorttitle="EMA Dist + ATR % Clean", overlay=false)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
groupCalc = "Calculation Settings"
emaLength = input.int(8, "EMA Length", minval=1, group=groupCalc)
atrLength = input.int(20, "ATR Length", minval=1, group=groupCalc)

groupDisplay = "Display Settings"
showAtrLine = input.bool(true, "Show ATR % Line", group=groupDisplay)
showTable = input.bool(true, "Show Table", group=groupDisplay)

// ─────────────────────────────────────────────
// Calculations
// ─────────────────────────────────────────────
emaValue = ta.ema(close, emaLength)
atrValue = ta.atr(atrLength)

distancePct = emaValue != 0 ? ((close - emaValue) / emaValue) * 100 : na
atrPct = close != 0 ? (atrValue / close) * 100 : na

// ─────────────────────────────────────────────
// Colours
// ─────────────────────────────────────────────
emaPosColor = color.new(color.lime, 0)
emaNegColor = color.new(color.red, 0)
atrColor = color.new(color.aqua, 0)
zeroColor = color.new(color.gray, 30)

emaHistogramColor = distancePct >= 0 ? emaPosColor : emaNegColor

// ─────────────────────────────────────────────
// Plots
// ─────────────────────────────────────────────
plot(
     distancePct,
     title="Distance from EMA (%)",
     style=plot.style_histogram,
     color=emaHistogramColor,
     linewidth=3
)

plot(
     showAtrLine ? atrPct : na,
     title="ATR (% of Price)",
     color=atrColor,
     linewidth=2
)

hline(
     0,
     "Zero Line",
     color=zeroColor,
     linestyle=hline.style_solid,
     linewidth=2
)

// ─────────────────────────────────────────────
// Table — fixed to top-left
// ─────────────────────────────────────────────
var table valueTable = table.new(
     position.top_left,
     2,
     3,
     bgcolor=color.new(color.black, 20),
     frame_color=color.new(color.gray, 60),
     frame_width=1,
     border_color=color.new(color.gray, 70),
     border_width=1
)

if barstate.islast and showTable
    string distanceText =
         na(distancePct) ? "N/A" :
         (distancePct > 0 ? "+" : "") +
         str.tostring(distancePct, "#.00") + "%"

    string atrPctText =
         na(atrPct) ? "N/A" :
         str.tostring(atrPct, "#.00") + "%"

    string atrMoneyText =
         na(atrValue) ? "N/A" :
         syminfo.currency + " " +
         str.tostring(atrValue, format.mintick)

    string emaLabel = "Distance from EMA" + str.tostring(emaLength)
    string atrPctLabel = "ATR(" + str.tostring(atrLength) + ") %"
    string atrMoneyLabel = "ATR(" + str.tostring(atrLength) + ") Move"

    color distanceColor =
         distancePct > 0 ? emaPosColor :
         distancePct < 0 ? emaNegColor :
         color.white

    table.cell(
         valueTable, 0, 0, emaLabel,
         text_color=color.white,
         text_halign=text.align_left,
         bgcolor=color.new(color.black, 20)
    )

    table.cell(
         valueTable, 1, 0, distanceText,
         text_color=distanceColor,
         text_halign=text.align_right,
         bgcolor=color.new(color.black, 20)
    )

    table.cell(
         valueTable, 0, 1, atrPctLabel,
         text_color=color.white,
         text_halign=text.align_left,
         bgcolor=color.new(color.black, 20)
    )

    table.cell(
         valueTable, 1, 1, atrPctText,
         text_color=atrColor,
         text_halign=text.align_right,
         bgcolor=color.new(color.black, 20)
    )

    table.cell(
         valueTable, 0, 2, atrMoneyLabel,
         text_color=color.white,
         text_halign=text.align_left,
         bgcolor=color.new(color.black, 20)
    )

    table.cell(
         valueTable, 1, 2, atrMoneyText,
         text_color=color.silver,
         text_halign=text.align_right,
         bgcolor=color.new(color.black, 20)
    )
````
