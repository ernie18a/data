# Asian & London Session Highs/Lows

- url: https://www.tradingview.com/script/0FzUzRDv/
- type: indicator
- pine_id: PUB;78b66e6a50434a65ad7d9ffe97286e42
- version: 1.0

## Description

[/list][b][/b]Description:
This indicator automatically detects and plots the highest and lowest price points of the Asian and London trading sessions. It is designed specifically for day traders, particularly those using Smart Money Concepts (SMC), Inner Circle Trader (ICT) methodologies, or classic Price Action strategies, who rely on session liquidity and daily market structure.

Session highs and lows act as major liquidity pools. A common trading concept involves waiting for the London or New York session to sweep the Asian session liquidity (High or Low) before anticipating a reversal or a strong trend continuation. This tool visually highlights these crucial levels directly on your chart, saving you time and keeping your analysis precise.

[b][/b]Key Features:
1. Accurate High/Low Detection: Pinpoints the exact highest and lowest wicks within your defined session windows.

2. Fully Customizable Session Times: Adjust the start and end times for both the Asian and London sessions directly from the indicator settings. Perfect for isolating specific timeframes like the "Asian Killzone".

3. Native Timezone Support: Built with Pine Script v6, it handles timezones flawlessly. You don't need to do any complex UTC math—just input your session string (e.g., 0000-0800) and the indicator does the rest.

4. Clean & Uncluttered Charts: Draws clean horizontal lines extending to the right for easy visibility. The script automatically removes lines from previous days, ensuring your current chart remains neat and focused on the active session.

5. Visual Customization: Easily change line colors, thickness, and how far the lines extend to the right to perfectly match your personal chart theme.

[b][/b]How to Use:
1. Apply the indicator to your intraday chart (e.g., 5m, 15m, 30m, 1H).

2. Open the indicator Settings.

3. Adjust the Asian Session Time and London Session Time to match your trading strategy (default is set to standard broad sessions, but can be narrowed down to specific killzones).

4. Watch for price action reactions, breakouts, or liquidity sweeps around these key structural lines during the trading day.
[i][/i]Note: This indicator is designed for intraday timeframes. It will not display lines on Daily (1D) or higher timeframes.

## Source Code

````pine
//@version=6
indicator("Asian & London Session Highs/Lows", overlay=true)

// === INPUTS === //
// Zamiast ręcznej matematyki, używamy wbudowanych stringów sesji
asianSessionStr  = input.session("2200-0700", "Asian Session Time")
londonSessionStr = input.session("0700-1300", "London Session Time")
sessionZone      = input.string("UTC", "Timezone (np. UTC, Europe/London)")

asianHighColor  = input.color(color.green, "Asian High Line Color")
asianLowColor   = input.color(color.red, "Asian Low Line Color")
londonHighColor = input.color(color.blue, "London High Line Color")
londonLowColor  = input.color(color.orange, "London Low Line Color")
lineWidth       = input.int(2, "Line Thickness", minval=1, maxval=5)
lineExtension   = input.int(20, "Bars to Extend Line Right", minval=1, maxval=500)

// === SESSION LOGIC === //
// Funkcja time() zwraca czas, jeśli świeca jest w podanej sesji. W przeciwnym razie zwraca 'na'
inAsian  = not na(time(timeframe.period, asianSessionStr, sessionZone))
inLondon = not na(time(timeframe.period, londonSessionStr, sessionZone))

// === ASIAN VARIABLES & LOGIC === //
var float asianHigh = na
var float asianLow = na
var int asianHighBar = na
var int asianLowBar = na
var line asianHighLine = na
var line asianLowLine = na

// Detekcja początku i końca sesji
asianStart = inAsian and not inAsian[1]
asianEnd   = not inAsian and inAsian[1]

if asianStart
    asianHigh := high
    asianLow := low
    asianHighBar := bar_index
    asianLowBar := bar_index
else if inAsian
    if high > asianHigh
        asianHigh := high
        asianHighBar := bar_index
    if low < asianLow
        asianLow := low
        asianLowBar := bar_index

if asianEnd
    line.delete(asianHighLine)
    line.delete(asianLowLine)
    asianHighLine := line.new(x1=asianHighBar, y1=asianHigh, x2=asianHighBar + lineExtension, y2=asianHigh, color=asianHighColor, width=lineWidth)
    asianLowLine  := line.new(x1=asianLowBar, y1=asianLow, x2=asianLowBar + lineExtension, y2=asianLow, color=asianLowColor, width=lineWidth)

// === LONDON VARIABLES & LOGIC === //
var float londonHigh = na
var float londonLow = na
var int londonHighBar = na
var int londonLowBar = na
var line londonHighLine = na
var line londonLowLine = na

londonStart = inLondon and not inLondon[1]
londonEnd   = not inLondon and inLondon[1]

if londonStart
    londonHigh := high
    londonLow := low
    londonHighBar := bar_index
    londonLowBar := bar_index
else if inLondon
    if high > londonHigh
        londonHigh := high
        londonHighBar := bar_index
    if low < londonLow
        londonLow := low
        londonLowBar := bar_index

if londonEnd
    line.delete(londonHighLine)
    line.delete(londonLowLine)
    londonHighLine := line.new(x1=londonHighBar, y1=londonHigh, x2=londonHighBar + lineExtension, y2=londonHigh, color=londonHighColor, width=lineWidth)
    londonLowLine  := line.new(x1=londonLowBar, y1=londonLow, x2=londonLowBar + lineExtension, y2=londonLow, color=londonLowColor, width=lineWidth)
````
