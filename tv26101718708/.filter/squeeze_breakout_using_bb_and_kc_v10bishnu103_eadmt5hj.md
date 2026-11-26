# Squeeze Breakout using BB and KC [v1.0][Bishnu103]

- url: https://www.tradingview.com/script/eaDmt5hj-Squeeze-Breakout-using-BB-and-KC-v1-0-Bishnu103/
- type: strategy
- pine_id: PUB;jD59Q9f3wFYvj46jTG6HYAt3nTORtXrH
- version: 4.0

## Description

Squeeze Breakout using BB and KC [v1.0][Bishnu103]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Bishnu103

//@version=4
strategy(title="Squeeze Breakout using BB and KC [v1.0][Bishnu103]",shorttitle="BB BREAKOUT",overlay=true,calc_on_every_tick=true,backtest_fill_limits_assumption=2)

// ***********************************************************************************************************************
// input variables
bb_squeeze_switch   = input(title="BB Squeeze Check", type=input.bool, defval=true)
bb_squeeze_width    = input(title="BB Squeeze Width", minval=1.0, defval=3.0)
bb_in_kc_switch     = input(title="BB within KC Check", type=input.bool, defval=false)
ema_trend_switch    = input(title="EMA Trend Check", type=input.bool, defval=false)
ma200_trend_switch  = input(title="200MA Trend Check", type=input.bool, defval=true)
vol_check_switch    = input(title="Average Volume Check", type=input.bool, defval=false)
vol_check_length    = input(title="No of bars for Volume Check", minval=1, maxval=20, defval=20)
buy_session         = input(title="Buy Session", type=input.session, defval="0915-1430")
exit_inraday        = input(title="Exit Intraday?", type=input.bool, defval=true)
entry_distance      = input(title="Entry distance from alert", minval=1, maxval=10, defval=3)
show_bb_switch      = input(title="Show BB", type=input.bool, defval=true)
show_kc_switch      = input(title="Show KC", type=input.bool, defval=true)
show_8ema_switch    = input(title="Show 8EMA", type=input.bool, defval=true)
show_emas_switch    = input(title="Show EMAs", type=input.bool, defval=false)
//
bbLength            = input(title="BB Length", minval=1, defval=20)
bbStdDev            = input(title="BB StdDev", minval=1, defval=2)
kcLength            = input(title="KC Length", minval=1, defval=20)
kcMult              = input(title="KC Mult", defval=1.5)
atrLength           = input(title="ATR Length", minval=1, defval=20)

// ***********************************************************************************************************************
// global variables
closed_above_bb     = false
closed_below_bb     = false
long_entry          = false
short_entry         = false

// variable values available across candles
var entry_price     = 0.0  
var sl_price        = 0.0
var exit_price      = 0.0
var candle_count    = 0

// ***********************************************************************************************************************
// function to return bollinger band values based on candle poition passed 
getBB(pos) =>
    float basis = sma(close[pos], bbLength)
    float dev = bbStdDev * stdev(close[pos], bbLength)
    [basis, basis + dev, basis - dev]

// function to return Keltner Channel values based on candle poition passed 
getKC(pos) => 
    mKC     = ema(close[pos],kcLength)
    range   = kcMult * atr(atrLength)[pos]
    uKC     = mKC + range
    lKC     = mKC - range
    [mKC,uKC,lKC]
    
// function returns true if current time is within intraday byuing session set in input
BarInSession(sess) => time(timeframe.period, sess) != 0

// ***********************************************************************************************************************
// strategy
//
// get current bb value
[mBB_0,uBB_0,lBB_0] = getBB(0)
[mBB_1,uBB_1,lBB_1] = getBB(1)

// if a candle closes above bb and previous candle closed inside bb then it's a bullish signal
if close[0] > uBB_0
    closed_above_bb := true
    entry_price     := high[0]

// if a candle closes above bb and previous candle closed inside bb then it's a bullish signal
if close[0] < lBB_0
    closed_below_bb := true
    entry_price     := low[0]

// check if BB is in squeeze
bb_in_squeeze = bb_squeeze_switch ? ((uBB_1 - lBB_1) < (atr(20)[1] * bb_squeeze_width)) : true

// 6 candle's bb prior to the alert candle, are within keltner channel on either upper side of the bands or on lower side of the bands
// bb
[mBB_2,uBB_2,lBB_2] = getBB(2)
[mBB_3,uBB_3,lBB_3] = getBB(3)
[mBB_4,uBB_4,lBB_4] = getBB(4)
[mBB_5,uBB_5,lBB_5] = getBB(5)
[mBB_6,uBB_6,lBB_6] = getBB(6)
// kc
[mKC_1,uKC_1,lKC_1] = getKC(1)
[mKC_2,uKC_2,lKC_2] = getKC(2)
[mKC_3,uKC_3,lKC_3] = getKC(3)
[mKC_4,uKC_4,lKC_4] = getKC(4)
[mKC_5,uKC_5,lKC_5] = getKC(5)
[mKC_6,uKC_6,lKC_6] = getKC(6)
// check if either side 6 candle's bb are inside kc
lower_squeeze_is_good = uBB_1   < uKC_1 and uBB_2 < uKC_2 and uBB_3 < uKC_3 and uBB_4 < uKC_4 and uBB_5 < uKC_5 and uBB_6 < uKC_6
upper_squeeze_is_good = lBB_1   > lKC_1 and lBB_2 > lKC_2 and lBB_3 > lKC_3 and lBB_4 > lKC_4 and lBB_5 > lKC_5 and lBB_6 > lKC_6
squeeze_is_good                 = bb_in_kc_switch ? (upper_squeeze_is_good or lower_squeeze_is_good) : true

// EMAs (8, 21, 34, 55, 89) should be aligned in sequence
ema_8               = ema(close,8)
ema_21              = ema(close,21)
ema_34              = ema(close,34)
ema_55              = ema(close,55)
ema_89              = ema(close,89)
ema_trend_check1    = ema_trend_switch and closed_above_bb and ema_8 > ema_21 and ema_21 > ema_34 and ema_34 > ema_55 and ema_55 > ema_89
ema_trend_check2    = ema_trend_switch and closed_below_bb and ema_8 < ema_21 and ema_21 < ema_34 and ema_34 < ema_55 and ema_55 < ema_89
ema_trend_check     = ema_trend_switch ? (ema_trend_check1 or ema_trend_check2) : true

// average volume check 
avg_vol         = sma(volume,vol_check_length)
avg_vol_is_good = vol_check_switch ? (volume > avg_vol) : true

// consolidation
//long_consolidation = (highest(high[1],10) - lowest(low[1],10)) < (atr(10)[1] * 2.5)
//long_consolidation = lowest(low[1],6) / highest(high[1],6) >= 0.98

// buy above 200MA and sell below 200MA
above_200ma = ma200_trend_switch ? (close[1] > sma(close[1],200) and (sma(close[1],200)/close[1]) >= 0.97) : true
below_200ma = ma200_trend_switch ? (close[1] < sma(close[1],200) and (close[1]/sma(close[1],200)) >= 0.97) : true

// ***********************************************************************************************************************
// entry conditions 
long_entry   := closed_above_bb and bb_in_squeeze and squeeze_is_good and ema_trend_check and avg_vol_is_good and above_200ma 
short_entry  := closed_below_bb and bb_in_squeeze and squeeze_is_good and ema_trend_check and avg_vol_is_good and below_200ma 

// keep candle count since the alert generated so that order can be cancelled after N number of candle calling it out as invalid alert
candle_count := candle_count + 1
if long_entry or short_entry
    candle_count    := 0
    
if long_entry or short_entry
    exit_price      := na

if long_entry or short_entry
    sl_price        := mBB_0

// ***********************************************************************************************************************
// risk management
//
// long trade - a candle closes below 8ema and in next candle price crosses low of previous candle
// short trade - a candle closes above 8ema and in next candle price crosses high of previous candle
long_exit_8ema    = strategy.position_size > 0 and crossunder(close,ema(close,8))
short_exit_8ema   = strategy.position_size < 0 and crossover(close,ema(close,8))

if long_exit_8ema
    exit_price := low

if short_exit_8ema
    exit_price := high
    
// ***********************************************************************************************************************
// position sizing
price = if close[0] > 25000
    25000
else
    price = close[0]

qty = 25000/price

// ***********************************************************************************************************************
// entry
if long_entry and candle_count < entry_distance and strategy.position_size == 0
    strategy.entry("BUY", strategy.long, qty, stop=entry_price, comment="BUY @ "+ tostring(entry_price)) 

if short_entry and candle_count < entry_distance and strategy.position_size == 0
    strategy.entry("SELL", strategy.short, qty, stop=entry_price, comment="SELL @ "+ tostring(entry_price))

// cancel an order if N number of candles are completed after alert candle
strategy.cancel_all(candle_count > entry_distance)

// if current time is outside byuing session then do not enter intraday trade
strategy.cancel_all(timeframe.isintraday and not BarInSession(buy_session))

// ***********************************************************************************************************************
// exit
if strategy.position_size > 0 and long_exit_8ema
    strategy.exit("EXIT using 8EMA", "BUY", stop=exit_price, comment="EXIT @ "+ tostring(exit_price))

if strategy.position_size < 0 and short_exit_8ema
    strategy.exit("EXIT using 8EMA", "SELL", stop=exit_price, comment="EXIT @ "+ tostring(exit_price))

// close if sl hit
strategy.close("BUY",  when=(strategy.position_size > 0 and close < sl_price), qty=strategy.position_size, comment="EXIT @ "+ tostring(close))
strategy.close("SELL", when=(strategy.position_size < 0 and close > sl_price), qty=strategy.position_size, comment="EXIT @ "+ tostring(close))

// if intraday trade, close the trade at open of 15:15 candle
exit_intraday_time = timestamp(syminfo.timezone,year,month,dayofmonth,15,14,0)
if timeframe.isintraday and exit_inraday and time_close >= exit_intraday_time
    strategy.close("BUY",  when=strategy.position_size > 0, qty=strategy.position_size, comment="EXIT @ "+ tostring(close))
    strategy.close("SELL", when=strategy.position_size < 0, qty=strategy.position_size, comment="EXIT @ "+ tostring(close))

// ***********************************************************************************************************************
// plots    
//
// plot BB
[mBBp,uBBp,lBBp] = getBB(0)
p_mBB = plot(show_bb_switch ? mBBp : na, color=color.teal)
p_uBB = plot(show_bb_switch ? uBBp : na, color=color.teal)
p_lBB = plot(show_bb_switch ? lBBp : na, color=color.teal)
fill(p_uBB,p_lBB,color=color.teal,transp=95)

// plot KC
[mKCp,uKCp,lKCp] = getKC(0)
p_uKC = plot(show_kc_switch ? uKCp : na, color=color.red)
p_lKC = plot(show_kc_switch ? lKCp : na, color=color.red)

// plot 8 ema
plot(show_8ema_switch?ema_8:na,color=color.blue)

// plot EMAs
plot(show_emas_switch ? ema_8  : na, color=color.green)
plot(show_emas_switch ? ema_21 : na, color=color.lime)
plot(show_emas_switch ? ema_34 : na, color=color.maroon)
plot(show_emas_switch ? ema_55 : na, color=color.orange)
plot(show_emas_switch ? ema_89 : na, color=color.purple)
````
