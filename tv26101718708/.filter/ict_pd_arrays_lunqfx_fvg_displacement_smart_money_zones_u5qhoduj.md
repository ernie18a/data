# ICT PD Arrays [LunqFX] FVG, Displacement & Smart Money Zones

- url: https://www.tradingview.com/script/U5qHodUJ-ICT-PD-Arrays-LunqFX-FVG-Displacement-Smart-Money-Zones/
- type: indicator
- pine_id: PUB;06f96e7654f840c2a7a40a1fc3f1535f
- version: 1.0

## Description

ICT PD Arrays is a complete Smart Money Concepts toolkit built on the Inner
Circle Trader (ICT) methodology. It maps the full Price Delivery Array —
7 interconnected modules working together to identify where institutions
accumulate and distribute positions across any liquid market.


█  WHAT IT DOES

[image]https://www.tradingview.com/x/OobVQOtS/[/image]

Most ICT indicators cover one concept in isolation — a Fair Value Gap, or
just Premium/Discount zones. This script combines all core PD Array
components into one cohesive system and ties them together with an ISD
state machine and a live HUD dashboard that shows full market context
at a glance.

Seven modules run simultaneously on every bar:

[1] Fair Value Gaps (FVG) + Inversion FVG + Balanced Price Range (BPR)
[2] Premium / Discount Zones + OTE Fibonacci Zones + Equilibrium Line
[3] Displacement Detection with ATR and Volume confirmation
[4] Inducement (IDM) — false breakout / liquidity trap detection
[5] ISD Sequence state machine (Inducement → Sweep → Displacement)
[6] Killzones — London, New York, Asian, Silver Bullet sessions
[7] Live HUD Dashboard — all signals aggregated in real time


█  HOW IT DOES IT

[1] FAIR VALUE GAPS

A Fair Value Gap is a 3-candle price imbalance where the gap between
candle 1's extreme and candle 3's extreme was never traded. Institutions
use these gaps as re-entry points — price gravitates back to fill them.

Detection uses a confirmed 3-candle structure with a [1] bar offset so
the current live bar never creates a new FVG. No repainting.

An ATR(14)-based minimum size filter removes micro-gaps that carry no
significance. Raise the multiplier to see only strong imbalances.

Mitigation is tracked in real time. Once price crosses the CE midpoint
(Consequent Encroachment — the 50% level of the gap), the box fades.

When price fully passes through a gap it automatically converts to an
Inversion FVG (IFVG) — former support becomes resistance, box recolors.

Balanced Price Range (BPR) detects spatial overlap between the most
recent bullish FVG and bearish FVG. The overlap zone is where both
buyer and seller imbalances exist at the same price — the strongest
equilibrium area on the chart.


[2] PREMIUM / DISCOUNT ZONES + OTE

ICT divides any dealing range into two halves: Premium (above 50%) where
institutions sell, and Discount (below 50%) where institutions buy.

Swing highs and lows are detected via pivot logic with a configurable
lookback. The range between the last confirmed pivot high and pivot low
becomes the active dealing range.

Two OTE zones are drawn using Fibonacci retracement logic:

OTE Buy zone  — 21.4% to 38.2% from the low
               = 61.8%–78.6% retracement FROM the swing high
               = deepest discount, highest-probability long area

OTE Sell zone — 61.8% to 78.6% from the low
               = deepest premium, highest-probability short area

Math:
OTE Buy Top  = SwingLow + Range x 0.382
OTE Buy Bot  = SwingLow + Range x 0.214
OTE Sell Top = SwingLow + Range x 0.786
OTE Sell Bot = SwingLow + Range x 0.618

Zones update automatically when new pivots are confirmed.


[3] DISPLACEMENT

Displacement is not simply a large candle. In ICT theory it marks a
genuine shift of institutional order flow — it must show conviction.

Three conditions must all be satisfied simultaneously:

  Body >= ATR(14) x multiplier (default 2.0)
  Filters out average volatility, keeps only significant momentum.

  Wick-to-range ratio below threshold (default 30%)
  A large wick relative to range signals indecision, not displacement.
  Formula: (High - Close) / Range for bulls,
           (Close - Low)  / Range for bears.

  Optional volume filter: Volume > SMA(20) x 1.5
  Confirms institutional participation behind the move.
  Disable for spot Forex where tick volume is unreliable.

Displacement candles are the primary FVG trigger — the gap left behind
a displacement candle is the highest-quality FVG to trade.


[4] INDUCEMENT (IDM)

Inducement is how institutions engineer a false breakout to grab
retail stop-loss liquidity before reversing price the other way.

Detected when price temporarily sweeps beyond a recent swing high or
low and then closes back inside the range. An ATR-based wick filter
ensures only meaningful sweeps qualify — micro-breakouts are excluded.

Bear Trap: price sweeps below a recent low and closes above it.
Bull Trap: price sweeps above a recent high and closes below it.

A 25-bar cooldown prevents label flooding in trending conditions.
The signal still feeds the ISD state machine on every bar regardless.


[5] ISD SEQUENCE STATE MACHINE

ISD stands for Inducement, Sweep, Displacement. This is the complete
3-step institutional setup that ICT traders look for before entering.

The module runs as a persistent state machine tracking progress
across bars in real time:

Score 1/3 — IDM confirmed. Liquidity has been grabbed.
Score 2/3 — A structural sweep of a 5-bar high or low confirmed.
Score 3/3 — A Displacement candle fires in the same direction.
            Label appears on chart. State resets automatically.

A 50-bar timeout resets the sequence if no follow-through occurs,
preventing stale signals from contaminating new setups.

ISD 3/3 is the single highest-confidence signal in this indicator.
All three institutional steps have completed in the correct order.

Dashboard shows live progress: Score 0 to 3 with block indicators.


[6] KILLZONES

ICT defines specific time windows where institutional order flow
is at its highest. The script highlights four of them:

London Open    02:00 - 05:00 New York time
New York Open  08:30 - 11:00 New York time
Asian Session  20:00 - 00:00 New York time
Silver Bullet  10:00 - 11:00 New York time

The Silver Bullet is a specific 1-hour ICT window occurring inside
the New York session — considered one of the highest-probability
entry windows in the entire ICT model.

Killzones are automatically hidden on timeframes 4H and above.


[7] LIVE HUD DASHBOARD

[image]https://www.tradingview.com/x/jwXuHnjV/[/image]

A real-time panel in the bottom-left corner aggregates all modules:

Zone   current price position (PREMIUM / DISCOUNT / EQ)
with gradient background that shifts green to red
EQ Level    exact equilibrium price of the current dealing range
Bull FVG    count of active non-inverted bullish gaps
Bear FVG    count of active non-inverted bearish gaps
BPR         whether a Balanced Price Range is currently active
Displace    direction of the most recent displacement candle
IDM         most recent trap type — Bear Trap / Bull Trap / None
ISD Score   live block progress from 0/3 to 3/3
ATR (14)    current ATR value
Timeframe   active chart timeframe


█  HOW TO USE

Recommended workflow for intraday setups on 1m to 1H timeframes.

Step 1
Check the dashboard Zone. If PREMIUM, look for short setups only.
If DISCOUNT, look for long setups only. Never trade against the zone.

Step 2
Wait for an IDM label. This confirms retail stop-loss liquidity has
been swept in the direction you are looking to trade.

Step 3
Watch the ISD score reach 2/3 — a structural sweep is confirmed in
the same direction as the IDM.

Step 4
When a Displacement candle fires and ISD reaches 3/3, the complete
institutional sequence is confirmed. This is the entry trigger.

Step 5
Enter on a retest of the FVG left by the displacement candle.
For the highest-precision entry, wait for price to reach the OTE
zone within the FVG (61.8%–78.6% retracement level).

Step 6
Use Killzones to time entries. Highest-probability window is the
Silver Bullet (10:00–11:00 NY). London and NY Open are second.

For higher timeframe analysis on 4H and Daily: use Premium/Discount
zones and swing structure only. Ignore Killzones and FVG entries.


█  SETTINGS GUIDE

Fair Value Gaps
Min FVG Size (ATR mult)   raise to filter weak gaps, 0 shows all
Max FVGs to Show          limits drawn gaps, default 5
Show CE Midline           shows the 50% Consequent Encroachment level
Show Inverted FVG         recolors box when price passes through fully
Show BPR                  draws overlap zone between bull and bear FVGs

PD Arrays
Swing Detection Length    longer lookback gives bigger dealing ranges
Show OTE Zones            draws the Fibonacci entry zones
Show Equilibrium Line     draws the 50% midpoint with price label

Displacement
Body Size (x ATR)         momentum threshold, raise for stronger signals
Max Wick/Range Ratio      lower value requires cleaner committed candles
Volume Filter             disable for Forex, enable for stocks/futures

Inducement
IDM Lookback Bars         how far back to find the reference high/low
Min Wick Size (x ATR)     raise to filter micro false-breakouts

ISD Sequence
Min Score to Show Label   set to 3 to see only complete 3/3 setups

Killzones
Each session can be toggled independently.


█  ALERTS

Bullish FVG Formed
Bearish FVG Formed
Bullish Displacement — check for FVG entry
Bearish Displacement — check for FVG entry
Full ISD Sequence (3/3) — high-probability setup complete
Bullish Inducement (IDM) — Bear Trap detected
Bearish Inducement (IDM) — Bull Trap detected


█  TECHNICAL NOTES

All ta.* function calls — ATR, SMA, pivot highs/lows, highest, lowest —
are executed unconditionally at the top script level in compliance with
the Pine Script v6 execution model. Never inside conditionals or
functions called conditionally.

FVG detection is locked to barstate.isconfirmed with a [1] bar offset.
The current live bar never creates a new FVG box. No repainting.

The ISD state machine uses persistent var variables with inline
assignment in the main execution body. Pine v6 does not allow global
variable reassignment inside functions, so the state machine runs
directly in the main script scope with a 50-bar timeout guard.


█  DISCLAIMER

This indicator is provided for educational and informational purposes
only. It does not constitute financial advice or a recommendation to
buy or sell any financial instrument. Past performance of any trading
concept or signal is not indicative of future results. All trading
involves risk. You are solely responsible for your own trading decisions.
Always use proper risk management.

© LunqFX

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © LunqFX

//@version=6
indicator(
    title         = "ICT PD Arrays [LunqFX] — Fair Value Gaps, Displacement & Premium/Discount Zones",
    shorttitle    = "PD Arrays",
    overlay       = true,
    max_bars_back = 500,
    max_boxes_count   = 300,
    max_lines_count   = 300,
    max_labels_count  = 200
)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

show_fvg        = input.bool(true,  "Show FVGs",                        group="Fair Value Gaps")
fvg_atr_mult    = input.float(0.1,  "Min FVG Size (ATR multiplier)",    group="Fair Value Gaps", step=0.05, minval=0, tooltip="FVG will only be drawn if its size >= ATR(14) x this multiplier")
show_ce         = input.bool(true,  "Show CE Midline",                  group="Fair Value Gaps", tooltip="Consequent Encroachment — midpoint of the FVG zone")
show_ifvg       = input.bool(true,  "Show Inverted FVG",                group="Fair Value Gaps", tooltip="When price fully passes through a FVG it becomes an Inversion FVG")
show_bpr        = input.bool(true,  "Show Balanced Price Range (BPR)",  group="Fair Value Gaps", tooltip="Spatial overlap between the most recent bullish and bearish FVG")
fvg_max_count   = input.int(5,      "Max FVGs to Show",                 group="Fair Value Gaps", minval=1, maxval=20)

show_pd         = input.bool(true,  "Show Premium/Discount Zones",      group="PD Arrays / Zones")
show_ote        = input.bool(true,  "Show OTE Zones (62-79%)",          group="PD Arrays / Zones", tooltip="Optimal Trade Entry zones based on Fibonacci levels")
swing_len       = input.int(10,     "Swing Detection Length",           group="PD Arrays / Zones", minval=3, maxval=50)
show_eq         = input.bool(true,  "Show Equilibrium Line",            group="PD Arrays / Zones", tooltip="50% midpoint of the current swing range")

show_disp       = input.bool(true,  "Show Displacement",                group="Displacement")
disp_mult       = input.float(2.0,  "Body Size (x ATR)",                group="Displacement", step=0.1, minval=0.5, tooltip="Candle body must be >= ATR(14) x this value")
disp_wick_ratio = input.float(0.3,  "Max Wick/Range Ratio",             group="Displacement", step=0.05, tooltip="Upper/lower wick must not exceed this fraction of total range")
disp_vol_filter = input.bool(true,  "Volume Filter",                    group="Displacement", tooltip="Require volume > 1.5x SMA(20) to confirm displacement")

show_idm        = input.bool(true,  "Show Inducement",                  group="Inducement (IDM)")
idm_period      = input.int(5,      "IDM Lookback Bars",                group="Inducement (IDM)", minval=2, maxval=20, tooltip="Number of bars used to detect false breakout traps")
idm_wick_mult   = input.float(0.3,  "Min Wick Size (x ATR)",            group="Inducement (IDM)", step=0.05, minval=0.0, tooltip="Wick beyond the level must be >= this multiple of ATR to qualify as IDM")

show_isd        = input.bool(true,  "Show ISD Score Labels",            group="ISD Sequence")
isd_min_score   = input.int(3,      "Min Score to Show Label (0-3)",    group="ISD Sequence", minval=0, maxval=3)

show_killzones  = input.bool(true,  "Show Killzones",                   group="Killzones")
show_london     = input.bool(true,  "London (02:00-05:00 NY)",          group="Killzones")
show_ny         = input.bool(true,  "New York (08:30-11:00 NY)",        group="Killzones")
show_asian      = input.bool(true,  "Asian (20:00-00:00 NY)",           group="Killzones")
show_silver     = input.bool(true,  "Silver Bullet (10:00-11:00 NY)",   group="Killzones")

show_hud        = input.bool(true,  "Show Dashboard",                   group="Dashboard")

// --- Candle Coloring ---
show_candle_grad  = input.bool(true,   "Gradient Candle Coloring",         group="Candle Coloring", tooltip="Color each candle by its position in the current swing range: Discount = bull color, Premium = bear color")
col_candle_bull   = input.color(color.new(#5CF0D7, 0),  "Discount Color",  group="Candle Coloring", tooltip="Candle color when price is deep in discount zone")
col_candle_bear   = input.color(color.new(#B32AC3, 0),  "Premium Color",   group="Candle Coloring", tooltip="Candle color when price is deep in premium zone")

col_bull_fvg      = input.color(color.rgb(41,  98,  255, 75),  "Bullish FVG",        group="Colors")
col_bear_fvg      = input.color(color.rgb(255, 82,  82,  75),  "Bearish FVG",        group="Colors")
col_ifvg_bull     = input.color(color.rgb(41,  98,  255, 88),  "Inversion FVG Bull", group="Colors")
col_ifvg_bear     = input.color(color.rgb(255, 82,  82,  88),  "Inversion FVG Bear", group="Colors")
col_bpr           = input.color(color.rgb(255, 215, 0,   70),  "BPR Zone",           group="Colors")
col_premium       = input.color(color.rgb(255, 82,  82,  92),  "Premium Zone",       group="Colors")
col_discount      = input.color(color.rgb(76,  175, 80,  92),  "Discount Zone",      group="Colors")
col_ote_buy       = input.color(color.rgb(76,  175, 80,  80),  "OTE Buy Zone",       group="Colors")
col_ote_sell      = input.color(color.rgb(255, 82,  82,  80),  "OTE Sell Zone",      group="Colors")
col_eq_line       = input.color(color.rgb(255, 215, 0,   0),   "Equilibrium Line",   group="Colors")
col_displacement  = input.color(color.rgb(255, 235, 59,  0),   "Displacement Label", group="Colors")
col_inducement    = input.color(color.rgb(156, 39,  176, 0),   "Inducement Label",   group="Colors")
col_london        = input.color(color.rgb(33,  150, 243, 93),  "London Killzone",    group="Colors")
col_ny_col        = input.color(color.rgb(76,  175, 80,  93),  "NY Killzone",        group="Colors")
col_asian         = input.color(color.rgb(120, 120, 120, 93),  "Asian Session",      group="Colors")
col_silver_bullet = input.color(color.rgb(255, 215, 0,   88),  "Silver Bullet",      group="Colors")
col_hud_bg        = input.color(color.rgb(13,  17,  23,  15),  "HUD Background",     group="Colors")
col_hud_border    = input.color(color.rgb(41,  98,  255, 60),  "HUD Border",         group="Colors")

// ═══════════════════════════════════════════════════════════════════════════════
// SERIES — all ta.* calls at top level, unconditional, every bar.
// Rule: ta.* must NEVER appear inside conditionals or inside functions that are
// called conditionally. Pre-compute everything here and pass as plain variables.
// ═══════════════════════════════════════════════════════════════════════════════

atr14       = ta.atr(14)
vol_sma20   = ta.sma(volume, 20)
idm_lo_ref  = ta.lowest(low,   idm_period)[1]
idm_hi_ref  = ta.highest(high, idm_period)[1]
sweep_lo5   = ta.lowest(low,   5)[1]
sweep_hi5   = ta.highest(high, 5)[1]
pivot_high  = ta.pivothigh(high, swing_len, swing_len)
pivot_low   = ta.pivotlow(low,   swing_len, swing_len)
// 50-bar high/low for candle gradient — tighter range = visible color shifts bar-to-bar
cg_hi50     = ta.highest(high, 50)
cg_lo50     = ta.lowest(low,  50)

// ═══════════════════════════════════════════════════════════════════════════════
// UTILITY
// ═══════════════════════════════════════════════════════════════════════════════

f_get_session(session_str) =>
    not na(time(timeframe.period, session_str, "America/New_York"))

f_progress_bar(val, max_val, chars) =>
    filled = math.round(val / max_val * chars)
    bar    = ""
    for i = 0 to chars - 1
        bar += i < filled ? "|" : "."
    bar

// ═══════════════════════════════════════════════════════════════════════════════
// FVG ENGINE
// ═══════════════════════════════════════════════════════════════════════════════

// Detects FVGs on confirmed 3-candle structures using [1] offset (bar[0] never touched).
// ATR filter uses pre-computed atr14 from outer scope — no internal ta.* call.
f_detect_fvg() =>
    bull_top    = low[1]
    bull_bottom = high[3]
    bull_ce     = (bull_top + bull_bottom) / 2
    is_bull     = bull_top > bull_bottom and (bull_top - bull_bottom) >= atr14 * fvg_atr_mult

    bear_top    = low[3]
    bear_bottom = high[1]
    bear_ce     = (bear_top + bear_bottom) / 2
    is_bear     = bear_top > bear_bottom and (bear_top - bear_bottom) >= atr14 * fvg_atr_mult

    [is_bull, is_bear, bull_top, bull_bottom, bull_ce, bear_top, bear_bottom, bear_ce]

var box[]   fvg_boxes     = array.new_box()
var line[]  fvg_ces       = array.new_line()
var bool[]  fvg_is_bull   = array.new_bool()
var float[] fvg_tops      = array.new_float()
var float[] fvg_bots      = array.new_float()
var float[] fvg_ce_vals   = array.new_float()
var bool[]  fvg_mitigated = array.new_bool()
var bool[]  fvg_inverted  = array.new_bool()

var float last_bull_top = na
var float last_bull_bot = na
var float last_bear_top = na
var float last_bear_bot = na
var box   bpr_box       = na

f_draw_fvg(is_bull, top, bottom, ce) =>
    box_col = is_bull ? col_bull_fvg : col_bear_fvg
    b = box.new(bar_index - 3, top, bar_index - 1, bottom,
                bgcolor=box_col, border_color=box_col, border_width=1, extend=extend.right)
    ce_col = is_bull ? color.new(col_bull_fvg, 20) : color.new(col_bear_fvg, 20)
    c = show_ce ? line.new(bar_index - 3, ce, bar_index - 1, ce,
                           color=ce_col, style=line.style_dashed, extend=extend.right) : na
    if array.size(fvg_boxes) >= fvg_max_count
        box.delete(array.shift(fvg_boxes))
        old_c = array.shift(fvg_ces)
        if not na(old_c)
            line.delete(old_c)
        array.shift(fvg_is_bull)
        array.shift(fvg_tops)
        array.shift(fvg_bots)
        array.shift(fvg_ce_vals)
        array.shift(fvg_mitigated)
        array.shift(fvg_inverted)
    array.push(fvg_boxes,     b)
    array.push(fvg_ces,       c)
    array.push(fvg_is_bull,   is_bull)
    array.push(fvg_tops,      top)
    array.push(fvg_bots,      bottom)
    array.push(fvg_ce_vals,   ce)
    array.push(fvg_mitigated, false)
    array.push(fvg_inverted,  false)

// Guards with if sz > 0 — in Pine Script, for i = 0 to -1 executes the body once,
// causing array.get on an empty array to throw a runtime error.
f_update_fvg_status() =>
    sz = array.size(fvg_boxes)
    if sz > 0
        for i = 0 to sz - 1
            if array.get(fvg_inverted, i)
                continue
            is_bull   = array.get(fvg_is_bull, i)
            top_v     = array.get(fvg_tops,    i)
            bot_v     = array.get(fvg_bots,    i)
            ce_v      = array.get(fvg_ce_vals, i)
            b         = array.get(fvg_boxes,   i)
            mitigated = is_bull ? close <= ce_v : close >= ce_v
            inv       = is_bull ? close <  bot_v : close > top_v
            if inv
                if show_ifvg
                    ifvg_col = is_bull ? col_ifvg_bull : col_ifvg_bear
                    box.set_bgcolor(b,      ifvg_col)
                    box.set_border_color(b, ifvg_col)
                array.set(fvg_inverted, i, true)
            else if mitigated
                muted = is_bull ? color.new(col_bull_fvg, 92) : color.new(col_bear_fvg, 92)
                box.set_bgcolor(b, muted)
                array.set(fvg_mitigated, i, true)

// ═══════════════════════════════════════════════════════════════════════════════
// BPR
// ═══════════════════════════════════════════════════════════════════════════════

f_check_bpr() =>
    has_both = not na(last_bull_top) and not na(last_bear_top)
    overlaps = has_both and last_bull_top >= last_bear_bot and last_bull_bot <= last_bear_top
    top_val  = overlaps ? math.min(last_bull_top, last_bear_top) : na
    bot_val  = overlaps ? math.max(last_bull_bot, last_bear_bot) : na
    [overlaps, top_val, bot_val]

// ═══════════════════════════════════════════════════════════════════════════════
// PD ARRAYS ENGINE
// ═══════════════════════════════════════════════════════════════════════════════

f_calc_pd_levels(sh, sl) =>
    rng          = sh - sl
    eq           = sl + rng * 0.5
    // ICT OTE logic (Fibonacci retracement of the swing):
    // OTE Buy  — price retraces 62-79% DOWN from swing high → sits at 21-38% from swing low → DISCOUNT zone
    // OTE Sell — price retraces 62-79% UP   from swing low  → sits at 62-79% from swing low → PREMIUM zone
    ote_buy_top  = sl + rng * 0.382   // 38.2% from low  (= 61.8% retracement from high)
    ote_buy_bot  = sl + rng * 0.214   // 21.4% from low  (= 78.6% retracement from high)
    ote_sell_top = sl + rng * 0.786   // 78.6% from low  (= 21.4% retracement from low  / deep premium)
    ote_sell_bot = sl + rng * 0.618   // 61.8% from low  (= 38.2% retracement from low)
    [eq, ote_buy_top, ote_buy_bot, ote_sell_top, ote_sell_bot]

f_get_price_zone(price, eq) =>
    price > eq ? "PREMIUM" : price < eq ? "DISCOUNT" : "EQ"

// PD objects stored in arrays — array.push/clear are reference-type mutations,
// allowed inside functions in Pine v6 (no := on global scalar vars needed).
var box[]   pd_boxes  = array.new_box()
var line[]  pd_lines  = array.new_line()
var label[] pd_labels = array.new_label()

f_draw_pd_zones(sh, sl, eq, ote_buy_top, ote_buy_bot, ote_sell_top, ote_sell_bot) =>
    for b in pd_boxes
        box.delete(b)
    array.clear(pd_boxes)
    for l in pd_lines
        line.delete(l)
    array.clear(pd_lines)
    for lbl in pd_labels
        label.delete(lbl)
    array.clear(pd_labels)

    pivot = bar_index - swing_len
    array.push(pd_boxes, box.new(pivot, sh, pivot, eq,
                                 bgcolor=col_premium,  border_color=color.new(col_premium,  60), extend=extend.right))
    array.push(pd_boxes, box.new(pivot, eq, pivot, sl,
                                 bgcolor=col_discount, border_color=color.new(col_discount, 60), extend=extend.right))
    if show_ote
        array.push(pd_boxes, box.new(pivot, ote_buy_top,  pivot, ote_buy_bot,
                                     bgcolor=col_ote_buy,  border_color=color.new(col_ote_buy,  40), extend=extend.right))
        array.push(pd_boxes, box.new(pivot, ote_sell_top, pivot, ote_sell_bot,
                                     bgcolor=col_ote_sell, border_color=color.new(col_ote_sell, 40), extend=extend.right))
    if show_eq
        array.push(pd_lines, line.new(pivot, eq, pivot, eq,
                                      color=col_eq_line, style=line.style_dashed, width=2, extend=extend.right))
        array.push(pd_labels, label.new(pivot + 1, eq, "EQ 50%",
                                        style    = label.style_label_right,
                                        color    = color.rgb(30, 25, 5, 0),
                                        textcolor= color.rgb(255, 215, 0),
                                        size     = size.small))
    // PREMIUM SELL — solid dark-red background, white text, clearly readable
    array.push(pd_labels, label.new(pivot + 1, (sh + eq) / 2, "PREMIUM  SELL",
                                    style    = label.style_label_right,
                                    color    = color.rgb(100, 15, 15, 0),
                                    textcolor= color.rgb(255, 180, 180),
                                    size     = size.small))
    // DISCOUNT BUY — solid dark-green background, white text
    array.push(pd_labels, label.new(pivot + 1, (eq + sl) / 2, "DISCOUNT  BUY",
                                    style    = label.style_label_right,
                                    color    = color.rgb(10, 70, 25, 0),
                                    textcolor= color.rgb(150, 255, 180),
                                    size     = size.small))

// ═══════════════════════════════════════════════════════════════════════════════
// DISPLACEMENT ENGINE
// Reads pre-computed atr14 and vol_sma20 from outer scope — no ta.* calls inside.
// ═══════════════════════════════════════════════════════════════════════════════

f_detect_displacement() =>
    body     = math.abs(close - open)
    rng      = high - low
    safe_rng = rng == 0 ? 0.0001 : rng
    vol_ok   = disp_vol_filter ? volume > vol_sma20 * 1.5 : true
    is_bull  = close > open
               and body >= atr14 * disp_mult
               and (high - close) / safe_rng <= disp_wick_ratio
               and vol_ok
    is_bear  = close < open
               and body >= atr14 * disp_mult
               and (close - low) / safe_rng <= disp_wick_ratio
               and vol_ok
    [is_bull, is_bear]

// ═══════════════════════════════════════════════════════════════════════════════
// INDUCEMENT ENGINE
// Reads pre-computed idm_lo_ref / idm_hi_ref from outer scope — no ta.* inside.
// ═══════════════════════════════════════════════════════════════════════════════

f_detect_inducement() =>
    // Wick size below/above the reference level must clear the ATR threshold.
    // This filters micro-breakouts that fire on nearly every bar.
    bull_wick = idm_lo_ref - low   // how far below the prev low the wick went
    bear_wick = high - idm_hi_ref  // how far above the prev high the wick went
    min_wick  = atr14 * idm_wick_mult
    is_bull_idm = low  < idm_lo_ref and close > idm_lo_ref and bull_wick >= min_wick
    is_bear_idm = high > idm_hi_ref and close < idm_hi_ref and bear_wick >= min_wick
    [is_bull_idm, is_bear_idm]

// ═══════════════════════════════════════════════════════════════════════════════
// ISD SEQUENCE STATE
// ═══════════════════════════════════════════════════════════════════════════════

var int  isd_score       = 0
var bool idm_confirmed   = false
var bool sweep_confirmed = false
var bool disp_confirmed  = false
var bool isd_bull_dir    = false
var int  isd_start_bar   = 0
var int  prev_isd_score  = 0

// ═══════════════════════════════════════════════════════════════════════════════
// HUD DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════

// Linear gradient between two colors at a given ratio [0..1]
f_grad(ratio, col_a, col_b) =>
    r = int(color.r(col_a) + (color.r(col_b) - color.r(col_a)) * ratio)
    g = int(color.g(col_a) + (color.g(col_b) - color.g(col_a)) * ratio)
    b = int(color.b(col_a) + (color.b(col_b) - color.b(col_a)) * ratio)
    color.rgb(r, g, b)

// border_width=0 removes the ugly vertical divider line between columns.
// frame_width=1 keeps the clean outer border.
var table hud = table.new(
     position     = position.bottom_left,
     columns      = 2,
     rows         = 17,
     bgcolor      = color.rgb(6, 8, 16, 5),
     border_color = color.rgb(255, 255, 255, 100),
     border_width = 0,
     frame_color  = color.rgb(41, 98, 255, 45),
     frame_width  = 1)

// Draws a label cell (left) and value cell (right) with independent backgrounds
f_hud_cell(row, lbl, val, lbl_bg, val_bg, lbl_col, val_col, val_sz) =>
    table.cell(hud, 0, row, "  " + lbl,
               text_color=lbl_col, text_size=size.small,
               bgcolor=lbl_bg, text_halign=text.align_left)
    table.cell(hud, 1, row, val + "  ",
               text_color=val_col, text_size=val_sz,
               bgcolor=val_bg, text_halign=text.align_right)

f_update_hud(zone, eq_level, bull_cnt, bear_cnt,
             has_disp, disp_is_bull, bull_idm, bear_idm,
             score, session_str, atr_val, has_bpr) =>

    // ── Palette ─────────────────────────────────────────────────────────────
    wht  = color.rgb(215, 220, 235)
    grn  = color.rgb(50,  210, 100)
    red  = color.rgb(255, 70,  70)
    gld  = color.rgb(255, 205, 0)
    blu  = color.rgb(70,  140, 255)
    purp = color.rgb(185, 75,  240)
    orng = color.rgb(255, 155, 30)
    dim  = color.rgb(75,  82,  105)

    // Base backgrounds
    bg_base = color.rgb(8, 10, 20, 5)
    bg_alt  = color.rgb(12, 15, 28, 5)

    // ── Row 0 — Header ───────────────────────────────────────────────────────
    hdr_bg = color.rgb(15, 20, 45, 5)
    table.cell(hud, 0, 0, "  ICT PD ARRAYS",
               text_color=blu, text_size=size.normal,
               bgcolor=hdr_bg, text_halign=text.align_left)
    table.cell(hud, 1, 0, "LunqFX  ",
               text_color=color.rgb(55, 65, 105), text_size=size.small,
               bgcolor=hdr_bg, text_halign=text.align_right)

    // ── Row 1 — ZONE (gradient background: green↔red based on zone) ──────────
    z_ratio   = zone == "PREMIUM" ? 1.0 : zone == "DISCOUNT" ? 0.0 : 0.5
    z_lbl_bg  = f_grad(z_ratio, color.rgb(10, 30, 15, 5), color.rgb(35, 10, 10, 5))
    z_val_bg  = f_grad(z_ratio, color.rgb(15, 50, 20, 5), color.rgb(55, 12, 12, 5))
    z_col     = zone == "PREMIUM" ? red : zone == "DISCOUNT" ? grn : gld
    f_hud_cell(1, "Zone", zone, z_lbl_bg, z_val_bg, dim, z_col, size.normal)

    // ── Row 2 — EQ Level ─────────────────────────────────────────────────────
    f_hud_cell(2, "EQ Level",
               str.format("{0,number,#.##}", eq_level),
               bg_base, bg_alt, dim, gld, size.normal)

    // ── Row 3 — Session ──────────────────────────────────────────────────────
    sess_bg = color.rgb(10, 12, 25, 5)
    f_hud_cell(3, "Session", session_str, bg_alt, bg_base, dim, wht, size.small)

    // ── Row 4 — Thin divider ─────────────────────────────────────────────────
    div_bg = color.rgb(20, 25, 50, 10)
    table.cell(hud, 0, 4, "", bgcolor=div_bg, text_size=size.tiny, text_color=dim)
    table.cell(hud, 1, 4, "", bgcolor=div_bg, text_size=size.tiny, text_color=dim)

    // ── Rows 5-7 — FVG (gradient bg intensity based on count) ────────────────
    bull_ratio = bull_cnt > 0 ? math.min(bull_cnt / 5.0, 1.0) : 0.0
    bull_lbg   = f_grad(bull_ratio, bg_base, color.rgb(8,  18, 45, 5))
    bull_vbg   = f_grad(bull_ratio, bg_alt,  color.rgb(12, 28, 65, 5))
    bull_col   = bull_cnt > 0 ? blu : dim
    f_hud_cell(5, "Bull FVG",
               str.tostring(bull_cnt) + " active",
               bull_lbg, bull_vbg, dim, bull_col, size.normal)

    bear_ratio = bear_cnt > 0 ? math.min(bear_cnt / 5.0, 1.0) : 0.0
    bear_lbg   = f_grad(bear_ratio, bg_base, color.rgb(40, 8,  8,  5))
    bear_vbg   = f_grad(bear_ratio, bg_alt,  color.rgb(60, 10, 10, 5))
    bear_col   = bear_cnt > 0 ? red : dim
    f_hud_cell(6, "Bear FVG",
               str.tostring(bear_cnt) + " active",
               bear_lbg, bear_vbg, dim, bear_col, size.normal)

    bpr_lbg = has_bpr ? color.rgb(35, 28, 5, 5)  : bg_alt
    bpr_vbg = has_bpr ? color.rgb(50, 40, 5, 5)  : bg_base
    bpr_col = has_bpr ? gld : dim
    f_hud_cell(7, "BPR",
               has_bpr ? "Active" : "None",
               bpr_lbg, bpr_vbg, dim, bpr_col, size.small)

    // ── Row 8 — Thin divider ─────────────────────────────────────────────────
    table.cell(hud, 0, 8, "", bgcolor=div_bg, text_size=size.tiny, text_color=dim)
    table.cell(hud, 1, 8, "", bgcolor=div_bg, text_size=size.tiny, text_color=dim)

    // ── Rows 9-11 — Signals ───────────────────────────────────────────────────
    d_ratio = has_disp ? 1.0 : 0.0
    d_base  = disp_is_bull ? color.rgb(8, 30, 12, 5) : color.rgb(30, 8, 8, 5)
    d_val   = disp_is_bull ? color.rgb(12, 45, 18, 5) : color.rgb(45, 10, 10, 5)
    d_lbg   = has_disp ? d_base : bg_base
    d_vbg   = has_disp ? d_val  : bg_alt
    d_col   = has_disp ? (disp_is_bull ? grn : red) : dim
    d_str   = has_disp ? (disp_is_bull ? "Bullish" : "Bearish") : "None"
    f_hud_cell(9, "Displacement", d_str, d_lbg, d_vbg, dim, d_col, size.normal)

    idm_active = bull_idm or bear_idm
    idm_lbg    = idm_active ? color.rgb(30, 8, 40, 5)  : bg_alt
    idm_vbg    = idm_active ? color.rgb(45, 12, 58, 5) : bg_base
    idm_col    = idm_active ? purp : dim
    idm_str    = bull_idm ? "Bear Trap" : bear_idm ? "Bull Trap" : "None"
    f_hud_cell(10, "IDM", idm_str, idm_lbg, idm_vbg, dim, idm_col, size.normal)

    // ISD Score — label cell: name + numeric score
    //             value cell: 3 large filled/empty blocks at size.large
    // Blocks use █ (full) and ░ (light shade) — both render reliably in TradingView.
    // Each block represents one completed ISD step: IDM / Sweep / Displacement.
    isd_ratio  = score / 3.0
    isd_lbg    = f_grad(isd_ratio, color.rgb(12, 12, 20, 5), color.rgb(5,  40, 18, 5))
    isd_vbg    = f_grad(isd_ratio, color.rgb(16, 16, 28, 5), color.rgb(8,  60, 25, 5))
    isd_col    = score == 3 ? grn : score >= 1 ? orng : dim
    blk_1      = score >= 1 ? "█" : "░"
    blk_2      = score >= 2 ? "█" : "░"
    blk_3      = score >= 3 ? "█" : "░"
    isd_blocks = blk_1 + "  " + blk_2 + "  " + blk_3
    // Label cell shows "ISD  2/3", value cell shows the large blocks
    table.cell(hud, 0, 11, "  ISD  " + str.tostring(score) + "/3",
               text_color=isd_col, text_size=size.small,
               bgcolor=isd_lbg, text_halign=text.align_left)
    table.cell(hud, 1, 11, isd_blocks + "  ",
               text_color=isd_col, text_size=size.large,
               bgcolor=isd_vbg, text_halign=text.align_right)

    // ── Row 12 — Thin divider ─────────────────────────────────────────────────
    table.cell(hud, 0, 12, "", bgcolor=div_bg, text_size=size.tiny, text_color=dim)
    table.cell(hud, 1, 12, "", bgcolor=div_bg, text_size=size.tiny, text_color=dim)

    // ── Rows 13-16 — Info ────────────────────────────────────────────────────
    f_hud_cell(13, "ATR (14)",   str.format("{0,number,#.##}", atr_val), bg_base, bg_alt, dim, dim, size.small)
    f_hud_cell(14, "Timeframe",  timeframe.period,                       bg_alt, bg_base, dim, dim, size.small)

    // Padding rows (keep bottom frame clean)
    table.cell(hud, 0, 15, "", bgcolor=bg_base, text_size=size.tiny, text_color=dim)
    table.cell(hud, 1, 15, "", bgcolor=bg_base, text_size=size.tiny, text_color=dim)
    table.cell(hud, 0, 16, "", bgcolor=bg_base, text_size=size.tiny, text_color=dim)
    table.cell(hud, 1, 16, "", bgcolor=bg_base, text_size=size.tiny, text_color=dim)

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN EXECUTION
// All detections are called unconditionally (top-level) before any conditionals.
// Results are then used inside if-blocks — never the function calls themselves.
// ═══════════════════════════════════════════════════════════════════════════════

is_lt_4h = timeframe.in_seconds() < timeframe.in_seconds("240")

// ── Detection (unconditional — all ta.* already at top of script) ────────────
[is_bull_fvg, is_bear_fvg,
 bull_fvg_top, bull_fvg_bot, bull_fvg_ce,
 bear_fvg_top, bear_fvg_bot, bear_fvg_ce] = f_detect_fvg()

[raw_bull_disp, raw_bear_disp] = f_detect_displacement()

[is_bull_idm, is_bear_idm] = f_detect_inducement()

// ── FVG drawing & state ───────────────────────────────────────────────────────
if barstate.isconfirmed
    if show_fvg
        if is_bull_fvg
            f_draw_fvg(true,  bull_fvg_top, bull_fvg_bot, bull_fvg_ce)
        if is_bear_fvg
            f_draw_fvg(false, bear_fvg_top, bear_fvg_bot, bear_fvg_ce)

    if is_bull_fvg
        last_bull_top := bull_fvg_top
        last_bull_bot := bull_fvg_bot
    if is_bear_fvg
        last_bear_top := bear_fvg_top
        last_bear_bot := bear_fvg_bot

    if show_fvg and show_bpr and (is_bull_fvg or is_bear_fvg)
        [bpr_a, bpr_t, bpr_b] = f_check_bpr()
        box.delete(bpr_box)
        bpr_box := bpr_a ? box.new(bar_index - 3, bpr_t, bar_index - 1, bpr_b,
                                   bgcolor=col_bpr, border_color=col_bpr, extend=extend.right) : na

    f_update_fvg_status()

bpr_active = not na(bpr_box)

var int active_bull_fvg = 0
var int active_bear_fvg = 0
if barstate.islast
    active_bull_fvg := 0
    active_bear_fvg := 0
    sz_fvg = array.size(fvg_boxes)
    if sz_fvg > 0
        for i = 0 to sz_fvg - 1
            if not array.get(fvg_inverted, i)
                if array.get(fvg_is_bull, i)
                    active_bull_fvg += 1
                else
                    active_bear_fvg += 1

// ── PD Arrays ─────────────────────────────────────────────────────────────────
var float saved_sh = na
var float saved_sl = na
sh_changed = not na(pivot_high) and pivot_high != saved_sh
sl_changed = not na(pivot_low)  and pivot_low  != saved_sl
if not na(pivot_high)
    saved_sh := pivot_high
if not na(pivot_low)
    saved_sl := pivot_low

var float current_eq = na
if barstate.isconfirmed and (sh_changed or sl_changed) and not na(saved_sh) and not na(saved_sl)
    [eq_v, obt, obb, ost, osb] = f_calc_pd_levels(saved_sh, saved_sl)
    current_eq := eq_v
    if show_pd
        f_draw_pd_zones(saved_sh, saved_sl, eq_v, obt, obb, ost, osb)

price_zone = not na(current_eq) ? f_get_price_zone(close, current_eq) : "N/A"

// ── Displacement ──────────────────────────────────────────────────────────────
// raw_bull_disp / raw_bear_disp are computed unconditionally above.
// We commit them to persistent vars only on confirmed bars.
var bool is_bull_disp = false
var bool is_bear_disp = false
if barstate.isconfirmed
    is_bull_disp := raw_bull_disp
    is_bear_disp := raw_bear_disp
    if show_disp
        if is_bull_disp
            // Bullish displacement — bright teal label above candle, large and readable
            label.new(bar_index, high + atr14 * 0.6, "DISP",
                      style    = label.style_label_down,
                      color    = color.new(#5CF0D7, 5),
                      textcolor= color.rgb(5, 15, 25),
                      size     = size.normal)
        if is_bear_disp
            // Bearish displacement — magenta label below candle
            label.new(bar_index, low - atr14 * 0.6, "DISP",
                      style    = label.style_label_up,
                      color    = color.new(#B32AC3, 5),
                      textcolor= color.white,
                      size     = size.normal)

// ── Gradient candle coloring ──────────────────────────────────────────────────
// Uses the 50-bar high/low range so the gradient shifts visibly from bar to bar.
// The swing range (saved_sh/saved_sl) is too wide — price barely moves in it.
// cg_hi50 / cg_lo50 are pre-computed in the SERIES section (unconditional).
var color candle_grad_col = na
if show_candle_grad
    cg_rng = cg_hi50 - cg_lo50
    cg_ratio = cg_rng > 0 ? math.max(0.0, math.min((close - cg_lo50) / cg_rng, 1.0)) : 0.5
    candle_grad_col := f_grad(cg_ratio, col_candle_bull, col_candle_bear)

final_candle_col = show_disp and is_bull_disp ? color.new(#5CF0D7, 0) :
                   show_disp and is_bear_disp ? color.new(#B32AC3, 0) :
                   show_candle_grad           ? candle_grad_col        :
                   close >= open              ? color.new(#5CF0D7, 0)  :
                                               color.new(#B32AC3, 0)

plotcandle(open, high, low, close,
     title       = "Candles",
     color       = final_candle_col,
     wickcolor   = final_candle_col,
     bordercolor = final_candle_col)

// ── Inducement ────────────────────────────────────────────────────────────────
// Cooldown of 10 bars between IDM labels — prevents flooding on trending markets.
// The signal is still passed to the ISD state machine every bar regardless of the label cooldown.
var int last_idm_bar = -25
if show_idm and barstate.isconfirmed and (bar_index - last_idm_bar) >= 25
    if is_bull_idm
        label.new(bar_index, low - atr14 * 0.4, "IDM",
                  style    = label.style_label_up,
                  color    = color.new(#5CF0D7, 10),
                  textcolor= color.rgb(5, 15, 25),
                  size     = size.small)
        last_idm_bar := bar_index
    else if is_bear_idm
        label.new(bar_index, high + atr14 * 0.4, "IDM",
                  style    = label.style_label_down,
                  color    = color.new(#B32AC3, 10),
                  textcolor= color.white,
                  size     = size.small)
        last_idm_bar := bar_index

// ── ISD Sequence state machine ────────────────────────────────────────────────
// Inline in main body (cannot assign global vars inside functions in Pine v6).
// sweep_lo5 / sweep_hi5 pre-computed at top of script — no ta.* here.
if barstate.isconfirmed
    if disp_confirmed
        isd_score       := 0
        idm_confirmed   := false
        sweep_confirmed := false
        disp_confirmed  := false
        isd_bull_dir    := false

    if idm_confirmed and not disp_confirmed and (bar_index - isd_start_bar) > 50
        isd_score       := 0
        idm_confirmed   := false
        sweep_confirmed := false
        isd_bull_dir    := false

    if not idm_confirmed and (is_bull_idm or is_bear_idm)
        idm_confirmed := true
        isd_bull_dir  := is_bull_idm
        isd_score     := 1
        isd_start_bar := bar_index

    if idm_confirmed and not sweep_confirmed
        swept = isd_bull_dir ? low < sweep_lo5 : high > sweep_hi5
        if swept
            sweep_confirmed := true
            isd_score       := 2

    if sweep_confirmed and not disp_confirmed and (is_bull_disp or is_bear_disp)
        disp_confirmed := true
        isd_score      := 3

isd_just_reached = barstate.isconfirmed and isd_score >= isd_min_score and prev_isd_score < isd_min_score
if show_isd and isd_just_reached
    // ISD completion label — gradient teal→magenta based on score, large and prominent
    isd_lbl_col = isd_score == 3 ? color.new(#5CF0D7, 5) : color.new(#B32AC3, 20)
    isd_txt_col = isd_score == 3 ? color.rgb(5, 15, 25) : color.white
    label.new(bar_index, low - atr14 * 1.2,
              text     = "ISD  " + str.tostring(isd_score) + "/3",
              style    = label.style_label_up,
              color    = isd_lbl_col,
              textcolor= isd_txt_col,
              size     = size.large)
prev_isd_score := isd_score

// ── Killzones ─────────────────────────────────────────────────────────────────
is_london_kz = show_killzones and show_london and is_lt_4h and f_get_session("0200-0500")
is_ny_kz     = show_killzones and show_ny     and is_lt_4h and f_get_session("0830-1100")
is_asian_kz  = show_killzones and show_asian  and is_lt_4h and f_get_session("2000-0000")
is_sb_kz     = show_killzones and show_silver and is_lt_4h and f_get_session("1000-1100")

bgcolor(is_london_kz ? col_london        : na, title="London Killzone")
bgcolor(is_ny_kz     ? col_ny_col        : na, title="NY Killzone")
bgcolor(is_asian_kz  ? col_asian         : na, title="Asian Session")
bgcolor(is_sb_kz     ? col_silver_bullet : na, title="Silver Bullet")

// ── Session label ─────────────────────────────────────────────────────────────
session_lbl = f_get_session("1000-1100") ? "Silver Bullet" :
              f_get_session("0830-1100") ? "NY Open"       :
              f_get_session("1300-1600") ? "NY Close"      :
              f_get_session("0200-0500") ? "London Open"   :
              f_get_session("0500-0800") ? "London Close"  :
              f_get_session("2000-0000") ? "Asian"         : "Off-Hours"

// ── HUD ───────────────────────────────────────────────────────────────────────
if show_hud
    f_update_hud(
         price_zone,
         na(current_eq) ? 0.0 : current_eq,
         active_bull_fvg, active_bear_fvg,
         is_bull_disp or is_bear_disp, is_bull_disp,
         is_bull_idm, is_bear_idm,
         isd_score, session_lbl, atr14, bpr_active)

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(is_bull_fvg,    "Bullish FVG Formed",       "Bullish FVG detected on {{ticker}} {{interval}}")
alertcondition(is_bear_fvg,    "Bearish FVG Formed",       "Bearish FVG detected on {{ticker}} {{interval}}")
alertcondition(is_bull_disp,   "Bullish Displacement",     "Bull Displacement on {{ticker}} — Check for FVG entry")
alertcondition(is_bear_disp,   "Bearish Displacement",     "Bear Displacement on {{ticker}} — Check for FVG entry")
alertcondition(isd_score == 3, "Full ISD Sequence (3/3)",  "ISD Complete on {{ticker}} {{interval}} — High probability setup")
alertcondition(is_bull_idm,    "Bullish Inducement (IDM)", "Bear Trap detected on {{ticker}}")
alertcondition(is_bear_idm,    "Bearish Inducement (IDM)", "Bull Trap detected on {{ticker}}")
````
