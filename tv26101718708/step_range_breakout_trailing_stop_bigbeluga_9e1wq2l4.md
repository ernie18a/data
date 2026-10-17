# Step Range Breakout & Trailing Stop [BigBeluga]

- url: https://www.tradingview.com/script/9e1wQ2L4-Step-Range-Breakout-Trailing-Stop-BigBeluga/
- type: indicator
- pine_id: PUB;e693fd0802e343b3a4ffb22ecd64107e
- version: 1.0

## Description

[b]🔵 OVERVIEW[/b]
[quote][b]Step Range Breakout & Trailing Stop [BigBeluga][/b] is an indicator that detects quiet consolidation zones, catches clean breakouts, and manages open trades automatically with a dynamic ATR trailing stop. It solves the problem of false signals in sideways markets by highlighting only stable, confirmed ranges, then switching to a trailing stop mode once price breaks out.[/quote]


[b]🔵 HOW IT WORKS[/b]
[quote]The system runs on an automated state machine that moves through three phases — Searching, Zone Active, and Trailing:

[b]1 — Range & Consolidation Detection[/b]
[list]
[*] [b]Structure Lookback:[/b] Calculates the highest high and lowest low over the [i]Structure Length[/i] to define structural boundaries.
[*] [b]Consolidation Check:[/b] Confirms a valid zone when the range average stays unchanged over [i]Consolidation Bars / Length[/i] bars, then draws a gradient box and center line.
[image]https://www.tradingview.com/x/ck4cuyrl/[/image]
[*] [b]Range Label:[/b] Displays the range size in Price, Ticks, or Both, based on the [i]Range Display Format[/i] setting.
[image]https://www.tradingview.com/x/ZstvsBl4/[/image]
[/list]

[b]2 — Breakout & Trailing Stop Engine[/b]
[list]
[*] [b]Breakout Triggers:[/b] Fires bullish when price closes above the range top, and bearish when price closes below the range bottom.
[*] [b]Dynamic Trailing Stop:[/b] Activates an ATR-based trailing stop using [i]Trailing Stop ATR Length[/i] and [i]Trailing Stop Multiplier[/i], with a fill channel that follows price to lock in gains.
[*] [b]Trade Exit:[/b] Closes the trade when price crosses the trailing stop and resets the state machine back to Searching.
[image]https://www.tradingview.com/x/dQYOM86i/[/image]
[/list]

[b]3 — Performance Dashboard[/b]
[list]
[*] [b]Win Rate Tracking:[/b] Records the last [i]Win Rate Lookback Trades[/i] closed trades and displays live metrics including last breakout direction, closed trade count, and win rate percentage.
[image]https://www.tradingview.com/x/jeGZFjjP/[/image]
[/list][/quote]


[b]🔵 HOW TO USE[/b]
[quote]Beyond mapping breakout zones, the indicator can be applied in several ways:

[list=1]
[*] [b]Spot Sideways Markets:[/b] Let the script highlight consolidation ranges automatically and show the exact range size in price or ticks.
[*] [b]Trade Breakouts Safely:[/b] Wait for a candle to close outside the range box, then enter in the direction of the breakout.
[*] [b]Manage Risk with Trailing Stops:[/b] Use the colored trailing stop line and fill channel to manage open trades and protect profits.
[*] [b]Review Performance Live:[/b] Check the dashboard for win rate and last breakout info without leaving the chart.
[*] [b]Tune Sensitivity:[/b] Adjust the ATR multiplier for tighter or looser trailing stops depending on market volatility.
[/list][/quote]


[b]🔵 NOTES[/b]
[quote][b]Why this implementation is unique:[/b]
[list]
[*] Combines automatic range box generation with an ATR-based trailing stop and gradient fill channel visuals.
[*] Uses an ATR reference line instead of the midpoint for cleaner, more accurate trailing stop fills.
[*] Includes a built-in performance dashboard that calculates win rate dynamically in real time.
[*] Fully customizable colors, display formats, and ATR settings to match any market or timeframe.
[/list][/quote]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Step Range Breakout & Trailing Stop [BigBeluga]", overlay=true, precision=2, max_lines_count=500, max_boxes_count=500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
len    = input.int(20, "Structure Length", minval=1, tooltip="Lookback period to calculate the highest high and lowest low for structural boundaries.")
len1   = input.int(5, "Consolidation Bars / Length", minval=1, tooltip="Number of consecutive bars the range average must remain unchanged to confirm a valid consolidation zone.")

// Range Display Mode Input
dspMd  = input.string("Price", "Range Display Format", options=["Price", "Ticks", "Both"], group="Display Settings", tooltip="Choose whether to show the range value in Price, Ticks/Pips, or Both.")

aLen   = input.int(14, "Trailing Stop ATR Length", minval=1, tooltip="Average True Range (ATR) length used for calculating the trailing stop distance.")
aMul   = input.float(3.0, "Trailing Stop Multiplier", minval=0.1, step=0.1, tooltip="Multiplier applied to the ATR to set how far the trailing stop trails behind the price.")

wLen   = input.int(100, "Win Rate Lookback Trades", minval=1, tooltip="Number of recent closed trades to calculate the win rate percentage.")

// Custom Color Inputs
cBul   = input.color(color.rgb(10, 167, 151), "Bullish Color", group="Color Settings", tooltip="Color used for bullish breakouts, fills, and trailing stops.")
cBar   = input.color(color.red, "Bearish Color", group="Color Settings", tooltip="Color used for bearish breakouts, fills, and trailing stops.")
cMid   = input.color(color.rgb(190, 193, 204), "Mid Line Color", group="Color Settings", tooltip="Color used for the center line of the range.")
// }

// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
hi     = ta.highest(high, len)
lo     = ta.lowest(low, len)
rAvg   = (hi + lo) / 2


// Check if the range average remains completely unchanged over the specified length bars
stbl   = ta.change(rAvg, len1) == 0

// Helper function to format the range text based on settings
f_txt(float pUp, float pLo) =>
    float pDif = pUp - pLo
    float tDif = pDif / syminfo.mintick
    string txt = ""
    if dspMd == "Price"
        txt := "Range: " + str.tostring(pDif, "#.##")
    else if dspMd == "Ticks"
        txt := "Range: " + str.tostring(tDif, "#.##") + " Ticks"
    else
        txt := "Range: " + str.tostring(pDif, "#.##") + " (" + str.tostring(tDif, "#.##") + " Ticks)"
    txt

// State variables
var float mLVal = na
var float uLVal = na
var float lLVal = na
var float tStop = na
var string stat = "SEARCHING" // "SEARCHING", "ZONE_ACTIVE", "TRAILING"
var bool isBul  = true

// Line and Label references for dynamic drawing
var line mLin   = na
var label rLab  = na
var int zBar    = na

// Box array for current active range gradient fill (historical boxes are preserved)
var box[] aBox  = array.new_box(0)
int nSli        = 16

cAtr   = ta.atr(aLen)
bool jstTr      = false

// Dashboard tracking variables
var string lDir = "None"
var float lPrc  = na
var float eCls  = na
var int[] trRes = array.new_int(0)

// State Machine Logic
if stat == "SEARCHING"
    if stbl
        mLVal := rAvg
        uLVal := hi
        lLVal := lo
        zBar  := bar_index - len1
        
        // Create permanent historical lines for the new zone using user input color
        mLin  := line.new(zBar, mLVal, bar_index, mLVal, width=1, color = cMid)
        
        // Create range label positioned at the horizontal middle of the range length
        int midBar = math.round(zBar + (bar_index - zBar) / 2.0)
        rLab  := label.new(midBar, uLVal, text=f_txt(uLVal, lLVal), color=color.new(cMid, 100), textcolor=chart.fg_color, style=label.style_label_down, size=size.small)
        
        // Initialize new active range boxes without deleting historical past boxes
        aBox  := array.new_box(0)
        sSiz  = (uLVal - lLVal) / nSli
        
        for i = 0 to nSli - 1
            bBot = lLVal + (i * sSiz)
            bTop = lLVal + ((i + 1) * sSiz)
 
            // Calculate gradient transparency for active consolidation state using neutral mid color
            dCtr = math.abs(i - (nSli - 1) / 2.0)
            mDst = (nSli - 1) / 2.0
            trns = math.round(110 - (90 - 50) * (dCtr / mDst))

            
            b = box.new(zBar, bTop, bar_index, bBot, border_color=na, bgcolor=color.new(cMid, int(trns)))
            array.push(aBox, b)
        
        stat := "ZONE_ACTIVE"

else if stat == "ZONE_ACTIVE"
    // Extend active lines, current gradient boxes, and keep label centered horizontally as time moves on
    line.set_x2(mLin, bar_index)
    
    int midBar = math.round(zBar + (bar_index - zBar) / 2.0)
    label.set_x(rLab, midBar)
    label.set_y(rLab, uLVal)
    label.set_text(rLab, f_txt(uLVal, lLVal))
    
    if array.size(aBox) > 0
        for b in aBox
            box.set_right(b, bar_index)
    
    if close > uLVal and barstate.isconfirmed
        isBul  := true
        tStop  := low - (cAtr * aMul)
        
        // Record dashboard metrics for breakout
        lDir   := "BULLISH"
        lPrc   := close
        eCls   := close
        
        // Keep label centered horizontally and pinned to lower line pointing up on bullish breakout
        label.set_x(rLab, math.round(zBar + (bar_index - zBar) / 2.0))
        label.set_y(rLab, lLVal)
        label.set_style(rLab, label.style_label_up)
        label.set_textcolor(rLab, chart.fg_color)
        
        // Color gradient boxes pale green on upward breakout
        if array.size(aBox) > 0
            for i = 0 to array.size(aBox) - 1
                b = array.get(aBox, i)
                dCtr = math.abs(i - (nSli - 1) / 2.0)
                mDst = (nSli - 1) / 2.0
                trns = math.round(110 - (90 - 50) * (dCtr / mDst))
                box.set_bgcolor(b, color.new(cBul, int(trns)))
        
        stat  := "TRAILING"
        jstTr := true
        
    else if close < lLVal and barstate.isconfirmed
        isBul  := false
        tStop  := high + (cAtr * aMul)
        
        // Record dashboard metrics for breakout
        lDir   := "BEARISH"
        lPrc   := close
        eCls   := close
        
        // Keep label centered horizontally and pinned to upper line pointing down on bearish breakout
        label.set_x(rLab, math.round(zBar + (bar_index - zBar) / 2.0))
        label.set_y(rLab, uLVal)
        label.set_style(rLab, label.style_label_down)
        label.set_textcolor(rLab, chart.fg_color)
        
        // Color gradient boxes pale red on downward breakout         
        if array.size(aBox) > 0
            for i = 0 to array.size(aBox) - 1
                b = array.get(aBox, i)
                dCtr = math.abs(i - (nSli - 1) / 2.0)
                mDst = (nSli - 1) / 2.0
                trns = math.round(110 - (90 - 50) * (dCtr / mDst))
                box.set_bgcolor(b, color.new(cBar, int(trns)))

        stat  := "TRAILING"
        jstTr := true

else if stat == "TRAILING"
    if isBul
        tStop := math.max(tStop, low - (cAtr * aMul))
        if close < tStop and barstate.isconfirmed
            bool isWin = isBul ? (close > eCls) : (close < eCls)
            array.push(trRes, isWin ? 1 : 0)
            if array.size(trRes) > wLen
                array.shift(trRes)
            stat := "SEARCHING"
    else
        tStop := math.min(tStop, high + (cAtr * aMul))
        if close > tStop and barstate.isconfirmed
            bool isWin = isBul ? (close > eCls) : (close < eCls)
            array.push(trRes, isWin ? 1 : 0)
            if array.size(trRes) > wLen
                array.shift(trRes)
            stat := "SEARCHING"
// }

// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
tSPlt  = stat == "TRAILING" ? tStop : na
hPlt   = stat == "TRAILING" ? hl2 : na

p1 = plot(tSPlt, title="Trailing Stop", color=isBul ? cBul : cBar, linewidth=1, style=plot.style_linebr)
p2 = plot(tSPlt + (isBul ? +cAtr : -cAtr), title="Trailing Stop Reference", color=color.new(color.white, 100), style=plot.style_linebr)
fill(p1, p2, color=color.new(isBul ? cBul : cBar, 90), title="Trailing Stop Fill")

// Circle marker at the exact starting point of the trailing stop
plotshape(jstTr ? tSPlt : na, title="Trailing Start Circle", style=shape.circle, location=location.absolute, color= color.new(isBul ? cBul : cBar, 50), size=size.small)
plotshape(jstTr ? tSPlt : na, title="Trailing Start Circle", style=shape.circle, location=location.absolute, color= color.new(isBul ? cBul : cBar, 0), size=size.tiny)

// Dashboard Table Generation
var table dash = table.new(position = position.top_right, columns = 2, rows = 3, bgcolor = color.new(color.black, 50), border_color = chart.bg_color, border_width = 2)
if barstate.islast
    // Calculate Win Rate statistics
    int tTrd  = array.size(trRes)
    int wins  = tTrd > 0 ? array.sum(trRes) : 0
    float wRat = tTrd > 0 ? (float(wins) / float(tTrd)) * 100.0 : 0.0

    // Populate Table Cells
    table.cell(dash, 0, 0, "Last Breakout", text_color=chart.fg_color, text_size=size.normal)
    table.cell(dash, 1, 0, lDir + "/" + str.tostring(lPrc, "#.##"), text_color=lDir == "BULLISH" ? cBul : cBar, text_size=size.normal)
    
    table.cell(dash, 0, 1, "Closed Trades", text_color=chart.fg_color, text_size=size.normal)
    table.cell(dash, 1, 1, str.tostring(tTrd), text_color=chart.fg_color, text_size=size.normal)
    
    table.cell(dash, 0, 2, "Win Rate", text_color=chart.fg_color, text_size=size.normal)
    table.cell(dash, 1, 2, str.tostring(wins) + "/" + str.tostring(tTrd) + " (" + str.tostring(wRat, "#.##") + "%)", text_color=wRat >= 50 ? cBul : cBar, text_size=size.normal)
// }
````
