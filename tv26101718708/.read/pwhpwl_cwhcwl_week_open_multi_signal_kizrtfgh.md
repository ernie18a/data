# PWH/PWL + CWH/CWL + Week Open + Multi Signal

- url: https://www.tradingview.com/script/kIzrtFgH/
- type: indicator
- pine_id: PUB;bdf42cf54a9343fc83addb171df4c0d7
- version: 1.0

## Description

PWL PWH CWL CWH zeichnet er ein. Inklusive Opens, Psychologische Levels

## Source Code

````pine
//@version=6
indicator("PWH/PWL + CWH/CWL + Week Open + Multi Signal", overlay = true,
          max_lines_count  = 500,
          max_labels_count = 200)

// ── OPENS — WEEKLY ONLY ─────────────────────────────────────────
var bool   i_o_w     = input.bool(true,    "Weekly Open", group = "Opens — Weekly", inline = "ow")
var color  c_o_w     = input.color(#FF9800,"",            group = "Opens — Weekly", inline = "ow")
var int    i_o_w_w   = input.int(1,        "Breite",      group = "Opens — Weekly", inline = "ow", minval = 1, maxval = 5)
var string i_o_w_sty = input.string("solid","Stil",       group = "Opens — Weekly", inline = "ow", options = ["solid","dashed","dotted"])
var bool   i_o_w_lbl = input.bool(true,    "Label",       group = "Opens — Weekly")

// ── CURRENT WEEK ────────────────────────────────────────────────
var bool   i_cwh     = input.bool(true,     "CWH",       group = "Current Week", inline = "cw1")
var bool   i_cwl     = input.bool(true,     "CWL",       group = "Current Week", inline = "cw1")
var color  c_cwh     = input.color(#00bfff, "CWH Farbe", group = "Current Week")
var color  c_cwl     = input.color(#ff8800, "CWL Farbe", group = "Current Week")
var int    i_cw_w    = input.int(2,  "Breite",            group = "Current Week", minval = 1, maxval = 5)
var string i_cw_sty  = input.string("dashed","Stil",      group = "Current Week", options = ["solid","dashed","dotted"])

// ── PREV WEEK -1 ────────────────────────────────────────────────
var bool   i_pwh     = input.bool(true,     "PWH",       group = "Prev. Week (-1)", inline = "pw1")
var bool   i_pwl     = input.bool(true,     "PWL",       group = "Prev. Week (-1)", inline = "pw1")
var color  c_pwh     = input.color(#00ff88, "PWH Farbe", group = "Prev. Week (-1)")
var color  c_pwl     = input.color(#ff4466, "PWL Farbe", group = "Prev. Week (-1)")
var int    i_pw_w    = input.int(2,  "Breite",            group = "Prev. Week (-1)", minval = 1, maxval = 5)
var string i_pw_sty  = input.string("solid","Stil",       group = "Prev. Week (-1)", options = ["solid","dashed","dotted"])

// ── BESTÄTIGTE SIGNALE ──────────────────────────────────────────
var bool   i_sig       = input.bool(true,     "Signale an",           group = "Bestätigte Signale")
var bool   i_sig_mo    = input.bool(true,     "Monthly Open",        group = "Bestätigte Signale")
var bool   i_sig_yo    = input.bool(true,     "Yearly Open",         group = "Bestätigte Signale")
var bool   i_sig_rl    = input.bool(true,     "Round Level (1000P)", group = "Bestätigte Signale")
var color  c_sig_long  = input.color(#00e87a, "Long Farbe",          group = "Bestätigte Signale")
var color  c_sig_short = input.color(#e83050, "Short Farbe",         group = "Bestätigte Signale")

// ── PREVIEW SIGNALE ─────────────────────────────────────────────
var bool   i_prev       = input.bool(true,     "Preview an",          group = "Preview Signale (Freitag)")
var bool   i_prev_mo    = input.bool(true,     "Monthly Open",       group = "Preview Signale (Freitag)")
var bool   i_prev_yo    = input.bool(true,     "Yearly Open",        group = "Preview Signale (Freitag)")
var bool   i_prev_rl    = input.bool(true,     "Round Level (1000P)",group = "Preview Signale (Freitag)")
var bool   i_prev_range = input.bool(true,     "CW Range anzeigen",  group = "Preview Signale (Freitag)")
var color  c_prev       = input.color(#FFD700, "Preview Farbe",      group = "Preview Signale (Freitag)")

// ── HELPER ──────────────────────────────────────────────────────
f_sty(string s) =>
    s == "dashed" ? line.style_dashed : s == "dotted" ? line.style_dotted : line.style_solid

f_round_count(float lo, float hi) =>
    float step = 1000.0 * syminfo.mintick
    float base = math.floor(lo / step) * step
    int cnt = 0
    for i = 0 to 50
        float lvl = base + i * step
        if lvl >= lo and lvl <= hi
            cnt += 1
        if lvl > hi
            break
    cnt

f_round_single(float lo, float hi) =>
    float step = 1000.0 * syminfo.mintick
    float base = math.floor(lo / step) * step
    float val = na
    for i = 0 to 50
        float lvl = base + i * step
        if lvl >= lo and lvl <= hi
            val := lvl
            break
        if lvl > hi
            break
    val

// ── MANUAL DATA TRACKING (replay-safe) ──────────────────────────
var float cw_h     = na
var float cw_l     = na
var int   cw_h_bar = 0
var int   cw_l_bar = 0
var int   cw_start = 0

var float pw_h       = na
var float pw_l       = na
var int   pw_start   = 0
var bool  pw_h_first = false
var bool  pw_l_first = false

var float w_open     = na
var float m_open     = na
var float y_open     = na
var float sig_m_open = na
var float sig_y_open = na

bool nw = timeframe.change("1W")
bool nm = timeframe.change("1M")
bool ny = timeframe.change("12M")

// MO/YO cachen BEVOR sie überschrieben werden
if nw
    sig_m_open := m_open
    sig_y_open := y_open

if ny or barstate.isfirst
    y_open := open

if nm or barstate.isfirst
    m_open := open

if nw or barstate.isfirst
    if not barstate.isfirst
        pw_h       := cw_h
        pw_l       := cw_l
        pw_start   := cw_start
        pw_h_first := cw_h_bar < cw_l_bar
        pw_l_first := cw_l_bar < cw_h_bar
    cw_h     := high
    cw_l     := low
    cw_h_bar := bar_index
    cw_l_bar := bar_index
    cw_start := bar_index
    w_open   := open
else
    if high > cw_h or na(cw_h)
        cw_h     := high
        cw_h_bar := bar_index
    if low < cw_l or na(cw_l)
        cw_l     := low
        cw_l_bar := bar_index

bool is_friday = dayofweek(time) == dayofweek.friday

// ── DRAW VARS ───────────────────────────────────────────────────
var line  ow_ln = na
var label ow_lb = na

var line  cwh_ln = na, var line  cwl_ln = na
var label cwh_lb = na, var label cwl_lb = na

var line  pwh_ln = na, var line  pwl_ln = na
var label pwh_lb = na, var label pwl_lb = na
var label sig_long_lb  = na
var label sig_short_lb = na

var label prev_long_lb  = na
var label prev_short_lb = na
var line  prev_h_ln = na, var line  prev_l_ln = na
var label prev_h_lb = na, var label prev_l_lb = na

// ── WEEKLY OPEN LINE ────────────────────────────────────────────
if i_o_w
    if nw or barstate.isfirst
        if not na(ow_ln)
            line.set_x2(ow_ln, bar_index - 1)
        ow_ln := line.new(bar_index, w_open, bar_index, w_open,
                          color = c_o_w, width = i_o_w_w, style = f_sty(i_o_w_sty))
        if i_o_w_lbl
            label.delete(ow_lb)
            ow_lb := label.new(bar_index, w_open, "W  " + str.tostring(math.round(w_open, 2)),
                               style = label.style_label_right,
                               color = color.new(c_o_w, 85), textcolor = c_o_w, size = size.small)

// ── CWH / CWL ──────────────────────────────────────────────────
if i_cwh or i_cwl
    if nw or barstate.isfirst
        line.delete(cwh_ln),  cwh_ln := na
        line.delete(cwl_ln),  cwl_ln := na
        label.delete(cwh_lb), cwh_lb := na
        label.delete(cwl_lb), cwl_lb := na

    if not na(cw_h) and i_cwh
        if na(cwh_ln)
            cwh_ln := line.new(cw_start, cw_h, bar_index, cw_h,
                               color = c_cwh, width = i_cw_w, style = f_sty(i_cw_sty))
            cwh_lb := label.new(bar_index, cw_h, "CWH  " + str.tostring(math.round(cw_h, 2)),
                                style = label.style_label_right,
                                color = color.new(c_cwh, 85), textcolor = c_cwh, size = size.small)
        else
            line.set_y1(cwh_ln, cw_h)
            line.set_y2(cwh_ln, cw_h)
            label.set_y(cwh_lb, cw_h)
            label.set_text(cwh_lb, "CWH  " + str.tostring(math.round(cw_h, 2)))

    if not na(cw_l) and i_cwl
        if na(cwl_ln)
            cwl_ln := line.new(cw_start, cw_l, bar_index, cw_l,
                               color = c_cwl, width = i_cw_w, style = f_sty(i_cw_sty))
            cwl_lb := label.new(bar_index, cw_l, "CWL  " + str.tostring(math.round(cw_l, 2)),
                                style = label.style_label_right,
                                color = color.new(c_cwl, 85), textcolor = c_cwl, size = size.small)
        else
            line.set_y1(cwl_ln, cw_l)
            line.set_y2(cwl_ln, cw_l)
            label.set_y(cwl_lb, cw_l)
            label.set_text(cwl_lb, "CWL  " + str.tostring(math.round(cw_l, 2)))

// ── NEW WEEK: PWH/PWL + BESTÄTIGTE SIGNALE ──────────────────────
if nw and not barstate.isfirst
    label.delete(prev_long_lb),  prev_long_lb  := na
    label.delete(prev_short_lb), prev_short_lb := na
    line.delete(prev_h_ln),      prev_h_ln     := na
    line.delete(prev_l_ln),      prev_l_ln     := na
    label.delete(prev_h_lb),     prev_h_lb     := na
    label.delete(prev_l_lb),     prev_l_lb     := na

    line.delete(pwh_ln),  pwh_ln := na
    line.delete(pwl_ln),  pwl_ln := na
    label.delete(pwh_lb), pwh_lb := na
    label.delete(pwl_lb), pwl_lb := na
    label.delete(sig_long_lb),  sig_long_lb  := na
    label.delete(sig_short_lb), sig_short_lb := na

    if not na(pw_h) and not na(pw_l) and pw_h > pw_l
        if i_pwh
            pwh_ln := line.new(pw_start, pw_h, bar_index, pw_h,
                               extend = extend.none, color = c_pwh,
                               width = i_pw_w, style = f_sty(i_pw_sty))
            pwh_lb := label.new(bar_index, pw_h, "PW1H  " + str.tostring(math.round(pw_h, 2)),
                                style = label.style_label_right,
                                color = color.new(c_pwh, 85), textcolor = c_pwh, size = size.small)
        if i_pwl
            pwl_ln := line.new(pw_start, pw_l, bar_index, pw_l,
                               extend = extend.none, color = c_pwl,
                               width = i_pw_w, style = f_sty(i_pw_sty))
            pwl_lb := label.new(bar_index, pw_l, "PW1L  " + str.tostring(math.round(pw_l, 2)),
                                style = label.style_label_right,
                                color = color.new(c_pwl, 85), textcolor = c_pwl, size = size.small)

        if i_sig
            float pw_mid     = pw_l + (pw_h - pw_l) * 0.5
            string s_l_hits  = ""
            string s_s_hits  = ""
            int    s_l_cnt   = 0
            int    s_s_cnt   = 0

            if i_sig_mo and not na(sig_m_open)
                if pw_l_first and sig_m_open >= pw_l and sig_m_open <= pw_mid
                    s_l_hits := s_l_hits + "MO: " + str.tostring(math.round(sig_m_open, 2))
                    s_l_cnt += 1
                if pw_h_first and sig_m_open >= pw_mid and sig_m_open <= pw_h
                    s_s_hits := s_s_hits + "MO: " + str.tostring(math.round(sig_m_open, 2))
                    s_s_cnt += 1

            if i_sig_yo and not na(sig_y_open)
                if pw_l_first and sig_y_open >= pw_l and sig_y_open <= pw_mid
                    s_l_hits := s_l_hits + (s_l_hits == "" ? "" : "\n") + "YO: " + str.tostring(math.round(sig_y_open, 2))
                    s_l_cnt += 1
                if pw_h_first and sig_y_open >= pw_mid and sig_y_open <= pw_h
                    s_s_hits := s_s_hits + (s_s_hits == "" ? "" : "\n") + "YO: " + str.tostring(math.round(sig_y_open, 2))
                    s_s_cnt += 1

            if i_sig_rl
                int s_rl_cnt = f_round_count(pw_l, pw_h)
                if s_rl_cnt == 1
                    float s_rl_val = f_round_single(pw_l, pw_h)
                    if not na(s_rl_val)
                        if pw_l_first and s_rl_val >= pw_l and s_rl_val <= pw_mid
                            s_l_hits := s_l_hits + (s_l_hits == "" ? "" : "\n") + "RL: " + str.tostring(math.round(s_rl_val, 2))
                            s_l_cnt += 1
                        if pw_h_first and s_rl_val >= pw_mid and s_rl_val <= pw_h
                            s_s_hits := s_s_hits + (s_s_hits == "" ? "" : "\n") + "RL: " + str.tostring(math.round(s_rl_val, 2))
                            s_s_cnt += 1

            if s_l_cnt > 0
                sig_long_lb := label.new(bar_index, pw_l + (pw_mid - pw_l) * 0.5,
                               "▲ LONG (" + str.tostring(s_l_cnt) + ")\n" + s_l_hits +
                               "\n(PWL zuerst · Level zw. 1.0–0.5)",
                               style     = label.style_label_up,
                               color     = c_sig_long,
                               textcolor = color.black,
                               size      = size.small)

            if s_s_cnt > 0
                sig_short_lb := label.new(bar_index, pw_mid + (pw_h - pw_mid) * 0.5,
                                "▼ SHORT (" + str.tostring(s_s_cnt) + ")\n" + s_s_hits +
                                "\n(PWH zuerst · Level zw. 1.0–0.5)",
                                style     = label.style_label_down,
                                color     = c_sig_short,
                                textcolor = color.black,
                                size      = size.small)

// ── FREITAG PREVIEW ─────────────────────────────────────────────
if i_prev and is_friday and not na(cw_h) and not na(cw_l) and cw_h > cw_l
    label.delete(prev_long_lb),  prev_long_lb  := na
    label.delete(prev_short_lb), prev_short_lb := na
    line.delete(prev_h_ln),      prev_h_ln     := na
    line.delete(prev_l_ln),      prev_l_ln     := na
    label.delete(prev_h_lb),     prev_h_lb     := na
    label.delete(prev_l_lb),     prev_l_lb     := na

    bool p_h_first = cw_h_bar < cw_l_bar
    bool p_l_first = cw_l_bar < cw_h_bar
    float p_mid    = cw_l + (cw_h - cw_l) * 0.5

    if i_prev_range
        prev_h_ln := line.new(cw_start, cw_h, bar_index, cw_h,
                              color = color.new(c_prev, 50), width = 1, style = line.style_dotted)
        prev_l_ln := line.new(cw_start, cw_l, bar_index, cw_l,
                              color = color.new(c_prev, 50), width = 1, style = line.style_dotted)
        prev_h_lb := label.new(bar_index, cw_h, "⏳ CW-H  " + str.tostring(math.round(cw_h, 2)),
                               style = label.style_label_right,
                               color = color.new(c_prev, 85), textcolor = c_prev, size = size.tiny)
        prev_l_lb := label.new(bar_index, cw_l, "⏳ CW-L  " + str.tostring(math.round(cw_l, 2)),
                               style = label.style_label_right,
                               color = color.new(c_prev, 85), textcolor = c_prev, size = size.tiny)

    string p_l_hits = ""
    string p_s_hits = ""
    int    p_l_cnt  = 0
    int    p_s_cnt  = 0

    if i_prev_mo and not na(m_open)
        if p_l_first and m_open >= cw_l and m_open <= p_mid
            p_l_hits := p_l_hits + "MO: " + str.tostring(math.round(m_open, 2))
            p_l_cnt += 1
        if p_h_first and m_open >= p_mid and m_open <= cw_h
            p_s_hits := p_s_hits + "MO: " + str.tostring(math.round(m_open, 2))
            p_s_cnt += 1

    if i_prev_yo and not na(y_open)
        if p_l_first and y_open >= cw_l and y_open <= p_mid
            p_l_hits := p_l_hits + (p_l_hits == "" ? "" : "\n") + "YO: " + str.tostring(math.round(y_open, 2))
            p_l_cnt += 1
        if p_h_first and y_open >= p_mid and y_open <= cw_h
            p_s_hits := p_s_hits + (p_s_hits == "" ? "" : "\n") + "YO: " + str.tostring(math.round(y_open, 2))
            p_s_cnt += 1

    if i_prev_rl
        int p_rl_cnt = f_round_count(cw_l, cw_h)
        if p_rl_cnt == 1
            float p_rl_val = f_round_single(cw_l, cw_h)
            if not na(p_rl_val)
                if p_l_first and p_rl_val >= cw_l and p_rl_val <= p_mid
                    p_l_hits := p_l_hits + (p_l_hits == "" ? "" : "\n") + "RL: " + str.tostring(math.round(p_rl_val, 2))
                    p_l_cnt += 1
                if p_h_first and p_rl_val >= p_mid and p_rl_val <= cw_h
                    p_s_hits := p_s_hits + (p_s_hits == "" ? "" : "\n") + "RL: " + str.tostring(math.round(p_rl_val, 2))
                    p_s_cnt += 1

    if p_l_cnt > 0
        prev_long_lb := label.new(bar_index, cw_l + (p_mid - cw_l) * 0.5,
                        "⏳ PREVIEW ▲ LONG (" + str.tostring(p_l_cnt) + ")\n" + p_l_hits,
                        style     = label.style_label_up,
                        color     = color.new(c_sig_long, 40),
                        textcolor = c_prev,
                        size      = size.small)

    if p_s_cnt > 0
        prev_short_lb := label.new(bar_index, p_mid + (cw_h - p_mid) * 0.5,
                         "⏳ PREVIEW ▼ SHORT (" + str.tostring(p_s_cnt) + ")\n" + p_s_hits,
                         style     = label.style_label_down,
                         color     = color.new(c_sig_short, 40),
                         textcolor = c_prev,
                         size      = size.small)

    if p_l_cnt == 0 and p_s_cnt == 0
        prev_long_lb := label.new(bar_index, p_mid,
                        "⏳ PREVIEW\nKein Signal\n" +
                        (p_h_first ? "CW-H zuerst" : p_l_first ? "CW-L zuerst" : "Unklar"),
                        style = label.style_label_center,
                        color = color.new(c_prev, 70),
                        textcolor = c_prev, size = size.tiny)

// ── EVERY BAR: POSITIONEN AKTUALISIEREN ─────────────────────────
if not na(ow_ln)
    line.set_x2(ow_ln, bar_index)
if not na(ow_lb) and i_o_w_lbl
    label.set_x(ow_lb, bar_index)
if not na(cwh_ln)
    line.set_x2(cwh_ln, bar_index)
if not na(cwl_ln)
    line.set_x2(cwl_ln, bar_index)
if not na(cwh_lb)
    label.set_x(cwh_lb, bar_index)
if not na(cwl_lb)
    label.set_x(cwl_lb, bar_index)
if not na(sig_long_lb)
    label.set_x(sig_long_lb, bar_index)
if not na(sig_short_lb)
    label.set_x(sig_short_lb, bar_index)
if not na(prev_long_lb)
    label.set_x(prev_long_lb, bar_index)
if not na(prev_short_lb)
    label.set_x(prev_short_lb, bar_index)
if not na(prev_h_lb)
    label.set_x(prev_h_lb, bar_index)
if not na(prev_l_lb)
    label.set_x(prev_l_lb, bar_index)

// ── ALERTS ──────────────────────────────────────────────────────
float a_mid = not na(pw_h) and not na(pw_l) ? pw_l + (pw_h - pw_l) * 0.5 : na
bool  a_ok  = nw and not barstate.isfirst and not na(pw_h) and not na(pw_l) and pw_h > pw_l and not na(a_mid)

alertcondition(a_ok and i_sig_mo and pw_l_first and not na(sig_m_open) and sig_m_open >= pw_l and sig_m_open <= a_mid,
               "MO LONG",  "Monthly Open LONG")
alertcondition(a_ok and i_sig_mo and pw_h_first and not na(sig_m_open) and sig_m_open >= a_mid and sig_m_open <= pw_h,
               "MO SHORT", "Monthly Open SHORT")
alertcondition(a_ok and i_sig_yo and pw_l_first and not na(sig_y_open) and sig_y_open >= pw_l and sig_y_open <= a_mid,
               "YO LONG",  "Yearly Open LONG")
alertcondition(a_ok and i_sig_yo and pw_h_first and not na(sig_y_open) and sig_y_open >= a_mid and sig_y_open <= pw_h,
               "YO SHORT", "Yearly Open SHORT")
````
