# Squeeze Wave by Agaam

- url: https://www.tradingview.com/script/51tJy4yh-Squeeze-Wave-by-Agaam/
- type: indicator
- pine_id: PUB;36c27a44472d477fbe10745adfbbebc7
- version: 1.0

## Description

Squeeze Wave by Agaam

Squeeze Wave by Agaam is a momentum and compression indicator designed to help identify when price is building energy and when that energy begins to release. It combines Bollinger Bands, Keltner Channels, and a smoothed momentum wave to show both volatility compression and directional strength in one lower-pane tool.

When the Bollinger Bands move inside the Keltner Channel, the market is in a squeeze, which can signal reduced volatility and potential buildup before expansion. When the Bollinger Bands move back outside the Keltner Channel, the squeeze is released, often marking the start of a stronger directional move.

The indicator plots a color-changing momentum wave, a signal line, and optional squeeze dots at the zero line.

How to read it

Bright bullish wave = positive momentum is increasing
Dark bullish wave = positive momentum is weakening
Bright bearish wave = negative momentum is increasing
Dark bearish wave = negative momentum is weakening
Red dots = squeeze is on, market is compressing
Lime dots = squeeze released, expansion may begin
Gray dots = neutral / no clear squeeze condition

Main features

Bollinger Band and Keltner Channel squeeze detection
Smoothed momentum wave for cleaner trend reading
Signal line for extra confirmation
Optional fill between wave and zero line
Optional background color for fast bullish / bearish bias
Adjustable widths, colors, and visibility for all main elements
Choice to use True Range or standard high-low range for Keltner calculation

Best use
This indicator can be used to:

Spot volatility compression before breakout moves
Confirm momentum direction after squeeze release
Filter weak vs strong bullish and bearish pressure
Stay aligned with expanding momentum instead of guessing early

Inputs included

Bollinger Bands length and multiplier
Keltner Channel length and multiplier
Wave smoothing and signal length
True Range toggle for Keltner calculation
On/off controls for wave, signal line, dots, fill, background, and zero line
Fully customizable colors and line widths

General idea

Wait for a squeeze to form
Watch for squeeze release
Use wave direction and strength color to judge momentum bias
Use the signal line and zero line for additional confirmation

Disclaimer
This indicator is for educational and chart-analysis purposes only. It does not guarantee future results and should be used together with price action, structure, and risk management

## Source Code

````pine
//@version=5
indicator("Squeeze Wave by Agaam", overlay=false)

//==================================================
// INPUTS
//==================================================
bbLength       = input.int(20, "Bollinger Bands Length", minval=1)
bbMult         = input.float(2.0, "Bollinger Bands Multiplier", minval=0.1, step=0.1)

kcLength       = input.int(20, "Keltner Channel Length", minval=1)
kcMult         = input.float(1.5, "Keltner Channel Multiplier", minval=0.1, step=0.1)

smoothLen      = input.int(3, "Wave Smoothing", minval=1)
signalLen      = input.int(5, "Signal Length", minval=1)

useTrueRange   = input.bool(true, "Use True Range For Keltner")
showWave       = input.bool(true, "Show Wave")
showSignal     = input.bool(true, "Show Signal Line")
showDots       = input.bool(true, "Show Squeeze Dots")
showFill       = input.bool(true, "Show Wave Fill")
showBg         = input.bool(true, "Show Background")
showZeroLine   = input.bool(true, "Show Zero Line")

waveWidth      = input.int(3, "Wave Width", minval=1, maxval=10)
signalWidth    = input.int(2, "Signal Width", minval=1, maxval=10)
dotWidth       = input.int(3, "Dot Width", minval=1, maxval=10)

waveBullStrong = input.color(color.lime, "Wave Bull Strong")
waveBullWeak   = input.color(color.green, "Wave Bull Weak")
waveBearStrong = input.color(color.red, "Wave Bear Strong")
waveBearWeak   = input.color(color.maroon, "Wave Bear Weak")
signalColor    = input.color(color.white, "Signal Color")

sqOnCol        = input.color(color.red, "Squeeze On Dot Color")
sqOffCol       = input.color(color.lime, "Squeeze Off Dot Color")
noSqCol        = input.color(color.gray, "No Squeeze Dot Color")
zeroLineCol    = input.color(color.gray, "Zero Line Color")

bullBgColor    = input.color(color.new(color.lime, 92), "Bull Background")
bearBgColor    = input.color(color.new(color.red, 92), "Bear Background")
neutralBgColor = input.color(color.new(color.gray, 95), "Neutral Background")

//==================================================
// BOLLINGER BANDS
//==================================================
bbBasis = ta.sma(close, bbLength)
bbDev   = bbMult * ta.stdev(close, bbLength)

upperBB = bbBasis + bbDev
lowerBB = bbBasis - bbDev

//==================================================
// KELTNER CHANNEL
//==================================================
kcBasis = ta.sma(close, kcLength)
kcRange = useTrueRange ? ta.atr(kcLength) : ta.sma(high - low, kcLength)

upperKC = kcBasis + kcRange * kcMult
lowerKC = kcBasis - kcRange * kcMult

//==================================================
// SQUEEZE STATES
//==================================================
squeezeOn  = lowerBB > lowerKC and upperBB < upperKC
squeezeOff = lowerBB < lowerKC and upperBB > upperKC
noSqueeze  = not squeezeOn and not squeezeOff

//==================================================
// MOMENTUM / WAVE
//==================================================
highestHigh = ta.highest(high, kcLength)
lowestLow   = ta.lowest(low, kcLength)
avgHL       = (highestHigh + lowestLow) / 2.0
avgSource   = (avgHL + ta.sma(close, kcLength)) / 2.0

rawMomentum = ta.linreg(close - avgSource, kcLength, 0)
wave        = ta.ema(rawMomentum, smoothLen)
signal      = ta.ema(wave, signalLen)

//==================================================
// COLORS
//==================================================
waveColor =
     wave >= 0 and wave > wave[1] ? waveBullStrong :
     wave >= 0 and wave <= wave[1] ? waveBullWeak :
     wave < 0 and wave < wave[1] ? waveBearStrong :
     waveBearWeak

dotColor =
     squeezeOn ? sqOnCol :
     squeezeOff ? sqOffCol :
     noSqCol

bgCol =
     wave > 0 ? bullBgColor :
     wave < 0 ? bearBgColor :
     neutralBgColor

fillCol = showFill ? color.new(waveColor, 82) : na

//==================================================
// PLOTS
//==================================================
zeroPlot   = plot(showZeroLine ? 0 : na, "Zero Line", color=zeroLineCol, linewidth=1)
wavePlot   = plot(showWave ? wave : na, "Wave", color=waveColor, linewidth=waveWidth)
signalPlot = plot(showSignal ? signal : na, "Signal", color=signalColor, linewidth=signalWidth)
dotPlot    = plot(showDots ? 0 : na, "Squeeze Dots", style=plot.style_circles, color=dotColor, linewidth=dotWidth)

fill(zeroPlot, wavePlot, color=fillCol)

bgcolor(showBg ? bgCol : na)
````
