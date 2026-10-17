# Trend Bias Guide MA

- url: https://www.tradingview.com/script/LCNoCk41/
- type: indicator
- pine_id: PUB;9e19e635b10741238e57e688166dce24
- version: 1.0

## Description

Trend Bias Guide MA

OVERVIEW

Trend Bias Guide MA is a smoothed reference line that shows which side (bullish or bearish) has been dominating recent price action, and helps spot early signs of trend exhaustion through divergence between price and candle-body pressure.

Unlike a standard moving average, this line is not derived from price itself. It is derived from the net directional pressure of individual candles over a lookback window, then projected onto the chart at a visual offset from price using ATR, so it never overlaps the candles.

WHAT IT IS BUILT FROM

For every candle in the lookback window (default: 50 candles), the script measures (close − open). This value is positive for a bullish candle and negative for a bearish candle, and its magnitude reflects the size of that candle's body.

These values are summed across the whole lookback window into a single number, referred to here as the net bias:

net bias = Σ (close − open) over the last N candles

This sum captures two distinct effects at once:
1. Count imbalance: whether there were more bullish or more bearish candles in the window.
2. Size imbalance: whether the bullish or bearish candles had larger bodies on average.

Both effects move price in the same underlying way, and summing (close − open) candle by candle combines them automatically, without needing to calculate them separately. If the net bias is positive, bullish pressure has dominated the window; if negative, bearish pressure has dominated.

HOW THE LINE IS DRAWN

- If the net bias is negative (bearish), the line is plotted above price, at a distance of (ATR × multiplier) above the current high.
- If the net bias is positive (bullish), the line is plotted below price, at a distance of (ATR × multiplier) below the current low.
- ATR length and multiplier are both adjustable inputs (defaults: ATR length 14, multiplier 1.0), and control how far the line sits from price.
- The raw level is then smoothed with a simple moving average (default length: 10) to reduce short-term noise and produce a cleaner, more continuous line instead of a jagged one.
- The line changes color to match its current bias: green when below price (bullish), red when above price (bearish).

INPUTS

- Lookback Length (default 50): number of candles used to calculate the net bias.
- ATR Length (default 14): period used for the ATR calculation that sets the offset distance.
- ATR Multiplier (default 1.0): scales the offset distance from price.
- Smoothing Length (default 10): period of the moving average applied to the final line.

HOW TO INTERPRET IT

- Green line below price: bullish pressure has dominated over the lookback window.
- Red line above price: bearish pressure has dominated over the lookback window.
- This is a trailing, lookback-based measure. Like any indicator built on a moving window, it reacts with a delay relative to the current candle — it will not flip instantly at the exact start of a new trend, and generally needs enough new candles in the new direction to outweigh the older ones still inside the window.

HOW TO USE IT

This indicator is designed as a contextual reference, not as a standalone entry or exit signal. Two practical uses:

1. Trend context: at a glance, see whether recent price action has been dominated by bullish or bearish candles, without needing to eyeball candle sizes manually.

2. Divergence / exhaustion warning: watch for cases where price is trading above a rising average (e.g., an EMA, not included in this script) while this line is still red (or below a falling average while the line is still green). This mismatch between price direction and underlying candle pressure can flag weakening trend conviction. In backtesting on XAUUSD (17 years of hourly data), this type of divergence was associated with a meaningfully higher chance of the trend reversing within the following 24–72 hours compared to the general baseline, with the effect strongest in the 24-hour window and gradually fading over longer horizons.

LIMITATIONS

- This is a descriptive/contextual tool, not a predictive trading signal on its own. It shows what has already happened over the lookback window, and any forward-looking use (such as the divergence behavior described above) carries no guarantee of repeating in the same way in the future or on other symbols/timeframes.
- Being lookback-based, the line inherently lags price, in the same way any moving average or rolling calculation does.
- It does not include stop-loss, take-profit, or position-sizing logic of any kind. It is a visual reference only.
- Backtested divergence statistics referenced above were derived from historical XAUUSD data and should not be assumed to hold with the same magnitude across all instruments, timeframes, or market regimes. Users should validate behavior on their own instrument and timeframe before relying on it.

## Source Code

````pine
//@version=6
indicator("Trend Bias Guide MA", overlay=true)

length      = input.int(50, title="Lookback Length", minval=1)
atrLen      = input.int(14, title="ATR Length", minval=1)
atrMult     = input.float(1.0, title="ATR Multiplier", minval=0.1, step=0.1)
smoothLen   = input.int(10, title="Smoothing Length", minval=1)

netMove = 0.0
for i = 0 to length - 1
    netMove += (close[i] - open[i])

bias = netMove

atrVal = ta.atr(atrLen)
offset = atrVal * atrMult

rawLevel = bias < 0 ? high + offset : low - offset
maLevel  = ta.sma(rawLevel, smoothLen)

plot(maLevel, title="Trend Bias Guide MA", color = bias < 0 ? color.red : color.green, linewidth = 2, style = plot.style_line)
````
