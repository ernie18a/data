# + Ultimate Momentum Oscillator

- url: https://www.tradingview.com/script/RHWqwwS8-Ultimate-Momentum-Oscillator/
- type: indicator
- pine_id: PUB;7a153318cd554bc1b71456170f064777
- version: 1.0

## Description

The Ultimate Momentum Oscillator is meant to be a companion piece to my Ultimate Moving Average (the any-moving-average-you-want-it-to-be moving average). It is comprised of two components: 1) the actual plotted indicator which oscillates around a zero line depending on the slope of your defined UMA, and 2) the two color sources based around bias and momentum, or volatility.

A quick description of how my UMA works, and how this indicator incorporates it: The UMA is a user-chosen moving average type applied across five different periods, with the resulting five averages blended together. The default option is an EMA with periods of 8, 21, 55, 144, and 233, but you could pick an SMA, a Hull MA, Zero-lag, Tillson T3, Fractal Adaptive, or several others. Additionally, you can de-blend it by making all the periods the same. If you want a 20 period SMA just make all the periods 20. In addition to this, a channel is created by calculating the UMA separately from the highs and lows. The primary UMA is the average of the resulting high and low UMAs. The UMO simply represents the rate of change—or, in practical terms, the slope—of your UMA as a histogram in a separate pane. When the average is sloping up the histogram is above zero, and vice versa when the average is sloping down. Below are a couple of screens showing both the UMA and UMO set to more commonly used moving averages. Top images is a 21 period EMA, and the bottom image is a 100 period SMA.
[image]https://www.tradingview.com/x/ta37L6cj/[/image]
[image]https://www.tradingview.com/x/hD4gixQa/[/image]

Now to describe the second part of the indicator, the color sources, and how they can help you when deciding about where to enter a trade, or [i]if[/i] you should enter a trade. There are two color sources, as stated above. One depicts bias and momentum, while the other gives information about volatility. We'll start with Bias + Momentum. I define bias as closing price's relative position to the UMA channel. This is pretty obvious stuff, but above the channel high would be bullish and below the channel low is bearish, while stuck between would be defined as indecisive or a state of transition. Momentum is the rate of change of the moving average. Color is comprised of five different swatches relating to different states: bullish = bullish bias and upward momentum; weak bullish = bullish bias and downward momentum; bearish = bearish bias and downward momentum; weak bearish = bearish bias and upward momentum; and lastly, neutral is price inside the channel. How you use these color clues in combination with the directionality of the histogram and the type of UMA you've created is of course up to you. With the default settings the UMA is best used, along with market structure, as a bias guide, and that bias most of the time trumps shifts in momentum. Being aware of higher timeframe points of interest is important here because these are areas where shifts in momentum can coincide with, or precede, a change in bias—sometimes very quickly and abruptly.

The second color source, volatility, is meant to help the trader, depending on his/her trading style, make a determination about whether a trade should or should not be entered. One can take this information and transpose it to a lower timeframe. Is the market dead on a higher timeframe? Maybe there are opportunities to play the range on a lower timeframe. Is volatility high and bias + momentum clearly directional? There may be possibilities of trading in alignment with that bias + momentum, with the expectation that market structure continues to develop in that direction.

Volatility is measured in this case using the width of the UMA channel. The current width is normalized relative to its recent range to produce a volatility state, which is then used to control the color intensity of the UMO. Because this channel is created by the average of high and low prices one can use it as a gauge for volatility. A relatively wide channel indicates that volatility is elevated compared with its recent range, while a relatively narrow channel indicates lower volatility. Because channel width can also be changing over time, a widening channel generally indicates increasing volatility, while a narrowing channel indicates decreasing volatility. All of this is visualized through a single color gradient of the UMO where a more solid color equates to greater volatility and vice versa for a fainter color.

In addition to this, I've added optional bar coloring so that you can have the indicator display one piece of information while the candles visualize something else. See images below.
[image]https://www.tradingview.com/x/1sUeXbmI/[/image]
[image]https://www.tradingview.com/x/KOlKA75V/[/image]

I believe that covers everything. As always, thank you, and I hope this provides edge in your trading!

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Assembled by ©ClassicScott

// @version=6
indicator('+ Ultimate Momentum Oscillator', shorttitle = '+ UMO', timeframe = '', overlay = false, precision = 4)
import ClassicScott/MyMovingAveragesLibrary/4 as mymas
import ClassicScott/MyVolatilityBands/7 as volbands

//----- General inputs
momPeriod     = input.int   (title  = 'Momentum Period',      defval = 3, group = 'General Inputs',
                            tooltip = '''Momentum in this instance is simply a measurement of the rate of change of the UMA. Depending on how you trade, what your settings 
for the UMA are, how reactive you want the indicator to be, etc., you may want this to be larger or smaller. As a general rule, the greater the period for your UMA the lower you may want this to be.''')
widthPeriod   = input.int   (title  = 'Channel Width Period', defval = 8, group = 'General Inputs',
                            tooltip = '''Determines the number of bars used to measure changes in the width of the UMA channel. Channel width is used as a measure of volatility,
with shorter periods producing a more responsive measurement and longer periods providing a broader comparison.''')
colorSrcInput = input.string(title  = 'Color Source',         defval = 'Bias + Momentum', options = ['Bias + Momentum', 'Volatility'], group = 'General Inputs',
                            tooltip = '''Choose what you want the indicator's color to represent. This can either be Bias + Momentum or Volatility. When Bias + Momentum is
selected, lighter colors indicate a momentum shift that conflicts with the current bias. For example, price may be below the UMA channel while the UMA has begun pointing upward.
Additionally, if price is within the channel, a neutral color is applied. If Volatility is selected, see the Transparency tooltip under Volatility Color below."''')
barColorSrc   = input.string(title = 'Bar Color Source',      defval = 'None', options = ['Bias + Momentum', 'Volatility', 'None'], group = 'General Inputs')


//----- Color inputs
bullC     = input.color(title = '+',                 defval = color.new(#445b84, 0),  inline = 'bull', group = 'Bias + Momentum Colors')
lessBullC = input.color(title = '+ Shift',           defval = color.new(#445b84, 50), inline = 'bull', group = 'Bias + Momentum Colors')
bearC     = input.color(title = '-',                 defval = color.new(#844444, 0),  inline = 'bear', group = 'Bias + Momentum Colors')
lessBearC = input.color(title = '   - Shift',        defval = color.new(#844444, 50), inline = 'bear', group = 'Bias + Momentum Colors')
neutC     = input.color(title = '       Indecision', defval = color.new(#4a4a4a, 50), inline = 'n',    group = 'Bias + Momentum Colors')
volC      = input.color(title = '',                  defval = #4a4a4a,                inline = 'vol',  group = 'Volatility Color')
volT      = input.int  (title = 'Transparency',      defval = 80,                       inline = 'vol',  group = 'Volatility Color',
                      tooltip = 'When Volatility is selected as the color source, Transparency sets the opacity of the lowest volatility level. Higher volatility produces a more solid color.')


//----- UMA type and periods inputs
umaType = input.string(title = 'Type', defval = 'Exponential - EMA', options = ['Arnaud Legoux - ALMA', 'Exponential - EMA', 'Double Exponential - DEMA', 'Triple Exponential - EMA', 'Fractal Adaptive - FRAMA', 'Kaufman Adaptive - KAMA', 'Hull - HMA', 'Jurik - JMA', 'Least Squares - LSMA', 'McGinley Dynamic', 'Modular Filter', 'Simple - SMA', 'Smoothed - SMMA', 'Tillson T3', 'Triangular - TMA', 'Volatility-Adjusted - VAMA', 'Volume-Weighted - VWMA', 'Weighted - WMA', 'Zero-Lag - ZLMA'], group = 'UMA Inputs',
                            tooltip = 'Select which moving average type you\'ve made a UMA of.')

period1 = input.int(title = 'Period 1', defval = 8,   group = 'UMA Inputs')
period2 = input.int(title = 'Period 2', defval = 21,  group = 'UMA Inputs')
period3 = input.int(title = 'Period 3', defval = 55,  group = 'UMA Inputs')
period4 = input.int(title = 'Period 4', defval = 144, group = 'UMA Inputs')
period5 = input.int(title = 'Period 5', defval = 233, group = 'UMA Inputs')


//----- Further moving average inputs for those that require more than just a source and period
//--- ALMA - arnaud legoux
almaOffset = input.float(title = 'ALMA Offset     ', defval = 0.85, step = 0.05, inline = 'alma', group = 'Additional Moving Average Inputs')
sigma      = input.float(title = 'ALMA Sigma        ', defval = 6, step = 0.5, inline = 'alma', group = 'Additional Moving Average Inputs')

//--- FRAMA - fractal adaptive
fc = input.int(title = 'FRAMA Fast Period ', defval = 34, minval = 1, inline = 'frama', group = 'Additional Moving Average Inputs')
sc = input.int(title = 'FRAMA Slow Period', defval = 89, minval = 1, inline = 'frama', group = 'Additional Moving Average Inputs')

//--- KAMA - kaufman adaptive
fl = input.float(title = 'KAMA Fast End     ', defval = 0.7, minval = 0.01, step = 0.01, inline = 'kama', group = 'Additional Moving Average Inputs')
sl = input.float(title = 'KAMA Slow End      ', defval = 0.065, minval = 0.01, step = 0.0025, inline = 'kama', group = 'Additional Moving Average Inputs')

//--- JMA - jurik
phase = input.int  (title = 'Jurik Phase      ', defval = 1, minval = -100, maxval = 100, inline = 'jma', group = 'Additional Moving Average Inputs')
power = input.float(title = 'Jurik Power           ', defval = 1, minval = 0.1, maxval = 10, step = 0.1, inline = 'jma', group = 'Additional Moving Average Inputs')

//--- LSMA - least squares
lsmaOffset = input.int(title = 'Least Squares Offset  ', defval = 9, inline = 'lsma', group = 'Additional Moving Average Inputs')

//--- MF - modular filter
beta      = input.float(title = 'Modular Filter Beta  ', defval = 0.5, maxval = 1, step = 0.05, inline = 'mf', group = 'Additional Moving Average Inputs')
feedback  = input.bool (title = 'Modular Filter Feedback', defval = true, inline = 'mf', group = 'Additional Moving Average Inputs')
weighting = input.float(title = 'Modular Filter Feedback Weighting     ', defval = 0.2, step = 0.1, minval = 0, maxval = 1, inline = 'mf', group = 'Additional Moving Average Inputs')

//--- VAMA - volatility adjusted
vamaPeriod = input.int(title = 'Volatility Adjusted Period         ', defval = 21, minval = 1, group = 'Additional Moving Average Inputs')


//------------------------------------------------------------------------------
//----- Switch operation for selecting your moving average tracking highs of the selected periods
umaHigh = switch umaType
    
    'Arnaud Legoux - ALMA'       => (mymas.alma(high, period1, almaOffset, sigma) + mymas.alma(high, period2, almaOffset, sigma)  + mymas.alma(high, period3, almaOffset, sigma) + mymas.alma(high, period4, almaOffset, sigma) + mymas.alma(high, period5, almaOffset, sigma)) / 5
    'Exponential - EMA'          => (mymas.ema(high, period1) + mymas.ema(high, period2) + mymas.ema(high, period3) + mymas.ema(high, period4) + mymas.ema(high, period5)) / 5
    'Double Exponential - DEMA'  => (mymas.dema(high, period1) + mymas.dema(high, period2) + mymas.dema(high, period3) + mymas.dema(high, period4) + mymas.dema(high, period5)) / 5
    'Triple Exponential - EMA'   => (mymas.tema(high, period1) + mymas.tema(high, period2) + mymas.tema(high, period3) + mymas.tema(high, period4) + mymas.tema(high, period5)) / 5
    'Fractal Adaptive - FRAMA'   => (mymas.frama(high, period1, fc, sc) + mymas.frama(high, period2, fc, sc) + mymas.frama(high, period3, fc, sc) + mymas.frama(high, period4, fc, sc) + mymas.frama(high, period5, fc, sc)) / 5
    'Kaufman Adaptive - KAMA'    => (mymas.kama(high, period1, fl, sl) + mymas.kama(high, period2, fl, sl) + mymas.kama(high, period3, fl, sl) + mymas.kama(high, period4, fl, sl) + mymas.kama(high, period5, fl, sl)) / 5
    'Hull - HMA'                 => (mymas.hma(high, period1) + mymas.hma(high, period2) + mymas.hma(high, period3) + mymas.hma(high, period4) + mymas.hma(high, period5)) / 5
    'Jurik - JMA'                => (mymas.jma(high, period1, phase, power) + mymas.jma(high, period2, phase, power) + mymas.jma(high, period3, phase, power) + mymas.jma(high, period4, phase, power) + mymas.jma(high, period5, phase, power)) / 5
    'Least Squares - LSMA'       => (mymas.lsma(high, period1, lsmaOffset) + mymas.lsma(high, period2, lsmaOffset) + mymas.lsma(high, period3, lsmaOffset) + mymas.lsma(high, period4, lsmaOffset) + mymas.lsma(high, period5, lsmaOffset)) / 5
    'McGinley Dynamic'           => (mymas.mcginley(high, period1) + mymas.mcginley(high, period2) + mymas.mcginley(high, period3) + mymas.mcginley(high, period4) + mymas.mcginley(high, period5)) / 5
    'Modular Filter'             => (mymas.mf(high, period1, feedback, beta, weighting) + mymas.mf(high, period2, feedback, beta, weighting) + mymas.mf(high, period3, feedback, beta, weighting) + mymas.mf(high, period4, feedback, beta, weighting) + mymas.mf(high, period5, feedback, beta, weighting)) / 5
    'Simple - SMA'               => (mymas.sma(high, period1) + mymas.sma(high, period2) + mymas.sma(high, period3) + mymas.sma(high, period4) + mymas.sma(high, period5)) / 5
    'Smoothed - SMMA'            => (mymas.smma(high, period1) + mymas.smma(high, period2) + mymas.smma(high, period3) + mymas.smma(high, period4) + mymas.smma(high, period5)) / 5
    'Tillson T3'                 => (mymas.t3(high, period1) + mymas.t3(high, period2) + mymas.t3(high, period3) + mymas.t3(high, period4) + mymas.t3(high, period5)) / 5
    'Triangular - TMA'           => (mymas.tma(high, period1) + mymas.tma(high, period2) + mymas.tma(high, period3) + mymas.tma(high, period4) + mymas.tma(high, period5)) / 5
    'Volatility-Adjusted - VAMA' => (mymas.vama(high, period1, vamaPeriod) + mymas.vama(high, period2, vamaPeriod) + mymas.vama(high, period3, vamaPeriod) + mymas.vama(high, period4, vamaPeriod) + mymas.vama(high, period5, vamaPeriod)) / 5
    'Volume-Weighted - VWMA'     => (mymas.vwma(high, period1) + mymas.vwma(high, period2) + mymas.vwma(high, period3) + mymas.vwma(high, period4) + mymas.vwma(high, period5)) / 5
    'Weighted - WMA'             => (mymas.wma(high, period1) + mymas.wma(high, period2) + mymas.wma(high, period3) + mymas.wma(high, period4) + mymas.wma(high, period5)) / 5
    'Zero-Lag - ZLMA'            => (mymas.zlma(high, period1) + mymas.zlma(high, period2) + mymas.zlma(high, period3) + mymas.zlma(high, period4) + mymas.zlma(high, period5)) / 5
    => 
        runtime.error("No matching MA type found.")
        float(na)


//----- Switch operation for selecting your moving average tracking lows of the selected periods
umaLow = switch umaType
    
    'Arnaud Legoux - ALMA'       => (mymas.alma(low, period1, almaOffset, sigma) + mymas.alma(low, period2, almaOffset, sigma)  + mymas.alma(low, period3, almaOffset, sigma) + mymas.alma(low, period4, almaOffset, sigma) + mymas.alma(low, period5, almaOffset, sigma)) / 5
    'Exponential - EMA'          => (mymas.ema(low, period1) + mymas.ema(low, period2) + mymas.ema(low, period3) + mymas.ema(low, period4) + mymas.ema(low, period5)) / 5
    'Double Exponential - DEMA'  => (mymas.dema(low, period1) + mymas.dema(low, period2) + mymas.dema(low, period3) + mymas.dema(low, period4) + mymas.dema(low, period5)) / 5
    'Triple Exponential - EMA'   => (mymas.tema(low, period1) + mymas.tema(low, period2) + mymas.tema(low, period3) + mymas.tema(low, period4) + mymas.tema(low, period5)) / 5
    'Fractal Adaptive - FRAMA'   => (mymas.frama(low, period1, fc, sc) + mymas.frama(low, period2, fc, sc) + mymas.frama(low, period3, fc, sc) + mymas.frama(low, period4, fc, sc) + mymas.frama(low, period5, fc, sc)) / 5
    'Kaufman Adaptive - KAMA'    => (mymas.kama(low, period1, fl, sl) + mymas.kama(low, period2, fl, sl) + mymas.kama(low, period3, fl, sl) + mymas.kama(low, period4, fl, sl) + mymas.kama(low, period5, fl, sl)) / 5
    'Hull - HMA'                 => (mymas.hma(low, period1) + mymas.hma(low, period2) + mymas.hma(low, period3) + mymas.hma(low, period4) + mymas.hma(low, period5)) / 5
    'Jurik - JMA'                => (mymas.jma(low, period1, phase, power) + mymas.jma(low, period2, phase, power) + mymas.jma(low, period3, phase, power) + mymas.jma(low, period4, phase, power) + mymas.jma(low, period5, phase, power)) / 5
    'Least Squares - LSMA'       => (mymas.lsma(low, period1, lsmaOffset) + mymas.lsma(low, period2, lsmaOffset) + mymas.lsma(low, period3, lsmaOffset) + mymas.lsma(low, period4, lsmaOffset) + mymas.lsma(low, period5, lsmaOffset)) / 5
    'McGinley Dynamic'           => (mymas.mcginley(low, period1) + mymas.mcginley(low, period2) + mymas.mcginley(low, period3) + mymas.mcginley(low, period4) + mymas.mcginley(low, period5)) / 5
    'Modular Filter'             => (mymas.mf(low, period1, feedback, beta, weighting) + mymas.mf(low, period2, feedback, beta, weighting) + mymas.mf(low, period3, feedback, beta, weighting) + mymas.mf(low, period4, feedback, beta, weighting) + mymas.mf(low, period5, feedback, beta, weighting)) / 5
    'Simple - SMA'               => (mymas.sma(low, period1) + mymas.sma(low, period2) + mymas.sma(low, period3) + mymas.sma(low, period4) + mymas.sma(low, period5)) / 5
    'Smoothed - SMMA'            => (mymas.smma(low, period1) + mymas.smma(low, period2) + mymas.smma(low, period3) + mymas.smma(low, period4) + mymas.smma(low, period5)) / 5
    'Tillson T3'                 => (mymas.t3(low, period1) + mymas.t3(low, period2) + mymas.t3(low, period3) + mymas.t3(low, period4) + mymas.t3(low, period5)) / 5
    'Triangular - TMA'           => (mymas.tma(low, period1) + mymas.tma(low, period2) + mymas.tma(low, period3) + mymas.tma(low, period4) + mymas.tma(low, period5)) / 5
    'Volatility-Adjusted - VAMA' => (mymas.vama(low, period1, vamaPeriod) + mymas.vama(low, period2, vamaPeriod) + mymas.vama(low, period3, vamaPeriod) + mymas.vama(low, period4, vamaPeriod) + mymas.vama(low, period5, vamaPeriod)) / 5
    'Volume-Weighted - VWMA'     => (mymas.vwma(low, period1) + mymas.vwma(low, period2) + mymas.vwma(low, period3) + mymas.vwma(low, period4) + mymas.vwma(low, period5)) / 5
    'Weighted - WMA'             => (mymas.wma(low, period1) + mymas.wma(low, period2) + mymas.wma(low, period3) + mymas.wma(low, period4) + mymas.wma(low, period5)) / 5
    'Zero-Lag - ZLMA'            => (mymas.zlma(low, period1) + mymas.zlma(low, period2) + mymas.zlma(low, period3) + mymas.zlma(low, period4) + mymas.zlma(low, period5)) / 5
    => 
        runtime.error("No matching MA type found.")
        float(na)


//----- Average of the high and low to get the center of the channel
uma = (umaHigh + umaLow) / 2


//------------------------------------------------------------------------------
//----- Momentum as rate of change of the UMA
umaMom = ta.roc(uma, momPeriod)


//------------------------------------------------------------------------------
//----- Volatility (is the UMA channel wide or narrow) 
width      = umaHigh - umaLow
minWidth   = ta.lowest (width, widthPeriod)
maxWidth   = ta.highest(width, widthPeriod)
widthState = (width - minWidth) / (maxWidth - minWidth)


//------------------------------------------------------------------------------
//----- Color variables
bull      = umaMom > 0 and close > umaHigh
lessBull  = umaMom < 0 and close > umaHigh
bear      = umaMom < 0 and close < umaLow
lessBear  = umaMom > 0 and close < umaLow
dontknow  = close > umaLow and close < umaHigh


momColor = if bull
    bullC
else if lessBull
    lessBullC
else if lessBear
    lessBearC
else if bear
    bearC
else if dontknow
    neutC


volColor = color.from_gradient(widthState, 0.0, 1.0, color.new(volC, volT), volC)

colorSrc = colorSrcInput == 'Bias + Momentum' ? momColor : volColor

barColor = barColorSrc == 'Bias + Momentum' ? momColor : barColorSrc == 'Volatility' ? volColor : na


//------------------------------------------------------------------------------
//----- Plots
plot (title = 'Momentum', series = umaMom, color = colorSrc,      style = plot.style_columns)
hline(title = '',         price = 0,       color = #000000, linestyle = hline.style_dotted)
barcolor(title = 'Bar Color', color = barColor)

//------------------------------------------------------------------------------
//----- Alerts
alertcondition(title = '+UMO Zero Cross', condition = ta.cross(umaMom, 0), message = 'The UMO has crossed the zero line.')
````
