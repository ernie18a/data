# Adaptive MACD+ [MACD]

- url: https://www.tradingview.com/script/Il2VRAlq-Adaptive-MACD-MACD/
- type: indicator
- pine_id: PUB;6d65ca261feb4713bca24c4882444b64
- version: 1.0

## Description

Adaptive MACD+ is a self-optimizing momentum indicator that dynamically selects the most effective MACD parameters

Instead of relying on fixed fast and slow EMA lengths, this indicator continuously evaluates a range of combinations and automatically selects the pair that has been performing best on recent price action — delivering a MACD that adapts to changing market conditions and momentum cycles.

[b]🔶 HOW IT WORKS[/b]

Traditional MACD uses fixed parameters, which may lag in fast markets or produce noise during consolidation. Adaptive MACD+ solves this by testing multiple fast and slow EMA combinations in parallel.

The process:
A range of fast EMAs (short-term) and slow EMAs (long-term) are calculated
Each combination generates its own MACD line
A performance scoring system evaluates how well each responds to momentum shifts

On every bar:
The best-performing fast and slow pair is selected
The MACD line is calculated using this optimal combination
A signal line (EMA of MACD) and histogram are derived as usual

This results in a MACD that continuously adapts its sensitivity to match current market momentum.

[b]🔶 USAGE[/b]

🔹 MACD Structure

MACD Line (Blue/Red) — Represents momentum direction based on the adaptive EMA pair
Signal Line (Orange) — Smoothed version of the MACD line used for crossover signals
Histogram — Difference between MACD and signal line, showing momentum strength

Green histogram — Bullish momentum
Red histogram — Bearish momentum

🔹 Trade Signals

Green triangle (▲) — Bullish crossover. MACD crosses above the signal line, indicating potential upward momentum
Red triangle (▼) — Bearish crossover. MACD crosses below the signal line, indicating potential downward momentum

Because the EMA lengths are dynamically selected, these signals reflect momentum conditions that are optimized for recent price behavior — not fixed parameters.

[b]🔶 SETTINGS[/b]

🔹 Calculation Settings

Source — Price used for calculations (default: close)

Min Fast Length — Lower bound for fast EMA range (more responsive)
Max Fast Length — Upper bound for fast EMA range (smoother)

Min Slow Length — Lower bound for slow EMA range
Max Slow Length — Upper bound for slow EMA range

Signal Length — EMA length applied to the MACD line to create the signal line

🔹 Visual Settings

Show Histogram — Toggle histogram display
Show Signal — Toggle signal line display

[b]🔶 NOTES[/b]

Suitable for all markets and timeframes.
Works best as a momentum confirmation and trend-strength tool.
Adaptive EMA selection helps reduce lag during strong trends and noise during consolidation.
Can be combined with trend indicators for higher-probability setups.
Past performance of any selected EMA combination does not guarantee future results — always apply proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MarketAlgoBot

//@version=6
indicator('Adaptive MACD+', overlay=false)

//────────────────────────────
// Inputs
//────────────────────────────
const string calcGroup   = 'Calculation'
const string visualGroup = 'Visuals'

src       = input.source(close, 'Source',         group=calcGroup)
minFast   = input.int(8,  'Min Fast Length', minval=2, maxval=20, group=calcGroup)
maxFast   = input.int(20, 'Max Fast Length', minval=2, maxval=20, group=calcGroup)
minSlow   = input.int(21, 'Min Slow Length', minval=10, maxval=50, group=calcGroup)
maxSlow   = input.int(50, 'Max Slow Length', minval=10, maxval=50, group=calcGroup)
signalLen = input.int(9,  'Signal Length',   minval=1, group=calcGroup)
showHist  = input.bool(true, 'Show Histogram', group=visualGroup)
showSig   = input.bool(true, 'Show Signal',    group=visualGroup)

perfAlpha = 10

//────────────────────────────
// Fast EMAs (8–20)
//────────────────────────────
emaF8  = ta.ema(src, 8)
emaF9  = ta.ema(src, 9)
emaF10 = ta.ema(src, 10)
emaF11 = ta.ema(src, 11)
emaF12 = ta.ema(src, 12)
emaF13 = ta.ema(src, 13)
emaF14 = ta.ema(src, 14)
emaF15 = ta.ema(src, 15)
emaF16 = ta.ema(src, 16)
emaF17 = ta.ema(src, 17)
emaF18 = ta.ema(src, 18)
emaF19 = ta.ema(src, 19)
emaF20 = ta.ema(src, 20)

//────────────────────────────
// Slow EMAs (21–50)
//────────────────────────────
emaS21 = ta.ema(src, 21)
emaS22 = ta.ema(src, 22)
emaS23 = ta.ema(src, 23)
emaS24 = ta.ema(src, 24)
emaS25 = ta.ema(src, 25)
emaS26 = ta.ema(src, 26)
emaS27 = ta.ema(src, 27)
emaS28 = ta.ema(src, 28)
emaS29 = ta.ema(src, 29)
emaS30 = ta.ema(src, 30)
emaS31 = ta.ema(src, 31)
emaS32 = ta.ema(src, 32)
emaS33 = ta.ema(src, 33)
emaS34 = ta.ema(src, 34)
emaS35 = ta.ema(src, 35)
emaS36 = ta.ema(src, 36)
emaS37 = ta.ema(src, 37)
emaS38 = ta.ema(src, 38)
emaS39 = ta.ema(src, 39)
emaS40 = ta.ema(src, 40)
emaS41 = ta.ema(src, 41)
emaS42 = ta.ema(src, 42)
emaS43 = ta.ema(src, 43)
emaS44 = ta.ema(src, 44)
emaS45 = ta.ema(src, 45)
emaS46 = ta.ema(src, 46)
emaS47 = ta.ema(src, 47)
emaS48 = ta.ema(src, 48)
emaS49 = ta.ema(src, 49)
emaS50 = ta.ema(src, 50)

//────────────────────────────
// Fast MACD lines — global scope series
// [1] on these works perfectly — they are NOT local variables
//────────────────────────────
mF8  = emaF8  - emaS25
mF9  = emaF9  - emaS25
mF10 = emaF10 - emaS25
mF11 = emaF11 - emaS25
mF12 = emaF12 - emaS25
mF13 = emaF13 - emaS25
mF14 = emaF14 - emaS25
mF15 = emaF15 - emaS25
mF16 = emaF16 - emaS25
mF17 = emaF17 - emaS25
mF18 = emaF18 - emaS25
mF19 = emaF19 - emaS25
mF20 = emaF20 - emaS25

//────────────────────────────
// Slow MACD lines — global scope series
//────────────────────────────
mS21 = emaF12 - emaS21
mS22 = emaF12 - emaS22
mS23 = emaF12 - emaS23
mS24 = emaF12 - emaS24
mS25 = emaF12 - emaS25
mS26 = emaF12 - emaS26
mS27 = emaF12 - emaS27
mS28 = emaF12 - emaS28
mS29 = emaF12 - emaS29
mS30 = emaF12 - emaS30
mS31 = emaF12 - emaS31
mS32 = emaF12 - emaS32
mS33 = emaF12 - emaS33
mS34 = emaF12 - emaS34
mS35 = emaF12 - emaS35
mS36 = emaF12 - emaS36
mS37 = emaF12 - emaS37
mS38 = emaF12 - emaS38
mS39 = emaF12 - emaS39
mS40 = emaF12 - emaS40
mS41 = emaF12 - emaS41
mS42 = emaF12 - emaS42
mS43 = emaF12 - emaS43
mS44 = emaF12 - emaS44
mS45 = emaF12 - emaS45
mS46 = emaF12 - emaS46
mS47 = emaF12 - emaS47
mS48 = emaF12 - emaS48
mS49 = emaF12 - emaS49
mS50 = emaF12 - emaS50

//────────────────────────────
// Performance scoring
// Use global series DIRECTLY — no array.get inside scoring
// Each mFx and mSx has proper history Pine can access with [1]
//────────────────────────────
var fastPerf = array.new<float>(13, 0.)
var slowPerf = array.new<float>(30, 0.)

// Fast scoring — reference each global series by name
f0  = 2 / (perfAlpha + 1) * (math.sign(mF8  - mF8 [1]) - array.get(fastPerf, 0))
f1  = 2 / (perfAlpha + 1) * (math.sign(mF9  - mF9 [1]) - array.get(fastPerf, 1))
f2  = 2 / (perfAlpha + 1) * (math.sign(mF10 - mF10[1]) - array.get(fastPerf, 2))
f3  = 2 / (perfAlpha + 1) * (math.sign(mF11 - mF11[1]) - array.get(fastPerf, 3))
f4  = 2 / (perfAlpha + 1) * (math.sign(mF12 - mF12[1]) - array.get(fastPerf, 4))
f5  = 2 / (perfAlpha + 1) * (math.sign(mF13 - mF13[1]) - array.get(fastPerf, 5))
f6  = 2 / (perfAlpha + 1) * (math.sign(mF14 - mF14[1]) - array.get(fastPerf, 6))
f7  = 2 / (perfAlpha + 1) * (math.sign(mF15 - mF15[1]) - array.get(fastPerf, 7))
f8  = 2 / (perfAlpha + 1) * (math.sign(mF16 - mF16[1]) - array.get(fastPerf, 8))
f9  = 2 / (perfAlpha + 1) * (math.sign(mF17 - mF17[1]) - array.get(fastPerf, 9))
f10 = 2 / (perfAlpha + 1) * (math.sign(mF18 - mF18[1]) - array.get(fastPerf, 10))
f11 = 2 / (perfAlpha + 1) * (math.sign(mF19 - mF19[1]) - array.get(fastPerf, 11))
f12 = 2 / (perfAlpha + 1) * (math.sign(mF20 - mF20[1]) - array.get(fastPerf, 12))

array.set(fastPerf, 0,  array.get(fastPerf, 0)  + f0)
array.set(fastPerf, 1,  array.get(fastPerf, 1)  + f1)
array.set(fastPerf, 2,  array.get(fastPerf, 2)  + f2)
array.set(fastPerf, 3,  array.get(fastPerf, 3)  + f3)
array.set(fastPerf, 4,  array.get(fastPerf, 4)  + f4)
array.set(fastPerf, 5,  array.get(fastPerf, 5)  + f5)
array.set(fastPerf, 6,  array.get(fastPerf, 6)  + f6)
array.set(fastPerf, 7,  array.get(fastPerf, 7)  + f7)
array.set(fastPerf, 8,  array.get(fastPerf, 8)  + f8)
array.set(fastPerf, 9,  array.get(fastPerf, 9)  + f9)
array.set(fastPerf, 10, array.get(fastPerf, 10) + f10)
array.set(fastPerf, 11, array.get(fastPerf, 11) + f11)
array.set(fastPerf, 12, array.get(fastPerf, 12) + f12)

// Slow scoring — same pattern
s0  = 2 / (perfAlpha + 1) * (math.sign(mS21 - mS21[1]) - array.get(slowPerf, 0))
s1  = 2 / (perfAlpha + 1) * (math.sign(mS22 - mS22[1]) - array.get(slowPerf, 1))
s2  = 2 / (perfAlpha + 1) * (math.sign(mS23 - mS23[1]) - array.get(slowPerf, 2))
s3  = 2 / (perfAlpha + 1) * (math.sign(mS24 - mS24[1]) - array.get(slowPerf, 3))
s4  = 2 / (perfAlpha + 1) * (math.sign(mS25 - mS25[1]) - array.get(slowPerf, 4))
s5  = 2 / (perfAlpha + 1) * (math.sign(mS26 - mS26[1]) - array.get(slowPerf, 5))
s6  = 2 / (perfAlpha + 1) * (math.sign(mS27 - mS27[1]) - array.get(slowPerf, 6))
s7  = 2 / (perfAlpha + 1) * (math.sign(mS28 - mS28[1]) - array.get(slowPerf, 7))
s8  = 2 / (perfAlpha + 1) * (math.sign(mS29 - mS29[1]) - array.get(slowPerf, 8))
s9  = 2 / (perfAlpha + 1) * (math.sign(mS30 - mS30[1]) - array.get(slowPerf, 9))
s10 = 2 / (perfAlpha + 1) * (math.sign(mS31 - mS31[1]) - array.get(slowPerf, 10))
s11 = 2 / (perfAlpha + 1) * (math.sign(mS32 - mS32[1]) - array.get(slowPerf, 11))
s12 = 2 / (perfAlpha + 1) * (math.sign(mS33 - mS33[1]) - array.get(slowPerf, 12))
s13 = 2 / (perfAlpha + 1) * (math.sign(mS34 - mS34[1]) - array.get(slowPerf, 13))
s14 = 2 / (perfAlpha + 1) * (math.sign(mS35 - mS35[1]) - array.get(slowPerf, 14))
s15 = 2 / (perfAlpha + 1) * (math.sign(mS36 - mS36[1]) - array.get(slowPerf, 15))
s16 = 2 / (perfAlpha + 1) * (math.sign(mS37 - mS37[1]) - array.get(slowPerf, 16))
s17 = 2 / (perfAlpha + 1) * (math.sign(mS38 - mS38[1]) - array.get(slowPerf, 17))
s18 = 2 / (perfAlpha + 1) * (math.sign(mS39 - mS39[1]) - array.get(slowPerf, 18))
s19 = 2 / (perfAlpha + 1) * (math.sign(mS40 - mS40[1]) - array.get(slowPerf, 19))
s20 = 2 / (perfAlpha + 1) * (math.sign(mS41 - mS41[1]) - array.get(slowPerf, 20))
s21 = 2 / (perfAlpha + 1) * (math.sign(mS42 - mS42[1]) - array.get(slowPerf, 21))
s22 = 2 / (perfAlpha + 1) * (math.sign(mS43 - mS43[1]) - array.get(slowPerf, 22))
s23 = 2 / (perfAlpha + 1) * (math.sign(mS44 - mS44[1]) - array.get(slowPerf, 23))
s24 = 2 / (perfAlpha + 1) * (math.sign(mS45 - mS45[1]) - array.get(slowPerf, 24))
s25 = 2 / (perfAlpha + 1) * (math.sign(mS46 - mS46[1]) - array.get(slowPerf, 25))
s26 = 2 / (perfAlpha + 1) * (math.sign(mS47 - mS47[1]) - array.get(slowPerf, 26))
s27 = 2 / (perfAlpha + 1) * (math.sign(mS48 - mS48[1]) - array.get(slowPerf, 27))
s28 = 2 / (perfAlpha + 1) * (math.sign(mS49 - mS49[1]) - array.get(slowPerf, 28))
s29 = 2 / (perfAlpha + 1) * (math.sign(mS50 - mS50[1]) - array.get(slowPerf, 29))

array.set(slowPerf, 0,  array.get(slowPerf, 0)  + s0)
array.set(slowPerf, 1,  array.get(slowPerf, 1)  + s1)
array.set(slowPerf, 2,  array.get(slowPerf, 2)  + s2)
array.set(slowPerf, 3,  array.get(slowPerf, 3)  + s3)
array.set(slowPerf, 4,  array.get(slowPerf, 4)  + s4)
array.set(slowPerf, 5,  array.get(slowPerf, 5)  + s5)
array.set(slowPerf, 6,  array.get(slowPerf, 6)  + s6)
array.set(slowPerf, 7,  array.get(slowPerf, 7)  + s7)
array.set(slowPerf, 8,  array.get(slowPerf, 8)  + s8)
array.set(slowPerf, 9,  array.get(slowPerf, 9)  + s9)
array.set(slowPerf, 10, array.get(slowPerf, 10) + s10)
array.set(slowPerf, 11, array.get(slowPerf, 11) + s11)
array.set(slowPerf, 12, array.get(slowPerf, 12) + s12)
array.set(slowPerf, 13, array.get(slowPerf, 13) + s13)
array.set(slowPerf, 14, array.get(slowPerf, 14) + s14)
array.set(slowPerf, 15, array.get(slowPerf, 15) + s15)
array.set(slowPerf, 16, array.get(slowPerf, 16) + s16)
array.set(slowPerf, 17, array.get(slowPerf, 17) + s17)
array.set(slowPerf, 18, array.get(slowPerf, 18) + s18)
array.set(slowPerf, 19, array.get(slowPerf, 19) + s19)
array.set(slowPerf, 20, array.get(slowPerf, 20) + s20)
array.set(slowPerf, 21, array.get(slowPerf, 21) + s21)
array.set(slowPerf, 22, array.get(slowPerf, 22) + s22)
array.set(slowPerf, 23, array.get(slowPerf, 23) + s23)
array.set(slowPerf, 24, array.get(slowPerf, 24) + s24)
array.set(slowPerf, 25, array.get(slowPerf, 25) + s25)
array.set(slowPerf, 26, array.get(slowPerf, 26) + s26)
array.set(slowPerf, 27, array.get(slowPerf, 27) + s27)
array.set(slowPerf, 28, array.get(slowPerf, 28) + s28)
array.set(slowPerf, 29, array.get(slowPerf, 29) + s29)

//────────────────────────────
// Select best fast and slow
//────────────────────────────
var int bestFastIdx = 0
var int bestSlowIdx = 0

bestFastVal = array.get(fastPerf, 0)
for i = 1 to 12
    if 8 + i >= minFast and 8 + i <= maxFast
        val = array.get(fastPerf, i)
        if val > bestFastVal
            bestFastVal := val
            bestFastIdx  := i

bestSlowVal = array.get(slowPerf, 0)
for i = 1 to 29
    if 21 + i >= minSlow and 21 + i <= maxSlow
        val = array.get(slowPerf, i)
        if val > bestSlowVal
            bestSlowVal := val
            bestSlowIdx  := i

//────────────────────────────
// Final MACD
//────────────────────────────
var int   bestFast  = 8
var int   bestSlow  = 21
var float macdLine  = 0.0
var float sigLine   = 0.0
var float histogram = 0.0

bestFast  := 8  + bestFastIdx
bestSlow  := 21 + bestSlowIdx

// Pick the right EMA pair by index
bestFastEma = bestFastIdx == 0  ? emaF8  : bestFastIdx == 1  ? emaF9  :
              bestFastIdx == 2  ? emaF10 : bestFastIdx == 3  ? emaF11 :
              bestFastIdx == 4  ? emaF12 : bestFastIdx == 5  ? emaF13 :
              bestFastIdx == 6  ? emaF14 : bestFastIdx == 7  ? emaF15 :
              bestFastIdx == 8  ? emaF16 : bestFastIdx == 9  ? emaF17 :
              bestFastIdx == 10 ? emaF18 : bestFastIdx == 11 ? emaF19 : emaF20

bestSlowEma = bestSlowIdx == 0  ? emaS21 : bestSlowIdx == 1  ? emaS22 :
              bestSlowIdx == 2  ? emaS23 : bestSlowIdx == 3  ? emaS24 :
              bestSlowIdx == 4  ? emaS25 : bestSlowIdx == 5  ? emaS26 :
              bestSlowIdx == 6  ? emaS27 : bestSlowIdx == 7  ? emaS28 :
              bestSlowIdx == 8  ? emaS29 : bestSlowIdx == 9  ? emaS30 :
              bestSlowIdx == 10 ? emaS31 : bestSlowIdx == 11 ? emaS32 :
              bestSlowIdx == 12 ? emaS33 : bestSlowIdx == 13 ? emaS34 :
              bestSlowIdx == 14 ? emaS35 : bestSlowIdx == 15 ? emaS36 :
              bestSlowIdx == 16 ? emaS37 : bestSlowIdx == 17 ? emaS38 :
              bestSlowIdx == 18 ? emaS39 : bestSlowIdx == 19 ? emaS40 :
              bestSlowIdx == 20 ? emaS41 : bestSlowIdx == 21 ? emaS42 :
              bestSlowIdx == 22 ? emaS43 : bestSlowIdx == 23 ? emaS44 :
              bestSlowIdx == 24 ? emaS45 : bestSlowIdx == 25 ? emaS46 :
              bestSlowIdx == 26 ? emaS47 : bestSlowIdx == 27 ? emaS48 :
              bestSlowIdx == 28 ? emaS49 : emaS50

macdLine  := bestFastEma - bestSlowEma
sigLine   := ta.ema(macdLine, signalLen)
histogram := macdLine - sigLine

//────────────────────────────
// Colors
//────────────────────────────
histColor = histogram >= 0
          ? (histogram > histogram[1] ? color.new(#26a69a, 0)  : color.new(#26a69a, 50))
          : (histogram < histogram[1] ? color.new(#ef5350, 0)  : color.new(#ef5350, 50))
macdColor = macdLine >= 0 ? color.new(#2962FF, 0) : color.new(#FF1744, 0)
sigColor  = color.new(#FF6D00, 0)

//────────────────────────────
// Zero line + plots
//────────────────────────────
hline(0, 'Zero Line', color=color.new(color.gray, 60), linewidth=1)

plot(showHist ? histogram : na,
     title = 'Histogram',
     style = plot.style_columns,
     color = histColor)

plot(macdLine,
     title     = 'MACD Line',
     color     = macdColor,
     linewidth = 2)

plot(showSig ? sigLine : na,
     title     = 'Signal Line',
     color     = sigColor,
     linewidth = 1)

//────────────────────────────
// Signals
//────────────────────────────
bullCross = ta.crossover(macdLine,  sigLine)
bearCross = ta.crossunder(macdLine, sigLine)

plotshape(bullCross,
     title    = 'Bull Cross',
     style    = shape.triangleup,
     location = location.bottom,
     color    = color.new(#26a69a, 0),
     size     = size.tiny)

plotshape(bearCross,
     title    = 'Bear Cross',
     style    = shape.triangledown,
     location = location.top,
     color    = color.new(#ef5350, 0),
     size     = size.tiny)

//────────────────────────────
// Alerts
//────────────────────────────
alertcondition(bullCross, title='MACD Bull Cross', message='Adaptive MACD+ Bull Cross — {{exchange}}:{{ticker}}')
alertcondition(bearCross, title='MACD Bear Cross', message='Adaptive MACD+ Bear Cross — {{exchange}}:{{ticker}}')
````
