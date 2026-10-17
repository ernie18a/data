# SMA & EMA [FIBO]

- url: https://www.tradingview.com/script/s2dSJe0v/
- type: indicator
- pine_id: PUB;7c1b0ba788b947988b77787929f666b0
- version: 1.0

## Description

This indicator provides a comprehensive suite of Simple Moving Averages (SMA) and Exponential Moving Averages (EMA) in a single script, designed for both short-term momentum and long-term trend analysis.

The periods are heavily based on the Fibonacci sequence, along with standard psychological levels (100 and 200), giving you a complete map of dynamic support and resistance zones.

Key Features:

Short-Term SMAs: 5, 8, 13

Medium & Long-Term EMAs: 21, 34, 55, 89, 100, 144, 200, 233, 377

Zero Interface Clutter: The "Inputs" tab is kept completely empty for a distraction-free experience. You can toggle the visibility of each moving average, change colors, and adjust line thickness directly from TradingView's native "Style" tab.

Dark Mode Ready: Default colors are specifically chosen to be vibrant and distinct on dark-themed charts.

How to Use:

Track the short-term SMAs (5, 8, 13) to spot immediate momentum shifts and fast crossovers.

Use the mid-to-long-term EMAs (like 55, 100, 200) as dynamic support and resistance levels or to determine the macro trend direction.

Since all averages are bundled in one script, you save indicator slots. Simply hide the ones you don't need via the Style tab to keep your chart clean.

## Source Code

````pine
//@version=5
indicator("SMA & EMA [FIBO]", overlay=true)

// --- HESAPLAMALAR ---
sma5  = ta.sma(close, 5)
sma8  = ta.sma(close, 8)
sma13 = ta.sma(close, 13)

ema21  = ta.ema(close, 21)
ema34  = ta.ema(close, 34)
ema55  = ta.ema(close, 55)
ema89  = ta.ema(close, 89)
ema100 = ta.ema(close, 100)
ema144 = ta.ema(close, 144)
ema200 = ta.ema(close, 200)
ema233 = ta.ema(close, 233)
ema377 = ta.ema(close, 377)

// --- ÇİZİMLER (Stil Sekmesinden Yönetilir) ---
plot(sma5,  color=#FFFFFF, title="SMA 5")
plot(sma8,  color=#FFEB3B, title="SMA 8")
plot(sma13, color=#FF9800, title="SMA 13")

plot(ema21,  color=#FF5252, title="EMA 21")
plot(ema34,  color=#FF4081, title="EMA 34")
plot(ema55,  color=#E040FB, title="EMA 55")
plot(ema89,  color=#448AFF, title="EMA 89")
plot(ema100, color=#00BCD4, title="EMA 100")
plot(ema144, color=#1DE9B6, title="EMA 144")
plot(ema200, color=#00E676, title="EMA 200", linewidth=2)
plot(ema233, color=#CDDC39, title="EMA 233")
plot(ema377, color=#B0BEC5, title="EMA 377", linewidth=2)
````
