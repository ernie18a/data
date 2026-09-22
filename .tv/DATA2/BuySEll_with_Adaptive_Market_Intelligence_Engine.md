<!-- tradingview-pine-id: PUB;3ba2e19f66c94759a2cab5c42ff02037 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Buy-SEll with Adaptive Market Intelligence Engine

Source: https://www.tradingview.com/script/rrwlLVT9-Buy-Sell-with-Adaptive-Market-Intelligence-Engine/

## Description

Adaptive Market Intelligence Engine - Structure and Trend Confluence

---------------------------------------

📊 Overview

Adaptive Market Intelligence Engine is a multi-layer market analysis indicator designed to interpret trend, market structure, momentum, volatility, participation, and higher-timeframe context through a unified weight-of-evidence framework.

The purpose of the indicator is not to predict every price movement or produce frequent trade signals.

Instead, it attempts to answer three practical questions:

• Is the market trending, ranging, compressing, or expanding?
• Which side currently has stronger technical evidence: buyers or sellers?
• Has a sufficiently strong new directional trend developed to justify a BUY or SELL signal?

The indicator combines several independent categories of technical evidence while attempting to reduce duplicated information and chart clutter.

Its primary components include:

• Major market structure
• HH/HL and LH/LL structural progression
• BOS and CHOCH detection
• Trend regime classification
• EMA trend structure
• Higher-timeframe confirmation
• VWAP / mean positioning
• RSI momentum
• MACD momentum
• ADX and directional movement
• Volume participation
• ATR volatility analysis
• Volatility compression detection
• Bullish and bearish confluence scores
• One-signal-per-trend state logic
• Structural retest identification
• Market intelligence dashboard

The indicator is intended to work as an analytical framework rather than as a standalone mechanical trading system.

https://www.tradingview.com/x/hPjquT46/

---------------------------------------

🧠 Core Philosophy

Markets rarely move because of one technical condition.

An EMA crossover alone, RSI reading alone, volume spike alone, or isolated market-structure break can provide incomplete information.

This indicator therefore uses a weight-of-evidence approach.

Different technical categories contribute to a bullish or bearish score, and directional signals are generated only when several conditions align simultaneously.

The goal is to separate:

Trend from Temporary movement and Directional expansion from Range-bound market noise.

---------------------------------------

🔄 Market Regime Engine

Before evaluating directional signals, the indicator attempts to classify the current market environment.

The main regime states are:

• TRENDING
• TREND EXPANSION
• VOL EXPANSION
• RANGE
• COMPRESSION
• TRANSITION

The regime engine uses a combination of:

• ADX
• EMA separation relative to ATR
• ATR expansion
• Bollinger Bandwidth compression

This is important because the same technical signal can behave differently depending on market conditions.

For example, repeated structure breaks occurring inside a narrow range are intentionally treated differently from breaks occurring during an established directional expansion.

BOS and CHOCH detection is therefore suppressed when the engine identifies significant range-bound or compression conditions.

---------------------------------------

https://www.tradingview.com/x/W99dxUx9/

🟢 Bullish Market Structure

Bullish structural development is identified through sequences involving:

Higher Highs and Higher Lows.

Instead of placing HH and HL text labels across the chart, the indicator represents qualifying bullish structural progression using low-opacity green gradient bands.

The bands are designed to visually communicate directional structure without covering the underlying candles.

A structural band is not automatically created for every small pivot.

The movement must satisfy configurable structure-strength and ATR-distance requirements.

This helps reduce visual noise created by minor oscillations.

---------------------------------------

https://www.tradingview.com/x/5tqqFbM1/

 🔴 Bearish Market Structure

Bearish structure is evaluated through:

Lower Highs and Lower Lows.

Qualifying bearish sequences are represented using low-opacity red gradient bands.

As with bullish structure, minor swings are filtered using structural strength and ATR-based movement requirements.

The purpose is to highlight meaningful directional structure rather than drawing every short-term fluctuation.

---------------------------------------

https://www.tradingview.com/x/GprSgHx7/

🔀 BOS and CHOCH

The indicator also tracks external market structure.

BOS = Break of Structure
CHOCH = Change of Character

These events are displayed using dashed structural break lines.

A bullish BOS generally represents continuation of bullish external structure.

A bearish BOS represents continuation of bearish external structure.

CHOCH identifies a structure break occurring against the previously established structural direction.

However, BOS and CHOCH are not treated as automatic trade signals.

They are one component of the wider market intelligence engine.

BOS/CHOCH events are also filtered when the market is classified as significantly range-bound or compressed.

This is intended to reduce repeated structure-break markings inside sideways markets.

---------------------------------------

https://www.tradingview.com/x/zLg5VWG6/

📈 Trend Engine

The default trend model uses:

Fast EMA: 21

Slow EMA: 50

A bullish trend condition requires bullish EMA alignment together with supportive price positioning.

A bearish trend condition requires bearish EMA alignment together with supportive price positioning.

The EMA ribbon provides a simple visual representation of the prevailing trend relationship.

These values are configurable.

---------------------------------------

🌐 Higher-Timeframe Confirmation

The engine can use a higher timeframe as an additional directional filter.

Higher-timeframe confirmation evaluates:

• Higher-timeframe price
• Higher-timeframe fast EMA
• Higher-timeframe slow EMA

Confirmed higher-timeframe data is used rather than the developing higher-timeframe candle.

This improves stability but introduces additional confirmation delay.

The selected higher timeframe must be greater than the chart timeframe.

For example:

15-minute chart → 1H or 4H confirmation

1H chart → 4H or Daily confirmation

Using the same or a lower timeframe as the HTF setting is intentionally prevented.

---------------------------------------

📍 VWAP / Mean Location

On intraday charts, the indicator uses session VWAP as a directional location reference.

Above VWAP supports bullish evidence.

Below VWAP supports bearish evidence.

On non-intraday charts, an EMA-based mean reference is used instead.

The purpose of this component is not to create VWAP crossover signals.

It provides context regarding where price is trading relative to an important market mean.

---------------------------------------

⚡ Momentum Engine

Momentum confirmation uses two separate measurements:

RSI

and

MACD Histogram.

The default bullish RSI threshold is above 52.

The default bearish RSI threshold is below 48.

The MACD histogram contributes additional directional momentum confirmation.

Momentum is intentionally only one component of the complete score.

A strong RSI reading by itself cannot produce a trade signal.

---------------------------------------

 📊 ADX and Directional Movement

ADX and DMI are used to evaluate trend quality.

The engine considers:

ADX strength

*

+DI / -DI directional dominance.

Bullish directional confirmation requires sufficient ADX together with +DI dominance.

Bearish directional confirmation requires sufficient ADX together with -DI dominance.

This helps differentiate directional movement from weak oscillation.

---------------------------------------

⚡ Volume Participation

Where reliable volume data is available, the engine evaluates current volume relative to its average.

Bullish participation favors increased volume accompanying bullish price movement.

Bearish participation favors increased volume accompanying bearish price movement.

Volume can also be required as part of the final signal confirmation.

For symbols where meaningful volume information is unavailable, the engine does not automatically treat missing volume as bearish or bullish confirmation.

---------------------------------------

🌡️ Volatility Analysis

ATR is used throughout the indicator as a volatility-normalized measurement.

This allows several conditions to adapt more naturally across instruments with different price scales.

ATR is used in areas including:

• Structure strength
• Swing-leg measurement
• Volatility expansion
• Structural break buffering
• Retest tolerance
• Signal positioning

The indicator also compares current ATR against a longer ATR baseline to identify volatility expansion.

---------------------------------------

📉 Compression Detection

Bollinger Bandwidth is used internally to help identify volatility compression.

The Bollinger Bands themselves are not plotted.

When bandwidth contracts materially relative to its recent baseline, the engine can classify the environment as COMPRESSION.

During these conditions, new structural signals are filtered more aggressively.

---------------------------------------

🧮 Bull and Bear Confluence Scores

The engine independently calculates bullish and bearish scores from 0 to 100.

The current weighting framework is:

Current timeframe trend — 15 points
Higher-timeframe trend — 20 points
Major market structure — 20 points
Momentum — 15 points
VWAP / mean location — 10 points
Volume participation — 10 points
ADX / directional movement — 10 points

Total possible score:
100

Bullish and bearish evidence are calculated separately.

The difference between the two scores is also evaluated.

This prevents a high bullish score from automatically being considered strong when bearish evidence is simultaneously elevated.

---------------------------------------

🎯 One Signal Per New Trend

One of the most important features of the indicator is its trend-state signal engine.

The indicator is intentionally designed NOT to print BUY or SELL signals repeatedly throughout the same trend.

Once a new bullish trend satisfies the complete confirmation framework:

BUY is generated once.

Afterward:

• Additional BOS events do not create another BUY.
• Retests do not create another BUY.
• New momentum confirmations do not create another BUY.
• Continuation candles do not create another BUY.

The bullish trend remains active until the internal trend-state engine determines that the trend has genuinely deteriorated or a confirmed bearish trend takes control.

The same principle applies to SELL signals.

This produces a sequence closer to:

Neutral → New Bull Trend → BUY → Bull Trend Active

or

Neutral → New Bear Trend → SELL → Bear Trend Active

rather than repeatedly generating signals during the same directional move.

---------------------------------------

🏷️ A and A+ Signal Grades

Signals may display an A or A+ classification.

These labels refer only to the amount of technical confluence present at the time of confirmation.

They are NOT historical win-rate statistics.

They do NOT represent a guaranteed probability of success.

A+ simply represents stronger alignment within the indicator's internal scoring framework than the standard A condition.

---------------------------------------

🔁 Trend Reset Logic

The engine does not immediately reset a trend because of one weak candle.

Instead, it tracks sustained deterioration.

The default Trend Reset Bars value is:

6 bars.

A bullish trend remains active while bullish conditions remain sufficiently healthy.

If the structure deteriorates for the required number of confirmed bars, the state returns to neutral and becomes eligible to identify a future trend.

An opposite fully confirmed trend can also transition the state directly.

This helps prevent repeated BUY → BUY → BUY or SELL → SELL → SELL signals during ordinary pullbacks.

---------------------------------------

🔄 Structural Retests

After a valid structural break, the indicator can identify a return toward the broken level.

Bullish breaks may produce an R>S RETEST.

Bearish breaks may produce an S>R RETEST.

Retests require price to return within an ATR-based tolerance and subsequently close back on the expected side of the level.

Retest labels are analytical information.

They do not independently generate another trade signal when a trend signal has already been used.

---------------------------------------

🧭 Premium, Discount and Equilibrium

The latest confirmed major swing high and major swing low are also used to estimate the active structural range.

Price is classified as:

PREMIUM

DISCOUNT

EQUILIBRIUM.

These classifications are contextual only.

They should not be interpreted as automatic reversal zones.

For example, price can remain in premium during a strong uptrend or remain in discount during a strong downtrend.

---------------------------------------

⚙️ Suggested Starting Configuration

The default settings are designed as a balanced starting point rather than universally optimal parameters.

Major Swing Length: 8
Fast EMA: 21
Slow EMA: 50
ADX Trend Threshold: 22
Minimum Signal Score: 86
Minimum Bull/Bear Advantage: 25
Trend Reset Bars: 6
Consecutive Structure Pairs: 2

Users should evaluate different settings according to the instrument, timeframe, volatility characteristics, and their own trading methodology.

Avoid changing parameters simply to improve historical appearance.

---------------------------------------

✅ How to Use the Indicator

The preferred workflow is:

1. Check Market Regime.

If RANGE or COMPRESSION is displayed, directional signals should be treated cautiously.

2. Check Bull Score vs Bear Score.

Look for meaningful separation rather than nearly equal scores.

3. Check Major Structure.

Determine whether the external structure supports the intended direction.

4. Check HTF.

Higher-timeframe agreement generally represents stronger directional alignment.

5. Observe the gradient structure bands.

These provide visual context regarding recent bullish or bearish structural progression.

6. Check price relative to VWAP / Mean.

This adds location context.

7. Wait for a confirmed new-trend signal.

Avoid anticipating the BUY or SELL before the complete engine confirms it.

8. Perform independent risk analysis.

Entry price, stop placement, targets, position size, option strike selection, and portfolio risk should be determined separately.

---------------------------------------

🚫 When to Avoid Using Signals

You should generally avoid relying heavily on directional signals when:

• Market Regime shows RANGE or COMPRESSION.
• Bull and Bear scores are very close.
• Price is reacting violently around major news.
• Liquidity is poor.
• The instrument has irregular or unreliable price/volume data.
• The chosen timeframe produces excessive market noise.
• A signal appears too close to an important external event or known gap-risk period.

No technical indicator can eliminate these market risks.

---------------------------------------

⏱️ Important Pivot Confirmation Behavior

The market-structure engine uses confirmed pivot highs and pivot lows.

A pivot cannot be confirmed until the required number of bars has formed to its right.

With a Major Swing Length of 8, for example, a major pivot requires eight subsequent bars before confirmation.

After confirmation, structural graphics can be anchored visually to the original pivot bar.

This means the historical chart can show a structural band beginning at the earlier pivot even though that pivot was not known to the indicator in real time until later.

This is an important distinction.

The structure graphics should therefore be interpreted as a confirmed historical map of market structure, NOT as proof that the swing was identifiable at the exact pivot candle.

Trade signals themselves are evaluated on confirmed bars using information available to the signal engine at that time.

---------------------------------------

🕒 Higher-Timeframe Timing

Higher-timeframe confirmation intentionally uses completed higher-timeframe information.

This reduces instability associated with using a still-forming HTF candle.

The tradeoff is confirmation delay.

For example, a strong movement can begin before the previous completed higher-timeframe candle has confirmed the same direction.

This indicator intentionally favors confirmation over immediate reaction.

---------------------------------------

🔬 What Makes This Indicator Different

The intention behind Adaptive Market Intelligence Engine is not to combine unrelated indicators simply to produce more signals.

Each component has a defined analytical role:

EMA structure → trend
HTF → broader directional context
Market structure → price-action direction
RSI / MACD → momentum
VWAP / mean → location
Volume → participation
ADX / DMI → directional trend quality
ATR → volatility normalization
Bandwidth → compression / regime
State machine → signal frequency control

The final result is therefore based on agreement between multiple categories of market evidence rather than repeated confirmation from several indicators measuring essentially the same thing.

Another important design choice is that structural information and trade signals are separated.

BOS, CHOCH, gradient structure bands, retests, support/resistance information, and dashboard states can continue updating without generating repeated BUY or SELL labels.

---------------------------------------

🛡️ Risk Notice

This indicator is intended for technical analysis and educational use.

BUY and SELL labels represent conditions produced by the indicator's internal rules. They are not guarantees of future price movement and should not be interpreted as personalized investment advice.

Markets involve risk, and technical conditions can fail.

Users should independently evaluate price structure, liquidity, volatility, position sizing, stop placement, trading costs, and event risk before making any trading decision.

Past chart behavior does not guarantee future results.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © InvestyourAsset

//@version=6
indicator("Buy-SEll with Adaptive Market Intelligence Engine", shorttitle="Adaptive Market Intelligence Engine", overlay=true, max_lines_count=500, max_labels_count=500)

//=============================================================================
// GROUPS
//=============================================================================
string GRP_TREND = "01. Trend Engine"
string GRP_STRUCTURE = "02. Structure Engine"
string GRP_REGIME = "03. Regime Filter"
string GRP_MOMENTUM = "04. Momentum Engine"
string GRP_VOLUME = "05. Participation"
string GRP_SIGNAL = "06. New Trend Signal Engine"
string GRP_VISUAL = "07. Visual Settings"

//=============================================================================
// DRAWING STORAGE
//=============================================================================
f_storeLine(array<line> ids, line lineId, int maxCount) =>
    array.push(ids, lineId)
    if array.size(ids) > maxCount
        line.delete(array.shift(ids))
    0

f_storeLabel(array<label> ids, label labelId, int maxCount) =>
    array.push(ids, labelId)
    if array.size(ids) > maxCount
        label.delete(array.shift(ids))
    0

//=============================================================================
// STRUCTURE STRENGTH
//=============================================================================
f_strength(float reactionATR, float legATR, float volumeRatio, bool htfAligned) =>
    float reactionScore = math.min(math.max(reactionATR, 0.0), 2.0) / 2.0 * 30.0
    float legScore = math.min(math.max(legATR, 0.0), 4.0) / 4.0 * 25.0
    float volumeScore = math.min(math.max(volumeRatio, 0.0), 2.0) / 2.0 * 20.0
    float htfScore = htfAligned ? 10.0 : 0.0
    float total = 15.0 + reactionScore + legScore + volumeScore + htfScore
    int(math.round(math.min(total, 100.0)))

//=============================================================================
// STRUCTURE GRADIENT BAND
//=============================================================================
f_drawStructureBand(
     array<line> lineStorage,
     int maxLines,
     int x1,
     float y1,
     int x2,
     float y2,
     float referenceATR,
     bool bullish,
     int strength,
     float widthATR,
     color bullColor,
     color bearColor,
     int coreTransparency
 ) =>

    color baseColor = bullish ? bullColor : bearColor

    int outerTransparency = coreTransparency + 8

    if outerTransparency > 99
        outerTransparency := 99

    color outerFill = color.from_gradient(
         strength,
         55,
         100,
         color.new(baseColor, 99),
         color.new(baseColor, outerTransparency)
     )

    color innerFill = color.from_gradient(
         strength,
         55,
         100,
         color.new(baseColor, 96),
         color.new(baseColor, coreTransparency)
     )

    float outerOffset = referenceATR * widthATR

    float innerOffset = outerOffset * 0.52

    line outerUpper = line.new(
         x1,
         y1 + outerOffset,
         x2,
         y2 + outerOffset,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.new(baseColor, 100),
         width=1
     )

    line outerLower = line.new(
         x1,
         y1 - outerOffset,
         x2,
         y2 - outerOffset,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.new(baseColor, 100),
         width=1
     )

    linefill.new(
         outerUpper,
         outerLower,
         outerFill
     )

    f_storeLine(
         lineStorage,
         outerUpper,
         maxLines
     )

    f_storeLine(
         lineStorage,
         outerLower,
         maxLines
     )

    line innerUpper = line.new(
         x1,
         y1 + innerOffset,
         x2,
         y2 + innerOffset,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.new(baseColor, 100),
         width=1
     )

    line innerLower = line.new(
         x1,
         y1 - innerOffset,
         x2,
         y2 - innerOffset,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.new(baseColor, 100),
         width=1
     )

    linefill.new(
         innerUpper,
         innerLower,
         innerFill
     )

    f_storeLine(
         lineStorage,
         innerUpper,
         maxLines
     )

    f_storeLine(
         lineStorage,
         innerLower,
         maxLines
     )

    0

//=============================================================================
// FRESHNESS
//=============================================================================
f_freshness(int age) =>
    string result = "AGED"

    if age <= 20
        result := "FRESH"

    else if age <= 50
        result := "ACTIVE"

    result

//=============================================================================
// TREND INPUTS
//=============================================================================
int fastLen = input.int(
     21,
     "Fast EMA",
     minval=2,
     group=GRP_TREND
 )

int slowLen = input.int(
     50,
     "Slow EMA",
     minval=3,
     group=GRP_TREND
 )

int meanLen = input.int(
     20,
     "Non-Intraday Mean EMA",
     minval=2,
     group=GRP_TREND
 )

bool useHTF = input.bool(
     true,
     "Use Higher-Timeframe Confirmation",
     group=GRP_TREND
 )

string htfTf = input.timeframe(
     "240",
     "Higher Timeframe",
     group=GRP_TREND
 )

//=============================================================================
// STRUCTURE INPUTS
//=============================================================================
int internalSwingLen = input.int(
     3,
     "Internal Swing Length",
     minval=2,
     maxval=20,
     group=GRP_STRUCTURE
 )

int majorSwingLen = input.int(
     8,
     "Major Swing Length",
     minval=4,
     maxval=50,
     group=GRP_STRUCTURE
 )

float structureBreakBuffer = input.float(
     0.05,
     "Structure Break Buffer ATR",
     minval=0.0,
     maxval=1.0,
     step=0.01,
     group=GRP_STRUCTURE
 )

int retestWindow = input.int(
     18,
     "Retest Window",
     minval=3,
     maxval=100,
     group=GRP_STRUCTURE
 )

float retestToleranceATR = input.float(
     0.18,
     "Retest Tolerance ATR",
     minval=0.02,
     maxval=1.0,
     step=0.01,
     group=GRP_STRUCTURE
 )

float retestMaxPenetrationATR = input.float(
     0.40,
     "Maximum Retest Penetration ATR",
     minval=0.05,
     maxval=2.0,
     step=0.05,
     group=GRP_STRUCTURE
 )

int minimumBandStrength = input.int(
     58,
     "Minimum Structure Band Strength",
     minval=40,
     maxval=90,
     group=GRP_STRUCTURE
 )

float minimumBandLegATR = input.float(
     0.70,
     "Minimum Band Leg Size ATR",
     minval=0.20,
     maxval=5.0,
     step=0.05,
     group=GRP_STRUCTURE
 )

float structureBandWidthATR = input.float(
     0.18,
     "Structure Band Width ATR",
     minval=0.05,
     maxval=0.60,
     step=0.01,
     group=GRP_STRUCTURE
 )

int requiredStructurePairs = input.int(
     2,
     "Consecutive Structure Pairs",
     minval=2,
     maxval=5,
     group=GRP_STRUCTURE
 )

//=============================================================================
// REGIME INPUTS
//=============================================================================
int diLen = input.int(
     14,
     "DMI Length",
     minval=2,
     group=GRP_REGIME
 )

int adxSmooth = input.int(
     14,
     "ADX Smoothing",
     minval=2,
     group=GRP_REGIME
 )

float trendAdxThreshold = input.float(
     22.0,
     "Trending ADX",
     minval=5.0,
     step=0.5,
     group=GRP_REGIME
 )

float rangeAdxThreshold = input.float(
     18.0,
     "Range ADX",
     minval=5.0,
     step=0.5,
     group=GRP_REGIME
 )

float minEmaSeparationATR = input.float(
     0.20,
     "Minimum EMA Separation / ATR",
     minval=0.01,
     maxval=2.0,
     step=0.01,
     group=GRP_REGIME
 )

float structureRegimeSeparationATR = input.float(
     0.30,
     "Structure Activation Separation / ATR",
     minval=0.01,
     maxval=2.0,
     step=0.01,
     group=GRP_REGIME
 )

int atrLen = input.int(
     14,
     "ATR Length",
     minval=2,
     group=GRP_REGIME
 )

int atrBaselineLen = input.int(
     50,
     "ATR Baseline",
     minval=10,
     group=GRP_REGIME
 )

float expansionMultiplier = input.float(
     1.10,
     "Volatility Expansion Multiplier",
     minval=1.0,
     step=0.05,
     group=GRP_REGIME
 )

int bbLen = input.int(
     20,
     "Compression Length",
     minval=5,
     group=GRP_REGIME
 )

float bbMult = input.float(
     2.0,
     "BB Deviation",
     minval=0.5,
     step=0.1,
     group=GRP_REGIME
 )

int bbBaselineLen = input.int(
     50,
     "Bandwidth Baseline",
     minval=10,
     group=GRP_REGIME
 )

float compressionMultiplier = input.float(
     0.75,
     "Compression Threshold",
     minval=0.30,
     maxval=1.00,
     step=0.05,
     group=GRP_REGIME
 )

//=============================================================================
// MOMENTUM INPUTS
//=============================================================================
int rsiLen = input.int(
     14,
     "RSI Length",
     minval=2,
     group=GRP_MOMENTUM
 )

int macdFast = input.int(
     12,
     "MACD Fast",
     minval=2,
     group=GRP_MOMENTUM
 )

int macdSlow = input.int(
     26,
     "MACD Slow",
     minval=3,
     group=GRP_MOMENTUM
 )

int macdSignalLen = input.int(
     9,
     "MACD Signal",
     minval=2,
     group=GRP_MOMENTUM
 )

//=============================================================================
// VOLUME INPUTS
//=============================================================================
bool useVolume = input.bool(
     true,
     "Use Volume",
     group=GRP_VOLUME
 )

int volumeLen = input.int(
     20,
     "Volume Average",
     minval=2,
     group=GRP_VOLUME
 )

float volumeMultiplier = input.float(
     1.0,
     "General Volume Multiplier",
     minval=0.50,
     step=0.05,
     group=GRP_VOLUME
 )

//=============================================================================
// SIGNAL INPUTS
//=============================================================================
int minimumSignalScore = input.int(
     86,
     "New Trend Minimum Score",
     minval=75,
     maxval=100,
     group=GRP_SIGNAL
 )

int minimumScoreAdvantage = input.int(
     25,
     "Minimum Bull/Bear Advantage",
     minval=10,
     maxval=60,
     group=GRP_SIGNAL
 )

bool requireHTFForSignals = input.bool(
     true,
     "Require HTF Alignment",
     group=GRP_SIGNAL
 )

bool requireVolumeForSignals = input.bool(
     true,
     "Require Participation",
     group=GRP_SIGNAL
 )

float signalVolumeMultiplier = input.float(
     1.05,
     "Signal Volume Multiplier",
     minval=0.50,
     maxval=3.0,
     step=0.05,
     group=GRP_SIGNAL
 )

int trendResetBars = input.int(
     6,
     "Trend Reset Bars",
     minval=2,
     maxval=30,
     group=GRP_SIGNAL
 )

bool requireStructureAlignment = input.bool(
     true,
     "Require Major Structure Alignment",
     group=GRP_SIGNAL
 )

bool requireStrongADX = input.bool(
     true,
     "Require Strong ADX / DMI",
     group=GRP_SIGNAL
 )

//=============================================================================
// VISUAL INPUTS
//=============================================================================
bool showTrendRibbon = input.bool(
     true,
     "EMA Trend Ribbon",
     group=GRP_VISUAL
 )

bool showMean = input.bool(
     true,
     "VWAP / Mean",
     group=GRP_VISUAL
 )

bool showStructureBands = input.bool(
     true,
     "Structure Gradient Bands",
     group=GRP_VISUAL
 )

color bullishBandColor = input.color(
     color.lime,
     "Uptrend Structure Band",
     group=GRP_VISUAL
 )

color bearishBandColor = input.color(
     color.red,
     "Downtrend Structure Band",
     group=GRP_VISUAL
 )

int bandCoreTransparency = input.int(
     87,
     "Structure Band Transparency",
     minval=70,
     maxval=96,
     group=GRP_VISUAL
 )

bool showInternalLabels = input.bool(
     false,
     "Internal Structure Labels",
     group=GRP_VISUAL
 )

bool showBreakLabels = input.bool(
     true,
     "BOS / CHOCH Labels",
     group=GRP_VISUAL
 )

bool showBreakLines = input.bool(
     true,
     "BOS / CHOCH Dashed Lines",
     group=GRP_VISUAL
 )

bool showRetests = input.bool(
     true,
     "Retest Labels",
     group=GRP_VISUAL
 )

bool colorCandles = input.bool(
     true,
     "Confluence Candle Coloring",
     group=GRP_VISUAL
 )

bool showDashboard = input.bool(
     true,
     "Market Intelligence Dashboard",
     group=GRP_VISUAL
 )

int drawingHistoryLimit = input.int(
     430,
     "Historical Drawing Lines",
     minval=100,
     maxval=470,
     group=GRP_VISUAL
 )

int labelHistoryLimit = input.int(
     250,
     "Historical Labels",
     minval=50,
     maxval=450,
     group=GRP_VISUAL
 )

//=============================================================================
// STORAGE
//=============================================================================
var array<line> historicalLines = array.new_line()

var array<label> historicalLabels = array.new_label()

//=============================================================================
// TREND ENGINE
//=============================================================================
float emaFast = ta.ema(
     close,
     fastLen
 )

float emaSlow = ta.ema(
     close,
     slowLen
 )

bool bullTrend = (
     emaFast > emaSlow and
     close > emaFast
 )

bool bearTrend = (
     emaFast < emaSlow and
     close < emaFast
 )

//=============================================================================
// HIGHER TIMEFRAME
//=============================================================================
if useHTF and timeframe.in_seconds(htfTf) <= timeframe.in_seconds(timeframe.period)
    runtime.error("Higher Timeframe must be greater than current chart timeframe.")

float htfClose = close

float htfFast = emaFast

float htfSlow = emaSlow

if useHTF

    htfClose := request.security(
         syminfo.tickerid,
         htfTf,
         close[1],
         lookahead=barmerge.lookahead_on
     )

    htfFast := request.security(
         syminfo.tickerid,
         htfTf,
         ta.ema(close, fastLen)[1],
         lookahead=barmerge.lookahead_on
     )

    htfSlow := request.security(
         syminfo.tickerid,
         htfTf,
         ta.ema(close, slowLen)[1],
         lookahead=barmerge.lookahead_on
     )

bool htfBull = (
     htfFast > htfSlow and
     htfClose > htfFast
 )

bool htfBear = (
     htfFast < htfSlow and
     htfClose < htfFast
 )

//=============================================================================
// VWAP / MEAN
//=============================================================================
float sessionVWAP = ta.vwap(hlc3)

float meanEMA = ta.ema(
     close,
     meanLen
 )

float meanLine = meanEMA

if timeframe.isintraday and not na(sessionVWAP)
    meanLine := sessionVWAP

bool aboveMean = close > meanLine

bool belowMean = close < meanLine

//=============================================================================
// MOMENTUM
//=============================================================================
float rsi = ta.rsi(
     close,
     rsiLen
 )

[macdLine, macdSignal, macdHistogram] = ta.macd(
     close,
     macdFast,
     macdSlow,
     macdSignalLen
 )

bool bullRSI = rsi > 52

bool bearRSI = rsi < 48

bool bullMACD = macdHistogram > 0

bool bearMACD = macdHistogram < 0

//=============================================================================
// VOLATILITY
//=============================================================================
float atr = ta.atr(
     atrLen
 )

float atrBaseline = ta.sma(
     atr,
     atrBaselineLen
 )

bool volatilityExpansion = (
     not na(atrBaseline) and
     atr > atrBaseline * expansionMultiplier
 )

//=============================================================================
// ADX
//=============================================================================
[plusDI, minusDI, adx] = ta.dmi(
     diLen,
     adxSmooth
 )

bool bullishADX = (
     adx >= trendAdxThreshold and
     plusDI > minusDI
 )

bool bearishADX = (
     adx >= trendAdxThreshold and
     minusDI > plusDI
 )

//=============================================================================
// COMPRESSION / REGIME
//=============================================================================
float bbBasis = ta.sma(
     close,
     bbLen
 )

float bbDeviation = ta.stdev(
     close,
     bbLen
 ) * bbMult

float bbWidth = 0.0

if bbBasis != 0

    bbWidth := (
         2.0 *
         bbDeviation /
         bbBasis
     ) * 100.0

float bbWidthBaseline = ta.sma(
     bbWidth,
     bbBaselineLen
 )

bool compression = (
     not na(bbWidthBaseline) and
     bbWidth < bbWidthBaseline * compressionMultiplier
 )

float emaSeparationATR = 0.0

if atr > 0

    emaSeparationATR := math.abs(
         emaFast -
         emaSlow
     ) / atr

bool rangeBound = (
     compression or
     (
         adx < rangeAdxThreshold and
         emaSeparationATR < minEmaSeparationATR
     )
 )

bool directionalRegime = (
     not rangeBound and
     (
         adx >= trendAdxThreshold or
         emaSeparationATR >= structureRegimeSeparationATR or
         volatilityExpansion
     )
 )

bool structureAllowed = (
     barstate.isconfirmed and
     directionalRegime and
     not rangeBound and
     not compression
 )

string marketRegime = "TRANSITION"

if compression

    marketRegime := "COMPRESSION"

else if rangeBound

    marketRegime := "RANGE"

else if directionalRegime and volatilityExpansion

    marketRegime := "TREND EXPANSION"

else if directionalRegime

    marketRegime := "TRENDING"

else if volatilityExpansion

    marketRegime := "VOL EXPANSION"

//=============================================================================
// VOLUME
//=============================================================================
float avgVolume = ta.sma(
     volume,
     volumeLen
 )

bool hasVolume = (
     not na(volume) and
     not na(avgVolume) and
     avgVolume > 0
 )

bool bullVolume = (
     hasVolume and
     volume > avgVolume * volumeMultiplier and
     close > close[1]
 )

bool bearVolume = (
     hasVolume and
     volume > avgVolume * volumeMultiplier and
     close < close[1]
 )

//=============================================================================
// INTERNAL STRUCTURE
//=============================================================================
float internalPivotHigh = ta.pivothigh(
     high,
     internalSwingLen,
     internalSwingLen
 )

float internalPivotLow = ta.pivotlow(
     low,
     internalSwingLen,
     internalSwingLen
 )

var float previousInternalHigh = na

var float previousInternalLow = na

if not na(internalPivotHigh)

    int pivotBar = bar_index - internalSwingLen

    string internalText = "iH"

    if not na(previousInternalHigh)

        if internalPivotHigh > previousInternalHigh
            internalText := "iHH"

        else
            internalText := "iLH"

    if showInternalLabels

        label internalLabel = label.new(
             pivotBar,
             internalPivotHigh,
             internalText,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_down,
             color=color.new(color.red, 88),
             textcolor=color.red,
             size=size.tiny
         )

        f_storeLabel(
             historicalLabels,
             internalLabel,
             labelHistoryLimit
         )

    previousInternalHigh := internalPivotHigh

if not na(internalPivotLow)

    int pivotBar = bar_index - internalSwingLen

    string internalText = "iL"

    if not na(previousInternalLow)

        if internalPivotLow > previousInternalLow
            internalText := "iHL"

        else
            internalText := "iLL"

    if showInternalLabels

        label internalLabel = label.new(
             pivotBar,
             internalPivotLow,
             internalText,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_up,
             color=color.new(color.green, 88),
             textcolor=color.lime,
             size=size.tiny
         )

        f_storeLabel(
             historicalLabels,
             internalLabel,
             labelHistoryLimit
         )

    previousInternalLow := internalPivotLow

//=============================================================================
// MAJOR STRUCTURE
//=============================================================================
float majorPivotHigh = ta.pivothigh(
     high,
     majorSwingLen,
     majorSwingLen
 )

float majorPivotLow = ta.pivotlow(
     low,
     majorSwingLen,
     majorSwingLen
 )

var float previousMajorHigh = na

var float previousMajorLow = na

var float lastMajorHigh = na

var float lastMajorLow = na

var int lastMajorHighBar = na

var int lastMajorLowBar = na

var int lastMajorHighStrength = 0

var int lastMajorLowStrength = 0

var float lastMajorHighATR = na

var float lastMajorLowATR = na

var bool lastMajorHighBroken = false

var bool lastMajorLowBroken = false

// High:
// 1 = HH
// -1 = LH
//
// Low:
// 1 = HL
// -1 = LL

var int lastHighType = 0

var int lastLowType = 0

//=============================================================================
// CONSECUTIVE STRUCTURE COUNTS
//
// Retained from Test 6 for dashboard / structural analysis.
// Trendline plotting has been removed.
//=============================================================================
var int bullPairCount = 0

var int bearPairCount = 0

//=============================================================================
// MAJOR HIGH
//=============================================================================
if not na(majorPivotHigh)

    int pivotBar = bar_index - majorSwingLen

    int currentHighType = 0

    if not na(previousMajorHigh)

        if majorPivotHigh > previousMajorHigh

            currentHighType := 1

        else

            currentHighType := -1

    float pivotATR = nz(
         atr[majorSwingLen],
         atr
     )

    float reactionATR = 0.0

    if pivotATR > 0

        reactionATR := math.max(
             majorPivotHigh -
             close,
             0.0
         ) / pivotATR

    float legATR = 1.0

    if not na(lastMajorLow) and pivotATR > 0

        legATR := math.abs(
             majorPivotHigh -
             lastMajorLow
         ) / pivotATR

    float volumeRatio = 1.0

    if (
         not na(avgVolume[majorSwingLen]) and
         avgVolume[majorSwingLen] > 0
     )

        volumeRatio := (
             volume[majorSwingLen] /
             avgVolume[majorSwingLen]
         )

    int strength = f_strength(
         reactionATR,
         legATR,
         volumeRatio,
         htfBear
     )

    //-------------------------------------------------------------------------
    // STRUCTURE BAND
    //-------------------------------------------------------------------------
    bool bullishSequence = (
         currentHighType == 1 and
         lastLowType == 1
     )

    bool bearishSequence = (
         currentHighType == -1 and
         lastLowType == -1
     )

    if (
         showStructureBands and
         not na(lastMajorLow) and
         not na(lastMajorLowBar) and
         (
             bullishSequence or
             bearishSequence
         )
     )

        int sequenceStrength = int(
             math.round(
                 (
                     strength +
                     lastMajorLowStrength
                 ) / 2.0
             )
         )

        float sequenceATR = pivotATR

        if not na(lastMajorLowATR)

            sequenceATR := (
                 pivotATR +
                 lastMajorLowATR
             ) / 2.0

        bool validBand = (
             sequenceStrength >= minimumBandStrength and
             legATR >= minimumBandLegATR
         )

        if validBand

            f_drawStructureBand(
                 historicalLines,
                 drawingHistoryLimit,
                 lastMajorLowBar,
                 lastMajorLow,
                 pivotBar,
                 majorPivotHigh,
                 sequenceATR,
                 bullishSequence,
                 sequenceStrength,
                 structureBandWidthATR,
                 bullishBandColor,
                 bearishBandColor,
                 bandCoreTransparency
             )

    //-------------------------------------------------------------------------
    // STRUCTURE STREAK RESET
    //-------------------------------------------------------------------------
    if currentHighType == 1

        bearPairCount := 0

    else if currentHighType == -1

        bullPairCount := 0

    //-------------------------------------------------------------------------
    // UPDATE HIGH
    //-------------------------------------------------------------------------
    lastMajorHigh := majorPivotHigh

    lastMajorHighBar := pivotBar

    lastMajorHighStrength := strength

    lastMajorHighATR := pivotATR

    lastMajorHighBroken := false

    lastHighType := currentHighType

    previousMajorHigh := majorPivotHigh

//=============================================================================
// MAJOR LOW
//=============================================================================
if not na(majorPivotLow)

    int pivotBar = bar_index - majorSwingLen

    int currentLowType = 0

    if not na(previousMajorLow)

        if majorPivotLow > previousMajorLow

            currentLowType := 1

        else

            currentLowType := -1

    float pivotATR = nz(
         atr[majorSwingLen],
         atr
     )

    float reactionATR = 0.0

    if pivotATR > 0

        reactionATR := math.max(
             close -
             majorPivotLow,
             0.0
         ) / pivotATR

    float legATR = 1.0

    if not na(lastMajorHigh) and pivotATR > 0

        legATR := math.abs(
             lastMajorHigh -
             majorPivotLow
         ) / pivotATR

    float volumeRatio = 1.0

    if (
         not na(avgVolume[majorSwingLen]) and
         avgVolume[majorSwingLen] > 0
     )

        volumeRatio := (
             volume[majorSwingLen] /
             avgVolume[majorSwingLen]
         )

    int strength = f_strength(
         reactionATR,
         legATR,
         volumeRatio,
         htfBull
     )

    //-------------------------------------------------------------------------
    // STRUCTURE BAND
    //-------------------------------------------------------------------------
    bool bullishSequence = (
         currentLowType == 1 and
         lastHighType == 1
     )

    bool bearishSequence = (
         currentLowType == -1 and
         lastHighType == -1
     )

    if (
         showStructureBands and
         not na(lastMajorHigh) and
         not na(lastMajorHighBar) and
         (
             bullishSequence or
             bearishSequence
         )
     )

        int sequenceStrength = int(
             math.round(
                 (
                     strength +
                     lastMajorHighStrength
                 ) / 2.0
             )
         )

        float sequenceATR = pivotATR

        if not na(lastMajorHighATR)

            sequenceATR := (
                 pivotATR +
                 lastMajorHighATR
             ) / 2.0

        bool validBand = (
             sequenceStrength >= minimumBandStrength and
             legATR >= minimumBandLegATR
         )

        if validBand

            f_drawStructureBand(
                 historicalLines,
                 drawingHistoryLimit,
                 lastMajorHighBar,
                 lastMajorHigh,
                 pivotBar,
                 majorPivotLow,
                 sequenceATR,
                 bullishSequence,
                 sequenceStrength,
                 structureBandWidthATR,
                 bullishBandColor,
                 bearishBandColor,
                 bandCoreTransparency
             )

    //-------------------------------------------------------------------------
    // COMPLETE STRUCTURE PAIRS
    //-------------------------------------------------------------------------
    bool completedBullPair = (
         currentLowType == 1 and
         lastHighType == 1
     )

    bool completedBearPair = (
         currentLowType == -1 and
         lastHighType == -1
     )

    if completedBullPair

        bearPairCount := 0

        bullPairCount += 1

    else if completedBearPair

        bullPairCount := 0

        bearPairCount += 1

    else

        if currentLowType == -1
            bullPairCount := 0

        if currentLowType == 1
            bearPairCount := 0

    //-------------------------------------------------------------------------
    // UPDATE LOW
    //-------------------------------------------------------------------------
    lastMajorLow := majorPivotLow

    lastMajorLowBar := pivotBar

    lastMajorLowStrength := strength

    lastMajorLowATR := pivotATR

    lastMajorLowBroken := false

    lastLowType := currentLowType

    previousMajorLow := majorPivotLow

//=============================================================================
// BOS / CHOCH
//=============================================================================
var int externalStructureDirection = 0

bool bullBreak = false

bool bearBreak = false

bool bullBOS = false

bool bearBOS = false

bool bullCHOCH = false

bool bearCHOCH = false

bool bullishBreakCandidate = (
     not na(lastMajorHigh) and
     not lastMajorHighBroken and
     close >
     lastMajorHigh +
     atr * structureBreakBuffer
 )

bool bearishBreakCandidate = (
     not na(lastMajorLow) and
     not lastMajorLowBroken and
     close <
     lastMajorLow -
     atr * structureBreakBuffer
 )

if structureAllowed and bullishBreakCandidate

    bullBreak := true

    bullCHOCH := externalStructureDirection == -1

    bullBOS := externalStructureDirection != -1

    lastMajorHighBroken := true

if structureAllowed and bearishBreakCandidate

    bearBreak := true

    bearCHOCH := externalStructureDirection == 1

    bearBOS := externalStructureDirection != 1

    lastMajorLowBroken := true

//=============================================================================
// BREAK / RETEST STATE
//=============================================================================
var float lastBullBreakLevel = na

var float lastBearBreakLevel = na

var int lastBullBreakBar = na

var int lastBearBreakBar = na

var bool bullRetestConsumed = true

var bool bearRetestConsumed = true

//=============================================================================
// BULL BOS / CHOCH
//=============================================================================
if bullBreak

    string breakText = bullCHOCH ? "CHOCH" : "BOS"

    color breakColor = bullCHOCH ? color.aqua : color.lime

    if showBreakLines

        line breakLine = line.new(
             lastMajorHighBar,
             lastMajorHigh,
             bar_index,
             lastMajorHigh,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=color.new(breakColor, 20),
             style=line.style_dashed,
             width=2
         )

        f_storeLine(
             historicalLines,
             breakLine,
             drawingHistoryLimit
         )

    if showBreakLabels

        label breakLabel = label.new(
             bar_index,
             lastMajorHigh,
             breakText,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_up,
             color=color.new(breakColor, 15),
             textcolor=color.white,
             size=size.small
         )

        f_storeLabel(
             historicalLabels,
             breakLabel,
             labelHistoryLimit
         )

    lastBullBreakLevel := lastMajorHigh

    lastBullBreakBar := bar_index

    bullRetestConsumed := false

    bearRetestConsumed := true

    externalStructureDirection := 1

//=============================================================================
// BEAR BOS / CHOCH
//=============================================================================
if bearBreak

    string breakText = bearCHOCH ? "CHOCH" : "BOS"

    color breakColor = bearCHOCH ? color.orange : color.red

    if showBreakLines

        line breakLine = line.new(
             lastMajorLowBar,
             lastMajorLow,
             bar_index,
             lastMajorLow,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=color.new(breakColor, 20),
             style=line.style_dashed,
             width=2
         )

        f_storeLine(
             historicalLines,
             breakLine,
             drawingHistoryLimit
         )

    if showBreakLabels

        label breakLabel = label.new(
             bar_index,
             lastMajorLow,
             breakText,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_down,
             color=color.new(breakColor, 15),
             textcolor=color.white,
             size=size.small
         )

        f_storeLabel(
             historicalLabels,
             breakLabel,
             labelHistoryLimit
         )

    lastBearBreakLevel := lastMajorLow

    lastBearBreakBar := bar_index

    bearRetestConsumed := false

    bullRetestConsumed := true

    externalStructureDirection := -1

//=============================================================================
// RETEST
//=============================================================================
bool bullRetest = false

bool bearRetest = false

bool bullRetestWindowActive = (
     not na(lastBullBreakBar) and
     bar_index > lastBullBreakBar and
     bar_index <= lastBullBreakBar + retestWindow
 )

bool bearRetestWindowActive = (
     not na(lastBearBreakBar) and
     bar_index > lastBearBreakBar and
     bar_index <= lastBearBreakBar + retestWindow
 )

bool bullRetestTouch = (
     bullRetestWindowActive and
     not bullRetestConsumed and
     low <=
     lastBullBreakLevel +
     atr * retestToleranceATR and
     low >=
     lastBullBreakLevel -
     atr * retestMaxPenetrationATR
 )

bool bearRetestTouch = (
     bearRetestWindowActive and
     not bearRetestConsumed and
     high >=
     lastBearBreakLevel -
     atr * retestToleranceATR and
     high <=
     lastBearBreakLevel +
     atr * retestMaxPenetrationATR
 )

if (
     barstate.isconfirmed and
     not rangeBound and
     bullRetestTouch and
     close > lastBullBreakLevel and
     close > open
 )

    bullRetest := true

    bullRetestConsumed := true

if (
     barstate.isconfirmed and
     not rangeBound and
     bearRetestTouch and
     close < lastBearBreakLevel and
     close < open
 )

    bearRetest := true

    bearRetestConsumed := true

if bullRetest and showRetests

    label retestLabel = label.new(
         bar_index,
         low,
         "R>S\nRETEST",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_up,
         color=color.new(color.green, 30),
         textcolor=color.white,
         size=size.tiny
     )

    f_storeLabel(
         historicalLabels,
         retestLabel,
         labelHistoryLimit
     )

if bearRetest and showRetests

    label retestLabel = label.new(
         bar_index,
         high,
         "S>R\nRETEST",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_down,
         color=color.new(color.red, 30),
         textcolor=color.white,
         size=size.tiny
     )

    f_storeLabel(
         historicalLabels,
         retestLabel,
         labelHistoryLimit
     )

//=============================================================================
// MAJOR RANGE
//=============================================================================
bool validMajorRange = (
     not na(lastMajorHigh) and
     not na(lastMajorLow) and
     lastMajorHigh > lastMajorLow
 )

float majorRange = na

float equilibrium = na

float equilibriumTolerance = na

if validMajorRange

    majorRange := (
         lastMajorHigh -
         lastMajorLow
     )

    equilibrium := (
         lastMajorHigh +
         lastMajorLow
     ) / 2.0

    equilibriumTolerance := (
         majorRange *
         0.05
     )

string rangeLocation = "N/A"

if validMajorRange

    if close > equilibrium + equilibriumTolerance

        rangeLocation := "PREMIUM"

    else if close < equilibrium - equilibriumTolerance

        rangeLocation := "DISCOUNT"

    else

        rangeLocation := "EQUILIBRIUM"

//=============================================================================
// STRUCTURE STATE
//=============================================================================
bool bullishStructure = externalStructureDirection == 1

bool bearishStructure = externalStructureDirection == -1

//=============================================================================
// CONFLUENCE SCORE
//=============================================================================
int bullTrendPoints = bullTrend ? 15 : 0

int bearTrendPoints = bearTrend ? 15 : 0

int bullHTFPoints = htfBull ? 20 : 0

int bearHTFPoints = htfBear ? 20 : 0

int bullStructurePoints = bullishStructure ? 20 : 0

int bearStructurePoints = bearishStructure ? 20 : 0

int bullMomentumPoints = 0

if bullRSI
    bullMomentumPoints += 10

if bullMACD
    bullMomentumPoints += 5

int bearMomentumPoints = 0

if bearRSI
    bearMomentumPoints += 10

if bearMACD
    bearMomentumPoints += 5

int bullLocationPoints = aboveMean ? 10 : 0

int bearLocationPoints = belowMean ? 10 : 0

int bullVolumePoints = 5

int bearVolumePoints = 5

if useVolume and hasVolume

    bullVolumePoints := bullVolume ? 10 : 0

    bearVolumePoints := bearVolume ? 10 : 0

int bullRegimePoints = bullishADX ? 10 : 0

int bearRegimePoints = bearishADX ? 10 : 0

int bullScore = (
     bullTrendPoints +
     bullHTFPoints +
     bullStructurePoints +
     bullMomentumPoints +
     bullLocationPoints +
     bullVolumePoints +
     bullRegimePoints
 )

int bearScore = (
     bearTrendPoints +
     bearHTFPoints +
     bearStructurePoints +
     bearMomentumPoints +
     bearLocationPoints +
     bearVolumePoints +
     bearRegimePoints
 )

int scoreDifference = (
     bullScore -
     bearScore
 )

//=============================================================================
// MARKET BIAS
//=============================================================================
string marketBias = "NEUTRAL"

if scoreDifference >= 35

    marketBias := "STRONG BULLISH"

else if scoreDifference >= 15

    marketBias := "BULLISH"

else if scoreDifference <= -35

    marketBias := "STRONG BEARISH"

else if scoreDifference <= -15

    marketBias := "BEARISH"

//=============================================================================
// SIGNAL FILTERS
//=============================================================================
bool bullHTFSignalOK = true

bool bearHTFSignalOK = true

if requireHTFForSignals and useHTF

    bullHTFSignalOK := htfBull

    bearHTFSignalOK := htfBear

bool bullParticipationOK = true

bool bearParticipationOK = true

if requireVolumeForSignals and useVolume and hasVolume

    bullParticipationOK := (
         volume >=
         avgVolume *
         signalVolumeMultiplier and
         close > open
     )

    bearParticipationOK := (
         volume >=
         avgVolume *
         signalVolumeMultiplier and
         close < open
     )

bool bullStructureOK = true

bool bearStructureOK = true

if requireStructureAlignment

    bullStructureOK := bullishStructure

    bearStructureOK := bearishStructure

bool bullADXOK = true

bool bearADXOK = true

if requireStrongADX

    bullADXOK := bullishADX

    bearADXOK := bearishADX

//=============================================================================
// CONFIRMED TREND
//=============================================================================
bool confirmedBullTrend = (
     barstate.isconfirmed and
     not rangeBound and
     not compression and
     directionalRegime and
     bullTrend and
     aboveMean and
     bullHTFSignalOK and
     bullStructureOK and
     bullADXOK and
     bullParticipationOK and
     bullScore >= minimumSignalScore and
     scoreDifference >= minimumScoreAdvantage
 )

bool confirmedBearTrend = (
     barstate.isconfirmed and
     not rangeBound and
     not compression and
     directionalRegime and
     bearTrend and
     belowMean and
     bearHTFSignalOK and
     bearStructureOK and
     bearADXOK and
     bearParticipationOK and
     bearScore >= minimumSignalScore and
     scoreDifference <= -minimumScoreAdvantage
 )

//=============================================================================
// ONE SIGNAL PER TREND
//=============================================================================
var int trendState = 0

var int trendFailureCount = 0

bool newBullTrend = false

bool newBearTrend = false

if barstate.isconfirmed

    if trendState == 0

        trendFailureCount := 0

        if confirmedBullTrend

            trendState := 1

            newBullTrend := true

        else if confirmedBearTrend

            trendState := -1

            newBearTrend := true

    else if trendState == 1

        if confirmedBearTrend

            trendState := -1

            trendFailureCount := 0

            newBearTrend := true

        else

            bool bullTrendStillHealthy = (
                 bullTrend and
                 not rangeBound and
                 not compression and
                 scoreDifference > 0
             )

            if bullTrendStillHealthy

                trendFailureCount := 0

            else

                trendFailureCount += 1

            if trendFailureCount >= trendResetBars

                trendState := 0

                trendFailureCount := 0

    else if trendState == -1

        if confirmedBullTrend

            trendState := 1

            trendFailureCount := 0

            newBullTrend := true

        else

            bool bearTrendStillHealthy = (
                 bearTrend and
                 not rangeBound and
                 not compression and
                 scoreDifference < 0
             )

            if bearTrendStillHealthy

                trendFailureCount := 0

            else

                trendFailureCount += 1

            if trendFailureCount >= trendResetBars

                trendState := 0

                trendFailureCount := 0

//=============================================================================
// SIGNAL QUALITY
//=============================================================================
string bullSignalGrade = "A"

string bearSignalGrade = "A"

if (
     bullScore >= 92 and
     scoreDifference >= 35
 )

    bullSignalGrade := "A+"

if (
     bearScore >= 92 and
     scoreDifference <= -35
 )

    bearSignalGrade := "A+"

//=============================================================================
// BUY SIGNAL
//=============================================================================
if newBullTrend

    color signalColor = color.green

    if bullSignalGrade == "A+"

        signalColor := color.lime

    string signalText = (
         bullSignalGrade +
         " BUY\nNEW TREND"
     )

    label buyLabel = label.new(
         bar_index,
         low - atr * 0.25,
         signalText,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_up,
         color=signalColor,
         textcolor=color.white,
         size=size.normal
     )

    f_storeLabel(
         historicalLabels,
         buyLabel,
         labelHistoryLimit
     )

//=============================================================================
// SELL SIGNAL
//=============================================================================
if newBearTrend

    color signalColor = color.maroon

    if bearSignalGrade == "A+"

        signalColor := color.red

    string signalText = (
         bearSignalGrade +
         " SELL\nNEW TREND"
     )

    label sellLabel = label.new(
         bar_index,
         high + atr * 0.25,
         signalText,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_down,
         color=signalColor,
         textcolor=color.white,
         size=size.normal
     )

    f_storeLabel(
         historicalLabels,
         sellLabel,
         labelHistoryLimit
     )

//=============================================================================
// EMA TREND RIBBON
//=============================================================================
color fastColor = color.gray

color slowColor = color.gray

color ribbonColor = color.new(
     color.gray,
     94
 )

if bullTrend

    fastColor := color.lime

    slowColor := color.new(
         color.green,
         10
     )

    ribbonColor := color.new(
         color.lime,
         89
     )

else if bearTrend

    fastColor := color.red

    slowColor := color.new(
         color.red,
         10
     )

    ribbonColor := color.new(
         color.red,
         89
     )

fastPlot = plot(
     showTrendRibbon ? emaFast : na,
     "Fast EMA",
     color=fastColor,
     linewidth=1
 )

slowPlot = plot(
     showTrendRibbon ? emaSlow : na,
     "Slow EMA",
     color=slowColor,
     linewidth=2
 )

fill(
     fastPlot,
     slowPlot,
     color=showTrendRibbon ? ribbonColor : na,
     title="Adaptive Trend Ribbon"
 )

//=============================================================================
// VWAP / MEAN
//=============================================================================
plot(
     showMean ? meanLine : na,
     "VWAP / Mean",
     color=color.new(color.blue, 20),
     linewidth=2
 )

//=============================================================================
// TEST 6 CANDLE COLORING
//=============================================================================
color candleColor = color.from_gradient(
     scoreDifference,
     -100,
     100,
     color.red,
     color.lime
 )

barcolor(
     colorCandles ?
     color.new(candleColor, 48) :
     na
 )

//=============================================================================
// DASHBOARD VALUES
//=============================================================================
int resistanceAge = 9999

if not na(lastMajorHighBar)
    resistanceAge := bar_index - lastMajorHighBar

int supportAge = 9999

if not na(lastMajorLowBar)
    supportAge := bar_index - lastMajorLowBar

string resistanceFreshness = f_freshness(
     resistanceAge
 )

string supportFreshness = f_freshness(
     supportAge
 )

string structureText = "UNDEFINED"

color structureTextColor = color.gray

if bullishStructure

    structureText := "BULLISH"

    structureTextColor := color.lime

else if bearishStructure

    structureText := "BEARISH"

    structureTextColor := color.red

//=============================================================================
// STRUCTURE BUILD
//=============================================================================
string sequenceText = "MIXED"

color sequenceColor = color.gray

if bullPairCount >= requiredStructurePairs

    sequenceText := (
         "BULL x" +
         str.tostring(bullPairCount)
     )

    sequenceColor := color.lime

else if bearPairCount >= requiredStructurePairs

    sequenceText := (
         "BEAR x" +
         str.tostring(bearPairCount)
     )

    sequenceColor := color.red

else if bullPairCount > 0

    sequenceText := (
         "BULL BUILD " +
         str.tostring(bullPairCount) +
         "/" +
         str.tostring(requiredStructurePairs)
     )

    sequenceColor := color.green

else if bearPairCount > 0

    sequenceText := (
         "BEAR BUILD " +
         str.tostring(bearPairCount) +
         "/" +
         str.tostring(requiredStructurePairs)
     )

    sequenceColor := color.maroon

//=============================================================================
// HTF
//=============================================================================
string htfText = "NEUTRAL"

color htfTextColor = color.gray

if htfBull

    htfText := "BULLISH"

    htfTextColor := color.lime

else if htfBear

    htfText := "BEARISH"

    htfTextColor := color.red

//=============================================================================
// TREND STATE
//=============================================================================
string trendStateText = "NEUTRAL / ARMED"

color trendStateColor = color.orange

if trendState == 1

    trendStateText := "BULL TREND ACTIVE"

    trendStateColor := color.lime

else if trendState == -1

    trendStateText := "BEAR TREND ACTIVE"

    trendStateColor := color.red

//=============================================================================
// SIGNAL STATE
//=============================================================================
string signalState = "WAIT"

color signalStateColor = color.orange

if rangeBound or compression

    signalState := "WAIT - RANGE"

else if trendState == 1

    signalState := "BUY USED"

    signalStateColor := color.lime

else if trendState == -1

    signalState := "SELL USED"

    signalStateColor := color.red

else if confirmedBullTrend

    signalState := "BULL START READY"

    signalStateColor := color.lime

else if confirmedBearTrend

    signalState := "BEAR START READY"

    signalStateColor := color.red

//=============================================================================
// BIAS COLOR
//=============================================================================
color biasColor = color.new(
     color.gray,
     75
 )

if (
     marketBias == "STRONG BULLISH" or
     marketBias == "BULLISH"
 )

    biasColor := color.new(
         color.green,
         70
     )

else if (
     marketBias == "STRONG BEARISH" or
     marketBias == "BEARISH"
 )

    biasColor := color.new(
         color.red,
         70
     )

//=============================================================================
// REGIME COLOR
//=============================================================================
color regimeColor = color.new(
     color.gray,
     75
 )

if (
     marketRegime == "RANGE" or
     marketRegime == "COMPRESSION"
 )

    regimeColor := color.new(
         color.orange,
         65
     )

else if marketRegime == "TREND EXPANSION"

    regimeColor := color.new(
         color.blue,
         55
     )

//=============================================================================
// CURRENT LEVELS
//=============================================================================
string resistanceText = "N/A"

if not na(lastMajorHigh)

    resistanceText := (
         str.tostring(
             lastMajorHigh,
             format.mintick
         ) +
         " | " +
         str.tostring(
             lastMajorHighStrength
         ) +
         " | " +
         resistanceFreshness
     )

string supportText = "N/A"

if not na(lastMajorLow)

    supportText := (
         str.tostring(
             lastMajorLow,
             format.mintick
         ) +
         " | " +
         str.tostring(
             lastMajorLowStrength
         ) +
         " | " +
         supportFreshness
     )

//=============================================================================
// DASHBOARD
//=============================================================================
var table dashboard = table.new(
     position.top_right,
     2,
     13,
     border_width=1
 )

if barstate.islast and showDashboard

    table.cell(
         dashboard,
         0,
         0,
         "MARKET ENGINE",
         text_color=color.white,
         bgcolor=color.new(color.black, 10)
     )

    table.cell(
         dashboard,
         1,
         0,
         "TEST 6",
         text_color=color.white,
         bgcolor=color.new(color.black, 10)
     )

    table.cell(
         dashboard,
         0,
         1,
         "Regime",
         text_color=color.white
     )

    table.cell(
         dashboard,
         1,
         1,
         marketRegime,
         text_color=color.white,
         bgcolor=regimeColor
     )

    table.cell(
         dashboard,
         0,
         2,
         "Bias",
         text_color=color.white
     )

    table.cell(
         dashboard,
         1,
         2,
         marketBias,
         text_color=color.white,
         bgcolor=biasColor
     )

    table.cell(
         dashboard,
         0,
         3,
         "Trend State",
         text_color=color.white
     )

    table.cell(
         dashboard,
         1,
         3,
         trendStateText,
         text_color=trendStateColor
     )

    table.cell(
         dashboard,
         0,
         4,
         "Structure Build",
         text_color=color.white
     )

    table.cell(
         dashboard,
         1,
         4,
         sequenceText,
         text_color=sequenceColor
     )

    table.cell(
         dashboard,
         0,
         5,
         "Bull Score",
         text_color=color.white
     )

    table.cell(
         dashboard,
         1,
         5,
         str.tostring(bullScore) + "/100",
         text_color=color.lime
     )

    table.cell(
         dashboard,
         0,
         6,
         "Bear Score",
         text_color=color.white
     )

    table.cell(
         dashboard,
         1,
         6,
         str.tostring(bearScore) + "/100",
         text_color=color.red
     )

    table.cell(
         dashboard,
         0,
         7,
         "Major Structure",
         text_color=color.white
     )

    table.cell(
         dashboard,
         1,
         7,
         structureText,
         text_color=structureTextColor
     )

    table.cell(
         dashboard,
         0,
         8,
         "HTF",
         text_color=color.white
     )

    table.cell(
         dashboard,
         1,
         8,
         htfText,
         text_color=htfTextColor
     )

    table.cell(
         dashboard,
         0,
         9,
         "Resistance",
         text_color=color.white
     )

    table.cell(
         dashboard,
         1,
         9,
         resistanceText,
         text_color=color.red
     )

    table.cell(
         dashboard,
         0,
         10,
         "Support",
         text_color=color.white
     )

    table.cell(
         dashboard,
         1,
         10,
         supportText,
         text_color=color.lime
     )

    color rangeTextColor = color.gray

    if rangeLocation == "DISCOUNT"

        rangeTextColor := color.lime

    else if rangeLocation == "PREMIUM"

        rangeTextColor := color.orange

    table.cell(
         dashboard,
         0,
         11,
         "Range Location",
         text_color=color.white
     )

    table.cell(
         dashboard,
         1,
         11,
         rangeLocation,
         text_color=rangeTextColor
     )

    table.cell(
         dashboard,
         0,
         12,
         "Signal State",
         text_color=color.white
     )

    table.cell(
         dashboard,
         1,
         12,
         signalState,
         text_color=signalStateColor
     )

//=============================================================================
// ALERTS
//=============================================================================
alertcondition(
     newBullTrend,
     "AMIE New Bull Trend",
     "AMIE Test 6: New high-quality bullish trend confirmed."
 )

alertcondition(
     newBearTrend,
     "AMIE New Bear Trend",
     "AMIE Test 6: New high-quality bearish trend confirmed."
 )
````
