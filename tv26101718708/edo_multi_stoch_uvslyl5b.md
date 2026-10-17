# Edo Multi Stoch

- url: https://www.tradingview.com/script/UvslyL5B-Edo-Multi-Stoch/
- type: indicator
- pine_id: PUB;03cc3eda0d9e4a1d8967130d2c0b4a25
- version: 1.0

## Description

Edo Multi Stoch is a four-layer stochastic system that reads market momentum across multiple time horizons simultaneously — from macro structural bias down to fast entry timing — all within a single panel.
Instead of comparing %K against a %D signal line derived from the same calculation, Edo Multi Stoch replaces individual signal lines with a hierarchy of four periods where each slower layer acts as the real context for the faster one. Every cross between layers carries genuine structural meaning because it connects different time horizons, not derivatives of the same input. The system is visually cleaner, structurally more informative, and built around a single principle: understand the context before looking for the signal.

[image]https://www.tradingview.com/x/JYvS9EJO/[/image]

THE FOUR LAYERS
The system uses four stochastic periods with distinct roles. Default values are 89, 50, 14 and 5 — all fully configurable. If any period is changed, panel labels and cross log update automatically.
🔵 K89 — Dark Blue — Macro Context
The slowest and structurally heaviest layer. Defines the background bias of the market. Above 50 = bullish macro. Below 50 = bearish macro. Moves deliberately — when it shifts, it carries real weight. It is the system anchor: all confluence and contradiction in the indicator is measured against K89, not against the 50 midline.
🔷 K50 — Light Blue — Operating Context
The intermediate layer. Represents the operating trend where medium-term price movements develop. When K50 and K89 are aligned in the same zone, the trend is structurally clean. When they diverge, the market is in transition or correction. The cross of K50 over K89 is the single highest-weight event in the entire indicator.
🟠 K14 — Orange — Standard Momentum
The classic stochastic reference used by the majority of technical analysts. Reacts faster than the blues and respects overbought and oversold levels with greater frequency. Drives the background zone coloring on the oscillator panel and is the reference layer for the K14 Zone reading in Current State.
🟡 K5 — Yellow — Fast Momentum
The most reactive layer. Captures immediate momentum and reacts first to any directional shift. Its value is only real when aligned with the upper layers — a bullish K5 against bearish K89 and K50 is noise. A bullish K5 with all layers aligned above is timing in full confluence. K5 is the execution layer: it tells you when fast momentum is moving in the direction the structure has already confirmed.
Color logic: Dark blue + light blue = structural context pair. Orange + yellow = momentum execution pair. Blues high and warm colors crossing upward = directional confluence. Blues low and warm colors pushing upward = structural contradiction — short-term momentum fighting the macro context.

[image]https://www.tradingview.com/x/DDthWSi7/[/image]

THE 5 CROSS PAIRS
Edo Multi Stoch monitors five cross pairs between the four layers, ordered from lowest to highest structural weight. Each cross is recorded in the panel log with timestamp and direction. Bullish crosses mark above the line, bearish crosses below. Shape and size reflect weight.
▲ K5 × K14 — Small triangle
The most frequent cross. Fast momentum crossing the classic reference. Useful as timing confirmation when context is already defined by the upper layers. By itself it is not an actionable signal.
▲▲ K5 × K50 — Medium triangle
Fast momentum crossing the operating structure. Indicates that K5 is aligning or misaligning with the intermediate context. More weight than K5×K14 but still requires macro confirmation.
▲▲▲ K14 × K50 — Large triangle
Standard momentum crossing the operating context. Medium-to-high weight. Signals that classic momentum has changed sides relative to the intermediate structure. Gains relevance when it coincides with key price levels.
◆ K14 × K89 — Medium diamond
Standard momentum crossing the macro anchor. Important structural event. Signals that classic momentum is breaking the background bias — a context shift in the K14 horizon. Watch for this cross when price is approaching a key level.
◆◆ K50 × K89 — Large diamond ◆
The heaviest cross in the system, marked with ◆ in the log. The intermediate structure crossing the macro anchor. The stochastic equivalent of a Golden Cross or Death Cross. Most infrequent and most significant. When it occurs with K14 and K5 already aligned in the same direction, the signal carries full system weight.

[image]https://www.tradingview.com/x/4tYrVn0G/[/image]

INFORMATION PANEL
The panel updates bar by bar and is organized into three sections. Position, size and color mode are all configurable.
📋 Cross Log
Timestamped history of recent crosses showing date, time, cross pair, and direction. Green rows = bullish. Red rows = bearish. The K50×K89 cross is marked ◆ in the CROSS column to make it immediately identifiable. Configurable between 3 and 15 rows. The log is especially useful for reading the sequence of events — a progressive build from K5×K14 through K14×K50 up to K14×K89 tells a story of systematic structural alignment.
📊 Current State
Two real-time readings of overall system alignment.
Macro X/3 counts how many of the three lower layers (K50, K14, K5) are currently above K89:
— 3/3 BULL BIAS (green): Full bullish alignment. Strongest bullish state the system can produce.
— 2/3 BULL BIAS (green): Majority alignment. Meaningful bullish bias, not yet complete.
— 1/3 MIXED (yellow): Transition state. Attention warranted, execution premature.
— 0/3 BEAR BIAS (red): Full bearish alignment. Strongest bearish state the system can produce.
K14 Zone shows the current condition of the classic momentum layer with live numerical value: OVERBOUGHT / OVERSOLD / BULL ZONE / BEAR ZONE.
🔢 Values
Live rounded values for all four layers in their corresponding line colors, each with a ▲ arrow if above 50 or ▼ if below. Read the state of the entire system at a glance without tracking four lines across the panel.


BACKGROUND ZONES
The oscillator panel background activates in two extreme K14 conditions.
🟢 Green background — Oversold zone (default ≤ 20)
Bearish momentum exhaustion. The market is at a structural extreme where bullish opportunities have historically appeared. Not a mechanical buy signal — a condition alert. Its highest value is when the Current State score is simultaneously transitioning upward.
🔴 Red background — Overbought zone (default ≥ 80)
Bullish momentum exhaustion. The market is at a structural extreme where corrections and consolidations have historically begun. Not a mechanical sell signal — a condition alert. Strong trending markets can sustain K14 in overbought territory for extended periods — always read zone context alongside the Macro X/3 score.

HOW TO READ IT
An efficient reading follows three steps.
1 — Current State first
The X/3 Macro score gives you the overall system bias immediately. 3/3 and 0/3 are the clearest and most reliable states — full alignment across all layers. 1/3 and 2/3 signal that something is changing but not yet confirmed.
2 — Read the color pairs
Blues high and warm colors crossing upward = full directional confluence. Blues low and warm colors pushing upward = structural contradiction. This visual read takes two seconds once you know the system.
3 — Check the Cross Log
A recent K50×K89 ◆ cross in the direction of the current price bias adds significant structural weight to the reading. A sequence of progressive crosses building from K5 up toward K50 tells you alignment is developing systematically.
Most actionable states:
— 3/3 BULL BIAS with blues above 50 and warm colors above the blue lines
— 0/3 BEAR BIAS with blues below 50 and warm colors below the blue lines
In ranging markets: when K89 oscillates near 50 without clear direction, faster layer crosses carry reduced reliability. Use K89 position relative to 50 as your primary structural filter until direction is established.

[image]https://www.tradingview.com/x/Fp1Lbc5V/[/image]

CONFIGURATION
— Periods: default 89 / 50 / 14 / 5 — all configurable, labels update automatically
— Smoothing: Smooth %K default 3 — balances sensitivity and visual clarity
— Levels: overbought / oversold thresholds + midline toggle
— Visibility: show or hide each layer independently
— Cross Panel: position (4 corners) / size (Small, Medium) / mode (Dark, Light) / history rows (3–15)

OPEN SOURCE
Edo Multi Stoch is published as a free open source indicator. Full source code is accessible to any TradingView user for study and adaptation. Part of the Edolab Markets free tools ecosystem alongside Edo EMA Core Cross, Edo Sentiment Map, Edo SuperTrend Core and Edo ZigZag Auto Fib SR.

This indicator is a technical analysis tool. It does not constitute financial advice or an investment recommendation. Trading financial markets involves significant risk of capital loss. Past performance does not guarantee future results. Always use proper risk management.

## Source Code

````pine
// ─────────────────────────────────────────────────────────────────
// ███████╗██████╗  ██████╗ ██╗      █████╗ ██████╗
// ██╔════╝██╔══██╗██╔═══██╗██║     ██╔══██╗██╔══██╗
// █████╗  ██║  ██║██║   ██║██║     ███████║██████╔╝
// ██╔══╝  ██║  ██║██║   ██║██║     ██╔══██║██╔══██╗
// ███████╗██████╔╝╚██████╔╝███████╗██║  ██║██████╔╝
// ╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝
// ─────────────────────────────────────────────────────────────────
// ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗███████╗████████╗███████╗
// ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝██╔════╝╚══██╔══╝██╔════╝
// ██╔████╔██║███████║██████╔╝█████╔╝ █████╗     ██║   ███████╗
// ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗ ██╔══╝     ██║   ╚════██║
// ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗███████╗   ██║   ███████║
// ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝
// ─────────────────────────────────────────────────────────────────
// © Edolab Markets

//@version=6
indicator("Edo Multi Stochastic", shorttitle="Edo Multi Stoch", overlay=false, max_labels_count=500)

// ======================================
// EDO MULTI STOCHASTIC
// Edolab Markets — edolab.io
// Structure before signals. Clarity over noise.
// ======================================
// Four-layer stochastic system:
// Period A (89) → Macro context / structural bias
// Period B (50) → Operational trend / intermediate context
// Period C (14) → Standard momentum (classic)
// Period D (5)  → Fast momentum / entry timing
// ======================================


// ──────────────────────────────────────
// INPUTS — PERIODS
// ──────────────────────────────────────
per_a = input.int(89, "Period A (Macro)",        minval=2, maxval=500, group="Periods")
per_b = input.int(50, "Period B (Intermediate)", minval=2, maxval=500, group="Periods")
per_c = input.int(14, "Period C (Classic)",      minval=2, maxval=500, group="Periods")
per_d = input.int( 5, "Period D (Fast)",         minval=2, maxval=500, group="Periods")

// Smoothing
smooth_k = input.int(3, "Smooth %K", minval=1, maxval=10, group="Smoothing")
smooth_d = input.int(3, "Smooth %D", minval=1, maxval=10, group="Smoothing")

// Levels
ob_level = input.int(80, "Overbought Level", minval=50, maxval=95, group="Levels")
os_level = input.int(20, "Oversold Level",   minval=5,  maxval=50, group="Levels")
mid_line  = input.bool(true, "Show Midline (50)", group="Levels")

// Visibility
show_a = input.bool(true, "Show Stoch A", group="Visibility")
show_b = input.bool(true, "Show Stoch B", group="Visibility")
show_c = input.bool(true, "Show Stoch C", group="Visibility")
show_d = input.bool(true, "Show Stoch D", group="Visibility")

// Panel
show_panel = input.bool(true,          "Show Cross Panel",     group="Cross Panel")
panel_pos  = input.string("Top Right", "Panel Position",       options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Cross Panel")
panel_size = input.string("Small",     "Panel Size",           options=["Small","Medium"], group="Cross Panel")
panel_mode = input.string("Dark",      "Panel Mode",           options=["Dark","Light"],   group="Cross Panel")
panel_rows = input.int(5,              "Cross History (rows)", minval=3, maxval=15,        group="Cross Panel")


// ──────────────────────────────────────
// COLORS — LINES
// ──────────────────────────────────────
col_a    = color.rgb(30, 80, 200)    // Dark blue   — Period A (89) macro
col_b    = color.rgb(91, 159, 173)   // Edolab teal — Period B (50) intermediate
col_c    = color.rgb(255, 140, 0)    // Orange      — Period C (14) classic
col_d    = color.rgb(255, 214, 0)    // Yellow      — Period D (5)  fast

col_bull = color.rgb(0, 230, 118)
col_bear = color.rgb(255, 82, 82)
col_ob   = color.new(color.red,   80)
col_os   = color.new(color.green, 80)

// Panel mode colors
is_dark      = panel_mode == "Dark"
p_bg_header  = is_dark ? color.new(color.black, 20)  : color.new(color.gray,  20)
p_bg_cell    = is_dark ? color.new(color.black, 50)  : color.new(color.white, 20)
p_bg_empty   = is_dark ? color.new(color.black, 60)  : color.new(color.gray,  60)
p_bg_sep     = is_dark ? color.new(color.gray,  70)  : color.new(color.gray,  40)
p_txt_header = is_dark ? color.white                  : color.new(color.black,  0)
p_txt_empty  = is_dark ? color.new(color.gray,  40)  : color.new(color.gray,  20)

// Panel text size
p_size = panel_size == "Small" ? size.small : size.normal


// ──────────────────────────────────────
// STOCHASTIC CALCULATION
// ──────────────────────────────────────
ka = ta.sma(ta.stoch(close, high, low, per_a), smooth_k)
kb = ta.sma(ta.stoch(close, high, low, per_b), smooth_k)
kc = ta.sma(ta.stoch(close, high, low, per_c), smooth_k)
kd = ta.sma(ta.stoch(close, high, low, per_d), smooth_k)


// ──────────────────────────────────────
// PLOTS
// ──────────────────────────────────────
plot(show_a ? ka : na, title="K-A (Macro)",        color=col_a, linewidth=2)
plot(show_b ? kb : na, title="K-B (Intermediate)", color=col_b, linewidth=2)
plot(show_c ? kc : na, title="K-C (Classic)",      color=col_c, linewidth=1)
plot(show_d ? kd : na, title="K-D (Fast)",         color=col_d, linewidth=1)

hline(ob_level, "Overbought", color=color.new(color.red,   60), linestyle=hline.style_dashed)
hline(os_level, "Oversold",   color=color.new(color.green, 60), linestyle=hline.style_dashed)
hline(mid_line ? 50 : na, "Midline", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

bgcolor(kc >= ob_level ? col_ob : na, title="OB Zone")
bgcolor(kc <= os_level ? col_os : na, title="OS Zone")


// ──────────────────────────────────────
// CROSS DETECTION
// ──────────────────────────────────────
bull_d_c = ta.crossover(kd, kc)
bear_d_c = ta.crossunder(kd, kc)

bull_d_b = ta.crossover(kd, kb)
bear_d_b = ta.crossunder(kd, kb)

bull_c_b = ta.crossover(kc, kb)
bear_c_b = ta.crossunder(kc, kb)

bull_c_a = ta.crossover(kc, ka)
bear_c_a = ta.crossunder(kc, ka)

bull_b_a = ta.crossover(kb, ka)
bear_b_a = ta.crossunder(kb, ka)


// ──────────────────────────────────────
// VISUAL MARKERS
// ──────────────────────────────────────
plotshape(bull_d_c, title="Bull DxC", location=location.bottom, style=shape.triangleup,   color=col_bull, size=size.tiny)
plotshape(bear_d_c, title="Bear DxC", location=location.top,    style=shape.triangledown, color=col_bear, size=size.tiny)

plotshape(bull_d_b, title="Bull DxB", location=location.bottom, style=shape.triangleup,   color=col_bull, size=size.small)
plotshape(bear_d_b, title="Bear DxB", location=location.top,    style=shape.triangledown, color=col_bear, size=size.small)

plotshape(bull_c_b, title="Bull CxB", location=location.bottom, style=shape.triangleup,   color=col_bull, size=size.normal)
plotshape(bear_c_b, title="Bear CxB", location=location.top,    style=shape.triangledown, color=col_bear, size=size.normal)

plotshape(bull_c_a, title="Bull CxA", location=location.bottom, style=shape.diamond,      color=col_bull, size=size.normal)
plotshape(bear_c_a, title="Bear CxA", location=location.top,    style=shape.diamond,      color=col_bear, size=size.normal)

plotshape(bull_b_a, title="Bull BxA", location=location.bottom, style=shape.diamond,      color=col_bull, size=size.large)
plotshape(bear_b_a, title="Bear BxA", location=location.top,    style=shape.diamond,      color=col_bear, size=size.large)


// ──────────────────────────────────────
// CROSS LOG — ARRAYS
// ──────────────────────────────────────
var string[] log_time  = array.new_string()
var string[] log_cross = array.new_string()
var string[] log_dir   = array.new_string()

f_time() => str.format("{0,date,dd-MM-yyyy HH:mm}", time)

f_log(cross_name, dir) =>
    array.unshift(log_time,  f_time())
    array.unshift(log_cross, cross_name)
    array.unshift(log_dir,   dir)
    if array.size(log_time) > panel_rows
        array.pop(log_time)
        array.pop(log_cross)
        array.pop(log_dir)

lbl_a = str.tostring(per_a)
lbl_b = str.tostring(per_b)
lbl_c = str.tostring(per_c)
lbl_d = str.tostring(per_d)

if bull_d_c
    f_log(lbl_d + " > " + lbl_c, "Bullish")
if bear_d_c
    f_log(lbl_d + " < " + lbl_c, "Bearish")
if bull_d_b
    f_log(lbl_d + " > " + lbl_b, "Bullish")
if bear_d_b
    f_log(lbl_d + " < " + lbl_b, "Bearish")
if bull_c_b
    f_log(lbl_c + " > " + lbl_b, "Bullish")
if bear_c_b
    f_log(lbl_c + " < " + lbl_b, "Bearish")
if bull_c_a
    f_log(lbl_c + " > " + lbl_a, "Bullish")
if bear_c_a
    f_log(lbl_c + " < " + lbl_a, "Bearish")
if bull_b_a
    f_log(lbl_b + " > " + lbl_a + " ◆", "Bullish")
if bear_b_a
    f_log(lbl_b + " < " + lbl_a + " ◆", "Bearish")


// ──────────────────────────────────────
// INFORMATIVE PANEL
// ──────────────────────────────────────
tbl_pos = panel_pos == "Top Right" ? position.top_right : panel_pos == "Top Left" ? position.top_left : panel_pos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table panel = table.new(tbl_pos, 3, 25, border_width=1, border_color=color.new(color.gray, 60))

row_bg(dir)  => dir == "Bullish" ? color.new(col_bull, 75) : color.new(col_bear, 75)
row_txt(dir) => dir == "Bullish" ? col_bull : col_bear

if barstate.islast and show_panel

    // HEADER — LOG
    table.cell(panel, 0, 0, "TIME",  text_color=p_txt_header, bgcolor=p_bg_header, text_size=p_size)
    table.cell(panel, 1, 0, "CROSS", text_color=p_txt_header, bgcolor=p_bg_header, text_size=p_size)
    table.cell(panel, 2, 0, "DIR",   text_color=p_txt_header, bgcolor=p_bg_header, text_size=p_size)

    // LOG ROWS
    int n = array.size(log_time)
    for i = 0 to panel_rows - 1
        int row = i + 1
        if i < n
            string dv = array.get(log_dir,   i)
            string cv = array.get(log_cross, i)
            string tv = array.get(log_time,  i)
            table.cell(panel, 0, row, tv, text_color=row_txt(dv), bgcolor=row_bg(dv), text_size=p_size)
            table.cell(panel, 1, row, cv, text_color=row_txt(dv), bgcolor=row_bg(dv), text_size=p_size)
            table.cell(panel, 2, row, dv, text_color=row_txt(dv), bgcolor=row_bg(dv), text_size=p_size)
        else
            table.cell(panel, 0, row, "—", text_color=p_txt_empty, bgcolor=p_bg_empty, text_size=p_size)
            table.cell(panel, 1, row, "—", text_color=p_txt_empty, bgcolor=p_bg_empty, text_size=p_size)
            table.cell(panel, 2, row, "—", text_color=p_txt_empty, bgcolor=p_bg_empty, text_size=p_size)

    // SEPARATOR
    int sep = panel_rows + 1
    table.cell(panel, 0, sep, "", bgcolor=p_bg_sep)
    table.cell(panel, 1, sep, "", bgcolor=p_bg_sep)
    table.cell(panel, 2, sep, "", bgcolor=p_bg_sep)

    // CURRENT STATE
    int st = sep + 1
    table.cell(panel, 0, st, "CURRENT STATE", text_color=p_txt_header, bgcolor=p_bg_header, text_size=p_size)
    table.merge_cells(panel, 0, st, 2, st)

    int above_a = (kb > ka ? 1 : 0) + (kc > ka ? 1 : 0) + (kd > ka ? 1 : 0)
    string macro_bias = above_a >= 2 ? "BULL BIAS" : above_a == 1 ? "MIXED" : "BEAR BIAS"
    color  macro_col  = above_a >= 2 ? col_bull : above_a == 1 ? color.yellow : col_bear

    table.cell(panel, 0, st+1, "Macro (vs " + lbl_a + ")",   text_color=p_txt_header, bgcolor=p_bg_cell, text_size=p_size)
    table.cell(panel, 1, st+1, macro_bias,                    text_color=macro_col,    bgcolor=p_bg_cell, text_size=p_size)
    table.cell(panel, 2, st+1, str.tostring(above_a) + "/3",  text_color=macro_col,    bgcolor=p_bg_cell, text_size=p_size)

    string zone_txt = kc >= ob_level ? "OVERBOUGHT" : kc <= os_level ? "OVERSOLD" : kc >= 50 ? "BULL ZONE" : "BEAR ZONE"
    color  zone_col = kc >= ob_level ? col_bear : kc <= os_level ? col_bull : kc >= 50 ? col_bull : col_bear

    table.cell(panel, 0, st+2, "K" + lbl_c + " Zone",        text_color=p_txt_header, bgcolor=p_bg_cell, text_size=p_size)
    table.cell(panel, 1, st+2, zone_txt,                      text_color=zone_col,     bgcolor=p_bg_cell, text_size=p_size)
    table.cell(panel, 2, st+2, str.tostring(math.round(kc)),  text_color=zone_col,     bgcolor=p_bg_cell, text_size=p_size)

    // SEPARATOR
    int sep2 = st + 3
    table.cell(panel, 0, sep2, "", bgcolor=p_bg_sep)
    table.cell(panel, 1, sep2, "", bgcolor=p_bg_sep)
    table.cell(panel, 2, sep2, "", bgcolor=p_bg_sep)

    // VALUES
    int vr = sep2 + 1
    table.cell(panel, 0, vr, "VALUES", text_color=p_txt_header, bgcolor=p_bg_header, text_size=p_size)
    table.merge_cells(panel, 0, vr, 2, vr)

    table.cell(panel, 0, vr+1, "K" + lbl_a, text_color=col_a, bgcolor=p_bg_cell, text_size=p_size)
    table.cell(panel, 1, vr+1, str.tostring(math.round(ka)),   text_color=col_a, bgcolor=p_bg_cell, text_size=p_size)
    table.cell(panel, 2, vr+1, ka >= 50 ? "▲" : "▼",          text_color=col_a, bgcolor=p_bg_cell, text_size=p_size)

    table.cell(panel, 0, vr+2, "K" + lbl_b, text_color=col_b, bgcolor=p_bg_cell, text_size=p_size)
    table.cell(panel, 1, vr+2, str.tostring(math.round(kb)),   text_color=col_b, bgcolor=p_bg_cell, text_size=p_size)
    table.cell(panel, 2, vr+2, kb >= 50 ? "▲" : "▼",          text_color=col_b, bgcolor=p_bg_cell, text_size=p_size)

    table.cell(panel, 0, vr+3, "K" + lbl_c, text_color=col_c, bgcolor=p_bg_cell, text_size=p_size)
    table.cell(panel, 1, vr+3, str.tostring(math.round(kc)),   text_color=col_c, bgcolor=p_bg_cell, text_size=p_size)
    table.cell(panel, 2, vr+3, kc >= 50 ? "▲" : "▼",          text_color=col_c, bgcolor=p_bg_cell, text_size=p_size)

    table.cell(panel, 0, vr+4, "K" + lbl_d, text_color=col_d, bgcolor=p_bg_cell, text_size=p_size)
    table.cell(panel, 1, vr+4, str.tostring(math.round(kd)),   text_color=col_d, bgcolor=p_bg_cell, text_size=p_size)
    table.cell(panel, 2, vr+4, kd >= 50 ? "▲" : "▼",          text_color=col_d, bgcolor=p_bg_cell, text_size=p_size)
````
