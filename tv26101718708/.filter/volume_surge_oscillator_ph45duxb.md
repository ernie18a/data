# Volume Surge Oscillator

- url: https://www.tradingview.com/script/PH45duxb-Volume-Surge-Oscillator/
- type: indicator
- pine_id: PUB;8b98fc0ca2d84bca92cd52c857ee75ad
- version: 2.0

## Description

Volume Surge Oscillator (VSO) is a momentum oscillator inspired by the Nova Volume Trading System.

It measures the percentage deviation of price from a fast EMA, normalizes it by recent volatility, and then dynamically boosts or dampens the signal based on relative volume strength.

This oscillator highlights high-conviction moves by amplifying signals during above-average volume and reducing noise during low volume periods. Ideal for spotting momentum shifts, breakouts, and divergences.

## Source Code

````pine
//@version=6
indicator('Volume Surge Oscillator', overlay = false, timeframe = '')

source              = input.source(close, 'Source')
length              = input.int(8,  'Price EMA Length', minval = 1)
volatility_period   = input.int(20, 'Volatility Length', minval = 1)
volume_lookback     = input.int(20, 'Volume Avg Lookback', minval = 5)
volume_strength     = input.float(0.35, 'Max Volume Influence', minval = 0, maxval = 0.99, step = 0.05)

// Colors
color_positive = input.color(#00897b, 'Positive Color')
color_negative = input.color(#f44336, 'Negative Color')

// ── Calculations ─────────────────────────────────────

// Price deviation
price_ema          = ta.ema(source, length)
raw_price_diff_pct = 100 * (source - price_ema) / price_ema

// Volatility normalization
price_stdev        = ta.stdev(source, volatility_period)
vol_adjusted       = raw_price_diff_pct / (price_stdev == 0 ? 1 : price_stdev)

// Volume adjustment
vol_sma            = ta.sma(volume, volume_lookback)
vol_ratio          = volume / math.max(vol_sma, 1)

// Stronger volume boost when above average, dampening when below
vol_multiplier     = 1 + volume_strength * math.pow(vol_ratio, 1.5) * math.sign(vol_ratio - 1)

volume_weighted    = vol_adjusted * vol_multiplier

// Final oscillator
oscillator         = volume_weighted

signal_line        = ta.ema(oscillator, 8)

// ── Plotting ─────────────────────────────────────────
plot(oscillator,  title = 'Volume Surge', color = oscillator >= 0 ? color_positive : color_negative, style = plot.style_histogram, linewidth = 3)
plot(signal_line, title = 'Signal Line',   color = color.orange, linewidth = 2)

//Zero line
hline(0, "Zero", color = color.new(color.gray, 50), linestyle = hline.style_dotted)
````
