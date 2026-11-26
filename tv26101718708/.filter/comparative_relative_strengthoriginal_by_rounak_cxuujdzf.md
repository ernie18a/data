# Comparative Relative Strength_Original By Rounak

- url: https://www.tradingview.com/script/cXUuJdzF-Comparative-Relative-Strength-Original-By-Rounak/
- type: indicator
- pine_id: PUB;ff774c1cb3e94b6096e1942b4e3ffd0c
- version: 4.0

## Description

This Pine Script was developed by Mr. Rounak of Trade with Trend; I just made a small modification. All credit goes to Rounak bhai

## Source Code

````pine
//@version=6
indicator("Comparative Relative Strength", shorttitle="RS", overlay=false)

b = input.symbol("NSE:NIFTY", "Benchmark")

as_ = request.security(syminfo.tickerid, timeframe.period, close)
bs_ = request.security(b, timeframe.period, close)

rs = (as_ / bs_) - 1

len = input.int(200, "Length")

plot(rs * 100, title="RS", color=color.gray, linewidth=2)
plot(ta.sma(rs, len) * 100, title="MA", color=color.blue, linewidth=2)

hline(0, "Zero")
````
