# Liquidity & Structure Toolkit [erdensedat] 

- url: https://www.tradingview.com/script/2lmG5Oi3-Liquidity-Structure-Toolkit-erdensedat/
- type: indicator
- pine_id: PUB;3b6955c6c6ec42ea944671c737ef2a9e
- version: 1.0

## Description

The Liquidity & Structure Toolkit is a comprehensive, all-in-one indicator designed for Smart Money Concepts (SMC), Volume Profile analysis, and overall market structure tracking. It aims to provide traders with a clear visual representation of liquidity zones, structural breaks, session balances, and high-volume nodes without cluttering the chart.

Below is a detailed breakdown of all the features, the math and logic behind the setups, the signal engine, and the alert systems included in this script.

1. Major Targets (Liquidity Pools - BSL/SSL)
The script identifies major structural high and low points that act as liquidity magnets (Buy Side Liquidity - BSL and Sell Side Liquidity - SSL).

Formula & Logic: It uses the ta.pivothigh() and ta.pivotlow() functions. A "Major Target" is confirmed only when the price forms a peak/valley with a user-defined Pivot Sensitivity (default is 10 bars on the left and right).
Visualization: When a major pivot is formed, a horizontal line and a label ("MAJOR BSL" or "MAJOR SSL") are drawn.
Sweep Mechanics: If the price crosses this level later, the level is considered "swept." The solid line turns into a dashed line with lower opacity, indicating that the liquidity has been taken. Swept levels are automatically removed after 24 hours to keep the chart clean.
2. Market Structure Breaks (BOS / CHoCH)
This module tracks internal and external structural shifts based on fractal highs and lows.

Logic: It calculates short-term pivots using a fractal length (default 5). When the price breaks above a recent pivot high, it's considered an upward break. When it breaks below a pivot low, it's a downward break.
BOS vs. CHoCH: The script intelligently labels the breaks based on the previous trend state. If the trend continues (e.g., up break followed by another up break), it labels it as BOS (Break of Structure). If the direction shifts (e.g., down break followed by an up break), it labels it as CHoCH (Change of Character).
Settings: You can choose whether a break requires a candle close beyond the level (Break = Close Beyond Level) or just a wick.
3. Initial Balance (IB) Box
The Initial Balance represents the price range established during the first specified minutes of a new trading session.

Setup: You define the Session Timeframe (e.g., Daily) and the IB Duration (e.g., the first 60 minutes).
Logic: The script tracks the highest high (IBH) and lowest low (IBL) during that initial window. Once the time window closes, the box extends to the right, serving as a dynamic support/resistance zone for the rest of the session.
Visualization: Highlights the IB High, IB Low, and IB Equilibrium (Midpoint) with clean labels and a customizable background box.
4. Volume Profile & POC Box (Point of Control)
A custom Volume Profile engine that calculates the highest volume node (POC) dynamically using lower timeframe data.

Lower Timeframe (LTF) Data: The script automatically fetches lower timeframe volume data (1m, 5m, 15m, or 60m depending on your chart's timeframe) to build an accurate profile inside a custom array matrix.
Rows/Bins: The session range is divided into horizontal bins (default 60). Volume is distributed among these bins based on where the LTF candles traded.
POC Engine Models:
Model 1 (Active POC): Displays the active, evolving POC of the current session as well as historical POCs from previous sessions. Uses a Hysteresis percentage (default 15%) to prevent the POC line from flickering rapidly; the new volume node must exceed the old POC by X% to shift the level.
Model 2 (Previous POC Focus): Instead of showing the actively changing current POC, it projects the finalized POC from the previous session starting from its original birth point, extending it across the current session as a heavy structural magnet.
Delta Lines: Inside the POC box, it plots the highest volume node and its immediate neighboring nodes (top, mid, bot) to show the thickness of the volume cluster.
5. Price Action & MSB Signal Engine
The script includes an automated signal engine that identifies highly probable reversal setups around the liquidity zones.

Price Action (PA) Signals: Triggered when the price "touches" or sweeps a Major BSL or SSL level, and subsequently prints a valid directional candle (e.g., sweeping SSL and printing a solid green candle that is not a Doji).
MSB (Market Structure Break) Signals: Triggered when the price sweeps a major liquidity level (BSL/SSL) and then creates a confirmed structural break (BOS/CHoCH) in the opposite direction.
Visualization: Triangle shapes are plotted above/below the signal candles (Green for Buy, Red for Sell).
6. Moving Averages & VWAP
For trend filtering and dynamic support/resistance, the toolkit includes optional traditional indicators:

VWAP: Session-based Volume Weighted Average Price.
Customizable MAs: Up to 5 moving averages can be toggled on/off. Supported types include SMA, EMA, WMA, HMA, and VWMA. Each can have its own length and color settings.
7. Alerts System
The indicator features a built-in alert system for the signal engine.

PA Signal Alert: Fires whenever a valid Price Action bounce occurs at a BSL/SSL level.
MSB Signal Alert: Fires whenever a structural reversal is confirmed after a liquidity sweep.
How to use: Create an alert in TradingView, select this indicator, and choose "Any alert() function call".
Disclaimer
This indicator is for educational and analytical purposes only. It does not constitute financial advice or a recommendation to buy or sell any asset. Past performance is not indicative of future results. Trading cryptocurrencies, forex, and stocks carries a high level of risk. Always perform your own backtesting, use proper risk management, and consult with a certified financial advisor before making any trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Liquidity & Structure Toolkit [erdensedat] ", overlay = true, max_bars_back = 5000, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// --- Watermark ---
var table wm = table.new(position.bottom_right, 1, 1)
if barstate.isfirst
    table.cell(wm, 0, 0, "erdensedat", text_color = color.new(color.gray, 70), text_size = size.large)

// --- Settings: Major Targets ---
const string G_MT = "Major Targets Settings"
int sensitivity = input.int(10, "Pivot Sensitivity (Confirmation Bars)", minval = 2, group = G_MT, tooltip = "Number of lower/higher bars required on left and right to confirm a major swing pivot.")
int maxActive   = input.int(15, "Max Active Levels", minval = 1, group = G_MT)
int labelOffset = input.int(8, "Label Offset (Bars)", minval = 0, group = G_MT)
string lblSizeStr = input.string("Small", "Target Label Size", options=["Tiny", "Small", "Normal", "Large"], group = G_MT)

color bearCol   = input.color(color.new(#f23645, 10), "Major High (BSL) Color", inline = "high", group = G_MT)
color bullCol   = input.color(color.new(#089981, 10), "Major Low (SSL) Color", inline = "low", group = G_MT)

get_lbl_size(string sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

// --- Settings: BLVL (BOS/CHoCH) ---
const string G_BLVL = "BLVL - BOS / CHoCH"
bool  showBlvl     = input.bool(true, "Show BOS / CHoCH", group=G_BLVL)
int   blvlLen      = input.int(5, "Fractal Length (odd)", minval=3, maxval=51, group=G_BLVL)
bool  blvlReqBody  = input.bool(true, "Break = Close Beyond Level", group=G_BLVL)
int   blvlShowLast = input.int(10, "Show Last N Broken (0=all)", minval=0, maxval=5000, group=G_BLVL)
color blvlUpCol    = input.color(color.rgb(8,153,129), "Broken UP Color", group=G_BLVL)
color blvlDnCol    = input.color(color.new(color.red, 0), "Broken DN Color", group=G_BLVL)
int   blvlWidth    = input.int(1, "Broken Width", minval=1, maxval=5, group=G_BLVL)
string blvlStyleStr= input.string("Solid", "Broken Style", options=["Solid","Dashed","Dotted"], group=G_BLVL)
string blvlLblSz   = input.string("tiny", "Label Size", options=["tiny","small","normal"], group=G_BLVL)
color blvlLblBg    = input.color(color.new(color.white, 100), "Label Bg", group=G_BLVL)

f_ls(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
f_sz(string s) => s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

// --- Settings: Signals & Alerts ---
const string G_SIG = "Signals & Alerts"
bool showPaSigs  = input.bool(true, "Show Price Action Triangles", group=G_SIG)
bool showMsbSigs = input.bool(true, "Show MSB Triangles", group=G_SIG)

// --- Settings: IB Box ---
const string G_IB = "Initial Balance (IB) Settings"
bool    show_ib      = input.bool(true, "Show Active IB Range", group=G_IB)
int     ib_mins      = input.int(60, "IB Duration (Minutes)", group=G_IB)
color   ib_col       = input.color(color.new(#00e2ff, 85), "IB Box Color", group=G_IB)
bool    show_ib_mid  = input.bool(true, "Show IB Mid Line (Dashed)", group=G_IB)
bool    show_ib_lbl  = input.bool(true, "Show IB Labels", group=G_IB)
string  ib_lbl_sz    = input.string("Normal", "IB Label Size", options=["Tiny", "Small", "Normal", "Large"], group=G_IB)
string  tf           = input.timeframe("1D", "Session Timeframe", group=G_IB)

// --- Settings: VP POC Box ---
const string G_VP = "Volume Profile & POC Box Settings"
string  pocModel     = input.string("Model 2: Previous POC Focus", "POC Engine Model", options=["Model 1: Active POC", "Model 2: Previous POC Focus"], group=G_VP, tooltip="Model 1: Shows Active and (optional) Previous POC. Model 2: Projects the previous session's POC onto the current session (hiding the active changing POC).")
bool    show_poc_box = input.bool(true, "Show Active POC Area Box (Model 1 only)", group=G_VP)
int     show_last_n_pocs = input.int(1, "Show Last N Previous POCs", minval=0, maxval=10, group=G_VP)
string  poc_tf       = input.timeframe("240", "POC Anchor Timeframe", group=G_VP)
int     rows         = input.int(60, "Profile Bins (Rows)", minval=10, maxval=200, group=G_VP)
float   poc_hysteresis = input.float(15.0, "POC Shift Tolerance (%)", minval=0.0, maxval=100.0, step=1.0, group=G_VP, tooltip="Requires the new POC to have X% more volume than the current POC to shift.")
int     poc_bars_right = input.int(2, "Box & Line Extension (Bars Right)", minval=0, group=G_VP)
color   poc_box_col  = input.color(#78a0ff, "Active POC Color", group=G_VP)
color   prev_poc_box_col = input.color(#5272be, "Previous POC Color", group=G_VP)
color   poc_line_up_col = input.color(#69ff6f, "POC Line Up Color", group=G_VP)
color   poc_line_dn_col = input.color(#ff3030, "POC Line Down Color", group=G_VP)
bool    show_lbl     = input.bool(true, "Show POC Label", group=G_VP)

// --- Settings: Moving Averages ---
const string G_MA = "Moving Averages"
bool showVwap   = input.bool(false, "Show VWAP", group = G_MA)

string ma1_type = input.string("None", "MA 1 Type", options=["None", "SMA", "EMA", "WMA", "HMA", "VWMA"], inline="ma1", group = G_MA)
int    ma1_len  = input.int(20, "Length", inline="ma1", group = G_MA)
color  ma1_col  = input.color(color.blue, "", inline="ma1", group = G_MA)

string ma2_type = input.string("None", "MA 2 Type", options=["None", "SMA", "EMA", "WMA", "HMA", "VWMA"], inline="ma2", group = G_MA)
int    ma2_len  = input.int(50, "Length", inline="ma2", group = G_MA)
color  ma2_col  = input.color(color.purple, "", inline="ma2", group = G_MA)

string ma3_type = input.string("None", "MA 3 Type", options=["None", "SMA", "EMA", "WMA", "HMA", "VWMA"], inline="ma3", group = G_MA)
int    ma3_len  = input.int(100, "Length", inline="ma3", group = G_MA)
color  ma3_col  = input.color(color.orange, "", inline="ma3", group = G_MA)

string ma4_type = input.string("None", "MA 4 Type", options=["None", "SMA", "EMA", "WMA", "HMA", "VWMA"], inline="ma4", group = G_MA)
int    ma4_len  = input.int(200, "Length", inline="ma4", group = G_MA)
color  ma4_col  = input.color(color.red, "", inline="ma4", group = G_MA)

string ma5_type = input.string("None", "MA 5 Type", options=["None", "SMA", "EMA", "WMA", "HMA", "VWMA"], inline="ma5", group = G_MA)
int    ma5_len  = input.int(200, "Length", inline="ma5", group = G_MA)
color  ma5_col  = input.color(color.green, "", inline="ma5", group = G_MA)


// ============================================================================
// 📊 DATA FETCHING (Dynamic LTF for Profile)
// ============================================================================
string dynamic_ltf = timeframe.isseconds ? "1" : timeframe.isintraday ? (timeframe.multiplier <= 15 ? "1" : timeframe.multiplier <= 60 ? "5" : timeframe.multiplier <= 240 ? "15" : "60") : timeframe.isdaily ? "60" : "240"
[ltf_o, ltf_h, ltf_l, ltf_c, ltf_v] = request.security_lower_tf(syminfo.tickerid, dynamic_ltf, [open, high, low, close, volume])

// ============================================================================
// 🧠 IB LOGIC
// ============================================================================
bool is_tf_change = ta.change(time(tf)) != 0
bool is_new_session = is_tf_change

var int session_start_time = na
if is_new_session
    session_start_time := time

var float ib_high = na
var float ib_low  = na
var box   ib_box  = box.new(na, na, na, na, xloc=xloc.bar_time, bgcolor=ib_col, border_color=na)
var line  ib_mid  = line.new(na, na, na, na, xloc=xloc.bar_time, color=color.new(chart.fg_color, 40), style=line.style_dashed)
var label ib_h_lbl = label.new(na, na, "IBH", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=color.new(chart.fg_color, 40), style=label.style_label_down, size=size.small)
var label ib_l_lbl = label.new(na, na, "IBL", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=color.new(chart.fg_color, 40), style=label.style_label_up, size=size.small)
var label ib_eq_lbl = label.new(na, na, "IBEQ", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=color.new(chart.fg_color, 40), style=label.style_label_left, size=size.small)

if is_new_session
    ib_high := high
    ib_low  := low
else if not na(session_start_time) and time < session_start_time + (ib_mins * 60 * 1000)
    ib_high := math.max(ib_high, high)
    ib_low  := math.min(ib_low, low)

if show_ib and not na(ib_high)
    float mid_val = math.avg(ib_high, ib_low)
    if is_new_session
        box.delete(ib_box)
        ib_box := box.new(session_start_time, ib_high, time, ib_low, xloc=xloc.bar_time, bgcolor=ib_col, border_color=na)
        if show_ib_mid
            line.delete(ib_mid)
            ib_mid := line.new(session_start_time, mid_val, time, mid_val, xloc=xloc.bar_time, color=color.new(chart.fg_color, 40), style=line.style_dashed)
    else
        box.set_right(ib_box, time)
        box.set_top(ib_box, ib_high)
        box.set_bottom(ib_box, ib_low)
        if show_ib_mid
            line.set_xy1(ib_mid, session_start_time, mid_val)
            line.set_xy2(ib_mid, time, mid_val)
        
    if show_ib_lbl
        label.set_xy(ib_h_lbl, time, ib_high)
        label.set_xy(ib_l_lbl, time, ib_low)
        label.set_xy(ib_eq_lbl, time, mid_val)
        label.set_size(ib_h_lbl, get_lbl_size(ib_lbl_sz))
        label.set_size(ib_l_lbl, get_lbl_size(ib_lbl_sz))
        label.set_size(ib_eq_lbl, get_lbl_size(ib_lbl_sz))
    else
        label.set_xy(ib_h_lbl, na, na)
        label.set_xy(ib_l_lbl, na, na)
        label.set_xy(ib_eq_lbl, na, na)
else
    box.set_lefttop(ib_box, na, na)
    box.set_rightbottom(ib_box, na, na)
    line.set_xy1(ib_mid, na, na)
    line.set_xy2(ib_mid, na, na)
    label.set_xy(ib_h_lbl, na, na)
    label.set_xy(ib_l_lbl, na, na)
    label.set_xy(ib_eq_lbl, na, na)

// ============================================================================
// 🧠 BLVL (BOS/CHoCH) LOGIC
// ============================================================================
int L_blvl = (blvlLen % 2 == 0) ? (blvlLen + 1) : blvlLen
int p_blvl = int(L_blvl / 2)

float phVal = ta.pivothigh(high, p_blvl, p_blvl)
float plVal = ta.pivotlow(low,  p_blvl, p_blvl)

var float upLvl = na
var int   upT   = na
var bool  upBroken = false

var float dnLvl = na
var int   dnT   = na
var bool  dnBroken = false

var int os = 0  // last break direction: +1 up, -1 down, 0 none

var line[]  brkLines = array.new_line()
var label[] brkLabs  = array.new_label()

f_trimBroken() =>
    if blvlShowLast > 0
        while array.size(brkLines) > blvlShowLast
            line oldLn = array.shift(brkLines)
            label oldLb = array.shift(brkLabs)
            if not na(oldLn)
                line.delete(oldLn)
            if not na(oldLb)
                label.delete(oldLb)

f_pushBroken(line ln, label lb) =>
    array.push(brkLines, ln)
    array.push(brkLabs,  lb)
    f_trimBroken()

if not na(phVal)
    upLvl := phVal
    upT   := time[p_blvl]
    upBroken := false

if not na(plVal)
    dnLvl := plVal
    dnT   := time[p_blvl]
    dnBroken := false

bool brkUp = false
bool brkDn = false

if not na(upLvl) and not upBroken
    brkUp := blvlReqBody ? close > upLvl : high > upLvl

if not na(dnLvl) and not dnBroken
    brkDn := blvlReqBody ? close < dnLvl : low < dnLvl

if brkUp
    upBroken := true
    if showBlvl
        line ln = line.new(upT, upLvl, time, upLvl, xloc=xloc.bar_time, color=blvlUpCol, style=f_ls(blvlStyleStr), width=blvlWidth)
        string txt = os == -1 ? "CHoCH" : "BOS"
        label lb = label.new(int(math.avg(time, upT)), upLvl, txt, xloc=xloc.bar_time, style=label.style_label_down, textcolor=blvlUpCol, color=blvlLblBg, size=f_sz(blvlLblSz))
        f_pushBroken(ln, lb)
    os := 1

if brkDn
    dnBroken := true
    if showBlvl
        line ln = line.new(dnT, dnLvl, time, dnLvl, xloc=xloc.bar_time, color=blvlDnCol, style=f_ls(blvlStyleStr), width=blvlWidth)
        string txt = os == 1 ? "CHoCH" : "BOS"
        label lb = label.new(int(math.avg(time, dnT)), dnLvl, txt, xloc=xloc.bar_time, style=label.style_label_up, textcolor=blvlDnCol, color=blvlLblBg, size=f_sz(blvlLblSz))
        f_pushBroken(ln, lb)
    os := -1


// ============================================================================
// --- UDT & MAJOR TARGETS ---
// ============================================================================
type PivotLine
    line  ln
    label lb
    float price
    int   startTime
    int   startBarIndex
    bool  isHigh
    bool  isSwept
    int   sweepTime

var PivotLine[] pivotLines = array.new<PivotLine>()

[ph, pl, pt] = request.security(syminfo.tickerid, "60", [ta.pivothigh(high, sensitivity, sensitivity), ta.pivotlow(low, sensitivity, sensitivity), time[sensitivity]], lookahead = barmerge.lookahead_on)

add_major_pivot(pPrice, pTime, isH) =>
    if not na(pPrice)
        bool exists = false
        if array.size(pivotLines) > 0
            for i = 0 to math.min(array.size(pivotLines) - 1, 30)
                p = array.get(pivotLines, i)
                if p.startTime == pTime
                    exists := true
                    break
        
        if not exists
            color c = isH ? bearCol : bullCol
            string priceStr = str.tostring(pPrice, format.mintick)
            string txt = isH ? ("MAJOR BSL " + priceStr) : ("MAJOR SSL " + priceStr)
            int barMili = int(math.max(time - time[1], 1))
            line l = line.new(pTime, pPrice, time, pPrice, xloc.bar_time, color = c, width = 1)
            label lbl = label.new(time + (barMili * labelOffset), pPrice, txt, xloc.bar_time, textcolor = c, style = label.style_label_left, color = #00000000, size = get_lbl_size(lblSizeStr))
            array.unshift(pivotLines, PivotLine.new(l, lbl, pPrice, pTime, bar_index - sensitivity, isH, false, na))

if not na(ph)
    add_major_pivot(ph, pt, true)
if not na(pl)
    add_major_pivot(pl, pt, false)

if array.size(pivotLines) > 0
    int barMili = int(math.max(time - time[1], 1))
    for i = array.size(pivotLines) - 1 to 0
        p = array.get(pivotLines, i)
        
        if not p.isSwept
            line.set_x2(p.ln, time)
            label.set_x(p.lb, time + (barMili * labelOffset))
            
            bool swept = p.isHigh ? high > p.price : low < p.price
            if swept
                p.isSwept := true
                p.sweepTime := time
                line.set_style(p.ln, line.style_dashed)
                line.set_color(p.ln, color.new(p.isHigh ? bearCol : bullCol, 75))
                label.set_textcolor(p.lb, color.new(p.isHigh ? bearCol : bullCol, 75))
                line.set_x2(p.ln, time)
                label.set_x(p.lb, time + (barMili * labelOffset))
        
        bool expired = p.isSwept and (time - p.sweepTime) > 86400000
        bool tooMany = not p.isSwept and i > maxActive
        
        if expired or tooMany
            line.delete(p.ln)
            label.delete(p.lb)
            array.remove(pivotLines, i)

// ============================================================================
// 🧠 PRICE ACTION & MSB SIGNAL ENGINE
// ============================================================================
bool touchSSL = false
bool touchBSL = false
bool anyTouchSSL = false
bool anyTouchBSL = false

if array.size(pivotLines) > 0
    for i = 0 to array.size(pivotLines) - 1
        p = array.get(pivotLines, i)
        bool active = not p.isSwept or (p.isSwept and p.sweepTime == time)
        
        if active
            if p.isHigh
                if high >= p.price
                    anyTouchBSL := true
                    if close < p.price
                        touchBSL := true
            else
                if low <= p.price
                    anyTouchSSL := true
                    if close > p.price
                        touchSSL := true

// Price Action Evaluation - Reliable Historical Lookback (No var states for signals to avoid repainting)
bool isDoji = math.abs(close - open) <= (high - low) * 0.15
bool validGreen = close > open and not isDoji
bool validRed   = close < open and not isDoji

int barsSinceSSL = ta.barssince(touchSSL)
int barsSinceBSL = ta.barssince(touchBSL)

bool paBuySig = false
bool paSellSig = false

if touchSSL and validGreen
    paBuySig := true
else if barsSinceSSL > 0 and barsSinceSSL <= 10 and validGreen
    bool firstValid = true
    for j = 1 to barsSinceSSL
        if close[j] > open[j] and not (math.abs(close[j] - open[j]) <= (high[j] - low[j]) * 0.15)
            firstValid := false
            break
    if firstValid
        paBuySig := true

if touchBSL and validRed
    paSellSig := true
else if barsSinceBSL > 0 and barsSinceBSL <= 10 and validRed
    bool firstValid = true
    for j = 1 to barsSinceBSL
        if close[j] < open[j] and not (math.abs(close[j] - open[j]) <= (high[j] - low[j]) * 0.15)
            firstValid := false
            break
    if firstValid
        paSellSig := true

// MSB Break Evaluation
var int lastBouncedFrom = 0

if anyTouchSSL
    lastBouncedFrom := 1
if anyTouchBSL
    lastBouncedFrom := -1

bool msbBuySig = false
bool msbSellSig = false

if brkUp and lastBouncedFrom == 1
    msbBuySig := true
    lastBouncedFrom := 0

if brkDn and lastBouncedFrom == -1
    msbSellSig := true
    lastBouncedFrom := 0

// PLOTTING SIGNALS
plotshape(showPaSigs and paBuySig, "PA Buy", shape.triangleup, location.belowbar, color=color.rgb(8,153,129), size=size.small, offset=0)
plotshape(showPaSigs and paSellSig, "PA Sell", shape.triangledown, location.abovebar, color=color.rgb(242,54,69), size=size.small, offset=0)

plotshape(showMsbSigs and msbBuySig, "MSB Buy", shape.triangleup, location.belowbar, color=color.rgb(8,153,129), size=size.small, offset=0)
plotshape(showMsbSigs and msbSellSig, "MSB Sell", shape.triangledown, location.abovebar, color=color.rgb(242,54,69), size=size.small, offset=0)

// ALERTS
alertcondition(paBuySig or paSellSig, "Price Action Signal", "PA Signal Triggered (Buy/Sell)")
alertcondition(msbBuySig or msbSellSig, "Market Structure Break Signal", "MSB Signal Triggered (Buy/Sell)")


// ============================================================================
// 🛠️ PROFILE BUILDER METHOD (FOR POC BOX)
// ============================================================================
var array<float> vol_bins = array.new<float>()

var array<box>   poc_boxes = array.new<box>()
var array<label> poc_labels = array.new<label>()
var array<line>  poc_lines  = array.new<line>()

type PocSessionData
    int start_time
    int end_time
    int start_bar
    int end_bar

var array<PocSessionData> poc_history = array.new<PocSessionData>()

method render_poc_box(int calc_start_b, int calc_end_b, int draw_start_t, int draw_end_t, bool is_prev, color b_col, string txt) =>
    int offset_start = math.min(bar_index - calc_start_b, bar_index)
    int offset_end   = math.max(bar_index - calc_end_b, 0)
    
    if offset_start >= offset_end and offset_start < 4999
        // Custom Highest/Lowest loop
        float s_high = na
        float s_low  = na
        for b_idx = offset_end to offset_start
            float h_val = high[b_idx]
            float l_val = low[b_idx]
            if na(s_high) or h_val > s_high
                s_high := h_val
            if na(s_low) or l_val < s_low
                s_low := l_val

        if not na(s_high) and not na(s_low) and s_high != s_low
            array.clear(vol_bins)
            for idx_loop = 0 to rows - 1
                vol_bins.push(0.0)
            
            float bin_size = (s_high - s_low) / rows
            bin_size := bin_size == 0 ? syminfo.mintick : bin_size

            for b_idx = offset_end to offset_start
                array<float> ltf_v_arr = ltf_v[b_idx]
                array<float> ltf_h_arr = ltf_h[b_idx]
                array<float> ltf_l_arr = ltf_l[b_idx]
                
                if not na(ltf_v_arr) and ltf_v_arr.size() > 0
                    for k = 0 to ltf_v_arr.size() - 1
                        float v = ltf_v_arr.get(k)
                        float h = ltf_h_arr.get(k)
                        float l = ltf_l_arr.get(k)
                        
                        int start_idx = math.max(0, math.min(rows - 1, int((l - s_low) / bin_size)))
                        int end_idx = math.max(0, math.min(rows - 1, int((h - s_low) / bin_size)))
                        int bins_spanned = math.max(1, end_idx - start_idx + 1)
                        float v_per_bin = v / bins_spanned
                        
                        for idx = start_idx to end_idx
                            vol_bins.set(idx, vol_bins.get(idx) + v_per_bin)
                else
                    float v = volume[b_idx]
                    float h = high[b_idx]
                    float l = low[b_idx]
                    
                    int start_idx = math.max(0, math.min(rows - 1, int((l - s_low) / bin_size)))
                    int end_idx = math.max(0, math.min(rows - 1, int((h - s_low) / bin_size)))
                    int bins_spanned = math.max(1, end_idx - start_idx + 1)
                    float v_per_bin = v / bins_spanned
                    
                    for idx = start_idx to end_idx
                        vol_bins.set(idx, vol_bins.get(idx) + v_per_bin)

            float max_v = 0.0
            int current_max_idx = 0
            for i = 0 to rows - 1
                float tot = vol_bins.get(i)
                if tot > max_v
                    max_v := tot
                    current_max_idx := i
                    
            var float last_poc_price = na
            int last_poc_bin = na
            
            // Hysteresis logic applied only for active current POC
            int poc_idx = current_max_idx
            if not is_prev
                if not na(last_poc_price) and last_poc_price >= s_low and last_poc_price <= s_high
                    last_poc_bin := math.max(0, math.min(rows - 1, int((last_poc_price - s_low) / bin_size)))
                    
                float last_poc_v = 0.0
                if not na(last_poc_bin)
                    last_poc_v := vol_bins.get(last_poc_bin)
                    if last_poc_bin > 0
                        last_poc_v := math.max(last_poc_v, vol_bins.get(last_poc_bin - 1))
                    if last_poc_bin < rows - 1
                        last_poc_v := math.max(last_poc_v, vol_bins.get(last_poc_bin + 1))
                        
                // Sadece yeni POC'un hacmi, toleransı ve eski POC hacmini net bir şekilde aştığında seviye değişsin
                if not na(last_poc_bin) and max_v <= last_poc_v * (1.0 + (poc_hysteresis / 100.0))
                    poc_idx := last_poc_bin
                    
                last_poc_price := s_low + (poc_idx * bin_size) + (bin_size / 2.0)

            // Make the POC Box taller to fit 3 delta lines
            int poc_up = math.min(rows - 1, poc_idx + 3)
            int poc_down = math.max(0, poc_idx - 3)

            float poc_h_price = s_low + (poc_up * bin_size) + bin_size
            float poc_l_price = s_low + (poc_down * bin_size)
            
            if max_v > 0
                int extended_end_t = draw_end_t + int(timeframe.in_seconds(timeframe.period) * 1000 * poc_bars_right)
                float mid_price = s_low + (poc_idx * bin_size) + (bin_size / 2.0)

                box b = box.new(draw_start_t, poc_h_price, extended_end_t, poc_l_price, xloc=xloc.bar_time, bgcolor=b_col, border_color=na)
                poc_boxes.push(b)

                // 3 Delta Volume Lines representation inside the POC box
                float volTop = poc_idx < rows - 1 ? vol_bins.get(poc_idx + 1) : 0
                float volMid = vol_bins.get(poc_idx)
                float volBot = poc_idx > 0 ? vol_bins.get(poc_idx - 1) : 0
                
                float maxLocalVol = math.max(volTop, math.max(volMid, volBot))
                
                if maxLocalVol > 0
                    int lenTop = draw_start_t + int(((extended_end_t - draw_start_t) * 0.9) * (volTop / maxLocalVol))
                    int lenMid = draw_start_t + int(((extended_end_t - draw_start_t) * 0.9) * (volMid / maxLocalVol))
                    int lenBot = draw_start_t + int(((extended_end_t - draw_start_t) * 0.9) * (volBot / maxLocalVol))

                    float yTop = s_low + ((poc_idx + 1) * bin_size) + (bin_size * 0.5)
                    float yMid = mid_price
                    float yBot = s_low + ((poc_idx - 1) * bin_size) + (bin_size * 0.5)

                    color l_col = close > mid_price ? color.new(poc_line_up_col, 0) : color.new(poc_line_dn_col, 0)

                    line lnTop = line.new(draw_start_t, yTop, lenTop, yTop, xloc=xloc.bar_time, color=l_col, width=1, style=line.style_solid)
                    line lnMid = line.new(draw_start_t, yMid, lenMid, yMid, xloc=xloc.bar_time, color=l_col, width=1, style=line.style_solid)
                    line lnBot = line.new(draw_start_t, yBot, lenBot, yBot, xloc=xloc.bar_time, color=l_col, width=1, style=line.style_solid)
                    
                    poc_lines.push(lnTop)
                    poc_lines.push(lnMid)
                    poc_lines.push(lnBot)

                if show_lbl
                    label l = label.new(extended_end_t, mid_price, txt + " " + str.tostring(mid_price, format.mintick), xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=color.white, style=label.style_label_left, size=size.small)
                    poc_labels.push(l)

// ============================================================================
// 🧠 POC ANCHOR LOGIC
// ============================================================================
bool is_poc_tf_change = ta.change(time(poc_tf)) != 0

var int poc_start_time = na
var int poc_start_bar  = na

if is_poc_tf_change or na(poc_start_time)
    if not na(poc_start_time)
        // Store finished session
        array.push(poc_history, PocSessionData.new(poc_start_time, time[1], poc_start_bar, bar_index[1]))
        if array.size(poc_history) > show_last_n_pocs
            array.shift(poc_history)
        
    poc_start_time := time
    poc_start_bar  := bar_index

// Calculate POC Box (Only on last bar for performance)
if barstate.islast
    // Clear elements
    if poc_boxes.size() > 0
        for i = 0 to poc_boxes.size() - 1
            box.delete(poc_boxes.get(i))
        poc_boxes.clear()
        
    if poc_labels.size() > 0
        for i = 0 to poc_labels.size() - 1
            label.delete(poc_labels.get(i))
        poc_labels.clear()

    if poc_lines.size() > 0
        for i = 0 to poc_lines.size() - 1
            line.delete(poc_lines.get(i))
        poc_lines.clear()

    if pocModel == "Model 1: Active POC"
        // Draw Previous POCs
        if show_last_n_pocs > 0 and array.size(poc_history) > 0
            int start_idx = math.max(0, array.size(poc_history) - show_last_n_pocs)
            for i = start_idx to array.size(poc_history) - 1
                PocSessionData p = array.get(poc_history, i)
                render_poc_box(p.start_bar, p.end_bar, p.start_time, p.end_time, true, color.new(prev_poc_box_col, 80), "Prev POC Area")
        
        // Draw Active POC
        if show_poc_box and not na(poc_start_time)
            render_poc_box(poc_start_bar, bar_index, poc_start_time, time, false, color.new(poc_box_col, 75), "POC Area")
            
    else if pocModel == "Model 2: Previous POC Focus"
        // Draw ONLY the previous POC, projected onto the CURRENT session
        if array.size(poc_history) > 0
            PocSessionData p = array.get(poc_history, array.size(poc_history) - 1)
            if not na(poc_start_time)
                render_poc_box(p.start_bar, p.end_bar, p.start_time, time, true, color.new(prev_poc_box_col, 80), "Prev POC Area")


// ============================================================================
// --- MAs / VWAP ---
// ============================================================================
get_ma_val(string type, int len) =>
    float res = na
    if type == "SMA"
        res := ta.sma(close, len)
    else if type == "EMA"
        res := ta.ema(close, len)
    else if type == "WMA"
        res := ta.wma(close, len)
    else if type == "HMA"
        res := ta.hma(close, len)
    else if type == "VWMA"
        res := ta.vwma(close, len)
    res

plot(showVwap ? ta.vwap : na, "VWAP", color = color.purple)
plot(ma1_type != "None" ? get_ma_val(ma1_type, ma1_len) : na, "MA 1", color = ma1_col)
plot(ma2_type != "None" ? get_ma_val(ma2_type, ma2_len) : na, "MA 2", color = ma2_col)
plot(ma3_type != "None" ? get_ma_val(ma3_type, ma3_len) : na, "MA 3", color = ma3_col)
plot(ma4_type != "None" ? get_ma_val(ma4_type, ma4_len) : na, "MA 4", color = ma4_col)
plot(ma5_type != "None" ? get_ma_val(ma5_type, ma5_len) : na, "MA 5", color = ma5_col)
````
