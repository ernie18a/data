# FUTURA Ultra MTF

- url: https://www.tradingview.com/script/bO0prQeR-FUTURA-Ultra-MTF/
- type: indicator
- pine_id: PUB;8b21c90c53a24503b0f63e1adbdc5508
- version: 4.0

## Description

FUTURA Ultra MTF 

An all-in-one overlay indicator built in Pine Script v6, comprising nine feature modules:

- Previous D/W/M Levels: Extending dynamic horizontal lines for prior day, week, and month highs/lows, anchored to the exact candle where each extreme occurred and snapping back when price interacts with them.

- Anchored VWAPs: Daily, weekly, and custom session VWAPs with optional standard deviation bands.

- Day Separators & Labels: Vertical lines at session boundaries with day-of-week labels plotted at the chart bottom.

- Custom Sessions: Shaded session boxes for Asia and NY with live extending high/low level lines that persist as historical references after each session closes, including a fix for RTH chart hidden boundary detection.

- Opening Range: A configurable time-based ORH/ORL box that plots extending levels only during NY regular hours, auto-deactivating at session close.

- HTF Candles: Current-bar candle representations for the 1H, 4H, and 1D timeframes.

- Label Collision Manager: Merges overlapping labels from all modules when levels are within a tick of each other.

- Watermark: A dynamic table displaying a configurable text header appended with the active ticker and timeframe.

- MTF Moving Averages: Three independently configurable moving averages (SMA, EMA, WMA, RMA, VWMA) pulling from any timeframe, with a dynamic gradient cloud fill between MA1 and MA2.

All modules share a unified visibility system with per-timeframe filter options.

## Source Code

````pine
//@version=6
//@description An advanced, all-in-one suite providing extending dynamic levels, multi-timeframe moving averages, customizable session boxes, opening ranges, anchored VWAPs, and day separators.
indicator("FUTURA Ultra MTF", shorttitle="FUTURA.Ultra", overlay=true, max_lines_count=250, max_labels_count=150, max_boxes_count=100, max_bars_back=500)

// ========================================================================= //
// ========================= INPUT CONFIGURATIONS ========================== //
// ========================================================================= //

var string GRP_VIS   = "--- Visibility Defaults ---"
var string GRP_PDWM  = "1. Previous D/W/M Levels"
var string GRP_VWAP  = "2. Anchored VWAPs"
var string GRP_SEP   = "3. Day Separator & Labels"
var string GRP_SESS  = "4. Custom Sessions (Asia/NY)"
var string GRP_OR    = "5. Opening Range"
var string GRP_HTF   = "6. HTF Candles"
var string GRP_WM    = "7. Watermark"
var string GRP_MA    = "8. MTF Moving Averages"

var string[] TZ_LIST = array.from("America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Asia/Tokyo", "Australia/Sydney", "UTC")
var string[] VIS_OPTS = array.from("All Timeframes", "Intraday (< 1H)", "Swing (<= 4H)", "<= Daily", "High TFs Only (D/W/M)", "Hidden")

// --- Helper NA Types to strictly satisfy UDT Constructors ---
line  na_line  = na
label na_label = na
box   na_box   = na
float na_float = na

// --- Helper Function for Line Styling ---
get_line_style(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// --- 1. Prev D/W/M Levels ---
string i_pdwm_vis  = input.string("All Timeframes", "Visibility", options=["All Timeframes", "Intraday (< 1H)", "Swing (<= 4H)", "<= Daily", "High TFs Only (D/W/M)", "Hidden"], group=GRP_PDWM)
string i_pdwm_sty  = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=GRP_PDWM, tooltip="Extending lines drop at the close of previous periods and break when price interacts with them.")

bool   i_pd_on     = input.bool(true, "Show Day", inline="pdwm1", group=GRP_PDWM)
color  i_pd_col    = input.color(color.new(#717382, 0), "Color", inline="pdwm1", group=GRP_PDWM)
int    i_pd_w      = input.int(1, "Width", inline="pdwm1", group=GRP_PDWM)

bool   i_pw_on     = input.bool(true, "Show Week", inline="pdwm2", group=GRP_PDWM)
color  i_pw_col    = input.color(color.new(#717382, 0), "Color", inline="pdwm2", group=GRP_PDWM)
int    i_pw_w      = input.int(2, "Width", inline="pdwm2", group=GRP_PDWM)

bool   i_pm_on     = input.bool(true, "Show Month", inline="pdwm3", group=GRP_PDWM)
color  i_pm_col    = input.color(color.new(#717382, 0), "Color", inline="pdwm3", group=GRP_PDWM)
int    i_pm_w      = input.int(3, "Width", inline="pdwm3", group=GRP_PDWM)

// --- 2. Anchored VWAP ---
string i_vwap_vis  = input.string("Intraday (< 1H)", "Visibility", options=["All Timeframes", "Intraday (< 1H)", "Swing (<= 4H)", "<= Daily", "High TFs Only (D/W/M)", "Hidden"], group=GRP_VWAP)
bool   i_vwap_d    = input.bool(true, "Daily VWAP", inline="v1", group=GRP_VWAP)
color  i_vwap_d_c  = input.color(color.new(#717382, 0), "", inline="v1", group=GRP_VWAP)
int    i_vwap_d_w  = input.int(2, "Width", minval=1, maxval=5, inline="v1", group=GRP_VWAP)

bool   i_vwap_w    = input.bool(false, "Weekly VWAP", inline="v2", group=GRP_VWAP)
color  i_vwap_w_c  = input.color(color.new(#717382, 0), "", inline="v2", group=GRP_VWAP)
int    i_vwap_w_w  = input.int(3, "Width", minval=1, maxval=5, inline="v2", group=GRP_VWAP)

bool   i_vwap_s    = input.bool(true, "Session VWAP", inline="v3", group=GRP_VWAP)
color  i_vwap_s_c  = input.color(color.new(#717382, 0), "", inline="v3", group=GRP_VWAP)
int    i_vwap_s_w  = input.int(1, "Width", minval=1, maxval=5, inline="v3", group=GRP_VWAP)

string i_vwap_sess = input.session("0930-1600", "Session Time", inline="v4", group=GRP_VWAP)
string i_vwap_tz   = input.string("America/New_York", "TZ", options=["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Asia/Tokyo", "Australia/Sydney", "UTC"], inline="v4", group=GRP_VWAP)

bool   i_vwap_b1_on= input.bool(false, "StDev Band 1", inline="vb1", group=GRP_VWAP)
float  i_vwap_b1_m = input.float(1.0, "Multiplier", inline="vb1", group=GRP_VWAP)
bool   i_vwap_b2_on= input.bool(false, "StDev Band 2", inline="vb2", group=GRP_VWAP)
float  i_vwap_b2_m = input.float(2.0, "Multiplier", inline="vb2", group=GRP_VWAP)
color  i_vwap_b_c  = input.color(color.new(color.gray, 60), "Bands Color", group=GRP_VWAP)

// --- 3. Day Separator ---
string i_sep_vis   = input.string("Intraday (< 1H)", "Visibility", options=["All Timeframes", "Intraday (< 1H)", "Swing (<= 4H)", "<= Daily", "High TFs Only (D/W/M)", "Hidden"], group=GRP_SEP)
string i_sep_sty   = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"], group=GRP_SEP)
color  i_sep_col   = input.color(color.new(color.gray, 60), "Separator Color", group=GRP_SEP)
color  i_sep_txt_c = input.color(color.new(color.gray, 50), "Label Text Color", group=GRP_SEP)

// --- 4. Custom Sessions ---
string i_sess_vis  = input.string("Intraday (< 1H)", "Visibility", options=["All Timeframes", "Intraday (< 1H)", "Swing (<= 4H)", "<= Daily", "High TFs Only (D/W/M)", "Hidden"], group=GRP_SESS)
int    i_sess_hist = input.int(3, "Historical Sessions Kept", minval=1, maxval=20, group=GRP_SESS, tooltip="Number of past session boxes/levels to keep on the chart.")
string i_sess_sty  = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"], group=GRP_SESS, tooltip="Creates shaded boxes during the session and plots extending high/low dynamic levels after.")

bool   i_sess_asia = input.bool(true, "Session 1 (Asia)", inline="s1", group=GRP_SESS)
string i_asia_time = input.session("2000-0000", "Time", inline="s1", group=GRP_SESS)
string i_asia_tz   = input.string("America/New_York", "TZ", options=["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Asia/Tokyo", "Australia/Sydney", "UTC"], inline="s1", group=GRP_SESS)
color  i_asia_bg   = input.color(color.new(#717382, 90), "Box BG", inline="s1_2", group=GRP_SESS)
color  i_asia_ln   = input.color(color.new(#717382, 0), "Levels Color", inline="s1_2", group=GRP_SESS)

bool   i_sess_ny   = input.bool(true, "Session 2 (NY)", inline="s2", group=GRP_SESS)
string i_ny_time   = input.session("0930-1600", "Time", inline="s2", group=GRP_SESS)
string i_ny_tz     = input.string("America/New_York", "TZ", options=["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Asia/Tokyo", "Australia/Sydney", "UTC"], inline="s2", group=GRP_SESS)
color  i_ny_bg     = input.color(color.new(#717382, 90), "Box BG", inline="s2_2", group=GRP_SESS)
color  i_ny_ln     = input.color(color.new(#717382, 0), "Levels Color", inline="s2_2", group=GRP_SESS)

// --- 5. Opening Range ---
string i_or_vis     = input.string("Intraday (< 1H)", "Visibility", options=["All Timeframes", "Intraday (< 1H)", "Swing (<= 4H)", "<= Daily", "High TFs Only (D/W/M)", "Hidden"], group=GRP_OR)
int    i_or_hist    = input.int(1, "Historical ORs Kept", minval=1, maxval=20, group=GRP_OR)
int    i_or_start_h = input.int(9, "Start Hour", minval=0, maxval=23, inline="or1", group=GRP_OR, tooltip="Opening Range start time. Uses a 24-hour clock in the selected timezone.")
int    i_or_start_m = input.int(30, "Minute", minval=0, maxval=59, inline="or1", group=GRP_OR)
string i_or_tz      = input.string("America/New_York", "TZ", options=["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Asia/Tokyo", "Australia/Sydney", "UTC"], inline="or1", group=GRP_OR)
int    i_or_dur     = input.int(30, "Duration (Mins)", options=[15, 30, 60], inline="or2", group=GRP_OR)
string i_or_sty     = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], inline="or2", group=GRP_OR)
int    i_or_w       = input.int(1, "Line Width", inline="or2", group=GRP_OR)
color  i_or_bg      = input.color(color.new(#ebebeb, 100), "Box BG", inline="or3", group=GRP_OR)
color  i_or_col     = input.color(color.new(#ebebeb, 0), "Levels Color", inline="or3", group=GRP_OR)

// --- 6. HTF Candles ---
string i_htf_vis       = input.string("Intraday (< 1H)", "Visibility", options=["All Timeframes", "Intraday (< 1H)", "Swing (<= 4H)", "<= Daily", "High TFs Only (D/W/M)", "Hidden"], group=GRP_HTF)
bool   i_htf_1h_on     = input.bool(false, "1H", inline="htf_tf", group=GRP_HTF)
bool   i_htf_4h_on     = input.bool(true, "4H", inline="htf_tf", group=GRP_HTF)
bool   i_htf_1d_on     = input.bool(false, "1D", inline="htf_tf", group=GRP_HTF)
int    i_htf_offset    = input.int(30, "Right Offset", minval=1, maxval=200, inline="htf_pos", group=GRP_HTF, tooltip="Number of bars to offset the first HTF candle to the right of the current bar.")
int    i_htf_width     = input.int(8, "Width", minval=1, maxval=50, inline="htf_pos", group=GRP_HTF)
int    i_htf_spacing   = input.int(6, "Spacing", minval=0, maxval=50, inline="htf_pos", group=GRP_HTF)
bool   i_htf_tf_labels = input.bool(true, "Show TF Labels", inline="htf_lbl", group=GRP_HTF)
bool   i_htf_timer_lbl = input.bool(true, "Show Timers", inline="htf_lbl", group=GRP_HTF)
bool   i_htf_ohlc_lbls = input.bool(false, "Show OHLC", inline="htf_lbl", group=GRP_HTF)
color  i_htf_lbl_col   = input.color(color.new(#717382, 0), "Label Color", group=GRP_HTF)

color  i_htf_bull_bg   = input.color(color.new(#b3ff00, 80), "Bull Fill", inline="htf_bull", group=GRP_HTF)
color  i_htf_bull_br   = input.color(color.new(#b3ff00, 0), "Border", inline="htf_bull", group=GRP_HTF)
color  i_htf_bull_wick = input.color(color.new(#b3ff00, 0), "Wick", inline="htf_bull", group=GRP_HTF)
color  i_htf_bear_bg   = input.color(color.new(#717382, 80), "Bear Fill", inline="htf_bear", group=GRP_HTF)
color  i_htf_bear_br   = input.color(color.new(#717382, 0), "Border", inline="htf_bear", group=GRP_HTF)
color  i_htf_bear_wick = input.color(color.new(#717382, 0), "Wick", inline="htf_bear", group=GRP_HTF)
color  i_htf_neut_bg   = input.color(color.new(#717382, 85), "Neutral Fill", inline="htf_neut", group=GRP_HTF)
color  i_htf_neut_br   = input.color(color.new(#717382, 0), "Border", inline="htf_neut", group=GRP_HTF)
color  i_htf_neut_wick = input.color(color.new(#717382, 0), "Wick", inline="htf_neut", group=GRP_HTF)

// --- 7. Watermark ---
string i_wm_vis    = input.string("All Timeframes", "Visibility", options=["All Timeframes", "Intraday (< 1H)", "Swing (<= 4H)", "<= Daily", "High TFs Only (D/W/M)", "Hidden"], group=GRP_WM)
string i_wm_txt    = input.string("FUTURA", "Text Header", group=GRP_WM, tooltip="Dynamic watermark appends the active Ticker and Timeframe to your text automatically.")
string i_wm_pos    = input.string(position.bottom_right, "Position", options=[position.bottom_right, position.bottom_left, position.bottom_center, position.top_right, position.top_left, position.top_center, position.middle_center], group=GRP_WM)
string i_wm_size   = input.string(size.small, "Size", options=[size.auto, size.tiny, size.small, size.normal, size.large, size.huge], group=GRP_WM)
color  i_wm_tc     = input.color(color.new(#0f0f0f, 0), "Text Color", inline="wm_c", group=GRP_WM)
color  i_wm_bg     = input.color(color.new(#b3ff00, 0), "Background", inline="wm_c", group=GRP_WM)

// --- 8. MTF MAs ---
string i_ma_vis    = input.string("Intraday (< 1H)", "Visibility", options=["All Timeframes", "Intraday (< 1H)", "Swing (<= 4H)", "<= Daily", "High TFs Only (D/W/M)", "Hidden"], group=GRP_MA)
bool   i_ma_cloud  = input.bool(true, "Enable MA 1 & 2 Cloud Fill", group=GRP_MA, tooltip="Fills the space between MA1 and MA2. Uses a dynamic gradient based on the spread between the moving averages.")
color  i_bull_c1   = input.color(color.new(#b3ff00, 95), "Bull Grad 1", inline="c1", group=GRP_MA)
color  i_bull_c2   = input.color(color.new(#b3ff00, 70), "Bull Grad 2", inline="c1", group=GRP_MA)
color  i_bear_c1   = input.color(color.new(#717382, 95), "Bear Grad 1", inline="c2", group=GRP_MA)
color  i_bear_c2   = input.color(color.new(#717382, 70), "Bear Grad 2", inline="c2", group=GRP_MA)

bool   i_ma1_on    = input.bool(true, "MA 1", inline="ma1_1", group=GRP_MA)
string i_ma1_tf    = input.timeframe("5", "TF", inline="ma1_1", group=GRP_MA)
string i_ma1_type  = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "RMA", "VWMA"], inline="ma1_2", group=GRP_MA)
int    i_ma1_len   = input.int(9, "Len", inline="ma1_2", group=GRP_MA)
color  i_ma1_col   = input.color(color.new(#b3ff00, 0), "Color", inline="ma1_2", group=GRP_MA)

bool   i_ma2_on    = input.bool(true, "MA 2", inline="ma2_1", group=GRP_MA)
string i_ma2_tf    = input.timeframe("5", "TF", inline="ma2_1", group=GRP_MA)
string i_ma2_type  = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "RMA", "VWMA"], inline="ma2_2", group=GRP_MA)
int    i_ma2_len   = input.int(21, "Len", inline="ma2_2", group=GRP_MA)
color  i_ma2_col   = input.color(color.new(#b3ff00, 0), "Color", inline="ma2_2", group=GRP_MA)

bool   i_ma3_on    = input.bool(true, "MA 3", inline="ma3_1", group=GRP_MA)
string i_ma3_tf    = input.timeframe("5", "TF", inline="ma3_1", group=GRP_MA)
string i_ma3_type  = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "RMA", "VWMA"], inline="ma3_2", group=GRP_MA)
int    i_ma3_len   = input.int(276, "Len", inline="ma3_2", group=GRP_MA)
color  i_ma3_col   = input.color(color.new(#ebebeb, 0), "Color", inline="ma3_2", group=GRP_MA)

// ========================================================================= //
// ========================= METHODS & UDTs ================================ //
// ========================================================================= //

//@description Checks if the current timeframe matches the visibility setting.
method isVis(string setting) =>
    bool visible = false
    int tf_mins = timeframe.multiplier
    if timeframe.isseconds
        tf_mins := 1

    if setting == "All Timeframes"
        visible := true
    else if setting == "Intraday (< 1H)" and timeframe.isintraday and tf_mins < 60
        visible := true
    else if setting == "Swing (<= 4H)" and timeframe.isintraday and tf_mins <= 240
        visible := true
    else if setting == "<= Daily" and (timeframe.isintraday or timeframe.isdaily)
        visible := true
    else if setting == "High TFs Only (D/W/M)" and (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)
        visible := true
    visible

// --- Global Visibility Cache ---
bool show_pdwm = i_pdwm_vis.isVis()
bool show_vwap = i_vwap_vis.isVis()
bool show_sep  = i_sep_vis.isVis()
bool show_sess = i_sess_vis.isVis()
bool show_or   = i_or_vis.isVis()
bool show_htf  = i_htf_vis.isVis()
bool show_wm   = i_wm_vis.isVis()
bool show_ma   = i_ma_vis.isVis()

//@description Object representing a dynamic horizontal level and label.
type Level
    line  ln
    label lbl
    float price
    bool  active
    string name
    color  clr
    bool   show_price

//@description Updates the line coordinates (+10 bars), moves the label, and deactivates/snaps back if hit.
method update(Level this, float curr_h, float curr_l) =>
    if this.active and not na(this.ln)
        line.set_x2(this.ln, bar_index + 10)
        if not na(this.lbl)
            label.set_x(this.lbl, bar_index + 10)

        if curr_h >= this.price and curr_l <= this.price
            this.active := false
            line.set_x2(this.ln, bar_index)
            if not na(this.lbl)
                label.delete(this.lbl)
                this.lbl := label(na)

//@description Updates the line coordinates, moves the label, but only if the session condition is met. (No +10 Ext).
method update_orb(Level this, bool condition) =>
    if this.active and condition and not na(this.ln)
        line.set_x2(this.ln, bar_index)
        if not na(this.lbl)
            label.set_x(this.lbl, bar_index)

//@description Tracks local extrema precisely by their origin bar index.
type PeriodExtrema
    float h     = na
    int   h_idx = na
    float l     = na
    int   l_idx = na

//@description Updates the exact index location of historical highs and lows.
method track(PeriodExtrema this, bool is_new) =>
    if is_new
        this.h := high
        this.h_idx := bar_index
        this.l := low
        this.l_idx := bar_index
    else
        if high > this.h or na(this.h)
            this.h := high
            this.h_idx := bar_index
        if low < this.l or na(this.l)
            this.l := low
            this.l_idx := bar_index

//@description Object for tracking custom sessions with boxes and live lines.
type SessionTracker
    float h
    float l
    bool  in_sess
    Level[] h_hist
    Level[] l_hist
    box[]   bx_hist
    Level live_h
    Level live_l

//@description Drawing objects for one right-offset HTF candle.
type HtfCandleDraw
    box body
    line upper_wick
    line lower_wick
    label tf_lbl
    label o_lbl
    label h_lbl
    label l_lbl
    label c_lbl

//@description Deletes all drawing objects associated with an HTF candle slot.
method clear(HtfCandleDraw this) =>
    if not na(this.body)
        box.delete(this.body)
        this.body := box(na)
    if not na(this.upper_wick)
        line.delete(this.upper_wick)
        this.upper_wick := line(na)
    if not na(this.lower_wick)
        line.delete(this.lower_wick)
        this.lower_wick := line(na)
    if not na(this.tf_lbl)
        label.delete(this.tf_lbl)
        this.tf_lbl := label(na)
    if not na(this.o_lbl)
        label.delete(this.o_lbl)
        this.o_lbl := label(na)
    if not na(this.h_lbl)
        label.delete(this.h_lbl)
        this.h_lbl := label(na)
    if not na(this.l_lbl)
        label.delete(this.l_lbl)
        this.l_lbl := label(na)
    if not na(this.c_lbl)
        label.delete(this.c_lbl)
        this.c_lbl := label(na)
    true

//@description Formats remaining milliseconds as a compact candle countdown.
format_countdown(int close_ts) =>
    int rem_ms = na(close_ts) ? 0 : math.max(close_ts - timenow, 0)
    int rem_sec = int(math.floor(rem_ms / 1000))
    int days = int(math.floor(rem_sec / 86400))
    int hrs = int(math.floor((rem_sec % 86400) / 3600))
    int mins = int(math.floor((rem_sec % 3600) / 60))
    int secs = rem_sec % 60
    string hh = hrs < 10 ? "0" + str.tostring(hrs) : str.tostring(hrs)
    string mm = mins < 10 ? "0" + str.tostring(mins) : str.tostring(mins)
    string ss = secs < 10 ? "0" + str.tostring(secs) : str.tostring(secs)
    days > 0 ? str.tostring(days) + "D " + hh + ":" + mm + ":" + ss : hh + ":" + mm + ":" + ss

//@description Draws or updates a right-offset HTF candle using real OHLC price levels.
method draw(HtfCandleDraw this, bool enabled, string tf_txt, float o, float h, float l, float c, int close_ts, int slot) =>
    bool did_draw = false
    if not enabled or na(o) or na(h) or na(l) or na(c)
        this.clear()
    else
        int x_left = bar_index + i_htf_offset + slot * (i_htf_width + i_htf_spacing)
        int x_right = x_left + i_htf_width
        int x_mid = int(math.round((x_left + x_right) / 2.0))
        int x_lbl = x_right + 1

        float body_top = math.max(o, c)
        float body_bot = math.min(o, c)
        bool is_bull = c > o
        bool is_bear = c < o
        color body_c = is_bull ? i_htf_bull_bg : is_bear ? i_htf_bear_bg : i_htf_neut_bg
        color border_c = is_bull ? i_htf_bull_br : is_bear ? i_htf_bear_br : i_htf_neut_br
        color wick_c = is_bull ? i_htf_bull_wick : is_bear ? i_htf_bear_wick : i_htf_neut_wick
        string timer_txt = format_countdown(close_ts)
        string combined_lbl = i_htf_tf_labels and i_htf_timer_lbl ? tf_txt + "\n" + timer_txt : i_htf_tf_labels ? tf_txt : i_htf_timer_lbl ? timer_txt : ""

        if na(this.body)
            this.body := box.new(x_left, body_top, x_right, body_bot, border_color=border_c, bgcolor=body_c)
            this.upper_wick := line.new(x_mid, h, x_mid, body_top, color=wick_c)
            this.lower_wick := line.new(x_mid, body_bot, x_mid, l, color=wick_c)
            this.tf_lbl := label.new(x_mid, l, combined_lbl, color=color.new(color.white, 100), textcolor=i_htf_lbl_col, style=label.style_label_up, size=size.small)
            this.o_lbl := label.new(x_lbl, o, "", color=color.new(color.white, 100), textcolor=i_htf_lbl_col, style=label.style_label_left, size=size.small)
            this.h_lbl := label.new(x_lbl, h, "", color=color.new(color.white, 100), textcolor=i_htf_lbl_col, style=label.style_label_left, size=size.small)
            this.l_lbl := label.new(x_lbl, l, "", color=color.new(color.white, 100), textcolor=i_htf_lbl_col, style=label.style_label_left, size=size.small)
            this.c_lbl := label.new(x_lbl, c, "", color=color.new(color.white, 100), textcolor=i_htf_lbl_col, style=label.style_label_left, size=size.small)

        box.set_left(this.body, x_left)
        box.set_right(this.body, x_right)
        box.set_top(this.body, body_top)
        box.set_bottom(this.body, body_bot)
        box.set_bgcolor(this.body, body_c)
        box.set_border_color(this.body, border_c)
        box.set_border_width(this.body, 1)

        line.set_x1(this.upper_wick, x_mid)
        line.set_x2(this.upper_wick, x_mid)
        line.set_y1(this.upper_wick, h)
        line.set_y2(this.upper_wick, body_top)
        line.set_color(this.upper_wick, wick_c)
        line.set_width(this.upper_wick, 1)

        line.set_x1(this.lower_wick, x_mid)
        line.set_x2(this.lower_wick, x_mid)
        line.set_y1(this.lower_wick, body_bot)
        line.set_y2(this.lower_wick, l)
        line.set_color(this.lower_wick, wick_c)
        line.set_width(this.lower_wick, 1)

        label.set_x(this.tf_lbl, x_mid)
        label.set_y(this.tf_lbl, l)
        label.set_text(this.tf_lbl, combined_lbl)
        label.set_textcolor(this.tf_lbl, i_htf_lbl_col)
        label.set_style(this.tf_lbl, label.style_label_up)

        label.set_x(this.o_lbl, x_lbl)
        label.set_y(this.o_lbl, o)
        label.set_text(this.o_lbl, i_htf_ohlc_lbls ? "O " + str.tostring(o, format.mintick) : "")
        label.set_textcolor(this.o_lbl, i_htf_lbl_col)

        label.set_x(this.h_lbl, x_lbl)
        label.set_y(this.h_lbl, h)
        label.set_text(this.h_lbl, i_htf_ohlc_lbls ? "H " + str.tostring(h, format.mintick) : "")
        label.set_textcolor(this.h_lbl, i_htf_lbl_col)

        label.set_x(this.l_lbl, x_lbl)
        label.set_y(this.l_lbl, l)
        label.set_text(this.l_lbl, i_htf_ohlc_lbls ? "L " + str.tostring(l, format.mintick) : "")
        label.set_textcolor(this.l_lbl, i_htf_lbl_col)

        label.set_x(this.c_lbl, x_lbl)
        label.set_y(this.c_lbl, c)
        label.set_text(this.c_lbl, i_htf_ohlc_lbls ? "C " + str.tostring(c, format.mintick) : "")
        label.set_textcolor(this.c_lbl, i_htf_lbl_col)
        did_draw := true
    did_draw

// ========================================================================= //
// ========================= 1. PREV D/W/M LEVELS ========================== //
// ========================================================================= //

var PeriodExtrema day_ext   = PeriodExtrema.new()
var PeriodExtrema week_ext  = PeriodExtrema.new()
var PeriodExtrema month_ext = PeriodExtrema.new()

bool new_d = timeframe.change("D")
bool new_w = timeframe.change("W")
bool new_m = timeframe.change("M")

var Level pd_h_lvl = Level.new(na_line, na_label, na_float, false, "", na, false)
var Level pd_l_lvl = Level.new(na_line, na_label, na_float, false, "", na, false)
var Level pw_h_lvl = Level.new(na_line, na_label, na_float, false, "", na, false)
var Level pw_l_lvl = Level.new(na_line, na_label, na_float, false, "", na, false)
var Level pm_h_lvl = Level.new(na_line, na_label, na_float, false, "", na, false)
var Level pm_l_lvl = Level.new(na_line, na_label, na_float, false, "", na, false)

gen_label(float price, string txt, color clr, int x_loc) =>
    label.new(x_loc, price, txt + " " + str.tostring(price, format.mintick), color=color.new(color.white, 100), textcolor=clr, style=label.style_label_left, size=size.small)

gen_label_no_price(float price, string txt, color clr, int x_loc) =>
    label.new(x_loc, price, txt, color=color.new(color.white, 100), textcolor=clr, style=label.style_label_left, size=size.small)

if show_pdwm
    string pdwm_style = get_line_style(i_pdwm_sty)
    if new_d
        if not na(pd_h_lvl.ln)
            line.delete(pd_h_lvl.ln)
        if not na(pd_h_lvl.lbl)
            label.delete(pd_h_lvl.lbl)
        if not na(pd_l_lvl.ln)
            line.delete(pd_l_lvl.ln)
        if not na(pd_l_lvl.lbl)
            label.delete(pd_l_lvl.lbl)

        if i_pd_on and not na(day_ext.h)
            pd_h_lvl := Level.new(line.new(day_ext.h_idx, day_ext.h, bar_index + 10, day_ext.h, color=i_pd_col, style=pdwm_style, width=i_pd_w), gen_label(day_ext.h, "PDH", i_pd_col, bar_index + 10), day_ext.h, true, "PDH", i_pd_col, true)
            pd_l_lvl := Level.new(line.new(day_ext.l_idx, day_ext.l, bar_index + 10, day_ext.l, color=i_pd_col, style=pdwm_style, width=i_pd_w), gen_label(day_ext.l, "PDL", i_pd_col, bar_index + 10), day_ext.l, true, "PDL", i_pd_col, true)

    if new_w
        if not na(pw_h_lvl.ln)
            line.delete(pw_h_lvl.ln)
        if not na(pw_h_lvl.lbl)
            label.delete(pw_h_lvl.lbl)
        if not na(pw_l_lvl.ln)
            line.delete(pw_l_lvl.ln)
        if not na(pw_l_lvl.lbl)
            label.delete(pw_l_lvl.lbl)

        if i_pw_on and not na(week_ext.h)
            pw_h_lvl := Level.new(line.new(week_ext.h_idx, week_ext.h, bar_index + 10, week_ext.h, color=i_pw_col, style=pdwm_style, width=i_pw_w), gen_label(week_ext.h, "PWH", i_pw_col, bar_index + 10), week_ext.h, true, "PWH", i_pw_col, true)
            pw_l_lvl := Level.new(line.new(week_ext.l_idx, week_ext.l, bar_index + 10, week_ext.l, color=i_pw_col, style=pdwm_style, width=i_pw_w), gen_label(week_ext.l, "PWL", i_pw_col, bar_index + 10), week_ext.l, true, "PWL", i_pw_col, true)

    if new_m
        if not na(pm_h_lvl.ln)
            line.delete(pm_h_lvl.ln)
        if not na(pm_h_lvl.lbl)
            label.delete(pm_h_lvl.lbl)
        if not na(pm_l_lvl.ln)
            line.delete(pm_l_lvl.ln)
        if not na(pm_l_lvl.lbl)
            label.delete(pm_l_lvl.lbl)

        if i_pm_on and not na(month_ext.h)
            pm_h_lvl := Level.new(line.new(month_ext.h_idx, month_ext.h, bar_index + 10, month_ext.h, color=i_pm_col, style=pdwm_style, width=i_pm_w), gen_label(month_ext.h, "PMH", i_pm_col, bar_index + 10), month_ext.h, true, "PMH", i_pm_col, true)
            pm_l_lvl := Level.new(line.new(month_ext.l_idx, month_ext.l, bar_index + 10, month_ext.l, color=i_pm_col, style=pdwm_style, width=i_pm_w), gen_label(month_ext.l, "PML", i_pm_col, bar_index + 10), month_ext.l, true, "PML", i_pm_col, true)

    day_ext.track(new_d)
    week_ext.track(new_w)
    month_ext.track(new_m)

    pd_h_lvl.update(high, low)
    pd_l_lvl.update(high, low)
    pw_h_lvl.update(high, low)
    pw_l_lvl.update(high, low)
    pm_h_lvl.update(high, low)
    pm_l_lvl.update(high, low)

// ========================================================================= //
// ========================= 2. ANCHORED VWAPS ============================= //
// ========================================================================= //

//@description Calculates VWAP and standard deviation variance. Bypasses math if disabled.
get_avwap_dev(bool cond, bool calc_enable) =>
    var float sum_src_vol = 0.0
    var float sum_src2_vol = 0.0
    var float sum_vol = 0.0
    if calc_enable
        if cond
            sum_src_vol  := 0.0
            sum_src2_vol := 0.0
            sum_vol      := 0.0
        sum_src_vol  += hlc3 * volume
        sum_src2_vol += hlc3 * hlc3 * volume
        sum_vol      += volume

    float vwap = sum_vol == 0 or not calc_enable ? na : sum_src_vol / sum_vol
    float variance = sum_vol == 0 or not calc_enable ? na : (sum_src2_vol / sum_vol) - (vwap * vwap)
    float stdev = variance > 0 ? math.sqrt(variance) : 0.0
    [vwap, stdev]

in_vwap_sess   = time(timeframe.period, i_vwap_sess, i_vwap_tz)
vwap_sess_strt = not na(in_vwap_sess) and na(in_vwap_sess[1])

[d_vwap, d_dev] = get_avwap_dev(new_d, show_vwap and i_vwap_d)
[w_vwap, w_dev] = get_avwap_dev(new_w, show_vwap and i_vwap_w)
[s_vwap, s_dev] = get_avwap_dev(vwap_sess_strt, show_vwap and i_vwap_s)

plot(show_vwap and i_vwap_d and not new_d ? d_vwap : na, "Daily VWAP", color=i_vwap_d_c, linewidth=i_vwap_d_w, style=plot.style_linebr)
plot(show_vwap and i_vwap_w and not new_w ? w_vwap : na, "Weekly VWAP", color=i_vwap_w_c, linewidth=i_vwap_w_w, style=plot.style_linebr)
plot(show_vwap and i_vwap_s and not na(in_vwap_sess) ? s_vwap : na, "Session VWAP", color=i_vwap_s_c, linewidth=i_vwap_s_w, style=plot.style_linebr)

plot(show_vwap and i_vwap_b1_on and i_vwap_d and not new_d ? d_vwap + d_dev * i_vwap_b1_m : na, "D +B1", color=i_vwap_b_c, style=plot.style_circles)
plot(show_vwap and i_vwap_b1_on and i_vwap_d and not new_d ? d_vwap - d_dev * i_vwap_b1_m : na, "D -B1", color=i_vwap_b_c, style=plot.style_circles)
plot(show_vwap and i_vwap_b2_on and i_vwap_d and not new_d ? d_vwap + d_dev * i_vwap_b2_m : na, "D +B2", color=i_vwap_b_c, style=plot.style_cross)
plot(show_vwap and i_vwap_b2_on and i_vwap_d and not new_d ? d_vwap - d_dev * i_vwap_b2_m : na, "D -B2", color=i_vwap_b_c, style=plot.style_cross)

// ========================================================================= //
// ========================= 3. DAY SEPARATOR & LABELS ===================== //
// ========================================================================= //

var line[] sep_lines = array.new<line>()

bool is_new_day = show_sep and new_d

int trading_dow = dayofweek(time, syminfo.timezone)
int tc = time_close("D")
if not na(tc)
    trading_dow := dayofweek(tc - 1000, syminfo.timezone)

if is_new_day
    sep_lines.push(line.new(bar_index, low, bar_index, high, extend=extend.both, color=i_sep_col, style=get_line_style(i_sep_sty)))
    if sep_lines.size() > 60
        line.delete(sep_lines.shift())

plotchar(is_new_day and trading_dow == 1, title="Sun", char="", text="Sun", location=location.bottom, color=i_sep_col, textcolor=i_sep_txt_c, size=size.small, editable=false, display=display.pane)
plotchar(is_new_day and trading_dow == 2, title="Mon", char="", text="Mon", location=location.bottom, color=i_sep_col, textcolor=i_sep_txt_c, size=size.small, editable=false, display=display.pane)
plotchar(is_new_day and trading_dow == 3, title="Tue", char="", text="Tue", location=location.bottom, color=i_sep_col, textcolor=i_sep_txt_c, size=size.small, editable=false, display=display.pane)
plotchar(is_new_day and trading_dow == 4, title="Wed", char="", text="Wed", location=location.bottom, color=i_sep_col, textcolor=i_sep_txt_c, size=size.small, editable=false, display=display.pane)
plotchar(is_new_day and trading_dow == 5, title="Thu", char="", text="Thu", location=location.bottom, color=i_sep_col, textcolor=i_sep_txt_c, size=size.small, editable=false, display=display.pane)
plotchar(is_new_day and trading_dow == 6, title="Fri", char="", text="Fri", location=location.bottom, color=i_sep_col, textcolor=i_sep_txt_c, size=size.small, editable=false, display=display.pane)
plotchar(is_new_day and trading_dow == 7, title="Sat", char="", text="Sat", location=location.bottom, color=i_sep_col, textcolor=i_sep_txt_c, size=size.small, editable=false, display=display.pane)

// ========================================================================= //
// ========================= 4. CUSTOM SESSIONS ============================ //
// ========================================================================= //

var SessionTracker s_asia = SessionTracker.new(na_float, na_float, false, array.new<Level>(), array.new<Level>(), array.new<box>(), Level.new(na_line, na_label, na_float, false, "", na, false), Level.new(na_line, na_label, na_float, false, "", na, false))
var SessionTracker s_ny   = SessionTracker.new(na_float, na_float, false, array.new<Level>(), array.new<Level>(), array.new<box>(), Level.new(na_line, na_label, na_float, false, "", na, false), Level.new(na_line, na_label, na_float, false, "", na, false))

// RTH charts can skip the bar where a custom session ends. This detects that hidden boundary.
int chart_tf_ms = timeframe.in_seconds(timeframe.period) * 1000
bool hidden_rth_session_roll =
     syminfo.session == session.regular and
     timeframe.isintraday and
     not na(time[1]) and
     time_tradingday != time_tradingday[1] and
     time - time[1] > chart_tf_ms * 3

process_session(SessionTracker obj, bool is_in, bool force_roll, color bg_c, color ln_c, string txt_prefix, bool is_visible) =>
    bool is_roll = is_in and obj.in_sess and force_roll
    bool is_end  = (not is_in and obj.in_sess) or is_roll
    bool is_new  = is_in and (not obj.in_sess or is_roll)

    if is_end
        if is_visible
            if not na(obj.live_h.ln)
                obj.h_hist.push(obj.live_h)
                obj.l_hist.push(obj.live_l)
                obj.live_h := Level.new(na_line, na_label, na_float, false, "", na, false)
                obj.live_l := Level.new(na_line, na_label, na_float, false, "", na, false)
            else
                string sty = get_line_style(i_sess_sty)
                Level new_h = Level.new(line.new(bar_index[1], obj.h, bar_index + 10, obj.h, color=ln_c, style=sty), gen_label_no_price(obj.h, txt_prefix + " H", ln_c, bar_index + 10), obj.h, true, txt_prefix + " H", ln_c, false)
                Level new_l = Level.new(line.new(bar_index[1], obj.l, bar_index + 10, obj.l, color=ln_c, style=sty), gen_label_no_price(obj.l, txt_prefix + " L", ln_c, bar_index + 10), obj.l, true, txt_prefix + " L", ln_c, false)
                obj.h_hist.push(new_h)
                obj.l_hist.push(new_l)

            if obj.h_hist.size() > i_sess_hist
                Level old_h = obj.h_hist.shift()
                if not na(old_h.ln)
                    line.delete(old_h.ln)
                if not na(old_h.lbl)
                    label.delete(old_h.lbl)

            if obj.l_hist.size() > i_sess_hist
                Level old_l = obj.l_hist.shift()
                if not na(old_l.ln)
                    line.delete(old_l.ln)
                if not na(old_l.lbl)
                    label.delete(old_l.lbl)
        else
            if not na(obj.live_h.ln)
                line.delete(obj.live_h.ln)
                label.delete(obj.live_h.lbl)
                obj.live_h := Level.new(na_line, na_label, na_float, false, "", na, false)
                line.delete(obj.live_l.ln)
                label.delete(obj.live_l.lbl)
                obj.live_l := Level.new(na_line, na_label, na_float, false, "", na, false)

    if is_new
        obj.h := high
        obj.l := low
        if is_visible
            obj.bx_hist.push(box.new(bar_index, high, bar_index, low, border_color=na, bgcolor=bg_c))
            if obj.bx_hist.size() > i_sess_hist + 1
                box.delete(obj.bx_hist.shift())

            string sty = get_line_style(i_sess_sty)
            obj.live_h := Level.new(line.new(bar_index, high, bar_index + 10, high, color=ln_c, style=sty), gen_label_no_price(high, txt_prefix + " H", ln_c, bar_index + 10), high, true, txt_prefix + " H", ln_c, false)
            obj.live_l := Level.new(line.new(bar_index, low, bar_index + 10, low, color=ln_c, style=sty), gen_label_no_price(low, txt_prefix + " L", ln_c, bar_index + 10), low, true, txt_prefix + " L", ln_c, false)

    if is_in
        float prev_h = obj.h
        float prev_l = obj.l
        obj.h := math.max(obj.h, high)
        obj.l := math.min(obj.l, low)
        bool h_changed = obj.h != prev_h
        bool l_changed = obj.l != prev_l

        if obj.bx_hist.size() > 0
            box b = obj.bx_hist.last()
            if not na(b)
                if h_changed
                    box.set_top(b, obj.h)
                if l_changed
                    box.set_bottom(b, obj.l)
                box.set_right(b, bar_index)

        if is_visible
            if na(obj.live_h.ln)
                string sty = get_line_style(i_sess_sty)
                obj.live_h := Level.new(line.new(bar_index, obj.h, bar_index + 10, obj.h, color=ln_c, style=sty), gen_label_no_price(obj.h, txt_prefix + " H", ln_c, bar_index + 10), obj.h, true, txt_prefix + " H", ln_c, false)
                obj.live_l := Level.new(line.new(bar_index, obj.l, bar_index + 10, obj.l, color=ln_c, style=sty), gen_label_no_price(obj.l, txt_prefix + " L", ln_c, bar_index + 10), obj.l, true, txt_prefix + " L", ln_c, false)
            else
                if h_changed
                    line.set_y1(obj.live_h.ln, obj.h)
                    line.set_y2(obj.live_h.ln, obj.h)
                    label.set_y(obj.live_h.lbl, obj.h)
                    obj.live_h.price := obj.h
                line.set_x2(obj.live_h.ln, bar_index + 10)
                label.set_x(obj.live_h.lbl, bar_index + 10)

                if l_changed
                    line.set_y1(obj.live_l.ln, obj.l)
                    line.set_y2(obj.live_l.ln, obj.l)
                    label.set_y(obj.live_l.lbl, obj.l)
                    obj.live_l.price := obj.l
                line.set_x2(obj.live_l.ln, bar_index + 10)
                label.set_x(obj.live_l.lbl, bar_index + 10)
        else
            if not na(obj.live_h.ln)
                line.delete(obj.live_h.ln)
                label.delete(obj.live_h.lbl)
                obj.live_h := Level.new(na_line, na_label, na_float, false, "", na, false)
                line.delete(obj.live_l.ln)
                label.delete(obj.live_l.lbl)
                obj.live_l := Level.new(na_line, na_label, na_float, false, "", na, false)

    obj.in_sess := is_in

    if is_visible
        for h_lvl in obj.h_hist
            h_lvl.update(high, low)
        for l_lvl in obj.l_hist
            l_lvl.update(high, low)

bool in_asia = not na(time(timeframe.period, i_asia_time, i_asia_tz))
bool in_ny   = not na(time(timeframe.period, i_ny_time, i_ny_tz))

if i_sess_asia
    process_session(s_asia, in_asia, hidden_rth_session_roll, i_asia_bg, i_asia_ln, "Asia", show_sess)
if i_sess_ny
    process_session(s_ny, in_ny, hidden_rth_session_roll, i_ny_bg, i_ny_ln, "NY", show_sess)

// ========================================================================= //
// ========================= 5. OPENING RANGE ============================== //
// ========================================================================= //

var int   or_start = na
var float or_h     = na
var float or_l     = na

var box[]   or_bx_hist = array.new<box>()
var Level[] or_h_hist  = array.new<Level>()
var Level[] or_l_hist  = array.new<Level>()

int or_start_ts = timestamp(i_or_tz, year(time, i_or_tz), month(time, i_or_tz), dayofmonth(time, i_or_tz), i_or_start_h, i_or_start_m)
int or_end_ts = or_start_ts + i_or_dur * 60000
int or_bar_close = time_close(timeframe.period)

bool in_or_window = not na(or_bar_close) and time < or_end_ts and or_bar_close > or_start_ts
bool is_new_or = in_or_window and not in_or_window[1]
bool is_or_done = not in_or_window and in_or_window[1]

if is_new_or
    or_start := or_start_ts
    or_h := high
    or_l := low

    if show_or
        or_bx_hist.push(box.new(bar_index, high, bar_index, low, border_color=na, bgcolor=i_or_bg))
        if or_bx_hist.size() > i_or_hist + 1
            box.delete(or_bx_hist.shift())

if in_or_window
    or_h := math.max(or_h, high)
    or_l := math.min(or_l, low)
    if or_bx_hist.size() > 0
        box b = or_bx_hist.last()
        if not na(b)
            box.set_top(b, or_h)
            box.set_bottom(b, or_l)
            box.set_right(b, bar_index)

if is_or_done and not na(or_h) and not na(or_l)
    if show_or
        string sty = get_line_style(i_or_sty)
        Level h_lvl = Level.new(line.new(bar_index, or_h, bar_index, or_h, color=i_or_col, width=i_or_w, style=sty), na_label, or_h, true, "ORH", i_or_col, false)
        Level l_lvl = Level.new(line.new(bar_index, or_l, bar_index, or_l, color=i_or_col, width=i_or_w, style=sty), na_label, or_l, true, "ORL", i_or_col, false)

        or_h_hist.push(h_lvl)
        or_l_hist.push(l_lvl)

        if or_h_hist.size() > i_or_hist
            Level old_h = or_h_hist.shift()
            line.delete(old_h.ln)
            if not na(old_h.lbl)
                label.delete(old_h.lbl)
            old_h.active := false

        if or_l_hist.size() > i_or_hist
            Level old_l = or_l_hist.shift()
            line.delete(old_l.ln)
            if not na(old_l.lbl)
                label.delete(old_l.lbl)
            old_l.active := false

bool in_ny_reg = not na(time(timeframe.period, "0930-1600", "America/New_York"))
bool ny_reg_ended = in_ny_reg[1] and not in_ny_reg

if show_or
    for h in or_h_hist
        if ny_reg_ended
            h.active := false
        h.update_orb(in_ny_reg)

    for l in or_l_hist
        if ny_reg_ended
            l.active := false
        l.update_orb(in_ny_reg)

// ========================================================================= //
// ========================= 6. HTF CANDLES ================================ //
// ========================================================================= //

var HtfCandleDraw htf_1h = HtfCandleDraw.new(na_box, na_line, na_line, na_label, na_label, na_label, na_label, na_label)
var HtfCandleDraw htf_4h = HtfCandleDraw.new(na_box, na_line, na_line, na_label, na_label, na_label, na_label, na_label)
var HtfCandleDraw htf_1d = HtfCandleDraw.new(na_box, na_line, na_line, na_label, na_label, na_label, na_label, na_label)

[htf_1h_o, htf_1h_h, htf_1h_l, htf_1h_c, htf_1h_tc] = request.security(syminfo.tickerid, "60", [open, high, low, close, time_close])
[htf_4h_o, htf_4h_h, htf_4h_l, htf_4h_c, htf_4h_tc] = request.security(syminfo.tickerid, "240", [open, high, low, close, time_close])
[htf_1d_o, htf_1d_h, htf_1d_l, htf_1d_c, htf_1d_tc] = request.security(syminfo.tickerid, "D", [open, high, low, close, time_close])

if barstate.islast
    int htf_slot = 0
    bool draw_1h = show_htf and i_htf_1h_on and timeframe.in_seconds(timeframe.period) < timeframe.in_seconds("60")
    bool draw_4h = show_htf and i_htf_4h_on and timeframe.in_seconds(timeframe.period) < timeframe.in_seconds("240")
    bool draw_1d = show_htf and i_htf_1d_on and timeframe.in_seconds(timeframe.period) < timeframe.in_seconds("1D")

    htf_1h.draw(draw_1h, "1H", htf_1h_o, htf_1h_h, htf_1h_l, htf_1h_c, htf_1h_tc, htf_slot)
    if draw_1h
        htf_slot += 1

    htf_4h.draw(draw_4h, "4H", htf_4h_o, htf_4h_h, htf_4h_l, htf_4h_c, htf_4h_tc, htf_slot)
    if draw_4h
        htf_slot += 1

    htf_1d.draw(draw_1d, "1D", htf_1d_o, htf_1d_h, htf_1d_l, htf_1d_c, htf_1d_tc, htf_slot)

// ========================================================================= //
// ========================= 7. LABEL COLLISION MANAGER ==================== //
// ========================================================================= //

if barstate.islast
    Level[] active_levels = array.new<Level>()

    if show_pdwm
        if pd_h_lvl.active and not na(pd_h_lvl.lbl)
            active_levels.push(pd_h_lvl)
        if pd_l_lvl.active and not na(pd_l_lvl.lbl)
            active_levels.push(pd_l_lvl)
        if pw_h_lvl.active and not na(pw_h_lvl.lbl)
            active_levels.push(pw_h_lvl)
        if pw_l_lvl.active and not na(pw_l_lvl.lbl)
            active_levels.push(pw_l_lvl)
        if pm_h_lvl.active and not na(pm_h_lvl.lbl)
            active_levels.push(pm_h_lvl)
        if pm_l_lvl.active and not na(pm_l_lvl.lbl)
            active_levels.push(pm_l_lvl)

    if show_sess
        for lvl in s_asia.h_hist
            if lvl.active and not na(lvl.lbl)
                active_levels.push(lvl)
        for lvl in s_asia.l_hist
            if lvl.active and not na(lvl.lbl)
                active_levels.push(lvl)
        if s_asia.live_h.active and not na(s_asia.live_h.lbl)
            active_levels.push(s_asia.live_h)
        if s_asia.live_l.active and not na(s_asia.live_l.lbl)
            active_levels.push(s_asia.live_l)

        for lvl in s_ny.h_hist
            if lvl.active and not na(lvl.lbl)
                active_levels.push(lvl)
        for lvl in s_ny.l_hist
            if lvl.active and not na(lvl.lbl)
                active_levels.push(lvl)
        if s_ny.live_h.active and not na(s_ny.live_h.lbl)
            active_levels.push(s_ny.live_h)
        if s_ny.live_l.active and not na(s_ny.live_l.lbl)
            active_levels.push(s_ny.live_l)

    int al_size = active_levels.size()
    if al_size > 0
        bool[] processed = array.new<bool>()
        for i = 0 to al_size - 1
            processed.push(false)

        for i = 0 to al_size - 1
            if not processed.get(i)
                Level main_lvl = active_levels.get(i)
                string combined_name = main_lvl.name
                bool show_prc = main_lvl.show_price

                if i + 1 < al_size
                    for j = i + 1 to al_size - 1
                        if not processed.get(j)
                            Level check_lvl = active_levels.get(j)
                            if math.abs(main_lvl.price - check_lvl.price) < syminfo.mintick * 2
                                combined_name += " + " + check_lvl.name
                                if check_lvl.show_price
                                    show_prc := true
                                processed.set(j, true)
                                label.set_text(check_lvl.lbl, "")

                string final_txt = show_prc ? combined_name + " " + str.tostring(main_lvl.price, format.mintick) : combined_name
                label.set_text(main_lvl.lbl, final_txt)
                processed.set(i, true)

// ========================================================================= //
// ========================= 8. WATERMARK ================================== //
// ========================================================================= //

var table wm_tab = table.new(i_wm_pos, 1, 1)

if barstate.islast and show_wm
    string wm_dyn_txt = i_wm_txt + " | " + syminfo.ticker + " | " + timeframe.period
    table.cell(wm_tab, 0, 0, wm_dyn_txt, text_color=i_wm_tc, bgcolor=i_wm_bg, text_size=i_wm_size)

// ========================================================================= //
// ========================= 9. MTF MOVING AVERAGES ======================== //
// ========================================================================= //

get_ma(string type, float src, int len) =>
    float val_sma  = ta.sma(src, len)
    float val_ema  = ta.ema(src, len)
    float val_wma  = ta.wma(src, len)
    float val_rma  = ta.rma(src, len)
    float val_vwma = ta.vwma(src, len)
    switch type
        "SMA"  => val_sma
        "EMA"  => val_ema
        "WMA"  => val_wma
        "RMA"  => val_rma
        "VWMA" => val_vwma
        => val_sma

tf1 = i_ma1_tf == "" ? timeframe.period : i_ma1_tf
tf2 = i_ma2_tf == "" ? timeframe.period : i_ma2_tf
tf3 = i_ma3_tf == "" ? timeframe.period : i_ma3_tf

ma1 = request.security(syminfo.tickerid, tf1, get_ma(i_ma1_type, close, i_ma1_len))
ma2 = request.security(syminfo.tickerid, tf2, get_ma(i_ma2_type, close, i_ma2_len))
ma3 = request.security(syminfo.tickerid, tf3, get_ma(i_ma3_type, close, i_ma3_len))

p_ma1 = plot(show_ma and i_ma1_on ? ma1 : na, "MA 1", color=i_ma1_col, linewidth=2)
p_ma2 = plot(show_ma and i_ma2_on ? ma2 : na, "MA 2", color=i_ma2_col, linewidth=2)
plot(show_ma and i_ma3_on ? ma3 : na, "MA 3", color=i_ma3_col, linewidth=2)

float ma_spread = show_ma and i_ma_cloud and i_ma1_on and i_ma2_on ? math.abs(ma1 - ma2) : na
float max_spread = ta.highest(ma_spread, 200)

color bull_grad = color.from_gradient(ma_spread, 0, max_spread == 0 ? 1 : max_spread, i_bull_c1, i_bull_c2)
color bear_grad = color.from_gradient(ma_spread, 0, max_spread == 0 ? 1 : max_spread, i_bear_c1, i_bear_c2)
color cloud_col = show_ma and i_ma_cloud and i_ma1_on and i_ma2_on ? (ma1 > ma2 ? bull_grad : bear_grad) : na

fill(p_ma1, p_ma2, color=cloud_col, title="MA Cloud Fill")
````
