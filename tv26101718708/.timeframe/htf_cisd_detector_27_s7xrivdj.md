# HTF CISD Detector 2.7

- url: https://www.tradingview.com/script/s7xrIVdJ/
- type: indicator
- pine_id: PUB;c2ab0d1d397e4f93922644bdb8ada1fe
- version: 1.0

## Description

HTF CISD Detector — Pine Script v6
Detects Change in State of Delivery (CISD) signals using ICT / Smart Money Concepts methodology on a higher timeframe (HTF) auto-selected based on your current chart resolution.
How it works:
The indicator monitors the HTF automatically (M5 → H1, H1 → H4, H4 → D1, etc.) for Order Blocks (OB): the last bullish candle before a bearish move, or the last bearish candle before a bullish move. A CISD is confirmed when a candle closes strictly beyond the OB open on the lower timeframe chart, signaling a potential Change in State of Delivery.
Features:

Auto HTF selection — no manual timeframe input needed
Draws horizontal price lines at the CISD level with label (e.g. "CISD H1")
Plots SL/TP boxes using swing-based Stop Loss detection and configurable Risk:Reward ratio
Auto-removes boxes when SL or TP is hit
Supports up to N simultaneous CISDs (configurable)
Optional: show only first active CISD per direction
Optional: minimum OB candle size filter
Optional: candle body size label on confirmation bar
Full color, transparency, line width, and box width customization

Settings:

Show/hide bullish and bearish CISDs independently
SL lookback and swing strength (pivot length min/max)
RR ratio for TP calculation
Box width in candles (adjusts in real time)
Auto-remove on SL/TP hit

Methodology:
Based on ICT Inner Circle Trader concepts. Best used on NQ/ES futures, Forex, and Crypto during active sessions. Combine with liquidity sweeps and session bias for higher-probability entries.

## Source Code

````pine
//@version=6
indicator("HTF CISD Detector 2.7", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// =========================
// INPUTS
// =========================
htf1_show_bull  = input.bool(true,  "Alcistas", group="CISD HTF 1", inline="h1bull")
htf1_color_bull = input.color(color.new(color.blue, 0), "", group="CISD HTF 1", inline="h1bull")
htf1_show_bear  = input.bool(true,  "Bajistas", group="CISD HTF 1", inline="h1bear")
htf1_color_bear = input.color(color.new(color.red, 0),  "", group="CISD HTF 1", inline="h1bear")
htf1_ext_lines  = input.int(30,  "Extensión líneas",   minval=5,   maxval=500,  group="CISD HTF 1")
htf1_line_width = input.int(2,   "Grosor",             minval=1,   maxval=4,    group="CISD HTF 1")
htf1_max_cisd   = input.int(1,   "Máx CISDs visibles", minval=1,   maxval=20,   group="CISD HTF 1")
htf1_only_first = input.bool(true, "Solo primer CISD activo", group="CISD HTF 1")
htf1_min_candle = input.float(0, "Tamaño mínimo vela OB", minval=0, step=0.5,   group="Filtros HTF 1")
htf1_sl_lookback = input.int(30, "Lookback SL",  minval=5, maxval=200, group="Filtros HTF 1")
htf1_swing_min   = input.int(2,  "Swing mínimo", minval=2, maxval=10,  group="Filtros HTF 1")
htf1_swing_max   = input.int(5,  "Swing máximo", minval=2, maxval=20,  group="Filtros HTF 1")
htf1_show_body   = input.bool(false, "Mostrar tamaño cuerpo", group="CISD HTF 1")
htf1_body_size   = input.string("normal", "Tamaño label", options=["small","normal","large"], group="CISD HTF 1")
htf1_show_boxes  = input.bool(true,  "Mostrar cajas",      group="CISD HTF 1")
htf1_show_labels = input.bool(true,  "Etiquetas en cajas", group="CISD HTF 1")
htf1_auto_sl     = input.bool(true,  "Auto-eliminar al SL",group="CISD HTF 1")
htf1_box_width   = input.int(12,    "Ancho caja (velas)", minval=5, maxval=400, group="CISD HTF 1")
htf1_transparency= input.int(75,    "Transparencia",      minval=0, maxval=100, step=5, group="CISD HTF 1")
htf1_rr          = input.float(1.6, "RR",                 minval=0.5, maxval=10.0, step=0.1, group="CISD HTF 1")
htf1_color_tp    = input.color(color.new(#84868b, 90), "Color TP", group="CISD HTF 1")
htf1_color_sl    = input.color(color.new(#1789e6, 90), "Color SL", group="CISD HTF 1")

// =========================
// SEGUNDOS DEL CHART TF — capturado una sola vez al inicio
// =========================
var int chart_tf_ms = timeframe.in_seconds() * 1000

// =========================
// TF AUTOMÁTICO (sin input)
// =========================
tf_minutes = timeframe.in_seconds() / 60

string tf1_resolved =
     tf_minutes <= 1  ? "5"   :
     tf_minutes <= 2  ? "16"  :
     tf_minutes <= 3  ? "30"  :
     tf_minutes <= 5  ? "60"  :
     tf_minutes <= 15 ? "240" : "D"

string tf1_label =
     tf_minutes <= 1  ? "M5"  :
     tf_minutes <= 2  ? "M16" :
     tf_minutes <= 3  ? "M30" :
     tf_minutes <= 5  ? "H1"  :
     tf_minutes <= 15 ? "H4"  : "D1"

// =========================
// TIPOS
// =========================
type OBCandidate
    float ob_open
    float ob_high
    float ob_low
    bool  is_bull
    int   start_time
    int   creation_bar

type CISDObjects
    line  cisd_line
    label cisd_label
    box   sl_box
    box   tp_box
    label sl_label
    label tp_label
    line  rr_line
    label body_label
    int   timestamp
    float sl_level
    float tp_level
    bool  is_bull_cisd
    bool  is_active

// =========================
// ARRAYS
// =========================
var OBCandidate[] h1_obs   = array.new<OBCandidate>()
var int[]         h1_drawn = array.new<int>()
var CISDObjects[] h1_objs  = array.new<CISDObjects>()

// =========================
// HTF1 DATA
// =========================
h1_time   = request.security(syminfo.tickerid, tf1_resolved, time,     lookahead=barmerge.lookahead_off)
h1_open1  = request.security(syminfo.tickerid, tf1_resolved, open[1],  lookahead=barmerge.lookahead_off)
h1_close1 = request.security(syminfo.tickerid, tf1_resolved, close[1], lookahead=barmerge.lookahead_off)
h1_high1  = request.security(syminfo.tickerid, tf1_resolved, high[1],  lookahead=barmerge.lookahead_off)
h1_low1   = request.security(syminfo.tickerid, tf1_resolved, low[1],   lookahead=barmerge.lookahead_off)
h1_time1  = request.security(syminfo.tickerid, tf1_resolved, time[1],  lookahead=barmerge.lookahead_off)
h1_close  = request.security(syminfo.tickerid, tf1_resolved, close,    lookahead=barmerge.lookahead_off)

// =========================
// DETECTAR OBs HTF1
// =========================
htf_changed = ta.change(h1_time) != 0

if htf_changed and not na(h1_close1)
    csize = math.abs(h1_close1 - h1_open1)
    if csize >= htf1_min_candle
        is_bull = h1_close1 > h1_open1
        array.push(h1_obs, OBCandidate.new(h1_open1, h1_high1, h1_low1, is_bull, h1_time1, bar_index))

// =========================
// VARIABLES DE SEÑAL — sin var, se resetean cada barra
// =========================
float new_cisd_level    = na
bool  new_is_bull_cisd  = false
int   new_ob_start_time = na
int   new_confirm_time  = na
bool  found_new_cisd    = false

// =========================
// VERIFICAR CRUCES Y CONFIRMACIÓN
// =========================
if array.size(h1_obs) > 0 and not na(h1_close)
    for i = array.size(h1_obs) - 1 to 0
        ob = array.get(h1_obs, i)

        if bar_index - ob.creation_bar > 100
            array.remove(h1_obs, i)
            continue

        bool in_zone       = ob.is_bull ? close <= ob.ob_open : close >= ob.ob_open
        bool is_new_cross  = in_zone and (ob.is_bull ? close[1] > ob.ob_open : close[1] < ob.ob_open)
        bool already_there = in_zone and (bar_index == ob.creation_bar)

        if is_new_cross or already_there
            bool already = false
            if array.size(h1_drawn) > 0
                for j = 0 to array.size(h1_drawn) - 1
                    if array.get(h1_drawn, j) == ob.start_time
                        already := true
                        break

            if not already
                new_cisd_level    := ob.ob_open
                new_is_bull_cisd  := not ob.is_bull
                new_ob_start_time := ob.start_time
                new_confirm_time  := time
                found_new_cisd    := true
                array.push(h1_drawn, ob.start_time)
                array.remove(h1_obs, i)
                break

// =========================
// FUNCIÓN: BUSCAR SL
// =========================
f_find_sl(is_bull, cisd_level, max_lookback, min_piv, max_piv) =>
    float sl    = na
    int   bars  = 0
    int   pivot = 0
    for plen = min_piv to max_piv
        if not na(sl)
            break
        if is_bull
            for j = plen to max_lookback
                if j <= bar_index
                    ok  = true
                    val = low[j]
                    if val >= cisd_level
                        ok := false
                    if ok
                        for l = 1 to plen
                            if j + l <= bar_index and low[j + l] <= val
                                ok := false
                                break
                    if ok and j >= plen
                        for r = 1 to plen
                            if low[j - r] <= val
                                ok := false
                                break
                    if ok
                        sl    := val
                        bars  := j
                        pivot := plen
                        break
        else
            for j = plen to max_lookback
                if j <= bar_index
                    ok  = true
                    val = high[j]
                    if val <= cisd_level
                        ok := false
                    if ok
                        for l = 1 to plen
                            if j + l <= bar_index and high[j + l] >= val
                                ok := false
                                break
                    if ok and j >= plen
                        for r = 1 to plen
                            if high[j - r] >= val
                                ok := false
                                break
                    if ok
                        sl    := val
                        bars  := j
                        pivot := plen
                        break
    [sl, bars, pivot]

// =========================
// FUNCIÓN: DIBUJAR CAJA
// =========================
f_draw_box(cisd_level, confirm_time, is_bull, sl_level, sl_bars, sl_pivot, rr, transparency, s_labels, c_sl, c_tp, bwidth) =>
    box   sl_box = na
    box   tp_box = na
    label sl_lbl = na
    label tp_lbl = na
    line  rr_ln  = na
    if htf1_show_boxes and not na(sl_level)
        bool valid = is_bull ? sl_level < cisd_level : sl_level > cisd_level
        if valid
            sd = math.abs(cisd_level - sl_level)
            if sd > syminfo.mintick * 2
                td     = sd * rr
                tp_lvl = is_bull ? cisd_level + td : cisd_level - td
                int rw = math.min(bwidth, 400)
                int rt = confirm_time + rw * chart_tf_ms
                float st = is_bull ? cisd_level : sl_level
                float sb = is_bull ? sl_level   : cisd_level
                sl_box := box.new(confirm_time, st, rt, sb,
                                  xloc=xloc.bar_time, border_color=c_sl,
                                  bgcolor=color.new(c_sl, transparency))
                if s_labels
                    int cx = confirm_time + (rt - confirm_time) / 2
                    sl_lbl := label.new(cx, is_bull ? sb + sd*0.1 : st - sd*0.1,
                                 text="SL: " + str.tostring(sd,"#.##") + " (" + str.tostring(sl_bars) + "b, sw" + str.tostring(sl_pivot) + ")",
                                 xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_center,
                                 color=color.new(color.red,90), textcolor=color.white, size=size.normal)
                float tt = is_bull ? tp_lvl    : cisd_level
                float tb = is_bull ? cisd_level : tp_lvl
                tp_box := box.new(confirm_time, tt, rt, tb,
                                  xloc=xloc.bar_time, border_color=c_tp,
                                  bgcolor=color.new(c_tp, transparency))
                if s_labels
                    int cx2 = confirm_time + (rt - confirm_time) / 2
                    tp_lbl := label.new(cx2, is_bull ? tt - td*0.1 : tb + td*0.1,
                                 text="TP: " + str.tostring(td,"#.##") + " (RR " + str.tostring(rr,"#.#") + ":1)",
                                 xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_center,
                                 color=color.new(color.green,90), textcolor=color.white, size=size.normal)
                if rr != 1.0
                    float rr1 = is_bull ? cisd_level + sd : cisd_level - sd
                    rr_ln := line.new(confirm_time, rr1, rt, rr1,
                                      xloc=xloc.bar_time, color=color.gray, style=line.style_dotted, width=1)
    [sl_box, tp_box, sl_lbl, tp_lbl, rr_ln]

// =========================
// DIBUJAR CUANDO SE DETECTA CISD
// =========================
if found_new_cisd
    bool show = new_is_bull_cisd ? htf1_show_bull : htf1_show_bear

    bool has_active = false
    if htf1_only_first and array.size(h1_objs) > 0
        for k = 0 to array.size(h1_objs) - 1
            obj = array.get(h1_objs, k)
            if obj.is_active and obj.is_bull_cisd == new_is_bull_cisd
                has_active := true
                break

    if show and not has_active
        [sl, slb, slp] = f_find_sl(new_is_bull_cisd, new_cisd_level, htf1_sl_lookback, htf1_swing_min, htf1_swing_max)

        float tp_lvl = na
        if not na(sl)
            float sd_e = math.abs(new_cisd_level - sl)
            tp_lvl := new_is_bull_cisd ? new_cisd_level + sd_e * htf1_rr : new_cisd_level - sd_e * htf1_rr

        c     = new_is_bull_cisd ? htf1_color_bull : htf1_color_bear
        end_t = new_ob_start_time + htf1_ext_lines * chart_tf_ms
        ln    = line.new(new_ob_start_time, new_cisd_level, end_t, new_cisd_level,
                         xloc=xloc.bar_time, color=c, width=htf1_line_width)
        lbl   = label.new(end_t, new_cisd_level + (-5*syminfo.mintick),
                          text="CISD " + tf1_label, xloc=xloc.bar_time, yloc=yloc.price,
                          style=new_is_bull_cisd ? label.style_label_up : label.style_label_down,
                          color=color.new(c,90), textcolor=color.white, size=size.normal)

        [sb,tb,sl_l,tp_l,rl] = f_draw_box(new_cisd_level, new_confirm_time, new_is_bull_cisd,
             sl, slb, slp, htf1_rr, htf1_transparency, htf1_show_labels,
             htf1_color_sl, htf1_color_tp, htf1_box_width)

        label blbl = na
        if htf1_show_body
            float bsize = math.abs(close - open)
            lsz = htf1_body_size == "small" ? size.small : htf1_body_size == "large" ? size.large : size.normal
            blbl := label.new(new_confirm_time + chart_tf_ms, new_cisd_level,
                         text=str.tostring(bsize,"#.##"), xloc=xloc.bar_time, yloc=yloc.price,
                         style=new_is_bull_cisd ? label.style_label_lower_left : label.style_label_upper_left,
                         color=color.new(color.white,30), textcolor=color.black, size=lsz)

        new_obj = CISDObjects.new(ln, lbl, sb, tb, sl_l, tp_l, rl, blbl,
                  new_confirm_time, sl, tp_lvl, new_is_bull_cisd, true)
        array.push(h1_objs, new_obj)

        while array.size(h1_objs) > htf1_max_cisd
            old = array.shift(h1_objs)
            line.delete(old.cisd_line)
            label.delete(old.cisd_label)
            box.delete(old.sl_box)
            box.delete(old.tp_box)
            label.delete(old.sl_label)
            label.delete(old.tp_label)
            line.delete(old.rr_line)
            label.delete(old.body_label)

// =========================
// ACTUALIZAR ANCHO CAJAS EN TIEMPO REAL
// =========================
if array.size(h1_objs) > 0
    for i = 0 to array.size(h1_objs) - 1
        obj = array.get(h1_objs, i)
        if obj.is_active
            int rw        = math.min(htf1_box_width, 400)
            int new_right = obj.timestamp + rw * chart_tf_ms
            int cx        = obj.timestamp + (new_right - obj.timestamp) / 2
            if not na(obj.sl_box)
                box.set_right(obj.sl_box, new_right)
            if not na(obj.tp_box)
                box.set_right(obj.tp_box, new_right)
            if not na(obj.rr_line)
                line.set_x2(obj.rr_line, new_right)
            if not na(obj.sl_label)
                label.set_x(obj.sl_label, cx)
            if not na(obj.tp_label)
                label.set_x(obj.tp_label, cx)

// =========================
// VERIFICAR SL/TP EN TIEMPO REAL
// =========================
if htf1_auto_sl and array.size(h1_objs) > 0
    for i = array.size(h1_objs) - 1 to 0
        obj = array.get(h1_objs, i)
        if obj.is_active and not na(obj.sl_level)
            bool sl_hit = obj.is_bull_cisd ? low <= obj.sl_level : high >= obj.sl_level
            bool tp_hit = not na(obj.tp_level) and (obj.is_bull_cisd ? high >= obj.tp_level : low <= obj.tp_level)
            if sl_hit or tp_hit
                line.delete(obj.cisd_line)
                label.delete(obj.cisd_label)
                box.delete(obj.sl_box)
                box.delete(obj.tp_box)
                label.delete(obj.sl_label)
                label.delete(obj.tp_label)
                line.delete(obj.rr_line)
                label.delete(obj.body_label)
                array.remove(h1_objs, i)

// =========================
// LIMPIEZA PERIÓDICA
// =========================
if array.size(h1_drawn) > 100
    array.shift(h1_drawn)
````
