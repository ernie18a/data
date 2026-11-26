# Commodity Markets Dashboard with Cheat Sheet

- url: https://www.tradingview.com/script/FdOZFyCn-Commodity-Markets-Dashboard-with-Cheat-Sheet/
- type: indicator
- pine_id: PUB;2285757258a640b09390e0706a823bbf
- version: 1.0

## Description

Commodity Markets Dashboard with Cheat Sheet

This indicator is a multi-market commodity dashboard designed to compare major commodity groups across short-, medium- and long-term time horizons.

It organises markets into six pages:

Commodity Indices
Energy
Metals
Grains & Oilseeds
Softs & Livestock
Real Commodity / CPI

The dashboard ranks instruments from strongest to weakest using 10-year performance where available. If a valid 10-year value is not available, it falls back to 5-year performance. The ranking basis is shown next to each instrument as [10Y] or [5Y].

For example:

#1 Gold [10Y]
#2 Copper [10Y]
#3 Iron [5Y]

This makes it possible to include newer data series while still keeping the table ranked.

What the dashboard shows

The Full view contains:

Current
1 Week
1 Month
3 Months
6 Months
1 Year
2 Years
3 Years
5 Years
10 Years
21-Day Z-Score
30-Week High Distance
200-Week Moving Average Distance
Cheat Sheet

There are also two reduced views:

Momentum focuses on shorter-term performance, the Z-score, distance from the 30-week high and position relative to the 200-week moving average.

Long Term concentrates on 1-year, 2-year, 3-year, 5-year and 10-year performance together with the 200-week moving average.

Colour interpretation

Green indicates positive performance or a market trading above its long-term trend.

Red indicates negative performance or a market trading below its long-term trend.

Yellow represents approximately unchanged performance based on the user-defined neutral band.

Orange is used when the 21-day Z-score indicates a relatively stretched move.

Blue is used for structural/reference information.

Grey is used for current values, neutral information and unavailable data.

Colours are intended as a visual aid only and are not automatic buy or sell signals.

21-Day Z-Score

The 21-day Z-score measures how far the current price is from its 21-day average in standard-deviation terms.

A reading around:

0       Near its recent average
+1      Moderately above average
-1      Moderately below average
+2      Strong positive extension
-2      Strong negative extension
+3/-3   Very unusual short-term move

The Z-score should be interpreted as a measure of statistical extension, not by itself as a reversal signal.

A strongly positive Z-score can occur in a powerful uptrend, while a strongly negative Z-score can occur during persistent weakness.

30-Week High

The dashboard shows the percentage distance from the highest price reached over approximately 30 weeks.

Examples:

0%       At or very near the 30-week high
-5%      5% below the 30-week high
-20%     20% below the 30-week high

A value close to zero generally indicates strong intermediate-term positioning, while a deeply negative value indicates that the instrument has moved significantly away from its recent high.

200-Week Moving Average

The 200-week moving average is used as a long-term trend reference.

Examples:

+25%     Price is 25% above its 200-week moving average
0%       Price is close to its 200-week moving average
-20%     Price is 20% below its 200-week moving average

This can help distinguish a short-term rally from a market that is also strong on a much longer-term basis.

Commodity Indices

This page provides a broad overview of the commodity complex using major benchmark indices.

It is useful for identifying whether strength or weakness is concentrated in an individual commodity or is part of a broader commodity-market move.

Energy

The Energy page includes major oil, refined-product, natural-gas and carbon markets.

Examples include:

WTI Crude
Brent Crude
Heating Oil
Gasoil
Gasoline
Henry Hub Natural Gas
Dutch TTF Gas
UK NBP Gas
Carbon

Energy markets can be influenced by supply, inventories, weather, refining capacity, geopolitical events and global demand.

Metals

The Metals page includes precious and industrial metals such as:

Gold
Silver
Platinum
Palladium
Copper
Aluminium
Iron
Zinc
Lead
Nickel
TSI

Precious metals can be sensitive to currencies, interest rates and investment demand, while industrial metals are often more closely linked to manufacturing, construction and global economic activity.

Copper and iron are particularly useful as cyclical indicators because of their importance in construction and industrial production.

Grains & Oilseeds

This section covers major agricultural markets including:

Wheat
Corn
Soybeans
Soybean Meal
Soybean Oil
Oats
Rough Rice
European Wheat

Agricultural commodities can be highly sensitive to weather, harvest conditions, inventories, trade policy and regional production shocks.

Softs & Livestock

This page includes markets such as:

Cocoa
Coffee
Robusta Coffee
Sugar
Cotton
Orange Juice
Live Cattle
Lean Hogs
Lumber

Many of these markets can experience substantial supply-driven volatility because production is sensitive to weather, disease, crop cycles, herd cycles or geographically concentrated supply.

Real Commodity / CPI

This page divides selected asset prices by the U.S. Consumer Price Index.

Examples include:

Gold / CPI
Silver / CPI
WTI / CPI
Copper / CPI
Bitcoin / CPI
Ethereum / CPI
XRP / CPI

These ratios are designed to show how an asset has performed relative to consumer-price inflation.

If a ratio is rising, the asset has been appreciating faster than the CPI measure over that period.

If a ratio is falling, the asset has been underperforming CPI.

These are relative-price ratios and should not be interpreted as a precise measure of an investor's personal purchasing power.

Ranking methodology

The dashboard sorts each page from strongest to weakest.

The ranking rule is:

1. Use 10-year return where available
2. If 10-year data is unavailable, use 5-year return
3. If neither exists, place the instrument at the bottom

The ranking basis is displayed alongside the commodity name.

This means that two instruments may occasionally be ranked using different historical periods. The [10Y] and [5Y] labels are included specifically so this is visible to the user.

Data availability

Some TradingView feeds have significantly longer histories than others.

For this reason:

Some instruments may show N/A for longer periods.
A 10-year figure requires sufficient historical data from the selected TradingView feed.
Continuous futures, CFDs, spot markets and exchange-traded instruments can have different historical construction methods.
Results from different providers may not be perfectly comparable.

The script uses ignore_invalid_symbol=true, so an unavailable symbol should normally display unavailable data rather than intentionally stopping the entire dashboard.

How to use the dashboard

The dashboard is most useful for looking for agreement across several horizons.

For example, an instrument displaying:

1M     positive
3M     positive
1Y     positive
5Y     positive
10Y    positive
200W   positive

is showing strength across several different time horizons.

By contrast:

1M     positive
3M     positive
5Y     negative
10Y    negative
200W   negative

may indicate a shorter-term recovery occurring inside a weaker long-term trend.

The dashboard is intended to help users see these differences quickly rather than relying on any single metric.

Important note

This indicator is an analytical dashboard, not an investment recommendation or automated trading system.

Long-term returns, moving averages, Z-scores and relative CPI ratios are descriptive measures. They should be considered together with liquidity, fundamentals, macroeconomic conditions, market structure and the characteristics of the underlying TradingView data feed.

## Source Code

````pine
//@version=6
indicator(
     "Commodity Markets Dashboard with Cheat Sheet",
     shorttitle="Commodity Markets Dashboard",
     overlay=false,
     dynamic_requests=true
)

//======================================================================
// COMMODITY MARKETS DASHBOARD WITH CHEAT SHEET
//======================================================================
//
// PURPOSE
// -------
//
// Multi-horizon dashboard for commodity markets.
//
// PAGES
// -----
//
// 1. Commodity Indices
// 2. Energy
// 3. Metals
// 4. Grains & Oilseeds
// 5. Softs & Livestock
// 6. Real Commodity / CPI
//
// DATA SHOWN
// ----------
//
// Current
// 1 Week
// 1 Month
// 3 Months
// 6 Months
// 1 Year
// 2 Years
// 3 Years
// 5 Years
// 10 Years
// 21-Day Z-Score
// Distance from approx. 30-week high
// Distance from 200-week moving average
//
// RANKING
// -------
//
// Each page is ranked from strongest to weakest.
//
// 1. Use 10-year percentage return where available.
// 2. If 10-year data is unavailable, use the 5-year return.
// 3. If neither 10Y nor 5Y exists, place the instrument at the bottom.
//
// The ranking basis is shown beside each instrument:
//
// #1 Gold [10Y]
// #2 Copper [10Y]
// #3 Iron [5Y]
//
// [5Y] means that a valid 10-year figure was not available.
//
//======================================================================


//======================================================================
// DASHBOARD SETTINGS
//======================================================================

dashboardPage = input.string(
     "Commodity Indices",
     "Dashboard Page",
     options=[
         "Commodity Indices",
         "Energy",
         "Metals",
         "Grains & Oilseeds",
         "Softs & Livestock",
         "Real Commodity / CPI"
     ],
     group="Dashboard",
     display=display.none
)

dashboardView = input.string(
     "Full",
     "Dashboard View",
     options=[
         "Full",
         "Momentum",
         "Long Term"
     ],
     group="Dashboard",
     display=display.none
)

showDashboard = input.bool(
     true,
     "Show Dashboard",
     group="Dashboard",
     display=display.none
)

showCheatSheet = input.bool(
     true,
     "Show Cheat Sheet",
     group="Dashboard",
     display=display.none
)


//======================================================================
// DISPLAY SETTINGS
//======================================================================

tablePositionInput = input.string(
     "Top Left",
     "Table Position",
     options=[
         "Top Left",
         "Top Center",
         "Top Right",
         "Middle Left",
         "Middle Center",
         "Middle Right",
         "Bottom Left",
         "Bottom Center",
         "Bottom Right"
     ],
     group="Display",
     display=display.none
)

fontInput = input.string(
     "Small",
     "Text Size",
     options=[
         "Tiny",
         "Small",
         "Normal",
         "Large"
     ],
     group="Display",
     display=display.none
)

neutralBand = input.float(
     1.0,
     "Neutral Return Band %",
     minval=0.0,
     step=0.25,
     group="Display",
     display=display.none
)


//======================================================================
// COMMODITY INDICES
//======================================================================

bcomSymbol = input.string(
     "BBG:BCOM",
     "Bloomberg Commodity Index",
     group="Commodity Indices",
     display=display.none
)

crbSymbol = input.string(
     "TVC:TRJEFFCRB",
     "CRB Index",
     group="Commodity Indices",
     display=display.none
)

gsciSymbol = input.string(
     "SPCFD:SPGSCI",
     "S&P GSCI",
     group="Commodity Indices",
     display=display.none
)

crspEnergySymbol = input.string(
     "NASDAQ:CRSPEN1",
     "CRSP Energy",
     group="Commodity Indices",
     display=display.none
)


//======================================================================
// ENERGY
//======================================================================

wtiSymbol = input.string(
     "TVC:USOIL",
     "WTI Crude",
     group="Energy",
     display=display.none
)

brentSymbol = input.string(
     "VELOCITY:BRENT",
     "Brent Crude",
     group="Energy",
     display=display.none
)

heatingOilSymbol = input.string(
     "IG:HEATINGOIL",
     "Heating Oil",
     group="Energy",
     display=display.none
)

gasoilSymbol = input.string(
     "VANTAGE:GASOIL",
     "Gasoil",
     group="Energy",
     display=display.none
)

gasolineSymbol = input.string(
     "PEPPERSTONE:GASOLINE",
     "Gasoline",
     group="Energy",
     display=display.none
)

natGasSymbol = input.string(
     "NYMEX:NG1!",
     "Henry Hub Natural Gas",
     group="Energy",
     display=display.none
)

ttfSymbol = input.string(
     "ICEEUR:TFN1!",
     "Dutch TTF Gas",
     group="Energy",
     display=display.none
)

nbpSymbol = input.string(
     "ICEEUR:GWM1!",
     "UK NBP Gas",
     group="Energy",
     display=display.none
)

carbonSymbol = input.string(
     "LSE:CARP",
     "Carbon",
     group="Energy",
     display=display.none
)


//======================================================================
// METALS
//======================================================================

goldSymbol = input.string(
     "TVC:GOLD",
     "Gold",
     group="Metals",
     display=display.none
)

silverSymbol = input.string(
     "TVC:SILVER",
     "Silver",
     group="Metals",
     display=display.none
)

platinumSymbol = input.string(
     "TVC:PLATINUM",
     "Platinum",
     group="Metals",
     display=display.none
)

palladiumSymbol = input.string(
     "NYMEX:PA1!",
     "Palladium",
     group="Metals",
     display=display.none
)

copperSymbol = input.string(
     "CAPITALCOM:XCUUSD",
     "Copper",
     group="Metals",
     display=display.none
)

aluminiumSymbol = input.string(
     "IG:ALUMINIUM",
     "Aluminium",
     group="Metals",
     display=display.none
)

ironSymbol = input.string(
     "IG:IRON",
     "Iron",
     group="Metals",
     display=display.none
)

zincSymbol = input.string(
     "IG:ZINC",
     "Zinc",
     group="Metals",
     display=display.none
)

leadSymbol = input.string(
     "LME:PB1!",
     "Lead",
     group="Metals",
     display=display.none
)

nickelSymbol = input.string(
     "CAPITALCOM:NICKEL",
     "Nickel",
     group="Metals",
     display=display.none
)

tsiSymbol = input.string(
     "CAPITALCOM:TSI",
     "TSI",
     group="Metals",
     display=display.none
)


//======================================================================
// GRAINS & OILSEEDS
//======================================================================

wheatSymbol = input.string(
     "CBOT:ZW1!",
     "Wheat",
     group="Grains & Oilseeds",
     display=display.none
)

cornSymbol = input.string(
     "CMCMARKETS:CORN",
     "Corn",
     group="Grains & Oilseeds",
     display=display.none
)

soybeanSymbol = input.string(
     "OANDA:SOYBNUSD",
     "Soybeans",
     group="Grains & Oilseeds",
     display=display.none
)

soybeanAltSymbol = input.string(
     "FOREXCOM:SOYUSD",
     "Soybeans Alternative",
     group="Grains & Oilseeds",
     display=display.none
)

soyMealSymbol = input.string(
     "CBOT:ZM1!",
     "Soybean Meal",
     group="Grains & Oilseeds",
     display=display.none
)

soyOilSymbol = input.string(
     "CMCMARKETS:SOYOIL",
     "Soybean Oil",
     group="Grains & Oilseeds",
     display=display.none
)

oatsSymbol = input.string(
     "CBOT:ZO1!",
     "Oats",
     group="Grains & Oilseeds",
     display=display.none
)

riceSymbol = input.string(
     "CBOT:ZR1!",
     "Rough Rice",
     group="Grains & Oilseeds",
     display=display.none
)

euroWheatSymbol = input.string(
     "ICEEUR:WHT1!",
     "European Wheat",
     group="Grains & Oilseeds",
     display=display.none
)


//======================================================================
// SOFTS & LIVESTOCK
//======================================================================

cocoaSymbol = input.string(
     "PEPPERSTONE:COCOA",
     "Cocoa",
     group="Softs & Livestock",
     display=display.none
)

coffeeSymbol = input.string(
     "CAPITALCOM:COFFEE",
     "Coffee",
     group="Softs & Livestock",
     display=display.none
)

robustaSymbol = input.string(
     "ICEEUR:RC1!",
     "Robusta Coffee",
     group="Softs & Livestock",
     display=display.none
)

sugarSymbol = input.string(
     "CAPITALCOM:SUGAR",
     "Sugar",
     group="Softs & Livestock",
     display=display.none
)

sugar5Symbol = input.string(
     "TRADENATION:SUGARNO5",
     "Sugar No. 5",
     group="Softs & Livestock",
     display=display.none
)

cottonSymbol = input.string(
     "FOREXCOM:COTTON",
     "Cotton",
     group="Softs & Livestock",
     display=display.none
)

orangeJuiceSymbol = input.string(
     "ICEUS:OJ1!",
     "Orange Juice",
     group="Softs & Livestock",
     display=display.none
)

cattleSymbol = input.string(
     "CME:LE1!",
     "Live Cattle",
     group="Softs & Livestock",
     display=display.none
)

leanHogsSymbol = input.string(
     "LSE:HOGS",
     "Lean Hogs",
     group="Softs & Livestock",
     display=display.none
)

lumberSymbol = input.string(
     "CME:LBR1!",
     "Lumber",
     group="Softs & Livestock",
     display=display.none
)


//======================================================================
// REAL COMMODITY / CPI
//======================================================================

realWTI = input.string(
     "TVC:USOIL/ECONOMICS:USCPI",
     "WTI / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realBrent = input.string(
     "BLACKBULL:BRENT/ECONOMICS:USCPI",
     "Brent / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realHeatingOil = input.string(
     "IG:HEATINGOIL/ECONOMICS:USCPI",
     "Heating Oil / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realGasoil = input.string(
     "VANTAGE:GASOIL/ECONOMICS:USCPI",
     "Gasoil / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realGasoline = input.string(
     "PEPPERSTONE:GASOLINE/ECONOMICS:USCPI",
     "Gasoline / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realNatGas = input.string(
     "NYMEX:NG1!/ECONOMICS:USCPI",
     "Natural Gas / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realTTF = input.string(
     "ICEEUR:TFN1!/ECONOMICS:USCPI",
     "TTF / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realNBP = input.string(
     "ICEEUR:GWM1!/ECONOMICS:USCPI",
     "NBP / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realCopper = input.string(
     "CAPITALCOM:XCUUSD/ECONOMICS:USCPI",
     "Copper / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realNickel = input.string(
     "CAPITALCOM:NICKEL/ECONOMICS:USCPI",
     "Nickel / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realCocoa = input.string(
     "PEPPERSTONE:COCOA/ECONOMICS:USCPI",
     "Cocoa / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realOJ = input.string(
     "ICEUS:OJ1!/ECONOMICS:USCPI",
     "Orange Juice / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realGold = input.string(
     "OANDA:XAUUSD/ECONOMICS:USCPI",
     "Gold / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realSilver = input.string(
     "OANDA:XAGUSD/ECONOMICS:USCPI",
     "Silver / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realBitcoin = input.string(
     "BITSTAMP:BTCUSD/ECONOMICS:USCPI",
     "Bitcoin / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realEthereum = input.string(
     "BITSTAMP:ETHUSD/ECONOMICS:USCPI",
     "Ethereum / CPI",
     group="Real Commodity / CPI",
     display=display.none
)

realXRP = input.string(
     "BITSTAMP:XRPUSD/ECONOMICS:USCPI",
     "XRP / CPI",
     group="Real Commodity / CPI",
     display=display.none
)


//======================================================================
// TABLE POSITION / FONT
//======================================================================

getPosition(string value) =>
    switch value
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_left


getFontSize(string value) =>
    switch value
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small


tablePosition = getPosition(tablePositionInput)
tableFont = getFontSize(fontInput)


//======================================================================
// COLOURS
//======================================================================

color titleColour  = color.rgb(30, 65, 95)
color headerColour = color.rgb(28, 28, 28)
color labelColour  = color.rgb(42, 42, 42)

color greenColour  = color.rgb(0, 115, 45)
color redColour    = color.rgb(150, 25, 35)
color yellowColour = color.rgb(150, 115, 0)
color orangeColour = color.rgb(185, 85, 10)
color blueColour   = color.rgb(25, 85, 165)
color greyColour   = color.rgb(65, 65, 65)

color textColour = color.white


//======================================================================
// FORMATTING
//======================================================================

fmtPrice(float value) =>
    na(value) ? "N/A" : str.tostring(value, "#,###.##")


fmtPct(float value) =>
    string result = "N/A"

    if not na(value)
        string sign = value > 0 ? "+" : ""
        result := sign + str.tostring(value, "#.1") + "%"

    result


fmtZ(float value) =>
    string result = "N/A"

    if not na(value)
        string sign = value > 0 ? "+" : ""
        result := sign + str.tostring(value, "#.00")

    result


//======================================================================
// COLOUR LOGIC
//======================================================================

performanceColour(float value) =>
    color result = greyColour

    if not na(value)
        if math.abs(value) <= neutralBand
            result := yellowColour
        else if value > 0
            result := greenColour
        else
            result := redColour

    result


zColour(float value) =>
    color result = greyColour

    if not na(value)
        float absoluteZ = math.abs(value)

        if absoluteZ < 1.0
            result := greenColour
        else if absoluteZ < 2.0
            result := yellowColour
        else if absoluteZ < 3.0
            result := orangeColour
        else
            result := redColour

    result


trendColour(float value) =>
    na(value) ?
         greyColour :
         value >= 0 ?
         greenColour :
         redColour


//======================================================================
// DAILY DATA REQUEST
//======================================================================

getDailyData(string symbol) =>

    request.security(
         symbol,
         "D",
         [
             close,

             (close / close[5] - 1.0) * 100.0,
             (close / close[21] - 1.0) * 100.0,
             (close / close[63] - 1.0) * 100.0,
             (close / close[126] - 1.0) * 100.0,
             (close / close[252] - 1.0) * 100.0,
             (close / close[504] - 1.0) * 100.0,
             (close / close[756] - 1.0) * 100.0,

             (
                 close -
                 ta.sma(close, 21)
             ) /
             ta.stdev(close, 21),

             (
                 close /
                 ta.highest(high, 150) -
                 1.0
             ) *
             100.0
         ],
         ignore_invalid_symbol=true,
         calc_bars_count=770
     )


//======================================================================
// WEEKLY DATA REQUEST
//======================================================================

getWeeklyData(string symbol) =>

    request.security(
         symbol,
         "W",
         [
             (close / close[260] - 1.0) * 100.0,

             (close / close[520] - 1.0) * 100.0,

             (
                 close /
                 ta.sma(close, 200) -
                 1.0
             ) *
             100.0
         ],
         ignore_invalid_symbol=true,
         calc_bars_count=530
     )


//======================================================================
// RANKING
//======================================================================

rankValue(
     float fiveYear,
     float tenYear
 ) =>

    float result = -1e20

    if not na(tenYear)
        result := tenYear
    else if not na(fiveYear)
        result := fiveYear

    result


rankBasis(
     float fiveYear,
     float tenYear
 ) =>

    string result = "N/A"

    if not na(tenYear)
        result := "10Y"
    else if not na(fiveYear)
        result := "5Y"

    result


//======================================================================
// TABLE
//======================================================================

TABLE_COLUMNS = 14
TABLE_ROWS = 22


var table dashboard =
     table.new(
         tablePosition,
         TABLE_COLUMNS,
         TABLE_ROWS,
         border_width=1
     )


//======================================================================
// DRAW CELL
//======================================================================

drawCell(
     int column,
     int row,
     string value,
     color background
 ) =>

    table.cell(
         dashboard,
         column,
         row,
         value,
         bgcolor=background,
         text_color=textColour,
         text_size=tableFont,
         text_halign=text.align_center
     )


//======================================================================
// TITLE
//======================================================================

drawTitle(string title) =>

    for column = 0 to TABLE_COLUMNS - 1

        drawCell(
             column,
             0,
             column == 0 ? title : "",
             titleColour
         )


//======================================================================
// HEADERS
//======================================================================

drawFullHeadings() =>

    drawCell(0, 1, "Rank / Commodity", headerColour)
    drawCell(1, 1, "Current", headerColour)
    drawCell(2, 1, "1W", headerColour)
    drawCell(3, 1, "1M", headerColour)
    drawCell(4, 1, "3M", headerColour)
    drawCell(5, 1, "6M", headerColour)
    drawCell(6, 1, "1Y", headerColour)
    drawCell(7, 1, "2Y", headerColour)
    drawCell(8, 1, "3Y", headerColour)
    drawCell(9, 1, "5Y", headerColour)
    drawCell(10, 1, "10Y", headerColour)
    drawCell(11, 1, "21D Z", headerColour)
    drawCell(12, 1, "Trend", headerColour)
    drawCell(13, 1, "Cheat Sheet", headerColour)


drawMomentumHeadings() =>

    drawCell(0, 1, "Rank / Commodity", headerColour)
    drawCell(1, 1, "Current", headerColour)
    drawCell(2, 1, "1W", headerColour)
    drawCell(3, 1, "1M", headerColour)
    drawCell(4, 1, "3M", headerColour)
    drawCell(5, 1, "6M", headerColour)
    drawCell(6, 1, "1Y", headerColour)
    drawCell(7, 1, "21D Z", headerColour)
    drawCell(8, 1, "30W High", headerColour)
    drawCell(9, 1, "200W MA", headerColour)

    for column = 10 to 12
        drawCell(column, 1, "", headerColour)

    drawCell(13, 1, "Cheat Sheet", headerColour)


drawLongTermHeadings() =>

    drawCell(0, 1, "Rank / Commodity", headerColour)
    drawCell(1, 1, "Current", headerColour)
    drawCell(2, 1, "1Y", headerColour)
    drawCell(3, 1, "2Y", headerColour)
    drawCell(4, 1, "3Y", headerColour)
    drawCell(5, 1, "5Y", headerColour)
    drawCell(6, 1, "10Y", headerColour)
    drawCell(7, 1, "200W MA", headerColour)

    for column = 8 to 12
        drawCell(column, 1, "", headerColour)

    drawCell(13, 1, "Cheat Sheet", headerColour)


drawHeadings() =>

    if dashboardView == "Full"
        drawFullHeadings()
    else if dashboardView == "Momentum"
        drawMomentumHeadings()
    else
        drawLongTermHeadings()


//======================================================================
// FULL ROW
//======================================================================

drawFullRow(
     int row,
     string rankedName,
     float current,
     float oneWeek,
     float oneMonth,
     float threeMonth,
     float sixMonth,
     float oneYear,
     float twoYear,
     float threeYear,
     float fiveYear,
     float tenYear,
     float zScore,
     float high30Week,
     float ma200Week,
     string cheat
 ) =>

    drawCell(0, row, rankedName, labelColour)
    drawCell(1, row, fmtPrice(current), greyColour)

    drawCell(2, row, fmtPct(oneWeek), performanceColour(oneWeek))
    drawCell(3, row, fmtPct(oneMonth), performanceColour(oneMonth))
    drawCell(4, row, fmtPct(threeMonth), performanceColour(threeMonth))
    drawCell(5, row, fmtPct(sixMonth), performanceColour(sixMonth))
    drawCell(6, row, fmtPct(oneYear), performanceColour(oneYear))
    drawCell(7, row, fmtPct(twoYear), performanceColour(twoYear))
    drawCell(8, row, fmtPct(threeYear), performanceColour(threeYear))
    drawCell(9, row, fmtPct(fiveYear), performanceColour(fiveYear))
    drawCell(10, row, fmtPct(tenYear), performanceColour(tenYear))

    drawCell(
         11,
         row,
         fmtZ(zScore),
         zColour(zScore)
     )

    drawCell(
         12,
         row,
         "30W " +
         fmtPct(high30Week) +
         "\n200W " +
         fmtPct(ma200Week),
         trendColour(ma200Week)
     )

    drawCell(
         13,
         row,
         showCheatSheet ? cheat : "",
         greyColour
     )


//======================================================================
// MOMENTUM ROW
//======================================================================

drawMomentumRow(
     int row,
     string rankedName,
     float current,
     float oneWeek,
     float oneMonth,
     float threeMonth,
     float sixMonth,
     float oneYear,
     float zScore,
     float high30Week,
     float ma200Week,
     string cheat
 ) =>

    drawCell(0, row, rankedName, labelColour)
    drawCell(1, row, fmtPrice(current), greyColour)

    drawCell(2, row, fmtPct(oneWeek), performanceColour(oneWeek))
    drawCell(3, row, fmtPct(oneMonth), performanceColour(oneMonth))
    drawCell(4, row, fmtPct(threeMonth), performanceColour(threeMonth))
    drawCell(5, row, fmtPct(sixMonth), performanceColour(sixMonth))
    drawCell(6, row, fmtPct(oneYear), performanceColour(oneYear))

    drawCell(
         7,
         row,
         fmtZ(zScore),
         zColour(zScore)
     )

    drawCell(
         8,
         row,
         fmtPct(high30Week),
         blueColour
     )

    drawCell(
         9,
         row,
         fmtPct(ma200Week),
         trendColour(ma200Week)
     )

    for column = 10 to 12
        drawCell(column, row, "", greyColour)

    drawCell(
         13,
         row,
         showCheatSheet ? cheat : "",
         greyColour
     )


//======================================================================
// LONG-TERM ROW
//======================================================================

drawLongTermRow(
     int row,
     string rankedName,
     float current,
     float oneYear,
     float twoYear,
     float threeYear,
     float fiveYear,
     float tenYear,
     float ma200Week,
     string cheat
 ) =>

    drawCell(0, row, rankedName, labelColour)
    drawCell(1, row, fmtPrice(current), greyColour)

    drawCell(2, row, fmtPct(oneYear), performanceColour(oneYear))
    drawCell(3, row, fmtPct(twoYear), performanceColour(twoYear))
    drawCell(4, row, fmtPct(threeYear), performanceColour(threeYear))
    drawCell(5, row, fmtPct(fiveYear), performanceColour(fiveYear))
    drawCell(6, row, fmtPct(tenYear), performanceColour(tenYear))

    drawCell(
         7,
         row,
         fmtPct(ma200Week),
         trendColour(ma200Week)
     )

    for column = 8 to 12
        drawCell(column, row, "", greyColour)

    drawCell(
         13,
         row,
         showCheatSheet ? cheat : "",
         greyColour
     )


//======================================================================
// PAGE DEFINITION ARRAYS
//======================================================================

var array<string> pageNames =
     array.new_string()

var array<string> pageSymbols =
     array.new_string()

var array<string> pageCheats =
     array.new_string()


addInstrument(
     string name,
     string symbol,
     string cheat
 ) =>

    array.push(pageNames, name)
    array.push(pageSymbols, symbol)
    array.push(pageCheats, cheat)


//======================================================================
// RESET PAGE DEFINITION
//======================================================================

array.clear(pageNames)
array.clear(pageSymbols)
array.clear(pageCheats)


//======================================================================
// COMMODITY INDICES PAGE
//======================================================================

if dashboardPage == "Commodity Indices"

    addInstrument(
         "Bloomberg Commodity",
         bcomSymbol,
         "Broad diversified commodity benchmark."
     )

    addInstrument(
         "CRB",
         crbSymbol,
         "Broad commodity benchmark useful for identifying long commodity cycles."
     )

    addInstrument(
         "S&P GSCI",
         gsciSymbol,
         "Broad commodity benchmark with substantial energy exposure."
     )

    addInstrument(
         "CRSP Energy",
         crspEnergySymbol,
         "Energy-market benchmark."
     )


//======================================================================
// ENERGY PAGE
//======================================================================

else if dashboardPage == "Energy"

    addInstrument(
         "WTI Crude",
         wtiSymbol,
         "Major U.S. crude-oil benchmark. TVC:USOIL is used for longer historical coverage."
     )

    addInstrument(
         "Brent Crude",
         brentSymbol,
         "Major international crude-oil benchmark."
     )

    addInstrument(
         "Heating Oil",
         heatingOilSymbol,
         "Refined petroleum distillate."
     )

    addInstrument(
         "Gasoil",
         gasoilSymbol,
         "European distillate-energy benchmark."
     )

    addInstrument(
         "Gasoline",
         gasolineSymbol,
         "Refined fuel affected by crude prices, refining margins and demand."
     )

    addInstrument(
         "Henry Hub Gas",
         natGasSymbol,
         "U.S. natural-gas benchmark; sensitive to weather, inventories and production."
     )

    addInstrument(
         "Dutch TTF Gas",
         ttfSymbol,
         "Major European natural-gas benchmark."
     )

    addInstrument(
         "UK NBP Gas",
         nbpSymbol,
         "Important UK natural-gas benchmark."
     )

    addInstrument(
         "Carbon",
         carbonSymbol,
         "Carbon-market exposure using LSE:CARP."
     )


//======================================================================
// METALS PAGE
//======================================================================

else if dashboardPage == "Metals"

    addInstrument(
         "Gold",
         goldSymbol,
         "Monetary and precious metal influenced by real rates, currencies and investment demand."
     )

    addInstrument(
         "Silver",
         silverSymbol,
         "Precious and industrial metal; normally more volatile than gold."
     )

    addInstrument(
         "Platinum",
         platinumSymbol,
         "Precious and industrial metal with important automotive demand."
     )

    addInstrument(
         "Palladium",
         palladiumSymbol,
         "Platinum-group metal sensitive to automotive demand and concentrated supply."
     )

    addInstrument(
         "Copper",
         copperSymbol,
         "Major industrial metal often monitored for global cyclical demand."
     )

    addInstrument(
         "Aluminium",
         aluminiumSymbol,
         "Industrial metal with strong energy and manufacturing sensitivity."
     )

    addInstrument(
         "Iron",
         ironSymbol,
         "Important bulk commodity closely linked to steel production and construction."
     )

    addInstrument(
         "Zinc",
         zincSymbol,
         "Industrial metal widely used for galvanising steel."
     )

    addInstrument(
         "Lead",
         leadSymbol,
         "Industrial metal strongly associated with battery demand."
     )

    addInstrument(
         "Nickel",
         nickelSymbol,
         "Industrial metal used in stainless steel and some battery chemistries."
     )

    addInstrument(
         "TSI",
         tsiSymbol,
         "TSI market feed from the original commodity list."
     )


//======================================================================
// GRAINS & OILSEEDS PAGE
//======================================================================

else if dashboardPage == "Grains & Oilseeds"

    addInstrument(
         "Wheat",
         wheatSymbol,
         "Major global grain affected by weather, harvests, inventories and trade flows."
     )

    addInstrument(
         "Corn",
         cornSymbol,
         "Major grain used for food, animal feed and ethanol."
     )

    addInstrument(
         "Soybeans",
         soybeanSymbol,
         "Major oilseed sensitive to weather, China demand and South American production."
     )

    addInstrument(
         "Soybeans Alt",
         soybeanAltSymbol,
         "Alternative soybean market feed."
     )

    addInstrument(
         "Soybean Meal",
         soyMealSymbol,
         "Protein-rich soybean product important to animal-feed markets."
     )

    addInstrument(
         "Soybean Oil",
         soyOilSymbol,
         "Vegetable oil influenced by food demand and biofuel markets."
     )

    addInstrument(
         "Oats",
         oatsSymbol,
         "Smaller grain market that can experience substantial supply-driven volatility."
     )

    addInstrument(
         "Rough Rice",
         riceSymbol,
         "Rice benchmark sensitive to crop supply, weather and global food demand."
     )

    addInstrument(
         "European Wheat",
         euroWheatSymbol,
         "European wheat benchmark."
     )


//======================================================================
// SOFTS & LIVESTOCK PAGE
//======================================================================

else if dashboardPage == "Softs & Livestock"

    addInstrument(
         "Cocoa",
         cocoaSymbol,
         "Highly weather- and supply-sensitive soft commodity."
     )

    addInstrument(
         "Coffee",
         coffeeSymbol,
         "Sensitive to weather and crop conditions in major producing countries."
     )

    addInstrument(
         "Robusta Coffee",
         robustaSymbol,
         "Robusta coffee benchmark."
     )

    addInstrument(
         "Sugar",
         sugarSymbol,
         "Affected by crop conditions, ethanol economics and major producer output."
     )

    addInstrument(
         "Sugar No. 5",
         sugar5Symbol,
         "Alternative sugar benchmark."
     )

    addInstrument(
         "Cotton",
         cottonSymbol,
         "Agricultural and textile-market input."
     )

    addInstrument(
         "Orange Juice",
         orangeJuiceSymbol,
         "Highly weather- and crop-sensitive agricultural market."
     )

    addInstrument(
         "Live Cattle",
         cattleSymbol,
         "CME continuous live-cattle futures."
     )

    addInstrument(
         "Lean Hogs",
         leanHogsSymbol,
         "Hog-market exposure sensitive to herd cycles, feed costs and pork demand."
     )

    addInstrument(
         "Lumber",
         lumberSymbol,
         "Construction-sensitive commodity linked to housing and building activity."
     )


//======================================================================
// REAL COMMODITY / CPI PAGE
//======================================================================

else if dashboardPage == "Real Commodity / CPI"

    addInstrument(
         "WTI / CPI",
         realWTI,
         "WTI relative to U.S. consumer prices."
     )

    addInstrument(
         "Brent / CPI",
         realBrent,
         "Brent crude relative to U.S. consumer prices."
     )

    addInstrument(
         "Heating Oil / CPI",
         realHeatingOil,
         "Heating-oil price relative to U.S. CPI."
     )

    addInstrument(
         "Gasoil / CPI",
         realGasoil,
         "Gasoil price relative to U.S. CPI."
     )

    addInstrument(
         "Gasoline / CPI",
         realGasoline,
         "Gasoline price relative to U.S. CPI."
     )

    addInstrument(
         "Natural Gas / CPI",
         realNatGas,
         "U.S. natural-gas price relative to U.S. CPI."
     )

    addInstrument(
         "TTF / CPI",
         realTTF,
         "Dutch TTF gas relative to U.S. CPI."
     )

    addInstrument(
         "NBP / CPI",
         realNBP,
         "UK NBP gas relative to U.S. CPI."
     )

    addInstrument(
         "Copper / CPI",
         realCopper,
         "Copper price relative to U.S. CPI."
     )

    addInstrument(
         "Nickel / CPI",
         realNickel,
         "Nickel price relative to U.S. CPI."
     )

    addInstrument(
         "Cocoa / CPI",
         realCocoa,
         "Cocoa price relative to U.S. CPI."
     )

    addInstrument(
         "Orange Juice / CPI",
         realOJ,
         "Orange-juice price relative to U.S. CPI."
     )

    addInstrument(
         "Gold / CPI",
         realGold,
         "Gold relative to U.S. consumer prices."
     )

    addInstrument(
         "Silver / CPI",
         realSilver,
         "Silver relative to U.S. consumer prices."
     )

    addInstrument(
         "Bitcoin / CPI",
         realBitcoin,
         "Bitcoin relative to U.S. consumer prices."
     )

    addInstrument(
         "Ethereum / CPI",
         realEthereum,
         "Ethereum relative to U.S. consumer prices."
     )

    addInstrument(
         "XRP / CPI",
         realXRP,
         "XRP relative to U.S. consumer prices."
     )


//======================================================================
// RESULT ARRAYS
//======================================================================

var array<string> resultNames =
     array.new_string()

var array<string> resultCheats =
     array.new_string()

var array<string> resultBasis =
     array.new_string()


var array<float> resultCurrent =
     array.new_float()

var array<float> result1W =
     array.new_float()

var array<float> result1M =
     array.new_float()

var array<float> result3M =
     array.new_float()

var array<float> result6M =
     array.new_float()

var array<float> result1Y =
     array.new_float()

var array<float> result2Y =
     array.new_float()

var array<float> result3Y =
     array.new_float()

var array<float> result5Y =
     array.new_float()

var array<float> result10Y =
     array.new_float()

var array<float> resultZ =
     array.new_float()

var array<float> result30W =
     array.new_float()

var array<float> result200W =
     array.new_float()

var array<float> resultRank =
     array.new_float()


//======================================================================
// CLEAR RESULTS
//======================================================================

array.clear(resultNames)
array.clear(resultCheats)
array.clear(resultBasis)

array.clear(resultCurrent)
array.clear(result1W)
array.clear(result1M)
array.clear(result3M)
array.clear(result6M)
array.clear(result1Y)
array.clear(result2Y)
array.clear(result3Y)
array.clear(result5Y)
array.clear(result10Y)
array.clear(resultZ)
array.clear(result30W)
array.clear(result200W)
array.clear(resultRank)


//======================================================================
// FETCH ACTIVE PAGE
//======================================================================

if array.size(pageSymbols) > 0

    for index = 0 to array.size(pageSymbols) - 1

        string selectedSymbol =
             array.get(
                  pageSymbols,
                  index
             )

        string selectedName =
             array.get(
                  pageNames,
                  index
             )

        string selectedCheat =
             array.get(
                  pageCheats,
                  index
             )


        [
             current,
             oneWeek,
             oneMonth,
             threeMonth,
             sixMonth,
             oneYear,
             twoYear,
             threeYear,
             zScore,
             high30Week
         ] =
             getDailyData(
                  selectedSymbol
             )


        [
             fiveYear,
             tenYear,
             ma200Week
         ] =
             getWeeklyData(
                  selectedSymbol
             )


        float ranking =
             rankValue(
                  fiveYear,
                  tenYear
             )


        string basis =
             rankBasis(
                  fiveYear,
                  tenYear
             )


        array.push(resultNames, selectedName)
        array.push(resultCheats, selectedCheat)
        array.push(resultBasis, basis)

        array.push(resultCurrent, current)
        array.push(result1W, oneWeek)
        array.push(result1M, oneMonth)
        array.push(result3M, threeMonth)
        array.push(result6M, sixMonth)
        array.push(result1Y, oneYear)
        array.push(result2Y, twoYear)
        array.push(result3Y, threeYear)
        array.push(result5Y, fiveYear)
        array.push(result10Y, tenYear)
        array.push(resultZ, zScore)
        array.push(result30W, high30Week)
        array.push(result200W, ma200Week)
        array.push(resultRank, ranking)


//======================================================================
// SORT RESULTS
//======================================================================
//
// Pine Script does NOT provide array.swap().
//
// Therefore all values are exchanged manually using:
//
// array.get()
// array.set()
//
// This keeps all fields belonging to an instrument together.
//
//======================================================================

int resultCount =
     array.size(resultRank)


if resultCount > 1

    for outer = 0 to resultCount - 2

        for inner = 0 to resultCount - outer - 2

            int leftIndex =
                 inner

            int rightIndex =
                 inner + 1


            float leftValue =
                 array.get(
                      resultRank,
                      leftIndex
                 )

            float rightValue =
                 array.get(
                      resultRank,
                      rightIndex
                 )


            if rightValue > leftValue

                //------------------------------------------------------
                // NAME
                //------------------------------------------------------

                string tempName =
                     array.get(
                          resultNames,
                          leftIndex
                     )

                array.set(
                     resultNames,
                     leftIndex,
                     array.get(
                          resultNames,
                          rightIndex
                     )
                )

                array.set(
                     resultNames,
                     rightIndex,
                     tempName
                )


                //------------------------------------------------------
                // CHEAT SHEET
                //------------------------------------------------------

                string tempCheat =
                     array.get(
                          resultCheats,
                          leftIndex
                     )

                array.set(
                     resultCheats,
                     leftIndex,
                     array.get(
                          resultCheats,
                          rightIndex
                     )
                )

                array.set(
                     resultCheats,
                     rightIndex,
                     tempCheat
                )


                //------------------------------------------------------
                // RANK BASIS
                //------------------------------------------------------

                string tempBasis =
                     array.get(
                          resultBasis,
                          leftIndex
                     )

                array.set(
                     resultBasis,
                     leftIndex,
                     array.get(
                          resultBasis,
                          rightIndex
                     )
                )

                array.set(
                     resultBasis,
                     rightIndex,
                     tempBasis
                )


                //------------------------------------------------------
                // CURRENT
                //------------------------------------------------------

                float tempCurrent =
                     array.get(
                          resultCurrent,
                          leftIndex
                     )

                array.set(
                     resultCurrent,
                     leftIndex,
                     array.get(
                          resultCurrent,
                          rightIndex
                     )
                )

                array.set(
                     resultCurrent,
                     rightIndex,
                     tempCurrent
                )


                //------------------------------------------------------
                // 1 WEEK
                //------------------------------------------------------

                float temp1W =
                     array.get(
                          result1W,
                          leftIndex
                     )

                array.set(
                     result1W,
                     leftIndex,
                     array.get(
                          result1W,
                          rightIndex
                     )
                )

                array.set(
                     result1W,
                     rightIndex,
                     temp1W
                )


                //------------------------------------------------------
                // 1 MONTH
                //------------------------------------------------------

                float temp1M =
                     array.get(
                          result1M,
                          leftIndex
                     )

                array.set(
                     result1M,
                     leftIndex,
                     array.get(
                          result1M,
                          rightIndex
                     )
                )

                array.set(
                     result1M,
                     rightIndex,
                     temp1M
                )


                //------------------------------------------------------
                // 3 MONTH
                //------------------------------------------------------

                float temp3M =
                     array.get(
                          result3M,
                          leftIndex
                     )

                array.set(
                     result3M,
                     leftIndex,
                     array.get(
                          result3M,
                          rightIndex
                     )
                )

                array.set(
                     result3M,
                     rightIndex,
                     temp3M
                )


                //------------------------------------------------------
                // 6 MONTH
                //------------------------------------------------------

                float temp6M =
                     array.get(
                          result6M,
                          leftIndex
                     )

                array.set(
                     result6M,
                     leftIndex,
                     array.get(
                          result6M,
                          rightIndex
                     )
                )

                array.set(
                     result6M,
                     rightIndex,
                     temp6M
                )


                //------------------------------------------------------
                // 1 YEAR
                //------------------------------------------------------

                float temp1Y =
                     array.get(
                          result1Y,
                          leftIndex
                     )

                array.set(
                     result1Y,
                     leftIndex,
                     array.get(
                          result1Y,
                          rightIndex
                     )
                )

                array.set(
                     result1Y,
                     rightIndex,
                     temp1Y
                )


                //------------------------------------------------------
                // 2 YEAR
                //------------------------------------------------------

                float temp2Y =
                     array.get(
                          result2Y,
                          leftIndex
                     )

                array.set(
                     result2Y,
                     leftIndex,
                     array.get(
                          result2Y,
                          rightIndex
                     )
                )

                array.set(
                     result2Y,
                     rightIndex,
                     temp2Y
                )


                //------------------------------------------------------
                // 3 YEAR
                //------------------------------------------------------

                float temp3Y =
                     array.get(
                          result3Y,
                          leftIndex
                     )

                array.set(
                     result3Y,
                     leftIndex,
                     array.get(
                          result3Y,
                          rightIndex
                     )
                )

                array.set(
                     result3Y,
                     rightIndex,
                     temp3Y
                )


                //------------------------------------------------------
                // 5 YEAR
                //------------------------------------------------------

                float temp5Y =
                     array.get(
                          result5Y,
                          leftIndex
                     )

                array.set(
                     result5Y,
                     leftIndex,
                     array.get(
                          result5Y,
                          rightIndex
                     )
                )

                array.set(
                     result5Y,
                     rightIndex,
                     temp5Y
                )


                //------------------------------------------------------
                // 10 YEAR
                //------------------------------------------------------

                float temp10Y =
                     array.get(
                          result10Y,
                          leftIndex
                     )

                array.set(
                     result10Y,
                     leftIndex,
                     array.get(
                          result10Y,
                          rightIndex
                     )
                )

                array.set(
                     result10Y,
                     rightIndex,
                     temp10Y
                )


                //------------------------------------------------------
                // Z SCORE
                //------------------------------------------------------

                float tempZ =
                     array.get(
                          resultZ,
                          leftIndex
                     )

                array.set(
                     resultZ,
                     leftIndex,
                     array.get(
                          resultZ,
                          rightIndex
                     )
                )

                array.set(
                     resultZ,
                     rightIndex,
                     tempZ
                )


                //------------------------------------------------------
                // 30 WEEK HIGH
                //------------------------------------------------------

                float temp30W =
                     array.get(
                          result30W,
                          leftIndex
                     )

                array.set(
                     result30W,
                     leftIndex,
                     array.get(
                          result30W,
                          rightIndex
                     )
                )

                array.set(
                     result30W,
                     rightIndex,
                     temp30W
                )


                //------------------------------------------------------
                // 200 WEEK MA
                //------------------------------------------------------

                float temp200W =
                     array.get(
                          result200W,
                          leftIndex
                     )

                array.set(
                     result200W,
                     leftIndex,
                     array.get(
                          result200W,
                          rightIndex
                     )
                )

                array.set(
                     result200W,
                     rightIndex,
                     temp200W
                )


                //------------------------------------------------------
                // RANKING VALUE
                //------------------------------------------------------

                float tempRank =
                     array.get(
                          resultRank,
                          leftIndex
                     )

                array.set(
                     resultRank,
                     leftIndex,
                     array.get(
                          resultRank,
                          rightIndex
                     )
                )

                array.set(
                     resultRank,
                     rightIndex,
                     tempRank
                )


//======================================================================
// CLEAR TABLE
//======================================================================

if barstate.islast

    table.clear(
         dashboard,
         0,
         0,
         TABLE_COLUMNS - 1,
         TABLE_ROWS - 1
     )


//======================================================================
// DRAW SORTED TABLE
//======================================================================

if barstate.islast and
   showDashboard and
   resultCount > 0

    drawTitle(
         dashboardPage
     )

    drawHeadings()


    for index = 0 to resultCount - 1

        int rankNumber =
             index + 1

        int tableRow =
             index + 2


        string name =
             array.get(
                  resultNames,
                  index
             )

        string basis =
             array.get(
                  resultBasis,
                  index
             )

        string cheat =
             array.get(
                  resultCheats,
                  index
             )


        string rankedName =
             "#" +
             str.tostring(rankNumber) +
             " " +
             name +
             " [" +
             basis +
             "]"


        float current =
             array.get(
                  resultCurrent,
                  index
             )

        float oneWeek =
             array.get(
                  result1W,
                  index
             )

        float oneMonth =
             array.get(
                  result1M,
                  index
             )

        float threeMonth =
             array.get(
                  result3M,
                  index
             )

        float sixMonth =
             array.get(
                  result6M,
                  index
             )

        float oneYear =
             array.get(
                  result1Y,
                  index
             )

        float twoYear =
             array.get(
                  result2Y,
                  index
             )

        float threeYear =
             array.get(
                  result3Y,
                  index
             )

        float fiveYear =
             array.get(
                  result5Y,
                  index
             )

        float tenYear =
             array.get(
                  result10Y,
                  index
             )

        float zScore =
             array.get(
                  resultZ,
                  index
             )

        float high30Week =
             array.get(
                  result30W,
                  index
             )

        float ma200Week =
             array.get(
                  result200W,
                  index
             )


        //--------------------------------------------------------------
        // FULL VIEW
        //--------------------------------------------------------------

        if dashboardView == "Full"

            drawFullRow(
                 tableRow,
                 rankedName,
                 current,
                 oneWeek,
                 oneMonth,
                 threeMonth,
                 sixMonth,
                 oneYear,
                 twoYear,
                 threeYear,
                 fiveYear,
                 tenYear,
                 zScore,
                 high30Week,
                 ma200Week,
                 cheat
             )


        //--------------------------------------------------------------
        // MOMENTUM VIEW
        //--------------------------------------------------------------

        else if dashboardView == "Momentum"

            drawMomentumRow(
                 tableRow,
                 rankedName,
                 current,
                 oneWeek,
                 oneMonth,
                 threeMonth,
                 sixMonth,
                 oneYear,
                 zScore,
                 high30Week,
                 ma200Week,
                 cheat
             )


        //--------------------------------------------------------------
        // LONG TERM VIEW
        //--------------------------------------------------------------

        else

            drawLongTermRow(
                 tableRow,
                 rankedName,
                 current,
                 oneYear,
                 twoYear,
                 threeYear,
                 fiveYear,
                 tenYear,
                 ma200Week,
                 cheat
             )


//======================================================================
// HIDE DASHBOARD
//======================================================================

if barstate.islast and
   not showDashboard

    table.clear(
         dashboard,
         0,
         0,
         TABLE_COLUMNS - 1,
         TABLE_ROWS - 1
     )


//======================================================================
// END
//======================================================================
````
