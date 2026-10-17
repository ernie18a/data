# Custom EMA Trio by haider

- url: https://www.tradingview.com/script/u63ClQtA-Custom-EMA-Trio-by-haider/
- type: indicator
- pine_id: PUB;fc87105308514ddb9b1e3cc1bb4daa6f
- version: 1.0

## Description

Triple Moving Average & Stochastic Trend Strategy
Overview
This custom indicator strategy is a trend-following pullback system. It uses three Moving Averages (MAs) to identify the primary market direction and relies on the Stochastic Oscillator to pinpoint optimal entry signals during market retracements.
1. Core Components
Fast Moving Average (25-period): Tracks short-term price action and immediate momentum.
Medium Moving Average (75-period): Defines the intermediate trend.
Slow Moving Average (140-period): Acts as the baseline for the major long-term trend.
Stochastic Oscillator (Default 14,3,3): Acts as the entry trigger by identifying overbought (above 80) and oversold (below 20) conditions within the established trend.
(Note: Exponential Moving Averages (EMA) are recommended for these periods as they react faster to recent price changes, but Simple Moving Averages (SMA) can also be used).EMA 25

## Source Code

````pine
//@version=5
indicator("Custom EMA Trio", shorttitle="My EMAs", overlay=true)

// ==================== الحسابات ====================
ema25 = ta.ema(close, 25)
ema75 = ta.ema(close, 75)
ema140 = ta.ema(close, 140)

// ==================== الرسم (كما طلبت) ====================
// EMA 25: لون أصفر، خط نحيف (linewidth = 1)
plot(ema25, title="EMA 25", color=color.yellow, linewidth=1)

// EMA 75: لون أزرق، سمك وسط (linewidth = 2)
plot(ema75, title="EMA 75", color=color.blue, linewidth=2)

// EMA 140: لون أبيض، سميك جداً (linewidth = 4)
plot(ema140, title="EMA 140", color=color.white, linewidth=4)

// ==================== الاستوكاستك (كخلفية ملونة على الشارت) ====================
periodK = 14
periodD = 3
smoothK = 3

stochK = ta.stoch(close, high, low, periodK)
k = ta.sma(stochK, smoothK)
d = ta.sma(k, periodD)

// تحديد إشارات الاستوكاستك
stoch_buy  = k > d and k < 20
stoch_sell = k < d and k > 80

// تلوين خلفية الشارت بناءً على الإشارات
bgcolor(stoch_buy ? color.new(color.green, 90) : stoch_sell ? color.new(color.red, 90) : na, title="Stochastic Signal Background")
````
