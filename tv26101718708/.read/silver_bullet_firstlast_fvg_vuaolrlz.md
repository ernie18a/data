# Silver Bullet & First/Last FVG

- url: https://www.tradingview.com/script/vuaOLrLz-Silver-Bullet-First-Last-FVG/
- type: indicator
- pine_id: PUB;9bef8d3dcfc345619d217ebd7321f33d
- version: 1.0

## Description

It is designed around the popular ICT (Inner Circle Trader) "Silver Bullet" concepts. Its main purpose is to highlight specific time-based trading windows on your chart and automatically detect and isolate the most significant Fair Value Gaps (FVGs) that form within those windows.

Here is a breakdown of its functionality:

1. Specific Time Sessions
The script monitors three specific 1-hour time windows (defaulting to New York time, but adjustable):

London Silver Bullet: 03:00 - 04:00
New York AM Silver Bullet: 10:00 - 11:00
New York PM Silver Bullet: 14:00 - 15:00
Each of these sessions can be toggled on/off individually, and their border colors customized.

2. Session Range Highlighting
When one of these 1-hour sessions begins, the script starts tracking the absolute Highest and Lowest price reached during that hour.

Once the session ends, it draws a large, semi-transparent box encapsulating that entire 1-hour price action range.
The box is labeled in the bottom right corner (e.g., "Lon SB" or "NY AM SB") so you can easily visually identify the Silver Bullet hour in hindsight.

3. First and Last FVG Detection
This is the most unique feature of the script. While standard indicators highlight every FVG, this script filters them based on the Silver Bullet sessions:

It continuously looks for standard 3-candle Fair Value Gaps (both bullish and bearish).
However, it only plots FVGs if they occur inside one of the active Silver Bullet sessions.
Furthermore, to reduce clutter, it only stores and plots the First FVG and the Last FVG that formed during that specific 1-hour window.
It automatically extends the boxes of these specific FVGs to match the right edge (end time) of the Silver Bullet session box.

4. Memory and Optimization
To prevent TradingView from throwing "too many drawings" errors or causing lag on your chart:

It uses a custom data structure (SBSessionData) to manage the state of each session cleanly.
At the start of every new day, it runs a cleanup function (clearDrawings()) that deletes older session boxes and FVGs if they exceed the user-defined sb_lookback limit (default 100 historical boxes).

## Source Code

````pine
//@version=6
indicator("Silver Bullet & First/Last FVG", overlay=true, max_boxes_count=500)

grp_time_sb = "SB Time Settings"
tz_sb = input.string("America/New_York", "SB Timezone", group=grp_time_sb)

grp_lon_sb = "London Silver Bullet (03:00 - 04:00)"
showLon = input.bool(true, "Enable London SB", group=grp_lon_sb)
lonBordCol = input.color(color.new(#2196F3, 50), "London Border Color", group=grp_lon_sb)

grp_nyam_sb = "NY AM Silver Bullet (10:00 - 11:00)"
showNyAm = input.bool(true, "Enable NY AM SB", group=grp_nyam_sb)
nyAmBordCol = input.color(color.new(#4CAF50, 50), "NY AM Border Color", group=grp_nyam_sb)

grp_nypm_sb = "NY PM Silver Bullet (14:00 - 15:00)"
showNyPm = input.bool(true, "Enable NY PM SB", group=grp_nypm_sb)
nyPmBordCol = input.color(color.new(#FF9800, 50), "NY PM Border Color", group=grp_nypm_sb)

grp_style_sb = "SB Style Settings"
boxBorderWidth_sb = input.int(1, "SB Box Border Width", group=grp_style_sb)
labelTextColor_sb = input.color(color.new(#000000, 50), "SB Label Text Color", group=grp_style_sb)
sb_lookback = input.int(100, "Historical Drawings Lookback", maxval=500, group=grp_style_sb)

grp_fvg = "FVG Settings"
bullFvgCol = input.color(color.new(#4CAF50, 80), "Bullish FVG Color", group=grp_fvg)
bearFvgCol = input.color(color.new(#F44336, 80), "Bearish FVG Color", group=grp_fvg)

// Global FVG detection (3-candle pattern)
var box[] sb_historical_boxes = array.new_box()

isBullFvg = low[0] > high[2] and close[1] > open[1]
isBearFvg = high[0] < low[2] and close[1] < open[1]

float fvgTop = isBullFvg ? low[0] : isBearFvg ? low[2] : na
float fvgBot = isBullFvg ? high[2] : isBearFvg ? high[0] : na
int fvgTimeLeft = time[2]

type SBSessionData
    float highPx = na
    float lowPx = na
    int startTime = na
    bool isDrawn = false
    box sbBox = na
    box firstFvg = na
    box lastFvg = na

method clearDrawings(SBSessionData this) =>
    if not na(this.sbBox)
        array.push(sb_historical_boxes, this.sbBox)
    if not na(this.firstFvg)
        array.push(sb_historical_boxes, this.firstFvg)
    if not na(this.lastFvg)
        array.push(sb_historical_boxes, this.lastFvg)
        
    while array.size(sb_historical_boxes) > sb_lookback
        box.delete(array.shift(sb_historical_boxes))
        
    this.sbBox := na
    this.firstFvg := na
    this.lastFvg := na

method drawBox(SBSessionData this, int endTime, color boxCol, int boxWidth, color txtCol, string nameStr) =>
    this.sbBox := box.new(left=this.startTime, top=this.highPx, right=endTime, bottom=this.lowPx, border_color=boxCol, border_width=boxWidth, bgcolor=color.new(boxCol, 90), text="  " + nameStr + "  ", text_color=txtCol, text_size=size.small, text_halign=text.align_right, text_valign=text.align_bottom, xloc=xloc.bar_time)
    this.isDrawn := true
    
    // Extend FVG boxes to end of session time
    if not na(this.firstFvg)
        box.set_right(this.firstFvg, endTime)
    if not na(this.lastFvg)
        box.set_right(this.lastFvg, endTime)

method updateSession(SBSessionData this, bool isActive, bool isEnabled, color boxCol, int boxWidth, color txtCol, string nameStr, bool bullFvg, bool bearFvg, float fTop, float fBot, int fTimeLeft) =>
    if isEnabled
        if isActive
            if na(this.startTime)
                this.startTime := time
                this.highPx := high
                this.lowPx := low
            else
                this.highPx := math.max(this.highPx, high)
                this.lowPx := math.min(this.lowPx, low)
                
            // Track FVGs
            if bullFvg or bearFvg
                color bg = bullFvg ? bullFvgCol : bearFvgCol
                box newFvg = box.new(left=fTimeLeft, top=fTop, right=time, bottom=fBot, border_color=na, bgcolor=bg, xloc=xloc.bar_time)
                
                if na(this.firstFvg)
                    this.firstFvg := newFvg
                else
                    if not na(this.lastFvg)
                        box.delete(this.lastFvg)
                    this.lastFvg := newFvg
                    
        // End of session logic
        bool justExited = not isActive and isActive[1]
        if justExited and not this.isDrawn and not na(this.startTime)
            this.drawBox(time[1], boxCol, boxWidth, txtCol, nameStr)

var SBSessionData lonSB = SBSessionData.new()
var SBSessionData nyAmSB = SBSessionData.new()
var SBSessionData nyPmSB = SBSessionData.new()

bool inLon = not na(time(timeframe.period, "0300-0400", tz_sb))
bool inNyAm = not na(time(timeframe.period, "1000-1100", tz_sb))
bool inNyPm = not na(time(timeframe.period, "1400-1500", tz_sb))

bool isNewDay = timeframe.change("D")

if isNewDay
    lonSB.clearDrawings()
    lonSB.highPx := na
    lonSB.lowPx := na
    lonSB.startTime := na
    lonSB.isDrawn := false
    
    nyAmSB.clearDrawings()
    nyAmSB.highPx := na
    nyAmSB.lowPx := na
    nyAmSB.startTime := na
    nyAmSB.isDrawn := false
    
    nyPmSB.clearDrawings()
    nyPmSB.highPx := na
    nyPmSB.lowPx := na
    nyPmSB.startTime := na
    nyPmSB.isDrawn := false

lonSB.updateSession(inLon, showLon, lonBordCol, boxBorderWidth_sb, labelTextColor_sb, "Lon SB", isBullFvg, isBearFvg, fvgTop, fvgBot, fvgTimeLeft)
nyAmSB.updateSession(inNyAm, showNyAm, nyAmBordCol, boxBorderWidth_sb, labelTextColor_sb, "NY AM SB", isBullFvg, isBearFvg, fvgTop, fvgBot, fvgTimeLeft)
nyPmSB.updateSession(inNyPm, showNyPm, nyPmBordCol, boxBorderWidth_sb, labelTextColor_sb, "NY PM SB", isBullFvg, isBearFvg, fvgTop, fvgBot, fvgTimeLeft)
````
