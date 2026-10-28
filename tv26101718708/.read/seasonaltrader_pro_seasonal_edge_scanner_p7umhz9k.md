# SeasonalTrader Pro - Seasonal Edge Scanner

- url: https://www.tradingview.com/script/P7UmhZ9k/
- type: indicator
- pine_id: PUB;f5fe95b710ea429e9568d748ce1f258c
- version: 12.0

## Description

SeasonalTrader Pro - Seasonal Edge Scanner is a Daily-based seasonal statistics scanner. It searches for recurring calendar-window behavior by comparing the current seasonal period with the same historical periods over a configurable lookback range.

The script scans potential entry and exit windows within a defined Daily scan horizon and evaluates Long, Short, and Range/Mean-Reversion candidates. All statistical calculations are based on Daily data. Lower chart timeframes can be used for visualization and trade observation, but they do not change the scan basis.

Methodology

For each tested seasonal window, the script compares the same calendar period across historical years and calculates directional and range-based statistics.

Directional Long/Short statistics include:

- historical win rate
- average return
- average drawdown
- SQN-style consistency metric
- sample count
- MAE/MFE-based risk and target reference levels
- recent stability and outlier impact checks

Range/Mean-Reversion statistics include:

- average historical range size
- net movement relative to the full range
- range efficiency
- close-inside rate
- breakout rate
- range quality and range eligibility

The scanner then applies an Auto Quality layer. This layer ranks and filters candidates using sample confidence, raw score, final quality grade, separation from competing Long/Short/Range candidates, outlier risk, stability, plateau robustness, and tradeability context.

AutoQ / Quality Engine

The AutoQ system is used to reduce weak or isolated seasonal candidates. It is not a trade signal by itself.

Quality evaluation includes:

- confidence-adjusted win rate
- minimum sample depth
- average return and drawdown requirements
- SQN contribution
- Long/Short/Range separation
- outlier and overfit checks
- recent-year stability
- plateau robustness around the selected window
- tradeability state of the current seasonal window

The Quality Strength setting controls how strict this filter is. A value of 0 enables a reference scan mode based mainly on the raw minimum win rate.

Bias Classification

The indicator can classify the current seasonal context as:

- LONG Bias
- SHORT Bias
- RANGE / MR Bias
- NO EDGE

The bias classifier compares the best eligible directional and range candidates. In Auto mode, Range only wins when the range score and quality context are strong enough compared with the directional alternatives. Directional-only and Range-only modes are also available.

Seasonal Potential Panel

The Seasonal Potential panel evaluates the currently selected Daily edge after the quality filter. It does not describe a general market bias. It evaluates whether the selected seasonal idea still has usable potential at the current point in the window.

The panel combines:

- current tradeability state: Pre, Active, Late, Expired, Invalidated, No Edge
- volatility fit
- move used or range position
- remaining potential
- seasonal risk/reward
- invalidation distance or breakout risk
- robustness score
- outlier risk
- final quality summary

For directional setups, the potential model uses historical MFE/MAE behavior to estimate remaining move, late-entry risk, and invalidation context. For range setups, it evaluates range position, range expansion, mean-reversion behavior, and breakout risk.

Risk / Reward Bands

The optional Risk/Reward bands are derived from the selected Daily seasonal window and its historical MAE/MFE distribution.

Displayed levels may include:

- Median MFE
- 75th percentile MFE
- Median MAE
- 75th percentile MAE

These levels are statistical reference areas only. They are not fixed targets, stops, or execution rules.

Historical Verification

The script can display historical verification periods on the chart and in a table. This allows visual inspection of how the selected seasonal window behaved in previous years.

Directional verification shows yearly profit/loss and drawdown.  
Range verification shows range efficiency, range size, net movement, and whether the historical window behaved as range, mean-reversion, or breakout.

Projection and Zone Locking

Future seasonal zones are projected from Daily timestamps. The script supports projected Long, Short, Range, Best Zone, or All Regime views.

Visible zones are stabilized through a lock mechanism:

- active zones remain locked until expiry
- pending zones can update depending on the selected pending-lock policy
- projected timestamps can use either trading-day estimation or calendar-day projection

This is intended to prevent visible zones from shifting unnecessarily once a seasonal window becomes active.

Alerts

The script provides alert conditions for selected seasonal state changes, including:

- potential becoming strong or weak
- late-entry risk
- move exhaustion
- invalidation
- 75% MFE reached
- weak robustness
- high outlier risk
- expired or invalidated window
- range breakout risk

Alerts refer to the selected seasonal edge and should be interpreted together with the chart context.

Important Limitations

This is a statistical analysis tool, not a standalone trading system.

The indicator does not place orders, define position sizing, or account for commissions, spread, slippage, funding costs, or execution quality. Seasonal behavior can change due to regime shifts, macro conditions, liquidity changes, market structure changes, or symbol-specific events.

All main calculations are Daily-based. Lower timeframes may help with execution timing, but they do not increase the statistical sample size or change the seasonal scan.

Historical recurrence does not guarantee future behavior. The output should be used as contextual information together with independent market analysis and risk management.

## Source Code

````pine
//@version=6
indicator("SeasonalTrader Pro - Seasonal Edge Scanner", overlay = true, shorttitle = 'SES', max_bars_back = 5000, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 200)

string GROUP_CORE       = "Core"
string GROUP_BIAS       = "Seasonal Bias"
string GROUP_POTENTIAL  = "Seasonal Potential"
string GROUP_RISK       = "Risk / Reward"
string GROUP_ALERTS     = "Alerts"
string GROUP_DISPLAY    = "Display"

// TradingView tooltip popovers wrap at roughly 38 text characters in this dialog.
// Continuation lines are pre-wrapped and indented with one U+2800 Braille blank
// because normal leading spaces are ignored in TradingView tooltips.

string TOOLTIP_AUTOQ_PANEL = "AutoQ overview:\n• Q0 uses All-History baseline\n⠀evidence.\n• Higher Q filters the same canonical\n⠀zones with stricter evidence gates.\n• Quality never changes canonical zone\n⠀dates or identity.\n\nImportant:\n• AutoQ filters/ranks existing zones;\n⠀it is not a trade signal."
string TOOLTIP_SEASONAL_POTENTIAL_PANEL = "Seasonal Potential overview:\n• Stable: canonical zone dates, FQ,\n⠀Evidence, Plateau and OOS.\n• Dynamic: lifecycle, volatility fit,\n⠀remaining move, risk/reward, Move\n⠀Used, invalidation and tradeability.\n• Strong potential means the selected\n⠀seasonal idea still has usable room\n⠀with acceptable context.\n\nImportant:\n• It is not a general market bias and\n⠀does not replace risk management.\n• Current price can change Dynamic\n⠀values, never the canonical zone or\n⠀its Historical Evidence."
string TOOLTIP_QUALITY_ROW = "Quality row legend:\n• FQ = effective Final Quality under\n⠀the selected Quality Strength.\n• Canonical geometry and historical\n⠀evidence remain unchanged.\n• WL90 = Training Wilson lower bound.\n• Sep/OR/Stab/Plat summarize quality\n⠀and robustness evidence."
string TOOLTIP_EVIDENCE_ROW = "Evidence row legend:\n• Q0 shows All-History Reference\n⠀wins/samples and raw winrate.\n• Q10+ shows Training evidence and\n⠀WL90 confidence.\n• Plateau and OOS remain diagnostic at\n⠀Q0 and become higher-Q robustness\n⠀gates."
string TOOLTIP_PROJECTED_TIME = "Projected time:\n• Proj means the displayed future\n⠀Daily timestamp is estimated from\n⠀Daily offsets.\n• Weekends are skipped for non-crypto\n⠀markets.\n• Exchange holidays and shortened\n⠀sessions are not fully modelled.\n• Actual means the Daily bar timestamp\n⠀has been resolved by confirmed data."
string TOOLTIP_POTENTIAL_CONTROLS = "Seasonal Potential controls:\n• Show/hide the Seasonal Potential\n⠀panel.\n• Position places the panel at the\n⠀selected chart edge.\n\nImportant:\n• Position changes display only, not\n⠀calculations.\n• Choose a panel position that avoids\n⠀candles, labels, and key price areas."
string TOOLTIP_RISK_REWARD_CONTROLS = "Risk / Reward controls:\n• Show/hide Daily-based target and\n⠀risk bands for the seasonal idea.\n• Mode selects Minimal for a cleaner\n⠀chart or Full for additional levels.\n\nImportant:\n• Lower timeframes still show\n⠀Daily-based results.\n• Bands are guidance, not guaranteed\n⠀target or stop areas."
string TOOLTIP_MAIN_PANEL_CONTROLS = "Main panel controls:\n• Show/hide the AutoQ/stats panel with\n⠀Long, Short, Bias, and quality data.\n• Position places it at the selected\n⠀chart edge.\n\nImportant:\n• Position changes display only, not\n⠀calculations.\n• Keep it separate from other panels\n⠀to prevent overlap."
string TOOLTIP_VERIFICATION_PANEL_CONTROLS = "Verification panel controls:\n• Show/hide the yearly historical\n⠀results panel.\n• Position places it at the selected\n⠀chart edge.\n\nPractical notes:\n• Use yearly results to spot outliers\n⠀and unstable patterns.\n• Keep it separate from other panels\n⠀to prevent overlap."
string TOOLTIP_HISTORICAL_DISPLAY_CONTROLS = "Historical verification controls:\n• Show/hide historical verification\n⠀periods on the chart.\n• Rows limits the displayed historical\n⠀zones; statistics still use all\n⠀configured Lookback Years.\n\nPractical notes:\n• Disable periods when the chart is\n⠀too crowded."
string TOOLTIP_NO_EDGE_REASON = "No-Edge reason:\n• Shows one primary standardized\n⠀reason for the missing final edge.\n• Details remain in the compact panel\n⠀context to avoid long rows.\n• Reasons do not create new trading\n⠀logic; they only describe the final\n⠀ViewModel and gates already applied."
string TOOLTIP_QUALITY_STRENGTH = "Quality Strength:\n• Q0 runs the All-History baseline\n⠀scan.\n• Q10+ progressively adds stricter\n⠀evidence and robustness filters.\n\nImportant:\n• Every level filters the same\n⠀canonical zones.\n• Quality Strength never changes zone\n⠀dates or identity."
string TOOLTIP_MINIMUM_WINRATE = "Minimum Winrate:\n• Sets the baseline historical winrate\n⠀required for every quality level.\n• Q0 applies it to All-History\n⠀Reference Evidence.\n• Q10+ must also pass this baseline;\n⠀AutoQ can add stricter quality gates.\n\nImportant:\n• It never changes canonical zone\n⠀dates or identity."
string TOOLTIP_VISIBLE_STATUS = "Visible status:\n• Shows the status of the locked zone.\n• Without a locked zone, it shows the\n⠀current primary scanner status."
string TOOLTIP_QUALITY_GATE_STATUS = "Quality gate status:\n• Gate Off means Q0 reference mode.\n• Gate On means an AutoQ level is\n⠀applying additional quality filters."

scanHorizonDays      = input.int(60, "Scan Horizon Days", minval = 10, maxval = 120, group = GROUP_CORE, tooltip = "What it controls:\n• Visibility range for already-built\n⠀future Seasonal Zones, measured in\n⠀Daily bars from the current date.\n• The fixed forecast-year map and its\n⠀historical Evidence do not change.\n\nPractical notes:\n• Higher values show more existing\n⠀future zones.\n• Lower values keep the view focused\n⠀without changing zone geometry.")
minTradeDurationDays = input.int(5, "Min Trade Duration", minval = 1, maxval = 60, group = GROUP_CORE, tooltip = "What it controls:\n• Shortest allowed holding period for\n⠀a tested seasonal setup, measured in\n⠀Daily bars.\n• Entry and exit must be at least this\n⠀many trading days apart.\n\nPractical notes:\n• Lower values can find shorter-term\n⠀seasonal patterns.\n• Higher values filter out very short\n⠀signals and often produce calmer\n⠀results.")
maxTradeDurationDays = input.int(25, "Max Trade Duration", minval = 1, maxval = 90, group = GROUP_CORE, tooltip = "What it controls:\n• Maximum operational holding period,\n⠀measured in Daily bars.\n• It does not shorten or redefine the\n⠀canonical Seasonal Zone.\n\nPractical notes:\n• Longer Seasonal Zones remain intact.\n• A later operational trade window can\n⠀apply this execution constraint.")
lookbackYears        = input.int(10, "Lookback Years", minval = 3, maxval = 30, group = GROUP_CORE, tooltip = "What it controls:\n• Number of historical years used for\n⠀the seasonal statistics.\n• Each year provides one sample for\n⠀the same calendar window when data is\n⠀available.\n\nPractical notes:\n• More years can make the statistics\n⠀more stable, but older regimes\n⠀receive more weight.\n• Fewer years are more current, but\n⠀more sensitive to randomness.\n\nCFD warning:\n• Do not use CFD charts for historical\n⠀seasonal analysis when a reference\n⠀index, future, or spot symbol exists.\n• Broker CFDs often provide shorter or\n⠀rebuilt history and use different\n⠀session boundaries or Daily closes.\n• This can reduce valid samples and\n⠀distort seasonal results.")
qualityStrength      = input.int(0, "Quality Strength", minval = 0, maxval = 100, step = 10, group = GROUP_CORE, tooltip = TOOLTIP_QUALITY_STRENGTH)
referenceMinWinRate  = input.int(70, "Minimum Winrate", minval = 50, maxval = 95, step = 5, group = GROUP_CORE, tooltip = TOOLTIP_MINIMUM_WINRATE)
int configuredHoldoutYears = lookbackYears >= 9 ? math.min(5, math.max(3, int(math.round(lookbackYears * 0.25)))) : 0
int configuredTrainingYears = lookbackYears - configuredHoldoutYears
bool isReferenceScan = qualityStrength == 0

type QualityConfig
    bool enableQualityLayer
    bool enableOverfitWarning
    int recentYearsCheck
    int q0MinSampleYears
    float q0MinAvgProfitPct
    int minSampleYears
    float minWinRatePct
    float minAvgProfitPct
    float maxAvgDrawdownPct
    string minQualityGrade
    float minFinalQualityScore
    float minSqn

f_qualityConfig(bool referenceScan, int strength, int years, int referenceWinRate) =>
    int cfgQ0MinSampleYears = math.min(years, 6)
    float cfgQ0MinAvgProfitPct = 0.05
    int cfgMinSampleYears = referenceScan ? cfgQ0MinSampleYears : strength <= 20 ? math.min(years, 6) : strength <= 50 ? math.min(years, 7) : math.min(years, 8)
    float cfgMinWinRatePct = referenceScan ? referenceWinRate * 1.0 : math.max(referenceWinRate * 1.0, 70.0 + strength * 0.05)
    float cfgMinAvgProfitPct = referenceScan ? cfgQ0MinAvgProfitPct : 0.08 + strength * 0.002
    string cfgMinQualityGrade = strength >= 90 ? "A" : strength >= 60 ? "B" : "C"
    float cfgMinFinalQualityScore = strength <= 30 ? 30.0 + strength * 0.25 : strength <= 60 ? 37.5 + (strength - 30) * 0.45 : 51.0 + (strength - 60) * 0.60
    QualityConfig.new(true, true, 3, cfgQ0MinSampleYears, cfgQ0MinAvgProfitPct, cfgMinSampleYears, cfgMinWinRatePct, cfgMinAvgProfitPct, 3.50, cfgMinQualityGrade, cfgMinFinalQualityScore, 0.0)

// AutoQ keeps Q0 as a light directional reference scan while Q10+
// progressively tightens sample, win-rate, average-profit, and final-score gates.
QualityConfig qualityConfig = f_qualityConfig(isReferenceScan, qualityStrength, configuredTrainingYears, referenceMinWinRate)
enableQualityLayer = qualityConfig.enableQualityLayer
enableOverfitWarning = qualityConfig.enableOverfitWarning
recentYearsCheck = qualityConfig.recentYearsCheck
int q0MinSampleYears = qualityConfig.q0MinSampleYears
float q0MinAvgProfitPct = qualityConfig.q0MinAvgProfitPct
int effectiveMinSampleYears = qualityConfig.minSampleYears
float effectiveMinWinRatePct = qualityConfig.minWinRatePct
float effectiveMinAvgProfitPct = qualityConfig.minAvgProfitPct
effectiveMaxAvgDrawdownPct = qualityConfig.maxAvgDrawdownPct
effectiveMinQualityGrade = qualityConfig.minQualityGrade
float effectiveMinFinalQualityScore = qualityConfig.minFinalQualityScore
effectiveMinSqn = qualityConfig.minSqn
enableBiasClassifier    = input.bool(true, "Enable Seasonal Bias Classifier", group = GROUP_BIAS, tooltip = "What it controls:\n• Enables the final bias summary:\n⠀LONG, SHORT, or NO EDGE.\n• The bias summarizes the best\n⠀directional candidate instead of\n⠀showing only one zone.\n\nPractical notes:\n• Beginners should usually keep it\n⠀enabled.\n• Use the bias as orientation, not as\n⠀a standalone trade decision.")

potentialStrongThreshold    = 70
potentialWeakThreshold      = 40
showEdgeRobustness          = true
edgeRobustnessMode          = "Compact"
outlierSensitivity          = "Normal"
enableTradabilityGate       = true
showTradabilityState        = true
showRiskRewardBands = input.bool(true, "Risk/Reward Bands", group = GROUP_RISK, inline = "riskReward", tooltip = TOOLTIP_RISK_REWARD_CONTROLS)
riskRewardBandMode  = input.string("Full", "⠀⠀⠀", options = ["Minimal", "Full"], group = GROUP_RISK, inline = "riskReward", tooltip = TOOLTIP_RISK_REWARD_CONTROLS)

int volLookback = 252
int atrShortLen = 14
int atrLongLen = 50
int realizedVolLen = 20

enablePotentialAlerts = input.bool(true, "Enable Potential Alerts", group = GROUP_ALERTS, tooltip = "What it controls:\n• Enables alerts for Daily-based\n⠀potential/risk signals.\n• Alerts refer to the seasonal idea\n⠀and its remaining potential.\n\nImportant:\n• This is not a general market alert.\n• Always review alerts together with\n⠀chart context, risk, and timing.")

showFutureZones             = input.bool(true, "Future Period", group = GROUP_DISPLAY, tooltip = "What it controls:\n• Draws future seasonal periods on the\n⠀chart.\n• The scan basis always remains Daily;\n⠀lower timeframes are only for\n⠀observation or entry timing.\n\nImportant:\n• Zones are not rendered on timeframes\n⠀above 1D.")
zoneViewRange               = input.string("Horizon", "Zone View Range", options = ["Horizon", "Full Year"], group = GROUP_DISPLAY, tooltip = "What it controls:\n• Horizon shows Active zones and\n⠀Pending zones inside Scan Horizon.\n• Full Year shows all valid zones of\n⠀the current forecast year.\n\nImportant:\n• This changes visibility only.\n• Canonical dates and Evidence stay\n⠀unchanged.")
projectedZoneMode           = input.string("Long + Short", "Projected Zone Mode", options = ["Long + Short", "Best Zone", "Long Only", "Short Only"], group = GROUP_DISPLAY, tooltip = "What it controls:\n• Selects which forecast directions\n⠀are displayed.\n\nOptions:\n• Long + Short: shows both directions.\n• Best Zone: shows exactly one Primary\n⠀zone.\n• Long Only: focuses on Long zones.\n• Short Only: focuses on Short zones.\n\nPractical notes:\n• Best Zone reduces chart noise.")
futureRenderMode            = input.string("Lines + Band", "Future Render Mode", options = ["Lines Only", "Lines + Band"], group = GROUP_DISPLAY, tooltip = "What it controls:\n• Display style for the future zone.\n\nOptions:\n• Lines Only: start/end lines only.\n• Lines + Band: lines plus a colored\n⠀time window.\n\nPractical notes:\n• Lines + Band is easier to see.\n• Lines Only is more subtle.")
historicalBandColorMode     = input.string("Direction", "Historical Band Color Mode", options = ["Result", "Direction"], group = GROUP_DISPLAY, tooltip = "What it controls:\n• Color mode for historical bands.\n\nOptions:\n• Result: green/red by historical\n⠀outcome.\n• Direction: color by the direction of\n⠀the historical zone.\n\nPractical notes:\n• Result is useful for quick success\n⠀checks.\n• Direction keeps direction colors\n⠀consistent.")
labelTextSize               = input.string("Small", "Label Text", options = ["None", "Tiny", "Small", "Normal", "Large"], group = GROUP_DISPLAY, tooltip = "What it controls:\n• Font size for future, Risk / Reward,\n⠀and historical labels.\n• None hides all chart labels while\n⠀keeping lines and bands visible.\n\nPractical notes:\n• Larger sizes improve readability.\n• Smaller sizes keep the chart\n⠀cleaner.")
showMainStatsPanel          = input.bool(true, "Main Stats Panel", group = GROUP_DISPLAY, inline = "mainPanel", tooltip = TOOLTIP_MAIN_PANEL_CONTROLS)
mainPanelPosition           = input.string("Top Right", "⠀⠀⠀⠀⠀", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = GROUP_DISPLAY, inline = "mainPanel", tooltip = TOOLTIP_MAIN_PANEL_CONTROLS)
showPotentialPanel          = input.bool(true, "Potential Panel", group = GROUP_DISPLAY, inline = "potentialPanel", tooltip = TOOLTIP_POTENTIAL_CONTROLS)
potentialPanelPosition      = input.string("Bottom Right", "⠀⠀⠀⠀⠀⠀", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = GROUP_DISPLAY, inline = "potentialPanel", tooltip = TOOLTIP_POTENTIAL_CONTROLS)
showVerificationPanel       = input.bool(true, "Verification Panel", group = GROUP_DISPLAY, inline = "verificationPanel", tooltip = TOOLTIP_VERIFICATION_PANEL_CONTROLS)
verificationPanelPosition   = input.string("Bottom Left", "⠀⠀⠀⠀", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = GROUP_DISPLAY, inline = "verificationPanel", tooltip = TOOLTIP_VERIFICATION_PANEL_CONTROLS)
showHistoricalPeriods       = input.bool(true, "Historical Verification", group = GROUP_DISPLAY, inline = "historicalDisplay", tooltip = TOOLTIP_HISTORICAL_DISPLAY_CONTROLS)
historicalDisplayRows       = input.int(10, "⠀", minval = 1, maxval = 50, group = GROUP_DISPLAY, inline = "historicalDisplay", tooltip = TOOLTIP_HISTORICAL_DISPLAY_CONTROLS)
int effectiveScanYears   = lookbackYears
int effectiveMetricRows  = effectiveScanYears
int effectiveDisplayRows = math.min(historicalDisplayRows, effectiveMetricRows)
showHistoricalLabels     = input.bool(true, "Historical Labels", group = GROUP_DISPLAY, tooltip = "What it controls:\n• Shows labels on historical zones.\n• Labels contain compact values such\n⠀as profit/loss and drawdown.\n\nPractical notes:\n• Enable for analysis.\n• Disable if labels overcrowd the\n⠀chart.")

bool useLongShortMode   = projectedZoneMode == "Long + Short"
bool useBestZoneMode    = projectedZoneMode == "Best Zone"
bool useLongOnlyMode    = projectedZoneMode == "Long Only"
bool useShortOnlyMode   = projectedZoneMode == "Short Only"
bool useHorizonView     = zoneViewRange == "Horizon"
bool useFullYearView    = zoneViewRange == "Full Year"


bool isDailyChart       = timeframe.isdaily and timeframe.multiplier == 1
bool isViewTfSupported  = timeframe.in_seconds() <= timeframe.in_seconds("1D")

float atr14             = ta.atr(14)
float recentHigh50      = ta.highest(high, 50)
float recentLow50       = ta.lowest(low, 50)
float zoneTopPrepared   = recentHigh50 + atr14 * 0.25
float zoneBottomPrepared    = recentLow50 - atr14 * 0.25
color panelMutedTextColor   = color.new(color.white, 10)

int FORECAST_MAP_TRADING_DAYS       = 260
int MAX_ANCHOR_SEARCH_BARS          = 5
// Fixed structural discovery thresholds. AutoQ may filter the resulting
// segments, but it must never alter their directional state or boundaries.
float STRUCTURAL_SEGMENT_CONFIDENCE_MIN = 50.0
float STRUCTURAL_DIR_THRESHOLD_FACTOR   = 0.25
string STRUCTURAL_ALGORITHM_VERSION     = "SV2"
bool ENABLE_PHASE0_DIAGNOSTICS          = false
// The renderer can represent every canonical annual-map zone. Capacity is a
// technical pool size only and never a second visibility rule.
int MAX_CANONICAL_SEASONAL_ZONES   = 16
int MAX_VISIBLE_SEASONAL_ZONES     = MAX_CANONICAL_SEASONAL_ZONES
int MAX_HISTORICAL_RENDER_PERIODS   = 30
int COMPLETED_ZONE_FILL_TRANSPARENCY   = 95
int COMPLETED_ZONE_BORDER_TRANSPARENCY = 80

int SEG_NONE = 0
int SEG_LONG = 1
int SEG_SHORT = -1

f_isDirectionalSide(int side) =>
    side == SEG_LONG or side == SEG_SHORT
int SEG_STATUS_BLOCKED = 0
int SEG_STATUS_WEAK = 1
int SEG_STATUS_WATCH = 2
int SEG_STATUS_TRADEABLE = 3
int TIME_SOURCE_NONE = 0
int TIME_SOURCE_ACTUAL = 1
int TIME_SOURCE_PROJECTED = 2

f_tradingDayIdentity(int timestampValue) =>
    na(timestampValue) ? na : year(timestampValue, "UTC") * 10000 + month(timestampValue, "UTC") * 100 + dayofmonth(timestampValue, "UTC")

// Seasonal Date Time helper derives UTC trading-day dates for historical anchor matching.
f_seasonalDateTsFromBar(int offset) =>
    int tdTs = time_tradingday[offset]
    if not na(tdTs)
        tdTs
    else
        int t = time[offset]
        timestamp("UTC", year(t, "UTC"), month(t, "UTC"), dayofmonth(t, "UTC"), 0, 0)

f_tradingYear(int offset) =>
    year(f_seasonalDateTsFromBar(offset), "UTC")


// Central Actual Time helper returns confirmed Daily bar timestamps.
f_actualDailyTimeFromBar(int offset) =>
    int result = na
    if not na(offset) and offset >= 0 and offset <= bar_index
        result := time[offset]
    result

// Backward-compatible Chart Geometry adapter; use f_actualDailyTimeFromBar() for new code.
f_dailyChartTsFromBar(int offset) =>
    f_actualDailyTimeFromBar(offset)

// Central Market-Day helper projects Daily timestamps in either direction.
// Crypto counts calendar days; other markets skip weekends.
f_projectMarketDailyTime(int anchorTime, int dailyOffset) =>
    int dayMs = 24 * 60 * 60 * 1000
    if syminfo.type == "crypto"
        anchorTime + dailyOffset * dayMs
    else
        int direction = dailyOffset >= 0 ? 1 : -1
        int remaining = math.abs(dailyOffset)
        int projected = anchorTime
        while remaining > 0
            projected += direction * dayMs
            int dow = dayofweek(projected, "UTC")
            if dow != dayofweek.saturday and dow != dayofweek.sunday
                remaining -= 1
        projected

// Segment window normalization keeps offset-to-time conversion in one place.
f_segmentWindowTimes(int entryOffset, int exitOffset, int mapOriginTime) =>
    // Seasonal-map coordinates are always projected from the immutable
    // forecast-year origin. They never resolve through the moving current bar.
    int entryTime = not na(mapOriginTime) and not na(entryOffset) ? f_projectMarketDailyTime(mapOriginTime, entryOffset) : na
    int exitTime = not na(mapOriginTime) and not na(exitOffset) ? f_projectMarketDailyTime(mapOriginTime, exitOffset) : na
    int entryTimeSource = not na(entryTime) ? TIME_SOURCE_PROJECTED : TIME_SOURCE_NONE
    int exitTimeSource = not na(exitTime) ? TIME_SOURCE_PROJECTED : TIME_SOURCE_NONE
    [entryTime, exitTime, entryTimeSource, exitTimeSource]

// Daily entry-price lookup for selected directional risk calculations.
f_getWindowEntryPrice(int entryOffset) =>
    float result = na
    if not na(entryOffset) and entryOffset <= 0
        int barsBack = math.abs(entryOffset)
        if barsBack <= bar_index
            result := close[barsBack]
    result

f_targetTimestamp(int targetYear, int anchorMonth, int anchorDay) =>
    bool leapYear = targetYear % 4 == 0 and (targetYear % 100 != 0 or targetYear % 400 == 0)
    int monthMaxDay = anchorMonth == 2 ? (leapYear ? 29 : 28) : anchorMonth == 4 or anchorMonth == 6 or anchorMonth == 9 or anchorMonth == 11 ? 30 : 31
    int adjustedDay = math.max(1, math.min(anchorDay, monthMaxDay))
    timestamp("UTC", targetYear, anchorMonth, adjustedDay, 0, 0)

f_forecastYearOrigin(int forecastYear) =>
    int dayMs = 24 * 60 * 60 * 1000
    int origin = f_targetTimestamp(forecastYear, 1, 1)
    if syminfo.type != "crypto"
        int dow = dayofweek(origin, "UTC")
        if dow == dayofweek.saturday
            origin += 2 * dayMs
        else if dow == dayofweek.sunday
            origin += dayMs
    origin

// Historical seasonal-date matching compares target month/day against UTC trading-day dates.
findHistoricalAnchorOffset(int targetYear, int anchorMonth, int anchorDay, int maxBarsBack, int maxAnchorSearchBars) =>
    int targetTs = f_targetTimestamp(targetYear, anchorMonth, anchorDay)
    int maxDistanceMs = maxAnchorSearchBars * 24 * 60 * 60 * 1000
    int safeMaxBarsBack = math.min(maxBarsBack, 4999)
    int bestOffset = na
    int bestDistance = na
    for lookbackOffset = 0 to safeMaxBarsBack
        int candidateTs = f_seasonalDateTsFromBar(lookbackOffset)
        if not na(candidateTs)
            int distance = math.abs(candidateTs - targetTs)
            if distance <= maxDistanceMs
                if na(bestDistance) or distance < bestDistance
                    bestDistance := distance
                    bestOffset := lookbackOffset
    bestOffset


f_periodHighLow(int exitOffset, int entryOffset) =>
    float lo = na
    float hi = na
    if exitOffset >= 0 and entryOffset >= 0 and exitOffset <= entryOffset
        for p = exitOffset to entryOffset
            lo := na(lo) ? low[p] : math.min(lo, low[p])
            hi := na(hi) ? high[p] : math.max(hi, high[p])
    [lo, hi]


f_encInt(int value) =>
    na(value) ? "na" : str.tostring(value)

f_encFloat(float value) =>
    na(value) ? "na" : str.tostring(value, format.mintick)

f_encPct(float value) =>
    na(value) ? "na" : str.tostring(value, "#.####")

f_parseFloat(string value) =>
    value == "na" ? na : str.tonumber(value)

f_parseInt(string value) =>
    value == "na" ? na : int(str.tonumber(value))

f_percentRank(float value, int len) =>
    float result = na
    if not na(value) and len > 0
        int valid = 0
        int belowOrEqual = 0
        for i = 0 to len - 1
            float historicalValue = value[i]
            if not na(historicalValue)
                valid += 1
                if historicalValue <= value
                    belowOrEqual += 1
        result := valid > 0 ? belowOrEqual / valid * 100.0 : na
    result

f_volPercentileFit(float pct) =>
    na(pct) ? na : pct < 10 ? 35.0 : pct < 25 ? 60.0 : pct <= 75 ? 90.0 : pct <= 90 ? 75.0 : 45.0

f_atrRatioFit(float ratio) =>
    na(ratio) ? na : ratio < 0.80 ? 55.0 : ratio <= 1.20 ? 90.0 : ratio <= 1.60 ? 80.0 : 40.0

f_dailyRangeUsedFit(float rangeUsed) =>
    na(rangeUsed) ? na : rangeUsed < 0.50 ? 65.0 : rangeUsed <= 1.00 ? 90.0 : rangeUsed <= 1.50 ? 75.0 : 35.0

f_volRegimeCode(float atrPct, float rvPct, float atrRatio, float dailyRangeUsed) =>
    int result = na
    if not na(atrPct) and not na(rvPct) and not na(atrRatio) and not na(dailyRangeUsed)
        result := atrPct > 90 or rvPct > 90 or atrRatio > 1.60 or dailyRangeUsed > 1.50 ? 4 : atrRatio > 1.20 or atrPct > 75 or rvPct > 75 ? 3 : atrRatio < 0.80 or atrPct < 25 or rvPct < 25 ? 1 : 2
    result

f_calcVolatilityFitTuple(int atrShortLen, int atrLongLen, int realizedVolLen, int volLookback) =>
    float atrShort = ta.atr(atrShortLen)
    float atrLong = ta.atr(atrLongLen)
    float atrPct = f_percentRank(atrShort, volLookback)
    float logRet = close[1] > 0 and close > 0 ? math.log(close / close[1]) : na
    float realizedVol = ta.stdev(logRet, realizedVolLen) * math.sqrt(252.0) * 100.0
    float rvPct = f_percentRank(realizedVol, volLookback)
    float atrRatio = atrLong > 0 ? atrShort / atrLong : na
    float dailyRangeUsed = atrShort > 0 ? (high - low) / atrShort : na
    float atrPctFit = f_volPercentileFit(atrPct)
    float rvPctFit = f_volPercentileFit(rvPct)
    float atrRatioFit = f_atrRatioFit(atrRatio)
    float rangeUsedFit = f_dailyRangeUsedFit(dailyRangeUsed)
    float volFitScore = not na(atrPctFit) and not na(rvPctFit) and not na(atrRatioFit) and not na(rangeUsedFit) ? atrPctFit * 0.30 + rvPctFit * 0.25 + atrRatioFit * 0.25 + rangeUsedFit * 0.20 : na
    int regimeCode = f_volRegimeCode(atrPct, rvPct, atrRatio, dailyRangeUsed)
    [volFitScore, regimeCode]

f_arrayMedianFloat(array<float> values) =>
    int n = array.size(values)
    float result = na
    if n > 0
        array<float> sorted = array.copy(values)
        array.sort(sorted, order.ascending)
        result := n % 2 == 1 ? array.get(sorted, int(math.floor(n * 0.5))) : (array.get(sorted, n / 2 - 1) + array.get(sorted, n / 2)) * 0.5
    result

f_arrayPercentileFloat(array<float> values, float percentile) =>
    int n = array.size(values)
    float result = na
    if n > 0
        array<float> sorted = array.copy(values)
        array.sort(sorted, order.ascending)
        float p = math.max(0.0, math.min(percentile, 100.0))
        float rank = (p / 100.0) * (n - 1)
        int loIdx = int(math.floor(rank))
        int hiIdx = int(math.ceil(rank))
        float loValue = array.get(sorted, loIdx)
        float hiValue = array.get(sorted, hiIdx)
        result := loValue + (hiValue - loValue) * (rank - loIdx)
    result

f_arrayMaxFloat(array<float> values) =>
    int n = array.size(values)
    float result = na
    if n > 0
        for i = 0 to n - 1
            float value = array.get(values, i)
            result := na(result) ? value : math.max(result, value)
    result

f_arrayAvgFloat(array<float> values) =>
    int n = array.size(values)
    float result = na
    if n > 0
        float sum = 0.0
        for i = 0 to n - 1
            sum += array.get(values, i)
        result := sum / n
    result

f_arrayMinFloat(array<float> values) =>
    int n = array.size(values)
    float result = na
    if n > 0
        for i = 0 to n - 1
            float value = array.get(values, i)
            result := na(result) ? value : math.min(result, value)
    result

f_arrayAvgWithoutBestWorst(array<float> values) =>
    int n = array.size(values)
    float result = f_arrayAvgFloat(values)
    if n >= 5
        float sum = 0.0
        float minValue = f_arrayMinFloat(values)
        float maxValue = f_arrayMaxFloat(values)
        bool removedMin = false
        bool removedMax = false
        int kept = 0
        for i = 0 to n - 1
            float value = array.get(values, i)
            bool removeThis = false
            if not removedMin and value == minValue
                removeThis := true
                removedMin := true
            else if not removedMax and value == maxValue
                removeThis := true
                removedMax := true
            if not removeThis
                sum += value
                kept += 1
        result := kept > 0 ? sum / kept : result
    result

f_positiveRate(array<float> values) =>
    int n = array.size(values)
    float result = na
    if n > 0
        int positives = 0
        for i = 0 to n - 1
            positives += array.get(values, i) > 0 ? 1 : 0
        result := positives / n * 100.0
    result

f_lastNAvg(array<float> values, int count) =>
    int n = array.size(values)
    float result = na
    int take = math.min(n, math.max(count, 0))
    if take > 0
        float sum = 0.0
        for i = 0 to take - 1
            sum += array.get(values, i)
        result := sum / take
    result

f_scoreText(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))


f_gapComponent(float gapPct) =>
    float sens = outlierSensitivity == "High" ? 0.75 : outlierSensitivity == "Low" ? 1.35 : 1.0
    na(gapPct) ? na : gapPct <= 20.0 * sens ? 100.0 : gapPct <= 45.0 * sens ? 70.0 : gapPct <= 80.0 * sens ? 35.0 : 10.0

f_recentComponent(float lastAvg, float fullAvg) =>
    float result = na
    if not na(lastAvg) and not na(fullAvg) and math.abs(fullAvg) > 0.0001
        float ratio = lastAvg / fullAvg
        result := ratio < 0 ? 10.0 : ratio >= 0.8 and ratio <= 1.3 ? 100.0 : ratio >= 0.5 ? 70.0 : 35.0
    result

f_edgeRobustnessMetrics(array<float> values) =>
    int validTrades = array.size(values)
    float avgReturn = f_arrayAvgFloat(values)
    float medianReturn = f_arrayMedianFloat(values)
    float avgWithoutBestWorst = f_arrayAvgWithoutBestWorst(values)
    float bestReturn = f_arrayMaxFloat(values)
    float worstReturn = f_arrayMinFloat(values)
    float positiveRate = f_positiveRate(values)
    float last5Avg = f_lastNAvg(values, 5)
    float fullAvg = avgReturn
    float medianVsAvgGap = not na(avgReturn) and not na(medianReturn) ? math.abs(avgReturn - medianReturn) : na
    float outlierImpact = not na(avgReturn) and not na(avgWithoutBestWorst) ? math.abs(avgReturn - avgWithoutBestWorst) : na
    float medianGapPct = not na(medianVsAvgGap) ? medianVsAvgGap / math.max(math.abs(avgReturn), 0.0001) * 100.0 : na
    float outlierImpactPct = not na(outlierImpact) ? outlierImpact / math.max(math.abs(avgReturn), 0.0001) * 100.0 : na
    float recentStability = not na(last5Avg) and not na(fullAvg) and math.abs(fullAvg) > 0.0001 ? last5Avg / fullAvg : na
    float positiveComponent = na(positiveRate) ? na : positiveRate >= 80 ? 100.0 : positiveRate >= 70 ? 80.0 : positiveRate >= 60 ? 60.0 : positiveRate >= 50 ? 40.0 : 20.0
    float medianComponent = f_gapComponent(medianGapPct)
    float outlierComponent = f_gapComponent(outlierImpactPct)
    float recentComponent = f_recentComponent(last5Avg, fullAvg)
    float robustnessScore = not na(positiveComponent) and not na(medianComponent) and not na(outlierComponent) and not na(recentComponent) ? positiveComponent * 0.30 + medianComponent * 0.25 + outlierComponent * 0.25 + recentComponent * 0.20 : na
    float largestAbsReturn = not na(bestReturn) and not na(worstReturn) ? math.max(math.abs(bestReturn), math.abs(worstReturn)) : na
    bool oneYearDominates = validTrades >= 3 and not na(largestAbsReturn) and not na(avgReturn) and largestAbsReturn > math.abs(avgReturn) * validTrades * 0.55
    string outlierRisk = na(robustnessScore) ? "n/a" : robustnessScore < 35 or oneYearDominates ? "Extreme" : robustnessScore >= 75 and nz(outlierImpactPct, 100.0) <= 25 ? "Low" : robustnessScore >= 55 ? "Medium" : "High"
    string stabilityLabel = na(recentStability) ? "n/a" : recentStability < 0 ? "Diverging" : recentStability >= 0.8 and recentStability <= 1.3 ? "Stable" : recentStability >= 0.5 ? "Softer" : "Weak"
    [validTrades, avgReturn, medianReturn, avgWithoutBestWorst, bestReturn, worstReturn, positiveRate, last5Avg, fullAvg, medianVsAvgGap, outlierImpact, recentStability, robustnessScore, outlierRisk, stabilityLabel]


f_clearDirectionalVerificationArrays(array<int> years, array<int> entryTimes, array<int> exitTimes, array<int> bandEndTimes, array<float> profits, array<float> drawdowns, array<float> lows, array<float> highs, array<float> entryPrices, array<float> exitPrices, array<float> maePcts, array<float> mfePcts) =>
    array.clear(years), array.clear(entryTimes), array.clear(exitTimes), array.clear(bandEndTimes), array.clear(profits), array.clear(drawdowns), array.clear(lows), array.clear(highs), array.clear(entryPrices), array.clear(exitPrices), array.clear(maePcts), array.clear(mfePcts)
    0

f_decodeDirectionalPayload(string payload, array<int> years, array<int> entryTimes, array<int> exitTimes, array<int> bandEndTimes, array<float> profits, array<float> drawdowns, array<float> lows, array<float> highs, array<float> entryPrices, array<float> exitPrices, array<float> maePcts, array<float> mfePcts) =>
    f_clearDirectionalVerificationArrays(years, entryTimes, exitTimes, bandEndTimes, profits, drawdowns, lows, highs, entryPrices, exitPrices, maePcts, mfePcts)
    if not na(payload) and str.length(payload) > 0
        array<string> rows = str.split(payload, ";")
        for i = 0 to array.size(rows)-1
            array<string> f = str.split(array.get(rows,i), "|")
            if array.size(f) >= 11
                int y = f_parseInt(array.get(f,0))
                int t1 = f_parseInt(array.get(f,1))
                int t2 = f_parseInt(array.get(f,2))
                float ep = f_parseFloat(array.get(f,3))
                float xp = f_parseFloat(array.get(f,4))
                float lo = f_parseFloat(array.get(f,5))
                float hi = f_parseFloat(array.get(f,6))
                float pr = f_parseFloat(array.get(f,7))
                float mae = f_parseFloat(array.get(f,8))
                float mfe = f_parseFloat(array.get(f,9))
                int tb = f_parseInt(array.get(f,10))
                if not na(y) and not na(t1) and not na(t2) and not na(tb) and not na(ep) and not na(xp) and not na(pr) and not na(mae) and not na(mfe) and not na(lo) and not na(hi)
                    array.push(years,y), array.push(entryTimes,t1), array.push(exitTimes,t2), array.push(bandEndTimes,tb), array.push(profits,pr), array.push(drawdowns,mae), array.push(lows,lo), array.push(highs,hi), array.push(entryPrices,ep), array.push(exitPrices,xp), array.push(maePcts,mae), array.push(mfePcts,mfe)
            else if array.size(f) >= 8
                int y = f_parseInt(array.get(f,0))
                int t1 = f_parseInt(array.get(f,1))
                int t2 = f_parseInt(array.get(f,2))
                int tb = f_parseInt(array.get(f,3))
                float pr = f_parseFloat(array.get(f,4))
                float dd = f_parseFloat(array.get(f,5))
                float lo = f_parseFloat(array.get(f,6))
                float hi = f_parseFloat(array.get(f,7))
                float mae = math.abs(dd)
                if not na(y) and not na(t1) and not na(t2) and not na(tb) and not na(pr) and not na(dd) and not na(lo) and not na(hi)
                    array.push(years,y), array.push(entryTimes,t1), array.push(exitTimes,t2), array.push(bandEndTimes,tb), array.push(profits,pr), array.push(drawdowns,dd), array.push(lows,lo), array.push(highs,hi), array.push(entryPrices,na), array.push(exitPrices,na), array.push(maePcts,mae), array.push(mfePcts,na)

f_directionalMaeMfeMetrics(array<float> maePcts, array<float> mfePcts) =>
    array<float> validMaeValues = array.new_float()
    array<float> validMfeValues = array.new_float()
    int maeCount = array.size(maePcts)
    if maeCount > 0
        for i = 0 to maeCount - 1
            float value = array.get(maePcts, i)
            if not na(value)
                array.push(validMaeValues, value)
    int mfeCount = array.size(mfePcts)
    if mfeCount > 0
        for i = 0 to mfeCount - 1
            float value = array.get(mfePcts, i)
            if not na(value)
                array.push(validMfeValues, value)
    int validMaeSampleCount = array.size(validMaeValues)
    int validMfeSampleCount = array.size(validMfeValues)
    float medianMae = f_arrayMedianFloat(validMaeValues)
    float mae75 = f_arrayPercentileFloat(validMaeValues, 75.0)
    float medianMfe = f_arrayMedianFloat(validMfeValues)
    float mfe75 = f_arrayPercentileFloat(validMfeValues, 75.0)
    bool maeMetricsAvailable = validMaeSampleCount > 0 and not na(medianMae) and not na(mae75)
    bool mfeMetricsAvailable = validMfeSampleCount > 0 and not na(medianMfe) and not na(mfe75)
    [medianMae, mae75, medianMfe, mfe75, validMaeSampleCount, validMfeSampleCount, maeMetricsAvailable, mfeMetricsAvailable]

int DIR_LONG = 1
int DIR_SHORT = -1

f_directionalReturnPct(float entryPrice, float exitPrice, int direction) =>
    not na(entryPrice) and not na(exitPrice) and entryPrice > 0 and exitPrice > 0 ? direction * (exitPrice - entryPrice) / entryPrice * 100.0 : na

f_directionalMaePct(float entryPrice, float periodLow, float periodHigh, int direction) =>
    not na(entryPrice) and not na(periodLow) and not na(periodHigh) and entryPrice > 0 and periodLow > 0 and periodHigh > 0 ? direction == DIR_LONG ? math.max(0.0, (entryPrice - periodLow) / entryPrice * 100.0) : math.max(0.0, (periodHigh - entryPrice) / entryPrice * 100.0) : na

f_directionalMfePct(float entryPrice, float periodLow, float periodHigh, int direction) =>
    not na(entryPrice) and not na(periodLow) and not na(periodHigh) and entryPrice > 0 and periodLow > 0 and periodHigh > 0 ? direction == DIR_LONG ? math.max(0.0, (periodHigh - entryPrice) / entryPrice * 100.0) : math.max(0.0, (entryPrice - periodLow) / entryPrice * 100.0) : na

f_directionalRawScore(float winRatePct, float avgReturnPct, float avgMaePct, float sqn) =>
    not na(winRatePct) and not na(avgReturnPct) and not na(avgMaePct) ? winRatePct + avgReturnPct * 5.0 - avgMaePct * 2.0 + nz(sqn, 0.0) * 3.0 : na

f_wilsonLowerBound(int successes, int samples) =>
    float z = 1.281551565545
    float result = na
    if samples > 0
        float n = samples
        float p = successes / n
        float z2 = z * z
        float denominator = 1.0 + z2 / n
        float center = p + z2 / (2.0 * n)
        float margin = z * math.sqrt((p * (1.0 - p) + z2 / (4.0 * n)) / n)
        result := (center - margin) / denominator * 100.0
    result

type DirectionalEvidence
    int samples
    int successes
    float successRate
    float wilsonLowerBound90
    float avgReturn
    float medianReturn
    float trimmedMean
    float worstReturn
    float mae75
    float maxMae
    float mfe75
    float medianMfe
    float mfeMaeRatio

type HoldoutResult
    bool enabled
    int nominalYears
    int samples
    int successes
    float successRate
    float wilsonLower
    float medianOutcome
    float mae75
    float maxMae
    float mfe75
    string depth
    string status

f_holdoutDepth(bool enabled, int samples) =>
    enabled ? samples < 3 ? "Insufficient" : samples < 5 ? "Preliminary" : "Adequate" : "Disabled"

f_directionalHoldoutStatus(bool enabled, string depth, float medianReturn, float successRate, float mfe75, float mae75) =>
    string result = "Mixed"
    if not enabled
        result := "Disabled"
    else if depth == "Insufficient"
        result := "Insufficient"
    else
        bool confirmed = not na(medianReturn) and not na(successRate) and not na(mfe75) and not na(mae75) and medianReturn > 0 and successRate >= 60.0 and mfe75 > mae75
        bool failed = not na(medianReturn) and not na(successRate) and medianReturn <= 0 and successRate < 50.0
        result := confirmed ? "Confirmed" : failed ? "Failed" : "Mixed"
    result

f_holdoutResult(int nominalYears, DirectionalEvidence directionalEvidence) =>
    bool enabled = nominalYears > 0
    int samples = directionalEvidence.samples
    string depth = f_holdoutDepth(enabled, samples)
    string status = f_directionalHoldoutStatus(enabled, depth, directionalEvidence.medianReturn, directionalEvidence.successRate, directionalEvidence.mfe75, directionalEvidence.mae75)
    HoldoutResult.new(enabled, nominalYears, samples, directionalEvidence.successes, directionalEvidence.successRate, directionalEvidence.wilsonLowerBound90, directionalEvidence.medianReturn, directionalEvidence.mae75, directionalEvidence.maxMae, directionalEvidence.mfe75, depth, status)

type EvidenceSnapshot
    int trainingYears
    int trainingSamples
    int trainingSuccesses
    float trainingWilsonLower
    float trainingMedianOutcome
    float worstOutcome
    float mae75
    float maxMae
    float mfe75
    float mfeMaeRatio
    string plateauGrade
    int holdoutYears
    int holdoutSamples
    int holdoutSuccesses
    float holdoutWilsonLower
    string holdoutDepth
    string holdoutStatus

f_evidenceSnapshot(int trainingYears, int trainingSamples, int trainingSuccesses, float trainingWilsonLower, float trainingMedianOutcome, float worstOutcome, float mae75, float maxMae, float mfe75, float mfeMaeRatio, string plateauGrade, int holdoutYears, int holdoutSamples, int holdoutSuccesses, float holdoutWilsonLower, string holdoutDepth, string holdoutStatus) =>
    EvidenceSnapshot.new(trainingYears, trainingSamples, trainingSuccesses, trainingWilsonLower, trainingMedianOutcome, worstOutcome, mae75, maxMae, mfe75, mfeMaeRatio, plateauGrade, holdoutYears, holdoutSamples, holdoutSuccesses, holdoutWilsonLower, holdoutDepth, holdoutStatus)

f_evidenceSnapshotNone() =>
    f_evidenceSnapshot(0, 0, 0, na, na, na, na, na, na, na, "Unknown", 0, 0, 0, na, "Disabled", "Disabled")

f_evidenceSnapshotFromResults(int trainingYears, DirectionalEvidence directionalEvidence, string plateauGrade, HoldoutResult holdoutResult) =>
    f_evidenceSnapshot(trainingYears, directionalEvidence.samples, directionalEvidence.successes, directionalEvidence.wilsonLowerBound90, directionalEvidence.medianReturn, directionalEvidence.worstReturn, directionalEvidence.mae75, directionalEvidence.maxMae, directionalEvidence.mfe75, directionalEvidence.mfeMaeRatio, plateauGrade, holdoutResult.nominalYears, holdoutResult.samples, holdoutResult.successes, holdoutResult.wilsonLower, holdoutResult.depth, holdoutResult.status)

// A vintage contains discovery inputs only. Forecast year is an explicit model
// coordinate; no current price, volatility, bar index, or execution state enters
// either the vintage ID or a canonical zone ID.
type SeasonalModelVintage
    bool valid
    string id
    string symbolIdentity
    int forecastYear
    int lookbackYears
    int trainingYears
    int holdoutYears

f_seasonalModelVintageId(string symbolIdentity, int forecastYear, int lookbackYearCount, int trainingYearCount, int holdoutYearCount) =>
    bool valid = str.length(symbolIdentity) > 0 and forecastYear > 0 and lookbackYearCount > 0 and trainingYearCount > 0 and holdoutYearCount >= 0
    // Eligibility inputs (Quality Strength and Minimum Winrate) are excluded:
    // they may select a zone, but cannot define its structural identity.
    valid ? symbolIdentity + "|FY" + str.tostring(forecastYear) + "|LB" + str.tostring(lookbackYearCount) + "|TR" + str.tostring(trainingYearCount) + "|HO" + str.tostring(holdoutYearCount) + "|MIN" + str.tostring(minTradeDurationDays) + "|" + STRUCTURAL_ALGORITHM_VERSION : ""

f_seasonalModelVintage(string symbolIdentity, int forecastYear, int lookbackYearCount, int trainingYearCount, int holdoutYearCount) =>
    string vintageId = f_seasonalModelVintageId(symbolIdentity, forecastYear, lookbackYearCount, trainingYearCount, holdoutYearCount)
    SeasonalModelVintage.new(str.length(vintageId) > 0, vintageId, symbolIdentity, forecastYear, lookbackYearCount, trainingYearCount, holdoutYearCount)

f_seasonalZoneId(string modelVintageId, int side, int canonicalEntryTime, int canonicalExitTime) =>
    bool valid = str.length(modelVintageId) > 0 and f_isDirectionalSide(side) and not na(canonicalEntryTime) and not na(canonicalExitTime) and canonicalEntryTime < canonicalExitTime
    string sideKey = side == SEG_LONG ? "L" : side == SEG_SHORT ? "S" : "N"
    valid ? modelVintageId + "|" + sideKey + "|" + str.tostring(canonicalEntryTime) + "|" + str.tostring(canonicalExitTime) : ""

// Immutable historical authority for one published seasonal window. Dynamic
// entry price, lifecycle, Potential, RR, invalidation, ATR, and render geometry
// deliberately remain outside this type.
type SeasonalZone
    bool valid
    string zoneId
    string modelVintageId
    int side
    int canonicalEntryTime
    int canonicalExitTime
    float score
    string verificationPayload
    string plateauGrade
    int plateauNeighborCount
    float plateauMinRatio
    float plateauAvgRatio
    int plateauWeakCount
    int winningTrades
    int validTrades
    float winRate
    float avgProfit
    float avgDrawdown
    float sqn
    int referenceSamples
    int referenceSuccesses
    float referenceWinRate
    float referenceAvgReturn
    EvidenceSnapshot evidence

f_seasonalZone(SeasonalModelVintage vintage, int side, int canonicalEntryTime, int canonicalExitTime, float score, string verificationPayload, string plateauGrade, int plateauNeighborCount, float plateauMinRatio, float plateauAvgRatio, int plateauWeakCount, int winningTrades, int validTrades, float winRate, float avgProfit, float avgDrawdown, float sqn, int referenceSamples, int referenceSuccesses, float referenceWinRate, float referenceAvgReturn, EvidenceSnapshot evidence) =>
    string zoneId = f_seasonalZoneId(vintage.id, side, canonicalEntryTime, canonicalExitTime)
    bool valid = vintage.valid and str.length(zoneId) > 0 and not na(score) and validTrades > 0 and referenceSamples > 0 and evidence.trainingSamples > 0
    SeasonalZone.new(valid, valid ? zoneId : "", valid ? vintage.id : "", valid ? side : SEG_NONE, valid ? canonicalEntryTime : na, valid ? canonicalExitTime : na, valid ? score : na, valid ? verificationPayload : "", valid ? plateauGrade : "Unknown", valid ? plateauNeighborCount : 0, valid ? plateauMinRatio : na, valid ? plateauAvgRatio : na, valid ? plateauWeakCount : 0, valid ? winningTrades : 0, valid ? validTrades : 0, valid ? winRate : na, valid ? avgProfit : na, valid ? avgDrawdown : na, valid ? sqn : na, valid ? referenceSamples : 0, valid ? referenceSuccesses : 0, valid ? referenceWinRate : na, valid ? referenceAvgReturn : na, valid ? evidence : f_evidenceSnapshotNone())

f_seasonalZoneNone() =>
    SeasonalZone.new(false, "", "", SEG_NONE, na, na, na, "", "Unknown", 0, na, na, 0, 0, 0, na, na, na, na, 0, 0, na, na, f_evidenceSnapshotNone())

f_seasonalZoneInvariant(SeasonalZone zone) =>
    string expectedId = f_seasonalZoneId(zone.modelVintageId, zone.side, zone.canonicalEntryTime, zone.canonicalExitTime)
    zone.valid and str.length(expectedId) > 0 and zone.zoneId == expectedId and zone.validTrades > 0 and zone.referenceSamples > 0 and zone.evidence.trainingSamples > 0

type ZoneEligibilityResult
    bool eligible
    string reasonCode

f_zoneBaselineEligibility(SeasonalZone zone) =>
    bool structuralValid = f_seasonalZoneInvariant(zone) and f_isDirectionalSide(zone.side) and not na(zone.canonicalEntryTime) and not na(zone.canonicalExitTime) and zone.canonicalEntryTime < zone.canonicalExitTime
    int minimumSamples = math.min(lookbackYears, 6)
    bool evidenceValid = zone.referenceSamples > 0 and zone.referenceSuccesses >= 0 and zone.referenceSuccesses <= zone.referenceSamples and not na(zone.referenceWinRate) and not na(zone.referenceAvgReturn)
    bool enoughSamples = evidenceValid and zone.referenceSamples >= minimumSamples
    bool winratePass = enoughSamples and zone.referenceWinRate >= referenceMinWinRate
    bool avgReturnPass = winratePass and zone.referenceAvgReturn >= q0MinAvgProfitPct
    string reason = not structuralValid ? "NO_STRUCTURAL_ZONE" : not evidenceValid or not enoughSamples ? "INSUFFICIENT_SAMPLES" : not winratePass ? "WINRATE_BELOW_MIN" : not avgReturnPass ? "AVG_RETURN_BELOW_MIN" : "ELIGIBLE"
    ZoneEligibilityResult.new(structuralValid and evidenceValid and enoughSamples and winratePass and avgReturnPass, reason)

f_zoneEligibilityForQuality(SeasonalZone zone, int strength, bool qualityEligible) =>
    ZoneEligibilityResult baseline = f_zoneBaselineEligibility(zone)
    EvidenceSnapshot evidence = zone.evidence
    int exploreSamples = int(math.ceil(math.min(configuredTrainingYears, 6) * 0.70))
    bool sampleConfidencePass = evidence.trainingSamples >= exploreSamples and nz(evidence.trainingWilsonLower, 0.0) >= 35.0
    bool stabilityPass = not na(evidence.trainingMedianOutcome) and evidence.trainingMedianOutcome > 0
    bool explorePass = sampleConfidencePass and stabilityPass
    bool reviewPass = strength < 30 or qualityEligible
    bool plateauPass = strength < 60 or evidence.plateauGrade != "Reject"
    bool holdoutPass = strength < 60 or not (evidence.holdoutDepth == "Adequate" and evidence.holdoutStatus == "Failed")
    bool eligible = baseline.eligible and (strength == 0 or explorePass and reviewPass and plateauPass and holdoutPass)
    string reason = not baseline.eligible ? baseline.reasonCode : strength == 0 ? "ELIGIBLE" : not sampleConfidencePass ? "SAMPLE_CONFIDENCE" : not stabilityPass ? "WEAK_STABILITY" : not reviewPass ? "QUALITY_GRADE" : not plateauPass ? "PLATEAU_REJECT" : not holdoutPass ? "HOLDOUT_FAILED" : "ELIGIBLE"
    ZoneEligibilityResult.new(eligible, reason)

type OperationalTradeWindow
    bool valid
    string sourceZoneId
    int entryTime
    int exitTime
    string entryReason
    string exitReason

f_buildOperationalTradeWindow(SeasonalZone zone, int maxDurationDays) =>
    int cappedExit = zone.valid ? f_projectMarketDailyTime(zone.canonicalEntryTime, maxDurationDays) : na
    int tradeExit = zone.valid ? math.min(zone.canonicalExitTime, cappedExit) : na
    bool valid = zone.valid and maxDurationDays > 0 and tradeExit > zone.canonicalEntryTime
    string exitReason = valid and tradeExit < zone.canonicalExitTime ? "MAX_DURATION" : valid ? "ZONE_EXIT" : "NONE"
    OperationalTradeWindow.new(valid, valid ? zone.zoneId : "", valid ? zone.canonicalEntryTime : na, valid ? tradeExit : na, valid ? "ZONE_ENTRY" : "NONE", exitReason)

f_operationalTradeWindowNone() =>
    OperationalTradeWindow.new(false, "", na, na, "NONE", "NONE")

type ZoneDynamicContext
    bool valid
    string zoneId
    string lifecycle
    float currentDailyClose
    float entryPrice
    float currentMove
    float moveUsed
    float remainingPotential
    float medianMae
    float medianMfe
    float mae75
    float mfe75
    string invalidation
    float seasonalRR
    float volatilityFit
    int volatilityRegime
    float potentialScore
    string tradeability

f_zoneDynamicContext(SeasonalZone zone, OperationalTradeWindow tradeWindow, int currentDailyTime, float currentDailyClose, float entryPrice, float currentMove, float moveUsed, float remainingPotential, float medianMae, float medianMfe, float mae75, float mfe75, string invalidation, float seasonalRR, float volatilityFit, int volatilityRegime, float potentialScore, string tradeability) =>
    bool valid = zone.valid and tradeWindow.valid and tradeWindow.sourceZoneId == zone.zoneId
    string lifecycle = not valid or na(currentDailyTime) ? "NONE" : currentDailyTime < zone.canonicalEntryTime ? "PENDING" : currentDailyTime <= zone.canonicalExitTime ? "ACTIVE" : "COMPLETED"
    ZoneDynamicContext.new(valid, valid ? zone.zoneId : "", lifecycle, currentDailyClose, entryPrice, currentMove, moveUsed, remainingPotential, medianMae, medianMfe, mae75, mfe75, invalidation, seasonalRR, volatilityFit, volatilityRegime, potentialScore, tradeability)

f_zoneDynamicContextNone() =>
    ZoneDynamicContext.new(false, "", "NONE", na, na, na, na, na, na, na, na, na, "n/a", na, na, 0, na, "n/a")

f_directionalEvidence(array<int> anchorOffsets, int entryOffset, int exitOffset, int direction) =>
    array<float> returns = array.new_float()
    array<float> maes = array.new_float()
    array<float> mfes = array.new_float()
    int successes = 0
    if array.size(anchorOffsets) > 0
        for yearIdx = 0 to array.size(anchorOffsets) - 1
            int anchorOffset = array.get(anchorOffsets, yearIdx)
            if not na(anchorOffset) and not na(entryOffset) and not na(exitOffset)
                int historicalEntryOffset = anchorOffset - entryOffset
                int historicalExitOffset = anchorOffset - exitOffset
                bool validOffsets = historicalEntryOffset >= 0 and historicalEntryOffset <= bar_index and historicalExitOffset >= 0 and historicalExitOffset <= bar_index and historicalExitOffset < historicalEntryOffset
                if validOffsets
                    float entryPrice = close[historicalEntryOffset]
                    float exitPrice = close[historicalExitOffset]
                    if not na(entryPrice) and not na(exitPrice) and entryPrice > 0 and exitPrice > 0
                        [periodLowest, periodHighest] = f_periodHighLow(historicalExitOffset, historicalEntryOffset)
                        if not na(periodLowest) and not na(periodHighest) and periodLowest > 0 and periodHighest > 0
                            float ret = f_directionalReturnPct(entryPrice, exitPrice, direction)
                            float mae = f_directionalMaePct(entryPrice, periodLowest, periodHighest, direction)
                            float mfe = f_directionalMfePct(entryPrice, periodLowest, periodHighest, direction)
                            if not na(ret) and not na(mae) and not na(mfe)
                                array.push(returns, ret)
                                array.push(maes, mae)
                                array.push(mfes, mfe)
                                successes += ret > 0 ? 1 : 0
    int samples = array.size(returns)
    float successRate = samples > 0 ? successes / samples * 100.0 : na
    float wilsonLowerBound90 = f_wilsonLowerBound(successes, samples)
    float avgReturn = f_arrayAvgFloat(returns)
    float medianReturn = f_arrayMedianFloat(returns)
    float trimmedMean = f_arrayAvgWithoutBestWorst(returns)
    float worstReturn = f_arrayMinFloat(returns)
    float mae75 = f_arrayPercentileFloat(maes, 75.0)
    float maxMae = f_arrayMaxFloat(maes)
    float mfe75 = f_arrayPercentileFloat(mfes, 75.0)
    float medianMfe = f_arrayMedianFloat(mfes)
    float mfeMaeRatio = not na(mfe75) and not na(mae75) and mae75 > 0 ? mfe75 / mae75 : na
    DirectionalEvidence.new(samples, successes, successRate, wilsonLowerBound90, avgReturn, medianReturn, trimmedMean, worstReturn, mae75, maxMae, mfe75, medianMfe, mfeMaeRatio)

// Directional verification reuses the exact anchors already resolved for Discovery.
// It must never repeat the expensive calendar search for the same scan generation.
f_buildDirectionalVerificationPayload(array<int> anchorOffsets, int entryOffset, int exitOffset, bool isLong, int maxMetricRows) =>
    string payload = ""
    if na(entryOffset) or na(exitOffset)
        payload
    else
        int direction = isLong ? DIR_LONG : DIR_SHORT
        int cnt = 0
        for anchorIdx = 0 to array.size(anchorOffsets) - 1
            if cnt < maxMetricRows
                int o = array.get(anchorOffsets, anchorIdx)
                if not na(o)
                    int y = year(f_seasonalDateTsFromBar(o), "UTC")
                    int e = o - entryOffset
                    int x = o - exitOffset
                    if e >= 0 and x >=0 and x < e and e <= bar_index and x <= bar_index
                        float ep = close[e], xp = close[x]
                        [lo, hi] = f_periodHighLow(x,e)
                        if not na(ep) and not na(xp) and ep > 0 and xp > 0 and not na(lo) and not na(hi) and lo > 0 and hi > 0
                            float p = f_directionalReturnPct(ep, xp, direction)
                            float mae = f_directionalMaePct(ep, lo, hi, direction)
                            float mfe = f_directionalMfePct(ep, lo, hi, direction)
                            int t1 = f_dailyChartTsFromBar(e), t2 = f_dailyChartTsFromBar(x), tb = x > 0 ? f_dailyChartTsFromBar(x - 1) : f_projectMarketDailyTime(t2, 1)
                            string row = str.format("{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}|{9}|{10}",f_encInt(y),f_encInt(t1),f_encInt(t2),f_encFloat(ep),f_encFloat(xp),f_encFloat(lo),f_encFloat(hi),f_encPct(p),f_encPct(mae),f_encPct(mfe),f_encInt(tb))
                            payload := str.length(payload)==0 ? row : payload+";"+row
                            cnt += 1
        payload


formatSignedPct(float v) =>
    na(v) ? "-" : (v > 0 ? "+" : "") + str.tostring(v, "#.##") + "%"

formatAbsPct(float v) =>
    na(v) ? "-" : str.tostring(math.abs(v), "#.##") + "%"

formatNumber(float v) =>
    na(v) ? "-" : str.tostring(v, "#.##")

formatOffset(int v) =>
    na(v) ? "-" : v > 0 ? "D+" + str.tostring(v) : v < 0 ? "D" + str.tostring(v) : "D+0"


f_dailyAgeFromEntry(int entryTs, int anchorTs) =>
    int age = na
    int dayMs = 24 * 60 * 60 * 1000
    if not na(entryTs) and not na(anchorTs)
        if anchorTs >= entryTs
            age := 0
            int cursor = entryTs
            while cursor < anchorTs and age < 500
                cursor += dayMs
                int dow = dayofweek(cursor, "UTC")
                if syminfo.type == "crypto" or (dow != dayofweek.saturday and dow != dayofweek.sunday)
                    age += 1
    age

formatTrades(int wins, int trades) =>
    trades <= 0 ? "-" : str.tostring(wins) + "/" + str.tostring(trades)

qualityGradeToRank(string grade) =>
    grade == "A" ? 4 : grade == "B" ? 3 : grade == "C" ? 2 : 1

rankToQualityGrade(int rank) =>
    rank >= 4 ? "A" : rank >= 3 ? "B" : rank >= 2 ? "C" : "D"

int effectiveMinQualityRank = qualityGradeToRank(effectiveMinQualityGrade)



f_wilsonSampleGrade(float wilsonLower, int samples, int requiredSamples, int trainingYears) =>
    int minSamples = math.max(1, requiredSamples)
    int cSamples = math.max(1, int(math.ceil(minSamples * 0.70)))
    float coveragePct = trainingYears > 0 ? samples / trainingYears * 100.0 : na
    string grade = "D"
    if not na(wilsonLower)
        grade := samples >= minSamples and nz(coveragePct, 0.0) >= 85.0 and wilsonLower >= 60.0 ? "A" : samples >= minSamples and wilsonLower >= 50.0 ? "B" : samples >= cSamples and wilsonLower >= 35.0 ? "C" : "D"
    grade

f_sampleConfidenceGrade(float winRatePct, int validTrades, int minValidTrades, int trainingYears) =>
    int estimatedSuccesses = not na(winRatePct) and validTrades > 0 ? int(math.round(validTrades * winRatePct / 100.0)) : 0
    float wilsonLower = f_wilsonLowerBound(estimatedSuccesses, validTrades)
    f_wilsonSampleGrade(wilsonLower, validTrades, minValidTrades, trainingYears)

f_directionalSeparation(float candidateScore, float competingDirectionalScore) =>
    na(candidateScore) ? na : candidateScore - nz(competingDirectionalScore, -1000000.0)

f_directionalSeparationGrade(float separationScore) =>
    na(separationScore) ? "Blocked" : separationScore >= 15.0 ? "Strong" : separationScore >= 7.0 ? "Valid" : separationScore >= 0.0 ? "Weak" : "Blocked"

f_outlierRiskGrade(float avgReturnPct, float stdevReturnPct, float sqn, float maxPositiveReturnPct) =>
    float outlierImpact = not na(avgReturnPct) and math.abs(avgReturnPct) > 0.0001 and not na(maxPositiveReturnPct) ? maxPositiveReturnPct / math.abs(avgReturnPct) : na
    bool extremeImpact = not na(outlierImpact) and outlierImpact >= 6.0
    bool highImpact = not na(outlierImpact) and outlierImpact >= 3.5
    bool highDispersion = not na(stdevReturnPct) and not na(avgReturnPct) and math.abs(avgReturnPct) > 0.0001 and stdevReturnPct / math.abs(avgReturnPct) >= 3.0
    bool weakSqn = nz(sqn, 0.0) < 0.5
    extremeImpact or (highDispersion and weakSqn) ? "Extreme" : highImpact or weakSqn ? "High" : not na(outlierImpact) and outlierImpact <= 2.0 and nz(sqn, 0.0) >= 1.0 ? "Low" : "Medium"

f_outlierQualityGrade(string outlierRisk) =>
    outlierRisk == "Low" ? "A" : outlierRisk == "Medium" ? "B" : outlierRisk == "High" ? "C" : "D"

f_rawEdgeGrade(float score) =>
    na(score) ? "D" : score >= 80.0 ? "A" : score >= 65.0 ? "B" : score >= 50.0 ? "C" : "D"

f_separationQualityGrade(string separationGrade) =>
    separationGrade == "Strong" ? "A" : separationGrade == "Valid" ? "B" : separationGrade == "Weak" ? "C" : "D"

f_windowTradeabilityGrade(int entryOffset, int exitOffset, int duration) =>
    bool expired = not na(exitOffset) and exitOffset < 0
    bool pending = not na(entryOffset) and entryOffset > 0
    float elapsedRatio = not na(entryOffset) and not na(duration) and duration > 0 ? math.max(0.0, -entryOffset) / duration : na
    expired ? "D" : pending ? "B" : na(elapsedRatio) ? "B" : elapsedRatio <= 0.35 ? "A" : elapsedRatio <= 0.70 ? "B" : elapsedRatio <= 1.0 ? "C" : "D"

type QualityResult
    string finalGrade
    float finalScore

// QUALITY_FINAL_GRADE: combines intermediate quality grades into the final AutoQ grade.
f_finalQualityGrade(string rawEdgeGrade, string sampleGrade, string stabilityGrade, string outlierGrade, string separationGrade, string tradeabilityGrade) =>
    rankToQualityGrade(math.min(math.min(math.min(qualityGradeToRank(rawEdgeGrade), qualityGradeToRank(sampleGrade)), math.min(qualityGradeToRank(stabilityGrade), qualityGradeToRank(outlierGrade))), math.min(qualityGradeToRank(separationGrade), qualityGradeToRank(tradeabilityGrade))))

f_qualityBonus(string grade) =>
    grade == "A" ? 6.0 : grade == "B" ? 2.0 : grade == "C" ? -8.0 : -25.0

// QUALITY_FINAL_SCORE: combines raw score plus intermediate-grade bonuses into the final AutoQ score.
f_finalQualityScore(float rawScore, string sampleGrade, string stabilityGrade, string outlierGrade, string separationGrade, string tradeabilityGrade, float separationScore) =>
    float score = nz(rawScore, 0.0) + f_qualityBonus(sampleGrade) + f_qualityBonus(stabilityGrade) + f_qualityBonus(outlierGrade) + f_qualityBonus(separationGrade) + f_qualityBonus(tradeabilityGrade)
    score += not na(separationScore) ? math.min(8.0, math.max(-12.0, separationScore * 0.20)) : -12.0
    math.max(0.0, math.min(100.0, score))

f_qualityResult(string rawEdgeGrade, float rawScore, string sampleGrade, string stabilityGrade, string outlierGrade, string separationGrade, string tradeabilityGrade, float separationScore) =>
    string finalGrade = f_finalQualityGrade(rawEdgeGrade, sampleGrade, stabilityGrade, outlierGrade, separationGrade, tradeabilityGrade)
    float finalScore = f_finalQualityScore(rawScore, sampleGrade, stabilityGrade, outlierGrade, separationGrade, tradeabilityGrade, separationScore)
    QualityResult.new(finalGrade, finalScore)

f_directionalCandidateQuality(float rawScore, float winRatePct, int validTrades, int minValidTrades, float avgReturnPct, float sqn, float maxPositiveReturnPct, int entryOffset, int exitOffset, int duration, float competingDirectionalScore) =>
    // QUALITY_INTERMEDIATE: sample, separation, outlier/stability and tradeability feed final grade/score.
    string sampleGrade = f_sampleConfidenceGrade(winRatePct, validTrades, minValidTrades, configuredTrainingYears)
    float separationScore = f_directionalSeparation(rawScore, competingDirectionalScore)
    string separationQuality = f_separationQualityGrade(f_directionalSeparationGrade(separationScore))
    string outlierQuality = f_outlierQualityGrade(f_outlierRiskGrade(avgReturnPct, na, sqn, maxPositiveReturnPct))
    string tradeabilityQuality = f_windowTradeabilityGrade(entryOffset, exitOffset, duration)
    QualityResult finalQuality = f_qualityResult(f_rawEdgeGrade(rawScore), rawScore, sampleGrade, "B", outlierQuality, separationQuality, tradeabilityQuality, separationScore)
    [finalQuality.finalGrade, finalQuality.finalScore]


f_directionalDistributionQuality(array<int> anchorOffsets, int entryOffset, int exitOffset, bool isShort, float sampleCoveragePct, int recentYearsN) =>
    array<float> profits = array.new_float()
    int direction = isShort ? DIR_SHORT : DIR_LONG
    int recentValid = 0
    int recentWins = 0
    for yearIdx = 0 to array.size(anchorOffsets) - 1
        int o = array.get(anchorOffsets, yearIdx)
        int e = na(o) ? na : o - entryOffset
        int x = na(o) ? na : o - exitOffset
        if not na(e) and not na(x) and e >= 0 and x >= 0 and x <= e and e < bar_index and x < bar_index
            float ep = close[e]
            float xp = close[x]
            if not na(ep) and not na(xp) and ep > 0 and xp > 0
                float p = f_directionalReturnPct(ep, xp, direction)
                array.push(profits, p)
                if yearIdx < recentYearsN
                    recentValid += 1
                    if p > 0
                        recentWins += 1

    float recentWinRatePct = na
    float medianProfitPct = na
    float outlierImpactPct = na
    bool overfitWarning = false
    string distributionQualityGrade = "D"

    if array.size(profits) > 0
        array.sort(profits, order.ascending)
        int n = array.size(profits)
        medianProfitPct := n % 2 == 1 ? array.get(profits, int(math.floor(n * 0.5))) : (array.get(profits, n / 2 - 1) + array.get(profits, n / 2)) * 0.5
        float bestY = array.get(profits, n - 1)
        float sumAll = 0.0
        for i = 0 to n - 1
            sumAll += array.get(profits, i)
        float avgAll = sumAll / n
        float avgEx = n > 1 ? (sumAll - bestY) / (n - 1) : avgAll
        outlierImpactPct := avgAll - avgEx
        overfitWarning := enableOverfitWarning and math.abs(avgAll) > 0 and outlierImpactPct > math.abs(avgAll) * 0.5
        recentWinRatePct := recentValid > 0 ? (recentWins / recentValid) * 100.0 : na
        int r = 1
        r += nz(sampleCoveragePct) >= 60 ? 1 : 0
        r += nz(sampleCoveragePct) >= 80 ? 1 : 0
        r += nz(recentWinRatePct) >= 60 ? 1 : 0
        r += nz(recentWinRatePct) >= 70 ? 1 : 0
        r += nz(medianProfitPct) > 0 ? 1 : 0
        r += overfitWarning ? -1 : 0
        distributionQualityGrade := rankToQualityGrade(math.max(1, math.min(4, r)))

    [recentWinRatePct, medianProfitPct, outlierImpactPct, overfitWarning, distributionQualityGrade]




f_evaluateSeasonalWindow(array<int> allAnchorOffsets, int entryOffset, int exitOffset) =>
    int validTrades = 0
    int longWinningTrades = 0
    int shortWinningTrades = 0
    float sumLongProfit = 0.0
    float sumLongProfitSq = 0.0
    float sumLongDrawdown = 0.0
    float sumLongMaxMove = 0.0
    float longMaxDrawdown = na
    float sumShortProfit = 0.0
    float sumShortProfitSq = 0.0
    float sumShortDrawdown = 0.0
    float sumShortMaxMove = 0.0
    float shortMaxDrawdown = na
    for yearIdx = 0 to array.size(allAnchorOffsets) - 1
        int historicalAnchorOffset = array.get(allAnchorOffsets, yearIdx)
        if not na(historicalAnchorOffset)
            int historicalEntryOffset = historicalAnchorOffset - entryOffset
            int historicalExitOffset = historicalAnchorOffset - exitOffset
            bool validOffsets = historicalEntryOffset >= 0 and historicalEntryOffset <= bar_index and historicalExitOffset >= 0 and historicalExitOffset <= bar_index and historicalExitOffset < historicalEntryOffset
            if validOffsets
                float entryPrice = close[historicalEntryOffset]
                float exitPrice = close[historicalExitOffset]
                if not na(entryPrice) and not na(exitPrice) and entryPrice > 0 and exitPrice > 0
                    [periodLowest, periodHighest] = f_periodHighLow(historicalExitOffset, historicalEntryOffset)
                    if not na(periodLowest) and not na(periodHighest) and periodLowest > 0 and periodHighest > 0
                        float longProfitPct = f_directionalReturnPct(entryPrice, exitPrice, DIR_LONG)
                        float longDrawdownPct = f_directionalMaePct(entryPrice, periodLowest, periodHighest, DIR_LONG)
                        float longMaxMovePct = f_directionalMfePct(entryPrice, periodLowest, periodHighest, DIR_LONG)
                        float shortProfitPct = f_directionalReturnPct(entryPrice, exitPrice, DIR_SHORT)
                        float shortDrawdownPct = f_directionalMaePct(entryPrice, periodLowest, periodHighest, DIR_SHORT)
                        float shortMaxMovePct = f_directionalMfePct(entryPrice, periodLowest, periodHighest, DIR_SHORT)
                        validTrades += 1
                        longWinningTrades += longProfitPct > 0 ? 1 : 0
                        shortWinningTrades += shortProfitPct > 0 ? 1 : 0
                        sumLongProfit += longProfitPct
                        sumLongProfitSq += longProfitPct * longProfitPct
                        sumLongDrawdown += longDrawdownPct
                        sumLongMaxMove += longMaxMovePct
                        longMaxDrawdown := na(longMaxDrawdown) ? longDrawdownPct : math.max(longMaxDrawdown, longDrawdownPct)
                        sumShortProfit += shortProfitPct
                        sumShortProfitSq += shortProfitPct * shortProfitPct
                        sumShortDrawdown += shortDrawdownPct
                        sumShortMaxMove += shortMaxMovePct
                        shortMaxDrawdown := na(shortMaxDrawdown) ? shortDrawdownPct : math.max(shortMaxDrawdown, shortDrawdownPct)
    float longWinRatePct = validTrades > 0 ? longWinningTrades / validTrades * 100.0 : na
    float shortWinRatePct = validTrades > 0 ? shortWinningTrades / validTrades * 100.0 : na
    float avgLongProfitPct = validTrades > 0 ? sumLongProfit / validTrades : na
    float avgLongDrawdownPct = validTrades > 0 ? sumLongDrawdown / validTrades : na
    float avgShortProfitPct = validTrades > 0 ? sumShortProfit / validTrades : na
    float avgShortDrawdownPct = validTrades > 0 ? sumShortDrawdown / validTrades : na
    float avgLongMaxMovePct = validTrades > 0 ? sumLongMaxMove / validTrades : na
    float avgShortMaxMovePct = validTrades > 0 ? sumShortMaxMove / validTrades : na
    float longVariance = validTrades > 0 ? (sumLongProfitSq / validTrades) - avgLongProfitPct * avgLongProfitPct : na
    float shortVariance = validTrades > 0 ? (sumShortProfitSq / validTrades) - avgShortProfitPct * avgShortProfitPct : na
    float longProfitStdev = not na(longVariance) ? math.sqrt(math.max(longVariance, 0.0)) : na
    float shortProfitStdev = not na(shortVariance) ? math.sqrt(math.max(shortVariance, 0.0)) : na
    float longSqn = not na(longProfitStdev) and longProfitStdev > 0 ? math.sqrt(validTrades) * avgLongProfitPct / longProfitStdev : na
    float shortSqn = not na(shortProfitStdev) and shortProfitStdev > 0 ? math.sqrt(validTrades) * avgShortProfitPct / shortProfitStdev : na
    float longScore = validTrades > 0 ? f_directionalRawScore(longWinRatePct, avgLongProfitPct, avgLongDrawdownPct, longSqn) : na
    float shortScore = validTrades > 0 ? f_directionalRawScore(shortWinRatePct, avgShortProfitPct, avgShortDrawdownPct, shortSqn) : na
    [validTrades, longWinningTrades, shortWinningTrades, longWinRatePct, shortWinRatePct, avgLongProfitPct, avgLongDrawdownPct, avgLongMaxMovePct, longMaxDrawdown, avgShortProfitPct, avgShortDrawdownPct, avgShortMaxMovePct, shortMaxDrawdown, longSqn, shortSqn, longScore, shortScore]

// Evaluates exactly one already-selected segment window. This is the compact
// transition point for moving validation, panels, verification, and alerts to the
// discrete Primary-Zone model instead of free all-window candidates.
f_evaluateSelectedSegment(array<int> anchorOffsets, int side, int entryOffset, int exitOffset) =>
    bool selectedValid = false
    float selectedScore = na
    string selectedQuality = "D"
    float selectedWinRate = na
    float selectedAvgProfit = na
    float selectedAvgDrawdown = na
    float selectedSqn = na
    int selectedSampleCount = 0
    int selectedWinningCount = 0
    float selectedEntryPrice = na
    string selectedVerificationPayload = ""
    int selectedDuration = not na(entryOffset) and not na(exitOffset) ? exitOffset - entryOffset : na
    bool selectedWindowOk = f_isDirectionalSide(side) and not na(entryOffset) and not na(exitOffset) and not na(selectedDuration) and selectedDuration > 0
    if selectedWindowOk
        [validTrades, longWinningTrades, shortWinningTrades, longWinRatePct, shortWinRatePct, avgLongProfitPct, avgLongDrawdownPct, avgLongMaxMovePct, _, avgShortProfitPct, avgShortDrawdownPct, avgShortMaxMovePct, _, longSqn, shortSqn, longScore, shortScore] = f_evaluateSeasonalWindow(anchorOffsets, entryOffset, exitOffset)
        if side == SEG_LONG and validTrades > 0
            // QUALITY_FLOW: longScore is raw; longGrade/longFinalScore are final; selectedQuality stores final grade.
            [longGrade, longFinalScore] = f_directionalCandidateQuality(longScore, longWinRatePct, validTrades, effectiveMinSampleYears, avgLongProfitPct, longSqn, avgLongMaxMovePct, entryOffset, exitOffset, selectedDuration, shortScore)
            bool longPassQualityStrength = qualityGradeToRank(longGrade) >= effectiveMinQualityRank and nz(longFinalScore, 0.0) >= effectiveMinFinalQualityScore
            bool q0LongPass = isReferenceScan and validTrades >= q0MinSampleYears and longWinRatePct >= referenceMinWinRate and avgLongProfitPct >= q0MinAvgProfitPct
            selectedValid := isReferenceScan ? q0LongPass : validTrades >= effectiveMinSampleYears and longWinRatePct >= effectiveMinWinRatePct and avgLongProfitPct >= effectiveMinAvgProfitPct and avgLongDrawdownPct <= effectiveMaxAvgDrawdownPct and longPassQualityStrength
            selectedScore := longScore
            selectedQuality := longGrade
            selectedWinRate := longWinRatePct
            selectedAvgProfit := avgLongProfitPct
            selectedAvgDrawdown := avgLongDrawdownPct
            selectedSqn := longSqn
            selectedSampleCount := validTrades
            selectedWinningCount := longWinningTrades
            selectedEntryPrice := f_getWindowEntryPrice(entryOffset)
        else if side == SEG_SHORT and validTrades > 0
            // QUALITY_FLOW: shortScore is raw; shortGrade/shortFinalScore are final; selectedQuality stores final grade.
            [shortGrade, shortFinalScore] = f_directionalCandidateQuality(shortScore, shortWinRatePct, validTrades, effectiveMinSampleYears, avgShortProfitPct, shortSqn, avgShortMaxMovePct, entryOffset, exitOffset, selectedDuration, longScore)
            bool shortPassQualityStrength = qualityGradeToRank(shortGrade) >= effectiveMinQualityRank and nz(shortFinalScore, 0.0) >= effectiveMinFinalQualityScore
            bool q0ShortPass = isReferenceScan and validTrades >= q0MinSampleYears and shortWinRatePct >= referenceMinWinRate and avgShortProfitPct >= q0MinAvgProfitPct
            selectedValid := isReferenceScan ? q0ShortPass : validTrades >= effectiveMinSampleYears and shortWinRatePct >= effectiveMinWinRatePct and avgShortProfitPct >= effectiveMinAvgProfitPct and avgShortDrawdownPct <= effectiveMaxAvgDrawdownPct and shortPassQualityStrength
            selectedScore := shortScore
            selectedQuality := shortGrade
            selectedWinRate := shortWinRatePct
            selectedAvgProfit := avgShortProfitPct
            selectedAvgDrawdown := avgShortDrawdownPct
            selectedSqn := shortSqn
            selectedSampleCount := validTrades
            selectedWinningCount := shortWinningTrades
            selectedEntryPrice := f_getWindowEntryPrice(entryOffset)
    [selectedValid, selectedScore, selectedQuality, selectedWinRate, selectedAvgProfit, selectedAvgDrawdown, selectedSqn, selectedSampleCount, selectedWinningCount, selectedEntryPrice, selectedVerificationPayload]


f_isSeasonalDiscoveryWindow(int entryOffset, int exitOffset) =>
    int duration = not na(entryOffset) and not na(exitOffset) ? exitOffset - entryOffset : na
    // Discovery constraints are calendar-map structural constraints only.
    // Horizon and Max Trade Duration belong to selection/execution, not geometry.
    not na(duration) and entryOffset >= 0 and exitOffset > entryOffset and duration >= minTradeDurationDays


// Re-evaluate six real neighboring directional windows around the selected
// window. The diagnostic does not feed AutoQ, locking, alerts, or rendering.
f_realPlateauNeighborScore(array<int> anchorOffsets, int side, int entryOffset, int exitOffset) =>
    bool windowOk = f_isDirectionalSide(side) and f_isSeasonalDiscoveryWindow(entryOffset, exitOffset)
    float score = na
    if windowOk
        [validTrades, _, _, _, _, _, _, _, _, _, _, _, _, _, _, longScore, shortScore] = f_evaluateSeasonalWindow(anchorOffsets, entryOffset, exitOffset)
        score := side == SEG_LONG and validTrades > 0 ? longScore : side == SEG_SHORT and validTrades > 0 ? shortScore : na
    score

f_realPlateauDiagnostics(array<int> anchorOffsets, int side, int entryOffset, int exitOffset, float selectedScore) =>
    int validNeighbors = 0
    int weakNeighbors = 0
    float minRatio = na
    float sumRatio = 0.0
    if f_isDirectionalSide(side) and not na(entryOffset) and not na(exitOffset) and not na(selectedScore) and selectedScore > 0
        for neighborIdx = 0 to 5
            int neighborEntry = neighborIdx == 0 ? entryOffset - 1 : neighborIdx == 1 ? entryOffset + 1 : neighborIdx == 4 ? entryOffset - 1 : neighborIdx == 5 ? entryOffset + 1 : entryOffset
            int neighborExit = neighborIdx == 0 ? exitOffset - 1 : neighborIdx == 1 ? exitOffset + 1 : neighborIdx == 2 ? exitOffset - 1 : neighborIdx == 3 ? exitOffset + 1 : exitOffset
            float neighborScore = f_realPlateauNeighborScore(anchorOffsets, side, neighborEntry, neighborExit)
            if not na(neighborScore)
                float ratio = neighborScore / selectedScore
                validNeighbors += 1
                weakNeighbors += ratio < 0.70 ? 1 : 0
                sumRatio += ratio
                minRatio := na(minRatio) ? ratio : math.min(minRatio, ratio)
    float avgRatio = validNeighbors > 0 ? sumRatio / validNeighbors : na
    [validNeighbors, minRatio, avgRatio, weakNeighbors]

f_realPlateauGrade(int validNeighbors, float minRatio, float avgRatio, int weakNeighbors) =>
    validNeighbors <= 0 or na(minRatio) or na(avgRatio) ? "Unknown" : validNeighbors >= 6 and minRatio >= 0.85 and avgRatio >= 0.95 and weakNeighbors == 0 ? "Strong" : validNeighbors >= 5 and minRatio >= 0.70 and avgRatio >= 0.85 and weakNeighbors <= 1 ? "Valid" : validNeighbors >= 4 and minRatio >= 0.55 and avgRatio >= 0.70 ? "Weak" : "Reject"

// Real neighboring-window diagnostics drive quality capping and selected-
// candidate rejection without introducing an additional seasonal state.
f_tablePosition(_positionText) =>
    switch _positionText
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_textSize(_sizeText) =>
    switch _sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.small

f_cell(table t, int c, int r, string txt, color tc) =>
    table.cell(t, c, r, txt, text_color = tc, text_size = size.small)

f_cellBg(table t, int c, int r, string txt, color tc, color bg) =>
    table.cell(t, c, r, txt, text_color = tc, bgcolor = bg, text_size = size.small)

f_cellTip(table t, int c, int r, string txt, color tc, string tip) =>
    table.cell(t, c, r, txt, text_color = tc, text_size = size.small, tooltip = tip)

f_cellBgTip(table t, int c, int r, string txt, color tc, color bg, string tip) =>
    table.cell(t, c, r, txt, text_color = tc, bgcolor = bg, text_size = size.small, tooltip = tip)

f_cellPlain(table t, int c, int r, string txt) =>
    table.cell(t, c, r, txt, text_size = size.small)

f_cellMuted(table t, int c, int r, string txt) =>
    f_cell(t, c, r, txt, panelMutedTextColor)

f_cellMutedBg(table t, int c, int r, string txt, color bg) =>
    f_cellBg(t, c, r, txt, panelMutedTextColor, bg)

f_cellMutedTip(table t, int c, int r, string txt, string tip) =>
    f_cellTip(t, c, r, txt, panelMutedTextColor, tip)

f_cellMutedBgTip(table t, int c, int r, string txt, color bg, string tip) =>
    f_cellBgTip(t, c, r, txt, panelMutedTextColor, bg, tip)

f_headerCell(table t, int c, int r, string txt, color bg) =>
    f_cellBg(t, c, r, txt, color.white, bg)

f_fallbackVerificationPosition(_mainPositionText, _verificationPositionText) =>
    _mainPositionText != _verificationPositionText ? _verificationPositionText : _mainPositionText == "Top Right" ? "Bottom Left" : _mainPositionText == "Top Left" ? "Bottom Right" : _mainPositionText == "Middle Right" ? "Middle Left" : _mainPositionText == "Middle Left" ? "Middle Right" : _mainPositionText == "Bottom Right" ? "Top Left" : "Top Right"

int MS_PER_DAY = 24 * 60 * 60 * 1000

f_zoneIsPending(int nowTime, int entryTime) =>
    not na(nowTime) and not na(entryTime) and nowTime < entryTime

f_zoneIsActive(int nowTime, int entryTime, int exitTime) =>
    not na(nowTime) and not na(entryTime) and not na(exitTime) and nowTime >= entryTime and nowTime <= exitTime

f_zoneIsCompleted(int nowTime, int exitTime) =>
    not na(nowTime) and not na(exitTime) and nowTime > exitTime

f_zoneLifecycle(int nowTime, SeasonalZone zone) =>
    not zone.valid ? "NONE" : f_zoneIsPending(nowTime, zone.canonicalEntryTime) ? "PENDING" : f_zoneIsActive(nowTime, zone.canonicalEntryTime, zone.canonicalExitTime) ? "ACTIVE" : f_zoneIsCompleted(nowTime, zone.canonicalExitTime) ? "COMPLETED" : "NONE"

f_validBarTimeWindow(int entryTime, int exitTime) =>
    not na(entryTime) and not na(exitTime) and exitTime >= entryTime

f_verificationCohortLabel(int verificationYear) =>
    int yearBack = not na(verificationYear) ? f_tradingYear(0) - verificationYear : na
    not na(yearBack) and configuredHoldoutYears > 0 and yearBack > 0 and yearBack <= configuredHoldoutYears ? "H" : "T"

f_verificationYearText(int verificationYear) =>
    str.tostring(verificationYear) + " " + f_verificationCohortLabel(verificationYear)

f_addRiskRewardLevel(array<line> rrLines, array<label> rrLabels, int x1, int x2, float priceLevel, string labelText, color lineColor, string lineStyle, color labelColor, string labelSizeText) =>
    line rrLine = line.new(x1, priceLevel, x2, priceLevel, xloc = xloc.bar_time, color = lineColor, style = lineStyle, width = 1)
    label rrLabel = na
    if labelSizeText != "None"
        rrLabel := label.new(x2, priceLevel, labelText, xloc = xloc.bar_time, style = label.style_label_left, color = labelColor, textcolor = color.white, size = f_textSize(labelSizeText))
        array.push(rrLabels, rrLabel)
    array.push(rrLines, rrLine)
    rrLine


var array<string> futurePoolZoneId = array.new_string(MAX_VISIBLE_SEASONAL_ZONES, "")
var array<int> futurePoolSide = array.new_int(MAX_VISIBLE_SEASONAL_ZONES, SEG_NONE)
var array<int> futurePoolEntryTarget = array.new_int(MAX_VISIBLE_SEASONAL_ZONES, na)
var array<int> futurePoolExitTarget = array.new_int(MAX_VISIBLE_SEASONAL_ZONES, na)
var array<float> futurePoolTop = array.new_float(MAX_VISIBLE_SEASONAL_ZONES, na)
var array<float> futurePoolBottom = array.new_float(MAX_VISIBLE_SEASONAL_ZONES, na)
var array<box> futurePoolBoxes = array.new_box(MAX_VISIBLE_SEASONAL_ZONES, na)
var array<line> futurePoolEntryLines = array.new_line(MAX_VISIBLE_SEASONAL_ZONES, na)
var array<line> futurePoolExitLines = array.new_line(MAX_VISIBLE_SEASONAL_ZONES, na)
var array<label> futurePoolLabels = array.new_label(MAX_VISIBLE_SEASONAL_ZONES, na)
var int lastFutureRenderGeneration = na

var array<line> historicalLines = array.new_line()
var array<box> historicalBoxes = array.new_box()
var array<label> historicalLabels = array.new_label()
var array<line> riskRewardLines = array.new_line()
var array<label> riskRewardLabels = array.new_label()
var string lastHistoricalRenderSignature = ""

f_segmentRenderText(int side, int status, string qualityText) =>
    string sideText = side == SEG_LONG ? "LONG" : side == SEG_SHORT ? "SHORT" : ""
    str.length(sideText) == 0 ? "" : status == SEG_STATUS_TRADEABLE ? sideText + " Q:" + qualityText : status == SEG_STATUS_WATCH ? sideText + " Watch" : sideText + " Weak"

f_renderLifecycle(int currentTime, int entryTime, int exitTime) =>
    na(currentTime) or na(entryTime) or na(exitTime) ? "NONE" : currentTime < entryTime ? "PENDING" : currentTime <= exitTime ? "ACTIVE" : "COMPLETED"

// One lifecycle-aware style authority serves Long/Short, Primary/registry, and
// overlap states. Rendering may distinguish zones but never remove membership.
f_zoneRenderStyle(int side, string lifecycle, bool isPrimary, bool outlineOnly) =>
    color baseColor = side == SEG_LONG ? color.green : color.red
    bool completed = lifecycle == "COMPLETED"
    bool active = lifecycle == "ACTIVE"
    int fillTransparency = outlineOnly ? 100 : completed ? COMPLETED_ZONE_FILL_TRANSPARENCY : active ? (isPrimary ? 82 : 88) : isPrimary ? 86 : 92
    int borderTransparency = outlineOnly ? 0 : completed ? COMPLETED_ZONE_BORDER_TRANSPARENCY : active ? (isPrimary ? 35 : 60) : isPrimary ? 50 : 80
    int lineTransparency = completed ? 82 : active ? (isPrimary ? 30 : 48) : isPrimary ? 45 : 65
    int labelTransparency = completed ? 75 : active ? 15 : 20
    [baseColor, fillTransparency, borderTransparency, lineTransparency, labelTransparency]

f_hideFutureZoneSlot(int slot) =>
    box.delete(array.get(futurePoolBoxes, slot))
    line.delete(array.get(futurePoolEntryLines, slot))
    line.delete(array.get(futurePoolExitLines, slot))
    label.delete(array.get(futurePoolLabels, slot))
    array.set(futurePoolBoxes, slot, na)
    array.set(futurePoolEntryLines, slot, na)
    array.set(futurePoolExitLines, slot, na)
    array.set(futurePoolLabels, slot, na)

f_releaseFutureZoneSlot(int slot) =>
    f_hideFutureZoneSlot(slot)
    array.set(futurePoolZoneId, slot, "")
    array.set(futurePoolSide, slot, SEG_NONE)
    array.set(futurePoolEntryTarget, slot, na)
    array.set(futurePoolExitTarget, slot, na)
    array.set(futurePoolTop, slot, na)
    array.set(futurePoolBottom, slot, na)

f_syncFutureZoneSlot(string zoneId, int side, int entryTarget, int exitTarget, int entryTime, int exitTime, string lifecycle, bool isPrimary, bool outlineOnly, int scannerStatus, int qualityCode, float zoneTop, float zoneBottom, string renderMode, string labelSizeText, array<string> visibleZoneIds) =>
    int slot = na
    int freeSlot = na
    for i = 0 to MAX_VISIBLE_SEASONAL_ZONES - 1
        string storedZoneId = array.get(futurePoolZoneId, i)
        if storedZoneId == zoneId and str.length(zoneId) > 0
            slot := i
        else if str.length(storedZoneId) == 0 and na(freeSlot)
            freeSlot := i
    bool isNew = na(slot)
    if isNew and na(freeSlot) and not na(zoneTop) and not na(zoneBottom) and zoneTop > zoneBottom
        for i = 0 to MAX_VISIBLE_SEASONAL_ZONES - 1
            bool acceptedVisible = false
            for acceptedSlot = 0 to array.size(visibleZoneIds) - 1
                if array.get(futurePoolZoneId, i) == array.get(visibleZoneIds, acceptedSlot)
                    acceptedVisible := true
                    break
            if not acceptedVisible
                f_releaseFutureZoneSlot(i)
                freeSlot := i
                break
    slot := isNew ? (not na(zoneTop) and not na(zoneBottom) and zoneTop > zoneBottom ? freeSlot : na) : slot
    if not na(slot)
        if isNew
            array.set(futurePoolZoneId, slot, zoneId)
            array.set(futurePoolSide, slot, side)
            array.set(futurePoolEntryTarget, slot, entryTarget)
            array.set(futurePoolExitTarget, slot, exitTarget)
            array.set(futurePoolTop, slot, zoneTop)
            array.set(futurePoolBottom, slot, zoneBottom)
        float top = array.get(futurePoolTop, slot)
        float bottom = array.get(futurePoolBottom, slot)
        [zoneColor, fillTransparency, borderTransparency, lineTransparency, labelTransparency] = f_zoneRenderStyle(side, lifecycle, isPrimary, outlineOnly)
        box zoneBox = array.get(futurePoolBoxes, slot)
        if renderMode == "Lines + Band"
            if na(zoneBox)
                zoneBox := box.new(entryTime, top, exitTime, bottom, xloc = xloc.bar_time)
                array.set(futurePoolBoxes, slot, zoneBox)
            box.set_left(zoneBox, entryTime)
            box.set_right(zoneBox, exitTime)
            box.set_bgcolor(zoneBox, color.new(zoneColor, fillTransparency))
            box.set_border_color(zoneBox, color.new(zoneColor, borderTransparency))
        else if not na(zoneBox)
            box.delete(zoneBox)
            array.set(futurePoolBoxes, slot, na)
        line entryLine = array.get(futurePoolEntryLines, slot)
        line exitLine = array.get(futurePoolExitLines, slot)
        label zoneLabel = array.get(futurePoolLabels, slot)
        if isPrimary
            if na(entryLine)
                entryLine := line.new(entryTime, top, entryTime, bottom, xloc = xloc.bar_time, color = color.new(zoneColor, 50), style = line.style_solid, width = 1, extend = extend.both)
                array.set(futurePoolEntryLines, slot, entryLine)
            if na(exitLine)
                exitLine := line.new(exitTime, top, exitTime, bottom, xloc = xloc.bar_time, color = color.new(zoneColor, 50), style = line.style_dashed, width = 1, extend = extend.both)
                array.set(futurePoolExitLines, slot, exitLine)
            line.set_x1(entryLine, entryTime)
            line.set_x2(entryLine, entryTime)
            line.set_x1(exitLine, exitTime)
            line.set_x2(exitLine, exitTime)
            line.set_color(entryLine, color.new(zoneColor, lineTransparency))
            line.set_color(exitLine, color.new(zoneColor, lineTransparency))
            if not na(zoneLabel)
                label.delete(zoneLabel)
                array.set(futurePoolLabels, slot, na)
        else
            if not na(entryLine)
                line.delete(entryLine)
                array.set(futurePoolEntryLines, slot, na)
            if not na(exitLine)
                line.delete(exitLine)
                array.set(futurePoolExitLines, slot, na)
            if labelSizeText != "None" and not outlineOnly
                string labelText = f_segmentRenderText(side, scannerStatus, rankToQualityGrade(qualityCode))
                if na(zoneLabel)
                    zoneLabel := label.new(exitTime, top, labelText, xloc = xloc.bar_time, style = label.style_label_down, color = color.new(zoneColor, 20), textcolor = color.white, size = f_textSize(labelSizeText))
                    array.set(futurePoolLabels, slot, zoneLabel)
                label.set_x(zoneLabel, exitTime)
                label.set_text(zoneLabel, labelText)
                label.set_color(zoneLabel, color.new(zoneColor, labelTransparency))
            else if not na(zoneLabel)
                label.delete(zoneLabel)
                array.set(futurePoolLabels, slot, na)
    not na(slot)

var table mainStatsTable = na
var table verificationPanel = na
var table potentialPanel = na
var string lastDecodedVerificationSignature = ""
var array<int> viewLongVerificationYears = array.new_int()
var array<int> viewLongVerificationEntryTimes = array.new_int()
var array<int> viewLongVerificationExitTimes = array.new_int()
var array<int> viewLongVerificationBandEndTimes = array.new_int()
var array<float> viewLongVerificationProfits = array.new_float()
var array<float> viewLongVerificationDrawdowns = array.new_float()
var array<float> viewLongVerificationLows = array.new_float()
var array<float> viewLongVerificationHighs = array.new_float()
var array<float> viewLongVerificationEntryPrices = array.new_float()
var array<float> viewLongVerificationExitPrices = array.new_float()
var array<float> viewLongMae = array.new_float()
var array<float> viewLongMfe = array.new_float()
var array<int> viewShortVerificationYears = array.new_int()
var array<int> viewShortVerificationEntryTimes = array.new_int()
var array<int> viewShortVerificationExitTimes = array.new_int()
var array<int> viewShortVerificationBandEndTimes = array.new_int()
var array<float> viewShortVerificationProfits = array.new_float()
var array<float> viewShortVerificationDrawdowns = array.new_float()
var array<float> viewShortVerificationLows = array.new_float()
var array<float> viewShortVerificationHighs = array.new_float()
var array<float> viewShortVerificationEntryPrices = array.new_float()
var array<float> viewShortVerificationExitPrices = array.new_float()
var array<float> viewShortMae = array.new_float()
var array<float> viewShortMfe = array.new_float()
var bool hasLong = false
var bool hasShort = false
var int bestLongEntryOffset = na
var int bestLongExitOffset = na
var int bestLongDuration = na
var int bestLongValidTrades = 0
var int bestLongWinningTrades = 0
var float bestLongWinRatePct = na
var float bestLongAvgProfitPct = na
var float bestLongAvgDrawdownPct = na
var float bestLongSqn = na
var float bestLongScore = na
var float longSampleCoveragePct = na
var float longRecentWinRatePct = na
var float longOutlierImpactPct = na
var float longMedianProfitPct = na
var string longQualityGrade = "D"
var bool longOverfitWarning = false
var bool longZoneValid = false
var int longZoneMapOriginTime = na
var int longZoneEntryMapOffset = na
var int longZoneExitMapOffset = na
var float longZoneEntryPrice = na

var int bestShortEntryOffset = na
var int bestShortExitOffset = na
var int bestShortDuration = na
var int bestShortValidTrades = 0
var int bestShortWinningTrades = 0
var float bestShortWinRatePct = na
var float bestShortAvgProfitPct = na
var float bestShortAvgDrawdownPct = na
var float bestShortSqn = na
var float bestShortScore = na
var float shortSampleCoveragePct = na
var float shortRecentWinRatePct = na
var float shortOutlierImpactPct = na
var float shortMedianProfitPct = na
var string shortQualityGrade = "D"
var bool shortOverfitWarning = false
var bool shortZoneValid = false
var int shortZoneMapOriginTime = na
var int shortZoneEntryMapOffset = na
var int shortZoneExitMapOffset = na
var float shortZoneEntryPrice = na

type SeasonalSegment
    int entryOffset
    int exitOffset
    int entryTime
    int exitTime
    int entryTimeSource
    int exitTimeSource
    int side
    float score
    string quality
    int status
    string eligibilityReason

type ZoneSelection
    bool valid
    SeasonalZone seasonalZone
    int qualityCode
    string source
    int mapOriginTime
    int entryTime
    int exitTime
    int entryTimeSource
    int exitTimeSource
    int entryMapOffset
    int exitMapOffset
    float entryPrice
    int mapOriginTradingDay
    int mapOriginDailyBarIndex
    int snapshotGeneration

f_zoneSelection(bool valid, SeasonalZone seasonalZone, int qualityCode, string source, int mapOriginTime, int entryTimeSource, int exitTimeSource, int entryMapOffset, int exitMapOffset, float entryPrice, int mapOriginTradingDay, int mapOriginDailyBarIndex, int snapshotGeneration) =>
    ZoneSelection.new(valid, seasonalZone, valid ? qualityCode : 1, source, mapOriginTime, seasonalZone.canonicalEntryTime, seasonalZone.canonicalExitTime, entryTimeSource, exitTimeSource, entryMapOffset, exitMapOffset, entryPrice, mapOriginTradingDay, mapOriginDailyBarIndex, snapshotGeneration)

f_zoneSelectionNone() =>
    f_zoneSelection(false, f_seasonalZoneNone(), 1, "NONE", na, TIME_SOURCE_NONE, TIME_SOURCE_NONE, na, na, na, na, na, 0)

f_zoneSelectionFinalReady(ZoneSelection selection) =>
    selection.valid and f_seasonalZoneInvariant(selection.seasonalZone) and selection.entryTime == selection.seasonalZone.canonicalEntryTime and selection.exitTime == selection.seasonalZone.canonicalExitTime

type VisibleZone
    bool valid
    string zoneId
    int side
    int scannerStatus
    int qualityCode
    int entryTargetDailyBarIndex
    int exitTargetDailyBarIndex
    int entryTime
    int exitTime
    int entryTimeSource
    int exitTimeSource

// One completed Discovery publication. Canonical Evidence, Holdout, Plateau
// and Verification remain frozen; effective Quality travels as qualityCode.
type DailyScanSnapshot
    bool valid
    int generation
    int anchorTradingDay
    int anchorChartTime
    int anchorDailyBarIndex
    ZoneSelection longSelection
    ZoneSelection shortSelection
    int primarySide
    int primaryStatus
    string noEdgeReason
    float longSampleCoverage
    float longRecentWinRate
    float longMedianProfit
    float longOutlierImpact
    bool longOverfitWarning
    float shortSampleCoverage
    float shortRecentWinRate
    float shortMedianProfit
    float shortOutlierImpact
    bool shortOverfitWarning

f_dailyScanSnapshotNone() =>
    DailyScanSnapshot.new(false, 0, na, na, na, f_zoneSelectionNone(), f_zoneSelectionNone(), SEG_NONE, SEG_STATUS_BLOCKED, "SCAN_NOT_COMPLETED", na, na, na, na, false, na, na, na, na, false)

type LockedZone
    bool valid
    SeasonalZone seasonalZone
    int qualityCode
    string state
    string source
    int mapOriginTime
    int entryTime
    int exitTime
    int entryTimeSource
    int exitTimeSource
    int entryMapOffset
    int exitMapOffset
    float entryPrice
    int mapOriginTradingDay
    int mapOriginDailyBarIndex
    int entryTargetDailyBarIndex
    int exitTargetDailyBarIndex
    int snapshotGeneration

f_lockedZone(bool valid, SeasonalZone seasonalZone, int qualityCode, string state, string source, int mapOriginTime, int entryTime, int exitTime, int entryTimeSource, int exitTimeSource, int entryMapOffset, int exitMapOffset, float entryPrice, int mapOriginTradingDay, int mapOriginDailyBarIndex, int entryTargetDailyBarIndex, int exitTargetDailyBarIndex, int snapshotGeneration) =>
    LockedZone.new(valid, seasonalZone, valid ? qualityCode : 1, state, source, mapOriginTime, entryTime, exitTime, entryTimeSource, exitTimeSource, entryMapOffset, exitMapOffset, entryPrice, mapOriginTradingDay, mapOriginDailyBarIndex, entryTargetDailyBarIndex, exitTargetDailyBarIndex, snapshotGeneration)

f_lockedZoneFromSelection(ZoneSelection selection, string state) =>
    bool lockedValid = f_zoneSelectionFinalReady(selection)
    int entryTargetIndex = lockedValid ? selection.mapOriginDailyBarIndex + selection.entryMapOffset : na
    int exitTargetIndex = lockedValid ? selection.mapOriginDailyBarIndex + selection.exitMapOffset : na
    bool targetOrderValid = lockedValid and not na(entryTargetIndex) and not na(exitTargetIndex) and entryTargetIndex < exitTargetIndex
    f_lockedZone(targetOrderValid, targetOrderValid ? selection.seasonalZone : f_seasonalZoneNone(), selection.qualityCode, targetOrderValid ? state : "NONE", targetOrderValid ? selection.source : "NONE", selection.mapOriginTime, selection.entryTime, selection.exitTime, selection.entryTimeSource, selection.exitTimeSource, selection.entryMapOffset, selection.exitMapOffset, selection.entryPrice, targetOrderValid ? selection.mapOriginTradingDay : na, targetOrderValid ? selection.mapOriginDailyBarIndex : na, targetOrderValid ? entryTargetIndex : na, targetOrderValid ? exitTargetIndex : na, targetOrderValid ? selection.snapshotGeneration : 0)

f_lockedZoneNone() =>
    f_lockedZone(false, f_seasonalZoneNone(), 1, "NONE", "NONE", na, na, na, TIME_SOURCE_NONE, TIME_SOURCE_NONE, na, na, na, na, na, na, na, 0)

f_lockedZoneHardInvalid(LockedZone zone) =>
    zone.valid and (not f_seasonalZoneInvariant(zone.seasonalZone) or na(zone.entryTargetDailyBarIndex) or na(zone.exitTargetDailyBarIndex) or zone.entryTargetDailyBarIndex >= zone.exitTargetDailyBarIndex)

f_lockedZoneKey(LockedZone zone, int side) =>
    zone.valid and f_seasonalZoneInvariant(zone.seasonalZone) and zone.seasonalZone.side == side ? zone.seasonalZone.zoneId : "NONE"


f_lockedZoneWithState(LockedZone zone, string state) =>
    f_lockedZone(zone.valid, zone.seasonalZone, zone.qualityCode, state, zone.source, zone.mapOriginTime, zone.entryTime, zone.exitTime, zone.entryTimeSource, zone.exitTimeSource, zone.entryMapOffset, zone.exitMapOffset, zone.entryPrice, zone.mapOriginTradingDay, zone.mapOriginDailyBarIndex, zone.entryTargetDailyBarIndex, zone.exitTargetDailyBarIndex, zone.snapshotGeneration)

f_lockedZoneWithEntryPrice(LockedZone zone, float entryPrice) =>
    f_lockedZone(zone.valid, zone.seasonalZone, zone.qualityCode, zone.state, zone.source, zone.mapOriginTime, zone.entryTime, zone.exitTime, zone.entryTimeSource, zone.exitTimeSource, zone.entryMapOffset, zone.exitMapOffset, entryPrice, zone.mapOriginTradingDay, zone.mapOriginDailyBarIndex, zone.entryTargetDailyBarIndex, zone.exitTargetDailyBarIndex, zone.snapshotGeneration)

f_lockedZoneRefreshLifecycle(LockedZone zone, int currentDailyTime) =>
    if not zone.valid or f_lockedZoneHardInvalid(zone)
        zone
    else
        f_lockedZoneWithState(zone, f_zoneLifecycle(currentDailyTime, zone.seasonalZone))

// Completed zones remain immutable in seasonalZoneMap. This only frees the
// short-lived Primary analytical slot so later map zones can be selected.
f_lockedZonePruneDisplay(LockedZone zone) =>
    zone.valid and (f_lockedZoneHardInvalid(zone) or zone.state == "COMPLETED") ? f_lockedZoneNone() : zone

f_lockedZoneResolveEntryPrice(LockedZone zone, int currentDailyBarIndex) =>
    int barsBack = currentDailyBarIndex - zone.entryTargetDailyBarIndex
    isDailyChart and zone.valid and na(zone.entryPrice) and barsBack >= 0 and barsBack <= bar_index and not na(close[barsBack]) ? f_lockedZoneWithEntryPrice(zone, close[barsBack]) : zone

f_lockedZoneRegistryStep(LockedZone existing, ZoneSelection selection, bool selectionLifecycleOk, string currentModelVintageId, int currentDailyBarIndex, int currentDailyTime) =>
    LockedZone current = f_lockedZoneRefreshLifecycle(f_lockedZoneResolveEntryPrice(existing, currentDailyBarIndex), currentDailyTime)
    bool vintageChanged = current.valid and str.length(currentModelVintageId) > 0 and current.seasonalZone.modelVintageId != currentModelVintageId
    bool replaceable = not current.valid or f_lockedZoneHardInvalid(current) or current.state == "COMPLETED" or vintageChanged
    LockedZone retained = vintageChanged ? f_lockedZoneNone() : f_lockedZonePruneDisplay(current)
    LockedZone selected = replaceable and selectionLifecycleOk ? f_lockedZoneFromSelection(selection, f_zoneLifecycle(currentDailyTime, selection.seasonalZone)) : retained
    f_lockedZoneRefreshLifecycle(f_lockedZoneResolveEntryPrice(selected, currentDailyBarIndex), currentDailyTime)

type DailyZoneBridge
    string modelVintageId
    string longZoneId
    string shortZoneId
    LockedZone longZone
    LockedZone shortZone
    int generation
    int primaryStatus
    string noEdgeReason
    int dailyBarIndex
    int dailyAnchorTime
    float dailyClose
    float dailyHigh
    float dailyLow
    int dailyTime
    int snapshotGeneration

f_dailyZoneBridgeValid(DailyZoneBridge bridge) =>
    bool longValid = not bridge.longZone.valid ? bridge.longZoneId == "" : bridge.longZoneId == bridge.longZone.seasonalZone.zoneId and bridge.longZone.seasonalZone.modelVintageId == bridge.modelVintageId
    bool shortValid = not bridge.shortZone.valid ? bridge.shortZoneId == "" : bridge.shortZoneId == bridge.shortZone.seasonalZone.zoneId and bridge.shortZone.seasonalZone.modelVintageId == bridge.modelVintageId
    str.length(bridge.modelVintageId) > 0 and longValid and shortValid

// Final Evidence View Model: presentation and alerts consume one frozen Primary lock, never scanner statistics.
type EvidenceViewModel
    int side
    string lifecycle
    int entryTime
    int exitTime
    int entryTimeSource
    int exitTimeSource
    string finalGrade
    int trainingSamples
    int trainingSuccesses
    float trainingWilsonLower
    float medianOutcome
    float worstOutcome
    float mae75
    float maxMae
    float mfe75
    float mfeMaeRatio
    string plateauGrade
    int holdoutSamples
    int holdoutSuccesses
    string holdoutDepth
    string holdoutStatus
    string rrState
    string noEdgeReason

f_evidenceViewModelNone(string noEdgeReason) =>
    EvidenceViewModel.new(SEG_NONE, "NONE", na, na, TIME_SOURCE_NONE, TIME_SOURCE_NONE, "D", 0, 0, na, na, na, na, na, na, na, "Unknown", 0, 0, "Disabled", "Disabled", "n/a", noEdgeReason)

f_evidenceViewModelFromLockedZone(int side, LockedZone zone, string rrState, string noEdgeReason) =>
    SeasonalZone canonical = zone.seasonalZone
    EvidenceSnapshot evidence = canonical.evidence
    EvidenceViewModel.new(side, zone.state, canonical.canonicalEntryTime, canonical.canonicalExitTime, zone.entryTimeSource, zone.exitTimeSource, rankToQualityGrade(zone.qualityCode), evidence.trainingSamples, evidence.trainingSuccesses, evidence.trainingWilsonLower, evidence.trainingMedianOutcome, evidence.worstOutcome, evidence.mae75, evidence.maxMae, evidence.mfe75, evidence.mfeMaeRatio, evidence.plateauGrade, evidence.holdoutSamples, evidence.holdoutSuccesses, evidence.holdoutDepth, evidence.holdoutStatus, rrState, noEdgeReason)

f_evidencePlateauShort(string plateauGrade) =>
    plateauGrade == "Strong" ? "S" : plateauGrade == "Valid" ? "V" : plateauGrade == "Weak" ? "W" : plateauGrade == "Reject" ? "R" : "-"

f_evidenceWl90Text(float wl90) =>
    na(wl90) ? "n/a" : str.tostring(math.round(wl90))

f_evidenceWinsText(int wins, int samples) =>
    str.tostring(wins) + "/" + str.tostring(samples)

f_evidenceOosText(EvidenceViewModel vm) =>
    vm.holdoutDepth == "Disabled" ? "OOS Off" : "OOS " + f_evidenceWinsText(vm.holdoutSuccesses, vm.holdoutSamples) + " " + vm.holdoutDepth + " " + vm.holdoutStatus

f_evidencePotentialLine(EvidenceViewModel vm) =>
    vm.side == SEG_NONE ? "FQ D | WL90 n/a | Plat - | OOS n/a | RR n/a" : "FQ " + vm.finalGrade + " | WL90 " + f_evidenceWl90Text(vm.trainingWilsonLower) + " | Plat " + f_evidencePlateauShort(vm.plateauGrade) + " | " + f_evidenceOosText(vm) + " | RR " + vm.rrState

f_evidenceVerificationHeader() =>
    "Training " + str.tostring(configuredTrainingYears) + "Y | Holdout " + str.tostring(configuredHoldoutYears) + "Y | Risk " + str.tostring(lookbackYears) + "Y"

f_timeSourceShort(int source) =>
    source == TIME_SOURCE_PROJECTED ? "Proj" : source == TIME_SOURCE_ACTUAL ? "Act" : "n/a"

f_viewModelProjectedSuffix(EvidenceViewModel vm) =>
    bool entryProjected = vm.entryTimeSource == TIME_SOURCE_PROJECTED
    bool exitProjected = vm.exitTimeSource == TIME_SOURCE_PROJECTED
    (entryProjected or exitProjected) ? " | E " + f_timeSourceShort(vm.entryTimeSource) + " X " + f_timeSourceShort(vm.exitTimeSource) : ""

f_noEdgeReasonCode(string reason, string tradeability, string rrState) =>
    // Eligibility reasons are accepted only when the eligibility engine can
    // actually emit them; dynamic view-state overrides remain presentation-only.
    bool standardized = reason == "NO_STRUCTURAL_ZONE" or reason == "INSUFFICIENT_SAMPLES" or reason == "WINRATE_BELOW_MIN" or reason == "AVG_RETURN_BELOW_MIN" or reason == "OUTSIDE_HORIZON" or reason == "SAMPLE_CONFIDENCE" or reason == "WEAK_STABILITY" or reason == "PLATEAU_REJECT" or reason == "HOLDOUT_FAILED" or reason == "QUALITY_GRADE"
    string result = standardized ? reason : "NO_CANDIDATE"
    if tradeability == "Data Error" or reason == "Selected-zone data error"
        result := "DATA_ERROR"
    else if reason == "Edge selected"
        result := "EDGE_SELECTED"
    else if tradeability == "Expired"
        result := "WINDOW_EXPIRED"
    else if rrState == "Weak"
        result := "RISK_REWARD_WEAK"
    result

// Discrete seasonal segment queue: recognized segments stay separate from trade validation status.
var array<SeasonalSegment> seasonalSegments = array.new<SeasonalSegment>()

var array<int> profileOffset = array.new_int()
var array<float> profileStep = array.new_float()
var array<float> profileSmoothStep = array.new_float()
var array<float> profileConfidence = array.new_float()
var array<int> profileState = array.new_int()


f_clearSegments() =>
    array.clear(seasonalSegments)

f_segmentCount() =>
    array.size(seasonalSegments)

f_newSegment(int entryOffset, int exitOffset, int entryTime, int exitTime, int entryTimeSource, int exitTimeSource, int side, float score, string quality, int status, string eligibilityReason) =>
    SeasonalSegment.new(entryOffset, exitOffset, entryTime, exitTime, entryTimeSource, exitTimeSource, side, score, quality, status, eligibilityReason)

f_segmentAt(int idx) =>
    array.get(seasonalSegments, idx)

f_segmentEntryOffset(int idx) =>
    SeasonalSegment segment = f_segmentAt(idx)
    segment.entryOffset

f_segmentExitOffset(int idx) =>
    SeasonalSegment segment = f_segmentAt(idx)
    segment.exitOffset

f_segmentEntryTime(int idx) =>
    SeasonalSegment segment = f_segmentAt(idx)
    segment.entryTime

f_segmentExitTime(int idx) =>
    SeasonalSegment segment = f_segmentAt(idx)
    segment.exitTime

f_segmentEntryTimeSource(int idx) =>
    SeasonalSegment segment = f_segmentAt(idx)
    segment.entryTimeSource

f_segmentExitTimeSource(int idx) =>
    SeasonalSegment segment = f_segmentAt(idx)
    segment.exitTimeSource

f_segmentSide(int idx) =>
    SeasonalSegment segment = f_segmentAt(idx)
    segment.side

f_segmentScore(int idx) =>
    SeasonalSegment segment = f_segmentAt(idx)
    segment.score

f_segmentQuality(int idx) =>
    SeasonalSegment segment = f_segmentAt(idx)
    segment.quality

f_segmentStatus(int idx) =>
    SeasonalSegment segment = f_segmentAt(idx)
    segment.status

f_segmentEligibilityReason(int idx) =>
    SeasonalSegment segment = f_segmentAt(idx)
    segment.eligibilityReason

f_setSegmentAt(int idx, SeasonalSegment segment) =>
    array.set(seasonalSegments, idx, segment)

f_setSegmentValidation(int idx, float score, string quality, int status, string eligibilityReason) =>
    SeasonalSegment segment = f_segmentAt(idx)
    f_setSegmentAt(idx, f_newSegment(segment.entryOffset, segment.exitOffset, segment.entryTime, segment.exitTime, segment.entryTimeSource, segment.exitTimeSource, segment.side, score, quality, status, eligibilityReason))

f_setSegmentExitFrom(int targetIdx, int sourceIdx) =>
    SeasonalSegment target = f_segmentAt(targetIdx)
    SeasonalSegment source = f_segmentAt(sourceIdx)
    f_setSegmentAt(targetIdx, f_newSegment(target.entryOffset, source.exitOffset, target.entryTime, source.exitTime, target.entryTimeSource, source.exitTimeSource, target.side, target.score, target.quality, target.status, target.eligibilityReason))

f_clearSeasonalProfile() =>
    array.clear(profileOffset)
    array.clear(profileStep)
    array.clear(profileSmoothStep)
    array.clear(profileConfidence)
    array.clear(profileState)

f_profileStepFromAnchors(array<int> anchorOffsets, int offsetFromOrigin) =>
    float stepSum = 0.0
    int samples = 0
    int upCount = 0
    int downCount = 0
    int anchorCount = array.size(anchorOffsets)
    if anchorCount > 0
        for yearIdx = 0 to anchorCount - 1
            int historicalAnchorOffset = array.get(anchorOffsets, yearIdx)
            if not na(historicalAnchorOffset)
                int historicalEntryOffset = historicalAnchorOffset - offsetFromOrigin
                int historicalExitOffset = historicalAnchorOffset - (offsetFromOrigin + 1)
                bool validOffsets = historicalEntryOffset >= 0 and historicalEntryOffset <= bar_index and historicalExitOffset >= 0 and historicalExitOffset <= bar_index and historicalExitOffset < historicalEntryOffset
                if validOffsets
                    float entryPrice = close[historicalEntryOffset]
                    float exitPrice = close[historicalExitOffset]
                    if not na(entryPrice) and not na(exitPrice) and entryPrice > 0 and exitPrice > 0
                        float stepPct = (exitPrice / entryPrice - 1.0) * 100.0
                        stepSum += stepPct
                        samples += 1
                        upCount += stepPct > 0 ? 1 : 0
                        downCount += stepPct < 0 ? 1 : 0
    float avgStep = samples > 0 ? stepSum / samples : na
    float signConsistency = samples > 0 ? math.max(upCount, downCount) / samples * 100.0 : na
    [avgStep, signConsistency]

f_stepToState(float smoothStep, float confidence, float threshold) =>
    int result = SEG_NONE
    if not na(smoothStep) and not na(confidence)
        if confidence >= STRUCTURAL_SEGMENT_CONFIDENCE_MIN
            result := smoothStep > threshold ? SEG_LONG : smoothStep < -threshold ? SEG_SHORT : SEG_NONE
    result

f_addRawSegment(int entryOffset, int exitOffset, int side, int mapOriginTime) =>
    if f_isDirectionalSide(side) and not na(entryOffset) and not na(exitOffset) and exitOffset >= entryOffset
        [entryTime, exitTime, entryTimeSource, exitTimeSource] = f_segmentWindowTimes(entryOffset, exitOffset, mapOriginTime)
        array.push(seasonalSegments, f_newSegment(entryOffset, exitOffset, entryTime, exitTime, entryTimeSource, exitTimeSource, side, na, "D", SEG_STATUS_WEAK, "NOT_EVALUATED"))

f_removeSegment(int idx) =>
    array.remove(seasonalSegments, idx)
    idx

f_swapSegments(int leftIdx, int rightIdx) =>
    SeasonalSegment leftSegment = f_segmentAt(leftIdx)
    f_setSegmentAt(leftIdx, f_segmentAt(rightIdx))
    f_setSegmentAt(rightIdx, leftSegment)

f_segmentSortKeySide(int side) =>
    side == SEG_LONG ? 1 : side == SEG_SHORT ? 2 : 3

f_segmentShouldComeAfter(int leftIdx, int rightIdx) =>
    int leftEntry = f_segmentEntryTime(leftIdx)
    int rightEntry = f_segmentEntryTime(rightIdx)
    int leftExit = f_segmentExitTime(leftIdx)
    int rightExit = f_segmentExitTime(rightIdx)
    int leftSideRank = f_segmentSortKeySide(f_segmentSide(leftIdx))
    int rightSideRank = f_segmentSortKeySide(f_segmentSide(rightIdx))
    float leftScore = nz(f_segmentScore(leftIdx), -1000000.0)
    float rightScore = nz(f_segmentScore(rightIdx), -1000000.0)
    leftEntry > rightEntry or (leftEntry == rightEntry and (leftSideRank > rightSideRank or (leftSideRank == rightSideRank and (leftExit > rightExit or (leftExit == rightExit and leftScore < rightScore)))))

f_sortSegmentsForDeterministicDisplay() =>
    int segmentCount = f_segmentCount()
    if segmentCount > 1
        for pass = 0 to segmentCount - 2
            for i = 0 to segmentCount - 2 - pass
                if f_segmentShouldComeAfter(i, i + 1)
                    f_swapSegments(i, i + 1)


f_segmentDays(int idx) =>
    f_segmentExitOffset(idx) - f_segmentEntryOffset(idx) + 1

f_mergeSegmentIntoPrevious(int idx) =>
    int prevIdx = idx - 1
    f_setSegmentExitFrom(prevIdx, idx)
    f_removeSegment(idx)

f_smoothRawSegments(int minSegmentDays) =>
    // Bridge a one-day neutral offset gap before minimum-duration filtering so
    // short same-direction fragments can form one valid directional window.
    int i = 1
    while i < f_segmentCount()
        int prevSide = f_segmentSide(i - 1)
        int currentSide = f_segmentSide(i)
        int gapDays = f_segmentEntryOffset(i) - f_segmentExitOffset(i - 1) - 1
        bool closeSameStateGap = prevSide == currentSide and f_isDirectionalSide(currentSide) and gapDays >= 0 and gapDays <= 1
        if closeSameStateGap
            f_mergeSegmentIntoPrevious(i)
            i := math.max(1, i - 1)
        else
            i += 1
    i := 0
    while i < f_segmentCount()
        if f_segmentDays(i) < minSegmentDays
            f_removeSegment(i)
        else
            i += 1
    // Normalize any same-side overlap or direct adjacency left after filtering.
    i := 1
    while i < f_segmentCount()
        int prevSide = f_segmentSide(i - 1)
        int currentSide = f_segmentSide(i)
        int gapDays = f_segmentEntryOffset(i) - f_segmentExitOffset(i - 1) - 1
        bool normalizeSameDirectional = prevSide == currentSide and f_isDirectionalSide(currentSide) and gapDays <= 0
        if normalizeSameDirectional
            f_mergeSegmentIntoPrevious(i)
            i := math.max(1, i - 1)
        else
            i += 1

f_validateStructuralSegments(array<int> anchorOffsets) =>
    int segmentCount = f_segmentCount()
    if segmentCount > 0
        for step = 0 to segmentCount - 1
            int i = segmentCount - 1 - step
            int entryOffset = f_segmentEntryOffset(i)
            int exitOffset = f_segmentExitOffset(i)
            int entryTime = f_segmentEntryTime(i)
            int exitTime = f_segmentExitTime(i)
            int side = f_segmentSide(i)
            bool geometryValid = f_isDirectionalSide(side) and f_isSeasonalDiscoveryWindow(entryOffset, exitOffset) and not na(entryTime) and not na(exitTime) and entryTime < exitTime
            float segmentScore = na
            int sampleCount = 0
            if geometryValid
                [evaluatedSamples, _, _, _, _, _, _, _, _, _, _, _, _, _, _, longScore, shortScore] = f_evaluateSeasonalWindow(anchorOffsets, entryOffset, exitOffset)
                segmentScore := side == SEG_LONG ? longScore : shortScore
                sampleCount := evaluatedSamples
            // Structural validation asks only whether the canonical window and
            // enough valid history exist to describe the phenomenon. Quality,
            // winrate, return, plateau, and holdout never remove map geometry.
            bool structuralDataValid = geometryValid and sampleCount > 0 and not na(segmentScore)
            if not structuralDataValid
                f_removeSegment(i)
            else
                f_setSegmentValidation(i, segmentScore, f_rawEdgeGrade(segmentScore), SEG_STATUS_WATCH, "NOT_EVALUATED")
    f_sortSegmentsForDeterministicDisplay()
    // Chronological deterministic order is retained; overflow is never silent.
    bool truncated = f_segmentCount() > MAX_CANONICAL_SEASONAL_ZONES
    while f_segmentCount() > MAX_CANONICAL_SEASONAL_ZONES
        f_removeSegment(f_segmentCount() - 1)
    truncated

// Eligibility is a selection layer over immutable canonical geometry.
f_applySegmentEligibility(array<int> anchorOffsets, array<SeasonalZone> zones) =>
    int segmentCount = f_segmentCount()
    if segmentCount > 0
        for i = 0 to segmentCount - 1
            int side = f_segmentSide(i)
            int entryOffset = f_segmentEntryOffset(i)
            int exitOffset = f_segmentExitOffset(i)
            [qualityEligible, score, quality, _, _, _, _, _, _, _, _] = f_evaluateSelectedSegment(anchorOffsets, side, entryOffset, exitOffset)
            SeasonalZone canonical = i < array.size(zones) ? array.get(zones, i) : f_seasonalZoneNone()
            ZoneEligibilityResult eligibility = f_zoneEligibilityForQuality(canonical, qualityStrength, qualityEligible)
            int status = eligibility.eligible ? SEG_STATUS_TRADEABLE : SEG_STATUS_BLOCKED
            f_setSegmentValidation(i, score, quality, status, eligibility.reasonCode)

var array<SeasonalZone> seasonalZoneMap = array.new<SeasonalZone>()
var bool canonicalMapTruncated = false
var string seasonalZoneMapVintageId = ""
var int seasonalMapOriginDailyBarIndex = na
var int selectionCurrentMapOffset = na

f_rebuildSeasonalZoneMap(SeasonalModelVintage vintage, array<int> allAnchors, array<int> trainingAnchors, array<int> holdoutAnchors) =>
    array.clear(seasonalZoneMap)
    int segmentCount = f_segmentCount()
    if vintage.valid and segmentCount > 0
        for i = 0 to segmentCount - 1
            int side = f_segmentSide(i)
            int entryOffset = f_segmentEntryOffset(i)
            int exitOffset = f_segmentExitOffset(i)
            int entryTime = f_segmentEntryTime(i)
            int exitTime = f_segmentExitTime(i)
            int evidenceDirection = side == SEG_LONG ? DIR_LONG : DIR_SHORT
            // Canonical geometry is already fixed. Evidence cohorts are now
            // populated in explicit order before any eligibility is applied.
            DirectionalEvidence referenceEvidence = f_directionalEvidence(allAnchors, entryOffset, exitOffset, evidenceDirection)
            DirectionalEvidence trainingEvidence = f_directionalEvidence(trainingAnchors, entryOffset, exitOffset, evidenceDirection)
            [_, score, _, winRate, avgProfit, avgDrawdown, sqn, sampleCount, winningCount, _, _] = f_evaluateSelectedSegment(trainingAnchors, side, entryOffset, exitOffset)
            DirectionalEvidence holdoutEvidence = f_directionalEvidence(holdoutAnchors, entryOffset, exitOffset, evidenceDirection)
            HoldoutResult holdoutResult = f_holdoutResult(configuredHoldoutYears, holdoutEvidence)
            [plateauNeighborCount, plateauMinRatio, plateauAvgRatio, plateauWeakCount] = f_realPlateauDiagnostics(trainingAnchors, side, entryOffset, exitOffset, score)
            string plateauGrade = f_realPlateauGrade(plateauNeighborCount, plateauMinRatio, plateauAvgRatio, plateauWeakCount)
            EvidenceSnapshot evidence = f_evidenceSnapshotFromResults(configuredTrainingYears, trainingEvidence, plateauGrade, holdoutResult)
            string verificationPayload = f_buildDirectionalVerificationPayload(allAnchors, entryOffset, exitOffset, side == SEG_LONG, effectiveMetricRows)
            bool canonicalEvidenceAvailable = referenceEvidence.samples > 0 and trainingEvidence.samples > 0 and sampleCount > 0 and not na(score)
            if canonicalEvidenceAvailable
                SeasonalZone zone = f_seasonalZone(vintage, side, entryTime, exitTime, score, verificationPayload, plateauGrade, plateauNeighborCount, plateauMinRatio, plateauAvgRatio, plateauWeakCount, winningCount, sampleCount, winRate, avgProfit, avgDrawdown, sqn, referenceEvidence.samples, referenceEvidence.successes, referenceEvidence.successRate, referenceEvidence.avgReturn, evidence)
                if zone.valid
                    array.push(seasonalZoneMap, zone)
    // A partial map is invalid: canonical zones and structural segments are a
    // single index-aligned structure and must never drift after a skipped zone.
    if array.size(seasonalZoneMap) != segmentCount
        array.clear(seasonalZoneMap)

f_seasonalZoneMapInvariant(array<SeasonalZone> zones, string vintageId) =>
    int count = array.size(zones)
    bool valid = count == f_segmentCount() and (count == 0 or str.length(vintageId) > 0)
    if count > 0
        for i = 0 to count - 1
            SeasonalZone zone = array.get(zones, i)
            valid := valid and f_seasonalZoneInvariant(zone) and zone.modelVintageId == vintageId and zone.side == f_segmentSide(i) and zone.canonicalEntryTime == f_segmentEntryTime(i) and zone.canonicalExitTime == f_segmentExitTime(i)
            if valid and i > 0
                SeasonalZone previous = array.get(zones, i - 1)
                int previousSideRank = f_segmentSortKeySide(previous.side)
                int sideRank = f_segmentSortKeySide(zone.side)
                bool ordered = previous.canonicalEntryTime < zone.canonicalEntryTime or (previous.canonicalEntryTime == zone.canonicalEntryTime and (previousSideRank < sideRank or (previousSideRank == sideRank and previous.canonicalExitTime <= zone.canonicalExitTime)))
                valid := ordered and previous.zoneId != zone.zoneId
    valid

// Development-only signatures keep each pipeline boundary independently
// comparable. Geometry deliberately excludes Evidence, eligibility and view.
f_phase0CanonicalGeometryDigest(array<SeasonalZone> zones, string vintageId, bool truncated) =>
    string digest = vintageId + "|COUNT=" + str.tostring(array.size(zones)) + "|TRUNC=" + str.tostring(truncated)
    int count = array.size(zones)
    if count > 0
        for i = 0 to count - 1
            SeasonalZone zone = array.get(zones, i)
            digest += str.format(";{0}:{1}:{2}:{3}:{4}", i, zone.zoneId, zone.side, zone.canonicalEntryTime, zone.canonicalExitTime)
    digest

f_phase0EvidenceDigest(array<SeasonalZone> zones, string vintageId) =>
    string digest = vintageId + "|COUNT=" + str.tostring(array.size(zones))
    int count = array.size(zones)
    if count > 0
        for i = 0 to count - 1
            SeasonalZone zone = array.get(zones, i)
            EvidenceSnapshot evidence = zone.evidence
            digest += str.format(";{0}:{1}:SC={2}:REF={3}/{4}/{5}/{6}:TR={7}/{8}/{9}/{10}:HO={11}/{12}/{13}:PL={14}:HOS={15}", i, zone.zoneId, zone.score, zone.referenceSuccesses, zone.referenceSamples, zone.referenceWinRate, zone.referenceAvgReturn, evidence.trainingSuccesses, evidence.trainingSamples, evidence.trainingWilsonLower, evidence.trainingMedianOutcome, evidence.holdoutSuccesses, evidence.holdoutSamples, evidence.holdoutYears, zone.plateauGrade, evidence.holdoutStatus)
    digest

f_phase0EligibilityDigest(array<SeasonalZone> zones, string vintageId) =>
    string digest = vintageId + "|Q=" + str.tostring(qualityStrength) + "|WR=" + str.tostring(referenceMinWinRate)
    int count = array.size(zones)
    if count > 0
        for i = 0 to count - 1
            SeasonalZone zone = array.get(zones, i)
            int status = i < f_segmentCount() ? f_segmentStatus(i) : SEG_STATUS_BLOCKED
            string reason = i < f_segmentCount() ? f_segmentEligibilityReason(i) : "MAP_SEGMENT_MISMATCH"
            string quality = i < f_segmentCount() ? f_segmentQuality(i) : "D"
            ZoneEligibilityResult baseline = f_zoneBaselineEligibility(zone)
            digest += str.format(";{0}:{1}:ST={2}:WHY={3}:FQ={4}:BASE={5}/{6}", i, zone.zoneId, status, reason, quality, baseline.eligible, baseline.reasonCode)
    digest

f_phase0AnchorDigest(int forecastYear, int anchorTime, int forecastOriginBarsBack, array<int> anchors, int holdoutYears) =>
    int count = array.size(anchors)
    int validTraining = 0
    int validHoldout = 0
    string rows = ""
    if count > 0
        for i = 0 to count - 1
            int offset = array.get(anchors, i)
            int targetYear = forecastYear - i - 1
            string role = i < holdoutYears ? "HO" : "TR"
            string validity = na(offset) ? "INVALID" : "VALID"
            int resolvedTradingDay = not na(offset) ? time[offset] : na
            int relativeOffset = not na(offset) and not na(forecastOriginBarsBack) ? offset - forecastOriginBarsBack : na
            validHoldout += role == "HO" and not na(offset) ? 1 : 0
            validTraining += role == "TR" and not na(offset) ? 1 : 0
            rows += str.format(";{0}:{1}:{2}:DAY={3}:REL_OFF={4}", targetYear, role, validity, resolvedTradingDay, relativeOffset)
    int nominalTraining = math.max(0, count - holdoutYears)
    int resolvedOriginTradingDay = not na(forecastOriginBarsBack) ? time[forecastOriginBarsBack] : na
    "FY=" + str.tostring(forecastYear) + "|ORIGIN=" + str.tostring(anchorTime) + "|ORIGIN_DAY=" + str.tostring(resolvedOriginTradingDay) + "|TR_VALID=" + str.tostring(validTraining) + "/" + str.tostring(nominalTraining) + "|HO_VALID=" + str.tostring(validHoldout) + "/" + str.tostring(holdoutYears) + rows

// Completed forecasts are references into the immutable map, not expired
// display locks. Rebuilding this bounded ID view never mutates zone evidence.
f_syncCompletedForecasts(array<SeasonalZone> zones, int currentTime, array<string> completedZoneIds) =>
    array.clear(completedZoneIds)
    int mapSize = array.size(zones)
    if mapSize > 0 and not na(currentTime)
        for i = 0 to mapSize - 1
            SeasonalZone zone = array.get(zones, i)
            if f_zoneLifecycle(currentTime, zone) == "COMPLETED"
                array.push(completedZoneIds, zone.zoneId)

f_zoneWithinTimeHorizon(SeasonalZone zone, int currentTime, int horizonDays) =>
    string lifecycle = f_zoneLifecycle(currentTime, zone)
    lifecycle == "ACTIVE" or (lifecycle == "PENDING" and zone.canonicalEntryTime <= f_projectMarketDailyTime(currentTime, horizonDays))

f_zoneDisplayModeEligible(SeasonalZone zone) =>
    useLongShortMode or (useLongOnlyMode and zone.side == SEG_LONG) or (useShortOnlyMode and zone.side == SEG_SHORT)

f_zonePrimaryModeEligible(SeasonalZone zone) =>
    useBestZoneMode or f_zoneDisplayModeEligible(zone)

f_zoneWithinCurrentView(SeasonalZone zone, int currentTime) =>
    useFullYearView or (useHorizonView and f_zoneWithinTimeHorizon(zone, currentTime, scanHorizonDays))

// Lifecycle visibility is a pure projection of canonical structure plus the
// current view. Direction mode is applied by the registry rebuild so Best Zone
// can be reduced afterward without placing Primary state in this predicate.
f_zoneVisibleForCurrentView(SeasonalZone zone, int segmentIndex, int currentTime) =>
    bool segmentAligned = segmentIndex >= 0 and segmentIndex < f_segmentCount() and zone.side == f_segmentSide(segmentIndex) and zone.canonicalEntryTime == f_segmentEntryTime(segmentIndex) and zone.canonicalExitTime == f_segmentExitTime(segmentIndex)
    bool staticEligible = segmentAligned and f_segmentStatus(segmentIndex) == SEG_STATUS_TRADEABLE
    f_seasonalZoneInvariant(zone) and staticEligible and f_zoneWithinCurrentView(zone, currentTime)

f_visibleZoneNone() =>
    VisibleZone.new(false, "", SEG_NONE, SEG_STATUS_BLOCKED, 1, na, na, na, na, TIME_SOURCE_NONE, TIME_SOURCE_NONE)

f_visibleZoneFromCanonical(SeasonalZone canonical, int segmentIndex, int mapOriginDailyBarIndex, int currentDailyBarIndex, int currentDailyTime) =>
    int status = not na(segmentIndex) ? f_segmentStatus(segmentIndex) : SEG_STATUS_BLOCKED
    int entryOffset = not na(segmentIndex) ? f_segmentEntryOffset(segmentIndex) : na
    int exitOffset = not na(segmentIndex) ? f_segmentExitOffset(segmentIndex) : na
    int entryTargetIndex = not na(mapOriginDailyBarIndex) and not na(entryOffset) ? mapOriginDailyBarIndex + entryOffset : na
    int exitTargetIndex = not na(mapOriginDailyBarIndex) and not na(exitOffset) ? mapOriginDailyBarIndex + exitOffset : na
    int entrySource = not na(segmentIndex) ? f_segmentEntryTimeSource(segmentIndex) : TIME_SOURCE_NONE
    int exitSource = not na(segmentIndex) ? f_segmentExitTimeSource(segmentIndex) : TIME_SOURCE_NONE
    bool sourcesValid = (entrySource == TIME_SOURCE_PROJECTED or entrySource == TIME_SOURCE_ACTUAL) and (exitSource == TIME_SOURCE_PROJECTED or exitSource == TIME_SOURCE_ACTUAL)
    bool viewVisible = f_zoneVisibleForCurrentView(canonical, segmentIndex, currentDailyTime)
    bool lifecycleTargetValid = useFullYearView or currentDailyBarIndex <= exitTargetIndex
    bool valid = viewVisible and sourcesValid and not na(entryTargetIndex) and not na(exitTargetIndex) and entryTargetIndex < exitTargetIndex and lifecycleTargetValid
    valid ? VisibleZone.new(true, canonical.zoneId, canonical.side, status, qualityGradeToRank(f_segmentQuality(segmentIndex)), entryTargetIndex, exitTargetIndex, canonical.canonicalEntryTime, canonical.canonicalExitTime, entrySource, exitSource) : f_visibleZoneNone()

f_sameZoneId(VisibleZone zone, string zoneId) =>
    zone.valid and str.length(zoneId) > 0 and zone.zoneId == zoneId

f_visibleRegistryHasZone(array<VisibleZone> registry, string zoneId) =>
    bool found = false
    int registrySize = array.size(registry)
    if registrySize > 0
        for i = 0 to registrySize - 1
            if f_sameZoneId(array.get(registry, i), zoneId)
                found := true
                break
    found

f_encodeVisibleRegistry(array<VisibleZone> registry, string modelVintageId, int generation) =>
    string payload = str.format("VR1,{0},{1},{2},{3}", modelVintageId, generation, zoneViewRange, projectedZoneMode)
    int n = array.size(registry)
    if n > 0
        for i = 0 to n - 1
            VisibleZone z = array.get(registry, i)
            string row = str.format("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}", z.zoneId, f_encInt(z.side), f_encInt(z.scannerStatus), f_encInt(z.qualityCode), f_encInt(z.entryTargetDailyBarIndex), f_encInt(z.exitTargetDailyBarIndex), f_encInt(z.entryTime), f_encInt(z.exitTime), f_encInt(z.entryTimeSource), f_encInt(z.exitTimeSource))
            payload += ";" + row
    payload

f_decodeVisibleRegistry(string payload, array<VisibleZone> registry, string expectedModelVintageId, int expectedGeneration, int currentDailyBarIndex) =>
    array<string> rows = str.split(payload, ";")
    int n = array.size(rows)
    array<VisibleZone> decodedRegistry = array.new<VisibleZone>()
    bool payloadValid = false
    if str.length(payload) > 0 and n > 0
        array<string> header = str.split(array.get(rows, 0), ",")
        payloadValid := array.size(header) == 5 and array.get(header, 0) == "VR1" and array.get(header, 1) == expectedModelVintageId and f_parseInt(array.get(header, 2)) == expectedGeneration and array.get(header, 3) == zoneViewRange and array.get(header, 4) == projectedZoneMode
        if payloadValid and n > 1
            for i = 1 to n - 1
                array<string> f = str.split(array.get(rows, i), ",")
                if array.size(f) != 10
                    payloadValid := false
                    break
                string zoneId = array.get(f, 0)
                int side = f_parseInt(array.get(f, 1))
                int entryTarget = f_parseInt(array.get(f, 4))
                int exitTarget = f_parseInt(array.get(f, 5))
                int entryTime = f_parseInt(array.get(f, 6))
                int exitTime = f_parseInt(array.get(f, 7))
                int entrySource = f_parseInt(array.get(f, 8))
                int exitSource = f_parseInt(array.get(f, 9))
                bool sourcesValid = (entrySource == TIME_SOURCE_PROJECTED or entrySource == TIME_SOURCE_ACTUAL) and (exitSource == TIME_SOURCE_PROJECTED or exitSource == TIME_SOURCE_ACTUAL)
                bool lifecycleTargetValid = useFullYearView or currentDailyBarIndex <= exitTarget
                bool rowValid = str.length(zoneId) > 0 and str.contains(zoneId, expectedModelVintageId) and f_isDirectionalSide(side) and not na(entryTarget) and not na(exitTarget) and entryTarget < exitTarget and lifecycleTargetValid and not na(entryTime) and not na(exitTime) and sourcesValid and not f_visibleRegistryHasZone(decodedRegistry, zoneId)
                if rowValid
                    array.push(decodedRegistry, VisibleZone.new(true, zoneId, side, f_parseInt(array.get(f, 2)), f_parseInt(array.get(f, 3)), entryTarget, exitTarget, entryTime, exitTime, entrySource, exitSource))
                else
                    payloadValid := false
                    break
    if payloadValid
        array.clear(registry)
        int decodedCount = array.size(decodedRegistry)
        if decodedCount > 0
            for i = 0 to decodedCount - 1
                array.push(registry, array.get(decodedRegistry, i))
    payloadValid

f_sortVisibleRegistry(array<VisibleZone> registry) =>
    int n = array.size(registry)
    if n > 1
        for pass = 0 to n - 2
            for i = 0 to n - 2 - pass
                VisibleZone a = array.get(registry, i)
                VisibleZone b = array.get(registry, i + 1)
                int aSideRank = f_segmentSortKeySide(a.side)
                int bSideRank = f_segmentSortKeySide(b.side)
                bool swap = a.entryTime > b.entryTime or (a.entryTime == b.entryTime and (a.exitTime > b.exitTime or (a.exitTime == b.exitTime and aSideRank > bSideRank)))
                if swap
                    array.set(registry, i, b)
                    array.set(registry, i + 1, a)

f_rebuildVisibleZoneRegistry(array<VisibleZone> registry, array<SeasonalZone> zones, int primaryMapIndex, int mapOriginDailyBarIndex, int currentDailyBarIndex, int currentDailyTime) =>
    array.clear(registry)
    int zoneCount = array.size(zones)
    if zoneCount > 0
        for i = 0 to zoneCount - 1
            SeasonalZone canonical = array.get(zones, i)
            bool bestZoneCandidate = useBestZoneMode and not na(primaryMapIndex) and i == primaryMapIndex
            bool directionEligible = useBestZoneMode ? bestZoneCandidate : f_zoneDisplayModeEligible(canonical)
            VisibleZone visible = directionEligible ? f_visibleZoneFromCanonical(canonical, i, mapOriginDailyBarIndex, currentDailyBarIndex, currentDailyTime) : f_visibleZoneNone()
            if visible.valid
                array.push(registry, visible)
    f_sortVisibleRegistry(registry)

// Dynamic registry signature is downstream from every static digest. It may
// change only with lifecycle, view range, horizon, or direction mode.
f_phase0RegistryDigest(array<SeasonalZone> zones, array<VisibleZone> registry, int primaryMapIndex, int currentTime) =>
    string digest = "T=" + str.tostring(currentTime) + "|VIEW=" + zoneViewRange + "|H=" + str.tostring(scanHorizonDays) + "|MODE=" + projectedZoneMode
    int count = array.size(zones)
    if count > 0
        for i = 0 to count - 1
            SeasonalZone zone = array.get(zones, i)
            string lifecycle = f_zoneLifecycle(currentTime, zone)
            bool withinHorizon = f_zoneWithinTimeHorizon(zone, currentTime, scanHorizonDays)
            bool displayEligible = useBestZoneMode ? not na(primaryMapIndex) and i == primaryMapIndex : f_zoneDisplayModeEligible(zone)
            bool registryMember = f_visibleRegistryHasZone(registry, zone.zoneId)
            digest += str.format(";{0}:{1}:{2}:LC={3}:HZ={4}:DM={5}:MEM={6}", i, zone.zoneId, zone.side, lifecycle, withinHorizon, displayEligible, registryMember)
    digest

f_primaryZoneMapIndex(int currentTime) =>
    int result = na
    int bestLifecycleRank = 9
    int bestTime = na
    int bestQualityRank = -1
    float bestScore = na
    int mapSize = array.size(seasonalZoneMap)
    if mapSize > 0
        for i = 0 to mapSize - 1
            SeasonalZone zone = array.get(seasonalZoneMap, i)
            string lifecycle = f_zoneLifecycle(currentTime, zone)
            bool inCurrentView = f_zoneWithinCurrentView(zone, currentTime)
            bool eligible = i < f_segmentCount() and f_segmentStatus(i) == SEG_STATUS_TRADEABLE
            bool displayEligible = f_zonePrimaryModeEligible(zone)
            bool relevant = inCurrentView and eligible and displayEligible
            int lifecycleRank = lifecycle == "ACTIVE" ? 0 : lifecycle == "PENDING" ? 1 : 2
            int timeRank = lifecycle == "ACTIVE" ? zone.canonicalExitTime : lifecycle == "PENDING" ? zone.canonicalEntryTime : -zone.canonicalExitTime
            int qualityRank = qualityGradeToRank(f_segmentQuality(i))
            // Strict comparisons preserve the earlier canonical-map index as
            // the deterministic final tie-breaker when all ranks are equal.
            bool better = relevant and (na(result) or lifecycleRank < bestLifecycleRank or (lifecycleRank == bestLifecycleRank and (timeRank < bestTime or (timeRank == bestTime and (qualityRank > bestQualityRank or (qualityRank == bestQualityRank and zone.score > bestScore))))))
            if better
                result := i
                bestLifecycleRank := lifecycleRank
                bestTime := timeRank
                bestQualityRank := qualityRank
                bestScore := zone.score
    result

f_mapNoEdgeReason(int currentTime) =>
    string reason = array.size(seasonalZoneMap) == 0 ? "NO_STRUCTURAL_ZONE" : "NO_CANDIDATE"
    bool eligibleOutsideHorizon = false
    int mapSize = array.size(seasonalZoneMap)
    if mapSize > 0
        for i = 0 to mapSize - 1
            SeasonalZone zone = array.get(seasonalZoneMap, i)
            bool displayEligible = f_zonePrimaryModeEligible(zone)
            bool eligible = i < f_segmentCount() and f_segmentStatus(i) == SEG_STATUS_TRADEABLE
            eligibleOutsideHorizon := eligibleOutsideHorizon or useHorizonView and displayEligible and eligible and not f_zoneWithinTimeHorizon(zone, currentTime, scanHorizonDays)
            if displayEligible and not eligible and reason == "NO_CANDIDATE" and i < f_segmentCount()
                reason := f_segmentEligibilityReason(i)
    eligibleOutsideHorizon ? "OUTSIDE_HORIZON" : reason

f_segmentStatusText(int status) =>
    status == SEG_STATUS_TRADEABLE ? "Tradeable" : status == SEG_STATUS_WATCH ? "Watch" : status == SEG_STATUS_WEAK ? "Weak" : "Blocked"

f_qualityModeText(int q) =>
    q == 0 ? "Q0 Reference" : q <= 20 ? "Q" + str.tostring(q) + " Explore" : q <= 50 ? "Q" + str.tostring(q) + " Review" : q <= 70 ? "Q" + str.tostring(q) + " Standard" : q <= 90 ? "Q" + str.tostring(q) + " Strict" : "Q100 Very Strict"

f_buildSeasonalProfileSegments(array<int> anchorOffsets, int profileStartOffset, int profileEndOffset, int mapOriginTime) =>
    f_clearSeasonalProfile()
    f_clearSegments()
    if profileEndOffset >= profileStartOffset
        for offsetFromOrigin = profileStartOffset to profileEndOffset
            [avgStep, signConsistency] = f_profileStepFromAnchors(anchorOffsets, offsetFromOrigin)
            array.push(profileOffset, offsetFromOrigin)
            array.push(profileStep, avgStep)
            array.push(profileConfidence, signConsistency)
        int profileSize = array.size(profileStep)
        if profileSize > 0
            for i = 0 to profileSize - 1
                float smoothSum = 0.0
                int smoothSamples = 0
                if i > 0
                    float prevStep = array.get(profileStep, i - 1)
                    if not na(prevStep)
                        smoothSum += prevStep
                        smoothSamples += 1
                float currentStep = array.get(profileStep, i)
                if not na(currentStep)
                    smoothSum += currentStep
                    smoothSamples += 1
                if i < profileSize - 1
                    float nextStep = array.get(profileStep, i + 1)
                    if not na(nextStep)
                        smoothSum += nextStep
                        smoothSamples += 1
                array.push(profileSmoothStep, smoothSamples > 0 ? smoothSum / smoothSamples : na)
            float absStepSum = 0.0
            int absStepSamples = 0
            for i = 0 to array.size(profileSmoothStep) - 1
                float smoothStep = array.get(profileSmoothStep, i)
                if not na(smoothStep)
                    absStepSum += math.abs(smoothStep)
                    absStepSamples += 1
            float avgAbsStep = absStepSamples > 0 ? absStepSum / absStepSamples : na
            float dirThreshold = math.max(nz(avgAbsStep, 0.0) * STRUCTURAL_DIR_THRESHOLD_FACTOR, 0.01)
            for i = 0 to profileSize - 1
                array.push(profileState, f_stepToState(array.get(profileSmoothStep, i), array.get(profileConfidence, i), dirThreshold))
            int currentState = SEG_NONE
            int currentStartOffset = na
            int previousOffset = na
            for i = 0 to array.size(profileState) - 1
                int state = array.get(profileState, i)
                int currentOffset = array.get(profileOffset, i)
                if state != currentState
                    if currentState != SEG_NONE
                        f_addRawSegment(currentStartOffset, previousOffset, currentState, mapOriginTime)
                    currentState := state
                    currentStartOffset := state != SEG_NONE ? currentOffset : na
                previousOffset := currentOffset
            if currentState != SEG_NONE
                f_addRawSegment(currentStartOffset, previousOffset, currentState, mapOriginTime)

var string finalBias = "NO EDGE"
var string finalBiasQuality = "D"
var string finalBiasWindow = "-"
var float finalBiasScore = na
var int scanAnchorTime = na
var array<int> allAnchorOffsets = array.new_int()
var array<int> trainingAnchorOffsets = array.new_int()
var array<int> holdoutAnchorOffsets = array.new_int()
var int cohortNominalTrainingYears = 0
var int cohortNominalHoldoutYears = 0
var int cohortValidTrainingAnchors = 0
var int cohortValidHoldoutAnchors = 0
var bool renderHistoricalLongFinal = false
var bool renderHistoricalShortFinal = false
var int renderedHistoricalLongCount = 0
var int renderedHistoricalShortCount = 0
var array<string> completedForecastZoneIds = array.new_string()

// Stable Primary analytical locks for panels, risk, potential, and alerts. They
// are deliberately not an authority for visibleZoneRegistry membership.
var LockedZone lockedLong = f_lockedZoneNone()
var LockedZone lockedShort = f_lockedZoneNone()
var array<VisibleZone> visibleZoneRegistry = array.new<VisibleZone>()

f_visibleRegistryOwnsZoneId(string zoneId) =>
    bool registered = false
    if array.size(visibleZoneRegistry) > 0
        for i = 0 to array.size(visibleZoneRegistry) - 1
            VisibleZone zone = array.get(visibleZoneRegistry, i)
            if zone.valid and zone.zoneId == zoneId
                registered := true
                break
    registered
var int lockedRegistryLastDailyBarIndex = na

// Phase-0 internal diagnostics. These values deliberately have no renderer or
// alert consumers, so the baseline chart behavior remains unchanged.
var string phase0AnchorDigest = ""
var string phase0CanonicalGeometryDigest = ""
var string phase0EvidenceDigest = ""
var string phase0EligibilityDigest = ""
var string phase0RegistryDigest = ""
var label phase0CaptureSurfaceLabel = na
var int scanGeneration = 0
var int registryGeneration = 0
var int lastImportedRegistryGeneration = na
var string lastImportedVisiblePayload = ""
// Versioned final Daily registry channel. Intraday validates its vintage,
// generation, view range, and direction mode before replacing local state.
var string visibleRegistryPayload = ""
var DailyScanSnapshot scanSnapshot = f_dailyScanSnapshotNone()
var int lastScheduledDailyTime = na

bool calcLongEnabled = true
bool calcShortEnabled = true

// Replay-safe Daily scheduler: bootstrap once at the history boundary, then
// accept only a newly confirmed tail bar. It never walks all confirmed history
// and never runs intrabar. Dedupe is committed only with a valid publication.
bool bootstrapDailyScan = isDailyChart and barstate.islastconfirmedhistory
bool confirmedTailDailyScan = isDailyChart and barstate.islast and barstate.isconfirmed
int requestedForecastYear = not na(f_seasonalDateTsFromBar(0)) ? year(f_seasonalDateTsFromBar(0), "UTC") : 0
string requestedVintageId = f_seasonalModelVintageId(syminfo.tickerid, requestedForecastYear, lookbackYears, configuredTrainingYears, configuredHoldoutYears)
bool modelVintageChanged = str.length(requestedVintageId) > 0 and requestedVintageId != seasonalZoneMapVintageId
bool shouldRunLocalDailyScan = (bootstrapDailyScan or confirmedTailDailyScan) and modelVintageChanged
bool completedScanCohortValid = false

// Daily Long/Short scanner starts here; renderer and panel logic stay outside this block.
if shouldRunLocalDailyScan
    // Resolve into attempt-local arrays first. A correctly sized array may still
    // contain na anchors and is never proof of a complete model cohort.
    int anchorYear = requestedForecastYear
    int candidateScanAnchorTime = f_forecastYearOrigin(anchorYear)
    int anchorMonth = month(candidateScanAnchorTime, "UTC")
    int anchorDay = dayofmonth(candidateScanAnchorTime, "UTC")
    int maxBarsBack = math.min(bar_index, effectiveScanYears * 370 + MAX_ANCHOR_SEARCH_BARS + FORECAST_MAP_TRADING_DAYS)
    int forecastOriginBarsBack = findHistoricalAnchorOffset(anchorYear, anchorMonth, anchorDay, maxBarsBack, MAX_ANCHOR_SEARCH_BARS)
    int candidateMapOriginDailyBarIndex = not na(forecastOriginBarsBack) ? bar_index - forecastOriginBarsBack : bar_index
    array<int> candidateAllAnchorOffsets = array.new_int()
    array<int> candidateTrainingAnchorOffsets = array.new_int()
    array<int> candidateHoldoutAnchorOffsets = array.new_int()
    int candidateValidTrainingAnchors = 0
    int candidateValidHoldoutAnchors = 0
    for yearBack = 1 to lookbackYears
        int targetYear = anchorYear - yearBack
        int historicalAnchorOffset = findHistoricalAnchorOffset(targetYear, anchorMonth, anchorDay, maxBarsBack, MAX_ANCHOR_SEARCH_BARS)
        array.push(candidateAllAnchorOffsets, historicalAnchorOffset)
        bool isHoldoutYear = yearBack <= configuredHoldoutYears
        if isHoldoutYear
            array.push(candidateHoldoutAnchorOffsets, historicalAnchorOffset)
            candidateValidHoldoutAnchors += not na(historicalAnchorOffset) ? 1 : 0
        else
            array.push(candidateTrainingAnchorOffsets, historicalAnchorOffset)
            candidateValidTrainingAnchors += not na(historicalAnchorOffset) ? 1 : 0

    bool candidateCohortComplete = not na(candidateScanAnchorTime) and candidateValidTrainingAnchors == configuredTrainingYears and candidateValidHoldoutAnchors == configuredHoldoutYears
    if ENABLE_PHASE0_DIAGNOSTICS
        phase0AnchorDigest := f_phase0AnchorDigest(anchorYear, candidateScanAnchorTime, forecastOriginBarsBack, candidateAllAnchorOffsets, configuredHoldoutYears)

    if candidateCohortComplete
        // Back up the published generation. Scanner construction still uses the
        // established single pipeline, but no candidate becomes authoritative
        // until its map/segment invariant is complete.
        array<SeasonalSegment> previousSegments = array.copy(seasonalSegments)
        array<SeasonalZone> previousMap = array.copy(seasonalZoneMap)
        string previousMapVintageId = seasonalZoneMapVintageId
        bool previousMapTruncated = canonicalMapTruncated
        f_clearSegments()
        hasLong := false
        hasShort := false
        bestLongScore := na
        bestShortScore := na
        int profileStartOffset = 0
        int profileEndOffset = FORECAST_MAP_TRADING_DAYS - 1
        f_buildSeasonalProfileSegments(candidateTrainingAnchorOffsets, profileStartOffset, profileEndOffset, candidateScanAnchorTime)
        f_smoothRawSegments(math.max(2, minTradeDurationDays))
        canonicalMapTruncated := f_validateStructuralSegments(candidateTrainingAnchorOffsets)
        SeasonalModelVintage mapVintage = f_seasonalModelVintage(syminfo.tickerid, anchorYear, lookbackYears, configuredTrainingYears, configuredHoldoutYears)
        f_rebuildSeasonalZoneMap(mapVintage, candidateAllAnchorOffsets, candidateTrainingAnchorOffsets, candidateHoldoutAnchorOffsets)
        f_applySegmentEligibility(candidateTrainingAnchorOffsets, seasonalZoneMap)
        bool candidateMapComplete = f_seasonalZoneMapInvariant(seasonalZoneMap, mapVintage.id)
        if candidateMapComplete
            scanAnchorTime := candidateScanAnchorTime
            seasonalMapOriginDailyBarIndex := candidateMapOriginDailyBarIndex
            selectionCurrentMapOffset := bar_index - seasonalMapOriginDailyBarIndex
            allAnchorOffsets := array.copy(candidateAllAnchorOffsets)
            trainingAnchorOffsets := array.copy(candidateTrainingAnchorOffsets)
            holdoutAnchorOffsets := array.copy(candidateHoldoutAnchorOffsets)
            cohortNominalHoldoutYears := configuredHoldoutYears
            cohortNominalTrainingYears := configuredTrainingYears
            cohortValidTrainingAnchors := candidateValidTrainingAnchors
            cohortValidHoldoutAnchors := candidateValidHoldoutAnchors
            seasonalZoneMapVintageId := mapVintage.id
            completedScanCohortValid := true
            if ENABLE_PHASE0_DIAGNOSTICS
                phase0CanonicalGeometryDigest := f_phase0CanonicalGeometryDigest(seasonalZoneMap, seasonalZoneMapVintageId, canonicalMapTruncated)
                phase0EvidenceDigest := f_phase0EvidenceDigest(seasonalZoneMap, seasonalZoneMapVintageId)
                phase0EligibilityDigest := f_phase0EligibilityDigest(seasonalZoneMap, seasonalZoneMapVintageId)
        else
            seasonalSegments := previousSegments
            seasonalZoneMap := previousMap
            seasonalZoneMapVintageId := previousMapVintageId
            canonicalMapTruncated := previousMapTruncated

string selectedPlateauGrade = "Unknown"
int selectedRealPlateauNeighborCount = 0
float selectedRealPlateauMinRatio = na
float selectedRealPlateauAvgRatio = na
int selectedRealPlateauWeakCount = 0
string selectedRealPlateauDiag = "Real Plat n/a"
EvidenceSnapshot selectedEvidenceSnapshot = f_evidenceSnapshotNone()

// All visible/panel-facing best fields are now derived from the selected Primary Zone.
int primarySegmentIndexForDaily = f_primaryZoneMapIndex(time)
int primarySide = not na(primarySegmentIndexForDaily) ? f_segmentSide(primarySegmentIndexForDaily) : SEG_NONE
int primaryEntryOffset = not na(primarySegmentIndexForDaily) ? f_segmentEntryOffset(primarySegmentIndexForDaily) : na
int primaryExitOffset = not na(primarySegmentIndexForDaily) ? f_segmentExitOffset(primarySegmentIndexForDaily) : na
int primaryEntryTime = not na(primarySegmentIndexForDaily) ? f_segmentEntryTime(primarySegmentIndexForDaily) : na
int primaryExitTime = not na(primarySegmentIndexForDaily) ? f_segmentExitTime(primarySegmentIndexForDaily) : na
int primaryEntryTimeSource = not na(primarySegmentIndexForDaily) ? f_segmentEntryTimeSource(primarySegmentIndexForDaily) : TIME_SOURCE_NONE
int primaryExitTimeSource = not na(primarySegmentIndexForDaily) ? f_segmentExitTimeSource(primarySegmentIndexForDaily) : TIME_SOURCE_NONE
int primaryMapOriginTradingDay = f_tradingDayIdentity(scanAnchorTime)
string primaryQuality = not na(primarySegmentIndexForDaily) ? f_segmentQuality(primarySegmentIndexForDaily) : "D"
int primaryStatus = not na(primarySegmentIndexForDaily) ? f_segmentStatus(primarySegmentIndexForDaily) : SEG_STATUS_BLOCKED
bool primaryIsActive = f_isDirectionalSide(primarySide) and primaryEntryOffset <= selectionCurrentMapOffset and primaryExitOffset >= selectionCurrentMapOffset
bool primaryStructurallyValid = f_isDirectionalSide(primarySide) and not na(primaryEntryOffset) and not na(primaryExitOffset) and not na(primaryEntryTime) and not na(primaryExitTime)
SeasonalZone primaryCanonicalZone = primaryStructurallyValid and primarySegmentIndexForDaily < array.size(seasonalZoneMap) ? array.get(seasonalZoneMap, primarySegmentIndexForDaily) : f_seasonalZoneNone()
bool primaryMetricsValid = primaryCanonicalZone.valid
float primaryMetricsScore = primaryMetricsValid ? primaryCanonicalZone.score : na
float primaryMetricsWinRate = primaryMetricsValid ? primaryCanonicalZone.winRate : na
float primaryMetricsAvgProfit = primaryMetricsValid ? primaryCanonicalZone.avgProfit : na
float primaryMetricsAvgDrawdown = primaryMetricsValid ? primaryCanonicalZone.avgDrawdown : na
float primaryMetricsSqn = primaryMetricsValid ? primaryCanonicalZone.sqn : na
int primaryMetricsSampleCount = primaryMetricsValid ? primaryCanonicalZone.validTrades : 0
int primaryMetricsWinningCount = primaryMetricsValid ? primaryCanonicalZone.winningTrades : 0
float primaryMetricsEntryPrice = primaryStructurallyValid ? f_getWindowEntryPrice(primaryEntryOffset) : na
int primaryRealPlateauNeighborCount = primaryMetricsValid ? primaryCanonicalZone.plateauNeighborCount : 0
float primaryRealPlateauMinRatio = primaryMetricsValid ? primaryCanonicalZone.plateauMinRatio : na
float primaryRealPlateauAvgRatio = primaryMetricsValid ? primaryCanonicalZone.plateauAvgRatio : na
int primaryRealPlateauWeakCount = primaryMetricsValid ? primaryCanonicalZone.plateauWeakCount : 0
string primaryRealPlateauGrade = primaryMetricsValid ? primaryCanonicalZone.plateauGrade : "Unknown"
// Segment eligibility was finalized by f_applySegmentEligibility(); Primary
// selection consumes that decision and must not run a second quality gate.
bool primaryFinalCandidateValid = primaryStructurallyValid and primaryCanonicalZone.valid and primaryStatus == SEG_STATUS_TRADEABLE
string primaryNoEdgeReason = primaryFinalCandidateValid ? "Edge selected" : f_mapNoEdgeReason(time)
if isDailyChart
    selectedPlateauGrade := primaryRealPlateauGrade
    selectedRealPlateauNeighborCount := primaryRealPlateauNeighborCount
    selectedRealPlateauMinRatio := primaryRealPlateauMinRatio
    selectedRealPlateauAvgRatio := primaryRealPlateauAvgRatio
    selectedRealPlateauWeakCount := primaryRealPlateauWeakCount
hasLong := false
hasShort := false
bestLongEntryOffset := na
bestLongExitOffset := na
bestLongDuration := na
bestLongValidTrades := 0
bestLongWinningTrades := 0
bestLongWinRatePct := na
bestLongAvgProfitPct := na
bestLongAvgDrawdownPct := na
bestLongSqn := na
bestLongScore := na
bestShortEntryOffset := na
bestShortExitOffset := na
bestShortDuration := na
bestShortValidTrades := 0
bestShortWinningTrades := 0
bestShortWinRatePct := na
bestShortAvgProfitPct := na
bestShortAvgDrawdownPct := na
bestShortSqn := na
bestShortScore := na

if primaryFinalCandidateValid and primarySide == SEG_LONG
    hasLong := true
    bestLongEntryOffset := primaryEntryOffset
    bestLongExitOffset := primaryExitOffset
    bestLongDuration := primaryExitOffset - primaryEntryOffset
    bestLongValidTrades := primaryMetricsSampleCount
    bestLongWinningTrades := primaryMetricsWinningCount
    bestLongWinRatePct := primaryMetricsWinRate
    bestLongAvgProfitPct := primaryMetricsAvgProfit
    bestLongAvgDrawdownPct := primaryMetricsAvgDrawdown
    bestLongSqn := primaryMetricsSqn
    bestLongScore := primaryMetricsScore
else if primaryFinalCandidateValid and primarySide == SEG_SHORT
    hasShort := true
    bestShortEntryOffset := primaryEntryOffset
    bestShortExitOffset := primaryExitOffset
    bestShortDuration := primaryExitOffset - primaryEntryOffset
    bestShortValidTrades := primaryMetricsSampleCount
    bestShortWinningTrades := primaryMetricsWinningCount
    bestShortWinRatePct := primaryMetricsWinRate
    bestShortAvgProfitPct := primaryMetricsAvgProfit
    bestShortAvgDrawdownPct := primaryMetricsAvgDrawdown
    bestShortSqn := primaryMetricsSqn
    bestShortScore := primaryMetricsScore
longSampleCoveragePct := hasLong ? (bestLongValidTrades / configuredTrainingYears) * 100.0 : na
shortSampleCoveragePct := hasShort ? (bestShortValidTrades / configuredTrainingYears) * 100.0 : na
longRecentWinRatePct := na
shortRecentWinRatePct := na
longOutlierImpactPct := na
shortOutlierImpactPct := na
longMedianProfitPct := na
shortMedianProfitPct := na
longQualityGrade := "D"
shortQualityGrade := "D"
longOverfitWarning := false
shortOverfitWarning := false

if enableQualityLayer and isViewTfSupported
    int recentYearsN = math.min(recentYearsCheck, configuredTrainingYears)
    if hasLong
        [longRecentWinRateCalc, longMedianProfitCalc, longOutlierImpactCalc, longOverfitWarningCalc, longQualityGradeCalc] = f_directionalDistributionQuality(trainingAnchorOffsets, bestLongEntryOffset, bestLongExitOffset, false, longSampleCoveragePct, recentYearsN)
        longRecentWinRatePct := longRecentWinRateCalc
        longMedianProfitPct := longMedianProfitCalc
        longOutlierImpactPct := longOutlierImpactCalc
        longOverfitWarning := longOverfitWarningCalc
        longQualityGrade := longQualityGradeCalc
    if hasShort
        [shortRecentWinRateCalc, shortMedianProfitCalc, shortOutlierImpactCalc, shortOverfitWarningCalc, shortQualityGradeCalc] = f_directionalDistributionQuality(trainingAnchorOffsets, bestShortEntryOffset, bestShortExitOffset, true, shortSampleCoveragePct, recentYearsN)
        shortRecentWinRatePct := shortRecentWinRateCalc
        shortMedianProfitPct := shortMedianProfitCalc
        shortOutlierImpactPct := shortOutlierImpactCalc
        shortOverfitWarning := shortOverfitWarningCalc
        shortQualityGrade := shortQualityGradeCalc

longZoneValid := primaryFinalCandidateValid and primarySide == SEG_LONG
longZoneMapOriginTime := longZoneValid ? scanAnchorTime : na
longZoneEntryMapOffset := longZoneValid ? primaryEntryOffset : na
longZoneExitMapOffset := longZoneValid ? primaryExitOffset : na
longZoneEntryPrice := longZoneValid ? primaryMetricsEntryPrice : na

shortZoneValid := primaryFinalCandidateValid and primarySide == SEG_SHORT
shortZoneMapOriginTime := shortZoneValid ? scanAnchorTime : na
shortZoneEntryMapOffset := shortZoneValid ? primaryEntryOffset : na
shortZoneExitMapOffset := shortZoneValid ? primaryExitOffset : na
shortZoneEntryPrice := shortZoneValid ? primaryMetricsEntryPrice : na

// Atomically publish only after every scanner-derived field for this run has
// been finalized. Until the next completed scan, all consumers keep this value.
if shouldRunLocalDailyScan
    string completedSource = primaryIsActive ? "ACTIVE_SEGMENT" : "PENDING_SEGMENT"
    SeasonalZone completedLongZone = longZoneValid ? primaryCanonicalZone : f_seasonalZoneNone()
    SeasonalZone completedShortZone = shortZoneValid ? primaryCanonicalZone : f_seasonalZoneNone()
    ZoneSelection completedLongSelection = f_zoneSelection(completedLongZone.valid, completedLongZone, qualityGradeToRank(primaryQuality), completedLongZone.valid ? completedSource : "NONE", longZoneMapOriginTime, completedLongZone.valid ? primaryEntryTimeSource : TIME_SOURCE_NONE, completedLongZone.valid ? primaryExitTimeSource : TIME_SOURCE_NONE, longZoneEntryMapOffset, longZoneExitMapOffset, longZoneEntryPrice, completedLongZone.valid ? primaryMapOriginTradingDay : na, completedLongZone.valid ? seasonalMapOriginDailyBarIndex : na, completedLongZone.valid ? scanGeneration + 1 : 0)
    ZoneSelection completedShortSelection = f_zoneSelection(completedShortZone.valid, completedShortZone, qualityGradeToRank(primaryQuality), completedShortZone.valid ? completedSource : "NONE", shortZoneMapOriginTime, completedShortZone.valid ? primaryEntryTimeSource : TIME_SOURCE_NONE, completedShortZone.valid ? primaryExitTimeSource : TIME_SOURCE_NONE, shortZoneEntryMapOffset, shortZoneExitMapOffset, shortZoneEntryPrice, completedShortZone.valid ? primaryMapOriginTradingDay : na, completedShortZone.valid ? seasonalMapOriginDailyBarIndex : na, completedShortZone.valid ? scanGeneration + 1 : 0)
    // Snapshot validity is strict cohort validity, never array-size validity.
    bool completedSnapshotValid = completedScanCohortValid and not na(scanAnchorTime) and cohortValidTrainingAnchors == configuredTrainingYears and cohortValidHoldoutAnchors == configuredHoldoutYears
    if completedSnapshotValid
        int completedGeneration = scanGeneration + 1
        scanSnapshot := DailyScanSnapshot.new(true, completedGeneration, primaryMapOriginTradingDay, scanAnchorTime, seasonalMapOriginDailyBarIndex, completedLongSelection, completedShortSelection, primaryFinalCandidateValid ? primarySide : SEG_NONE, primaryStatus, primaryNoEdgeReason, longSampleCoveragePct, longRecentWinRatePct, longMedianProfitPct, longOutlierImpactPct, longOverfitWarning, shortSampleCoveragePct, shortRecentWinRatePct, shortMedianProfitPct, shortOutlierImpactPct, shortOverfitWarning)
        scanGeneration := completedGeneration
        lastScheduledDailyTime := time
    else
        // Keep the scheduler uncommitted and retain an existing valid generation.
        // On bootstrap there is no previous generation, so expose SCAN_INCOMPLETE.
        if not scanSnapshot.valid
            scanSnapshot := DailyScanSnapshot.new(false, scanGeneration, primaryMapOriginTradingDay, scanAnchorTime, seasonalMapOriginDailyBarIndex, f_zoneSelectionNone(), f_zoneSelectionNone(), SEG_NONE, SEG_STATUS_BLOCKED, "SCAN_INCOMPLETE", na, na, na, na, false, na, na, na, na, false)

finalBias := "NO EDGE"
finalBiasQuality := "D"
finalBiasWindow := "-"
finalBiasScore := na
bool renderHistoricalLong = false
bool renderHistoricalShort = false
int dailyAnchorTime = f_dailyChartTsFromBar(0)
int dailyScanAnchorTime = na(scanAnchorTime) ? dailyAnchorTime : scanAnchorTime

bool viewHasLong = hasLong
bool viewHasShort = hasShort
int viewBestLongEntryOffset = bestLongEntryOffset
int viewBestLongExitOffset = bestLongExitOffset
int viewBestShortEntryOffset = bestShortEntryOffset
int viewBestShortExitOffset = bestShortExitOffset
float viewBestLongWinRatePct = bestLongWinRatePct
float viewBestShortWinRatePct = bestShortWinRatePct
float viewBestLongAvgProfitPct = bestLongAvgProfitPct
float viewBestShortAvgProfitPct = bestShortAvgProfitPct
float viewBestLongAvgDrawdownPct = bestLongAvgDrawdownPct
float viewBestShortAvgDrawdownPct = bestShortAvgDrawdownPct
float viewBestLongSqn = bestLongSqn
float viewBestShortSqn = bestShortSqn
int viewBestLongWinningTrades = bestLongWinningTrades
int viewBestLongValidTrades = bestLongValidTrades
int viewBestShortWinningTrades = bestShortWinningTrades
int viewBestShortValidTrades = bestShortValidTrades

float viewBestLongScore = bestLongScore
bool selectedLongZoneValid = false
string selectedLongZoneSource = "NONE"
int selectedLongZoneMapOriginTime = na
int selectedLongZoneEntryTime = na
int selectedLongZoneExitTime = na
int selectedLongZoneEntryTimeSource = TIME_SOURCE_NONE
int selectedLongZoneExitTimeSource = TIME_SOURCE_NONE
int selectedLongZoneEntryMapOffset = na
int selectedLongZoneExitMapOffset = na
float selectedLongZoneEntryPrice = na
float selectedLongZoneScore = na
float selectedLongZoneWinRate = na
float selectedLongZoneAvgProfit = na
float selectedLongZoneAvgDrawdown = na
float selectedLongZoneSqn = na
int selectedLongZoneWinningTrades = 0
int selectedLongZoneValidTrades = 0
string selectedLongZoneQuality = "D"
float viewBestShortScore = bestShortScore
bool selectedShortZoneValid = false
string selectedShortZoneSource = "NONE"
int selectedShortZoneMapOriginTime = na
int selectedShortZoneEntryTime = na
int selectedShortZoneExitTime = na
int selectedShortZoneEntryTimeSource = TIME_SOURCE_NONE
int selectedShortZoneExitTimeSource = TIME_SOURCE_NONE
int selectedShortZoneEntryMapOffset = na
int selectedShortZoneExitMapOffset = na
float selectedShortZoneEntryPrice = na
float selectedShortZoneScore = na
float selectedShortZoneWinRate = na
float selectedShortZoneAvgProfit = na
float selectedShortZoneAvgDrawdown = na
float selectedShortZoneSqn = na
int selectedShortZoneWinningTrades = 0
int selectedShortZoneValidTrades = 0
string selectedShortZoneQuality = "D"
float viewLongSampleCoveragePct = longSampleCoveragePct
float viewLongRecentWinRatePct = longRecentWinRatePct
float viewLongMedianProfitPct = longMedianProfitPct
float viewLongOutlierImpactPct = longOutlierImpactPct
bool viewLongOverfitWarning = longOverfitWarning
float viewShortSampleCoveragePct = shortSampleCoveragePct
float viewShortRecentWinRatePct = shortRecentWinRatePct
float viewShortMedianProfitPct = shortMedianProfitPct
float viewShortOutlierImpactPct = shortOutlierImpactPct
bool viewShortOverfitWarning = shortOverfitWarning
string viewLongQualityGrade = longQualityGrade
string viewShortQualityGrade = shortQualityGrade
string viewFinalBias = finalBias
string viewFinalBiasQuality = finalBiasQuality
string viewFinalBiasWindow = finalBiasWindow
float viewFinalBiasScore = finalBiasScore
int viewDailyAnchorTime = dailyScanAnchorTime
int viewCurrentDailyBarIndex = bar_index
int viewSnapshotGeneration = scanSnapshot.generation
float viewCurrentDailyClose = close
float viewCurrentDailyHigh = high
float viewCurrentDailyLow = low
int viewCurrentDailyTime = time
var ZoneDynamicContext selectedDynamicContext = f_zoneDynamicContextNone()
float viewWindowEntryPrice = na
int viewWindowEntryTime = na
int viewWindowExitTime = na
bool viewWindowIsPending = true
float viewCurrentMovePct = na
float viewMoveUsedPct = na
float viewRemainingPotentialPct = na
string viewMoveUsedState = "n/a"
float viewInvalidationMaeBasis = na
float viewInvalidationLevel = na
float viewDistanceToInvalidationPct = na
string viewInvalidationState = "n/a"
float viewSeasonalRR = na
string viewSeasonalRRState = "n/a"
float viewVolatilityFitScore = na
int viewVolRegimeCode = na
float viewPotentialScore = na
string viewPotentialState = "n/a"
string viewPotentialDirectionLabel = "-"
float viewEdgeRobustnessScore = na
string viewOutlierRisk = "n/a"
string viewEdgeStabilityLabel = "n/a"
string tradeabilityState = "n/a"
float viewRemainingMoveScore = na
float viewRRScore = na
float viewMoveUsedScore = na
float viewInvalidationScore = na
string viewQualitySummary = "n/a"
string viewSelectedFinalQualityGrade = "D"
float viewSelectedConfidenceWinRate = na
float viewSelectedSeparationScore = na
string viewSelectedSeparationGrade = "Blocked"
string viewSelectedRobustnessLabel = "n/a"
string viewTradeabilitySummary = "n/a"
string viewCompactEdgeSummary = "No Edge | Direction unclear"
string viewNoEdgeReason = "Direction unclear"
string viewNoEdgeReasonCode = "NO_CANDIDATE"
string viewPrimaryNoEdgeReason = "NO_CANDIDATE"
int viewPrimaryStatus = primaryStatus
bool canRenderFutureZones = isViewTfSupported and not na(viewDailyAnchorTime)
float viewLongMedianMae = na
float viewLongMae75 = na
float viewLongMedianMfe = na
float viewLongMfe75 = na
int viewLongMaeSampleCount = 0
int viewLongMfeSampleCount = 0
bool viewLongMaeMetricsAvailable = false
bool viewLongMfeMetricsAvailable = false
float viewShortMedianMae = na
float viewShortMae75 = na
float viewShortMedianMfe = na
float viewShortMfe75 = na
int viewShortMaeSampleCount = 0
int viewShortMfeSampleCount = 0
bool viewShortMaeMetricsAvailable = false
bool viewShortMfeMetricsAvailable = false
float viewSelectedMedianMae = na
float viewSelectedMae75 = na
float viewSelectedMedianMfe = na
float viewSelectedMfe75 = na
int viewSelectedMaeSampleCount = 0
int viewSelectedMfeSampleCount = 0
bool viewSelectedMaeMetricsAvailable = false
bool viewSelectedMfeMetricsAvailable = false
bool viewSelectedCompleteRiskMetricsAvailable = false
string viewSelectedRiskMode = "NONE"
int selectedEntryTime = na
int selectedExitTime = na
float selectedEntryPrice = na
int selectedOriginAge = na
int selectedEntryOffsetDisplay = na
int selectedExitOffsetDisplay = na
bool selectedEntryFixed = false
bool viewSelectedDataInvariantOk = true

// Daily presentation seed values are read from one completed generation. The
// registry below remains the final visible source once a lock is available.
if isDailyChart
    ZoneSelection snapshotLong = scanSnapshot.longSelection
    ZoneSelection snapshotShort = scanSnapshot.shortSelection
    viewHasLong := scanSnapshot.valid and snapshotLong.valid
    viewHasShort := scanSnapshot.valid and snapshotShort.valid
    viewBestLongEntryOffset := viewHasLong ? snapshotLong.entryMapOffset : na
    viewBestLongExitOffset := viewHasLong ? snapshotLong.exitMapOffset : na
    viewBestShortEntryOffset := viewHasShort ? snapshotShort.entryMapOffset : na
    viewBestShortExitOffset := viewHasShort ? snapshotShort.exitMapOffset : na
    viewBestLongWinRatePct := viewHasLong ? snapshotLong.seasonalZone.winRate : na
    viewBestShortWinRatePct := viewHasShort ? snapshotShort.seasonalZone.winRate : na
    viewBestLongAvgProfitPct := viewHasLong ? snapshotLong.seasonalZone.avgProfit : na
    viewBestShortAvgProfitPct := viewHasShort ? snapshotShort.seasonalZone.avgProfit : na
    viewBestLongAvgDrawdownPct := viewHasLong ? snapshotLong.seasonalZone.avgDrawdown : na
    viewBestShortAvgDrawdownPct := viewHasShort ? snapshotShort.seasonalZone.avgDrawdown : na
    viewBestLongSqn := viewHasLong ? snapshotLong.seasonalZone.sqn : na
    viewBestShortSqn := viewHasShort ? snapshotShort.seasonalZone.sqn : na
    viewBestLongWinningTrades := viewHasLong ? snapshotLong.seasonalZone.winningTrades : 0
    viewBestLongValidTrades := viewHasLong ? snapshotLong.seasonalZone.validTrades : 0
    viewBestShortWinningTrades := viewHasShort ? snapshotShort.seasonalZone.winningTrades : 0
    viewBestShortValidTrades := viewHasShort ? snapshotShort.seasonalZone.validTrades : 0
    viewBestLongScore := viewHasLong ? snapshotLong.seasonalZone.score : na
    viewBestShortScore := viewHasShort ? snapshotShort.seasonalZone.score : na
    viewLongSampleCoveragePct := scanSnapshot.longSampleCoverage
    viewLongRecentWinRatePct := scanSnapshot.longRecentWinRate
    viewLongMedianProfitPct := scanSnapshot.longMedianProfit
    viewLongOutlierImpactPct := scanSnapshot.longOutlierImpact
    viewLongOverfitWarning := scanSnapshot.longOverfitWarning
    viewShortSampleCoveragePct := scanSnapshot.shortSampleCoverage
    viewShortRecentWinRatePct := scanSnapshot.shortRecentWinRate
    viewShortMedianProfitPct := scanSnapshot.shortMedianProfit
    viewShortOutlierImpactPct := scanSnapshot.shortOutlierImpact
    viewShortOverfitWarning := scanSnapshot.shortOverfitWarning
    viewLongQualityGrade := viewHasLong ? rankToQualityGrade(snapshotLong.qualityCode) : "D"
    viewShortQualityGrade := viewHasShort ? rankToQualityGrade(snapshotShort.qualityCode) : "D"
    viewPrimaryStatus := scanSnapshot.primaryStatus
    viewPrimaryNoEdgeReason := scanSnapshot.noEdgeReason
    viewDailyAnchorTime := scanSnapshot.valid ? scanSnapshot.anchorChartTime : dailyAnchorTime

// Lifecycle uses the confirmed Daily timestamp imported from the Daily context.
int currentDailyConfirmedTime = viewCurrentDailyTime
bool seasonalZoneMapInvariantOk = not isDailyChart or not barstate.isconfirmed or f_seasonalZoneMapInvariant(seasonalZoneMap, seasonalZoneMapVintageId)
if isDailyChart and barstate.isconfirmed
    f_syncCompletedForecasts(seasonalZoneMap, currentDailyConfirmedTime, completedForecastZoneIds)

// Primary selection and analytical locks are Daily-authoritative. Intraday
// imports their finalized snapshot and never reconstructs fresh selections.
if not isDailyChart
    f_clearSegments()
int currentPrimaryMapIndex = isDailyChart and seasonalZoneMapInvariantOk ? f_primaryZoneMapIndex(currentDailyConfirmedTime) : na
SeasonalZone currentPrimaryMapZone = not na(currentPrimaryMapIndex) ? array.get(seasonalZoneMap, currentPrimaryMapIndex) : f_seasonalZoneNone()
int currentPrimarySegmentIndex = currentPrimaryMapIndex
int currentPrimaryEntryOffset = not na(currentPrimarySegmentIndex) ? f_segmentEntryOffset(currentPrimarySegmentIndex) : na
int currentPrimaryExitOffset = not na(currentPrimarySegmentIndex) ? f_segmentExitOffset(currentPrimarySegmentIndex) : na
string currentPrimaryLifecycle = f_zoneLifecycle(currentDailyConfirmedTime, currentPrimaryMapZone)
ZoneSelection currentMapSelection = f_zoneSelection(currentPrimaryMapZone.valid, currentPrimaryMapZone, not na(currentPrimarySegmentIndex) ? qualityGradeToRank(f_segmentQuality(currentPrimarySegmentIndex)) : 1, currentPrimaryLifecycle, scanAnchorTime, TIME_SOURCE_PROJECTED, TIME_SOURCE_PROJECTED, currentPrimaryEntryOffset, currentPrimaryExitOffset, na, f_tradingDayIdentity(scanAnchorTime), seasonalMapOriginDailyBarIndex, scanGeneration)
ZoneSelection mapLongSelection = currentPrimaryMapZone.side == SEG_LONG ? currentMapSelection : f_zoneSelectionNone()
ZoneSelection mapShortSelection = currentPrimaryMapZone.side == SEG_SHORT ? currentMapSelection : f_zoneSelectionNone()

// Primary selection reads the canonical map. The visible registry below is
// independent from Primary churn: active and pending analytical
// locks survive while Pending/Active; Completed locks only free their analytical slot.
string mapLongLifecycle = mapLongSelection.valid ? f_zoneLifecycle(currentDailyConfirmedTime, mapLongSelection.seasonalZone) : "NONE"
string mapShortLifecycle = mapShortSelection.valid ? f_zoneLifecycle(currentDailyConfirmedTime, mapShortSelection.seasonalZone) : "NONE"
bool mapLongIsActive = mapLongLifecycle == "ACTIVE"
bool mapShortIsActive = mapShortLifecycle == "ACTIVE"
bool mapLongIsPending = mapLongLifecycle == "PENDING"
bool mapShortIsPending = mapShortLifecycle == "PENDING"
bool mapLongHardValid = f_zoneSelectionFinalReady(mapLongSelection)
bool mapShortHardValid = f_zoneSelectionFinalReady(mapShortSelection)
bool mapLongLifecycleOk = mapLongHardValid and (mapLongIsActive or mapLongIsPending)
bool mapShortLifecycleOk = mapShortHardValid and (mapShortIsActive or mapShortIsPending)
// Primary analytical snapshots are retained through Pending/Active lifecycle.
// They feed panels, risk, potential, and alerts, never visible membership.
bool lockedRegistryCanMutate = isDailyChart and not na(viewCurrentDailyBarIndex) and (na(lockedRegistryLastDailyBarIndex) or viewCurrentDailyBarIndex != lockedRegistryLastDailyBarIndex)
if lockedRegistryCanMutate
    lockedLong := f_lockedZoneRegistryStep(lockedLong, mapLongSelection, mapLongLifecycleOk, seasonalZoneMapVintageId, viewCurrentDailyBarIndex, currentDailyConfirmedTime)
    lockedShort := f_lockedZoneRegistryStep(lockedShort, mapShortSelection, mapShortLifecycleOk, seasonalZoneMapVintageId, viewCurrentDailyBarIndex, currentDailyConfirmedTime)

if lockedRegistryCanMutate
    if isDailyChart
        // Membership is rebuilt from the complete canonical map. Previous
        // membership and Primary locks cannot add, remove, or reorder a zone.
        f_rebuildVisibleZoneRegistry(visibleZoneRegistry, seasonalZoneMap, currentPrimaryMapIndex, seasonalMapOriginDailyBarIndex, viewCurrentDailyBarIndex, currentDailyConfirmedTime)
        if ENABLE_PHASE0_DIAGNOSTICS
            phase0RegistryDigest := f_phase0RegistryDigest(seasonalZoneMap, visibleZoneRegistry, currentPrimaryMapIndex, currentDailyConfirmedTime)
        int nextRegistryGeneration = registryGeneration + 1
        visibleRegistryPayload := f_encodeVisibleRegistry(visibleZoneRegistry, seasonalZoneMapVintageId, nextRegistryGeneration)
        registryGeneration := nextRegistryGeneration
    lockedRegistryLastDailyBarIndex := viewCurrentDailyBarIndex

// Intraday consumers import the final Daily registry, not fresh scanner results.
// The tail guard deliberately lives inside each request expression. An outer
// chart-tail guard only delays consumption; it does not stop request.security()
// from constructing and retaining a large UDT/string value for every Daily bar.
// Keep the infrequently changing string payload on a separate tail channel so it
// is not embedded twice inside the lock bridge's historical series.
if isViewTfSupported and not isDailyChart
    DailyZoneBridge dailyRegistryBridge = request.security(syminfo.tickerid, "D", barstate.islast ? DailyZoneBridge.new(seasonalZoneMapVintageId, lockedLong.valid ? lockedLong.seasonalZone.zoneId : "", lockedShort.valid ? lockedShort.seasonalZone.zoneId : "", lockedLong, lockedShort, registryGeneration, scanSnapshot.primaryStatus, scanSnapshot.noEdgeReason, bar_index, scanSnapshot.anchorChartTime, close, high, low, time, scanSnapshot.generation) : na, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, calc_bars_count = 5000)
    string dailyVisiblePayload = request.security(syminfo.tickerid, "D", barstate.islast ? visibleRegistryPayload : "", gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, calc_bars_count = 5000)
    if barstate.islast
        if not na(dailyRegistryBridge) and f_dailyZoneBridgeValid(dailyRegistryBridge)
            bool registryChanged = na(lastImportedRegistryGeneration) or dailyRegistryBridge.generation != lastImportedRegistryGeneration
            viewPrimaryStatus := dailyRegistryBridge.primaryStatus
            viewPrimaryNoEdgeReason := dailyRegistryBridge.noEdgeReason
            viewCurrentDailyBarIndex := dailyRegistryBridge.dailyBarIndex
            viewDailyAnchorTime := dailyRegistryBridge.dailyAnchorTime
            viewCurrentDailyClose := dailyRegistryBridge.dailyClose
            viewCurrentDailyHigh := dailyRegistryBridge.dailyHigh
            viewCurrentDailyLow := dailyRegistryBridge.dailyLow
            viewCurrentDailyTime := dailyRegistryBridge.dailyTime
            viewSnapshotGeneration := dailyRegistryBridge.snapshotGeneration
            currentDailyConfirmedTime := dailyRegistryBridge.dailyTime
            if registryChanged
                bool payloadChanged = dailyVisiblePayload != lastImportedVisiblePayload
                bool payloadImported = payloadChanged and f_decodeVisibleRegistry(dailyVisiblePayload, visibleZoneRegistry, dailyRegistryBridge.modelVintageId, dailyRegistryBridge.generation, viewCurrentDailyBarIndex)
                if payloadImported
                    lockedLong := dailyRegistryBridge.longZone
                    lockedShort := dailyRegistryBridge.shortZone
                    registryGeneration := dailyRegistryBridge.generation
                    viewLongSampleCoveragePct := lockedLong.valid ? lockedLong.seasonalZone.validTrades / configuredTrainingYears * 100.0 : na
                    viewShortSampleCoveragePct := lockedShort.valid ? lockedShort.seasonalZone.validTrades / configuredTrainingYears * 100.0 : na
                    viewLongRecentWinRatePct := na
                    viewLongMedianProfitPct := na
                    viewLongOutlierImpactPct := na
                    viewLongOverfitWarning := false
                    viewShortRecentWinRatePct := na
                    viewShortMedianProfitPct := na
                    viewShortOutlierImpactPct := na
                    viewShortOverfitWarning := false
                    lastImportedVisiblePayload := dailyVisiblePayload
                    lastImportedRegistryGeneration := dailyRegistryBridge.generation
                else
                    canRenderFutureZones := false
                    viewPrimaryNoEdgeReason := "DAILY_REGISTRY_PAYLOAD_MISMATCH"
            if not registryChanged or lastImportedRegistryGeneration == dailyRegistryBridge.generation
                canRenderFutureZones := not na(viewDailyAnchorTime)
        else
            canRenderFutureZones := false
            viewPrimaryStatus := SEG_STATUS_BLOCKED
            viewPrimaryNoEdgeReason := "DAILY_BRIDGE_UNAVAILABLE"

// Selected/visible zones are derived exclusively from canonical map-backed locks.
selectedLongZoneValid := lockedLong.valid
selectedLongZoneSource := lockedLong.valid ? lockedLong.source : "NONE"
selectedLongZoneMapOriginTime := lockedLong.mapOriginTime
selectedLongZoneEntryTime := lockedLong.seasonalZone.canonicalEntryTime
selectedLongZoneExitTime := lockedLong.seasonalZone.canonicalExitTime
selectedLongZoneEntryTimeSource := lockedLong.entryTimeSource
selectedLongZoneExitTimeSource := lockedLong.exitTimeSource
selectedLongZoneEntryMapOffset := lockedLong.entryMapOffset
selectedLongZoneExitMapOffset := lockedLong.exitMapOffset
selectedLongZoneEntryPrice := lockedLong.entryPrice
selectedLongZoneScore := lockedLong.seasonalZone.score
selectedLongZoneWinRate := lockedLong.seasonalZone.winRate
selectedLongZoneAvgProfit := lockedLong.seasonalZone.avgProfit
selectedLongZoneAvgDrawdown := lockedLong.seasonalZone.avgDrawdown
selectedLongZoneSqn := lockedLong.seasonalZone.sqn
selectedLongZoneWinningTrades := lockedLong.seasonalZone.winningTrades
selectedLongZoneValidTrades := lockedLong.seasonalZone.validTrades
selectedLongZoneQuality := rankToQualityGrade(lockedLong.qualityCode)
selectedShortZoneValid := lockedShort.valid
selectedShortZoneSource := lockedShort.valid ? lockedShort.source : "NONE"
selectedShortZoneMapOriginTime := lockedShort.mapOriginTime
selectedShortZoneEntryTime := lockedShort.seasonalZone.canonicalEntryTime
selectedShortZoneExitTime := lockedShort.seasonalZone.canonicalExitTime
selectedShortZoneEntryTimeSource := lockedShort.entryTimeSource
selectedShortZoneExitTimeSource := lockedShort.exitTimeSource
selectedShortZoneEntryMapOffset := lockedShort.entryMapOffset
selectedShortZoneExitMapOffset := lockedShort.exitMapOffset
selectedShortZoneEntryPrice := lockedShort.entryPrice
selectedShortZoneScore := lockedShort.seasonalZone.score
selectedShortZoneWinRate := lockedShort.seasonalZone.winRate
selectedShortZoneAvgProfit := lockedShort.seasonalZone.avgProfit
selectedShortZoneAvgDrawdown := lockedShort.seasonalZone.avgDrawdown
selectedShortZoneSqn := lockedShort.seasonalZone.sqn
selectedShortZoneWinningTrades := lockedShort.seasonalZone.winningTrades
selectedShortZoneValidTrades := lockedShort.seasonalZone.validTrades
selectedShortZoneQuality := rankToQualityGrade(lockedShort.qualityCode)
// EvidenceSnapshot is selected below from the final EvidenceViewModel after Primary lock selection.

bool selectedLongLifecycleOk = selectedLongZoneValid and (lockedLong.state == "PENDING" or lockedLong.state == "ACTIVE")
bool selectedShortLifecycleOk = selectedShortZoneValid and (lockedShort.state == "PENDING" or lockedShort.state == "ACTIVE")
selectedLongZoneValid := selectedLongLifecycleOk
selectedShortZoneValid := selectedShortLifecycleOk
selectedLongZoneSource := selectedLongZoneValid ? selectedLongZoneSource : "NONE"
selectedShortZoneSource := selectedShortZoneValid ? selectedShortZoneSource : "NONE"

// Visible Zone View Model: panels and downstream display decisions read active/pending selected zones, not fresh scanner results.
bool selectedLongActiveOrPending = selectedLongZoneValid and (lockedLong.state == "ACTIVE" or lockedLong.state == "PENDING")
bool selectedShortActiveOrPending = selectedShortZoneValid and (lockedShort.state == "ACTIVE" or lockedShort.state == "PENDING")
bool rawVisibleLongValid = selectedLongActiveOrPending
bool rawVisibleShortValid = selectedShortActiveOrPending
int selectedLockedSide = SEG_NONE
bool selectedLockedActive = false
int selectedLockedTimeRank = na
int selectedLockedQualityRank = -1
float selectedLockedScore = na
if rawVisibleLongValid
    selectedLockedSide := SEG_LONG
    selectedLockedActive := lockedLong.state == "ACTIVE"
    selectedLockedTimeRank := selectedLockedActive ? selectedLongZoneExitTime : selectedLongZoneEntryTime
    selectedLockedQualityRank := qualityGradeToRank(selectedLongZoneQuality)
    selectedLockedScore := selectedLongZoneScore
if rawVisibleShortValid
    bool candidateActive = lockedShort.state == "ACTIVE"
    int candidateTimeRank = candidateActive ? selectedShortZoneExitTime : selectedShortZoneEntryTime
    int candidateQualityRank = qualityGradeToRank(selectedShortZoneQuality)
    bool shortSelectionBeats = selectedLockedSide == SEG_NONE or (candidateActive and not selectedLockedActive) or (candidateActive == selectedLockedActive and (candidateTimeRank < selectedLockedTimeRank or (candidateTimeRank == selectedLockedTimeRank and (candidateQualityRank > selectedLockedQualityRank or (candidateQualityRank == selectedLockedQualityRank and nz(selectedShortZoneScore, -1000000.0) > nz(selectedLockedScore, -1000000.0))))))
    if shortSelectionBeats
        selectedLockedSide := SEG_SHORT
        selectedLockedActive := candidateActive
        selectedLockedTimeRank := candidateTimeRank
        selectedLockedQualityRank := candidateQualityRank
        selectedLockedScore := selectedShortZoneScore
bool visibleLongValid = selectedLockedSide == SEG_LONG
bool visibleShortValid = selectedLockedSide == SEG_SHORT
// The selected Primary side is the single directional authority for every analytical downstream view.
bool selectedZoneUseLong = selectedLockedSide == SEG_LONG
bool selectedZoneUseShort = selectedLockedSide == SEG_SHORT
bool viewHasSelectedZone = selectedZoneUseLong or selectedZoneUseShort
bool selectedLockedSideValid = selectedLockedSide == SEG_NONE or selectedLockedSide == SEG_LONG or selectedLockedSide == SEG_SHORT
bool selectedZoneSelectionInvariantOk = selectedLockedSideValid and not (selectedZoneUseLong and selectedZoneUseShort) and viewHasSelectedZone == (selectedZoneUseLong or selectedZoneUseShort) and selectedZoneUseLong == (selectedLockedSide == SEG_LONG) and selectedZoneUseShort == (selectedLockedSide == SEG_SHORT)
selectedEntryTime := selectedZoneUseLong ? selectedLongZoneEntryTime : selectedZoneUseShort ? selectedShortZoneEntryTime : na
selectedExitTime := selectedZoneUseLong ? selectedLongZoneExitTime : selectedZoneUseShort ? selectedShortZoneExitTime : na
selectedEntryPrice := selectedZoneUseLong ? selectedLongZoneEntryPrice : selectedZoneUseShort ? selectedShortZoneEntryPrice : na
SeasonalZone selectedCanonicalZone = selectedZoneUseLong ? lockedLong.seasonalZone : selectedZoneUseShort ? lockedShort.seasonalZone : f_seasonalZoneNone()
OperationalTradeWindow selectedTradeWindow = viewHasSelectedZone ? f_buildOperationalTradeWindow(selectedCanonicalZone, maxTradeDurationDays) : f_operationalTradeWindowNone()
int selectedTradeEntryTime = selectedTradeWindow.entryTime
int selectedTradeExitTime = selectedTradeWindow.exitTime
string evidenceViewModelNoEdgeReason = selectedLockedSide != SEG_NONE ? "Edge selected" : "No selected Primary zone"
EvidenceViewModel selectedBaseEvidenceViewModel = visibleLongValid ? f_evidenceViewModelFromLockedZone(SEG_LONG, lockedLong, "n/a", evidenceViewModelNoEdgeReason) : visibleShortValid ? f_evidenceViewModelFromLockedZone(SEG_SHORT, lockedShort, "n/a", evidenceViewModelNoEdgeReason) : f_evidenceViewModelNone(evidenceViewModelNoEdgeReason)
EvidenceViewModel selectedFinalEvidenceViewModel = f_evidenceViewModelNone("Not finalized")
selectedEvidenceSnapshot := visibleLongValid ? lockedLong.seasonalZone.evidence : visibleShortValid ? lockedShort.seasonalZone.evidence : f_evidenceSnapshotNone()
selectedPlateauGrade := selectedBaseEvidenceViewModel.plateauGrade
selectedRealPlateauNeighborCount := visibleLongValid ? lockedLong.seasonalZone.plateauNeighborCount : visibleShortValid ? lockedShort.seasonalZone.plateauNeighborCount : 0
selectedRealPlateauMinRatio := visibleLongValid ? lockedLong.seasonalZone.plateauMinRatio : visibleShortValid ? lockedShort.seasonalZone.plateauMinRatio : na
selectedRealPlateauAvgRatio := visibleLongValid ? lockedLong.seasonalZone.plateauAvgRatio : visibleShortValid ? lockedShort.seasonalZone.plateauAvgRatio : na
selectedRealPlateauWeakCount := visibleLongValid ? lockedLong.seasonalZone.plateauWeakCount : visibleShortValid ? lockedShort.seasonalZone.plateauWeakCount : 0

if visibleLongValid
    viewHasLong := true
    viewBestLongEntryOffset := selectedLongZoneEntryMapOffset
    viewBestLongExitOffset := selectedLongZoneExitMapOffset
    viewBestLongScore := selectedLongZoneScore
    viewBestLongWinRatePct := selectedLongZoneWinRate
    viewBestLongAvgProfitPct := selectedLongZoneAvgProfit
    viewBestLongAvgDrawdownPct := selectedLongZoneAvgDrawdown
    viewBestLongSqn := selectedLongZoneSqn
    viewBestLongWinningTrades := selectedLongZoneWinningTrades
    viewBestLongValidTrades := selectedLongZoneValidTrades
    viewLongQualityGrade := selectedLongZoneQuality
else
    viewHasLong := false
    viewBestLongEntryOffset := na
    viewBestLongExitOffset := na
    viewBestLongScore := na
    viewBestLongWinRatePct := na
    viewBestLongAvgProfitPct := na
    viewBestLongAvgDrawdownPct := na
    viewBestLongSqn := na
    viewBestLongWinningTrades := 0
    viewBestLongValidTrades := 0
    viewLongQualityGrade := "D"

if visibleShortValid
    viewHasShort := true
    viewBestShortEntryOffset := selectedShortZoneEntryMapOffset
    viewBestShortExitOffset := selectedShortZoneExitMapOffset
    viewBestShortScore := selectedShortZoneScore
    viewBestShortWinRatePct := selectedShortZoneWinRate
    viewBestShortAvgProfitPct := selectedShortZoneAvgProfit
    viewBestShortAvgDrawdownPct := selectedShortZoneAvgDrawdown
    viewBestShortSqn := selectedShortZoneSqn
    viewBestShortWinningTrades := selectedShortZoneWinningTrades
    viewBestShortValidTrades := selectedShortZoneValidTrades
    viewShortQualityGrade := selectedShortZoneQuality
else
    viewHasShort := false
    viewBestShortEntryOffset := na
    viewBestShortExitOffset := na
    viewBestShortScore := na
    viewBestShortWinRatePct := na
    viewBestShortAvgProfitPct := na
    viewBestShortAvgDrawdownPct := na
    viewBestShortSqn := na
    viewBestShortWinningTrades := 0
    viewBestShortValidTrades := 0
    viewShortQualityGrade := "D"

// Best Zone is the locked/selected Primary Zone; mode flags only filter that segment side.
bool longHistoricalDisplayAllowed = useLongShortMode or useLongOnlyMode or (useBestZoneMode and visibleLongValid)
bool shortHistoricalDisplayAllowed = useLongShortMode or useShortOnlyMode or (useBestZoneMode and visibleShortValid)
renderHistoricalLong := showHistoricalPeriods and isViewTfSupported and visibleLongValid and longHistoricalDisplayAllowed
renderHistoricalShort := showHistoricalPeriods and isViewTfSupported and visibleShortValid and shortHistoricalDisplayAllowed

string selectedLongZoneKey = visibleLongValid ? f_lockedZoneKey(lockedLong, SEG_LONG) : ""
string selectedShortZoneKey = visibleShortValid ? f_lockedZoneKey(lockedShort, SEG_SHORT) : ""

int selectedLongDurationNow = visibleLongValid and not na(selectedLongZoneEntryMapOffset) and not na(selectedLongZoneExitMapOffset) ? selectedLongZoneExitMapOffset - selectedLongZoneEntryMapOffset : na
int selectedShortDurationNow = visibleShortValid and not na(selectedShortZoneEntryMapOffset) and not na(selectedShortZoneExitMapOffset) ? selectedShortZoneExitMapOffset - selectedShortZoneEntryMapOffset : na

// Active/future zone geometry is sourced only from selected Primary/segment zones.
int viewLongOriginAge = f_dailyAgeFromEntry(selectedLongZoneEntryTime, currentDailyConfirmedTime)
int viewShortOriginAge = f_dailyAgeFromEntry(selectedShortZoneEntryTime, currentDailyConfirmedTime)
int viewLongEntryOffsetDisplay = visibleLongValid and not na(viewLongOriginAge) and currentDailyConfirmedTime >= selectedLongZoneEntryTime ? -viewLongOriginAge : selectedLongZoneEntryMapOffset
int viewShortEntryOffsetDisplay = visibleShortValid and not na(viewShortOriginAge) and currentDailyConfirmedTime >= selectedShortZoneEntryTime ? -viewShortOriginAge : selectedShortZoneEntryMapOffset
int viewLongExitOffsetDisplay = not na(viewLongEntryOffsetDisplay) and not na(selectedLongDurationNow) ? viewLongEntryOffsetDisplay + selectedLongDurationNow : selectedLongZoneExitMapOffset
int viewShortExitOffsetDisplay = not na(viewShortEntryOffsetDisplay) and not na(selectedShortDurationNow) ? viewShortEntryOffsetDisplay + selectedShortDurationNow : selectedShortZoneExitMapOffset
selectedOriginAge := selectedZoneUseLong ? viewLongOriginAge : selectedZoneUseShort ? viewShortOriginAge : na
selectedEntryOffsetDisplay := selectedZoneUseLong ? viewLongEntryOffsetDisplay : selectedZoneUseShort ? viewShortEntryOffsetDisplay : na
selectedExitOffsetDisplay := selectedZoneUseLong ? viewLongExitOffsetDisplay : selectedZoneUseShort ? viewShortExitOffsetDisplay : na

int visibleRegistrySize = array.size(visibleZoneRegistry)
bool syncFutureZoneObjects = barstate.islast and (na(lastFutureRenderGeneration) or registryGeneration != lastFutureRenderGeneration)

if barstate.islast
    // A zone ID uniquely owns its frozen payload. Daily generations and current
    // market progress therefore cannot trigger a different historical decode.
    string dLongVerificationPayload = visibleLongValid ? lockedLong.seasonalZone.verificationPayload : ""
    string dShortVerificationPayload = visibleShortValid ? lockedShort.seasonalZone.verificationPayload : ""
    string verificationSignature = selectedLongZoneKey + "|" + selectedShortZoneKey
    bool refreshVerification = verificationSignature != lastDecodedVerificationSignature
    if refreshVerification
        f_clearDirectionalVerificationArrays(viewLongVerificationYears, viewLongVerificationEntryTimes, viewLongVerificationExitTimes, viewLongVerificationBandEndTimes, viewLongVerificationProfits, viewLongVerificationDrawdowns, viewLongVerificationLows, viewLongVerificationHighs, viewLongVerificationEntryPrices, viewLongVerificationExitPrices, viewLongMae, viewLongMfe)
        f_clearDirectionalVerificationArrays(viewShortVerificationYears, viewShortVerificationEntryTimes, viewShortVerificationExitTimes, viewShortVerificationBandEndTimes, viewShortVerificationProfits, viewShortVerificationDrawdowns, viewShortVerificationLows, viewShortVerificationHighs, viewShortVerificationEntryPrices, viewShortVerificationExitPrices, viewShortMae, viewShortMfe)
        f_decodeDirectionalPayload(dLongVerificationPayload, viewLongVerificationYears, viewLongVerificationEntryTimes, viewLongVerificationExitTimes, viewLongVerificationBandEndTimes, viewLongVerificationProfits, viewLongVerificationDrawdowns, viewLongVerificationLows, viewLongVerificationHighs, viewLongVerificationEntryPrices, viewLongVerificationExitPrices, viewLongMae, viewLongMfe)
        f_decodeDirectionalPayload(dShortVerificationPayload, viewShortVerificationYears, viewShortVerificationEntryTimes, viewShortVerificationExitTimes, viewShortVerificationBandEndTimes, viewShortVerificationProfits, viewShortVerificationDrawdowns, viewShortVerificationLows, viewShortVerificationHighs, viewShortVerificationEntryPrices, viewShortVerificationExitPrices, viewShortMae, viewShortMfe)
        [longMedianMaeCalc, longMae75Calc, longMedianMfeCalc, longMfe75Calc, longMaeSampleCountCalc, longMfeSampleCountCalc, longMaeAvailableCalc, longMfeAvailableCalc] = f_directionalMaeMfeMetrics(viewLongMae, viewLongMfe)
        viewLongMedianMae := longMedianMaeCalc
        viewLongMae75 := longMae75Calc
        viewLongMedianMfe := longMedianMfeCalc
        viewLongMfe75 := longMfe75Calc
        viewLongMaeSampleCount := longMaeSampleCountCalc
        viewLongMfeSampleCount := longMfeSampleCountCalc
        viewLongMaeMetricsAvailable := longMaeAvailableCalc
        viewLongMfeMetricsAvailable := longMfeAvailableCalc
        [shortMedianMaeCalc, shortMae75Calc, shortMedianMfeCalc, shortMfe75Calc, shortMaeSampleCountCalc, shortMfeSampleCountCalc, shortMaeAvailableCalc, shortMfeAvailableCalc] = f_directionalMaeMfeMetrics(viewShortMae, viewShortMfe)
        viewShortMedianMae := shortMedianMaeCalc
        viewShortMae75 := shortMae75Calc
        viewShortMedianMfe := shortMedianMfeCalc
        viewShortMfe75 := shortMfe75Calc
        viewShortMaeSampleCount := shortMaeSampleCountCalc
        viewShortMfeSampleCount := shortMfeSampleCountCalc
        viewShortMaeMetricsAvailable := shortMaeAvailableCalc
        viewShortMfeMetricsAvailable := shortMfeAvailableCalc
        lastDecodedVerificationSignature := verificationSignature
    string effectiveVerificationPosition = f_fallbackVerificationPosition(mainPanelPosition, verificationPanelPosition)
    bool showLongRow = calcLongEnabled
    bool showShortRow = calcShortEnabled
    bool showLongQualRow = showLongRow and enableQualityLayer
    bool showShortQualRow = showShortRow and enableQualityLayer
    bool showBiasRow = true
    bool showEvidenceRow = true
    int dynamicMainRows = 2 + (showLongRow ? 1 : 0) + (showShortRow ? 1 : 0) + (showLongQualRow ? 1 : 0) + (showShortQualRow ? 1 : 0) + (showBiasRow ? 1 : 0) + (showEvidenceRow ? 1 : 0)
    if na(mainStatsTable)
        mainStatsTable := table.new(f_tablePosition(mainPanelPosition), 7, dynamicMainRows, border_width = 1)
    if na(verificationPanel)
        verificationPanel := table.new(f_tablePosition(effectiveVerificationPosition), 3, effectiveDisplayRows + 3, border_width = 1)
    if showPotentialPanel and isViewTfSupported and na(potentialPanel)
        potentialPanel := table.new(f_tablePosition(potentialPanelPosition), 2, 9, border_width = 1)

    int selectedPrimaryBiasSide = selectedLockedSide == SEG_LONG or selectedLockedSide == SEG_SHORT ? selectedLockedSide : SEG_NONE
    string selectedPrimaryQuality = visibleLongValid ? selectedLongZoneQuality : visibleShortValid ? selectedShortZoneQuality : "D"
    float selectedPrimaryScore = visibleLongValid ? selectedLongZoneScore : visibleShortValid ? selectedShortZoneScore : na
    int selectedPrimaryEntryOffset = visibleLongValid ? selectedLongZoneEntryMapOffset : visibleShortValid ? selectedShortZoneEntryMapOffset : na
    int selectedPrimaryExitOffset = visibleLongValid ? selectedLongZoneExitMapOffset : visibleShortValid ? selectedShortZoneExitMapOffset : na
    bool viewSelectedZoneIsTradeable = selectedPrimaryBiasSide != SEG_NONE
    bool viewSelectedZoneIsWatch = false
    bool viewSelectedZoneIsWeak = false
    bool selectedPrimaryStatusEligible = selectedPrimaryBiasSide != SEG_NONE and (viewSelectedZoneIsTradeable or viewSelectedZoneIsWatch or viewSelectedZoneIsWeak)
    bool selectedDirectionalQualityEligible = (selectedPrimaryBiasSide == SEG_LONG or selectedPrimaryBiasSide == SEG_SHORT) and selectedPrimaryStatusEligible
    string selectedPrimaryBlockReason = selectedPrimaryBiasSide == SEG_NONE ? "NO_EDGE" : not selectedPrimaryStatusEligible ? "STATUS_BLOCKED" : "NONE"
    finalBias := "NO EDGE"
    finalBiasQuality := "D"
    finalBiasWindow := "-"
    finalBiasScore := na
    if enableBiasClassifier
        if selectedPrimaryBiasSide == SEG_LONG and selectedDirectionalQualityEligible
            finalBias := "LONG"
            finalBiasQuality := selectedPrimaryQuality
            finalBiasWindow := formatOffset(selectedPrimaryEntryOffset) + "→" + formatOffset(selectedPrimaryExitOffset)
            finalBiasScore := selectedPrimaryScore
        else if selectedPrimaryBiasSide == SEG_SHORT and selectedDirectionalQualityEligible
            finalBias := "SHORT"
            finalBiasQuality := selectedPrimaryQuality
            finalBiasWindow := formatOffset(selectedPrimaryEntryOffset) + "→" + formatOffset(selectedPrimaryExitOffset)
            finalBiasScore := selectedPrimaryScore


    viewNoEdgeReason := finalBias != "NO EDGE" ? "Edge selected" : selectedPrimaryBiasSide == SEG_NONE ? viewPrimaryNoEdgeReason : selectedPrimaryBlockReason
    viewFinalBias := finalBias
    viewFinalBiasQuality := finalBiasQuality
    viewFinalBiasWindow := finalBiasWindow
    viewFinalBiasScore := finalBiasScore

    viewSelectedZoneIsTradeable := viewHasSelectedZone and viewSelectedZoneIsTradeable
    viewSelectedZoneIsWatch := viewHasSelectedZone and viewSelectedZoneIsWatch
    viewSelectedZoneIsWeak := viewHasSelectedZone and viewSelectedZoneIsWeak
    bool selectedRiskUseLong = selectedZoneUseLong
    bool selectedRiskUseShort = selectedZoneUseShort
    // Potential/Risk/Reward follows the selected Primary Daily window; display modes cannot reselect its side.
    viewSelectedRiskMode := selectedRiskUseLong ? "LONG" : selectedRiskUseShort ? "SHORT" : "NONE"
    [dVolFitScore, dVolRegimeCode] = request.security(syminfo.tickerid, "D", f_calcVolatilityFitTuple(atrShortLen, atrLongLen, realizedVolLen, volLookback), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    viewVolatilityFitScore := dVolFitScore
    viewVolRegimeCode := dVolRegimeCode
    selectedRealPlateauDiag := selectedRealPlateauNeighborCount > 0 ? "Real " + str.tostring(selectedRealPlateauNeighborCount) + "/6 Min " + str.tostring(math.round(selectedRealPlateauMinRatio * 100.0)) + "% Avg " + str.tostring(math.round(selectedRealPlateauAvgRatio * 100.0)) + "% W" + str.tostring(selectedRealPlateauWeakCount) : "Real Plat n/a"
    string selectedBaseQualityGrade = selectedBaseEvidenceViewModel.side != SEG_NONE ? selectedBaseEvidenceViewModel.finalGrade : "D"
    viewSelectedFinalQualityGrade := viewSelectedRiskMode != "NONE" ? selectedBaseQualityGrade : "D"
    bool rejectSelectedPlateau = viewSelectedRiskMode != "NONE" and selectedBaseEvidenceViewModel.plateauGrade == "Reject" and qualityStrength >= 60
    if rejectSelectedPlateau
        viewNoEdgeReason := "Single-window spike"
        viewSelectedRiskMode := "NONE"
        selectedRiskUseLong := false
        selectedRiskUseShort := false
        renderHistoricalLong := false
        renderHistoricalShort := false
        viewSelectedFinalQualityGrade := "D"
    // Selected risk evidence follows the locked side even when a later tradeability gate rejects execution.
    viewSelectedMedianMae := selectedZoneUseLong ? viewLongMedianMae : selectedZoneUseShort ? viewShortMedianMae : na
    viewSelectedMae75 := selectedZoneUseLong ? viewLongMae75 : selectedZoneUseShort ? viewShortMae75 : na
    viewSelectedMedianMfe := selectedZoneUseLong ? viewLongMedianMfe : selectedZoneUseShort ? viewShortMedianMfe : na
    viewSelectedMfe75 := selectedZoneUseLong ? viewLongMfe75 : selectedZoneUseShort ? viewShortMfe75 : na
    viewSelectedMaeSampleCount := selectedZoneUseLong ? viewLongMaeSampleCount : selectedZoneUseShort ? viewShortMaeSampleCount : 0
    viewSelectedMfeSampleCount := selectedZoneUseLong ? viewLongMfeSampleCount : selectedZoneUseShort ? viewShortMfeSampleCount : 0
    viewSelectedMaeMetricsAvailable := selectedZoneUseLong ? viewLongMaeMetricsAvailable : selectedZoneUseShort ? viewShortMaeMetricsAvailable : false
    viewSelectedMfeMetricsAvailable := selectedZoneUseLong ? viewLongMfeMetricsAvailable : selectedZoneUseShort ? viewShortMfeMetricsAvailable : false
    viewSelectedCompleteRiskMetricsAvailable := viewSelectedMaeMetricsAvailable and viewSelectedMfeMetricsAvailable
    bool selectedMaeSampleInvariantOk = viewSelectedMaeSampleCount >= 0 and viewSelectedMaeMetricsAvailable == (viewSelectedMaeSampleCount > 0 and not na(viewSelectedMedianMae) and not na(viewSelectedMae75))
    bool selectedMfeSampleInvariantOk = viewSelectedMfeSampleCount >= 0 and viewSelectedMfeMetricsAvailable == (viewSelectedMfeSampleCount > 0 and not na(viewSelectedMedianMfe) and not na(viewSelectedMfe75))
    bool selectedRiskSampleInvariantOk = selectedMaeSampleInvariantOk and selectedMfeSampleInvariantOk
    float robustScoreCalc = na
    string robustOutlierRiskCalc = "n/a"
    string robustStabilityLabelCalc = "n/a"
    if selectedZoneUseLong
        [lRobustSampleCount, lRobustAvgReturn, lRobustMedianReturn, lRobustTrimmedAvg, lRobustBestReturn, lRobustWorstReturn, lRobustPositiveRate, lRobustLast5Avg, lRobustFullAvg, lRobustMedianGap, lRobustOutlierImpact, lRobustRecentStability, robustScoreLongCalc, robustOutlierRiskLongCalc, robustStabilityLabelLongCalc] = f_edgeRobustnessMetrics(viewLongVerificationProfits)
        robustScoreCalc := robustScoreLongCalc
        robustOutlierRiskCalc := robustOutlierRiskLongCalc
        robustStabilityLabelCalc := robustStabilityLabelLongCalc
    else if selectedZoneUseShort
        [sRobustSampleCount, sRobustAvgReturn, sRobustMedianReturn, sRobustTrimmedAvg, sRobustBestReturn, sRobustWorstReturn, sRobustPositiveRate, sRobustLast5Avg, sRobustFullAvg, sRobustMedianGap, sRobustOutlierImpact, sRobustRecentStability, robustScoreShortCalc, robustOutlierRiskShortCalc, robustStabilityLabelShortCalc] = f_edgeRobustnessMetrics(viewShortVerificationProfits)
        robustScoreCalc := robustScoreShortCalc
        robustOutlierRiskCalc := robustOutlierRiskShortCalc
        robustStabilityLabelCalc := robustStabilityLabelShortCalc
    viewEdgeRobustnessScore := (showEdgeRobustness and edgeRobustnessMode != "Off" and viewSelectedRiskMode != "NONE") ? robustScoreCalc : na
    viewOutlierRisk := not na(viewEdgeRobustnessScore) ? robustOutlierRiskCalc : "n/a"
    viewEdgeStabilityLabel := not na(viewEdgeRobustnessScore) ? robustStabilityLabelCalc : "n/a"
    viewWindowEntryPrice := selectedEntryPrice
    viewWindowEntryTime := selectedTradeEntryTime
    viewWindowExitTime := selectedTradeExitTime
    bool selectedWindowHasTimes = selectedTradeWindow.valid
    bool selectedWindowHasEntryPrice = not na(selectedEntryPrice) and selectedEntryPrice > 0
    bool selectedWindowDataReady = selectedWindowHasTimes and selectedWindowHasEntryPrice
    bool selectedWindowIsPending = selectedWindowHasTimes and currentDailyConfirmedTime < selectedTradeEntryTime
    bool selectedWindowIsActive = selectedWindowHasTimes and currentDailyConfirmedTime >= selectedTradeEntryTime and currentDailyConfirmedTime <= selectedTradeExitTime
    bool selectedWindowIsExpired = selectedWindowHasTimes and currentDailyConfirmedTime > selectedTradeExitTime
    bool selectedActiveWindowInvariantOk = not selectedWindowIsActive or (selectedTradeWindow.valid)
    bool selectedCanonicalInvariantOk = not viewHasSelectedZone or f_seasonalZoneInvariant(selectedCanonicalZone)
    bool operationalBindingInvariantOk = not selectedTradeWindow.valid or selectedTradeWindow.sourceZoneId == selectedCanonicalZone.zoneId
    bool selectedEntryPriceInvariantOk = na(selectedEntryPrice) or selectedEntryPrice > 0
    viewSelectedDataInvariantOk := seasonalZoneMapInvariantOk and selectedZoneSelectionInvariantOk and selectedCanonicalInvariantOk and operationalBindingInvariantOk and selectedActiveWindowInvariantOk and selectedEntryPriceInvariantOk and selectedRiskSampleInvariantOk
    selectedEntryFixed := selectedWindowDataReady
    viewWindowIsPending := selectedWindowIsPending
    viewFinalBiasWindow := not na(selectedEntryOffsetDisplay) and not na(selectedExitOffsetDisplay) ? formatOffset(selectedEntryOffsetDisplay) + "→" + formatOffset(selectedExitOffsetDisplay) + f_viewModelProjectedSuffix(selectedBaseEvidenceViewModel) : viewFinalBiasWindow
    // Move Used, remaining move, invalidation level/state, and potential scores are calculated here.
    float selectedMfeBasis = viewSelectedMedianMfe
    bool canCalculateMoveUsed = viewSelectedDataInvariantOk and (selectedRiskUseLong or selectedRiskUseShort) and selectedWindowIsActive and selectedWindowDataReady and viewSelectedMfeMetricsAvailable and not na(viewCurrentDailyClose) and viewCurrentDailyClose > 0 and not na(selectedMfeBasis)
    viewCurrentMovePct := canCalculateMoveUsed ? selectedRiskUseLong ? f_directionalReturnPct(viewWindowEntryPrice, viewCurrentDailyClose, DIR_LONG) : f_directionalReturnPct(viewWindowEntryPrice, viewCurrentDailyClose, DIR_SHORT) : na
    viewMoveUsedPct := canCalculateMoveUsed and selectedMfeBasis > 0 ? viewCurrentMovePct / selectedMfeBasis * 100.0 : na
    viewRemainingPotentialPct := canCalculateMoveUsed ? selectedMfeBasis - viewCurrentMovePct : na
    viewMoveUsedState := na(viewMoveUsedPct) ? "n/a" : viewMoveUsedPct < 0 ? "Adverse" : viewMoveUsedPct <= 40 ? "Early" : viewMoveUsedPct <= 70 ? "OK" : viewMoveUsedPct <= 90 ? "Late" : "Exhausted"
    viewInvalidationMaeBasis := viewSelectedMae75
    bool canCalculateInvalidation = viewSelectedDataInvariantOk and (selectedRiskUseLong or selectedRiskUseShort) and selectedWindowIsActive and selectedWindowDataReady and viewSelectedMaeMetricsAvailable and not na(viewCurrentDailyClose) and viewCurrentDailyClose > 0 and not na(viewInvalidationMaeBasis)
    viewInvalidationLevel := canCalculateInvalidation ? selectedRiskUseLong ? viewWindowEntryPrice * (1.0 - viewInvalidationMaeBasis / 100.0) : viewWindowEntryPrice * (1.0 + viewInvalidationMaeBasis / 100.0) : na
    bool canCalculateInvalidationDistance = canCalculateInvalidation and not na(viewInvalidationLevel) and viewInvalidationLevel > 0
    viewDistanceToInvalidationPct := canCalculateInvalidationDistance ? selectedRiskUseLong ? (viewCurrentDailyClose / viewInvalidationLevel - 1.0) * 100.0 : (viewInvalidationLevel / viewCurrentDailyClose - 1.0) * 100.0 : na
    bool viewInvalidated = canCalculateInvalidationDistance and (selectedRiskUseLong ? viewCurrentDailyClose <= viewInvalidationLevel : viewCurrentDailyClose >= viewInvalidationLevel)
    viewInvalidationState := canCalculateInvalidationDistance and not na(viewInvalidationMaeBasis) ? viewInvalidated ? "Invalidated" : viewDistanceToInvalidationPct <= viewInvalidationMaeBasis * 0.5 ? "Near" : "OK" : "n/a"
    viewSeasonalRR := viewSelectedCompleteRiskMetricsAvailable and not na(viewRemainingPotentialPct) and not na(viewSelectedMae75) and viewSelectedMae75 > 0 ? math.max(0.0, viewRemainingPotentialPct / viewSelectedMae75) : na
    viewSeasonalRRState := na(viewSeasonalRR) ? "n/a" : viewSeasonalRR >= 2.0 ? "Strong" : viewSeasonalRR >= 1.5 ? "Good" : viewSeasonalRR >= 1.0 ? "Acceptable" : "Weak"
    bool hasSelectedEdge = viewHasSelectedZone
    bool viewSelectedZoneIsActive = selectedWindowIsActive
    bool viewSelectedZoneIsPending = selectedWindowIsPending
    bool directionalLate = (selectedRiskUseLong or selectedRiskUseShort) and not na(viewMoveUsedPct) and viewMoveUsedPct >= 70
    string selectedStatusState = viewSelectedZoneIsWeak ? "Weak" : viewSelectedZoneIsWatch ? "Watch" : "Active"
    tradeabilityState := not isViewTfSupported ? "Unsupported" : not viewSelectedDataInvariantOk ? "Data Error" : not hasSelectedEdge ? "No Edge" : viewInvalidationState == "Invalidated" ? "Invalidated" : selectedWindowIsExpired ? "Expired" : viewSelectedZoneIsActive and directionalLate ? "Late" : viewSelectedZoneIsActive ? selectedStatusState : viewSelectedZoneIsPending ? viewSelectedZoneIsWeak ? "Weak" : "Pre" : "Watch"
    viewNoEdgeReason := not viewSelectedDataInvariantOk ? "Selected-zone data error" : viewNoEdgeReason
    viewNoEdgeReasonCode := f_noEdgeReasonCode(viewNoEdgeReason, tradeabilityState, viewSeasonalRRState)
    string finalEvidenceNoEdgeReason = viewHasSelectedZone ? viewNoEdgeReason : viewNoEdgeReasonCode
    selectedFinalEvidenceViewModel := selectedZoneUseLong ? f_evidenceViewModelFromLockedZone(SEG_LONG, lockedLong, viewSeasonalRRState, finalEvidenceNoEdgeReason) : selectedZoneUseShort ? f_evidenceViewModelFromLockedZone(SEG_SHORT, lockedShort, viewSeasonalRRState, finalEvidenceNoEdgeReason) : f_evidenceViewModelNone(finalEvidenceNoEdgeReason)
    float remainingRatio = not na(viewRemainingPotentialPct) and not na(selectedMfeBasis) and selectedMfeBasis > 0 ? viewRemainingPotentialPct / selectedMfeBasis : na
    viewRemainingMoveScore := na(remainingRatio) ? na : remainingRatio >= 0.75 ? 100.0 : remainingRatio >= 0.50 ? 80.0 : remainingRatio >= 0.25 ? 60.0 : viewRemainingPotentialPct > 0 ? 40.0 : 10.0
    viewRRScore := na(viewSeasonalRR) ? na : viewSeasonalRR >= 2.0 ? 100.0 : viewSeasonalRR >= 1.5 ? 80.0 : viewSeasonalRR >= 1.0 ? 60.0 : viewSeasonalRR >= 0.5 ? 35.0 : 10.0
    viewMoveUsedScore := na(viewMoveUsedPct) ? na : viewMoveUsedPct < 0 ? 65.0 : viewMoveUsedPct <= 40 ? 100.0 : viewMoveUsedPct <= 70 ? 75.0 : viewMoveUsedPct <= 90 ? 40.0 : 10.0
    viewInvalidationScore := viewInvalidationState == "Invalidated" ? 0.0 : viewInvalidationState == "Near" ? 30.0 : viewInvalidationState == "OK" ? viewDistanceToInvalidationPct > viewInvalidationMaeBasis ? 100.0 : 80.0 : na
    bool hasDirectionalPotentialInputs = selectedRiskUseLong or selectedRiskUseShort
    float directionalPotentialScore = hasDirectionalPotentialInputs and not na(viewRemainingMoveScore) and not na(viewRRScore) and not na(viewMoveUsedScore) and not na(viewVolatilityFitScore) and not na(viewInvalidationScore) ? viewRemainingMoveScore * 0.30 + viewRRScore * 0.25 + viewMoveUsedScore * 0.20 + viewVolatilityFitScore * 0.15 + viewInvalidationScore * 0.10 : na
    if not na(directionalPotentialScore)
        directionalPotentialScore := viewInvalidationState == "Invalidated" ? math.min(directionalPotentialScore, 20.0) : directionalPotentialScore
        directionalPotentialScore := not na(viewMoveUsedPct) and viewMoveUsedPct > 100 ? math.min(directionalPotentialScore, 35.0) : directionalPotentialScore
        directionalPotentialScore := viewVolRegimeCode == 4 and not na(viewMoveUsedPct) and viewMoveUsedPct > 70 ? math.min(directionalPotentialScore, 40.0) : directionalPotentialScore
        int completeRiskSampleCount = math.min(viewSelectedMaeSampleCount, viewSelectedMfeSampleCount)
        directionalPotentialScore := completeRiskSampleCount < effectiveMinSampleYears ? math.min(directionalPotentialScore, 50.0) : directionalPotentialScore
    viewPotentialScore := hasDirectionalPotentialInputs ? math.min(100.0, math.max(0.0, directionalPotentialScore)) : na
    if not na(viewPotentialScore)
        if viewOutlierRisk == "Extreme"
            viewPotentialScore := math.min(viewPotentialScore, 45.0)
        if viewOutlierRisk == "High"
            viewPotentialScore := math.min(viewPotentialScore, 65.0)
        if not na(viewEdgeRobustnessScore) and viewEdgeRobustnessScore < 40
            viewPotentialScore := math.min(viewPotentialScore, 50.0)
        if not na(viewEdgeRobustnessScore) and viewEdgeRobustnessScore >= 80 and viewOutlierRisk == "Low"
            viewPotentialScore := math.min(100.0, viewPotentialScore + 5.0)
        if enableTradabilityGate
            viewPotentialScore := tradeabilityState == "Pre" ? math.min(viewPotentialScore, 75.0) : tradeabilityState == "Late" ? math.min(viewPotentialScore, 55.0) : tradeabilityState == "Expired" ? math.min(viewPotentialScore, 20.0) : tradeabilityState == "Invalidated" ? math.min(viewPotentialScore, 15.0) : tradeabilityState == "Unsupported" ? na : viewPotentialScore
    viewPotentialState := tradeabilityState == "Pre" and not na(viewPotentialScore) ? "Watch" : na(viewPotentialScore) ? "n/a" : viewPotentialScore >= potentialStrongThreshold ? "Strong" : viewPotentialScore < potentialWeakThreshold ? "Weak" : "Valid"
    viewPotentialDirectionLabel := selectedRiskUseLong ? "L" : selectedRiskUseShort ? "S" : "-"
    viewSelectedFinalQualityGrade := viewSelectedRiskMode != "NONE" ? viewSelectedFinalQualityGrade : "D"
    viewSelectedConfidenceWinRate := selectedFinalEvidenceViewModel.trainingWilsonLower
    viewSelectedSeparationScore := isReferenceScan ? na : selectedRiskUseLong ? f_directionalSeparation(viewBestLongScore, viewBestShortScore) : selectedRiskUseShort ? f_directionalSeparation(viewBestShortScore, viewBestLongScore) : na
    viewSelectedSeparationGrade := f_directionalSeparationGrade(viewSelectedSeparationScore)
    string baseRobustnessLabel = viewOutlierRisk == "Extreme" ? "Outlier Extreme" : viewOutlierRisk == "High" ? "Outlier Risk" : viewEdgeStabilityLabel == "Diverging" or viewEdgeStabilityLabel == "Weak" ? "Recent Weak" : viewEdgeStabilityLabel == "Stable" and (viewOutlierRisk == "Low" or viewOutlierRisk == "Medium") ? "Robust" : viewEdgeStabilityLabel == "Softer" ? "Softer" : "Valid"
    string plateauSummaryLabel = selectedFinalEvidenceViewModel.plateauGrade == "Reject" or selectedFinalEvidenceViewModel.plateauGrade == "Weak" ? "Weak Plateau" : selectedFinalEvidenceViewModel.plateauGrade == "Strong" or selectedFinalEvidenceViewModel.plateauGrade == "Valid" ? "Plateau" : ""
    string plateauShortLabel = f_evidencePlateauShort(selectedFinalEvidenceViewModel.plateauGrade)
    viewSelectedRobustnessLabel := viewSelectedRiskMode != "NONE" and plateauSummaryLabel != "" ? plateauSummaryLabel : baseRobustnessLabel
    viewTradeabilitySummary := tradeabilityState == "Invalidated" or viewInvalidationState == "Invalidated" ? "Invalidated" : tradeabilityState == "Expired" ? "Expired" : tradeabilityState == "Pre" ? "Watch" : tradeabilityState == "Late" or viewMoveUsedState == "Late" or viewMoveUsedState == "Exhausted" ? "Late" : viewMoveUsedState == "Early" ? "Early" : tradeabilityState == "Active" ? "Active" : tradeabilityState
    viewNoEdgeReasonCode := f_noEdgeReasonCode(viewNoEdgeReason, tradeabilityState, viewSeasonalRRState)
    string compactTimingLabel = viewMoveUsedState
    string compactRrLabel = viewSeasonalRRState == "Strong" or viewSeasonalRRState == "Good" or viewSeasonalRRState == "Acceptable" ? "RR OK" : viewSeasonalRRState == "Weak" ? "RR weak" : "RR n/a"
    viewCompactEdgeSummary := (viewSelectedRiskMode == "LONG" ? "Long " + viewSelectedFinalQualityGrade + " | " + viewTradeabilitySummary + " | " + viewSelectedRobustnessLabel + " | " + compactTimingLabel + " | " + compactRrLabel : viewSelectedRiskMode == "SHORT" ? "Short " + viewSelectedFinalQualityGrade + " | " + viewTradeabilitySummary + " | " + viewSelectedRobustnessLabel + " | " + compactTimingLabel + " | " + compactRrLabel : viewHasSelectedZone ? "Edge present | Potential n/a" : "No Edge | " + viewNoEdgeReasonCode) + f_viewModelProjectedSuffix(selectedFinalEvidenceViewModel)
    viewQualitySummary := "FQ:" + viewSelectedFinalQualityGrade + " WL90:" + f_evidenceWl90Text(viewSelectedConfidenceWinRate) + " Sep:" + viewSelectedSeparationGrade + " OR:" + viewOutlierRisk + " Stab:" + viewEdgeStabilityLabel + " Plat:" + plateauShortLabel + " " + selectedRealPlateauDiag
    string viewEvidencePotentialSummary = f_evidencePotentialLine(selectedFinalEvidenceViewModel)
    string viewVerificationEvidenceHeader = f_evidenceVerificationHeader()
    selectedDynamicContext := f_zoneDynamicContext(selectedCanonicalZone, selectedTradeWindow, currentDailyConfirmedTime, viewCurrentDailyClose, selectedEntryPrice, viewCurrentMovePct, viewMoveUsedPct, viewRemainingPotentialPct, viewSelectedMedianMae, viewSelectedMedianMfe, viewSelectedMae75, viewSelectedMfe75, viewInvalidationState, viewSeasonalRR, viewVolatilityFitScore, viewVolRegimeCode, viewPotentialScore, tradeabilityState)

    bool hasDirectionalVerificationRows = array.size(viewLongVerificationYears) > 0 or array.size(viewShortVerificationYears) > 0
    renderHistoricalLongFinal := renderHistoricalLong and hasDirectionalVerificationRows
    renderHistoricalShortFinal := renderHistoricalShort and hasDirectionalVerificationRows

    // Future geometry uses selected Daily zone timestamps only; no view-TF bar offsets or time arithmetic.
    array<string> acceptedVisibleZoneId = array.new_string()
    array<int> acceptedVisibleSide = array.new_int()
    array<int> acceptedVisibleEntryTarget = array.new_int()
    array<int> acceptedVisibleExitTarget = array.new_int()
    array<bool> acceptedVisibleOutlineOnly = array.new_bool()
    if syncFutureZoneObjects and canRenderFutureZones and isViewTfSupported and showFutureZones
        // All modes, including Best Zone, render the finalized registry. Best
        // Zone membership is already reduced to the Primary map index upstream.
        if visibleRegistrySize > 0
            for i = 0 to visibleRegistrySize - 1
                VisibleZone zone = array.get(visibleZoneRegistry, i)
                if array.size(acceptedVisibleZoneId) < MAX_VISIBLE_SEASONAL_ZONES and zone.valid and f_validBarTimeWindow(zone.entryTime, zone.exitTime)
                    bool overlapsOppositeSide = false
                    if array.size(acceptedVisibleSide) > 0
                        for acceptedSlot = 0 to array.size(acceptedVisibleSide) - 1
                            if zone.entryTargetDailyBarIndex <= array.get(acceptedVisibleExitTarget, acceptedSlot) and zone.exitTargetDailyBarIndex >= array.get(acceptedVisibleEntryTarget, acceptedSlot)
                                overlapsOppositeSide := overlapsOppositeSide or zone.side != array.get(acceptedVisibleSide, acceptedSlot)
                    array.push(acceptedVisibleZoneId, zone.zoneId)
                    array.push(acceptedVisibleSide, zone.side)
                    array.push(acceptedVisibleEntryTarget, zone.entryTargetDailyBarIndex)
                    array.push(acceptedVisibleExitTarget, zone.exitTargetDailyBarIndex)
                    array.push(acceptedVisibleOutlineOnly, overlapsOppositeSide)
    if syncFutureZoneObjects
        for poolSlot = 0 to MAX_VISIBLE_SEASONAL_ZONES - 1
            string poolZoneId = array.get(futurePoolZoneId, poolSlot)
            if str.length(poolZoneId) > 0
                bool acceptedVisible = false
                if array.size(acceptedVisibleSide) > 0
                    for acceptedSlot = 0 to array.size(acceptedVisibleSide) - 1
                        if array.get(acceptedVisibleZoneId, acceptedSlot) == poolZoneId
                            acceptedVisible := true
                            break
                if not f_visibleRegistryOwnsZoneId(poolZoneId)
                    f_releaseFutureZoneSlot(poolSlot)
                else if not acceptedVisible
                    f_hideFutureZoneSlot(poolSlot)
    if syncFutureZoneObjects and canRenderFutureZones and isViewTfSupported and showFutureZones
        float zoneTop = zoneTopPrepared
        float zoneBottom = zoneBottomPrepared
        if array.size(acceptedVisibleSide) > 0
            for acceptedSlot = 0 to array.size(acceptedVisibleSide) - 1
                string acceptedZoneId = array.get(acceptedVisibleZoneId, acceptedSlot)
                for i = 0 to visibleRegistrySize - 1
                    VisibleZone zone = array.get(visibleZoneRegistry, i)
                    if zone.zoneId == acceptedZoneId
                        bool isPrimaryZone = selectedLockedSide == zone.side and (zone.side == SEG_LONG and lockedLong.valid and lockedLong.seasonalZone.zoneId == zone.zoneId or zone.side == SEG_SHORT and lockedShort.valid and lockedShort.seasonalZone.zoneId == zone.zoneId)
                        string lifecycle = f_renderLifecycle(currentDailyConfirmedTime, zone.entryTime, zone.exitTime)
                        f_syncFutureZoneSlot(zone.zoneId, zone.side, zone.entryTargetDailyBarIndex, zone.exitTargetDailyBarIndex, zone.entryTime, zone.exitTime, lifecycle, isPrimaryZone, array.get(acceptedVisibleOutlineOnly, acceptedSlot), zone.scannerStatus, zone.qualityCode, zoneTop, zoneBottom, futureRenderMode, labelTextSize, acceptedVisibleZoneId)
                        break
    if syncFutureZoneObjects
        lastFutureRenderGeneration := registryGeneration

    // Risk/Reward uses the explicit Operational Trade Window; zone rendering remains canonical.
    int rrSelectedEntryTime = selectedTradeEntryTime
    int rrSelectedExitTime = selectedTradeExitTime
    float rrSelectedEntryPrice = selectedEntryPrice
    bool canRenderRiskRewardBands = showRiskRewardBands and isViewTfSupported and viewSelectedDataInvariantOk and selectedWindowIsActive and selectedWindowDataReady and (selectedRiskUseLong or selectedRiskUseShort) and viewSelectedCompleteRiskMetricsAvailable and f_validBarTimeWindow(rrSelectedEntryTime, rrSelectedExitTime)
    bool syncRiskRewardObjects = syncFutureZoneObjects
    if syncRiskRewardObjects
        if array.size(riskRewardLines) > 0
            for i = 0 to array.size(riskRewardLines) - 1
                line.delete(array.get(riskRewardLines, i))
        if array.size(riskRewardLabels) > 0
            for i = 0 to array.size(riskRewardLabels) - 1
                label.delete(array.get(riskRewardLabels, i))
        array.clear(riskRewardLines)
        array.clear(riskRewardLabels)
        if canRenderRiskRewardBands
            bool rrFullMode = riskRewardBandMode == "Full"
            int rrX1 = rrSelectedEntryTime
            int rrX2 = rrSelectedExitTime
            float rrEntryPrice = rrSelectedEntryPrice
            float rrMedianMfeTarget = not na(viewSelectedMedianMfe) ? selectedRiskUseLong ? rrEntryPrice * (1.0 + viewSelectedMedianMfe / 100.0) : rrEntryPrice * (1.0 - viewSelectedMedianMfe / 100.0) : na
            float rrMfe75Target = not na(viewSelectedMfe75) ? selectedRiskUseLong ? rrEntryPrice * (1.0 + viewSelectedMfe75 / 100.0) : rrEntryPrice * (1.0 - viewSelectedMfe75 / 100.0) : na
            float rrMedianMaeLevel = not na(viewSelectedMedianMae) ? selectedRiskUseLong ? rrEntryPrice * (1.0 - viewSelectedMedianMae / 100.0) : rrEntryPrice * (1.0 + viewSelectedMedianMae / 100.0) : na
            float rrMae75Level = not na(viewSelectedMae75) ? selectedRiskUseLong ? rrEntryPrice * (1.0 - viewSelectedMae75 / 100.0) : rrEntryPrice * (1.0 + viewSelectedMae75 / 100.0) : na
            if not na(rrMedianMfeTarget)
                f_addRiskRewardLevel(riskRewardLines, riskRewardLabels, rrX1, rrX2, rrMedianMfeTarget, "Med MFE", color.new(color.green, 25), line.style_solid, color.new(color.green, 80), labelTextSize)
            if not na(rrMae75Level)
                f_addRiskRewardLevel(riskRewardLines, riskRewardLabels, rrX1, rrX2, rrMae75Level, "MAE75", color.new(color.red, 25), line.style_dashed, color.new(color.red, 82), labelTextSize)
            if rrFullMode and not na(rrMfe75Target)
                f_addRiskRewardLevel(riskRewardLines, riskRewardLabels, rrX1, rrX2, rrMfe75Target, "MFE75", color.new(color.green, 45), line.style_dotted, color.new(color.green, 86), labelTextSize)
            if rrFullMode and not na(rrMedianMaeLevel)
                f_addRiskRewardLevel(riskRewardLines, riskRewardLabels, rrX1, rrX2, rrMedianMaeLevel, "Med MAE", color.new(color.red, 45), line.style_dotted, color.new(color.red, 86), labelTextSize)

    string visibleStatusText = selectedLockedSide != SEG_NONE ? "Tradeable" : f_segmentStatusText(viewPrimaryStatus)
    if showMainStatsPanel and isViewTfSupported
        f_cellBgTip(mainStatsTable, 0, 0, "AutoQ", color.white, color.new(color.gray, 78), TOOLTIP_AUTOQ_PANEL)
        f_cellMutedBgTip(mainStatsTable, 1, 0, f_qualityModeText(qualityStrength), color.new(color.gray, 85), TOOLTIP_AUTOQ_PANEL)
        f_cellMutedBg(mainStatsTable, 2, 0, "WR " + str.tostring(math.round(effectiveMinWinRatePct)) + "%", color.new(color.gray, 85))
        f_cellMutedBg(mainStatsTable, 3, 0, str.tostring(lookbackYears) + "Y", color.new(color.gray, 85))
        f_cellMutedBg(mainStatsTable, 4, 0, "View " + timeframe.period, color.new(color.gray, 85))
        f_cellMutedBgTip(mainStatsTable, 5, 0, visibleStatusText, color.new(color.gray, 85), TOOLTIP_VISIBLE_STATUS)
        f_cellMutedBgTip(mainStatsTable, 6, 0, isReferenceScan ? "Gate Off" : "Gate On", color.new(color.gray, 85), TOOLTIP_QUALITY_GATE_STATUS)
        f_headerCell(mainStatsTable, 0, 1, "Side", color.new(color.gray, 80))
        f_headerCell(mainStatsTable, 1, 1, "Window", color.new(color.gray, 80))
        f_headerCell(mainStatsTable, 2, 1, "Win", color.new(color.gray, 80))
        f_headerCell(mainStatsTable, 3, 1, "Avg", color.new(color.gray, 80))
        f_headerCell(mainStatsTable, 4, 1, "DD", color.new(color.gray, 80))
        f_headerCell(mainStatsTable, 5, 1, "SQN", color.new(color.gray, 80))
        f_headerCell(mainStatsTable, 6, 1, "Trades", color.new(color.gray, 80))
        int row = 2
        if showLongRow
            f_headerCell(mainStatsTable, 0, row, "Long", color.new(color.green, 78))
            f_cellMuted(mainStatsTable, 1, row, viewHasLong ? formatOffset(viewLongEntryOffsetDisplay) + "→" + formatOffset(viewLongExitOffsetDisplay) : "-")
            f_cellMuted(mainStatsTable, 2, row, viewHasLong ? formatAbsPct(viewBestLongWinRatePct) : "-")
            f_cellMuted(mainStatsTable, 3, row, viewHasLong ? formatSignedPct(viewBestLongAvgProfitPct) : "-")
            f_cellMuted(mainStatsTable, 4, row, viewHasLong ? formatAbsPct(viewBestLongAvgDrawdownPct) : "-")
            f_cellMuted(mainStatsTable, 5, row, viewHasLong ? formatNumber(viewBestLongSqn) : "-")
            f_cellMuted(mainStatsTable, 6, row, viewHasLong ? formatTrades(viewBestLongWinningTrades, viewBestLongValidTrades) : "-")
            row += 1
        if showShortRow
            f_headerCell(mainStatsTable, 0, row, "Short", color.new(color.red, 78))
            f_cellMuted(mainStatsTable, 1, row, viewHasShort ? formatOffset(viewShortEntryOffsetDisplay) + "→" + formatOffset(viewShortExitOffsetDisplay) : "-")
            f_cellMuted(mainStatsTable, 2, row, viewHasShort ? formatAbsPct(viewBestShortWinRatePct) : "-")
            f_cellMuted(mainStatsTable, 3, row, viewHasShort ? formatSignedPct(viewBestShortAvgProfitPct) : "-")
            f_cellMuted(mainStatsTable, 4, row, viewHasShort ? formatAbsPct(viewBestShortAvgDrawdownPct) : "-")
            f_cellMuted(mainStatsTable, 5, row, viewHasShort ? formatNumber(viewBestShortSqn) : "-")
            f_cellMuted(mainStatsTable, 6, row, viewHasShort ? formatTrades(viewBestShortWinningTrades, viewBestShortValidTrades) : "-")
            row += 1
        if showLongQualRow
            f_headerCell(mainStatsTable, 0, row, "L Qual", color.new(color.green, 85))
            f_cellMuted(mainStatsTable, 1, row, viewHasLong ? viewLongQualityGrade : "-")
            f_cellMuted(mainStatsTable, 2, row, viewHasLong ? formatAbsPct(viewLongSampleCoveragePct) : "-")
            f_cellMuted(mainStatsTable, 3, row, viewHasLong ? formatAbsPct(viewLongRecentWinRatePct) : "-")
            f_cellMuted(mainStatsTable, 4, row, viewHasLong ? formatSignedPct(viewLongMedianProfitPct) : "-")
            f_cellMuted(mainStatsTable, 5, row, viewHasLong ? formatSignedPct(viewLongOutlierImpactPct) : "-")
            f_cell(mainStatsTable, 6, row, viewHasLong and viewLongOverfitWarning ? "WARN" : "-", viewLongOverfitWarning ? color.orange : panelMutedTextColor)
            row += 1
        if showShortQualRow
            f_headerCell(mainStatsTable, 0, row, "S Qual", color.new(color.red, 85))
            f_cellMuted(mainStatsTable, 1, row, viewHasShort ? viewShortQualityGrade : "-")
            f_cellMuted(mainStatsTable, 2, row, viewHasShort ? formatAbsPct(viewShortSampleCoveragePct) : "-")
            f_cellMuted(mainStatsTable, 3, row, viewHasShort ? formatAbsPct(viewShortRecentWinRatePct) : "-")
            f_cellMuted(mainStatsTable, 4, row, viewHasShort ? formatSignedPct(viewShortMedianProfitPct) : "-")
            f_cellMuted(mainStatsTable, 5, row, viewHasShort ? formatSignedPct(viewShortOutlierImpactPct) : "-")
            f_cell(mainStatsTable, 6, row, viewHasShort and viewShortOverfitWarning ? "WARN" : "-", viewShortOverfitWarning ? color.orange : panelMutedTextColor)
            row += 1
        if showBiasRow
            string biasCell = not enableBiasClassifier ? "OFF" : viewFinalBias
            string biasReasonCell = not enableBiasClassifier ? "-" : viewFinalBias != "NO EDGE" ? "-" : viewNoEdgeReasonCode
            f_headerCell(mainStatsTable, 0, row, "Bias", color.new(color.purple, 78))
            f_cellMuted(mainStatsTable, 1, row, biasCell)
            f_cellMuted(mainStatsTable, 2, row, "Q:" + viewFinalBiasQuality)
            f_cellMutedTip(mainStatsTable, 3, row, viewFinalBiasWindow, TOOLTIP_PROJECTED_TIME)
            f_cellMuted(mainStatsTable, 4, row, "Auto")
            f_cellMuted(mainStatsTable, 5, row, formatNumber(viewFinalBiasScore))
            f_cellMutedTip(mainStatsTable, 6, row, biasReasonCell, TOOLTIP_NO_EDGE_REASON)
            row += 1
        if showEvidenceRow
            f_headerCell(mainStatsTable, 0, row, "Ev", color.new(color.teal, 78))
            f_cellMutedTip(mainStatsTable, 1, row, isReferenceScan ? "Ref " + f_evidenceWinsText(selectedCanonicalZone.referenceSuccesses, selectedCanonicalZone.referenceSamples) : "Train " + f_evidenceWinsText(selectedFinalEvidenceViewModel.trainingSuccesses, selectedFinalEvidenceViewModel.trainingSamples), TOOLTIP_EVIDENCE_ROW)
            f_cellMutedTip(mainStatsTable, 2, row, isReferenceScan ? "WR " + formatAbsPct(selectedCanonicalZone.referenceWinRate) : "WL90 " + f_evidenceWl90Text(selectedFinalEvidenceViewModel.trainingWilsonLower), TOOLTIP_EVIDENCE_ROW)
            f_cellMutedTip(mainStatsTable, 3, row, "Plat " + f_evidencePlateauShort(selectedFinalEvidenceViewModel.plateauGrade), TOOLTIP_EVIDENCE_ROW)
            f_cellMutedTip(mainStatsTable, 4, row, selectedFinalEvidenceViewModel.holdoutDepth == "Disabled" ? "OOS Off" : "OOS " + f_evidenceWinsText(selectedFinalEvidenceViewModel.holdoutSuccesses, selectedFinalEvidenceViewModel.holdoutSamples), TOOLTIP_EVIDENCE_ROW)
            f_cellMutedTip(mainStatsTable, 5, row, selectedFinalEvidenceViewModel.holdoutDepth, TOOLTIP_EVIDENCE_ROW)
            f_cellMutedTip(mainStatsTable, 6, row, selectedFinalEvidenceViewModel.holdoutStatus, TOOLTIP_EVIDENCE_ROW)
        if showPotentialPanel and isViewTfSupported and not na(potentialPanel)
            bool hasPotentialData = selectedDynamicContext.valid and not na(selectedDynamicContext.potentialScore)
            string dailyEdgeText = not viewHasSelectedZone ? "No Daily edge" : viewSelectedZoneIsPending ? "Pending Daily edge" : viewSelectedZoneIsActive ? "Active Daily edge" : selectedDynamicContext.tradeability == "Expired" ? "Expired Daily edge" : "Edge present | Potential n/a"
            color potentialHeaderBg = color.new(color.teal, 78)
            color potentialScoreColor = selectedDynamicContext.tradeability == "Invalidated" ? color.red : not hasPotentialData ? panelMutedTextColor : selectedDynamicContext.potentialScore >= potentialStrongThreshold ? color.lime : selectedDynamicContext.potentialScore < potentialWeakThreshold ? color.orange : color.yellow
            f_cellBgTip(potentialPanel, 0, 0, "Seasonal Potential", color.white, potentialHeaderBg, TOOLTIP_SEASONAL_POTENTIAL_PANEL)
            f_cellBgTip(potentialPanel, 1, 0, viewCompactEdgeSummary, potentialScoreColor, color.new(color.gray, 85), TOOLTIP_SEASONAL_POTENTIAL_PANEL)
            if hasPotentialData
                f_cellMuted(potentialPanel, 0, 1, showTradabilityState ? "Dynamic" : "Dyn Score")
                f_cell(potentialPanel, 1, 1, showTradabilityState ? selectedDynamicContext.tradeability : f_scoreText(selectedDynamicContext.potentialScore) + " " + viewPotentialState, potentialScoreColor)
                f_cellMuted(potentialPanel, 0, 2, "Vol Fit")
                f_cellMuted(potentialPanel, 1, 2, f_scoreText(selectedDynamicContext.volatilityFit))
                f_cellMuted(potentialPanel, 0, 3, "Remaining")
                f_cellMuted(potentialPanel, 1, 3, na(selectedDynamicContext.remainingPotential) ? "-" : formatSignedPct(selectedDynamicContext.remainingPotential))
                f_cellMuted(potentialPanel, 0, 4, "Move Used")
                f_cellMuted(potentialPanel, 1, 4, (na(selectedDynamicContext.moveUsed) ? "-" : (selectedDynamicContext.moveUsed > 0 ? "+" : "") + str.tostring(math.round(selectedDynamicContext.moveUsed)) + "%") + " " + viewMoveUsedState)
                f_cellMuted(potentialPanel, 0, 5, "RR")
                f_cell(potentialPanel, 1, 5, (na(selectedDynamicContext.seasonalRR) ? "n/a" : str.tostring(selectedDynamicContext.seasonalRR, "#.0")) + " " + viewSeasonalRRState, panelMutedTextColor)
                f_cellMuted(potentialPanel, 0, 6, "Risk")
                f_cell(potentialPanel, 1, 6, selectedDynamicContext.invalidation, selectedDynamicContext.invalidation == "Invalidated" ? color.red : selectedDynamicContext.invalidation == "Near" ? color.orange : panelMutedTextColor)
                f_cellMuted(potentialPanel, 0, 7, "Robust")
                f_cell(potentialPanel, 1, 7, showEdgeRobustness and edgeRobustnessMode != "Off" ? f_scoreText(viewEdgeRobustnessScore) + " | OR " + viewOutlierRisk + (edgeRobustnessMode == "Full" ? " " + viewEdgeStabilityLabel : "") : "Off", viewOutlierRisk == "High" or viewOutlierRisk == "Extreme" ? color.orange : panelMutedTextColor)
                f_cellMutedTip(potentialPanel, 0, 8, "Stable", TOOLTIP_EVIDENCE_ROW)
                f_cellMutedTip(potentialPanel, 1, 8, viewEvidencePotentialSummary, TOOLTIP_EVIDENCE_ROW)
            else
                f_cellMutedTip(potentialPanel, 0, 1, selectedDynamicContext.tradeability == "Unsupported" ? "Unsupported TF" : dailyEdgeText, TOOLTIP_NO_EDGE_REASON)
                f_cellMutedTip(potentialPanel, 1, 1, viewHasSelectedZone ? selectedDynamicContext.tradeability : viewNoEdgeReasonCode, TOOLTIP_NO_EDGE_REASON)
        if showVerificationPanel and isViewTfSupported
            bool selectedVerificationIsLong = viewSelectedRiskMode == "LONG"
            bool selectedVerificationIsShort = viewSelectedRiskMode == "SHORT"
            bool selectedVerificationHasDirectional = selectedVerificationIsLong or selectedVerificationIsShort
            array<int> panelYears = selectedVerificationIsLong ? viewLongVerificationYears : viewShortVerificationYears
            array<float> panelProfits = selectedVerificationIsLong ? viewLongVerificationProfits : viewShortVerificationProfits
            array<float> panelDrawdowns = selectedVerificationIsLong ? viewLongVerificationDrawdowns : viewShortVerificationDrawdowns
            int panelDirectionalRows = array.size(panelYears)
            int panelDirectionalDisplayRows = math.min(panelDirectionalRows, effectiveDisplayRows)
            string verificationModeText = selectedVerificationIsLong ? "LONG" : selectedVerificationIsShort ? "SHORT" : "NONE"
            string verificationRiskCoverageText = verificationModeText + " M" + str.tostring(viewSelectedMaeSampleCount) + "/F" + str.tostring(viewSelectedMfeSampleCount)
            f_headerCell(verificationPanel, 0, 0, "Verification", color.new(color.gray, 75))
            f_cellBg(verificationPanel, 1, 0, verificationRiskCoverageText, color.yellow, color.new(color.gray, 82))
            f_cellMutedBgTip(verificationPanel, 2, 0, viewVerificationEvidenceHeader, color.new(color.gray, 82), TOOLTIP_EVIDENCE_ROW)
            f_headerCell(verificationPanel, 0, 1, "Year", color.new(color.gray, 80))
            f_headerCell(verificationPanel, 1, 1, "P/L", color.new(color.gray, 80))
            f_headerCell(verificationPanel, 2, 1, "DD", color.new(color.gray, 80))
            if selectedVerificationHasDirectional and panelDirectionalDisplayRows > 0
                for rowIdx = 0 to panelDirectionalDisplayRows - 1
                    int row = rowIdx + 2
                    float p = array.get(panelProfits, rowIdx)
                    f_cellMuted(verificationPanel, 0, row, f_verificationYearText(array.get(panelYears, rowIdx)))
                    f_cell(verificationPanel, 1, row, formatSignedPct(p), p > 0 ? color.lime : color.red)
                    f_cell(verificationPanel, 2, row, formatAbsPct(array.get(panelDrawdowns, rowIdx)), color.orange)
            else
                f_cellPlain(verificationPanel, 0, 2, "No valid period")
if barstate.islast
    string historicalRenderSignature = lastDecodedVerificationSignature + "|" + str.tostring(registryGeneration) + "|" + str.tostring(showHistoricalPeriods) + "|" + str.tostring(showHistoricalLabels)
    if historicalRenderSignature != lastHistoricalRenderSignature
        if array.size(historicalLines) > 0
            for i = 0 to array.size(historicalLines) - 1
                line.delete(array.get(historicalLines, i))
        if array.size(historicalBoxes) > 0
            for i = 0 to array.size(historicalBoxes) - 1
                box.delete(array.get(historicalBoxes, i))
        if array.size(historicalLabels) > 0
            for i = 0 to array.size(historicalLabels) - 1
                label.delete(array.get(historicalLabels, i))
        array.clear(historicalLines)
        array.clear(historicalBoxes)
        array.clear(historicalLabels)

        renderedHistoricalLongCount := 0
        renderedHistoricalShortCount := 0
        bool hasDirectionalVerificationRows = array.size(viewLongVerificationYears) > 0 or array.size(viewShortVerificationYears) > 0
        int historicalRenderLimit = math.min(effectiveDisplayRows, MAX_HISTORICAL_RENDER_PERIODS)
        // Historical verification rendering is delete-before-redraw and bounded by the configured period/object cap.
        if showHistoricalPeriods and isViewTfSupported and hasDirectionalVerificationRows

            if renderHistoricalLongFinal and hasDirectionalVerificationRows
                color edgeColorLong = color.new(color.green, 50)
                int renderedLong = 0
                int longRows = array.size(viewLongVerificationYears)
                for i = 0 to longRows - 1
                    if renderedLong < historicalRenderLimit
                        int t1 = array.get(viewLongVerificationEntryTimes, i)
                        int t2 = array.get(viewLongVerificationExitTimes, i)
                        float profitLong = array.get(viewLongVerificationProfits, i)
                        float drawdownLong = array.get(viewLongVerificationDrawdowns, i)
                        float lo = array.get(viewLongVerificationLows, i)
                        float hi = array.get(viewLongVerificationHighs, i)
                        if not na(t1) and not na(t2) and not na(lo) and not na(hi)
                            bool histLongWin = profitLong > 0
                            color outcomeColorLong = histLongWin ? color.new(color.green, 0) : color.new(color.red, 0)
                            color bandColorLong = historicalBandColorMode == "Direction" ? edgeColorLong : outcomeColorLong
                            float pad = (hi - lo) * 0.05
                            float top = hi + pad
                            float bot = lo - pad
                            line l1 = line.new(t1, top, t1, bot, xloc = xloc.bar_time, color = edgeColorLong, style = line.style_solid, width = 1, extend = extend.none)
                            line l2 = line.new(t2, top, t2, bot, xloc = xloc.bar_time, color = edgeColorLong, style = line.style_dotted, width = 1, extend = extend.none)
                            box b = box.new(t1, top, t2, bot, xloc = xloc.bar_time, bgcolor = color.new(bandColorLong, 82), border_color = color.new(edgeColorLong, 100))
                            array.push(historicalBoxes, b)
                            if showHistoricalLabels and labelTextSize != "None"
                                label lb = label.new(t2, top, formatSignedPct(profitLong) + " | DD " + formatAbsPct(drawdownLong), xloc = xloc.bar_time, style = label.style_label_down, color = color.new(color.black, 35), textcolor = color.white, size = f_textSize(labelTextSize))
                                array.push(historicalLabels, lb)
                            array.push(historicalLines, l1)
                            array.push(historicalLines, l2)
                            renderedLong += 1
                renderedHistoricalLongCount := renderedLong

            if renderHistoricalShortFinal and hasDirectionalVerificationRows
                color edgeColorShort = color.new(color.red, 50)
                int renderedShort = 0
                int shortRows = array.size(viewShortVerificationYears)
                for i = 0 to shortRows - 1
                    if renderedShort < historicalRenderLimit
                        int t1 = array.get(viewShortVerificationEntryTimes, i)
                        int t2 = array.get(viewShortVerificationExitTimes, i)
                        float profitShort = array.get(viewShortVerificationProfits, i)
                        float drawdownShort = array.get(viewShortVerificationDrawdowns, i)
                        float lo = array.get(viewShortVerificationLows, i)
                        float hi = array.get(viewShortVerificationHighs, i)
                        if not na(t1) and not na(t2) and not na(lo) and not na(hi)
                            bool histShortWin = profitShort > 0
                            color outcomeColorShort = histShortWin ? color.new(color.green, 0) : color.new(color.red, 0)
                            color bandColorShort = historicalBandColorMode == "Direction" ? edgeColorShort : outcomeColorShort
                            float pad = (hi - lo) * 0.05
                            float top = hi + pad
                            float bot = lo - pad
                            line l1 = line.new(t1, top, t1, bot, xloc = xloc.bar_time, color = edgeColorShort, style = line.style_solid, width = 1, extend = extend.none)
                            line l2 = line.new(t2, top, t2, bot, xloc = xloc.bar_time, color = edgeColorShort, style = line.style_dotted, width = 1, extend = extend.none)
                            box b = box.new(t1, top, t2, bot, xloc = xloc.bar_time, bgcolor = color.new(bandColorShort, 82), border_color = color.new(edgeColorShort, 100))
                            array.push(historicalBoxes, b)
                            if showHistoricalLabels and labelTextSize != "None"
                                label lb = label.new(t2, top, formatSignedPct(profitShort) + " | DD " + formatAbsPct(drawdownShort), xloc = xloc.bar_time, style = label.style_label_down, color = color.new(color.black, 35), textcolor = color.white, size = f_textSize(labelTextSize))
                                array.push(historicalLabels, lb)
                            array.push(historicalLines, l1)
                            array.push(historicalLines, l2)
                            renderedShort += 1
                renderedHistoricalShortCount := renderedShort
        lastHistoricalRenderSignature := historicalRenderSignature
var float previousPotentialScoreForAlert = na
var float previousMoveUsedPctForAlert = na
var float previousCurrentMovePctForAlert = na
var string previousInvalidationStateForAlert = "n/a"
var float previousRobustnessScoreForAlert = na
var string previousOutlierRiskForAlert = "n/a"
var string previousTradeabilityStateForAlert = "n/a"
var string previousAlertZoneId = ""
bool potentialTurnsStrong = false
bool potentialTurnsWeak = false
bool lateRiskHigh = false
bool exhausted = false
bool invalidationTouched = false
bool mfe75Reached = false
bool robustnessWeakAlert = false
bool outlierRiskHighAlert = false
bool tradeabilityInvalidatedAlert = false

if barstate.islast
    string currentAlertZoneId = selectedDynamicContext.valid ? selectedDynamicContext.zoneId : ""
    bool sameAlertZone = str.length(currentAlertZoneId) > 0 and currentAlertZoneId == previousAlertZoneId
    bool selectedAlertModeEligible = viewSelectedRiskMode == "LONG" ? visibleLongValid : viewSelectedRiskMode == "SHORT" ? visibleShortValid : false
    bool selectedAlertAllowed = enablePotentialAlerts and viewSelectedDataInvariantOk and (visibleLongValid or visibleShortValid) and selectedAlertModeEligible and viewSelectedRiskMode != "NONE" and selectedFinalEvidenceViewModel.plateauGrade != "Reject" and not na(viewSelectedFinalQualityGrade) and str.length(viewSelectedFinalQualityGrade) > 0
    bool directionalAlertAllowed = selectedAlertAllowed and (viewSelectedRiskMode == "LONG" or viewSelectedRiskMode == "SHORT")
    bool hasPotentialAlertScore = selectedAlertAllowed and not na(selectedDynamicContext.potentialScore)
    bool hasMoveUsedAlertValue = directionalAlertAllowed and not na(selectedDynamicContext.moveUsed)
    bool hasCurrentMoveAlertValue = directionalAlertAllowed and not na(selectedDynamicContext.currentMove) and not na(viewSelectedMfe75)
    potentialTurnsStrong := sameAlertZone and hasPotentialAlertScore and not na(previousPotentialScoreForAlert) and selectedDynamicContext.potentialScore >= potentialStrongThreshold and previousPotentialScoreForAlert < potentialStrongThreshold
    potentialTurnsWeak := sameAlertZone and hasPotentialAlertScore and not na(previousPotentialScoreForAlert) and selectedDynamicContext.potentialScore <= potentialWeakThreshold and previousPotentialScoreForAlert > potentialWeakThreshold
    lateRiskHigh := sameAlertZone and hasMoveUsedAlertValue and not na(previousMoveUsedPctForAlert) and selectedDynamicContext.moveUsed >= 70 and previousMoveUsedPctForAlert < 70
    exhausted := sameAlertZone and hasMoveUsedAlertValue and not na(previousMoveUsedPctForAlert) and selectedDynamicContext.moveUsed >= 90 and previousMoveUsedPctForAlert < 90
    invalidationTouched := sameAlertZone and directionalAlertAllowed and selectedDynamicContext.invalidation == "Invalidated" and previousInvalidationStateForAlert != "Invalidated"
    mfe75Reached := sameAlertZone and hasCurrentMoveAlertValue and not na(previousCurrentMovePctForAlert) and selectedDynamicContext.currentMove >= viewSelectedMfe75 and previousCurrentMovePctForAlert < viewSelectedMfe75
    robustnessWeakAlert := sameAlertZone and selectedAlertAllowed and not na(viewEdgeRobustnessScore) and viewEdgeRobustnessScore < 40 and not na(previousRobustnessScoreForAlert) and previousRobustnessScoreForAlert >= 40
    outlierRiskHighAlert := sameAlertZone and selectedAlertAllowed and (viewOutlierRisk == "High" or viewOutlierRisk == "Extreme") and previousOutlierRiskForAlert != viewOutlierRisk
    tradeabilityInvalidatedAlert := sameAlertZone and selectedAlertAllowed and selectedDynamicContext.tradeability == "Invalidated" and previousTradeabilityStateForAlert != "Invalidated"
    previousPotentialScoreForAlert := selectedDynamicContext.potentialScore
    previousMoveUsedPctForAlert := selectedDynamicContext.moveUsed
    previousCurrentMovePctForAlert := selectedDynamicContext.currentMove
    previousInvalidationStateForAlert := selectedDynamicContext.invalidation
    previousRobustnessScoreForAlert := viewEdgeRobustnessScore
    previousOutlierRiskForAlert := viewOutlierRisk
    previousTradeabilityStateForAlert := selectedDynamicContext.tradeability
    previousAlertZoneId := currentAlertZoneId
    string canonicalAlertEvent = potentialTurnsStrong ? "POTENTIAL_STRONG" : potentialTurnsWeak ? "POTENTIAL_WEAK" : lateRiskHigh ? "LATE_RISK" : exhausted ? "MOVE_EXHAUSTED" : invalidationTouched ? "INVALIDATION" : mfe75Reached ? "MFE75" : robustnessWeakAlert ? "ROBUSTNESS_WEAK" : outlierRiskHighAlert ? "OUTLIER_RISK" : tradeabilityInvalidatedAlert ? "SETUP_INVALIDATED" : ""
    if str.length(canonicalAlertEvent) > 0
        alert("SeasonalTrader|" + canonicalAlertEvent + "|zoneId=" + currentAlertZoneId + "|" + syminfo.ticker, alert.freq_once_per_bar_close)


alertcondition(potentialTurnsStrong, "Seasonal Potential Strong", "Seasonal Potential strong: {{ticker}}")
alertcondition(potentialTurnsWeak, "Seasonal Potential Weak", "Seasonal Potential weak: {{ticker}}")
alertcondition(lateRiskHigh, "Seasonal Late Risk High", "Late entry risk high: {{ticker}}")
alertcondition(exhausted, "Seasonal Move Exhausted", "Seasonal move exhausted: {{ticker}}")
alertcondition(invalidationTouched, "Seasonal Invalidation Touched", "Seasonal invalidation touched: {{ticker}}")
alertcondition(mfe75Reached, "Seasonal 75% MFE Reached", "Seasonal 75% MFE target reached: {{ticker}}")
alertcondition(robustnessWeakAlert, "Seasonal Robustness Weak", "Seasonal robustness weakened: {{ticker}}")
alertcondition(outlierRiskHighAlert, "Seasonal Outlier Risk High", "Seasonal outlier risk high: {{ticker}}")
alertcondition(tradeabilityInvalidatedAlert, "Seasonal Setup Invalidated", "Seasonal setup invalidated: {{ticker}}")

// Development-only capture surface for the Phase-0 replay contract. Enabling
// the compile-time flag exposes the otherwise internal digests without adding a
// permanent input, panel, selection dependency, or renderer dependency.
if barstate.islast
    if ENABLE_PHASE0_DIAGNOSTICS and isDailyChart
        string phase0DiagnosticText = "ANCHORS\n" + phase0AnchorDigest + "\n\nGEOMETRY\n" + phase0CanonicalGeometryDigest + "\n\nEVIDENCE\n" + phase0EvidenceDigest + "\n\nELIGIBILITY\n" + phase0EligibilityDigest + "\n\nREGISTRY\n" + phase0RegistryDigest
        if na(phase0CaptureSurfaceLabel)
            phase0CaptureSurfaceLabel := label.new(bar_index, high, phase0DiagnosticText, xloc = xloc.bar_index, yloc = yloc.abovebar, style = label.style_label_down, color = color.new(color.black, 10), textcolor = color.white, size = size.tiny)
        else
            label.set_xy(phase0CaptureSurfaceLabel, bar_index, high)
            label.set_text(phase0CaptureSurfaceLabel, phase0DiagnosticText)
    else if not na(phase0CaptureSurfaceLabel)
        label.delete(phase0CaptureSurfaceLabel)
        phase0CaptureSurfaceLabel := na
````
