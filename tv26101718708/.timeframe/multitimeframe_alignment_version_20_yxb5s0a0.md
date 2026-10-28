# Multi-Timeframe Alignment Version 2.0

- url: https://www.tradingview.com/script/yXB5s0a0-Multi-Timeframe-Alignment-Version-2-0/
- type: indicator
- pine_id: PUB;1236ba5c9aab40a3b2eab9d4eda9d521
- version: 1.0

## Description

# Multi-Timeframe Alignment Alert — Strength Version

## Purpose of the Indicator

The Multi-Timeframe Alignment Alert — Strength Version was created to address a problem that affects both intraday and swing traders: a market can appear bullish on one chart while the larger timeframe structure remains bearish, or appear bearish on a lower timeframe while the broader trend remains bullish.

Looking at only one timeframe can cause a trader to mistake a temporary pullback for a full trend reversal or mistake a short-lived breakout for a move that is supported by the broader market structure.

This indicator provides a consolidated view of trend direction and trend strength across eight customizable timeframes:

* Weekly
* Daily
* Four-hour
* One-hour
* 30-minute
* 15-minute
* Five-minute
* One-minute

Its primary purpose is to help traders determine whether the price movement visible on their execution chart is supported by the intermediate and higher timeframes.

The indicator is not intended to predict price or produce automatic buy-and-sell signals. Its best purpose is to serve as a directional-bias dashboard, market-condition filter, and pre-trade decision-support tool.

## Why Multi-Timeframe Alignment Is Important

Every timeframe represents a different view of market behavior.

The weekly and daily charts provide broader directional context. The four-hour and one-hour charts help identify the active market structure. The 30-minute and 15-minute charts show how that structure is developing during the trading session. The five-minute and one-minute charts provide more immediate information that may be useful for trade execution.

A bullish signal on a one-minute chart does not necessarily carry the same significance when the weekly, daily, four-hour, and one-hour charts remain bearish. Likewise, a bearish move on a five-minute chart may simply be a temporary pullback inside a larger bullish trend.

This indicator helps traders distinguish between:

* A short-term move occurring against the larger trend
* A pullback occurring inside an established trend
* Partial bullish or bearish alignment
* Complete multi-timeframe alignment
* Strong alignment supported by moving-average direction
* Mixed conditions where the timeframes disagree

The dashboard makes these relationships visible without requiring the trader to repeatedly switch between eight separate charts.

## Why the 30-Minute Timeframe Was Included

The 30-minute timeframe serves an important purpose because it bridges the gap between the 15-minute execution structure and the one-hour directional structure.

The 15-minute chart can respond quickly to intraday price movement, but it may also change direction several times during a session. The one-hour chart provides more stable information, but it may react too slowly to reveal an important shift developing within the current hour.

The 30-minute timeframe provides an intermediate layer of confirmation.

For example, a bullish change on the one-minute, five-minute, and 15-minute charts may represent only a brief rally. When the 30-minute chart also becomes bullish, the move has begun to affect a more meaningful portion of the session. If the one-hour, four-hour, daily, and weekly charts are also bullish, the lower-timeframe movement is occurring with broader directional support.

The 30-minute timeframe can therefore help a trader determine whether a lower-timeframe move is beginning to develop into a more significant structural change or remains only short-term price noise.

## How the Indicator Determines Trend Strength

Each timeframe is evaluated using two conditions:

1. The location of price relative to the selected moving average
2. The direction of the selected moving average

Users can choose between an exponential moving average and a simple moving average. The moving-average length is also customizable.

The default setting uses a 21-period EMA.

The indicator classifies each timeframe into one of five states.

### Strong Bull

Price is above the moving average, and the moving average is rising.

This means that both price location and moving-average direction support a bullish interpretation.

### Weak Bull

Price is above the moving average, but the moving average is not rising.

Price remains on the bullish side of the moving average, but the trend may be flattening, transitioning, or losing upward momentum.

### Strong Bear

Price is below the moving average, and the moving average is falling.

This means that both price location and moving-average direction support a bearish interpretation.

### Weak Bear

Price is below the moving average, but the moving average is not falling.

Price remains on the bearish side of the moving average, but the bearish trend may be flattening, transitioning, or losing downward momentum.

### Neutral

The price and moving-average conditions do not create a clear bullish or bearish classification.

## Overall Alignment Conditions

The indicator combines the individual timeframe readings into an overall market status.

### Strong Bullish Aligned

All eight timeframes are classified as Strong Bull.

This means price is above the selected moving average and the moving average is rising on the weekly, daily, four-hour, one-hour, 30-minute, 15-minute, five-minute, and one-minute charts.

### Bullish Bias

All eight timeframes are bullish, but at least one timeframe is classified as Weak Bull rather than Strong Bull.

The market is directionally aligned, but the strength of the bullish condition is not identical across every timeframe.

### Strong Bearish Aligned

All eight timeframes are classified as Strong Bear.

This means price is below the selected moving average and the moving average is falling on every monitored timeframe.

### Bearish Bias

All eight timeframes are bearish, but at least one timeframe is classified as Weak Bear rather than Strong Bear.

The market is directionally aligned, but the strength of the bearish condition is not identical across every timeframe.

### Mixed

The monitored timeframes are not fully aligned in one direction.

A Mixed reading is useful because it warns the trader that the market is producing conflicting directional information. This may occur during consolidations, pullbacks, reversals, opening volatility, or transitions from one trend to another.

Mixed does not automatically mean that no trading opportunity exists. It means the trader should understand that the opportunity is not supported by complete timeframe agreement.

## Best Purpose and Practical Use

The indicator is best used before entering a trade rather than as a standalone entry trigger.

A practical workflow is to divide the dashboard into three layers.

### Higher-Timeframe Direction

Use the weekly, daily, and four-hour readings to identify the broader market direction.

These timeframes can help answer whether the larger market environment is bullish, bearish, or transitioning.

### Intermediate Market Structure

Use the one-hour and 30-minute readings to evaluate whether the active session structure agrees with the broader trend.

The 30-minute chart is especially useful here because it can identify an intraday shift before that shift becomes fully visible on the one-hour chart.

### Execution Conditions

Use the 15-minute, five-minute, and one-minute readings to evaluate the shorter-term conditions surrounding a potential entry.

The lower timeframes can help show whether price is moving back into alignment after a pullback or beginning to move against the larger trend.

A trader can then combine the dashboard with an independent entry method such as:

* Market-structure confirmation
* Break-and-retest confirmation
* Support or resistance
* Volume analysis
* VWAP
* Liquidity levels
* Candlestick confirmation
* Risk-to-reward requirements

For example, a trader considering a long position may give the setup greater weight when the weekly, daily, four-hour, one-hour, and 30-minute charts are bullish and the 15-minute, five-minute, and one-minute charts are returning to bullish alignment after a pullback.

A trader may be more cautious when the one-minute and five-minute charts are bullish but the 30-minute, one-hour, four-hour, daily, and weekly charts remain bearish. In that situation, the lower-timeframe rally may represent a countertrend move rather than the beginning of a broader bullish trend.

## Dashboard and Visual Features

The on-chart dashboard displays the current condition of each monitored timeframe.

The color-coded trend cells make it easier to distinguish between:

* Strong bullish conditions
* Weak bullish conditions
* Strong bearish conditions
* Weak bearish conditions
* Neutral conditions

The final Status row displays the overall alignment classification.

Users may customize the dashboard position and text size. The dashboard can also be hidden while leaving the indicator’s other visual features active.

## Chart Markers and Background Shading

Optional chart markers identify periods when the market reaches:

* Strong Bullish Alignment
* Bullish Bias
* Strong Bearish Alignment
* Bearish Bias

Optional background shading provides a broader visual indication of the current alignment condition.

The stronger background colors represent complete strong alignment, while the lighter background colors represent general bullish or bearish bias.

These visual tools are intended to make alignment changes easier to recognize. They are not automatic entry instructions.

## Alerts

The indicator includes separate alert conditions for:

* New Strong Bullish Alignment
* New Bullish Bias
* New Strong Bearish Alignment
* New Bearish Bias

The alerts are designed to trigger when the market first enters a new alignment condition rather than repeatedly triggering on every bar while the same condition remains active.

Each alert category can be enabled or disabled independently in the indicator settings.

## Customization

Users can customize:

* The moving-average length
* EMA or SMA calculation
* Weekly timeframe
* Daily timeframe
* Four-hour timeframe
* One-hour timeframe
* 30-minute timeframe
* 15-minute timeframe
* Five-minute timeframe
* One-minute timeframe
* Dashboard location
* Dashboard text size
* Chart markers
* Background highlighting
* Individual alert categories

Although the default settings use common trading timeframes, each timeframe input can be changed to support different intraday, swing-trading, or position-trading workflows.

The indicator is written in Pine Script v6.

## Important Limitations

Multi-timeframe alignment does not guarantee that price will continue in the aligned direction.

Complete alignment may sometimes occur after price has already made an extended move. A strongly bullish reading does not mean that price cannot pull back, and a strongly bearish reading does not mean that price cannot rally.

The indicator does not independently evaluate:

* Support and resistance
* Liquidity
* Volume
* Volatility
* Market profile
* Economic announcements
* Earnings events
* Stop-loss placement
* Position sizing
* Risk-to-reward
* Whether price is overextended

The condition of an open candle may also change before that candle closes. For example, the 30-minute or one-hour reading may change during the formation of the current 30-minute or one-hour bar.

For this reason, traders who require confirmed signals should consider whether the relevant timeframe candle has closed before acting on a change in status.

The indicator should be used as a market-context and trade-filtering tool alongside an independent trading strategy and appropriate risk management.

## Summary

The Multi-Timeframe Alignment Alert — Strength Version provides a consolidated view of trend direction and moving-average strength across eight customizable timeframes.

Its main value is helping traders understand whether short-term price movement is supported by the intermediate and higher timeframe structure.

The addition of the 30-minute timeframe improves the transition between the 15-minute and one-hour charts, helping traders evaluate whether an intraday move is gaining structural importance or remains limited to the shortest timeframes.

Rather than treating every bullish or bearish move equally, the indicator distinguishes between weak conditions, strong conditions, full alignment, and mixed markets.

Its best use is as a directional-bias dashboard, pre-trade checklist, countertrend warning, and multi-timeframe market-context tool.

## Source Code

````pine
//@version=6
indicator(
     "Multi-Timeframe Alignment Alert - Strength Version v6",
     shorttitle = "MTF Alignment Strength v6",
     overlay = true,
     max_labels_count = 500,
     dynamic_requests = true)

//====================================================
// INPUTS
//====================================================
string groupTrend = "Trend Settings"

int maLength = input.int(
     21,
     "Moving Average Length",
     minval = 1,
     group = groupTrend)

bool useEMA = input.bool(
     true,
     "Use EMA (unchecked = SMA)",
     group = groupTrend)

//====================================================
// ALERT SETTINGS
//====================================================
string groupAlerts = "Alerts"

bool alertStrongBullAlignment = input.bool(
     true,
     "Alert on Strong Bullish Alignment",
     group = groupAlerts)

bool alertStrongBearAlignment = input.bool(
     true,
     "Alert on Strong Bearish Alignment",
     group = groupAlerts)

bool alertBullBias = input.bool(
     false,
     "Alert on Bullish Bias",
     group = groupAlerts)

bool alertBearBias = input.bool(
     false,
     "Alert on Bearish Bias",
     group = groupAlerts)

//====================================================
// DISPLAY SETTINGS
//====================================================
string groupDisplay = "Display"

bool showStatusTable = input.bool(
     true,
     "Show Status Table",
     group = groupDisplay)

string tablePositionInput = input.string(
     "top_right",
     "Table Position",
     options = [
          "top_right",
          "top_left",
          "bottom_right",
          "bottom_left"
     ],
     group = groupDisplay)

string tableSizeInput = input.string(
     "Normal",
     "Dashboard Text Size",
     options = [
          "Tiny",
          "Small",
          "Normal",
          "Large",
          "Huge"
     ],
     group = groupDisplay)

bool showChartSignals = input.bool(
     true,
     "Show Bull/Bear Alignment Markers",
     group = groupDisplay)

bool showBackground = input.bool(
     true,
     "Show Background Color",
     group = groupDisplay)

//====================================================
// TIMEFRAME SETTINGS
//====================================================
string groupTimeframes = "Timeframes"

string tfWeekly = input.timeframe(
     "W",
     "Weekly TF",
     group = groupTimeframes)

string tfDaily = input.timeframe(
     "D",
     "Daily TF",
     group = groupTimeframes)

string tf4H = input.timeframe(
     "240",
     "4 Hour TF",
     group = groupTimeframes)

string tf1H = input.timeframe(
     "60",
     "1 Hour TF",
     group = groupTimeframes)

string tf30M = input.timeframe(
     "30",
     "30 Min TF",
     group = groupTimeframes)

string tf15M = input.timeframe(
     "15",
     "15 Min TF",
     group = groupTimeframes)

string tf5M = input.timeframe(
     "5",
     "5 Min TF",
     group = groupTimeframes)

string tf1M = input.timeframe(
     "1",
     "1 Min TF",
     group = groupTimeframes)

//====================================================
// TABLE POSITION AND TEXT SIZE
//====================================================
tablePos = switch tablePositionInput
    "top_left"     => position.top_left
    "bottom_right" => position.bottom_right
    "bottom_left"  => position.bottom_left
    => position.top_right

tableTextSize = switch tableSizeInput
    "Tiny"  => size.tiny
    "Small" => size.small
    "Large" => size.large
    "Huge"  => size.huge
    => size.normal

//====================================================
// MOVING AVERAGE FUNCTION
//====================================================
f_ma(_src, _len) =>
    useEMA ? ta.ema(_src, _len) : ta.sma(_src, _len)

//====================================================
// TIMEFRAME TREND STATE
//====================================================
//  2 = Strong Bull: price above MA and MA rising
//  1 = Weak Bull:   price above MA and MA not rising
// -1 = Weak Bear:   price below MA and MA not falling
// -2 = Strong Bear: price below MA and MA falling
//  0 = Neutral
//====================================================
f_tf_state(_tf) =>
    [tfClose, tfMA, tfMAprev] = request.security(
         syminfo.tickerid,
         _tf,
         [
              close,
              f_ma(close, maLength),
              f_ma(close, maLength)[1]
         ],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off)

    bool isAbove = tfClose > tfMA
    bool isBelow = tfClose < tfMA
    bool isRising = tfMA > tfMAprev
    bool isFalling = tfMA < tfMAprev

    isAbove and isRising ? 2 :
     isAbove and not isRising ? 1 :
     isBelow and isFalling ? -2 :
     isBelow and not isFalling ? -1 :
     0

//====================================================
// STATE DISPLAY FUNCTIONS
//====================================================
f_stateText(_state) =>
    _state == 2 ? "▲ STRONG BULL" :
     _state == 1 ? "▲ WEAK BULL" :
     _state == -1 ? "▼ WEAK BEAR" :
     _state == -2 ? "▼ STRONG BEAR" :
     "• NEUTRAL"

f_stateBg(_state) =>
    _state == 2 ? color.rgb(46, 125, 50) :
     _state == 1 ? color.rgb(102, 187, 106) :
     _state == -1 ? color.rgb(239, 83, 80) :
     _state == -2 ? color.rgb(183, 28, 28) :
     color.rgb(158, 158, 158)

f_isBull(_state) =>
    _state == 1 or _state == 2

f_isBear(_state) =>
    _state == -1 or _state == -2

f_isStrongBull(_state) =>
    _state == 2

f_isStrongBear(_state) =>
    _state == -2

//====================================================
// TIMEFRAME STATES
//====================================================
int weeklyState = f_tf_state(tfWeekly)
int dailyState = f_tf_state(tfDaily)
int h4State = f_tf_state(tf4H)
int h1State = f_tf_state(tf1H)
int m30State = f_tf_state(tf30M)
int m15State = f_tf_state(tf15M)
int m5State = f_tf_state(tf5M)
int m1State = f_tf_state(tf1M)

//====================================================
// ALIGNMENT LOGIC
//====================================================
bool allBull =
     f_isBull(weeklyState) and
     f_isBull(dailyState) and
     f_isBull(h4State) and
     f_isBull(h1State) and
     f_isBull(m30State) and
     f_isBull(m15State) and
     f_isBull(m5State) and
     f_isBull(m1State)

bool allBear =
     f_isBear(weeklyState) and
     f_isBear(dailyState) and
     f_isBear(h4State) and
     f_isBear(h1State) and
     f_isBear(m30State) and
     f_isBear(m15State) and
     f_isBear(m5State) and
     f_isBear(m1State)

bool allStrongBull =
     f_isStrongBull(weeklyState) and
     f_isStrongBull(dailyState) and
     f_isStrongBull(h4State) and
     f_isStrongBull(h1State) and
     f_isStrongBull(m30State) and
     f_isStrongBull(m15State) and
     f_isStrongBull(m5State) and
     f_isStrongBull(m1State)

bool allStrongBear =
     f_isStrongBear(weeklyState) and
     f_isStrongBear(dailyState) and
     f_isStrongBear(h4State) and
     f_isStrongBear(h1State) and
     f_isStrongBear(m30State) and
     f_isStrongBear(m15State) and
     f_isStrongBear(m5State) and
     f_isStrongBear(m1State)

//====================================================
// OPTIONAL ALIGNMENT COUNTS
//====================================================
int bullCount =
     (f_isBull(weeklyState) ? 1 : 0) +
     (f_isBull(dailyState) ? 1 : 0) +
     (f_isBull(h4State) ? 1 : 0) +
     (f_isBull(h1State) ? 1 : 0) +
     (f_isBull(m30State) ? 1 : 0) +
     (f_isBull(m15State) ? 1 : 0) +
     (f_isBull(m5State) ? 1 : 0) +
     (f_isBull(m1State) ? 1 : 0)

int bearCount =
     (f_isBear(weeklyState) ? 1 : 0) +
     (f_isBear(dailyState) ? 1 : 0) +
     (f_isBear(h4State) ? 1 : 0) +
     (f_isBear(h1State) ? 1 : 0) +
     (f_isBear(m30State) ? 1 : 0) +
     (f_isBear(m15State) ? 1 : 0) +
     (f_isBear(m5State) ? 1 : 0) +
     (f_isBear(m1State) ? 1 : 0)

int strongBullCount =
     (f_isStrongBull(weeklyState) ? 1 : 0) +
     (f_isStrongBull(dailyState) ? 1 : 0) +
     (f_isStrongBull(h4State) ? 1 : 0) +
     (f_isStrongBull(h1State) ? 1 : 0) +
     (f_isStrongBull(m30State) ? 1 : 0) +
     (f_isStrongBull(m15State) ? 1 : 0) +
     (f_isStrongBull(m5State) ? 1 : 0) +
     (f_isStrongBull(m1State) ? 1 : 0)

int strongBearCount =
     (f_isStrongBear(weeklyState) ? 1 : 0) +
     (f_isStrongBear(dailyState) ? 1 : 0) +
     (f_isStrongBear(h4State) ? 1 : 0) +
     (f_isStrongBear(h1State) ? 1 : 0) +
     (f_isStrongBear(m30State) ? 1 : 0) +
     (f_isStrongBear(m15State) ? 1 : 0) +
     (f_isStrongBear(m5State) ? 1 : 0) +
     (f_isStrongBear(m1State) ? 1 : 0)

//====================================================
// OVERALL STATUS
//====================================================
string statusText =
     allStrongBull ? "✓ STRONG BULLISH ALIGNED" :
     allBull ? "✓ BULLISH BIAS" :
     allStrongBear ? "✓ STRONG BEARISH ALIGNED" :
     allBear ? "✓ BEARISH BIAS" :
     "• MIXED"

color statusBg =
     allStrongBull ? color.rgb(27, 94, 32) :
     allBull ? color.rgb(76, 175, 80) :
     allStrongBear ? color.rgb(127, 0, 0) :
     allBear ? color.rgb(198, 40, 40) :
     color.rgb(158, 120, 51)

//====================================================
// TABLE COLORS
//====================================================
color headerBg = color.rgb(70, 70, 70)
color leftColBg = color.rgb(55, 55, 55)
color textColor = color.white

//====================================================
// STATUS TABLE
// Header + 8 timeframes + overall status = 10 rows
//====================================================
var table statusTable = table.new(
     tablePos,
     2,
     10,
     border_width = 1)

if barstate.islast
    if showStatusTable
        table.cell(
             statusTable,
             0,
             0,
             "Timeframe",
             text_color = textColor,
             bgcolor = headerBg,
             text_size = tableTextSize)

        table.cell(
             statusTable,
             1,
             0,
             "Trend",
             text_color = textColor,
             bgcolor = headerBg,
             text_size = tableTextSize)

        table.cell(
             statusTable,
             0,
             1,
             "Weekly",
             text_color = textColor,
             bgcolor = leftColBg,
             text_size = tableTextSize)

        table.cell(
             statusTable,
             1,
             1,
             f_stateText(weeklyState),
             text_color = textColor,
             bgcolor = f_stateBg(weeklyState),
             text_size = tableTextSize)

        table.cell(
             statusTable,
             0,
             2,
             "Daily",
             text_color = textColor,
             bgcolor = leftColBg,
             text_size = tableTextSize)

        table.cell(
             statusTable,
             1,
             2,
             f_stateText(dailyState),
             text_color = textColor,
             bgcolor = f_stateBg(dailyState),
             text_size = tableTextSize)

        table.cell(
             statusTable,
             0,
             3,
             "4 Hour",
             text_color = textColor,
             bgcolor = leftColBg,
             text_size = tableTextSize)

        table.cell(
             statusTable,
             1,
             3,
             f_stateText(h4State),
             text_color = textColor,
             bgcolor = f_stateBg(h4State),
             text_size = tableTextSize)

        table.cell(
             statusTable,
             0,
             4,
             "1 Hour",
             text_color = textColor,
             bgcolor = leftColBg,
             text_size = tableTextSize)

        table.cell(
             statusTable,
             1,
             4,
             f_stateText(h1State),
             text_color = textColor,
             bgcolor = f_stateBg(h1State),
             text_size = tableTextSize)

        table.cell(
             statusTable,
             0,
             5,
             "30 Min",
             text_color = textColor,
             bgcolor = leftColBg,
             text_size = tableTextSize)

        table.cell(
             statusTable,
             1,
             5,
             f_stateText(m30State),
             text_color = textColor,
             bgcolor = f_stateBg(m30State),
             text_size = tableTextSize)

        table.cell(
             statusTable,
             0,
             6,
             "15 Min",
             text_color = textColor,
             bgcolor = leftColBg,
             text_size = tableTextSize)

        table.cell(
             statusTable,
             1,
             6,
             f_stateText(m15State),
             text_color = textColor,
             bgcolor = f_stateBg(m15State),
             text_size = tableTextSize)

        table.cell(
             statusTable,
             0,
             7,
             "5 Min",
             text_color = textColor,
             bgcolor = leftColBg,
             text_size = tableTextSize)

        table.cell(
             statusTable,
             1,
             7,
             f_stateText(m5State),
             text_color = textColor,
             bgcolor = f_stateBg(m5State),
             text_size = tableTextSize)

        table.cell(
             statusTable,
             0,
             8,
             "1 Min",
             text_color = textColor,
             bgcolor = leftColBg,
             text_size = tableTextSize)

        table.cell(
             statusTable,
             1,
             8,
             f_stateText(m1State),
             text_color = textColor,
             bgcolor = f_stateBg(m1State),
             text_size = tableTextSize)

        table.cell(
             statusTable,
             0,
             9,
             "Status",
             text_color = textColor,
             bgcolor = leftColBg,
             text_size = tableTextSize)

        table.cell(
             statusTable,
             1,
             9,
             statusText,
             text_color = textColor,
             bgcolor = statusBg,
             text_size = tableTextSize)

    else
        table.clear(
             statusTable,
             0,
             0,
             1,
             9)

//====================================================
// CHART MARKERS
//====================================================
plotshape(
     showChartSignals and allStrongBull,
     title = "Strong Bullish Alignment",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.green,
     size = size.small,
     text = "STR BULL")

plotshape(
     showChartSignals and allStrongBear,
     title = "Strong Bearish Alignment",
     style = shape.triangledown,
     location = location.abovebar,
     color = color.red,
     size = size.small,
     text = "STR BEAR")

plotshape(
     showChartSignals and not allStrongBull and allBull,
     title = "Bullish Bias",
     style = shape.circle,
     location = location.belowbar,
     color = color.green,
     size = size.tiny,
     text = "BULL")

plotshape(
     showChartSignals and not allStrongBear and allBear,
     title = "Bearish Bias",
     style = shape.circle,
     location = location.abovebar,
     color = color.red,
     size = size.tiny,
     text = "BEAR")

//====================================================
// BACKGROUND COLOR
//====================================================
color backgroundColor =
     allStrongBull ? color.new(color.green, 88) :
     allStrongBear ? color.new(color.red, 88) :
     allBull ? color.new(color.green, 93) :
     allBear ? color.new(color.red, 93) :
     na

bgcolor(showBackground ? backgroundColor : na)

//====================================================
// NEW ALIGNMENT SIGNALS
//====================================================
bool strongBullSignal =
     allStrongBull and
     not allStrongBull[1]

bool strongBearSignal =
     allStrongBear and
     not allStrongBear[1]

bool bullBiasSignal =
     allBull and
     not allStrongBull and
     not allBull[1]

bool bearBiasSignal =
     allBear and
     not allStrongBear and
     not allBear[1]

//====================================================
// ALERT CONDITIONS
//====================================================
alertcondition(
     alertStrongBullAlignment and strongBullSignal,
     title = "Strong Bullish Alignment",
     message = "All eight timeframes are STRONG BULL: Weekly, Daily, 4 Hour, 1 Hour, 30 Min, 15 Min, 5 Min, and 1 Min.")

alertcondition(
     alertStrongBearAlignment and strongBearSignal,
     title = "Strong Bearish Alignment",
     message = "All eight timeframes are STRONG BEAR: Weekly, Daily, 4 Hour, 1 Hour, 30 Min, 15 Min, 5 Min, and 1 Min.")

alertcondition(
     alertBullBias and bullBiasSignal,
     title = "Bullish Bias",
     message = "All eight timeframes are bullish, but at least one is not strongly bullish: Weekly, Daily, 4 Hour, 1 Hour, 30 Min, 15 Min, 5 Min, and 1 Min.")

alertcondition(
     alertBearBias and bearBiasSignal,
     title = "Bearish Bias",
     message = "All eight timeframes are bearish, but at least one is not strongly bearish: Weekly, Daily, 4 Hour, 1 Hour, 30 Min, 15 Min, 5 Min, and 1 Min.")
````
