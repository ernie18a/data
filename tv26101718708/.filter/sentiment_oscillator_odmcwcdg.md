# Sentiment Oscillator

- url: https://www.tradingview.com/script/ODMCwcDG-Sentiment-Oscillator/
- type: strategy
- pine_id: PUB;rF0XVocHM8kyh9VSExpesYdVV9uXNLR5
- version: 3.0

## Description

Price moves when there are more market takers than there are market makers at a certain price (i.e. price moves up when there are more market buys than limit sells and vice versa). The idea of this indicator is to show the ratio between market takers and market makers in a way that is intuitive to technical analysis methods, and hopefully revealing the overall sentiment of the market in doing so. You can use it in the same way you would other oscillators (histogram crossing zero, divergences, etc). The main difference between this and most volume-weighted indicators is that the price is divided by volume instead of multiplied by it, thus giving you a rough idea of how much "effort" it took to move the price.  My hypothesis is that when more volume is needed to move the price, that means bulls and bears are not in agreement of what the "fair price" should be for an asset (e.g. if the candle closes only a bit higher than its open but there's a huge spike in volume, that tells you that a majority of the market are starting to think the price is too high and they've started selling).

[b]Methods of Calculation[/b]
1. Price Change Per Volume
The main method this indicator uses to reveal market sentiment is by comparing price change to the volume of trades in a bar.
You will see this calculation plotted in its most basic form by ticking the "Show Bar per Bar Change/Volume" box in the inputs dialog. I personally found that the plots were too noisy and cannot be used in real time reliably due to the fact that there is not much volume at the open of a new bar. I decided to leave in the option to use this method, in case you'd like to experiment with it or get a better grasp of how the indicator works.

2. Exponential Moving Averages
In my quest to smooth out the plotted data, I experimented with exponential moving averages. Applying an EMA on the change per volume data did smooth it out a bit, but still left in a lot of noise. So I worked around it by applying the EMA to the price change first, and then dividing it by the EMA of the volume. The term I use for the result of this calculation is "Market Sentiment" (do let me know if you have a better-fitting term for it ;-)), and I have kept it as an option that you can use in the way you would use other oscillators like CMF, OBV, etc. This option is unticked by default.

3. MACD
I left "Market Sentiment" unchecked as the default option because I thought an easier way to use this indicator would be as a momentum indicator like the MACD . So that's what I turned it into! I applied another EMA on the Market Sentiment, added a slower EMA to subtract from the first, and now we have a MACD line. I added a signal line to subtract from the MACD , and the result is plotted as a histogram... ish . I used area instead of columns for plot style so you don't get confused when comparing with a regular MACD indicator, but you can always change it if an actual histogram is more your taste.
The "histogram" is the main gauge of sentiment change momentum and it is easiest to use, that is why it is the only calculation plotted by default.

[b]Methods of Use[/b]
As I have mentioned before, you can use this as you would other oscillators.
-The easiest way to use this indicator is with the Momentum histogram, where crosses over 0 indicate increasing bullish sentiment, and crosses below 0 indicate increasing bearish sentiment. You may also spot occasional divergences with the histogram.
-For the Market Sentiment option, the easiest way to use it is to look for divergences.
-And if you use the "Price Change per Volume of Each Bar", well... I honestly don't know. I guess divergences would be apparent towards the close of a bar, but in realtime, I don't recommend you use this. Maybe if you'd like to study the market movement, looking at historical data and comparing price, volume , and Change per Volume of each bar would come in handy in a pseudo-tape-reading kind of way.

Anyway, that's my explanation of this indicator. The default values were tested on BTC/USDT (Binance) 4h with decent results. You'll have to adjust the parameters for different markets and timeframes.
I have published this as a strategy so you can test out how the indicator performs as you're tweaking the parameters.

I'm aware that the code might not be the cleanest as I have only started learning pine (and code in general) for about a month, so any suggestions to improve the script would be appreciated!
Good luck and happy trading :-)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dannylimardi

//@version=4
strategy("Sentiment Oscillator with Backtest", "Sentiment Oscillator", overlay=false, initial_capital=100, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.08)


//Inputs
msLen = input(49, type=input.integer, title="Market Sentiment Lookback Length", group="Parameters")
emaLen1 = input(40, type=input.integer, title="Fast EMA Length", group="Parameters")
emaLen2 = input(204, type=input.integer, title="Slow EMA Length", group="Parameters")
signalLen = input(20, type=input.integer, title="Signal Length", group="Parameters")
showMs = input(false, type=input.bool, title="Show Market Sentiment Line?", group="Plots")
showHist = input(true, type=input.bool, title="Show Momentum Histogram?", group="Plots")
showMacd = input(true, type=input.bool, title="Show MACD Line?", group="Plots")
showSignal = input(true, type=input.bool, title="Show Signal Line?", group="Plots")
showDots = input(true, type=input.bool, title="Plot Dots when MACD and Signal Line cross?", group="Plots")
showCpv = input(false, type=input.bool, title="[Show Change/Volume of Each Bar?]", group="Plots")
showEma1 = input(false, type=input.bool, title="[Show Fast EMA?]", group="Plots")
showEma2 = input(false, type=input.bool, title="[Show Slow EMA?]", group="Plots")
longStrategy = input(true, type=input.bool, title="Backtest Long Strategy?", group="Long Strategy")
entryVar1 = input(title="Long Entry Variable 1",defval="Histogram", options=["Market Sentiment", "Fast EMA", "Slow EMA", "MACD", "Signal Line", "Histogram"], group="Long Strategy")
entryCond = input(title="Long Entry Condition", defval="Crossing Over", options=["Crossing Over", "Crossing Under"], group="Long Strategy")
entryVar2 = input(title="Long Entry Variable 2", defval="Zero Line", options=["Market Sentiment", "Fast EMA", "Slow EMA", "MACD", "Signal Line", "Histogram", "Zero Line"], group="Long Strategy")
exitVar1 = input(title="Long Exit Variable 1",defval="MACD", options=["Market Sentiment", "Fast EMA", "Slow EMA", "MACD", "Signal Line", "Histogram"], group="Long Strategy")
exitCond = input(title="Long Exit Condition", defval="Crossing Under", options=["Crossing Over", "Crossing Under"], group="Long Strategy")
exitVar2 = input(title="Long Exit Variable 2", defval="Zero Line", options=["Market Sentiment", "Fast EMA", "Slow EMA", "MACD", "Signal Line", "Histogram", "Zero Line"], group="Long Strategy")
useCPV = input(false, type=input.bool, title="Use Alternate Calculation Method?", group="Other Settings", tooltip="If checked, the Market Sentiment will be the EMA of Change Per Volume of each bar, instead of the default calculation method (Price Change EMA divided by Volume EMA). The alternate method may be slightly more responsive, but will result in bigger fluctuations when there is a huge change in volume. If this method is checked, I recommend changing the Long Exit Strategy to 'Signal Line Crossing Under Zero'.")
mcTheme = input(false, type=input.bool, title="Use Alternate Color Scheme?", group="Other Settings", tooltip="If checked, the MACD, Signal, and Histogram will all be plotted as areas and histograms")

//Calculations
priceChange = close - close[1]
changePerVolume = (priceChange/volume) * 10000000  // (The 1000000 doesn't have any significance, it's just to avoid color-change errors when the values are too small.)
priceChangeEma = ema(priceChange, msLen)
volumeEma = ema(volume, msLen)
marketSentiment = useCPV ? ema(changePerVolume, msLen) : priceChangeEma/volumeEma * 1000000000
msEma1 = ema(marketSentiment, emaLen1)
msEma2 = ema(marketSentiment, emaLen2)
macd = msEma1-msEma2
signal = ema(macd, signalLen)
hist = macd-signal

//Strategy Function and String Definitions

var entryVar1_ = 0.0
var entryVar2_ = 0.0
var exitVar1_ = 0.0
var exitVar2_ = 0.0

if entryVar1 == "Market Sentiment" 
    entryVar1_ := marketSentiment
else if entryVar1 == "Fast EMA"
    entryVar1_ := msEma1
else if entryVar1 =="Slow EMA"
    entryVar1_ := msEma2
else if entryVar1 == "MACD"
    entryVar1_ := macd
else if entryVar1 == "Signal Line" 
    entryVar1_ := signal
else if entryVar1 == "Histogram" 
    entryVar1_ := hist
    
if entryVar2 == "Market Sentiment" 
    entryVar2_ := marketSentiment
else if entryVar2 == "Fast EMA"
    entryVar2_ := msEma1
else if entryVar2 =="Slow EMA"
    entryVar2_ := msEma2
else if entryVar2 == "MACD"
    entryVar2_ := macd
else if entryVar2 == "Signal Line" 
    entryVar2_ := signal
else if entryVar2 == "Histogram" 
    entryVar2_ := hist
else if entryVar2 == "Zero Line"
    entryVar2_ := 0
    
if exitVar1 == "Market Sentiment" 
    exitVar1_ := marketSentiment
else if exitVar1 == "Fast EMA"
    exitVar1_ := msEma1
else if exitVar1 =="Slow EMA"
    exitVar1_ := msEma2
else if exitVar1 == "MACD"
    exitVar1_ := macd
else if exitVar1 == "Signal Line" 
    exitVar1_ := signal
else if exitVar1 == "Histogram" 
    exitVar1_ := hist
    
if exitVar2 == "Market Sentiment" 
    exitVar2_ := marketSentiment
else if exitVar2 == "Fast EMA"
    exitVar2_ := msEma1
else if exitVar2 =="Slow EMA"
    exitVar2_ := msEma2
else if exitVar2 == "MACD"
    exitVar2_ := macd
else if exitVar2 == "Signal Line" 
    exitVar2_ := signal
else if exitVar2 == "Histogram" 
    exitVar2_ := hist
else if exitVar2 == "Zero Line"
    exitVar2_ := 0
    
entryCond_(entryVar1_, entryVar2_) =>
    if entryCond == "Crossing Over"
        crossover(entryVar1_, entryVar2_)
    else if entryCond == "Crossing Under"
        crossunder(entryVar1_, entryVar2_)

exitCond_(exitVar1_, exitVar2_) =>
    if exitCond == "Crossing Over"
        crossover(exitVar1_, exitVar2_)
    if exitCond == "Crossing Under"
        crossunder(exitVar1_, exitVar2_)

longEntry = entryCond_(entryVar1_, entryVar2_)
longExit = exitCond_(exitVar1_, exitVar2_)

up = crossover(macd, signal)
down = crossunder(macd, signal)

greenDot = up ? valuewhen(up, signal, 0) : na
redDot = down ? valuewhen(down, signal, 0) : na

//Plot colors
col_grow_above = #26A69A
col_grow_below = #FFCDD2
col_fall_above = #B2DFDB
col_fall_below = #EF5350
col_macd = #0094ff
col_signal = #ff6a00

//Drawings
plot(showMacd ? macd : na, title="MACD", color=mcTheme ? #6f62e3 : col_macd, transp=mcTheme ? 15 : 0,
 style=mcTheme ? plot.style_histogram : plot.style_line)
plot(showSignal ? signal : na, title="Signal", color=mcTheme ? (signal > 0 ? color.blue : color.orange) : col_signal, transp=mcTheme ? 85 : 0,
 style=mcTheme ? plot.style_area : plot.style_line)
plot(showHist ? hist : na, title="Histogram", style=mcTheme ? plot.style_columns : plot.style_area, 
 color=mcTheme ? (hist > 0 ? color.teal : color.red) : (hist>=0 ? (hist[1] < hist ? col_grow_above : col_fall_above) : (hist[1] < hist ? col_grow_below : col_fall_below)), 
 transp=mcTheme ? 15 : 20)
plot(showDots ? greenDot : na, color=color.lime, style=plot.style_circles, linewidth=5, transp=40)
plot(showDots ? redDot : na, color=color.red, style=plot.style_circles, linewidth=5, transp=40)
plot(0, color=color.white, transp=80)
plot(showEma1 ? msEma1 : na, color=color.aqua)
plot(showEma2 ? msEma2 : na, color=color.yellow)
plot(showMs ? marketSentiment : na, color=color.lime)
plot(showCpv ? changePerVolume : na, color=changePerVolume > changePerVolume[1] ? color.teal : color.red)

// if longEntry and valuewhen(longEntry, bar_index, 1) < valuewhen(longExit, bar_index, 0)
//     label.new(bar_index, signal, "BUY", yloc=yloc.price, style=label.style_none, color=color.green, textcolor=color.blue)

// if longExit and valuewhen(longExit, bar_index, 1) < valuewhen(longEntry, bar_index, 0)
//     label.new(bar_index, signal, "SELL", yloc=yloc.price, style=label.style_none, color=color.red, textcolor=color.red)

//Strategy
if longStrategy
    strategy.entry("Buy", strategy.long, when=longEntry)
    strategy.close("Buy", when=longExit)
````
