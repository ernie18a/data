# Shift Structure Cloud [JOAT]

- url: https://www.tradingview.com/script/3YDhSIer-Shift-Structure-Cloud-JOAT/
- type: indicator
- pine_id: PUB;13cd7bb7a0094f3ebe409872300f9156
- version: 1.0

## Description

Shift Structure Cloud is an open-source Pine Script v6 overlay that converts confirmed swing structure into a clean adaptive trend cloud. It tracks pivot highs and pivot lows, separates continuation breaks from character shifts, and uses the active structure range to build a dynamic average and multi-layer cloud around price.

The problem it solves is structural context. Many trend tools react only to moving averages or oscillator thresholds. This script anchors its visual state to confirmed market structure first, then uses an adaptive cloud to show whether price is trading above, below, or inside the current structural center. The result is a chart layer that can help separate continuation from transition without relying on future bars.

[image]https://www.tradingview.com/x/x2lns7Z3/[/image]

[b]Core Concepts[/b]

[b]1. Confirmed Pivot Structure[/b]

The script uses ta.pivothigh() and ta.pivotlow() to confirm swing highs and lows. A pivot is only accepted after the configured right-side confirmation window closes, which means the level is delayed by design but does not depend on unconfirmed future plotting.

[pine]
pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLow  = ta.pivotlow(low, pivotLeft, pivotRight)

if not na(pivotHigh)
    structureHigh := pivotHigh
[/pine]

[b]2. BOS and CHoCH Logic[/b]

The current structure high and low become break reference levels. A bullish break occurs when price closes above the prior structure high. A bearish break occurs when price closes below the prior structure low. If the break happens against the previous side, it is classified as CHoCH; otherwise it is a continuation BOS.

[pine]
bullBreakRaw = barstate.isconfirmed and not na(priorHigh) and close > priorHigh and priorClose <= priorHigh
bearBreakRaw = barstate.isconfirmed and not na(priorLow) and close < priorLow and priorClose >= priorLow

bullChoCh = bullBreak and trendSide == -1
bearChoCh = bearBreak and trendSide == 1
[/pine]

[b]3. Adaptive Structure Average[/b]

Instead of plotting only fixed swing levels, the script calculates the midpoint between the active structure high and low. The midpoint is then smoothed with an adaptive alpha. When price moves far from the structural center, the average becomes more responsive; when price is balanced, it becomes slower.

[pine]
structureMid = (activeHigh + activeLow) * 0.5
structureDrift = f_clamp(math.abs(close - structureMid) / legSize, 0.0, 1.0)
adaptAlpha = slowAlpha + (fastAlpha - slowAlpha) * structureDrift
structureAverage := structureAverage[1] + adaptAlpha * (structureMid - structureAverage[1])
[/pine]

[b]4. Multi-Layer Cloud[/b]

The cloud is built from ATR-adjusted bands around the adaptive structure average. Inner, middle, and outer layers give a visual read of compression, transition, and extended distance from structure.

[b]5. Strength-Based Candle Coloring[/b]

When enabled, candles are repainted with a gradient based on distance from the structure average. The candle color is informational only; it does not change the underlying chart data.

[b]Features[/b]

[list]
[*][b]Confirmed BOS and CHoCH detection:[/b] Structural events are gated with barstate.isconfirmed
[*][b]Adaptive structure average:[/b] A dynamic centerline based on active swing range and price drift
[*][b]Layered trend cloud:[/b] Inner, middle, and outer ATR bands visualize distance from structure
[*][b]Structure high and low levels:[/b] Current confirmed swing levels can be shown as reference lines
[*][b]Gradient candle mode:[/b] Optional candle coloring by structural distance
[*][b]Compact dashboard:[/b] Shows side, last shift, strength, bars since shift, and active range
[*][b]Palette presets:[/b] Aqua Rose, Neon Desk, Mint Pulse, and VWAP Field
[*][b]Alert conditions:[/b] Separate alerts for bullish BOS, bearish BOS, bullish CHoCH, and bearish CHoCH
[/list]

[b]Input Parameters[/b]

[b]Visual System:[/b]
[list]
[*]Palette Preset: Selects the bull and bear color pair
[*]Color Candles: Enables structural candle coloring
[*]Dashboard: Shows or hides the top-right dashboard
[*]Pivot Dots: Shows confirmed pivot dots
[/list]

[b]Structure Engine:[/b]
[list]
[*]Pivot Left / Pivot Right: Controls swing confirmation sensitivity
[*]Fast Adapt Length: Fast smoothing response for the adaptive average
[*]Slow Adapt Length: Slow smoothing response for balanced conditions
[*]Cloud ATR Length: ATR length used for cloud width
[*]Cloud Width: Multiplier applied to the cloud distance
[*]BOS and CHoCH Marks: Shows structural event markers
[*]Structure Levels: Shows active swing high and low reference lines
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Cloud Side[/b]
If price is above the adaptive structure average and the cloud is colored bullish, the current structural state favors upside continuation. If price is below and the cloud is bearish, the state favors downside continuation.

[b]Step 2: Watch CHoCH Events[/b]
CHoCH labels mark breaks against the previous structural side. They are useful as transition warnings, not automatic entries.

[b]Step 3: Use the Structure Levels[/b]
The active high and low lines show where the next confirmed break could occur. These are the levels the script uses for BOS and CHoCH classification.

[b]Step 4: Combine with Your Own Trigger[/b]
This script is designed as a structure and context layer. Use it with your own entry model, risk plan, and market selection process.

[b]Indicator Limitations[/b]

[list]
[*]Pivot levels confirm after the right-side pivot window closes, so they are intentionally delayed
[*]A fast reversal can occur before a new pivot is confirmed
[*]Cloud distance is ATR-based, so very low volatility markets can compress the visual bands
[*]The script classifies structure; it does not predict future price movement
[/list]

[b]Originality Statement[/b]

Shift Structure Cloud combines confirmed BOS/CHoCH logic, an adaptive structure midpoint, ATR cloud geometry, and strength-colored candles in one original Pine v6 implementation. The script is not a pasted source clone. It rebuilds structure analysis from public Pine mechanics and adds a distinct visual model around the current swing range.

[b]Disclaimer[/b]

This script is provided for educational and informational use only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Signals and structure readings are based on historical chart data and can be wrong in live market conditions. Always use independent analysis and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Shift Structure Cloud [JOAT]", overlay = true, max_labels_count = 100, max_lines_count = 100)

string groupVisual = "Visual System"
string palettePreset = input.string("Aqua Rose", "Palette Preset", options = ["Aqua Rose", "Neon Desk", "Mint Pulse", "VWAP Field"], group = groupVisual)
bool showCandles = input.bool(true, "Color Candles", group = groupVisual)
bool showDashboard = input.bool(true, "Dashboard", group = groupVisual)
bool showPivots = input.bool(false, "Pivot Dots", group = groupVisual)

string groupStructure = "Structure Engine"
int pivotLeft = input.int(4, "Pivot Left", minval = 1, maxval = 20, group = groupStructure)
int pivotRight = input.int(4, "Pivot Right", minval = 1, maxval = 20, group = groupStructure)
int fastLength = input.int(8, "Fast Adapt Length", minval = 2, maxval = 100, group = groupStructure)
int slowLength = input.int(34, "Slow Adapt Length", minval = 3, maxval = 200, group = groupStructure)
int atrLength = input.int(21, "Cloud ATR Length", minval = 2, maxval = 200, group = groupStructure)
float cloudWidth = input.float(0.85, "Cloud Width", minval = 0.10, maxval = 5.00, step = 0.05, group = groupStructure)
bool showSignals = input.bool(true, "BOS and CHoCH Marks", group = groupStructure)
bool showLevels = input.bool(true, "Structure Levels", group = groupStructure)

f_palette(string preset) =>
    color bull = switch preset
        "Neon Desk" => color.rgb(0, 255, 0)
        "Mint Pulse" => color.rgb(0, 255, 213)
        "VWAP Field" => color.rgb(26, 194, 0)
        => color.rgb(0, 200, 255)
    color bear = switch preset
        "Neon Desk" => color.rgb(255, 0, 0)
        "Mint Pulse" => color.rgb(255, 0, 102)
        "VWAP Field" => color.rgb(255, 64, 64)
        => color.rgb(255, 0, 93)
    [bull, bear]

f_clamp(float value, float low, float high) =>
    math.max(low, math.min(high, value))

[bullBase, bearBase] = f_palette(palettePreset)
color quiet = color.rgb(148, 154, 166)

float pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
float pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)
bool newPivotHigh = not na(pivotHigh)
bool newPivotLow = not na(pivotLow)

var float structureHigh = na
var float structureLow = na
var int trendSide = 0
var string lastShift = "None"

float priorHigh = structureHigh
float priorLow = structureLow
float priorClose = nz(close[1], close)
bool bullBreakRaw = barstate.isconfirmed and not na(priorHigh) and close > priorHigh and priorClose <= priorHigh
bool bearBreakRaw = barstate.isconfirmed and not na(priorLow) and close < priorLow and priorClose >= priorLow
bool bullBreak = bullBreakRaw and not bearBreakRaw
bool bearBreak = bearBreakRaw and not bullBreakRaw
bool bullChoCh = bullBreak and trendSide == -1
bool bearChoCh = bearBreak and trendSide == 1
bool bullBos = bullBreak and not bullChoCh
bool bearBos = bearBreak and not bearChoCh

if bullBreak
    trendSide := 1
    lastShift := bullChoCh ? "Bull CHoCH" : "Bull BOS"
else if bearBreak
    trendSide := -1
    lastShift := bearChoCh ? "Bear CHoCH" : "Bear BOS"

if newPivotHigh
    structureHigh := pivotHigh
if newPivotLow
    structureLow := pivotLow

float activeHigh = nz(structureHigh, high)
float activeLow = nz(structureLow, low)
float structureMid = (activeHigh + activeLow) * 0.5
float legSize = math.max(math.abs(activeHigh - activeLow), syminfo.mintick * 10.0)
float structureDrift = f_clamp(math.abs(close - structureMid) / legSize, 0.0, 1.0)
float fastAlpha = 2.0 / (fastLength + 1.0)
float slowAlpha = 2.0 / (slowLength + 1.0)
float adaptAlpha = slowAlpha + (fastAlpha - slowAlpha) * structureDrift

var float structureAverage = na
structureAverage := na(structureAverage[1]) ? structureMid : structureAverage[1] + adaptAlpha * (structureMid - structureAverage[1])

float atr = ta.atr(atrLength)
float adaptiveWidth = math.max(atr * cloudWidth * (0.70 + structureDrift * 0.60), syminfo.mintick * 10.0)
float innerUpper = structureAverage + adaptiveWidth * 0.50
float innerLower = structureAverage - adaptiveWidth * 0.50
float midUpper = structureAverage + adaptiveWidth
float midLower = structureAverage - adaptiveWidth
float outerUpper = structureAverage + adaptiveWidth * 1.55
float outerLower = structureAverage - adaptiveWidth * 1.55
float score = f_clamp((close - structureAverage) / (adaptiveWidth * 1.55), -1.0, 1.0)
float strength = math.abs(score) * 100.0
color strengthColor = color.from_gradient(score, -1.0, 1.0, bearBase, bullBase)
color sideColor = trendSide == 1 ? bullBase : trendSide == -1 ? bearBase : quiet

plot(structureAverage, "Adaptive Structure Average", color = color.new(strengthColor, 0), linewidth = 2)
plot(showLevels ? structureHigh : na, "Structure High", color = color.new(bullBase, 15), style = plot.style_linebr, linewidth = 1)
plot(showLevels ? structureLow : na, "Structure Low", color = color.new(bearBase, 15), style = plot.style_linebr, linewidth = 1)

plotInnerUpper = plot(innerUpper, "Cloud Inner High", color = color.new(sideColor, 78), linewidth = 1)
plotInnerLower = plot(innerLower, "Cloud Inner Low", color = color.new(sideColor, 78), linewidth = 1)
plotMidUpper = plot(midUpper, "Cloud Mid High", color = color.new(sideColor, 84), linewidth = 1)
plotMidLower = plot(midLower, "Cloud Mid Low", color = color.new(sideColor, 84), linewidth = 1)
plotOuterUpper = plot(outerUpper, "Cloud Outer High", color = color.new(sideColor, 90), linewidth = 1)
plotOuterLower = plot(outerLower, "Cloud Outer Low", color = color.new(sideColor, 90), linewidth = 1)

fill(plotInnerUpper, plotInnerLower, color = color.new(strengthColor, 88), title = "Inner Cloud Fill")
fill(plotMidUpper, plotInnerUpper, color = color.new(sideColor, 92), title = "Upper Mid Cloud Fill")
fill(plotInnerLower, plotMidLower, color = color.new(sideColor, 92), title = "Lower Mid Cloud Fill")
fill(plotOuterUpper, plotMidUpper, color = color.new(sideColor, 95), title = "Upper Outer Cloud Fill")
fill(plotMidLower, plotOuterLower, color = color.new(sideColor, 95), title = "Lower Outer Cloud Fill")

plotshape(showPivots and newPivotHigh ? high : na, "Confirmed Pivot High Dot", style = shape.circle, location = location.absolute, color = color.new(bearBase, 0), size = size.tiny)
plotshape(showPivots and newPivotLow ? low : na, "Confirmed Pivot Low Dot", style = shape.circle, location = location.absolute, color = color.new(bullBase, 0), size = size.tiny)

plotshape(showSignals and bullBos ? low - atr * 0.18 : na, "Bull BOS", text = "BOS", style = shape.circle, location = location.absolute, color = color.new(bullBase, 0), textcolor = color.white, size = size.tiny)
plotshape(showSignals and bearBos ? high + atr * 0.18 : na, "Bear BOS", text = "BOS", style = shape.circle, location = location.absolute, color = color.new(bearBase, 0), textcolor = color.white, size = size.tiny)
plotshape(showSignals and bullChoCh ? low - atr * 0.26 : na, "Bull CHoCH", text = "CHoCH", style = shape.diamond, location = location.absolute, color = color.new(bullBase, 0), textcolor = color.white, size = size.tiny)
plotshape(showSignals and bearChoCh ? high + atr * 0.26 : na, "Bear CHoCH", text = "CHoCH", style = shape.diamond, location = location.absolute, color = color.new(bearBase, 0), textcolor = color.white, size = size.tiny)

color candleColor = color.new(strengthColor, score == 0.0 ? 35 : 8)
plotcandle(showCandles ? open : na, showCandles ? high : na, showCandles ? low : na, showCandles ? close : na, "Structure Candle Color", color = candleColor, wickcolor = color.new(strengthColor, 0), bordercolor = color.new(strengthColor, 0))

bool anyShift = bullBos or bearBos or bullChoCh or bearChoCh
int barsFromShift = ta.barssince(anyShift)
string sideText = trendSide == 1 ? "Up" : trendSide == -1 ? "Down" : "Range"
string ageText = na(barsFromShift) ? "n/a" : str.tostring(barsFromShift)

var table dash = table.new(position.top_right, 2, 5, bgcolor = color.new(color.black, 88), frame_color = color.new(color.gray, 70), frame_width = 1, border_width = 1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Shift", text_color = color.white, text_size = size.small, bgcolor = color.new(sideColor, 75))
    table.cell(dash, 1, 0, sideText, text_color = color.white, text_size = size.small, bgcolor = color.new(sideColor, 75))
    table.cell(dash, 0, 1, "Last", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 1, lastShift, text_color = color.white, text_size = size.small)
    table.cell(dash, 0, 2, "Strength", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 2, str.tostring(strength, "#") + "%", text_color = strengthColor, text_size = size.small)
    table.cell(dash, 0, 3, "Bars", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 3, ageText, text_color = color.white, text_size = size.small)
    table.cell(dash, 0, 4, "Range", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 4, str.tostring(legSize, format.mintick), text_color = color.white, text_size = size.small)

alertcondition(barstate.isconfirmed and bullBos, "Bull BOS [JOAT]", "Shift Structure Cloud [JOAT]: confirmed bullish BOS.")
alertcondition(barstate.isconfirmed and bearBos, "Bear BOS [JOAT]", "Shift Structure Cloud [JOAT]: confirmed bearish BOS.")
alertcondition(barstate.isconfirmed and bullChoCh, "Bull CHoCH [JOAT]", "Shift Structure Cloud [JOAT]: confirmed bullish CHoCH.")
alertcondition(barstate.isconfirmed and bearChoCh, "Bear CHoCH [JOAT]", "Shift Structure Cloud [JOAT]: confirmed bearish CHoCH.")
````
