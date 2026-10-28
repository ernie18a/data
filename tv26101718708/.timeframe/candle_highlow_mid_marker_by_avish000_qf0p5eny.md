# Candle High/Low & Mid Marker by Avish000

- url: https://www.tradingview.com/script/qF0P5ENy-Candle-High-Low-Mid-Marker-by-Avish000/
- type: indicator
- pine_id: PUB;07afa025b7bb42b6aca4604a57ef5441
- version: 1.0

## Description

Candle High/Low & Mid Marker by Avish000

This indicator is designed to highlight high-probability trading zones when price interacts with the 200 EMA, helping traders spot precise entry levels using a structured, rule-based approach.

⚙️ Core Concept

When price crosses the 200 EMA, the indicator automatically marks key levels from the crossing candle:

🎯 Midpoint (50%) → Ideal limit entry zone
🔴 High (for bearish candles) → Potential stop loss level
🟢 Low (for bullish candles) → Potential stop loss level

It visually maps the exact candle structure so you don’t have to calculate anything manually.

🚀 Key Features
📈 200 EMA Cross Detection
Identifies both bullish and bearish crosses using closing price
📏 Dynamic High/Low Levels
Bearish candle → marks High
Bullish candle → marks Low
📍 Midpoint Level (50%)
Automatically calculates and plots the candle’s midpoint
Useful for limit order entries
➖ Clean Visual Dashes
Horizontal lines extend into the future for easy tracking
🏷️ Smart Labels
Displays:
H: for High
L: for Low
M: for Midpoint
Fully customizable colors, size, and font
⏱️ Multi-Timeframe Support
EMA can be calculated from a different timeframe (default: 3 min)
🎯 How to Use
Wait for price to cross the 200 EMA
Observe the marked levels:
Enter near Midpoint (M)
Place SL at High/Low (H/L)
Combine with your own strategy (RR, confirmations, etc.)
⚠️ Notes
Works best in trending markets
Avoid using in sideways/choppy conditions
Recommended for scalping and intraday setups
💡 Ideal For
Price action traders
EMA-based strategies
Scalpers looking for structured entries
🔧 Customization
Adjust EMA length
Change label styles, colors, and fonts
Control dash width and visibility

## Source Code

````pine
//@version=6
indicator("EMA 200 Cross - Dynamic High/Low & Mid", overlay=true)

// --- Inputs for EMA and Dash ---
emaLength      = input.int(200, "EMA Length")
timeframeInput = input.timeframe("3", "Timeframe")
dashWidth      = input.int(5, "Dash Width (bars to right)", minval=1, maxval=20)
pricePrecision = input.int(2, "Price Decimal Places")

// --- Inputs for High/Low Label (Dynamic) ---
showDynamicLabel   = input.bool(true, "Show Dynamic (High/Low) Label")
dynamicLabelColor  = input.color(color.maroon, "Dynamic Label Background")
dynamicTextColor   = input.color(color.white, "Dynamic Label Text Color")
dynamicLabelSize   = input.string("large", "Dynamic Label Size", options=["small", "normal", "large"])

// --- Inputs for Mid Label ---
showMidLabel       = input.bool(true, "Show Mid Price Label")
midLabelColor      = input.color(color.navy, "Mid Label Background")
midTextColor       = input.color(color.white, "Mid Label Text Color")
midLabelSize       = input.string("large", "Mid Label Size", options=["small", "normal", "large"])

// --- Font Setting ---
labelFontFamily    = input.string("Monospace", "Label Font", options=["Default", "Monospace"])

// --- Calculate EMA on 3-Minute Chart ---
emaValue = request.security(syminfo.tickerid, timeframeInput, ta.ema(close, emaLength))

// --- Detect Crosses (using close price) ---
crossUp   = ta.crossover(close, emaValue)
crossDown = ta.crossunder(close, emaValue)
plotCandle = crossUp or crossDown

// --- Determine Candle Type (Bullish/Bearish) ---
isBullish = close > open
isBearish = close < open

// --- Calculate Midpoint ---
candleMid = (high + low) / 2

// --- Dynamic Level to Mark (High for Bearish, Low for Bullish) ---
dynamicLevel = isBearish ? high : (isBullish ? low : na)
dynamicColorLine = isBearish ? color.red : color.green
dynamicColorLabel = isBearish ? dynamicLabelColor : color.green   // You can use input color or green for bull

// --- Convert String Size to Pine Size Constant ---
getSize(strSize) =>
    switch strSize
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.large

// --- Convert Font String to Font Family Constant ---
getFontFamily(fontStr) =>
    switch fontStr
        "Monospace" => font.family_monospace
        => font.family_default

// --- Draw Markers on Crossing Candle ---
if plotCandle
    // Dynamic Dash (Red for Bearish High, Green for Bullish Low)
    if not na(dynamicLevel)
        line.new(
             bar_index,
             dynamicLevel,
             bar_index + dashWidth,
             dynamicLevel,
             color = dynamicColorLine,
             width = 2,
             style = line.style_solid
        )
    
    // Mid Dash (Blue) – unchanged
    line.new(
         bar_index,
         candleMid,
         bar_index + dashWidth,
         candleMid,
         color = color.blue,
         width = 2,
         style = line.style_solid
    )
    
    // Dynamic Label (High/Low)
    if showDynamicLabel and not na(dynamicLevel)
        labelText = (isBearish ? "H: " : "L: ") + str.tostring(dynamicLevel, format.mintick)
        label.new(
             bar_index,
             dynamicLevel,
             text = labelText,
             color = dynamicColorLine == color.red ? dynamicLabelColor : color.green,
             textcolor = dynamicTextColor,
             style = label.style_label_down,
             yloc = yloc.abovebar,
             size = getSize(dynamicLabelSize),
             text_font_family = getFontFamily(labelFontFamily)
        )
    
    // Mid Label
    if showMidLabel
        label.new(
             bar_index,
             candleMid,
             text = "M: " + str.tostring(candleMid, format.mintick),
             color = midLabelColor,
             textcolor = midTextColor,
             style = label.style_label_center,
             size = getSize(midLabelSize),
             text_font_family = getFontFamily(labelFontFamily)
        )
````
