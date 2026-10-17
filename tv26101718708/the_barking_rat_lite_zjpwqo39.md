# The Barking Rat Lite

- url: https://www.tradingview.com/script/zjPWQO39-The-Barking-Rat-Lite/
- type: strategy
- pine_id: PUB;b106b6aab0764a31b0720e998c93c4c0
- version: 4.0

## Description

[i]Momentum & FVG Reversion Strategy[/i]
The Barking Rat Lite is a disciplined, short-term mean-reversion strategy that combines RSI momentum filtering, EMA bands, and Fair Value Gap (FVG) detection to identify short-term reversal points. Designed for practical use on volatile markets, it focuses on precise entries and ATR-based take profit management to balance opportunity and risk.

[image]https://www.tradingview.com/x/AZHmDfBM/[/image]

[b]Core Concept[/b]
This strategy seeks potential reversals when short-term price action shows exhaustion outside an EMA band, confirmed by momentum and FVG signals:

[i]EMA Bands:[/i]
Parameters used: A 20-period EMA (fast) and 100-period EMA (slow).

[b]Why chosen:[/b]
- The 20 EMA is sensitive to short-term moves and reflects immediate momentum.
- The 100 EMA provides a slower, structural anchor.

When price trades outside both bands, it often signals overextension relative to both short-term and medium-term trends.

[b]Application in strategy:[/b]
- Long entries are only considered when price dips below both EMAs, identifying potential undervaluation.
- Short entries are only considered when price rises above both EMAs, identifying potential overvaluation.

This dual-band filter avoids counter-trend signals that would occur if only a single EMA was used, making entries more selective..

[i]Fair Value Gap Detection (FVG):[/i]
Parameters used: The script checks for dislocations using a 12-bar lookback (i.e. comparing current highs/lows with values 12 candles back).

[b]Why chosen:
[/b]- A 12-bar displacement highlights significant inefficiencies in price structure while filtering out micro-gaps that appear every few bars in high-volatility markets.
- By aligning FVG signals with candle direction (bullish = close > open, bearish = close < open), the strategy avoids random gaps and instead targets ones that suggest exhaustion.

[b]Application in strategy:[/b]
- Bullish FVGs form when earlier lows sit above current highs, hinting at downward over-extension.
- Bearish FVGs form when earlier highs sit below current lows, hinting at upward over-extension.

This gives the strategy a structural filter beyond simple oscillators, ensuring signals have price-dislocation context.

[i]RSI Momentum Filter:[/i]
Parameters used: 14-period RSI with thresholds of 80 (overbought) and 20 (oversold).

[b]Why chosen:[/b]
- RSI(14) is a widely recognized momentum measure that balances responsiveness with stability.
- The thresholds are intentionally extreme (80/20 vs. the more common 70/30), so the strategy only engages at genuine exhaustion points rather than frequent minor corrections.

[b]Application in strategy:[/b]
- Longs trigger when RSI < 20, suggesting oversold exhaustion.
- Shorts trigger when RSI > 80, suggesting overbought exhaustion.

This ensures entries are not just technically valid but also backed by momentum extremes, raising conviction.

[i]ATR-Based Take Profit:[/i]
Parameters used: 14-period ATR, with a default multiplier of 4.

[b]Why chosen:[/b]
- ATR(14) reflects the prevailing volatility environment without reacting too much to outliers.
- A multiplier of 4 is a pragmatic compromise: wide enough to let trades breathe in volatile conditions, but tight enough to enforce disciplined exits before mean reversion fades.

[b]Application in strategy:[/b]
- At entry, a fixed target is set = Entry Price ± (ATR × 4).
- This target scales automatically with volatility: narrower in calm periods, wider in explosive markets.

By avoiding discretionary exits, the system maintains rule-based discipline.

[b]Visual Signals on Chart[/b]
[list][*]Blue “▲” below candle: Potential long entry
[*]Orange/Yellow “▼” above candle: Potential short entry
[*]Green “✔️”: Trade closed at ATR take profit
[*]Blue (20 EMA) & Orange (100 EMA) lines: Dynamic channel reference[/list]

[image]https://www.tradingview.com/x/xGIcIsBO/[/image]
[image]https://www.tradingview.com/x/43dS5L7V/[/image]

[b]⚙️Strategy report properties[/b]
Position size: 25% equity per trade
Initial capital: 10,000.00 USDT
Pyramiding: 10 entries per direction
Slippage: 2 ticks
Commission: 0.055% per side
Backtest timeframe: 1-minute
Backtest instrument: HYPEUSDT
Backtesting range: Jul 28, 2025 — Aug 17, 2025

[i]Note on Sample Size:[/i]
You’ll notice the report displays fewer than the ideal 100 trades in the strategy report above. This is intentional. The goal of the script is to isolate high-quality, short-term reversal opportunities while filtering out low-conviction setups. This means that the Barking Rat Lite strategy is very selective, filtering out over 90% of market noise. The brief timeframe shown in the strategy report here illustrates its filtering logic over a short window — not its full capabilities. As a result, even on lower timeframes like the 1-minute chart, signals are deliberately sparse — each one must pass all criteria before triggering.

[i]For a larger dataset:[/i]
Once the strategy is applied to your chart, users are encouraged to expand the lookback range or apply the strategy to other volatile pairs to view a full sample.

[b]💡Why 25% Equity Per Trade?[/b]
While it's always best to size positions based on personal risk tolerance, we defaulted to 25% equity per trade in the backtesting data — and here’s why:
[list][*]Backtests using this sizing show manageable drawdowns even under volatile periods.
[*]The strategy generates a sizeable number of trades, reducing reliance on a single outcome.
[*]Combined with conservative filters, the 25% setting offers a balance between aggression and control. 
[*]Users are strongly encouraged to customize this to suit their risk profile.[/list]

[b]What makes Barking Rat Lite valuable[/b]
[list]
[*]Combines multiple layers of confirmation: EMA bands + FVG + RSI
[*]Adaptive to volatility: ATR-based exits scale with market conditions
[*]Clear, actionable visuals: Easy to monitor and manage trades[/list]
[image]https://www.tradingview.com/x/m0F298gz/[/image]

## Source Code

````pine
//@version=5
strategy("The Barking Rat Lite", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=25)

/// === INPUTS === ///
rsiLength = input.int(14, "RSI Length")
rsiOverbought = input.int(80, "RSI Overbought")
rsiOversold = input.int(20, "RSI Oversold")
atrLength = input.int(14, "ATR Length")
atrMultiplier = input.float(4, "ATR TP Multiplier")
emaLengthLower = input.int(20, "EMA Lower")
emaLengthUpper = input.int(100, "EMA Upper")

// === RSI FILTER ===
rsi = ta.rsi(close, rsiLength)
rsi_long_ok = rsi < rsiOversold
rsi_short_ok = rsi > rsiOverbought

// === ATR FOR TP ===
atr = ta.atr(atrLength)

// === EMA BAND ===
emaLower = ta.ema(close, emaLengthLower)
emaUpper = ta.ema(close, emaLengthUpper)

// === PLOT EMA LINES ===
plot(emaLower, color=color.blue, title="EMA Lower", linewidth=2)
plot(emaUpper, color=color.orange, title="EMA Upper", linewidth=2)

// === FVG DETECTION ===
fvg_up = high[12] < low
fvg_down = low[12] > high

// === WICK REJECTION SIGNALS ===
valid_bullish_fvg = fvg_down
valid_bearish_fvg = fvg_up

bullish_signal = valid_bullish_fvg and close > open and rsi_long_ok
bearish_signal = valid_bearish_fvg and close < open and rsi_short_ok

// === TRADE STATE VARIABLES ===
var inTrade = false
var isLong = false
var isShort = false
var float longTP = na
var float shortTP = na

// === ENTRY LOGIC WITH LABELS & LINES ===
if bullish_signal and close < emaLower and close < emaUpper
    float labelY = low * 0.98
    label.new(bar_index, labelY, text="▲", style=label.style_label_up, size=size.tiny, color=color.rgb(4, 77, 211), textcolor=color.white)
    line.new(bar_index, labelY, bar_index, low, color=color.rgb(4, 77, 211), width=1)
    strategy.entry("Long", strategy.long)
    inTrade := true
    isLong := true
    isShort := false
    longTP := close + atr * atrMultiplier  // fixed TP at entry
    alert("Long Entry Signal", alert.freq_once_per_bar_close)

if bearish_signal and close > emaUpper and close > emaLower
    float labelY = high * 1.02
    label.new(bar_index, labelY, text="▼", style=label.style_label_down, size=size.tiny, color=color.rgb(255, 186, 82), textcolor=color.white)
    line.new(bar_index, labelY, bar_index, high, color=color.rgb(255, 186, 82), width=1)
    strategy.entry("Short", strategy.short)
    inTrade := true
    isShort := true
    isLong := false
    shortTP := close - atr * atrMultiplier  // fixed TP at entry
    alert("Short Entry Signal", alert.freq_once_per_bar_close)

// === EXIT LOGIC: ATR-BASED TP ===
if inTrade and isLong and close >= longTP
    strategy.close("Long")
    inTrade := false
    isLong := false
    longTP := na
    label.new(bar_index, high * 1.01, text="✔️", style=label.style_label_down, color=color.rgb(64, 251, 142), textcolor=color.white, size=size.tiny)
    line.new(bar_index, high * 1.02, bar_index, low * 0.98, color=color.rgb(64, 251, 142), width=1, style=line.style_dotted)
    alert("Long Exit Hit (TP)", alert.freq_once_per_bar_close)

if inTrade and isShort and close <= shortTP
    strategy.close("Short")
    inTrade := false
    isShort := false
    shortTP := na
    label.new(bar_index, low * 0.99, text="✔️", style=label.style_label_up, color=color.rgb(64, 251, 142), textcolor=color.white, size=size.tiny)
    line.new(bar_index, high * 1.02, bar_index, low * 0.98, color=color.rgb(64, 251, 142), width=1, style=line.style_dotted)
    alert("Short Exit Hit (TP)", alert.freq_once_per_bar_close)
````
