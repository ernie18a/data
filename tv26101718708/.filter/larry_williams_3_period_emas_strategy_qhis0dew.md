# Larry Williams 3 Period EMAs strategy

- url: https://www.tradingview.com/script/QhIS0dEW-Larry-Williams-3-Period-EMAs-strategy/
- type: strategy
- pine_id: PUB;d05e7b15654642a4aa61c8be8a3b1d97
- version: 2.0

## Description

Larry R. Williams explains this strategy in his book "Long-Term secrets to Short-Term trading", it consists of using two 3-period EMAs, one representing the Highs and the other the Lows.
When the price falls below the 3-period Lows EMA we have a long signal.
The trade is closed when the price closes above the 3-period Highs EMA .[symbol="BINANCE:BTCUSDT"]BINANCE:BTCUSDT[/symbol]

## Source Code

````pine
//Dragolite95
//@version=4
strategy(
     "Larry Williams 3 Period EMAs strategy",
     overlay=true,
     calc_on_every_tick=true,
     currency=currency.USD,
     process_orders_on_close=true
     )

// Security to avoid Repainting
res = input(title="Timeframe", type=input.resolution, defval="60")
rp_security(_symbol, _res, _src) => security(_symbol, _res, _src, barmerge.gaps_off, barmerge.lookahead_on)
securedClose = rp_security(syminfo.tickerid, res, close)

// Time range for backtesting
startDate = input(title="Start Date", defval=1, minval=1, maxval=31)
startMonth = input(title="Start Month", defval=1, minval=1, maxval=12)
startYear = input(title="Start Year", defval=2018, minval=1800, maxval=2100)

endDate = input(title="End Date", defval=31, minval=1, maxval=31)
endMonth = input(title="End Month", defval=12, minval=1, maxval=12)
endYear = input(title="End Year", defval=2021, minval=1800, maxval=2100)

inDateRange = (time >= timestamp(syminfo.timezone, startYear, startMonth, startDate, 0, 0)) and
     (time < timestamp(syminfo.timezone, endYear, endMonth, endDate, 0, 0))

// EMA
highs = input(title="Highs Period", type=input.integer, defval=3, minval=1, maxval=9999)
lows  = input(title="Lows Period", type=input.integer, defval=3, minval=1, maxval=9999)
emaH = ema(high, highs)
emaL = ema(low, lows)

// PLOT:
// Draw the EMA lines on the chart
plot(series=emaH, color=color.green, linewidth=2)
plot(series=emaL, color=color.red, linewidth=2)

// Conditions
if(inDateRange and securedClose < emaL and barstate.isconfirmed)
    strategy.entry("Long", strategy.long, comment="Long")
if(securedClose > emaH and barstate.isconfirmed)
    strategy.close("Long", comment="Close Long")

// Uncomment to enable short entries
//if(inDateRange and close > emaH and barstate.isconfirmed)                                    
//    strategy.entry("Short", strategy.short, comment="Short")    
//if(close < emaL and barstate.isconfirmed)
//    strategy.close("Short", comment="Close Short")
````
