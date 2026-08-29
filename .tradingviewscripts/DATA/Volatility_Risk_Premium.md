<!-- tradingview-pine-id: PUB;579c41b76d4d497ba94eccd958f0e96a -->
<!-- tradingviewscripts-format: 1 -->
# Volatility Risk Premium

Source: https://www.tradingview.com/script/UJgVgUvT-Volatility-Risk-Premium/

## Description

THE INSURANCE PREMIUM OF THE STOCK MARKET

Every day, millions of investors face a fundamental question that has puzzled economists for decades: how much should protection against market crashes cost? The answer lies in a phenomenon called the Volatility Risk Premium, and understanding it may fundamentally change how you interpret market conditions.

Think of the stock market like a neighborhood where homeowners buy insurance against fire. The insurance company charges premiums based on their estimates of fire risk. But here is the interesting part: insurance companies systematically charge more than the actual expected losses. This difference between what people pay and what actually happens is the insurance premium. The same principle operates in financial markets, but instead of fire insurance, investors buy protection against market volatility through options contracts.

The Volatility Risk Premium, or VRP, measures exactly this difference. It represents the gap between what the market expects volatility to be (implied volatility, as reflected in options prices) and what volatility actually turns out to be (realized volatility, calculated from actual price movements). This indicator quantifies that gap and transforms it into actionable intelligence.

THE FOUNDATION

The academic study of volatility risk premiums began gaining serious traction in the early 2000s, though the phenomenon itself had been observed by practitioners for much longer. Three research papers form the backbone of this indicator's methodology.

Peter Carr and Liuren Wu published their seminal work "Variance Risk Premiums" in the Review of Financial Studies in 2009. Their research established that variance risk premiums exist across virtually all asset classes and persist over time. They documented that on average, implied volatility exceeds realized volatility by approximately three to four percentage points annualized. This is not a small number. It means that sellers of volatility insurance have historically collected a substantial premium for bearing this risk.

Tim Bollerslev, George Tauchen, and Hao Zhou extended this research in their 2009 paper "Expected Stock Returns and Variance Risk Premia," also published in the Review of Financial Studies. Their critical contribution was demonstrating that the VRP is a statistically significant predictor of future equity returns. When the VRP is high, meaning investors are paying substantial premiums for protection, future stock returns tend to be positive. When the VRP collapses or turns negative, it often signals that realized volatility has spiked above expectations, typically during market stress periods.

Gurdip Bakshi and Nikunj Kapadia provided additional theoretical grounding in their 2003 paper "Delta-Hedged Gains and the Negative Market Volatility Risk Premium." They demonstrated through careful empirical analysis why volatility sellers are compensated: the risk is not diversifiable and tends to materialize precisely when investors can least afford losses.

HOW THE INDICATOR CALCULATES VOLATILITY

The calculation begins with two separate measurements that must be compared: implied volatility and realized volatility.

For implied volatility, the indicator uses the CBOE Volatility Index, commonly known as the VIX. The VIX represents the market's expectation of 30-day forward volatility on the S&P 500, calculated from a weighted average of out-of-the-money put and call options. It is often called the "fear gauge" because it rises when investors rush to buy protective options.

Realized volatility requires more careful consideration. The indicator offers three distinct calculation methods, each with specific advantages rooted in academic literature.

The Close-to-Close method is the most straightforward approach. It calculates the standard deviation of logarithmic daily returns over a specified lookback period, then annualizes this figure by multiplying by the square root of 252, the approximate number of trading days in a year. This method is intuitive and widely used, but it only captures information from closing prices and ignores intraday price movements.

The Parkinson estimator, developed by Michael Parkinson in 1980, improves efficiency by incorporating high and low prices. The mathematical formula calculates variance as the sum of squared log ratios of daily highs to lows, divided by four times the natural logarithm of two, times the number of observations. This estimator is theoretically about five times more efficient than the close-to-close method because high and low prices contain additional information about the volatility process.

The Garman-Klass estimator, published by Mark Garman and Michael Klass in 1980, goes further by incorporating opening, high, low, and closing prices. The formula combines half the squared log ratio of high to low prices minus a factor involving the log ratio of close to open. This method achieves the minimum variance among estimators using only these four price points, making it particularly valuable for markets where intraday information is meaningful.

THE CORE VRP CALCULATION

Once both volatility measures are obtained, the VRP calculation is straightforward: subtract realized volatility from implied volatility. A positive result means the market is paying a premium for volatility insurance. A negative result means realized volatility has exceeded expectations, typically indicating market stress.

The raw VRP signal receives slight smoothing through an exponential moving average to reduce noise while preserving responsiveness. The default smoothing period of five days balances signal clarity against lag.

INTERPRETING THE REGIMES

The indicator classifies market conditions into five distinct regimes based on VRP levels.

The EXTREME regime occurs when VRP exceeds ten percentage points. This represents an unusual situation where the gap between implied and realized volatility is historically wide. Markets are pricing in significantly more fear than is materializing. Research suggests this often precedes positive equity returns as the premium normalizes.

The HIGH regime, between five and ten percentage points, indicates elevated risk aversion. Investors are paying above-average premiums for protection. This often occurs after market corrections when fear remains elevated but realized volatility has begun subsiding.

The NORMAL regime covers VRP between zero and five percentage points. This represents the long-term average state of markets where implied volatility modestly exceeds realized volatility. The insurance premium is being collected at typical rates.

The LOW regime, between negative two and zero percentage points, suggests either unusual complacency or that realized volatility is catching up to implied volatility. The premium is shrinking, which can precede either calm continuation or increased stress.

The NEGATIVE regime occurs when realized volatility exceeds implied volatility. This is relatively rare and typically indicates active market stress. Options were priced for less volatility than actually occurred, meaning volatility sellers are experiencing losses. Historically, deeply negative VRP readings have often coincided with market bottoms, though timing the reversal remains challenging.

TERM STRUCTURE ANALYSIS

Beyond the basic VRP calculation, sophisticated market participants analyze how volatility behaves across different time horizons. The indicator calculates VRP using both short-term (default ten days) and long-term (default sixty days) realized volatility windows.

Under normal market conditions, short-term realized volatility tends to be lower than long-term realized volatility. This produces what traders call contango in the term structure, analogous to futures markets where later delivery dates trade at premiums. The RV Slope metric quantifies this relationship.

When markets enter stress periods, the term structure often inverts. Short-term realized volatility spikes above long-term realized volatility as markets experience immediate turmoil. This backwardation condition serves as an early warning signal that current volatility is elevated relative to historical norms.

The academic foundation for term structure analysis comes from Scott Mixon's 2007 paper "The Implied Volatility Term Structure" in the Journal of Derivatives, which documented the predictive power of term structure dynamics.

MEAN REVERSION CHARACTERISTICS

One of the most practically useful properties of the VRP is its tendency to mean-revert. Extreme readings, whether high or low, tend to normalize over time. This creates opportunities for systematic trading strategies.

The indicator tracks VRP in statistical terms by calculating its Z-score relative to the trailing one-year distribution. A Z-score above two indicates that current VRP is more than two standard deviations above its mean, a statistically unusual condition. Similarly, a Z-score below negative two indicates VRP is unusually low.

Mean reversion signals trigger when VRP reaches extreme Z-score levels and then shows initial signs of reversal. A buy signal occurs when VRP recovers from oversold conditions (Z-score below negative two and rising), suggesting that the period of elevated realized volatility may be ending. A sell signal occurs when VRP contracts from overbought conditions (Z-score above two and falling), suggesting the fear premium may be excessive and due for normalization.

These signals should not be interpreted as standalone trading recommendations. They indicate probabilistic conditions based on historical patterns. Market context and other factors always matter.

MOMENTUM ANALYSIS

The rate of change in VRP carries its own information content. Rapidly rising VRP suggests fear is building faster than volatility is materializing, often seen in the early stages of corrections before realized volatility catches up. Rapidly falling VRP indicates either calming conditions or rising realized volatility eating into the premium.

The indicator tracks VRP momentum as the difference between current VRP and VRP from a specified number of bars ago. Positive momentum with positive acceleration suggests strengthening risk aversion. Negative momentum with negative acceleration suggests intensifying stress or rapid normalization from elevated levels.

PRACTICAL APPLICATION

For equity investors, the VRP provides context for risk management decisions. High VRP environments historically favor equity exposure because the market is pricing in more pessimism than typically materializes. Low or negative VRP environments suggest either reducing exposure or hedging, as markets may be underpricing risk.

For options traders, understanding VRP is fundamental to strategy selection. Strategies that sell volatility, such as covered calls, cash-secured puts, or iron condors, tend to profit when VRP is elevated and compress toward its mean. Strategies that buy volatility tend to profit when VRP is low and risk materializes.

For systematic traders, VRP provides a regime filter for other strategies. Momentum strategies may benefit from different parameters in high versus low VRP environments. Mean reversion strategies in VRP itself can form the basis of a complete trading system.

LIMITATIONS AND CONSIDERATIONS

No indicator provides perfect foresight, and the VRP is no exception. Several limitations deserve attention.

The VRP measures a relationship between two estimates, each subject to measurement error. The VIX represents expectations that may prove incorrect. Realized volatility calculations depend on the chosen method and lookback period.

Mean reversion tendencies hold over longer time horizons but provide limited guidance for short-term timing. VRP can remain extreme for extended periods, and mean reversion signals can generate losses if the extremity persists or intensifies.

The indicator is calibrated for equity markets, specifically the S&P 500. Application to other asset classes requires recalibration of thresholds and potentially different data sources.

Historical relationships between VRP and subsequent returns, while statistically robust, do not guarantee future performance. Structural changes in markets, options pricing, or investor behavior could alter these dynamics.

STATISTICAL OUTPUTS

The indicator presents comprehensive statistics including current VRP level, implied volatility from VIX, realized volatility from the selected method, current regime classification, number of bars in the current regime, percentile ranking over the lookback period, Z-score relative to recent history, mean VRP over the lookback period, realized volatility term structure slope, VRP momentum, mean reversion signal status, and overall market bias interpretation.

Color coding throughout the indicator provides immediate visual interpretation. Green tones indicate elevated VRP associated with fear and potential opportunity. Red tones indicate compressed or negative VRP associated with complacency or active stress. Neutral tones indicate normal market conditions.

ALERT CONDITIONS

The indicator provides alerts for regime transitions, extreme statistical readings, term structure inversions, mean reversion signals, and momentum shifts. These can be configured through the TradingView alert system for real-time monitoring across multiple timeframes.

REFERENCES

Bakshi, G., and Kapadia, N. (2003). Delta-Hedged Gains and the Negative Market Volatility Risk Premium. Review of Financial Studies, 16(2), 527-566.

Bollerslev, T., Tauchen, G., and Zhou, H. (2009). Expected Stock Returns and Variance Risk Premia. Review of Financial Studies, 22(11), 4463-4492.

Carr, P., and Wu, L. (2009). Variance Risk Premiums. Review of Financial Studies, 22(3), 1311-1341.

Garman, M. B., and Klass, M. J. (1980). On the Estimation of Security Price Volatilities from Historical Data. Journal of Business, 53(1), 67-78.

Mixon, S. (2007). The Implied Volatility Term Structure of Stock Index Options. Journal of Empirical Finance, 14(3), 333-354.

Parkinson, M. (1980). The Extreme Value Method for Estimating the Variance of the Rate of Return. Journal of Business, 53(1), 61-65.

---

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © EdgeTools
//
// Volatility Risk Premium (VRP)
// 
// Based on academic research:
// - Carr & Wu (2009): Variance Risk Premiums, Review of Financial Studies
// - Bollerslev, Tauchen & Zhou (2009): Expected Stock Returns and Variance Risk Premia
// - Bakshi & Kapadia (2003): Delta-Hedged Gains and the Negative Market Volatility Risk Premium
//
// The VRP measures the difference between implied volatility (VIX) and realized volatility.
// A positive VRP indicates investors pay a premium for volatility protection.
// Research shows VRP predicts future equity returns and signals market stress when negative.

//@version=6
indicator("Volatility Risk Premium", shorttitle="VRP", overlay=false, max_bars_back=5000)

// --- Inputs ---

// Core Settings
rv_length = input.int(20, "Realized Vol Period", minval=5, maxval=63, group="Core Settings")
rv_method = input.string("Close-to-Close", "RV Calculation Method", 
     options=["Close-to-Close", "Parkinson", "Garman-Klass"], group="Core Settings")
vrp_smoothing = input.int(5, "VRP Smoothing (EMA)", minval=1, maxval=21, group="Core Settings")
vrp_lookback = input.int(252, "Statistical Lookback", minval=60, maxval=1000, group="Core Settings")

// Regime Thresholds
threshold_high = input.float(5.0, "High VRP (%)", minval=1.0, maxval=15.0, step=0.5, group="Thresholds")
threshold_extreme = input.float(10.0, "Extreme VRP (%)", minval=5.0, maxval=20.0, step=0.5, group="Thresholds")
threshold_low = input.float(-2.0, "Low VRP (%)", minval=-10.0, maxval=2.0, step=0.5, group="Thresholds")

// Term Structure
rv_short = input.int(10, "Short-Term RV Period", minval=5, maxval=20, group="Term Structure")
rv_long = input.int(60, "Long-Term RV Period", minval=40, maxval=126, group="Term Structure")
show_term_structure = input.bool(false, "Show Term Structure Lines", group="Term Structure")

// Mean Reversion
mr_zscore_threshold = input.float(2.0, "Z-Score Threshold", minval=1.0, maxval=3.0, step=0.5, group="Mean Reversion")
show_mr_signals = input.bool(false, "Show MR Signals", group="Mean Reversion")
show_bollinger = input.bool(false, "Show VRP Bands", group="Mean Reversion")
bb_mult = input.float(2.0, "Band Multiplier", minval=1.0, maxval=3.0, step=0.5, group="Mean Reversion")

// Display
show_histogram = input.bool(true, "Histogram", group="Display")
show_line = input.bool(false, "Line", group="Display")
show_components = input.bool(false, "IV/RV Components", group="Display")
show_table = input.bool(true, "Statistics Panel", group="Display")
show_thresholds = input.bool(true, "Threshold Lines", group="Display")
show_background = input.bool(true, "Dynamic Background", group="Display")
color_candles = input.bool(true, "Color Candles", group="Display")
show_momentum = input.bool(false, "VRP Momentum", group="Display")
vrp_momentum_length = input.int(5, "Momentum Period", minval=1, maxval=20, group="Display")

// Appearance
color_scheme = input.string("EdgeTools", "Theme", 
     options=["EdgeTools", "Gold", "Ocean", "Fire", "Matrix", "Arctic"], group="Appearance")
use_dark_mode = input.bool(true, "Dark Mode", group="Appearance")
background_intensity = input.int(85, "Background Transparency", minval=70, maxval=95, step=5, group="Appearance")

// --- Color Definitions ---

color primary_color = switch color_scheme
    "EdgeTools" => use_dark_mode ? #3b82f6 : #2563eb
    "Gold" => use_dark_mode ? #FFD700 : #DAA520
    "Ocean" => use_dark_mode ? #20B2AA : #008B8B
    "Fire" => use_dark_mode ? #FF6347 : #DC143C
    "Matrix" => use_dark_mode ? #00FF41 : #006400
    "Arctic" => use_dark_mode ? #87CEFA : #4169E1
    => #3b82f6

color bullish_color = switch color_scheme
    "EdgeTools" => use_dark_mode ? #22c55e : #16a34a
    "Gold" => use_dark_mode ? #FFA500 : #FF8C00
    "Ocean" => use_dark_mode ? #00CED1 : #4682B4
    "Fire" => use_dark_mode ? #FFD700 : #FF8C00
    "Matrix" => use_dark_mode ? #39FF14 : #228B22
    "Arctic" => use_dark_mode ? #00BFFF : #0000CD
    => #22c55e

color bearish_color = switch color_scheme
    "EdgeTools" => use_dark_mode ? #ef4444 : #dc2626
    "Gold" => use_dark_mode ? #FF5252 : #D32F2F
    "Ocean" => use_dark_mode ? #FF4500 : #B22222
    "Fire" => use_dark_mode ? #8B0000 : #800000
    "Matrix" => use_dark_mode ? #FF073A : #8B0000
    "Arctic" => use_dark_mode ? #FF1493 : #8B008B
    => #ef4444

color neutral_color = switch color_scheme
    "EdgeTools" => use_dark_mode ? #737373 : #525252
    "Gold" => use_dark_mode ? #C0C0C0 : #808080
    "Ocean" => use_dark_mode ? #87CEEB : #2F4F4F
    "Fire" => use_dark_mode ? #FFA500 : #CD853F
    "Matrix" => use_dark_mode ? #00FFFF : #008B8B
    "Arctic" => use_dark_mode ? #B0E0E6 : #483D8B
    => #737373

color text_color = use_dark_mode ? #fafafa : #0a0a0a
color table_bg = use_dark_mode ? #171717 : #f9f9f9
color header_bg = use_dark_mode ? #262626 : #e5e5e5
table_transp = use_dark_mode ? 80 : 15

// --- Data Sources ---

vix = request.security("CBOE:VIX", timeframe.period, close, lookahead=barmerge.lookahead_off)

use_chart = syminfo.ticker == "SPY" or syminfo.ticker == "SPX" or syminfo.ticker == "ES1!"
spy_close = use_chart ? close : request.security("SPY", timeframe.period, close, lookahead=barmerge.lookahead_off)
spy_high = use_chart ? high : request.security("SPY", timeframe.period, high, lookahead=barmerge.lookahead_off)
spy_low = use_chart ? low : request.security("SPY", timeframe.period, low, lookahead=barmerge.lookahead_off)
spy_open = use_chart ? open : request.security("SPY", timeframe.period, open, lookahead=barmerge.lookahead_off)

// --- Realized Volatility Functions ---

log_ret = math.log(spy_close / nz(spy_close[1], spy_close))

calc_rv_ctc(int len) =>
    ta.stdev(log_ret, len) * math.sqrt(252) * 100

calc_rv_parkinson(int len) =>
    sum_sq = 0.0
    for i = 0 to len - 1
        if not na(spy_high[i]) and not na(spy_low[i]) and spy_low[i] > 0
            hl = math.log(spy_high[i] / spy_low[i])
            sum_sq += hl * hl
    math.sqrt(sum_sq / (4.0 * math.log(2.0) * len) * 252) * 100

calc_rv_gk(int len) =>
    sum_gk = 0.0
    for i = 0 to len - 1
        if not na(spy_high[i]) and not na(spy_low[i]) and not na(spy_open[i]) and not na(spy_close[i])
            if spy_low[i] > 0 and spy_open[i] > 0
                hl = math.log(spy_high[i] / spy_low[i])
                co = math.log(spy_close[i] / spy_open[i])
                sum_gk += 0.5 * hl * hl - (2 * math.log(2) - 1) * co * co
    math.sqrt(math.max(sum_gk / len, 0) * 252) * 100

get_rv(int len) =>
    switch rv_method
        "Close-to-Close" => calc_rv_ctc(len)
        "Parkinson" => calc_rv_parkinson(len)
        "Garman-Klass" => calc_rv_gk(len)
        => calc_rv_ctc(len)

// --- Core Calculations ---

realized_vol = get_rv(rv_length)
vrp_raw = vix - realized_vol
vrp = ta.ema(vrp_raw, vrp_smoothing)

// Statistics
vrp_mean = ta.sma(vrp, vrp_lookback)
vrp_stdev = ta.stdev(vrp, vrp_lookback)
vrp_zscore = (vrp - vrp_mean) / math.max(vrp_stdev, 0.001)
vrp_percentile = ta.percentrank(vrp, vrp_lookback)

// Term Structure
rv_short_val = get_rv(rv_short)
rv_long_val = get_rv(rv_long)
vrp_short = vix - rv_short_val
vrp_long = vix - rv_long_val
rv_slope = rv_long_val - rv_short_val

// Mean Reversion
vrp_upper = vrp_mean + bb_mult * vrp_stdev
vrp_lower = vrp_mean - bb_mult * vrp_stdev
mr_overbought = vrp_zscore >= mr_zscore_threshold
mr_oversold = vrp_zscore <= -mr_zscore_threshold
mr_long = mr_oversold and vrp > nz(vrp[1])
mr_short = mr_overbought and vrp < nz(vrp[1])

// Momentum
vrp_roc = vrp - nz(vrp[vrp_momentum_length])

// Regime
var int regime_bars = 0
var string last_regime = "NORMAL"

get_regime() =>
    if vrp >= threshold_extreme
        "EXTREME"
    else if vrp >= threshold_high
        "HIGH"
    else if vrp >= 0
        "NORMAL"
    else if vrp >= threshold_low
        "LOW"
    else
        "NEGATIVE"

regime = get_regime()
regime_change = regime != last_regime
regime_bars := regime_change ? 1 : regime_bars + 1
last_regime := regime

// --- Dynamic Colors ---

get_vrp_color() =>
    if vrp >= threshold_extreme
        color.from_gradient(vrp, threshold_extreme, threshold_extreme + 5, bullish_color, primary_color)
    else if vrp >= threshold_high
        bullish_color
    else if vrp >= 0
        color.from_gradient(vrp, 0, threshold_high, neutral_color, bullish_color)
    else if vrp >= threshold_low
        color.from_gradient(vrp, threshold_low, 0, bearish_color, neutral_color)
    else
        bearish_color

vrp_color = get_vrp_color()

get_bg_color() =>
    if vrp >= threshold_extreme
        color.from_gradient(vrp, threshold_extreme, threshold_extreme + 5, primary_color, bullish_color)
    else if vrp >= threshold_high
        color.from_gradient(vrp, threshold_high, threshold_extreme, bullish_color, primary_color)
    else if vrp >= 0
        color.from_gradient(vrp, 0, threshold_high, neutral_color, bullish_color)
    else if vrp >= threshold_low
        color.from_gradient(vrp, threshold_low, 0, bearish_color, neutral_color)
    else
        bearish_color

get_bg_opacity() =>
    abs_v = math.abs(vrp)
    max_ex = math.max(math.abs(threshold_extreme), math.abs(threshold_low))
    if abs_v >= max_ex
        int(math.max(70, math.min(75, 70 + (abs_v - max_ex) * 2)))
    else if abs_v >= threshold_high
        int(math.max(80, math.min(85, 80 + (abs_v - threshold_high))))
    else
        background_intensity

// --- Plotting ---

bgcolor(show_background ? color.new(get_bg_color(), get_bg_opacity()) : na, title="Background")
barcolor(color_candles ? vrp_color : na, title="Candles")

plot(show_histogram ? vrp : na, "VRP", vrp_color, style=plot.style_histogram, linewidth=3)
plot(show_line ? vrp : na, "VRP Line", vrp_color, linewidth=2)

hline(0, "Zero", color.new(neutral_color, 50))
plot(show_thresholds ? threshold_high : na, "High", color.new(bullish_color, 60))
plot(show_thresholds ? threshold_extreme : na, "Extreme", color.new(primary_color, 60))
plot(show_thresholds ? threshold_low : na, "Low", color.new(bearish_color, 60))

plot(show_components ? vix : na, "VIX", color.new(primary_color, 40))
plot(show_components ? realized_vol : na, "RV", color.new(bearish_color, 40))

plot(show_bollinger ? vrp_upper : na, "Upper Band", color.new(bullish_color, 70))
plot(show_bollinger ? vrp_lower : na, "Lower Band", color.new(bearish_color, 70))
plot(show_bollinger ? vrp_mean : na, "Mean", color.new(neutral_color, 50))

plotshape(show_mr_signals and mr_long, title="Buy", location=location.bottom, style=shape.triangleup, size=size.small, color=bullish_color)
plotshape(show_mr_signals and mr_short, title="Sell", location=location.top, style=shape.triangledown, size=size.small, color=bearish_color)

plot(show_term_structure ? vrp_short : na, "VRP Short", color.new(primary_color, 50))
plot(show_term_structure ? vrp_long : na, "VRP Long", color.new(neutral_color, 50))

mom_col = vrp_roc > 0 ? color.new(bullish_color, 60) : color.new(bearish_color, 60)
plot(show_momentum ? vrp_roc : na, "Momentum", mom_col, style=plot.style_histogram, linewidth=2)

// --- Statistics Panel ---

if show_table and barstate.islast
    var tbl = table.new(position.top_right, 2, 12, border_width=1, bgcolor=color.new(table_bg, table_transp))
    table.clear(tbl, 0, 0, 1, 11)
    
    table.cell(tbl, 0, 0, "VRP Analysis", text_color=text_color, bgcolor=color.new(header_bg, 20), text_size=size.small)
    table.cell(tbl, 1, 0, "", bgcolor=color.new(header_bg, 20))
    
    table.cell(tbl, 0, 1, "VRP", text_color=text_color, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(vrp, "#.##") + "%", text_color=vrp_color, text_size=size.small)
    
    table.cell(tbl, 0, 2, "VIX", text_color=text_color, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(vix, "#.##") + "%", text_color=color.new(primary_color, 40), text_size=size.small)
    
    table.cell(tbl, 0, 3, "Realized Vol", text_color=text_color, text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(realized_vol, "#.##") + "%", text_color=color.new(bearish_color, 40), text_size=size.small)
    
    reg_col = regime == "EXTREME" ? primary_color : regime == "HIGH" ? bullish_color : regime == "NORMAL" ? neutral_color : bearish_color
    table.cell(tbl, 0, 4, "Regime", text_color=text_color, text_size=size.small)
    table.cell(tbl, 1, 4, regime, text_color=reg_col, text_size=size.small)
    
    table.cell(tbl, 0, 5, "Duration", text_color=text_color, text_size=size.small)
    table.cell(tbl, 1, 5, str.tostring(regime_bars) + " bars", text_color=neutral_color, text_size=size.small)
    
    pct_col = vrp_percentile > 70 ? bullish_color : vrp_percentile < 30 ? bearish_color : neutral_color
    table.cell(tbl, 0, 6, "Percentile", text_color=text_color, text_size=size.small)
    table.cell(tbl, 1, 6, str.tostring(vrp_percentile, "#.#") + "%", text_color=pct_col, text_size=size.small)
    
    z_col = vrp_zscore > 1 ? bullish_color : vrp_zscore < -1 ? bearish_color : neutral_color
    table.cell(tbl, 0, 7, "Z-Score", text_color=text_color, text_size=size.small)
    table.cell(tbl, 1, 7, str.tostring(vrp_zscore, "#.##"), text_color=z_col, text_size=size.small)
    
    slope_col = rv_slope > 0 ? bullish_color : bearish_color
    table.cell(tbl, 0, 8, "RV Slope", text_color=text_color, text_size=size.small)
    table.cell(tbl, 1, 8, str.tostring(rv_slope, "#.##") + "%", text_color=slope_col, text_size=size.small)
    
    mom_tbl_col = vrp_roc > 0 ? bullish_color : bearish_color
    table.cell(tbl, 0, 9, "Momentum", text_color=text_color, text_size=size.small)
    table.cell(tbl, 1, 9, str.tostring(vrp_roc, "#.##"), text_color=mom_tbl_col, text_size=size.small)
    
    mr_txt = mr_overbought ? "OVERBOUGHT" : mr_oversold ? "OVERSOLD" : "NEUTRAL"
    mr_col = mr_overbought ? bearish_color : mr_oversold ? bullish_color : neutral_color
    table.cell(tbl, 0, 10, "MR Status", text_color=text_color, text_size=size.small)
    table.cell(tbl, 1, 10, mr_txt, text_color=mr_col, text_size=size.small)
    
    bias_txt = vrp > threshold_high ? "RISK-ON" : vrp < 0 ? "RISK-OFF" : "NEUTRAL"
    bias_col = vrp > threshold_high ? bullish_color : vrp < 0 ? bearish_color : neutral_color
    table.cell(tbl, 0, 11, "Bias", text_color=text_color, text_size=size.small)
    table.cell(tbl, 1, 11, bias_txt, text_color=bias_col, text_size=size.small)

// --- Alerts ---

alertcondition(vrp >= threshold_extreme, "Extreme VRP", "VRP extreme high - elevated risk aversion")
alertcondition(vrp >= threshold_high and vrp < threshold_extreme, "High VRP", "VRP above normal - risk premium elevated")
alertcondition(vrp < threshold_low, "Negative VRP", "VRP negative - realized exceeds implied (stress)")
alertcondition(ta.cross(vrp, 0), "Zero Cross", "VRP crossed zero line")
alertcondition(math.abs(vrp_zscore) > 2, "Z-Score Extreme", "VRP statistically extreme")
alertcondition(mr_long, "MR Buy Signal", "VRP mean reversion buy signal")
alertcondition(mr_short, "MR Sell Signal", "VRP mean reversion sell signal")
alertcondition(ta.crossunder(rv_slope, 0), "Term Structure Inversion", "Short-term RV exceeds long-term (stress)")
alertcondition(ta.crossover(rv_slope, 0), "Term Structure Normal", "Term structure normalized")
alertcondition(regime_change, "Regime Change", "VRP regime changed")
````
