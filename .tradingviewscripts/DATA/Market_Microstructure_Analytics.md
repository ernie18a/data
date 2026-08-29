<!-- tradingview-pine-id: PUB;76ae6089244f4445b6dc2bd097148ffd -->
<!-- tradingviewscripts-format: 1 -->
# Market Microstructure Analytics

Source: https://www.tradingview.com/script/34R4Mh5W-Market-Microstructure-Analytics/

## Description

The Hidden Toll on Every Trade

Every time you buy or sell a financial instrument, you pay a cost that never appears on your brokerage statement. It is not a commission. It is not a fee. It is the spread between the price at which someone is willing to sell to you and the price at which someone is willing to buy from you. That gap, measured in ticks, basis points, or fractions of a percent, is the bid-ask spread. Over a single trade it looks small. Over thousands of trades, across a year, for a fund managing billions, it compounds into one of the most significant sources of performance drag in all of finance.

For decades, institutional traders have measured this cost obsessively. Research desks at hedge funds and investment banks have dedicated entire teams to understanding when spreads are wide, why they widen, who is causing them to widen, and what that signal implies about the near-term behaviour of a market. Retail traders, however, have had almost no access to this kind of analysis. The reason is simple: measuring the bid-ask spread in real time requires access to the order book, tick-by-tick trade data, and quote data that most platforms either do not provide or lock behind expensive data terminals.

This indicator changes that. Using only the OHLCV data that every chart on TradingView already contains, it reconstructs spread estimates and liquidity conditions through seven statistically validated models drawn directly from the academic market microstructure literature. It cannot replicate what a full order book feed provides, and the documentation is explicit about where the approximations are. But it gets considerably closer than anything available to the typical chart-based trader, and on short intraday charts it delivers information that is genuinely useful for both execution decisions and regime assessment.

What Market Microstructure Actually Measures

Market microstructure is the academic field that studies how prices are formed at the level of individual transactions. Its central question is not where a price will go tomorrow but how the mechanics of trading itself affect price formation right now. Two papers published decades apart established the framework this indicator builds on.

The first was by Roll (1984), who noticed something elegant: in an efficient market, the prices of consecutive trades should not be correlated with each other, because any predictability would be arbitraged away. But if you look at actual trade-by-trade price changes, you consistently find negative autocorrelation. Prices bounce back and forth. The reason, Roll argued, is the bid-ask spread itself. Buyers trade at the ask and sellers at the bid, so consecutive trades alternate between two price levels. This bouncing creates a predictable negative covariance in price changes, and the size of that covariance is directly related to the size of the spread. From this insight he derived the formula S = 2 times the square root of the negative covariance of consecutive price changes. If you observe a series of trades and measure how negatively they correlate with each other, you can back out the spread without ever seeing a quote.

The second foundational contribution came from Kyle (1985), who approached the problem from a completely different angle. He asked: if a market contains some traders who have private information about the true value of an asset, how do their orders affect price? His answer was the lambda coefficient, a measure of how much the price moves per unit of net order flow. A high lambda means the market is thin and informed: each additional unit of buying or selling pushes the price significantly. A low lambda means the market absorbs flow without moving much. Lambda is not just a spread measure; it is a measure of how much information asymmetry exists in the market at any given moment. This is the adverse selection component of the spread, and it is arguably the most strategically useful signal the indicator produces.

The Spread Estimators

The first layer of computation produces four distinct estimates of the bid-ask spread, each using a different statistical approach.

The Roll (1984) estimator is the oldest and most widely cited. It computes the rolling covariance between a price change and the price change that came before it, then takes two times the square root of the negative of that covariance. One important detail: Roll's model is defined in terms of absolute price changes, not log-returns. Using log-returns introduces a scaling distortion tied to the price level of the asset, which biases the spread estimate upward at high prices. This implementation correctly uses delta-P throughout.

The Corwin-Schultz (2012) estimator takes a fundamentally different approach. Rather than looking at the serial structure of price changes, it uses the high-low range of a bar. The core insight is that the high price of any trading period is most likely a transaction that occurred at the ask, while the low price is most likely a transaction at the bid. If you look at a two-period window, the combined high-low range reflects the true price variance over those two periods plus the spread component. A single-period range conflates variance and spread; the two-period structure allows them to be separated algebraically. The resulting formula involves a decomposition using the constant k = 3 minus 2 times the square root of 2, which emerges from the statistical properties of the high-low range under continuous diffusion. Corwin and Schultz (2012) validated this estimator extensively against actual quoted spreads across thousands of US equities and found it performs well both in cross-section and over time.

The Abdi-Ranaldo (2017) estimator is the most recent of the three and, in empirical tests, the most stable. For each bar, it computes a quantity called c, defined as the log of the close price minus the average of the log-high and log-low. This is the signed deviation of the close price from the geometric midpoint of the bar's range, expressed in log-space. Abdi and Ranaldo proved that the expected value of the product of c at time t and c at time t plus one equals negative one quarter of the spread squared. This means that by measuring how negatively c correlates with the next period's c, you can recover the spread. The estimator inherits much of the intuition of Roll but anchors itself to the intrabar price range rather than the close-to-close change, which tends to reduce noise substantially. To handle cases where the high and low are identical, which occurs on 1-tick bars or extremely liquid instruments, the implementation excludes invalid pairs from the covariance calculation rather than substituting zeros, which would bias the estimate toward zero.

The effective spread proxy takes yet another approach. Rather than estimating the quoted spread, it attempts to estimate the effective spread, which is the actual cost paid by a specific trade. The formula is two times the trade direction multiplied by the distance between the transaction price and the quote midpoint. Trade direction is approximated using the tick rule, which assigns a positive sign to transactions at prices higher than the previous price and a negative sign to those at lower prices, carrying the previous sign forward when the price is unchanged. This classification method was formalised by Lee and Ready (1991) and remains the standard approach for assigning direction when quote data is unavailable. The bar midpoint substitutes for the true quote midpoint, which introduces a systematic upward bias because the high and low of a bar are extreme transaction prices, not quotes. The effective spread proxy is therefore most reliable as a relative indicator of whether transaction costs are rising or falling, rather than as an absolute estimate of the quoted spread.

The Liquidity Metrics

The second layer moves beyond spread estimation into broader liquidity measurement. The key distinction is this: the spread tells you what it costs to execute one trade right now. Liquidity metrics tell you something about the structure of the market, how deep it is, how much information is embedded in the current order flow, and how efficiently prices are absorbing volume.

The Amihud (2002) illiquidity ratio is the most widely used liquidity measure in the academic asset pricing literature. Its construction is conceptually simple: it divides the absolute value of a log return by the dollar volume of trading in the same period. What this measures is price impact per dollar traded. If a stock moves one percent and 10 million dollars changed hands, the ratio is small. If the same one percent move happened on only 50,000 dollars of volume, the ratio is large, indicating a thin market where small amounts of capital move prices significantly. Unlike the spread measures, which capture the cost of a single round trip, the Amihud ratio captures market depth. This implementation uses dollar volume rather than share or contract volume, which is the correct specification for comparability across instruments at different price levels. The ratio is scaled by a factor of 100 million for display purposes; its absolute level is asset-dependent and should always be interpreted relative to the instrument's own history.

Kyle lambda, estimated here via ordinary least squares regression of price changes on signed volume, is the most theoretically sophisticated metric in the indicator. Each bar's signed volume is the total volume signed by the tick rule direction: positive if the bar closed higher than the previous bar, negative if it closed lower. The regression coefficient from regressing price changes on this signed volume is the lambda estimate. A high positive lambda means prices are moving more than expected for the amount of flow being absorbed, which is the signature of informed trading. When lambda rises, someone in the market likely knows something that others do not, and market makers are widening their spreads in response. The critical implementation detail here is that the volume must not be normalised before the regression. Normalising the signed volume changes the regression coefficient from a price-impact-per-share measure to a dimensionless sensitivity measure, which is a different quantity and does not correspond to Kyle's original model.

The Parkinson (1980) range-based volatility estimator serves a supporting role: it estimates intrabar variance from the high-low range using the formula sigma-squared equals one over four times the natural log of two, multiplied by the square of the log ratio of high to low. This estimator is approximately five times more statistically efficient than the classic close-to-close variance estimator for the same number of observations (Parkinson 1980). Its role in this indicator is to help decompose the high-low range: the range reflects both volatility and the spread, and the ratio of the composite spread estimate to the Parkinson volatility tells you which component is dominant at any given time.

The Composite and the Regime System

Having computed multiple independent estimates of the spread, the natural question is how to combine them. Simple averaging is theoretically suboptimal when the estimators have different levels of noise. The precision-weighted composite assigns each estimator a weight inversely proportional to its robust variance, so that noisier estimators contribute less to the final reading.

The key word is robust. Rather than computing standard rolling variance, which is dominated by extreme observations and can make a normally well-behaved estimator look unreliable for weeks after a single outlier bar, this implementation uses a variance estimator based on the Median Absolute Deviation, or MAD. The MAD is the median of the absolute deviations from the rolling median. Multiplied by the consistency factor 1.4826, it provides an equivalent to the standard deviation that is resistant to outliers with a breakdown point of 0.5, meaning up to half the observations in a window can be extreme values without corrupting the estimate. This approach follows Rousseeuw and Croux (1993), who established the formal properties of MAD-based scale estimators.

Two further safeguards stabilise the weights. A ridge regularisation term, set to five percent of the mean robust variance across active estimators, prevents any weight from exploding toward infinity when an estimator is temporarily near-constant. And a weight cap, set by default at 70 percent of the total, prevents any single estimator from dominating the composite during regimes where it happens to be locally smooth. The live weights are displayed in the dashboard so the user can always see how the composite is currently distributed.

The regime detection system answers the question of whether the current spread level is historically unusual. This is done through a robust z-score: the composite spread is compared to its rolling median, and the deviation is normalised by the MAD. The result is a standardised score that tells you how many robust standard deviations the current spread is from its recent typical level. A score of two or above signals a statistically unusual widening event. The same procedure is applied independently to the Amihud illiquidity ratio and to the absolute value of Kyle lambda.

These three scores are then combined into the Liquidity Stress Index, computed as their equal-weighted average after each component has been winsorised at plus or minus three robust standard deviations. The winsorisation prevents a single extreme reading in one dimension from overwhelming the composite. Each component is then winsorised before averaging to prevent a single extreme dimension from dominating. The result is mapped to a zero-to-100 scale using the hyperbolic tangent function, where 50 represents neutral conditions, readings in the 65 to 80 range indicate elevated stress, and readings above 80 indicate severe stress across multiple liquidity dimensions simultaneously.

Practical Use Cases

For a retail trader, the most immediately useful output is the composite spread and its regime classification. When the composite spread widens and the regime indicator shifts to Elevated or Stress, entering a new position becomes more expensive than usual. On illiquid instruments this widening can be dramatic, consuming a significant fraction of the expected profit in transaction costs before the trade even begins. Conversely, when spreads are compressed, the market is functioning efficiently and execution is cheap. Timing entries and exits around spread conditions is a simple, evidence-based way to reduce the invisible drag that erodes returns over time.

The spread trend indicator, which compares a five-period exponential moving average of the composite spread against a twenty-period average, provides a simple directional signal. A widening trend often precedes a period of higher volatility, lower liquidity, or increased uncertainty. This does not tell you which direction the price will move, but it tells you that the environment is becoming less predictable and more costly to trade, which is operationally important information.

For professional traders and systematic strategy developers, the Kyle lambda signal has specific applications. When lambda is elevated relative to its own history, which the dashboard displays as the adverse selection z-score, it indicates that price changes are disproportionate to the measured order flow. This is consistent with the presence of informed traders, a phenomenon central to the theoretical work of Kyle (1985) and Glosten and Milgrom (1985). Elevated adverse selection is one of the clearest early warning signs of an impending directional move driven by asymmetric information, such as pre-announcement positioning, earnings whispers, or macroeconomic data leakage.

The Amihud illiquidity ratio is particularly valuable for cross-asset comparisons and for monitoring the liquidity conditions of a specific instrument over time. Portfolio managers can use it to time their entries and exits in less liquid securities: entering when illiquidity is below its historical median and exiting before a period of known low liquidity such as a holiday period or low-volume session. Research by Amihud and Mendelson (1986) established that expected returns are positively correlated with illiquidity, meaning that investors demand higher compensation for holding assets where transaction costs are high. The illiquidity z-score in this indicator allows that premium to be tracked in real time.

The spread-to-volatility ratio is a metric that practitioners familiar with the work of Corwin and Schultz (2012) will recognise immediately. It expresses the composite spread as a percentage of the Parkinson volatility estimate. When this ratio is high, the spread accounts for a large fraction of the observed price range, which typically indicates a market where market makers are cautious and price discovery is slow. When it is low, the price range is driven primarily by genuine information, not by the mechanics of the spread. This ratio is useful for distinguishing between a volatile and actively traded market, which is generally healthy, and a wide-spread market that looks volatile but is actually just illiquid.

The Liquidity Stress Index in its scaled zero-to-100 form provides an accessible summary for traders who do not want to track multiple metrics simultaneously. During normal market conditions the reading sits near 50. When all three components, the spread, the illiquidity ratio, and the adverse selection estimate, are simultaneously elevated relative to their own histories, the index rises sharply. The historical examples of this pattern occurring together include the flash crash of May 2010, the August 2015 China-driven volatility spike, the COVID-19 crash of March 2020, and various cryptocurrency deleveraging events. In each case, the simultaneous widening of spreads, collapse of market depth, and spike in price impact coefficients preceded the most severe price dislocations by enough time to be actionable.

Configuration and Settings

The Estimation Window controls the rolling window for all covariance and liquidity calculations. A shorter window, around 10 to 20 bars, makes the estimators more responsive to recent changes but increases noise. A longer window, around 50 bars, produces smoother estimates that better reflect structural conditions but lag more. The default of 20 is a reasonable starting point for most intraday timeframes.

The EMA Smoothing parameter applies an exponential moving average to each raw spread estimate before it is used in the composite and displayed on the chart. This reduces bar-to-bar noise without introducing the same lag that a longer estimation window would create. Setting it to 1 disables smoothing entirely, which is useful for research purposes but not for trading.

The Regime Window determines how far back the robust z-scores look when assessing whether current conditions are unusual. A setting of 100 means the indicator asks whether the current spread is unusual relative to the last 100 bars. For daily charts, 100 bars is approximately five months of trading. For tick charts, it represents the most recent 100 tick bars. This parameter should be set large enough to capture at least one full market cycle of the relevant timeframe.

The Maximum Composite Weight prevents any single estimator from being assigned more than the specified fraction of total weight. The default of 70 percent is conservative; in practice, during regimes where all three estimators agree and produce similar variances, the weights tend to distribute fairly evenly. The cap becomes most important when one estimator is temporarily quiet and its MAD-based variance falls to near zero, which would otherwise assign it almost all the weight.

The LSI Winsorisation Cap limits the influence of extreme readings in any single component before they contribute to the Liquidity Stress Index. At the default of three robust standard deviations, a reading of ten, which would represent a truly exceptional event, contributes the same as a reading of three. This prevents a single data anomaly or calculation artifact from permanently elevating the stress index.

Structural Limitations

No representation is made that these outputs are equivalent to actual exchange quote data. They are not. TradingView provides bars, not tick-by-tick trades, and the academic models on which this indicator is based were developed for transaction-level data. The Roll estimator assumes that each observation is a single trade; when a bar aggregates hundreds or thousands of trades, the covariance structure it observes is a convolution of many individual trade-level covariances, and the result understates the true spread. This bias grows with bar duration and trade frequency. On 1-tick or 5-tick bars the bias is minimal; on daily bars it can be substantial.

The tick rule classification, which assigns trade direction to bars and underpins both the Kyle lambda and effective spread estimates, was designed for individual trades. Applied to the close price of aggregated bars, it misclassifies a material fraction of bars. Ellis, Michaely and O'Hara (2000) documented misclassification rates of 30 to 50 percent on daily stock data. On short intraday bars the performance is better, but it never reaches the accuracy achievable with actual quote data.

The rolling MAD computation is a streaming approximation to the exact finite-window MAD. In a stationary process the difference is negligible and the heavy-tail robustness property is preserved. In rapidly changing regimes the approximation introduces a small second-order error that does not materially affect the interpretation of the outputs.

The effective spread proxy suffers from a systematic upward bias because it uses the bar midpoint rather than the true quote midpoint. This bias is largest when the intrabar range is wide relative to the actual spread, which is precisely when the estimate is most needed. On very short tick bars the range collapses toward the actual spread and the bias diminishes, but on longer bars the effective spread reading should be treated as an upper bound rather than a point estimate.

Pine Script v6 introduced the built-in variables bid and ask, which return the current best bid and ask prices from a connected broker feed when accessed on the 1-tick timeframe via request.security(syminfo.tickerid, "1T", bid) and request.security(syminfo.tickerid, "1T", ask). This is a genuine improvement over bar-based proxies for the single most recent bar. However, these variables carry three constraints that prevent them from replacing the statistical estimators in this indicator. First, they carry no historical record: the values exist only at the current bar and return na on all prior bars, which makes it impossible to compute rolling covariances, MAD-based z-scores, or any of the regime detection logic that requires a lookback window. Second, the data is only available through a live broker connection on TradingView. Users on free accounts, paper trading environments, or instruments not covered by their connected broker will receive na throughout. Third, instrument coverage is uneven: major forex pairs, selected cryptocurrency pairs on exchanges such as Binance, and equities through brokers such as Interactive Brokers are generally supported, but futures, CFDs on many instruments, and equities through data-only feeds often return no data. The statistical estimators in this indicator therefore remain the primary analytical engine. If a broker connection is active, the live bid-ask spread retrieved via these built-in variables can serve as a real-time reference point to validate whether the rolling estimates are in a plausible range for the current session, but it cannot contribute to the historical signal calculations.

None of the outputs should be used as the sole basis for any trading decision.

References

Abdi, F. & Ranaldo, A. (2017) A Simple Estimation of Bid-Ask Spreads from Daily Close, High, and Low Prices. Review of Financial Studies, 30(12).

Amihud, Y. (2002) Illiquidity and Stock Returns: Cross-Section and Time-Series Effects. Journal of Financial Markets, 5(1), 31-56.

Amihud, Y. & Mendelson, H. (1986) Asset Pricing and the Bid-Ask Spread. Journal of Financial Economics, 17(2).

Corwin, S.A. & Schultz, P. (2012) A Simple Way to Estimate Bid-Ask Spreads from Daily High and Low Prices. Journal of Finance, 67(2).

Ellis, K., Michaely, R. & O'Hara, M. (2000) The Accuracy of Trade Classification Rules: Evidence from Nasdaq. Journal of Financial and Quantitative Analysis, 35(4).

Glosten, L.R. & Milgrom, P.R. (1985) Bid, Ask and Transaction Prices in a Specialist Market with Heterogeneously Informed Traders. Journal of Financial Economics, 14(1).

Hasbrouck, J. (2009) Trading Costs and Returns for U.S. Equities: Estimating Effective Costs from Daily Data. Journal of Finance, 64(3).

Kyle, A.S. (1985) Continuous Auctions and Insider Trading. Econometrica, 53(6).

Lee, C.M.C. & Ready, M.J. (1991) Inferring Trade Direction from Intraday Data. Journal of Finance, 46(2).

Parkinson, M. (1980) The Extreme Value Method for Estimating the Variance of the Rate of Return. Journal of Business, 53(1).

Roll, R. (1984) A Simple Implicit Measure of the Effective Bid-Ask Spread in an Efficient Market. Journal of Finance, 39(4).

Rousseeuw, P.J. & Croux, C. (1993) Alternatives to the Median Absolute Deviation. Journal of the American Statistical Association, 88(424).

---

## Source Code

````pine
//@version=6
// (c) EdgeTools — Market Microstructure Analytics
//
// Estimates bid-ask spread and liquidity conditions from OHLCV bar data using
// empirically validated microstructure models. No order book data is available
// in Pine Script; all outputs are statistical approximations.
//
// Layer 1 — Spread estimators
//   Roll (1984)          covariance of consecutive ΔP
//   Corwin-Schultz (2012) two-period high-low decomposition
//   Abdi-Ranaldo (2017)  close deviation from geometric bar midpoint
//   Effective spread     tick-rule signed distance from bar midpoint (upward bias)
//   HL range             reference only, captures variance + spread jointly
//
// Layer 2 — Liquidity metrics
//   Amihud (2002)        |r| per dollar of trading volume
//   Kyle lambda (1985)   OLS price-impact coefficient on signed flow
//   Parkinson (1980)     range-based variance estimator
//
// Layer 3 — Derived signals
//   Composite spread     precision-weighted (inverse rolling MAD variance)
//   Robust z-score       MAD-based normalisation, breakdown point 0.5
//   Liquidity Stress Index  equal-weight composite of z(spread)+z(ILLIQ)+z(|λ|)
//   Spread/volatility ratio spread as fraction of Parkinson volatility
//
// Structural limitations
//   Roll, Kyle, and the tick rule assume trade-level data. Bar aggregation
//   introduces downward bias in Roll and degrades tick-rule accuracy substantially
//   on longer timeframes (Ellis, Michaely & O'Hara 2000, JFI 9(4), 421-442).
//   The effective spread proxy uses (H+L)/2 as a quote-midpoint proxy, which
//   overstates the true midpoint distance and biases the estimate upward.
//   Rolling MAD is a streaming approximation of the exact window MAD; the error
//   is second-order for slowly varying series and does not affect robustness.
//   For educational and analytical purposes only.

indicator("Market Microstructure Analytics", shorttitle="MICRO", overlay=false,
     max_lines_count=500, max_bars_back=5000)

// Inputs

i_lookback   = input.int(20,  "Estimation Window",  minval=5,   maxval=200, group="Parameters",
    tooltip="Rolling window for covariance, SMA, and Amihud/Kyle calculations")
i_smooth     = input.int(5,   "EMA Smoothing",      minval=1,   maxval=50,  group="Parameters",
    tooltip="EMA period applied to each spread estimate before plotting and compositing")
i_regime_win = input.int(100, "Regime Window",      minval=20,  maxval=500, group="Parameters",
    tooltip="Window for MAD-based robust z-scores and regime band calculations")
i_w_cap      = input.float(0.70, "Max Composite Weight",
    minval=0.34, maxval=1.0, step=0.05, group="Parameters",
    tooltip="Upper bound on any single estimator's weight in the precision-weighted composite. Prevents unstable weight concentration when estimators are correlated.")
i_winsor     = input.float(3.0, "LSI Winsorization Cap",
    minval=1.0, maxval=6.0, step=0.5, group="Parameters",
    tooltip="Cap applied to each robust z-score component before forming the LSI. Limits the influence of extreme microstructure events on the composite stress index.")

i_show_roll  = input.bool(true,  "Roll (1984)",             group="Display")
i_show_cs    = input.bool(true,  "Corwin-Schultz (2012)",   group="Display")
i_show_ar    = input.bool(true,  "Abdi-Ranaldo (2017)",     group="Display")
i_show_eff   = input.bool(false, "Effective Spread Proxy",  group="Display")
i_show_comp  = input.bool(true,  "Composite Spread",        group="Display")
i_show_park  = input.bool(false, "Parkinson Volatility",    group="Display")
i_show_hl    = input.bool(false, "HL Range (reference)",    group="Display",
    tooltip="High-low range % — captures variance + spread jointly. Excluded from composite.")
i_show_bands = input.bool(true,  "Robust Regime Bands",     group="Display")
i_show_dash  = input.bool(true,  "Dashboard",               group="Display")
i_color_src  = input.string("LSI", "Color Source",
    options=["LSI", "Spread Regime", "Adverse Selection", "Spread Trend"],
    group="Display",
    tooltip="Drives bar coloring, background coloring, and the composite glow. LSI = full liquidity stress index. Spread Regime = composite spread z-score only. Adverse Selection = Kyle lambda z-score. Spread Trend = EMA 5/20 direction.")
i_bar_color  = input.bool(true,  "Bar Coloring",    group="Display")
i_bg_color   = input.bool(true,  "BG Coloring",     group="Display")
i_glow       = input.bool(true,  "Glow Effect (Composite)", group="Display")

i_dash_pos   = input.string("Top Right", "Dashboard Position",
    options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Display")
i_dash_size  = input.string("Normal", "Dashboard Size",
    options=["Tiny", "Small", "Normal", "Large"], group="Display")

i_scheme     = input.string("EdgeTools", "Color Theme",
    options=["Gold", "EdgeTools", "Quant", "Ocean"], group="Appearance")
i_dark       = input.bool(true, "Dark Mode",   group="Appearance")
i_lw         = input.int(2,    "Line Width",   minval=1, maxval=4, group="Appearance")

i_alerts     = input.bool(false, "Enable Alerts", group="Alerts")
i_thresh     = input.float(2.0,  "LSI Threshold", minval=0.5, maxval=4.0, step=0.5, group="Alerts",
    tooltip="LSI robust z-score threshold for stress alerts")

// Color scheme

var color c_pri  = #3b82f6
var color c_bull = #22c55e
var color c_bear = #ef4444
var color c_neut = #737373
var color c_text = #fafafa
var color c_tbg  = #171717
var color c_hbg  = #262626

switch i_scheme
    "Gold" =>
        c_pri  := i_dark ? #FFD700 : #DAA520
        c_bull := i_dark ? #FFA500 : #FF8C00
        c_bear := i_dark ? #FF5252 : #D32F2F
        c_neut := i_dark ? #C0C0C0 : #808080
        c_text := i_dark ? color.white : color.black
        c_tbg  := i_dark ? #1A1A00 : #FFFEF0
        c_hbg  := i_dark ? #2D2600 : #F5F5DC
    "EdgeTools" =>
        c_pri  := i_dark ? #3b82f6 : #2563eb
        c_bull := i_dark ? #22c55e : #16a34a
        c_bear := i_dark ? #ef4444 : #dc2626
        c_neut := i_dark ? #737373 : #525252
        c_text := i_dark ? #fafafa : #0a0a0a
        c_tbg  := i_dark ? #171717 : #f9f9f9
        c_hbg  := i_dark ? #262626 : #e5e5e5
    "Quant" =>
        c_pri  := #808080
        c_bull := #FFA500
        c_bear := #8B0000
        c_neut := #4682B4
        c_text := i_dark ? color.white : color.black
        c_tbg  := i_dark ? #0D0D0D : #FAFAFA
        c_hbg  := i_dark ? #1A1A1A : #F0F0F0
    "Ocean" =>
        c_pri  := i_dark ? #20B2AA : #008B8B
        c_bull := i_dark ? #00CED1 : #4682B4
        c_bear := i_dark ? #FF4500 : #B22222
        c_neut := i_dark ? #87CEEB : #2F4F4F
        c_text := i_dark ? #F0F8FF : #191970
        c_tbg  := i_dark ? #001A2E : #E6F7FF
        c_hbg  := i_dark ? #002A47 : #CCF2FF

tbl_trans = i_dark ? 80 : 15

// Helper functions

f_tbl_pos(string p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>               position.top_right

f_txt_sz(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        =>         size.normal

// Base series

// ΔP (not log-returns): Roll (1984) is specified in price-change units.
// Log-return scaling changes the dimension of the spread estimator.
dp     = not na(close[1]) and close[1] > 0 ? close - close[1] : 0.0
dp_lag = nz(dp[1], 0.0)

r         = close > 0 and close[1] > 0 ? math.log(close / close[1]) : 0.0
mid_price = (high + low) / 2.0
hl_valid  = high > 0 and low > 0 and high > low and
             not na(high[1]) and high[1] > 0 and low[1] > 0 and high[1] > low[1]

// Tick rule (Lee & Ready 1991): d = +1 if ΔP > 0, -1 if ΔP < 0, carry forward if ΔP = 0.
var int tick_dir = 1
if not na(close[1])
    if close > close[1]
        tick_dir := 1
    else if close < close[1]
        tick_dir := -1

// Signed volume for Kyle lambda — not normalised before regression.
// Normalising changes the estimand from price-impact-per-share to a dimensionless sensitivity.
q = float(tick_dir) * volume

// Layer 1: Spread estimators

// Roll (1984) — S = 2 * sqrt(max(0, -Cov(ΔP_t, ΔP_{t-1})))
// Roll, R. (1984). Journal of Finance, 39(4), 1127-1139.
cov_roll      = ta.sma(dp * dp_lag, i_lookback) - ta.sma(dp, i_lookback) * ta.sma(dp_lag, i_lookback)
roll_price    = 2.0 * math.sqrt(math.max(0.0, -cov_roll))
roll_pct_inst = close > 0 ? roll_price / close * 100.0 : 0.0
spread_roll   = ta.ema(roll_pct_inst, i_smooth)

// Corwin-Schultz (2012) — two-period high-low spread decomposition
// k = 3 - 2*sqrt(2); S = 2*(exp(α)-1)/(1+exp(α)) * 100
// Corwin, S.A. & Schultz, P. (2012). Journal of Finance, 67(2), 719-760.
cs_k     = 3.0 - 2.0 * math.sqrt(2.0)
beta_cs  = hl_valid ?
     math.pow(math.log(high / low), 2.0) + math.pow(math.log(high[1] / low[1]), 2.0) : na
gamma_cs = hl_valid ?
     math.pow(math.log(math.max(high, high[1]) / math.min(low, low[1])), 2.0) : na
alpha_cs = not na(beta_cs) and not na(gamma_cs) ?
     math.max(0.0, (math.sqrt(2.0 * beta_cs) - math.sqrt(beta_cs)) / cs_k -
     math.sqrt(gamma_cs / cs_k)) : na
cs_raw   = not na(alpha_cs) ?
     2.0 * (math.exp(alpha_cs) - 1.0) / (1.0 + math.exp(alpha_cs)) * 100.0 : na
cs_inst  = nz(cs_raw, 0.0)
spread_cs = ta.ema(cs_inst, i_smooth)
cs_active = not na(cs_raw)

// Abdi-Ranaldo (2017) — c_t = ln(close) - (ln(H)+ln(L))/2
// E[c_t * c_{t-1}] = -s²/4  →  s = 2*sqrt(max(0,-E[c_t*c_{t-1}]))
// When H = L, c_t is undefined. Setting it to 0 would inject artificial zeros
// into the covariance; instead NA pairs are excluded via validity-weighted mean.
// Abdi, F. & Ranaldo, A. (2017). Review of Financial Studies, 30(12), 4437-4480.
ar_c          = hl_valid ? math.log(close) - (math.log(high) + math.log(low)) / 2.0 : na
ar_pair_valid = (hl_valid and hl_valid[1]) ? 1.0 : 0.0
ar_prod_valid = ar_pair_valid > 0 ? nz(ar_c) * nz(ar_c[1]) : 0.0
ar_n_valid    = ta.sma(ar_pair_valid, i_lookback) * float(i_lookback)
ar_prod_sum_w = ta.sma(ar_prod_valid, i_lookback) * float(i_lookback)
// Require at least 50% valid (H > L) pairs; minimum 3 regardless of window size.
ar_min_valid  = math.max(3.0, math.ceil(float(i_lookback) * 0.5))
ar_sufficient = ar_n_valid >= ar_min_valid
ar_mean_prod  = ar_sufficient ? ar_prod_sum_w / ar_n_valid : 0.0
ar_raw        = ar_sufficient ? 2.0 * math.sqrt(math.max(0.0, -ar_mean_prod)) * 100.0 : 0.0
spread_ar     = ta.ema(ar_raw, i_smooth)
ar_active     = hl_valid and ar_sufficient

// Effective spread proxy (Hasbrouck 2009) — ES = 2*d*(P-M)/P
// M = (H+L)/2 overstates the true quote midpoint; upward bias increases with intrabar range.
// Use for relative trend analysis, not as an absolute spread level.
// Hasbrouck, J. (2009). Journal of Finance, 64(3), 1445-1477.
eff_bar    = close > 0 and high > low ?
     2.0 * float(tick_dir) * (close - mid_price) / close * 100.0 : 0.0
eff_spread = ta.sma(eff_bar, i_lookback)

// HL range — reference only, not in composite (captures variance + spread jointly)
hl_raw    = mid_price > 0 and high > low ? (high - low) / mid_price * 100.0 : 0.0
spread_hl = ta.ema(hl_raw, i_smooth)

// Layer 2: Liquidity metrics

// Amihud (2002) — ILLIQ = |r| / (P*V); dollar volume normalises across price levels.
// Scale ×1e8 for display; absolute level is asset-dependent.
// Amihud, Y. (2002). Journal of Financial Markets, 5(1), 31-56.
dollar_vol  = close * volume
amihud_inst = dollar_vol > 0 ? math.abs(r) / dollar_vol : 0.0
amihud_sma  = ta.sma(amihud_inst, i_lookback) * 1e8

// Kyle lambda (1985) — λ = Cov(ΔP, q) / Var(q); OLS on unnormalised signed volume.
// Scale ×1e6 for display; units are price/volume and asset-dependent.
// Kyle, A.S. (1985). Econometrica, 53(6), 1315-1335.
cov_kl      = ta.sma(dp * q, i_lookback) - ta.sma(dp, i_lookback) * ta.sma(q, i_lookback)
var_kl      = math.pow(ta.stdev(q, i_lookback), 2.0)
kl_raw      = var_kl > 1e-20 ? cov_kl / var_kl : 0.0
kyle_lambda = ta.ema(kl_raw * 1e6, i_smooth)

// Parkinson (1980) — σ²_P = [1/(4*ln2)] * [ln(H/L)]²
// ~5× more efficient than close-to-close variance for the same number of observations.
// Used to decompose the HL range into spread and variance components.
// Parkinson, M. (1980). Journal of Business, 53(1), 61-65.
park_k    = 1.0 / (4.0 * math.log(2.0))
park_inst = hl_valid ? park_k * math.pow(math.log(high / low), 2.0) : 0.0
park_var  = ta.sma(park_inst, i_lookback)
park_vol  = math.sqrt(math.max(0.0, park_var)) * 100.0

// Layer 3: Derived signals

// Composite spread — precision-weighted (inverse rolling MAD variance)
// MAD-based variance (breakdown point 0.5) prevents single outlier bars from
// collapsing a weight to near-zero for the full lookback window.
// Ridge regularisation: ε = 5% of mean robust variance across active estimators.
// Weight cap (i_w_cap) prevents near-100% concentration in one estimator.
// Rousseeuw, P.J. & Croux, C. (1993). JASA, 88(424), 1273-1283.
n_comps = 1 + (cs_active ? 1 : 0) + (ar_active ? 1 : 0)

roll_med_v   = ta.percentile_nearest_rank(roll_pct_inst, i_lookback, 50)
roll_dev_v   = math.abs(roll_pct_inst - roll_med_v)
roll_mad_v   = ta.percentile_nearest_rank(roll_dev_v, i_lookback, 50)
var_roll_raw = math.pow(1.4826 * roll_mad_v, 2.0)

cs_med_v   = ta.percentile_nearest_rank(cs_inst, i_lookback, 50)
cs_dev_v   = math.abs(cs_inst - cs_med_v)
cs_mad_v   = ta.percentile_nearest_rank(cs_dev_v, i_lookback, 50)
var_cs_raw = math.pow(1.4826 * cs_mad_v, 2.0)

ar_med_v   = ta.percentile_nearest_rank(ar_raw, i_lookback, 50)
ar_dev_v   = math.abs(ar_raw - ar_med_v)
ar_mad_v   = ta.percentile_nearest_rank(ar_dev_v, i_lookback, 50)
var_ar_raw = math.pow(1.4826 * ar_mad_v, 2.0)

var_act_sum = var_roll_raw +
              (cs_active ? var_cs_raw : 0.0) +
              (ar_active ? var_ar_raw : 0.0)
reg_eps     = var_act_sum > 0 ? 0.05 * var_act_sum / float(n_comps) : 1e-10

ivar_roll_r = 1.0 / (var_roll_raw + reg_eps)
ivar_cs_r   = cs_active ? 1.0 / (var_cs_raw + reg_eps) : 0.0
ivar_ar_r   = ar_active ? 1.0 / (var_ar_raw + reg_eps) : 0.0
ivar_sum_r  = ivar_roll_r + ivar_cs_r + ivar_ar_r

w_roll_unc = ivar_sum_r > 0 ? ivar_roll_r / ivar_sum_r : 1.0 / float(n_comps)
w_cs_unc   = ivar_sum_r > 0 ? ivar_cs_r   / ivar_sum_r : (cs_active ? 1.0 / float(n_comps) : 0.0)
w_ar_unc   = ivar_sum_r > 0 ? ivar_ar_r   / ivar_sum_r : (ar_active ? 1.0 / float(n_comps) : 0.0)

w_roll_cap = math.min(w_roll_unc, i_w_cap)
w_cs_cap   = math.min(w_cs_unc,   i_w_cap)
w_ar_cap   = math.min(w_ar_unc,   i_w_cap)
w_cap_sum  = w_roll_cap + w_cs_cap + w_ar_cap

w_roll_f = w_cap_sum > 0 ? w_roll_cap / w_cap_sum : 1.0 / float(n_comps)
w_cs_f   = w_cap_sum > 0 ? w_cs_cap   / w_cap_sum : (cs_active ? 1.0 / float(n_comps) : 0.0)
w_ar_f   = w_cap_sum > 0 ? w_ar_cap   / w_cap_sum : (ar_active ? 1.0 / float(n_comps) : 0.0)

spread_comp = w_roll_f * spread_roll + w_cs_f * spread_cs + w_ar_f * spread_ar

w_roll = w_roll_f * 100.0
w_cs   = w_cs_f   * 100.0
w_ar   = w_ar_f   * 100.0

// Robust z-score: (x - median) / (1.4826 * MAD)
// Consistency factor 1.4826 makes MAD equivalent to σ under Gaussian data.
rz_sp_med = ta.percentile_nearest_rank(spread_comp, i_regime_win, 50)
rz_sp_dev = math.abs(spread_comp - rz_sp_med)
rz_sp_mad = ta.percentile_nearest_rank(rz_sp_dev,  i_regime_win, 50)
spread_rz = rz_sp_mad > 1e-10 ? (spread_comp - rz_sp_med) / (1.4826 * rz_sp_mad) : 0.0

rz_ah_med = ta.percentile_nearest_rank(amihud_sma, i_regime_win, 50)
rz_ah_dev = math.abs(amihud_sma - rz_ah_med)
rz_ah_mad = ta.percentile_nearest_rank(rz_ah_dev,  i_regime_win, 50)
amihud_rz = rz_ah_mad > 1e-10 ? (amihud_sma - rz_ah_med) / (1.4826 * rz_ah_mad) : 0.0

kyle_abs  = math.abs(kyle_lambda)
rz_kl_med = ta.percentile_nearest_rank(kyle_abs,   i_regime_win, 50)
rz_kl_dev = math.abs(kyle_abs - rz_kl_med)
rz_kl_mad = ta.percentile_nearest_rank(rz_kl_dev,  i_regime_win, 50)
kyle_rz   = rz_kl_mad > 1e-10 ? (kyle_abs - rz_kl_med) / (1.4826 * rz_kl_mad) : 0.0

// Liquidity Stress Index — equal-weight composite of z(spread) + z(ILLIQ) + z(|λ|)
// Components winsorised at ±i_winsor before combining to prevent a single extreme
// reading from dominating the composite (second layer of outlier protection).
spread_rz_w = math.max(-i_winsor, math.min(i_winsor, spread_rz))
amihud_rz_w = math.max(-i_winsor, math.min(i_winsor, amihud_rz))
kyle_rz_w   = math.max(-i_winsor, math.min(i_winsor, kyle_rz))
lsi         = (spread_rz_w + amihud_rz_w + kyle_rz_w) / 3.0

// LSI scaled to 0-100 via tanh: neutral = 50, elevated ≈ 65-80, severe > 80.
// tanh(x) = (e^(2x)-1)/(e^(2x)+1); here x = lsi/2, so e^(2x) = e^lsi.
// Clamped at ±40 to prevent overflow in math.exp.
lsi_e2x    = math.exp(math.max(-40.0, math.min(40.0, lsi)))
lsi_scaled = 50.0 * (1.0 + (lsi_e2x - 1.0) / (lsi_e2x + 1.0))

// Spread/volatility ratio: high (> 1) indicates spread-dominated, thin market
sv_ratio = park_vol > 0.001 ? spread_comp / park_vol : na

// Spread trend
s_fast      = ta.ema(spread_comp, 5)
s_slow      = ta.ema(spread_comp, 20)
spread_wide = s_fast > s_slow

// Regime classification
regime_str = lsi >=  i_thresh ? "STRESS"     :
             lsi >=  1.0      ? "ELEVATED"   :
             lsi <= -1.0      ? "COMPRESSED" : "NORMAL"

regime_color = lsi >=  i_thresh ? c_bear                   :
               lsi >=  1.0      ? color.new(c_bear, 40)   :
               lsi <= -1.0      ? c_bull                   : c_neut

// Robust regime bands: centred on rolling median, width = 1.4826 * MAD
band_sigma = 1.4826 * rz_sp_mad
band_up_2s = rz_sp_med + 2.0 * band_sigma
band_up_1s = rz_sp_med + 1.0 * band_sigma
band_dn_1s = rz_sp_med - 1.0 * band_sigma

// Adverse selection assessment
as_elevated = kyle_rz > 1.5
as_str      = as_elevated ? "ELEVATED" : "NORMAL"
as_color    = as_elevated ? c_bear : c_bull

// Unified signal color — drives bar coloring, bg coloring, and composite glow
spread_rz_color = spread_rz >= 2.0 ? c_bear :
                  spread_rz >= 1.0 ? color.new(c_bear, 40) :
                  spread_rz <= -1.0 ? c_bull : c_neut
as_grad_color   = kyle_rz > 2.0 ? c_bear :
                  kyle_rz > 1.5 ? color.new(c_bear, 40) : c_neut
trend_color     = spread_wide ? c_bear : c_bull

signal_color = switch i_color_src
    "LSI"               => regime_color
    "Spread Regime"     => spread_rz_color
    "Adverse Selection" => as_grad_color
    "Spread Trend"      => trend_color
    =>                     regime_color

// Plots

color c_ar  = #F59E0B
color c_eff = #A855F7

bg_active = signal_color != c_neut
barcolor(i_bar_color and bg_active ? signal_color : na, title="Bar Color")
bgcolor(i_bg_color   and bg_active ? color.new(signal_color, 91) : na, title="BG Color")

plot(i_show_roll ? spread_roll  : na, "Roll 1984 %",
     color=color.new(c_pri, 0), linewidth=i_lw)
plot(i_show_cs   ? spread_cs   : na, "Corwin-Schultz 2012 %",
     color=color.new(c_bull, 20), linewidth=i_lw > 1 ? i_lw - 1 : 1)
plot(i_show_ar   ? spread_ar   : na, "Abdi-Ranaldo 2017 %",
     color=color.new(c_ar, 20), linewidth=i_lw > 1 ? i_lw - 1 : 1)
plot(i_show_eff  ? eff_spread  : na, "Eff. Spread Proxy %",
     color=color.new(c_eff, 25), linewidth=1)

// Glow effect: three stacked layers rendered beneath the composite line.
// Color inherits signal_color so the halo follows the selected source.
plot(i_glow and i_show_comp ? spread_comp : na, "Composite Glow 3",
     color=color.new(signal_color, 88), linewidth=i_lw + 6, display=display.pane)
plot(i_glow and i_show_comp ? spread_comp : na, "Composite Glow 2",
     color=color.new(signal_color, 76), linewidth=i_lw + 3, display=display.pane)
plot(i_glow and i_show_comp ? spread_comp : na, "Composite Glow 1",
     color=color.new(signal_color, 58), linewidth=i_lw + 1, display=display.pane)
plot(i_show_comp ? spread_comp : na, "Composite Spread %",
     color=color.new(signal_color, 15), linewidth=i_lw)

plot(i_show_park ? park_vol    : na, "Parkinson Vol %",
     color=color.new(c_neut, 35), linewidth=1, style=plot.style_circles)
plot(i_show_hl   ? spread_hl   : na, "HL Range (ref) %",
     color=color.new(c_neut, 65), linewidth=1)

plot(i_show_bands ? rz_sp_med  : na, "Median",     color=color.new(c_neut, 55), linewidth=1)
p_u2 = plot(i_show_bands ? band_up_2s : na, "Median +2σ", color=color.new(c_bear, 65), linewidth=1)
p_u1 = plot(i_show_bands ? band_up_1s : na, "Median +1σ", color=color.new(c_bear, 82), linewidth=1)
p_d1 = plot(i_show_bands ? band_dn_1s : na, "Median -1σ", color=color.new(c_bull, 82), linewidth=1)
fill(p_u2, p_u1, color=i_show_bands ? color.new(c_bear, 92) : na, title="Stress Zone (1σ-2σ)")

plot(0.0, "Zero", color=color.new(c_neut, 70), linewidth=1)

// Dashboard

d_pos = f_tbl_pos(i_dash_pos)
d_sz  = f_txt_sz(i_dash_size)
d_sm  = i_dash_size == "Large"  ? size.normal :
         i_dash_size == "Normal" ? size.small  : size.tiny
d_xs  = size.tiny

if i_show_dash and barstate.islast
    var table dash = table.new(d_pos, 2, 18, border_width=1,
                               bgcolor=color.new(c_tbg, tbl_trans))
    table.clear(dash, 0, 0, 1, 17)

    hbg = color.new(c_hbg, 20)
    tbg = color.new(c_tbg, tbl_trans)

    table.cell(dash, 0, 0, "MICROSTRUCTURE ANALYTICS", text_color=c_text, bgcolor=hbg, text_size=d_sz)
    table.cell(dash, 1, 0, syminfo.ticker + "  " + timeframe.period, text_color=c_pri,
               bgcolor=hbg, text_size=d_sz)

    roll_c = spread_rz > 0 ? c_bear : c_bull
    table.cell(dash, 0, 1, "Roll 1984", text_color=c_text, bgcolor=tbg, text_size=d_sm)
    table.cell(dash, 1, 1, str.tostring(spread_roll, "#.00000") + "%",
               text_color=roll_c, bgcolor=color.new(roll_c, 90), text_size=d_sm)

    cs_str = cs_active ? str.tostring(spread_cs, "#.00000") + "%" : "N/A  (H = L)"
    cs_c   = cs_active and spread_cs > spread_roll ? c_bear : c_bull
    table.cell(dash, 0, 2, "Corwin-Schultz 2012", text_color=c_text, bgcolor=tbg, text_size=d_sm)
    table.cell(dash, 1, 2, cs_str, text_color=cs_c, bgcolor=color.new(cs_c, 90), text_size=d_sm)

    ar_str = ar_active ? str.tostring(spread_ar, "#.00000") + "%" : "N/A  (H = L)"
    ar_c   = ar_active and spread_ar > spread_roll ? c_bear : c_bull
    table.cell(dash, 0, 3, "Abdi-Ranaldo 2017", text_color=c_text, bgcolor=tbg, text_size=d_sm)
    table.cell(dash, 1, 3, ar_str, text_color=ar_c, bgcolor=color.new(ar_c, 90), text_size=d_sm)

    eff_c = eff_spread > rz_sp_med ? c_bear : c_bull
    table.cell(dash, 0, 4, "Eff. Spread Proxy  (bias↑ w/ range)", text_color=c_text, bgcolor=tbg, text_size=d_sm)
    table.cell(dash, 1, 4, str.tostring(eff_spread, "#.00000") + "%",
               text_color=eff_c, bgcolor=color.new(eff_c, 90), text_size=d_sm)

    comp_c = spread_rz > 1.0 ? c_bear : spread_rz < -1.0 ? c_bull : c_neut
    table.cell(dash, 0, 5, "Composite (prec.wt.)", text_color=c_text,
               bgcolor=color.new(comp_c, 90), text_size=d_sm)
    table.cell(dash, 1, 5, str.tostring(spread_comp, "#.00000") + "%",
               text_color=comp_c, bgcolor=color.new(comp_c, 90), text_size=d_sm)

    w_str = "Rll:" + str.tostring(w_roll, "#") + "%" +
             (cs_active ? "  CS:" + str.tostring(w_cs, "#") + "%" : "  CS:0%") +
             (ar_active ? "  AR:" + str.tostring(w_ar, "#") + "%" : "  AR:0%")
    table.cell(dash, 0, 6, "  weights", text_color=color.new(c_neut, 20),
               bgcolor=color.new(comp_c, 95), text_size=d_xs)
    table.cell(dash, 1, 6, w_str, text_color=color.new(c_neut, 20),
               bgcolor=color.new(comp_c, 95), text_size=d_xs)

    sv_str = not na(sv_ratio) ? str.tostring(sv_ratio * 100.0, "#.0") + "% of Park.Vol" : "N/A"
    table.cell(dash, 0, 7, "Parkinson Vol / S÷V ratio", text_color=c_text, bgcolor=tbg, text_size=d_sm)
    table.cell(dash, 1, 7, str.tostring(park_vol, "#.00000") + "%  " + sv_str,
               text_color=c_neut, bgcolor=tbg, text_size=d_sm)

    ah_c = amihud_rz > 1.0 ? c_bear : c_neut
    table.cell(dash, 0, 8, "Amihud ILLIQ  (|r|/$Vol ×1e8)", text_color=c_text, bgcolor=tbg, text_size=d_sm)
    table.cell(dash, 1, 8, str.tostring(amihud_sma, "#.000000"),
               text_color=ah_c, bgcolor=color.new(ah_c, 90), text_size=d_sm)

    kl_c    = kyle_rz > 1.5 ? c_bear : c_neut
    kl_sign = kyle_lambda >= 0 ? "+" : ""
    table.cell(dash, 0, 9, "Kyle Lambda  (ΔP~q OLS ×1e6)", text_color=c_text, bgcolor=tbg, text_size=d_sm)
    table.cell(dash, 1, 9, kl_sign + str.tostring(kyle_lambda, "#.000000"),
               text_color=kl_c, bgcolor=color.new(kl_c, 90), text_size=d_sm)

    table.cell(dash, 0, 10, "Adverse Selection  (λ z=" + str.tostring(kyle_rz, "#.##") + ")",
               text_color=c_text, bgcolor=color.new(as_color, 85), text_size=d_sm)
    table.cell(dash, 1, 10, as_str, text_color=as_color,
               bgcolor=color.new(as_color, 85), text_size=d_sm)

    table.cell(dash, 0, 11, "Spread Regime  (robust z=" + str.tostring(spread_rz, "#.##") + ")",
               text_color=c_text, bgcolor=color.new(regime_color, 82), text_size=d_sm)
    table.cell(dash, 1, 11, regime_str,
               text_color=regime_color, bgcolor=color.new(regime_color, 82), text_size=d_sm)

    trend_c = spread_wide ? c_bear : c_bull
    table.cell(dash, 0, 12, "Spread Trend  (EMA 5/20)", text_color=c_text,
               bgcolor=color.new(trend_c, 90), text_size=d_sm)
    table.cell(dash, 1, 12, spread_wide ? "WIDENING" : "TIGHTENING",
               text_color=trend_c, bgcolor=color.new(trend_c, 90), text_size=d_sm)

    lsi_c   = lsi >=  i_thresh ? c_bear :
              lsi >=  1.0      ? color.new(c_bear, 40) :
              lsi <= -1.0      ? c_bull : c_neut
    lsi_str = lsi >=  i_thresh ? "STRESS"     :
              lsi >=  1.0      ? "ELEVATED"   :
              lsi <= -1.0      ? "COMPRESSED" : "NORMAL"
    table.cell(dash, 0, 13, "LSI  z=" + str.tostring(lsi, "#.##") +
               "  scaled=" + str.tostring(lsi_scaled, "#") + "/100",
               text_color=c_text, bgcolor=color.new(lsi_c, 80), text_size=d_sm)
    table.cell(dash, 1, 13, lsi_str + "  [Sprd+ILLIQ+|λ|]",
               text_color=lsi_c, bgcolor=color.new(lsi_c, 80), text_size=d_sm)

    table.cell(dash, 0, 14, "LSI breakdown  spread / ILLIQ / |λ|",
               text_color=color.new(c_neut, 20), bgcolor=tbg, text_size=d_xs)
    table.cell(dash, 1, 14,
               str.tostring(spread_rz, "#.##") + " / " +
               str.tostring(amihud_rz, "#.##") + " / " +
               str.tostring(kyle_rz,   "#.##"),
               text_color=color.new(c_neut, 20), bgcolor=tbg, text_size=d_xs)

    table.cell(dash, 0, 15, "Bands  median / +1σ / +2σ",
               text_color=color.new(c_neut, 40), bgcolor=tbg, text_size=d_xs)
    table.cell(dash, 1, 15,
               str.tostring(rz_sp_med,  "#.0000") + " / " +
               str.tostring(band_up_1s, "#.0000") + " / " +
               str.tostring(band_up_2s, "#.0000") + "%",
               text_color=color.new(c_neut, 40), bgcolor=tbg, text_size=d_xs)

    table.cell(dash, 0, 16, "Win " + str.tostring(i_lookback) + "  Regime " +
               str.tostring(i_regime_win) + "  Smooth " + str.tostring(i_smooth),
               text_color=color.new(c_neut, 55), bgcolor=tbg, text_size=d_xs)
    table.cell(dash, 1, 16, "(c) EdgeTools", text_color=color.new(c_neut, 55), bgcolor=tbg, text_size=d_xs)

    table.cell(dash, 0, 17, "Roll84 | CS12 | AR17 | Hasbrouck09 | Amihud02 | Kyle85 | Park80",
               text_color=color.new(c_neut, 65), bgcolor=tbg, text_size=d_xs)
    table.cell(dash, 1, 17, "MAD-z: Rousseeuw & Croux 1993",
               text_color=color.new(c_neut, 65), bgcolor=tbg, text_size=d_xs)

// Alerts

lsi_stress_on  = ta.crossover(lsi,  i_thresh) and barstate.isconfirmed
lsi_stress_off = ta.crossunder(lsi,  1.0)     and barstate.isconfirmed
as_event       = as_elevated and not as_elevated[1] and barstate.isconfirmed

alertcondition(lsi_stress_on and i_alerts, title="LSI Stress Event",
    message="MMA: LSI crossed stress threshold — spread widening, illiquidity, and adverse selection elevated simultaneously.")
alertcondition(lsi_stress_off and i_alerts, title="LSI Normalising",
    message="MMA: LSI returning below 1.0 — liquidity conditions normalising.")
alertcondition(as_event and i_alerts, title="Adverse Selection Elevated",
    message="MMA: Kyle Lambda z-score > 1.5. Tick-rule order flow showing elevated price impact — possible informed trading.")
````
