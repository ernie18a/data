# M8 BUY @ END OF DAY

- url: https://www.tradingview.com/script/X1Ee5NVw-M8-BUY-END-OF-DAY/
- type: strategy
- pine_id: PUB;8373504d450c4e678fed1791be61f7ca
- version: 1.0

## Description

I've read a couple of times at a couple of different places that most of the move in the market happens after hours, meaning during non-standard trading hours. 

After-market and pre-market hours and have seen data presented showing that systems which bought just before end normal market hours and sold the next morning had really amazing resutls. 

But when testing those I found the results to be quite poor compared to the pretty graphs I saw, and after much tweaking and trying different ideas I gave up on the idea until I recently decided to try a new position management system.

The System

[list]
[*] Buys at the end of the trading day before the close
[*] Sells the next morning at the open IF THE CLOSE OF THE CURRENT BAR IS HIGHER THAN THE ENTRY PRICE
[*] When the current price is not higher, [b]the system will keep the position open until it EITHER gets stops out or closes on profit <<< this is WHY it has the high win %[/b]
[/list]



[list]
[*] The system [b]has a high win ratio because it will keep that one position open until it either reaches profit or stops out[/b]
[*] This "system" of waiting, and keeping the trade open, actually turned out to be a fantastic way to kind of put the complete trading strategy in a kind of limbo mode. It either waits for market failure or for a profit.
[*] I don't really care about win % at all, almost always high win % ratio systems are just nonsense. What I look for is a PF -- profit factor of 1.5 or above, and a relatively smooth equity curve. -- This has both.

[*] The Stop Loss setting is set @ .95, meaning a 5% stop loss. The Red Line on the chart is the stop loss line.
[*] There is no set profit target -- it simply takes what the market gives. 
[/list]


[b]Non-Repainting System[/b]
This does use a 200D Simple Moving Average as a filter. Like a Green Light / Red Light traffic light, the system will only trade long when the price is above its 200 Moving average.
Here is the code: "F1              = close > sma(security(syminfo.tickerid, "D", close[2]), MarketFilterLen) // HIGH OF OLD DATA -- SO NO REPAINTING"

I use "close[2]", so that's data from two days ago, it's fixed, confirmed, non-repainting data from the higher timeframe. 

-- I would only suggest using this on direction tickers like SPY, QQQ, SSO, TQQQ, market sectors with additional filters in place.

## Source Code

````pine
//  @version=4
//  © HermanBrummer
//  This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
strategy("M8 BUY @ END OF DAY", "", 1)

///         BUYS AT THE END OF THE DAY
///         SELLS THE NEXT MORNING IF PRICE IS HIGHER THEN THE ENTRY PRICE
///         IF PRICE IS NOT HIGHER THEN IT WILL KEEP THE POSITION AND WAIT FOR EITHER A STOP OUT OR FOR PRICE TO BE HIGHER THAN THE ENTRY
///         USES A 5% STOP LOSS ON THE REDLINE  -- SETTABLE IN SETTINGS
///         USES A 200 DAY MARKET FILTER        -- SETTABLE IN SETTINGS -- IMPORTS DATA FROM HIGHER TIMEFRAME, BUT USES CLOSE[2] << SO THIS IS FIXED, NON-REPAITING DATA


MarketFilterLen = input(200)
StopLossPerc    = input(.95, step=0.01)

buyTime         = time(timeframe.period, "1429-1500")
sellTime        = time(timeframe.period, "0925-0935")

F1              = close > sma(security(syminfo.tickerid, "D", close[2]), MarketFilterLen) // HIGH OF OLD DATA -- SO NO REPAINTING

enter           = buyTime and F1
exit            = sellTime


StopLossLine    = strategy.position_avg_price * StopLossPerc

plot(StopLossLine, "StopLossLine", color.new(#FF0000, 50))

strategy.entry("L", true, when=enter)
strategy.exit("StopLoss", stop=StopLossLine )
if  close > strategy.position_avg_price
    strategy.close("L", when=exit)

barcolor(strategy.opentrades != 0 ? color.new(color.yellow, 0) : na )
````
