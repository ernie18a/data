<!-- tradingview-pine-id: PUB;j0FuqqJKuUk0jdvGJnUa22rUR09oinvv -->
<!-- tradingviewscripts-format: 1 -->
# Market EKG

Source: https://www.tradingview.com/script/2VmbQBLn-Market-EKG/

## Description

Short Summary 

[*]This indicator takes the differences in the previous 4 period OHLC inputs, and compares them to the previously closed candle input. The difference is then placed into an oscillator that when all four inputs are scrolled back on, shows an EKG appearing oscillator / volatility measure for traders to use on indexes, tickers and markets that do not allow typical volume based indicators.

Full Summary 
[*] Named for its similar appearance to an EKG medical chart, this script takes the difference in relative averages of previous periods in a trend , and compares it to the most recent period input. This can be used as a price based volatility measure, useful in markets that may be limited by no valume measures or other indexes where volatility is useful to meeasure but will not allow volume initializations.

Steps taken 

[*] Taking Previous Period OHLC
[*] Taking Previous 3 Periods OHLC Avgs
[*] Difference Between #1 & #2 (Comparing most recent confirmation to relative trend
[*] Plot Results

This RSI Script is intended for public use and can be shared / implemented as needed
Questions? I do not monitor my TradingView inbox. See email address in signature at the bottom of this page for contact information.
Use this script and its calculations as needed! No permission required.
Cheers,

---

## Source Code

````pine
//  || This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/                                             -                \\  ||
//  ||-------------------------------------------------------------------------------------------------------------------------------------------------------------------------\\  ||
//  || Published by © Eric Thies on Tradingview.com --> Released on 2/6/2020                                                                                                       ||
//  ||-------------------------------------------------------------------------------------------------------------------------------------------------------------------------\\  ||
//  || Market EKG - by KingThies                                                                                                                                               \\  ||
//  ||-------------------------------------------------------------------------------------------------------------------------------------------------------------------------\\  ||
//<Start Source> <pine>
//@version=4
study("Market EKG", title="Market EKG", overlay=false)

//#1) Taking Previous Period OHLC 
al = low[1],    ah = high[1], ac = close[1], ao = open[1]

//#2) Taking Previous 3 Periods OHLC Avgs  
xaLo = avg(low[3],low[2]), xaHi = avg(high[3],high[2]), xaCl = avg(close[3],close[2]), xaOp = avg(open[3],open[2])

//Difference Between #1 & #2 (Comparing most recent confirmation to relative trend)
xdLo = xaLo-al, xdHi = xaHi - ah, xdCl = xaCl - ac, xdOp = xaOp - ao

//Plot Results 
plot(xdLo,color=color.red), plot(xdHi,color=color.red), plot(xdCl,color=color.red),plot(xdOp,color=color.red),hline(0,color=color.white)

// </End Source> </pine>
//  ||----------------------------------------------------------------------------------------------------------------------------------------------------------------------------||
//  || Market EKG - by KingThies                                                                                                                                              \\  ||
//  ||--------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ||
//  || Published by © Eric Thies on Tradingview.com --> Released on 2/6/2020                                                                                                      ||
//  ||--------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ||
````
