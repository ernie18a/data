# Micro Momentum Oscillator [DYNA]

- url: https://www.tradingview.com/script/XRMZSPQO-Micro-Momentum-Oscillator-DYNA/
- type: indicator
- pine_id: PUB;6cd4bd6bb5d14becae6736c04bcc6397
- version: 1.0

## Description

Micro Momentum Oscillator is a purpose-built momentum tool for scalpers who need to know the instant short-term momentum shifts direction. It doesn't just tell you whether RSI is high or low -- it measures how fast RSI is changing and fires a signal the moment that rate of change flips in an extreme zone.

Most oscillators lag behind price on micro timeframes. By the time a standard RSI or MACD prints a crossover on a 1-minute chart, the move is already half over. Micro Momentum Oscillator solves this by applying a rate-of-change calculation directly to RSI and smoothing the result with a weighted moving average. The output is a fast, responsive line that turns teal when momentum is accelerating upward and red when it is accelerating downward -- giving you a clean visual read on who is in control right now.


[b]Key Features[/b]

[list]
[*] [b]RSI Rate-of-Change Pipeline[/b] -- Measures how quickly RSI itself is changing, not just its level. This catches momentum shifts before the RSI line visually turns.
[*] [b]OB/OS Zone Flip Detection[/b] -- Signals only fire when momentum flips direction while RSI was in an extreme zone (oversold or overbought), filtering out noise in the middle range.
[*] [b]Color-Coded Momentum Line[/b] -- Teal for bullish acceleration, red for bearish acceleration. No interpretation needed -- the color tells you the direction at a glance.
[*] [b]Zone Shading[/b] -- Soft red and teal fills in the overbought and oversold momentum zones so you can instantly see when the oscillator is in an extreme area.
[*] [b]Confirmed-Bar Logic[/b] -- All signals reference the previous bar's values, so flip markers never repaint or disappear after they print.
[/list]


[b]How It Works[/b]

The oscillator computes a short-period RSI (default 5), then calculates the rate of change of that RSI over the last 3 bars. This raw ROC is smoothed with a 3-period weighted moving average to filter out single-bar noise while keeping the reading fast.

The result is plotted as a line that oscillates around zero. When the line is above zero and teal, momentum is pushing RSI higher -- buyers are gaining strength. When the line is below zero and red, momentum is dragging RSI lower -- sellers are in control.

The key signal is the [b]momentum flip[/b]. When the oscillator crosses above zero and RSI was recently in the oversold zone (below 30), a bullish FLIP marker appears. When it crosses below zero and RSI was in the overbought zone (above 70), a bearish FLIP marker appears. These flips highlight the moments when exhausted momentum reverses direction at an extreme -- exactly the kind of micro-reversal scalpers look for.

[image]https://www.tradingview.com/x/caxFpRNY/[/image]
[i]Micro Momentum Oscillator on a 1-minute BTC chart showing bullish and bearish flip signals at momentum extremes.[/i]


[b]Visual Elements[/b]

The oscillator pane shows a teal/red momentum line, a gray zero line, and soft zone shading in the overbought and oversold areas. A thin orange reference line tracks the underlying RSI (scaled to fit the pane) so you can see at a glance whether price is stretched. Triangle markers with "FLIP" text appear at momentum reversal points in extreme zones.

[image]https://www.tradingview.com/x/h6C9ETl7/[/image]
[i]Zone shading highlights overbought and oversold momentum areas. The orange RSI reference line shows underlying conditions.[/i]


[b]Settings[/b]

The core settings control the speed of the oscillator. RSI Length (default 5) sets the underlying RSI period -- lower values make it more reactive. ROC Length (default 3) controls how many bars of RSI change are measured. Smoothing (default 3) applies a WMA to the ROC output to remove noise without adding significant lag.

Overbought and Oversold levels (default 70 and 30) define the RSI thresholds for flip detection. Only momentum reversals that occur when RSI was beyond these levels generate flip markers. You can tighten these thresholds (e.g., 75/25) for fewer but higher-conviction signals, or widen them (e.g., 65/35) for more frequent signals.

Visual toggles let you show or hide zone shading and flip markers. Alert toggles let you enable or disable each alert type independently.


[b]Alerts[/b]

[list]
[*] [b]Momentum Flip Bullish[/b] -- Fires when the smoothed ROC crosses above zero while RSI was in the oversold zone. [i]"Micro Momentum Oscillator [DYNA]: Bullish momentum flip detected. RSI was oversold, ROC now accelerating upward."[/i]
[*] [b]Momentum Flip Bearish[/b] -- Fires when the smoothed ROC crosses below zero while RSI was in the overbought zone. [i]"Micro Momentum Oscillator [DYNA]: Bearish momentum flip detected. RSI was overbought, ROC now decelerating downward."[/i]
[/list]

To set up alerts: click the TradingView Alerts button, select "Micro Momentum Oscillator [DYNA]" from the indicator dropdown, choose "Any alert() function call" as the condition, and set your preferred notification method.


[b]Best Practices[/b]

[list]
[*] Use on 1-3 minute charts for best results. The default parameters are calibrated for micro-timeframe scalping.
[*] Treat FLIP signals as timing cues, not standalone entries. Confirm with a supporting candle pattern, a volume spike, or a key support/resistance level.
[*] Avoid trading flips during low-volume periods such as pre-market or lunch hours when momentum readings become noisy.
[*] If moving to 5-minute charts, consider increasing RSI Length to 8-10 to maintain signal quality.
[*] Pair with a volume indicator or tape reader for stronger confirmation on each flip.
[/list]


[b]Part of the DYNA Ecosystem[/b]

Micro Momentum Oscillator is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Micro Momentum Oscillator [DYNA]
// Ultra-fast momentum oscillator tuned for 1-3 minute scalping entries.
// Detects momentum flips in overbought/oversold zones using RSI rate of change.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Micro Momentum Oscillator [DYNA]", shorttitle = "MicroMom [DYNA]", overlay = false, max_labels_count = 500, max_lines_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800
color OB_ZONE_COLOR = color.new(#ef5350, 85)
color OS_ZONE_COLOR = color.new(#26a69a, 85)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// --- Core Settings ---
string GRP_CORE = "Core Settings"
int    i_rsiLen     = input.int(5,    "RSI Length",       minval = 2, maxval = 50,   group = GRP_CORE)
int    i_rocLen     = input.int(3,    "ROC Length",       minval = 1, maxval = 20,   group = GRP_CORE)
int    i_smoothLen  = input.int(3,    "Smoothing (WMA)",  minval = 1, maxval = 20,   group = GRP_CORE)
float  i_obLevel    = input.float(70, "Overbought Level", minval = 50, maxval = 95, step = 5.0, group = GRP_CORE)
float  i_osLevel    = input.float(30, "Oversold Level",   minval = 5,  maxval = 50, step = 5.0, group = GRP_CORE)

// --- Visual ---
string GRP_VIS = "Visual"
bool   i_showZones  = input.bool(true, "Show OB/OS Zone Shading", group = GRP_VIS)
bool   i_showFlips  = input.bool(true, "Show Flip Markers",       group = GRP_VIS)

// --- Alerts ---
string GRP_ALERT = "Alerts"
bool   i_alertBull  = input.bool(true, "Alert: Momentum Flip Bullish",  group = GRP_ALERT)
bool   i_alertBear  = input.bool(true, "Alert: Momentum Flip Bearish",  group = GRP_ALERT)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- RSI -> ROC -> WMA pipeline ---
float rsiVal      = ta.rsi(close, i_rsiLen)
float rsiRoc      = rsiVal - nz(rsiVal[i_rocLen])
float smoothedRoc = ta.wma(rsiRoc, i_smoothLen)

// --- Momentum flip detection (confirmed-bar logic using [1]) ---
// Bullish flip: smoothed ROC crosses from negative to positive while RSI was in oversold zone
bool bullFlip = i_alertBull and smoothedRoc > 0 and nz(smoothedRoc[1]) <= 0 and nz(rsiVal[1]) < i_osLevel
// Bearish flip: smoothed ROC crosses from positive to negative while RSI was in overbought zone
bool bearFlip = i_alertBear and smoothedRoc < 0 and nz(smoothedRoc[1]) >= 0 and nz(rsiVal[1]) > i_obLevel

// --- Oscillator color based on current state ---
color oscColor = smoothedRoc > 0 ? BULL_COLOR : smoothedRoc < 0 ? BEAR_COLOR : NEUTRAL_COLOR

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// --- Oscillator line ---
plot(smoothedRoc, "Micro Momentum", color = oscColor, linewidth = 2)

// --- Zero line ---
hline(0, "Zero Line", color = NEUTRAL_COLOR, linestyle = hline.style_solid)

// --- OB/OS reference levels (mapped to ROC scale thresholds) ---
h_upper = hline(5,  "Upper Threshold", color = color.new(BEAR_COLOR, 60), linestyle = hline.style_dotted)
h_lower = hline(-5, "Lower Threshold", color = color.new(BULL_COLOR, 60), linestyle = hline.style_dotted)

// --- Zone shading ---
fill(h_upper, hline(10, "OB Ceiling", color = color.new(BEAR_COLOR, 90), linestyle = hline.style_dotted), color = i_showZones ? OB_ZONE_COLOR : na, title = "Overbought Zone")
fill(h_lower, hline(-10, "OS Floor", color = color.new(BULL_COLOR, 90), linestyle = hline.style_dotted), color = i_showZones ? OS_ZONE_COLOR : na, title = "Oversold Zone")

// --- Flip markers ---
plotshape(i_showFlips and bullFlip ? smoothedRoc : na, "Bullish Flip", style = shape.triangleup,   location = location.absolute, color = BULL_COLOR, size = size.small, text = "FLIP", textcolor = BULL_COLOR)
plotshape(i_showFlips and bearFlip ? smoothedRoc : na, "Bearish Flip", style = shape.triangledown, location = location.absolute, color = BEAR_COLOR, size = size.small, text = "FLIP", textcolor = BEAR_COLOR)

// --- RSI reference line (secondary, thinner) ---
// Map RSI from 0-100 to a comparable scale for visual reference
float rsiMapped = (rsiVal - 50) / 5
plot(rsiMapped, "RSI (scaled)", color = color.new(WARNING_COLOR, 50), linewidth = 1, style = plot.style_line)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(bullFlip, title = "Momentum Flip Bullish", message = "Micro Momentum Oscillator [DYNA]: Bullish momentum flip detected. RSI was oversold, ROC now accelerating upward.")
alertcondition(bearFlip, title = "Momentum Flip Bearish", message = "Micro Momentum Oscillator [DYNA]: Bearish momentum flip detected. RSI was overbought, ROC now decelerating downward.")
````
