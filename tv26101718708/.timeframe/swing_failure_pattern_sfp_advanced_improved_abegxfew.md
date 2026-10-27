# Swing Failure Pattern (SFP) - Advanced & Improved

- url: https://www.tradingview.com/script/aBEgxFEw-Swing-Failure-Pattern-SFP-Advanced-Improved/
- type: indicator
- pine_id: PUB;6a4930d0bbbb4f48a9b397c3082d74c8
- version: 2.0

## Description

[b]Swing Failure Pattern (SFP)[/b] automatically detects liquidity sweeps on your chart — bars that wick past a prior swing high or low and close back inside it — and marks them with labels, swept level lines, and optional retest tracking.

[b]=================================[/b]
[b]WHAT IS AN SFP?[/b]

Every significant swing high and low on your chart has a cluster of orders sitting just beyond it. Stop losses from traders who are long, buy stops from traders waiting for a breakout, limit orders placed at round numbers. All of that sitting at one level is called liquidity.

An SFP is what happens when the market reaches that level, triggers all those orders, and then immediately reverses. Price makes a new high or low — just enough to sweep the liquidity — then snaps back and closes on the other side of the level.

[b]Bullish SFP[/b] — wick below a prior swing low, close back above it. The sell stops below that level got triggered. The sellers who just got filled are now trapped. Price is labeled below the wick.

[b]Bearish SFP[/b] — wick above a prior swing high, close back below it. The buy stops above that level got triggered. The buyers who just got filled are now trapped. Price is labeled above the wick.

[b]SFP+ and SFP++[/b] — the same wick swept 2 or 3 stacked swing levels at once. More liquidity was grabbed in a single move, which tends to produce a stronger and more sustained reversal.

[b]=================================[/b]
[b]HOW THE DETECTION WORKS[/b]

The indicator tracks the most recent swing highs and lows using pivot detection (configurable lookback, stored up to max_age days). Each closed bar is checked against all stored pivots:
[list]
[*]The wick must exceed the pivot level by at least the minimum sweep size (ATR-based) to filter out micro-wicks that barely graze the level.
[*]The close must reject back past the swept level with a minimum close position (top or bottom X% of the bar), filtering weak closes near the middle.
[*]Optionally, the bar must have above-average volume — real stop hunts typically show a volume spike.
[/list]

[b]=================================[/b]
[b]WHEN IT DOES NOT WORK[/b]

An SFP is a liquidity event, not a reversal guarantee. Two conditions reduce its reliability significantly:

[b]Trading against a strong trend.[/b] A bearish SFP in the middle of a powerful uptrend often produces only a brief pause before the move continues. The stop hunt happened, but the underlying demand is too strong to reverse. The HTF Trend Filter setting exists for this reason — enabling it filters SFPs that go against the higher timeframe EMA direction.

[b]No supporting context at the level.[/b] An SFP that fires at a random mid-range price tends to fail more often than one that occurs at a meaningful confluence of levels — a weekly high, a significant VWAP, a well-established volume node, or a clean structural area that multiple timeframes agree on. The signal is the same but the odds are different. Using this indicator alongside tools that measure level significance will separate the high-quality setups from the noise.

[b]=================================[/b]
[b]SETTINGS[/b]

[b]Pivot Detection[/b]
[list]
[*][b]Intraday pivot bars[/b] — confirmation bars required on each side for intraday timeframes (1m to 4H). Default 8.
[*][b]HTF pivot bars[/b] — confirmation bars for Daily and above. Default 3. Kept lower because daily swings are structurally significant with less confirmation needed.
[*][b]Max pivots stored[/b] — how many recent swing levels are tracked per side. Default 5.
[*][b]Max pivot age (days)[/b] — levels older than this are expired. Default 20.
[/list]

[b]Filters[/b]
[list]
[*][b]Min sweep size[/b] — wick must exceed the level by at least this ATR multiple.
[*][b]Min close position %[/b] — for bullish SFP, close must be in the top X% of the bar. For bearish, the bottom X%.
[*][b]Volume confirmation[/b] — optionally require above-average volume on the SFP bar.
[/list]

[b]HTF Trend Filter[/b]
[list]
[*]When enabled, bullish SFPs only show during uptrends and bearish SFPs only during downtrends, defined by price relative to a configurable EMA on a higher timeframe.
[/list]

[b]Session Filter[/b]
[list]
[*]Optionally restrict signals to the London open and NY open windows (UTC hours, fully configurable). SFPs during these windows tend to be institutionally driven rather than low-liquidity noise.
[/list]

[b]Retest Tracking[/b]
[list]
[*]After an SFP fires, the swept level is stored. If price later returns to that level and holds, a small [b]R[/b] label marks the retest candle. The retest is often a cleaner entry than the SFP candle itself.
[/list]

[b]Display[/b]
[list]
[*][b]Draw swept level lines[/b] — dashed line from the original pivot bar to the SFP bar, showing which level was grabbed.
[*][b]Show tracked pivot levels[/b] — draws all currently tracked pivots as dashed lines so you can watch levels in real time before an SFP forms.
[*][b]Remove pivot when swept[/b] — cleans up the level from storage once it has been used.
[/list]

[b]=================================[/b]
[b]RECOMMENDED TIMEFRAME[/b]

Works on all timeframes. Pivot bars auto-adjust between intraday and HTF values. Most actionable on [b]1H to 4H[/b] for intraday setups and [b]Daily[/b] for swing trading.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © cliteka-cell

//@version=6
indicator("Swing Failure Pattern (SFP)", shorttitle="SFP", overlay=true,
          max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// SWING FAILURE PATTERN (SFP)
//
// An SFP occurs when price wicks past a prior swing high or low — sweeping
// the liquidity sitting at that level — then closes back inside it.
//
// BULLISH SFP: wick below a prior swing low, close back above it.
// BEARISH SFP: wick above a prior swing high, close back below it.
// SFP+ / SFP++: single wick swept 2 or 3+ stacked pivot levels at once.
//
// OPTIONAL FILTERS:
//   HTF Trend  — only show signals that align with the higher timeframe trend.
//   Session    — only show signals during London or NY open windows.
//   Retest     — mark when price returns to the swept level and holds.
// ═══════════════════════════════════════════════════════════════════════════

// ── Pivot Detection ───────────────────────────────────────────────────────────
var g_p = "Pivot Detection"
piv_intra  = input.int  (8,   "Intraday pivot bars (1m to 4H)",  minval=2, maxval=50, group=g_p)
piv_htf    = input.int  (3,   "HTF pivot bars (Daily and above)", minval=2, maxval=20, group=g_p)
max_pivots = input.int  (5,   "Max pivots stored per side",       minval=1, maxval=10, group=g_p)
max_age    = input.int  (20,  "Max pivot age (days)",             minval=1, maxval=90, group=g_p)

// ── Effective pivot length based on current timeframe ─────────────────────────
bool is_htf  = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
int  eff_piv = is_htf ? piv_htf : piv_intra

// ── Filters ───────────────────────────────────────────────────────────────────
var g_f = "Filters"
min_sweep  = input.float(0.1,  "Min sweep size (ATR mult)", minval=0.0, maxval=5.0, step=0.05, group=g_f,
             tooltip="Wick must exceed the pivot by at least this multiple of ATR to qualify.")
close_pct  = input.int  (50,   "Min close position %",      minval=1,   maxval=99,  group=g_f,
             tooltip="Bullish SFP: close must be in the top X% of the bar. Bearish: bottom X%.")
use_vol    = input.bool (false, "Volume confirmation",                               group=g_f,
             tooltip="SFP bar must have above-average volume.")
vol_len    = input.int  (20,   "Volume MA length",          minval=5,   maxval=100, group=g_f)

// ── HTF Trend Filter ──────────────────────────────────────────────────────────
var g_h = "HTF Trend Filter"
use_htf    = input.bool      (false, "Enable HTF trend filter",  group=g_h,
             tooltip="Only show bullish SFPs in uptrends and bearish SFPs in downtrends.")
htf_tf     = input.timeframe ("D",   "HTF timeframe",            group=g_h)
htf_ma_len = input.int       (50,    "HTF EMA length",  minval=5, maxval=200, group=g_h)

// ── Session Filter ────────────────────────────────────────────────────────────
var g_s = "Session Filter"
use_session = input.bool(false, "Enable session filter",     group=g_s,
              tooltip="Only show SFPs that occur during the London or NY open windows.")
lon_open    = input.int (8,     "London open (UTC hour)",    minval=0, maxval=23, group=g_s)
lon_close   = input.int (10,    "London window end (UTC hour)", minval=0, maxval=23, group=g_s)
ny_open     = input.int (13,    "NY open (UTC hour)",        minval=0, maxval=23, group=g_s)
ny_close    = input.int (16,    "NY window end (UTC hour)",  minval=0, maxval=23, group=g_s)

// ── Retest Tracking ───────────────────────────────────────────────────────────
var g_r = "Retest Tracking"
show_retest  = input.bool (true,  "Track retests",             group=g_r,
               tooltip="Mark when price returns to the swept level and holds after an SFP.")
retest_tol   = input.float(0.3,   "Retest tolerance (ATR mult)", minval=0.05, maxval=2.0, step=0.05, group=g_r,
               tooltip="How close price must come to the swept level to count as a retest.")
c_retest     = input.color(color.new(color.yellow, 0), "Retest label color", group=g_r)

// ── Display ───────────────────────────────────────────────────────────────────
var g_d = "Display"
show_levels  = input.bool (true,  "Draw swept level lines",    group=g_d)
show_active  = input.bool (false, "Show tracked pivot levels", group=g_d,
               tooltip="Draws all currently tracked pivot levels as dashed lines.")
remove_swept = input.bool (true,  "Remove pivot when swept",   group=g_d)
c_bull       = input.color(color.new(color.lime, 0),   "Bullish SFP",       group=g_d)
c_bear       = input.color(color.new(color.red,  0),   "Bearish SFP",       group=g_d)
c_level      = input.color(color.new(color.gray, 50),  "Swept level line",  group=g_d)
c_active     = input.color(color.new(color.white, 75), "Active pivot line", group=g_d)

// ── ATR and volume ────────────────────────────────────────────────────────────
float atr    = ta.atr(14)
float vol_ma = ta.sma(volume, vol_len)
bool  vol_ok = not use_vol or volume >= vol_ma

// ── HTF trend direction ───────────────────────────────────────────────────────
float htf_close = request.security(syminfo.tickerid, htf_tf, close, lookahead=barmerge.lookahead_off)
float htf_ema   = request.security(syminfo.tickerid, htf_tf, ta.ema(close, htf_ma_len), lookahead=barmerge.lookahead_off)
bool  htf_bull  = not use_htf or htf_close > htf_ema
bool  htf_bear  = not use_htf or htf_close < htf_ema

// ── Session check ─────────────────────────────────────────────────────────────
int  utc_h      = hour(time, "UTC")
bool in_session = not use_session or
                  (utc_h >= lon_open and utc_h < lon_close) or
                  (utc_h >= ny_open  and utc_h < ny_close)

// ── Pivot storage ─────────────────────────────────────────────────────────────
var array<float> ph_prices = array.new<float>()
var array<int>   ph_bars   = array.new<int>()
var array<int>   ph_times  = array.new<int>()

var array<float> pl_prices = array.new<float>()
var array<int>   pl_bars   = array.new<int>()
var array<int>   pl_times  = array.new<int>()

int age_ms = max_age * 24 * 60 * 60 * 1000

// ── Retest storage ────────────────────────────────────────────────────────────
// type: 1 = bullish SFP level (expect retest from above), -1 = bearish (from below)
var array<float> rt_levels = array.new<float>()
var array<int>   rt_types  = array.new<int>()
var array<int>   rt_bars   = array.new<int>()
var array<int>   rt_times  = array.new<int>()

// ── Expire old pivots ─────────────────────────────────────────────────────────
f_expire_ph() =>
    if ph_prices.size() > 0
        for i = ph_prices.size() - 1 to 0
            if time - ph_times.get(i) > age_ms
                ph_prices.remove(i)
                ph_bars.remove(i)
                ph_times.remove(i)

f_expire_pl() =>
    if pl_prices.size() > 0
        for i = pl_prices.size() - 1 to 0
            if time - pl_times.get(i) > age_ms
                pl_prices.remove(i)
                pl_bars.remove(i)
                pl_times.remove(i)

// ── Detect new pivots ─────────────────────────────────────────────────────────
float ph = ta.pivothigh(high, eff_piv, eff_piv)
float pl = ta.pivotlow (low,  eff_piv, eff_piv)

if not na(ph)
    f_expire_ph()
    ph_prices.push(ph)
    ph_bars.push(bar_index - eff_piv)
    ph_times.push(time)
    while ph_prices.size() > max_pivots
        ph_prices.shift()
        ph_bars.shift()
        ph_times.shift()

if not na(pl)
    f_expire_pl()
    pl_prices.push(pl)
    pl_bars.push(bar_index - eff_piv)
    pl_times.push(time)
    while pl_prices.size() > max_pivots
        pl_prices.shift()
        pl_bars.shift()
        pl_times.shift()

// ── Draw active tracked pivot levels ─────────────────────────────────────────
if show_active and barstate.islast
    if ph_prices.size() > 0
        for i = 0 to ph_prices.size() - 1
            line.new(ph_bars.get(i), ph_prices.get(i), bar_index + 10, ph_prices.get(i),
                     xloc=xloc.bar_index, color=c_active, style=line.style_dashed, width=1)
    if pl_prices.size() > 0
        for i = 0 to pl_prices.size() - 1
            line.new(pl_bars.get(i), pl_prices.get(i), bar_index + 10, pl_prices.get(i),
                     xloc=xloc.bar_index, color=c_active, style=line.style_dashed, width=1)

// ── SFP detection ─────────────────────────────────────────────────────────────
if barstate.isconfirmed and in_session

    float bar_range   = high - low
    float close_ratio = bar_range > 0 ? (close - low) / bar_range : 0.5
    float reject_top  = close_pct / 100.0
    float reject_bot  = 1.0 - close_pct / 100.0

    // ── Bearish SFP ──────────────────────────────────────────────────────────
    int   bear_count  = 0
    array<int>   bear_idx    = array.new<int>()
    array<float> bear_levels = array.new<float>()

    if ph_prices.size() > 0 and htf_bear
        for i = 0 to ph_prices.size() - 1
            float lvl = ph_prices.get(i)
            bool bear_cond = high > lvl and (high - lvl) >= min_sweep * atr and close < lvl and close_ratio <= reject_bot and vol_ok
            if bear_cond
                bear_count += 1
                bear_idx.push(i)
                bear_levels.push(lvl)

    if bear_count > 0
        string lbl = bear_count == 1 ? "BrSFP" : bear_count == 2 ? "BrSFP+" : "BrSFP++"
        label.new(bar_index, high, lbl,
                  style=label.style_label_down,
                  color=c_bear, textcolor=color.white, size=size.small)

        if show_levels
            for i = 0 to bear_idx.size() - 1
                line.new(ph_bars.get(bear_idx.get(i)), bear_levels.get(i), bar_index, bear_levels.get(i),
                         xloc=xloc.bar_index, color=c_level, style=line.style_dashed, width=1)

        if show_retest
            for i = 0 to bear_levels.size() - 1
                rt_levels.push(bear_levels.get(i))
                rt_types.push(-1)
                rt_bars.push(bar_index)
                rt_times.push(time)

        if remove_swept
            for i = bear_idx.size() - 1 to 0
                int idx = bear_idx.get(i)
                ph_prices.remove(idx)
                ph_bars.remove(idx)
                ph_times.remove(idx)

    // ── Bullish SFP ──────────────────────────────────────────────────────────
    int   bull_count  = 0
    array<int>   bull_idx    = array.new<int>()
    array<float> bull_levels = array.new<float>()

    if pl_prices.size() > 0 and htf_bull
        for i = 0 to pl_prices.size() - 1
            float lvl = pl_prices.get(i)
            bool bull_cond = low < lvl and (lvl - low) >= min_sweep * atr and close > lvl and close_ratio >= reject_top and vol_ok
            if bull_cond
                bull_count += 1
                bull_idx.push(i)
                bull_levels.push(lvl)

    if bull_count > 0
        string lbl = bull_count == 1 ? "SFP" : bull_count == 2 ? "SFP+" : "SFP++"
        label.new(bar_index, low, lbl,
                  style=label.style_label_up,
                  color=c_bull, textcolor=color.white, size=size.small)

        if show_levels
            for i = 0 to bull_idx.size() - 1
                line.new(pl_bars.get(bull_idx.get(i)), bull_levels.get(i), bar_index, bull_levels.get(i),
                         xloc=xloc.bar_index, color=c_level, style=line.style_dashed, width=1)

        if show_retest
            for i = 0 to bull_levels.size() - 1
                rt_levels.push(bull_levels.get(i))
                rt_types.push(1)
                rt_bars.push(bar_index)
                rt_times.push(time)

        if remove_swept
            for i = bull_idx.size() - 1 to 0
                int idx = bull_idx.get(i)
                pl_prices.remove(idx)
                pl_bars.remove(idx)
                pl_times.remove(idx)

// ── Retest detection ─────────────────────────────────────────────────────────
if show_retest and barstate.isconfirmed and rt_levels.size() > 0
    float tol = retest_tol * atr
    for i = rt_levels.size() - 1 to 0
        float lvl  = rt_levels.get(i)
        int   typ  = rt_types.get(i)
        int   sbar = rt_bars.get(i)

        // Expire old retest levels
        if time - rt_times.get(i) > age_ms
            rt_levels.remove(i)
            rt_types.remove(i)
            rt_bars.remove(i)
            rt_times.remove(i)

        // Skip the SFP bar itself
        else if bar_index > sbar
            // Bullish retest: price pulls back to level from above and holds
            bool bull_retest = typ == 1 and low <= lvl + tol and low >= lvl - tol and close > lvl
            // Bearish retest: price pulls back to level from below and holds
            bool bear_retest = typ == -1 and high >= lvl - tol and high <= lvl + tol and close < lvl

            if bull_retest or bear_retest
                label.new(bar_index, typ == 1 ? low : high, "R",
                          style = typ == 1 ? label.style_label_up : label.style_label_down,
                          color=c_retest, textcolor=color.black, size=size.tiny)
                rt_levels.remove(i)
                rt_types.remove(i)
                rt_bars.remove(i)
                rt_times.remove(i)
````
