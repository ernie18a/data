# Smooths HTF Mini Chart

- url: https://www.tradingview.com/script/SiYfT3ZD-Smooths-HTF-Mini-Chart/
- type: indicator
- pine_id: PUB;098fee7abab64f89a1ad269b6204322b
- version: 1.0

## Description

Overview
The Smooths HTF Mini Chart is a technical utility designed for traders who require constant high-timeframe (HTF) context without sacrificing screen real estate or deal with the "drifting" issues associated with standard drawing objects. By leveraging the Pine Script Table API, this script creates a live candlestick "monitor" that is anchored to the UI layer of the chart, ensuring it stays perfectly positioned in the corner regardless of how a user drags or scales the primary price action.

The Technical Concept (Why it is Original)
Most HTF indicators overlay candles directly onto the main price chart. This presents two problems:

They clutter the primary timeframe's candles.

They are tied to bar indexes; when a user scrolls back in time, the HTF context disappears off-screen.

This script solves this by utilizing Unicode String Rendering. Instead of using box.new or line.new (which are anchored to the time/price axis), this indicator maps price data into a vertical string of characters (█ and ┆) and renders them inside a table.cell. Because tables are part of the chart's fixed UI layer (the "Glass Layer"), the monitor functions like a native dashboard widget that never moves.

Calculations & Underlying Logic
Data Aggregation: The script uses request.security to pull OHLC data from the user-defined HTF.

Dynamic Normalization: Since the widget has a fixed vertical height (Resolution), the script dynamically normalizes the HTF price range within the array to fit the vertical space of the table cell.

Monospace Alignment: By forcing a font.family_monospace, the script ensures that the "wicks" and "bodies" of the Unicode candles stay mathematically centered and symmetrical.

Usefulness for Traders
Scalping Context: A 1-minute trader can monitor the 15-minute or 1-hour trend without switching tabs or cluttering their workspace.

Persistent Visibility: Essential for traders who zoom in and out frequently; the HTF trend is always visible in the top-right corner.

Customizable UI: Users can adjust the "Vertical Resolution" to change the widget's height and toggle "Horizontal Spacing" to fit their specific screen layout.

Instructions for Use
HTF Timeframe: Choose the timeframe you wish to monitor.

Vertical Resolution: Increase for more detail in the candles, decrease for a more compact widget.

Position: Use the inputs to move the widget to any of the four corners of your screen.

## Source Code

````pine
//@version=5
indicator("Smooths HTF Mini Chart", overlay=true)

// ============================================================================
// SETTINGS
// ============================================================================
htfTf      = input.timeframe("15", "HTF Timeframe")
numBars    = input.int(12, "Number of Candles", minval=2, maxval=40)

// SIZE & SPACING SETTINGS
res        = input.int(12, "Vertical Height", minval=5, maxval=30, tooltip="Lower = Shorter widget height.")
useSpacing = input.bool(true, "Add Spacing Between Candles?")
txtSize    = input.string(size.small, "Overall Scale", [size.tiny, size.small, size.normal], tooltip="Adjusts the character size.")

// POSITION
vPos       = input.string("top", "Vertical Side", ["top", "middle", "bottom"])
hPos       = input.string("right", "Horizontal Side", ["left", "center", "right"])

// STYLE
upCol      = input.color(#26a69a, "Bullish")
dnCol      = input.color(#ef5350, "Bearish")
bgCol      = input.color(color.new(#131722, 25), "Widget Background")
frameCol   = input.color(color.new(color.gray, 60), "Frame Border")

// ============================================================================
// DATA
// ============================================================================
var float[] oArr = array.new_float(0)
var float[] hArr = array.new_float(0)
var float[] lArr = array.new_float(0)
var float[] cArr = array.new_float(0)

[O, H, L, C] = request.security(syminfo.tickerid, htfTf, [open, high, low, close], lookahead=barmerge.lookahead_off)

if ta.change(time(htfTf)) != 0
    array.push(oArr, nz(O[1])), array.push(hArr, nz(H[1])), array.push(lArr, nz(L[1])), array.push(cArr, nz(C[1]))
    if array.size(oArr) > numBars
        array.shift(oArr), array.shift(hArr), array.shift(lArr), array.shift(cArr)

// ============================================================================
// UI ENGINE
// ============================================================================
int totalCols = useSpacing ? numBars * 2 : numBars
var table ui = table.new(vPos + "_" + hPos, totalCols, 1, bgcolor=bgCol, border_width=0, frame_color=frameCol, frame_width=1)

if barstate.islast
    table.clear(ui, 0, 0, totalCols - 1, 0)
    
    tempO = array.copy(oArr), tempH = array.copy(hArr), tempL = array.copy(lArr), tempC = array.copy(cArr)
    array.push(tempO, O), array.push(tempH, H), array.push(tempL, L), array.push(tempC, C)
    if array.size(tempO) > numBars
        array.shift(tempO), array.shift(tempH), array.shift(tempL), array.shift(tempC)

    float minP = array.min(tempL)
    float maxP = array.max(tempH)
    float pRng = math.max(maxP - minP, syminfo.mintick)

    for i = 0 to array.size(tempO) - 1
        float vO = array.get(tempO, i), vH = array.get(tempH, i)
        float vL = array.get(tempL, i), vC = array.get(tempC, i)

        int rH = int(math.round(((vH - minP) / pRng) * (res - 1)))
        int rL = int(math.round(((vL - minP) / pRng) * (res - 1)))
        int rO = int(math.round(((vO - minP) / pRng) * (res - 1)))
        int rC = int(math.round(((vC - minP) / pRng) * (res - 1)))

        string candleStr = ""
        int bodyTop = math.max(rO, rC)
        int bodyBot = math.min(rO, rC)

        for j = res - 1 to 0
            string char = " "
            if j == rH and j > bodyTop
                char := "┆" 
            else if j <= bodyTop and j >= bodyBot
                char := "█" 
            else if j == rL and j < bodyBot
                char := "┆"
            else if j < rH and j > bodyTop
                char := "┆"
            else if j > rL and j < bodyBot
                char := "┆"
            candleStr := candleStr + char + (j > 0 ? "\n" : "")

        color c = vC >= vO ? upCol : dnCol
        int colIdx = useSpacing ? i * 2 : i
        
        table.cell(ui, colIdx, 0, candleStr, text_color=c, text_size=txtSize, text_font_family=font.family_monospace)
````
