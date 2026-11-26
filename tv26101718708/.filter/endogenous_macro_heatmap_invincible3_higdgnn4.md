# Endogenous Macro Heatmap [invincible3]

- url: https://www.tradingview.com/script/hiGDgNN4-Endogenous-Macro-Heatmap-invincible3/
- type: indicator
- pine_id: PUB;a031218927b4406b99bb56a261810f84
- version: 1.0

## Description

[b]Endogenous Macro Heatmap [invincible3][/b]

The Endogenous Macro Heatmap is a multi-factor macroeconomic dashboard designed to show the internal economic condition of a selected country in a compact table format directly on the chart.

Unlike cross-country or exogenous comparison models, this indicator focuses on domestic macro conditions : growth, production, demand, liquidity, rates, inflation, employment, fiscal position, debt pressure, and central bank balance sheet behavior.

The goal is to help traders, investors, and macro analysts quickly assess whether a country’s internal economic backdrop is improving, neutral, weakening, or entering a stress phase.

The indicator uses a heatmap structure so that changes in the macro environment can be understood visually. Stronger readings are shown through the positive color gradient, weaker readings through the negative color gradient, and balanced or transition zones through the neutral color.

[b]What This Indicator Measures[/b]

The heatmap tracks a broad set of endogenous macro variables, including:
[list]
[*]GDP year-over-year growth
[*]Manufacturing production / manufacturing index
[*]New orders or capacity utilization
[*]Building permits, construction output, construction orders, or housing starts depending on the selected country
[*]Retail sales year-over-year
[*]Money supply
[*]10-year government bond yield
[*]Interest rate
[*]Inflation year-over-year
[*]Employment-related data
[*]Debt-to-GDP
[*]Government budget
[*]Central bank balance sheet
[/list]
Because macro data availability differs across countries, the script automatically substitutes certain fields where required. For example, some countries may use construction output, construction orders, housing starts, or capacity utilization depending on what is available in the TradingView economic database.

[b]Supported Countries[/b]

The dashboard currently supports:
[list]
[*]United States
[*]United Kingdom
[*]Euro Area
[*]Germany
[*]France
[*]Italy
[*]Canada
[*]Japan
[*]China
[*]Australia
[*]South Korea
[*]New Zealand
[/list]
Each country uses its corresponding TradingView economic code where available.

[b]Composite Macro Score[/b]

The final Score column converts multiple macro readings into a single composite score from 0 to 100.

The score is grouped into four macro blocks:

[b]1. Growth Block[/b]

Includes GDP, manufacturing, new orders, construction/building activity, retail sales, and employment.

This block has the largest weight because real economic momentum is the primary driver of macro regime strength.

[b]2. Liquidity Block[/b]

Includes money supply and central bank balance sheet data.

This block helps identify whether domestic liquidity conditions are expanding or contracting.

[b]3. Tightness Block[/b]

Includes 10-year yield and interest rate conditions.

This block helps measure whether financial conditions are becoming easier or tighter.

[b]4. Stability Block[/b]

Includes inflation, debt/GDP, and government budget data.

This block helps detect macro pressure from inflation, fiscal stress, or excessive debt burden.

The composite score is weighted as follows:
[list]
[*]Growth: 45%
[*]Liquidity: 20%
[*]Tightness: 20%
[*]Stability: 15%
[/list]
[b]Score Interpretation[/b]

The score is displayed as a clean numeric value without extra symbols, making the table easier to read.

General interpretation:
[list]
[*]70–100: Strong macro condition
[*]55–69: Positive / improving condition
[*]45–54: Neutral / transition condition
[*]30–44: Weak condition
[*]Below 30: Stress condition
[/list]
The score should not be interpreted as a direct buy or sell signal. It is a macro regime filter designed to provide context.

[b] Heatmap Color Logic[/b]

The table uses a simple and consistent three-color structure:

[list]
[*]Positive color: stronger or favorable macro readings
[*]Neutral color:  balanced or mid-range readings
[*]Negative color: weaker or unfavorable macro readings
[/list]
The color system is intentionally matched with the Exogenous Heatmap style, allowing both dashboards to be used together with a consistent visual language.

Each macro field also includes an **Up Good** setting. This allows the user to define whether higher values are favorable or unfavorable for each metric.

For example:
[list]
[*]Higher GDP growth is generally positive.
[*]Higher manufacturing activity is generally positive.
[*]Higher liquidity can be positive.
[*]Higher inflation, debt, or rates may be interpreted differently depending on the user’s macro framework.
[/list]
This flexibility allows the heatmap to be adapted for different economic regimes and analytical preferences.

[b]Auto and Manual Scaling[/b]

The indicator includes an automatic macro gradient scale.

When auto scaling is enabled, the heatmap normalizes each metric based on the visible historical table range. This makes the table visually adaptive and easier to compare across different periods.

Manual scaling is also available for users who prefer fixed macro ranges.

This is useful when comparing the same country across different time periods or when the user wants a stable visual reference.

[b]Timeframe and History Controls[/b]

Users can select the table period:
[list]
[*]Yearly
[*]Quarterly
[*]Monthly
[*]Weekly
[*]Daily
[/list]
The data can be fetched by:
[list]
[*]A fixed number of periods
[*]A selected start date
[/list]

This gives flexibility for short-term macro monitoring as well as longer-term economic cycle analysis.

[b]Table Customization[/b]

The dashboard includes several table display settings:
[list]
[*]Show or hide table
[*]Select table position
[*]Select table size
[*]Customize positive, neutral, and negative colors
[/list]
The table automatically adapts to the chart background and foreground colors for better readability on both dark and light chart themes.

[b]How to Use[/b]

This indicator is best used as a macro context tool.

A practical workflow:

1. Select the country you want to analyze.
2. Choose the table period, such as monthly or quarterly.
3. Review the color trend across the macro fields.
4. Watch whether growth, liquidity, tightness, and stability are improving or deteriorating together.
5. Use the composite score as a broad internal macro regime filter.
6. Combine the macro backdrop with price action, trend, liquidity, sector rotation, and risk management.

For example:
[list]
[*]A rising score with improving growth and liquidity may support a risk-on environment.
[*]A falling score with weakening growth and tightening conditions may warn of macro deterioration.
[*]A neutral score may indicate a transition period where markets can become more sensitive to new economic data.
[/list]
[b]Suggested Use Cases[/b]

This heatmap can be useful for:
[list]
[*]Macro regime analysis
[*]Country-level economic monitoring
[*]Risk-on / risk-off context
[*]Equity index analysis
[*]Bond market context
[*]Currency market macro background
[*]Sector rotation research
[*]Long-term investment cycle analysis
[*]Comparing domestic conditions with external macro pressure when used together with an exogenous heatmap
[/list]
[b] Important Notes[/b]

Economic data can be revised, delayed, or unavailable depending on the country and TradingView’s data coverage.

Some fields may not exist for every country, so the script uses alternative fields where possible.

The heatmap is designed for macro analysis and educational research. It does not predict price direction by itself and should not be used as a standalone trading system.

Always combine macro signals with technical analysis, market structure, liquidity conditions, and proper risk management.

[b]Disclaimer[/b]

This script is for educational and analytical purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any asset.

Markets are influenced by many factors beyond macroeconomic data, including positioning, liquidity, earnings, policy changes, geopolitical events, and sentiment. Use this tool as one layer of a broader decision-making process.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © invincible3

//@version=6
indicator("Endogenous Macro Heatmap [invincible3]", overlay=true, max_labels_count=500, dynamic_requests=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showTable = input.bool(true, "Show Table", group="Table Setting")

tablePos = input.string(
     "Middle Right",
     "Table Location",
     options=[
         "Top Right", "Middle Right", "Bottom Right",
         "Top Center", "Middle Center", "Bottom Center",
         "Top Left", "Middle Left", "Bottom Left"
     ],
     group="Table Setting"
)

tableSiz = input.string(
     "Small",
     "Table Size",
     options=["Auto", "Huge", "Large", "Normal", "Small", "Tiny"],
     group="Table Setting"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE COLORS - MATCH EXOGENOUS HEATMAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

upCol = input.color(#089981, "Positive", group="Table Setting")
mdCol = input.color(#FFEF00, "Neutral",  group="Table Setting")
dnCol = input.color(#f23645, "Negative", group="Table Setting")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLOR SCALE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

autoMacroScale = input.bool(true, "Auto Macro Gradient Scale", group="Color Scale")
manualMinMacro = input.float(0.0, "Manual Min Macro", step=0.25, group="Color Scale")
manualMaxMacro = input.float(6.0, "Manual Max Macro", step=0.25, group="Color Scale")

country = input.string(
     "United States",
     "Country",
     options=[
         "Australia", "Canada", "China", "Euro", "France", "Germany",
         "Italy", "Japan", "South Korea", "United Kingdom", "United States", "New Zealand"
     ],
     group="Technical Setting"
)

timFrm = input.string(
     "Monthly",
     "Table Period",
     options=["Yearly", "Quarterly", "Monthly", "Weekly", "Daily"],
     group="Technical Setting"
)

calMod = input.string(
     "Period",
     "Fetch By",
     options=["Date", "Period"],
     group="Technical Setting"
)

sDate = input.time(timestamp("01 Jan 2019 00:00"), "Start Date", group="Technical Setting")
sPerd = input.int(25, "Periods", minval=1, maxval=100, group="Technical Setting")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MACRO FIELD SETTINGS
// Up Good = true  → high value is good.
// Up Good = false → low value is good.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

m1Label  = input.string("GDP YoY", "Label", group="Macro Fields", inline="m1")
m1Field  = input.string("GDPYY", "Field", group="Macro Fields", inline="m1")
m1Good   = input.bool(true, "Up Good", group="Macro Fields", inline="m1")

m2Label  = input.string("Mfg Prod YoY", "Label", group="Macro Fields", inline="m2")
m2Field  = input.string("MPRYY", "Field", group="Macro Fields", inline="m2")
m2Good   = input.bool(true, "Up Good", group="Macro Fields", inline="m2")

m3Label  = input.string("New Orders", "Label", group="Macro Fields", inline="m3")
m3Field  = input.string("NO", "Field", group="Macro Fields", inline="m3")
m3Good   = input.bool(true, "Up Good", group="Macro Fields", inline="m3")

m5Label  = input.string("Build Permits", "Label", group="Macro Fields", inline="m5")
m5Field  = input.string("BP", "Field", group="Macro Fields", inline="m5")
m5Good   = input.bool(true, "Up Good", group="Macro Fields", inline="m5")

m6Label  = input.string("Retail YoY", "Label", group="Macro Fields", inline="m6")
m6Field  = input.string("RSYY", "Field", group="Macro Fields", inline="m6")
m6Good   = input.bool(true, "Up Good", group="Macro Fields", inline="m6")

m7Label  = input.string("Money M2", "Label", group="Macro Fields", inline="m7")
m7Field  = input.string("M2", "Field", group="Macro Fields", inline="m7")
m7Good   = input.bool(true, "Up Good", group="Macro Fields", inline="m7")

m8Label  = input.string("Interest Rate", "Label", group="Macro Fields", inline="m8")
m8Field  = input.string("INTR", "Field", group="Macro Fields", inline="m8")
m8Good   = input.bool(true, "Up Good", group="Macro Fields", inline="m8")

m9Label  = input.string("Inflation YoY", "Label", group="Macro Fields", inline="m9")
m9Field  = input.string("IRYY", "Field", group="Macro Fields", inline="m9")
m9Good   = input.bool(true, "Up Good", group="Macro Fields", inline="m9")

m10Label = input.string("Employment", "Label", group="Macro Fields", inline="m10")
m10Good  = input.bool(true, "Up Good", group="Macro Fields", inline="m10")

m11Label = input.string("Debt/GDP", "Label", group="Macro Fields", inline="m11")
m11Field = input.string("GDG", "Field", group="Macro Fields", inline="m11")
m11Good  = input.bool(true, "Up Good", group="Macro Fields", inline="m11")

m12Label = input.string("Gov Budget", "Label", group="Macro Fields", inline="m12")
m12Field = input.string("GBP", "Field", group="Macro Fields", inline="m12")
m12Good  = input.bool(true, "Up Good", group="Macro Fields", inline="m12")

m13Label = input.string("CB Balance", "Label", group="Macro Fields", inline="m13")
m13Field = input.string("CBBS", "Field", group="Macro Fields", inline="m13")
m13Good  = input.bool(true, "Up Good", group="Macro Fields", inline="m13")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONSTANTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const int MAX_ROWS = 100
const int COLS = 15

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASIC HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_pos(x) =>
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

f_size(x) =>
    switch x
        "Auto"   => size.auto
        "Huge"   => size.huge
        "Large"  => size.large
        "Normal" => size.normal
        "Small"  => size.small
        "Tiny"   => size.tiny
        => size.small

tBgCol = chart.bg_color
tFgCol = chart.fg_color

readableTextColor(bg) =>
    r = color.r(bg)
    g = color.g(bg)
    b = color.b(bg)
    brightness = (r * 299 + g * 587 + b * 114) / 1000
    brightness > 150 ? color.black : color.white

f_contrastText(bg) =>
    readableTextColor(bg)

f_dateBg(rowNum) =>
    tBgCol

f_borderCol() =>
    color.new(tFgCol, 70)

code = switch country
    "United States"  => "US"
    "Euro"           => "EU"
    "United Kingdom" => "GB"
    "Germany"        => "DE"
    "France"         => "FR"
    "Italy"          => "IT"
    "Canada"         => "CA"
    "Japan"          => "JP"
    "China"          => "CN"
    "Australia"      => "AU"
    "South Korea"    => "KR"
    "New Zealand"    => "NZ"
    => "US"

tf =
     timFrm == "Yearly"    ? "12M" :
     timFrm == "Quarterly" ? "3M"  :
     timFrm == "Monthly"   ? "1M"  :
     timFrm == "Weekly"    ? "1W"  :
                              "1D"

f_fmt(v) =>
    if na(v)
        ""
    else
        av = math.abs(v)
        av >= 1000000000000 ? str.tostring(v / 1000000000000, "#.##") + "T" :
         av >= 1000000000 ? str.tostring(v / 1000000000, "#.##") + "B" :
         av >= 1000000 ? str.tostring(v / 1000000, "#.##") + "M" :
         av >= 1000 ? str.tostring(v / 1000, "#.##") + "K" :
                       str.tostring(v, "#.##")

f_fmtPct(v) =>
    na(v) ? "" : str.tostring(v, "#.##") + "%"

f_fmtScore(v) =>
    na(v) ? "" : str.tostring(v, "#")

f_fmtDate(ts) =>
    timFrm == "Yearly" ? str.format_time(ts, "yyyy", syminfo.timezone) :
     timFrm == "Quarterly" or timFrm == "Monthly" ? str.format_time(ts, "MMM-yyyy", syminfo.timezone) :
     str.format_time(ts, "dd-MM-yyyy", syminfo.timezone)

f_norm01(v, minV, maxV) =>
    hi = maxV <= minV ? minV + 1.0 : maxV
    math.max(math.min((v - minV) / (hi - minV), 1.0), 0.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SCALE FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_levelMin(_arr, _n) =>
    float mn = na
    for k = 0 to _n - 1
        v = array.get(_arr, k)
        if not na(v)
            mn := na(mn) ? v : math.min(mn, v)
    mn

f_levelMax(_arr, _n) =>
    float mx = na
    for k = 0 to _n - 1
        v = array.get(_arr, k)
        if not na(v)
            mx := na(mx) ? v : math.max(mx, v)
    mx

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SCORE FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_scoreValue(v, minV, maxV, upGood) =>
    if na(v) or na(minV) or na(maxV)
        na
    else if maxV <= minV
        50.0
    else
        x = f_norm01(v, minV, maxV)
        upGood ? x * 100.0 : (1.0 - x) * 100.0

f_arrScore(_arr, j, upGood, minV, maxV) =>
    v = array.get(_arr, j)
    f_scoreValue(v, minV, maxV, upGood)

f_avg2(a, b) =>
    float sum = 0.0
    float cnt = 0.0
    if not na(a)
        sum += a
        cnt += 1.0
    if not na(b)
        sum += b
        cnt += 1.0
    cnt > 0 ? sum / cnt : na

f_avg3(a, b, c) =>
    float sum = 0.0
    float cnt = 0.0
    if not na(a)
        sum += a
        cnt += 1.0
    if not na(b)
        sum += b
        cnt += 1.0
    if not na(c)
        sum += c
        cnt += 1.0
    cnt > 0 ? sum / cnt : na

f_avg6(a, b, c, d, e, g) =>
    float sum = 0.0
    float cnt = 0.0
    if not na(a)
        sum += a
        cnt += 1.0
    if not na(b)
        sum += b
        cnt += 1.0
    if not na(c)
        sum += c
        cnt += 1.0
    if not na(d)
        sum += d
        cnt += 1.0
    if not na(e)
        sum += e
        cnt += 1.0
    if not na(g)
        sum += g
        cnt += 1.0
    cnt > 0 ? sum / cnt : na

f_macroScore(growthScore, liquidityScore, tightnessScore, stabilityScore) =>
    float sum = 0.0
    float wt  = 0.0
    if not na(growthScore)
        sum += growthScore * 0.45
        wt  += 0.45
    if not na(liquidityScore)
        sum += liquidityScore * 0.20
        wt  += 0.20
    if not na(tightnessScore)
        sum += tightnessScore * 0.20
        wt  += 0.20
    if not na(stabilityScore)
        sum += stabilityScore * 0.15
        wt  += 0.15
    wt > 0 ? sum / wt : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLOR FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_levelColor(v, minV, maxV, upGood) =>
    if na(v) or na(minV) or na(maxV)
        color.new(tBgCol, 0)
    else
        x = f_norm01(v, minV, maxV)
        upGood ?
             (x <= 0.5 ? color.from_gradient(x, 0.0, 0.5, dnCol, mdCol) : color.from_gradient(x, 0.5, 1.0, mdCol, upCol)) :
             (x <= 0.5 ? color.from_gradient(x, 0.0, 0.5, upCol, mdCol) : color.from_gradient(x, 0.5, 1.0, mdCol, dnCol))

f_scoreColor(score) =>
    if na(score)
        color.new(tBgCol, 0)
    else
        x = math.max(math.min(score / 100.0, 1.0), 0.0)
        x <= 0.5 ? color.from_gradient(x, 0.0, 0.5, dnCol, mdCol) : color.from_gradient(x, 0.5, 1.0, mdCol, upCol)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

txtSize = f_size(tableSiz)

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
         tooltip=tip
    )

f_metricCell(_tbl, col, row, _arr, j, upGood, minV, maxV, lbl) =>
    v = array.get(_arr, j)
    bg = f_levelColor(v, minV, maxV, upGood)
    tip = lbl + ": " + f_fmt(v)
    f_cell(_tbl, col, row, f_fmt(v), bg, f_contrastText(bg), tip)

f_yieldCell(_tbl, col, row, _arr, j, upGood, minV, maxV, lbl) =>
    v = array.get(_arr, j)
    bg = f_levelColor(v, minV, maxV, upGood)
    tip = lbl + ": " + f_fmtPct(v)
    f_cell(_tbl, col, row, f_fmtPct(v), bg, f_contrastText(bg), tip)

f_scoreBand(score) =>
    na(score) ? "No data" :
     score >= 70 ? "Strong" :
     score >= 55 ? "Positive" :
     score >= 45 ? "Neutral" :
     score >= 30 ? "Weak" : "Stress"

f_scoreCell(_tbl, col, row, score) =>
    bg = f_scoreColor(score)
    tip = "Composite Score: " + f_fmtScore(score) + " | " + f_scoreBand(score)
    f_cell(_tbl, col, row, f_fmtScore(score), bg, f_contrastText(bg), tip)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA FETCH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_econ(_field) =>
    request.economic(code, _field, barmerge.gaps_off, true)

f_yield(_sym) =>
    request.security(_sym, tf, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

m1 = f_econ(m1Field)

manufacturingField = country == "New Zealand" ? "MS" : m2Field
manufacturingLabel = country == "New Zealand" ? "Mfg Idx" : m2Label
m2 = f_econ(manufacturingField)

newOrdersField = country == "Euro" or country == "New Zealand" ? "CU" : m3Field
newOrdersLabel = country == "Euro" or country == "New Zealand" ? "Capacity Uti" : m3Label
m3 = f_econ(newOrdersField)

buildingField = country == "United Kingdom" or country == "Italy" or country == "Euro" ? "COUT" : country == "South Korea" or country == "Japan" ? "CORD" : country == "China" ? "HST" : m5Field
buildingLabel = country == "United Kingdom" or country == "Italy" or country == "Euro" ? "Construction Output" : country == "South Korea" or country == "Japan" ? "Construction Orders" : country == "China" ? "Housing Starts" : m5Label
m5 = f_econ(buildingField)

m6 = f_econ(m6Field)

moneyField = country == "Australia" ? "M3" : m7Field
moneyLabel = country == "Australia" ? "Money M3" : m7Label
m7 = f_econ(moneyField)

y10 = f_yield(code + "10Y")
m8 = f_econ(m8Field)
m9 = f_econ(m9Field)

empField = country == "China" ? "EMP" : country == "Euro"  ? "EMC" : "EMR"
m10 = f_econ(empField)
m11 = f_econ(m11Field)
m12 = f_econ(m12Field)
m13 = f_econ(m13Field)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORE HISTORY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isNewPeriod = ta.change(time(tf)) != 0 or barstate.isfirst
allowStore  = calMod == "Date" ? time >= sDate : true

var int[] timeH = array.new_int()
var float[] m1H  = array.new_float()
var float[] m2H  = array.new_float()
var float[] m3H  = array.new_float()
var float[] m5H  = array.new_float()
var float[] m6H  = array.new_float()
var float[] m7H  = array.new_float()
var float[] y10H = array.new_float()
var float[] m8H  = array.new_float()
var float[] m9H  = array.new_float()
var float[] m10H = array.new_float()
var float[] m11H = array.new_float()
var float[] m12H = array.new_float()
var float[] m13H = array.new_float()

if isNewPeriod and allowStore
    array.unshift(timeH, time(tf))
    array.unshift(m1H, m1)
    array.unshift(m2H, m2)
    array.unshift(m3H, m3)
    array.unshift(m5H, m5)
    array.unshift(m6H, m6)
    array.unshift(m7H, m7)
    array.unshift(y10H, y10)
    array.unshift(m8H, m8)
    array.unshift(m9H, m9)
    array.unshift(m10H, m10)
    array.unshift(m11H, m11)
    array.unshift(m12H, m12)
    array.unshift(m13H, m13)

    if array.size(timeH) > MAX_ROWS
        array.pop(timeH)
        array.pop(m1H)
        array.pop(m2H)
        array.pop(m3H)
        array.pop(m5H)
        array.pop(m6H)
        array.pop(m7H)
        array.pop(y10H)
        array.pop(m8H)
        array.pop(m9H)
        array.pop(m10H)
        array.pop(m11H)
        array.pop(m12H)
        array.pop(m13H)

if array.size(timeH) > 0
    array.set(timeH, 0, time(tf))
    array.set(m1H, 0, m1)
    array.set(m2H, 0, m2)
    array.set(m3H, 0, m3)
    array.set(m5H, 0, m5)
    array.set(m6H, 0, m6)
    array.set(m7H, 0, m7)
    array.set(y10H, 0, y10)
    array.set(m8H, 0, m8)
    array.set(m9H, 0, m9)
    array.set(m10H, 0, m10)
    array.set(m11H, 0, m11)
    array.set(m12H, 0, m12)
    array.set(m13H, 0, m13)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table tbl = na

if barstate.islast
    n = calMod == "Period" ? math.min(sPerd, array.size(timeH)) : array.size(timeH)
    n := math.min(n, MAX_ROWS)

    if not showTable or array.size(timeH) == 0 or n <= 0
        if not na(tbl)
            table.delete(tbl)
            tbl := na
    else
        if na(tbl)
            tbl := table.new(
                 f_pos(tablePos),
                 COLS,
                 MAX_ROWS + 2,
                 bgcolor=color.new(tBgCol, 100),
                 frame_color=tFgCol,
                 frame_width=1,
                 border_color=f_borderCol(),
                 border_width=0
            )
        else
            table.clear(tbl, 0, 0, COLS - 1, MAX_ROWS + 1)

        m1Min  = autoMacroScale ? f_levelMin(m1H, n)  : manualMinMacro
        m1Max  = autoMacroScale ? f_levelMax(m1H, n)  : manualMaxMacro
        m2Min  = autoMacroScale ? f_levelMin(m2H, n)  : manualMinMacro
        m2Max  = autoMacroScale ? f_levelMax(m2H, n)  : manualMaxMacro
        m3Min  = autoMacroScale ? f_levelMin(m3H, n)  : manualMinMacro
        m3Max  = autoMacroScale ? f_levelMax(m3H, n)  : manualMaxMacro
        m5Min  = autoMacroScale ? f_levelMin(m5H, n)  : manualMinMacro
        m5Max  = autoMacroScale ? f_levelMax(m5H, n)  : manualMaxMacro
        m6Min  = autoMacroScale ? f_levelMin(m6H, n)  : manualMinMacro
        m6Max  = autoMacroScale ? f_levelMax(m6H, n)  : manualMaxMacro
        m7Min  = autoMacroScale ? f_levelMin(m7H, n)  : manualMinMacro
        m7Max  = autoMacroScale ? f_levelMax(m7H, n)  : manualMaxMacro
        y10Min = autoMacroScale ? f_levelMin(y10H, n) : manualMinMacro
        y10Max = autoMacroScale ? f_levelMax(y10H, n) : manualMaxMacro
        m8Min  = autoMacroScale ? f_levelMin(m8H, n)  : manualMinMacro
        m8Max  = autoMacroScale ? f_levelMax(m8H, n)  : manualMaxMacro
        m9Min  = autoMacroScale ? f_levelMin(m9H, n)  : manualMinMacro
        m9Max  = autoMacroScale ? f_levelMax(m9H, n)  : manualMaxMacro
        m10Min = autoMacroScale ? f_levelMin(m10H, n) : manualMinMacro
        m10Max = autoMacroScale ? f_levelMax(m10H, n) : manualMaxMacro
        m11Min = autoMacroScale ? f_levelMin(m11H, n) : manualMinMacro
        m11Max = autoMacroScale ? f_levelMax(m11H, n) : manualMaxMacro
        m12Min = autoMacroScale ? f_levelMin(m12H, n) : manualMinMacro
        m12Max = autoMacroScale ? f_levelMax(m12H, n) : manualMaxMacro
        m13Min = autoMacroScale ? f_levelMin(m13H, n) : manualMinMacro
        m13Max = autoMacroScale ? f_levelMax(m13H, n) : manualMaxMacro

        startTxt = f_fmtDate(array.get(timeH, n - 1))
        endTxt   = f_fmtDate(array.get(timeH, 0))

        titleBg = tBgCol
        headBg  = tFgCol
        titleTx = tFgCol
        headTx  = tBgCol

        table.merge_cells(tbl, 0, 0, COLS - 1, 0)
        f_cell(tbl, 0, 0, country + " Endogenous Macro Heatmap | " + timFrm + " | " + startTxt + " To " + endTxt, titleBg, titleTx)

        f_cell(tbl, 0,  1, "Date",               headBg, headTx)
        f_cell(tbl, 1,  1, m1Label,              headBg, headTx)
        f_cell(tbl, 2,  1, manufacturingLabel,   headBg, headTx)
        f_cell(tbl, 3,  1, newOrdersLabel,       headBg, headTx)
        f_cell(tbl, 4,  1, buildingLabel,        headBg, headTx)
        f_cell(tbl, 5,  1, m6Label,              headBg, headTx)
        f_cell(tbl, 6,  1, moneyLabel,           headBg, headTx)
        f_cell(tbl, 7,  1, "10Y Yield",          headBg, headTx)
        f_cell(tbl, 8,  1, m8Label,              headBg, headTx)
        f_cell(tbl, 9,  1, m9Label,              headBg, headTx)
        f_cell(tbl, 10, 1, m10Label,             headBg, headTx)
        f_cell(tbl, 11, 1, m11Label,             headBg, headTx)
        f_cell(tbl, 12, 1, m12Label,             headBg, headTx)
        f_cell(tbl, 13, 1, m13Label,             headBg, headTx)
        f_cell(tbl, 14, 1, "Score",              headBg, headTx)

        for j = 0 to n - 1
            row = j + 2
            tRow = array.get(timeH, j)
            dBg = f_dateBg(j)
            f_cell(tbl, 0, row, f_fmtDate(tRow), dBg, f_contrastText(dBg), "Date: " + f_fmtDate(tRow))

            f_metricCell(tbl, 1,  row, m1H,  j, m1Good,  m1Min,  m1Max, m1Label)
            f_metricCell(tbl, 2,  row, m2H,  j, m2Good,  m2Min,  m2Max, manufacturingLabel)
            f_metricCell(tbl, 3,  row, m3H,  j, m3Good,  m3Min,  m3Max, newOrdersLabel)
            f_metricCell(tbl, 4,  row, m5H,  j, m5Good,  m5Min,  m5Max, buildingLabel)
            f_metricCell(tbl, 5,  row, m6H,  j, m6Good,  m6Min,  m6Max, m6Label)
            f_metricCell(tbl, 6,  row, m7H,  j, m7Good,  m7Min,  m7Max, moneyLabel)
            f_yieldCell( tbl, 7,  row, y10H, j, false,   y10Min, y10Max, "10Y Yield")
            f_metricCell(tbl, 8,  row, m8H,  j, m8Good,  m8Min,  m8Max, m8Label)
            f_metricCell(tbl, 9,  row, m9H,  j, m9Good,  m9Min,  m9Max, m9Label)
            f_metricCell(tbl, 10, row, m10H, j, m10Good, m10Min, m10Max, m10Label)
            f_metricCell(tbl, 11, row, m11H, j, m11Good, m11Min, m11Max, m11Label)
            f_metricCell(tbl, 12, row, m12H, j, m12Good, m12Min, m12Max, m12Label)
            f_metricCell(tbl, 13, row, m13H, j, m13Good, m13Min, m13Max, m13Label)

            g1 = f_arrScore(m1H,  j, m1Good,  m1Min,  m1Max)
            g2 = f_arrScore(m2H,  j, m2Good,  m2Min,  m2Max)
            g3 = f_arrScore(m3H,  j, m3Good,  m3Min,  m3Max)
            g4 = f_arrScore(m5H,  j, m5Good,  m5Min,  m5Max)
            g5 = f_arrScore(m6H,  j, m6Good,  m6Min,  m6Max)
            g6 = f_arrScore(m10H, j, m10Good, m10Min, m10Max)
            growthScore = f_avg6(g1, g2, g3, g4, g5, g6)

            l1 = f_arrScore(m7H,  j, m7Good,  m7Min,  m7Max)
            l2 = f_arrScore(m13H, j, m13Good, m13Min, m13Max)
            liquidityScore = f_avg2(l1, l2)

            t1 = f_arrScore(y10H, j, false,  y10Min, y10Max)
            t2 = f_arrScore(m8H,  j, m8Good, m8Min,  m8Max)
            tightnessScore = f_avg2(t1, t2)

            s1 = f_arrScore(m9H,  j, m9Good,  m9Min,  m9Max)
            s2 = f_arrScore(m11H, j, m11Good, m11Min, m11Max)
            s3 = f_arrScore(m12H, j, m12Good, m12Min, m12Max)
            stabilityScore = f_avg3(s1, s2, s3)

            macroScore = f_macroScore(growthScore, liquidityScore, tightnessScore, stabilityScore)
            f_scoreCell(tbl, 14, row, macroScore)
````
