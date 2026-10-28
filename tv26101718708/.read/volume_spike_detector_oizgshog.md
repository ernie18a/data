# Volume Spike Detector

- url: https://www.tradingview.com/script/OizgsHOg-Volume-Spike-Detector/
- type: indicator
- pine_id: PUB;ec8c9a3f6b004bf0a1664b4dedcb57e5
- version: 1.0

## Description

This is a clean and simple volume indicator designed to give traders a clearer picture of market participation at a glance.
Features:

Color-coded volume bars — Teal for bullish candles, Red for bearish candles
20-period Volume Moving Average (adjustable)
Spike Detection — highlights unusually high volume bars in Yellow (bullish spike) and Orange (bearish spike)
Triangle marker on every volume spike for quick visual identification
All settings fully customizable — MA length, spike multiplier, toggle each element on/off

How to use:

When volume spikes above 2× the MA, it signals strong institutional interest or a potential reversal/breakout
Use it alongside your existing price action or trend indicators for confirmation
Works on any timeframe and any instrument — stocks, forex, crypto, indices

Settings:

MA Length — default 20, adjust to your timeframe
Spike Multiplier — default 2.0, lower it to catch more spikes, raise it to filter only extreme ones

© itsmtj

Free to use. Please do not republish as your own.

## Source Code

````pine
//@version=6
// © itsmtj
// Volume Spike Detector
// This source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/

indicator("Volume Spike Detector", overlay=false)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
show_vol   = input.bool(true,  "Show Volume Bars",  group="Volume")
show_ma    = input.bool(true,  "Show Volume MA",    group="Volume")
vol_ma_len = input.int(20,     "MA Length",         group="Volume", minval=1)
show_spike = input.bool(true,  "Highlight Spikes",  group="Volume")
spike_mult = input.float(2.0,  "Spike Multiplier",  group="Volume", minval=1.0, step=0.1, tooltip="Volume > X × MA is a spike")

// ─── CALCULATIONS ─────────────────────────────────────────────────────────────
vol_ma   = ta.sma(volume, vol_ma_len)
is_spike = volume > vol_ma * spike_mult
is_up    = close >= open

// ─── COLORS ───────────────────────────────────────────────────────────────────
vol_color =
  show_spike and is_spike and is_up     ? color.new(color.yellow, 0)  :
  show_spike and is_spike and not is_up ? color.new(#ff5500,      0)  :
  is_up                                 ? color.new(color.teal,  30)  :
                                          color.new(color.red,   30)

// ─── PLOTS ────────────────────────────────────────────────────────────────────
plot(show_vol ? volume : na, title="Volume",    style=plot.style_columns, color=vol_color)
plot(show_ma  ? vol_ma : na, title="Volume MA", style=plot.style_line,    color=color.new(color.orange, 0), linewidth=2)

// ─── SPIKE MARKER ─────────────────────────────────────────────────────────────
plotshape(show_spike and is_spike ? volume : na,
  title="Spike Marker", style=shape.triangleup,
  location=location.absolute, color=color.new(color.yellow, 0), size=size.tiny)
````
