# TBM - SMT Divergence - Institutional

- url: https://www.tradingview.com/script/yRMDeG3C-TBM-SMT-Divergence-Institutional/
- type: indicator
- pine_id: PUB;730eaae7a755494196048e6872a68c14
- version: 1.0

## Description

TBM - SMT Divergence │ Institutional
Detects SMT Divergences between MNQ1! and MES1! and marks them on the chart.

## Source Code

````pine
//@version=5
indicator(
     title              = "SMT Divergence │ Institutional",
     shorttitle         = "SMT",
     overlay            = true,
     max_lines_count    = 500,
     max_labels_count   = 200)

// ─────────────────────────────────────────────────────────────────────────────
// § 1 │ INPUT GROUPS
// ─────────────────────────────────────────────────────────────────────────────

var G_SYM = "⚙️  Symbol & Pivot Configuration"
var G_VOL = "🔬  Volatility Filter (ATR-Based)"
var G_VIS = "🎨  Visual & Label Options"
var G_ALT = "🔔  Alerts"

// ── Symbol ──
i_sym2 = input.symbol(
     defval  = "MES1!",
     title   = "Secondary Symbol",
     group   = G_SYM,
     tooltip = "Correlated instrument compared against the chart symbol.\n" +
               "Default: MES1! (Micro E-mini S&P 500) vs MNQ1! (Micro Nasdaq).")

// ── Pivot ──
i_lb = input.int(
     defval  = 10,
     title   = "Pivot Lookback (bars each side)",
     minval  = 3,
     maxval  = 50,
     group   = G_SYM,
     tooltip = "Pine's ta.pivothigh/low require this many bars on each side to\n" +
               "confirm a swing. Higher → fewer but more significant pivots.\n" +
               "Recommended: 5–15 for intraday, 8–20 for daily.")

i_sync = input.int(
     defval  = 8,
     title   = "Pivot Sync Window (bars)",
     minval  = 1,
     maxval  = 40,
     group   = G_SYM,
     tooltip = "Maximum bar distance allowed between the two instruments' pivot\n" +
               "confirmation bars for them to qualify as a 'paired swing'.\n" +
               "Prevents comparing a fresh pivot against a weeks-old one.")

// ── ATR Filter ──
i_use_vol = input.bool(
     defval  = true,
     title   = "Enable ATR Volatility Filter",
     group   = G_VOL,
     tooltip = "When enabled, signals are suppressed if current ATR is below\n" +
               "ATR-MA × multiplier — filtering out low-volatility consolidation.")

i_atr_len = input.int(
     defval  = 14,
     title   = "ATR Length",
     minval  = 5,
     maxval  = 50,
     group   = G_VOL)

i_atr_mult = input.float(
     defval  = 0.75,
     title   = "Min ATR Multiplier (ATR / ATR-MA threshold)",
     minval  = 0.1,
     maxval  = 5.0,
     step    = 0.05,
     group   = G_VOL,
     tooltip = "Signal fires only when ATR(n) ≥ ATR-MA × this value.\n" +
               "0.75 = ATR must be at least 75% of its own moving average.\n" +
               "Raise to be more selective; lower to allow more signals.")

// ── Visuals ──
i_bull_col = input.color(
     defval  = color.new(#00BCD4, 0),
     title   = "Bullish Divergence Color",
     group   = G_VIS)

i_bear_col = input.color(
     defval  = color.new(#FF5252, 0),
     title   = "Bearish Divergence Color",
     group   = G_VIS)

i_lw = input.int(
     defval  = 2,
     title   = "Divergence Line Width",
     minval  = 1,
     maxval  = 4,
     group   = G_VIS)

i_show_lbl  = input.bool(true,  "Show Signal Labels",          group = G_VIS)
i_show_dash = input.bool(true,  "Show Info Dashboard",         group = G_VIS)
i_show_s2   = input.bool(false, "Plot Secondary H/L Reference",group = G_VIS,
     tooltip = "Overlay the secondary symbol's high/low as cross marks on\n" +
               "the primary chart for quick visual correlation checks.")

// ─────────────────────────────────────────────────────────────────────────────
// § 2 │ SECONDARY SYMBOL DATA — ZERO REPAINT
// ─────────────────────────────────────────────────────────────────────────────
// lookahead_off:  never peek at future bars → no historical ghost signals
// gaps_off:       carry last known price across non-trading sessions

[s2_high, s2_low] = request.security(
     symbol    = i_sym2,
     timeframe = timeframe.period,
     expression= [high, low],
     lookahead = barmerge.lookahead_off,
     gaps      = barmerge.gaps_off)

// ─────────────────────────────────────────────────────────────────────────────
// § 3 │ PIVOT DETECTION
// ─────────────────────────────────────────────────────────────────────────────
// ta.pivothigh/low fire at bar_index N when the pivot is confirmed i_lb bars
// in the past (actual pivot bar = bar_index - i_lb at detection time).
// Reading these only on barstate.isconfirmed eliminates intra-bar flip.

ph1 = ta.pivothigh(high,   i_lb, i_lb)   // Primary   pivot HIGH
pl1 = ta.pivotlow (low,    i_lb, i_lb)   // Primary   pivot LOW
ph2 = ta.pivothigh(s2_high, i_lb, i_lb)  // Secondary pivot HIGH
pl2 = ta.pivotlow (s2_low,  i_lb, i_lb)  // Secondary pivot LOW

// ─────────────────────────────────────────────────────────────────────────────
// § 4 │ ATR VOLATILITY FILTER
// ─────────────────────────────────────────────────────────────────────────────
// ATR-MA uses 2× the ATR length to produce a smooth baseline.
// A signal is only "vol_ok" when current ATR exceeds the threshold.

atr_now = ta.atr(i_atr_len)
atr_ma  = ta.sma(atr_now, i_atr_len * 2)
vol_ok  = not i_use_vol or (atr_now >= atr_ma * i_atr_mult)

// ─────────────────────────────────────────────────────────────────────────────
// § 5 │ PIVOT STATE MACHINE  (updated only on confirmed close → zero repaint)
// ─────────────────────────────────────────────────────────────────────────────
// Stores the two most-recent confirmed pivot High/Low for each symbol.
// _a = current (most recent), _b = previous.
// _bi = actual bar_index of the pivot event (bar_index - i_lb at detection).

// ── Primary pivot HIGHS ──
var float s1_ph_a    = na   // current  high value
var int   s1_ph_a_bi = na   // current  high bar_index
var float s1_ph_b    = na   // previous high value
var int   s1_ph_b_bi = na   // previous high bar_index

// ── Primary pivot LOWS ──
var float s1_pl_a    = na
var int   s1_pl_a_bi = na
var float s1_pl_b    = na
var int   s1_pl_b_bi = na

// ── Secondary pivot HIGHS ──
var float s2_ph_a    = na
var int   s2_ph_a_bi = na
var float s2_ph_b    = na   // value only (bar_index not needed for divergence logic)

// ── Secondary pivot LOWS ──
var float s2_pl_a    = na
var int   s2_pl_a_bi = na
var float s2_pl_b    = na

// Update state only on confirmed (closed) bars
if barstate.isconfirmed
    // Primary high pivot
    if not na(ph1)
        s1_ph_b    := s1_ph_a
        s1_ph_b_bi := s1_ph_a_bi
        s1_ph_a    := ph1
        s1_ph_a_bi := bar_index - i_lb   // ← actual pivot bar

    // Primary low pivot
    if not na(pl1)
        s1_pl_b    := s1_pl_a
        s1_pl_b_bi := s1_pl_a_bi
        s1_pl_a    := pl1
        s1_pl_a_bi := bar_index - i_lb

    // Secondary high pivot
    if not na(ph2)
        s2_ph_b    := s2_ph_a
        s2_ph_a    := ph2
        s2_ph_a_bi := bar_index - i_lb

    // Secondary low pivot
    if not na(pl2)
        s2_pl_b    := s2_pl_a
        s2_pl_a    := pl2
        s2_pl_a_bi := bar_index - i_lb

// ─────────────────────────────────────────────────────────────────────────────
// § 6 │ SMT DIVERGENCE CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
//
//  BEARISH SMT: Primary makes Higher High (HH) while Secondary makes Lower High (LH)
//               Signals institutional distribution / smart money selling into strength
//
//  BULLISH SMT: Primary makes Lower Low (LL) while Secondary makes Higher Low (HL)
//               Signals institutional accumulation / smart money buying into weakness
//
//  SYNC CHECK:  Both instruments' confirmed pivot bars must be within i_sync bars
//               of each other to qualify as contemporaneous swings.
//
//  GATE:        barstate.isconfirmed + not na(ph1/pl1) ensures the signal
//               fires exactly once, on the close of the confirmation bar,
//               and never repaints on historical bars.

// ── Bearish SMT ──
bear_smt = barstate.isconfirmed
     and not na(ph1)                                              // new primary pivot high confirmed
     and not na(s1_ph_a) and not na(s1_ph_b)                     // two primary highs available
     and not na(s2_ph_a) and not na(s2_ph_b)                     // two secondary highs available
     and (s1_ph_a > s1_ph_b)                                      // primary:   Higher High  ✓
     and (s2_ph_a < s2_ph_b)                                      // secondary: Lower High   ✓  → divergence
     and (math.abs(s1_ph_a_bi - s2_ph_a_bi) <= i_sync)           // contemporaneous swing   ✓
     and vol_ok                                                    // sufficient volatility   ✓

// ── Bullish SMT ──
bull_smt = barstate.isconfirmed
     and not na(pl1)
     and not na(s1_pl_a) and not na(s1_pl_b)
     and not na(s2_pl_a) and not na(s2_pl_b)
     and (s1_pl_a < s1_pl_b)                                      // primary:   Lower Low    ✓
     and (s2_pl_a > s2_pl_b)                                      // secondary: Higher Low   ✓  → divergence
     and (math.abs(s1_pl_a_bi - s2_pl_a_bi) <= i_sync)
     and vol_ok

// ─────────────────────────────────────────────────────────────────────────────
// § 7 │ DIVERGENCE LINES & LABELS
// ─────────────────────────────────────────────────────────────────────────────
// line.new() draws a trendline connecting the two divergent pivots.
// Labels are pinned to the most-recent pivot (signal bar) for clarity.

if bear_smt and not na(s1_ph_b_bi) and not na(s1_ph_a_bi)
    // ── Divergence trendline (previous high → current high on primary chart)
    line.new(
         x1    = s1_ph_b_bi,
         y1    = s1_ph_b,
         x2    = s1_ph_a_bi,
         y2    = s1_ph_a,
         color = i_bear_col,
         width = i_lw,
         style = line.style_solid)

    if i_show_lbl
        label.new(
             x         = s1_ph_a_bi,
             y         = s1_ph_a,
             text      = "▼ BEAR SMT\n" + syminfo.ticker + " HH  /  " + i_sym2 + " LH",
             style     = label.style_label_down,
             color     = color.new(i_bear_col, 10),
             textcolor = color.white,
             size      = size.small)

if bull_smt and not na(s1_pl_b_bi) and not na(s1_pl_a_bi)
    line.new(
         x1    = s1_pl_b_bi,
         y1    = s1_pl_b,
         x2    = s1_pl_a_bi,
         y2    = s1_pl_a,
         color = i_bull_col,
         width = i_lw,
         style = line.style_solid)

    if i_show_lbl
        label.new(
             x         = s1_pl_a_bi,
             y         = s1_pl_a,
             text      = "▲ BULL SMT\n" + syminfo.ticker + " LL  /  " + i_sym2 + " HL",
             style     = label.style_label_up,
             color     = color.new(i_bull_col, 10),
             textcolor = color.white,
             size      = size.small)

// ─────────────────────────────────────────────────────────────────────────────
// § 8 │ BACKGROUND BAR HIGHLIGHT
// ─────────────────────────────────────────────────────────────────────────────

bgcolor(bear_smt ? color.new(i_bear_col, 82) : na, title = "Bear SMT Bar Highlight")
bgcolor(bull_smt ? color.new(i_bull_col, 82) : na, title = "Bull SMT Bar Highlight")

// ─────────────────────────────────────────────────────────────────────────────
// § 9 │ SECONDARY SYMBOL H/L REFERENCE PLOTS
// ─────────────────────────────────────────────────────────────────────────────

plot(i_show_s2 ? s2_high : na,
     title     = "Secondary High",
     color     = color.new(i_bear_col, 55),
     style     = plot.style_cross,
     linewidth = 1)

plot(i_show_s2 ? s2_low : na,
     title     = "Secondary Low",
     color     = color.new(i_bull_col, 55),
     style     = plot.style_cross,
     linewidth = 1)

// ─────────────────────────────────────────────────────────────────────────────
// § 10 │ INFORMATION DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────

var table dash = table.new(
     position     = position.top_right,
     columns      = 2,
     rows         = 11,
     bgcolor      = color.new(#0d1117, 6),
     frame_color  = color.new(#30363d, 0),
     frame_width  = 1,
     border_color = color.new(#21262d, 0),
     border_width = 1)

if i_show_dash and barstate.islast
    // Palette
    C_BG  = color.new(#161b22, 0)
    C_KEY = color.new(#8b949e, 0)
    C_VAL = color.white
    C_HDR = color.new(#58a6ff, 0)
    C_GRN = color.new(#3fb950, 0)
    C_YEL = color.new(#d29922, 0)

    // ── Row 0: Title ──
    table.cell(dash, 0, 0,
         "SMT DIVERGENCE  v2.0",
         text_color   = C_HDR,
         text_size    = size.small,
         bgcolor      = C_BG,
         text_halign  = text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    // ── Row 1: Primary symbol ──
    table.cell(dash, 0, 1, "Primary",      text_color=C_KEY, text_size=size.tiny, bgcolor=C_BG)
    table.cell(dash, 1, 1, syminfo.ticker, text_color=C_VAL, text_size=size.tiny, bgcolor=C_BG)

    // ── Row 2: Secondary symbol ──
    table.cell(dash, 0, 2, "Secondary",    text_color=C_KEY, text_size=size.tiny, bgcolor=C_BG)
    table.cell(dash, 1, 2, i_sym2,         text_color=C_VAL, text_size=size.tiny, bgcolor=C_BG)

    // ── Row 3: Pivot lookback ──
    table.cell(dash, 0, 3, "Pivot LB",     text_color=C_KEY, text_size=size.tiny, bgcolor=C_BG)
    table.cell(dash, 1, 3, str.tostring(i_lb) + " bars",
         text_color=C_VAL, text_size=size.tiny, bgcolor=C_BG)

    // ── Row 4: Sync window ──
    table.cell(dash, 0, 4, "Sync Window",  text_color=C_KEY, text_size=size.tiny, bgcolor=C_BG)
    table.cell(dash, 1, 4, "± " + str.tostring(i_sync) + " bars",
         text_color=C_VAL, text_size=size.tiny, bgcolor=C_BG)

    // ── Row 5: ATR values ──
    atr_display = str.tostring(math.round(atr_now, 2)) +
                  "  /  " + str.tostring(math.round(atr_ma, 2))
    table.cell(dash, 0, 5, "ATR / MA",     text_color=C_KEY, text_size=size.tiny, bgcolor=C_BG)
    table.cell(dash, 1, 5, atr_display,    text_color=C_VAL, text_size=size.tiny, bgcolor=C_BG)

    // ── Row 6: ATR threshold ──
    thresh_display = str.tostring(math.round(atr_ma * i_atr_mult, 2))
    table.cell(dash, 0, 6, "Min ATR Req.", text_color=C_KEY, text_size=size.tiny, bgcolor=C_BG)
    table.cell(dash, 1, 6, thresh_display, text_color=C_VAL, text_size=size.tiny, bgcolor=C_BG)

    // ── Row 7: Volatility status ──
    vol_str = i_use_vol ? (vol_ok ? "✓  PASS" : "✗  FILTERED") : "DISABLED"
    vol_clr = i_use_vol ? (vol_ok ? C_GRN : C_YEL) : C_KEY
    table.cell(dash, 0, 7, "Volatility",   text_color=C_KEY,  text_size=size.tiny, bgcolor=C_BG)
    table.cell(dash, 1, 7, vol_str,        text_color=vol_clr,text_size=size.tiny, bgcolor=C_BG)

    // ── Row 8: Last Primary High ──
    ph_str = not na(s1_ph_a) ? str.tostring(math.round(s1_ph_a, 2)) : "—"
    table.cell(dash, 0, 8, "Last PH (S1)", text_color=C_KEY, text_size=size.tiny, bgcolor=C_BG)
    table.cell(dash, 1, 8, ph_str,         text_color=C_VAL, text_size=size.tiny, bgcolor=C_BG)

    // ── Row 9: Last Primary Low ──
    pl_str = not na(s1_pl_a) ? str.tostring(math.round(s1_pl_a, 2)) : "—"
    table.cell(dash, 0, 9, "Last PL (S1)", text_color=C_KEY, text_size=size.tiny, bgcolor=C_BG)
    table.cell(dash, 1, 9, pl_str,         text_color=C_VAL, text_size=size.tiny, bgcolor=C_BG)

    // ── Row 10: Current bar signal ──
    sig_txt = bear_smt ? "▼  BEARISH SMT" : bull_smt ? "▲  BULLISH SMT" : "●  Scanning..."
    sig_clr = bear_smt ? i_bear_col : bull_smt ? i_bull_col : C_KEY
    table.cell(dash, 0, 10, "Signal",      text_color=C_KEY,  text_size=size.tiny, bgcolor=C_BG)
    table.cell(dash, 1, 10, sig_txt,       text_color=sig_clr,text_size=size.tiny, bgcolor=C_BG)

// ─────────────────────────────────────────────────────────────────────────────
// § 11 │ ALERT CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
// alertcondition() is evaluated on every bar; actual alerts fire only when the
// condition is true. Because bear_smt / bull_smt are gated by barstate.isconfirmed,
// alerts will only trigger on the close of a bar — never intra-bar.

alertcondition(
     bull_smt,
     title   = "[SMT] Bullish Divergence",
     message = "BULLISH SMT DETECTED\n" +
               "Primary ({{ticker}}): Lower Low\n" +
               "Secondary: Higher Low\n" +
               "Bar time: {{time}} | TF: {{interval}}")

alertcondition(
     bear_smt,
     title   = "[SMT] Bearish Divergence",
     message = "BEARISH SMT DETECTED\n" +
               "Primary ({{ticker}}): Higher High\n" +
               "Secondary: Lower High\n" +
               "Bar time: {{time}} | TF: {{interval}}")

alertcondition(
     bull_smt or bear_smt,
     title   = "[SMT] Any Divergence",
     message = "SMT DIVERGENCE DETECTED on {{ticker}} | {{time}}")
````
