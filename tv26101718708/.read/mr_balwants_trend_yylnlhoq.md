# Mr Balwant's Trend

- url: https://www.tradingview.com/script/yYLnLHoq-Mr-Balwant-s-Trend/
- type: indicator
- pine_id: PUB;88f06d4db2914c1f8abb8780b81a9de2
- version: 1.0

## Description

# Mr Balwant's Trend + ADR Dashboard

This indicator combines Multi-Timeframe EMA 200 Trend Analysis with Average Daily Range (ADR) into a single dashboard.

Features:

• Trend detection using the 200 EMA on:

* 4 Hour
* 12 Hour
* 18 Hour
* Daily
* Weekly
* Monthly

• Bullish trend is displayed when price is above the 200 EMA.

• Bearish trend is displayed when price is below the 200 EMA.

• Displays Previous 14-Day ADR (Average Daily Range).

• Shows ADR Length and ADR Value directly on the chart.

• Clean dashboard layout with a quick higher-timeframe market bias overview.

How to Use:

* Look for alignment across multiple timeframes.
* More bullish timeframes indicate stronger bullish market structure.
* More bearish timeframes indicate stronger bearish market structure.
* Use ADR to estimate average daily movement and potential targets.

This indicator is intended for trend analysis and market context. It should be used alongside your own trading strategy and risk management.

## Source Code

````pine
//@version=6
indicator("Mr Balwant's Trend", overlay=true)

// =====================
// ADR SETTINGS
// =====================
adrLength = input.int(14, "ADR Length", minval=1)

adr = request.security(
    syminfo.tickerid,
    "D",
    ta.sma(high - low, adrLength)[1]
)

// =====================
// TREND FUNCTION
// =====================
getTrend(tf) =>
    ema200 = request.security(syminfo.tickerid, tf, ta.ema(close, 200))
    price = request.security(syminfo.tickerid, tf, close)
    price > ema200 ? "Bullish" : "Bearish"

// =====================
// TRENDS
// =====================
trend4H  = getTrend("240")
trend12H = getTrend("720")
trend18H = getTrend("1080")
trend1D  = getTrend("D")
trend1W  = getTrend("W")
trend1M  = getTrend("M")

// =====================
// TABLE
// =====================
var table dashboard = table.new(
    position.top_right,
    2,
    9,
    bgcolor=color.black,
    frame_color=color.yellow,
    frame_width=1
)

// =====================
// UPDATE TABLE
// =====================
if barstate.islast

    table.cell(dashboard, 0, 0, "Timeframe", bgcolor=color.yellow, text_color=color.black)
    table.cell(dashboard, 1, 0, "Trend", bgcolor=color.yellow, text_color=color.black)

    table.cell(dashboard, 0, 1, "4H", text_color=color.white)
    table.cell(dashboard, 1, 1, trend4H, bgcolor=trend4H == "Bullish" ? color.green : color.red, text_color=color.white)

    table.cell(dashboard, 0, 2, "12H", text_color=color.white)
    table.cell(dashboard, 1, 2, trend12H, bgcolor=trend12H == "Bullish" ? color.green : color.red, text_color=color.white)

    table.cell(dashboard, 0, 3, "18H", text_color=color.white)
    table.cell(dashboard, 1, 3, trend18H, bgcolor=trend18H == "Bullish" ? color.green : color.red, text_color=color.white)

    table.cell(dashboard, 0, 4, "1D", text_color=color.white)
    table.cell(dashboard, 1, 4, trend1D, bgcolor=trend1D == "Bullish" ? color.green : color.red, text_color=color.white)

    table.cell(dashboard, 0, 5, "1W", text_color=color.white)
    table.cell(dashboard, 1, 5, trend1W, bgcolor=trend1W == "Bullish" ? color.green : color.red, text_color=color.white)

    table.cell(dashboard, 0, 6, "1M", text_color=color.white)
    table.cell(dashboard, 1, 6, trend1M, bgcolor=trend1M == "Bullish" ? color.green : color.red, text_color=color.white)

    table.cell(dashboard, 0, 7, "ADR Length", bgcolor=color.rgb(40, 40, 40), text_color=color.white)
    table.cell(dashboard, 1, 7, str.tostring(adrLength), text_color=color.white)

    table.cell(dashboard, 0, 8, "ADR", bgcolor=color.rgb(40, 40, 40), text_color=color.white)
    table.cell(dashboard, 1, 8, str.tostring(adr, "#.0"), text_color=color.white)
````
