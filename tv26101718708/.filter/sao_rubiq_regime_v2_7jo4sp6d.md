# SAO RUBIQ Regime v2

- url: https://www.tradingview.com/script/7jo4sp6D-SAO-RUBIQ-Regime-v2/
- type: indicator
- pine_id: PUB;b94c5595dd8242a1a467edee0a41d42e
- version: 1.0

## Description

# SAO · RUBIQ — Regime Visualizer  (v2)

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

## What's new in v2

v2 throws out the v1 AND-stack of ADX / BB-width / drift cutoffs and
replaces it with four orthogonal signals that vote together:

- **Fractal pivots** (3-bar centered) labeled **HH / LH / HL / LL**
- **Trend state machine** with **re-anchoring**:
  UP / DOWN / RANGE / REVERSAL_UP / REVERSAL_DOWN
- **Multi-TF RSI** on M30 / H1 / H4 / D1 / W1 with per-TF thresholds
  and a **≥3 of 5 agreement** rule
- **S/R level clustering** (±0.3 ATR tolerance) with **double-bounce**
  reversal flag that persists for 10 bars

Measured improvements over v1.1 on EUR/USD M30, 2024-2025 (24,863 bars):

| Metric                  | v1.1 calibrated | v2          |
| ----------------------- | --------------- | ----------- |
| Confident coverage      | 44.87%          | **53.96%**  |
| Transitions (less whipsaw) | 1,567        | **855**     |
| BULL_CALM Sharpe (h=5)  | +0.085          | **+0.271**  |
| BEAR_CALM direction     | +0.04 ⚠ (wrong)| **−0.19 ✅** |
| Shuffle F-stat (h=5)    | 0.0027          | **0.0068**  |
| Strategy diagonal score | 1 / 5           | **2 / 5**   |

All validated by 1000-iter shuffle Monte Carlo (p < 0.001) and a
strategy × regime P&L matrix.

## The five regimes

| Regime        | Meaning                                                  |
| ------------- | -------------------------------------------------------- |
| **BULL_CALM** | Trend UP + ≥3 of 5 RSI TFs agree bullish                 |
| **BEAR_CALM** | Trend DOWN + ≥3 of 5 RSI TFs agree bearish               |
| **RANGE**     | Mixed last pivots (no clean HH+HL or LH+LL)              |
| **CHOPPY**    | Trend UP/DOWN without RSI agreement, or active reversal  |
| **STRESS**    | Volatility spike: rv20_norm > 2  OR  atr_z > 2           |
| *UNCERTAIN*   | Fallback — pre-warmup or no labels yet (no box drawn)    |

Priority order (highest wins): **STRESS > BULL > BEAR > CHOPPY > RANGE.**

## How it works

For every confirmed bar the indicator:

1. Computes ATR(14), realized vol (20), z-scored ATR — used by stress
   detection and S/R cluster tolerance.
2. Requests RSI(14) on five timeframes via `request.security`
   (M30 / H1 / H4 / D1 / W1) and counts bull / bear agreements.
3. Detects fractal pivots with `ta.pivothigh / pivotlow(3, 3)` and
   labels each as HH / LH / HL / LL versus the previous same-type
   pivot.
4. Adds each pivot to a greedy S/R level cluster (±0.3 ATR). On the
   second touch within 500 bars it fires a **double-bounce reversal**
   flag (type H → REVERSAL_DOWN, type L → REVERSAL_UP) that persists
   for 10 bars.
5. Maintains a trend state machine: **UP** when last H=HH and last L=HL,
   **DOWN** when last H=LH and last L=LL, **RANGE** otherwise.
6. Combines trend × RSI × stress into the final label, then applies
   a hysteresis smoother (`min_run = 5 bars`) so single-bar flips
   never get committed.

## Visualization (FX-Sessions-style)

- **Dashed segment box** per confirmed regime run, sized to that
  segment's high/low.
- **Background tint** — semi-transparent regime color over the span.
- **Bar color** (off by default) — paints OHLC bars with regime color.
- **Segment label** anchored to the top of each box.
- **Pivot markers** — HH / LH / HL / LL drawn at every confirmed pivot
  with bull/bear tint.
- **Reversal arrows** — ▲ green at support double-bounces, ▼ red at
  resistance double-bounces.
- **Info table** (top-right) — current state, trend, last H and L labels,
  RSI per TF, bull/bear agree counts, rv20_norm, atr_z.
- **Stats table** (bottom-right) — N bars and % share per regime across
  the visible history.

UNCERTAIN bars deliberately render no box and no tint (clean chart).

## Settings worth knowing

- **Hysteresis min_run** (5) — bars of consistent raw state before
  commit. Bigger = less flicker, more boundary lag.
- **Pivot left/right** (3) — fractal pivot window. Smaller catches
  more pivots but more noise.
- **Per-TF RSI thresholds** — defaults are 65/35 (M30), 62/38 (H1),
  60/40 (H4), 55/45 (D1), 50/50 (W1). Overridable per pair / TF.
- **RSI agree min** (3) — TFs that must agree to qualify as
  BULL_CALM / BEAR_CALM. Lower = more sensitive.
- **S/R cluster tolerance** (0.3 × ATR) — width of an S/R level zone.
- **S/R max age** (500 bars) — oldest first-touch still eligible for
  double-bounce reversal.
- **Reversal persistence** (10 bars) — how long after the second touch
  the REVERSAL state stays active.
- **Max active S/R levels** (200) — FIFO ceiling on level memory.
- **All six regime colors + reversal arrow colors** — fully overridable.

## Sanity-check expectation (EUR/USD M30, 2 years)

If the v2 baseline distribution holds on your data window:

| State     | Share  |
| --------- | ------ |
| BULL_CALM | ~2.6%  |
| BEAR_CALM | ~1.8%  |
| RANGE     | ~2.4%  |
| CHOPPY    | ~38.7% |
| STRESS    | ~8.4%  |
| UNCERTAIN | ~46.0% |

v2 deliberately has stricter BULL / BEAR (needs trend state + 3-of-5
RSI agreement) and a wider CHOPPY (catches trend bars without RSI
agreement + all active reversals). Cleaner regime blocks, better
direction mapping.

## Honest limitations — please read

- **Tuned to EUR/USD M30 vol scale.** Features and rules are
  TF-agnostic in math, but the thresholds were calibrated on M30.
  On H1 / D1 / crypto / equities the distribution will be approximate
  unless you re-tune.
- **v2 direction mapping is improved but not perfect.** Diagonal
  score = 2 / 5 (vs 1 / 5 in v1.1). BULL_CALM and BEAR_CALM now point
  the right way; RANGE drifts slightly up; CHOPPY and STRESS still
  show counter-intuitive mean-reversion edge. **Treat the indicator
  as a labeled regime overlay for research, not a stand-alone
  trade-direction signal.**
- **Streaming lags exist.** Pivot detection lag ≈ 3 bars,
  hysteresis commit lag ≈ `min_run − 1` bars, multi-TF RSI uses
  `lookahead=barmerge.lookahead_off` so higher-TF RSI updates only on
  higher-TF bar close.
- **S/R level memory capped at 200 (FIFO).** The Python reference
  keeps levels unbounded; on very long charts you may see different
  bounce decisions than the offline version near the cap.

## Alerts

Seven alert conditions ship in:

- Regime → STRESS
- Regime → BULL_CALM
- Regime → BEAR_CALM
- Regime → RANGE
- Regime → CHOPPY
- Double-bounce UP   (support held, second touch)
- Double-bounce DOWN (resistance held, second touch)

Regime alerts fire on transition (state differs from previous bar).
Double-bounce alerts fire at the second-touch bar of any cluster.

## Credits & attribution

- **Visual style** inspired by *FX Market Sessions* by **boitoki**
  (Mozilla Public License 2.0). The segment-box-per-run pattern is
  borrowed from that script; all classifier logic, feature math,
  pivot state machine and S/R clustering is original to SAO · RUBIQ.
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
//        product   ::  SAO · RUBIQ   —   Regime Visualizer  (v2)
//        engine    ::  pivot fractals  +  multi-TF RSI  +  S/R double-bounce
//        build     ::  Pine Script v6     ·     2026-05-26
//        license   ::  same as parent SAO_RUBIQ project
//      ──────────────────────────────────────────────────────────────────────
//
// ════════════════════════════════════════════════════════════════════════════════
//
//   v2 vs v1.1 (EUR/USD M30, 2024-2025 baseline, 24,863 bars):
//
//     coverage         44.87%  →  53.96%   (+9pp)
//     transitions       1 567  →     855   (cleaner regime blocks)
//     bull Sharpe       +0.085 →  +0.271   (3.2× higher)
//     bear direction    +0.04  ⚠ →  -0.19  ✅ (fixed — diagonal 1/5 → 2/5)
//     shuffle F (h=5)   0.0027 →  0.0068   (2.5× more separable; p<0.001)
//
//   Engine: NO AND-stack of ADX / BB-width / drift. Instead:
//     1. Fractal pivots (3-bar centered) → HH / LH / HL / LL labels
//     2. Trend state machine: UP / DOWN / RANGE / REVERSAL_UP / REVERSAL_DOWN
//     3. Multi-TF RSI (M30/H1/H4/D1/W1) with TF-specific thresholds
//     4. S/R level clustering (±0.3 ATR tolerance) + double-bounce reversal flag
//        with 10-bar persistence
//     5. Stress = rv20_norm > 2  OR  atr_z > 2  (simpler than v1)
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
//   Source of truth (Python, local):
//     ~/SAO_RUBIQ/rubiq/regime/v2_classifier.py   (orchestrator)
//     ~/SAO_RUBIQ/rubiq/regime/pivots.py          (fractal pivot detection + HH/LH/HL/LL)
//     ~/SAO_RUBIQ/rubiq/regime/rsi_multi_tf.py    (per-TF RSI + agree counts)
//     ~/SAO_RUBIQ/rubiq/regime/sr_tracker.py      (level clustering + bounces)
//     ~/SAO_RUBIQ/rubiq/regime/trend_tracker.py   (state machine + re-anchoring)
//
//   Visual style preserved from v1 — boitoki/FX Market Sessions segment-box-per-run.
//
//   Streaming-vs-offline lags (real-time approximations of offline pandas):
//     - Pivot detection lag    : `pivot_window` bars (default 3)
//     - Hysteresis commit lag  : `min_run - 1` bars (default 5)
//     - Reversal persistence   : 10 bars from second bounce
//
// ════════════════════════════════════════════════════════════════════════════════

//@version=6
indicator('SAO RUBIQ Regime v2', 'RUBIQ v2', overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=500,
     explicit_plot_zorder=true)

// ────────────────────────────────────────────────────────────────────────────
// GROUPS
// ────────────────────────────────────────────────────────────────────────────
g_show    = '// DISPLAY //'
g_rules   = '// RULES //'
g_rsi     = '// MULTI-TF RSI //'
g_sr      = '// S/R + REVERSAL //'
g_colors  = '// COLORS //'
g_table   = '// TABLES //'

// ────────────────────────────────────────────────────────────────────────────
// INPUTS — display
// ────────────────────────────────────────────────────────────────────────────
i_show_bg        = input.bool(true,  'Background tint',     group=g_show)
i_show_boxes     = input.bool(true,  'Segment boxes',       group=g_show)
i_show_barcolor  = input.bool(false, 'Bar color',           group=g_show)
i_show_label     = input.bool(true,  'Segment label',       group=g_show)
i_show_pivots    = input.bool(true,  'Pivot markers (HH/HL/LH/LL)', group=g_show)
i_show_bounces   = input.bool(true,  'Reversal arrows',     group=g_show)
i_show_table     = input.bool(true,  'Info table',          group=g_table)
i_show_stats     = input.bool(true,  'Stats table',         group=g_table)

// ────────────────────────────────────────────────────────────────────────────
// INPUTS — rules
// ────────────────────────────────────────────────────────────────────────────
i_min_run        = input.int(5,   'Hysteresis min_run (bars)', minval=1, group=g_rules)
i_median_lb      = input.int(500, 'Norm median lookback',      minval=100, group=g_rules)
i_pivot_window   = input.int(3,   'Pivot left/right (bars)',   minval=1, group=g_rules)
i_max_levels     = input.int(200, 'Max active S/R levels',     minval=20, maxval=500, group=g_rules)

// ────────────────────────────────────────────────────────────────────────────
// INPUTS — multi-TF RSI (per-TF thresholds, Python-matched defaults)
// ────────────────────────────────────────────────────────────────────────────
i_rsi_len        = input.int(14, 'RSI length',        minval=2, group=g_rsi)
i_rsi_agree_min  = input.int(3,  'TFs that must agree (>=)', minval=1, maxval=5, group=g_rsi)
i_th_m30_bull    = input.int(65, 'M30 bull threshold', group=g_rsi)
i_th_m30_bear    = input.int(35, 'M30 bear threshold', group=g_rsi)
i_th_h1_bull     = input.int(62, 'H1 bull threshold',  group=g_rsi)
i_th_h1_bear     = input.int(38, 'H1 bear threshold',  group=g_rsi)
i_th_h4_bull     = input.int(60, 'H4 bull threshold',  group=g_rsi)
i_th_h4_bear     = input.int(40, 'H4 bear threshold',  group=g_rsi)
i_th_d1_bull     = input.int(55, 'D1 bull threshold',  group=g_rsi)
i_th_d1_bear     = input.int(45, 'D1 bear threshold',  group=g_rsi)
i_th_w1_bull     = input.int(50, 'W1 bull threshold',  group=g_rsi)
i_th_w1_bear     = input.int(50, 'W1 bear threshold',  group=g_rsi)

// ────────────────────────────────────────────────────────────────────────────
// INPUTS — S/R + reversal
// ────────────────────────────────────────────────────────────────────────────
i_sr_tol_atr     = input.float(0.3,  'S/R cluster tolerance (× ATR)', minval=0.05, step=0.05, group=g_sr)
i_sr_max_age     = input.int  (500,  'S/R double-bounce max age (bars)', minval=10, group=g_sr)
i_reversal_hold  = input.int  (10,   'Reversal persistence (bars)', minval=1, group=g_sr)
i_stress_rv      = input.float(2.0,  'Stress: rv20_norm threshold', minval=1.0, step=0.1, group=g_sr)
i_stress_atrz    = input.float(2.0,  'Stress: atr_z threshold',     minval=1.0, step=0.1, group=g_sr)

// ────────────────────────────────────────────────────────────────────────────
// INPUTS — colors
// ────────────────────────────────────────────────────────────────────────────
c_bull           = input.color(#26A69A, 'BULL_CALM', group=g_colors)
c_bear           = input.color(#EF5350, 'BEAR_CALM', group=g_colors)
c_range          = input.color(#5C6BC0, 'RANGE',     group=g_colors)
c_choppy         = input.color(#FF9800, 'CHOPPY',    group=g_colors)
c_stress         = input.color(#D81B60, 'STRESS',    group=g_colors)
c_uncertain      = input.color(color.new(#888888, 70), 'UNCERTAIN', group=g_colors)
c_rev_up         = input.color(#00E676, 'Reversal UP arrow',   group=g_colors)
c_rev_down       = input.color(#FF1744, 'Reversal DOWN arrow', group=g_colors)
bg_transp        = input.int(88, 'Background transparency', minval=50, maxval=100, group=g_colors)
box_transp       = input.int(92, 'Box bg transparency',     minval=50, maxval=100, group=g_colors)

// ════════════════════════════════════════════════════════════════════════════
// FEATURES — only what v2 needs (ATR, RV20_norm, ATR_z)
// ════════════════════════════════════════════════════════════════════════════
atr14   = ta.atr(14)
log_ret = math.log(close / close[1])
rv20    = ta.stdev(log_ret, 20) * math.sqrt(20)

rv_med  = ta.percentile_linear_interpolation(rv20,  i_median_lb, 50)
atr_med = ta.percentile_linear_interpolation(atr14, i_median_lb, 50)
atr_std = ta.stdev(atr14, i_median_lb)

rv20_norm = rv_med  != 0 ? rv20 / rv_med               : na
atr_z     = atr_std != 0 ? (atr14 - atr_med) / atr_std : na

// ════════════════════════════════════════════════════════════════════════════
// MULTI-TF RSI — request per TF, count agreements per side
// ════════════════════════════════════════════════════════════════════════════
get_rsi(simple string tf) =>
    request.security(syminfo.tickerid, tf, ta.rsi(close, i_rsi_len), lookahead=barmerge.lookahead_off)

rsi_m30 = get_rsi("30")
rsi_h1  = get_rsi("60")
rsi_h4  = get_rsi("240")
rsi_d1  = get_rsi("1D")
rsi_w1  = get_rsi("1W")

bull_m30 = nz(rsi_m30) > i_th_m30_bull ? 1 : 0
bull_h1  = nz(rsi_h1)  > i_th_h1_bull  ? 1 : 0
bull_h4  = nz(rsi_h4)  > i_th_h4_bull  ? 1 : 0
bull_d1  = nz(rsi_d1)  > i_th_d1_bull  ? 1 : 0
bull_w1  = nz(rsi_w1)  > i_th_w1_bull  ? 1 : 0
bear_m30 = nz(rsi_m30, 50) < i_th_m30_bear ? 1 : 0
bear_h1  = nz(rsi_h1,  50) < i_th_h1_bear  ? 1 : 0
bear_h4  = nz(rsi_h4,  50) < i_th_h4_bear  ? 1 : 0
bear_d1  = nz(rsi_d1,  50) < i_th_d1_bear  ? 1 : 0
bear_w1  = nz(rsi_w1,  50) < i_th_w1_bear  ? 1 : 0

rsi_bull_agree = bull_m30 + bull_h1 + bull_h4 + bull_d1 + bull_w1
rsi_bear_agree = bear_m30 + bear_h1 + bear_h4 + bear_d1 + bear_w1

bull_rsi = rsi_bull_agree >= i_rsi_agree_min
bear_rsi = rsi_bear_agree >= i_rsi_agree_min

// ════════════════════════════════════════════════════════════════════════════
// PIVOT DETECTION — fractal n-bar centered, confirmed at +n lag
// ════════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(i_pivot_window, i_pivot_window)
pl = ta.pivotlow (i_pivot_window, i_pivot_window)

// piv bar = bar_index - right_bars (i.e. where the pivot actually sits)
pivot_bar = bar_index - i_pivot_window

// ════════════════════════════════════════════════════════════════════════════
// PIVOT STATE — last labels + chain anchors for trend re-anchoring
// ════════════════════════════════════════════════════════════════════════════
var float  last_h_price = na
var float  last_l_price = na
var string last_h_label = na   // 'H0' | 'HH' | 'LH'
var string last_l_label = na   // 'L0' | 'HL' | 'LL'
var int    chain_up_start   = na
var int    chain_down_start = na

// ════════════════════════════════════════════════════════════════════════════
// S/R LEVEL STORAGE — greedy clustering at ±tol × ATR
// ════════════════════════════════════════════════════════════════════════════
var array<float>  lv_price     = array.new<float>()
var array<int>    lv_touches   = array.new<int>()
var array<int>    lv_first_bar = array.new<int>()
var array<int>    lv_last_bar  = array.new<int>()

// ════════════════════════════════════════════════════════════════════════════
// REVERSAL STATE — set on second touch, persists for `reversal_hold` bars
// ════════════════════════════════════════════════════════════════════════════
var string reversal_active    = ''
var int    reversal_remaining = 0

// ════════════════════════════════════════════════════════════════════════════
// TREND STATE MACHINE
// ════════════════════════════════════════════════════════════════════════════
var string current_trend          = 'UNKNOWN'
var int    current_trend_anchor   = na
var int    current_trend_start    = na

// ════════════════════════════════════════════════════════════════════════════
// HELPER — try to add pivot price to S/R levels, return new touch count
//   Mutates the four lv_* arrays. Returns int touch count after this pivot.
// ════════════════════════════════════════════════════════════════════════════
add_to_levels(array<float> arr_p, array<int> arr_t, array<int> arr_f, array<int> arr_l,
              float price, int piv_bar, float tol) =>
    int matched   = -1
    float best_d  = 1.0e20
    int n_lv      = array.size(arr_p)
    if tol > 0 and not na(price) and n_lv > 0
        for i = 0 to n_lv - 1
            float d = math.abs(array.get(arr_p, i) - price)
            if d <= tol and d < best_d
                matched := i
                best_d  := d
    int new_touches = 1
    if matched >= 0
        new_touches := array.get(arr_t, matched) + 1
        array.set(arr_t, matched, new_touches)
        array.set(arr_l, matched, piv_bar)
    else
        // cap: drop oldest level when full
        if n_lv >= i_max_levels
            array.shift(arr_p)
            array.shift(arr_t)
            array.shift(arr_f)
            array.shift(arr_l)
        array.push(arr_p, price)
        array.push(arr_t, 1)
        array.push(arr_f, piv_bar)
        array.push(arr_l, piv_bar)
        matched := array.size(arr_p) - 1
    [matched, new_touches]

// ════════════════════════════════════════════════════════════════════════════
// PIVOT PROCESSING — at script level so we can mutate scalar globals
// ════════════════════════════════════════════════════════════════════════════
sr_tol = nz(atr14) * i_sr_tol_atr

// Bounce reveal flags for current bar (used by render below)
bool   new_bounce       = false
string new_bounce_dir   = ''
float  new_bounce_price = na

// — process pivot HIGH
if not na(ph)
    // 1. label vs previous H
    string lbl_h = na(last_h_price) ? 'H0' : (ph > last_h_price ? 'HH' : 'LH')
    last_h_label := lbl_h
    last_h_price := ph
    // 2. update chains
    if lbl_h == 'HH'
        if na(chain_up_start)
            chain_up_start := pivot_bar
        chain_down_start := na
    else if lbl_h == 'LH'
        chain_up_start := na
        if na(chain_down_start)
            chain_down_start := pivot_bar
    // 3. add to S/R levels and check for double bounce
    [matched_idx, new_touches] = add_to_levels(lv_price, lv_touches, lv_first_bar, lv_last_bar, ph, pivot_bar, sr_tol)
    if new_touches >= 2 and matched_idx >= 0
        int first_bar = array.get(lv_first_bar, matched_idx)
        if pivot_bar - first_bar <= i_sr_max_age
            reversal_active    := 'REVERSAL_DOWN'
            reversal_remaining := i_reversal_hold
            current_trend_anchor := pivot_bar
            current_trend_start  := bar_index
            new_bounce       := true
            new_bounce_dir   := 'REVERSAL_DOWN'
            new_bounce_price := ph

// — process pivot LOW
if not na(pl)
    string lbl_l = na(last_l_price) ? 'L0' : (pl < last_l_price ? 'LL' : 'HL')
    last_l_label := lbl_l
    last_l_price := pl
    if lbl_l == 'LL'
        chain_up_start := na
        if na(chain_down_start)
            chain_down_start := pivot_bar
    else if lbl_l == 'HL'
        if na(chain_up_start)
            chain_up_start := pivot_bar
        chain_down_start := na
    [matched_idx_l, new_touches_l] = add_to_levels(lv_price, lv_touches, lv_first_bar, lv_last_bar, pl, pivot_bar, sr_tol)
    if new_touches_l >= 2 and matched_idx_l >= 0
        int first_bar_l = array.get(lv_first_bar, matched_idx_l)
        if pivot_bar - first_bar_l <= i_sr_max_age
            reversal_active    := 'REVERSAL_UP'
            reversal_remaining := i_reversal_hold
            current_trend_anchor := pivot_bar
            current_trend_start  := bar_index
            new_bounce       := true
            new_bounce_dir   := 'REVERSAL_UP'
            new_bounce_price := pl

// ════════════════════════════════════════════════════════════════════════════
// TREND DERIVATION — from latest H + L labels
// ════════════════════════════════════════════════════════════════════════════
pivot_seen_this_bar = (not na(ph)) or (not na(pl))

if pivot_seen_this_bar
    if last_h_label == 'HH' and last_l_label == 'HL'
        if current_trend != 'UP'
            current_trend := 'UP'
            current_trend_anchor := na(chain_up_start) ? pivot_bar : chain_up_start
            current_trend_start  := bar_index
            reversal_active    := ''
            reversal_remaining := 0
    else if last_h_label == 'LH' and last_l_label == 'LL'
        if current_trend != 'DOWN'
            current_trend := 'DOWN'
            current_trend_anchor := na(chain_down_start) ? pivot_bar : chain_down_start
            current_trend_start  := bar_index
            reversal_active    := ''
            reversal_remaining := 0
    else if not na(last_h_label) and not na(last_l_label)
        current_trend := 'RANGE'
        current_trend_anchor := pivot_bar
        current_trend_start  := bar_index

// effective trend (reversal flag overrides)
string effective_trend = current_trend
if reversal_remaining > 0
    effective_trend := reversal_active
    reversal_remaining := reversal_remaining - 1
    if reversal_remaining <= 0
        reversal_active := ''

// ════════════════════════════════════════════════════════════════════════════
// CLASSIFIER v2 — port of v2_classifier.classify_v2
// ════════════════════════════════════════════════════════════════════════════
is_stress_v2 = nz(rv20_norm) > i_stress_rv or nz(atr_z) > i_stress_atrz

is_up   = effective_trend == 'UP'
is_down = effective_trend == 'DOWN'
is_rng  = effective_trend == 'RANGE'
is_ru   = effective_trend == 'REVERSAL_UP'
is_rd   = effective_trend == 'REVERSAL_DOWN'

bull_calm   = is_up   and bull_rsi and not is_stress_v2
bear_calm   = is_down and bear_rsi and not is_stress_v2
bull_no_rsi = is_up   and not bull_rsi and not is_stress_v2
bear_no_rsi = is_down and not bear_rsi and not is_stress_v2
choppy_mask = (bull_no_rsi or bear_no_rsi or is_ru or is_rd) and not is_stress_v2
range_clean = is_rng  and not is_stress_v2 and not choppy_mask

// Python order: range, choppy, bear, bull, stress (last-write-wins → stress highest)
raw_state = is_stress_v2 ? 'STRESS' :
             bull_calm    ? 'BULL_CALM' :
             bear_calm    ? 'BEAR_CALM' :
             choppy_mask  ? 'CHOPPY' :
             range_clean  ? 'RANGE' :
             'UNCERTAIN'

// ════════════════════════════════════════════════════════════════════════════
// HYSTERESIS — streaming approximation (same as v1 Pine port)
// ════════════════════════════════════════════════════════════════════════════
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

// ════════════════════════════════════════════════════════════════════════════
// COLORS
// ════════════════════════════════════════════════════════════════════════════
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

// ════════════════════════════════════════════════════════════════════════════
// RENDER — background + bar color
// ════════════════════════════════════════════════════════════════════════════
bgcolor(i_show_bg      and not is_unc ? color.new(cur_color, bg_transp) : na, title='Regime bg')
barcolor(i_show_barcolor and not is_unc ? cur_color : na,                     title='Regime bar')

// ════════════════════════════════════════════════════════════════════════════
// RENDER — segment boxes (FX Sessions style)
// ════════════════════════════════════════════════════════════════════════════
var box   cur_box     = na
var label cur_label   = na
var float seg_top     = na
var float seg_bottom  = na
var int   seg_start   = na

state_changed = committed_state != committed_state[1]

if state_changed
    if not na(cur_box)
        box.set_right(cur_box, bar_index - 1)
    if not na(cur_label) and not na(seg_start)
        label.set_x(cur_label, math.round((seg_start + bar_index - 1) / 2.0))
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

// ════════════════════════════════════════════════════════════════════════════
// RENDER — pivot markers (HH/HL/LH/LL)
// ════════════════════════════════════════════════════════════════════════════
if i_show_pivots and not na(ph)
    color c_h = last_h_label == 'HH' ? color.new(c_bull, 0) : color.new(c_bear, 0)
    label.new(pivot_bar, ph, last_h_label,
                xloc=xloc.bar_index, yloc=yloc.price,
                style=label.style_label_down,
                color=color.new(c_h, 80),
                textcolor=color.white,
                size=size.tiny)

if i_show_pivots and not na(pl)
    color c_l = last_l_label == 'LL' ? color.new(c_bear, 0) : color.new(c_bull, 0)
    label.new(pivot_bar, pl, last_l_label,
                xloc=xloc.bar_index, yloc=yloc.price,
                style=label.style_label_up,
                color=color.new(c_l, 80),
                textcolor=color.white,
                size=size.tiny)

// ════════════════════════════════════════════════════════════════════════════
// RENDER — reversal arrows
// ════════════════════════════════════════════════════════════════════════════
if i_show_bounces and new_bounce
    color c_rev = new_bounce_dir == 'REVERSAL_UP' ? c_rev_up : c_rev_down
    label.new(pivot_bar, new_bounce_price,
                new_bounce_dir == 'REVERSAL_UP' ? '▲' : '▼',
                xloc=xloc.bar_index, yloc=yloc.price,
                style=new_bounce_dir == 'REVERSAL_UP' ? label.style_label_up : label.style_label_down,
                color=color.new(c_rev, 30),
                textcolor=color.white,
                size=size.normal)

// ════════════════════════════════════════════════════════════════════════════
// STATS — running per-regime bar counts
// ════════════════════════════════════════════════════════════════════════════
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

// ════════════════════════════════════════════════════════════════════════════
// TABLES
// ════════════════════════════════════════════════════════════════════════════
var color tcol_dim   = color.new(#888888, 30)
var color tcol_white = #e1e2e4
var color tbl_bg     = #1a1c20
var color tbl_frame  = #25272c

// info table — top right
var table tbl_info = na
if i_show_table and barstate.isfirst
    tbl_info := table.new(position.top_right, 2, 14,
                            frame_width=1, frame_color=tbl_frame,
                            border_width=1, border_color=tbl_frame,
                            bgcolor=tbl_bg)

if i_show_table and barstate.islast
    table.cell(tbl_info, 0, 0,  'RUBIQ',                          text_color=tcol_white, bgcolor=tbl_frame, text_size=size.small)
    table.cell(tbl_info, 1, 0,  'v2',                             text_color=color.new(tcol_white, 40), bgcolor=tbl_frame, text_size=size.small)
    table.cell(tbl_info, 0, 1,  'State',     text_color=tcol_dim, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 1,  committed_state,                  text_color=cur_color,  text_size=size.small, text_halign=text.align_right)
    table.cell(tbl_info, 0, 2,  'Trend',     text_color=tcol_dim, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 2,  effective_trend,                  text_color=tcol_white, text_size=size.tiny,  text_halign=text.align_right)
    table.cell(tbl_info, 0, 3,  'H label',   text_color=tcol_dim, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 3,  na(last_h_label) ? '—' : last_h_label, text_color=tcol_white, text_size=size.tiny, text_halign=text.align_right)
    table.cell(tbl_info, 0, 4,  'L label',   text_color=tcol_dim, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 4,  na(last_l_label) ? '—' : last_l_label, text_color=tcol_white, text_size=size.tiny, text_halign=text.align_right)
    table.cell(tbl_info, 0, 5,  'RSI M30',   text_color=tcol_dim, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 5,  str.tostring(rsi_m30, '#.#'),     text_color=tcol_white, text_size=size.tiny,  text_halign=text.align_right)
    table.cell(tbl_info, 0, 6,  'RSI H1',    text_color=tcol_dim, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 6,  str.tostring(rsi_h1,  '#.#'),     text_color=tcol_white, text_size=size.tiny,  text_halign=text.align_right)
    table.cell(tbl_info, 0, 7,  'RSI H4',    text_color=tcol_dim, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 7,  str.tostring(rsi_h4,  '#.#'),     text_color=tcol_white, text_size=size.tiny,  text_halign=text.align_right)
    table.cell(tbl_info, 0, 8,  'RSI D1',    text_color=tcol_dim, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 8,  str.tostring(rsi_d1,  '#.#'),     text_color=tcol_white, text_size=size.tiny,  text_halign=text.align_right)
    table.cell(tbl_info, 0, 9,  'RSI W1',    text_color=tcol_dim, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 9,  str.tostring(rsi_w1,  '#.#'),     text_color=tcol_white, text_size=size.tiny,  text_halign=text.align_right)
    table.cell(tbl_info, 0, 10, 'Bull agree',text_color=tcol_dim, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 10, str.tostring(rsi_bull_agree)+'/5',text_color=c_bull,     text_size=size.tiny,  text_halign=text.align_right)
    table.cell(tbl_info, 0, 11, 'Bear agree',text_color=tcol_dim, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 11, str.tostring(rsi_bear_agree)+'/5',text_color=c_bear,     text_size=size.tiny,  text_halign=text.align_right)
    table.cell(tbl_info, 0, 12, 'RV20_n',    text_color=tcol_dim, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 12, str.tostring(rv20_norm, '#.##'),  text_color=tcol_white, text_size=size.tiny,  text_halign=text.align_right)
    table.cell(tbl_info, 0, 13, 'ATR_z',     text_color=tcol_dim, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(tbl_info, 1, 13, str.tostring(atr_z, '#.##'),      text_color=tcol_white, text_size=size.tiny,  text_halign=text.align_right)

// stats table — bottom right
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

// ════════════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════════════
alertcondition(committed_state == 'STRESS'    and committed_state[1] != 'STRESS',    'Regime → STRESS',    'RUBIQ v2 regime entered STRESS')
alertcondition(committed_state == 'BULL_CALM' and committed_state[1] != 'BULL_CALM', 'Regime → BULL_CALM', 'RUBIQ v2 regime entered BULL_CALM')
alertcondition(committed_state == 'BEAR_CALM' and committed_state[1] != 'BEAR_CALM', 'Regime → BEAR_CALM', 'RUBIQ v2 regime entered BEAR_CALM')
alertcondition(committed_state == 'RANGE'     and committed_state[1] != 'RANGE',     'Regime → RANGE',     'RUBIQ v2 regime entered RANGE')
alertcondition(committed_state == 'CHOPPY'    and committed_state[1] != 'CHOPPY',    'Regime → CHOPPY',    'RUBIQ v2 regime entered CHOPPY')
alertcondition(new_bounce and new_bounce_dir == 'REVERSAL_UP',   'Double-bounce UP',   'RUBIQ v2 double-bounce UP at support')
alertcondition(new_bounce and new_bounce_dir == 'REVERSAL_DOWN', 'Double-bounce DOWN', 'RUBIQ v2 double-bounce DOWN at resistance')

// ════════════════════════════════════════════════════════════════════════════
// PLOTS (data window only)
// ════════════════════════════════════════════════════════════════════════════
plot(rsi_m30,        'RSI M30',     display=display.data_window, color=color.gray)
plot(rsi_h1,         'RSI H1',      display=display.data_window, color=color.aqua)
plot(rsi_h4,         'RSI H4',      display=display.data_window, color=color.blue)
plot(rsi_d1,         'RSI D1',      display=display.data_window, color=color.purple)
plot(rsi_w1,         'RSI W1',      display=display.data_window, color=color.fuchsia)
plot(rsi_bull_agree, 'Bull agree',  display=display.data_window, color=color.green)
plot(rsi_bear_agree, 'Bear agree',  display=display.data_window, color=color.red)
plot(rv20_norm,      'RV20_norm',   display=display.data_window, color=color.orange)
plot(atr_z,          'ATR_z',       display=display.data_window, color=color.yellow)
````
