# Power Of Stocks - Bollinger Band & 5Ema Indicator - Keanu_RiTz

- url: https://www.tradingview.com/script/q4oJNMqK-Power-Of-Stocks-Bollinger-Band-5Ema-Indicator-Keanu-RiTz/
- type: indicator
- pine_id: PUB;f2500ee8e0b14fe9a1fee2080687a760
- version: 3.0

## Description

Power of Stocks - Bollinger band & 5ema Strategy


In this script you get to take Buy/Sell trades using the 3 options mentioned below.(Alerts with price levels for buy/sell at , SL & Target are included in this one)

1. Combined Strategy :- uses confirmation from both strategies to trade.
2. Bollinger band Strategy :- use the Bollinger band Strategy to trade.
3. 5ema Strategy :- use the 5ema Strategy to trade.


1. Combined Strategy :-

for Selling :- we will go short/sell only when conditions of both strategies are satisfied.
	i.e. when a candle is completely above the upper Bollinger band & completely above the 5ema then it will be our Alert Candle.
	We Short/Sell only when the low of the Alert candle is broken or when the candle closes below the close of the Alert Candle.
		SL will be above high of the Alert Candle. Target will be minimum 1:3 or as per your emotions.
		
for Buying:- we will go Long/Buy only when conditions of both strategies are satisfied.
	i.e. when a candle is completely below the lower Bollinger band & completely below the 5ema then it will be our Alert Candle.
	We go Long/Buy only when the high of the Alert candle is broken or when the candle closes above the close of the Alert Candle.
		SL will be below low of the Alert Candle. Target will be minimum 1:3 or as per your emotions.


2. Power of Stocks - Bollinger Band Strategy :-

Bollinger band with standard deviation = 1.5

when a candle is completely above the upper Bollinger band, that candle will be called a signal/alert candle.
Initiate a Sell trade when that alert candles low is broken. SL will be above high of that alert candle.
Risk to reward ratio will be 1:4 i.e. target will be 4 times the SL.

when a candle is completely below the lower Bollinger band, that candle will be called a signal/alert candle.
Initiate a Buy trade when that alert candles high is broken. SL will be below low of that alert candle.
Risk to reward ratio will be 1:4 i.e. target will be 4 times the SL.

other rules for Options buying:- minimum 15min timeframe
The day you initiate the position , you should be in profit above 10%-15% then only you should carry forward that position overnight, otherwise squareoff your trade on that day only.
Buy ATM or slightly OTM, SL max 100 points , target 1:4

for Long-term/Investing  :- Minimum Weekly
If candle is outside the lower band then initiate a Buy trade when that candles High is broken. Sl will be below Low of that candle.
for Long-term Target will be according to your emotions.


3. Power of Stocks - 5ema Strategy (target minimum 1:3)
Timeframe - 
	5 min for Selling (Sell Futures/index/stocks or buy Put)
	15 min for Buying (Buy Futures/index/stocks or sell Put)


for selling stocks :-
you should enter trade within 10am , don't look for entries after that time. take only 2 entries a day.

for selling Index(Banknifty) :-
you can take trade at anytime of the day whenever conditions get satisfied. you can take multiple entries in banknifty as it is very volatile.

for options choose atm strikes: selling trade
sl for premium between 200-300 :- 20-30 points SL
sl for premium between 400-500 :- 40-50 points SL
sl for premium between 500-600 :- 50-60 points SL



Subhashish Pani's (power of stocks) 5 EMA Strategy:-

It plots 5 EMA and Buy/Sell signals with Target & Stoploss levels.

What is Subhashish Pani's (power of stocks) 5 EMA Strategy :- 
    His strategy is very simple to understand. for intraday use 5 minutes timeframe for selling. You can sell futures, sell call or buy Puts in selling strategy.
What this strategy tries to do is , it tries to catch the tops, so when you sell at top & it turns out to be a reversal point then you can get good profit.
this will hit stop losses often, but stop losses are small and minimum target should be 1:3. but if you stay with the trend you can get big profits.
According to Subhashish Pani this strategy has 60% success rate.

Strategy for Selling (Short future/Call/stock or buy Put)
When ever a Candle closes completely above 5 ema (no part of candle should be touching the 5ema), then that candle should be considered as Alert Candle.
If the next candle is also completely above 5 ema and it has not broken the low of previous alert candle, Then the previous Alert Candle should be ignored and the new candle should be considered as new Alert Candle.
so if this goes on then continue shifting the Alert Candle, but whenever the next candle breaks the low of the Alert Candle we should take the Short trade (Short future/Call/stock or buy Put).
Stoploss will be above high of the Alert Candle and minimum target will be 1:3. 

Strategy for Buying (Buy future/Call/stock or sell Put) 
When ever a Candle closes completely below 5 ema (no part of candle should be touching the 5ema), then that candle should be considered as Alert Candle.
If the next candle is also completely below 5 ema and it has not broken the high of previous alert candle, Then the previous Alert Candle should be ignored and the new candle should be considered as new Alert Candle.
so if this goes on then continue shifting the Alert Candle, but whenever the next candle breaks the high of the Alert Candle we should take the Long trade  (Buy future/Call/stock or sell Put).
Stoploss will be below low of the Alert Candle and minimum target will be 1:3. 

Buy/Sell with extra conditions :
it just adds 1 more condition to buying/selling
1. checks if closing of current candle is lower than alert candles closing for Selling & checks if closing of current candle is higher than alert candles closing for Buyling.
	 This can sometimes save you from false moves but by using this, you can also miss out on big moves as you'll enter trade after candle closing instead of entering at break of high/low.

Note :- According to Subhashish Pani Timeframe for intraday buying should be 15 minutes Timeframe.

If you haven't understood the strategy by reading above description, then search for "Subhashish Pani's (power of stocks) 5 EMA Strategy" on YouTube to get a deeper understanding.

Note:- This is not only for Intraday trading , you can use this strategy for Positional/Swing trading as well. If you use this on Monthly Timeframe then it can be very good for Long Term Investing as well.
           Rules will be same for all types of trades & Timeframes.

## Source Code

````pine
//==================================================================================================================================================================================================================//
//===========================𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏 Power Of Stocks - Bollinger Band & 5Ema Strategy - Indicator Code Start - Keanu_RiTz{===========================//
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Keanu_ritz
//@version=5
//==================================================================================================================================================================================================================//
indicator(title='Power Of Stocks - Bollinger Band & 5Ema Strategy - Indicator_-_ Keanu_RiTz', overlay=true)
//==================================================================================================================================================================================================================//

Ecusl = input.bool(false, title="Enable the Extra SL shown below", group='Power Of Stocks - BB5Ema Combined Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
cusl = input.int(defval=5 , title='Value to set SL number of points below-low or above-high - BB5Ema Combined Strategy', minval=1, maxval=100, group='Power Of Stocks - BB5Ema Combined Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
CRiRe = input.int(defval=3,title='Risk to Reward Ratio - BB5Ema Combined Strategy',minval=2,maxval=25, group='Power Of Stocks - BB5Ema Combined Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
ShowCSell = input.bool(true,'Show Sell Signals - BB5Ema Combined Strategy', group='Power Of Stocks - BB5Ema Combined Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
ShowCBuy = input.bool(false,'Show Buy Signals - BB5Ema Combined Strategy', group='Power Of Stocks - BB5Ema Combined Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
CBSWCon = input.bool(defval=false, title='Buy/Sell with Extra Condition - candle close - BB5Ema Combined Strategy', tooltip='Extra Condition 1 : candle close greater/lesser than previous candle close, This can sometimes save you from false moves but by using this, you can also miss out on big moves as you will enter trade after candle closing instead of entering at break of high/low', group='Power Of Stocks - BB5Ema Combined Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')

Ebbusl = input.bool(false, title="Enable the Extra SL shown below", group='Power Of Stocks BollingerBand Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
bbusl = input.int(defval=5 , title='Value to set SL number of points below-low or above-high - Bollinger Band', minval=1, maxval=100, group='Power Of Stocks BollingerBand Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
BRiRe = input.int(defval=4,title='Risk to Reward Ratio - Bollinger Band',minval=2,maxval=25, group='Power Of Stocks BollingerBand Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
ShowBSell = input.bool(false,'Show Sell Signals - Bollinger Band', group='Power Of Stocks BollingerBand Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
ShowBBuy = input.bool(false,'Show Buy Signals - Bollinger Band', group='Power Of Stocks BollingerBand Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
BBSWCon = input.bool(defval=false, title='Buy/Sell with Extra Condition - candle close - Bollinger Band', tooltip='Extra Condition 1 : candle close greater/lesser than previous candle close, This can sometimes save you from false moves but by using this, you can also miss out on big moves as you will enter trade after candle closing instead of entering at break of high/low', group='Power Of Stocks BollingerBand Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')

Eusl = input.bool(false, title="Enable the Extra SL shown below", group='Power Of Stocks 5EMA Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
usl = input.int(defval=5 , title='Value to set SL number of points below-low or above-high - 5EMA Strategy', minval=1, maxval=100, group='Power Of Stocks 5EMA Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
RiRe = input.int(defval=3,title='Risk to Reward Ratio - 5EMA Strategy',minval=2,maxval=25, group='Power Of Stocks 5EMA Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
ShowSell = input.bool(false,'Show Sell Signals - 5EMA Strategy', group='Power Of Stocks 5EMA Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
ShowBuy = input.bool(false,'Show Buy Signals - 5EMA Strategy', group='Power Of Stocks 5EMA Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
BSWCon = input.bool(defval=false, title='Buy/Sell with Extra Condition - candle close - 5EMA Strategy', tooltip='Extra Condition 1 : candle close greater/lesser than previous candle close, This can sometimes save you from false moves but by using this, you can also miss out on big moves as you will enter trade after candle closing instead of entering at break of high/low', group='Power Of Stocks 5EMA Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')

length = 20
src = close
mult = input.float(1.5, minval=0.001, maxval=50, title="Bollinger Band StdDev", group='Power Of Stocks - BB5Ema Combined Strategy - 𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏')
basis = ta.sma(src, length)
dev = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev
offset = 0
plot(ShowCSell or ShowCBuy or ShowBSell or ShowBBuy ? basis : na, "Bollinger Band Basis", color=color.new(#FFFFFF,35),linewidth=4, offset = offset,display=display.all)
p1 = plot(ShowCSell or ShowCBuy or ShowBSell or ShowBBuy ? upper : na, "Upper Bollinger Band", color=color.new(#929594,50), offset = offset,display=display.all)
p2 = plot(ShowCSell or ShowCBuy or ShowBSell or ShowBBuy ? lower : na, "Lower Bollinger Band", color=color.new(#929594,50), offset = offset,display=display.all)
fill(p1, p2, title = "Background", color=color.new(#929594, 91))
ema5 = ta.ema(close,5)
pema5 = plot(ShowCSell or ShowCBuy or ShowSell or ShowBuy ? ema5 : na, '5 Ema', color=color.new(#882626, 0), linewidth=2)

var bool CShort  = na
var bool CLong  = na
var int cshortC = 0
var int csslhitC = 0
var int cstarhitC = 0
var float cssl = na
var float cstarl = na
var float cstar = na
var float csellat = na
var float calert_shorthigh = na
var float calert_shortlow = na
var bool ccan_drawssl = false
var bool ccan_drawstar = false
var line clssl = na
var line clstar = na
var line clsell = na
var label clssllbl = na
var label clstarlbl = na
var label clselllbl = na
var int clongC = 0
var int clslhitC = 0
var int cltarhitC = 0
var float clsl = na
var float cltarl = na
var float cltar = na
var float cbuyat = na
var float calert_longhigh = na
var float calert_longlow = na
var bool ccan_drawlsl = false
var bool ccan_drawltar = false
var line cllsl = na
var line clltar = na
var line clbuy = na
var label cllsllbl = na
var label clltarlbl = na
var label clbuylbl = na

var bool UBBTrap  = na
var bool LBBTrap  = na
var int UBBTrapC = 0
var int bbsslhitC = 0
var int bbstarhitC = 0
var float bbssl = na
var float bbstarl = na
var float bbstar = na
var float bbsellat = na
var float bbalert_shorthigh = na
var float bbalert_shortlow = na
var line bblssl = na
var line bblstar = na
var line bblsell = na
var label bblssllbl = na
var label bblstarlbl = na
var label bblselllbl = na
var int LBBTrapC = 0
var int bblslhitC = 0
var int bbltarhitC = 0
var float bblsl = na
var float bbltarl = na
var float bbltar = na
var float bbbuyat = na
var float bbalert_longhigh = na
var float bbalert_longlow = na
var line bbllsl = na
var line bblltar = na
var line bblbuy = na
var label bbllsllbl = na
var label bblltarlbl = na
var label bblbuylbl = na
var bool Short  = na
var bool Long  = na
var int shortC = 0
var int sslhitC = 0
var int starhitC = 0
var float ssl = na
var float starl = na
var float star = na
var float sellat = na
var float alert_shorthigh = na
var float alert_shortlow = na
var line lssl = na
var line lstar = na
var line lsell = na
var label lssllbl = na
var label lstarlbl = na
var label lselllbl = na
var int longC = 0
var int lslhitC = 0
var int ltarhitC = 0
var float lsl = na
var float ltarl = na
var float ltar = na
var float buyat = na
var float alert_longhigh = na
var float alert_longlow = na
var line llsl = na
var line lltar = na
var line lbuy = na
var label llsllbl = na
var label lltarlbl = na
var label lbuylbl = na

CShortWC = low[1] > upper[1] and low[1] > ema5[1] and low < low[1] and cshortC == 0 and close < close[1]
CShortWOC = low[1] > upper[1] and low[1] > ema5[1] and low < low[1] and cshortC == 0
CShort := CBSWCon ? CShortWC : CShortWOC
csslhit = high > cssl and cshortC > 0 and csslhitC == 0
cstarhit = low < cstar and cshortC > 0 and cstarhitC == 0

CLongWC =  high[1] < lower[1] and high[1] < ema5[1] and high > high[1] and clongC == 0 and close > close[1]
CLongWOC =  high[1] < lower[1] and high[1] < ema5[1] and high > high[1] and clongC == 0
CLong := CBSWCon ? CLongWC : CLongWOC
clslhit = low < clsl and clongC > 0 and clslhitC == 0
cltarhit = high > cltar and clongC > 0 and cltarhitC == 0

UBBTrapWC = low[1] > upper[1] and low[1] > low and UBBTrapC == 0 and close<close[1]
UBBTrapWOC = low[1] > upper[1] and low[1] > low and UBBTrapC == 0
UBBTrap := BBSWCon ? UBBTrapWC : UBBTrapWOC
bbsslhit = high > bbssl and UBBTrapC > 0 and bbsslhitC == 0
bbstarhit = low < bbstar and UBBTrapC > 0 and bbstarhitC == 0

LBBTrapWC =  high[1] < lower[1] and high[1] < high and LBBTrapC == 0 and close>close[1]
LBBTrapWOC =  high[1] < lower[1] and high[1] < high and LBBTrapC == 0
LBBTrap := BBSWCon ? LBBTrapWC : LBBTrapWOC
bblslhit = low < bblsl and LBBTrapC > 0 and bblslhitC == 0
bbltarhit = high > bbltar and LBBTrapC > 0 and bbltarhitC == 0

ShortWC = low[1] > ema5[1] and low[1] > low and shortC == 0 and close<close[1]
ShortWOC = low[1] > ema5[1] and low[1] > low and shortC == 0
Short := BSWCon ? ShortWC : ShortWOC
sslhit = high > ssl and shortC > 0 and sslhitC == 0
starhit = low < star and shortC > 0 and starhitC == 0

LongWC =  high[1] < ema5[1] and high[1] < high and longC == 0 and close>close[1]
LongWOC =  high[1] < ema5[1] and high[1] < high and longC == 0
Long := BSWCon ? LongWC : LongWOC
lslhit = low < lsl and longC > 0 and lslhitC == 0
ltarhit = high > ltar and longC > 0 and ltarhitC == 0

if CShort and ShowCSell
    cshortC := cshortC + 1
    csslhitC := 0
    cstarhitC := 0
    calert_shorthigh := high[1]
    if Ecusl
        cssl := high[1] + cusl
        cstarl := CBSWCon ? ((high[1] - close) + cusl) * CRiRe : ((high[1] - low[1]) + cusl) * CRiRe
    else
        cssl := high[1]
        cstarl := CBSWCon ? (high[1] - close) * CRiRe : (high[1] - low[1]) * CRiRe
    cstar := CBSWCon ? close - cstarl : low[1] - cstarl
    csellat := CBSWCon ? close : low[1]
    ccan_drawssl := true
    ccan_drawstar := true
    clssl := line.new(bar_index, cssl, bar_index, cssl, color=color.new(#fc2d01,25), style=line.style_dashed)
    clstar := line.new(bar_index, cstar, bar_index, cstar, color=color.new(color.green,25), style=line.style_dashed)
    clsell := line.new(bar_index, csellat, bar_index, csellat, color=color.new(color.orange,25), style=line.style_dashed)
    clssllbl := label.new(bar_index, cssl, style=label.style_none, text='Short SL - Combined' + ' (' + str.tostring(cssl) + ')', textcolor=color.new(#fc2d01,35), color=color.new(#fc2d01,35))
    clstarlbl := label.new(bar_index, cstar, style=label.style_none, text='Short Target - Combined' + ' (' + str.tostring(cstar) + ')', textcolor=color.new(color.green,35), color=color.new(color.green,35))
    clselllbl := label.new(bar_index, csellat, style=label.style_none, text='Sell at - Combined' + ' (' + str.tostring(csellat) + ')', textcolor=color.new(color.orange,35), color=color.new(color.orange,35))


if csslhit == false and cstarhit == false and cshortC > 0
    line.set_x2(clssl, bar_index)
    line.set_x2(clstar, bar_index)
    line.set_x2(clsell, bar_index)
    csslhitC := 0
    cstarhitC := 0
else
    if csslhit
        ccan_drawssl := false
        cshortC := 0
        csslhitC := csslhitC + 1
    else 
        if cstarhit
            ccan_drawstar := false
            cshortC := 0
            cstarhitC := cstarhitC + 1    

if CLong and ShowCBuy
    clongC := clongC + 1
    clslhitC := 0
    cltarhitC := 0
    calert_longlow := low[1]
    if Ecusl
        clsl := low[1] - cusl
        cltarl := CBSWCon ? ((close - low[1]) + cusl) * CRiRe : ((high[1] - low[1]) + cusl) * CRiRe
    else
        clsl := low[1]
        cltarl := CBSWCon ? (close - low[1]) * CRiRe : (high[1] - low[1]) * CRiRe
    cltar := CBSWCon ? close + cltarl : high[1] + cltarl
    cbuyat := CBSWCon ? close : high[1]
    ccan_drawlsl := true
    ccan_drawltar := true
    cllsl := line.new(bar_index, clsl, bar_index, clsl, color=color.new(#fc2d01,25), style=line.style_dotted)
    clltar := line.new(bar_index, cltar, bar_index, cltar, color=color.new(color.green,25), style=line.style_dotted)
    clbuy := line.new(bar_index, cbuyat, bar_index, cbuyat, color=color.new(color.orange,25), style=line.style_dotted)
    cllsllbl := label.new(bar_index, clsl, style=label.style_none, text='Long SL - Combined' + ' (' + str.tostring(clsl) + ')', textcolor=color.new(#fc2d01,35), color=color.new(#fc2d01,35))
    clltarlbl := label.new(bar_index, cltar, style=label.style_none, text='Long Target - Combined' + ' (' + str.tostring(cltar) + ')', textcolor=color.new(color.green,35), color=color.new(color.green,35))
    clbuylbl := label.new(bar_index, cbuyat, style=label.style_none, text='Buy at - Combined' + ' (' + str.tostring(cbuyat) + ')', textcolor=color.new(color.orange,35), color=color.new(color.orange,35))

if clslhit == false and cltarhit == false and clongC > 0
    line.set_x2(cllsl, bar_index)
    line.set_x2(clltar, bar_index)
    line.set_x2(clbuy, bar_index)
    clslhitC := 0
    cltarhitC := 0
else
    if clslhit
        ccan_drawlsl := false
        clongC := 0
        clslhitC := clslhitC + 1
    else
        if cltarhit
            ccan_drawltar := false
            clongC := 0
            cltarhitC := cltarhitC + 1


if UBBTrap and ShowBSell
    UBBTrapC := UBBTrapC + 1
    bbsslhitC := 0
    bbstarhitC := 0
    bbalert_shorthigh := high[1]
    if Ebbusl
        bbssl := high[1] + bbusl
        bbstarl := BBSWCon ? ((high[1] - close) + bbusl) * BRiRe : ((high[1] - low[1]) + bbusl) * BRiRe
    else
        bbssl := high[1]
        bbstarl := BBSWCon ? (high[1] - close) * BRiRe : (high[1] - low[1]) * BRiRe
    bbstar := BBSWCon ? close - bbstarl : low[1] - bbstarl
    bbsellat := BBSWCon ? close : low[1]
    bblssl := line.new(bar_index, bbssl, bar_index, bbssl, color=color.new(#fc2d01,45), style=line.style_dashed)
    bblstar := line.new(bar_index, bbstar, bar_index, bbstar, color=color.new(color.green,45), style=line.style_dashed)
    bblsell := line.new(bar_index, bbsellat, bar_index, bbsellat, color=color.new(color.orange,45), style=line.style_dashed)
    bblssllbl := label.new(bar_index, bbssl, style=label.style_none, text='Short SL - BB' + ' (' + str.tostring(bbssl) + ')', textcolor=color.new(#fc2d01,35), color=color.new(#fc2d01,35))
    bblstarlbl := label.new(bar_index, bbstar, style=label.style_none, text='Short Target - BB' + ' (' + str.tostring(bbstar) + ')', textcolor=color.new(color.green,35), color=color.new(color.green,35))
    bblselllbl := label.new(bar_index, bbsellat, style=label.style_none, text='Sell at - BB' + ' (' + str.tostring(bbsellat) + ')', textcolor=color.new(color.orange,35), color=color.new(color.orange,35))
    
if bbsslhit == false and bbstarhit == false and UBBTrapC > 0
    line.set_x2(bblssl, bar_index)
    line.set_x2(bblstar, bar_index)
    line.set_x2(bblsell, bar_index)
    bbsslhitC := 0
    bbstarhitC := 0
else
    if bbsslhit
        UBBTrapC := 0
        bbsslhitC := bbsslhitC + 1
    else
        if bbstarhit
            UBBTrapC := 0
            bbstarhitC := bbstarhitC + 1        

if LBBTrap and ShowBBuy
    LBBTrapC := LBBTrapC + 1
    bblslhitC := 0
    bbltarhitC := 0
    bbalert_longlow := low[1]
    if Ebbusl
        bblsl := low[1] - bbusl
        bbltarl := BBSWCon ? ((close - low[1]) + bbusl) * BRiRe : ((high[1] - low[1]) + bbusl) * BRiRe
    else
        bblsl := low[1]
        bbltarl := BBSWCon ? (close - low[1]) * BRiRe : (high[1] - low[1]) * BRiRe
    bbltar := BBSWCon ? close + bbltarl : high[1] + bbltarl
    bbbuyat := BBSWCon ? close : high[1]
    bbllsl := line.new(bar_index, bblsl, bar_index, bblsl, color=color.new(#fc2d01,45), style=line.style_dotted)
    bblltar := line.new(bar_index, bbltar, bar_index, bbltar, color=color.new(color.green,45), style=line.style_dotted)
    bblbuy := line.new(bar_index, bbbuyat, bar_index, bbbuyat, color=color.new(color.orange,45), style=line.style_dotted)
    bbllsllbl := label.new(bar_index, bblsl, style=label.style_none, text='Long SL - BB' + ' (' + str.tostring(bblsl) + ')', textcolor=color.new(#fc2d01,35), color=color.new(#fc2d01,35))
    bblltarlbl := label.new(bar_index, bbltar, style=label.style_none, text='Long Target - BB' + ' (' + str.tostring(bbltar) + ')', textcolor=color.new(color.green,35), color=color.new(color.green,35))
    bblbuylbl := label.new(bar_index, bbbuyat, style=label.style_none, text='Buy at - BB' + ' (' + str.tostring(bbbuyat) + ')', textcolor=color.new(color.orange,35), color=color.new(color.orange,35))

if bblslhit == false and bbltarhit == false and LBBTrapC > 0
    line.set_x2(bbllsl, bar_index)
    line.set_x2(bblltar, bar_index)
    line.set_x2(bblbuy, bar_index)
    bblslhitC := 0
    bbltarhitC := 0
else
    if bblslhit
        LBBTrapC := 0
        bblslhitC := bblslhitC + 1
    else
        if bbltarhit
            LBBTrapC := 0
            bbltarhitC := bbltarhitC + 1

if Short and ShowSell
    shortC := shortC + 1
    sslhitC := 0
    starhitC := 0
    alert_shorthigh := high[1]
    if Eusl
        ssl := high[1] + usl
        starl := BSWCon ? ((high[1] - close) + usl) * RiRe : ((high[1] - low[1]) + usl) * RiRe
    else
        ssl := high[1]
        starl := BSWCon ? (high[1] - close) * RiRe : (high[1] - low[1]) * RiRe
    star := BSWCon ? close - starl : low[1] - starl
    sellat := BSWCon ? close : low[1]
    lssl := line.new(bar_index, ssl, bar_index, ssl, color=color.new(#fc2d01,45), style=line.style_dashed)
    lstar := line.new(bar_index, star, bar_index, star, color=color.new(color.green,45), style=line.style_dashed)
    lsell := line.new(bar_index, sellat, bar_index, sellat, color=color.new(color.orange,45), style=line.style_dashed)
    lssllbl := label.new(bar_index, ssl, style=label.style_none, text='Short SL - 5ema' + ' (' + str.tostring(ssl) + ')', textcolor=color.new(#fc2d01,35), color=color.new(#fc2d01,35))
    lstarlbl := label.new(bar_index, star, style=label.style_none, text='Short Target - 5ema' + ' (' + str.tostring(star) + ')', textcolor=color.new(color.green,35), color=color.new(color.green,35))
    lselllbl := label.new(bar_index, sellat, style=label.style_none, text='Sell at - 5ema' + ' (' + str.tostring(sellat) + ')', textcolor=color.new(color.orange,35), color=color.new(color.orange,35))

if sslhit == false and starhit == false and shortC > 0
    line.set_x2(lssl, bar_index)
    line.set_x2(lstar, bar_index)
    line.set_x2(lsell, bar_index)
    sslhitC := 0
    starhitC := 0
else
    if sslhit
        shortC := 0
        sslhitC := sslhitC + 1
    else
        if low < star and shortC > 0 and starhitC == 0
            shortC := 0
            starhitC := starhitC + 1

if Long and ShowBuy
    longC := longC + 1
    lslhitC := 0
    ltarhitC := 0
    alert_longlow := low[1]
    if Eusl
        lsl := low[1] - usl
        ltarl := BSWCon ? ((close - low[1]) + usl) * RiRe : ((high[1] - low[1]) + usl) * RiRe
    else
        lsl := low[1]
        ltarl := BSWCon ? (close - low[1]) * RiRe : (high[1] - low[1]) * RiRe
    ltar := BSWCon ? close + ltarl : high[1] + ltarl
    buyat := BSWCon ? close : high[1]
    llsl := line.new(bar_index, lsl, bar_index, lsl, color=color.new(#fc2d01,45), style=line.style_dotted)
    lltar := line.new(bar_index, ltar, bar_index, ltar, color=color.new(color.green,45), style=line.style_dotted)
    lbuy := line.new(bar_index, buyat, bar_index, buyat, color=color.new(color.orange,45), style=line.style_dotted)
    llsllbl := label.new(bar_index, lsl, style=label.style_none, text='Long SL - 5ema' + ' (' + str.tostring(lsl) + ')', textcolor=color.new(#fc2d01,35), color=color.new(#fc2d01,35))
    lltarlbl := label.new(bar_index, ltar, style=label.style_none, text='Long Target - 5ema' + ' (' + str.tostring(ltar) + ')', textcolor=color.new(color.green,35), color=color.new(color.green,35))
    lbuylbl := label.new(bar_index, buyat, style=label.style_none, text='Buy at - 5ema' + ' (' + str.tostring(buyat) + ')', textcolor=color.new(color.orange,35), color=color.new(color.orange,35))

if lslhit == false and ltarhit == false and longC > 0
    line.set_x2(llsl, bar_index)
    line.set_x2(lltar, bar_index)
    line.set_x2(lbuy, bar_index)
    lslhitC := 0
    ltarhitC := 0    
else
    if lslhit
        longC := 0
        lslhitC := lslhitC + 1
    else
        if ltarhit
            longC := 0
            ltarhitC := ltarhitC + 1


plotshape(ShowCSell and CShort, title='Sell - Combined Strategy', location=location.abovebar, offset=0, color=color.new(#e74c3c, 65), style=shape.arrowdown, size=size.normal, text='Sell - Combined', textcolor=color.new(#e74c3c, 55))
plotshape(ShowCSell and csslhit, title='Short SL Hit - Combined Strategy', location=location.abovebar, offset=0, color=color.new(#fc2d01, 65), style=shape.arrowdown, size=size.normal, text='Short SL Hit - Combined', textcolor=color.new(#fc2d01, 25))
plotshape(ShowCSell and cstarhit, title='Short Target Hit - Combined Strategy', location=location.belowbar, offset=0, color=color.new(color.green, 65), style=shape.arrowup, size=size.normal, text='Short Target Hit - Combined', textcolor=color.new(color.green, 55))
plotshape(ShowCBuy and CLong, title='Buy - Combined Strategy', location=location.belowbar, offset=0, color=color.new(#2ecc71, 65), style=shape.arrowup, size=size.normal, text='Buy - Combined', textcolor=color.new(#2ecc71, 55))
plotshape(ShowCBuy and clslhit, title='Long SL Hit - Combined Strategy', location=location.belowbar, offset=0, color=color.new(#fc2d01, 65), style=shape.arrowdown, size=size.normal, text='Long SL Hit - Combined', textcolor=color.new(#fc2d01, 25))
plotshape(ShowCBuy and cltarhit, title='Long Target Hit - Combined Strategy', location=location.abovebar, offset=0, color=color.new(color.green, 65), style=shape.arrowup, size=size.normal, text='Long Target Hit - Combined', textcolor=color.new(color.green, 55))

plotshape(ShowBSell and UBBTrap, title='Sell - BB Strategy', location=location.abovebar, offset=0, color=color.new(#e74c3c, 45), style=shape.arrowdown, size=size.normal, text='Sell - BB', textcolor=color.new(#e74c3c, 55))
plotshape(ShowBSell and bbsslhit, title='Short SL Hit - BB Strategy', location=location.abovebar, offset=0, color=color.new(#fc2d01, 25), style=shape.arrowdown, size=size.normal, text='Short SL Hit - BB', textcolor=color.new(#fc2d01, 25))
plotshape(ShowBSell and bbstarhit, title='Short Target Hit - BB Strategy', location=location.belowbar, offset=0, color=color.new(color.green, 45), style=shape.arrowup, size=size.normal, text='Short Target Hit - BB', textcolor=color.new(color.green, 55))
plotshape(ShowBBuy and LBBTrap, title='Buy - BB Strategy', location=location.belowbar, offset=0, color=color.new(#2ecc71, 45), style=shape.arrowup, size=size.normal, text='Buy - BB', textcolor=color.new(#2ecc71, 55))
plotshape(ShowBBuy and bblslhit, title='Long SL Hit - BB Strategy', location=location.belowbar, offset=0, color=color.new(#fc2d01, 25), style=shape.arrowdown, size=size.normal, text='Long SL Hit - BB', textcolor=color.new(#fc2d01, 25))
plotshape(ShowBBuy and bbltarhit, title='Long Target Hit - BB Strategy', location=location.abovebar, offset=0, color=color.new(color.green, 45), style=shape.arrowup, size=size.normal, text='Long Target Hit - BB', textcolor=color.new(color.green, 55))

plotshape(ShowSell and Short, title='Sell - 5ema Strategy', location=location.abovebar, offset=0, color=color.new(#e74c3c, 45), style=shape.arrowdown, size=size.normal, text='Sell - 5ema', textcolor=color.new(#e74c3c, 55))
plotshape(ShowSell and sslhit, title='Short SL Hit - 5ema Strategy', location=location.abovebar, offset=0, color=color.new(#fc2d01, 25), style=shape.arrowdown, size=size.normal, text='Short SL Hit - 5ema', textcolor=color.new(#fc2d01, 25))
plotshape(ShowSell and starhit, title='Short Target Hit - 5ema Strategy', location=location.belowbar, offset=0, color=color.new(color.green, 45), style=shape.arrowup, size=size.normal, text='Short Target Hit - 5ema Strategy', textcolor=color.new(color.green, 55))
plotshape(ShowBuy and Long, title='Buy - 5ema Strategy', location=location.belowbar, offset=0, color=color.new(#2ecc71, 45), style=shape.arrowup, size=size.normal, text='Buy - 5ema', textcolor=color.new(#2ecc71, 55))
plotshape(ShowBuy and lslhit, title='Long SL Hit - 5ema Strategy', location=location.belowbar, offset=0, color=color.new(#fc2d01, 25), style=shape.arrowdown, size=size.normal, text='Long SL Hit - 5ema', textcolor=color.new(#fc2d01, 25))
plotshape(ShowBuy and ltarhit, title='Long Target Hit - 5ema Strategy', location=location.abovebar, offset=0, color=color.new(color.green, 45), style=shape.arrowup, size=size.normal, text='Long Target Hit - 5ema', textcolor=color.new(color.green, 55))


if ShowCSell and CShort
    alert("Go Short@ " + str.tostring(csellat) + " : SL@ " + str.tostring(cssl) + " : Target@ " + str.tostring(cstar) + " - Combined Strategy", alert.freq_once_per_bar )

if ShowCSell and csslhit
    alert("Short Stop-loss hit - Combined Strategy", alert.freq_once_per_bar )

if ShowCSell and cstarhit
    alert("Short Target hit - Combined Strategy", alert.freq_once_per_bar )

if ShowCBuy and CLong
    alert("Go Long@ " + str.tostring(cbuyat) + " : SL@ " + str.tostring(clsl) + " : Target@ " + str.tostring(cltar) + " - Combined Strategy", alert.freq_once_per_bar )

if ShowCBuy and clslhit
    alert("Long Stop-loss hit - Combined Strategy", alert.freq_once_per_bar )

if ShowCBuy and cltarhit
    alert("Long Target hit - Combined Strategy", alert.freq_once_per_bar )

if ShowBSell and UBBTrap
    alert("Go Short@ " + str.tostring(bbsellat) + " : SL@ " + str.tostring(bbssl) + " : Target@ " + str.tostring(bbstar) + " - BB Strategy", alert.freq_once_per_bar)

if ShowBSell and bbsslhit
    alert("Short Stop-loss hit - BB Strategy", alert.freq_once_per_bar)

if ShowBSell and bbstarhit
    alert("Short Target hit - BB Strategy", alert.freq_once_per_bar)

if ShowBBuy and LBBTrap
    alert("Go Long@ " + str.tostring(bbbuyat) + " : SL@ " + str.tostring(bblsl) + " : Target@ " + str.tostring(bbltar) + " - BB Strategy", alert.freq_once_per_bar)

if ShowBBuy and bblslhit
    alert("Long Stop-loss hit - BB Strategy", alert.freq_once_per_bar)

if ShowBBuy and bbltarhit
    alert("Long Target hit - BB Strategy", alert.freq_once_per_bar)

if ShowSell and Short
    alert("Go Short@ " + str.tostring(sellat) + " : SL@ " + str.tostring(ssl) + " : Target@ " + str.tostring(star) + " - 5Ema Strategy", alert.freq_once_per_bar)

if ShowSell and sslhit
    alert("Short Stop-loss hit - 5Ema Strategy", alert.freq_once_per_bar)

if ShowSell and starhit
    alert("Short Target hit - 5Ema Strategy", alert.freq_once_per_bar)

if ShowBuy and Long
    alert("Go Long@ " + str.tostring(buyat) + " : SL@ " + str.tostring(lsl) + " : Target@ " + str.tostring(ltar) + " - 5Ema Strategy", alert.freq_once_per_bar)

if ShowBuy and lslhit
    alert("Long Stop-loss hit - 5Ema Strategy", alert.freq_once_per_bar)

if ShowBuy and ltarhit
    alert("Long Target hit - 5Ema Strategy", alert.freq_once_per_bar)

//===========================𝒦𝑒𝒶𝓃𝓊_𝑅𝒾𝒯𝓏 Power Of Stocks - Bollinger Band & 5Ema Strategy - Indicator Code End - Keanu_RiTz===========================]//

//==================================================================================================================================================================================================================//
````
