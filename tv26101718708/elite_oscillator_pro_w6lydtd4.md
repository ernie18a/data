# Elite Oscillator Pro

- url: https://www.tradingview.com/script/W6LydTd4-Elite-Oscillator-Pro/
- type: indicator
- pine_id: PUB;fe2841686a58471093d5586e41e1deaa
- version: 1.0

## Description

Elite Oscillator Pro is a visual momentum oscillator designed to provide a cleaner reading of overbought, oversold, neutral, and momentum-transition conditions in a separate oscillator pane.

The script can calculate its base oscillator using either Stochastic or RSI logic. The selected oscillator is then processed through a two-step smoothing engine to reduce short-term noise and make momentum transitions easier to read visually.

The goal of this indicator is not to predict future price movement or generate automatic trading instructions. It is intended as a visual analysis tool that helps users observe momentum structure, oscillator regime changes, and transitions around predefined levels.

Main features:

• Dual calculation mode
The user can choose between a Stochastic-based oscillator and an RSI-based oscillator.

• Custom source selection
The selected source is used in the oscillator calculation, allowing the user to adapt the tool to different price inputs.

• Double smoothing engine
The raw oscillator is smoothed twice with configurable lengths. This is designed to make the oscillator less noisy while preserving the main directional movement.

• Configurable levels
The script includes adjustable overbought, oversold, midline, neutral-band, upper-bound, and lower-bound levels.

• Bull and bear pressure gradients
The oscillator area is visually separated around the midline. Positive momentum above the midline and negative momentum below the midline are displayed with separate gradient regions.

• Neutral band
A configurable neutral zone can be displayed between the upper and lower neutral-band levels. This helps identify when momentum is not clearly extended in either direction.

• Signal dots
The script displays optional dots for specific oscillator states:

* Green dots mark overbought conditions.
* Red dots mark oversold conditions.
* Orange dots mark bullish momentum crosses.
* Magenta dots mark neutral-band events or neutral-band zone conditions.

The dot logic can be set to either “Events” or “Zones”.
In Events mode, dots appear only when a condition is newly triggered.
In Zones mode, dots remain visible while the condition is active.

• Alerts
The script includes alert conditions for overbought entry, oversold entry, exits from those zones, bullish momentum crosses, and bearish momentum crosses.

How to use:

1. Choose the calculation mode: Stochastic or RSI.
2. Adjust the oscillator length and smoothing settings to match the symbol and timeframe being analyzed.
3. Use the overbought and oversold levels to identify extended oscillator conditions.
4. Use the midline and neutral band to evaluate whether momentum is directional or balanced.
5. Use the dots as visual markers of oscillator state changes, not as standalone trade entries.
6. Combine this oscillator with price structure, trend context, volume, and risk management before making any trading decision.

Important limitations:

• This script is an indicator, not a strategy.
• It does not place trades.
• It does not manage risk.
• It does not provide financial advice.
• It does not guarantee profitable results.
• Overbought does not automatically mean price must fall.
• Oversold does not automatically mean price must rise.
• Momentum crosses can fail during ranging or volatile markets.
• Users should test settings on their own symbols and timeframes before relying on the visual output.

This indicator is best used as a momentum-context tool, not as a standalone entry or exit system.

## Source Code

````pine
//@version=6
//╔════════════════════════════════════════════════════════════════════════════╗
//║                                                                            ║
//║   ███████╗██╗     ██╗████████╗███████╗                                   ║
//║   ██╔════╝██║     ██║╚══██╔══╝██╔════╝                                   ║
//║   █████╗  ██║     ██║   ██║   █████╗                                     ║
//║   ██╔══╝  ██║     ██║   ██║   ██╔══╝                                     ║
//║   ███████╗███████╗██║   ██║   ███████╗                                   ║
//║   ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝                                   ║
//║                                                                            ║
//║   ELITE OSCILLATOR PRO                                                     ║
//║   © 2026 Not Alpha                                                         ║
//║                                                                            ║
//║   Advanced momentum oscillator module                                      ║
//║   RSI / Stochastic engine · smoothing · regime dots · gradient pressure    ║
//║                                                                            ║
//╚════════════════════════════════════════════════════════════════════════════╝

indicator("Elite Oscillator Pro", overlay = false, precision = 3)

// ============================================================================
// INPUTS — CALCULATION
// ============================================================================
grpCalc   = "OSCILLATOR ENGINE"

calcMode  = input.string("Stochastic", "Calculation Mode", options = ["Stochastic", "RSI"], group = grpCalc)
src       = input.source(close, "Source", group = grpCalc)
oscLen    = input.int(14, "Length", minval = 1, group = grpCalc)
smooth1   = input.int(3, "Smoothing 1", minval = 1, group = grpCalc)
smooth2   = input.int(3, "Smoothing 2", minval = 1, group = grpCalc)
sigLen    = input.int(9, "Signal Line Length", minval = 1, group = grpCalc)

// ============================================================================
// INPUTS — LEVELS
// ============================================================================
grpLvl   = "LEVELS"

obLevel  = input.float(70,  "Overbought",        group = grpLvl)
osLevel  = input.float(30,  "Oversold",          group = grpLvl)
midLevel = input.float(50,  "Midline",           group = grpLvl)
bandHi   = input.float(55,  "Neutral Band Top",  group = grpLvl)
bandLo   = input.float(45,  "Neutral Band Bot",  group = grpLvl)
upBound  = input.float(101, "Upper Bound",       group = grpLvl)
loBound  = input.float(0,   "Lower Bound",       group = grpLvl)

// ============================================================================
// INPUTS — STYLE
// ============================================================================
grpStyle   = "STYLE"

useBlackBg  = input.bool(true, "Black Background", group = grpStyle)
colLine     = input.color(#2979FF, "Oscillator Line", group = grpStyle)
lineWidth   = input.int(2, "Line Width", minval = 1, maxval = 5, group = grpStyle)

colFill     = input.color(#00E676, "Hump Fill Bull", group = grpStyle)
colFillBear = input.color(#FF1744, "Hump Fill Bear", group = grpStyle)
colMid      = input.color(#26A69A, "Midline", group = grpStyle)
colBlue     = input.color(#2962FF, "OB / OS Lines", group = grpStyle)
colTeal     = input.color(#00BCD4, "Bound Lines", group = grpStyle)

showBand    = input.bool(true, "Show Neutral Band Fill", group = grpStyle)

// ============================================================================
// INPUTS — SIGNAL DOTS
// ============================================================================
grpDots     = "SIGNAL DOTS"

dotMode     = input.string("Events", "Dot Logic", options = ["Events", "Zones"], group = grpDots)

showGreen   = input.bool(true, "Green — Overbought", group = grpDots)
showRed     = input.bool(true, "Red — Oversold", group = grpDots)
showOrange  = input.bool(true, "Orange — Bullish Momentum", group = grpDots)
showMagenta = input.bool(true, "Magenta — Neutral Band", group = grpDots)

colGreen    = input.color(#00E676, "Green Dot",   group = grpDots)
colRed      = input.color(#FF1744, "Red Dot",     group = grpDots)
colOrange   = input.color(#FF9800, "Orange Dot",  group = grpDots)
colMagenta  = input.color(#EC407A, "Magenta Dot", group = grpDots)

dotSize     = input.int(3, "Dot Size", minval = 1, maxval = 6, group = grpDots)

// ============================================================================
// INTERNAL HELPERS
// ============================================================================
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_inRange(float x, float lo, float hi) =>
    x >= lo and x <= hi

f_eventOrZone(bool zoneCond, bool eventCond, string mode) =>
    mode == "Zones" ? zoneCond : eventCond

f_rawOsc(_mode, _src, _len) =>
    _mode == "Stochastic" ? ta.stoch(_src, high, low, _len) : ta.rsi(_src, _len)

f_doubleSmooth(x, len1, len2) =>
    ta.ema(ta.ema(x, len1), len2)

// ============================================================================
// CORE ENGINE
// ============================================================================
rawBase = f_rawOsc(calcMode, src, oscLen)
raw     = f_clamp(rawBase, loBound, upBound)

oscRaw  = f_doubleSmooth(raw, smooth1, smooth2)
osc     = f_clamp(oscRaw, loBound, upBound)

signalRaw = ta.ema(osc, sigLen)
signal    = f_clamp(signalRaw, loBound, upBound)

// ============================================================================
// STATE ENGINE
// ============================================================================
oscAboveMid = osc > midLevel
oscBelowMid = osc < midLevel

oscInOB      = osc >= obLevel
oscInOS      = osc <= osLevel
oscInNeutral = f_inRange(osc, bandLo, bandHi)

crossUpSignal   = ta.crossover(osc, signal)
crossDownSignal = ta.crossunder(osc, signal)

enterOB      = ta.crossover(osc, obLevel)
exitOB       = ta.crossunder(osc, obLevel)
enterOS      = ta.crossunder(osc, osLevel)
exitOS       = ta.crossover(osc, osLevel)

enterNeutralFromBelow = ta.crossover(osc, bandLo) and osc <= bandHi
enterNeutralFromAbove = ta.crossunder(osc, bandHi) and osc >= bandLo
enterNeutral          = enterNeutralFromBelow or enterNeutralFromAbove

bullMomentum = crossUpSignal and oscAboveMid
bearMomentum = crossDownSignal and oscBelowMid

// ============================================================================
// BACKGROUND
// ============================================================================
bgcolor(useBlackBg ? color.new(#2a2b2e, 100) : na, title = "Background")

// ============================================================================
// LEVEL LINES
// ============================================================================
plot(upBound,  "Upper Bound 101", color = colTeal, linewidth = 1)
plot(loBound,  "Lower Bound 0",   color = colTeal, linewidth = 1)
plot(obLevel,  "Overbought 70",   color = color.new(colBlue, 0), linewidth = 1)
plot(osLevel,  "Oversold 30",     color = color.new(colBlue, 0), linewidth = 1)
plot(midLevel, "Midline 50",      color = colMid, linewidth = 1)

// ============================================================================
// NEUTRAL BAND
// ============================================================================
hlHi = hline(bandHi, "Band Top 55", color = color.new(colMid, 65), linestyle = hline.style_dotted)
hlLo = hline(bandLo, "Band Bot 45", color = color.new(colMid, 65), linestyle = hline.style_dotted)

fill(hlHi, hlLo, color = showBand ? color.new(colMid, 93) : na, title = "Neutral Band Fill")

// ============================================================================
// HUMPS — BULL / BEAR GRADIENTS
// ============================================================================
fillTop  = plot(math.max(osc, midLevel), "fillTop",  display = display.none)
fillBase = plot(midLevel,                "fillBase", display = display.none)

fill(
     fillTop,
     fillBase,
     top_value = upBound,
     bottom_value = midLevel,
     top_color = color.new(colFill, 14),
     bottom_color = color.new(colFill, 92),
     title = "Hump Gradient Bull"
)

fillBearTop  = plot(midLevel,                "fillBearTop",  display = display.none)
fillBearBase = plot(math.min(osc, midLevel), "fillBearBase", display = display.none)

fill(
     fillBearTop,
     fillBearBase,
     top_value = midLevel,
     bottom_value = loBound,
     top_color = color.new(colFillBear, 92),
     bottom_color = color.new(colFillBear, 14),
     title = "Hump Gradient Bear"
)

// ============================================================================
// MAIN OSCILLATOR LINE
// ============================================================================
plot(osc, "Elite Oscillator", color = colLine, linewidth = lineWidth)

// ============================================================================
// SIGNAL DOTS
// ============================================================================
// Green top  = Overbought
// Red bottom = Oversold
// Orange     = Bullish momentum cross
// Magenta    = Neutral band event / zone

greenSig   = f_eventOrZone(oscInOB, enterOB, dotMode)
redSig     = f_eventOrZone(oscInOS, enterOS, dotMode)
orangeSig  = bullMomentum
magentaSig = f_eventOrZone(oscInNeutral, enterNeutral, dotMode)

greenY   = upBound
redY     = loBound
orangeY  = bandHi
magentaY = midLevel

plot(showGreen   and greenSig   ? greenY   : na, "Green Dots — Overbought",     color = colGreen,   style = plot.style_circles, linewidth = dotSize)
plot(showRed     and redSig     ? redY     : na, "Red Dots — Oversold",         color = colRed,     style = plot.style_circles, linewidth = dotSize)
plot(showOrange  and orangeSig  ? orangeY  : na, "Orange Dots — Bull Momentum", color = colOrange,  style = plot.style_circles, linewidth = dotSize)
plot(showMagenta and magentaSig ? magentaY : na, "Magenta Dots — Neutral Band", color = colMagenta, style = plot.style_circles, linewidth = dotSize)

// ============================================================================
// ALERT CONDITIONS
// ============================================================================
alertcondition(enterOB,       "Overbought",        "Elite Oscillator: entered overbought zone")
alertcondition(enterOS,       "Oversold",          "Elite Oscillator: entered oversold zone")
alertcondition(exitOB,        "Exit Overbought",   "Elite Oscillator: exited overbought zone")
alertcondition(exitOS,        "Exit Oversold",     "Elite Oscillator: exited oversold zone")
alertcondition(orangeSig,     "Bullish Momentum",  "Elite Oscillator: bullish momentum cross above midline")
alertcondition(bearMomentum,  "Bearish Momentum",  "Elite Oscillator: bearish momentum cross below midline")
````
