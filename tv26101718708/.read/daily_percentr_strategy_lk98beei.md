# Daily PercentR Strategy

- url: https://www.tradingview.com/script/Lk98Beei-Daily-PercentR-Strategy/
- type: strategy
- pine_id: PUB;y71HvuUnyjy8z6pizpaamMldr1yC3HHj
- version: 2.0

## Description

The PercentR strategy from Larry Williams is highly profitable on the daily nasdaq chart

Buy at the open if PercentR Indicator is above –87 and below –20 
Exit at the end of the day.

## Source Code

````pine
//@version=5
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © zweiprozent original strategy by larry williams

strategy('Daily PercentR Long Strategy', overlay=false)
//default_qty_type=strategy.percent_of_equity, default_qty_value=100)

f_security(_sym, _res, _src, _rep) =>
    request.security(_sym, _res, _src[not _rep and barstate.isrealtime ? 1 : 0])[_rep or barstate.isrealtime ? 0 : 1]

pctP = input.int(15, minval=1, maxval=99, title='Percentage Input For PBars, What % The Wick Of Candle Has To Be')
pblb = input.int(10, minval=1, maxval=100, title='PBars Look Back Period To Define The Trend of Highs and Lows')
pctS = input.int(15, minval=1, maxval=99, title='Percentage Input For Shaved Bars, Percent of Range it Has To Close On The Lows or Highs')
neareight = input(true, title=' only above 18 sma')
aboveeighteen = input(true, title='above 200 sma')
lowhighlow = input(true, title='low high low %R')
twobar = input(false, title='two instead of 1 bar trailing stop')
//PBar Percentages
pctCp = pctP * .01
pctCPO = 1 - pctCp

//Shaved Bars Percentages
pctCs = pctS * .01
pctSPO = pctCs

range_1 = high - low

///PinBars
pBarUp() =>
    open > high - range_1 * pctCPO and close > high - range_1 * pctCPO and low <= ta.lowest(pblb) ? 1 : 0
pBarDn() =>
    open < high - range_1 * pctCp and close < high - range_1 * pctCp and high >= ta.highest(pblb) ? 1 : 0

//Shaved Bars
sBarUp() =>
    close >= high - range_1 * pctCs
sBarDown() =>
    close <= low + range_1 * pctCs


D_High = request.security(syminfo.tickerid, 'D', high[1])
D_Low = request.security(syminfo.tickerid, 'D', low[1])
D_Close = request.security(syminfo.tickerid, 'D', close[1])
D_Open = request.security(syminfo.tickerid, 'D', open[1])

LowMarker = input(-67, 'Low Marker')

HighMarker = input(-17, 'High Marker')

length = input(title='Length', defval=3)
src = input(close, 'Source')
_pr(length) =>
    max = ta.highest(length)
    min = ta.lowest(length)
    100 * (src - max) / (max - min)
percentR = _pr(length)
obPlot = hline(LowMarker, title='Upper Band', color=#606060)
hline(-50, title='Middle Level', linestyle=hline.style_dotted, color=#606060)
osPlot = hline(HighMarker, title='Lower Band', color=#606060)
fill(obPlot, osPlot, title='Background', color=color.new(#9915ff, 90))
plot(percentR, title='%R', color=color.new(#3A6CA8, 0))

// Go Long - if percentR is not overbought/sold
M_Low1 = request.security(syminfo.tickerid, 'M', low[0])
M_Low2 = request.security(syminfo.tickerid, 'M', low[1])
//plot(M_Low2, title="mlow", color=#803aa8, transp=0)

ordersize = math.floor(strategy.equity / close)

if (percentR < LowMarker or percentR[1] < LowMarker) and (lowhighlow == false or low > ta.lowest(low, 9)[1] and low < close - 28 * syminfo.mintick) and time > timestamp(2020, 0, 0, 0, 0) and (aboveeighteen == false or high > ta.sma(close, 200)[0]) and (neareight or high > ta.sma(close, 18))  //(neareight or ((high>M_Low2 or (high>M_Low1 and sma(close,18)>sma(close,18)[1]))and high[1]>sma(close,18)[1] and ((low[0]<sma(close,18)[0]and low[1]>low[2] and sma(close,18)>sma(close,18)[1])or low[1]<sma(close,18)[0])))//or (percentR<percentR[1] and percentR[1]<percentR[2]))  //and highest(high,2)>=sma(close,18)  //and pBarDn() == false and sBarDown() == false 
    if high < ta.sma(close, 18) and (open >= close or high <= high[1])
        strategy.entry('Long', strategy.long, stop=high)
    if high < ta.sma(close, 18) and open < close and high > high[1]
        strategy.entry('Long', strategy.long, limit=low)
    if high >= ta.sma(close, 18)
        strategy.entry('Long', strategy.long, stop=close)



if strategy.position_avg_price > 0 and twobar == false  // or (high<high[1] and low>low[1]) or ((open<=close[1] and close>=open[1] and close<=close[1])or not (open>=close[1] and open<=open[1] and close<=open[1] and close>=close[1])))
    strategy.exit('Long', stop=low)

lexit = low - 56 * syminfo.mintick

if strategy.position_avg_price > 0 and twobar and (open <= high[1] or open > close[1] and close < open[1] and close[1] > open[1] or open < close[1] and close > open[1] and close[1] <= open[1])  //(high<high[1] and low>low[1])
    strategy.exit('Long', stop=lexit)

ll = ta.lowest(low, 3)

if strategy.position_avg_price > 0 and twobar and (open > high[1] or open <= close[1] and close >= open[1] and close[1] > open[1] or open > close[1] and close < open[1] and close[1] <= open[1])  //(high<high[1] and low>low[1])
    strategy.close_all()
````
