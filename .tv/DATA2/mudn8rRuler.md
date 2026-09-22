<!-- tradingview-pine-id: PUB;cd862c5cfe264ecc94c6f57450566057 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# mudn8rRuler

Source: https://www.tradingview.com/script/MdafM7uG-mudn8rRuler/

## Description

mudn8rRuler is an interactive measurement indicator that shows the potential profit or loss of a price move based on your selected contract quantity.

Designed for futures traders, it combines ruler measurements and contract-aware P/L in one text box.

Features

Measure the bar distance, elapsed time, and price change between two points.

Display price change in points, ticks, percent, or total currency value.

View potential long and short gross P/L for your chosen number of contracts.

Reposition the measurement and text box using three interactive chart points.

Customize line color, line width, text size, and text-box colors.

Use the symbol’s point value automatically, with an optional manual override.

How to use

Add mudn8rRuler to your chart.

Select the starting point, ending point, and text-box location when prompted.

Open Settings → Inputs and set Contracts to your intended quantity.

Select the indicator to reveal its interactive markers, then move those markers to adjust the measurement or text-box position.

Add another instance of the indicator if you want multiple rulers on the chart.

P/L calculation

Long P/L = Tick-rounded price change × Point value × Contracts

Short P/L is the opposite of long P/L. An upward move produces positive long P/L and negative short P/L; a downward move reverses those results.

For example, with a point value of $50, a one-point upward move measured with three contracts shows +$150 long P/L and −$150 short P/L.

Notes and limitations

Contracts is a manual setting. The indicator does not read or synchronize with the trading panel’s Order Qty field.

Amounts are displayed in the symbol’s currency. Commissions, fees, slippage, and currency conversion are excluded.

Intended for linear futures contracts. Forex lot sizing and inverse-contract calculations are not supported.

Bar distance uses loaded chart bars. If an anchor does not match a loaded bar’s opening time, Bars displays N/A.

Standard time-based charts provide the most predictable bar counts.

Move the indicator’s input markers to adjust it; the lines and text box are not native TradingView drawing tools.

Reset the anchors after changing symbols because the selected prices remain in the indicator’s inputs.

mudn8rRuler is a measurement and trade-planning aid. It does not generate trading signals or place orders.

---

## Source Code

````pine
//@version=6
indicator("mudn8rRuler", shorttitle = "mudn8rRuler", overlay = true, max_lines_count = 2, max_labels_count = 1)
// TradingView adaptation of mudn8rRuler. One ruler per indicator instance.
// Pine has no access to the Trading Panel/broker Order Qty field. Contracts
// is an explicit manual input, not a live broker/account/position quantity.
// Interactive input points can be moved; Pine line/label objects cannot be
// dragged like native drawing tools. Select the indicator to see its points.
// Intended for linear futures. No fees, slippage, or currency conversion.
float startPrice = input.price(0, "Start price", inline = "start", group = "Ruler anchors", confirm = true)
int startTime = input.time(0, "Time", inline = "start", group = "Ruler anchors", confirm = true)
float endPrice = input.price(0, "End price", inline = "end", group = "Ruler anchors", confirm = true)
int endTime = input.time(0, "Time", inline = "end", group = "Ruler anchors", confirm = true)
float textPrice = input.price(0, "Text box price", inline = "text", group = "Ruler anchors", confirm = true)
int textTime = input.time(0, "Time", inline = "text", group = "Ruler anchors", confirm = true)
int contracts = input.int(1, "Contracts", minval = 1, group = "Contract P/L", tooltip = "Set this manually to match your intended order quantity. Pine cannot read the trading panel's Order Qty.")
bool customPointValue = input.bool(false, "Override symbol point value", group = "Contract P/L")
float manualPointValue = input.float(50.0, "Value per 1.0 price point per contract", minval = 0.000001, group = "Contract P/L", tooltip = "Used only when override is enabled. Denominated in the chart symbol's currency.")
string yUnit = input.string("Points", "Y-value display", options = ["Points", "Ticks", "Percent", "Currency"], group = "Appearance")
color lineColor = input.color(color.green, "Line color", group = "Appearance")
int lineWidth = input.int(2, "Line width", minval = 1, maxval = 4, group = "Appearance")
color textColor = input.color(color.white, "Text color", group = "Appearance")
color boxColor = input.color(color.new(color.green, 10), "Text box color", group = "Appearance")
string textSize = input.string("Normal", "Text size", options = ["Small", "Normal", "Large"], group = "Appearance")
signedNumber(float value) =>
    (value > 0 ? "+" : "") + str.tostring(value, "#,##0.00")
// Dollar signs for USD; keep other denominations explicit without implying FX conversion.
formatMoney(float value, string denomination) =>
    string sign = value > 0 ? "+" : value < 0 ? "-" : ""
    string symbol = denomination == "USD" ? "$" : ""
    sign + symbol + str.tostring(math.abs(value), "#,##0.00") + " " + denomination
elapsedText(int milliseconds) =>
    int secondsTotal = int(math.abs(milliseconds) / 1000)
    int days = int(secondsTotal / 86400)
    int hours = int(secondsTotal % 86400 / 3600)
    int minutes = int(secondsTotal % 3600 / 60)
    int seconds = secondsTotal % 60
    (days > 0 ? str.tostring(days) + "d " : "") + str.tostring(hours, "00") + ":" + str.tostring(minutes, "00") + ":" + str.tostring(seconds, "00")
// Count actual chart bars, not elapsed time divided by timeframe (which would
// count weekends/session gaps). Only exact bar-opening timestamps are mapped.
// Missing/future/off-bar anchors show N/A rather than an estimated bar count.
var int startIndex = na
var int endIndex = na
if time == startTime and na(startIndex)
    startIndex := bar_index
if time == endTime and na(endIndex)
    endIndex := bar_index
float pointValue = customPointValue ? manualPointValue : syminfo.pointvalue
float priceDelta = math.round_to_mintick(endPrice - startPrice)
float tickDelta = priceDelta / syminfo.mintick
float total = priceDelta * pointValue * contracts
string currency = syminfo.currency
string longMoney = formatMoney(total, currency)
string shortMoney = formatMoney(-total, currency)
string barText = not na(startIndex) and not na(endIndex) ? str.tostring(endIndex - startIndex) : "N/A (anchors outside loaded bars/off-bar)"
string yText = switch yUnit
    "Ticks" => str.tostring(tickDelta, "#") + " ticks"
    "Percent" => startPrice != 0 ? signedNumber(priceDelta / startPrice * 100) + "%" : "N/A (start price is zero)"
    "Currency" => longMoney + " total"
    => str.tostring(priceDelta, format.mintick) + " points"
string labelSize = textSize == "Small" ? size.small : textSize == "Large" ? size.large : size.normal
var line measurement = na
var line connector = na
var label readout = na
if barstate.islast
    string info = "Long P/L: " + longMoney + "\nShort P/L: " + shortMoney
    info += "\nContracts: " + str.tostring(contracts) + " (manual)"
    info += "\nBars: " + barText + "\nTime: " + elapsedText(endTime - startTime) + "\nY-value: " + yText
    if na(pointValue) or pointValue <= 0
        info += "\nSet a valid point-value override."
    // A constant number of objects, including during realtime updates.
    if na(measurement)
        measurement := line.new(startTime, startPrice, endTime, endPrice, xloc = xloc.bar_time, color = lineColor, width = lineWidth)
        connector := line.new(endTime, endPrice, textTime, textPrice, xloc = xloc.bar_time, color = lineColor, width = lineWidth, style = line.style_dotted)
        readout := label.new(textTime, textPrice, info, xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_lower_right, color = boxColor, textcolor = textColor, size = labelSize, textalign = text.align_left)
    else
        line.set_xy1(measurement, startTime, startPrice)
        line.set_xy2(measurement, endTime, endPrice)
        line.set_xy1(connector, endTime, endPrice)
        line.set_xy2(connector, textTime, textPrice)
        label.set_xy(readout, textTime, textPrice)
        label.set_text(readout, info)
````
