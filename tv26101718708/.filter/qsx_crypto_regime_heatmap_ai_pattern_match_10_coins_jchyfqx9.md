# QSX Crypto Regime Heatmap - AI Pattern Match | 10 Coins

- url: https://www.tradingview.com/script/JCHyFqX9-QSX-Crypto-Regime-Heatmap-AI-Pattern-Match-10-Coins/
- type: indicator
- pine_id: PUB;33233fbb2ede430f8a8f25de2543a6ff
- version: 2.0

## Description

QSX Crypto Regime Heatmap scores the trend health of 10 crypto assets on a
continuous 0-100 scale and renders them as a color-coded dashboard — so you
can read the health of the whole market in a single glance, without flipping
through 10 charts.

This is a market-overview dashboard, not a trading system. It answers one
question fast: which coins are in a strong regime right now, and which are
breaking down.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT IT SHOWS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For each of the 10 assets, the table displays:

• Price       — live price, auto-formatted for large caps and micro-caps
• 24h         — daily change with ↑/↓ direction and green/red coloring
• Score       — trend health, 0 (weakest) to 100 (strongest)
• Regime      — a visual strength bar, red → yellow → green
• Match       — AI Pattern Match confidence (explained below)

A Top 3 Strongest / Weakest panel sits at the bottom for an instant read on
where relative strength is concentrated.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW THE SCORE WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The 0-100 Trend Health score blends three continuous signals — not simple
binary above/below-MA flags:

1. Distance from the 200-period MA (how far price is extended)
2. Slope of the 200-period MA (how strong the underlying trend is)
3. Directional bias (which side of the MA price sits on)

A volatility-health component then rewards stable, orderly trends and
discounts high-volatility chop, using a rolling ATR percentile.

ADAPTIVE SCORING automatically adjusts the weight between trend and
volatility per coin, based on how persistent that coin's trend has been —
so trending assets and choppy assets are judged on their own terms.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AI PATTERN MATCH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The "Match" column uses a K-Nearest-Neighbors model. It builds a feature
vector from the current regime (trend, volatility, MA slope) and searches
each coin's own history for the most similar past setups, then reads what
happened next.

• High  — historically similar regimes tended to resolve upward
• Mid   — mixed / neutral historical outcome
• Low   — historically similar regimes tended to resolve downward
• Wait  — not enough history yet to form a reliable match

Pattern Match is a context signal, not a prediction. Treat it as "what has
this regime tended to lead to," never as a guarantee.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CUSTOMIZE YOUR WATCHLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

4 fixed blue-chips (BTC, ETH, SOL, BNB) anchor the board.
6 fully customizable slots let you drop in any symbols you want — majors,
alts, or your current rotation. No waiting for an update to track a new coin.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• Strong Breakout — any tracked coin crosses ABOVE score 70
• Weak Breakdown  — any tracked coin crosses BELOW score 30

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

★ Best used on the 4H or 1D timeframe. This is a regime dashboard — its job
  is to read the bigger picture, and higher timeframes give cleaner, more
  stable scores.

★ On very low timeframes (1m–15m) the panel needs to pull deep history for
  10 assets and will load noticeably slower. That is expected. If you want
  a fast, stable board, stay on 4H / 1D.

★ Green cluster = broad strength, favor long-biased setups on your own
  system. Red cluster = broad weakness, tighten risk.

★ Use the Top 3 panel to spot where relative strength is rotating.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTES & LIMITATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• In broad bear phases, most scores will sit low together — that is a correct
  reflection of the market, not a malfunction.
• The panel updates on the latest bar. Historical bars intentionally do not
  render the table.
• Symbols default to BINANCE pairs; you can swap any slot to another exchange.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator is for educational and informational purposes only. It is not
financial advice, not a recommendation to buy or sell any asset, and not a
trading system. Scores, Pattern Match values, and alerts describe historical
and current market conditions — they do not predict future prices. Crypto
markets are highly volatile and you can lose money. Always do your own
research and manage your own risk. Past behavior of similar regimes does not
guarantee future results.

## Source Code

````pine
// © QuantScopeX
// QSX Crypto Regime Heatmap v1.1
// ---------------------------------------------------------------------
// Multi-coin trend health dashboard with adaptive scoring and pattern matching.
//
// - 10 assets: 4 fixed blue-chips + 6 user-customizable slots
// - Trend Score 0-100: MA200 trend + normalized ATR volatility
// - Adaptive weighting: automatically adjusts MA200 vs ATR weight per coin
// - Pattern Match: compares current regime to 200+ historical patterns
// - Heatmap visualization: green (strong) → yellow (neutral) → red (weak)
// - Price + 24h change columns for screener-style scanning
// - Top 3 Strongest / Weakest panel for quick actionable insights
//
// This is a market overview dashboard, not a trading system.
// ---------------------------------------------------------------------

//@version=6
indicator("QSX Crypto Regime Heatmap - AI Pattern Match | 10 Coins", shorttitle="QSX Regime AI", overlay=false, max_labels_count=0, max_boxes_count=0, max_bars_back=1000)

// --------------------------------------------------------------------- Settings
grp_coins = "Coin Selection"
coin1 = input.string("BINANCE:XRPUSDT", "Custom 1", group=grp_coins, tooltip="Add your own coin (e.g., BINANCE:SUIUSDT)")
coin2 = input.string("BINANCE:DOGEUSDT", "Custom 2", group=grp_coins, tooltip="Add your own coin (e.g., BINANCE:PEPEUSDT)")
coin3 = input.string("BINANCE:AVAXUSDT", "Custom 3", group=grp_coins, tooltip="Add your own coin (e.g., BINANCE:LINKUSDT)")
coin4 = input.string("BINANCE:LINKUSDT", "Custom 4", group=grp_coins, tooltip="Add your own coin (e.g., BINANCE:NEARUSDT)")
coin5 = input.string("BINANCE:SUIUSDT", "Custom 5", group=grp_coins, tooltip="Add your own coin (e.g., BINANCE:ARBUSDT)")
coin6 = input.string("BINANCE:ADAUSDT", "Custom 6", group=grp_coins, tooltip="Add your own coin (e.g., BINANCE:OPUSDT)")

grp_display = "Display"
panel_pos = input.string("top_right", "Panel Position", options=["top_right","top_left","bottom_right","bottom_left","middle_right"], group=grp_display)
show_pattern = input.bool(true, "Show Pattern Match", group=grp_display, tooltip="Historical regime similarity confidence")
show_adaptive = input.bool(true, "Adaptive Scoring", group=grp_display, tooltip="Auto-adjusts MA200 vs ATR weight per coin")
show_top3 = input.bool(true, "Show Top 3 Strongest/Weakest", group=grp_display, tooltip="Quick actionable insights")

grp_params = "Parameters"
trend_len = input.int(200, "Trend MA Length", minval=50, maxval=400, group=grp_params)
vol_len = input.int(14, "Volatility ATR", minval=5, maxval=50, group=grp_params)
vol_rank_len = input.int(100, "Volatility Rank Window", minval=50, maxval=200, group=grp_params)
smooth_len = input.int(5, "Score Smoothing", minval=1, maxval=20, group=grp_params)

grp_pattern = "Pattern Match Settings"
knn_lookback = input.int(200, "History Lookback", minval=100, maxval=500, group=grp_pattern)
knn_neighbors = input.int(5, "Neighbors", minval=3, maxval=10, group=grp_pattern)
knn_horizon = input.int(30, "Forward Horizon (bars)", minval=10, maxval=90, group=grp_pattern)

// --------------------------------------------------------------------- Fixed Core (4 blue-chips)
var string[] FIXED_COINS = array.from(
     "BINANCE:BTCUSDT",
     "BINANCE:ETHUSDT",
     "BINANCE:SOLUSDT",
     "BINANCE:BNBUSDT"
     )

var string[] ALL_COINS = array.new<string>(0)
if barstate.isfirst
    array.concat(ALL_COINS, FIXED_COINS)
    array.push(ALL_COINS, coin1)
    array.push(ALL_COINS, coin2)
    array.push(ALL_COINS, coin3)
    array.push(ALL_COINS, coin4)
    array.push(ALL_COINS, coin5)
    array.push(ALL_COINS, coin6)

COIN_COUNT = array.size(ALL_COINS)

// --------------------------------------------------------------------- Constants
W_TREND_BASE = 0.65
W_VOL_BASE = 0.35

COL_GREEN = #22c55e
COL_YELLOW = #f59e0b
COL_RED = #ef4444
COL_TEXT = #e4e4e7
COL_DIM = #71717a
COL_PANEL = #0a0a0a
COL_TRACK = #27272a

// --------------------------------------------------------------------- Helpers
f_clamp(_x, _lo, _hi) =>
    math.max(_lo, math.min(_hi, _x))

f_pos(_p) =>
    switch _p
        "top_left" => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left" => position.bottom_left
        "middle_right" => position.middle_right
        => position.top_right

f_extract_ticker(_full) =>
    _parts = str.split(_full, ":")
    array.size(_parts) > 1 ? array.get(_parts, 1) : _full

// --------------------------------------------------------------------- Core Scoring Functions
f_trend_state(_close, _ma) =>
    if na(_close) or na(_ma)
        na
    else
        _above = _close > _ma ? 0.5 : -0.5
        _slope = (not na(_ma[1]) and _ma > _ma[1]) ? 0.5 : -0.5
        _above + _slope

f_trend_health(_close, _ma) =>
    if na(_close) or na(_ma)
        na
    else
        _dist_pct = (_close / _ma - 1.0) * 100.0
        _dist_score = f_clamp(50.0 + _dist_pct * 1.5, 0.0, 100.0)
        _slope_pct = na(_ma[1]) or _ma[1] == 0.0 ? 0.0 : (_ma / _ma[1] - 1.0) * 100.0
        _slope_score = f_clamp(50.0 + _slope_pct * 80.0, 0.0, 100.0)
        _bias_score = _close > _ma ? 65.0 : 35.0
        0.55 * _dist_score + 0.30 * _slope_score + 0.15 * _bias_score

f_vol_health(_natr_pct) =>
    na(_natr_pct) ? na : f_clamp(100.0 - _natr_pct * 60.0, 30.0, 100.0)

f_adaptive_weight(_close, _ma, _lookback) =>
    if not show_adaptive or bar_index < 1
        [W_TREND_BASE, W_VOL_BASE]
    else
        float _sum = 0.0
        int _count = 0
        _end = math.min(_lookback, bar_index)
        for i = 1 to _end
            _prev_trend = f_trend_state(_close[i], _ma[i])
            _curr_trend = f_trend_state(_close[i-1], _ma[i-1])
            if not na(_prev_trend) and not na(_curr_trend)
                _sum += (_prev_trend * _curr_trend > 0) ? 1.0 : 0.0
                _count += 1
        _persistence = _count > 0 ? _sum / _count : 0.5
        _adaptive_trend_w = f_clamp(W_TREND_BASE + (_persistence - 0.5) * 0.3, 0.4, 0.8)
        [_adaptive_trend_w, 1.0 - _adaptive_trend_w]

f_pattern_confidence(_close, _trend_score, _natr_pct, _ma_slope_norm) =>
    // 每根 bar 都进函数（让上面传进来的参数序列积累历史），
    // 但 KNN 回溯只在最后一根 bar 跑，避免每根都 O(n^2)。
    if not show_pattern or not barstate.islast
        na
    else
        _curr_trend = _trend_score
        _curr_vol = _natr_pct
        _curr_slope = _ma_slope_norm

        _distances = array.new<float>(0)
        _fwd_returns = array.new<float>(0)

        _history_end = math.min(knn_lookback + knn_horizon, bar_index - 1)
        if _history_end >= knn_horizon
            for i = knn_horizon to _history_end
                _hist_trend = _trend_score[i]
                _hist_vol = _natr_pct[i]
                _hist_slope = _ma_slope_norm[i]

                if not na(_hist_trend) and not na(_hist_vol) and not na(_hist_slope)
                    _dist = math.sqrt(
                         math.pow(_curr_trend - _hist_trend, 2) +
                         math.pow(_curr_vol - _hist_vol, 2) +
                         math.pow(_curr_slope - _hist_slope, 2)
                         )

                    _entry_price = _close[i]
                    _exit_price = _close[i - knn_horizon]
                    _fwd_ret = na(_entry_price) or na(_exit_price) or _entry_price == 0 ? na :
                         (_exit_price / _entry_price - 1.0)

                    if not na(_fwd_ret)
                        array.push(_distances, _dist)
                        array.push(_fwd_returns, _fwd_ret)

        if array.size(_distances) >= knn_neighbors
            _sorted_idx = array.new<int>(0)
            for j = 0 to array.size(_distances) - 1
                array.push(_sorted_idx, j)

            _n = array.size(_distances)
            for j = 0 to _n - 2
                for k = j + 1 to _n - 1
                    _idx_j = array.get(_sorted_idx, j)
                    _idx_k = array.get(_sorted_idx, k)
                    if array.get(_distances, _idx_j) > array.get(_distances, _idx_k)
                        array.set(_sorted_idx, j, _idx_k)
                        array.set(_sorted_idx, k, _idx_j)

            _sum_ret = 0.0
            for j = 0 to math.min(knn_neighbors - 1, array.size(_sorted_idx) - 1)
                _idx = array.get(_sorted_idx, j)
                _sum_ret += array.get(_fwd_returns, _idx)
            _avg_ret = _sum_ret / knn_neighbors

            f_clamp(0.5 + _avg_ret * 5.0, 0.0, 1.0)
        else
            na

f_compute_score(_symbol) =>
    [_close, _high, _low] = request.security(_symbol, timeframe.period, [close, high, low], ignore_invalid_symbol=true)
    [_day_close, _day_prev_close] = request.security(_symbol, "D", [close, close[1]], ignore_invalid_symbol=true)
    _chg24 = na(_day_close) or na(_day_prev_close) or _day_prev_close == 0.0 ? na :
         (_day_close / _day_prev_close - 1.0) * 100.0

    _ma = ta.sma(_close, trend_len)
    _trend_health = f_trend_health(_close, _ma)

    _prev_close = _close[1]
    _tr = math.max(_high - _low, math.max(math.abs(_high - _prev_close), math.abs(_low - _prev_close)))
    _atr = ta.sma(_tr, vol_len)
    _natr = _atr / _close
    _natr_high = ta.highest(_natr, vol_rank_len)
    _natr_low = ta.lowest(_natr, vol_rank_len)
    _spread = _natr_high - _natr_low
    _natr_pct = na(_natr) or na(_natr_high) or na(_natr_low) ? na :
         (_spread == 0.0 ? 0.5 : (_natr - _natr_low) / _spread)
    _vol_health = f_vol_health(_natr_pct)

    _ma_slope = na(_ma) or na(_ma[1]) ? 0.0 : (_ma / _ma[1] - 1.0) * 100.0
    _ma_slope_norm = f_clamp(_ma_slope / 2.0 + 0.5, 0.0, 1.0)

    [_w_trend, _w_vol] = f_adaptive_weight(_close, _ma, 90)

    _raw = _w_trend * _trend_health + _w_vol * _vol_health
    _smooth = ta.sma(_raw, smooth_len)
    _score = na(_close) or na(_ma) or na(_smooth) ? na : f_clamp(_smooth, 0.0, 100.0)

    _trend_feature = na(_trend_health) ? na : _trend_health / 100.0
    // 必须每根 bar 都调用，参数序列才能积累历史；重活在函数内部用 barstate.islast 挡。
    _conf = f_pattern_confidence(_close, _trend_feature, _natr_pct, _ma_slope_norm)

    [_score, _conf, _close, _chg24]

// --------------------------------------------------------------------- 计算所有币种
// Pine 对动态 symbol 的 request.security 支持有限；这里展开为固定 call site，
// 避免多个币共用同一份 series 状态，导致热力图结果塌缩。
[s0, c0, p0, ch0] = f_compute_score("BINANCE:BTCUSDT")
[s1, c1, p1, ch1] = f_compute_score("BINANCE:ETHUSDT")
[s2, c2, p2, ch2] = f_compute_score("BINANCE:SOLUSDT")
[s3, c3, p3, ch3] = f_compute_score("BINANCE:BNBUSDT")
[s4, c4, p4, ch4] = f_compute_score(coin1)
[s5, c5, p5, ch5] = f_compute_score(coin2)
[s6, c6, p6, ch6] = f_compute_score(coin3)
[s7, c7, p7, ch7] = f_compute_score(coin4)
[s8, c8, p8, ch8] = f_compute_score(coin5)
[s9, c9, p9, ch9] = f_compute_score(coin6)

var float[] scores = array.new<float>(COIN_COUNT, na)
var float[] confs = array.new<float>(COIN_COUNT, na)
var float[] prices = array.new<float>(COIN_COUNT, na)
var float[] changes24 = array.new<float>(COIN_COUNT, na)
var string[] tickers = array.new<string>(COIN_COUNT, "")

if barstate.islast
    array.set(scores, 0, s0)
    array.set(scores, 1, s1)
    array.set(scores, 2, s2)
    array.set(scores, 3, s3)
    array.set(scores, 4, s4)
    array.set(scores, 5, s5)
    array.set(scores, 6, s6)
    array.set(scores, 7, s7)
    array.set(scores, 8, s8)
    array.set(scores, 9, s9)
    array.set(confs, 0, c0)
    array.set(confs, 1, c1)
    array.set(confs, 2, c2)
    array.set(confs, 3, c3)
    array.set(confs, 4, c4)
    array.set(confs, 5, c5)
    array.set(confs, 6, c6)
    array.set(confs, 7, c7)
    array.set(confs, 8, c8)
    array.set(confs, 9, c9)
    array.set(prices, 0, p0)
    array.set(prices, 1, p1)
    array.set(prices, 2, p2)
    array.set(prices, 3, p3)
    array.set(prices, 4, p4)
    array.set(prices, 5, p5)
    array.set(prices, 6, p6)
    array.set(prices, 7, p7)
    array.set(prices, 8, p8)
    array.set(prices, 9, p9)
    array.set(changes24, 0, ch0)
    array.set(changes24, 1, ch1)
    array.set(changes24, 2, ch2)
    array.set(changes24, 3, ch3)
    array.set(changes24, 4, ch4)
    array.set(changes24, 5, ch5)
    array.set(changes24, 6, ch6)
    array.set(changes24, 7, ch7)
    array.set(changes24, 8, ch8)
    array.set(changes24, 9, ch9)
    for i = 0 to COIN_COUNT - 1
        array.set(tickers, i, f_extract_ticker(array.get(ALL_COINS, i)))

// --------------------------------------------------------------------- 排序
var int[] sorted_idx = array.new<int>(COIN_COUNT, 0)
if barstate.islast
    for i = 0 to COIN_COUNT - 1
        array.set(sorted_idx, i, i)

    for i = 0 to COIN_COUNT - 2
        for j = i + 1 to COIN_COUNT - 1
            _idx_i = array.get(sorted_idx, i)
            _idx_j = array.get(sorted_idx, j)
            _score_i = array.get(scores, _idx_i)
            _score_j = array.get(scores, _idx_j)
            if na(_score_i) or (not na(_score_j) and _score_j > _score_i)
                array.set(sorted_idx, i, _idx_j)
                array.set(sorted_idx, j, _idx_i)

// --------------------------------------------------------------------- 可视化
f_score_color(_score) =>
    na(_score) ? COL_TRACK :
     _score >= 70 ? COL_GREEN :
     _score >= 55 ? color.new(COL_GREEN, 40) :
     _score >= 45 ? COL_YELLOW :
     _score >= 30 ? color.new(COL_RED, 40) :
     COL_RED

f_conf_label(_conf) =>
    na(_conf) ? "Wait" :
     _conf >= 0.65 ? "Up" :
     _conf >= 0.35 ? "Flat" : "Down"

f_conf_color(_conf) =>
    na(_conf) ? COL_DIM :
     _conf >= 0.65 ? COL_GREEN :
     _conf >= 0.35 ? COL_YELLOW : COL_RED

f_price_label(_price) =>
    na(_price) ? "n/a" :
     _price >= 100.0 ? str.tostring(_price, "#") :
     _price >= 1.0 ? str.tostring(_price, "#.##") :
     _price >= 0.01 ? str.tostring(_price, "#.####") :
     str.tostring(_price, "#.########")

f_change_label(_chg) =>
    na(_chg) ? "n/a" :
     _chg > 0.0 ? "↑ " + str.tostring(math.abs(_chg), "#.##") + "%" :
     _chg < 0.0 ? "↓ " + str.tostring(math.abs(_chg), "#.##") + "%" :
     "0.00%"

f_change_color(_chg) =>
    na(_chg) ? COL_DIM :
     _chg > 0.0 ? COL_GREEN :
     _chg < 0.0 ? COL_RED : COL_DIM

var table panel = na
if na(panel)
    _cols = show_pattern ? 7 : 6
    _rows = COIN_COUNT + 2 + (show_top3 ? 2 : 0)
    panel := table.new(f_pos(panel_pos), _cols, _rows, border_width=1, frame_width=1, frame_color=color.new(COL_DIM, 70))

    table.merge_cells(panel, 0, 0, _cols - 1, 0)
    table.cell(panel, 0, 0, "QSX AI CRYPTO REGIME HEATMAP", text_color=COL_TEXT, text_size=size.normal, bgcolor=COL_PANEL, text_halign=text.align_center)

    table.cell(panel, 0, 1, "#", text_color=COL_DIM, text_size=size.small, bgcolor=COL_PANEL)
    table.cell(panel, 1, 1, "Asset", text_color=COL_DIM, text_size=size.small, bgcolor=COL_PANEL)
    table.cell(panel, 2, 1, "Price", text_color=COL_DIM, text_size=size.small, bgcolor=COL_PANEL)
    table.cell(panel, 3, 1, "24h", text_color=COL_DIM, text_size=size.small, bgcolor=COL_PANEL)
    table.cell(panel, 4, 1, "Score", text_color=COL_DIM, text_size=size.small, bgcolor=COL_PANEL)
    table.cell(panel, 5, 1, "Regime", text_color=COL_DIM, text_size=size.small, bgcolor=COL_PANEL)
    if show_pattern
        table.cell(panel, 6, 1, "Outlook", text_color=COL_DIM, text_size=size.small, bgcolor=COL_PANEL, tooltip="Historical outlook: past setups that looked like now were, on average, followed by an Up / Flat / Down move. Statistical context, not a prediction. Wait = not enough history yet.")

if barstate.islast and not na(panel)
    for i = 0 to COIN_COUNT - 1
        _idx = array.get(sorted_idx, i)
        _score = array.get(scores, _idx)
        _conf = array.get(confs, _idx)
        _price = array.get(prices, _idx)
        _chg = array.get(changes24, _idx)
        _ticker = array.get(tickers, _idx)

        _row = i + 2

        table.cell(panel, 0, _row, str.tostring(i + 1), text_color=COL_TEXT, text_size=size.small, bgcolor=COL_PANEL)
        table.cell(panel, 1, _row, _ticker, text_color=COL_TEXT, text_size=size.small, bgcolor=COL_PANEL, text_halign=text.align_left)
        table.cell(panel, 2, _row, f_price_label(_price), text_color=COL_TEXT, text_size=size.small, bgcolor=COL_PANEL, text_halign=text.align_right)
        table.cell(panel, 3, _row, f_change_label(_chg), text_color=f_change_color(_chg), text_size=size.small, bgcolor=COL_PANEL, text_halign=text.align_right)

        _score_txt = na(_score) ? "n/a" : str.tostring(math.round(_score))
        table.cell(panel, 4, _row, _score_txt, text_color=color.white, text_size=size.normal, bgcolor=COL_PANEL)

        _regime_txt = na(_score) ? "" :
             _score >= 70 ? "█████████" :
             _score >= 60 ? "████████░" :
             _score >= 55 ? "███████░░" :
             _score >= 45 ? "█████░░░░" :
             _score >= 30 ? "███░░░░░░" : "█░░░░░░░░"
        table.cell(panel, 5, _row, _regime_txt, text_color=f_score_color(_score), text_size=size.small, bgcolor=COL_PANEL)

        if show_pattern
            _conf_txt = f_conf_label(_conf)
            table.cell(panel, 6, _row, _conf_txt, text_color=f_conf_color(_conf), text_size=size.small, bgcolor=COL_PANEL)

    // Top 3 Strongest / Weakest
    if show_top3
        _row_top3 = COIN_COUNT + 2
        table.merge_cells(panel, 0, _row_top3, show_pattern ? 6 : 5, _row_top3)

        _top3_txt = "🟢 Strongest: "
        for i = 0 to math.min(2, COIN_COUNT - 1)
            _idx = array.get(sorted_idx, i)
            _ticker = array.get(tickers, _idx)
            _score = array.get(scores, _idx)
            if not na(_score)
                _top3_txt += _ticker + " (" + str.tostring(math.round(_score)) + ")"
                if i < 2
                    _top3_txt += "  "

        table.cell(panel, 0, _row_top3, _top3_txt, text_color=COL_GREEN, text_size=size.small, bgcolor=COL_PANEL, text_halign=text.align_left)

        _row_bottom3 = COIN_COUNT + 3
        table.merge_cells(panel, 0, _row_bottom3, show_pattern ? 6 : 5, _row_bottom3)

        _bottom3_txt = "🔴 Weakest:   "
        for i = math.max(0, COIN_COUNT - 3) to COIN_COUNT - 1
            _idx = array.get(sorted_idx, i)
            _ticker = array.get(tickers, _idx)
            _score = array.get(scores, _idx)
            if not na(_score)
                _bottom3_txt += _ticker + " (" + str.tostring(math.round(_score)) + ")"
                if i < COIN_COUNT - 1
                    _bottom3_txt += "  "

        table.cell(panel, 0, _row_bottom3, _bottom3_txt, text_color=COL_RED, text_size=size.small, bgcolor=COL_PANEL, text_halign=text.align_left)

// --------------------------------------------------------------------- Alerts
strong0 = ta.crossover(s0, 70.0)
strong1 = ta.crossover(s1, 70.0)
strong2 = ta.crossover(s2, 70.0)
strong3 = ta.crossover(s3, 70.0)
strong4 = ta.crossover(s4, 70.0)
strong5 = ta.crossover(s5, 70.0)
strong6 = ta.crossover(s6, 70.0)
strong7 = ta.crossover(s7, 70.0)
strong8 = ta.crossover(s8, 70.0)
strong9 = ta.crossover(s9, 70.0)
weak0 = ta.crossunder(s0, 30.0)
weak1 = ta.crossunder(s1, 30.0)
weak2 = ta.crossunder(s2, 30.0)
weak3 = ta.crossunder(s3, 30.0)
weak4 = ta.crossunder(s4, 30.0)
weak5 = ta.crossunder(s5, 30.0)
weak6 = ta.crossunder(s6, 30.0)
weak7 = ta.crossunder(s7, 30.0)
weak8 = ta.crossunder(s8, 30.0)
weak9 = ta.crossunder(s9, 30.0)
strong_cross = strong0 or strong1 or strong2 or strong3 or strong4 or strong5 or strong6 or strong7 or strong8 or strong9
weak_cross = weak0 or weak1 or weak2 or weak3 or weak4 or weak5 or weak6 or weak7 or weak8 or weak9

alertcondition(strong_cross, title="QSX Regime Strong Breakout", message="QSX Regime: one tracked coin crossed above score 70")
alertcondition(weak_cross, title="QSX Regime Weak Breakdown", message="QSX Regime: one tracked coin crossed below score 30")
````
