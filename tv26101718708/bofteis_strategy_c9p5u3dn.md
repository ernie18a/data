# Boftei's Strategy

- url: https://www.tradingview.com/script/c9p5U3DN-boftei-s-strategy/
- type: strategy
- pine_id: PUB;17cff0222d704b9782baf81804fd39fa
- version: 3.0

## Description

I wrote this strategy about a year ago, but decided to publish it just now. I have not been able to implement this strategy in the market. If you can, then I will be happy for you.

This strategy is based on my "Botvenko Script". (It finds the difference between the logarithms of closing prices from different days.) (Check this script in my profile)

Then the strategy makes trades when the "Botvenko Script" indicator crosses the levels set earlier and manually selected for each currency pair/shares: long/short opening/closing levels, long/short re-entry levels. (They are drawn with horizontal dotted lines.) The names of these lines are: buy/sell level, long/short retry - too low/high, long close up/down, dead - close the short. Manual selection of each of the parameters provides a qualitative entry of the strategy into the deal. However, without restraining mechanisms, the strategy enters into rather controversial deals. In order to avoid going long/short during bear/bull markets, which is unacceptable, I added a fan of EMA lines.

The fan consists of several EMA lines, which are set according to Fibonacci numbers (21, 55, 89, 144). If the lines in the fan are arranged in ascending order (ema_21>ema_55 and ema_55>ema_89 and ema_89>ema_144), then this indicates a bull market, during which I banned shorting. And vice versa: during the bear market (ema_21<ema_55 and ema_55<ema_89 and ema_89<ema_144) I banned long trading. If these two inequalities are not met, then this indicates that the market is flat, and during it it is allowed to enter any transactions, because a flat is a good moment to catch massive movements in the future by entering a transaction. (This is all visualized using semi-transparent thick lines of green, yellow and red colors.)

By default, all parameters are adjusted for the btc/usd (bitstamp) pair. Best of all, the strategy shows itself if 1 candle = 1 day.

At the time of writing, on the pair btcusd (bitstamp) (1d) with pyramiding = 1, the strategy shows a profit of 64728896%. If pyramiding is increased by 1, then the profit will be greater, but I still prefer pyramiding = 1.

There is a possibility that my strategy is doing complete nonsense. I don't vouch for her.

If you select parameters for other pairs of currencies/stocks, then you should not change anything in the fan of lines.

That's all, probably.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © boftei

//@version=5

strategy("Boftei's Strategy", overlay=false, pyramiding=1, default_qty_type= strategy.percent_of_equity, default_qty_value = 100, calc_on_order_fills=false, margin_long = 100, margin_short = 100, slippage=0, commission_type=strategy.commission.percent, commission_value = 0, initial_capital = 40, precision = 6)
strat_dir_input = input.string("all", "strategy direction", options=["long", "short", "all"])
strat_dir_value = strat_dir_input == "long" ? strategy.direction.long : strat_dir_input == "short" ? strategy.direction.short : strategy.direction.all
strategy.risk.allow_entry_in(strat_dir_value)
//////////////////////////////////////////////////////////////////////
//DATA
testStartYear = input(2005, "Backtest Start Year")
testStartMonth = input(7, "Backtest Start Month")
testStartDay = input(16, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear,testStartMonth,testStartDay,0,0)
//Stop date if you want to use a specific range of dates
testStopYear = input(2030, "Backtest Stop Year")
testStopMonth = input(12, "Backtest Stop Month")
testStopDay = input(30, "Backtest Stop Day")
testPeriodStop = timestamp(testStopYear,testStopMonth,testStopDay,0,0)


testPeriod() =>
    time >= testPeriodStart and time <= testPeriodStop ? true : false
//////////////////////////////////////////////////////////////////////
sell = input.float(0.0065, "sell level")
buy = input.float(0, "buy level")
long1 = input.float(-0.493, "long retry - too low")
long2 = input.float(2.2, "long close up")
long3 = input.float(-1.5, "long close down")
short1 = input.float(0.8, "short retry - too high")
short2 = input.float(-5, "dead - close the short")
///< botvenko script
nn = input(60, "Histogram Period")
float x = 0
float z = 0
float k = 0



y = math.log(close[0]) - math.log(close[nn])
if y>0
    x := y
else
    k := y
//---------------------------------------------
        
plot(y > 0 ? x: 0, color = color.green, linewidth = 4)
plot(y <= 0 ? k: 0, color = color.maroon, linewidth = 4)
plot(y, color = color.yellow, linewidth = 1)

co = ta.crossover(y, buy)
cu = ta.crossunder(y, sell)
retry_long = ta.crossunder(y, long1)
deadline_long_up = ta.crossover(y, long2)
deadline_long_down = ta.crossunder(y, long3)
retry_short = ta.crossover(y, short1)
deadline_short = ta.crossunder(y, short2)


hline(buy, title='buy', color=color.green, linestyle=hline.style_dotted, linewidth=2)
hline(0, title='zero', color=color.white, linestyle=hline.style_dotted, linewidth=1)
hline(sell, title='sell', color=color.red, linestyle=hline.style_dotted, linewidth=2)
hline(long1, title='long retry', color=color.blue, linestyle=hline.style_dotted, linewidth=2)
hline(long2, title='overbought', color=color.teal, linestyle=hline.style_dotted, linewidth=2)
hline(long3, title='oversold', color=color.maroon, linestyle=hline.style_dotted, linewidth=2)
hline(short1, title='short retry', color=color.purple, linestyle=hline.style_dotted, linewidth=2)
hline(short2, title='too low to short - an asset may die', color=color.navy, linestyle=hline.style_dotted, linewidth=2)


////////////////////////////////////////////////////////////EMAprotectionBLOCK
ema_21 = ta.ema(close, 21)
ema_55 = ta.ema(close, 55)
ema_89 = ta.ema(close, 89)
ema_144 = ta.ema(close, 144)
ema_233 = ta.ema(close, 233)
//ema_377 = ta.ema(close, 377)

long_st = ema_21>ema_55 and ema_55>ema_89 and ema_89>ema_144 and ema_144>ema_233// and ema_233>ema_377
short_st = ema_21<ema_55 and ema_55<ema_89 and ema_89<ema_144 and ema_144<ema_233// and ema_233<ema_377 

g_v = long_st == true?3:0
r_v = short_st == true?-2:0
y_v = long_st != true and short_st != true?2:0

plot(math.log(ema_21), color = color.new(#ffaf5e, 50))
plot(math.log(ema_55), color = color.new(#b9ff5e, 50))
plot(math.log(ema_89), color = color.new(#5eff81, 50))
plot(math.log(ema_144), color = color.new(#5effe4, 50))
plot(math.log(ema_233), color = color.new(#5e9fff, 50))
//plot(math.log(ema_377), color = color.new(#af5eff, 50))

plot(long_st == true?3:0, color = color.new(color.green, 65), linewidth = 5)
plot(short_st == true?-2:0, color = color.new(color.red, 65), linewidth = 5)
plot(long_st != true and short_st != true?2:0, color = color.new(color.yellow, 65), linewidth = 5)
////////////////////////////////////////////////////////////EMAprotectionBLOCK




if (co and testPeriod() and (g_v == 3 or y_v == 2))
    strategy.close("OH BRO", comment = "EXIT-SHORT")
    strategy.close("OH DUDE", comment = "EXIT-SHORT")
	strategy.entry("OH DAMN", strategy.long, comment="ENTER-LONG 'co'")
if (retry_long and testPeriod() and (g_v == 3 or y_v == 2))
    strategy.close("OH DAMN", comment = "EXIT-LONG")
    strategy.entry("OH BRUH", strategy.long, comment="ENTER-LONG 'retry_long'")
	
if (cu and testPeriod() and (r_v == -2 or y_v == 2))
    strategy.close("OH DAMN", comment = "EXIT-LONG")
    strategy.close("OH BRUH", comment = "EXIT-LONG")
	strategy.entry("OH BRO", strategy.short, comment="ENTER-SHORT 'cu'")
if (retry_short and testPeriod() and (r_v == -2 or y_v == 2))
    strategy.close("OH BRO", comment = "EXIT-SHORT")
    strategy.entry("OH DUDE", strategy.short, comment="ENTER-SHORT 'retry_short'")
	
    
if (deadline_long_up and testPeriod() or r_v == -2 and testPeriod())
    strategy.close("OH DAMN", comment = "EXIT-LONG 'deadline_long_up'")
    strategy.close("OH BRUH", comment = "EXIT-LONG 'deadline_long_up'")
if (deadline_long_down and testPeriod())
    strategy.close("OH DAMN", comment = "EXIT-LONG 'deadline_long_down'")
    strategy.close("OH BRUH", comment = "EXIT-LONG 'deadline_long_down'")
if (deadline_short and testPeriod() or g_v == 3 and testPeriod())
    strategy.close("OH BRO", comment = "EXIT-SHORT 'deadline_short'")
    strategy.close("OH DUDE", comment = "EXIT-SHORT 'deadline_short'")
    // (you can use strategy.close_all(comment = "close all entries") here)
````
