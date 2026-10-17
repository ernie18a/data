# Minimalist Price Movement Label

- url: https://www.tradingview.com/script/16e8fpLN-Minimalist-Price-Movement-Label/
- type: indicator
- pine_id: PUB;d46d09a8c78d4af6ac12c3ab755d1c85
- version: 3.0

## Description

[b]Price Movement Label[/b] is an ultra-clean, minimal on-chart HUD designed to display the relative percentage move across your currently visible chart window. 

Instead of measuring from a static daily session open or arbitrary fixed period, this script uses TradingView’s chart window variables (chart.left_visible_bar_time to chart.right_visible_bar_time). 

As you pan or zoom your chart, the indicator dynamically anchors to the leftmost visible bar's open price and calculates the total percentage change to the latest price in real time. It is particularly useful for order-entry execution, fast visual sizing of screen-level trends, and keeping track of bar timers without cluttering your layout. 

Features
[list][*][/list] Dynamic Viewport Measurement: Automatically recalculates percentage change based on whatever section of history is currently visible on your screen.
[list][*][/list]Minimalist HUD: Pins a single, clean label just past the current bar (bar_index + 1), keeping chart candles unobscured.Optional Price & Candle 
[list][*][/list]Timer: Toggle between showing only the percentage, the raw current price, a live countdown timer (mm:ss) to the bar close, or any combination.
[list][*][/list]Distinct Visuals: Color-coded label dynamically shifts hue depending on whether the move across the visible window is net positive or net negative.Settings & Inputs
[list][*][/list]Show percentage: Displays the net percentage gain/loss from the leftmost visible candle open to current price (formatted to 3 decimal places).
[list][*][/list]Show current price: Appends the exact latest price formatted to the instrument’s minimum tick size.
[list][*][/list]Show candle countdown: Displays a real-time countdown timer (MM:SS) until the current active bar closes (active on real-time bars only).

[b]How It Works[/b]
When the chart renders, the indicator reads the open price of the bar at chart.left_visible_bar_time.On the latest visible bar (chart.right_visible_bar_time), it calculates: 

Movement = (Close/Start Price - 1) x 100

The resulting metrics are drawn into a single pinned label styled on the right-hand margin.Note: Because this script relies on visible chart window time boundaries, zooming in, zooming out, or panning left/right will adjust the reference anchor bar to match the new visible range.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Meowella7777

//@version=6

indicator("Dynamic Viewport % Movement & Live HUD", overlay = true)

// --- Settings ---
showPercent   = input.bool(true, "Show viewport % change", group = "Metrics")
showPrice     = input.bool(false, "Show current price", group = "Metrics")
showCountdown = input.bool(false, "Show bar countdown", group = "Metrics")
showTrendIcon = input.bool(true, "Show candle tick direction (▲ / ▼)", group = "Metrics")

colorMode     = input.string("Visible Screen %", "Label Color Reflects", 
                             options = ["Visible Screen %", "Live Candle", "Previous Close"], 
                             group = "Styling")
colorUp       = input.color(color.rgb(28, 137, 205), "Up Color", group = "Styling")
colorDown     = input.color(color.rgb(142, 83, 161), "Down Color", group = "Styling")
textColor     = input.color(color.white, "Text Color", group = "Styling")

var float startPrice = na
var label priceLabel = label.new(
     na, na, "", style = label.style_label_left,
     textcolor = textColor, size = size.normal)

// Anchor to leftmost visible bar on the chart
if time == chart.left_visible_bar_time
    startPrice := open

// Render on rightmost visible bar
if time == chart.right_visible_bar_time and not na(startPrice) and startPrice != 0
    movement = (close / startPrice - 1) * 100
    labelText = ""

    // Candle momentum indicator
    string trendIcon = close >= open ? " ▲" : " ▼"

    if showPercent
        labelText := (movement > 0 ? "+" : "") + str.tostring(movement, "#.###") + " %" + (showTrendIcon ? trendIcon : "")

    if showPrice
        labelText += (labelText == "" ? "" : "\n") + str.tostring(close, format.mintick)

    if showCountdown and barstate.isrealtime and not na(time_close)
        remaining = math.max(0, int(math.ceil((time_close - timenow) / 1000)))
        minutes = int(remaining / 60)
        seconds = remaining % 60
        labelText += (labelText == "" ? "" : "\n") +
             str.tostring(minutes, "00") + ":" + str.tostring(seconds, "00")

    // Determine background color
    bool isDown = switch colorMode
        "Visible Screen %" => movement < 0
        "Live Candle"      => close < open
        "Previous Close"   => close < close[1]
        => false

    label.set_xy(priceLabel, labelText == "" ? na : bar_index + 1, close)
    label.set_text(priceLabel, labelText)
    label.set_textcolor(priceLabel, textColor)
    label.set_color(priceLabel, isDown ? colorDown : colorUp)
````
