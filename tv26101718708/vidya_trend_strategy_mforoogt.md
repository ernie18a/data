# VIDYA Trend Strategy

- url: https://www.tradingview.com/script/mfOrooGt-VIDYA-Trend-Strategy/
- type: strategy
- pine_id: PUB;18cbb2373bcc45ee8c1a4b1bb488b019
- version: 1.0

## Description

One of the most common messages I get is people reaching out asking for quantitative strategies that trade cryptocurrency. This has compelled me to write this script and article, to help provide a quantitative/technical perspective on why I believe most strategies people write for crypto fail catastrophically, and how one might build measures within their strategies that help reduce the risk of that happening. For those that don't trade crypto, know that these approaches are applicable to any market.

I will start off by qualifying up that I mainly trade stocks and ETFs, and I believe that if you trade crypto, you should only be playing with money you are okay with losing. Most published crypto strategies I have seen "work" when the market is going up, and fail catastrophically when it is not. There are far more people trying to sell you a strategy than there are people providing 5-10+ year backtest results on their strategies, with slippage and commissions included, showing how they generated alpha and beat buy/hold. I understand that this community has some really talented people that can create some really awesome things, but I am saying that the vast majority of what you find on the internet will not be strategies that create alpha over the long term. 

[b]So, why do so many of these strategies fail?[/b]

[list]
[*]There is an assumption many people make that cryptocurrency will act just like stocks and ETFs, and it does not. ETF returns have more of a Gaussian probability distribution. Because of this, ETFs have a short term mean reverting behavior that can be capitalized on consistently. Many technical indicators are built to take advantage of this on the equities market. Many people apply them to crypto. Many of those people are drawn down 60-70% right now while there are mean reversion strategies up YTD on equities, even though the equities market is down. Crypto has many more "tail events" that occur 3-4+ standard deviations from the mean. 
[*]There is a correlation in many equities and ETF markets for how long an asset continues to do well when it is currently doing well. This is known as momentum, and that correlation and time-horizon is different for different assets. Many technical indicators are built based on this behavior, and then people apply them to cryptocurrency with little risk management assuming they behave the same and and on the same time horizon, without pulling in the statistics to verify if that is actually the case. They do not. 
[*]People do not take into account the brokerage commissions and slippage. Brokerage commissions are particularly high with cryptocurrency. The irony here isn't lost to me. When you factor in trading costs, it blows up most short-term trading strategies that might otherwise look profitable. 
[*]There is an assumption that it will "always come back" and that you "HODL" through the crash and "buy more." This is why Three Arrows Capital, a $10 billion dollar crypto hedge fund is now in bankruptcy, and no one can find the owners. This is also why many that trade crypto are drawn down 60-70% right now. There are bad risk practices in place, like thinking the martingale gambling strategy is the same as dollar cost averaging while also using those terms interchangeably. They are not the same. The 1st will blow up your trade account, and the 2nd will reduce timing risk. Many people are systematically blowing up their trade accounts/strategies by using martingale and calling it dollar cost averaging. The more risk you are exposing yourself too, the more important your risk management strategy is. 
[*]There is an odd assumption some have that you can buy anything and win with technical/quantitative analysis. Technical analysis does not tell you what you should buy, it just tells you when. If you are running a strategy that is going long on an asset that lost 80% of its value in the last year, then your strategy is probably down. That same strategy might be up on a different asset. One might consider a different methodology on choosing assets to trade. 
[*]Lastly, most strategies are over-fit, or curve-fit. The more complicated and more parameters/settings you have in your model, the more likely it is just fit to historical data and will not perform similar in live trading. This is one of the reasons why I like simple models with few parameters. They are less likely to be over-fit to historical data. If the strategy only works with 1 set of parameters, and there isn't a range of parameters around it that create alpha, then your strategy is over-fit and is probably not suitable for live trading.
[/list]

[b]So, what can I do about all of this!?[/b]

[list]
[*]I created the VIDYA Trend Strategy to provide an example of how one might create a basic model with a basic risk management strategy that might generate long term alpha on a volatile asset, like cryptocurrency. This is  one (of many) risk management strategies that can reduce the volatility of your returns when trading any asset. I chose the Variable Index Dynamic Average (VIDYA) for this example because it's calculation filters out some market noise by taking into account the volatility of the underlying asset. I chose a trend following strategy because regressions are capturing behaviors that are not just specific to the equities market.
[*]The more volatile an asset, the more you have to back-off the short term price movement to effectively trend-follow it. Otherwise, you are constantly buying into short term trends that don't represent the trend of the asset, then they reverse and loose money. This is why I am applying a trend following strategy to a 4 hour chart and not a 4 minute chart. It is also important to note that following these long term trends on a volatile asset exposes you to additional risk. So, how might one mitigate some of that risk?
[*]One of the ways of reducing timing risk is scaling into a trade. This is different from "doubling down" or "trippling down." It is really a basic application of dollar cost averaging to reduce timing risk, although DCA would typically happen over a longer time period. If it is really a trend you are following, it will probably still be a trend tomorrow. Trend following strategies have lower win rates because the beginning of a trend often reverses. The more volatile the asset, the more likely that is to happen. However, we can reduce risk of buying into a reversal by slowly scaling into the trend with a small % of equity per trade. 
[*]Our example "VIDYA Trend Strategy" executes this by looking at a medium-term, volatility adjusted trend on a 4 hour chart. The script scales into it with 4% of the account equity every 4-hours that the trend is still up. This means you become fully invested after 25 trades/bars. It also means that early in the trade, when you might be more likely to experience a reversal, most of your account equity is not invested and those losses are much smaller. The script sells 100% of the position when it detects a trend reversal. The slower you scale into a trade, the less volatile your equity curve will be. This model also includes slippage and commissions that you can adjust under the "settings" menu.
[*]This fundamental concept of reducing timing risk by scaling into a trade can be applied to any market.
[/list]


Disclaimer: This is not financial advice. Open-source scripts I publish in the community are largely meant to spark ideas that can be used as building blocks for part of a more robust trade management strategy. If you would like to implement a version of any script, I would recommend making significant additions/modifications to the strategy & risk management functions. If you don’t know how to program in Pine, then hire a Pine-coder. We can help!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// @version=5
// Author = TradeAutomation


strategy(title="VIDYA Trend Strategy", shorttitle="VIDYA Trend Strategy", process_orders_on_close=true, overlay=true, pyramiding=25,  commission_type=strategy.commission.percent, commission_value=.075, slippage = 1, initial_capital = 1000000, default_qty_type=strategy.percent_of_equity, default_qty_value=4)


// Backtest Date Range Inputs // 
StartTime = input.time(defval=timestamp('01 Jan 2000 08:00'), group="Date Range", title='Start Time')
EndTime = input.time(defval=timestamp('01 Jan 2099 00:00'), group="Date Range", title='End Time')
InDateRange = time>=StartTime and time<=EndTime

// Strategy Inputs //
len = input.int(title="VIDYA Length", defval=50, step=5,group="Trend Settings")
src = input.source(title="VIDYA Price Source",defval=ohlc4, group="Trend Settings")

// VIDYA Calculations //
valpha=2/(len+1)
vud1=src>src[1] ? src-src[1] : 0
vdd1=src<src[1] ? src[1]-src : 0
vUD=math.sum(vud1,9)
vDD=math.sum(vdd1,9)
vCMO=nz((vUD-vDD)/(vUD+vDD))
var VIDYA = 0.0
VIDYA := na(VIDYA[1]) ? ta.sma(src, len) : nz(valpha*math.abs(vCMO)*src)+(1-valpha*math.abs(vCMO))*nz(VIDYA[1])
plot(VIDYA, title="VIDYA",color=(VIDYA > VIDYA[1]) ? color.green : (VIDYA<VIDYA[1]) ? color.red : (VIDYA==VIDYA[1]) ? color.gray : color.black, linewidth=2)

// Entry & Exit Signals //
if (InDateRange)
    strategy.entry("Long", strategy.long, when = VIDYA>VIDYA[1])
    strategy.close("Long", when = VIDYA<VIDYA[1])
if (not InDateRange)
    strategy.close_all()
````
