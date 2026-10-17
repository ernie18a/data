# Spread Compression Alert [DYNA]

- url: https://www.tradingview.com/script/5iO3CmFg-Spread-Compression-Alert-DYNA/
- type: indicator
- pine_id: PUB;eab3078116eb4fd0a097f5eaefbda639
- version: 1.0

## Description

Markets don't move in straight lines -- they alternate between periods of compression and expansion. Spread Compression Alert detects when candle ranges shrink to unusually low levels, warning you that a sharp move is building beneath the surface. Instead of reacting after a breakout has already happened, you can position yourself before it begins.

Most traders miss the quiet before the storm. They stare at flat price action and look away, only to catch the tail end of a big move. This indicator solves that problem by continuously comparing short-term volatility to its longer-term baseline and flagging the exact moments when the market is coiling tightest -- right when you should be paying the most attention.


[b]Key Features[/b]

[list]
[*] [b]ATR Compression Ratio[/b] -- Compares fast ATR to slow ATR to objectively measure how compressed current price action is relative to normal conditions
[*] [b]Diamond Markers[/b] -- Small orange diamonds appear above each compressed bar, giving you an instant visual scan of where the market is tightening
[*] [b]Cluster Detection[/b] -- When multiple consecutive bars are compressed, the background highlights orange, signaling that expansion pressure is building to extreme levels
[*] [b]Confirmed-Bar Logic[/b] -- All signals are calculated on confirmed (closed) bars, so markers never appear and disappear mid-bar
[/list]


[b]How It Works[/b]
 
As you watch a chart, you will notice small orange diamond markers appearing above certain bars. Each diamond indicates that the bar's range is significantly smaller than the recent average -- the market is compressing. A single diamond is worth noting but not necessarily actionable.

When diamonds appear on several consecutive bars, the background turns a soft orange. This is the cluster highlight, and it tells you the market has been compressing for an extended period. Many traders study these clusters as periods of consolidation that can precede a range expansion. The longer the compression lasts, the more notable the eventual breakout in range can be.

[image]https://www.tradingview.com/x/6bYnVF15/[/image]
[i]Orange diamonds mark individual compressed bars. The background highlight appears when consecutive compressed bars reach the threshold, flagging an extended period of compression.[/i]


[b]Settings[/b]

The indicator works out of the box with sensible defaults. The Fast ATR Length (default 5) measures recent candle ranges, while the Slow ATR Length (default 50) establishes the normal volatility baseline. The Compression Ratio (default 0.6) sets how tight the range must get before flagging compression -- lower values require more extreme compression. The Consecutive Bar Threshold (default 3) controls how many compressed bars in a row trigger the cluster highlight and extreme compression alert.

For lower timeframes like 1-5 minute charts, you may want to reduce the Slow ATR Length to 30 so the baseline adapts faster. For stricter signals on any timeframe, try lowering the Compression Ratio to 0.3.


[b]Alerts[/b]

[list]
[*] [b]Compression Detected[/b] -- Fires when a single compressed bar is confirmed. Message: [i]"Spread Compression Alert [DYNA]: Candle range compression detected. ATR ratio dropped below threshold -- watch for expansion."[/i]
[*] [b]Extreme Compression[/b] -- Fires when consecutive compressed bars reach the threshold. Message: [i]"Spread Compression Alert [DYNA]: Extreme compression -- multiple consecutive compressed bars. Expansion is imminent."[/i]
[/list]

To set up alerts: click the TradingView Alerts button, select "Spread Compression Alert [DYNA]" from the indicator dropdown, choose "Any alert() function call" as the condition, and set your preferred notification method.


[b]Best Practices[/b]

[list]
[*] Compression tells you when a move is coming, not which direction. Pair this indicator with a trend or momentum tool for directional bias.
[*] Compression clusters near key support or resistance levels tend to produce the most tradeable breakouts.
[*] This indicator is especially useful before scheduled news events or market opens, when volatility is temporarily suppressed.
[*] On higher timeframes (4H, Daily), compression signals can indicate multi-day consolidation patterns worth monitoring for swing entries.
[/list]


[b]Part of the DYNA Ecosystem[/b]

Spread Compression Alert is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Spread Compression Alert [DYNA]
// Detects when candle ranges compress to extreme lows, signaling imminent
// price expansion. Compares fast ATR to slow ATR and flags compression clusters.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Spread Compression Alert [DYNA]", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// --- Core Settings ---
int   i_fastATR            = input.int(5,   "Fast ATR Length",        minval = 1,  group = "Core Settings", tooltip = "Short-term ATR measuring recent candle ranges.")
int   i_slowATR            = input.int(50,  "Slow ATR Length",        minval = 2,  group = "Core Settings", tooltip = "Long-term ATR baseline for normal volatility.")
float i_compressionRatio   = input.float(0.6, "Compression Ratio",   minval = 0.05, maxval = 1.0, step = 0.05, group = "Core Settings", tooltip = "Ratio below which fast/slow ATR is considered compressed. Lower = stricter.")
int   i_consecutiveThresh  = input.int(3,   "Consecutive Bar Threshold", minval = 2, group = "Core Settings", tooltip = "Number of consecutive compressed bars to trigger extreme compression alert.")

// --- Visual ---
bool  i_showDiamonds       = input.bool(true, "Show Diamond Markers",     group = "Visual")
bool  i_showBackground     = input.bool(true, "Show Cluster Background",  group = "Visual")

// --- Alerts ---
bool  i_alertCompression   = input.bool(true, "Alert: Compression Detected",   group = "Alerts")
bool  i_alertExtreme       = input.bool(true, "Alert: Extreme Compression",    group = "Alerts")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- ATR Calculation ---
float fastATR = ta.atr(i_fastATR)
float slowATR = ta.atr(i_slowATR)

// --- Compression Ratio (guard division by zero) ---
float ratio = fastATR / math.max(slowATR, syminfo.mintick)

// --- Compression Detection (confirmed bar) ---
bool isCompressed = ratio[1] < i_compressionRatio

// --- Consecutive Compressed Bar Counter (confirmed bar) ---
var int consecutiveCount = 0
if ratio[1] < i_compressionRatio
    consecutiveCount += 1
else
    consecutiveCount := 0

// --- Extreme Compression (confirmed bar) ---
bool isExtremeCompression = consecutiveCount >= i_consecutiveThresh

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// --- Diamond markers above compressed bars ---
plotshape(i_showDiamonds and isCompressed, title = "Compression Diamond", style = shape.diamond, location = location.abovebar, color = WARNING_COLOR, size = size.tiny)

// --- Background highlight on compression clusters ---
bgcolor(i_showBackground and consecutiveCount >= i_consecutiveThresh ? color.new(WARNING_COLOR, 90) : na, title = "Cluster Background")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(i_alertCompression and isCompressed, title = "Compression Detected", message = "Spread Compression Alert [DYNA]: Candle range compression detected. ATR ratio dropped below threshold -- watch for expansion.")

alertcondition(i_alertExtreme and isExtremeCompression, title = "Extreme Compression", message = "Spread Compression Alert [DYNA]: Extreme compression -- multiple consecutive compressed bars. Expansion is imminent.")
````
