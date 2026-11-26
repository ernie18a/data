# Keltner Channel MTF Oscillator

- url: https://www.tradingview.com/script/f7wSYklx-Keltner-Channel-MTF-Oscillator/
- type: indicator
- pine_id: PUB;610eb9d93c994b2ea27c70e02a1fa637
- version: 1.0

## Description

[b]OVERVIEW[/b]

The Keltner Channel MTF Oscillator brings eight intraday Keltner Channels into one normalized oscillator pane, making it easier to compare trend, volatility, and price location across multiple timeframes without stacking indicators.

[b]INCLUDED TIMEFRAMES[/b]

• 1 minute
• 3 minutes
• 5 minutes
• 15 minutes
• 30 minutes
• 1 hour
• 2 hours
• 4 hours

Every timeframe can be enabled or disabled independently.

[b]HOW IT WORKS[/b]

Each channel uses an EMA centerline with ATR-based upper and lower bands. The EMA length, ATR length, ATR multiplier, and source are adjustable.

All plotted values are normalized against the 4-hour Keltner Channel:

• 4H upper band = +100
• 4H basis = 0
• 4H lower band = -100

The thick white line represents the current chart-timeframe price source. The colored envelopes display the upper band, basis, and lower band for each enabled timeframe.

[b]FEATURES[/b]

• Eight independently toggleable timeframes
• Colored multi-timeframe channel envelopes
• Optional basis lines and channel fills
• Adjustable EMA and ATR settings
• Optional strict -100 to +100 clamping
• Clear 4-hour reference levels
• Separate oscillator pane

[b]INTERPRETATION[/b]

Values above zero place price above the 4-hour Keltner basis, while values below zero place it beneath the basis. Readings near +100 approach the 4-hour upper channel, and readings near -100 approach the lower channel.

Channel compression can highlight volatility contraction. Expansion or separation between timeframe channels can help reveal increasing volatility or disagreement across timeframes.

When clamping is disabled, values may exceed +/-100, allowing breakouts beyond the 4-hour envelope to remain visible.

[b]NOTES[/b]

Higher-timeframe values can change until their corresponding candles close. Lower-timeframe information displayed on a higher-timeframe chart is sampled according to TradingView's multi-timeframe behavior.

This indicator is intended for informational and educational purposes only. It is not financial advice and does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Keltner Channel MTF Oscillator", shorttitle = "KC MTF Osc", overlay = false, precision = 1)

// =============================================================================
// Settings
// =============================================================================
string GROUP_KC      = "Keltner Settings"
string GROUP_TF      = "Visible Timeframes"
string GROUP_DISPLAY = "Display"

sourceInput = input.source(hlc3, "Source", group = GROUP_KC)
basisLength = input.int(20, "EMA Length", minval = 1, group = GROUP_KC)
atrLength   = input.int(10, "ATR Length", minval = 1, group = GROUP_KC)
multiplier  = input.float(2.0, "ATR Multiplier", minval = 0.1, step = 0.1, group = GROUP_KC)

show1m  = input.bool(true, "1 minute",  group = GROUP_TF, inline = "tf1")
show3m  = input.bool(true, "3 minutes", group = GROUP_TF, inline = "tf1")
show5m  = input.bool(true, "5 minutes", group = GROUP_TF, inline = "tf1")
show15m = input.bool(true, "15 minutes", group = GROUP_TF, inline = "tf2")
show30m = input.bool(true, "30 minutes", group = GROUP_TF, inline = "tf2")
show1h  = input.bool(true, "1 hour",  group = GROUP_TF, inline = "tf3")
show2h  = input.bool(true, "2 hours", group = GROUP_TF, inline = "tf3")
show4h  = input.bool(true, "4 hours", group = GROUP_TF, inline = "tf3")

showBasis = input.bool(true, "Show channel basis lines", group = GROUP_DISPLAY)
showFills = input.bool(true, "Fill channels", group = GROUP_DISPLAY)
clampToRange = input.bool(true, "Clamp all plots to -100...+100", group = GROUP_DISPLAY,
     tooltip = "When disabled, values beyond the 4-hour Keltner bounds can exceed +/-100.")

// =============================================================================
// Keltner calculations
// =============================================================================
f_keltner() =>
    float basis = ta.ema(sourceInput, basisLength)
    float offset = ta.atr(atrLength) * multiplier
    [basis, basis + offset, basis - offset]

// Every timeframe is calculated inside its own requested context.
[basis1m,  upper1m,  lower1m]  = request.security(syminfo.tickerid, "1",   f_keltner(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[basis3m,  upper3m,  lower3m]  = request.security(syminfo.tickerid, "3",   f_keltner(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[basis5m,  upper5m,  lower5m]  = request.security(syminfo.tickerid, "5",   f_keltner(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[basis15m, upper15m, lower15m] = request.security(syminfo.tickerid, "15",  f_keltner(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[basis30m, upper30m, lower30m] = request.security(syminfo.tickerid, "30",  f_keltner(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[basis1h,  upper1h,  lower1h]  = request.security(syminfo.tickerid, "60",  f_keltner(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[basis2h,  upper2h,  lower2h]  = request.security(syminfo.tickerid, "120", f_keltner(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[basis4h,  upper4h,  lower4h]  = request.security(syminfo.tickerid, "240", f_keltner(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// The 4-hour basis maps to 0; its lower and upper bounds map to -100 and +100.
// The 4-hour request remains active even when its channel is hidden because it
// is the normalization anchor for every other plot.
float anchorHalfRange = upper4h - basis4h

f_scale(float value) =>
    float normalized = not na(value) and not na(anchorHalfRange) and anchorHalfRange > 0.0 ?
         100.0 * (value - basis4h) / anchorHalfRange : na
    clampToRange and not na(normalized) ? math.max(-100.0, math.min(100.0, normalized)) : normalized

float chartLine = f_scale(sourceInput)

float b1m = f_scale(basis1m)
float u1m = f_scale(upper1m)
float l1m = f_scale(lower1m)
float b3m = f_scale(basis3m)
float u3m = f_scale(upper3m)
float l3m = f_scale(lower3m)
float b5m = f_scale(basis5m)
float u5m = f_scale(upper5m)
float l5m = f_scale(lower5m)
float b15m = f_scale(basis15m)
float u15m = f_scale(upper15m)
float l15m = f_scale(lower15m)
float b30m = f_scale(basis30m)
float u30m = f_scale(upper30m)
float l30m = f_scale(lower30m)
float b1h = f_scale(basis1h)
float u1h = f_scale(upper1h)
float l1h = f_scale(lower1h)
float b2h = f_scale(basis2h)
float u2h = f_scale(upper2h)
float l2h = f_scale(lower2h)
float b4h = f_scale(basis4h)
float u4h = f_scale(upper4h)
float l4h = f_scale(lower4h)

// =============================================================================
// Reference levels
// =============================================================================
hline(100,  "4H upper bound", color = color.new(color.red, 35), linestyle = hline.style_dashed)
hline(0,    "4H basis",       color = color.new(color.gray, 65), linestyle = hline.style_dotted)
hline(-100, "4H lower bound", color = color.new(color.lime, 35), linestyle = hline.style_dashed)

color color1m  = color.rgb(0, 188, 212)
color color3m  = color.rgb(33, 150, 243)
color color5m  = color.rgb(63, 81, 181)
color color15m = color.rgb(76, 175, 80)
color color30m = color.rgb(205, 190, 35)
color color1h  = color.rgb(255, 152, 0)
color color2h  = color.rgb(156, 39, 176)
color color4h  = color.rgb(244, 67, 54)

// Plot longest channels first so shorter channels remain legible on top.
p4hU = plot(show4h ? u4h : na, "4H Upper", color = color4h, linewidth = 1)
p4hB = plot(show4h and showBasis ? b4h : na, "4H Basis", color = color.new(color4h, 30), linewidth = 1)
p4hL = plot(show4h ? l4h : na, "4H Lower", color = color4h, linewidth = 1)
fill(p4hU, p4hL, color = show4h and showFills ? color.new(color4h, 94) : na, title = "4H Fill")

p2hU = plot(show2h ? u2h : na, "2H Upper", color = color2h, linewidth = 1)
p2hB = plot(show2h and showBasis ? b2h : na, "2H Basis", color = color.new(color2h, 30), linewidth = 1)
p2hL = plot(show2h ? l2h : na, "2H Lower", color = color2h, linewidth = 1)
fill(p2hU, p2hL, color = show2h and showFills ? color.new(color2h, 94) : na, title = "2H Fill")

p1hU = plot(show1h ? u1h : na, "1H Upper", color = color1h, linewidth = 1)
p1hB = plot(show1h and showBasis ? b1h : na, "1H Basis", color = color.new(color1h, 30), linewidth = 1)
p1hL = plot(show1h ? l1h : na, "1H Lower", color = color1h, linewidth = 1)
fill(p1hU, p1hL, color = show1h and showFills ? color.new(color1h, 94) : na, title = "1H Fill")

p30mU = plot(show30m ? u30m : na, "30m Upper", color = color30m, linewidth = 1)
p30mB = plot(show30m and showBasis ? b30m : na, "30m Basis", color = color.new(color30m, 30), linewidth = 1)
p30mL = plot(show30m ? l30m : na, "30m Lower", color = color30m, linewidth = 1)
fill(p30mU, p30mL, color = show30m and showFills ? color.new(color30m, 94) : na, title = "30m Fill")

p15mU = plot(show15m ? u15m : na, "15m Upper", color = color15m, linewidth = 1)
p15mB = plot(show15m and showBasis ? b15m : na, "15m Basis", color = color.new(color15m, 30), linewidth = 1)
p15mL = plot(show15m ? l15m : na, "15m Lower", color = color15m, linewidth = 1)
fill(p15mU, p15mL, color = show15m and showFills ? color.new(color15m, 94) : na, title = "15m Fill")

p5mU = plot(show5m ? u5m : na, "5m Upper", color = color5m, linewidth = 1)
p5mB = plot(show5m and showBasis ? b5m : na, "5m Basis", color = color.new(color5m, 30), linewidth = 1)
p5mL = plot(show5m ? l5m : na, "5m Lower", color = color5m, linewidth = 1)
fill(p5mU, p5mL, color = show5m and showFills ? color.new(color5m, 94) : na, title = "5m Fill")

p3mU = plot(show3m ? u3m : na, "3m Upper", color = color3m, linewidth = 1)
p3mB = plot(show3m and showBasis ? b3m : na, "3m Basis", color = color.new(color3m, 30), linewidth = 1)
p3mL = plot(show3m ? l3m : na, "3m Lower", color = color3m, linewidth = 1)
fill(p3mU, p3mL, color = show3m and showFills ? color.new(color3m, 94) : na, title = "3m Fill")

p1mU = plot(show1m ? u1m : na, "1m Upper", color = color1m, linewidth = 1)
p1mB = plot(show1m and showBasis ? b1m : na, "1m Basis", color = color.new(color1m, 30), linewidth = 1)
p1mL = plot(show1m ? l1m : na, "1m Lower", color = color1m, linewidth = 1)
fill(p1mU, p1mL, color = show1m and showFills ? color.new(color1m, 94) : na, title = "1m Fill")

// Current chart-timeframe source, intentionally drawn last and in white.
plot(chartLine, "Chart timeframe", color = color.white, linewidth = 3)
````
