# DUAL RSI

- url: https://www.tradingview.com/script/ZiZBBmq8-DUAL-RSI/
- type: strategy
- pine_id: PUB;0e048af69fc04a81bb628a3f8e1a8103
- version: 1.0

## Description

[list]
[*] This system uses two RSI's with different settings
[*] Fast RSI Lenght is 16, buys when RSI price is oversold @ 91 or lower, and sells when RSI price is overbought at 70
[*] Slow RSI Lenght is 31, buys when RSI price is oversold @ 91 or lower, and sells when RSI price is overbought at 68
[/list]

[list]
[*] Pyramiding is set to 2 since each system should be able to trade in the same direction on the same day
[*] The Red StopLine is a stop loss of 10% based on the combined strategic position average entry price.
[*] I've used a 2D chart because I prefer longer-term charts for higher quality signals
[*] The way I trade all the systems is to set up alerts to let me know when to look at what setups
[*] The system also has a market filter and does not trade when the close is lower than its 200 days moving average
[/list]

## Source Code

````pine
//  @version=4
//  © HermanBrummer
//  This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

strategy("DUAL RSI", "RSI", 1, pyramiding=2)
///     USES TWO RSI'S BOTH OF THEM CAN TRADE IN THE SAME DIRECTION AT THE SAME TIME -- ONE SLOW RSI, AND ONE FAST RSI
///     BOTH RSI'S HAVE DIFFERENT LENGHTS ONE IS FAST AND HAS A SETTTING OF 16 ONE IS SLOW AND HAS A SETTING OF 31
///     BOTH RSI'S HAVE DIFERENT EXIT PARAMETERS
///     PYRAMIDING ALLOWS THE SYSTEM TO BUY ONE DO ONE SLOW RSI AND ONE FAST RSI BUY ON THE SAME DAY
///     FASTRSI     EXITS AT 70 RSI LEVEL
///     SLOW RSI    EXITS AT 68 RSI LEVEL


FastRSILen      = input( 16 )
SlowRSILen      = input( 31 )

overSold        = input( 91 )

FastRsi         = rsi(ohlc4, FastRSILen)
SlowRsi         = rsi(ohlc4, SlowRSILen)

aboveMaFilter   = close > sma(close, 200)
StopLossLine    = strategy.position_avg_price * .90

plot(StopLossLine, "StopLossLine", #ff0000)
// plot(FastRsi, "FastRsi", color.yellow, 2)
// plot(SlowRsi, "SlowRsi", color.purple, 2)

FastBuy         = FastRsi < overSold and aboveMaFilter //and strategy.position_size != 1
SlowBuy         = SlowRsi < overSold and aboveMaFilter //and strategy.position_size != 1


//     FAST_BUY
strategy.entry("Fast Enter", true, when=FastBuy)
    
if  FastRsi > 70    /// SELLS IF RSI == 75
    strategy.close("Fast Enter", comment="Fast Exit")
    
strategy.exit("Stop Loss", "Fast Enter", stop=StopLossLine)       



// // ///     SLOW_BUY
strategy.entry("Slow Enter", true, when=SlowBuy)
    
strategy.exit("Stop Loss", "Slow Enter", stop=StopLossLine)       

if  SlowRsi > 68    /// SELLS IF RSI == 68
    strategy.close("Slow Enter", comment="Slow Exit")
````
