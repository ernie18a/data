# Volatility Squeeze Ignition [MarkitTick]

- url: https://www.tradingview.com/script/l8tV3inq-Volatility-Squeeze-Ignition-MarkitTick/
- type: indicator
- pine_id: PUB;4c4988c661c940fa8002a8acaaf11100
- version: 1.0

## Description

💡 A multi-dimensional analytical engine designed to detect periods of extreme market consolidation and validate the subsequent directional expansion. By measuring the mathematical relationship between standard deviation and average true range, this tool identifies equilibrium zones where price action compresses and stores kinetic energy. Rather than reacting blindly to every volatility spike, the script employs a sophisticated filtration matrix that evaluates underlying volume delta, higher timeframe macro-trend alignment, directional movement strength, and immediate candlestick morphology. This creates a rigorous framework that authenticates breakout signals, ensuring that traders only focus on high-probability momentum ignitions supported by definitive market conviction.

[b]✨ Originality and Utility[/b]
Standard volatility indicators often generate breakout signals without providing any insight into the underlying market participation or the structural validity of the move. This system distinguishes itself by integrating a state-tracking memory engine that monitors the cumulative buying and selling volume specifically during the compression phase. This continuous volume delta tracking allows the system to pre-assess the directional bias before the actual breakout materializes. Furthermore, it incorporates a dynamic risk-to-reward projection matrix mapped directly onto the chart. It calculates stop-loss zones and sequential take-profit levels based on the exact width of the preceding volatility squeeze. This creates a completely self-contained analytical environment that bridges the critical gap between signal generation and precise trade management, eliminating the need for discretionary target plotting and manual risk calculations.

[b]🔬 Methodology and Concepts[/b]
[b]● The Volatility Squeeze Engine[/b]
The core mechanics rely on the precise interplay between Bollinger Bands and Keltner Channels. A squeeze state is formally activated when the Bollinger Bands contract entirely within the boundaries of the Keltner Channels. This condition signifies that the market's standard deviation has fallen below its historical true range, indicating a profound period of low volatility and liquidity resting. The system mathematically locks in the exact width of the bands at the onset of this compression. An ignition signal is mathematically validated only when the price decisively breaks outside the Bollinger Bands, provided the bands have begun to expand.

[b]● Volume Delta Profiling[/b]
While the squeeze state is active, the script meticulously aggregates the volume of up-closing bars versus down-closing bars. This builds a cumulative delta sum. When a breakout triggers, the system references this stored delta to ensure that the directional break is fully supported by the actual volume flow accumulated during the consolidation phase, preventing false breakouts engineered by low-liquidity spikes.

[b]● Multi-Dimensional Filtering[/b]
The breakout validation process is governed by a rigorous confluence matrix:
[list]
[*] Higher Timeframe Alignment: Evaluates a simple moving average on a higher resolution chart to ensure the breakout trades strictly in the direction of the macro trend, utilizing a secure, non-repainting data referencing architecture.
[*] Trend Strength Evaluation: Integrates the Average Directional Index to demand a minimum trend strength threshold, actively filtering out choppy, sideways market noise.
[*] Candlestick Morphology: Evaluates immediate, candle-by-candle price and momentum interaction. The real body of the breakout candle must constitute a specific percentage of the total high-to-low range, confirming definitive and immediate market conviction rather than relying on lagging divergences.
[*] Volatility Expansion: Compares the current channel width against the locked width from the start of the squeeze, ensuring the breakout is accompanied by a genuine expansion in market volatility.
[/list]

[b]🎨 Visual Guide[/b]
[b]● Chart Overlays[/b]
[list]
[*] Active Squeeze Background: A subtle blue vertical background highlight appears when the volatility squeeze is actively compressing.
[*] Breakout Backgrounds: A vibrant teal background signals a confirmed bullish squeeze ignition, while a vivid crimson background highlights a bearish squeeze ignition.
[*] BB Basis Line: A solid blue line representing the central moving average of the standard deviation channel.
[*] KC Lines: Muted, semi-transparent lines mapping the upper and lower boundaries of the true range channel.
[/list]

[b]● Trade Management UI[/b]
[list]
[*] Entry Line: A dashed blue line marking the exact closing price of the validated breakout candle, accompanied by a dynamic price label.
[*] Stop Loss (SL) Line: A solid, thick crimson line indicating the invalidation level. Depending on user settings, this is positioned either at the opposite channel edge or calculated via an ATR multiplier. A red translucent fill connects the Entry to the SL, visualizing the exact risk zone.
[*] Take Profit (TP) Lines: Three distinct dashed teal lines representing sequential profit targets, derived from Fibonacci extensions of the locked squeeze width. A green translucent fill highlights the total reward zone from the Entry to TP3.
[/list]

[b]● Information Dashboard[/b]
A comprehensive heads-up display anchored to the chart corner providing real-time telemetry on the system's state:
[list]
[*] Squeeze Status: Displays whether the compression is currently ACTIVE or OFF, alongside a graphical progress bar.
[*] Sqz Bars: A numerical count of how long the current squeeze has been compressing.
[*] BB Width %: A visual gauge showing the current width of the standard deviation channel relative to its basis.
[*] Delta Bias: Highlights the dominant accumulated volume direction (BULLISH, BEARISH, or NEUTRAL) colored dynamically in teal or crimson.
[*] R:R Metrics: Real-time calculation bars showing the exact risk-to-reward ratios for all three take-profit targets based on the current active signal.
[*] Filter Diagnostics: Individual status readouts for HTF Trend, ADX, Body Strength, and Volume Confirmation, allowing traders to instantly see which filters are passing or failing.
[/list]

[b]📖 How to Use[/b]
[b]● Identifying Setups[/b]
Traders should monitor the chart for the appearance of the blue active squeeze background. During this phase, direct your attention to the Dashboard to monitor the "Delta Bias" and "Sqz Bars" count. A longer squeeze accompanied by a strong, building Delta Bias indicates a high-probability impending breakout. Wait for a confirmed candle close that breaks the channel limits, triggering the vibrant teal or crimson background.

[b]● Managing Trades[/b]
Once an ignition signal fires, the script automatically projects the entry, stop-loss, and three take-profit levels. Traders can use the SL line to place their initial protective stop. As price approaches TP1, traders may consider scaling out a portion of their position and trailing their stop loss to the Entry line to secure a risk-free trade. The graphical risk and reward fills visually assist in quickly assessing if the projected trade meets your personal risk parameters before execution.

[b]⚙️ Inputs and Settings[/b]
[b]● Core Parameters[/b]
[list]
[*] BB Range: Defines the calculation range for the standard deviation channel.
[*] BB Mult: The standard deviation multiplier determining the width of the outer bands.
[*] KC Range: Defines the calculation range for the average true range channel.
[*] KC Mult: The multiplier dictating the width of the Keltner Channels.
[*] Min Squeeze Bars: The absolute minimum number of consecutive compressed bars required before a valid ignition can be fired.
[/list]

[b]● Filters[/b]
[list]
[*] Require Volume Confirmation: Toggles the volume delta tracking engine.
[*] HTF Trend Filter: Activates the macro-trend alignment requirement, preventing counter-trend breakout signals.
[*] ADX Trend Strength Filter: Enables a strict momentum threshold requiring the market to be actively trending.
[*] Candle Body Strength Filter: Enforces a structural rule where the breakout candle's body must meet a minimum size relative to its wicks.
[/list]

[b]● Trade Tools & Alerts[/b]
[list]
[*] SL Mode: Allows traders to select between a structural stop loss at the opposite channel edge or a volatility-based ATR stop.
[*] TP1, TP2, TP3 Fib: Customizable Fibonacci multipliers that project the profit targets based on the original width of the market squeeze.
[*] Dashboard Settings: Toggles the visibility and positional anchoring of the telemetry table.
[*] Alert Actions: Advanced JSON-formatted string inputs allowing traders to define precise webhook payloads for entries, exits, and target hits, enabling seamless automated execution.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
[b]● Volatility Compression Theory[/b]
The fundamental architecture of this script is rooted in the cyclical nature of market volatility, which oscillates continuously between periods of extreme contraction and aggressive expansion. By cross-referencing standard deviation against an absolute measure of true range, the algorithm quantitatively identifies the inflection points where liquidity providers pull back and the market reaches a state of unnatural equilibrium. The mathematical locking of the channel width captures the precise kinetic energy stored during this phase, applying principles of mean reversion and standard deviation expansion to project the statistical probability of the ensuing vector move.

[b]● Order Flow and Delta Mechanics[/b]
To move beyond simple price derivatives, the system incorporates an approximated order flow model through its volume delta profiling. By segmenting traded volume into up-closing and down-closing aggregates during the compression state, the script builds a proxy for aggressive market participation. This mechanism relies on Auction Market Theory, assessing the imbalance between aggressive buyers lifting the offer and aggressive sellers hitting the bid. When the mathematical breakout aligns with the underlying delta accumulation, the script confirms that the price displacement is driven by genuine institutional or macroscopic participation, significantly reducing the statistical likelihood of a mean-reverting liquidity sweep.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Volatility Squeeze Ignition [MarkitTick]", overlay=true, max_lines_count=500, max_boxes_count=50, max_labels_count=500)

// ── INPUTS ──────────────────────────────────────────────────
var string G_CORE   = "⚙️ Core"
var string G_FILT   = "🕯️ Filters"
var string G_TRADE  = "📐 Trade Tools"
var string G_VIS    = "🎨 Visuals"
var string G_DASH   = "📊 Dashboard"
var string G_WH     = "🔔 Alerts"
var string G_COL    = "🌈 Colors"

i_bbLen      = input.int(20, "BB Length", minval=5, group=G_CORE)
i_bbMult     = input.float(2.0, "BB Mult", minval=0.5, step=0.1, group=G_CORE)
i_kcLen      = input.int(20, "KC Length", minval=5, group=G_CORE)
i_kcMult     = input.float(1.5, "KC Mult", minval=0.5, step=0.1, group=G_CORE)
i_kcSrc      = input.string("ATR", "KC Range", options=["ATR", "TrueRange"], group=G_CORE)
i_minSqzBars = input.int(5, "Min Squeeze Bars", minval=1, group=G_CORE)

i_volFilter  = input.bool(false, "Require Volume Confirmation", group=G_FILT)
i_volMinRatio= input.float(1.0, "Min Delta Ratio", minval=0.0, step=0.05, group=G_FILT)
i_htfFilter  = input.bool(false, "HTF Trend Filter", group=G_FILT)
i_htfTF      = input.timeframe("60", "HTF Timeframe", group=G_FILT)
i_adxFilter  = input.bool(false, "ADX Trend Strength Filter", group=G_FILT)
i_adxMin     = input.float(20.0, "Min ADX", minval=5, step=1, group=G_FILT)
i_bodyFilter = input.bool(false, "Candle Body Strength Filter", group=G_FILT)
i_bodyMinPct = input.float(50.0, "Min Body %", minval=10, maxval=100, step=5, group=G_FILT)
i_expFilter  = input.bool(false, "Volatility Expansion Filter", group=G_FILT)
i_expMinRatio= input.float(1.2, "Min Expansion Ratio", minval=1.0, step=0.05, group=G_FILT)

i_slMode     = input.string("Channel Edge", "SL Mode", options=["Channel Edge", "ATR Mult"], group=G_TRADE)
i_slAtrMult  = input.float(1.5, "SL ATR Mult", minval=0.1, step=0.1, group=G_TRADE)
i_tp1Fib     = input.float(1.618, "TP1 Fib", minval=0.1, step=0.001, group=G_TRADE)
i_tp2Fib     = input.float(2.618, "TP2 Fib", minval=0.1, step=0.001, group=G_TRADE)
i_tp3Fib     = input.float(4.236, "TP3 Fib", minval=0.1, step=0.001, group=G_TRADE)

i_showSqzBg  = input.bool(true, "Show Squeeze Background", group=G_VIS)
i_showLevels = input.bool(true, "Show Trade Levels", group=G_VIS)
i_showDelta  = input.bool(true, "Show Delta Bias Marks", group=G_VIS)

i_showDash   = input.bool(true, "Show Dashboard", group=G_DASH)
i_dashPos    = input.string("top_right", "Dashboard Position", options=["top_right", "top_left", "bottom_right", "bottom_left"], group=G_DASH)

i_actionLong        = input.string("long",       "↑ Long Action",        group=G_WH)
i_actionShort       = input.string("short",      "↓ Short Action",       group=G_WH)
i_actionCloseLong   = input.string("closelong",  "✕ Close Long Action",  group=G_WH)
i_actionCloseShort  = input.string("closeshort", "✕ Close Short Action", group=G_WH)
i_actionTP1         = input.string("tp1hit",     "◆ TP1 Action",         group=G_WH)
i_actionTP2         = input.string("tp2hit",     "✦ TP2 Action",         group=G_WH)
i_actionTP3         = input.string("tp3hit",     "◆ TP3 Action",         group=G_WH)

c_bullSqz    = input.color(color.new(#00c9a7, 85), "Bull Squeeze Break BG", group=G_COL)
c_bearSqz    = input.color(color.new(#ff5470, 85), "Bear Squeeze Break BG", group=G_COL)
_mt741c    = input.color(color.new(#3d5aff, 80), "Active Squeeze BG", group=G_COL)
c_bbLine     = input.color(#5b6eff, "BB Basis Line", group=G_COL)
c_kcLine     = input.color(color.new(#7a8ba6, 40), "KC Lines", group=G_COL)
c_deltaBull  = input.color(#00c9a7, "Delta Bull Mark", group=G_COL)
c_deltaBear  = input.color(#ff5470, "Delta Bear Mark", group=G_COL)
c_slColor    = input.color(#ff5470, "SL Line/Label", group=G_COL)
c_entryColor = input.color(#5b6eff, "Entry Line/Label", group=G_COL)
c_tp1Color   = input.color(color.new(#00c9a7, 40), "TP1 Line/Label", group=G_COL)
c_tp2Color   = input.color(color.new(#00c9a7, 20), "TP2 Line/Label", group=G_COL)
c_tp3Color   = input.color(color.new(#00c9a7, 0),  "TP3 Line/Label", group=G_COL)
c_riskFill   = input.color(color.new(#ff5470, 80), "Risk Zone Fill", group=G_COL)
c_rewardFill = input.color(color.new(#00c9a7, 85), "Reward Zone Fill", group=G_COL)
c_lblTxt     = input.color(color.white, "Level Label Text", group=G_COL)
c_dashBg     = input.color(color.new(#0d0b1e, 10), "Dashboard BG", group=G_COL)
c_dashHeader = input.color(color.new(#7b2ff7, 20), "Dashboard Header BG", group=G_COL)
c_dashLabel  = input.color(color.new(#ffffff, 30), "Dashboard Label Text", group=G_COL)
c_dashValue  = input.color(color.new(#ffffff, 0),  "Dashboard Value Text", group=G_COL)
c_barGreen   = input.color(color.new(#26a69a, 0), "Progress Bar High Color", group=G_COL)
c_barYellow  = input.color(color.new(#f9a825, 0), "Progress Bar Mid Color", group=G_COL)
c_barRed     = input.color(color.new(#ef5350, 0), "Progress Bar Low Color", group=G_COL)

// ── UDTs ────────────────────────────────────────────────────
type SqueezeState
    bool  active
    int   startBar
    float deltaSum
    float upVolSum
    float downVolSum
    float widthAtStart

// ── CORE LOGIC ──────────────────────────────────────────────
float basis  = ta.sma(close, i_bbLen)
float dev    = i_bbMult * ta.stdev(close, i_bbLen)
float upperBB = basis + dev
float lowerBB = basis - dev

float kcBasis = ta.sma(close, i_kcLen)
float kcRange = i_kcSrc == "ATR" ? ta.atr(i_kcLen) : ta.rma(ta.tr(true), i_kcLen)
float upperKC = kcBasis + kcRange * i_kcMult
float lowerKC = kcBasis - kcRange * i_kcMult

bool squeezeOn = lowerBB > lowerKC and upperBB < upperKC

var SqueezeState sqz = SqueezeState.new(false, bar_index, 0.0, 0.0, 0.0, 0.0)

float barDelta = close > open ? volume : close < open ? -volume : 0.0
float barUpVol = close > open ? volume : 0.0
float barDownVol = close < open ? volume : 0.0

if squeezeOn and not squeezeOn[1]
    sqz := SqueezeState.new(true, bar_index, barDelta, barUpVol, barDownVol, upperBB - lowerBB)
else if squeezeOn and squeezeOn[1]
    sqz.deltaSum += barDelta
    sqz.upVolSum += barUpVol
    sqz.downVolSum += barDownVol
    sqz.widthAtStart := upperBB - lowerBB
else if not squeezeOn and squeezeOn[1]
    sqz.active := false
else
    sqz.active := false

int sqzBarCount = squeezeOn ? bar_index - sqz.startBar + 1 : 0
bool sqzLongEnough = sqzBarCount >= i_minSqzBars

float sqzVolTotal = sqz.upVolSum + sqz.downVolSum
float deltaRatio = sqzVolTotal != 0 ? math.abs(sqz.deltaSum) / sqzVolTotal : 0.0
bool volConfirmsBull = not i_volFilter or (sqz.deltaSum > 0 and deltaRatio >= i_volMinRatio)
bool volConfirmsBear = not i_volFilter or (sqz.deltaSum < 0 and deltaRatio >= i_volMinRatio)

f_htfTrendUp(simple string tf) =>
    bool _mt741a = close > ta.sma(close, 50)
    request.security(syminfo.tickerid, tf, _mt741a[1], lookahead=barmerge.lookahead_on)

bool htfUp = i_htfFilter ? f_htfTrendUp(i_htfTF) : true
bool htfDown = i_htfFilter ? not f_htfTrendUp(i_htfTF) : true

float prevDeltaSum = na(sqz[1]) ? 0.0 : (sqz[1]).deltaSum

bool squeezeBreakUp   = not squeezeOn and squeezeOn[1] and sqzLongEnough[1] and close > upperBB and prevDeltaSum > 0
bool squeezeBreakDown = not squeezeOn and squeezeOn[1] and sqzLongEnough[1] and close < lowerBB and prevDeltaSum < 0

[diPlus, diMinus, adxVal] = ta.dmi(14, 14)
bool adxConfirms = not i_adxFilter or adxVal >= i_adxMin

float barRange = high - low
float bodyPct = barRange != 0 ? math.abs(close - open) / barRange * 100 : 0.0
bool bodyConfirms = not i_bodyFilter or bodyPct >= i_bodyMinPct

float sqzWidthPrev = na(sqz[1]) ? 0.0 : (sqz[1]).widthAtStart
float expansionRatio = sqzWidthPrev != 0 ? (upperBB - lowerBB) / sqzWidthPrev : 1.0
bool expansionConfirms = not i_expFilter or expansionRatio >= i_expMinRatio

bool longSignal  = squeezeBreakUp   and volConfirmsBull[1] and htfUp   and adxConfirms and bodyConfirms and expansionConfirms and barstate.isconfirmed
bool shortSignal = squeezeBreakDown and volConfirmsBear[1] and htfDown and adxConfirms and bodyConfirms and expansionConfirms and barstate.isconfirmed

float sqzWidthLocked = na(sqz[1]) ? 0.0 : (sqz[1]).widthAtStart
float slAtr14 = ta.atr(14)

var float entryLong = na
var float slLong = na
var float tp1Long = na
var float tp2Long = na
var float tp3Long = na
var float entryShort = na
var float slShort = na
var float tp1Short = na
var float tp2Short = na
var float tp3Short = na
var int lastSignalBar = na
var bool isLongActive = false
var bool isShortActive = false

if longSignal
    entryLong := close
    slLong := i_slMode == "Channel Edge" ? lowerBB[1] : close - slAtr14 * i_slAtrMult
    tp1Long := entryLong + sqzWidthLocked * i_tp1Fib
    tp2Long := entryLong + sqzWidthLocked * i_tp2Fib
    tp3Long := entryLong + sqzWidthLocked * i_tp3Fib
    lastSignalBar := bar_index
    isLongActive := true
    isShortActive := false

if shortSignal
    entryShort := close
    slShort := i_slMode == "Channel Edge" ? upperBB[1] : close + slAtr14 * i_slAtrMult
    tp1Short := entryShort - sqzWidthLocked * i_tp1Fib
    tp2Short := entryShort - sqzWidthLocked * i_tp2Fib
    tp3Short := entryShort - sqzWidthLocked * i_tp3Fib
    lastSignalBar := bar_index
    isShortActive := true
    isLongActive := false

bool tp1Hit = isLongActive and not na(tp1Long) and high >= tp1Long or isShortActive and not na(tp1Short) and low <= tp1Short
bool tp2Hit = isLongActive and not na(tp2Long) and high >= tp2Long or isShortActive and not na(tp2Short) and low <= tp2Short
bool tp3Hit = isLongActive and not na(tp3Long) and high >= tp3Long or isShortActive and not na(tp3Short) and low <= tp3Short

if tp3Hit
    isLongActive := false
    isShortActive := false

// ── ALERTS ──────────────────────────────────────────────────
string _longInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}"',
     i_actionLong, syminfo.tickerid, timeframe.period,
     str.tostring(close, format.mintick), str.tostring(slLong, format.mintick),
     str.tostring(tp1Long, format.mintick), str.tostring(tp2Long, format.mintick), str.tostring(tp3Long, format.mintick))
string longPayload = "{" + _longInner + "}"

string _shortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}"',
     i_actionShort, syminfo.tickerid, timeframe.period,
     str.tostring(close, format.mintick), str.tostring(slShort, format.mintick),
     str.tostring(tp1Short, format.mintick), str.tostring(tp2Short, format.mintick), str.tostring(tp3Short, format.mintick))
string shortPayload = "{" + _shortInner + "}"

string _closeLongInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closelong"',
     i_actionCloseLong, syminfo.tickerid, timeframe.period)
string closeLongPayload = "{" + _closeLongInner + "}"

string _closeShortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closeshort"',
     i_actionCloseShort, syminfo.tickerid, timeframe.period)
string closeShortPayload = "{" + _closeShortInner + "}"

string _mt741b = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","price":"{3}"', i_actionTP1, syminfo.tickerid, timeframe.period, str.tostring(isLongActive ? tp1Long : tp1Short, format.mintick))
string tp1Payload = "{" + _mt741b + "}"
string _tp2Inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","price":"{3}"', i_actionTP2, syminfo.tickerid, timeframe.period, str.tostring(isLongActive ? tp2Long : tp2Short, format.mintick))
string tp2Payload = "{" + _tp2Inner + "}"
string _tp3Inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","price":"{3}"', i_actionTP3, syminfo.tickerid, timeframe.period, str.tostring(isLongActive ? tp3Long : tp3Short, format.mintick))
string tp3Payload = "{" + _tp3Inner + "}"

if longSignal and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if longSignal and barstate.isconfirmed
    alert(closeShortPayload, alert.freq_once_per_bar_close)

if tp1Hit
    alert(tp1Payload, alert.freq_once_per_bar)
if tp2Hit
    alert(tp2Payload, alert.freq_once_per_bar)
if tp3Hit
    alert(tp3Payload, alert.freq_once_per_bar)

alertcondition(longSignal,  "BUY Signal",         "MarkitTick VSI — BUY Signal Fired")
alertcondition(shortSignal, "SELL Signal",        "MarkitTick VSI — SELL Signal Fired")
alertcondition(shortSignal, "Close Long Signal",  "MarkitTick VSI — Close Long")
alertcondition(longSignal,  "Close Short Signal", "MarkitTick VSI — Close Short")
alertcondition(tp1Hit, "TP1 Hit", "MarkitTick VSI — TP1 Hit")
alertcondition(tp2Hit, "TP2 Hit", "MarkitTick VSI — TP2 Hit")
alertcondition(tp3Hit, "TP3 Hit", "MarkitTick VSI — TP3 Hit")

// ── VISUALS ─────────────────────────────────────────────────
plot(basis, "BB Basis", c_bbLine, 1)
plot(upperKC, "KC Upper", c_kcLine, 1)
plot(lowerKC, "KC Lower", c_kcLine, 1)

bgcolor(i_showSqzBg and squeezeOn ? _mt741c : na, title="Active Squeeze BG")
bgcolor(i_showSqzBg and squeezeBreakUp and barstate.isconfirmed ? c_bullSqz : i_showSqzBg and squeezeBreakDown and barstate.isconfirmed ? c_bearSqz : na, title="Squeeze Break BG")

var line slLine = na
var line entryLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label slLbl = na
var label entryLbl = na
var label tp1Lbl = na
var label tp2Lbl = na
var label tp3Lbl = na
var linefill riskFill = na
var linefill rewardFill = na

f_deleteLevels() =>
    line.delete(slLine)
    line.delete(entryLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(slLbl)
    label.delete(entryLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    linefill.delete(riskFill)
    linefill.delete(rewardFill)

if i_showLevels and (longSignal or shortSignal)
    f_deleteLevels()
    float _entry = longSignal ? entryLong : entryShort
    float _sl    = longSignal ? slLong : slShort
    float _tp1   = longSignal ? tp1Long : tp1Short
    float _tp2   = longSignal ? tp2Long : tp2Short
    float _tp3   = longSignal ? tp3Long : tp3Short
    int _x2 = lastSignalBar + 50
    slLine    := line.new(bar_index, _sl, _x2, _sl, color=c_slColor, style=line.style_solid, width=2)
    entryLine := line.new(bar_index, _entry, _x2, _entry, color=c_entryColor, style=line.style_dashed, width=1)
    tp1Line   := line.new(bar_index, _tp1, _x2, _tp1, color=c_tp1Color, style=line.style_dashed, width=1)
    tp2Line   := line.new(bar_index, _tp2, _x2, _tp2, color=c_tp2Color, style=line.style_dashed, width=1)
    tp3Line   := line.new(bar_index, _tp3, _x2, _tp3, color=c_tp3Color, style=line.style_dashed, width=1)
    slLbl     := label.new(_x2, _sl, "✕ SL " + str.tostring(_sl, format.mintick), style=label.style_label_left, color=c_slColor, textcolor=c_lblTxt, size=size.small)
    entryLbl  := label.new(_x2, _entry, "▶ Entry " + str.tostring(_entry, format.mintick), style=label.style_label_left, color=c_entryColor, textcolor=c_lblTxt, size=size.small)
    tp1Lbl    := label.new(_x2, _tp1, "◆ TP1 " + str.tostring(_tp1, format.mintick), style=label.style_label_left, color=c_tp1Color, textcolor=c_lblTxt, size=size.small)
    tp2Lbl    := label.new(_x2, _tp2, "✦ TP2 " + str.tostring(_tp2, format.mintick), style=label.style_label_left, color=c_tp2Color, textcolor=c_lblTxt, size=size.small)
    tp3Lbl    := label.new(_x2, _tp3, "◆ TP3 " + str.tostring(_tp3, format.mintick), style=label.style_label_left, color=c_tp3Color, textcolor=c_lblTxt, size=size.small)
    riskFill  := linefill.new(slLine, entryLine, c_riskFill)
    rewardFill:= linefill.new(entryLine, tp3Line, c_rewardFill)

if i_showLevels and not na(slLine) and not na(lastSignalBar) and bar_index <= lastSignalBar + 50
    int _extX = lastSignalBar + 50
    line.set_x2(slLine, _extX)
    line.set_x2(entryLine, _extX)
    line.set_x2(tp1Line, _extX)
    line.set_x2(tp2Line, _extX)
    line.set_x2(tp3Line, _extX)
    label.set_x(slLbl, _extX)
    label.set_x(entryLbl, _extX)
    label.set_x(tp1Lbl, _extX)
    label.set_x(tp2Lbl, _extX)
    label.set_x(tp3Lbl, _extX)

// ── DASHBOARD ───────────────────────────────────────────────
f_barColor(float pct) =>
    pct >= 0.66 ? c_barGreen : pct >= 0.33 ? c_barYellow : c_barRed

f_bar(float val, float maxVal) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(math.min(val / maxVal, 1.0) * 100)) + "%"

var table dash = table.new(i_dashPos == "top_right" ? position.top_right : i_dashPos == "top_left" ? position.top_left : i_dashPos == "bottom_right" ? position.bottom_right : position.bottom_left, 2, 16, bgcolor=c_dashBg)

if i_showDash
    table.cell(dash, 0, 0, "VSI [MarkitTick]", text_color=c_dashValue, bgcolor=c_dashHeader, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", bgcolor=c_dashHeader)

    table.cell(dash, 0, 1, "Squeeze", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 1, squeezeOn ? "ACTIVE" : "OFF", text_color=squeezeOn ? f_barColor(1.0) : f_barColor(0.0), bgcolor=c_dashBg, text_size=size.small)

    table.cell(dash, 0, 2, "Sqz Bars", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(sqzBarCount), text_color=c_dashValue, bgcolor=c_dashBg, text_size=size.small)

    float bbWidthPct = basis != 0 ? (upperBB - lowerBB) / basis * 100 : 0.0
    table.cell(dash, 0, 3, "BB Width %", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 3, f_bar(bbWidthPct, 10.0), text_color=f_barColor(math.min(bbWidthPct / 10.0, 1.0)), bgcolor=c_dashBg, text_size=size.small)

    table.cell(dash, 0, 4, "Delta Ratio", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 4, f_bar(deltaRatio, 1.0), text_color=f_barColor(deltaRatio), bgcolor=c_dashBg, text_size=size.small)

    string biasTxt = sqz.deltaSum > 0 ? "BULLISH" : sqz.deltaSum < 0 ? "BEARISH" : "NEUTRAL"
    table.cell(dash, 0, 5, "Delta Bias", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 5, biasTxt, text_color=sqz.deltaSum > 0 ? c_deltaBull : sqz.deltaSum < 0 ? c_deltaBear : c_dashValue, bgcolor=c_dashBg, text_size=size.small)

    table.cell(dash, 0, 6, "Active Dir", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 6, isLongActive ? "LONG" : isShortActive ? "SHORT" : "NONE", text_color=isLongActive ? c_deltaBull : isShortActive ? c_deltaBear : c_dashValue, bgcolor=c_dashBg, text_size=size.small)

    float rr = isLongActive and not na(slLong) and entryLong != slLong ? math.abs(tp1Long - entryLong) / math.abs(entryLong - slLong) : isShortActive and not na(slShort) and entryShort != slShort ? math.abs(tp1Short - entryShort) / math.abs(entryShort - slShort) : 0.0
    table.cell(dash, 0, 7, "R:R (TP1)", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 7, f_bar(rr, 5.0), text_color=f_barColor(math.min(rr / 5.0, 1.0)), bgcolor=c_dashBg, text_size=size.small)

    table.cell(dash, 0, 8, "HTF Trend", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 8, not i_htfFilter ? "OFF" : htfUp ? "UP" : "DOWN", text_color=not i_htfFilter ? c_dashValue : htfUp ? c_deltaBull : c_deltaBear, bgcolor=c_dashBg, text_size=size.small)

    table.cell(dash, 0, 9, "ADX", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 9, f_bar(adxVal, 50.0), text_color=f_barColor(math.min(adxVal / 50.0, 1.0)), bgcolor=c_dashBg, text_size=size.small)

    table.cell(dash, 0, 10, "Body Strength", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 10, f_bar(bodyPct, 100.0), text_color=f_barColor(bodyPct / 100.0), bgcolor=c_dashBg, text_size=size.small)

    table.cell(dash, 0, 11, "Expansion", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 11, f_bar(expansionRatio, 2.0), text_color=f_barColor(math.min(expansionRatio / 2.0, 1.0)), bgcolor=c_dashBg, text_size=size.small)

    string volTxt = not i_volFilter ? "OFF" : volConfirmsBull ? "BULL OK" : volConfirmsBear ? "BEAR OK" : "NO"
    table.cell(dash, 0, 12, "Vol Confirm", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 12, volTxt, text_color=not i_volFilter ? c_dashValue : volConfirmsBull ? c_deltaBull : volConfirmsBear ? c_deltaBear : c_barRed, bgcolor=c_dashBg, text_size=size.small)

    float rr2 = isLongActive and not na(slLong) and entryLong != slLong ? math.abs(tp2Long - entryLong) / math.abs(entryLong - slLong) : isShortActive and not na(slShort) and entryShort != slShort ? math.abs(tp2Short - entryShort) / math.abs(entryShort - slShort) : 0.0
    table.cell(dash, 0, 13, "R:R (TP2)", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 13, f_bar(rr2, 8.0), text_color=f_barColor(math.min(rr2 / 8.0, 1.0)), bgcolor=c_dashBg, text_size=size.small)

    float rr3 = isLongActive and not na(slLong) and entryLong != slLong ? math.abs(tp3Long - entryLong) / math.abs(entryLong - slLong) : isShortActive and not na(slShort) and entryShort != slShort ? math.abs(tp3Short - entryShort) / math.abs(entryShort - slShort) : 0.0
    table.cell(dash, 0, 14, "R:R (TP3)", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 14, f_bar(rr3, 12.0), text_color=f_barColor(math.min(rr3 / 12.0, 1.0)), bgcolor=c_dashBg, text_size=size.small)

    int barsSinceSignal = na(lastSignalBar) ? 0 : bar_index - lastSignalBar
    table.cell(dash, 0, 15, "Bars Since Sig", text_color=c_dashLabel, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 15, na(lastSignalBar) ? "—" : str.tostring(barsSinceSignal), text_color=c_dashValue, bgcolor=c_dashBg, text_size=size.small)
````
