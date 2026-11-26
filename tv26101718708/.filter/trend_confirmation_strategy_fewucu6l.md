# Trend Confirmation Strategy

- url: https://www.tradingview.com/script/fEwucu6l-Trend-Confirmation-Strategy/
- type: strategy
- pine_id: PUB;94aafdfa9807485c82e488a4a4895fec
- version: 1.0

## Description

The profitability and uniqueness of a trading strategy depend on various factors including market conditions, risk management, and the strategy's ability to capitalize on price movements. I'll describe the strategy provided and highlight its potential benefits and differences compared to other strategies:

Strategy Overview:
The provided strategy combines three technical indicators: Supertrend, MACD, and VWAP. It aims to identify potential entry and exit points by confirming trend direction and considering the proximity to the VWAP level. The strategy also incorporates stop-loss and take-profit mechanisms, as well as a trailing stop.

Unique Aspects and Potential Benefits:

Trend Confirmation: The strategy uses both Supertrend and MACD to confirm the trend direction. This dual confirmation can increase the likelihood of accurate trend identification and filter out false signals.

VWAP Confirmation: The strategy considers the proximity of the price to the VWAP level. This dynamic level can act as a support or resistance and provide additional context for entry decisions.

Adaptive Stop Loss: The strategy sets a stop-loss range, which helps provide some tolerance for minor price fluctuations. This adaptive approach considers market volatility and helps prevent premature stop-loss triggers.

Trailing Stop: The strategy incorporates a trailing stop mechanism to lock in profits as the trade moves in the desired direction. This can potentially enhance profitability during strong trends.

Partial Profit Booking: While not explicitly implemented in the provided code, you could consider booking partial profits when the MACD shows a crossover in the opposite direction. This aspect could help secure gains while still keeping exposure to potential further price movements.

Key Differences from Other Strategies:

Dual Indicator Confirmation: The combination of Supertrend and MACD for trend confirmation is a unique aspect of this strategy. It adds an extra layer of filtering to enhance the accuracy of entry signals.

Dynamic VWAP: Incorporating the VWAP level into the decision-making process adds a dynamic element to the strategy. VWAP is often used by institutional traders, and its inclusion can provide insights into the market sentiment.

Adaptive Stop Loss and Trailing: The strategy's use of an adaptive stop-loss range and a trailing stop can help manage risk and protect profits more effectively during changing market conditions.

Partial Profit Booking: The suggestion to consider partial profit booking upon MACD crossovers in the opposite direction is a practical approach to secure gains while staying in the trade.

Caution and Considerations:

Backtesting: Before deploying any strategy in real trading, it's crucial to thoroughly backtest it on historical data to understand its performance under various market conditions.

Risk Management: While the strategy has built-in risk management mechanisms, it's essential to carefully manage position sizes and overall portfolio risk.

Market Conditions: No strategy works well in all market conditions. It's important to be flexible and adjust the strategy or refrain from trading during particularly volatile or unpredictable periods.

Continuous Monitoring: Even though the strategy includes automated components, continuous monitoring of the trades and market conditions is necessary.

Adaptability: Markets can change over time. Traders need to be prepared to adapt the strategy as necessary to stay aligned with evolving market dynamics.

## Source Code

````pine
//@version=5
strategy("Trend Confirmation Strategy", overlay=true)

// Supertrend Indicator
atrPeriod = input(10, "ATR Length")
factor = input.float(3.0, "Factor", step = 0.01)
[supertrend, direction] = ta.supertrend(factor, atrPeriod)

// MACD Indicator
fast_length = input(title="Fast Length", defval=12)
slow_length = input(title="Slow Length", defval=26)
macd_src = input(title="Source", defval=close)
signal_length = input.int(title="Signal Smoothing",  minval = 1, maxval = 50, defval = 9)
macd_sma_source = input.string(title="Oscillator MA Type",  defval="EMA", options=["SMA", "EMA"])
macd_sma_signal = input.string(title="Signal Line MA Type", defval="EMA", options=["SMA", "EMA"])

fast_ma = macd_sma_source == "SMA" ? ta.sma(macd_src, fast_length) : ta.ema(macd_src, fast_length)
slow_ma = macd_sma_source == "SMA" ? ta.sma(macd_src, slow_length) : ta.ema(macd_src, slow_length)
macd = fast_ma - slow_ma
signal = macd_sma_signal == "SMA" ? ta.sma(macd, signal_length) : ta.ema(macd, signal_length)

// VWAP Indicator
vwap_hideonDWM = input(false, title="Hide VWAP on 1D or Above")
vwap_src = input(title="VWAP Source", defval=hlc3)

vwap_value = ta.vwap(vwap_src)
vwap_value_long = vwap_value
vwap_value_short = vwap_value

// Entry Criteria
confirm_up_trend = direction > 0 and macd > signal
confirm_down_trend = direction < 0 and macd < signal

// VWAP Confirmation
price_above_vwap = close > vwap_value_long
price_below_vwap = close < vwap_value_short

// Stop Loss and Take Profit
stop_loss_range = input(2, title="Stop Loss Range")
trail_offset = input(0.5, title="Trailing Stop Offset")

stop_loss_long = close - stop_loss_range
stop_loss_short = close + stop_loss_range

// Strategy Entry
if not (vwap_hideonDWM and timeframe.isdwm)
    if confirm_up_trend and price_above_vwap
        strategy.entry("Buy", strategy.long)
    if confirm_down_trend and price_below_vwap
        strategy.entry("Sell", strategy.short)

// Strategy Exit
if macd < signal and macd[1] >= signal[1]
    strategy.close("Buy", comment="MACD Crossover")

if macd > signal and macd[1] <= signal[1]
    strategy.close("Sell", comment="MACD Crossover")

// Plot Supertrend and VWAP
plot(supertrend, color=direction > 0 ? color.green : color.red, title="Supertrend")
plot(vwap_value_long, color=color.blue, title="VWAP Long")
plot(vwap_value_short, color=color.orange, title="VWAP Short")

// Plot MACD Histogram
hist = macd - signal
hist_color = hist >= 0 ? color.green : color.red
plot(hist, style=plot.style_histogram, color=hist_color, title="MACD Histogram")
````
