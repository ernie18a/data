# Mirage Liquidity Sweep (MLS) [JPT]

- url: https://www.tradingview.com/script/rrhWfPGy-Mirage-Liquidity-Sweep-MLS-JPT/
- type: indicator
- pine_id: PUB;4e5c1ac45ad946f1942010e49ccf3d44
- version: 1.0

## Description

[b]🔷 OVERVIEW[/b]

[b]Mirage Liquidity Sweep (MLS) [JPT][/b] is a smart price-action indicator designed to identify potential trading opportunities by combining liquidity sweeps, market structure shifts (MSS), displacement candles, and Fair Value Gaps (FVG).

It includes a signal scoring system, higher-timeframe trend bias, premium/discount filtering, volume confirmation, entry and exit levels, and a real-time trade management dashboard to help traders make more structured trading decisions.

[b]🔷 HOW IT WORKS[/b]

- Liquidity Sweeps: Identifies when price takes out previous swing highs or lows and closes back inside the level, potentially signaling a reversal.
- Market Structure Shift (MSS): Confirms potential directional changes by detecting breaks of recent market structure.
- Displacement Confirmation: Looks for strong candles with sufficient range and body strength to indicate momentum.
- Fair Value Gaps (FVG): Detects potential imbalance zones that may help identify areas of interest.
- Signal Scoring: Assigns a score from 0 to 100 based on sweep strength, displacement, MSS, volume, higher-timeframe bias, premium/discount position, and FVG confirmation.
- Trend and Volume Filters: Uses a higher-timeframe EMA, volume strength, and premium/discount conditions to help filter weaker setups.
- Risk Management: Calculates entry, stop-loss (SL), and three take-profit targets (TP1, TP2, TP3) based on ATR and configurable risk-to-reward multiples.
- Trade Monitoring: Tracks target hits, optional break-even stop adjustments, win/loss statistics, and recent trade outcomes.
- Alerts and Visuals: Displays entry signals, liquidity levels, FVG zones, risk levels, dashboard statistics, and optional text or JSON alerts.

🔷 [b]HOW TO USE[/b]

1. Add the indicator to your TradingView chart using Pine Script v6.
2. Adjust the liquidity swing length, minimum signal score, and cooldown settings according to your trading style.
3. Enable or disable confirmation filters such as MSS, displacement, volume, higher-timeframe bias, premium/discount, and FVG confirmation.
4. Wait for a confirmed JPT LONG or JPT SHORT signal. Review the signal score and overall market conditions before considering a trade.
5. Use the displayed entry, stop-loss, and TP1/TP2/TP3 levels to plan risk and potential reward.
6. Monitor the dashboard for trend bias, trade status, target levels, and recorded outcomes.
7. Configure TradingView alerts to receive entry and take-profit notifications when the relevant alert conditions are triggered.

[b]🔷 IMPORTANT NOTE[/b]

This indicator is a technical analysis tool, not a guarantee of profitable trades. Liquidity sweeps and structure breaks can produce false signals, particularly in volatile or sideways markets. Signals are confirmed at candle close, but actual execution prices may differ because of slippage, spreads, and market conditions.

The built-in win rate and trade statistics are based on the script's simplified internal trade-tracking logic; they are not a substitute for a proper TradingView strategy backtest and do not account for commissions, slippage, or position sizing. The break-even feature, stop-loss handling, and target-hit logic should also be independently tested before relying on them for live trading.

[quote][i]Always use appropriate risk management and test the indicator on historical data and in a demo environment before trading with real capital.[/i][/quote]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
// 2. INPUTS
// ═══════════════════════════════════════════════════════════════

// Core//@version=6
// ═══════════════════════════════════════════════════════════════
// MIRAGE LIQUIDITY SWEEP (MLS) [JPT]
// ═══════════════════════════════════════════════════════════════
// Liquidity Sweep + Displacement + MSS + FVG
// Pine Script v6
// ═══════════════════════════════════════════════════════════════

indicator(
     "Mirage Liquidity Sweep (MLS) [JPT]",
     shorttitle = "Mirage LS [JPT]",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 300,
     max_bars_back = 5000)

// ═══════════════════════════════════════════════════════════════
// 1. GROUPS
// ═══════════════════════════════════════════════════════════════

G_MAIN   = "⚙️ Core Engine"
G_CONFIRM = "🧠 Confirmation"
G_FILTER = "🔍 Filters"
G_RISK   = "🛡 Risk"
G_LIQ    = "💧 Liquidity"
G_FVG    = "📦 Fair Value Gap"
G_VIS    = "🎨 Visuals"
G_DASH   = "📊 Dashboard"
G_ALERT  = "🔔 Alerts"

// ═══════════════════════════════════════════════════════════════
swingLen = input.int(
     15, "Liquidity Swing Length",
     minval = 3, maxval = 60, group = G_MAIN)

poolLookback = input.int(
     120, "Liquidity Validity Bars",
     minval = 20, maxval = 500, group = G_MAIN)

minScore = input.int(
     60, "Minimum Signal Score",
     minval = 0, maxval = 100, group = G_MAIN)

cooldownBars = input.int(
     5, "Signal Cooldown",
     minval = 0, maxval = 50, group = G_MAIN)

// Confirmation
useMSS = input.bool(
     true, "Require Market Structure Shift", group = G_CONFIRM)

mssLen = input.int(
     5, "MSS Pivot Length",
     minval = 2, maxval = 20, group = G_CONFIRM)

useDisplacement = input.bool(
     true, "Require Displacement Candle", group = G_CONFIRM)

dispATR = input.float(
     0.8, "Minimum Candle Range × ATR",
     minval = 0.1, maxval = 5.0, step = 0.1, group = G_CONFIRM)

useBodyFilter = input.bool(
     true, "Strong Body Filter", group = G_CONFIRM)

minBodyPct = input.float(
     55, "Minimum Body %",
     minval = 10, maxval = 100, step = 5, group = G_CONFIRM)

// Filters
useVolume = input.bool(
     true, "Volume Confirmation", group = G_FILTER)

volumeLen = input.int(
     20, "Volume Average Length",
     minval = 2, maxval = 200, group = G_FILTER)

volumeBoost = input.float(
     1.2, "Volume Boost",
     minval = 1.0, maxval = 5.0, step = 0.1, group = G_FILTER)

useHTF = input.bool(
     true, "Higher-Timeframe Bias", group = G_FILTER)

htfTF = input.timeframe(
     "240", "HTF", group = G_FILTER)

htfEMA = input.int(
     50, "HTF EMA Length",
     minval = 5, maxval = 300, group = G_FILTER)

usePremiumDiscount = input.bool(
     true, "Premium / Discount Filter", group = G_FILTER)

pdLookback = input.int(
     50, "PD Range Lookback",
     minval = 10, maxval = 300, group = G_FILTER)

useFVGFilter = input.bool(
     false, "Require FVG Confirmation", group = G_FVG)

showFVG = input.bool(
     true, "Show FVG Zones", group = G_FVG)

fvgExtend = input.int(
     20, "FVG Extension",
     minval = 1, maxval = 100, group = G_FVG)

// Risk
atrLen = input.int(
     14, "ATR Length", minval = 5, maxval = 100, group = G_RISK)

slATR = input.float(
     0.25, "SL Buffer × ATR",
     minval = 0, maxval = 3, step = 0.05, group = G_RISK)

minRiskATR = input.float(
     0.5, "Minimum Risk × ATR",
     minval = 0.1, maxval = 5, step = 0.1, group = G_RISK)

tp1R = input.float(
     1.0, "TP1 R", minval = 0.5, maxval = 10, step = 0.1, group = G_RISK)

tp2R = input.float(
     2.0, "TP2 R", minval = 1, maxval = 15, step = 0.1, group = G_RISK)

tp3R = input.float(
     3.0, "TP3 R", minval = 1.5, maxval = 20, step = 0.1, group = G_RISK)

breakEven = input.bool(
     true, "Move SL to BE After TP1", group = G_RISK)

closeAtTP3 = input.bool(
     true, "Close Trade at TP3", group = G_RISK)

// Liquidity
showLiquidity = input.bool(
     true, "Show Resting Liquidity", group = G_LIQ)

maxLiquidity = input.int(
     5, "Liquidity Levels / Side",
     minval = 1, maxval = 20, group = G_LIQ)

showEqual = input.bool(
     true, "Detect Equal Highs/Lows", group = G_LIQ)

equalATR = input.float(
     0.12, "Equal H/L Tolerance × ATR",
     minval = 0.01, maxval = 1, step = 0.01, group = G_LIQ)

showTargets = input.bool(
     true, "Show Draw-on-Liquidity Target", group = G_LIQ)

// Visuals
showSweep = input.bool(
     true, "Show Sweep Marks", group = G_VIS)

showSignals = input.bool(
     true, "Show Entry Signals", group = G_VIS)

showRisk = input.bool(
     true, "Show Entry / SL / TP", group = G_VIS)

showScore = input.bool(
     false, "Show Signal Score", group = G_VIS)

showDashboard = input.bool(
     true, "Show Dashboard", group = G_DASH)

showWatermark = input.bool(
     true, "Show Watermark", group = G_DASH)

// Alerts
enableAlerts = input.bool(
     true, "Enable Entry Alerts", group = G_ALERT)

jsonAlerts = input.bool(
     false, "Use JSON Alerts", group = G_ALERT)

alertTP = input.bool(
     true, "TP / BE Alerts", group = G_ALERT)

// ═══════════════════════════════════════════════════════════════
// 3. COLORS
// ═══════════════════════════════════════════════════════════════

BULL = #00E676
BEAR = #FF5252
BLUE = #42A5F5
GOLD = #FFD54F
CYAN = #26C6DA
PURPLE = #AB47BC
WHITE = #FFFFFF
MUTED = #90A4AE
DARK = #111827

SL_COL = #EF5350
TP_COL = #66BB6A
BE_COL = #FFA726

// ═══════════════════════════════════════════════════════════════
// 4. HELPERS
// ═══════════════════════════════════════════════════════════════

f_lineStyle(string x) =>
    x == "Dashed" ? line.style_dashed :
     x == "Dotted" ? line.style_dotted :
     line.style_solid

f_pct(float a, float b) =>
    b != 0 ? math.abs(a - b) / math.abs(b) * 100 : 0

f_score(
     float sweepScore,
     float displacementScore,
     float mssScore,
     float volumeScore,
     float htfScore,
     float pdScore,
     float fvgScore) =>

    math.min(
         100,
         sweepScore * 0.25 +
         displacementScore * 0.20 +
         mssScore * 0.20 +
         volumeScore * 0.10 +
         htfScore * 0.10 +
         pdScore * 0.10 +
         fvgScore * 0.05)

// ═══════════════════════════════════════════════════════════════
// 5. BASE DATA
// ═══════════════════════════════════════════════════════════════

atr = ta.atr(atrLen)

rng = high - low
body = math.abs(close - open)

bodyPct = rng > 0 ? body / rng * 100 : 0

bullCandle = close > open
bearCandle = close < open

bullDisplacement =
     bullCandle and
     rng >= atr * dispATR and
     (not useBodyFilter or bodyPct >= minBodyPct)

bearDisplacement =
     bearCandle and
     rng >= atr * dispATR and
     (not useBodyFilter or bodyPct >= minBodyPct)

// Volume
volMA = ta.sma(volume, volumeLen)

volumeAvailable = nz(volume, 0) > 0

volumeStrong =
     volumeAvailable and
     not na(volMA) and
     volMA > 0 and
     volume >= volMA * volumeBoost

volumeScore =
     not useVolume ? 100 :
     volumeStrong ? 100 : 35

// ═══════════════════════════════════════════════════════════════
// 6. HIGHER TIMEFRAME BIAS
// ═══════════════════════════════════════════════════════════════

[htfClose, htfEMAValue] =
     request.security(
         syminfo.tickerid,
         htfTF,
         [close[1], ta.ema(close, htfEMA)[1]],
         barmerge.gaps_off,
         barmerge.lookahead_on)

htfBull = htfClose > htfEMAValue
htfBear = htfClose < htfEMAValue

htfBullScore =
     not useHTF ? 100 :
     htfBull ? 100 : 20

htfBearScore =
     not useHTF ? 100 :
     htfBear ? 100 : 20

// ═══════════════════════════════════════════════════════════════
// 7. LIQUIDITY MEMORY
// ═══════════════════════════════════════════════════════════════

var array<float> highs = array.new<float>()
var array<int> highBars = array.new<int>()
var array<bool> highTaken = array.new<bool>()

var array<float> lows = array.new<float>()
var array<int> lowBars = array.new<int>()
var array<bool> lowTaken = array.new<bool>()

ph = ta.pivothigh(swingLen, swingLen)
pl = ta.pivotlow(swingLen, swingLen)

if not na(ph)
    array.push(highs, ph)
    array.push(highBars, bar_index - swingLen)
    array.push(highTaken, false)

if not na(pl)
    array.push(lows, pl)
    array.push(lowBars, bar_index - swingLen)
    array.push(lowTaken, false)

if array.size(highs) > 30
    array.shift(highs)
    array.shift(highBars)
    array.shift(highTaken)

if array.size(lows) > 30
    array.shift(lows)
    array.shift(lowBars)
    array.shift(lowTaken)

// ═══════════════════════════════════════════════════════════════
// 8. LIQUIDITY SWEEP ENGINE
// ═══════════════════════════════════════════════════════════════

bool bullishSweep = false
bool bearishSweep = false

float bullLevel = na
float bearLevel = na

float bullSweepDepth = 0
float bearSweepDepth = 0

int bullOrigin = na
int bearOrigin = na

// Sell-side liquidity swept
if array.size(lows) > 0
    for i = array.size(lows) - 1 to 0

        lvl = array.get(lows, i)
        b = array.get(lowBars, i)
        used = array.get(lowTaken, i)

        validAge = bar_index - b <= poolLookback

        if not used and validAge

            if close < lvl
                array.set(lowTaken, i, true)

            else if low < lvl and close > lvl

                array.set(lowTaken, i, true)

                if not bullishSweep
                    bullishSweep := true
                    bullLevel := lvl
                    bullOrigin := b
                    bullSweepDepth := lvl - low

// Buy-side liquidity swept
if array.size(highs) > 0
    for i = array.size(highs) - 1 to 0

        lvl = array.get(highs, i)
        b = array.get(highBars, i)
        used = array.get(highTaken, i)

        validAge = bar_index - b <= poolLookback

        if not used and validAge

            if close > lvl
                array.set(highTaken, i, true)

            else if high > lvl and close < lvl

                array.set(highTaken, i, true)

                if not bearishSweep
                    bearishSweep := true
                    bearLevel := lvl
                    bearOrigin := b
                    bearSweepDepth := high - lvl

// ═══════════════════════════════════════════════════════════════
// 9. MARKET STRUCTURE SHIFT
// ═══════════════════════════════════════════════════════════════

mHigh = ta.pivothigh(mssLen, mssLen)
mLow = ta.pivotlow(mssLen, mssLen)

var float structureHigh = na
var float structureLow = na

if not na(mHigh)
    structureHigh := mHigh

if not na(mLow)
    structureLow := mLow

bullMSS =
     not na(structureHigh) and
     close > structureHigh

bearMSS =
     not na(structureLow) and
     close < structureLow

// ═══════════════════════════════════════════════════════════════
// 10. FAIR VALUE GAP
// ═══════════════════════════════════════════════════════════════

bullFVG =
     bar_index >= 2 and
     low > high[2]

bearFVG =
     bar_index >= 2 and
     high < low[2]

var float bullFvgTop = na
var float bullFvgBottom = na
var int bullFvgBar = na

var float bearFvgTop = na
var float bearFvgBottom = na
var int bearFvgBar = na

if bullFVG
    bullFvgTop := low
    bullFvgBottom := high[2]
    bullFvgBar := bar_index

if bearFVG
    bearFvgTop := low[2]
    bearFvgBottom := high
    bearFvgBar := bar_index

bullFVGValid =
     not na(bullFvgBar) and
     bar_index - bullFvgBar <= 10

bearFVGValid =
     not na(bearFvgBar) and
     bar_index - bearFvgBar <= 10

fvgBullScore =
     not useFVGFilter ? 100 :
     bullFVGValid ? 100 : 20

fvgBearScore =
     not useFVGFilter ? 100 :
     bearFVGValid ? 100 : 20

// ═══════════════════════════════════════════════════════════════
// 11. PREMIUM / DISCOUNT
// ═══════════════════════════════════════════════════════════════

rangeHigh = ta.highest(high, pdLookback)
rangeLow = ta.lowest(low, pdLookback)

rangeMid = (rangeHigh + rangeLow) / 2

discount =
     close <= rangeMid

premium =
     close >= rangeMid

pdBullScore =
     not usePremiumDiscount ? 100 :
     discount ? 100 : 20

pdBearScore =
     not usePremiumDiscount ? 100 :
     premium ? 100 : 20

// ═══════════════════════════════════════════════════════════════
// 12. SWEEP QUALITY
// ═══════════════════════════════════════════════════════════════

bullSweepScore =
     bullishSweep and atr > 0 ?
     math.min(100, bullSweepDepth / atr * 100) :
     0

bearSweepScore =
     bearishSweep and atr > 0 ?
     math.min(100, bearSweepDepth / atr * 100) :
     0

bullDispScore =
     bullDisplacement ? 100 : 20

bearDispScore =
     bearDisplacement ? 100 : 20

bullMSSScore =
     not useMSS ? 100 :
     bullMSS ? 100 : 15

bearMSSScore =
     not useMSS ? 100 :
     bearMSS ? 100 : 15

bullScore =
     f_score(
         bullSweepScore,
         bullDispScore,
         bullMSSScore,
         volumeScore,
         htfBullScore,
         pdBullScore,
         fvgBullScore)

bearScore =
     f_score(
         bearSweepScore,
         bearDispScore,
         bearMSSScore,
         volumeScore,
         htfBearScore,
         pdBearScore,
         fvgBearScore)

// ═══════════════════════════════════════════════════════════════
// 13. SIGNAL ENGINE
// ═══════════════════════════════════════════════════════════════

var int lastSignalBar = na

cooldownOK =
     na(lastSignalBar) or
     bar_index - lastSignalBar > cooldownBars

rawLong =
     bullishSweep and
     bullScore >= minScore and
     cooldownOK

rawShort =
     bearishSweep and
     bearScore >= minScore and
     cooldownOK

longSignal =
     rawLong and
     (not useDisplacement or bullDisplacement) and
     (not useMSS or bullMSS)

shortSignal =
     rawShort and
     (not useDisplacement or bearDisplacement) and
     (not useMSS or bearMSS)

longSignal :=
     longSignal and
     barstate.isconfirmed

shortSignal :=
     shortSignal and
     barstate.isconfirmed

// Prevent both directions simultaneously
if longSignal and shortSignal
    if bullScore > bearScore
        shortSignal := false
    else
        longSignal := false

if longSignal or shortSignal
    lastSignalBar := bar_index

// ═══════════════════════════════════════════════════════════════
// 14. POSITION ENGINE
// ═══════════════════════════════════════════════════════════════

var int position = 0

var float entry = na
var float stop = na
var float target1 = na
var float target2 = na
var float target3 = na

var bool hitTP1 = false
var bool hitTP2 = false
var bool hitTP3 = false
var bool movedBE = false

var int wins = 0
var int losses = 0

var string recentForm = ""

canEnter = position == 0

enterLong =
     longSignal and
     canEnter and
     atr > 0

enterShort =
     shortSignal and
     canEnter and
     atr > 0

if enterLong

    position := 1
    entry := close

    rawStop = bullLevel - atr * slATR

    risk = entry - rawStop

    if risk < atr * minRiskATR
        rawStop := entry - atr * minRiskATR
        risk := atr * minRiskATR

    stop := rawStop

    target1 := entry + risk * tp1R
    target2 := entry + risk * tp2R
    target3 := entry + risk * tp3R

    hitTP1 := false
    hitTP2 := false
    hitTP3 := false
    movedBE := false

if enterShort

    position := -1
    entry := close

    rawStop = bearLevel + atr * slATR

    risk = rawStop - entry

    if risk < atr * minRiskATR
        rawStop := entry + atr * minRiskATR
        risk := atr * minRiskATR

    stop := rawStop

    target1 := entry - risk * tp1R
    target2 := entry - risk * tp2R
    target3 := entry - risk * tp3R

    hitTP1 := false
    hitTP2 := false
    hitTP3 := false
    movedBE := false

// ═══════════════════════════════════════════════════════════════
// 15. TRADE MANAGEMENT
// ═══════════════════════════════════════════════════════════════

activeBar =
     position != 0 and
     bar_index > lastSignalBar and
     barstate.isconfirmed

longSL =
     activeBar and
     position == 1 and
     low <= stop

shortSL =
     activeBar and
     position == -1 and
     high >= stop

longTP1 =
     activeBar and
     position == 1 and
     high >= target1

shortTP1 =
     activeBar and
     position == -1 and
     low <= target1

longTP2 =
     activeBar and
     position == 1 and
     high >= target2

shortTP2 =
     activeBar and
     position == -1 and
     low <= target2

longTP3 =
     activeBar and
     position == 1 and
     high >= target3

shortTP3 =
     activeBar and
     position == -1 and
     low <= target3

tp1Touch =
     (longTP1 or shortTP1) and not hitTP1 and not longSL and not shortSL

tp2Touch =
     (longTP2 or shortTP2) and not hitTP2 and not longSL and not shortSL

tp3Touch =
     (longTP3 or shortTP3) and not hitTP3 and not longSL and not shortSL

if tp1Touch
    hitTP1 := true

if tp2Touch
    hitTP2 := true

if tp3Touch
    hitTP3 := true

if breakEven and tp1Touch and not movedBE
    stop := entry
    movedBE := true

tradeClosed = false
tradeWon = false

if position != 0

    stopHit =
         position == 1 ? low <= stop :
         high >= stop

    finalTPHit =
         closeAtTP3 and
         (position == 1 ? high >= target3 : low <= target3)

    if stopHit or finalTPHit

        tradeClosed := true

        tradeWon :=
             hitTP1 or
             hitTP2 or
             hitTP3 or
             finalTPHit

        if tradeWon
            wins += 1
            recentForm += "W"
        else
            losses += 1
            recentForm += "L"

        if str.length(recentForm) > 10
            recentForm := str.substring(
                 recentForm,
                 str.length(recentForm) - 10)

        position := 0
        entry := na
        stop := na
        target1 := na
        target2 := na
        target3 := na

        hitTP1 := false
        hitTP2 := false
        hitTP3 := false
        movedBE := false

// ═══════════════════════════════════════════════════════════════
// 16. SWEEP VISUALS
// ═══════════════════════════════════════════════════════════════

plotshape(
     showSweep and bullishSweep,
     title = "Sell-Side Sweep",
     style = shape.xcross,
     location = location.belowbar,
     color = color.new(BULL, 20),
     size = size.tiny)

plotshape(
     showSweep and bearishSweep,
     title = "Buy-Side Sweep",
     style = shape.xcross,
     location = location.abovebar,
     color = color.new(BEAR, 20),
     size = size.tiny)

plotshape(
     showSignals and enterLong,
     title = "JPT Long",
     style = shape.labelup,
     location = location.belowbar,
     color = BULL,
     textcolor = #003B20,
     text = "JPT LONG",
     size = size.small)

plotshape(
     showSignals and enterShort,
     title = "JPT Short",
     style = shape.labeldown,
     location = location.abovebar,
     color = BEAR,
     textcolor = WHITE,
     text = "JPT SHORT",
     size = size.small)

// ═══════════════════════════════════════════════════════════════
// 17. SCORE LABELS
// ═══════════════════════════════════════════════════════════════

if showScore and enterLong
    label.new(
         bar_index,
         low - atr * 0.5,
         "LQ " + str.tostring(bullScore, "#"),
         style = label.style_none,
         textcolor = BULL,
         size = size.small)

if showScore and enterShort
    label.new(
         bar_index,
         high + atr * 0.5,
         "LQ " + str.tostring(bearScore, "#"),
         style = label.style_none,
         textcolor = BEAR,
         size = size.small)

// ═══════════════════════════════════════════════════════════════
// 18. SWEEP LEVELS
// ═══════════════════════════════════════════════════════════════

var array<line> sweepLines = array.new<line>()

if bullishSweep
    ln = line.new(
         bullOrigin,
         bullLevel,
         bar_index + 15,
         bullLevel,
         color = color.new(BULL, 35),
         style = line.style_dashed,
         width = 1)

    array.push(sweepLines, ln)

if bearishSweep
    ln = line.new(
         bearOrigin,
         bearLevel,
         bar_index + 15,
         bearLevel,
         color = color.new(BEAR, 35),
         style = line.style_dashed,
         width = 1)

    array.push(sweepLines, ln)

if array.size(sweepLines) > 30
    old = array.shift(sweepLines)
    line.delete(old)

// ═══════════════════════════════════════════════════════════════
// 19. FVG BOXES
// ═══════════════════════════════════════════════════════════════

var array<box> fvgBoxes = array.new<box>()

if showFVG and bullFVG
    bx = box.new(
         bar_index - 2,
         bullFvgTop,
         bar_index + fvgExtend,
         bullFvgBottom,
         bgcolor = color.new(BULL, 90),
         border_color = color.new(BULL, 55))

    array.push(fvgBoxes, bx)

if showFVG and bearFVG
    bx = box.new(
         bar_index - 2,
         bearFvgTop,
         bar_index + fvgExtend,
         bearFvgBottom,
         bgcolor = color.new(BEAR, 90),
         border_color = color.new(BEAR, 55))

    array.push(fvgBoxes, bx)

if array.size(fvgBoxes) > 30
    oldBox = array.shift(fvgBoxes)
    box.delete(oldBox)

// ═══════════════════════════════════════════════════════════════
// 20. RESTING LIQUIDITY
// ═══════════════════════════════════════════════════════════════

var array<line> liquidityLines = array.new<line>()

if showLiquidity and barstate.islast

    if array.size(liquidityLines) > 0
        for i = 0 to array.size(liquidityLines) - 1
            line.delete(array.get(liquidityLines, i))

    array.clear(liquidityLines)

    drawnHighs = 0

    if array.size(highs) > 0
        for i = array.size(highs) - 1 to 0

            if drawnHighs >= maxLiquidity
                break

            if not array.get(highTaken, i)

                l = line.new(
                     array.get(highBars, i),
                     array.get(highs, i),
                     bar_index + 10,
                     array.get(highs, i),
                     color = color.new(BEAR, 60),
                     style = line.style_dotted)

                array.push(liquidityLines, l)

                drawnHighs += 1

    drawnLows = 0

    if array.size(lows) > 0
        for i = array.size(lows) - 1 to 0

            if drawnLows >= maxLiquidity
                break

            if not array.get(lowTaken, i)

                l = line.new(
                     array.get(lowBars, i),
                     array.get(lows, i),
                     bar_index + 10,
                     array.get(lows, i),
                     color = color.new(BULL, 60),
                     style = line.style_dotted)

                array.push(liquidityLines, l)

                drawnLows += 1

// ═══════════════════════════════════════════════════════════════
// 21. DRAW-ON-LIQUIDITY TARGET
// ═══════════════════════════════════════════════════════════════

var line targetLine = na
var label targetLabel = na

if showTargets and (enterLong or enterShort)

    line.delete(targetLine)
    label.delete(targetLabel)

    float targetLiquidity = na

    if enterLong

        if array.size(highs) > 0
            for i = 0 to array.size(highs) - 1

                lvl = array.get(highs, i)

                if not array.get(highTaken, i) and lvl > close
                    if na(targetLiquidity) or lvl < targetLiquidity
                        targetLiquidity := lvl

    if enterShort

        if array.size(lows) > 0
            for i = 0 to array.size(lows) - 1

                lvl = array.get(lows, i)

                if not array.get(lowTaken, i) and lvl < close
                    if na(targetLiquidity) or lvl > targetLiquidity
                        targetLiquidity := lvl

    if not na(targetLiquidity)

        targetLine := line.new(
             bar_index,
             targetLiquidity,
             bar_index + 20,
             targetLiquidity,
             color = GOLD,
             style = line.style_dashed,
             width = 2)

        targetLabel := label.new(
             bar_index + 20,
             targetLiquidity,
             "◎ LIQ TARGET",
             style = label.style_label_left,
             color = color.new(color.black, 100),
             textcolor = GOLD,
             size = size.small)

// ═══════════════════════════════════════════════════════════════
// 22. RISK DRAWINGS
// ═══════════════════════════════════════════════════════════════

var line entryLine = na
var line stopLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na

if (enterLong or enterShort) and showRisk

    line.delete(entryLine)
    line.delete(stopLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)

    entryLine := line.new(
         bar_index,
         entry,
         bar_index + 20,
         entry,
         color = BLUE,
         style = line.style_dotted)

    stopLine := line.new(
         bar_index,
         stop,
         bar_index + 20,
         stop,
         color = SL_COL,
         width = 2)

    tp1Line := line.new(
         bar_index,
         target1,
         bar_index + 20,
         target1,
         color = color.new(TP_COL, 25),
         style = line.style_dashed)

    tp2Line := line.new(
         bar_index,
         target2,
         bar_index + 20,
         target2,
         color = color.new(TP_COL, 10),
         style = line.style_dashed)

    tp3Line := line.new(
         bar_index,
         target3,
         bar_index + 20,
         target3,
         color = TP_COL,
         width = 2)

// Extend active risk lines
if position != 0 and showRisk

    line.set_x2(entryLine, bar_index + 10)
    line.set_x2(stopLine, bar_index + 10)
    line.set_x2(tp1Line, bar_index + 10)
    line.set_x2(tp2Line, bar_index + 10)
    line.set_x2(tp3Line, bar_index + 10)

    if movedBE
        line.set_color(stopLine, color.new(BE_COL, 10))

// ═══════════════════════════════════════════════════════════════
// 23. TP STATUS
// ═══════════════════════════════════════════════════════════════

if hitTP1 and not na(tp1Line)
    line.set_color(tp1Line, CYAN)
    line.set_style(tp1Line, line.style_solid)

if hitTP2 and not na(tp2Line)
    line.set_color(tp2Line, CYAN)
    line.set_style(tp2Line, line.style_solid)

if hitTP3 and not na(tp3Line)
    line.set_color(tp3Line, CYAN)
    line.set_style(tp3Line, line.style_solid)

// ═══════════════════════════════════════════════════════════════
// 24. DASHBOARD
// ═══════════════════════════════════════════════════════════════

var table dash = na

if showDashboard and barstate.islast

    if not na(dash)
        table.delete(dash)

    dash := table.new(
         position.top_right,
         2,
         12,
         bgcolor = color.new(DARK, 5),
         border_color = color.new(MUTED, 65),
         border_width = 1)

    biasText =
         not useHTF ? "OFF" :
         htfBull ? "BULLISH" :
         htfBear ? "BEARISH" : "NEUTRAL"

    biasColor =
         htfBull ? BULL :
         htfBear ? BEAR :
         MUTED

    stateText =
         position == 1 ? "LONG" :
         position == -1 ? "SHORT" :
         "WAIT"

    stateColor =
         position == 1 ? BULL :
         position == -1 ? BEAR :
         GOLD

    closedTrades = wins + losses

    winRate =
         closedTrades > 0 ?
         wins / float(closedTrades) * 100 :
         0

    scoreDisplay =
         bullishSweep ? bullScore :
         bearishSweep ? bearScore :
         0

    table.cell(
         dash, 0, 0,
         "◆ MIRAGE LQ [JPT]",
         text_color = WHITE,
         bgcolor = PURPLE,
         text_size = size.normal)

    table.cell(
         dash, 1, 0,
         "v1.0",
         text_color = WHITE,
         bgcolor = PURPLE)

    table.cell(dash, 0, 1, "STATE", text_color = MUTED)
    table.cell(dash, 1, 1, stateText, text_color = stateColor)

    table.cell(dash, 0, 2, "HTF BIAS", text_color = MUTED)
    table.cell(dash, 1, 2, biasText, text_color = biasColor)

    table.cell(dash, 0, 3, "SIGNAL SCORE", text_color = MUTED)
    table.cell(
         dash, 1, 3,
         str.tostring(scoreDisplay, "#"),
         text_color =
             scoreDisplay >= minScore ? BULL : MUTED)

    table.cell(dash, 0, 4, "MSS", text_color = MUTED)
    table.cell(
         dash, 1, 4,
         bullMSS ? "BULL" :
         bearMSS ? "BEAR" :
         "—",
         text_color =
             bullMSS ? BULL :
             bearMSS ? BEAR :
             MUTED)

    table.cell(dash, 0, 5, "FVG", text_color = MUTED)
    table.cell(
         dash, 1, 5,
         bullFVGValid ? "BULL FVG" :
         bearFVGValid ? "BEAR FVG" :
         "—",
         text_color =
             bullFVGValid ? BULL :
             bearFVGValid ? BEAR :
             MUTED)

    table.cell(dash, 0, 6, "TP1", text_color = MUTED)
    table.cell(
         dash, 1, 6,
         position != 0 ? str.tostring(target1, format.mintick) :
         "—",
         text_color = TP_COL)

    table.cell(dash, 0, 7, "TP2", text_color = MUTED)
    table.cell(
         dash, 1, 7,
         position != 0 ? str.tostring(target2, format.mintick) :
         "—",
         text_color = TP_COL)

    table.cell(dash, 0, 8, "TP3", text_color = MUTED)
    table.cell(
         dash, 1, 8,
         position != 0 ? str.tostring(target3, format.mintick) :
         "—",
         text_color = TP_COL)

    table.cell(dash, 0, 9, "W / L", text_color = MUTED)
    table.cell(
         dash, 1, 9,
         str.tostring(wins) + " / " + str.tostring(losses),
         text_color = WHITE)

    table.cell(dash, 0, 10, "WIN RATE", text_color = MUTED)
    table.cell(
         dash, 1, 10,
         closedTrades > 0 ?
         str.tostring(winRate, "#.#") + "%" :
         "—",
         text_color =
             winRate >= 55 ? BULL :
             winRate >= 45 ? GOLD :
             BEAR)

    table.cell(dash, 0, 11, "FORM", text_color = MUTED)
    table.cell(
         dash, 1, 11,
         recentForm == "" ? "—" : recentForm,
         text_color = CYAN)

// ═══════════════════════════════════════════════════════════════
// 25. WATERMARK
// ═══════════════════════════════════════════════════════════════

if barstate.islast and showWatermark

    var table wm =
         table.new(
             position.bottom_center,
             1,
             1,
             bgcolor = color.new(color.black, 100))

    table.cell(
         wm,
         0,
         0,
         "Mirage Liquidity Sweep [JPT]",
         text_color = color.new(WHITE, 75),
         text_size = size.small,
         bgcolor = color.new(color.black, 100))

// ═══════════════════════════════════════════════════════════════
// 26. ALERTS
// ═══════════════════════════════════════════════════════════════

if enableAlerts and enterLong

    priceTxt = str.tostring(close, format.mintick)
    slTxt = str.tostring(stop, format.mintick)
    tpTxt = str.tostring(target1, format.mintick)

    msg =
         jsonAlerts ?
         '{"action":"BUY","ticker":"' +
         syminfo.tickerid +
         '","price":' + priceTxt +
         ',"score":' + str.tostring(bullScore, "#") +
         ',"sl":' + slTxt +
         ',"tp1":' + tpTxt + '}' :

         "🟢 JPT LONG | " +
         syminfo.tickerid +
         " | Score " +
         str.tostring(bullScore, "#") +
         " | Entry " +
         priceTxt +
         " | SL " +
         slTxt +
         " | TP1 " +
         tpTxt

    alert(msg, alert.freq_once_per_bar_close)

if enableAlerts and enterShort

    priceTxt = str.tostring(close, format.mintick)
    slTxt = str.tostring(stop, format.mintick)
    tpTxt = str.tostring(target1, format.mintick)

    msg =
         jsonAlerts ?
         '{"action":"SELL","ticker":"' +
         syminfo.tickerid +
         '","price":' + priceTxt +
         ',"score":' + str.tostring(bearScore, "#") +
         ',"sl":' + slTxt +
         ',"tp1":' + tpTxt + '}' :

         "🔴 JPT SHORT | " +
         syminfo.tickerid +
         " | Score " +
         str.tostring(bearScore, "#") +
         " | Entry " +
         priceTxt +
         " | SL " +
         slTxt +
         " | TP1 " +
         tpTxt

    alert(msg, alert.freq_once_per_bar_close)

if alertTP and tp1Touch

    alert(
         "🎯 TP1 HIT | " +
         syminfo.tickerid +
         " | " +
         str.tostring(target1, format.mintick),
         alert.freq_once_per_bar_close)

if alertTP and tp2Touch

    alert(
         "🎯 TP2 HIT | " +
         syminfo.tickerid +
         " | " +
         str.tostring(target2, format.mintick),
         alert.freq_once_per_bar_close)

if alertTP and tp3Touch

    alert(
         "🏆 TP3 HIT | " +
         syminfo.tickerid +
         " | " +
         str.tostring(target3, format.mintick),
         alert.freq_once_per_bar_close)

if alertTP and movedBE and tp1Touch

    alert(
         "🛡 BREAK EVEN | " +
         syminfo.tickerid +
         " | SL moved to entry",
         alert.freq_once_per_bar_close)
````
