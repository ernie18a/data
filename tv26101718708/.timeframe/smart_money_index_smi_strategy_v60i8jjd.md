# Smart Money Index (SMI) Strategy

- url: https://www.tradingview.com/script/v60i8jJd-Smart-Money-Index-SMI-Strategy/
- type: indicator
- pine_id: PUB;umw7usT53HvLWGjgdxtFIibk20cHj8Wr
- version: 1.0

## Description

Attention:
 If you would to use this indicator on the ES, you should have intraday data 60min in your account.

 Smart money index (SMI) or smart money flow index is a technical analysis indicator demonstrating investors sentiment. 
 The index was invented and popularized by money manager Don Hays.[1] The indicator is based on intra-day price patterns.
 The main idea is that the majority of traders (emotional, news-driven) overreact at the beginning of the trading day 
 because of the overnight news and economic data. There is also a lot of buying on market orders and short covering at the opening. 
 Smart, experienced investors start trading closer to the end of the day having the opportunity to evaluate market performance.
 Therefore, the basic strategy is to bet against the morning price trend and bet with the evening price trend. The SMI may be calculated 
 for many markets and market indices (S&P 500, DJIA, etc.)

 The SMI sends no clear signal whether the market is bullish or bearish. There are also no fixed absolute or relative readings signaling 
 about the trend. Traders need to look at the SMI dynamics relative to that of the market. If, for example, SMI rises sharply when the 
market falls, this fact would mean that smart money is buying, and the market is to revert to an uptrend soon. The opposite situation 
 is also true. A rapidly falling SMI during a bullish market means that smart money is selling and that market is to revert to a downtrend 
 soon. The SMI is, therefore, a trend-based indicator.
 Some analysts use the smart money index to claim that precious metals such as gold will continually maintain value in the future.

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 31/07/2018
// Attention:
// If you would to use this indicator on the ES, you should have intraday data 60min in your account.
//
// Smart money index (SMI) or smart money flow index is a technical analysis indicator demonstrating investors sentiment. 
// The index was invented and popularized by money manager Don Hays.[1] The indicator is based on intra-day price patterns.
// The main idea is that the majority of traders (emotional, news-driven) overreact at the beginning of the trading day 
// because of the overnight news and economic data. There is also a lot of buying on market orders and short covering at the opening. 
// Smart, experienced investors start trading closer to the end of the day having the opportunity to evaluate market performance.
// Therefore, the basic strategy is to bet against the morning price trend and bet with the evening price trend. The SMI may be calculated 
// for many markets and market indices (S&P 500, DJIA, etc.)
//
// The SMI sends no clear signal whether the market is bullish or bearish. There are also no fixed absolute or relative readings signaling 
// about the trend. Traders need to look at the SMI dynamics relative to that of the market. If, for example, SMI rises sharply when the 
// market falls, this fact would mean that smart money is buying, and the market is to revert to an uptrend soon. The opposite situation 
// is also true. A rapidly falling SMI during a bullish market means that smart money is selling and that market is to revert to a downtrend 
// soon. The SMI is, therefore, a trend-based indicator.
// Some analysts use the smart money index to claim that precious metals such as gold will continually maintain value in the future.
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Smart Money Index (SMI) Strategy", shorttitle="Smart Money Index")
Length = input(18, minval=1)
xcloseH1 = security(tickerid, "60", close)
xopenH1 =  security(tickerid, "60", open)
nRes = nz(nRes[1], 1) - (open - close) + (xopenH1 - xcloseH1)
xSmaRes = sma(nRes, Length)
pos = iff(xSmaRes > nRes, 1,
       iff(xSmaRes < nRes, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xSmaRes, color=red, title="SMASMI")
plot(nRes, color=green, title="SMI")
````
