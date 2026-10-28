# Keltner Channel [LINKUSDT] 1H

- url: https://www.tradingview.com/script/Dxqv8ftu-Keltner-Channel-LINKUSDT-1H/
- type: strategy
- pine_id: PUB;Sx8JILTHq2l0YpbKR9lMXOlb3tJJPduj
- version: 1.0

## Description

This is a long-only strategy tested on LINK/USDT, 1 hour bar, from Feb 2019. The entry is determined by the breakout of upper Keltnel Channel and when the +DI is higher than 32. Instead of a fixed stop-loss from the original script , I change the exit to the middle band of the Keltnel Channel. 1st profit target will close 20% of the position. 2nd profit target will close 30% of the position. While the remaining 50% position will be closed when the price closes below the middle band of the Keltnel Channel, to take advantage of big trend. All parameters are adjustable. I added another option to enable or disable the ribbon trend filter.

My thoughts: For the same period, LINK appreciated 3000%. So I guess most in and out strategies couldn’t beat a buy and hold strategy during this period. But this doesn’t mean that this strategy is not feasible as each strategy is designed to only take advantage of a certain pattern or behavior of the market. Also, short term strategies allow you to use leverage and hence enable you to use you capital efficiently. Commission is set to 0.1%, taking account of the slippage.

Suggestion: Please perform walk forward analysis before you use real money for trading. Parameters need to be adjusted from time to time depends on your analysis. Can try using ATR for profit targets as over a longer term, the volatility might drop hence a high fixed % profit targets might not be realistic.

Any suggestions are welcome!

## Source Code

````pine
//Original Idea by: @Wunderbit


//@version=4
strategy("Keltner Channel [LINKUSDT] 1H", overlay=true, initial_capital=3000,pyramiding = 0, currency="USD", default_qty_type=strategy.percent_of_equity, default_qty_value=100,  commission_type=strategy.commission.percent,commission_value=0.1)


/// TREND
trend_cond = input(true, title="Enable Ribbon Filter")
ribbon_period = input(30, "Ribbon Period", step=1)

leadLine1 = ema(close, ribbon_period)
leadLine2 = sma(close, ribbon_period)

// p3 = plot(leadLine1, color= #53b987, title="EMA", transp = 50, linewidth = 1)
// p4 = plot(leadLine2, color= #eb4d5c, title="SMA", transp = 50, linewidth = 1)
// fill(p3, p4, transp = 60, color = leadLine1 > leadLine2 ? #53b987 : #eb4d5c)

//Upward Trend
UT=leadLine2 < leadLine1
DT=leadLine2 > leadLine1

///////////////////////////////////////INDICATORS

// KELTNER //
source       = close
useTrueRange = input(true)
length       = input(80, "KELTNER Period", step=1, minval=1)
mult         = input(3.0,"KELTNER Multiple", step=0.1)

// Calculate Keltner Channel
ma      = ema(source, length)
range   = useTrueRange ? tr : high - low
rangema = ema(range, length)
upper = ma + rangema * mult
lower = ma - rangema * mult

plot(ma, title="Middle", color=color.orange)
p1=plot(upper, title="Upper", color=color.orange)
p2=plot(lower, title="Lower", color=color.orange)
fill(p1,p2)


// DMI INDICATOR //

lensig = input(14, title="ADX Smoothing", minval=1, maxval=50)
len = input(14, minval=1, title="DI Length")
up = change(high)
down = -change(low)
plusDM = na(up) ? na : (up > down and up > 0 ? up : 0)
minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
trur = rma(tr, len)
plus = fixnan(100 * rma(plusDM, len) / trur)
minus = fixnan(100 * rma(minusDM, len) / trur)
sum = plus + minus
adx = 100 * rma(abs(plus - minus) / (sum == 0 ? 1 : sum), lensig)

trig_level=input(title="+DI Trigger Level", defval=32, minval=1,step=1)
//trig_level_adx=input(title="ADX Trigger Level", defval=30, minval=1,step=1)

//plot(adx, color=#FF006E, title="ADX")
//plot(plus, color=#0094FF, title="+DI")
//plot(minus, color=#FF6A00, title="-DI")
// plot(trig_level, color=color.white, title="Key Level")

///////////////////////////////////////////////////////////


////////////////////////////////////////////////////Component Code Start

testStartYear = input(2019, "Backtest Start Year")
testStartMonth = input(1, "Backtest Start Month")
testStartDay = input(1, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear,testStartMonth,testStartDay,0,0)

testStopYear = input(2030, "Backtest Stop Year")
testStopMonth = input(12, "Backtest Stop Month")
testStopDay = input(31, "Backtest Stop Day")
testPeriodStop = timestamp(testStopYear,testStopMonth,testStopDay,0,0)

testPeriod() =>
    time >= testPeriodStart and time <= testPeriodStop ? true : false
    
///// Component Code Stop //////////////////////////////////////////

//////////////// STRATEGY EXECUTION //////////////////////////

// STRATEGY CONDITION
// LONG

long = ((open > lower and open < upper) and close > upper) and plus > minus and plus > trig_level and volume[0] > volume[1]
entry_long = trend_cond ? long and UT : long
exit_long = (close < ma) //or low < SL_long

//LONG SET UP
// Take Profit / Stop Loss

entry_price_long=valuewhen(entry_long,close,0)
//SL_long = entry_price_long * (1 - long_sl_inp)

long_tp1_inp = input(8, title='Long Take Profit 1 Target %', step=0.1)/100
long_tp1_qty = input(20, title="Long Take Profit 1 Qty %", step=1)

long_tp2_inp = input(16, title='Long Take Profit 2 Target %', step=0.1)/100
long_tp2_qty = input(30, title="Long Take Profit 2 Qty %", step=1)

long_take_level_1 = strategy.position_avg_price * (1 + long_tp1_inp)
long_take_level_2 = strategy.position_avg_price * (1 + long_tp2_inp)

//long_sl_inp = input(4, title='Long Stop Loss %', step=0.1)/100
//long_stop_level = strategy.position_avg_price * (1 - long_sl_inp)


// STRATEGY EXECUTION
if testPeriod()

    // LONG
    
    strategy.entry(id="Long", long=true, when=entry_long, comment = "INSERT ENTRY LONG COMMAND")
    strategy.exit("TP1","Long", qty_percent=long_tp1_qty, limit=long_take_level_1) // PLACE TAKE PROFIT IN WBT BOT SETTINGS 
    strategy.exit("TP2","Long", qty_percent=long_tp2_qty, limit=long_take_level_2) // PLACE TAKE PROFIT IN WBT BOT SETTINGS
    strategy.close(id="Long", when=exit_long, comment= "INSERT EXIT LONG COMMAND")


//PLOT FIXED SLTP LINE
// LONG POSITION
plot(strategy.position_size > 0 ? long_take_level_1 : na, style=plot.style_linebr, color=color.green, linewidth=1, title="1st Long Take Profit")
plot(strategy.position_size > 0 ? long_take_level_2 : na, style=plot.style_linebr, color=color.green, linewidth=1, title="2nd Long Take Profit")
//plot(strategy.position_size > 0 ? long_stop_level : na, style=plot.style_linebr, color=color.red, linewidth=1, title="Long Stop Loss")
````
