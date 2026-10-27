# Vix FIX / Stochastic Weights Strategy

- url: https://www.tradingview.com/script/QfgPbWOr-Vix-FIX-Stochastic-Weights-Strategy/
- type: indicator
- pine_id: PUB;b244ce29db774338a9fd5e47ed964df8
- version: 2.0

## Description

This script is based off of Chris Moody's Vix Fix Indicator modified by OskarGallard and BigBitsIO's Stochastic Weights.

This script is a compilation of several different stochastic indicators (and RSI ) where the K value of each indicator is equally weighted. The purpose of the indicator is to combine many indicators together in a fashion that weights them easier. By default, the Stochastic and Stochastic RSI are both enabled - the idea is to speed up the relatively slower Stochastic and to slow down the relatively fast Stochastic RSI . BigBitsIO's Stochastics are also available that can also be added to the weighted calculation. Only the K value is weighted, as the D value is just a moving average of the weighted K.

- Why is this modifed stochastic useful?
- To weight multiple indicators together so that you can attempt to find optimal values shared amongst the indicators. Ex: If Stochastic RSI is 100 and Stochastic is 50, K would be 75 and not particularly high. If you add in a 50 RSI , the K would be 67 in this example. If we weight indicators together that all have a high value they could potentially help find elements that align together to produce a stronger signal.

In this script we have the red "S" triangles which are Exits (overbought stochastic crosses).

Added alerts for stochastic exit signals. Alerts are Pre-Set to only Alert on Bar Close.

The "Williams Vix Fix" is one of the most reliable indicators in history for finding market bottoms. The Vix Fix is simply a code from Larry Williams creating almost identical results for creating the same ability the Vix has to all assets.

The VIX has always been much better at signaling bottoms than tops. Simple reason is when market falls retail traders panic and increase volatility , and professionals come in and capitalize on the situation. At market tops there is no one panicking... just liquidity drying up.

The FE green triangles are "Filtered Entries".
The AE green triangles are "Aggressive Filtered Entries".

Added Alerts to Williams Vix Fix (Aggressive Entry and Filtered Entry). Alerts are Pre-Set to only Alert on Bar Close.

Added "Ehlrers StochCCI" indicator of user @glaz

The Ehlrers StochCCI is a variation of Ehlers Stochastic RSI replaced with CCI.

The John Ehlers' article in August, 2006, "Modeling The Market = Building Trading Strategies," describes a process for extracting trend and cyclic elements from market data, then recombining them for trading purposes. He used the Stochastic RSI denoted the cyclic elements.

Added ability to show Dots when StochCCI Crosses.
Sell: fuchsia dots.
Buy: green dots. 

Added alerts for (Buy / Sell) StochCCI. Alerts are Pre-Set to only Alert on Bar Close. 

DISCLAIMER: For educational and entertainment purposes only. Nothing in this content should be interpreted as financial advice or a recommendation to buy or sell any sort of security or investment including all types of crypto. DYOR, TYOB.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © OsMar21

//@version=6
indicator('Vix FIX / Stochastic Weights Strategy', 'VixFIX / StochWeights Strategy', overlay = false)
show_StochW = input.bool(true, 'Show Stochastic Weights')
show_exit = input.bool(true, 'Show Signal: OverBought [Stochastic Crossover]')
alert_Stoch = input.bool(false, '◁ Alert: OverBought [Stochastic Crossover]')

enableStoch = input.bool(true, 'Enable Stochastic')
smoothStochK = input.int(3, 'Stochastic K MA Length', minval = 1)
lengthStoch = input.int(14, 'Stochastic Lookback Length', minval = 1)

enableRSI = input.bool(false, 'Enable RSI')
rsiLength = input.int(14, 'RSI Lookback Length', minval = 1)

enableStochRSI = input.bool(true, 'Enable Stochastic RSI')
smoothStochRSIK = input.int(3, 'Stochastic RSI K MA Length', minval = 1)
lengthStochRSI = input.int(14, 'Stochastic RSI - Stochastic Lookback Length', minval = 1)
rsiLengthInStochRSI = input.int(14, 'Stochastic RSI - RSI Lookback Length', minval = 1)

enableStochVOL = input.bool(false, 'Enable Stochastic VOL [BigBitsIO]')
smoothStochVOLK = input.int(3, 'Stochastic VOL K MA Length', minval = 1)
lengthStochVOL = input.int(14, 'Stochastic VOL Lookback Length', minval = 1)
superStochVOLFastSmoothLength = input.int(6, 'Stochastic VOL Super Fast Smoothing Length', minval = 1)

enableStochPC = input.bool(false, 'Enable Stochastic PC [BigBitsIO]')
smoothStochPCK = input.int(3, 'Stochastic PC K MA Length', minval = 1)
lengthStochPC = input.int(8, 'Stochastic PC Lookback Length', minval = 1)
superStochPCFastSmoothLength = input.int(4, 'Stochastic PC Super Fast Smoothing Length', minval = 1)

smoothD = input.int(3, 'Stochastic D Length (only applies to weighted K)', minval = 1)

sbcFilt = input.bool(true, 'Show Signal For Filtered Entry [▲ FE ]', group = 'Williams Vix Fix') // Use FILTERED Criteria
sbcAggr = input.bool(true, 'Show Signal For AGGRESSIVE Filtered Entry [▲ AE ]', group = 'Williams Vix Fix') // Use FILTERED Criteria
alert_AE = input.bool(false, '◁ Alert: [AGGRESSIVE Entry]', inline = 'AlertVF', group = 'Williams Vix Fix')
alert_FE = input.bool(false, '◁ Alert: [Filtered Entry]', inline = 'AlertVF', group = 'Williams Vix Fix')
pd = input.int(22, 'LookBack Period Standard Deviation High', group = 'Williams Vix Fix')
bbl = input.int(20, 'Bolinger Band Length', group = 'Williams Vix Fix')
mult = input.float(2.0, 'Bollinger Band Standard Devaition Up', minval = 1, maxval = 5, group = 'Williams Vix Fix')
lb = input.int(50, 'Look Back Period Percentile High', group = 'Williams Vix Fix')
ph = input.float(.85, 'Highest Percentile - 0.90=90%, 0.95=95%, 0.99=99%', group = 'Williams Vix Fix')
ltLB = input.int(40, minval = 25, maxval = 99, title = 'Long-Term Look Back Current Bar Has To Close Below This Value OR Medium Term--Default=40', group = 'Williams Vix Fix')
mtLB = input.int(14, minval = 10, maxval = 20, title = 'Medium-Term Look Back Current Bar Has To Close Below This Value OR Long Term--Default=14', group = 'Williams Vix Fix')
str = input.int(3, minval = 1, maxval = 9, title = 'Entry Price Action Strength--Close > X Bars Back---Default=3', group = 'Williams Vix Fix')

show_StochCCI = input.bool(false, 'Show StochCCI', inline = 'show_scci', group = 'Ehlers Stochastic CCI')
show_dots = input.bool(false, 'Show Circle on Cross', inline = 'show_scci', group = 'Ehlers Stochastic CCI')
color_change = input.bool(true, 'Color Change', inline = 'show_scci', group = 'Ehlers Stochastic CCI')
RSI_Length = input.int(8, 'Length: RSI', minval = 1, inline = 'len', group = 'Ehlers Stochastic CCI')
Stoc_Length = input.int(8, 'Stoch', minval = 1, inline = 'len', group = 'Ehlers Stochastic CCI')
WMA_Length = input.int(5, 'WMA', minval = 1, inline = 'len', group = 'Ehlers Stochastic CCI')
alert_StochCCI = input.bool(false, '◁ Alert: [Buy / Sell]', group = 'Ehlers Stochastic CCI')

//_____________________________________________________________________________________________
// Based on "Stochastic Weights - Basic [BigBitsIO]" - Author: @BigBitsIO
// https://www.tradingview.com/script/DOgvQOPh-Stochastic-Weights-Basic-BigBitsIO/
//_____________________________________________________________________________________________
int Weights = 0
float WeightedTotal = 0

float percentChange = 0
float SPC = 0
float StochPC = 0
if enableStochPC
    percentChange := (close - open) / open * 100
    SPC := ta.sma(percentChange, superStochPCFastSmoothLength)
    StochPC := ta.sma(ta.stoch(SPC, SPC, SPC, lengthStochPC), smoothStochPCK)
    Weights := Weights + 1
    WeightedTotal := WeightedTotal + StochPC
    WeightedTotal

float Stoch = 0
if enableStoch
    Stoch := ta.sma(ta.stoch(close, high, low, lengthStoch), smoothStochK)
    Weights := Weights + 1
    WeightedTotal := WeightedTotal + Stoch
    WeightedTotal

float RSIInStochRSI = 0
float StochRSI = 0
if enableStochRSI
    RSIInStochRSI := ta.rsi(close, rsiLengthInStochRSI)
    StochRSI := ta.sma(ta.stoch(RSIInStochRSI, RSIInStochRSI, RSIInStochRSI, lengthStochRSI), smoothStochRSIK)
    Weights := Weights + 1
    WeightedTotal := WeightedTotal + StochRSI
    WeightedTotal

float RSI = 0
if enableRSI
    RSI := ta.rsi(close, rsiLength)
    Weights := Weights + 1
    WeightedTotal := WeightedTotal + RSI
    WeightedTotal

float VOLInStochVOL = 0
float SVOL = 0
float StochVOL = 0
if enableStochVOL
    VOLInStochVOL := close >= open ? volume : volume * -1
    SVOL := ta.sma(VOLInStochVOL, superStochVOLFastSmoothLength)
    StochVOL := ta.sma(ta.stoch(SVOL, SVOL, SVOL, lengthStochVOL), smoothStochVOLK)
    Weights := Weights + 1
    WeightedTotal := WeightedTotal + StochVOL
    WeightedTotal

k = WeightedTotal / Weights
d = ta.sma(k, smoothD)

plot(show_StochW ? k : na, color = color.aqua, title = 'K (Weighted)', linewidth = 2)
plot(show_StochW ? d : na, color = color.orange, title = 'D', linewidth = 2)
h0 = hline(80, 'Overbought Level')
h1 = hline(20, 'Oversold Level')
fill(h0, h1, color = color.new(color.purple, 80))

//_____________________________________________________________________________________________
// Based on "Matrix Series and Vix Fix with VWAP CCI and QQE Signals" 
// Author: @ChrisMoody and @OskarGallard
// https://www.tradingview.com/script/n8l5QqjD/
//_____________________________________________________________________________________________
// Williams Vix Fix Formula
wvf = (ta.highest(close, pd) - low) / ta.highest(close, pd) * 100
sDev = mult * ta.stdev(wvf, bbl)
midLine = ta.sma(wvf, bbl)
lowerBand = midLine - sDev
upperBand = midLine + sDev
rangeHigh = ta.highest(wvf, lb) * ph

// Filtered Criteria
upRange = low > low[1] and close > high[1]
upRange_Aggr = close > close[1] and close > open[1]
// Filtered Criteria
filtered = (wvf[1] >= upperBand[1] or wvf[1] >= rangeHigh[1]) and wvf < upperBand and wvf < rangeHigh
filtered_Aggr = (wvf[1] >= upperBand[1] or wvf[1] >= rangeHigh[1]) and not(wvf < upperBand and wvf < rangeHigh)

// Alerts Criteria
alert1 = wvf >= upperBand or wvf >= rangeHigh ? 1 : 0
alert2 = (wvf[1] >= upperBand[1] or wvf[1] >= rangeHigh[1]) and wvf < upperBand and wvf < rangeHigh ? 1 : 0
cond_FE = upRange and close > close[str] and (close < close[ltLB] or close < close[mtLB]) and filtered
alert3 = cond_FE ? 1 : 0
cond_AE = upRange_Aggr and close > close[str] and (close < close[ltLB] or close < close[mtLB]) and filtered_Aggr
alert4 = cond_AE ? 1 : 0

color_VF = bool(alert1) ? color.new(color.lime, 60) : bool(alert2) ? color.new(color.teal, 60) : color.new(color.silver, 80)

plotshape(sbcAggr and bool(alert4) ? alert4 : na, title = 'Aggressive Entry', color = color.new(#80FF00, 0), style = shape.triangleup, location = location.bottom, text = 'AE', textcolor = color.new(#80FF00, 0))
bgcolor(sbcAggr and bool(alert4) ? color.new(#80FF00, 80) : na, title = 'Aggressive Entry')
plotshape(sbcFilt and bool(alert3) ? alert3 : na, title = 'Filtered Entry', color = color.new(#15FF00, 0), style = shape.triangleup, location = location.bottom, text = 'FE', textcolor = color.new(#15FF00, 0))
bgcolor(sbcFilt and bool(alert3) ? color.new(#15FF00, 80) : na, title = 'Filtered Entry')

if alert_AE and cond_AE
    alert('Symbol = (' + syminfo.tickerid + ') \n TimeFrame = (' + timeframe.period + ') \n Current Price (' + str.tostring(close) + ') \n Aggressive Entry [VixFix].-', alert.freq_once_per_bar_close)

if alert_FE and cond_FE
    alert('Symbol = (' + syminfo.tickerid + ') \n TimeFrame = (' + timeframe.period + ') \n Current Price (' + str.tostring(close) + ') \n Filtered Entry [VixFix].-', alert.freq_once_per_bar_close)

isOverBought = ta.crossunder(k, d) and d > 80
plotshape(show_exit and isOverBought, title = 'Stochastic Crossover', color = color.new(#FF8080, 0), style = shape.triangledown, location = location.top, text = 'S', textcolor = color.new(#FF8080, 0))
bgcolor(show_exit and isOverBought ? color.new(#FF0015, 65) : na, title = 'Stochastic Crossover')

if alert_Stoch and isOverBought
    alert('Symbol = (' + syminfo.tickerid + ') \n TimeFrame = (' + timeframe.period + ') \n Current Price (' + str.tostring(close) + ') \n Exit [Stochastic Crossover].-', alert.freq_once_per_bar_close)

//_____________________________________________________________________________________________
// Based on "Ehlrers StochCCI" - Author: @glaz
// https://www.tradingview.com/script/OC5yz8CP-Ehlrers-StochCCI/
//_____________________________________________________________________________________________
// A variation of Ehlers Stochastic RSI 
Value1 = ta.cci(hlc3, RSI_Length) - ta.lowest(ta.cci(hlc3, RSI_Length), Stoc_Length)
Value2 = ta.highest(ta.cci(close, RSI_Length), Stoc_Length) - ta.lowest(ta.cci(close, RSI_Length), Stoc_Length)
Value3 = nz(Value1 / Value2)
Value4 = ta.wma(Value3, WMA_Length) * 100 //2 * (ta.wma(Value3, WMA_Length) - 0.5)
Trigger = Value4[1]
cross_UP = ta.crossover(Value4, Trigger) and Value4 < 50
cross_DN = ta.crossunder(Value4, Trigger) and Value4 > 50

col = color_change ? Value4 > Value4[1] ? #00FF90 : #FF006E : #00FF90
plot(show_StochCCI ? Value4 : na, 'StochCCI', color = col)
plot(show_StochCCI ? Trigger : na, 'Trigger', color = color.yellow)

plot(show_dots and cross_UP ? Trigger : na, title = 'Buy\'s Dots', color = color.new(#00FF90, 40), style = plot.style_circles, linewidth = 5)
plot(show_dots and cross_DN ? Trigger : na, title = 'Sell\'s Dots', color = color.new(#FF006E, 30), style = plot.style_circles, linewidth = 5)

if alert_StochCCI and cross_UP
    alert('Symbol = (' + syminfo.tickerid + ') \n TimeFrame = (' + timeframe.period + ') \n Current Price (' + str.tostring(close) + ') \n Buy [StochCCI].-', alert.freq_once_per_bar_close)

if alert_StochCCI and cross_DN
    alert('Symbol = (' + syminfo.tickerid + ') \n TimeFrame = (' + timeframe.period + ') \n Current Price (' + str.tostring(close) + ') \n Sell [StochCCI].-', alert.freq_once_per_bar_close)
````
