<!-- tradingview-pine-id: PUB;6d19f2898a264eb0899114d10790b3bd -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 24-hour Volume

Source: https://www.tradingview.com/script/DtpDJE1H-24-hour-Volume/

## Description

oppock Curve Multi-Filter is a trend and momentum-based indicator designed to identify potential high-probability Long and Short opportunities. It combines the Coppock Curve with multiple confirmation filters to determine market bias and provides visual Entry, Stop Loss, TP1, TP2 and TP3 levels.

Use the indicator alongside market structure, support/resistance and price action for confirmation. It is designed as a decision-support and risk-management tool, not a guaranteed signal generator. Always apply proper risk management.

If you want, I can also write you a much more professional TradingView publication description with sections like “How It Works,” “Buy Conditions,” “Sell Conditions,” “Risk Management,” and “Settings,” tailored specifically to your script.

---

## Source Code

````pine
//@version=6
indicator("24-hour Volume", "24H Vol", format=format.volume)

import PineCoders/getSeries/1 as gs

priceTooltip = "If the symbol's volume is expressed in base units, it is multiplied by this value to convert it into a price."
price = input.source(close, "Price Source", tooltip = priceTooltip)
currencyInput = input.string(title = "Target Currency", defval="Default", options=["Default", "USD", "EUR", "CAD", "JPY", "GBP", "HKD", "CNY", "NZD", "RUB"], display = display.none)
currency = currencyInput == "Default" ? "" : currencyInput
    
sumVolTF = switch
    timeframe.isminutes or timeframe.isseconds => "1"
    timeframe.isdaily => "5"
    => "60"

sum24hVol(src) =>
    msIn24h = 24 * 60 * 60 * 1000
    sourceValues = gs.rollOnTimeWhen(src, msIn24h)
    sourceValues.sum()
        
noVolumeError = "The data vendor doesn't provide volume data for this symbol."
if syminfo.volumetype == "tick" and syminfo.type == "crypto"
    runtime.error(noVolumeError)

var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error(noVolumeError)
    
expr = syminfo.volumetype == "quote" ? volume : price * volume
vol24h = request.security(syminfo.tickerid, sumVolTF, sum24hVol(expr * request.currency_rate(syminfo.currency, currency)))
plot(vol24h, title = "24H Volume", style = plot.style_columns)
````
