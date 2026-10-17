# HTF/LTF Alignment ("Trend Is your Friend, Until the end!")

- url: https://www.tradingview.com/script/q4qutfwL-HTF-LTF-Alignment-Trend-Is-your-Friend-Until-the-end/
- type: indicator
- pine_id: PUB;b438d645b5e646f2b8880875fe6a3878
- version: 1.0

## Description

HTF/LTF Alignment Dashboard
A clean multi-timeframe bias dashboard built around the 9 and 13 EMA. Tracks 9/13 EMA direction across three user-defined timeframes simultaneously and shows whether they're aligned at a glance — without making you flip charts.
What it does
Reads the 9 EMA (blue) and 13 EMA (grey) on three independently selectable timeframes (defaults: 1H / 15m / 5m) and prints the result as a compact dashboard on your chart. Each timeframe is color-coded — green when 9 EMA is above 13 EMA (bullish), red when below (bearish). A single alignment indicator at the top of the table reads "HTF/LTF Aligned" with a light blue dot when all three timeframes agree, grey when they don't.
The dashboard works on any chart timeframe. The three TFs in the table are pulled independently of what you're viewing, so you can sit on a 1m execution chart and still read 1H bias.
How to use it
1. Trend continuation — the cleanest setup
When all three TFs are aligned (blue dot lit), you're in a confirmed trending regime where higher and lower timeframes agree. This is the highest-probability environment to take continuation trades — pullbacks to value, breakouts, retests of broken structure. Trend is your friend, until the end. Trade with the alignment, not against it.
2. Possible reversal — read the flip cascade
The order in which timeframes change is the early-warning system. Reversals almost always start small and work outward:

LTF flips first → first crack, often just noise on its own
MTF flips → trend in your execution window has rolled
HTF flips → regime change confirmed

If you're holding a position in a fully-aligned market and the LTF flips against you, that's your cue to tighten stops, scale out, or stop adding. If two TFs have flipped and only the HTF holds, you're in the danger zone — the trend is dying. A full new-direction alignment (all three flip and re-agree) is the cleanest signal that the reversal is real, not a wick.
3. Top-down bias filter
Set TF1 to your bias timeframe, TF2 to your structure timeframe, TF3 to your execution timeframe. Only take longs when all three show BULL. Only take shorts when all three show BEAR. When the alignment dot is grey, the market is in transition — stand down or wait for it to settle.
4. Confluence trigger
Watch for the dot flipping from grey to light blue. That moment marks all three TFs agreeing for the first time and frequently coincides with momentum kicks and continuation legs. Pair it with your own entry trigger — structure break, pullback to a key level, breakout retest, or whatever you already use.
5. Don't fight the tide check
If your HTF row is BEAR and you're tempted to long an LTF setup, the dashboard sitting grey is the visual reminder you're trading against the higher tide. Reduce size, skip the trade, or wait for alignment to come to you.
Settings

Three timeframes, fully editable (HTF / MTF / LTF)
Table position: any of four corners or middle sides
Table size: Tiny / Small / Normal / Large
Every color editable — cell backgrounds, text colors, frame, borders, alignment indicator
Optional plot of the 9/13 EMA on the current chart (off by default; 9 = blue, 13 = grey)
"Use confirmed values only" toggle for non-repainting bias (locks each TF until that bar closes)
Three alerts: bullish alignment fired, bearish alignment fired, alignment lost

Notes
Default mode shows live developing bias — values can update intra-bar until each TF's bar closes. Flip on "Use confirmed values only" if you prefer locked, non-repainting values. For best data fidelity, keep your chart timeframe equal to or lower than the lowest TF in your dashboard. Works on any market — futures, FX, equities, crypto.
This is a bias and confluence tool. It won't tell you exactly where to enter or exit on its own — it shows you when the trend stack agrees, when it doesn't, and when it's starting to come apart

## Source Code

````pine
//@version=5
indicator('HTF/LTF Alignment ("Trend Is your Friend, Until the end!")', 'HTF/LTF Alignment ("Trend Is your Friend, Until the end!")', overlay=true)

// ============================== INPUTS ==============================
g_ema = "EMAs"
g_tf  = "Timeframes"
g_tab = "Table"
g_col = "Colors"

ema_fast_len  = input.int(9,  "Fast EMA Length", minval=1, group=g_ema)
ema_slow_len  = input.int(13, "Slow EMA Length", minval=1, group=g_ema)
ema_src       = input.source(close, "EMA Source", group=g_ema)
use_confirmed = input.bool(false, "Use confirmed values only (no repaint)", tooltip="OFF (default): bias updates live as each TF bar develops. ON: each TF bias locks until that TF bar closes - no repaint, but lags by one HTF bar.", group=g_ema)
show_emas     = input.bool(false, "Plot EMAs on chart (current TF only)", group=g_ema)
ema_fast_col  = input.color(#5DADE2, "Fast EMA color (9)", group=g_ema)
ema_slow_col  = input.color(color.gray, "Slow EMA color (13)", group=g_ema)

tf_higher = input.timeframe("60", "Higher TF (TF1)", group=g_tf)
tf_middle = input.timeframe("15", "Middle TF (TF2)", group=g_tf)
tf_lower  = input.timeframe("5",  "Lower TF (TF3)",  group=g_tf)

pos_in  = input.string("Top Right", "Position", options=["Top Left","Top Right","Bottom Left","Bottom Right","Middle Left","Middle Right"], group=g_tab)
size_in = input.string("Small", "Size", options=["Tiny","Small","Normal","Large"], group=g_tab)

bull_bg       = input.color(color.new(color.green, 15), "Bullish bg", group=g_col)
bear_bg       = input.color(color.new(color.red, 15), "Bearish bg", group=g_col)
header_bg     = input.color(color.new(color.gray, 70), "Header bg", group=g_col)
frame_col     = input.color(color.new(color.gray, 50), "Table frame", group=g_col)
border_col    = input.color(color.new(color.gray, 60), "Cell borders", group=g_col)
text_col      = input.color(color.white, "TF label text", group=g_col)
bias_text_col = input.color(color.white, "BULL / BEAR text", group=g_col)
align_col     = input.color(#5DADE2, "Aligned (text + dot)", group=g_col)
no_align_col  = input.color(color.gray, "Not aligned (text + dot)", group=g_col)

// ============================== HELPERS ==============================
// Returns: 1 = bull (fast > slow), -1 = bear (fast < slow), 0 = neutral / na
get_bias(tf, src, fast, slow, confirmed) =>
    [f_live, s_live, f_conf, s_conf] = request.security(syminfo.tickerid, tf, [ta.ema(src, fast), ta.ema(src, slow), ta.ema(src, fast)[1], ta.ema(src, slow)[1]], barmerge.gaps_off, barmerge.lookahead_off)
    f = confirmed ? f_conf : f_live
    s = confirmed ? s_conf : s_live
    f > s ? 1 : f < s ? -1 : 0

fmt_tf(tf) =>
    m = str.tonumber(tf)
    string res = ""
    if na(m)
        res := tf
    else if m >= 1440 and m % 1440 == 0
        res := str.tostring(int(m / 1440)) + "D"
    else if m >= 60 and m % 60 == 0
        res := str.tostring(int(m / 60)) + "H"
    else
        res := str.tostring(int(m)) + "m"
    res

bias_text(b) => b == 1 ? "BULL" : b == -1 ? "BEAR" : "-"
bias_bg(b, bull_c, bear_c) => b == 1 ? bull_c : b == -1 ? bear_c : color.new(color.gray, 50)

// ============================== COMPUTE BIAS ==============================
bias_h = get_bias(tf_higher, ema_src, ema_fast_len, ema_slow_len, use_confirmed)
bias_m = get_bias(tf_middle, ema_src, ema_fast_len, ema_slow_len, use_confirmed)
bias_l = get_bias(tf_lower,  ema_src, ema_fast_len, ema_slow_len, use_confirmed)

aligned = bias_h != 0 and bias_h == bias_m and bias_m == bias_l

// ============================== OPTIONAL EMA PLOTS ==============================
ema_fast_plot = ta.ema(ema_src, ema_fast_len)
ema_slow_plot = ta.ema(ema_src, ema_slow_len)
plot(show_emas ? ema_fast_plot : na, "Fast EMA", color=ema_fast_col, linewidth=2)
plot(show_emas ? ema_slow_plot : na, "Slow EMA", color=ema_slow_col, linewidth=2)

// ============================== POSITION / SIZE MAP ==============================
table_pos = pos_in == "Top Left" ? position.top_left : pos_in == "Top Right" ? position.top_right : pos_in == "Bottom Left" ? position.bottom_left : pos_in == "Bottom Right" ? position.bottom_right : pos_in == "Middle Left" ? position.middle_left : position.middle_right

table_size = size_in == "Tiny" ? size.tiny : size_in == "Small" ? size.small : size_in == "Normal" ? size.normal : size.large

// ============================== TABLE ==============================
var table dash = table.new(table_pos, 3, 3, border_width=1, frame_color=frame_col, border_color=border_col)

if barstate.islast
    // Row 0 - alignment header (merged across 3 cols)
    align_text  = "●  HTF/LTF Aligned"
    align_color = aligned ? align_col : no_align_col
    table.cell(dash, 0, 0, align_text, text_color=align_color, bgcolor=header_bg, text_size=table_size)
    table.cell(dash, 1, 0, "", text_color=align_color, bgcolor=header_bg, text_size=table_size)
    table.cell(dash, 2, 0, "", text_color=align_color, bgcolor=header_bg, text_size=table_size)
    table.merge_cells(dash, 0, 0, 2, 0)

    // Row 1 - TF labels
    table.cell(dash, 0, 1, fmt_tf(tf_higher), text_color=text_col, bgcolor=header_bg, text_size=table_size)
    table.cell(dash, 1, 1, fmt_tf(tf_middle), text_color=text_col, bgcolor=header_bg, text_size=table_size)
    table.cell(dash, 2, 1, fmt_tf(tf_lower),  text_color=text_col, bgcolor=header_bg, text_size=table_size)

    // Row 2 - Bias (BULL / BEAR)
    table.cell(dash, 0, 2, bias_text(bias_h), text_color=bias_text_col, bgcolor=bias_bg(bias_h, bull_bg, bear_bg), text_size=table_size)
    table.cell(dash, 1, 2, bias_text(bias_m), text_color=bias_text_col, bgcolor=bias_bg(bias_m, bull_bg, bear_bg), text_size=table_size)
    table.cell(dash, 2, 2, bias_text(bias_l), text_color=bias_text_col, bgcolor=bias_bg(bias_l, bull_bg, bear_bg), text_size=table_size)

// ============================== ALERTS ==============================
bull_align_now = aligned and bias_h ==  1
bear_align_now = aligned and bias_h == -1
alertcondition(bull_align_now and not bull_align_now[1], "Bullish Alignment", "All 3 TFs aligned BULLISH (9 > 13 EMA)")
alertcondition(bear_align_now and not bear_align_now[1], "Bearish Alignment", "All 3 TFs aligned BEARISH (9 < 13 EMA)")
alertcondition(not aligned and aligned[1],               "Alignment Lost",    "Multi-TF EMA alignment lost")
````
