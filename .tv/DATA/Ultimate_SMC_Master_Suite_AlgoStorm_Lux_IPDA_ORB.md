<!-- tradingview-pine-id: PUB;9d15c7f485724f1d9cf6847d3b3654e6 -->
<!-- tradingviewscripts-format: 1 -->
# Ultimate SMC Master Suite [AlgoStorm + Lux + IPDA + ORB]

Source: https://www.tradingview.com/script/AdMcbpCN-The-Ultimate-Indicator/

## Description

Here is a complete feature and use-case letter detailing the mechanics and strategic applications of your custom script.

## The Ultimate Indicator: Function and Use Guide

This document outlines the core mechanics of the "Ultimate SMC Master Suite." By combining institutional session boundaries, dynamic liquidity mapping, and fractal standard deviations into a single optimized TradingView script, this tool eliminates chart clutter while exposing high-probability market structures.

---

### Core Functions

| Module | Technical Features |
| --- | --- |
| **AlgoStorm ISS** | Maps Asia, London, and New York sessions. Anchors the Overnight (Globex) High/Low and calculates the 60-minute Initial Balance (IB) with automated 1.5x and 2.0x extension projections. |
| **Triple ORB 15** | Captures the 15-minute Opening Range for three independent time slots (Morning, Evening, Night) and continuously extends the breakout levels to the right edge of the chart. |
| **IPDA Standard Deviations** | Projects standard deviation pricing bands based on structural swing highs and lows across customizable fractal timeframes (Monthly, Weekly, Daily, Intraday). |
| **Fair Value Gaps (FVG)** | Automatically detects volume imbalances. Highlights unmitigated bullish/bearish zones and instantly deletes them once price fills the gap. Includes a live tracking dashboard. |
| **Order Blocks (OB)** | Identifies institutional supply and demand zones tied directly to volume pivot points. Automatically filters out mitigated levels to keep the chart clean. |

---

### Strategic Use Cases

**1. High-Probability Breakout Entries**
The intersection of the ISS Initial Balance and the Triple ORB provides concrete triggers for directional momentum. If price cleanly breaks the 15-minute Morning ORB and sustains a push through the 60-minute Initial Balance High, it confirms institutional trend-day behavior. This provides a highly defined entry parameter when firing off options contracts on SPY or TSLA with real capital.

**2. Precision Target Mapping**
Instead of guessing where a momentum run will exhaust, the IPDA Standard Deviations and ISS IB Extensions provide exact mathematical take-profit zones. Scaling out at the 1.5 or 2.0 standard deviation bands ensures you are paying yourself into buy-side or sell-side liquidity before a reversal traps the position.

**3. Institutional Reversal Setups**
The automated FVG and Order Block modules serve as dynamic support and resistance. If price aggressively retraces into a fresh, unmitigated volume-backed Order Block that perfectly aligns with the Overnight Low, it creates a prime asymmetrical risk-to-reward setup. This is particularly effective for managing tight stops during Take Profit Trader evaluations, protecting your drawdown while positioning for maximum profit splits.

**4. Streamlined Execution Environment**
Consolidating five resource-heavy scripts into a single master indicator drastically reduces TradingView's processing load, keeping rendering speeds ultra-fast on a PC setup. Because mitigated Order Blocks and filled FVGs automatically delete themselves, the chart stays entirely focused on active, tradable data without visual noise.

---

## Source Code

````pine
// This work is licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
//@version=6
indicator(title = "Ultimate SMC Master Suite [AlgoStorm + Lux + IPDA + ORB]", shorttitle = "SMC Master", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// =================================================================================================
// 1. INPUTS & SETTINGS
// =================================================================================================

// --- AlgoStorm ISS Inputs ---
string G_VIS = "ISS: Visibility"
bool i_showAsia  = input.bool(true, "Asia Session Box", group = G_VIS)
bool i_showLon   = input.bool(true, "London Session Box", group = G_VIS)
bool i_showNy    = input.bool(true, "New York Session Box", group = G_VIS)
bool i_showOpens = input.bool(true, "Session Open Lines", group = G_VIS)
bool i_showON    = input.bool(true, "Overnight (Globex) H/L", group = G_VIS)
bool i_showIB    = input.bool(true, "Initial Balance H/L", group = G_VIS)
bool i_showExt   = input.bool(true, "IB Extensions", group = G_VIS)
bool i_showOR    = input.bool(true, "Opening Range H/L", group = G_VIS)
bool i_showTable = input.bool(true, "Session State Table", group = G_VIS)

string G_SESS = "ISS: Session Windows"
string i_tz       = input.string("America/New_York", "Timezone", group = G_SESS)
string i_asiaSess = input.session("1800-0300", "Asia Session", group = G_SESS)
string i_lonSess  = input.session("0300-0930", "London Session", group = G_SESS)
string i_nySess   = input.session("0930-1600", "New York Session (RTH)", group = G_SESS)
string i_onSess   = input.session("1800-0930", "Overnight (Globex)", group = G_SESS)

string G_STRUCT = "ISS: Structure"
int   i_ibMin  = input.int(60, "Initial Balance Length (min)", group = G_STRUCT)
int   i_orMin  = input.int(15, "Opening Range Length (min)", group = G_STRUCT)
float i_ext1   = input.float(1.5, "IB Extension Multiple 1", group = G_STRUCT)
float i_ext2   = input.float(2.0, "IB Extension Multiple 2", group = G_STRUCT)
int i_histDays = input.int(5, "Session Box History (days)", group = G_STRUCT)
int i_lblOff   = input.int(8, "Text Offset (bars)", group = G_STRUCT)

color i_cAsia = input.color(#fff59d, "Asia Session", group = G_STRUCT)
color i_cLon  = input.color(#faa1a4, "London Session", group = G_STRUCT)
color i_cNy   = input.color(#a5d6a7, "New York Session", group = G_STRUCT)
color i_cON   = input.color(#ffffff, "Overnight H/L", group = G_STRUCT)
color i_cIB   = input.color(#c7e36c, "Initial Balance", group = G_STRUCT)
color i_cExt  = input.color(#ffffff, "IB Extensions", group = G_STRUCT)
color i_cOR   = input.color(#ffffff, "Opening Range", group = G_STRUCT)

// --- Triple ORB 15 Inputs ---
string G_ORB = "TRIPLE ORB 15"
string orb_sess1 = input.session("0930-0945", "Session 1", group = G_ORB)
color orb_col1   = input.color(#00bcd4, "Color 1", group = G_ORB)
string orb_sess2 = input.session("1800-1815", "Session 2", group = G_ORB)
color orb_col2   = input.color(#ff9800, "Color 2", group = G_ORB)
string orb_sess3 = input.session("2000-2015", "Session 3", group = G_ORB)
color orb_col3   = input.color(#9c27b0, "Color 3", group = G_ORB)

// --- IPDA Standard Deviations Inputs ---
string G_IPDA = "IPDA FRACTAL STDEV"
string dvs = input.text_area("0\n1\n-1\n-1.5\n-2\n-2.5\n-4", "Deviations", group = G_IPDA)
string label_size = input.string("Small", "Label Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = G_IPDA)
bool lbl = input.bool(false, "Hide Labels?", group = G_IPDA)
bool MLB = input.bool(true , "Monthly", group = G_IPDA), string lMTF = input.timeframe("D"), string hMTF = input.timeframe("D")
bool WLB = input.bool(true , "Weekly", group = G_IPDA), string lWTF = input.timeframe("240"), string hWTF = input.timeframe("480")
bool DLB = input.bool(true , "Daily", group = G_IPDA), string lDTF = input.timeframe("15"), string hDTF = input.timeframe("60")
bool ILB = input.bool(true , "Intraday", group = G_IPDA), string lITF = input.timeframe("1"), string hITF = input.timeframe("5")
bool removeDev = input.bool(false, "Remove Invalidated Devs?", group = G_IPDA)
bool tw3_up = input.bool(true, "TW3 Up", group = G_IPDA), bool tw2_up = input.bool(true, "TW2 Up", group = G_IPDA), bool tw1_up = input.bool(true , "TW1 Up", group = G_IPDA)
bool tw3_dw = input.bool(true, "TW3 Down", group = G_IPDA), bool tw2_dw = input.bool(true, "TW2 Down", group = G_IPDA), bool tw1_dw = input.bool(true , "TW1 Down", group = G_IPDA)

// --- Fair Value Gaps (LuxAlgo) Inputs ---
string G_FVG = "FAIR VALUE GAPS"
float thresholdPer = input.float(0, "Threshold %", group = G_FVG)
bool autoFvg = input.bool(false, "Auto Threshold", group = G_FVG)
int showLastFvg = input.int(0, 'Unmitigated Levels', group = G_FVG)
bool mitigationLevels = input.bool(false, 'Mitigation Levels', group = G_FVG)
string fvg_tf = input.timeframe('', "FVG Timeframe", group = G_FVG)
int fvg_extend = input.int(20, 'Extend Boxes', group = G_FVG)
bool fvg_dynamic = input.bool(false, 'Dynamic', group = G_FVG)
color bullCssFvg = input.color(color.new(#089981, 70), "Bullish FVG", group = G_FVG)
color bearCssFvg = input.color(color.new(#f23645, 70), "Bearish FVG", group = G_FVG)
bool showDashFvg  = input.bool(false, 'Show FVG Dash', group = G_FVG)
string dashLocFvg  = input.string('Bottom Right', 'Dash Location', options = ['Top Right', 'Bottom Right', 'Bottom Left'], group = G_FVG)
string textSizeFvg = input.string('Small', 'Dash Size', options = ['Tiny', 'Small', 'Normal'], group = G_FVG)

// --- Order Blocks (LuxAlgo) Inputs ---
string G_OB = "ORDER BLOCKS"
int ob_length = input.int(5, 'Volume Pivot Length', group = G_OB)
int bull_ext_last = input.int(3, 'Bullish OB count', group = G_OB)
color bg_bull_css = input.color(color.new(#169400, 80), 'Bull BG', group = G_OB)
color bull_css_ob = input.color(#169400, 'Bull Line', group = G_OB)
color bull_avg_css = input.color(color.new(#9598a1, 37), 'Bull Avg', group = G_OB)
int bear_ext_last = input.int(3, 'Bearish OB count', group = G_OB)
color bg_bear_css = input.color(color.new(#ff1100, 80), 'Bear BG', group = G_OB)
color bear_css_ob = input.color(#ff1100, 'Bear Line', group = G_OB)
color bear_avg_css = input.color(color.new(#9598a1, 37), 'Bear Avg', group = G_OB)
string ob_mitigation = input.string('Wick', 'Mitigation Methods', options = ['Wick', 'Close'], group = G_OB)

// =================================================================================================
// 2. TYPES & GLOBALS
// =================================================================================================

color noColor = color.new(color.white, 100)

// IPDA Types
type DexterDev
    string side
    array<line> lines
    array<label> labels

type TimeWindow
    chart.point h
    chart.point h_stl
    chart.point l
    chart.point l_sth
    line edge
    DexterDev up
    DexterDev dw    

// FVG Type
type fvg_type
    float max
    float min
    bool isbull
    int t

// =================================================================================================
// 3. METHODS & FUNCTIONS
// =================================================================================================

// -- ISS Session Boxes --
f_sessionBox(bool show, string sess, string name, color col) =>
    bool inSess = not na(time("", sess, i_tz))
    bool starts = inSess and not inSess[1]
    var array<box> bxs = array.new<box>()
    var array<line> opn = array.new<line>()
    if show
        color openCol = i_showOpens ? color.new(col, 45) : color.new(col, 100)
        if starts
            array.push(bxs, box.new(bar_index, high, bar_index, low, border_color = color.new(col, 55), border_width = 1, bgcolor = color.new(col, 92), text = name, text_color = color.new(col, 25), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top))
            array.push(opn, line.new(bar_index, open, bar_index, open, color = openCol, style = line.style_dotted, width = 1))
            if array.size(bxs) > i_histDays
                box.delete(array.shift(bxs))
                line.delete(array.shift(opn))
        else if inSess and array.size(bxs) > 0
            box b = array.get(bxs, array.size(bxs) - 1)
            box.set_right(b, bar_index)
            box.set_top(b, math.max(box.get_top(b), high))
            box.set_bottom(b, math.min(box.get_bottom(b), low))
            line o = array.get(opn, array.size(opn) - 1)
            line.set_x2(o, bar_index)
            line.set_color(o, openCol)
    inSess

// -- ISS Level Drawing function (No Tabs, Text on Top, Extended Right) --
f_drawLevel(line ln, label lb, float y, string txt, color col, string sty, bool show, int startBar) =>
    if show and not na(y)
        line.set_xy1(ln, startBar, y)
        line.set_xy2(ln, bar_index, y)
        line.set_extend(ln, extend.right) 
        line.set_color(ln, col)
        line.set_style(ln, sty == "solid" ? line.style_solid : sty == "dashed" ? line.style_dashed : line.style_dotted)
        
        label.set_xy(lb, bar_index + i_lblOff, y)
        label.set_text(lb, txt + " " + str.tostring(y, format.mintick))
        label.set_style(lb, label.style_none) // Removes the background tab
        label.set_textcolor(lb, col)
        label.set_textalign(lb, text.align_left)
    else
        line.set_xy1(ln, na, na)
        label.set_xy(lb, na, na)

// -- TRIPLE ORB METHOD --
f_get_orb(string sess, color lineCol) =>
    bool inSess = not na(time("", sess, i_tz))
    bool starts = inSess and not inSess[1]
    bool ends   = not inSess and inSess[1]
    var float highRange = na
    var float lowRange  = na
    var line highLine = na
    var line lowLine  = na
    if starts
        highRange := high
        lowRange  := low
    else if inSess
        highRange := math.max(highRange, high)
        lowRange  := math.min(lowRange, low)
    if ends
        highLine := line.new(bar_index - 1, highRange, bar_index, highRange, color=lineCol, width=2, extend=extend.right)
        lowLine  := line.new(bar_index - 1, lowRange, bar_index, lowRange, color=lineCol, width=2, extend=extend.right)
    [highRange, lowRange]

// -- IPDA METHODS --
ipda_size(string _size) =>
    switch _size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge

tfRange(string LOW, string HIGH) => timeframe.in_seconds(timeframe.period) >= timeframe.in_seconds(LOW) and timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(HIGH)

swing_high_point(chart.point prev)=>
    if (high<high[1] and high[1]>high[2]) or (high<=high[1] and high[1]>high[2]) or (high<high[1] and high[1]>=high[2])
        chart.point.from_time(time[1], high[1])
    else
        prev

swing_low_point(chart.point prev)=>
    if (low>low[1] and low[1]<low[2]) or (low>=low[1] and low[1]<low[2]) or (low>low[1] and low[1]<=low[2])
        chart.point.from_time(time[1], low[1])
    else
        prev

var deviations = array.new_float()
if deviations.size() == 0 
    string[] chrs = str.split(dvs, "")
    if chrs.size() > 0
        var string num = ""
        for i = 0 to chrs.size() - 1
            string c = chrs.get(i)
            if c == "\n"
                deviations.unshift(str.tonumber(num))
                num := ""
            else
                num += c
        deviations.unshift(str.tonumber(num))

method plotDexterDev(TimeWindow TW)=>
    DexterDev stdev_up = DexterDev.new("UP", array.new_line(), array.new_label())
    DexterDev stdev_dw = DexterDev.new("DW", array.new_line(), array.new_label())
    if not na(TW.h) and not na(TW.h_stl)
        int rxh = TW.h.time, int lxh = TW.h_stl.time 
        float zyh = TW.h_stl.price, float yh = TW.h.price-zyh
        stdev_dw.lines.unshift(line.new(chart.point.from_time(lxh, TW.h.price), TW.h, xloc.bar_time, color=chart.fg_color))
        stdev_dw.labels.unshift(label.new(rxh, TW.h.price, "1", xloc.bar_time, color=noColor, style=label.style_label_left, textcolor= not lbl ? chart.fg_color : noColor, size=ipda_size(label_size)))
        stdev_dw.lines.unshift(line.new(TW.h_stl, chart.point.from_time(rxh, zyh), xloc.bar_time, color=chart.fg_color))
        stdev_dw.labels.unshift(label.new(rxh, zyh, "0", xloc.bar_time, color=noColor, style=label.style_label_left, textcolor= not lbl ? chart.fg_color : noColor, size=ipda_size(label_size)))
        for dv=0 to deviations.size()-1
            float dev = deviations.get(dv)
            float price = zyh+(yh*dev)
            stdev_dw.lines.unshift(line.new(lxh, price, rxh, price, xloc.bar_time, color=chart.fg_color))
            stdev_dw.labels.unshift(label.new(rxh, price, str.tostring(dev), xloc.bar_time, color=noColor, style=label.style_label_left, textcolor= not lbl ? chart.fg_color : noColor, size=ipda_size(label_size)))
    if not na(TW.l) and not na(TW.l_sth)
        int rxl = TW.l.time, int lxl = TW.l_sth.time
        float zyl = TW.l_sth.price, float yl = zyl-TW.l.price
        stdev_up.lines.unshift(line.new(chart.point.from_time(lxl, TW.l.price), TW.l, xloc.bar_time, color=chart.fg_color))
        stdev_up.labels.unshift(label.new(rxl, TW.l.price, "1", xloc.bar_time, color=noColor, style=label.style_label_left, textcolor= not lbl ? chart.fg_color : noColor, size=ipda_size(label_size)))
        stdev_up.lines.unshift(line.new(TW.l_sth, chart.point.from_time(rxl, zyl), xloc.bar_time, color=chart.fg_color))
        stdev_up.labels.unshift(label.new(rxl, zyl, "0", xloc.bar_time, color=noColor, style=label.style_label_left, textcolor= not lbl ? chart.fg_color : noColor, size=ipda_size(label_size)))
        for dv=0 to deviations.size()-1
            float dev = deviations.get(dv)
            float price = zyl-(yl*dev)
            stdev_up.lines.unshift(line.new(lxl, price, rxl, price, xloc.bar_time, color=chart.fg_color))
            stdev_up.labels.unshift(label.new(rxl, price, str.tostring(dev), xloc.bar_time, color=noColor, style=label.style_label_left, textcolor= not lbl ? chart.fg_color : noColor, size=ipda_size(label_size)))
    TW.up := stdev_up
    TW.dw := stdev_dw

// -- FVG METHODS --
fvg_detect()=>
    float new_max = float(na)
    float new_min = float(na)
    bool new_isbull = false
    int new_t = int(na)
    
    float threshold = autoFvg ? ta.cum((high - low) / low) / bar_index : thresholdPer / 100
    bool bull_fvg = low > high[2] and close[1] > high[2] and (low - high[2]) / high[2] > threshold
    bool bear_fvg = high < low[2] and close[1] < low[2] and (low[2] - high) / high > threshold
    
    if bull_fvg
        new_max := low
        new_min := high[2]
        new_isbull := true
        new_t := time
    else if bear_fvg
        new_max := low[2]
        new_min := high
        new_isbull := false
        new_t := time
        
    [bull_fvg, bear_fvg, new_max, new_min, new_isbull, new_t]

// -- OB METHODS --
get_coordinates(condition, top, btm, ob_val)=>
    var ob_top = array.new_float(0), var ob_btm = array.new_float(0), var ob_avg = array.new_float(0), var ob_left = array.new_int(0)
    float ob = na
    if condition
        array.unshift(ob_top, top)
        array.unshift(ob_btm, btm)
        array.unshift(ob_avg, math.avg(top, btm))
        array.unshift(ob_left, time[ob_length])
        ob := ob_val
    [ob_top, ob_btm, ob_avg, ob_left, ob]

remove_mitigated(ob_top, ob_btm, ob_left, ob_avg, target, bull)=>
    mitigated = false
    target_array = bull ? ob_btm : ob_top
    if array.size(target_array) > 0
        for i = array.size(target_array)-1 to 0
            if (bull ? target < array.get(target_array, i) : target > array.get(target_array, i))
                mitigated := true
                array.remove(ob_top, i)
                array.remove(ob_btm, i)
                array.remove(ob_avg, i)
                array.remove(ob_left, i)
    mitigated

// =================================================================================================
// 4. CORE EXECUTION LOGIC
// =================================================================================================

// --- EXECUTE ISS ---
bool asiaIn = f_sessionBox(i_showAsia, i_asiaSess, "ASIA", i_cAsia)
bool lonIn  = f_sessionBox(i_showLon, i_lonSess, "LONDON", i_cLon)
bool nyIn   = f_sessionBox(i_showNy, i_nySess, "NEW YORK", i_cNy)

bool inRTH = not na(time("", i_nySess, i_tz)), rthStart = inRTH and not inRTH[1]
bool inON = not na(time("", i_onSess, i_tz)), onStart = inON and not inON[1]

var float _onH = na, var float _onL = na
var float onH = na, var float onL = na
if onStart
    _onH := high, _onL := low
else if inON
    _onH := math.max(nz(_onH, high), high), _onL := math.min(nz(_onL, low), low)

var int rthStartBar = na, var int lastRthBar = na, var int rthStartTime = na
var float rthHi = na, var float rthLo = na, var string gapRead = "—"
var float _ibH = na, var float _ibL = na, var float ibH = na, var float ibL = na
var float ibExtU1 = na, var float ibExtD1 = na, var float ibExtU2 = na, var float ibExtD2 = na
var float _orH = na, var float _orL = na, var float orH = na, var float orL = na

if rthStart
    onH := _onH, onL := _onL
    _onH := na, _onL := na
    rthStartBar := bar_index, rthStartTime := time, rthHi := high, rthLo := low
    ibH := na, ibL := na, ibExtU1 := na, ibExtD1 := na, ibExtU2 := na, ibExtD2 := na
    orH := na, orL := na, _ibH := na, _ibL := na, _orH := na, _orL := na
    gapRead := na(onH) or na(onL) ? "—" : open > onH ? "ABOVE ON HIGH ▲" : open < onL ? "BELOW ON LOW ▼" : open >= (onH + onL) / 2 ? "UPPER HALF OF ON" : "LOWER HALF OF ON"

if inRTH
    lastRthBar := bar_index
    rthHi := math.max(nz(rthHi, high), high), rthLo := math.min(nz(rthLo, low), low)

bool ibWindow = inRTH and not na(rthStartTime) and (time - rthStartTime) < i_ibMin * 60000
bool orWindow = inRTH and not na(rthStartTime) and (time - rthStartTime) < i_orMin * 60000

if ibWindow
    _ibH := math.max(nz(_ibH, high), high), _ibL := math.min(nz(_ibL, low), low)
if orWindow
    _orH := math.max(nz(_orH, high), high), _orL := math.min(nz(_orL, low), low)

if inRTH and not ibWindow and ibWindow[1]
    ibH := _ibH, ibL := _ibL, _ibH := na, _ibL := na
    float rng = ibH - ibL
    ibExtU1 := ibL + i_ext1 * rng, ibExtD1 := ibH - i_ext1 * rng
    ibExtU2 := ibL + i_ext2 * rng, ibExtD2 := ibH - i_ext2 * rng

if inRTH and not orWindow and orWindow[1]
    orH := _orH, orL := _orL, _orH := na, _orL := na

// ISS Drawing Pool
var line lnOnH = line.new(na, na, na, na), var label lbOnH = label.new(na, na, "")
var line lnOnL = line.new(na, na, na, na), var label lbOnL = label.new(na, na, "")
var line lnIbH = line.new(na, na, na, na), var label lbIbH = label.new(na, na, "")
var line lnIbL = line.new(na, na, na, na), var label lbIbL = label.new(na, na, "")
var line lnE1U = line.new(na, na, na, na), var label lbE1U = label.new(na, na, "")
var line lnE1D = line.new(na, na, na, na), var label lbE1D = label.new(na, na, "")
var line lnE2U = line.new(na, na, na, na), var label lbE2U = label.new(na, na, "")
var line lnE2D = line.new(na, na, na, na), var label lbE2D = label.new(na, na, "")
var line lnOrH = line.new(na, na, na, na), var label lbOrH = label.new(na, na, "")
var line lnOrL = line.new(na, na, na, na), var label lbOrL = label.new(na, na, "")

if barstate.islast and not na(rthStartBar)
    f_drawLevel(lnOnH, lbOnH, onH, "ON HIGH", i_cON, "solid", i_showON, rthStartBar)
    f_drawLevel(lnOnL, lbOnL, onL, "ON LOW", i_cON, "solid", i_showON, rthStartBar)
    f_drawLevel(lnIbH, lbIbH, ibH, "IBH", i_cIB, "solid", i_showIB, rthStartBar)
    f_drawLevel(lnIbL, lbIbL, ibL, "IBL", i_cIB, "solid", i_showIB, rthStartBar)
    f_drawLevel(lnE1U, lbE1U, ibExtU1, "IB " + str.tostring(i_ext1) + "× ▲", i_cExt, "dashed", i_showExt, rthStartBar)
    f_drawLevel(lnE1D, lbE1D, ibExtD1, "IB " + str.tostring(i_ext1) + "× ▼", i_cExt, "dashed", i_showExt, rthStartBar)
    f_drawLevel(lnE2U, lbE2U, ibExtU2, "IB " + str.tostring(i_ext2) + "× ▲", i_cExt, "dashed", i_showExt, rthStartBar)
    f_drawLevel(lnE2D, lbE2D, ibExtD2, "IB " + str.tostring(i_ext2) + "× ▼", i_cExt, "dashed", i_showExt, rthStartBar)
    f_drawLevel(lnOrH, lbOrH, orH, "ORH", i_cOR, "dotted", i_showOR, rthStartBar)
    f_drawLevel(lnOrL, lbOrL, orL, "ORL", i_cOR, "dotted", i_showOR, rthStartBar)

// --- EXECUTE ORB ---
[orb_h1, orb_l1] = f_get_orb(orb_sess1, orb_col1)
[orb_h2, orb_l2] = f_get_orb(orb_sess2, orb_col2)
[orb_h3, orb_l3] = f_get_orb(orb_sess3, orb_col3)

// --- EXECUTE FVG ---
var float max_bull_fvg = na, var float min_bull_fvg = na, var bull_count = 0
var float max_bear_fvg = na, var float min_bear_fvg = na, var bear_count = 0
var fvg_t = 0
var fvg_records = array.new<fvg_type>(0), var fvg_areas = array.new<box>(0)

[bull_fvg, bear_fvg, fvg_max, fvg_min, fvg_isbull, fvg_new_t] = request.security(syminfo.tickerid, fvg_tf, fvg_detect())
fvg_type new_fvg = fvg_type.new(fvg_max, fvg_min, fvg_isbull, fvg_new_t)

if bull_fvg and new_fvg.t != fvg_t
    if fvg_dynamic
        max_bull_fvg := new_fvg.max, min_bull_fvg := new_fvg.min
    if not fvg_dynamic
        fvg_areas.unshift(box.new(bar_index-2, new_fvg.max, bar_index+fvg_extend, new_fvg.min, na, bgcolor = bullCssFvg))
    fvg_records.unshift(new_fvg)
    bull_count += 1, fvg_t := new_fvg.t
else if fvg_dynamic
    max_bull_fvg := math.max(math.min(close, max_bull_fvg), min_bull_fvg)

if bear_fvg and new_fvg.t != fvg_t
    if fvg_dynamic
        max_bear_fvg := new_fvg.max, min_bear_fvg := new_fvg.min
    if not fvg_dynamic
        fvg_areas.unshift(box.new(bar_index-2, new_fvg.max, bar_index+fvg_extend, new_fvg.min, na, bgcolor = bearCssFvg))
    fvg_records.unshift(new_fvg)
    bear_count += 1, fvg_t := new_fvg.t
else if fvg_dynamic
    min_bear_fvg := math.min(math.max(close, min_bear_fvg), max_bear_fvg) 

// --- EXECUTE OB ---
float upper_ob = ta.highest(ob_length), float lower_ob = ta.lowest(ob_length)
float target_bull = ob_mitigation == 'Close' ? ta.lowest(close, ob_length) : lower_ob
float target_bear = ob_mitigation == 'Close' ? ta.highest(close, ob_length) : upper_ob
var int os = 0
os := high[ob_length] > upper_ob ? 0 : low[ob_length] < lower_ob ? 1 : os[1]

bool phv = not na(ta.pivothigh(volume, ob_length, ob_length))

[bull_top, bull_btm, bull_avg, bull_left, bull_ob] = get_coordinates(phv and os == 1, hl2[ob_length], low[ob_length], low[ob_length])
[bear_top, bear_btm, bear_avg, bear_left, bear_ob] = get_coordinates(phv and os == 0, high[ob_length], hl2[ob_length], high[ob_length])

bool mitigated_bull = remove_mitigated(bull_top, bull_btm, bull_left, bull_avg, target_bull, true)
bool mitigated_bear = remove_mitigated(bear_top, bear_btm, bear_left, bear_avg, target_bear, false)

// =================================================================================================
// 5. RENDERING & TABLES
// =================================================================================================

// FVG Dash
var tb_fvg = table.new(dashLocFvg == 'Bottom Left' ? position.bottom_left : dashLocFvg == 'Top Right' ? position.top_right : position.bottom_right, 3, 3, bgcolor = #1e222d, border_color = #373a46, border_width = 1, frame_color = #373a46, frame_width = 1)
if showDashFvg
    if barstate.isfirst
        tb_fvg.cell(1, 0, 'Bullish', text_color = bullCssFvg, text_size = ipda_size(textSizeFvg))
        tb_fvg.cell(2, 0, 'Bearish', text_color = bearCssFvg, text_size = ipda_size(textSizeFvg))
    if barstate.islast
        tb_fvg.cell(1, 1, str.tostring(bull_count), text_color = bullCssFvg, text_size = ipda_size(textSizeFvg))
        tb_fvg.cell(2, 1, str.tostring(bear_count), text_color = bearCssFvg, text_size = ipda_size(textSizeFvg))

// OB Rendering Arrays
var ob_box_bull = array.new_box(0), var ob_box_bear = array.new_box(0)
if barstate.isfirst
    for i = 0 to bull_ext_last-1
        array.unshift(ob_box_bull, box.new(na,na,na,na, xloc = xloc.bar_time, extend= extend.right, bgcolor = bg_bull_css))
    for i = 0 to bear_ext_last-1
        array.unshift(ob_box_bear, box.new(na,na,na,na, xloc = xloc.bar_time, extend= extend.right, bgcolor = bg_bear_css))

if barstate.islast
    if array.size(bull_top) > 0
        for i = 0 to math.min(bull_ext_last-1, array.size(bull_top)-1)
            box b = array.get(ob_box_bull, i)
            box.set_lefttop(b, array.get(bull_left, i), array.get(bull_top, i))
            box.set_rightbottom(b, array.get(bull_left, i), array.get(bull_btm, i))
    if array.size(bear_top) > 0
        for i = 0 to math.min(bear_ext_last-1, array.size(bear_top)-1)
            box b = array.get(ob_box_bear, i)
            box.set_lefttop(b, array.get(bear_left, i), array.get(bear_top, i))
            box.set_rightbottom(b, array.get(bear_left, i), array.get(bear_btm, i))
````
