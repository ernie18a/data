# Market Risk Dashboard with Cheat Sheet

- url: https://www.tradingview.com/script/IYRfZ5M8-Market-Risk-Dashboard-with-Cheat-Sheet/
- type: indicator
- pine_id: PUB;38a6937805d14a8fba3516f35bf8cbff
- version: 1.0

## Description

To help build a top down perspective of the God Markets necessary to identity Triangle breakouts and get the direction of the breakout correct on balance of probability you need to understand this because its the single biggest factor of your financial success regardless of which ever method you choose to use

You make your own luck which can be the output of a prepared mind that puts the work in, plus a little bit of destiny and manifestation. Reach out and follow for more insight and build the life you want for you and your family.

William Playfair was the inventor of charts, being the first documented person in our taught history to have the invention of charts attributed to him, bringing attending to this great person. 

Market Internals, Macro & Cross-Asset Dashboard

This indicator is a multi-page market dashboard designed to help users understand what is happening underneath the headline price action.

Rather than relying on a single indicator, it combines equity breadth, major U.S. indices, volatility, Treasury yields, yield-curve structure, credit markets, commodities, the U.S. dollar and cross-asset relative performance.

The aim is to help answer questions such as:

Is an index rally supported by broad participation?
Are fewer stocks participating even though the headline index is rising?
Is an index statistically stretched?
Is volatility rising across equities or bonds?
Is the U.S. Treasury yield curve inverted, steepening or flattening?
Are credit markets confirming or contradicting equity strength?
Are commodities suggesting stronger cyclical demand or greater defensive positioning?
Which major asset classes are gaining or losing relative strength?

The indicator does not attempt to generate a single automatic Buy or Sell signal. It is intended as a market-analysis framework that lets the user compare several independent areas of the financial system.

Dashboard pages

The indicator is divided into pages to keep the information readable and to reduce TradingView data-request usage.

Overview shows the current level and one-week performance of major U.S. indices including the S&P 500, Nasdaq 100, Dow Jones, Russell 2000, Nasdaq Composite, NYSE Composite, S&P MidCap 400 and S&P SmallCap 600.

Equity Breadth examines how many stocks are participating in the market trend using the percentage of constituents above their 20-day, 50-day, 100-day and 200-day moving averages. It also compares current breadth with approximately one week earlier and highlights simple price/breadth divergences.

Index Trend shows each major index alongside its one-week return, 21-day Z-score, distance from its 30-week high and distance from its 200-week moving average.

Intraday Internals examines NYSE and Nasdaq TICK, Advance/Decline, volume breadth and TRIN. These are particularly useful during U.S. market hours.

Volatility tracks VIX, VXN, three-month VIX and MOVE, together with statistical extension and volatility term structure.

Bonds & Credit examines Treasury yields from 3 months through 30 years, yield-curve inversion, real yields, inflation expectations, credit spreads and bond-market relative strength.

Commodities tracks Gold, Silver, Copper, WTI, Brent, Natural Gas, a broad commodity index and the U.S. Dollar Index, together with several useful relative-value ratios.

Relative Performance compares equities, bonds, commodities, the dollar and Bitcoin over 1-week, 1-month, 3-month and 6-month periods.

Understanding the colours

Green generally means strengthening or improving.

Red generally means weakening, deterioration or greater market stress.

Yellow indicates a relatively neutral, flat or unchanged condition.

Orange highlights an elevated statistical condition or a divergence that deserves attention.

Blue is used mainly for reference measurements such as distance from a long-term high or moving average.

Grey represents neutral information or unavailable data.

The colours are intended to make large amounts of market information easier to read. They should not be interpreted as automatic trading signals.

Equity Breadth

Breadth asks a simple but important question:

How many stocks are actually participating in the market move?

An index can rise even when many of its underlying stocks are falling, particularly when a small number of very large companies dominate the index.

% above the 20-day moving average

A short-term breadth measure.

For example:

75%

means roughly 75% of the constituents represented by the breadth feed are trading above their 20-day moving averages.

A rising number means short-term participation is expanding.

A falling number means participation is narrowing.

If an index rises while its 20-day breadth falls, the advance may be becoming more concentrated.

% above the 50-day moving average

A useful intermediate breadth measure.

Above 50% means a majority of constituents are above their 50-day averages.

Below 50% means a majority are below them.

% above the 100-day moving average

Provides a medium-term view of participation.

Persistent deterioration may indicate that weakness is spreading beyond short-term fluctuations.

% above the 200-day moving average

A long-term breadth measure.

High readings mean a large part of the market remains in long-term uptrends.

A reading below 50% means fewer than half of the represented constituents are above their 200-day moving averages.

Weekly breadth change

The second number in a breadth cell shows how much the reading has changed from approximately one trading week earlier.

Example:

61%
-8 pts

means breadth is currently 61% and has fallen about eight percentage points from the previous week.

Price/Breadth Divergence

The dashboard can highlight:

PRICE UP / BREADTH DOWN

The index has risen while participation has weakened.

Or:

PRICE DOWN / BREADTH UP

The index has fallen while participation has improved.

A divergence is something to investigate. It is not automatically a reversal signal.

Z-Score

The 21-day Z-score measures how far the current price is from its recent average in units of standard deviation.

A positive value means price is above its recent average.

A negative value means price is below it.

As a rough guide:

-1 to +1      Relatively normal
+1 to +2      Elevated
+2 to +3      Stretched
Above +3      Unusually extended

-1 to -2      Elevated downside deviation
-2 to -3      Stretched downside
Below -3      Unusually extended

A high Z-score does not automatically mean an asset should fall.

A low Z-score does not automatically mean it should rise.

Strong trends can remain statistically extended for a considerable period.

The Z-score measures how unusual the current position is, not when a reversal must occur.

30-Week and 200-Week Measures
Distance from 30-week high

Shows how far the current value is below its highest level over approximately 30 weeks.

Example:

-3.5%

means the asset is about 3.5% below its 30-week high.

Distance from 200-week moving average

Shows the asset's position relative to a very long-term trend measure.

Positive means price is above the 200-week average.

Negative means it is below.

A large positive value can indicate strong long-term momentum, although it can also mean the asset is unusually far from its long-term trend.

Intraday Market Internals

These indicators are particularly useful during U.S. market hours.

TICK

Measures the number of stocks trading on an uptick minus those trading on a downtick.

Positive TICK means more stocks are ticking upward.

Negative TICK means more stocks are ticking downward.

Extreme readings can indicate unusually strong short-term buying or selling pressure.

ADD — Advance/Decline Difference

Measures advancing stocks minus declining stocks.

Positive means more stocks are advancing.

Negative means more stocks are declining.

If an index rises strongly while ADD remains weak, participation may be narrow.

VOLD

Measures advancing volume minus declining volume.

Positive means more volume is flowing through advancing stocks.

Negative means declining volume dominates.

TRIN — Arms Index

TRIN combines advancing and declining issues with their respective volume.

Around 1 is broadly balanced.

Above 1 generally indicates proportionally heavier volume in declining stocks.

Below 1 generally indicates relatively stronger volume in advancing stocks.

TRIN is best interpreted together with TICK, ADD and VOLD.

Volatility
VIX

Measures option-implied volatility for the S&P 500.

A rapidly rising VIX generally indicates increasing equity-market uncertainty or stress.

A falling VIX generally indicates declining expected volatility.

The change in VIX can sometimes be more informative than its absolute level.

VXN

The Nasdaq-100 volatility index.

Useful for comparing volatility in growth and technology stocks with the broader market.

VIX3M

Represents approximately three-month S&P 500 implied volatility.

Comparing VIX with VIX3M helps analyse volatility term structure.

VIX / VIX3M

Below 1 generally means short-term volatility is below three-month volatility.

Above 1 means short-dated volatility has moved above three-month volatility, which can occur during periods of near-term market stress.

MOVE

Measures implied volatility in the U.S. Treasury market.

It is sometimes described as the bond market's equivalent of VIX.

A sharp rise in MOVE indicates increasing uncertainty in interest rates and the Treasury market.

Treasury Yields and Yield Curve

The Bonds & Credit page tracks:

3-Month Treasury
2-Year Treasury
5-Year Treasury
10-Year Treasury
30-Year Treasury

This lets the dashboard examine the shape of the U.S. yield curve.

10Y − 3M

A widely followed curve spread.

If it is negative, the 3-month yield is above the 10-year yield.

10Y − 2Y

Another widely followed inversion measure.

Negative means the 2-year yield is above the 10-year yield.

30Y − 2Y

Compares a policy-sensitive shorter maturity with the long end of the Treasury curve.

30Y − 10Y

Shows the shape of the long end of the curve.

Curve status

The dashboard classifies each spread as:

INVERTED — the longer maturity yields less than the shorter maturity.

FLAT — the spread is positive but relatively small.

POSITIVE — the longer maturity yields more than the shorter maturity.

Inversion Direction

The dashboard also distinguishes whether an inversion is changing.

Example:

10Y - 2Y = -50 bp

If it was previously -80 bp, the inversion has become less negative.

The dashboard describes this as:

INVERTED / NORMALISING

If the spread moves from -20 bp to -50 bp, the inversion has become more pronounced:

INVERTED / DEEPENING

This distinction is important because simply knowing that the curve is inverted does not show how the curve is changing.

Bull and Bear Steepeners / Flatteners

The dashboard also attempts to classify the movement of key curve relationships.

Bull Steepener

Short-term yields fall faster than long-term yields.

The curve becomes steeper while yields are generally falling.

Bear Steepener

Long-term yields rise faster than short-term yields.

The curve becomes steeper while yields are generally rising.

Bull Flattener

Long-term yields fall faster than short-term yields.

The curve becomes flatter while rates are falling.

Bear Flattener

Short-term yields rise faster than long-term yields.

The curve becomes flatter while rates are rising.

These descriptions explain how the curve is moving, rather than declaring whether the move is good or bad for markets.

10-Year Real Yield

The real yield is the inflation-adjusted Treasury yield.

Rising real yields increase the real return available from bonds and raise the discount rate applied to financial assets.

They can be particularly relevant to:

growth equities
long-duration bonds
gold
other duration-sensitive assets
10-Year Breakeven Inflation

Represents the market-implied average inflation rate over approximately the next ten years.

Rising breakevens indicate increasing market-implied inflation expectations.

Falling breakevens indicate declining inflation expectations.

High-Yield Credit Spread

Measures the additional yield investors demand for holding lower-quality corporate credit instead of government bonds.

A widening spread means investors are demanding more compensation for credit risk.

A narrowing spread means credit risk is being priced more favourably.

Rapid widening can indicate increasing financial stress.

TLT, HYG and LQD
TLT

Represents long-duration U.S. Treasury bonds.

It generally moves inversely to long-term Treasury yields.

HYG

Represents high-yield corporate credit.

Strength can reflect healthy demand for riskier corporate debt.

Weakness can indicate deteriorating credit risk appetite.

LQD

Represents investment-grade corporate credit.

It generally carries lower credit risk than HYG.

HYG / LQD

Compares high-yield credit with investment-grade credit.

Rising means high-yield credit is outperforming.

Falling means investment-grade credit is outperforming relative to high-yield.

HYG / TLT

Compares risky corporate credit with long-duration government bonds.

Rising means credit is outperforming Treasuries.

Falling means Treasuries are gaining relative strength.

Commodities
Gold

Can respond to real yields, the U.S. dollar, inflation expectations, monetary demand and geopolitical risk.

Gold rising does not automatically mean markets are becoming defensive.

Context matters.

Silver

Has both precious-metal and industrial characteristics.

It often exhibits greater volatility than gold.

Copper

A major industrial metal often monitored as one indicator of global cyclical demand.

WTI and Brent Crude

Major U.S. and global oil benchmarks.

Large changes in oil prices can influence inflation expectations and economic conditions.

Natural Gas

Highly volatile and strongly affected by weather, inventories, production and LNG flows.

Broad Commodity Index

Helps determine whether commodity strength or weakness is widespread rather than isolated to one market.

U.S. Dollar Index — DXY

Tracks the U.S. dollar against a basket of major currencies.

A rising dollar can tighten global financial conditions and can influence commodities, emerging markets and international liquidity.

Relationships vary over time, so DXY should be interpreted alongside rates, commodities and risk assets.

Commodity Ratios
Copper / Gold

Rising means Copper is outperforming Gold.

This can be associated with stronger cyclical relative performance.

Falling means Gold is outperforming Copper.

Gold / Silver

Rising means Gold is outperforming Silver.

Falling means Silver is outperforming Gold.

WTI / Gold

Rising means Oil is outperforming Gold.

Falling means Gold is outperforming Oil.

These are relative-performance measures rather than standalone forecasts.

Cross-Asset Relative Performance

This page puts very different markets onto the same percentage-return basis.

It compares:

S&P 500
Nasdaq 100
Russell 2000
TLT
HYG
Gold
Copper
WTI
DXY
Bitcoin

Across:

1 week
1 month
3 months
6 months

This can make capital rotation much easier to identify.

For example:

S&P 500      +5%
Gold        +12%
TLT          -7%
Bitcoin     +18%

immediately shows which assets have delivered the strongest and weakest performance over the selected period.

Interpreting Several Indicators Together

The dashboard is intended to be read as a network of evidence.

For example:

S&P 500 rising
Russell 2000 rising
20D breadth rising
50D breadth rising
HYG strong
Credit spreads stable
VIX falling

describes a market move with relatively broad confirmation.

Compare that with:

S&P 500 rising
Nasdaq rising
Russell falling
20D breadth falling
50D breadth falling
HYG weakening
VIX rising

The headline index may still be advancing, but several internal measures are moving in a different direction.

Similarly:

VIX rising
MOVE rising
Credit spreads widening
HYG weakening
Breadth deteriorating

shows several independent stress indicators worsening at the same time.

The combination is generally more informative than any single number.

Data Availability

Some market-internal, volatility, exchange and economic feeds can depend on TradingView data access and subscription level.

Where possible, the script uses defensive requests so that an unavailable feed displays:

N/A

rather than intentionally stopping the rest of the dashboard.

Different feeds also update at different frequencies.

For example, exchange-traded markets may update continuously during trading hours while some economic or Federal Reserve series update daily or less frequently.

Important Limitations

Breadth feeds are aggregate market series. The script does not manually request and calculate all 500 S&P 500 constituents.

Continuous futures contracts can be influenced by contract rolls.

A five-bar weekly comparison represents approximately five trading sessions rather than exactly seven calendar days.

Statistical extremes can persist.

Yield-curve inversion has historically been monitored as a macroeconomic indicator, but it does not provide precise timing for equity-market peaks, recessions or recoveries.

Correlations between asset classes also change over time.

The dashboard therefore focuses on showing the evidence clearly rather than turning every reading into a prediction.

Suggested workflow

A useful sequence is:

1. Overview — identify leadership between large caps, mid caps and small caps.

2. Equity Breadth — determine whether the index move is broadly supported.

3. Index Trend — check statistical extension and longer-term trend position.

4. Intraday Internals — during U.S. market hours, assess TICK, ADD, VOLD and TRIN.

5. Volatility — examine whether equity and bond-market volatility is increasing.

6. Bonds & Credit — examine Treasury yields, curve inversion, real rates and credit conditions.

7. Commodities — assess Gold, Copper, Oil, DXY and important ratios.

8. Relative Performance — identify which asset classes are actually leading across several horizons.

The central principle of the indicator is simple:

Do not rely on one number. Look for confirmation or contradiction between price, breadth, volatility, rates, credit, commodities and relative performance.

This dashboard is designed to make those relationships easier to see.

## Source Code

````pine
//@version=6
indicator(
     "Market Risk Dashboard with Cheat Sheet",
     shorttitle="Market Risk Dashboard with Cheat Sheet",
     overlay=false,
     dynamic_requests=true
)

//======================================================================
// MARKET INTERNALS, MACRO & CROSS-ASSET DASHBOARD
//======================================================================
//
// PAGES
// -----
// 1. Overview
// 2. Equity Breadth
// 3. Index Trend
// 4. Intraday Internals
// 5. Volatility
// 6. Bonds & Credit
// 7. Commodities
// 8. Relative Performance
//
// IMPORTANT:
//
// All user selections are hidden from the indicator title/status line
// by using display=display.none on every input.
//
// The visible chart title should remain:
//
// Market Risk Dashboard with Cheat Sheet
//
//======================================================================


//======================================================================
// DASHBOARD PAGE
//======================================================================

dashboardPage = input.string(
     "Overview",
     "Dashboard Page",
     options=[
         "Overview",
         "Equity Breadth",
         "Index Trend",
         "Intraday Internals",
         "Volatility",
         "Bonds & Credit",
         "Commodities",
         "Relative Performance"
     ],
     group="Dashboard",
     display=display.none
)


//======================================================================
// DISPLAY
//======================================================================

showDashboard = input.bool(
     true,
     "Show Dashboard",
     group="Display",
     display=display.none
)

showCheatSheet = input.bool(
     true,
     "Show Cheat Sheet",
     group="Display",
     display=display.none
)

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


//======================================================================
// THRESHOLDS
//======================================================================

breadthNeutralBand = input.float(
     1.0,
     "Breadth Weekly Neutral Band",
     minval=0.0,
     step=0.1,
     group="Colours",
     display=display.none
)

priceNeutralBand = input.float(
     0.25,
     "Price Neutral Band %",
     minval=0.0,
     step=0.05,
     group="Colours",
     display=display.none
)

rateNeutralBand = input.float(
     3.0,
     "Yield Neutral Band bp",
     minval=0.0,
     step=0.5,
     group="Colours",
     display=display.none
)

curveFlatBand = input.float(
     15.0,
     "Curve Flat Band bp",
     minval=0.0,
     step=1.0,
     group="Colours",
     display=display.none
)


//======================================================================
// INDEX SYMBOLS
//======================================================================

spxSymbol = input.string(
     "TVC:SPX",
     "S&P 500",
     group="Index Symbols",
     display=display.none
)

ndxSymbol = input.string(
     "NASDAQ:NDX",
     "Nasdaq 100",
     group="Index Symbols",
     display=display.none
)

dowSymbol = input.string(
     "TVC:DJI",
     "Dow Jones",
     group="Index Symbols",
     display=display.none
)

rutSymbol = input.string(
     "TVC:RUT",
     "Russell 2000",
     group="Index Symbols",
     display=display.none
)

ixicSymbol = input.string(
     "NASDAQ:IXIC",
     "Nasdaq Composite",
     group="Index Symbols",
     display=display.none
)

nyaSymbol = input.string(
     "TVC:NYA",
     "NYSE Composite",
     group="Index Symbols",
     display=display.none
)

midSymbol = input.string(
     "SP:MID",
     "S&P MidCap 400",
     group="Index Symbols",
     display=display.none
)

sp600Symbol = input.string(
     "SP:SP600",
     "S&P SmallCap 600",
     group="Index Symbols",
     display=display.none
)


//======================================================================
// BREADTH SYMBOLS
//======================================================================

sp20Breadth = input.string(
     "INDEX:S5TW",
     "S&P % > 20D",
     group="Breadth Symbols",
     display=display.none
)

sp50Breadth = input.string(
     "INDEX:S5FI",
     "S&P % > 50D",
     group="Breadth Symbols",
     display=display.none
)

sp100Breadth = input.string(
     "INDEX:S5OH",
     "S&P % > 100D",
     group="Breadth Symbols",
     display=display.none
)

sp200Breadth = input.string(
     "INDEX:S5TH",
     "S&P % > 200D",
     group="Breadth Symbols",
     display=display.none
)

nd20Breadth = input.string(
     "INDEX:NDTW",
     "Nasdaq % > 20D",
     group="Breadth Symbols",
     display=display.none
)

nd50Breadth = input.string(
     "INDEX:NDFI",
     "Nasdaq % > 50D",
     group="Breadth Symbols",
     display=display.none
)

nd100Breadth = input.string(
     "INDEX:NDOH",
     "Nasdaq % > 100D",
     group="Breadth Symbols",
     display=display.none
)

nd200Breadth = input.string(
     "INDEX:NDTH",
     "Nasdaq % > 200D",
     group="Breadth Symbols",
     display=display.none
)

dow20Breadth = input.string(
     "INDEX:DITW",
     "Dow % > 20D",
     group="Breadth Symbols",
     display=display.none
)

dow50Breadth = input.string(
     "INDEX:DIFI",
     "Dow % > 50D",
     group="Breadth Symbols",
     display=display.none
)

dow100Breadth = input.string(
     "INDEX:DIOH",
     "Dow % > 100D",
     group="Breadth Symbols",
     display=display.none
)

dow200Breadth = input.string(
     "INDEX:DITH",
     "Dow % > 200D",
     group="Breadth Symbols",
     display=display.none
)

r220Breadth = input.string(
     "INDEX:R2TW",
     "Russell % > 20D",
     group="Breadth Symbols",
     display=display.none
)

r250Breadth = input.string(
     "INDEX:R2FI",
     "Russell % > 50D",
     group="Breadth Symbols",
     display=display.none
)

r2100Breadth = input.string(
     "INDEX:R2OH",
     "Russell % > 100D",
     group="Breadth Symbols",
     display=display.none
)

r2200Breadth = input.string(
     "INDEX:R2TH",
     "Russell % > 200D",
     group="Breadth Symbols",
     display=display.none
)


//======================================================================
// INTRADAY INTERNALS
//======================================================================

tickNYSE = input.string(
     "USI:TICK",
     "NYSE TICK",
     group="Intraday Internals",
     display=display.none
)

addNYSE = input.string(
     "USI:ADD",
     "NYSE ADD",
     group="Intraday Internals",
     display=display.none
)

voldNYSE = input.string(
     "USI:VOLD",
     "NYSE VOLD",
     group="Intraday Internals",
     display=display.none
)

trinNYSE = input.string(
     "USI:TRIN.NY",
     "NYSE TRIN",
     group="Intraday Internals",
     display=display.none
)

tickNASDAQ = input.string(
     "USI:TICKQ",
     "Nasdaq TICK",
     group="Intraday Internals",
     display=display.none
)

addNASDAQ = input.string(
     "USI:ADDQ",
     "Nasdaq ADD",
     group="Intraday Internals",
     display=display.none
)

voldNASDAQ = input.string(
     "USI:VOLDQ",
     "Nasdaq VOLD",
     group="Intraday Internals",
     display=display.none
)

trinNASDAQ = input.string(
     "USI:TRIN.NQ",
     "Nasdaq TRIN",
     group="Intraday Internals",
     display=display.none
)

internalsTimeframe = input.string(
     "5",
     "Internals Timeframe",
     options=[
         "1",
         "5",
         "15"
     ],
     group="Intraday Internals",
     display=display.none
)


//======================================================================
// VOLATILITY
//======================================================================

vixSymbol = input.string(
     "CBOE:VIX",
     "VIX",
     group="Volatility",
     display=display.none
)

vxnSymbol = input.string(
     "CBOE:VXN",
     "VXN",
     group="Volatility",
     display=display.none
)

vix3mSymbol = input.string(
     "CBOE:VIX3M",
     "VIX 3-Month",
     group="Volatility",
     display=display.none
)

moveSymbol = input.string(
     "TVC:MOVE",
     "MOVE",
     group="Volatility",
     display=display.none
)


//======================================================================
// BONDS / CREDIT
//======================================================================

us03mSymbol = input.string(
     "TVC:US03MY",
     "US 3M Yield",
     group="Bonds / Credit",
     display=display.none
)

us02Symbol = input.string(
     "TVC:US02Y",
     "US 2Y Yield",
     group="Bonds / Credit",
     display=display.none
)

us05Symbol = input.string(
     "TVC:US05Y",
     "US 5Y Yield",
     group="Bonds / Credit",
     display=display.none
)

us10Symbol = input.string(
     "TVC:US10Y",
     "US 10Y Yield",
     group="Bonds / Credit",
     display=display.none
)

us30Symbol = input.string(
     "TVC:US30Y",
     "US 30Y Yield",
     group="Bonds / Credit",
     display=display.none
)

real10Symbol = input.string(
     "FRED:DFII10",
     "10Y Real Yield",
     group="Bonds / Credit",
     display=display.none
)

breakeven10Symbol = input.string(
     "FRED:T10YIE",
     "10Y Breakeven Inflation",
     group="Bonds / Credit",
     display=display.none
)

hySpreadSymbol = input.string(
     "FRED:BAMLH0A0HYM2",
     "High Yield Spread",
     group="Bonds / Credit",
     display=display.none
)

tltSymbol = input.string(
     "NASDAQ:TLT",
     "TLT",
     group="Bonds / Credit",
     display=display.none
)

hygSymbol = input.string(
     "AMEX:HYG",
     "HYG",
     group="Bonds / Credit",
     display=display.none
)

lqdSymbol = input.string(
     "AMEX:LQD",
     "LQD",
     group="Bonds / Credit",
     display=display.none
)


//======================================================================
// COMMODITIES / RELATIVE PERFORMANCE
//======================================================================

goldSymbol = input.string(
     "COMEX:GC1!",
     "Gold",
     group="Commodities",
     display=display.none
)

silverSymbol = input.string(
     "COMEX:SI1!",
     "Silver",
     group="Commodities",
     display=display.none
)

copperSymbol = input.string(
     "COMEX:HG1!",
     "Copper",
     group="Commodities",
     display=display.none
)

wtiSymbol = input.string(
     "NYMEX:CL1!",
     "WTI",
     group="Commodities",
     display=display.none
)

brentSymbol = input.string(
     "NYMEX:BZ1!",
     "Brent",
     group="Commodities",
     display=display.none
)

gasSymbol = input.string(
     "NYMEX:NG1!",
     "Natural Gas",
     group="Commodities",
     display=display.none
)

bcomSymbol = input.string(
     "BBG:BCOM",
     "Broad Commodity Index",
     group="Commodities",
     display=display.none
)

dxySymbol = input.string(
     "TVC:DXY",
     "DXY",
     group="Commodities",
     display=display.none
)

btcSymbol = input.string(
     "CRYPTO:BTCUSD",
     "Bitcoin",
     group="Relative Performance",
     display=display.none
)


//======================================================================
// POSITION / FONT
//======================================================================

getPosition(string p) =>
    switch p
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


getFontSize(string s) =>
    switch s
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

color headerColour = color.rgb(25, 25, 25)
color sectionColour = color.rgb(30, 65, 95)
color labelColour = color.rgb(42, 42, 42)

color greenColour = color.rgb(0, 115, 45)
color redColour = color.rgb(150, 25, 35)
color yellowColour = color.rgb(150, 115, 0)
color orangeColour = color.rgb(185, 85, 10)
color blueColour = color.rgb(25, 85, 165)
color greyColour = color.rgb(65, 65, 65)
color textColour = color.white


//======================================================================
// FORMATTING
//======================================================================

fmt(float x) =>
    na(x) ? "N/A" : str.tostring(x, "#,###.##")


fmtPct(float x) =>
    na(x) ? "N/A" : str.tostring(x, "#.1") + "%"


fmtSignedPct(float x) =>
    string result = "N/A"
    if not na(x)
        string sign = x > 0 ? "+" : ""
        result := sign + str.tostring(x, "#.2") + "%"
    result


fmtPoints(float x) =>
    string result = "N/A"
    if not na(x)
        string sign = x > 0 ? "+" : ""
        result := sign + str.tostring(x, "#.2") + " pts"
    result


fmtBp(float x) =>
    string result = "N/A"
    if not na(x)
        string sign = x > 0 ? "+" : ""
        result := sign + str.tostring(x, "#.1") + " bp"
    result


fmtZ(float x) =>
    string result = "N/A"
    if not na(x)
        string sign = x > 0 ? "+" : ""
        result := sign + str.tostring(x, "#.00")
    result


//======================================================================
// COLOUR HELPERS
//======================================================================

changeColour(
     float change,
     float neutralBand,
     bool higherIsBetter
 ) =>

    color result = greyColour

    if not na(change)
        if math.abs(change) <= neutralBand
            result := yellowColour
        else
            bool improving = higherIsBetter ? change > 0 : change < 0
            result := improving ? greenColour : redColour

    result


priceColour(float change) =>
    changeColour(
         change,
         priceNeutralBand,
         true
     )


zColour(float z) =>
    color result = greyColour

    if not na(z)
        float az = math.abs(z)

        if az < 1
            result := greenColour
        else if az < 2
            result := yellowColour
        else if az < 3
            result := orangeColour
        else
            result := redColour

    result


//======================================================================
// CURVE HELPERS
//======================================================================

curveStatus(float spread) =>
    string result = "N/A"

    if not na(spread)
        if spread < 0
            result := "INVERTED"
        else if spread <= curveFlatBand
            result := "FLAT"
        else
            result := "POSITIVE"

    result


curveStatusColour(float spread) =>
    color result = greyColour

    if not na(spread)
        if spread < 0
            result := redColour
        else if spread <= curveFlatBand
            result := yellowColour
        else
            result := greenColour

    result


curveDirection(
     float currentSpread,
     float priorSpread
 ) =>

    string result = "N/A"

    if not na(currentSpread) and not na(priorSpread)

        float change = currentSpread - priorSpread

        if currentSpread < 0

            if change > 0
                result := "INVERTED / NORMALISING"
            else if change < 0
                result := "INVERTED / DEEPENING"
            else
                result := "INVERTED / UNCHANGED"

        else

            if change > 0
                result := "STEEPENING"
            else if change < 0
                result := "FLATTENING"
            else
                result := "UNCHANGED"

    result


curveMoveType(
     float shortNow,
     float shortPrev,
     float longNow,
     float longPrev
 ) =>

    string result = "N/A"

    if not na(shortNow) and
       not na(shortPrev) and
       not na(longNow) and
       not na(longPrev)

        float shortMove = shortNow - shortPrev
        float longMove = longNow - longPrev

        float spreadNow = longNow - shortNow
        float spreadPrev = longPrev - shortPrev

        float spreadChange = spreadNow - spreadPrev

        bool steepening = spreadChange > 0
        bool ratesRising = shortMove > 0 and longMove > 0
        bool ratesFalling = shortMove < 0 and longMove < 0

        if steepening and ratesFalling
            result := "BULL STEEPENER"
        else if steepening and ratesRising
            result := "BEAR STEEPENER"
        else if not steepening and ratesRising
            result := "BEAR FLATTENER"
        else if not steepening and ratesFalling
            result := "BULL FLATTENER"
        else if steepening
            result := "STEEPENING"
        else
            result := "FLATTENING"

    result


//======================================================================
// Z SCORE
//======================================================================

z21() =>
    float basis = ta.sma(close, 21)
    float sd = ta.stdev(close, 21)
    float result = na

    if not na(basis) and not na(sd) and sd != 0
        result := (close - basis) / sd

    result


//======================================================================
// DATA REQUEST FUNCTIONS
//======================================================================

getCurrentAndWeek(string symbol) =>
    request.security(
         symbol,
         "D",
         [
             close,
             (close / close[5] - 1.0) * 100.0
         ],
         ignore_invalid_symbol=true,
         calc_bars_count=15
     )


getBreadth(string symbol) =>
    request.security(
         symbol,
         "D",
         [
             close,
             close[5]
         ],
         ignore_invalid_symbol=true,
         calc_bars_count=15
     )


getWeeklyTrend(string symbol) =>
    request.security(
         symbol,
         "W",
         [
             close,
             (close / close[1] - 1.0) * 100.0,
             (close / ta.highest(high, 30) - 1.0) * 100.0,
             (close / ta.lowest(low, 30) - 1.0) * 100.0,
             ta.stdev(math.log(close / close[1]), 30) * math.sqrt(52.0) * 100.0,
             (close / ta.sma(close, 200) - 1.0) * 100.0
         ],
         ignore_invalid_symbol=true,
         calc_bars_count=210
     )


getZ(string symbol) =>
    request.security(
         symbol,
         "D",
         z21(),
         ignore_invalid_symbol=true,
         calc_bars_count=40
     )


getRate(string symbol) =>
    request.security(
         symbol,
         "W",
         [
             close,
             close[1],
             (close - close[1]) * 100.0
         ],
         ignore_invalid_symbol=true,
         calc_bars_count=12
     )


getDailyMacro(string symbol) =>
    request.security(
         symbol,
         "D",
         [
             close,
             close - close[5]
         ],
         ignore_invalid_symbol=true,
         calc_bars_count=15
     )


getMacroAsset(string symbol) =>
    request.security(
         symbol,
         "W",
         [
             close,
             (close / close[1] - 1.0) * 100.0,
             (close / ta.highest(high, 30) - 1.0) * 100.0,
             (close / ta.sma(close, 200) - 1.0) * 100.0
         ],
         ignore_invalid_symbol=true,
         calc_bars_count=210
     )


getVolatilityStats(string symbol) =>
    request.security(
         symbol,
         "D",
         [
             close,
             (close / close[5] - 1.0) * 100.0,
             z21(),
             (close / ta.highest(high, 126) - 1.0) * 100.0
         ],
         ignore_invalid_symbol=true,
         calc_bars_count=150
     )


getInternal(string symbol) =>
    request.security(
         symbol,
         internalsTimeframe,
         [
             close,
             close - close[6],
             ta.sma(close, 12)
         ],
         ignore_invalid_symbol=true,
         calc_bars_count=30
     )


getPerformance(string symbol) =>
    request.security(
         symbol,
         "D",
         [
             (close / close[5] - 1.0) * 100.0,
             (close / close[21] - 1.0) * 100.0,
             (close / close[63] - 1.0) * 100.0,
             (close / close[126] - 1.0) * 100.0
         ],
         ignore_invalid_symbol=true,
         calc_bars_count=135
     )


//======================================================================
// TABLE
//======================================================================

TABLE_COLUMNS = 6
TABLE_ROWS = 22


var table dashboard =
     table.new(
         tablePosition,
         TABLE_COLUMNS,
         TABLE_ROWS,
         border_width=1
     )


//======================================================================
// TABLE HELPERS
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


drawLabel(
     int row,
     string value
 ) =>
    drawCell(
         0,
         row,
         value,
         labelColour
     )


drawCheat(
     int row,
     string value
 ) =>
    drawCell(
         5,
         row,
         showCheatSheet ? value : "",
         greyColour
     )


drawSection(
     int row,
     string title
 ) =>
    for column = 0 to 5
        drawCell(
             column,
             row,
             column == 0 ? title : "",
             sectionColour
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
// PAGE 1 - OVERVIEW
//======================================================================

if dashboardPage == "Overview"

    [spxNow, spxWeek] = getCurrentAndWeek(spxSymbol)
    [ndxNow, ndxWeek] = getCurrentAndWeek(ndxSymbol)
    [dowNow, dowWeek] = getCurrentAndWeek(dowSymbol)
    [rutNow, rutWeek] = getCurrentAndWeek(rutSymbol)
    [ixicNow, ixicWeek] = getCurrentAndWeek(ixicSymbol)
    [nyaNow, nyaWeek] = getCurrentAndWeek(nyaSymbol)
    [midNow, midWeek] = getCurrentAndWeek(midSymbol)
    [sp600Now, sp600Week] = getCurrentAndWeek(sp600Symbol)

    if barstate.islast and showDashboard

        drawSection(0, "US MARKET OVERVIEW")

        drawCell(0, 1, "Index", headerColour)
        drawCell(1, 1, "Current", headerColour)
        drawCell(2, 1, "1W Change", headerColour)
        drawCell(3, 1, "Segment", headerColour)
        drawCell(4, 1, "Role", headerColour)
        drawCell(5, 1, "Cheat Sheet", headerColour)

        drawLabel(2, "S&P 500")
        drawCell(1, 2, fmt(spxNow), greyColour)
        drawCell(2, 2, fmtSignedPct(spxWeek), priceColour(spxWeek))
        drawCell(3, 2, "Large Cap", blueColour)
        drawCell(4, 2, "Broad benchmark", greyColour)
        drawCheat(2, "Primary large-cap U.S. equity benchmark.")

        drawLabel(3, "Nasdaq 100")
        drawCell(1, 3, fmt(ndxNow), greyColour)
        drawCell(2, 3, fmtSignedPct(ndxWeek), priceColour(ndxWeek))
        drawCell(3, 3, "Mega/Large", blueColour)
        drawCell(4, 3, "Growth / Tech", greyColour)
        drawCheat(3, "Large non-financial Nasdaq companies; growth and technology heavy.")

        drawLabel(4, "Dow Jones")
        drawCell(1, 4, fmt(dowNow), greyColour)
        drawCell(2, 4, fmtSignedPct(dowWeek), priceColour(dowWeek))
        drawCell(3, 4, "Large Cap", blueColour)
        drawCell(4, 4, "30 blue chips", greyColour)
        drawCheat(4, "Thirty major established U.S. companies.")

        drawLabel(5, "Russell 2000")
        drawCell(1, 5, fmt(rutNow), greyColour)
        drawCell(2, 5, fmtSignedPct(rutWeek), priceColour(rutWeek))
        drawCell(3, 5, "Small Cap", blueColour)
        drawCell(4, 5, "Broad small cap", greyColour)
        drawCheat(5, "Widely followed U.S. small-cap benchmark.")

        drawLabel(6, "Nasdaq Composite")
        drawCell(1, 6, fmt(ixicNow), greyColour)
        drawCell(2, 6, fmtSignedPct(ixicWeek), priceColour(ixicWeek))
        drawCell(3, 6, "Broad Nasdaq", blueColour)
        drawCell(4, 6, "Exchange-wide", greyColour)
        drawCheat(6, "Broader Nasdaq universe than the Nasdaq 100.")

        drawLabel(7, "NYSE Composite")
        drawCell(1, 7, fmt(nyaNow), greyColour)
        drawCell(2, 7, fmtSignedPct(nyaWeek), priceColour(nyaWeek))
        drawCell(3, 7, "Broad NYSE", blueColour)
        drawCell(4, 7, "Exchange-wide", greyColour)
        drawCheat(7, "Broad view of NYSE-listed companies.")

        drawLabel(8, "S&P MidCap 400")
        drawCell(1, 8, fmt(midNow), greyColour)
        drawCell(2, 8, fmtSignedPct(midWeek), priceColour(midWeek))
        drawCell(3, 8, "Mid Cap", blueColour)
        drawCell(4, 8, "400 companies", greyColour)
        drawCheat(8, "Shows whether strength extends beyond mega-cap stocks.")

        drawLabel(9, "S&P SmallCap 600")
        drawCell(1, 9, fmt(sp600Now), greyColour)
        drawCell(2, 9, fmtSignedPct(sp600Week), priceColour(sp600Week))
        drawCell(3, 9, "Small Cap", blueColour)
        drawCell(4, 9, "600 companies", greyColour)
        drawCheat(9, "Additional small-cap confirmation alongside Russell 2000.")


//======================================================================
// PAGE 2 - EQUITY BREADTH
//======================================================================

if dashboardPage == "Equity Breadth"

    [spxNow, spxWeek] = getCurrentAndWeek(spxSymbol)
    [ndxNow, ndxWeek] = getCurrentAndWeek(ndxSymbol)
    [dowNow, dowWeek] = getCurrentAndWeek(dowSymbol)
    [rutNow, rutWeek] = getCurrentAndWeek(rutSymbol)

    [sp20, sp20Prev] = getBreadth(sp20Breadth)
    [sp50, sp50Prev] = getBreadth(sp50Breadth)
    [sp100, sp100Prev] = getBreadth(sp100Breadth)
    [sp200, sp200Prev] = getBreadth(sp200Breadth)

    [nd20, nd20Prev] = getBreadth(nd20Breadth)
    [nd50, nd50Prev] = getBreadth(nd50Breadth)
    [nd100, nd100Prev] = getBreadth(nd100Breadth)
    [nd200, nd200Prev] = getBreadth(nd200Breadth)

    [dow20, dow20Prev] = getBreadth(dow20Breadth)
    [dow50, dow50Prev] = getBreadth(dow50Breadth)
    [dow100, dow100Prev] = getBreadth(dow100Breadth)
    [dow200, dow200Prev] = getBreadth(dow200Breadth)

    [r220, r220Prev] = getBreadth(r220Breadth)
    [r250, r250Prev] = getBreadth(r250Breadth)
    [r2100, r2100Prev] = getBreadth(r2100Breadth)
    [r2200, r2200Prev] = getBreadth(r2200Breadth)

    if barstate.islast and showDashboard

        drawSection(0, "EQUITY MARKET BREADTH")

        drawCell(0, 1, "Measure", headerColour)
        drawCell(1, 1, "S&P 500", headerColour)
        drawCell(2, 1, "NASDAQ 100", headerColour)
        drawCell(3, 1, "DOW", headerColour)
        drawCell(4, 1, "RUSSELL 2000", headerColour)
        drawCell(5, 1, "Cheat Sheet", headerColour)

        drawLabel(2, "Current Index")
        drawCell(1, 2, fmt(spxNow), greyColour)
        drawCell(2, 2, fmt(ndxNow), greyColour)
        drawCell(3, 2, fmt(dowNow), greyColour)
        drawCell(4, 2, fmt(rutNow), greyColour)
        drawCheat(2, "Actual current index value for context.")

        drawLabel(3, "Index 1W")
        drawCell(1, 3, fmtSignedPct(spxWeek), priceColour(spxWeek))
        drawCell(2, 3, fmtSignedPct(ndxWeek), priceColour(ndxWeek))
        drawCell(3, 3, fmtSignedPct(dowWeek), priceColour(dowWeek))
        drawCell(4, 3, fmtSignedPct(rutWeek), priceColour(rutWeek))
        drawCheat(3, "Compare index performance with participation underneath.")

        float sp20C = sp20 - sp20Prev
        float nd20C = nd20 - nd20Prev
        float dow20C = dow20 - dow20Prev
        float r220C = r220 - r220Prev

        drawLabel(4, "% > 20D MA")
        drawCell(1, 4, fmtPct(sp20) + "\n" + fmtPoints(sp20C), changeColour(sp20C, breadthNeutralBand, true))
        drawCell(2, 4, fmtPct(nd20) + "\n" + fmtPoints(nd20C), changeColour(nd20C, breadthNeutralBand, true))
        drawCell(3, 4, fmtPct(dow20) + "\n" + fmtPoints(dow20C), changeColour(dow20C, breadthNeutralBand, true))
        drawCell(4, 4, fmtPct(r220) + "\n" + fmtPoints(r220C), changeColour(r220C, breadthNeutralBand, true))
        drawCheat(4, "Short-term participation. Falling while price rises can indicate narrowing breadth.")

        float sp50C = sp50 - sp50Prev
        float nd50C = nd50 - nd50Prev
        float dow50C = dow50 - dow50Prev
        float r250C = r250 - r250Prev

        drawLabel(5, "% > 50D MA")
        drawCell(1, 5, fmtPct(sp50) + "\n" + fmtPoints(sp50C), changeColour(sp50C, breadthNeutralBand, true))
        drawCell(2, 5, fmtPct(nd50) + "\n" + fmtPoints(nd50C), changeColour(nd50C, breadthNeutralBand, true))
        drawCell(3, 5, fmtPct(dow50) + "\n" + fmtPoints(dow50C), changeColour(dow50C, breadthNeutralBand, true))
        drawCell(4, 5, fmtPct(r250) + "\n" + fmtPoints(r250C), changeColour(r250C, breadthNeutralBand, true))
        drawCheat(5, "Intermediate participation. Below 50% means a majority are below their 50D average.")

        float sp100C = sp100 - sp100Prev
        float nd100C = nd100 - nd100Prev
        float dow100C = dow100 - dow100Prev
        float r2100C = r2100 - r2100Prev

        drawLabel(6, "% > 100D MA")
        drawCell(1, 6, fmtPct(sp100) + "\n" + fmtPoints(sp100C), changeColour(sp100C, breadthNeutralBand, true))
        drawCell(2, 6, fmtPct(nd100) + "\n" + fmtPoints(nd100C), changeColour(nd100C, breadthNeutralBand, true))
        drawCell(3, 6, fmtPct(dow100) + "\n" + fmtPoints(dow100C), changeColour(dow100C, breadthNeutralBand, true))
        drawCell(4, 6, fmtPct(r2100) + "\n" + fmtPoints(r2100C), changeColour(r2100C, breadthNeutralBand, true))
        drawCheat(6, "Medium-term participation. Persistent deterioration can reveal spreading weakness.")

        float sp200C = sp200 - sp200Prev
        float nd200C = nd200 - nd200Prev
        float dow200C = dow200 - dow200Prev
        float r2200C = r2200 - r2200Prev

        drawLabel(7, "% > 200D MA")
        drawCell(1, 7, fmtPct(sp200) + "\n" + fmtPoints(sp200C), changeColour(sp200C, breadthNeutralBand, true))
        drawCell(2, 7, fmtPct(nd200) + "\n" + fmtPoints(nd200C), changeColour(nd200C, breadthNeutralBand, true))
        drawCell(3, 7, fmtPct(dow200) + "\n" + fmtPoints(dow200C), changeColour(dow200C, breadthNeutralBand, true))
        drawCell(4, 7, fmtPct(r2200) + "\n" + fmtPoints(r2200C), changeColour(r2200C, breadthNeutralBand, true))
        drawCheat(7, "Long-term participation. Below 50% means most members are below their 200D average.")

        string spDiv =
             na(spxWeek) or na(sp20C) ?
             "N/A" :
             spxWeek > 0 and sp20C < 0 ?
             "PRICE UP / BREADTH DOWN" :
             spxWeek < 0 and sp20C > 0 ?
             "PRICE DOWN / BREADTH UP" :
             "No simple divergence"

        string ndDiv =
             na(ndxWeek) or na(nd20C) ?
             "N/A" :
             ndxWeek > 0 and nd20C < 0 ?
             "PRICE UP / BREADTH DOWN" :
             ndxWeek < 0 and nd20C > 0 ?
             "PRICE DOWN / BREADTH UP" :
             "No simple divergence"

        string dowDiv =
             na(dowWeek) or na(dow20C) ?
             "N/A" :
             dowWeek > 0 and dow20C < 0 ?
             "PRICE UP / BREADTH DOWN" :
             dowWeek < 0 and dow20C > 0 ?
             "PRICE DOWN / BREADTH UP" :
             "No simple divergence"

        string rutDiv =
             na(rutWeek) or na(r220C) ?
             "N/A" :
             rutWeek > 0 and r220C < 0 ?
             "PRICE UP / BREADTH DOWN" :
             rutWeek < 0 and r220C > 0 ?
             "PRICE DOWN / BREADTH UP" :
             "No simple divergence"

        drawLabel(8, "Price/Breadth Divergence")

        drawCell(1, 8, spDiv, spDiv == "No simple divergence" or spDiv == "N/A" ? greyColour : orangeColour)
        drawCell(2, 8, ndDiv, ndDiv == "No simple divergence" or ndDiv == "N/A" ? greyColour : orangeColour)
        drawCell(3, 8, dowDiv, dowDiv == "No simple divergence" or dowDiv == "N/A" ? greyColour : orangeColour)
        drawCell(4, 8, rutDiv, rutDiv == "No simple divergence" or rutDiv == "N/A" ? greyColour : orangeColour)

        drawCheat(8, "Highlights disagreement between weekly price direction and short-term participation.")


//======================================================================
// PAGE 3 - INDEX TREND
//======================================================================

if dashboardPage == "Index Trend"

    [spNow, spWeek, sp30High, sp30Low, spVol, sp200MA] = getWeeklyTrend(spxSymbol)
    spZ = getZ(spxSymbol)

    [ndNow, ndWeek, nd30High, nd30Low, ndVol, nd200MA] = getWeeklyTrend(ndxSymbol)
    ndZ = getZ(ndxSymbol)

    [djNow, djWeek, dj30High, dj30Low, djVol, dj200MA] = getWeeklyTrend(dowSymbol)
    djZ = getZ(dowSymbol)

    [ruNow, ruWeek, ru30High, ru30Low, ruVol, ru200MA] = getWeeklyTrend(rutSymbol)
    ruZ = getZ(rutSymbol)

    [ixNow, ixWeek, ix30High, ix30Low, ixVol, ix200MA] = getWeeklyTrend(ixicSymbol)
    ixZ = getZ(ixicSymbol)

    [nyNow, nyWeek, ny30High, ny30Low, nyVol, ny200MA] = getWeeklyTrend(nyaSymbol)
    nyZ = getZ(nyaSymbol)

    [miNow, miWeek, mi30High, mi30Low, miVol, mi200MA] = getWeeklyTrend(midSymbol)
    miZ = getZ(midSymbol)

    [s6Now, s6Week, s630High, s630Low, s6Vol, s6200MA] = getWeeklyTrend(sp600Symbol)
    s6Z = getZ(sp600Symbol)

    if barstate.islast and showDashboard

        drawSection(0, "INDEX TREND / STATISTICAL EXTENSION")

        drawCell(0, 1, "Index", headerColour)
        drawCell(1, 1, "Current", headerColour)
        drawCell(2, 1, "1W", headerColour)
        drawCell(3, 1, "21D Z", headerColour)
        drawCell(4, 1, "30W High / 200W MA", headerColour)
        drawCell(5, 1, "Cheat Sheet", headerColour)

        drawLabel(2, "S&P 500")
        drawCell(1, 2, fmt(spNow), greyColour)
        drawCell(2, 2, fmtSignedPct(spWeek), priceColour(spWeek))
        drawCell(3, 2, fmtZ(spZ), zColour(spZ))
        drawCell(4, 2, fmtPct(sp30High) + "\n200W " + fmtPct(sp200MA), blueColour)
        drawCheat(2, "21D Z = statistical extension. 30W high and 200W MA provide trend context.")

        drawLabel(3, "Nasdaq 100")
        drawCell(1, 3, fmt(ndNow), greyColour)
        drawCell(2, 3, fmtSignedPct(ndWeek), priceColour(ndWeek))
        drawCell(3, 3, fmtZ(ndZ), zColour(ndZ))
        drawCell(4, 3, fmtPct(nd30High) + "\n200W " + fmtPct(nd200MA), blueColour)
        drawCheat(3, "Growth/technology leadership and statistical extension.")

        drawLabel(4, "Dow Jones")
        drawCell(1, 4, fmt(djNow), greyColour)
        drawCell(2, 4, fmtSignedPct(djWeek), priceColour(djWeek))
        drawCell(3, 4, fmtZ(djZ), zColour(djZ))
        drawCell(4, 4, fmtPct(dj30High) + "\n200W " + fmtPct(dj200MA), blueColour)
        drawCheat(4, "Blue-chip trend and statistical extension.")

        drawLabel(5, "Russell 2000")
        drawCell(1, 5, fmt(ruNow), greyColour)
        drawCell(2, 5, fmtSignedPct(ruWeek), priceColour(ruWeek))
        drawCell(3, 5, fmtZ(ruZ), zColour(ruZ))
        drawCell(4, 5, fmtPct(ru30High) + "\n200W " + fmtPct(ru200MA), blueColour)
        drawCheat(5, "Small-cap trend and market participation.")

        drawLabel(6, "Nasdaq Composite")
        drawCell(1, 6, fmt(ixNow), greyColour)
        drawCell(2, 6, fmtSignedPct(ixWeek), priceColour(ixWeek))
        drawCell(3, 6, fmtZ(ixZ), zColour(ixZ))
        drawCell(4, 6, fmtPct(ix30High) + "\n200W " + fmtPct(ix200MA), blueColour)
        drawCheat(6, "Broader Nasdaq market trend.")

        drawLabel(7, "NYSE Composite")
        drawCell(1, 7, fmt(nyNow), greyColour)
        drawCell(2, 7, fmtSignedPct(nyWeek), priceColour(nyWeek))
        drawCell(3, 7, fmtZ(nyZ), zColour(nyZ))
        drawCell(4, 7, fmtPct(ny30High) + "\n200W " + fmtPct(ny200MA), blueColour)
        drawCheat(7, "Broad NYSE-listed market trend.")

        drawLabel(8, "S&P MidCap 400")
        drawCell(1, 8, fmt(miNow), greyColour)
        drawCell(2, 8, fmtSignedPct(miWeek), priceColour(miWeek))
        drawCell(3, 8, fmtZ(miZ), zColour(miZ))
        drawCell(4, 8, fmtPct(mi30High) + "\n200W " + fmtPct(mi200MA), blueColour)
        drawCheat(8, "Mid-cap trend beyond mega-cap leadership.")

        drawLabel(9, "S&P SmallCap 600")
        drawCell(1, 9, fmt(s6Now), greyColour)
        drawCell(2, 9, fmtSignedPct(s6Week), priceColour(s6Week))
        drawCell(3, 9, fmtZ(s6Z), zColour(s6Z))
        drawCell(4, 9, fmtPct(s630High) + "\n200W " + fmtPct(s6200MA), blueColour)
        drawCheat(9, "Alternative U.S. small-cap trend measure.")


//======================================================================
// PAGE 4 - INTRADAY INTERNALS
//======================================================================

if dashboardPage == "Intraday Internals"

    [tickN, tickNChange, tickNAvg] = getInternal(tickNYSE)
    [addN, addNChange, addNAvg] = getInternal(addNYSE)
    [voldN, voldNChange, voldNAvg] = getInternal(voldNYSE)
    [trinN, trinNChange, trinNAvg] = getInternal(trinNYSE)

    [tickQ, tickQChange, tickQAvg] = getInternal(tickNASDAQ)
    [addQ, addQChange, addQAvg] = getInternal(addNASDAQ)
    [voldQ, voldQChange, voldQAvg] = getInternal(voldNASDAQ)
    [trinQ, trinQChange, trinQAvg] = getInternal(trinNASDAQ)

    if barstate.islast and showDashboard

        drawSection(0, "INTRADAY MARKET INTERNALS")

        drawCell(0, 1, "Measure", headerColour)
        drawCell(1, 1, "NYSE Now", headerColour)
        drawCell(2, 1, "NYSE Change", headerColour)
        drawCell(3, 1, "NASDAQ Now", headerColour)
        drawCell(4, 1, "NASDAQ Change", headerColour)
        drawCell(5, 1, "Cheat Sheet", headerColour)

        drawLabel(2, "TICK")
        drawCell(1, 2, fmt(tickN), na(tickN) ? greyColour : tickN >= 0 ? greenColour : redColour)
        drawCell(2, 2, fmt(tickNChange), changeColour(tickNChange, 50, true))
        drawCell(3, 2, fmt(tickQ), na(tickQ) ? greyColour : tickQ >= 0 ? greenColour : redColour)
        drawCell(4, 2, fmt(tickQChange), changeColour(tickQChange, 50, true))
        drawCheat(2, "Upticking stocks minus downticking stocks.")

        drawLabel(3, "ADD")
        drawCell(1, 3, fmt(addN), na(addN) ? greyColour : addN >= 0 ? greenColour : redColour)
        drawCell(2, 3, fmt(addNChange), changeColour(addNChange, 100, true))
        drawCell(3, 3, fmt(addQ), na(addQ) ? greyColour : addQ >= 0 ? greenColour : redColour)
        drawCell(4, 3, fmt(addQChange), changeColour(addQChange, 100, true))
        drawCheat(3, "Advancing issues minus declining issues.")

        drawLabel(4, "VOLD")
        drawCell(1, 4, fmt(voldN), na(voldN) ? greyColour : voldN >= 0 ? greenColour : redColour)
        drawCell(2, 4, fmt(voldNChange), changeColour(voldNChange, 10000000, true))
        drawCell(3, 4, fmt(voldQ), na(voldQ) ? greyColour : voldQ >= 0 ? greenColour : redColour)
        drawCell(4, 4, fmt(voldQChange), changeColour(voldQChange, 10000000, true))
        drawCheat(4, "Up-volume minus down-volume.")

        drawLabel(5, "TRIN")
        drawCell(1, 5, fmt(trinN), na(trinN) ? greyColour : trinN <= 1 ? greenColour : redColour)
        drawCell(2, 5, fmt(trinNChange), changeColour(trinNChange, 0.05, false))
        drawCell(3, 5, fmt(trinQ), na(trinQ) ? greyColour : trinQ <= 1 ? greenColour : redColour)
        drawCell(4, 5, fmt(trinQChange), changeColour(trinQChange, 0.05, false))
        drawCheat(5, "Arms Index. Around 1 is balanced; higher usually means heavier declining volume.")

        drawLabel(6, "Smoothed Average")
        drawCell(1, 6, "TICK " + fmt(tickNAvg) + "\nADD " + fmt(addNAvg), greyColour)
        drawCell(2, 6, "VOLD " + fmt(voldNAvg) + "\nTRIN " + fmt(trinNAvg), greyColour)
        drawCell(3, 6, "TICK " + fmt(tickQAvg) + "\nADD " + fmt(addQAvg), greyColour)
        drawCell(4, 6, "VOLD " + fmt(voldQAvg) + "\nTRIN " + fmt(trinQAvg), greyColour)
        drawCheat(6, "12-bar average smooths short-lived internal-market spikes.")


//======================================================================
// PAGE 5 - VOLATILITY
//======================================================================

if dashboardPage == "Volatility"

    [vix, vixWeek, vixZ, vix126High] = getVolatilityStats(vixSymbol)
    [vxn, vxnWeek, vxnZ, vxn126High] = getVolatilityStats(vxnSymbol)
    [vix3m, vix3mWeek, vix3mZ, vix3m126High] = getVolatilityStats(vix3mSymbol)
    [move, moveWeek, moveZ, move126High] = getVolatilityStats(moveSymbol)

    if barstate.islast and showDashboard

        float vixCurve = na

        if not na(vix) and not na(vix3m) and vix3m != 0
            vixCurve := vix / vix3m

        drawSection(0, "VOLATILITY / STRESS")

        drawCell(0, 1, "Measure", headerColour)
        drawCell(1, 1, "Current", headerColour)
        drawCell(2, 1, "1W Change", headerColour)
        drawCell(3, 1, "21D Z", headerColour)
        drawCell(4, 1, "Dev 6M High", headerColour)
        drawCell(5, 1, "Cheat Sheet", headerColour)

        drawLabel(2, "VIX")
        drawCell(1, 2, fmt(vix), greyColour)
        drawCell(2, 2, fmtSignedPct(vixWeek), changeColour(vixWeek, 2, false))
        drawCell(3, 2, fmtZ(vixZ), zColour(vixZ))
        drawCell(4, 2, fmtPct(vix126High), blueColour)
        drawCheat(2, "S&P 500 implied volatility. Rapid rises generally indicate increasing equity stress.")

        drawLabel(3, "VXN")
        drawCell(1, 3, fmt(vxn), greyColour)
        drawCell(2, 3, fmtSignedPct(vxnWeek), changeColour(vxnWeek, 2, false))
        drawCell(3, 3, fmtZ(vxnZ), zColour(vxnZ))
        drawCell(4, 3, fmtPct(vxn126High), blueColour)
        drawCheat(3, "Nasdaq-100 implied volatility.")

        drawLabel(4, "VIX 3-Month")
        drawCell(1, 4, fmt(vix3m), greyColour)
        drawCell(2, 4, fmtSignedPct(vix3mWeek), changeColour(vix3mWeek, 2, false))
        drawCell(3, 4, fmtZ(vix3mZ), zColour(vix3mZ))
        drawCell(4, 4, fmtPct(vix3m126High), blueColour)
        drawCheat(4, "Three-month volatility expectation; useful for term structure.")

        drawLabel(5, "MOVE")
        drawCell(1, 5, fmt(move), greyColour)
        drawCell(2, 5, fmtSignedPct(moveWeek), changeColour(moveWeek, 2, false))
        drawCell(3, 5, fmtZ(moveZ), zColour(moveZ))
        drawCell(4, 5, fmtPct(move126High), blueColour)
        drawCheat(5, "Treasury-market implied volatility; often called the bond-market VIX.")

        drawLabel(6, "VIX / VIX3M")
        drawCell(1, 6, fmt(vixCurve), na(vixCurve) ? greyColour : vixCurve > 1 ? redColour : greenColour)
        drawCell(2, 6, "-", greyColour)
        drawCell(3, 6, "-", greyColour)
        drawCell(4, 6, "-", greyColour)
        drawCheat(6, ">1 means short-dated implied volatility exceeds three-month volatility.")


//======================================================================
// PAGE 6 - BONDS & CREDIT
//======================================================================

if dashboardPage == "Bonds & Credit"

    [us03m, us03mPrev, us03mWeek] = getRate(us03mSymbol)
    [us02, us02Prev, us02Week] = getRate(us02Symbol)
    [us05, us05Prev, us05Week] = getRate(us05Symbol)
    [us10, us10Prev, us10Week] = getRate(us10Symbol)
    [us30, us30Prev, us30Week] = getRate(us30Symbol)

    [real10, real10Week] = getDailyMacro(real10Symbol)
    [breakeven10, breakeven10Week] = getDailyMacro(breakeven10Symbol)
    [hySpread, hySpreadWeek] = getDailyMacro(hySpreadSymbol)

    [tlt, tltWeek, tlt30High, tlt200MA] = getMacroAsset(tltSymbol)
    [hyg, hygWeek, hyg30High, hyg200MA] = getMacroAsset(hygSymbol)
    [lqd, lqdWeek, lqd30High, lqd200MA] = getMacroAsset(lqdSymbol)

    if barstate.islast and showDashboard

        float spread3m10y = na
        float spread2s10s = na
        float spread2s30s = na
        float spread10s30s = na

        if not na(us10) and not na(us03m)
            spread3m10y := (us10 - us03m) * 100.0

        if not na(us10) and not na(us02)
            spread2s10s := (us10 - us02) * 100.0

        if not na(us30) and not na(us02)
            spread2s30s := (us30 - us02) * 100.0

        if not na(us30) and not na(us10)
            spread10s30s := (us30 - us10) * 100.0

        float spread3m10yPrev = na
        float spread2s10sPrev = na
        float spread2s30sPrev = na
        float spread10s30sPrev = na

        if not na(us10Prev) and not na(us03mPrev)
            spread3m10yPrev := (us10Prev - us03mPrev) * 100.0

        if not na(us10Prev) and not na(us02Prev)
            spread2s10sPrev := (us10Prev - us02Prev) * 100.0

        if not na(us30Prev) and not na(us02Prev)
            spread2s30sPrev := (us30Prev - us02Prev) * 100.0

        if not na(us30Prev) and not na(us10Prev)
            spread10s30sPrev := (us30Prev - us10Prev) * 100.0

        float spread3m10yChange = na
        float spread2s10sChange = na
        float spread2s30sChange = na
        float spread10s30sChange = na

        if not na(spread3m10y) and not na(spread3m10yPrev)
            spread3m10yChange := spread3m10y - spread3m10yPrev

        if not na(spread2s10s) and not na(spread2s10sPrev)
            spread2s10sChange := spread2s10s - spread2s10sPrev

        if not na(spread2s30s) and not na(spread2s30sPrev)
            spread2s30sChange := spread2s30s - spread2s30sPrev

        if not na(spread10s30s) and not na(spread10s30sPrev)
            spread10s30sChange := spread10s30s - spread10s30sPrev

        float hygLqd = na

        if not na(hyg) and not na(lqd) and lqd != 0
            hygLqd := hyg / lqd

        float hygTlt = na

        if not na(hyg) and not na(tlt) and tlt != 0
            hygTlt := hyg / tlt

        int invertedCount = 0

        if not na(spread3m10y) and spread3m10y < 0
            invertedCount += 1

        if not na(spread2s10s) and spread2s10s < 0
            invertedCount += 1

        if not na(spread2s30s) and spread2s30s < 0
            invertedCount += 1

        string overallCurve = "N/A"
        color overallCurveColour = greyColour

        if invertedCount == 0
            overallCurve := "NO KEY INVERSIONS"
            overallCurveColour := greenColour
        else if invertedCount == 1
            overallCurve := "PARTIALLY INVERTED"
            overallCurveColour := yellowColour
        else
            overallCurve := "BROADLY INVERTED"
            overallCurveColour := redColour

        string move2s10s =
             curveMoveType(
                 us02,
                 us02Prev,
                 us10,
                 us10Prev
             )

        string move3m10y =
             curveMoveType(
                 us03m,
                 us03mPrev,
                 us10,
                 us10Prev
             )

        drawSection(0, "US TREASURY CURVE")

        drawCell(0, 1, "Maturity", headerColour)
        drawCell(1, 1, "Yield", headerColour)
        drawCell(2, 1, "1W Change", headerColour)
        drawCell(3, 1, "Prior Week", headerColour)
        drawCell(4, 1, "Role", headerColour)
        drawCell(5, 1, "Cheat Sheet", headerColour)

        drawLabel(2, "3M")
        drawCell(1, 2, fmtPct(us03m), greyColour)
        drawCell(2, 2, fmtBp(us03mWeek), changeColour(us03mWeek, rateNeutralBand, false))
        drawCell(3, 2, fmtPct(us03mPrev), greyColour)
        drawCell(4, 2, "Very Short", blueColour)
        drawCheat(2, "Very short Treasury rate; useful against 10Y when monitoring inversion.")

        drawLabel(3, "2Y")
        drawCell(1, 3, fmtPct(us02), greyColour)
        drawCell(2, 3, fmtBp(us02Week), changeColour(us02Week, rateNeutralBand, false))
        drawCell(3, 3, fmtPct(us02Prev), greyColour)
        drawCell(4, 3, "Policy", blueColour)
        drawCheat(3, "Highly sensitive to expectations for Federal Reserve policy.")

        drawLabel(4, "5Y")
        drawCell(1, 4, fmtPct(us05), greyColour)
        drawCell(2, 4, fmtBp(us05Week), changeColour(us05Week, rateNeutralBand, false))
        drawCell(3, 4, fmtPct(us05Prev), greyColour)
        drawCell(4, 4, "Intermediate", blueColour)
        drawCheat(4, "Intermediate point between policy-sensitive and long-duration yields.")

        drawLabel(5, "10Y")
        drawCell(1, 5, fmtPct(us10), greyColour)
        drawCell(2, 5, fmtBp(us10Week), changeColour(us10Week, rateNeutralBand, false))
        drawCell(3, 5, fmtPct(us10Prev), greyColour)
        drawCell(4, 5, "Benchmark", blueColour)
        drawCheat(5, "Major global benchmark and discount rate for asset valuation.")

        drawLabel(6, "30Y")
        drawCell(1, 6, fmtPct(us30), greyColour)
        drawCell(2, 6, fmtBp(us30Week), changeColour(us30Week, rateNeutralBand, false))
        drawCell(3, 6, fmtPct(us30Prev), greyColour)
        drawCell(4, 6, "Long End", blueColour)
        drawCheat(6, "Long-duration Treasury yield; sensitive to term premium and long-run inflation expectations.")

        drawSection(7, "YIELD CURVE / INVERSION")

        drawCell(0, 8, "Spread", headerColour)
        drawCell(1, 8, "Current", headerColour)
        drawCell(2, 8, "1W Change", headerColour)
        drawCell(3, 8, "Status", headerColour)
        drawCell(4, 8, "Direction", headerColour)
        drawCell(5, 8, "Cheat Sheet", headerColour)

        drawLabel(9, "10Y - 3M")
        drawCell(1, 9, fmtBp(spread3m10y), curveStatusColour(spread3m10y))
        drawCell(2, 9, fmtBp(spread3m10yChange), na(spread3m10yChange) ? greyColour : spread3m10yChange > 0 ? greenColour : spread3m10yChange < 0 ? redColour : yellowColour)
        drawCell(3, 9, curveStatus(spread3m10y), curveStatusColour(spread3m10y))
        drawCell(4, 9, curveDirection(spread3m10y, spread3m10yPrev), greyColour)
        drawCheat(9, "Negative means the 3M yield exceeds the 10Y yield. Moving toward zero = normalising.")

        drawLabel(10, "10Y - 2Y")
        drawCell(1, 10, fmtBp(spread2s10s), curveStatusColour(spread2s10s))
        drawCell(2, 10, fmtBp(spread2s10sChange), na(spread2s10sChange) ? greyColour : spread2s10sChange > 0 ? greenColour : spread2s10sChange < 0 ? redColour : yellowColour)
        drawCell(3, 10, curveStatus(spread2s10s), curveStatusColour(spread2s10s))
        drawCell(4, 10, curveDirection(spread2s10s, spread2s10sPrev), greyColour)
        drawCheat(10, "Negative means the 2Y yield exceeds the 10Y yield. A classic curve-inversion measure.")

        drawLabel(11, "30Y - 2Y")
        drawCell(1, 11, fmtBp(spread2s30s), curveStatusColour(spread2s30s))
        drawCell(2, 11, fmtBp(spread2s30sChange), na(spread2s30sChange) ? greyColour : spread2s30sChange > 0 ? greenColour : spread2s30sChange < 0 ? redColour : yellowColour)
        drawCell(3, 11, curveStatus(spread2s30s), curveStatusColour(spread2s30s))
        drawCell(4, 11, curveDirection(spread2s30s, spread2s30sPrev), greyColour)
        drawCheat(11, "Compares the policy-sensitive 2Y yield with the long end of the Treasury curve.")

        drawLabel(12, "30Y - 10Y")
        drawCell(1, 12, fmtBp(spread10s30s), curveStatusColour(spread10s30s))
        drawCell(2, 12, fmtBp(spread10s30sChange), na(spread10s30sChange) ? greyColour : spread10s30sChange > 0 ? greenColour : spread10s30sChange < 0 ? redColour : yellowColour)
        drawCell(3, 12, curveStatus(spread10s30s), curveStatusColour(spread10s30s))
        drawCell(4, 12, curveDirection(spread10s30s, spread10s30sPrev), greyColour)
        drawCheat(12, "Shows the shape of the long end of the Treasury curve.")

        drawLabel(13, "Overall Curve")
        drawCell(1, 13, overallCurve, overallCurveColour)
        drawCell(2, 13, "2s10s\n" + move2s10s, greyColour)
        drawCell(3, 13, "3m10y\n" + move3m10y, greyColour)
        drawCell(4, 13, "Key inversions: " + str.tostring(invertedCount), overallCurveColour)
        drawCheat(13, "Inversion describes curve shape, not a precise market-timing signal. Direction and cause matter.")

        drawSection(14, "REAL RATES / INFLATION / CREDIT")

        drawLabel(15, "10Y Real Yield")
        drawCell(1, 15, fmtPct(real10), greyColour)
        drawCell(2, 15, fmtPoints(real10Week), changeColour(real10Week, 0.05, false))
        drawCell(3, 15, "-", greyColour)
        drawCell(4, 15, "Real discount rate", blueColour)
        drawCheat(15, "Inflation-adjusted 10Y yield. Rising real yields increase the real discount rate.")

        drawLabel(16, "10Y Breakeven")
        drawCell(1, 16, fmtPct(breakeven10), greyColour)
        drawCell(2, 16, fmtPoints(breakeven10Week), yellowColour)
        drawCell(3, 16, "-", greyColour)
        drawCell(4, 16, "Inflation expectation", blueColour)
        drawCheat(16, "Market-implied average inflation expectation over approximately ten years.")

        drawLabel(17, "HY Credit Spread")
        drawCell(1, 17, fmtPct(hySpread), greyColour)
        drawCell(2, 17, fmtPoints(hySpreadWeek), changeColour(hySpreadWeek, 0.05, false))
        drawCell(3, 17, "-", greyColour)
        drawCell(4, 17, "Credit stress", blueColour)
        drawCheat(17, "Wider spreads mean investors demand more compensation for lower-quality corporate credit.")

        drawLabel(18, "TLT")
        drawCell(1, 18, fmt(tlt), greyColour)
        drawCell(2, 18, fmtSignedPct(tltWeek), priceColour(tltWeek))
        drawCell(3, 18, fmtPct(tlt30High), blueColour)
        drawCell(4, 18, fmtPct(tlt200MA), na(tlt200MA) ? greyColour : tlt200MA >= 0 ? greenColour : redColour)
        drawCheat(18, "Long-duration Treasury ETF; generally moves inversely to long Treasury yields.")

        drawLabel(19, "HYG")
        drawCell(1, 19, fmt(hyg), greyColour)
        drawCell(2, 19, fmtSignedPct(hygWeek), priceColour(hygWeek))
        drawCell(3, 19, fmtPct(hyg30High), blueColour)
        drawCell(4, 19, fmtPct(hyg200MA), na(hyg200MA) ? greyColour : hyg200MA >= 0 ? greenColour : redColour)
        drawCheat(19, "High-yield corporate credit. Weakness can indicate deteriorating risk appetite.")

        drawLabel(20, "HYG / LQD")
        drawCell(1, 20, fmt(hygLqd), greyColour)
        drawCell(2, 20, "-", greyColour)
        drawCell(3, 20, "-", greyColour)
        drawCell(4, 20, "Risk / Quality", blueColour)
        drawCheat(20, "Rising means high-yield credit is outperforming investment-grade corporate bonds.")

        drawLabel(21, "HYG / TLT")
        drawCell(1, 21, fmt(hygTlt), greyColour)
        drawCell(2, 21, "-", greyColour)
        drawCell(3, 21, "-", greyColour)
        drawCell(4, 21, "Credit / Treasury", blueColour)
        drawCheat(21, "Rising means risky credit is outperforming defensive long-duration Treasuries.")


//======================================================================
// PAGE 7 - COMMODITIES
//======================================================================

if dashboardPage == "Commodities"

    [gold, goldWeek, gold30High, gold200MA] = getMacroAsset(goldSymbol)
    [silver, silverWeek, silver30High, silver200MA] = getMacroAsset(silverSymbol)
    [copper, copperWeek, copper30High, copper200MA] = getMacroAsset(copperSymbol)
    [wti, wtiWeek, wti30High, wti200MA] = getMacroAsset(wtiSymbol)
    [brent, brentWeek, brent30High, brent200MA] = getMacroAsset(brentSymbol)
    [gas, gasWeek, gas30High, gas200MA] = getMacroAsset(gasSymbol)
    [bcom, bcomWeek, bcom30High, bcom200MA] = getMacroAsset(bcomSymbol)
    [dxy, dxyWeek, dxy30High, dxy200MA] = getMacroAsset(dxySymbol)

    if barstate.islast and showDashboard

        float copperGold = na
        if not na(copper) and not na(gold) and gold != 0
            copperGold := copper / gold

        float goldSilver = na
        if not na(gold) and not na(silver) and silver != 0
            goldSilver := gold / silver

        float wtiGold = na
        if not na(wti) and not na(gold) and gold != 0
            wtiGold := wti / gold

        drawSection(0, "COMMODITIES / DOLLAR")

        drawCell(0, 1, "Measure", headerColour)
        drawCell(1, 1, "Current", headerColour)
        drawCell(2, 1, "1W", headerColour)
        drawCell(3, 1, "Dev 30W High", headerColour)
        drawCell(4, 1, "Dev 200W MA", headerColour)
        drawCell(5, 1, "Cheat Sheet", headerColour)

        drawLabel(2, "Gold")
        drawCell(1, 2, fmt(gold), greyColour)
        drawCell(2, 2, fmtSignedPct(goldWeek), priceColour(goldWeek))
        drawCell(3, 2, fmtPct(gold30High), blueColour)
        drawCell(4, 2, fmtPct(gold200MA), na(gold200MA) ? greyColour : gold200MA >= 0 ? greenColour : redColour)
        drawCheat(2, "Precious and monetary asset. Interpret alongside real yields and the U.S. dollar.")

        drawLabel(3, "Silver")
        drawCell(1, 3, fmt(silver), greyColour)
        drawCell(2, 3, fmtSignedPct(silverWeek), priceColour(silverWeek))
        drawCell(3, 3, fmtPct(silver30High), blueColour)
        drawCell(4, 3, fmtPct(silver200MA), na(silver200MA) ? greyColour : silver200MA >= 0 ? greenColour : redColour)
        drawCheat(3, "Precious and industrial metal; often higher beta than gold.")

        drawLabel(4, "Copper")
        drawCell(1, 4, fmt(copper), greyColour)
        drawCell(2, 4, fmtSignedPct(copperWeek), priceColour(copperWeek))
        drawCell(3, 4, fmtPct(copper30High), blueColour)
        drawCell(4, 4, fmtPct(copper200MA), na(copper200MA) ? greyColour : copper200MA >= 0 ? greenColour : redColour)
        drawCheat(4, "Industrial metal often associated with global cyclical demand.")

        drawLabel(5, "WTI")
        drawCell(1, 5, fmt(wti), greyColour)
        drawCell(2, 5, fmtSignedPct(wtiWeek), priceColour(wtiWeek))
        drawCell(3, 5, fmtPct(wti30High), blueColour)
        drawCell(4, 5, fmtPct(wti200MA), na(wti200MA) ? greyColour : wti200MA >= 0 ? greenColour : redColour)
        drawCheat(5, "U.S. crude benchmark and important inflation input.")

        drawLabel(6, "Brent")
        drawCell(1, 6, fmt(brent), greyColour)
        drawCell(2, 6, fmtSignedPct(brentWeek), priceColour(brentWeek))
        drawCell(3, 6, fmtPct(brent30High), blueColour)
        drawCell(4, 6, fmtPct(brent200MA), na(brent200MA) ? greyColour : brent200MA >= 0 ? greenColour : redColour)
        drawCheat(6, "Global crude-oil benchmark.")

        drawLabel(7, "Natural Gas")
        drawCell(1, 7, fmt(gas), greyColour)
        drawCell(2, 7, fmtSignedPct(gasWeek), priceColour(gasWeek))
        drawCell(3, 7, fmtPct(gas30High), blueColour)
        drawCell(4, 7, fmtPct(gas200MA), na(gas200MA) ? greyColour : gas200MA >= 0 ? greenColour : redColour)
        drawCheat(7, "Highly volatile and seasonal energy market.")

        drawLabel(8, "Broad Commodities")
        drawCell(1, 8, fmt(bcom), greyColour)
        drawCell(2, 8, fmtSignedPct(bcomWeek), priceColour(bcomWeek))
        drawCell(3, 8, fmtPct(bcom30High), blueColour)
        drawCell(4, 8, fmtPct(bcom200MA), na(bcom200MA) ? greyColour : bcom200MA >= 0 ? greenColour : redColour)
        drawCheat(8, "Shows whether commodity strength is widespread rather than isolated.")

        drawLabel(9, "DXY")
        drawCell(1, 9, fmt(dxy), greyColour)
        drawCell(2, 9, fmtSignedPct(dxyWeek), changeColour(dxyWeek, priceNeutralBand, false))
        drawCell(3, 9, fmtPct(dxy30High), blueColour)
        drawCell(4, 9, fmtPct(dxy200MA), greyColour)
        drawCheat(9, "A stronger dollar can tighten global financial conditions.")

        drawLabel(10, "Copper / Gold")
        drawCell(1, 10, fmt(copperGold), greyColour)
        drawCell(2, 10, "-", greyColour)
        drawCell(3, 10, "-", greyColour)
        drawCell(4, 10, "-", greyColour)
        drawCheat(10, "Rising means copper is outperforming gold; often stronger cyclical relative performance.")

        drawLabel(11, "Gold / Silver")
        drawCell(1, 11, fmt(goldSilver), greyColour)
        drawCell(2, 11, "-", greyColour)
        drawCell(3, 11, "-", greyColour)
        drawCell(4, 11, "-", greyColour)
        drawCheat(11, "Rising means gold is outperforming silver.")

        drawLabel(12, "WTI / Gold")
        drawCell(1, 12, fmt(wtiGold), greyColour)
        drawCell(2, 12, "-", greyColour)
        drawCell(3, 12, "-", greyColour)
        drawCell(4, 12, "-", greyColour)
        drawCheat(12, "Shows energy performance relative to gold.")


//======================================================================
// PAGE 8 - RELATIVE PERFORMANCE
//======================================================================

if dashboardPage == "Relative Performance"

    [sp1w, sp1m, sp3m, sp6m] = getPerformance(spxSymbol)
    [nd1w, nd1m, nd3m, nd6m] = getPerformance(ndxSymbol)
    [rut1w, rut1m, rut3m, rut6m] = getPerformance(rutSymbol)
    [tlt1w, tlt1m, tlt3m, tlt6m] = getPerformance(tltSymbol)
    [hyg1w, hyg1m, hyg3m, hyg6m] = getPerformance(hygSymbol)
    [gold1w, gold1m, gold3m, gold6m] = getPerformance(goldSymbol)
    [copper1w, copper1m, copper3m, copper6m] = getPerformance(copperSymbol)
    [wti1w, wti1m, wti3m, wti6m] = getPerformance(wtiSymbol)
    [dxy1w, dxy1m, dxy3m, dxy6m] = getPerformance(dxySymbol)
    [btc1w, btc1m, btc3m, btc6m] = getPerformance(btcSymbol)

    if barstate.islast and showDashboard

        drawSection(0, "CROSS-ASSET RELATIVE PERFORMANCE")

        drawCell(0, 1, "Asset", headerColour)
        drawCell(1, 1, "1W", headerColour)
        drawCell(2, 1, "1M", headerColour)
        drawCell(3, 1, "3M", headerColour)
        drawCell(4, 1, "6M", headerColour)
        drawCell(5, 1, "Cheat Sheet", headerColour)

        drawLabel(2, "S&P 500")
        drawCell(1, 2, fmtSignedPct(sp1w), priceColour(sp1w))
        drawCell(2, 2, fmtSignedPct(sp1m), priceColour(sp1m))
        drawCell(3, 2, fmtSignedPct(sp3m), priceColour(sp3m))
        drawCell(4, 2, fmtSignedPct(sp6m), priceColour(sp6m))
        drawCheat(2, "Large-cap U.S. equity performance.")

        drawLabel(3, "Nasdaq 100")
        drawCell(1, 3, fmtSignedPct(nd1w), priceColour(nd1w))
        drawCell(2, 3, fmtSignedPct(nd1m), priceColour(nd1m))
        drawCell(3, 3, fmtSignedPct(nd3m), priceColour(nd3m))
        drawCell(4, 3, fmtSignedPct(nd6m), priceColour(nd6m))
        drawCheat(3, "Growth and technology relative performance.")

        drawLabel(4, "Russell 2000")
        drawCell(1, 4, fmtSignedPct(rut1w), priceColour(rut1w))
        drawCell(2, 4, fmtSignedPct(rut1m), priceColour(rut1m))
        drawCell(3, 4, fmtSignedPct(rut3m), priceColour(rut3m))
        drawCell(4, 4, fmtSignedPct(rut6m), priceColour(rut6m))
        drawCheat(4, "Small-cap and domestic-risk performance.")

        drawLabel(5, "TLT")
        drawCell(1, 5, fmtSignedPct(tlt1w), priceColour(tlt1w))
        drawCell(2, 5, fmtSignedPct(tlt1m), priceColour(tlt1m))
        drawCell(3, 5, fmtSignedPct(tlt3m), priceColour(tlt3m))
        drawCell(4, 5, fmtSignedPct(tlt6m), priceColour(tlt6m))
        drawCheat(5, "Long-duration Treasury performance.")

        drawLabel(6, "HYG")
        drawCell(1, 6, fmtSignedPct(hyg1w), priceColour(hyg1w))
        drawCell(2, 6, fmtSignedPct(hyg1m), priceColour(hyg1m))
        drawCell(3, 6, fmtSignedPct(hyg3m), priceColour(hyg3m))
        drawCell(4, 6, fmtSignedPct(hyg6m), priceColour(hyg6m))
        drawCheat(6, "High-yield corporate credit performance.")

        drawLabel(7, "Gold")
        drawCell(1, 7, fmtSignedPct(gold1w), priceColour(gold1w))
        drawCell(2, 7, fmtSignedPct(gold1m), priceColour(gold1m))
        drawCell(3, 7, fmtSignedPct(gold3m), priceColour(gold3m))
        drawCell(4, 7, fmtSignedPct(gold6m), priceColour(gold6m))
        drawCheat(7, "Precious and monetary asset performance.")

        drawLabel(8, "Copper")
        drawCell(1, 8, fmtSignedPct(copper1w), priceColour(copper1w))
        drawCell(2, 8, fmtSignedPct(copper1m), priceColour(copper1m))
        drawCell(3, 8, fmtSignedPct(copper3m), priceColour(copper3m))
        drawCell(4, 8, fmtSignedPct(copper6m), priceColour(copper6m))
        drawCheat(8, "Industrial/global cyclical metal performance.")

        drawLabel(9, "WTI")
        drawCell(1, 9, fmtSignedPct(wti1w), priceColour(wti1w))
        drawCell(2, 9, fmtSignedPct(wti1m), priceColour(wti1m))
        drawCell(3, 9, fmtSignedPct(wti3m), priceColour(wti3m))
        drawCell(4, 9, fmtSignedPct(wti6m), priceColour(wti6m))
        drawCheat(9, "Energy-market performance.")

        drawLabel(10, "DXY")
        drawCell(1, 10, fmtSignedPct(dxy1w), priceColour(dxy1w))
        drawCell(2, 10, fmtSignedPct(dxy1m), priceColour(dxy1m))
        drawCell(3, 10, fmtSignedPct(dxy3m), priceColour(dxy3m))
        drawCell(4, 10, fmtSignedPct(dxy6m), priceColour(dxy6m))
        drawCheat(10, "U.S. dollar performance across multiple horizons.")

        drawLabel(11, "Bitcoin")
        drawCell(1, 11, fmtSignedPct(btc1w), priceColour(btc1w))
        drawCell(2, 11, fmtSignedPct(btc1m), priceColour(btc1m))
        drawCell(3, 11, fmtSignedPct(btc3m), priceColour(btc3m))
        drawCell(4, 11, fmtSignedPct(btc6m), priceColour(btc6m))
        drawCheat(11, "Crypto risk-asset performance for comparison with traditional markets.")
````
