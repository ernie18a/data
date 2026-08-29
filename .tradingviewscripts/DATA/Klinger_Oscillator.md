<!-- tradingview-pine-id: PUB;aca6867a9e37437e9c3faf48d8493d02 -->
<!-- tradingviewscripts-format: 1 -->
# + Klinger Oscillator

Source: https://www.tradingview.com/script/41E5Ocgx-Klinger-Oscillator/

## Description

This is a version of Stephen J. Klinger's, Klinger Oscillator (sometimes called Klinger Volume Oscillator). I've changed virtually nothing about the indicator itself, but added some lookback inputs for the EMAs the oscillator is derived from (traditionally 34 and 55), and added a few other things, as is my wont.

But what is the Klinger Oscillator? Essentially, the calculation looks at the high, low, and close of the current period, and compares that to the previous period's. If it is greater, it adds volume, and if it is less, it subtracts volume. It then takes an EMA of two different lookback periods of that calculation and subtracts one from the other. That's your oscillator. There is then made a signal line of the oscillator that a trader can use, in combination with the zero line, for taking trades. Investopedia has a good article on it, so if you're looking for more specifics, check there.

What I've done is add a selection of different moving averages that you may choose for the signal line. Usually it's a 13 period EMA, and that comes default, but here you could use an ALMA or HMA, or modular filter, etc. Find something that works for your style/algorithm.

Of course there are all the usual additions of mine with the various ways of coloring the indicator and candles, adjustable Donchian Bands, and alerts. A new addition that I've just added to all my indicators (oscillators, anyway) are divergences. This is more or less just a copy and paste of the divergence indicator available in TradingView. In this case you can set it to plot divergences off either the Klinger or the signal line. Depending on which one you choose you may have to adjust pivot lookbacks, and lookback range. I've kept the settings default from the RSI TradingView version.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Assembled by ©ClassicScott

// @version=6
indicator(title = '+ Klinger Oscillator', shorttitle = '+ KVO', format = format.volume, timeframe = '')
import ClassicScott/MyMovingAveragesLibrary/4 as mymas
import ClassicScott/MyVolatilityBands/7 as volbands

//----- Inputs
barColor         = input.bool     (title = 'Bar Color', defval = true, group = 'Klinger Oscillator')
useSmoothed      = input.bool     (title = 'Indicator Smoothing', defval = true, group = 'Klinger Oscillator', tooltip = 'Checking this will turn off the standard KVO. The assumption is you will use a smoothed version as your primary indicator.')
src              = input          (title = 'Source', defval = close, group = 'Klinger Oscillator')
period1          = input.int      (title = 'EMA 1 Period', defval = 34, group = 'Klinger Oscillator', tooltip = 'The Klinger Volume Oscillator is the difference between two exponential moving averages of different lengths. Standards are 34 and 55.')
period2          = input.int      (title = 'EMA 2 Period', defval = 55, group = 'Klinger Oscillator')
colorSelectInput = input.string   (title = 'Color Reference', defval = 'Centerline', options = ['Centerline', 'Signal Line', 'Donchian Channel Basis', 'Channel / Bands Range'], group = 'Klinger Oscillator', tooltip = 'All of these options, with the exception of \'Channel / Bands Range\', should be self-explanatory. Selecting \'Channel / Bands Range\' simply colors the KVO differently if it reaches the Donchian Channel or Bollinger Bands extremes.')
timeframeInput   = input.timeframe(title = 'Timeframe Reference for Indicator Color', defval = '', group = 'Klinger Oscillator', tooltip = 'Pick your timeframe and the KVO and bars, if bar color is selected, will be colored based on the relation of the current KVO to whatever you selected for the color reference of this other timeframe.')


//------------------------------------------------------------------------------
//----- Moving average inputs for smoothed klinger oscillator or signal line 1
showSmoothed   = input.bool  (title = '', defval = true, group = 'Smoothed Klinger Oscillator', tooltip = 'Use this as a signal line for the KVO, or as a smoothed version to reduce chop and false signals.')
smoothedType   = input.string(title = 'Type     ', defval = 'Jurik - JMA', options = ['Arnaud Legoux - ALMA', 'Exponential - EMA', 'Double Exponential - DEMA', 'Triple Exponential - EMA', 'Fractal Adaptive - FRAMA', 'Kaufman Adaptive - KAMA', 'Hull - HMA', 'Jurik - JMA', 'Laguerre Filter', 'Least Squares - LSMA', 'McGinley Dynamic', 'Modular Filter', 'RexDog - RDMA', 'Simple - SMA', 'Smoothed - SMMA', 'Tillson T3', 'Triangular - TMA', 'Volatility-Adjusted - VAMA', 'Volume-Weighted - VWMA', 'Weighted - WMA', 'Zero-Lag - ZLMA'], inline = 'type', group = 'Smoothed Klinger Oscillator')
smoothedPeriod = input.int   (title = 'Period', defval = 3, inline = 'period', group = 'Smoothed Klinger Oscillator')

//----- Further moving average inputs for those that require more than just a period
//--- ALMA - arnaud legoux
almaOffset = input.float(title = 'ALMA Offset     ', defval = 0.85, step = 0.05, inline = 'alma', group = 'Additional Smoothed Klinger Oscillator Inputs')
sigma      = input.float(title = 'ALMA Sigma        ', defval = 6, step = 0.5, inline = 'alma', group = 'Additional Smoothed Klinger Oscillator Inputs')

//--- FRAMA - fractal adaptive
fc = input.int(title = 'FRAMA Fast Period ', defval = 34, minval = 1, inline = 'frama', group = 'Additional Smoothed Klinger Oscillator Inputs')
sc = input.int(title = 'FRAMA Slow Period', defval = 89, minval = 1, inline = 'frama', group = 'Additional Smoothed Klinger Oscillator Inputs')

//--- KAMA - kaufman adaptive
fl = input.float(title = 'KAMA Fast End     ', defval = 0.7, minval = 0.01, step = 0.01, inline = 'kama', group = 'Additional Smoothed Klinger Oscillator Inputs')
sl = input.float(title = 'KAMA Slow End      ', defval = 0.065, minval = 0.01, step = 0.0025, inline = 'kama', group = 'Additional Smoothed Klinger Oscillator Inputs')

//--- JMA - jurik
phase = input.int  (title = 'Jurik Phase      ', defval = 1, minval = -100, maxval = 100, inline = 'jma', group = 'Additional Smoothed Klinger Oscillator Inputs')
power = input.float(title = 'Jurik Power           ', defval = 1, minval = 0.1, maxval = 10, step = 0.1, inline = 'jma', group = 'Additional Smoothed Klinger Oscillator Inputs')

//--- Laguerre Filter
laguerreAlpha = input.float(title = 'Laguerre Filter Alpha ', defval = 0.7, minval = 0, maxval = 1, step = 0.025, inline = 'laguerre', group = 'Additional Smoothed Klinger Oscillator Inputs')

//--- LSMA - least squares
lsmaOffset = input.int(title = 'Least Squares Offset  ', defval = 9, inline = 'lsma', group = 'Additional Smoothed Klinger Oscillator Inputs')

//--- MF - modular filter
beta      = input.float(title = 'Modular Filter Beta  ', defval = 0.5, maxval = 1, step = 0.05, inline = 'mf', group = 'Additional Smoothed Klinger Oscillator Inputs')
feedback  = input.bool (title = 'Modular Filter Feedback', defval = true, inline = 'mf', group = 'Additional Smoothed Klinger Oscillator Inputs')
weighting = input.float(title = 'Modular Filter Feedback Weighting      ', defval = 0.2, step = 0.1, minval = 0, maxval = 1, inline = 'mf', group = 'Additional Smoothed Klinger Oscillator Inputs')

//--- VAMA - volatility-adjusted
vamaPeriod = input.int(title = 'Volatility Adjusted Period         ', defval = 21, minval = 1, inline = 'vama', group = 'Additional Smoothed Klinger Oscillator Inputs')


//------------------------------------------------------------------------------
//----- Moving average inputs for signal line 2
showSignal      = input.bool  (title = '', defval = true, group = 'Signal Line', tooltip = 'A signal line for the smoothed KVO, or a second signal line for the standard version if you like.')
signalFillInput = input.bool  (title = 'Signal Line Fill', defval = false, group = 'Signal Line', tooltip = 'Adds a color fill between the smoothed KVO and the signal line.')
signalType      = input.string(title = 'Type     ', defval = 'Jurik - JMA', options = ['Arnaud Legoux - ALMA', 'Exponential - EMA', 'Double Exponential - DEMA', 'Triple Exponential - EMA', 'Fractal Adaptive - FRAMA', 'Kaufman Adaptive - KAMA', 'Hull - HMA', 'Jurik - JMA', 'Laguerre Filter', 'Least Squares - LSMA', 'McGinley Dynamic', 'Modular Filter', 'RexDog - RDMA', 'Simple - SMA', 'Smoothed - SMMA', 'Tillson T3', 'Triangular - TMA', 'Volatility-Adjusted - VAMA', 'Volume-Weighted - VWMA', 'Weighted - WMA', 'Zero-Lag - ZLMA'], inline = 'signal', group = 'Signal Line')
signalPeriod    = input.int   (title = 'Period', defval = 21, inline = 'period', group = 'Signal Line')

//----- Further moving average inputs for those that require more than just a period
//--- ALMA - arnaud legoux
almaOffset2 = input.float(title = 'ALMA Offset     ', defval = 0.85, step = 0.05, inline = 'alma', group = 'Additional Signal Line Inputs')
sigma2      = input.float(title = 'ALMA Sigma        ', defval = 6, step = 0.5, inline = 'alma', group = 'Additional Signal Line Inputs')

//--- FRAMA - fractal adaptive
fc2 = input.int(title = 'FRAMA Fast Period ', defval = 34, minval = 1, inline = 'frama', group = 'Additional Signal Line Inputs')
sc2 = input.int(title = 'FRAMA Slow Period', defval = 89, minval = 1, inline = 'frama', group = 'Additional Signal Line Inputs')

//--- KAMA - kaufman adaptive
fl2 = input.float(title = 'KAMA Fast End     ', defval = 0.7, minval = 0.01, step = 0.01, inline = 'kama', group = 'Additional Signal Line Inputs')
sl2 = input.float(title = 'KAMA Slow End      ', defval = 0.065, minval = 0.01, step = 0.0025, inline = 'kama', group = 'Additional Signal Line Inputs')

//--- JMA - jurik
phase2 = input.int  (title = 'Jurik Phase      ', defval = 1, minval = -100, maxval = 100, inline = 'jma', group = 'Additional Signal Line Inputs')
power2 = input.float(title = 'Jurik Power           ', defval = 1, minval = 0.1, maxval = 10, step = 0.1, inline = 'jma', group = 'Additional Signal Line Inputs')

//--- Laguerre Filter
laguerreAlpha2 = input.float(title = 'Laguerre Filter Alpha ', defval = 0.7, minval = 0, maxval = 1, step = 0.025, inline = 'laguerre', group = 'Additional Signal Line Inputs')

//--- LSMA - least squares
lsmaOffset2 = input.int(title = 'Least Squares Offset  ', defval = 9, inline = 'lsma', group = 'Additional Signal Line Inputs')

//--- MF - modular filter
beta2      = input.float(title = 'Modular Filter Beta  ', defval = 0.5, maxval = 1, step = 0.05, inline = 'mf', group = 'Additional Signal Line Inputs')
feedback2  = input.bool (title = 'Modular Filter Feedback', defval = true, inline = 'mf', group = 'Additional Signal Line Inputs')
weighting2 = input.float(title = 'Modular Filter Feedback Weighting      ', defval = 0.2, step = 0.1, minval = 0, maxval = 1, inline = 'mf', group = 'Additional Signal Line Inputs')

//--- VAMA - volatility-adjusted
vamaPeriod2 = input.int(title = 'Volatility Adjusted Period         ', defval = 21, minval = 1, inline = 'vama', group = 'Additional Signal Line Inputs')


//------------------------------------------------------------------------------
//----- Bollinger bands and donchian channel inputs
showBands   = input.bool  (title = '', defval = false, group = 'Bollinger Bands & Donchian Channel')
bandsType   = input.string(title = 'Type', defval = 'Donchian Channel', options = ['Bollinger Bands', 'Donchian Channel'], group = 'Bollinger Bands & Donchian Channel')
bandsPeriod = input.int   (title = 'Period', defval = 20, group = 'Bollinger Bands & Donchian Channel')
bandsMult   = input.float (title = 'Multiplier', defval = 2, step = 0.25, group = 'Bollinger Bands & Donchian Channel', tooltip = 'Standard deviation multiplier for Bollinger Bands.')
bandsWidth  = input.float (title = 'Band Thickness', defval = 10, step = 0.5, group = 'Bollinger Bands & Donchian Channel', tooltip = 'Defines the thickness of the band. Larger number is thinner.')
showBasis   = input.bool  (title = 'Display Basis', defval = false, group = 'Bollinger Bands & Donchian Channel', tooltip = 'Ignore this if using Bollinger Bands as the basis for these is the signal line.')


//------------------------------------------------------------------------------
//----- Klinger Oscillator itself
var cumVol = 0.
cumVol := cumVol + nz(volume)
sv = ta.change(src) >= 0 ? volume : -volume
kvo = ta.ema(sv, period1) - ta.ema(sv, period2)


//------------------------------------------------------------------------------
//----- Switch operation for selecting the smoothed kvo or signal line 1
smoothedKVO = switch smoothedType
    
    'Arnaud Legoux - ALMA'       => mymas.alma    (kvo, smoothedPeriod, almaOffset, sigma)
    'Exponential - EMA'          => mymas.ema     (kvo, smoothedPeriod)
    'Double Exponential - DEMA'  => mymas.dema    (kvo, smoothedPeriod)
    'Triple Exponential - EMA'   => mymas.tema    (kvo, smoothedPeriod)
    'Fractal Adaptive - FRAMA'   => mymas.frama   (kvo, smoothedPeriod, fc, sc)
    'Kaufman Adaptive - KAMA'    => mymas.kama    (kvo, smoothedPeriod, fl, sl)
    'Hull - HMA'                 => mymas.hma     (kvo, smoothedPeriod)
    'Jurik - JMA'                => mymas.jma     (kvo, smoothedPeriod, phase, power)
    'Laguerre Filter'            => mymas.laguerre(kvo, laguerreAlpha)
    'Least Squares - LSMA'       => mymas.lsma    (kvo, smoothedPeriod, lsmaOffset)
    'McGinley Dynamic'           => mymas.mcginley(kvo, smoothedPeriod)
    'Modular Filter'             => mymas.mf      (kvo, smoothedPeriod, feedback, beta, weighting)
    'RexDog - RDMA'              => mymas.rdma    (kvo)
    'Simple - SMA'               => mymas.sma     (kvo, smoothedPeriod)
    'Smoothed - SMMA'            => mymas.smma    (kvo, smoothedPeriod)
    'Tillson T3'                 => mymas.t3      (kvo, smoothedPeriod)
    'Triangular - TMA'           => mymas.tma     (kvo, smoothedPeriod)
    'Volatility-Adjusted - VAMA' => mymas.vama    (kvo, smoothedPeriod, vamaPeriod)
    'Volume-Weighted - VWMA'     => mymas.vwma    (kvo, smoothedPeriod)
    'Weighted - WMA'             => mymas.wma     (kvo, smoothedPeriod)
    'Zero-Lag - ZLMA'            => mymas.zlma    (kvo, smoothedPeriod)
    => 
        runtime.error("No matching MA type found.")
        float(na)


//------------------------------------------------------------------------------
//----- Switch operation for selecting the signal line on the smoothed kvo
signalLine = switch signalType
    
    'Arnaud Legoux - ALMA'       => mymas.alma    (smoothedKVO, signalPeriod, almaOffset2, sigma2)
    'Exponential - EMA'          => mymas.ema     (smoothedKVO, signalPeriod)
    'Double Exponential - DEMA'  => mymas.dema    (smoothedKVO, signalPeriod)
    'Triple Exponential - EMA'   => mymas.tema    (smoothedKVO, signalPeriod)
    'Fractal Adaptive - FRAMA'   => mymas.frama   (smoothedKVO, signalPeriod, fc2, sc2)
    'Kaufman Adaptive - KAMA'    => mymas.kama    (smoothedKVO, signalPeriod, fl2, sl2)
    'Hull - HMA'                 => mymas.hma     (smoothedKVO, signalPeriod)
    'Jurik - JMA'                => mymas.jma     (smoothedKVO, signalPeriod, phase2, power2)
    'Laguerre Filter'            => mymas.laguerre(smoothedKVO, laguerreAlpha2)
    'Least Squares - LSMA'       => mymas.lsma    (smoothedKVO, signalPeriod, lsmaOffset2)
    'McGinley Dynamic'           => mymas.mcginley(smoothedKVO, signalPeriod)
    'Modular Filter'             => mymas.mf      (smoothedKVO, signalPeriod, feedback2, beta2, weighting2)
    'RexDog - RDMA'              => mymas.rdma    (smoothedKVO)
    'Simple - SMA'               => mymas.sma     (smoothedKVO, signalPeriod)
    'Smoothed - SMMA'            => mymas.smma    (smoothedKVO, signalPeriod)
    'Tillson T3'                 => mymas.t3      (smoothedKVO, signalPeriod)
    'Triangular - TMA'           => mymas.tma     (smoothedKVO, signalPeriod)
    'Volatility-Adjusted - VAMA' => mymas.vama    (smoothedKVO, signalPeriod, vamaPeriod2)
    'Volume-Weighted - VWMA'     => mymas.vwma    (smoothedKVO, signalPeriod)
    'Weighted - WMA'             => mymas.wma     (smoothedKVO, signalPeriod)
    'Zero-Lag - ZLMA'            => mymas.zlma    (smoothedKVO, signalPeriod)
    => 
        runtime.error("No matching MA type found.")
        float(na)


//------------------------------------------------------------------------------
//----- Switch operation for selecting bollinger bands or donchian channel 
[basis, upper, lower, innerUpper, innerLower] = switch bandsType
    'Bollinger Bands'  => (volbands.bollingerbands (useSmoothed ? smoothedKVO : kvo, bandsPeriod, bandsMult, useSmoothed ? signalLine : smoothedKVO, bandsWidth))
    'Donchian Channel' => (volbands.donchianchannel(useSmoothed ? smoothedKVO : kvo, bandsPeriod, bandsWidth))
    =>
        runtime.error("No matching bands or channel type found.")
        [na, na, na, na, na]


//------------------------------------------------------------------------------
//----- Color variables
colorOb         = color.new(#445b84, 25)
colorUp         = color.new(#445b84, 0)
colorNeut       = color.new(#808080, 0)
colorDown       = color.new(#844444, 0)
colorOs         = color.new(#844444, 25)
signalColorUp   = color.new(#448484, 50)
signalColorDown = color.new(#5a4484, 50)
ribbonColorUp   = color.new(#448484, 75)
ribbonColorDown = color.new(#5a4484, 75)
xUpColor        = color.new(#ffffff, 50)
xDownColor      = color.new(#000000, 50)


//------------------------------------------------------------------------------
//----- if statements determining how to color kvo depending on if smoothing is or is not being used
kvoColor1  = if useSmoothed
    color1 = request.security(syminfo.tickerid, timeframeInput, smoothedKVO > 0 ? colorUp : smoothedKVO < 0 ? colorDown : na)
else
    color1 = request.security(syminfo.tickerid, timeframeInput, kvo > 0 ? colorUp : kvo < 0 ? colorDown : na)

kvoColor2  = if useSmoothed
    color2 = request.security(syminfo.tickerid, timeframeInput, smoothedKVO > 0 and smoothedKVO > signalLine ? colorUp : smoothedKVO < 0 and smoothedKVO < signalLine ? colorDown : colorNeut)
else
    color2 = request.security(syminfo.tickerid, timeframeInput, kvo > 0 and kvo > smoothedKVO ? colorUp : kvo < 0 and kvo < smoothedKVO ? colorDown : colorNeut)

kvoColor3  = if useSmoothed
    color3 = request.security(syminfo.tickerid, timeframeInput, smoothedKVO > 0 and smoothedKVO > basis ? colorUp : smoothedKVO < 0 and smoothedKVO < basis ? colorDown : colorNeut)
else
    color3 = request.security(syminfo.tickerid, timeframeInput, kvo > 0 and kvo > basis ? colorUp : kvo < 0 and kvo < basis ? colorDown : colorNeut)

kvoColor4  = if useSmoothed
    color4 = request.security(syminfo.tickerid, timeframeInput, smoothedKVO > 0 and smoothedKVO <= innerLower or smoothedKVO < 0 and smoothedKVO >= innerUpper ? colorNeut : smoothedKVO > 0 and smoothedKVO >= innerUpper ? colorOb : smoothedKVO > 0 and smoothedKVO < innerUpper ? colorUp : smoothedKVO < 0 and smoothedKVO > innerLower ? colorDown : smoothedKVO < 0 and smoothedKVO <= innerLower ? colorOs : na)
else
    color4 = request.security(syminfo.tickerid, timeframeInput, kvo > 0 and kvo <= innerLower or kvo < 0 and kvo >= innerUpper ? colorNeut : kvo > 0 and kvo >= innerUpper ? colorOb : kvo > 0 and kvo < innerUpper ? colorUp : kvo < 0 and kvo > innerLower ? colorDown : kvo < 0 and kvo <= innerLower ? colorOs : na)


//----- if statements determining how to color the signal line depending on if smoothing is or is not being used
smoothedColor = if useSmoothed
    color     = request.security(syminfo.tickerid, timeframeInput, signalLine > signalLine[1] ? signalColorUp : signalColorDown)
else
    color     = request.security(syminfo.tickerid, timeframeInput, smoothedKVO > smoothedKVO[1] ? signalColorUp : signalColorDown)


//----- signal color for signal line on smoothed kvo or as a secondary signal line if not smoothed
signalColor = request.security(syminfo.tickerid, timeframeInput, signalLine > signalLine[1] ? signalColorUp : signalColorDown)


//----- the rest
signalFill  = signalFillInput ? smoothedKVO > signalLine ? ribbonColorUp : ribbonColorDown : na

colorSelect = colorSelectInput == 'Centerline' ? kvoColor1 :
              colorSelectInput == 'Signal Line' ? kvoColor2 :
              colorSelectInput == 'Donchian Channel Basis' ? kvoColor3 :
              colorSelectInput == 'Channel / Bands Range' ? kvoColor4 :
              na


//------------------------------------------------------------------------------
//----- Signal line crosses
smoothedXUp   = ta.crossover (useSmoothed ? smoothedKVO : kvo, useSmoothed ? signalLine : smoothedKVO)
smoothedXDown = ta.crossunder(useSmoothed ? smoothedKVO : kvo, useSmoothed ? signalLine : smoothedKVO)


//------------------------------------------------------------------------------
//----- Visuals
//--- Plots, bar color, shapes
plot(title = 'Klinger Oscillator', series = useSmoothed ? na : kvo, color = colorSelect)

smoothed = plot(title = 'Smoothed Klinger Oscillator', series = showSmoothed ? smoothedKVO : useSmoothed and not showSmoothed ? smoothedKVO : na, color = useSmoothed ? colorSelect : smoothedColor)
signal   = plot(title = 'Signal Line', series = showSignal ? signalLine : na, color = signalColor)

barcolor (title = 'Bar Color', color = barColor ? colorSelect : na)

plotshape(title = '+ Signal Line Cross', series = not useSmoothed and showSmoothed ? smoothedXUp : useSmoothed and showSignal ? smoothedXUp : bool(na), style = shape.circle, location = location.bottom, color = xUpColor)
plotshape(title = '- Signal Line Cross', series = not useSmoothed and showSmoothed ? smoothedXDown : useSmoothed and showSignal ? smoothedXDown : bool(na), style = shape.circle, location = location.top, color = xDownColor)

//--- Channel/bands plots
plot(title = 'Basis', series = showBasis ? basis : na, color = color.new(#808080, 50))

upperPlot      = plot(title = 'Upper Band', series = showBands ? upper : na, color = colorNeut, display = display.none)
innerUpperPlot = plot(title = 'Inner Upper Band', series = showBands ? innerUpper : na, color = colorNeut, display = display.none)
innerLowerPlot = plot(title = 'Inner Lower Band', series = showBands ? innerLower : na, color = colorNeut, display = display.none)
lowerPlot      = plot(title = 'Lower Band', series = showBands ? lower : na, color = colorNeut, display = display.none)

//--- Fills
fill(smoothed, signal, color = signalFill, title = 'Signal Line Ribbon')
fill(upperPlot, innerUpperPlot, color = color.new(#808080, 50), title = 'Upper Bands Fill')
fill(lowerPlot, innerLowerPlot, color = color.new(#808080, 50), title = 'Lower Bands Fill')

hline(0, linestyle = hline.style_dotted, color = #000000)


//------------------------------------------------------------------------------
//----- Divergences
//--- is the KVO smoothed or not?
kvoType = if useSmoothed
    smoothedKVO
else
    kvo
    
//-----
lbR            = input(title = 'Pivot Period Right', defval = 5, group = 'Divergences')
lbL            = input(title = 'Pivot Period Left', defval = 5, group = 'Divergences')
rangeUpper     = input(title = 'Max of Period Range', defval = 60, group = 'Divergences')
rangeLower     = input(title = 'Min of Period Range', defval = 5, group = 'Divergences')
plotBull       = input(title = 'Bullish', defval = false, group = 'Divergences')
plotHiddenBull = input(title = 'Hidden Bullish', defval = false, group = 'Divergences')
plotBear       = input(title = 'Bearish', defval = false, group = 'Divergences')
plotHiddenBear = input(title = 'Hidden Bearish', defval = false, group = 'Divergences')

bearColor       = #844444
bullColor       = #445b84
hiddenBullColor = color.new(#445b84, 80)
hiddenBearColor = color.new(#844444, 80)
textColor       = color.white
noneColor       = color.new(color.white, 100)

plFound = na(ta.pivotlow(kvoType, lbL, lbR)) ? false : true
phFound = na(ta.pivothigh(kvoType, lbL, lbR)) ? false : true

_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper

//------------------------------------------------------------------------------
//----- Regular Bullish
//--- kvoType: Higher Low
inRangePl = _inRange(plFound[1])
kvoTypeHL = kvoType[lbR] > ta.valuewhen(plFound, kvoType[lbR], 1) and inRangePl

//--- Price: Lower Low

priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
bullCondAlert = priceLL and kvoTypeHL and plFound
bullCond = plotBull and bullCondAlert

plot(
     plFound ? kvoType[lbR] : na,
     offset = -lbR,
     title = 'Regular Bullish',
     linewidth = 2,
     color = (bullCond ? bullColor : noneColor),
 display = display.pane,
 editable = plotBull
     )

plotshape(
 bullCond ? kvoType[lbR] : na,
 offset = -lbR,
 title = 'Regular Bullish Label',
 text = ' Bull ',
 style = shape.labelup,
 location = location.absolute,
 color = bullColor,
 textcolor = textColor,
 editable = plotBull
 )

//------------------------------------------------------------------------------
//----- Hidden Bullish
//--- kvoType: Lower Low

kvoTypeLL = kvoType[lbR] < ta.valuewhen(plFound, kvoType[lbR], 1) and inRangePl

//--- Price: Higher Low

priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
hiddenBullCondAlert = priceHL and kvoTypeLL and plFound
hiddenBullCond = plotHiddenBull and hiddenBullCondAlert

plot(
 plFound ? kvoType[lbR] : na,
 offset = -lbR,
 title = 'Hidden Bullish',
 linewidth = 2,
 color = (hiddenBullCond ? hiddenBullColor : noneColor),
 display = display.pane,
 editable = plotHiddenBull
 )

plotshape(
 hiddenBullCond ? kvoType[lbR] : na,
 offset = -lbR,
 title = 'Hidden Bullish Label',
 text = ' H Bull ',
 style = shape.labelup,
 location = location.absolute,
 color = bullColor,
 textcolor = textColor,
 editable = plotHiddenBull
 )

//------------------------------------------------------------------------------
//----- Regular Bearish
//--- kvoType: Lower High
inRangePh = _inRange(phFound[1])
kvoTypeLH = kvoType[lbR] < ta.valuewhen(phFound, kvoType[lbR], 1) and inRangePh

//--- Price: Higher High

priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)

bearCondAlert = priceHH and kvoTypeLH and phFound
bearCond = plotBear and bearCondAlert

plot(
 phFound ? kvoType[lbR] : na,
 offset = -lbR,
 title = 'Regular Bearish',
 linewidth = 2,
 color = (bearCond ? bearColor : noneColor),
 display = display.pane,
 editable = plotBear
 )

plotshape(
 bearCond ? kvoType[lbR] : na,
 offset = -lbR,
 title = 'Regular Bearish Label',
 text = ' Bear ',
 style = shape.labeldown,
 location = location.absolute,
 color = bearColor,
 textcolor = textColor,
 editable = plotBear
 )

//------------------------------------------------------------------------------
//----- Hidden Bearish
//--- kvoType: Higher High

kvoTypeHH = kvoType[lbR] > ta.valuewhen(phFound, kvoType[lbR], 1) and inRangePh

//--- Price: Lower High

priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)

hiddenBearCondAlert = priceLH and kvoTypeHH and phFound
hiddenBearCond = plotHiddenBear and hiddenBearCondAlert

plot(
 phFound ? kvoType[lbR] : na,
 offset = -lbR,
 title = 'Hidden Bearish',
 linewidth = 2,
 color = (hiddenBearCond ? hiddenBearColor : noneColor),
 display = display.pane,
 editable = plotHiddenBear
 )

plotshape(
 hiddenBearCond ? kvoType[lbR] : na,
 offset = -lbR,
 title = 'Hidden Bearish Label',
 text = ' H Bear ',
 style = shape.labeldown,
 location = location.absolute,
 color = bearColor,
 textcolor = textColor,
 editable = plotHiddenBear
 )


//------------------------------------------------------------------------------
//----- Alerts
alertcondition(ta.cross(useSmoothed ? smoothedKVO : kvo, 0),     title = 'KVO Crossing Centerline', message = 'KVO has crossed the centerline.')
alertcondition(ta.cross(useSmoothed ? smoothedKVO : kvo, basis), title = 'KVO Crossing Basis',      message = 'KVO has crossed the basis.')

alertcondition(ta.cross(useSmoothed ? smoothedKVO : kvo, useSmoothed ? signalLine : smoothedKVO), title = 'KVO Crossing Signal Line', message = 'KVO has crossed the signal line.')

alertcondition(ta.cross(useSmoothed ? smoothedKVO : kvo, innerUpper), title = 'KVO Crossing Upper Band', message = 'KVO is at the upper band.')
alertcondition(ta.cross(useSmoothed ? smoothedKVO : kvo, innerLower), title = 'KVO Crossing Lower Band', message = 'KVO is at the lower band.')

alertcondition(bullCondAlert,       title = 'Bull Div', message = 'KVO bull div')
alertcondition(bearCondAlert,       title = 'Bear Div', message = 'KVO bear div')
alertcondition(hiddenBullCondAlert, title = 'Hidden Bull Div', message = 'KVO hidden bull div')
alertcondition(hiddenBearCondAlert, title = 'Hidden Bear Div', message = 'KVO hidden bear div')
````
