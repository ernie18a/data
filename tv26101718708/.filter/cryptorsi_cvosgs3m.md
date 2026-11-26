# CryptoRSI

- url: https://www.tradingview.com/script/cvosgS3M/
- type: strategy
- pine_id: PUB;b2dca37700894f6d89d81cc26c1f6364
- version: 1.0

## Description

[b]CryptoRSI – Presets[/b]

This strategy is inspired by the work of [b]Pavel Kýček[/b] (Robuxio).

CryptoRSI is a rule-based approach built around [b]RSI extremes[/b] with a simple [b]market regime filter[/b].

[quote]
This is a systematic framework. It does not guarantee results. Crypto markets are volatile and can produce long streaks of false signals.
[/quote]

[b]Core idea[/b]

The strategy seeks to participate in strong upside phases after momentum becomes extreme.

It does so by combining:

[list]
[*]An RSI-based entry rule
[*]A regime filter based on BTC vs its EMA
[*]A mechanical exit rule (WMA or RSI threshold, depending on preset)
[/list]

[b]Presets[/b]

Only one input is exposed: the [b]Preset[/b].

[list]
[*][b]Original[/b] – smoother and more selective. Fewer signals, typically higher quality.
[*][b]Agressif[/b] – faster RSI and higher thresholds. More signals, more noise.
[/list]

[b]Entry rule[/b]

[list]
[*]RSI is computed on the traded symbol.
[*]In [b]Original[/b], RSI is smoothed (SMA smoothing) to reduce noise.
[*]A long entry triggers when RSI exceeds the [b]Buy Threshold[/b].
[/list]

[b]Market filter (BTC regime)[/b]

A market filter is enabled by default.

[list]
[*]The filter uses [b]BITSTAMP:BTCUSD on the [b]Daily[/b] timeframe.
[*]Trades are allowed only when BTC is above its [b]EMA(50)[/b].
[/list]

When the filter is not satisfied, the background turns red.

[b]Exit rule[/b]

Exit depends on the preset:

[list]
[*][b]Original[/b]: exit when price crosses below a [b]WMA(50)[/b].
[*][b]Agressif[/b]: exit when RSI drops below the [b]Sell Threshold[/b].
[/list]

[b]Chart elements[/b]

[list]
[*]RSI plot (smoothed or raw depending on preset)
[*]Horizontal lines showing Buy / Sell thresholds
[*]Background regime highlighting the market filter
[/list]

[b]Important notes[/b]

[quote]
This strategy is long-only.

Backtests assume frictionless execution (no fees, no slippage). Real-world results may differ significantly.

The objective is to provide a consistent decision framework, not to predict tops or bottoms.
[/quote]

## Source Code

````pine
//@version=5
strategy("CryptoRSI", overlay=false, precision=8, initial_capital=1000, default_qty_type=strategy.percent_of_equity, default_qty_value=1)

// Preset (seul input visible)
string preset = input.string("Original", "Preset", options=["Original", "Agressif"], tooltip="Original : stratégie équilibrée et lissée, peu de signaux mais de meilleure qualité.\nAgressif : signaux plus fréquents, meilleure capture des mouvement extreme, en contrepartie d'un plus grand nombre de faux signaux.")

bool isAgressif = preset == "Agressif"

// Paramètres selon le preset
int rsi_period = isAgressif ? 7 : 20
int buy_threshold = isAgressif ? 80 : 60
int sell_threshold = isAgressif ? 70 : 50
bool useWMAExit = isAgressif ? false : true
bool smooth_rsi_enabled = isAgressif ? false : true
bool market_filter_enabled = true

int wmaLength = 50
int smooth_rsi_period = 10
string smooth_rsi_method = "SMA"
string market_filter_ticker = "BITSTAMP:BTCUSD"
int market_filter_ema_period = 50

// RSI Calculation
rsi = ta.rsi(close, rsi_period)

// Smooth RSI Calculation
smooth_rsi = switch smooth_rsi_method
    "SMA" => ta.sma(rsi, smooth_rsi_period)
    "EMA" => ta.ema(rsi, smooth_rsi_period)
    => rsi

final_rsi = smooth_rsi_enabled ? smooth_rsi : rsi

// Market Filter Calculations
market_close = request.security(market_filter_ticker, "D", close)
market_ema = request.security(market_filter_ticker, "D", ta.ema(close, market_filter_ema_period))

// WMA Calculation for Exit
wmaExit = ta.wma(close, wmaLength)

// Market Filter Condition
market_above_ema = market_close > market_ema

// Trading Conditions (MA200 filter removed)
buy_condition = (not market_filter_enabled or market_above_ema) and final_rsi > buy_threshold
sell_condition = useWMAExit ? ta.crossunder(close, wmaExit) : final_rsi < sell_threshold

// Background Color for Market Filter only
bgcolor(market_filter_enabled and not market_above_ema ? color.new(color.red, 90) : na)

// Execute Orders Based on Conditions
if buy_condition
    strategy.entry("Buy", strategy.long)

if sell_condition
    strategy.close("Buy")

// Plot for Debugging
plot(final_rsi, "RSI", color=color.blue)
hline(buy_threshold, "Buy Threshold", color=color.green)
hline(sell_threshold, "Sell Threshold", color=color.red)
````
