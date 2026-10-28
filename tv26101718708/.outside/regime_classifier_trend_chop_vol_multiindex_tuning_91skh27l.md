# Regime Classifier : TREND / CHOP / VOL (Multi-Index Tuning)

- url: https://www.tradingview.com/script/91Skh27L-Regime-Classifier-TREND-CHOP-VOL-Multi-Index-Tuning/
- type: indicator
- pine_id: PUB;6451aa089d5a476b9217af0e59f67cdf
- version: 2.0

## Description

The Big Picture
The Regime Classifier is a single Pine Script that runs on any chart in TradingView and tells you what kind of market you are looking at. It analyzes the recent price action using three independent measurements and combines them into a single label that reads either TREND, CHOP, or VOL. This label appears as a colored tag at the top right of the most recent price bar, with green meaning the market is trending cleanly, red meaning it is choppy and directionless, and orange meaning it is in a high-volatility unstable phase.
The script is designed to be used across multiple charts — one instance on Nifty 50, another on Bank Nifty, another on Midcap 150, and so on for US indices. Each chart instance can be tuned independently from the indicator settings panel without touching the script itself. This is achieved through a configurable inputs section that exposes every important threshold as an adjustable parameter.

How The Script Is Structured
The script is organized into clearly demarcated sections, each separated by horizontal divider lines made of unicode characters. Reading from top to bottom, the sections are: a comprehensive documentation header, the Pine version declaration and indicator title, the inputs section, a position conversion block, the core calculations, the regime logic, the regime label and color assignments, the on-chart label display, the alert condition, a hidden plot for external referencing, and finally the diagnostic table.
This top-to-bottom flow matches the natural reading order. First you understand what the script does (header), then you see how it can be configured (inputs), then you see what it calculates (core calculations), then you see how those calculations are turned into decisions (regime logic), and finally you see how the decisions are displayed and made available (label, alert, plot, table).

The Documentation Header
The first major section of the script is a long block of comments that explains everything a user needs to know before using the indicator. This block is approximately one hundred lines long and is structured into seven distinct parts.
The first part explains what the indicator does in plain language, describing each of the three regimes — TREND, CHOP, and VOL — with their visual signature on the chart and the trading behavior recommended in each. The second part explains how the indicator makes its decisions, walking through the three underlying measurements (ADX, Bollinger Band Width Percentile, and EMA Whipsaw Filter) and explaining why each was chosen and what role it plays.
The third part is a detailed tuning guide showing recommended threshold values for seven different indices spanning Indian and US markets. This table is the most practical piece of documentation in the script because it tells the user exactly which numbers to enter when configuring the indicator on a specific chart.
The fourth part describes the diagnostic table, explaining what each row means and how to interpret the color coding. The fifth part is a deliberate disclosure of the indicator's limitations — what it cannot do, where it lags, and why these limitations are acceptable. The sixth part explains how to set up TradingView alerts using the indicator's built-in alert condition. The seventh part contains author and license information.
This entire header serves as both onboarding documentation for new users and a future reference for the author when revisiting the script after months away.

The Indicator Declaration
After the header comes the Pine version declaration and the indicator title. The script is written for Pine Script version 6, which is the current standard. The title is intentionally region-neutral, reading simply Regime Classifier with the three regime names listed. This neutrality matters because the same script is used across many different markets and indices, so the title should not imply it is specific to any one of them.
The overlay parameter is set to true, which means the indicator draws on top of the price chart rather than creating its own pane below the chart. This is the right choice for an indicator that places labels and tables on the chart but does not plot any price-like values that need their own scale.

The Inputs Section
The inputs section exposes every adjustable parameter to the user through TradingView's settings panel. There are nine inputs in total, organized into four logical groups.
The first input is the Configuration Label, which is a dropdown menu containing eight options corresponding to seven different indices plus a Custom option for any other instrument. This label is purely informational — it does not affect calculations. Its purpose is to give the user a clear visual indicator on each chart of which tuning preset is active. When you have multiple charts open, this label tells you at a glance whether you are looking at the Nifty 50 instance, the Bank Nifty instance, or another configuration.
The second input is the Diagnostic Table Position, which is another dropdown menu with nine options corresponding to the nine standard positions where Pine Script can place a table on a chart. This input lets the user move the diagnostic table to wherever it best fits the chart layout without having to edit the script.
The next group of inputs concerns the ADX calculation. The ADX Length controls the lookback period for the indicator (defaulting to fourteen, the classical value). The ADX Trend Threshold sets the value above which ADX is considered to confirm a trending market. The ADX Chop Threshold sets the value below which ADX contributes to a chop classification.
The third group concerns Bollinger Band Width. The Bollinger Length controls the period for the band calculation. The Bollinger StdDev controls how wide the bands are relative to the middle line. The BBW Percentile Lookback determines how many bars of history the current band width is ranked against. The BBW Volatility Percentile sets the threshold above which the indicator flags VOL.
The fourth group concerns the EMA Whipsaw Filter. The EMA Length sets the period of the moving average used to detect whipsawing. The EMA Whipsaw Lookback determines how many recent bars are checked for crossover counts.
Every input has a tooltip that explains its purpose when the user hovers over it in the settings panel. This makes the indicator self-documenting at the point of use.

The Position Conversion Block
After the inputs comes a small but important block that converts the user's selection from the Diagnostic Table Position dropdown into the actual Pine Script position constant required by the table.new function. The dropdown stores the user's choice as a text string like "Top Right" or "Bottom Left," but Pine Script's table function requires a specific built-in constant such as position.top_right or position.bottom_left.
The conversion block uses an if-else if chain to map each text option to its corresponding constant. The result is stored in a variable called posConstant, which is later used when creating the diagnostic table. This indirection is necessary because Pine Script does not allow dynamic position selection at the table creation point — you cannot pass a string variable directly. The conversion block solves this with a small one-time mapping.

The Core Calculations
This section computes the three underlying measurements that the regime logic depends on.
The first calculation is the ADX. The script uses Pine Script's built-in ta.dmi function, which returns three values — the Plus Directional Indicator, the Minus Directional Indicator, and the ADX itself. The script captures all three but uses only the ADX value for trend strength assessment. The other two are kept available for potential future enhancement but are not currently consumed.
The second calculation produces the Bollinger Band Width. The script first computes the Simple Moving Average over the configured length, then computes the standard deviation of price over the same length, then constructs the upper and lower bands by adding and subtracting a multiple of the standard deviation from the moving average. The band width is calculated as the upper minus the lower, divided by the middle, which normalizes the width to be comparable across instruments at different price levels.
After computing the raw band width, the script ranks it against its own history using the percentrank function. This produces a value between zero and one hundred indicating where the current band width falls compared to the previous one hundred bars (or whatever lookback the user configured). A value of ninety means the current width is wider than ninety percent of recent history, indicating volatility expansion.
The third calculation is the EMA whipsaw count. The script computes a twenty-period exponential moving average, then identifies every bar where price crossed above the EMA (a crossover) or below the EMA (a crossunder) within the recent lookback window. It sums these events to get a total cross count over the lookback. If this count reaches three or more, a boolean flag called isWhipsawing is set to true.

The Regime Logic
This is the heart of the script — the section where the three calculations are combined into a single regime classification. The logic uses three boolean flags computed in a specific priority order.
The first flag is isVol, which is set to true when the BBW percentile rank meets or exceeds the user's volatility threshold. This is checked first because volatility takes priority over everything else in the classification. A market in extreme volatility cannot be considered a clean trend regardless of what ADX says.
The second flag is isTrend, which requires three conditions to all be true. First, the market must not be in VOL state. Second, ADX must be at or above the trend threshold. Third, the whipsaw filter must not be active. Only when all three conditions hold does the indicator classify the market as TREND.
The third flag is isChop, which is the default fallback. It is set to true when the market is neither in VOL nor in TREND, and either ADX is below the chop threshold or whipsawing is active.
This priority structure — VOL first, TREND second, CHOP as fallback — biases the indicator toward conservative classification. If conditions are ambiguous, the indicator defaults to CHOP, which is the regime where the system tells you to stand aside. This bias is intentional because preventing bad trades is more valuable than catching every good one.

The Regime Label, Color, And Code Assignment
After determining which flag is true, the script assigns the appropriate label text, label color, and numeric code to three variables. The label text is one of TREND, CHOP, VOL, or MIXED. The label color is green for TREND, red for CHOP, orange for VOL, and gray for MIXED. The numeric code is one for TREND, negative one for CHOP, two for VOL, and zero for MIXED.
The MIXED state is a defensive fallback that should rarely if ever occur. It exists to handle the theoretical edge case where none of the three primary conditions is true, which can only happen due to floating-point precision issues at exactly the threshold boundaries.
The assignment logic uses if-else if blocks rather than nested ternary expressions. This is a deliberate choice because Pine Script's parser sometimes has trouble with multi-way nested ternaries that mix string and color types. The if-else structure is unambiguous and produces reliable compilation across Pine versions.

The On-Chart Label Display
This section renders the regime classification visually on the chart. The script uses Pine Script's persistent variable mechanism, declaring a label variable with the var keyword that retains its value across bars. On every bar, the script first deletes the previous label and then creates a new one positioned at the high of the current bar.
This delete-and-recreate pattern ensures that only one label exists on the chart at any time, always at the most recent bar. Without this pattern, the script would create a new label on every bar and accumulate hundreds of historical labels, cluttering the chart.
The label uses the style_label_down style, which makes it look like a tag pointing downward at the price bar. The text shows the current regime, the background color matches the regime color, the text itself is white for high contrast, and the size is set to large for visibility.

The Alert Condition
This section enables TradingView users to set up alerts that fire whenever the regime changes from one bar to the next. The script uses Pine Script's history-referencing operator to compare the current regime to the previous bar's regime. When they differ, the regimeChanged boolean is true, and the alertcondition function makes this state available to TradingView's alert engine.
When a user creates an alert in TradingView and selects this script as the source, the Regime Changed condition appears as a selectable trigger. The alert message is a simple text string indicating that the regime has shifted on the current ticker and timeframe. Users can configure delivery via popup, email, mobile push, or webhook depending on their TradingView subscription.

The Hidden Plot
After the alert section, the script includes a single plot statement that outputs the numeric regime code. This plot is hidden from the chart using the display.none parameter, so it does not visually clutter the chart. Its purpose is to make the regime code accessible to other Pine scripts that might want to reference this indicator's output.
For example, if a user later builds a separate strategy script that should only enter trades when the Regime Classifier shows TREND, that strategy can use Pine Script's input source mechanism to read this hidden plot value and gate its trade logic accordingly. The plot is essentially a structured way of exposing the regime decision to downstream automation while keeping the chart clean.

The Diagnostic Table
The final and largest section of the script renders a small information table on the chart showing the indicator's internal state. The table is created once using the var keyword (so it persists across bars) and is positioned according to the user's choice from the Diagnostic Table Position dropdown.
The table has two columns and six rows. The first row shows the Configuration Label, identifying which tuning preset is active on this chart. The second row is a header row labeling the columns as Metric and Value. The remaining four rows show the four diagnostic measurements.
The ADX row displays the current ADX value with two decimal places, color-coded green when above the trend threshold and orange when below. The BBW Rank row shows the current BBW percentile rank, color-coded orange when in volatility territory and white otherwise. The EMA Crosses row shows the count of recent EMA crossings, color-coded red when at or above the whipsaw threshold and white otherwise. The Whipsaw row shows a clean YES or NO indicator with red coloring for YES and green for NO.
The table updates only on the most recent bar by checking the barstate.islast condition. This optimization avoids unnecessary recomputation on historical bars, where the table would not be visible anyway.
The diagnostic table is what makes the indicator transparent rather than a black box. When the user sees a CHOP label and wants to understand why, they can read the table and see exactly which condition is responsible. If ADX is fifteen, the answer is clear — directional momentum has not been confirmed. If Whipsaw is YES, the answer is clear — the market has been crossing the EMA too frequently to be considered trending. This transparency builds user trust in the indicator and helps the user develop intuition about market regime over time.

How The Sections Work Together
Reading the script as a whole, you can trace a clear flow from input to output. The user configures parameters in the inputs section. The position conversion block translates the position selection into the format Pine Script needs. The core calculations transform raw price data into the three measurements (ADX, BBW Rank, Whipsaw count). The regime logic combines these measurements into a single classification. The label and color assignment renders the classification into visible elements. The on-chart label, the alert condition, the hidden plot, and the diagnostic table each consume the classification in different ways — for visual display, for notifications, for downstream automation, and for transparency.
Every section has a single clear purpose. Nothing is duplicated. The script is approximately three hundred lines including comments, but the actual executable Pine code is closer to ninety lines. The comment-to-code ratio reflects the priority on documentation and readability over compactness.

Why It Is Built This Way
The script reflects several deliberate design choices that may not be obvious from reading the code alone.
The choice of three measurements (ADX, BBW Percentile, Whipsaw) rather than one or two reflects the reality that no single technical indicator is reliable across all market conditions. Combining three independent measurements with a priority order significantly reduces the false signals that any one of them would produce alone.
The choice to put the configuration in inputs rather than constants reflects the reality that one set of thresholds cannot fit all markets. A bank index, a tech-heavy index, and a small-cap index have fundamentally different volatility characteristics, and the indicator must be tunable to fit each.
The choice to bias toward CHOP as the default fallback reflects the trading philosophy that protecting capital is more valuable than catching every move. The indicator is designed to keep the user out of bad markets even at the cost of occasionally missing the start of good ones.
The choice to provide a diagnostic table reflects the reality that black-box indicators erode user trust. By showing the user exactly which numbers are driving the classification, the script invites scrutiny rather than blind acceptance.
The choice to write extensive narrative documentation in the comment header reflects the reality that scripts are read by humans, including future versions of yourself, who need to understand the design intent and not just the code mechanics.
These choices add complexity to the script but produce an indicator that is genuinely useful, tunable, transparent, and maintainable.

What This Script Is Not
It is worth noting what this script does not attempt to do. It does not generate buy or sell signals. It does not calculate position sizes. It does not draw entry levels, stops, or targets on the chart. It does not provide a backtesting framework. It does not optimize its own thresholds. It does not access external data feeds.
These omissions are intentional. The script does one thing — classify market regime — and does it cleanly. Other concerns belong in other scripts. A trading system built around this indicator would consist of multiple scripts, each handling a separate concern, with the regime classifier serving as the foundational filter that determines whether the trading system should be active at all.
This separation of concerns is good software architecture in any context. Each script has clear boundaries, can be tested independently, can be improved without breaking other components, and can be replaced if a better version is developed.

In Summary
The Regime Classifier is a Pine Script v6 indicator that classifies any market chart into one of three regimes (TREND, CHOP, VOL) using three independent measurements (ADX, Bollinger Band Width Percentile, EMA Whipsaw Filter) combined with a priority-ordered logic that biases toward conservative classification. It is fully configurable through inputs, transparent through a diagnostic table, deployable across multiple charts with per-chart tuning, alert-enabled for hands-off monitoring, and extensively documented in plain language. It is one component of a larger trading system, focused on the single critical question of whether the current market environment is suitable for trading at all.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════
// MASTER REGIME CLASSIFIER — V6.2 (MERGED)
// ═══════════════════════════════════════════════════════════════════════════
//
// CHANGELOG VERSUS V6.1
// ---------------------
// + Restored Configuration Label dropdown (per-chart tuning identification)
// + Restored Diagnostic Table Position dropdown (9 positions)
// + Restored alertcondition for regime change events
// + Restored hidden numeric plot for downstream Pine script integration
// + Restored input tooltips for self-documentation
// + Renamed "BBM" back to "BBW" (Bollinger Band Width — standard terminology)
// + Added persistence and RS lead alerts as separate alert conditions
//
// CHANGELOG VERSUS ORIGINAL V1.1
// ------------------------------
// + Added 5-MA configurable suite (replaces external MA indicators)
// + Added EMA vs SMA selector for the entire MA suite
// + Added long-term bias detection (price above/below MA5)
// + Added regime persistence counter (how many bars has regime lasted)
// + Added benchmark index comparison
// + Added Relative Strength lead counter (stock trending vs index choppy)
// + Added market context row to diagnostic table
// + Added ADX value display inside the on-chart regime label
// + Simplified BBW calculation using stdev × 4 shortcut (math equivalent)
//
// PURPOSE
// -------
// This indicator is the foundational filter for any trend-based trading
// system. It does not generate buy or sell signals. It tells you what kind
// of market you are looking at and provides supporting context to decide
// whether the current chart deserves further attention.
//
// The five major outputs are:
//   1. Regime classification (TREND, CHOP, or VOL)
//   2. Long-term bias (BULLISH or BEARISH versus the long-term MA)
//   3. Regime persistence (how mature the current regime is)
//   4. Relative strength lead (is this stock outperforming the benchmark)
//   5. Market context (what regime is the benchmark itself in)
//
// Read together, these five outputs answer the question: "Is this stock
// worth analyzing in detail right now, and what is the appropriate stance?"
//
// AUTHOR AND LICENSE
// ------------------
// License: Mozilla Public License 2.0 (https://mozilla.org/MPL/2.0/)
// Version: 6.2
//
// ═══════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Master Regime Classifier — V6.2", overlay=true)


// ─── INPUT GROUP 1: CONFIGURATION IDENTIFICATION ───────────────────────────
// These inputs do not affect calculations. They make it easy to identify
// which tuning preset is active when running multiple chart instances.

group_config = "Configuration"

chartLabel = input.string("Nifty 50 (Default Large Cap)", "Configuration Label",
     options=["Nifty 50 (Default Large Cap)", "Bank Nifty Tuning", "Midcap 150 Tuning",
              "Smallcap 250 Tuning", "S&P 500 (Default Large Cap)", "Nasdaq 100 Tuning",
              "Russell 2000 Tuning", "Custom"],
     group=group_config,
     tooltip="Identifies which tuning preset this chart instance is using. Purely informational.")

tablePosition = input.string("Top Right", "Diagnostic Table Position",
     options=["Top Left", "Top Center", "Top Right",
              "Middle Left", "Middle Center", "Middle Right",
              "Bottom Left", "Bottom Center", "Bottom Right"],
     group=group_config,
     tooltip="Where to display the diagnostic table on the chart. Browser refresh required after change.")


// ─── INPUT GROUP 2: MAIN REGIME LOGIC ──────────────────────────────────────
// The core threshold values that determine regime classification.
// Tune these per the documented per-index tuning table.

group_main = "Main Logic Settings"

adxLen = input.int(14, "ADX Length", minval=5,
     group=group_main,
     tooltip="Lookback period for ADX calculation. Standard is 14. Lower values are faster but noisier.")

adxTrendTh = input.int(20, "ADX Trend Threshold", minval=10,
     group=group_main,
     tooltip="ADX must be at or above this value to confirm a TREND. Higher values demand stricter trend confirmation.")

adxChopTh = input.int(18, "ADX Chop Threshold", minval=5,
     group=group_main,
     tooltip="ADX below this value contributes to CHOP classification. Should be lower than the trend threshold.")


// ─── INPUT GROUP 3: BENCHMARK INDEX (FOR RELATIVE STRENGTH) ────────────────
// The benchmark index is used to compare this chart's regime against
// the broader market. Used for the RS Lead counter and Market Context row.

group_bench = "Benchmark & Context"

benchmark = input.symbol("NSE:NIFTY", "Market Benchmark Index",
     group=group_bench,
     tooltip="Index to compare against for relative strength. NSE:NIFTY for Indian stocks, SP:SPX for US stocks.")


// ─── INPUT GROUP 4: VOLATILITY DETECTION ───────────────────────────────────
// Bollinger Band Width (BBW) percentile-based volatility threshold.

group_vol = "Volatility Settings"

bbwVolPct = input.int(80, "BBW Volatility Percentile", minval=50, maxval=99,
     group=group_vol,
     tooltip="If BBW is in this top percentile of its lookback, regime is flagged as VOL. Lower values flag VOL more aggressively.")


// ─── INPUT GROUP 5: MOVING AVERAGE SUITE ───────────────────────────────────
// Five configurable moving averages displayed on the chart for trend
// structure visualization. Each can be individually toggled on or off.
// MA5 (default 200) is also used as the long-term bias indicator.

group_ma_type = "Moving Average Engine"

maType = input.string("EMA", "MA Type", options=["EMA", "SMA"],
     group=group_ma_type,
     tooltip="Choose Exponential or Simple Moving Average for the entire MA suite below.")

group_mas = "MA Suite (Select/Configure)"

useMa1 = input.bool(true, "", inline="ma1", group=group_mas)
ma1Len = input.int(9, "MA 1", inline="ma1", group=group_mas,
     tooltip="Short-term MA. Default 9 captures very recent momentum.")

useMa2 = input.bool(true, "", inline="ma2", group=group_mas)
ma2Len = input.int(21, "MA 2", inline="ma2", group=group_mas,
     tooltip="Short-medium MA. Default 21 is the classic swing trader's reference.")

useMa3 = input.bool(true, "", inline="ma3", group=group_mas)
ma3Len = input.int(50, "MA 3", inline="ma3", group=group_mas,
     tooltip="Medium-term MA. Default 50 is the standard institutional reference.")

useMa4 = input.bool(false, "", inline="ma4", group=group_mas)
ma4Len = input.int(100, "MA 4", inline="ma4", group=group_mas,
     tooltip="Medium-long MA. Default 100. Toggle on for more granular trend analysis.")

useMa5 = input.bool(true, "", inline="ma5", group=group_mas)
ma5Len = input.int(200, "MA 5 (Long-Term Bias)", inline="ma5", group=group_mas,
     tooltip="Long-term MA used as the bias indicator. Above = BULLISH, Below = BEARISH. Default 200 is the standard major trend reference.")


// ─── HELPER FUNCTION: GET MOVING AVERAGE BY TYPE ───────────────────────────
// Returns either EMA or SMA based on user's selection in the MA Type input.
// This single function handles both cases cleanly.

get_ma(src, len) =>
    maType == "EMA" ? ta.ema(src, len) : ta.sma(src, len)


// ─── POSITION CONVERSION ───────────────────────────────────────────────────
// Convert the user's text selection from the table position dropdown into
// the actual Pine Script position constant required by table.new().

var posConstant = position.top_right
if tablePosition == "Top Left"
    posConstant := position.top_left
else if tablePosition == "Top Center"
    posConstant := position.top_center
else if tablePosition == "Top Right"
    posConstant := position.top_right
else if tablePosition == "Middle Left"
    posConstant := position.middle_left
else if tablePosition == "Middle Center"
    posConstant := position.middle_center
else if tablePosition == "Middle Right"
    posConstant := position.middle_right
else if tablePosition == "Bottom Left"
    posConstant := position.bottom_left
else if tablePosition == "Bottom Center"
    posConstant := position.bottom_center
else if tablePosition == "Bottom Right"
    posConstant := position.bottom_right


// ─── CORE CALCULATIONS ─────────────────────────────────────────────────────

// ADX (Average Directional Index) — the primary trend strength measure.
// Returns +DI, -DI, and ADX. We only use ADX for trend strength assessment.
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)

// Bollinger Band Width (BBW)
// Standard formula: (upper band - lower band) / middle band
// Simplified using algebra: when band multiplier is 2.0, the width
// equals 4 × stdev. Then we normalize by the middle (basis) value.
// This is mathematically identical to the explicit BB formula but cleaner.
basis = ta.sma(close, 20)
bbw   = (ta.stdev(close, 20) * 4) / basis

// BBW Percentile Rank
// Converts current BBW into a 0-100 score relative to the past 100 bars.
// 80 means current width is wider than 80% of recent history.
bbwRank = ta.percentrank(bbw, 100)

// Whipsaw Filter (EMA Crosses)
// Counts how many times price has crossed the 20 EMA in the last 10 bars.
// 3 or more crosses indicates choppy back-and-forth action that disqualifies
// the market from being classified as TREND even if ADX is elevated.
ema_ref  = ta.ema(close, 20)
crossCnt = math.sum(ta.crossover(close, ema_ref) ? 1 : 0, 10) +
           math.sum(ta.crossunder(close, ema_ref) ? 1 : 0, 10)
isWhipsawing = crossCnt >= 3


// ─── REGIME DETERMINATION ──────────────────────────────────────────────────
// Three boolean flags determined in priority order:
// VOL is checked first. If true, regime is VOL regardless of trend.
// TREND requires not VOL, ADX above threshold, and no whipsaw.
// CHOP is the default fallback.

isVol   = bbwRank >= bbwVolPct
isTrend = not isVol and adx >= adxTrendTh and not isWhipsawing
isChop  = not isVol and not isTrend and (adx <= adxChopTh or isWhipsawing)

// Single string variable for the current regime label
currentRegime = isVol ? "VOL" : isTrend ? "TREND" : "CHOP"

// Numeric code for external reference (hidden plot for downstream scripts)
regimeCode = isVol ? 2 : isTrend ? 1 : isChop ? -1 : 0


// ─── LONG-TERM BIAS DETECTION ──────────────────────────────────────────────
// Uses MA5 (default 200) as the long-term bias indicator.
// Price above MA5 = BULLISH context. Price below MA5 = BEARISH context.
// This is independent of the current regime — a stock can be in CHOP regime
// but still BULLISH bias (consolidating in an uptrend).

biasMa = get_ma(close, ma5Len)
isAboveBias = close > biasMa


// ─── PLOT THE MOVING AVERAGE SUITE ─────────────────────────────────────────
// Five MAs displayed on the chart with distinct colors.
// Each is conditionally plotted based on its toggle input.
// MA5 is drawn thicker because it represents the long-term bias level.

plot(useMa1 ? get_ma(close, ma1Len) : na, "MA 1",
     color=color.new(color.teal, 30))

plot(useMa2 ? get_ma(close, ma2Len) : na, "MA 2",
     color=color.new(color.orange, 30))

plot(useMa3 ? get_ma(close, ma3Len) : na, "MA 3",
     color=color.new(color.blue, 30))

plot(useMa4 ? get_ma(close, ma4Len) : na, "MA 4",
     color=color.new(color.gray, 30))

plot(useMa5 ? get_ma(close, ma5Len) : na, "MA 5 (Bias)",
     color=color.new(color.red, 30), linewidth=2)


// ─── REGIME PERSISTENCE COUNTER ────────────────────────────────────────────
// Counts how many bars the current regime has lasted. Reset to 1 whenever
// the regime changes. Useful context: a regime that has been TREND for
// 30 bars is more reliable but closer to exhaustion than one just flipped.

var int regimeBars = 0
regimeBars := (currentRegime == currentRegime[1]) ? regimeBars + 1 : 1


// ─── BENCHMARK COMPARISON FOR RELATIVE STRENGTH ────────────────────────────
// Pull ADX from the configured benchmark index using request.security.
// Used to determine if the broader market is trending or not.

indexADX = request.security(benchmark, timeframe.period, adx)
indexIsTrending = indexADX >= 20


// ─── RELATIVE STRENGTH LEAD COUNTER ────────────────────────────────────────
// Counts consecutive bars where this chart is in TREND while the benchmark
// is NOT trending. This identifies "leadership" stocks that are trending
// during a choppy or weak broader market — high-quality candidates.
// Counter resets to zero whenever this chart is no longer in TREND.

var int rsLeadCounter = 0
if isTrend and not indexIsTrending
    rsLeadCounter := rsLeadCounter + 1
else if not isTrend
    rsLeadCounter := 0


// ─── DIAGNOSTIC TABLE ──────────────────────────────────────────────────────
// 8-row table showing the configuration label and 7 diagnostic metrics.
// Updates only on the most recent bar to save resources.
// All values are color-coded for at-a-glance interpretation.

var tbl = table.new(posConstant, 2, 8,
     bgcolor=color.new(color.black, 70), border_width=1)

if barstate.islast
    // Configuration row — identifies which tuning preset is active
    table.cell(tbl, 0, 0, "Config", text_color=color.white,
         bgcolor=color.new(color.blue, 50), text_size=size.small,
         text_halign=text.align_left)
    table.cell(tbl, 1, 0, chartLabel, text_color=color.yellow,
         bgcolor=color.new(color.blue, 50), text_size=size.small,
         text_halign=text.align_right)

    // Stock regime row — current regime + persistence count
    table.cell(tbl, 0, 1, "Stock", text_color=color.white,
         text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 1,
         currentRegime + " (" + str.tostring(regimeBars) + "b)",
         bgcolor = isTrend ? color.new(color.green, 40) :
                   isVol   ? color.new(color.orange, 40) :
                             color.new(color.red, 40),
         text_size=size.small, text_halign=text.align_right)

    // RS Lead row — bars trending while benchmark is not
    table.cell(tbl, 0, 2, "RS Lead", text_color=color.white,
         text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 2, str.tostring(rsLeadCounter) + "b",
         text_color = rsLeadCounter > 0 ? color.lime : color.white,
         text_size=size.small, text_halign=text.align_right)

    // Bias row — price above/below long-term MA
    table.cell(tbl, 0, 3, "Bias (" + str.tostring(ma5Len) + ")",
         text_color=color.white, text_size=size.small,
         text_halign=text.align_left)
    table.cell(tbl, 1, 3, isAboveBias ? "BULLISH" : "BEARISH",
         text_color = isAboveBias ? color.lime : color.red,
         text_size=size.small, text_halign=text.align_right)

    // BBW Rank row — current volatility percentile
    table.cell(tbl, 0, 4, "BBW Rank", text_color=color.white,
         text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 4, str.tostring(bbwRank, "#") + "%",
         text_color = bbwRank > 80 ? color.orange : color.white,
         text_size=size.small, text_halign=text.align_right)

    // EMA Crosses row — count of recent EMA crossings
    table.cell(tbl, 0, 5, "EMA Crosses", text_color=color.white,
         text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 5, str.tostring(crossCnt),
         text_color = isWhipsawing ? color.red : color.white,
         text_size=size.small, text_halign=text.align_right)

    // Whipsaw flag row — clear yes/no
    table.cell(tbl, 0, 6, "Whipsaw", text_color=color.white,
         text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 6, isWhipsawing ? "YES" : "NO",
         text_color = isWhipsawing ? color.red : color.white,
         text_size=size.small, text_halign=text.align_right)

    // Market context row — what regime is the benchmark in
    table.cell(tbl, 0, 7, "Market", text_color=color.white,
         text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 7, indexIsTrending ? "TREND" : "CHOP/VOL",
         text_color = indexIsTrending ? color.lime : color.orange,
         text_size=size.small, text_halign=text.align_right)


// ─── ON-CHART REGIME LABEL ─────────────────────────────────────────────────
// Single label drawn at the high of the most recent bar, showing the
// current regime and current ADX value for quick reference.

var label rLabel = na
label.delete(rLabel)
rLabel := label.new(bar_index, high,
     text=currentRegime + "\n" + str.tostring(adx, "#.#"),
     color = isTrend ? color.green :
             isVol   ? color.orange :
                       color.red,
     textcolor=color.white,
     style=label.style_label_down,
     size=size.small)


// ─── ALERT CONDITIONS ──────────────────────────────────────────────────────
// Three separate alert conditions you can configure in TradingView.

// Alert 1: Regime change — fires whenever the regime classification flips
regimeChanged = currentRegime != currentRegime[1]
alertcondition(regimeChanged, "Regime Changed",
     "Regime shifted on this ticker and timeframe")

// Alert 2: New TREND established — fires only when changing INTO trend
newTrend = isTrend and not isTrend[1]
alertcondition(newTrend, "New TREND Established",
     "Stock has just transitioned into TREND regime")

// Alert 3: RS Lead milestone — fires when stock has been leading for 5+ bars
rsLeadMilestone = rsLeadCounter == 5
alertcondition(rsLeadMilestone, "RS Lead Milestone",
     "Stock has been in TREND while benchmark is choppy for 5 consecutive bars")


// ─── HIDDEN PLOTS FOR EXTERNAL REFERENCING ────────────────────────────────
// These plots are hidden from the chart but accessible to other Pine scripts
// via the input source mechanism. Useful when building strategy scripts that
// gate entry logic on this classifier's output.

plot(regimeCode, "regime_code", display=display.none)
plot(rsLeadCounter, "rs_lead_count", display=display.none)
plot(isAboveBias ? 1 : 0, "is_above_bias", display=display.none)

// ═══════════════════════════════════════════════════════════════════════════
// END OF SCRIPT
// ═══════════════════════════════════════════════════════════════════════════
````
