# HTF Radar V1

- url: https://www.tradingview.com/script/xlm5otz3/
- type: indicator
- pine_id: PUB;e5b18a1ef276457b8f6573c6679fd3b4
- version: 1.0

## Description

HTF Radar V1 – Multi-Timeframe Level & Sweep Tracking
ATTENTION: The display range and historical accuracy of the levels depend directly on your TradingView subscription, as it determines the maximum number of available bars. Switching to a higher timeframe may produce a different visual result or reveal older levels that were previously hidden.

The HTF Radar V1 is a specialized analytical tool designed to identify and visualize significant price levels from higher timeframes. The indicator scans the market for pivot points across M15, H1, H4, and Daily intervals and tracks their relevance in real-time, with a specific focus on liquidity sweeps.

Core Features
Automatic HTF Level Mapping: Extracts swing highs and swing lows from four timeframe layers (M15, H1, H4, D) and projects them as dynamic lines onto the current chart.

Intelligent Segmentation System: If multiple HTF levels overlap at the same price, the lines are automatically segmented and displayed side-by-side. This allows for immediate visual recognition of "confluence zones."

Dynamic Glow-Lines & Sweep Tracking: Once a level is breached (swept), it transforms into a tracking "Glow-Line." This line follows the new extreme point until a trend reversal is confirmed by a local fractal.

NQ Auto-Detection Filter: Specifically designed for the Nasdaq (NQ), this algorithm automatically determines the ideal starting point for data calculation based on volume and efficiency. This helps exclude irrelevant historical data, such as price action before a contract rollover.

Real-Time Statistics Table: A compact dashboard showing the distance (in points/ticks) to the nearest HTF high and low levels, along with the current trend direction based on EMAs.

Visual Features & Operation
Interactive Tooltips: Hovering over level labels displays detailed information, including the exact timestamp of the pivot, the price level, and the original timeframe.

Visual Sweeps: Highlights liquidity grabs using distinct markers and optional "halo" effects directly on the chart.

Customizable Glow Logic: Users can choose whether the glow color remains the HTF color permanently or switches to a standard bullish/bearish color upon a trend break (fractal confirmation).

Technical Details
Multi-Timeframe Engine: Utilizes request.security with optimized data handling for both live analysis and backtesting.

Resource Efficient: Uses an optimized array structure to maintain performance even with a high number of active lines.

Alert System: Individually toggleable alerts for level sweeps for every configured timeframe.

Use Case
Ideal for traders utilizing Smart Money Concepts (SMC), ICT, or classic Support/Resistance strategies who require high-timeframe context without the need to constantly switch chart intervals.

License: MIT License
Developer: kp_eu_de

## Source Code

````pine
//@version=5
// © 2025 kp_eu_de
// Released under the MIT License

indicator("HTF Radar V1", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// --- [MODULARE CONTAINER] ---
var lastH_Price = array.new_float(1, na)
var lastH_Sweep = array.new_float(1, na)
var lastH_Color = array.new_color(1, na)
var lastH_Bar   = array.new_int(1, 0)
var lastH_TF    = array.new_string(1, "")
var lastH_Time  = array.new_string(1, "")

var lastL_Price = array.new_float(1, na)
var lastL_Sweep = array.new_float(1, na)
var lastL_Color = array.new_color(1, na)
var lastL_Bar   = array.new_int(1, 0)
var lastL_TF    = array.new_string(1, "")
var lastL_Time  = array.new_string(1, "")

var string[] barAlertArray = array.new_string(1, "")
var int[] glowBarsArray = array.new_int(2, na) 
var bool[] glowBrokenArray = array.new_bool(2, false)

// --- [SETTINGS: TIME & FILTER] ---
G_TIME = "Time Settings"
ttTime = "DE: Wähle deine lokale Zeitzone für die Tooltips\nEN: Select your local timezone for the tooltips"
i_timezone = input.string("Europe/Berlin", "Timezone", options=["Europe/Berlin", "Europe/London", "UTC", "America/New_York", "America/Chicago", "Asia/Tokyo", "Australia/Sydney", "Exchange (Börse)"], group=G_TIME, tooltip=ttTime)

groupFilter = "Time Filter"
ttNQ = "--- BITTE LESEN / PLEASE READ ---\n\nDEUTSCH\n• Manual Date: Ignoriert alle Preisdaten vor diesem Datum. Nützlich, um alte, irrelevante Level nach einem Kontraktwechsel auszuschließen.\n• Auto Detection NQ: Ermittelt den Startpunkt für NQ automatisch anhand von Volumen, Effizienz und Dichte. Dies ersetzt die manuelle Datumseingabe. Hinweis: Die Automatik liefert ein ungefähres Datum.\n• Info: Wenn 'Auto' gewählt ist, aber kein NQ-Chart aktiv ist, wird automatisch das manuelle Datum als Fallback verwendet.\n\n-----------------------\n\nENGLISH\n• Manual Date: Ignores all price data before this date.\n• Auto Detection NQ: Automatically detects the start point for NQ based on volume, efficiency, and density."

i_useFilter  = input.bool(true, "Filter active? (Check Tooltip!)", group=groupFilter, inline="filt", tooltip=ttNQ)
i_filterMode = input.string("Auto Detection NQ", "", options=["Manual Date", "Auto Detection NQ"], group=groupFilter, inline="filt")
i_startTime  = input.time(timestamp("2025-12-18 01:00"), "Manual Start Date", group=groupFilter)

// --- [SETTINGS: HTF LINE STATISTICS] ---
G_STAT = "HTF Line Statistics"
i_showStats = input.bool(true, "Show Info", group=G_STAT, inline="stat")
i_statSize  = input.string("small", "Size", options=["tiny", "small", "normal", "large", "huge"], group=G_STAT, inline="stat")
i_statTF    = input.bool(true, "TF", group=G_STAT, inline="stat")
i_statPrice = input.bool(true, "Price", group=G_STAT, inline="stat")
i_statDist  = input.bool(true, "Points", group=G_STAT, inline="stat")

// --- [SETTINGS: HTF & VISUAL] ---
G_HTF = "HTF Lines: Offset / Lines / Max / Toleranz"
ttAbbr = "DE: Linien\nO = Offset (Abstand zur Kerze)\nL = Line Length (Linienlänge)\nM = Max Lines (Maximale Linienanzahl)\nT = Tolerance (Abweichungstoleranz)\n\nEN: Lines\nO = Offset (Distance to bar)\nL = Line Length\nM = Max Lines\nT = Tolerance"
i_showLines    = input.bool(true, "Lines", group=G_HTF, tooltip=ttAbbr)
i_labelDist    = input.int(5, "O", minval=0, group=G_HTF, inline="Core")
i_lineLen      = input.int(10, "L", minval=1, group=G_HTF, inline="Core")
i_maxHtfLines  = input.int(5, "M", minval=1, group=G_HTF, inline="Core")
i_lineTol      = input.float(1.0, "T", minval=0, step=0.1, group=G_HTF, inline="Core")

ttM15 = "DE: Pivot = Lookback Perioden. 🔔 = Alarm-Auswahl.\nEN: Pivot = Lookback periods. 🔔 = Alert Selection."
ttH1  = "DE: Pivot = Lookback Perioden. 🔔 = Alarm-Auswahl.\nEN: Pivot = Lookback periods. 🔔 = Alert Selection."
ttH4  = "DE: Pivot = Lookback Perioden. 🔔 = Alarm-Auswahl.\nEN: Pivot = Lookback periods. 🔔 = Alert Selection."
ttD   = "DE: Pivot = Lookback Perioden. 🔔 = Alarm-Auswahl.\nEN: Pivot = Lookback periods. 🔔 = Alert Selection."

c_M15 = input.color(color.blue, "", group=G_HTF, inline="M15")
i_wM15 = input.int(2, "Width", minval=1, group=G_HTF, inline="M15")
i_lM15 = input.int(5, "Pivot", group=G_HTF, inline="M15", tooltip=ttM15)
i_useM15 = input.bool(true, "M15", group=G_HTF, inline="M15")
i_alM15 = input.bool(true, "🔔", group=G_HTF, inline="M15")

c_H1 = input.color(color.orange, "", group=G_HTF, inline="H1")
i_wH1 = input.int(2, "Width", minval=1, group=G_HTF, inline="H1")
i_lH1 = input.int(5, "Pivot", group=G_HTF, inline="H1", tooltip=ttH1)
i_useH1 = input.bool(true, "H1", group=G_HTF, inline="H1")
i_alH1 = input.bool(true, "🔔", group=G_HTF, inline="H1")

c_H4 = input.color(color.red, "", group=G_HTF, inline="H4")
i_wH4 = input.int(2, "Width", minval=1, group=G_HTF, inline="H4")
i_lH4 = input.int(5, "Pivot", group=G_HTF, inline="H4", tooltip=ttH4)
i_useH4 = input.bool(true, "H4", group=G_HTF, inline="H4")
i_alH4 = input.bool(true, "🔔", group=G_HTF, inline="H4")

c_D = input.color(color.purple, "", group=G_HTF, inline="D")
i_wD = input.int(2, "Width", minval=1, group=G_HTF, inline="D")
i_lD = input.int(5, "Pivot", group=G_HTF, inline="D", tooltip=ttD)
i_useD = input.bool(true, "D", group=G_HTF, inline="D")
i_alD = input.bool(true, "🔔", group=G_HTF, inline="D")

G_VIS = "Visual Sweep Extension"
i_showHalo = input.bool(true, "Halo", group=G_VIS, inline="Vis")
i_haloTransp = input.int(80, "", minval=0, maxval=100, group=G_VIS, inline="Vis")
i_leftLineLen = input.int(4, "", minval=1, maxval=50, group=G_VIS, inline="Vis")
i_showLeftLine = input.bool(true, "Line", group=G_VIS, inline="Vis")
i_useTooltip = input.bool(true, "Tooltip", group=G_VIS, inline="Vis")

// --- [SETTINGS: GLOW LINE & BEHAVIOR] ---
G_GLO = "glow line: Behavior / Width / Colors"
ttFrac = "DE: Bestimmt die Sensitivität der Umschaltung. Ein Fraktal in Gegenrichtung bestätigt den Trendbruch und schaltet von der HTF-Farbe auf die HH/LL-Farbe um.\n\nEN: Determines switching sensitivity. A counter-directional fractal confirms the trend break."
ttGlowCombined = "DE: Modus auswählen:\n1. Permanent HTF: Die Linie behält die HTF-Farbe bis zum nächsten Sweep.\n2. Change on HH/LL: Die Farbe wechselt zur Standardfarbe, sobald der Kurs nach einem Durchbruch ein Fraktal in der Gegenrichtung bestätigt.\n\nH = Halo Breite, T = Halo Transparenz\nC = Kern (Core) Breite, T = Kern Transparenz\nDie Glow-Linie folgt nach dem Sweep des HTF in dessen Farbe dem Kurs, bis dieser die Richtung umkehrt. Sie bleibt in dieser Farbe stehen, bis ein neues Level gesweept wird.\n\nEN: Select mode:\n1. Permanent HTF: The line keeps the HTF color until the next sweep.\n2. Change on HH/LL: The color changes to standard color as soon as price confirms a counter-directional fractal after a breakout."

i_showGlow   = input.bool(true, "Glow Line", group=G_GLO, inline="G1", tooltip=ttGlowCombined)
i_useEffHTF  = input.bool(true, "Glow", group=G_GLO, inline="G1") 
i_glowMode   = input.string("Permanent HTF", "", options=["Permanent HTF", "Change on HH/LL"], group=G_GLO, inline="G1")
i_glowBear   = input.color(color.new(#ff0000, 50), "", group=G_GLO, inline="G1") 
i_glowBull   = input.color(color.new(#00ff00, 50), "", group=G_GLO, inline="G1") 
i_useEffHHLL = input.bool(false, "Glow", group=G_GLO, inline="G1") 

i_glowHaloW  = input.int(6, "H", minval=1, group=G_GLO, inline="G2")
i_glowHaloT  = input.int(60, "T", minval=0, maxval=100, group=G_GLO, inline="G2")
i_glowCoreW  = input.int(1, "C", minval=1, group=G_GLO, inline="G2")
i_glowCoreT  = input.int(0, "T", minval=0, maxval=100, group=G_GLO, inline="G2")

i_fracLen    = input.int(2, "Fractal Period", minval=1, group=G_GLO, inline="G3", tooltip=ttFrac)

G_TAB = "Table Settings"
i_textSize = input.string("small", "Table Size", options=["tiny", "small", "normal", "large", "huge"], group=G_TAB, inline="Tab")
i_emaLen = input.int(50, "", minval=1, group=G_TAB, inline="Tab")
i_emaLen2 = input.int(200, "", minval=1, group=G_TAB, inline="Tab")
i_emaLabel = input.bool(true, "EMA", group=G_TAB, inline="Tab", tooltip="DE: EMA Längen werden für die Trendrichtungsanzeige in der Tabelle verwendet. Die farbigen Punkte vor dem HTF Namen in der Tabelle zeigen den Trend an: Grün (über beiden), Rot (unter beiden), Grau (zwischen beiden = neutral).")

// --- [NQ AUTO DETECTION] ---
var float t1V = 0.0, var float t1E = 0.0, var float t1D = 0.0
var float t2V = 0.0, var float t2E = 0.0, var float t2D = 0.0
var int b1 = 0, var int b2 = 0
var bool gestartet = false
var int autoStartTime = na
isNewDay = ta.change(time("D")) != 0
eff = ta.tr > 0 ? (math.abs(open - close) / ta.tr) * 100 : 0
dic = volume / math.max(ta.atr(14), 1)
if not gestartet
    if isNewDay
        t2V := t1V, t2E := t1E, t2D := t1D, b2 := b1
        t1V := 0.0, t1E := 0.0, t1D := 0.0, b1 := 0
    t1V += volume, t1E += eff, t1D += dic, b1 += 1
    if b2 > 0 and (t1V + t2V) / (b1 + b2) > 400 and (t1E + t2E) / (b1 + b2) > 45 and (t1D + t2D) / (b1 + b2) > 45
        gestartet := true, autoStartTime := time
isNQ = str.contains(syminfo.ticker, "NQ")
finalStart = i_useFilter ? (i_filterMode == "Auto Detection NQ" and isNQ and not na(autoStartTime) ? autoStartTime : i_startTime) : 0

// --- [ARRAYS] ---
var line[] m15_lines = array.new_line(), var label[] m15_tt = array.new_label(), var label[] m15_stat = array.new_label(), var string[] m15_times = array.new_string()
var line[] h1_lines  = array.new_line(), var label[] h1_tt  = array.new_label(), var label[] h1_stat  = array.new_label(), var string[] h1_times  = array.new_string()
var line[] h4_lines  = array.new_line(), var label[] h4_tt  = array.new_label(), var label[] h4_stat  = array.new_label(), var string[] h4_times  = array.new_string()
var line[] d_lines   = array.new_line(), var label[] d_tt   = array.new_label(), var label[] d_stat   = array.new_label(), var string[] d_times   = array.new_string()

// --- [HILFSFUNKTIONEN] ---
f_get_time(t) =>
    t_z = i_timezone == "Exchange (Börse)" ? syminfo.timezone : i_timezone
    dw = dayofweek(t, t_z), d = dayofmonth(t, t_z), mo = month(t, t_z)
    h = hour(t, t_z), m = minute(t, t_z)
    wd = dw == 2 ? "Mo" : dw == 3 ? "Di" : dw == 4 ? "Mi" : dw == 5 ? "Do" : dw == 6 ? "Fr" : dw == 7 ? "Sa" : "So"
    str.format("{0}, {1,number,00}.{2,number,00}. {3,number,00}:{4,number,00}", wd, d, mo, h, m)
    
f_pts(v) => str.tostring(math.round(math.abs(close - v)))

f_txt_v66(v, p) => 
    res = ""
    if not na(v) and v != 0
        res := str.tostring(math.round(math.abs(p - v)))
    res

f_find_time_tf(val, l_arr, t_arr) =>
    res = ""
    float tol = i_lineTol * syminfo.mintick
    if array.size(l_arr) > 0
        for i = 0 to array.size(l_arr) - 1
            if math.abs(line.get_y1(array.get(l_arr, i)) - val) <= tol
                res := array.get(t_arr, i), break
    res

f_get_closest_level(line[] l_arr, bool search_high) =>
    float closest_p = na, float min_diff = 1e10
    if array.size(l_arr) > 0
        for i = 0 to array.size(l_arr) - 1
            l_p = line.get_y1(array.get(l_arr, i))
            if search_high
                if l_p > close and (l_p - close) < min_diff
                    min_diff := l_p - close, closest_p := l_p
            else
                if l_p < close and (close - l_p) < min_diff
                    min_diff := close - l_p, closest_p := l_p
    closest_p

f_get_combined_tfs(val) =>
    res = ""
    float tol = i_lineTol * syminfo.mintick
    if array.size(d_lines) > 0
        for i = 0 to array.size(d_lines) - 1
            if math.abs(line.get_y1(array.get(d_lines, i)) - val) <= tol
                res += (res != "" ? "/" : "") + "D", break
    if array.size(h4_lines) > 0
        for i = 0 to array.size(h4_lines) - 1
            if math.abs(line.get_y1(array.get(h4_lines, i)) - val) <= tol
                res += (res != "" ? "/" : "") + "H4", break
    if array.size(h1_lines) > 0
        for i = 0 to array.size(h1_lines) - 1
            if math.abs(line.get_y1(array.get(h1_lines, i)) - val) <= tol
                res += (res != "" ? "/" : "") + "H1", break
    if array.size(m15_lines) > 0
        for i = 0 to array.size(m15_lines) - 1
            if math.abs(line.get_y1(array.get(m15_lines, i)) - val) <= tol
                res += (res != "" ? "/" : "") + "M15", break
    res

f_is_primary_tf(val, current_tf) =>
    float tol = i_lineTol * syminfo.mintick
    res = true
    if current_tf == "M15"
        if array.size(h1_lines) > 0
            for i = 0 to array.size(h1_lines) - 1
                if math.abs(line.get_y1(array.get(h1_lines, i)) - val) <= tol
                    res := false, break
    if (current_tf == "M15" or current_tf == "H1") and res
        if array.size(h4_lines) > 0
            for i = 0 to array.size(h4_lines) - 1
                if math.abs(line.get_y1(array.get(h4_lines, i)) - val) <= tol
                    res := false, break
    if (current_tf == "M15" or current_tf == "H1" or current_tf == "H4") and res
        if array.size(d_lines) > 0
            for i = 0 to array.size(d_lines) - 1
                if math.abs(line.get_y1(array.get(d_lines, i)) - val) <= tol
                    res := false, break
    res

f_get_trend_col(ema1, ema2) => 
    if close > ema1 and close > ema2
        color.lime
    else if close < ema1 and close < ema2
        color.red
    else
        color.gray

// --- [HTF UPDATE LOGIC] ---
method update_htf_swings(float val, int peakTime, color col, int wid, line[] l_arr, label[] t_arr, label[] s_arr, string[] time_arr, string tf) =>
    if not na(val) and time >= finalStart
        float tol = i_lineTol * syminfo.mintick
        bool swept = high >= val - tol and low <= val + tol
        exists = false
        if array.size(l_arr) > 0
            for i = 0 to array.size(l_arr) - 1
                if math.round(line.get_y1(array.get(l_arr, i)) / syminfo.mintick) == math.round(val / syminfo.mintick)
                    exists := true, break
        if not exists and not swept
            x1 = bar_index + i_labelDist
            new_line = line.new(x1, val, x1 + i_lineLen, val, color=col, width=wid)
            array.push(l_arr, new_line)
            t_str = f_get_time(peakTime)
            array.push(time_arr, t_str)
            new_lb = label.new(x1, val, "__________", color=color.new(color.black, 100), textcolor=color.new(color.black, 100), style=label.style_label_center)
            array.push(t_arr, new_lb)
            new_sl = label.new(x1 + i_lineLen, val, "", color=color.new(color.black, 100), textcolor=col, style=label.style_label_left, size=i_statSize)
            array.push(s_arr, new_sl)
            if array.size(l_arr) > i_maxHtfLines
                line.delete(array.shift(l_arr)), label.delete(array.shift(t_arr)), label.delete(array.shift(s_arr)), array.shift(time_arr)

// --- [HTF DATA REQUESTS] ---
m15_ph = request.security(syminfo.tickerid, "15", ta.pivothigh(high, i_lM15, i_lM15), lookahead=barmerge.lookahead_on)
m15_ptH = request.security(syminfo.tickerid, "15", ta.valuewhen(ta.pivothigh(high, i_lM15, i_lM15), time[i_lM15], 0), lookahead=barmerge.lookahead_on)
m15_pl = request.security(syminfo.tickerid, "15", ta.pivotlow(low, i_lM15, i_lM15), lookahead=barmerge.lookahead_on)
m15_ptL = request.security(syminfo.tickerid, "15", ta.valuewhen(ta.pivotlow(low, i_lM15, i_lM15), time[i_lM15], 0), lookahead=barmerge.lookahead_on)
m15_e1 = request.security(syminfo.tickerid, "15", ta.ema(close, i_emaLen)), m15_e2 = request.security(syminfo.tickerid, "15", ta.ema(close, i_emaLen2))

h1_ph = request.security(syminfo.tickerid, "60", ta.pivothigh(high, i_lH1, i_lH1), lookahead=barmerge.lookahead_on)
h1_ptH = request.security(syminfo.tickerid, "60", ta.valuewhen(ta.pivothigh(high, i_lH1, i_lH1), time[i_lH1], 0), lookahead=barmerge.lookahead_on)
h1_pl = request.security(syminfo.tickerid, "60", ta.pivotlow(low, i_lH1, i_lH1), lookahead=barmerge.lookahead_on)
h1_ptL = request.security(syminfo.tickerid, "60", ta.valuewhen(ta.pivotlow(low, i_lH1, i_lH1), time[i_lH1], 0), lookahead=barmerge.lookahead_on)
h1_e1 = request.security(syminfo.tickerid, "60", ta.ema(close, i_emaLen)), h1_e2 = request.security(syminfo.tickerid, "60", ta.ema(close, i_emaLen2))

h4_ph = request.security(syminfo.tickerid, "240", ta.pivothigh(high, i_lH4, i_lH4), lookahead=barmerge.lookahead_on)
h4_ptH = request.security(syminfo.tickerid, "240", ta.valuewhen(ta.pivothigh(high, i_lH4, i_lH4), time[i_lH4], 0), lookahead=barmerge.lookahead_on)
h4_pl = request.security(syminfo.tickerid, "240", ta.pivotlow(low, i_lH4, i_lH4), lookahead=barmerge.lookahead_on)
h4_ptL = request.security(syminfo.tickerid, "240", ta.valuewhen(ta.pivotlow(low, i_lH4, i_lH4), time[i_lH4], 0), lookahead=barmerge.lookahead_on)
h4_e1 = request.security(syminfo.tickerid, "240", ta.ema(close, i_emaLen)), h4_e2 = request.security(syminfo.tickerid, "240", ta.ema(close, i_emaLen2))

d_ph = request.security(syminfo.tickerid, "D", ta.pivothigh(high, i_lD, i_lD), lookahead=barmerge.lookahead_on)
d_ptH = request.security(syminfo.tickerid, "D", ta.valuewhen(ta.pivothigh(high, i_lD, i_lD), time[i_lD], 0), lookahead=barmerge.lookahead_on)
d_pl = request.security(syminfo.tickerid, "D", ta.pivotlow(low, i_lD, i_lD), lookahead=barmerge.lookahead_on)
d_ptL = request.security(syminfo.tickerid, "D", ta.valuewhen(ta.pivotlow(low, i_lD, i_lD), time[i_lD], 0), lookahead=barmerge.lookahead_on)
d_e1 = request.security(syminfo.tickerid, "D", ta.ema(close, i_emaLen)), d_e2 = request.security(syminfo.tickerid, "D", ta.ema(close, i_emaLen2))

process_htf_cleanup(line[] l_arr, label[] t_arr, label[] s_arr, string[] time_arr, color col, int wid, bool use_sweep, string tf) =>
    if array.size(l_arr) > 0
        float t_val = i_lineTol * syminfo.mintick
        for i = array.size(l_arr) - 1 to 0
            ln = array.get(l_arr, i), p_ln = line.get_y1(ln), lb = array.get(t_arr, i), ls = array.get(s_arr, i)
            if (low <= p_ln + t_val and high >= p_ln - t_val)
                if use_sweep
                    t_hit = f_get_time(time)
                    isAlActive = (tf == "M15" and i_alM15) or (tf == "H1" and i_alH1) or (tf == "H4" and i_alH4) or (tf == "D" and i_alD)
                    if isAlActive
                        currentMsg = array.get(barAlertArray, 0)
                        array.set(barAlertArray, 0, currentMsg + (currentMsg == "" ? "" : " + ") + tf)
                    label_bg = i_showHalo ? color.new(col, i_haloTransp) : color.new(color.white, 100)
                    label.new(bar_index, p_ln, "⦿", color=label_bg, textcolor=col, style=label.style_label_center, size=size.small)
                    if i_showLeftLine
                        line.new(bar_index, p_ln, bar_index - i_leftLineLen, p_ln, color=col, width=1)
                    
                    if p_ln >= close[1]
                        oldBarH = array.get(lastH_Bar, 0), oldTFH = array.get(lastH_TF, 0)
                        newTFH = (oldBarH == bar_index and oldTFH != "") ? (str.contains(oldTFH, tf) ? oldTFH : oldTFH + "/" + tf) : tf
                        array.set(lastH_Price, 0, p_ln), array.set(lastH_Sweep, 0, p_ln), array.set(lastH_Color, 0, col), array.set(lastH_Bar, 0, bar_index), array.set(lastH_TF, 0, newTFH), array.set(lastH_Time, 0, t_hit)
                        array.set(glowBarsArray, 0, bar_index), array.set(glowBrokenArray, 0, false)
                    else
                        oldBarL = array.get(lastL_Bar, 0), oldTFL = array.get(lastL_TF, 0)
                        newTFL = (oldBarL == bar_index and oldTFL != "") ? (str.contains(oldTFL, tf) ? oldTFL : oldTFL + "/" + tf) : tf
                        array.set(lastL_Price, 0, p_ln), array.set(lastL_Sweep, 0, p_ln), array.set(lastL_Color, 0, col), array.set(lastL_Bar, 0, bar_index), array.set(lastL_TF, 0, newTFL), array.set(lastL_Time, 0, t_hit)
                        array.set(glowBarsArray, 1, bar_index), array.set(glowBrokenArray, 1, false)
                
                line.delete(ln)
                label.delete(lb)
                label.delete(ls)
                array.remove(l_arr, i)
                array.remove(t_arr, i)
                array.remove(s_arr, i)
                array.remove(time_arr, i)
            else
                line.set_color(ln, col)
                line.set_width(ln, wid)
                line.set_x1(ln, bar_index + i_labelDist)
                line.set_x2(ln, bar_index + i_labelDist + i_lineLen)
                label.set_x(lb, bar_index + i_labelDist)
                label.set_y(lb, p_ln)
                label.set_x(ls, bar_index + i_labelDist + i_lineLen)
                label.set_y(ls, p_ln)
                label.set_size(ls, i_statSize)
                if i_useTooltip
                    tt_seg = ""
                    t_d = f_find_time_tf(p_ln, d_lines, d_times), t_h4 = f_find_time_tf(p_ln, h4_lines, h4_times), t_h1 = f_find_time_tf(p_ln, h1_lines, h1_times), t_m15 = f_find_time_tf(p_ln, m15_lines, m15_times)
                    if t_d != "" 
                        tt_seg += "Detected: D, " + t_d + " @ " + str.tostring(p_ln, "#.##########") + " (" + f_pts(p_ln) + ")\n"
                    if t_h4 != "" 
                        tt_seg += "Detected: H4, " + t_h4 + " @ " + str.tostring(p_ln, "#.##########") + " (" + f_pts(p_ln) + ")\n"
                    if t_h1 != "" 
                        tt_seg += "Detected: H1, " + t_h1 + " @ " + str.tostring(p_ln, "#.##########") + " (" + f_pts(p_ln) + ")\n"
                    if t_m15 != "" 
                        tt_seg += "Detected: M15, " + t_m15 + " @ " + str.tostring(p_ln, "#.##########") + " (" + f_pts(p_ln) + ")\n"
                    label.set_tooltip(lb, tt_seg)
                if f_is_primary_tf(p_ln, tf)
                    if i_showStats
                        label.set_text(ls, (i_statTF ? f_get_combined_tfs(p_ln) : "") + (i_statPrice ? " @ " + str.tostring(p_ln, "#.##########") : "") + (i_statDist ? " (" + f_pts(p_ln) + ")" : ""))
                else
                    label.set_text(ls, "")
    0

if barstate.isconfirmed
    m15_ph.update_htf_swings(m15_ptH, c_M15, i_wM15, m15_lines, m15_tt, m15_stat, m15_times, "M15")
    m15_pl.update_htf_swings(m15_ptL, c_M15, i_wM15, m15_lines, m15_tt, m15_stat, m15_times, "M15")
    h1_ph.update_htf_swings(h1_ptH, c_H1, i_wH1, h1_lines, h1_tt, h1_stat, h1_times, "H1")
    h1_pl.update_htf_swings(h1_ptL, c_H1, i_wH1, h1_lines, h1_tt, h1_stat, h1_times, "H1")
    h4_ph.update_htf_swings(h4_ptH, c_H4, i_wH4, h4_lines, h4_tt, h4_stat, h4_times, "H4")
    h4_pl.update_htf_swings(h4_ptL, c_H4, i_wH4, h4_lines, h4_tt, h4_stat, h4_times, "H4")
    d_ph.update_htf_swings(d_ptH, c_D, i_wD, d_lines, d_tt, d_stat, d_times, "D")
    d_pl.update_htf_swings(d_ptL, c_D, i_wD, d_lines, d_tt, d_stat, d_times, "D")

if i_showLines
    process_htf_cleanup(m15_lines, m15_tt, m15_stat, m15_times, c_M15, i_wM15, i_useM15, "M15")
    process_htf_cleanup(h1_lines, h1_tt, h1_stat, h1_times, c_H1, i_wH1, i_useH1, "H1")
    process_htf_cleanup(h4_lines, h4_tt, h4_stat, h4_times, c_H4, i_wH4, i_useH4, "H4")
    process_htf_cleanup(d_lines, d_tt, d_stat, d_times, c_D, i_wD, i_useD, "D")

// --- [DYNAMISCHE NACHFOLGE & BAR-TRACKING] ---
curH_Price_val = array.get(lastH_Price, 0)
curL_Price_val = array.get(lastL_Price, 0)

if not na(curH_Price_val) and high > curH_Price_val
    array.set(lastH_Price, 0, high)
    array.set(glowBarsArray, 0, bar_index)
if not na(curL_Price_val) and low < curL_Price_val
    array.set(lastL_Price, 0, low)
    array.set(glowBarsArray, 1, bar_index)

// --- [REALE SEGMENTIERUNGS-LOGIK] ---
f_draw_all_segments(line[] l_arr, color col) =>
    if array.size(l_arr) > 0
        float tol = i_lineTol * syminfo.mintick
        for i = 0 to array.size(l_arr) - 1
            ln = array.get(l_arr, i), p_ln = line.get_y1(ln)
            hasD = false, hasH4 = false, hasH1 = false, hasM15 = false
            if array.size(d_lines) > 0
                for j = 0 to array.size(d_lines) - 1
                    if math.abs(line.get_y1(array.get(d_lines, j)) - p_ln) <= tol
                        hasD := true, break
            if array.size(h4_lines) > 0
                for j = 0 to array.size(h4_lines) - 1
                    if math.abs(line.get_y1(array.get(h4_lines, j)) - p_ln) <= tol
                        hasH4 := true, break
            if array.size(h1_lines) > 0
                for j = 0 to array.size(h1_lines) - 1
                    if math.abs(line.get_y1(array.get(h1_lines, j)) - p_ln) <= tol
                        hasH1 := true, break
            if array.size(m15_lines) > 0
                for j = 0 to array.size(m15_lines) - 1
                    if math.abs(line.get_y1(array.get(m15_lines, j)) - p_ln) <= tol
                        hasM15 := true, break
            int shares = (hasD ? 1 : 0) + (hasH4 ? 1 : 0) + (hasH1 ? 1 : 0) + (hasM15 ? 1 : 0)
            int pos = 0
            if col == c_D and hasD
                pos := 1
            else if col == c_H4 and hasH4
                pos := (hasD ? 1 : 0) + 1
            else if col == c_H1 and hasH1
                pos := (hasD ? 1 : 0) + (hasH4 ? 1 : 0) + 1
            else if col == c_M15 and hasM15
                pos := (hasD ? 1 : 0) + (hasH4 ? 1 : 0) + (hasH1 ? 1 : 0) + 1
            if shares > 1
                segLen = math.floor(i_lineLen / shares)
                x1 = bar_index + i_labelDist + (pos - 1) * segLen
                x2 = (pos == shares) ? bar_index + i_labelDist + i_lineLen : x1 + segLen
                line.set_x1(ln, x1)
                line.set_x2(ln, x2)

if i_showLines
    f_draw_all_segments(d_lines, c_D)
    f_draw_all_segments(h4_lines, c_H4)
    f_draw_all_segments(h1_lines, c_H1)
    f_draw_all_segments(m15_lines, c_M15)

// --- [TABLE DRAWING] ---
if barstate.islast
    var table t = table.new(position.bottom_right, 4, 6)
    table.cell(t, 1, 0, "HTF", text_color=color.gray, text_size=i_textSize)
    table.cell(t, 2, 0, "High", text_color=color.gray, text_size=i_textSize)
    table.cell(t, 3, 0, "Low", text_color=color.gray, text_size=i_textSize)
    dot = i_emaLabel ? "●" : ""
    m15_h = f_get_closest_level(m15_lines, true), m15_l = f_get_closest_level(m15_lines, false)
    h1_h  = f_get_closest_level(h1_lines, true), h1_l  = f_get_closest_level(h1_lines, false)
    h4_h  = f_get_closest_level(h4_lines, true), h4_l  = f_get_closest_level(h4_lines, false)
    d_h   = f_get_closest_level(d_lines, true), d_l   = f_get_closest_level(d_lines, false)
    table.cell(t, 0, 2, dot, text_color=f_get_trend_col(m15_e1, m15_e2), text_size=i_textSize)
    table.cell(t, 1, 2, "M15", text_color=c_M15, text_size=i_textSize, text_halign=text.align_left)
    table.cell(t, 2, 2, f_txt_v66(m15_h, close), text_color=c_M15, text_size=i_textSize)
    table.cell(t, 3, 2, f_txt_v66(m15_l, close), text_color=c_M15, text_size=i_textSize)
    table.cell(t, 0, 3, dot, text_color=f_get_trend_col(h1_e1, h1_e2), text_size=i_textSize)
    table.cell(t, 1, 3, "H1", text_color=c_H1, text_size=i_textSize, text_halign=text.align_left)
    table.cell(t, 2, 3, f_txt_v66(h1_h, close), text_color=c_H1, text_size=i_textSize)
    table.cell(t, 3, 3, f_txt_v66(h1_l, close), text_color=c_H1, text_size=i_textSize)
    table.cell(t, 0, 4, dot, text_color=f_get_trend_col(h4_e1, h4_e2), text_size=i_textSize)
    table.cell(t, 1, 4, "H4", text_color=c_H4, text_size=i_textSize, text_halign=text.align_left)
    table.cell(t, 2, 4, f_txt_v66(h4_h, close), text_color=c_H4, text_size=i_textSize)
    table.cell(t, 3, 4, f_txt_v66(h4_l, close), text_color=c_H4, text_size=i_textSize)
    table.cell(t, 0, 5, dot, text_color=f_get_trend_col(d_e1, d_e2), text_size=i_textSize)
    table.cell(t, 1, 5, "D", text_color=c_D, text_size=i_textSize, text_halign=text.align_left)
    table.cell(t, 2, 5, f_txt_v66(d_h, close), text_color=c_D, text_size=i_textSize)
    table.cell(t, 3, 5, f_txt_v66(d_l, close), text_color=c_D, text_size=i_textSize)

// --- [DYNAMISCHE NACHFOLGE & STRIKTE FRACTAL LOGIK] ---
f_isPivotH(len) =>
    p = high[len], ok = true
    for i = 0 to len * 2
        if i != len and high[i] >= p
            ok := false
            break
    ok

f_isPivotL(len) =>
    p = low[len], ok = true
    for i = 0 to len * 2
        if i != len and low[i] <= p
            ok := false
            break
    ok

fTopC = f_isPivotH(i_fracLen)
fBottomC = f_isPivotL(i_fracLen)

p_cH = array.get(lastH_Price, 0), p_sH_val = array.get(lastH_Sweep, 0), p_sH_Bar = array.get(lastH_Bar, 0)
p_cL = array.get(lastL_Price, 0), p_sL_val = array.get(lastL_Sweep, 0), p_sL_Bar = array.get(lastL_Bar, 0)

// --- [KORRIGIERTE RICHTUNGSWECHSEL-LOGIK] ---
if barstate.isconfirmed
    // WIDERSTAND (High Sweep Glow)
    if not na(p_cH)
        if high > p_cH
            array.set(lastH_Price, 0, high)
            array.set(glowBarsArray, 0, bar_index)
            array.set(glowBrokenArray, 0, false) // Reset bei neuem High
        else if i_glowMode == "Change on HH/LL" and not array.get(glowBrokenArray, 0)
            // Ein Pivot Low bestätigt den Richtungswechsel weg vom HTF-Fokus
            if fBottomC and (bar_index - i_fracLen) > p_sH_Bar
                array.set(glowBrokenArray, 0, true)

    // UNTERSTÜTZUNG (Low Sweep Glow)
    if not na(p_cL)
        if low < p_cL
            array.set(lastL_Price, 0, low)
            array.set(glowBarsArray, 1, bar_index)
            array.set(glowBrokenArray, 1, false) // Reset bei neuem Low
        else if i_glowMode == "Change on HH/LL" and not array.get(glowBrokenArray, 1)
            // Ein Pivot High bestätigt den Richtungswechsel weg vom HTF-Fokus
            if fTopC and (bar_index - i_fracLen) > p_sL_Bar
                array.set(glowBrokenArray, 1, true)
// --- [DYNAMISCHE GLOW DARSTELLUNG FINAL] ---
var line glowKernH = na, var line glowHaloH = na, var label glowTTH = na
var line glowKernL = na, var line glowHaloL = na, var label glowTTL = na

if barstate.islast and i_showGlow
    // --- HIGH SIDE (Widerstand) ---
    v_P_H = array.get(lastH_Price, 0), v_T_H = array.get(lastH_Time, 0), v_TF_H = array.get(lastH_TF, 0)
    v_B_H = array.get(lastH_Bar, 0), v_PeakB_H = array.get(glowBarsArray, 0), is_Brk_H = array.get(glowBrokenArray, 0), v_C_H = array.get(lastH_Color, 0)
    
    if not na(v_P_H) and v_B_H > bar_index - 4900
        line.delete(glowKernH), line.delete(glowHaloH), label.delete(glowTTH)
        
        // Startpunkt-Logik: Bei HTF-Fokus ab Sweep-Bar, bei HHLL-Fokus ab Peak-Bar
        int d_X1_H = is_Brk_H ? v_PeakB_H : v_B_H
        d_X1_H := math.min(math.max(0, d_X1_H), bar_index)
        
        bool d_Eff_H = is_Brk_H ? i_useEffHHLL : i_useEffHTF
        color d_ColK_H = is_Brk_H ? i_glowBear : color.new(v_C_H, i_glowCoreT)
        color d_ColG_H = is_Brk_H ? color.new(i_glowBear, i_glowHaloT) : color.new(v_C_H, i_glowHaloT)
        
        if d_Eff_H
            glowHaloH := line.new(d_X1_H, v_P_H, bar_index, v_P_H, color=d_ColG_H, width=i_glowHaloW)
        glowKernH := line.new(d_X1_H, v_P_H, bar_index, v_P_H, color=d_ColK_H, width=i_glowCoreW)
        
        if i_useTooltip
            tt_H = "Sweep: " + v_TF_H + ", " + v_T_H + " @ " + str.tostring(v_P_H, "#.##") + "\n" + "Current: " + str.tostring(close, "#.##") + " (" + f_pts(v_P_H) + ")"
            glowTTH := label.new(bar_index, v_P_H, "", color=color.new(color.black, 100), tooltip=tt_H)

    // --- LOW SIDE (Unterstützung) ---
    v_P_L = array.get(lastL_Price, 0), v_T_L = array.get(lastL_Time, 0), v_TF_L = array.get(lastL_TF, 0)
    v_B_L = array.get(lastL_Bar, 0), v_PeakB_L = array.get(glowBarsArray, 1), is_Brk_L = array.get(glowBrokenArray, 1), v_C_L = array.get(lastL_Color, 0)
    
    if not na(v_P_L) and v_B_L > bar_index - 4900
        line.delete(glowKernL), line.delete(glowHaloL), label.delete(glowTTL)
        
        int d_X1_L = is_Brk_L ? v_PeakB_L : v_B_L
        d_X1_L := math.min(math.max(0, d_X1_L), bar_index)
        
        bool d_Eff_L = is_Brk_L ? i_useEffHHLL : i_useEffHTF
        color d_ColK_L = is_Brk_L ? i_glowBull : color.new(v_C_L, i_glowCoreT)
        color d_ColG_L = is_Brk_L ? color.new(i_glowBull, i_glowHaloT) : color.new(v_C_L, i_glowHaloT)
        
        if d_Eff_L
            glowHaloL := line.new(d_X1_L, v_P_L, bar_index, v_P_L, color=d_ColG_L, width=i_glowHaloW)
        glowKernL := line.new(d_X1_L, v_P_L, bar_index, v_P_L, color=d_ColK_L, width=i_glowCoreW)
        
        if i_useTooltip
            tt_L = "Sweep: " + v_TF_L + ", " + v_T_L + " @ " + str.tostring(v_P_L, "#.##") + "\n" + "Current: " + str.tostring(close, "#.##") + " (" + f_pts(v_P_L) + ")"
            glowTTL := label.new(bar_index, v_P_L, "", color=color.new(color.black, 100), tooltip=tt_L)
// --- [MODULARES ALERT SYSTEM] ---
finalBarMsg = array.get(barAlertArray, 0)
if finalBarMsg != ""
    alert("HTF Sweep: " + finalBarMsg + " @ " + str.tostring(close), alert.freq_once_per_bar)
    array.set(barAlertArray, 0, "")
````
