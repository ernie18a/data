<!-- tradingview-pine-id: PUB;b8acef574a45480586f38032bcba20f5 -->
<!-- tradingviewscripts-format: 1 -->
# Bear Market Probability Model

Source: https://www.tradingview.com/script/8jAHmKXS-Bear-Market-Probability-Model/

## Description

# Bear Market Probability Model: A Multi-Factor Risk Assessment Framework

The Bear Market Probability Model represents a comprehensive quantitative framework for assessing systemic market risk through the integration of 13 distinct risk factors across four analytical categories: macroeconomic indicators, technical analysis factors, market sentiment measures, and market breadth metrics. This indicator synthesizes established financial research methodologies to provide real-time probabilistic assessments of impending bear market conditions, offering institutional-grade risk management capabilities to retail and professional traders alike.

## Theoretical Foundation

### Historical Context of Bear Market Prediction

Bear market prediction has been a central focus of financial research since the seminal work of Dow (1901) and the subsequent development of technical analysis theory. The challenge of predicting market downturns gained renewed academic attention following the market crashes of 1929, 1987, 2000, and 2008, leading to the development of sophisticated multi-factor models.

Fama and French (1989) demonstrated that certain financial variables possess predictive power for stock returns, particularly during market stress periods. Their three-factor model laid the groundwork for multi-dimensional risk assessment, which this indicator extends through the incorporation of real-time market microstructure data.

### Methodological Framework

The model employs a weighted composite scoring methodology based on the theoretical framework established by Campbell and Shiller (1998) for market valuation assessment, extended through the incorporation of high-frequency sentiment and technical indicators as proposed by Baker and Wurgler (2006) in their seminal work on investor sentiment.

The mathematical foundation follows the general form:

Bear Market Probability = Σ(Wi × Ci) / ΣWi × 100

Where:
- Wi = Category weight (i = 1,2,3,4)
- Ci = Normalized category score
- Categories: Macroeconomic, Technical, Sentiment, Breadth

## Component Analysis

### 1. Macroeconomic Risk Factors

#### Yield Curve Analysis
The inclusion of yield curve inversion as a primary predictor follows extensive research by Estrella and Mishkin (1998), who demonstrated that the term spread between 3-month and 10-year Treasury securities has historically preceded all major recessions since 1969. The model incorporates both the 2Y-10Y and 3M-10Y spreads to capture different aspects of monetary policy expectations.

Implementation:
- 2Y-10Y Spread: Captures market expectations of monetary policy trajectory
- 3M-10Y Spread: Traditional recession predictor with 12-18 month lead time

Scientific Basis: Harvey (1988) and subsequent research by Ang, Piazzesi, and Wei (2006) established the theoretical foundation linking yield curve inversions to economic contractions through the expectations hypothesis of the term structure.

#### Credit Risk Premium Assessment
High-yield credit spreads serve as a real-time gauge of systemic risk, following the methodology established by Gilchrist and Zakrajšek (2012) in their excess bond premium research. The model incorporates the ICE BofA High Yield Master II Option-Adjusted Spread as a proxy for credit market stress.

Threshold Calibration:
- Normal conditions: < 350 basis points
- Elevated risk: 350-500 basis points  
- Severe stress: > 500 basis points

#### Currency and Commodity Stress Indicators
The US Dollar Index (DXY) momentum serves as a risk-off indicator, while the Gold-to-Oil ratio captures commodity market stress dynamics. This approach follows the methodology of Akram (2009) and Beckmann, Berger, and Czudaj (2015) in analyzing commodity-currency relationships during market stress.

### 2. Technical Analysis Factors

#### Multi-Timeframe Moving Average Analysis
The technical component incorporates the well-established moving average convergence methodology, drawing from the work of Brock, Lakonishok, and LeBaron (1992), who provided empirical evidence for the profitability of technical trading rules.

Implementation:
- Price relative to 50-day and 200-day simple moving averages
- Moving average convergence/divergence analysis
- Multi-timeframe MACD assessment (daily and weekly)

#### Momentum and Volatility Analysis
The model integrates Relative Strength Index (RSI) analysis following Wilder's (1978) original methodology, combined with maximum drawdown analysis based on the work of Magdon-Ismail and Atiya (2004) on optimal drawdown measurement.

### 3. Market Sentiment Factors

#### Volatility Index Analysis  
The VIX component follows the established research of Whaley (2009) and subsequent work by Bekaert and Hoerova (2014) on VIX as a predictor of market stress. The model incorporates both absolute VIX levels and relative VIX spikes compared to the 20-day moving average.

Calibration:
- Low volatility: VIX < 20
- Elevated concern: VIX 20-25
- High fear: VIX > 25
- Panic conditions: VIX > 30

#### Put-Call Ratio Analysis
Options flow analysis through put-call ratios provides insight into sophisticated investor positioning, following the methodology established by Pan and Poteshman (2006) in their analysis of informed trading in options markets.

### 4. Market Breadth Factors

#### Advance-Decline Analysis
Market breadth assessment follows the classic work of Fosback (1976) and subsequent research by Brown and Cliff (2004) on market breadth as a predictor of future returns.

Components:
- Daily advance-decline ratio
- Advance-decline line momentum
- McClellan Oscillator (Ema19 - Ema39 of A-D difference)

#### New Highs-New Lows Analysis
The new highs-new lows ratio serves as a market leadership indicator, based on the research of Zweig (1986) and validated in academic literature by Zarowin (1990).

## Dynamic Threshold Methodology

The model incorporates adaptive thresholds based on rolling volatility and trend analysis, following the methodology established by Pagan and Sossounov (2003) for business cycle dating. This approach allows the model to adjust sensitivity based on prevailing market conditions.

Dynamic Threshold Calculation:
- Warning Level: Base threshold ± (Volatility × 1.0)
- Danger Level: Base threshold ± (Volatility × 1.5)
- Bounds: ±10-20 points from base threshold

## Professional Implementation

### Institutional Usage Patterns

Professional risk managers typically employ multi-factor bear market models in several contexts:

#### 1. Portfolio Risk Management
- Tactical Asset Allocation: Reducing equity exposure when probability exceeds 60-70%
- Hedging Strategies: Implementing protective puts or VIX calls when warning thresholds are breached
- Sector Rotation: Shifting from growth to defensive sectors during elevated risk periods

#### 2. Risk Budgeting
- Value-at-Risk Adjustment: Incorporating bear market probability into VaR calculations
- Stress Testing: Using probability levels to calibrate stress test scenarios
- Capital Requirements: Adjusting regulatory capital based on systemic risk assessment

#### 3. Client Communication
- Risk Reporting: Quantifying market risk for client presentations
- Investment Committee Decisions: Providing objective risk metrics for strategic decisions
- Performance Attribution: Explaining defensive positioning during market stress

### Implementation Framework

Professional traders typically implement such models through:

#### Signal Hierarchy:
1. Probability < 30%: Normal risk positioning
2. Probability 30-50%: Increased hedging, reduced leverage
3. Probability 50-70%: Defensive positioning, cash building
4. Probability > 70%: Maximum defensive posture, short exposure consideration

#### Risk Management Integration:
- Position Sizing: Inverse relationship between probability and position size
- Stop-Loss Adjustment: Tighter stops during elevated risk periods
- Correlation Monitoring: Increased attention to cross-asset correlations

## Strengths and Advantages

### 1. Comprehensive Coverage
The model's primary strength lies in its multi-dimensional approach, avoiding the single-factor bias that has historically plagued market timing models. By incorporating macroeconomic, technical, sentiment, and breadth factors, the model provides robust risk assessment across different market regimes.

### 2. Dynamic Adaptability
The adaptive threshold mechanism allows the model to adjust sensitivity based on prevailing volatility conditions, reducing false signals during low-volatility periods and maintaining sensitivity during high-volatility regimes.

### 3. Real-Time Processing
Unlike traditional academic models that rely on monthly or quarterly data, this indicator processes daily market data, providing timely risk assessment for active portfolio management.

### 4. Transparency and Interpretability
The component-based structure allows users to understand which factors are driving risk assessment, enabling informed decision-making about model signals.

### 5. Historical Validation
Each component has been validated in academic literature, providing theoretical foundation for the model's predictive power.

## Limitations and Weaknesses

### 1. Data Dependencies
The model's effectiveness depends heavily on the availability and quality of real-time economic data. Federal Reserve Economic Data (FRED) updates may have lags that could impact model responsiveness during rapidly evolving market conditions.

### 2. Regime Change Sensitivity
Like most quantitative models, the indicator may struggle during unprecedented market conditions or structural regime changes where historical relationships break down (Taleb, 2007).

### 3. False Signal Risk
Multi-factor models inherently face the challenge of balancing sensitivity with specificity. The model may generate false positive signals during normal market volatility periods.

### 4. Currency and Geographic Bias
The model focuses primarily on US market indicators, potentially limiting its effectiveness for global portfolio management or non-USD denominated assets.

### 5. Correlation Breakdown
During extreme market stress, correlations between risk factors may increase dramatically, reducing the model's diversification benefits (Forbes and Rigobon, 2002).

## References

Akram, Q. F. (2009). Commodity prices, interest rates and the dollar. Energy Economics, 31(6), 838-851.

Ang, A., Piazzesi, M., & Wei, M. (2006). What does the yield curve tell us about GDP growth? Journal of Econometrics, 131(1-2), 359-403.

Baker, M., & Wurgler, J. (2006). Investor sentiment and the cross‐section of stock returns. The Journal of Finance, 61(4), 1645-1680.

Baker, S. R., Bloom, N., & Davis, S. J. (2016). Measuring economic policy uncertainty. The Quarterly Journal of Economics, 131(4), 1593-1636.

Barber, B. M., & Odean, T. (2001). Boys will be boys: Gender, overconfidence, and common stock investment. The Quarterly Journal of Economics, 116(1), 261-292.

Beckmann, J., Berger, T., & Czudaj, R. (2015). Does gold act as a hedge or a safe haven for stocks? A smooth transition approach. Economic Modelling, 48, 16-24.

Bekaert, G., & Hoerova, M. (2014). The VIX, the variance premium and stock market volatility. Journal of Econometrics, 183(2), 181-192.

Brock, W., Lakonishok, J., & LeBaron, B. (1992). Simple technical trading rules and the stochastic properties of stock returns. The Journal of Finance, 47(5), 1731-1764.

Brown, G. W., & Cliff, M. T. (2004). Investor sentiment and the near-term stock market. Journal of Empirical Finance, 11(1), 1-27.

Campbell, J. Y., & Shiller, R. J. (1998). Valuation ratios and the long-run stock market outlook. The Journal of Portfolio Management, 24(2), 11-26.

Dow, C. H. (1901). Scientific stock speculation. The Magazine of Wall Street.

Estrella, A., & Mishkin, F. S. (1998). Predicting US recessions: Financial variables as leading indicators. Review of Economics and Statistics, 80(1), 45-61.

Fama, E. F., & French, K. R. (1989). Business conditions and expected returns on stocks and bonds. Journal of Financial Economics, 25(1), 23-49.

Forbes, K. J., & Rigobon, R. (2002). No contagion, only interdependence: measuring stock market comovements. The Journal of Finance, 57(5), 2223-2261.

Fosback, N. G. (1976). Stock market logic: A sophisticated approach to profits on Wall Street. The Institute for Econometric Research.

Gilchrist, S., & Zakrajšek, E. (2012). Credit spreads and business cycle fluctuations. American Economic Review, 102(4), 1692-1720.

Harvey, C. R. (1988). The real term structure and consumption growth. Journal of Financial Economics, 22(2), 305-333.

Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. Econometrica, 47(2), 263-291.

Magdon-Ismail, M., & Atiya, A. F. (2004). Maximum drawdown. Risk, 17(10), 99-102.

Nickerson, R. S. (1998). Confirmation bias: A ubiquitous phenomenon in many guises. Review of General Psychology, 2(2), 175-220.

Pagan, A. R., & Sossounov, K. A. (2003). A simple framework for analysing bull and bear markets. Journal of Applied Econometrics, 18(1), 23-46.

Pan, J., & Poteshman, A. M. (2006). The information in option volume for future stock prices. The Review of Financial Studies, 19(3), 871-908.

Taleb, N. N. (2007). The black swan: The impact of the highly improbable. Random House.

Whaley, R. E. (2009). Understanding the VIX. The Journal of Portfolio Management, 35(3), 98-105.

Wilder, J. W. (1978). New concepts in technical trading systems. Trend Research.

Zarowin, P. (1990). Size, seasonality, and stock market overreaction. Journal of Financial and Quantitative Analysis, 25(1), 113-125.

Zweig, M. E. (1986). Winning on Wall Street. Warner Books.

---

## Source Code

````pine
//@version=6
indicator("Bear Market Probability Model", shorttitle="BMPM", overlay=false, max_bars_back=500)

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
// ENHANCED BEAR MARKET PROBABILITY MODEL
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
//
// This indicator combines 13 different market risk factors across 4 categories to calculate
// the probability of an impending bear market. Based on historical market research and 
// proven risk management methodologies used by institutional investors.
//
// METHODOLOGY:
// • Macroeconomic Analysis: Yield curve inversions, credit spreads, currency strength
// • Technical Analysis: Moving averages, momentum, volatility patterns  
// • Market Sentiment: Fear indicators, positioning metrics
// • Market Breadth: Participation analysis, sector rotation signals
//
// CATEGORIES WEIGHTED:
// Each category contributes equally by default but can be adjusted based on market regime
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════

// COLOR SCHEME - TradingView Standard Colors
var color NEUTRAL_COLOR = #2196F3
var color BULL_COLOR = #4CAF50
var color BEAR_COLOR = #FF5252
var color POSITIVE_COLOR = #4CAF50
var color NEGATIVE_COLOR = #FF5252

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
// INPUT PARAMETERS
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Display Settings
show_table = input.bool(true, "Show Analysis Table", group="Display")
warning_threshold = input.int(40, "Warning Threshold (%)", minval=0, maxval=100, group="Thresholds")
danger_threshold = input.int(70, "Danger Threshold (%)", minval=0, maxval=100, group="Thresholds")
use_dynamic_thresholds = input.bool(true, "Use Dynamic Thresholds", group="Thresholds")

// Visual Effects
smoothing_length = input.int(3, "Line Smoothing", minval=1, maxval=10, group="Visual")
glow_intensity = input.float(0.7, "Glow Effect Intensity", minval=0.1, maxval=1.0, step=0.1, group="Visual")

// Category Weighting - Allows adaptation to different market regimes
macro_weight = input.float(1.0, "Macroeconomic Weight", minval=0.1, maxval=3.0, group="Category Weights")
technical_weight = input.float(1.0, "Technical Analysis Weight", minval=0.1, maxval=3.0, group="Category Weights")
sentiment_weight = input.float(1.0, "Market Sentiment Weight", minval=0.1, maxval=3.0, group="Category Weights")
breadth_weight = input.float(1.0, "Market Breadth Weight", minval=0.1, maxval=3.0, group="Category Weights")

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
// MACROECONOMIC RISK FACTORS
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Yield Curve Analysis - Historical bear market predictor
us_10y = request.security("FRED:DGS10", "D", close, lookahead=barmerge.lookahead_off)
us_2y = request.security("FRED:DGS2", "D", close, lookahead=barmerge.lookahead_off) 
us_3m = request.security("FRED:DGS3MO", "D", close, lookahead=barmerge.lookahead_off)

// Safe null checks and proper calculations
spread_2y10y = na(us_10y) or na(us_2y) ? 0 : us_10y - us_2y
spread_3m10y = na(us_10y) or na(us_3m) ? 0 : us_10y - us_3m
yield_inversion_count = (spread_2y10y < 0 ? 1 : 0) + (spread_3m10y < 0 ? 1 : 0)
yield_curve_score = yield_inversion_count / 2

// Credit Risk Premium - Corporate stress indicator  
high_yield_spread = request.security("FRED:BAMLH0A0HYM2", "D", close, lookahead=barmerge.lookahead_off)
credit_stress_score = na(high_yield_spread) ? 0 : (high_yield_spread > 500 ? 1 : (high_yield_spread > 350 ? 0.5 : 0))

// Dollar Strength - Risk-off currency flows
dxy = request.security("TVC:DXY", "D", close, lookahead=barmerge.lookahead_off)
dxy_ma50 = na(dxy) ? na : ta.sma(dxy, 50)
dollar_strength_score = na(dxy) or na(dxy_ma50) ? 0 : (dxy > dxy_ma50 * 1.05 ? 1 : 0)

// Commodity Stress - Gold vs Oil ratio as economic stress gauge
gold_price = request.security("TVC:GOLD", "D", close, lookahead=barmerge.lookahead_off)
oil_price = request.security("TVC:USOIL", "D", close, lookahead=barmerge.lookahead_off)
gold_oil_ratio = na(gold_price) or na(oil_price) or oil_price == 0 ? na : gold_price / oil_price
gold_oil_ma = na(gold_oil_ratio) ? na : ta.sma(gold_oil_ratio, 252)
commodity_stress_score = na(gold_oil_ratio) or na(gold_oil_ma) ? 0 : (gold_oil_ratio > gold_oil_ma * 1.2 ? 1 : 0)

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
// TECHNICAL ANALYSIS FACTORS
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Moving Average Analysis - Trend deterioration signals
sma_50 = ta.sma(close, 50)
sma_200 = ta.sma(close, 200)
price_below_200 = close < sma_200 ? 1 : 0
price_below_50 = close < sma_50 ? 1 : 0
ma_convergence = sma_50 < sma_200 ? 1 : 0
technical_ma_score = (price_below_200 + price_below_50 + ma_convergence) / 3

// Multi-Timeframe MACD - Momentum deterioration across timeframes
[macd_line, signal_line, _] = ta.macd(close, 12, 26, 9)
[macd_weekly, signal_weekly, _] = request.security(syminfo.tickerid, "W", ta.macd(close, 12, 26, 9))
macd_bearish_signals = (macd_line < signal_line ? 1 : 0) + (macd_weekly < signal_weekly ? 1 : 0)
momentum_score = macd_bearish_signals / 2

// RSI Strength Analysis - Market momentum weakness
rsi_14 = ta.rsi(close, 14)
rsi_weakness_score = rsi_14 < 50 ? 1 : 0

// Drawdown Analysis - Peak-to-trough deterioration
highest_close_252 = ta.highest(close, 252)
current_drawdown = 100 * (close - highest_close_252) / highest_close_252
drawdown_score = current_drawdown < -20 ? 1 : (current_drawdown < -15 ? 0.5 : 0)

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
// MARKET SENTIMENT FACTORS
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════

// VIX Fear Analysis - Volatility regime assessment
vix = request.security("CBOE:VIX", "D", close, lookahead=barmerge.lookahead_off)
vix_ma20 = na(vix) ? na : ta.sma(vix, 20)
vix_elevated_score = na(vix) ? 0 : (vix > 25 ? 1 : (vix > 20 ? 0.5 : 0))
vix_spike_score = na(vix) or na(vix_ma20) ? 0 : (vix > vix_ma20 * 1.5 ? 1 : 0)
volatility_sentiment_score = (vix_elevated_score + vix_spike_score) / 2

// Put-Call Ratio - Options positioning as sentiment gauge
put_call_ratio = request.security("INDEX:PCP", "D", close, lookahead=barmerge.lookahead_off)
put_call_score = na(put_call_ratio) ? 0 : (put_call_ratio > 1.2 ? 1 : (put_call_ratio > 1.0 ? 0.5 : 0))

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
// MARKET BREADTH FACTORS
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Advance-Decline Analysis - Market participation strength
advancing_issues = request.security("INDEX:ADVN", "D", close, lookahead=barmerge.lookahead_off)
declining_issues = request.security("INDEX:DECN", "D", close, lookahead=barmerge.lookahead_off)
total_issues = na(advancing_issues) or na(declining_issues) ? na : advancing_issues + declining_issues
advance_decline_ratio = na(total_issues) or total_issues == 0 ? 0.5 : advancing_issues / total_issues
advance_decline_diff = na(advancing_issues) or na(declining_issues) ? 0 : advancing_issues - declining_issues
advance_decline_line = ta.cum(advance_decline_diff)
ad_line_ma20 = ta.sma(advance_decline_line, 20)
ad_line_ma50 = ta.sma(advance_decline_line, 50)
ad_line_weakness = na(ad_line_ma20) or na(ad_line_ma50) ? 0 : (ad_line_ma20 < ad_line_ma50 ? 1 : 0)
breadth_weakness_score = advance_decline_ratio < 0.4 ? 1 : (advance_decline_ratio < 0.45 ? 0.5 : 0)

// New Highs vs New Lows - Leadership analysis
new_highs = request.security("INDEX:HIGN", "D", close, lookahead=barmerge.lookahead_off)
new_lows = request.security("INDEX:LOWN", "D", close, lookahead=barmerge.lookahead_off)
total_hl = na(new_highs) or na(new_lows) ? na : new_highs + new_lows
nh_nl_ratio = na(total_hl) or total_hl == 0 ? 0.5 : new_highs / total_hl
new_high_low_score = nh_nl_ratio < 0.3 ? 1 : (nh_nl_ratio < 0.4 ? 0.5 : 0)

// McClellan Oscillator - Market breadth momentum
mcclellan_ema19 = na(advance_decline_diff) ? 0 : ta.ema(advance_decline_diff, 19)
mcclellan_ema39 = na(advance_decline_diff) ? 0 : ta.ema(advance_decline_diff, 39)
mcclellan_oscillator = mcclellan_ema19 - mcclellan_ema39
mcclellan_score = mcclellan_oscillator < -50 ? 1 : (mcclellan_oscillator < 0 ? 0.5 : 0)

market_breadth_score = (ad_line_weakness + breadth_weakness_score + new_high_low_score + mcclellan_score) / 4

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
// COMPOSITE SCORING AND PROBABILITY CALCULATION
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Calculate category components with proper validation
macro_component_count = 4 // yield_curve, credit_stress, dollar_strength, commodity_stress
macro_component_sum = yield_curve_score + credit_stress_score + dollar_strength_score + commodity_stress_score
macro_component = macro_component_sum / macro_component_count

technical_component_count = 4 // ma_score, momentum, rsi, drawdown  
technical_component_sum = technical_ma_score + momentum_score + rsi_weakness_score + drawdown_score
technical_component = technical_component_sum / technical_component_count

sentiment_component_count = 2 // vix, put_call
sentiment_component_sum = volatility_sentiment_score + put_call_score
sentiment_component = sentiment_component_sum / sentiment_component_count

breadth_component = market_breadth_score

// Validate all components are within [0,1] range
macro_component := math.max(0, math.min(1, macro_component))
technical_component := math.max(0, math.min(1, technical_component))
sentiment_component := math.max(0, math.min(1, sentiment_component))
breadth_component := math.max(0, math.min(1, breadth_component))

// Apply user-defined weightings for market regime adaptation
weighted_macro = macro_component * macro_weight
weighted_technical = technical_component * technical_weight
weighted_sentiment = sentiment_component * sentiment_weight
weighted_breadth = breadth_component * breadth_weight

total_weight = macro_weight + technical_weight + sentiment_weight + breadth_weight
bear_market_probability = total_weight > 0 ? 100 * (weighted_macro + weighted_technical + weighted_sentiment + weighted_breadth) / total_weight : 0

// Ensure probability is within valid range [0,100]
bear_market_probability := math.max(0, math.min(100, bear_market_probability))

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
// ADAPTIVE THRESHOLDS AND SMOOTHING
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Apply smoothing for noise reduction
smoothed_probability = ta.sma(bear_market_probability, smoothing_length)

// Dynamic threshold calculation based on historical volatility with safety checks
prob_volatility = ta.stdev(bear_market_probability, 50)
prob_sma = ta.sma(bear_market_probability, 20)

// Ensure we have valid values for dynamic calculations
valid_prob_volatility = na(prob_volatility) or prob_volatility < 0 ? 10 : prob_volatility
valid_prob_sma = na(prob_sma) or prob_sma < 0 ? 30 : prob_sma

dynamic_warning = use_dynamic_thresholds ? 
                 math.max(warning_threshold - 10, math.min(warning_threshold + 15, valid_prob_sma + valid_prob_volatility)) : 
                 warning_threshold

dynamic_danger = use_dynamic_thresholds ? 
                 math.max(danger_threshold - 10, math.min(danger_threshold + 20, valid_prob_sma + valid_prob_volatility * 1.5)) : 
                 danger_threshold

// Ensure thresholds are within valid range
dynamic_warning := math.max(0, math.min(100, dynamic_warning))
dynamic_danger := math.max(0, math.min(100, dynamic_danger))
// Ensure danger threshold is higher than warning threshold
dynamic_danger := math.max(dynamic_warning + 5, dynamic_danger)

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
// DYNAMIC VISUALIZATION
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Color calculation with smooth gradients
get_dynamic_color(value) =>
    if value >= dynamic_danger
        color.from_gradient(value, dynamic_danger, 100, BEAR_COLOR, color.new(BEAR_COLOR, 50))
    else if value >= dynamic_warning
        color.from_gradient(value, dynamic_warning, dynamic_danger, NEUTRAL_COLOR, BEAR_COLOR)
    else
        color.from_gradient(value, 0, dynamic_warning, BULL_COLOR, NEUTRAL_COLOR)

main_color = get_dynamic_color(smoothed_probability)
glow_color = color.new(main_color, math.round(80 * glow_intensity))

// Signal detection for alerts
danger_signal = smoothed_probability >= dynamic_danger and smoothed_probability[1] < dynamic_danger
warning_signal = smoothed_probability >= dynamic_warning and smoothed_probability[1] < dynamic_warning

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
// PLOT OUTPUTS
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Main probability line with glow effect
plot(smoothed_probability, title="Bear Market Probability", color=main_color, linewidth=3)
plot(smoothed_probability, title="Glow Layer 1", color=color.new(main_color, 70), linewidth=5, display=display.none)
plot(smoothed_probability, title="Glow Layer 2", color=color.new(main_color, 85), linewidth=7, display=display.none)
plot(smoothed_probability, title="Glow Layer 3", color=color.new(main_color, 95), linewidth=9, display=display.none)

// Threshold lines
plot(use_dynamic_thresholds ? dynamic_warning : na, title="Dynamic Warning", color=color.new(NEUTRAL_COLOR, 30), linewidth=2)
plot(use_dynamic_thresholds ? dynamic_danger : na, title="Dynamic Danger", color=color.new(BEAR_COLOR, 30), linewidth=2)
plot(not use_dynamic_thresholds ? warning_threshold : na, title="Static Warning", color=NEUTRAL_COLOR, linewidth=1)
plot(not use_dynamic_thresholds ? danger_threshold : na, title="Static Danger", color=BEAR_COLOR, linewidth=1)

// Background coloring for risk zones
var float bg_intensity = 0.0
bg_color = color(na)

if smoothed_probability >= dynamic_danger
    bg_intensity := math.min(85.0, 65.0 + (smoothed_probability - dynamic_danger) * 2.0)
    bg_color := color.new(BEAR_COLOR, math.round(bg_intensity))
else if smoothed_probability >= dynamic_warning
    bg_intensity := math.min(85.0, 65.0 + (smoothed_probability - dynamic_warning) * 2.0)
    bg_color := color.new(NEUTRAL_COLOR, math.round(bg_intensity))

bgcolor(bg_color)

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
// COMPREHENSIVE ANALYSIS TABLE
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════

if show_table
    var table analysis_table = table.new(position.top_right, 3, 18, border_width=1, 
                                         bgcolor=#000000, border_color=#333333)
    
    if bar_index % 10 == 0
        // Main status header
        risk_status = smoothed_probability >= dynamic_danger ? "DANGER" : 
                     smoothed_probability >= dynamic_warning ? "WARNING" : "NORMAL"
        
        table.cell(analysis_table, 0, 0, "BEAR MARKET PROBABILITY MODEL", 
                  bgcolor=#000000, text_color=#FFFFFF, text_size=size.small)
        table.cell(analysis_table, 1, 0, str.tostring(smoothed_probability, "##.#") + "%", 
                  bgcolor=#000000, text_color=main_color, text_size=size.small)
        table.cell(analysis_table, 2, 0, risk_status, 
                  bgcolor=#000000, text_color=main_color, text_size=size.small)
        
        // Category analysis
        table.cell(analysis_table, 0, 1, "CATEGORY", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 1, "SCORE", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 2, 1, "STATUS", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        
        // Macroeconomic
        table.cell(analysis_table, 0, 2, "Macroeconomic", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 2, str.tostring(macro_component * 100, "##") + "%", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        macro_status = macro_component > 0.5 ? "RISK" : "STABLE"
        macro_color = macro_component > 0.5 ? NEGATIVE_COLOR : POSITIVE_COLOR
        table.cell(analysis_table, 2, 2, macro_status, bgcolor=#000000, text_color=macro_color, text_size=size.tiny)
        
        // Technical Analysis
        table.cell(analysis_table, 0, 3, "Technical Analysis", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 3, str.tostring(technical_component * 100, "##") + "%", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        tech_status = technical_component > 0.6 ? "BEARISH" : technical_component > 0.3 ? "NEUTRAL" : "BULLISH"
        tech_color = technical_component > 0.6 ? BEAR_COLOR : technical_component > 0.3 ? NEUTRAL_COLOR : BULL_COLOR
        table.cell(analysis_table, 2, 3, tech_status, bgcolor=#000000, text_color=tech_color, text_size=size.tiny)
        
        // Market Sentiment
        table.cell(analysis_table, 0, 4, "Market Sentiment", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 4, str.tostring(sentiment_component * 100, "##") + "%", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        sentiment_status = sentiment_component > 0.6 ? "FEARFUL" : sentiment_component > 0.3 ? "CAUTIOUS" : "COMPLACENT"
        sentiment_color = sentiment_component > 0.6 ? BEAR_COLOR : sentiment_component > 0.3 ? NEUTRAL_COLOR : BULL_COLOR
        table.cell(analysis_table, 2, 4, sentiment_status, bgcolor=#000000, text_color=sentiment_color, text_size=size.tiny)
        
        // Market Breadth
        table.cell(analysis_table, 0, 5, "Market Breadth", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 5, str.tostring(breadth_component * 100, "##") + "%", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        breadth_status = breadth_component > 0.5 ? "DETERIORATING" : "HEALTHY"
        breadth_color = breadth_component > 0.5 ? NEGATIVE_COLOR : POSITIVE_COLOR
        table.cell(analysis_table, 2, 5, breadth_status, bgcolor=#000000, text_color=breadth_color, text_size=size.tiny)
        
        // Separator
        table.cell(analysis_table, 0, 6, "", bgcolor=#000000, text_size=size.tiny)
        table.cell(analysis_table, 1, 6, "", bgcolor=#000000, text_size=size.tiny)
        table.cell(analysis_table, 2, 6, "", bgcolor=#000000, text_size=size.tiny)
        
        // Individual indicators
        table.cell(analysis_table, 0, 7, "INDICATOR", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 7, "VALUE", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 2, 7, "SIGNAL", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        
        // Key indicators display
        table.cell(analysis_table, 0, 8, "Yield Curve (2Y-10Y)", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 8, str.tostring(spread_2y10y, "#.##") + " bp", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        yield_signal_color = spread_2y10y < 0 ? NEGATIVE_COLOR : POSITIVE_COLOR
        table.cell(analysis_table, 2, 8, spread_2y10y < 0 ? "INVERTED" : "NORMAL", bgcolor=#000000, text_color=yield_signal_color, text_size=size.tiny)
        
        table.cell(analysis_table, 0, 9, "High Yield Spread", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 9, na(high_yield_spread) ? "N/A" : str.tostring(high_yield_spread, "###") + " bp", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        credit_signal_color = na(high_yield_spread) ? #FFFFFF : high_yield_spread > 500 ? NEGATIVE_COLOR : POSITIVE_COLOR
        table.cell(analysis_table, 2, 9, na(high_yield_spread) ? "N/A" : high_yield_spread > 500 ? "STRESSED" : "NORMAL", bgcolor=#000000, text_color=credit_signal_color, text_size=size.tiny)
        
        table.cell(analysis_table, 0, 10, "Price vs SMA(200)", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        price_vs_ma200 = (close - sma_200) / sma_200 * 100
        table.cell(analysis_table, 1, 10, str.tostring(price_vs_ma200, "#.#") + "%", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        ma_signal_color = close < sma_200 ? NEGATIVE_COLOR : POSITIVE_COLOR
        table.cell(analysis_table, 2, 10, close < sma_200 ? "BELOW" : "ABOVE", bgcolor=#000000, text_color=ma_signal_color, text_size=size.tiny)
        
        table.cell(analysis_table, 0, 11, "MACD Signal", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 11, str.tostring(macd_line, "#.##"), bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        macd_signal_color = macd_line < signal_line ? NEGATIVE_COLOR : POSITIVE_COLOR
        table.cell(analysis_table, 2, 11, macd_line < signal_line ? "BEARISH" : "BULLISH", bgcolor=#000000, text_color=macd_signal_color, text_size=size.tiny)
        
        table.cell(analysis_table, 0, 12, "Volatility Index", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 12, str.tostring(vix, "##.#"), bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        vix_signal_color = vix > 30 ? BEAR_COLOR : vix > 20 ? NEUTRAL_COLOR : BULL_COLOR
        table.cell(analysis_table, 2, 12, vix > 30 ? "HIGH" : vix > 20 ? "ELEVATED" : "LOW", bgcolor=#000000, text_color=vix_signal_color, text_size=size.tiny)
        
        table.cell(analysis_table, 0, 13, "Maximum Drawdown", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 13, str.tostring(current_drawdown, "##.#") + "%", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        dd_signal_color = current_drawdown < -20 ? BEAR_COLOR : current_drawdown < -10 ? NEUTRAL_COLOR : BULL_COLOR
        table.cell(analysis_table, 2, 13, current_drawdown < -20 ? "SEVERE" : current_drawdown < -10 ? "MODERATE" : "MINIMAL", bgcolor=#000000, text_color=dd_signal_color, text_size=size.tiny)
        
        table.cell(analysis_table, 0, 14, "Advance/Decline Ratio", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 14, str.tostring(advance_decline_ratio * 100, "##") + "%", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        ad_signal_color = advance_decline_ratio < 0.4 ? NEGATIVE_COLOR : POSITIVE_COLOR
        table.cell(analysis_table, 2, 14, advance_decline_ratio < 0.4 ? "WEAK" : "HEALTHY", bgcolor=#000000, text_color=ad_signal_color, text_size=size.tiny)
        
        table.cell(analysis_table, 0, 15, "McClellan Oscillator", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 15, str.tostring(mcclellan_oscillator, "###"), bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        mcc_signal_color = mcclellan_oscillator < -50 ? BEAR_COLOR : mcclellan_oscillator > 50 ? BULL_COLOR : NEUTRAL_COLOR
        table.cell(analysis_table, 2, 15, mcclellan_oscillator < -50 ? "BEARISH" : mcclellan_oscillator > 50 ? "BULLISH" : "NEUTRAL", bgcolor=#000000, text_color=mcc_signal_color, text_size=size.tiny)
        
        table.cell(analysis_table, 0, 16, "New Highs/Lows Ratio", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 16, str.tostring(nh_nl_ratio * 100, "##") + "%", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        nh_signal_color = nh_nl_ratio < 0.3 ? NEGATIVE_COLOR : POSITIVE_COLOR
        table.cell(analysis_table, 2, 16, nh_nl_ratio < 0.3 ? "DETERIORATING" : "IMPROVING", bgcolor=#000000, text_color=nh_signal_color, text_size=size.tiny)
        
        table.cell(analysis_table, 0, 17, "RSI (14-period)", bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        table.cell(analysis_table, 1, 17, str.tostring(rsi_14, "##.#"), bgcolor=#000000, text_color=#FFFFFF, text_size=size.tiny)
        rsi_signal_color = rsi_14 < 30 ? BULL_COLOR : rsi_14 > 70 ? BEAR_COLOR : NEUTRAL_COLOR
        table.cell(analysis_table, 2, 17, rsi_14 < 30 ? "OVERSOLD" : rsi_14 > 70 ? "OVERBOUGHT" : "NEUTRAL", bgcolor=#000000, text_color=rsi_signal_color, text_size=size.tiny)

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
// ALERT CONDITIONS
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(danger_signal, title="Bear Market Alert", 
               message="Bear Market Probability reached {{plot_0}}% - Critical Level!")
alertcondition(warning_signal, title="Bear Market Warning", 
               message="Bear Market Probability reached {{plot_0}}% - Warning Level!")

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
// IMPORTANT NOTE REGARDING EXTERNAL MARKET DATA
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
//
// KNOWN PINESCRIPT LIMITATION:
// Due to technical limitations in PineScript, some market breadth indicators
// (VIX, A/D Ratio, New Highs/Lows) may change slightly when the chart symbol is switched.
// This is a known issue with the request.security() function and does NOT affect
// the calculation logic of this indicator.
//
// The core calculations of the Bear Market Probability Model remain accurate and meaningful.
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════
````
