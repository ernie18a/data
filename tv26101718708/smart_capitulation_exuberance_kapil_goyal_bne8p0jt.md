# Smart Capitulation & Exuberance - KAPIL GOYAL

- url: https://www.tradingview.com/script/BNe8P0Jt-Smart-Capitulation-Exuberance-KAPIL-GOYAL/
- type: indicator
- pine_id: PUB;3166746ad96545f7891d80de12b9c28e
- version: 1.0

## Description

The Smart Capitulation & Exuberance indicator is a multi-factor algorithmic tool designed to keep you out of emotional market extremes. By combining price action, volume anomalies, and price velocity, it pinpoints true panic selling and blow-off tops, moving beyond simple oscillators to identify high-probability reversal zones.

## Source Code

````pine
//@version=5
indicator("Smart Capitulation & Exuberance", overlay=true)

// 1. Settings
length = input.int(20, "Lookback Period (BB & High/Low)")
vol_mult = input.float(1.5, "Volume Multiplier")
rsi_length = input.int(14, "RSI Length")

// 2. The Normal Range (Bollinger Bands & High/Low)
[middle_band, upper_band, lower_band] = ta.bb(close, length, 2.0)
highest_high = ta.highest(high, length)
lowest_low = ta.lowest(low, length)

// 3. Momentum & Volume Checks
avg_vol = ta.sma(volume, length)
is_high_volume = volume > (avg_vol * vol_mult)
rsi_value = ta.rsi(close, rsi_length)

// 4. Smart Signals (Piercing + Volume + RSI + Structural Extreme)
// CAP: Pierces floor + Huge Crowd + Oversold + Hits 20d Low
is_at_low = (low == lowest_low)
capitulation = low < lower_band and is_high_volume and rsi_value < 35 and is_at_low

// TOP: Pierces ceiling + Huge Crowd + Overbought + Hits 20d High
is_at_high = (high == highest_high)
exuberance   = high > upper_band and is_high_volume and rsi_value > 65 and is_at_high

// 5. Drawing the Labels
if capitulation
    label.new(bar_index, low, text="CAP@" + str.tostring(math.round(close)), style=label.style_none, textcolor=color.black, yloc=yloc.belowbar)

if exuberance
    label.new(bar_index, high, text="TOP@" + str.tostring(math.round(close)), style=label.style_none, textcolor=color.black, yloc=yloc.abovebar)
````
