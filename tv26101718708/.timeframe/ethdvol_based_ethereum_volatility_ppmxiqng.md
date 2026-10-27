# ETHDVOL based Ethereum Volatility

- url: https://www.tradingview.com/script/pPMXiqng-ETHDVOL-based-Ethereum-Volatility/
- type: indicator
- pine_id: PUB;c9c0fc1d590b45838559b5111b637ecf
- version: 1.0

## Description

This indicator maps Ethereum's expected price range across three timeframes — daily, weekly, and monthly — using the Ethereum Deribit Volatility Index (ETHDVOL) as the implied volatility source and realized historical volatility (HV7, HV14, HV30) as the measured counterpart.

ETHDVOL is Ethereum's equivalent of the VIX. It represents the market's forward-looking expectation of annualized volatility, derived from Deribit options pricing. When ETHDVOL is high, the market expects large moves. When it is low, the market expects compression. By scaling ETHDVOL and realized vol into dollar-denominated price bands anchored to key opens, this indicator gives you a structural volatility map directly on the ETH price chart — no separate pane required.

The core concept is straightforward: options market participants price expected ranges. Those ranges become levels. Price respects them — not always, not perfectly, but consistently enough to be meaningful as reference and used in comparison to what is realized.

[b]How to Read the Bands[/b]

[i]The Anchoring System[/i]

Each set of bands is anchored to a specific open and held fixed for its entire period. They do not drift or repaint mid-period.

**Weekly bands** lock on Saturday's opening price and ETHDVOL reading at the start of each crypto week. They hold for the full 7-day period. This Saturday anchor matters: the crypto options and perpetuals market structurally resets around the Saturday UTC open. Weekly expiries settle on Fridays, and Saturday represents the cleanest "new week" anchor available on a 24/7 market.

**Monthly bands** lock on the 1st of each calendar month and hold for the entire month. They represent the options market's expectation of how far ETH could move over a 30-day window from that open.

**Daily bands** reset each day at 00:00 UTC and reflect that day's opening price and current live volatility readings. They are the tightest, most reactive bands on the chart.

[i]The Band Pairs[/i]

Each timeframe shows two bands — one from implied volatility (IV) and one from realized historical volatility (HV):

**IV bands** (white weekly, white monthly) represent what the options market *expects* ETH to move. These are forward-looking. They define the market's priced range for the period.

**HV14 Weekly** (orange) represents the actual realized volatility over the past 14 days, scaled to a weekly move. When HV14 is inside the IV band, the market is pricing more risk than it has been delivering — a low-volatility regime. When HV14 approaches or exceeds the IV band, realized vol is catching up to or exceeding what was priced.

**HV30 Monthly** (orange-red) is the 30-day realized volatility scaled to a monthly move. This sits alongside the monthly IV band and gives context for whether the current month's implied range is historically generous or tight.

**HV7 Today** (light yellow) is a live daily band using the most recent 7 days of realized volatility anchored to today's open. It is the most sensitive reading — useful for intraday context and identifying when daily price movement is pushing into or through the short-term realized range.

**IV Today** (faded white) is the same daily scaling but using DVOL — today's implied daily range from the options market. It is intentionally faded to keep the chart readable.

The Info Table

The top-left badge shows three live readings updated on every bar:

- **IV %** — the current ETHDVOL weekly reading with a heat emoji (🔥 above 60%, ❄️ below 40%, ⚡ in between)
- **HV14 %** — the Saturday-latched realized vol for the week
- **HV14/IV ratio** — the percentage of realized vol relative to implied. ✅ below 95% means RV is running below IV (options are pricing more than has been delivered). ⚠️ at or above 95% means RV is catching up to or exceeding IV — a higher-energy regime.
- **Daily change** — BTC price change from today's open in both % and dollar terms

[i]The Saturday Anchor Line[/i]

The ⚓ Sat Open line marks the weekly anchor price. It is the midpoint of the weekly IV and HV14 bands. Price reclaiming or failing at this line is significant — it is the reference price that all weekly band math is built from.

[i]Trend Channels[/i]

Two sets of dynamic trendlines auto-draw based on pivot structure — a shorter-period dashed pair and a longer-period solid pair. They update continuously as new pivots form. Green slope = bullish structure on that channel. Red slope = bearish. They reset on the 1st of each calendar month, giving enough bars to build meaningful structure across a full monthly cycle rather than resetting too frequently on the weekly.

---

[b]Settings Walkthrough[/b]

[i]Display Toggles[/i]

✅ Show Weekly Open Line | The ⚓ Sat Open midline
✅ Show Weekly Bands (IV + HV14) | Both white IV weekly and orange HV14 bands together
✅ Show Monthly Bands (IV + HV30) | Both white IV monthly and orange-red HV30 bands together
✅ Show HV7 Today (daily rotating) | The light yellow daily realized vol band — resets each day
✅ Show IV Today (daily rotating) | The faded white daily implied vol band — resets each day

The weekly and monthly band pairs are intentionally linked — IV and HV are most useful when compared against each other, so they toggle as a unit.

[i]Label Proximity Gate ($)[/i]

When multiple bands converge near the same price level, the chart can become cluttered with overlapping labels. The Proximity Gate controls how close a daily band label can be to a weekly or monthly level before it is suppressed. The **line still draws** — only the text label is hidden.

**Default: $50.** At this setting, a daily HV7 or IV Today label will be hidden if it sits within $50 of any weekly or monthly band. Increase this value if you want a cleaner chart with fewer labels. Decrease it if you want to see all labels even when levels are close together.

[i]**Practical guidance:**[/i]

💡 On wider perspectives toggle HV7/IV (daily) off and widen 'proximity label gate' to reduce screen clutter
💡 On narrow perspectives keep the daily looks with a tighter 'proximity label gate'

[i]Trend Line Settings[/i]

Short and long pivot periods are adjustable independently. The defaults (10 and 16) are calibrated for the 30-minute timeframe. On the 1-hour chart, consider reducing both slightly. On 15-minute, increasing them gives more stable pivots. Because the trendlines reset monthly rather than weekly, they have sufficient bars to establish meaningful channel structure — particularly useful for identifying multi-week compression patterns and directional bias across the full monthly vol cycle.

🚨 General — The indicator is most powerful when used to identify when price is testing a band confluence — for example, when the weekly IV lower and monthly HV30 lower are within close range of each other. Those areas represent options-market-defined support zones where two independent vol calculations agree.

---

*Indicator is designed for ETHUSD. Requires access to DERIBIT:ETHDVOL data on TradingView. Works on intraday timeframes only — weekly and monthly band projections display for the current period.*

## Source Code

````pine
//@version=6
indicator("Ξthereum Volatility off ETHDVOL", overlay=true, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════
// ─── DISPLAY SETTINGS ────────────────────────────────────
// ═══════════════════════════════════════════════════════════
show_midline     = input.bool(true,  "Show Weekly Open Line",            group="Display")
show_weekly      = input.bool(true,  "Show Weekly Bands (IV + HV14)",    group="Display")
show_monthly     = input.bool(true,  "Show Monthly Bands (IV + HV30)",   group="Display")
show_hv7_daily   = input.bool(true,  "Show HV7 Today (daily rotating)",  group="Display")
show_iv_daily    = input.bool(true,  "Show IV Today (daily rotating)",   group="Display")
label_proximity  = input.float(50.0, "Label Proximity Gate ($)", minval=10, step=10, group="Display", tooltip="Hide daily labels when within this $ of a weekly or monthly level. Lines still draw.")

iv_weekly_color  = input.color(#FFFFFF, "IV Weekly Color",    group="Display")
hv14_color       = input.color(#FF9800, "HV14 Weekly Color",  group="Display")
iv_monthly_color = input.color(#FFFFFF, "IV Monthly Color",   group="Display")
hv30_color       = input.color(#FF6B35, "HV30 Monthly Color", group="Display")
hv7_daily_color  = input.color(#FFF9C4, "HV7 Today Color",    group="Display")
mid_color        = input.color(#82B1FF, "Weekly Open Color",   group="Display")

// ═══════════════════════════════════════════════════════════
// ─── FATS TRENDLINE SETTINGS ────────────────────────────
// ═══════════════════════════════════════════════════════════
// Adapted from "Fibonacci Auto Trend Scouter" by sirkriz (MPL 2.0)
// Dual-period rolling bag system — no validation gate, no classification lag.
tl_short_period = input.int(10, "Short Period", minval=2, maxval=55, group="Trend Lines", tooltip="Bars for short pivot detection. 10 on 30m = 5 hours each side.")
tl_long_period  = input.int(16, "Long Period",  minval=2, maxval=89, group="Trend Lines", tooltip="Bars for long pivot detection. 16 on 30m = 8 hours each side.")
show_tl_short   = input.bool(true, "Show Short TrendLines", group="Trend Lines")
show_tl_long    = input.bool(true, "Show Long TrendLines",  group="Trend Lines")
tl_short_width  = input.int(2, "Short Line Width", minval=1, maxval=4, group="Trend Lines")
tl_long_width   = input.int(3, "Long Line Width",  minval=1, maxval=4, group="Trend Lines")
tl_up_color     = input.color(#4CAF50, "Up Channel Color",   group="Trend Lines")
tl_dn_color     = input.color(#F44336, "Down Channel Color", group="Trend Lines")

// ═══════════════════════════════════════════════════════════
// ─── VOLATILITY SETTINGS ────────────────────────────────
// ═══════════════════════════════════════════════════════════
hv14_length = input.int(14, "HV14 Lookback (days)", minval=2, maxval=60, group="Volatility")
hv30_length = input.int(30, "HV30 Lookback (days)", minval=2, maxval=90, group="Volatility")
hv7_length  = input.int(7,  "HV7 Lookback (days)",  minval=2, maxval=60, group="Volatility")

// ═══════════════════════════════════════════════════════════
// ─── DATA FEEDS ─────────────────────────────────────────
// ═══════════════════════════════════════════════════════════
eth_daily_open    = request.security("COINBASE:ETHUSD", "D", open, lookahead=barmerge.lookahead_on)
ethdvol_daily_open = request.security("DERIBIT:ETHDVOL", "D", open, lookahead=barmerge.lookahead_on)

// ═══════════════════════════════════════════════════════════
// ─── WEEKLY ANCHOR (LOCKS ON SATURDAY) ──────────────────
// ═══════════════════════════════════════════════════════════
is_saturday = dayofweek(time) == dayofweek.saturday and dayofweek(time[1]) != dayofweek.saturday

var float eth_weekly_open    = na
var float ethdvol_weekly_open = na

if is_saturday
    if not na(eth_daily_open)
        eth_weekly_open := eth_daily_open
    if not na(ethdvol_daily_open) and ethdvol_daily_open > 0
        ethdvol_weekly_open := ethdvol_daily_open

if na(eth_weekly_open) and not na(eth_daily_open)
    eth_weekly_open := eth_daily_open
if na(ethdvol_weekly_open) and not na(ethdvol_daily_open) and ethdvol_daily_open > 0
    ethdvol_weekly_open := ethdvol_daily_open

// ═══════════════════════════════════════════════════════════
// ─── MONTHLY ANCHOR (LOCKS ON 1ST OF EACH MONTH) ────────
// ═══════════════════════════════════════════════════════════
is_new_month = ta.change(month(time)) != 0

var float eth_monthly_open    = na
var float ethdvol_monthly_open = na

if is_new_month
    if not na(eth_daily_open)
        eth_monthly_open := eth_daily_open
    if not na(ethdvol_daily_open) and ethdvol_daily_open > 0
        ethdvol_monthly_open := ethdvol_daily_open

if na(eth_monthly_open) and not na(eth_daily_open)
    eth_monthly_open := eth_daily_open
if na(ethdvol_monthly_open) and not na(ethdvol_daily_open) and ethdvol_daily_open > 0
    ethdvol_monthly_open := ethdvol_daily_open

// ═══════════════════════════════════════════════════════════
// ─── DAILY ANCHOR (RESETS 00:00 UTC EACH DAY) ───────────
// ═══════════════════════════════════════════════════════════
is_new_day = ta.change(dayofmonth(time)) != 0

var float eth_daily_anchor    = na
var float ethdvol_daily_anchor = na

if is_new_day
    if not na(eth_daily_open)
        eth_daily_anchor := eth_daily_open
    if not na(ethdvol_daily_open) and ethdvol_daily_open > 0
        ethdvol_daily_anchor := ethdvol_daily_open

if na(eth_daily_anchor) and not na(eth_daily_open)
    eth_daily_anchor := eth_daily_open
if na(ethdvol_daily_anchor) and not na(ethdvol_daily_open) and ethdvol_daily_open > 0
    ethdvol_daily_anchor := ethdvol_daily_open

// ═══════════════════════════════════════════════════════════
// ─── REALIZED VOLATILITY ────────────────────────────────
// ═══════════════════════════════════════════════════════════
// HV14 — weekly band basis
pop_stdev_14         = request.security("COINBASE:ETHUSD", "D", ta.stdev(math.log(close[1] / close[2]), hv14_length), lookahead=barmerge.lookahead_on)
sample_correction_14 = math.sqrt(hv14_length / (hv14_length - 1.0))
hv14_live            = pop_stdev_14 * sample_correction_14 * math.sqrt(365.0) * 100.0

// HV30 — monthly band basis
pop_stdev_30         = request.security("COINBASE:ETHUSD", "D", ta.stdev(math.log(close[1] / close[2]), hv30_length), lookahead=barmerge.lookahead_on)
sample_correction_30 = math.sqrt(hv30_length / (hv30_length - 1.0))
hv30_live            = pop_stdev_30 * sample_correction_30 * math.sqrt(365.0) * 100.0

// HV7 — daily band basis (live, not latched)
pop_stdev_7         = request.security("COINBASE:ETHUSD", "D", ta.stdev(math.log(close[1] / close[2]), hv7_length), lookahead=barmerge.lookahead_on)
sample_correction_7 = math.sqrt(hv7_length / (hv7_length - 1.0))
hv7_live            = pop_stdev_7 * sample_correction_7 * math.sqrt(365.0) * 100.0

// HV14: latch on Saturday — holds the full week
var float hv14_weekly = na
if is_saturday
    if not na(hv14_live)
        hv14_weekly := hv14_live
if na(hv14_weekly) and not na(hv14_live)
    hv14_weekly := hv14_live

// HV30: latch on 1st of month — holds the full calendar month
var float hv30_monthly = na
if is_new_month
    if not na(hv30_live)
        hv30_monthly := hv30_live
if na(hv30_monthly) and not na(hv30_live)
    hv30_monthly := hv30_live

// RV as % of IV (weekly basis — info table)
rv_pct_of_iv = (hv14_weekly / ethdvol_weekly_open) * 100.0

// ═══════════════════════════════════════════════════════════
// ─── RANGE CALCULATIONS ─────────────────────────────────
// ═══════════════════════════════════════════════════════════
daily_factor   = math.sqrt(1.0  / 365.0)
weekly_factor  = math.sqrt(7.0  / 365.0)
monthly_factor = math.sqrt(30.0 / 365.0)

// ── Weekly (anchored to Saturday open) ──
iv_weekly_move  = eth_weekly_open * (ethdvol_weekly_open / 100.0) * weekly_factor
iv_weekly_upper = eth_weekly_open + iv_weekly_move
iv_weekly_lower = eth_weekly_open - iv_weekly_move

hv14_move  = eth_weekly_open * (hv14_weekly / 100.0) * weekly_factor
hv14_upper = eth_weekly_open + hv14_move
hv14_lower = eth_weekly_open - hv14_move

// ── Monthly (anchored to 1st-of-month open) ──
iv_monthly_move  = eth_monthly_open * (ethdvol_monthly_open / 100.0) * monthly_factor
iv_monthly_upper = eth_monthly_open + iv_monthly_move
iv_monthly_lower = eth_monthly_open - iv_monthly_move

hv30_monthly_move  = eth_monthly_open * (hv30_monthly / 100.0) * monthly_factor
hv30_monthly_upper = eth_monthly_open + hv30_monthly_move
hv30_monthly_lower = eth_monthly_open - hv30_monthly_move

// ── Daily (anchored to today's open, resets each day) ──
hv7_daily_move_today  = eth_daily_anchor * (hv7_live  / 100.0) * daily_factor
hv7_daily_upper_today = eth_daily_anchor + hv7_daily_move_today
hv7_daily_lower_today = eth_daily_anchor - hv7_daily_move_today

iv_daily_move_today  = eth_daily_anchor * (ethdvol_daily_anchor / 100.0) * daily_factor
iv_daily_upper_today = eth_daily_anchor + iv_daily_move_today
iv_daily_lower_today = eth_daily_anchor - iv_daily_move_today

// ═══════════════════════════════════════════════════════════
// ─── CURRENT WEEK FILTER (SAT–SAT) ─────────────────────
// ═══════════════════════════════════════════════════════════
ms_offset    = 2 * 86400 * 1000
current_week = weekofyear(timenow + ms_offset)
current_year = year(timenow + ms_offset)
bar_week     = weekofyear(time + ms_offset)
bar_year     = year(time + ms_offset)
show         = timeframe.isintraday and bar_week == current_week and bar_year == current_year

///////////////////////////////////////////////////////////
//                                                       //
//    FATS TRENDLINE ENGINE                              //
//    Rolling bag pivot system — dual period             //
//    Adapted from sirkriz "Fibonacci Auto Trend         //
//    Scouter" (MPL 2.0)                                 //
//                                                       //
///////////////////////////////////////////////////////////

// ═══════════════════════════════════════════════════════════
// ─── BAG FUNCTIONS ──────────────────────────────────────
// ═══════════════════════════════════════════════════════════
f_bag_add(float[] bag, float val, float bi) =>
    array.unshift(bag, bi)
    array.unshift(bag, val)
    if array.size(bag) > 14
        array.pop(bag)
        array.pop(bag)
    0

f_bag_update(float[] bag, float val, float bi, int dir) =>
    if array.size(bag) == 0
        f_bag_add(bag, val, bi)
    else
        if (dir == 1 and val > array.get(bag, 0)) or (dir == -1 and val < array.get(bag, 0))
            array.set(bag, 0, val)
            array.set(bag, 1, bi)
    0

// ═══════════════════════════════════════════════════════════
// ─── SHORT PERIOD PIVOT DETECTION ───────────────────────
// ═══════════════════════════════════════════════════════════
var int sm_dir = 0
var float[] sm_bag = array.new_float(0)

if is_new_month
    array.clear(sm_bag)
    sm_dir := 0

float sm_hi = ta.highestbars(high, tl_short_period) == 0 ? high : na
float sm_lo = ta.lowestbars(low,  tl_short_period) == 0 ? low  : na

bool sm_is_hi = not na(sm_hi) and na(sm_lo)
bool sm_is_lo = not na(sm_lo) and na(sm_hi)
sm_dir := sm_is_hi ? 1 : sm_is_lo ? -1 : sm_dir

bool sm_dir_changed = ta.change(sm_dir) != 0
if sm_dir_changed
    float sm_new_val = sm_dir == 1 ? sm_hi : sm_lo
    if not na(sm_new_val)
        f_bag_add(sm_bag, sm_new_val, float(bar_index))
else
    float sm_upd_val = sm_dir == 1 ? sm_hi : sm_lo
    if not na(sm_upd_val)
        f_bag_update(sm_bag, sm_upd_val, float(bar_index), sm_dir)

bool sm_ready = array.size(sm_bag) >= 8

// ═══════════════════════════════════════════════════════════
// ─── LONG PERIOD PIVOT DETECTION ────────────────────────
// ═══════════════════════════════════════════════════════════
var int lg_dir = 0
var float[] lg_bag = array.new_float(0)

if is_new_month
    array.clear(lg_bag)
    lg_dir := 0

float lg_hi = ta.highestbars(high, tl_long_period) == 0 ? high : na
float lg_lo = ta.lowestbars(low,  tl_long_period) == 0 ? low  : na

bool lg_is_hi = not na(lg_hi) and na(lg_lo)
bool lg_is_lo = not na(lg_lo) and na(lg_hi)
lg_dir := lg_is_hi ? 1 : lg_is_lo ? -1 : lg_dir

bool lg_dir_changed = ta.change(lg_dir) != 0
if lg_dir_changed
    float lg_new_val = lg_dir == 1 ? lg_hi : lg_lo
    if not na(lg_new_val)
        f_bag_add(lg_bag, lg_new_val, float(bar_index))
else
    float lg_upd_val = lg_dir == 1 ? lg_hi : lg_lo
    if not na(lg_upd_val)
        f_bag_update(lg_bag, lg_upd_val, float(bar_index), lg_dir)

bool lg_ready = array.size(lg_bag) >= 8

// ═══════════════════════════════════════════════════════════
// ─── ANCHOR SELECTION ───────────────────────────────────
// ═══════════════════════════════════════════════════════════
// ─── Short anchors ───
float sm_b1_v = sm_ready ? array.get(sm_bag, 0) : na
int   sm_b1_i = sm_ready ? int(array.get(sm_bag, 1)) : 0
float sm_b2_v = sm_ready ? array.get(sm_bag, 2) : na
int   sm_b2_i = sm_ready ? int(array.get(sm_bag, 3)) : 0
float sm_b3_v = sm_ready ? array.get(sm_bag, 4) : na
int   sm_b3_i = sm_ready ? int(array.get(sm_bag, 5)) : 0
float sm_b4_v = sm_ready ? array.get(sm_bag, 6) : na
int   sm_b4_i = sm_ready ? int(array.get(sm_bag, 7)) : 0

float sm_from_top_v = sm_ready ? (sm_dir == 1 ? sm_b3_v : sm_b4_v) : na
int   sm_from_top_i = sm_ready ? (sm_dir == 1 ? sm_b3_i : sm_b4_i) : 0
float sm_to_top_v   = sm_ready ? (sm_dir == 1 ? sm_b1_v : sm_b2_v) : na
int   sm_to_top_i   = sm_ready ? (sm_dir == 1 ? sm_b1_i : sm_b2_i) : 0

float sm_from_bot_v = sm_ready ? (sm_dir == 1 ? sm_b4_v : sm_b3_v) : na
int   sm_from_bot_i = sm_ready ? (sm_dir == 1 ? sm_b4_i : sm_b3_i) : 0
float sm_to_bot_v   = sm_ready ? (sm_dir == 1 ? sm_b2_v : sm_b1_v) : na
int   sm_to_bot_i   = sm_ready ? (sm_dir == 1 ? sm_b2_i : sm_b1_i) : 0

int sm_top_dir = sm_ready and sm_to_top_i != sm_from_top_i ? (sm_to_top_v > sm_from_top_v ? 1 : -1) : 0
int sm_bot_dir = sm_ready and sm_to_bot_i != sm_from_bot_i ? (sm_to_bot_v > sm_from_bot_v ? 1 : -1) : 0

// ─── Long anchors ───
float lg_b1_v = lg_ready ? array.get(lg_bag, 0) : na
int   lg_b1_i = lg_ready ? int(array.get(lg_bag, 1)) : 0
float lg_b2_v = lg_ready ? array.get(lg_bag, 2) : na
int   lg_b2_i = lg_ready ? int(array.get(lg_bag, 3)) : 0
float lg_b3_v = lg_ready ? array.get(lg_bag, 4) : na
int   lg_b3_i = lg_ready ? int(array.get(lg_bag, 5)) : 0
float lg_b4_v = lg_ready ? array.get(lg_bag, 6) : na
int   lg_b4_i = lg_ready ? int(array.get(lg_bag, 7)) : 0

float lg_from_top_v = lg_ready ? (lg_dir == 1 ? lg_b3_v : lg_b4_v) : na
int   lg_from_top_i = lg_ready ? (lg_dir == 1 ? lg_b3_i : lg_b4_i) : 0
float lg_to_top_v   = lg_ready ? (lg_dir == 1 ? lg_b1_v : lg_b2_v) : na
int   lg_to_top_i   = lg_ready ? (lg_dir == 1 ? lg_b1_i : lg_b2_i) : 0

float lg_from_bot_v = lg_ready ? (lg_dir == 1 ? lg_b4_v : lg_b3_v) : na
int   lg_from_bot_i = lg_ready ? (lg_dir == 1 ? lg_b4_i : lg_b3_i) : 0
float lg_to_bot_v   = lg_ready ? (lg_dir == 1 ? lg_b2_v : lg_b1_v) : na
int   lg_to_bot_i   = lg_ready ? (lg_dir == 1 ? lg_b2_i : lg_b1_i) : 0

int lg_top_dir = lg_ready and lg_to_top_i != lg_from_top_i ? (lg_to_top_v > lg_from_top_v ? 1 : -1) : 0
int lg_bot_dir = lg_ready and lg_to_bot_i != lg_from_bot_i ? (lg_to_bot_v > lg_from_bot_v ? 1 : -1) : 0

// ═══════════════════════════════════════════════════════════
// ─── TRENDLINE VISUAL LINES ─────────────────────────────
// ═══════════════════════════════════════════════════════════
var line l_sm_bot = na, var line l_sm_top = na
var line l_lg_bot = na, var line l_lg_top = na

line.delete(l_sm_bot), line.delete(l_sm_top)
line.delete(l_lg_bot), line.delete(l_lg_top)

color sm_top_color = color.new(sm_top_dir == 1 ? tl_up_color : tl_dn_color, 50)
color sm_bot_color = color.new(sm_bot_dir == 1 ? tl_up_color : tl_dn_color, 50)
color lg_top_color = color.new(lg_top_dir == 1 ? tl_up_color : tl_dn_color, 50)
color lg_bot_color = color.new(lg_bot_dir == 1 ? tl_up_color : tl_dn_color, 50)

if sm_ready and show_tl_short
    l_sm_bot := line.new(sm_from_bot_i, sm_from_bot_v, sm_to_bot_i, sm_to_bot_v, color=sm_bot_color, style=line.style_dashed, width=tl_short_width, extend=extend.right)
    l_sm_top := line.new(sm_from_top_i, sm_from_top_v, sm_to_top_i, sm_to_top_v, color=sm_top_color, style=line.style_dashed, width=tl_short_width, extend=extend.right)

if lg_ready and show_tl_long
    l_lg_bot := line.new(lg_from_bot_i, lg_from_bot_v, lg_to_bot_i, lg_to_bot_v, color=lg_bot_color, style=line.style_solid, width=tl_long_width, extend=extend.right)
    l_lg_top := line.new(lg_from_top_i, lg_from_top_v, lg_to_top_i, lg_to_top_v, color=lg_top_color, style=line.style_solid, width=tl_long_width, extend=extend.right)

// ═══════════════════════════════════════════════════════════
// ─── WEEK SEPARATOR LINES ───────────────────────────────
// ═══════════════════════════════════════════════════════════
if is_saturday
    line.new(bar_index, iv_weekly_upper + iv_weekly_move * 0.5, bar_index, iv_weekly_lower - iv_weekly_move * 0.5,
         color=color.new(color.gray, 50), style=line.style_dotted, width=1)
    label.new(bar_index, iv_weekly_upper + iv_weekly_move * 0.5,
         str.tostring(month(time)) + "/" + str.tostring(dayofmonth(time)),
         color=color.new(na, 100), textcolor=color.gray, style=label.style_label_down, size=size.small)

// ═══════════════════════════════════════════════════════════
// ─── FORWARD PROJECTION LINES ───────────────────────────
// ═══════════════════════════════════════════════════════════
ms_per_bar     = timeframe.in_seconds() * 1000
ms_in_week     = 7 * 86400 * 1000
days_since_sat = (dayofweek(timenow) + 1) % 7
time_of_day_ms = timenow % (86400 * 1000)
ms_into_week   = days_since_sat * 86400 * 1000 + time_of_day_ms
ms_remaining   = ms_in_week - ms_into_week
bars_remaining = math.ceil(ms_remaining / ms_per_bar)

// ─── Line vars ───
var line l_mid           = na
var line l_iv_w_iu       = na, var line l_iv_w_il      = na
var line l_hv14_iu       = na, var line l_hv14_il      = na
var line l_iv_m_iu       = na, var line l_iv_m_il      = na
var line l_hv30_iu       = na, var line l_hv30_il      = na
var line l_hv7_today_iu  = na, var line l_hv7_today_il = na
var line l_iv_today_iu   = na, var line l_iv_today_il  = na

// ─── Label vars ───
var label lbl_mid           = na
var label lbl_iv_w_iu       = na, var label lbl_iv_w_il      = na
var label lbl_hv14_iu       = na, var label lbl_hv14_il      = na
var label lbl_iv_m_iu       = na, var label lbl_iv_m_il      = na
var label lbl_hv30_iu       = na, var label lbl_hv30_il      = na
var label lbl_hv7_today_iu  = na, var label lbl_hv7_today_il = na
var label lbl_iv_today_iu   = na, var label lbl_iv_today_il  = na

if barstate.islast and show
    line.delete(l_mid)
    line.delete(l_iv_w_iu),      line.delete(l_iv_w_il)
    line.delete(l_hv14_iu),      line.delete(l_hv14_il)
    line.delete(l_iv_m_iu),      line.delete(l_iv_m_il)
    line.delete(l_hv30_iu),      line.delete(l_hv30_il)
    line.delete(l_hv7_today_iu), line.delete(l_hv7_today_il)
    line.delete(l_iv_today_iu),  line.delete(l_iv_today_il)

    label.delete(lbl_mid)
    label.delete(lbl_iv_w_iu),      label.delete(lbl_iv_w_il)
    label.delete(lbl_hv14_iu),      label.delete(lbl_hv14_il)
    label.delete(lbl_iv_m_iu),      label.delete(lbl_iv_m_il)
    label.delete(lbl_hv30_iu),      label.delete(lbl_hv30_il)
    label.delete(lbl_hv7_today_iu), label.delete(lbl_hv7_today_il)
    label.delete(lbl_iv_today_iu),  label.delete(lbl_iv_today_il)

    int proj_bars = math.max(bars_remaining, 5)
    int ext_bars  = math.min(math.round(proj_bars * 1.0), 480)

    // ── Weekly open midline ──
    if show_midline
        l_mid   := line.new(bar_index, eth_weekly_open, bar_index + ext_bars, eth_weekly_open, color=color.new(mid_color, 50), style=line.style_solid, width=1)
        lbl_mid := label.new(bar_index + ext_bars + 3, eth_weekly_open, "⚓ Sat Open", color=color.new(na, 100), textcolor=color.new(mid_color, 50), style=label.style_label_left, size=size.normal)

    // ── Weekly bands: IV Weekly + HV14 (both always visible together) ──
    if show_weekly
        l_iv_w_iu   := line.new(bar_index, iv_weekly_upper, bar_index + ext_bars, iv_weekly_upper, color=iv_weekly_color, style=line.style_solid, width=1)
        l_iv_w_il   := line.new(bar_index, iv_weekly_lower, bar_index + ext_bars, iv_weekly_lower, color=iv_weekly_color, style=line.style_solid, width=1)
        lbl_iv_w_iu := label.new(bar_index + ext_bars + 3, iv_weekly_upper, "IV Weekly (" + str.tostring(ethdvol_weekly_open, "#.#") + "%)", color=color.new(na, 100), textcolor=iv_weekly_color, style=label.style_label_left, size=size.normal)
        lbl_iv_w_il := label.new(bar_index + ext_bars + 3, iv_weekly_lower, "IV Weekly (" + str.tostring(ethdvol_weekly_open, "#.#") + "%)", color=color.new(na, 100), textcolor=iv_weekly_color, style=label.style_label_left, size=size.normal)

        l_hv14_iu   := line.new(bar_index, hv14_upper, bar_index + ext_bars, hv14_upper, color=hv14_color, style=line.style_solid, width=1)
        l_hv14_il   := line.new(bar_index, hv14_lower, bar_index + ext_bars, hv14_lower, color=hv14_color, style=line.style_solid, width=1)
        bool hv14u_ok = math.abs(hv14_upper - iv_weekly_upper) > label_proximity and math.abs(hv14_upper - iv_weekly_lower) > label_proximity and math.abs(hv14_upper - iv_monthly_upper) > label_proximity and math.abs(hv14_upper - iv_monthly_lower) > label_proximity and math.abs(hv14_upper - hv30_monthly_upper) > label_proximity and math.abs(hv14_upper - hv30_monthly_lower) > label_proximity and math.abs(hv14_upper - eth_weekly_open) > label_proximity
        if hv14u_ok
            lbl_hv14_iu := label.new(bar_index + ext_bars + 3, hv14_upper, "HV14 Weekly (" + str.tostring(hv14_weekly, "#.#") + "%)", color=color.new(na, 100), textcolor=hv14_color, style=label.style_label_left, size=size.normal)
        bool hv14l_ok = math.abs(hv14_lower - iv_weekly_upper) > label_proximity and math.abs(hv14_lower - iv_weekly_lower) > label_proximity and math.abs(hv14_lower - iv_monthly_upper) > label_proximity and math.abs(hv14_lower - iv_monthly_lower) > label_proximity and math.abs(hv14_lower - hv30_monthly_upper) > label_proximity and math.abs(hv14_lower - hv30_monthly_lower) > label_proximity and math.abs(hv14_lower - eth_weekly_open) > label_proximity
        if hv14l_ok
            lbl_hv14_il := label.new(bar_index + ext_bars + 3, hv14_lower, "HV14 Weekly (" + str.tostring(hv14_weekly, "#.#") + "%)", color=color.new(na, 100), textcolor=hv14_color, style=label.style_label_left, size=size.normal)

    // ── Monthly bands: IV Monthly + HV30 (both always visible together) ──
    if show_monthly
        l_iv_m_iu   := line.new(bar_index, iv_monthly_upper, bar_index + ext_bars, iv_monthly_upper, color=iv_monthly_color, style=line.style_solid, width=2)
        l_iv_m_il   := line.new(bar_index, iv_monthly_lower, bar_index + ext_bars, iv_monthly_lower, color=iv_monthly_color, style=line.style_solid, width=2)
        lbl_iv_m_iu := label.new(bar_index + ext_bars + 3, iv_monthly_upper, "IV Monthly (" + str.tostring(ethdvol_monthly_open, "#.#") + "%)", color=color.new(na, 100), textcolor=iv_monthly_color, style=label.style_label_left, size=size.normal)
        lbl_iv_m_il := label.new(bar_index + ext_bars + 3, iv_monthly_lower, "IV Monthly (" + str.tostring(ethdvol_monthly_open, "#.#") + "%)", color=color.new(na, 100), textcolor=iv_monthly_color, style=label.style_label_left, size=size.normal)

        l_hv30_iu   := line.new(bar_index, hv30_monthly_upper, bar_index + ext_bars, hv30_monthly_upper, color=hv30_color, style=line.style_solid, width=2)
        l_hv30_il   := line.new(bar_index, hv30_monthly_lower, bar_index + ext_bars, hv30_monthly_lower, color=hv30_color, style=line.style_solid, width=2)
        bool hv30u_ok = math.abs(hv30_monthly_upper - iv_monthly_upper) > label_proximity and math.abs(hv30_monthly_upper - iv_monthly_lower) > label_proximity and math.abs(hv30_monthly_upper - eth_weekly_open) > label_proximity
        if hv30u_ok
            lbl_hv30_iu := label.new(bar_index + ext_bars + 3, hv30_monthly_upper, "HV30 Monthly (" + str.tostring(hv30_monthly, "#.#") + "%)", color=color.new(na, 100), textcolor=hv30_color, style=label.style_label_left, size=size.normal)
        bool hv30l_ok = math.abs(hv30_monthly_lower - iv_monthly_upper) > label_proximity and math.abs(hv30_monthly_lower - iv_monthly_lower) > label_proximity and math.abs(hv30_monthly_lower - eth_weekly_open) > label_proximity
        if hv30l_ok
            lbl_hv30_il := label.new(bar_index + ext_bars + 3, hv30_monthly_lower, "HV30 Monthly (" + str.tostring(hv30_monthly, "#.#") + "%)", color=color.new(na, 100), textcolor=hv30_color, style=label.style_label_left, size=size.normal)

    // ── HV7 Today (daily rotating — anchored to today's open) ──
    if show_hv7_daily
        l_hv7_today_iu := line.new(bar_index, hv7_daily_upper_today, bar_index + ext_bars, hv7_daily_upper_today, color=hv7_daily_color, style=line.style_solid, width=1)
        l_hv7_today_il := line.new(bar_index, hv7_daily_lower_today, bar_index + ext_bars, hv7_daily_lower_today, color=hv7_daily_color, style=line.style_solid, width=1)
        bool hv7u_ok = math.abs(hv7_daily_upper_today - iv_weekly_upper) > label_proximity and math.abs(hv7_daily_upper_today - iv_weekly_lower) > label_proximity and math.abs(hv7_daily_upper_today - hv14_upper) > label_proximity and math.abs(hv7_daily_upper_today - hv14_lower) > label_proximity and math.abs(hv7_daily_upper_today - iv_monthly_upper) > label_proximity and math.abs(hv7_daily_upper_today - iv_monthly_lower) > label_proximity and math.abs(hv7_daily_upper_today - hv30_monthly_upper) > label_proximity and math.abs(hv7_daily_upper_today - hv30_monthly_lower) > label_proximity and math.abs(hv7_daily_upper_today - eth_weekly_open) > label_proximity and math.abs(hv7_daily_upper_today - iv_daily_upper_today) > label_proximity and math.abs(hv7_daily_upper_today - iv_daily_lower_today) > label_proximity
        if hv7u_ok
            lbl_hv7_today_iu := label.new(bar_index + ext_bars + 3, hv7_daily_upper_today, "HV7 Today (" + str.tostring(hv7_live, "#.#") + "%)", color=color.new(na, 100), textcolor=hv7_daily_color, style=label.style_label_left, size=size.normal)
        bool hv7l_ok = math.abs(hv7_daily_lower_today - iv_weekly_upper) > label_proximity and math.abs(hv7_daily_lower_today - iv_weekly_lower) > label_proximity and math.abs(hv7_daily_lower_today - hv14_upper) > label_proximity and math.abs(hv7_daily_lower_today - hv14_lower) > label_proximity and math.abs(hv7_daily_lower_today - iv_monthly_upper) > label_proximity and math.abs(hv7_daily_lower_today - iv_monthly_lower) > label_proximity and math.abs(hv7_daily_lower_today - hv30_monthly_upper) > label_proximity and math.abs(hv7_daily_lower_today - hv30_monthly_lower) > label_proximity and math.abs(hv7_daily_lower_today - eth_weekly_open) > label_proximity and math.abs(hv7_daily_lower_today - iv_daily_upper_today) > label_proximity and math.abs(hv7_daily_lower_today - iv_daily_lower_today) > label_proximity
        if hv7l_ok
            lbl_hv7_today_il := label.new(bar_index + ext_bars + 3, hv7_daily_lower_today, "HV7 Today (" + str.tostring(hv7_live, "#.#") + "%)", color=color.new(na, 100), textcolor=hv7_daily_color, style=label.style_label_left, size=size.normal)

    // ── IV Today (daily rotating — anchored to today's open) ──
    if show_iv_daily
        daily_iv_color = color.new(iv_weekly_color, 40)
        l_iv_today_iu  := line.new(bar_index, iv_daily_upper_today, bar_index + ext_bars, iv_daily_upper_today, color=daily_iv_color, style=line.style_solid, width=1)
        l_iv_today_il  := line.new(bar_index, iv_daily_lower_today, bar_index + ext_bars, iv_daily_lower_today, color=daily_iv_color, style=line.style_solid, width=1)
        bool ivu_ok = math.abs(iv_daily_upper_today - iv_weekly_upper) > label_proximity and math.abs(iv_daily_upper_today - iv_weekly_lower) > label_proximity and math.abs(iv_daily_upper_today - hv14_upper) > label_proximity and math.abs(iv_daily_upper_today - hv14_lower) > label_proximity and math.abs(iv_daily_upper_today - iv_monthly_upper) > label_proximity and math.abs(iv_daily_upper_today - iv_monthly_lower) > label_proximity and math.abs(iv_daily_upper_today - hv30_monthly_upper) > label_proximity and math.abs(iv_daily_upper_today - hv30_monthly_lower) > label_proximity and math.abs(iv_daily_upper_today - eth_weekly_open) > label_proximity
        if ivu_ok
            lbl_iv_today_iu := label.new(bar_index + ext_bars + 3, iv_daily_upper_today, "IV Today (" + str.tostring(ethdvol_daily_anchor, "#.#") + "%)", color=color.new(na, 100), textcolor=daily_iv_color, style=label.style_label_left, size=size.normal)
        bool ivl_ok = math.abs(iv_daily_lower_today - iv_weekly_upper) > label_proximity and math.abs(iv_daily_lower_today - iv_weekly_lower) > label_proximity and math.abs(iv_daily_lower_today - hv14_upper) > label_proximity and math.abs(iv_daily_lower_today - hv14_lower) > label_proximity and math.abs(iv_daily_lower_today - iv_monthly_upper) > label_proximity and math.abs(iv_daily_lower_today - iv_monthly_lower) > label_proximity and math.abs(iv_daily_lower_today - hv30_monthly_upper) > label_proximity and math.abs(iv_daily_lower_today - hv30_monthly_lower) > label_proximity and math.abs(iv_daily_lower_today - eth_weekly_open) > label_proximity
        if ivl_ok
            lbl_iv_today_il := label.new(bar_index + ext_bars + 3, iv_daily_lower_today, "IV Today (" + str.tostring(ethdvol_daily_anchor, "#.#") + "%)", color=color.new(na, 100), textcolor=daily_iv_color, style=label.style_label_left, size=size.normal)

// ═══════════════════════════════════════════════════════════
// ─── INFO TABLE (TOP LEFT) ──────────────────────────────
// ═══════════════════════════════════════════════════════════
var table info = table.new(position.top_left, 3, 4, bgcolor=color.new(#0a0e27, 85), border_width=1, border_color=color.new(#FF9800, 50), frame_width=1, frame_color=color.new(#FF9800, 50))

if barstate.islast
    table.cell(info, 0, 0, "", text_size=size.small)
    table.cell(info, 1, 0, "", text_size=size.small)
    table.cell(info, 2, 0, "", text_size=size.small)
    table.cell(info, 0, 1, "", text_size=size.small)
    table.cell(info, 1, 1, "", text_size=size.small)
    table.cell(info, 2, 1, "", text_size=size.small)

    float eth_daily_change     = close - eth_daily_anchor
    float eth_daily_change_pct = (eth_daily_change / eth_daily_anchor) * 100.0
    string change_sign         = eth_daily_change >= 0 ? "+" : ""
    color  change_color        = eth_daily_change >= 0 ? #4CAF50 : #F44336

    string iv_emoji    = ethdvol_weekly_open > 60 ? "🔥" : ethdvol_weekly_open < 40 ? "❄️" : "⚡"
    string ratio_emoji = rv_pct_of_iv < 95.0 ? "✅" : "⚠️"

    table.cell(info, 0, 2, iv_emoji + " IV "  + str.tostring(ethdvol_weekly_open, "#.#") + "%",         text_color=#FFFFFF,                    text_size=size.small, text_font_family=font.family_monospace)
    table.cell(info, 1, 2, "🎲 HV14 "         + str.tostring(hv14_weekly, "#.#")      + "%",         text_color=#CC6600,                    text_size=size.small)
    table.cell(info, 2, 2, ratio_emoji + " "  + str.tostring(rv_pct_of_iv, "#")       + "% HV14/IV", text_color=color.new(color.white, 40), text_size=size.small)

    string change_emoji = eth_daily_change >= 0 ? "📈" : "📉"
    table.cell(info, 0, 3, change_emoji + " " + change_sign + str.tostring(eth_daily_change_pct, "#.##") + "%", text_color=change_color,                    text_size=size.small)
    table.cell(info, 1, 3, "$" + str.tostring(math.abs(eth_daily_change), "#,###"),                             text_color=change_color,                    text_size=size.small)
    table.cell(info, 2, 3, str.tostring(month(timenow)) + "/" + str.tostring(dayofmonth(timenow)),              text_color=color.new(color.white, 50),        text_size=size.small)
````
