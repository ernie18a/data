<!-- tradingview-pine-id: PUB;5117111a15a14c708e799324ef23784b -->
<!-- tradingviewscripts-format: 1 -->
# Aurum Gold V2 - Trading Mentor [XAUUSD]

Source: https://www.tradingview.com/script/JkCzpotk-Aurum-Gold-V2-Trading-Mentor-XAUUSD/

## Description

For execution of trades specifically made for Gold.

---

## Source Code

````pine
//@version=6
// =============================================================================
// AURUM V2 — Gold (XAUUSD) Discretionary Trading Mentor
// Not a signal generator - a decision-support dashboard. Four components:
// Market Dashboard (Regime/HTF Bias/EMA Bias/Premium-Discount/S-R/ATR/Session),
// Confidence Engine (7-category weighted score -> label + stars), Trade Quality
// Grade (A+ down to D), and a Visual Trade Plan (Entry/SL/TP1-5) with WHY/WHY-NOT
// explanations, Trade Management guidance, probabilistic Market Scenarios, and a
// unified Decision Panel / "Patience Meter" (WAIT/PREPARE/EXECUTE/NO TRADE).
// Every factor contributes a score instead of acting as a mandatory filter -
// nothing here pressures a trade into existence. Market Regime (Trending/
// Ranging/Expansion/Consolidation) comes from ADX (direction/strength) plus an
// ATR percentile rank (volatility state), and feeds both the take-profit style
// and the Trade Grade. See the base AurumGoldExecutionAssistant.pine for the V1
// version this extends.
// =============================================================================
indicator("Aurum Gold V2 - Trading Mentor [XAUUSD]", shorttitle = "AURUM V2 XAUUSD",
     overlay = true, max_lines_count = 500, max_labels_count = 500,
     max_boxes_count = 500, max_bars_back = 2000)

// ── Gold-only guard (soft) ───────────────────────────────────────────────────
isGold = str.contains(str.upper(syminfo.ticker), "XAU") or str.contains(str.upper(syminfo.ticker), "GOLD") or
     str.contains(str.upper(syminfo.description), "GOLD")

// =============================================================================
// INPUTS
// =============================================================================
g_regime = "Regime Detection"
g_sr     = "Dynamic Support / Resistance"
g_conf   = "Confirmation Candle"
g_trend  = "Trend / EMA Bias"
g_mom    = "Momentum"
g_score  = "Confidence Weights (Aurum V2: 7 categories, sum to 100)"
g_grade  = "Trade Quality Grade"
g_risk   = "Stop Loss / Take Profit"
g_htf    = "Higher Timeframe (display only)"
g_liq    = "Liquidity Levels (display only)"
g_sess   = "Sessions & Kill Zones"
g_disp   = "Display"
g_log    = "Logging"

// -- Regime Detection --
// Trending/Ranging come from ADX (direction+strength); Expansion/Consolidation
// come from where current ATR sits in its own recent percentile history -
// Expansion/Consolidation take priority over Trending/Ranging when volatility
// is extreme, since a violently expanding or dead-quiet tape is the more
// decision-relevant fact in that moment (see f_marketRegime()).
adxLen       = input.int(14, "ADX Length", minval = 1, group = g_regime)
adxThreshold = input.float(25, "ADX >= this = Trending, below = Ranging", minval = 1, group = g_regime)
atrLen       = input.int(14, "ATR Length", minval = 1, group = g_regime)
atrPctLookback   = input.int(100, "ATR Percentile Lookback (bars)", minval = 20, group = g_regime)
expansionPct     = input.float(70, "Expansion: ATR Percentile >=", minval = 50, maxval = 100, group = g_regime)
consolidationPct = input.float(30, "Consolidation: ATR Percentile <=", minval = 0, maxval = 50, group = g_regime)

// -- Dynamic Support / Resistance (range mode) --
srLookback  = input.int(100, "S/R Swing Lookback (bars, 80-150 typical)", minval = 20, maxval = 500, group = g_sr)
zoneAtrMult = input.float(0.5, "Zone Half-Width (x ATR)", minval = 0.05, group = g_sr)

// -- Confirmation Candle --
wickRejectPct = input.float(60, "Rejection Wick >= this % of Candle Range", minval = 10, maxval = 95, group = g_conf)

// -- Trend / EMA Bias --
// EMA200 is a directional BIAS input to the Confidence Engine, never a hard
// filter - a trade can still fire with EMA200 disagreeing, it just scores lower.
emaTrendLen     = input.int(200, "EMA Bias Length", minval = 1, group = g_trend)
emaFastLen      = input.int(20, "Management/Pullback EMA Length", minval = 1, group = g_trend)
pullbackAtrMult = input.float(0.75, "Pullback Proximity (x ATR from Fast EMA)", minval = 0.05, group = g_trend)

// -- Momentum (deliberately not an oscillator - rate of price change over N
// bars, normalized by ATR, direction-aware) --
momLookback        = input.int(10, "Momentum Lookback (bars)", minval = 1, group = g_mom)
momFullScoreAtr     = input.float(1.5, "Momentum Full Score at This Many ATR Move", minval = 0.1, group = g_mom)

// -- Confidence Weights: Aurum V2's exact 7 categories (25/20/15/15/10/10/5=100).
// Each factor contributes a score instead of gating the trade outright. --
wTrendAlign = input.float(25, "Weight: Trend Alignment (HTF structure agreement)", minval = 0, maxval = 100, group = g_score)
wSR         = input.float(20, "Weight: Support/Resistance Proximity", minval = 0, maxval = 100, group = g_score)
wEmaBias    = input.float(15, "Weight: EMA Bias (EMA200 position)", minval = 0, maxval = 100, group = g_score)
wConfirm    = input.float(15, "Weight: Confirmation Candle", minval = 0, maxval = 100, group = g_score)
wMomentum   = input.float(10, "Weight: Momentum", minval = 0, maxval = 100, group = g_score)
wAtr        = input.float(10, "Weight: ATR", minval = 0, maxval = 100, group = g_score)
wSession    = input.float(5,  "Weight: Session", minval = 0, maxval = 100, group = g_score)
minConfidence = input.float(65, "Minimum Confidence to Fire Signal", minval = 0, maxval = 100, group = g_score)

// -- Confidence score bands (labels + star rating) --
bandExceptional   = input.float(90, "Exceptional: score >=", minval = 0, maxval = 100, group = g_score)
bandHighProb      = input.float(80, "High Probability: score >=", minval = 0, maxval = 100, group = g_score)
bandGood          = input.float(65, "Good: score >=", minval = 0, maxval = 100, group = g_score)
bandAverage       = input.float(50, "Average: score >=", minval = 0, maxval = 100, group = g_score)

// -- Trade Quality Grade (A+ should be rare) --
aPlusMinConfidence = input.float(90, "A+: min Confidence", minval = 0, maxval = 100, group = g_grade)
aPlusMinRR         = input.float(3.0, "A+: min Risk/Reward", minval = 0.1, group = g_grade)
aMinConfidence     = input.float(85, "A: min Confidence", minval = 0, maxval = 100, group = g_grade)
aMinRR             = input.float(2.5, "A: min Risk/Reward", minval = 0.1, group = g_grade)
bPlusMinConfidence = input.float(75, "B+: min Confidence", minval = 0, maxval = 100, group = g_grade)
bPlusMinRR         = input.float(2.0, "B+: min Risk/Reward", minval = 0.1, group = g_grade)
bMinConfidence     = input.float(65, "B: min Confidence", minval = 0, maxval = 100, group = g_grade)
bMinRR             = input.float(1.5, "B: min Risk/Reward", minval = 0.1, group = g_grade)
cMinConfidence     = input.float(50, "C: min Confidence", minval = 0, maxval = 100, group = g_grade)

// -- Stop Loss / Take Profit --
// TP1-TP5 are R-multiples of the Stop Loss distance (1R = Stop Loss distance
// itself) - the classic "risk 1, make N" framing, constant regardless of
// regime. Risk/Reward everywhere else in the script is simply tp3R (the
// "primary" target) - it no longer varies by market structure the way the
// old regime-adaptive ATR/range-width target used to.
slAtrMult      = input.float(1.0, "Stop Loss (x ATR)", minval = 0.1, group = g_risk)
tp1R = input.float(1.0, "TP1 (x Stop Loss distance)", minval = 0.1, group = g_risk)
tp2R = input.float(2.0, "TP2 (x Stop Loss distance)", minval = 0.1, group = g_risk)
tp3R = input.float(3.0, "TP3 (x Stop Loss distance) - this is \"the\" Risk/Reward", minval = 0.1, group = g_risk)
tp4R = input.float(4.0, "TP4 (x Stop Loss distance)", minval = 0.1, group = g_risk)
tp5R = input.float(5.0, "TP5 (x Stop Loss distance)", minval = 0.1, group = g_risk)
maxHoldBars    = input.int(200, "Max Trade Duration (bars) — force-resolves a stale trade so it can't block new signals forever", minval = 1, group = g_risk)

// -- Higher Timeframe (context only, does not gate entries) --
tfDaily   = input.timeframe("D",   "Daily Timeframe", group = g_htf)
tf4h      = input.timeframe("240", "4H Timeframe",    group = g_htf)
tf1h      = input.timeframe("60",  "1H Timeframe",    group = g_htf)
swingLenD = input.int(5, "Daily Swing Length", minval = 2, group = g_htf)
swingLen4 = input.int(5, "4H Swing Length",    minval = 2, group = g_htf)
swingLen1 = input.int(5, "1H Swing Length",    minval = 2, group = g_htf)

// -- Liquidity Levels (display only) --
showPDHL   = input.bool(true, "Show Previous Day High/Low",  group = g_liq)
showPWHL   = input.bool(true, "Show Previous Week High/Low", group = g_liq)
showAsia   = input.bool(true, "Show Asian Session High/Low", group = g_liq)
showLondon = input.bool(true, "Show London Session High/Low", group = g_liq)

// -- Sessions / Kill Zones --
sessAsia   = input.session("2000-0000", "Asia Session Window", group = g_sess)
sessLondon = input.session("0200-0500", "London Session Window", group = g_sess)
sessNY     = input.session("0800-1100", "New York Session Window", group = g_sess)
kzLondon   = input.session("0200-0400", "London Kill Zone", group = g_sess)
kzNY       = input.session("0800-1000", "NY Kill Zone", group = g_sess)
requireKillzone = input.bool(false, "Require Kill Zone for Entry (optional filter)", group = g_sess)

// -- Display --
dashPos     = input.string("Top Right", "Dashboard Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = g_disp)
showDash    = input.bool(true, "Show Dashboard", group = g_disp)
showExplain = input.bool(true, "Show Trade Explanation Panel", group = g_disp)
showRibbon  = input.bool(true, "Show Trend Ribbon", group = g_disp)
showZones   = input.bool(true, "Show Support/Resistance Zones", group = g_disp)
showEmas    = input.bool(true, "Show EMA Lines", group = g_disp)
showLiqLines = input.bool(true, "Show Liquidity Lines", group = g_disp)
bullColor = input.color(color.new(#00e0a4, 0), "Bullish Color", group = g_disp)
bearColor = input.color(color.new(#ff4d6d, 0), "Bearish Color", group = g_disp)
neutColor = input.color(color.new(#9aa4b2, 0), "Neutral Color", group = g_disp)
entryColor  = input.color(color.new(#f2c744, 0), "Entry Line/Label Color", group = g_disp)
slColor     = input.color(color.new(#ff4d6d, 0), "SL Line/Label Color", group = g_disp)
tpColor     = input.color(color.new(#00e0a4, 0), "TP Line/Label Color", group = g_disp)
labelSizeOpt = input.string("Huge", "Entry/SL/TP Label Size", options = ["Small", "Normal", "Large", "Huge"], group = g_disp)
entryLineWidth = input.int(4, "Entry Line Width", minval = 1, maxval = 10, group = g_disp)
slLineWidth    = input.int(3, "SL Line Width", minval = 1, maxval = 10, group = g_disp)
tpLineWidth    = input.int(2, "TP Line Width", minval = 1, maxval = 10, group = g_disp)
slTpLineStyle  = input.string("Dotted", "SL/TP Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_disp)
lockTrade = input.bool(false, "Lock In Executed Trade (check AFTER you execute in your broker; uncheck + re-check for your next manual trade)", group = g_disp)
lockDirection = input.string("BUY", "  ⤷ Direction You Actually Entered", options = ["BUY", "SELL"], group = g_disp)
manualEntryPrice = input.float(0.0, "  ⤷ Your Exact Entry Price (0 = use current close instead)", minval = 0.0, group = g_disp)
labelOffsetBars = input.int(15, "Entry/SL/TP Label Offset (bars to the right, clear of candles)", minval = 0, maxval = 200, group = g_disp)
signalLabelOffsetBars = input.int(15, "BUY/SELL Signal Label Offset (bars to the left, clear of candles)", minval = 0, maxval = 200, group = g_disp)

// -- Logging --
enableLogging = input.bool(true, "Log Confidence Breakdown (Pine Logs, once per closed candle)", group = g_log)

atrVal = ta.atr(atrLen)

// =============================================================================
// UTILITIES
// =============================================================================
// Returns true on the first bar a given session window becomes active.
f_sessionStart(bool active) =>
    active and not active[1]

// =============================================================================
// 1) HIGHER TIMEFRAME STRUCTURE (display only — does not gate entries)
// Tracks confirmed swing pivots per timeframe and derives BOS/CHoCH bias, shown
// on the dashboard purely as context for a discretionary trader.
// bias: 1 bullish, -1 bearish, 0 undetermined.
// =============================================================================
f_structureBias(simple int len) =>
    var float swingHigh = na
    var float swingLow  = na
    var int   bias      = 0

    ph = ta.pivothigh(len, len)
    pl = ta.pivotlow(len, len)
    if not na(ph)
        swingHigh := ph
    if not na(pl)
        swingLow := pl

    if not na(swingHigh) and close > swingHigh
        bias := 1
        swingHigh := na
    if not na(swingLow) and close < swingLow
        bias := -1
        swingLow := na

    bias

dBias  = request.security(syminfo.tickerid, tfDaily, f_structureBias(swingLenD), lookahead = barmerge.lookahead_off)
h4Bias = request.security(syminfo.tickerid, tf4h,    f_structureBias(swingLen4), lookahead = barmerge.lookahead_off)
h1Bias = request.security(syminfo.tickerid, tf1h,    f_structureBias(swingLen1), lookahead = barmerge.lookahead_off)

// =============================================================================
// 2) LIQUIDITY LEVELS (display only)
// Previous Day/Week highs+lows and Asian/London session highs+lows.
// =============================================================================
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_off)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead = barmerge.lookahead_off)
pwl = request.security(syminfo.tickerid, "W", low[1],  lookahead = barmerge.lookahead_off)

asiaActive   = not na(time(timeframe.period, sessAsia))
londonActive = not na(time(timeframe.period, sessLondon))

var float asiaHigh = na
var float asiaLow  = na
if f_sessionStart(asiaActive)
    asiaHigh := high
    asiaLow  := low
else if asiaActive
    asiaHigh := math.max(asiaHigh, high)
    asiaLow  := math.min(asiaLow, low)

var float londonHigh = na
var float londonLow  = na
if f_sessionStart(londonActive)
    londonHigh := high
    londonLow  := low
else if londonActive
    londonHigh := math.max(londonHigh, high)
    londonLow  := math.min(londonLow, low)

// =============================================================================
// 3) SESSION + KILL ZONE ENGINE
// =============================================================================
sessNYActive   = not na(time(timeframe.period, sessNY))
kzLondonActive = not na(time(timeframe.period, kzLondon))
kzNYActive     = not na(time(timeframe.period, kzNY))
inKillzone     = kzLondonActive or kzNYActive
inOverlap      = londonActive and sessNYActive

currentSession = inOverlap ? "London/NY Overlap" : sessNYActive ? "New York" : londonActive ? "London" : asiaActive ? "Asian" : "Off-Session"

// =============================================================================
// 4) PREMIUM / DISCOUNT (display context)
// =============================================================================
pdSwingLen  = 20
rangeHighPd = ta.highest(high, pdSwingLen)
rangeLowPd  = ta.lowest(low, pdSwingLen)
equilibrium = (rangeHighPd + rangeLowPd) / 2
zoneLabel   = close > equilibrium ? "Premium" : close < equilibrium ? "Discount" : "Equilibrium"

// =============================================================================
// 5) REGIME ENGINE
// ADX gives direction/strength (Trending vs Ranging); an ATR percentile rank
// gives volatility state (Expansion vs Consolidation). Expansion/Consolidation
// take priority when volatility is extreme - a violently expanding or
// dead-quiet tape is the more decision-relevant fact than trend strength in
// that moment. Feeds the Market Regime dashboard row, the take-profit style,
// and the Trade Quality Grade.
// =============================================================================
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
isTrending = adxVal >= adxThreshold
atrPercentile = ta.percentrank(atrVal, atrPctLookback)

f_marketRegime() =>
    atrPercentile >= expansionPct ? "Expansion" : atrPercentile <= consolidationPct ? "Consolidation" : isTrending ? "Trending" : "Ranging"

marketRegime = f_marketRegime()

// =============================================================================
// 6) EMA BIAS (directional bias, not a gate) + MANAGEMENT/PULLBACK EMA
// =============================================================================
ema200  = ta.ema(close, emaTrendLen)
emaFast = ta.ema(close, emaFastLen)
bullTrend = close > ema200
bearTrend = close < ema200

// =============================================================================
// 7) DYNAMIC SUPPORT / RESISTANCE ENGINE
// Recalculates every bar from the rolling swing high/low over srLookback bars.
// The ATR-based zone defines the reference distance for the proximity score
// below (full score at the level, fading to 0 by ~3 zone-widths away).
// =============================================================================
resistance = ta.highest(high, srLookback)
support    = ta.lowest(low, srLookback)

buyZoneTop    = support + zoneAtrMult * atrVal
buyZoneBottom = support - zoneAtrMult * atrVal
sellZoneTop    = resistance + zoneAtrMult * atrVal
sellZoneBottom = resistance - zoneAtrMult * atrVal

distToSupport    = math.abs(close - support)
distToResistance = math.abs(close - resistance)

// =============================================================================
// 8) CONFIDENCE ENGINE — Aurum V2's 7 categories
// Every factor below returns a 0-1 fraction ("how well is this condition met"),
// which is then multiplied by its input weight. Nothing here blocks a trade by
// itself — only the final weighted total, compared against minConfidence, does.
// =============================================================================
// Trend Alignment: agreement across the three HTF structure biases (Daily/4H/
// 1H) computed in section 1 - promoted from display-only to a scored category.
f_trendAlignFrac(bool isLong) =>
    target = isLong ? 1 : -1
    agree = (dBias == target ? 1 : 0) + (h4Bias == target ? 1 : 0) + (h1Bias == target ? 1 : 0)
    agree / 3.0

// Support/Resistance proximity: full score at the level, decaying linearly to 0
// over ~3 zone-widths — a graded distance score, not a strict in/out zone test.
f_srFrac(bool isLong) =>
    level = isLong ? support : resistance
    dist = math.abs(close - level)
    maxDist = zoneAtrMult * atrVal * 3
    maxDist > 0 ? math.max(0.0, 1.0 - dist / maxDist) : 0.0

// EMA Bias: EMA200 position, its own separate (smaller-weight) category from
// Trend Alignment above - a directional input, never a hard requirement.
f_emaBiasFrac(bool isLong) =>
    isLong ? (bullTrend ? 1.0 : 0.0) : (bearTrend ? 1.0 : 0.0)

// Management/pullback proximity - not a scored category (see Aurum V2 spec:
// 7 categories only), kept for Position Context / Trade Management use below.
f_pullbackFrac() =>
    dist = math.abs(close - emaFast)
    maxDist = pullbackAtrMult * atrVal * 2
    maxDist > 0 ? math.max(0.0, 1.0 - dist / maxDist) : 0.0

// Confirmation candle: tiered instead of a flat pass/fail — a full engulfing
// candle counts for more than a bare directional close.
f_bullConfirmTiered() =>
    rng = high - low
    lowerWick = math.min(open, close) - low
    engulf = close > open and close[1] < open[1] and close >= open[1] and open <= close[1]
    rejection = rng > 0 and (lowerWick / rng) >= wickRejectPct / 100 and close > (low + rng * 0.5)
    bullClose = close > open
    frac = engulf ? 1.0 : rejection ? 0.8 : bullClose ? 0.55 : 0.0
    confirmed = engulf or rejection or bullClose
    [confirmed, frac]

f_bearConfirmTiered() =>
    rng = high - low
    upperWick = high - math.max(open, close)
    engulf = close < open and close[1] > open[1] and close <= open[1] and open >= close[1]
    rejection = rng > 0 and (upperWick / rng) >= wickRejectPct / 100 and close < (high - rng * 0.5)
    bearClose = close < open
    frac = engulf ? 1.0 : rejection ? 0.8 : bearClose ? 0.55 : 0.0
    confirmed = engulf or rejection or bearClose
    [confirmed, frac]

// Momentum: rate of price change over momLookback bars, normalized by ATR,
// direction-aware — deliberately not an oscillator (no MACD/Stochastic/etc.).
f_momentumFrac(bool isLong) =>
    roc = (close - close[momLookback]) / atrVal
    directional = isLong ? roc : -roc
    momFullScoreAtr > 0 ? math.max(0.0, math.min(1.0, directional / momFullScoreAtr)) : 0.0

// ATR: rewards current ATR being at/above its own 50-bar average (enough
// movement to reach a target) rather than a dead, quiet tape.
f_atrFrac() =>
    avgAtr = ta.sma(atrVal, 50)
    avgAtr > 0 ? math.min(1.0, atrVal / avgAtr) : 0.5

// Session: full credit inside a Kill Zone, half credit in any major session,
// zero off-session — informational context promoted to a small (5pt) scored
// category rather than a mandatory gate (requireKillzone remains available
// below as a separate, optional hard filter for users who still want one).
f_sessionFrac() =>
    inKillzone ? 1.0 : (asiaActive or londonActive or sessNYActive) ? 0.5 : 0.0

trendAlignFracLong  = f_trendAlignFrac(true)
trendAlignFracShort = f_trendAlignFrac(false)
srFracLong   = f_srFrac(true)
srFracShort  = f_srFrac(false)
emaBiasFracLong  = f_emaBiasFrac(true)
emaBiasFracShort = f_emaBiasFrac(false)
pullFrac = f_pullbackFrac()
[bullConfirm, bullConfirmFrac] = f_bullConfirmTiered()
[bearConfirm, bearConfirmFrac] = f_bearConfirmTiered()
momFracLong  = f_momentumFrac(true)
momFracShort = f_momentumFrac(false)
atrFrac = f_atrFrac()
sessionFrac = f_sessionFrac()

trendAlignScoreLong  = trendAlignFracLong * wTrendAlign
trendAlignScoreShort = trendAlignFracShort * wTrendAlign
srScoreLong   = srFracLong * wSR
srScoreShort  = srFracShort * wSR
emaBiasScoreLong  = emaBiasFracLong * wEmaBias
emaBiasScoreShort = emaBiasFracShort * wEmaBias
bullConfirmScore = bullConfirmFrac * wConfirm
bearConfirmScore = bearConfirmFrac * wConfirm
momScoreLong  = momFracLong * wMomentum
momScoreShort = momFracShort * wMomentum
atrScoreVal = atrFrac * wAtr
sessionScoreVal = sessionFrac * wSession

longConfidence  = math.min(100.0, trendAlignScoreLong + srScoreLong + emaBiasScoreLong + bullConfirmScore + momScoreLong + atrScoreVal + sessionScoreVal)
shortConfidence = math.min(100.0, trendAlignScoreShort + srScoreShort + emaBiasScoreShort + bearConfirmScore + momScoreShort + atrScoreVal + sessionScoreVal)

// Whichever direction currently leads - computed here (not just in the Decision
// Panel section below) since the Entry Engine's manual-lock trigger needs it too.
bestConfidence = math.max(longConfidence, shortConfidence)
bestDirection  = longConfidence >= shortConfidence ? "BUY" : "SELL"
bestConfirmed  = bestDirection == "BUY" ? bullConfirm : bearConfirm

// Confidence label bands + star rating (shared by both directions - applied to
// whichever confidence value is being displayed).
f_confidenceLabel(float score) =>
    score >= bandExceptional ? "Exceptional" : score >= bandHighProb ? "High Probability" : score >= bandGood ? "Good" : score >= bandAverage ? "Average" : "Low Probability"

f_confidenceColor(float score) =>
    score >= 95 ? color.new(#0b6623, 0) : score >= 80 ? color.new(#00c853, 0) : score >= 65 ? color.new(#ffd600, 0) : color.new(#9aa4b2, 0)

// Detailed per-candle logging: score contribution of every component, both
// directions, written to the Pine Logs panel once per closed candle.
if enableLogging and barstate.isconfirmed
    log.info("AURUM LONG  conf=" + str.tostring(longConfidence, "#.#") + "/100 || TrendAlign=" + str.tostring(trendAlignScoreLong, "#.#") + "/" + str.tostring(wTrendAlign, "#") +
         " S/R=" + str.tostring(srScoreLong, "#.#") + "/" + str.tostring(wSR, "#") +
         " EmaBias=" + str.tostring(emaBiasScoreLong, "#.#") + "/" + str.tostring(wEmaBias, "#") +
         " Confirm=" + str.tostring(bullConfirmScore, "#.#") + "/" + str.tostring(wConfirm, "#") +
         " Momentum=" + str.tostring(momScoreLong, "#.#") + "/" + str.tostring(wMomentum, "#") +
         " ATR=" + str.tostring(atrScoreVal, "#.#") + "/" + str.tostring(wAtr, "#") +
         " Session=" + str.tostring(sessionScoreVal, "#.#") + "/" + str.tostring(wSession, "#"))
    log.info("AURUM SHORT conf=" + str.tostring(shortConfidence, "#.#") + "/100 || TrendAlign=" + str.tostring(trendAlignScoreShort, "#.#") + "/" + str.tostring(wTrendAlign, "#") +
         " S/R=" + str.tostring(srScoreShort, "#.#") + "/" + str.tostring(wSR, "#") +
         " EmaBias=" + str.tostring(emaBiasScoreShort, "#.#") + "/" + str.tostring(wEmaBias, "#") +
         " Confirm=" + str.tostring(bearConfirmScore, "#.#") + "/" + str.tostring(wConfirm, "#") +
         " Momentum=" + str.tostring(momScoreShort, "#.#") + "/" + str.tostring(wMomentum, "#") +
         " ATR=" + str.tostring(atrScoreVal, "#.#") + "/" + str.tostring(wAtr, "#") +
         " Session=" + str.tostring(sessionScoreVal, "#.#") + "/" + str.tostring(wSession, "#"))

// =============================================================================
// 9) ENTRY ENGINE
// Fires purely on weighted confidence clearing the threshold. Kill Zone remains
// an optional gate (off by default) rather than a scored factor. A trade can
// ALSO be locked in manually (see lockTrade below) - e.g. you executed off the
// live preview at a confidence below the auto-fire threshold - which reuses
// this exact same entry/tracking/drawing path so Trade Management, TP-hit
// tracking, and the dashboard all just work for it too.
// =============================================================================
longMandatory  = longConfidence >= minConfidence and (not requireKillzone or inKillzone)
shortMandatory = shortConfidence >= minConfidence and (not requireKillzone or inKillzone)

var bool  longActive  = false
var bool  shortActive = false
var float activeEntry = na
var float activeSL    = na
var float tp1 = na
var float tp2 = na
var float tp3 = na
var float tp4 = na
var float tp5 = na
var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var bool tp4Hit = false
var bool tp5Hit = false
var bool  isLongTrade = true
var int   activeSinceBar = na
var string activeMode = ""
var label signalLbl = na // most recent BUY/SELL callout only - old ones are deleted, not
                          // accumulated, so the chart doesn't clutter up over many signals

// Manual lock: check the box AFTER you've actually executed in your broker, to
// freeze the plan you were just looking at in the live preview instead of it
// continuing to move with price. Gated on barstate.islast, so it can only ever
// capture "right now," regardless of when the box was checked. lockConsumed
// prevents it silently re-firing on some later bar if the box is left checked
// after this trade closes - uncheck and re-check it for your next manual trade.
var bool lockConsumed = false
if not lockTrade
    lockConsumed := false
manualLockLong  = lockTrade and not lockConsumed and not longActive and not shortActive and barstate.islast and lockDirection == "BUY"
manualLockShort = lockTrade and not lockConsumed and not longActive and not shortActive and barstate.islast and lockDirection == "SELL"

longSignal  = (barstate.isconfirmed and longMandatory and not longActive and not shortActive) or manualLockLong
shortSignal = (barstate.isconfirmed and shortMandatory and not shortActive and not longActive) or manualLockShort

// Snapshot of each component's score contribution at signal time, for the
// explanation panel — a breakdown, not just a pass/fail checklist.
var float sig_trendAlignScore = na
var float sig_srScore = na
var float sig_emaBiasScore = na
var float sig_confirmScore = na
var float sig_momScore = na
var float sig_atrScore = na
var float sig_sessionScore = na
var float sig_total = na
var string sig_regime = ""
var bool   sig_sess = false
var string sig_dir = ""
var float  sig_rr = na
var string sig_grade = ""

// =============================================================================
// TRADE QUALITY GRADE — A+ down to D. A+ is deliberately rare: it requires
// exceptional confidence AND a strong risk/reward AND a Trending regime AND an
// actual confirmation candle, all at once - not just a high score alone.
// =============================================================================
f_tradeGrade(float confidence, float rr, string regime, bool confirmed) =>
    isAPlus = confidence >= aPlusMinConfidence and rr >= aPlusMinRR and regime == "Trending" and confirmed
    isA     = confidence >= aMinConfidence and rr >= aMinRR
    isBPlus = confidence >= bPlusMinConfidence and rr >= bPlusMinRR
    isB     = confidence >= bMinConfidence and rr >= bMinRR
    isC     = confidence >= cMinConfidence
    isAPlus ? "A+" : isA ? "A" : isBPlus ? "B+" : isB ? "B" : isC ? "C" : "D"

// =============================================================================
// 10) STOP LOSS / TAKE PROFIT ENGINE
// ATR-based stop. TP1-TP5 are R-multiples of that SAME stop distance (1R =
// the stop distance itself) - "risk 1, make N", constant regardless of
// regime, each multiple independently editable above.
// =============================================================================
f_stopLoss(bool isLong, float entry) =>
    isLong ? entry - slAtrMult * atrVal : entry + slAtrMult * atrVal

f_takeProfits(bool isLong, float entry, float stopDistance) =>
    t1 = isLong ? entry + stopDistance * tp1R : entry - stopDistance * tp1R
    t2 = isLong ? entry + stopDistance * tp2R : entry - stopDistance * tp2R
    t3 = isLong ? entry + stopDistance * tp3R : entry - stopDistance * tp3R
    t4 = isLong ? entry + stopDistance * tp4R : entry - stopDistance * tp4R
    t5 = isLong ? entry + stopDistance * tp5R : entry - stopDistance * tp5R
    [t1, t2, t3, t4, t5]

if longSignal
    longActive := true
    if manualLockLong
        lockConsumed := true
    activeSinceBar := bar_index
    isLongTrade := true
    activeMode := manualLockLong ? "Manual Lock" : (not isTrending ? "Range" : "Trend")
    activeEntry := manualLockLong and manualEntryPrice > 0 ? manualEntryPrice : close
    activeSL := f_stopLoss(true, activeEntry)
    stopDistance = slAtrMult * atrVal
    [t1, t2, t3, t4, t5] = f_takeProfits(true, activeEntry, stopDistance)
    tp1 := t1
    tp2 := t2
    tp3 := t3
    tp4 := t4
    tp5 := t5
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    tp4Hit := false
    tp5Hit := false
    sig_trendAlignScore := trendAlignScoreLong
    sig_srScore := srScoreLong
    sig_emaBiasScore := emaBiasScoreLong
    sig_confirmScore := bullConfirmScore
    sig_momScore := momScoreLong
    sig_atrScore := atrScoreVal
    sig_sessionScore := sessionScoreVal
    sig_total := longConfidence
    sig_regime := marketRegime
    sig_sess := inKillzone
    sig_dir := "BUY"
    sig_rr := tp3R
    sig_grade := f_tradeGrade(longConfidence, sig_rr, marketRegime, bullConfirm)
    if not na(signalLbl)
        label.delete(signalLbl)
    signalLbl := label.new(bar_index - signalLabelOffsetBars, low - atrVal, "BUY (" + activeMode + ") Grade " + sig_grade,
         style = label.style_label_up, color = bullColor, textcolor = color.white, size = size.normal)
    alert("Aurum XAUUSD BUY — " + activeMode + " mode, confidence " + str.tostring(math.round(longConfidence)) + "%, grade " + sig_grade, alert.freq_once_per_bar_close)

if shortSignal
    shortActive := true
    if manualLockShort
        lockConsumed := true
    activeSinceBar := bar_index
    isLongTrade := false
    activeMode := manualLockShort ? "Manual Lock" : (not isTrending ? "Range" : "Trend")
    activeEntry := manualLockShort and manualEntryPrice > 0 ? manualEntryPrice : close
    activeSL := f_stopLoss(false, activeEntry)
    stopDistance = slAtrMult * atrVal
    [t1, t2, t3, t4, t5] = f_takeProfits(false, activeEntry, stopDistance)
    tp1 := t1
    tp2 := t2
    tp3 := t3
    tp4 := t4
    tp5 := t5
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    tp4Hit := false
    tp5Hit := false
    sig_trendAlignScore := trendAlignScoreShort
    sig_srScore := srScoreShort
    sig_emaBiasScore := emaBiasScoreShort
    sig_confirmScore := bearConfirmScore
    sig_momScore := momScoreShort
    sig_atrScore := atrScoreVal
    sig_sessionScore := sessionScoreVal
    sig_total := shortConfidence
    sig_regime := marketRegime
    sig_sess := inKillzone
    sig_dir := "SELL"
    sig_rr := tp3R
    sig_grade := f_tradeGrade(shortConfidence, sig_rr, marketRegime, bearConfirm)
    if not na(signalLbl)
        label.delete(signalLbl)
    signalLbl := label.new(bar_index - signalLabelOffsetBars, high + atrVal, "SELL (" + activeMode + ") Grade " + sig_grade,
         style = label.style_label_down, color = bearColor, textcolor = color.white, size = size.normal)
    alert("Aurum XAUUSD SELL — " + activeMode + " mode, confidence " + str.tostring(math.round(shortConfidence)) + "%, grade " + sig_grade, alert.freq_once_per_bar_close)

// TP hit tracking + SL invalidation, for whichever trade is active. A max-hold-time
// force-resolve is included so a trade that never reaches TP5 or SL (e.g. price just
// chops sideways) can't lock this flag true forever and block every future signal.
if longActive
    if not tp1Hit and high >= tp1
        tp1Hit := true
    if not tp2Hit and high >= tp2
        tp2Hit := true
    if not tp3Hit and high >= tp3
        tp3Hit := true
    if not tp4Hit and high >= tp4
        tp4Hit := true
    if not tp5Hit and high >= tp5
        tp5Hit := true
        longActive := false
    if low <= activeSL
        longActive := false
    if not na(activeSinceBar) and (bar_index - activeSinceBar) >= maxHoldBars
        longActive := false

if shortActive
    if not tp1Hit and low <= tp1
        tp1Hit := true
    if not tp2Hit and low <= tp2
        tp2Hit := true
    if not tp3Hit and low <= tp3
        tp3Hit := true
    if not tp4Hit and low <= tp4
        tp4Hit := true
    if not tp5Hit and low <= tp5
        tp5Hit := true
        shortActive := false
    if high >= activeSL
        shortActive := false
    if not na(activeSinceBar) and (bar_index - activeSinceBar) >= maxHoldBars
        shortActive := false

tradeIsActive = longActive or shortActive

// =============================================================================
// 11) POSITION CONTEXT — instant "where does price sit right now" label.
// =============================================================================
f_positionContext() =>
    nearThresholdAtr = zoneAtrMult * 3 // same "close enough" band as the S/R proximity score
    isNearSupport    = (distToSupport / atrVal) <= nearThresholdAtr
    isNearResistance = (distToResistance / atrVal) <= nearThresholdAtr
    // A genuine new-high/new-low breakout: today's close beyond the PRIOR bar's rolling
    // S/R extreme (resistance[1]/support[1] exclude the current bar), not just "at" it.
    brokeOut = close > resistance[1] or close < support[1]
    brokeOut and marketRegime == "Expansion" ? "Breakout" :
         isNearSupport and not isNearResistance ? "Near Support" :
         isNearResistance and not isNearSupport ? "Near Resistance" :
         marketRegime == "Ranging" ? "Middle of Range" :
         pullFrac >= 0.5 ? "Pullback" :
         "Extended"

positionContext = f_positionContext()

// =============================================================================
// 12) MARKET SCENARIOS — probabilistic, rule-based (not random/ML). Percentages
// come from a deterministic lookup keyed on Confidence band + Regime, not a
// single predicted outcome.
// =============================================================================
f_scenarioPercents(string regime, float confidence) =>
    float pA = confidence >= bandExceptional ? 75 : confidence >= bandHighProb ? 70 : confidence >= bandGood ? 60 : confidence >= bandAverage ? 50 : 40
    float pB = regime == "Ranging" ? 20 : 15
    float pC = 100 - pA - pB
    [pA, pB, pC]

f_scenarioText(bool isLong, string regime, float confidence) =>
    [pA, pB, pC] = f_scenarioPercents(regime, confidence)
    targetWord    = isLong ? "resistance" : "support"
    sourceWord    = isLong ? "support" : "resistance"
    sourceWordCap = isLong ? "Support" : "Resistance"
    contWord      = regime == "Trending" ? "continues its trend toward " : "bounces from " + sourceWord + " toward "
    textA = "Scenario A (" + str.tostring(pA, "#") + "%): Price " + contWord + targetWord + "."
    textB = "Scenario B (" + str.tostring(pB, "#") + "%): Liquidity sweep beyond " + sourceWord + " before reversing " + (isLong ? "higher" : "lower") + "."
    textC = "Scenario C (" + str.tostring(pC, "#") + "%): " + sourceWordCap + " fails outright, invalidating the setup."
    invalidLevel = isLong ? support : resistance
    textInvalid = "Invalidation: close beyond " + str.tostring(invalidLevel, format.mintick) + " (" + sourceWord + ")."
    [textA, textB, textC, textInvalid]

// =============================================================================
// 13) TRADE MANAGEMENT SUGGESTIONS — informational only, anchored to Aurum's
// own tracked trade plan (activeEntry/activeSL/tp1/tp2). Pine has no live
// broker/position access at all (even for indicators), so this is always
// "if this plan were taken," never a read of a real account position.
// =============================================================================
f_managementAdvice() =>
    string advice = "No active trade - nothing to manage."
    if tradeIsActive
        weakening = not isTrending // regime has cooled since entry
        advice := tp2Hit ? "Trail stop behind EMA" + str.tostring(emaFastLen) + (weakening ? ". Trend has weakened - consider taking partial profit." : ".") :
             tp1Hit ? "TP1 hit - move Stop Loss to Break Even (" + str.tostring(activeEntry, format.mintick) + ")." :
             weakening ? "Trend momentum has weakened since entry - consider a partial profit." :
             "Hold - next management step at TP1 (" + str.tostring(tp1, format.mintick) + ")."
    advice

managementAdvice = f_managementAdvice()

// =============================================================================
// 14) DECISION PANEL / "PATIENCE METER" — unified: one state, two renderings
// (text label + emoji chip). Never pressures a trade into existence; NO TRADE
// is a hard gate independent of confidence crossing the fire threshold.
// bestConfidence/bestDirection/bestConfirmed are computed earlier (section 8)
// since the Entry Engine's manual-lock trigger needs them too.
// =============================================================================

f_decisionState(float confidence, string regime, bool confirmed) =>
    noTrade = regime == "Consolidation" and confidence < bandAverage
    noTrade ? "NO TRADE" : confidence < minConfidence ? "WAIT" : not confirmed ? "PREPARE" : "EXECUTE"

f_decisionEmoji(string state) =>
    state == "EXECUTE" ? "🟢" : state == "PREPARE" ? "🟡" : state == "NO TRADE" ? "⚫" : "🔴"

decisionState = f_decisionState(bestConfidence, marketRegime, bestConfirmed)
decisionEmoji = f_decisionEmoji(decisionState)

// =============================================================================
// DRAWING — Entry / SL / TP lines (kept live only while a trade is active)
// =============================================================================
var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var line tp4Line = na
var line tp5Line = na
var label entryLbl = na
var label slLbl = na
var label tp1Lbl = na
var label tp2Lbl = na
var label tp3Lbl = na
var label tp4Lbl = na
var label tp5Lbl = na
// Creates/updates/deletes a persistent horizontal level line as its input toggles or value changes.
f_updateLevelLine(line ln, float lvl, color col, bool active) =>
    line result = ln
    if active and not na(lvl)
        if na(result)
            result := line.new(bar_index, lvl, bar_index + 1, lvl, extend = extend.right, color = col, width = 1, style = line.style_dashed)
        else
            line.set_xy1(result, bar_index, lvl)
            line.set_xy2(result, bar_index + 1, lvl)
    else if not active and not na(result)
        line.delete(result)
        result := na
    result

// Maps the "Entry/SL/TP Label Size" input to a Pine label size constant.
f_labelSize(string s) =>
    s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

// Maps the "SL/TP Line Style" input to a Pine line style constant.
f_lineStyle(string s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

// Small floating text tag identifying a level line, stating its exact price. Uses
// style_label_up (the same proven style as the BUY/SELL signal callouts below), which
// renders the text ABOVE the anchor point with a small pointer down to it — so the tag
// sits above the line automatically. textCol is chosen per-line for contrast against
// that line's own (often light/bright) default color rather than a fixed white. Anchored
// labelOffsetBars bars to the right of the current bar (into the empty space beyond the
// last candle) rather than directly on bar_index, so it doesn't sit on top of price action.
f_levelLabel(float lvl, string txt, color col, color textCol) =>
    label.new(bar_index + labelOffsetBars, lvl, txt, style = label.style_label_up, size = f_labelSize(labelSizeOpt),
         color = col, textcolor = textCol)

if longSignal or shortSignal
    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)
    if not na(tp4Line)
        line.delete(tp4Line)
    if not na(tp5Line)
        line.delete(tp5Line)
    if not na(entryLbl)
        label.delete(entryLbl)
    if not na(slLbl)
        label.delete(slLbl)
    if not na(tp1Lbl)
        label.delete(tp1Lbl)
    if not na(tp2Lbl)
        label.delete(tp2Lbl)
    if not na(tp3Lbl)
        label.delete(tp3Lbl)
    if not na(tp4Lbl)
        label.delete(tp4Lbl)
    if not na(tp5Lbl)
        label.delete(tp5Lbl)
    entryLine := line.new(bar_index, activeEntry, bar_index + 1, activeEntry, extend = extend.right, color = entryColor, width = entryLineWidth)
    slLine := line.new(bar_index, activeSL, bar_index + 1, activeSL, extend = extend.right, color = slColor, width = slLineWidth, style = f_lineStyle(slTpLineStyle))
    tp1Line := line.new(bar_index, tp1, bar_index + 1, tp1, extend = extend.right, color = tpColor, width = tpLineWidth, style = f_lineStyle(slTpLineStyle))
    tp2Line := line.new(bar_index, tp2, bar_index + 1, tp2, extend = extend.right, color = tpColor, width = tpLineWidth, style = f_lineStyle(slTpLineStyle))
    tp3Line := line.new(bar_index, tp3, bar_index + 1, tp3, extend = extend.right, color = tpColor, width = tpLineWidth, style = f_lineStyle(slTpLineStyle))
    tp4Line := line.new(bar_index, tp4, bar_index + 1, tp4, extend = extend.right, color = tpColor, width = tpLineWidth, style = f_lineStyle(slTpLineStyle))
    tp5Line := line.new(bar_index, tp5, bar_index + 1, tp5, extend = extend.right, color = tpColor, width = tpLineWidth, style = f_lineStyle(slTpLineStyle))
    entryLbl := f_levelLabel(activeEntry, "ENTRY: " + str.tostring(activeEntry, format.mintick), entryColor, color.black)
    slLbl := f_levelLabel(activeSL, "STOP LOSS: " + str.tostring(activeSL, format.mintick), slColor, color.white)
    tp1Lbl := f_levelLabel(tp1, "TP1: " + str.tostring(tp1, format.mintick), tpColor, color.black)
    tp2Lbl := f_levelLabel(tp2, "TP2: " + str.tostring(tp2, format.mintick), tpColor, color.black)
    tp3Lbl := f_levelLabel(tp3, "TP3: " + str.tostring(tp3, format.mintick), tpColor, color.black)
    tp4Lbl := f_levelLabel(tp4, "TP4: " + str.tostring(tp4, format.mintick), tpColor, color.black)
    tp5Lbl := f_levelLabel(tp5, "TP5: " + str.tostring(tp5, format.mintick), tpColor, color.black)

// Deliberately NOT deleted when the trade closes (SL/TP5/max-hold) - the
// Entry/SL/TP plan from the LATEST valid signal (algorithmic or manual lock)
// stays on screen as a fixed reference, extending via extend=right, exactly
// like the requested reference style: always showing the most recent valid
// entry rather than a constantly-moving live preview. It's only replaced the
// moment a NEW signal fires (see the delete-then-recreate block inside
// "if longSignal"/"if shortSignal" above) - the dashboard's own "Active Trade"
// row and the WHY panel remain the live, current-state indicators; this chart
// layer is intentionally a historical/reference layer, not a live one.

// =============================================================================
// SUPPORT / RESISTANCE ZONE BOXES
// =============================================================================
var box buyZoneBox = na
var box sellZoneBox = na
if showZones
    if na(buyZoneBox)
        buyZoneBox := box.new(bar_index, buyZoneTop, bar_index + 1, buyZoneBottom,
             border_color = color.new(bullColor, 60), bgcolor = color.new(bullColor, 88), extend = extend.none)
    else
        box.set_top(buyZoneBox, buyZoneTop)
        box.set_bottom(buyZoneBox, buyZoneBottom)
        box.set_right(buyZoneBox, bar_index + 1)
    if na(sellZoneBox)
        sellZoneBox := box.new(bar_index, sellZoneTop, bar_index + 1, sellZoneBottom,
             border_color = color.new(bearColor, 60), bgcolor = color.new(bearColor, 88), extend = extend.none)
    else
        box.set_top(sellZoneBox, sellZoneTop)
        box.set_bottom(sellZoneBox, sellZoneBottom)
        box.set_right(sellZoneBox, bar_index + 1)

// =============================================================================
// LIQUIDITY LINES
// =============================================================================
var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na
var line asiaHLine = na
var line asiaLLine = na
var line lonHLine = na
var line lonLLine = na

if showLiqLines
    pdhLine := f_updateLevelLine(pdhLine, pdh, color.new(neutColor, 30), showPDHL)
    pdlLine := f_updateLevelLine(pdlLine, pdl, color.new(neutColor, 30), showPDHL)
    pwhLine := f_updateLevelLine(pwhLine, pwh, color.new(color.purple, 30), showPWHL)
    pwlLine := f_updateLevelLine(pwlLine, pwl, color.new(color.purple, 30), showPWHL)
    asiaHLine := f_updateLevelLine(asiaHLine, asiaHigh, color.new(color.yellow, 40), showAsia)
    asiaLLine := f_updateLevelLine(asiaLLine, asiaLow, color.new(color.yellow, 40), showAsia)
    lonHLine := f_updateLevelLine(lonHLine, londonHigh, color.new(color.blue, 40), showLondon)
    lonLLine := f_updateLevelLine(lonLLine, londonLow, color.new(color.blue, 40), showLondon)

// =============================================================================
// TREND RIBBON — subtle background tint reflecting the active regime/direction
// (not a value-based plot, so it can't turn into a noisy wide band at any zoom).
// =============================================================================
ribbonBg = isTrending and bullTrend ? color.new(bullColor, 90) : isTrending and bearTrend ? color.new(bearColor, 90) : na
bgcolor(showRibbon ? ribbonBg : na, title = "Trend Ribbon")

// =============================================================================
// EMA / ATR PLOTS
// =============================================================================
plot(showEmas ? ema200 : na, "EMA 200 (Trend)", color = color.new(color.orange, 0), linewidth = 2)
plot(showEmas ? emaFast : na, "EMA Fast (Pullback)", color = color.new(color.aqua, 0), linewidth = 1)

// =============================================================================
// DASHBOARD
// =============================================================================
f_biasText(int b) => b == 1 ? "▲ Bullish" : b == -1 ? "▼ Bearish" : "— Neutral"
f_stars(float score) =>
    n = math.max(0, math.min(5, math.round(score / 20)))
    string s = ""
    for i = 1 to 5
        s += i <= n ? "★" : "☆"
    s

var table dash = table.new(
     dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left :
     dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left,
     2, 20, bgcolor = color.new(color.black, 15), border_color = color.new(neutColor, 60), border_width = 1)

f_cell(int row, string label_, string val, color valColor) =>
    table.cell(dash, 0, row, label_, text_color = color.new(color.white, 20), text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, row, val, text_color = valColor, text_size = size.small, text_halign = text.align_right)

if showDash and barstate.islast
    table.cell(dash, 0, 0, "AURUM XAUUSD V2", text_color = color.white, text_size = size.normal, bgcolor = color.new(color.teal, 40))
    table.merge_cells(dash, 0, 0, 1, 0)
    // Decision Panel / "Patience Meter" - top of dashboard, unified state.
    table.cell(dash, 0, 1, decisionEmoji + " " + decisionState, text_color = color.white, text_size = size.normal,
         bgcolor = color.new(f_confidenceColor(bestConfidence), 30))
    table.merge_cells(dash, 0, 1, 1, 1)
    f_cell(2, "Market Regime", marketRegime + " (ADX " + str.tostring(math.round(adxVal)) + ")",
         marketRegime == "Trending" ? bullColor : marketRegime == "Expansion" ? tpColor : neutColor)
    f_cell(3, "Daily / 4H / 1H Bias", f_biasText(dBias) + " / " + f_biasText(h4Bias) + " / " + f_biasText(h1Bias), neutColor)
    f_cell(4, "EMA200 Bias", bullTrend ? "▲ Bullish" : "▼ Bearish", bullTrend ? bullColor : bearColor)
    f_cell(5, "Support", str.tostring(support, format.mintick) + "  (" + str.tostring(distToSupport / atrVal, "#.##") + " ATR)", bullColor)
    f_cell(6, "Resistance", str.tostring(resistance, format.mintick) + "  (" + str.tostring(distToResistance / atrVal, "#.##") + " ATR)", bearColor)
    f_cell(7, "Position Context", positionContext, neutColor)
    f_cell(8, "Zone (Premium/Discount)", zoneLabel, zoneLabel == "Premium" ? bearColor : zoneLabel == "Discount" ? bullColor : neutColor)
    f_cell(9, "ATR", str.tostring(atrVal, format.mintick), color.white)
    f_cell(10, "Session", currentSession + (inKillzone ? " (Kill Zone)" : ""), inKillzone ? bullColor : neutColor)
    f_cell(11, "BUY Confidence", f_stars(longConfidence) + " " + str.tostring(math.round(longConfidence)) + "/100 (" + f_confidenceLabel(longConfidence) + ")",
         f_confidenceColor(longConfidence))
    f_cell(12, "SELL Confidence", f_stars(shortConfidence) + " " + str.tostring(math.round(shortConfidence)) + "/100 (" + f_confidenceLabel(shortConfidence) + ")",
         f_confidenceColor(shortConfidence))
    f_cell(13, "Active Trade", tradeIsActive ? (isLongTrade ? "BUY @ " : "SELL @ ") + str.tostring(activeEntry, format.mintick) + " (" + activeMode + ", Grade " + sig_grade + ")" : "None",
         tradeIsActive ? (isLongTrade ? bullColor : bearColor) : neutColor)
    f_cell(14, "TP Hits", (tp1Hit ? "1✓ " : "1• ") + (tp2Hit ? "2✓ " : "2• ") + (tp3Hit ? "3✓ " : "3• ") + (tp4Hit ? "4✓ " : "4• ") + (tp5Hit ? "5✓" : "5•"),
         color.white)
    f_cell(15, "Trade Management", managementAdvice, neutColor)
    [scenA, scenB, scenC, scenInvalid] = f_scenarioText(bestDirection == "BUY", marketRegime, bestConfidence)
    f_cell(16, "Scenario A", scenA, neutColor)
    f_cell(17, "Scenario B", scenB, neutColor)
    f_cell(18, "Scenario C", scenC, neutColor)
    f_cell(19, "Invalidation", scenInvalid, bearColor)

// =============================================================================
// WHY / WHY-NOT PANEL — explicit checklist for the CURRENTLY ACTIVE trade, or
// (if none is active - either none has fired yet, or the last one already
// closed) a live WHY-NOT breakdown for whichever direction currently leads, so
// patience has a stated reason instead of just silence. Deliberately keyed on
// tradeIsActive rather than "has a signal ever fired" - otherwise this panel
// would keep showing a closed trade's old snapshot forever even after the
// live leading direction has since flipped (confirmed: this is exactly what
// was happening before this fix).
// =============================================================================
fired = tradeIsActive

// Live fractions for whichever direction currently leads - used for the
// WHY-NOT preview when no signal has fired yet.
liveTrendAlignFrac = bestDirection == "BUY" ? trendAlignFracLong : trendAlignFracShort
liveSRFrac         = bestDirection == "BUY" ? srFracLong : srFracShort
liveEmaBiasFrac    = bestDirection == "BUY" ? emaBiasFracLong : emaBiasFracShort
liveConfirmFrac    = bestDirection == "BUY" ? bullConfirmFrac : bearConfirmFrac
liveMomFrac        = bestDirection == "BUY" ? momFracLong : momFracShort
// RR is now a fixed constant (your TP3 R-multiple setting) rather than a
// market-structure-derived ratio - see the Stop Loss/Take Profit inputs.
liveRR             = tp3R

// Backs a 0-1 fraction out of a snapshotted score/weight pair (fired branch),
// or falls through to the live fraction (not-yet-fired branch) - lets both
// branches share one row-drawing pass instead of two separate layouts.
f_dispFrac(bool isFired, float sigScore, float liveFrac, float weight) =>
    isFired ? (weight > 0 ? sigScore / weight : 1.0) : liveFrac

dispTrendAlignFrac = f_dispFrac(fired, sig_trendAlignScore, liveTrendAlignFrac, wTrendAlign)
dispSRFrac         = f_dispFrac(fired, sig_srScore, liveSRFrac, wSR)
dispEmaBiasFrac    = f_dispFrac(fired, sig_emaBiasScore, liveEmaBiasFrac, wEmaBias)
dispConfirmFrac    = f_dispFrac(fired, sig_confirmScore, liveConfirmFrac, wConfirm)
dispMomFrac        = f_dispFrac(fired, sig_momScore, liveMomFrac, wMomentum)
dispAtrFrac        = f_dispFrac(fired, sig_atrScore, atrFrac, wAtr)
dispSessionFrac     = f_dispFrac(fired, sig_sessionScore, sessionFrac, wSession)
dispRR              = fired ? sig_rr : liveRR

f_checkMark(bool pass) => pass ? "✓" : "✗"
f_checkColor(bool pass) => pass ? bullColor : bearColor

var table explain = table.new(position.bottom_left, 2, 11, bgcolor = color.new(color.black, 15),
     border_color = color.new(neutColor, 60), border_width = 1)

if showExplain and barstate.islast
    headerText = fired ? sig_dir + " — " + str.tostring(math.round(sig_total)) + "/100 (" + f_confidenceLabel(sig_total) + ") — Grade " + sig_grade :
         "NO SIGNAL YET — " + bestDirection + " leading @ " + str.tostring(math.round(bestConfidence)) + "/100"
    table.cell(explain, 0, 0, headerText, text_color = color.white, text_size = size.normal,
         bgcolor = color.new(fired ? (sig_dir == "SELL" ? color.maroon : color.teal) : color.gray, 40))
    table.merge_cells(explain, 0, 0, 1, 0)
    table.cell(explain, 0, 1, "Regime", text_color = color.new(color.white, 20), text_size = size.small, text_halign = text.align_left)
    table.cell(explain, 1, 1, fired ? sig_regime : marketRegime, text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(explain, 0, 2, f_checkMark(dispTrendAlignFrac >= 0.5) + " Trend Alignment", text_color = f_checkColor(dispTrendAlignFrac >= 0.5), text_size = size.small, text_halign = text.align_left)
    table.cell(explain, 1, 2, str.tostring(dispTrendAlignFrac * wTrendAlign, "#.#") + " / " + str.tostring(wTrendAlign, "#"), text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(explain, 0, 3, f_checkMark(dispSRFrac >= 0.5) + " Support/Resistance", text_color = f_checkColor(dispSRFrac >= 0.5), text_size = size.small, text_halign = text.align_left)
    table.cell(explain, 1, 3, str.tostring(dispSRFrac * wSR, "#.#") + " / " + str.tostring(wSR, "#"), text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(explain, 0, 4, f_checkMark(dispEmaBiasFrac >= 0.5) + " EMA Bias", text_color = f_checkColor(dispEmaBiasFrac >= 0.5), text_size = size.small, text_halign = text.align_left)
    table.cell(explain, 1, 4, str.tostring(dispEmaBiasFrac * wEmaBias, "#.#") + " / " + str.tostring(wEmaBias, "#"), text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(explain, 0, 5, f_checkMark(dispConfirmFrac >= 0.5) + " Confirmation Candle", text_color = f_checkColor(dispConfirmFrac >= 0.5), text_size = size.small, text_halign = text.align_left)
    table.cell(explain, 1, 5, str.tostring(dispConfirmFrac * wConfirm, "#.#") + " / " + str.tostring(wConfirm, "#"), text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(explain, 0, 6, f_checkMark(dispMomFrac >= 0.5) + " Momentum", text_color = f_checkColor(dispMomFrac >= 0.5), text_size = size.small, text_halign = text.align_left)
    table.cell(explain, 1, 6, str.tostring(dispMomFrac * wMomentum, "#.#") + " / " + str.tostring(wMomentum, "#"), text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(explain, 0, 7, f_checkMark(dispAtrFrac >= 0.5) + " ATR", text_color = f_checkColor(dispAtrFrac >= 0.5), text_size = size.small, text_halign = text.align_left)
    table.cell(explain, 1, 7, str.tostring(dispAtrFrac * wAtr, "#.#") + " / " + str.tostring(wAtr, "#"), text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(explain, 0, 8, f_checkMark(dispSessionFrac >= 0.5) + " Session", text_color = f_checkColor(dispSessionFrac >= 0.5), text_size = size.small, text_halign = text.align_left)
    table.cell(explain, 1, 8, str.tostring(dispSessionFrac * wSession, "#.#") + " / " + str.tostring(wSession, "#"), text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(explain, 0, 9, "Risk / Reward", text_color = color.new(color.white, 20), text_size = size.small, text_halign = text.align_left)
    table.cell(explain, 1, 9, na(dispRR) ? "—" : str.tostring(dispRR, "#.##") + "R", text_color = (na(dispRR) or dispRR < 1.5) ? bearColor : bullColor, text_size = size.small, text_halign = text.align_right)
    // Last row: Stop/Target once a signal has fired, otherwise the explicit
    // WHY-NOT reasons list (matches the user-facing "NO TRADE, Reason: ..." spec).
    string whyNot = ""
    if liveRR < 1.5
        whyNot := whyNot + "✗ Poor Risk/Reward\n"
    if liveMomFrac < 0.5
        whyNot := whyNot + "✗ Weak Momentum\n"
    if liveSRFrac < 0.5
        whyNot := whyNot + "✗ Too far from Support/Resistance\n"
    if liveTrendAlignFrac < 0.5 or liveEmaBiasFrac < 0.5
        whyNot := whyNot + "✗ Trend Conflict\n"
    if whyNot == ""
        whyNot := "No blocking issues - waiting on confidence threshold."
    table.cell(explain, 0, 10, fired ? "Stop / Target" : "Why Not", text_color = color.new(color.white, 20), text_size = size.small, text_halign = text.align_left)
    table.cell(explain, 1, 10, fired ? str.tostring(activeSL, format.mintick) + " / " + str.tostring(tp3, format.mintick) : whyNot,
         text_color = fired ? color.white : bearColor, text_size = size.small, text_halign = text.align_right)

// =============================================================================
// GOLD-SYMBOL WARNING
// =============================================================================
var label goldWarnLbl = na
if not isGold and barstate.islast
    if not na(goldWarnLbl)
        label.delete(goldWarnLbl)
    goldWarnLbl := label.new(bar_index, high, "⚠ Aurum is tuned for XAUUSD/Gold — results on other symbols are unvalidated",
         style = label.style_label_down, color = color.new(color.orange, 20), textcolor = color.black, size = size.small)

// =============================================================================
// ALERT CONDITIONS
// =============================================================================
alertcondition(longSignal, title = "Aurum BUY", message = "Aurum XAUUSD BUY signal")
alertcondition(shortSignal, title = "Aurum SELL", message = "Aurum XAUUSD SELL signal")
````
