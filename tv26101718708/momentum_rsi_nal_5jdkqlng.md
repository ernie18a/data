# Momentum RSI | NAL

- url: https://www.tradingview.com/script/5JdkQLNg-Momentum-RSI-NAL/
- type: indicator
- pine_id: PUB;bb20dd567fa64094bd1d7ceb462ded0d
- version: 1.0

## Description

[b]1. Overview
[/b]
Momentum RSI | NAL is a momentum-regime indicator built around a Jurik-smoothed double RSI engine. It first smooths price using a Jurik-style moving average, then applies RSI twice to measure both momentum and momentum-of-momentum.

Instead of relying on raw RSI movement, the indicator uses a smoothed second RSI layer to better identify when momentum is expanding or deteriorating. The final Momentum RSI is compared against bullish and bearish thresholds to create a clean directional state.

[b]2. Calculation
[/b]
The indicator starts by smoothing the selected source with a Jurik-style moving average. This creates a cleaner input before the RSI calculation, helping reduce noise while keeping the response relatively fast.

The first RSI measures the momentum of the smoothed source. The second RSI is then applied to the first RSI, creating a double RSI structure. This second layer measures whether the original RSI itself is strengthening or weakening.

After the double RSI is calculated, it is smoothed again using the same Jurik-style smoothing method. This produces the final Momentum RSI line.

The signal is based on two thresholds. A bullish state triggers when the Momentum RSI rises above the long threshold. A bearish state triggers when the Momentum RSI falls below the short threshold.

When the Momentum RSI is between both thresholds, the indicator keeps its previous directional state. This helps avoid constant neutral flipping and gives a cleaner regime-style output.

[b]3. Key Features
[/b]
[list=1]
[*]Jurik-smoothed double RSI momentum engine.
[*]Measures both momentum and momentum-of-momentum.
[*]Bullish and bearish threshold-based regime detection.
[*]State-based coloring that holds the previous direction between thresholds.
[*]Glow-style RSI plot, threshold fills, candle coloring, and transition labels.
[/list]

[b]4. Use
[/b]
Works well for identifying momentum shifts and potential exhaustion areas during trending periods. The double RSI structure can react to changes in momentum before a standard RSI fully confirms the move.

A move above the long threshold suggests bullish momentum pressure. A move below the short threshold suggests bearish momentum pressure. The colored candles and transition labels make it easier to see when the indicator changes state.

Best used in confluence with other indicators, due to its unique behavior and potential for false signals in choppy or low-directional regimes. The indicator is best used as a momentum-regime tool for confirming trend continuation, spotting momentum deterioration, and visually separating bullish and bearish conditions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Momentum RSI | NAL", "Momentum RSI", precision = 2, overlay = false)


//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝


// ══════════════════════════════════════ ◈ Visuals & Tooltips ◈ ══════════════════════════════════════

col_mode = input.string("Standard", title = "Color Mode", group = "Visuals", options = ["Standard", "Nordic", "Simple"])
show_shapes = input.bool(true, "Show Labels", group = "Visuals")

[col_up, col_dn, col_nu] = switch col_mode
    "Standard"  => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"    => [color.rgb(46, 161, 255), color.rgb(150, 154, 169), color.gray]
    "Simple"    => [color.lime, color.red, color.gray]

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

GR = "Momentum RSI"
GT = "Thresholds"

Rsi_src = input.source(close, "RSI Source", group = GR)
Rsi_len = input.int(18, "RSI Length", minval = 1, group = GR)

JMA_len = input.int(12, "JMA Length", minval = 1, group = GR)
JMA_power = input.float(5.0, "JMA Power", minval = 0.1, step = 0.1, group = GR)

long_threshold = input.int(60, "Long Threshold", group = GT)
short_threshold = input.int(40, "Short Threshold", group = GT)

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

RSI1 = ta.rsi(jma(Rsi_src, JMA_len, 100, JMA_power), Rsi_len)
RSI2 = ta.rsi(RSI1, Rsi_len)

JMA_RSI2 = jma(RSI2, JMA_len, 100, JMA_power)


// ══════════════════════════════════════ ◈ Plots ◈ ══════════════════════════════════════

// Threshold state
rsi_bullish = JMA_RSI2 > long_threshold
rsi_bearish = JMA_RSI2 < short_threshold

var int rsi_state = 0
rsi_state := rsi_bullish ? 1 : rsi_bearish ? -1 : nz(rsi_state[1], 0)

color rsi_color = na
rsi_color := rsi_bullish ? col_up : rsi_bearish ? col_dn : rsi_color[1]

bullish_transition = rsi_state == 1 and rsi_state[1] == -1
bearish_transition = rsi_state == -1 and rsi_state[1] == 1

p_long = plot(long_threshold, "Long Threshold", color = color.new(col_up, 45), linewidth = 1)
p_short = plot(short_threshold, "Short Threshold", color = color.new(col_dn, 45), linewidth = 1)
p_mid = plot(50.0, "Midline", color = color.new(col_nu, 75), linewidth = 1, display = display.pane)

p_upper_fill = plot(rsi_bullish ? JMA_RSI2 : na, "Upper Fill Anchor", color = color.new(col_up, 100), display = display.pane)
p_lower_fill = plot(rsi_bearish ? JMA_RSI2 : na, "Lower Fill Anchor", color = color.new(col_dn, 100), display = display.pane)

fill(p_upper_fill, p_long, color = color.new(col_up, 86))
fill(p_lower_fill, p_short, color = color.new(col_dn, 86))

plot(JMA_RSI2, "Momentum RSI Glow", color = color.new(rsi_color, 78), linewidth = 7, display = display.pane)
plot(JMA_RSI2, "Momentum RSI", color = rsi_color, linewidth = 2)

plotcandle(open, high, low, close, "RSI Colored Candles", color = rsi_color, wickcolor = rsi_color, bordercolor = rsi_color, force_overlay = true, display = display.pane)

plotshape(show_shapes and bullish_transition, "Bullish Transition", style = shape.triangleup, location = location.belowbar, text = "𝓑𝓾𝔂", color = col_up, textcolor = col_up, size = size.tiny, force_overlay = true, display = display.pane)
plotshape(show_shapes and bearish_transition, "Bearish Transition", style = shape.triangledown, location = location.abovebar, text = "𝓢𝓮𝓵𝓵", color = col_dn, textcolor = col_dn, size = size.tiny, force_overlay = true, display = display.pane)
````
