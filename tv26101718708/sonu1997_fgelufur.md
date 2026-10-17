# sonu1997

- url: https://www.tradingview.com/script/FGELufUr-sonu1997/
- type: strategy
- pine_id: PUB;9d07cea05d2c43de87e3d71c88aa5905
- version: 1.0

## Description

full banchod
Information technology (IT) companies will kick off the first-quarter earnings season in July amid expectations they will post strong revenue growth, offset by pressure on profit margins exerted by higher. wage costs. IT companies including Infosys and HCL Technologies are unlikely to change their full-year guidance despite concerns of a recession in the US and Europe, analysts said.

Major IT companies typically announce their earnings for the three months ended June in the first fortnight of July, with Infosys and Tata Consultancy Services leading the pack.

The earnings season follows a tumultuous quarter marked by worries over the Russia-Ukraine war, accelerating inflation and tightening of interest rates by global central banks to cool it, supply-chain disruptions, and tumbling financial markets.

IT stocks have fallen the most among sectors, with the Nifty IT index correcting 29 percent from its high in January. Higher valuations and rising fears of an economic slowdown, even recession, in the US and Europe, the biggest markets for IT companies, weighed on the sector

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sonu1997

//@version=4
//@version=5
strategy('moving average strategy', overlay=true)

ema50 =ema(close, 50)
ema200 =ema(close, 200)



long = ema50 > ema200
short = ema50 < ema200

strategy.entry('long', strategy.long, 100, 0, when=long)
strategy.entry('short', strategy.short, 100, 0, when=short)

strategy.close('long', when=short)
strategy.close('short', when=long)
````
