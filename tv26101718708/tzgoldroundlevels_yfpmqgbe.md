# TZ_Gold_Round_Levels

- url: https://www.tradingview.com/script/YFpMqGbe-TZ-Gold-Round-Levels/
- type: indicator
- pine_id: PUB;283d2c1f95d94fdf9cea0ad0a09ccbe1
- version: 1.0

## Description

TZ_Gold_Round_Levels displays a moving grid of round-number price levels around the latest chart price. It automates a five-level layout with fixed offsets, making it easier to keep these reference levels centered as price changes. It is designed for XAUUSD on a 15-minute chart and also works on other chart timeframes. It does not change the chart timeframe automatically.

CALCULATION AND COLORS
The central level is calculated as:
nearest round level = round(latest price / spacing) x spacing

With the default spacing of 50, the indicator selects the nearest multiple of 50 and draws two round levels above it and two below it. Each of these five levels has a blue horizontal line, a green line 10 price units above it, and a red line 10 price units below it, producing 15 lines in total.

For example, when the center is 4300, the blue levels are 4200, 4250, 4300, 4350, and 4400. The lines surrounding 4300 are green at 4310 and red at 4290.

LIVE UPDATES
The grid updates as the live candle's price changes. Midpoint ties round upward: at 4325, the center changes from 4300 to 4350. If price moves back below that midpoint, the center returns to 4300. This can happen before the candle closes.

The latest grid extends across the chart, including earlier candles. These lines represent the current grid, not the levels that were active at each historical candle. The indicator is a visual reference tool; it does not generate buy/sell signals or backtest results.

SETTINGS AND USE
Add the indicator to an XAUUSD chart and choose the desired timeframe, such as 15 minutes. Inputs control round-number spacing, offset distance, levels on each side, line colors and width, price-label visibility, and label distance. The offset must remain below half the spacing.

Distances are price units, not pips. On XAUUSD, an offset of 10 means a 10.00 change in the quoted price. The horizontal levels alone do not establish support, resistance, or a trade recommendation.

## Source Code

````pine
//@version=6
indicator("TZ_Gold_Round_Levels", shorttitle="TZ_Gold_Round_Levels", overlay=true, max_lines_count=100, max_labels_count=100)

// All distances are price units: on XAUUSD, 10 means a $10 price move.
float spacing = input.float(50.0, "Round-number spacing", minval=0.01, group="Levels")
float offset = input.float(10.0, "Green / red offset", minval=0.01, group="Levels")
int eachSide = input.int(2, "Round levels above and below", minval=0, maxval=10, group="Levels")

color baseColor = input.color(color.rgb(41, 98, 255), "Round level", group="Appearance")
color upperColor = input.color(color.rgb(76, 175, 80), "Above (+offset)", group="Appearance")
color lowerColor = input.color(color.rgb(242, 54, 69), "Below (-offset)", group="Appearance")
int lineWidth = input.int(2, "Line width", minval=1, maxval=4, group="Appearance")
bool showPrices = input.bool(true, "Show price labels", group="Appearance")
int labelBars = input.int(5, "Label distance to the right (bars)", minval=1, maxval=100, group="Appearance")

if barstate.isfirst and offset >= spacing / 2.0
    runtime.error("Green / red offset must be less than half the round-number spacing.")

// Create a fixed pool of drawing objects. Move them instead of accumulating
// old grids. Defaults: 5 round levels x 3 lines = 15 horizontal lines.
int lineCount = (eachSide * 2 + 1) * 3
var array<line> gridLines = array.new<line>()
var array<label> priceLabels = array.new<label>()

if barstate.isfirst
    for i = 0 to lineCount - 1
        array.push(gridLines, line.new(bar_index, na, bar_index + 1, na, xloc=xloc.bar_index, extend=extend.both, width=lineWidth))
        if showPrices
            array.push(priceLabels, label.new(na, na, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, textcolor=color.white, size=size.tiny))

// On a live candle, close is the latest available chart price.
// Recenter when the nearest round number changes; midpoint ties round up.
// These are the CURRENT levels, extended across the chart, not historical signals.
if barstate.islast and not na(close)
    float center = math.round(close / spacing) * spacing
    for levelIndex = 0 to eachSide * 2
        float base = center + (levelIndex - eachSide) * spacing
        for band = 0 to 2
            int objectIndex = levelIndex * 3 + band
            float price = math.round_to_mintick(base + (band == 1 ? offset : band == 2 ? -offset : 0.0))
            color levelColor = band == 0 ? baseColor : band == 1 ? upperColor : lowerColor
            line levelLine = array.get(gridLines, objectIndex)
            line.set_xy1(levelLine, bar_index, price)
            line.set_xy2(levelLine, bar_index + 1, price)
            line.set_color(levelLine, levelColor)
            if showPrices
                label priceLabel = array.get(priceLabels, objectIndex)
                label.set_xy(priceLabel, bar_index + labelBars, price)
                label.set_text(priceLabel, str.tostring(price, format.mintick))
                label.set_color(priceLabel, levelColor)
````
