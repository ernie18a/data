# HTF Candle PO3 AMD Sessions

- url: https://www.tradingview.com/script/cWU7ElBx-HTF-Candle-PO3-AMD-Sessions/
- type: indicator
- pine_id: PUB;01be7a86ba1343e1a4cdac95980bb3c8
- version: 1.0

## Description

HTF Session Dashboard (Higher Timeframe Candles)
Core idea: This indicator allows you to view the price action of a Higher Timeframe (HTF) drawn as full candles directly on your current lower timeframe chart. It's designed to keep you aware of the macro market structure without needing to constantly switch timeframes.

How It Works
Instead of just showing standard HTF levels, this indicator dynamically builds and projects the current day's higher timeframe candles (e.g., 4-Hour candles) off to the right side of your active chart (e.g., a 1-minute or 5-minute chart).

The candles are constructed in real-time. As price moves on your lower timeframe, the active "current" HTF candle will grow its wicks and adjust its body live.

Key Features
Live HTF Candle Projection: Displays the sequence of HTF candles that make up the current trading day, spaced neatly to the right of the current price action.
Session Extremes: Automatically draws dotted reference lines stretching across your chart to highlight the absolute High, Low, Body High, and Body Low of the entire current session.
Live Countdown Timer: Shows a dynamic timer above and below the candle cluster indicating exactly how much time is left until the active HTF candle closes.
Hour Labels: Every HTF candle has a small label indicating its open hour (with an adjustable timezone offset setting) to help you quickly identify Kill Zones within the macro candles.
Visual Customization: Fully adjustable body width, transparency, spacing, offset distance, and bull/bear color schemes.
Clean Daily Reset: The indicator automatically clears the prior day's candles at midnight (exchange time) and begins building the new sequence, keeping your chart uncluttered.
Why Use This?
When trading intraday (like on a 1m chart), it's easy to get lost in the noise and trade right into a major 4-Hour support or resistance level. By projecting the 4-Hour candles directly onto your 1-minute chart, you always know exactly where you are relative to the higher timeframe narrative and structure.

Recommended Settings
HTF Setting: 240 (4 Hours) or 60 (1 Hour) when trading on a 1m–15m chart.
Hour Label Offset: Adjust this (e.g., +1 or -1) if you want the candle hour labels to match a specific local time zone (like EST) rather than exchange time.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © antigravity

//@version=6
indicator("HTF Session Dashboard", overlay=true, max_boxes_count=50, max_lines_count=50, max_labels_count=50)

// ══════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════
string G_HTF   = "HTF Settings"
string i_htfTF = input.timeframe("240", "Higher Timeframe", group=G_HTF)

string G_STYLE = "Appearance"
color  i_bullCol = input.color(#4caf50, "Bull Body Color", group=G_STYLE)
color  i_bearCol = input.color(#f44336, "Bear Body Color", group=G_STYLE)
color  i_bullBordCol = input.color(#4caf50, "Bull Border Color", group=G_STYLE)
color  i_bearBordCol = input.color(#f44336, "Bear Border Color", group=G_STYLE)
int    i_transp  = input.int(20, "Body Transparency", minval=0, maxval=100, group=G_STYLE)
int    i_width   = input.int(2, "Candle Width (Bars)", minval=1, maxval=10, group=G_STYLE)

string G_POS   = "Positioning"
int    i_offset  = input.int(15, "Offset from Current Bar", group=G_POS)
int    i_spacing = input.int(5, "Spacing Between Candles", group=G_POS)

string G_DISP  = "Display Elements"
bool   i_showHL    = input.bool(true, "Show Session H/L Lines", group=G_DISP)
bool   i_showBodyHL= input.bool(true, "Show Session Body H/L Lines", group=G_DISP)
bool   i_showTimer = input.bool(true, "Show Timer & TF Label", group=G_DISP)
int    i_hrOffset  = input.int(1, "Hour Label Offset", group=G_DISP, tooltip="Adjusts the hour label up or down (e.g. +1 for EST)")

// ══════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════
f_getTimerStr(int ms) =>
    if ms < 0
        "00:00"
    else
        int sec = math.floor(ms / 1000)
        int h = math.floor(sec / 3600)
        int m = math.floor((sec % 3600) / 60)
        int s = sec % 60
        h > 0 ? str.format("{0,number,00}:{1,number,00}:{2,number,00}", h, m, s) : str.format("{0,number,00}:{1,number,00}", m, s)

f_priceStr(float price) =>
    if price == math.floor(price)
        str.tostring(int(price))
    else
        str.tostring(price, format.mintick)

// HTF candle close time (for countdown timer)
int htfCloseTime = request.security(syminfo.tickerid, i_htfTF, time_close, lookahead=barmerge.lookahead_on)

// ══════════════════════════════════════════════════════════════
//  STATE VARIABLES
// ══════════════════════════════════════════════════════════════
var array<float> oArr  = array.new_float()
var array<float> hArr  = array.new_float()
var array<float> lArr  = array.new_float()
var array<float> cArr  = array.new_float()
var array<int>   hrArr = array.new_int()

var float curO  = na
var float curH  = na
var float curL  = na
var int   curHr = na

// ══════════════════════════════════════════════════════════════
//  DATA COLLECTION
// ══════════════════════════════════════════════════════════════
bool isNewDay = timeframe.change("D")
bool isNewHTF = timeframe.change(i_htfTF)

if isNewDay
    array.clear(oArr)
    array.clear(hArr)
    array.clear(lArr)
    array.clear(cArr)
    array.clear(hrArr)
    curO  := na
    curH  := na
    curL  := na
    curHr := na

if isNewHTF
    if not na(curO)
        // Save completed candle
        array.push(oArr, curO)
        array.push(hArr, curH)
        array.push(lArr, curL)
        array.push(cArr, close[1])
        array.push(hrArr, curHr)
    
    // Start new candle
    // Match open with previous close exactly if not start of day to eliminate visual gaps
    curO  := isNewDay ? open : nz(close[1], open)
    curH  := math.max(high, curO)
    curL  := math.min(low, curO)
    curHr := (hour(time) + i_hrOffset) % 24
else if not na(curO)
    curH := math.max(curH, high)
    curL := math.min(curL, low)

// ══════════════════════════════════════════════════════════════
//  DRAWING ENGINE
// ══════════════════════════════════════════════════════════════
var array<box>   boxes  = array.new_box()
var array<line>  lines  = array.new_line()
var array<label> labels = array.new_label()

if barstate.islast
    // ─── Clear previous drawings ───
    while array.size(boxes) > 0
        box.delete(array.pop(boxes))
    while array.size(lines) > 0
        line.delete(array.pop(lines))
    while array.size(labels) > 0
        label.delete(array.pop(labels))
    
    int totalCandles = array.size(oArr) + (na(curO) ? 0 : 1)
    if totalCandles > 0
        int startX = bar_index + i_offset
        
        float sessHigh = na
        float sessLow  = na
        float bodyHigh = na
        float bodyLow  = na
        
        // ─── Step 1: Calculate Extremes ───
        for i = 0 to totalCandles - 1
            bool isCurrent = (i == totalCandles - 1) and not na(curO)
            float _o = isCurrent ? curO : array.get(oArr, i)
            float _h = isCurrent ? curH : array.get(hArr, i)
            float _l = isCurrent ? curL : array.get(lArr, i)
            float _c = isCurrent ? close : array.get(cArr, i)
            
            sessHigh := na(sessHigh) ? _h : math.max(sessHigh, _h)
            sessLow  := na(sessLow)  ? _l : math.min(sessLow, _l)
            
            float bt = math.max(_o, _c)
            float bb = math.min(_o, _c)
            bodyHigh := na(bodyHigh) ? bt : math.max(bodyHigh, bt)
            bodyLow  := na(bodyLow)  ? bb : math.min(bodyLow, bb)

        // ─── Step 2: Draw Background Lines ───
        int clusterLeft   = startX
        int clusterRight  = startX + (totalCandles - 1) * i_spacing
        int clusterCenter = int(math.round((clusterLeft + clusterRight) / 2.0))
        
        color lineCol  = color.new(chart.fg_color, 70)
        color priceCol = color.new(chart.fg_color, 40)
        int   lineLeft = bar_index - 50  // Extend lines to the left behind price action
        
        if i_showHL and not na(sessHigh) and not na(sessLow)
            // Session High
            array.push(lines, line.new(x1=lineLeft, y1=sessHigh, x2=clusterRight + 5, y2=sessHigh, color=lineCol, style=line.style_dotted))
            array.push(labels, label.new(x=clusterRight + 5, y=sessHigh, text=f_priceStr(sessHigh), style=label.style_none, textcolor=priceCol, size=size.tiny))
            // Session Low
            array.push(lines, line.new(x1=lineLeft, y1=sessLow, x2=clusterRight + 5, y2=sessLow, color=lineCol, style=line.style_dotted))
            array.push(labels, label.new(x=clusterRight + 5, y=sessLow, text=f_priceStr(sessLow), style=label.style_none, textcolor=priceCol, size=size.tiny))

        if i_showBodyHL and not na(bodyHigh) and not na(bodyLow)
            if math.abs(bodyHigh - sessHigh) > syminfo.mintick
                array.push(lines, line.new(x1=lineLeft, y1=bodyHigh, x2=clusterRight + 5, y2=bodyHigh, color=color.new(i_bearCol, 50), style=line.style_dotted))
                array.push(labels, label.new(x=clusterRight + 5, y=bodyHigh, text=f_priceStr(bodyHigh), style=label.style_none, textcolor=color.new(i_bearCol, 20), size=size.tiny))
            if math.abs(bodyLow - sessLow) > syminfo.mintick
                array.push(lines, line.new(x1=lineLeft, y1=bodyLow, x2=clusterRight + 5, y2=bodyLow, color=color.new(i_bullCol, 50), style=line.style_dotted))
                array.push(labels, label.new(x=clusterRight + 5, y=bodyLow, text=f_priceStr(bodyLow), style=label.style_none, textcolor=color.new(i_bullCol, 20), size=size.tiny))

        // ─── Step 3: Draw Candles ───
        float rangeY = sessHigh - sessLow
        
        for i = 0 to totalCandles - 1
            bool isCurrent = (i == totalCandles - 1) and not na(curO)
            float _o = isCurrent ? curO : array.get(oArr, i)
            float _h = isCurrent ? curH : array.get(hArr, i)
            float _l = isCurrent ? curL : array.get(lArr, i)
            float _c = isCurrent ? close : array.get(cArr, i)
            int   _hr= isCurrent ? curHr : array.get(hrArr, i)
            
            int xPos = startX + (i * i_spacing)
            int boxL = xPos - math.floor(i_width / 2)
            int boxR = xPos + math.ceil(i_width / 2)
            if boxR <= boxL
                boxR := boxL + 1
            
            bool isBull = _c >= _o
            color cCol = isBull ? i_bullCol : i_bearCol
            color bordCol = isBull ? i_bullBordCol : i_bearBordCol
            color bgCol = color.new(cCol, i_transp)
            
            float bt = math.max(_o, _c)
            float bb = math.min(_o, _c)
            
            // Body
            array.push(boxes, box.new(left=boxL, top=bt, right=boxR, bottom=bb, border_color=bordCol, bgcolor=bgCol))
            
            // Wicks
            if _h > bt
                array.push(lines, line.new(x1=xPos, y1=bt, x2=xPos, y2=_h, color=bordCol))
            if _l < bb
                array.push(lines, line.new(x1=xPos, y1=bb, x2=xPos, y2=_l, color=bordCol))
                
            // Hour Label
            array.push(labels, label.new(x=xPos, y=_h + (rangeY * 0.05), text=str.tostring(_hr), style=label.style_none, textcolor=chart.fg_color, size=size.small))

        // ─── Step 4: Draw Header/Footer Timer ───
        if i_showTimer
            string tfStr = i_htfTF
            if not na(str.tonumber(tfStr))
                int tfMins = int(str.tonumber(tfStr))
                tfStr := tfMins >= 60 ? str.tostring(tfMins / 60) + "H" : tfStr + "m"
            
            int timeLeftMs = htfCloseTime - timenow
            string timeStr = f_getTimerStr(timeLeftMs)
            
            string topText = tfStr + "\n(" + timeStr + ")"
            string botText = "(" + timeStr + ")\n" + tfStr
            
            array.push(labels, label.new(x=clusterCenter, y=sessHigh + (rangeY * 0.15), text=topText, style=label.style_none, textcolor=priceCol, size=size.normal, textalign=text.align_center))
            array.push(labels, label.new(x=clusterCenter, y=sessLow - (rangeY * 0.15), text=botText, style=label.style_none, textcolor=priceCol, size=size.normal, textalign=text.align_center))
````
