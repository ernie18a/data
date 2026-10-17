# REVERSALS

- url: https://www.tradingview.com/script/Fzw2bz39-REVERSALS/
- type: strategy
- pine_id: PUB;645657ed13ee4923ac2d09cba257af22
- version: 1.0

## Description

[list]
[*] The systems basically play reversals, it enters when the close is lower than its low of 5 bars ago to enter
[*] It exits when the price is higher than the high of 5 days ago
[/list]

[list]
[*] Uses a 200 MA as a market filter, does not trade when the price is below its 200 Moving average
[*] Uses a 5% stop, as per the red Stop Loss Line -- can be adjusted
[/list]

The amount of bars it uses to look for reversals is set to 5 by default, but can be adjusted in settings.

Best to use on directional instruments where you know that the long term direction is up, for example:

TQQQ, SSO, SPX, SPY, or sector tickers -- but it would be best to include some more advanced filtering for sectors

## Source Code

````pine
//  @version=4
//  © HermanBrummer
//  This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//  BUYS    WHEN THE CLOSE IS SMALLER THAN THE LOW OF 5 DAYS AGO
//  SELLS   WHEN THE CLOSE IS HIGHER THEN THE HIGH OF 5 DAYS AGO
//  USES A 200 MOVING AVERGE AS A FILTER, AND DOESN'T TAKE TRADES IF THE MARKET IS BELOW IT'S 200 MA
//  USES A 5% STOP LOSS FROM ENTRIES

strategy("REVERSALS", overlay=true)

StopLoss    = input(.95, step=0.01)
HowManyBars = input( 5 )

///     EXITS
if  close > sma(high,HowManyBars)[1]
    strategy.close_all()


///     ENTRIES
MarketFilter    = sma(close, 200)
F1              = close < sma(low,HowManyBars)[1]
F2              = close > MarketFilter
plot(MarketFilter, "MarketFilter", color.yellow)

strategy.entry("Long", true, 1, when=F1 and F2)


///     STOP LOSS
StopLossLine    = strategy.position_avg_price * StopLoss
plot(StopLossLine, "StopLossLine", #FF0000)
strategy.exit("Exit", stop=StopLossLine)
````
