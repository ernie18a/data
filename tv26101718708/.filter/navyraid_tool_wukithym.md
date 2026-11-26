# Navyraid Tool

- url: https://www.tradingview.com/script/wuKiTHYM-Navyraid-Tool/
- type: indicator
- pine_id: PUB;47d0697986ae4a5dbb73be80d9cbda20
- version: 1.0

## Description

[b]Navyraid Tool - ICT All-in-One Suite[/b]

The [b]Navyraid Tool[/b] is a comprehensive, all-in-one indicator designed for traders utilizing Inner Circle Trader (ICT). To prevent chart clutter from overlapping indicators, this tool intelligently consolidates time-based sessions, liquidity levels, price gaps, and SMT divergences into a single, lightweight suite.

[b]Key Features & How It Works:[/b]

[list]
[*][b]Smart Auto-DST Sessions:[/b] Visually highlights the Asia, London, and New York sessions. It features a built-in dynamic timezone engine that automatically shifts session start/end times based on the active Daylight Saving Time (DST / Non-DST) period. Users can simply toggle between "Forex & Gold Mode" or "Index Mode" to get the mathematically accurate session times without manual monthly adjustments.
[*][b]Liquidity Levels (PDH/PDL & PWH/PWL):[/b] Automatically maps out the Previous Daily High/Low and Previous Weekly High/Low. These lines serve as visual aids for identifying potential draw-on-liquidity targets or purge levels.
[*][b]True Price Gaps (NWOG & NDOG):[/b] Plots the New Week Opening Gap (NWOG) and New Day Opening Gap (NDOG). The indicator actively tracks price interaction; if a candle mitigates and closes outside the gap boundary, it dynamically changes color to represent an "Inverse Gap."
[*][b]Multi-Timeframe FVG (Fair Value Gaps):[/b] Simultaneously displays Higher Timeframe (HTF) and Lower Timeframe (LTF) FVGs on your current chart. Similar to the price gaps, these zones turn into Inverse FVGs (IFVG) upon full mitigation.
[*][b]Manual SMT Divergence Engine:[/b] A strictly manual, linear SMT tracking system. By inputting a correlated comparison symbol (e.g., SP500FT vs NAS100FT, or EURUSD vs GBPUSD), the script calculates and draws structural divergences across Weekly, Daily, and Sessional timeframes.
[/list]

[b]Why this script?[/b]

Most ICT indicators only focus on one concept. The Navyraid Tool integrates all crucial time-and-price theories into one organized dashboard while maintaining high performance through strict historical lookback limiters.

[i]Disclaimer: This indicator is designed solely for educational and structural analysis. It does not generate buy/sell signals. Always use proper risk management.[/i]

## Source Code

````pine
//@version=6
indicator("Navyraid Tool", overlay=true, max_lines_count=500, max_boxes_count=500, max_bars_back=5000, dynamic_requests=true)

// =========================================================
// 1. GLOBAL HISTORY SETTINGS
// =========================================================
lookbackDays = input.int(7, title="Global History", minval=1, group="Global History Settings")

// =========================================================
// 2. SESSION SETTINGS (BOXES & LINES)
// =========================================================
assetMode     = input.string("Forex & Gold Mode", title="Asset Mode", options=["Forex & Gold Mode", "Index Mode"], group="Session Settings (Boxes & Lines)")

showText      = input.bool(true, title="Session Name in Box", group="Session Settings (Boxes & Lines)")
showSessLines = input.bool(true, title="Session Lines (High/Low)", group="Session Settings (Boxes & Lines)")
showSessText  = input.bool(false, title="Session Line Text (High/Low)", group="Session Settings (Boxes & Lines)") 

boxColorHex   = color.rgb(184, 184, 184, 80) 

asiaBoxCol    = input.color(boxColorHex, title="Asia Box Color", group="Session Settings (Boxes & Lines)")
lonBoxCol     = input.color(boxColorHex, title="London Box Color", group="Session Settings (Boxes & Lines)")
nyBoxCol      = input.color(boxColorHex, title="New York Box Color", group="Session Settings (Boxes & Lines)")

asiaLineCol   = color.new(asiaBoxCol, 0)
lonLineCol    = color.new(lonBoxCol, 0)
nyLineCol     = color.new(nyBoxCol, 0)

lineStyle     = line.style_solid
lineWidthInp  = input.int(1, title="Session Line Width", minval=1, maxval=5, group="Session Settings (Boxes & Lines)")

// =========================================================
// 3. DAILY / WEEKLY SETTINGS (PDH, PDL, PWH, PWL)
// =========================================================
showPDHWL     = input.bool(true, title="PDH/PDL & PWH/PWL", group="Daily / Weekly Settings")

// =========================================================
// 4. GAP & FVG SETTINGS (NWOG, NDOG, HTF FVG, LTF FVG)
// =========================================================
showGaps        = input.bool(true, title="NWOG & NDOG", group="Gap & FVG Settings (NWOG, NDOG, FVG)")
showHtfFvg      = input.bool(true, title="HTF FVG", group="Gap & FVG Settings (NWOG, NDOG, FVG)")
htfRes          = input.timeframe("60", title="HTF FVG Timeframe", group="Gap & FVG Settings (NWOG, NDOG, FVG)")
htfHistHrs      = input.int(12, title="HTF FVG History", minval=1, group="Gap & FVG Settings (NWOG, NDOG, FVG)") 
showLtfFvg      = input.bool(true, title="LTF FVG (<= 5m)", group="Gap & FVG Settings (NWOG, NDOG, FVG)")
ltfHistHrs      = input.int(1, title="LTF FVG History", minval=1, group="Gap & FVG Settings (NWOG, NDOG, FVG)") 

gapCol          = input.color(color.new(color.purple, 80), title="NWOG & NDOG Color (Fresh)", group="Gap & FVG Settings (NWOG, NDOG, FVG)")
fvgCol          = input.color(color.new(color.blue, 80), title="FVG Color - HTF & LTF (Fresh)", group="Gap & FVG Settings (NWOG, NDOG, FVG)")

fvgTextColorStr = input.color(color.rgb(0, 0, 0), title="Gap & FVG Text Color", group="Gap & FVG Settings (NWOG, NDOG, FVG)")
fvgTextSizeStr  = input.string("Tiny", title="Gap & FVG Text Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group="Gap & FVG Settings (NWOG, NDOG, FVG)")

// =========================================================
// 5. SMT SETTINGS
// =========================================================
string g_smt           = "SMT SETTINGS"
bool i_smt_enable      = input.bool(true, "SMT", group=g_smt)
bool i_smt_enable_w    = input.bool(true, "Weekly SMT", group=g_smt)
bool i_smt_enable_d    = input.bool(true, "Daily SMT", group=g_smt)
bool i_smt_enable_sess = input.bool(true, "Sessional SMT", group=g_smt)
string smtSymbol       = input.symbol("SP500FT", "Comparison Symbol", group=g_smt)
bool i_show_info_box   = input.bool(true, "Info Box", group=g_smt)

color i_smt_color      = color.new(#f75260, 0)
int i_smt_line_width   = 1

// =========================================================
// WAKTU SESI OTOMATIS BERDASARKAN MODE ASET & DETEKSI DST (WIB)
// =========================================================
var string TZ_WIB = "GMT+7"
var string TZ_NY  = "America/New_York"
var string TZ_UTC = "GMT+0"

f_tz_offset_hour(string _tz) =>
    int localH = hour(time, _tz)
    int utcH   = hour(time, TZ_UTC)
    int raw    = localH - utcH
    raw > 12 ? raw - 24 : raw < -12 ? raw + 24 : raw

int ny_offset  = f_tz_offset_hour(TZ_NY)

// DETEKSI AKURAT: Maret - November (DST / Summer), November - Maret (Non-DST / Winter)
bool use_us_dst = ny_offset == -4
string dstStatusTxt = use_us_dst ? "[DST - Summer]" : "[Non-DST - Winter]"

// FIX AKURAT: Jam Sesi yang menyambung sempurna tanpa celah (Gap)
string asiaSession   = assetMode == "Index Mode" ? (use_us_dst ? "0800-1400" : "0800-1500") : (use_us_dst ? "0700-1400" : "0700-1500")
string londonSession = assetMode == "Index Mode" ? (use_us_dst ? "1400-2030" : "1500-2130") : (use_us_dst ? "1400-1900" : "1500-2000")
string nySession     = assetMode == "Index Mode" ? (use_us_dst ? "2030-0300" : "2130-0400") : (use_us_dst ? "1900-0400" : "2000-0500")

// =========================================================
// SYSTEM LOGIC (OPTIMIZED & PRESERVED 100%)
// =========================================================
var lastTime = time 
if time > lastTime
    lastTime := time

var int msPerDay = 86400000
var int msPerHour = 3600000

limitGlobalTime = lastTime - (lookbackDays * msPerDay)
isWithinHistory = time >= limitGlobalTime
limitHtfTime    = math.max(lastTime - (htfHistHrs * msPerHour), limitGlobalTime)
limitLtfTime    = math.max(lastTime - (ltfHistHrs * msPerHour), limitGlobalTime) 
smtHistoryMs    = lookbackDays * msPerDay

fvgTextSize = fvgTextSizeStr == "Tiny" ? size.tiny : fvgTextSizeStr == "Small" ? size.small : fvgTextSizeStr == "Normal" ? size.normal : fvgTextSizeStr == "Large" ? size.large : fvgTextSizeStr == "Huge" ? size.huge : size.auto
var tapCol      = color.new(color.gray, 80) 
var tapColGap   = color.new(color.gray, 80)
var ifvgCol     = color.new(color.red, 80)  

var activeLines = array.new_line()
var activeLabels = array.new_label()
var activeLineX1 = array.new_int()
var activeLabelTexts = array.new_string() 
var activeLineTimes = array.new_int()

var box[] sessBoxes = array.new_box()
var int[] sessBoxTimes = array.new_int()

var line[] mitigatedLines = array.new_line()
var label[] mitigatedLabels = array.new_label()
var int[] mitigatedTimes = array.new_int()

var int currentBoundary = bar_index

timeAsia = time(timeframe.period, asiaSession, "Asia/Jakarta")
timeLon  = time(timeframe.period, londonSession, "Asia/Jakarta")
timeNY   = time(timeframe.period, nySession, "Asia/Jakarta")

inAsia_g = not na(timeAsia)
inLon_g  = not na(timeLon)
inNY_g   = not na(timeNY)

if (inAsia_g and not inAsia_g[1]) or (not inAsia_g and inAsia_g[1]) or (inLon_g and not inLon_g[1]) or (not inLon_g and inLon_g[1]) or (inNY_g and not inNY_g[1]) or (not inNY_g and inNY_g[1])
    currentBoundary := bar_index

f_finalize_line(newLine, newLabel, x1, y, textStr, isHigh, cTime) =>
    bool found = false
    if cTime < limitGlobalTime
        line.delete(newLine)
        label.delete(newLabel)
    else
        int sz = array.size(activeLines)
        if sz > 0
            for i = 0 to sz - 1
                l = array.get(activeLines, i)
                if math.abs(line.get_y1(l) - y) <= syminfo.mintick
                    lbl = array.get(activeLabels, i)
                    oldTxt = array.get(activeLabelTexts, i)
                    if not str.contains(oldTxt, textStr)
                        newTxt = oldTxt + "/" + textStr
                        array.set(activeLabelTexts, i, newTxt)
                        label.set_text(lbl, newTxt + "            ")
                    line.delete(newLine)
                    label.delete(newLabel)
                    found := true
                    break
        if not found
            array.push(activeLines, newLine)
            array.push(activeLabels, newLabel)
            array.push(activeLineX1, x1)
            array.push(activeLabelTexts, textStr)
            array.push(activeLineTimes, cTime)

f_drawSession(inSession, boxCol, lineCol, lStyle, lWidth, showLine, sessionName) =>
    var float sHigh = na
    var float sLow = na
    var int highBar = na
    var int lowBar = na
    var int startBar = na
    var int startTime = na
    var box b = na
    var line lh = na
    var line ll = na
    var label lblH = na
    var label lblL = na
    
    sessionStart = inSession and not inSession[1]
    sessionEnd = not inSession and inSession[1]

    if sessionStart
        sHigh := high
        sLow := low
        highBar := bar_index
        lowBar := bar_index
        startBar := bar_index
        startTime := time
        
        textColor = color.new(lineCol, 90)
        boxText = showText ? sessionName : ""
        b := box.new(left=startBar, top=sHigh, right=bar_index, bottom=sLow, border_color=na, bgcolor=boxCol, text=boxText, text_color=textColor, text_size=size.auto, text_halign=text.align_center, text_valign=text.align_center)
        array.push(sessBoxes, b)
        array.push(sessBoxTimes, time)
        
        if showLine
            lh := line.new(x1=highBar, y1=sHigh, x2=bar_index + 10, y2=sHigh, color=lineCol, width=lWidth, style=lStyle, extend=extend.none)
            ll := line.new(x1=lowBar, y1=sLow, x2=bar_index + 10, y2=sLow, color=lineCol, width=lWidth, style=lStyle, extend=extend.none)
            
            lblH_text = showSessText ? (sessionName + " High            ") : ""
            lblL_text = showSessText ? (sessionName + " Low            ") : ""
            
            lblH := label.new(x=bar_index + 10, y=sHigh, text=lblH_text, color=color.new(color.white, 100), textcolor=color.black, style=label.style_label_down, size=size.small)
            lblL := label.new(x=bar_index + 10, y=sLow, text=lblL_text, color=color.new(color.white, 100), textcolor=color.black, style=label.style_label_up, size=size.small)

    if inSession
        if high > sHigh
            sHigh := high
            highBar := bar_index
        if low < sLow
            sLow := low
            lowBar := bar_index
            
        if not na(b)
            box.set_top(b, sHigh)
            box.set_bottom(b, sLow)
            box.set_right(b, bar_index)
            
            if showLine and not na(lh)
                line.set_xy1(lh, highBar, sHigh)
                line.set_xy2(lh, bar_index + 10, sHigh)
                label.set_xy(lblH, bar_index + 10, sHigh)
                
                line.set_xy1(ll, lowBar, sLow)
                line.set_xy2(ll, bar_index + 10, sLow)
                label.set_xy(lblL, bar_index + 10, sLow)

    if sessionEnd
        if showLine and not na(lh)
            lblH_finalText = showSessText ? (sessionName + " High") : ""
            lblL_finalText = showSessText ? (sessionName + " Low") : ""
            f_finalize_line(lh, lblH, highBar, sHigh, lblH_finalText, true, startTime)
            f_finalize_line(ll, lblL, lowBar, sLow, lblL_finalText, false, startTime)
        b := na
        lh := na
        ll := na
        lblH := na
        lblL := na

f_drawSession(inAsia_g, asiaBoxCol, asiaLineCol, lineStyle, lineWidthInp, showSessLines, "Asia")
f_drawSession(inLon_g, lonBoxCol, lonLineCol, lineStyle, lineWidthInp, showSessLines, "London")
f_drawSession(inNY_g, nyBoxCol, nyLineCol, lineStyle, lineWidthInp, showSessLines, "NY")


// ---------------------------------------------------------
// TRACKING DAILY (PDH / PDL)
// ---------------------------------------------------------
var float d_high = na
var float d_low = na
var int d_highBar = na
var int d_lowBar = na
var int d_startTime = na

isNewDay_PD = time("D") != time("D")[1]
if isNewDay_PD
    if not na(d_high) and showPDHWL
        l_pdh = line.new(x1=d_highBar, y1=d_high, x2=bar_index + 10, y2=d_high, color=color.rgb(46, 46, 46), width=lineWidthInp, style=lineStyle, extend=extend.none)
        lbl_pdh = label.new(x=bar_index + 10, y=d_high, text="PDH            ", color=color.new(color.white, 100), textcolor=color.black, style=label.style_label_down, size=size.small)
        f_finalize_line(l_pdh, lbl_pdh, d_highBar, d_high, "PDH", true, d_startTime)
        
        l_pdl = line.new(x1=d_lowBar, y1=d_low, x2=bar_index + 10, y2=d_low, color=color.rgb(46, 46, 46), width=lineWidthInp, style=lineStyle, extend=extend.none)
        lbl_pdl = label.new(x=bar_index + 10, y=d_low, text="PDL            ", color=color.new(color.white, 100), textcolor=color.black, style=label.style_label_up, size=size.small)
        f_finalize_line(l_pdl, lbl_pdl, d_lowBar, d_low, "PDL", false, d_startTime)
        
    d_high := high
    d_low := low
    d_highBar := bar_index
    d_lowBar := bar_index
    d_startTime := time
else
    if na(d_high) or high > d_high
        d_high := high
        d_highBar := bar_index
    if na(d_low) or low < d_low
        d_low := low
        d_lowBar := bar_index


// ---------------------------------------------------------
// TRACKING WEEKLY (PWH / PWL)
// ---------------------------------------------------------
var float w_high = na
var float w_low = na
var int w_highBar = na
var int w_lowBar = na
var int w_startTime = na

isNewWeek_PW = time("W") != time("W")[1]
if isNewWeek_PW
    if not na(w_high) and showPDHWL
        l_pwh = line.new(x1=w_highBar, y1=w_high, x2=bar_index + 10, y2=w_high, color=color.rgb(46, 46, 46), width=lineWidthInp, style=lineStyle, extend=extend.none)
        lbl_pwh = label.new(x=bar_index + 10, y=w_high, text="PWH            ", color=color.new(color.white, 100), textcolor=color.black, style=label.style_label_down, size=size.small)
        f_finalize_line(l_pwh, lbl_pwh, w_highBar, w_high, "PWH", true, w_startTime)
        
        l_pwl = line.new(x1=w_lowBar, y1=w_low, x2=bar_index + 10, y2=w_low, color=color.rgb(46, 46, 46), width=lineWidthInp, style=lineStyle, extend=extend.none)
        lbl_pwl = label.new(x=bar_index + 10, y=w_low, text="PWL            ", color=color.new(color.white, 100), textcolor=color.black, style=label.style_label_up, size=size.small)
        f_finalize_line(l_pwl, lbl_pwl, w_lowBar, w_low, "PWL", false, w_startTime)
        
    w_high := high
    w_low := low
    w_highBar := bar_index
    w_lowBar := bar_index
    w_startTime := time
else
    if na(w_high) or high > w_high
        w_high := high
        w_highBar := bar_index
    if na(w_low) or low < w_low
        w_low := low
        w_lowBar := bar_index


// ---------------------------------------------------------
// LOGIKA MITIGASI & PEMBERSIHAN GARIS AKTIF
// ---------------------------------------------------------
if array.size(activeLines) > 0
    for i = array.size(activeLines) - 1 to 0
        l = array.get(activeLines, i)
        lbl = array.get(activeLabels, i)
        x1 = array.get(activeLineX1, i)
        lblTxt = array.get(activeLabelTexts, i)
        cTime = array.get(activeLineTimes, i)
        
        if cTime < limitGlobalTime
            line.delete(l)
            label.delete(lbl)
            array.remove(activeLines, i)
            array.remove(activeLabels, i)
            array.remove(activeLineX1, i)
            array.remove(activeLabelTexts, i)
            array.remove(activeLineTimes, i)
            continue
            
        lvl = line.get_y1(l)
        
        if high >= lvl and low <= lvl
            line.set_extend(l, extend.none)
            line.set_x2(l, currentBoundary)
            line.set_style(l, line.style_dotted) 
            
            centerX = int((x1 + currentBoundary) / 2)
            label.set_x(lbl, centerX)
            label.set_text(lbl, lblTxt) 
            
            array.push(mitigatedLines, l)
            array.push(mitigatedLabels, lbl)
            array.push(mitigatedTimes, cTime)
            
            array.remove(activeLines, i)
            array.remove(activeLabels, i)
            array.remove(activeLineX1, i)
            array.remove(activeLabelTexts, i)
            array.remove(activeLineTimes, i)
        else
            line.set_x2(l, bar_index + 10)
            label.set_x(lbl, bar_index + 10)


// ---------------------------------------------------------
// PENGATURAN NWOG & NDOG (TRUE PRICE GAP + INVERSE)
// ---------------------------------------------------------
isNewDayBar = ta.change(time("D")) != 0
isMondayBar = isNewDayBar and dayofweek == dayofweek.monday
isOtherDayBar = isNewDayBar and not isMondayBar

var box[] gapBoxes = array.new_box()
var float[] gapTop = array.new_float()
var float[] gapBot = array.new_float()
var int[] gapDir   = array.new_int()
var int[] gapCreationTime = array.new_int() 
var int[] gapCreationBar  = array.new_int()
var string[] gapLbl = array.new_string()

var box[] invGapBoxes = array.new_box()
var int[] invGapCreationTime = array.new_int()

if showGaps and time >= limitGlobalTime
    if isMondayBar
        if open > close[1]
            bx = box.new(left=bar_index[1], top=open, right=bar_index+10, bottom=close[1], border_color=na, bgcolor=gapCol, text="NWOG      ", text_color=fvgTextColorStr, text_size=fvgTextSize, text_halign=text.align_right, text_valign=text.align_center)
            array.push(gapBoxes, bx)
            array.push(gapTop, open)
            array.push(gapBot, close[1])
            array.push(gapDir, 1)
            array.push(gapCreationTime, time)
            array.push(gapCreationBar, bar_index)
            array.push(gapLbl, "INV-NWOG")
        else if open < close[1]
            bx = box.new(left=bar_index[1], top=close[1], right=bar_index+10, bottom=open, border_color=na, bgcolor=gapCol, text="NWOG      ", text_color=fvgTextColorStr, text_size=fvgTextSize, text_halign=text.align_right, text_valign=text.align_center)
            array.push(gapBoxes, bx)
            array.push(gapTop, close[1])
            array.push(gapBot, open)
            array.push(gapDir, -1)
            array.push(gapCreationTime, time)
            array.push(gapCreationBar, bar_index)
            array.push(gapLbl, "INV-NWOG")
            
    if isOtherDayBar
        if open > close[1]
            bx = box.new(left=bar_index[1], top=open, right=bar_index+10, bottom=close[1], border_color=na, bgcolor=gapCol, text="NDOG      ", text_color=fvgTextColorStr, text_size=fvgTextSize, text_halign=text.align_right, text_valign=text.align_center)
            array.push(gapBoxes, bx)
            array.push(gapTop, open)
            array.push(gapBot, close[1])
            array.push(gapDir, 1)
            array.push(gapCreationTime, time)
            array.push(gapCreationBar, bar_index)
            array.push(gapLbl, "INV-NDOG")
        else if open < close[1]
            bx = box.new(left=bar_index[1], top=close[1], right=bar_index+10, bottom=open, border_color=na, bgcolor=gapCol, text="NDOG      ", text_color=fvgTextColorStr, text_size=fvgTextSize, text_halign=text.align_right, text_valign=text.align_center)
            array.push(gapBoxes, bx)
            array.push(gapTop, close[1])
            array.push(gapBot, open)
            array.push(gapDir, -1)
            array.push(gapCreationTime, time)
            array.push(gapCreationBar, bar_index)
            array.push(gapLbl, "INV-NDOG")

if array.size(gapBoxes) > 0
    for i = array.size(gapBoxes) - 1 to 0
        bx = array.get(gapBoxes, i)
        t  = array.get(gapTop, i)
        b  = array.get(gapBot, i)
        dir = array.get(gapDir, i)
        cTime = array.get(gapCreationTime, i)
        cBar  = array.get(gapCreationBar, i)
        lblTxt = array.get(gapLbl, i)
        
        if cTime < limitGlobalTime
            box.delete(bx)
            array.remove(gapBoxes, i)
            array.remove(gapTop, i)
            array.remove(gapBot, i)
            array.remove(gapDir, i)
            array.remove(gapCreationTime, i)
            array.remove(gapCreationBar, i)
            array.remove(gapLbl, i)
            continue
            
        box.set_right(bx, bar_index + 10)
        
        if bar_index > cBar
            isInv = false
            if (dir == 1 and close < b) or (dir == -1 and close > t)
                isInv := true
                box.set_bgcolor(bx, color.new(color.purple, 80)) 
                box.set_right(bx, bar_index) 
                box.set_text(bx, lblTxt)
                box.set_text_halign(bx, text.align_center)
                
                array.push(invGapBoxes, bx)
                array.push(invGapCreationTime, cTime)
                
                array.remove(gapBoxes, i)
                array.remove(gapTop, i)
                array.remove(gapBot, i)
                array.remove(gapDir, i)
                array.remove(gapCreationTime, i)
                array.remove(gapCreationBar, i)
                array.remove(gapLbl, i)
                
            if not isInv
                if low <= t and high >= b
                    box.set_bgcolor(bx, tapColGap)

if array.size(invGapBoxes) > 0
    for i = array.size(invGapBoxes) - 1 to 0
        bx = array.get(invGapBoxes, i)
        cTime = array.get(invGapCreationTime, i)
        if cTime < limitGlobalTime
            box.delete(bx)
            array.remove(invGapBoxes, i)
            array.remove(invGapCreationTime, i)


// ---------------------------------------------------------
// PENGATURAN FAIR VALUE GAP
// ---------------------------------------------------------
f_format_tf_text(tf) =>
    tf == "60" ? "1H" : tf == "240" ? "4H" : (tf == "D" or tf == "1D") ? "1D" : tf == "15" ? "15m" : tf + "m"

htfFvgLabel = f_format_tf_text(htfRes) + " FVG      " 
ltfFvgLabel = timeframe.period + "m FVG      "
htfIfvgLabel = f_format_tf_text(htfRes) + " IFVG"
ltfIfvgLabel = timeframe.period + "m IFVG"

var box[] htfBoxes = array.new_box()
var float[] htfTop = array.new_float()
var float[] htfBot = array.new_float()
var int[] htfDir = array.new_int()
var int[] htfCreationTime = array.new_int() 
var int[] htfCreationBar = array.new_int() 

var box[] ltfBoxes = array.new_box()
var float[] ltfTop = array.new_float()
var float[] ltfBot = array.new_float()
var int[] ltfDir = array.new_int()
var int[] ltfCreationTime = array.new_int() 
var int[] ltfCreationBar = array.new_int() 

var box[] htfIfvgBoxes = array.new_box()
var int[] htfIfvgCreationTime = array.new_int()

var box[] ltfIfvgBoxes = array.new_box()
var int[] ltfIfvgCreationTime = array.new_int()

f_get_htf_fvg() =>
    isBull = low > high[2] and close[1] > high[2]
    isBear = high < low[2] and close[1] < low[2]
    [isBull, isBear, high[2], low[2], high, low, time[1], time]

[htfBull, htfBear, htfH2, htfL2, htfH0, htfL0, htfT1, htfT0] = request.security(syminfo.tickerid, htfRes, f_get_htf_fvg(), lookahead=barmerge.lookahead_on)

if showHtfFvg
    if time >= limitHtfTime
        if htfBull and htfT0 != nz(htfT0[1])
            b = box.new(left=htfT1, top=htfL0, right=time, bottom=htfH2, xloc=xloc.bar_time, border_color=na, bgcolor=fvgCol, text=htfFvgLabel, text_color=fvgTextColorStr, text_size=fvgTextSize, text_halign=text.align_right, text_valign=text.align_center)
            array.push(htfBoxes, b)
            array.push(htfTop, htfL0)
            array.push(htfBot, htfH2)
            array.push(htfDir, 1) 
            array.push(htfCreationTime, time)
            array.push(htfCreationBar, bar_index) 
            
        if htfBear and htfT0 != nz(htfT0[1])
            b = box.new(left=htfT1, top=htfL2, right=time, bottom=htfH0, xloc=xloc.bar_time, border_color=na, bgcolor=fvgCol, text=htfFvgLabel, text_color=fvgTextColorStr, text_size=fvgTextSize, text_halign=text.align_right, text_valign=text.align_center)
            array.push(htfBoxes, b)
            array.push(htfTop, htfL2)
            array.push(htfBot, htfH0)
            array.push(htfDir, -1) 
            array.push(htfCreationTime, time)
            array.push(htfCreationBar, bar_index) 

if array.size(htfBoxes) > 0
    timeStep = time - nz(time[1])
    for i = array.size(htfBoxes) - 1 to 0
        b = array.get(htfBoxes, i)
        t = array.get(htfTop, i)
        bot = array.get(htfBot, i)
        dir = array.get(htfDir, i)
        cTime = array.get(htfCreationTime, i)
        cBar = array.get(htfCreationBar, i)
        
        if cTime < limitHtfTime
            box.delete(b)
            array.remove(htfBoxes, i)
            array.remove(htfTop, i)
            array.remove(htfBot, i)
            array.remove(htfDir, i)
            array.remove(htfCreationTime, i)
            array.remove(htfCreationBar, i)
            continue
            
        box.set_right(b, time + (timeStep * 10))
        
        if bar_index > cBar
            isIfvg = false
            if (dir == 1 and close < bot) or (dir == -1 and close > t)
                isIfvg := true
                box.set_bgcolor(b, ifvgCol) 
                box.set_right(b, time) 
                box.set_text(b, htfIfvgLabel)
                box.set_text_halign(b, text.align_center)
                
                array.push(htfIfvgBoxes, b)
                array.push(htfIfvgCreationTime, cTime)
                
                array.remove(htfBoxes, i)
                array.remove(htfTop, i)
                array.remove(htfBot, i)
                array.remove(htfDir, i)
                array.remove(htfCreationTime, i)
                array.remove(htfCreationBar, i)
                
            if not isIfvg
                if low <= t and high >= bot
                    box.set_bgcolor(b, tapCol)

if array.size(htfIfvgBoxes) > 0
    for i = array.size(htfIfvgBoxes) - 1 to 0
        b = array.get(htfIfvgBoxes, i)
        cTime = array.get(htfIfvgCreationTime, i)
        if cTime < limitHtfTime
            box.delete(b)
            array.remove(htfIfvgBoxes, i)
            array.remove(htfIfvgCreationTime, i)


tf_in_minutes = timeframe.multiplier
if showLtfFvg and timeframe.isintraday and tf_in_minutes <= 5
    bullFvgLtf = low > high[2] and close[1] > high[2]
    bearFvgLtf = high < low[2] and close[1] < low[2]
    
    if time >= limitLtfTime
        if bullFvgLtf
            b = box.new(left=bar_index[1], top=low, right=bar_index+10, bottom=high[2], border_color=na, bgcolor=fvgCol, text=ltfFvgLabel, text_color=fvgTextColorStr, text_size=fvgTextSize, text_halign=text.align_right, text_valign=text.align_center)
            array.push(ltfBoxes, b)
            array.push(ltfTop, low)
            array.push(ltfBot, high[2])
            array.push(ltfDir, 1)
            array.push(ltfCreationTime, time)
            array.push(ltfCreationBar, bar_index)
            
        if bearFvgLtf
            b = box.new(left=bar_index[1], top=low[2], right=bar_index+10, bottom=high, border_color=na, bgcolor=fvgCol, text=ltfFvgLabel, text_color=fvgTextColorStr, text_size=fvgTextSize, text_halign=text.align_right, text_valign=text.align_center)
            array.push(ltfBoxes, b)
            array.push(ltfTop, low[2])
            array.push(ltfBot, high)
            array.push(ltfDir, -1)
            array.push(ltfCreationTime, time)
            array.push(ltfCreationBar, bar_index)

    if array.size(ltfBoxes) > 0
        for i = array.size(ltfBoxes) - 1 to 0
            b = array.get(ltfBoxes, i)
            t = array.get(ltfTop, i)
            bot = array.get(ltfBot, i)
            dir = array.get(ltfDir, i)
            cTime = array.get(ltfCreationTime, i)
            cBar = array.get(ltfCreationBar, i)
            
            if cTime < limitLtfTime
                box.delete(b)
                array.remove(ltfBoxes, i)
                array.remove(ltfTop, i)
                array.remove(ltfBot, i)
                array.remove(ltfDir, i)
                array.remove(ltfCreationTime, i)
                array.remove(ltfCreationBar, i)
                continue
                
            box.set_right(b, bar_index + 10) 
            
            if bar_index > cBar
                isIfvgLtf = false
                if (dir == 1 and close < bot) or (dir == -1 and close > t)
                    isIfvgLtf := true
                    box.set_bgcolor(b, ifvgCol) 
                    box.set_right(b, bar_index) 
                    box.set_text(b, ltfIfvgLabel)
                    box.set_text_halign(b, text.align_center)
                    
                    array.push(ltfIfvgBoxes, b)
                    array.push(ltfIfvgCreationTime, cTime)

                    array.remove(ltfBoxes, i)
                    array.remove(ltfTop, i)
                    array.remove(ltfBot, i)
                    array.remove(ltfDir, i)
                    array.remove(ltfCreationTime, i)
                    array.remove(ltfCreationBar, i)
                    
                if not isIfvgLtf
                    if low <= t and high >= bot
                        box.set_bgcolor(b, tapCol)

    if array.size(ltfIfvgBoxes) > 0
        for i = array.size(ltfIfvgBoxes) - 1 to 0
            b = array.get(ltfIfvgBoxes, i)
            cTime = array.get(ltfIfvgCreationTime, i)
            if cTime < limitLtfTime
                box.delete(b)
                array.remove(ltfIfvgBoxes, i)
                array.remove(ltfIfvgCreationTime, i)


// =============================================================================
// 5. ENGINE SMT (WEEKLY, DAILY, SESSIONAL - MANUAL ONLY)
// =============================================================================
f_symbol_broker(string _symbol) =>
    int p = str.pos(_symbol, ":")
    not na(p) and p >= 0 ? str.substring(_symbol, 0, p) : syminfo.prefix

f_symbol_asset(string _symbol) =>
    int p = str.pos(_symbol, ":")
    not na(p) and p >= 0 ? str.substring(_symbol, p + 1, str.length(_symbol)) : _symbol

string smtInfoAsset  = f_symbol_asset(smtSymbol)
string smtInfoBroker = f_symbol_broker(smtSymbol)

var table smtInfoTable = table.new(position.bottom_right, 1, 1, border_width=1)

if barstate.islast
    if i_show_info_box
        table.cell(smtInfoTable, 0, 0, "SMT: " + smtInfoAsset + "\nBroker: " + smtInfoBroker + "\n" + dstStatusTxt, text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    else
        table.cell(smtInfoTable, 0, 0, "", text_color=color.white, bgcolor=color.new(color.black, 100), text_size=size.tiny)

float h_ext = request.security(smtSymbol, timeframe.period, high, lookahead=barmerge.lookahead_off)
float l_ext = request.security(smtSymbol, timeframe.period, low, lookahead=barmerge.lookahead_off)

type SMTLine
    line line_id
    int created_time

var smtLineArray = array.new<SMTLine>()

f_is_smt(bool b1, bool b2) =>
    b1 != b2

f_is_brk_H(float curr_h, float ref_h) =>
    not na(curr_h) and not na(ref_h) ? curr_h > ref_h : false

f_is_brk_L(float curr_l, float ref_l) =>
    not na(curr_l) and not na(ref_l) ? curr_l < ref_l : false

f_draw_rt(line _ln, bool _active, int _x1, float _y1, int _x2, float _y2, color _col) =>
    line out = _ln
    if _active
        if na(out)
            out := line.new(x1=_x1, y1=_y1, x2=_x2, y2=_y2, xloc=xloc.bar_time, color=_col, width=i_smt_line_width)
        else
            line.set_xy1(out, _x1, _y1)
            line.set_xy2(out, _x2, _y2)
        line.set_color(out, _col)
        line.set_width(out, i_smt_line_width)
    else
        if not na(out)
            line.delete(out)
        out := na
    out

f_store_smt_line(line _ln) =>
    if not na(_ln)
        array.push(smtLineArray, SMTLine.new(_ln, time))

f_cleanup_smt_lines() =>
    int sz = array.size(smtLineArray)
    if sz > 0
        for i = sz - 1 to 0
            SMTLine smt = array.get(smtLineArray, i)
            if time - smt.created_time > smtHistoryMs
                line.delete(smt.line_id)
                array.remove(smtLineArray, i)
    if array.size(smtLineArray) > 450
        SMTLine old = array.shift(smtLineArray)
        line.delete(old.line_id)

var int smt_session_start_hour = use_us_dst ? 5 : 6
int smt_session_start_minutes = smt_session_start_hour * 60
int smt_hour = hour(time, TZ_WIB)
int smt_minute = minute(time, TZ_WIB)
int smt_real_total_minutes = smt_hour * 60 + smt_minute
int smt_total_minutes_today = smt_real_total_minutes >= smt_session_start_minutes ? smt_real_total_minutes - smt_session_start_minutes : 1440 - smt_session_start_minutes + smt_real_total_minutes

f_get_cycle_info(int _total_minutes, int _divisor) =>
    int cycleIndex = int(math.floor(_total_minutes / _divisor))
    bool isNewDayCycle = _total_minutes < nz(_total_minutes[1], 1440)
    bool isChange = ta.change(cycleIndex) != 0 or isNewDayCycle
    [cycleIndex, isChange]

[cycle_4h_index, isNew_4h_raw] = f_get_cycle_info(smt_total_minutes_today, 240)
bool isNew_weekly_smt = timeframe.isweekly or timeframe.ismonthly ? true : ta.change(time("W")) != 0
bool isNew_daily_smt  = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly ? true : isNew_4h_raw and cycle_4h_index == 0

bool in_asia = inAsia_g
bool in_lon  = inLon_g
bool in_ny   = inNY_g

var float h_asia = na
var float l_asia = na
var int t_h_asia = na
var int t_l_asia = na

if in_asia and not in_asia[1]
    h_asia := high
    l_asia := low
    t_h_asia := time
    t_l_asia := time

if in_asia
    if na(h_asia) or high >= h_asia
        h_asia := high
        t_h_asia := time
    if na(l_asia) or low <= l_asia
        l_asia := low
        t_l_asia := time

var float h_lon = na
var float l_lon = na
var int t_h_lon = na
var int t_l_lon = na

if in_lon and not in_lon[1]
    h_lon := high
    l_lon := low
    t_h_lon := time
    t_l_lon := time

if in_lon
    if na(h_lon) or high >= h_lon
        h_lon := high
        t_h_lon := time
    if na(l_lon) or low <= l_lon
        l_lon := low
        t_l_lon := time

var float e1_h_asia = na
var float e1_l_asia = na

if in_asia and not in_asia[1]
    e1_h_asia := h_ext
    e1_l_asia := l_ext

if in_asia
    if na(e1_h_asia) or not na(h_ext) and h_ext >= e1_h_asia
        e1_h_asia := h_ext
    if na(e1_l_asia) or not na(l_ext) and l_ext <= e1_l_asia
        e1_l_asia := l_ext

var float e1_h_lon = na
var float e1_l_lon = na

if in_lon and not in_lon[1]
    e1_h_lon := h_ext
    e1_l_lon := l_ext

if in_lon
    if na(e1_h_lon) or not na(h_ext) and h_ext >= e1_h_lon
        e1_h_lon := h_ext
    if na(e1_l_lon) or not na(l_ext) and l_ext <= e1_l_lon
        e1_l_lon := l_ext

var float run_h_w = high
var float run_l_w = low
var int run_h_time_w = time
var int run_l_time_w = time
var float run_ext_h_w = h_ext
var float run_ext_l_w = l_ext

var float prev_h_w = na
var int prev_h_time_w = na
var float prev_l_w = na
var int prev_l_time_w = na
var float prev_ext_h_w = na
var float prev_ext_l_w = na

var line rt_line_w_bull = na
var line rt_line_w_bear = na

var float run_h_d = high
var float run_l_d = low
var int run_h_time_d = time
var int run_l_time_d = time
var float run_ext_h_d = h_ext
var float run_ext_l_d = l_ext

var float prev_h_d = na
var int prev_h_time_d = na
var float prev_l_d = na
var int prev_l_time_d = na
var float prev_ext_h_d = na
var float prev_ext_l_d = na

var line rt_line_d_bull = na
var line rt_line_d_bear = na

var float smt_ny_h = na
var float smt_ny_l = na
var int smt_t_ny_h = na
var int smt_t_ny_l = na

var float e1_ny_h = na
var float e1_ny_l = na

var line rt_line_lon_ny_bull = na
var line rt_line_lon_ny_bear = na
var line rt_line_as_ny_bull = na
var line rt_line_as_ny_bear = na

if i_smt_enable and time >= limitGlobalTime
    if i_smt_enable_w
        if isNew_weekly_smt
            f_store_smt_line(rt_line_w_bull)
            f_store_smt_line(rt_line_w_bear)
            rt_line_w_bull := na
            rt_line_w_bear := na

            prev_h_w := run_h_w
            prev_h_time_w := run_h_time_w
            prev_l_w := run_l_w
            prev_l_time_w := run_l_time_w
            prev_ext_h_w := run_ext_h_w
            prev_ext_l_w := run_ext_l_w

            run_h_w := high
            run_l_w := low
            run_h_time_w := time
            run_l_time_w := time
            run_ext_h_w := h_ext
            run_ext_l_w := l_ext
        else
            if na(run_h_w) or high >= run_h_w
                run_h_w := high
                run_h_time_w := time
            if na(run_l_w) or low <= run_l_w
                run_l_w := low
                run_l_time_w := time
            if not na(h_ext) and (na(run_ext_h_w) or h_ext >= run_ext_h_w)
                run_ext_h_w := h_ext
            if not na(l_ext) and (na(run_ext_l_w) or l_ext <= run_ext_l_w)
                run_ext_l_w := l_ext

        if not na(prev_l_w)
            bool mainBrkL_w = f_is_brk_L(run_l_w, prev_l_w)
            bool extBrkL_w = f_is_brk_L(run_ext_l_w, prev_ext_l_w)
            bool smtL_w = f_is_smt(mainBrkL_w, extBrkL_w)
            rt_line_w_bull := f_draw_rt(rt_line_w_bull, smtL_w, prev_l_time_w, prev_l_w, run_l_time_w, run_l_w, i_smt_color)

            bool mainBrkH_w = f_is_brk_H(run_h_w, prev_h_w)
            bool extBrkH_w = f_is_brk_H(run_ext_h_w, prev_ext_h_w)
            bool smtH_w = f_is_smt(mainBrkH_w, extBrkH_w)
            rt_line_w_bear := f_draw_rt(rt_line_w_bear, smtH_w, prev_h_time_w, prev_h_w, run_h_time_w, run_h_w, i_smt_color)

    if i_smt_enable_d
        if isNew_daily_smt
            f_store_smt_line(rt_line_d_bull)
            f_store_smt_line(rt_line_d_bear)
            rt_line_d_bull := na
            rt_line_d_bear := na

            prev_h_d := run_h_d
            prev_h_time_d := run_h_time_d
            prev_l_d := run_l_d
            prev_l_time_d := run_l_time_d
            prev_ext_h_d := run_ext_h_d
            prev_ext_l_d := run_ext_l_d

            run_h_d := high
            run_l_d := low
            run_h_time_d := time
            run_l_time_d := time
            run_ext_h_d := h_ext
            run_ext_l_d := l_ext
        else
            if na(run_h_d) or high >= run_h_d
                run_h_d := high
                run_h_time_d := time
            if na(run_l_d) or low <= run_l_d
                run_l_d := low
                run_l_time_d := time
            if not na(h_ext) and (na(run_ext_h_d) or h_ext >= run_ext_h_d)
                run_ext_h_d := h_ext
            if not na(l_ext) and (na(run_ext_l_d) or l_ext <= run_ext_l_d)
                run_ext_l_d := l_ext

        if not na(prev_l_d)
            bool mainBrkL_d = f_is_brk_L(run_l_d, prev_l_d)
            bool extBrkL_d = f_is_brk_L(run_ext_l_d, prev_ext_l_d)
            bool smtL_d = f_is_smt(mainBrkL_d, extBrkL_d)
            rt_line_d_bull := f_draw_rt(rt_line_d_bull, smtL_d, prev_l_time_d, prev_l_d, run_l_time_d, run_l_d, i_smt_color)

            bool mainBrkH_d = f_is_brk_H(run_h_d, prev_h_d)
            bool extBrkH_d = f_is_brk_H(run_ext_h_d, prev_ext_h_d)
            bool smtH_d = f_is_smt(mainBrkH_d, extBrkH_d)
            rt_line_d_bear := f_draw_rt(rt_line_d_bear, smtH_d, prev_h_time_d, prev_h_d, run_h_time_d, run_h_d, i_smt_color)

    if in_ny and not in_ny[1]
        smt_ny_h := high
        smt_ny_l := low
        smt_t_ny_h := time
        smt_t_ny_l := time
        e1_ny_h := h_ext
        e1_ny_l := l_ext

    if in_ny
        if na(smt_ny_h) or high >= smt_ny_h
            smt_ny_h := high
            smt_t_ny_h := time
        if na(smt_ny_l) or low <= smt_ny_l
            smt_ny_l := low
            smt_t_ny_l := time
        if na(e1_ny_h) or not na(h_ext) and h_ext >= e1_ny_h
            e1_ny_h := h_ext
        if na(e1_ny_l) or not na(l_ext) and l_ext <= e1_ny_l
            e1_ny_l := l_ext

    if i_smt_enable_sess
        if in_ny and not na(h_lon) and not na(l_lon)
            bool validLonH = time - t_h_lon <= 86400000
            bool validLonL = time - t_l_lon <= 86400000
            if validLonH
                bool mainBrkH_lon = f_is_brk_H(smt_ny_h, h_lon)
                bool extBrkH_lon = f_is_brk_H(e1_ny_h, e1_h_lon)
                bool smtH_lon = f_is_smt(mainBrkH_lon, extBrkH_lon)
                rt_line_lon_ny_bear := f_draw_rt(rt_line_lon_ny_bear, smtH_lon, t_h_lon, h_lon, smt_t_ny_h, smt_ny_h, i_smt_color)

            if validLonL
                bool mainBrkL_lon = f_is_brk_L(smt_ny_l, l_lon)
                bool extBrkL_lon = f_is_brk_L(e1_ny_l, e1_l_lon)
                bool smtL_lon = f_is_smt(mainBrkL_lon, extBrkL_lon)
                rt_line_lon_ny_bull := f_draw_rt(rt_line_lon_ny_bull, smtL_lon, t_l_lon, l_lon, smt_t_ny_l, smt_ny_l, i_smt_color)

        if in_ny and not na(h_asia) and not na(l_asia)
            bool validAsiaH = time - t_h_asia <= 86400000
            bool validAsiaL = time - t_l_asia <= 86400000
            if validAsiaH
                bool mainBrkH_asia = f_is_brk_H(smt_ny_h, h_asia)
                bool extBrkH_asia = f_is_brk_H(e1_ny_h, e1_h_asia)
                bool smtH_asia = f_is_smt(mainBrkH_asia, extBrkH_asia)
                rt_line_as_ny_bear := f_draw_rt(rt_line_as_ny_bear, smtH_asia, t_h_asia, h_asia, smt_t_ny_h, smt_ny_h, i_smt_color)

            if validAsiaL
                bool mainBrkL_asia = f_is_brk_L(smt_ny_l, l_asia)
                bool extBrkL_asia = f_is_brk_L(e1_ny_l, e1_l_asia)
                bool smtL_asia = f_is_smt(mainBrkL_asia, extBrkL_asia)
                rt_line_as_ny_bull := f_draw_rt(rt_line_as_ny_bull, smtL_asia, t_l_asia, l_asia, smt_t_ny_l, smt_ny_l, i_smt_color)

        if not in_ny and in_ny[1]
            f_store_smt_line(rt_line_lon_ny_bull)
            f_store_smt_line(rt_line_lon_ny_bear)
            f_store_smt_line(rt_line_as_ny_bull)
            f_store_smt_line(rt_line_as_ny_bear)
            rt_line_lon_ny_bull := na
            rt_line_lon_ny_bear := na
            rt_line_as_ny_bull := na
            rt_line_as_ny_bear := na


// ---------------------------------------------------------
// PEMBERSIH MUTLAK HISTORY GLOBAL
// ---------------------------------------------------------
if array.size(sessBoxes) > 0
    for i = array.size(sessBoxes) - 1 to 0
        bx = array.get(sessBoxes, i)
        cTime = array.get(sessBoxTimes, i)
        if cTime < limitGlobalTime
            box.delete(bx)
            array.remove(sessBoxes, i)
            array.remove(sessBoxTimes, i)

if array.size(mitigatedLines) > 0
    for i = array.size(mitigatedLines) - 1 to 0
        l = array.get(mitigatedLines, i)
        lbl = array.get(mitigatedLabels, i)
        cTime = array.get(mitigatedTimes, i)
        if cTime < limitGlobalTime
            line.delete(l)
            label.delete(lbl)
            array.remove(mitigatedLines, i)
            array.remove(mitigatedLabels, i)
            array.remove(mitigatedTimes, i)

f_cleanup_smt_lines()
````
