# Fine-tune Inputs: Fourier Smoothed Volume zone oscillator WFSVZ0

- url: https://www.tradingview.com/script/POUInjNO-Fine-tune-Inputs-Fourier-Smoothed-Volume-zone-oscillator-WFSVZ0/
- type: strategy
- pine_id: PUB;ac3c1aebd83f4150b1d308b9743451e4
- version: 1.0

## Description

[b]Use this Strategy to Fine-tune inputs for the (W&)FSVZ0 Indicator.
[/b]
Strategy allows you to fine-tune the indicator for 1 TimeFrame at a time; cross Timeframe Input fine-tuning is done manually after exporting the chart data.

I suggest using "Close all" input False when fine-tuning Inputs for 1 TimeFrame. When you export data to Excel/Numbers/GSheets I suggest using "Close all" input as True, except for the lowest TimeFrame.


MEANINGFUL DESCRIPTION:

The [b]Volume Zone oscillator[/b] breaks up volume activity into positive and negative categories. It is positive when the current closing price is greater than the prior closing price and negative when it's lower than the prior closing price. The resulting curve plots through relative percentage levels that yield a series of buy and sell signals, depending on level and indicator direction.

[b]The Wavelet & Fourier Smoothed Volume Zone Oscillator (W&)FSVZO[/b] is a refined version of the Volume Zone Oscillator, enhanced by the implementation of the [b]Discrete Fourier Transform[/b]. Its primary function is to streamline price data and diminish market noise, thus offering a clearer and more precise reflection of price trends.

By combining the [b]Wavalet and Fourier aproximation[/b] with [b]Ehler's white noise[/b] histogram, users gain a comprehensive perspective on volume-related market conditions.

HOW TO USE THE INDICATOR:
The default period is 2 but can be adjusted after backtesting. (I suggest 5 VZO length and NoiceR max length 8 as-well)

The [b]VZO[/b] points to [b]a positive trend[/b] when it is rising above the 0% level, and [b]a negative trend[/b] when it is falling below the 0% level. 0% level can be adjusted in setting by adjusting VzoDifference. Oscillations rising below 0% level or falling above 0% level result in [b]a natural trend.[/b]

HOW TO USE THE STRATEGY:

Here you fine-tune the inputs until you find a combination that works well on all Timeframes you will use when creating your Automated Trade Algorithmic Strategy. I suggest 4h, 12h, 1D, 2D, 3D, 4D, 5D, 6D, W and M.

When I[b]ndicator/Strategy[/b] returns [b]0[/b] or [b]natural trend[/b], Strategy Closes All it's positions.


ORIGINALITY & USFULLNESS:

Personal combination of Fourier and Wavalet aproximation of a price which results in less noise Volume Zone Oscillator.

The [b]Wavelet Transform[/b] is a powerful mathematical tool for signal analysis, particularly effective in analyzing signals with varying frequency or non-stationary characteristics. It dissects a signal into wavelets, small waves with varying frequency and limited duration, providing a multi-resolution analysis. This approach captures both frequency and location information, making it especially useful for detecting changes or anomalies in complex signals.

The [b]Discrete Fourier Transform (DFT)[/b] is a mathematical technique that transforms discrete data from the time domain into its corresponding representation in the frequency domain. This process involves breaking down a signal into its individual frequency components, thereby exposing the amplitude and phase characteristics inherent in each frequency element.

This indicator utilizes the concept of[b] Ehler's Universal Oscillator[/b] and displays a histogram, offering critical insights into the prevailing levels of market noise. The Ehler's Universal Oscillator is grounded in a statistical model that captures the erratic and unpredictable nature of market movements. Through the application of this principle, the histogram aids traders in pinpointing times when market volatility is either rising or subsiding.


DETAILED DESCRIPTION:

My detailed description of the indicator and use cases which I find very valuable.

[b]What is oscillator?
[/b]
Oscillators are chart indicators that can assist a trader in determining overbought or oversold conditions in ranging (non-trending) markets.

[b]What is volume zone oscillator?
[/b]
Price Zone Oscillator measures if the most recent closing price is above or below the preceding closing price.

Volume Zone Oscillator is Volume multiplied by the 1 or -1 depending on the difference of the preceding 2 close prices and smoothed with Exponential moving Average.

[image]https://www.tradingview.com/x/OBAgEt9k[/image]
[image]https://www.tradingview.com/x/WTsuK2fE/[/image]


[b]What does this mean?
[/b]
If the VZO is above 0 and VZO is rising. We have a bullish trend. Most likely.
If the VZO is below 0 and VZO is falling. We have a bearish trend. Most likely.

Rising means that VZO on close is higher than the previous day.
Falling means that VZO on close is lower than the previous day.

[b]What if VZO is falling above 0 line?
[/b]
It means we have a high probability of a bearish trend.

Thus the indicator returns 0 and [b]Strategy[/b] closes all it's positions when falling above 0 (or rising bellow 0) and we combine higher and lower timeframes to gauge the trend.

In the next Image you can see that trend is negative on 4h, negative on 12h and positive on 1D. That means trend is negative.

I am sorry, the chart is a bit messy. The idea is to use the indicator over more than 1 Timeframe.

[image]https://www.tradingview.com/x/dauTfcQc/[/image]

[b]What is approximation and smoothing?
[/b]
They are mathematical concepts for making a discrete set of numbers a
continuous curved line.

Fourier and Wavelet approximation of a close price are taken from aprox library.

[url=https://www.tradingview.com/script/F4THFatm-aprox/]https://www.tradingview.com/script/F4THFatm-aprox/[/url]

Key Features:

You can tailor the [b]Indicator/Strategy[/b] to your preferences with adjustable parameters such as VZO length, noise reduction settings, and smoothing length.

[b]Volume Zone Oscillator (VZO) [/b]shows market sentiment with the VZO, enhanced with Exponential Moving Average (EMA) smoothing for clearer trend identification.

[b]Noise Reduction[/b] leverages Euler's White noise capabilities for effective noise reduction in the VZO, providing a cleaner and more accurate representation of market dynamics.

Choose between the traditional [b]Fast Fourier Transform (FFT)[/b], the innovative Double [b]Discrete Fourier Transform (DTF32) [/b]and Wavelet soothed Fourier soothed price series to suit your analytical needs.

[b]Image of Wavelet transform[/b] with FAST settings, Double Fourier transform with FAST settings. Improved noice reduction with SLOW settings, and standard FSVZO with SLOW settings:

[image]https://www.tradingview.com/x/KPcFgaZ2[/image]

Fast setting are setting by default:
VZO length = 2
NoiceR max Length = 2

Slow settings are:
VZO length = 5 or 7
NoiceR max Length = 8

As you can see fast setting are more volatile. I suggest averaging fast setting on 4h 12h 1d 2d 3d 4d W and M Timeframe to get a clear view on market trend.

[b]What if I want long only when VZO is rising and above 15 not 0?
[/b]
You have set Setting VzoDifference to 15. That reduces the number of trend changes.

[b]Example of W&FSVZO with VzoDifference 15 than 0:
[/b]
VZO crossed 0 line but not 15 line and that's why Indicator returns 0 in one case an 1 in another.

[image]https://www.tradingview.com/x/eVqkqNm4/[/image]

[b]What is Smooth length setting?
[/b]
A way of calculating Bullish or Bearish  (W&)FSVZO .

If smooth length is 2 the trend is rising if:

[pine] rising = VZO > ta.ema(VZO, 2) [/pine]

Meaning that we check if VZO is higher that exponential average of the last 2 elements.

If smooth length is 1 the trend is rising if:
[pine] rising = VZO_ > VZO_[1] [/pine]

Use this Strategy to [b]fine-tune[/b] inputs for the (W&)FSVZO Indicator.
[url=https://www.tradingview.com/script/YNwMIZgi-Wavelet-Fourier-Smoothed-Volume-zone-oscillator-W-FSVZO/]https://www.tradingview.com/script/YNwMIZgi-Wavelet-Fourier-Smoothed-Volume-zone-oscillator-W-FSVZO/[/url]
(Strategy allows you to fine-tune the indicator for 1 TimeFrame at a time; cross Timeframe Input fine-tuning is done manually after exporting the chart data)

I suggest using "[b]Close all[/b]" input [b]False[/b] when fine-tuning Inputs for [b]1 TimeFrame[/b]. When you export data to Excel/Numbers/GSheets I suggest using "[b]Close all[/b]" input as [b]True[/b], [b]except[/b] for the[b] lowest TimeFrame[/b]. I suggest using 100% equity as your default quantity for fine-tune purposes. I have to mention that 100% equity may lead to unrealistic backtesting results. Be avare. When backtesting for trading purposes use Contracts or USDT.

## Source Code

````pine
//@version=5
strategy("Fine-tune W&FSVZO Strategy [Algo Alert]", precision = 2, default_qty_type ="percent_of_equity" , default_qty_value = 100 )

// Importing required libraries
import TradingView/ta/5
import Celje_2300/aprox/1

// Input options for enabling new versions of DFT and whitenoise
version2 = input.bool(title = 'Double Fourier', tooltip="Improved Fourier Transform" ,defval = true, group = "VZO")
version3 = input.bool(title = 'Improved whitenoise', tooltip="Improved Noice Reduction using aproximated price aswell ad close price.", defval = true, group = "VZO")

magic = input.bool(title = 'Magical Wavelet Aproximation',tooltip="Uses Wavelet as Main aprox. instead of Fourier", defval = false, group = "Edition")


// FAST FOURIER TRANSFORM
// Selecting either DTF32 or FFT based on user preference
dft = magic ? version2 ? aprox.Wavelet(src = aprox.smooth(aprox.DTF32(),aprox.Wavelet(src = aprox.DTF32(),len = 6))) : aprox.Wavelet(src = aprox.smooth(aprox.FFT(),aprox.Wavelet(src = aprox.FFT(),len = 6))) : version2 ? aprox.DTF32() : aprox.FFT()

// VZO (Volume Zone Oscillator) calculation with EMA smoothing
lengthV = input(2, title='VZO Length', tooltip="I suggest 2 for FAST and 5 or 7 for SLOW. Using FAST setting require averaging more than 1 Timeframe together. ", group = "VZO")
VZO_1 = aprox.vzo_ema(dft, lengthV)

// NOISE REDUCTION
min_ = input(1, "NoiseR min length", tooltip="Keep it at 1 if you didn't read the code!! it's the range of EMA aproximation of the VZO depending on last 3 close prices." , group = "Noise")
max_ = input(8, "NoiseR max length",tooltip="I suggest 2 for FAST and 7 or 8 for SLOW. Using FAST setting require averaging more than 1 Timeframe together.", group = "Noise")
malen = input(2, title="Smooth Length", tooltip="Insert 1 if you use VZO > VZO[1] and 2 if you use VZO > ta.ema(VZO,2)", group = "Noise")

// Using whitenoise function for noise reduction in VZO
VZO_ = version3 ? aprox.whitenoise(VZO_1, dft, 10, minEmaLength = min_, maxEmaLength = max_) : 
               aprox.whitenoise(VZO_1, 10, minEmaLength = min_, maxEmaLength = max_)

// PLOTS
nice_chart = input.bool(true, "Nice chart", tooltip="IF (FALSE): Shows the red falling line if VZO falling above 0", group = "Plots")

// Conditions for plotting based on oscillator direction
var greencon = false
var redcon = false

taema = ta.ema(VZO_, malen)

greencon := malen < 2 ? VZO_ > VZO_[1] : (VZO_ > taema)
redcon := malen < 2 ? VZO_ < VZO_[1] : (VZO_ < taema)

leadosc = (VZO_)*0.8

mar = input.int(0,"Vzvo difference",tooltip="bulish_VZO = true  WHEN  { Vzo = bulish AND VZO > this_input } ")

plot(mar , display = display.pane)
plot(-mar,  display = display.pane)
close_all = input.bool(true,"Enable Close all", tooltip=" Position is always 1 or -1 if false, and 1, 0 or -1 if true. 0 Is falling above 0 or rising bellow 0")


longCondition = greencon and VZO_ >mar
shortCondition =  redcon and VZO_ < -mar
// Strategy execution
var pos = 0
var long = 0

if longCondition 
    pos := 1
    long := 1
    strategy.entry("long",strategy.long)

if shortCondition 
    pos := -1
    long := -1
    strategy.entry("short",strategy.short)


if not longCondition and not shortCondition and close_all
    pos := 0
    strategy.close_all()


// Plotting the indicators and colored zones
mid = plot(0, color=color.new(#ffffff, 71), display = display.pane)
lii = plot(leadosc, color = greencon ? color.rgb(0, 255, 187, math.abs(leadosc)) : color.rgb(255, 17, 0, math.abs(leadosc)), display = display.none)
v3 = plot(VZO_ >= 0 ? math.min(VZO_, taema)*1.1 : math.max(VZO_, taema)*1.1, display = display.none)
v4 = plot(VZO_ >= 0 ? math.min(VZO_, taema)*1: math.max(VZO_, taema)*1, display = display.none)

fill(v3, lii, taema > 0 ? taema : 0, taema > 0 ? 0 : taema, taema > 0 ? color.rgb(9, 232, 173, math.abs(leadosc)) : #0d030300, taema > 0 ? #0b030300 : color.rgb(208, 20, 7, math.abs(leadosc)), display = nice_chart ? display.all : display.none)
fill(v4, lii, taema > 0 ? taema : 0, taema > 0 ? 0 : taema, taema > 0 ? color.rgb(9, 232, 173, math.abs(leadosc)) : #0d030300, taema > 0 ? #0b030300 : color.rgb(208, 20, 7, math.abs(leadosc)), display = not nice_chart ? display.all : display.none)
plot(VZO_, color = greencon ? color.rgb(9, 232, 173, math.abs(leadosc)) : redcon ? color.rgb(255, 17, 0, math.abs(leadosc)) : color.aqua, display = not nice_chart ? display.pane : display.none)

// Plotting additional information on the status line
plot(close, title="ClosePrice", display=display.status_line)
plot(open, title="OpenPrice", display=display.status_line)

plot(pos, color = greencon ? color.rgb(9, 232, 173, 50) : redcon ? color.rgb(255, 17, 0, 50) : color.aqua, title="position", display=display.status_line)

plotchar(longCondition and long[1]==-1 ? -125 : na, char = "▲", color = color.rgb(0, 255, 187,40), location = location.absolute, size = size.tiny,  display = display.pane)
plotchar(shortCondition  and long[1]==1 ? 125 : na, char = "▼", color = color.rgb(255, 17, 0, 40), location = location.absolute, size = size.tiny,  display = display.pane)
````
