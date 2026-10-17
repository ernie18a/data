# BL_MTF River Strategy with TP/SL by Beller

- url: https://www.tradingview.com/script/bqGkc4RA-BL-MTF-River-Strategy-with-TP-SL-by-Beller/
- type: indicator
- pine_id: PUB;1061
- version: -1.0

## Description

Anyone remember the "Frogger" game where a frog must pass a river ?

This strategy is like a game.

Immagine you that the cyan lines are a River, any time the price can cross up or down this river, you must  buy or sell only when the bar are dry..

BUY at highest price of the first bar that is completely dry over the river
SELL at the lowest price of the first bar that is completely dry under the river

Stoploss is placed at the river bands, take profit is placed at 1:1 and 1:2 ratio, a risk money management must be applied.

This strategy can be used with multiple time frame, i'm testing it in 15min,180m and daily base applyed to EURJPY.

It's a game but can produce some money... ;-)

## Source Code

````pine
//Created By Beller on 09-MAR-2015
// 
study(title="BL_MTF River Strategy with TP/SL by Beller", shorttitle="BL_MTF River Strategy", overlay=true)
bblenght = input(55, minval=1, title="Bollinger Bars Lenght")
bbstdev = input(0.2, minval=0.2, title="Bollinger Bars Standard Deviation")


//Calculate BB 55 0.2
source = close
basis = sma(source, bblenght)
dev = bbstdev * stdev(source, bblenght)
upperBB = basis + dev
lowerBB = basis - dev
//is over the top?
isOverBBTop = low > upperBB ? true : false
isUnderBBBottom = high < lowerBB ? true : false
newisOverBBTop = isOverBBTop != isOverBBTop[1]
newisUnderBBBottom = isUnderBBBottom != isUnderBBBottom[1]
//receive high and low range
high_range = valuewhen(newisOverBBTop,high,0)
low_range = valuewhen(newisUnderBBBottom,low,0)

bblow = valuewhen(newisOverBBTop,(lowerBB/0.00005) *  0.00005,0)
bbhigh = valuewhen(newisUnderBBBottom,(((upperBB*1000)/5)+5) * 5/1000,0)

//take it only if over the BB limit
buy_limit_entry = isOverBBTop ? high_range==high_range[1] ? high_range+0.001: na : na
sell_limit_entry = isUnderBBBottom ? low_range==low_range[1] ? low_range-0.001: na : na

take_profit_buy=  isOverBBTop ? high_range==high_range[1] ? buy_limit_entry + buy_limit_entry-bblow : na : na 
take_profit_sell= isUnderBBBottom ? low_range==low_range[1] ? sell_limit_entry - (bbhigh-sell_limit_entry) : na : na

take_profit2_buy=  isOverBBTop ? high_range==high_range[1] ? buy_limit_entry + 2*(buy_limit_entry-bblow) : na : na 
take_profit2_sell= isUnderBBBottom ? low_range==low_range[1] ? sell_limit_entry - 2*(bbhigh-sell_limit_entry) : na : na

stop_loss_buy = isOverBBTop ? high_range==high_range[1] ? bblow : na : na 
stop_loss_sell = isUnderBBBottom ? low_range==low_range[1] ? bbhigh : na : na

highlightHigh = isOverBBTop ? lime : aqua
highlightLow  = isUnderBBBottom ? lime : aqua

colorLineUp = buy_limit_entry ? blue : blue
colorLineDown = sell_limit_entry ? red : red


colorBuyTP = close>=take_profit_buy ? lime : fuchsia
colorSellTP = close<=take_profit_sell ? lime : fuchsia
colorBuyTP2 = close>=take_profit2_buy ? lime : fuchsia
colorSellTP2 = close<=take_profit2_sell ? lime : fuchsia

barcolor((high >= lowerBB and low <= upperBB) ? aqua : na)
barcolor((high < sell_limit_entry and low > take_profit_sell) ? orange : na)
barcolor((low > buy_limit_entry and high < take_profit_buy) ? orange : na)
barcolor(high >= take_profit_buy and not(na(buy_limit_entry)==1) ? fuchsia : low <= take_profit_sell and not(na(sell_limit_entry)==1) ? fuchsia : na)




//plot Statements
bbup=plot(upperBB, title="BB Upper Band", style=linebr, linewidth=2, color=highlightHigh)
bbdo=plot(lowerBB, title="BB Bottom Band", style=linebr, linewidth=2, color=highlightLow)
plot( buy_limit_entry, title="Buy Entry", style=linebr, linewidth=2, color=colorLineUp, transp=80)
plot( sell_limit_entry, title="Short Entry", style=linebr, linewidth=2, color=colorLineDown, transp=80)
plot( stop_loss_buy, title="Buy Stop", style=circles, linewidth=2, color=maroon, transp=0)
plot( stop_loss_sell, title="Short Stop", style=circles, linewidth=2, color=maroon, transp=20)
plot( take_profit_buy, title="Buy TP 1:1", style=circles, linewidth=2, color=colorBuyTP, transp=20)
plot( take_profit_sell, title="Short TP 1:1", style=circles, linewidth=2, color=colorSellTP, transp=20)
plot( take_profit2_buy, title="Buy TP2 1:2", style=circles, linewidth=2, color=colorBuyTP2, transp=20)
plot( take_profit2_sell, title="Short TP2 1:2", style=circles, linewidth=2, color=colorSellTP2, transp=20)
fill(bbup, bbdo, color=aqua, transp=80)
````
