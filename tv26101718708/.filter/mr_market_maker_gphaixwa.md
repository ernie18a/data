# Mr. Market Maker

- url: https://www.tradingview.com/script/gPHaIxWa-Mr-Market-Maker/
- type: indicator
- pine_id: PUB;07af59bb721c470d932ccb4096087f31
- version: 2.0

## Description

Mr. Market Maker (MR.MM)
Mr. Market Maker is an advanced technical analysis tool designed for traders following Smart Money Concepts (SMC) and institutional trading frameworks. It automates the complex process of identifying structural shifts in the market, specifically focusing on trend reversals and continuations using precision-calculated Gann levels.

Key Features:
Dynamic Market Structure Detection:
The script uses a sophisticated fractal-based algorithm to identify Pivot Highs and Lows. These levels serve as the foundation for institutional supply and demand zones.
Dual-Engine Setup Logic:
CHoCH Engine (Change of Character): Automatically detects when the market sentiment shifts from bullish to bearish (or vice versa), identifying high-probability reversal setups.
BOS Engine (Break of Structure): Tracks trend continuation signals, allowing traders to scale into positions during strong trending phases.
Both engines operate independently and can be toggled on/off based on your trading strategy.
Automated Gann Box Execution:
Upon a structural break, the script instantly draws a customized Gann Box. It highlights the 0.382 - 0.618 "Entry Zone", which is widely regarded as the optimal institutional discount/premium area for entries.
Real-Time Liquidity Mapping:
The indicator identifies and visualizes "Candidate" levels. These horizontal levels represent Sell-Side and Buy-Side Liquidity, providing you with dynamic targets and logical stop-loss placements.
Integrated Trend Filtering:
Includes a multi-type Moving Average filter (SMA, EMA, WMA, HMA, RMA) to ensure that your setups are always aligned with the macro trend, significantly reducing "fake-out" signals.
Smart Alert System:
A consolidated alert engine monitors both CHoCH and BOS setups. It triggers a notification the moment price enters the defined Entry Zone, ensuring you never miss a high-conviction trade.
Optimized Visual Management:
The "Show Last N" feature keeps your chart clean by managing object counts, while the "Sliding Update" logic ensures that active setups dynamically extend to the current price action.
Disclaimer
Trading involves significant risk of loss and is not suitable for every investor. The "Mr. Market Maker" indicator is provided for educational and informational purposes only. It does not constitute financial, investment, or trading advice. Past performance is not indicative of future results. The developer and associated parties are not responsible for any financial losses incurred through the use of this script. Always perform your own due diligence, backtest thoroughly, and use appropriate risk management before trading with real capital.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Mr. Market Maker", shorttitle="MR.MM", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//==================== CORE ====================
grpCore = "Core Settings"
len          = input.int(10, "Fractal Length", minval=3, maxval=51, group=grpCore, tooltip="Pivot detection length")
requireBody  = input.bool(true, "Break = Close Beyond Level", group=grpCore, tooltip="If true, requires candle close beyond level for CHoCH/BOS")
showLastN    = input.int(1, "Show Last N per Engine", minval=1, group=grpCore, tooltip="How many setups to keep visible FOR EACH engine (CHoCH and BOS separately)")

grpEng = "Setup Engines"
useChoch     = input.bool(true, "CHoCH Setup Engine", group=grpEng, tooltip="Enable setups based on Change of Character (Trend Reversal)")
useBos       = input.bool(false, "BOS Setup Engine", group=grpEng, tooltip="Enable setups based on Break of Structure (Trend Continuation)")

//==================== HTF FILTER ====================
grpHTF = "HTF Bias Filter"
useHtfFilter = input.bool(true, "Use HTF Bias Filter", group=grpHTF)
htfRes       = input.timeframe("720", "HTF Resolution", group=grpHTF) // 12h = 720
htfGrayCol   = input.color(color.new(color.gray, 60), "Filtered Out Color", group=grpHTF)

//==================== TREND FILTER ====================
grpTrend = "Trend Filter (MA)"
useFilter   = input.bool(false, "Use Trend Filter", group=grpTrend)
maType      = input.string("EMA", "MA Type", options=["SMA", "EMA", "WMA", "HMA", "RMA"], group=grpTrend)
maLen       = input.int(200, "MA Length", minval=1, group=grpTrend)
maCol       = input.color(color.new(color.gray, 50), "MA Color", group=grpTrend)
showMA      = input.bool(false, "Show MA on Chart", group=grpTrend)

f_ma(type, src, length) =>
    switch type
        "SMA" => ta.sma(src, length)
        "EMA" => ta.ema(src, length)
        "WMA" => ta.wma(src, length)
        "HMA" => ta.hma(src, length)
        "RMA" => ta.rma(src, length)
        => ta.ema(src, length)

maValue = f_ma(maType, close, maLen)
plot(showMA ? maValue : na, "Trend Filter MA", color=maCol, linewidth=1)

trendBullish = not useFilter or close > maValue
trendBearish = not useFilter or close < maValue

//==================== CANDIDATE STYLE ====================
grpCand = "Candidate BOS Settings"
candBarsToRight = input.int(5, "Candidate Extension (Bars)", minval=1, maxval=500, group=grpCand)
candCol         = input.color(color.black, "Candidate Color", group=grpCand)
candW           = 2 

//==================== SETUP STYLE ====================
grpStyle = "Gann Box / Setup Settings"
gannBarsToRight = input.int(20, "Gann Box Width (Bars)", minval=1, maxval=500, group=grpStyle)
bearCol         = input.color(color.red, "Bearish Setup Color", group=grpStyle)
bullCol         = input.color(color.rgb(8, 153, 129), "Bullish Setup Color", group=grpStyle)
blackCol        = input.color(color.black, "Skeleton Color (Black)", group=grpStyle)

//==================== HTF LOGIC ====================
f_calcOs(pLen, reqBody) =>
    float pHigh = ta.pivothigh(high, pLen, pLen)
    float pLow  = ta.pivotlow(low, pLen, pLen)
    
    var float uLvl = na
    var bool uBrok = false
    var float dLvl = na
    var bool dBrok = false
    
    if not na(pHigh)
        uLvl := pHigh
        uBrok := false
    if not na(pLow)
        dLvl := pLow
        dBrok := false
        
    bUp = not na(uLvl) and not uBrok and (reqBody ? close > uLvl : high > uLvl)
    bDn = not na(dLvl) and not dBrok and (reqBody ? close < dLvl : low < dLvl)
    
    var int currentOs = 0
    if bUp
        uBrok := true
        currentOs := 1
    if bDn
        dBrok := true
        currentOs := -1
    
    currentOs

htfOs = request.security(syminfo.tickerid, htfRes, f_calcOs(int(len/2), requireBody)[1], lookahead=barmerge.lookahead_on)

//==================== UDT FOR CLEANUP ====================
type SetupInfo
    box[]   boxes
    line[]  lines
    label[] labels
    bool    isBullish
    float   zTop     // Entry Zone Top
    float   zBot     // Entry Zone Bottom
    string  labelTxt
    int     lastUpdateBar = 0

method clearObjects(SetupInfo self) =>
    for b in self.boxes
        box.delete(b)
    for l in self.lines
        line.delete(l)
    for lb in self.labels
        label.delete(lb)

var SetupInfo[] chochSetups = array.new<SetupInfo>()
var SetupInfo[] bosSetups   = array.new<SetupInfo>()

f_cleanup(SetupInfo[] targetArr) =>
    if array.size(targetArr) > showLastN
        SetupInfo old = array.shift(targetArr)
        old.clearObjects()

//==================== PIVOTS ====================
pLen = int(len / 2)
phVal = ta.pivothigh(high, pLen, pLen)
plVal = ta.pivotlow(low,  pLen, pLen)

//==================== STATE ====================
var float upLvl = na, var int upT = na, var bool upBroken = false, var line upLine = na, var label upLab = na
var float dnLvl = na, var int dnT = na, var bool dnBroken = false, var line dnLine = na, var label dnLab = na
var int os = 0 

tfMs = timeframe.in_seconds(timeframe.period) * 1000

//==================== CANDIDATE MOTORU ====================
if not na(phVal)
    if not na(upLine)
        line.delete(upLine)
    if not na(upLab)
        label.delete(upLab)
    upLvl := phVal
    upT   := time[pLen]
    upBroken := false
    upLine := line.new(upT, upLvl, time + tfMs * candBarsToRight, upLvl, xloc=xloc.bar_time, color=candCol, style=line.style_solid, width=candW)
    upLab  := label.new(int(math.avg(upT, time + tfMs * candBarsToRight)), upLvl, "Sell Positions StopLoss Level", xloc=xloc.bar_time, textcolor=bearCol, style=label.style_label_down, color=color.new(color.white, 100), size=size.small)

if not na(plVal)
    if not na(dnLine)
        line.delete(dnLine)
    if not na(dnLab)
        label.delete(dnLab)
    dnLvl := plVal
    dnT   := time[pLen]
    dnBroken := false
    dnLine := line.new(dnT, dnLvl, time + tfMs * candBarsToRight, dnLvl, xloc=xloc.bar_time, color=candCol, style=line.style_solid, width=candW)
    dnLab  := label.new(int(math.avg(dnT, time + tfMs * candBarsToRight)), dnLvl, "Buy Positions Stop Loss level", xloc=xloc.bar_time, textcolor=bullCol, style=label.style_label_up, color=color.new(color.white, 100), size=size.small)

// Update extensions
if not na(upLine)
    line.set_x2(upLine, time + tfMs * candBarsToRight)
    label.set_x(upLab, int(math.avg(upT, time + tfMs * candBarsToRight)))
if not na(dnLine)
    line.set_x2(dnLine, time + tfMs * candBarsToRight)
    label.set_x(dnLab, int(math.avg(dnT, time + tfMs * candBarsToRight)))

//==================== EXACT GANN BOX FUNCTION ====================
f_createGann(SetupInfo[] targetArr, float hh, float ll, int anchorT, int breakT, bool isBullish, string labelTxt) =>
    float rng = hh - ll
    
    float y0236 = isBullish ? hh - rng * 0.236 : ll + rng * 0.236
    float y0382 = isBullish ? hh - rng * 0.382 : ll + rng * 0.382
    float y0500 = isBullish ? hh - rng * 0.500 : ll + rng * 0.500
    float y0618 = isBullish ? hh - rng * 0.618 : ll + rng * 0.618
    float y0764 = isBullish ? hh - rng * 0.764 : ll + rng * 0.764
    
    float y100_top = isBullish ? hh : ll
    float y100_bot = isBullish ? ll : hh
    
    SetupInfo s = SetupInfo.new(array.new_box(), array.new_line(), array.new_label(), isBullish, math.max(y0382, y0618), math.min(y0382, y0618), labelTxt, bar_index)
    
    // Determine color based on HTF filter
    color baseDirColor = isBullish ? bullCol : bearCol
    color dirColor = baseDirColor
    if useHtfFilter
        if isBullish and htfOs == -1
            dirColor := htfGrayCol
        else if not isBullish and htfOs == 1
            dirColor := htfGrayCol
            
    color activeBlack = useHtfFilter and ((isBullish and htfOs == -1) or (not isBullish and htfOs == 1)) ? htfGrayCol : blackCol
            
    int lineEnd = time + tfMs * gannBarsToRight

    // Horizontal Levels
    s.lines.push(line.new(breakT, y0236, lineEnd, y0236, xloc=xloc.bar_time, color=activeBlack, style=line.style_solid))
    s.labels.push(label.new(lineEnd, y0236, "0.236", xloc=xloc.bar_time, textcolor=activeBlack, style=label.style_label_left, color=color.new(color.white, 100), size=size.small))
    
    s.lines.push(line.new(breakT, y0382, lineEnd, y0382, xloc=xloc.bar_time, color=dirColor, style=line.style_solid))
    s.labels.push(label.new(lineEnd, y0382, "0.382", xloc=xloc.bar_time, textcolor=dirColor, style=label.style_label_left, color=color.new(color.white, 100), size=size.small))
    
    s.lines.push(line.new(breakT, y0500, lineEnd, y0500, xloc=xloc.bar_time, color=activeBlack, style=line.style_dotted))
    s.labels.push(label.new(lineEnd, y0500, "ENTRY ZONE", xloc=xloc.bar_time, textcolor=activeBlack, style=label.style_label_left, color=color.new(color.white, 100), size=size.small))
    
    s.lines.push(line.new(breakT, y0618, lineEnd, y0618, xloc=xloc.bar_time, color=dirColor, style=line.style_solid))
    s.labels.push(label.new(lineEnd, y0618, "0.618", xloc=xloc.bar_time, textcolor=dirColor, style=label.style_label_left, color=color.new(color.white, 100), size=size.small))
    
    s.lines.push(line.new(breakT, y0764, lineEnd, y0764, xloc=xloc.bar_time, color=activeBlack, style=line.style_solid))
    s.labels.push(label.new(lineEnd, y0764, "0.764", xloc=xloc.bar_time, textcolor=activeBlack, style=label.style_label_left, color=color.new(color.white, 100), size=size.small))

    // Vertical line
    s.lines.push(line.new(lineEnd, y100_top, lineEnd, y100_bot, xloc=xloc.bar_time, color=activeBlack))
    s.labels.push(label.new(lineEnd, y100_top, "1", xloc=xloc.bar_time, textcolor=activeBlack, style=label.style_label_left, color=color.new(color.white, 100), size=size.small))
    s.labels.push(label.new(lineEnd, y100_bot, "1", xloc=xloc.bar_time, textcolor=activeBlack, style=label.style_label_left, color=color.new(color.white, 100), size=size.small))

    s.boxes.push(box.new(breakT, y0382, lineEnd, y0618, xloc=xloc.bar_time, bgcolor=color.new(dirColor, 85), border_color=na))
    
    float labelY = isBullish ? y100_bot : y100_top
    s.labels.push(label.new(breakT, labelY, labelTxt, xloc=xloc.bar_time, textcolor=dirColor, style=isBullish ? label.style_label_up : label.style_label_down, color=color.new(color.white, 100), size=size.small))

    array.push(targetArr, s)
    f_cleanup(targetArr)

//==================== BREAKS (CHoCH & BOS) ====================
brkUp = not na(upLvl) and not upBroken and (requireBody ? close > upLvl : high > upLvl)
brkDn = not na(dnLvl) and not dnBroken and (requireBody ? close < dnLvl : low < dnLvl)

if brkUp and trendBullish
    upBroken := true
    if os == -1 
        if useChoch
            f_createGann(chochSetups, high, dnLvl, dnT, time, true, "CHoCH")
    else if os == 1 
        if useBos
            f_createGann(bosSetups, high, dnLvl, dnT, time, true, "BOS")
    os := 1

if brkDn and trendBearish
    dnBroken := true
    if os == 1 
        if useChoch
            f_createGann(chochSetups, upLvl, low, upT, time, false, "CHoCH")
    else if os == -1 
        if useBos
            f_createGann(bosSetups, upLvl, low, upT, time, false, "BOS")
    os := -1

//==================== ALERT ENGINE ====================
string alertMsg = ""

f_checkAlert(SetupInfo[] setupsArr) =>
    string res = ""
    if array.size(setupsArr) > 0
        SetupInfo last = array.get(setupsArr, array.size(setupsArr) - 1)
        // Check if price is within the Entry Zone (0.382 - 0.618)
        if close <= last.zTop and close >= last.zBot
            res := "Price in " + (last.isBullish ? "Bullish " : "Bearish ") + last.labelTxt + " Entry Zone! | "
    res

if useChoch
    alertMsg += f_checkAlert(chochSetups)
if useBos
    alertMsg += f_checkAlert(bosSetups)

if alertMsg != ""
    alert(alertMsg, alert.freq_once_per_bar)

//==================== DYNAMIC TARGET DECORATION ====================
SetupInfo latest = na
int lastIdxChoch = array.size(chochSetups) - 1
int lastIdxBos   = array.size(bosSetups) - 1

if lastIdxChoch >= 0 and lastIdxBos >= 0
    SetupInfo c = array.get(chochSetups, lastIdxChoch)
    SetupInfo b = array.get(bosSetups, lastIdxBos)
    latest := c.lastUpdateBar > b.lastUpdateBar ? c : b
else if lastIdxChoch >= 0
    latest := array.get(chochSetups, lastIdxChoch)
else if lastIdxBos >= 0
    latest := array.get(bosSetups, lastIdxBos)

if not na(latest)
    if latest.isBullish and not na(upLab)
        label.set_text(upLab, "TARGET: Sell Positions StopLoss Level - " + str.tostring(upLvl, format.mintick))
        label.set_size(upLab, size.normal)
    else if not latest.isBullish and not na(dnLab)
        label.set_text(dnLab, "TARGET: Buy Positions Stop Loss level - " + str.tostring(dnLvl, format.mintick))
        label.set_size(dnLab, size.normal)

//==================== DYNAMIC SLIDING UPDATE ====================
f_updateLast(SetupInfo[] targetArr) =>
    if array.size(targetArr) > 0
        SetupInfo last = array.get(targetArr, array.size(targetArr) - 1)
        int newEnd = time + tfMs * gannBarsToRight
        for i = 0 to 4 
            line.set_x2(last.lines.get(i), newEnd)
        line.set_x1(last.lines.get(5), newEnd)
        line.set_x2(last.lines.get(5), newEnd)
        box.set_right(last.boxes.get(0), newEnd)
        for i = 0 to 6
            label.set_x(last.labels.get(i), newEnd)

if barstate.islast
    f_updateLast(chochSetups)
    f_updateLast(bosSetups)

//==================== WATERMARK ====================
var table watermarkTable = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(watermarkTable, 0, 0, "erdensedat", text_color=color.new(color.gray, 70), text_size=size.huge)
````
