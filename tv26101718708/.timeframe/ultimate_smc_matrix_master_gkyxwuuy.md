# Ultimate SMC Matrix Master

- url: https://www.tradingview.com/script/GKYxwuUY-Ultimate-SMC-Matrix-Master/
- type: indicator
- pine_id: PUB;2c5092420e8e4376b239d05909533dc6
- version: 1.0

## Description

Core Algorithmic Modules

1. Sonarlab Order Blocks Engine This module tracks institutional footprint zones where large market orders are highly concentrated. Dynamic Sensitivity Filtering: Uses a multi-bar momentum calculation to spot explosive displacement moves, locating the exact rest blocks where trend reversals or continuations initiated. Smart Mitigation Logic: Automatically extends active bullish and bearish order blocks to the right of the chart until price breaks through them. You can configure mitigation to trigger via candle wick violations or candle close breaks, ensuring real-time relevance.

2. Nephew Sam Fair Value Gaps (FVG)Tracks algorithmic market imbalances left behind during rapid expansion phases. Imbalance Thresholds: Filters out insignificant micro-gaps by requiring a minimum tick distance threshold before mapping out the zone. Real-time Invalidation: Renders clear visual expansion fields that automatically dissolve or adjust when incoming market price fully mitigates or closes the gap.

3. Volatility Profiler & Multi-Timeframe Benchmarks This matrix anchors current price action against historical volatility benchmarks to ensure you don't overextend trades near exhaustion zones. ATR vs. DTR Metric: Directly compares the Daily True Range (DTR) against the Average True Range (ATR). The HUD dashboard expresses this as a real-time ratio percentage, dynamically changing color (Green $\rightarrow$ Yellow $\rightarrow$ Orange $\rightarrow$ Red) as the asset approaches its average daily capacity.ADR Bands: Automatically projects visual, shaded Average Daily Range boundary bands around the daily opening price.SSS 50% Equilibrium: Continuously tracks and plots the crucial 50% equilibrium line of higher-timeframe candles (e.g., Daily and 1-Hour). This lets you see at a glance whether the current asset price is premium or discount relative to structural reference candles. Opening Anchors: Plots static daily and weekly opening levels, giving you immediate context on current directional bias.

4. LuxAlgo Market Structure & Fractal Shift Matrix This engine analyzes price swing mechanics to uncover underlying market architecture. BOS & ChoCH Tracking: Utilizes fractal length filters to reliably identify Change of Character (ChoCH) signals for early trend shifts and Break of Structure (BOS) signals for trend validation. Trailing Support & Resistance Breakouts: Offers optional trailing structural lines that paint circle breakout points directly onto the chart whenever confirmation wicks break out. Mathematical Success Metrics: Aggregates total fractal structural wins to display a running probability percentage of successful bullish vs. bearish breaks right on the HUD.

## Source Code

````pine
// © AI Collaborator
//@version=5
indicator("Ultimate SMC Matrix Master", shorttitle="SMC_Matrix", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ==========================================
// CONFIGURATION & GLOBAL INPUTS
// ==========================================
var string G_OB   = "1. Sonarlab Order Blocks"
sens              = input.int(28, minval=1, title="OB Sensitivity", group=G_OB, tooltip="Lower = more blocks. Higher = fewer blocks.") / 100.0
OBMitigationType  = input.string("Close", title="OB Mitigation Type", options=["Close", "Wick"], group=G_OB)
col_bullish       = input.color(#5db49e, title="Bullish OB Border", group=G_OB, inline="cob1")
col_bullish_ob    = input.color(color.new(#64C4AC, 85), title="BG", group=G_OB, inline="cob1")
col_bearish       = input.color(#4760bb, title="Bearish OB Border", group=G_OB, inline="cob2")
col_bearish_ob    = input.color(color.new(#506CD3, 85), title="BG", group=G_OB, inline="cob2")
buy_alert         = input.bool(true, title="Enable OB Buy Alerts", group=G_OB)
sell_alert        = input.bool(true, title="Enable OB Sell Alerts", group=G_OB)

var string G_FVG  = "2. Nephew Sam Fair Value Gaps"
fvg_threshold     = input.float(0.0, "Min FVG Size (Ticks)", minval=0.0, group=G_FVG, tooltip="Filters out microscopic market gaps.")
fvg_bull_col      = input.color(color.new(#2196F3, 85), "Bullish FVG Color", group=G_FVG, inline="fvg1")
fvg_bull_bord     = input.color(#2196F3, "Border", group=G_FVG, inline="fvg1")
fvg_bear_col      = input.color(color.new(#FF9800, 85), "Bearish FVG Color", group=G_FVG, inline="fvg2")
fvg_bear_bord     = input.color(#FF9800, "Border", group=G_FVG, inline="fvg2")

var string G_ATR   = "3. ATR/DTR, ADR Zones & SSS 50%"
TimeFrame          = input.timeframe("D", "ATR Timeframe", group=G_ATR)
firstperColor      = input.int(25, "Threshold 1 (%)", group=G_ATR)
secondperColor     = input.int(50, "Threshold 2 (%)", group=G_ATR)
thirdperColor      = input.int(75, "Threshold 3 (%)", group=G_ATR)
lastperColor       = input.int(100, "Threshold 4 (%)", group=G_ATR)
normalcolor        = input.color(color.gray, "Standard BG Color", group=G_ATR)
colorchangefirst   = input.color(color.green, "Color > Threshold 1", group=G_ATR)
colorchangeSecond  = input.color(color.yellow, "Color > Threshold 2", group=G_ATR)
colorchangeThird   = input.color(color.orange, "Color > Threshold 3", group=G_ATR)
colorchangeLast    = input.color(color.red, "Color > Threshold 4", group=G_ATR)
labels_enabled     = input.bool(true, title="Show Volatility Line Labels", group=G_ATR)
adr_1              = input.int(10, title="ADR Period 1", minval=1, group=G_ATR)
adr_2              = input.int(5, title="ADR Period 2", minval=1, group=G_ATR)
color_ADR1_high    = input.color(#FF8000, title="ADR1 Upper Line", group=G_ATR)
color_ADR2_high    = input.color(#FF4000, title="ADR2 Upper Line", group=G_ATR)
color_ADR1_low     = input.color(#80FF00, title="ADR1 Lower Line", group=G_ATR)
color_ADR2_low     = input.color(#00FF00, title="ADR2 Lower Line", group=G_ATR)
adrUppercolorfill  = input.color(color.red, "ADR Upper Band Shading", group=G_ATR)
adrlowercolorfill  = input.color(color.green, "ADR Lower Band Shading", group=G_ATR)
openofWK           = input.bool(true, title="Plot Weekly Open Line", group=G_ATR)
color_openwk       = input.color(#7DF9FF, title="Weekly Open Color", group=G_ATR)
color_open         = input.color(#808080, title="Daily Open Color", group=G_ATR)
fitypercentOnorOFF = input.bool(true, title="Display SSS 50% Line 1", group=G_ATR)
fiftypercentTF     = input.timeframe("D", "SSS 50% Line 1 TF", group=G_ATR)
fitypercentlineColor = input.color(color.red, title="SSS 50% Line 1 Color", group=G_ATR)
fitypercentOnorOFF2 = input.bool(true, title="Display SSS 50% Line 2", group=G_ATR)
fiftypercentTF2    = input.timeframe("60", "SSS 50% Line 2 TF", group=G_ATR)
fitypercentlineColor2 = input.color(#8d53ac, title="SSS 50% Line 2 Color", group=G_ATR)

var string G_LUX  = "4. LuxAlgo Market Structure"
lux_length        = input.int(5, "Fractal Length Check", minval=3, group=G_LUX)
showBull          = input.bool(true, "Display Bullish Structures", group=G_LUX, inline="lxb1")
bullCss           = input.color(#089981, "", group=G_LUX, inline="lxb1")
showBear          = input.bool(true, "Display Bearish Structures", group=G_LUX, inline="lxb2")
bearCss           = input.color(#f23645, "", group=G_LUX, inline="lxb2")
showSupport       = input.bool(false, "Track Trailing Support", group=G_LUX, inline="lxb3")
supCss            = input.color(#089981, "", group=G_LUX, inline="lxb3")
showResistance    = input.bool(false, "Track Trailing Resistance", group=G_LUX, inline="lxb4")
resCss            = input.color(#f23645, "", group=G_LUX, inline="lxb4")

var string G_DASH = "5. Global Unified Dashboard Layout"
showDash          = input.bool(true, "Enable Dashboard UI HUD", group=G_DASH)
BoxPlacement      = input.string(position.bottom_right, "HUD Canvas Position", options=[position.bottom_right, position.bottom_left, position.top_right, position.top_center, position.bottom_center], group=G_DASH)
textSize          = input.string("Small", "HUD Font Scaling", options=["Tiny", "Small", "Normal"], group=G_DASH)

// ==========================================
// GENERAL METHOD DEFINITIONS & UTILITIES
// ==========================================
draw_line(_x1, _y1, _x2, _y2, _xloc, _extend, _color, _style, _width) =>
    dline = line.new(x1=_x1, y1=_y1, x2=_x2, y2=_y2, xloc=_xloc, extend=_extend, color=_color, style=_style, width=_width)
    line.delete(dline[1])

draw_label(_x, _y, _text, _xloc, _yloc, _color, _style, _textcolor, _size, _textalign, _tooltip) =>
    dlabel = label.new(x=_x, y=_y, text=_text, xloc=_xloc, yloc=_yloc, color=_color, style=_style, textcolor=_textcolor, size=_size, textalign=_textalign, tooltip=_tooltip)
    label.delete(dlabel[1])

tickerid_func() =>
    syminfo.type == "futures" ? syminfo.root + "1!" : syminfo.tickerid

adr_func(lengthInput, hi_low) =>
    float result = 0.0
    open_    = request.security(tickerid_func(), "D", open, barmerge.gaps_off, barmerge.lookahead_on)
    adr_High = request.security(tickerid_func(), "D", ta.sma(high[1], lengthInput), barmerge.gaps_off, barmerge.lookahead_on)
    adr_Low  = request.security(tickerid_func(), "D", ta.sma(low[1], lengthInput), barmerge.gaps_off, barmerge.lookahead_on)
    adr      = adr_High - adr_Low
    hi_low ? adr / 2.0 + open_ : open_ - adr / 2.0

f_returnTFminutes(_tfs) =>
    // Converted to explicit if/else chains to clear structural indentation conflicts
    int tfMin = 1
    if _tfs == "240"
        tfMin := 240
    else if _tfs == "130"
        tfMin := 130
    else if _tfs == "90"
        tfMin := 90
    else if _tfs == "60"
        tfMin := 60
    else if _tfs == "65"
        tfMin := 65
    else if _tfs == "45"
        tfMin := 45
    else if _tfs == "30"
        tfMin := 30
    else if _tfs == "26"
        tfMin := 26
    else if _tfs == "15"
        tfMin := 15
    else if _tfs == "13"
        tfMin := 13
    else if _tfs == "10"
        tfMin := 10
    else if _tfs == "9"
        tfMin := 9
    else if _tfs == "18"
        tfMin := 18
    else if _tfs == "36"
        tfMin := 36
    else if _tfs == "6"
        tfMin := 6
    else if _tfs == "5"
        tfMin := 5
    else if _tfs == "4"
        tfMin := 4
    else if _tfs == "3"
        tfMin := 3
    else if _tfs == "2"
        tfMin := 2
    else if _tfs == "1"
        tfMin := 1
    else if _tfs == "1D" or _tfs == "D"
        tfMin := 1440
    else if _tfs == "1W" or _tfs == "W"
        tfMin := 10080
    else if _tfs == "1M" or _tfs == "M"
        tfMin := 43830

    int currentTFmins = timeframe.isdaily ? 1440 : timeframe.isweekly ? 10080 : timeframe.ismonthly ? 43830 : na
    if na(currentTFmins)
        if timeframe.period == "65"
            currentTFmins := 65
        else if timeframe.period == "60"
            currentTFmins := 60
        else if timeframe.period == "90"
            currentTFmins := 90
        else if timeframe.period == "240"
            currentTFmins := 240
        else if timeframe.period == "130"
            currentTFmins := 130
        else if timeframe.period == "26"
            currentTFmins := 26
        else if timeframe.period == "18"
            currentTFmins := 18
        else if timeframe.period == "5"
            currentTFmins := 5
        else if timeframe.period == "36"
            currentTFmins := 36
        else if timeframe.period == "9"
            currentTFmins := 9
        else if timeframe.period == "4"
            currentTFmins := 4
        else if timeframe.period == "3"
            currentTFmins := 3
        else if timeframe.period == "2"
            currentTFmins := 2
        else if timeframe.period == "1"
            currentTFmins := 1
        else if timeframe.period == "45"
            currentTFmins := 45
        else if timeframe.period == "30"
            currentTFmins := 30
        else if timeframe.period == "16"
            currentTFmins := 16
        else if timeframe.period == "13"
            currentTFmins := 13
        else if timeframe.period == "15"
            currentTFmins := 15
            
    tfMin >= currentTFmins

// ==========================================
// MODULE 1: SONARLAB ORDER BLOCKS ENGINE
// ==========================================
OBBullMitigation = OBMitigationType == "Close" ? close[1] : low
OBBearMitigation = OBMitigationType == "Close" ? close[1] : high

bool ob_created = false
bool ob_created_bull = false
var int cross_index = na

var box drawlongBox = na
var longBoxes = array.new_box()
var box drawShortBox = na
var shortBoxes = array.new_box()

pc = (open - open[4]) / open[4] * 100.0

if ta.crossunder(pc, -sens)
    ob_created := true
    cross_index := bar_index

if ta.crossover(pc, sens)
    ob_created_bull := true
    cross_index := bar_index

if ob_created and (na(cross_index[1]) or cross_index - cross_index[1] > 5)
    int last_green = 4
    for i = 4 to 15
        if close[i] > open[i]
            last_green := i
            break
    drawShortBox := box.new(left=bar_index[last_green], top=high[last_green], bottom=low[last_green], right=bar_index[last_green], bgcolor=col_bearish_ob, border_color=col_bearish, extend=extend.right)
    array.push(shortBoxes, drawShortBox)

if ob_created_bull and (na(cross_index[1]) or cross_index - cross_index[1] > 5)
    int last_red = 4
    for i = 4 to 15
        if close[i] < open[i]
            last_red := i
            break
    drawlongBox := box.new(left=bar_index[last_red], top=high[last_red], bottom=low[last_red], right=bar_index[last_red], bgcolor=col_bullish_ob, border_color=col_bullish, extend=extend.right)
    array.push(longBoxes, drawlongBox)

if array.size(shortBoxes) > 0
    for i = array.size(shortBoxes) - 1 to 0 by 1
        sbox = array.get(shortBoxes, i)
        top = box.get_top(sbox)
        bot = box.get_bottom(sbox)
        if OBBearMitigation > top
            array.remove(shortBoxes, i)
            box.delete(sbox)
        else if high > bot and sell_alert
            alert('Price inside Bearish OB', alert.freq_once_per_bar)

if array.size(longBoxes) > 0
    for i = array.size(longBoxes) - 1 to 0 by 1
        lbox = array.get(longBoxes, i)
        bot = box.get_bottom(lbox)
        top = box.get_top(lbox)
        if OBBullMitigation < bot
            array.remove(longBoxes, i)
            box.delete(lbox)
        else if low < top and buy_alert
            alert('Price inside Bullish OB', alert.freq_once_per_bar)

// ==========================================
// MODULE 2: FAIR VALUE GAPS (FVG/IFVG)
// ==========================================
var box[] bull_fvgs = array.new<box>()
var box[] bear_fvgs = array.new<box>()

bull_fvg_detected = (low[0] - high[2]) > (fvg_threshold * syminfo.mintick) and close[1] > high[2]
if bull_fvg_detected
    array.push(bull_fvgs, box.new(left=bar_index[2], top=low[0], right=bar_index, bottom=high[2], bgcolor=fvg_bull_col, border_color=fvg_bull_bord))

bear_fvg_detected = (low[2] - high[0]) > (fvg_threshold * syminfo.mintick) and close[1] < low[2]
if bear_fvg_detected
    array.push(bear_fvgs, box.new(left=bar_index[2], top=low[2], right=bar_index, bottom=high[0], bgcolor=fvg_bear_col, border_color=fvg_bear_bord))

if array.size(bull_fvgs) > 0
    for i = array.size(bull_fvgs) - 1 to 0
        b = array.get(bull_fvgs, i)
        if close < box.get_bottom(b)
            array.remove(bull_fvgs, i)
            box.delete(b)
        else if box.get_right(b) == bar_index[1]
            box.set_right(b, bar_index)

if array.size(bear_fvgs) > 0
    for i = array.size(bear_fvgs) - 1 to 0
        b = array.get(bear_fvgs, i)
        if close > box.get_top(b)
            array.remove(bear_fvgs, i)
            box.delete(b)
        else if box.get_right(b) == bar_index[1]
            box.set_right(b, bar_index)

// ==========================================
// MODULE 3: ATRvsDTR / ADR / SSS 50% SYSTEM
// ==========================================
atr = request.security(syminfo.tickerid, TimeFrame, ta.atr(14))
atr2 = math.round(atr, 2)
dtr = request.security(syminfo.tickerid, TimeFrame, math.round(high - low, 2))
atrp = math.round(dtr / (atr == 0 ? 1 : atr) * 100)

start_time       = request.security(tickerid_func(), "D", time_close[1], barmerge.gaps_off, barmerge.lookahead_on)
open__           = request.security(tickerid_func(), "D", open, barmerge.gaps_off, barmerge.lookahead_on)
openWK__         = request.security(tickerid_func(), "W", open, barmerge.gaps_off, barmerge.lookahead_on)
start_day_open   = request.security(syminfo.tickerid, 'D', open, lookahead=barmerge.lookahead_on)
start_time1      = request.security(syminfo.tickerid, 'W', open, lookahead=barmerge.lookahead_on)
perc50_1_time    = request.security(syminfo.tickerid, fiftypercentTF, time[1], lookahead=barmerge.lookahead_on)
perc50_2_time    = request.security(syminfo.tickerid, fiftypercentTF2, time[1], lookahead=barmerge.lookahead_on)

adr1_high = adr_func(adr_1, true)
adr1_low  = adr_func(adr_1, false)
adr2_high = adr_func(adr_2, true)
adr2_low  = adr_func(adr_2, false)

highofTFinput       = request.security(syminfo.tickerid, fiftypercentTF, high[1], lookahead=barmerge.lookahead_on)
lowofTFinput        = request.security(syminfo.tickerid, fiftypercentTF, low[1], lookahead=barmerge.lookahead_on)
fiftypercentLevel   = (lowofTFinput - highofTFinput) * 0.5 + highofTFinput

highofTFinput2      = request.security(syminfo.tickerid, fiftypercentTF2, high[1], lookahead=barmerge.lookahead_on)
lowofTFinput2       = request.security(syminfo.tickerid, fiftypercentTF2, low[1], lookahead=barmerge.lookahead_on)
fiftypercentLevel2  = (lowofTFinput2 - highofTFinput2) * 0.5 + highofTFinput2

show_chart = timeframe.isintraday

currTF = timeframe.period
float posX = time + (24 * 60 * 60 * 1000)
if currTF == "60" or currTF == "90"
    posX := time + (24 * 60 * 60 * 2000)
if currTF == "240"
    posX := time + (24 * 60 * 60 * 10000)
if currTF == "720" or currTF == "D"
    posX := time + (24 * 60 * 60 * 20000)

var perc50_1 = line.new(na,na,na,na)
if fitypercentOnorOFF and f_returnTFminutes(fiftypercentTF)
    perc50_1 := line.new(perc50_1_time, fiftypercentLevel, time, fiftypercentLevel, xloc=xloc.bar_time, extend=extend.right, color=fitypercentlineColor, width=1)
    line.delete(perc50_1[1])
if labels_enabled and f_returnTFminutes(fiftypercentTF)
    perc50_1_lbl = label.new(math.round(posX), fiftypercentLevel, fiftypercentTF + ":50% (" + str.tostring(math.round(fiftypercentLevel,2)) + ")", color=color.new(color.white,100), textcolor=fitypercentlineColor, style=label.style_none, size=size.normal, xloc=xloc.bar_time)
    label.delete(perc50_1_lbl[1])

var perc50_2 = line.new(na,na,na,na)
if fitypercentOnorOFF2 and f_returnTFminutes(fiftypercentTF2)
    perc50_2 := line.new(perc50_2_time, fiftypercentLevel2, time, fiftypercentLevel2, xloc=xloc.bar_time, extend=extend.right, color=fitypercentlineColor2, width=1)
    line.delete(perc50_2[1])
if labels_enabled and f_returnTFminutes(fiftypercentTF2)
    perc50_2_lbl = label.new(math.round(posX), fiftypercentLevel2, fiftypercentTF2 + ":50% (" + str.tostring(math.round(fiftypercentLevel2,2)) + ")", color=color.new(color.white,100), textcolor=fitypercentlineColor2, style=label.style_none, size=size.normal, xloc=xloc.bar_time)
    label.delete(perc50_2_lbl[1])

if openofWK and f_returnTFminutes("W")
    var line1 = line.new(na, na, na, na, style=line.style_solid, color=color_openwk, extend=extend.right)
    if ta.change(weekofyear)
        line.set_xy1(line1, bar_index, open)
        line.set_xy2(line1, bar_index + 1, open)
if labels_enabled and f_returnTFminutes("W")
    wo_lbl = label.new(math.round(posX), start_time1, "Open WK (" + str.tostring(math.round(start_time1,2)) + ")", color=color.new(color.white,100), textcolor=color_openwk, style=label.style_none, size=size.normal, xloc=xloc.bar_time)
    label.delete(wo_lbl[1])

day_line = line.new(x1=bar_index-1, y1=start_day_open, x2=bar_index, y2=start_day_open, xloc=xloc.bar_index, style=line.style_solid, extend=extend.right, color=color_open)
line.delete(day_line[1])
if labels_enabled and f_returnTFminutes("D")
    d_lbl = label.new(math.round(posX), open__, "Open (" + str.tostring(math.round(open__,2)) + ")", color=color.new(color.white,100), textcolor=color_open, style=label.style_none, size=size.normal, xloc=xloc.bar_time)
    label.delete(d_lbl[1])

if show_chart
    draw_line1 = line.new(start_time, adr1_high, time, adr1_high, xloc.bar_time, extend.none, color_ADR1_high, line.style_solid, 1)
    line.delete(draw_line1[1])
    draw_line2 = line.new(start_time, adr2_high, time, adr2_high, xloc.bar_time, extend.none, color_ADR2_high, line.style_solid, 1)
    line.delete(draw_line2[1])
    draw_line3 = line.new(start_time, adr1_low, time, adr1_low, xloc.bar_time, extend.none, color_ADR1_low, line.style_solid, 1)
    line.delete(draw_line3[1])
    draw_line4 = line.new(start_time, adr2_low, time, adr2_low, xloc.bar_time, extend.none, color_ADR2_low, line.style_solid, 1)
    line.delete(draw_line4[1])
    linefill.new(draw_line1, draw_line2, color.new(adrUppercolorfill, 80))
    linefill.new(draw_line3, draw_line4, color.new(adrlowercolorfill, 80))

[currPrice, currHigh, currLow] = request.security(syminfo.tickerid, timeframe.period, [close, high, low], lookahead=barmerge.lookahead_on)
if ta.crossover(currPrice, fiftypercentLevel) or ta.crossover(currPrice, fiftypercentLevel2)
    alert(syminfo.ticker + " [" + timeframe.period + "] : Cross over 50% of prev candle detected!", alert.freq_once_per_bar)
if ta.crossunder(currPrice, fiftypercentLevel) or ta.crossunder(currPrice, fiftypercentLevel2)
    alert(syminfo.ticker + " [" + timeframe.period + "] : Cross under 50% of prev candle detected!", alert.freq_once_per_bar)
if ta.crossover(currPrice, adr1_high)
    alert(syminfo.ticker + " [" + timeframe.period + "] : Cross over upper adr 1 detected!", alert.freq_once_per_bar)
if ta.crossover(currPrice, adr2_high)
    alert(syminfo.ticker + " [" + timeframe.period + "] : Cross over upper adr 2 detected!", alert.freq_once_per_bar)
if ta.crossunder(currPrice, adr1_low)
    alert(syminfo.ticker + " [" + timeframe.period + "] : Cross under lower adr 1 detected!", alert.freq_once_per_bar)
if ta.crossunder(currPrice, adr2_low)
    alert(syminfo.ticker + " [" + timeframe.period + "] : Cross under lower adr 2 detected!", alert.freq_once_per_bar)

if show_chart and labels_enabled
    draw_label(bar_index + 1, adr1_high, "ADR1 Upper (" + str.tostring(math.round_to_mintick(adr1_high)) + ")", xloc.bar_index, yloc.price, color.new(color.white, 100), label.style_label_left, color_ADR1_high, size.normal, text.align_left, '')
    draw_label(bar_index + 1, adr2_high, "ADR2 Upper (" + str.tostring(math.round_to_mintick(adr2_high)) + ")", xloc.bar_index, yloc.price, color.new(color.white, 100), label.style_label_left, color_ADR2_high, size.normal, text.align_left, '')
    draw_label(bar_index + 1, adr1_low,  "ADR1 Lower (" + str.tostring(math.round_to_mintick(adr1_low)) + ")",  xloc.bar_index, yloc.price, color.new(color.white, 100), label.style_label_left, color_ADR1_low, size.normal, text.align_left, '')
    draw_label(bar_index + 1, adr2_low,  "ADR2 Lower (" + str.tostring(math.round_to_mintick(adr2_low)) + ")",  xloc.bar_index, yloc.price, color.new(color.white, 100), label.style_label_left, color_ADR2_low, size.normal, text.align_left, '')
    draw_label(bar_index + 1, open__,   "Open (" + str.tostring(math.round_to_mintick(open__)) + ")",         xloc.bar_index, yloc.price, color.new(color.white, 100), label.style_label_left, color_open, size.normal, text.align_left, '')

// ==========================================
// MODULE 4: LUXALGO MARKET STRUCTURE (FRACTAL)
// ==========================================
type fractal
    float value
    int loc
    bool iscrossed

var p = int(lux_length / 2)
n = bar_index
dh = math.sum(math.sign(high - high[1]), p)
dl = math.sum(math.sign(low - low[1]), p)

bullf = dh == -p and dh[p] == p and high[p] == ta.highest(lux_length)
bearf = dl == p and dl[p] == -p and low[p] == ta.lowest(lux_length)

bullf_count = ta.cum(bullf ? 1 : 0)
bearf_count = ta.cum(bearf ? 1 : 0)

var upper = fractal.new()
var line lower_lvl = na
var label ms_lbl = na
var bull_ms_count = 0
var broken_sup = false
var os = 0

if bullf
    upper.value := high[p]
    upper.loc := n - p
    upper.iscrossed := false

if ta.crossover(close, upper.value) and not upper.iscrossed
    line.new(upper.loc, upper.value, n, upper.value, color=showBull ? bullCss : na)
    ms_lbl := label.new(int(math.avg(n, upper.loc)), upper.value, os == -1 ? 'ChoCH' : 'BOS', color=color(na), textcolor=showBull ? bullCss : na, style=label.style_label_down, size=size.tiny)
    k = 2
    min = low[1]
    for i = 2 to (n - upper.loc) - 1
        min := math.min(low[i], min)
        k := low[i] == min ? i : k
    if showSupport
        lower_lvl := line.new(n - k, min, n, min, color=bullCss, style=line.style_dashed)
        broken_sup := false
    upper.iscrossed := true
    bull_ms_count += 1
    os := 1
else if showSupport and not broken_sup and not na(lower_lvl)
    lower_lvl.set_x2(n)
    if close < lower_lvl.get_y2()
        broken_sup := true

var lower = fractal.new()
var line upper_lvl = na
var broken_res = false
var bear_ms_count = 0

if bearf
    lower.value := low[p]
    lower.loc := n - p
    lower.iscrossed := false

if ta.crossunder(close, lower.value) and not lower.iscrossed
    line.new(lower.loc, lower.value, n, lower.value, color=showBear ? bearCss : na)
    label.new(int(math.avg(n, lower.loc)), lower.value, os == 1 ? 'ChoCH' : 'BOS', color=color(na), textcolor=showBear ? bearCss : na, style=label.style_label_up, size=size.tiny)
    k = 2
    max = high[1]
    for i = 2 to (n - lower.loc) - 1
        max := math.max(high[i], max)
        k := high[i] == max ? i : k
    if showResistance
        upper_lvl := line.new(n - k, max, n, max, color=bearCss, style=line.style_dashed)
        broken_res := false
    lower.iscrossed := true
    bear_ms_count += 1
    os := -1
else if showResistance and not broken_res and not na(upper_lvl)
    upper_lvl.set_x2(n)
    if close > upper_lvl.get_y2()
        broken_res := true

plot(broken_res and not broken_res[1] ? low : na, 'Resistance Breakout', #089981, 2, plot.style_circles)
plot(broken_sup and not broken_sup[1] ? high : na, 'Support Breakout', #f23645, 2, plot.style_circles)

// ==========================================
// MODULE 5: UNIFIED HUD DASHBOARD DATA MATRICES
// ==========================================
var table_position = BoxPlacement
var table_size = textSize == 'Tiny' ? size.tiny : textSize == 'Small' ? size.small : size.normal

var tb = table.new(table_position, 3, 4, bgcolor=#1e222d, border_color=#373a46, border_width=1, frame_color=#373a46, frame_width=1)

if showDash and barstate.islast
    color current_bg = normalcolor
    if atrp > firstperColor
        current_bg := colorchangefirst
    if atrp > secondperColor
        current_bg := colorchangeSecond
    if atrp > thirdperColor
        current_bg := colorchangeThird
    if atrp > lastperColor
        current_bg := colorchangeLast

    table.cell(tb, 0, 0, "VOLATILITY METRICS", text_color=color.white, text_size=table_size, bgcolor=#2a2e39)
    table.merge_cells(tb, 0, 0, 2, 0)
    
    table.cell(tb, 0, 1, "ATR: " + str.tostring(atr2), text_color=color.white, text_size=table_size)
    table.cell(tb, 1, 1, "DTR: " + str.tostring(dtr), text_color=color.white, text_size=table_size)
    table.cell(tb, 2, 1, "Ratio: " + str.tostring(atrp) + "%", text_color=color.black, text_size=table_size, bgcolor=current_bg)
    
    table.cell(tb, 0, 2, "STRUCTURE TO FRACTAL MATRIX", text_color=color.white, text_size=table_size, bgcolor=#2a2e39)
    table.merge_cells(tb, 0, 2, 2, 2)
    
    float bull_pct = bullf_count > 0 ? (bull_ms_count / bullf_count) * 100.0 : 0.0
    float bear_pct = bearf_count > 0 ? (bear_ms_count / bearf_count) * 100.0 : 0.0
    table.cell(tb, 0, 3, "Bullish Structure: " + str.tostring(bull_pct, "#.##") + "%", text_color=bullCss, text_size=table_size)
    table.cell(tb, 1, 3, "", bgcolor=#1e222d)
    table.cell(tb, 2, 3, "Bearish Structure: " + str.tostring(bear_pct, "#.##") + "%", text_color=bearCss, text_size=table_size)
    table.merge_cells(tb, 1, 3, 1, 3)
````
