# KOFE Buy/Sell Bubbles

- url: https://www.tradingview.com/script/afmaISm1-KOFE-Buy-Sell-Bubbles/
- type: indicator
- pine_id: PUB;ad23013c729442a0a7cb71a9105fa956
- version: 2.0

## Description

Buy/sell indication on candle with change in background during high volume events on either side.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Buy/Sell Volume Breakdown", shorttitle="B/S Vol", overlay=false, format=format.volume, precision=0)

// --- Inputs ---
calcTfInput  = input.timeframe("1", "Calculation Timeframe", tooltip="The timeframe used to calculate buy and sell volume breakdown. Use 1m for higher timeframes, or lower for 1m charts.")
bullColor    = input.color(#089981, "Buy Volume Color", inline="Colors", tooltip="Color for buy volume (bullish).")
bearColor    = input.color(#f23645, "Sell Volume Color", inline="Colors", tooltip="Color for sell volume (bearish).")
showDelta    = input.bool(true, "Show Net Volume (Delta) Line", tooltip="Display a line representing the difference between buy and sell volume.")

// Bubble Settings
showBubbles  = input.bool(true, "Show Volume Bubbles on Candles", tooltip="Display colored circles on the price candles representing the dominant volume side.", group="Bubble Settings")
bubbleTransp = input.int(50, "Bubble Transparency", minval=0, maxval=100, group="Bubble Settings")
volLookback  = input.int(20, "Volume Avg Lookback", minval=1, group="Bubble Settings", tooltip="Period used to calculate the average volume for dynamic sizing.")

// Background Highlighting
showBg       = input.bool(true, "Highlight High Volume Background", group="Background Settings", tooltip="Colors the background when a significant volume spike occurs.")
bgHugeOnly   = input.bool(false, "Huge Volume Only", group="Background Settings", tooltip="If true, only 'Huge' volume spikes will trigger the highlight. If false, both 'Large' and 'Huge' will.")
bgTransp     = input.int(90, "Background Transparency", minval=0, maxval=100, group="Background Settings")

// --- Core Logic ---
// Fetch lower timeframe data
[ltfOpen, ltfClose, ltfVol] = request.security_lower_tf(syminfo.tickerid, calcTfInput, [open, close, volume])

var float buyVol  = 0.0
var float sellVol = 0.0

buyVol  := 0.0
sellVol := 0.0

if array.size(ltfVol) > 0
    for i = 0 to array.size(ltfVol) - 1
        float v = array.get(ltfVol, i)
        float o = array.get(ltfOpen, i)
        float c = array.get(ltfClose, i)
        
        if c > o
            buyVol += v
        else if c < o
            sellVol += v
        else
            buyVol  += v / 2
            sellVol += v / 2
else
    if close > open
        buyVol := volume
    else if close < open
        sellVol := volume
    else
        buyVol  := volume / 2
        sellVol := volume / 2

// Calculate Relative Volume for Sizing & Highlighting
totalVol = buyVol + sellVol
avgVol   = ta.sma(totalVol, volLookback)
volScale = totalVol / avgVol

// Define dynamic size tiers
bool isTiny   = volScale <= 0.6
bool isSmall  = volScale > 0.6 and volScale <= 1.2
bool isNormal = volScale > 1.2 and volScale <= 1.8
bool isLarge  = volScale > 1.8 and volScale <= 2.5
bool isHuge   = volScale > 2.5

// Dominant color
color dominantColor = buyVol >= sellVol ? bullColor : bearColor

// --- Visuals: Lower Pane ---
plot(buyVol, "Buy Volume", color=bullColor, style=plot.style_columns)
plot(-sellVol, "Sell Volume", color=bearColor, style=plot.style_columns)
plot(showDelta ? buyVol - sellVol : na, "Net Volume (Delta)", color=chart.fg_color, style=plot.style_line, linewidth=1)
hline(0, "Zero Line", color=chart.fg_color, linestyle=hline.style_dotted)

// --- Visuals: Main Chart (Dynamic Bubbles) ---
plotshape(showBubbles and isTiny   ? hl2 : na, title="Tiny Bubble",   style=shape.circle, location=location.absolute, color=color.new(dominantColor, bubbleTransp), size=size.tiny,   force_overlay=true)
plotshape(showBubbles and isSmall  ? hl2 : na, title="Small Bubble",  style=shape.circle, location=location.absolute, color=color.new(dominantColor, bubbleTransp), size=size.small,  force_overlay=true)
plotshape(showBubbles and isNormal ? hl2 : na, title="Normal Bubble", style=shape.circle, location=location.absolute, color=color.new(dominantColor, bubbleTransp), size=size.normal, force_overlay=true)
plotshape(showBubbles and isLarge  ? hl2 : na, title="Large Bubble",  style=shape.circle, location=location.absolute, color=color.new(dominantColor, bubbleTransp), size=size.large,  force_overlay=true)
plotshape(showBubbles and isHuge   ? hl2 : na, title="Huge Bubble",   style=shape.circle, location=location.absolute, color=color.new(dominantColor, bubbleTransp), size=size.huge,   force_overlay=true)

// --- Visuals: Background Highlighting ---
highVolCond = bgHugeOnly ? isHuge : (isHuge or isLarge)
bgcolor(showBg and highVolCond ? color.new(dominantColor, bgTransp) : na, title="High Volume Background")
````
