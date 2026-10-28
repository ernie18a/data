# Market Entropy Index

- url: https://www.tradingview.com/script/qxuj6cTf-Market-Entropy-Index/
- type: indicator
- pine_id: PUB;9478e3bb4fb548239ebae1dd631bd53c
- version: 1.0

## Description

Market Entropy Index (MEI)

Most risk indicators react to price. They measure what has already happened. The Market Entropy Index takes a different approach: it measures the structural organization of the market itself, identifying fragility before it becomes visible in price. When sector participation narrows, when sectors stop agreeing on direction, and when credit markets become complacent, the MEI detects these precursor conditions. It applies information theoretic entropy to three independent dimensions of market structure, producing a single composite that distinguishes broad, healthy markets from concentrated, fragile ones. This makes it a leading indicator of structural risk, not a coincident crash detector.


What entropy means in financial markets

Entropy, as formalized by Shannon (1948), quantifies uncertainty in a probability distribution. In information theory, a distribution where all outcomes are equally likely has maximum entropy. A distribution concentrated on a single outcome has minimum entropy. Applied to financial markets, this framework has been used in two distinct ways that should not be confused.

The first is temporal return entropy: measuring how the distribution of an index's daily returns changes over time. Risso (2008) showed that Shannon entropy of stock market return distributions drops before financial crashes, as returns become more extreme and less uniformly distributed. Zunino et al. (2009) found that permutation entropy of return series tracks market efficiency and deteriorates during stress. Gu (2017) extended this to multiple time scales. These studies all measure the statistical properties of a single return series over time.

The second is cross-sectional entropy, which is what the MEI uses. Instead of asking "how are returns distributed over time?", it asks "how is market activity distributed across sectors right now?" When all nine S&P 500 GICS sectors contribute equally to market movement, the entropy of their return distribution reaches its theoretical maximum: roughly log2(9) = 3.17 bits. This corresponds to broad, healthy participation. When movement concentrates in two or three sectors while the rest are flat, entropy drops. The market relies on a narrow base.

These two types of entropy can move in opposite directions. During an acute crash, temporal return entropy drops (Risso's finding: returns become extreme and non-normal). But cross-sectional breadth entropy often rises, because all sectors sell off together, producing a more uniform distribution across the cross-section. The MEI does not measure temporal return entropy. It measures cross-sectional breadth entropy and two related structural conditions. This distinction matters for interpretation (see the section on what the MEI does not do).


How the MEI is constructed

The indicator combines three dimensions, each measuring a distinct aspect of market fragility. All three were validated through statistical screening with Bonferroni correction across seven different parameter configurations to guard against data-mining bias.

Sector Breadth Concentration (weight: 0.40)

This is the primary dimension. It computes the Shannon entropy of the distribution of smoothed absolute returns across nine GICS sector ETFs (XLB, XLE, XLF, XLI, XLK, XLP, XLU, XLV, XLY) over a 21-day rolling window. The entropy value is normalized to the theoretical maximum so it ranges from 0 (all activity in one sector) to 1 (perfectly uniform distribution).

The critical finding from backtesting: low sector entropy (concentrated breadth) is the danger condition, not high entropy. When market movement narrows to a few sectors, the rally or sell-off lacks structural support. This is consistent with the well-documented market breadth divergence effect: narrow rallies tend to precede corrections. In our testing, the low-entropy tercile showed significantly worse forward returns than the high-entropy tercile across a 21-day horizon (spread = +1.18%, t = 5.81, p = 7.3e-09, Bonferroni-significant in all seven parameter configurations).

Sector Directional Discord (weight: 0.30)

This dimension measures the fraction of sectors that agree on daily direction (all up or all down), averaged over 21 days. When eight of nine sectors move in the same direction, concordance is high, indicating a coherent market. When sectors split nearly evenly between positive and negative days, concordance drops, signaling confusion, rotation, or conflicting macro forces.

Low concordance (high discord) is the danger condition. Sectors disagreeing on direction means the market lacks conviction and is vulnerable to dislocations. This dimension was Bonferroni-significant in five of seven parameter configurations (21d: spread = +0.97%, t = 5.20, p = 2.2e-07).

Credit Complacency (weight: 0.30)

The third dimension measures the rolling standard deviation of the daily return spread between iShares High Yield Corporate Bond ETF (HYG) and iShares Investment Grade Corporate Bond ETF (LQD), normalized by its 252-day average. This ratio captures how volatile credit spreads are relative to their recent history.

Low credit spread volatility is the danger condition. When credit markets are calm and spreads barely move, it often reflects complacent risk pricing. The empirical parallel is well-supported: Gilchrist and Zakrajsek (2012) showed that credit spread dynamics, specifically the excess bond premium, predict economic downturns and equity returns. In our testing, this dimension produced the strongest individual t-statistic (63d: spread = +1.89%, t = 6.73, p = 2.2e-11, Bonferroni-significant in three of seven configurations).

Signal processing

Each dimension is z-scored over a 252-day lookback and clipped at three standard deviations. The z-scores are sign-inverted so that high values consistently indicate danger across all three dimensions. After weighting, the composite is re-standardized over 252 days to restore the variance lost through averaging weakly correlated signals. The result is scaled to a 0-10 range (5.0 + z * 2.0) and smoothed with a Kaufman Adaptive Moving Average (Kaufman, 2013). The KAMA adjusts its smoothing speed based on the efficiency ratio of the composite: during clear regime transitions, it responds quickly; during choppy sideways periods, it filters noise. A minimum smoothing constant floor prevents the filter from becoming excessively sluggish.


How to read the MEI

0 to 3: Low Risk. All three dimensions read safe. Sectors participate broadly, agree on direction, and credit markets are actively pricing risk. These conditions are historically associated with favorable forward equity returns.

3 to 7: Normal. No structural signal in either direction. The market is in equilibrium. This is the expected reading roughly two-thirds of the time.

7 to 10: Elevated Risk. One or more dimensions show stress. Sector participation is narrowing, directional agreement is breaking down, or credit markets have become complacent. The higher the reading, the more dimensions agree on risk.

The dashboard shows each dimension individually, so you can diagnose what is driving the composite. The historical percentile tells you where the current reading sits relative to the past 252 days. The trend direction (with arrow symbols) shows whether risk is rising or falling.


What the MEI detects and what it does not

The MEI is a leading indicator of structural fragility, not a coincident crash detector. It measures conditions that build up before market stress: narrowing sector participation, loss of directional agreement, and complacent credit pricing. These are precursor conditions. They describe a market that has become structurally fragile, not one that is already falling apart.

During an acute sell off, the MEI typically drops toward the green zone. This is not a malfunction. When all sectors sell off together, breadth entropy actually increases (uniform distribution across sectors), concordance rises (all sectors agree on the down direction), and credit spread volatility spikes (the opposite of complacency). All three dimensions read "safe" precisely because the structural fragility has already resolved through the sell-off itself.

The practical implication: the MEI is most useful in the quiet periods before stress, when markets look calm but the underlying structure is deteriorating. If the MEI reads 8 while the SPX is making new highs, that is a warning worth paying attention to. If the MEI reads 2 during a violent correction, that means the correction is broad-based and structural participation is actually healthy, which is historically a better setup for recovery than a narrow, concentrated decline.


How to use it in practice

The MEI is a regime monitor, not a timing signal. It answers the question "what kind of market are we in?" rather than "should I buy or sell today?" The most productive way to use it:

As a confluence filter: combine the MEI with your existing trend-following or mean-reversion strategy. When the MEI reads above 7, tighten stops, reduce position sizes, or require stronger entry signals. When it reads below 3, conditions favor taking positions.

As an allocation tool: for portfolio managers running multi-asset or tactical allocation, the MEI provides a daily structural risk reading that can scale equity exposure. Reduce equity allocation when the composite is elevated, increase when it is low.

As a diagnostic tool: enable the individual components (Breadth Concentration, Directional Discord, Credit Complacency) to understand what is driving the composite. If only one dimension is elevated while the others are normal, the risk may be localized. If all three converge, the structural case is stronger.

For monitoring credit conditions: the Credit Complacency dimension alone serves as a real-time gauge of credit market risk pricing. Low readings (complacency) have historically preceded episodes of spread widening.


Quant fund applications

For systematic portfolio managers and quantitative research teams, the MEI framework offers several practical applications.

As a regime classifier for conditional strategies: most equity strategies behave differently in ordered versus disordered markets. Momentum strategies, for example, tend to work well when breadth entropy is high (broad participation) and poorly when it is low (concentrated leadership). The MEI provides a daily regime classification that can condition strategy selection or parameter adjustment. In our backtesting, the composite showed a spread of +2.86% (21-day forward returns, t = 5.91) in high-volatility regimes, offering a quantitatively meaningful signal for regime-conditional allocation.

As a risk budget input: the three z-scored danger signals can feed directly into a risk budgeting framework. When breadth_danger or credit_danger exceeds one standard deviation, the risk model can automatically reduce gross exposure or hedge tail risk. The low cross-correlation between dimensions (breadth-credit: rho = -0.07, breadth-discord: rho = 0.20) means each dimension adds genuine incremental information to the risk estimate.

As an alpha decay monitor: sector concentration (low breadth entropy) is one mechanism through which crowded trades develop. When the breadth dimension rises, it may indicate that a previously broad factor exposure has narrowed to a few names or sectors, which is a warning sign for factor crowding and potential alpha decay.

As a multi-asset overlay: the framework extends naturally beyond equities. The same entropy-based approach can be applied to any cross-section of assets (currencies, commodities, fixed income sectors) to detect concentration and complacency.


Limitations

This indicator has clear boundaries that users should understand.

It detects fragility, not crashes. The MEI measures structural precursors (concentration, complacency, discord) that build up before stress events. During acute sell-offs, the indicator typically drops because the conditions it measures dissolve once panic selling is broad-based. Do not expect the MEI to read red during a crash. Expect it to read red before one.

The signal is regime-dependent. In high-volatility and bear markets, the composite works as designed: high readings correspond to worse forward returns, low readings to better. In calm, trending bull markets, the relationship weakens and can reverse. This is because the "danger" conditions (concentrated breadth, credit complacency) can persist for extended periods during healthy trends without leading to corrections. Weight MEI readings more heavily when realized volatility is already elevated.

It is designed for the S&P 500. The sector ETFs and credit instruments are U.S.-specific. Applying the indicator to other indices or asset classes without modifying the data sources would not be methodologically sound.

It requires a daily timeframe. The cross-sector entropy and credit spread calculations require daily closing prices. Intraday data introduces noise that degrades the signal quality.

It needs historical depth. The z-score normalization uses a 252-day lookback. Results during the first year of data should be treated with caution.

It is not a standalone system. No single indicator captures all relevant market dynamics. The MEI measures structural conditions. It does not measure momentum, valuation, sentiment, or liquidity directly. Use it alongside other analytical tools.


References

Gilchrist, S. and Zakrajsek, E. (2012) 'Credit Spreads and Business Cycle Fluctuations', American Economic Review, 102(4), pp. 1692-1720.

Gu, R. (2017) 'Multiscale Shannon entropy and its application in the stock market', Physica A, 484, pp. 215-224.

Kaufman, P.J. (2013) Trading Systems and Methods. 5th edn. Hoboken: Wiley.

Risso, W.A. (2008) 'The informational efficiency and the financial crashes', Research in International Business and Finance, 22(3), pp. 396-408.

Shannon, C.E. (1948) 'A Mathematical Theory of Communication', Bell System Technical Journal, 27(3), pp. 379-423.

Zunino, L., Zanin, M., Tabak, B.M., Perez, D.G. and Rosso, O.A. (2009) 'Forbidden patterns, permutation entropy and stock market inefficiency', Physica A, 388(14), pp. 2854-2864.

## Source Code

````pine
//@version=6
// This Pine Script(TM) code is subject to the terms of the Mozilla Public License 2.0
// (c) EdgeTools
//
// Market Entropy Index (MEI)
//
// Detects structural risk in the S&P 500 through three entropy-derived
// dimensions. Each dimension captures a distinct facet of market fragility
// that is invisible in price alone. The composite is sign-aligned so that
// HIGH values indicate elevated structural risk, LOW values indicate
// favorable conditions with broad participation.
//
// Dimensions:
//   1. Sector Breadth Concentration (w=0.40)
//      Shannon entropy of absolute returns across 9 GICS sector ETFs.
//      Low entropy means market movement concentrates in few sectors, a
//      well-documented precursor to broader weakness.
//      Bonferroni-significant in 7/7 parameter configurations.
//
//   2. Sector Directional Discord (w=0.30)
//      Fraction of sectors agreeing on daily direction, averaged over 21 days.
//      Low agreement signals confusion and sector rotation stress.
//      Bonferroni-significant in 5/7 parameter configurations.
//
//   3. Credit Complacency (w=0.30)
//      HYG-LQD spread volatility relative to its 252-day average.
//      Low credit spread volatility signals complacent credit markets and
//      underpriced tail risk.
//      Bonferroni-significant in 3/7 parameter configurations.
//
// How to use:
//   0-3:  Low Risk. Broad sector participation, directional agreement,
//         active credit pricing. Historically favorable forward returns.
//   3-7:  Normal. No structural signal in either direction.
//   7-10: Elevated Risk. Concentrated breadth, sector discord, credit
//         complacency. Strongest during volatile or bearish markets.
//
// Interpretation:
//   The MEI is a regime monitor, not a timing signal. It identifies
//   structural conditions associated with elevated or reduced risk.
//   Use it as a confluence filter alongside price-based analysis.
//   Enable individual components to diagnose which dimension is driving
//   the composite reading.
//
// Limitations:
//   - Designed for SPX/SPY on daily timeframe. Other assets or
//     intraday timeframes lack the cross-sector data this requires.
//   - Signal is strongest in high-volatility and bear markets.
//     In calm bull markets, the risk signal can reverse direction.
//     Weight readings more heavily when realized volatility is elevated.
//   - Requires 252+ bars of history for stable z-score normalization.
//   - Not a standalone buy/sell signal. Use as context alongside
//     trend, momentum, or fundamental analysis.
//
// References:
//   Shannon, C.E. (1948). A Mathematical Theory of Communication.
//     Bell System Technical Journal, 27(3), pp. 379-423.
//   Kaufman, P.J. (2013). Trading Systems and Methods. 5th ed. Wiley.
//   Zunino, L. et al. (2009). Forbidden patterns, permutation entropy
//     and stock market inefficiency. Physica A, 388(14), pp. 2854-2864.

indicator("Market Entropy Index", shorttitle="MEI", overlay=false,
     max_lines_count=500, max_bars_back=5000)

// Calibrated parameters from backtesting across 7 parameter configurations
BREADTH_WINDOW = 21
CREDIT_WINDOW  = 21
ZSCORE_WINDOW  = 252
KAMA_FAST      = 5
KAMA_SLOW      = 42
KAMA_ER_LEN    = 21
W_BREADTH      = 0.40
W_CONC         = 0.30
W_CREDIT       = 0.30

// --- Inputs: Components ---

show_breadth = input.bool(false, "Show Breadth Concentration", group="Components",
    tooltip="Sector breadth danger signal (purple). High = concentrated market = risk. " +
            "Based on Shannon entropy of absolute returns across 9 GICS sector ETFs.")
show_discord = input.bool(false, "Show Directional Discord", group="Components",
    tooltip="Concordance danger signal (cyan). High = sectors disagree on direction = risk. " +
            "Measures the fraction of sectors moving in the same direction each day.")
show_credit  = input.bool(false, "Show Credit Complacency", group="Components",
    tooltip="Credit danger signal (orange). High = low HYG-LQD spread volatility = " +
            "complacent credit market = underpriced tail risk.")

// --- Inputs: Display ---

low_threshold  = input.float(3.0, "Low Risk Threshold", minval=0.5, maxval=4.5, step=0.5, group="Display",
    tooltip="MEI values below this level indicate low structural risk.")
high_threshold = input.float(7.0, "High Risk Threshold", minval=5.5, maxval=9.5, step=0.5, group="Display",
    tooltip="MEI values above this level indicate elevated structural risk.")
show_trend     = input.bool(true, "Show Trend Line", group="Display",
    tooltip="EMA(21) of the MEI composite for direction context.")
show_bands     = input.bool(true, "Show Volatility Bands", group="Display",
    tooltip="Standard deviation bands around the composite signal.")
bg_mode        = input.string("Dynamic", "Background Shading",
    options=["Off", "Dynamic"], group="Display",
    tooltip="Gradient background that shifts color with the risk level.")
bg_intensity   = input.int(88, "Background Transparency", minval=70, maxval=95, step=5, group="Display")

// --- Inputs: Candle Coloring ---

show_candles     = input.bool(false, "Color Candles by Risk", group="Candle Coloring",
    tooltip="Tint candles green in low-risk zones, red in high-risk zones.")
candle_base_tr   = input.int(30, "Base Transparency", minval=0, maxval=60, step=5, group="Candle Coloring")

// --- Inputs: Dashboard ---

show_dashboard = input.bool(true, "Show Dashboard", group="Dashboard",
    tooltip="Compact analytics panel showing all dimensions, composite z-score, " +
            "historical percentile, and trend direction.")
dash_position  = input.string("Top Right", "Position",
    options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"],
    group="Dashboard")
dash_size      = input.string("Normal", "Size",
    options=["Tiny", "Small", "Normal", "Large"], group="Dashboard")

// --- Inputs: Watermark ---

show_watermark = input.bool(true, "Show Watermark", group="Watermark")
wm_position    = input.string("Bottom Right", "Position",
    options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"],
    group="Watermark")
wm_size        = input.string("Large", "Size",
    options=["Small", "Normal", "Large", "Huge"], group="Watermark")

// --- Inputs: Appearance ---

color_scheme  = input.string("EdgeTools", "Color Theme",
    options=["Gold", "EdgeTools", "Behavioral", "Quant", "Ocean", "Fire", "Matrix", "Arctic"],
    group="Appearance")
use_dark      = input.bool(true, "Optimize for Dark Theme", group="Appearance")
line_width    = input.int(2, "Main Line Width", minval=1, maxval=5, group="Appearance")
enable_glow   = input.bool(false, "Glow Effect", group="Appearance",
    tooltip="Soft halo around the main signal line for better visibility.")

// --- Inputs: Alerts ---

enable_alerts = input.bool(false, "Enable Alerts", group="Alerts",
    tooltip="Activate all alert conditions. Create alerts via the TradingView alert dialog.")

// Color scheme definitions

var color clr_primary = #2196F3
var color clr_bull    = #4CAF50
var color clr_bear    = #FF5252
var color clr_neutral = #808080
var color clr_text    = color.white
var color clr_tbl_bg  = #1E1E1E
var color clr_hdr_bg  = #2D2D2D

switch color_scheme
    "Gold" =>
        clr_primary := use_dark ? #FFD700 : #DAA520
        clr_bull    := use_dark ? #FFA500 : #FF8C00
        clr_bear    := use_dark ? #FF5252 : #D32F2F
        clr_neutral := use_dark ? #C0C0C0 : #808080
        clr_text    := use_dark ? color.white : color.black
        clr_tbl_bg  := use_dark ? #1A1A00 : #FFFEF0
        clr_hdr_bg  := use_dark ? #2D2600 : #F5F5DC
    "EdgeTools" =>
        clr_primary := use_dark ? #3b82f6 : #2563eb
        clr_bull    := use_dark ? #22c55e : #16a34a
        clr_bear    := use_dark ? #ef4444 : #dc2626
        clr_neutral := use_dark ? #737373 : #525252
        clr_text    := use_dark ? #fafafa : #0a0a0a
        clr_tbl_bg  := use_dark ? #171717 : #f9f9f9
        clr_hdr_bg  := use_dark ? #262626 : #e5e5e5
    "Behavioral" =>
        clr_primary := #808080
        clr_bull    := #00FF00
        clr_bear    := #8B0000
        clr_neutral := #FFBF00
        clr_text    := use_dark ? color.white : color.black
        clr_tbl_bg  := use_dark ? #1A1A1A : #F8F8F8
        clr_hdr_bg  := use_dark ? #2D2D2D : #E8E8E8
    "Quant" =>
        clr_primary := #808080
        clr_bull    := #FFA500
        clr_bear    := #8B0000
        clr_neutral := #4682B4
        clr_text    := use_dark ? color.white : color.black
        clr_tbl_bg  := use_dark ? #0D0D0D : #FAFAFA
        clr_hdr_bg  := use_dark ? #1A1A1A : #F0F0F0
    "Ocean" =>
        clr_primary := use_dark ? #20B2AA : #008B8B
        clr_bull    := use_dark ? #00CED1 : #4682B4
        clr_bear    := use_dark ? #FF4500 : #B22222
        clr_neutral := use_dark ? #87CEEB : #2F4F4F
        clr_text    := use_dark ? #F0F8FF : #191970
        clr_tbl_bg  := use_dark ? #001A2E : #E6F7FF
        clr_hdr_bg  := use_dark ? #002A47 : #CCF2FF
    "Fire" =>
        clr_primary := use_dark ? #FF6347 : #DC143C
        clr_bull    := use_dark ? #FFD700 : #FF8C00
        clr_bear    := use_dark ? #8B0000 : #800000
        clr_neutral := use_dark ? #FFA500 : #CD853F
        clr_text    := use_dark ? #FFFAF0 : #2F1B14
        clr_tbl_bg  := use_dark ? #261611 : #FFF8F0
        clr_hdr_bg  := use_dark ? #3D241A : #FFE4CC
    "Matrix" =>
        clr_primary := use_dark ? #00FF41 : #006400
        clr_bull    := use_dark ? #39FF14 : #228B22
        clr_bear    := use_dark ? #FF073A : #8B0000
        clr_neutral := use_dark ? #00FFFF : #008B8B
        clr_text    := use_dark ? #C0FF8C : #003300
        clr_tbl_bg  := use_dark ? #0A1A0A : #E8FFF0
        clr_hdr_bg  := use_dark ? #112B11 : #CCFFCC
    "Arctic" =>
        clr_primary := use_dark ? #87CEFA : #4169E1
        clr_bull    := use_dark ? #00BFFF : #0000CD
        clr_bear    := use_dark ? #FF1493 : #8B008B
        clr_neutral := use_dark ? #B0E0E6 : #483D8B
        clr_text    := use_dark ? #F8F8FF : #191970
        clr_tbl_bg  := use_dark ? #141B47 : #F0F8FF
        clr_hdr_bg  := use_dark ? #1E2A5C : #E0F0FF

zone_tr  = use_dark ? 90 : 95
band_tr  = use_dark ? 70 : 85
tbl_tr   = use_dark ? 80 : 15

// Helper functions

f_table_pos(string p) =>
    switch p
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Top Center"    => position.top_center
        "Bottom Center" => position.bottom_center
        => position.top_right

f_text_sz(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

f_zscore(series float src, int window) =>
    float mu = ta.sma(src, window)
    float sigma = ta.stdev(src, window)
    float z = sigma > 0 ? (src - mu) / sigma : 0.0
    math.max(-3.0, math.min(3.0, z))

f_kama(series float src, int er_len, int fast_len, int slow_len) =>
    float fa = 2.0 / (fast_len + 1.0)
    float sa = 2.0 / (slow_len + 1.0)
    float min_sc = sa * sa * 1.5
    float dir = math.abs(src - src[er_len])
    float vol = math.sum(math.abs(src - src[1]), er_len)
    float er = vol != 0 ? dir / vol : 0.0
    float sc = math.max(min_sc, math.pow(er * (fa - sa) + sa, 2))
    var float k = na
    k := na(k) ? src : k + sc * (src - k)
    k

f_safe_ret(series float c) =>
    not na(c) and not na(c[1]) and c[1] != 0 ? c / c[1] - 1.0 : 0.0

// Data: 9 sector ETFs + 2 credit ETFs (11 request.security calls)

get_daily(simple string sym) =>
    request.security(sym, "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

xlb = get_daily("XLB")
xle = get_daily("XLE")
xlf = get_daily("XLF")
xli = get_daily("XLI")
xlk = get_daily("XLK")
xlp = get_daily("XLP")
xlu = get_daily("XLU")
xlv = get_daily("XLV")
xly = get_daily("XLY")
hyg = get_daily("HYG")
lqd = get_daily("LQD")

// Dimension 1: Sector Breadth Concentration
// Shannon entropy H of absolute return distribution across 9 sectors.
// Inverted: low H (concentrated) = high danger.

r_xlb = f_safe_ret(xlb)
r_xle = f_safe_ret(xle)
r_xlf = f_safe_ret(xlf)
r_xli = f_safe_ret(xli)
r_xlk = f_safe_ret(xlk)
r_xlp = f_safe_ret(xlp)
r_xlu = f_safe_ret(xlu)
r_xlv = f_safe_ret(xlv)
r_xly = f_safe_ret(xly)

a1 = ta.sma(math.abs(r_xlb), BREADTH_WINDOW)
a2 = ta.sma(math.abs(r_xle), BREADTH_WINDOW)
a3 = ta.sma(math.abs(r_xlf), BREADTH_WINDOW)
a4 = ta.sma(math.abs(r_xli), BREADTH_WINDOW)
a5 = ta.sma(math.abs(r_xlk), BREADTH_WINDOW)
a6 = ta.sma(math.abs(r_xlp), BREADTH_WINDOW)
a7 = ta.sma(math.abs(r_xlu), BREADTH_WINDOW)
a8 = ta.sma(math.abs(r_xlv), BREADTH_WINDOW)
a9 = ta.sma(math.abs(r_xly), BREADTH_WINDOW)

total_a = a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9

var float h_breadth = na
if total_a > 0
    float max_h = math.log(9) / math.log(2.0)
    float p1 = a1 / total_a, float p2 = a2 / total_a, float p3 = a3 / total_a
    float p4 = a4 / total_a, float p5 = a5 / total_a, float p6 = a6 / total_a
    float p7 = a7 / total_a, float p8 = a8 / total_a, float p9 = a9 / total_a
    float h = 0.0
    if p1 > 0
        h -= p1 * (math.log(p1) / math.log(2.0))
    if p2 > 0
        h -= p2 * (math.log(p2) / math.log(2.0))
    if p3 > 0
        h -= p3 * (math.log(p3) / math.log(2.0))
    if p4 > 0
        h -= p4 * (math.log(p4) / math.log(2.0))
    if p5 > 0
        h -= p5 * (math.log(p5) / math.log(2.0))
    if p6 > 0
        h -= p6 * (math.log(p6) / math.log(2.0))
    if p7 > 0
        h -= p7 * (math.log(p7) / math.log(2.0))
    if p8 > 0
        h -= p8 * (math.log(p8) / math.log(2.0))
    if p9 > 0
        h -= p9 * (math.log(p9) / math.log(2.0))
    h_breadth := max_h > 0 ? h / max_h : 0.0
else
    h_breadth := na

breadth_danger = ta.ema(-f_zscore(h_breadth, ZSCORE_WINDOW), 10)

// Dimension 2: Sector Directional Discord
// Daily concordance: |fraction_positive - 0.5| * 2, averaged over window.
// Inverted: low concordance (sectors disagree) = high danger.

n_pos = (r_xlb > 0 ? 1.0 : 0.0) + (r_xle > 0 ? 1.0 : 0.0) + (r_xlf > 0 ? 1.0 : 0.0) +
         (r_xli > 0 ? 1.0 : 0.0) + (r_xlk > 0 ? 1.0 : 0.0) + (r_xlp > 0 ? 1.0 : 0.0) +
         (r_xlu > 0 ? 1.0 : 0.0) + (r_xlv > 0 ? 1.0 : 0.0) + (r_xly > 0 ? 1.0 : 0.0)

concordance_avg = ta.sma(math.abs(n_pos / 9.0 - 0.5) * 2.0, BREADTH_WINDOW)
conc_danger     = ta.ema(-f_zscore(concordance_avg, ZSCORE_WINDOW), 10)

// Dimension 3: Credit Complacency
// HYG-LQD spread return volatility normalized by its 252d mean.
// Inverted: low vol (complacent) = high danger.

spread_vol    = ta.stdev(f_safe_ret(hyg) - f_safe_ret(lqd), CREDIT_WINDOW)
spread_vol_ma = ta.sma(spread_vol, 252)
credit_raw    = spread_vol_ma > 0 ? spread_vol / spread_vol_ma : 1.0
credit_danger = ta.ema(-f_zscore(credit_raw, ZSCORE_WINDOW), 10)

// Composite: weighted, re-standardized, adaptively smoothed

composite_raw = breadth_danger * W_BREADTH + conc_danger * W_CONC + credit_danger * W_CREDIT
composite_z   = f_zscore(composite_raw, ZSCORE_WINDOW)
signal_raw    = 5.0 + composite_z * 2.0
signal_kama   = f_kama(signal_raw, KAMA_ER_LEN, KAMA_FAST, KAMA_SLOW)
signal_value  = math.max(0.0, math.min(10.0, signal_kama))

// Classification and trend

is_low  = signal_value <= low_threshold
is_high = signal_value >= high_threshold

zone_str   = is_low ? "LOW RISK" : is_high ? "ELEVATED RISK" : "NORMAL"
regime_str = is_low ? "BROAD/ACTIVE" : is_high ? "CONCENTRATED" : "EQUILIBRIUM"

trend_ema = ta.ema(signal_value, 21)
trend_dir = trend_ema > trend_ema[1] ? 1 : trend_ema < trend_ema[1] ? -1 : 0
trend_str = trend_dir > 0 ? "RISING" : trend_dir < 0 ? "FALLING" : "SIDEWAYS"
trend_sym = trend_dir > 0 ? " ▲" : trend_dir < 0 ? " ▼" : " ■"

mei_std    = ta.stdev(signal_value, 10)
upper_band = signal_value + mei_std
lower_band = signal_value - mei_std

// Percentile rank over 252 bars for dashboard context
mei_pctile = ta.percentrank(signal_value, ZSCORE_WINDOW)

// Rate of change over 21 bars
mei_roc = nz(signal_value - signal_value[21])

// Zone color logic

zone_color = is_low ? clr_bull : is_high ? clr_bear : clr_primary

var color bg_color = na
if bg_mode == "Dynamic"
    if signal_value <= 4.0
        bg_color := color.from_gradient(signal_value, 0.0, 4.0, clr_bull, clr_primary)
    else if signal_value >= 6.0
        bg_color := color.from_gradient(signal_value, 6.0, 10.0, clr_primary, clr_bear)
    else
        bg_color := clr_primary
else
    bg_color := na

bgcolor(not na(bg_color) ? color.new(bg_color, bg_intensity) : na, title="Risk Background")

// Candle coloring

f_candle_clr() =>
    if signal_value >= 7.0
        int tr = signal_value >= 8.5 ? candle_base_tr : candle_base_tr + 25
        color.new(clr_bear, tr)
    else if signal_value <= 3.0
        int tr = signal_value <= 1.5 ? candle_base_tr : candle_base_tr + 25
        color.new(clr_bull, tr)
    else
        color.new(clr_primary, candle_base_tr + 35)

barcolor(show_candles ? f_candle_clr() : na, title="Risk Candle Color")

// Plots

plot(enable_glow ? signal_value : na, title="Glow 3", color=color.new(zone_color, 95), linewidth=line_width + 6)
plot(enable_glow ? signal_value : na, title="Glow 2", color=color.new(zone_color, 90), linewidth=line_width + 4)
plot(enable_glow ? signal_value : na, title="Glow 1", color=color.new(zone_color, 80), linewidth=line_width + 2)

plot(signal_value, title="MEI Composite", color=zone_color, linewidth=line_width)
plot(show_trend ? trend_ema : na, title="Trend EMA", color=color.new(clr_primary, 40), linewidth=1)

p_upper = plot(show_bands ? upper_band : na, title="Upper Band", color=color.new(color.gray, band_tr), display=display.none)
p_lower = plot(show_bands ? lower_band : na, title="Lower Band", color=color.new(color.gray, band_tr), display=display.none)
fill(p_upper, p_lower, color=show_bands ? color.new(color.gray, band_tr) : na, title="Volatility Band")

p_lo = plot(float(low_threshold), color=color.new(clr_bull, 40), linewidth=1, title="Low Threshold")
p_hi = plot(float(high_threshold), color=color.new(clr_bear, 40), linewidth=1, title="High Threshold")
fill(p_lo, p_hi, color=color.new(clr_primary, zone_tr), title="Normal Zone Fill")

plot(5.0, "Midline", color=color.new(clr_neutral, 60), linewidth=1)

// Component overlays scaled to the same 0-10 range as the composite

plot(show_breadth ? 5.0 + nz(breadth_danger) * 1.67 : na, title="Breadth Concentration",
     color=color.new(#a855f7, 40), linewidth=1)
plot(show_discord ? 5.0 + nz(conc_danger) * 1.67 : na, title="Directional Discord",
     color=color.new(#06b6d4, 40), linewidth=1)
plot(show_credit ? 5.0 + nz(credit_danger) * 1.67 : na, title="Credit Complacency",
     color=color.new(#f59e0b, 40), linewidth=1)

// Watermark

wm_pos   = f_table_pos(wm_position)
wm_sz    = f_text_sz(wm_size)
wm_sz_sm = wm_size == "Huge" ? size.large : wm_size == "Large" ? size.normal : size.small
wm_sz_xs = wm_size == "Huge" ? size.normal : wm_size == "Large" ? size.small : size.tiny

var table wm_tbl = table.new(wm_pos, 1, 4, border_width=0, bgcolor=color.new(color.black, 100))

if show_watermark and barstate.islast
    color wm_clr = use_dark ? color.new(color.white, 30) : color.new(color.black, 40)
    color t_clr  = trend_dir > 0 ? clr_bear : trend_dir < 0 ? clr_bull : clr_neutral

    table.cell(wm_tbl, 0, 0, syminfo.ticker + ", " + timeframe.period,
               bgcolor=color.new(color.black, 100), text_color=wm_clr,
               text_size=wm_sz, text_halign=text.align_right)
    table.cell(wm_tbl, 0, 1, "MEI: " + str.tostring(signal_value, "#.##"),
               bgcolor=color.new(color.black, 100), text_color=wm_clr,
               text_size=wm_sz_sm, text_halign=text.align_right)
    table.cell(wm_tbl, 0, 2, zone_str + " | " + regime_str,
               bgcolor=color.new(color.black, 100), text_color=wm_clr,
               text_size=wm_sz_xs, text_halign=text.align_right)
    table.cell(wm_tbl, 0, 3, "Trend: " + trend_str + trend_sym,
               bgcolor=color.new(color.black, 100), text_color=color.new(t_clr, 20),
               text_size=wm_sz_sm, text_halign=text.align_right)

// Dashboard

d_pos    = f_table_pos(dash_position)
d_sz     = f_text_sz(dash_size)
d_sz_sm  = dash_size == "Large" ? size.normal : dash_size == "Normal" ? size.small : size.tiny

if show_dashboard and barstate.islast
    var table dash = table.new(d_pos, 2, 9, border_width=1,
                               bgcolor=color.new(clr_tbl_bg, tbl_tr))
    table.clear(dash, 0, 0, 1, 8)

    hdr = color.new(clr_hdr_bg, 20)

    table.cell(dash, 0, 0, "MEI", text_color=clr_text, bgcolor=hdr, text_size=d_sz)
    table.cell(dash, 1, 0, str.tostring(signal_value, "#.##"), text_color=zone_color, bgcolor=hdr, text_size=d_sz)

    z_bg = color.new(zone_color, 90)
    table.cell(dash, 0, 1, "Regime", text_color=clr_text, bgcolor=z_bg, text_size=d_sz_sm)
    table.cell(dash, 1, 1, zone_str, text_color=zone_color, bgcolor=z_bg, text_size=d_sz_sm)

    t_clr = trend_dir > 0 ? clr_bear : trend_dir < 0 ? clr_bull : clr_neutral
    t_bg  = color.new(t_clr, 90)
    table.cell(dash, 0, 2, "Trend", text_color=clr_text, bgcolor=t_bg, text_size=d_sz_sm)
    table.cell(dash, 1, 2, trend_str + trend_sym, text_color=t_clr, bgcolor=t_bg, text_size=d_sz_sm)

    // Individual dimension readings
    color c1 = breadth_danger > 1.0 ? clr_bear : breadth_danger < -1.0 ? clr_bull : clr_neutral
    table.cell(dash, 0, 3, "Breadth", text_color=clr_text, bgcolor=color.new(c1, 90), text_size=d_sz_sm)
    table.cell(dash, 1, 3, not na(breadth_danger) ? str.tostring(breadth_danger, "#.##") : "N/A",
               text_color=c1, bgcolor=color.new(c1, 90), text_size=d_sz_sm)

    color c2 = conc_danger > 1.0 ? clr_bear : conc_danger < -1.0 ? clr_bull : clr_neutral
    table.cell(dash, 0, 4, "Discord", text_color=clr_text, bgcolor=color.new(c2, 90), text_size=d_sz_sm)
    table.cell(dash, 1, 4, not na(conc_danger) ? str.tostring(conc_danger, "#.##") : "N/A",
               text_color=c2, bgcolor=color.new(c2, 90), text_size=d_sz_sm)

    color c3 = credit_danger > 1.0 ? clr_bear : credit_danger < -1.0 ? clr_bull : clr_neutral
    table.cell(dash, 0, 5, "Credit", text_color=clr_text, bgcolor=color.new(c3, 90), text_size=d_sz_sm)
    table.cell(dash, 1, 5, not na(credit_danger) ? str.tostring(credit_danger, "#.##") : "N/A",
               text_color=c3, bgcolor=color.new(c3, 90), text_size=d_sz_sm)

    // Composite z-score
    color cz = composite_z > 1.0 ? clr_bear : composite_z < -1.0 ? clr_bull : clr_neutral
    table.cell(dash, 0, 6, "Z-Score", text_color=clr_text, bgcolor=color.new(cz, 90), text_size=d_sz_sm)
    table.cell(dash, 1, 6, str.tostring(composite_z, "#.##"), text_color=cz, bgcolor=color.new(cz, 90), text_size=d_sz_sm)

    // Historical percentile
    color cp = mei_pctile > 67 ? clr_bear : mei_pctile < 33 ? clr_bull : clr_neutral
    table.cell(dash, 0, 7, "Percentile", text_color=clr_text, bgcolor=color.new(cp, 90), text_size=d_sz_sm)
    table.cell(dash, 1, 7, str.tostring(mei_pctile, "#") + "%", text_color=cp, bgcolor=color.new(cp, 90), text_size=d_sz_sm)

    // Data status
    data_ok = not na(h_breadth) and not na(credit_raw) and not na(concordance_avg)
    color cs = data_ok ? clr_bull : clr_primary
    table.cell(dash, 0, 8, "Data", text_color=clr_text, bgcolor=color.new(cs, 90), text_size=d_sz_sm)
    table.cell(dash, 1, 8, data_ok ? "3/3 OK" : "WARMING", text_color=cs, bgcolor=color.new(cs, 90), text_size=d_sz_sm)

// Alerts

cross_high   = is_high and not is_high[1] and barstate.isconfirmed
cross_low    = is_low and not is_low[1] and barstate.isconfirmed
cross_normal = not is_high and not is_low and (is_high[1] or is_low[1]) and barstate.isconfirmed
trend_up     = trend_dir > 0 and trend_dir[1] <= 0
trend_down   = trend_dir < 0 and trend_dir[1] >= 0

alertcondition(cross_high and enable_alerts, title="Elevated Risk",
    message="MEI entered ELEVATED RISK on {{ticker}} {{interval}}. Concentrated breadth, sector discord, or credit complacency detected.")
alertcondition(cross_low and enable_alerts, title="Low Risk",
    message="MEI entered LOW RISK on {{ticker}} {{interval}}. Broad participation, sector agreement, and active credit markets.")
alertcondition(cross_normal and enable_alerts, title="Normal Regime",
    message="MEI returned to NORMAL on {{ticker}} {{interval}}.")
alertcondition(trend_up and enable_alerts, title="Risk Trend Rising",
    message="MEI risk trend turning upward on {{ticker}} {{interval}}.")
alertcondition(trend_down and enable_alerts, title="Risk Trend Falling",
    message="MEI risk trend turning downward on {{ticker}} {{interval}}.")
````
