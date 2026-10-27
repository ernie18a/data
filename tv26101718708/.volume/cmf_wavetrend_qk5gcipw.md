# CMF - WaveTrend

- url: https://www.tradingview.com/script/QK5gCiPw-CMF-WaveTrend/
- type: strategy
- pine_id: PUB;Mp3bYly14LxClehxlUXdliyzEfFACvO4
- version: 6.0

## Description

CMF - WaveTrend - Best performance on a 15-minute timeframe.

## Source Code

````pine
//@version=3
strategy(title = "CMF - WaveTrend", shorttitle = "CMF - WaveTrend", overlay = true, pyramiding = 0, default_qty_type = strategy.percent_of_equity, default_qty_value = 100, currency = currency.EUR, calc_on_order_fills=true, initial_capital = 1000, commission_type = "percent", commission_value = 0.05)

useStop  = input(true, "Use Stop Loss/Take Profit?") 
sl_inp = input(300, title='Stop Loss')
tp_inp = input(500, title='Take Profit')

//Chaikin Money Flow

len = input(30, minval=1, title="Length")
mas = input(title="Aggregation", defval="SUM", options=["SUM", "EMA", "WMA"])
e = input(9.0, title="Volume Exponent (0-10 reduces & 10+ increases volume effect)")
p = input(false, title="Show in Percentage")
mvs = input(true, "Factor in Price (Money Volume)")
src=input(hlc3, title="Source for price factor")

trl = min(low,close[1]), trh = max(high,close[1]) // 'true range' fixes issues caused by gaps in price
wv = pow(volume,e/10.0)*(mvs ? src : 1)
ad = (trh==trl ? 0 : (2*close-(trh+trl))/tr(true))*wv
cmf = mas=="SUM" ? sum(ad, len)/sum(wv, len) : mas=="EMA" ? ema(ad, len)/ema(wv, len) : mas=="WMA" ? wma(ad, len)/wma(wv, len) : na
cmf_p  = if p
    50*cmf+50
else
    cmf
b = p ? 50 : 0


//WaveTrend
n1 = input(10, "Channel Length")
n2 = input(21, "Average Length")
obLevel1 = input(49, "Over Bought Level 1")
obLevel2 = input(53, "Over Bought Level 2")
osLevel1 = input(-54, "Over Sold Level 1")
osLevel2 = input(-53, "Over Sold Level 2")
 
ap = hlc3 
esa = ema(ap, n1)
d = ema(abs(ap - esa), n1)
ci = (ap - esa) / (0.015 * d)
tci = ema(ci, n2)
 
wt1 = tci
wt2 = sma(wt1,4)
// 

qLong =  (crossover(wt1,osLevel1) and wt1 > wt2 and cmf < 0.04) 
qShort = (crossunder(wt1,obLevel1) and wt2 > wt1 and cmf > - 0.05)

longCondition = (wt1 < osLevel1 and cmf < - 0.15 and wt1 > wt2)
shortCondition = (wt1 > obLevel1 and cmf > 0.15 ) or (wt1 > 75 and wt2 > wt1) 

if (qLong)
 
    strategy.entry("My Long Entry Id", strategy.long)
    
 
if (qShort)
 
    strategy.entry("My Short Entry Id", strategy.short)
    


closeLongCondition = crossover(cmf_p[1],0.17) ? true : false
closeShortCondition = crossunder(cmf_p[1],-0.17)? true : false

long_stop_level = na
long_profit_level = na
long_stop_level := qLong ? open - sl_inp : long_stop_level[1]
long_profit_level := qLong ? close + tp_inp : long_profit_level[1]
 
short_stop_level = na
short_profit_level = na
short_stop_level := qShort ? open + sl_inp : short_stop_level[1]
short_profit_level := qShort ? close - tp_inp : short_profit_level[1]

if (useStop) 
    strategy.exit("TP/SL", "My Long Entry Id", stop=long_stop_level, limit=long_profit_level) 
    strategy.exit("TP/SL", "My Short Entry Id", stop=short_stop_level, limit=short_profit_level)
    
strategy.close("My Long Entry Id", when=(closeLongCondition == true))
strategy.close("My Short Entry Id", when=(closeShortCondition == true))
````
