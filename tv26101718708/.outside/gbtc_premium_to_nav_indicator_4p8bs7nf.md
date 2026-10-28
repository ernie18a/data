# GBTC Premium to NAV Indicator

- url: https://www.tradingview.com/script/4p8BS7nf-GBTC-Premium-to-NAV-Indicator/
- type: indicator
- pine_id: PUB;bRZlVhIDIEdRmhzgl2zbwVxhSx9E8TyG
- version: 1.0

## Description

When bitcoin is in an uptrend, a very profitable strategy is to buy GBTC when premium to NAV is low, and sell when it reaches extremes. This can be far more profitable than buying bitcoin itself.

## Source Code

````pine
//@version=3
study("GBTC Premium to NAV Indicator", 'GBTC Premium', false)
btc = security(symbol = 'BITFINEX:BTCUSD', resolution = period, expression = close)
holdings = input(title="BTC/Share", type=float, defval=0.00100231)
EMA = input(title='EMA Period', type=integer, defval= 200)
//default pulled from Greyscale website and current as of April 30,2018

l1 = 0, l2 = 20, l3 = 40, l4 = 80, l5 = 100, l6 = 120, l7 = 150
h1 = hline(price = l1, color=color(gray, 50), linestyle = dotted, linewidth=1, editable=true)
h2 = hline(price = l2, color=color(gray, 50), linestyle = dotted, linewidth=1, editable=true)
h3 = hline(price = l3, color=color(gray, 50), linestyle = dotted, linewidth=1, editable=true)
h4 = hline(price = l4, color=color(gray, 50), linestyle = dotted, linewidth=1, editable=true)
h5 = hline(price = l5, color=color(gray, 50), linestyle = dotted, linewidth=1, editable=true)
h6 = hline(price = l6, color=color(gray, 50), linestyle = dotted, linewidth=1, editable=true)


prem = close/(btc*holdings)*100 - 100

color = prem < 10 ? lime : prem < l2 ? green : prem < l3 ? olive : prem < l4 ? gray : prem < l5 ? orange: prem < l6 ? red : prem < l7 ? fuchsia : na

bgcolor(prem < 20 ? green : prem > 90 ? red : na, transp=80)

plot(prem,'Premium to NAV',color = color, linewidth = 3, trackprice = true)
plot(ema(prem,EMA),'Mean Premium', color = navy, linewidth = 1)
````
