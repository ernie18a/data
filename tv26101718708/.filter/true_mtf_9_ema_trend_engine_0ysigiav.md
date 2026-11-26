# True MTF 9 EMA Trend Engine

- url: https://www.tradingview.com/script/0ySIGIAv-True-MTF-9-EMA-Trend-Engine/
- type: indicator
- pine_id: PUB;2a91a1bd294b4a74a4ff120fea08b382
- version: 1.0

## Description

Pine Script is a True Multi-Timeframe (MTF) 9 EMA Trend Engine for TradingView. Its main purpose is to show the direction of the 9-period Exponential Moving Average across 8 different timeframes simultaneously, while also plotting the 9 EMA on your active chart.

1. What the indicator does

It combines two things:

A. 9 EMA on your active chart

The script calculates:

9 EMA = 9-period Exponential Moving Average

and plots it directly on the price chart.

The line automatically changes:

🟢 Green → 9 EMA is rising
🔴 Red → 9 EMA is falling
⚪ Gray → essentially flat

So you can visually see when the short-term trend represented by the 9 EMA changes direction.

2. True multi-timeframe calculation

The important part is that the script does not take the 9 EMA from your current chart and somehow convert it into other timeframes.

It independently calculates the 9 EMA using:

Dashboard timeframe	EMA calculated from
Monthly	Monthly candles
Weekly	Weekly candles
Daily	Daily candles
4 Hour	4H candles
1 Hour	1H candles
15 Minute	15M candles
5 Minute	5M candles
1 Minute	1M candles

## Source Code

````pine
//@version=6
indicator("True MTF 9 EMA Trend Engine", shorttitle="MTF 9 EMA Engine", overlay=true, max_bars_back=500)

//====================================================
// INPUTS
//====================================================

groupEMA = "9 EMA Settings"

emaLength = input.int(
     9,
     "EMA Length",
     minval=1,
     group=groupEMA)

emaSource = input.source(
     close,
     "EMA Source",
     group=groupEMA)


groupDisplay = "Display Settings"

showEMA = input.bool(
     true,
     "Show 9 EMA",
     group=groupDisplay)

showDashboard = input.bool(
     true,
     "Show MTF Dashboard",
     group=groupDisplay)

showPriceRelation = input.bool(
     true,
     "Show Price vs EMA",
     group=groupDisplay)


groupDashboard = "Dashboard Settings"

dashboardPosition = input.string(
     "Top Right",
     "Dashboard Position",
     options=[
         "Top Right",
         "Top Left",
         "Bottom Right",
         "Bottom Left"
     ],
     group=groupDashboard)


//====================================================
// DASHBOARD POSITION
//====================================================

dashboardPos = dashboardPosition == "Top Left" ? position.top_left :
     dashboardPosition == "Bottom Right" ? position.bottom_right :
     dashboardPosition == "Bottom Left" ? position.bottom_left :
     position.top_right


//====================================================
// CURRENT CHART 9 EMA
//====================================================

ema9 = ta.ema(
     emaSource,
     emaLength)


// EMA direction
emaRising = ema9 > ema9[1]
emaFalling = ema9 < ema9[1]


// Dynamic EMA color
emaColor = emaRising ? color.green :
     emaFalling ? color.red :
     color.gray


// Plot actual chart 9 EMA
plot(
     showEMA ? ema9 : na,
     title="9 EMA",
     color=emaColor,
     linewidth=3)


//====================================================
// TRUE MTF EMA FUNCTION
//====================================================

// Calculates the actual 9 EMA inside the requested timeframe.
f_mtfEMA(string tf) =>
    request.security(
         syminfo.tickerid,
         tf,
         ta.ema(emaSource, emaLength),
         barmerge.gaps_off,
         barmerge.lookahead_off)


// Calculates previous 9 EMA inside requested timeframe.
f_mtfEMAPrev(string tf) =>
    request.security(
         syminfo.tickerid,
         tf,
         ta.ema(emaSource, emaLength)[1],
         barmerge.gaps_off,
         barmerge.lookahead_off)


// Calculates close inside requested timeframe.
f_mtfClose(string tf) =>
    request.security(
         syminfo.tickerid,
         tf,
         close,
         barmerge.gaps_off,
         barmerge.lookahead_off)


//====================================================
// MTF 9 EMA VALUES
//====================================================

emaMonthly = f_mtfEMA("1M")
emaMonthlyPrev = f_mtfEMAPrev("1M")

emaWeekly = f_mtfEMA("1W")
emaWeeklyPrev = f_mtfEMAPrev("1W")

emaDaily = f_mtfEMA("1D")
emaDailyPrev = f_mtfEMAPrev("1D")

ema4H = f_mtfEMA("240")
ema4HPrev = f_mtfEMAPrev("240")

ema1H = f_mtfEMA("60")
ema1HPrev = f_mtfEMAPrev("60")

ema15M = f_mtfEMA("15")
ema15MPrev = f_mtfEMAPrev("15")

ema5M = f_mtfEMA("5")
ema5MPrev = f_mtfEMAPrev("5")

ema1M = f_mtfEMA("1")
ema1MPrev = f_mtfEMAPrev("1")


//====================================================
// MTF PRICE VALUES
//====================================================

closeMonthly = f_mtfClose("1M")
closeWeekly = f_mtfClose("1W")
closeDaily = f_mtfClose("1D")
close4H = f_mtfClose("240")
close1H = f_mtfClose("60")
close15M = f_mtfClose("15")
close5M = f_mtfClose("5")
close1M = f_mtfClose("1")


//====================================================
// MTF EMA TREND
//====================================================

monthlyBull = emaMonthly > emaMonthlyPrev
weeklyBull = emaWeekly > emaWeeklyPrev
dailyBull = emaDaily > emaDailyPrev
h4Bull = ema4H > ema4HPrev
h1Bull = ema1H > ema1HPrev
m15Bull = ema15M > ema15MPrev
m5Bull = ema5M > ema5MPrev
m1Bull = ema1M > ema1MPrev


//====================================================
// MTF PRICE VS EMA
//====================================================

monthlyPriceBull = closeMonthly > emaMonthly
weeklyPriceBull = closeWeekly > emaWeekly
dailyPriceBull = closeDaily > emaDaily
h4PriceBull = close4H > ema4H
h1PriceBull = close1H > ema1H
m15PriceBull = close15M > ema15M
m5PriceBull = close5M > ema5M
m1PriceBull = close1M > ema1M


//====================================================
// DASHBOARD
//====================================================

var table dashboard = table.new(
     dashboardPos,
     4,
     10,
     border_width=1)


//====================================================
// DASHBOARD ROW FUNCTION
//====================================================

f_dashboardRow(
     int row,
     string tfName,
     float emaValue,
     bool trendBull,
     bool priceBull) =>

    trendText = trendBull ? "BULLISH" : "BEARISH"

    trendColor = trendBull ? color.green : color.red

    priceText = priceBull ? "ABOVE" : "BELOW"

    priceColor = priceBull ? color.green : color.red


    table.cell(
         dashboard,
         0,
         row,
         tfName,
         text_color=color.white,
         bgcolor=color.rgb(35, 35, 35))


    table.cell(
         dashboard,
         1,
         row,
         str.tostring(emaValue, format.mintick),
         text_color=color.white,
         bgcolor=color.rgb(35, 35, 35))


    table.cell(
         dashboard,
         2,
         row,
         trendText,
         text_color=color.white,
         bgcolor=trendColor)


    table.cell(
         dashboard,
         3,
         row,
         showPriceRelation ? priceText : "-",
         text_color=color.white,
         bgcolor=showPriceRelation ? priceColor : color.rgb(35, 35, 35))


//====================================================
// BUILD DASHBOARD
//====================================================

if barstate.islast

    if showDashboard

        // Header
        table.cell(
             dashboard,
             0,
             0,
             "TIMEFRAME",
             text_color=color.white,
             bgcolor=color.rgb(20, 20, 20))


        table.cell(
             dashboard,
             1,
             0,
             "9 EMA",
             text_color=color.white,
             bgcolor=color.rgb(20, 20, 20))


        table.cell(
             dashboard,
             2,
             0,
             "TREND",
             text_color=color.white,
             bgcolor=color.rgb(20, 20, 20))


        table.cell(
             dashboard,
             3,
             0,
             "PRICE",
             text_color=color.white,
             bgcolor=color.rgb(20, 20, 20))


        // Monthly
        f_dashboardRow(
             1,
             "Monthly",
             emaMonthly,
             monthlyBull,
             monthlyPriceBull)


        // Weekly
        f_dashboardRow(
             2,
             "Weekly",
             emaWeekly,
             weeklyBull,
             weeklyPriceBull)


        // Daily
        f_dashboardRow(
             3,
             "Daily",
             emaDaily,
             dailyBull,
             dailyPriceBull)


        // 4 Hour
        f_dashboardRow(
             4,
             "4 Hour",
             ema4H,
             h4Bull,
             h4PriceBull)


        // 1 Hour
        f_dashboardRow(
             5,
             "1 Hour",
             ema1H,
             h1Bull,
             h1PriceBull)


        // 15 Minute
        f_dashboardRow(
             6,
             "15 Min",
             ema15M,
             m15Bull,
             m15PriceBull)


        // 5 Minute
        f_dashboardRow(
             7,
             "5 Min",
             ema5M,
             m5Bull,
             m5PriceBull)


        // 1 Minute
        f_dashboardRow(
             8,
             "1 Min",
             ema1M,
             m1Bull,
             m1PriceBull)


        // Current chart
        chartTrendText = emaRising ? "RISING" :
             emaFalling ? "FALLING" :
             "FLAT"


        chartTrendColor = emaRising ? color.green :
             emaFalling ? color.red :
             color.gray


        table.cell(
             dashboard,
             0,
             9,
             "CHART",
             text_color=color.white,
             bgcolor=color.rgb(20, 20, 20))


        table.cell(
             dashboard,
             1,
             9,
             "9 EMA",
             text_color=color.white,
             bgcolor=color.rgb(20, 20, 20))


        table.cell(
             dashboard,
             2,
             9,
             chartTrendText,
             text_color=color.white,
             bgcolor=chartTrendColor)


        table.cell(
             dashboard,
             3,
             9,
             close > ema9 ? "ABOVE" : "BELOW",
             text_color=color.white,
             bgcolor=close > ema9 ? color.green : color.red)


//====================================================
// ALERTS
//====================================================

alertcondition(
     ta.crossover(close, ema9),
     title="Price Crossed Above 9 EMA",
     message="Price crossed above the 9 EMA.")


alertcondition(
     ta.crossunder(close, ema9),
     title="Price Crossed Below 9 EMA",
     message="Price crossed below the 9 EMA.")


alertcondition(
     emaRising and not emaRising[1],
     title="9 EMA Turned Bullish",
     message="9 EMA has turned bullish/rising.")


alertcondition(
     emaFalling and not emaFalling[1],
     title="9 EMA Turned Bearish",
     message="9 EMA has turned bearish/falling.")
````
