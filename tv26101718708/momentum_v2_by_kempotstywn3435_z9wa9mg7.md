# Momentum v2 By KempotStywn3435

- url: https://www.tradingview.com/script/Z9WA9mG7/
- type: indicator
- pine_id: PUB;6068f6da1c4843adb94a2ca5ed1df151
- version: 1.0

## Description

Momentum v2 By KempotStywn3435 is a TradingView indicator designed to detect strong momentum candles based on candle body size. The indicator compares the current candle body with the bodies of the previous three candles.

This script displays a green or red triangle when the latest candle has a significantly larger body than the previous candles. Its main purpose is to help traders identify potential strong momentum in the market.

How the Indicator Works

The indicator calculates the pure candle body size, which is the difference between the open and close prices, without including the candle wick or shadow.

The script calculates:

The current candle body
The previous 1st candle body
The previous 2nd candle body
The previous 3rd candle body

After that, the indicator finds the largest body from the previous three candles. The current candle body is then compared with that largest previous body.

Signal Conditions

A signal will only appear when two main conditions are met:

1. The current candle body must be larger than the minimum body size

The default value is:

min_body_size = 5.5

This means the current candle body must be greater than 5.5 points/pips, depending on the trading instrument.

2. The current candle body must be larger than the largest previous body multiplied by the size multiplier

The default value is:

size_multiplier = 2.0

This means the current candle body must be more than 2 times larger than the biggest body among the previous three candles.

Simple example:

If the largest body from the previous three candles is 10 points, then the current candle body must be greater than:

10 x 2.0 = 20 points

If the current candle body is greater than 20 points and also passes the minimum body size requirement, a momentum signal will appear.

Signal Meaning

Green triangle below the candle

Appears when a strong bullish momentum candle is detected.

This means:

close > open

This signal indicates strong buying pressure.

Red triangle above the candle

Appears when a strong bearish momentum candle is detected.

This means:

close < open

This signal indicates strong selling pressure.

Main Purpose of the Indicator

This indicator can be used to:

Detect breakout or impulse candles.
Identify the beginning of strong momentum.
Read buyer and seller pressure.
Act as an additional filter for manual entries.
Avoid entries when the market is weak or moving sideways.
Important Note

This indicator is not a fully automatic trading system. It is a visual tool that helps mark unusual momentum candles. The signal should be combined with other analysis methods such as market structure, support and resistance, trend direction, supply and demand, FVG, Fibonacci, or proper risk management.

Conclusion

Momentum v2 By KempotStywn3435 is a simple indicator for reading candle strength based on body size. When the current candle is significantly larger than the previous three candles, the indicator displays a triangle based on the candle direction.

A green triangle indicates strong bullish momentum, while a red triangle indicates strong bearish momentum.

## Source Code

````pine
//@version=5
indicator("Momentum v2 By KempotStywn3435", overlay=true)

// --- Menu Pengaturan ---
min_body_size = input.float(5.5, title="Minimal Panjang Body", step=0.5)
size_multiplier = input.float(2.0, title="Pengali Ukuran", step=0.1)

// --- Perhitungan Ukuran Body Murni ---
body_current = math.abs(close - open)       // Candle ke-4 (saat ini)
body_1 = math.abs(close[1] - open[1])       // Candle 1 sebelumnya
body_2 = math.abs(close[2] - open[2])       // Candle 2 sebelumnya
body_3 = math.abs(close[3] - open[3])       // Candle 3 sebelumnya

// LOGIKA UTAMA: Mengambil HANYA yang terpanjang dari 3 candle awal
highest_prev_body = math.max(body_1, body_2, body_3)

// --- Syarat Kondisi ---
// 1. Body candle saat ini harus melewati batas minimal pips/poin
is_valid_size = body_current > min_body_size

// 2. Body saat ini harus lebih besar dari (Body Terpanjang x Pengali)
is_breakout = body_current > (highest_prev_body * size_multiplier)

// Menentukan Arah
is_bullish = close > open
is_bearish = close < open

// Eksekusi Syarat
trigger_bull = is_valid_size and is_breakout and is_bullish
trigger_bear = is_valid_size and is_breakout and is_bearish

// --- Menampilkan Segitiga ---
// Segitiga hijau menghadap atas, di bawah candle
plotshape(trigger_bull, title="Buy Triangle", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.normal)

// Segitiga merah menghadap bawah, di atas candle
plotshape(trigger_bear, title="Sell Triangle", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.normal)
````
