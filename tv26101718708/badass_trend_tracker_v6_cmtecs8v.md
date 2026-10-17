# Badass Trend Tracker v6

- url: https://www.tradingview.com/script/CMTecS8v-Badass-Trend-Tracker-v6/
- type: indicator
- pine_id: PUB;69b5126e242d41678e0b561b22daf6df
- version: 1.0

## Description

Simple trend indicator up or down, as is. Can play with your settings.

## Source Code

````pine
//@version=6
indicator("Badass Trend Tracker v6", overlay=true, timeframe="", timeframe_gaps=true)

// --- Inputs ---
src         = input.source(close, title="Source")
ma_len      = input.int(21, title="Trend Length", minval=1)
atr_len     = input.int(14, title="Volatility Length")
atr_mult    = input.float(1.5, title="Band Sensitivity")

// --- Styling Toggles ---
show_bg      = input.bool(true, title="Enable Background Glow")
show_ribbon  = input.bool(true, title="Enable Neon Trend Ribbon")
show_bands   = input.bool(true, title="Enable Volatility Bands")
show_signals = input.bool(true, title="Enable Breakout Flashes")

// --- Calculations ---
ema_fast    = ta.ema(src, ma_len)
ema_slow    = ta.ema(ema_fast, 5)
atr         = ta.atr(atr_len)

upper_band  = ema_fast + (atr * atr_mult)
lower_band  = ema_fast - (atr * atr_mult)

// --- Trend Logic ---
is_bullish  = ema_fast > ema_slow and close > ema_fast
is_bearish  = ema_fast < ema_slow and close < ema_fast

// --- Color Palette (Cyberpunk Neon) ---
color_bull     = color.new(#00ffcc, 0)      // Neon Cyan
color_bear     = color.new(#ff0055, 0)      // Neon Pink/Red
color_neutral  = color.new(#9e9e9e, 50)     // Slate Gray

// Dynamic ribbon colors based on trend
ribbon_color_fast = is_bullish ? color_bull : is_bearish ? color_bear : color_neutral
ribbon_color_slow = is_bullish ? color.new(color_bull, 40) : is_bearish ? color.new(color_bear, 40) : color_neutral
fill_color_ribbon = is_bullish ? color.new(color_bull, 85) : is_bearish ? color.new(color_bear, 85) : color.new(color_neutral, 90)

// --- Visual Rendering ---

// 1. Neon Trend Ribbon
plot_fast = plot(show_ribbon ? ema_fast : na, "Ribbon Fast", color=ribbon_color_fast, linewidth=2)
plot_slow = plot(show_ribbon ? ema_slow : na, "Ribbon Slow", color=ribbon_color_slow, linewidth=1)
fill(plot_fast, plot_slow, color=fill_color_ribbon, title="Ribbon Fill")

// 2. Volatility Bands (Fixed for Pine Script v6)
plot_up = plot(show_bands ? upper_band : na, "Upper Band", color=color.new(#8a2be2, 60), style=plot.style_line, linestyle=plot.linestyle_dashed) 
plot_dn = plot(show_bands ? lower_band : na, "Lower Band", color=color.new(#8a2be2, 60), style=plot.style_line, linestyle=plot.linestyle_dashed)
fill(plot_up, plot_dn, color=color.new(#8a2be2, 95), title="Band Fill")

// 3. Background Glow
bg_color = show_bg ? (is_bullish ? color.new(color_bull, 92) : is_bearish ? color.new(color_bear, 92) : na) : na
bgcolor(bg_color, title="Trend Background")

// 4. Breakout Flashes (Signals)
bull_flash = is_bullish and ta.crossover(close, upper_band)
bear_flash = is_bearish and ta.crossunder(close, lower_band)

plotshape(show_signals and bull_flash ? low : na, title="Bullish Flash", style=shape.triangleup, location=location.belowbar, color=color_bull, size=size.normal)
plotshape(show_signals and bear_flash ? high : na, title="Bearish Flash", style=shape.triangledown, location=location.abovebar, color=color_bear, size=size.normal)
````
