# Hybrid Oscillator

- url: https://www.tradingview.com/script/l9b7NGh6-Hybrid-Oscillator/
- type: indicator
- pine_id: PUB;f765575fca504e8b9528a1122fe450f7
- version: 1.0

## Description

Hybrid Oscillator

Hybrid Oscillator is a visual oscillator designed to read momentum pressure, overbought conditions, oversold conditions, oscillator crosses, extreme zones and directional fading inside a separate chart pane.

the indicator combines a selected oscillator engine with a smoothed wave, a secondary cross line, gradient zones, level dots and alert conditions.

the goal is to help traders understand when momentum is expanding, when it is reaching an extreme area, when it is cooling down, and when the main oscillator line crosses its reference line.

this tool is not a trading strategy. it does not place trades, does not guarantee reversals and does not predict future price movement. it is a technical analysis tool for market context, momentum reading and visual confirmation.

main concept

the oscillator moves between 0 and 100.

values near the upper zone show stronger upside pressure or overbought conditions.

values near the lower zone show stronger downside pressure or oversold conditions.

the main oscillator line is the active momentum wave.

the real cross line is a smoother reference line.

when the main oscillator crosses above the real cross line, momentum may be recovering or shifting upward.

when the main oscillator crosses below the real cross line, momentum may be weakening or shifting downward.

what the indicator displays

main oscillator line

real cross line

upper and lower gradient zones

overbought level

oversold level

extreme overbought level

extreme oversold level

mid upper level

mid lower level

top extreme dots

bottom extreme dots

real cross dots

level lines

alert conditions

oscillator engines

the script includes several oscillator calculation modes.

rsi

uses relative strength index behavior.

this mode is useful for reading classic momentum strength and overbought or oversold behavior.

stochastic

uses stochastic positioning.

this mode focuses on where price is closing compared to its recent high and low range.

hybrid rsi plus stochastic

uses rsi first, then applies a stochastic calculation to the rsi behavior.

this mode focuses on momentum position inside the rsi range and gives a more reactive exhaustion style.

cci normalized

uses commodity channel index behavior and normalizes it into a 0 to 100 style range.

this mode can be useful for reading broader deviation and momentum pressure.

how the real cross line works

the real cross line is a smoothed version of the active oscillator.

it is not a separate oscillator type. it follows the selected engine.

if rsi mode is selected, the cross line follows the rsi-based oscillator.

if stochastic mode is selected, the cross line follows the stochastic-based oscillator.

if hybrid mode is selected, the cross line follows the hybrid oscillator.

if cci normalized mode is selected, the cross line follows the normalized cci oscillator.

the cross dots are based on the actual intersection between the main oscillator and the real cross line.

orange cross dots show an upward cross.

magenta cross dots show a downward cross.

input guide

source

selects the price source used by the oscillator.

common choices are close, hl2, hlc3 or ohlc4.

close is simple and reactive.

hlc3 is smoother because it includes high, low and close.

length

controls the base oscillator calculation period.

a lower value makes the oscillator faster and more sensitive.

a higher value makes the oscillator smoother and slower.

smoothing

controls the smoothing applied to the final oscillator.

a lower value reacts faster.

a higher value reduces noise but adds more delay.

oscillator type

selects the calculation engine.

rsi is classic momentum.

stochastic is range position.

hybrid rsi plus stochastic is a more sensitive momentum range model.

cci normalized is a deviation-based momentum model.

extreme overbought

sets the upper extreme zone.

when the oscillator reaches this area, upside momentum is considered stretched.

overbought

sets the main upper warning level.

crossing this level can mark a strong bullish extension.

mid upper

sets the upper midline reference.

this can be used to detect smaller upward crosses around the upper balance area.

mid lower

sets the lower midline reference.

this can be used to detect smaller downward crosses around the lower balance area.

oversold

sets the main lower warning level.

crossing this level can mark a strong bearish extension.

extreme oversold

sets the lower extreme zone.

when the oscillator reaches this area, downside momentum is considered stretched.

enable gradient fills

turns the upper and lower visual gradient zones on or off.

when enabled, the oscillator pane becomes easier to read visually.

gradient layers

controls the number of visual layers used for the gradient style.

more layers create a smoother visual feel.

show level cross dots

shows or hides the dots created by cross conditions and extreme conditions.

show real cross line

shows or hides the smoother cross reference line.

this line is useful when you want to see exactly where the oscillator cross dots come from.

show level lines

shows or hides the horizontal reference lines.

these lines help identify overbought, oversold, extreme and midpoint areas.

oscillator line width

controls the thickness of the main oscillator line.

higher values make the oscillator more visible.

lower values keep the chart cleaner.

how to read the dots

top extreme dots

these appear when the oscillator is inside the extreme overbought zone.

they indicate strong upside extension.

they do not mean price must reverse immediately.

bottom extreme dots

these appear when the oscillator is inside the extreme oversold zone.

they indicate strong downside extension.

they do not mean price must reverse immediately.

orange cross dots

these appear when the main oscillator crosses above the real cross line.

they can show a possible upward momentum shift.

magenta cross dots

these appear when the main oscillator crosses below the real cross line.

they can show a possible downward momentum shift.

important note about dots

cross dots are not automatic buy or sell signals.

they show technical events inside the oscillator.

always confirm with trend, support and resistance, candle close, volume and risk management.

alerts

the script includes alert conditions for:

cross above the real cross line

cross below the real cross line

cross above overbought

cross below oversold

cross above extreme overbought

cross below extreme oversold

recommended beginner alert use

start with real cross up and real cross down.

use overbought and oversold alerts only as context.

use extreme alerts as exhaustion warnings, not direct trade signals.

avoid activating every alert at once if you want a clean workflow.

beginner tutorial

step 1: start with the default oscillator type

begin with hybrid rsi plus stochastic.

this mode gives a balanced view between momentum and range behavior.

step 2: keep the default levels

use the default overbought, oversold and extreme levels first.

do not change too many settings before understanding the oscillator behavior.

step 3: enable the real cross line

turn on the real cross line to see where cross dots come from.

when the oscillator crosses above the line, upward momentum may be improving.

when the oscillator crosses below the line, momentum may be weakening.

step 4: read the zones

above overbought, the market is showing strong upside momentum.

below oversold, the market is showing strong downside momentum.

inside the middle area, the market is more balanced.

step 5: read extremes carefully

extreme overbought can show strong bullish pressure.

extreme oversold can show strong bearish pressure.

an extreme does not guarantee a reversal.

strong markets can stay extreme longer than expected.

step 6: confirm with price action

before using any oscillator event, check the main chart.

look for:

trend direction

support and resistance

market structure

candle close

volume reaction

higher timeframe context

risk to reward

step 7: keep the chart clean

do not use every signal as an entry.

focus on the main oscillator, real cross line, extreme zones and a few important dots.

example 1: upward cross from the lower zone

the oscillator is near the oversold area.

then it crosses above the real cross line.

an orange dot appears at the real cross.

this can suggest that downside momentum is cooling and upward pressure may be starting.

a beginner should wait for price confirmation, such as a higher low, bullish candle close or break of short-term resistance.

example 2: downward cross from the upper zone

the oscillator is near the overbought area.

then it crosses below the real cross line.

a magenta dot appears at the real cross.

this can suggest that upside momentum is weakening.

a beginner should wait for price confirmation, such as rejection, lower high or break of short-term support.

example 3: extreme overbought continuation

the oscillator reaches the extreme overbought zone.

top extreme dots appear.

this means momentum is very strong to the upside.

it does not mean a sell signal is confirmed.

in a strong trend, the oscillator can remain high while price continues moving upward.

example 4: extreme oversold continuation

the oscillator reaches the extreme oversold zone.

bottom extreme dots appear.

this means momentum is very strong to the downside.

it does not mean a buy signal is confirmed.

in a strong downtrend, the oscillator can remain low while price continues moving downward.

example 5: using the cross line for timing

price is near support.

the oscillator is low.

the oscillator crosses above the real cross line.

an orange dot appears.

this can be used as an early momentum recovery warning, but the trader should still wait for price structure confirmation before making a decision.

example 6: using overbought as context

price is in an uptrend.

the oscillator crosses above the overbought level.

this confirms strong bullish pressure.

instead of shorting immediately, a beginner can watch for continuation or wait for a later loss of momentum.

best use cases

momentum reading

overbought and oversold context

detecting oscillator cross events

watching exhaustion zones

supporting reversal analysis

supporting trend continuation analysis

building alert-based watchlists

confirming price action with momentum context

recommended beginner setup

oscillator type: hybrid rsi plus stochastic

length: 14

smoothing: 3

show real cross line: on

show level cross dots: on

show level lines: on

enable gradient fills: on

use cross dots as warnings

use extreme dots as context

confirm every idea on the price chart

practical workflow

first, identify the current trend on the main chart.

second, check whether the oscillator is near the upper, middle or lower zone.

third, watch the real cross line.

fourth, note any orange or magenta cross dot.

fifth, check whether price confirms the oscillator event.

sixth, define invalidation and risk before any trade idea.

seventh, avoid taking signals against a strong trend without extra confirmation.

limitations

the oscillator is based on historical price data.

signals can appear late during fast moves.

extreme zones can stay extreme during strong trends.

cross dots are momentum events, not guaranteed reversals.

the tool should not be used alone.

risk note

this indicator is designed for technical analysis and educational market study. it does not provide financial advice, investment advice or guaranteed trading signals. all dots, levels, crosses, alerts and visual zones are references that require independent confirmation and proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("HYDRID OSCILLATOR", "HOSC", overlay=false,
     precision=2, max_labels_count=300, max_lines_count=300)

// ════════════════════════════════════════════════════════════════════════════
// THEME
// ════════════════════════════════════════════════════════════════════════════
var color C_BG          = #050816
var color C_LINE        = #6c6cff 
var color C_LINE_GLOW   = #4040c8

var color C_BULL_TOP    = #00ff66
var color C_BULL_MID    = #00b347
var color C_BULL_FADE   = #003311

var color C_BEAR_BOT    = #ff1a8a 
var color C_BEAR_MID    = #c4156a
var color C_BEAR_FADE   = #330018 

var color C_DOT_EXT_BULL = #00ff66     
var color C_DOT_OB       = #ffaa00     
var color C_DOT_OS       = #ff4dcb     
var color C_DOT_EXT_BEAR = #ff3344     

var color C_GRID         = #1a2750
var color C_NEUTRAL      = #3a4870

// ════════════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════════════
gO = "⟦ OSCILLATOR ENGINE ⟧"
src       = input.source(close, "Source", group=gO)
oscLen    = input.int(14, "Length", minval=2, group=gO)
smoothLen = input.int(3,  "Smoothing", minval=1, group=gO)
oscType   = input.string("Hybrid RSI+Stoch", "Oscillator Type",
     options=["RSI", "Stochastic", "Hybrid RSI+Stoch", "CCI normalized"], group=gO)

gL = "⟦ LEVELS ⟧"
ext_ob   = input.int(80, "Extreme Overbought", minval=70, maxval=95, group=gL)
ob_lvl   = input.int(65, "Overbought",         minval=55, maxval=80, group=gL)
mid_up   = input.int(55, "Mid Upper",          minval=50, maxval=60, group=gL)
mid_lo   = input.int(45, "Mid Lower",          minval=40, maxval=50, group=gL)
os_lvl   = input.int(35, "Oversold",           minval=20, maxval=45, group=gL)
ext_os   = input.int(20, "Extreme Oversold",   minval=5,  maxval=30, group=gL)

gV = "⟦ VISUAL ⟧"
showGradient = input.bool(true, "Enable gradient fills", group=gV)
gradientLayers = input.int(8, "Gradient layers (more = smoother)", minval=4, maxval=12, group=gV)
showDots     = input.bool(false, "Show level cross dots", group=gV)
showCrossLine = input.bool(false, "Show real cross line", group=gV)
showGrid     = input.bool(true, "Show level lines", group=gV)
lineWidth    = input.int(2, "Oscillator line width", minval=1, maxval=4, group=gV)

// ════════════════════════════════════════════════════════════════════════════
// OSCILLATOR CALCULATION
// ════════════════════════════════════════════════════════════════════════════
rsiRaw = ta.rsi(src, oscLen)
stochRaw = ta.stoch(src, high, low, oscLen)
hybridRaw = ta.stoch(rsiRaw, rsiRaw, rsiRaw, oscLen)
cciRaw = ta.cci(src, oscLen)
cciNorm = 50 + math.max(-50, math.min(50, cciRaw / 4))
oscRaw = oscType == "RSI" ? rsiRaw : oscType == "Stochastic" ? stochRaw : oscType == "Hybrid RSI+Stoch" ? hybridRaw : cciNorm
osc = ta.ema(oscRaw, smoothLen)
realCrossLine = ta.ema(osc, smoothLen + 2)

// ════════════════════════════════════════════════════════════════════════════
// GLOBAL CROSS CALCULATIONS
// ════════════════════════════════════════════════════════════════════════════
realCrossUp = ta.crossover(osc, realCrossLine)
realCrossDn = ta.crossunder(osc, realCrossLine)
obCrossUp = ta.crossover(osc, ob_lvl)
osCrossDn = ta.crossunder(osc, os_lvl)
extObCrossUp = ta.crossover(osc, ext_ob)
extOsCrossDn = ta.crossunder(osc, ext_os)
crossDen = (osc - osc[1]) - (realCrossLine - realCrossLine[1])
crossFracRaw = crossDen != 0 ? (realCrossLine[1] - osc[1]) / crossDen : 1.0
crossFrac = math.max(0.0, math.min(1.0, crossFracRaw))
crossY = osc[1] + (osc - osc[1]) * crossFrac

// ════════════════════════════════════════════════════════════════════════════
// LEVEL LINES
// ════════════════════════════════════════════════════════════════════════════
plot(showGrid ? ext_ob : na, "Extreme OB", color=color.new(C_BULL_TOP, 70), linewidth=1, style=plot.style_line)
plot(showGrid ? ob_lvl : na, "OB",         color=color.new(C_BULL_MID, 75), linewidth=1, style=plot.style_line)
plot(showGrid ? 50 : na,     "Mid",        color=color.new(C_NEUTRAL, 60),  linewidth=1, style=plot.style_line)
plot(showGrid ? os_lvl : na, "OS",         color=color.new(C_BEAR_MID, 75), linewidth=1, style=plot.style_line)
plot(showGrid ? ext_os : na, "Extreme OS", color=color.new(C_BEAR_BOT, 70), linewidth=1, style=plot.style_line)
plot(showGrid ? 0 : na,      "Floor",      color=color.new(C_GRID, 80),     linewidth=1, style=plot.style_line)
plot(showGrid ? 100 : na,    "Ceil",       color=color.new(C_GRID, 80),     linewidth=1, style=plot.style_line)

// ════════════════════════════════════════════════════════════════════════════
// GRADIENT FILLS
// ════════════════════════════════════════════════════════════════════════════
oscPlot = plot(osc, "Oscillator", color=color.new(C_LINE, 0), linewidth=lineWidth)

plot(osc, "Glow1", color=color.new(C_LINE_GLOW, 80), linewidth=lineWidth + 2)
plot(osc, "Glow2", color=color.new(C_LINE_GLOW, 90), linewidth=lineWidth + 4)
plot(showCrossLine ? realCrossLine : na, "Real Cross Line", color=color.new(C_DOT_OB, 0), linewidth=1)

top100 = plot(showGradient ? 100 : na, "Top",    color=color.new(C_BULL_TOP, 100), display=display.none)
ob_p   = plot(showGradient ? ob_lvl : na, "OB",  color=color.new(C_BULL_TOP, 100), display=display.none)
mid_p  = plot(showGradient ? 50 : na, "Mid",     color=color.new(C_NEUTRAL,  100), display=display.none)
os_p   = plot(showGradient ? os_lvl : na, "OS",  color=color.new(C_BEAR_BOT, 100), display=display.none)
bot0   = plot(showGradient ? 0 : na, "Bot",      color=color.new(C_BEAR_BOT, 100), display=display.none)

fill(oscPlot, top100,
     top_value    = 100,
     bottom_value = ob_lvl,
     top_color    = color.new(C_BULL_TOP, 30),
     bottom_color = color.new(C_BULL_TOP, 92),
     title        = "Bull Gradient")

fill(oscPlot, bot0,
     top_value    = os_lvl,
     bottom_value = 0,
     top_color    = color.new(C_BEAR_BOT, 92),
     bottom_color = color.new(C_BEAR_BOT, 30),
     title        = "Bear Gradient")

fill(oscPlot, top100,
     top_value    = 100,
     bottom_value = 70,
     top_color    = color.new(C_BULL_MID, 65),
     bottom_color = color.new(C_BULL_MID, 95),
     title        = "Bull Glow")

fill(oscPlot, bot0,
     top_value    = 30,
     bottom_value = 0,
     top_color    = color.new(C_BEAR_MID, 95),
     bottom_color = color.new(C_BEAR_MID, 65),
     title        = "Bear Glow")

// ════════════════════════════════════════════════════════════════════════════
// LEVEL CROSS DOTS
// ════════════════════════════════════════════════════════════════════════════
plotshape(showDots and osc >= ext_ob and osc[1] < ext_ob,
     "Extreme OB", shape.circle, location.top,
     color=C_DOT_EXT_BULL, size=size.tiny)

plot(showDots and showCrossLine and realCrossUp ? crossY : na,
     "Real cross up dot", color=C_DOT_OB, style=plot.style_circles, linewidth=4)

plot(showDots and showCrossLine and realCrossDn ? crossY : na,
     "Real cross down dot", color=C_DOT_OS, style=plot.style_circles, linewidth=4)

plotshape(showDots and osc >= ext_ob,
     "Top extreme", shape.circle, location.top,
     color=C_DOT_EXT_BULL, size=size.tiny)

plotshape(showDots and osc <= ext_os,
     "Bot extreme", shape.circle, location.bottom,
     color=C_DOT_EXT_BEAR, size=size.tiny)

// ════════════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════════════
alertcondition(realCrossUp, "Real Cross Up", "⟦HOSC⟧ Oscillator crossed above the real cross line")
alertcondition(realCrossDn, "Real Cross Down", "⟦HOSC⟧ Oscillator crossed below the real cross line")
alertcondition(obCrossUp,  "Cross OB",  "⟦HOSC⟧ Crossed overbought")
alertcondition(osCrossDn, "Cross OS",  "⟦HOSC⟧ Crossed oversold")
alertcondition(extObCrossUp,  "Extreme OB","⟦HOSC⟧ Extreme overbought")
alertcondition(extOsCrossDn, "Extreme OS","⟦HOSC⟧ Extreme oversold")
````
