# Adjustable Timezone Swap Highlighter

- url: https://www.tradingview.com/script/oRETa9nd-Adjustable-Timezone-Swap-Highlighter/
- type: indicator
- pine_id: PUB;da1b0a8c2dc64c4688f65019fe8081fa
- version: 1.0

## Description

[b]Swap Hour Candle Highlighter[/b]

This simple, lightweight indicator highlights candles that form during a specific "swap hour" or low-liquidity session by changing their color on your chart. It features a built-in timezone setting to ensure the highlighted window perfectly aligns with your local screen time.

[b]Why this script was created:[/b]
Especially for pattern traders, swap candles can make a market structure look better or worse than it actually is. Countless times, I found myself placing too much emphasis on a structure because of candles that weren't really showing genuine price action (PA).

I built this small script to serve as a constant visual reminder that candles created during the swap hour do not hold the same weight as candles formed during highly active, liquid trading sessions. It filters out the noise so you can focus on true market volume.

Features:
[list=1]
[*]Customizable Session: Define your specific swap hour using the HHMM-HHMM format.
[*]Flexible Timezone Selection: A built-in timezone dropdown (e.g., GMT+8) to easily match your chart's display time.
[*]Fully Customizable Colors: Adjust the candle overlay color directly from the style menu to fit your chart theme.
[/list]

## Source Code

````pine
//@version=6
indicator("Adjustable Timezone Swap Highlighter", overlay=true)

// Inputs
swapSession = input.string("0500-0600", title="Swap Hour Session (HHMM-HHMM)")
tzInput     = input.string("GMT+8", title="Timezone", options=["GMT+8", "GMT+0", "America/New_York", "Europe/London", "Asia/Tokyo"])
swapColor   = input.color(color.new(#FFB300, 0), title="Candle Color")

// Check session using the selected timezone
inSession = not na(time(timeframe.period, swapSession, tzInput))

// Color the candles
barcolor(inSession ? swapColor : na)
````
