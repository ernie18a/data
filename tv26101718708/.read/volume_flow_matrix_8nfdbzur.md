# Volume Flow Matrix

- url: https://www.tradingview.com/script/8NFdBzUr-Volume-Flow-Matrix/
- type: indicator
- pine_id: PUB;792ce2eb9daa4e5aaea75bcff70f4760
- version: 1.0

## Description

Volume Flow Matrix is a relative volume histogram that helps identify how strong or weak current market participation is compared to recent volume activity.

The indicator measures current volume against a fixed 300-bar volume baseline. Instead of showing raw volume only, it converts volume into a relative reading. This makes it easier to see whether the current candle is trading below average volume, around normal activity, with increased participation, or at an unusually high volume level.

On historical candles, the calculation uses completed candle volume. On the live candle, the indicator uses realtime volume projection. This means the current candle’s volume is estimated based on how much time has passed in the candle. As a result, the histogram can react during the candle instead of only after the candle closes.

[b]The histogram is divided into five volume conditions:[/b]

Dry Volume shows candles with weak participation. These bars appear when relative volume is below 0.75. Dry volume can be useful for spotting quiet market phases, low-interest candles, or areas where price is moving without strong volume support.

Default Volume represents normal volume conditions. These candles do not meet the requirements for dry, directional, or extreme volume. Default volume helps separate ordinary market activity from more important volume events.

Bull Volume appears when relative volume is elevated and the candle also shows bullish pressure. For a candle to qualify as Bull Volume, relative volume must be at least 1.55, the candle must close above its open, and the close must be positioned in the upper part of the candle range. This can help highlight candles where stronger participation supports upward pressure.

Bear Volume appears when relative volume is elevated and the candle shows bearish pressure. For a candle to qualify as Bear Volume, relative volume must be at least 1.55, the candle must close below its open, and the close must be positioned in the lower part of the candle range. This can help highlight candles where stronger participation supports downward pressure.

Extreme Volume marks unusually high relative volume at or above 2.30. These candles show that volume is significantly above the recent baseline. Extreme Volume does not automatically mean bullish or bearish continuation. It should be read together with price location, candle structure, support and resistance, liquidity zones, or the broader market context.

Each candle is assigned to only one volume condition. The script checks the conditions in a fixed order so the histogram remains clean and does not stack multiple volume types on the same bar.

[b]How to use it:[/b]

Use Dry Volume to identify low-participation areas where price movement may be less reliable.

Use Bull Volume and Bear Volume to confirm whether directional candles are supported by stronger participation.

Use Extreme Volume to mark important high-activity candles that may appear near breakouts, liquidity grabs, absorption areas, reversals, or strong continuation moves.

Use Default Volume as the neutral background state between low-volume and high-volume conditions.

[i]Volume Flow Matrix does not provide trade entries or exits by itself. It is designed to support analysis by making volume behavior easier to read. The strongest use case is combining it with price action, market structure, key levels, liquidity, trend context, or any existing trading plan.[/i]

## Source Code

````pine
//@version=6
// This source code is subject to the Mozilla Public License 2.0.
// https://mozilla.org/MPL/2.0/
// Volume Flow Matrix
// Deterministic relative volume histogram.

indicator("Volume Flow Matrix", overlay=false, precision=2)

// Fixed Volume Settings
int volumeLookback = 300
bool useRealtimeProjection = true

float dryVolume = 0.75
float confirmVolume = 1.55
float extremeVolume = 2.30

// Colors
color bullColor = color.rgb(0, 220, 140)
color bearColor = color.rgb(255, 70, 90)
color neutralColor = color.rgb(120, 120, 120)
color dryColor = color.rgb(65, 65, 65)
color extremeColor = color.rgb(180, 90, 255)

// Helpers
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(value, maxValue))

// Realtime Relative Volume
int barDuration = math.max(nz(time_close - time, 1), 1)
float barProgressRaw = float(timenow - time) / float(barDuration)
float barProgress = f_clamp(barProgressRaw, 0.05, 1.0)

float projectedVolume = useRealtimeProjection and barstate.isrealtime and barstate.islast ? volume / barProgress : volume

float historicalVolumeBase = ta.sma(volume, volumeLookback)
float previousVolumeBase = ta.sma(volume[1], volumeLookback)
float volumeBase = useRealtimeProjection and barstate.isrealtime and barstate.islast ? nz(previousVolumeBase, historicalVolumeBase) : historicalVolumeBase

float relativeVolume = volumeBase > 0 ? projectedVolume / volumeBase : 0.0

// Candle Pressure
float barRange = math.max(high - low, syminfo.mintick)
float closeLocation = (close - low) / barRange

bool bullPressure = closeLocation >= 0.60 and close > open
bool bearPressure = closeLocation <= 0.40 and close < open

// Volume Priority Logic
bool isDryVolume = relativeVolume < dryVolume
bool isBullVolume = not isDryVolume and bullPressure and relativeVolume >= confirmVolume
bool isBearVolume = not isDryVolume and not isBullVolume and bearPressure and relativeVolume >= confirmVolume
bool isExtremeVolume = not isDryVolume and not isBullVolume and not isBearVolume and relativeVolume >= extremeVolume
bool isDefaultVolume = not isDryVolume and not isBullVolume and not isBearVolume and not isExtremeVolume

// Volume Plots
plot(isDryVolume ? relativeVolume : na, title="Dry Volume", style=plot.style_columns, color=color.new(dryColor, 25))
plot(isBullVolume ? relativeVolume : na, title="Bull Volume", style=plot.style_columns, color=color.new(bullColor, 10))
plot(isBearVolume ? relativeVolume : na, title="Bear Volume", style=plot.style_columns, color=color.new(bearColor, 10))
plot(isExtremeVolume ? relativeVolume : na, title="Extreme Volume", style=plot.style_columns, color=color.new(extremeColor, 0))
plot(isDefaultVolume ? relativeVolume : na, title="Default Volume", style=plot.style_columns, color=color.new(neutralColor, 25))
````
