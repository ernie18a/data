# Support & Resistance Threesome [Zofesu]

- url: https://www.tradingview.com/script/jheNKbhu-Support-Resistance-Threesome-Zofesu/
- type: indicator
- pine_id: PUB;edc9f743dff5478db578e191c81a58a1
- version: 1.0

## Description

[b]Support & Resistance Threesome [Zofesu][/b] is an overlay indicator that tracks up to twelve simultaneous liquidity zones across two structural levels — major and minor — and combines zone interaction data with an RSI-based smart entry filter to produce high-probability reversal signals directly at institutional price levels.

The three components work as a system: zones define where price is expected to react, touch counting measures how many times the level has been tested and held, and the entry filter ensures signals fire only when momentum conditions align with the zone interaction.

─────────────────────────────────────
[b]01 — What is S/R Threesome?[/b]
─────────────────────────────────────
[b]S/R Threesome[/b] detects pivot-based support and resistance zones and tracks them dynamically across the chart. Each zone is built around a confirmed swing high or low, padded by a configurable buffer, and updated in real time as price interacts with it.

[b]The indicator tracks two structural levels simultaneously:[/b]

[b]Major zones[/b] — built from wider swing lookback (default 20 bars). These represent significant structural levels where institutional activity is more likely.

[b]Minor zones[/b] — built from shorter swing lookback (default 8 bars). These represent recent, lower-timeframe levels within the larger structure.

Up to three zones per type are tracked simultaneously — three major resistance, three major support, three minor resistance, three minor support — twelve zones total.

─────────────────────────────────────
[b]02 — Zone Lifecycle[/b]
─────────────────────────────────────
[b]Each zone passes through three states:[/b]

[b]Active[/b] — zone is intact, price has not closed beyond it. The zone extends forward in real time and darkens with each confirmed touch.

[b]Confirmed[/b] — zone has been tested at least twice (touch count ≥ 2). Border changes to yellow. A confirmed zone is a higher-probability level — it has held under pressure more than once.

[b]Filled[/b] — price closed beyond the zone boundary. The box turns gray with a dashed border, marking the zone as invalidated. A filled resistance that price returns to often acts as new support, and vice versa.

─────────────────────────────────────
[b]03 — Touch Count and Visual Intensity[/b]
─────────────────────────────────────
Every time a confirmed bar closes with price interacting with a zone boundary, the touch counter increments (maximum 5). The zone responds visually:

[b]Touch 1[/b] — lightest fill, thinnest border
[b]Touch 2[/b] — zone confirmed, yellow border
[b]Touch 3[/b] — medium fill intensity
[b]Touch 4+[/b] — darkest fill, thickest border

This system makes the most tested zones immediately visible — heavier zones have held under more pressure and carry more institutional weight.

─────────────────────────────────────
[b]04 — Buffer System[/b]
─────────────────────────────────────
Zones are not single price lines — they are areas with a configurable half-width on both sides of the pivot price. Three buffer modes are available:

[b]ATR[/b] — zone width adapts to current volatility. Default multiplier: 0.5. Recommended for most markets.
[b]Percent[/b] — fixed percentage of current price. Default: 0.15%.
[b]Fixed[/b] — absolute tick-based value. Default: 500 ticks. Use for specific instruments with known pip structures.

[b]Duplicate filter:[/b] zones that form within 3× buffer distance of an existing major zone, or 2× for minor zones, are suppressed to prevent visual clutter from overlapping levels.

─────────────────────────────────────
[b]05 — Smart Entry System[/b]
─────────────────────────────────────
[b]Entry signals fire when two conditions align simultaneously:[/b]

1. Price interacted with a major support or resistance zone on the previous bar (low touched support zone / high touched resistance zone)
2. RSI confirms momentum exhaustion — oversold for long entries (default below 35), overbought for short entries (default above 65)

A stop loss line is drawn automatically at the time of entry — positioned below the support zone bottom for longs, above the resistance zone top for shorts, with an additional SL buffer applied.

The zone must also be older than the maximum of both swing lookback periods — this prevents entries on zones that were just created and not yet validated by subsequent price action.

─────────────────────────────────────
[b]06 — Settings[/b]
─────────────────────────────────────
Liquidity Zones
[b]Major Swing Lookback[/b] — pivot detection window for major zones. Default: 20.
[b]Minor Swing Lookback[/b] — pivot detection window for minor zones. Default: 8.
[b]ATR Length[/b] — ATR lookback for buffer calculation. Default: 14.
[b]Max Zone Age (bars)[/b] — zones older than this are replaced. Default: 300.

Buffer
[b]Buffer Mode[/b] — ATR / Percent / Fixed. Default: ATR.
[b]ATR Multiplier[/b] — zone half-width as ATR multiple. Default: 0.5.
[b]Percent Buffer %[/b] — zone half-width as % of price. Default: 0.15%.
[b]Fixed Buffer[/b] — zone half-width in ticks. Default: 500.

Entry — RSI
[b]RSI Length[/b] — default: 14.
[b]RSI Overbought[/b] — short entry filter threshold. Default: 65.
[b]RSI Oversold[/b] — long entry filter threshold. Default: 35.

Entry — SL
[b]SL Mode[/b] — ATR / Percent / Fixed. Default: ATR.
[b]SL ATR Multiplier[/b] — SL distance as ATR multiple. Default: 1.5.
[b]SL Percent %[/b] — SL as % of price. Default: 0.5%.
[b]SL Fixed (pips)[/b] — SL in ticks. Default: 800.

Entry — Visual
[b]Show Entry Signals[/b] — enable/disable arrows and SL lines.
[b]SL Line / Long Arrow / Short Arrow[/b] — color settings.

Colors
[b]Major Resistance / Support[/b] — zone fill color for major levels.
[b]Minor Resistance / Support[/b] — zone fill color for minor levels.
[b]Filled Zone[/b] — border color for invalidated zones.
[b]Resistance / Support Border[/b] — active zone border color.
[b]Confirmed Border[/b] — border color when touch count ≥ 2. Default: yellow.

─────────────────────────────────────
[b]07 — How To Use[/b]
─────────────────────────────────────
[b]Step 1[/b] — Identify the active zones
Major zones (darker, thicker border) are the primary levels. Minor zones provide secondary context within the structure.

[b]Step 2[/b] — Watch for confirmed zones
Yellow border = zone has been tested and held at least twice. These are the highest-priority levels to trade from.

[b]Step 3[/b] — Wait for the entry signal
A triangle arrow appears when price touches a major zone with RSI confirming exhaustion. The SL line shows the invalidation level automatically.

[b]Step 4[/b] — Read zone fill intensity
Darker fill = more touches = stronger institutional interest at that level. Lighter fill = fresh zone, treat with less conviction.

[b]Step 5[/b] — Monitor filled zones
Gray dashed zones that price returns to after being filled often flip polarity — former resistance becomes support and vice versa. Watch for interaction at these levels even after they are invalidated.

[b]Step 6[/b] — Alerts
Two alert conditions are pre-configured:
[b]S/R-3: LONG[/b] — long entry at support zone with RSI oversold
[b]S/R-3: SHORT[/b] — short entry at resistance zone with RSI overbought

Works on all asset classes: Indices, Forex, Gold, Oil, Crypto.
Best timeframes: H1, H4, D1.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Since 2020 Zofesu

//@version=6
indicator("Support & Resistance Threesome [Zofesu]",
     shorttitle="[Zofesu] S/R-3",
     overlay=true,
     max_bars_back=500)

// ══════════════════════════════════════════
//  INPUTS — LIQUIDITY ZONES
// ══════════════════════════════════════════

swing_major = input.int(20,   "Major Swing Lookback", group="Liquidity Zones", tooltip="Lookback period for detecting major pivot highs and lows. Higher = fewer but more significant zones. Default 20.")
swing_minor = input.int(8,    "Minor Swing Lookback", group="Liquidity Zones", tooltip="Lookback period for detecting minor pivot highs and lows. Lower = more sensitive, more zones. Default 8.")
atr_len     = input.int(14,   "ATR Length",           group="Liquidity Zones", tooltip="ATR lookback used for zone buffer calculation when Buffer Mode is set to ATR. Default 14.")
max_hist    = input.int(300,  "Max Zone Age (bars)",  group="Liquidity Zones", minval=50, step=100, maxval=5000, tooltip="Maximum age of a zone in bars. Zones older than this are replaced when a new pivot is detected. Default 300.")

buf_mode  = input.string("ATR", "Buffer Mode", options=["ATR", "Percent", "Fixed"], group="Buffer", tooltip="Method used to calculate the zone width around each pivot. ATR = adaptive to volatility. Percent = fixed % of price. Fixed = absolute tick-based value.")
atr_mult  = input.float(0.5,   "ATR Multiplier",   group="Buffer", step=0.1, tooltip="Zone half-width as a multiple of ATR. Active when Buffer Mode = ATR. Default 0.5.")
buf_pct   = input.float(0.15,  "Percent Buffer %", group="Buffer", step=0.05, tooltip="Zone half-width as a percentage of current price. Active when Buffer Mode = Percent. Default 0.15%.")
buf_fixed = input.float(500.0, "Fixed Buffer",     group="Buffer", step=100.0, tooltip="Zone half-width as a fixed number of ticks (multiplied by syminfo.mintick). Active when Buffer Mode = Fixed. Default 500.")

col_major_r   = input.color(#ff0000, "Major Resistance",  group="Colors", tooltip="Fill color for major resistance zones. Transparency is controlled automatically by touch count.")
col_major_s   = input.color(#00ff08, "Major Support",     group="Colors", tooltip="Fill color for major support zones. Transparency is controlled automatically by touch count.")
col_minor_r   = input.color(#ff8080, "Minor Resistance",  group="Colors", tooltip="Fill color for minor resistance zones.")
col_minor_s   = input.color(#83ff87, "Minor Support",     group="Colors", tooltip="Fill color for minor support zones.")
col_filled    = input.color(#787b86, "Filled Zone",       group="Colors", tooltip="Border color for zones that have been broken through (filled/invalidated).")
col_border_r  = input.color(#a10000, "Resistance Border", group="Colors", tooltip="Border color for active resistance zones.")
col_border_s  = input.color(#00a105, "Support Border",    group="Colors", tooltip="Border color for active support zones.")
col_confirmed = input.color(color.yellow, "Confirmed Border", group="Colors", tooltip="Border color when a zone has been tested at least twice. Indicates a confirmed, high-probability level.")

// ══════════════════════════════════════════
//  INPUTS — ENTRY
// ══════════════════════════════════════════

rsi_len        = input.int(14,   "RSI Length",     group="Entry — RSI", tooltip="RSI lookback period. Default 14.")
rsi_overbought = input.float(65, "RSI Overbought", group="Entry — RSI", step=1.0, tooltip="RSI level above which price is considered overbought. Short entry filter. Default 65.")
rsi_oversold   = input.float(35, "RSI Oversold",   group="Entry — RSI", step=1.0, tooltip="RSI level below which price is considered oversold. Long entry filter. Default 35.")

sl_mode   = input.string("ATR", "SL Mode", options=["ATR", "Percent", "Fixed"], group="Entry — SL", tooltip="Method for calculating the stop loss distance below/above the zone. ATR = adaptive. Percent = fixed %. Fixed = tick-based.")
sl_mult   = input.float(1.5,   "SL ATR Multiplier",  group="Entry — SL", step=0.1, tooltip="SL distance as a multiple of ATR. Active when SL Mode = ATR. Default 1.5.")
sl_pct    = input.float(0.5,   "SL Percent %",       group="Entry — SL", step=0.05, tooltip="SL distance as a percentage of price. Active when SL Mode = Percent. Default 0.5%.")
sl_fixed  = input.float(800.0, "SL Fixed (pips)",    group="Entry — SL", step=100.0, tooltip="SL distance as a fixed number of ticks. Active when SL Mode = Fixed. Default 800.")

show_entry    = input.bool(true, "Show Entry Signals",  group="Entry — Visual", tooltip="Enable or disable entry signal arrows and SL lines on the chart.")
col_sl        = input.color(color.new(#ffffff, 0), "SL Line",          group="Entry — Visual", tooltip="Color of the stop loss line drawn at entry.")
col_arrow_l   = input.color(color.new(#00ff9d, 0), "Long Arrow",       group="Entry — Visual", tooltip="Color of the long entry arrow.")
col_arrow_s   = input.color(color.new(#c40093, 0), "Short Arrow",      group="Entry — Visual", tooltip="Color of the short entry arrow.")

// ══════════════════════════════════════════
//  ATR + BUFFER + SWING
// ══════════════════════════════════════════

atr_val = ta.atr(atr_len)

f_buf() =>
    float result = atr_val * atr_mult
    if buf_mode == "Percent"
        result := close * buf_pct / 100
    else if buf_mode == "Fixed"
        result := buf_fixed * syminfo.mintick
    result

f_sl() =>
    float result = atr_val * sl_mult
    if sl_mode == "Percent"
        result := close * sl_pct / 100
    else if sl_mode == "Fixed"
        result := sl_fixed * syminfo.mintick
    result

sh_major = ta.pivothigh(high, swing_major, swing_major)
sl_major = ta.pivotlow(low,  swing_major, swing_major)
sh_minor = ta.pivothigh(high, swing_minor, swing_minor)
sl_minor = ta.pivotlow(low,  swing_minor, swing_minor)

// ══════════════════════════════════════════
//  RSI
// ══════════════════════════════════════════

rsi_val      = ta.rsi(close, rsi_len)
long_signal  = rsi_val < rsi_oversold
short_signal = rsi_val > rsi_overbought

// ══════════════════════════════════════════
//  ZONE VARIABLES
// ══════════════════════════════════════════

var float mr1_top = na
var float mr1_bot = na
var int   mr1_bar = na
var bool  mr1_f   = false
var int   mr1_t   = 1
var bool  mr1_c   = false
var float mr2_top = na
var float mr2_bot = na
var int   mr2_bar = na
var bool  mr2_f   = false
var int   mr2_t   = 1
var bool  mr2_c   = false
var float mr3_top = na
var float mr3_bot = na
var int   mr3_bar = na
var bool  mr3_f   = false
var int   mr3_t   = 1
var bool  mr3_c   = false

var float ms1_top = na
var float ms1_bot = na
var int   ms1_bar = na
var bool  ms1_f   = false
var int   ms1_t   = 1
var bool  ms1_c   = false
var float ms2_top = na
var float ms2_bot = na
var int   ms2_bar = na
var bool  ms2_f   = false
var int   ms2_t   = 1
var bool  ms2_c   = false
var float ms3_top = na
var float ms3_bot = na
var int   ms3_bar = na
var bool  ms3_f   = false
var int   ms3_t   = 1
var bool  ms3_c   = false

var float nr1_top = na
var float nr1_bot = na
var int   nr1_bar = na
var bool  nr1_f   = false
var int   nr1_t   = 1
var bool  nr1_c   = false
var float nr2_top = na
var float nr2_bot = na
var int   nr2_bar = na
var bool  nr2_f   = false
var int   nr2_t   = 1
var bool  nr2_c   = false
var float nr3_top = na
var float nr3_bot = na
var int   nr3_bar = na
var bool  nr3_f   = false
var int   nr3_t   = 1
var bool  nr3_c   = false

var float ns1_top = na
var float ns1_bot = na
var int   ns1_bar = na
var bool  ns1_f   = false
var int   ns1_t   = 1
var bool  ns1_c   = false
var float ns2_top = na
var float ns2_bot = na
var int   ns2_bar = na
var bool  ns2_f   = false
var int   ns2_t   = 1
var bool  ns2_c   = false
var float ns3_top = na
var float ns3_bot = na
var int   ns3_bar = na
var bool  ns3_f   = false
var int   ns3_t   = 1
var bool  ns3_c   = false

var box b_mr1 = na
var box b_mr2 = na
var box b_mr3 = na
var box b_ms1 = na
var box b_ms2 = na
var box b_ms3 = na
var box b_nr1 = na
var box b_nr2 = na
var box b_nr3 = na
var box b_ns1 = na
var box b_ns2 = na
var box b_ns3 = na

// ══════════════════════════════════════════
//  DUPLICATE FILTERS
// ══════════════════════════════════════════

f_dup_mr(v) =>
    a = not na(mr1_top) and math.abs(mr1_top - v) < f_buf() * 3
    b = not na(mr2_top) and math.abs(mr2_top - v) < f_buf() * 3
    c = not na(mr3_top) and math.abs(mr3_top - v) < f_buf() * 3
    a or b or c

f_dup_ms(v) =>
    a = not na(ms1_bot) and math.abs(ms1_bot - v) < f_buf() * 3
    b = not na(ms2_bot) and math.abs(ms2_bot - v) < f_buf() * 3
    c = not na(ms3_bot) and math.abs(ms3_bot - v) < f_buf() * 3
    a or b or c

f_dup_nr(v) =>
    a = not na(nr1_top) and math.abs(nr1_top - v) < f_buf() * 2
    b = not na(nr2_top) and math.abs(nr2_top - v) < f_buf() * 2
    c = not na(nr3_top) and math.abs(nr3_top - v) < f_buf() * 2
    a or b or c

f_dup_ns(v) =>
    a = not na(ns1_bot) and math.abs(ns1_bot - v) < f_buf() * 2
    b = not na(ns2_bot) and math.abs(ns2_bot - v) < f_buf() * 2
    c = not na(ns3_bot) and math.abs(ns3_bot - v) < f_buf() * 2
    a or b or c

f_lw(t) => t >= 4 ? 4 : t >= 3 ? 3 : t >= 2 ? 2 : 1
f_tr(t)  => t >= 4 ? 35 : t >= 3 ? 45 : t >= 2 ? 55 : 70

// ══════════════════════════════════════════
//  REGISTRATION — MAJOR RESISTANCE
// ══════════════════════════════════════════

if not na(sh_major)
    if not f_dup_mr(sh_major)
        zt   = sh_major + f_buf()
        zb   = sh_major - f_buf()
        zbar = bar_index - swing_major
        if na(mr1_top) or mr1_f or (bar_index - mr1_bar) > max_hist
            mr1_top := zt
            mr1_bot := zb
            mr1_bar := zbar
            mr1_f   := false
            mr1_t   := 1
            mr1_c   := false
            box.delete(b_mr1)
            b_mr1 := box.new(zbar, zb, bar_index, zt, bgcolor=color.new(col_major_r, f_tr(1)), border_color=col_border_r, border_width=2)
        else if na(mr2_top) or mr2_f or (bar_index - mr2_bar) > max_hist
            mr2_top := zt
            mr2_bot := zb
            mr2_bar := zbar
            mr2_f   := false
            mr2_t   := 1
            mr2_c   := false
            box.delete(b_mr2)
            b_mr2 := box.new(zbar, zb, bar_index, zt, bgcolor=color.new(col_major_r, f_tr(1)), border_color=col_border_r, border_width=2)
        else if na(mr3_top) or mr3_f or (bar_index - mr3_bar) > max_hist
            mr3_top := zt
            mr3_bot := zb
            mr3_bar := zbar
            mr3_f   := false
            mr3_t   := 1
            mr3_c   := false
            box.delete(b_mr3)
            b_mr3 := box.new(zbar, zb, bar_index, zt, bgcolor=color.new(col_major_r, f_tr(1)), border_color=col_border_r, border_width=2)
    else
        if not na(mr1_top) and not mr1_f and math.abs(mr1_top - sh_major) < f_buf() * 3
            mr1_t := math.min(mr1_t + 1, 5)
        if not na(mr2_top) and not mr2_f and math.abs(mr2_top - sh_major) < f_buf() * 3
            mr2_t := math.min(mr2_t + 1, 5)
        if not na(mr3_top) and not mr3_f and math.abs(mr3_top - sh_major) < f_buf() * 3
            mr3_t := math.min(mr3_t + 1, 5)

// ══════════════════════════════════════════
//  REGISTRATION — MAJOR SUPPORT
// ══════════════════════════════════════════

if not na(sl_major)
    if not f_dup_ms(sl_major)
        zt   = sl_major + f_buf()
        zb   = sl_major - f_buf()
        zbar = bar_index - swing_major
        if na(ms1_bot) or ms1_f or (bar_index - ms1_bar) > max_hist
            ms1_top := zt
            ms1_bot := zb
            ms1_bar := zbar
            ms1_f   := false
            ms1_t   := 1
            ms1_c   := false
            box.delete(b_ms1)
            b_ms1 := box.new(zbar, zb, bar_index, zt, bgcolor=color.new(col_major_s, f_tr(1)), border_color=col_border_s, border_width=2)
        else if na(ms2_bot) or ms2_f or (bar_index - ms2_bar) > max_hist
            ms2_top := zt
            ms2_bot := zb
            ms2_bar := zbar
            ms2_f   := false
            ms2_t   := 1
            ms2_c   := false
            box.delete(b_ms2)
            b_ms2 := box.new(zbar, zb, bar_index, zt, bgcolor=color.new(col_major_s, f_tr(1)), border_color=col_border_s, border_width=2)
        else if na(ms3_bot) or ms3_f or (bar_index - ms3_bar) > max_hist
            ms3_top := zt
            ms3_bot := zb
            ms3_bar := zbar
            ms3_f   := false
            ms3_t   := 1
            ms3_c   := false
            box.delete(b_ms3)
            b_ms3 := box.new(zbar, zb, bar_index, zt, bgcolor=color.new(col_major_s, f_tr(1)), border_color=col_border_s, border_width=2)
    else
        if not na(ms1_bot) and not ms1_f and math.abs(ms1_bot - sl_major) < f_buf() * 3
            ms1_t := math.min(ms1_t + 1, 5)
        if not na(ms2_bot) and not ms2_f and math.abs(ms2_bot - sl_major) < f_buf() * 3
            ms2_t := math.min(ms2_t + 1, 5)
        if not na(ms3_bot) and not ms3_f and math.abs(ms3_bot - sl_major) < f_buf() * 3
            ms3_t := math.min(ms3_t + 1, 5)

// ══════════════════════════════════════════
//  REGISTRATION — MINOR RESISTANCE
// ══════════════════════════════════════════

if not na(sh_minor)
    if not f_dup_nr(sh_minor) and not f_dup_mr(sh_minor)
        zt   = sh_minor + f_buf()
        zb   = sh_minor - f_buf()
        zbar = bar_index - swing_minor
        if na(nr1_top) or nr1_f or (bar_index - nr1_bar) > max_hist
            nr1_top := zt
            nr1_bot := zb
            nr1_bar := zbar
            nr1_f   := false
            nr1_t   := 1
            nr1_c   := false
            box.delete(b_nr1)
            b_nr1 := box.new(zbar, zb, bar_index, zt, bgcolor=color.new(col_minor_r, f_tr(1)), border_color=col_border_r, border_width=1)
        else if na(nr2_top) or nr2_f or (bar_index - nr2_bar) > max_hist
            nr2_top := zt
            nr2_bot := zb
            nr2_bar := zbar
            nr2_f   := false
            nr2_t   := 1
            nr2_c   := false
            box.delete(b_nr2)
            b_nr2 := box.new(zbar, zb, bar_index, zt, bgcolor=color.new(col_minor_r, f_tr(1)), border_color=col_border_r, border_width=1)
        else if na(nr3_top) or nr3_f or (bar_index - nr3_bar) > max_hist
            nr3_top := zt
            nr3_bot := zb
            nr3_bar := zbar
            nr3_f   := false
            nr3_t   := 1
            nr3_c   := false
            box.delete(b_nr3)
            b_nr3 := box.new(zbar, zb, bar_index, zt, bgcolor=color.new(col_minor_r, f_tr(1)), border_color=col_border_r, border_width=1)
    else
        if not na(nr1_top) and not nr1_f and math.abs(nr1_top - sh_minor) < f_buf() * 2
            nr1_t := math.min(nr1_t + 1, 5)
        if not na(nr2_top) and not nr2_f and math.abs(nr2_top - sh_minor) < f_buf() * 2
            nr2_t := math.min(nr2_t + 1, 5)
        if not na(nr3_top) and not nr3_f and math.abs(nr3_top - sh_minor) < f_buf() * 2
            nr3_t := math.min(nr3_t + 1, 5)

// ══════════════════════════════════════════
//  REGISTRATION — MINOR SUPPORT
// ══════════════════════════════════════════

if not na(sl_minor)
    if not f_dup_ns(sl_minor) and not f_dup_ms(sl_minor)
        zt   = sl_minor + f_buf()
        zb   = sl_minor - f_buf()
        zbar = bar_index - swing_minor
        if na(ns1_bot) or ns1_f or (bar_index - ns1_bar) > max_hist
            ns1_top := zt
            ns1_bot := zb
            ns1_bar := zbar
            ns1_f   := false
            ns1_t   := 1
            ns1_c   := false
            box.delete(b_ns1)
            b_ns1 := box.new(zbar, zb, bar_index, zt, bgcolor=color.new(col_minor_s, f_tr(1)), border_color=col_border_s, border_width=1)
        else if na(ns2_bot) or ns2_f or (bar_index - ns2_bar) > max_hist
            ns2_top := zt
            ns2_bot := zb
            ns2_bar := zbar
            ns2_f   := false
            ns2_t   := 1
            ns2_c   := false
            box.delete(b_ns2)
            b_ns2 := box.new(zbar, zb, bar_index, zt, bgcolor=color.new(col_minor_s, f_tr(1)), border_color=col_border_s, border_width=1)
        else if na(ns3_bot) or ns3_f or (bar_index - ns3_bar) > max_hist
            ns3_top := zt
            ns3_bot := zb
            ns3_bar := zbar
            ns3_f   := false
            ns3_t   := 1
            ns3_c   := false
            box.delete(b_ns3)
            b_ns3 := box.new(zbar, zb, bar_index, zt, bgcolor=color.new(col_minor_s, f_tr(1)), border_color=col_border_s, border_width=1)
    else
        if not na(ns1_bot) and not ns1_f and math.abs(ns1_bot - sl_minor) < f_buf() * 2
            ns1_t := math.min(ns1_t + 1, 5)
        if not na(ns2_bot) and not ns2_f and math.abs(ns2_bot - sl_minor) < f_buf() * 2
            ns2_t := math.min(ns2_t + 1, 5)
        if not na(ns3_bot) and not ns3_f and math.abs(ns3_bot - sl_minor) < f_buf() * 2
            ns3_t := math.min(ns3_t + 1, 5)

// ══════════════════════════════════════════
//  UPDATE — MAJOR RESISTANCE
// ══════════════════════════════════════════

if not na(mr1_top)
    if not mr1_f and high > mr1_top
        mr1_f := true
        box.delete(b_mr1)
        b_mr1 := box.new(mr1_bar, mr1_bot, bar_index, mr1_top, bgcolor=color.new(color.gray, 90), border_color=col_filled, border_width=1, border_style=line.style_dashed)
    else if not mr1_f
        if barstate.isconfirmed and high >= mr1_bot and high <= mr1_top
            mr1_t := math.min(mr1_t + 1, 5)
        box.set_right(b_mr1, bar_index)
        box.set_border_width(b_mr1, f_lw(mr1_t))
        box.set_bgcolor(b_mr1, color.new(col_major_r, f_tr(mr1_t)))
        box.set_border_color(b_mr1, mr1_c ? col_confirmed : col_border_r)

if not na(mr2_top)
    if not mr2_f and high > mr2_top
        mr2_f := true
        box.delete(b_mr2)
        b_mr2 := box.new(mr2_bar, mr2_bot, bar_index, mr2_top, bgcolor=color.new(color.gray, 90), border_color=col_filled, border_width=1, border_style=line.style_dashed)
    else if not mr2_f
        if barstate.isconfirmed and high >= mr2_bot and high <= mr2_top
            mr2_t := math.min(mr2_t + 1, 5)
        box.set_right(b_mr2, bar_index)
        box.set_border_width(b_mr2, f_lw(mr2_t))
        box.set_bgcolor(b_mr2, color.new(col_major_r, f_tr(mr2_t)))
        box.set_border_color(b_mr2, mr2_c ? col_confirmed : col_border_r)

if not na(mr3_top)
    if not mr3_f and high > mr3_top
        mr3_f := true
        box.delete(b_mr3)
        b_mr3 := box.new(mr3_bar, mr3_bot, bar_index, mr3_top, bgcolor=color.new(color.gray, 90), border_color=col_filled, border_width=1, border_style=line.style_dashed)
    else if not mr3_f
        if barstate.isconfirmed and high >= mr3_bot and high <= mr3_top
            mr3_t := math.min(mr3_t + 1, 5)
        box.set_right(b_mr3, bar_index)
        box.set_border_width(b_mr3, f_lw(mr3_t))
        box.set_bgcolor(b_mr3, color.new(col_major_r, f_tr(mr3_t)))
        box.set_border_color(b_mr3, mr3_c ? col_confirmed : col_border_r)

// ══════════════════════════════════════════
//  UPDATE — MAJOR SUPPORT
// ══════════════════════════════════════════

if not na(ms1_top)
    if not ms1_f and low < ms1_bot
        ms1_f := true
        box.delete(b_ms1)
        b_ms1 := box.new(ms1_bar, ms1_bot, bar_index, ms1_top, bgcolor=color.new(color.gray, 90), border_color=col_filled, border_width=1, border_style=line.style_dashed)
    else if not ms1_f
        if barstate.isconfirmed and low <= ms1_top and low >= ms1_bot
            ms1_t := math.min(ms1_t + 1, 5)
        box.set_right(b_ms1, bar_index)
        box.set_border_width(b_ms1, f_lw(ms1_t))
        box.set_bgcolor(b_ms1, color.new(col_major_s, f_tr(ms1_t)))
        box.set_border_color(b_ms1, ms1_c ? col_confirmed : col_border_s)

if not na(ms2_top)
    if not ms2_f and low < ms2_bot
        ms2_f := true
        box.delete(b_ms2)
        b_ms2 := box.new(ms2_bar, ms2_bot, bar_index, ms2_top, bgcolor=color.new(color.gray, 90), border_color=col_filled, border_width=1, border_style=line.style_dashed)
    else if not ms2_f
        if barstate.isconfirmed and low <= ms2_top and low >= ms2_bot
            ms2_t := math.min(ms2_t + 1, 5)
        box.set_right(b_ms2, bar_index)
        box.set_border_width(b_ms2, f_lw(ms2_t))
        box.set_bgcolor(b_ms2, color.new(col_major_s, f_tr(ms2_t)))
        box.set_border_color(b_ms2, ms2_c ? col_confirmed : col_border_s)

if not na(ms3_top)
    if not ms3_f and low < ms3_bot
        ms3_f := true
        box.delete(b_ms3)
        b_ms3 := box.new(ms3_bar, ms3_bot, bar_index, ms3_top, bgcolor=color.new(color.gray, 90), border_color=col_filled, border_width=1, border_style=line.style_dashed)
    else if not ms3_f
        if barstate.isconfirmed and low <= ms3_top and low >= ms3_bot
            ms3_t := math.min(ms3_t + 1, 5)
        box.set_right(b_ms3, bar_index)
        box.set_border_width(b_ms3, f_lw(ms3_t))
        box.set_bgcolor(b_ms3, color.new(col_major_s, f_tr(ms3_t)))
        box.set_border_color(b_ms3, ms3_c ? col_confirmed : col_border_s)

// ══════════════════════════════════════════
//  UPDATE — MINOR RESISTANCE
// ══════════════════════════════════════════

if not na(nr1_top)
    if not nr1_f and high > nr1_top
        nr1_f := true
        box.delete(b_nr1)
        b_nr1 := box.new(nr1_bar, nr1_bot, bar_index, nr1_top, bgcolor=color.new(color.gray, 92), border_color=col_filled, border_width=1, border_style=line.style_dashed)
    else if not nr1_f
        if barstate.isconfirmed and high >= nr1_bot and high <= nr1_top
            nr1_t := math.min(nr1_t + 1, 5)
        box.set_right(b_nr1, bar_index)
        box.set_border_width(b_nr1, f_lw(nr1_t))
        box.set_bgcolor(b_nr1, color.new(col_minor_r, f_tr(nr1_t)))
        box.set_border_color(b_nr1, nr1_c ? col_confirmed : col_border_r)

if not na(nr2_top)
    if not nr2_f and high > nr2_top
        nr2_f := true
        box.delete(b_nr2)
        b_nr2 := box.new(nr2_bar, nr2_bot, bar_index, nr2_top, bgcolor=color.new(color.gray, 92), border_color=col_filled, border_width=1, border_style=line.style_dashed)
    else if not nr2_f
        if barstate.isconfirmed and high >= nr2_bot and high <= nr2_top
            nr2_t := math.min(nr2_t + 1, 5)
        box.set_right(b_nr2, bar_index)
        box.set_border_width(b_nr2, f_lw(nr2_t))
        box.set_bgcolor(b_nr2, color.new(col_minor_r, f_tr(nr2_t)))
        box.set_border_color(b_nr2, nr2_c ? col_confirmed : col_border_r)

if not na(nr3_top)
    if not nr3_f and high > nr3_top
        nr3_f := true
        box.delete(b_nr3)
        b_nr3 := box.new(nr3_bar, nr3_bot, bar_index, nr3_top, bgcolor=color.new(color.gray, 92), border_color=col_filled, border_width=1, border_style=line.style_dashed)
    else if not nr3_f
        if barstate.isconfirmed and high >= nr3_bot and high <= nr3_top
            nr3_t := math.min(nr3_t + 1, 5)
        box.set_right(b_nr3, bar_index)
        box.set_border_width(b_nr3, f_lw(nr3_t))
        box.set_bgcolor(b_nr3, color.new(col_minor_r, f_tr(nr3_t)))
        box.set_border_color(b_nr3, nr3_c ? col_confirmed : col_border_r)

// ══════════════════════════════════════════
//  UPDATE — MINOR SUPPORT
// ══════════════════════════════════════════

if not na(ns1_top)
    if not ns1_f and low < ns1_bot
        ns1_f := true
        box.delete(b_ns1)
        b_ns1 := box.new(ns1_bar, ns1_bot, bar_index, ns1_top, bgcolor=color.new(color.gray, 92), border_color=col_filled, border_width=1, border_style=line.style_dashed)
    else if not ns1_f
        if barstate.isconfirmed and low <= ns1_top and low >= ns1_bot
            ns1_t := math.min(ns1_t + 1, 5)
        box.set_right(b_ns1, bar_index)
        box.set_border_width(b_ns1, f_lw(ns1_t))
        box.set_bgcolor(b_ns1, color.new(col_minor_s, f_tr(ns1_t)))
        box.set_border_color(b_ns1, ns1_c ? col_confirmed : col_border_s)

if not na(ns2_top)
    if not ns2_f and low < ns2_bot
        ns2_f := true
        box.delete(b_ns2)
        b_ns2 := box.new(ns2_bar, ns2_bot, bar_index, ns2_top, bgcolor=color.new(color.gray, 92), border_color=col_filled, border_width=1, border_style=line.style_dashed)
    else if not ns2_f
        if barstate.isconfirmed and low <= ns2_top and low >= ns2_bot
            ns2_t := math.min(ns2_t + 1, 5)
        box.set_right(b_ns2, bar_index)
        box.set_border_width(b_ns2, f_lw(ns2_t))
        box.set_bgcolor(b_ns2, color.new(col_minor_s, f_tr(ns2_t)))
        box.set_border_color(b_ns2, ns2_c ? col_confirmed : col_border_s)

if not na(ns3_top)
    if not ns3_f and low < ns3_bot
        ns3_f := true
        box.delete(b_ns3)
        b_ns3 := box.new(ns3_bar, ns3_bot, bar_index, ns3_top, bgcolor=color.new(color.gray, 92), border_color=col_filled, border_width=1, border_style=line.style_dashed)
    else if not ns3_f
        if barstate.isconfirmed and low <= ns3_top and low >= ns3_bot
            ns3_t := math.min(ns3_t + 1, 5)
        box.set_right(b_ns3, bar_index)
        box.set_border_width(b_ns3, f_lw(ns3_t))
        box.set_bgcolor(b_ns3, color.new(col_minor_s, f_tr(ns3_t)))
        box.set_border_color(b_ns3, ns3_c ? col_confirmed : col_border_s)

// ══════════════════════════════════════════
//  ZONE CONFIRMATION
// ══════════════════════════════════════════

if not na(mr1_top) and not mr1_f and mr1_t >= 2
    mr1_c := true
if not na(mr2_top) and not mr2_f and mr2_t >= 2
    mr2_c := true
if not na(mr3_top) and not mr3_f and mr3_t >= 2
    mr3_c := true
if not na(ms1_bot) and not ms1_f and ms1_t >= 2
    ms1_c := true
if not na(ms2_bot) and not ms2_f and ms2_t >= 2
    ms2_c := true
if not na(ms3_bot) and not ms3_f and ms3_t >= 2
    ms3_c := true
if not na(nr1_top) and not nr1_f and nr1_t >= 2
    nr1_c := true
if not na(nr2_top) and not nr2_f and nr2_t >= 2
    nr2_c := true
if not na(nr3_top) and not nr3_f and nr3_t >= 2
    nr3_c := true
if not na(ns1_bot) and not ns1_f and ns1_t >= 2
    ns1_c := true
if not na(ns2_bot) and not ns2_f and ns2_t >= 2
    ns2_c := true
if not na(ns3_bot) and not ns3_f and ns3_t >= 2
    ns3_c := true

// ══════════════════════════════════════════
//  SMART ENTRY
// ══════════════════════════════════════════

min_zone_age = math.max(swing_major, swing_minor) + 1

f_in_support() =>
    a = not na(ms1_top) and not ms1_f and low[1] <= ms1_top and low[1] >= ms1_bot and (bar_index - ms1_bar) > min_zone_age
    b = not na(ms2_top) and not ms2_f and low[1] <= ms2_top and low[1] >= ms2_bot and (bar_index - ms2_bar) > min_zone_age
    d = not na(ms3_top) and not ms3_f and low[1] <= ms3_top and low[1] >= ms3_bot and (bar_index - ms3_bar) > min_zone_age
    a or b or d

f_in_resistance() =>
    a = not na(mr1_top) and not mr1_f and high[1] >= mr1_bot and high[1] <= mr1_top and (bar_index - mr1_bar) > min_zone_age
    b = not na(mr2_top) and not mr2_f and high[1] >= mr2_bot and high[1] <= mr2_top and (bar_index - mr2_bar) > min_zone_age
    d = not na(mr3_top) and not mr3_f and high[1] >= mr3_bot and high[1] <= mr3_top and (bar_index - mr3_bar) > min_zone_age
    a or b or d

f_sl_bot() =>
    float z = na
    if not na(ms1_top) and not ms1_f and low[1] <= ms1_top and low[1] >= ms1_bot
        z := ms1_bot
    else if not na(ms2_top) and not ms2_f and low[1] <= ms2_top and low[1] >= ms2_bot
        z := ms2_bot
    else if not na(ms3_top) and not ms3_f and low[1] <= ms3_top and low[1] >= ms3_bot
        z := ms3_bot
    z

f_sl_top() =>
    float z = na
    if not na(mr1_top) and not mr1_f and high[1] >= mr1_bot and high[1] <= mr1_top
        z := mr1_top
    else if not na(mr2_top) and not mr2_f and high[1] >= mr2_bot and high[1] <= mr2_top
        z := mr2_top
    else if not na(mr3_top) and not mr3_f and high[1] >= mr3_bot and high[1] <= mr3_top
        z := mr3_top
    z

long_entry  = show_entry and barstate.isconfirmed and long_signal[1]  and f_in_support()
short_entry = show_entry and barstate.isconfirmed and short_signal[1] and f_in_resistance()

if long_entry
    sl_price = f_sl_bot() - f_sl()
    line.new(bar_index, sl_price, bar_index + 3, sl_price,
         color=col_sl, width=2, style=line.style_solid)

if short_entry
    sl_price = f_sl_top() + f_sl()
    line.new(bar_index, sl_price, bar_index + 3, sl_price,
         color=col_sl, width=2, style=line.style_solid)

plotshape(long_entry,  "LONG Entry",  shape.triangleup,   location.belowbar, col_arrow_l, size=size.normal)
plotshape(short_entry, "SHORT Entry", shape.triangledown, location.abovebar, col_arrow_s, size=size.normal)

alertcondition(long_entry,  "S/R-3: LONG",  "[S/R Threesome] Long Entry — support zone + RSI oversold on {{ticker}} ({{interval}})")
alertcondition(short_entry, "S/R-3: SHORT", "[S/R Threesome] Short Entry — resistance zone + RSI overbought on {{ticker}} ({{interval}})")
````
