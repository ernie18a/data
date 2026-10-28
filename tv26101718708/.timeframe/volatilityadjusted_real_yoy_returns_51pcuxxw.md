# Volatility-adjusted real YoY returns (%)

- url: https://www.tradingview.com/script/51PcuXxW-Volatility-adjusted-real-YoY-returns/
- type: indicator
- pine_id: PUB;ffd4f510514f4c1680aeb3772aeb3d93
- version: 1.0

## Description

This indicator shows volatility-adjusted YoY real return.

It uses year-over-year log returns because YoY comparisons help eliminate seasonality. Other timeframes are generally less meaningful for this purpose, as they can be distorted by seasonal patterns, short-term noise, or incomplete economic cycles.

The hurdle rate is the maximum of inflation or the 3-month U.S. Treasury yield. The asset’s YoY return is reduced by this hurdle rate, then divided by annualized volatility.

The result is a risk-adjusted macro return score:

Positive values indicate YoY return is clearing the inflation/rate hurdle after volatility adjustment.

Negative values indicate YoY return is failing to clear that hurdle after volatility adjustment.

Copyright © 2026 @BTCTides. All rights reserved.
For educational and informational purposes only. Not financial advice.

## Source Code

````pine
//@version=5
// Copyright © 2026 @BTCTides (X account). All rights reserved.
// This script is provided for educational and informational purposes only.
// It is not financial advice, investment advice, or a recommendation to buy or sell any asset.
// Unauthorized copying, modification, redistribution, resale, or publication of this code is prohibited without prior written permission.
indicator("Vol-adjusted real YoY returns (%)", overlay=false, scale=scale.right,precision=2,format=format.percent)
//-------------------------------------------------------------------
bars_in_n_days(n) =>
    target_time = timestamp(year, month, dayofmonth - n, 0, 0)
    daily_time  = request.security(syminfo.tickerid, "D", time)
    int count   = 0
    for i = 0 to n
        if daily_time[i] >= target_time
            count += 1
    count
//-------------------------------------------------------------------
change(x,n0) =>
    n    = bars_in_n_days(n0)
    yoy = math.log(x/x[n])*100
//-------------------------------------------------------------------
volatility_adjustment(x, n0) =>
    ny=bars_in_n_days(365)
    n    = bars_in_n_days(n0)
    daily_ret = math.log(x / x[1]) * 100
    daily_vol = ta.stdev(daily_ret, n)
    ann_vol = daily_vol * math.sqrt(ny)
    ann_vol
//-------------------------------------------------------------------
[c, h, l]  = request.security(syminfo.tickerid, "D", [close, high, low])
p          = (c+c+h+l)/4
vol0       = volatility_adjustment(p, 365) 
//-------------------------------------------------------------------
intr0  = request.security("TVC:US03MY", "D", close)
infr0  = request.security("ECONOMICS:USIRYY", "D", close)
//-------------------------------------------------------------------
yoy0=change(p,365)
//-------------------------------------------------------------------
[yoy,vol,intr,infr] = request.security(syminfo.tickerid, "D", [yoy0,vol0,intr0,infr0])
//-------------------------------------------------------------------
hrdl=math.max(intr,infr)
//-------------------------------------------------------------------
VARyoy_returns=(yoy-hrdl)/vol 
//-------------------------------------------------------------------
col=VARyoy_returns   >= 0 ? color.new(color.green, 69) : color.new(color.red, 69)
//-------------------------------------------------------------------
plot(VARyoy_returns  , title="Area plot", color=col, linewidth=1, style=plot.style_area, display = display.pane)
plot(VARyoy_returns  , title="Line plot", color=color.rgb(255, 255, 255, 34), linewidth=4, style=plot.style_line, display = display.pane)
plot(0  , title="Zero line", color=color.rgb(255, 230, 34), linewidth=3, style=plot.style_line, display = display.pane)
````
