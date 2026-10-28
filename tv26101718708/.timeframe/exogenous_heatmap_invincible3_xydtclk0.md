# Exogenous Heatmap [invincible3]

- url: https://www.tradingview.com/script/XydtcLK0-Exogenous-Heatmap-invincible3/
- type: indicator
- pine_id: PUB;1487746d11644174b2a5e9f925662624
- version: 1.0

## Description

[b]Exogenous Heatmap [invincible3][/b]

The Exogenous Heatmap is a multi-country macro and market-performance dashboard designed to help traders and investors monitor external economic forces that may influence currencies, equities, commodities, and broader risk sentiment.

Instead of focusing only on price action from the current chart, this indicator visualizes key exogenous variables across major economies in a clean historical heatmap format. Users can compare countries by interest rates, GDP growth, balance of trade, foreign exchange reserves, and major stock index performance.

The indicator supports two calculation modes:

[b]1. Raw Value[/b]
Displays the actual macroeconomic value or stock index performance for each country.

[b]2. Differential vs Base[/b]
Compares each country against a selected base country. This is useful for identifying relative macro strength or weakness. For example, if the base country is set to the USA, the indicator shows how Australia, Japan, the UK, Europe, China, and other countries compare against the United States.

The heatmap includes the following datasets:

[b]Interest Rates and Differentials[/b]
Displays policy interest rates or interest-rate differentials between countries. This is especially useful for forex analysis because higher relative interest rates can influence capital flows and currency strength.

[b]GDP and Differentials[/b]
Displays GDP year-over-year growth or GDP growth differentials. This helps identify which economies are expanding faster or slower relative to the selected base country.

[b]Balance of Trade and Differentials[/b]
Displays trade balance data. A stronger trade surplus may indicate external demand strength, while a deficit may reflect import pressure or weaker export competitiveness.

[b]Reserves and Differentials[/b]
Displays foreign exchange reserve levels. This can help assess external liquidity strength and a country’s ability to manage currency or balance-of-payment stress.

[b]Stock Index Performance and Differentials[/b]
Displays the performance of major stock indexes from leading economies. This adds a global risk-on/risk-off component to the indicator. Strong equity index performance may reflect improving investor sentiment, while weak performance may signal risk aversion.

The default stock index symbols include:

Australia: ASX 200
Canada: TSX Composite
China: Shanghai Composite
Europe: Euro Stoxx 50
Japan: Nikkei 225
New Zealand: NZX 50
Switzerland: SMI
United Kingdom: FTSE 100
United States: S&P 500

Users can manually change these symbols from the settings panel if they prefer alternative benchmarks.

[b]Example 1: Interest Rate Differential[/b]

Suppose the selected dataset is [b]Interest Rates and Differentials[/b] and the base country is set to [b]USA[/b].

If:

USA interest rate = 5.50%
Japan interest rate = 0.50%

Then Japan’s differential versus the USA is:

0.50% - 5.50% = -5.00 pp 

This means Japan’s policy rate is 5.00 percentage points lower than the USA. In the heatmap, this would appear as a negative differential and would be colored toward the negative side of the gradient.

[b]Example 2: Stock Index Performance Differential[/b]

Suppose the selected dataset is [b]Stock Index Performance and Differentials[/b] and the timeframe is set to [b]Monthly[/b].

If:

USA S&P 500 monthly return = +4.20%
Japan Nikkei 225 monthly return = +2.10%

Then Japan’s stock index performance differential versus the USA is:

2.10% - 4.20% = -2.10 pp

This means Japan’s equity market underperformed the USA by 2.10 percentage points during that monthly period.

[b]Example 3: Raw Stock Index Performance[/b]

If the calculation mode is set to [b]Raw Value[/b], the indicator displays each country’s own index return for the selected period.

For example:

USA: +4.20%
Japan: +2.10%
UK: -1.30%
Europe: +0.80%

This allows users to quickly identify which regions are leading or lagging in global equity performance.

[b]Color Interpretation[/b]

Positive values are shown using the positive color gradient.
Negative values are shown using the negative color gradient.
Neutral or near-zero values are shown near the neutral color.

The indicator includes both automatic and manual color scaling. Auto Scale adjusts the heatmap based on the strongest visible value, while Manual Scale lets the user set a fixed range for more consistent comparisons.

[b]How Traders Can Use It[/b]

Forex traders can use interest-rate and GDP differentials to evaluate relative currency strength.

Macro traders can use trade balance and reserve data to identify external economic pressure or resilience.

Equity and index traders can use global stock index performance to track international risk sentiment.

Commodity traders can use the dashboard as a macro backdrop because global growth, rates, and risk appetite often influence commodity demand and capital flows.

[b]Important Notes[/b]

For percentage-based datasets such as interest rates, GDP growth, and stock index returns, differential values are displayed in percentage points, abbreviated as “pp.”

For balance of trade and reserves, raw values may often be more meaningful than differentials because countries may report values in different scales or currencies.

This indicator is designed as a macro and risk-sentiment visualization tool. It should be used together with technical analysis, fundamental analysis, and proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © invincible3

//@version=6
indicator("Exogenous Heatmap [invincible3]", overlay=true, dynamic_requests=true)

// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
// |                                   INPUTS                                   |
// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|

// --- Macro Dataset ---
macroSet = input.string(
     "Interest Rates and Differentials",
     "Macro Dataset",
     options=[
         "Interest Rates and Differentials",
         "GDP and Differentials",
         "Balance of Trade and Differentials",
         "Reserves and Differentials",
         "Stock Index Performance and Differentials"
     ],
     group="Macro Settings"
)

calcMode = input.string(
     "Differential vs Base",
     "Calculation Mode",
     options=["Raw Value", "Differential vs Base"],
     group="Macro Settings",
     tooltip="Raw Value shows the selected economic/index value. Differential vs Base subtracts the selected base country value from each country."
)

baseCountry = input.string(
     "USA",
     "Differential Base",
     options=["Australia", "Canada", "China", "Europe", "Japan", "New Zealand", "Switzerland", "UK", "USA"],
     group="Macro Settings"
)

// --- Stock Index Symbols ---
auIndex = input.symbol("ASX:XJO",      "Australia Index",     group="Stock Index Symbols")
caIndex = input.symbol("TSX:TSX",      "Canada Index",        group="Stock Index Symbols")
cnIndex = input.symbol("SSE:000001",   "China Index",         group="Stock Index Symbols")
euIndex = input.symbol("TVC:SX5E",     "Europe Index",        group="Stock Index Symbols")
jpIndex = input.symbol("TVC:NI225",    "Japan Index",         group="Stock Index Symbols")
nzIndex = input.symbol("NZX:NZ50G",    "New Zealand Index",   group="Stock Index Symbols")
chIndex = input.symbol("SIX:SMI",      "Switzerland Index",   group="Stock Index Symbols")
gbIndex = input.symbol("TVC:UKX",      "UK Index",            group="Stock Index Symbols")
usIndex = input.symbol("SP:SPX",       "USA Index",           group="Stock Index Symbols")

// --- Table Settings ---
showTable = input.bool(true, "Show Table", group="Table Settings")
tablePos  = input.string("Middle Right", "Table Location", options=["Top Right", "Middle Right", "Bottom Right", "Top Center", "Middle Center", "Bottom Center", "Top Left", "Middle Left", "Bottom Left"], group="Table Settings")
tableSiz  = input.string("Small", "Table Size", options=["Auto", "Huge", "Large", "Normal", "Small", "Tiny"], group="Table Settings")

upCol = input.color(#089981, "Positive", group="Table Settings")
mdCol = input.color(#FFEF00, "Neutral", group="Table Settings")
dnCol = input.color(#f23645, "Negative", group="Table Settings")

// --- Technical Settings ---
timFrm = input.string("Monthly", "Timeframe", options=["Yearly", "Quarterly", "Monthly", "Weekly"], group="Technical Settings")
calMod = input.string("Period", "Fetch By", options=["Date", "Period"], group="Technical Settings")
sDate  = input.time(timestamp("01 Jan 2019 00:00"), "Start Date", group="Technical Settings")
sPerd  = input.int(25, "Periods", minval=1, maxval=80, group="Technical Settings")

// --- Color Scale ---
autoScale   = input.bool(true, "Auto Color Scale", group="Color Scale")
manualScale = input.float(10.0, "Manual Scale ±", minval=0.5, step=0.5, group="Color Scale")

// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
// |                                  CONSTANTS                                 |
// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|

const int MAX_ROWS  = 80
const int DATA_COLS = 10
const int COLS      = DATA_COLS + 1

tBgCol = chart.bg_color
tFgCol = chart.fg_color

// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
// |                                   TYPES                                    |
// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|

type MacroColumn
    string title
    array<float> history

method pushValue(MacroColumn this, float value) =>
    array.unshift(this.history, value)

method updateCurrent(MacroColumn this, float value) =>
    if array.size(this.history) > 0
        array.set(this.history, 0, value)

method trim(MacroColumn this, int maxRows) =>
    while array.size(this.history) > maxRows
        array.pop(this.history)

method valueAt(MacroColumn this, int row) =>
    row >= 0 and row < array.size(this.history) ? array.get(this.history, row) : na

method size(MacroColumn this) =>
    array.size(this.history)

// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
// |                                  HELPERS                                   |
// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|

getPos(x) =>
    switch x
        "Top Right"      => position.top_right
        "Middle Right"   => position.middle_right
        "Bottom Right"   => position.bottom_right
        "Top Center"     => position.top_center
        "Middle Center"  => position.middle_center
        "Bottom Center"  => position.bottom_center
        "Top Left"       => position.top_left
        "Middle Left"    => position.middle_left
        "Bottom Left"    => position.bottom_left
        => position.middle_right

getSize(x) =>
    switch x
        "Auto"   => size.auto
        "Huge"   => size.huge
        "Large"  => size.large
        "Normal" => size.normal
        "Small"  => size.small
        "Tiny"   => size.tiny
        => size.small

tf = switch timFrm
    "Yearly"    => "12M"
    "Quarterly" => "3M"
    "Monthly"   => "1M"
    "Weekly"    => "1W"
    => "1M"

isIndexMode() =>
    macroSet == "Stock Index Performance and Differentials"

macroSuffix() =>
    switch macroSet
        "Interest Rates and Differentials"     => "INTR"
        "GDP and Differentials"                => "GDPYY"
        "Balance of Trade and Differentials"   => "BOT"
        "Reserves and Differentials"           => "FER"
        => "INTR"

macroShortName() =>
    switch macroSet
        "Interest Rates and Differentials"             => "Interest Rates"
        "GDP and Differentials"                        => "GDP YoY"
        "Balance of Trade and Differentials"           => "Balance of Trade"
        "Reserves and Differentials"                   => "Foreign Exchange Reserves"
        "Stock Index Performance and Differentials"    => "Stock Index Performance"
        => "Macro"

isPercentMetric() =>
    macroSet == "Interest Rates and Differentials" or macroSet == "GDP and Differentials" or isIndexMode()

baseCode() =>
    switch baseCountry
        "Australia"     => "AU"
        "Canada"        => "CA"
        "China"         => "CN"
        "Europe"        => "EU"
        "Japan"         => "JP"
        "New Zealand"   => "NZ"
        "Switzerland"   => "CH"
        "UK"            => "GB"
        "USA"           => "US"
        => "US"

baseIndexSymbol() =>
    switch baseCountry
        "Australia"     => auIndex
        "Canada"        => caIndex
        "China"         => cnIndex
        "Europe"        => euIndex
        "Japan"         => jpIndex
        "New Zealand"   => nzIndex
        "Switzerland"   => chIndex
        "UK"            => gbIndex
        "USA"           => usIndex
        => usIndex

absNoNa(v) => na(v) ? 0.0 : math.abs(v)

timeLabel(ts) =>
    switch timFrm
        "Yearly"    => str.format_time(ts, "yyyy", syminfo.timezone)
        "Weekly"    => str.format_time(ts, "dd-MM-yyyy", syminfo.timezone)
        => str.format_time(ts, "MMM-yyyy", syminfo.timezone)

compactNumber(v) =>
    av = math.abs(v)
    av >= 1000000000000 ? str.tostring(v / 1000000000000, "#.##") + "T" :
     av >= 1000000000   ? str.tostring(v / 1000000000, "#.##") + "B" :
     av >= 1000000      ? str.tostring(v / 1000000, "#.##") + "M" :
     av >= 1000         ? str.tostring(v / 1000, "#.##") + "K" :
                          str.tostring(v, "#.##")

fmt(v) =>
    if na(v)
        "na"
    else
        if isPercentMetric()
            calcMode == "Differential vs Base" ? str.tostring(v, "#.##") + " pp" : str.tostring(v, "#.##") + "%"
        else
            compactNumber(v)

cellColor(v, scale) =>
    if na(v)
        color.new(tBgCol, 0)
    else
        lim = scale <= 0 ? 1.0 : scale
        x = math.max(math.min(v, lim), -lim)
        x > 0 ? color.from_gradient(x, 0, lim, mdCol, upCol) :
         x < 0 ? color.from_gradient(x, -lim, 0, dnCol, mdCol) :
                 mdCol

readableTextColor(bg) =>
    r = color.r(bg)
    g = color.g(bg)
    b = color.b(bg)
    brightness = (r * 299 + g * 587 + b * 114) / 1000
    brightness > 150 ? color.black : color.white

cellTextColor(v, scale) =>
    if na(v)
        tFgCol
    else
        bg = cellColor(v, scale)
        readableTextColor(bg)

// Fetch macro value or stock index period performance
fetchValue(countryCode, indexSymbol) =>
    float result = na

    if isIndexMode()
        result := request.security(
             indexSymbol,
             tf,
             (close / close[1] - 1.0) * 100.0,
             gaps=barmerge.gaps_off,
             lookahead=barmerge.lookahead_off,
             ignore_invalid_symbol=true
        )
    else
        string sym = "ECONOMICS:" + countryCode + macroSuffix()
        result := request.security(
             sym,
             tf,
             close,
             gaps=barmerge.gaps_off,
             lookahead=barmerge.lookahead_off,
             ignore_invalid_symbol=true
        )

    result

calcValue(rawValue, baseValue) =>
    calcMode == "Differential vs Base" ? rawValue - baseValue : rawValue

meanValid(values) =>
    sum = 0.0
    cnt = 0
    for i = 0 to array.size(values) - 1
        v = array.get(values, i)
        if not na(v)
            sum += v
            cnt += 1
    cnt > 0 ? sum / cnt : na

// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
// |                            COLUMN OBJECT STORAGE                           |
// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|

var int[] timH = array.new_int()
var array<MacroColumn> columns = array.new<MacroColumn>()

if barstate.isfirst
    array.push(columns, MacroColumn.new("Australia",   array.new_float()))
    array.push(columns, MacroColumn.new("Canada",      array.new_float()))
    array.push(columns, MacroColumn.new("China",       array.new_float()))
    array.push(columns, MacroColumn.new("Europe",      array.new_float()))
    array.push(columns, MacroColumn.new("Japan",       array.new_float()))
    array.push(columns, MacroColumn.new("New Zealand", array.new_float()))
    array.push(columns, MacroColumn.new("Switzerland", array.new_float()))
    array.push(columns, MacroColumn.new("UK",          array.new_float()))
    array.push(columns, MacroColumn.new("USA",         array.new_float()))
    array.push(columns, MacroColumn.new("Global",      array.new_float()))

storeColumn(idx, value) =>
    col = array.get(columns, idx)
    col.pushValue(value)
    col.trim(MAX_ROWS)

refreshColumn(idx, value) =>
    col = array.get(columns, idx)
    col.updateCurrent(value)

columnValue(idx, row) =>
    col = array.get(columns, idx)
    col.valueAt(row)

columnTitle(idx) =>
    col = array.get(columns, idx)
    col.title

trimTimeHistory() =>
    while array.size(timH) > MAX_ROWS
        array.pop(timH)

// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
// |                              MACRO / INDEX DATA                            |
// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|

baseVal = fetchValue(baseCode(), baseIndexSymbol())

auRaw  = fetchValue("AU", auIndex)
caRaw  = fetchValue("CA", caIndex)
cnRaw  = fetchValue("CN", cnIndex)
euRaw  = fetchValue("EU", euIndex)
jpRaw  = fetchValue("JP", jpIndex)
nzRaw  = fetchValue("NZ", nzIndex)
chRaw  = fetchValue("CH", chIndex)
gbRaw  = fetchValue("GB", gbIndex)
usRaw  = fetchValue("US", usIndex)

au  = calcValue(auRaw, baseVal)
ca  = calcValue(caRaw, baseVal)
cn  = calcValue(cnRaw, baseVal)
eu  = calcValue(euRaw, baseVal)
jp  = calcValue(jpRaw, baseVal)
nzd = calcValue(nzRaw, baseVal)
ch  = calcValue(chRaw, baseVal)
gb  = calcValue(gbRaw, baseVal)
us  = calcValue(usRaw, baseVal)

countryValues = array.from(au, ca, cn, eu, jp, nzd, ch, gb, us)
gl = meanValid(countryValues)

allValues = array.from(au, ca, cn, eu, jp, nzd, ch, gb, us, gl)

// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
// |                              STORE HISTORY                                 |
// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|

periodTime = time(tf)
isNewPeriod = ta.change(periodTime) != 0 or barstate.isfirst
allowStore  = calMod == "Date" ? time >= sDate : true

if isNewPeriod and allowStore
    array.unshift(timH, periodTime)
    trimTimeHistory()
    for i = 0 to array.size(allValues) - 1
        storeColumn(i, array.get(allValues, i))

if array.size(timH) > 0
    for i = 0 to array.size(allValues) - 1
        refreshColumn(i, array.get(allValues, i))

// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
// |                                  TABLE                                     |
// |++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|

txtSize = getSize(tableSiz)

var table tbl = table.new(
     getPos(tablePos),
     COLS,
     MAX_ROWS + 2,
     bgcolor=color.new(tBgCol, 100),
     frame_color=tFgCol,
     frame_width=1,
     border_color=color.new(tFgCol, 70),
     border_width=0
)

cell(col, row, txt, bg, txtCol) =>
    table.cell(
         tbl,
         col,
         row,
         text=txt,
         bgcolor=bg,
         text_color=txtCol,
         text_size=txtSize,
         text_font_family=font.family_monospace
    )

visibleRows() =>
    n = calMod == "Period" ? math.min(sPerd, array.size(timH)) : array.size(timH)
    math.min(n, MAX_ROWS)

visibleScale(rows) =>
    maxAbs = 0.0
    if rows > 0
        for r = 0 to rows - 1
            for c = 0 to array.size(columns) - 1
                maxAbs := math.max(maxAbs, absNoNa(columnValue(c, r)))
    scale = autoScale ? maxAbs : manualScale
    scale <= 0 ? 1.0 : scale

titleText(startTxt, endTxt) =>
    modeTxt = calcMode == "Differential vs Base" ? "Differential vs " + baseCountry : isIndexMode() ? "Raw Performance" : "Raw Value"
    macroShortName() + " Heatmap | " + modeTxt + " | " + timFrm + " | " + startTxt + " To " + endTxt

if barstate.islast
    table.clear(tbl, 0, 0, COLS - 1, MAX_ROWS + 1)

    if showTable
        rows = visibleRows()

        if rows > 0 and array.size(columns) == DATA_COLS
            scale = visibleScale(rows)

            startTxt = timeLabel(array.get(timH, rows - 1))
            endTxt   = timeLabel(array.get(timH, 0))

            table.merge_cells(tbl, 0, 0, COLS - 1, 0)
            cell(0, 0, titleText(startTxt, endTxt), tBgCol, tFgCol)

            cell(0, 1, "Date", tFgCol, tBgCol)

            for c = 0 to array.size(columns) - 1
                cell(c + 1, 1, columnTitle(c), tFgCol, tBgCol)

            for r = 0 to rows - 1
                rowNum = r + 2
                cell(0, rowNum, timeLabel(array.get(timH, r)), tBgCol, tFgCol)

                for c = 0 to array.size(columns) - 1
                    v = columnValue(c, r)
                    cell(c + 1, rowNum, fmt(v), cellColor(v, scale), cellTextColor(v, scale))
````
