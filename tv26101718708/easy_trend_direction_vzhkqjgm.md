# Easy Trend Direction

- url: https://www.tradingview.com/script/vzHKQjgM/
- type: indicator
- pine_id: PUB;186fda7910ca4abdbc744f79d5f54398
- version: 3.0

## Description

[b]Easy Trend Direction (ETD) – Smart UI Arrow[/b]

Keep your charts completely clean! [b]Easy Trend Direction (ETD)[/b] places a dynamic trend arrow directly in the [b]top right corner of your chart[/b], giving you instant, distraction-free visual feedback on the current market structure and momentum. 

Instead of cluttering your workspace with multiple moving averages and oscillators, ETD combines the logic of structural EMAs and RSI momentum into one single, elegant UI element. 

[b]How it Works[/b]

The indicator analyzes two key technical factors to dynamically update the symbol, angle, and color of the arrow in real-time:

[list]
[*][b]Trend Structure (Direction):[/b] The script calculates the relationship between a Fast EMA (default 50) and a Slow EMA (default 200).
Fast EMA > Slow EMA = [b]Bullish (Green)[/b]
Fast EMA < Slow EMA = [b]Bearish (Red)[/b]
If both EMAs are extremely close to each other (defined by the customizable "Neutral Zone"), the market is consolidating, resulting in a [b]Neutral state (Gray, horizontal arrow)[/b].

[*][b]Momentum (Strength):[/b] Once a trend direction is established, the script uses the RSI (default 14) to determine the angle of the arrow.
High momentum (RSI hitting extreme thresholds like 70 or 30) points the arrow straight up or down.
Normal momentum results in a diagonal arrow, indicating a steady, healthy trend.
[/list]

[b]Key Features[/b]

[list]
[*][b]Zero Chart Clutter:[/b] Designed for minimalists. The UI table sits quietly in the top right corner, leaving your candles and price action fully visible.
[*][b]Customizable Arrow Styles:[/b] Use the dropdown menu in the settings to choose between three clean, built-in design sets: "Classic Line", "Heavy Blocks", or "Simple Triangles".
[*][b]Fully Adjustable Logic:[/b] Tweak the EMA lengths, RSI momentum thresholds, and the percentage-based "Neutral Zone" to perfectly fit your preferred asset and timeframe.
[*][b]Theme Integration:[/b] Personalize the Bullish, Bearish, and Neutral colors to match your specific chart setup.
[/list]

ETD is the perfect confluence filter for daytraders and swing traders who want to stay aligned with the trend at a single glance. Add it to your favorites and never lose sight of the market direction again!

## Source Code

````pine
//@version=6
indicator("Easy Trend Direction", shorttitle="ETD", overlay=true)

// --- Inputs ---
// Structure (EMAs for Trend Direction)
fastLen = input.int(50, title="Fast EMA", group="Structure")
slowLen = input.int(200, title="Slow EMA", group="Structure")
neutralZone = input.float(0.05, title="Neutral Zone (%)", tooltip="If the percentage distance between the EMAs is smaller than this value, the market is considered neutral (ranging).", group="Structure")

// Momentum (RSI for Trend Strength)
rsiLen = input.int(14, title="RSI Length", group="Momentum")
rsiBullish = input.int(70, title="RSI Strong Bullish Threshold", group="Momentum")
rsiBearish = input.int(30, title="RSI Strong Bearish Threshold", group="Momentum")

// Appearance (Dropdown Choice & Colors)
arrowStyle = input.string("Classic Line", title="Arrow Style", options=["Classic Line", "Heavy Blocks", "Simple Triangles"], group="Appearance")
colBull = input.color(color.green, title="Color: Bullish", group="Appearance")
colNeutral = input.color(color.gray, title="Color: Neutral", group="Appearance")
colBear = input.color(color.red, title="Color: Bearish", group="Appearance")

// --- Calculations ---
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)
rsi = ta.rsi(close, rsiLen)

// Calculate percentage distance between EMAs
emaDiff = math.abs(fastEMA - slowEMA) / slowEMA * 100

// Determine State (Structure)
isNeutral = emaDiff <= neutralZone
isBullish = fastEMA > slowEMA and not isNeutral
isBearish = fastEMA < slowEMA and not isNeutral

// --- Assign Symbols Based on Dropdown Selection ---
var string symStrongBull = "↑"
var string symWeakBull   = "↗"
var string symNeutral    = "→"
var string symWeakBear   = "↘"
var string symStrongBear = "↓"

if arrowStyle == "Heavy Blocks"
    symStrongBull := "⬆"
    symWeakBull   := "⬈"
    symNeutral    := "➡"
    symWeakBear   := "⬊"
    symStrongBear := "⬇"
else if arrowStyle == "Simple Triangles"
    symStrongBull := "▲"
    symWeakBull   := "◥"
    symNeutral    := "▶"
    symWeakBear   := "◢"
    symStrongBear := "▼"

// --- Logic for Direction and Color ---
var string dirSymbol = symNeutral
var color dirColor = colNeutral

if isNeutral
    dirSymbol := symNeutral
    dirColor := colNeutral
else if isBullish
    dirColor := colBull
    if rsi >= rsiBullish
        dirSymbol := symStrongBull
    else
        dirSymbol := symWeakBull
else if isBearish
    dirColor := colBear
    if rsi <= rsiBearish
        dirSymbol := symStrongBear
    else
        dirSymbol := symWeakBear

// --- Draw Table (UI Top Right) ---
var table dirTable = table.new(position.top_right, 1, 1, frame_color=color.new(color.black, 100), frame_width=0)

if barstate.islast
    table.cell(dirTable, 0, 0, dirSymbol, text_color=dirColor, text_size=size.large, bgcolor=color.new(color.black, 100))
````
