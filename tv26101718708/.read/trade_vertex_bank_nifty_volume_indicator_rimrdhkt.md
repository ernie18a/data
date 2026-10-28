# Trade Vertex - Bank Nifty Volume Indicator

- url: https://www.tradingview.com/script/RIMRdHKt-Trade-Vertex-Bank-Nifty-Volume-Indicator/
- type: indicator
- pine_id: PUB;d00261e5f47642f7a5dcb9cb73fc747a
- version: 1.0

## Description

[symbol="NSE:BANKNIFTY"]NSE:BANKNIFTY[/symbol]

We all know that the value of an Bank Nifty is derived from top banking sector underlying stocks. 
The value of Bank Nifty is calculated from free float market capitalization.
Using the same formula, I made an indicator on the bases of weighted volume of each stock.
This indicator will help you to plot Volume on Bank Nifty.

## Source Code

````pine
//@version=4
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Trade_Vertex

study(title="BNF Volume Study")

W_HDFCBANK=input(title="HDFCBANK", type=input.float, defval=26.08)
W_ICICIBANK=input(title="ICICIBANK", type=input.float, defval=20.05)
W_AXISBANK=input(title="AXISBANK", type=input.float, defval=15.35)
W_KOTAKBANK=input(title="KOTAKBANK", type=input.float, defval=15.88)
W_SBIN=input(title="SBIN", type=input.float, defval=10.54)
W_INDUSINDBK=input(title="INDUSINDBK", type=input.float, defval=5.07)
W_FEDERALBNK=input(title="FEDERALBNK", type=input.float, defval=1.33)
W_RBLBANK=input(title="RBLBANK", type=input.float, defval=1.03)
W_BANKBARODA=input(title="BANKBARODA", type=input.float, defval=0.61)
W_BANDHANBNK=input(title="BANDHANBNK", type=input.float, defval=2.72)
W_IDFC=input(title="IDFC", type=input.float, defval=0.78)
W_PNB=input(title="PNB", type=input.float, defval=0.56)


// custom function 
sym(s) => security(s,timeframe.period,  volume)

// make the weighted index 
A = (W_HDFCBANK*sym("NSE:HDFCBANK")/100 + W_ICICIBANK*sym("NSE:ICICIBANK")/100 + W_AXISBANK*sym("NSE:AXISBANK")/100+W_KOTAKBANK*sym("NSE:KOTAKBANK")/100+ W_SBIN*sym("NSE:SBIN")/100+W_INDUSINDBK*sym("NSE:INDUSINDBK")/100 +W_FEDERALBNK*sym("NSE:FEDERALBNK")/100 +W_RBLBANK*sym("NSE:RBLBANK")/100+W_BANKBARODA*sym("NSE:BANKBARODA")/100 +W_BANDHANBNK*sym("NSE:BANDHANBNK")/100+W_IDFC*sym("NSE:IDFC")/100+W_PNB*sym("NSE:PNB")/100)

colorofbar = open < close ? color.green : color.red

plot(A, linewidth=5, style=plot.style_columns,color=colorofbar)

length = input(title="MF Period",defval=20,type=input.integer, minval=1)
ad = close==high and close==low or high==low ? 0 : ((2*close-low-high)/(high-low))*A
mf = sum(ad, length) / sum(A, length)
plot(mf, color=color.green, title="MF",style=plot.style_line, linewidth=2)
hline(0, color=color.gray, title="Zero", linestyle=hline.style_dashed)
````
