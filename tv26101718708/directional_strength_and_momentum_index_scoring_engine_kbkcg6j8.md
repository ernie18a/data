# Directional Strength and Momentum Index - Scoring Engine

- url: https://www.tradingview.com/script/KbKCg6J8/
- type: indicator
- pine_id: PUB;9bd35c33c9cf40f5b603be3db270fc42
- version: 1.0

## Description

█ OVERVIEW
Directional Strength and Momentum Index - Scoring Engine is an indicator designed to analyze market strength and directional bias.
It is a technical analysis tool inspired by the classic DMI. Unlike the standard approach based on DM+/DM− values calculated directly from high/low differences, this indicator uses an alternative methodology built on candle size relationships (body or full range), candle direction, and EMA smoothing. As a result, price impulses are weighted differently, allowing for a more flexible interpretation of trend phases, consolidation, and market volatility.

Directional Strength and Momentum Index - Scoring Engine is an advanced evolution of the earlier Directional Strength and Momentum Index version. The new release expands the original concept with a multi-factor scoring system, an additional signal confirmation layer (secondary confirmation), TP/SL management features, and an advanced analytical dashboard.

█ CONCEPTS
The indicator was designed as an expansion of the earlier, simpler DSMI version in order to fully utilize its analytical potential.
The added components do not change the core concept of the model, but extend it with additional analytical dimensions and greater flexibility in signal construction.

The expanded scoring system allows users to freely shape signal-generation logic by modifying weights, filters, and entry conditions, making the indicator adaptable to different trading styles and markets.

The introduction of secondary DSMI and secondary DS adds an additional confirmation layer that enables:
• better filtering of false signals
• evaluation of momentum consistency across multiple levels
• more precise differentiation between impulse and correction phases
As a result, the final version of the indicator becomes a multi-layered market strength and momentum analysis system, where each layer serves a distinct and complementary role.

DSMI Core
The main market strength index on a 0–100 scale.
• measures the current level of buying or selling dominance (market state)
• based on the relationship between cumulative bullish and bearish movement strength
• EMA-smoothed to reduce noise
• defines the core market regime (weak / moderate / strong)
• serves as the foundation of the entire scoring system
DSMI Core describes “where market strength currently is” (state / level).

Directional Strength (+DS / -DS)
A layer describing real-time market pressure.
• +DS = bullish movement strength
• -DS = bearish movement strength
• dependent on candle direction and size (body or full range)
• EMA-smoothed
• determines which side of the market currently dominates price expansion
DS describes the structure of buying/selling dominance within candle flow.

Momentum Layer
A layer describing the dynamics of market strength changes (DSMI slope / velocity).
• rising DSMI = accelerating dominance of one market side
• falling DSMI = weakening or fading trend strength
• secondary DSMI = additional confirmation of momentum changes
• DS changes indicate acceleration or weakening of impulse strength
The Momentum Layer describes “how market strength changes” (velocity / rate of change).

Scoring Engine
A point-based system evaluating the quality of potential trading signals.
Each component adds or subtracts points:
• trend strength (weak / moderate / strong DSMI regime)
• DSMI momentum (rising / falling confirmation)
• DS expansion (+DS / -DS growth)
• SMA alignment
• candle size relative to volatility
• extreme DS values (overextension)
• trend weakening (DSMI or DS weakening)
• secondary confirmation layer
The final result is a weighted score calculated separately for LONG and SHORT setups (0–100).

█ FEATURES
DSMI Parameters
• calculation source (Body Only / Full Range)
• DSMI signal length
• secondary DSMI length

DSMI Display
• main DSMI line (trend strength)
• optional secondary DSMI line
• color changes based on market direction

DS Lines
• +DS (buying pressure)
• -DS (selling pressure)
• secondary DS as confirmation
• strength relationship visualization (fill between lines)

Trend Strength Levels
• weak / moderate / strong
• defined by DSMI thresholds
• determine when scoring can activate signals

Neutral Zones
• neutral +DS / -DS range
• area of no clear market dominance
• filters directionless movement and low volatility
• configurable levels such as 40/60
• within this range, both the oscillator and candles may be colored gray (or another selected color) to indicate the absence of directional dominance, often associated with consolidation or low-activity phases

Extreme Zones
• extreme DS value levels
• visual overbought / oversold bands
• detection of excessive price expansion
• changing band levels affects the width of the area where scoring penalties are applied for entries into extreme zones

Scoring Signals
• LONG / SHORT signals generated by the scoring engine
• activated after exceeding a threshold
• candle direction filter
• signals represent movement quality, not automatic trade execution decisions

Scoring Weights
• trend strength
• momentum
• DS expansion
• SMA alignment
• candle size vs volatility
• penalties for weakening conditions and extremes
• secondary confirmation

█ APPLICATIONS
1. Trend Following
The primary application is trading in trending market environments where DSMI and DS maintain directional consistency without chaotic dominance shifts.
The key is observing whether DSMI and +DS / -DS move in the same direction and maintain matching color structure. Such conditions indicate stable market-side dominance and may be used as:
• a trend-quality filter
• confirmation for signals from other systems
• context for entries based on price action and market structure

2. Momentum Trading
The system helps evaluate whether a move is genuinely gaining strength or merely producing corrective fluctuations.
• rising DSMI + rising DS = increasing momentum
• falling DSMI + falling DS = fading movement strength
This makes it easier to distinguish impulsive moves from corrections.

3. Consolidation Filtering
With neutral zones configured, for example at 40/60:
• DSMI remains within the middle range
• +DS and -DS stay balanced
• no clear market dominance exists

Under such conditions:
• the market often enters consolidation
• volatility becomes limited
• scoring signals naturally become less frequent and more selective

4. Scoring-Based Entries (Primary Use Case)
Entries are generated exclusively by the scoring engine, but their interpretation should always consider overall market context.
Signals should be filtered using:
• support and resistance levels
• Fibonacci zones
• pivot points
• order blocks
• market structure and liquidity
• potential exhaustion after impulsive moves
The best entries occur when:
• the scoring value is high
• there is no nearby major support/resistance zone
• other tools do not indicate movement exhaustion

█ NOTES
The indicator performs best after DSMI, DS, and scoring parameters are adjusted to fit the user’s strategy and market conditions.

It is recommended to use the indicator together with other technical analysis tools such as Fibonacci levels, order blocks, pivot points, and RSI.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator('Directional Strength and Momentum Index — Scoring Engine', shorttitle='DSMI-SE', overlay=false, max_bars_back=500, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// INPUTS DSMI
dmSource = input.string("Full Range (Body + Wicks)", "DM Calculation Source",
     options=["Body Only", "Full Range (Body + Wicks)"],
     group='DSMI Parameters',
     tooltip="Defines which candle component is used for Directional Movement calculations.\n\n• Body Only → uses candle bodies only.\n• Full Range (Body + Wicks) → includes full candle range (high-low), making the indicator more sensitive to volatility and wick activity.")
lenSignal = input.int(20, '1. Signal DSMI Length',
     minval=1,
     group='DSMI Parameters',
     tooltip="Main DSMI smoothing length.\n\nHigher values produce smoother and more stable trend readings.\nLower values react faster to short-term momentum changes.")
lenSecondary = input.int(10, '2. Secondary DSMI Length',
     minval=1,
     group='DSMI Parameters',
     tooltip="Secondary DSMI length used for additional momentum confirmation and scoring logic.\n\nTypically set lower than the main DSMI length for faster reaction.")
showSignalLine = input.bool(true, 'Show 1. Signal DSMI Line',
     group='DSMI Parameters',
     tooltip="Displays the primary DSMI trend strength line.")
showSecondaryLine = input.bool(false, 'Show 2. Secondary DSMI Line',
     group='DSMI Parameters',
     tooltip="Displays the secondary DSMI line used for additional momentum analysis.")
dsmiSignalColor = input.color(color.rgb(236, 213, 7), '1. Signal Line Color',
     group='DSMI Parameters',
     tooltip="Color of the primary DSMI line.")
dsmiSecondaryColor = input.color(color.new(color.rgb(236, 213, 7), 10), '2. Secondary Line Color',
     group='DSMI Parameters',
     tooltip="Color of the secondary DSMI line.")

// DS LINES DISPLAY
showDSSignal = input.bool(true, 'Show 1. Signal +DS / -DS',
     group='DS Lines Display',
     tooltip="Displays the primary directional strength components:\n\n• +DS → bullish directional strength\n• -DS → bearish directional strength")
showDSSecondary = input.bool(false, 'Show 2. Secondary +DS / -DS',
     group='DS Lines Display',
     tooltip="Displays the secondary directional strength components calculated from the secondary DSMI length.")

// SCORING Signals
showEntrySignal = input.bool(true, 'Show Entry Highlight',
     group='Scoring Signals',
     tooltip="Highlights candles where the scoring engine reaches the required entry threshold.")
entryThreshold = input.int(70, "Minimal Score Threshold (Entry)",
     minval=30,
     maxval=100,
     group='Scoring Signals',
     tooltip="Minimum score required to trigger a LONG or SHORT entry signal.\n\nHigher values create stricter and more selective signals.")
showTriangleSignals = input.bool(true, 'Show Triangle Signals',
     group='Scoring Signals',
     tooltip="Displays triangle entry signals on the chart.")
signalSizeStr = input.string("Small", title = "Signal triangle size",
     options = ["Tiny", "Small", "Normal"],
     group = 'Scoring Signals',
     tooltip="Size of the triangle entry signals.")

// SCORING WEIGHTS
groupWeights = 'Scoring Weights'
trendWeakBonus = input.int(5, "Weak Trend Bonus (DSMI > weak_thr)",
     minval=0,
     group=groupWeights,
     tooltip="Score bonus awarded when DSMI rises above the weak trend threshold.")
trendModerateBonus = input.int(15, "Moderate Trend Bonus (DSMI > neutral_thr)",
     minval=0,
     group=groupWeights,
     tooltip="Additional score bonus awarded when DSMI confirms a moderate trend environment.")
trendStrongBonus = input.int(10, "Strong Trend Bonus (DSMI > strong_thr)",
     minval=0,
     group=groupWeights,
     tooltip="Additional score bonus awarded when DSMI confirms a strong trend environment.")
momentumBonus = input.int(15, "Momentum Bonus (DSMI Rising/Falling)",
     minval=0,
     group=groupWeights,
     tooltip="Additional score awarded when DSMI momentum strengthens in the direction of the current trend.")
dsExpandingBonus = input.int(10, "Expanding DS Bonus",
     minval=0,
     group=groupWeights,
     tooltip="Additional score awarded when directional strength expands.\n\n• LONG → +DS is increasing\n• SHORT → -DS is increasing")
candleSizeMultiplier = input.float(2.0, "Candle Size Multiplier Threshold",
     minval=0.1,
     step=0.1,
     group=groupWeights,
     tooltip="Defines how large the current candle must be relative to the average candle size to qualify for the large candle bonus.")
candleLargeBonus = input.int(10, "Large Candle Bonus",
     minval=0,
     group=groupWeights,
     tooltip="Additional score awarded when the current candle exceeds the defined size multiplier threshold.")
smaLength = input.int(200, "SMA Length",
     minval=1,
     group=groupWeights,
     tooltip="Length of the Simple Moving Average used for trend alignment scoring.")
smaBonus = input.int(20, "SMA Alignment Bonus",
     minval=0,
     group=groupWeights,
     tooltip="Score awarded when price aligns with the SMA direction.\n\n• LONG → price above SMA\n• SHORT → price below SMA")
extremePenalty = input.int(10, "OB/OS Penalty (Main DS)",
     minval=0,
     group=groupWeights,
     tooltip="Penalty applied when the primary directional strength reaches extreme overbought or oversold conditions.")
secondaryExtremePenalty = input.int(10, "Secondary OB/OS Penalty",
     minval=0,
     group=groupWeights,
     tooltip="Penalty applied when the secondary directional strength reaches extreme conditions.")
dsmiFallingPenalty = input.int(10, "Falling DSMI Penalty",
     minval=0,
     group=groupWeights,
     tooltip="Penalty applied when the primary DSMI weakens against the current directional bias.")
secondaryDsmiFallingPenalty = input.int(10, "Secondary DSMI Penalty",
     minval=0,
     group=groupWeights,
     tooltip="Penalty applied when the secondary DSMI weakens against the current directional bias.")
dsWeakeningPenalty = input.int(10, "Weakening DS Penalty",
     minval=0,
     group=groupWeights,
     tooltip="Penalty applied when directional strength weakens.\n\n• LONG → +DS decreases\n• SHORT → -DS decreases")

// SCORING DASHBOARD
showScoreTable = input.bool(true, 'Show Scoring Dashboard',
     group='Scoring Dashboard',
     tooltip="Displays a real-time scoring dashboard with all active score components.")

// DASHBOARD SETTINGS
tablePosition = input.string("Top Right", "Table Position",
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Top Center", "Bottom Center", "Middle Left", "Middle Right"],
     group='Scoring Dashboard',
     tooltip="Defines the on-screen position of the scoring dashboard.")
tableTextSize = input.string("Small", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group='Scoring Dashboard',
     tooltip="Adjusts the text size used inside the scoring dashboard.")

// TREND STRENGTH LEVELS
weak_thr = input.int(10, 'Weak Trend – below = neutral',
     minval=1,
     maxval=100,
     group='Trend Strength Levels',
     tooltip="Minimum DSMI level required to classify the market as trending instead of neutral.")
neutral_thr = input.int(14, 'Moderate Trend – up to',
     minval=1,
     maxval=100,
     group='Trend Strength Levels',
     tooltip="Threshold separating weak and moderate trend conditions.")
strong_thr = input.int(35, 'Strong Trend – up to',
     minval=1,
     maxval=100,
     group='Trend Strength Levels',
     tooltip="Threshold required to classify trend conditions as strong.")
// NEUTRAL ZONES
neutralLow = input.int(50, 'Neutral Gray Zone Low (+DS / -DS)',
     minval=0,
     maxval=99,
     group='Neutral Zones',
     tooltip="Lower boundary of the neutral directional strength zone.")
neutralHigh = input.int(50, 'Neutral Gray Zone High (+DS / -DS)',
     minval=0,
     maxval=100,
     group='Neutral Zones',
     tooltip="Upper boundary of the neutral directional strength zone.\n\nWhen both levels are equal, the neutral gray zone is disabled.")

// EXTREME ZONES + OTHERS
lowerExtreme = input.int(15, 'Lower Extreme Level',
     minval=1,
     maxval=99,
     group='Extreme Zones',
     tooltip="Lower boundary of the extreme zone used for visual reference.")
upperExtreme = input.int(85, 'Upper Extreme Level',
     minval=1,
     maxval=99,
     group='Extreme Zones',
     tooltip="Upper boundary of the extreme zone used for visual reference.")
bandColor = input.color(color.new(#545559, 0), 'Extreme Zone Line Color',
     group='Extreme Zones',
     tooltip="Color of the extreme zone boundary lines.")
outsideGradientColor = input.color(color.new(#545559, 15), 'Gradient Color Outside Zones',
     group='Extreme Zones',
     tooltip="Background gradient color used outside the extreme zones.")
bullColor = input.color(color.rgb(6, 162, 47), 'BULLISH Color',
     group='Trend Colors',
     tooltip="Primary bullish trend color.")
bearColor = input.color(color.rgb(207, 23, 23), 'BEARISH Color',
     group='Trend Colors',
     tooltip="Primary bearish trend color.")
neutralColor = input.color(color.new(color.gray, 60), 'NEUTRAL Color',
     group='Trend Colors',
     tooltip="Color used during neutral or low-strength market conditions.")
showCandleColor = input.bool(true, 'Color Candles by Trend',
     group='Candle Coloring',
     tooltip="Colors chart candles based on current DSMI trend conditions.")

// GRADIENT
gradient_steps = 30
var array<color> grad_bull = array.new_color(gradient_steps)
var array<color> grad_bear = array.new_color(gradient_steps)
var array<color> grad_neutral = array.new_color(gradient_steps)
if barstate.isfirst
    for i = 0 to gradient_steps - 1
        float ratio = i / (gradient_steps - 1.0)
        array.set(grad_bull, i, color.new(bullColor, 80 - ratio * 80))
        array.set(grad_bear, i, color.new(bearColor, 80 - ratio * 80))
        array.set(grad_neutral, i, color.new(neutralColor, 80 - ratio * 80))

// CALCULATIONS
bodySize = math.abs(close - open)
fullRangeSize = high - low
candleSizeDM = dmSource == "Full Range (Body + Wicks)" ? fullRangeSize : bodySize
avgCandleSize = ta.sma(bodySize[1], 100)
candleRatio = avgCandleSize == 0 ? 1 : bodySize / avgCandleSize
direction = close > open ? 1 : close < open ? -1 : 0
plusDM = direction > 0 ? candleSizeDM : 0
minusDM = direction < 0 ? candleSizeDM : 0

// DSMI FUNCTION
f_calculateDSMI(int len) =>
    plusDM_EMA = ta.ema(plusDM, len)
    minusDM_EMA = ta.ema(minusDM, len)
    candle_EMA = ta.ema(candleSizeDM, len)
    candle_EMA_safe = candle_EMA == 0 ? 1e-10 : candle_EMA
    plusDS = 100 * plusDM_EMA / candle_EMA_safe
    minusDS = 100 * minusDM_EMA / candle_EMA_safe
    sumDS = plusDS + minusDS
    DX = sumDS == 0 ? 0.0 : 100 * math.abs(plusDS - minusDS) / sumDS
    DSMI_val = ta.ema(DX, len)
    isBull_val = plusDS > minusDS
    [DSMI_val, plusDS, minusDS, isBull_val]

// CALCULATIONS
[dsmiSignal, plusDSSignal, minusDSSignal, isBullSignal] = f_calculateDSMI(lenSignal)
[dsmiSecondary, plusDSSecondary, minusDSSecondary, isBullSecondary] = f_calculateDSMI(lenSecondary)
DSMI = dsmiSignal
plusDS = plusDSSignal
minusDS = minusDSSignal
isBull = isBullSignal

// STRONG TREND + COLORS
bool plusStrong = plusDS > neutralHigh
bool minusStrong = minusDS > neutralHigh
bool strongBull = isBull and plusStrong
bool strongBear = not isBull and minusStrong
bool hasGrayZone = neutralHigh > neutralLow
bool disableNeutral = not hasGrayZone
color trendColor =
     disableNeutral ?
         (isBull ? bullColor : bearColor) :
     DSMI < weak_thr ?
         neutralColor :
     strongBull ?
         bullColor :
     strongBear ?
         bearColor :
         neutralColor
bool plusInGrayZone = hasGrayZone and (plusDS >= neutralLow and plusDS <= neutralHigh)
bool minusInGrayZone = hasGrayZone and (minusDS >= neutralLow and minusDS <= neutralHigh)
color plusDSLineColor = trendColor
color minusDSLineColor = trendColor
color dsFillColor = na
if hasGrayZone and plusInGrayZone and minusInGrayZone
    dsFillColor := color.new(color.gray, 65)
else if not disableNeutral and DSMI < weak_thr
    dsFillColor := array.get(grad_neutral, math.min(math.max(math.round(DSMI / 100 * (gradient_steps - 1)), 0), gradient_steps - 1))
else if isBull
    dsFillColor := array.get(grad_bull, math.min(math.max(math.round(DSMI / 100 * (gradient_steps - 1)), 0), gradient_steps - 1))
else
    dsFillColor := array.get(grad_bear, math.min(math.max(math.round(DSMI / 100 * (gradient_steps - 1)), 0), gradient_steps - 1))
if hasGrayZone
    if plusInGrayZone
        plusDSLineColor := color.new(color.gray, 0)
    if minusInGrayZone
        minusDSLineColor := color.new(color.gray, 0)

// PLOTS
plot(showSignalLine ? DSMI : na, title='1. Signal DSMI', color=dsmiSignalColor, linewidth=2)
plot(showSecondaryLine ? dsmiSecondary : na, title='2. Secondary DSMI', color=dsmiSecondaryColor, linewidth=1)
plot(showDSSecondary ? plusDSSecondary : na, title='+DS Secondary', color=color.new(trendColor, 30), linewidth=1)
plot(showDSSecondary ? minusDSSecondary : na, title='-DS Secondary', color=color.new(trendColor, 30), linewidth=1)
pPlus = plot(showDSSignal ? plusDS : na, title='+DS Signal', color=plusDSLineColor, linewidth=1)
pMinus = plot(showDSSignal ? minusDS : na, title='-DS Signal', color=minusDSLineColor, linewidth=1)
fill(pPlus, pMinus, color = showDSSignal ? dsFillColor : na)
hline(upperExtreme, 'Upper Extreme', color=bandColor, linestyle=hline.style_dotted)
hline(lowerExtreme, 'Lower Extreme', color=bandColor, linestyle=hline.style_dotted)
hline(100, '', color=color.new(color.gray, 100))
hline(0, '', color=color.new(color.gray, 100))
fill(hline(100), hline(upperExtreme), color=color.new(outsideGradientColor, 85))
fill(hline(0), hline(lowerExtreme), color=color.new(outsideGradientColor, 85))
plot(0, title="Force Scale 0", color=color.new(color.white, 100), display=display.none)
plot(100, title="Force Scale 100", color=color.new(color.white, 100), display=display.none)

// SCORING ENGINE
int trendCore = 0
if DSMI > weak_thr
    trendCore += trendWeakBonus
if DSMI > neutral_thr
    trendCore += trendModerateBonus
if DSMI > strong_thr
    trendCore += trendStrongBonus
int trendCoreLong = isBull ? trendCore : 0
int trendCoreShort = not isBull ? trendCore : 0
bool dsmiRising = DSMI > DSMI[1]
bool dsmiFalling = DSMI < DSMI[1]
bool secondaryFalling = dsmiSecondary < dsmiSecondary[1]
bool plusDSFalling = plusDS < plusDS[1]
bool minusDSFalling = minusDS < minusDS[1]
bool plusDSRising = plusDS > plusDS[1]
bool minusDSRising = minusDS > minusDS[1]
int candleScoreLong = (direction == 1 and candleRatio >= candleSizeMultiplier) ? candleLargeBonus : 0
int candleScoreShort = (direction == -1 and candleRatio >= candleSizeMultiplier) ? candleLargeBonus : 0
smaValue = ta.sma(close, smaLength)
int longSmaBonus = (isBull and close > smaValue) ? smaBonus : 0
int shortSmaBonus = (not isBull and close < smaValue) ? smaBonus : 0

// SCORE DECLARATION
int score_long = 0
int score_short = 0

// LONG SCORING
int longMomentum = (dsmiRising and isBull) ? momentumBonus : 0
int longWeakeningPenalty = (dsmiFalling and isBull) ? -dsmiFallingPenalty : 0
int longSecondaryPenalty = (secondaryFalling and isBull) ? -secondaryDsmiFallingPenalty : 0
int longExtremePenalty = plusDS > upperExtreme ? -extremePenalty : 0
int longSecondaryExtremePenalty = plusDSSecondary > upperExtreme ? -secondaryExtremePenalty : 0
int longDsWeakeningPenalty = (isBull and plusDSFalling) ? -dsWeakeningPenalty : 0
int longDsExpandingBonus = (isBull and plusDSRising) ? dsExpandingBonus : 0
score_long := trendCoreLong + longMomentum + candleScoreLong + longSmaBonus + longWeakeningPenalty + longSecondaryPenalty + longExtremePenalty + longSecondaryExtremePenalty + longDsWeakeningPenalty + longDsExpandingBonus

// SHORT SCORING
int shortMomentum = (dsmiRising and not isBull) ? momentumBonus : 0
int shortWeakeningPenalty = (dsmiFalling and not isBull) ? -dsmiFallingPenalty : 0
int shortSecondaryPenalty = (secondaryFalling and not isBull) ? -secondaryDsmiFallingPenalty : 0
int shortExtremePenalty = minusDS > upperExtreme ? -extremePenalty : 0
int shortSecondaryExtremePenalty = minusDSSecondary > upperExtreme ? -secondaryExtremePenalty : 0
int shortDsWeakeningPenalty = (not isBull and minusDSFalling) ? -dsWeakeningPenalty : 0
int shortDsExpandingBonus = (not isBull and minusDSRising) ? dsExpandingBonus : 0
score_short := trendCoreShort + shortMomentum + candleScoreShort + shortSmaBonus + shortWeakeningPenalty + shortSecondaryPenalty + shortExtremePenalty + shortSecondaryExtremePenalty + shortDsWeakeningPenalty + shortDsExpandingBonus
score_long := math.max(0, math.min(100, score_long))
score_short := math.max(0, math.min(100, score_short))
bool longEntry = score_long >= entryThreshold and direction == 1
bool shortEntry = score_short >= entryThreshold and direction == -1
bgcolor(showEntrySignal and longEntry ? color.new(bullColor, 70) : na)
bgcolor(showEntrySignal and shortEntry ? color.new(bearColor, 70) : na)
barcolor(showCandleColor ? trendColor : na)

// TP/SL + OVERLAY SIGNALS
show_targets = input.bool(true, "Show TP/SL levels", group = "TP/SL")
use_atr_sl = input.bool(true, "SL = ATR × instead of %", group = "TP/SL")
tp_atr_period = input.int(14, "ATR period for TP/SL", minval=1, group = "TP/SL")
sl_atr_mult = input.float(1.5, "ATR multiplier for SL", step=0.1, group = "TP/SL")
sl_percent = input.float(1.0, "SL % from entry", step=0.1, group = "TP/SL")
rr_tp1 = input.float(1.0, "RR for TP1", step=0.1, group = "TP/SL")
rr_tp2 = input.float(2.0, "RR for TP2", step=0.1, group = "TP/SL")
rr_tp3 = input.float(3.0, "RR for TP3", step=0.1, group = "TP/SL")
show_sl_level = input.bool(true, "Show SL level", group = "TP/SL Display")
show_tp1_level = input.bool(true, "Show TP1 level", group = "TP/SL Display")
show_tp2_level = input.bool(true, "Show TP2 level", group = "TP/SL Display")
show_tp3_level = input.bool(true, "Show TP3 level", group = "TP/SL Display")
buyLabelColor = bullColor
sellLabelColor = bearColor
buyColorLight = color.new(buyLabelColor, 40)
sellColorLight = color.new(sellLabelColor, 40)
buyFill = color.new(buyLabelColor, 70)
sellFill = color.new(sellLabelColor, 70)
atr_for_targets = ta.atr(tp_atr_period)

// TP/SL VARIABLES
var int trade_dir = 0
var float sl_level = na
var float extreme_level = na
var line entry_line = na
var label entry_label = na
var line sl_line = na
var label sl_label = na
var line tp1_line = na
var label tp1_label = na
var line tp2_line = na
var label tp2_label = na
var line tp3_line = na
var label tp3_label = na
var line extreme_line = na
var linefill risk_fill = na
var linefill reward_fill = na
var int entry_bar = na

// TP/SL LOGIC
if (longEntry or shortEntry) and show_targets
    line.delete(entry_line)
    label.delete(entry_label)
    line.delete(sl_line)
    label.delete(sl_label)
    line.delete(tp1_line)
    label.delete(tp1_label)
    line.delete(tp2_line)
    label.delete(tp2_label)
    line.delete(tp3_line)
    label.delete(tp3_label)
    line.delete(extreme_line)
    linefill.delete(risk_fill)
    linefill.delete(reward_fill)
  
    trade_dir := longEntry ? 1 : -1
    entry_bar := bar_index
    float entry_price = close
    float risk_dist = use_atr_sl ? atr_for_targets * sl_atr_mult : entry_price * (sl_percent / 100)
  
    float tp1_p = na
    float tp2_p = na
    float tp3_p = na
  
    if trade_dir == 1
        sl_level := entry_price - risk_dist
        tp1_p := entry_price + risk_dist * rr_tp1
        tp2_p := entry_price + risk_dist * rr_tp2
        tp3_p := entry_price + risk_dist * rr_tp3
        extreme_level := show_tp3_level ? tp3_p : show_tp2_level ? tp2_p : show_tp1_level ? tp1_p : na
      
        string forceTxt = "LONG " + str.tostring(math.round(score_long)) + "/100"
        entry_line := line.new(bar_index, entry_price, bar_index + 1, entry_price, color = buyLabelColor, width = 2, extend = extend.none, force_overlay = true)
        entry_label := label.new(bar_index, entry_price, forceTxt, style = label.style_label_left, color = buyLabelColor, textcolor = color.white, size = size.small, force_overlay = true)
      
        if show_sl_level
            sl_line := line.new(bar_index, sl_level, bar_index + 1, sl_level, color = sellColorLight, width = 1, style = line.style_dashed, extend = extend.none, force_overlay = true)
            sl_label := label.new(bar_index, sl_level, "SL " + str.tostring(sl_level, format.mintick), style = label.style_label_left, color = sellColorLight, textcolor = color.white, size = size.small, force_overlay = true)
      
        if show_tp1_level
            tp1_line := line.new(bar_index, tp1_p, bar_index + 1, tp1_p, color = buyColorLight, width = 1, extend = extend.none, force_overlay = true)
            tp1_label := label.new(bar_index, tp1_p, "TP1 " + str.tostring(tp1_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small, force_overlay = true)
        if show_tp2_level
            tp2_line := line.new(bar_index, tp2_p, bar_index + 1, tp2_p, color = buyColorLight, width = 1, extend = extend.none, force_overlay = true)
            tp2_label := label.new(bar_index, tp2_p, "TP2 " + str.tostring(tp2_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small, force_overlay = true)
        if show_tp3_level
            tp3_line := line.new(bar_index, tp3_p, bar_index + 1, tp3_p, color = buyColorLight, width = 1, style = line.style_dotted, extend = extend.none, force_overlay = true)
            tp3_label := label.new(bar_index, tp3_p, "TP3 " + str.tostring(tp3_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small, force_overlay = true)
      
        if show_sl_level
            risk_fill := linefill.new(entry_line, sl_line, sellFill)
      
        float max_tp_for_fill = entry_price
        if show_tp1_level
            max_tp_for_fill := math.max(max_tp_for_fill, tp1_p)
        if show_tp2_level
            max_tp_for_fill := math.max(max_tp_for_fill, tp2_p)
        if show_tp3_level
            max_tp_for_fill := math.max(max_tp_for_fill, tp3_p)
        if max_tp_for_fill > entry_price
            extreme_line := line.new(bar_index, max_tp_for_fill, bar_index + 1, max_tp_for_fill, color = na, extend = extend.none, force_overlay = true)
            reward_fill := linefill.new(entry_line, extreme_line, buyFill)
  
    else
        sl_level := entry_price + risk_dist
        tp1_p := entry_price - risk_dist * rr_tp1
        tp2_p := entry_price - risk_dist * rr_tp2
        tp3_p := entry_price - risk_dist * rr_tp3
        extreme_level := show_tp3_level ? tp3_p : show_tp2_level ? tp2_p : show_tp1_level ? tp1_p : na
      
        string forceTxt = "SHORT " + str.tostring(math.round(score_short)) + "/100"
        entry_line := line.new(bar_index, entry_price, bar_index + 1, entry_price, color = sellLabelColor, width = 2, extend = extend.none, force_overlay = true)
        entry_label := label.new(bar_index, entry_price, forceTxt, style = label.style_label_left, color = sellLabelColor, textcolor = color.white, size = size.small, force_overlay = true)
      
        if show_sl_level
            sl_line := line.new(bar_index, sl_level, bar_index + 1, sl_level, color = sellColorLight, width = 1, style = line.style_dashed, extend = extend.none, force_overlay = true)
            sl_label := label.new(bar_index, sl_level, "SL " + str.tostring(sl_level, format.mintick), style = label.style_label_left, color = sellColorLight, textcolor = color.white, size = size.small, force_overlay = true)
      
        if show_tp1_level
            tp1_line := line.new(bar_index, tp1_p, bar_index + 1, tp1_p, color = sellColorLight, width = 1, extend = extend.none, force_overlay = true)
            tp1_label := label.new(bar_index, tp1_p, "TP1 " + str.tostring(tp1_p, format.mintick), style = label.style_label_left, color = sellColorLight, textcolor = color.white, size = size.small, force_overlay = true)
        if show_tp2_level
            tp2_line := line.new(bar_index, tp2_p, bar_index + 1, tp2_p, color = sellColorLight, width = 1, extend = extend.none, force_overlay = true)
            tp2_label := label.new(bar_index, tp2_p, "TP2 " + str.tostring(tp2_p, format.mintick), style = label.style_label_left, color = sellColorLight, textcolor = color.white, size = size.small, force_overlay = true)
        if show_tp3_level
            tp3_line := line.new(bar_index, tp3_p, bar_index + 1, tp3_p, color = sellColorLight, width = 1, style = line.style_dotted, extend = extend.none, force_overlay = true)
            tp3_label := label.new(bar_index, tp3_p, "TP3 " + str.tostring(tp3_p, format.mintick), style = label.style_label_left, color = sellColorLight, textcolor = color.white, size = size.small, force_overlay = true)
      
        if show_sl_level
            risk_fill := linefill.new(entry_line, sl_line, sellFill)
      
        float min_tp_for_fill = entry_price
        if show_tp1_level
            min_tp_for_fill := math.min(min_tp_for_fill, tp1_p)
        if show_tp2_level
            min_tp_for_fill := math.min(min_tp_for_fill, tp2_p)
        if show_tp3_level
            min_tp_for_fill := math.min(min_tp_for_fill, tp3_p)
        if min_tp_for_fill < entry_price
            extreme_line := line.new(bar_index, min_tp_for_fill, bar_index + 1, min_tp_for_fill, color = na, extend = extend.none, force_overlay = true)
            reward_fill := linefill.new(entry_line, extreme_line, buyFill)

// TP/SL POSITION UPDATE
if trade_dir != 0
    if not na(entry_label)
        label.set_x(entry_label, bar_index)
    if not na(sl_label)
        label.set_x(sl_label, bar_index)
    if not na(tp1_label)
        label.set_x(tp1_label, bar_index)
    if not na(tp2_label)
        label.set_x(tp2_label, bar_index)
    if not na(tp3_label)
        label.set_x(tp3_label, bar_index)
  
    if not na(entry_line)
        line.set_x2(entry_line, bar_index + 1)
    if not na(sl_line)
        line.set_x2(sl_line, bar_index + 1)
    if not na(tp1_line)
        line.set_x2(tp1_line, bar_index + 1)
    if not na(tp2_line)
        line.set_x2(tp2_line, bar_index + 1)
    if not na(tp3_line)
        line.set_x2(tp3_line, bar_index + 1)
    if not na(extreme_line)
        line.set_x2(extreme_line, bar_index + 1)
  
    bool sl_hit = false
    bool tp_hit = false
    if trade_dir == 1
        sl_hit := low <= sl_level
        tp_hit := not na(extreme_level) and high >= extreme_level
    else if trade_dir == -1
        sl_hit := high >= sl_level
        tp_hit := not na(extreme_level) and low <= extreme_level
  
    if bar_index > entry_bar and (sl_hit or tp_hit)
        line.set_extend(entry_line, extend.none)
        line.set_x2(entry_line, bar_index)
        if not na(sl_line)
            line.set_extend(sl_line, extend.none)
            line.set_x2(sl_line, bar_index)
        if not na(tp1_line)
            line.set_extend(tp1_line, extend.none)
            line.set_x2(tp1_line, bar_index)
        if not na(tp2_line)
            line.set_extend(tp2_line, extend.none)
            line.set_x2(tp2_line, bar_index)
        if not na(tp3_line)
            line.set_extend(tp3_line, extend.none)
            line.set_x2(tp3_line, bar_index)
        if not na(extreme_line)
            line.set_extend(extreme_line, extend.none)
            line.set_x2(extreme_line, bar_index)
        trade_dir := 0

// OVERLAY SIGNALS
plotshape(showTriangleSignals and longEntry and signalSizeStr == "Tiny", title="LONG Entry", style=shape.triangleup, location=location.belowbar, color=bullColor, size=size.tiny, force_overlay = true)
plotshape(showTriangleSignals and longEntry and signalSizeStr == "Small", title="LONG Entry", style=shape.triangleup, location=location.belowbar, color=bullColor, size=size.small, force_overlay = true)
plotshape(showTriangleSignals and longEntry and signalSizeStr == "Normal", title="LONG Entry", style=shape.triangleup, location=location.belowbar, color=bullColor, size=size.normal, force_overlay = true)
plotshape(showTriangleSignals and shortEntry and signalSizeStr == "Tiny", title="SHORT Entry", style=shape.triangledown, location=location.abovebar, color=bearColor, size=size.tiny, force_overlay = true)
plotshape(showTriangleSignals and shortEntry and signalSizeStr == "Small", title="SHORT Entry", style=shape.triangledown, location=location.abovebar, color=bearColor, size=size.small, force_overlay = true)
plotshape(showTriangleSignals and shortEntry and signalSizeStr == "Normal", title="SHORT Entry", style=shape.triangledown, location=location.abovebar, color=bearColor, size=size.normal, force_overlay = true)

// SCORING DASHBOARD
getLongScoreColor(int val) => val > 0 ? bullColor : val < 0 ? bearColor : color.gray
getShortScoreColor(int val) => val > 0 ? bearColor : val < 0 ? bullColor : color.gray
finalTablePos =
     tablePosition == "Top Left" ? position.top_left :
     tablePosition == "Top Right" ? position.top_right :
     tablePosition == "Bottom Left" ? position.bottom_left :
     tablePosition == "Bottom Right" ? position.bottom_right :
     tablePosition == "Top Center" ? position.top_center :
     tablePosition == "Bottom Center" ? position.bottom_center :
     tablePosition == "Middle Left" ? position.middle_left :
     tablePosition == "Middle Right" ? position.middle_right : position.top_right
tableSize =
     tableTextSize == "Tiny" ? size.tiny :
     tableTextSize == "Small" ? size.small :
     tableTextSize == "Large" ? size.large : size.normal
var table t = na
if barstate.islast and showScoreTable
    if not na(t)
        table.delete(t)
        t := na
   
    t := table.new(finalTablePos, columns = 3, rows = 13, bgcolor = color.new(color.black, 85), border_width = 1, border_color = color.gray, force_overlay = true)
   
    string regime = DSMI > strong_thr ? 'strong' : DSMI > neutral_thr ? 'moderate' : DSMI > weak_thr ? 'weak' : 'neutral'
    table.cell(t, 0, 0, 'Component', text_color=color.white, bgcolor=color.new(color.gray, 40), text_size=tableSize)
    table.cell(t, 1, 0, 'LONG', text_color=color.white, bgcolor=bullColor, text_size=tableSize)
    table.cell(t, 2, 0, 'SHORT', text_color=color.white, bgcolor=bearColor, text_size=tableSize)
    table.cell(t, 0, 1, 'Trend Strength', text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 1, 1, trendCoreLong > 0 ? '+' + str.tostring(trendCoreLong) : str.tostring(trendCoreLong), text_color=getLongScoreColor(trendCoreLong), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 2, 1, trendCoreShort > 0 ? '+' + str.tostring(trendCoreShort) : str.tostring(trendCoreShort), text_color=getShortScoreColor(trendCoreShort), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 0, 2, 'Momentum', text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 1, 2, longMomentum > 0 ? '+' + str.tostring(longMomentum) : str.tostring(longMomentum), text_color=getLongScoreColor(longMomentum), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 2, 2, shortMomentum > 0 ? '+' + str.tostring(shortMomentum) : str.tostring(shortMomentum), text_color=getShortScoreColor(shortMomentum), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 0, 3, 'Expanding DS', text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 1, 3, longDsExpandingBonus > 0 ? '+' + str.tostring(longDsExpandingBonus) : str.tostring(longDsExpandingBonus), text_color=getLongScoreColor(longDsExpandingBonus), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 2, 3, shortDsExpandingBonus > 0 ? '+' + str.tostring(shortDsExpandingBonus) : str.tostring(shortDsExpandingBonus), text_color=getShortScoreColor(shortDsExpandingBonus), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 0, 4, 'Large Candle', text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 1, 4, candleScoreLong > 0 ? '+' + str.tostring(candleScoreLong) : str.tostring(candleScoreLong), text_color=getLongScoreColor(candleScoreLong), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 2, 4, candleScoreShort > 0 ? '+' + str.tostring(candleScoreShort) : str.tostring(candleScoreShort), text_color=getShortScoreColor(candleScoreShort), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 0, 5, 'SMA Alignment', text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 1, 5, longSmaBonus > 0 ? '+' + str.tostring(longSmaBonus) : str.tostring(longSmaBonus), text_color=getLongScoreColor(longSmaBonus), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 2, 5, shortSmaBonus > 0 ? '+' + str.tostring(shortSmaBonus) : str.tostring(shortSmaBonus), text_color=getShortScoreColor(shortSmaBonus), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 0, 6, 'Main Extreme', text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 1, 6, str.tostring(longExtremePenalty), text_color=getLongScoreColor(longExtremePenalty), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 2, 6, str.tostring(shortExtremePenalty), text_color=getShortScoreColor(shortExtremePenalty), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 0, 7, 'Secondary Extreme', text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 1, 7, str.tostring(longSecondaryExtremePenalty), text_color=getLongScoreColor(longSecondaryExtremePenalty), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 2, 7, str.tostring(shortSecondaryExtremePenalty), text_color=getShortScoreColor(shortSecondaryExtremePenalty), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 0, 8, 'DSMI Falling', text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 1, 8, str.tostring(longWeakeningPenalty), text_color=getLongScoreColor(longWeakeningPenalty), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 2, 8, str.tostring(shortWeakeningPenalty), text_color=getShortScoreColor(shortWeakeningPenalty), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 0, 9, 'Secondary DSMI Falling', text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 1, 9, str.tostring(longSecondaryPenalty), text_color=getLongScoreColor(longSecondaryPenalty), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 2, 9, str.tostring(shortSecondaryPenalty), text_color=getShortScoreColor(shortSecondaryPenalty), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 0, 10, 'Declining DS', text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 1, 10, str.tostring(longDsWeakeningPenalty), text_color=getLongScoreColor(longDsWeakeningPenalty), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 2, 10, str.tostring(shortDsWeakeningPenalty), text_color=getShortScoreColor(shortDsWeakeningPenalty), bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 0, 11, 'TOTAL', text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=tableSize)
    table.cell(t, 1, 11, str.tostring(score_long), text_color=score_long >= entryThreshold ? bullColor : color.white, bgcolor=color.new(color.black, 70), text_size=tableSize)
    table.cell(t, 2, 11, str.tostring(score_short), text_color=score_short >= entryThreshold ? bearColor : color.white, bgcolor=color.new(color.black, 70), text_size=tableSize)
    string trendInfo = "Trend strength " + regime + " • DSMI " + str.tostring(math.round(DSMI))
    table.cell(t, 0, 12, trendInfo, text_color=color.white, bgcolor=color.new(color.black, 60), text_size=tableSize)
    table.merge_cells(t, 0, 12, 2, 12)

// ALERTS
alertcondition(longEntry, title='SCORING Long Entry', message='DSMI Scoring → LONG ENTRY')
alertcondition(shortEntry, title='SCORING Short Entry', message='DSMI Scoring → SHORT ENTRY')
````
