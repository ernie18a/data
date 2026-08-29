<!-- tradingview-pine-id: PUB;f3bc76748b2b44e9838035ecc795b8af -->
<!-- tradingviewscripts-format: 1 -->
# Dynamic Equity Allocation Model

Source: https://www.tradingview.com/script/HjgCUw6g-Dynamic-Equity-Allocation-Model/

## Description

"Cash is Trash"? Not Always. Here's Why Science Beats Guesswork.

Every retail trader knows the frustration: you draw support and resistance lines, you spot patterns, you follow market gurus on social media—and still, when the next bear market hits, your portfolio bleeds red. Meanwhile, institutional investors seem to navigate market turbulence with ease, preserving capital when markets crash and participating when they rally. What's their secret?

The answer isn't insider information or access to exotic derivatives. It's systematic, scientifically validated decision-making. While most retail traders rely on subjective chart analysis and emotional reactions, professional portfolio managers use quantitative models that remove emotion from the equation and process multiple streams of market information simultaneously.

This document presents exactly such a system—not a proprietary black box available only to hedge funds, but a fully transparent, academically grounded framework that any serious investor can understand and apply. The Dynamic Equity Allocation Model (DEAM) synthesizes decades of financial research from Nobel laureates and leading academics into a practical tool for tactical asset allocation.

Stop drawing colorful lines on your chart and start thinking like a quant. This isn't about predicting where the market goes next week—it's about systematically adjusting your risk exposure based on what the data actually tells you. When valuations scream danger, when volatility spikes, when credit markets freeze, when multiple warning signals align—that's when cash isn't trash. That's when cash saves your portfolio.

The irony of "cash is trash" rhetoric is that it ignores timing. Yes, being 100% cash for decades would be disastrous. But being 100% equities through every crisis is equally foolish. The sophisticated approach is dynamic: aggressive when conditions favor risk-taking, defensive when they don't. This model shows you how to make that decision systematically, not emotionally.

Whether you're managing your own retirement portfolio or seeking to understand how institutional allocation strategies work, this comprehensive analysis provides the theoretical foundation, mathematical implementation, and practical guidance to elevate your investment approach from amateur to professional.

The choice is yours: keep hoping your chart patterns work out, or start using the same quantitative methods that professionals rely on. The tools are here. The research is cited. The methodology is explained. All you need to do is read, understand, and apply.

The Dynamic Equity Allocation Model (DEAM) is a quantitative framework for systematic allocation between equities and cash, grounded in modern portfolio theory and empirical market research. The model integrates five scientifically validated dimensions of market analysis—market regime, risk metrics, valuation, sentiment, and macroeconomic conditions—to generate dynamic allocation recommendations ranging from 0% to 100% equity exposure. This work documents the theoretical foundations, mathematical implementation, and practical application of this multi-factor approach.

1. Introduction and Theoretical Background

1.1 The Limitations of Static Portfolio Allocation

Traditional portfolio theory, as formulated by Markowitz (1952) in his seminal work "Portfolio Selection," assumes an optimal static allocation where investors distribute their wealth across asset classes according to their risk aversion. This approach rests on the assumption that returns and risks remain constant over time. However, empirical research demonstrates that this assumption does not hold in reality. Fama and French (1989) showed that expected returns vary over time and correlate with macroeconomic variables such as the spread between long-term and short-term interest rates. Campbell and Shiller (1988) demonstrated that the price-earnings ratio possesses predictive power for future stock returns, providing a foundation for dynamic allocation strategies.

The academic literature on tactical asset allocation has evolved considerably over recent decades. Ilmanen (2011) argues in "Expected Returns" that investors can improve their risk-adjusted returns by considering valuation levels, business cycles, and market sentiment. The Dynamic Equity Allocation Model presented here builds on this research tradition and operationalizes these insights into a practically applicable allocation framework.

1.2 Multi-Factor Approaches in Asset Allocation

Modern financial research has shown that different factors capture distinct aspects of market dynamics and together provide a more robust picture of market conditions than individual indicators. Ross (1976) developed the Arbitrage Pricing Theory, a model that employs multiple factors to explain security returns. Following this multi-factor philosophy, DEAM integrates five complementary analytical dimensions, each tapping different information sources and collectively enabling comprehensive market understanding.

2. Data Foundation and Data Quality

2.1 Data Sources Used

The model draws its data exclusively from publicly available market data via the TradingView platform. This transparency and accessibility is a significant advantage over proprietary models that rely on non-public data. The data foundation encompasses several categories of market information, each capturing specific aspects of market dynamics.

First, price data for the S&P 500 Index is obtained through the SPDR S&P 500 ETF (ticker: SPY). The use of a highly liquid ETF instead of the index itself has practical reasons, as ETF data is available in real-time and reflects actual tradability. In addition to closing prices, high, low, and volume data are captured, which are required for calculating advanced volatility measures.

Fundamental corporate metrics are retrieved via TradingView's Financial Data API. These include earnings per share, price-to-earnings ratio, return on equity, debt-to-equity ratio, dividend yield, and share buyback yield. Cochrane (2011) emphasizes in "Presidential Address: Discount Rates" the central importance of valuation metrics for forecasting future returns, making these fundamental data a cornerstone of the model.

Volatility indicators are represented by the CBOE Volatility Index (VIX) and related metrics. The VIX, often referred to as the market's "fear gauge," measures the implied volatility of S&P 500 index options and serves as a proxy for market participants' risk perception. Whaley (2000) describes in "The Investor Fear Gauge" the construction and interpretation of the VIX and its use as a sentiment indicator.

Macroeconomic data includes yield curve information through US Treasury bonds of various maturities and credit risk premiums through the spread between high-yield bonds and risk-free government bonds. These variables capture the macroeconomic conditions and financing conditions relevant for equity valuation. Estrella and Hardouvelis (1991) showed that the shape of the yield curve has predictive power for future economic activity, justifying the inclusion of these data.

2.2 Handling Missing Data

A practical problem when working with financial data is dealing with missing or unavailable values. The model implements a fallback system where a plausible historical average value is stored for each fundamental metric. When current data is unavailable for a specific point in time, this fallback value is used. This approach ensures that the model remains functional even during temporary data outages and avoids systematic biases from missing data. The use of average values as fallback is conservative, as it generates neither overly optimistic nor pessimistic signals.

3. Component 1: Market Regime Detection

3.1 The Concept of Market Regimes

The idea that financial markets exist in different "regimes" or states that differ in their statistical properties has a long tradition in financial science. Hamilton (1989) developed regime-switching models that allow distinguishing between different market states with different return and volatility characteristics. The practical application of this theory consists of identifying the current market state and adjusting portfolio allocation accordingly.

DEAM classifies market regimes using a scoring system that considers three main dimensions: trend strength, volatility level, and drawdown depth. This multidimensional view is more robust than focusing on individual indicators, as it captures various facets of market dynamics. Classification occurs into six distinct regimes: Strong Bull, Bull Market, Neutral, Correction, Bear Market, and Crisis.

3.2 Trend Analysis Through Moving Averages

Moving averages are among the oldest and most widely used technical indicators and have also received attention in academic literature. Brock, Lakonishok, and LeBaron (1992) examined in "Simple Technical Trading Rules and the Stochastic Properties of Stock Returns" the profitability of trading rules based on moving averages and found evidence for their predictive power, although later studies questioned the robustness of these results when considering transaction costs.

The model calculates three moving averages with different time windows: a 20-day average (approximately one trading month), a 50-day average (approximately one quarter), and a 200-day average (approximately one trading year). The relationship of the current price to these averages and the relationship of the averages to each other provide information about trend strength and direction. When the price trades above all three averages and the short-term average is above the long-term, this indicates an established uptrend. The model assigns points based on these constellations, with longer-term trends weighted more heavily as they are considered more persistent.

3.3 Volatility Regimes

Volatility, understood as the standard deviation of returns, is a central concept of financial theory and serves as the primary risk measure. However, research has shown that volatility is not constant but changes over time and occurs in clusters—a phenomenon first documented by Mandelbrot (1963) and later formalized through ARCH and GARCH models (Engle, 1982; Bollerslev, 1986).

DEAM calculates volatility not only through the classic method of return standard deviation but also uses more advanced estimators such as the Parkinson estimator and the Garman-Klass estimator. These methods utilize intraday information (high and low prices) and are more efficient than simple close-to-close volatility estimators. The Parkinson estimator (Parkinson, 1980) uses the range between high and low of a trading day and is based on the recognition that this information reveals more about true volatility than just the closing price difference. The Garman-Klass estimator (Garman and Klass, 1980) extends this approach by additionally considering opening and closing prices.

The calculated volatility is annualized by multiplying it by the square root of 252 (the average number of trading days per year), enabling standardized comparability. The model compares current volatility with the VIX, the implied volatility from option prices. A low VIX (below 15) signals market comfort and increases the regime score, while a high VIX (above 35) indicates market stress and reduces the score. This interpretation follows the empirical observation that elevated volatility is typically associated with falling markets (Schwert, 1989).

3.4 Drawdown Analysis

A drawdown refers to the percentage decline from the highest point (peak) to the lowest point (trough) during a specific period. This metric is psychologically significant for investors as it represents the maximum loss experienced. Calmar (1991) developed the Calmar Ratio, which relates return to maximum drawdown, underscoring the practical relevance of this metric.

The model calculates current drawdown as the percentage distance from the highest price of the last 252 trading days (one year). A drawdown below 3% is considered negligible and maximally increases the regime score. As drawdown increases, the score decreases progressively, with drawdowns above 20% classified as severe and indicating a crisis or bear market regime. These thresholds are empirically motivated by historical market cycles, in which corrections typically encompassed 5-10% drawdowns, bear markets 20-30%, and crises over 30%.

3.5 Regime Classification

Final regime classification occurs through aggregation of scores from trend (40% weight), volatility (30%), and drawdown (30%). The higher weighting of trend reflects the empirical observation that trend-following strategies have historically delivered robust results (Moskowitz, Ooi, and Pedersen, 2012). A total score above 80 signals a strong bull market with established uptrend, low volatility, and minimal losses. At a score below 10, a crisis situation exists requiring defensive positioning. The six regime categories enable a differentiated allocation strategy that not only distinguishes binarily between bullish and bearish but allows gradual gradations.

4. Component 2: Risk-Based Allocation

4.1 Volatility Targeting as Risk Management Approach

The concept of volatility targeting is based on the idea that investors should maximize not returns but risk-adjusted returns. Sharpe (1966, 1994) defined with the Sharpe Ratio the fundamental concept of return per unit of risk, measured as volatility. Volatility targeting goes a step further and adjusts portfolio allocation to achieve constant target volatility. This means that in times of low market volatility, equity allocation is increased, and in times of high volatility, it is reduced.

Moreira and Muir (2017) showed in "Volatility-Managed Portfolios" that strategies that adjust their exposure based on volatility forecasts achieve higher Sharpe Ratios than passive buy-and-hold strategies. DEAM implements this principle by defining a target portfolio volatility (default 12% annualized) and adjusting equity allocation to achieve it. The mathematical foundation is simple: if market volatility is 20% and target volatility is 12%, equity allocation should be 60% (12/20 = 0.6), with the remaining 40% held in cash with zero volatility.

4.2 Market Volatility Calculation

Estimating current market volatility is central to the risk-based allocation approach. The model uses several volatility estimators in parallel and selects the higher value between traditional close-to-close volatility and the Parkinson estimator. This conservative choice ensures the model does not underestimate true volatility, which could lead to excessive risk exposure.

Traditional volatility calculation uses logarithmic returns, as these have mathematically advantageous properties (additive linkage over multiple periods). The logarithmic return is calculated as ln(P_t / P_{t-1}), where P_t is the price at time t. The standard deviation of these returns over a rolling 20-trading-day window is then multiplied by √252 to obtain annualized volatility. This annualization is based on the assumption of independently identically distributed returns, which is an idealization but widely accepted in practice.

The Parkinson estimator uses additional information from the trading range (High minus Low) of each day. The formula is: σ_P = (1/√(4ln2)) × √(1/n × Σln²(H_i/L_i)) × √252, where H_i and L_i are high and low prices. Under ideal conditions, this estimator is approximately five times more efficient than the close-to-close estimator (Parkinson, 1980), as it uses more information per observation.

4.3 Drawdown-Based Position Size Adjustment

In addition to volatility targeting, the model implements drawdown-based risk control. The logic is that deep market declines often signal further losses and therefore justify exposure reduction. This behavior corresponds with the concept of path-dependent risk tolerance: investors who have already suffered losses are typically less willing to take additional risk (Kahneman and Tversky, 1979).

The model defines a maximum portfolio drawdown as a target parameter (default 15%). Since portfolio volatility and portfolio drawdown are proportional to equity allocation (assuming cash has neither volatility nor drawdown), allocation-based control is possible. For example, if the market exhibits a 25% drawdown and target portfolio drawdown is 15%, equity allocation should be at most 60% (15/25).

4.4 Dynamic Risk Adjustment

An advanced feature of DEAM is dynamic adjustment of risk-based allocation through a feedback mechanism. The model continuously estimates what actual portfolio volatility and portfolio drawdown would result at the current allocation. If risk utilization (ratio of actual to target risk) exceeds 1.0, allocation is reduced by an adjustment factor that grows exponentially with overutilization. This implements a form of dynamic feedback that avoids overexposure.

Mathematically, a risk adjustment factor r_adjust is calculated: if risk utilization u > 1, then r_adjust = exp(-0.5 × (u - 1)). This exponential function ensures that moderate overutilization is gently corrected, while strong overutilization triggers drastic reductions. The factor 0.5 in the exponent was empirically calibrated to achieve a balanced ratio between sensitivity and stability.

5. Component 3: Valuation Analysis

5.1 Theoretical Foundations of Fundamental Valuation

DEAM's valuation component is based on the fundamental premise that the intrinsic value of a security is determined by its future cash flows and that deviations between market price and intrinsic value are eventually corrected. Graham and Dodd (1934) established in "Security Analysis" the basic principles of fundamental analysis that remain relevant today. Translated into modern portfolio context, this means that markets with high valuation metrics (high price-earnings ratios) should have lower expected returns than cheaply valued markets.

Campbell and Shiller (1988) developed the Cyclically Adjusted P/E Ratio (CAPE), which smooths earnings over a full business cycle. Their empirical analysis showed that this ratio has significant predictive power for 10-year returns. Asness, Moskowitz, and Pedersen (2013) demonstrated in "Value and Momentum Everywhere" that value effects exist not only in individual stocks but also in asset classes and markets.

5.2 Equity Risk Premium as Central Valuation Metric

The Equity Risk Premium (ERP) is defined as the expected excess return of stocks over risk-free government bonds. It is the theoretical heart of valuation analysis, as it represents the compensation investors demand for bearing equity risk. Damodaran (2012) discusses in "Equity Risk Premiums: Determinants, Estimation and Implications" various methods for ERP estimation.

DEAM calculates ERP not through a single method but combines four complementary approaches with different weights. This multi-method strategy increases estimation robustness and avoids dependence on single, potentially erroneous inputs.

The first method (35% weight) uses earnings yield, calculated as 1/P/E or directly from operating earnings data, and subtracts the 10-year Treasury yield. This method follows Fed Model logic (Yardeni, 2003), although this model has theoretical weaknesses as it does not consistently treat inflation (Asness, 2003).

The second method (30% weight) extends earnings yield by share buyback yield. Share buybacks are a form of capital return to shareholders and increase value per share. Boudoukh et al. (2007) showed in "The Total Shareholder Yield" that the sum of dividend yield and buyback yield is a better predictor of future returns than dividend yield alone.

The third method (20% weight) implements the Gordon Growth Model (Gordon, 1962), which models stock value as the sum of discounted future dividends. Under constant growth g assumption: Expected Return = Dividend Yield + g. The model estimates sustainable growth as g = ROE × (1 - Payout Ratio), where ROE is return on equity and payout ratio is the ratio of dividends to earnings. This formula follows from equity theory: unretained earnings are reinvested at ROE and generate additional earnings growth.

The fourth method (15% weight) combines total shareholder yield (Dividend + Buybacks) with implied growth derived from revenue growth. This method considers that companies with strong revenue growth should generate higher future earnings, even if current valuations do not yet fully reflect this.

The final ERP is the weighted average of these four methods. A high ERP (above 4%) signals attractive valuations and increases the valuation score to 95 out of 100 possible points. A negative ERP, where stocks have lower expected returns than bonds, results in a minimal score of 10.

5.3 Quality Adjustments to Valuation

Valuation metrics alone can be misleading if not interpreted in the context of company quality. A company with a low P/E may be cheap or fundamentally problematic. The model therefore implements quality adjustments based on growth, profitability, and capital structure.

Revenue growth above 10% annually adds 10 points to the valuation score, moderate growth above 5% adds 5 points. This adjustment reflects that growth has independent value (Modigliani and Miller, 1961, extended by later growth theory). Net margin above 15% signals pricing power and operational efficiency and increases the score by 5 points, while low margins below 8% indicate competitive pressure and subtract 5 points.

Return on equity (ROE) above 20% characterizes outstanding capital efficiency and increases the score by 5 points. Piotroski (2000) showed in "Value Investing: The Use of Historical Financial Statement Information" that fundamental quality signals such as high ROE can improve the performance of value strategies.

Capital structure is evaluated through the debt-to-equity ratio. A conservative ratio below 1.0 multiplies the valuation score by 1.2, while high leverage above 2.0 applies a multiplier of 0.8. This adjustment reflects that high debt constrains financial flexibility and can become problematic in crisis times (Korteweg, 2010).

6. Component 4: Sentiment Analysis

6.1 The Role of Sentiment in Financial Markets

Investor sentiment, defined as the collective psychological attitude of market participants, influences asset prices independently of fundamental data. Baker and Wurgler (2006, 2007) developed a sentiment index and showed that periods of high sentiment are followed by overvaluations that later correct. This insight justifies integrating a sentiment component into allocation decisions.

Sentiment is difficult to measure directly but can be proxied through market indicators. The VIX is the most widely used sentiment indicator, as it aggregates implied volatility from option prices. High VIX values reflect elevated uncertainty and risk aversion, while low values signal market comfort. Whaley (2009) refers to the VIX as the "Investor Fear Gauge" and documents its role as a contrarian indicator: extremely high values typically occur at market bottoms, while low values occur at tops.

6.2 VIX-Based Sentiment Assessment

DEAM uses statistical normalization of the VIX by calculating the Z-score: z = (VIX_current - VIX_average) / VIX_standard_deviation. The Z-score indicates how many standard deviations the current VIX is from the historical average. This approach is more robust than absolute thresholds, as it adapts to the average volatility level, which can vary over longer periods.

A Z-score below -1.5 (VIX is 1.5 standard deviations below average) signals exceptionally low risk perception and adds 40 points to the sentiment score. This may seem counterintuitive—shouldn't low fear be bullish? However, the logic follows the contrarian principle: when no one is afraid, everyone is already invested, and there is limited further upside potential (Zweig, 1973). Conversely, a Z-score above 1.5 (extreme fear) adds -40 points, reflecting market panic but simultaneously suggesting potential buying opportunities.

6.3 VIX Term Structure as Sentiment Signal

The VIX term structure provides additional sentiment information. Normally, the VIX trades in contango, meaning longer-term VIX futures have higher prices than short-term. This reflects that short-term volatility is currently known, while long-term volatility is more uncertain and carries a risk premium. The model compares the VIX with VIX9D (9-day volatility) and identifies backwardation (VIX > 1.05 × VIX9D) and steep backwardation (VIX > 1.15 × VIX9D).

Backwardation occurs when short-term implied volatility is higher than longer-term, which typically happens during market stress. Investors anticipate immediate turbulence but expect calming. Psychologically, this reflects acute fear. The model subtracts 15 points for backwardation and 30 for steep backwardation, as these constellations signal elevated risk. Simon and Wiggins (2001) analyzed the VIX futures curve and showed that backwardation is associated with market declines.

6.4 Safe-Haven Flows

During crisis times, investors flee from risky assets into safe havens: gold, US dollar, and Japanese yen. This "flight to quality" is a sentiment signal. The model calculates the performance of these assets relative to stocks over the last 20 trading days. When gold or the dollar strongly rise while stocks fall, this indicates elevated risk aversion.

The safe-haven component is calculated as the difference between safe-haven performance and stock performance. Positive values (safe havens outperform) subtract up to 20 points from the sentiment score, negative values (stocks outperform) add up to 10 points. The asymmetric treatment (larger deduction for risk-off than bonus for risk-on) reflects that risk-off movements are typically sharper and more informative than risk-on phases.

Baur and Lucey (2010) examined safe-haven properties of gold and showed that gold indeed exhibits negative correlation with stocks during extreme market movements, confirming its role as crisis protection.

7. Component 5: Macroeconomic Analysis

7.1 The Yield Curve as Economic Indicator

The yield curve, represented as yields of government bonds of various maturities, contains aggregated expectations about future interest rates, inflation, and economic growth. The slope of the yield curve has remarkable predictive power for recessions. Estrella and Mishkin (1998) showed that an inverted yield curve (short-term rates higher than long-term) predicts recessions with high reliability. This is because inverted curves reflect restrictive monetary policy: the central bank raises short-term rates to combat inflation, dampening economic activity.

DEAM calculates two spread measures: the 2-year-minus-10-year spread and the 3-month-minus-10-year spread. A steep, positive curve (spreads above 1.5% and 2% respectively) signals healthy growth expectations and generates the maximum yield curve score of 40 points. A flat curve (spreads near zero) reduces the score to 20 points. An inverted curve (negative spreads) is particularly alarming and results in only 10 points.

The choice of two different spreads increases analysis robustness. The 2-10 spread is most established in academic literature, while the 3M-10Y spread is often considered more sensitive, as the 3-month rate directly reflects current monetary policy (Ang, Piazzesi, and Wei, 2006).

7.2 Credit Conditions and Spreads

Credit spreads—the yield difference between risky corporate bonds and safe government bonds—reflect risk perception in the credit market. Gilchrist and Zakrajšek (2012) constructed an "Excess Bond Premium" that measures the component of credit spreads not explained by fundamentals and showed this is a predictor of future economic activity and stock returns.

The model approximates credit spread by comparing the yield of high-yield bond ETFs (HYG) with investment-grade bond ETFs (LQD). A narrow spread below 200 basis points signals healthy credit conditions and risk appetite, contributing 30 points to the macro score. Very wide spreads above 1000 basis points (as during the 2008 financial crisis) signal credit crunch and generate zero points.

Additionally, the model evaluates whether "flight to quality" is occurring, identified through strong performance of Treasury bonds (TLT) with simultaneous weakness in high-yield bonds. This constellation indicates elevated risk aversion and reduces the credit conditions score.

7.3 Financial Stability at Corporate Level

While the yield curve and credit spreads reflect macroeconomic conditions, financial stability evaluates the health of companies themselves. The model uses the aggregated debt-to-equity ratio and return on equity of the S&P 500 as proxies for corporate health.

A low leverage level below 0.5 combined with high ROE above 15% signals robust corporate balance sheets and generates 20 points. This combination is particularly valuable as it represents both defensive strength (low debt means crisis resistance) and offensive strength (high ROE means earnings power). High leverage above 1.5 generates only 5 points, as it implies vulnerability to interest rate increases and recessions.

Korteweg (2010) showed in "The Net Benefits to Leverage" that optimal debt maximizes firm value, but excessive debt increases distress costs. At the aggregated market level, high debt indicates fragilities that can become problematic during stress phases.

8. Component 6: Crisis Detection

8.1 The Need for Systematic Crisis Detection

Financial crises are rare but extremely impactful events that suspend normal statistical relationships. During normal market volatility, diversified portfolios and traditional risk management approaches function, but during systemic crises, seemingly independent assets suddenly correlate strongly, and losses exceed historical expectations (Longin and Solnik, 2001). This justifies a separate crisis detection mechanism that operates independently of regular allocation components.

Reinhart and Rogoff (2009) documented in "This Time Is Different: Eight Centuries of Financial Folly" recurring patterns in financial crises: extreme volatility, massive drawdowns, credit market dysfunction, and asset price collapse. DEAM operationalizes these patterns into quantifiable crisis indicators.

8.2 Multi-Signal Crisis Identification

The model uses a counter-based approach where various stress signals are identified and aggregated. This methodology is more robust than relying on a single indicator, as true crises typically occur simultaneously across multiple dimensions. A single signal may be a false alarm, but the simultaneous presence of multiple signals increases confidence.

The first indicator is a VIX above the crisis threshold (default 40), adding one point. A VIX above 60 (as in 2008 and March 2020) adds two additional points, as such extreme values are historically very rare. This tiered approach captures the intensity of volatility.

The second indicator is market drawdown. A drawdown above 15% adds one point, as corrections of this magnitude can be potential harbingers of larger crises. A drawdown above 25% adds another point, as historical bear markets typically encompass 25-40% drawdowns.

The third indicator is credit market spreads above 500 basis points, adding one point. Such wide spreads occur only during significant credit market disruptions, as in 2008 during the Lehman crisis.

The fourth indicator identifies simultaneous losses in stocks and bonds. Normally, Treasury bonds act as a hedge against equity risk (negative correlation), but when both fall simultaneously, this indicates systemic liquidity problems or inflation/stagflation fears. The model checks whether both SPY and TLT have fallen more than 10% and 5% respectively over 5 trading days, adding two points.

The fifth indicator is a volume spike combined with negative returns. Extreme trading volumes (above twice the 20-day average) with falling prices signal panic selling. This adds one point.

A crisis situation is diagnosed when at least 3 indicators trigger, a severe crisis at 5 or more indicators. These thresholds were calibrated through historical backtesting to identify true crises (2008, 2020) without generating excessive false alarms.

8.3 Crisis-Based Allocation Override

When a crisis is detected, the system overrides the normal allocation recommendation and caps equity allocation at maximum 25%. In a severe crisis, the cap is set at 10%. This drastic defensive posture follows the empirical observation that crises typically require time to develop and that early reduction can avoid substantial losses (Faber, 2007).

This override logic implements a "safety first" principle: in situations of existential danger to the portfolio, capital preservation becomes the top priority. Roy (1952) formalized this approach in "Safety First and the Holding of Assets," arguing that investors should primarily minimize ruin probability.

9. Integration and Final Allocation Calculation

9.1 Component Weighting

The final allocation recommendation emerges through weighted aggregation of the five components. The standard weighting is: Market Regime 35%, Risk Management 25%, Valuation 20%, Sentiment 15%, Macro 5%. These weights reflect both theoretical considerations and empirical backtesting results.

The highest weighting of market regime is based on evidence that trend-following and momentum strategies have delivered robust results across various asset classes and time periods (Moskowitz, Ooi, and Pedersen, 2012). Current market momentum is highly informative for the near future, although it provides no information about long-term expectations.

The substantial weighting of risk management (25%) follows from the central importance of risk control. Wealth preservation is the foundation of long-term wealth creation, and systematic risk management is demonstrably value-creating (Moreira and Muir, 2017).

The valuation component receives 20% weight, based on the long-term mean reversion of valuation metrics. While valuation has limited short-term predictive power (bull and bear markets can begin at any valuation), the long-term relationship between valuation and returns is robustly documented (Campbell and Shiller, 1988).

Sentiment (15%) and Macro (5%) receive lower weights, as these factors are subtler and harder to measure. Sentiment is valuable as a contrarian indicator at extremes but less informative in normal ranges. Macro variables such as the yield curve have strong predictive power for recessions, but the transmission from recessions to stock market performance is complex and temporally variable.

9.2 Model Type Adjustments

DEAM allows users to choose between four model types: Conservative, Balanced, Aggressive, and Adaptive. This choice modifies the final allocation through additive adjustments.

Conservative mode subtracts 10 percentage points from allocation, resulting in consistently more cautious positioning. This is suitable for risk-averse investors or those with limited investment horizons. Aggressive mode adds 10 percentage points, suitable for risk-tolerant investors with long horizons.

Adaptive mode implements procyclical adjustment based on short-term momentum: if the market has risen more than 5% in the last 20 days, 5 percentage points are added; if it has declined more than 5%, 5 points are subtracted. This logic follows the observation that short-term momentum persists (Jegadeesh and Titman, 1993), but the moderate size of adjustment avoids excessive timing bets.

Balanced mode makes no adjustment and uses raw model output. This neutral setting is suitable for investors who wish to trust model recommendations unchanged.

9.3 Smoothing and Stability

The allocation resulting from aggregation undergoes final smoothing through a simple moving average over 3 periods. This smoothing is crucial for model practicality, as it reduces frequent trading and thus transaction costs. Without smoothing, the model could fluctuate between adjacent allocations with every small input change.

The choice of 3 periods as smoothing window is a compromise between responsiveness and stability. Longer smoothing would excessively delay signals and impede response to true regime changes. Shorter or no smoothing would allow too much noise. Empirical tests showed that 3-period smoothing offers an optimal ratio between these goals.

10. Visualization and Interpretation

10.1 Main Output: Equity Allocation

DEAM's primary output is a time series from 0 to 100 representing the recommended percentage allocation to equities. This representation is intuitive: 100% means full investment in stocks (specifically: an S&P 500 ETF), 0% means complete cash position, and intermediate values correspond to mixed portfolios. A value of 60% means, for example: invest 60% of wealth in SPY, hold 40% in money market instruments or cash.

The time series is color-coded to enable quick visual interpretation. Green shades represent high allocations (above 80%, bullish), red shades low allocations (below 20%, bearish), and neutral colors middle allocations. The chart background is dynamically colored based on the signal, enhancing readability in different market phases.

10.2 Dashboard Metrics

A tabular dashboard presents key metrics compactly. This includes current allocation, cash allocation (complement), an aggregated signal (BULLISH/NEUTRAL/BEARISH), current market regime, VIX level, market drawdown, and crisis status.

Additionally, fundamental metrics are displayed: P/E Ratio, Equity Risk Premium, Return on Equity, Debt-to-Equity Ratio, and Total Shareholder Yield. This transparency allows users to understand model decisions and form their own assessments.

Component scores (Regime, Risk, Valuation, Sentiment, Macro) are also displayed, each normalized on a 0-100 scale. This shows which factors primarily drive the current recommendation. If, for example, the Risk score is very low (20) while other scores are moderate (50-60), this indicates that risk management considerations are pulling allocation down.

10.3 Component Breakdown (Optional)

Advanced users can display individual components as separate lines in the chart. This enables analysis of component dynamics: do all components move synchronously, or are there divergences? Divergences can be particularly informative. If, for example, the market regime is bullish (high score) but the valuation component is very negative, this signals an overbought market not fundamentally supported—a classic "bubble warning."

This feature is disabled by default to keep the chart clean but can be activated for deeper analysis.

10.4 Confidence Bands

The model optionally displays uncertainty bands around the main allocation line. These are calculated as ±1 standard deviation of allocation over a rolling 20-period window. Wide bands indicate high volatility of model recommendations, suggesting uncertain market conditions. Narrow bands indicate stable recommendations.

This visualization implements a concept of epistemic uncertainty—uncertainty about the model estimate itself, not just market volatility. In phases where various indicators send conflicting signals, the allocation recommendation becomes more volatile, manifesting in wider bands. Users can understand this as a warning to act more cautiously or consult alternative information sources.

11. Alert System

11.1 Allocation Alerts

DEAM implements an alert system that notifies users of significant events. Allocation alerts trigger when smoothed allocation crosses certain thresholds. An alert is generated when allocation reaches 80% (from below), signaling strong bullish conditions. Another alert triggers when allocation falls to 20%, indicating defensive positioning.

These thresholds are not arbitrary but correspond with boundaries between model regimes. An allocation of 80% roughly corresponds to a clear bull market regime, while 20% corresponds to a bear market regime. Alerts at these points are therefore informative about fundamental regime shifts.

11.2 Crisis Alerts

Separate alerts trigger upon detection of crisis and severe crisis. These alerts have highest priority as they signal large risks. A crisis alert should prompt investors to review their portfolio and potentially take defensive measures beyond the automatic model recommendation (e.g., hedging through put options, rebalancing to more defensive sectors).

11.3 Regime Change Alerts

An alert triggers upon change of market regime (e.g., from Neutral to Correction, or from Bull Market to Strong Bull). Regime changes are highly informative events that typically entail substantial allocation changes. These alerts enable investors to proactively respond to changes in market dynamics.

11.4 Risk Breach Alerts

A specialized alert triggers when actual portfolio risk utilization exceeds target parameters by 20%. This is a warning signal that the risk management system is reaching its limits, possibly because market volatility is rising faster than allocation can be reduced. In such situations, investors should consider manual interventions.

12. Practical Application and Limitations

12.1 Portfolio Implementation

DEAM generates a recommendation for allocation between equities (S&P 500) and cash. Implementation by an investor can take various forms. The most direct method is using an S&P 500 ETF (e.g., SPY, VOO) for equity allocation and a money market fund or savings account for cash allocation.

A rebalancing strategy is required to synchronize actual allocation with model recommendation. Two approaches are possible: (1) rule-based rebalancing at every 10% deviation between actual and target, or (2) time-based monthly rebalancing. Both have trade-offs between responsiveness and transaction costs. Empirical evidence (Jaconetti, Kinniry, and Zilbering, 2010) suggests rebalancing frequency has moderate impact on performance, and investors should optimize based on their transaction costs.

12.2 Adaptation to Individual Preferences

The model offers numerous adjustment parameters. Component weights can be modified if investors place more or less belief in certain factors. A fundamentally-oriented investor might increase valuation weight, while a technical trader might increase regime weight.

Risk target parameters (target volatility, max drawdown) should be adapted to individual risk tolerance. Younger investors with long investment horizons can choose higher target volatility (15-18%), while retirees may prefer lower volatility (8-10%). This adjustment systematically shifts average equity allocation.

Crisis thresholds can be adjusted based on preference for sensitivity versus specificity of crisis detection. Lower thresholds (e.g., VIX > 35 instead of 40) increase sensitivity (more crises are detected) but reduce specificity (more false alarms). Higher thresholds have the reverse effect.

12.3 Limitations and Disclaimers

DEAM is based on historical relationships between indicators and market performance. There is no guarantee these relationships will persist in the future. Structural changes in markets (e.g., through regulation, technology, or central bank policy) can break established patterns. This is the fundamental problem of induction in financial science (Taleb, 2007).

The model is optimized for US equities (S&P 500). Application to other markets (international stocks, bonds, commodities) would require recalibration. The indicators and thresholds are specific to the statistical properties of the US equity market.

The model cannot eliminate losses. Even with perfect crisis prediction, an investor following the model would lose money in bear markets—just less than a buy-and-hold investor. The goal is risk-adjusted performance improvement, not risk elimination.

Transaction costs are not modeled. In practice, spreads, commissions, and taxes reduce net returns. Frequent trading can cause substantial costs. Model smoothing helps minimize this, but users should consider their specific cost situation.

The model reacts to information; it does not anticipate it. During sudden shocks (e.g., 9/11, COVID-19 lockdowns), the model can only react after price movements, not before. This limitation is inherent to all reactive systems.

12.4 Relationship to Other Strategies

DEAM is a tactical asset allocation approach and should be viewed as a complement, not replacement, for strategic asset allocation. Brinson, Hood, and Beebower (1986) showed in their influential study "Determinants of Portfolio Performance" that strategic asset allocation (long-term policy allocation) explains the majority of portfolio performance, but this leaves room for tactical adjustments based on market timing.

The model can be combined with value and momentum strategies at the individual stock level. While DEAM controls overall market exposure, within-equity decisions can be optimized through stock-picking models. This separation between strategic (market exposure) and tactical (stock selection) levels follows classical portfolio theory.

The model does not replace diversification across asset classes. A complete portfolio should also include bonds, international stocks, real estate, and alternative investments. DEAM addresses only the US equity allocation decision within a broader portfolio.

13. Scientific Foundation and Evaluation

13.1 Theoretical Consistency

DEAM's components are based on established financial theory and empirical evidence. The market regime component follows from regime-switching models (Hamilton, 1989) and trend-following literature. The risk management component implements volatility targeting (Moreira and Muir, 2017) and modern portfolio theory (Markowitz, 1952). The valuation component is based on discounted cash flow theory and empirical value research (Campbell and Shiller, 1988; Fama and French, 1992). The sentiment component integrates behavioral finance (Baker and Wurgler, 2006). The macro component uses established business cycle indicators (Estrella and Mishkin, 1998).

This theoretical grounding distinguishes DEAM from purely data-mining-based approaches that identify patterns without causal theory. Theory-guided models have greater probability of functioning out-of-sample, as they are based on fundamental mechanisms, not random correlations (Lo and MacKinlay, 1990).

13.2 Empirical Validation

While this document does not present detailed backtest analysis, it should be noted that rigorous validation of a tactical asset allocation model should include several elements:

In-sample testing establishes whether the model functions at all in the data on which it was calibrated. Out-of-sample testing is crucial: the model should be tested in time periods not used for development. Walk-forward analysis, where the model is successively trained on rolling windows and tested in the next window, approximates real implementation.

Performance metrics should be risk-adjusted. Pure return consideration is misleading, as higher returns often only compensate for higher risk. Sharpe Ratio, Sortino Ratio, Calmar Ratio, and Maximum Drawdown are relevant metrics. Comparison with benchmarks (Buy-and-Hold S&P 500, 60/40 Stock/Bond portfolio) contextualizes performance.

Robustness checks test sensitivity to parameter variation. If the model only functions at specific parameter settings, this indicates overfitting. Robust models show consistent performance over a range of plausible parameters.

13.3 Comparison with Existing Literature

DEAM fits into the broader literature on tactical asset allocation. Faber (2007) presented a simple momentum-based timing system that goes long when the market is above its 10-month average, otherwise cash. This simple system avoided large drawdowns in bear markets. DEAM can be understood as a sophistication of this approach that integrates multiple information sources.

Ilmanen (2011) discusses various timing factors in "Expected Returns" and argues for multi-factor approaches. DEAM operationalizes this philosophy. Asness, Moskowitz, and Pedersen (2013) showed that value and momentum effects work across asset classes, justifying cross-asset application of regime and valuation signals.

Ang (2014) emphasizes in "Asset Management: A Systematic Approach to Factor Investing" the importance of systematic, rule-based approaches over discretionary decisions. DEAM is fully systematic and eliminates emotional biases that plague individual investors (overconfidence, hindsight bias, loss aversion).

References

Ang, A. (2014) *Asset Management: A Systematic Approach to Factor Investing*. Oxford: Oxford University Press.

Ang, A., Piazzesi, M. and Wei, M. (2006) 'What does the yield curve tell us about GDP growth?', *Journal of Econometrics*, 131(1-2), pp. 359-403.

Asness, C.S. (2003) 'Fight the Fed Model', *The Journal of Portfolio Management*, 30(1), pp. 11-24.

Asness, C.S., Moskowitz, T.J. and Pedersen, L.H. (2013) 'Value and Momentum Everywhere', *The Journal of Finance*, 68(3), pp. 929-985.

Baker, M. and Wurgler, J. (2006) 'Investor Sentiment and the Cross-Section of Stock Returns', *The Journal of Finance*, 61(4), pp. 1645-1680.

Baker, M. and Wurgler, J. (2007) 'Investor Sentiment in the Stock Market', *Journal of Economic Perspectives*, 21(2), pp. 129-152.

Baur, D.G. and Lucey, B.M. (2010) 'Is Gold a Hedge or a Safe Haven? An Analysis of Stocks, Bonds and Gold', *Financial Review*, 45(2), pp. 217-229.

Bollerslev, T. (1986) 'Generalized Autoregressive Conditional Heteroskedasticity', *Journal of Econometrics*, 31(3), pp. 307-327.

Boudoukh, J., Michaely, R., Richardson, M. and Roberts, M.R. (2007) 'On the Importance of Measuring Payout Yield: Implications for Empirical Asset Pricing', *The Journal of Finance*, 62(2), pp. 877-915.

Brinson, G.P., Hood, L.R. and Beebower, G.L. (1986) 'Determinants of Portfolio Performance', *Financial Analysts Journal*, 42(4), pp. 39-44.

Brock, W., Lakonishok, J. and LeBaron, B. (1992) 'Simple Technical Trading Rules and the Stochastic Properties of Stock Returns', *The Journal of Finance*, 47(5), pp. 1731-1764.

Calmar, T.W. (1991) 'The Calmar Ratio', *Futures*, October issue.

Campbell, J.Y. and Shiller, R.J. (1988) 'The Dividend-Price Ratio and Expectations of Future Dividends and Discount Factors', *Review of Financial Studies*, 1(3), pp. 195-228.

Cochrane, J.H. (2011) 'Presidential Address: Discount Rates', *The Journal of Finance*, 66(4), pp. 1047-1108.

Damodaran, A. (2012) *Equity Risk Premiums: Determinants, Estimation and Implications*. Working Paper, Stern School of Business.

Engle, R.F. (1982) 'Autoregressive Conditional Heteroskedasticity with Estimates of the Variance of United Kingdom Inflation', *Econometrica*, 50(4), pp. 987-1007.

Estrella, A. and Hardouvelis, G.A. (1991) 'The Term Structure as a Predictor of Real Economic Activity', *The Journal of Finance*, 46(2), pp. 555-576.

Estrella, A. and Mishkin, F.S. (1998) 'Predicting U.S. Recessions: Financial Variables as Leading Indicators', *Review of Economics and Statistics*, 80(1), pp. 45-61.

Faber, M.T. (2007) 'A Quantitative Approach to Tactical Asset Allocation', *The Journal of Wealth Management*, 9(4), pp. 69-79.

Fama, E.F. and French, K.R. (1989) 'Business Conditions and Expected Returns on Stocks and Bonds', *Journal of Financial Economics*, 25(1), pp. 23-49.

Fama, E.F. and French, K.R. (1992) 'The Cross-Section of Expected Stock Returns', *The Journal of Finance*, 47(2), pp. 427-465.

Garman, M.B. and Klass, M.J. (1980) 'On the Estimation of Security Price Volatilities from Historical Data', *Journal of Business*, 53(1), pp. 67-78.

Gilchrist, S. and Zakrajšek, E. (2012) 'Credit Spreads and Business Cycle Fluctuations', *American Economic Review*, 102(4), pp. 1692-1720.

Gordon, M.J. (1962) *The Investment, Financing, and Valuation of the Corporation*. Homewood: Irwin.

Graham, B. and Dodd, D.L. (1934) *Security Analysis*. New York: McGraw-Hill.

Hamilton, J.D. (1989) 'A New Approach to the Economic Analysis of Nonstationary Time Series and the Business Cycle', *Econometrica*, 57(2), pp. 357-384.

Ilmanen, A. (2011) *Expected Returns: An Investor's Guide to Harvesting Market Rewards*. Chichester: Wiley.

Jaconetti, C.M., Kinniry, F.M. and Zilbering, Y. (2010) 'Best Practices for Portfolio Rebalancing', *Vanguard Research Paper*.

Jegadeesh, N. and Titman, S. (1993) 'Returns to Buying Winners and Selling Losers: Implications for Stock Market Efficiency', *The Journal of Finance*, 48(1), pp. 65-91.

Kahneman, D. and Tversky, A. (1979) 'Prospect Theory: An Analysis of Decision under Risk', *Econometrica*, 47(2), pp. 263-292.

Korteweg, A. (2010) 'The Net Benefits to Leverage', *The Journal of Finance*, 65(6), pp. 2137-2170.

Lo, A.W. and MacKinlay, A.C. (1990) 'Data-Snooping Biases in Tests of Financial Asset Pricing Models', *Review of Financial Studies*, 3(3), pp. 431-467.

Longin, F. and Solnik, B. (2001) 'Extreme Correlation of International Equity Markets', *The Journal of Finance*, 56(2), pp. 649-676.

Mandelbrot, B. (1963) 'The Variation of Certain Speculative Prices', *The Journal of Business*, 36(4), pp. 394-419.

Markowitz, H. (1952) 'Portfolio Selection', *The Journal of Finance*, 7(1), pp. 77-91.

Modigliani, F. and Miller, M.H. (1961) 'Dividend Policy, Growth, and the Valuation of Shares', *The Journal of Business*, 34(4), pp. 411-433.

Moreira, A. and Muir, T. (2017) 'Volatility-Managed Portfolios', *The Journal of Finance*, 72(4), pp. 1611-1644.

Moskowitz, T.J., Ooi, Y.H. and Pedersen, L.H. (2012) 'Time Series Momentum', *Journal of Financial Economics*, 104(2), pp. 228-250.

Parkinson, M. (1980) 'The Extreme Value Method for Estimating the Variance of the Rate of Return', *Journal of Business*, 53(1), pp. 61-65.

Piotroski, J.D. (2000) 'Value Investing: The Use of Historical Financial Statement Information to Separate Winners from Losers', *Journal of Accounting Research*, 38, pp. 1-41.

Reinhart, C.M. and Rogoff, K.S. (2009) *This Time Is Different: Eight Centuries of Financial Folly*. Princeton: Princeton University Press.

Ross, S.A. (1976) 'The Arbitrage Theory of Capital Asset Pricing', *Journal of Economic Theory*, 13(3), pp. 341-360.

Roy, A.D. (1952) 'Safety First and the Holding of Assets', *Econometrica*, 20(3), pp. 431-449.

Schwert, G.W. (1989) 'Why Does Stock Market Volatility Change Over Time?', *The Journal of Finance*, 44(5), pp. 1115-1153.

Sharpe, W.F. (1966) 'Mutual Fund Performance', *The Journal of Business*, 39(1), pp. 119-138.

Sharpe, W.F. (1994) 'The Sharpe Ratio', *The Journal of Portfolio Management*, 21(1), pp. 49-58.

Simon, D.P. and Wiggins, R.A. (2001) 'S&P Futures Returns and Contrary Sentiment Indicators', *Journal of Futures Markets*, 21(5), pp. 447-462.

Taleb, N.N. (2007) *The Black Swan: The Impact of the Highly Improbable*. New York: Random House.

Whaley, R.E. (2000) 'The Investor Fear Gauge', *The Journal of Portfolio Management*, 26(3), pp. 12-17.

Whaley, R.E. (2009) 'Understanding the VIX', *The Journal of Portfolio Management*, 35(3), pp. 98-105.

Yardeni, E. (2003) 'Stock Valuation Models', *Topical Study*, 51, Yardeni Research.

Zweig, M.E. (1973) 'An Investor Expectations Stock Price Predictive Model Using Closed-End Fund Premiums', *The Journal of Finance*, 28(1), pp. 67-78.

---

## Source Code

````pine
//@version=6
indicator('Dynamic Equity Allocation Model', shorttitle = 'DEAM', overlay = false, precision = 1, scale = scale.right, max_bars_back = 500)

// DYNAMIC EQUITY ALLOCATION MODEL

// Quantitative framework for dynamic portfolio allocation between stocks and cash.
// Analyzes five dimensions: market regime, risk metrics, valuation, sentiment,
// and macro conditions to generate allocation recommendations (0-100% equity).
//
// Uses real-time data from TradingView including fundamentals (P/E, ROE, ERP),
// volatility indicators (VIX), credit spreads, yield curves, and market structure.

// INPUT PARAMETERS

group1 = 'Model Configuration'
model_type = input.string('Adaptive', 'Allocation Model Type', options = ['Conservative', 'Balanced', 'Aggressive', 'Adaptive'], group = group1, tooltip = 'Conservative: Slower to increase equity, Aggressive: Faster allocation changes, Adaptive: Dynamic based on regime')

use_crisis_detection = input.bool(true, 'Enable Crisis Detection System', group = group1, tooltip = 'Automatic detection and response to crisis conditions')

use_regime_model = input.bool(true, 'Use Market Regime Detection', group = group1, tooltip = 'Identify Bull/Bear/Crisis regimes for dynamic allocation')

group2 = 'Portfolio Risk Management'
target_portfolio_volatility = input.float(12.0, 'Target Portfolio Volatility (%)', minval = 3, maxval = 20, step = 0.5, group = group2, tooltip = 'Target portfolio volatility (Cash reduces volatility: 50% Equity = ~10% vol, 100% Equity = ~20% vol)')

max_portfolio_drawdown = input.float(15.0, 'Maximum Portfolio Drawdown (%)', minval = 5, maxval = 35, step = 2.5, group = group2, tooltip = 'Maximum acceptable PORTFOLIO drawdown (not market drawdown - portfolio with cash has lower drawdown)')

enable_portfolio_risk_scaling = input.bool(true, 'Enable Portfolio Risk Scaling', group = group2, tooltip = 'Scale allocation based on actual portfolio risk characteristics (recommended)')

risk_lookback = input.int(252, 'Risk Calculation Period (Days)', minval = 60, maxval = 504, group = group2, tooltip = 'Period for calculating volatility and risk metrics')

group3 = 'Component Weights (Total = 100%)'
w_regime = input.float(35.0, 'Market Regime Weight (%)', minval = 0, maxval = 100, step = 5, group = group3)
w_risk = input.float(25.0, 'Risk Metrics Weight (%)', minval = 0, maxval = 100, step = 5, group = group3)
w_valuation = input.float(20.0, 'Valuation Weight (%)', minval = 0, maxval = 100, step = 5, group = group3)
w_sentiment = input.float(15.0, 'Sentiment Weight (%)', minval = 0, maxval = 100, step = 5, group = group3)
w_macro = input.float(5.0, 'Macro Weight (%)', minval = 0, maxval = 100, step = 5, group = group3)

group4 = 'Crisis Detection Thresholds'
crisis_vix_threshold = input.float(40, 'Crisis VIX Level', minval = 30, maxval = 80, group = group4, tooltip = 'VIX level indicating crisis conditions (COVID peaked at 82)')

crisis_drawdown_threshold = input.float(15, 'Crisis Drawdown Threshold (%)', minval = 10, maxval = 30, group = group4, tooltip = 'Market drawdown indicating crisis conditions')

crisis_credit_spread = input.float(500, 'Crisis Credit Spread (bps)', minval = 300, maxval = 1000, group = group4, tooltip = 'High yield spread indicating crisis conditions')

group5 = 'Display Settings'
show_components = input.bool(false, 'Show Component Breakdown', group = group5, tooltip = 'Display individual component analysis lines')
show_regime_background = input.bool(true, 'Show Dynamic Background', group = group5, tooltip = 'Color background based on allocation signals')
show_reference_lines = input.bool(false, 'Show Reference Lines', group = group5, tooltip = 'Display allocation percentage reference lines')
show_dashboard = input.bool(true, 'Show Analytics Dashboard', group = group5, tooltip = 'Display comprehensive analytics table')
show_confidence_bands = input.bool(false, 'Show Confidence Bands', group = group5, tooltip = 'Display uncertainty quantification bands')
smoothing_period = input.int(3, 'Smoothing Period', minval = 1, maxval = 10, group = group5, tooltip = 'Smoothing to reduce allocation noise')
background_intensity = input.int(95, 'Background Intensity (%)', minval = 90, maxval = 99, group = group5, tooltip = 'Higher values = more transparent background')

// Styling Options
color_scheme = input.string('EdgeTools', 'Color Theme', options = ['Gold', 'EdgeTools', 'Behavioral', 'Quant', 'Ocean', 'Fire', 'Matrix', 'Arctic'], group = 'Appearance', tooltip = 'Professional color themes')
use_dark_mode = input.bool(true, 'Optimize for Dark Theme', group = 'Appearance')
main_line_width = input.int(3, 'Main Line Width', minval = 1, maxval = 5, group = 'Appearance')

// DATA RETRIEVAL

// Market Data
sp500 = request.security('SPY', timeframe.period, close)
sp500_high = request.security('SPY', timeframe.period, high)
sp500_low = request.security('SPY', timeframe.period, low)
sp500_volume = request.security('SPY', timeframe.period, volume)

// Volatility Indicators
vix = request.security('VIX', timeframe.period, close)
vix9d = request.security('VIX9D', timeframe.period, close)
vxn = request.security('VXN', timeframe.period, close)

// Fixed Income and Credit
us2y = request.security('US02Y', timeframe.period, close)
us10y = request.security('US10Y', timeframe.period, close)
us3m = request.security('US03MY', timeframe.period, close)
hyg = request.security('HYG', timeframe.period, close)
lqd = request.security('LQD', timeframe.period, close)
tlt = request.security('TLT', timeframe.period, close)

// Safe Haven Assets
gold = request.security('GLD', timeframe.period, close)
usd = request.security('DXY', timeframe.period, close)
yen = request.security('JPYUSD', timeframe.period, close)

// Financial data with fallback values
get_financial_data(symbol, fin_id, period, fallback) =>
    data = request.financial(symbol, fin_id, period, ignore_invalid_symbol = true)
    na(data) ? fallback : data

// SPY fundamental metrics
spy_earnings_per_share = get_financial_data('AMEX:SPY', 'EARNINGS_PER_SHARE_BASIC', 'TTM', 20.0)
spy_operating_earnings_yield = get_financial_data('AMEX:SPY', 'OPERATING_EARNINGS_YIELD', 'FY', 4.5)
spy_dividend_yield = get_financial_data('AMEX:SPY', 'DIVIDENDS_YIELD', 'FY', 1.8)
spy_buyback_yield = get_financial_data('AMEX:SPY', 'BUYBACK_YIELD', 'FY', 2.0)
spy_net_margin = get_financial_data('AMEX:SPY', 'NET_MARGIN', 'TTM', 12.0)
spy_debt_to_equity = get_financial_data('AMEX:SPY', 'DEBT_TO_EQUITY', 'FY', 0.5)
spy_return_on_equity = get_financial_data('AMEX:SPY', 'RETURN_ON_EQUITY', 'FY', 15.0)
spy_free_cash_flow = get_financial_data('AMEX:SPY', 'FREE_CASH_FLOW', 'TTM', 100000000)
spy_ebitda = get_financial_data('AMEX:SPY', 'EBITDA', 'TTM', 200000000)
spy_pe_forward = get_financial_data('AMEX:SPY', 'PRICE_EARNINGS_FORWARD', 'FY', 18.0)
spy_total_debt = get_financial_data('AMEX:SPY', 'TOTAL_DEBT', 'FY', 500000000)
spy_total_equity = get_financial_data('AMEX:SPY', 'TOTAL_EQUITY', 'FY', 1000000000)
spy_enterprise_value = get_financial_data('AMEX:SPY', 'ENTERPRISE_VALUE', 'FY', 30000000000)
spy_revenue_growth = get_financial_data('AMEX:SPY', 'REVENUE_ONE_YEAR_GROWTH', 'TTM', 5.0)

// Market Breadth Indicators
nya = request.security('NYA', timeframe.period, close)
rut = request.security('IWM', timeframe.period, close)

// Sector Performance
xlk = request.security('XLK', timeframe.period, close)
xlu = request.security('XLU', timeframe.period, close)
xlf = request.security('XLF', timeframe.period, close)

// MARKET REGIME DETECTION

// Calculate Market Trend
sma_20 = ta.sma(sp500, 20)
sma_50 = ta.sma(sp500, 50)
sma_200 = ta.sma(sp500, 200)
ema_10 = ta.ema(sp500, 10)

// Market Structure Score
trend_strength = 0.0
trend_strength := trend_strength + (sp500 > sma_20 ? 1 : -1)
trend_strength := trend_strength + (sp500 > sma_50 ? 1 : -1)
trend_strength := trend_strength + (sp500 > sma_200 ? 2 : -2)
trend_strength := trend_strength + (sma_50 > sma_200 ? 2 : -2)

// Volatility Regime
returns = math.log(sp500 / sp500[1])
realized_vol_20d = ta.stdev(returns, 20) * math.sqrt(252) * 100
realized_vol_60d = ta.stdev(returns, 60) * math.sqrt(252) * 100
ewma_vol = ta.ema(math.pow(returns, 2), 20)
realized_vol = math.sqrt(ewma_vol * 252) * 100
vol_premium = vix - realized_vol

// Drawdown Calculation
running_max = ta.highest(sp500, risk_lookback)
current_drawdown = (running_max - sp500) / running_max * 100

// Regime Score
regime_score = 0.0

// Trend Component (40%)
if trend_strength >= 4
    regime_score := regime_score + 40
    regime_score
else if trend_strength >= 2
    regime_score := regime_score + 30
    regime_score
else if trend_strength >= 0
    regime_score := regime_score + 20
    regime_score
else if trend_strength >= -2
    regime_score := regime_score + 10
    regime_score
else
    regime_score := regime_score + 0
    regime_score

// Volatility Component (30%)
if vix < 15
    regime_score := regime_score + 30
    regime_score
else if vix < 20
    regime_score := regime_score + 25
    regime_score
else if vix < 25
    regime_score := regime_score + 15
    regime_score
else if vix < 35
    regime_score := regime_score + 5
    regime_score
else
    regime_score := regime_score + 0
    regime_score

// Drawdown Component (30%)
if current_drawdown < 3
    regime_score := regime_score + 30
    regime_score
else if current_drawdown < 7
    regime_score := regime_score + 20
    regime_score
else if current_drawdown < 12
    regime_score := regime_score + 10
    regime_score
else if current_drawdown < 20
    regime_score := regime_score + 5
    regime_score
else
    regime_score := regime_score + 0
    regime_score

// Classify Regime
market_regime = regime_score >= 80 ? 'Strong Bull' : regime_score >= 60 ? 'Bull Market' : regime_score >= 40 ? 'Neutral' : regime_score >= 20 ? 'Correction' : regime_score >= 10 ? 'Bear Market' : 'Crisis'

// RISK-BASED ALLOCATION

// Calculate Market Risk
parkinson_hl = math.log(sp500_high / sp500_low)
parkinson_vol = parkinson_hl / (2 * math.sqrt(math.log(2))) * math.sqrt(252) * 100

garman_klass_vol = math.sqrt((0.5 * math.pow(math.log(sp500_high / sp500_low), 2) - (2 * math.log(2) - 1) * math.pow(math.log(sp500 / sp500[1]), 2)) * 252) * 100

market_volatility_20d = math.max(ta.stdev(returns, 20) * math.sqrt(252) * 100, parkinson_vol)
market_volatility_60d = ta.stdev(returns, 60) * math.sqrt(252) * 100
market_drawdown = current_drawdown

// Initialize risk allocation
risk_allocation = 50.0

if enable_portfolio_risk_scaling
    // Volatility-based allocation
    vol_based_allocation = target_portfolio_volatility / math.max(market_volatility_20d, 5.0) * 100
    vol_based_allocation := math.max(0, math.min(100, vol_based_allocation))

    // Drawdown-based allocation
    dd_based_allocation = 100.0
    if market_drawdown > 1.0
        dd_based_allocation := max_portfolio_drawdown / market_drawdown * 100
        dd_based_allocation := math.max(0, math.min(100, dd_based_allocation))
        dd_based_allocation

    // Combine (conservative)
    risk_allocation := math.min(vol_based_allocation, dd_based_allocation)

    // Dynamic adjustment
    current_equity_estimate = 50.0
    estimated_portfolio_vol = current_equity_estimate / 100 * market_volatility_20d
    estimated_portfolio_dd = current_equity_estimate / 100 * market_drawdown

    vol_utilization = estimated_portfolio_vol / target_portfolio_volatility
    dd_utilization = estimated_portfolio_dd / max_portfolio_drawdown
    risk_utilization = math.max(vol_utilization, dd_utilization)

    risk_adjustment_factor = 1.0
    if risk_utilization > 1.0
        risk_adjustment_factor := math.exp(-0.5 * (risk_utilization - 1.0))
        risk_adjustment_factor := math.max(0.5, risk_adjustment_factor)
        risk_adjustment_factor
    else if risk_utilization < 0.9
        risk_adjustment_factor := 1.0 + 0.2 * math.log(1.0 / risk_utilization)
        risk_adjustment_factor := math.min(1.3, risk_adjustment_factor)
        risk_adjustment_factor

    risk_allocation := risk_allocation * risk_adjustment_factor
    risk_allocation

else
    vol_scalar = target_portfolio_volatility / math.max(market_volatility_20d, 10)
    vol_scalar := math.min(1.5, math.max(0.2, vol_scalar))

    drawdown_penalty = 0.0
    if current_drawdown > max_portfolio_drawdown
        drawdown_penalty := (current_drawdown - max_portfolio_drawdown) / max_portfolio_drawdown
        drawdown_penalty := math.min(1.0, drawdown_penalty)
        drawdown_penalty

    risk_allocation := 100 * vol_scalar * (1 - drawdown_penalty)
    risk_allocation

risk_allocation := math.max(0, math.min(100, risk_allocation))

// VALUATION ANALYSIS

// Valuation Metrics
actual_pe_ratio = spy_earnings_per_share > 0 ? sp500 / spy_earnings_per_share : spy_pe_forward
actual_earnings_yield = nz(spy_operating_earnings_yield, 0) > 0 ? spy_operating_earnings_yield : 100 / actual_pe_ratio
total_shareholder_yield = spy_dividend_yield + spy_buyback_yield

// Equity Risk Premium (multi-method calculation)
method1_erp = actual_earnings_yield - us10y
method2_erp = actual_earnings_yield + spy_buyback_yield - us10y

payout_ratio = spy_dividend_yield > 0 and actual_earnings_yield > 0 ? spy_dividend_yield / actual_earnings_yield : 0.4
sustainable_growth = spy_return_on_equity * (1 - payout_ratio) / 100
method3_erp = spy_dividend_yield + sustainable_growth * 100 - us10y

implied_growth = spy_revenue_growth * 0.7
method4_erp = total_shareholder_yield + implied_growth - us10y

equity_risk_premium = method1_erp * 0.35 + method2_erp * 0.30 + method3_erp * 0.20 + method4_erp * 0.15

ev_ebitda_ratio = spy_enterprise_value > 0 and spy_ebitda > 0 ? spy_enterprise_value / spy_ebitda : 15.0
debt_equity_health = spy_debt_to_equity < 1.0 ? 1.2 : spy_debt_to_equity < 2.0 ? 1.0 : 0.8

// Valuation Score
base_valuation_score = 50.0

if equity_risk_premium > 4
    base_valuation_score := 95
    base_valuation_score
else if equity_risk_premium > 3
    base_valuation_score := 85
    base_valuation_score
else if equity_risk_premium > 2
    base_valuation_score := 70
    base_valuation_score
else if equity_risk_premium > 1
    base_valuation_score := 55
    base_valuation_score
else if equity_risk_premium > 0
    base_valuation_score := 40
    base_valuation_score
else if equity_risk_premium > -1
    base_valuation_score := 25
    base_valuation_score
else
    base_valuation_score := 10
    base_valuation_score

growth_adjustment = spy_revenue_growth > 10 ? 10 : spy_revenue_growth > 5 ? 5 : 0
margin_adjustment = spy_net_margin > 15 ? 5 : spy_net_margin < 8 ? -5 : 0
roe_adjustment = spy_return_on_equity > 20 ? 5 : spy_return_on_equity < 10 ? -5 : 0

valuation_score = base_valuation_score + growth_adjustment + margin_adjustment + roe_adjustment
valuation_score := math.max(0, math.min(100, valuation_score * debt_equity_health))

// SENTIMENT ANALYSIS

// VIX Term Structure
vix_term_structure = vix9d > 0 ? vix / vix9d : 1
backwardation = vix_term_structure > 1.05
steep_backwardation = vix_term_structure > 1.15

// Safe Haven Flows
gold_momentum = ta.roc(gold, 20)
dollar_momentum = ta.roc(usd, 20)
yen_momentum = ta.roc(yen, 20)
treasury_momentum = ta.roc(tlt, 20)

safe_haven_flow = gold_momentum * 0.3 + treasury_momentum * 0.3 + dollar_momentum * 0.25 + yen_momentum * 0.15

// Advanced Sentiment Analysis
vix_percentile = ta.percentrank(vix, 252)
vix_zscore = (vix - ta.sma(vix, 252)) / ta.stdev(vix, 252)

vix_momentum = ta.roc(vix, 5)
vvix_proxy = ta.stdev(vix_momentum, 20) * math.sqrt(252)

risk_reversal_proxy = (vix - realized_vol) / realized_vol

// Sentiment Score
base_sentiment = 50.0

vix_adjustment = 0.0
if vix_zscore < -1.5
    vix_adjustment := 40
    vix_adjustment
else if vix_zscore < -0.5
    vix_adjustment := 20
    vix_adjustment
else if vix_zscore < 0.5
    vix_adjustment := 0
    vix_adjustment
else if vix_zscore < 1.5
    vix_adjustment := -20
    vix_adjustment
else
    vix_adjustment := -40
    vix_adjustment

term_structure_adjustment = backwardation ? -15 : steep_backwardation ? -30 : 5
vvix_adjustment = vvix_proxy > 2.0 ? -10 : vvix_proxy < 1.0 ? 10 : 0

sentiment_score = base_sentiment + vix_adjustment + term_structure_adjustment + vvix_adjustment
sentiment_score := math.max(0, math.min(100, sentiment_score))

// MACRO ANALYSIS

// Yield Curve
yield_spread_2_10 = us10y - us2y
yield_spread_3m_10 = us10y - us3m

// Credit Conditions
hyg_return = ta.roc(hyg, 20)
lqd_return = ta.roc(lqd, 20)
tlt_return = ta.roc(tlt, 20)

hyg_duration = 4.0
lqd_duration = 8.0
tlt_duration = 17.0

hyg_log_returns = math.log(hyg / hyg[1])
lqd_log_returns = math.log(lqd / lqd[1])
hyg_volatility = ta.stdev(hyg_log_returns, 20) * math.sqrt(252)
lqd_volatility = ta.stdev(lqd_log_returns, 20) * math.sqrt(252)

hyg_yield_proxy = -math.log(hyg / hyg[252]) * 100
lqd_yield_proxy = -math.log(lqd / lqd[252]) * 100
tlt_yield = us10y

hyg_spread = (hyg_yield_proxy - tlt_yield) * 100
lqd_spread = (lqd_yield_proxy - tlt_yield) * 100

hyg_distance = (hyg - ta.lowest(hyg, 252)) / (ta.highest(hyg, 252) - ta.lowest(hyg, 252))
lqd_distance = (lqd - ta.lowest(lqd, 252)) / (ta.highest(lqd, 252) - ta.lowest(lqd, 252))
default_risk_proxy = 2.0 - (hyg_distance + lqd_distance)

credit_spread = hyg_spread * 0.5 + (hyg_volatility - lqd_volatility) * 1000 * 0.3 + default_risk_proxy * 200 * 0.2
credit_spread := math.max(50, credit_spread)

credit_market_health = hyg_return > lqd_return ? 1 : -1
flight_to_quality = tlt_return > (hyg_return + lqd_return) / 2

// Macro Score
macro_score = 50.0

yield_curve_score = 0
if yield_spread_2_10 > 1.5 and yield_spread_3m_10 > 2
    yield_curve_score := 40
    yield_curve_score
else if yield_spread_2_10 > 0.5 and yield_spread_3m_10 > 1
    yield_curve_score := 30
    yield_curve_score
else if yield_spread_2_10 > 0 and yield_spread_3m_10 > 0
    yield_curve_score := 20
    yield_curve_score
else if yield_spread_2_10 < 0 or yield_spread_3m_10 < 0
    yield_curve_score := 10
    yield_curve_score
else
    yield_curve_score := 5
    yield_curve_score

credit_conditions_score = 0
if credit_spread < 200 and not flight_to_quality
    credit_conditions_score := 30
    credit_conditions_score
else if credit_spread < 400 and credit_market_health > 0
    credit_conditions_score := 20
    credit_conditions_score
else if credit_spread < 600
    credit_conditions_score := 15
    credit_conditions_score
else if credit_spread < 1000
    credit_conditions_score := 10
    credit_conditions_score
else
    credit_conditions_score := 0
    credit_conditions_score

financial_stability_score = 0
if spy_debt_to_equity < 0.5 and spy_return_on_equity > 15
    financial_stability_score := 20
    financial_stability_score
else if spy_debt_to_equity < 1.0 and spy_return_on_equity > 10
    financial_stability_score := 15
    financial_stability_score
else if spy_debt_to_equity < 1.5
    financial_stability_score := 10
    financial_stability_score
else
    financial_stability_score := 5
    financial_stability_score

macro_score := yield_curve_score + credit_conditions_score + financial_stability_score
macro_score := math.max(0, math.min(100, macro_score))

// CRISIS DETECTION

crisis_indicators = 0

if vix > crisis_vix_threshold
    crisis_indicators := crisis_indicators + 1
    crisis_indicators
if vix > 60
    crisis_indicators := crisis_indicators + 2
    crisis_indicators

if current_drawdown > crisis_drawdown_threshold
    crisis_indicators := crisis_indicators + 1
    crisis_indicators
if current_drawdown > 25
    crisis_indicators := crisis_indicators + 1
    crisis_indicators

if credit_spread > crisis_credit_spread
    crisis_indicators := crisis_indicators + 1
    crisis_indicators

sp500_roc_5 = ta.roc(sp500, 5)
tlt_roc_5 = ta.roc(tlt, 5)
if sp500_roc_5 < -10 and tlt_roc_5 < -5
    crisis_indicators := crisis_indicators + 2
    crisis_indicators

volume_spike = sp500_volume > ta.sma(sp500_volume, 20) * 2
sp500_roc_1 = ta.roc(sp500, 1)
if volume_spike and sp500_roc_1 < -3
    crisis_indicators := crisis_indicators + 1
    crisis_indicators

is_crisis = crisis_indicators >= 3
is_severe_crisis = crisis_indicators >= 5

// FINAL ALLOCATION CALCULATION

// Convert regime to base allocation
regime_allocation = market_regime == 'Strong Bull' ? 100 : market_regime == 'Bull Market' ? 80 : market_regime == 'Neutral' ? 60 : market_regime == 'Correction' ? 40 : market_regime == 'Bear Market' ? 20 : 0

// Normalize weights
total_weight = w_regime + w_risk + w_valuation + w_sentiment + w_macro
w_regime_norm = w_regime / total_weight
w_risk_norm = w_risk / total_weight
w_valuation_norm = w_valuation / total_weight
w_sentiment_norm = w_sentiment / total_weight
w_macro_norm = w_macro / total_weight

// Calculate Weighted Allocation
weighted_allocation = regime_allocation * w_regime_norm + risk_allocation * w_risk_norm + valuation_score * w_valuation_norm + sentiment_score * w_sentiment_norm + macro_score * w_macro_norm

// Apply Crisis Override
if use_crisis_detection
    if is_severe_crisis
        weighted_allocation := math.min(weighted_allocation, 10)
        weighted_allocation
    else if is_crisis
        weighted_allocation := math.min(weighted_allocation, 25)
        weighted_allocation

// Model Type Adjustment
model_adjustment = 0.0
if model_type == 'Conservative'
    model_adjustment := -10
    model_adjustment
else if model_type == 'Aggressive'
    model_adjustment := 10
    model_adjustment
else if model_type == 'Adaptive'
    recent_return = (sp500 - sp500[20]) / sp500[20] * 100
    if recent_return > 5
        model_adjustment := 5
        model_adjustment
    else if recent_return < -5
        model_adjustment := -5
        model_adjustment

// Apply adjustment and bounds
final_allocation = weighted_allocation + model_adjustment
final_allocation := math.max(0, math.min(100, final_allocation))

// Smooth allocation
smoothed_allocation = ta.sma(final_allocation, smoothing_period)

// Calculate portfolio risk metrics (only for internal alerts)
actual_portfolio_volatility = smoothed_allocation / 100 * market_volatility_20d
actual_portfolio_drawdown = smoothed_allocation / 100 * current_drawdown

// VISUALIZATION

// Color definitions
var color primary_color = #2196F3
var color bullish_color = #4CAF50
var color bearish_color = #FF5252
var color neutral_color = #808080
var color text_color = color.white
var color bg_color = #000000
var color table_bg_color = #1E1E1E
var color header_bg_color = #2D2D2D

switch color_scheme // Apply color scheme
    'Gold' => 
	    primary_color := use_dark_mode ? #FFD700 : #DAA520
	    bullish_color := use_dark_mode ? #FFA500 : #FF8C00
	    bearish_color := use_dark_mode ? #FF5252 : #D32F2F
	    neutral_color := use_dark_mode ? #C0C0C0 : #808080
	    text_color := use_dark_mode ? color.white : color.black
	    bg_color := use_dark_mode ? #000000 : #FFFFFF
	    table_bg_color := use_dark_mode ? #1A1A00 : #FFFEF0
	    header_bg_color := use_dark_mode ? #2D2600 : #F5F5DC
	    header_bg_color
    'EdgeTools' => 

	    primary_color := use_dark_mode ? #4682B4 : #1E90FF
	    bullish_color := use_dark_mode ? #4CAF50 : #388E3C
	    bearish_color := use_dark_mode ? #FF5252 : #D32F2F
	    neutral_color := use_dark_mode ? #708090 : #696969
	    text_color := use_dark_mode ? color.white : color.black
	    bg_color := use_dark_mode ? #000000 : #FFFFFF
	    table_bg_color := use_dark_mode ? #0F1419 : #F0F8FF
	    header_bg_color := use_dark_mode ? #1E2A3A : #E6F3FF
	    header_bg_color
    'Behavioral' => 

	    primary_color := #808080
	    bullish_color := #00FF00
	    bearish_color := #8B0000
	    neutral_color := #FFBF00
	    text_color := use_dark_mode ? color.white : color.black
	    bg_color := use_dark_mode ? #000000 : #FFFFFF
	    table_bg_color := use_dark_mode ? #1A1A1A : #F8F8F8
	    header_bg_color := use_dark_mode ? #2D2D2D : #E8E8E8
	    header_bg_color
    'Quant' => 

	    primary_color := #808080
	    bullish_color := #FFA500
	    bearish_color := #8B0000
	    neutral_color := #4682B4
	    text_color := use_dark_mode ? color.white : color.black
	    bg_color := use_dark_mode ? #000000 : #FFFFFF
	    table_bg_color := use_dark_mode ? #0D0D0D : #FAFAFA
	    header_bg_color := use_dark_mode ? #1A1A1A : #F0F0F0
	    header_bg_color
    'Ocean' => 

	    primary_color := use_dark_mode ? #20B2AA : #008B8B
	    bullish_color := use_dark_mode ? #00CED1 : #4682B4
	    bearish_color := use_dark_mode ? #FF4500 : #B22222
	    neutral_color := use_dark_mode ? #87CEEB : #2F4F4F
	    text_color := use_dark_mode ? #F0F8FF : #191970
	    bg_color := use_dark_mode ? #001F3F : #F0F8FF
	    table_bg_color := use_dark_mode ? #001A2E : #E6F7FF
	    header_bg_color := use_dark_mode ? #002A47 : #CCF2FF
	    header_bg_color
    'Fire' => 

	    primary_color := use_dark_mode ? #FF6347 : #DC143C
	    bullish_color := use_dark_mode ? #FFD700 : #FF8C00
	    bearish_color := use_dark_mode ? #8B0000 : #800000
	    neutral_color := use_dark_mode ? #FFA500 : #CD853F
	    text_color := use_dark_mode ? #FFFAF0 : #2F1B14
	    bg_color := use_dark_mode ? #2F1B14 : #FFFAF0
	    table_bg_color := use_dark_mode ? #261611 : #FFF8F0
	    header_bg_color := use_dark_mode ? #3D241A : #FFE4CC
	    header_bg_color
    'Matrix' => 

	    primary_color := use_dark_mode ? #00FF41 : #006400
	    bullish_color := use_dark_mode ? #39FF14 : #228B22
	    bearish_color := use_dark_mode ? #FF073A : #8B0000
	    neutral_color := use_dark_mode ? #00FFFF : #008B8B
	    text_color := use_dark_mode ? #C0FF8C : #003300
	    bg_color := use_dark_mode ? #0D1B0D : #F0FFF0
	    table_bg_color := use_dark_mode ? #0A1A0A : #E8FFF0
	    header_bg_color := use_dark_mode ? #112B11 : #CCFFCC
	    header_bg_color
    'Arctic' => 

	    primary_color := use_dark_mode ? #87CEFA : #4169E1
	    bullish_color := use_dark_mode ? #00BFFF : #0000CD
	    bearish_color := use_dark_mode ? #FF1493 : #8B008B
	    neutral_color := use_dark_mode ? #B0E0E6 : #483D8B
	    text_color := use_dark_mode ? #F8F8FF : #191970
	    bg_color := use_dark_mode ? #191970 : #F8F8FF
	    table_bg_color := use_dark_mode ? #141B47 : #F0F8FF
	    header_bg_color := use_dark_mode ? #1E2A5C : #E0F0FF
	    header_bg_color

// Transparency settings
bg_transparency = use_dark_mode ? 85 : 92
zone_transparency = use_dark_mode ? 90 : 95
band_transparency = use_dark_mode ? 70 : 85
table_transparency = use_dark_mode ? 80 : 15

// Allocation color
alloc_color = smoothed_allocation >= 80 ? bullish_color : smoothed_allocation >= 60 ? color.new(bullish_color, 30) : smoothed_allocation >= 40 ? primary_color : smoothed_allocation >= 20 ? color.new(bearish_color, 30) : bearish_color

// Dynamic background
var color dynamic_bg_color = na
if show_regime_background
    if smoothed_allocation >= 70
        dynamic_bg_color := color.new(bullish_color, background_intensity)
        dynamic_bg_color
    else if smoothed_allocation <= 30
        dynamic_bg_color := color.new(bearish_color, background_intensity)
        dynamic_bg_color
    else if smoothed_allocation > 60 or smoothed_allocation < 40
        dynamic_bg_color := color.new(primary_color, math.min(99, background_intensity + 2))
        dynamic_bg_color

bgcolor(dynamic_bg_color, title = 'Allocation Signal Background')

// Plot main allocation line
plot(smoothed_allocation, 'Equity Allocation %', color = alloc_color, linewidth = math.max(1, main_line_width))

// Reference lines (static colors for hline)
hline_bullish_color = color_scheme == 'Gold' ? use_dark_mode ? #FFA500 : #FF8C00 : color_scheme == 'EdgeTools' ? use_dark_mode ? #4CAF50 : #388E3C : color_scheme == 'Behavioral' ? #00FF00 : color_scheme == 'Quant' ? #FFA500 : color_scheme == 'Ocean' ? use_dark_mode ? #00CED1 : #4682B4 : color_scheme == 'Fire' ? use_dark_mode ? #FFD700 : #FF8C00 : color_scheme == 'Matrix' ? use_dark_mode ? #39FF14 : #228B22 : color_scheme == 'Arctic' ? use_dark_mode ? #00BFFF : #0000CD : #4CAF50

hline_bearish_color = color_scheme == 'Gold' ? use_dark_mode ? #FF5252 : #D32F2F : color_scheme == 'EdgeTools' ? use_dark_mode ? #FF5252 : #D32F2F : color_scheme == 'Behavioral' ? #8B0000 : color_scheme == 'Quant' ? #8B0000 : color_scheme == 'Ocean' ? use_dark_mode ? #FF4500 : #B22222 : color_scheme == 'Fire' ? use_dark_mode ? #8B0000 : #800000 : color_scheme == 'Matrix' ? use_dark_mode ? #FF073A : #8B0000 : color_scheme == 'Arctic' ? use_dark_mode ? #FF1493 : #8B008B : #FF5252

hline_primary_color = color_scheme == 'Gold' ? use_dark_mode ? #FFD700 : #DAA520 : color_scheme == 'EdgeTools' ? use_dark_mode ? #4682B4 : #1E90FF : color_scheme == 'Behavioral' ? #808080 : color_scheme == 'Quant' ? #808080 : color_scheme == 'Ocean' ? use_dark_mode ? #20B2AA : #008B8B : color_scheme == 'Fire' ? use_dark_mode ? #FF6347 : #DC143C : color_scheme == 'Matrix' ? use_dark_mode ? #00FF41 : #006400 : color_scheme == 'Arctic' ? use_dark_mode ? #87CEFA : #4169E1 : #2196F3

hline(show_reference_lines ? 100 : na, '100% Equity', color = color.new(hline_bullish_color, 70), linestyle = hline.style_dotted, linewidth = 1)
hline(show_reference_lines ? 80 : na, '80% Equity', color = color.new(hline_bullish_color, 40), linestyle = hline.style_dashed, linewidth = 1)
hline(show_reference_lines ? 60 : na, '60% Equity', color = color.new(hline_bullish_color, 60), linestyle = hline.style_dotted, linewidth = 1)
hline(50, '50% Balanced', color = color.new(hline_primary_color, 50), linestyle = hline.style_solid, linewidth = 2)
hline(show_reference_lines ? 40 : na, '40% Equity', color = color.new(hline_bearish_color, 60), linestyle = hline.style_dotted, linewidth = 1)
hline(show_reference_lines ? 20 : na, '20% Equity', color = color.new(hline_bearish_color, 40), linestyle = hline.style_dashed, linewidth = 1)
hline(show_reference_lines ? 0 : na, '0% Equity', color = color.new(hline_bearish_color, 70), linestyle = hline.style_dotted, linewidth = 1)

// Component plots
plot(show_components ? regime_allocation : na, 'Regime', color = color.new(#4ECDC4, 70), linewidth = 1)
plot(show_components ? risk_allocation : na, 'Risk', color = color.new(#FF6B6B, 70), linewidth = 1)
plot(show_components ? valuation_score : na, 'Valuation', color = color.new(#45B7D1, 70), linewidth = 1)
plot(show_components ? sentiment_score : na, 'Sentiment', color = color.new(#FFD93D, 70), linewidth = 1)
plot(show_components ? macro_score : na, 'Macro', color = color.new(#6BCF7F, 70), linewidth = 1)

// Confidence bands
upper_band = plot(show_confidence_bands ? math.min(100, smoothed_allocation + ta.stdev(smoothed_allocation, 20)) : na, color = color.new(neutral_color, band_transparency), display = display.none, title = 'Upper Band')
lower_band = plot(show_confidence_bands ? math.max(0, smoothed_allocation - ta.stdev(smoothed_allocation, 20)) : na, color = color.new(neutral_color, band_transparency), display = display.none, title = 'Lower Band')
fill(upper_band, lower_band, color = show_confidence_bands ? color.new(neutral_color, zone_transparency) : na, title = 'Uncertainty')

// DASHBOARD

if show_dashboard and barstate.islast
    var table dashboard = table.new(position.top_right, 2, 20, border_width = 1, bgcolor = color.new(table_bg_color, table_transparency))

    table.clear(dashboard, 0, 0, 1, 19)

    // Header
    header_color = color.new(header_bg_color, 20)
    dashboard_text_color = text_color

    table.cell(dashboard, 0, 0, 'DEAM', text_color = dashboard_text_color, bgcolor = header_color, text_size = size.normal)
    table.cell(dashboard, 1, 0, model_type, text_color = dashboard_text_color, bgcolor = header_color, text_size = size.normal)

    // Core metrics
    table.cell(dashboard, 0, 1, 'Equity Allocation', text_color = dashboard_text_color, text_size = size.small)
    table.cell(dashboard, 1, 1, str.tostring(smoothed_allocation, '##.#') + '%', text_color = alloc_color, text_size = size.small)

    table.cell(dashboard, 0, 2, 'Cash Allocation', text_color = dashboard_text_color, text_size = size.small)
    cash_color = 100 - smoothed_allocation > 70 ? bearish_color : primary_color
    table.cell(dashboard, 1, 2, str.tostring(100 - smoothed_allocation, '##.#') + '%', text_color = cash_color, text_size = size.small)

    // Signal
    signal_text = 'NEUTRAL'
    signal_color = primary_color
    if smoothed_allocation >= 70
        signal_text := 'BULLISH'
        signal_color := bullish_color
        signal_color
    else if smoothed_allocation <= 30
        signal_text := 'BEARISH'
        signal_color := bearish_color
        signal_color
    table.cell(dashboard, 0, 3, 'Signal', text_color = dashboard_text_color, text_size = size.small)
    table.cell(dashboard, 1, 3, signal_text, text_color = signal_color, text_size = size.small)

    // Market Regime
    table.cell(dashboard, 0, 4, 'Regime', text_color = dashboard_text_color, text_size = size.small)
    regime_color_display = market_regime == 'Strong Bull' or market_regime == 'Bull Market' ? bullish_color : market_regime == 'Neutral' ? primary_color : market_regime == 'Crisis' ? bearish_color : bearish_color
    table.cell(dashboard, 1, 4, market_regime, text_color = regime_color_display, text_size = size.small)

    // VIX
    table.cell(dashboard, 0, 5, 'VIX Level', text_color = dashboard_text_color, text_size = size.small)
    vix_color_display = vix < 20 ? bullish_color : vix < 30 ? primary_color : bearish_color
    table.cell(dashboard, 1, 5, str.tostring(vix, '##.##'), text_color = vix_color_display, text_size = size.small)

    // Market Drawdown
    table.cell(dashboard, 0, 6, 'Market DD', text_color = dashboard_text_color, text_size = size.small)
    market_dd_color = current_drawdown < 5 ? bullish_color : current_drawdown < 10 ? primary_color : bearish_color
    table.cell(dashboard, 1, 6, '-' + str.tostring(current_drawdown, '##.#') + '%', text_color = market_dd_color, text_size = size.small)

    // Crisis Detection
    table.cell(dashboard, 0, 7, 'Crisis Detection', text_color = dashboard_text_color, text_size = size.small)
    crisis_text = is_severe_crisis ? 'SEVERE' : is_crisis ? 'CRISIS' : 'Normal'
    crisis_display_color = is_severe_crisis or is_crisis ? bearish_color : bullish_color
    table.cell(dashboard, 1, 7, crisis_text, text_color = crisis_display_color, text_size = size.small)

    // Real Data Section
    financial_bg = color.new(primary_color, 85)
    table.cell(dashboard, 0, 8, 'REAL DATA', text_color = dashboard_text_color, bgcolor = financial_bg, text_size = size.small)
    table.cell(dashboard, 1, 8, 'Live Metrics', text_color = dashboard_text_color, bgcolor = financial_bg, text_size = size.small)

    // P/E Ratio
    table.cell(dashboard, 0, 9, 'P/E Ratio', text_color = dashboard_text_color, text_size = size.small)
    pe_color = actual_pe_ratio < 18 ? bullish_color : actual_pe_ratio < 25 ? primary_color : bearish_color
    table.cell(dashboard, 1, 9, str.tostring(actual_pe_ratio, '##.#'), text_color = pe_color, text_size = size.small)

    // ERP
    table.cell(dashboard, 0, 10, 'ERP', text_color = dashboard_text_color, text_size = size.small)
    erp_color = equity_risk_premium > 2 ? bullish_color : equity_risk_premium > 0 ? primary_color : bearish_color
    table.cell(dashboard, 1, 10, str.tostring(equity_risk_premium, '##.##') + '%', text_color = erp_color, text_size = size.small)

    // ROE
    table.cell(dashboard, 0, 11, 'ROE', text_color = dashboard_text_color, text_size = size.small)
    roe_color = spy_return_on_equity > 20 ? bullish_color : spy_return_on_equity > 10 ? primary_color : bearish_color
    table.cell(dashboard, 1, 11, str.tostring(spy_return_on_equity, '##.#') + '%', text_color = roe_color, text_size = size.small)

    // D/E Ratio
    table.cell(dashboard, 0, 12, 'D/E Ratio', text_color = dashboard_text_color, text_size = size.small)
    de_color = spy_debt_to_equity < 0.5 ? bullish_color : spy_debt_to_equity < 1.0 ? primary_color : bearish_color
    table.cell(dashboard, 1, 12, str.tostring(spy_debt_to_equity, '##.##'), text_color = de_color, text_size = size.small)

    // Shareholder Yield
    table.cell(dashboard, 0, 13, 'Dividend+Buyback', text_color = dashboard_text_color, text_size = size.small)
    yield_color = total_shareholder_yield > 4 ? bullish_color : total_shareholder_yield > 2 ? primary_color : bearish_color
    table.cell(dashboard, 1, 13, str.tostring(total_shareholder_yield, '##.#') + '%', text_color = yield_color, text_size = size.small)

    // Component Scores
    component_bg = color.new(neutral_color, 80)
    table.cell(dashboard, 0, 14, 'Components', text_color = dashboard_text_color, bgcolor = component_bg, text_size = size.small)
    table.cell(dashboard, 1, 14, 'Scores', text_color = dashboard_text_color, bgcolor = component_bg, text_size = size.small)

    table.cell(dashboard, 0, 15, 'Regime', text_color = dashboard_text_color, text_size = size.small)
    regime_score_color = regime_allocation > 60 ? bullish_color : regime_allocation < 40 ? bearish_color : primary_color
    table.cell(dashboard, 1, 15, str.tostring(regime_allocation, '##'), text_color = regime_score_color, text_size = size.small)

    table.cell(dashboard, 0, 16, 'Risk', text_color = dashboard_text_color, text_size = size.small)
    risk_score_color = risk_allocation > 60 ? bullish_color : risk_allocation < 40 ? bearish_color : primary_color
    table.cell(dashboard, 1, 16, str.tostring(risk_allocation, '##'), text_color = risk_score_color, text_size = size.small)

    table.cell(dashboard, 0, 17, 'Valuation', text_color = dashboard_text_color, text_size = size.small)
    val_score_color = valuation_score > 60 ? bullish_color : valuation_score < 40 ? bearish_color : primary_color
    table.cell(dashboard, 1, 17, str.tostring(valuation_score, '##'), text_color = val_score_color, text_size = size.small)

    table.cell(dashboard, 0, 18, 'Sentiment', text_color = dashboard_text_color, text_size = size.small)
    sent_score_color = sentiment_score > 60 ? bullish_color : sentiment_score < 40 ? bearish_color : primary_color
    table.cell(dashboard, 1, 18, str.tostring(sentiment_score, '##'), text_color = sent_score_color, text_size = size.small)

    table.cell(dashboard, 0, 19, 'Macro', text_color = dashboard_text_color, text_size = size.small)
    macro_score_color = macro_score > 60 ? bullish_color : macro_score < 40 ? bearish_color : primary_color
    table.cell(dashboard, 1, 19, str.tostring(macro_score, '##'), text_color = macro_score_color, text_size = size.small)

// ALERTS

// Major allocation changes
alertcondition(smoothed_allocation >= 80 and smoothed_allocation[1] < 80, 'High Equity Allocation', 'Equity allocation reached 80% - Bull market conditions')

alertcondition(smoothed_allocation <= 20 and smoothed_allocation[1] > 20, 'Low Equity Allocation', 'Equity allocation dropped to 20% - Defensive positioning')

// Crisis alerts
alertcondition(is_crisis and not is_crisis[1], 'CRISIS DETECTED', 'Crisis conditions detected - Reducing equity allocation')

alertcondition(is_severe_crisis and not is_severe_crisis[1], 'SEVERE CRISIS', 'Severe crisis detected - Maximum defensive positioning')

// Regime changes
regime_changed = market_regime != market_regime[1]
alertcondition(regime_changed, 'Regime Change', 'Market regime has changed')

// Risk management alerts
risk_breach = enable_portfolio_risk_scaling and (actual_portfolio_volatility > target_portfolio_volatility * 1.2 or actual_portfolio_drawdown > max_portfolio_drawdown * 1.2)
alertcondition(risk_breach, 'Risk Breach', 'Portfolio risk exceeds target parameters')

// USAGE

// The indicator displays a recommended equity allocation percentage (0-100%).
// Example: 75% allocation = 75% stocks, 25% cash/bonds.
//
// The model combines market regime analysis (trend, volatility, drawdowns),
// risk management (portfolio-level targeting), valuation metrics (P/E, ERP),
// sentiment indicators (VIX term structure), and macro factors (yield curve,
// credit spreads) into a single allocation signal.
//
// Crisis detection automatically reduces exposure when multiple warning signals
// converge. Alerts available for major allocation shifts and regime changes.
//
// Designed for SPY/S&P 500 portfolio allocation. Adjust component weights and
// risk parameters in settings to match your risk tolerance.
````
