# Momentum RSI For Loop | NAL

- url: https://www.tradingview.com/script/xBz0tYCg-Momentum-RSI-For-Loop-NAL/
- type: indicator
- pine_id: PUB;d9ccae70f8f041c392bf3ce2e410f2d4
- version: 1.0

## Description

[b]1. Overview
[/b]
Momentum RSI For Loop | NAL is a momentum-regime indicator built around a Jurik-smoothed double RSI engine. It first smooths price using a Jurik-style moving average, then applies RSI twice to measure both momentum and momentum-of-momentum.

Instead of using a fixed RSI threshold, the indicator compares the current smoothed double RSI against many of its previous values. This creates a loop counter that shows whether current momentum is stronger or weaker than a broad section of recent history.

[b]2. Calculation
[/b]
The indicator starts by smoothing the selected source with a Jurik-style moving average. This creates a cleaner input before RSI is calculated, helping reduce noise while keeping the response relatively fast.

The first RSI measures the momentum of the smoothed source. The second RSI is then applied to the first RSI, creating a double RSI structure. This second layer measures whether the original RSI itself is strengthening or weakening.

After the double RSI is calculated, it is smoothed again using the same Jurik-style smoothing method. This produces the final momentum series used by the loop engine.

The loop mechanism then compares the current smoothed double RSI value against past values over the selected range. If the current value is greater than the value from [i][b]i[/b][/i] bars ago, the counter adds one point. If it is not greater, the counter subtracts one point.

A high positive counter means current momentum is stronger than many previous momentum readings. A deeply negative counter means current momentum is weaker than many previous readings.

The final signal is based on two thresholds. A bullish state triggers when the loop counter rises above the upper threshold. A bearish state triggers when the loop counter falls below the lower threshold.

[b]3. Key Features
[/b]
[list=1]
[*]Jurik-smoothed double RSI momentum engine.

[*]For-loop comparison against historical momentum values.

[*]Measures relative momentum strength instead of relying on static RSI levels.

[*]Upper and lower loop thresholds for bullish and bearish regime detection.

[*]Glow-style loop plot, threshold fills, candle coloring, and transition labels.
[/list]

[b]4. Use
[/b]
Works well in getting out around tops and bottoms, during trending periods. Best used in confluence with other indicators, due to it's unique behaviour, and it being prone to false signals in regimes where other indicators are not.

The indicator is best used as a momentum-regime tool. It can help confirm trend continuation, detect momentum shifts, and visually separate bullish and bearish conditions through candle coloring and transition labels.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Momentum RSI For Loop | NAL", "Momentum RSI FL", precision = 2, overlay = false)

//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝

// ══════════════════════════════════════ ◈ Visuals & Tooltips ◈ ══════════════════════════════════════

col_mode = input.string("Standard", title = "Color Mode", group = "Visuals", options = ["Standard", "Nordic", "Simple"])
show_shapes = input.bool(true, "Show Labels", group = "Visuals")
show_candles = input.bool(true, "Color Candles", group = "Visuals")

[col_up, col_dn, col_nu] = switch col_mode
    "Standard"  => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"    => [color.rgb(46, 161, 255), color.rgb(150, 154, 169), color.gray]
    "Simple"    => [color.lime, color.red, color.gray]

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

GR = "Momentum RSI"
LOO = "For Loop"

Rsi_src = input.source(close, "RSI Source", group = GR)
Rsi_len = input.int(30, "RSI Length", minval = 1, group = GR)

JMA_len = input.int(12, "JMA Length", minval = 1, group = GR)
JMA_power = input.float(5.0, "JMA Power", minval = 0.1, step = 0.1, group = GR)

from = input.int(1, "From", minval = 1, group = LOO, inline = "LOOP")
to_ = input.int(60, "To", minval = 1, group = LOO, inline = "LOOP")

upper_threshold = input.int(20, "Upper Threshold", group = LOO)
lower_threshold = input.int(-35, "Lower Threshold", group = LOO)

// ══════════════════════════════════════ ◈ Logic ◈ ══════════════════════════════════════

jma(series float src, simple int length, simple float phase, simple float power) =>
    float phaseRatio = phase < -100.0 ? 0.5 : phase > 100.0 ? 2.5 : phase / 100.0 + 1.5
    float beta = 0.45 * float(length - 1) / (0.45 * float(length - 1) + 2.0)
    float alpha = math.pow(beta, power)
    var float jma_val = na
    var float e0 = na
    var float e1 = na
    var float e2 = na
    e0 := (1.0 - alpha) * src + alpha * nz(e0[1], src)
    e1 := (src - e0) * (1.0 - beta) + beta * nz(e1[1], 0.0)
    e2 := (e0 + phaseRatio * e1 - nz(jma_val[1], src)) * math.pow(1.0 - alpha, 2.0) + math.pow(alpha, 2.0) * nz(e2[1], 0.0)
    jma_val := e2 + nz(jma_val[1], src)
    jma_val

JMA_src = jma(Rsi_src, JMA_len, 100.0, JMA_power)

RSI1 = ta.rsi(JMA_src, Rsi_len)
RSI2 = ta.rsi(RSI1, Rsi_len)

JMA_RSI2 = jma(RSI2, JMA_len, 100.0, JMA_power)

// ══════════════════════════════════════ ◈ For Loop Mechanism ◈ ══════════════════════════════════════

int counter = 0

for i = from to to_
    counter := JMA_RSI2 > JMA_RSI2[i] ? counter + 1 : counter - 1

long = counter > upper_threshold
short = counter < lower_threshold

// ══════════════════════════════════════ ◈ Score ◈ ══════════════════════════════════════

var int score = 0

if long
    score := 1

if short
    score := -1

bullish_transition = score == 1 and score[1] == -1
bearish_transition = score == -1 and score[1] == 1

col = score == 1 ? col_up : score == -1 ? col_dn : col_nu
candle_col = show_candles ? col : na

// ══════════════════════════════════════ ◈ Plots and Visuals ◈ ══════════════════════════════════════

p_upper = plot(upper_threshold, "Upper Threshold", color = color.new(col_up, 45), linewidth = 1)
p_lower = plot(lower_threshold, "Lower Threshold", color = color.new(col_dn, 45), linewidth = 1)
p_zero = plot(0, "Zero Line", color = color.new(col_nu, 75), linewidth = 1, display = display.pane)

p_upper_fill = plot(long ? counter : na, "Upper Fill Anchor", color = color.new(col_up, 100), display = display.pane)
p_lower_fill = plot(short ? counter : na, "Lower Fill Anchor", color = color.new(col_dn, 100), display = display.pane)

fill(p_upper_fill, p_upper, color = color.new(col_up, 86))
fill(p_lower_fill, p_lower, color = color.new(col_dn, 86))

plot(counter, "Loop Glow", color = color.new(col, 78), linewidth = 7, display = display.pane)
plot(counter, "Loop", color = col, linewidth = 2)

plotcandle(open, high, low, close, "Loop Colored Candles", color = candle_col, wickcolor = candle_col, bordercolor = candle_col, force_overlay = true, display = display.pane)

plotshape(show_shapes and bullish_transition, "Bullish Transition", style = shape.triangleup, location = location.belowbar, text = "𝓑𝓾𝔂", color = col_up, textcolor = col_up, size = size.tiny, force_overlay = true, display = display.pane)
plotshape(show_shapes and bearish_transition, "Bearish Transition", style = shape.triangledown, location = location.abovebar, text = "𝓢𝓮𝓵𝓵", color = col_dn, textcolor = col_dn, size = size.tiny, force_overlay = true, display = display.pane)
````
