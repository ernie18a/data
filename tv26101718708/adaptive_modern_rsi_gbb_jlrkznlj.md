# Adaptive Modern RSI [GBB]

- url: https://www.tradingview.com/script/jlRKZnLj-Adaptive-Modern-RSI-GBB/
- type: indicator
- pine_id: PUB;3de396eea42b433daaaa3283971f65f4
- version: 1.0

## Description

[b]Adaptive Modern RSI[/b]

A self-tuning RSI. Instead of you picking a period and overbought/oversold levels and hoping you got it right, the indicator figures out the best settings from recent price action and adjusts as the market changes.

It tests 60 different parameter combinations on every bar (5 RSI periods, 3 smoother strengths, 4 threshold pairs), measures how each one would have performed over the last 300 bars, and uses whichever combination scored best. When the market shifts, the parameters shift with it.

The thinking behind it: Wilder published the RSI in 1978. The "14 period, 70/30 levels" defaults were chosen for stock markets that traded a few hours a day. Crypto, 24/7 markets, and modern volatility didn't exist yet. 

[b] What you see on the chart[/b]

The aqua line is the active RSI — whichever period and smoother the optimizer currently picked.

The red and green horizontal lines are the adaptive overbought and oversold levels. They step when the optimizer changes its mind about what counts as "extreme" for this asset right now.

Red triangles fire when the RSI rolls over from overbought. Green triangles fire when it enters oversold. Both fire on bar close and never repaint.

The label at the top tells you what kind of market the recent past has been. Five possible regimes:

[list=1]
[*]Mean-reverting chop — Fast reversals at extremes. RSI triggers are most reliable here.
[*]Quiet range — Mild swings, modest signal. Use as light confluence only.
[*]Trending — Mean reversion is dangerous here. Use the RSI for pullback entries in the trend direction, not for fading.
[*]Noisy transition — The indicator can't find a stable read. Step back, wait for clarity.
[*]Adapting — Warming up on a fresh chart. Give it the lookback period worth of bars.
[/list]

Next to the regime name you'll see "held N bars." That tells you how long the current regime read has been stable. A regime held for 200+ bars is a confident read. A regime that just flipped (held 5 bars) is fresh and should be weighted lightly.

[b]How to use it per regime[/b]

[i]Mean-reverting chop[/i]:This is the regime RSI was designed for. Use the triggers actively, with normal confluence requirements (price at a level, HTF context, etc.). Tight stops, normal targets.

[i]Quiet range:[/i] Triggers work but the moves are small. Better for intraday scalp confluence than positional setups. Don't size up on triggers alone.

[i]Trending[/i]: Invert the classic logic. Green triangles in an uptrend are pullback buys, not counter-trend opportunities. Red triangles in a downtrend are bounce shorts. Never fade triggers against the trend in this regime — that's how RSI users blow up accounts.

[i]Noisy transition[/i]: Sit on your hands. The indicator is telling you it can't find a signal. This is rare but valuable information — most indicators don't admit when they don't know.

[i]Adapting[/i]: Wait. On 1H with default 300-bar lookback, this takes about 12-13 days of data.

[b]What it works on[/b]

Designed for crypto, but the logic is asset-agnostic. The optimizer figures out the right parameters from whatever data you give it. Tested on:

- Crypto (BTC, ETH, majors) on 5M through 1D
- Forex majors on 15M through 4H
- Indices (NDX, SPX, DAX) on 1H through 1D
- Gold on 1H through 1D

On lower timeframes (5M, 15M), consider raising the optimization lookback from 300 to 500-700 bars. On higher timeframes (4H, 1D), you can lower it to 100-200. The default 300 is tuned for 1H. The tooltip on the input has more detail.

Everything else (forward-return horizon, switch margin, regime hysteresis) can stay at defaults across all assets and timeframes for a first pass.

[b]What it is not[/b]

A complete trading system. This is one RSI layer. It tells you something about momentum and mean-reversion potential. It does not tell you about trend, volume, market structure, key levels, or risk management. If you trade off this alone, you will lose money.

A leading indicator. Triggers fire on bar close, after the crossover happens. There is no lag in the sense of waiting for confirmation bars, but there is also no prediction. The indicator is reactive to closed-bar price action, not forecasting future bars.

A backtest-proof strategy. The parameter optimization is backward-looking. It tunes to what worked recently. At regime transitions (chop becoming trend, trend becoming crash), the indicator will lag because its lookback window is still anchored to the old regime. The regime label and the "held N bars" counter give you the information to know when to trust it more or less.

[b]Settings[/b]

[i]Optimization lookback (default 300)[/i]: How many bars the optimizer searches over. Shorter adapts faster but jitters more. Longer is stabler but slower to catch genuine regime shifts.

[i]Forward-return evaluation horizon (default 5)[/i]: How many bars forward the optimizer measures trigger payoffs. 5 is a reasonable mean-reversion timescale. Bump to 8-10 for forex if you want to.

[i]Switch margin (default 10%)[/i]: New parameter winners need to beat the current ones by this much to take over. Higher means stickier parameters.

[i]Minimum triggers required (default 5)[/i]: Candidates firing fewer than this many times in the lookback are disqualified. Prevents noisy low-sample-size winners.

[i]Regime label hysteresis (default 10):[/i] Bars the new regime classification must hold before the displayed label updates. Higher means more stable label, slower to react to genuine shifts.

[i]Regime label size[/i]: Tiny to huge. Pick whatever fits your screen.

[b]Final note[/b]

This indicator does not replace thinking. It does not replace risk management. It does not replace knowing the asset you're trading. It gives you a better RSI than 1978's defaults. The rest is on you.


Made by The Good, the Bad and the Bitcoin (GBB)
Quantitative trading research with no shilling, no paywall, and no hype.

## Source Code

````pine
//@version=6
indicator("Adaptive Modern RSI [GBB]", 
     shorttitle="A-MRSI", 
     overlay=false, 
     precision=2,
     max_lines_count=50, 
     max_labels_count=20,
     max_bars_back=1000)

// ============================================================================
//  INPUTS
// ============================================================================
g_core = "Adaptation"
lookback     = input.int(300,  "Optimization lookback (bars)",    minval=100, maxval=1000, group=g_core,
                         tooltip="Window for parameter search. 200-500 typical on 1H BTC. Shorter = faster adaptation, more jitter.")
eval_bars    = input.int(5,    "Forward-return eval horizon",     minval=2,   maxval=20, group=g_core,
                         tooltip="How many bars forward to measure mean-reversion success per trigger.")
switch_margin = input.float(10.0, "Switch margin (%)",            minval=0.0, maxval=50.0, step=2.5, group=g_core,
                            tooltip="New winner must beat current by this % to switch. Higher = stickier parameters.")
min_triggers  = input.int(5,   "Min triggers required per candidate", minval=2, group=g_core,
                          tooltip="Candidates firing fewer than this many times in the lookback are disqualified.")

g_regime = "Regime label"
show_regime         = input.bool(true, "Show regime label",           group=g_regime)
regime_size         = input.string("normal", "Regime label size", options=["tiny", "small", "normal", "large", "huge"], group=g_regime)
regime_hysteresis   = input.int(10, "Min bars to confirm regime change", minval=1, maxval=100, group=g_regime,
                                tooltip="Optimizer's regime classification must hold this many bars before the displayed label updates. Higher = stabler label, slower to react to genuine regime shifts.")

g_disp = "Display"
show_levels  = input.bool(true, "Show adaptive OS/OB lines",   group=g_disp)

// ============================================================================
//  CONSTANTS
// ============================================================================
N_PI = 5
N_SI = 3
N_TI = 4
N_CAND = N_PI * N_SI * N_TI

// Regime codes (kept as ints so we can compare easily for hysteresis)
REG_ADAPTING  = 0
REG_NOISY     = 1
REG_TREND     = 2
REG_CHOP      = 3
REG_QUIET     = 4

// ============================================================================
//  HELPERS
// ============================================================================
supersmoother(float src, simple int period) =>
    a  = math.exp(-math.sqrt(2) * math.pi / period)
    b  = 2 * a * math.cos(math.sqrt(2) * math.pi / period)
    c2 = b
    c3 = -a * a
    c1 = 1 - c2 - c3
    var float ss = 0.0
    src1 = nz(src[1], src)
    ss1  = nz(ss[1],  src)
    ss2  = nz(ss[2],  src)
    ss := c1 * (src + src1) / 2 + c2 * ss1 + c3 * ss2
    ss

ss_rsi(simple int rsi_period, simple int smooth_period) =>
    chg = ta.change(close)
    g_ = math.max(chg,  0)
    l_ = math.max(-chg, 0)
    ag = supersmoother(g_, smooth_period)
    al = supersmoother(l_, smooth_period)
    rs = al == 0 ? na : ag / al
    100 - 100 / (1 + rs)

rsi_7_6   = ss_rsi(7, 6)
rsi_7_10  = ss_rsi(7, 10)
rsi_7_16  = ss_rsi(7, 16)
rsi_10_6  = ss_rsi(10, 6)
rsi_10_10 = ss_rsi(10, 10)
rsi_10_16 = ss_rsi(10, 16)
rsi_14_6  = ss_rsi(14, 6)
rsi_14_10 = ss_rsi(14, 10)
rsi_14_16 = ss_rsi(14, 16)
rsi_21_6  = ss_rsi(21, 6)
rsi_21_10 = ss_rsi(21, 10)
rsi_21_16 = ss_rsi(21, 16)
rsi_28_6  = ss_rsi(28, 6)
rsi_28_10 = ss_rsi(28, 10)
rsi_28_16 = ss_rsi(28, 16)

get_rsi(int pi, int si) =>
    float out = na
    if pi == 0 and si == 0
        out := rsi_7_6
    else if pi == 0 and si == 1
        out := rsi_7_10
    else if pi == 0 and si == 2
        out := rsi_7_16
    else if pi == 1 and si == 0
        out := rsi_10_6
    else if pi == 1 and si == 1
        out := rsi_10_10
    else if pi == 1 and si == 2
        out := rsi_10_16
    else if pi == 2 and si == 0
        out := rsi_14_6
    else if pi == 2 and si == 1
        out := rsi_14_10
    else if pi == 2 and si == 2
        out := rsi_14_16
    else if pi == 3 and si == 0
        out := rsi_21_6
    else if pi == 3 and si == 1
        out := rsi_21_10
    else if pi == 3 and si == 2
        out := rsi_21_16
    else if pi == 4 and si == 0
        out := rsi_28_6
    else if pi == 4 and si == 1
        out := rsi_28_10
    else if pi == 4 and si == 2
        out := rsi_28_16
    out

get_rsi_back(int pi, int si, int back) =>
    float out = na
    if pi == 0 and si == 0
        out := rsi_7_6[back]
    else if pi == 0 and si == 1
        out := rsi_7_10[back]
    else if pi == 0 and si == 2
        out := rsi_7_16[back]
    else if pi == 1 and si == 0
        out := rsi_10_6[back]
    else if pi == 1 and si == 1
        out := rsi_10_10[back]
    else if pi == 1 and si == 2
        out := rsi_10_16[back]
    else if pi == 2 and si == 0
        out := rsi_14_6[back]
    else if pi == 2 and si == 1
        out := rsi_14_10[back]
    else if pi == 2 and si == 2
        out := rsi_14_16[back]
    else if pi == 3 and si == 0
        out := rsi_21_6[back]
    else if pi == 3 and si == 1
        out := rsi_21_10[back]
    else if pi == 3 and si == 2
        out := rsi_21_16[back]
    else if pi == 4 and si == 0
        out := rsi_28_6[back]
    else if pi == 4 and si == 1
        out := rsi_28_10[back]
    else if pi == 4 and si == 2
        out := rsi_28_16[back]
    out

get_os(int ti) =>
    ti == 0 ? 15.0 : ti == 1 ? 20.0 : ti == 2 ? 25.0 : 30.0
get_ob(int ti) =>
    ti == 0 ? 85.0 : ti == 1 ? 80.0 : ti == 2 ? 75.0 : 70.0
get_p(int pi) =>
    pi == 0 ? 7 : pi == 1 ? 10 : pi == 2 ? 14 : pi == 3 ? 21 : 28
get_s(int si) =>
    si == 0 ? 6 : si == 1 ? 10 : 16

cand_idx(int pi, int si, int ti) =>
    pi * N_SI * N_TI + si * N_TI + ti

size_from_string(string s) =>
    s == "tiny"   ? size.tiny   : s == "small"  ? size.small  : s == "normal" ? size.normal : s == "large"  ? size.large  : size.huge

// ============================================================================
//  INCREMENTAL SCORING
// ============================================================================
trigger_at(int pi, int si, int ti, int b) =>
    int  kind = 0
    float fret = 0.0
    r_now = get_rsi_back(pi, si, b)
    r_prv = get_rsi_back(pi, si, b + 1)
    os_t = get_os(ti)
    ob_t = get_ob(ti)
    if not na(r_now) and not na(r_prv)
        os_entry = r_prv >= os_t and r_now < os_t
        ob_exit  = r_prv >= ob_t and r_now < ob_t and r_prv > ob_t
        if os_entry
            p_then = close[b]
            p_fwd  = close[b - eval_bars]
            if not na(p_then) and not na(p_fwd) and p_then > 0
                kind := 1
                fret := p_fwd / p_then - 1
        else if ob_exit
            p_then = close[b]
            p_fwd  = close[b - eval_bars]
            if not na(p_then) and not na(p_fwd) and p_then > 0
                kind := 2
                fret := -(p_fwd / p_then - 1)
    [kind, fret]

var array<float> sum_ret  = array.new<float>(N_CAND, 0.0)
var array<int>   trig_cnt = array.new<int>(N_CAND, 0)

if bar_index > lookback + eval_bars
    for pi = 0 to N_PI - 1
        for si = 0 to N_SI - 1
            for ti = 0 to N_TI - 1
                idx = cand_idx(pi, si, ti)
                [add_kind, add_fret] = trigger_at(pi, si, ti, eval_bars)
                if add_kind != 0
                    array.set(sum_ret,  idx, array.get(sum_ret,  idx) + add_fret)
                    array.set(trig_cnt, idx, array.get(trig_cnt, idx) + 1)
                [sub_kind, sub_fret] = trigger_at(pi, si, ti, lookback)
                if sub_kind != 0
                    array.set(sum_ret,  idx, array.get(sum_ret,  idx) - sub_fret)
                    array.set(trig_cnt, idx, array.get(trig_cnt, idx) - 1)

// ============================================================================
//  SEARCH
// ============================================================================
var int   active_pi = 2
var int   active_si = 1
var int   active_ti = 2
var float active_score = na

if bar_index > lookback + eval_bars
    float best_score = na
    int   best_pi = active_pi
    int   best_si = active_si
    int   best_ti = active_ti
    for pi = 0 to N_PI - 1
        for si = 0 to N_SI - 1
            for ti = 0 to N_TI - 1
                idx = cand_idx(pi, si, ti)
                cnt = array.get(trig_cnt, idx)
                if cnt >= min_triggers
                    sc = array.get(sum_ret, idx) / cnt
                    if na(best_score) or sc > best_score
                        best_score := sc
                        best_pi := pi
                        best_si := si
                        best_ti := ti
    if not na(best_score)
        if na(active_score)
            active_pi := best_pi
            active_si := best_si
            active_ti := best_ti
            active_score := best_score
        else
            cur_idx = cand_idx(active_pi, active_si, active_ti)
            cur_cnt = array.get(trig_cnt, cur_idx)
            cur_sc = cur_cnt >= min_triggers ? array.get(sum_ret, cur_idx) / cur_cnt : na
            if not na(cur_sc)
                active_score := cur_sc
            margin = math.abs(active_score) * switch_margin / 100.0
            if best_score > active_score + margin
                active_pi := best_pi
                active_si := best_si
                active_ti := best_ti
                active_score := best_score

// ============================================================================
//  ACTIVE RSI + THRESHOLDS
// ============================================================================
active_rsi = get_rsi(active_pi, active_si)
active_os  = get_os(active_ti)
active_ob  = get_ob(active_ti)
active_p   = get_p(active_pi)
active_s   = get_s(active_si)

zone_state = na(active_rsi) ? na : active_rsi < active_os ? -1 : active_rsi > active_ob ? 1 : 0

os_entry_now = active_rsi[1] >= active_os and active_rsi < active_os
ob_exit_now  = active_rsi[1] >= active_ob and active_rsi < active_ob and active_rsi[1] > active_ob

// ============================================================================
//  RAW REGIME CLASSIFICATION (per-bar, before hysteresis)
// ============================================================================
classify_regime() =>
    int code = REG_ADAPTING
    if na(active_score)
        code := REG_ADAPTING
    else if math.abs(active_score) < 0.0005 and active_si == 2
        code := REG_NOISY
    else if active_pi >= 3 and active_ti >= 2
        code := REG_TREND
    else if active_pi <= 1 and active_ti <= 1
        code := REG_CHOP
    else
        code := REG_QUIET
    code

raw_regime = classify_regime()

// ============================================================================
//  HYSTERESIS — confirmed regime + bars-held counter
//
// State machine:
//   - displayed_regime: the currently shown label (only updates after confirmation)
//   - candidate_regime: the regime the optimizer is currently classifying as
//   - candidate_streak: bars the candidate has held continuously
//   - bars_held: bars the displayed regime has been displayed
//
// Promotion rule: when candidate_streak reaches regime_hysteresis AND candidate
// differs from displayed, the candidate gets promoted to displayed and the
// bars_held counter resets.
// ============================================================================
var int displayed_regime  = REG_ADAPTING
var int candidate_regime  = REG_ADAPTING
var int candidate_streak  = 0
var int bars_held         = 0

if raw_regime == candidate_regime
    candidate_streak += 1
else
    candidate_regime := raw_regime
    candidate_streak := 1

if candidate_streak >= regime_hysteresis and candidate_regime != displayed_regime
    displayed_regime := candidate_regime
    bars_held := 1
else
    bars_held += 1

// ============================================================================
//  REGIME LABEL TEXT
// ============================================================================
regime_text(int code) =>
    string lbl  = ""
    string desc = ""
    color  col  = color.gray
    if code == REG_ADAPTING
        lbl  := "Adapting"
        desc := "Indicator still warming up"
        col  := color.gray
    else if code == REG_NOISY
        lbl  := "Noisy transition"
        desc := "Mean reversion signal weak — wait for clearer regime"
        col  := color.orange
    else if code == REG_TREND
        lbl  := "Trending"
        desc := "Mean reversion less reliable — favor trend-continuation signals"
        col  := color.new(color.blue, 0)
    else if code == REG_CHOP
        lbl  := "Mean-reverting chop"
        desc := "Fast reversals at extremes — RSI triggers most reliable here"
        col  := color.new(color.green, 0)
    else
        lbl  := "Quiet range"
        desc := "Mild swings, moderate signal — use as light confluence"
        col  := color.new(color.teal, 0)
    [lbl, desc, col]

[reg_lbl, reg_desc, reg_col] = regime_text(displayed_regime)

// ============================================================================
//  PLOTTING
// ============================================================================
plot(active_rsi, "Active RSI", color=color.new(color.aqua, 0), linewidth=2)
hline(50, "mid", color=color.new(color.white, 80), linestyle=hline.style_dotted)

plot(show_levels ? active_os : na, "Adaptive OS", color=color.new(color.lime, 30), linewidth=1, style=plot.style_stepline)
plot(show_levels ? active_ob : na, "Adaptive OB", color=color.new(color.red,  30), linewidth=1, style=plot.style_stepline)

plotshape(os_entry_now ? active_os : na, "OS entry trigger", shape.triangleup,   location.absolute, color=color.lime, size=size.small)
plotshape(ob_exit_now  ? active_ob : na, "OB exit trigger",  shape.triangledown, location.absolute, color=color.red,  size=size.small)

plot(zone_state,        "zone_state",        display=display.data_window)
plot(active_p,          "active_period",     display=display.data_window)
plot(active_s,          "active_smooth",     display=display.data_window)
plot(active_os,         "active_os",         display=display.data_window)
plot(active_ob,         "active_ob",         display=display.data_window)
plot(active_score,      "active_score",      display=display.data_window)
plot(displayed_regime,  "displayed_regime",  display=display.data_window)
plot(bars_held,         "regime_bars_held",  display=display.data_window)

// ============================================================================
//  REGIME LABEL — anchored at top of pane with bars-held counter
// ============================================================================
if show_regime and barstate.islast
    var label reg_label = na
    label.delete(reg_label)
    held_str = "held " + str.tostring(bars_held) + " bars"
    txt = "Regime: " + reg_lbl + " (" + held_str + ")\n" + reg_desc
    reg_label := label.new(x=bar_index, y=100, text=txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(reg_col, 70), textcolor=color.white, size=size_from_string(regime_size))

// ============================================================================
//  ALERTS
// ============================================================================
alertcondition(os_entry_now, "Adaptive RSI: OS entry")
alertcondition(ob_exit_now,  "Adaptive RSI: OB exit")
alertcondition(displayed_regime != displayed_regime[1], "Adaptive RSI: regime change")
````
