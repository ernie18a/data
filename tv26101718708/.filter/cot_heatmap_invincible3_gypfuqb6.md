# COT Heatmap [invincible3]

- url: https://www.tradingview.com/script/GyPFuQb6-COT-Heatmap-invincible3/
- type: indicator
- pine_id: PUB;b53e941e193c46d5b09bf56cad84c8be
- version: 3.0

## Description

[b]COT Heatmap [invincible3][/b]

COT Heatmap is a professional Commitment of Traders dashboard designed to visualize historical positioning pressure between two selected markets, currencies, commodities, indices, or crypto futures. The indicator converts weekly COT positioning data into an easy-to-read heatmap table, allowing traders to compare Non-Commercial and Commercial positioning strength, extremes, long/short participation, and A-B spread pressure directly on the chart.

The tool is built for macro, forex, commodities, futures, and intermarket analysis. It can automatically detect the current chart symbol or allow the user to manually select Pair A and Pair B from a predefined COT market list.

-----------------------------------------------------------------------------------------------

[b]Main Features[/b]
[list]
[*] Historical COT heatmap table
[*]Auto symbol detection from the chart
[*]Manual Pair A / Pair B selection
[*]Futures Only or Futures + Options data mode
[*]Non-Commercial, Commercial, or Both participant modes
[*]Separate metric control for Pair A and Pair B
[*]Historical weekly values displayed by date
[*]Adjustable table size, position, start date, and number of periods
[*]Heatmap coloring for fast visual interpretation
[*]Optional A-B positioning spread columns
[/list]
-----------------------------------------------------------------------------------------------

[b] Data Source[/b]

The indicator uses weekly COT data through TradingView’s COT Library.

Available data modes:

[b]Futures Only[/b]
Uses futures positioning data only.

[b]Futures and Options[/b]
Uses combined futures and options positioning data.

The indicator uses Legacy COT report categories:
[list]
[*]Non-Commercial Positions
[*]Commercial Positions
[*]Open Interest
[/list]
All COT calculations are performed on the weekly timeframe.

-----------------------------------------------------------------------------------------------

[b]Participant Modes[/b]

The indicator supports three participant display modes:

[b]Non-Commercial Only[/b]
Shows speculative positioning metrics.

[b]Commercial Only[/b]
Shows hedger/commercial positioning metrics.

[b]Both[/b]
Shows both Non-Commercial and Commercial metrics side by side.

-----------------------------------------------------------------------------------------------

[b]Core Positioning Formulas[/b]

For each selected market:

[b]Open Interest[/b]

OI = Total Open Interest

[b]Non-Commercial Net Position[/b]

NC Net = NC Long − NC Short

[b]Commercial Net Position[/b]

Commercial Net = Commercial Long − Commercial Short

[b]Long Change[/b]

Long Change = Current Long − Previous Week Long

[b]Short Change[/b]

Short Change = Current Short − Previous Week Short

[b]Net Change[/b]

Net Change = Long Change − Short Change

-----------------------------------------------------------------------------------------------

[b]Long% and Short% Formulas[/b]

The indicator normalizes long and short positions against open interest.

[b]Long Percentage[/b]

Long% = Long Positions / Open Interest × 100

[b]Short Percentage[/b]

Short% = Short Positions / Open Interest × 100

These values show how much of total open interest is held on the long or short side by a specific participant group.

-----------------------------------------------------------------------------------------------

[b]Flip% Formula[/b]

Flip% measures the net long/short bias as a percentage of open interest.

[b]Flip%[/b]

Flip% = Long% − Short%

Interpretation:
[list]
[*]Positive Flip% = participant group is net long
[*]Negative Flip% = participant group is net short
[*]Higher positive values show stronger bullish positioning
[*]Lower negative values show stronger bearish positioning
[/list]
Example:

If Non-Commercial Long% = 42%
and Non-Commercial Short% = 25%

Then:

NC Flip% = 42 − 25 = +17%

This means Non-Commercial traders are net long by 17% of open interest.

-----------------------------------------------------------------------------------------------

[b]Difference Metrics[/b]

The indicator compares Non-Commercial and Commercial net positioning.

[b]Non-Commercial Difference[/b]

NC Difference = NC Net − Commercial Net

This measures how strongly speculative positioning differs from commercial positioning.

[b]Commercial Difference[/b]

Commercial Difference = Commercial Net − NC Net

This is the inverse view, useful when analyzing commercial hedger pressure.

-----------------------------------------------------------------------------------------------

[b]Diff13 / Diff26 / Diff52 Formulas[/b]

The Diff columns are stochastic-style normalized scores of the positioning difference over different historical windows.

[b]Stochastic Positioning Score[/b]

Stoch(X, Length) =
(X − Lowest(X, Length)) / (Highest(X, Length) − Lowest(X, Length)) × 100

If the range is zero, the value returns 50.

Where:
[list]
[*]X = selected positioning series
[*]Length = 13, 26, or 52 weeks
[/list]
[b]NC Diff13[/b]*

NC Diff13 = Stoch(NC Difference, 13)

[b]NC Diff26[/b]

NC Diff26 = Stoch(NC Difference, 26)

[b]NC Diff52[/b]

NC Diff52 = Stoch(NC Difference, 52)

[b]Commercial Diff13[/b]

Commercial Diff13 = Stoch(Commercial Difference, 13)

[b]Commercial Diff26[/b]

Commercial Diff26 = Stoch(Commercial Difference, 26)

[b]Commercial Diff52[/b]

Commercial Diff52 = Stoch(Commercial Difference, 52)

Interpretation:
[list]
[*]Values near 100 show positioning is near the upper extreme of the selected lookback period
[*]Values near 50 show neutral/mid-range positioning
[*]Values near 0 show positioning is near the lower extreme of the selected lookback period
[/list]
-----------------------------------------------------------------------------------------------

[b]COT Index Formulas[/b]

The COT Index measures where current net positioning stands relative to its own historical range.

[b]COT Index[/b]

COT Index =
(Current Net Position − Lowest Net Position over N weeks) /
(Highest Net Position over N weeks − Lowest Net Position over N weeks) × 100

If the range is zero, the value returns 50.

-----------------------------------------------------------------------------------------------

[b]Non-Commercial COT Index[/b]

[b]NC Index 52[/b]

NCIdx52 = Stoch(NC Net, 52)

This shows where current Non-Commercial net positioning stands within its 1-year range.

[b]NC Index 156[/b]

NCIdx156 = Stoch(NC Net, 156)

This shows where current Non-Commercial net positioning stands within its 3-year range.

-----------------------------------------------------------------------------------------------

[b]Commercial COT Index[/b]

[b]Commercial Index 52[/b]

ComIdx52 = Stoch(Commercial Net, 52)

This shows where current Commercial net positioning stands within its 1-year range.

[b]Commercial Index 156[/b]

ComIdx156 = Stoch(Commercial Net, 156)

This shows where current Commercial net positioning stands within its 3-year range.

-----------------------------------------------------------------------------------------------

[b]A-B Spread Formulas[/b]

The indicator can also compare Pair A and Pair B positioning directly.

[b]A-B Non-Commercial Flip%[/b]

A-B NC Flip% = Pair A NC Flip% − Pair B NC Flip%

[b]A-B Commercial Flip%[/b]

A-B Commercial Flip% = Pair A Commercial Flip% − Pair B Commercial Flip%

Interpretation:
[list]
[*]Positive A-B Flip% means Pair A has stronger positioning than Pair B
[*]Negative A-B Flip% means Pair B has stronger positioning than Pair A
[*]Useful for forex pair analysis, relative commodity analysis, and intermarket comparison
[/list]
Example:

If EUR NC Flip% = +20%
and USD NC Flip% = +5%

Then:

EUR − USD NC Flip% = +15%

This suggests stronger speculative positioning in EUR relative to USD.

-----------------------------------------------------------------------------------------------

[b]Heatmap Color Logic[/b]

The table uses color gradients to make positioning extremes easy to identify.

For score-based columns such as Diff13, Diff26, Diff52, NCIdx52, NCIdx156, ComIdx52, and ComIdx156:
[list]
[*]High values move toward the positive color
[*]Mid-range values move toward the neutral color
[*]Low values move toward the negative color
[/list]
Default colors:
[list]
[*]Positive: Blue
[*]Neutral: Pink
[*]Negative: Red
[/list]
For Long% columns:
[list]
[*]Higher Long% is treated as stronger
[*]Lower Long% is treated as weaker
[/list]
For Short% columns:
[list]
[*]Higher Short% is treated as weaker
[*]Lower Short% is treated as stronger
[/list]
For Flip% columns:

The heatmap uses a signed scale.

[b]Signed Heatmap Normalization[/b]

Normalized Flip Value =
(Flip% + Flip Scale) / (2 × Flip Scale)

The value is clamped between 0 and 1.

Default Flip Scale = 35%

This means:
[list]
[*]+35% or above = strong positive color
[*]0% = neutral color
[*]−35% or below = strong negative color
[/list]
-----------------------------------------------------------------------------------------------

[b] How to Read the Table[/b]

Each row represents one weekly COT snapshot.

The Date column shows the COT week.

Pair A and Pair B are displayed in separate grouped sections. Each section can include Non-Commercial metrics, Commercial metrics, or both, depending on user settings.

[b]Important interpretation guidelines:[/b]

[b]Diff13 / Diff26 / Diff52[/b]
Shows short-term, medium-term, and 1-year positioning extremes between Non-Commercial and Commercial groups.

[b]NCIdx52 / NCIdx156[/b]
Shows whether speculative positioning is historically stretched or depressed.

[b]ComIdx52 / ComIdx156[/b]
Shows whether commercial hedger positioning is historically stretched or depressed.

[b]Long%[/b]
Shows the long-side participation as a percentage of open interest.

[b]Short%[/b]
Shows the short-side participation as a percentage of open interest.

[b]Flip%[/b]
Shows the net directional bias after subtracting short exposure from long exposure.

[b]A-B Flip%[/b]
Shows relative positioning pressure between the two selected markets.

-----------------------------------------------------------------------------------------------

[b]Example Use Cases[/b]

[b]Forex Analysis[/b]

Use Pair A and Pair B to compare currency futures positioning.

Example:

Pair A = EUR
Pair B = USD

This allows EUR/USD positioning analysis using COT data.

[b]Commodity Analysis[/b]

Compare metals, energy, or agricultural markets.

Example:

Pair A = Gold
Pair B = Silver

This helps identify relative speculative or commercial positioning strength.

[b]Index Analysis[/b]

Compare equity index futures.

Example:

Pair A = NASDAQ
Pair B = S&P 500

This can help identify relative risk appetite and index positioning rotation.

[b]Macro Sentiment Analysis[/b]

Use Non-Commercial positioning to track speculative crowding and Commercial positioning to observe hedging pressure.

-----------------------------------------------------------------------------------------------

[b]Notes[/b]

COT data is weekly and is not designed for intraday signals. This indicator is best used as a macro positioning tool, sentiment confirmation tool, or higher-timeframe market context dashboard.

The heatmap does not generate direct buy or sell signals. Instead, it provides a structured view of positioning extremes, participant behavior, and relative strength between selected COT markets.

Extreme readings can remain extreme for long periods, so COT data should be combined with price action, trend structure, volatility, liquidity, and broader market context.

-----------------------------------------------------------------------------------------------

[b]Summary[/b]

COT Historical Heatmap [invincible3] transforms weekly Commitment of Traders data into a clean, customizable, and visually intuitive positioning dashboard. By combining Net Positioning, Long%, Short%, Flip%, COT Index, Difference Scores, and A-B relative spread analysis, it helps traders understand how Non-Commercial and Commercial participants are positioned across major futures markets.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © invincible3

//@version=6
import TradingView/LibraryCOT/2

indicator("COT Heatmap [invincible3]", overlay=true, max_labels_count=500, dynamic_requests=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA SOURCE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpCOT = "COT Data"

i_dataSource = input.string(
     "Futures Only",
     "Data",
     options=["Futures Only", "Futures and Options"],
     group=grpCOT)

includeOptions = i_dataSource == "Futures and Options"

participantMode = input.string(
     "Non-Commercial Only",
     "Participant Mode",
     options=["Non-Commercial Only", "Commercial Only"],
     group=grpCOT)

showNC  = participantMode == "Non-Commercial Only"
showCom = participantMode == "Commercial Only"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SYMBOL SELECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpSymbol = "Symbol Selection"

symbolMode = input.string(
     "Auto From Chart",
     "Symbol Source",
     options=["Auto From Chart", "Manual From List"],
     group=grpSymbol)

manualA = input.string(
     "EUR",
     "Manual Pair A",
     options=[
         "GOLD", "SILVER", "PLATINUM", "PALLADIUM", "ALUMINUM", "COPPER",
         "CRUDE OIL", "NATURAL GAS", "GASOLINE", "HEATING OIL",
         "WHEAT", "CORN", "SOYBEANS", "SOYBEAN MEAL", "SOYBEAN OIL",
         "COFFEE", "COTTON", "SUGAR", "COCOA", "ORANGE JUICE",
         "LIVE CATTLE", "LEAN HOGS", "FEEDER CATTLE",
         "S&P 500", "S&P 500 Mini", "Dow Jones", "NASDAQ", "NASDAQ Mini", "RUSSELL 2000", "NIKKEI", "Volatility S&P 500",
         "BTC", "ETH",
         "USD", "EUR", "JPY", "GBP", "CHF", "CAD", "AUD", "NZD", "MXN", "BRL", "ZAR", "RUB"
     ],
     group=grpSymbol)

manualB = input.string(
     "USD",
     "Manual Pair B",
     options=[
         "GOLD", "SILVER", "PLATINUM", "PALLADIUM", "ALUMINUM", "COPPER",
         "CRUDE OIL", "NATURAL GAS", "GASOLINE", "HEATING OIL",
         "WHEAT", "CORN", "SOYBEANS", "SOYBEAN MEAL", "SOYBEAN OIL",
         "COFFEE", "COTTON", "SUGAR", "COCOA", "ORANGE JUICE",
         "LIVE CATTLE", "LEAN HOGS", "FEEDER CATTLE",
         "S&P 500", "S&P 500 Mini", "Dow Jones", "NASDAQ", "NASDAQ Mini", "RUSSELL 2000", "NIKKEI", "Volatility S&P 500",
         "BTC", "ETH",
         "USD", "EUR", "JPY", "GBP", "CHF", "CAD", "AUD", "NZD", "MXN", "BRL", "ZAR", "RUB"
     ],
     group=grpSymbol)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HEATMAP TABLE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpTable = "Heatmap Table"

showTable = input.bool(true, "Show Heatmap Table", group=grpTable)

tablePos = input.string(
     "Middle Right",
     "Table Location",
     options=[
         "Top Right", "Middle Right", "Bottom Right",
         "Top Center", "Middle Center", "Bottom Center",
         "Top Left", "Middle Left", "Bottom Left"
     ],
     group=grpTable)

tableSize = input.string(
     "Small",
     "Table Size",
     options=["Auto", "Huge", "Large", "Normal", "Small", "Tiny"],
     group=grpTable)

startDate = input.time(timestamp("01 Jan 2019 00:00"), "Start Date", group=grpTable)
periods   = input.int(25, "Periods", minval=1, maxval=100, group=grpTable)

upCol = input.color(#3B82F6, "Positive", group=grpTable)
mdCol = input.color(#D48CFF, "Neutral", group=grpTable)
dnCol = input.color(#FF5A6E, "Negative", group=grpTable)

flipScale = input.float(35.0, "Flip% Heat Scale", minval=1.0, step=1.0, group=grpTable)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HEATMAP COLUMN OPTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpNCDiffA = "Pair A Non-Commercial"
showNCNetA    = input.bool(true, "NC Net", inline="ANA1", group=grpNCDiffA)
showNCLongA   = input.bool(true, "NC Long%", inline="ANA2", group=grpNCDiffA)
showNCShortA  = input.bool(true, "NC Short%", inline="ANA3", group=grpNCDiffA)
showNCFlipA   = input.bool(true, "NC Flip%", inline="ANA4", group=grpNCDiffA)

showNCDiff13A = input.bool(true, "NC Diff 13", inline="NDA1", group=grpNCDiffA)
showNCDiff26A = input.bool(true, "NC Diff 26", inline="NDA2", group=grpNCDiffA)
showNCDiff52A = input.bool(true, "NC Diff 52", inline="NDA3", group=grpNCDiffA)
showNCIdx52A  = input.bool(true, "NC Index 1yr", inline="AN1", group=grpNCDiffA)
showNCIdx156A = input.bool(true, "NC Index 3yr", inline="AN2", group=grpNCDiffA)

grpComDiffA = "Pair A Commercial"
// Commercial columns default to ON so Commercial Only mode displays immediately.
showComDiff13A = input.bool(true, "Com Diff 13", inline="CDA1", group=grpComDiffA)
showComDiff26A = input.bool(true, "Com Diff 26", inline="CDA2", group=grpComDiffA)
showComDiff52A = input.bool(true, "Com Diff 52", inline="CDA3", group=grpComDiffA)

showComIdx52A  = input.bool(true, "Com Index 1yr", inline="AC1", group=grpComDiffA)
showComIdx156A = input.bool(true, "Com Index 3yr", inline="AC2", group=grpComDiffA)
showComLongA   = input.bool(true, "Com Long%", inline="AC3", group=grpComDiffA)
showComShortA  = input.bool(true, "Com Short%", inline="AC4", group=grpComDiffA)
showComFlipA   = input.bool(true, "Com Flip%", inline="AC5", group=grpComDiffA)

grpNCDiffB = "Pair B Non-Commercial"
showNCNetB    = input.bool(true, "NC Net", inline="BNB1", group=grpNCDiffB)
showNCLongB   = input.bool(true, "NC Long%", inline="BNB2", group=grpNCDiffB)
showNCShortB  = input.bool(true, "NC Short%", inline="BNB3", group=grpNCDiffB)
showNCFlipB   = input.bool(true, "NC Flip%", inline="BNB4", group=grpNCDiffB)

showNCDiff13B = input.bool(true, "NC Diff 13", inline="NDB1", group=grpNCDiffB)
showNCDiff26B = input.bool(true, "NC Diff 26", inline="NDB2", group=grpNCDiffB)
showNCDiff52B = input.bool(true, "NC Diff 52", inline="NDB3", group=grpNCDiffB)
showNCIdx52B  = input.bool(true, "NC Index 1yr", inline="BN1", group=grpNCDiffB)
showNCIdx156B = input.bool(true, "NC Index 3yr", inline="BN2", group=grpNCDiffB)

grpComDiffB = "Pair B Commercial"
showComDiff13B = input.bool(true, "Com Diff 13", inline="CDB1", group=grpComDiffB)
showComDiff26B = input.bool(true, "Com Diff 26", inline="CDB2", group=grpComDiffB)
showComDiff52B = input.bool(true, "Com Diff 52", inline="CDB3", group=grpComDiffB)

showComIdx52B  = input.bool(true, "Com Index 1yr", inline="BC1", group=grpComDiffB)
showComIdx156B = input.bool(true, "Com Index 3yr", inline="BC2", group=grpComDiffB)
showComLongB   = input.bool(true, "Com Long%", inline="BC3", group=grpComDiffB)
showComShortB  = input.bool(true, "Com Short%", inline="BC4", group=grpComDiffB)
showComFlipB   = input.bool(true, "Com Flip%", inline="BC5", group=grpComDiffB)

grpAB = "Pair A-B Spread"
showABNCFlip  = input.bool(false, "A-B NC Flip%", inline="AB1", group=grpAB)
showABComFlip = input.bool(false, "A-B Com Flip%", inline="AB2", group=grpAB)

grpBias = "Positioning Bias"
showBiasA  = input.bool(true, "Show Pair A Bias", inline="BIAS1", group=grpBias)
showBiasB  = input.bool(true, "Show Pair B Bias", inline="BIAS1", group=grpBias)
showABBias = input.bool(true, "Show Relative Bias", group=grpBias,
     tooltip="Shows which selected market has the stronger relative positioning setup. The table uses the actual market names instead of Pair A / Pair B labels.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COT SYMBOL MAPPING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_getTickerCode(name) =>
    switch name
        "GOLD" => "088691"
        "SILVER" => "084691"
        "PLATINUM" => "076651"
        "PALLADIUM" => "075651"
        "ALUMINUM" => "191651"
        "COPPER" => "085692"
        "CRUDE OIL" => "067651"
        "NATURAL GAS" => "023651"
        "GASOLINE" => "111659"
        "HEATING OIL" => "022651"
        "WHEAT" => "001602"
        "CORN" => "002602"
        "SOYBEANS" => "005602"
        "SOYBEAN MEAL" => "026603"
        "SOYBEAN OIL" => "007601"
        "COFFEE" => "009741"
        "COTTON" => "033661"
        "SUGAR" => "014603"
        "COCOA" => "073732"
        "ORANGE JUICE" => "042601"
        "LIVE CATTLE" => "057643"
        "LEAN HOGS" => "054642"
        "FEEDER CATTLE" => "061641"
        "S&P 500" => "13874+"
        "S&P 500 Mini" => "13874A"
        "Dow Jones" => "12460+"
        "NASDAQ" => "20974+"
        "NASDAQ Mini" => "209742"
        "RUSSELL 2000" => "239742"
        "NIKKEI" => "240741"
        "Volatility S&P 500" => "1170E1"
        "BTC" => "133741"
        "ETH" => "146021"
        "USD" => "098662"
        "EUR" => "099741"
        "JPY" => "097741"
        "MXN" => "095741"
        "CHF" => "092741"
        "RUB" => "089741"
        "CAD" => "090741"
        "NZD" => "112741"
        "GBP" => "096742"
        "BRL" => "102741"
        "ZAR" => "122741"
        "AUD" => "232741"
        => ""

f_normalizeName(x) =>
    switch x
        "XAU" => "GOLD"
        "XAUUSD" => "GOLD"
        "GOLD" => "GOLD"
        "GOLD1!" => "GOLD"
        "GC1!" => "GOLD"
        "XAG" => "SILVER"
        "XAGUSD" => "SILVER"
        "SILVER" => "SILVER"
        "SILVER1!" => "SILVER"
        "SI1!" => "SILVER"
        "XPT" => "PLATINUM"
        "XPTUSD" => "PLATINUM"
        "PLATINUM" => "PLATINUM"
        "PLAT1!" => "PLATINUM"
        "XPD" => "PALLADIUM"
        "XPDUSD" => "PALLADIUM"
        "PALLADIUM" => "PALLADIUM"
        "HG1!" => "COPPER"
        "HG" => "COPPER"
        "COPPER" => "COPPER"
        "ALI1!" => "ALUMINUM"
        "ALUMINUM" => "ALUMINUM"
        "CL" => "CRUDE OIL"
        "CL1!" => "CRUDE OIL"
        "CRUDE" => "CRUDE OIL"
        "CRUDEOIL" => "CRUDE OIL"
        "OIL" => "CRUDE OIL"
        "USOIL" => "CRUDE OIL"
        "WTICOUSD" => "CRUDE OIL"
        "NG" => "NATURAL GAS"
        "NG1!" => "NATURAL GAS"
        "NATGAS" => "NATURAL GAS"
        "NATURALGAS" => "NATURAL GAS"
        "GASUSD" => "NATURAL GAS"
        "RB1!" => "GASOLINE"
        "RBOB" => "GASOLINE"
        "HO1!" => "HEATING OIL"
        "HEATOIL" => "HEATING OIL"
        "ZW1!" => "WHEAT"
        "WHEAT" => "WHEAT"
        "ZC1!" => "CORN"
        "CORN" => "CORN"
        "ZS1!" => "SOYBEANS"
        "SOYBEANS" => "SOYBEANS"
        "ZM1!" => "SOYBEAN MEAL"
        "SOYMEAL" => "SOYBEAN MEAL"
        "ZL1!" => "SOYBEAN OIL"
        "SOYOIL" => "SOYBEAN OIL"
        "SOYUSD" => "SOYBEAN OIL"
        "KC1!" => "COFFEE"
        "COFFEE" => "COFFEE"
        "CT1!" => "COTTON"
        "COTTON" => "COTTON"
        "SB1!" => "SUGAR"
        "SUGAR" => "SUGAR"
        "CC1!" => "COCOA"
        "COCOA" => "COCOA"
        "OJ1!" => "ORANGE JUICE"
        "ORANGE JUICE" => "ORANGE JUICE"
        "LE1!" => "LIVE CATTLE"
        "LIVE CATTLE" => "LIVE CATTLE"
        "HE1!" => "LEAN HOGS"
        "LEAN HOGS" => "LEAN HOGS"
        "GF1!" => "FEEDER CATTLE"
        "FEEDER CATTLE" => "FEEDER CATTLE"
        "SPX" => "S&P 500"
        "ES1!" => "S&P 500"
        "SPX500USD" => "S&P 500"
        "XSP" => "S&P 500 Mini"
        "DJI" => "Dow Jones"
        "US30" => "Dow Jones"
        "YM1!" => "Dow Jones"
        "NDX" => "NASDAQ"
        "NASDAQ" => "NASDAQ"
        "US100" => "NASDAQ"
        "NQ1!" => "NASDAQ"
        "NQM" => "NASDAQ"
        "RUT" => "RUSSELL 2000"
        "RTY" => "RUSSELL 2000"
        "RTY1!" => "RUSSELL 2000"
        "NKD" => "NIKKEI"
        "NKD1!" => "NIKKEI"
        "NK225" => "NIKKEI"
        "VIX" => "Volatility S&P 500"
        "BTC" => "BTC"
        "BITCOIN" => "BTC"
        "ETH" => "ETH"
        "ETHEREUM" => "ETH"
        "DXY" => "USD"
        "USD" => "USD"
        "USD1!" => "USD"
        "EUR" => "EUR"
        "EUR1!" => "EUR"
        "EXY" => "EUR"
        "JPY" => "JPY"
        "JPY1!" => "JPY"
        "JXY" => "JPY"
        "JPYX" => "JPY"
        "GBP" => "GBP"
        "GBP1!" => "GBP"
        "BXY" => "GBP"
        "CHF" => "CHF"
        "CHF1!" => "CHF"
        "SXY" => "CHF"
        "CAD" => "CAD"
        "CXY" => "CAD"
        "CXY1!" => "CAD"
        "AUD" => "AUD"
        "AUD1!" => "AUD"
        "AXY" => "AUD"
        "NZD" => "NZD"
        "NZD1!" => "NZD"
        "NXY" => "NZD"
        "MXN" => "MXN"
        "BRL" => "BRL"
        "ZAR" => "ZAR"
        "RUB" => "RUB"
        => x

f_getTicker() =>
    normalizedTicker = f_normalizeName(syminfo.ticker)
    f_getTickerCode(normalizedTicker) == "" ? "" : normalizedTicker

f_autoPairA() =>
    base = syminfo.basecurrency
    tickerName = f_getTicker()
    base != "" ? f_normalizeName(base) : tickerName

f_autoPairB(_a) =>
    quote = syminfo.currency
    q = quote != "" ? f_normalizeName(quote) : "USD"
    q == "" or q == _a ? "USD" : q

autoA = f_autoPairA()
autoB = f_autoPairB(autoA)

currencyA = symbolMode == "Auto From Chart" ? autoA : manualA
currencyB = symbolMode == "Auto From Chart" ? autoB : manualB

codeA = f_getTickerCode(currencyA)
codeB = f_getTickerCode(currencyB)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COT DATA REQUESTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

dataRequest(code, metricName, direction) =>
    if code == ""
        na
    else
        ticker = LibraryCOT.COTTickerid(
             COTType = "Legacy",
             CFTCCode = code,
             includeOptions = includeOptions,
             metricName = metricName,
             metricDirection = direction,
             metricType = "All")
        request.security(
             ticker,
             "W",
             close,
             gaps=barmerge.gaps_off,
             lookahead=barmerge.lookahead_off,
             ignore_invalid_symbol=true)

dataRequestPrev(code, metricName, direction) =>
    if code == ""
        na
    else
        ticker = LibraryCOT.COTTickerid(
             COTType = "Legacy",
             CFTCCode = code,
             includeOptions = includeOptions,
             metricName = metricName,
             metricDirection = direction,
             metricType = "All")
        request.security(
             ticker,
             "W",
             close[1],
             gaps=barmerge.gaps_off,
             lookahead=barmerge.lookahead_off,
             ignore_invalid_symbol=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PAIR A COT CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pairA_openInterest = dataRequest(codeA, "Open Interest", "No direction")

pairA_coms_long = dataRequest(codeA, "Commercial Positions", "Long")
pairA_coms_long_prev = dataRequestPrev(codeA, "Commercial Positions", "Long")
pairA_coms_short = dataRequest(codeA, "Commercial Positions", "Short")
pairA_coms_short_prev = dataRequestPrev(codeA, "Commercial Positions", "Short")

pairA_coms_net_Positions = pairA_coms_long - pairA_coms_short
pairA_coms_longChange = pairA_coms_long - pairA_coms_long_prev
pairA_coms_shortChange = pairA_coms_short - pairA_coms_short_prev
pairA_coms_netChange = pairA_coms_longChange - pairA_coms_shortChange

pairA_coms_long_percentage = pairA_openInterest == 0 ? na : pairA_coms_long / pairA_openInterest * 100.0
pairA_coms_short_percentage = pairA_openInterest == 0 ? na : pairA_coms_short / pairA_openInterest * 100.0
pairA_coms_flip = pairA_coms_long_percentage - pairA_coms_short_percentage

pairA_noncoms_long = dataRequest(codeA, "Noncommercial Positions", "Long")
pairA_noncoms_long_prev = dataRequestPrev(codeA, "Noncommercial Positions", "Long")
pairA_noncoms_short = dataRequest(codeA, "Noncommercial Positions", "Short")
pairA_noncoms_short_prev = dataRequestPrev(codeA, "Noncommercial Positions", "Short")

pairA_noncoms_net_Positions = pairA_noncoms_long - pairA_noncoms_short
pairA_noncoms_longChange = pairA_noncoms_long - pairA_noncoms_long_prev
pairA_noncoms_shortChange = pairA_noncoms_short - pairA_noncoms_short_prev
pairA_noncoms_netChange = pairA_noncoms_longChange - pairA_noncoms_shortChange

pairA_noncoms_long_percentage = pairA_openInterest == 0 ? na : pairA_noncoms_long / pairA_openInterest * 100.0
pairA_noncoms_short_percentage = pairA_openInterest == 0 ? na : pairA_noncoms_short / pairA_openInterest * 100.0
pairA_noncoms_flip = pairA_noncoms_long_percentage - pairA_noncoms_short_percentage

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PAIR B COT CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pairB_openInterest = dataRequest(codeB, "Open Interest", "No direction")

pairB_coms_long = dataRequest(codeB, "Commercial Positions", "Long")
pairB_coms_long_prev = dataRequestPrev(codeB, "Commercial Positions", "Long")
pairB_coms_short = dataRequest(codeB, "Commercial Positions", "Short")
pairB_coms_short_prev = dataRequestPrev(codeB, "Commercial Positions", "Short")

pairB_coms_net_Positions = pairB_coms_long - pairB_coms_short
pairB_coms_longChange = pairB_coms_long - pairB_coms_long_prev
pairB_coms_shortChange = pairB_coms_short - pairB_coms_short_prev
pairB_coms_netChange = pairB_coms_longChange - pairB_coms_shortChange

pairB_coms_long_percentage = pairB_openInterest == 0 ? na : pairB_coms_long / pairB_openInterest * 100.0
pairB_coms_short_percentage = pairB_openInterest == 0 ? na : pairB_coms_short / pairB_openInterest * 100.0
pairB_coms_flip = pairB_coms_long_percentage - pairB_coms_short_percentage

pairB_noncoms_long = dataRequest(codeB, "Noncommercial Positions", "Long")
pairB_noncoms_long_prev = dataRequestPrev(codeB, "Noncommercial Positions", "Long")
pairB_noncoms_short = dataRequest(codeB, "Noncommercial Positions", "Short")
pairB_noncoms_short_prev = dataRequestPrev(codeB, "Noncommercial Positions", "Short")

pairB_noncoms_net_Positions = pairB_noncoms_long - pairB_noncoms_short
pairB_noncoms_longChange = pairB_noncoms_long - pairB_noncoms_long_prev
pairB_noncoms_shortChange = pairB_noncoms_short - pairB_noncoms_short_prev
pairB_noncoms_netChange = pairB_noncoms_longChange - pairB_noncoms_shortChange

pairB_noncoms_long_percentage = pairB_openInterest == 0 ? na : pairB_noncoms_long / pairB_openInterest * 100.0
pairB_noncoms_short_percentage = pairB_openInterest == 0 ? na : pairB_noncoms_short / pairB_openInterest * 100.0
pairB_noncoms_flip = pairB_noncoms_long_percentage - pairB_noncoms_short_percentage

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIFF / COT INDEX CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_stoch(v, len) =>
    lo = ta.lowest(v, len)
    hi = ta.highest(v, len)
    rng = hi - lo
    na(v) or na(lo) or na(hi) ? na : rng == 0 ? 50.0 : (v - lo) / rng * 100.0

ncDifferenceA  = pairA_noncoms_net_Positions - pairA_coms_net_Positions
ncDifferenceB  = pairB_noncoms_net_Positions - pairB_coms_net_Positions

comDifferenceA = pairA_coms_net_Positions - pairA_noncoms_net_Positions
comDifferenceB = pairB_coms_net_Positions - pairB_noncoms_net_Positions

ncDiff13A = request.security(syminfo.tickerid, "W", f_stoch(ncDifferenceA, 13), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ncDiff26A = request.security(syminfo.tickerid, "W", f_stoch(ncDifferenceA, 26), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ncDiff52A = request.security(syminfo.tickerid, "W", f_stoch(ncDifferenceA, 52), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

ncDiff13B = request.security(syminfo.tickerid, "W", f_stoch(ncDifferenceB, 13), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ncDiff26B = request.security(syminfo.tickerid, "W", f_stoch(ncDifferenceB, 26), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ncDiff52B = request.security(syminfo.tickerid, "W", f_stoch(ncDifferenceB, 52), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

comDiff13A = request.security(syminfo.tickerid, "W", f_stoch(comDifferenceA, 13), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
comDiff26A = request.security(syminfo.tickerid, "W", f_stoch(comDifferenceA, 26), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
comDiff52A = request.security(syminfo.tickerid, "W", f_stoch(comDifferenceA, 52), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

comDiff13B = request.security(syminfo.tickerid, "W", f_stoch(comDifferenceB, 13), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
comDiff26B = request.security(syminfo.tickerid, "W", f_stoch(comDifferenceB, 26), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
comDiff52B = request.security(syminfo.tickerid, "W", f_stoch(comDifferenceB, 52), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

ncIdx52A = request.security(syminfo.tickerid, "W", f_stoch(pairA_noncoms_net_Positions, 52), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ncIdx156A = request.security(syminfo.tickerid, "W", f_stoch(pairA_noncoms_net_Positions, 156), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

ncIdx52B = request.security(syminfo.tickerid, "W", f_stoch(pairB_noncoms_net_Positions, 52), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ncIdx156B = request.security(syminfo.tickerid, "W", f_stoch(pairB_noncoms_net_Positions, 156), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

comIdx52A = request.security(syminfo.tickerid, "W", f_stoch(pairA_coms_net_Positions, 52), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
comIdx156A = request.security(syminfo.tickerid, "W", f_stoch(pairA_coms_net_Positions, 156), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

comIdx52B = request.security(syminfo.tickerid, "W", f_stoch(pairB_coms_net_Positions, 52), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
comIdx156B = request.security(syminfo.tickerid, "W", f_stoch(pairB_coms_net_Positions, 156), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTORY ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const int MAX_HISTORY = 100

var int[] timeH = array.new_int()

var float[] aNCDiff13H = array.new_float()
var float[] aNCDiff26H = array.new_float()
var float[] aNCDiff52H = array.new_float()
var float[] aNCIdx52H = array.new_float()
var float[] aNCIdx156H = array.new_float()
var float[] aNCNetH = array.new_float()
var float[] aNCLongPctH = array.new_float()
var float[] aNCShortPctH = array.new_float()
var float[] aNCFlipH = array.new_float()
var float[] aNCNetChangeH = array.new_float()

var float[] aComDiff13H = array.new_float()
var float[] aComDiff26H = array.new_float()
var float[] aComDiff52H = array.new_float()
var float[] aComIdx52H = array.new_float()
var float[] aComIdx156H = array.new_float()
var float[] aComLongPctH = array.new_float()
var float[] aComShortPctH = array.new_float()
var float[] aComFlipH = array.new_float()
var float[] aComNetChangeH = array.new_float()

var float[] bNCDiff13H = array.new_float()
var float[] bNCDiff26H = array.new_float()
var float[] bNCDiff52H = array.new_float()
var float[] bNCIdx52H = array.new_float()
var float[] bNCIdx156H = array.new_float()
var float[] bNCNetH = array.new_float()
var float[] bNCLongPctH = array.new_float()
var float[] bNCShortPctH = array.new_float()
var float[] bNCFlipH = array.new_float()
var float[] bNCNetChangeH = array.new_float()

var float[] bComDiff13H = array.new_float()
var float[] bComDiff26H = array.new_float()
var float[] bComDiff52H = array.new_float()
var float[] bComIdx52H = array.new_float()
var float[] bComIdx156H = array.new_float()
var float[] bComLongPctH = array.new_float()
var float[] bComShortPctH = array.new_float()
var float[] bComFlipH = array.new_float()
var float[] bComNetChangeH = array.new_float()

var float[] abNCFlipH = array.new_float()
var float[] abComFlipH = array.new_float()

f_trimHistory() =>
    if array.size(timeH) > MAX_HISTORY
        array.pop(timeH)

        array.pop(aNCDiff13H)
        array.pop(aNCDiff26H)
        array.pop(aNCDiff52H)
        array.pop(aNCIdx52H)
        array.pop(aNCIdx156H)
        array.pop(aNCNetH)
        array.pop(aNCLongPctH)
        array.pop(aNCShortPctH)
        array.pop(aNCFlipH)
        array.pop(aNCNetChangeH)

        array.pop(aComDiff13H)
        array.pop(aComDiff26H)
        array.pop(aComDiff52H)
        array.pop(aComIdx52H)
        array.pop(aComIdx156H)
        array.pop(aComLongPctH)
        array.pop(aComShortPctH)
        array.pop(aComFlipH)
        array.pop(aComNetChangeH)

        array.pop(bNCDiff13H)
        array.pop(bNCDiff26H)
        array.pop(bNCDiff52H)
        array.pop(bNCIdx52H)
        array.pop(bNCIdx156H)
        array.pop(bNCNetH)
        array.pop(bNCLongPctH)
        array.pop(bNCShortPctH)
        array.pop(bNCFlipH)
        array.pop(bNCNetChangeH)

        array.pop(bComDiff13H)
        array.pop(bComDiff26H)
        array.pop(bComDiff52H)
        array.pop(bComIdx52H)
        array.pop(bComIdx156H)
        array.pop(bComLongPctH)
        array.pop(bComShortPctH)
        array.pop(bComFlipH)
        array.pop(bComNetChangeH)

        array.pop(abNCFlipH)
        array.pop(abComFlipH)

f_pushSnapshot() =>
    array.unshift(timeH, time("W"))

    array.unshift(aNCDiff13H, ncDiff13A)
    array.unshift(aNCDiff26H, ncDiff26A)
    array.unshift(aNCDiff52H, ncDiff52A)
    array.unshift(aNCIdx52H, ncIdx52A)
    array.unshift(aNCIdx156H, ncIdx156A)
    array.unshift(aNCNetH, pairA_noncoms_net_Positions)
    array.unshift(aNCLongPctH, pairA_noncoms_long_percentage)
    array.unshift(aNCShortPctH, pairA_noncoms_short_percentage)
    array.unshift(aNCFlipH, pairA_noncoms_flip)
    array.unshift(aNCNetChangeH, pairA_noncoms_netChange)

    array.unshift(aComDiff13H, comDiff13A)
    array.unshift(aComDiff26H, comDiff26A)
    array.unshift(aComDiff52H, comDiff52A)
    array.unshift(aComIdx52H, comIdx52A)
    array.unshift(aComIdx156H, comIdx156A)
    array.unshift(aComLongPctH, pairA_coms_long_percentage)
    array.unshift(aComShortPctH, pairA_coms_short_percentage)
    array.unshift(aComFlipH, pairA_coms_flip)
    array.unshift(aComNetChangeH, pairA_coms_netChange)

    array.unshift(bNCDiff13H, ncDiff13B)
    array.unshift(bNCDiff26H, ncDiff26B)
    array.unshift(bNCDiff52H, ncDiff52B)
    array.unshift(bNCIdx52H, ncIdx52B)
    array.unshift(bNCIdx156H, ncIdx156B)
    array.unshift(bNCNetH, pairB_noncoms_net_Positions)
    array.unshift(bNCLongPctH, pairB_noncoms_long_percentage)
    array.unshift(bNCShortPctH, pairB_noncoms_short_percentage)
    array.unshift(bNCFlipH, pairB_noncoms_flip)
    array.unshift(bNCNetChangeH, pairB_noncoms_netChange)

    array.unshift(bComDiff13H, comDiff13B)
    array.unshift(bComDiff26H, comDiff26B)
    array.unshift(bComDiff52H, comDiff52B)
    array.unshift(bComIdx52H, comIdx52B)
    array.unshift(bComIdx156H, comIdx156B)
    array.unshift(bComLongPctH, pairB_coms_long_percentage)
    array.unshift(bComShortPctH, pairB_coms_short_percentage)
    array.unshift(bComFlipH, pairB_coms_flip)
    array.unshift(bComNetChangeH, pairB_coms_netChange)

    array.unshift(abNCFlipH, pairA_noncoms_flip - pairB_noncoms_flip)
    array.unshift(abComFlipH, pairA_coms_flip - pairB_coms_flip)

    f_trimHistory()

f_updateCurrentSnapshot() =>
    if array.size(timeH) > 0
        array.set(timeH, 0, time("W"))

        array.set(aNCDiff13H, 0, ncDiff13A)
        array.set(aNCDiff26H, 0, ncDiff26A)
        array.set(aNCDiff52H, 0, ncDiff52A)
        array.set(aNCIdx52H, 0, ncIdx52A)
        array.set(aNCIdx156H, 0, ncIdx156A)
        array.set(aNCNetH, 0, pairA_noncoms_net_Positions)
        array.set(aNCLongPctH, 0, pairA_noncoms_long_percentage)
        array.set(aNCShortPctH, 0, pairA_noncoms_short_percentage)
        array.set(aNCFlipH, 0, pairA_noncoms_flip)
        array.set(aNCNetChangeH, 0, pairA_noncoms_netChange)

        array.set(aComDiff13H, 0, comDiff13A)
        array.set(aComDiff26H, 0, comDiff26A)
        array.set(aComDiff52H, 0, comDiff52A)
        array.set(aComIdx52H, 0, comIdx52A)
        array.set(aComIdx156H, 0, comIdx156A)
        array.set(aComLongPctH, 0, pairA_coms_long_percentage)
        array.set(aComShortPctH, 0, pairA_coms_short_percentage)
        array.set(aComFlipH, 0, pairA_coms_flip)
        array.set(aComNetChangeH, 0, pairA_coms_netChange)

        array.set(bNCDiff13H, 0, ncDiff13B)
        array.set(bNCDiff26H, 0, ncDiff26B)
        array.set(bNCDiff52H, 0, ncDiff52B)
        array.set(bNCIdx52H, 0, ncIdx52B)
        array.set(bNCIdx156H, 0, ncIdx156B)
        array.set(bNCNetH, 0, pairB_noncoms_net_Positions)
        array.set(bNCLongPctH, 0, pairB_noncoms_long_percentage)
        array.set(bNCShortPctH, 0, pairB_noncoms_short_percentage)
        array.set(bNCFlipH, 0, pairB_noncoms_flip)
        array.set(bNCNetChangeH, 0, pairB_noncoms_netChange)

        array.set(bComDiff13H, 0, comDiff13B)
        array.set(bComDiff26H, 0, comDiff26B)
        array.set(bComDiff52H, 0, comDiff52B)
        array.set(bComIdx52H, 0, comIdx52B)
        array.set(bComIdx156H, 0, comIdx156B)
        array.set(bComLongPctH, 0, pairB_coms_long_percentage)
        array.set(bComShortPctH, 0, pairB_coms_short_percentage)
        array.set(bComFlipH, 0, pairB_coms_flip)
        array.set(bComNetChangeH, 0, pairB_coms_netChange)

        array.set(abNCFlipH, 0, pairA_noncoms_flip - pairB_noncoms_flip)
        array.set(abComFlipH, 0, pairA_coms_flip - pairB_coms_flip)

newCotWeek = ta.change(time("W")) != 0 or barstate.isfirst
allowStore = time >= startDate

if newCotWeek and allowStore
    f_pushSnapshot()

f_updateCurrentSnapshot()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_pos(x) =>
    switch x
        "Top Right" => position.top_right
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        "Top Center" => position.top_center
        "Middle Center" => position.middle_center
        "Bottom Center" => position.bottom_center
        "Top Left" => position.top_left
        "Middle Left" => position.middle_left
        "Bottom Left" => position.bottom_left
        => position.middle_right

f_size(x) =>
    switch x
        "Auto" => size.auto
        "Huge" => size.huge
        "Large" => size.large
        "Normal" => size.normal
        "Small" => size.small
        "Tiny" => size.tiny
        => size.small

f_participantLabel() =>
    participantMode == "Non-Commercial Only" ? "Non-Commercial" : "Commercial"

f_ncDiffTitle(x) =>
    x

f_comDiffTitle(x) =>
    x

tBg = chart.bg_color
tFg = chart.fg_color
txtSize = f_size(tableSize)
pLabel = f_participantLabel()
pLabelSuffix = pLabel == "" ? "" : " | " + pLabel
pLabelTipSuffix = pLabel == "" ? "" : " | Participant: " + pLabel

participantTitle = participantMode == "Non-Commercial Only" ? "NON-COMMERCIAL" : "COMMERCIAL"
biasHeader = participantMode == "Non-Commercial Only" ? "NC Bias" : "Com Bias"
dataTitle = includeOptions ? "FUTURES + OPTIONS" : "FUTURES"

f_readableText(bg) =>
    r = color.r(bg)
    g = color.g(bg)
    b = color.b(bg)
    brightness = (r * 299 + g * 587 + b * 114) / 1000
    brightness > 150 ? color.black : color.white

f_fmtDate(ts) =>
    str.format_time(ts, "yyyy-MM-dd", syminfo.timezone)

f_fmtPct(v) =>
    na(v) ? "" : str.tostring(v, "#.1") + "%"

f_fmtScore(v) =>
    na(v) ? "" : str.tostring(v, "#")

f_fmtScoreNA(v) =>
    na(v) ? "n/a" : str.tostring(v, "#.0")

f_fmtSignedScore(v) =>
    na(v) ? "n/a" : (v > 0 ? "+" : "") + str.tostring(v, "#.0")

f_fmtPctNA(v) =>
    na(v) ? "n/a" : (v > 0 ? "+" : "") + str.tostring(v, "#.1") + "%"

f_fmtPosition(v) =>
    if na(v)
        "n/a"
    else
        av = math.abs(v)
        prefix = v > 0 ? "+" : ""
        prefix + (av >= 1000000 ? str.tostring(v / 1000000.0, "#.1") + "M" :
         av >= 1000 ? str.tostring(v / 1000.0, "#.1") + "K" :
         str.tostring(v, "#.0"))

// INDEPENDENT PARTICIPANT BIAS ENGINE
// Each mode is calculated from the selected participant's own matrix only.
// Composite matrix weights:
// D13 10% | D26 15% | D52 25% | I52 25% | I3Y 25%.
// All values are converted to one MARKET-bias axis:
// 100 = bullish setup, 50 = neutral, 0 = bearish setup.
// Low NC readings are bullish contrarian readings; high Commercial readings
// are bullish direct Commercial readings.
f_biasAxis(v, isCommercial) =>
    isCommercial ? v : 100.0 - v

f_matrixBull(d13, d26, d52, idx52, idx156, isCommercial) =>
    if na(d13) or na(d26) or na(d52) or na(idx52) or na(idx156)
        na
    else
        b13 = f_biasAxis(d13, isCommercial)
        b26 = f_biasAxis(d26, isCommercial)
        b52 = f_biasAxis(d52, isCommercial)
        i52 = f_biasAxis(idx52, isCommercial)
        i156 = f_biasAxis(idx156, isCommercial)
        b13 * 0.10 + b26 * 0.15 + b52 * 0.25 + i52 * 0.25 + i156 * 0.25

f_biasScore(d13, d26, d52, idx52, idx156, isCommercial) =>
    weightedBull = f_matrixBull(d13, d26, d52, idx52, idx156, isCommercial)
    na(weightedBull) ? na : 2.0 * weightedBull - 100.0

f_participantAlignment(idx52, idx156, isCommercial) =>
    if na(idx52) or na(idx156)
        "Unavailable"
    else
        b52 = f_biasAxis(idx52, isCommercial)
        b156 = f_biasAxis(idx156, isCommercial)
        b52 >= 80 and b156 >= 70 ? "Bullish extreme" :
         b52 <= 20 and b156 <= 30 ? "Bearish extreme" :
         b52 > 60 and b156 > 60 ? "Bullish leaning" :
         b52 < 40 and b156 < 40 ? "Bearish leaning" :
         "Mixed / neutral"

f_biasLabel(d13, d26, d52, prevD13, prevD26, prevD52, idx52, idx156, prevIdx52, prevIdx156, participantNetChange, participantFlip, isCommercial) =>
    weightedBull = f_matrixBull(d13, d26, d52, idx52, idx156, isCommercial)
    prevWeightedBull = f_matrixBull(prevD13, prevD26, prevD52, prevIdx52, prevIdx156, isCommercial)

    if na(weightedBull)
        "NO DATA"
    else
        // Flow must follow the same market-bias axis as the score.
        // NC is contrarian, so increasing NC net positioning is bearish for this
        // market-bias model. Commercial is direct, so increasing Commercial net
        // positioning is bullish. The previous version had these signs reversed.
        marketFlow = na(participantNetChange) ? na : (isCommercial ? participantNetChange : -participantNetChange)

        bullSetup = weightedBull >= 75
        bearSetup = weightedBull <= 25

        // SETUP labels are transition events, not permanent labels. A matrix pinned
        // at 0 for several weeks remains a bearish extreme, but it is not a fresh
        // TOP RISK event every week.
        enteredBull = bullSetup and not na(prevWeightedBull) and prevWeightedBull < 75
        enteredBear = bearSetup and not na(prevWeightedBull) and prevWeightedBull > 25

        // A turn is the first meaningful move away from an established extreme.
        bullTurn = bullSetup and not enteredBull and not na(prevWeightedBull) and prevWeightedBull >= 75 and weightedBull < prevWeightedBull - 2
        bearTurn = bearSetup and not enteredBear and not na(prevWeightedBull) and prevWeightedBull <= 25 and weightedBull > prevWeightedBull + 2

        enteredBull ? "BOTTOM SETUP" :
         enteredBear ? "TOP RISK" :
         bullTurn and not na(marketFlow) and marketFlow > 0 ? "LONG BUILD" :
         bullTurn ? "BULL TURN" :
         bearTurn and not na(marketFlow) and marketFlow < 0 ? "SHORT BUILD" :
         bearTurn ? "BEAR TURN" :
         weightedBull >= 60 and not na(marketFlow) and marketFlow > 0 ? "LONG BUILD" :
         weightedBull >= 60 and not na(marketFlow) and marketFlow < 0 ? "LONG UNWIND" :
         weightedBull >= 60 ? "LONG BIAS" :
         weightedBull <= 40 and not na(marketFlow) and marketFlow < 0 ? "SHORT BUILD" :
         weightedBull <= 40 and not na(marketFlow) and marketFlow > 0 ? "SHORT COVER" :
         weightedBull <= 40 ? "SHORT BIAS" :
         "NEUTRAL"

f_biasTooltip(market, d13, d26, d52, prevD13, prevD26, prevD52, idx52, idx156, prevIdx52, prevIdx156, participantNetChange, participantFlip, isCommercial) =>
    score = f_biasScore(d13, d26, d52, idx52, idx156, isCommercial)
    stage = f_biasLabel(d13, d26, d52, prevD13, prevD26, prevD52, idx52, idx156, prevIdx52, prevIdx156, participantNetChange, participantFlip, isCommercial)
    participantName = isCommercial ? "Commercial" : "Non-Commercial"
    marketFlow = na(participantNetChange) ? na : (isCommercial ? participantNetChange : -participantNetChange)
    market + " " + participantName + " market bias" +
     "\nBias: " + stage +
     "\nComposite score: " + f_fmtSignedScore(score) + " (-100 bearish to +100 bullish)" +
     "\nMatrix weights: D13 10% | D26 15% | D52 25% | I52 25% | I3Y 25%" +
     "\nDiff 13 / 26 / 52: " + f_fmtScoreNA(d13) + " / " + f_fmtScoreNA(d26) + " / " + f_fmtScoreNA(d52) +
     "\nIndex 52 / 156: " + f_fmtScoreNA(idx52) + " / " + f_fmtScoreNA(idx156) +
     "\nMatrix alignment: " + f_participantAlignment(idx52, idx156, isCommercial) +
     "\n" + participantName + " Flip: " + f_fmtPctNA(participantFlip) +
     "\n" + participantName + " Net Change: " + f_fmtPosition(participantNetChange) +
     "\nBias-axis flow: " + f_fmtPosition(marketFlow) +
     "\nTOP RISK / BOTTOM SETUP are shown only on entry into an extreme zone."

f_relativeBiasLabel(score, nameA, nameB) =>
    na(score) ? "NO DATA" :
     score >= 60 ? "STRONG " + nameA :
     score >= 25 ? nameA + " BIAS" :
     score <= -60 ? "STRONG " + nameB :
     score <= -25 ? nameB + " BIAS" :
     "BALANCED"

f_relativeBiasTooltip(scoreA, labelA, scoreB, labelB, relativeScore, nameA, nameB) =>
    nameA + " vs " + nameB + " relative positioning" +
     "\n" + nameA + " score: " + f_fmtSignedScore(scoreA) + " | " + labelA +
     "\n" + nameB + " score: " + f_fmtSignedScore(scoreB) + " | " + labelB +
     "\n" + nameA + " - " + nameB + " relative score: " + f_fmtSignedScore(relativeScore) +
     "\nRelative leader: " + f_relativeBiasLabel(relativeScore, nameA, nameB) +
     "\nPositive = " + nameA + " has the stronger bullish positioning setup." +
     "\nNegative = " + nameB + " has the stronger bullish positioning setup." +
     "\nNear zero = positioning is balanced between both markets."

f_norm01(v, minV, maxV) =>
    hi = maxV <= minV ? minV + 1.0 : maxV
    math.max(math.min((v - minV) / (hi - minV), 1.0), 0.0)

f_levelColor(v, minV, maxV, upGood) =>
    if na(v)
        color.new(tBg, 0)
    else
        x = f_norm01(v, minV, maxV)
        upGood ?
             (x <= 0.5 ? color.from_gradient(x, 0.0, 0.5, dnCol, mdCol) : color.from_gradient(x, 0.5, 1.0, mdCol, upCol)) :
             (x <= 0.5 ? color.from_gradient(x, 0.0, 0.5, upCol, mdCol) : color.from_gradient(x, 0.5, 1.0, mdCol, dnCol))

f_scoreColor(score) =>
    f_levelColor(score, 0, 100, true)

f_signedColor(v, scale) =>
    if na(v)
        color.new(tBg, 0)
    else
        s = math.max(scale, 0.0001)
        x = math.max(math.min((v + s) / (2.0 * s), 1.0), 0.0)
        x <= 0.5 ? color.from_gradient(x, 0.0, 0.5, dnCol, mdCol) : color.from_gradient(x, 0.5, 1.0, mdCol, upCol)

f_cell(_tbl, col, row, txt, bg, txtCol, tip = "") =>
    table.cell(
         _tbl,
         col,
         row,
         text=txt,
         bgcolor=bg,
         text_color=txtCol,
         text_size=txtSize,
         text_font_family=font.family_monospace,
         text_halign=text.align_center,
         text_valign=text.align_center,
         tooltip=tip)

f_cellSized(_tbl, col, row, txt, bg, txtCol, cellSize, tip = "") =>
    table.cell(
         _tbl,
         col,
         row,
         text=txt,
         bgcolor=bg,
         text_color=txtCol,
         text_size=cellSize,
         text_font_family=font.family_monospace,
         text_halign=text.align_center,
         text_valign=text.align_center,
         tooltip=tip)

f_uiCell(_tbl, col, row, txt, bg, txtCol, cellSize, tip = "") =>
    table.cell(
         _tbl,
         col,
         row,
         text=txt,
         bgcolor=bg,
         text_color=txtCol,
         text_size=cellSize,
         text_font_family=font.family_default,
         text_halign=text.align_center,
         text_valign=text.align_center,
         tooltip=tip)

// Opaque, theme-aware table surfaces.
headerBg  = color.from_gradient(0.08, 0.0, 1.0, tBg, tFg)
titleBg   = color.from_gradient(0.14, 0.0, 1.0, tBg, tFg)
sectionBg = color.from_gradient(0.10, 0.0, 1.0, tBg, tFg)
headerFg = tFg

f_header(_tbl, col, txt) =>
    f_cell(_tbl, col, 2, txt, headerBg, headerFg, txt)

f_dateCell(_tbl, col, row, txt) =>
    f_cell(_tbl, col, row, txt, tBg, tFg, "COT date: " + txt)

f_historyDateCell(_tbl, col, row, txt, isLatest, rowFade) =>
    dateBg = isLatest ?
         color.from_gradient(0.18, 0.0, 1.0, tBg, tFg) :
         color.from_gradient(0.06, 0.0, 1.0, tBg, tFg)
    dateTip = "COT date: " + txt + (isLatest ? " | LATEST" : "")
    f_cell(_tbl, col, row, txt, dateBg, tFg, dateTip)

f_valueCell(_tbl, col, row, txt, bg, tip) =>
    f_cell(_tbl, col, row, txt, bg, f_readableText(bg), tip)

f_addHeader(_tbl, col, enabled, title) =>
    nextCol = col
    if enabled
        f_header(_tbl, nextCol, title)
        nextCol += 1
    nextCol

f_addScoreCol(_tbl, col, row, enabled, title, val) =>
    nextCol = col
    if enabled
        bg = f_scoreColor(val)
        f_valueCell(_tbl, nextCol, row, f_fmtScore(val), bg, title + ": " + f_fmtScore(val))
        nextCol += 1
    nextCol

f_addLongPctCol(_tbl, col, row, enabled, title, val) =>
    nextCol = col
    if enabled
        bg = f_levelColor(val, 0, 100, true)
        f_valueCell(_tbl, nextCol, row, f_fmtPct(val), bg, title + ": " + f_fmtPct(val))
        nextCol += 1
    nextCol

f_addShortPctCol(_tbl, col, row, enabled, title, val) =>
    nextCol = col
    if enabled
        bg = f_levelColor(val, 0, 100, false)
        f_valueCell(_tbl, nextCol, row, f_fmtPct(val), bg, title + ": " + f_fmtPct(val))
        nextCol += 1
    nextCol

f_addFlipCol(_tbl, col, row, enabled, title, val) =>
    nextCol = col
    if enabled
        bg = f_signedColor(val, flipScale)
        f_valueCell(_tbl, nextCol, row, f_fmtPct(val), bg, title + ": " + f_fmtPct(val))
        nextCol += 1
    nextCol

f_addNetCol(_tbl, col, row, enabled, title, netVal, flipVal) =>
    nextCol = col
    if enabled
        bg = f_signedColor(flipVal, flipScale)
        f_valueCell(_tbl, nextCol, row, f_fmtPosition(netVal), bg, title + ": " + f_fmtPosition(netVal))
        nextCol += 1
    nextCol

f_biasStateColor(label, score) =>
    softBull = color.from_gradient(0.78, 0.0, 1.0, tBg, upCol)
    softBear = color.from_gradient(0.78, 0.0, 1.0, tBg, dnCol)
    neutralBias = color.from_gradient(0.22, 0.0, 1.0, tBg, tFg)

    label == "BOTTOM SETUP" or label == "BULL TURN" or label == "LONG BUILD" ? upCol :
     label == "LONG BIAS" or label == "LONG UNWIND" ? softBull :
     label == "NEUTRAL" ? neutralBias :
     label == "SHORT BIAS" or label == "SHORT COVER" ? softBear :
     label == "SHORT BUILD" or label == "BEAR TURN" or label == "TOP RISK" ? dnCol :
     f_signedColor(score, 100.0)

f_displayBiasLabel(label) =>
    label == "LONG BUILD" ? "▲ LONG BUILD" :
     label == "BULL TURN" ? "↗ BULL TURN" :
     label == "BOTTOM SETUP" ? "▲ BUY" :
     label == "LONG BIAS" ? "▲ LONG BIAS" :
     label == "LONG UNWIND" ? "↘ LONG UNWIND" :
     label == "SHORT COVER" ? "↗ SHORT COVER" :
     label == "SHORT BIAS" ? "▼ SHORT BIAS" :
     label == "TOP RISK" ? "◇ TOP RISK" :
     label == "BEAR TURN" ? "↘ BEAR TURN" :
     label == "SHORT BUILD" ? "▼ SHORT BUILD" :
     label == "NEUTRAL" ? "• NEUTRAL" :
     label == "NO DATA" ? "— NO DATA" :
     label

f_addBiasCol(_tbl, col, row, enabled, label, score, tip) =>
    nextCol = col
    if enabled
        bg = f_biasStateColor(label, score)
        displayLabel = f_displayBiasLabel(label)
        f_valueCell(_tbl, nextCol, row, displayLabel, bg, tip)
        nextCol += 1
    nextCol

// Relative bias colors are based directly on the A-B score so dynamic market
// names such as "STRONG SILVER" and "USD BIAS" keep the intended heat state.
f_relativeBiasStateColor(score) =>
    softBull = color.from_gradient(0.78, 0.0, 1.0, tBg, upCol)
    softBear = color.from_gradient(0.78, 0.0, 1.0, tBg, dnCol)
    neutralBias = color.from_gradient(0.22, 0.0, 1.0, tBg, tFg)

    na(score) ? color.new(tBg, 0) :
     score >= 60 ? upCol :
     score >= 25 ? softBull :
     score <= -60 ? dnCol :
     score <= -25 ? softBear :
     neutralBias

f_addRelativeBiasCol(_tbl, col, row, enabled, label, score, tip) =>
    nextCol = col
    if enabled
        bg = f_relativeBiasStateColor(score)
        f_valueCell(_tbl, nextCol, row, label, bg, tip)
        nextCol += 1
    nextCol

f_groupCell(_tbl, firstCol, lastCol, row, txt, tip) =>
    if lastCol > firstCol
        table.merge_cells(_tbl, firstCol, row, lastCol, row)
    f_uiCell(_tbl, firstCol, row, txt, sectionBg, headerFg, size.small, tip)

// Blank shaded gutters create cleaner separation than a visible line character.
separatorBg = color.from_gradient(0.18, 0.0, 1.0, tBg, tFg)

f_separatorCell(_tbl, col, row) =>
    f_cell(
         _tbl,
         col,
         row,
         "",
         separatorBg,
         color.new(tFg, 100),
         "Section separator")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE COLUMN COUNTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

aCols = 0
aCols += (showNC and showNCNetA) ? 1 : 0
aCols += (showNC and showNCLongA) ? 1 : 0
aCols += (showNC and showNCShortA) ? 1 : 0
aCols += (showNC and showNCFlipA) ? 1 : 0
aCols += (showNC and showNCDiff13A) ? 1 : 0
aCols += (showNC and showNCDiff26A) ? 1 : 0
aCols += (showNC and showNCDiff52A) ? 1 : 0
aCols += (showNC and showNCIdx52A) ? 1 : 0
aCols += (showNC and showNCIdx156A) ? 1 : 0
aCols += (showCom and showComDiff13A) ? 1 : 0
aCols += (showCom and showComDiff26A) ? 1 : 0
aCols += (showCom and showComDiff52A) ? 1 : 0
aCols += (showCom and showComIdx52A) ? 1 : 0
aCols += (showCom and showComIdx156A) ? 1 : 0
aCols += (showCom and showComLongA) ? 1 : 0
aCols += (showCom and showComShortA) ? 1 : 0
aCols += (showCom and showComFlipA) ? 1 : 0
aCols += showBiasA ? 1 : 0

bCols = 0
bCols += (showNC and showNCNetB) ? 1 : 0
bCols += (showNC and showNCLongB) ? 1 : 0
bCols += (showNC and showNCShortB) ? 1 : 0
bCols += (showNC and showNCFlipB) ? 1 : 0
bCols += (showNC and showNCDiff13B) ? 1 : 0
bCols += (showNC and showNCDiff26B) ? 1 : 0
bCols += (showNC and showNCDiff52B) ? 1 : 0
bCols += (showNC and showNCIdx52B) ? 1 : 0
bCols += (showNC and showNCIdx156B) ? 1 : 0
bCols += (showCom and showComDiff13B) ? 1 : 0
bCols += (showCom and showComDiff26B) ? 1 : 0
bCols += (showCom and showComDiff52B) ? 1 : 0
bCols += (showCom and showComIdx52B) ? 1 : 0
bCols += (showCom and showComIdx156B) ? 1 : 0
bCols += (showCom and showComLongB) ? 1 : 0
bCols += (showCom and showComShortB) ? 1 : 0
bCols += (showCom and showComFlipB) ? 1 : 0
bCols += showBiasB ? 1 : 0

abCols = 0
abCols += (showNC and showABNCFlip) ? 1 : 0
abCols += (showCom and showABComFlip) ? 1 : 0
abCols += showABBias ? 1 : 0

// Insert narrow separators between Pair A / Pair B and Pair B / A-B.
aBSeparatorCols = aCols > 0 and bCols > 0 ? 1 : 0
bABSeparatorCols = bCols > 0 and abCols > 0 ? 1 : 0

selectedCols = 1 + aCols + aBSeparatorCols + bCols + bABSeparatorCols + abCols
noMetricSelected = selectedCols == 1
displayCols = noMetricSelected ? 2 : selectedCols

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE DRAWING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table cotTbl = na
var int prevCols = na
var int prevRows = na
var int prevACols = na
var int prevBCols = na
var int prevABCols = na

if barstate.islast
    n = math.min(periods, array.size(timeH))
    displayRows = math.max(4, n + 3)

    if not showTable
        if not na(cotTbl)
            table.delete(cotTbl)
            cotTbl := na
            prevCols := na
            prevRows := na
            prevACols := na
            prevBCols := na
            prevABCols := na
    else
        needNewTable = na(cotTbl) or prevCols != displayCols or prevRows != displayRows or prevACols != aCols or prevBCols != bCols or prevABCols != abCols

        if needNewTable
            if not na(cotTbl)
                table.delete(cotTbl)

            cotTbl := table.new(
                 f_pos(tablePos),
                 displayCols,
                 displayRows,
                 bgcolor=tBg,
                 frame_color=color.new(tFg, 55),
                 frame_width=1,
                 border_color=color.new(tFg, 90),
                 border_width=0)

            prevCols := displayCols
            prevRows := displayRows
            prevACols := aCols
            prevBCols := bCols
            prevABCols := abCols
        else
            table.clear(cotTbl, 0, 0, displayCols - 1, displayRows - 1)

        table.merge_cells(cotTbl, 0, 0, displayCols - 1, 0)

        titleText = "COT HEATMAP • " + currencyA + "/" + currencyB + " • " + participantTitle + " • " + dataTitle

        if codeA == "" or codeB == ""
            titleText := "COT HEATMAP • SYMBOL CODE MISSING • " + currencyA + "/" + currencyB

        f_uiCell(cotTbl, 0, 0, titleText, titleBg, tFg, size.normal, titleText)

        if noMetricSelected
            f_uiCell(cotTbl, 0, 1, "DATE", sectionBg, tFg, size.small, "Date")
            f_uiCell(cotTbl, 1, 1, "SELECT METRIC", sectionBg, tFg, size.small, "Enable at least one metric column")
        else
            f_uiCell(cotTbl, 0, 1, "DATE", sectionBg, tFg, size.small, "Date")

            groupCol = 1

            if aCols > 0
                aFirst = groupCol
                aLast = groupCol + aCols - 1
                f_groupCell(
                     cotTbl,
                     aFirst,
                     aLast,
                     1,
                     currencyA + " — " + participantTitle,
                     "Pair A selected COT market: " + currencyA + pLabelTipSuffix)
                groupCol += aCols

            if aBSeparatorCols > 0
                f_separatorCell(cotTbl, groupCol, 1)
                groupCol += 1

            if bCols > 0
                bFirst = groupCol
                bLast = groupCol + bCols - 1
                f_groupCell(
                     cotTbl,
                     bFirst,
                     bLast,
                     1,
                     currencyB + " — " + participantTitle,
                     "Pair B selected COT market: " + currencyB + pLabelTipSuffix)
                groupCol += bCols

            if bABSeparatorCols > 0
                f_separatorCell(cotTbl, groupCol, 1)
                groupCol += 1

            if abCols > 0
                abFirst = groupCol
                abLast = groupCol + abCols - 1
                f_groupCell(
                     cotTbl,
                     abFirst,
                     abLast,
                     1,
                     currencyA + "–" + currencyB + " RELATIVE",
                     "Pair spread: " + currencyA + " - " + currencyB + pLabelTipSuffix)

        f_header(cotTbl, 0, "")
        col = 1

        if noMetricSelected
            f_header(cotTbl, 1, "Select metric")
        else
            // Pair A headers
            col := f_addHeader(cotTbl, col, showNC and showNCNetA, "Net")
            col := f_addHeader(cotTbl, col, showNC and showNCLongA, "L%")
            col := f_addHeader(cotTbl, col, showNC and showNCShortA, "S%")
            col := f_addHeader(cotTbl, col, showNC and showNCFlipA, "Flip%")
            col := f_addHeader(cotTbl, col, showNC and showNCDiff13A, f_ncDiffTitle("D13"))
            col := f_addHeader(cotTbl, col, showNC and showNCDiff26A, f_ncDiffTitle("D26"))
            col := f_addHeader(cotTbl, col, showNC and showNCDiff52A, f_ncDiffTitle("D52"))
            col := f_addHeader(cotTbl, col, showNC and showNCIdx52A, "I52")
            col := f_addHeader(cotTbl, col, showNC and showNCIdx156A, "I3Y")

            col := f_addHeader(cotTbl, col, showCom and showComDiff13A, f_comDiffTitle("D13"))
            col := f_addHeader(cotTbl, col, showCom and showComDiff26A, f_comDiffTitle("D26"))
            col := f_addHeader(cotTbl, col, showCom and showComDiff52A, f_comDiffTitle("D52"))
            col := f_addHeader(cotTbl, col, showCom and showComIdx52A, "I52")
            col := f_addHeader(cotTbl, col, showCom and showComIdx156A, "I3Y")
            col := f_addHeader(cotTbl, col, showCom and showComLongA, "L%")
            col := f_addHeader(cotTbl, col, showCom and showComShortA, "S%")
            col := f_addHeader(cotTbl, col, showCom and showComFlipA, "Flip%")
            col := f_addHeader(cotTbl, col, showBiasA, biasHeader)

            if aBSeparatorCols > 0
                f_separatorCell(cotTbl, col, 2)
                col += 1

            // Pair B headers
            col := f_addHeader(cotTbl, col, showNC and showNCNetB, "Net")
            col := f_addHeader(cotTbl, col, showNC and showNCLongB, "L%")
            col := f_addHeader(cotTbl, col, showNC and showNCShortB, "S%")
            col := f_addHeader(cotTbl, col, showNC and showNCFlipB, "Flip%")
            col := f_addHeader(cotTbl, col, showNC and showNCDiff13B, f_ncDiffTitle("D13"))
            col := f_addHeader(cotTbl, col, showNC and showNCDiff26B, f_ncDiffTitle("D26"))
            col := f_addHeader(cotTbl, col, showNC and showNCDiff52B, f_ncDiffTitle("D52"))
            col := f_addHeader(cotTbl, col, showNC and showNCIdx52B, "I52")
            col := f_addHeader(cotTbl, col, showNC and showNCIdx156B, "I3Y")

            col := f_addHeader(cotTbl, col, showCom and showComDiff13B, f_comDiffTitle("D13"))
            col := f_addHeader(cotTbl, col, showCom and showComDiff26B, f_comDiffTitle("D26"))
            col := f_addHeader(cotTbl, col, showCom and showComDiff52B, f_comDiffTitle("D52"))
            col := f_addHeader(cotTbl, col, showCom and showComIdx52B, "I52")
            col := f_addHeader(cotTbl, col, showCom and showComIdx156B, "I3Y")
            col := f_addHeader(cotTbl, col, showCom and showComLongB, "L%")
            col := f_addHeader(cotTbl, col, showCom and showComShortB, "S%")
            col := f_addHeader(cotTbl, col, showCom and showComFlipB, "Flip%")
            col := f_addHeader(cotTbl, col, showBiasB, biasHeader)

            if bABSeparatorCols > 0
                f_separatorCell(cotTbl, col, 2)
                col += 1

            // A-B headers
            col := f_addHeader(cotTbl, col, showNC and showABNCFlip, "Rel Flip%")
            col := f_addHeader(cotTbl, col, showCom and showABComFlip, "Rel Flip%")
            col := f_addHeader(cotTbl, col, showABBias, "Leader")

        if n <= 0
            f_dateCell(cotTbl, 0, 3, "No data")
            if displayCols > 1
                f_cell(cotTbl, 1, 3, "Check symbol / start date", headerBg, tFg)
        else
            for j = 0 to n - 1
                row = j + 3
                d = f_fmtDate(array.get(timeH, j))
                isLatest = j == 0

                // Fully opaque rows: chart candles and markers cannot show through.
                rowFade = 0
                f_historyDateCell(cotTbl, 0, row, d, isLatest, rowFade)

                col := 1

                if noMetricSelected
                    f_cell(cotTbl, 1, row, "Enable columns", tBg, tFg)
                else
                    // Bias inputs for this historical row. Arrays are newest first,
                    // so j + 1 is the previous COT week used for turn detection.
                    useCommercialBias = showCom

                    aD13 = array.get(aNCDiff13H, j)
                    aD26 = array.get(aNCDiff26H, j)
                    aD52 = array.get(aNCDiff52H, j)
                    aComD13 = array.get(aComDiff13H, j)
                    aComD26 = array.get(aComDiff26H, j)
                    aComD52 = array.get(aComDiff52H, j)
                    aNet = array.get(aNCNetH, j)
                    aNetChange = array.get(aNCNetChangeH, j)
                    aComNetChange = array.get(aComNetChangeH, j)
                    aIdx52 = array.get(aNCIdx52H, j)
                    aIdx156 = array.get(aNCIdx156H, j)
                    aCom52 = array.get(aComIdx52H, j)
                    aCom156 = array.get(aComIdx156H, j)
                    aFlip = array.get(aNCFlipH, j)
                    aComFlip = array.get(aComFlipH, j)

                    aBiasD13 = useCommercialBias ? aComD13 : aD13
                    aBiasD26 = useCommercialBias ? aComD26 : aD26
                    aBiasD52 = useCommercialBias ? aComD52 : aD52
                    aBiasIdx52 = useCommercialBias ? aCom52 : aIdx52
                    aBiasIdx156 = useCommercialBias ? aCom156 : aIdx156
                    aPrevNCD13 = j + 1 < array.size(aNCDiff13H) ? array.get(aNCDiff13H, j + 1) : na
                    aPrevNCD26 = j + 1 < array.size(aNCDiff26H) ? array.get(aNCDiff26H, j + 1) : na
                    aPrevNCD52 = j + 1 < array.size(aNCDiff52H) ? array.get(aNCDiff52H, j + 1) : na
                    aPrevComD13 = j + 1 < array.size(aComDiff13H) ? array.get(aComDiff13H, j + 1) : na
                    aPrevComD26 = j + 1 < array.size(aComDiff26H) ? array.get(aComDiff26H, j + 1) : na
                    aPrevComD52 = j + 1 < array.size(aComDiff52H) ? array.get(aComDiff52H, j + 1) : na
                    aPrevNCIdx52 = j + 1 < array.size(aNCIdx52H) ? array.get(aNCIdx52H, j + 1) : na
                    aPrevNCIdx156 = j + 1 < array.size(aNCIdx156H) ? array.get(aNCIdx156H, j + 1) : na
                    aPrevComIdx52 = j + 1 < array.size(aComIdx52H) ? array.get(aComIdx52H, j + 1) : na
                    aPrevComIdx156 = j + 1 < array.size(aComIdx156H) ? array.get(aComIdx156H, j + 1) : na
                    aBiasPrevD13 = useCommercialBias ? aPrevComD13 : aPrevNCD13
                    aBiasPrevD26 = useCommercialBias ? aPrevComD26 : aPrevNCD26
                    aBiasPrevD52 = useCommercialBias ? aPrevComD52 : aPrevNCD52
                    aBiasPrevIdx52 = useCommercialBias ? aPrevComIdx52 : aPrevNCIdx52
                    aBiasPrevIdx156 = useCommercialBias ? aPrevComIdx156 : aPrevNCIdx156
                    aBiasNetChange = useCommercialBias ? aComNetChange : aNetChange
                    aBiasFlip = useCommercialBias ? aComFlip : aFlip
                    aBiasScore = f_biasScore(aBiasD13, aBiasD26, aBiasD52, aBiasIdx52, aBiasIdx156, useCommercialBias)
                    aBiasLabel = f_biasLabel(aBiasD13, aBiasD26, aBiasD52, aBiasPrevD13, aBiasPrevD26, aBiasPrevD52, aBiasIdx52, aBiasIdx156, aBiasPrevIdx52, aBiasPrevIdx156, aBiasNetChange, aBiasFlip, useCommercialBias)
                    aBiasTip = f_biasTooltip(currencyA, aBiasD13, aBiasD26, aBiasD52, aBiasPrevD13, aBiasPrevD26, aBiasPrevD52, aBiasIdx52, aBiasIdx156, aBiasPrevIdx52, aBiasPrevIdx156, aBiasNetChange, aBiasFlip, useCommercialBias)

                    bD13 = array.get(bNCDiff13H, j)
                    bD26 = array.get(bNCDiff26H, j)
                    bD52 = array.get(bNCDiff52H, j)
                    bComD13 = array.get(bComDiff13H, j)
                    bComD26 = array.get(bComDiff26H, j)
                    bComD52 = array.get(bComDiff52H, j)
                    bNet = array.get(bNCNetH, j)
                    bNetChange = array.get(bNCNetChangeH, j)
                    bComNetChange = array.get(bComNetChangeH, j)
                    bIdx52 = array.get(bNCIdx52H, j)
                    bIdx156 = array.get(bNCIdx156H, j)
                    bCom52 = array.get(bComIdx52H, j)
                    bCom156 = array.get(bComIdx156H, j)
                    bFlip = array.get(bNCFlipH, j)
                    bComFlip = array.get(bComFlipH, j)

                    bBiasD13 = useCommercialBias ? bComD13 : bD13
                    bBiasD26 = useCommercialBias ? bComD26 : bD26
                    bBiasD52 = useCommercialBias ? bComD52 : bD52
                    bBiasIdx52 = useCommercialBias ? bCom52 : bIdx52
                    bBiasIdx156 = useCommercialBias ? bCom156 : bIdx156
                    bPrevNCD13 = j + 1 < array.size(bNCDiff13H) ? array.get(bNCDiff13H, j + 1) : na
                    bPrevNCD26 = j + 1 < array.size(bNCDiff26H) ? array.get(bNCDiff26H, j + 1) : na
                    bPrevNCD52 = j + 1 < array.size(bNCDiff52H) ? array.get(bNCDiff52H, j + 1) : na
                    bPrevComD13 = j + 1 < array.size(bComDiff13H) ? array.get(bComDiff13H, j + 1) : na
                    bPrevComD26 = j + 1 < array.size(bComDiff26H) ? array.get(bComDiff26H, j + 1) : na
                    bPrevComD52 = j + 1 < array.size(bComDiff52H) ? array.get(bComDiff52H, j + 1) : na
                    bPrevNCIdx52 = j + 1 < array.size(bNCIdx52H) ? array.get(bNCIdx52H, j + 1) : na
                    bPrevNCIdx156 = j + 1 < array.size(bNCIdx156H) ? array.get(bNCIdx156H, j + 1) : na
                    bPrevComIdx52 = j + 1 < array.size(bComIdx52H) ? array.get(bComIdx52H, j + 1) : na
                    bPrevComIdx156 = j + 1 < array.size(bComIdx156H) ? array.get(bComIdx156H, j + 1) : na
                    bBiasPrevD13 = useCommercialBias ? bPrevComD13 : bPrevNCD13
                    bBiasPrevD26 = useCommercialBias ? bPrevComD26 : bPrevNCD26
                    bBiasPrevD52 = useCommercialBias ? bPrevComD52 : bPrevNCD52
                    bBiasPrevIdx52 = useCommercialBias ? bPrevComIdx52 : bPrevNCIdx52
                    bBiasPrevIdx156 = useCommercialBias ? bPrevComIdx156 : bPrevNCIdx156
                    bBiasNetChange = useCommercialBias ? bComNetChange : bNetChange
                    bBiasFlip = useCommercialBias ? bComFlip : bFlip
                    bBiasScore = f_biasScore(bBiasD13, bBiasD26, bBiasD52, bBiasIdx52, bBiasIdx156, useCommercialBias)
                    bBiasLabel = f_biasLabel(bBiasD13, bBiasD26, bBiasD52, bBiasPrevD13, bBiasPrevD26, bBiasPrevD52, bBiasIdx52, bBiasIdx156, bBiasPrevIdx52, bBiasPrevIdx156, bBiasNetChange, bBiasFlip, useCommercialBias)
                    bBiasTip = f_biasTooltip(currencyB, bBiasD13, bBiasD26, bBiasD52, bBiasPrevD13, bBiasPrevD26, bBiasPrevD52, bBiasIdx52, bBiasIdx156, bBiasPrevIdx52, bBiasPrevIdx156, bBiasNetChange, bBiasFlip, useCommercialBias)

                    relativeBiasScore = na(aBiasScore) or na(bBiasScore) ? na : (aBiasScore - bBiasScore) / 2.0
                    relativeBiasLabel = f_relativeBiasLabel(relativeBiasScore, currencyA, currencyB)
                    relativeBiasTip = f_relativeBiasTooltip(aBiasScore, aBiasLabel, bBiasScore, bBiasLabel, relativeBiasScore, currencyA, currencyB)

                    // Pair A values
                    col := f_addNetCol(cotTbl, col, row, showNC and showNCNetA, currencyA + " Non-Commercial Net", aNet, aFlip)
                    col := f_addLongPctCol(cotTbl, col, row, showNC and showNCLongA, currencyA + " Non-Commercial Long%", array.get(aNCLongPctH, j))
                    col := f_addShortPctCol(cotTbl, col, row, showNC and showNCShortA, currencyA + " Non-Commercial Short%", array.get(aNCShortPctH, j))
                    col := f_addFlipCol(cotTbl, col, row, showNC and showNCFlipA, currencyA + " Non-Commercial Flip%", aFlip)
                    col := f_addScoreCol(cotTbl, col, row, showNC and showNCDiff13A, currencyA + " Non-Commercial Diff 13", aD13)
                    col := f_addScoreCol(cotTbl, col, row, showNC and showNCDiff26A, currencyA + " Non-Commercial Diff 26", aD26)
                    col := f_addScoreCol(cotTbl, col, row, showNC and showNCDiff52A, currencyA + " Non-Commercial Diff 52", aD52)
                    col := f_addScoreCol(cotTbl, col, row, showNC and showNCIdx52A, currencyA + " Non-Commercial Index 52W", aIdx52)
                    col := f_addScoreCol(cotTbl, col, row, showNC and showNCIdx156A, currencyA + " Non-Commercial Index 156W", aIdx156)

                    col := f_addScoreCol(cotTbl, col, row, showCom and showComDiff13A, currencyA + " Commercial Diff 13", array.get(aComDiff13H, j))
                    col := f_addScoreCol(cotTbl, col, row, showCom and showComDiff26A, currencyA + " Commercial Diff 26", array.get(aComDiff26H, j))
                    col := f_addScoreCol(cotTbl, col, row, showCom and showComDiff52A, currencyA + " Commercial Diff 52", array.get(aComDiff52H, j))
                    col := f_addScoreCol(cotTbl, col, row, showCom and showComIdx52A, currencyA + " Commercial Index 52W", aCom52)
                    col := f_addScoreCol(cotTbl, col, row, showCom and showComIdx156A, currencyA + " Commercial Index 156W", aCom156)
                    col := f_addLongPctCol(cotTbl, col, row, showCom and showComLongA, currencyA + " Commercial Long%", array.get(aComLongPctH, j))
                    col := f_addShortPctCol(cotTbl, col, row, showCom and showComShortA, currencyA + " Commercial Short%", array.get(aComShortPctH, j))
                    col := f_addFlipCol(cotTbl, col, row, showCom and showComFlipA, currencyA + " Commercial Flip%", array.get(aComFlipH, j))
                    col := f_addBiasCol(cotTbl, col, row, showBiasA, aBiasLabel, aBiasScore, aBiasTip)

                    if aBSeparatorCols > 0
                        f_separatorCell(cotTbl, col, row)
                        col += 1

                    // Pair B values
                    col := f_addNetCol(cotTbl, col, row, showNC and showNCNetB, currencyB + " Non-Commercial Net", bNet, bFlip)
                    col := f_addLongPctCol(cotTbl, col, row, showNC and showNCLongB, currencyB + " Non-Commercial Long%", array.get(bNCLongPctH, j))
                    col := f_addShortPctCol(cotTbl, col, row, showNC and showNCShortB, currencyB + " Non-Commercial Short%", array.get(bNCShortPctH, j))
                    col := f_addFlipCol(cotTbl, col, row, showNC and showNCFlipB, currencyB + " Non-Commercial Flip%", bFlip)
                    col := f_addScoreCol(cotTbl, col, row, showNC and showNCDiff13B, currencyB + " Non-Commercial Diff 13", bD13)
                    col := f_addScoreCol(cotTbl, col, row, showNC and showNCDiff26B, currencyB + " Non-Commercial Diff 26", bD26)
                    col := f_addScoreCol(cotTbl, col, row, showNC and showNCDiff52B, currencyB + " Non-Commercial Diff 52", bD52)
                    col := f_addScoreCol(cotTbl, col, row, showNC and showNCIdx52B, currencyB + " Non-Commercial Index 52W", bIdx52)
                    col := f_addScoreCol(cotTbl, col, row, showNC and showNCIdx156B, currencyB + " Non-Commercial Index 156W", bIdx156)

                    col := f_addScoreCol(cotTbl, col, row, showCom and showComDiff13B, currencyB + " Commercial Diff 13", array.get(bComDiff13H, j))
                    col := f_addScoreCol(cotTbl, col, row, showCom and showComDiff26B, currencyB + " Commercial Diff 26", array.get(bComDiff26H, j))
                    col := f_addScoreCol(cotTbl, col, row, showCom and showComDiff52B, currencyB + " Commercial Diff 52", array.get(bComDiff52H, j))
                    col := f_addScoreCol(cotTbl, col, row, showCom and showComIdx52B, currencyB + " Commercial Index 52W", bCom52)
                    col := f_addScoreCol(cotTbl, col, row, showCom and showComIdx156B, currencyB + " Commercial Index 156W", bCom156)
                    col := f_addLongPctCol(cotTbl, col, row, showCom and showComLongB, currencyB + " Commercial Long%", array.get(bComLongPctH, j))
                    col := f_addShortPctCol(cotTbl, col, row, showCom and showComShortB, currencyB + " Commercial Short%", array.get(bComShortPctH, j))
                    col := f_addFlipCol(cotTbl, col, row, showCom and showComFlipB, currencyB + " Commercial Flip%", array.get(bComFlipH, j))
                    col := f_addBiasCol(cotTbl, col, row, showBiasB, bBiasLabel, bBiasScore, bBiasTip)

                    if bABSeparatorCols > 0
                        f_separatorCell(cotTbl, col, row)
                        col += 1

                    // A-B spread values
                    col := f_addFlipCol(cotTbl, col, row, showNC and showABNCFlip, currencyA + " - " + currencyB + " Non-Commercial Flip%", array.get(abNCFlipH, j))
                    col := f_addFlipCol(cotTbl, col, row, showCom and showABComFlip, currencyA + " - " + currencyB + " Commercial Flip%", array.get(abComFlipH, j))
                    col := f_addRelativeBiasCol(cotTbl, col, row, showABBias, relativeBiasLabel, relativeBiasScore, relativeBiasTip)
````
