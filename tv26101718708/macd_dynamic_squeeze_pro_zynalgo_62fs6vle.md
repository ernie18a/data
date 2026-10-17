# MACD Dynamic Squeeze Pro [ZynAlgo]

- url: https://www.tradingview.com/script/62Fs6vLE-MACD-Dynamic-Squeeze-Pro-ZynAlgo/
- type: indicator
- pine_id: PUB;80e875f994a54424b64b3e2a07909245
- version: 1.0

## Description

[b]1. Technical Overview[/b]
ZynAlgo MACD Dynamic Squeeze Pro [ZynAlgo] is a momentum-context indicator built from the traditional MACD concept. Instead of trying to pick tops and bottoms against the trend, it focuses on trend-following shakeouts, energy compression, and breakout confirmation after a squeeze phase.
[image]https://www.tradingview.com/x/Pe73dwm7/[/image]

[b]2. Chart Reading & UI Guide[/b]
[b]ZynAlgo Ribbon[/b]
[list]
[*]The area between the MACD line and Signal line is filled with Green/Purple ribbon colors.
[*]The ribbon helps traders quickly see which side currently has momentum control.
[*]Use the ribbon as context for your own trading approach, not as a standalone entry trigger.
[/list]
[image]https://www.tradingview.com/x/GU9mxdOR/[/image]
[b]4-State Histogram[/b]
[list]
[*]Neon Green highlights bullish acceleration.
[*]Neon Purple highlights bearish acceleration.
[*]Faded colors warn that momentum is losing strength or price may be stagnating.
[/list]
[image]https://www.tradingview.com/x/ZlqPqQH5/[/image]
[b]Diamond Marker on Main Chart[/b]
[list]
[*]The breakout context marker is plotted directly on the main price chart.
[*]This reduces the need to constantly switch attention between the oscillator pane and price candles.
[*]Treat the marker as a context alert that should be confirmed with your own entry method, risk plan, and market structure.
[/list]
[image]https://www.tradingview.com/x/OD3mDBt6/[/image]

[b]3. Zyn Explosion Logic[/b]
The Green/Purple diamond markers appear only when the indicator detects several conditions together:
[list]
[*][b]Trend Filter:[/b] The MACD and Signal lines must both be above the Zero line for bullish trend context, or both below the Zero line for bearish trend context.
[*][b]Squeeze Phase:[/b] The histogram compresses, showing that the market is consolidating or shaking out traders.
[*][b]Explosion Phase:[/b] After the squeeze, MACD crosses the Signal line with enough timing alignment to suggest momentum expansion.
[/list]
This is a context/analysis tool, not a signal generator. The marker identifies a possible momentum continuation area, but it does not execute trades or guarantee direction.

[b]4. Settings Explanation[/b]
[b]Momentum Average Length[/b]
[list]
[*]Controls the period used to calculate the average volatility of the histogram.
[*]This average becomes the baseline for detecting whether current momentum is compressed.
[/list]
[b]Squeeze Compression Ratio[/b]
[list]
[*]Controls how tightly the histogram must compress before the market is considered to be in a squeeze phase.
[*]For example, 0.5 means the current histogram column must compress to less than 50% of the average.
[*]Lower values reduce marker frequency and make the squeeze requirement stricter.
[/list]
[b]Squeeze Valid Lookback[/b]
[list]
[*]Defines how many bars after the squeeze phase the MACD cross can still qualify.
[*]This helps reject late or off-beat crossover events.
[/list]

[b]5. Recommended Presets[/b]
[b]Gold Breakout - XAUUSD 5m/15m[/b]
[list]
[*]Squeeze Average Length: 20
[*]Squeeze Compression Ratio: 0.4
[*]Valid Lookback: 3
[*]Useful when gold creates short-term shakeouts before starting a stronger trend move.
[/list]
[b]Crypto Trend Following - BTC/ETH 15m/1H[/b]
[list]
[*]Squeeze Average Length: 30
[*]Squeeze Compression Ratio: 0.5
[*]Valid Lookback: 5
[*]Useful when crypto spends longer periods in sideways consolidation before momentum expansion.
[/list]

[b]6. Best Practices & Limitations[/b]
[list]
[*]Use this tool as momentum and squeeze context for your own framework.
[*]Confirm any trade idea with price structure, session context, volatility, and risk planning.
[*]A diamond marker is not an automatic buy or sell instruction.
[*]This tool does not predict price movement.
[*]You alone are responsible for your trading decisions.
[*]No tool eliminates risk or guarantees results.
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZynAlgo

//@version=6
indicator('MACD Dynamic Squeeze Pro [ZynAlgo]', shorttitle = 'MACD Squeeze [ZynAlgo]', overlay = false)

// === INPUT GROUPS ============================================================
GRP_MACD = 'MACD Settings'
GRP_SQZ = 'Squeeze & Explosion Logic'
GRP_UI = 'ZynAlgo UI & Colors'

// MACD Settings
fast_len = input.int(12, 'Fast Length', group = GRP_MACD)
slow_len = input.int(26, 'Slow Length', group = GRP_MACD)
sig_len = input.int(9, 'Signal Length', group = GRP_MACD)

// Squeeze Combo Settings
sqz_len = input.int(20, 'Momentum Average Length', group = GRP_SQZ, tooltip = 'Lookback length for the average histogram momentum used as the compression baseline.')
sqz_mult = input.float(0.5, 'Squeeze Compression Ratio', step = 0.1, maxval = 1.0, group = GRP_SQZ, tooltip = 'Compression ratio. 0.5 means the histogram must fall below 50% of its average to qualify as squeezed.')
sqz_lookback = input.int(3, 'Squeeze Valid Lookback (Bars)', minval = 1, group = GRP_SQZ, tooltip = 'Maximum bars allowed between the completed squeeze and the explosion trigger.')

// UI Settings
col_macd = input.color(color.white, 'MACD Line', group = GRP_UI)
col_sig = input.color(color.new(color.yellow, 0), 'Signal Line', group = GRP_UI)

c_bull = color.rgb(57, 255, 20) // Neon Green
c_bear = color.rgb(191, 0, 255) // Neon Purple

// === CORE MACD LOGIC =========================================================
fast_ma = ta.ema(close, fast_len)
slow_ma = ta.ema(close, slow_len)
macd = fast_ma - slow_ma
signal = ta.sma(macd, sig_len)
hist = macd - signal

// === HISTOGRAM 4-COLOR LOGIC (ZYNALGO THEME) =================================
hist_grow_above = hist > 0 and hist > hist[1]
hist_fall_above = hist > 0 and hist < hist[1]
hist_grow_below = hist < 0 and hist < hist[1]
hist_fall_below = hist < 0 and hist > hist[1]

c_grow_above = c_bull
c_fall_above = color.new(c_bull, 60) // Faded Green
c_grow_below = c_bear
c_fall_below = color.new(c_bear, 60) // Faded Purple

hist_color = hist_grow_above ? c_grow_above : hist_fall_above ? c_fall_above : hist_grow_below ? c_grow_below : c_fall_below

// === PLOTTING MACD PANE ======================================================
plot(hist, 'Histogram', color = hist_color, style = plot.style_columns, linewidth = 2)
p_macd = plot(macd, 'MACD Line', color = col_macd, linewidth = 2)
p_sig = plot(signal, 'Signal Line', color = col_sig, linewidth = 1)

fill(p_macd, p_sig, color = macd > signal ? color.new(c_bull, 85) : color.new(c_bear, 85), title = 'Momentum Ribbon')

// Plot normal crossover dots (faded) so the user can see the consolidation/struggle
plot(ta.crossover(macd, signal) ? macd : na, 'Cross Up', style = plot.style_circles, linewidth = 2, color = color.new(c_bull, 50))
plot(ta.crossunder(macd, signal) ? macd : na, 'Cross Down', style = plot.style_circles, linewidth = 2, color = color.new(c_bear, 50))
hline(0, 'Zero Line', linestyle = hline.style_dashed, color = color.new(color.white, 50))

// === COMBO LOGIC: SQUEEZE + ZERO-LINE REJECTION (ZYN EXPLOSION) ==============
// Step 1: Calculate the average size of the Histogram (Average Volatility)
hist_abs = math.abs(hist)
hist_avg = ta.sma(hist_abs, sqz_len)

// Step 2: Identify Squeeze Phase
// If the Histogram falls below the average * squeeze ratio -> Tight accumulation
is_squeezed = hist_abs < hist_avg * sqz_mult

// Step 3: Trend Filter (Must be in a clear trend above/below the Zero Line)
bull_trend = macd > 0 and signal > 0
bear_trend = macd < 0 and signal < 0

// Check if there was a Squeeze phase within the last N bars
was_squeezed = ta.barssince(is_squeezed) <= sqz_lookback

// Step 4: Explosion Trigger
bull_explosion = bull_trend and ta.crossover(macd, signal) and was_squeezed
bear_explosion = bear_trend and ta.crossunder(macd, signal) and was_squeezed

// === PLOTTING EXPLOSION ON MAIN CHART (DIAMOND) ==============================
plotshape(bull_explosion ? low : na, 'Bullish Explosion', style = shape.diamond, location = location.belowbar, color = c_bull, size = size.small, force_overlay = true)
plotshape(bear_explosion ? high : na, 'Bearish Explosion', style = shape.diamond, location = location.abovebar, color = c_bear, size = size.small, force_overlay = true)
````
