# GB Session & Liquidity Tool

- url: https://www.tradingview.com/script/hYqUzbIN/
- type: indicator
- pine_id: PUB;2f05ca1783254fd6b3a08fbaa777d9f0
- version: 2.0

## Description

Session & Liquidity Tool — Asian Range + London KZ + NY Midnight Open

A clean, fully configurable session tool built for traders who use liquidity-based 
strategies (ICT, SMC, PO3). No clutter — just the three key references you need 
before every trading session.

──────────────────────────────────────────
WHAT IT DOES
──────────────────────────────────────────

▸ ASIAN RANGE
Draws the Asian session as a box that builds in real-time as the session progresses.
Displays the pip range inside the box so you instantly know if Asia was tight or 
expansive — a critical filter before entering any London setup.

Includes Standard Deviation levels (±1 SD by default, fully configurable) shown as 
dashed lines spanning the session. These let you quickly assess whether London's 
move is within normal manipulation range (≤1 SD) or an extended continuation 
(>2 SD) — directly influencing whether to fade or follow the move.

Supports multiple sessions in history so you can compare ranges across days.

▸ LONDON KILL ZONE
Marks the start and end of the London Kill Zone with vertical dashed lines. 
This is the primary manipulation window — the zone where institutional sweeps 
and Judas Swings occur before the real move begins.
Configurable history to display multiple past sessions.

▸ NY MIDNIGHT OPEN
Plots a horizontal line at the exact open price of 00:00 NY time for each day.
The Midnight Open is one of the most important daily reference levels in 
liquidity-based trading — price trading above or below it determines daily bias 
and confirms or invalidates setups throughout the session.
Each line is labelled with its date. Configurable history (default: last 5 days).

──────────────────────────────────────────
KEY FEATURES
──────────────────────────────────────────

✦ All sessions fully configurable — timezone, start/end times, colors, history count
✦ Asian Range: background color, border color, border width — all adjustable
✦ SD multiplier configurable (0.1 to 5.0x) — use 1.0 for standard 1 SD, 
  2.0 for 2 SD, etc.
✦ Works on any asset — Forex, Indices, Crypto
✦ Optimized for intraday timeframes (1m to 4H)
✦ Clean object management — no performance issues on historical data

──────────────────────────────────────────
HOW TO USE
──────────────────────────────────────────

1. Add to chart on your execution timeframe (5M recommended)
2. Set your timezone in each section (default: America/New_York)
3. Before London opens — check if Asia was tight (good) or expansive (caution)
4. During London KZ — watch for a sweep of the Asian High or Low
5. Use the SD lines to gauge extension: ≤1 SD = normal manipulation, 
   proceed with setup / >2 SD with body close = likely continuation, don't fade
6. Use the Midnight Open as daily bias filter throughout the session

──────────────────────────────────────────
BEST FOR
──────────────────────────────────────────

ICT / SMC traders · PO3 (Power of 3) · Asia Sweep setups · 
London Kill Zone entries · Liquidity-based intraday strategies

──────────────────────────────────────────
SETTINGS
──────────────────────────────────────────

Asian Range     → Show / Timezone / Start / End / History / Background / 
                  Border color & width / SD on-off / SD multiplier / SD color & width
London Kill Zone → Show / Timezone / Start / End / Color / Width / History
NY Midnight Open → Show / Timezone / Color / History (days)

## Source Code

````pine
//@version=6
indicator("Session & Liquidity Tool", overlay=true, max_lines_count=500, max_labels_count=200, max_boxes_count=100)

// ════════════════════════════════════════════════════════════
//  INPUTS — Asian Range
// ════════════════════════════════════════════════════════════
asia_show    = input.bool(true,                 "Show",                group="Asian Range")
asia_tz      = input.string("America/New_York", "Timezone",            group="Asian Range")
asia_start   = input.string("20:00",            "Start (HH:MM)",       group="Asian Range")
asia_end     = input.string("04:00",            "End   (HH:MM)",       group="Asian Range")
asia_history = input.int(3, "History (caixas)", minval=1, maxval=10,   group="Asian Range")
asia_bgcolor = input.color(color.new(color.orange, 85), "Fundo",       group="Asian Range")
asia_brd_col = input.color(color.black,         "Borda — Cor",         group="Asian Range")
asia_brd_w   = input.int(1, "Borda — Espessura", minval=1, maxval=4,   group="Asian Range")
asia_sd_show = input.bool(true,                 "Mostrar SD",          group="Asian Range")
asia_sd_mult = input.float(1.0, "SD Multiplicador", minval=0.1, maxval=5.0, step=0.1, group="Asian Range")
asia_sd_col  = input.color(color.orange,        "SD — Cor",            group="Asian Range")
asia_sd_w    = input.int(1, "SD — Espessura", minval=1, maxval=4,      group="Asian Range")

// ════════════════════════════════════════════════════════════
//  INPUTS — London Kill Zone
// ════════════════════════════════════════════════════════════
lkz_show    = input.bool(true,                 "Show",                group="London Kill Zone")
lkz_tz      = input.string("America/New_York", "Timezone",            group="London Kill Zone")
lkz_start   = input.string("02:00",            "Start (HH:MM)",       group="London Kill Zone")
lkz_end     = input.string("05:00",            "End   (HH:MM)",       group="London Kill Zone")
lkz_col     = input.color(color.gray,          "Color",               group="London Kill Zone")
lkz_width   = input.int(1, "Width", minval=1, maxval=4,               group="London Kill Zone")
lkz_history = input.int(3, "History (sessões)", minval=1, maxval=10,  group="London Kill Zone")

// ════════════════════════════════════════════════════════════
//  INPUTS — NY Midnight Open
// ════════════════════════════════════════════════════════════
ny_show    = input.bool(true,                 "Show",                group="NY Midnight Open")
ny_tz      = input.string("America/New_York", "Timezone",            group="NY Midnight Open")
ny_col     = input.color(color.gray,          "Color",               group="NY Midnight Open")
ny_history = input.int(5, "History (dias)",   minval=1, maxval=30,   group="NY Midnight Open")

// ════════════════════════════════════════════════════════════
//  HELPERS
// ════════════════════════════════════════════════════════════
f_hhmm(s) =>
    int(str.tonumber(str.substring(s, 0, 2))) * 60 + int(str.tonumber(str.substring(s, 3, 5)))

f_inRange(bT, sT, eT) =>
    sT < eT ? (bT >= sT and bT < eT) : (bT >= sT or bT < eT)

inAsia = f_inRange(hour(time, asia_tz) * 60 + minute(time, asia_tz), f_hhmm(asia_start), f_hhmm(asia_end))
inLKZ  = f_inRange(hour(time, lkz_tz)  * 60 + minute(time, lkz_tz),  f_hhmm(lkz_start),  f_hhmm(lkz_end))

// ════════════════════════════════════════════════════════════
//  ASIAN RANGE + SD
// ════════════════════════════════════════════════════════════
var float   asia_hi        = na
var float   asia_lo        = na
var bool    asia_on        = false
var box     asia_cur       = na
var line    asia_cur_sd_hi = na
var line    asia_cur_sd_lo = na
var box[]   asia_boxes     = array.new<box>()
var line[]  asia_sd_his    = array.new<line>()
var line[]  asia_sd_los    = array.new<line>()

if asia_show
    // Abertura — sem deletes aqui, pois o asia_cur anterior já está no array
    if inAsia and not asia_on
        asia_on := true
        asia_hi := high
        asia_lo := low
        asia_cur     := box.new(bar_index, high, bar_index + 1, low, border_color=asia_brd_col, bgcolor=asia_bgcolor, border_width=asia_brd_w)
        if asia_sd_show
            sd_r = high - low
            asia_cur_sd_hi := line.new(bar_index, high + sd_r * asia_sd_mult, bar_index + 1, high + sd_r * asia_sd_mult, color=asia_sd_col, style=line.style_dashed, width=asia_sd_w)
            asia_cur_sd_lo := line.new(bar_index, low  - sd_r * asia_sd_mult, bar_index + 1, low  - sd_r * asia_sd_mult, color=asia_sd_col, style=line.style_dashed, width=asia_sd_w)

    // Actualiza caixa e SD durante a sessão
    if inAsia and asia_on
        if high > asia_hi
            asia_hi := high
        if low < asia_lo
            asia_lo := low
        sd_r = asia_hi - asia_lo
        box.set_top(asia_cur, asia_hi)
        box.set_bottom(asia_cur, asia_lo)
        box.set_right(asia_cur, bar_index + 1)
        if asia_sd_show and not na(asia_cur_sd_hi)
            line.set_y1(asia_cur_sd_hi, asia_hi + sd_r * asia_sd_mult)
            line.set_y2(asia_cur_sd_hi, asia_hi + sd_r * asia_sd_mult)
            line.set_x2(asia_cur_sd_hi, bar_index + 1)
            line.set_y1(asia_cur_sd_lo, asia_lo - sd_r * asia_sd_mult)
            line.set_y2(asia_cur_sd_lo, asia_lo - sd_r * asia_sd_mult)
            line.set_x2(asia_cur_sd_lo, bar_index + 1)

    // Sessão encerrada — guarda no array e reseta os ponteiros para na
    if not inAsia and asia_on
        asia_on := false
        box.set_right(asia_cur, bar_index)
        array.push(asia_boxes, asia_cur)
        asia_cur := na
        while array.size(asia_boxes) > asia_history
            box.delete(array.shift(asia_boxes))
        if asia_sd_show and not na(asia_cur_sd_hi)
            line.set_x2(asia_cur_sd_hi, bar_index)
            line.set_x2(asia_cur_sd_lo, bar_index)
            array.push(asia_sd_his, asia_cur_sd_hi)
            array.push(asia_sd_los, asia_cur_sd_lo)
            asia_cur_sd_hi := na
            asia_cur_sd_lo := na
            while array.size(asia_sd_his) > asia_history
                line.delete(array.shift(asia_sd_his))
                line.delete(array.shift(asia_sd_los))

// ════════════════════════════════════════════════════════════
//  LONDON KILL ZONE
// ════════════════════════════════════════════════════════════
var line   lkz_cur_s  = na
var line[] lkz_starts = array.new<line>()
var line[] lkz_ends   = array.new<line>()
var bool   lkz_on     = false
var bool   lkz_s_done = false

if lkz_show
    if inLKZ and not lkz_on
        lkz_on     := true
        lkz_s_done := false
    if inLKZ and not lkz_s_done
        lkz_s_done := true
        lkz_cur_s  := line.new(bar_index, high, bar_index, low, extend=extend.both, color=lkz_col, style=line.style_dashed, width=lkz_width)
    if not inLKZ and lkz_on
        lkz_on  := false
        end_ln   = line.new(bar_index, high, bar_index, low, extend=extend.both, color=lkz_col, style=line.style_dashed, width=lkz_width)
        array.push(lkz_starts, lkz_cur_s)
        array.push(lkz_ends,   end_ln)
        lkz_cur_s := na
        while array.size(lkz_starts) > lkz_history
            line.delete(array.shift(lkz_starts))
            line.delete(array.shift(lkz_ends))

// ════════════════════════════════════════════════════════════
//  NY MIDNIGHT OPEN
// ════════════════════════════════════════════════════════════
var line[] ny_lns = array.new<line>()

isMidnight = hour(time, ny_tz) == 0 and minute(time, ny_tz) == 0

if ny_show and isMidnight
    ln = line.new(bar_index, open, bar_index + 1, open, color=ny_col, width=1, extend=extend.right)
    array.push(ny_lns, ln)
    while array.size(ny_lns) > ny_history
        line.delete(array.shift(ny_lns))
````
