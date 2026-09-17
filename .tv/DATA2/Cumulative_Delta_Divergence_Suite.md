<!-- tradingview-pine-id: PUB;0788ec12e6bc42558709e5b7e6ee0227 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Cumulative Delta Divergence Suite

Source: https://www.tradingview.com/script/h1LpnZDP-Cumulative-Delta-Divergence-Suite/

## Description

## Cumulative Delta Divergence Suite

The underlying cumulative-delta calculation and CDV candle construction are adapted from “Cumulative Delta Volume” by LonesomeTheBlue, licensed under MPL 2.0. This version adds independently developed divergence detection, multi-factor scoring, higher-timeframe analysis, absorption and exhaustion conditions, alerts, timeframe presets, and historical target/stop outcome analysis.

### Overview

Cumulative Delta Divergence Suite is a multi-module volume-pressure analysis indicator built around a cumulative delta oscillator.

The script compares confirmed price pivots with confirmed cumulative-delta pivots and combines divergence analysis with configurable scoring, higher-timeframe context, absorption conditions, Z-score extreme zones, timeframe presets, alerts, and simplified historical target/stop outcome tables.

The purpose of combining these components is to examine disagreement between price structure and directional volume pressure from several related perspectives. The modules are not simply displayed independently. Divergence magnitude, delta momentum, relative volume, trend alignment, higher-timeframe agreement, and pivot spacing can contribute to a shared scoring and classification process.

The displayed conditions are analytical observations. They do not predict that price will reverse, continue, or reach a particular level.

### Cumulative delta calculation

Standard chart volume does not directly separate executed buying volume from executed selling volume.

The cumulative-delta calculation used by this script derives directional volume from each candle's:

* total volume;
* body size;
* upper wick;
* lower wick;
* closing direction.

The resulting directional volume value is accumulated over time to construct the cumulative delta series.

The oscillator is displayed as candles in a separate pane. Users can display either the raw cumulative delta candles or an internally calculated Heikin-Ashi representation.

The Heikin-Ashi option smooths the oscillator structure, but this additional averaging can delay changes and alter the location of oscillator pivots.

The calculation is derived from chart OHLCV data. It does not use exchange bid/ask transaction classifications, footprint data, or order-book data.

### Divergence framework

The script compares confirmed pivots in price with confirmed pivots in the cumulative delta oscillator.

It identifies four divergence structures:

* Regular bullish divergence occurs when price forms a lower low while cumulative delta forms a higher low.
* Regular bearish divergence occurs when price forms a higher high while cumulative delta forms a lower high.
* Hidden bullish divergence occurs when price forms a higher low while cumulative delta forms a lower low.
* Hidden bearish divergence occurs when price forms a lower high while cumulative delta forms a higher high.

Regular divergence highlights disagreement between a new price extreme and the cumulative-delta structure.

Hidden divergence highlights a different form of structural disagreement that traders commonly examine within an existing trend.

Neither type establishes what price will do afterward.

### How the modules work together

The script is designed as a cumulative-delta analysis workflow rather than a collection of unrelated indicators.

Divergence provides the primary structural condition by comparing price pivots with cumulative-delta pivots.

The scoring system then evaluates additional characteristics surrounding that divergence, including divergence magnitude, recent delta-momentum change, relative volume, trend alignment, higher-timeframe agreement, and the distance between the compared pivots.

Absorption conditions examine bars where comparatively strong directional volume occurs with limited price progress under the selected volume, range, body, and confluence filters.

Z-score zones identify cumulative-delta readings that are unusually high or low relative to their recent distribution.

Higher-timeframe analysis provides broader confirmed divergence, trend, and volume context.

These components therefore perform different roles within the same analysis process rather than simply duplicating one another.

### How to use the indicator

Apply the indicator to a symbol that provides usable volume data.

The cumulative delta candles appear in a separate pane below the price chart.

A practical workflow is:

1. Review the broader price trend and market structure.
2. Observe whether cumulative delta generally confirms or disagrees with price.
3. Wait for a confirmed regular or hidden divergence condition.
4. Inspect the optional price and oscillator divergence lines to see which pivots were compared.
5. Review the divergence strength score and A+, B, or C category.
6. Check whether confirmed higher-timeframe context agrees with the current structure.
7. Review nearby absorption conditions and Z-score extreme zones.
8. Examine support, resistance, volatility, liquidity, and candle structure separately.
9. Treat all markers as analytical conditions rather than automatic trade instructions.
10. Test settings, alerts, and historical outcome assumptions on the intended symbol and timeframe.

### Regular bullish divergence

Regular bullish divergence is confirmed when:

* price forms a lower confirmed low;
* cumulative delta forms a higher confirmed low.

Price has therefore reached a new lower pivot while the cumulative-delta oscillator has not produced a corresponding lower pivot.

Traders may examine this disagreement together with market structure, support, momentum, cumulative-delta behaviour after confirmation, Z-score context, absorption conditions, and higher-timeframe structure.

The condition can fail, and price can continue lower after confirmation.

### Regular bearish divergence

Regular bearish divergence is confirmed when:

* price forms a higher confirmed high;
* cumulative delta forms a lower confirmed high.

Price has therefore reached a new higher pivot while the cumulative-delta oscillator has not produced a corresponding higher pivot.

Traders may examine this disagreement together with market structure, resistance, momentum, cumulative-delta behaviour after confirmation, Z-score context, absorption conditions, and higher-timeframe structure.

The condition can fail, and price can continue higher after confirmation.

### Hidden bullish divergence

Hidden bullish divergence is confirmed when:

* price forms a higher confirmed low;
* cumulative delta forms a lower confirmed low.

This structure is commonly examined within an existing upward trend because price retains a higher low while cumulative delta makes a deeper retracement.

It does not guarantee that the upward trend will continue.

### Hidden bearish divergence

Hidden bearish divergence is confirmed when:

* price forms a lower confirmed high;
* cumulative delta forms a higher confirmed high.

This structure is commonly examined within an existing downward trend because price retains a lower high while cumulative delta makes a stronger retracement.

It does not guarantee that the downward trend will continue.

### Raw and Heikin-Ashi CDV candles

When Heikin-Ashi CDV candles are disabled, the script uses the raw cumulative delta candle values.

When they are enabled, the script applies an internal Heikin-Ashi transformation to the cumulative delta series.

This affects only the oscillator displayed by the indicator. It does not convert the main TradingView price chart to Heikin-Ashi candles.

The smoothed representation can make broader cumulative-delta structure easier to inspect, but it may also delay short-term changes and alter oscillator pivot locations.

### Pivot settings and confirmation delay

Pivot Left controls how many earlier bars participate in identifying a pivot.

Pivot Right controls how many later bars must pass before that pivot becomes confirmed.

Higher pivot values generally produce fewer pivots, filter more short-term movement, and confirm conditions later.

Lower pivot values generally produce more pivots and react more quickly, but they are also more sensitive to short-term movement.

A pivot-based divergence is not known on the original pivot bar.

The script must wait for the configured number of Pivot Right bars before the pivot can be confirmed.

After confirmation, divergence markers and optional connecting lines are drawn at the original pivot location so users can visually inspect the price-versus-CDV structure.

For example, when Pivot Right is 5, five subsequent bars are required before the pivot is confirmed.

Consequently, a historical divergence marker appears on the earlier pivot bar even though the condition only became known several bars later.

Alerts for pivot-based divergences occur after confirmation, not on the earlier pivot bar.

### Divergence lines

The script can draw oscillator pivot-to-pivot lines in the indicator pane and corresponding price pivot-to-pivot lines on the main chart.

These lines show the exact pair of pivots used for the divergence comparison.

For example, regular bullish divergence connects two price lows where the newer price pivot is lower while the corresponding cumulative-delta pivot is higher.

The lines can be disabled when a cleaner chart is preferred.

### Divergence strength score

The optional divergence strength value measures the relative displacement between the compared price pivots and cumulative-delta pivots.

It is derived from the magnitude of the price movement and the magnitude of the oscillator movement between the compared pivots.

It is not a probability, win rate, or forecast.

The Minimum Divergence Strength setting can suppress conditions whose calculated magnitude is below the selected value.

### Composite scoring

Each confirmed divergence can receive a configurable composite score.

The score combines several measurements:

* divergence strength;
* recent change in smoothed delta momentum;
* volume relative to its recent average;
* alignment with the script's EMA-based trend state;
* agreement with confirmed higher-timeframe divergence context;
* distance between the compared pivots.

Each component performs a different function.

Divergence strength measures the magnitude of the structural disagreement.

Delta momentum examines recent directional change in the smoothed delta series.

Relative volume measures participation around the evaluated pivot.

Trend alignment provides directional price context.

Higher-timeframe agreement measures whether the selected confirmed HTF divergence context supports the same side.

Pivot spacing distinguishes closely grouped pivots from structures developing across a wider interval.

Users can adjust the contribution of these components through the scoring weights.

The active weights are normalized before the final composite value is calculated.

The score organizes conditions according to the selected model. It is not a prediction of future performance.

### Score categories

The script assigns A+, B, or C categories according to the configured score thresholds.

These categories are internal classifications.

They are not probabilities, win rates, accuracy measurements, guarantees, or independently validated performance rankings.

An A+ category means only that the condition reached the highest configured score range.

A B category means that the condition reached the middle configured range.

A C category represents conditions below the B threshold that remain eligible under the selected filter.

The Minimum Grade setting can suppress conditions below the selected category.

### Score transformation

The Score Boost Power applies a nonlinear transformation to the composite score before the A+, B, and C thresholds are evaluated.

Lower values compress scores upward and therefore allow higher categories to occur more frequently.

Higher values keep transformed scores closer to the underlying composite values and make the upper categories more selective.

This setting changes the script's internal classification behaviour. It does not increase the probability that a condition will succeed.

### Adaptive score scaling

When Adaptive Grade Scaling is enabled, the script compares the current raw composite score with the recent distribution of composite scores.

It uses a rolling mean and standard deviation to place the current value in the context of recently observed values before the category thresholds are applied.

When adaptive scaling is disabled, category thresholds are applied to the unscaled composite score.

Because adaptive scaling is relative to recent observations, the same general type of structure can receive different categories under different market conditions.

### Higher-timeframe context

The script can evaluate divergence context from a user-selected higher timeframe.

The HTF module calculates its pivot structure, trend context, and relative-volume component using confirmed data from the requested higher timeframe.

The script uses the last fully closed higher-timeframe information rather than relying on a still-forming HTF candle.

This means higher-timeframe information becomes available only after the required higher-timeframe data has been confirmed.

The HTF module identifies regular bullish, regular bearish, hidden bullish, and hidden bearish cumulative-delta divergence structures.

Its scoring process combines HTF divergence strength with HTF trend context and HTF volume participation.

Higher-timeframe conditions can be displayed separately and can also contribute to the chart-timeframe composite score.

An independent HTF Minimum Grade setting determines which higher-timeframe categories are displayed.

Because confirmed HTF data is used, higher-timeframe conditions can appear later than chart-timeframe conditions.

Higher-timeframe context should therefore be interpreted as broader confirmed information rather than an earlier signal.

### Absorption conditions

The absorption module searches for bars where comparatively large directional delta occurs while price progress remains constrained under the selected filters.

The module evaluates:

* directional delta relative to its recent average;
* volume relative to its recent average;
* candle range relative to its average;
* candle body as a proportion of the complete range;
* an optional close opposing the delta direction;
* optional proximity to a recently graded divergence.

A bullish absorption condition is associated with comparatively strong negative delta while downward price progress remains limited under the configured filters.

A bearish absorption condition is associated with comparatively strong positive delta while upward price progress remains limited under the configured filters.

The module is derived from chart OHLCV information. It does not prove that passive limit orders absorbed aggressive market orders.

The markers should therefore be interpreted as absorption-style analytical conditions rather than direct measurements of order-book behaviour.

### Absorption confluence and filtering

Absorption conditions can be filtered using recent divergence proximity, minimum divergence category, cooldown bars, volume thresholds, delta thresholds, range thresholds, body-to-range limits, and optional opposite-close confirmation.

When divergence confluence is enabled, the absorption condition must occur within the configured number of bars following a qualifying divergence.

The absorption grade displayed with a condition is derived from the nearby qualifying divergence category.

These filters change which conditions are displayed. They do not guarantee a particular subsequent price outcome.

### Z-score extreme zones

The script calculates a Z-score from the cumulative-delta oscillator's rolling mean and standard deviation.

A lower extreme zone appears when the oscillator moves below the selected negative Z-score threshold.

An upper extreme zone appears when the oscillator moves above the selected positive threshold.

These zones identify values that are unusually high or low relative to the oscillator's recent statistical distribution.

The Z-Score Length determines how much history contributes to the rolling mean and standard deviation.

The Z-Score Threshold determines how many standard deviations the oscillator must move from its rolling mean before an extreme zone is displayed.

Higher thresholds produce fewer extreme zones. Lower thresholds produce more frequent zones.

An extreme value does not establish that buying or selling pressure is exhausted and does not establish that price will reverse.

Extreme readings can persist or become more extreme.

### Using divergence, absorption, and Z-score context together

The modules provide different forms of information.

Divergence compares price pivot structure with cumulative-delta pivot structure.

Absorption examines strong directional delta occurring with constrained price progress.

Z-score analysis measures whether cumulative delta is unusually high or low relative to recent values.

Higher-timeframe analysis provides broader confirmed structural context.

Composite scoring organizes divergence conditions according to multiple characteristics of the setup.

The purpose of combining these modules is to provide several related perspectives on price-versus-volume-pressure disagreement without treating any one module as a complete trading system.

Confluence between modules provides additional analytical context but does not automatically validate a condition or guarantee reversal or continuation.

### Timeframe presets

The script contains lower-, medium-, and higher-timeframe preset bundles.

The presets adjust selected settings including:

* pivot lengths;
* score transformation power;
* adaptive score scaling;
* Heikin-Ashi CDV display;
* absorption averaging lengths;
* absorption thresholds;
* absorption confluence lookback.

The presets are intended as starting configurations.

They are not automatically optimized for the active symbol and have not been fitted to guarantee particular historical results.

Users can disable Apply Timeframe Preset to configure the corresponding settings manually.

### Cooldown settings

Independent cooldown controls can reduce repeated conditions of the same type.

Separate cooldown settings are available for regular divergences, hidden divergences, higher-timeframe divergences, absorption conditions, and Z-score extreme conditions.

A value of zero disables the relevant cooldown.

Higher cooldown values reduce repeated same-direction markers but can also suppress nearby structures that would otherwise qualify.

### Historical target/stop outcome tables

Optional tables provide a simplified historical outcome study for confirmed divergence and absorption conditions.

When a condition is confirmed, the script records the confirmation-bar closing price and calculates a fixed percentage target and fixed percentage stop level.

The target and stop percentages are user configurable.

Outcome evaluation begins on the bar after the condition is confirmed.

This prevents price movement that occurred earlier within the confirmation bar from being counted as a subsequent target or stop event.

Each confirmed condition is tracked independently.

If another qualifying condition appears before an earlier condition has resolved, the newer condition does not replace the earlier unresolved condition in the historical study.

For each tracked condition, the script records whether the target or stop is reached first.

If both the target and stop are touched during the same evaluation candle, standard OHLC chart data does not reveal which level was reached first. In this situation the script uses a conservative convention and counts the stop as occurring first.

Separate tables are available for:

* regular bullish divergence;
* regular bearish divergence;
* hidden bullish divergence;
* hidden bearish divergence;
* bullish absorption;
* bearish absorption.

The tables display the number of target-first outcomes, stop-first outcomes, and the resulting target-first percentage for the available chart history.

These tables are intended as a basic chart-based comparison tool.

They are not TradingView Strategy Tester results and are not a complete strategy backtest.

They do not model commissions, slippage, bid/ask spread, realistic order execution, position sizing, portfolio equity, liquidity, partial fills, or complete intrabar price sequencing.

Historical results depend on the symbol, timeframe, available chart history, target and stop distances, filters, indicator settings, and available volume data.

The table percentages describe only the simplified historical study produced under those settings. They do not imply future performance.

### Evaluation target and stop lines

The script can display the fixed target and stop levels associated with the most recently confirmed qualifying condition.

The Target and Stop labels remain anchored at the left side of their respective lines. While the outcome is unresolved, the lines extend to the right. Once either the target or stop is reached, the lines end at the resolution bar and remain visible until a newer qualifying condition replaces them.

These levels use the same configurable percentage distances as the historical outcome study and are provided for visual evaluation rather than as trading recommendations.

Only the most recent Target/Stop pair is displayed to limit chart clutter, while historical conditions continue to be tracked independently by the outcome tables.

### Alerts

Alerts are available for configured divergence, absorption, and exhaustion conditions.

Pivot-based regular and hidden divergence alerts occur only after the required Pivot Right bars have confirmed the pivot.

A+ divergence alerts require the underlying divergence to qualify for the A+ category.

Absorption conditions can depend on values from the current chart bar and can therefore change while that bar is still forming.

Z-score extreme conditions can likewise change as the current chart bar develops.

Users who require closed-bar confirmation should configure their TradingView alert frequency accordingly.

Higher-timeframe divergence context uses confirmed higher-timeframe information.

### What makes the implementation distinct

The script extends a cumulative-delta framework into a broader price-versus-volume-pressure analysis workflow.

Its distinguishing structure includes:

* cumulative delta candle visualization;
* optional internal Heikin-Ashi smoothing;
* regular and hidden pivot-based price/CDV divergence analysis;
* configurable divergence strength filtering;
* multi-factor divergence scoring;
* user-adjustable scoring weights;
* nonlinear score transformation;
* adaptive score scaling;
* A+, B, and C classification and filtering;
* confirmed higher-timeframe divergence analysis;
* higher-timeframe trend and volume context;
* absorption conditions that can be linked to recently graded divergences;
* Z-score extreme analysis;
* timeframe-based parameter presets;
* independent cooldown controls;
* independent tracking of historical target/stop outcomes;
* configurable target and stop evaluation levels;
* divergence, absorption, exhaustion, and grade-based alerts.

The purpose of this combination is to evaluate price-versus-cumulative-delta disagreement using several related measurements within a single workflow.

The divergence module identifies the structural event. The score measures characteristics of that structure and its surrounding context. Higher-timeframe analysis supplies broader confirmed context. Absorption examines directional volume occurring with limited price progress. Z-score analysis identifies statistically unusual oscillator readings. The historical tables provide a simplified way to inspect what happened after past qualifying conditions.

This integration is the reason the components are combined rather than published merely as separate common indicators placed together.

### Limitations

Cumulative delta in this script is derived from candle structure and chart volume rather than exchange bid/ask transaction classifications.

Volume quality and interpretation vary between exchanges, brokers, instruments, and symbols.

Pivot-based divergences are delayed by the selected Pivot Right value.

Confirmed pivot markers and divergence lines are drawn on the earlier pivot location after confirmation, so historical marker placement is earlier than the time at which the condition became known.

Heikin-Ashi smoothing changes the cumulative-delta oscillator structure and can introduce additional delay.

Higher-timeframe analysis waits for confirmed HTF information, which can delay HTF conditions.

Divergence conditions can fail and price can continue in the same direction after a divergence has been confirmed.

Hidden divergence does not guarantee trend continuation.

Absorption conditions are OHLCV-based analytical approximations and do not directly identify passive order-book absorption.

Z-score extremes can persist or become more extreme.

Composite scores and A+, B, and C categories are model outputs, not probabilities, win rates, accuracy measurements, or independently validated performance rankings.

Adaptive scaling can change classifications as the recent score distribution changes.

Lower timeframes can produce more frequent and noisier conditions.

Timeframe presets are starting configurations and are not automatically optimized for a symbol.

Historical target/stop tables are simplified outcome studies and do not represent complete strategy backtests.

Historical target-first percentages depend heavily on the selected target/stop distances, indicator settings, symbol, timeframe, available history, and market conditions.

The indicator does not model commissions, slippage, spread, liquidity, or realistic execution.

No divergence, score category, absorption condition, Z-score reading, target/stop outcome, or combination of these elements guarantees future market behaviour.

The indicator should not be used as the sole basis for a trading decision.

This script is an analytical tool and does not provide financial advice or guaranteed trading outcomes.

---

## Source Code

````pine
//@version=6
indicator("Cumulative Delta Divergence Suite", "CDDS", overlay=false, explicit_plot_zorder=true, max_lines_count=500, max_labels_count=500)

infoGuide = input.string("? Tooltip ?", "? How to Use & Timeframe Settings Guide", tooltip="HOW TO USE CUMULATIVE DELTA DIVERGENCE SUITE:\n\n- DELTA MODEL: Estimates directional volume from each bar's reported volume, candle direction, body, and wick structure. It is not exchange bid/ask order-flow delta.\n- HEIKIN ASHI OPTION: Smooths the indicator's cumulative-delta candles only; it does not change the chart's source bars.\n- DIVERGENCES: Regular and hidden price-vs-oscillator pivot structures are confirmed only after Pivot Right bars have elapsed. After confirmation, regular/hidden markers and lines are drawn at the original pivot location for visual inspection; the condition was not known on that earlier pivot bar.\n- GRADES: A+, B, and C are configurable internal score categories, not probabilities or predictions.\n- TABLES: Simplified historical target/stop outcome studies for confirmed conditions. Evaluation starts on the bar after confirmation, overlapping conditions are tracked independently, and if target and stop are both touched on the same evaluation bar the stop is counted first conservatively. This is not a strategy backtest.\n- HTF: Higher-timeframe pivot, trend, and volume-score components use fully confirmed higher-timeframe bars and are displayed after the HTF confirmation is available.\n- LINES: Optional oscillator pivot-to-pivot and price lines visualize the compared divergence structures.\n- ALERTS: Create alerts for selected confirmed conditions. Use bar-close confirmation where appropriate.\n\nTIMEFRAME PRESETS:\n- LOW TF (1-15m): Pivot L/R 4/5, Score Boost 0.55, Adaptive Grade Scaling on, plus more sensitive absorption settings.\n- MID TF (30m-1H): Pivot L/R 5/7, Score Boost 0.70, Adaptive Grade Scaling on.\n- HIGH TF (4H+): Pivot L/R 8/12, Score Boost 0.85, Adaptive Grade Scaling off, plus stricter absorption settings.\n\nTIPS: Test settings on the intended symbol and timeframe. Results depend on the quality and availability of volume data.", group="? Guide")

presetGuide = input.string("? Tooltip ?", "? Timeframe Preset Guide", tooltip="? KEY TERMS (used in other tooltips):\n- HTF = Higher Timeframe\n- Bl/Br = Bull/Bear pivots\n- lbL/R = Pivot lookback Left/Right lengths\n- Boost = Score transformation power\n- A+/B/C = configurable score categories, not probability ratings\n- H = Hidden Divergence\n- Abs = Absorption heuristic\n\n? HOW PRESETS WORK:\n- Preset Timeframe selects a fixed bundle for pivot lengths, score boost, adaptive grade scaling, Heikin-Ashi display, and absorption parameters.\n- Apply Timeframe Preset = true applies the complete preset bundle and overrides the corresponding manual inputs.\n\n? TIMEFRAME PRESETS:\n- LOW TF (1-15m): lbL/lbR=4/5, Boost=0.55, Adaptive Scaling=true\n- MID TF (30m-1H): lbL/lbR=5/7, Boost=0.70, Adaptive Scaling=true\n- HIGH TF (4H+): lbL/lbR=8/12, Boost=0.85, Adaptive Scaling=false\n\n? TIPS: Match the preset to the chart timeframe, then test it on the intended market. Disable Apply Timeframe Preset to use manual settings. The model requires volume data.", group="? Presets")

theme = input.string("Dark", "Color Theme", options=["Dark","Light"], tooltip="Controls text and candle contrast only. The indicator pane remains transparent and follows the TradingView chart background.", group="? Theme")

showSma1 = input.bool(false, "Show SMA 1", group="Pane Moving Averages", inline="sma1")
sma1Length = input.int(50, "Length", minval=1, group="Pane Moving Averages", inline="sma1")
sma1Color = input.color(color.rgb(33, 149, 243, 31), "Color", group="Pane Moving Averages", inline="sma1")

showSma2 = input.bool(false, "Show SMA 2", group="Pane Moving Averages", inline="sma2")
sma2Length = input.int(200, "Length", minval=1, group="Pane Moving Averages", inline="sma2")
sma2Color = input.color(color.rgb(255, 153, 0, 31), "Color", group="Pane Moving Averages", inline="sma2")

showEma1 = input.bool(true, "Show EMA 1", group="Pane Moving Averages", inline="ema1")
ema1Length = input.int(50, "Length", minval=1, group="Pane Moving Averages", inline="ema1")
ema1Color = input.color(color.rgb(0, 187, 212, 50), "Color", group="Pane Moving Averages", inline="ema1")

showEma2 = input.bool(true, "Show EMA 2", group="Pane Moving Averages", inline="ema2")
ema2Length = input.int(200, "Length", minval=1, group="Pane Moving Averages", inline="ema2")
ema2Color = input.color(color.rgb(255, 255, 255, 50), "Color", group="Pane Moving Averages", inline="ema2")


tf_preset = input.string("Mid TF (30m-1H)", "? Preset Timeframe", options=["Low TF (1-15m)", "Mid TF (30m-1H)", "High TF (4H+)"], tooltip="Select a parameter bundle suited to the chart timeframe. The preset controls pivot lengths, score boost, adaptive grade scaling, Heikin-Ashi display, and absorption settings.\n\nFULL BUNDLE:\n- Apply=true: preset values override the corresponding manual inputs.\n- Apply=false: manual inputs are used.\n\nPRESET PIVOTS / BOOST:\n- Low: 4/5, 0.55\n- Mid: 5/7, 0.70\n- High: 8/12, 0.85\n\nThe grade filter displays only the selected internal score categories.", group="? Timeframe Presets")
use_presets = input.bool(true, "Apply Timeframe Preset?", tooltip="true: Apply the selected preset's pivot lengths, score boost, adaptive scaling, Heikin-Ashi display, and absorption parameters.\nfalse: Use the corresponding manual inputs.\n\nA+/B/C remain internal score categories, not probabilities.", group="? Timeframe Presets")

tableTextCol = theme=="Dark"?color.white:color.black
bgTable = input.color(color.new(color.gray, 80), "Table Background", tooltip="Neutral gray background for table headers and ratios.", group="Table Colors")
winCol = input.color(color.new(color.green, 80), "Resolved Target Highlight", tooltip="Green background for target-first outcome cells.", group="Table Colors", inline="wl")
lossCol = input.color(color.new(color.red, 80), "Resolved Stop Highlight", tooltip="Red background for stop-first outcome cells.", group="Table Colors", inline="wl")

//--------------------------------------------------
// STYLE
//--------------------------------------------------

manual_hacandle = input.bool(true, "Heikin Ashi CDV Candles?", tooltip="Apply Heikin-Ashi smoothing to the indicator's cumulative-delta candle display. This does not change the chart's source price bars. Recommended for visually smoothing noisy low-timeframe oscillator movement. Overridden by presets if enabled.", group="?? Candle Style")

colorup = input.color(color.rgb(52,182,56),"Body Bull", group="?? Candle Style")
colordown = input.color(color.rgb(136, 14, 79),"Body Bear", group="?? Candle Style")

bcolup = input.color(#aafd99,"Border Bull", group="?? Candle Style")
bcoldown = input.color(#ffad7d,"Border Bear", group="?? Candle Style")

wcolup = input.color(#b5b5b8,"Wick Bull", group="?? Candle Style")
wcoldown = input.color(#b5b5b8,"Wick Bear", group="?? Candle Style")

candleBodyUp = theme == "Dark" ? colorup : bcolup
candleBodyDown = theme == "Dark" ? colordown : bcoldown
candleBorderUp = theme == "Dark" ? bcolup : colorup
candleBorderDown = theme == "Dark" ? bcoldown : colordown
wickColUp = theme == "Dark" ? wcolup : color.rgb(64, 64, 64)
wickColDown = theme == "Dark" ? wcoldown : color.rgb(64, 64, 64)

//--------------------------------------------------
// HISTORICAL OUTCOME LEVELS
//--------------------------------------------------

tp_perc = input.float(1.0, "Evaluation Target %", tooltip="Fixed target distance used only by the simplified historical outcome tables.", group="? TP/SL") / 100
sl_perc = input.float(1.0, "Evaluation Stop %", tooltip="Fixed stop distance used only by the simplified historical outcome tables.", group="? TP/SL") / 100

showTPSLlines = input.bool(true, "Show Evaluation Target/Stop Lines", tooltip="Draw the fixed evaluation target and stop levels used by the historical outcome tables.", group="? TP/SL")
slLineCol = input.color(color.rgb(255, 0, 0), "Stop Line Color", group="? TP/SL")
tpLineCol = input.color(color.rgb(0, 255, 8), "Target Line Color", group="? TP/SL")
slLineWidth = input.int(2, "Stop Line Width", minval=1, maxval=5, group="? TP/SL")
tpLineWidth = input.int(2, "Target Line Width", minval=1, maxval=5, group="? TP/SL")
slLineStyle = input.string("Solid", "Stop Line Style", options=["Solid", "Dotted", "Dashed"], group="? TP/SL")
tpLineStyle = input.string("Solid", "Target Line Style", options=["Solid", "Dotted", "Dashed"], group="? TP/SL")

getLineStyle(s) =>
    switch s
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed
        => line.style_solid

//--------------------------------------------------
// DIVERGENCE SETTINGS
//--------------------------------------------------

manual_lbR = input.int(5,"Pivot Right", tooltip="A pivot becomes confirmed only after this many bars to the right have elapsed. Once confirmed, regular/hidden divergence markers and lines are drawn at the original pivot location for visual inspection; they were not known on that earlier bar. Recommended: 5 (1-minute to 5-minute), 8-12 (15-minute to 1-hour), 15-25 (4-hour and higher). Overridden by presets if enabled.", group="? Divergence Pivots")
manual_lbL = input.int(5,"Pivot Left", tooltip="Bars to the left forming pivot. Recommended: same as Pivot Right: 5 for low timeframes, 10-20 for higher timeframes. Overridden by presets if enabled.", group="? Divergence Pivots")

showBull = input.bool(true, "Regular Bull", tooltip="Toggle regular bullish divergence conditions: price lower low with oscillator higher low. The pivot is confirmed after Pivot Right bars. Also controls the corresponding HTF condition.", group="? Divergence Types")
showBear = input.bool(true, "Regular Bear", tooltip="Toggle regular bearish divergence conditions: price higher high with oscillator lower high. The pivot is confirmed after Pivot Right bars. Also controls the corresponding HTF condition.", group="? Divergence Types")
plotHiddenBull = input.bool(true, "Hidden Bull", tooltip="Toggle hidden bullish divergence conditions: price higher low with oscillator lower low. Also controls the corresponding HTF condition.", group="? Divergence Types")
plotHiddenBear = input.bool(true, "Hidden Bear", tooltip="Toggle hidden bearish divergence conditions: price lower high with oscillator higher high. Also controls the corresponding HTF condition.", group="? Divergence Types")

showRegularDivs = input.bool(true, "Regular Divergences", tooltip="Show or hide regular bullish and bearish divergence conditions.", group="? Feature Toggles")
showHiddenDivs = input.bool(true, "Hidden Divergences", tooltip="Show or hide hidden bullish and bearish divergence conditions.", group="? Feature Toggles")
showAbsorption = input.bool(true, "Absorption", tooltip="Show or hide absorption conditions.", group="? Feature Toggles")
showExhaustion = input.bool(true, "Exhaustion", tooltip="Show or hide backgrounds when the oscillator Z-score exceeds the selected positive or negative threshold. Extreme readings do not guarantee a reversal.", group="? Feature Toggles")

// ?? Cooldown Bars
manual_absorptionCooldownBars = input.int(0, "Absorption Cooldown Bars", minval=0, tooltip="Min bars between same-side absorption signals. Default 0 for debug. Recommended: 3-7 low TF (1m-5m), 5-12 mid TF (15m-1H), 10+ high TF (4H+).", group="?? Cooldown Bars")
divCooldownBars = input.int(0, "Regular Divergence Cooldown Bars", minval=0, tooltip="Min bars between same-side regular divergence signals. 0 = no cooldown. Recommended: 3-5 low TF, 5-10 mid TF, 10+ high TF.", group="?? Cooldown Bars")
hidDivCooldownBars = input.int(0, "Hidden Divergence Cooldown Bars", minval=0, tooltip="Min bars between same-side hidden divergence signals. 0 = no cooldown. Recommended: 3-5 low TF, 5-10 mid TF, 10+ high TF.", group="?? Cooldown Bars")
htfCooldownBars = input.int(0, "HTF Cooldown Bars", minval=0, tooltip="Min bars between same-side HTF divergence signals. 0 = no cooldown. Recommended: 3-5 low TF, 5-10 mid TF, 10+ high TF.", group="?? Cooldown Bars")
exhaustionCooldownBars = input.int(0, "Exhaustion Cooldown Bars", minval=0, tooltip="Min bars between same-side exhaustion signals. 0 = no cooldown. Recommended: 3-5 low TF, 5-10 mid TF, 10+ high TF.", group="?? Cooldown Bars")


bullDivCol = input.color(color.lime,"Regular Bull Line", group="? Divergence Lines")
bearDivCol = input.color(color.red,"Regular Bear Line", group="? Divergence Lines")

hiddenBullCol = input.color(color.teal,"Hidden Bull Line", group="? Divergence Lines")
hiddenBearCol = input.color(color.orange,"Hidden Bear Line", group="? Divergence Lines")

bullSigCol = input.color(color.lime,"Regular Bull Signal", group="? Divergence Lines")
bearSigCol = input.color(color.red,"Regular Bear Signal", group="? Divergence Lines")

hiddenBullSigCol = input.color(color.teal,"Hidden Bull Signal", group="? Divergence Lines")
hiddenBearSigCol = input.color(color.orange,"Hidden Bear Signal", group="? Divergence Lines")

divWidth = input.int(3,"Line Width", tooltip="Line thickness for divergence lines (oscillator & price). 1=thin, 4=thick.", group="? Divergence Lines")

showPivotToPivotLines = input.bool(true, "Draw Pivot-to-Pivot Divergence Lines", tooltip="Draw lines connecting the oscillator pivot highs/lows where divergence is detected. For regular bullish divergence: connects oscillator's lower low (first pivot) to higher low (second pivot). Visualizes the exact oscillator structure mismatch with price. Enable for detailed analysis and confirmation; disable for cleaner charts on lower timeframes.", group="? Divergence Lines")
showPriceDivLines = input.bool(true, "Draw Price Divergence Lines", tooltip="Draw lines connecting price pivot highs/lows in divergences. Regular bullish divergence connects a prior price low to a lower price low while the oscillator forms a higher low. Hidden bullish divergence uses a price higher low with an oscillator lower low. Useful for inspecting the compared price pivots; disable on cluttered charts for a cleaner view.", group="? Divergence Lines")
lineTransp = input.int(35, "Divergence Line Transparency", minval=0, maxval=100, tooltip="Transparency of divergence lines (0=solid/opaque, 100=invisible). Lower for prominent lines.", group="? Divergence Lines")

showSignalMarkers = input.bool(true, "Show Divergence Markers", group="? Divergence Markers")
normalMarkerOffsetMult = input.float(0.5,"Normal Marker Offset Mult (0=on oscillator line)", minval=0.0, step=0.01, tooltip="Vertical offset multiplier for regular divergence shape markers above/below oscillator line. 0=on line, higher=further away.", group="? Divergence Markers")
hiddenMarkerOffsetMult = input.float(0.5,"Hidden Marker Offset Mult (0=on oscillator line)", minval=0.0, step=0.01, tooltip="Vertical offset multiplier for hidden divergence shape markers above/below oscillator line. 0=on line, higher=further away.", group="? Divergence Markers")

manual_absorptionVolLen = input.int(20, "Absorption Volume MA Length", minval=1, tooltip="Moving average length for average volume in the absorption heuristic (volume spike + estimated delta/range against price direction). Recommended: 14-25 for low timeframes, 25-50 for higher timeframes.", group="? Absorption Settings")
manual_absorptionDeltaLen = input.int(20, "Absorption Delta Average Length", minval=1, tooltip="Average length for estimated-delta spike detection. Recommended: 14-25 low TF (1m-5m), 25-50 higher TF (15m+), match volume length.", group="? Absorption Settings")
manual_absorptionRangeLen = input.int(20, "Absorption Range Average Length", minval=1, tooltip="Average true range (ATR) length for expansion check. Recommended: 14-25 low TF (1m-5m), 25-50 higher TF (15m+), match vol/delta lengths.", group="? Absorption Settings")
manual_absorptionDeltaMult = input.float(1.4, "Absorption Delta Spike Multiplier", minval=1.0, step=0.1, tooltip="Delta spike greater than average times this multiplier. Higher value is stricter. Recommended: 1.3-1.6 for low timeframes, 1.5-2 for higher timeframes.", group="? Absorption Settings")
manual_absorptionRangeMult = input.float(2.0, "Absorption Range Multiplier", minval=0.5, step=0.1, tooltip="Range expansion > avg range * mult. Recommended: 1.6-2.0 low TF (1m-5m), 2.0-2.5 higher TF (15m+).", group="? Absorption Settings")
manual_absorptionVolMult = input.float(1.10, "Absorption Volume Multiplier", minval=1.0, step=0.05, tooltip="Volume greater than average times multiplier. Recommended: 1.15-1.3 for low timeframes, 1.3 or higher for higher timeframes.", group="? Absorption Settings")
manual_absorptionBodyMaxRatio = input.float(0.70, "Absorption Max Body/Range Ratio", minval=0.05, maxval=1.0, step=0.01, tooltip="Max body/range ratio for absorption candle (small body/doji-like preferred). Lower=stricter. Recommended: 0.6-0.75 low TF (1m-5m), 0.5-0.65 higher TF (15m+).", group="? Absorption Settings")
manual_absorptionUseOppositeClose = input.bool(false, "Require Opposite Candle Close", tooltip="Require candle close opposite delta dir. (e.g. pos delta but close low). False default for debug; enable live. Recommended: true mid+ TF (15m+), false low TF (1m-5m)/debug.", group="? Absorption Settings")
manual_absorptionUseDivConfluence = input.bool(true, "Require Divergence Confluence", tooltip="Only flag absorption near recent reg/hid divergence. When enabled, absorption conditions require proximity to a recent divergence that passes the selected grade filter.", group="? Absorption Settings")
showAbsorptionDebug = input.bool(false, "Show Absorption Debug Markers", tooltip="Debug stages for tuning absorption params:\n- Yellow circle 'd': Delta spike stage (|delta| > avg abs delta * Delta Mult)\n- Light gray circle 'f': Base filters (vol spike + range/body filter)\n- Purple circle 'o': Opposite close passes (and with the default relaxed inputs it should appear much more often)\n- Light blue circle 'c': Cooldown OK for that side (default cooldown is 0 for debug visibility)\n- Orange circle 'v': Div confluence OK for that side\nStages are vertically staggered so you can see which condition is failing instead of all debug markers drawing on top of each other. For stricter live trading filters, turn opposite-close back on and increase cooldown.", group="? Absorption Settings")
absorbSellCol = input.color(color.fuchsia, "Bearish Absorption Marker", tooltip="Color for a bearish absorption heuristic: large positive estimated delta with the selected volume, range, body, and confluence filters. This is an analytical marker, not a sell or short instruction.", group="Absorption Colors")
absorbBuyCol = input.color(color.aqua, "Bullish Absorption Marker", tooltip="Color for a bullish absorption heuristic: large negative estimated delta with the selected volume, range, body, and confluence filters. This is an analytical marker, not a buy or long instruction.", group="Absorption Colors")
absorptionOffsetMult = input.float(0.5, "Absorption Marker Offset Mult (0=on oscillator line)", minval=0.0, step=0.01, tooltip="Vertical offset multiplier for absorption shape markers. >0: bearish above osc, bullish below.", group="? Absorption Colors")
manual_absorptionConfluenceLookback = input.int(15, "Absorption Confluence Lookback Bars", minval=1, tooltip="Max bars since last reg/hid divergence for absorption confluence. Longer=more signals while keeping 'near recent' req. Rec: 10-15 low TF, 15-20 mid, 20-30 high.", group="? Absorption Settings")

//--------------------------------------------------
// DELTA EXHAUSTION (Z-SCORE)
//--------------------------------------------------

zLen = input.int(100, "Z-Score Length", tooltip="Length for oscillator mean/standard deviation in Z-score. Shorter length is more sensitive. Recommended: 50-100 (1-minute to 15-minute), 100-200 (1-hour to 4-hour), 200-500 (Daily/Weekly).", group="Exhaustion")
zThresh = input.float(3.0, "Exhaustion Threshold", tooltip="Z-score threshold (standard deviations) for exhaustion zones. Higher value is harder to trigger. Recommended: 2.5-3 for intraday timeframes, 3-3.5 for higher timeframes.", group="Exhaustion")

exhaustionBullCol = input.color(color.new(color.teal, 85), "Negative Z-Score Zone Color", tooltip="Background color for an extreme negative oscillator Z-score. This does not establish that price will reverse.", group="Exhaustion")
exhaustionBearCol = input.color(color.new(#ff5252, 85), "Positive Z-Score Zone Color", tooltip="Background color for an extreme positive oscillator Z-score. This does not establish that price will reverse.", group="Exhaustion")

//--------------------------------------------------
// STRENGTH + QUALITY
//--------------------------------------------------

useSmartScore = input.bool(false,"Apply Minimum Divergence Strength", tooltip="Suppress plotting divergences whose divergence strength score is below the selected minimum.", group="? Strength & Quality")
minStrength = input.float(1.0,"Minimum Strength", tooltip="Minimum divergence strength score for a valid condition. The score combines relative price displacement and oscillator displacement between the compared pivots. Higher values suppress more low-magnitude conditions. Recommended: 0.8-1.5.", group="? Strength & Quality")
showStrength = input.bool(true, "Show Strength", tooltip="Display the divergence strength score in divergence labels. This is a relative magnitude score, not a probability.", group="? Strength & Quality")

normalOffsetMult = input.float(0.5, "Normal Label Offset Mult (0=on oscillator line)", minval=0.0, step=0.01, tooltip="Vertical offset multiplier for regular divergence labels above oscillator. 0= on line, higher= further up.", group="? Strength & Quality")
hiddenOffsetMult = input.float(0.5, "Hidden Label Offset Mult (0=on oscillator line)", minval=0.0, step=0.01, tooltip="Vertical offset multiplier for hidden divergence labels. Adjust to avoid overlap.", group="? Strength & Quality")

htf_tf = input.timeframe("60", "HTF Timeframe", tooltip="Higher timeframe for divergence context (for example, 15-minute on a 5-minute chart, 1-hour on a 15-minute chart, or 4-hour on a 1-hour chart). HTF pivot, trend, and volume-score components use the last fully closed requested higher-timeframe bar, and HTF markers appear after that HTF confirmation is available. Default: 1H. Leave blank to disable.", group="? HTF Settings")
showHTF = input.bool(true, "HTF Signals", tooltip="Toggle HTF (Higher Time Frame) Signals on/off.", group="? Feature Toggles")

htf_reg_bull_col = input.color(color.new(color.lime, 50), "HTF Regular Bull", group="HTF Colors", inline="htf_reg")
htf_reg_bear_col = input.color(color.new(color.red, 50), "HTF Regular Bear", group="HTF Colors", inline="htf_reg")
htf_hid_bull_col = input.color(color.new(color.teal, 50), "HTF Hidden Bull", group="HTF Colors", inline="htf_hid")
htf_hid_bear_col = input.color(color.new(color.orange, 50), "HTF Hidden Bear", group="HTF Colors", inline="htf_hid")
htf_offset = input.float(0.5, "HTF Vertical Offset Mult", minval=-5.0, maxval=5.0, step=0.1, tooltip="Vertical offset multiplier for HTF labels relative to default positions. Positive: upward, negative: downward.", group="? HTF Settings")

signalTextCol = input.color(color.white, "Signal Text Color", tooltip="Color for the text displayed on signal markers (e.g., 'Bull', 'Hidden Bull').", group="? Signal Colors")

weightDivStrength = input.float(0.35, "Weight: Divergence Strength", step=0.01, tooltip="Score weight for divergence slope strength (0-1). Defaults sum to 1.", group="?? Scoring Weights")
weightDeltaMomentum = input.float(0.20, "Weight: Delta Momentum Change", step=0.01, tooltip="Score weight for the direction of recent smoothed delta-momentum change (0-1).", group="?? Scoring Weights")
weightVolumeSpike = input.float(0.15, "Weight: Volume Spike", step=0.01, tooltip="Score weight for volume surge at divergence (0-1).", group="?? Scoring Weights")
weightTrend = input.float(0.10, "Weight: Trend Alignment", step=0.01, tooltip="Score weight for alignment with the script's EMA trend state (0-1).", group="?? Scoring Weights")
weightHTF = input.float(0.10, "Weight: HTF Agreement", step=0.01, tooltip="Score weight for higher timeframe divergence agreement (0-1). Increase if using multi-timeframe.", group="?? Scoring Weights")
weightPivotDistance = input.float(0.10, "Weight: Pivot Distance", step=0.01, tooltip="Score weight derived from the distance between the compared pivots (0-1).", group="?? Scoring Weights")

gradeAThreshold = input.float(72.0, "A+ Divergence Threshold", tooltip="Composite score greater than this value receives A+ grade. Higher thresholds assign the A+ category less frequently. Recommended: 70-80.", group="? Grade Thresholds")
gradeBThreshold = input.float(52.0, "B Divergence Threshold", tooltip="Score greater than this receives B grade (A+/B). Recommended: 50-60.", group="? Grade Thresholds")
manual_signalBoost = input.float(0.60, "Score Boost Power (lower value = more A+ and B grades)", minval=0.3, maxval=1.0, step=0.05, tooltip="Exponential power applied to composite score before grading. Lower values (e.g., 0.5) compress scores upward, producing more A+/B grades. Higher values (e.g., 0.9) keep scores closer to linear, making A+ harder to achieve. Recommended: 0.5-0.7 for frequent signals, 0.8+ for strict filtering. Overridden by presets if enabled.", group="? Grade Thresholds")
minGrade = input.string("C", "Minimum Grade Filter", options=["A+", "B", "C"], tooltip="Display only conditions in the selected score categories. Grades are internal model categories, not probabilities.", group="? Grade Thresholds")
manual_absorbMinGrade = input.string("C", "Absorption Min Grade Filter", options=["A+", "B", "C"], tooltip="Only show absorption signals near divergences at or above this grade. Separate from main minGrade so absorption signals aren't filtered when raising the main grade. A+ requires proximity to an A+ score category; C allows proximity to any displayed category.", group="? Grade Thresholds")
htf_minGrade = input.string("C", "HTF Minimum Grade Filter", options=["A+", "B", "C"], tooltip="Only show HTF signals at or above this grade. Independent of main Minimum Grade Filter.", group="? Grade Thresholds")
htf_gradeAThreshold = input.float(62.0, "HTF A+ Divergence Threshold", tooltip="HTF composite score greater than this value receives A+ grade. Lower threshold than main (72) to account for HTF strength differences, producing more A+/B HTF grades. Recommended: 60-70.", group="? Grade Thresholds")
htf_gradeBThreshold = input.float(42.0, "HTF B Divergence Threshold", tooltip="HTF score greater than this receives B grade (A+/B). Recommended: 40-50.", group="? Grade Thresholds")

manual_useAdaptiveScaling = input.bool(true, "Adaptive Grade Scaling", tooltip="Compare each raw composite score with its rolling mean and standard deviation before applying grade thresholds. Disable to grade the raw composite score directly. Presets may override this setting.", group="? Grade Thresholds")

showBullTable = input.bool(true, "Show Bull Table", group="Table Layout")
bullTablePosInput = input.string("Top Left", "Bull Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip="Choose UNIQUE positions per table to avoid overlaps (later tables cover earlier ones). Defaults are non-overlapping.", group="Table Layout")
showBearTable = input.bool(true, "Show Bear Table", group="Table Layout")
bearTablePosInput = input.string("Top Right", "Bear Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip="Choose UNIQUE positions per table to avoid overlaps (later tables cover earlier ones). Defaults are non-overlapping.", group="Table Layout")
showHBullTable = input.bool(true, "Show Hidden Bull Table", group="Table Layout")
hBullTablePosInput = input.string("Bottom Left", "Hidden Bull Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip="Choose UNIQUE positions per table to avoid overlaps (later tables cover earlier ones). Defaults are non-overlapping.", group="Table Layout")
showHBearTable = input.bool(true, "Show Hidden Bear Table", group="Table Layout")
hBearTablePosInput = input.string("Bottom Right", "Hidden Bear Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip="Choose UNIQUE positions per table to avoid overlaps (later tables cover earlier ones). Defaults are non-overlapping.", group="Table Layout")
showAbsorbBullTable = input.bool(true, "Show Abs Bull Table", group="Table Layout")
absorbBullTablePosInput = input.string("Middle Left", "Abs Bull Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip="Choose UNIQUE positions per table to avoid overlaps (later tables cover earlier ones). Defaults are non-overlapping.", group="Table Layout")
showAbsorbBearTable = input.bool(true, "Show Abs Bear Table", group="Table Layout")
absorbBearTablePosInput = input.string("Middle Right", "Abs Bear Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip="Choose UNIQUE positions per table to avoid overlaps (later tables cover earlier ones). Defaults are non-overlapping.", group="Table Layout")

// ? Timeframe Presetsd Effective Settings
isLowTFPreset = tf_preset == "Low TF (1-15m)"
isMidTFPreset = tf_preset == "Mid TF (30m-1H)"
isHighTFPreset = tf_preset == "High TF (4H+)"

int opt_lbL = isLowTFPreset ? 4 : isMidTFPreset ? 5 : 8
int opt_lbR = isLowTFPreset ? 5 : isMidTFPreset ? 7 : 12
lbL = use_presets ? opt_lbL : manual_lbL
lbR = use_presets ? opt_lbR : manual_lbR
float opt_boost = isLowTFPreset ? 0.55 : isMidTFPreset ? 0.70 : 0.85
signalBoost = use_presets ? opt_boost : manual_signalBoost
bool opt_adaptive = isLowTFPreset ? true : isMidTFPreset ? true : false
useAdaptiveScaling = use_presets ? opt_adaptive : manual_useAdaptiveScaling
bool opt_ha = true
hacandle = use_presets ? opt_ha : manual_hacandle

absorptionVolLen = use_presets ? (isLowTFPreset ? 14 : isMidTFPreset ? 20 : 25) : manual_absorptionVolLen
absorptionDeltaLen = use_presets ? (isLowTFPreset ? 14 : isMidTFPreset ? 20 : 25) : manual_absorptionDeltaLen
absorptionRangeLen = use_presets ? (isLowTFPreset ? 14 : isMidTFPreset ? 20 : 25) : manual_absorptionRangeLen
absorptionDeltaMult = use_presets ? (isLowTFPreset ? 1.20 : isMidTFPreset ? 1.40 : 1.50) : manual_absorptionDeltaMult
absorptionRangeMult = use_presets ? (isLowTFPreset ? 1.60 : isMidTFPreset ? 2.00 : 2.10) : manual_absorptionRangeMult
absorptionVolMult = use_presets ? (isLowTFPreset ? 1.05 : isMidTFPreset ? 1.10 : 1.15) : manual_absorptionVolMult
absorptionBodyMaxRatio = use_presets ? (isLowTFPreset ? 0.85 : isMidTFPreset ? 0.70 : 0.65) : manual_absorptionBodyMaxRatio
absorptionUseOppositeClose = use_presets ? (isHighTFPreset ? false : false) : manual_absorptionUseOppositeClose
absorptionUseDivConfluence = use_presets ? true : manual_absorptionUseDivConfluence
absorptionCooldownBars = manual_absorptionCooldownBars
absorptionConfluenceLookback = use_presets ? (isLowTFPreset ? 15 : isMidTFPreset ? 20 : 25) : manual_absorptionConfluenceLookback
absorbMinGrade = manual_absorbMinGrade

//--------------------------------------------------
// DELTA
//--------------------------------------------------

tw = high - math.max(open,close)
bw = math.min(open,close) - low
body = math.abs(close-open)

denom = tw + bw + body
rate = denom > 0 ? 0.5 * (tw + bw + 2 * body) / denom : 0.5
delta = volume * rate * (close >= open ? 1.0 : -1.0)
cumdelta = ta.cum(delta)

//--------------------------------------------------
// BUILD CDV CANDLES
//--------------------------------------------------

float o=na
float h=na
float l=na
float c=na

o:=cumdelta[1]
h:=math.max(cumdelta,cumdelta[1])
l:=math.min(cumdelta,cumdelta[1])
c:=cumdelta

//--------------------------------------------------
// HEIKIN ASHI OPTION
//--------------------------------------------------

var float haclose=na
var float haopen=na
var float hahigh=na
var float halow=na

haclose:=(o+h+l+c)/4
haopen:=na(haopen[1])?(o+c)/2:(haopen[1]+haclose[1])/2
hahigh:=math.max(h,math.max(haopen,haclose))
halow:=math.min(l,math.min(haopen,haclose))

c_ = hacandle?haclose:c
o_ = hacandle?haopen:o
h_ = hacandle?hahigh:h
l_ = hacandle?halow:l
candle_range = ta.sma(h_ - l_, 20)

isUp = o_ <= c_

osc=c_

//--------------------------------------------------
// PANE MOVING AVERAGES (DRAWN BEHIND CDV CANDLES)
//--------------------------------------------------

sma1Pane = ta.sma(osc, sma1Length)
sma2Pane = ta.sma(osc, sma2Length)
ema1Pane = ta.ema(osc, ema1Length)
ema2Pane = ta.ema(osc, ema2Length)

plot(showSma1 ? sma1Pane : na, title="Pane SMA 1", color=sma1Color, linewidth=2)
plot(showSma2 ? sma2Pane : na, title="Pane SMA 2", color=sma2Color, linewidth=2)
plot(showEma1 ? ema1Pane : na, title="Pane EMA 1", color=ema1Color, linewidth=2)
plot(showEma2 ? ema2Pane : na, title="Pane EMA 2", color=ema2Color, linewidth=2)

// With explicit plot ordering enabled, declaring the candles after the moving
// averages keeps candle bodies, borders, and wicks in front of every MA line.
plotcandle(o_,h_,l_,c_,
  color=isUp?candleBodyUp:candleBodyDown,
  bordercolor=isUp?candleBorderUp:candleBorderDown,
  wickcolor=isUp?wickColUp:wickColDown)

//--------------------------------------------------
// DIVERGENCE
//--------------------------------------------------

price_range_avg = ta.sma(high - low, 100)
osc_change_avg = ta.sma(math.abs(ta.change(osc)), 100)
price_change_avg = ta.sma(math.abs(ta.change(close)), 100)
scale_factor = price_change_avg != 0 ? osc_change_avg / price_change_avg : 1.0
oscMoveRange = nz(price_range_avg * scale_factor, syminfo.mintick)
labelOffsetRange = math.max(oscMoveRange, syminfo.mintick)

float htf_top_y = ta.highest(osc, 100) + labelOffsetRange * 1.0
float htf_bottom_y = ta.lowest(osc, 100) - labelOffsetRange * 1.0
float htf_hid_top_y = ta.highest(osc, 100) + labelOffsetRange * 0.5
float htf_hid_bottom_y = ta.lowest(osc, 100) - labelOffsetRange * 0.5

oscMean = ta.sma(osc, zLen)
oscStd = ta.stdev(osc, zLen)
zScore = oscStd != 0 ? (osc - oscMean) / oscStd : 0.0
bullExhaustion = zScore < -zThresh
bearExhaustion = zScore > zThresh

// Keep the normal pane transparent. Only the configured exhaustion blocks colour the background.
activePaneBg = showExhaustion and bullExhaustion ? exhaustionBullCol : showExhaustion and bearExhaustion ? exhaustionBearCol : na
bgcolor(activePaneBg, title="Exhaustion Background Zones")

plFound = not na(ta.pivotlow(osc,lbL,lbR))
phFound = not na(ta.pivothigh(osc,lbL,lbR))

prevOscLow = ta.valuewhen(plFound,osc[lbR],1)
prevPriceLow = ta.valuewhen(plFound,low[lbR],1)

prevOscHigh = ta.valuewhen(phFound,osc[lbR],1)
prevPriceHigh = ta.valuewhen(phFound,high[lbR],1)

currPlBar = ta.valuewhen(plFound, bar_index[lbR], 0)
prevPlBar = ta.valuewhen(plFound, bar_index[lbR], 1)
currPlOsc = ta.valuewhen(plFound, osc[lbR], 0)
prevPlOsc = ta.valuewhen(plFound, osc[lbR], 1)
currPlPrice = ta.valuewhen(plFound, low[lbR], 0)
prevPlPrice = ta.valuewhen(plFound, low[lbR], 1)

currPhBar = ta.valuewhen(phFound, bar_index[lbR], 0)
prevPhBar = ta.valuewhen(phFound, bar_index[lbR], 1)
currPhOsc = ta.valuewhen(phFound, osc[lbR], 0)
prevPhOsc = ta.valuewhen(phFound, osc[lbR], 1)
currPhPrice = ta.valuewhen(phFound, high[lbR], 0)
prevPhPrice = ta.valuewhen(phFound, high[lbR], 1)

hasTwoPl = not na(prevPlBar) and not na(currPlBar)
hasTwoPh = not na(prevPhBar) and not na(currPhBar)

lineExt = extend.none

priceLL = low[lbR] < prevPriceLow
oscHL = osc[lbR] > prevOscLow
regBull = showRegularDivs and showBull and priceLL and oscHL and plFound

priceHH = high[lbR] > prevPriceHigh
oscLH = osc[lbR] < prevOscHigh
regBear = showRegularDivs and showBear and priceHH and oscLH and phFound

priceHL = low[lbR] > prevPriceLow
oscLL = osc[lbR] < prevOscLow
hidBull = showHiddenDivs and plotHiddenBull and priceHL and oscLL and plFound

priceLH = high[lbR] < prevPriceHigh
oscHH = osc[lbR] > prevOscHigh
hidBear = showHiddenDivs and plotHiddenBear and priceLH and oscHH and phFound

//--------------------------------------------------

calcStrength(p1,p2,o1,o2)=>
    priceMove=math.abs(p1-p2)
    oscMove=math.abs(o1-o2)
    pricePct=p2!=0?priceMove/math.abs(p2):0
    oscPct=o2!=0?oscMove/math.abs(o2):0
    math.min((pricePct+oscPct)*50, 100)

clamp01(v)=>
    math.max(0.0, math.min(1.0, v))

scoreDirection(raw, scale, bullDir)=>
    n = scale > 0 ? raw / scale : 0
    directed = bullDir ? n : -n
    clamp01((directed + 1.0) * 0.5) * 100

gradeText(score)=>
    score >= gradeAThreshold ? "A+" : score >= gradeBThreshold ? "B" : "C"

htf_gradeText(score)=>
    score >= htf_gradeAThreshold ? "A+" : score >= htf_gradeBThreshold ? "B" : "C"

// Grade helper for main divergences (uses minGrade)
gradeAllowed(grade) =>
    switch minGrade
        "C" => true
        "B" => grade == "A+" or grade == "B"
        "A+" => grade == "A+"

// Grade helper for absorption confluence (uses absorbMinGrade)
absorbGradeAllowed(grade) =>
    switch absorbMinGrade
        "C" => true
        "B" => grade == "A+" or grade == "B"
        "A+" => grade == "A+"

// Grade helper for HTF divergences (uses htf_minGrade)
htfGradeAllowed(grade) =>
    switch htf_minGrade
        "C" => true
        "B" => grade == "A+" or grade == "B"
        "A+" => grade == "A+"
        => false
boostScore(rawScore)=>
    powered = math.pow(clamp01(rawScore / 100.0), signalBoost) * 100.0
    clamp01(powered / 100.0) * 100.0

adaptiveScore(raw, mean, dev)=>
    zBase = math.max(dev * 1.75, 5.0)
    scaled = 50.0 + ((raw - mean) / zBase) * 50.0
    clamp01(scaled / 100.0) * 100.0

htfPivotPack() =>
    // Offset every requested value by one HTF bar so the request uses only
    // fully confirmed higher-timeframe data.
    plRaw = ta.pivotlow(osc, lbL, lbR)
    phRaw = ta.pivothigh(osc, lbL, lbR)
    emaSlowCtx = ta.ema(close, 55)
    volAvgCtx = ta.sma(volume, 20)
    pl = plRaw[1]
    ph = phRaw[1]
    plPrice = not na(pl) ? low[lbR + 1] : na
    phPrice = not na(ph) ? high[lbR + 1] : na
    plTrendScore = not na(pl) ? (close[lbR + 1] > emaSlowCtx[lbR + 1] ? 100.0 : 0.0) : na
    phTrendScore = not na(ph) ? (close[lbR + 1] < emaSlowCtx[lbR + 1] ? 100.0 : 0.0) : na
    plVolScore = not na(pl) ? clamp01((volume[lbR + 1] / math.max(nz(volAvgCtx[lbR + 1], 0.0), 1.0)) / 2.0) * 100.0 : na
    phVolScore = not na(ph) ? clamp01((volume[lbR + 1] / math.max(nz(volAvgCtx[lbR + 1], 0.0), 1.0)) / 2.0) * 100.0 : na
    [pl, plPrice, plTrendScore, plVolScore, ph, phPrice, phTrendScore, phVolScore]

// lookahead_on is safe here because every requested HTF expression is explicitly
// offset by one HTF bar. This returns the last fully confirmed HTF values.
[htf_plOsc, htf_plPrice, htf_plTrendScore, htf_plVolScore, htf_phOsc, htf_phPrice, htf_phTrendScore, htf_phVolScore] = request.security(syminfo.tickerid, htf_tf, htfPivotPack(), barmerge.gaps_off, barmerge.lookahead_on)

htfEnabled = htf_tf != ""
htfNewConfirmedBar = htfEnabled and timeframe.change(htf_tf)
htf_plFound = htfNewConfirmedBar and not na(htf_plOsc)
htf_phFound = htfNewConfirmedBar and not na(htf_phOsc)

htf_prevOscLow = ta.valuewhen(htf_plFound, htf_plOsc, 1)
htf_prevPriceLow = ta.valuewhen(htf_plFound, htf_plPrice, 1)
htf_prevOscHigh = ta.valuewhen(htf_phFound, htf_phOsc, 1)
htf_prevPriceHigh = ta.valuewhen(htf_phFound, htf_phPrice, 1)

htf_priceLL = htf_plPrice < htf_prevPriceLow
htf_oscHL = htf_plOsc > htf_prevOscLow
htf_regBull = showBull and htf_priceLL and htf_oscHL and htf_plFound

htf_priceHH = htf_phPrice > htf_prevPriceHigh
htf_oscLH = htf_phOsc < htf_prevOscHigh
htf_regBear = showBear and htf_priceHH and htf_oscLH and htf_phFound

htf_priceHL = htf_plPrice > htf_prevPriceLow
htf_oscLL = htf_plOsc < htf_prevOscLow
htf_hidBull = plotHiddenBull and htf_priceHL and htf_oscLL and htf_plFound

htf_priceLH = htf_phPrice < htf_prevPriceHigh
htf_oscHH = htf_phOsc > htf_prevOscHigh
htf_hidBear = plotHiddenBear and htf_priceLH and htf_oscHH and htf_phFound

htf_bullStrength = calcStrength(htf_plPrice, htf_prevPriceLow, htf_plOsc, htf_prevOscLow)
htf_bearStrength = calcStrength(htf_phPrice, htf_prevPriceHigh, htf_phOsc, htf_prevOscHigh)

// HTF divergence strength is normalized against prior HTF pivot-event values.
htf_strengthAvgBull = math.max(nz(ta.sma(htf_bullStrength, 100), 0.0), minStrength)
htf_strengthScoreBull = clamp01((htf_bullStrength / htf_strengthAvgBull) * 0.75) * 100
htf_strengthAvgBear = math.max(nz(ta.sma(htf_bearStrength, 100), 0.0), minStrength)
htf_strengthScoreBear = clamp01((htf_bearStrength / htf_strengthAvgBear) * 0.75) * 100

htf_bullOK = not useSmartScore or htf_bullStrength >= minStrength
htf_bearOK = not useSmartScore or htf_bearStrength >= minStrength

var int lastBullDivBar = na
var int lastBearDivBar = na
var int lastHidBullDivBar = na
var int lastHidBearDivBar = na
var int lastHtfBullDivBar = na
var int lastHtfBearDivBar = na
var int lastBullExhaustionBar = na
var int lastBearExhaustionBar = na

htf_regBullSig = htf_regBull and htf_bullOK
htf_regBearSig = htf_regBear and htf_bearOK
htf_hidBullSig = htf_hidBull and htf_bullOK
htf_hidBearSig = htf_hidBear and htf_bearOK

// HTF divergence cooldown is measured in chart bars after each confirmed HTF condition.
htfBullDivCooldownOK = htfCooldownBars == 0 or na(lastHtfBullDivBar) or bar_index - lastHtfBullDivBar >= htfCooldownBars
htfBearDivCooldownOK = htfCooldownBars == 0 or na(lastHtfBearDivBar) or bar_index - lastHtfBearDivBar >= htfCooldownBars
htf_regBullSig := htf_regBullSig and htfBullDivCooldownOK
htf_regBearSig := htf_regBearSig and htfBearDivCooldownOK
htf_hidBullSig := htf_hidBullSig and htfBullDivCooldownOK
htf_hidBearSig := htf_hidBearSig and htfBearDivCooldownOK

// Trend and volume components are captured at the confirmed HTF oscillator pivot.
htf_trendScoreBull = nz(htf_plTrendScore, 0.0)
htf_trendScoreBear = nz(htf_phTrendScore, 0.0)
htf_volumeSpikeBull = nz(htf_plVolScore, 0.0)
htf_volumeSpikeBear = nz(htf_phVolScore, 0.0)

// HTF composite score: divergence strength + HTF trend context + HTF volume participation.
htf_wStrength = weightDivStrength
htf_wTrend = weightTrend
htf_wVol = weightVolumeSpike
htf_wTotal = htf_wStrength + htf_wTrend + htf_wVol
htf_wNorm = htf_wTotal > 0 ? htf_wTotal : 1.0

htf_bullScoreRaw = (htf_strengthScoreBull * htf_wStrength + htf_trendScoreBull * htf_wTrend + htf_volumeSpikeBull * htf_wVol) / htf_wNorm
htf_bearScoreRaw = (htf_strengthScoreBear * htf_wStrength + htf_trendScoreBear * htf_wTrend + htf_volumeSpikeBear * htf_wVol) / htf_wNorm

htf_bullRawMean = nz(ta.sma(htf_bullScoreRaw, 120), htf_bullScoreRaw)
htf_bearRawMean = nz(ta.sma(htf_bearScoreRaw, 120), htf_bearScoreRaw)
htf_bullRawDev = nz(ta.stdev(htf_bullScoreRaw, 120), 0.0)
htf_bearRawDev = nz(ta.stdev(htf_bearScoreRaw, 120), 0.0)

htf_bullScoreBase = useAdaptiveScaling ? adaptiveScore(htf_bullScoreRaw, htf_bullRawMean, htf_bullRawDev) : htf_bullScoreRaw
htf_bearScoreBase = useAdaptiveScaling ? adaptiveScore(htf_bearScoreRaw, htf_bearRawMean, htf_bearRawDev) : htf_bearScoreRaw

htf_bullScore = math.pow(htf_bullScoreBase / 100.0, signalBoost) * 100.0
htf_bearScore = math.pow(htf_bearScoreBase / 100.0, signalBoost) * 100.0
htf_bullGrade = htf_gradeText(htf_bullScore)
htf_bearGrade = htf_gradeText(htf_bearScore)

htf_bullFilter = htfGradeAllowed(htf_bullGrade)
htf_bearFilter = htfGradeAllowed(htf_bearGrade)
htf_regBullSig := htf_regBullSig and htf_bullFilter
htf_regBearSig := htf_regBearSig and htf_bearFilter
htf_hidBullSig := htf_hidBullSig and htf_bullFilter
htf_hidBearSig := htf_hidBearSig and htf_bearFilter

//--------------------------------------------------
// STRENGTH + QUALITY SCORING
//--------------------------------------------------

bullStrength = calcStrength(low[lbR],prevPriceLow,osc[lbR],prevOscLow)
bearStrength = calcStrength(high[lbR],prevPriceHigh,osc[lbR],prevOscHigh)

strengthAvgBull = math.max(nz(ta.sma(bullStrength, 100), 0.0), minStrength)
strengthScoreBull = clamp01((bullStrength / strengthAvgBull) * 0.75) * 100
strengthAvgBear = math.max(nz(ta.sma(bearStrength, 100), 0.0), minStrength)
strengthScoreBear = clamp01((bearStrength / strengthAvgBear) * 0.75) * 100

bullOK = not useSmartScore or bullStrength>=minStrength
bearOK = not useSmartScore or bearStrength>=minStrength

regBullSig = regBull and bullOK
regBearSig = regBear and bearOK
hidBullSig = hidBull and bullOK
hidBearSig = hidBear and bearOK

// Regular divergence cooldown
regBullDivCooldownOK = divCooldownBars == 0 or na(lastBullDivBar) or bar_index - lastBullDivBar >= divCooldownBars
regBearDivCooldownOK = divCooldownBars == 0 or na(lastBearDivBar) or bar_index - lastBearDivBar >= divCooldownBars
regBullSig := regBullSig and regBullDivCooldownOK
regBearSig := regBearSig and regBearDivCooldownOK

// Hidden divergence cooldown
hidBullDivCooldownOK = hidDivCooldownBars == 0 or na(lastHidBullDivBar) or bar_index - lastHidBullDivBar >= hidDivCooldownBars
hidBearDivCooldownOK = hidDivCooldownBars == 0 or na(lastHidBearDivBar) or bar_index - lastHidBearDivBar >= hidDivCooldownBars
hidBullSig := hidBullSig and hidBullDivCooldownOK
hidBearSig := hidBearSig and hidBearDivCooldownOK

regBullSigExhausted = regBullSig and bullExhaustion
regBearSigExhausted = regBearSig and bearExhaustion

emaFast = ta.ema(close, 21)
emaSlow = ta.ema(close, 55)
trendBull = close[lbR] > emaSlow[lbR] and emaFast[lbR] >= emaSlow[lbR]
trendBear = close[lbR] < emaSlow[lbR] and emaFast[lbR] <= emaSlow[lbR]
trendScoreBull = trendBull ? 100.0 : 0.0
trendScoreBear = trendBear ? 100.0 : 0.0

deltaMomRaw = ta.change(ta.ema(delta, 5), 3)
deltaMomScale = math.max(nz(ta.sma(math.abs(deltaMomRaw), 50), 0.0), syminfo.mintick)
deltaMomentumBull = scoreDirection(deltaMomRaw[lbR], deltaMomScale[lbR], true)
deltaMomentumBear = scoreDirection(deltaMomRaw[lbR], deltaMomScale[lbR], false)

volBase = math.max(nz(ta.sma(volume, 20)[lbR], 0.0), 1.0)
volumeSpike = clamp01((volume[lbR] / volBase) / 2.0) * 100

volMA = ta.sma(volume, absorptionVolLen)
avgAbsDelta = ta.sma(math.abs(delta), absorptionDeltaLen)
avgAbsRange = ta.sma(high - low, absorptionRangeLen)
barRange = math.max(high - low, syminfo.mintick)
bodyRatio = math.abs(close - open) / barRange

deltaSpikeBuy = delta < -avgAbsDelta * absorptionDeltaMult
deltaSpikeSell = delta > avgAbsDelta * absorptionDeltaMult
volumeSpikeAbs = volume > volMA * absorptionVolMult
smallRangeAbs = barRange <= avgAbsRange * absorptionRangeMult
smallBodyAbs = bodyRatio <= absorptionBodyMaxRatio
bullOppositeClose = close >= open
bearOppositeClose = close <= open

bullAbsorptionRaw = deltaSpikeBuy and volumeSpikeAbs and smallRangeAbs and smallBodyAbs and (not absorptionUseOppositeClose or bullOppositeClose)
bearAbsorptionRaw = deltaSpikeSell and volumeSpikeAbs and smallRangeAbs and smallBodyAbs and (not absorptionUseOppositeClose or bearOppositeClose)

bullDeltaStage = deltaSpikeBuy
bearDeltaStage = deltaSpikeSell
bullBaseFilterStage = bullDeltaStage and volumeSpikeAbs and smallRangeAbs and smallBodyAbs
bearBaseFilterStage = bearDeltaStage and volumeSpikeAbs and smallRangeAbs and smallBodyAbs
bullOppCloseStage = bullBaseFilterStage and (not absorptionUseOppositeClose or bullOppositeClose)
bearOppCloseStage = bearBaseFilterStage and (not absorptionUseOppositeClose or bearOppositeClose)



var int lastAbsorbSellBar = na
var int lastAbsorbBuyBar = na







int pivotDistBull = hasTwoPl ? (currPlBar - prevPlBar) : na
int pivotDistBear = hasTwoPh ? (currPhBar - prevPhBar) : na
pivotDistanceBull = hasTwoPl ? clamp01(pivotDistBull / ((lbL + lbR) * 2.0)) * 100 : 0.0
pivotDistanceBear = hasTwoPh ? clamp01(pivotDistBear / ((lbL + lbR) * 2.0)) * 100 : 0.0

htfConfirmBull = not showHTF or htf_tf == "" ? 50.0 : (htf_regBullSig or htf_hidBullSig ? 100.0 : 0.0)
htfConfirmBear = not showHTF or htf_tf == "" ? 50.0 : (htf_regBearSig or htf_hidBearSig ? 100.0 : 0.0)

wTrend = weightTrend
wTotal = weightDivStrength + weightDeltaMomentum + weightVolumeSpike + weightHTF + weightPivotDistance + wTrend
wNorm = wTotal > 0 ? wTotal : 1.0

bullScoreRaw = (strengthScoreBull * weightDivStrength + deltaMomentumBull * weightDeltaMomentum + volumeSpike * weightVolumeSpike + htfConfirmBull * weightHTF + pivotDistanceBull * weightPivotDistance + trendScoreBull * wTrend) / wNorm
bearScoreRaw = (strengthScoreBear * weightDivStrength + deltaMomentumBear * weightDeltaMomentum + volumeSpike * weightVolumeSpike + htfConfirmBear * weightHTF + pivotDistanceBear * weightPivotDistance + trendScoreBear * wTrend) / wNorm

bullRawMean = nz(ta.sma(bullScoreRaw, 120), bullScoreRaw)
bearRawMean = nz(ta.sma(bearScoreRaw, 120), bearScoreRaw)
bullRawDev = nz(ta.stdev(bullScoreRaw, 120), 0.0)
bearRawDev = nz(ta.stdev(bearScoreRaw, 120), 0.0)

bullScoreBase = useAdaptiveScaling ? adaptiveScore(bullScoreRaw, bullRawMean, bullRawDev) : bullScoreRaw
bearScoreBase = useAdaptiveScaling ? adaptiveScore(bearScoreRaw, bearRawMean, bearRawDev) : bearScoreRaw

bullScore = math.pow(bullScoreBase / 100.0, signalBoost) * 100.0
bearScore = math.pow(bearScoreBase / 100.0, signalBoost) * 100.0

bullGrade = gradeText(bullScore)
bearGrade = gradeText(bearScore)

bullFilter = gradeAllowed(bullGrade)
bearFilter = gradeAllowed(bearGrade)

// Absorption-specific sigs (independent of main grade filter AND display toggles)
// Use raw divergence conditions so absorption works even when Regular/Hidden toggles are off
bullAbsorbOK = absorbGradeAllowed(bullGrade)
bearAbsorbOK = absorbGradeAllowed(bearGrade)
rawRegBull = priceLL and oscHL and plFound
rawRegBear = priceHH and oscLH and phFound
rawHidBull = priceHL and oscLL and plFound
rawHidBear = priceLH and oscHH and phFound
bullSigAbsorb = (rawRegBull or rawHidBull) and bullOK and bullAbsorbOK
bearSigAbsorb = (rawRegBear or rawHidBear) and bearOK and bearAbsorbOK

regBullSig := regBullSig and bullFilter
hidBullSig := hidBullSig and bullFilter
regBearSig := regBearSig and bearFilter
hidBearSig := hidBearSig and bearFilter

// Compute absorption confluence using GRADED divergences + absorption-specific grade filter
bullBarsSinceGraded = ta.barssince(bullSigAbsorb)
bearBarsSinceGraded = ta.barssince(bearSigAbsorb)
string bullConfGrade = bullBarsSinceGraded <= absorptionConfluenceLookback ? gradeText(ta.valuewhen(bullSigAbsorb, bullScore, 0)) : na
string bearConfGrade = bearBarsSinceGraded <= absorptionConfluenceLookback ? gradeText(ta.valuewhen(bearSigAbsorb, bearScore, 0)) : na
absorbBuyConfluenceOK = not absorptionUseDivConfluence or (not na(bullBarsSinceGraded) and bullBarsSinceGraded <= absorptionConfluenceLookback)
absorbSellConfluenceOK = not absorptionUseDivConfluence or (not na(bearBarsSinceGraded) and bearBarsSinceGraded <= absorptionConfluenceLookback)

// Cooldowns (independent of grade)
absorbSellCooldownOK = na(lastAbsorbSellBar) or bar_index - lastAbsorbSellBar >= absorptionCooldownBars
absorbBuyCooldownOK = na(lastAbsorbBuyBar) or bar_index - lastAbsorbBuyBar >= absorptionCooldownBars

// Final absorption signals with grade filtering
absorbBuy = bullOppCloseStage and absorbBuyCooldownOK and absorbBuyConfluenceOK and bullAbsorptionRaw
absorbSell = bearOppCloseStage and absorbSellCooldownOK and absorbSellConfluenceOK and bearAbsorptionRaw

// Absorption grades (for labels)
string absorbBuyGrade = bullConfGrade
string absorbSellGrade = bearConfGrade


// Debug stages use grade-INDEPENDENT confluence/cooldown
bullCooldownStage = bullOppCloseStage and absorbBuyCooldownOK
bearCooldownStage = bearOppCloseStage and absorbSellCooldownOK
bullConfluenceStage = bullCooldownStage and absorbBuyConfluenceOK
bearConfluenceStage = bearCooldownStage and absorbSellConfluenceOK


if absorbSell
    lastAbsorbSellBar := bar_index
if absorbBuy
    lastAbsorbBuyBar := bar_index

// Track last divergence bars for cooldown
if regBullSig
    lastBullDivBar := bar_index
if regBearSig
    lastBearDivBar := bar_index
if hidBullSig
    lastHidBullDivBar := bar_index
if hidBearSig
    lastHidBearDivBar := bar_index
if htf_regBullSig or htf_hidBullSig
    lastHtfBullDivBar := bar_index
if htf_regBearSig or htf_hidBearSig
    lastHtfBearDivBar := bar_index
regBullMarkerY = osc[lbR] - normalMarkerOffsetMult * labelOffsetRange
regBearMarkerY = osc[lbR] + normalMarkerOffsetMult * labelOffsetRange
hidBullMarkerY = osc[lbR] - hiddenMarkerOffsetMult * labelOffsetRange
hidBearMarkerY = osc[lbR] + hiddenMarkerOffsetMult * labelOffsetRange
bullSignal = regBullSig or hidBullSig
bearSignal = regBearSig or hidBearSig
bullShapeY = regBullSig ? regBullMarkerY : hidBullMarkerY
bearShapeY = regBearSig ? regBearMarkerY : hidBearMarkerY
bullShapeCol = regBullSig ? bullSigCol : hiddenBullSigCol
bearShapeCol = regBearSig ? bearSigCol : hiddenBearSigCol
absorbSellY = h_ + absorptionOffsetMult * labelOffsetRange
absorbBuyY = l_ - absorptionOffsetMult * labelOffsetRange

absDebugStep = labelOffsetRange * 0.18
bullDebugDeltaY = osc - absDebugStep * 1.0
bullDebugFilterY = osc - absDebugStep * 2.0
bullDebugOppY = osc - absDebugStep * 3.0
bullDebugCooldownY = osc - absDebugStep * 4.0
bullDebugConfluenceY = osc - absDebugStep * 5.0
bearDebugDeltaY = osc + absDebugStep * 1.0
bearDebugFilterY = osc + absDebugStep * 2.0
bearDebugOppY = osc + absDebugStep * 3.0
bearDebugCooldownY = osc + absDebugStep * 4.0
bearDebugConfluenceY = osc + absDebugStep * 5.0

plotshape(showSignalMarkers and bullSignal ? bullShapeY : na, title="Bull Signal", style=shape.triangleup, location=location.absolute, offset=-lbR, color=bullShapeCol, size=size.tiny)
plotshape(showSignalMarkers and bearSignal ? bearShapeY : na, title="Bear Signal", style=shape.triangledown, location=location.absolute, offset=-lbR, color=bearShapeCol, size=size.tiny)
plotshape(showAbsorption and absorbSell ? absorbSellY : na, title="Bearish Absorption", style=shape.diamond, location=location.absolute, offset=0, color=absorbSellCol, size=size.tiny)
plotshape(showAbsorption and absorbBuy ? absorbBuyY : na, title="Bullish Absorption", style=shape.diamond, location=location.absolute, offset=0, color=absorbBuyCol, size=size.tiny)
if showAbsorption and absorbSell
    label.new(bar_index, absorbSellY, "Abs Br " + (na(absorbSellGrade) ? "?" : absorbSellGrade), yloc=yloc.price, style=label.style_label_down, color=color.new(absorbSellCol, 80), textcolor=color.rgb(108, 182, 224), size=size.small)
if showAbsorption and absorbBuy
    label.new(bar_index, absorbBuyY, "Abs Bl " + (na(absorbBuyGrade) ? "?" : absorbBuyGrade), yloc=yloc.price, style=label.style_label_up, color=color.new(absorbBuyCol, 80), textcolor=color.rgb(108, 182, 224), size=size.small)
plotshape(showAbsorptionDebug and bullDeltaStage ? bullDebugDeltaY : na, title="Absorption Debug Bull Delta", style=shape.circle, location=location.absolute, color=color.new(color.yellow, 0), size=size.tiny, text="d")
plotshape(showAbsorptionDebug and bullBaseFilterStage ? bullDebugFilterY : na, title="Absorption Debug Bull Filters", style=shape.circle, location=location.absolute, color=color.new(color.silver, 15), size=size.tiny, text="f")
plotshape(showAbsorptionDebug and bullOppCloseStage ? bullDebugOppY : na, title="Absorption Debug Bull Opp Close", style=shape.circle, location=location.absolute, color=color.new(color.purple, 20), size=size.tiny, text="o")
plotshape(showAbsorptionDebug and bullCooldownStage ? bullDebugCooldownY : na, title="Absorption Debug Bull Cooldown", style=shape.circle, location=location.absolute, color=color.new(color.rgb(135, 206, 250), 10), size=size.tiny, textcolor=color.rgb(191, 232, 255), text="c")
plotshape(showAbsorptionDebug and bullConfluenceStage ? bullDebugConfluenceY : na, title="Absorption Debug Bull Confluence", style=shape.circle, location=location.absolute, color=color.new(color.orange, 0), size=size.tiny, text="v")
plotshape(showAbsorptionDebug and bearDeltaStage ? bearDebugDeltaY : na, title="Absorption Debug Bear Delta", style=shape.circle, location=location.absolute, color=color.new(color.yellow, 0), size=size.tiny, text="d")
plotshape(showAbsorptionDebug and bearBaseFilterStage ? bearDebugFilterY : na, title="Absorption Debug Bear Filters", style=shape.circle, location=location.absolute, color=color.new(color.silver, 15), size=size.tiny, text="f")
plotshape(showAbsorptionDebug and bearOppCloseStage ? bearDebugOppY : na, title="Absorption Debug Bear Opp Close", style=shape.circle, location=location.absolute, color=color.new(color.purple, 20), size=size.tiny, text="o")
plotshape(showAbsorptionDebug and bearCooldownStage ? bearDebugCooldownY : na, title="Absorption Debug Bear Cooldown", style=shape.circle, location=location.absolute, color=color.new(color.rgb(135, 206, 250), 10), size=size.tiny, textcolor=color.rgb(191, 232, 255), text="c")
plotshape(showAbsorptionDebug and bearConfluenceStage ? bearDebugConfluenceY : na, title="Absorption Debug Bear Confluence", style=shape.circle, location=location.absolute, color=color.new(color.orange, 0), size=size.tiny, text="v")

float htfBullY = osc - (1.5 + htf_offset) * labelOffsetRange
float htfBearY = osc + (1.5 + htf_offset) * labelOffsetRange
float htfHidBullY = osc - (1.0 + htf_offset) * labelOffsetRange
float htfHidBearY = osc + (1.0 + htf_offset) * labelOffsetRange

if showHTF and htf_regBullSig
    label.new(bar_index, htfBullY, "", yloc=yloc.price, style=label.style_triangleup, color=htf_reg_bull_col, size=size.tiny)
    label.new(bar_index + 1, htfBullY - 0.3 * labelOffsetRange, "HTF Bl " + htf_bullGrade, yloc=yloc.price, style=label.style_none, color=na, textcolor=tableTextCol, size=size.small)
if showHTF and htf_regBearSig
    label.new(bar_index, htfBearY, "", yloc=yloc.price, style=label.style_triangledown, color=htf_reg_bear_col, size=size.tiny)
    label.new(bar_index + 1, htfBearY + 0.3 * labelOffsetRange, "HTF Br " + htf_bearGrade, yloc=yloc.price, style=label.style_none, color=na, textcolor=tableTextCol, size=size.small)
if showHTF and htf_hidBullSig
    label.new(bar_index, htfHidBullY, "", yloc=yloc.price, style=label.style_triangleup, color=htf_hid_bull_col, size=size.tiny)
    label.new(bar_index + 1, htfHidBullY - 0.3 * labelOffsetRange, "HTF H Bl " + htf_bullGrade, yloc=yloc.price, style=label.style_none, color=na, textcolor=tableTextCol, size=size.small)
if showHTF and htf_hidBearSig
    label.new(bar_index, htfHidBearY, "", yloc=yloc.price, style=label.style_triangledown, color=htf_hid_bear_col, size=size.tiny)
    label.new(bar_index + 1, htfHidBearY + 0.3 * labelOffsetRange, "HTF H Br " + htf_bearGrade, yloc=yloc.price, style=label.style_none, color=na, textcolor=tableTextCol, size=size.small)


if showStrength and regBullSig
    float labelY = osc[lbR] - normalOffsetMult * labelOffsetRange
    label.new(bar_index[lbR], labelY, str.tostring(bullStrength, "#.##") + "% " + bullGrade, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_upper_left, color=color.new(bullSigCol, 80), textcolor=tableTextCol, size=size.small)

if showStrength and regBearSig
    float labelY = osc[lbR] + normalOffsetMult * labelOffsetRange
    label.new(bar_index[lbR], labelY, str.tostring(bearStrength, "#.##") + "% " + bearGrade, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_lower_left, color=color.new(bearSigCol, 80), textcolor=tableTextCol, size=size.small)

if showStrength and hidBullSig
    float labelY = osc[lbR] - hiddenOffsetMult * labelOffsetRange
    label.new(bar_index[lbR], labelY, str.tostring(bullStrength, "H #.##") + "% " + bullGrade, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_upper_left, color=color.new(hiddenBullSigCol, 80), textcolor=tableTextCol, size=size.small)

if showStrength and hidBearSig
    float labelY = osc[lbR] + hiddenOffsetMult * labelOffsetRange
    label.new(bar_index[lbR], labelY, str.tostring(bearStrength, "H #.##") + "% " + bearGrade, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_lower_left, color=color.new(hiddenBearSigCol, 80), textcolor=tableTextCol, size=size.small)

alertcondition(regBullSig, title="Regular Bull Divergence", message="Regular Bullish Divergence detected on Cumulative Delta")
alertcondition(regBearSig, title="Regular Bear Divergence", message="Regular Bearish Divergence detected on Cumulative Delta")
alertcondition(hidBullSig, title="Hidden Bull Divergence", message="Hidden Bullish Divergence detected on Cumulative Delta")
alertcondition(hidBearSig, title="Hidden Bear Divergence", message="Hidden Bearish Divergence detected on Cumulative Delta")
alertcondition((regBullSig or hidBullSig) and bullGrade == "A+", title="A+ Bull Divergence", message="A+ Bullish divergence category on Cumulative Delta")
alertcondition((regBearSig or hidBearSig) and bearGrade == "A+", title="A+ Bear Divergence", message="A+ Bearish divergence category on Cumulative Delta")
alertcondition(showAbsorption and absorbSell, title="Bearish Absorption", message="Bearish absorption detected: strong positive estimated delta with limited upside response")
alertcondition(showAbsorption and absorbBuy, title="Bullish Absorption", message="Bullish absorption detected: strong negative estimated delta with limited downside response")
alertcondition(regBullSigExhausted, title="Bull Divergence + Exhaustion", message="Bull divergence with negative cumulative-delta z-score extreme")
alertcondition(regBearSigExhausted, title="Bear Divergence + Exhaustion", message="Bear divergence with positive cumulative-delta z-score extreme")

//--------------------------------------------------
// HISTORICAL OUTCOME COUNTERS
//--------------------------------------------------

var int bullW=0
var int bullL=0
var int bearW=0
var int bearL=0
var int hBullW=0
var int hBullL=0
var int hBearW=0
var int hBearL=0
var int absorbBullW=0
var int absorbBullL=0
var int absorbBearW=0
var int absorbBearL=0

//--------------------------------------------------
// HISTORICAL OUTCOME STORAGE
//--------------------------------------------------

// Each confirmed condition is tracked independently. Evaluation begins on the
// NEXT bar, because the reference entry is the confirmation bar's close.
// Type: 1=regular bull, 2=regular bear, 3=hidden bull, 4=hidden bear,
//       5=bull absorption heuristic, 6=bear absorption heuristic.
var outcomeIds = array.new_int()
var outcomeTypes = array.new_int()
var outcomeTps = array.new_float()
var outcomeSls = array.new_float()
var outcomeStartBars = array.new_int()
var int nextOutcomeId = 0

// Only one TP/SL pair is displayed: the most recent confirmed condition.
// The historical outcome queue remains independent from these display objects.
var line slLine = na
var line tpLine = na
var label slLineLabel = na
var label tpLineLabel = na
var int tpSlOutcomeId = na

//--------------------------------------------------
// DRAW + QUEUE HISTORICAL OUTCOME
//--------------------------------------------------

if regBullSig
    if showPivotToPivotLines and hasTwoPl
        line.new(prevPlBar, prevPlOsc, currPlBar, currPlOsc, color=color.new(bullDivCol, lineTransp), width=divWidth, extend=lineExt)
    if showPriceDivLines and hasTwoPl
        line.new(prevPlBar, prevPlPrice, currPlBar, currPlPrice, color=color.new(bullDivCol, lineTransp), width=divWidth, extend=lineExt, force_overlay=true)
    float evalTp = close * (1 + tp_perc)
    float evalSl = close * (1 - sl_perc)
    nextOutcomeId += 1
    array.push(outcomeIds, nextOutcomeId)
    array.push(outcomeTypes, 1)
    array.push(outcomeTps, evalTp)
    array.push(outcomeSls, evalSl)
    array.push(outcomeStartBars, bar_index)
    if showTPSLlines
        line.delete(slLine)
        line.delete(tpLine)
        label.delete(slLineLabel)
        label.delete(tpLineLabel)
        slLine := line.new(bar_index + 1, evalSl, bar_index + 2, evalSl, color=slLineCol, width=slLineWidth, style=getLineStyle(slLineStyle), extend=extend.right, force_overlay=true)
        tpLine := line.new(bar_index + 1, evalTp, bar_index + 2, evalTp, color=tpLineCol, width=tpLineWidth, style=getLineStyle(tpLineStyle), extend=extend.right, force_overlay=true)
        slLineLabel := label.new(bar_index + 1, evalSl, "Bull Div " + (na(bullGrade) ? "?" : bullGrade) + " SL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(slLineCol, 72), textcolor=tableTextCol, size=size.small, textalign=text.align_center, force_overlay=true)
        tpLineLabel := label.new(bar_index + 1, evalTp, "Bull Div " + (na(bullGrade) ? "?" : bullGrade) + " TP", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(tpLineCol, 72), textcolor=tableTextCol, size=size.small, textalign=text.align_center, force_overlay=true)
        tpSlOutcomeId := nextOutcomeId

if regBearSig
    if showPivotToPivotLines and hasTwoPh
        line.new(prevPhBar, prevPhOsc, currPhBar, currPhOsc, color=color.new(bearDivCol, lineTransp), width=divWidth, extend=lineExt)
    if showPriceDivLines and hasTwoPh
        line.new(prevPhBar, prevPhPrice, currPhBar, currPhPrice, color=color.new(bearDivCol, lineTransp), width=divWidth, extend=lineExt, force_overlay=true)
    float evalTp = close * (1 - tp_perc)
    float evalSl = close * (1 + sl_perc)
    nextOutcomeId += 1
    array.push(outcomeIds, nextOutcomeId)
    array.push(outcomeTypes, 2)
    array.push(outcomeTps, evalTp)
    array.push(outcomeSls, evalSl)
    array.push(outcomeStartBars, bar_index)
    if showTPSLlines
        line.delete(slLine)
        line.delete(tpLine)
        label.delete(slLineLabel)
        label.delete(tpLineLabel)
        slLine := line.new(bar_index + 1, evalSl, bar_index + 2, evalSl, color=slLineCol, width=slLineWidth, style=getLineStyle(slLineStyle), extend=extend.right, force_overlay=true)
        tpLine := line.new(bar_index + 1, evalTp, bar_index + 2, evalTp, color=tpLineCol, width=tpLineWidth, style=getLineStyle(tpLineStyle), extend=extend.right, force_overlay=true)
        slLineLabel := label.new(bar_index + 1, evalSl, "Bear Div " + (na(bearGrade) ? "?" : bearGrade) + " SL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(slLineCol, 72), textcolor=tableTextCol, size=size.small, textalign=text.align_center, force_overlay=true)
        tpLineLabel := label.new(bar_index + 1, evalTp, "Bear Div " + (na(bearGrade) ? "?" : bearGrade) + " TP", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(tpLineCol, 72), textcolor=tableTextCol, size=size.small, textalign=text.align_center, force_overlay=true)
        tpSlOutcomeId := nextOutcomeId

if hidBullSig
    if showPivotToPivotLines and hasTwoPl
        line.new(prevPlBar, prevPlOsc, currPlBar, currPlOsc, color=color.new(hiddenBullCol, lineTransp), width=divWidth, extend=lineExt)
    if showPriceDivLines and hasTwoPl
        line.new(prevPlBar, prevPlPrice, currPlBar, currPlPrice, color=color.new(hiddenBullCol, lineTransp), width=divWidth, extend=lineExt, force_overlay=true)
    float evalTp = close * (1 + tp_perc)
    float evalSl = close * (1 - sl_perc)
    nextOutcomeId += 1
    array.push(outcomeIds, nextOutcomeId)
    array.push(outcomeTypes, 3)
    array.push(outcomeTps, evalTp)
    array.push(outcomeSls, evalSl)
    array.push(outcomeStartBars, bar_index)
    if showTPSLlines
        line.delete(slLine)
        line.delete(tpLine)
        label.delete(slLineLabel)
        label.delete(tpLineLabel)
        slLine := line.new(bar_index + 1, evalSl, bar_index + 2, evalSl, color=slLineCol, width=slLineWidth, style=getLineStyle(slLineStyle), extend=extend.right, force_overlay=true)
        tpLine := line.new(bar_index + 1, evalTp, bar_index + 2, evalTp, color=tpLineCol, width=tpLineWidth, style=getLineStyle(tpLineStyle), extend=extend.right, force_overlay=true)
        slLineLabel := label.new(bar_index + 1, evalSl, "H Bull Div " + (na(bullGrade) ? "?" : bullGrade) + " SL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(slLineCol, 72), textcolor=tableTextCol, size=size.small, textalign=text.align_center, force_overlay=true)
        tpLineLabel := label.new(bar_index + 1, evalTp, "H Bull Div " + (na(bullGrade) ? "?" : bullGrade) + " TP", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(tpLineCol, 72), textcolor=tableTextCol, size=size.small, textalign=text.align_center, force_overlay=true)
        tpSlOutcomeId := nextOutcomeId

if hidBearSig
    if showPivotToPivotLines and hasTwoPh
        line.new(prevPhBar, prevPhOsc, currPhBar, currPhOsc, color=color.new(hiddenBearCol, lineTransp), width=divWidth, extend=lineExt)
    if showPriceDivLines and hasTwoPh
        line.new(prevPhBar, prevPhPrice, currPhBar, currPhPrice, color=color.new(hiddenBearCol, lineTransp), width=divWidth, extend=lineExt, force_overlay=true)
    float evalTp = close * (1 - tp_perc)
    float evalSl = close * (1 + sl_perc)
    nextOutcomeId += 1
    array.push(outcomeIds, nextOutcomeId)
    array.push(outcomeTypes, 4)
    array.push(outcomeTps, evalTp)
    array.push(outcomeSls, evalSl)
    array.push(outcomeStartBars, bar_index)
    if showTPSLlines
        line.delete(slLine)
        line.delete(tpLine)
        label.delete(slLineLabel)
        label.delete(tpLineLabel)
        slLine := line.new(bar_index + 1, evalSl, bar_index + 2, evalSl, color=slLineCol, width=slLineWidth, style=getLineStyle(slLineStyle), extend=extend.right, force_overlay=true)
        tpLine := line.new(bar_index + 1, evalTp, bar_index + 2, evalTp, color=tpLineCol, width=tpLineWidth, style=getLineStyle(tpLineStyle), extend=extend.right, force_overlay=true)
        slLineLabel := label.new(bar_index + 1, evalSl, "H Bear Div " + (na(bearGrade) ? "?" : bearGrade) + " SL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(slLineCol, 72), textcolor=tableTextCol, size=size.small, textalign=text.align_center, force_overlay=true)
        tpLineLabel := label.new(bar_index + 1, evalTp, "H Bear Div " + (na(bearGrade) ? "?" : bearGrade) + " TP", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(tpLineCol, 72), textcolor=tableTextCol, size=size.small, textalign=text.align_center, force_overlay=true)
        tpSlOutcomeId := nextOutcomeId

if showAbsorption and absorbBuy
    float evalTp = close * (1 + tp_perc)
    float evalSl = close * (1 - sl_perc)
    nextOutcomeId += 1
    array.push(outcomeIds, nextOutcomeId)
    array.push(outcomeTypes, 5)
    array.push(outcomeTps, evalTp)
    array.push(outcomeSls, evalSl)
    array.push(outcomeStartBars, bar_index)
    if showTPSLlines
        line.delete(slLine)
        line.delete(tpLine)
        label.delete(slLineLabel)
        label.delete(tpLineLabel)
        slLine := line.new(bar_index + 1, evalSl, bar_index + 2, evalSl, color=slLineCol, width=slLineWidth, style=getLineStyle(slLineStyle), extend=extend.right, force_overlay=true)
        tpLine := line.new(bar_index + 1, evalTp, bar_index + 2, evalTp, color=tpLineCol, width=tpLineWidth, style=getLineStyle(tpLineStyle), extend=extend.right, force_overlay=true)
        slLineLabel := label.new(bar_index + 1, evalSl, "Abs Bull " + (na(absorbBuyGrade) ? "?" : absorbBuyGrade) + " SL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(slLineCol, 72), textcolor=tableTextCol, size=size.small, textalign=text.align_center, force_overlay=true)
        tpLineLabel := label.new(bar_index + 1, evalTp, "Abs Bull " + (na(absorbBuyGrade) ? "?" : absorbBuyGrade) + " TP", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(tpLineCol, 72), textcolor=tableTextCol, size=size.small, textalign=text.align_center, force_overlay=true)
        tpSlOutcomeId := nextOutcomeId

if showAbsorption and absorbSell
    float evalTp = close * (1 - tp_perc)
    float evalSl = close * (1 + sl_perc)
    nextOutcomeId += 1
    array.push(outcomeIds, nextOutcomeId)
    array.push(outcomeTypes, 6)
    array.push(outcomeTps, evalTp)
    array.push(outcomeSls, evalSl)
    array.push(outcomeStartBars, bar_index)
    if showTPSLlines
        line.delete(slLine)
        line.delete(tpLine)
        label.delete(slLineLabel)
        label.delete(tpLineLabel)
        slLine := line.new(bar_index + 1, evalSl, bar_index + 2, evalSl, color=slLineCol, width=slLineWidth, style=getLineStyle(slLineStyle), extend=extend.right, force_overlay=true)
        tpLine := line.new(bar_index + 1, evalTp, bar_index + 2, evalTp, color=tpLineCol, width=tpLineWidth, style=getLineStyle(tpLineStyle), extend=extend.right, force_overlay=true)
        slLineLabel := label.new(bar_index + 1, evalSl, "Abs Bear " + (na(absorbSellGrade) ? "?" : absorbSellGrade) + " SL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(slLineCol, 72), textcolor=tableTextCol, size=size.small, textalign=text.align_center, force_overlay=true)
        tpLineLabel := label.new(bar_index + 1, evalTp, "Abs Bear " + (na(absorbSellGrade) ? "?" : absorbSellGrade) + " TP", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(tpLineCol, 72), textcolor=tableTextCol, size=size.small, textalign=text.align_center, force_overlay=true)
        tpSlOutcomeId := nextOutcomeId

//--------------------------------------------------
// HISTORICAL OUTCOME RESOLUTION
//--------------------------------------------------

bool latestOutcomeResolved = false
int outcomeIndex = array.size(outcomeIds) - 1
while outcomeIndex >= 0
    int startBar = array.get(outcomeStartBars, outcomeIndex)
    if bar_index > startBar
        int outcomeType = array.get(outcomeTypes, outcomeIndex)
        int outcomeId = array.get(outcomeIds, outcomeIndex)
        float evalTp = array.get(outcomeTps, outcomeIndex)
        float evalSl = array.get(outcomeSls, outcomeIndex)
        bool bullishOutcome = outcomeType == 1 or outcomeType == 3 or outcomeType == 5
        bool stopTouched = bullishOutcome ? low <= evalSl : high >= evalSl
        bool targetTouched = bullishOutcome ? high >= evalTp : low <= evalTp
        bool resolved = stopTouched or targetTouched
        if resolved
            // Conservative same-bar rule: if both levels are touched, count stop first.
            bool targetFirst = targetTouched and not stopTouched
            if outcomeType == 1
                if targetFirst
                    bullW += 1
                else
                    bullL += 1
            else if outcomeType == 2
                if targetFirst
                    bearW += 1
                else
                    bearL += 1
            else if outcomeType == 3
                if targetFirst
                    hBullW += 1
                else
                    hBullL += 1
            else if outcomeType == 4
                if targetFirst
                    hBearW += 1
                else
                    hBearL += 1
            else if outcomeType == 5
                if targetFirst
                    absorbBullW += 1
                else
                    absorbBullL += 1
            else if outcomeType == 6
                if targetFirst
                    absorbBearW += 1
                else
                    absorbBearL += 1

            if not na(tpSlOutcomeId) and outcomeId == tpSlOutcomeId
                latestOutcomeResolved := true

            array.remove(outcomeIds, outcomeIndex)
            array.remove(outcomeTypes, outcomeIndex)
            array.remove(outcomeTps, outcomeIndex)
            array.remove(outcomeSls, outcomeIndex)
            array.remove(outcomeStartBars, outcomeIndex)
    outcomeIndex -= 1

if showTPSLlines and latestOutcomeResolved and not na(slLine)
    // Keep the most recent resolved evaluation pair visible instead of deleting it.
    // While unresolved the lines extend to the right. On resolution they stop at
    // the bar where either the target or stop was first touched, and remain on
    // the chart until a newer qualifying condition replaces them.
    line.set_extend(slLine, extend.none)
    line.set_extend(tpLine, extend.none)
    line.set_x2(slLine, bar_index)
    line.set_x2(tpLine, bar_index)
    // Keep the Target/Stop labels fixed at the original left endpoint.
    // Only the right edge of each evaluation line moves/stops.
    tpSlOutcomeId := na

//--------------------------------------------------
// TABLES
//--------------------------------------------------

tablePosition(posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_left

if barstate.islast

    bullTotal=bullW+bullL
    bearTotal=bearW+bearL
    hBullTotal=hBullW+hBullL
    hBearTotal=hBearW+hBearL
    absorbBullTotal=absorbBullW+absorbBullL
    absorbBearTotal=absorbBearW+absorbBearL

    bullRatio=bullW/math.max(bullTotal,1)*100
    bearRatio=bearW/math.max(bearTotal,1)*100
    hBullRatio=hBullW/math.max(hBullTotal,1)*100
    hBearRatio=hBearW/math.max(hBearTotal,1)*100
    absorbBullRatio=absorbBullW/math.max(absorbBullTotal,1)*100
    absorbBearRatio=absorbBearW/math.max(absorbBearTotal,1)*100


    if showBullTable
        bullTable = table.new(tablePosition(bullTablePosInput), 4, 1, border_width=1, frame_width=1, frame_color=color.gray, border_color=color.gray)
        table.cell(bullTable, 0, 0, "Bull", bgcolor=bgTable, text_color=tableTextCol, text_size=size.small)
        table.cell(bullTable, 1, 0, "T:"+str.tostring(bullW), bgcolor=winCol, text_color=tableTextCol, text_size=size.small)
        table.cell(bullTable, 2, 0, "S:"+str.tostring(bullL), bgcolor=lossCol, text_color=tableTextCol, text_size=size.small)
        table.cell(bullTable, 3, 0, str.tostring(bullRatio,"#.##")+"%", bgcolor=bgTable, text_color=tableTextCol, text_size=size.small)

    if showBearTable
        bearTable = table.new(tablePosition(bearTablePosInput), 4, 1, border_width=1, frame_width=1, frame_color=color.gray, border_color=color.gray)
        table.cell(bearTable, 0, 0, "Bear", bgcolor=bgTable, text_color=tableTextCol, text_size=size.small)
        table.cell(bearTable, 1, 0, "T:"+str.tostring(bearW), bgcolor=winCol, text_color=tableTextCol, text_size=size.small)
        table.cell(bearTable, 2, 0, "S:"+str.tostring(bearL), bgcolor=lossCol, text_color=tableTextCol, text_size=size.small)
        table.cell(bearTable, 3, 0, str.tostring(bearRatio,"#.##")+"%", bgcolor=bgTable, text_color=tableTextCol, text_size=size.small)

    if showHBullTable
        hBullTable = table.new(tablePosition(hBullTablePosInput), 4, 1, border_width=1, frame_width=1, frame_color=color.gray, border_color=color.gray)
        table.cell(hBullTable, 0, 0, "H Bull", bgcolor=bgTable, text_color=tableTextCol, text_size=size.small)
        table.cell(hBullTable, 1, 0, "T:"+str.tostring(hBullW), bgcolor=winCol, text_color=tableTextCol, text_size=size.small)
        table.cell(hBullTable, 2, 0, "S:"+str.tostring(hBullL), bgcolor=lossCol, text_color=tableTextCol, text_size=size.small)
        table.cell(hBullTable, 3, 0, str.tostring(hBullRatio,"#.##")+"%", bgcolor=bgTable, text_color=tableTextCol, text_size=size.small)

    if showHBearTable
        hBearTable = table.new(tablePosition(hBearTablePosInput), 4, 1, border_width=1, frame_width=1, frame_color=color.gray, border_color=color.gray)
        table.cell(hBearTable, 0, 0, "H Bear", bgcolor=bgTable, text_color=tableTextCol, text_size=size.small)
        table.cell(hBearTable, 1, 0, "T:"+str.tostring(hBearW), bgcolor=winCol, text_color=tableTextCol, text_size=size.small)
        table.cell(hBearTable, 2, 0, "S:"+str.tostring(hBearL), bgcolor=lossCol, text_color=tableTextCol, text_size=size.small)
        table.cell(hBearTable, 3, 0, str.tostring(hBearRatio,"#.##")+"%", bgcolor=bgTable, text_color=tableTextCol, text_size=size.small)

    if showAbsorbBullTable
        absorbBullTable = table.new(tablePosition(absorbBullTablePosInput), 4, 1, border_width=1, frame_width=1, frame_color=color.gray, border_color=color.gray)
        table.cell(absorbBullTable, 0, 0, "A Bull", bgcolor=bgTable, text_color=tableTextCol, text_size=size.small)
        table.cell(absorbBullTable, 1, 0, "T:"+str.tostring(absorbBullW), bgcolor=winCol, text_color=tableTextCol, text_size=size.small)
        table.cell(absorbBullTable, 2, 0, "S:"+str.tostring(absorbBullL), bgcolor=lossCol, text_color=tableTextCol, text_size=size.small)
        table.cell(absorbBullTable, 3, 0, str.tostring(absorbBullRatio,"#.##")+"%", bgcolor=bgTable, text_color=tableTextCol, text_size=size.small)

    if showAbsorbBearTable
        absorbBearTable = table.new(tablePosition(absorbBearTablePosInput), 4, 1, border_width=1, frame_width=1, frame_color=color.gray, border_color=color.gray)
        table.cell(absorbBearTable, 0, 0, "A Bear", bgcolor=bgTable, text_color=tableTextCol, text_size=size.small)
        table.cell(absorbBearTable, 1, 0, "T:"+str.tostring(absorbBearW), bgcolor=winCol, text_color=tableTextCol, text_size=size.small)
        table.cell(absorbBearTable, 2, 0, "S:"+str.tostring(absorbBearL), bgcolor=lossCol, text_color=tableTextCol, text_size=size.small)
        table.cell(absorbBearTable, 3, 0, str.tostring(absorbBearRatio,"#.##")+"%", bgcolor=bgTable, text_color=tableTextCol, text_size=size.small)
````
