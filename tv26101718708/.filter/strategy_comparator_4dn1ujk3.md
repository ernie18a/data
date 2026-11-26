# Strategy Comparator

- url: https://www.tradingview.com/script/4Dn1ujK3-Strategy-Comparator/
- type: indicator
- pine_id: PUB;c2118529798b4105b64599cdfbf9ac94
- version: 1.0

## Description

[b]Strategy Comparator[/b]

[b]Important — script type[/b]

This is a Pine v6 [b]indicator()[/b] script, NOT a strategy() script. TradingView's built-in [i]Strategy Tester[/i] does NOT apply to this script. All backtesting metrics (equity curve, return, Sharpe, R-Ratio, win rate, profit factor, max drawdown, Calmar) are computed internally and displayed in this script's own ranking table on the chart, plus on-chart entry markers and alerts.


[b]What it does[/b]

A single indicator that runs a live backtest of 18 strategy configurations across a grid of 6 assets × 4 timeframes (up to 1h), ranks them by the chosen metric (default [b]R-Ratio[/b]), and surfaces the best (asset, strategy) combination automatically on the chart.


[b]Originality (not a mashup)[/b]

This is a self-contained decision framework — not a stack of standard indicators or signals. The three components that make it original:

- [b]Dynamic concurrent backtest engine[/b] — the table values are computed live on every bar via [i]request.security[/i] across 24 (asset, timeframe) cells, each running all 18 strategy implementations and tracking 6 statistics per strategy. Changing parameters, side, or timeframe re-evaluates the entire grid on the fly. No precomputed values.
- [b]R-Ratio ranking metric[/b] — a single number combining return and smoothness via an OLS regression on log-equity vs time in years (R² × slope). Selects strategies that grow linearly rather than via lucky spikes. Available alongside Sharpe, Win Rate, Total Return, Calmar, Profit Factor and Max DD.
- [b]Confidence score (0–100)[/b] — a quantitative layer that tests whether the top candidate's edge is meaningful or compatible with noise. Combines: R-Ratio strength (scale-invariant), edge over direction-weighted passive baselines (HODL for long-biased time, REKT for short-biased time), edge over RAND (statistical baseline), win rate excess over 50%, and Kelly fraction = p × (1 − 1/PF). Shown in title as [i]CONF X/100[/i].


[b]The 18 strategy configurations[/b]

- [b]1. HODL[/b] — Always long. Buy & hold reference.
- [b]2. REKT[/b] — Always short. Opposite of HODL.
- [b]3. RAND[/b] — Random positions (-1 / 0 / +1). Statistical baseline.
- [b]4. BBANDS[/b] — Bollinger Bands, 3 selectable behaviors (mean reversion, exit at midline, breakout outside).
- [b]5. KELTNER[/b] — Keltner Channel breakout (EMA ± ATR × multiplier).
- [b]6. SMA[/b] — Two-SMA crossover (fast vs slow).
- [b]7. MACD[/b] — MACD line / signal line crossover.
- [b]8. MOM[/b] — Momentum: current price vs price N bars ago.
- [b]9. BREAKOUT[/b] — Donchian Channel: long above N-bar high, short below N-bar low.
- [b]10. RSI[/b] — RSI thresholds, 3 selectable behaviors.
- [b]11. RWI[/b] — Random Walk Index (fast and slow).
- [b]12. OUTSIDE[/b] — Outside-bar pattern with candle-color direction.
- [b]13. CONSEC[/b] — N consecutive up/down bars for direction.
- [b]14. SUPER[/b] — Native Supertrend (ATR-based trailing stop).
- [b]15. TRATINGS[/b] — Aggregate of 14 sub-indicators (SMA/EMA on 6 periods, HMA, VWMA, Ichimoku, RSI, Stoch, CCI, ADX, AO, MOM, MACD, StochRSI, Williams %R, Bulls/Bears Power, Ultimate Oscillator). MA / Oscillator / Both groups selectable.
- [b]16. PSAR[/b] — Parabolic SAR.
- [b]17. STOCH[/b] — Stochastic Slow with overbought/oversold thresholds.
- [b]18. WICKS[/b] — Cumulative upper-vs-lower wick imbalance over a rolling period.

Every strategy honors the [b]Side[/b] input (Long Only / Short Only / Both). In Long Only mode, an opposite-direction signal closes the long position to flat (and symmetric for Short Only).


[b]How to use[/b]

1. Add it to your chart.
2. Leave the 6 asset slots empty to test only the chart symbol, or fill them to compare different symbols side by side. Duplicate slots are deduplicated automatically.
3. Read the [b]first row[/b] of the ranking table — that's the best combination by the chosen metric averaged over the 4 timeframes.
4. On the chart, the top strategy's [b]long[/b] (green label below the bar) and [b]short[/b] (red label above the bar) entries are plotted with the strategy name as label. A state machine suppresses consecutive same-direction signals; exits to flat reset the state.
5. Read the [b]CONF X/100[/b] in the title row as a quick "should I trust this?" gauge.
6. Tick [b]Show selected strategy[/b] in the [i]Strategy Override[/i] group to force a specific strategy (overrides the ranking).
7. Create one TradingView alert on the indicator with condition "Any alert() function call" — it covers every entry of the currently tracked strategy. Frequency: Once Per Bar Close (no repaint).


[b]Non-repainting[/b]

- Markers: rendered once at chart load for the full history, then incrementally only at confirmed real-time bar closes. No intra-bar flicker.
- Alerts: fire only on [i]alert.freq_once_per_bar_close[/i].


[b]Main inputs[/b]

- [b]Strategy Override[/b] (checkbox + dropdown) — force a specific strategy as TOP regardless of ranking.
- [b]6 asset slots[/b] (optional) — empty falls back to chart symbol.
- [b]4 timeframe slots[/b] (max 1h).
- [b]History (bars per cell)[/b] — backtest depth, 100–5000 step 50, default 1000.
- [b]Ranking metric[/b] — R-Ratio (default), Sharpe, Win Rate %, Total Return %, Calmar, Profit Factor, Max DD %.
- [b]Side[/b] — Long Only / Short Only / Both.
- [b]Top N (markers)[/b] — how many top-ranked strategies to plot on the chart (1–10, default 1).
- [b]Top N (table)[/b] — how many rows to display in the ranking table (5–98).
- [b]Show signal markers[/b], [b]Enable alerts[/b], [b]Table position[/b], [b]Table size[/b].
- Per-strategy parameters (period, threshold, multiplier, etc.).


[b]Limits[/b]

- Up to 4 timeframes and 6 assets, with 1h as the highest allowed timeframe (Pine [i]request.security[/i] cap of 40 calls — 24 used).
- History limited to 5000 bars per cell (Pine [i]max_bars_back[/i] cap).
- HODL / REKT / RAND are control strategies (baselines): if they appear at the top of the ranking, the technical strategies are underperforming buy & hold or random.
- All UI labels and tooltips are in English. Translations can be requested in comments if needed.

## Source Code

````pine
// Strategy Comparator
// Pine v6 indicator - compares 18 strategies on a grid of 6 assets x 4 timeframes (max 1h).
// Pine mirror of the strategies in backend/aelium/framework/layers/strategy_layer.py
//
// Budget: 24 request.security() calls for the grid (within the limit of 40).
// History configurable via histBars input (default 1000, applied as calc_bars_count).
// Output: comparative table with heatmap + Top-5 + equity curve of the selected cell.

//@version=6
indicator("Strategy Comparator", overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=5000)

// ============================================================
// INPUTS
// ============================================================
g_override = "Strategy Override"
useOverride = input.bool(false, "Show selected strategy", group=g_override,
     tooltip="If checked, markers / alerts / confidence track ONLY the strategy chosen in the dropdown below, ignoring the auto-detected top. If unchecked, the dropdown value is ignored.")
overrideTop = input.string("SUPER", "Selected strategy",
     options=["HODL", "REKT", "RAND", "BBANDS", "KELTNER", "SMA", "MACD", "MOM", "BREAKOUT", "RSI", "RWI", "OUTSIDE", "CONSEC", "SUPER", "TRATINGS", "PSAR", "STOCH", "WICKS"],
     group=g_override,
     tooltip="Only effective when 'Show selected strategy' is checked.")

g_assets = "Assets (max 6, optional — empty = chart symbol)"
asset1_in = input.symbol("", "Asset 1", group=g_assets, tooltip="Leave empty to use the chart symbol")
asset2_in = input.symbol("", "Asset 2", group=g_assets)
asset3_in = input.symbol("", "Asset 3", group=g_assets)
asset4_in = input.symbol("", "Asset 4", group=g_assets)
asset5_in = input.symbol("", "Asset 5", group=g_assets)
asset6_in = input.symbol("", "Asset 6", group=g_assets)
// Fallback to chart symbol if empty
asset1 = asset1_in == "" ? syminfo.tickerid : asset1_in
asset2 = asset2_in == "" ? syminfo.tickerid : asset2_in
asset3 = asset3_in == "" ? syminfo.tickerid : asset3_in
asset4 = asset4_in == "" ? syminfo.tickerid : asset4_in
asset5 = asset5_in == "" ? syminfo.tickerid : asset5_in
asset6 = asset6_in == "" ? syminfo.tickerid : asset6_in

g_tfs = "Timeframes (max 4, max 1h)"
tf1 = input.timeframe("5",  "TF 1", group=g_tfs)
tf2 = input.timeframe("10", "TF 2", group=g_tfs)
tf3 = input.timeframe("30", "TF 3", group=g_tfs)
tf4 = input.timeframe("60", "TF 4", group=g_tfs)

g_perf = "Performance"
histBars = input.int(1000, "History (bars per cell)",
     minval=100, maxval=5000, step=50, group=g_perf,
     tooltip="Maximum number of bars computed per cell via calc_bars_count. Higher values = longer backtest and more stable ranking but more memory/compute. Range 100-5000 (Pine v6 max_bars_back cap), step 50. Default 1000. If you see 'Memory limit exceeded' lower the value; if you want more ranking stability (e.g. for ranking metrics with very close values), increase it.")

g_view = "Ranking Table"
topN        = input.int(20, "Top N combos to show", minval=5, maxval=98, group=g_view,
     tooltip="Shows the top N (Asset, Strategy) pairs sorted by the average of the chosen metric across the 4 timeframes. Max 98 (Pine table limit).")

g_signals = "Signal Markers"
topRangeN = input.int(1, "Strategies to plot (rank 1..N)", minval=1, maxval=10, group=g_signals,
     tooltip="Plots entry markers for the top N strategies. Each marker has the rank number (1=best, 2=second, ...). Green=long, red=short. After a long, subsequent longs are suppressed until the next short, and vice versa. Ignored when 'Show selected strategy' is enabled in the Strategy Override group.")

g_metric = "Ranking Metric"
metricChoice = input.string("R-Ratio", "Metric",
     options=["R-Ratio", "Sharpe", "Win Rate %", "Total Return %", "Calmar", "Profit Factor", "Max DD %"],
     group=g_metric,
     tooltip="R-Ratio = R^2 * slope of an OLS regression on log(equity) vs time in years. Rewards smooth equity curves with positive trend (high = smooth + profitable).")

g_side = "Side"
sideStr = input.string("Both", "Side", options=["Both", "Long Only", "Short Only"], group=g_side)
side = sideStr == "Long Only" ? 1 : sideStr == "Short Only" ? -1 : 0

// ---- Strategy params ----
g_strat = "Strategy Params"
sma_fast      = input.int(20,   "SMA fast",        group=g_strat)
sma_slow      = input.int(50,   "SMA slow",        group=g_strat)
macd_fast     = input.int(12,   "MACD fast",       group=g_strat)
macd_slow     = input.int(26,   "MACD slow",       group=g_strat)
macd_sig      = input.int(9,    "MACD signal",     group=g_strat)
bb_period     = input.int(20,   "BB period",       group=g_strat)
bb_mult       = input.float(2.0,"BB mult",         group=g_strat)
bb_behavior   = input.int(1,    "BB behavior 1/2/3", minval=1, maxval=3, group=g_strat)
kc_period     = input.int(20,   "KC period",       group=g_strat)
kc_mult       = input.float(2.0,"KC mult",         group=g_strat)
rsi_period    = input.int(14,   "RSI period",      group=g_strat)
rsi_lth       = input.int(30,   "RSI low th",      group=g_strat)
rsi_hth       = input.int(70,   "RSI high th",     group=g_strat)
rsi_behavior  = input.int(1,    "RSI behavior 1/2/3", minval=1, maxval=3, group=g_strat)
mom_period    = input.int(20,   "MOM period",      group=g_strat)
brk_period    = input.int(10,   "BREAKOUT period", group=g_strat)
rwi_fast      = input.int(4,    "RWI fast",        group=g_strat)
rwi_slow      = input.int(15,   "RWI slow",        group=g_strat)
cons_up       = input.int(3,    "CONSEC up",       group=g_strat)
cons_dn       = input.int(3,    "CONSEC down",     group=g_strat)
st_period     = input.int(10,   "SUPERTREND period", group=g_strat)
st_factor     = input.float(3.0,"SUPERTREND factor", group=g_strat)
psar_start    = input.float(0.02,"PSAR start",     group=g_strat)
psar_accel    = input.float(0.02,"PSAR accel",     group=g_strat)
psar_max      = input.float(0.2, "PSAR max",       group=g_strat)
stoch_period  = input.int(14,   "STOCH period",    group=g_strat)
stoch_smk     = input.int(3,    "STOCH smoothK",   group=g_strat)
stoch_smd     = input.int(3,    "STOCH smoothD",   group=g_strat)
stoch_ob      = input.int(70,   "STOCH overbought", group=g_strat)
stoch_os      = input.int(30,   "STOCH oversold",  group=g_strat)
wicks_period  = input.int(10,   "WICKS period",    group=g_strat)
wicks_mult    = input.float(0.75,"WICKS mult",     group=g_strat)
wicks_th      = input.float(0.75,"WICKS th",       group=g_strat)
trat_strong   = input.bool(false,"TRATINGS strong-only", group=g_strat)
trat_table    = input.int(0,    "TRATINGS table 0=All/1=MA/2=Osc", minval=0, maxval=2, group=g_strat)

g_misc = "Misc"
showSignals    = input.bool(true,  "Show entry/exit markers (top strategy)", group=g_misc,
     tooltip="Plots buy/sell arrows and exit markers on the chart for the strategy currently at the top of the ranking table.")
enableAlerts   = input.bool(true,  "Enable entry/exit alerts", group=g_misc,
     tooltip="Fires dynamic alerts on the top strategy. A single 'Any alert() function call' subscription covers all signals.")
tableSize      = input.string("normal", "Table size", options=["tiny","small","normal","large"], group=g_misc)
mainTablePosIn = input.string("top_right", "Table position",
     options=["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"],
     group=g_misc)

// ============================================================
// HELPERS
// ============================================================

// Sign helper
f_sign(x) => x > 0 ? 1 : x < 0 ? -1 : 0

// Apply side filter to long/short signals -> position
f_apply_side(simple int side_, bool longSig, bool shortSig, float prevPos) =>
    float p = prevPos
    if side_ == 1
        if longSig
            p := 1
        else if shortSig
            p := 0
    else if side_ == -1
        if longSig
            p := 0
        else if shortSig
            p := -1
    else
        if longSig
            p := 1
        else if shortSig
            p := -1
    p

// MA rating helper for TRATINGS (must be top-level - Pine v6 disallows nested funcs)
f_ma_rating(float ma) => ma < close ? 1.0 : ma > close ? -1.0 : 0.0

// ============================================================
// STRATEGY FUNCTIONS - each returns a series of {-1, 0, 1}
// ============================================================

// 1. HODL (always long)
strat_hodl() => 1.0

// 2. REKT (always short)
strat_rekt() => -1.0

// 3. RAND
strat_rand() =>
    r = math.random(-1.0, 1.0)
    r > 0.33 ? 1.0 : r < -0.33 ? -1.0 : 0.0

// 4. BBANDS
strat_bbands(simple int side_, simple int period, simple float mult, simple int behavior) =>
    [mid, upper, lower] = ta.bb(close, period, mult)
    var float pos = 0.0
    if behavior == 1
        longSig  = close > lower  and close[1] <= lower[1]
        shortSig = close < upper  and close[1] >= upper[1]
        pos := f_apply_side(side_, longSig, shortSig, pos)
    else if behavior == 2
        longSig   = close > lower  and close[1] <= lower[1]
        longExit  = close > mid    and close[1] <= mid[1]
        shortSig  = close < upper  and close[1] >= upper[1]
        shortExit = close < mid    and close[1] >= mid[1]
        if side_ == 1   // Long Only: long on longSig; close on shortSig OR longExit
            if longSig
                pos := 1
            if shortSig or (longExit and pos == 1)
                pos := 0
        else if side_ == -1   // Short Only: short on shortSig; close on longSig OR shortExit
            if shortSig
                pos := -1
            if longSig or (shortExit and pos == -1)
                pos := 0
        else   // Both: full bidirectional with strategy exits
            if longSig
                pos := 1
            if shortSig
                pos := -1
            if longExit and pos == 1
                pos := 0
            if shortExit and pos == -1
                pos := 0
    else
        longSig  = close > upper
        shortSig = close < lower
        if (side_ == 1 or side_ == 0) and longSig
            pos := 1
        else if (side_ == -1 or side_ == 0) and shortSig
            pos := -1
        else
            pos := 0
    pos

// 5. KELTNER
strat_keltner(simple int side_, simple int period, simple float mult) =>
    basis = ta.ema(close, period)
    rng = ta.atr(period) * mult
    upper = basis + rng
    lower = basis - rng
    var float pos = 0.0
    longSig  = close > upper
    shortSig = close < lower
    pos := f_apply_side(side_, longSig, shortSig, pos)
    pos

// 6. SMA Crossover
strat_sma(simple int side_, simple int fast, simple int slow) =>
    fastMA = ta.sma(close, fast)
    slowMA = ta.sma(close, slow)
    longSig = fastMA >= slowMA
    shortSig = fastMA <  slowMA
    p = 0.0
    if (side_ == 1 or side_ == 0) and longSig
        p := 1
    if (side_ == -1 or side_ == 0) and shortSig
        p := -1
    p

// 7. MACD
strat_macd(simple int side_, simple int fast, simple int slow, simple int sig) =>
    [macdLine, sigLine, _hist] = ta.macd(close, fast, slow, sig)
    longSig = macdLine >= sigLine
    shortSig = macdLine <  sigLine
    p = 0.0
    if (side_ == 1 or side_ == 0) and longSig
        p := 1
    if (side_ == -1 or side_ == 0) and shortSig
        p := -1
    p

// 8. MOM (price vs price[n])
strat_mom(simple int side_, simple int period) =>
    prev = close[period]
    var float pos = 0.0
    longSig = close > prev
    shortSig = close < prev
    pos := f_apply_side(side_, longSig, shortSig, pos)
    pos

// 9. BREAKOUT (channel)
strat_breakout(simple int side_, simple int period) =>
    thigh = ta.highest(high[1], period)
    tlow  = ta.lowest(low[1], period)
    var float pos = 0.0
    longSig = high > thigh
    shortSig = low  < tlow
    pos := f_apply_side(side_, longSig, shortSig, pos)
    pos

// 10. RSI
strat_rsi(simple int side_, simple int period, simple int lth, simple int hth, simple int behavior) =>
    rsi = ta.rsi(close, period)
    var float pos = 0.0
    if behavior == 1
        longSig  = rsi > lth  and rsi[1] <= lth
        shortSig = rsi < hth  and rsi[1] >= hth
        pos := f_apply_side(side_, longSig, shortSig, pos)
    else if behavior == 2
        longSig  = rsi > lth  and rsi[1] <= lth
        longExit = rsi > hth  and rsi[1] <= hth
        shortSig = rsi < hth  and rsi[1] >= hth
        shortExit= rsi < lth  and rsi[1] >= lth
        if side_ == 1   // Long Only: close on shortSig too
            if longSig
                pos := 1
            if shortSig or longExit or shortExit
                pos := 0
        else if side_ == -1   // Short Only: close on longSig too
            if shortSig
                pos := -1
            if longSig or longExit or shortExit
                pos := 0
        else   // Both
            if longSig
                pos := 1
            if shortSig
                pos := -1
            if longExit or shortExit
                pos := 0
    else
        longSig  = rsi > hth
        shortSig = rsi < lth
        if (side_ == 1 or side_ == 0) and longSig
            pos := 1
        else if (side_ == -1 or side_ == 0) and shortSig
            pos := -1
        else
            pos := 0
    pos

// 11. RWI (Random Walk Index)
strat_rwi(simple int side_, simple int fast, simple int slow) =>
    rng = high - low
    rwi_f_pos = (high - low[fast]) / (rng[fast] * math.sqrt(fast))
    rwi_f_neg = (high[fast] - low) / (rng[fast] * math.sqrt(fast))
    rwi_f = rwi_f_pos - rwi_f_neg
    rwi_s_pos = (high - low[slow]) / (rng[slow] * math.sqrt(slow))
    rwi_s_neg = (high[slow] - low) / (rng[slow] * math.sqrt(slow))
    rwi_s = rwi_s_pos - rwi_s_neg
    var float pos = 0.0
    longSig  = rwi_f > 0 and rwi_s >= 0
    shortSig = rwi_f < 0 and rwi_s <= 0
    pos := f_apply_side(side_, longSig, shortSig, pos)
    pos

// 12. OUTSIDE BAR
strat_outside(simple int side_) =>
    var float pos = 0.0
    isOutside = high[1] <= high and low[1] >= low
    longSig  = isOutside and close > open
    shortSig = isOutside and close < open
    pos := f_apply_side(side_, longSig, shortSig, pos)
    pos

// 13. CONSECUTIVE UP/DOWN
strat_consec(simple int side_, simple int upN, simple int dnN) =>
    var int upCount = 0
    var int dnCount = 0
    if close > close[1]
        upCount += 1
        dnCount := 0
    else if close < close[1]
        dnCount += 1
        upCount := 0
    else
        upCount := 0
        dnCount := 0
    var float pos = 0.0
    longSig  = upCount >= upN
    shortSig = dnCount >= dnN
    pos := f_apply_side(side_, longSig, shortSig, pos)
    pos

// 14. SUPERTREND
strat_supertrend(simple int side_, simple int period, simple float factor) =>
    [st, dir] = ta.supertrend(factor, period)
    var float pos = 0.0
    longSig  = dir == -1
    shortSig = dir ==  1
    pos := f_apply_side(side_, longSig, shortSig, pos)
    pos

// 15. TRATINGS (hand-coded)
// Aggregates 14+ sub-indicators into two groups (MA + Oscillators) and averages the ratings.
strat_tratings(simple int side_, simple bool strong, simple int tableKind) =>
    avgPrice = ta.ema(close, 50)
    downTrend = close < avgPrice
    upTrend   = close > avgPrice

    // --- MOVING AVERAGES (12) ---
    r_sma10  = f_ma_rating(ta.sma(close, 10))
    r_sma20  = f_ma_rating(ta.sma(close, 20))
    r_sma30  = f_ma_rating(ta.sma(close, 30))
    r_sma50  = f_ma_rating(ta.sma(close, 50))
    r_sma100 = f_ma_rating(ta.sma(close, 100))
    r_sma200 = f_ma_rating(ta.sma(close, 200))
    r_ema10  = f_ma_rating(ta.ema(close, 10))
    r_ema20  = f_ma_rating(ta.ema(close, 20))
    r_ema30  = f_ma_rating(ta.ema(close, 30))
    r_ema50  = f_ma_rating(ta.ema(close, 50))
    r_ema100 = f_ma_rating(ta.ema(close, 100))
    r_ema200 = f_ma_rating(ta.ema(close, 200))

    // HMA(9), VWMA(20)
    r_hma  = f_ma_rating(ta.hma(close, 9))
    r_vwma = f_ma_rating(ta.vwma(close, 20))

    // Ichimoku (Tenkan/Kijun/SpanA/SpanB)
    conv = (ta.highest(high, 9)  + ta.lowest(low, 9))  / 2
    base = (ta.highest(high, 26) + ta.lowest(low, 26)) / 2
    spanA = (conv + base) / 2
    spanB = (ta.highest(high, 52) + ta.lowest(low, 52)) / 2
    closePrev = close[1]
    r_ichi = 0.0
    if spanA > spanB and close > spanA and close < base and closePrev < conv and close > conv
        r_ichi := 1.0
    else if spanA < spanB and close < spanB and close > base and closePrev > conv and close < conv
        r_ichi := -1.0

    maMean = (r_sma10 + r_sma20 + r_sma30 + r_sma50 + r_sma100 + r_sma200
             + r_ema10 + r_ema20 + r_ema30 + r_ema50 + r_ema100 + r_ema200
             + r_hma + r_vwma + r_ichi) / 15.0

    // --- OSCILLATORS (11) ---
    rsi14 = ta.rsi(close, 14)
    r_rsi = rsi14 < 30 ? 1.0 : rsi14 > 70 ? -1.0 : 0.0

    // Stochastic main & signal
    stk = ta.stoch(close, high, low, 14)
    std = ta.sma(stk, 3)
    r_stoch = (stk < 20 and std < 20 and stk > std) ? 1.0 : (stk > 80 and stk < std) ? -1.0 : 0.0

    cci20 = ta.cci(close, 20)
    r_cci = (cci20 < -100 and cci20[1] < cci20) ? 1.0 : (cci20 > 100 and cci20[1] > cci20) ? -1.0 : 0.0

    // ADX
    [diPlus, diMinus, adx] = ta.dmi(14, 14)
    r_adx = (adx > 20 and diPlus > diMinus and diPlus[1] < diMinus[1]) ? 1.0 :
             (adx > 20 and diPlus < diMinus and diPlus[1] > diMinus[1]) ? -1.0 : 0.0

    // Awesome Oscillator
    ao = ta.sma(hl2, 5) - ta.sma(hl2, 34)
    r_ao = 0.0
    if (ao > 0 and ao[1] > 0 and ao > ao[1] and ao[2] > ao[1])
        r_ao := 1.0
    else if (ao > 0 and ao[1] < 0)
        r_ao := 1.0
    else if (ao < 0 and ao[1] < 0 and ao < ao[1] and ao[2] < ao[1])
        r_ao := -1.0
    else if (ao < 0 and ao[1] > 0)
        r_ao := -1.0

    // Momentum (default talib period 10)
    momV = ta.mom(close, 10)
    r_mom = momV < momV[1] ? 1.0 : momV > momV[1] ? -1.0 : 0.0

    // MACD
    [macdL, macdS, _hh] = ta.macd(close, 12, 26, 9)
    r_macd = macdL > macdS ? 1.0 : macdL < macdS ? -1.0 : 0.0

    // Stochastic RSI
    rsiSrc = ta.rsi(close, 14)
    stochRsiK = ta.sma(ta.stoch(rsiSrc, rsiSrc, rsiSrc, 14), 3)
    stochRsiD = ta.sma(stochRsiK, 3)
    r_stochRsi = (downTrend and stochRsiK < 20 and stochRsiD < 20 and stochRsiK > stochRsiD and stochRsiK[1] < stochRsiD[1]) ? 1.0 :
                  (upTrend   and stochRsiK > 80 and stochRsiD > 80 and stochRsiK < stochRsiD and stochRsiK[1] > stochRsiD[1]) ? -1.0 : 0.0

    // Williams %R
    wpr = ta.wpr(14)
    r_wpr = (wpr < -80 and wpr > wpr[1]) ? 1.0 : (wpr > -20 and wpr < wpr[1]) ? -1.0 : 0.0

    // Bulls/Bears Power (ERI)
    eriEma = ta.ema(close, 13)
    bull = high - eriEma
    bear = low  - eriEma
    r_eri = (upTrend   and bear < 0 and bear > bear[1]) ? 1.0 :
             (downTrend and bull > 0 and bull < bull[1]) ? -1.0 : 0.0

    // Ultimate Oscillator (7/14/28)
    bp = close - math.min(low, close[1])
    trUO = math.max(high, close[1]) - math.min(low, close[1])
    avg7  = math.sum(bp, 7)  / math.sum(trUO, 7)
    avg14 = math.sum(bp, 14) / math.sum(trUO, 14)
    avg28 = math.sum(bp, 28) / math.sum(trUO, 28)
    uo = 100 * (4 * avg7 + 2 * avg14 + avg28) / 7
    r_uo = uo > 70 ? 1.0 : uo < 30 ? -1.0 : 0.0

    oscMean = (r_rsi + r_stoch + r_cci + r_adx + r_ao + r_mom + r_macd + r_stochRsi + r_wpr + r_eri + r_uo) / 11.0

    // Combine groups
    var float combined = 0.0
    if tableKind == 1
        combined := maMean
    else if tableKind == 2
        combined := oscMean
    else
        combined := (maMean + oscMean) / 2.0

    longThr  = strong ?  0.5 :  0.1
    shortThr = strong ? -0.5 : -0.1
    p = 0.0
    if (side_ == 1 or side_ == 0) and combined > longThr
        p := 1
    if (side_ == -1 or side_ == 0) and combined < shortThr
        p := -1
    p

// 16. PSAR
strat_psar(simple int side_, simple float start, simple float accel, simple float maxAf) =>
    sar = ta.sar(start, accel, maxAf)
    var float pos = 0.0
    longSig  = close > sar and close[1] <= sar[1]
    shortSig = close < sar and close[1] >= sar[1]
    pos := f_apply_side(side_, longSig, shortSig, pos)
    pos

// 17. STOCH SLOW
strat_stoch(simple int side_, simple int period, simple int smk, simple int smd, simple int ob, simple int os) =>
    fastk = ta.stoch(close, high, low, period)
    slowk = ta.sma(fastk, smk)
    slowd = ta.sma(slowk, smd)
    var float pos = 0.0
    longSig  = slowk > slowd and slowk[1] <= slowd[1] and slowk < os
    shortSig = slowk < slowd and slowk[1] >= slowd[1] and slowk > ob
    pos := f_apply_side(side_, longSig, shortSig, pos)
    pos

// 18. WICKS
strat_wicks(simple int side_, simple int period, simple float mult, simple float th) =>
    atrM = ta.atr(period) * mult
    upwick = close >= open ? high - close : high - open
    lowick = close <= open ? close - low  : open  - low
    wickdiff = (upwick - lowick) / atrM
    indi = math.sum(wickdiff, period)
    var float pos = 0.0
    longSig  = indi >  th
    shortSig = indi < -th
    exitSig  = (indi > 0 and indi[1] <= 0) or (indi < 0 and indi[1] >= 0)
    if side_ == 1   // Long Only: close on shortSig too
        if longSig
            pos := 1
        if shortSig or exitSig
            pos := 0
    else if side_ == -1   // Short Only: close on longSig too
        if shortSig
            pos := -1
        if longSig or exitSig
            pos := 0
    else   // Both
        if longSig
            pos := 1
        if shortSig
            pos := -1
        if exitSig
            pos := 0
    pos


// ============================================================
// BACKTEST METRICS ENGINE
// ============================================================
// computeMetric() is called once per strategy per cell. Pine gives each call site
// its own persistent `var` state, so equity/trades/etc. accumulate correctly.
// Returns the metric value selected by `metric_id`.
//   1=WinRate, 2=Sharpe, 3=TotalReturn, 4=Calmar, 5=ProfitFactor, 6=MaxDD

f_metric_id(simple string m) =>
    switch m
        "Win Rate %"     => 1
        "Sharpe"         => 2
        "Total Return %" => 3
        "Calmar"         => 4
        "Profit Factor"  => 5
        "Max DD %"       => 6
        =>                   7   // R-Ratio

// Annualization factor table (rough): bars per year for common TFs.
f_ann_factor(simple string tf) =>
    switch tf
        "1"   => 525600
        "3"   => 175200
        "5"   => 105120
        "15"  => 35040
        "30"  => 17520
        "45"  => 11680
        "60"  => 8760
        "120" => 4380
        "180" => 2920
        "240" => 2190
        "D"   => 365
        "W"   => 52
        "M"   => 12
        =>       252

computeMetric(float position, simple int metricId, simple float annF) =>
    var float equity     = 1.0
    var int   n_trades   = 0
    var int   n_wins     = 0
    var float gross_p    = 0.0
    var float gross_l    = 0.0
    var float peak_eq    = 1.0
    var float maxDD      = 0.0
    var float trade_eq0  = 1.0
    var int   prev_pos   = 0
    var float sum_r      = 0.0
    var float sum_r2     = 0.0
    var int   n_bars     = 0
    // Directional time tracking (for confidence computation: weighted baseline).
    var int   bars_long  = 0
    var int   bars_short = 0
    // R-Ratio accumulators: OLS regression on (x=years, y=log(equity))
    // R^2 * slope = "smoothness-weighted" annualized log-return.
    var float sum_x      = 0.0
    var float sum_y      = 0.0
    var float sum_xy     = 0.0
    var float sum_xx     = 0.0
    var float sum_yy     = 0.0
    var int   n_reg      = 0

    bar_pct = nz((close - close[1]) / close[1], 0)
    bar_ret = nz(position[1], 0) * bar_pct
    equity := equity * (1 + bar_ret)

    cur_pos = int(math.round(position))
    if cur_pos == 1
        bars_long += 1
    else if cur_pos == -1
        bars_short += 1
    if cur_pos != prev_pos
        if prev_pos != 0 and trade_eq0 > 0
            trade_pnl = (equity[1] - trade_eq0) / trade_eq0
            n_trades += 1
            if trade_pnl > 0
                n_wins += 1
                gross_p += trade_pnl
            else
                gross_l += math.abs(trade_pnl)
        trade_eq0 := equity
        prev_pos  := cur_pos

    peak_eq := math.max(peak_eq, equity)
    dd = peak_eq > 0 ? (equity - peak_eq) / peak_eq : 0.0
    maxDD := math.min(maxDD, dd)

    sum_r  += bar_ret
    sum_r2 += bar_ret * bar_ret
    n_bars += 1

    // R-Ratio: accumulate OLS sums only if equity > 0 (log defined)
    if equity > 0
        x_yr  = (n_bars - 1) / annF      // years elapsed since the start
        y_log = math.log(equity)
        sum_x  += x_yr
        sum_y  += y_log
        sum_xy += x_yr * y_log
        sum_xx += x_yr * x_yr
        sum_yy += y_log * y_log
        n_reg  += 1

    winRate = n_trades > 0 ? float(n_wins) / n_trades * 100.0 : 0.0
    totRet  = (equity - 1.0) * 100.0
    meanR   = n_bars > 0 ? sum_r / n_bars : 0.0
    varR    = n_bars > 0 ? sum_r2 / n_bars - meanR * meanR : 0.0
    stdR    = math.sqrt(math.max(varR, 0.0))
    sharpe  = stdR > 0 ? meanR / stdR * math.sqrt(annF) : 0.0
    maxDDpct = math.abs(maxDD) * 100.0
    calmar  = maxDDpct > 0 ? totRet / maxDDpct : 0.0
    pf      = gross_l > 0 ? gross_p / gross_l : (gross_p > 0 ? 99.0 : 0.0)

    // R-Ratio computation
    rRatio = 0.0
    if n_reg > 2
        mean_x = sum_x / n_reg
        mean_y = sum_y / n_reg
        var_x  = sum_xx / n_reg - mean_x * mean_x
        var_y  = sum_yy / n_reg - mean_y * mean_y
        cov_xy = sum_xy / n_reg - mean_x * mean_y
        if var_x > 0 and var_y > 0
            slope = cov_xy / var_x
            r_sq  = (cov_xy * cov_xy) / (var_x * var_y)
            rRatio := r_sq * slope

    rankVal = switch metricId
        1 => winRate
        2 => sharpe
        3 => totRet
        4 => calmar
        5 => pf
        6 => -maxDDpct
        => rRatio    // R-Ratio (id 7)
    [rankVal, winRate, rRatio, float(bars_long), float(bars_short), pf]

// ============================================================
// PER-CELL FUNCTION
// Returns an array<float> of 36 elements:
//   indices  0..17 = rank metric (per chosen metric) for strategies 1..18
//   indices 18..35 = win rate %  for strategies 1..18
// Using arrays instead of a 36-element tuple keeps module-scope var count low.
// ============================================================
runCell(simple int metricId, simple float annF) =>
    p1  = strat_hodl()
    p2  = strat_rekt()
    p3  = strat_rand()
    p4  = strat_bbands(side, bb_period, bb_mult, bb_behavior)
    p5  = strat_keltner(side, kc_period, kc_mult)
    p6  = strat_sma(side, sma_fast, sma_slow)
    p7  = strat_macd(side, macd_fast, macd_slow, macd_sig)
    p8  = strat_mom(side, mom_period)
    p9  = strat_breakout(side, brk_period)
    p10 = strat_rsi(side, rsi_period, rsi_lth, rsi_hth, rsi_behavior)
    p11 = strat_rwi(side, rwi_fast, rwi_slow)
    p12 = strat_outside(side)
    p13 = strat_consec(side, cons_up, cons_dn)
    p14 = strat_supertrend(side, st_period, st_factor)
    p15 = strat_tratings(side, trat_strong, trat_table)
    p16 = strat_psar(side, psar_start, psar_accel, psar_max)
    p17 = strat_stoch(side, stoch_period, stoch_smk, stoch_smd, stoch_ob, stoch_os)
    p18 = strat_wicks(side, wicks_period, wicks_mult, wicks_th)

    [m1,  w1,  r1,  bl1,  bs1,  pf1]  = computeMetric(p1,  metricId, annF)
    [m2,  w2,  r2,  bl2,  bs2,  pf2]  = computeMetric(p2,  metricId, annF)
    [m3,  w3,  r3,  bl3,  bs3,  pf3]  = computeMetric(p3,  metricId, annF)
    [m4,  w4,  r4,  bl4,  bs4,  pf4]  = computeMetric(p4,  metricId, annF)
    [m5,  w5,  r5,  bl5,  bs5,  pf5]  = computeMetric(p5,  metricId, annF)
    [m6,  w6,  r6,  bl6,  bs6,  pf6]  = computeMetric(p6,  metricId, annF)
    [m7,  w7,  r7,  bl7,  bs7,  pf7]  = computeMetric(p7,  metricId, annF)
    [m8,  w8,  r8,  bl8,  bs8,  pf8]  = computeMetric(p8,  metricId, annF)
    [m9,  w9,  r9,  bl9,  bs9,  pf9]  = computeMetric(p9,  metricId, annF)
    [m10, w10, r10, bl10, bs10, pf10] = computeMetric(p10, metricId, annF)
    [m11, w11, r11, bl11, bs11, pf11] = computeMetric(p11, metricId, annF)
    [m12, w12, r12, bl12, bs12, pf12] = computeMetric(p12, metricId, annF)
    [m13, w13, r13, bl13, bs13, pf13] = computeMetric(p13, metricId, annF)
    [m14, w14, r14, bl14, bs14, pf14] = computeMetric(p14, metricId, annF)
    [m15, w15, r15, bl15, bs15, pf15] = computeMetric(p15, metricId, annF)
    [m16, w16, r16, bl16, bs16, pf16] = computeMetric(p16, metricId, annF)
    [m17, w17, r17, bl17, bs17, pf17] = computeMetric(p17, metricId, annF)
    [m18, w18, r18, bl18, bs18, pf18] = computeMetric(p18, metricId, annF)

    // Array layout (108 elements):
    //   0..17  = rank metric (selected)
    //   18..35 = win rate %
    //   36..53 = R-Ratio (always computed)
    //   54..71 = bars_long
    //   72..89 = bars_short
    //   90..107= profit factor
    var array<float> arr = array.new<float>(108, na)
    array.set(arr, 0,  m1)
    array.set(arr, 1,  m2)
    array.set(arr, 2,  m3)
    array.set(arr, 3,  m4)
    array.set(arr, 4,  m5)
    array.set(arr, 5,  m6)
    array.set(arr, 6,  m7)
    array.set(arr, 7,  m8)
    array.set(arr, 8,  m9)
    array.set(arr, 9,  m10)
    array.set(arr, 10, m11)
    array.set(arr, 11, m12)
    array.set(arr, 12, m13)
    array.set(arr, 13, m14)
    array.set(arr, 14, m15)
    array.set(arr, 15, m16)
    array.set(arr, 16, m17)
    array.set(arr, 17, m18)
    array.set(arr, 18, w1)
    array.set(arr, 19, w2)
    array.set(arr, 20, w3)
    array.set(arr, 21, w4)
    array.set(arr, 22, w5)
    array.set(arr, 23, w6)
    array.set(arr, 24, w7)
    array.set(arr, 25, w8)
    array.set(arr, 26, w9)
    array.set(arr, 27, w10)
    array.set(arr, 28, w11)
    array.set(arr, 29, w12)
    array.set(arr, 30, w13)
    array.set(arr, 31, w14)
    array.set(arr, 32, w15)
    array.set(arr, 33, w16)
    array.set(arr, 34, w17)
    array.set(arr, 35, w18)
    array.set(arr, 36, r1)
    array.set(arr, 37, r2)
    array.set(arr, 38, r3)
    array.set(arr, 39, r4)
    array.set(arr, 40, r5)
    array.set(arr, 41, r6)
    array.set(arr, 42, r7)
    array.set(arr, 43, r8)
    array.set(arr, 44, r9)
    array.set(arr, 45, r10)
    array.set(arr, 46, r11)
    array.set(arr, 47, r12)
    array.set(arr, 48, r13)
    array.set(arr, 49, r14)
    array.set(arr, 50, r15)
    array.set(arr, 51, r16)
    array.set(arr, 52, r17)
    array.set(arr, 53, r18)
    array.set(arr, 54, bl1)
    array.set(arr, 55, bl2)
    array.set(arr, 56, bl3)
    array.set(arr, 57, bl4)
    array.set(arr, 58, bl5)
    array.set(arr, 59, bl6)
    array.set(arr, 60, bl7)
    array.set(arr, 61, bl8)
    array.set(arr, 62, bl9)
    array.set(arr, 63, bl10)
    array.set(arr, 64, bl11)
    array.set(arr, 65, bl12)
    array.set(arr, 66, bl13)
    array.set(arr, 67, bl14)
    array.set(arr, 68, bl15)
    array.set(arr, 69, bl16)
    array.set(arr, 70, bl17)
    array.set(arr, 71, bl18)
    array.set(arr, 72, bs1)
    array.set(arr, 73, bs2)
    array.set(arr, 74, bs3)
    array.set(arr, 75, bs4)
    array.set(arr, 76, bs5)
    array.set(arr, 77, bs6)
    array.set(arr, 78, bs7)
    array.set(arr, 79, bs8)
    array.set(arr, 80, bs9)
    array.set(arr, 81, bs10)
    array.set(arr, 82, bs11)
    array.set(arr, 83, bs12)
    array.set(arr, 84, bs13)
    array.set(arr, 85, bs14)
    array.set(arr, 86, bs15)
    array.set(arr, 87, bs16)
    array.set(arr, 88, bs17)
    array.set(arr, 89, bs18)
    array.set(arr, 90, pf1)
    array.set(arr, 91, pf2)
    array.set(arr, 92, pf3)
    array.set(arr, 93, pf4)
    array.set(arr, 94, pf5)
    array.set(arr, 95, pf6)
    array.set(arr, 96, pf7)
    array.set(arr, 97, pf8)
    array.set(arr, 98, pf9)
    array.set(arr, 99, pf10)
    array.set(arr, 100, pf11)
    array.set(arr, 101, pf12)
    array.set(arr, 102, pf13)
    array.set(arr, 103, pf14)
    array.set(arr, 104, pf15)
    array.set(arr, 105, pf16)
    array.set(arr, 106, pf17)
    array.set(arr, 107, pf18)
    arr

// Computes ALL 18 positions on the chart symbol/TF at module scope.
// Each has its own internal var state (per call site).
// The allPositions array allows accessing a strategy's position
// by index efficiently, without re-computing via switch.
chartPos1  = strat_hodl()
chartPos2  = strat_rekt()
chartPos3  = strat_rand()
chartPos4  = strat_bbands(side, bb_period, bb_mult, bb_behavior)
chartPos5  = strat_keltner(side, kc_period, kc_mult)
chartPos6  = strat_sma(side, sma_fast, sma_slow)
chartPos7  = strat_macd(side, macd_fast, macd_slow, macd_sig)
chartPos8  = strat_mom(side, mom_period)
chartPos9  = strat_breakout(side, brk_period)
chartPos10 = strat_rsi(side, rsi_period, rsi_lth, rsi_hth, rsi_behavior)
chartPos11 = strat_rwi(side, rwi_fast, rwi_slow)
chartPos12 = strat_outside(side)
chartPos13 = strat_consec(side, cons_up, cons_dn)
chartPos14 = strat_supertrend(side, st_period, st_factor)
chartPos15 = strat_tratings(side, trat_strong, trat_table)
chartPos16 = strat_psar(side, psar_start, psar_accel, psar_max)
chartPos17 = strat_stoch(side, stoch_period, stoch_smk, stoch_smd, stoch_ob, stoch_os)
chartPos18 = strat_wicks(side, wicks_period, wicks_mult, wicks_th)

allPositions = array.from(chartPos1, chartPos2, chartPos3, chartPos4, chartPos5, chartPos6,
     chartPos7, chartPos8, chartPos9, chartPos10, chartPos11, chartPos12, chartPos13,
     chartPos14, chartPos15, chartPos16, chartPos17, chartPos18)

// ============================================================
// GRID ORCHESTRATION
// 24 request.security() calls (6 asset x 4 TF, within the 40 limit).
// Each returns an array<float> of 36 elements:
//   indices  0..17 = rank metric (selected) for strategies 1..18
//   indices 18..35 = win rate %   for strategies 1..18
// calc_bars_count limits history to reduce runtime memory.
// ============================================================
metricId = f_metric_id(metricChoice)
annF1 = f_ann_factor(tf1)
annF2 = f_ann_factor(tf2)
annF3 = f_ann_factor(tf3)
annF4 = f_ann_factor(tf4)

cellA1T1 = request.security(asset1, tf1, runCell(metricId, annF1), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA1T2 = request.security(asset1, tf2, runCell(metricId, annF2), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA1T3 = request.security(asset1, tf3, runCell(metricId, annF3), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA1T4 = request.security(asset1, tf4, runCell(metricId, annF4), ignore_invalid_symbol=true, calc_bars_count=histBars)

cellA2T1 = request.security(asset2, tf1, runCell(metricId, annF1), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA2T2 = request.security(asset2, tf2, runCell(metricId, annF2), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA2T3 = request.security(asset2, tf3, runCell(metricId, annF3), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA2T4 = request.security(asset2, tf4, runCell(metricId, annF4), ignore_invalid_symbol=true, calc_bars_count=histBars)

cellA3T1 = request.security(asset3, tf1, runCell(metricId, annF1), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA3T2 = request.security(asset3, tf2, runCell(metricId, annF2), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA3T3 = request.security(asset3, tf3, runCell(metricId, annF3), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA3T4 = request.security(asset3, tf4, runCell(metricId, annF4), ignore_invalid_symbol=true, calc_bars_count=histBars)

cellA4T1 = request.security(asset4, tf1, runCell(metricId, annF1), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA4T2 = request.security(asset4, tf2, runCell(metricId, annF2), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA4T3 = request.security(asset4, tf3, runCell(metricId, annF3), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA4T4 = request.security(asset4, tf4, runCell(metricId, annF4), ignore_invalid_symbol=true, calc_bars_count=histBars)

cellA5T1 = request.security(asset5, tf1, runCell(metricId, annF1), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA5T2 = request.security(asset5, tf2, runCell(metricId, annF2), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA5T3 = request.security(asset5, tf3, runCell(metricId, annF3), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA5T4 = request.security(asset5, tf4, runCell(metricId, annF4), ignore_invalid_symbol=true, calc_bars_count=histBars)

cellA6T1 = request.security(asset6, tf1, runCell(metricId, annF1), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA6T2 = request.security(asset6, tf2, runCell(metricId, annF2), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA6T3 = request.security(asset6, tf3, runCell(metricId, annF3), ignore_invalid_symbol=true, calc_bars_count=histBars)
cellA6T4 = request.security(asset6, tf4, runCell(metricId, annF4), ignore_invalid_symbol=true, calc_bars_count=histBars)

// ============================================================
// ACCESSORS
// f_cell(a, t) -> array<float> of 36 elements per (asset, tf) cell
// f_get(a, t, s)   -> rank metric value for strategy s in cell (a,t)
// f_getwr(a, t, s) -> win rate %       for strategy s in cell (a,t)
// ============================================================
f_cell(int a, int t) =>
    // flatten (a, t) -> 0..23 (grid 6 asset x 4 TF)
    idx = (a - 1) * 4 + (t - 1)
    switch idx
        0  => cellA1T1
        1  => cellA1T2
        2  => cellA1T3
        3  => cellA1T4
        4  => cellA2T1
        5  => cellA2T2
        6  => cellA2T3
        7  => cellA2T4
        8  => cellA3T1
        9  => cellA3T2
        10 => cellA3T3
        11 => cellA3T4
        12 => cellA4T1
        13 => cellA4T2
        14 => cellA4T3
        15 => cellA4T4
        16 => cellA5T1
        17 => cellA5T2
        18 => cellA5T3
        19 => cellA5T4
        20 => cellA6T1
        21 => cellA6T2
        22 => cellA6T3
        =>    cellA6T4

f_get(int a, int t, int s) =>
    arr = f_cell(a, t)
    na(arr) or array.size(arr) < 108 ? na : array.get(arr, s - 1)

f_getwr(int a, int t, int s) =>
    arr = f_cell(a, t)
    na(arr) or array.size(arr) < 108 ? na : array.get(arr, s + 17)

f_getR(int a, int t, int s) =>
    arr = f_cell(a, t)
    na(arr) or array.size(arr) < 108 ? na : array.get(arr, s + 35)

f_getBL(int a, int t, int s) =>
    arr = f_cell(a, t)
    na(arr) or array.size(arr) < 108 ? na : array.get(arr, s + 53)

f_getBS(int a, int t, int s) =>
    arr = f_cell(a, t)
    na(arr) or array.size(arr) < 108 ? na : array.get(arr, s + 71)

f_getPF(int a, int t, int s) =>
    arr = f_cell(a, t)
    na(arr) or array.size(arr) < 108 ? na : array.get(arr, s + 89)

// ============================================================
// LABELS for table headers
// Note: Pine v6 seems to have problems rendering table.cell when
// the text comes from a switch/ternary on `series int` (inside nested
// loops in if barstate.islast). Workaround: we pre-compute the name
// arrays with `array.from` and use `array.get(arr, idx - 1)` in the loops.
// ============================================================
clean_asset_name(simple string s) =>
    parts = str.split(s, ":")
    cleaned = array.size(parts) > 1 ? array.get(parts, 1) : s
    str.contains(cleaned, "(") or str.contains(cleaned, ",") ? syminfo.ticker : cleaned

var assetNames = array.from(
     clean_asset_name(asset1),
     clean_asset_name(asset2),
     clean_asset_name(asset3),
     clean_asset_name(asset4),
     clean_asset_name(asset5),
     clean_asset_name(asset6))

var stratNames = array.from(
     "HODL", "REKT", "RAND",
     "BBANDS", "KELTNER", "SMA", "MACD", "MOM", "BREAKOUT",
     "RSI", "RWI", "OUTSIDE", "CONSEC", "SUPER",
     "TRATINGS", "PSAR", "STOCH", "WICKS")

var tfNames = array.from(tf1, tf2, tf3, tf4)

// ============================================================
// HEATMAP COLOR
// ============================================================
// Empirical bounds per metric (used by gradient).
f_bounds(simple int mid) =>
    float lo = 0.0
    float hi = 0.0
    if mid == 1       // win rate
        lo := 30.0
        hi := 70.0
    else if mid == 2  // sharpe
        lo := -1.0
        hi := 2.0
    else if mid == 3  // total return %
        lo := -50.0
        hi := 200.0
    else if mid == 4  // calmar
        lo := -2.0
        hi := 3.0
    else if mid == 5  // profit factor
        lo := 0.5
        hi := 2.5
    else if mid == 6  // max DD (negative)
        lo := -60.0
        hi := -5.0
    else              // R-Ratio (R^2 * annualized log slope)
        lo := -0.3
        hi := 0.5
    [lo, hi]

f_color(float v, simple int mid) =>
    [lo, hi] = f_bounds(mid)
    color.from_gradient(v, lo, hi, color.new(color.red, 20), color.new(color.green, 20))

f_text_color() => color.white

f_fmt(float v) => na(v) ? "—" : str.tostring(v, "#.##")

// ============================================================
// TABLE RENDERING
// ============================================================
f_position(simple string s) =>
    switch s
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        =>                 position.bottom_right

// Top strategy & marker ranking are determined inside the
// barstate.islast block further down, reusing the same avgArr/sorted
// as the table render. This way title TOP == first row of the ranking table.

// Ranking table: one row per (Asset, Strategy), sorted by the average
// of the chosen metric across the 4 timeframes. Columns:
//   Rank | Asset | Strategy | TF1 | TF2 | TF3 | TF4 | Avg | WR%
var table mainTbl = table.new(f_position(mainTablePosIn), 9, 100, border_width=1)

// One-shot history render flag + per-strategy state machine for incremental updates.
// On chart load: render full history once, record state per strategy.
// On real-time bar close: check just-closed bar incrementally (no full re-render,
// so existing labels NEVER disappear).
var bool        history_rendered = false
var array<int>  rt_last_sig      = array.new<int>(18, 0)
var int         last_top_sidx    = 0

f_text_size(simple string s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "large" ? size.large : size.normal

if barstate.islast
    table.clear(mainTbl, 0, 0, 8, 99)
    txtSize = f_text_size(tableSize)

    // ---- Compute avg metric per (asset, strategy) over the 4 TFs ----
    // Dedup: if multiple asset slots point to the same symbol (e.g. empty inputs
    // -> all fall back to syminfo.tickerid), only one row per symbol.
    avgArr   = array.new<float>()
    aArr     = array.new<int>()
    sArr     = array.new<int>()
    wrAvgArr = array.new<float>()
    seenAssets = array.new<string>()
    for aIdx = 1 to 6
        assetSym = array.get(assetNames, aIdx - 1)
        if not array.includes(seenAssets, assetSym)
            array.push(seenAssets, assetSym)
            for sIdx = 1 to 18
                sumM = 0.0
                sumW = 0.0
                n    = 0
                for tIdx = 1 to 4
                    v  = f_get(aIdx, tIdx, sIdx)
                    wr = f_getwr(aIdx, tIdx, sIdx)
                    if not na(v)
                        sumM += v
                        sumW += nz(wr, 0)
                        n    += 1
                avgV  = n > 0 ? sumM / n : na
                avgWR = n > 0 ? sumW / n : na
                array.push(avgArr, avgV)
                array.push(aArr, aIdx)
                array.push(sArr, sIdx)
                array.push(wrAvgArr, avgWR)

    sorted = array.sort_indices(avgArr, order.descending)

    // Map override dropdown -> strategy index. Ignored unless useOverride==true.
    override_sidx_raw = switch overrideTop
        "HODL"     => 1
        "REKT"     => 2
        "RAND"     => 3
        "BBANDS"   => 4
        "KELTNER"  => 5
        "SMA"      => 6
        "MACD"     => 7
        "MOM"      => 8
        "BREAKOUT" => 9
        "RSI"      => 10
        "RWI"      => 11
        "OUTSIDE"  => 12
        "CONSEC"   => 13
        "SUPER"    => 14
        "TRATINGS" => 15
        "PSAR"     => 16
        "STOCH"    => 17
        "WICKS"    => 18
        =>            0
    override_sidx = useOverride ? override_sidx_raw : 0

    // ---- Top N unique strategies (for markers/alerts) ----
    // If override_sidx is set, force only that strategy as TOP (rank 1).
    // Otherwise iterate sorted ranking and accumulate top N distinct strategies.
    topStratIndices = array.new<int>()
    if override_sidx > 0
        array.push(topStratIndices, override_sidx)
    else
        for k_top = 0 to array.size(sorted) - 1
            if array.size(topStratIndices) < topRangeN
                cand_sIdx = array.get(sArr, array.get(sorted, k_top))
                cand_avg  = array.get(avgArr, array.get(sorted, k_top))
                if not na(cand_avg) and not array.includes(topStratIndices, cand_sIdx)
                    array.push(topStratIndices, cand_sIdx)
    topStratName = array.size(topStratIndices) > 0 ? array.get(stratNames, array.get(topStratIndices, 0) - 1) : "—"
    topStratSidx = array.size(topStratIndices) > 0 ? array.get(topStratIndices, 0) : 0

    // ---- CONFIDENCE COMPUTATION ----
    // Chart asset = first slot (typically the chart symbol when slots are empty).
    // Chart TF = whichever of tf1..tf4 matches; else fallback to 1 (we still compute).
    chart_a_idx = 1
    chart_t_idx = timeframe.period == tf1 ? 1 :
                   timeframe.period == tf2 ? 2 :
                   timeframe.period == tf3 ? 3 :
                   timeframe.period == tf4 ? 4 : 1

    // Pull stats for top, HODL (sIdx=1), REKT (2), RAND (3) from the chart's cell.
    R_top   = topStratSidx > 0 ? f_getR(chart_a_idx, chart_t_idx, topStratSidx) : na
    R_hodl  = f_getR(chart_a_idx, chart_t_idx, 1)
    R_rekt  = f_getR(chart_a_idx, chart_t_idx, 2)
    R_rand  = f_getR(chart_a_idx, chart_t_idx, 3)
    WR_top  = topStratSidx > 0 ? f_getwr(chart_a_idx, chart_t_idx, topStratSidx) : na
    BL_top  = topStratSidx > 0 ? f_getBL(chart_a_idx, chart_t_idx, topStratSidx) : 0
    BS_top  = topStratSidx > 0 ? f_getBS(chart_a_idx, chart_t_idx, topStratSidx) : 0
    PF_top  = topStratSidx > 0 ? f_getPF(chart_a_idx, chart_t_idx, topStratSidx) : na

    // Direction-weighted baseline: blend of HODL (long) and REKT (short)
    // weighted by the % of time the top strategy spent in each direction.
    total_directional = BL_top + BS_top
    w_long  = total_directional > 0 ? BL_top / total_directional : 0.5
    w_short = total_directional > 0 ? BS_top / total_directional : 0.5
    baseline_passive = w_long * nz(R_hodl, 0) + w_short * nz(R_rekt, 0)
    edge_passive = nz(R_top, 0) - baseline_passive
    edge_random  = nz(R_top, 0) - nz(R_rand, 0)

    // Kelly fraction (binary with PF): f* = p * (1 - 1/PF). Cap to [0,1].
    p_win = nz(WR_top, 0) / 100.0
    kelly_f = (not na(PF_top) and PF_top > 0) ? p_win * (1 - 1 / PF_top) : 0.0

    // Sub-scores (each clamped 0..1). Scale-invariant where possible.
    // s1: absolute R-Ratio strength. Use relative scale: rTop / max(|rTop|, |HODL|, 1)
    absRTop = math.abs(nz(R_top, 0))
    refScale = math.max(absRTop, math.max(math.abs(nz(R_hodl, 0)), 0.10))
    s1 = math.max(math.min(nz(R_top, 0) / refScale, 1.0), 0.0)
    // s2: edge vs passive (relative to ref scale)
    s2 = math.max(math.min(edge_passive / refScale, 1.0), 0.0)
    // s3: edge vs random
    s3 = math.max(math.min(edge_random / refScale, 1.0), 0.0)
    // s4: WR excess over 50% (saturates at WR=75%)
    s4 = math.max(math.min((p_win - 0.5) * 4, 1.0), 0.0)
    // s5: Kelly (saturates at f=0.20)
    s5 = math.max(math.min(kelly_f * 5, 1.0), 0.0)

    confidence = (0.20 * s1 + 0.20 * s2 + 0.20 * s3 + 0.20 * s4 + 0.20 * s5) * 100.0

    // ---- Title row ----
    confTxt  = " | CONF " + str.tostring(math.round(confidence)) + "/100"
    titleStr = "Strategy Comparator  |  metric=" + metricChoice + "  |  side=" + sideStr + "  |  TOP: " + topStratName + confTxt
    table.cell(mainTbl, 0, 0, titleStr, bgcolor=color.new(color.black, 30), text_color=color.white, text_size=txtSize)
    table.merge_cells(mainTbl, 0, 0, 8, 0)

    // ---- Header row ----
    table.cell(mainTbl, 0, 1, "#",        bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=txtSize)
    table.cell(mainTbl, 1, 1, "Asset",    bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=txtSize)
    table.cell(mainTbl, 2, 1, "Strategy", bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=txtSize)
    table.cell(mainTbl, 3, 1, tf1,        bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=txtSize)
    table.cell(mainTbl, 4, 1, tf2,        bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=txtSize)
    table.cell(mainTbl, 5, 1, tf3,        bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=txtSize)
    table.cell(mainTbl, 6, 1, tf4,        bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=txtSize)
    table.cell(mainTbl, 7, 1, "Avg",      bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=txtSize)
    table.cell(mainTbl, 8, 1, "WR%",      bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=txtSize)

    // ---- Render top-N body rows ----
    written = 0
    for k = 0 to array.size(sorted) - 1
        if written < topN
            sortedIdx = array.get(sorted, k)
            avgV      = array.get(avgArr, sortedIdx)
            if not na(avgV)
                written += 1
                aIdx  = array.get(aArr, sortedIdx)
                sIdx  = array.get(sArr, sortedIdx)
                avgWR = array.get(wrAvgArr, sortedIdx)
                v1 = f_get(aIdx, 1, sIdx)
                v2 = f_get(aIdx, 2, sIdx)
                v3 = f_get(aIdx, 3, sIdx)
                v4 = f_get(aIdx, 4, sIdx)
                row = written + 1   // 0=title, 1=header, body starts at row 2
                assetName = array.get(assetNames, aIdx - 1)
                stratName = array.get(stratNames, sIdx - 1)
                labelBg = color.new(color.gray, 50)
                table.cell(mainTbl, 0, row, "#" + str.tostring(written), bgcolor=labelBg, text_color=color.white, text_size=txtSize)
                table.cell(mainTbl, 1, row, assetName, bgcolor=labelBg, text_color=color.white, text_size=txtSize)
                table.cell(mainTbl, 2, row, stratName, bgcolor=labelBg, text_color=color.white, text_size=txtSize)
                table.cell(mainTbl, 3, row, f_fmt(v1),   bgcolor=f_color(v1, metricId),   text_color=f_text_color(), text_size=txtSize)
                table.cell(mainTbl, 4, row, f_fmt(v2),   bgcolor=f_color(v2, metricId),   text_color=f_text_color(), text_size=txtSize)
                table.cell(mainTbl, 5, row, f_fmt(v3),   bgcolor=f_color(v3, metricId),   text_color=f_text_color(), text_size=txtSize)
                table.cell(mainTbl, 6, row, f_fmt(v4),   bgcolor=f_color(v4, metricId),   text_color=f_text_color(), text_size=txtSize)
                table.cell(mainTbl, 7, row, f_fmt(avgV), bgcolor=f_color(avgV, metricId), text_color=f_text_color(), text_size=txtSize)
                table.cell(mainTbl, 8, row, na(avgWR) ? "—" : str.tostring(avgWR, "#") + "%", bgcolor=labelBg, text_color=color.white, text_size=txtSize)

    // ============================================================
    // SIGNAL MARKERS + ALERTS — use the SAME ranking as the table
    // (topStratIndices: top N distinct strategies from the sorted avgArr).
    // Gated by confidenceThreshold: skip rendering if confidence below.
    // ============================================================
    // Signal rendering (no gate on confidence — always render if showSignals on).
    if showSignals
        // PHASE 1: one-shot full history render on the FIRST islast evaluation.
        // We don't check ishistory here because in live markets the very last
        // bar is often a real-time forming bar; relying on ishistory caused
        // history to never get rendered.
        if not history_rendered
            history_rendered := true
            n_show_sig = array.size(topStratIndices)
            for rk_iter = 1 to 10
                if rk_iter <= n_show_sig
                    sIdx_iter = array.get(topStratIndices, rk_iter - 1)
                    nm_iter   = array.get(stratNames, sIdx_iter - 1)
                    last_sig_hist = 0
                    // Walk from oldest bar (i = histBars-1) to current (i = 0).
                    for i = histBars - 1 to 0
                        if i <= bar_index
                            cur_arr  = allPositions[i]
                            prev_arr = (i + 1 < histBars and i + 1 <= bar_index) ? allPositions[i + 1] : na
                            if not na(cur_arr) and array.size(cur_arr) == 18
                                pos_i  = array.get(cur_arr, sIdx_iter - 1)
                                prev_i = (not na(prev_arr) and array.size(prev_arr) == 18) ? array.get(prev_arr, sIdx_iter - 1) : 0.0
                                raw_long  = pos_i ==  1 and prev_i !=  1
                                raw_short = pos_i == -1 and prev_i != -1
                                raw_flat  = pos_i ==  0 and prev_i !=  0
                                show_long  = raw_long  and last_sig_hist !=  1
                                show_short = raw_short and last_sig_hist != -1
                                if show_long
                                    label.new(bar_index - i, na, text=nm_iter,
                                         yloc=yloc.belowbar, color=color.new(color.green, 0),
                                         textcolor=color.white, style=label.style_label_up,
                                         size=size.small, force_overlay=true)
                                    last_sig_hist := 1
                                if show_short
                                    label.new(bar_index - i, na, text=nm_iter,
                                         yloc=yloc.abovebar, color=color.new(color.red, 0),
                                         textcolor=color.white, style=label.style_label_down,
                                         size=size.small, force_overlay=true)
                                    last_sig_hist := -1
                                // Exit to flat resets the state machine so the next
                                // entry of the same direction is shown again. Critical
                                // for Long Only / Short Only modes where position
                                // alternates between {1,0} or {-1,0}.
                                if raw_flat
                                    last_sig_hist := 0
                    // Record final state per strategy for real-time continuation
                    array.set(rt_last_sig, sIdx_iter - 1, last_sig_hist)

        // PHASE 2: real-time bar close — incremental check, only on confirmed close.
        else if barstate.isconfirmed and not barstate.ishistory
            n_show_sig = array.size(topStratIndices)
            for rk_iter = 1 to 10
                if rk_iter <= n_show_sig
                    sIdx_iter = array.get(topStratIndices, rk_iter - 1)
                    nm_iter   = array.get(stratNames, sIdx_iter - 1)
                    cur_arr  = allPositions
                    prev_arr = allPositions[1]
                    pos_now  = (not na(cur_arr)  and array.size(cur_arr)  == 18) ? array.get(cur_arr,  sIdx_iter - 1) : 0.0
                    pos_prv  = (not na(prev_arr) and array.size(prev_arr) == 18) ? array.get(prev_arr, sIdx_iter - 1) : 0.0
                    raw_long  = pos_now ==  1 and pos_prv !=  1
                    raw_short = pos_now == -1 and pos_prv != -1
                    raw_flat  = pos_now ==  0 and pos_prv !=  0
                    cur_state = array.get(rt_last_sig, sIdx_iter - 1)
                    show_long  = raw_long  and cur_state !=  1
                    show_short = raw_short and cur_state != -1
                    if show_long
                        label.new(bar_index, na, text=nm_iter,
                             yloc=yloc.belowbar, color=color.new(color.green, 0),
                             textcolor=color.white, style=label.style_label_up,
                             size=size.small, force_overlay=true)
                        array.set(rt_last_sig, sIdx_iter - 1, 1)
                        if enableAlerts
                            alert("LONG #"  + str.tostring(rk_iter) + " " + nm_iter + " - " + syminfo.ticker + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
                    if show_short
                        label.new(bar_index, na, text=nm_iter,
                             yloc=yloc.abovebar, color=color.new(color.red, 0),
                             textcolor=color.white, style=label.style_label_down,
                             size=size.small, force_overlay=true)
                        array.set(rt_last_sig, sIdx_iter - 1, -1)
                        if enableAlerts
                            alert("SHORT #" + str.tostring(rk_iter) + " " + nm_iter + " - " + syminfo.ticker + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
                    // Reset state machine on exit-to-flat so the next entry of the
                    // same direction is shown again (required for Long Only / Short
                    // Only where position alternates between {1,0} or {-1,0}).
                    if raw_flat
                        array.set(rt_last_sig, sIdx_iter - 1, 0)
````
