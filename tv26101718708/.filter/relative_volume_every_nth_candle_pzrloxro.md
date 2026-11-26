# Relative Volume Every Nth Candle

- url: https://www.tradingview.com/script/PZRLoxRo-Relative-Volume-Every-Nth-Candle/
- type: indicator
- pine_id: PUB;3d27d8ce4d76471ea0ed803092630612
- version: 1.0

## Description

Displays relative volume (current volume vs 20-period SMA) as labeled bars every Nth candle. Green = above average volume (>1x), Red = below average (<1x).

How to use:
Add to any intraday chart (1m, 2m, 5m best)
Labels appear automatically every Nth candle above the high
Use to spot volume surges on key time intervals

*Important, auto fit price view by clicking on the right price bar, then lock it before making this indicator visible or it will not display properly!

Settings:
Show Every Nth Candle: 1=every bar, 3=every 3rd, 5=every fifth
SMA Length: Volume average period (default 20)

## Source Code

````pine
// @version=5
indicator("Relative Volume Every Nth Candle", overlay=true)

// === INPUTS ===
interval_candles = input.int(3, "Show Every Nth Candle", minval=1, tooltip="Show relative volume label every N candles (1 = every candle, 5 = every 5th candle)")
length = input.int(20, "SMA Length", minval=1, tooltip="Number of candles to calculate the average volume.")

// Calculate the volume SMA
volume_sma = ta.sma(volume, length)

// Calculate relative volume (current volume / SMA)
relative_volume = volume / volume_sma

// Determine if the current candle is the Nth candle
candle_count = bar_index % interval_candles == 0

// Plot the relative volume label every Nth candle
if candle_count
    label.new(bar_index, high, text=str.tostring(relative_volume, "#.#x"), 
              color=relative_volume > 1 ? color.green : color.red, 
              textcolor=color.white, 
              style=label.style_label_down, 
              yloc=yloc.abovebar)

// Optional: Plot volume bars at the bottom for reference
plot(volume, title="Volume", style=plot.style_histogram, color=color.blue)

// Optional: Plot the volume SMA for reference
plot(volume_sma, title="Volume SMA", color=color.yellow, linewidth=2)
````
