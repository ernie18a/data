# L&S Intraday Lite  H1/M15/M3

- url: https://www.tradingview.com/script/ydMz8rv3/
- type: indicator
- pine_id: PUB;839041b8ca934f33a7a2a83faffe948f
- version: 1.0

## Description

# L&S Intraday Lite — H1/M15/M3

**Liquidität & Struktur — der Markt bewegt sich nicht wegen Linien. Er bewegt sich wegen Liquidität.**

L&S Intraday ist ein Multi-Timeframe Struktur-Indikator, der auf dem Prinzip basiert: *Preis bewegt sich von Liquidität zu Liquidität.* Statt Muster zu raten, zeigt dir L&S, wo Liquidität liegt, wann sie geholt wird und ob sich die Struktur danach verändert.

---

## Was dieser Indikator zeigt

**🔭 H1 Bias — Wohin will der Markt?**
Automatische Trend-Erkennung auf H1 via Swing-Pivots. Gibt dir den übergeordneten Kontext, bevor du auf M15 nach Struktur suchst.

**📈 M15 Struktur — Was passiert gerade?**
Swing Highs/Lows auf M15, sauber berechnet via native Pivots innerhalb der Security-Funktion — korrekt auf jedem Chart-Timeframe (M1, M3, M5).

**⚡ Sweep-Erkennung — Wo wird Liquidität geholt?**
Erkennt Sweeps gegen M15 Swing-Level: Docht über/unter dem Level + Close davor = Liquidität wurde genommen. Bestätigte Sweeps (HL/LH danach) werden separat markiert.

**🏗️ BOS / CHoCH / MSS — Hat sich die Struktur verändert?**
- **BOS** (Break of Structure): Fortsetzung in Trendrichtung
- **CHoCH** (Change of Character): Erster Bruch gegen den Trend
- **MSS** (Market Structure Shift): Sweep bestätigt + Strukturbruch + HTF-Bias aligned

Jedes Event wird mit einer **Bruch-Linie** vom gebrochenen Pivot bis zur Break-Kerze dargestellt — du siehst exakt, welches Level gebrochen wurde und wo.

**📊 Marktphasen — Ist der Markt überhaupt bereit?**
Erkennt automatisch: Expansion 🚀, Erschöpfung ⚠️ oder Aufbau 🔄 — basierend auf ADX + ATR-Verhältnis. Optionaler Phasen-Hintergrund macht den Zustand sofort sichtbar.

**📏 Key Levels — PWH/PWL & PDH/PDL**
Previous Week High/Low und Previous Day High/Low als gestrichelte Referenz-Linien.

---

## Wie du es nutzt

1. **H1 Bias prüfen** — Bullisch oder Bärisch?
2. **M15 Swing-Level beobachten** — Wo liegt offensichtliche Liquidität?
3. **Auf Sweep warten** — Wird ein Level geholt?
4. **Strukturbruch beobachten** — CHoCH / BOS / MSS nach dem Sweep?
5. **Entscheidung treffen** — Passt der Kontext?

> *Ich trade nicht, weil ich etwas sehe. Ich trade, weil der Markt ein Verhalten zeigt, das Wahrscheinlichkeit erzeugt.*

---

## Technische Details

- **Bias:** H1 (Swing-Pivots, Länge 10)
- **Struktur:** M15 (Swing-Pivots extern + intern, konfigurierbar)
- **Berechnung:** Komplett innerhalb `request.security` auf dem jeweiligen Timeframe — keine Timeframe-Abhängigkeit, kein Repainting auf geschlossenen Kerzen
- **Break-Erkennung:** Level-Vergleich + Crossed-Flag (robust gegen bereits durchbrochene Pivots)
- **Labels:** Zeitbasiert platziert via `xloc.bar_time` auf der echten Event-Kerze

---

## 🔒 L&S Pro

Diese Lite-Version zeigt dir **Struktur bis zum Shift**. Die Pro-Version geht weiter:

- ✅ **Akzeptanz-Filter** — Entscheidet, ob ein Shift tatsächlich handelbar ist
- ✅ **FVG & Order Blocks** — Präzise Entry-Zonen aus dem Impuls
- ✅ **Premium/Discount + OTE** — Dealing Range mit Equilibrium und Optimal Trade Entry
- ✅ **Checkliste + Score** — 6-Punkte-Entscheidungssystem: Trade oder kein Trade
- ✅ **Entry-Trigger** — Der letzte Schritt, den die Lite bewusst nicht zeigt

*Struktur zeigt dir, dass etwas passiert ist. Akzeptanz entscheidet, ob du handeln darfst.*

---

**Einstellungen:** Alle Parameter (Swing-Längen, Sweep-Fenster, Farben, Anzeige-Toggles) sind über die Settings konfigurierbar.

**Timeframes:** Optimiert für M1–M5 Chart-Ansicht. H1 Bias + M15 Struktur werden automatisch berechnet.

**Instrumente:** Funktioniert auf allen Märkten — Indizes, Forex, Krypto, Aktien.

## Source Code

````pine
// ============================================================
// L&S INTRADAY — LITE  v3.1
// Bias: H1 | Struktur: M15 | Ansicht: M3/M1
// Pine Script v5
// ============================================================
// KOSTENLOSE LITE-VERSION — Liquiditäts- & Struktur-Mapper.
// Zeigt: Sweep, BOS/CHoCH/MSS (Shift) inkl. Bruch-Linien,
//        HTF-Bias, Phasen, PWH/PWL, PDH/PDL.
// NICHT enthalten (Pro): Akzeptanz-Filter, FVG/OB-Zonen,
//        Premium/Discount + OTE, Entry-Trigger, Checkliste/Score.
// ============================================================

//@version=5
indicator("L&S Intraday Lite — H1/M15/M3",
     shorttitle="L&S Lite",
     overlay=true,
     max_labels_count=500,
     max_lines_count=500,
     max_boxes_count=200)

// ============================================================
// ░░░  EINSTELLUNGEN  ░░░
// ============================================================

string TF_BIAS     = "60"
string TF_STRUKTUR = "15"

grp_show = "👁 Anzeige"
show_pwhl        = input.bool(true,  "PWH/PWL anzeigen",        group=grp_show)
show_pdhl        = input.bool(true,  "PDH/PDL anzeigen",        group=grp_show)
show_bias_hl     = input.bool(true,  "H1 Highs/Lows anzeigen",  group=grp_show)
show_str_hl      = input.bool(true,  "M15 Highs/Lows anzeigen", group=grp_show)
show_bos         = input.bool(true,  "BOS anzeigen",            group=grp_show)
show_choch       = input.bool(true,  "CHoCH anzeigen",          group=grp_show)
show_mss         = input.bool(true,  "MSS anzeigen",            group=grp_show)
show_break_lines = input.bool(true,  "Bruch-Linien anzeigen",   group=grp_show)
show_sweep_lbl   = input.bool(true,  "Sweep Labels anzeigen",   group=grp_show)
show_dashboard   = input.bool(true,  "Dashboard anzeigen",      group=grp_show)
show_phase_bg    = input.bool(true,  "Phasen-Hintergrund",      group=grp_show)

grp_str = "⚡ Struktur"
swing_len    = input.int(20, "Swing Länge M15 (Highs/Lows)",   minval=5,  maxval=50,  group=grp_str)
internal_len = input.int(5,  "Interner Swing M15 (BOS/CHoCH)", minval=2,  maxval=20,  group=grp_str)
sweep_window = input.int(40, "Sweep-Fenster (Chart-Bars)",     minval=10, maxval=200, group=grp_str)

grp_col = "🎨 Farben"
col_pwhl    = input.color(color.new(#FF8C00, 0),  "PWH/PWL",   group=grp_col)
col_pdhl    = input.color(color.new(#FFD700, 0),  "PDH/PDL",   group=grp_col)
col_bias    = input.color(color.new(#58A6FF, 0),  "H1 H/L",    group=grp_col)
col_str     = input.color(color.new(#B794F4, 0),  "M15 H/L",   group=grp_col)
col_bull    = input.color(color.new(#00E5A0, 0),  "Bullisch",  group=grp_col)
col_bear    = input.color(color.new(#FF3B5C, 0),  "Bärisch",   group=grp_col)
col_mss     = input.color(color.new(#00B4D8, 0),  "MSS Level", group=grp_col)
col_sweep   = input.color(color.new(#FFD700, 0),  "Sweep",     group=grp_col)
col_choch   = input.color(color.new(#7C3AED, 0),  "CHoCH",     group=grp_col)
col_neutral = input.color(color.new(#A0AEC0, 0),  "Neutral",   group=grp_col)
col_bg_expansion    = input.color(color.new(#00E5A0, 82), "Expansion BG",   group=grp_col)
col_bg_exhaustion   = input.color(color.new(#FF3B5C, 82), "Erschöpfung BG", group=grp_col)
col_bg_accumulation = input.color(color.new(#A0AEC0, 90), "Aufbau BG",      group=grp_col)

// ============================================================
// ░░░  KERN  ░░░
// ============================================================

atr = ta.atr(14)

// ── PWH / PWL (Vorwoche) ─────────────────────────────────────
pw_high = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pw_low  = request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_on)

var float pwh_level = na
var float pwl_level = na
var line  pwh_line  = na
var line  pwl_line  = na
var label pwh_lbl   = na
var label pwl_lbl   = na

if show_pwhl and (timeframe.change("W") or na(pwh_level))
    if not na(pwh_line)
        line.delete(pwh_line)
        label.delete(pwh_lbl)
    if not na(pwl_line)
        line.delete(pwl_line)
        label.delete(pwl_lbl)
    pwh_level := pw_high
    pwl_level := pw_low
    pwh_line  := line.new(bar_index, pwh_level, bar_index + 500, pwh_level, color=col_pwhl, style=line.style_dashed, width=2, extend=extend.right)
    pwh_lbl   := label.new(bar_index + 2, pwh_level, "PWH", color=color.new(col_pwhl, 80), textcolor=col_pwhl, style=label.style_label_left, size=size.small)
    pwl_line  := line.new(bar_index, pwl_level, bar_index + 500, pwl_level, color=col_pwhl, style=line.style_dashed, width=2, extend=extend.right)
    pwl_lbl   := label.new(bar_index + 2, pwl_level, "PWL", color=color.new(col_pwhl, 80), textcolor=col_pwhl, style=label.style_label_left, size=size.small)

// ── PDH / PDL (Vortag) ───────────────────────────────────────
pd_high = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pd_low  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

var float pdh_level = na
var float pdl_level = na
var line  pdh_line  = na
var line  pdl_line  = na
var label pdh_lbl   = na
var label pdl_lbl   = na

if show_pdhl and (timeframe.change("D") or na(pdh_level))
    if not na(pdh_line)
        line.delete(pdh_line)
        label.delete(pdh_lbl)
    if not na(pdl_line)
        line.delete(pdl_line)
        label.delete(pdl_lbl)
    pdh_level := pd_high
    pdl_level := pd_low
    pdh_line  := line.new(bar_index, pdh_level, bar_index + 500, pdh_level, color=col_pdhl, style=line.style_dashed, width=2, extend=extend.right)
    pdh_lbl   := label.new(bar_index + 2, pdh_level, "PDH", color=color.new(col_pdhl, 80), textcolor=col_pdhl, style=label.style_label_left, size=size.small)
    pdl_line  := line.new(bar_index, pdl_level, bar_index + 500, pdl_level, color=col_pdhl, style=line.style_dashed, width=2, extend=extend.right)
    pdl_lbl   := label.new(bar_index + 2, pdl_level, "PDL", color=color.new(col_pdhl, 80), textcolor=col_pdhl, style=label.style_label_left, size=size.small)

// ============================================================
// ░░░  H1 BIAS  ░░░
// ============================================================

f_h1_bias() =>
    sh = ta.pivothigh(high, 10, 10)
    sl = ta.pivotlow(low,  10, 10)

    var float sh1    = na
    var float sl1    = na
    var int   trend  = 0
    var bool  new_sh = false
    var bool  new_sl = false
    var int   sh_t   = na
    var int   sl_t   = na

    new_sh := false
    new_sl := false

    if not na(sh)
        sh1    := sh
        new_sh := true
        sh_t   := time[10]
    if not na(sl)
        sl1    := sl
        new_sl := true
        sl_t   := time[10]

    if not na(sh1) and close > sh1
        trend := 1
    if not na(sl1) and close < sl1
        trend := -1

    [sh1, sl1, trend, new_sh, new_sl, sh_t, sl_t]

[h1_sh1, h1_sl1, h1_trend, h1_new_sh, h1_new_sl, h1_sh_t, h1_sl_t] = request.security(syminfo.tickerid, TF_BIAS, f_h1_bias(), lookahead=barmerge.lookahead_off)

bool htf_bull = h1_trend >= 0
bool htf_bear = h1_trend <= 0

// H1 Linien
var float h1_last_sh = na
var float h1_last_sl = na
var array<line>  h1_lines  = array.new<line>()
var array<label> h1_labels = array.new<label>()

if show_bias_hl and h1_new_sh and not na(h1_sh1) and not na(h1_sh_t) and h1_sh1 != h1_last_sh
    h1_last_sh := h1_sh1
    array.push(h1_lines,  line.new(h1_sh_t, h1_sh1, time, h1_sh1, xloc=xloc.bar_time, color=col_bias, style=line.style_dashed, width=1, extend=extend.right))
    array.push(h1_labels, label.new(time, h1_sh1, "H1H", xloc=xloc.bar_time, color=color.new(col_bias, 80), textcolor=col_bias, style=label.style_label_left, size=size.tiny))

if show_bias_hl and h1_new_sl and not na(h1_sl1) and not na(h1_sl_t) and h1_sl1 != h1_last_sl
    h1_last_sl := h1_sl1
    array.push(h1_lines,  line.new(h1_sl_t, h1_sl1, time, h1_sl1, xloc=xloc.bar_time, color=col_bias, style=line.style_dashed, width=1, extend=extend.right))
    array.push(h1_labels, label.new(time, h1_sl1, "H1L", xloc=xloc.bar_time, color=color.new(col_bias, 80), textcolor=col_bias, style=label.style_label_left, size=size.tiny))

if array.size(h1_lines) > 0
    i = 0
    while i < array.size(h1_lines)
        ln  = array.get(h1_lines, i)
        lb  = array.get(h1_labels, i)
        lvl = line.get_y1(ln)
        if (close > lvl * 1.001) or (close < lvl * 0.999)
            line.delete(ln)
            label.delete(lb)
            array.remove(h1_lines, i)
            array.remove(h1_labels, i)
        else
            i += 1

// ============================================================
// ░░░  M15 STRUKTUR  ░░░
// ============================================================

f_m15_struktur() =>
    // Swing Pivots
    swing_sh = ta.pivothigh(high, swing_len, swing_len)
    swing_sl = ta.pivotlow(low,   swing_len, swing_len)

    var float sw_high   = na
    var float sw_low    = na
    var bool  sw_new_sh = false
    var bool  sw_new_sl = false
    var int   sw_high_t = na
    var int   sw_low_t  = na

    sw_new_sh := false
    sw_new_sl := false

    if not na(swing_sh)
        sw_high   := swing_sh
        sw_new_sh := true
        sw_high_t := time[swing_len]
    if not na(swing_sl)
        sw_low    := swing_sl
        sw_new_sl := true
        sw_low_t  := time[swing_len]

    // Internal Pivots
    int_sh = ta.pivothigh(high, internal_len, internal_len)
    int_sl = ta.pivotlow(low,   internal_len, internal_len)

    var float int_high   = na
    var float int_low    = na
    var int   int_high_t = na
    var int   int_low_t  = na
    var bool  ih_crossed = false
    var bool  il_crossed = false

    if not na(int_sh)
        int_high   := int_sh
        int_high_t := time[internal_len]
        ih_crossed := false
    if not na(int_sl)
        int_low    := int_sl
        int_low_t  := time[internal_len]
        il_crossed := false

    // BOS / CHoCH — Level-Vergleich + crossed-Flag
    var int   str_trend  = 0
    var bool  bos_bull   = false
    var bool  bos_bear   = false
    var bool  choch_bull = false
    var bool  choch_bear = false
    var int   brk_t      = na
    var float brk_low    = na
    var float brk_high   = na
    var float brk_lvl    = na
    var int   brk_lvl_t  = na

    bos_bull   := false
    bos_bear   := false
    choch_bull := false
    choch_bear := false

    if not na(int_high) and close > int_high and not ih_crossed
        if str_trend < 1
            choch_bull := true
        else
            bos_bull   := true
        ih_crossed := true
        str_trend  := 1
        brk_t      := time
        brk_low    := low
        brk_high   := high
        brk_lvl    := int_high
        brk_lvl_t  := int_high_t

    if not na(int_low) and close < int_low and not il_crossed
        if str_trend > -1
            choch_bear := true
        else
            bos_bear   := true
        il_crossed := true
        str_trend  := -1
        brk_t      := time
        brk_low    := low
        brk_high   := high
        brk_lvl    := int_low
        brk_lvl_t  := int_low_t

    // Sweep Erkennung
    min_os    = math.max(close * 0.0005, ta.atr(14) * 0.3)
    wick_up   = high - math.max(open, close)
    wick_down = math.min(open, close) - low

    sweep_h_raw = not na(sw_high) and high > sw_high + min_os and close < sw_high and wick_up   > (high - low) * 0.3
    sweep_l_raw = not na(sw_low)  and low  < sw_low  - min_os and close > sw_low  and wick_down > (high - low) * 0.3

    var float pend_sl   = na
    var float pend_sh   = na
    var bool  sw_c_bull = false
    var bool  sw_c_bear = false
    var int   swp_t     = na
    var float swp_low   = na
    var float swp_high  = na
    var int   swc_t     = na

    sw_c_bull := false
    sw_c_bear := false

    if sweep_l_raw
        if na(pend_sl) or low < pend_sl
            pend_sl := low
        swp_t    := time
        swp_low  := low
        swp_high := high
    if sweep_h_raw
        if na(pend_sh) or high > pend_sh
            pend_sh := high
        swp_t    := time
        swp_low  := low
        swp_high := high

    if not na(pend_sl) and sw_new_sl and sw_low > pend_sl
        sw_c_bull := true
        swc_t     := time
        pend_sl   := na
    if not na(pend_sh) and sw_new_sh and sw_high < pend_sh
        sw_c_bear := true
        swc_t     := time
        pend_sh   := na

    [sw_high, sw_low, sw_new_sh, sw_new_sl, sw_high_t, sw_low_t, int_high, int_low, str_trend, bos_bull, bos_bear, choch_bull, choch_bear, brk_t, brk_low, brk_high, sweep_h_raw, sweep_l_raw, swp_t, swp_low, swp_high, sw_c_bull, sw_c_bear, swc_t, brk_lvl, brk_lvl_t]

[m15_sw_high, m15_sw_low, m15_sw_new_sh, m15_sw_new_sl, m15_sw_high_t, m15_sw_low_t, m15_int_high, m15_int_low, m15_str_trend, m15_bos_bull, m15_bos_bear, m15_choch_bull, m15_choch_bear, m15_brk_t, m15_brk_low, m15_brk_high, m15_sweep_h_raw, m15_sweep_l_raw, m15_swp_t, m15_swp_low, m15_swp_high, m15_sw_c_bull, m15_sw_c_bear, m15_swc_t, m15_brk_lvl, m15_brk_lvl_t] = request.security(syminfo.tickerid, TF_STRUKTUR, f_m15_struktur(), lookahead=barmerge.lookahead_off)

// ── Sweep Fenster ─────────────────────────────────────────────
var int last_sweep_bar = na

if m15_sw_c_bull or m15_sw_c_bear
    last_sweep_bar := bar_index

bool sweep_in_window = not na(last_sweep_bar) and (bar_index - last_sweep_bar) <= sweep_window

// ============================================================
// ░░░  MSS (Shift)  ░░░
// ============================================================

var float mss_lv_bull  = na
var float mss_lv_bear  = na
var bool  mss_act_bull = false
var bool  mss_act_bear = false
var bool  mss_bull     = false
var bool  mss_bear     = false

mss_bull := false
mss_bear := false

if sweep_in_window and m15_sw_c_bull and (m15_bos_bull or m15_choch_bull) and not mss_act_bull and htf_bull
    mss_bull       := true
    mss_act_bull   := true
    mss_lv_bull    := m15_int_high
    mss_act_bear   := false
    last_sweep_bar := na

if sweep_in_window and m15_sw_c_bear and (m15_bos_bear or m15_choch_bear) and not mss_act_bear and htf_bear
    mss_bear       := true
    mss_act_bear   := true
    mss_lv_bear    := m15_int_low
    mss_act_bull   := false
    last_sweep_bar := na

if mss_act_bull and not na(mss_lv_bull) and close < mss_lv_bull
    mss_act_bull := false
    mss_lv_bull  := na
if mss_act_bear and not na(mss_lv_bear) and close > mss_lv_bear
    mss_act_bear := false
    mss_lv_bear  := na

// ============================================================
// ░░░  MARKTPHASE  ░░░
// ============================================================

atr_avg = ta.sma(atr, 20)
[di_plus, di_minus, adx] = ta.dmi(14, 14)

exh_bull = high >= ta.highest(high, 20) and close < open and (high - close) > (close - low) * 1.5
exh_bear = low  <= ta.lowest(low,  20)  and close > open and (close - low) > (high - close) * 1.5

bool phase_exp = adx > 25 and atr > atr_avg * 1.5
bool phase_exh = (exh_bull or exh_bear) and adx > 20
bool phase_acc = not phase_exp and not phase_exh

string phase_lbl = phase_exp ? "EXPANSION 🚀" : phase_exh ? "ERSCHÖPFUNG ⚠️" : "AUFBAU 🔄"
color  phase_col = phase_exp ? col_bull : phase_exh ? col_bear : col_neutral

bgcolor(show_phase_bg and phase_exp ? col_bg_expansion    : na, title="Expansion BG")
bgcolor(show_phase_bg and phase_exh ? col_bg_exhaustion   : na, title="Erschöpfung BG")
bgcolor(show_phase_bg and phase_acc ? col_bg_accumulation : na, title="Aufbau BG")

// ============================================================
// ░░░  M15 SWING LINIEN  ░░░
// ============================================================

var float m15_last_sh = na
var float m15_last_sl = na
var array<line>  m15_lines  = array.new<line>()
var array<label> m15_labels = array.new<label>()

if show_str_hl and m15_sw_new_sh and not na(m15_sw_high) and not na(m15_sw_high_t) and m15_sw_high != m15_last_sh
    m15_last_sh := m15_sw_high
    array.push(m15_lines,  line.new(m15_sw_high_t, m15_sw_high, time, m15_sw_high, xloc=xloc.bar_time, color=col_str, style=line.style_dashed, width=1, extend=extend.right))
    array.push(m15_labels, label.new(time, m15_sw_high, "M15H", xloc=xloc.bar_time, color=color.new(col_str, 80), textcolor=col_str, style=label.style_label_left, size=size.tiny))

if show_str_hl and m15_sw_new_sl and not na(m15_sw_low) and not na(m15_sw_low_t) and m15_sw_low != m15_last_sl
    m15_last_sl := m15_sw_low
    array.push(m15_lines,  line.new(m15_sw_low_t, m15_sw_low, time, m15_sw_low, xloc=xloc.bar_time, color=col_str, style=line.style_dashed, width=1, extend=extend.right))
    array.push(m15_labels, label.new(time, m15_sw_low, "M15L", xloc=xloc.bar_time, color=color.new(col_str, 80), textcolor=col_str, style=label.style_label_left, size=size.tiny))

if array.size(m15_lines) > 0
    i = 0
    while i < array.size(m15_lines)
        ln  = array.get(m15_lines, i)
        lb  = array.get(m15_labels, i)
        lvl = line.get_y1(ln)
        if (close > lvl * 1.001) or (close < lvl * 0.999)
            line.delete(ln)
            label.delete(lb)
            array.remove(m15_lines, i)
            array.remove(m15_labels, i)
        else
            i += 1

// ============================================================
// ░░░  VISUALISIERUNG — MSS Linien  ░░░
// ============================================================

plot(mss_act_bull ? mss_lv_bull : na, "MSS Long",  color=col_mss, linewidth=2, style=plot.style_linebr)
plot(mss_act_bear ? mss_lv_bear : na, "MSS Short", color=col_mss, linewidth=2, style=plot.style_linebr)

// ============================================================
// ░░░  EVENT-LABELS + BRUCH-LINIEN (zeitbasiert)  ░░░
// ============================================================

var array<label> ev_lbls  = array.new<label>()
var array<line>  ev_lines = array.new<line>()

addEv(_lbl) =>
    array.push(ev_lbls, _lbl)
    if array.size(ev_lbls) > 80
        label.delete(array.shift(ev_lbls))

// Bruch-Linie: vom gebrochenen Pivot (Origin) bis zur Break-Kerze
f_break_line(_col, _w) =>
    if show_break_lines and not na(m15_brk_lvl) and not na(m15_brk_lvl_t) and not na(m15_brk_t)
        ln = line.new(m15_brk_lvl_t, m15_brk_lvl, m15_brk_t, m15_brk_lvl, xloc=xloc.bar_time, color=_col, style=line.style_solid, width=_w)
        array.push(ev_lines, ln)
        if array.size(ev_lines) > 60
            line.delete(array.shift(ev_lines))

// BOS
if show_bos and m15_bos_bull and not m15_bos_bull[1] and not na(m15_brk_t)
    addEv(label.new(m15_brk_t, m15_brk_low - atr * 0.5, "BOS ↑", xloc=xloc.bar_time, style=label.style_label_up, color=color.new(col_bull, 10), textcolor=color.white, size=size.small))
    f_break_line(col_bull, 1)
if show_bos and m15_bos_bear and not m15_bos_bear[1] and not na(m15_brk_t)
    addEv(label.new(m15_brk_t, m15_brk_high + atr * 0.5, "BOS ↓", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(col_bear, 10), textcolor=color.white, size=size.small))
    f_break_line(col_bear, 1)

// CHoCH
if show_choch and m15_choch_bull and not m15_choch_bull[1] and not na(m15_brk_t)
    addEv(label.new(m15_brk_t, m15_brk_low - atr * 1.0, "CHoCH ↑", xloc=xloc.bar_time, style=label.style_label_up, color=color.new(col_choch, 10), textcolor=color.white, size=size.small))
    f_break_line(col_choch, 1)
if show_choch and m15_choch_bear and not m15_choch_bear[1] and not na(m15_brk_t)
    addEv(label.new(m15_brk_t, m15_brk_high + atr * 1.0, "CHoCH ↓", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(col_choch, 10), textcolor=color.white, size=size.small))
    f_break_line(col_choch, 1)

// MSS
if show_mss and mss_bull and not na(m15_brk_t)
    addEv(label.new(m15_brk_t, m15_brk_low - atr * 1.5, "MSS ↑", xloc=xloc.bar_time, style=label.style_label_up, color=color.new(col_mss, 0), textcolor=color.white, size=size.normal))
    f_break_line(col_mss, 2)
if show_mss and mss_bear and not na(m15_brk_t)
    addEv(label.new(m15_brk_t, m15_brk_high + atr * 1.5, "MSS ↓", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(col_mss, 0), textcolor=color.white, size=size.normal))
    f_break_line(col_mss, 2)

// Sweep roh
if show_sweep_lbl and m15_sweep_l_raw and not m15_sweep_l_raw[1] and not na(m15_swp_t)
    addEv(label.new(m15_swp_t, m15_swp_low - atr * 0.3, "⚡ SWEEP LOW", xloc=xloc.bar_time, style=label.style_label_up, color=color.new(col_sweep, 0), textcolor=color.black, size=size.small))
if show_sweep_lbl and m15_sweep_h_raw and not m15_sweep_h_raw[1] and not na(m15_swp_t)
    addEv(label.new(m15_swp_t, m15_swp_high + atr * 0.3, "⚡ SWEEP HIGH", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(col_sweep, 0), textcolor=color.black, size=size.small))

// Sweep bestätigt
if show_sweep_lbl and m15_sw_c_bull and not m15_sw_c_bull[1] and not na(m15_swc_t)
    addEv(label.new(m15_swc_t, m15_sw_low - atr * 0.8, "✅ BEST.", xloc=xloc.bar_time, style=label.style_label_up, color=color.new(col_sweep, 40), textcolor=color.black, size=size.tiny))
if show_sweep_lbl and m15_sw_c_bear and not m15_sw_c_bear[1] and not na(m15_swc_t)
    addEv(label.new(m15_swc_t, m15_sw_high + atr * 0.8, "✅ BEST.", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(col_sweep, 40), textcolor=color.black, size=size.tiny))

// ============================================================
// ░░░  DASHBOARD  ░░░
// ============================================================

if show_dashboard and barstate.islast
    var table dash = table.new(position.top_right, 2, 11,
         bgcolor=color.new(#0D1117, 5), border_color=color.new(#30363D, 80),
         border_width=1, frame_color=color.new(#58A6FF, 50), frame_width=2)

    table.cell(dash, 0, 0, "L&S LITE",      bgcolor=color.new(#161B22, 0), text_color=color.new(#58A6FF, 0), text_size=size.normal, text_halign=text.align_center)
    table.cell(dash, 1, 0, "H1 | M15 | M3", bgcolor=color.new(#161B22, 0), text_color=color.new(#58A6FF, 0), text_size=size.small,  text_halign=text.align_center)

    h1_txt = h1_trend == 1 ? "BULLISCH ↑" : h1_trend == -1 ? "BÄRISCH ↓" : "NEUTRAL →"
    h1_col = h1_trend == 1 ? col_bull : h1_trend == -1 ? col_bear : col_neutral
    h1_bg  = h1_trend == 1 ? color.new(col_bull, 80) : h1_trend == -1 ? color.new(col_bear, 80) : color.new(#161B22, 0)
    table.cell(dash, 0, 1, "🔭 H1 Bias",  bgcolor=h1_bg, text_color=color.new(#8B949E, 0), text_size=size.small)
    table.cell(dash, 1, 1, h1_txt,         bgcolor=h1_bg, text_color=h1_col, text_size=size.normal)

    table.cell(dash, 0, 2, "📊 Phase",  bgcolor=color.new(#161B22, 0), text_color=color.new(#8B949E, 0), text_size=size.small)
    table.cell(dash, 1, 2, phase_lbl,   bgcolor=color.new(#161B22, 0), text_color=phase_col, text_size=size.small)

    t_txt = m15_str_trend == 1 ? "BULLISCH ↑" : m15_str_trend == -1 ? "BÄRISCH ↓" : "NEUTRAL →"
    t_col = m15_str_trend == 1 ? col_bull : m15_str_trend == -1 ? col_bear : col_neutral
    table.cell(dash, 0, 3, "📈 M15 Trend", bgcolor=color.new(#161B22, 0), text_color=color.new(#8B949E, 0), text_size=size.small)
    table.cell(dash, 1, 3, t_txt,           bgcolor=color.new(#161B22, 0), text_color=t_col, text_size=size.small)

    adx_txt = adx > 25 ? "STARK (" + str.tostring(math.round(adx)) + ")" : "SCHWACH (" + str.tostring(math.round(adx)) + ")"
    table.cell(dash, 0, 4, "⚡ ADX",  bgcolor=color.new(#161B22, 0), text_color=color.new(#8B949E, 0), text_size=size.small)
    table.cell(dash, 1, 4, adx_txt,   bgcolor=color.new(#161B22, 0), text_color=adx > 25 ? col_bull : col_neutral, text_size=size.small)

    sw_txt = m15_sw_c_bull ? "BULL ✅" : m15_sw_c_bear ? "BEAR ✅" : m15_sweep_l_raw ? "LOW ⚡" : m15_sweep_h_raw ? "HIGH ⚡" : "Kein Sweep"
    sw_col = (m15_sw_c_bull or m15_sw_c_bear) ? col_bull : (m15_sweep_l_raw or m15_sweep_h_raw) ? col_sweep : col_neutral
    table.cell(dash, 0, 5, "💧 Sweep", bgcolor=color.new(#161B22, 0), text_color=color.new(#8B949E, 0), text_size=size.small)
    table.cell(dash, 1, 5, sw_txt,     bgcolor=color.new(#161B22, 0), text_color=sw_col, text_size=size.small)

    mss_txt = mss_act_bull ? "BULL aktiv ✅" : mss_act_bear ? "BEAR aktiv ✅" : "Kein MSS"
    mss_col = mss_act_bull ? col_bull : mss_act_bear ? col_bear : col_neutral
    table.cell(dash, 0, 6, "🏗️ MSS", bgcolor=color.new(#161B22, 0), text_color=color.new(#8B949E, 0), text_size=size.small)
    table.cell(dash, 1, 6, mss_txt,   bgcolor=color.new(#161B22, 0), text_color=mss_col, text_size=size.small)

    table.cell(dash, 0, 7, "📏 ATR(14)", bgcolor=color.new(#161B22, 0), text_color=color.new(#8B949E, 0), text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(math.round(atr, 2)), bgcolor=color.new(#161B22, 0), text_color=col_neutral, text_size=size.small)

    pwh_t = not na(pwh_level) ? str.tostring(math.round(pwh_level, 2)) : "–"
    pwl_t = not na(pwl_level) ? str.tostring(math.round(pwl_level, 2)) : "–"
    pdh_t = not na(pdh_level) ? str.tostring(math.round(pdh_level, 2)) : "–"
    pdl_t = not na(pdl_level) ? str.tostring(math.round(pdl_level, 2)) : "–"
    table.cell(dash, 0, 8, "PWH " + pwh_t + "  PWL " + pwl_t, bgcolor=color.new(#161B22, 0), text_color=col_pwhl, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 1, 8, "PDH " + pdh_t + "  PDL " + pdl_t, bgcolor=color.new(#161B22, 0), text_color=col_pdhl, text_size=size.tiny, text_halign=text.align_center)

    table.cell(dash, 0, 9, "🔒 PRO",                   bgcolor=color.new(#161B22, 0), text_color=col_sweep, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 1, 9, "Akzeptanz · Zonen · Score", bgcolor=color.new(#161B22, 0), text_color=color.new(#8B949E, 0), text_size=size.tiny, text_halign=text.align_center)

    table.cell(dash, 0, 10, "L&S Intraday Lite v3.1", bgcolor=color.new(#0D1117, 0), text_color=color.new(#30363D, 0), text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 1, 10, "Bias H1 | Str M15",      bgcolor=color.new(#0D1117, 0), text_color=color.new(#30363D, 0), text_size=size.tiny, text_halign=text.align_center)

// ============================================================
// ░░░  ALERTS  ░░░
// ============================================================

alertcondition(mss_bull,       "L&S Lite — MSS Bull",             "L&S Lite: MSS Bull ↑ M15")
alertcondition(mss_bear,       "L&S Lite — MSS Bear",             "L&S Lite: MSS Bear ↓ M15")
alertcondition(m15_sw_c_bull,  "L&S Lite — Sweep Bull bestätigt", "L&S Lite: Sweep Bull ✅")
alertcondition(m15_sw_c_bear,  "L&S Lite — Sweep Bear bestätigt", "L&S Lite: Sweep Bear ✅")
alertcondition(m15_choch_bull, "L&S Lite — CHoCH Bull",           "L&S Lite: CHoCH Bull ↑")
alertcondition(m15_choch_bear, "L&S Lite — CHoCH Bear",           "L&S Lite: CHoCH Bear ↓")
````
