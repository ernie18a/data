# HL MovingAvg2Line Cross Dhananjay

- url: https://www.tradingview.com/script/nhG8OBiD-HL-MovingAvg2Line-Cross-Dhananjay/
- type: strategy
- pine_id: PUB;NfM9pV8bAUClqr6gePzGqQfBk3SKQElI
- version: 3.0

## Description

[image]https://www.tradingview.com/x/mnmt1YrN/[/image]

Sharing the simple trend following trading strategy, traders can add their own rules in this, to minimise the losses and maximise the profits. Like below.

1. Go long only if price is above 189 days EMA/SAM
2. Exit position when high or low of previous candle is breached in the opposite direction of the trend. 
3. Go long only if price is in up trend on higher time frame charts and go short when price is down trend of higher time frame charts.  

Stop loss, target and other things can also be decided by the trader. 

Idea is to capture the short term trend to trade in FnO or 2/3 days position in underlying instrument. 

Traders can optimise the length of the Moving average so that your traded is set for maximum profit giving settings for this strategy. Different instruments responds to different moving averages because of different volatility. 

Idea is to go long when price closes above 9 days EMA of Highs and exit and go short whenever price closes below 9 days EMA of lows, exit short when first condition meets after short trade. 

[b]I ma not that good with scripts, have many such ideas, interested script writers can get in touch with me so that we can create trading systems which have grater success rate[/b].

## Source Code

````pine
//@version=2
strategy("HL MovingAvg2Line Cross Dhananjay V1.0", overlay=true)

length0 = input(9)
length1 = input(9)

emahigh = ema(high,length0)
emalow = ema(low, length1)
emalow50 = ema(low,50)

if  (close > emahigh)
    strategy.entry("long", strategy.long, comment="GOLong")
    strategy.exit("long","strategy.long",comment="ExitLong",when=close<emalow)

if (close < emalow)
    strategy.entry("short", strategy.short, comment="GoShort")
    strategy.exit("short","strategy.short",comment="ExitLong",when=close>emahigh)
    

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````
