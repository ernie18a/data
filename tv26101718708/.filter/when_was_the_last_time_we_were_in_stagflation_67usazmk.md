# When was the last time we were in stagflation?

- url: https://www.tradingview.com/script/67USaZMK-When-was-the-last-time-we-were-in-stagflation/
- type: strategy
- pine_id: PUB;58bbdde6ad4942418908436cdc0e17d7
- version: 1.0

## Description

Here I coded a strategy that indicates when we should enter a long position in the US dollar. The three indicators I used were the Inflation Rate, 10Y interest rate, and GDP growth rate. Right now in our economy, It seems as though we are in stagflation due to high inflation and declining GDP growth. Thoughts on how our government should handle the oversupply of money in the economy right now are another conversation. The reason I built this indicator is to see when the last time our country was in this type of market environment was and to see how far the dollar rose from that point on. It is necessary to say that the US dollar generally does not show these steep increases in value unless there is a hard cut in the Money supply. However, what we see is that the last time we were in stagflation was around the early 1980s when the dollar value rose to around 107( the levels we're at right now) and did not stop until It hit its peak at 150!!!! This isn't all that exciting really because if the FED follows a similar path as It did back in the '80s then we are going to see a whole lot more money supply being cut, an increase in interest rates, and a declining GDP Growth rate.

ATTENTION: This indicator does not tell you to buy any financial instrument that follows the DXY(US Dollar index), with that being said please feel free to comment and tell me your opinion. whether it's how bad my coding is(I'm a beginner sorry!!) or whether my ideas on our market environment right now are bogus or just do not make sense.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © brett0923
//@version=4
// #First I name the strategy
strategy("Stagflation backtesting ")
// # Collect and store the data for each economic indicator use
inflation_rate = security('USIRYY',"M", close)
interest_rate = security('US10Y', 'M', close  )
GDP_growth_rate = security('USGDPQQ', 'M', close )
//Command the strategy to enter a long position in the dollar when our indicators show or already showing signs of Stagflation
strategy.entry("enter long",true , 1000.0, when = inflation_rate > 8.0 and interest_rate >= 3.0 and GDP_growth_rate <= 1)
````
