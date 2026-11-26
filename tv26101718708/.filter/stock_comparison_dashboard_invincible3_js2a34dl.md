# Stock: Comparison Dashboard [invincible3]

- url: https://www.tradingview.com/script/js2a34DL-Stock-Comparison-Dashboard-invincible3/
- type: indicator
- pine_id: PUB;d1a8a64a7e4d401e8828ccfd9d02b47a
- version: 1.0

## Description

[b]Stock: Comparison Dashboard [invincible3][/b]

**Stock: Comparison Dashboard [invincible3]** is a fundamental and market-strength comparison tool designed to compare two stocks side by side directly on the TradingView chart.

The dashboard helps traders and investors quickly evaluate which stock is stronger across multiple financial dimensions, including growth, income statement strength, profitability, valuation, cash flow quality, financial strength, liquidity, dividend quality, and relative price strength.

[b]Key Features[/b]

[b]1. Two-Stock Comparison[/b]

Select any two symbols and compare their financial metrics side by side. The dashboard displays both raw values and category-based scores.

[b]2. Fundamental Metrics[/b]

The indicator includes a wide set of financial metrics, such as:

* Revenue growth
* EPS growth
* Total revenue
* Operating income
* Net income
* Margins
* Return on equity
* Price-to-earnings ratio
* Price-to-sales ratio
* Free cash flow
* Debt ratios
* Current ratio
* Dividend yield
* Dividend payout ratio

[b]3. Category Scores[/b]

The dashboard calculates separate comparison scores for:

* Growth Score
* Income Score
* Profitability Score
* Valuation Score
* Cash Flow Score
* Financial Strength Score
* Liquidity Score
* Dividend Score
* Relative Strength Score

[b]4. Proportional Scoring System[/b]

The scoring system uses proportional comparison instead of simple winner-take-all logic.

For example, if one stock has 16% growth and another has 18% growth, the weaker stock does not receive 0. Instead, both stocks receive proportional scores based on how close their values are.

This makes the dashboard more realistic and useful for financial analysis.

[b]5. Relative Strength Score[/b]

The Relative Strength Score compares the market performance of both stocks using:

* 3-month price performance
* 6-month price performance
* 12-month price performance
* Position within the 52-week range
* Distance from the 200-day moving average

This helps identify which stock has stronger market momentum.

[b]6. Better / Weaker Value Highlighting[/b]

Better and weaker values are highlighted using text color instead of heavy background coloring. This keeps the table cleaner and easier to read.

[b]7. Light and Dark Table Themes[/b]

The dashboard includes both light and dark table themes, making it suitable for different TradingView chart layouts.

[b]8. Customizable Rows[/b]

Each category allows the user to choose which metrics to display. Unwanted rows can be set to “None” to keep the dashboard clean.

[b]How to Use[/b]

1. Select Stock 1 and Stock 2 from the indicator settings.
2. Choose the financial period: Quarter or Year.
3. Select the metrics you want to compare in each category.
4. Choose Light or Dark table theme.
5. Read the raw values and comparison scores to identify the stronger stock.

[b]Interpretation[/b]

A higher score means the stock is stronger in that specific category.

Example:

* Higher Growth Score = stronger growth profile
* Higher Profitability Score = better profitability
* Higher Valuation Score = more attractive valuation
* Higher Financial Strength Score = stronger balance sheet
* Higher Relative Strength Score = stronger market momentum

[b]Important Notes[/b]

This indicator uses TradingView financial data. Some financial fields may be unavailable for certain stocks, exchanges, or periods. If a metric is unavailable, the table may show a dash.

TradingView also has request limits, so the dashboard is designed to keep the number of active financial rows under control.

This indicator is intended for research, comparison, and educational analysis only. It is not financial advice. Always combine fundamental analysis with your own research, risk management, and market context.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © invincible3

//@version=6
indicator(
     "Stock: Comparison Dashboard [invincible3]",
     shorttitle = "Sk-Com",
     overlay = true,
     max_labels_count = 50,
     calc_bars_count = 400
)

//────────────────────────────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────────────────────────────
string GRP_SYMBOLS  = "SYMBOLS"
string GRP_PERIOD   = "PERIOD"
string GRP_SNAP     = "ROWS: SNAPSHOT"
string GRP_GROWTH   = "ROWS: GROWTH"
string GRP_INCOME   = "ROWS: INCOME STATEMENT"
string GRP_PROFIT   = "ROWS: PROFITABILITY"
string GRP_VALUE    = "ROWS: VALUATION"
string GRP_CF       = "ROWS: CASH FLOW QUALITY"
string GRP_STRENGTH = "ROWS: FINANCIAL STRENGTH"
string GRP_LIQ      = "ROWS: LIQUIDITY"
string GRP_DIV      = "ROWS: DIVIDEND QUALITY"
string GRP_VIS      = "VISUAL SETTINGS"

sym1 = input.symbol("NASDAQ:AAPL", "Stock 1", group = GRP_SYMBOLS, tooltip = "First stock for comparison")
sym2 = input.symbol("NASDAQ:MSFT", "Stock 2", group = GRP_SYMBOLS, tooltip = "Second stock for comparison")

periodMode = input.string("Quarter", "Financial Period", options = ["Quarter", "Year"], group = GRP_PERIOD, tooltip = "Financial data period (Quarterly or Annually)")

snap1 = input.string("Close", "Row 1", options = ["None", "Close", "Volume", "Market Capitalization", "Distance From 52 Week High", "Distance From 52 Week Low"], group = GRP_SNAP, tooltip = "Select metric for snapshot row 1")
snap2 = input.string("Volume", "Row 2", options = ["None", "Close", "Volume", "Market Capitalization", "Distance From 52 Week High", "Distance From 52 Week Low"], group = GRP_SNAP, tooltip = "Select metric for snapshot row 2")
snap3 = input.string("Market Capitalization", "Row 3", options = ["None", "Close", "Volume", "Market Capitalization", "Distance From 52 Week High", "Distance From 52 Week Low"], group = GRP_SNAP, tooltip = "Select metric for snapshot row 3")
snap4 = input.string("Distance From 52 Week High", "Row 4", options = ["None", "Close", "Volume", "Market Capitalization", "Distance From 52 Week High", "Distance From 52 Week Low"], group = GRP_SNAP, tooltip = "Select metric for snapshot row 4")
snap5 = input.string("Distance From 52 Week Low", "Row 5", options = ["None", "Close", "Volume", "Market Capitalization", "Distance From 52 Week High", "Distance From 52 Week Low"], group = GRP_SNAP, tooltip = "Select metric for snapshot row 5")

growth1 = input.string("Revenue One Year Growth", "Row 1", options = ["None", "Revenue One Year Growth", "EPS Diluted One Year Growth", "EPS Basic One Year Growth", "Sustainable Growth Rate", "Shares Buyback Ratio %", "Revenue Estimates", "EPS Estimates"], group = GRP_GROWTH, tooltip = "Select metric for growth row 1")
growth2 = input.string("EPS Diluted One Year Growth", "Row 2", options = ["None", "Revenue One Year Growth", "EPS Diluted One Year Growth", "EPS Basic One Year Growth", "Sustainable Growth Rate", "Shares Buyback Ratio %", "Revenue Estimates", "EPS Estimates"], group = GRP_GROWTH, tooltip = "Select metric for growth row 2")

income1 = input.string("Total Revenue", "Row 1", options = ["None", "Total Revenue", "Cost of Goods Sold", "Gross Profit", "Operating Income", "Net Income", "EBIT", "EBITDA", "Total Operating Expenses", "Research & Development"], group = GRP_INCOME, tooltip = "Select metric for income statement row 1")
income2 = input.string("Operating Income", "Row 2", options = ["None", "Total Revenue", "Cost of Goods Sold", "Gross Profit", "Operating Income", "Net Income", "EBIT", "EBITDA", "Total Operating Expenses", "Research & Development"], group = GRP_INCOME, tooltip = "Select metric for income statement row 2")
income3 = input.string("Net Income", "Row 3", options = ["None", "Total Revenue", "Cost of Goods Sold", "Gross Profit", "Operating Income", "Net Income", "EBIT", "EBITDA", "Total Operating Expenses", "Research & Development"], group = GRP_INCOME, tooltip = "Select metric for income statement row 3")

profit1 = input.string("Operating Margin %", "Row 1", options = ["None", "Gross Margin %", "Operating Margin %", "Net Margin %", "EBITDA Margin %", "Return on Equity %", "Return on Assets %", "Return on Invested Capital %", "Quality Ratio"], group = GRP_PROFIT, tooltip = "Select metric for profitability row 1")
profit2 = input.string("Net Margin %", "Row 2", options = ["None", "Gross Margin %", "Operating Margin %", "Net Margin %", "EBITDA Margin %", "Return on Equity %", "Return on Assets %", "Return on Invested Capital %", "Quality Ratio"], group = GRP_PROFIT, tooltip = "Select metric for profitability row 2")
profit3 = input.string("Return on Equity %", "Row 3", options = ["None", "Gross Margin %", "Operating Margin %", "Net Margin %", "EBITDA Margin %", "Return on Equity %", "Return on Assets %", "Return on Invested Capital %", "Quality Ratio"], group = GRP_PROFIT, tooltip = "Select metric for profitability row 3")

value1 = input.string("Price Earnings Ratio Forward", "Row 1", options = ["None", "Market Capitalization", "Free Float Shares", "Total Common Shares Outstanding", "Enterprise Value", "Price Earnings Ratio Forward", "Price To Earnings", "Price To Book Value", "Price Sales Ratio Forward", "Price To Sales", "PEG Ratio", "Enterprise Value to EBITDA", "Enterprise Value to Revenue", "Enterprise Value to EBIT", "Graham's Number", "Operating Earnings Yield %"], group = GRP_VALUE, tooltip = "Select metric for valuation row 1")
value2 = input.string("Price To Book Value", "Row 2", options = ["None", "Market Capitalization", "Free Float Shares", "Total Common Shares Outstanding", "Enterprise Value", "Price Earnings Ratio Forward", "Price To Earnings", "Price To Book Value", "Price Sales Ratio Forward", "Price To Sales", "PEG Ratio", "Enterprise Value to EBITDA", "Enterprise Value to Revenue", "Enterprise Value to EBIT", "Graham's Number", "Operating Earnings Yield %"], group = GRP_VALUE, tooltip = "Select metric for valuation row 2")
value3 = input.string("Price Sales Ratio Forward", "Row 3", options = ["None", "Market Capitalization", "Free Float Shares", "Total Common Shares Outstanding", "Enterprise Value", "Price Earnings Ratio Forward", "Price To Earnings", "Price To Book Value", "Price Sales Ratio Forward", "Price To Sales", "PEG Ratio", "Enterprise Value to EBITDA", "Enterprise Value to Revenue", "Enterprise Value to EBIT", "Graham's Number", "Operating Earnings Yield %"], group = GRP_VALUE, tooltip = "Select metric for valuation row 3")
value4 = input.string("None", "Row 4", options = ["None", "Market Capitalization", "Free Float Shares", "Total Common Shares Outstanding", "Enterprise Value", "Price Earnings Ratio Forward", "Price To Earnings", "Price To Book Value", "Price Sales Ratio Forward", "Price To Sales", "PEG Ratio", "Enterprise Value to EBITDA", "Enterprise Value to Revenue", "Enterprise Value to EBIT", "Graham's Number", "Operating Earnings Yield %"], group = GRP_VALUE, tooltip = "Select metric for valuation row 4")

cf1 = input.string("Cash From Operating Activities", "Row 1", options = ["None", "Cash From Operating Activities", "Free Cash Flow", "Free Cash Flow Margin %", "Capital Expenditures", "Cash From Investing Activities", "Cash From Financing Activities", "Common Dividends Paid"], group = GRP_CF, tooltip = "Select metric for cash flow row 1")
cf2 = input.string("Free Cash Flow", "Row 2", options = ["None", "Cash From Operating Activities", "Free Cash Flow", "Free Cash Flow Margin %", "Capital Expenditures", "Cash From Investing Activities", "Cash From Financing Activities", "Common Dividends Paid"], group = GRP_CF, tooltip = "Select metric for cash flow row 2")
cf3 = input.string("None", "Row 3", options = ["None", "Cash From Operating Activities", "Free Cash Flow", "Free Cash Flow Margin %", "Capital Expenditures", "Cash From Investing Activities", "Cash From Financing Activities", "Common Dividends Paid"], group = GRP_CF, tooltip = "Select metric for cash flow row 3")

strength1 = input.string("Debt to Equity Ratio", "Row 1", options = ["None", "Debt to Equity Ratio", "Debt to Assets Ratio", "Debt to Revenue Ratio", "Debt to EBITDA Ratio", "Total Debt", "Net Debt", "Long Term Debt", "Total Assets", "Total Liabilities", "Shareholders' Equity", "Cash to Debt Ratio", "Interest Coverage"], group = GRP_STRENGTH, tooltip = "Select metric for financial strength row 1")
strength2 = input.string("None", "Row 2", options = ["None", "Debt to Equity Ratio", "Debt to Assets Ratio", "Debt to Revenue Ratio", "Debt to EBITDA Ratio", "Total Debt", "Net Debt", "Long Term Debt", "Total Assets", "Total Liabilities", "Shareholders' Equity", "Cash to Debt Ratio", "Interest Coverage"], group = GRP_STRENGTH, tooltip = "Select metric for financial strength row 2")
strength3 = input.string("None", "Row 3", options = ["None", "Debt to Equity Ratio", "Debt to Assets Ratio", "Debt to Revenue Ratio", "Debt to EBITDA Ratio", "Total Debt", "Net Debt", "Long Term Debt", "Total Assets", "Total Liabilities", "Shareholders' Equity", "Cash to Debt Ratio", "Interest Coverage"], group = GRP_STRENGTH, tooltip = "Select metric for financial strength row 3")

liq1 = input.string("Current Ratio", "Row 1", options = ["None", "Current Ratio", "Quick Ratio", "Cash Conversion Cycle", "Days Sales Outstanding", "Days Inventory", "Days Payable"], group = GRP_LIQ, tooltip = "Select metric for liquidity row 1")
liq2 = input.string("None", "Row 2", options = ["None", "Current Ratio", "Quick Ratio", "Cash Conversion Cycle", "Days Sales Outstanding", "Days Inventory", "Days Payable"], group = GRP_LIQ, tooltip = "Select metric for liquidity row 2")

div1 = input.string("Dividend Yield %", "Row 1", options = ["None", "Dividend Yield %", "Dividends Per Share", "Dividend Payout Ratio %", "Buyback Yield %", "Common Dividends Paid"], group = GRP_DIV, tooltip = "Select metric for dividend quality row 1")
div2 = input.string("Dividend Payout Ratio %", "Row 2", options = ["None", "Dividend Yield %", "Dividends Per Share", "Dividend Payout Ratio %", "Buyback Yield %", "Common Dividends Paid"], group = GRP_DIV, tooltip = "Select metric for dividend quality row 2")

tablePos = input.string("Top Right", "Table Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Center", "Middle Center", "Bottom Center", "Top Left", "Middle Left", "Bottom Left"], group = GRP_VIS, tooltip = "Choose the position of the dashboard on the chart")
txtSizeInput = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_VIS, tooltip = "Choose the text size for the dashboard")
tableTheme = input.string("Light", "Table Theme", options = ["Dark", "Light"], group = GRP_VIS, tooltip = "Choose the color theme (Dark or Light)")
compactNumbers = input.bool(true, "Compact Number Format", group = GRP_VIS, tooltip = "Display large numbers in compact format (e.g., 1.5M instead of 1,500,000)")
highlightValues = input.bool(true, "Highlight Better / Weaker Value", group = GRP_VIS, tooltip = "Color-code values to indicate which stock is performing better")
showProgress = input.bool(true, "Show Score Progress Bars", group = GRP_VIS, tooltip = "Display visual progress bars for the comparison scores")

//────────────────────────────────────────────────────────────────────
// COLORS
//────────────────────────────────────────────────────────────────────
bool isDarkTheme = tableTheme == "Dark"

color colTitle    = isDarkTheme ? color.rgb(20, 24, 31)    : color.rgb(245, 245, 245)
color colHeader   = isDarkTheme ? color.rgb(28, 34, 44)    : color.rgb(235, 235, 235)
color colCategory = isDarkTheme ? color.rgb(34, 41, 52)    : color.rgb(235, 235, 235)
color colMetric   = isDarkTheme ? color.rgb(24, 29, 38)    : color.rgb(245, 245, 245)
color colNeutral  = isDarkTheme ? color.rgb(24, 29, 38)    : color.rgb(235, 235, 235)
color colBorder   = isDarkTheme ? color.rgb(70, 78, 92)    : color.rgb(185, 185, 185)

color txtMain     = isDarkTheme ? color.rgb(235, 238, 245) : color.rgb(20, 20, 20)
color txtLight    = color.white

color colBetter   = isDarkTheme ? color.rgb(255, 204, 77)  : color.rgb(156, 131, 25)
color colWeaker   = isDarkTheme ? color.rgb(170, 145, 255) : color.rgb(103, 83, 172)
color colTie      = isDarkTheme ? color.rgb(116, 210, 145) : color.rgb(82, 126, 66)

color scoreGold   = isDarkTheme ? color.rgb(255, 204, 77)  : color.rgb(156, 131, 25)
color scoreGreen  = isDarkTheme ? color.rgb(116, 210, 145) : color.rgb(82, 126, 66)
color scoreTeal   = isDarkTheme ? color.rgb(80, 210, 190)  : color.rgb(57, 128, 112)
color scoreBlue   = isDarkTheme ? color.rgb(120, 170, 255) : color.rgb(55, 86, 130)
color scorePurple = isDarkTheme ? color.rgb(170, 145, 255) : color.rgb(103, 83, 172)

//────────────────────────────────────────────────────────────────────
// TABLE POSITION / SIZE
//────────────────────────────────────────────────────────────────────
f_pos(string p) =>
    switch p
        "Top Right"      => position.top_right
        "Middle Right"   => position.middle_right
        "Bottom Right"   => position.bottom_right
        "Top Center"     => position.top_center
        "Middle Center"  => position.middle_center
        "Bottom Center"  => position.bottom_center
        "Top Left"       => position.top_left
        "Middle Left"    => position.middle_left
        "Bottom Left"    => position.bottom_left
        => position.top_right

f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

txtSize = f_size(txtSizeInput)

const int MAX_ROWS = 80

var table dash = table.new(
     f_pos(tablePos),
     4,
     MAX_ROWS,
     frame_width = 1,
     frame_color = colBorder,
     border_width = 1,
     border_color = colBorder
)

//────────────────────────────────────────────────────────────────────
// HELPERS
//────────────────────────────────────────────────────────────────────
f_symbolName(string s) =>
    string[] parts = str.split(s, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : s

f_periodCode() =>
    periodMode == "Year" ? "FY" : "FQ"

f_finId(string metric) =>
    switch metric
        "Market Capitalization"             => "MARKET_CAPITALIZATION"
        "Free Float Shares"                 => "FLOAT_SHARES_OUTSTANDING"
        "Total Common Shares Outstanding"   => "TOTAL_SHARES_OUTSTANDING"
        "Enterprise Value"                  => "ENTERPRISE_VALUE"

        "Revenue One Year Growth"           => "REVENUE_ONE_YEAR_GROWTH"
        "EPS Diluted One Year Growth"       => "EARNINGS_PER_SHARE_DILUTED_ONE_YEAR_GROWTH"
        "EPS Basic One Year Growth"         => "EARNINGS_PER_SHARE_BASIC_ONE_YEAR_GROWTH"
        "Sustainable Growth Rate"           => "SUSTAINABLE_GROWTH_RATE"
        "Shares Buyback Ratio %"            => "SHARE_BUYBACK_RATIO"
        "Revenue Estimates"                 => "SALES_ESTIMATES"
        "EPS Estimates"                     => "EARNINGS_ESTIMATE"

        "Total Revenue"                     => "TOTAL_REVENUE"
        "Cost of Goods Sold"                => "COST_OF_GOODS"
        "Gross Profit"                      => "GROSS_PROFIT"
        "Operating Income"                  => "OPER_INCOME"
        "Net Income"                        => "NET_INCOME"
        "EBIT"                              => "EBIT"
        "EBITDA"                            => "EBITDA"
        "Total Operating Expenses"          => "TOTAL_OPER_EXPENSE"
        "Research & Development"            => "RESEARCH_AND_DEV"

        "Gross Margin %"                    => "GROSS_MARGIN"
        "Operating Margin %"                => "OPERATING_MARGIN"
        "Net Margin %"                      => "NET_MARGIN"
        "EBITDA Margin %"                   => "EBITDA_MARGIN"
        "Return on Equity %"                => "RETURN_ON_EQUITY"
        "Return on Assets %"                => "RETURN_ON_ASSETS"
        "Return on Invested Capital %"      => "RETURN_ON_INVESTED_CAPITAL"
        "Quality Ratio"                     => "QUALITY_RATIO"

        "Dividend Yield %"                  => "DIVIDENDS_YIELD"
        "Dividends Per Share"               => "DPS_COMMON_STOCK_PRIM_ISSUE"
        "Dividend Payout Ratio %"           => "DIVIDEND_PAYOUT_RATIO"
        "Buyback Yield %"                   => "BUYBACK_YIELD"

        "Price Earnings Ratio Forward"      => "PRICE_EARNINGS_FORWARD"
        "Price To Earnings"                 => "PRICE_EARNINGS_FORWARD"
        "Price Sales Ratio Forward"         => "PRICE_SALES_FORWARD"
        "Price To Sales"                    => "PRICE_SALES_FORWARD"
        "Price To Book Value"               => "PRICE_BOOK_RATIO"
        "PEG Ratio"                         => "PEG_RATIO"
        "Enterprise Value to EBITDA"        => "ENTERPRISE_VALUE_EBITDA"
        "Enterprise Value to EBITDA Ratio"  => "ENTERPRISE_VALUE_EBITDA"
        "Enterprise Value to Revenue"       => "EV_REVENUE"
        "Enterprise Value to EBIT"          => "EV_EBIT"
        "Graham's Number"                   => "GRAHAM_NUMBERS"
        "Operating Earnings Yield %"        => "OPERATING_EARNINGS_YIELD"

        "Cash From Operating Activities"    => "CASH_F_OPERATING_ACTIVITIES"
        "Free Cash Flow"                    => "FREE_CASH_FLOW"
        "Free Cash Flow Margin %"           => "FREE_CASH_FLOW_MARGIN"
        "Capital Expenditures"              => "CAPITAL_EXPENDITURES"
        "Cash From Investing Activities"    => "CASH_F_INVESTING_ACTIVITIES"
        "Cash From Financing Activities"    => "CASH_F_FINANCING_ACTIVITIES"
        "Common Dividends Paid"             => "COMMON_DIVIDENDS_CASH_FLOW"

        "Debt to Equity Ratio"              => "DEBT_TO_EQUITY"
        "Debt to Assets Ratio"              => "DEBT_TO_ASSET"
        "Debt to Revenue Ratio"             => "DEBT_TO_REVENUE"
        "Debt to EBITDA Ratio"              => "DEBT_TO_EBITDA"
        "Total Debt"                        => "TOTAL_DEBT"
        "Net Debt"                          => "NET_DEBT"
        "Long Term Debt"                    => "LONG_TERM_DEBT"
        "Total Assets"                      => "TOTAL_ASSETS"
        "Total Liabilities"                 => "TOTAL_LIABILITIES"
        "Shareholders' Equity"              => "SHRHLDRS_EQUITY"
        "Cash to Debt Ratio"                => "CASH_TO_DEBT"
        "Interest Coverage"                 => "INTERST_COVER"

        "Current Ratio"                     => "CURRENT_RATIO"
        "Quick Ratio"                       => "QUICK_RATIO"
        "Cash Conversion Cycle"             => "CASH_CONVERSION_CYCLE"
        "Days Sales Outstanding"            => "DAY_SALES_OUT"
        "Days Inventory"                    => "DAYS_INVENT"
        "Days Payable"                      => "DAYS_PAY"
        => ""

f_isPercent(string metric) =>
    str.contains(metric, "%") or
     str.contains(metric, "Growth") or
     metric == "Sustainable Growth Rate" or
     str.contains(metric, "Yield") or
     str.contains(metric, "Distance From 52 Week")

f_lowerBetter(string metric) =>
    metric == "Cost of Goods Sold" or
     metric == "Total Operating Expenses" or
     metric == "Price To Earnings" or
     metric == "Price Earnings Ratio Forward" or
     metric == "Price To Book Value" or
     metric == "Price To Sales" or
     metric == "Price Sales Ratio Forward" or
     metric == "Enterprise Value to EBITDA" or
     metric == "Enterprise Value to EBITDA Ratio" or
     metric == "Enterprise Value to Revenue" or
     metric == "Enterprise Value to EBIT" or
     metric == "PEG Ratio" or
     metric == "Debt to Equity Ratio" or
     metric == "Debt to Assets Ratio" or
     metric == "Debt to Revenue Ratio" or
     metric == "Debt to EBITDA Ratio" or
     metric == "Total Debt" or
     metric == "Net Debt" or
     metric == "Long Term Debt" or
     metric == "Total Liabilities" or
     metric == "Capital Expenditures" or
     metric == "Cash Conversion Cycle" or
     metric == "Days Sales Outstanding" or
     metric == "Days Inventory"

f_valid(string metric, float v1, float v2) =>
    metric != "None" and not na(v1) and not na(v2)

f_fin(string symbolInput, string metric) =>
    string id = f_finId(metric)
    metric == "None" or id == "" ? na : request.financial(
         symbolInput,
         id,
         f_periodCode(),
         ignore_invalid_symbol = true
    )

f_snapshot(string symbolInput) =>
    request.security(
         symbolInput,
         "D",
         [
             close,
             volume,
             ta.highest(high, 300),
             ta.lowest(low, 300),
             close[63],
             close[126],
             close[252],
             ta.sma(close, 200)
         ],
         ignore_invalid_symbol = true
    )

f_compact(float v) =>
    if na(v)
        "—"
    else
        float av = math.abs(v)
        string sign = v < 0 ? "-" : ""
        av >= 1000000000000 ? sign + str.tostring(av / 1000000000000, "#.##") + "T" :
         av >= 1000000000 ? sign + str.tostring(av / 1000000000, "#.##") + "B" :
         av >= 1000000 ? sign + str.tostring(av / 1000000, "#.##") + "M" :
         av >= 1000 ? sign + str.tostring(av / 1000, "#.##") + "K" :
         str.tostring(v, "#.##")

f_format(string metric, float v) =>
    if na(v)
        "—"
    else if f_isPercent(metric)
        str.tostring(v, format.percent)
    else
        compactNumbers ? f_compact(v) : str.tostring(v, "#.##")

f_snapValue(string metric, float c, float v, float hi52, float lo52, float mcap) =>
    switch metric
        "Close" => c
        "Volume" => v
        "Market Capitalization" => mcap
        "Distance From 52 Week High" => hi52 != 0 and not na(hi52) ? (c / hi52) - 1.0 : na
        "Distance From 52 Week Low" => lo52 != 0 and not na(lo52) ? (c / lo52) - 1.0 : na
        => na

f_score1(string metric, float v1, float v2) =>
    if not f_valid(metric, v1, v2)
        0.0
    else
        bool lowBetter = f_lowerBetter(metric)

        if v1 == v2
            0.5
        else if lowBetter
            float a = math.abs(v1)
            float b = math.abs(v2)
            a + b == 0 ? 0.5 : b / (a + b)
        else
            float a = math.max(v1, 0)
            float b = math.max(v2, 0)
            a + b == 0 ? 0.5 : a / (a + b)

f_score2(string metric, float v1, float v2) =>
    if not f_valid(metric, v1, v2)
        0.0
    else
        bool lowBetter = f_lowerBetter(metric)

        if v1 == v2
            0.5
        else if lowBetter
            float a = math.abs(v1)
            float b = math.abs(v2)
            a + b == 0 ? 0.5 : a / (a + b)
        else
            float a = math.max(v1, 0)
            float b = math.max(v2, 0)
            a + b == 0 ? 0.5 : b / (a + b)

f_valueBg(string metric, float v1, float v2, bool firstSymbol) =>
    colNeutral

f_valueTxt(string metric, float v1, float v2, bool firstSymbol) =>
    if not highlightValues or not f_valid(metric, v1, v2)
        txtMain
    else
        float s = firstSymbol ? f_score1(metric, v1, v2) : f_score2(metric, v1, v2)
        s > 0.5 ? colBetter : s < 0.5 ? colWeaker : colTie

f_repeat(string ch, int n) =>
    string out = ""
    if n > 0
        for i = 1 to n
            out += ch
    out

f_scoreText(int score) =>
    int filled = int(math.round(score / 10.0))
    filled := math.max(0, math.min(10, filled))
    showProgress ? f_repeat("■", filled) + f_repeat("□", 10 - filled) + "  " + str.tostring(score) + "/100" : str.tostring(score) + "/100"

f_row(int r, string cat, string metric, float v1, float v2) =>
    color bg1 = f_valueBg(metric, v1, v2, true)
    color bg2 = f_valueBg(metric, v1, v2, false)

    table.cell(dash, 0, r, cat, text_color = txtMain, bgcolor = colCategory, text_size = txtSize, text_halign = text.align_left)
    table.cell(dash, 1, r, metric, text_color = txtMain, bgcolor = colMetric, text_size = txtSize, text_halign = text.align_left)
    table.cell(dash, 2, r, f_format(metric, v1), text_color = f_valueTxt(metric, v1, v2, true), bgcolor = bg1, text_size = txtSize, text_halign = text.align_center)
    table.cell(dash, 3, r, f_format(metric, v2), text_color = f_valueTxt(metric, v1, v2, false), bgcolor = bg2, text_size = txtSize, text_halign = text.align_center)

f_scoreRow(int r, string cat, string label, int score1, int score2, color scoreCol) =>
    table.cell(dash, 0, r, cat, text_color = txtMain, bgcolor = colCategory, text_size = txtSize, text_halign = text.align_left)
    table.cell(dash, 1, r, label, text_color = txtMain, bgcolor = colMetric, text_size = txtSize, text_halign = text.align_left)
    table.cell(dash, 2, r, f_scoreText(score1), text_color = scoreCol, bgcolor = colMetric, text_size = txtSize, text_halign = text.align_center)
    table.cell(dash, 3, r, f_scoreText(score2), text_color = scoreCol, bgcolor = colMetric, text_size = txtSize, text_halign = text.align_center)

// Relative strength helpers
f_perf(float nowVal, float pastVal) =>
    not na(nowVal) and not na(pastVal) and pastVal != 0 ? nowVal / pastVal - 1.0 : na

f_pos52(float c, float hi, float lo) =>
    not na(c) and not na(hi) and not na(lo) and hi != lo ? (c - lo) / (hi - lo) : na

// For return-based metrics like 3M, 6M, 12M, MA distance.
// Uses 1 + return, so small differences do not become 0/100.
f_pairScoreReturn(float a, float b) =>
    if na(a) or na(b)
        0.5
    else
        float aa = math.max(1.0 + a, 0.01)
        float bb = math.max(1.0 + b, 0.01)
        aa + bb == 0 ? 0.5 : aa / (aa + bb)

// For bounded position metrics like 52-week position.
f_pairScoreLevel(float a, float b) =>
    if na(a) or na(b)
        0.5
    else
        float aa = math.max(a, 0.0)
        float bb = math.max(b, 0.0)
        aa + bb == 0 ? 0.5 : aa / (aa + bb)

//────────────────────────────────────────────────────────────────────
// REQUEST LIMIT CONTROL
//────────────────────────────────────────────────────────────────────
const int MAX_FIN_ROWS = 19

bool needMcap =
     snap1 == "Market Capitalization" or
     snap2 == "Market Capitalization" or
     snap3 == "Market Capitalization" or
     snap4 == "Market Capitalization" or
     snap5 == "Market Capitalization"

int selectedFinRows = 0
selectedFinRows += needMcap ? 1 : 0
selectedFinRows += growth1 != "None" ? 1 : 0
selectedFinRows += growth2 != "None" ? 1 : 0
selectedFinRows += income1 != "None" ? 1 : 0
selectedFinRows += income2 != "None" ? 1 : 0
selectedFinRows += income3 != "None" ? 1 : 0
selectedFinRows += profit1 != "None" ? 1 : 0
selectedFinRows += profit2 != "None" ? 1 : 0
selectedFinRows += profit3 != "None" ? 1 : 0
selectedFinRows += value1 != "None" ? 1 : 0
selectedFinRows += value2 != "None" ? 1 : 0
selectedFinRows += value3 != "None" ? 1 : 0
selectedFinRows += value4 != "None" ? 1 : 0
selectedFinRows += cf1 != "None" ? 1 : 0
selectedFinRows += cf2 != "None" ? 1 : 0
selectedFinRows += cf3 != "None" ? 1 : 0
selectedFinRows += strength1 != "None" ? 1 : 0
selectedFinRows += strength2 != "None" ? 1 : 0
selectedFinRows += strength3 != "None" ? 1 : 0
selectedFinRows += liq1 != "None" ? 1 : 0
selectedFinRows += liq2 != "None" ? 1 : 0
selectedFinRows += div1 != "None" ? 1 : 0
selectedFinRows += div2 != "None" ? 1 : 0

bool tooManyRows = selectedFinRows > MAX_FIN_ROWS
bool useMcap = needMcap

string liq1Eff      = liq1
string liq2Eff      = tooManyRows ? "None" : liq2
string strength2Eff = tooManyRows ? "None" : strength2
string strength3Eff = tooManyRows ? "None" : strength3
string cf3Eff       = tooManyRows and liq1 != "None" ? "None" : cf3

//────────────────────────────────────────────────────────────────────
// DATA
//────────────────────────────────────────────────────────────────────
[c1, v1, hi1, lo1, c63_1, c126_1, c252_1, sma200_1] = f_snapshot(sym1)
[c2, v2, hi2, lo2, c63_2, c126_2, c252_2, sma200_2] = f_snapshot(sym2)

mcap1 = useMcap ? f_fin(sym1, "Market Capitalization") : na
mcap2 = useMcap ? f_fin(sym2, "Market Capitalization") : na

snap1v1 = f_snapValue(snap1, c1, v1, hi1, lo1, mcap1)
snap1v2 = f_snapValue(snap1, c2, v2, hi2, lo2, mcap2)
snap2v1 = f_snapValue(snap2, c1, v1, hi1, lo1, mcap1)
snap2v2 = f_snapValue(snap2, c2, v2, hi2, lo2, mcap2)
snap3v1 = f_snapValue(snap3, c1, v1, hi1, lo1, mcap1)
snap3v2 = f_snapValue(snap3, c2, v2, hi2, lo2, mcap2)
snap4v1 = f_snapValue(snap4, c1, v1, hi1, lo1, mcap1)
snap4v2 = f_snapValue(snap4, c2, v2, hi2, lo2, mcap2)
snap5v1 = f_snapValue(snap5, c1, v1, hi1, lo1, mcap1)
snap5v2 = f_snapValue(snap5, c2, v2, hi2, lo2, mcap2)

growth1v1 = f_fin(sym1, growth1)
growth1v2 = f_fin(sym2, growth1)
growth2v1 = f_fin(sym1, growth2)
growth2v2 = f_fin(sym2, growth2)

income1v1 = f_fin(sym1, income1)
income1v2 = f_fin(sym2, income1)
income2v1 = f_fin(sym1, income2)
income2v2 = f_fin(sym2, income2)
income3v1 = f_fin(sym1, income3)
income3v2 = f_fin(sym2, income3)

profit1v1 = f_fin(sym1, profit1)
profit1v2 = f_fin(sym2, profit1)
profit2v1 = f_fin(sym1, profit2)
profit2v2 = f_fin(sym2, profit2)
profit3v1 = f_fin(sym1, profit3)
profit3v2 = f_fin(sym2, profit3)

value1v1 = f_fin(sym1, value1)
value1v2 = f_fin(sym2, value1)
value2v1 = f_fin(sym1, value2)
value2v2 = f_fin(sym2, value2)
value3v1 = f_fin(sym1, value3)
value3v2 = f_fin(sym2, value3)
value4v1 = f_fin(sym1, value4)
value4v2 = f_fin(sym2, value4)

cf1v1 = f_fin(sym1, cf1)
cf1v2 = f_fin(sym2, cf1)
cf2v1 = f_fin(sym1, cf2)
cf2v2 = f_fin(sym2, cf2)
cf3v1 = f_fin(sym1, cf3Eff)
cf3v2 = f_fin(sym2, cf3Eff)

strength1v1 = f_fin(sym1, strength1)
strength1v2 = f_fin(sym2, strength1)
strength2v1 = f_fin(sym1, strength2Eff)
strength2v2 = f_fin(sym2, strength2Eff)
strength3v1 = f_fin(sym1, strength3Eff)
strength3v2 = f_fin(sym2, strength3Eff)

liq1v1 = f_fin(sym1, liq1Eff)
liq1v2 = f_fin(sym2, liq1Eff)
liq2v1 = f_fin(sym1, liq2Eff)
liq2v2 = f_fin(sym2, liq2Eff)

div1v1 = f_fin(sym1, div1)
div1v2 = f_fin(sym2, div1)
div2v1 = f_fin(sym1, div2)
div2v2 = f_fin(sym2, div2)

//────────────────────────────────────────────────────────────────────
// RELATIVE STRENGTH SCORE
//────────────────────────────────────────────────────────────────────
perf3m1  = f_perf(c1, c63_1)
perf3m2  = f_perf(c2, c63_2)

perf6m1  = f_perf(c1, c126_1)
perf6m2  = f_perf(c2, c126_2)

perf12m1 = f_perf(c1, c252_1)
perf12m2 = f_perf(c2, c252_2)

pos52_1 = f_pos52(c1, hi1, lo1)
pos52_2 = f_pos52(c2, hi2, lo2)

maDist1 = not na(sma200_1) and sma200_1 != 0 ? c1 / sma200_1 - 1.0 : na
maDist2 = not na(sma200_2) and sma200_2 != 0 ? c2 / sma200_2 - 1.0 : na

rsRaw1 =
     f_pairScoreReturn(perf3m1,  perf3m2)  * 0.30 +
     f_pairScoreReturn(perf6m1,  perf6m2)  * 0.30 +
     f_pairScoreReturn(perf12m1, perf12m2) * 0.25 +
     f_pairScoreLevel(pos52_1,   pos52_2)  * 0.10 +
     f_pairScoreReturn(maDist1,  maDist2)  * 0.05

rsScore1 = int(math.round(rsRaw1 * 100.0))
rsScore2 = 100 - rsScore1

//────────────────────────────────────────────────────────────────────
// RENDER TABLE
//────────────────────────────────────────────────────────────────────
if barstate.islast
    table.clear(dash, 0, 0, 3, MAX_ROWS - 1)
    
    // Merge the top title cell properly
    table.merge_cells(dash, 0, 0, 3, 0)

    table.cell(
         dash,
         0,
         0,
         "Stock Comparison Dashboard  :  " + periodMode,
         text_color = txtMain,
         bgcolor = colTitle,
         text_size = txtSize,
         text_halign = text.align_center,
         text_valign = text.align_center
    )

    table.cell(dash, 0, 1, "Category", text_color = txtMain, bgcolor = colHeader, text_size = txtSize, text_halign = text.align_left)
    table.cell(dash, 1, 1, "Metric", text_color = txtMain, bgcolor = colHeader, text_size = txtSize, text_halign = text.align_left)
    table.cell(dash, 2, 1, f_symbolName(sym1), text_color = txtMain, bgcolor = colHeader, text_size = txtSize, text_halign = text.align_center)
    table.cell(dash, 3, 1, f_symbolName(sym2), text_color = txtMain, bgcolor = colHeader, text_size = txtSize, text_halign = text.align_center)

    int row = 2

    // Snapshot
    bool firstSnap = true
    if snap1 != "None"
        f_row(row, firstSnap ? "Snapshot" : "", snap1, snap1v1, snap1v2)
        row += 1
        firstSnap := false
    if snap2 != "None"
        f_row(row, firstSnap ? "Snapshot" : "", snap2, snap2v1, snap2v2)
        row += 1
        firstSnap := false
    if snap3 != "None"
        f_row(row, firstSnap ? "Snapshot" : "", snap3, snap3v1, snap3v2)
        row += 1
        firstSnap := false
    if snap4 != "None"
        f_row(row, firstSnap ? "Snapshot" : "", snap4, snap4v1, snap4v2)
        row += 1
        firstSnap := false
    if snap5 != "None"
        f_row(row, firstSnap ? "Snapshot" : "", snap5, snap5v1, snap5v2)
        row += 1
        firstSnap := false

    // Score variables
    float growthS1 = 0.0
    float growthS2 = 0.0
    int growthN = 0

    float incomeS1 = 0.0
    float incomeS2 = 0.0
    int incomeN = 0

    float profitS1 = 0.0
    float profitS2 = 0.0
    int profitN = 0

    float valueS1 = 0.0
    float valueS2 = 0.0
    int valueN = 0

    float cfS1 = 0.0
    float cfS2 = 0.0
    int cfN = 0

    float strengthS1 = 0.0
    float strengthS2 = 0.0
    int strengthN = 0

    float liqS1 = 0.0
    float liqS2 = 0.0
    int liqN = 0

    float divS1 = 0.0
    float divS2 = 0.0
    int divN = 0

    // Growth
    bool firstGrowth = true
    if growth1 != "None"
        f_row(row, firstGrowth ? "Growth" : "", growth1, growth1v1, growth1v2)
        if f_valid(growth1, growth1v1, growth1v2)
            growthS1 += f_score1(growth1, growth1v1, growth1v2)
            growthS2 += f_score2(growth1, growth1v1, growth1v2)
            growthN += 1
        row += 1
        firstGrowth := false
    if growth2 != "None"
        f_row(row, firstGrowth ? "Growth" : "", growth2, growth2v1, growth2v2)
        if f_valid(growth2, growth2v1, growth2v2)
            growthS1 += f_score1(growth2, growth2v1, growth2v2)
            growthS2 += f_score2(growth2, growth2v1, growth2v2)
            growthN += 1
        row += 1
        firstGrowth := false

    // Income
    bool firstIncome = true
    if income1 != "None"
        f_row(row, firstIncome ? "Income Statement" : "", income1, income1v1, income1v2)
        if f_valid(income1, income1v1, income1v2)
            incomeS1 += f_score1(income1, income1v1, income1v2)
            incomeS2 += f_score2(income1, income1v1, income1v2)
            incomeN += 1
        row += 1
        firstIncome := false
    if income2 != "None"
        f_row(row, firstIncome ? "Income Statement" : "", income2, income2v1, income2v2)
        if f_valid(income2, income2v1, income2v2)
            incomeS1 += f_score1(income2, income2v1, income2v2)
            incomeS2 += f_score2(income2, income2v1, income2v2)
            incomeN += 1
        row += 1
        firstIncome := false
    if income3 != "None"
        f_row(row, firstIncome ? "Income Statement" : "", income3, income3v1, income3v2)
        if f_valid(income3, income3v1, income3v2)
            incomeS1 += f_score1(income3, income3v1, income3v2)
            incomeS2 += f_score2(income3, income3v1, income3v2)
            incomeN += 1
        row += 1
        firstIncome := false

    // Profitability
    bool firstProfit = true
    if profit1 != "None"
        f_row(row, firstProfit ? "Profitability" : "", profit1, profit1v1, profit1v2)
        if f_valid(profit1, profit1v1, profit1v2)
            profitS1 += f_score1(profit1, profit1v1, profit1v2)
            profitS2 += f_score2(profit1, profit1v1, profit1v2)
            profitN += 1
        row += 1
        firstProfit := false
    if profit2 != "None"
        f_row(row, firstProfit ? "Profitability" : "", profit2, profit2v1, profit2v2)
        if f_valid(profit2, profit2v1, profit2v2)
            profitS1 += f_score1(profit2, profit2v1, profit2v2)
            profitS2 += f_score2(profit2, profit2v1, profit2v2)
            profitN += 1
        row += 1
        firstProfit := false
    if profit3 != "None"
        f_row(row, firstProfit ? "Profitability" : "", profit3, profit3v1, profit3v2)
        if f_valid(profit3, profit3v1, profit3v2)
            profitS1 += f_score1(profit3, profit3v1, profit3v2)
            profitS2 += f_score2(profit3, profit3v1, profit3v2)
            profitN += 1
        row += 1
        firstProfit := false

    // Valuation
    bool firstValue = true
    if value1 != "None"
        f_row(row, firstValue ? "Valuation" : "", value1, value1v1, value1v2)
        if f_valid(value1, value1v1, value1v2)
            valueS1 += f_score1(value1, value1v1, value1v2)
            valueS2 += f_score2(value1, value1v1, value1v2)
            valueN += 1
        row += 1
        firstValue := false
    if value2 != "None"
        f_row(row, firstValue ? "Valuation" : "", value2, value2v1, value2v2)
        if f_valid(value2, value2v1, value2v2)
            valueS1 += f_score1(value2, value2v1, value2v2)
            valueS2 += f_score2(value2, value2v1, value2v2)
            valueN += 1
        row += 1
        firstValue := false
    if value3 != "None"
        f_row(row, firstValue ? "Valuation" : "", value3, value3v1, value3v2)
        if f_valid(value3, value3v1, value3v2)
            valueS1 += f_score1(value3, value3v1, value3v2)
            valueS2 += f_score2(value3, value3v1, value3v2)
            valueN += 1
        row += 1
        firstValue := false
    if value4 != "None"
        f_row(row, firstValue ? "Valuation" : "", value4, value4v1, value4v2)
        if f_valid(value4, value4v1, value4v2)
            valueS1 += f_score1(value4, value4v1, value4v2)
            valueS2 += f_score2(value4, value4v1, value4v2)
            valueN += 1
        row += 1
        firstValue := false

    // Cash Flow
    bool firstCF = true
    if cf1 != "None"
        f_row(row, firstCF ? "Cash Flow Quality" : "", cf1, cf1v1, cf1v2)
        if f_valid(cf1, cf1v1, cf1v2)
            cfS1 += f_score1(cf1, cf1v1, cf1v2)
            cfS2 += f_score2(cf1, cf1v1, cf1v2)
            cfN += 1
        row += 1
        firstCF := false
    if cf2 != "None"
        f_row(row, firstCF ? "Cash Flow Quality" : "", cf2, cf2v1, cf2v2)
        if f_valid(cf2, cf2v1, cf2v2)
            cfS1 += f_score1(cf2, cf2v1, cf2v2)
            cfS2 += f_score2(cf2, cf2v1, cf2v2)
            cfN += 1
        row += 1
        firstCF := false
    if cf3Eff != "None"
        f_row(row, firstCF ? "Cash Flow Quality" : "", cf3Eff, cf3v1, cf3v2)
        if f_valid(cf3Eff, cf3v1, cf3v2)
            cfS1 += f_score1(cf3Eff, cf3v1, cf3v2)
            cfS2 += f_score2(cf3Eff, cf3v1, cf3v2)
            cfN += 1
        row += 1
        firstCF := false

    // Financial Strength
    bool firstStrength = true
    if strength1 != "None"
        f_row(row, firstStrength ? "Financial Strength" : "", strength1, strength1v1, strength1v2)
        if f_valid(strength1, strength1v1, strength1v2)
            strengthS1 += f_score1(strength1, strength1v1, strength1v2)
            strengthS2 += f_score2(strength1, strength1v1, strength1v2)
            strengthN += 1
        row += 1
        firstStrength := false
    if strength2Eff != "None"
        f_row(row, firstStrength ? "Financial Strength" : "", strength2Eff, strength2v1, strength2v2)
        if f_valid(strength2Eff, strength2v1, strength2v2)
            strengthS1 += f_score1(strength2Eff, strength2v1, strength2v2)
            strengthS2 += f_score2(strength2Eff, strength2v1, strength2v2)
            strengthN += 1
        row += 1
        firstStrength := false
    if strength3Eff != "None"
        f_row(row, firstStrength ? "Financial Strength" : "", strength3Eff, strength3v1, strength3v2)
        if f_valid(strength3Eff, strength3v1, strength3v2)
            strengthS1 += f_score1(strength3Eff, strength3v1, strength3v2)
            strengthS2 += f_score2(strength3Eff, strength3v1, strength3v2)
            strengthN += 1
        row += 1
        firstStrength := false

    // Liquidity
    bool firstLiq = true
    if liq1Eff != "None"
        f_row(row, firstLiq ? "Liquidity" : "", liq1Eff, liq1v1, liq1v2)
        if f_valid(liq1Eff, liq1v1, liq1v2)
            liqS1 += f_score1(liq1Eff, liq1v1, liq1v2)
            liqS2 += f_score2(liq1Eff, liq1v1, liq1v2)
            liqN += 1
        row += 1
        firstLiq := false
    if liq2Eff != "None"
        f_row(row, firstLiq ? "Liquidity" : "", liq2Eff, liq2v1, liq2v2)
        if f_valid(liq2Eff, liq2v1, liq2v2)
            liqS1 += f_score1(liq2Eff, liq2v1, liq2v2)
            liqS2 += f_score2(liq2Eff, liq2v1, liq2v2)
            liqN += 1
        row += 1
        firstLiq := false

    // Dividend
    bool firstDiv = true
    if div1 != "None"
        f_row(row, firstDiv ? "Dividend Quality" : "", div1, div1v1, div1v2)
        if f_valid(div1, div1v1, div1v2)
            divS1 += f_score1(div1, div1v1, div1v2)
            divS2 += f_score2(div1, div1v1, div1v2)
            divN += 1
        row += 1
        firstDiv := false
    if div2 != "None"
        f_row(row, firstDiv ? "Dividend Quality" : "", div2, div2v1, div2v2)
        if f_valid(div2, div2v1, div2v2)
            divS1 += f_score1(div2, div2v1, div2v2)
            divS2 += f_score2(div2, div2v1, div2v2)
            divN += 1
        row += 1
        firstDiv := false

    // Comparison Scores
    bool firstScore = true

    f_scoreRow(row, firstScore ? "Comparison Score" : "", "Relative Strength Score", rsScore1, rsScore2, scorePurple)
    row += 1
    firstScore := false

    if growthN > 0
        int s1 = int(math.round(100.0 * growthS1 / growthN))
        int s2 = int(math.round(100.0 * growthS2 / growthN))
        f_scoreRow(row, firstScore ? "Comparison Score" : "", "Growth Score", s1, s2, scoreGold)
        row += 1
        firstScore := false

    if incomeN > 0
        int s1 = int(math.round(100.0 * incomeS1 / incomeN))
        int s2 = int(math.round(100.0 * incomeS2 / incomeN))
        f_scoreRow(row, firstScore ? "Comparison Score" : "", "Income Score", s1, s2, scoreGold)
        row += 1
        firstScore := false

    if profitN > 0
        int s1 = int(math.round(100.0 * profitS1 / profitN))
        int s2 = int(math.round(100.0 * profitS2 / profitN))
        f_scoreRow(row, firstScore ? "Comparison Score" : "", "Profitability Score", s1, s2, scoreTeal)
        row += 1
        firstScore := false

    if valueN > 0
        int s1 = int(math.round(100.0 * valueS1 / valueN))
        int s2 = int(math.round(100.0 * valueS2 / valueN))
        f_scoreRow(row, firstScore ? "Comparison Score" : "", "Valuation Score", s1, s2, scoreGreen)
        row += 1
        firstScore := false

    if cfN > 0
        int s1 = int(math.round(100.0 * cfS1 / cfN))
        int s2 = int(math.round(100.0 * cfS2 / cfN))
        f_scoreRow(row, firstScore ? "Comparison Score" : "", "Cash Flow Score", s1, s2, scoreGold)
        row += 1
        firstScore := false

    if strengthN > 0
        int s1 = int(math.round(100.0 * strengthS1 / strengthN))
        int s2 = int(math.round(100.0 * strengthS2 / strengthN))
        f_scoreRow(row, firstScore ? "Comparison Score" : "", "Financial Strength Score", s1, s2, scoreGold)
        row += 1
        firstScore := false

    if liqN > 0
        int s1 = int(math.round(100.0 * liqS1 / liqN))
        int s2 = int(math.round(100.0 * liqS2 / liqN))
        f_scoreRow(row, firstScore ? "Comparison Score" : "", "Liquidity Score", s1, s2, scoreBlue)
        row += 1
        firstScore := false

    if divN > 0
        int s1 = int(math.round(100.0 * divS1 / divN))
        int s2 = int(math.round(100.0 * divS2 / divN))
        f_scoreRow(row, firstScore ? "Comparison Score" : "", "Dividend Score", s1, s2, scoreGold)
        row += 1
        firstScore := false

    if tooManyRows and row < MAX_ROWS
        table.cell(dash, 0, row, "Limit", text_color = txtLight, bgcolor = color.rgb(160, 50, 50), text_size = txtSize, text_halign = text.align_left)
        table.cell(dash, 1, row, "Too many financial rows selected", text_color = txtLight, bgcolor = color.rgb(160, 50, 50), text_size = txtSize, text_halign = text.align_left)
        table.cell(dash, 2, row, "Max 19", text_color = txtLight, bgcolor = color.rgb(160, 50, 50), text_size = txtSize, text_halign = text.align_center)
        table.cell(dash, 3, row, "Extra rows disabled", text_color = txtLight, bgcolor = color.rgb(160, 50, 50), text_size = txtSize, text_halign = text.align_center)
````
