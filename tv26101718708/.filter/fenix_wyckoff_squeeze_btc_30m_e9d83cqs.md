# Fenix Wyckoff Squeeze BTC 30m

- url: https://www.tradingview.com/script/e9D83CQS-Fenix-Wyckoff-Squeeze-BTC-30m/
- type: strategy
- pine_id: PUB;65597ef008444e15a60aa158f38f54c0
- version: 7.0

## Description

Fenix Wyckoff Squeeze — BTC 30m
A systematic trend-following strategy for the 30-minute timeframe, combining four independent signal layers into a single high-confidence entry condition. Default parameters are optimized for BTCUSDC on Binance, but all inputs are fully adjustable — the strategy can be adapted to any symbol or timeframe by tuning the parameters to match that market's characteristics.

Core Philosophy
Most trend-following strategies fail not because the trend concept is wrong, but because they enter too early, in low-quality conditions, or against the dominant momentum. This strategy addresses all three problems simultaneously by requiring four independent conditions to align before any trade is taken. The result is a low-frequency, high-selectivity system — the majority of 30-minute bars produce no signal at all. When a signal does appear, it reflects a convergence of volatility breakout, trend alignment, momentum direction, and oscillator confirmation.

Signal Layer 1 — Squeeze Momentum (Volatility Breakout)
Bollinger Bands (BB) measure price volatility relative to a moving average. Keltner Channels (KC) measure volatility using ATR. When BB contracts inside KC, the market enters a squeeze — a low-volatility compression phase where energy builds. When BB expands back outside KC after a squeeze period, a momentum breakout is detected.
The strategy only considers entries when this breakout occurs following a confirmed squeeze. This filters out random noise and focuses entries on genuine expansions from compressed conditions — a concept rooted in Wyckoff's accumulation and distribution phases, where periods of low volatility precede significant directional moves.
The lookback parameter controls how many bars back the strategy checks for a prior squeeze. A longer lookback means the breakout must follow a longer compression period, producing fewer but higher-quality signals.

Signal Layer 2 — Higher Timeframe EMA Trend Filter
A 2-hour Exponential Moving Average is used as a macro trend filter. Long trades are only allowed when price is above the 2h EMA. Short trades are only allowed when price is below. This single filter eliminates a large proportion of counter-trend entries that would otherwise reduce the strategy's edge.
The EMA length parameter controls how responsive or smooth the trend filter is. Longer values produce a smoother, slower-reacting filter that keeps you aligned with major trends. Shorter values react faster but may produce more whipsaws during trend transitions.
For other timeframes or symbols, this MTF EMA timeframe can be adjusted. The principle is to use a timeframe approximately 4× higher than your entry timeframe.

Signal Layer 3 — HMA Slope (Momentum Acceleration)
The Hull Moving Average is used to confirm that momentum is actively accelerating in the trade direction at the moment of entry. A rising HMA slope confirms long bias. A declining slope confirms short bias.
HMA was chosen over standard MAs because it significantly reduces lag while maintaining smoothness — it reacts faster to momentum shifts than EMA or WMA of equivalent length, making it more effective at confirming the direction of a breakout in real time.

Signal Layer 4 — Phoenix TCI + MoneyFlow + RSI
Three independent momentum oscillators must all agree on direction simultaneously.
The Phoenix TCI (Typical Close Index) is a smoothed momentum oscillator calculated from the typical price (HLC3) relative to its own deviation range, then further smoothed with an EMA. It measures normalized price momentum with reduced noise compared to raw price change.
MoneyFlow is a volume-weighted directional pressure indicator. It compares the sum of bullish volume (bars where price moved up) against bearish volume (bars where price moved down) over a rolling window. When MoneyFlow is rising, institutional buying pressure is dominant. When falling, selling pressure dominates.
RSI is used as a classic momentum confirmation filter. Here it is applied to HLC3 rather than close to reduce sensitivity to wicks and produce a smoother signal.
All three must simultaneously agree on direction — bullish for longs, bearish for shorts. This triple confirmation dramatically reduces false signals compared to using any single oscillator alone.
A secondary LSMA (Least Squares Moving Average) is applied to the composite Phoenix value as an additional trend confirmation. The LSMA slope must also agree with the trade direction.

Exit Logic
Three independent exit mechanisms are active simultaneously. Whichever triggers first closes the position.
The ATR Trailing Stop is set at entry as a multiple of ATR below price for longs, above price for shorts. It moves with price as the trade progresses — locking in profits while giving the trade room to breathe. The stop only moves in the profitable direction and never moves against the trade.
The ATR Take Profit is a fixed multiple of ATR set as a hard profit target at the moment of entry. When price reaches this level, the position closes regardless of other conditions.
The Maximum Hold Bars exit closes the trade after a maximum number of bars regardless of P&L. This prevents positions from being held indefinitely in slow, directionless markets where the original signal has likely expired.
A fourth optional exit is the Phoenix momentum reversal — when the Phoenix oscillator crosses below its signal line (for longs) or above (for shorts), it signals momentum exhaustion and the position closes.

Regime Filter (ADX)
An optional ADX-based regime filter prevents entries during sideways, low-trend markets. When ADX falls below the threshold, the market is considered to be in a ranging phase and no new entries are allowed. This filter is most effective on lower timeframes where choppy, directionless price action is more frequent.
ADX threshold of 18 is the default — values below 18 indicate weak trend, values above indicate a trending environment. This can be adjusted based on the symbol and timeframe.

Volatility-Adaptive ATR (Optional)
An optional volatility scaling mode adjusts the ATR stop and take profit multipliers based on the current volatility percentile. In low-volatility environments, the multipliers are scaled down slightly. In high-volatility environments, they are scaled up. This keeps the strategy's risk-reward profile consistent across different market conditions. Disabled by default — enable with caution and verify on your target symbol before live use.

Position Sizing
Position size is calculated dynamically at each entry using ATR-based risk management. The formula ensures that the distance from entry to stop loss always represents the same fixed percentage of equity, regardless of current volatility. This keeps actual dollar risk per trade approximately constant.
Default risk per trade is 2% of equity. This can be adjusted via the Risk per trade input. The position size is capped at 2× equity to prevent excessive leverage in extreme low-volatility conditions.

Backtest Conditions
Commission: 0.1% per trade (standard Binance Futures taker fee). Slippage: 2 ticks. process_orders_on_close: true — signals are only acted upon at confirmed bar close, eliminating intra-bar look-ahead bias. Lookahead is explicitly set to OFF in all security calls.
Default parameters were tested on BTCUSDC 30m data from December 2018 to March 2026 — covering 8+ years and 507 completed trades across all major market regimes: the 2019 accumulation phase, the 2020–2021 bull run, the 2022 bear market, the 2023 sideways consolidation, and the 2024–2025 recovery.

Adapting to Other Symbols and Timeframes
The default parameters are specifically optimized for BTCUSDC on the 30-minute timeframe. Applying them directly to other symbols or timeframes without adjustment will likely produce suboptimal results, as each market has different volatility characteristics, trend behaviors, and momentum profiles.
To adapt the strategy to a different symbol or timeframe, the following parameters are most important to re-tune: BB length and multipliers, KC multiplier, ATR length and multipliers, Phoenix N1/N2/N3 lengths, HMA length, EMA MTF length, and the squeeze lookback period. The regime filter ADX threshold should also be calibrated to the target market's typical trend strength.
A systematic approach using parameter optimization (grid search or Bayesian optimization) across a representative historical dataset is recommended over manual trial-and-error.

Why the Win Rate Is Low
This is a trend-following system, not a mean-reversion system. It accepts a low win rate (approximately 28% on default settings) in exchange for a high reward-to-risk ratio. The average winning trade is significantly larger than the average losing trade. The mathematical edge comes from this asymmetry, not from being right more often than wrong. This is a normal and expected characteristic of breakout and momentum strategies.

Disclaimer
Past performance does not guarantee future results. Cryptocurrency trading involves significant risk of loss. Only trade with capital you can afford to lose entirely. This script is provided for educational and research purposes only and does not constitute financial advice. You are solely responsible for your trading decisions.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════
// Fenix Wyckoff Squeeze — BTC 30m
// Trend-following strategy: Squeeze + EMA MTF + HMA + Phoenix TCI
// Optimized for BTCUSDC 30m | Adaptable to any symbol/timeframe
// ═══════════════════════════════════════════════════════════════════
strategy("Fenix Wyckoff Squeeze — BTC 30m",
     overlay            = true,
     initial_capital    = 10000,
     default_qty_type   = strategy.percent_of_equity,
     default_qty_value  = 100,
     commission_type    = strategy.commission.percent,
     commission_value   = 0.1,
     slippage           = 2,
     calc_on_every_tick = false,
     process_orders_on_close = true,
     max_bars_back      = 5000)

// ── Parametre ────────────────────────────────────────────────────────
int   entry_n1        = input.int(1188,   "Phoenix N1 (TCI EMA)",       group="Phoenix TCI")
int   entry_n2        = input.int(366,    "Phoenix N2 (TCI smooth)",    group="Phoenix TCI")
int   entry_n3        = input.int(3512,   "Phoenix N3 (MF + RSI)",      group="Phoenix TCI")
int   lsma_len        = input.int(1320,   "LSMA length",                group="Phoenix TCI")

int   bb_len          = input.int(138,    "BB length",                  group="Squeeze")
float bb_mult         = input.float(10.2, "BB mult",    step=0.1,       group="Squeeze")
float kc_mult         = input.float(20.5, "KC mult",    step=0.1,       group="Squeeze")
int   sq_lookback     = input.int(68,     "Squeeze lookback",           group="Squeeze")

int   ema_len         = input.int(476,    "EMA 2h MTF length",          group="Filters")
int   hma_len         = input.int(600,    "HMA length (30m)",           group="Filters")

int   atr_len         = input.int(412,    "ATR length",                 group="Risk")
float atr_stop_mult   = input.float(18.6, "ATR stop mult",  step=0.1,   group="Risk")
float atr_tp_mult     = input.float(38.8, "ATR TP mult",    step=0.1,   group="Risk")
int   max_hold_bars   = input.int(480,    "Max hold bars",              group="Risk")
float risk_pct        = input.float(0.020,"Risk per trade (0.02 = 2%)", step=0.001, group="Risk")
int   exit_slope_bars = input.int(296,    "Exit slope bars",            group="Risk")

int   vol_lookback    = input.int(135,    "Vol ATR lookback",           group="Volatility Filter")
float vol_pct_low     = input.float(4.0,  "Vol percentile min",         group="Volatility Filter")
float vol_pct_high    = input.float(99.0, "Vol percentile max",         group="Volatility Filter")

bool  use_regime      = input.bool(true,  "Enable Regime filter (ADX)", group="Regime Filter")
int   adx_len         = input.int(14,     "ADX length",                 group="Regime Filter")
float adx_threshold   = input.float(18.0, "ADX threshold",  step=0.5,   group="Regime Filter")

bool  use_vol_adapt   = input.bool(false, "Volatility-adaptive ATR",    group="Vol Adaptive")
float vol_scale_min   = input.float(0.8,  "Vol scale min",  step=0.05,  group="Vol Adaptive")
float vol_scale_max   = input.float(1.2,  "Vol scale max",  step=0.05,  group="Vol Adaptive")

// ── Phoenix TCI + MoneyFlow + RSI ─────────────────────────────────────
ema_src  = ta.ema(hlc3, entry_n1)
dev_tci  = ta.ema(math.abs(hlc3 - ema_src), entry_n1)
tci_raw  = (hlc3 - ema_src) / math.max(dev_tci, 1e-6) / 0.025
tci      = ta.ema(tci_raw, entry_n2) + 50.0

chg      = hlc3 - hlc3[1]
upper_v  = chg > 0 ? hlc3 * volume : 0.0
lower_v  = chg < 0 ? hlc3 * volume : 0.0
mf       = 100.0 - 100.0 / (1.0 + math.sum(upper_v, entry_n3) / math.max(math.sum(lower_v, entry_n3), 1e-6))
rsi_h    = ta.rsi(hlc3, entry_n3)

wt1      = (tci + mf + rsi_h) / 3.0
wt2      = ta.sma(wt1, 6)
wt3      = ta.linreg(wt1, lsma_len, 0)

phoenix_bull = wt1 > wt2 and wt1 > wt1[1]
phoenix_bear = wt1 < wt2 and wt1 < wt1[1]
lsma_bull    = wt3 > 50.0
lsma_bear    = wt3 < 50.0

exit_long_cross  = ta.crossunder(wt1, wt2)
exit_short_cross = ta.crossover(wt1, wt2)

wt1_diff         = wt1 - wt1[1]
exit_long_slope  = exit_slope_bars <= 1 ? wt1_diff < 0 :
     math.sum(wt1_diff < 0 ? 1 : 0, exit_slope_bars) >= exit_slope_bars
exit_short_slope = exit_slope_bars <= 1 ? wt1_diff > 0 :
     math.sum(wt1_diff > 0 ? 1 : 0, exit_slope_bars) >= exit_slope_bars

// ── Squeeze (BB vs KC) ────────────────────────────────────────────────
basis    = ta.sma(close, bb_len)
upper_bb = basis + bb_mult * ta.stdev(close, bb_len)
lower_bb = basis - bb_mult * ta.stdev(close, bb_len)
upper_kc = basis + kc_mult * ta.atr(bb_len)
lower_kc = basis - kc_mult * ta.atr(bb_len)

squeeze_on     = upper_bb < upper_kc and lower_bb > lower_kc
squeeze_off    = upper_bb > upper_kc or lower_bb < lower_kc
recent_squeeze = math.sum(squeeze_on[1] ? 1 : 0, sq_lookback) > 0
squeeze_fired  = squeeze_off and recent_squeeze

// ── HMA filter ────────────────────────────────────────────────────────
hma_half  = math.floor(hma_len / 2)
hma_sqrtn = math.max(math.floor(math.sqrt(hma_len)), 2)
hma_raw   = 2.0 * ta.wma(close, hma_half) - ta.wma(close, hma_len)
hma       = ta.wma(hma_raw, hma_sqrtn)
hma_bull  = hma > hma[1]
hma_bear  = hma < hma[1]

// ── EMA 2h MTF filter — natívna 30m EMA, žiadny repainting ───────────
// 30m → 2h = 4× multiplikátor (namiesto request.security)
ema_2h     = ta.ema(close, ema_len * 4)
bull_trend = close > ema_2h
bear_trend = close < ema_2h

// ── Volatility percentile filter ─────────────────────────────────────
atr_14   = ta.atr(14)
vol_rank = ta.percentrank(atr_14, vol_lookback)
vol_ok   = vol_rank >= vol_pct_low and vol_rank <= vol_pct_high

// ── Regime Filter (ADX) ───────────────────────────────────────────────
[adx_plus, adx_minus, adx_val] = ta.dmi(adx_len, adx_len)
regime_ok = not use_regime or adx_val >= adx_threshold

// ── Volatility-Adaptive ATR ───────────────────────────────────────────
vol_scale          = use_vol_adapt ?
     vol_scale_min + (vol_scale_max - vol_scale_min) * (vol_rank / 100.0) : 1.0
adaptive_stop_mult = atr_stop_mult * vol_scale
adaptive_tp_mult   = atr_tp_mult   * vol_scale

// ── Entry / Exit podmienky ────────────────────────────────────────────
long_entry  = squeeze_fired and bull_trend and hma_bull and phoenix_bull and lsma_bull and vol_ok and regime_ok
short_entry = squeeze_fired and bear_trend and hma_bear and phoenix_bear and lsma_bear and vol_ok and regime_ok
exit_long   = exit_long_cross  or exit_long_slope
exit_short  = exit_short_cross or exit_short_slope

// ── Position management ───────────────────────────────────────────────
var float entry_atr_v  = na
var float trail_stop_v = na
var float take_prof_v  = na
var int   bars_held    = 0
atr_val = ta.atr(atr_len)

if strategy.position_size != 0
    bars_held += 1
else
    bars_held := 0

// ── Long ──────────────────────────────────────────────────────────────
if long_entry and strategy.position_size == 0
    stop_pct      = math.max(atr_val * adaptive_stop_mult / close, 0.001)
    size_frac     = math.min(risk_pct / stop_pct, 2.0)
    qty_units     = (strategy.equity * size_frac) / close
    entry_atr_v  := atr_val
    trail_stop_v := close - atr_val * adaptive_stop_mult
    take_prof_v  := close + atr_val * adaptive_tp_mult
    bars_held    := 0
    strategy.entry("Long", strategy.long, qty=qty_units)

if strategy.position_size > 0 and not na(entry_atr_v)
    trail_stop_v := math.max(trail_stop_v, close - entry_atr_v * adaptive_stop_mult)
    if close <= trail_stop_v or close >= take_prof_v or bars_held >= max_hold_bars or exit_long
        strategy.close("Long")
        entry_atr_v  := na
        trail_stop_v := na
        take_prof_v  := na

// ── Short ─────────────────────────────────────────────────────────────
if short_entry and strategy.position_size == 0
    stop_pct      = math.max(atr_val * adaptive_stop_mult / close, 0.001)
    size_frac     = math.min(risk_pct / stop_pct, 2.0)
    qty_units     = (strategy.equity * size_frac) / close
    entry_atr_v  := atr_val
    trail_stop_v := close + atr_val * adaptive_stop_mult
    take_prof_v  := close - atr_val * adaptive_tp_mult
    bars_held    := 0
    strategy.entry("Short", strategy.short, qty=qty_units)

if strategy.position_size < 0 and not na(entry_atr_v)
    trail_stop_v := math.min(trail_stop_v, close + entry_atr_v * adaptive_stop_mult)
    if close >= trail_stop_v or close <= take_prof_v or bars_held >= max_hold_bars or exit_short
        strategy.close("Short")
        entry_atr_v  := na
        trail_stop_v := na
        take_prof_v  := na

// ── Vizualizácia ──────────────────────────────────────────────────────
plotshape(long_entry,  title="Long",  style=shape.triangleup,
     location=location.belowbar, color=color.new(color.green, 0), size=size.small)
plotshape(short_entry, title="Short", style=shape.triangledown,
     location=location.abovebar, color=color.new(color.red, 0),   size=size.small)

plot(strategy.position_size != 0 ? trail_stop_v : na,
     title="Trailing Stop", color=color.orange, linewidth=1, style=plot.style_linebr)
plot(strategy.position_size != 0 ? take_prof_v : na,
     title="Take Profit",   color=color.blue,   linewidth=1, style=plot.style_linebr)

plot(ema_2h, title="EMA 2h MTF", color=color.new(color.gray,   50), linewidth=1)
plot(hma,    title="HMA 30m",    color=color.new(color.purple, 50), linewidth=1)

bgcolor(squeeze_on                             ? color.new(color.orange, 90) : na, title="Squeeze ON")
bgcolor(squeeze_fired                          ? color.new(color.green,  80) : na, title="Squeeze fired")
bgcolor(not vol_ok                             ? color.new(color.red,    95) : na, title="Vol filter OFF")
bgcolor(use_regime and adx_val < adx_threshold ? color.new(color.blue,  93) : na, title="Sideways (ADX low)")
````
