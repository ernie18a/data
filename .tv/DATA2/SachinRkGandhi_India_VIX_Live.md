<!-- tradingview-pine-id: PUB;008a53e8024249eebeeb835f8028db18 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# SachinRkGandhi India VIX Live

Source: https://www.tradingview.com/script/UlcXXN9x-SachinRkGandhi-India-VIX-Live/

## Description

# India VIX Live Value & Change Percentage Indicator

**India VIX by Sachin Raj Kumar Gandhi** is a TradingView indicator designed to provide a quick and clear view of the **live India VIX (Volatility Index) value** directly on the price chart.

The indicator displays:

* **India VIX – Live Value**
* **Change Percentage – Live % Change**

By keeping the India VIX information directly on the chart, traders can quickly monitor changes in market volatility without switching to a separate indicator panel.

### How It Helps

India VIX reflects the expected volatility in the Indian equity market. Monitoring its movement can provide useful context for **intraday trading, scalping, and short-term trade management**.

A rising VIX may indicate increasing market uncertainty and volatility, while a falling VIX may indicate relatively lower expected volatility.

This indicator can therefore be used alongside **Price Action, Technical Indicators, Options Data, and Market Structure** to help traders understand the prevailing volatility environment.

**Designed by Sachin Raj Kumar Gandhi**
*For educational and analytical purposes only. It is not a trading recommendation or financial advice.*

---

## Source Code

````pine
//@version=6
indicator("SachinRkGandhi India VIX Live", shorttitle="SachinRkGandhi India VIX", overlay=true)


//--------------------------------------------------
// India VIX Live Value
//--------------------------------------------------
vix = request.security(
     "NSE:INDIAVIX",
     timeframe.period,
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)

//--------------------------------------------------
// India VIX Previous Day Close
//--------------------------------------------------
vixPDC = request.security(
     "NSE:INDIAVIX",
     "D",
     close[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)

//--------------------------------------------------
// Change % From Previous Day Close
//--------------------------------------------------
vixChangePct = vixPDC != 0 ? ((vix - vixPDC) / vixPDC) * 100 : na

//--------------------------------------------------
// Display on Main Chart
//--------------------------------------------------
var table vixTable = table.new(
     position.top_right,
     2,
     2,
     bgcolor=color.new(color.black, 10),
     border_width=1
)

if barstate.islast
    table.cell(
         vixTable,
         0,
         0,
         "India VIX",
         text_color=color.white,
         text_size=size.normal
    )

    table.cell(
         vixTable,
         1,
         0,
         str.tostring(vix, "#.##"),
         text_color=color.white,
         text_size=size.normal
    )

    table.cell(
         vixTable,
         0,
         1,
         "Change Percentage",
         text_color=color.white,
         text_size=size.normal
    )

    table.cell(
         vixTable,
         1,
         1,
         str.tostring(vixChangePct, "+#.##;-#.##") + "%",
         text_color=vixChangePct >= 0 ? color.lime : color.red,
         text_size=size.normal
    )
````
