# FxNeel MTF Swing & FVG PRO

- url: https://www.tradingview.com/script/njJ5UnGU-FxNeel-MTF-Swing-FVG-PRO/
- type: indicator
- pine_id: PUB;6abda7c875de4034a930c69f69f60559
- version: 1.0

## Description

Description:
The FxNeel Institutional Swing & FVG Matrix is a comprehensive technical analysis tool designed for traders who follow Price Action and Institutional trading concepts. This indicator helps you identify market structure and potential imbalances (Fair Value Gaps) with precision.

Key Features:
Multi-Swing Structure: Automatically detects and plots Short-Term and Intermediate-Term Highs and Lows, helping you visualize the market trend and potential reversal points.

Dynamic Fair Value Gap (FVG) Engine: Real-time identification of Bullish and Bearish Fair Value Gaps. The tool features an automatic mitigation logic—meaning the gap box disappears once the price mitigates the imbalance, keeping your chart clean and actionable.

Customizable Settings:

Control the length of swing detection.

Adjust the horizontal extension of swing lines.

Toggle between different swing line styles (Solid, Dashed, Dotted).

Enable/Disable individual components to suit your trading style.

Clean & Professional: Optimized for performance and readability, making it suitable for both scalpers and swing traders.

How to Use:
Swing Lines: Use these to identify Key Levels (Highs/Lows) and observe how price reacts around these institutional pivots.

FVGs: Identify areas of market imbalance. Look for price reactions within these zones to find potential entry setups.

Mitigation: The indicator automatically cleans up "mitigated" FVGs, so you only focus on "fresh" and active zones.

Disclaimer: This indicator is for educational purposes only and does not constitute financial advice. Always perform your own analysis before making trading decisions.

## Source Code

````pine
//@version=6
indicator("FxNeel MTF Swing & FVG PRO", overlay=true, max_labels_count=500, max_boxes_count=300, max_lines_count=300)

// ==========================================
// ১. সেটিংস (Settings)
// ==========================================
grp_swing   = 'External/Internal Multi-Swing Settings'
show_swings = input.bool(true, title = 'Enable Multi-Swing Lines 🔑', group = grp_swing)
leftLen     = input.int(5, title = 'External Left Bars Length', group = grp_swing)
rightLen    = input.int(5, title = 'External Right Bars Length', group = grp_swing)
lineLength  = input.int(20, title = 'Max Line Extension (Bars)', minval = 1, group = grp_swing)
maxSwings   = input.int(5, title = 'Max Active Lines to Show', minval = 1, group = grp_swing)
highColor   = input.color(color.black, title = 'High Line Color', group = grp_swing)
lowColor    = input.color(color.blue, title = 'Low Line Color', group = grp_swing)

grp_fvg     = "Dynamic Fair Value Gap (FVG) Engine"
showFVG       = input.bool(true, "Plot Dynamic Fair Value Gaps", group=grp_fvg)
fvgCountLimit = input.int(10, "Max Number of FVGs to Show", minval=1, maxval=100, group=grp_fvg)
fvgColorBull  = input.color(color.new(color.green, 93), "Bullish FVG Fill", group=grp_fvg)
fvgColorBear  = input.color(color.new(color.red, 93), "Bearish FVG Fill", group=grp_fvg)

// ==========================================
// ২. সুইং স্ট্রাকচার লজিক
// ==========================================
swingHigh = ta.pivothigh(high, leftLen, rightLen)
swingLow  = ta.pivotlow(low, leftLen, rightLen)

var line[] highLinesArray = array.new_line()
var line[] lowLinesArray  = array.new_line()

ln_high_color = show_swings ? highColor : color.new(color.black, 100)
ln_low_color  = show_swings ? lowColor : color.new(color.black, 100)

if not na(swingHigh)
    line newHighLine = line.new(x1 = bar_index - rightLen, y1 = high[rightLen], x2 = bar_index, y2 = high[rightLen], color = ln_high_color, width = 2)
    array.push(highLinesArray, newHighLine)
    if array.size(highLinesArray) > maxSwings
        line.delete(array.shift(highLinesArray))

if not na(swingLow)
    line newLowLine = line.new(x1 = bar_index - rightLen, y1 = low[rightLen], x2 = bar_index, y2 = low[rightLen], color = ln_low_color, width = 2)
    array.push(lowLinesArray, newLowLine)
    if array.size(lowLinesArray) > maxSwings
        line.delete(array.shift(lowLinesArray))

// লাইন এক্সটেনশন লজিক (নিরাপত্তামূলক চেক সহ)
if show_swings
    if array.size(highLinesArray) > 0
        for i = array.size(highLinesArray) - 1 to 0
            line l = array.get(highLinesArray, i)
            if bar_index - line.get_x1(l) <= lineLength
                line.set_x2(l, bar_index)
            
    if array.size(lowLinesArray) > 0
        for i = array.size(lowLinesArray) - 1 to 0
            line l = array.get(lowLinesArray, i)
            if bar_index - line.get_x1(l) <= lineLength
                line.set_x2(l, bar_index)

// ==========================================
// ৩. DYNAMIC FAIR VALUE GAP (FVG) ENGINE
// ==========================================
var box[] bullFvgBoxes = array.new_box(0)
var box[] bearFvgBoxes = array.new_box(0)

isBullFVG = low[0] > high[2] and close[1] > high[2]
isBearFVG = high[0] < low[2] and close[1] < low[2]

if showFVG
    if isBullFVG
        bx = box.new(left=bar_index - 2, top=low[0], right=bar_index, bottom=high[2], bgcolor=fvgColorBull, border_color=na)
        array.push(bullFvgBoxes, bx)
        if array.size(bullFvgBoxes) > fvgCountLimit
            box.delete(array.shift(bullFvgBoxes))
    
    if isBearFVG
        bx = box.new(left=bar_index - 2, top=low[2], right=bar_index, bottom=high[0], bgcolor=fvgColorBear, border_color=na)
        array.push(bearFvgBoxes, bx)
        if array.size(bearFvgBoxes) > fvgCountLimit
            box.delete(array.shift(bearFvgBoxes))

    // Mitigation লজিক (নিরাপত্তামূলক চেক সহ)
    if array.size(bullFvgBoxes) > 0
        for i = array.size(bullFvgBoxes) - 1 to 0
            b = array.get(bullFvgBoxes, i)
            if low[0] <= box.get_bottom(b)
                box.delete(b)
                array.remove(bullFvgBoxes, i)
            else
                box.set_right(b, bar_index)

    if array.size(bearFvgBoxes) > 0
        for i = array.size(bearFvgBoxes) - 1 to 0
            b = array.get(bearFvgBoxes, i)
            if high[0] >= box.get_top(b)
                box.delete(b)
                array.remove(bearFvgBoxes, i)
            else
                box.set_right(b, bar_index)
````
