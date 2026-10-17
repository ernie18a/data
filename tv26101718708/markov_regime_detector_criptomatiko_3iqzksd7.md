# Markov Regime Detector - CriptoMatiko

- url: https://www.tradingview.com/script/3IqZksd7-Markov-Regime-Detector-CriptoMatiko/
- type: indicator
- pine_id: PUB;aeab37e9fe934c1fb8c4ed14f1582e6b
- version: 1.0

## Description

The **Markov Regime Detector** classifies each bar as Bull, Bear, or Lateral using rolling log-return, then builds a 3×3 Markov transition matrix from the chart's full visible history.

The matrix diagonal measures **persistence** — the probability of each regime continuing into the next bar. Alerts fire only when persistence exceeds a user-defined threshold, filtering out short-lived, low-confidence regime flips.

---

**How it works**

1. Computes log-return over the last N bars (default: 20)
2. Labels each bar: Bull (log-ret > +5%), Bear (log-ret < −5%), Lateral (in between)
3. Counts all historical transitions and row-normalizes into probabilities
4. Diagonal of the matrix = persistence of the current regime
5. Alert fires when: regime changes AND persistence >= configured threshold

---

**Visuals**

- Ribbon — real-time background tint: green (Bull) / rose (Bear) / grey (Lateral)
- Triangles ▲▼◆ — mark the start of each confirmed new regime
- Floating labels — regime name + persistence % at each transition point
- Table (bottom-right) — current regime, persistence, log-return and alert status

Note: The ribbon updates on the forming bar. Labels, shapes and alerts only fire on confirmed bar close (barstate.isconfirmed).

---

**Alerts**

Set up as "Any alert() call" + "Once per bar close". Dynamic message format:

REGIME: BEAR
Anterior: LATERAL
Persistencia: 85%
Preco: 2022.60
Indicador: Markov | CriptoMatiko

---

**Parameters**

Lookback window (default 20): bars used to compute log-return and classify the current state
Bull threshold (default 5%): log-ret above this value = Bull
Bear threshold (default 5%): log-ret below -5% = Bear
Min persistence to alert (default 55%): minimum persistence to trigger an alert
Min bars to hold (default 3): consecutive bars in same regime before label appears

---

## Source Code

````pine
//@version=5
// =============================================================================
// Markov Regime Detector — CriptoMatiko
// =============================================================================
// Classifies each bar as Bull / Bear / Lateral using a rolling log-return rule,
// then builds a 3x3 Markov transition matrix from visible chart history.
//
// KEY FEATURE — PERSISTENCE FILTER:
// The diagonal of the transition matrix (P[Bull→Bull], P[Bear→Bear],
// P[Lateral→Lateral]) measures how "sticky" each regime is. This script
// exposes that value as a numeric signal and fires alerts ONLY when
// persistence exceeds a user-defined threshold — filtering out noisy,
// short-lived regime flips before they reach your bot.
//
// DESIGNED FOR BOT INTEGRATION:
// Alert messages include regime, persistence %, and close price in a
// structured format ready for TradingView webhooks → Python FastAPI endpoint.
// Use the exported "Regime" and "Persistence" plots in Pine strategies for
// dynamic bot filter adjustment.
//
// Author: Vernon · CriptoMatiko
// =============================================================================

indicator("Markov Regime Detector — CriptoMatiko",
     shorttitle    = "Markov | CM",
     overlay       = true,
     max_labels_count = 500)

// ────────────────────────────────────────────────────────────────────────────
// Inputs
// ────────────────────────────────────────────────────────────────────────────
grp_logic   = "Regime Logic"
grp_filter  = "Alert Filter"
grp_display = "Display"

lookback_window    = input.int(20,   "Lookback window (bars)",  minval=5,   maxval=250, group=grp_logic,
     tooltip="Bars used for rolling log-return. Default 20 on BTCUSDT daily = approx. 1 month of market context.")
bull_threshold_pct = input.float(5.0, "Bull threshold (%)",      minval=0.1, maxval=50.0, step=0.1, group=grp_logic,
     tooltip="Log-return above this value labels the bar Bull.")
bear_threshold_pct = input.float(5.0, "Bear threshold (%)",      minval=0.1, maxval=50.0, step=0.1, group=grp_logic,
     tooltip="Log-return below the negative of this value labels the bar Bear.")

min_persistence    = input.int(55,   "Min persistence to alert (%)", minval=0, maxval=99, group=grp_filter,
     tooltip="Alert fires only when P(stay in current regime) >= this threshold. Raise to filter out choppy regime flips. Lower to be more sensitive.")

show_ribbon = input.bool(true,  "Show background ribbon",    group=grp_display)
show_table  = input.bool(true,  "Show info table",           group=grp_display)
show_labels = input.bool(true,  "Show regime-change labels", group=grp_display)
min_hold    = input.int(3, "Min bars to hold before labelling", minval=1, maxval=50, group=grp_display,
     tooltip="New regime must persist this many confirmed bars before a chart label appears. Reduces label noise in choppy zones.")

// ────────────────────────────────────────────────────────────────────────────
// Palette (matches CriptoMatiko brand — muted, never neon)
// ────────────────────────────────────────────────────────────────────────────
c_bull = color.rgb(132, 187, 161)   // soft green
c_bear = color.rgb(197, 127, 134)   // muted rose
c_side = color.rgb(164, 171, 183)   // cool grey

regime_color(r) => r == 1 ? c_bull : r == 2 ? c_bear : c_side
regime_name(r)  => r == 1 ? "BULL"    : r == 2 ? "BEAR"    : "LATERAL"
regime_label(r) => r == 1 ? "Alta"    : r == 2 ? "Baixa"   : "Lateral"
regime_icon(r)  => r == 1 ? " ▲"      : r == 2 ? " ▼"      : " ↔"

// ────────────────────────────────────────────────────────────────────────────
// Per-bar regime — rolling log-return
//
// No request.security() needed — operates on the chart's native timeframe.
// log_ret = log(close / close[N]) = total log-return over the lookback window.
// ────────────────────────────────────────────────────────────────────────────
log_ret = math.log(close / close[lookback_window])
regime  = na(log_ret) ? int(na)
     : log_ret >  bull_threshold_pct / 100.0 ? 1
     : log_ret < -bear_threshold_pct / 100.0 ? 2
     : 0

// ────────────────────────────────────────────────────────────────────────────
// Transition counting — persistent state across bars
//
// Row-major 3x3 flattened array: idx = prev_regime * 3 + curr_regime.
// Only counts on confirmed bars to avoid double-counting the live bar.
// ────────────────────────────────────────────────────────────────────────────
var counts = array.new_int(9, 0)

if barstate.isconfirmed and not na(regime[1]) and not na(regime)
    idx = regime[1] * 3 + regime
    array.set(counts, idx, array.get(counts, idx) + 1)

// ────────────────────────────────────────────────────────────────────────────
// Build P matrix — row-normalise counts into probabilities
//
// Run every bar (not just last) so persistence is a plottable series.
// Each row sums to 1.0; rows with zero observations fall back to uniform 1/3.
// ────────────────────────────────────────────────────────────────────────────
persistence = float(na)

if not na(regime)
    P = array.new_float(9, 0.0)
    for r = 0 to 2
        row_sum = array.get(counts, r*3) + array.get(counts, r*3+1) + array.get(counts, r*3+2)
        for c = 0 to 2
            v = row_sum > 0 ? float(array.get(counts, r*3+c)) / float(row_sum) : 1.0/3.0
            array.set(P, r*3+c, v)
    // Diagonal index for current regime: regime*3 + regime
    persistence := array.get(P, regime * 3 + regime) * 100.0

// ────────────────────────────────────────────────────────────────────────────
// Regime ribbon — subtle background tint
// ────────────────────────────────────────────────────────────────────────────
bgcolor(show_ribbon and not na(regime) ? color.new(regime_color(regime), 92) : na,
     title="Regime ribbon")

// ────────────────────────────────────────────────────────────────────────────
// Regime-change signals — debounced (Bot Signals style)
//
// A new regime must hold for min_hold confirmed bars before a signal fires.
// Prevents label/shape spam in choppy zones without affecting transition counts.
//
// label.new  : floating box showing new regime name + persistence % — detail.
// plotshape  : triangle/diamond arrow — quick visual scan (same style DCA bots).
//   Bull  → label.style_label_up   + location.belowbar (triangle ▲ below bar)
//   Bear  → label.style_label_down + location.abovebar (triangle ▼ above bar)
//   Lateral → label.style_label_right + location.abovebar (diamond ↔ above bar)
// ────────────────────────────────────────────────────────────────────────────
var int last_lbl_regime = na

held = not na(regime)
for k = 0 to min_hold - 1
    held := held and not na(regime[k]) and regime[k] == regime

regime_flip   = barstate.isconfirmed and not na(regime) and held and (na(last_lbl_regime) or regime != last_lbl_regime)
bull_start    = regime_flip and regime == 1
bear_start    = regime_flip and regime == 2
lateral_start = regime_flip and regime == 0

if regime_flip
    if show_labels
        lbl_txt   = regime_label(regime) + regime_icon(regime) + "\n" + str.tostring(math.round(persistence), "#") + "% persistência"
        lbl_style = regime == 1 ? label.style_label_up : regime == 2 ? label.style_label_down : label.style_label_right
        lbl_yloc  = regime == 1 ? yloc.belowbar : yloc.abovebar
        label.new(bar_index, na,
             lbl_txt,
             yloc      = lbl_yloc,
             style     = lbl_style,
             color     = color.new(regime_color(regime), 20),
             textcolor = color.white,
             size      = size.small)
    last_lbl_regime := regime

// Plotshape markers — mesmo estilo dos indicadores DCA / Bot Signals
plotshape(show_labels and bull_start,    "Alta (início)",    shape.triangleup,   location.belowbar,
     color=color.new(c_bull, 0),  size=size.small, textcolor=color.white)
plotshape(show_labels and bear_start,    "Baixa (início)",   shape.triangledown, location.abovebar,
     color=color.new(c_bear, 0),  size=size.small, textcolor=color.white)
plotshape(show_labels and lateral_start, "Lateral (início)", shape.diamond,      location.abovebar,
     color=color.new(c_side, 20), size=size.small, textcolor=color.white)

// ────────────────────────────────────────────────────────────────────────────
// Alerts — fire on confirmed bar close only
//
// Uses alert() (not alertcondition) so the message carries dynamic values:
// persistence % and close price. Set up as "Any alert() call" in TradingView.
// The persistence filter (min_persistence) blocks noisy low-confidence flips.
// ────────────────────────────────────────────────────────────────────────────
prev_regime    = regime[1]
regime_changed = barstate.isconfirmed and not na(prev_regime) and not na(regime) and regime != prev_regime
above_thresh   = not na(persistence) and persistence >= float(min_persistence)

if regime_changed and above_thresh
    alert(
         "REGIME: "      + regime_name(regime)                              + "\n" +
         "Anterior: "    + regime_name(prev_regime)                         + "\n" +
         "Persistencia: "+ str.tostring(math.round(persistence), "#") + "%" + "\n" +
         "Preco: "       + str.tostring(close, format.mintick)              + "\n" +
         "Indicador: Markov | CriptoMatiko",
         alert.freq_once_per_bar_close)

// ────────────────────────────────────────────────────────────────────────────
// Info table — compact panel (regime + persistence + alert status)
// ────────────────────────────────────────────────────────────────────────────
var table tbl = table.new(position.bottom_right, 2, 6,
     bgcolor      = color.new(color.black, 15),
     frame_color  = color.gray,
     frame_width  = 1,
     border_width = 1)

if show_table and barstate.islast and not na(regime) and not na(persistence)
    rc    = regime_color(regime)
    above = persistence >= float(min_persistence)

    table.cell(tbl, 0, 0, "Markov Regime",
         text_color=color.white, bgcolor=color.new(color.gray, 40),
         text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 0, "CM",
         text_color=color.new(color.teal, 20), bgcolor=color.new(color.gray, 40),
         text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 1, "Regime",
         text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(tbl, 1, 1, regime_label(regime),
         text_color=color.white, bgcolor=color.new(rc, 20),
         text_size=size.normal, text_halign=text.align_center)

    table.cell(tbl, 0, 2, "Persistência",
         text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    pers_bg = above ? color.new(color.green, 50) : color.new(color.orange, 50)
    table.cell(tbl, 1, 2, str.tostring(math.round(persistence), "#") + "%",
         text_color=color.white, bgcolor=pers_bg,
         text_size=size.normal, text_halign=text.align_center)

    table.cell(tbl, 0, 3, "Alerta ativo?",
         text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    alert_status = above
         ? "SIM  (>=" + str.tostring(min_persistence) + "%)"
         : "NAO  (<"  + str.tostring(min_persistence) + "%)"
    alert_bg = above ? color.new(color.green, 60) : color.new(color.gray, 70)
    table.cell(tbl, 1, 3, alert_status,
         text_color=color.white, bgcolor=alert_bg,
         text_size=size.tiny, text_halign=text.align_center)

    table.cell(tbl, 0, 4, "Log-ret " + str.tostring(lookback_window) + "b",
         text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    lr_color = log_ret > 0 ? color.new(color.green, 50) : color.new(color.red, 50)
    table.cell(tbl, 1, 4, str.tostring(math.round(log_ret * 100, 1), "+#.#;-#.#") + "%",
         text_color=color.white, bgcolor=lr_color,
         text_size=size.small, text_halign=text.align_center)

    table.cell(tbl, 0, 5, "Educational",
         text_color=color.new(color.teal, 40), text_size=size.tiny)
    table.cell(tbl, 1, 5, "",
         text_size=size.tiny)

// ────────────────────────────────────────────────────────────────────────────
// Plots — hidden by default; uncomment to export values to Pine strategies
// ────────────────────────────────────────────────────────────────────────────
// plot(regime,        "Regime (1=Bull 2=Bear 0=Lateral)", display=display.none)
// plot(persistence,   "Persistence (%)",                  display=display.none)
// plot(log_ret * 100, "Log Return (%)",                   display=display.none)
````
