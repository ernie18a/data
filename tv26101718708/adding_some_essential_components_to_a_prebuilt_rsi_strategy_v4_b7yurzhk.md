# Adding some essential components to a prebuilt RSI strategy v4

- url: https://www.tradingview.com/script/B7YUrzhk-Adding-some-essential-components-to-a-prebuilt-RSI-strategy-v4/
- type: strategy
- pine_id: PUB;8yO4NyWy6pPF6D6Oggjiwt25hMy8eCT9
- version: 1.0

## Description

Taken from https://www.tradingview.com/script/GbZGYi6l-Adding-some-essential-components-to-a-prebuilt-RSI-strategy/ and just updated to compile in version 4. Added notes for users on where to swap out RSI component with their setup components to signal a long or short position.

## Source Code

````pine
// LOVE JOY PEACE PATIENCE KINDNESS GOODNESS FAITHFULNESS GENTLENESS SELF-CONTROL 
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Author: © JoshuaMcGowan
// Taken from https://www.tradingview.com/script/GbZGYi6l-Adding-some-essential-components-to-a-prebuilt-RSI-strategy/
// Just updated to compile in version 4. 

//@version=4

strategy("Adding some essential components to a prebuilt RSI strategy", overlay=true)

/////////////// Component Code Start ///////////////

testStartYear = input(2011, "Backtest Start Year") 
testStartMonth = input(8, "Backtest Start Month")
testStartDay = input(1, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear,testStartMonth,testStartDay,0,0)

testStopYear = input(2100, "Backtest Stop Year")
testStopMonth = input(9, "Backtest Stop Month")
testStopDay = input(29, "Backtest Stop Day")
// testStopDay = testStartDay + 1
testPeriodStop = timestamp(testStopYear,testStopMonth,testStopDay,0,0)

// A switch to control background coloring of the test period
testPeriodBackground = input(title="Color Background?", type=input.bool, defval=true)
testPeriodBackgroundColor = testPeriodBackground and (time >= testPeriodStart) and (time <= testPeriodStop) ? #00FF00 : na
bgcolor(testPeriodBackgroundColor, transp=97)

testPeriod() =>
    time >= testPeriodStart and time <= testPeriodStop ? true : false
    
/////////////// Component Code Stop ///////////////

// Replace RSI Component, Long/Short, and Long Signal/Short Signal conditions with your trade setup components.
///////////// RSI component /////////////

length = input( 14 )
overSold = input( 30 )
overBought = input( 70 )
price = close

vrsi = rsi(price, length)
notna = not na(vrsi)

/////////////// STRATEGY ///////////////

ts = input(99999, "Trailing Stop") / 100
tp = input(99999, "Take Profit") / 100
sl = input(99999, "Stop Loss") / 100

// Update this with your setup. 
long = notna and crossover(vrsi, overSold)
short = notna and crossunder(vrsi, overBought)

last_long = 0
last_short = 0
last_long := long ? time : nz(last_long[1])
last_short := short ? time : nz(last_short[1])

// Update this to reflect your setup. 
long_signal = crossover(last_long, last_short)
short_signal = crossover(last_short, last_long)

float last_open_long_signal = 0
float last_open_short_signal = 0
last_open_long_signal := long_signal ? open : nz(last_open_long_signal[1])
last_open_short_signal := short_signal ? open : nz(last_open_short_signal[1])

last_long_signal = 0
last_short_signal = 0
last_long_signal := long_signal ? time : nz(last_long_signal[1])
last_short_signal := short_signal ? time : nz(last_short_signal[1])

in_long_signal = last_long_signal > last_short_signal
in_short_signal = last_short_signal > last_long_signal

float last_high = 0
float last_low = 0
last_high := not in_long_signal ? na : in_long_signal and (na(last_high[1]) or high > nz(last_high[1])) ? high : nz(last_high[1])
last_low := not in_short_signal ? na : in_short_signal and (na(last_low[1]) or low < nz(last_low[1])) ? low : nz(last_low[1])

long_ts = not na(last_high) and high <= (last_high - ts) //and high >= last_open_long_signal
short_ts = not na(last_low) and low >= (last_low + ts) //and low <= last_open_short_signal

long_tp = high >= (last_open_long_signal + tp)
short_tp = low <= (last_open_short_signal - tp)

long_sl = low <= (last_open_long_signal - sl)
short_sl = high >= (last_open_short_signal + sl)

leverage = input(200, "Leverage")
long_call = last_open_long_signal - (0.8 + 0.2 * (1/leverage)) / leverage * last_open_long_signal
short_call = last_open_short_signal + (0.78 + 0.2 * (1/leverage)) / leverage * last_open_short_signal
long_call_signal = low <= long_call
short_call_signal = high >= short_call

if testPeriod()
    strategy.entry("Long", strategy.long, when=long_signal)
    strategy.entry("Short", strategy.short, when=short_signal)

    // plot(long_call, color=color.red)
    // plot(short_call, color=color.green)
    strategy.close("Long", when=long_call_signal)
    strategy.close("Short", when=short_call_signal)
    strategy.close("Long", when=long_tp)
    strategy.close("Short", when=short_tp)
    strategy.close("Long", when=long_sl)
    strategy.close("Short", when=short_sl)
    strategy.close("Long", when=long_ts)
    strategy.close("Short", when=short_ts)
````
