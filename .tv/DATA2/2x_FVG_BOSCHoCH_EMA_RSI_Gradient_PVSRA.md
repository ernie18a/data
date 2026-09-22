<!-- tradingview-pine-id: PUB;f07335bca4ef45ddbf54bba1e56c7738 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 2x FVG + BOS/CHoCH + EMA + RSI Gradient + PVSRA

Source: https://www.tradingview.com/script/i9466shI/

## Description

OVERVIEW

2x FVG Structure and PVSRA Footprint Toolkit is an intraday market-analysis indicator designed to combine several different layers of market information into one structured workflow:

1. Trend and directional context using EMA 50 and EMA 200
2. Market structure using BOS and CHoCH
3. Price imbalance using Fair Value Gaps
4. Detection of two distinct same-direction FVG structures
5. Volume-based PVSRA / Vector Candle classification
6. Volume Footprint Buy/Sell dominance
7. Optional RSI-based candle coloring
8. Alerts for selected structural, EMA, FVG and PVSRA events

The purpose of combining these modules is not to produce a standalone automatic buy or sell signal.

Instead, the indicator is intended to help traders evaluate several independent pieces of market information on the same chart and determine whether price structure, imbalance, volume activity and directional participation are supporting the same market scenario.

The indicator does not place trades, calculate position size, define risk, or guarantee future price direction.

WHY THESE MODULES ARE COMBINED

This indicator is not intended to be a collection of unrelated indicators.

Each module has a specific role in the analysis process.

EMA 50 and EMA 200 provide broader directional context.

BOS and CHoCH identify changes or continuation in confirmed market structure.

Fair Value Gaps identify three-candle price inefficiencies.

The 2x FVG module identifies situations where two separate same-direction imbalance structures occur within a configurable number of bars.

PVSRA highlights candles with abnormal volume or volume-spread activity.

Volume Footprint statistics provide additional information about the distribution of classified Buy and Sell volume inside selected candles.

The intended workflow is therefore:

CONTEXT
→ STRUCTURE
→ IMBALANCE
→ VOLUME
→ FOOTPRINT CONFIRMATION

A trader can use each layer independently, but the main purpose of the indicator is to provide contextual confirmation between different types of market information.

EMA 50 AND EMA 200

The indicator calculates two Exponential Moving Averages:

Fast EMA:
Default length = 50

Slow EMA:
Default length = 200

Both lengths, colors and line widths can be changed in the settings.

The EMA module provides a simple representation of medium-term and longer-term price direction.

A bullish EMA cross occurs when the Fast EMA crosses above the Slow EMA.

A bearish EMA cross occurs when the Fast EMA crosses below the Slow EMA.

The script can display small visual markers when these crosses occur and can generate corresponding alert conditions.

The EMA module should be treated as market context rather than as an independent entry system.

For example, a trader may choose to give more weight to bullish structural setups while the Fast EMA is above the Slow EMA and more weight to bearish setups while the opposite condition exists.

This is only one possible interpretation and is not enforced by the indicator.

MARKET STRUCTURE: SWING HIGH AND SWING LOW

Market structure is calculated using confirmed pivot highs and pivot lows.

The Swing Length setting determines how many bars are required on each side of a potential swing.

With the default Swing Length of 5, a pivot requires five bars to the left and five bars to the right before it can be confirmed.

This has an important consequence:

A swing point cannot be known at the moment the original high or low occurs.

It becomes confirmed only after the required number of right-side bars exists.

Therefore, historical swing locations must not be interpreted as signals that were available at the original swing bar.

The indicator uses these confirmed swings as reference levels for BOS and CHoCH detection.

BOS — BREAK OF STRUCTURE

A Break of Structure identifies a break of a previously confirmed swing level in the current structural direction.

Depending on the Structure Break Confirmation setting, a break can be confirmed using:

Close
or
Wick

When Close is selected, price must close beyond the swing level.

When Wick is selected, the high or low of the candle can confirm the break.

A bullish BOS represents a confirmed break above a relevant swing high while the internal structural direction is already bullish or has not previously established a bearish reversal condition.

A bearish BOS represents the corresponding break below a relevant swing low.

BOS should generally be interpreted as a structural continuation event rather than an automatic trade signal.

CHOCH — CHANGE OF CHARACTER

CHoCH is used to identify a possible change in structural direction.

A bullish CHoCH occurs when price breaks a confirmed swing high while the previously tracked structure was bearish.

A bearish CHoCH occurs when price breaks a confirmed swing low while the previously tracked structure was bullish.

This can help identify potential transitions between bearish and bullish structure.

A CHoCH does not guarantee a reversal.

Markets frequently produce temporary structural breaks before continuing in the previous direction.

For this reason, CHoCH is intended to be evaluated together with other information such as FVGs, EMA context, PVSRA activity and Footprint dominance.

IMPORTANT STRUCTURE DISPLAY BEHAVIOR

When a BOS or CHoCH occurs, the horizontal structure line begins at the historical swing that was broken and ends at the bar that confirmed the break.

The visual line therefore extends backward to the location of the swing.

This does NOT mean the BOS or CHoCH signal was known at the swing bar.

The actual structural event is confirmed only when the later candle breaks the swing according to the selected Close or Wick confirmation method.

This distinction is important when visually reviewing historical charts.

FAIR VALUE GAP — FVG

The indicator detects traditional three-candle Fair Value Gaps.

A Bullish FVG is detected when:

Current Low > High from two bars earlier

A Bearish FVG is detected when:

Current High < Low from two bars earlier

This represents a price range that was not overlapped by the first and third candles of the three-candle sequence.

The FVG is created only on a confirmed bar.

Users can optionally apply a minimum FVG size filter.

The minimum size can be expressed in:

Points
or
Ticks

This can be useful for reducing very small imbalances that may have limited analytical value on a particular instrument.

The appropriate minimum FVG size depends on the instrument, volatility and timeframe.

There is no universal value that works for every market.

FVG VISIBILITY

The indicator allows users to display:

All available FVGs

or

Only FVGs from the most recent configured number of hours.

The default historical window is 24 hours.

A maximum number of FVG objects is also enforced to protect chart performance and TradingView object limits.

IMPORTANT:

The current implementation does not automatically remove an FVG simply because price later trades through or mitigates the zone.

The displayed FVG therefore represents the historical detection of the imbalance, not necessarily an active or unmitigated trading zone.

2x FVG LOGIC

The 2x FVG module is more selective than simply counting any two Fair Value Gaps.

The script tracks FVGs of the same direction occurring within the configurable Max Bars Between FVG setting.

The default value is 5 bars.

If a new same-direction FVG overlaps the currently tracked FVG cluster, the indicator treats the gaps as part of the same broader imbalance structure.

The cluster boundaries are expanded when necessary.

A 2x FVG event is generated when another same-direction FVG appears within the allowed bar window but forms a separate, non-overlapping imbalance rather than simply extending the existing cluster.

Therefore:

Two overlapping bullish FVGs are not necessarily treated as a completed 2x Bullish FVG signal.

Two distinct bullish FVG structures occurring close together can generate the bullish 2x marker.

The same logic applies in the bearish direction.

When an opposite-direction FVG occurs, the previous same-direction cluster is reset.

This design attempts to distinguish between one extended imbalance and two separate displacement events.

HOW TO INTERPRET 2x FVG

A 2x FVG should not automatically be interpreted as an entry.

It indicates that price has created multiple distinct inefficiencies in the same direction over a relatively short sequence of candles.

For example:

Bullish market structure
+
price above the broader EMA context
+
bullish BOS
+
two separate bullish FVGs
+
strong bullish PVSRA activity

provides more contextual information than a single FVG alone.

However, the indicator does not assign a statistical probability of success to such a configuration.

Users should test the behavior on the specific instrument and timeframe they trade.

PVSRA / VECTOR CANDLES

The PVSRA module classifies candles according to volume and candle spread.

The default volume lookback period is 10 bars.

The script calculates the average volume over this lookback period.

The default Above Average threshold is:

150% of average volume

The default Climax threshold is:

200% of average volume

A candle can also qualify as a Climax candle through the Volume x Spread calculation.

Volume x Spread is calculated as:

Volume × (High - Low)

The script compares this value with the highest Volume x Spread value over the configured PVSRA lookback.

This allows unusually large volume combined with a wide candle range to be identified even when the simple volume threshold alone may not fully describe the event.

PVSRA CANDLE COLORS

By default, the PVSRA candle categories are displayed as:

Green:
Bullish 200% / Climax candle

Red:
Bearish 200% / Climax candle

Blue:
Bullish 150% Above Average candle

Purple:
Bearish 150% Above Average candle

Light Gray:
Regular bullish candle

Dark Gray:
Regular bearish candle

All colors can be modified by the user.

The bullish or bearish classification of the candle itself is determined by comparing its Open and Close.

A bullish candle has:

Close > Open

A bearish candle has:

Close <= Open

PVSRA SOURCE SYMBOL

By default, PVSRA calculations use the current chart symbol.

An optional Override PVSRA Source Symbol setting is available.

This allows the volume calculations to use another symbol or data feed.

This feature should be used carefully.

If the PVSRA source symbol is different from the chart symbol, the volume information no longer represents exactly the same instrument displayed on the chart.

The user is responsible for selecting a logically appropriate source.

WHAT A PVSRA CLIMAX MEANS

A Climax candle indicates unusually high activity relative to recent bars.

It does NOT automatically indicate reversal.

For example, a bullish Climax candle can represent:

Strong continuation buying

Aggressive participation during a breakout

Buying absorption

Late participation near the end of a move

or increased activity around an important level.

Context is therefore essential.

A high-volume candle is evidence of increased activity, not proof of the next market direction.

VOLUME FOOTPRINT BUY/SELL DOMINANCE

The Footprint module uses TradingView's volume footprint data.

For selected candles, the script retrieves:

Total Volume

Buy Volume

Sell Volume

Volume Delta

The script then calculates:

Buy % = Buy Volume / Total Volume × 100

Sell % = Sell Volume / Total Volume × 100

Delta % = Volume Delta / Total Volume × 100

where:

Volume Delta = Buy Volume - Sell Volume

IMPORTANT INFORMATION ABOUT BUY AND SELL VOLUME

The words BUY and SELL in the Footprint module refer to TradingView's volume footprint classification.

TradingView classifies lower-timeframe volume according to the direction of intrabar price movement.

This should not be interpreted as direct access to every participant's intentions, resting limit orders, or the complete exchange order book.

The indicator does NOT display DOM resting liquidity.

It does NOT show pending limit orders.

It does NOT identify how many individual traders are buying or selling.

It displays TradingView's calculated Buy and Sell footprint volume categories.

This distinction is important when interpreting the values.

FOOTPRINT DOMINANCE

The indicator compares Buy % and Sell %.

If the difference between the two sides is smaller than or equal to the Neutral Threshold, the candle is classified as NEUTRAL.

The default Neutral Threshold is 5 percentage points.

For example:

BUY = 52%
SELL = 48%

Difference = 4 percentage points

With a 5% Neutral Threshold, this candle is considered neutral.

Another example:

BUY = 67%
SELL = 33%

Difference = 34 percentage points

This candle is classified as BUY dominance.

The same logic applies to SELL dominance.

FOOTPRINT BUBBLES

Footprint information is displayed using bubbles near selected candles.

BUY dominance is displayed below the candle.

SELL dominance is displayed above the candle.

Neutral conditions are also displayed above the candle.

The bubble can contain:

BUY or SELL classification

Buy or Sell percentage

Volume Delta percentage

A detailed tooltip can additionally display:

Buy Volume

Sell Volume

Total Volume

Buy %

Sell %

Absolute Delta

Delta %

Dominance classification

Difference between Buy and Sell percentages

DYNAMIC BUBBLE SIZE

When Dynamic Bubble Size is enabled, stronger Buy/Sell differences can produce larger bubbles.

The bubble size is therefore a visual representation of the magnitude of the Buy/Sell dominance difference.

It should not be interpreted as a prediction of future price movement.

The script also uses a simple anti-collision system that assigns nearby bubbles to different visual lanes to reduce overlap.

FOOTPRINT VISIBILITY FILTER

Users can choose which candles receive Footprint bubbles.

Available modes are:

200% Climax only

150% + 200%

All candles

The default mode is 200% Climax only.

This is intentional.

Displaying Footprint statistics only around unusually active PVSRA candles can reduce visual noise and focuses the Footprint module on bars where volume participation is already elevated.

FOOTPRINT HISTORY

The indicator includes an option to limit Footprint bubble history to approximately the most recent hour.

This reduces chart clutter and helps manage the amount of footprint data used by the script.

The current implementation also restricts footprint calculations to a limited number of recent bars for memory efficiency.

As a result, the Footprint component is primarily intended as a recent intraday analysis tool rather than a long-term historical footprint database.

The availability and precision of Footprint data can also depend on the symbol, timeframe, available market data and TradingView account/data access.

FOOTPRINT ROW SIZE

Ticks Per Footprint Row controls the aggregation size used in the footprint request.

However, this indicator currently uses the overall Buy Volume, Sell Volume, Total Volume and Delta of each requested footprint.

It does not display every individual footprint price row.

It therefore should not be confused with a complete Footprint chart showing bid/ask-style information at every individual price level.

RSI CANDLE GRADIENT

The indicator also includes an optional RSI candle-coloring mode.

The default RSI length is 14.

The gradient transitions through several ranges:

Very low RSI
→ green

Lower RSI
→ green/yellow

Mid-range RSI
→ yellow/orange

Higher RSI
→ red

Extreme high RSI
→ dark red

The default Oversold and Overbought reference values are 30 and 70.

This module is designed primarily as an alternative momentum visualization.

IMPORTANT:

PVSRA candle coloring has priority over RSI candle coloring.

If PVSRA and RSI Gradient are both enabled, PVSRA colors are displayed.

To view the RSI candle gradient directly, disable PVSRA candle coloring.

ALERTS

The indicator provides alert conditions for:

2x Bullish FVG

2x Bearish FVG

Any 2x FVG

Bullish BOS

Bearish BOS

Any BOS

Bullish CHoCH

Bearish CHoCH

Any CHoCH

Any Structure Break

Bullish EMA Cross

Bearish EMA Cross

Any EMA Cross

Bullish PVSRA Climax candle

Bearish PVSRA Climax candle

Any PVSRA Climax candle

Master "Any Signal" condition

The script also includes a repeating alert engine using alert() calls.

Signals are evaluated using confirmed bars.

This means alerts are intended to trigger after the relevant candle has closed rather than continuously changing during the still-forming candle.

The current Footprint bubble itself is not included as a separate alert condition.

PRACTICAL WORKFLOW

One possible way to use the indicator is to begin with directional context.

First evaluate the position and relationship of EMA 50 and EMA 200.

Then evaluate the most recent confirmed BOS or CHoCH.

Next examine whether the displacement created one or more Fair Value Gaps.

A 2x FVG can indicate that multiple separate price inefficiencies have formed in the same direction.

PVSRA can then be used to determine whether the move occurred with unusually high volume or Volume x Spread activity.

Finally, the Footprint bubble can provide additional information about TradingView-classified Buy/Sell volume dominance inside the selected high-activity candle.

This creates a multi-layer confirmation process rather than relying on one isolated indicator.

EXAMPLE OF BULLISH CONFLUENCE

A trader may observe:

EMA context favoring the upside

Bullish BOS or bullish CHoCH

Bullish FVG structure

Bullish 2x FVG

Bullish PVSRA Climax candle

BUY-dominant Footprint statistics

This combination may justify further investigation of a bullish scenario.

It does NOT mean a long trade must be taken.

The same concept can be mirrored for bearish conditions.

DIVERGENCE BETWEEN PRICE AND FOOTPRINT

The Footprint module may also be useful when its information disagrees with the candle direction.

For example, price may close bullish while the Footprint statistics show stronger Sell classification.

Likewise, a bearish candle may contain strong classified Buy volume.

Such situations can indicate more complex interaction between price movement and volume participation.

They can be worth observing around:

previous highs or lows

liquidity areas

major support or resistance

BOS or CHoCH levels

FVG boundaries

session extremes

However, these relationships are contextual observations and are not automatically classified by this version of the indicator as absorption or reversal signals.

TIMEFRAMES AND MARKETS

The indicator is primarily designed for intraday use.

It can technically operate on multiple standard chart timeframes, but the meaning of each component changes with timeframe and market structure.

Short timeframes generate more structural events and more FVGs, but also more noise.

Higher timeframes produce fewer signals and generally larger structural zones.

Users should adjust:

Swing Length

Minimum FVG Size

Maximum Bars Between FVGs

PVSRA thresholds

Footprint settings

according to the volatility and tick size of the instrument being analyzed.

The default settings should be treated as starting values rather than universally optimized parameters.

Volume-dependent modules are most meaningful on markets where reliable volume data is available.

STANDARD CANDLESTICK CHARTS RECOMMENDED

The indicator is designed for use with standard time-based candlestick charts.

Using synthetic chart types such as:

Heikin Ashi

Renko

Kagi

Point & Figure

Range

or Line Break

can change the relationship between displayed OHLC values and actual market prices.

For structural or signal-based analysis, standard candlestick charts are recommended.

REPAINTING, CONFIRMATION AND HISTORICAL DISPLAY

The script intentionally uses confirmed candles for FVG, structure, EMA-cross and PVSRA signal events.

The PVSRA security request uses lookahead disabled.

However, users should understand the behavior of confirmed pivots.

A pivot high or pivot low requires future right-side bars before it becomes confirmed.

The structure line is then drawn starting from the historical pivot.

Therefore, the historical location of a swing does not mean the swing was known in real time at that original candle.

Likewise, a BOS/CHoCH line visually beginning at a previous swing does not mean the structure break occurred there.

The actual BOS or CHoCH event occurs only on the later bar that confirms the break.

This is normal pivot-based structure behavior and should be considered when reviewing historical charts.

LIMITATIONS

This indicator does not predict future market direction.

It does not provide guaranteed entries or exits.

It does not calculate Stop Loss or Take Profit levels.

It does not calculate risk or position size.

It does not execute trades.

FVG zones are not automatically removed after mitigation.

BOS and CHoCH depend on confirmed swing pivots and therefore include structural confirmation delay.

PVSRA identifies unusual volume activity but cannot determine the intention of market participants.

Footprint BUY and SELL statistics are based on TradingView's footprint volume classification and should not be confused with direct DOM order-book liquidity.

The Footprint module currently uses bar-level total Buy/Sell statistics rather than displaying the complete footprint ladder at every price level.

The availability and granularity of Footprint data depend on TradingView's available lower-timeframe data and market-data access.

Historical results should not be interpreted as evidence of future performance.

INTENDED USE

This indicator is intended as a discretionary market-analysis toolkit.

It is most useful when the trader evaluates the relationship between:

market direction

confirmed structure

price imbalance

volume expansion

and Buy/Sell volume distribution

rather than interpreting any single visual element as an automatic trading signal.

Users are encouraged to test the indicator on historical and real-time data, understand each component independently, and build their own risk-management rules before using the information in live trading.

---

## Source Code

````pine
//@version=6
indicator("2x FVG + BOS/CHoCH + EMA + RSI Gradient + PVSRA", shorttitle="FVG Structure EMA RSI PVSRA", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, calc_bars_count=6000)

const string GROUP_FVG   = "FVG SETTINGS"
const string GROUP_MS    = "MARKET STRUCTURE SETTINGS"
const string GROUP_EMA   = "EMA SETTINGS"
const string GROUP_RSI   = "RSI CANDLE GRADIENT"
const string GROUP_PVSR  = "PVSRA / VECTOR CANDLES"
const string GROUP_FOOTPRINT = "PVSRA FOOTPRINT / BUY-SELL DOMINANCE"
const string GROUP_ALERT = "ALERT SETTINGS"
const string GROUP_DEBUG = "DEBUG"

bool enableFvg = input.bool(true, "Enable FVG", group=GROUP_FVG)
bool showFvg = input.bool(true, "Show FVG", group=GROUP_FVG)

string fvgVisibility = input.string(
     "Last N hours",
     "FVG + 2x FVG Visibility",
     options=["Last N hours", "All"],
     group=GROUP_FVG)

int recentFvgHours = input.int(
     24,
     "Recent FVG + 2x FVG hours",
     minval=1,
     maxval=168,
     group=GROUP_FVG)

int maxBarsBetweenFvg = input.int(
     5,
     "Max bars between FVG",
     minval=1,
     maxval=50,
     group=GROUP_FVG)

bool useMinFvgFilter = input.bool(
     false,
     "Minimum FVG size filter",
     group=GROUP_FVG)

float minFvgSize = input.float(
     0.0,
     "Minimum FVG size",
     minval=0.0,
     step=0.25,
     group=GROUP_FVG)

string minFvgUnit = input.string(
     "Points",
     "Minimum FVG unit",
     options=["Points", "Ticks"],
     group=GROUP_FVG)

int maximumFvgZones = input.int(
     350,
     "Maximum FVG zones",
     minval=1,
     maxval=450,
     group=GROUP_FVG)

color bullishFvgColor = input.color(
     color.rgb(65, 225, 165),
     "Bullish FVG color",
     group=GROUP_FVG)

color bearishFvgColor = input.color(
     color.rgb(255, 90, 105),
     "Bearish FVG color",
     group=GROUP_FVG)

int fvgTransparency = input.int(
     68,
     "FVG transparency",
     minval=0,
     maxval=100,
     group=GROUP_FVG)

bool showTwoFvgMarkers = input.bool(
     true,
     "Show subtle 2x FVG markers",
     group=GROUP_FVG)

bool enableBos = input.bool(
     true,
     "Enable BOS",
     group=GROUP_MS)

bool enableChoch = input.bool(
     true,
     "Enable CHoCH",
     group=GROUP_MS)

int swingLength = input.int(
     5,
     "Swing Length",
     minval=1,
     maxval=50,
     group=GROUP_MS)

string breakConfirmation = input.string(
     "Close",
     "Structure Break Confirmation",
     options=["Close", "Wick"],
     group=GROUP_MS)

string structureVisibility = input.string(
     "Last N hours",
     "BOS / CHoCH Visibility",
     options=["Last N hours", "All"],
     group=GROUP_MS)

int recentStructureHours = input.int(
     24,
     "Recent BOS / CHoCH hours",
     minval=1,
     maxval=168,
     group=GROUP_MS)

int maximumStructureObjects = input.int(
     350,
     "Maximum BOS / CHoCH objects",
     minval=20,
     maxval=450,
     group=GROUP_MS)

bool showSwingHighLow = input.bool(
     false,
     "Show Swing High/Low",
     group=GROUP_MS)

bool showStructureLines = input.bool(
     true,
     "Show Structure Lines",
     group=GROUP_MS)

bool showBosLabels = input.bool(
     true,
     "Show BOS Labels",
     group=GROUP_MS)

bool showChochLabels = input.bool(
     true,
     "Show CHoCH Labels",
     group=GROUP_MS)

color bullishStructureColor = input.color(
     color.rgb(0, 195, 105),
     "Bullish BOS / CHoCH",
     group=GROUP_MS)

color bearishStructureColor = input.color(
     color.rgb(245, 40, 55),
     "Bearish BOS / CHoCH",
     group=GROUP_MS)

bool enableEma = input.bool(
     true,
     "Enable EMA",
     group=GROUP_EMA)

int fastEmaLength = input.int(
     50,
     "Fast EMA Length",
     minval=1,
     group=GROUP_EMA)

int slowEmaLength = input.int(
     200,
     "Slow EMA Length",
     minval=2,
     group=GROUP_EMA)

bool showEma = input.bool(
     true,
     "Show EMA",
     group=GROUP_EMA)

int emaLineWidth = input.int(
     2,
     "EMA Line Width",
     minval=1,
     maxval=5,
     group=GROUP_EMA)

color fastEmaColor = input.color(
     color.rgb(255, 125, 0),
     "Fast EMA Color",
     group=GROUP_EMA)

color slowEmaColor = input.color(
     color.rgb(70, 85, 255),
     "Slow EMA Color",
     group=GROUP_EMA)

bool enableRsiGradient = input.bool(
     true,
     "Enable RSI Candle Gradient",
     group=GROUP_RSI)

int rsiLength = input.int(
     14,
     "RSI Length",
     minval=2,
     maxval=100,
     group=GROUP_RSI)

float rsiOversold = input.float(
     30.0,
     "Oversold Level",
     minval=1,
     maxval=49,
     step=1,
     group=GROUP_RSI)

float rsiOverbought = input.float(
     70.0,
     "Overbought Level",
     minval=51,
     maxval=99,
     step=1,
     group=GROUP_RSI)

color rsiExtremeLowColor = input.color(
     color.rgb(0, 255, 90),
     "Extreme Low RSI",
     group=GROUP_RSI)

color rsiLowColor = input.color(
     color.rgb(0, 200, 95),
     "Low RSI",
     group=GROUP_RSI)

color rsiNeutralLowColor = input.color(
     color.rgb(170, 215, 35),
     "RSI 40-50",
     group=GROUP_RSI)

color rsiNeutralColor = input.color(
     color.rgb(255, 195, 0),
     "Neutral RSI 50",
     group=GROUP_RSI)

color rsiNeutralHighColor = input.color(
     color.rgb(255, 115, 0),
     "RSI 50-60",
     group=GROUP_RSI)

color rsiHighColor = input.color(
     color.rgb(255, 45, 45),
     "High RSI",
     group=GROUP_RSI)

color rsiExtremeHighColor = input.color(
     color.rgb(125, 0, 25),
     "Extreme High RSI",
     group=GROUP_RSI)

int rsiCandleTransparency = input.int(
     0,
     "RSI Candle Transparency",
     minval=0,
     maxval=80,
     group=GROUP_RSI)

bool enablePvsr = input.bool(
     true,
     "Enable PVSRA",
     group=GROUP_PVSR)

int pvsrVolumeLength = input.int(
     10,
     "PVSRA Lookback",
     minval=2,
     maxval=100,
     tooltip="Leave at 10 to match the Trademania reference.",
     group=GROUP_PVSR)

float pvsrAboveAvgMultiplier = input.float(
     1.5,
     "150% Volume Threshold",
     minval=1.0,
     maxval=5.0,
     step=0.1,
     group=GROUP_PVSR)

float pvsrClimaxMultiplier = input.float(
     2.0,
     "200% Volume Threshold",
     minval=1.0,
     maxval=10.0,
     step=0.1,
     group=GROUP_PVSR)

bool pvsrUseVolumeSpreadClimax = input.bool(
     true,
     "Use Volume x Spread Climax",
     group=GROUP_PVSR)

bool pvsrOverrideSymbol = input.bool(
     false,
     "Override PVSRA Source Symbol",
     tooltip="Use this only if the reference indicator is using another volume feed. Both indicators must use the same feed to match candle-for-candle.",
     group=GROUP_PVSR)

string pvsrOverrideTicker = input.symbol(
     "CME_MINI:NQ1!",
     "PVSRA Override Symbol",
     group=GROUP_PVSR)

color pvsrBullClimaxColor = input.color(
     #69F0AE,
     "200% Bull / Green",
     group=GROUP_PVSR)

color pvsrBearClimaxColor = input.color(
     #FF5252,
     "200% Bear / Red",
     group=GROUP_PVSR)

color pvsrBullAboveAvgColor = input.color(
     #448AFF,
     "150% Bull / Blue",
     group=GROUP_PVSR)

color pvsrBearAboveAvgColor = input.color(
     #E040FB,
     "150% Bear / Purple",
     group=GROUP_PVSR)

color pvsrRegularBullColor = input.color(
     #999999,
     "Regular Bull / Light Gray",
     group=GROUP_PVSR)

color pvsrRegularBearColor = input.color(
     #4D4D4D,
     "Regular Bear / Dark Gray",
     group=GROUP_PVSR)

int pvsrCandleTransparency = input.int(
     0,
     "PVSRA Candle Transparency",
     minval=0,
     maxval=80,
     group=GROUP_PVSR)

bool enableFootprintBubbles = input.bool(
     true,
     "Enable Footprint Bubbles",
     group=GROUP_FOOTPRINT)

bool footprintLimitHistoryToOneHour = input.bool(
     true,
     "Limit Footprint History to Last 1H",
     group=GROUP_FOOTPRINT)

string footprintBubbleVisibility = input.string(
     "200% Climax only",
     "Bubble Visibility",
     options=["200% Climax only", "150% + 200%", "All candles"],
     group=GROUP_FOOTPRINT)

float footprintNeutralThreshold = input.float(
     5.0,
     "Neutral Threshold %",
     minval=0.0,
     maxval=100.0,
     step=0.5,
     group=GROUP_FOOTPRINT)

int footprintTicksPerRow = input.int(
     100,
     "Ticks Per Footprint Row (100 recommended)",
     minval=1,
     maxval=1000,
     group=GROUP_FOOTPRINT)

bool footprintDynamicBubbleSize = input.bool(
     true,
     "Dynamic Bubble Size",
     group=GROUP_FOOTPRINT)

string footprintBubbleSize = input.string(
     "Small",
     "Bubble Size (Dynamic OFF)",
     options=["Tiny", "Small", "Normal"],
     group=GROUP_FOOTPRINT)

bool footprintShowDeltaPct = input.bool(
     true,
     "Show Delta %",
     group=GROUP_FOOTPRINT)

bool footprintShowDetailedTooltip = input.bool(
     true,
     "Show Detailed Tooltip",
     group=GROUP_FOOTPRINT)

color footprintBuyBubbleColor = input.color(
     #00C853,
     "BUY Bubble Color",
     group=GROUP_FOOTPRINT)

color footprintSellBubbleColor = input.color(
     #FF3D57,
     "SELL Bubble Color",
     group=GROUP_FOOTPRINT)

color footprintNeutralBubbleColor = input.color(
     #7A7A7A,
     "Neutral Bubble Color",
     group=GROUP_FOOTPRINT)

int footprintBubbleTransparency = input.int(
     10,
     "Bubble Transparency",
     minval=0,
     maxval=90,
     group=GROUP_FOOTPRINT)

int maximumFootprintBubbles = input.int(
     250,
     "Maximum Footprint Bubbles",
     minval=1,
     maxval=450,
     group=GROUP_FOOTPRINT)

bool enableFvgAlerts = input.bool(true, "Enable FVG Alerts", group=GROUP_ALERT)
bool enableStructureAlerts = input.bool(true, "Enable Structure Alerts", group=GROUP_ALERT)
bool enableEmaAlerts = input.bool(true, "Enable EMA Alerts", group=GROUP_ALERT)
bool enablePvsrAlerts = input.bool(true, "Enable PVSRA Green/Red Alerts", group=GROUP_ALERT)
bool enableMasterAlert = input.bool(true, "Enable Master Alert", group=GROUP_ALERT)
bool enableRepeatingAlerts = input.bool(true, "Enable Repeating Alert Engine", group=GROUP_ALERT)
bool debugMode = input.bool(false, "Debug Mode", group=GROUP_DEBUG)

int fvgWindowMs = recentFvgHours * 60 * 60 * 1000
int structureWindowMs = recentStructureHours * 60 * 60 * 1000
int footprintHistoryWindowMs = 60 * 60 * 1000

int fvgCutoff = last_bar_time - fvgWindowMs
int structureCutoff = last_bar_time - structureWindowMs
int footprintHistoryCutoff = last_bar_time - footprintHistoryWindowMs

float rsiValue = ta.rsi(close, rsiLength)
color rsiCandleColor = na

if rsiValue <= rsiOversold
    rsiCandleColor := color.from_gradient(rsiValue, 0, rsiOversold, rsiExtremeLowColor, rsiLowColor)
else if rsiValue < 40
    rsiCandleColor := color.from_gradient(rsiValue, rsiOversold, 40, rsiLowColor, rsiNeutralLowColor)
else if rsiValue < 50
    rsiCandleColor := color.from_gradient(rsiValue, 40, 50, rsiNeutralLowColor, rsiNeutralColor)
else if rsiValue < 60
    rsiCandleColor := color.from_gradient(rsiValue, 50, 60, rsiNeutralColor, rsiNeutralHighColor)
else if rsiValue < rsiOverbought
    rsiCandleColor := color.from_gradient(rsiValue, 60, rsiOverbought, rsiNeutralHighColor, rsiHighColor)
else
    rsiCandleColor := color.from_gradient(rsiValue, rsiOverbought, 100, rsiHighColor, rsiExtremeHighColor)

color finalRsiCandleColor = color.new(rsiCandleColor, rsiCandleTransparency)

[pvsrVolume, pvsrHigh, pvsrLow, pvsrClose, pvsrOpen] =
     request.security(
         pvsrOverrideSymbol ? pvsrOverrideTicker : syminfo.tickerid,
         "",
         [volume, high, low, close, open],
         barmerge.gaps_off,
         barmerge.lookahead_off)

float pvsrAvgVolume = ta.sma(pvsrVolume, pvsrVolumeLength)
float pvsrSpread = pvsrHigh - pvsrLow
float pvsrVolumeSpread = pvsrVolume * pvsrSpread
float pvsrHighestVolumeSpread = ta.highest(pvsrVolumeSpread, pvsrVolumeLength)

bool pvsrBullCandle = pvsrClose > pvsrOpen

bool pvsrHasData =
     not na(pvsrVolume) and
     not na(pvsrAvgVolume) and
     not na(pvsrHigh) and
     not na(pvsrLow)

bool pvsrClimaxByVolume =
     pvsrHasData and
     pvsrVolume >= pvsrAvgVolume * pvsrClimaxMultiplier

bool pvsrClimaxBySpread =
     pvsrUseVolumeSpreadClimax and
     pvsrHasData and
     not na(pvsrHighestVolumeSpread) and
     pvsrVolumeSpread >= pvsrHighestVolumeSpread

bool pvsrClimax = pvsrClimaxByVolume or pvsrClimaxBySpread

bool pvsrAboveAverage =
     pvsrHasData and
     not pvsrClimax and
     pvsrVolume >= pvsrAvgVolume * pvsrAboveAvgMultiplier

const int FOOTPRINT_REQUEST_BARS = 120

f_footprintStats() =>
    footprint fp = request.footprint(footprintTicksPerRow)
    bool hasFp = not na(fp)
    float totalVol = hasFp ? footprint.total_volume(fp) : na
    float buyVol = hasFp ? footprint.buy_volume(fp) : na
    float sellVol = hasFp ? footprint.sell_volume(fp) : na
    float deltaVol = hasFp ? footprint.delta(fp) : na
    [totalVol, buyVol, sellVol, deltaVol]

[footprintTotalVolume, footprintBuyVolume, footprintSellVolume, footprintDeltaVolume] =
     request.security(
         syminfo.tickerid,
         timeframe.period,
         f_footprintStats(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         calc_bars_count=FOOTPRINT_REQUEST_BARS)

bool footprintBubbleSelectedBar =
     footprintBubbleVisibility == "All candles"
         ? true
         : footprintBubbleVisibility == "150% + 200%"
             ? (
                 pvsrClimax or
                 pvsrAboveAverage
             )
             : pvsrClimax

bool footprintInsideHistoryWindow =
     not footprintLimitHistoryToOneHour or
     time >= footprintHistoryCutoff

bool footprintRequestNeeded =
     enableFootprintBubbles and
     barstate.isconfirmed and
     footprintBubbleSelectedBar and
     footprintInsideHistoryWindow

bool footprintHasData =
     not na(footprintTotalVolume) and
     not na(footprintBuyVolume) and
     not na(footprintSellVolume) and
     not na(footprintDeltaVolume)

bool footprintHasUsableData =
     footprintHasData and
     footprintTotalVolume > 0

float footprintBuyPct =
     footprintHasUsableData
         ? footprintBuyVolume / footprintTotalVolume * 100.0
         : na

float footprintSellPct =
     footprintHasUsableData
         ? footprintSellVolume / footprintTotalVolume * 100.0
         : na

float footprintDeltaPct =
     footprintHasUsableData
         ? footprintDeltaVolume / footprintTotalVolume * 100.0
         : na

float footprintDominanceDifference =
     footprintHasUsableData
         ? math.abs(footprintBuyPct - footprintSellPct)
         : na

bool footprintNeutralDominance =
     footprintHasUsableData and
     footprintDominanceDifference <= footprintNeutralThreshold

bool footprintBuyDominance =
     footprintHasUsableData and
     not footprintNeutralDominance and
     footprintBuyPct > footprintSellPct

bool footprintSellDominance =
     footprintHasUsableData and
     not footprintNeutralDominance and
     footprintSellPct > footprintBuyPct

color pvsrCandleColor =
     pvsrClimax
         ? (pvsrBullCandle ? pvsrBullClimaxColor : pvsrBearClimaxColor)
         : pvsrAboveAverage
             ? (pvsrBullCandle ? pvsrBullAboveAvgColor : pvsrBearAboveAvgColor)
             : (pvsrBullCandle ? pvsrRegularBullColor : pvsrRegularBearColor)

color finalPvsrCandleColor =
     color.new(pvsrCandleColor, pvsrCandleTransparency)

color finalCandleColor =
     enablePvsr
         ? finalPvsrCandleColor
         : enableRsiGradient
             ? finalRsiCandleColor
             : na

barcolor(finalCandleColor)

float minFvgThreshold =
     minFvgUnit == "Ticks"
         ? minFvgSize * syminfo.mintick
         : minFvgSize

bool bullishFvgRaw = bar_index >= 2 and low > high[2]
bool bearishFvgRaw = bar_index >= 2 and high < low[2]

float bullishFvgSize = bullishFvgRaw ? low - high[2] : na
float bearishFvgSize = bearishFvgRaw ? low[2] - high : na

bool bullishFvg =
     enableFvg and
     barstate.isconfirmed and
     bullishFvgRaw and
     (not useMinFvgFilter or bullishFvgSize >= minFvgThreshold)

bool bearishFvg =
     enableFvg and
     barstate.isconfirmed and
     bearishFvgRaw and
     (not useMinFvgFilter or bearishFvgSize >= minFvgThreshold)

var array<box> fvgBoxes = array.new<box>()
var array<int> fvgTimes = array.new<int>()

if showFvg and bullishFvg
    box bullBox =
         box.new(
             left=bar_index - 2,
             top=low,
             right=bar_index,
             bottom=high[2],
             xloc=xloc.bar_index,
             extend=extend.none,
             border_color=color.new(bullishFvgColor, 76),
             border_width=1,
             bgcolor=color.new(bullishFvgColor, fvgTransparency))
    array.push(fvgBoxes, bullBox)
    array.push(fvgTimes, time)

if showFvg and bearishFvg
    box bearBox =
         box.new(
             left=bar_index - 2,
             top=low[2],
             right=bar_index,
             bottom=high,
             xloc=xloc.bar_index,
             extend=extend.none,
             border_color=color.new(bearishFvgColor, 76),
             border_width=1,
             bgcolor=color.new(bearishFvgColor, fvgTransparency))
    array.push(fvgBoxes, bearBox)
    array.push(fvgTimes, time)

if fvgVisibility == "Last N hours"
    while array.size(fvgTimes) > 0
        int oldestFvgTime = array.get(fvgTimes, 0)
        if oldestFvgTime < fvgCutoff
            box oldFvg = array.shift(fvgBoxes)
            array.shift(fvgTimes)
            box.delete(oldFvg)
        else
            break

while array.size(fvgBoxes) > maximumFvgZones
    box oldFvg = array.shift(fvgBoxes)
    array.shift(fvgTimes)
    box.delete(oldFvg)

var int bullishClusterFirstBar = na
var float bullishClusterBottom = na
var float bullishClusterTop = na

var int bearishClusterFirstBar = na
var float bearishClusterBottom = na
var float bearishClusterTop = na

bool twoBullishFvg = false
bool twoBearishFvg = false

if enableFvg and barstate.isconfirmed
    if not na(bullishClusterFirstBar) and
       bar_index - bullishClusterFirstBar > maxBarsBetweenFvg
        bullishClusterFirstBar := na
        bullishClusterBottom := na
        bullishClusterTop := na

    if not na(bearishClusterFirstBar) and
       bar_index - bearishClusterFirstBar > maxBarsBetweenFvg
        bearishClusterFirstBar := na
        bearishClusterBottom := na
        bearishClusterTop := na

    if bullishFvg
        bearishClusterFirstBar := na
        bearishClusterBottom := na
        bearishClusterTop := na

        float currentBullBottom = high[2]
        float currentBullTop = low

        if na(bullishClusterFirstBar)
            bullishClusterFirstBar := bar_index
            bullishClusterBottom := currentBullBottom
            bullishClusterTop := currentBullTop
        else
            bool overlapsBullCluster =
                 currentBullBottom <= bullishClusterTop and
                 currentBullTop >= bullishClusterBottom

            if overlapsBullCluster
                bullishClusterBottom :=
                     math.min(
                         bullishClusterBottom,
                         currentBullBottom)

                bullishClusterTop :=
                     math.max(
                         bullishClusterTop,
                         currentBullTop)
            else
                twoBullishFvg := true
                bullishClusterFirstBar := na
                bullishClusterBottom := na
                bullishClusterTop := na

    else if bearishFvg
        bullishClusterFirstBar := na
        bullishClusterBottom := na
        bullishClusterTop := na

        float currentBearBottom = high
        float currentBearTop = low[2]

        if na(bearishClusterFirstBar)
            bearishClusterFirstBar := bar_index
            bearishClusterBottom := currentBearBottom
            bearishClusterTop := currentBearTop
        else
            bool overlapsBearCluster =
                 currentBearBottom <= bearishClusterTop and
                 currentBearTop >= bearishClusterBottom

            if overlapsBearCluster
                bearishClusterBottom :=
                     math.min(
                         bearishClusterBottom,
                         currentBearBottom)

                bearishClusterTop :=
                     math.max(
                         bearishClusterTop,
                         currentBearTop)
            else
                twoBearishFvg := true
                bearishClusterFirstBar := na
                bearishClusterBottom := na
                bearishClusterTop := na

bool anyTwoFvg = twoBullishFvg or twoBearishFvg

var array<label> twoFvgLabels = array.new<label>()
var array<int> twoFvgTimes = array.new<int>()

float markerAtr =
     nz(
         ta.atr(14),
         syminfo.mintick * 20)

if showTwoFvgMarkers and twoBullishFvg
    label bull2x =
         label.new(
             x=bar_index,
             y=low - markerAtr * 0.10,
             text="▲ 2x",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_none,
             textcolor=bullishFvgColor,
             size=size.tiny)

    array.push(twoFvgLabels, bull2x)
    array.push(twoFvgTimes, time)

if showTwoFvgMarkers and twoBearishFvg
    label bear2x =
         label.new(
             x=bar_index,
             y=high + markerAtr * 0.10,
             text="▼ 2x",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_none,
             textcolor=bearishFvgColor,
             size=size.tiny)

    array.push(twoFvgLabels, bear2x)
    array.push(twoFvgTimes, time)

if fvgVisibility == "Last N hours"
    while array.size(twoFvgTimes) > 0
        int oldest2xTime =
             array.get(twoFvgTimes, 0)

        if oldest2xTime < fvgCutoff
            label old2x =
                 array.shift(twoFvgLabels)

            array.shift(twoFvgTimes)
            label.delete(old2x)
        else
            break

float pivotHigh =
     ta.pivothigh(
         high,
         swingLength,
         swingLength)

float pivotLow =
     ta.pivotlow(
         low,
         swingLength,
         swingLength)

var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na
var bool lastSwingHighBroken = false
var bool lastSwingLowBroken = false
var int structureDirection = 0

bool bullishBosRaw = false
bool bearishBosRaw = false
bool bullishChochRaw = false
bool bearishChochRaw = false

float bullishSignalLevel = na
int bullishSignalStartBar = na
float bearishSignalLevel = na
int bearishSignalStartBar = na

if barstate.isconfirmed
    float highBreakSource =
         breakConfirmation == "Close"
             ? close
             : high

    float lowBreakSource =
         breakConfirmation == "Close"
             ? close
             : low

    bool oldBreakHigh =
         not na(lastSwingHigh) and
         not lastSwingHighBroken and
         highBreakSource > lastSwingHigh

    bool oldBreakLow =
         not na(lastSwingLow) and
         not lastSwingLowBroken and
         lowBreakSource < lastSwingLow

    if oldBreakHigh
        lastSwingHighBroken := true

    if oldBreakLow
        lastSwingLowBroken := true

    bool selectedOldHigh = oldBreakHigh
    bool selectedOldLow = oldBreakLow

    if oldBreakHigh and oldBreakLow
        if structureDirection == 1
            selectedOldHigh := false
        else if structureDirection == -1
            selectedOldLow := false
        else if close >= open
            selectedOldLow := false
        else
            selectedOldHigh := false

    bool structureSignalCreated = false

    if selectedOldHigh
        bullishSignalLevel := lastSwingHigh
        bullishSignalStartBar := lastSwingHighBar

        if structureDirection == -1
            bullishChochRaw := true
        else
            bullishBosRaw := true

        structureDirection := 1
        structureSignalCreated := true

    else if selectedOldLow
        bearishSignalLevel := lastSwingLow
        bearishSignalStartBar := lastSwingLowBar

        if structureDirection == 1
            bearishChochRaw := true
        else
            bearishBosRaw := true

        structureDirection := -1
        structureSignalCreated := true

    bool hasNewPivotHigh = not na(pivotHigh)
    bool hasNewPivotLow = not na(pivotLow)

    float newPivotHighLevel = pivotHigh
    float newPivotLowLevel = pivotLow

    int newPivotHighBar =
         bar_index -
         swingLength

    int newPivotLowBar =
         bar_index -
         swingLength

    bool newPivotHighAlreadyBroken =
         hasNewPivotHigh and
         highBreakSource > newPivotHighLevel

    bool newPivotLowAlreadyBroken =
         hasNewPivotLow and
         lowBreakSource < newPivotLowLevel

    bool selectedNewHigh =
         newPivotHighAlreadyBroken

    bool selectedNewLow =
         newPivotLowAlreadyBroken

    if not structureSignalCreated
        if selectedNewHigh and selectedNewLow
            if structureDirection == 1
                selectedNewHigh := false
            else if structureDirection == -1
                selectedNewLow := false
            else if close >= open
                selectedNewLow := false
            else
                selectedNewHigh := false

        if selectedNewHigh
            bullishSignalLevel := newPivotHighLevel
            bullishSignalStartBar := newPivotHighBar

            if structureDirection == -1
                bullishChochRaw := true
            else
                bullishBosRaw := true

            structureDirection := 1

        else if selectedNewLow
            bearishSignalLevel := newPivotLowLevel
            bearishSignalStartBar := newPivotLowBar

            if structureDirection == 1
                bearishChochRaw := true
            else
                bearishBosRaw := true

            structureDirection := -1

    if hasNewPivotHigh
        lastSwingHigh := newPivotHighLevel
        lastSwingHighBar := newPivotHighBar
        lastSwingHighBroken := newPivotHighAlreadyBroken

    if hasNewPivotLow
        lastSwingLow := newPivotLowLevel
        lastSwingLowBar := newPivotLowBar
        lastSwingLowBroken := newPivotLowAlreadyBroken

bool bullishBos =
     enableBos and
     bullishBosRaw

bool bearishBos =
     enableBos and
     bearishBosRaw

bool bullishChoch =
     enableChoch and
     bullishChochRaw

bool bearishChoch =
     enableChoch and
     bearishChochRaw

bool anyBos = bullishBos or bearishBos
bool anyChoch = bullishChoch or bearishChoch

bool anyStructureBreak =
     anyBos or
     anyChoch

var array<line> structureLines =
     array.new<line>()

var array<int> structureLineTimes =
     array.new<int>()

var array<label> structureLabels =
     array.new<label>()

var array<int> structureLabelTimes =
     array.new<int>()

float structureAtr =
     ta.atr(14)

float structureLabelOffset =
     nz(
         structureAtr,
         syminfo.mintick * 20) *
     0.06

if bullishBos or bullishChoch
    string bullText =
         bullishChoch
             ? "CHoCH"
             : "BOS"

    bool showBullText =
         (
             bullishBos and
             showBosLabels
         ) or
         (
             bullishChoch and
             showChochLabels
         )

    if showStructureLines and
       not na(bullishSignalLevel) and
       not na(bullishSignalStartBar)

        line bullLine =
             line.new(
                 x1=bullishSignalStartBar,
                 y1=bullishSignalLevel,
                 x2=bar_index,
                 y2=bullishSignalLevel,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=bullishStructureColor,
                 style=line.style_dashed,
                 width=2)

        array.push(structureLines, bullLine)
        array.push(structureLineTimes, time)

    if showBullText and
       not na(bullishSignalLevel) and
       not na(bullishSignalStartBar)

        int textX =
             bullishSignalStartBar +
             int(
                 (bar_index -
                  bullishSignalStartBar) /
                 2)

        label bullLabel =
             label.new(
                 x=textX,
                 y=bullishSignalLevel +
                   structureLabelOffset,
                 text=bullText,
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_none,
                 textcolor=bullishStructureColor,
                 size=size.small)

        array.push(structureLabels, bullLabel)
        array.push(structureLabelTimes, time)

if bearishBos or bearishChoch
    string bearText =
         bearishChoch
             ? "CHoCH"
             : "BOS"

    bool showBearText =
         (
             bearishBos and
             showBosLabels
         ) or
         (
             bearishChoch and
             showChochLabels
         )

    if showStructureLines and
       not na(bearishSignalLevel) and
       not na(bearishSignalStartBar)

        line bearLine =
             line.new(
                 x1=bearishSignalStartBar,
                 y1=bearishSignalLevel,
                 x2=bar_index,
                 y2=bearishSignalLevel,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=bearishStructureColor,
                 style=line.style_dashed,
                 width=2)

        array.push(structureLines, bearLine)
        array.push(structureLineTimes, time)

    if showBearText and
       not na(bearishSignalLevel) and
       not na(bearishSignalStartBar)

        int textX =
             bearishSignalStartBar +
             int(
                 (bar_index -
                  bearishSignalStartBar) /
                 2)

        label bearLabel =
             label.new(
                 x=textX,
                 y=bearishSignalLevel +
                   structureLabelOffset,
                 text=bearText,
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_none,
                 textcolor=bearishStructureColor,
                 size=size.small)

        array.push(structureLabels, bearLabel)
        array.push(structureLabelTimes, time)

if structureVisibility == "Last N hours"
    while array.size(structureLineTimes) > 0
        int oldestLineTime =
             array.get(
                 structureLineTimes,
                 0)

        if oldestLineTime <
           structureCutoff

            line oldLine =
                 array.shift(
                     structureLines)

            array.shift(
                 structureLineTimes)

            line.delete(
                 oldLine)
        else
            break

    while array.size(structureLabelTimes) > 0
        int oldestLabelTime =
             array.get(
                 structureLabelTimes,
                 0)

        if oldestLabelTime <
           structureCutoff

            label oldLabel =
                 array.shift(
                     structureLabels)

            array.shift(
                 structureLabelTimes)

            label.delete(
                 oldLabel)
        else
            break

while array.size(structureLines) >
      maximumStructureObjects

    line oldLine =
         array.shift(
             structureLines)

    array.shift(
         structureLineTimes)

    line.delete(
         oldLine)

while array.size(structureLabels) >
      maximumStructureObjects

    label oldLabel =
         array.shift(
             structureLabels)

    array.shift(
         structureLabelTimes)

    label.delete(
         oldLabel)

float fastEma =
     ta.ema(
         close,
         fastEmaLength)

float slowEma =
     ta.ema(
         close,
         slowEmaLength)

bool emaBullishCross =
     enableEma and
     barstate.isconfirmed and
     ta.crossover(
         fastEma,
         slowEma)

bool emaBearishCross =
     enableEma and
     barstate.isconfirmed and
     ta.crossunder(
         fastEma,
         slowEma)

bool anyEmaCross =
     emaBullishCross or
     emaBearishCross

plot(
     enableEma and showEma
         ? fastEma
         : na,
     title="Fast EMA",
     color=fastEmaColor,
     linewidth=emaLineWidth)

plot(
     enableEma and showEma
         ? slowEma
         : na,
     title="Slow EMA",
     color=slowEmaColor,
     linewidth=emaLineWidth)

plotshape(
     emaBullishCross,
     title="EMA Bullish Cross",
     style=shape.circle,
     location=location.belowbar,
     color=fastEmaColor,
     size=size.tiny)

plotshape(
     emaBearishCross,
     title="EMA Bearish Cross",
     style=shape.circle,
     location=location.abovebar,
     color=slowEmaColor,
     size=size.tiny)

plot(
     showSwingHighLow or debugMode
         ? pivotHigh
         : na,
     title="Confirmed Swing High",
     color=bearishStructureColor,
     linewidth=2,
     style=plot.style_circles)

plot(
     showSwingHighLow or debugMode
         ? pivotLow
         : na,
     title="Confirmed Swing Low",
     color=bullishStructureColor,
     linewidth=2,
     style=plot.style_circles)

bool alertTwoBullFvg =
     enableFvgAlerts and
     twoBullishFvg

bool alertTwoBearFvg =
     enableFvgAlerts and
     twoBearishFvg

bool alertAnyTwoFvg =
     enableFvgAlerts and
     anyTwoFvg

bool alertBullBos =
     enableStructureAlerts and
     bullishBos

bool alertBearBos =
     enableStructureAlerts and
     bearishBos

bool alertAnyBos =
     enableStructureAlerts and
     anyBos

bool alertBullChoch =
     enableStructureAlerts and
     bullishChoch

bool alertBearChoch =
     enableStructureAlerts and
     bearishChoch

bool alertAnyChoch =
     enableStructureAlerts and
     anyChoch

bool alertAnyStructure =
     enableStructureAlerts and
     anyStructureBreak

bool alertEmaBull =
     enableEmaAlerts and
     emaBullishCross

bool alertEmaBear =
     enableEmaAlerts and
     emaBearishCross

bool alertAnyEma =
     enableEmaAlerts and
     anyEmaCross

bool pvsrGreenCandle =
     enablePvsr and
     barstate.isconfirmed and
     pvsrClimax and
     pvsrBullCandle

bool pvsrRedCandle =
     enablePvsr and
     barstate.isconfirmed and
     pvsrClimax and
     not pvsrBullCandle

bool anyPvsrClimax =
     pvsrGreenCandle or
     pvsrRedCandle

bool alertPvsrGreen =
     enablePvsrAlerts and
     pvsrGreenCandle

bool alertPvsrRed =
     enablePvsrAlerts and
     pvsrRedCandle

bool alertAnyPvsrClimax =
     enablePvsrAlerts and
     anyPvsrClimax

bool footprintShouldDrawBubble =
     footprintRequestNeeded and
     footprintHasUsableData

var array<label> footprintCircleLabels =
     array.new<label>()

var array<label> footprintTextLabels =
     array.new<label>()

var array<int> footprintBubbleTimes =
     array.new<int>()

var array<int> footprintBubbleBars =
     array.new<int>()

var array<int> footprintBubbleSides =
     array.new<int>()

var array<int> footprintBubbleLanes =
     array.new<int>()

float footprintBubbleAtr =
     nz(
         ta.atr(14),
         syminfo.mintick * 20)

if footprintLimitHistoryToOneHour
    while array.size(
          footprintBubbleTimes) > 0

        int oldestFootprintBubbleTime =
             array.get(
                 footprintBubbleTimes,
                 0)

        if oldestFootprintBubbleTime <
           footprintHistoryCutoff

            label oldCircle =
                 array.shift(
                     footprintCircleLabels)

            label oldText =
                 array.shift(
                     footprintTextLabels)

            array.shift(
                 footprintBubbleTimes)

            array.shift(
                 footprintBubbleBars)

            array.shift(
                 footprintBubbleSides)

            array.shift(
                 footprintBubbleLanes)

            label.delete(
                 oldCircle)

            label.delete(
                 oldText)
        else
            break

int footprintNonBubbleLabelCount =
     array.size(twoFvgLabels) +
     array.size(structureLabels)

int footprintAvailableLabelSlots =
     math.max(
         0,
         495 -
         footprintNonBubbleLabelCount)

int footprintAvailableBubblePairs =
     int(
         math.floor(
             footprintAvailableLabelSlots /
             2.0))

int footprintEffectiveBubbleLimit =
     math.min(
         maximumFootprintBubbles,
         footprintAvailableBubblePairs)

while array.size(
      footprintCircleLabels) >
      footprintEffectiveBubbleLimit

    label oldCircle =
         array.shift(
             footprintCircleLabels)

    label oldText =
         array.shift(
             footprintTextLabels)

    if array.size(
       footprintBubbleTimes) > 0

        array.shift(
             footprintBubbleTimes)

        array.shift(
             footprintBubbleBars)

        array.shift(
             footprintBubbleSides)

        array.shift(
             footprintBubbleLanes)

    label.delete(
         oldCircle)

    label.delete(
         oldText)

if footprintShouldDrawBubble and
   footprintEffectiveBubbleLimit > 0

    while array.size(
          footprintCircleLabels) >=
          footprintEffectiveBubbleLimit and
          array.size(
          footprintCircleLabels) > 0

        label oldCircle =
             array.shift(
                 footprintCircleLabels)

        label oldText =
             array.shift(
                 footprintTextLabels)

        if array.size(
           footprintBubbleTimes) > 0

            array.shift(
                 footprintBubbleTimes)

            array.shift(
                 footprintBubbleBars)

            array.shift(
                 footprintBubbleSides)

            array.shift(
                 footprintBubbleLanes)

        label.delete(
             oldCircle)

        label.delete(
             oldText)

    int footprintManualCircleSize =
         footprintBubbleSize == "Tiny"
             ? 22
             : footprintBubbleSize == "Small"
                 ? 26
                 : 30

    int footprintManualOverlayTextSize =
         footprintBubbleSize == "Tiny"
             ? 7
             : footprintBubbleSize == "Small"
                 ? 8
                 : 9

    int footprintDynamicCircleSize =
         footprintDominanceDifference <=
         footprintNeutralThreshold
             ? 26
             : footprintDominanceDifference <= 15.0
                 ? 22
                 : footprintDominanceDifference <= 30.0
                     ? 26
                     : footprintDominanceDifference <= 50.0
                         ? 30
                         : 34

    int footprintDynamicOverlayTextSize =
         footprintDominanceDifference <=
         footprintNeutralThreshold
             ? 7
             : footprintDominanceDifference <= 15.0
                 ? 7
                 : footprintDominanceDifference <= 30.0
                     ? 8
                     : footprintDominanceDifference <= 50.0
                         ? 8
                         : 9

    int footprintCircleSize =
         footprintDynamicBubbleSize
             ? footprintDynamicCircleSize
             : footprintManualCircleSize

    int footprintOverlayTextSize =
         footprintDynamicBubbleSize
             ? footprintDynamicOverlayTextSize
             : footprintManualOverlayTextSize

    string footprintBuyPctText =
         str.tostring(
             footprintBuyPct,
             "#.#")

    string footprintSellPctText =
         str.tostring(
             footprintSellPct,
             "#.#")

    string footprintDeltaPctValueText =
         str.tostring(
             footprintDeltaPct,
             "#.#")

    string footprintDeltaPctSignedText =
         (
             footprintDeltaPct > 0
                 ? "+"
                 : ""
         ) +
         footprintDeltaPctValueText +
         "%"

    string footprintDeltaVolumeSignedText =
         (
             footprintDeltaVolume > 0
                 ? "+"
                 : ""
         ) +
         str.tostring(
             footprintDeltaVolume,
             "#,###.##")

    string footprintDominanceText =
         footprintBuyDominance
             ? "BUY"
             : footprintSellDominance
                 ? "SELL"
                 : "NEUTRAL"

    string footprintBubbleText =
         footprintBuyDominance
             ? footprintShowDeltaPct
                 ? "BUY " +
                   footprintBuyPctText +
                   "%\nΔ " +
                   footprintDeltaPctSignedText
                 : "BUY " +
                   footprintBuyPctText +
                   "%"
             : footprintSellDominance
                 ? footprintShowDeltaPct
                     ? "SELL " +
                       footprintSellPctText +
                       "%\nΔ " +
                       footprintDeltaPctSignedText
                     : "SELL " +
                       footprintSellPctText +
                       "%"
                 : footprintShowDeltaPct
                     ? "NEUTRAL\n" +
                       footprintBuyPctText +
                       "/" +
                       footprintSellPctText +
                       "%\nΔ " +
                       footprintDeltaPctSignedText
                     : "NEUTRAL\n" +
                       footprintBuyPctText +
                       "/" +
                       footprintSellPctText +
                       "%"

    string footprintDetailedTooltip =
         "BUY Volume: " +
         str.tostring(
             footprintBuyVolume,
             "#,###.##") +
         "\nSELL Volume: " +
         str.tostring(
             footprintSellVolume,
             "#,###.##") +
         "\nTotal Volume: " +
         str.tostring(
             footprintTotalVolume,
             "#,###.##") +
         "\nBUY: " +
         footprintBuyPctText +
         "%" +
         "\nSELL: " +
         footprintSellPctText +
         "%" +
         "\nDelta: " +
         footprintDeltaVolumeSignedText +
         "\nDelta %: " +
         footprintDeltaPctSignedText +
         "\nDominance: " +
         footprintDominanceText +
         "\nBUY/SELL difference: " +
         str.tostring(
             footprintDominanceDifference,
             "#.#") +
         " pp"

    string footprintTooltip =
         footprintShowDetailedTooltip
             ? footprintDetailedTooltip
             : ""

    bool footprintBubbleBelow =
         footprintBuyDominance

    int footprintBubbleSide =
         footprintBubbleBelow
             ? -1
             : 1

    int footprintCollisionLookbackBars =
         4

    bool footprintLane0Used = false
    bool footprintLane1Used = false
    bool footprintLane2Used = false
    bool footprintLane3Used = false
    bool footprintLane4Used = false

    if array.size(
       footprintBubbleBars) > 0

        for i = 0 to array.size(footprintBubbleBars) - 1
            int oldBubbleBar =
                 array.get(
                     footprintBubbleBars,
                     i)

            int oldBubbleSide =
                 array.get(
                     footprintBubbleSides,
                     i)

            int oldBubbleLane =
                 array.get(
                     footprintBubbleLanes,
                     i)

            int bubbleBarsApart =
                 bar_index -
                 oldBubbleBar

            bool bubbleCanCollide =
                 oldBubbleSide ==
                 footprintBubbleSide and
                 bubbleBarsApart >= 0 and
                 bubbleBarsApart <=
                 footprintCollisionLookbackBars

            if bubbleCanCollide
                if oldBubbleLane == 0
                    footprintLane0Used := true
                else if oldBubbleLane == 1
                    footprintLane1Used := true
                else if oldBubbleLane == 2
                    footprintLane2Used := true
                else if oldBubbleLane == 3
                    footprintLane3Used := true
                else if oldBubbleLane == 4
                    footprintLane4Used := true

    int footprintCollisionLane =
         not footprintLane0Used
             ? 0
             : not footprintLane1Used
                 ? 1
                 : not footprintLane2Used
                     ? 2
                     : not footprintLane3Used
                         ? 3
                         : not footprintLane4Used
                             ? 4
                             : 0

    float footprintDynamicOffsetMultiplier =
         footprintDynamicBubbleSize
             ? footprintDominanceDifference <= 15.0
                 ? 1.00
                 : footprintDominanceDifference <= 30.0
                     ? 1.08
                     : footprintDominanceDifference <= 50.0
                         ? 1.16
                         : 1.24
             : 1.00

    float footprintBubbleBaseOffset =
         math.max(
             footprintBubbleAtr *
             0.22 *
             footprintDynamicOffsetMultiplier,
             syminfo.mintick *
             12)

    float footprintLaneAtrFactor =
         footprintCircleSize <= 22
             ? 0.24
             : footprintCircleSize <= 26
                 ? 0.28
                 : footprintCircleSize <= 30
                     ? 0.33
                     : 0.38

    float footprintLaneSpacing =
         math.max(
             footprintBubbleAtr *
             footprintLaneAtrFactor,
             syminfo.mintick *
             16)

    float footprintCollisionOffset =
         footprintCollisionLane *
         footprintLaneSpacing

    float footprintBubbleY =
         footprintBubbleBelow
             ? low -
               footprintBubbleBaseOffset -
               footprintCollisionOffset
             : high +
               footprintBubbleBaseOffset +
               footprintCollisionOffset

    color footprintBubbleBaseColor =
         footprintBuyDominance
             ? footprintBuyBubbleColor
             : footprintSellDominance
                 ? footprintSellBubbleColor
                 : footprintNeutralBubbleColor

    color footprintBubbleFinalColor =
         color.new(
             footprintBubbleBaseColor,
             footprintBubbleTransparency)

    label footprintCircle =
         label.new(
             x=bar_index,
             y=footprintBubbleY,
             text="",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             color=footprintBubbleFinalColor,
             style=label.style_circle,
             textcolor=color.white,
             size=footprintCircleSize,
             textalign=text.align_center,
             tooltip=footprintTooltip)

    label footprintText =
         label.new(
             x=bar_index,
             y=footprintBubbleY,
             text=footprintBubbleText,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             color=color.new(
                 color.white,
                 100),
             style=label.style_none,
             textcolor=color.white,
             size=footprintOverlayTextSize,
             textalign=text.align_center,
             tooltip=footprintTooltip,
             text_formatting=text.format_bold)

    array.push(
         footprintCircleLabels,
         footprintCircle)

    array.push(
         footprintTextLabels,
         footprintText)

    array.push(
         footprintBubbleTimes,
         time)

    array.push(
         footprintBubbleBars,
         bar_index)

    array.push(
         footprintBubbleSides,
         footprintBubbleSide)

    array.push(
         footprintBubbleLanes,
         footprintCollisionLane)

bool alertMaster =
     enableMasterAlert and
     (
         anyTwoFvg or
         anyStructureBreak or
         anyEmaCross or
         anyPvsrClimax
     )

alertcondition(
     alertTwoBullFvg,
     title="2x Bullish FVG",
     message="2x BULLISH FVG | {{ticker}} | TF: {{interval}}")

alertcondition(
     alertTwoBearFvg,
     title="2x Bearish FVG",
     message="2x BEARISH FVG | {{ticker}} | TF: {{interval}}")

alertcondition(
     alertAnyTwoFvg,
     title="2x FVG — Any Direction",
     message="2x FVG | {{ticker}} | TF: {{interval}}")

alertcondition(
     alertBullBos,
     title="Bullish BOS",
     message="BULLISH BOS | {{ticker}} | TF: {{interval}}")

alertcondition(
     alertBearBos,
     title="Bearish BOS",
     message="BEARISH BOS | {{ticker}} | TF: {{interval}}")

alertcondition(
     alertAnyBos,
     title="Any BOS",
     message="BOS | {{ticker}} | TF: {{interval}}")

alertcondition(
     alertBullChoch,
     title="Bullish CHoCH",
     message="BULLISH CHoCH | {{ticker}} | TF: {{interval}}")

alertcondition(
     alertBearChoch,
     title="Bearish CHoCH",
     message="BEARISH CHoCH | {{ticker}} | TF: {{interval}}")

alertcondition(
     alertAnyChoch,
     title="Any CHoCH",
     message="CHoCH | {{ticker}} | TF: {{interval}}")

alertcondition(
     alertAnyStructure,
     title="Any Structure Break",
     message="STRUCTURE BREAK | {{ticker}} | TF: {{interval}}")

alertcondition(
     alertEmaBull,
     title="EMA Bullish Cross",
     message="EMA BULLISH CROSS | {{ticker}} | TF: {{interval}}")

alertcondition(
     alertEmaBear,
     title="EMA Bearish Cross",
     message="EMA BEARISH CROSS | {{ticker}} | TF: {{interval}}")

alertcondition(
     alertAnyEma,
     title="Any EMA Cross",
     message="EMA CROSS | {{ticker}} | TF: {{interval}}")

alertcondition(
     alertPvsrGreen,
     title="PVSRA Green Candle — Bullish Climax",
     message="PVSRA GREEN CANDLE / BULLISH CLIMAX | {{ticker}} | TF: {{interval}} | Close: {{close}}")

alertcondition(
     alertPvsrRed,
     title="PVSRA Red Candle — Bearish Climax",
     message="PVSRA RED CANDLE / BEARISH CLIMAX | {{ticker}} | TF: {{interval}} | Close: {{close}}")

alertcondition(
     alertAnyPvsrClimax,
     title="PVSRA Green/Red Candle — Any Climax",
     message="PVSRA CLIMAX CANDLE | {{ticker}} | TF: {{interval}} | Close: {{close}}")

alertcondition(
     alertMaster,
     title="ANY SIGNAL",
     message="ANY SIGNAL | {{ticker}} | TF: {{interval}}")

bool repeatingSignal =
     alertTwoBullFvg or
     alertTwoBearFvg or
     alertBullBos or
     alertBearBos or
     alertBullChoch or
     alertBearChoch or
     alertEmaBull or
     alertEmaBear or
     alertPvsrGreen or
     alertPvsrRed

string repeatingMessage = ""

if alertTwoBullFvg
    repeatingMessage +=
         "2x BULLISH FVG | " +
         syminfo.ticker +
         " | TF: " +
         timeframe.period +
         "\n"

if alertTwoBearFvg
    repeatingMessage +=
         "2x BEARISH FVG | " +
         syminfo.ticker +
         " | TF: " +
         timeframe.period +
         "\n"

if alertBullBos
    repeatingMessage +=
         "BULLISH BOS | " +
         syminfo.ticker +
         " | TF: " +
         timeframe.period +
         "\n"

if alertBearBos
    repeatingMessage +=
         "BEARISH BOS | " +
         syminfo.ticker +
         " | TF: " +
         timeframe.period +
         "\n"

if alertBullChoch
    repeatingMessage +=
         "BULLISH CHoCH | " +
         syminfo.ticker +
         " | TF: " +
         timeframe.period +
         "\n"

if alertBearChoch
    repeatingMessage +=
         "BEARISH CHoCH | " +
         syminfo.ticker +
         " | TF: " +
         timeframe.period +
         "\n"

if alertEmaBull
    repeatingMessage +=
         "EMA BULLISH CROSS | " +
         syminfo.ticker +
         " | TF: " +
         timeframe.period +
         "\n"

if alertEmaBear
    repeatingMessage +=
         "EMA BEARISH CROSS | " +
         syminfo.ticker +
         " | TF: " +
         timeframe.period +
         "\n"

if alertPvsrGreen
    repeatingMessage +=
         "PVSRA GREEN CANDLE / BULLISH CLIMAX | " +
         syminfo.ticker +
         " | TF: " +
         timeframe.period +
         " | Close: " +
         str.tostring(
             close) +
         "\n"

if alertPvsrRed
    repeatingMessage +=
         "PVSRA RED CANDLE / BEARISH CLIMAX | " +
         syminfo.ticker +
         " | TF: " +
         timeframe.period +
         " | Close: " +
         str.tostring(
             close) +
         "\n"

if enableRepeatingAlerts and
   repeatingSignal and
   barstate.isconfirmed

    alert(
         repeatingMessage,
         alert.freq_once_per_bar_close)
````
