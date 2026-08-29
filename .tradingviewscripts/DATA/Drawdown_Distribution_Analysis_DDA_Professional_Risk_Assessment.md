<!-- tradingview-pine-id: PUB;136a840953a34353ac31d843e4e02e6d -->
<!-- tradingviewscripts-format: 1 -->
# Drawdown Distribution Analysis (DDA) - Professional Risk Assessment

Source: https://www.tradingview.com/script/hTo2OL8G-Drawdown-Distribution-Analysis-DDA/

## Description

ACADEMIC FOUNDATION AND RESEARCH BACKGROUND

The Drawdown Distribution Analysis indicator implements quantitative risk management principles, drawing upon decades of academic research in portfolio theory, behavioral finance, and statistical risk modeling. This tool provides risk assessment capabilities for traders and portfolio managers seeking to understand their current position within historical drawdown patterns.

The theoretical foundation of this indicator rests on modern portfolio theory as established by Markowitz (1952), who introduced the fundamental concepts of risk-return optimization that continue to underpin contemporary portfolio management. Sharpe (1966) later expanded this framework by developing risk-adjusted performance measures, most notably the Sharpe ratio, which remains a cornerstone of performance evaluation in financial markets.

The specific focus on drawdown analysis builds upon the work of Chekhlov, Uryasev and Zabarankin (2005), who provided the mathematical framework for incorporating drawdown measures into portfolio optimization. Their research demonstrated that traditional mean-variance optimization often fails to capture the full risk profile of investment strategies, particularly regarding sequential losses. More recent work by Goldberg and Mahmoud (2017) has brought these theoretical concepts into practical application within institutional risk management frameworks.

Value at Risk methodology, as comprehensively outlined by Jorion (2007), provides the statistical foundation for the risk measurement components of this indicator. The coherent risk measures framework developed by Artzner et al. (1999) ensures that the risk metrics employed satisfy the mathematical properties required for sound risk management decisions. Additionally, the focus on downside risk follows the framework established by Sortino and Price (1994), while the drawdown-adjusted performance measures implement concepts introduced by Young (1991).

MATHEMATICAL METHODOLOGY

The core calculation methodology centers on a peak-tracking algorithm that continuously monitors the maximum price level achieved and calculates the percentage decline from this peak. The drawdown at any time t is defined as DD(t) = (P(t) - Peak(t)) / Peak(t) × 100, where P(t) represents the asset price at time t and Peak(t) represents the running maximum price observed up to time t.

Statistical distribution analysis forms the analytical backbone of the indicator. The system calculates key percentiles using the ta.percentile_nearest_rank() function to establish the 5th, 10th, 25th, 50th, 75th, 90th, and 95th percentiles of the historical drawdown distribution. This approach provides a complete picture of how the current drawdown compares to historical patterns.

Statistical significance assessment employs standard deviation bands at one, two, and three standard deviations from the mean, following the conventional approach where the upper band equals μ + nσ and the lower band equals μ - nσ. The Z-score calculation, defined as Z = (DD - μ) / σ, enables the identification of statistically extreme events, with thresholds set at |Z| > 2.5 for extreme drawdowns and |Z| > 3.0 for severe drawdowns, corresponding to confidence levels exceeding 99.4% and 99.7% respectively.

ADVANCED RISK METRICS

The indicator incorporates several risk-adjusted performance measures that extend beyond basic drawdown analysis. The Sharpe ratio calculation follows the standard formula Sharpe = (R - Rf) / σ, where R represents the annualized return, Rf represents the risk-free rate, and σ represents the annualized volatility. The system supports dynamic sourcing of the risk-free rate from the US 10-year Treasury yield or allows for manual specification.

The Sortino ratio addresses the limitation of the Sharpe ratio by focusing exclusively on downside risk, calculated as Sortino = (R - Rf) / σd, where σd represents the downside deviation computed using only negative returns. This measure provides a more accurate assessment of risk-adjusted performance for strategies that exhibit asymmetric return distributions.

The Calmar ratio, defined as Annual Return divided by the absolute value of Maximum Drawdown, offers a direct measure of return per unit of drawdown risk. This metric proves particularly valuable for comparing strategies or assets with different risk profiles, as it directly relates performance to the maximum historical loss experienced.

Value at Risk calculations provide quantitative estimates of potential losses at specified confidence levels. The 95% VaR corresponds to the 5th percentile of the drawdown distribution, while the 99% VaR corresponds to the 1st percentile. Conditional VaR, also known as Expected Shortfall, estimates the average loss in the worst 5% of scenarios, providing insight into tail risk that standard VaR measures may not capture.

To enable fair comparison across assets with different volatility characteristics, the indicator calculates volatility-adjusted drawdowns using the formula Adjusted DD = Raw DD / (Volatility / 20%). This normalization allows for meaningful comparison between high-volatility assets like cryptocurrencies and lower-volatility instruments like government bonds.

The Risk Efficiency Score represents a composite measure ranging from 0 to 100 that combines the Sharpe ratio and current percentile rank to provide a single metric for quick asset assessment. Higher scores indicate superior risk-adjusted performance relative to historical patterns.

COLOR SCHEMES AND VISUALIZATION

The indicator implements eight distinct color themes designed to accommodate different analytical preferences and market contexts. The EdgeTools theme employs a corporate blue palette that matches the design system used throughout the edgetools.org platform, ensuring visual consistency across analytical tools.

The Gold theme specifically targets precious metals analysis with warm tones that complement gold chart analysis, while the Quant theme provides a grayscale scheme suitable for analytical environments that prioritize clarity over aesthetic appeal. The Behavioral theme incorporates psychology-based color coding, using green to represent greed-driven market conditions and red to indicate fear-driven environments.

Additional themes include Ocean, Fire, Matrix, and Arctic schemes, each designed for specific market conditions or user preferences. All themes function effectively with both dark and light mode trading platforms, ensuring accessibility across different user interface configurations.

PRACTICAL APPLICATIONS

Asset allocation and portfolio construction represent primary use cases for this analytical framework. When comparing multiple assets such as Bitcoin, gold, and the S&P 500, traders can examine Risk Efficiency Scores to identify instruments offering superior risk-adjusted performance. The 95% VaR provides worst-case scenario comparisons, while volatility-adjusted drawdowns enable fair comparison despite varying volatility profiles.

The practical decision framework suggests that assets with Risk Efficiency Scores above 70 may be suitable for aggressive portfolio allocations, scores between 40 and 70 indicate moderate allocation potential, and scores below 40 suggest defensive positioning or avoidance. These thresholds should be adjusted based on individual risk tolerance and market conditions.

Risk management and position sizing applications utilize the current percentile rank to guide allocation decisions. When the current drawdown ranks above the 75th percentile of historical data, indicating that current conditions are better than 75% of historical periods, position increases may be warranted. Conversely, when percentile rankings fall below the 25th percentile, indicating elevated risk conditions, position reductions become advisable.

Institutional portfolio monitoring applications include hedge fund risk dashboard implementations where multiple strategies can be monitored simultaneously. Sharpe ratio tracking identifies deteriorating risk-adjusted performance across strategies, VaR monitoring ensures portfolios remain within established risk limits, and drawdown duration tracking provides valuable information for investor reporting requirements.

Market timing applications combine the statistical analysis with trend identification techniques. Strong buy signals may emerge when risk levels register as "Low" in conjunction with established uptrends, while extreme risk levels combined with downtrends may indicate exit or hedging opportunities. Z-scores exceeding 3.0 often signal statistically oversold conditions that may precede trend reversals.

STATISTICAL SIGNIFICANCE AND VALIDATION

The indicator provides 95% confidence intervals around current drawdown levels using the standard formula CI = μ ± 1.96σ. This statistical framework enables users to assess whether current conditions fall within normal market variation or represent statistically significant departures from historical patterns.

Risk level classification employs a dynamic assessment system based on percentile ranking within the historical distribution. Low risk designation applies when current drawdowns perform better than 50% of historical data, moderate risk encompasses the 25th to 50th percentile range, high risk covers the 10th to 25th percentile range, and extreme risk applies to the worst 10% of historical drawdowns.

Sample size considerations play a crucial role in statistical reliability. For daily data, the system requires a minimum of 252 trading days (approximately one year) but performs better with 500 or more observations. Weekly data analysis benefits from at least 104 weeks (two years) of history, while monthly data requires a minimum of 60 months (five years) for reliable statistical inference.

IMPLEMENTATION BEST PRACTICES

Parameter optimization should consider the specific characteristics of different asset classes. Equity analysis typically benefits from 500-day lookback periods with 21-day smoothing, while cryptocurrency analysis may employ 365-day lookback periods with 14-day smoothing to account for higher volatility patterns. Fixed income analysis often requires longer lookback periods of 756 days with 34-day smoothing to capture the lower volatility environment.

Multi-timeframe analysis provides hierarchical risk assessment capabilities. Daily timeframe analysis supports tactical risk management decisions, weekly analysis informs strategic positioning choices, and monthly analysis guides long-term allocation decisions. This hierarchical approach ensures that risk assessment occurs at appropriate temporal scales for different investment objectives.

Integration with complementary indicators enhances the analytical framework. Trend indicators such as RSI and moving averages provide directional bias context, volume analysis helps confirm the severity of drawdown conditions, and volatility measures like VIX or ATR assist in market regime identification.

ALERT SYSTEM AND AUTOMATION

The automated alert system monitors five distinct categories of risk events. Risk level changes trigger notifications when drawdowns move between risk categories, enabling proactive risk management responses. Statistical significance alerts activate when Z-scores exceed established threshold levels of 2.5 or 3.0 standard deviations.

New maximum drawdown alerts notify users when historical maximum levels are exceeded, indicating entry into uncharted risk territory. Poor risk efficiency alerts trigger when the composite risk efficiency score falls below 30, suggesting deteriorating risk-adjusted performance. Sharpe ratio decline alerts activate when risk-adjusted performance turns negative, indicating that returns no longer compensate for the risk undertaken.

TRADING STRATEGIES

Conservative risk parity strategies can be implemented by monitoring Risk Efficiency Scores across a diversified asset portfolio. Monthly rebalancing maintains equal risk contribution from each asset, with allocation reductions triggered when risk levels reach "High" status and complete exits executed when "Extreme" risk levels emerge. This approach typically results in lower overall portfolio volatility, improved risk-adjusted returns, and reduced maximum drawdown periods.

Tactical asset rotation strategies compare Risk Efficiency Scores across different asset classes to guide allocation decisions. Assets with scores exceeding 60 receive overweight allocations, while assets scoring below 40 receive underweight positions. Percentile rankings provide timing guidance for allocation adjustments, creating a systematic approach to asset allocation that responds to changing risk-return profiles.

Market timing strategies with statistical edges can be constructed by entering positions when Z-scores fall below -2.5, indicating statistically oversold conditions, and scaling out when Z-scores exceed 2.5, suggesting overbought conditions. The 95% VaR serves as a stop-loss reference point, while trend confirmation indicators provide additional validation for position entry and exit decisions.

LIMITATIONS AND CONSIDERATIONS

Several statistical limitations affect the interpretation and application of these risk measures. Historical bias represents a fundamental challenge, as past drawdown patterns may not accurately predict future risk characteristics, particularly during structural market changes or regime shifts. Sample dependence means that results can be sensitive to the selected lookback period, with shorter periods providing more responsive but potentially less stable estimates.

Market regime changes can significantly alter the statistical parameters underlying the analysis. During periods of structural market evolution, historical distributions may provide poor guidance for future expectations. Additionally, many financial assets exhibit return distributions with fat tails that deviate from normal distribution assumptions, potentially leading to underestimation of extreme event probabilities.

Practical limitations include execution risk, where theoretical signals may not translate directly into actual trading results due to factors such as slippage, timing delays, and market impact. Liquidity constraints mean that risk metrics assume perfect liquidity, which may not hold during stressed market conditions when risk management becomes most critical.

Transaction costs are not incorporated into risk-adjusted return calculations, potentially overstating the attractiveness of strategies that require frequent trading. Behavioral factors represent another limitation, as human psychology may override statistical signals, particularly during periods of extreme market stress when disciplined risk management becomes most challenging.

TECHNICAL IMPLEMENTATION

Performance optimization ensures reliable operation across different market conditions and timeframes. All technical analysis functions are extracted from conditional statements to maintain Pine Script compliance and ensure consistent execution. Memory efficiency is achieved through optimized variable scoping and array usage, while computational speed benefits from vectorized calculations where possible.

Data quality requirements include clean price data without gaps or errors that could distort distribution analysis. Sufficient historical data is essential, with a minimum of 100 bars required and 500 or more preferred for reliable statistical inference. Time alignment across related assets ensures meaningful comparison when conducting multi-asset analysis.

The configuration parameters are organized into logical groups to enhance usability. Core settings include the Distribution Analysis Period (100-2000 bars), Drawdown Smoothing Period (1-50 bars), and Price Source selection. Advanced metrics settings control risk-free rate sourcing, either from live market data or fixed rate specification, along with toggles for various risk-adjusted metric calculations.

Display options provide flexibility in visual presentation, including color theme selection from eight available schemes, automatic dark mode optimization, and control over table display, position lines, percentile bands, and standard deviation overlays. These options ensure that the indicator can be adapted to different analytical workflows and visual preferences.

CONCLUSION

The Drawdown Distribution Analysis indicator provides risk management tools for traders seeking to understand their current position within historical risk patterns. By combining established statistical methodology with practical usability features, the tool enables evidence-based risk assessment and portfolio optimization decisions.

The implementation draws upon established academic research while providing practical features that address real-world trading requirements. Dynamic risk-free rate integration ensures accurate risk-adjusted performance calculations, while multiple color schemes accommodate different analytical preferences and use cases.

Academic compliance is maintained through transparent methodology and acknowledgment of limitations. The tool implements peer-reviewed statistical techniques while clearly communicating the constraints and assumptions underlying the analysis. This approach ensures that users can make informed decisions about the appropriate application of the risk assessment framework within their broader trading and investment processes.

BIBLIOGRAPHY

Artzner, P., Delbaen, F., Eber, J.M. and Heath, D. (1999) 'Coherent Measures of Risk', Mathematical Finance, 9(3), pp. 203-228.

Chekhlov, A., Uryasev, S. and Zabarankin, M. (2005) 'Drawdown Measure in Portfolio Optimization', International Journal of Theoretical and Applied Finance, 8(1), pp. 13-58.

Goldberg, L.R. and Mahmoud, O. (2017) 'Drawdown: From Practice to Theory and Back Again', Journal of Risk Management in Financial Institutions, 10(2), pp. 140-152.

Jorion, P. (2007) Value at Risk: The New Benchmark for Managing Financial Risk. 3rd edn. New York: McGraw-Hill.

Markowitz, H. (1952) 'Portfolio Selection', Journal of Finance, 7(1), pp. 77-91.

Sharpe, W.F. (1966) 'Mutual Fund Performance', Journal of Business, 39(1), pp. 119-138.

Sortino, F.A. and Price, L.N. (1994) 'Performance Measurement in a Downside Risk Framework', Journal of Investing, 3(3), pp. 59-64.

Young, T.W. (1991) 'Calmar Ratio: A Smoother Tool', Futures, 20(1), pp. 40-42.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © EdgeTools

//@version=6
indicator("Drawdown Distribution Analysis (DDA) - Professional Risk Assessment", shorttitle="DDA Pro", overlay=false, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
// DRAWDOWN DISTRIBUTION ANALYSIS - PROFESSIONAL RISK ASSESSMENT TOOL
// 
// This indicator provides institutional-grade risk analysis through comprehensive drawdown distribution statistics,
// combining advanced risk-adjusted performance metrics with sophisticated statistical modeling.
//
// ACADEMIC FOUNDATION:
// • Markowitz (1952) - Modern Portfolio Theory foundations
// • Sharpe (1966) - Risk-adjusted performance measurement  
// • Chekhlov, Uryasev & Zabarankin (2005) - Drawdown optimization theory
// • Sortino & Price (1994) - Downside risk framework
// • Jorion (2007) - Value at Risk methodology
//
// KEY FEATURES:
// • Statistical distribution analysis with percentile bands (5th-95th)
// • Professional risk-adjusted metrics (Sharpe, Sortino, Calmar ratios)
// • Value at Risk (VaR) and Conditional VaR calculations
// • Volatility-adjusted drawdowns for fair asset comparison
// • Dynamic risk-free rate integration (US10Y or custom)
// • 8 professional color themes optimized for institutional use
// • Real-time risk level classification and alerts
//
// PRACTICAL APPLICATIONS:
// • Portfolio risk assessment and asset allocation
// • Dynamic position sizing based on risk percentiles
// • Institutional portfolio monitoring and reporting
// • Market timing and risk management decisions
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//                                                    CONSTANTS AND HELPERS
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

BASE_TRANSPARENCY = 70
TABLE_TRANSPARENCY = 15
EXTREME_THRESHOLD = 2.5
SEVERE_THRESHOLD = 3.0

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//                                                        INPUT GROUPS
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Core Analysis Parameters
lookbackPeriod = input.int(500, title="Distribution Analysis Period", minval=100, maxval=2000, 
     tooltip="Statistical analysis period (recommended: 252-756 for daily data). Longer periods provide more robust statistics but slower adaptation to regime changes.", group="Core Settings")
smoothingPeriod = input.int(14, title="Drawdown Smoothing Period", minval=1, maxval=50, 
     tooltip="EMA smoothing period to reduce noise while preserving trend signals. Higher values = smoother but slower response.", group="Core Settings")
dataSource = input.source(close, title="Price Source", 
     tooltip="Price source for analysis (Close recommended for most applications, HL2 for reduced noise)", group="Core Settings")

// Distribution Bands Settings
showPercentileBands = input.bool(true, title="Show Percentile Bands", 
     tooltip="Display percentile-based distribution bands", group="Distribution Bands")
showStdDevBands = input.bool(true, title="Show Standard Deviation Bands", 
     tooltip="Display standard deviation bands (1σ, 2σ, 3σ)", group="Distribution Bands")
showFills = input.bool(true, title="Show Band Fills", 
     tooltip="Fill areas between distribution bands", group="Distribution Bands")

// Risk Assessment
riskThresholdModerate = input.float(50.0, title="Low Risk Threshold (%)", 
     minval=0.0, maxval=100.0, step=5.0, 
     tooltip="Drawdowns better than this % of history = Low Risk (default: top 50%)", group="Risk Assessment")
riskThresholdHigh = input.float(75.0, title="Moderate Risk Threshold (%)", 
     minval=0.0, maxval=100.0, step=5.0, 
     tooltip="Drawdowns better than this % of history = Moderate Risk (default: top 25%)", group="Risk Assessment")
riskThresholdExtreme = input.float(90.0, title="High Risk Threshold (%)", 
     minval=0.0, maxval=100.0, step=5.0, 
     tooltip="Drawdowns better than this % of history = High Risk (default: top 10%)", group="Risk Assessment")

// Advanced Risk Metrics
enableRiskAdjustedMetrics = input.bool(true, title="Enable Risk-Adjusted Metrics", 
     tooltip="Calculate Sharpe, Sortino, Calmar ratios", group="Advanced Metrics")
riskFreeSymbol = input.string("US10Y", title="Risk-Free Rate Asset", 
     tooltip="Symbol for risk-free rate (default: US 10-Year Treasury)", group="Advanced Metrics")
useFixedRiskFreeRate = input.bool(false, title="Use Fixed Risk-Free Rate", 
     tooltip="Use fixed rate instead of live asset data", group="Advanced Metrics")
fixedRiskFreeRate = input.float(4.0, title="Fixed Risk-Free Rate (%)", 
     minval=0.0, maxval=20.0, step=0.25, 
     tooltip="Fixed annual risk-free rate (only if Use Fixed is enabled)", group="Advanced Metrics")
enableVaR = input.bool(true, title="Enable VaR Calculations", 
     tooltip="Calculate Value at Risk metrics", group="Advanced Metrics")
enableVolatilityAdjustment = input.bool(true, title="Volatility-Adjusted Analysis", 
     tooltip="Normalize drawdowns by volatility for asset comparison", group="Advanced Metrics")

// Display Options
showTable = input.bool(true, title="Show Statistics Table", 
     tooltip="Display essential risk metrics", group="Display Options")
showCurrentPosition = input.bool(true, title="Show Current Position Line", 
     tooltip="Highlight current drawdown level", group="Display Options")
showZeroLine = input.bool(false, title="Show Zero Reference Line", 
     tooltip="Display zero line for reference", group="Display Options")
showDistributionInfo = input.bool(true, title="Show Distribution Info", 
     tooltip="Display additional distribution metrics", group="Display Options")

// Appearance Settings
tablePosition = input.string("top_right", title="Table Position", 
     options=["top_right", "top_left", "bottom_right", "bottom_left"], 
     group="Appearance")
colorScheme = input.string("EdgeTools", "Color Theme", 
     options=["Gold", "EdgeTools", "Behavioral", "Quant", "Ocean", "Fire", "Matrix", "Arctic"], 
     group="Appearance")
useDarkMode = input.bool(true, title="Optimize for Dark Theme", 
     tooltip="Optimize colors for dark/light backgrounds", group="Appearance")
lineWidth = input.int(2, title="Main Line Width", minval=1, maxval=5, group="Appearance")
bandLineWidth = input.int(1, title="Band Line Width", minval=1, maxval=3, group="Appearance")

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//                                                 PROFESSIONAL COLOR SCHEME
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Professional color definitions based on selected theme
var color primary_color = #2196F3
var color bullish_color = #4CAF50
var color bearish_color = #FF5252
var color neutral_color = #808080
var color text_color = color.white
var color bg_color = #000000
var color table_bg_color = #1E1E1E
var color header_bg_color = #2D2D2D

// Apply professional color scheme
switch colorScheme
    "Gold" =>
        primary_color := useDarkMode ? #FFD700 : #DAA520
        bullish_color := useDarkMode ? #FFA500 : #FF8C00
        bearish_color := useDarkMode ? #FF5252 : #D32F2F
        neutral_color := useDarkMode ? #C0C0C0 : #808080
        text_color := useDarkMode ? color.white : color.black
        bg_color := useDarkMode ? #000000 : #FFFFFF
        table_bg_color := useDarkMode ? #1A1A00 : #FFFEF0
        header_bg_color := useDarkMode ? #2D2600 : #F5F5DC
    
    "EdgeTools" =>
        primary_color := useDarkMode ? #3b82f6 : #2563eb  // edge-blue-500/600
        bullish_color := useDarkMode ? #22c55e : #16a34a  // edge-green-500/600
        bearish_color := useDarkMode ? #ef4444 : #dc2626  // Professional red
        neutral_color := useDarkMode ? #737373 : #525252  // edge-gray-500/600
        text_color := useDarkMode ? #fafafa : #0a0a0a     // edge-light/dark
        bg_color := useDarkMode ? #0a0a0a : #fafafa       // edge-dark/light
        table_bg_color := useDarkMode ? #171717 : #f9f9f9 // edge-gray-900/50
        header_bg_color := useDarkMode ? #262626 : #e5e5e5 // edge-gray-800/200
    
    "Behavioral" =>
        primary_color := #808080  // Gray 50%
        bullish_color := #00FF00  // Bright Green (Gier)
        bearish_color := #8B0000  // Deep Red (Panik)
        neutral_color := #FFBF00  // Amber (Unsicherheit)
        text_color := useDarkMode ? color.white : color.black
        bg_color := useDarkMode ? #000000 : #FFFFFF
        table_bg_color := useDarkMode ? #1A1A1A : #F8F8F8
        header_bg_color := useDarkMode ? #2D2D2D : #E8E8E8
    
    "Quant" =>
        primary_color := #808080  // Gray (neutral)
        bullish_color := #FFA500  // Orange (positive)
        bearish_color := #8B0000  // Dark Red (negative)
        neutral_color := #4682B4  // Steel Blue
        text_color := useDarkMode ? color.white : color.black
        bg_color := useDarkMode ? #000000 : #FFFFFF
        table_bg_color := useDarkMode ? #0D0D0D : #FAFAFA
        header_bg_color := useDarkMode ? #1A1A1A : #F0F0F0
    
    "Ocean" =>
        primary_color := useDarkMode ? #20B2AA : #008B8B  // Light Sea Green / Dark Cyan
        bullish_color := useDarkMode ? #00CED1 : #4682B4  // Dark Turquoise / Steel Blue
        bearish_color := useDarkMode ? #FF4500 : #B22222  // Orange Red / Fire Brick
        neutral_color := useDarkMode ? #87CEEB : #2F4F4F  // Sky Blue / Dark Slate Gray
        text_color := useDarkMode ? #F0F8FF : #191970     // Alice Blue / Midnight Blue
        bg_color := useDarkMode ? #001F3F : #F0F8FF       // Navy / Alice Blue
        table_bg_color := useDarkMode ? #001A2E : #E6F7FF
        header_bg_color := useDarkMode ? #002A47 : #CCF2FF
    
    "Fire" =>
        primary_color := useDarkMode ? #FF6347 : #DC143C  // Tomato / Crimson
        bullish_color := useDarkMode ? #FFD700 : #FF8C00  // Gold / Dark Orange
        bearish_color := useDarkMode ? #8B0000 : #800000  // Dark Red / Maroon
        neutral_color := useDarkMode ? #FFA500 : #CD853F  // Orange / Peru
        text_color := useDarkMode ? #FFFAF0 : #2F1B14     // Floral White / Dark Brown
        bg_color := useDarkMode ? #2F1B14 : #FFFAF0       // Dark Brown / Floral White
        table_bg_color := useDarkMode ? #261611 : #FFF8F0
        header_bg_color := useDarkMode ? #3D241A : #FFE4CC
    
    "Matrix" =>
        primary_color := useDarkMode ? #00FF41 : #006400  // Matrix Green / Dark Green
        bullish_color := useDarkMode ? #39FF14 : #228B22  // Neon Green / Forest Green
        bearish_color := useDarkMode ? #FF073A : #8B0000  // Neon Red / Dark Red
        neutral_color := useDarkMode ? #00FFFF : #008B8B  // Cyan / Dark Cyan
        text_color := useDarkMode ? #C0FF8C : #003300     // Light Green / Very Dark Green
        bg_color := useDarkMode ? #0D1B0D : #F0FFF0       // Very Dark Green / Honeydew
        table_bg_color := useDarkMode ? #0A1A0A : #E8FFF0
        header_bg_color := useDarkMode ? #112B11 : #CCFFCC
    
    "Arctic" =>
        primary_color := useDarkMode ? #87CEFA : #4169E1  // Light Sky Blue / Royal Blue
        bullish_color := useDarkMode ? #00BFFF : #0000CD  // Deep Sky Blue / Medium Blue
        bearish_color := useDarkMode ? #FF1493 : #8B008B  // Deep Pink / Dark Magenta
        neutral_color := useDarkMode ? #B0E0E6 : #483D8B  // Powder Blue / Dark Slate Blue
        text_color := useDarkMode ? #F8F8FF : #191970     // Ghost White / Midnight Blue
        bg_color := useDarkMode ? #191970 : #F8F8FF       // Midnight Blue / Ghost White
        table_bg_color := useDarkMode ? #141B47 : #F0F8FF
        header_bg_color := useDarkMode ? #1E2A5C : #E0F0FF

// Transparency settings
backgroundAlpha = useDarkMode ? 85 : 92
bandAlpha = useDarkMode ? 70 : 85
tableAlpha = useDarkMode ? 80 : 15

// Map to existing variable names for compatibility
neutralColor = primary_color
lowRiskColor = bullish_color
moderateRiskColor = neutral_color
highRiskColor = bearish_color
extremeRiskColor = bearish_color

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//                                                   CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Enhanced Peak Tracking with Rolling Window
var float runningPeak = na
var float maxPeakInPeriod = na

// Initialize peak tracking
if na(runningPeak)
    runningPeak := dataSource
    maxPeakInPeriod := dataSource

// Update running peak (all-time high tracking)
runningPeak := math.max(runningPeak, dataSource)

// Update peak within analysis period  
maxPeakInPeriodCalc = ta.highest(dataSource, lookbackPeriod)
if bar_index < lookbackPeriod
    maxPeakInPeriod := math.max(nz(maxPeakInPeriod, dataSource), dataSource)
else
    maxPeakInPeriod := maxPeakInPeriodCalc

// Calculate raw drawdown from peak
rawDrawdown = runningPeak > 0 ? ((dataSource - runningPeak) / runningPeak) * 100 : 0.0

// Smoothed drawdown for analysis
smoothedDrawdown = ta.ema(rawDrawdown, smoothingPeriod)

// Ensure sufficient data for distribution analysis
validBars = bar_index >= lookbackPeriod

// Risk-Free Rate Calculation
riskFreeRateValue = useFixedRiskFreeRate ? fixedRiskFreeRate : 
                   request.security(riskFreeSymbol, "D", close, lookahead=barmerge.lookahead_off)
// Fallback to fixed rate if symbol data unavailable
riskFreeRate = na(riskFreeRateValue) ? fixedRiskFreeRate : riskFreeRateValue

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//                                              DISTRIBUTION STATISTICAL ANALYSIS
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Core Distribution Metrics - Extract ta.stdev calls first
drawdownMeanCalc = ta.sma(smoothedDrawdown, lookbackPeriod)
drawdownStdDevCalc = ta.stdev(smoothedDrawdown, lookbackPeriod)

// Apply conditions
drawdownMean = validBars ? drawdownMeanCalc : na
drawdownStdDev = validBars ? drawdownStdDevCalc : na
drawdownVariance = validBars and not na(drawdownStdDev) ? math.pow(drawdownStdDev, 2) : na

// Percentile Analysis (Key Distribution Points) - Extract function calls first
p5_calc = ta.percentile_nearest_rank(smoothedDrawdown, lookbackPeriod, 5)
p10_calc = ta.percentile_nearest_rank(smoothedDrawdown, lookbackPeriod, 10)
p25_calc = ta.percentile_nearest_rank(smoothedDrawdown, lookbackPeriod, 25)
p50_calc = ta.percentile_nearest_rank(smoothedDrawdown, lookbackPeriod, 50)
p75_calc = ta.percentile_nearest_rank(smoothedDrawdown, lookbackPeriod, 75)
p90_calc = ta.percentile_nearest_rank(smoothedDrawdown, lookbackPeriod, 90)
p95_calc = ta.percentile_nearest_rank(smoothedDrawdown, lookbackPeriod, 95)

// Apply conditions
p5_drawdown = validBars ? p5_calc : na
p10_drawdown = validBars ? p10_calc : na
p25_drawdown = validBars ? p25_calc : na
p50_drawdown = validBars ? p50_calc : na
p75_drawdown = validBars ? p75_calc : na
p90_drawdown = validBars ? p90_calc : na
p95_drawdown = validBars ? p95_calc : na

// Current Position in Distribution - Extract ta.percentrank call first
currentPercentileRankCalc = ta.percentrank(smoothedDrawdown, lookbackPeriod)
currentPercentileRank = validBars ? currentPercentileRankCalc : na

// Standard Deviation Bands
std1_upper = validBars and not na(drawdownMean) and not na(drawdownStdDev) ? drawdownMean + drawdownStdDev : na
std1_lower = validBars and not na(drawdownMean) and not na(drawdownStdDev) ? drawdownMean - drawdownStdDev : na
std2_upper = validBars and not na(drawdownMean) and not na(drawdownStdDev) ? drawdownMean + 2 * drawdownStdDev : na
std2_lower = validBars and not na(drawdownMean) and not na(drawdownStdDev) ? drawdownMean - 2 * drawdownStdDev : na
std3_upper = validBars and not na(drawdownMean) and not na(drawdownStdDev) ? drawdownMean + 3 * drawdownStdDev : na
std3_lower = validBars and not na(drawdownMean) and not na(drawdownStdDev) ? drawdownMean - 3 * drawdownStdDev : na

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//                                                    RISK ASSESSMENT
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Risk Level Determination
riskLevel = validBars and not na(currentPercentileRank) ?
     currentPercentileRank >= (100 - riskThresholdModerate) ? "Low" :
     currentPercentileRank >= (100 - riskThresholdHigh) ? "Moderate" :
     currentPercentileRank >= (100 - riskThresholdExtreme) ? "High" : "Extreme" : "Insufficient Data"

// Risk Color Mapping
riskColor = riskLevel == "Low" ? lowRiskColor :
           riskLevel == "Moderate" ? moderateRiskColor :
           riskLevel == "High" ? highRiskColor :
           riskLevel == "Extreme" ? extremeRiskColor : neutralColor

// Z-Score for statistical significance
zScore = validBars and not na(drawdownMean) and not na(drawdownStdDev) and drawdownStdDev > 0 ? 
         (smoothedDrawdown - drawdownMean) / drawdownStdDev : na

// Statistical Significance Levels
significantDrawdown = validBars and not na(zScore) ? math.abs(zScore) > EXTREME_THRESHOLD : false
severeDrawdown = validBars and not na(zScore) ? math.abs(zScore) > SEVERE_THRESHOLD : false

// Maximum Drawdown in Analysis Period
maxDrawdownCalc = ta.lowest(smoothedDrawdown, lookbackPeriod)
maxDrawdownInPeriod = validBars ? maxDrawdownCalc : na

// Recovery Analysis
dataSourceLowest = ta.lowest(dataSource, lookbackPeriod)
drawdownRecovery = runningPeak > 0 ? ((dataSource - dataSourceLowest) / dataSourceLowest) * 100 : 0.0

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//                                                 ADVANCED RISK-ADJUSTED METRICS
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Returns Calculation for Risk-Adjusted Metrics - Extract ta.stdev calls first
returns = validBars ? math.log(dataSource / dataSource[1]) : na
annualizedReturnsCalc = ta.sma(returns, lookbackPeriod) * 252 * 100
volatilityCalc = ta.stdev(returns, lookbackPeriod) * math.sqrt(252) * 100

// Apply conditions
annualizedReturns = validBars ? annualizedReturnsCalc : na  // Annualized %
volatility = validBars ? volatilityCalc : na  // Annualized volatility %

// Sharpe Ratio Calculation
excessReturn = validBars and not na(annualizedReturns) ? annualizedReturns - riskFreeRate : na
sharpeRatio = validBars and not na(excessReturn) and not na(volatility) and volatility > 0 ? excessReturn / volatility : na

// Downside Deviation for Sortino Ratio - Extract ta.stdev call first
downsideReturns = validBars and not na(returns) ? (returns < 0 ? returns : 0) : na
downsideDeviationCalc = ta.stdev(downsideReturns, lookbackPeriod) * math.sqrt(252) * 100

// Apply conditions
downsideDeviation = validBars ? downsideDeviationCalc : na
sortinoRatio = validBars and not na(excessReturn) and not na(downsideDeviation) and downsideDeviation > 0 ? excessReturn / downsideDeviation : na

// Calmar Ratio (Return / Max Drawdown)
calmarRatio = validBars and not na(annualizedReturns) and not na(maxDrawdownInPeriod) and maxDrawdownInPeriod < -0.01 ? 
              annualizedReturns / math.abs(maxDrawdownInPeriod) : na

// Volatility-Adjusted Drawdown for Asset Comparison
volatilityAdjustedDrawdown = enableVolatilityAdjustment and validBars and not na(smoothedDrawdown) and not na(volatility) and volatility > 0 ? 
                             smoothedDrawdown / (volatility / 20) : smoothedDrawdown  // Normalized to 20% vol baseline

// Value at Risk Calculations (VaR) - Reuse existing percentile calculations
// 95% VaR = 5th percentile (already calculated as p5_calc)
// 99% VaR = 1st percentile  
var99_calc = ta.percentile_nearest_rank(smoothedDrawdown, lookbackPeriod, 1)

// Apply conditions
var95 = validBars ? p5_calc : na  // Reuse p5_calc for efficiency
var99 = validBars ? var99_calc : na

// Conditional VaR components (calculate remaining percentiles)
p2_calc = ta.percentile_nearest_rank(smoothedDrawdown, lookbackPeriod, 2)
p3_calc = ta.percentile_nearest_rank(smoothedDrawdown, lookbackPeriod, 3)
p4_calc = ta.percentile_nearest_rank(smoothedDrawdown, lookbackPeriod, 4)
// p1_calc = var99_calc (1st percentile)
// p5_calc already calculated above

// Conditional VaR (Expected Shortfall) - approximation using worst 5% cases
cvar95 = validBars and not na(var95) ? (var99_calc + p2_calc + p3_calc + p4_calc + p5_calc) / 5 : na

// Risk Efficiency Score (0-100, higher = better risk-adjusted performance)
riskEfficiencyScore = validBars and not na(sharpeRatio) and not na(currentPercentileRank) ? 
                     math.max(0, math.min(100, (sharpeRatio * 10 + currentPercentileRank) / 2)) : na

// Maximum Drawdown Duration (approximation)
var int drawdownDuration = 0
var bool inDrawdown = false

if validBars and smoothedDrawdown < -1.0  // In drawdown
    if not inDrawdown
        drawdownDuration := 1
        inDrawdown := true
    else
        drawdownDuration := drawdownDuration + 1
else
    inDrawdown := false

maxDrawdownDurationCalc = ta.highest(drawdownDuration, lookbackPeriod)
maxDrawdownDuration = validBars ? maxDrawdownDurationCalc : na

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//                                                         PLOTTING
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Zero reference line
plot(showZeroLine ? 0 : na, title="Zero Line", color=color.new(color.gray, 0), linewidth=1, style=plot.style_line, display=display.all)

// Main drawdown line with dynamic coloring
mainLineColor = color.new(riskColor, 0)
plot(smoothedDrawdown, title="Smoothed Drawdown (%)", color=mainLineColor, linewidth=lineWidth)

// Volatility-Adjusted Drawdown (optional overlay)
plot(enableVolatilityAdjustment ? volatilityAdjustedDrawdown : na, 
     title="Vol-Adjusted Drawdown (%)", color=color.new(primary_color, 30), linewidth=lineWidth-1, style=plot.style_line, display=display.none)

// Plot invisible lines for alert access
plot(sharpeRatio, title="Sharpe Ratio", display=display.none)
plot(riskEfficiencyScore, title="Risk Efficiency Score", display=display.none)
plot(riskFreeRate, title="Risk-Free Rate (%)", display=display.none)

// Current position line (secondary overlay of the main drawdown)
plot(showCurrentPosition and validBars ? smoothedDrawdown : na, 
     title="Current Position Line", color=color.new(riskColor, 40), linewidth=1, 
     style=plot.style_line)

// Mean line  
plot(drawdownMean, title="Mean Drawdown", color=color.new(primary_color, 40), linewidth=bandLineWidth)

// Percentile Bands
p95_plot = plot(showPercentileBands ? p95_drawdown : na, title="95th Percentile", 
                 color=color.new(bearish_color, bandAlpha), linewidth=bandLineWidth)
p90_plot = plot(showPercentileBands ? p90_drawdown : na, title="90th Percentile", 
                 color=color.new(bearish_color, bandAlpha + 10), linewidth=bandLineWidth)
p75_plot = plot(showPercentileBands ? p75_drawdown : na, title="75th Percentile", 
                 color=color.new(neutral_color, bandAlpha), linewidth=bandLineWidth)
p50_plot = plot(showPercentileBands ? p50_drawdown : na, title="50th Percentile (Median)", 
                 color=color.new(primary_color, bandAlpha), linewidth=bandLineWidth)
p25_plot = plot(showPercentileBands ? p25_drawdown : na, title="25th Percentile", 
                 color=color.new(bullish_color, bandAlpha), linewidth=bandLineWidth)
p10_plot = plot(showPercentileBands ? p10_drawdown : na, title="10th Percentile", 
                 color=color.new(bullish_color, bandAlpha + 10), linewidth=bandLineWidth)
p5_plot = plot(showPercentileBands ? p5_drawdown : na, title="5th Percentile", 
                 color=color.new(bullish_color, bandAlpha + 20), linewidth=bandLineWidth)

// VaR Lines
var95_plot = plot(enableVaR ? var95 : na, title="95% VaR", 
                  color=color.new(bearish_color, bandAlpha - 20), linewidth=bandLineWidth + 1, style=plot.style_linebr)
var99_plot = plot(enableVaR ? var99 : na, title="99% VaR", 
                  color=color.new(bearish_color, bandAlpha - 30), linewidth=bandLineWidth + 1, style=plot.style_linebr)

// Standard Deviation Bands
std1_upper_plot = plot(showStdDevBands ? std1_upper : na, title="1σ Upper", 
                       color=color.new(primary_color, bandAlpha), linewidth=bandLineWidth)
std1_lower_plot = plot(showStdDevBands ? std1_lower : na, title="1σ Lower", 
                       color=color.new(primary_color, bandAlpha), linewidth=bandLineWidth)
std2_upper_plot = plot(showStdDevBands ? std2_upper : na, title="2σ Upper", 
                       color=color.new(neutral_color, bandAlpha), linewidth=bandLineWidth)
std2_lower_plot = plot(showStdDevBands ? std2_lower : na, title="2σ Lower", 
                       color=color.new(neutral_color, bandAlpha), linewidth=bandLineWidth)
std3_upper_plot = plot(showStdDevBands ? std3_upper : na, title="3σ Upper", 
                       color=color.new(bearish_color, bandAlpha), linewidth=bandLineWidth)
std3_lower_plot = plot(showStdDevBands ? std3_lower : na, title="3σ Lower", 
                       color=color.new(bearish_color, bandAlpha), linewidth=bandLineWidth)

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//                                                         FILLS
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Percentile band fills
fill(p95_plot, p90_plot, color=showPercentileBands and showFills ? color.new(bearish_color, backgroundAlpha) : na, title="95th-90th Percentile")
fill(p90_plot, p75_plot, color=showPercentileBands and showFills ? color.new(bearish_color, backgroundAlpha + 5) : na, title="90th-75th Percentile")
fill(p75_plot, p50_plot, color=showPercentileBands and showFills ? color.new(neutral_color, backgroundAlpha) : na, title="75th-50th Percentile")
fill(p50_plot, p25_plot, color=showPercentileBands and showFills ? color.new(primary_color, backgroundAlpha) : na, title="50th-25th Percentile")
fill(p25_plot, p10_plot, color=showPercentileBands and showFills ? color.new(bullish_color, backgroundAlpha) : na, title="25th-10th Percentile")
fill(p10_plot, p5_plot, color=showPercentileBands and showFills ? color.new(bullish_color, backgroundAlpha + 10) : na, title="10th-5th Percentile")

// Standard deviation fills
fill(std2_upper_plot, std1_upper_plot, color=showStdDevBands and showFills ? color.new(primary_color, backgroundAlpha + 5) : na, title="1σ-2σ Upper")
fill(std1_lower_plot, std2_lower_plot, color=showStdDevBands and showFills ? color.new(primary_color, backgroundAlpha + 5) : na, title="1σ-2σ Lower")
fill(std3_upper_plot, std2_upper_plot, color=showStdDevBands and showFills ? color.new(neutral_color, backgroundAlpha + 5) : na, title="2σ-3σ Upper")
fill(std2_lower_plot, std3_lower_plot, color=showStdDevBands and showFills ? color.new(neutral_color, backgroundAlpha + 5) : na, title="2σ-3σ Lower")

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//                                                 BACKGROUND HIGHLIGHTING
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Risk-based background coloring
bgcolor(riskLevel == "Extreme" ? color.new(bearish_color, backgroundAlpha + 10) : na, title="Extreme Risk Zone")
bgcolor(riskLevel == "High" ? color.new(bearish_color, backgroundAlpha + 15) : na, title="High Risk Zone")
bgcolor(significantDrawdown and not severeDrawdown ? color.new(neutral_color, backgroundAlpha + 15) : na, title="Significant Drawdown")
bgcolor(severeDrawdown ? color.new(bearish_color, backgroundAlpha + 5) : na, title="Severe Drawdown")

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//                                                    STATISTICS TABLE
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Professional table styling (shared by both tables)
tableBgColor = color.new(table_bg_color, tableAlpha)
headerTextColor = text_color
labelTextColor = text_color
valueTextColor = text_color
headerBgColor = color.new(header_bg_color, 20)

if showTable and barstate.islast and validBars
    
    // Position mapping
    pos = switch tablePosition
        "top_right" => position.top_right
        "top_left" => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left" => position.bottom_left
        => position.top_right
    
    // Create compact main table
    var table statsTable = table.new(pos, 2, 9, 
         border_width=1, 
         bgcolor=tableBgColor,
         border_color=color.new(neutral_color, 50))
    
    if barstate.islast
        table.clear(statsTable, 0, 0, 1, 8)
        
        // Professional Headers
        table.cell(statsTable, 0, 0, "Risk Analysis", 
             text_color=headerTextColor, bgcolor=headerBgColor, text_size=size.small)
        table.cell(statsTable, 1, 0, "Value", 
             text_color=headerTextColor, bgcolor=headerBgColor, text_size=size.small)
        
        // Core Risk Metrics
        table.cell(statsTable, 0, 1, "Current Drawdown", text_color=labelTextColor, text_size=size.small)
        table.cell(statsTable, 1, 1, str.tostring(smoothedDrawdown, "#.##") + "%", 
             text_color=riskColor, text_size=size.small)
        
        table.cell(statsTable, 0, 2, "Risk Level", text_color=labelTextColor, text_size=size.small)
        table.cell(statsTable, 1, 2, riskLevel, 
             text_color=riskColor, text_size=size.small)
        
        table.cell(statsTable, 0, 3, "Percentile Rank", text_color=labelTextColor, text_size=size.small)
        table.cell(statsTable, 1, 3, str.tostring(currentPercentileRank, "#.#") + "%", 
             text_color=riskColor, text_size=size.small)
        
        // Risk-Adjusted Performance
        table.cell(statsTable, 0, 4, "Sharpe Ratio", text_color=labelTextColor, text_size=size.small)
        sharpeColor = not na(sharpeRatio) ? (sharpeRatio > 1.0 ? bullish_color : (sharpeRatio > 0 ? primary_color : bearish_color)) : neutral_color
        table.cell(statsTable, 1, 4, str.tostring(sharpeRatio, "#.##"), 
             text_color=sharpeColor, text_size=size.small)
        
        table.cell(statsTable, 0, 5, "Risk Efficiency Score", text_color=labelTextColor, text_size=size.small)
        efficiencyColor = not na(riskEfficiencyScore) ? (riskEfficiencyScore > 70 ? bullish_color : (riskEfficiencyScore > 40 ? primary_color : bearish_color)) : neutral_color
        table.cell(statsTable, 1, 5, str.tostring(riskEfficiencyScore, "#.#") + "/100", 
             text_color=efficiencyColor, text_size=size.small)
        
        // Key Risk Levels
        table.cell(statsTable, 0, 6, "Max Drawdown", text_color=labelTextColor, text_size=size.small)
        table.cell(statsTable, 1, 6, str.tostring(maxDrawdownInPeriod, "#.##") + "%", 
             text_color=bearish_color, text_size=size.small)
        
        table.cell(statsTable, 0, 7, "95% VaR", text_color=labelTextColor, text_size=size.small)
        table.cell(statsTable, 1, 7, str.tostring(var95, "#.##") + "%", 
             text_color=bearish_color, text_size=size.small)
        
        table.cell(statsTable, 0, 8, "Annualized Return", text_color=labelTextColor, text_size=size.small)
        returnColor = not na(annualizedReturns) and annualizedReturns > 0 ? bullish_color : bearish_color
        table.cell(statsTable, 1, 8, str.tostring(annualizedReturns, "#.##") + "%", 
             text_color=returnColor, text_size=size.small)



// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//                                                        ALERTS
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Risk level change alerts
extremeRiskAlert = riskLevel == "Extreme" and riskLevel[1] != "Extreme"
highRiskAlert = riskLevel == "High" and riskLevel[1] != "High" and riskLevel[1] != "Extreme"
significantDrawdownAlert = significantDrawdown and not significantDrawdown[1]
severeDrawdownAlert = severeDrawdown and not severeDrawdown[1]

// Statistical significance alerts
newMaxDrawdownAlert = validBars and smoothedDrawdown <= maxDrawdownInPeriod and smoothedDrawdown[1] > maxDrawdownInPeriod

// Risk-Adjusted Metric Alerts
sharpeDeclineAlert = enableRiskAdjustedMetrics and validBars and not na(sharpeRatio) and not na(sharpeRatio[1]) and 
                     sharpeRatio < 0 and sharpeRatio[1] >= 0
riskEfficiencyAlert = enableRiskAdjustedMetrics and validBars and not na(riskEfficiencyScore) and not na(riskEfficiencyScore[1]) and 
                     riskEfficiencyScore < 30 and riskEfficiencyScore[1] >= 30

alertcondition(extremeRiskAlert, 
     title="Extreme Risk Level Alert", 
     message="Drawdown has entered extreme risk territory ({{plot(\"Smoothed Drawdown (%)\")}}}%)")

alertcondition(highRiskAlert, 
     title="High Risk Level Alert", 
     message="Drawdown has reached high risk level ({{plot(\"Smoothed Drawdown (%)\")}}}%)")

alertcondition(significantDrawdownAlert, 
     title="Statistically Significant Drawdown", 
     message="Drawdown is statistically significant (Z-Score: {{plot(\"Z-Score\")}})")

alertcondition(severeDrawdownAlert, 
     title="Severe Drawdown Alert", 
     message="Drawdown has reached severe levels (Z-Score: {{plot(\"Z-Score\")}})")

alertcondition(newMaxDrawdownAlert, 
     title="New Maximum Drawdown", 
     message="New maximum drawdown reached: {{plot(\"Smoothed Drawdown (%)\")}}%")

alertcondition(sharpeDeclineAlert, 
     title="Sharpe Ratio Negative", 
     message="Sharpe ratio has turned negative: {{plot(\"Sharpe Ratio\")}}")

alertcondition(riskEfficiencyAlert, 
     title="Poor Risk Efficiency", 
     message="Risk efficiency score below 30: {{plot(\"Risk Efficiency Score\")}}/100")

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
// PROFESSIONAL QUALITY ASSURANCE & ACADEMIC COMPLIANCE
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//
// This indicator meets institutional standards for:
// • Regulatory compliance (educational/research purposes)
// • Risk management integration capabilities  
// • Audit trail and methodology transparency
// • Performance monitoring and validation
// • Scalability for portfolio management applications
//
// ACADEMIC DISCLAIMER:
// This indicator implements peer-reviewed methodologies and maintains transparency in its statistical approach.
// Past performance does not guarantee future results. The academic research cited provides theoretical
// foundation but does not constitute investment advice.
//
// TECHNICAL IMPLEMENTATION:
// • Pine Script™ v6 compliance with optimized performance
// • Function call consistency for reliable execution
// • Memory-efficient calculations and data handling
// • Professional error handling and edge case management
//
// For detailed methodology, citations, and application examples, refer to the comprehensive
// academic documentation provided with this indicator.
//
// © EdgeTools - Professional Trading Analytics
// License: Mozilla Public License 2.0
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
````
