# Fair Value Strategy - ekmll

- url: https://www.tradingview.com/script/Hvzsgn8F/
- type: strategy
- pine_id: PUB;40a7505658064fb3aa8f88d8485f9d3e
- version: 1.0

## Description

This is a strategy using SPX's Fair Value derived from Net Liquidity.

The main difference between this one and calebsandfort's one is net liquidity values in this one are calculated in TradingView and doesn't need author's daily library updates to function.  

Net Liquidity function is simply: Fed Balance Sheet - Treasury General Account - Reverse Repo Balance

Formula for calculating the fair value of and Index using Net Liquidity looks like this: (WALCL - WTREGEN - RRPONTSYD)/1000000000/scalar - subtractor

The Index Fair Value is then subtracted from the Index value which creates an oscillating diff value.

When diff is greater than the overbought threshold, Index is considered overbought and we go short/sell.

When diff is less than the oversold signal, Index is considered oversold and we cover/buy.

Parameters:

Index: SPX, NDX, RUT

Strategy: Short Only, Long Only, Long/Short

Inverse (bool): check if using an inverse ETF to go long instead of short.

Scalar (float)

Subtractor (int)

Overbought Threshold (int)

Oversold Threshold (int)

Start After Date: When the strategy should start trading

Close Date: Day to close open trades. I just like it to get complete results rather than the strategy ending with open trades.

I've optimized the parameters for SPX.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©ekmll

//@version=5
strategy("Fair Value Strategy ekmll", overlay=false, initial_capital = 1000000, calc_on_every_tick = true)

fv_index_ticker = input.string("SPX", "Fair Value Index", ["SPX", "NDX", "RUT"])
mode = input.string("Long/Short", "Strategy", ["Short Only", "Long Only", "Long/Short"])

scalar = input.float(1.1, "Scalar", 0.0, 5.0, .1)
subtractor = input.int(1425, "Subtractor", step = 25)
ob_threshold = input.int(0, "OB Threshold", step = 25)
os_threshold = input.int(-175, "OS Threshold", step = 25)

inverse = input.bool(false, "Inverse")

startDate = input.int(title="Start Day", defval=20, minval=1, maxval=31)
startMonth = input.int(title="Start Month", defval=12, minval=1, maxval=12)
startYear = input.int(title="Start Year", defval=2021, minval=1800, maxval=2100)

// See if this bar's time happened on/after start date
afterStartDate = (time >= timestamp(syminfo.timezone, startYear, startMonth, startDate, 0, 0))

useCloseDate = input.bool(true, title="Use Close Date")

closeDay = input.int(title="Close Day", defval=20, minval=1, maxval=31)
closeMonth = input.int(title="Close Month", defval=12, minval=1, maxval=12)
closeYear = input.int(title="Close Year", defval=2024, minval=1800, maxval=2100)  

// See if this bar's time happened on/after end date
afterEndDate = year == closeYear and month == closeMonth and dayofmonth == closeDay


net_liquidity = request.security("(WALCL - WTREGEN - RRPONTSYD)", "D", close)
plotchar(net_liquidity, "net_liquidity", "", location.top)

index_fair_value = net_liquidity/1000000000/scalar - subtractor
index = request.security(fv_index_ticker, "D", close)
diff = index - index_fair_value

plot(index_fair_value > 0 ? diff : na, title = "Spread", color = color.blue, trackprice = true, linewidth = 2)

hline(0, title='Zero', color=color.gray, linestyle=hline.style_dotted, linewidth=2)
hline(ob_threshold, title='Overbought', color=color.red, linestyle=hline.style_dotted, linewidth=2)
hline(os_threshold, title='Oversold', color=color.green, linestyle=hline.style_dotted, linewidth=2)

overbought_signal = net_liquidity > 0.0 and (diff[1] < ob_threshold and diff[0] > ob_threshold)
oversold_signal = net_liquidity > 0.0 and (diff[1] > os_threshold and diff[0] < os_threshold)

barcolor(overbought_signal ? color.purple : oversold_signal ? color.blue : na)

qty = (strategy.initial_capital + strategy.netprofit + strategy.openprofit)/close
qty_adj = strategy.opentrades > 0 ? math.abs(strategy.opentrades.size(0) * 1) : qty[0]

if (mode == "Long/Short")
    if (inverse)
        if (overbought_signal and afterStartDate)
            strategy.entry("Long", strategy.long, qty = qty[0], comment = "LE")        
        else if ((afterStartDate and oversold_signal) or (useCloseDate and afterEndDate))
            strategy.entry("Short", strategy.short, qty = qty[0], comment = "SE")
        else if (useCloseDate and afterEndDate)
            strategy.close("Short", qty_percent=100, comment="close")
            strategy.close("Long", qty_percent=100, comment="close")
    else
        if (overbought_signal and afterStartDate)
            strategy.entry("Short", strategy.short, qty = qty[0], comment = "SE")
        else if (afterStartDate and oversold_signal)
            strategy.entry("Long", strategy.long, qty = qty[0], comment = "LE")
        else if (useCloseDate and afterEndDate)
            strategy.close("Short", qty_percent=100, comment="close")
            strategy.close("Long", qty_percent=100, comment="close")
else if (mode == "Short Only")
    if (inverse)
        if (overbought_signal and afterStartDate)
            strategy.entry("Long", strategy.long, qty = qty[0], comment = "LE")
                
        if ((afterStartDate and oversold_signal) or (useCloseDate and afterEndDate))
            strategy.close("Long", qty_percent=100, comment="close")
    else
        if (overbought_signal and afterStartDate)
            strategy.entry("Short", strategy.short, qty = qty[0], comment = "SE")
                
        if ((afterStartDate and oversold_signal) or (useCloseDate and afterEndDate))
            strategy.close("Short", qty_percent=100, comment="close")
else if (mode == "Long Only")
    if (inverse)
        if (oversold_signal and afterStartDate)
            strategy.entry("Short", strategy.short, qty = qty[0], comment = "SE")
                
        if ((afterStartDate and overbought_signal) or (useCloseDate and afterEndDate))
            strategy.close("Short", qty_percent=100, comment="close")
    else
        if (oversold_signal and afterStartDate)
            strategy.entry("Long", strategy.long, qty = qty[0], comment = "LE")
                
        if ((afterStartDate and overbought_signal) or (useCloseDate and afterEndDate))
            strategy.close("Long", qty_percent=100, comment="close")
````
