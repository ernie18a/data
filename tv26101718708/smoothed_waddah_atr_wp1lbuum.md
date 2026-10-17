# Smoothed Waddah ATR

- url: https://www.tradingview.com/script/wP1LbuUm-Smoothed-Waddah-ATR/
- type: strategy
- pine_id: PUB;3f157e58021b4322b36eb61cfcfa30a0
- version: 1.0

## Description

~~~All Credit to LAZY BEAR for posting the original Script which is an old MT4 indicator.~~~~

[i]No this system does not repaint... if it does let me know. Either the code is wrong or you are using a repainting chart such as renko candles. [/i]

[b]*PURPOSE*[/b]
This Is an "Enhanced or Smoothed" version of the script that captures the heiken-ashi closing price as its main calculation variable. While using normal bar or line charts. Enhancements integrate trade filters to reduce false signals. 

[b]*WHAT TYPE OF TRADING STRATEGY IS THIS?*[/b]
This is a Long Only, Trend Trading System. Is intended to be applied to Charts/Timeframes that produce sustainable trends for which ever asset you are trading. 

[b]*NOTE OF ADVICE REGARDING SETTINGS* [/b]
Settings can be tweaked but I have found that best results come with the given settings. If a chart is too choppy to trade this indicator successfully, it is advised not to change the settings but either find a different timeframe or different asset to apply this strategy to. 

[b]TLDR [/b]
Indicator measures the change of the MacD (difference between MAC D of given EMA's) and compares it to the difference between the Upper and Lower Bollinger bands. Green bar over trigger line= entry. Red bar over trigger line = close. 


[b]*SETTINGS AND INPUTS*[/b]
-MacD of HeikenAshi chart (will always be of the Heikenashi chart even when applied to different chart type)
sensitivity = input(150, title='Sensitivity')  =range should be (125-175)multiplier so that MacD can be compared to BB 
fastLength = input(20, title='MacD FastEMA Length')
slowLength = input(40, title='MacD SlowEMA Length')

-Bollinger Band of currently used price chart type
channelLength = input(20, title='BB Channel Length')
mult = input(1.5, title='BB Stdev Multiplier')

-14 Period RSI Trade Filter (set to 0 to Disable)
RSI14filter = input(40, title='RSI Value trade filter') =only gives entry when RSI is higher than given value


[b]*ABSTRACT & CONCEPT*[/b]
TLDR - Indicator measures the change of the MacD (difference between MAC D of given EMA's) and compares it to the difference between the Upper and Lower Bollinger bands. Green bar over trigger line= entry. Red bar over trigger line = close. 

Indicator plots - 
Bars are the change in the MAC D and the indicator line is the difference in the BB. 
When Bars are higher than the indicator line then it is considered a trend "Explosion"
Green Bars are Trend Explosion to the upside, Red Bars are Trend explosion to the downside. 
 
GENERAL DETAIL- 
the core calculation is measuring the change in MacD of current candle compared to the MacD of two previous candles. 
[(MacD current)- (MacD two candle previous).] 
This value is multiplied by the sensitivy so it can be compared to the change in Bollinger Band Width.
[(BBupper-BBlower)current - (BBupper-BBlower)one candle previous]

if the MACD change is positive then you get a green/lime bar for that value. If the MacDchange is negative you get a red/orange bar for that value. 

[green vs lime] and [red vs orange] are determined by whether the actual change is increasing in that direction or decreasing. (bars getting taller or bars getting shorter)

Entry signal for long is A positive change in MACD difference (Green bar) that is greater than the change of the bollinger band (orange signal line) AND if the RSI value is above your filter. 

Close signal or Trend Stop Warning Signal is  given when a Negative MacD Difference (red bar) is greater than the change of the bollinger band (orange Line)

*CONSIDERATIONS AND THOUGHTS*
I have over 150 iterations of this indicator and this is the most consistent and best version of settings and filters I was able to generate. I built this indicator specifically for 3 charts. SPY monthly, QQQ monthly, BTC 3 Day. However this indicator works well on any long term bullish chart. (tech stocks are great) . 

 Trend trading systems are intended to be homerun hitting, plunge protecting  indicators that allow for long legs and expanding volatility. This indicator does this as the trigger line is Dynamic with the expansion and contraction of the bollinger band. 

 I do not take every signal specifically not the close signals. Instead they more like warnings in ultra bullish environments. 

If i had to pair this indicator with any other filter than the RSI, it would be a long term moving average i.e. the 50 week or equivalent for your chart. signals above rising moving averages means that you are trading with an upward trending market. 

Hope this helps. Happy trades.

-SnarkyPuppy

## Source Code

````pine
//@version=5

///////////Original Script Courtesy of Lazy_Bear.... Absolute Legend\\\\\\\\\\\\\\\

strategy('SmoothedWaddah', overlay=false, initial_capital=1)
sensitivity = input(150, title='Sensitivity')
fastLength = input(20, title='MacD FastEMA Length')
slowLength = input(40, title='MacD SlowEMA Length')
channelLength = input(20, title='BB Channel Length')
mult = input(1.5, title='BB Stdev Multiplier')
RSI14filter = input(40, title='RSI Value trade filter')

////////////MacD Calculation of price//////////////////////////////
calc_macd(source, fastLength, slowLength) =>
    fastMA = ta.ema(source, fastLength)
    slowMA = ta.ema(source, slowLength)
    fastMA - slowMA

/////////BolingerBand Calculation of Price///////////////////////
calc_BBUpper(source, length, mult) =>
    basis = ta.sma(source, length)
    dev = mult * ta.stdev(source, length)
    basis + dev

calc_BBLower(source, length, mult) =>
    basis = ta.sma(source, length)
    dev = mult * ta.stdev(source, length)
    basis - dev

//////heinkenashi chart call for closing price "smoothing mechanism"\\\\\\\\\\\\\\\\\\\\\\\\\\\
point = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close)

////////////////////T1 is change in MacD current  candle from previous candle Sensitivy amplifies calculation/////////////////////
t1 = (calc_macd(point, fastLength, slowLength) - calc_macd(point[1], fastLength, slowLength)) * sensitivity
//////////////////////T2 is  T1 from two candles prior\\\\\\\\\\\\\\\\\\\\\\\\\\\
t2 = (calc_macd(point[2], fastLength, slowLength) - calc_macd(point[3], fastLength, slowLength)) * sensitivity

////////////////E1 is difference in bolinger band upper and lower...E2 is E1 from one candle prior not needed//////////////
e1 = calc_BBUpper(ohlc4, channelLength, mult) - calc_BBLower(ohlc4, channelLength, mult)
//e2 = (calc_BBUpper(close[1], channelLength, mult) - calc_BBLower(close[1], channelLength, mult))

//////signal bar printing.. Up if MacD positive .. Down if MacD negative//////////
trendUp = t1 >= 0 ? t1 : 0
trendDown = t1 < 0 ? -1 * t1 : 0

///////plots difference in macD*Sensitivity, color change if increasing or decreasing. 
//////color is green/lime if explosion is up \ color is red/orange if explosion is down/////////
plot(trendUp, style=plot.style_columns, linewidth=1, color=trendUp < trendUp[1] ? color.new(color.lime,45) : color.new(color.green,45), title='UpTrend')
plot(trendDown, style=plot.style_columns, linewidth=1, color=trendDown < trendDown[1] ? color.new(color.orange,45) : color.new(color.red,45), title='DownTrend')
plot(e1, style=plot.style_line, linewidth=2, color=color.new(#A0522D, 0), title='ExplosionLine')


////////////Entry conditions and Concept/////////////////////
////////////Long Only System. T1 is measuring the distance between MACD EMA's. This is Multiplied
////////////by the sensitivity so that it can be compared to the difference between BollingerBand. 
/////////////{this could have been a ratio maybe i will work with that in a different script.} 
/////////////I found that 135-175 sensitivy allows for values to be compared on most charts.....
////////////If the (difference between the EMA)*(Sensitivity) is greater than (BB upper line- BB lower line)
////////////it is considered an explosion in either the downside or the upside.The indicator will print
///////////a bar higher than the trigger line either green or red (up or down respectively)//////////////////

longCondition = trendUp > e1 and ta.rsi(close, 14) > RSI14filter
if longCondition
    strategy.entry('up', strategy.long)

strategy.close('up', trendDown > e1)
````
