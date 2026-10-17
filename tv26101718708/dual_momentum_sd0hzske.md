# DUAL MOMENTUM

- url: https://www.tradingview.com/script/sd0HzSke-DUAL-MOMENTUM/
- type: indicator
- pine_id: PUB;0d3f11f18e714963aef163259a28632f
- version: 1.0

## Description

dual momentum

dual momentum is a visual momentum oscillator built to compare a fast momentum line and a slow momentum line inside a symmetric oscillator range.

the goal of this tool is to help traders read momentum expansion, momentum compression, bullish pressure, bearish pressure, crossovers, overbought areas and oversold areas in a clean separate pane.

this indicator is not a strategy and does not place trades. it does not predict the future and does not guarantee buy or sell signals. it is designed as a technical analysis tool for reading momentum context.

main idea

dual momentum uses a normalized price calculation to transform price movement into a bounded oscillator.

the fast line reacts more quickly to price movement.

the slow line reacts more slowly and gives a smoother momentum reference.

when the fast line is above the slow line, momentum is generally stronger on the bullish side.

when the fast line is below the slow line, momentum is generally stronger on the bearish side.

the distance between both lines helps show whether momentum is expanding or compressing.

what the indicator displays

fast momentum line

slow momentum line

bullish and bearish gradient fill

fast and slow spread ribbon

higher and lower flow bands

bull and bear rails

optional cross triangles

ob and os text markers

glow effect

separate buy and sell alert conditions

how to read the oscillator

the oscillator is centered around zero.

above zero, momentum is generally stronger.

below zero, momentum is generally weaker.

when the fast line crosses above the slow line, bullish momentum may be increasing.

when the fast line crosses below the slow line, bearish momentum may be increasing.

when both lines are far from zero, momentum is extended.

when both lines return toward zero, momentum is cooling down.

input guide

engine

source

selects the price source used for the main calculation.

common choices are close, open, high, low, hl2, hlc3 or ohlc4.

normalization window

sets how many bars are used to normalize price movement.

a higher value creates a smoother and more stable oscillator.

a lower value makes the oscillator more reactive but also more sensitive to noise.

fast smoothing

controls the speed of the fast momentum line.

lower values make the fast line react quickly.

higher values make the fast line smoother.

slow smoothing

controls the speed of the slow momentum line.

lower values make the slow line more reactive.

higher values make the slow line smoother and slower.

amplitude

controls how much the oscillator expands vertically.

higher values make the lines move farther from zero.

lower values keep the lines closer to the center.

range cap

sets the maximum positive and negative range of the oscillator.

this keeps the display symmetrical and prevents the lines from expanding too far.

flow bands

show higher / lower bands

shows or hides the upper and lower flow bands.

these bands help visualize where the oscillator is moving inside its higher and lower zones.

band length

sets the calculation length used for the flow bands.

a higher value makes the bands smoother.

a lower value makes the bands more reactive.

band smoothing

smooths the flow band calculation.

higher smoothing reduces noise.

lower smoothing reacts faster.

band inner edge

controls how deep the flow bands extend toward the center.

higher values create tighter bands.

lower values create larger bands.

bull / bear fill

gradient fill under line

shows or hides the bull and bear gradient fill around the oscillator.

this fill helps identify whether the oscillator is leaning bullish or bearish.

gradient transparency

controls the visibility of the gradient fill.

higher values make the fill lighter.

lower values make the fill stronger.

fast / slow spread ribbon

shows the colored ribbon between the fast and slow lines.

when fast is above slow, the ribbon uses the bullish color.

when fast is below slow, the ribbon uses the bearish color.

ribbons

show bull / bear rails

shows or hides the rail markers at the top and bottom of the oscillator pane.

these rails help show when the fast and slow spread becomes strong enough.

rail min strength

sets the minimum strength required before the rails appear.

higher values show fewer rail signals.

lower values show more rail signals.

signals

show cross triangles

shows or hides triangle markers when the fast line crosses the slow line.

this input is off by default to keep the chart cleaner.

show ob / os text

shows or hides overbought and oversold text markers.

the script displays only text markers, without boxes.

ob text appears above the upper rail.

os text appears below the lower rail.

overbought level

sets the level where the script can mark an ob event.

an ob event appears when the fast line crosses above this level.

oversold level

sets the level where the script can mark an os event.

an os event appears when the fast line crosses below this level.

glow

neon glow

shows or hides the glow around the fast and slow lines.

glow intensity

controls the strength of the glow.

higher values make the glow stronger.

lower values make it softer.

colors

fast / bull color

sets the color of the fast line and bullish visuals.

slow / bear color

sets the color of the slow line and bearish visuals.

buy triangle color

sets the color of the bullish triangle when cross triangles are enabled.

ob / os gold

sets the color of the ob and os text markers.

signals and alerts

buy condition

a buy condition happens when the fast line crosses above the slow line.

this does not mean automatic entry.

it only means the fast momentum line moved above the slow momentum line.

sell condition

a sell condition happens when the fast line crosses below the slow line.

this does not mean automatic exit or short entry.

it only means the fast momentum line moved below the slow momentum line.

ob condition

an ob condition happens when the fast line crosses above the overbought level.

this can show strong upside extension.

os condition

an os condition happens when the fast line crosses below the oversold level.

this can show strong downside extension.

beginner tutorial

step 1: start with the default settings

keep the default settings at first.

the default setup gives a balanced view between speed and smoothness.

step 2: watch the fast and slow lines

the fast line reacts first.

the slow line confirms the broader momentum direction.

when fast is above slow, bullish momentum is stronger.

when fast is below slow, bearish momentum is stronger.

step 3: use the zero line as balance

when both lines are above zero, momentum is generally positive.

when both lines are below zero, momentum is generally negative.

when both lines are close to zero, the market may be neutral or compressing.

step 4: read the spread ribbon

the ribbon between fast and slow shows the momentum spread.

a wider ribbon means stronger separation.

a smaller ribbon means momentum is compressing.

step 5: read the rails

rails appear when the fast and slow difference becomes strong enough.

bull rails show stronger bullish spread.

bear rails show stronger bearish spread.

step 6: use ob and os as extension warnings

ob means the fast line has reached an overbought extension area.

os means the fast line has reached an oversold extension area.

these markers are not automatic reversal signals.

they only show that momentum reached an extreme area.

step 7: use cross triangles only when needed

cross triangles are off by default.

turn them on only if you want visual markers for fast and slow crosses.

for a cleaner chart, keep them disabled and focus on the lines and ribbon.

step 8: confirm with price action

before using any signal, check the price chart.

look for trend direction, support and resistance, market structure, candle close and volume reaction.

do not use the oscillator alone.

example 1: bullish momentum shift

the fast line crosses above the slow line.

the spread ribbon turns bullish.

the oscillator is moving above zero.

this can suggest that bullish momentum is increasing.

a beginner should then check if price is also making higher highs or higher lows.

example 2: bearish momentum shift

the fast line crosses below the slow line.

the spread ribbon turns bearish.

the oscillator is moving below zero.

this can suggest that bearish momentum is increasing.

a beginner should then check if price is also making lower highs or lower lows.

example 3: overbought extension

the fast line crosses above the overbought level.

the script prints ob text above the rail.

this means momentum is stretched upward.

it does not mean price must reverse immediately.

a beginner should wait for rejection, loss of momentum or a structure shift before making any decision.

example 4: oversold extension

the fast line crosses below the oversold level.

the script prints os text below the rail.

this means momentum is stretched downward.

it does not mean price must reverse immediately.

a beginner should wait for support reaction, momentum recovery or a structure shift before making any decision.

example 5: compression before expansion

the fast and slow lines move close together near zero.

the spread ribbon becomes small.

this can show momentum compression.

if the fast line later separates strongly from the slow line, momentum may begin expanding again.

recommended beginner workflow

first, identify the market trend on the price chart.

second, check whether the oscillator is above or below zero.

third, compare the fast line with the slow line.

fourth, read the spread ribbon.

fifth, check for ob or os extension.

sixth, confirm with support, resistance, structure and candle close.

seventh, define risk before any trade idea.

best use cases

reading momentum direction

spotting momentum expansion

spotting momentum compression

watching fast and slow line crosses

identifying overbought and oversold extensions

supporting trend continuation analysis

supporting reversal watch zones

building simple momentum alerts

important notes

ob does not automatically mean sell.

os does not automatically mean buy.

cross triangles are only visual momentum markers.

the oscillator should be used with price action and risk management.

higher settings make the tool smoother.

lower settings make the tool faster.

no indicator can guarantee future market direction.

risk note

this indicator is for technical analysis and educational market study only. it does not provide financial advice, investment advice or guaranteed trading signals. all signals, levels, labels and alerts are references that require independent confirmation and proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("DUAL MOMENTUM", overlay = false)

// ───────────────────────────── INPUTS ──────────────────────────────────
gE = "🌊 ENGINE"
src      = input.source(close, "Source", group = gE)
zlen     = input.int(50, "Normalization Window", minval = 10, group = gE)
lenFast  = input.int(4,  "Fast Smoothing", minval = 1, maxval = 50, group = gE)
lenSlow  = input.int(16, "Slow Smoothing", minval = 2, maxval = 100, group = gE)
ampl     = input.float(58, "Amplitude", minval = 10, maxval = 150, group = gE)
rangeMax = input.int(150, "Range Cap (±)", minval = 60, maxval = 300, group = gE)

gB = "🌊 FLOW BANDS"
showBand  = input.bool(true, "Show Higher / Lower Bands", group = gB)
subLen    = input.int(40, "Band Length", minval = 5, group = gB)
subSmooth = input.int(10, "Band Smoothing", minval = 1, group = gB)
bandInner = input.int(48, "Band Inner Edge", minval = 20, group = gB)

gF = "🎚️ BULL / BEAR FILL"
showGrad   = input.bool(true, "Gradient Fill (under line)", group = gF)
gradTransp = input.int(80, "Gradient Transparency", minval = 40, maxval = 95, group = gF)
showSpread = input.bool(true, "Fast/Slow Spread Ribbon", group = gF)

gR = "📊 RIBBONS"
showRibbon = input.bool(true, "Show Bull / Bear Rails", group = gR)
railThresh = input.float(0.05, "Rail Min Strength", minval = 0.0, maxval = 0.5, step = 0.01, group = gR)

gS = "🎯 SIGNALS"
showSignals = input.bool(false, "Show Cross Triangles", group = gS)
showOB      = input.bool(false, "Show OB / OS Text", group = gS)
obT         = input.int(105,  "Overbought Level", minval = 50, group = gS)
osT         = input.int(-105, "Oversold Level",   maxval = -50, group = gS)

gG = "✨ GLOW"
showGlow = input.bool(false, "Neon Glow", group = gG)
glowAmt  = input.float(1.0, "Glow Intensity", minval = 0.2, maxval = 2.0, step = 0.1, group = gG)

gC = "🎨 COLORS"
cFast = input.color(color.rgb(20, 224, 210), "Fast / Bull (cyan)", group = gC)
cSlow = input.color(color.rgb(242, 59, 92),  "Slow / Bear (red)", group = gC)
cUp   = input.color(color.rgb(43, 255, 140), "Buy Triangle", group = gC)
cGold = input.color(color.rgb(245, 197, 24), "OB / OS Gold", group = gC)

// ───────────────────────────── HELPERS ─────────────────────────────────
clampV(x, lo, hi) => math.max(lo, math.min(hi, x))
clampT(x) => int(math.max(0, math.min(100, x)))

// ───────────────────── GEOMETRY (symmetric) ────────────────────────────
lineCap   = rangeMax - 30
railY     = rangeMax - 5
bandOuter = lineCap - 2

// ──────────────────────── OSCILLATOR ENGINE ────────────────────────────
basis = ta.ema(src, zlen)
dev   = ta.stdev(src, zlen)
z     = dev > 0 ? (src - basis) / dev : 0
zs    = ta.ema(z, 3)
fast  = clampV(ta.ema(zs, lenFast) * ampl, -lineCap, lineCap)
slow  = clampV(ta.ema(zs, lenSlow) * ampl, -lineCap, lineCap)

// symmetric flow bands
flow  = ta.ema(ta.stoch(close, high, low, subLen), subSmooth) / 100
hiEdge =  bandOuter - flow * (bandOuter - bandInner)
loEdge = -bandOuter + flow * (bandOuter - bandInner)

// ───────────────────────── SCALE ANCHORS ───────────────────────────────
plot(rangeMax + 10,  "anchU", color = color.new(color.gray, 100), display = display.none)
plot(-rangeMax - 10, "anchL", color = color.new(color.gray, 100), display = display.none)

// ───────────────── SYMMETRIC HIGHER / LOWER BANDS ───────────────────────
pHiTop  = plot(showBand ? bandOuter : na, "Hi Top",  display = display.none)
pHiEdge = plot(showBand ? hiEdge : na,    "Hi Edge", display = display.none)
pLoBot  = plot(showBand ? -bandOuter : na,"Lo Bot",  display = display.none)
pLoEdge = plot(showBand ? loEdge : na,    "Lo Edge", display = display.none)
fill(pHiTop, pHiEdge, top_value = bandOuter, bottom_value = bandInner, top_color = color.new(cFast, 58), bottom_color = color.new(cFast, 90), title = "Higher Band")
fill(pLoEdge, pLoBot, top_value = -bandInner, bottom_value = -bandOuter, top_color = color.new(cSlow, 90), bottom_color = color.new(cSlow, 58), title = "Lower Band")

// ───────────────── PRO BULL / BEAR GRADIENT FILL ───────────────────────
p0       = plot(0, "Zero", color = color.new(color.gray, 84), linewidth = 1)
pFastRef = plot(fast, "FastRef", display = display.none)
pSlowRef = plot(slow, "SlowRef", display = display.none)
gt = showGrad ? gradTransp : 100
fill(pFastRef, p0, top_value = lineCap, bottom_value = -lineCap, top_color = color.new(cFast, gt), bottom_color = color.new(cSlow, gt), title = "Bull/Bear Gradient")
spreadCol = fast >= slow ? color.new(cFast, 70) : color.new(cSlow, 70)
fill(pFastRef, pSlowRef, color = showSpread ? spreadCol : color.new(color.gray, 100), title = "Spread Ribbon")

// ─────────────────── GLOW + CORE MAIN LINES ────────────────────────────
g = glowAmt
plot(showGlow ? slow : na, "Slow Glow 3", color = color.new(color.white, clampT(90 - 5  * g)), linewidth = 9)
plot(showGlow ? slow : na, "Slow Glow 2", color = color.new(color.white, clampT(82 - 8  * g)), linewidth = 6)
plot(showGlow ? slow : na, "Slow Glow 1", color = color.new(color.white, clampT(72 - 11 * g)), linewidth = 4)
plot(slow, "Slow", color = color.new(cSlow, 0), linewidth = 3)
plot(showGlow ? fast : na, "Fast Glow 3", color = color.new(color.white, clampT(90 - 5  * g)), linewidth = 9)
plot(showGlow ? fast : na, "Fast Glow 2", color = color.new(color.white, clampT(82 - 8  * g)), linewidth = 6)
plot(showGlow ? fast : na, "Fast Glow 1", color = color.new(color.white, clampT(72 - 11 * g)), linewidth = 4)
plot(fast, "Fast", color = color.new(cFast, 0), linewidth = 3)

// ───────────────── GLOSSY BULL / BEAR RAILS (bounds) ────────────────────
diff = fast - slow
bull = diff >= 0
str  = clampV(math.abs(diff) / (rangeMax * 0.7), 0, 1)
tShow = showRibbon and bull and str > railThresh
bShow = showRibbon and (not bull) and str > railThresh
topCol    = color.from_gradient(str, 0, 1, color.rgb(20, 150, 110), cFast)
botCol    = color.from_gradient(str, 0, 1, color.rgb(120, 25, 45), cSlow)
topBright = color.from_gradient(str, 0, 1, cFast, color.rgb(210, 255, 248))
botBright = color.from_gradient(str, 0, 1, cSlow, color.rgb(255, 200, 210))
plotshape(tShow ? railY : na,  "Top Glow", shape.square, location.absolute, color = color.new(topCol, clampT(76 - str * 28)), size = size.normal)
plotshape(bShow ? -railY : na, "Bot Glow", shape.square, location.absolute, color = color.new(botCol, clampT(76 - str * 28)), size = size.normal)
plotshape(tShow ? railY : na,  "Top Body", shape.square, location.absolute, color = color.new(topCol, clampT(48 - str * 28)), size = size.small)
plotshape(bShow ? -railY : na, "Bot Body", shape.square, location.absolute, color = color.new(botCol, clampT(48 - str * 28)), size = size.small)
plotshape(tShow ? railY : na,  "Top Core", shape.square, location.absolute, color = color.new(topBright, clampT(18 - str * 14)), size = size.tiny)
plotshape(bShow ? -railY : na, "Bot Core", shape.square, location.absolute, color = color.new(botBright, clampT(18 - str * 14)), size = size.tiny)

// ─────────────── CROSS TRIANGLES (printed at the cross) ─────────────────
fastCrossDn = ta.crossunder(fast, slow)
fastCrossUp = ta.crossover(fast, slow)
sellSig = showSignals and barstate.isconfirmed and fastCrossDn
buySig  = showSignals and barstate.isconfirmed and fastCrossUp
plotshape(sellSig ? fast + 7 : na, "Sell", shape.triangledown, location.absolute, color = color.new(cSlow, 0), size = size.tiny)
plotshape(buySig ? fast - 7 : na,  "Buy",  shape.triangleup,   location.absolute, color = color.new(cUp, 0),   size = size.tiny)
alertcondition(sellSig, "DUAL — SELL", "Fast crossed below Slow")
alertcondition(buySig,  "DUAL — BUY",  "Fast crossed above Slow")

// ─────────────────────── OB / OS TEXT ONLY ─────────────────────────────
var label[] obLab = array.new<label>()
obCrossUp = ta.crossover(fast, obT)
osCrossDn = ta.crossunder(fast, osT)
obEvent = showOB and barstate.isconfirmed and obCrossUp
osEvent = showOB and barstate.isconfirmed and osCrossDn
if obEvent
    l = label.new(bar_index + 2, railY + 14, "OB", style = label.style_none, textcolor = cGold, size = size.tiny)
    array.push(obLab, l)
if osEvent
    l = label.new(bar_index + 2, -railY - 14, "OS", style = label.style_none, textcolor = cGold, size = size.tiny)
    array.push(obLab, l)
if array.size(obLab) > 14
    label.delete(array.shift(obLab))
````
