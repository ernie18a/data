# Camarilla Levels Intraday @darshakssc

- url: https://www.tradingview.com/script/J1mDPr1s-Camarilla-Levels-Intraday-darshakssc/
- type: indicator
- pine_id: PUB;bfb5a2b8dbed4ec8baa5aa2c1dbacc04
- version: 1.0

## Description

Camarilla Pivot Levels are one of the most reliable intraday support and resistance frameworks used by professional traders worldwide. Unlike traditional pivots, Camarilla levels are derived from the previous day's range and close, giving highly precise price zones for reversals, breakouts, and targets — all calculated before the market opens.

𝗛𝗼𝘄 𝗶𝘁 𝘄𝗼𝗿𝗸𝘀:
This indicator uses the confirmed previous day's High, Low, and Close to calculate eight Camarilla levels (H3 to H6 and L3 to L6) plus Previous Day High, Low, and Close reference lines. Levels are fixed for the entire trading session and update only at the start of each new day.

𝗞𝗲𝘆 𝗟𝗲𝘃𝗲𝗹𝘀 𝗘𝘅𝗽𝗹𝗮𝗶𝗻𝗲𝗱:
- H3 — Sell Reversal zone. Price often rejects here in a downtrend
- H4 — Breakout level. A close above H4 signals strong bullish momentum
- H5 / H6 — Breakout targets 1 and 2 for extended upside moves
- L3 — Buy Reversal zone. Price often bounces here in an uptrend
- L4 — Breakdown level. A close below L4 signals strong bearish momentum
- L5 / L6 — Breakdown targets 1 and 2 for extended downside moves
- PDH / PDL / PDC — Previous Day High, Low, and Close for context

𝗙𝗲𝗮𝘁𝘂𝗿𝗲𝘀:
- Non-repainting — all levels based on confirmed previous day data
- Same values on all timeframes (5m, 15m, 1H, Daily — identical levels)
- Timeframe-aware line length — adapts automatically to your chart timeframe
- Clean dashboard showing all levels and current LTP at a glance
- Fully customisable colors for buy, sell, and target zones
- Toggle each level group independently (Reversal, Breakout, Targets, PDH/PDL/PDC)
- 4 built-in alert conditions for Breakout, Breakdown, and Reversal zones
- Coded in Pine Script v6

𝗛𝗼𝘄 𝘁𝗼 𝘁𝗿𝗮𝗱𝗲 𝘄𝗶𝘁𝗵 𝗶𝘁:
Reversal trades: Look for rejection candles at H3 (short) or L3 (long) with confirmation
Breakout trades: Wait for a candle close above H4 (long) or below L4 (short), then target H5/H6 or L5/L6
Reference: Use PDH and PDL as additional confluence zones

𝗧𝗶𝗺𝗲𝗳𝗿𝗮𝗺𝗲𝘀: Best on 5m / 15m / 1H for intraday. Works on all timeframes.
𝗜𝗻𝘀𝘁𝗿𝘂𝗺𝗲𝗻𝘁𝘀: Indices, Stocks, Futures, Forex, Crypto

⚠ This indicator is for educational and analytical purposes only.
It does not constitute financial advice. Always apply your own risk management.

by @darshakssc

## Source Code

````pine
// ════════════════════════════════════════════════════════════════
//  CAMARILLA LEVELS  —  Clean Intraday Setup
//  Pine Script v6 | TradingView Compliant
//  by @darshakssc
//
//  H3 = Sell Reversal   | L3 = Buy Reversal
//  H4 = Breakout        | L4 = Breakdown
//  H5 = Breakout T1     | L5 = Breakdown T1
//  H6 = Breakout T2     | L6 = Breakdown T2
//  PDH / PDL / PDC      = Previous Day High / Low / Close
//  Values same on ALL timeframes (Daily-based)
// ════════════════════════════════════════════════════════════════

//@version=6
indicator("Camarilla Levels — Intraday",
          shorttitle       = "Cam Levels",
          overlay          = true,
          max_lines_count  = 50,
          max_labels_count = 50)

// ─────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────
G1 = "Levels"
G2 = "Previous Day"
G3 = "Display"

i_show_rev  = input.bool(true,  "Show Buy / Sell Reversal (H3 / L3)", group=G1)
i_show_brk  = input.bool(true,  "Show Breakout / Breakdown (H4 / L4)", group=G1)
i_show_tgt  = input.bool(true,  "Show Targets (H5 H6 / L5 L6)",       group=G1)
i_show_pdhl = input.bool(true,  "Show PDH / PDL / PDC",               group=G2)
i_show_lbl  = input.bool(true,  "Show Labels",                         group=G3)
i_show_dash = input.bool(true,  "Show Dashboard",                      group=G3)

i_col_sell  = input.color(#EF5350, "Sell / Breakdown Color", group=G3)
i_col_buy   = input.color(#26A69A, "Buy / Breakout Color",   group=G3)
i_col_tgt   = input.color(#FF9800, "Target Color",           group=G3)
i_col_pd    = input.color(#FF9800, "Prev Day Color",         group=G3)

// ─────────────────────────────────────────────────────
//  DAILY-BASED DATA  (same values on ALL timeframes)
// ─────────────────────────────────────────────────────
[d_h, d_l, d_c] = request.security(syminfo.tickerid, "D",
     [high[1], low[1], close[1]],
     lookahead = barmerge.lookahead_on)

// ─────────────────────────────────────────────────────
//  CAMARILLA FORMULA
// ─────────────────────────────────────────────────────
float rng = d_h - d_l

float H3 = d_c + rng * 1.1 / 4.0
float H4 = d_c + rng * 1.1 / 2.0
float H5 = H4 + 1.168 * (H4 - H3)
float H6 = d_h / d_l * d_c

float L3 = d_c - rng * 1.1 / 4.0
float L4 = d_c - rng * 1.1 / 2.0
float L5 = L4 - 1.168 * (L3 - L4)
float L6 = d_c - (H6 - d_c)

// ─────────────────────────────────────────────────────
//  HELPERS  (global scope — no nesting)
// ─────────────────────────────────────────────────────
f_s(float v) =>
    str.tostring(math.round(v))

// ─────────────────────────────────────────────────────
//  MANAGED DRAWING ARRAYS
// ─────────────────────────────────────────────────────
var line[]  ln_arr = array.new<line>()
var label[] lb_arr = array.new<label>()

// ─────────────────────────────────────────────────────
//  DRAW ALL LEVELS  (barstate.islast)
// ─────────────────────────────────────────────────────
if barstate.islast
    // clear old drawings
    for _l in ln_arr
        line.delete(_l)
    for _l in lb_arr
        label.delete(_l)
    array.clear(ln_arr)
    array.clear(lb_arr)

    // Timeframe-aware lookback: ~1 trading session worth of bars
    // 5m=75bars, 15m=25bars, 30m=13bars, 1H=6bars, Daily/Weekly=3bars
    int lbk = timeframe.isintraday ?
         math.min(bar_index, math.round(375 / timeframe.multiplier)) :
         math.min(bar_index, 3)
    int fwd = 12

    // ── SELL REVERSAL  H3 ────────────────────────────
    if i_show_rev
        array.push(ln_arr, line.new(
             bar_index - lbk, H3, bar_index + fwd, H3,
             color=color.new(i_col_sell, 20), width=2, style=line.style_solid))
        if i_show_lbl
            array.push(lb_arr, label.new(
                 bar_index + fwd, H3,
                 "Sell Reversal  •  " + f_s(H3),
                 style=label.style_label_left, size=size.small,
                 color=color.new(i_col_sell, 25), textcolor=color.white))

    // ── BUY REVERSAL  L3 ─────────────────────────────
    if i_show_rev
        array.push(ln_arr, line.new(
             bar_index - lbk, L3, bar_index + fwd, L3,
             color=color.new(i_col_buy, 20), width=2, style=line.style_solid))
        if i_show_lbl
            array.push(lb_arr, label.new(
                 bar_index + fwd, L3,
                 "Buy Reversal  •  " + f_s(L3),
                 style=label.style_label_left, size=size.small,
                 color=color.new(i_col_buy, 25), textcolor=color.white))

    // ── BREAKOUT  H4 ─────────────────────────────────
    if i_show_brk
        array.push(ln_arr, line.new(
             bar_index - lbk, H4, bar_index + fwd, H4,
             color=color.new(i_col_sell, 10), width=2, style=line.style_solid))
        if i_show_lbl
            array.push(lb_arr, label.new(
                 bar_index + fwd, H4,
                 "Breakout  •  " + f_s(H4),
                 style=label.style_label_left, size=size.small,
                 color=color.new(i_col_sell, 15), textcolor=color.white))

    // ── BREAKDOWN  L4 ────────────────────────────────
    if i_show_brk
        array.push(ln_arr, line.new(
             bar_index - lbk, L4, bar_index + fwd, L4,
             color=color.new(i_col_buy, 10), width=2, style=line.style_solid))
        if i_show_lbl
            array.push(lb_arr, label.new(
                 bar_index + fwd, L4,
                 "Breakdown  •  " + f_s(L4),
                 style=label.style_label_left, size=size.small,
                 color=color.new(i_col_buy, 15), textcolor=color.white))

    // ── BREAKOUT TARGETS  H5 H6 ──────────────────────
    if i_show_tgt
        array.push(ln_arr, line.new(
             bar_index - lbk, H5, bar_index + fwd, H5,
             color=color.new(i_col_tgt, 35), width=1, style=line.style_dashed))
        if i_show_lbl
            array.push(lb_arr, label.new(
                 bar_index + fwd, H5,
                 "Target 1  •  " + f_s(H5),
                 style=label.style_label_left, size=size.small,
                 color=color.new(i_col_tgt, 40), textcolor=color.white))

        array.push(ln_arr, line.new(
             bar_index - lbk, H6, bar_index + fwd, H6,
             color=color.new(i_col_tgt, 25), width=1, style=line.style_dashed))
        if i_show_lbl
            array.push(lb_arr, label.new(
                 bar_index + fwd, H6,
                 "Target 2  •  " + f_s(H6),
                 style=label.style_label_left, size=size.small,
                 color=color.new(i_col_tgt, 30), textcolor=color.white))

    // ── BREAKDOWN TARGETS  L5 L6 ─────────────────────
    if i_show_tgt
        array.push(ln_arr, line.new(
             bar_index - lbk, L5, bar_index + fwd, L5,
             color=color.new(i_col_tgt, 35), width=1, style=line.style_dashed))
        if i_show_lbl
            array.push(lb_arr, label.new(
                 bar_index + fwd, L5,
                 "Target 1  •  " + f_s(L5),
                 style=label.style_label_left, size=size.small,
                 color=color.new(i_col_tgt, 40), textcolor=color.white))

        array.push(ln_arr, line.new(
             bar_index - lbk, L6, bar_index + fwd, L6,
             color=color.new(i_col_tgt, 25), width=1, style=line.style_dashed))
        if i_show_lbl
            array.push(lb_arr, label.new(
                 bar_index + fwd, L6,
                 "Target 2  •  " + f_s(L6),
                 style=label.style_label_left, size=size.small,
                 color=color.new(i_col_tgt, 30), textcolor=color.white))

    // ── PDH / PDL / PDC ──────────────────────────────
    if i_show_pdhl
        array.push(ln_arr, line.new(
             bar_index - lbk, d_h, bar_index + fwd, d_h,
             color=color.new(i_col_pd, 15), width=1, style=line.style_dashed))
        if i_show_lbl
            array.push(lb_arr, label.new(
                 bar_index + fwd, d_h, "PDH  •  " + f_s(d_h),
                 style=label.style_label_left, size=size.small,
                 color=color.new(i_col_pd, 25), textcolor=color.white))

        array.push(ln_arr, line.new(
             bar_index - lbk, d_l, bar_index + fwd, d_l,
             color=color.new(i_col_pd, 15), width=1, style=line.style_dashed))
        if i_show_lbl
            array.push(lb_arr, label.new(
                 bar_index + fwd, d_l, "PDL  •  " + f_s(d_l),
                 style=label.style_label_left, size=size.small,
                 color=color.new(i_col_pd, 25), textcolor=color.white))

        array.push(ln_arr, line.new(
             bar_index - lbk, d_c, bar_index + fwd, d_c,
             color=color.new(#90A4AE, 25), width=1, style=line.style_dotted))
        if i_show_lbl
            array.push(lb_arr, label.new(
                 bar_index + fwd, d_c, "PDC  •  " + f_s(d_c),
                 style=label.style_label_left, size=size.small,
                 color=color.new(#546E7A, 30), textcolor=color.white))

// ─────────────────────────────────────────────────────
//  PROXIMITY BACKGROUND
// ─────────────────────────────────────────────────────
float atr14  = ta.atr(14)
float tol    = atr14 * 0.25
bool near_s  = math.abs(close - H3) < tol or math.abs(close - H4) < tol
bool near_b  = math.abs(close - L3) < tol or math.abs(close - L4) < tol

// proximity bgcolor removed — not needed with clear level lines

// ─────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────
var table dash = table.new(position.bottom_right, 2, 10,
     bgcolor      = color.new(#0D0D0D, 10),
     border_color = color.new(#37474F, 50),
     border_width = 1,
     frame_color  = color.new(#FF9800, 50),
     frame_width  = 1)

if i_show_dash and barstate.islast
    table.cell(dash, 0, 0, "CAM",    bgcolor=color.new(#1A1A1A, 5), text_color=#FF9800, text_size=size.normal, text_halign=text.align_center)
    table.cell(dash, 1, 0, "LEVELS", bgcolor=color.new(#1A1A1A, 5), text_color=color.new(#FF9800, 40), text_size=size.normal, text_halign=text.align_center)

    table.cell(dash, 0, 1, "BRK T2", bgcolor=color.new(i_col_tgt, 55), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, f_s(H6),  bgcolor=color.new(i_col_tgt, 68), text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 2, "BRK T1", bgcolor=color.new(i_col_tgt, 45), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, f_s(H5),  bgcolor=color.new(i_col_tgt, 60), text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 3, "BRK ↑",  bgcolor=color.new(i_col_sell, 25), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 3, f_s(H4),  bgcolor=color.new(i_col_sell, 42), text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 4, "SELL R", bgcolor=color.new(i_col_sell, 35), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 4, f_s(H3),  bgcolor=color.new(i_col_sell, 52), text_color=color.white, text_size=size.small)

    color ltp_c = close >= H4 ? i_col_sell : close <= L4 ? i_col_buy : #FFD600
    table.cell(dash, 0, 5, "LTP",      bgcolor=color.new(#263238, 20), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 5, f_s(close), bgcolor=color.new(#263238, 10), text_color=ltp_c, text_size=size.small)

    table.cell(dash, 0, 6, "BUY R", bgcolor=color.new(i_col_buy, 35), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 6, f_s(L3),  bgcolor=color.new(i_col_buy, 52), text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 7, "BRK ↓",  bgcolor=color.new(i_col_buy, 25), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 7, f_s(L4),  bgcolor=color.new(i_col_buy, 42), text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 8, "BDN T1", bgcolor=color.new(i_col_tgt, 45), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 8, f_s(L5),  bgcolor=color.new(i_col_tgt, 60), text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 9, "BDN T2", bgcolor=color.new(i_col_tgt, 55), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 9, f_s(L6),  bgcolor=color.new(i_col_tgt, 68), text_color=color.white, text_size=size.small)

// ─────────────────────────────────────────────────────
//  BRANDING  — Ganesh ji unicode + author
//  TradingView does not support image uploads in scripts.
//  Best TV-compliant alternative: Ganesh unicode symbol
//  🐘 is the closest widely supported symbol.
//  Displayed small, top-center, policy safe.
// ─────────────────────────────────────────────────────
var table brand = table.new(position.top_center, 1, 1)

if barstate.islast
    table.cell(brand, 0, 0, "🐘  by @darshakssc",
         text_color = color.new(#FF9800, 15),
         bgcolor    = color.new(#000000, 100),
         text_size  = size.small)

// ─────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────
alertcondition(ta.crossover(close, H4),  title="Breakout H4",
     message="Camarilla — Breakout above H4. Watch targets H5 and H6.")
alertcondition(ta.crossunder(close, L4), title="Breakdown L4",
     message="Camarilla — Breakdown below L4. Watch targets L5 and L6.")
alertcondition(ta.crossover(close, H3),  title="Sell Reversal H3",
     message="Camarilla — Price reached H3 Sell Reversal zone.")
alertcondition(ta.crossunder(close, L3), title="Buy Reversal L3",
     message="Camarilla — Price reached L3 Buy Reversal zone.")
````
