# Simple way to BEAT the market [STRATEGY]

- url: https://www.tradingview.com/script/vrFq8cGn-Simple-way-to-BEAT-the-market-STRATEGY/
- type: strategy
- pine_id: PUB;3JHRl8tLQmwRlVIzkCBaH2C7DXJ1nwQE
- version: 2.0

## Description

This script has been created to demonstrate the effectiveness of using market regime filters in your trading strategy, and how they can improve your returns and lower your drawdowns

This strategy adds a simple filter (A historical volatility percentile filter, an implementation of which can be found on my trading profile) to a traditional buy and hold strategy of the index SPY. 

Note, There are other filters that could also be added including a long-term moving average/percentile rank filter/ADX filter etc, to improve the returns further.

The filter closes our long position during periods of volatility that exceed the 95th percentile (or in the top 5% of volatile days) and buys back when the volatility is below 95% rank of the past 100 days

Have included the backtest results since 1993 which is 28 years of data at the time of writing. Comparison of traditional buy and hold with this modified strategy can be found below:

[b]Traditional buy and hold:[/b]

[list]
[*] Return per year:         7.95   % (ex Dividends)
[*] Total return:              851.1  %
[*] Max drawdown:          50.79  %
[/list]

[b]'Modified' buy and hold (this script):[/b]

[list]
[*] Return per year:     9.92    % (ex Dividends)
[*] Total return:          [b]1412.2 %[/b]
[*] Max drawdown:      [b]31.57   %[/b]
[/list]

Feel free to use some of the market filters in my trading profile to improve and refine your strategies further, or make a copy and play around with the code yourself. This is just a simple example for demo purposes.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// 
// @author Sunil Halai
//
// This script has been created to demonstrate the effectiveness of using market regime filters in your trading strategy, and how they can improve your returns and lower your drawdowns
//
// This strategy adds a simple filter (The historical volatility filter, which can be found on my trading profile) to a traditional buy and hold strategy of the index SPY. There are other filters
// that could also be added included a long term moving average / percentile rank filter / ADX filter etc, to improve the returns further.
//
// Feel free to use some of the market filters in my trading profile to improve and refine your strategies further, or make a copy and play around with the code yourself. This is just 
// a simple example for demo purposes.
//

//@version=4
strategy(title = "Simple way to beat the market [STRATEGY]", shorttitle = "Beat The Market [STRATEGY]", overlay=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, currency="USD", default_qty_value=100)


upperExtreme = input(title = "Upper percentile filter (Do not trade above this number)", type = input.integer, defval = 95)
lookbackPeriod = input(title = "Lookback period", type = input.integer, defval = 100)

annual = 365
per = timeframe.isintraday or timeframe.isdaily and timeframe.multiplier == 1 ? 1 : 7
hv = lookbackPeriod * stdev(log(close / close[1]), 10) * sqrt(annual / per)

filtered = hv >= percentile_nearest_rank(hv, 100, upperExtreme)

if(not(filtered))
    strategy.entry("LONG", strategy.long)
else
    strategy.close("LONG")
````
