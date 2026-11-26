# Sovereign Execution [JOAT]

- url: https://www.tradingview.com/script/hVJ4WG1v-Sovereign-Execution-JOAT/
- type: strategy
- pine_id: PUB;959cd935d80a4b628e2a2fa91b566046
- version: 1.0

## Description

[b]Sovereign Execution [JOAT][/b]

[b]Introduction[/b]

Sovereign Execution is an open-source multi-layer trading strategy that synthesizes five independent analytical engines into a unified execution framework. Rather than relying on a single indicator or a simple crossover, this strategy requires alignment across regime classification, momentum displacement, session timing, imbalance confluence, and multi-timeframe bias scoring before any trade is taken. The result is a highly selective system that filters out low-conviction setups and only enters when multiple independent analytical dimensions agree.

The strategy uses ATR-based adaptive stop-losses, configurable risk-reward ratio targets, optional trailing stops, and multiple exit conditions including regime flips and opposite displacement detection. It is designed for traders who want a systematic, rules-based approach to execution with full transparency into every decision the system makes.

[image]https://www.tradingview.com/x/tSWJQK8f/[/image]

[b]Why This Strategy Exists[/b]

Most trading strategies suffer from one of two problems: they are either too simple (single-indicator entries that generate excessive noise) or too complex (dozens of conditions that are impossible to understand or debug). Sovereign Execution occupies the middle ground by using exactly five analytical layers, each addressing a different aspect of market conditions:

[list]
[*][b]Regime Cipher:[/b] Is the market trending or compressing? Only trade in trending regimes.
[*][b]Displacement Lens:[/b] Is there institutional momentum right now? Only enter on confirmed displacement.
[*][b]Session Filter:[/b] Is the market in an active trading session? Avoid low-liquidity periods.
[*][b]Imbalance Confluence:[/b] Is there a Fair Value Gap nearby? Optional confirmation of institutional interest.
[*][b]Confluence Ledger:[/b] Do multiple timeframes agree on direction? Only trade when the score exceeds the threshold.
[/list]

Each layer acts as an independent filter. A trade only fires when ALL active filters align simultaneously. This multi-gate approach dramatically reduces false signals compared to single-indicator strategies.

[b]Module 1: Regime Cipher — Trend and Volatility Classification[/b]

The regime engine uses an Outlier-Resistant Moving Average (ORMA) as its foundation. The ORMA applies a square-root transformation to price, calculates a base moving average (configurable: EMA, SMA, RMA, WMA, HMA, DEMA, or TEMA), then applies a volatility-dampening filter using the ratio of full ATR to half-period ATR. This creates a moving average that is responsive to genuine trend changes but resistant to outlier spikes.

ATR-based bands are drawn above and below the ORMA. When price closes above the upper band, the regime is classified as Trending Bull. When price closes below the lower band, Trending Bear. The strategy also monitors Bollinger Band width relative to its 50-bar average to detect compression (BB width below 85% of average) and expansion (above 110%).

The key rule: the strategy only takes trades when the regime is Trending (not Compressed or Transitional). This single filter eliminates the majority of choppy, range-bound conditions where most strategies bleed money.

[b]Module 2: Displacement Lens — Momentum Timing[/b]

The displacement engine normalizes three momentum oscillators (Bollinger %B, CCI, ROC) to a [-1, +1] scale and blends them with a volume-weighted candle body analysis. The composite is smoothed with an EMA and compared against adaptive threshold bands calculated from the signal's own standard deviation.

A "strong bull displacement" occurs when the composite exceeds the upper threshold — meaning momentum, volume, and candle structure all confirm bullish institutional activity. Strong bear displacement is the mirror condition. The strategy only enters when displacement confirms the regime direction.

[b]Module 3: Session Filter[/b]

Trading sessions are defined by UTC hour ranges (configurable for Asia, London, and New York). When the session filter is enabled (default), the strategy only takes trades during active sessions. This avoids entries during low-liquidity periods (overnight gaps, holiday hours) where spreads widen and price action is unreliable.

The session filter is optional — it can be disabled for instruments that trade 24/7 with consistent liquidity (e.g., major crypto pairs).

[b]Module 4: FVG Confluence (Optional)[/b]

When enabled, the strategy scans the last 10 bars for Fair Value Gaps in the entry direction. A bullish FVG (gap up in price delivery) near the entry confirms institutional buying interest. A bearish FVG confirms selling interest. This filter is optional (default off) because not all valid setups occur near FVGs, but when enabled, it adds an additional layer of institutional confirmation.

[b]Module 5: Confluence Score — Multi-Timeframe Bias Gate[/b]

The strategy calculates a simplified confluence score combining trend alignment, momentum, volatility state, market structure, and volume conviction on the current timeframe, then blends it with a higher timeframe score (default 4H) at a 40/60 weighting (HTF gets more weight).

The score is mapped to 0-100. Long entries require the score to exceed the long threshold (default 60). Short entries require the score to be below the short threshold (default 40). This ensures the strategy only trades when multiple analytical dimensions across timeframes agree on direction.

[b]Entry Conditions[/b]

A long entry requires ALL of the following simultaneously:
[list]
[*]Regime is Trending Bull (price above upper ORMA band, not compressing)
[*]Confluence score >= long threshold (default 60)
[*]Strong bullish displacement (composite above adaptive threshold)
[*]Active session (if session filter enabled)
[*]Recent bullish FVG (if FVG filter enabled)
[*]Bar is confirmed (barstate.isconfirmed — no intrabar entries)
[/list]

Short entries require the bearish mirror of all conditions. Edge detection ensures each signal fires only once — no repeated entries on the same setup.

[b]Risk Management[/b]

[b]Stop-Loss:[/b] ATR-based adaptive stop calculated as ATR(14) multiplied by the stop multiplier (default 1.5). For longs, the stop is placed below the entry price by this distance. For shorts, above. This means the stop automatically adapts to the instrument's current volatility — wider stops in volatile markets, tighter stops in calm markets.

[b]Take-Profit:[/b] Calculated as the stop distance multiplied by the reward-risk ratio (default 2.0). A 1.5 ATR stop with a 2.0 R:R produces a 3.0 ATR take-profit target.

[b]Trailing Stop:[/b] When enabled (default), the stop is trailed upward (for longs) or downward (for shorts) using the trail ATR multiplier (default 2.0). The trail only moves in the favorable direction — it never moves against the position.

[b]Exit Conditions[/b]

Beyond the TP/SL levels, the strategy has two additional exit conditions:

[list]
[*][b]Regime Flip:[/b] If the regime changes from Trending Bull to Trending Bear (or vice versa), or enters Compression, the position is closed immediately. The thesis for the trade no longer holds.
[*][b]Opposite Displacement:[/b] If strong displacement fires in the opposite direction of the trade, the position is closed. Institutional momentum has shifted against the position.
[/list]

[b]Default Strategy Properties[/b]

These are the exact values used in the strategy's Properties dialog:

[list]
[*][b]Initial Capital:[/b] $100,000 — a realistic account size for the average trader
[*][b]Default Quantity:[/b] 5% of equity per trade — conservative position sizing
[*][b]Commission:[/b] 0.04% per trade (round-trip 0.08%) — realistic for most exchanges
[*][b]Slippage:[/b] 2 ticks per order — accounts for execution delay and spread
[*][b]Pyramiding:[/b] 0 — only one position at a time
[*][b]Calc on Every Tick:[/b] false — entries only on bar close for realistic execution
[/list]

These settings are intentionally conservative. The commission and slippage values are included to produce realistic backtesting results. Traders should adjust these values to match their specific broker/exchange conditions.

[b]Visualization[/b]

[list]
[*][b]Regime MA:[/b] The ORMA line plotted with a glow effect (crisp line + transparent wider line) colored by trend state — teal for bullish, rose for bearish, gray for neutral
[*][b]ATR Bands:[/b] Upper and lower bands showing the regime breakout thresholds
[*][b]SL/TP Levels:[/b] When a position is active, the stop-loss (red), take-profit (green), and entry price (gray) are plotted as horizontal lines
[*][b]Gradient Candles:[/b] Candles colored by the confluence score — transitioning from bearish rose (low score) to bullish teal (high score)
[*][b]Session Background:[/b] Subtle amber tint when an active session is in progress
[/list]

[b]10-Row Dashboard[/b]

[list]
[*][b]Row 1:[/b] Header — "SOVEREIGN EXECUTION"
[*][b]Row 2:[/b] Regime — TREND LONG / TREND SHORT / COMPRESSED / TRANSITIONAL
[*][b]Row 3:[/b] Displacement — BULL DISP / BEAR DISP / NEUTRAL
[*][b]Row 4:[/b] Session — ASIA / LONDON / NEW YORK / OFF-SESSION
[*][b]Row 5:[/b] Confluence — Score value + bias classification
[*][b]Row 6:[/b] Volatility — EXPANDING / COMPRESSED / NORMAL
[*][b]Row 7:[/b] Position — LONG / SHORT / FLAT
[*][b]Row 8:[/b] Entry — Entry price when in a trade
[*][b]Row 9:[/b] Stop — Current stop-loss level
[*][b]Row 10:[/b] Target — Current take-profit level
[/list]

[image]https://www.tradingview.com/x/fQUBQgj0/[/image]

[b]Input Parameters[/b]

[b]Execution Parameters:[/b]
[list]
[*]Risk Per Trade % (default 1.5) — percentage of equity risked per trade
[*]Reward:Risk Ratio (default 2.0) — take-profit as multiple of stop distance
[*]ATR Stop Multiplier (default 1.5) — stop distance as ATR multiple
[*]Use Trailing Stop (default on), Trail ATR Multiplier (default 2.0)
[/list]

[b]Entry Filters:[/b]
[list]
[*]Confluence Threshold Long (default 60) — minimum score for long entries
[*]Confluence Threshold Short (default 40) — maximum score for short entries
[*]Require Active Session (default on)
[*]Require FVG Confluence (default off)
[/list]

[b]Regime Cipher Parameters:[/b]
[list]
[*]Adaptive MA Length (default 27), ATR Length (default 14), ATR Factor (default 1.05)
[*]Base MA type (default EMA, options: RMA/SMA/EMA/WMA/HMA/DEMA/TEMA)
[/list]

[b]Displacement Parameters:[/b]
[list]
[*]BB Length (20), BB Multiplier (2.0), CCI Length (23), ROC Length (50)
[*]Displacement Smoothing (default 5)
[/list]

[b]Session Filter (UTC):[/b]
[list]
[*]Asia Start/End (0/8), London Start/End (8/14), NY Start/End (14/21)
[/list]

[b]Strategy Limitations and Compromises[/b]

Every strategy involves design compromises. Here are the key ones for Sovereign Execution:

[list]
[*][b]Selectivity vs Frequency:[/b] The multi-gate filter approach produces fewer trades than single-indicator strategies. On some instruments/timeframes, the strategy may go days without a signal. This is by design — it prioritizes quality over quantity — but it means the strategy needs sufficient historical data to produce a meaningful sample size.
[*][b]Regime Lag:[/b] The ORMA-based regime classification has inherent lag. It will not catch the exact top or bottom of a trend. The strategy enters after the trend is confirmed, which means it misses the first portion of moves.
[*][b]Session Filter Limitation:[/b] The UTC-based session filter works well for forex and indices but may need adjustment for instruments with non-standard trading hours. Crypto traders may want to disable the session filter entirely.
[*][b]Single Timeframe Execution:[/b] While the confluence score incorporates HTF data, entries and exits are executed on the chart's timeframe. Very fast timeframes (1m) may produce noisy signals despite the filters.
[*][b]Backtesting Caveats:[/b] All backtesting results are historical and do not guarantee future performance. The strategy uses calc_on_every_tick=false and barstate.isconfirmed to produce realistic entries, but real-world execution will always differ from backtesting due to slippage, partial fills, and latency.
[*][b]No Guarantee of Profitability:[/b] This strategy is a systematic framework, not a profit guarantee. Market conditions change, and strategies that worked historically may underperform in different regimes.
[/list]

[b]Recommended Usage[/b]

[list]
[*]Use on liquid instruments (major forex pairs, large-cap stocks, major crypto) for most reliable signals
[*]Test on the 15m to 4H timeframe range — these provide enough bars for the regime and displacement engines while maintaining meaningful session context
[*]Ensure the backtest produces at least 100 trades for statistical significance before drawing conclusions
[*]Adjust commission and slippage to match your specific broker/exchange
[*]Consider the strategy as one component of a broader trading plan, not a standalone system
[/list]

[b]Originality Statement[/b]

This strategy is original in its multi-layer filter architecture. While individual components (moving averages, momentum oscillators, session filters) are established concepts, this strategy is justified because:

[list]
[*]It synthesizes five independent analytical engines (regime classification, displacement measurement, session timing, imbalance confluence, multi-TF scoring) into a unified execution framework where ALL must align for entry
[*]The ORMA-based regime engine uses a volatility-dampened, outlier-resistant moving average with ATR bands — not a standard MA crossover
[*]The displacement engine normalizes three oscillators and blends them with volume-weighted candle body analysis for institutional-grade momentum confirmation
[*]The confluence score combines five analytical dimensions with HTF weighting, producing a quantitative bias gate rather than a subjective assessment
[*]Multiple exit conditions (regime flip, opposite displacement, trailing stop, TP/SL) provide layered risk management beyond simple stop-loss
[*]The strategy uses realistic default settings (commission, slippage, position sizing) and documents all Properties values for transparent backtesting
[/list]

[b]Disclaimer[/b]

This strategy is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss and is not suitable for all investors.

Backtesting results shown are historical and do not guarantee future performance. The results of a single backtest run do not constitute proof that the strategy will be profitable in the future. Market conditions change, and strategies that performed well historically may underperform or lose money in different market environments.

The default settings (commission 0.04%, slippage 2 ticks, 5% equity per trade, $100,000 initial capital) are designed to produce realistic results. Users should verify these match their trading conditions and adjust accordingly.

Always use proper risk management. Never risk more than you can afford to lose. Consider consulting with a qualified financial advisor before making investment decisions. The author is not responsible for any losses incurred from using this strategy.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
strategy("Sovereign Execution [JOAT]", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=5, initial_capital=100000, commission_type=strategy.commission.percent, commission_value=0.04, slippage=2, pyramiding=0, calc_on_every_tick=false, max_bars_back=500, max_lines_count=200, max_labels_count=100, max_boxes_count=100)

// ─── COLOR SYSTEM ────────────────────────────────────────────────────────────
c_long_entry  = color.rgb(0, 220, 155)
c_short_entry = color.rgb(210, 50, 125)
c_long_exit   = color.rgb(0, 150, 110, 40)
c_short_exit  = color.rgb(150, 40, 90, 40)
c_neutral     = color.rgb(70, 70, 90)
c_bg          = color.rgb(18, 18, 28)
c_header      = color.rgb(30, 30, 42)
c_txt_dim     = color.rgb(130, 130, 150)
c_txt_bright  = color.rgb(200, 200, 220)
c_amber       = color.rgb(255, 180, 40)

// ─── STRATEGY INPUTS ─────────────────────────────────────────────────────────
grp_exec = "Execution Parameters"
i_risk_pct     = input.float(1.5, "Risk Per Trade (%)", minval=0.1, maxval=10, step=0.1, group=grp_exec)
i_rr_ratio     = input.float(2.0, "Reward:Risk Ratio", minval=1.0, maxval=5.0, step=0.25, group=grp_exec)
i_atr_sl_mult  = input.float(1.5, "ATR Stop Multiplier", minval=0.5, maxval=5.0, step=0.25, group=grp_exec)
i_trail_atr    = input.bool(true, "Use Trailing Stop", group=grp_exec)
i_trail_mult   = input.float(2.0, "Trail ATR Multiplier", minval=1.0, maxval=5.0, step=0.25, group=grp_exec)

grp_filters = "Entry Filters"
i_conf_thresh  = input.int(60, "Confluence Threshold (Long)", minval=50, maxval=90, group=grp_filters, tooltip="Minimum confluence score to allow long entries")
i_conf_thresh_s= input.int(40, "Confluence Threshold (Short)", minval=10, maxval=50, group=grp_filters, tooltip="Maximum confluence score to allow short entries")
i_require_sess = input.bool(true, "Require Active Session", group=grp_filters)
i_require_fvg  = input.bool(false, "Require FVG Confluence", group=grp_filters, tooltip="Entry must be near an active FVG")

grp_regime = "Regime Cipher Parameters"
i_ma_len       = input.int(27, "Adaptive MA Length", minval=4, group=grp_regime)
i_atr_len      = input.int(14, "ATR Length", minval=1, group=grp_regime)
i_atr_factor   = input.float(1.05, "ATR Factor", minval=0.1, step=0.05, group=grp_regime)
i_base_ma      = input.string("EMA", "Base MA", options=["RMA","SMA","EMA","WMA","HMA","DEMA","TEMA"], group=grp_regime)

grp_disp = "Displacement Parameters"
i_bb_len       = input.int(20, "BB Length", minval=5, group=grp_disp)
i_bb_mult      = input.float(2.0, "BB Multiplier", minval=0.5, step=0.1, group=grp_disp)
i_cci_len      = input.int(23, "CCI Length", minval=5, group=grp_disp)
i_roc_len      = input.int(50, "ROC Length", minval=5, group=grp_disp)
i_disp_smooth  = input.int(5, "Displacement Smoothing", minval=1, maxval=20, group=grp_disp)

grp_sess = "Session Filter (UTC)"
i_asia_s = input.int(0, "Asia Start", minval=0, maxval=23, group=grp_sess)
i_asia_e = input.int(8, "Asia End", minval=0, maxval=23, group=grp_sess)
i_ldn_s  = input.int(8, "London Start", minval=0, maxval=23, group=grp_sess)
i_ldn_e  = input.int(14, "London End", minval=0, maxval=23, group=grp_sess)
i_ny_s   = input.int(14, "NY Start", minval=0, maxval=23, group=grp_sess)
i_ny_e   = input.int(21, "NY End", minval=0, maxval=23, group=grp_sess)

grp_conf = "Confluence Ledger Parameters"
i_htf        = input.timeframe("240", "Higher TF for Bias", group=grp_conf)
i_swing_len  = input.int(10, "Swing Length", minval=3, group=grp_conf)

grp_vis = "Visualization"
i_show_dash  = input.bool(true, "Show Dashboard", group=grp_vis)
i_show_levels= input.bool(true, "Show SL/TP Levels", group=grp_vis)

// ════════════════════════════════════════════════════════════════════════════════
// MODULE 1 — REGIME CIPHER (Trend + Volatility State)
// ════════════════════════════════════════════════════════════════════════════════
// Custom MA implementations (not built-in to Pine v6)
f_dema(float src, int len) =>
    float e1 = ta.ema(src, len)
    float e2 = ta.ema(e1, len)
    2.0 * e1 - e2

f_tema(float src, int len) =>
    float e1 = ta.ema(src, len)
    float e2 = ta.ema(e1, len)
    float e3 = ta.ema(e2, len)
    3.0 * e1 - 3.0 * e2 + e3

f_hma(float src, int len) =>
    int half_len = int(math.max(1, math.round(len / 2)))
    int sqrt_len = int(math.max(1, math.round(math.sqrt(len))))
    float wma1 = ta.wma(src, half_len)
    float wma2 = ta.wma(src, len)
    ta.wma(2.0 * wma1 - wma2, sqrt_len)

x_src = math.sqrt(close)
r_coeff = 2.0 / (1.0 + i_ma_len)

base_val = switch i_base_ma
    "RMA"  => ta.rma(x_src, i_ma_len)
    "SMA"  => ta.sma(x_src, i_ma_len)
    "EMA"  => ta.ema(x_src, i_ma_len)
    "WMA"  => ta.wma(x_src, i_ma_len)
    "HMA"  => f_hma(x_src, i_ma_len)
    "DEMA" => f_dema(x_src, i_ma_len)
    "TEMA" => f_tema(x_src, i_ma_len)

core_ma = base_val * (base_val * r_coeff + nz(base_val[1]) * (1.0 - r_coeff))
atr_full = ta.atr(i_atr_len) * i_atr_factor
atr_half = ta.atr(int(math.max(1, math.round(i_atr_len / 2)))) * i_atr_factor
vol_ratio = atr_half != 0 ? atr_full / atr_half : 1.0
regime_ma = core_ma * (1.0 - vol_ratio) + nz(core_ma[1]) * vol_ratio
band_up = regime_ma + atr_full
band_lo = regime_ma - atr_full

var int trend_state = 0
if close > band_up
    trend_state := 1
if close < band_lo
    trend_state := -1

// Volatility regime
bb_width = ta.stdev(close, i_bb_len) * i_bb_mult * 2.0
bb_width_ma = ta.sma(bb_width, 50)
is_expanding = bb_width > bb_width_ma * 1.1
is_compressing = bb_width < bb_width_ma * 0.85

// Regime classification
bool regime_trending_bull = trend_state == 1 and not is_compressing
bool regime_trending_bear = trend_state == -1 and not is_compressing

// ════════════════════════════════════════════════════════════════════════════════
// MODULE 2 — DISPLACEMENT LENS (Momentum Timing)
// ════════════════════════════════════════════════════════════════════════════════
f_bb_norm() =>
    float basis = ta.sma(close, i_bb_len)
    float dev = i_bb_mult * ta.stdev(close, i_bb_len)
    float span = 2.0 * dev
    float pct_b = span != 0 ? (close - (basis - dev)) / span : 0.5
    math.max(-1.0, math.min(1.0, (pct_b - 0.5) * 2.0))

f_cci_norm() =>
    math.max(-1.0, math.min(1.0, ta.cci(close, i_cci_len) / 200.0))

f_roc_norm() =>
    float roc_v = ta.roc(close, i_roc_len)
    float roc_std = ta.stdev(ta.roc(close, i_roc_len), 50)
    roc_std != 0 ? math.max(-1.0, math.min(1.0, roc_v / (roc_std * 2.0))) : 0.0

float osc_composite = (f_bb_norm() + f_cci_norm() + f_roc_norm()) / 3.0

// Volume-weighted displacement
float body_size = math.abs(close - open)
float candle_range = high - low
float body_ratio = candle_range != 0 ? body_size / candle_range : 0.0
float vol_sma = ta.sma(volume, 20)
float vol_intensity = vol_sma != 0 ? math.max(-1.0, math.min(1.0, (volume / vol_sma - 1.0))) : 0.0
float disp_dir = close > open ? 1.0 : close < open ? -1.0 : 0.0
float vol_disp = disp_dir * body_ratio * vol_intensity

float displacement = ta.ema(osc_composite * 0.7 + vol_disp * 0.3, i_disp_smooth)

// Adaptive thresholds
float disp_std = ta.stdev(displacement, 100)
float disp_thresh_up = disp_std * 1.5
float disp_thresh_dn = -disp_std * 1.5

bool strong_bull_disp = displacement > disp_thresh_up
bool strong_bear_disp = displacement < disp_thresh_dn

// ════════════════════════════════════════════════════════════════════════════════
// MODULE 3 — SESSION FILTER
// ════════════════════════════════════════════════════════════════════════════════
int utc_h = hour(time, "UTC")
bool in_session = (utc_h >= i_asia_s and utc_h < i_asia_e) or (utc_h >= i_ldn_s and utc_h < i_ldn_e) or (utc_h >= i_ny_s and utc_h < i_ny_e)
bool session_ok = not i_require_sess or in_session

// ════════════════════════════════════════════════════════════════════════════════
// MODULE 4 — FVG CONFLUENCE (Optional)
// ════════════════════════════════════════════════════════════════════════════════
bool recent_bull_fvg = false
bool recent_bear_fvg = false
if i_require_fvg
    for i = 1 to 10
        if low[i] > high[i + 2] and close[i + 1] > high[i + 2]
            recent_bull_fvg := true
            break
    for i = 1 to 10
        if high[i] < low[i + 2] and close[i + 1] < low[i + 2]
            recent_bear_fvg := true
            break

bool fvg_ok_long  = not i_require_fvg or recent_bull_fvg
bool fvg_ok_short = not i_require_fvg or recent_bear_fvg

// ════════════════════════════════════════════════════════════════════════════════
// MODULE 5 — CONFLUENCE SCORE (Simplified inline version)
// ════════════════════════════════════════════════════════════════════════════════
// Current TF scores
float s_trend = close > ta.ema(close, i_ma_len) ? 1.0 : -1.0
float s_mom   = osc_composite
float s_vol   = bb_width_ma != 0 ? math.max(-1.0, math.min(1.0, (bb_width / bb_width_ma - 1.0) * 3.0)) : 0.0

f_struct_score() =>
    var int os = 0
    float upper_sw = ta.highest(high, i_swing_len)
    float lower_sw = ta.lowest(low, i_swing_len)
    os := high[i_swing_len] > upper_sw ? 0 : low[i_swing_len] < lower_sw ? 1 : os[1]
    os == 1 ? 1.0 : -1.0

float s_struct = f_struct_score()
float s_volc   = disp_dir * math.min(1.0, vol_intensity)

float ctf_score = (s_trend + s_mom + s_vol + s_struct + s_volc) / 5.0

// HTF scores
f_htf_scores() =>
    float ema_v = ta.ema(close, i_ma_len)
    float t = close > ema_v ? 1.0 : -1.0
    float basis_h = ta.sma(close, i_bb_len)
    float dev_h = i_bb_mult * ta.stdev(close, i_bb_len)
    float span_h = 2.0 * dev_h
    float pct_b_h = span_h != 0 ? (close - (basis_h - dev_h)) / span_h : 0.5
    float m = pct_b_h > 0.5 ? 1.0 : pct_b_h < 0.0 ? -1.0 : 0.0
    (t + m) / 2.0

float htf_score = request.security(syminfo.tickerid, i_htf, f_htf_scores(), lookahead=barmerge.lookahead_on)

// Weighted confluence: CTF=40%, HTF=60%
float raw_conf = ctf_score * 0.4 + nz(htf_score) * 0.6
float confluence = math.round((raw_conf + 1.0) / 2.0 * 100)
confluence := math.max(0, math.min(100, confluence))

bool conf_ok_long  = confluence >= i_conf_thresh
bool conf_ok_short = confluence <= i_conf_thresh_s

// ════════════════════════════════════════════════════════════════════════════════
// ENTRY CONDITIONS — All filters must align
// ════════════════════════════════════════════════════════════════════════════════
bool long_entry  = regime_trending_bull and conf_ok_long and strong_bull_disp and session_ok and fvg_ok_long and barstate.isconfirmed
bool short_entry = regime_trending_bear and conf_ok_short and strong_bear_disp and session_ok and fvg_ok_short and barstate.isconfirmed

// Edge detection: only fire once per signal
var bool prev_long  = false
var bool prev_short = false
bool long_edge  = long_entry and not prev_long
bool short_edge = short_entry and not prev_short
prev_long  := long_entry
prev_short := short_entry

// ════════════════════════════════════════════════════════════════════════════════
// RISK MANAGEMENT — ATR-based SL/TP
// ════════════════════════════════════════════════════════════════════════════════
float atr_risk = ta.atr(i_atr_len)
float sl_dist  = atr_risk * i_atr_sl_mult
float tp_dist  = sl_dist * i_rr_ratio

var float entry_price = na
var float stop_price  = na
var float tp_price    = na
var int   trade_dir   = 0  // 1=long, -1=short

// ════════════════════════════════════════════════════════════════════════════════
// EXIT CONDITIONS
// ════════════════════════════════════════════════════════════════════════════════
// Regime flip exit
bool regime_exit_long  = strategy.position_size > 0 and (trend_state == -1 or is_compressing)
bool regime_exit_short = strategy.position_size < 0 and (trend_state == 1 or is_compressing)

// Opposite displacement exit
bool disp_exit_long  = strategy.position_size > 0 and strong_bear_disp
bool disp_exit_short = strategy.position_size < 0 and strong_bull_disp

// ════════════════════════════════════════════════════════════════════════════════
// ORDER EXECUTION
// ════════════════════════════════════════════════════════════════════════════════
if long_edge and strategy.position_size == 0
    entry_price := close
    stop_price  := close - sl_dist
    tp_price    := close + tp_dist
    trade_dir   := 1
    strategy.entry("Long", strategy.long)
    strategy.exit("Long TP/SL", "Long", stop=stop_price, limit=tp_price)

if short_edge and strategy.position_size == 0
    entry_price := close
    stop_price  := close + sl_dist
    tp_price    := close - tp_dist
    trade_dir   := -1
    strategy.entry("Short", strategy.short)
    strategy.exit("Short TP/SL", "Short", stop=stop_price, limit=tp_price)

// Trailing stop update
if i_trail_atr and strategy.position_size > 0
    float trail_stop = close - atr_risk * i_trail_mult
    if trail_stop > stop_price
        stop_price := trail_stop
        strategy.exit("Long TP/SL", "Long", stop=stop_price, limit=tp_price)

if i_trail_atr and strategy.position_size < 0
    float trail_stop = close + atr_risk * i_trail_mult
    if trail_stop < stop_price
        stop_price := trail_stop
        strategy.exit("Short TP/SL", "Short", stop=stop_price, limit=tp_price)

// Regime/displacement exits
if regime_exit_long or disp_exit_long
    strategy.close("Long", comment="Regime/Disp Exit")
    trade_dir := 0

if regime_exit_short or disp_exit_short
    strategy.close("Short", comment="Regime/Disp Exit")
    trade_dir := 0

// Reset on flat
if strategy.position_size == 0
    trade_dir := 0

// ════════════════════════════════════════════════════════════════════════════════
// VISUALIZATION
// ════════════════════════════════════════════════════════════════════════════════
// Regime MA with glow
color ma_col = trend_state == 1 ? c_long_entry : trend_state == -1 ? c_short_entry : c_neutral
plot(regime_ma, "Regime MA", color=ma_col, linewidth=2)
plot(regime_ma, "MA Glow", color=color.new(ma_col, 70), linewidth=5)

// Bands
plot(band_up, "Upper Band", color=color.new(ma_col, 80), linewidth=1)
plot(band_lo, "Lower Band", color=color.new(ma_col, 80), linewidth=1)

// SL/TP levels on active trade
plot(i_show_levels and strategy.position_size != 0 ? stop_price : na, "Stop Loss", color=color.rgb(255, 80, 80), linewidth=1, style=plot.style_linebr)
plot(i_show_levels and strategy.position_size != 0 ? tp_price : na, "Take Profit", color=color.rgb(80, 255, 160), linewidth=1, style=plot.style_linebr)
plot(i_show_levels and strategy.position_size != 0 ? entry_price : na, "Entry", color=color.rgb(180, 180, 200, 50), linewidth=1, style=plot.style_linebr)

// Candle coloring by regime
color candle_col = color.from_gradient(confluence, 20, 80, c_short_entry, c_long_entry)
plotcandle(open, high, low, close, "Candles", color=candle_col, wickcolor=candle_col, bordercolor=candle_col, force_overlay=true)

// Background session tint
bgcolor(in_session ? color.new(c_amber, 96) : na, title="Session Active")

// ════════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════════════════
if i_show_dash and barstate.islast
    var table dash = table.new(position.top_right, 2, 10, border_width=1, border_color=color.rgb(40, 40, 50), bgcolor=c_bg)

    table.cell(dash, 0, 0, "SOVEREIGN", text_color=c_amber, text_size=size.small, bgcolor=c_header)
    table.cell(dash, 1, 0, "EXECUTION", text_color=c_txt_dim, text_size=size.small, bgcolor=c_header)

    // Regime
    string reg_txt = regime_trending_bull ? "TREND LONG" : regime_trending_bear ? "TREND SHORT" : is_compressing ? "COMPRESSED" : "TRANSITIONAL"
    color  reg_col = regime_trending_bull ? c_long_entry : regime_trending_bear ? c_short_entry : c_neutral
    table.cell(dash, 0, 1, "Regime", text_color=c_txt_dim, text_size=size.tiny)
    table.cell(dash, 1, 1, reg_txt, text_color=reg_col, text_size=size.tiny)

    // Displacement
    string dsp_txt = strong_bull_disp ? "BULL DISP" : strong_bear_disp ? "BEAR DISP" : "NEUTRAL"
    color  dsp_col = strong_bull_disp ? c_long_entry : strong_bear_disp ? c_short_entry : c_neutral
    table.cell(dash, 0, 2, "Displacement", text_color=c_txt_dim, text_size=size.tiny)
    table.cell(dash, 1, 2, dsp_txt, text_color=dsp_col, text_size=size.tiny)

    // Session
    string sess_name = utc_h >= i_asia_s and utc_h < i_asia_e ? "ASIA" : utc_h >= i_ldn_s and utc_h < i_ldn_e ? "LONDON" : utc_h >= i_ny_s and utc_h < i_ny_e ? "NEW YORK" : "OFF-SESSION"
    color  sess_col = in_session ? c_amber : c_neutral
    table.cell(dash, 0, 3, "Session", text_color=c_txt_dim, text_size=size.tiny)
    table.cell(dash, 1, 3, sess_name, text_color=sess_col, text_size=size.tiny)

    // Confluence
    string conf_txt = str.tostring(confluence, "#")
    string bias_txt = confluence >= 70 ? "STRONG LONG" : confluence >= 55 ? "LEAN LONG" : confluence <= 30 ? "STRONG SHORT" : confluence <= 45 ? "LEAN SHORT" : "NEUTRAL"
    color  conf_col = confluence >= 60 ? c_long_entry : confluence <= 40 ? c_short_entry : c_neutral
    table.cell(dash, 0, 4, "Confluence", text_color=c_txt_dim, text_size=size.tiny)
    table.cell(dash, 1, 4, conf_txt + " " + bias_txt, text_color=conf_col, text_size=size.tiny)

    // Volatility
    string vol_txt = is_expanding ? "EXPANDING" : is_compressing ? "COMPRESSED" : "NORMAL"
    color  vol_col = is_expanding ? c_amber : is_compressing ? c_neutral : c_txt_dim
    table.cell(dash, 0, 5, "Volatility", text_color=c_txt_dim, text_size=size.tiny)
    table.cell(dash, 1, 5, vol_txt, text_color=vol_col, text_size=size.tiny)

    // Position
    string pos_txt = strategy.position_size > 0 ? "LONG" : strategy.position_size < 0 ? "SHORT" : "FLAT"
    color  pos_col = strategy.position_size > 0 ? c_long_entry : strategy.position_size < 0 ? c_short_entry : c_neutral
    table.cell(dash, 0, 6, "Position", text_color=c_txt_dim, text_size=size.tiny)
    table.cell(dash, 1, 6, pos_txt, text_color=pos_col, text_size=size.tiny)

    // Entry price
    table.cell(dash, 0, 7, "Entry", text_color=c_txt_dim, text_size=size.tiny)
    table.cell(dash, 1, 7, strategy.position_size != 0 ? str.tostring(entry_price, format.mintick) : "-", text_color=c_txt_bright, text_size=size.tiny)

    // Stop
    table.cell(dash, 0, 8, "Stop", text_color=c_txt_dim, text_size=size.tiny)
    table.cell(dash, 1, 8, strategy.position_size != 0 ? str.tostring(stop_price, format.mintick) : "-", text_color=color.rgb(255, 100, 100), text_size=size.tiny)

    // Target
    table.cell(dash, 0, 9, "Target", text_color=c_txt_dim, text_size=size.tiny)
    table.cell(dash, 1, 9, strategy.position_size != 0 ? str.tostring(tp_price, format.mintick) : "-", text_color=color.rgb(100, 255, 170), text_size=size.tiny)

// ════════════════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════════════════
alertcondition(long_edge, "Sovereign: Long Entry", "All filters aligned — Long entry signal")
alertcondition(short_edge, "Sovereign: Short Entry", "All filters aligned — Short entry signal")
alertcondition(regime_exit_long or regime_exit_short, "Sovereign: Regime Exit", "Regime flipped — closing position")
alertcondition(disp_exit_long or disp_exit_short, "Sovereign: Displacement Exit", "Opposite displacement detected — closing position")
````
