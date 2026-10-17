# Running Equity - A New Indicator For Optimal Markets Detection

- url: https://www.tradingview.com/script/BqLZ8fp7-Running-Equity-A-New-Indicator-For-Optimal-Markets-Detection/
- type: indicator
- pine_id: PUB;XmNE8ypwFNi4yfuRzPriBbsB03CLDUfa
- version: 1.0

## Description

[b]Introduction[/b]

Winning trades and gaining profits in trading is not impossible, however having gross profits superior to gross losses is what make trading challenging, it is logical to think that it is better to open a position when the probability of winning the trade is high, such probability can’t be measured with accuracy but a lot of metrics have been proposed in order to help determining when to open positions, technical analysis support the fact that a trending market is the best market condition for opening a position, which is logical when using a trend following strategy, therefore a long-term positive auto-correlated market is optimal for trading, this is why this paper present a new method for detecting optimal markets conditions in order to open a position.


[b]The Indicator[/b]

The proposed indicator is based on the assumption that positive returns using a trend following strategy are a strong indication of trend strength, the proposed indicator is built from the conditions of a simple SMA cross trend following strategy, which are to go long when price > SMA and to go short when price < SMA. Then the equity from those conditions is built, in order to provide a more flexible indicator, [i]length[/i] control the period of the sum.

[image]https://www.tradingview.com/x/FSZPVEvN/[/image]

When the indicator is positive it means that the market allow for potential returns, it can thus be considered being trending. Else a negative value of the indicator indicate a ranging market that won't allow for returns.

[b]Filtering Bad Trades[/b]

The indicator can be used to filter bad trades entries, in this example a Bollinger band breakout strategy is used, without any changes the strategy return the following equity on EURUSD

[image]https://www.tradingview.com/x/PVavihhQ/[/image]

The proposed indicator is then applied with the following conditions : buy and sell only if Req > 0 

[image]https://www.tradingview.com/x/7DN7iip5/[/image]

With an indicator period = 100 we filtered unprofitable trades.

[b]Conclusion[/b]

I presented a new indicator for the detection of optimal markets based on a running equity. I hope both indicators may find applications in technical analysis and help investors get pertinent outputs from them.

it would mean a lot if you could read the original paper : https://figshare.com/articles/A_New_Technical_Indicator_For_Optimal_Markets_Detection/9825752

## Source Code

````pine
//@version=4
study("Running Equity")
length = input(100)
//----
src = close
X = sign(src - sma(src,length))
Req = sum(change(src)*X[1],length)
//----
css = Req > 0 ? #0cb51a : #FF0000
plot(Req,color=css,style=plot.style_area,transp=20)
````
