# BitMEX pump catcher - MACD

- url: https://www.tradingview.com/script/AMxhpBej-BitMEX-pump-catcher-MACD/
- type: strategy
- pine_id: PUB;ZT9foEFnkWxB4h6rAE8stTI3GJcEXyfn
- version: 2.0

## Description

This is a modified version of the [url=https://www.tradingview.com/script/EzWSn57d-BitMEX-pump-catcher/#tc2901456]BitMEX pump catcher[/url] by [url=https://www.tradingview.com/u/Jomy/]Jomy[/url]. 

I have tweaked the algorithm to use the difference in MACD to get the correct direction of entries rather than using direction of candles which are not always indicative of trend direction. These changes increase net profit, profitable trades, while reducing drawdown. 

Below is a copy and paste of Jomy's explanation of the algorithm.

What is going on here? This strategy is pretty simple. We start by measuring a very long chunk of volume history on BitMEX:XBTUSD 1 hour chart to find out if the current volume is high or low. At 1.0 the indicator is showing we are at 100% of normal historical volume . The blue line is a measure of recent volume! This indicator gets interested when the volume drops below 90% of the regular volume (0.9), and then comes back up over 90%. There's usually a pump of increased price activity during this time. When the 0.9 line is crossed by the blue line, the indicator surveys the last 2 bars of price action to figure out which way we're going, long or short. Green is long. Red is short. To exit the trade we use a 7 period fast ema of the volume crossing under an 11 ema slower period which shows declining interest in the market signifying an end to the pump or dump. The profit factor is quite high with 5x leverage, but historically we see 50% drawdown -- very risky. 1x leverage looks nice and tight with very low drawdown. Play with the inputs to see what matches your own risk profile. I would not recommend taking this into much lower timeframes as trading fees are not included in the profit calculations. Please don't get burned trading on stupid high leverage. This indicator is probably not going to work well on alts, as Bitcoin FOMO build up and behavior is different. This whole indicator is tuned to Bitcoin , and attempts to trade only the meatiest part of the market moves.

Jomy should get full credit to this indicator

## Source Code

````pine
//@version=4
strategy("Hancock - Pump Catcher [BitMEX]", precision = 8, initial_capital = 1000)

// Inputs
macd_fast_length   = input(12, title = "MACD - Fast Length", type = input.integer, minval = 1)
macd_slow_length   = input(26, title = "MACD - Slow Length", type = input.integer, minval = 1)

vol_threshold    = input(0.9, title = "Volume - Threshold", step = 0.05)
vol_fast_length  = input(7, title = "Volume - Fast Length")
vol_slow_length  = input(11, title = "Volume - Slow Length")

trade_leverage = input(5, title = "Trade - Leverage", step = 0.25)
trade_stop     = input(10, title = "Trade - Stop Loss Percent", type = input.float, step = 0.1, minval = 0.1)
trade_risk     = input(100, title = "Trade - Risk Percent", type = input.float, step = 0.1, minval = 0.1, maxval = 100)

// Functions
get_round(value, precision) => round(value * (pow(10, precision))) / pow(10, precision)

// Strategy
b = sum(volume,24)
c = 0.0
for i = 24 to 1200 by +24
    c := b[i] + c

d = c / 50
vol = b / d

macd = (ema(close, macd_fast_length) - ema(close, macd_slow_length))

trend = macd - macd[1]

fast_signal = ema(vol, vol_fast_length)
slow_signal = ema(vol, vol_slow_length)

// Conditions
enter_condition = crossover(vol, vol_threshold) and rising(slow_signal, 1)

enter_long_condition  = enter_condition and trend > 0
enter_short_condition = enter_condition and trend < 0

exit_condition  = slow_signal > fast_signal

position_signal = 0
position_signal := 
     enter_long_condition ? 1 :
     enter_short_condition ? -1 :
     exit_condition ? 0 :
     position_signal[1]

// Positions
if (strategy.opentrades == 0)
    contracts = get_round((strategy.equity * trade_leverage / close) * (trade_risk / 100), 4)
    
    strategy.entry(
         "LONG", 
         strategy.long, 
         qty = contracts,
         when = enter_long_condition)
        
    strategy.entry(
         "SHORT", 
         strategy.short, 
         qty = contracts,
         when = enter_short_condition)
         

stop_difference = (strategy.position_avg_price / trade_leverage) * (trade_stop / 100)

in_long  = strategy.position_size > 0
in_short  = strategy.position_size < 0
 
long_stop  = in_long ? strategy.position_avg_price - stop_difference : na
short_stop = in_short ? strategy.position_avg_price + stop_difference : na

strategy.exit("S/L", "LONG",
     stop = long_stop, 
     qty = abs(get_round(strategy.position_size, 4)))
         
strategy.exit("S/L", "SHORT", 
     stop = short_stop, 
     qty = abs(get_round(strategy.position_size, 4)))

strategy.close_all(when = exit_condition or abs(change(position_signal)) > 0)

// Plots
bgcolor(position_signal > 0 ? color.lime : position_signal < 0 ? color.red : na, transp = 70)

hline(vol_threshold)

plot(vol, color = color.blue)
plot(slow_signal, color = color.yellow)
plot(fast_signal, color = color.red)
````
