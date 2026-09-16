<!-- tradingview-pine-id: PUB;4cb689c71beb474a97b8b9ec1af6d55e -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Fundamental Valuation Snapshot [FVS]

Source: https://www.tradingview.com/script/Zh6g7Niu-Fundamental-Valuation-Snapshot-FVS/

## Description

Fundamental Valuation Snapshot [FVS]

Fundamental Valuation Snapshot [FVS] is a compact fundamental dashboard designed to provide a quick view of a company's profitability, valuation, financial strength, growth, cash generation, and analyst expectations directly on the chart.

The panel includes ROA, ROE, ROIC, Current Ratio, P/E, PEG, P/S, P/B, Debt/Equity, Dividend Yield, Market Capitalization, Cash-Adjusted Price, Revenue, Gross Profit, Net Income, Return on Capital (ROC), Revenue Growth, Net Margin, Free Cash Flow, Debt/EBITDA, Piotroski F-Score, and analyst price targets when the data is available from TradingView.

Valuation Color Profiles

FVS includes four configurable valuation profiles:

[*]* Conservative
[*]* Balanced
[*]* Growth
[*]* Custom

The selected profile changes only the thresholds used for color grading. It does not alter the underlying financial data.

Green indicates that a metric meets the selected profile's preferred threshold. Blue represents a neutral tolerance zone around the threshold. Red indicates that the metric is outside the profile's preferred range. Gray indicates unavailable data.

The Neutral Zone Tolerance setting can be adjusted to make the grading system stricter or more flexible.

Because valuation norms differ significantly between industries and business models, these profiles should be treated as screening guidelines rather than universal definitions of fair value. The Custom profile allows users to define their own thresholds.

Credits

This indicator was originally inspired by and partially adapted from the open-source "Valuation Table" by TradingView author kenhuangsy2.

FVS substantially expands the original concept with additional fundamental metrics, configurable fiscal periods, valuation and quality profiles, tolerance-based color grading, cash-adjusted price calculations, analyst price targets, Piotroski F-Score, additional financial statement data, formatting utilities, configurable panel sizing and positioning, and a Pine Script v6 implementation.

Published open-source under the Mozilla Public License 2.0.

This indicator is intended as a fundamental research and screening tool. Its colors and valuation profiles are contextual aids and should not be interpreted as investment recommendations or automatic buy/sell signals.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// Original inspiration and portions adapted from:
// "Valuation Table" by TradingView author kenhuangsy2.
//
// Extended and substantially modified by nixforge, 2026.
// Major additions include expanded financial metrics, analyst price targets,
// configurable valuation profiles, tolerance-based color grading,
// panel controls, formatting, and Pine Script v6 implementation.
//
// © 2026 nixforge
//
// Version 1.1
//@version=6
indicator(
     title      = "Fundamental Valuation Snapshot [FVS]",
     shorttitle = "FVS",
     overlay    = true,
     calc_bars_count = 100

)
// ============================================================================
// INPUT
// ============================================================================
panelSize = input.string(
     "Small",
     title   = "Panel Size",
     options = ["Normal", "Small", "Tiny"],
     group   = "Panel Settings",
     tooltip = "Adjusts both the text size and the overall size of the Valuation table."
)
// POSITION SETTING
panelPosition = input.string(
     "Top Right",
     title   = "Panel Position",
     options = [
          "Top Right",
          "Bottom Right",
          "Bottom Left"
     ],
     group   = "Panel Settings"
)
string tablePosition =
     panelPosition == "Top Right"    ? position.top_right :
     panelPosition == "Bottom Right" ? position.bottom_right :
                                       position.bottom_left
// Panel/text size preset.
int panelTextSize =
     panelSize == "Normal" ? 14 :
     panelSize == "Small"  ? 11 :
                             10
showPanel = input.bool(
     true,
     title   = "Show Valuation Panel",
     group   = "Panel Settings",
     tooltip = "Shows the core profitability, valuation, debt, market, and income-statement section. Automatically disabled on chart timeframes below 1H to reduce memory usage."
)
showAdditional = input.bool(
     true,
     title   = "Show Additional Metrics",
     group   = "Panel Settings",
     tooltip = "Displays Revenue Growth, Net Margin, FCF, Debt/EBITDA, and the Piotroski F-Score. Automatically disabled on chart timeframes below 1H to reduce memory usage."
)
showPriceTargets = input.bool(
     true,
     title   = "Show Analyst Price Targets",
     group   = "Panel Settings",
     tooltip = "Displays analysts' minimum, average, and maximum price targets. Remains available on all chart timeframes."
)
// ============================================================================
// TIMEFRAME PROTECTION
// ============================================================================
// FVS is a current fundamental snapshot rather than an intraday signal.
// On intraday chart timeframes below 1H, the heavy fundamental sections are
// automatically disabled. Analyst Price Targets remain available.
bool allowFundamentalSections =
     not timeframe.isintraday or timeframe.multiplier >= 60
bool showPanelEffective =
     showPanel and allowFundamentalSections
bool showAdditionalEffective =
     showAdditional and allowFundamentalSections
ratioPeriod = input.string(
     "FQ",
     title   = "Fiscal Period — Financial Ratios",
     options = ["FY", "FQ"],
     group   = "Financial Settings",
     tooltip = "FY = Annual financial reports. FQ = Quarterly financial reports."
)
// ============================================================================
// VALUATION COLOR PROFILE
// ============================================================================
groupProfile = "Valuation Color Profile"
valuationProfile = input.string(
     "Balanced",
     title   = "Valuation Color Profile",
     options = ["Conservative", "Balanced", "Growth", "Custom"],
     group   = groupProfile,
     tooltip = "Changes only the color thresholds used to grade valuation and quality metrics. It does not modify the reported financial data."
)
profileTolerancePct = input.float(
     25.0,
     title   = "Neutral Zone Tolerance (%)",
     minval  = 0.0,
     maxval  = 100.0,
     step    = 5.0,
     group   = groupProfile,
     tooltip = "Creates a blue neutral zone around each profile threshold. Example: with 25% tolerance, a P/E limit of 20 stays blue up to 25 before turning red."
)
// Custom thresholds are used only when Valuation Color Profile = Custom.
customRoaMin = input.float(
     5.0,
     title  = "Custom — ROA Min (%)",
     step   = 0.5,
     group  = groupProfile
)
customRoeMin = input.float(
     10.0,
     title  = "Custom — ROE Min (%)",
     step   = 0.5,
     group  = groupProfile
)
customRoicMin = input.float(
     8.0,
     title  = "Custom — ROIC Min (%)",
     step   = 0.5,
     group  = groupProfile
)
customCurrentRatioMin = input.float(
     1.5,
     title  = "Custom — Current Ratio Min",
     minval = 0.0,
     step   = 0.1,
     group  = groupProfile
)
customPeMax = input.float(
     20.0,
     title  = "Custom — P/E Max",
     minval = 0.1,
     step   = 0.5,
     group  = groupProfile
)
customPegMax = input.float(
     1.5,
     title  = "Custom — PEG Max",
     minval = 0.1,
     step   = 0.1,
     group  = groupProfile
)
customPsMax = input.float(
     3.0,
     title  = "Custom — P/S Max",
     minval = 0.1,
     step   = 0.1,
     group  = groupProfile
)
customPbMax = input.float(
     2.5,
     title  = "Custom — P/B Max",
     minval = 0.1,
     step   = 0.1,
     group  = groupProfile
)
customDebtEquityMax = input.float(
     1.0,
     title  = "Custom — Debt/Equity Max",
     minval = 0.0,
     step   = 0.1,
     group  = groupProfile
)
customRocMin = input.float(
     10.0,
     title  = "Custom — ROC Min (%)",
     step   = 0.5,
     group  = groupProfile
)
customDebtEbitdaMax = input.float(
     3.0,
     title  = "Custom — Debt/EBITDA Max",
     minval = 0.0,
     step   = 0.1,
     group  = groupProfile
)
customPiotroskiMin = input.float(
     6.0,
     title  = "Custom — Piotroski Good Min",
     minval = 0.0,
     maxval = 9.0,
     step   = 1.0,
     group  = groupProfile
)
// Profile thresholds.
// These are heuristic presets, not sector-adjusted valuation models.
float roaMin =
     valuationProfile == "Conservative" ? 8.0 :
     valuationProfile == "Balanced"     ? 5.0 :
     valuationProfile == "Growth"       ? 2.0 :
                                           customRoaMin
float roeMin =
     valuationProfile == "Conservative" ? 15.0 :
     valuationProfile == "Balanced"     ? 10.0 :
     valuationProfile == "Growth"       ? 5.0 :
                                           customRoeMin
float roicMin =
     valuationProfile == "Conservative" ? 12.0 :
     valuationProfile == "Balanced"     ? 8.0 :
     valuationProfile == "Growth"       ? 5.0 :
                                           customRoicMin
float currentRatioMin =
     valuationProfile == "Conservative" ? 2.0 :
     valuationProfile == "Balanced"     ? 1.5 :
     valuationProfile == "Growth"       ? 1.0 :
                                           customCurrentRatioMin
float peMax =
     valuationProfile == "Conservative" ? 15.0 :
     valuationProfile == "Balanced"     ? 20.0 :
     valuationProfile == "Growth"       ? 35.0 :
                                           customPeMax
float pegMax =
     valuationProfile == "Conservative" ? 1.0 :
     valuationProfile == "Balanced"     ? 1.5 :
     valuationProfile == "Growth"       ? 2.0 :
                                           customPegMax
float psMax =
     valuationProfile == "Conservative" ? 2.0 :
     valuationProfile == "Balanced"     ? 3.0 :
     valuationProfile == "Growth"       ? 6.0 :
                                           customPsMax
float pbMax =
     valuationProfile == "Conservative" ? 1.5 :
     valuationProfile == "Balanced"     ? 2.5 :
     valuationProfile == "Growth"       ? 5.0 :
                                           customPbMax
float debtEquityMax =
     valuationProfile == "Conservative" ? 0.5 :
     valuationProfile == "Balanced"     ? 1.0 :
     valuationProfile == "Growth"       ? 1.5 :
                                           customDebtEquityMax
float rocMin =
     valuationProfile == "Conservative" ? 15.0 :
     valuationProfile == "Balanced"     ? 10.0 :
     valuationProfile == "Growth"       ? 5.0 :
                                           customRocMin
float debtEbitdaMax =
     valuationProfile == "Conservative" ? 2.0 :
     valuationProfile == "Balanced"     ? 3.0 :
     valuationProfile == "Growth"       ? 4.0 :
                                           customDebtEbitdaMax
float piotroskiGoodMin =
     valuationProfile == "Conservative" ? 7.0 :
     valuationProfile == "Balanced"     ? 6.0 :
     valuationProfile == "Growth"       ? 5.0 :
                                           customPiotroskiMin
// COLOR GROUP
groupColors = "Colors"
TextDataColor = input.color(
     color.new(#b8b8b8, 20),
     "Text Color",
     group = groupColors
     )

// ============================================================================
// FINANCIAL REQUEST ENGINE — LAST-STATE OPTIMIZED
// ============================================================================
// FVS is a current fundamental snapshot, not a historical fundamental plot.
// To reduce runtime and memory pressure, financial datasets are requested only:
//   1) on the last confirmed historical bar (primes request contexts safely), and
//   2) once at the start of each realtime bar, plus once at its closing update.
// Values are stored in persistent variables and reused by the table.
//
// This keeps all reported metrics and calculations unchanged while avoiding
// repeated request.financial() execution across the full chart history.
// Persistent core financial values.
var float roa = na
var float roe = na
var float roic = na
var float currentRatio = na
var float epsTTM = na
var float totalShares = na
var float bookValuePerShare = na
var float pegRatio = na
var float debtToEquity = na
var float dividendYield = na
var float totalRevenue = na
var float grossProfit = na
var float netIncome = na
var float cashAndInvestments = na
var float totalDebt = na
var float ebitTTM = na
var float netFixedAssets = na
var float accountsReceivable = na
var float totalInventory = na
var float accountsPayable = na
// Persistent additional fundamental values.
var float revenueGrowthYoY = na
var float netMargin = na
var float freeCashFlowTTM = na
var float debtToEBITDA = na
var float piotroskiScore = na
// varip lets us remember whether the current realtime bar has already refreshed.
// It resets explicitly when a new realtime bar starts.
varip bool financialsRefreshedThisBar = false
if barstate.isnew
    financialsRefreshedThisBar := false
bool refreshFinancials =
     barstate.islastconfirmedhistory or
     (barstate.isrealtime and (not financialsRefreshedThisBar or barstate.isconfirmed))
// --------------------------------------------------------------------------
// CORE A — RATIOS & PER-SHARE DATA (10 financial requests)
// --------------------------------------------------------------------------
if refreshFinancials and showPanelEffective
    roa := request.financial(
         syminfo.tickerid,
         "RETURN_ON_ASSETS",
         ratioPeriod,
         ignore_invalid_symbol = true
    )
    roe := request.financial(
         syminfo.tickerid,
         "RETURN_ON_EQUITY",
         ratioPeriod,
         ignore_invalid_symbol = true
    )
    roic := request.financial(
         syminfo.tickerid,
         "RETURN_ON_INVESTED_CAPITAL",
         ratioPeriod,
         ignore_invalid_symbol = true
    )
    currentRatio := request.financial(
         syminfo.tickerid,
         "CURRENT_RATIO",
         ratioPeriod,
         ignore_invalid_symbol = true
    )
    epsTTM := request.financial(
         syminfo.tickerid,
         "EARNINGS_PER_SHARE",
         "TTM",
         ignore_invalid_symbol = true
    )
    totalShares := request.financial(
         syminfo.tickerid,
         "TOTAL_SHARES_OUTSTANDING",
         "FQ",
         ignore_invalid_symbol = true
    )
    bookValuePerShare := request.financial(
         syminfo.tickerid,
         "BOOK_VALUE_PER_SHARE",
         "FQ",
         ignore_invalid_symbol = true
    )
    pegRatio := request.financial(
         syminfo.tickerid,
         "PEG_RATIO",
         ratioPeriod,
         ignore_invalid_symbol = true
    )
    debtToEquity := request.financial(
         syminfo.tickerid,
         "DEBT_TO_EQUITY",
         ratioPeriod,
         ignore_invalid_symbol = true
    )
    dividendYield := request.financial(
         syminfo.tickerid,
         "DIVIDENDS_YIELD",
         ratioPeriod,
         ignore_invalid_symbol = true
    )
// --------------------------------------------------------------------------
// CORE B — INCOME, CASH & ROC DATA (10 financial requests)
// --------------------------------------------------------------------------
if refreshFinancials and showPanelEffective
    // Income statement — TTM
    totalRevenue := request.financial(
         syminfo.tickerid,
         "TOTAL_REVENUE",
         "TTM",
         ignore_invalid_symbol = true
    )
    grossProfit := request.financial(
         syminfo.tickerid,
         "GROSS_PROFIT",
         "TTM",
         ignore_invalid_symbol = true
    )
    netIncome := request.financial(
         syminfo.tickerid,
         "NET_INCOME",
         "TTM",
         ignore_invalid_symbol = true
    )
    // Net cash
    cashAndInvestments := request.financial(
         syminfo.tickerid,
         "CASH_N_SHORT_TERM_INVEST",
         "FQ",
         ignore_invalid_symbol = true
    )
    totalDebt := request.financial(
         syminfo.tickerid,
         "TOTAL_DEBT",
         "FQ",
         ignore_invalid_symbol = true
    )
    // ROC — Joel Greenblatt
    ebitTTM := request.financial(
         syminfo.tickerid,
         "EBIT",
         "TTM",
         ignore_invalid_symbol = true
    )
    netFixedAssets := request.financial(
         syminfo.tickerid,
         "PPE_TOTAL_NET",
         "FQ",
         ignore_invalid_symbol = true
    )
    accountsReceivable := request.financial(
         syminfo.tickerid,
         "ACCOUNTS_RECEIVABLES_NET",
         "FQ",
         ignore_invalid_symbol = true
    )
    totalInventory := request.financial(
         syminfo.tickerid,
         "TOTAL_INVENTORY",
         "FQ",
         ignore_invalid_symbol = true
    )
    accountsPayable := request.financial(
         syminfo.tickerid,
         "ACCOUNTS_PAYABLE",
         "FQ",
         ignore_invalid_symbol = true
    )
// --------------------------------------------------------------------------
// ADDITIONAL FUNDAMENTAL METRICS (5 financial requests)
// --------------------------------------------------------------------------
if refreshFinancials and showAdditionalEffective
    revenueGrowthYoY := request.financial(
         syminfo.tickerid,
         "REVENUE_ONE_YEAR_GROWTH",
         "TTM",
         ignore_invalid_symbol = true
    )
    netMargin := request.financial(
         syminfo.tickerid,
         "NET_MARGIN",
         "TTM",
         ignore_invalid_symbol = true
    )
    freeCashFlowTTM := request.financial(
         syminfo.tickerid,
         "FREE_CASH_FLOW",
         "TTM",
         ignore_invalid_symbol = true
    )
    debtToEBITDA := request.financial(
         syminfo.tickerid,
         "DEBT_TO_EBITDA",
         ratioPeriod,
         ignore_invalid_symbol = true
    )
    piotroskiScore := request.financial(
         syminfo.tickerid,
         "PIOTROSKI_F_SCORE",
         ratioPeriod,
         ignore_invalid_symbol = true
    )
if barstate.isrealtime and refreshFinancials
    financialsRefreshedThisBar := true
// ============================================================================
// ANALYST PRICE TARGETS
// ============================================================================
// Analyst targets can become unavailable directly on very high chart
// timeframes. Retrieve the three lightweight target values from Daily context.
[targetPriceLow,
 targetPriceAverage,
 targetPriceHigh] = request.security(
    syminfo.tickerid,
    "D",
    [
        syminfo.target_price_low,
        syminfo.target_price_average,
        syminfo.target_price_high
    ],
    gaps                  = barmerge.gaps_off,
    lookahead             = barmerge.lookahead_off,
    ignore_invalid_symbol = true,
    calc_bars_count       = 5
)

float targetAverageGap = (
     not na(targetPriceAverage) and close != 0
     ? (targetPriceAverage / close - 1) * 100
     : na
)

// ============================================================================
// CALCULATION
// ============================================================================
safeDivide(float numerator, float denominator) =>
    (not na(numerator) and not na(denominator) and denominator != 0)
         ? numerator / denominator
         : na
float marketCap = totalShares * close
float priceEarningsRatio = safeDivide(close, epsTTM)
float priceSalesRatio    = safeDivide(marketCap, totalRevenue)
float priceBookRatio     = safeDivide(close, bookValuePerShare)
// Net cash = cash + short-term investment - total debt
float netCash = cashAndInvestments - totalDebt
float netCashPerShare = safeDivide(
     netCash,
     totalShares
)
// Business price after accounting for net cash.
float cashAdjustedPrice = close - netCashPerShare
// ROC Greenblatt
float operatingNWC = (
     accountsReceivable +
     totalInventory -
     accountsPayable
)
float investedCapital = (
     netFixedAssets +
     operatingNWC
)
float roc = (
     not na(ebitTTM) and
     not na(investedCapital) and
     investedCapital > 0
)
     ? ebitTTM / investedCapital * 100
     : na
// ============================================================================
// FORMAT FUNCTIONS
// ============================================================================
formatNumber(float value) =>
    na(value)
         ? "N/A"
         : str.tostring(value, "#.##")
formatPercent(float value) =>
    na(value)
         ? "N/A"
         : str.tostring(value, "#.##") + "%"
formatPrice(float value) =>
    na(value)
         ? "N/A"
         : str.tostring(value, format.mintick)
// 1.000 → 1K
// 1.000.000 → 1M
// 1 billion → 1B
// 1 trillion → 1T
formatLargeNumber(float value) =>
    if na(value)
        "N/A"
    else
        float absoluteValue = math.abs(value)
        float divisor =
             absoluteValue >= 1e12 ? 1e12 :
             absoluteValue >= 1e9  ? 1e9  :
             absoluteValue >= 1e6  ? 1e6  :
             absoluteValue >= 1e3  ? 1e3  :
             1.0
        string suffix =
             absoluteValue >= 1e12 ? "T" :
             absoluteValue >= 1e9  ? "B" :
             absoluteValue >= 1e6  ? "M" :
             absoluteValue >= 1e3  ? "K" :
             ""
        str.tostring(value / divisor, "#.##") + suffix
// ============================================================================
// COLORS
// ============================================================================
color positiveColor = color.new(color.green, 70)
color negativeColor = color.new(color.red, 70)
color neutralColor  = color.new(color.blue, 70)
color headerColor   = color.new(color.rgb(45, 45, 55), 0)
color naColor       = color.new(color.gray, 75)
float toleranceFactor = profileTolerancePct / 100.0
// Higher-is-better metrics:
// green = meets profile threshold
// blue  = within tolerance below threshold
// red   = below the neutral zone
higherIsBetter(float value, float minimumValue) =>
    float neutralMinimum = minimumValue * (1.0 - toleranceFactor)
    na(value)
         ? naColor
         : value >= minimumValue
             ? positiveColor
             : value >= neutralMinimum
                 ? neutralColor
                 : negativeColor
// Lower-is-better valuation multiples.
// Negative/zero multiples are not classified as "cheap".
valuationColor(float value, float maximumValue) =>
    float neutralMaximum = maximumValue * (1.0 + toleranceFactor)
    na(value)
         ? naColor
         : value <= 0
             ? negativeColor
             : value <= maximumValue
                 ? positiveColor
                 : value <= neutralMaximum
                     ? neutralColor
                     : negativeColor
// Lower-is-better debt ratios.
// Negative ratios are treated as unhealthy/invalid for this grading system.
debtColor(float value, float maximumValue) =>
    float neutralMaximum = maximumValue * (1.0 + toleranceFactor)
    na(value)
         ? naColor
         : value < 0
             ? negativeColor
             : value <= maximumValue
                 ? positiveColor
                 : value <= neutralMaximum
                     ? neutralColor
                     : negativeColor
profitColor(float value) =>
    na(value)
         ? naColor
         : value >= 0
             ? positiveColor
             : negativeColor
growthColor(float value) =>
    na(value)
         ? naColor
         : value > 0
             ? positiveColor
             : negativeColor
neutralValue(float value) =>
    na(value)
         ? naColor
         : neutralColor
piotroskiColor(float value) =>
    float neutralMinimum = math.max(piotroskiGoodMin - 2.0, 0.0)
    na(value)
         ? naColor
         : value >= piotroskiGoodMin
             ? positiveColor
             : value >= neutralMinimum
                 ? neutralColor
                 : negativeColor
targetPriceColor(float targetPrice) =>
    na(targetPrice)
         ? naColor
         : targetPrice > close
             ? positiveColor
             : targetPrice < close
                 ? negativeColor
                 : neutralColor
// Green: analyst average target is at least 10% above price.
// Blue : price is within ±10% of the average target.
// Red  : price is at least 10% above the average target.
targetGapColor(float gapPercent) =>
    na(gapPercent)
         ? naColor
         : gapPercent >= 10
             ? positiveColor
             : gapPercent <= -10
                 ? negativeColor
                 : neutralColor
// Analyst minimum-target display:
// green when current price is at/above the analyst minimum target,
// blue when it is still below the minimum target.
targetMinColor(float targetPrice) =>
    na(targetPrice)
         ? naColor
         : close >= targetPrice
             ? positiveColor
             : neutralColor
// ============================================================================
// TABLE
// ============================================================================
var table valuationTable = table.new(
     tablePosition,
     2,
     14,
     border_width = 1,
     frame_width  = 1,
     frame_color  = color.new(color.gray, 60)
)
if barstate.isfirst
    table.merge_cells(
         valuationTable,
         0,
         0,
         1,
         0
    )
    table.merge_cells(
         valuationTable,
         0,
         11,
         1,
         11
    )
if barstate.islast
    bool showAnySection = showPanelEffective or showAdditionalEffective or showPriceTargets
    if showAnySection
        // ====================================================================
        // HEADER — VISIBLE WHEN ANY SECTION IS ENABLED
        // ====================================================================
        table.cell(
             valuationTable,
             0,
             0,
             syminfo.ticker +
             " • FVS • TTM • " +
             ratioPeriod +
             " • " +
             valuationProfile +
             " • " +
             syminfo.currency,
             text_color = color.new(color.white, 20),
             bgcolor    = headerColor,
             text_size  = panelTextSize
        )
        // ====================================================================
        // CORE VALUATION PANEL
        // ====================================================================
        if showPanelEffective
            // PROFITABILITY
            table.cell(
                 valuationTable,
                 0,
                 1,
                 "ROA: " + formatPercent(roa),
                 text_color = TextDataColor,
                 bgcolor    = higherIsBetter(roa, roaMin),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 1,
                 1,
                 "ROE: " + formatPercent(roe),
                 text_color = TextDataColor,
                 bgcolor    = higherIsBetter(roe, roeMin),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 0,
                 2,
                 "ROIC: " + formatPercent(roic),
                 text_color = TextDataColor,
                 bgcolor    = higherIsBetter(roic, roicMin),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 1,
                 2,
                 "Current Ratio: " + formatNumber(currentRatio),
                 text_color = TextDataColor,
                 bgcolor    = higherIsBetter(currentRatio, currentRatioMin),
                 text_size  = panelTextSize
            )
            // VALUATION
            table.cell(
                 valuationTable,
                 0,
                 3,
                 "P/E: " + formatNumber(priceEarningsRatio),
                 text_color = TextDataColor,
                 bgcolor    = valuationColor(priceEarningsRatio, peMax),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 1,
                 3,
                 "PEG: " + formatNumber(pegRatio),
                 text_color = TextDataColor,
                 bgcolor    = valuationColor(pegRatio, pegMax),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 0,
                 4,
                 "P/S: " + formatNumber(priceSalesRatio),
                 text_color = TextDataColor,
                 bgcolor    = valuationColor(priceSalesRatio, psMax),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 1,
                 4,
                 "P/B: " + formatNumber(priceBookRatio),
                 text_color = TextDataColor,
                 bgcolor    = valuationColor(priceBookRatio, pbMax),
                 text_size  = panelTextSize
            )
            // DEBT AND DIVIDEND
            table.cell(
                 valuationTable,
                 0,
                 5,
                 "Debt/Equity: " + formatNumber(debtToEquity),
                 text_color = TextDataColor,
                 bgcolor    = debtColor(debtToEquity, debtEquityMax),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 1,
                 5,
                 "Dividend Yield: " + formatPercent(dividendYield),
                 text_color = TextDataColor,
                 bgcolor    = neutralValue(dividendYield),
                 text_size  = panelTextSize
            )
            // MARKET DATA
            table.cell(
                 valuationTable,
                 0,
                 6,
                 "Market Cap: " + formatLargeNumber(marketCap),
                 text_color = TextDataColor,
                 bgcolor    = neutralValue(marketCap),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 1,
                 6,
                 "Cash-Adj Price: " + formatPrice(cashAdjustedPrice),
                 text_color = TextDataColor,
                 bgcolor    = neutralValue(cashAdjustedPrice),
                 text_size  = panelTextSize
            )
            // INCOME STATEMENT
            table.cell(
                 valuationTable,
                 0,
                 7,
                 "Revenue: " + formatLargeNumber(totalRevenue),
                 text_color = TextDataColor,
                 bgcolor    = neutralValue(totalRevenue),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 1,
                 7,
                 "Gross Profit: " + formatLargeNumber(grossProfit),
                 text_color = TextDataColor,
                 bgcolor    = profitColor(grossProfit),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 0,
                 8,
                 "Net Income: " + formatLargeNumber(netIncome),
                 text_color = TextDataColor,
                 bgcolor    = profitColor(netIncome),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 1,
                 8,
                 "ROC: " + formatPercent(roc),
                 text_color = TextDataColor,
                 bgcolor    = higherIsBetter(roc, rocMin),
                 text_size  = panelTextSize
            )
        else
            table.clear(
                 valuationTable,
                 0,
                 1,
                 1,
                 8
            )
        // ====================================================================
        // OPTIONAL ADDITIONAL METRICS — INDEPENDENT FROM CORE PANEL
        // ====================================================================
        if showAdditionalEffective
            table.cell(
                 valuationTable,
                 0,
                 9,
                 "Revenue Growth: " + formatPercent(revenueGrowthYoY),
                 text_color = TextDataColor,
                 bgcolor    = growthColor(revenueGrowthYoY),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 1,
                 9,
                 "Net Margin: " + formatPercent(netMargin),
                 text_color = TextDataColor,
                 bgcolor    = profitColor(netMargin),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 0,
                 10,
                 "FCF TTM: " + formatLargeNumber(freeCashFlowTTM),
                 text_color = TextDataColor,
                 bgcolor    = profitColor(freeCashFlowTTM),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 1,
                 10,
                 "Debt/EBITDA: " + formatNumber(debtToEBITDA),
                 text_color = TextDataColor,
                 bgcolor    = debtColor(debtToEBITDA, debtEbitdaMax),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 0,
                 11,
                 "Piotroski F-Score: " +
                 formatNumber(piotroskiScore) +
                 " / 9",
                 text_color = TextDataColor,
                 bgcolor    = piotroskiColor(piotroskiScore),
                 text_size  = panelTextSize
            )
        else
            table.clear(
                 valuationTable,
                 0,
                 9,
                 1,
                 11
            )
        // ====================================================================
        // OPTIONAL ANALYST PRICE TARGETS — INDEPENDENT FROM CORE PANEL
        // ====================================================================
        if showPriceTargets
            table.cell(
                 valuationTable,
                 0,
                 12,
                 "Target Min: " + formatPrice(targetPriceLow),
                 text_color = TextDataColor,
                 bgcolor    = targetMinColor(targetPriceLow),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 1,
                 12,
                 "Target Avg: " + formatPrice(targetPriceAverage),
                 text_color = TextDataColor,
                 bgcolor    = targetPriceColor(targetPriceAverage),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 0,
                 13,
                 "Target Max: " + formatPrice(targetPriceHigh),
                 text_color = TextDataColor,
                 bgcolor    = targetPriceColor(targetPriceHigh),
                 text_size  = panelTextSize
            )
            table.cell(
                 valuationTable,
                 1,
                 13,
                 "vs Target Avg: " + formatPercent(targetAverageGap),
                 text_color = TextDataColor,
                 bgcolor    = targetGapColor(targetAverageGap),
                 text_size  = panelTextSize
            )
        else
            table.clear(
                 valuationTable,
                 0,
                 12,
                 1,
                 13
            )
    else
        table.clear(
             valuationTable,
             0,
             0,
             1,
             13
        )
````
