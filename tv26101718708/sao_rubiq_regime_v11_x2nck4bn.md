# SAO RUBIQ Regime v1.1

- url: https://www.tradingview.com/script/x2nCK4bn-SAO-RUBIQ-Regime-v1-1/
- type: indicator
- pine_id: PUB;ab1cc486b27243f99c880791b0a53dca
- version: 1.0

## Description

# SAO · RUBIQ — Regime Visualizer

**by SNP420 · Jarvis Claudos · Finexus s.r.o.**
*Pine Script v6 · Build 2026-05-26*

---

## What is it

A research-grade market regime overlay that classifies every confirmed
bar into one of **five regimes** and paints the chart accordingly.
Born out of a simple insight:

> *"The right algorithm in the wrong phase of the market still fails —
> even when it is 100% correct under ideal conditions."*

This is the central thesis of the **SAO · RUBIQ** project: every
strategy lives or dies inside a specific regime × timeframe cell.
Without active regime perception, every trading system is necessarily
under-performing on the bars it was not designed for. This indicator
makes those cells visible.

## The five regimes

| Regime        | Meaning                                                  |
| ------------- | -------------------------------------------------------- |
| **BULL_CALM** | Trending up with low realized volatility                 |
| **BEAR_CALM** | Trending down with low realized volatility               |
| **RANGE**     | Sideways with narrow Bollinger width                     |
| **CHOPPY**    | Sideways with high noise / many directional flips        |
| **STRESS**    | Volatility spike — any 2 of {rv, ATR z-score, bar range} |
| *UNCERTAIN*   | Fallback — nothing fits cleanly (no box drawn)           |

Priority order: **STRESS > BULL > BEAR > RANGE > CHOPPY > UNCERTAIN.**

## How it works

The indicator computes the full RUBIQ v1.1 feature stack on every bar:

- ATR(14), ADX/DI(14), Bollinger(20, 2)
- 20-bar realized volatility, 30-bar directional flips
- HH / HL / LH / LL pivot-swing counts in a 30-bar window
- 500-bar rolling medians for BBwidth, RV, ATR, bar range
- ATR z-score, bar-range ratio, price drift in ATR units

It then applies a calibrated rule set (per-feature thresholds derived
from EUR/USD M30 2024-2025 baseline) and assigns one of the six labels.
A hysteresis smoother (`min_run = 5` bars, configurable) suppresses
flicker — a regime is only committed after enough confirming bars.

## Visualization (FX-Sessions-style)

- **Dashed segment boxes** — one box per confirmed regime run, sized
  to that segment's high/low range. Mirrors the FX Market Sessions look.
- **Background tint** — semi-transparent regime color over the active span.
- **Bar color** (off by default) — paints OHLC bars with the regime color.
- **Segment label** — regime name anchored to the top of the box.
- **Info table** (top-right) — current state + live feature values.
- **Stats table** (bottom-right) — N bars and % share per regime across
  the visible history.

UNCERTAIN bars deliberately render no box and no tint — keeps the
chart clean and matches the "no session" look of FX Sessions.

## Settings worth knowing

- **Calibrated v1.1 rules** (default on) — ~45% confident coverage on
  EUR/USD M30. Turn off for strict v1 (~6% coverage, mostly UNCERTAIN —
  useful for research only).
- **Hysteresis min_run** — bars of consistent raw state before commit.
  Bigger value = less flicker, more boundary lag.
- **Norm median lookback** (500) — window for the rolling median of
  BBwidth / RV / ATR / bar range. Lower it for faster adaptation.
- **Swing / drift window** (30) — pivot-count window and `price_drift_atr`
  reference horizon.
- **All six regime colors** — fully overridable.

## Sanity-check expectation (EUR/USD M30, 2 years)

If the calibration baseline holds on your data window, the stats
table should land near:

| State     | Share  |
| --------- | ------ |
| BULL_CALM | ~12%   |
| BEAR_CALM | ~12%   |
| RANGE     | ~7%    |
| CHOPPY    | ~10%   |
| STRESS    | ~3.5%  |
| UNCERTAIN | ~55%   |

Any major divergence on a fresh window = signal to re-validate
(regime shift, threshold drift, or data-feed alignment).

## Honest limitations — please read

- **Tuned to EUR/USD M30 vol scale.** Features themselves are
  TF-agnostic, but the cut points (`rv20_norm < 1.8`, `ADX > 20`,
  `price_drift_atr > 1.5`, etc.) were calibrated on M30. On H1, D1,
  crypto or equities the regime distribution will be approximate
  unless you re-tune.
- **v1.1 direction-mapping is incomplete.** Validation diagonal score
  is 1/5 — BEAR_CALM bars in the 2024-2025 baseline have a slight
  *positive* forward drift. The labels are statistically informative
  (shuffle MC p<0.001) but trade-direction routing needs a v1.2 fix.
  **Treat this indicator as a labeled regime overlay for research, not
  as a stand-alone trade-direction signal.**
- **Streaming hysteresis ≠ offline two-sided smoothing.** Boundary
  detection lags by approximately `min_run - 1` bars in real time.

## Alerts

Five alert conditions ship in:

- Regime → STRESS
- Regime → BULL_CALM
- Regime → BEAR_CALM
- Regime → RANGE
- Regime → CHOPPY

Each fires on transition (state differs from previous bar).

## Credits & attribution

- **Visual style** inspired by *FX Market Sessions* by **boitoki**
  (Mozilla Public License 2.0). The segment-box-per-run pattern is
  borrowed from that script; all classifier logic and feature math
  is original to SAO · RUBIQ.
- **RUBIQ thesis** — *Rubik's-cube model of the market*: the right
  algorithm in the wrong market phase still fails. Distilled from
  100+ failed variants across the SAO portfolio.
- **Built by** SNP420 · Jarvis Claudos · Finexus s.r.o.

## License

Same as the parent SAO_RUBIQ project. Use freely, modify freely,
attribute when republishing.

---

*"Trh je proměnlivé prostředí. RUBIQ je centrální nervová soustava,
která to řeší pro všechny SAO strategie."*

— SNP420

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════════════════
//
//      ███████╗██╗███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗
//      ██╔════╝██║████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝
//      █████╗  ██║██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗
//      ██╔══╝  ██║██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║
//      ██║     ██║██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║   s.r.o.
//      ╚═╝     ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
//
//      ──────────────────────────────────────────────────────────────────────
//        author    ::  SNP420   ·   Jarvis Claudos
//        product   ::  SAO · RUBIQ   —   Regime Visualizer
//        build     ::  Pine Script v6     ·     2026-05-26
//        license   ::  same as parent SAO_RUBIQ project
//      ──────────────────────────────────────────────────────────────────────
//
// ════════════════════════════════════════════════════════════════════════════════
//
//                          _______
//              _,.--''''''  -    ''`-...__
//            /''___...---    -   ---..    `.._
//          .,--'              `-  __  `-.     .
//        .'/     ___..--------  -   ''---'-.   `.
//        /J  ,-''         __,.   -   .._  `-'-. `\
//      ,//  |     _..--'''    _         '-._|  `  \
//     / |  ,'  ,-'      _..--'    -  _____ `\|  '  `.
//   ,'  /    ,'  ,  ,.-'   _.-            '-'|    | \
//   '  / .','   / ,-    _,'  :  :      -.    '.|  |  \
//     |  /'    //'    /'   . /  | \  \   \    \+   |  |
//     | //   .'/     |     |.'  | |   |  '.    +\  |  \
//     ||/    J|      /    / |   | '.  '.  |    '.\ \   \
//     |||   | |     |   ,'  |   |  \   \   |   || ||   |
//     ||    J J    ,'   |  /_   |  |   |  ,|    |   |  |
//     ||   | |    .'|. .||/'|   | / |  + |\'     |  |  |
//     ||   | |  . | \ ./ |,'|/'|'/\  _'|,'| /  / |  |  L
//     ||   | | |'.| |'--..._`  | /| ,' |'_,.. -  || |   |
//     /L   | / | \|,.....  -'\ |/ |/  . .....    |\ |  .'
//     | |  | | |   `._(  )\           /(  )_.'   |  |  /
//    | .\  J | \      '''''           '````     /'   .|
//    |  | |  |  |                              .|  ,.'|
//    |  |.'. | _\.                             /  / | |
//    || || |  \'\:                            /   | / |
//     +L||-\...__ -._                        / /  | | |
//   | '||.+ \ _  '`-.:._     _     _        /'|   J|  J
//   |  \\ +` \ -.     `       `...'        ,' |  | | |
//   |  || |.  .         _ _               /'  |  | | |
//   |  '.  |   \          \''------;'   ,'.'  |  | | |
//    |  || |\   `._        '-.._..'   ,/  |   |  / | L
//    \  ||  |\     '-.               ,|'' |   |  | | '|
//     | '.| \ `\      `             J ||  |   |  | |  |
//     \  ||  |  \       '..      ,-'  /|  |   |  | |  L.
//     '. ||  `    -.       '''`-' |   '|  |   /  | |   |
//      | | |  '-..  `.            '''-'\ ._....._| |   |
//      | | '.         `                ||_ `.     ' . |
//     /+    \                         /'|'`. \        `.
//     \_'                           ,-,/.   \ \         \
//    \,,' _--..__                _,/,/   `   \ \         \
//    \'\  ||  ..__'--......___./, -,  ``      \ \         .
//     \ \ ''   ||`'+--..... . -'\\  \\        | |         |
//      \ \     ||' ||   ||  \\   \\  "        \ \         |
//       \ \        ||   ||   \\   "            \ \        '
//       \  \                                    \ \      /
//        \  .                                    \ \   |/
//         | .                                     \ \  |
//         |  .                                    '  \ |
//         \  .                                     \  \|
//          \  \                                     \  `.
//           |  \                                     \   \
//           |   \                                     \   `.
//           '    \                                     Y    \
//            |    \               .                    |     \
//            |     '               `                   J      `
//            |      `.              `                 /         \
//           J         `.             `               /           '
//           |           `._           `             '             `
//           |              '-._        `           .              :
//          J                   `-.._    .         /
//          |                        -.  :        /                '
//          |                          `\:      .                ,'
//          J                            Y    ,'                '
//         /                             |-._/                '
//        /                              |  /          _,_,.'
//       .'                              | Y       , -' '  |
//       J                               | | ,..--'        |
//     _-.                               /.-             _/
//      |  -.._                    _, -'''             , '/
//      |     '-...._________,.-''                 ,-'  /
//      |                                    __,,-'     |\
//      |_                             __.-.''          | \
//       '`-..___            _____, -''  /'\            |  \
//       \       '''-------''           /   \           |   \
//        \                            /     \       _.'|    \
//         |                          /       \  _.-'   |     \
//         |                         /         -'       |      \
//         |`-._                    /                   \       \
//         |    '--..____,......---'                     \       \
//       ,'                                               \       .
//     ,'                                                 /\       .
//   .'                                                  /  \       .
//  '  \                                                /    \
//      \                                  ( )         /      \
//       \                                            /        \
//        \                                          /
//
// ════════════════════════════════════════════════════════════════════════════════
//
//   "Spravny algoritmus ve spatne fazi trhu = fail.   RUBIQ = Rubikova kostka trhu."
//
// ════════════════════════════════════════════════════════════════════════════════
//
//   SAO RUBIQ — Regime Visualizer for TradingView
//   Pine Script v6 port of RUBIQ v1.1 calibrated 5-state regime classifier.
//
//   Source of truth (Python, local):
//     ~/SAO_RUBIQ/rubiq/regime/features.py     (feature engineering)
//     ~/SAO_RUBIQ/rubiq/regime/classifier.py   (rule masks + hysteresis)
//
//   Visual style inspired by boitoki/FX Market Sessions
//   (segment box per confirmed run + bg tint + label).
//
//   Calibration baseline: EUR/USD M30, 2024-2025 (24,863 live bars).
//   Features are TF-agnostic; thresholds (rv20_norm, price_drift_atr, ADX cuts)
//   are tuned to M30 vol scale. On other TF re-tune via shuffle MC.
//
//   Known v1.1 issue (see notes/2026-05-26_v11-validation-results.md):
//     Direction-mapping diagonal score 1/5 — BEAR_CALM bars actually have
//     slight positive forward drift. Labels are statistically informative
//     (shuffle MC p<0.001) but strategy-routing needs v1.2 fix. Use as
//     research/visualization tool, not as live trade signal yet.
//
// ════════════════════════════════════════════════════════════════════════════════

//@version=6
indicator('SAO RUBIQ Regime v1.1', 'RUBIQ', overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=500,
     explicit_plot_zorder=true)

// ========================================================================
// GROUPS
// ========================================================================
g_show    = '// DISPLAY //'
g_rules   = '// RULES //'
g_colors  = '// COLORS //'
g_table   = '// TABLES //'

// ========================================================================
// INPUTS
// ========================================================================
i_show_bg        = input.bool(true,  'Background tint', group=g_show)
i_show_boxes     = input.bool(true,  'Segment boxes',   group=g_show)
i_show_barcolor  = input.bool(false, 'Bar color',       group=g_show)
i_show_label     = input.bool(true,  'Segment label',   group=g_show)
i_show_table     = input.bool(true,  'Info table',      group=g_table)
i_show_stats     = input.bool(true,  'Stats table',     group=g_table)

i_calibrated     = input.bool(true,  'Calibrated v1.1 rules (off = strict v1)', group=g_rules)
i_min_run        = input.int(5,      'Hysteresis min_run (bars)',  minval=1, group=g_rules)
i_median_lb      = input.int(500,    'Norm median lookback (bars)', minval=100, group=g_rules)
i_swing_window   = input.int(30,     'Swing / drift window (bars)', minval=10, group=g_rules)
i_pivot_window   = input.int(3,      'Pivot left/right (bars)',     minval=1,  group=g_rules)

c_bull           = input.color(#26A69A, 'BULL_CALM', group=g_colors)
c_bear           = input.color(#EF5350, 'BEAR_CALM', group=g_colors)
c_range          = input.color(#5C6BC0, 'RANGE',     group=g_colors)
c_choppy         = input.color(#FF9800, 'CHOPPY',    group=g_colors)
c_stress         = input.color(#D81B60, 'STRESS',    group=g_colors)
c_uncertain      = input.color(color.new(#888888, 70), 'UNCERTAIN', group=g_colors)

bg_transp        = input.int(88, 'Background transparency', minval=50, maxval=100, group=g_colors)
box_transp       = input.int(92, 'Box bg transparency',     minval=50, maxval=100, group=g_colors)

// ========================================================================
// FEATURES — port of features.py
// ========================================================================
ma20  = ta.sma(close, 20)
ma50  = ta.sma(close, 50)
atr14 = ta.atr(14)
[di_plus, di_minus, adx] = ta.dmi(14, 14)
[bb_mid, bb_upper, bb_lower] = ta.bb(close, 20, 2.0)
bb_width = bb_mid != 0 ? (bb_upper - bb_lower) / bb_mid : na

log_ret = math.log(close / close[1])
rv20    = ta.stdev(log_ret, 20) * math.sqrt(20)

sign_curr = math.sign(close - close[1])
sign_prev = math.sign(close[1] - close[2])
flip      = sign_curr != sign_prev ? 1.0 : 0.0
dir_flips_30 = ta.sma(flip, 30)

bar_range = high - low

// rolling medians via 50th percentile (matches pandas rolling().median())
bw_med  = ta.percentile_linear_interpolation(bb_width,  i_median_lb, 50)
rv_med  = ta.percentile_linear_interpolation(rv20,      i_median_lb, 50)
atr_med = ta.percentile_linear_interpolation(atr14,     i_median_lb, 50)
br_med  = ta.percentile_linear_interpolation(bar_range, i_median_lb, 50)
atr_std = ta.stdev(atr14, i_median_lb)

bb_width_norm   = bw_med  != 0 ? bb_width  / bw_med  : na
rv20_norm       = rv_med  != 0 ? rv20      / rv_med  : na
atr_z           = atr_std != 0 ? (atr14 - atr_med) / atr_std : na
bar_range_ratio = br_med  != 0 ? bar_range / br_med  : na
bb_width_slope5 = bb_width - bb_width[5]

atr14_avg14     = ta.sma(atr14, 14)
price_drift_atr = atr14_avg14 != 0 ? (close - close[i_swing_window]) / atr14_avg14 : na

// ========================================================================
// SWING STRUCTURE — HH/HL/LH/LL counts in trailing swing_window bars
// ========================================================================
ph = ta.pivothigh(i_pivot_window, i_pivot_window)
pl = ta.pivotlow (i_pivot_window, i_pivot_window)

var float last_ph = na
var float last_pl = na
var array<int> hh_bars = array.new<int>()
var array<int> hl_bars = array.new<int>()
var array<int> lh_bars = array.new<int>()
var array<int> ll_bars = array.new<int>()

ph_bar = bar_index - i_pivot_window
pl_bar = bar_index - i_pivot_window

if not na(ph)
    if not na(last_ph)
        if ph > last_ph
            array.push(hh_bars, ph_bar)
        else if ph < last_ph
            array.push(lh_bars, ph_bar)
    last_ph := ph

if not na(pl)
    if not na(last_pl)
        if pl < last_pl
            array.push(ll_bars, pl_bar)
        else if pl > last_pl
            array.push(hl_bars, pl_bar)
    last_pl := pl

trim_old(array<int> arr, int cutoff) =>
    while array.size(arr) > 0 and array.first(arr) < cutoff
        array.shift(arr)

cutoff_bar = bar_index - i_swing_window
trim_old(hh_bars, cutoff_bar)
trim_old(hl_bars, cutoff_bar)
trim_old(lh_bars, cutoff_bar)
trim_old(ll_bars, cutoff_bar)

hh_n = array.size(hh_bars)
hl_n = array.size(hl_bars)
lh_n = array.size(lh_bars)
ll_n = array.size(ll_bars)

// ========================================================================
// CLASSIFIER — port of classifier.py masks + priority
// ========================================================================
// STRESS — vol spike / panic: any 2-of-3 of {rv>2x, atr_z>2, bar_range>3x}
stress_cnt = (nz(rv20_norm)       > 2.0 ? 1 : 0) +
              (nz(atr_z)           > 2.0 ? 1 : 0) +
              (nz(bar_range_ratio) > 3.0 ? 1 : 0)
is_stress = stress_cnt >= 2

// Calibrated v1.1 masks (default — usable coverage ~45%)
is_bull_c   = close > ma50 and ma20 > ma50 and adx > 20 and di_plus > di_minus
                  and nz(price_drift_atr) >  1.5 and nz(rv20_norm, 9.0) < 1.8
is_bear_c   = close < ma50 and ma20 < ma50 and adx > 20 and di_minus > di_plus
                  and nz(price_drift_atr) < -1.5 and nz(rv20_norm, 9.0) < 1.8
is_range_c  = adx < 22 and nz(bb_width_norm, 9.0) < 0.9
                  and math.abs(nz(price_drift_atr)) < 1.8 and nz(rv20_norm, 9.0) < 1.2
is_choppy_c = adx < 25 and nz(rv20_norm) > 1.0 and nz(dir_flips_30) > 0.35

// Strict v1 masks (research mode — coverage <7%, ~94% UNCERTAIN)
is_bull_s   = close > ma50 and ma20 > ma50 and adx > 25 and di_plus > di_minus
                  and (hh_n + hl_n) >= 8 and nz(rv20_norm, 9.0) < 1.5 and nz(bb_width_slope5) > 0
is_bear_s   = close < ma50 and ma20 < ma50 and adx > 25 and di_minus > di_plus
                  and (lh_n + ll_n) >= 8 and nz(rv20_norm, 9.0) < 1.5 and nz(bb_width_slope5) > 0
is_range_s  = adx < 20 and nz(bb_width_norm, 9.0) < 0.7
                  and math.abs(nz(price_drift_atr)) < 1.5 and nz(rv20_norm, 9.0) < 1.0
is_choppy_s = adx < 25 and nz(rv20_norm) > 1.3 and nz(dir_flips_30) > 0.4
                  and math.abs(nz(price_drift_atr)) < 2.0

is_bull   = i_calibrated ? is_bull_c   : is_bull_s
is_bear   = i_calibrated ? is_bear_c   : is_bear_s
is_range  = i_calibrated ? is_range_c  : is_range_s
is_choppy = i_calibrated ? is_choppy_c : is_choppy_s

// Priority: STRESS > BULL > BEAR > RANGE > CHOPPY > UNCERTAIN
raw_state = is_stress                                                              ? 'STRESS' :
             (is_bull and not is_stress)                                            ? 'BULL_CALM' :
             (is_bear and not is_stress)                                            ? 'BEAR_CALM' :
             (is_range  and not is_stress and not is_bull and not is_bear)          ? 'RANGE' :
             (is_choppy and not is_stress and not is_bull and not is_bear and not is_range) ? 'CHOPPY' :
             'UNCERTAIN'

// ========================================================================
// HYSTERESIS — streaming approximation of min_run smoothing
// (offline pandas version is two-sided; here we commit after min_run
//  consecutive same raw_state bars. Boundary lag ≈ min_run-1 bars.)
// ========================================================================
var string committed_state = 'UNCERTAIN'
var string prev_raw        = 'UNCERTAIN'
var int    candidate_run   = 0

if raw_state == prev_raw
    candidate_run := candidate_run + 1
else
    prev_raw      := raw_state
    candidate_run := 1

if candidate_run >= i_min_run
    committed_state := raw_state

// ========================================================================
// COLORS
// ========================================================================
state_color(string s) =>
    switch s
        'BULL_CALM' => c_bull
        'BEAR_CALM' => c_bear
        'RANGE'     => c_range
        'CHOPPY'    => c_choppy
        'STRESS'    => c_stress
        =>             c_uncertain

cur_color = state_color(committed_state)
is_unc    = committed_state == 'UNCERTAIN'

// ========================================================================
// RENDER — background tint + bar color
// ========================================================================
bgcolor(i_show_bg     and not is_unc ? color.new(cur_color, bg_transp) : na, title='Regime bg')
barcolor(i_show_barcolor and not is_unc ? cur_color : na,                     title='Regime bar')

// ========================================================================
// RENDER — segment boxes (FX-Sessions-style)
// ========================================================================
var box   cur_box     = na
var label cur_label   = na
var float seg_top     = na
var float seg_bottom  = na
var int   seg_start   = na

state_changed = committed_state != committed_state[1]

if state_changed
    // close prior segment
    if not na(cur_box)
        box.set_right(cur_box, bar_index - 1)
    if not na(cur_label) and not na(seg_start)
        label.set_x(cur_label, math.round((seg_start + bar_index - 1) / 2.0))
    // open new segment (only if not UNCERTAIN — keeps chart clean like FX Sessions)
    if i_show_boxes and not is_unc
        seg_top    := high
        seg_bottom := low
        seg_start  := bar_index
        cur_box := box.new(bar_index, high, bar_index, low,
                             border_color=cur_color, border_width=1, border_style=line.style_dashed,
                             bgcolor=color.new(cur_color, box_transp))
        if i_show_label
            cur_label := label.new(bar_index, high, committed_state,
                                     style=label.style_label_lower_left,
                                     color=color.new(cur_color, 50),
                                     textcolor=color.white,
                                     size=size.small)
        else
            cur_label := na
    else
        cur_box   := na
        cur_label := na
else if not na(cur_box)
    seg_top    := math.max(seg_top, high)
    seg_bottom := math.min(seg_bottom, low)
    box.set_top   (cur_box, seg_top)
    box.set_bottom(cur_box, seg_bottom)
    box.set_right (cur_box, bar_index)
    if not na(cur_label)
        label.set_y(cur_label, seg_top)

// ========================================================================
// STATS — running per-regime bar counts
// ========================================================================
var int n_bull   = 0
var int n_bear   = 0
var int n_range  = 0
var int n_chop   = 0
var int n_stress = 0
var int n_unc    = 0

if barstate.isconfirmed
    if committed_state == 'BULL_CALM'
        n_bull := n_bull + 1
    else if committed_state == 'BEAR_CALM'
        n_bear := n_bear + 1
    else if committed_state == 'RANGE'
        n_range := n_range + 1
    else if committed_state == 'CHOPPY'
        n_chop := n_chop + 1
    else if committed_state == 'STRESS'
        n_stress := n_stress + 1
    else
        n_unc := n_unc + 1

n_total = n_bull + n_bear + n_range + n_chop + n_stress + n_unc

// ========================================================================
// TABLES
// ========================================================================
var color tcol_dim   = color.new(#888888, 30)
var color tcol_white = #e1e2e4
var color tbl_bg     = #1a1c20
var color tbl_frame  = #25272c

// info table (top-right)
var table tbl_info = na
if i_show_table and barstate.isfirst
    tbl_info := table.new(position.top_right, 2, 9,
                            frame_width=1, frame_color=tbl_frame,
                            border_width=1, border_color=tbl_frame,
                            bgcolor=tbl_bg)

if i_show_table and barstate.islast
    table.cell(tbl_info, 0, 0, 'RUBIQ v1.1', text_color=tcol_white, bgcolor=tbl_frame, text_size=size.small)
    table.cell(tbl_info, 1, 0, i_calibrated ? 'calibrated' : 'strict',
                                                       text_color=color.new(tcol_white, 40), bgcolor=tbl_frame, text_size=size.small)
    table.cell(tbl_info, 0, 1, 'State',    text_color=tcol_dim,   text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 1, committed_state, text_color=cur_color, text_size=size.small, text_halign=text.align_right)
    table.cell(tbl_info, 0, 2, 'ADX',      text_color=tcol_dim,   text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 2, str.tostring(adx, '#.#'),                                  text_color=tcol_white, text_size=size.tiny, text_halign=text.align_right)
    table.cell(tbl_info, 0, 3, 'DI+/DI-',  text_color=tcol_dim,   text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 3, str.tostring(di_plus, '#.#')+'/'+str.tostring(di_minus, '#.#'),
                                                                                          text_color=tcol_white, text_size=size.tiny, text_halign=text.align_right)
    table.cell(tbl_info, 0, 4, 'BBwidth_n',text_color=tcol_dim,   text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 4, str.tostring(bb_width_norm, '#.##'),                       text_color=tcol_white, text_size=size.tiny, text_halign=text.align_right)
    table.cell(tbl_info, 0, 5, 'RV20_n',   text_color=tcol_dim,   text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 5, str.tostring(rv20_norm, '#.##'),                           text_color=tcol_white, text_size=size.tiny, text_halign=text.align_right)
    table.cell(tbl_info, 0, 6, 'ATR_z',    text_color=tcol_dim,   text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 6, str.tostring(atr_z, '#.##'),                               text_color=tcol_white, text_size=size.tiny, text_halign=text.align_right)
    table.cell(tbl_info, 0, 7, 'Drift_atr',text_color=tcol_dim,   text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 7, str.tostring(price_drift_atr, '#.##'),                     text_color=tcol_white, text_size=size.tiny, text_halign=text.align_right)
    table.cell(tbl_info, 0, 8, 'Flips30',  text_color=tcol_dim,   text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 8, str.tostring(dir_flips_30, '#.##'),                        text_color=tcol_white, text_size=size.tiny, text_halign=text.align_right)

// stats table (bottom-right)
stats_row(table tbl, int row, string lbl, int n, int total, color c) =>
    pct = total > 0 ? n / float(total) : 0.0
    table.cell(tbl, 0, row, lbl, text_color=c,         text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, row, str.tostring(n),           text_color=#e1e2e4, text_size=size.tiny, text_halign=text.align_right)
    table.cell(tbl, 2, row, str.format('{0,number,percent}', pct), text_color=#e1e2e4, text_size=size.tiny, text_halign=text.align_right)

var table tbl_stats = na
if i_show_stats and barstate.isfirst
    tbl_stats := table.new(position.bottom_right, 3, 7,
                              frame_width=1, frame_color=tbl_frame,
                              border_width=1, border_color=tbl_frame,
                              bgcolor=tbl_bg)

if i_show_stats and barstate.islast and n_total > 0
    table.cell(tbl_stats, 0, 0, 'Regime', text_color=tcol_white, bgcolor=tbl_frame, text_size=size.tiny)
    table.cell(tbl_stats, 1, 0, 'N',      text_color=tcol_white, bgcolor=tbl_frame, text_size=size.tiny)
    table.cell(tbl_stats, 2, 0, '%',      text_color=tcol_white, bgcolor=tbl_frame, text_size=size.tiny)
    stats_row(tbl_stats, 1, 'BULL',   n_bull,   n_total, c_bull)
    stats_row(tbl_stats, 2, 'BEAR',   n_bear,   n_total, c_bear)
    stats_row(tbl_stats, 3, 'RANGE',  n_range,  n_total, c_range)
    stats_row(tbl_stats, 4, 'CHOPPY', n_chop,   n_total, c_choppy)
    stats_row(tbl_stats, 5, 'STRESS', n_stress, n_total, c_stress)
    stats_row(tbl_stats, 6, 'UNC',    n_unc,    n_total, color.gray)

// ========================================================================
// ALERTS
// ========================================================================
alertcondition(committed_state == 'STRESS'    and committed_state[1] != 'STRESS',    'Regime → STRESS',    'RUBIQ regime entered STRESS')
alertcondition(committed_state == 'BULL_CALM' and committed_state[1] != 'BULL_CALM', 'Regime → BULL_CALM', 'RUBIQ regime entered BULL_CALM')
alertcondition(committed_state == 'BEAR_CALM' and committed_state[1] != 'BEAR_CALM', 'Regime → BEAR_CALM', 'RUBIQ regime entered BEAR_CALM')
alertcondition(committed_state == 'RANGE'     and committed_state[1] != 'RANGE',     'Regime → RANGE',     'RUBIQ regime entered RANGE')
alertcondition(committed_state == 'CHOPPY'    and committed_state[1] != 'CHOPPY',    'Regime → CHOPPY',    'RUBIQ regime entered CHOPPY')

// ========================================================================
// PLOTS (data window only — invisible by default)
// ========================================================================
plot(adx,             'ADX',             display=display.data_window, color=color.gray)
plot(di_plus,         'DI+',             display=display.data_window, color=color.green)
plot(di_minus,        'DI-',             display=display.data_window, color=color.red)
plot(bb_width_norm,   'BBwidth_norm',    display=display.data_window, color=color.blue)
plot(rv20_norm,       'RV20_norm',       display=display.data_window, color=color.orange)
plot(atr_z,           'ATR_z',           display=display.data_window, color=color.purple)
plot(price_drift_atr, 'Drift_atr',       display=display.data_window, color=color.aqua)
plot(dir_flips_30,    'Flips_30',        display=display.data_window, color=color.fuchsia)
plot(hh_n + hl_n,     'HH+HL',           display=display.data_window, color=color.lime)
plot(lh_n + ll_n,     'LH+LL',           display=display.data_window, color=color.maroon)
````
