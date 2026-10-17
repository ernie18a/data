# Rising ADX strategy

- url: https://www.tradingview.com/script/z2yjKdbe-Rising-ADX-strategy/
- type: strategy
- pine_id: PUB;a57b387494b14ed7adebad0a8ad44d51
- version: 1.0

## Description

I have always been a huge fan of ADX. Its good for finding out good trending moves.
But it has been said that only ADX after 20 or 25 is good for trending market, but few trend gets completed at that level.

So I have come up with a logic to find out the rising ADX. This could be used to determine the trending moves from the start.

Buy signal:
When close is greater than moving average 1 and 2. This moving average can be SMA, EMA, WMA or HMA.
When ADX is greater than the threshold range. I have taken 10 as my minimum range.
Of course important of all ADX should be rising which implies trend is about to start.

Buy exit:
When close is less than moving average 1 and 2. This moving average can be SMA, EMA, WMA or HMA.
When ADX is lesser than the threshold range. I have taken 10 as my minimum range.
ADX falling which implies trend is about to end.

Sell signal:
I don't repeat the above logic again.
Everything similar to buy signal except above moving average. For selling it should be below moving average.

Strategy can be tested for long and short sides.

Note: No Repainting as the logic is very simple.

Using this script we can identify the best timeframe the script trend yields profit.

Test and provide your comments.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dhilipthegreat

//@version=4
//Rising ADX strategy

strategy(title="Rising ADX strategy", overlay=false,pyramiding=25, default_qty_type=strategy.fixed, default_qty_value=25,    initial_capital=100000, currency=currency.USD)

adxlen = input(14, title="ADX Length", minval=1)
threshold = input(10, title="threshold", minval=5)

hline(threshold, color=color.black, linestyle=hline.style_dashed)

atype = input(2,minval=1,maxval=7,title="1=SMA, 2=EMA, 3=WMA, 4=HullMA")
malen=input(20, title="Moving average 1 ",minval=1, maxval=50)
avg = atype == 1 ? sma(close,malen) : atype == 2 ? ema(close,malen) : atype == 3 ? wma(close,malen) : atype == 4 ? hma(close,malen) : na

atype2 = input(2,minval=1,maxval=7,title="1=SMA, 2=EMA, 3=WMA, 4=HullMA")
malen2=input(20, title="Moving average 2",minval=1, maxval=200)
avg2 = atype2 == 1 ? sma(close,malen2) : atype2 == 2 ? ema(close,malen2) : atype2 == 3 ? wma(close,malen2) : atype2 == 4 ? hma(close,malen2) : na

//ADX&DI
dilen = 14
dirmov(len,_high,_low,_tr) =>
	up = change(_high)
	down = -change(_low)
	plusDM = na(up) ? na : (up > down and up > 0 ? up : 0)
    minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
	truerange = rma(_tr, len)
	
	plus = fixnan(100 * rma(plusDM, len) / truerange)
	minus = fixnan(100 * rma(minusDM, len) / truerange)

	[plus, minus]

adx(dilen, adxlen,_high,_low,_tr) =>
	[plus, minus] = dirmov(dilen,_high,_low,_tr)
	sum = plus + minus
	adx = 100 * rma(abs(plus - minus) / (sum == 0 ? 1 : sum), adxlen)

[plus, minus] = dirmov(dilen,high,low,tr)
sig = adx(dilen, adxlen,high,low,tr)
prev_sig = adx(dilen, adxlen,high[1],low[1],tr)
plot(sig ? sig : na, color = rising(sig, 1) ? color.lime : falling(sig, 1) ? color.orange : color.purple, title="ADX",linewidth=2)

//////
longCondition=  sig > threshold  and rising(sig, 1) and falling(prev_sig, 1) and close > avg and close > avg2
barcolor(longCondition ? color.yellow: na)
Long_side = input(false, "Long side")
if Long_side
    strategy.entry(id="Long", long=true,  when= longCondition  and strategy.position_size<1)
    exitCondition=  (rising(prev_sig, 1) and falling(sig, 1)) or close < avg and close < avg2
    strategy.close(id="Long",comment="L exit",    qty=strategy.position_size ,   when= exitCondition)   //close all

shortCondition=  sig > threshold  and rising(sig, 1) and falling(prev_sig, 1) and close < avg and close < avg2
barcolor(shortCondition ? color.gray: na)
Short_side = input(false, "Short side")
if Short_side
    strategy.entry(id="Short", long=false,  when= shortCondition  and strategy.position_size<1)
    sell_exitCondition=  (rising(prev_sig, 1) and falling(sig, 1)) or close > avg and close > avg2
    strategy.close(id="Short",comment="S exit",    qty=strategy.position_size ,   when= sell_exitCondition)   //close all

barcolor(strategy.position_size>1 ? color.lime: na)
bgcolor(strategy.position_size>1 ? color.lime: na)

barcolor(strategy.position_size<0 ? color.orange: na)
bgcolor(strategy.position_size<0 ? color.orange: na)
````
