# Squeeze Engine PRO [CandleChasers]

- url: https://www.tradingview.com/script/wTQjU9uS-Squeeze-Engine-PRO-CandleChasers/
- type: indicator
- pine_id: PUB;8682f207b5654a31950d91e42c45e3e9
- version: 1.0

## Description

Squeeze Engine PRO [CandleChasers] combines volatility compression, directional momentum and a single-position signal lifecycle. Its purpose is to make compression setups, entry qualifications and exit conditions easier to distinguish on standard time-based charts.

HOW IT WORKS
Bollinger Bands are compared with Keltner Channels to identify loose, medium and deep compression. PRO and Early use detrended linear-regression momentum. A release occurs when price volatility leaves the outer compression envelope. Classic uses a fixed 20-period, 2-deviation Bollinger envelope, a 20-period, 1.5-range Keltner envelope, and 12-bar close momentum; its release is defined by the medium envelope.

THREE ENGINES
PRO qualifies setups using local EMA trend, optional confirmed higher-timeframe trend, optional ADX/directional movement and relative volume, and a confluence threshold.
Early permits qualifying entries during compression and uses momentum slope rather than acceleration as its impulse requirement. Filters and the zero-side requirement still apply; disable the latter if you want entries before a zero crossing.
Classic uses momentum sign on the release bar. An optional slope setting uses rising momentum for long entries and falling momentum for shorts, including when momentum is still on the opposite side of zero. Classic bypasses the PRO entry filters and confluence score.

PRESETS
Scalping, Day Trading and Swing Trading adjust PRO/Early lengths to 14, 20 and 24, local EMA lengths to 34, 50 and 89, and release windows to 3, 5 and 7 bars after release, inclusive. They do not change the chart timeframe or guarantee suitability for a market. Classic retains fixed compression lengths.
Earlier Signals, Balanced and Stronger Confirmation change minimum compression duration, score thresholds and ADX/relative-volume thresholds. Stronger Confirmation adds sustained momentum requirements; its name describes its rules, not a measured reduction in false signals.

CONFLUENCE SCORE
The 0-100 score summarizes the active squeeze, trend, momentum, participation and strength components. Disabled ADX and disabled/unavailable volume are excluded and the remaining weights are normalized. When optional no-squeeze entries are enabled outside a release window, squeeze weight is excluded. Scores are not probabilities, win rates or performance forecasts. They are informational and unused for Classic entries.

MARKERS AND COLORS
Bright green: positive momentum rising. Dark green: positive momentum weakening or unchanged. Bright red: negative momentum falling. Dark red: negative momentum rising or unchanged.
Compression dots: yellow loose, orange medium, purple deep, gray open. Classic uses orange while compressed and gray when open.
R: squeeze release. E: early bullish/bearish setup, not necessarily an entry. DIV: pivot-confirmed divergence. BUY: long entry. SELL: short entry, not an instruction to exit an existing long. EXIT: exit of the tracked virtual position.
Divergences appear on the confirmation bar, after the selected number of right-side pivot bars. They are not plotted retrospectively at the pivot.

TRADE LIFECYCLE
The dashboard shows standby, charging, armed, in-trade and cooldown states. Only one virtual position can be tracked at a time. Squeeze-based entries are limited to one per compression episode. Optional no-squeeze entries use readiness transitions. Exits cannot produce a new entry on the same bar. Display toggles do not alter the lifecycle or alert logic.

VIRTUAL RISK LEVELS
Entry is the signal-bar close. PRO/Early use an ATR initial stop, reward:risk target and optional ATR trail. Trail updates become effective on the next bar. Classic uses a fixed initial distance of two ATR, no target or trail, and exits on the first momentum-fade bar. PRO/Early can exit after two consecutive fade bars. Stops and targets may be plotted on the price chart or inspected in the data window. These are informational levels, not orders or broker-emulator fills. The dashboard identifies bars that touch both stop and target as having unknown intrabar ordering.

USAGE AND ALERTS
Begin with Day Trading, PRO and Balanced, then assess behavior on your own instrument and standard candle timeframe. Enable price-chart levels if useful. Select Once Per Bar Close for alerts. Alerts are generated separately from marker visibility. After changing settings or updating the script, recreate existing alerts because they retain the prior script configuration.
The histogram, compression display and dashboard can change during the current bar. Entry, exit, early-setup, release and divergence events require chart-bar confirmation. Higher-timeframe trend uses the preceding confirmed higher-timeframe bar and therefore has a deliberate delay. ATR normalization affects the histogram display only.

LIMITATIONS
This is an indicator, not a backtested strategy. No win rate, profitability or false-signal improvement is claimed. Signal-bar closes and OHLC stop/target touches do not model spread, slippage, fees, liquidity, gaps or intrabar fill ordering. Data revisions and changes to available chart history can alter historical results. Tick volume may be used by some feeds; unavailable volume is excluded from scoring and its filter is bypassed. Standard time-based candles or bars are required. Very large chart timeframes may require manual HTF selection or disabling that filter. Classic ignores custom compression widths and several PRO controls as described above.

ORIGINALITY AND SOURCE CREDIT
Source credit: LazyBear, author of Squeeze Momentum Indicator [LazyBear] (SQZMOM_LB). The PRO/Early detrended linear-regression momentum component is adapted from the original code supplied for this project. The compression concept is established technical-analysis practice. CandleChasers adds a purpose-built combination of selectable engines, active-weight confluence, confirmed HTF filtering, one-entry-per-squeeze lifecycle, independent visibility controls, explicit virtual exits and a unified dashboard.

## Source Code

````pine
//@version=6
indicator("Squeeze Engine PRO [CandleChasers]", shorttitle="CC Squeeze PRO", overlay=false, max_labels_count=300, max_lines_count=100)

// Squeeze Engine PRO [CandleChasers]
// Indicator and signal research tool. Not a backtested strategy.
// Default settings are starting points, NOT optimized or guaranteed.

// ───── 1. Profiles ─────
gProfile = "01 • CandleChasers Presets"
tradeStyle = input.string("Day Trading", "Trading style", options=["Scalping", "Day Trading", "Swing Trading"], group=gProfile)
signalMode = input.string("Balanced", "Signal personality", options=["Earlier Signals", "Balanced", "Stronger Confirmation"], group=gProfile)
engineMode = input.string("CandleChasers PRO", "Signal engine", options=["CandleChasers Classic", "CandleChasers PRO", "CandleChasers Early"], group=gProfile)
classicSlope = input.bool(false, "Classic: allow opposite-side rising/falling momentum", tooltip="Off: direction follows 12-bar momentum sign. On: direction follows its slope, allowing rising negative momentum longs and the symmetric short case. Enable to anticipate momentum reversals before a zero crossing.", group=gProfile)
cooldownBars = input.int(3, "Bars to wait after an exit", minval=0, maxval=500, group=gProfile)
customLengths = input.bool(false, "Override preset lengths", group=gProfile)
userBBLen = input.int(20, "Custom BB length", minval=5, maxval=500, group=gProfile)
userKCLen = input.int(20, "Custom KC length", minval=5, maxval=500, group=gProfile)
userBBMult = input.float(2.0, "BB multiplier", minval=0.1, step=0.1, group=gProfile)

int presetLen = tradeStyle == "Scalping" ? 14 : tradeStyle == "Day Trading" ? 20 : 24
bool classicMode = engineMode == "CandleChasers Classic"
int bbLen = classicMode ? 20 : customLengths ? userBBLen : presetLen
int kcLen = classicMode ? 20 : customLengths ? userKCLen : presetLen
int trendLen = tradeStyle == "Scalping" ? 34 : tradeStyle == "Day Trading" ? 50 : 89
int freshBars = tradeStyle == "Scalping" ? 3 : tradeStyle == "Day Trading" ? 5 : 7
int minSqueezeBars = signalMode == "Earlier Signals" ? 2 : signalMode == "Balanced" ? 3 : 5
int scoreThreshold = signalMode == "Earlier Signals" ? 60 : signalMode == "Balanced" ? 75 : 85
float adxMin = signalMode == "Earlier Signals" ? 15.0 : signalMode == "Balanced" ? 18.0 : 22.0
float rvolMin = signalMode == "Earlier Signals" ? 0.9 : signalMode == "Balanced" ? 1.15 : 1.4

// ───── 2. Filter controls ─────
gFilters = "02 • Signal Filters"
useHTF = input.bool(true, "Use confirmed higher-timeframe trend", group=gFilters)
autoHTF = input.bool(true, "Automatic higher timeframe", group=gFilters)
manualHTF = input.timeframe("240", "Manual higher timeframe", group=gFilters)
useADX = input.bool(true, "Use ADX / DI filter", group=gFilters)
useVol = input.bool(true, "Use relative volume filter (auto-skip absent volume)", group=gFilters)
requireZero = input.bool(true, "Require momentum on trade's side of zero", tooltip="Applies to PRO and Early. Disable to permit entries before momentum crosses zero.", group=gFilters)
allowNoSqueeze = input.bool(false, "Allow momentum entries without recent squeeze", group=gFilters)
// Lifecycle signals always wait for the chart bar to close.

// ───── 3. Volatility and momentum ─────
gEngine = "03 • Squeeze Engine"
useTR = input.bool(true, "KC uses true range", group=gEngine)
wideKC = input.float(2.0, "Wide KC (loose squeeze)", step=0.1, minval=0.1, group=gEngine)
normalKC = input.float(1.5, "Normal KC (medium squeeze)", step=0.1, minval=0.1, group=gEngine)
tightKC = input.float(1.0, "Tight KC (deep squeeze)", step=0.1, minval=0.1, group=gEngine)
normalizeMomentum = input.bool(false, "Normalize histogram by ATR", tooltip="Display only. Does not alter entries, exits, scores, or divergences.", group=gEngine)
accelSmoothing = input.int(3, "Acceleration smoothing", minval=1, maxval=100, group=gEngine)

// ───── 4. Divergences ─────
gDivergence = "04 • Confirmed Pivot Divergences"
showDivergences = input.bool(true, "Display divergence markers", group=gDivergence)
pivotLeft = input.int(4, "Pivot left bars", minval=1, maxval=20, group=gDivergence)
pivotRight = input.int(4, "Pivot confirmation bars", minval=1, maxval=20, group=gDivergence)
maxPivotDistance = input.int(80, "Maximum bars between pivots", minval=5, maxval=500, group=gDivergence)

// ───── 5. Trade management ─────
gRisk = "05 • Trade Map (Indicator Simulation)"
showTradeMap = input.bool(true, "Display virtual trade levels", group=gRisk)
atrPeriod = input.int(14, "ATR period", minval=1, maxval=500, group=gRisk)
atrStopMult = input.float(1.8, "Initial stop ATR", minval=0.1, step=0.1, group=gRisk)
rewardMult = input.float(2.0, "Target reward:risk", minval=0.1, step=0.25, group=gRisk)
trailEnabled = input.bool(true, "Enable ATR trailing stop", group=gRisk)
trailATR = input.float(2.0, "Trail ATR from favorable extreme", minval=0.1, step=0.1, group=gRisk)
exitOnFade = input.bool(true, "Exit on two bars of momentum fade", group=gRisk)

// ───── 6. Visual controls ─────
gVisual = "06 • CandleChasers Visuals"
showExits = input.bool(true, "Show exit markers", group=gVisual)
showPriceMap = input.bool(false, "Plot virtual entry / stop / target on price chart", group=gVisual)
showDashboard = input.bool(true, "Show dashboard", group=gVisual)
showEarly = input.bool(true, "Show early setup markers", group=gVisual)
showSignals = input.bool(true, "Show confirmed BUY / SELL markers", group=gVisual)
showBackground = input.bool(false, "Subtle compression background", group=gVisual)
showScoreInData = input.bool(true, "Expose score in data window", group=gVisual)

// ───── Volatility compression: correct BB multiplier ─────
float src = close
float bbBasis = ta.sma(src, bbLen)
float bbDev = (classicMode ? 2.0 : userBBMult) * ta.stdev(src, bbLen)
float upperBB = bbBasis + bbDev
float lowerBB = bbBasis - bbDev
float kcBasis = ta.sma(src, kcLen)
float kcRange = useTR ? ta.tr(true) : high - low
float kcAvgRange = ta.sma(kcRange, kcLen)
float effectiveWideKC = classicMode ? 2.0 : wideKC
float effectiveNormalKC = classicMode ? 1.5 : normalKC
float effectiveTightKC = classicMode ? 1.0 : tightKC
bool sqzLoose = lowerBB > kcBasis - kcAvgRange * effectiveWideKC and upperBB < kcBasis + kcAvgRange * effectiveWideKC
bool sqzMedium = lowerBB > kcBasis - kcAvgRange * effectiveNormalKC and upperBB < kcBasis + kcAvgRange * effectiveNormalKC
bool sqzDeep = lowerBB > kcBasis - kcAvgRange * effectiveTightKC and upperBB < kcBasis + kcAvgRange * effectiveTightKC
int squeezeLevel = sqzDeep ? 3 : sqzMedium ? 2 : sqzLoose ? 1 : 0
if not classicMode and not (wideKC > normalKC and normalKC > tightKC)
    runtime.error("CandleChasers: KC widths must satisfy Wide > Normal > Tight.")
bool inSqueeze = classicMode ? sqzMedium : squeezeLevel > 0
bool release = not inSqueeze and inSqueeze[1]
var int episode = 0
if inSqueeze and not inSqueeze[1]
    episode += 1
var int squeezeDuration = 0
squeezeDuration := inSqueeze ? nz(squeezeDuration[1]) + 1 : 0
var int lastSqueezeDuration = 0
if release
    lastSqueezeDuration := nz(squeezeDuration[1])
int sinceRelease = ta.barssince(release)
bool freshRelease = not inSqueeze and not na(sinceRelease) and sinceRelease <= freshBars and lastSqueezeDuration >= minSqueezeBars

// PRO/Early momentum adapted from Squeeze Momentum Indicator [LazyBear].
// Credit: LazyBear, original author of the supplied SQZMOM_LB momentum code.
// Protected publication requires explicit closed-source reuse permission.
// Classic uses standard 12-bar close momentum.
float midPrice = (ta.highest(high, kcLen) + ta.lowest(low, kcLen)) / 2.0
float anchor = (midPrice + ta.sma(close, kcLen)) / 2.0
float lbMomentum = ta.linreg(src - anchor, kcLen, 0)
float rawMomentum = classicMode ? ta.mom(close, 12) : lbMomentum
float atr = ta.atr(atrPeriod)
float momentum = normalizeMomentum ? rawMomentum / math.max(atr, syminfo.mintick) : rawMomentum
// Normalization changes presentation only; raw momentum drives every signal.
float velocity = rawMomentum - rawMomentum[1]
float acceleration = ta.ema(velocity - velocity[1], accelSmoothing)
bool rising = rawMomentum > rawMomentum[1]
bool falling = rawMomentum < rawMomentum[1]
bool bullMomentum = rising and acceleration > 0
bool bearMomentum = falling and acceleration < 0

// ───── Higher timeframe: closed HTF values only ─────
int chartSeconds = timeframe.in_seconds()
if not chart.is_standard or na(chartSeconds)
    runtime.error("CandleChasers: use standard time-based candles or bars.")
string automaticTF = timeframe.from_seconds(math.min(chartSeconds * (tradeStyle == "Swing Trading" ? 5 : tradeStyle == "Scalping" ? 12 : 8), 31536000))
string htf = autoHTF ? automaticTF : manualHTF
bool htfActive = useHTF and not classicMode
if htfActive and timeframe.in_seconds(htf) <= chartSeconds
    runtime.error("CandleChasers: HTF must exceed chart timeframe. Select a larger manual HTF. Automatic HTF may reach its limit on very large chart timeframes.")
float htfClose = na
float htfEma = na
if htfActive
    [confirmedClose, confirmedEma] = request.security(syminfo.tickerid, htf, [close[1], ta.ema(close, trendLen)[1]], lookahead=barmerge.lookahead_on)
    htfClose := confirmedClose
    htfEma := confirmedEma
float localEma = ta.ema(close, trendLen)
bool bullTrend = close > localEma and (not htfActive or htfClose > htfEma)
bool bearTrend = close < localEma and (not htfActive or htfClose < htfEma)

// ───── Strength and participation ─────
[diPlus, diMinus, adx] = ta.dmi(14, 14)
bool adxBull = adx >= adxMin and diPlus > diMinus
bool adxBear = adx >= adxMin and diMinus > diPlus
float avgVol = ta.sma(volume, 20)
bool hasVolume = not na(volume) and not na(avgVol) and avgVol > 0
float rvol = hasVolume ? volume / avgVol : na
bool volPass = not useVol or not hasVolume or rvol >= rvolMin
bool adxBullPass = not useADX or adxBull
bool adxBearPass = not useADX or adxBear

// ───── Score: normalized active confluence, never a win probability ─────
int squeezePoints = freshRelease ? (lastSqueezeDuration >= minSqueezeBars * 2 ? 25 : 18) : inSqueeze ? (squeezeLevel == 3 ? 25 : squeezeLevel == 2 ? 18 : 10) : 0
bool scoreSqueezeActive = not (allowNoSqueeze and not inSqueeze and not freshRelease)
bool scoreVolumeActive = useVol and hasVolume
int volumePoints = scoreVolumeActive ? (rvol >= rvolMin ? 15 : rvol >= rvolMin * 0.8 ? 7 : 0) : 0
int scoreMaximum = 45 + (scoreSqueezeActive ? 25 : 0) + (scoreVolumeActive ? 15 : 0) + (useADX ? 15 : 0)
int longPoints = (scoreSqueezeActive ? squeezePoints : 0) + (bullTrend ? 25 : 0) + (bullMomentum ? 20 : rising ? 10 : 0) + volumePoints + (useADX and adxBull ? 15 : 0)
int shortPoints = (scoreSqueezeActive ? squeezePoints : 0) + (bearTrend ? 25 : 0) + (bearMomentum ? 20 : falling ? 10 : 0) + volumePoints + (useADX and adxBear ? 15 : 0)
int longScore = int(math.round(100.0 * longPoints / scoreMaximum))
int shortScore = int(math.round(100.0 * shortPoints / scoreMaximum))

// ───── Entry engine / signal modes ─────
bool earlyMode = engineMode == "CandleChasers Early" or signalMode == "Earlier Signals"
bool strictMode = signalMode == "Stronger Confirmation"
bool candleOK = barstate.isconfirmed
bool setupEligible = allowNoSqueeze or freshRelease or (earlyMode and inSqueeze and squeezeDuration >= minSqueezeBars)
bool zeroLong = not requireZero or rawMomentum > 0
bool zeroShort = not requireZero or rawMomentum < 0
bool longImpulse = earlyMode ? rising : strictMode ? (bullMomentum and rawMomentum > rawMomentum[1] and rawMomentum[1] > rawMomentum[2]) : bullMomentum
bool shortImpulse = earlyMode ? falling : strictMode ? (bearMomentum and rawMomentum < rawMomentum[1] and rawMomentum[1] < rawMomentum[2]) : bearMomentum
bool longReady = candleOK and setupEligible and zeroLong and bullTrend and volPass and adxBullPass and longImpulse and longScore >= scoreThreshold
bool shortReady = candleOK and setupEligible and zeroShort and bearTrend and volPass and adxBearPass and shortImpulse and shortScore >= scoreThreshold
// CandleChasers Classic release uses fixed 20/2 BB, 20/1.5 KC and 12-close momentum.
// Slope exception is optional to avoid conflicting long/short interpretations.
if classicMode
    longReady := candleOK and release and (classicSlope ? rising : rawMomentum > 0)
    shortReady := candleOK and release and (classicSlope ? falling : rawMomentum < 0)
bool earlyLong = candleOK and inSqueeze and squeezeDuration >= minSqueezeBars and rising and rawMomentum > rawMomentum[2] and bullTrend
bool earlyShort = candleOK and inSqueeze and squeezeDuration >= minSqueezeBars and falling and rawMomentum < rawMomentum[2] and bearTrend
bool earlyLongSignal = earlyLong and not earlyLong[1]
bool earlyShortSignal = earlyShort and not earlyShort[1]

// ───── Pivot-confirmed divergence: confirmed after pivotRight bars ─────
float pLow = ta.pivotlow(low, pivotLeft, pivotRight)
float pHigh = ta.pivothigh(high, pivotLeft, pivotRight)
var float priorLowPrice = na
var float priorLowMom = na
var int priorLowBar = na
var float priorHighPrice = na
var float priorHighMom = na
var int priorHighBar = na
bool bullDiv = false
bool bearDiv = false
if not na(pLow) and candleOK
    int pivotBar = bar_index - pivotRight
    float pMom = rawMomentum[pivotRight]
    bullDiv := not na(priorLowBar) and pivotBar - priorLowBar <= maxPivotDistance and pLow < priorLowPrice and pMom > priorLowMom
    priorLowPrice := pLow
    priorLowMom := pMom
    priorLowBar := pivotBar
if not na(pHigh) and candleOK
    int pivotBar = bar_index - pivotRight
    float pMom = rawMomentum[pivotRight]
    bearDiv := not na(priorHighBar) and pivotBar - priorHighBar <= maxPivotDistance and pHigh > priorHighPrice and pMom < priorHighMom
    priorHighPrice := pHigh
    priorHighMom := pMom
    priorHighBar := pivotBar

// ───── Trade lifecycle: visibility never changes calculations ─────
// STANDBY -> CHARGING -> ARMED -> IN TRADE -> COOLDOWN.
// One entry per squeeze episode. Exits cannot become opposite entries on the same bar.
var int direction = 0
var float entry = na
var float stop = na
var float target = na
var float extreme = na
var int lastEntryBar = na
var int lastExitBar = na
var int tradedEpisode = -1
var string lastExitReason = "NONE"
bool exitLong = false
bool exitShort = false
bool buy = false
bool sell = false
bool exited = false
if direction != 0 and candleOK and bar_index > lastEntryBar
    bool hitStop = direction == 1 ? low <= stop : high >= stop
    bool hitTarget = not classicMode and (direction == 1 ? high >= target : low <= target)
    bool momentumFade = direction == 1 ? (classicMode ? falling : falling and falling[1]) : (classicMode ? rising : rising and rising[1])
    bool shouldExit = hitStop or hitTarget or ((classicMode or exitOnFade) and momentumFade)
    if shouldExit
        exitLong := direction == 1
        exitShort := direction == -1
        exited := true
        lastExitReason := hitStop and hitTarget ? "STOP + TARGET: ORDER UNKNOWN" : hitStop ? "STOP" : hitTarget ? "TARGET" : "MOMENTUM FADE"
        lastExitBar := bar_index
        direction := 0
        entry := na
        stop := na
        target := na
        extreme := na
    else
        extreme := direction == 1 ? math.max(extreme, high) : math.min(extreme, low)
        // Trail calculated after this bar's stop check; effective on the next bar.
        if trailEnabled and not classicMode
            stop := direction == 1 ? math.max(stop, extreme - atr * trailATR) : math.min(stop, extreme + atr * trailATR)
bool cooling = not na(lastExitBar) and bar_index - lastExitBar <= cooldownBars
bool episodeAvailable = episode > 0 and tradedEpisode != episode
bool noSqzEntry = allowNoSqueeze and not inSqueeze and not freshRelease and not classicMode
bool canEnter = candleOK and direction == 0 and not exited and not cooling and not na(atr) and atr > 0
buy := canEnter and longReady and (noSqzEntry ? not longReady[1] : episodeAvailable)
sell := canEnter and shortReady and not buy and (noSqzEntry ? not shortReady[1] : episodeAvailable)
if buy or sell
    direction := buy ? 1 : -1
    entry := close
    float riskDistance = math.max(atr * (classicMode ? 2.0 : atrStopMult), syminfo.mintick)
    stop := buy ? entry - riskDistance : entry + riskDistance
    target := classicMode ? na : buy ? entry + riskDistance * rewardMult : entry - riskDistance * rewardMult
    extreme := close
    lastEntryBar := bar_index
    if not noSqzEntry
        tradedEpisode := episode
string lifecycle = direction != 0 ? (direction == 1 ? "IN TRADE: LONG" : "IN TRADE: SHORT") : cooling ? "COOLDOWN" : inSqueeze ? "CHARGING" : freshRelease and episodeAvailable ? "ARMED" : "STANDBY"

// ───── CandleChasers visuals ─────
color bullBright = color.rgb(0, 220, 145)
color bullDim = color.rgb(0, 115, 87)
color bearBright = color.rgb(255, 83, 87)
color bearDim = color.rgb(142, 42, 67)
color histColor = momentum >= 0 ? (rising ? bullBright : bullDim) : (falling ? bearBright : bearDim)
color dotColor = classicMode ? (inSqueeze ? color.rgb(255, 158, 46) : color.rgb(113, 135, 153)) : squeezeLevel == 3 ? color.rgb(196, 76, 255) : squeezeLevel == 2 ? color.rgb(255, 158, 46) : squeezeLevel == 1 ? color.rgb(242, 218, 73) : color.rgb(113, 135, 153)
plot(momentum, "CandleChasers Momentum", color=histColor, style=plot.style_columns, linewidth=3)
plot(0, "Compression Level", color=dotColor, style=plot.style_circles, linewidth=3)
plotshape(release and candleOK, title="Squeeze released", style=shape.diamond, location=location.bottom, color=color.aqua, size=size.tiny, text="R")
plotshape(showEarly and earlyLongSignal, "Early Bull Signal (E)", shape.circle, location.bottom, color=color.new(bullBright, 0), size=size.tiny, text="E")
plotshape(showEarly and earlyShortSignal, "Early Bear Signal (E)", shape.circle, location.top, color=color.new(bearBright, 0), size=size.tiny, text="E")
plotshape(showSignals and buy, "Long Entry (BUY)", shape.labelup, location.bottom, color=bullBright, text="CC BUY", textcolor=color.black, size=size.tiny)
plotshape(showSignals and sell, "Short Entry (SELL)", shape.labeldown, location.top, color=bearBright, text="CC SELL", textcolor=color.white, size=size.tiny)
plotshape(showDivergences and bullDiv and candleOK, "Bullish Divergence (DIV)", shape.triangleup, location.bottom, color=color.lime, size=size.tiny, text="DIV")
plotshape(showDivergences and bearDiv and candleOK, "Bearish Divergence (DIV)", shape.triangledown, location.top, color=color.red, size=size.tiny, text="DIV")
plotshape(showExits and exitLong, "Exit Long (EXIT)", shape.xcross, location.bottom, color=color.yellow, size=size.tiny, text="EXIT")
plotshape(showExits and exitShort, "Exit Short (EXIT)", shape.xcross, location.top, color=color.yellow, size=size.tiny, text="EXIT")
bgcolor(showBackground and inSqueeze ? color.new(dotColor, 93) : na, title="Compression background")
plot(showScoreInData ? longScore : na, "Long confluence score", display=display.data_window)
plot(showScoreInData ? shortScore : na, "Short confluence score", display=display.data_window)
plot(showScoreInData ? rvol : na, "Relative volume", display=display.data_window)
plot(showScoreInData ? adx : na, "ADX", display=display.data_window)
plot(showScoreInData ? squeezeDuration : na, "Squeeze duration", display=display.data_window)
plot(showScoreInData and showTradeMap ? stop : na, "Virtual stop (price)", display=display.data_window)
plot(showScoreInData and showTradeMap ? target : na, "Virtual target (price)", display=display.data_window)

// ───── Dashboard ─────
plot(showPriceMap and showTradeMap ? entry : na, "Virtual entry", color=color.aqua, style=plot.style_linebr, force_overlay=true)
plot(showPriceMap and showTradeMap ? stop : na, "Virtual stop", color=color.red, style=plot.style_linebr, force_overlay=true)
plot(showPriceMap and showTradeMap ? target : na, "Virtual target", color=color.lime, style=plot.style_linebr, force_overlay=true)
var table dash = table.new(position.top_right, 2, 11, border_width=1)
if showDashboard and barstate.islast
    color head = color.rgb(21, 32, 45)
    color bg = color.rgb(34, 44, 58)
    color fg = color.white
    string sqzText = classicMode ? (inSqueeze ? "CLASSIC SQUEEZE" : "OPEN") : squeezeLevel == 3 ? "DEEP" : squeezeLevel == 2 ? "MEDIUM" : squeezeLevel == 1 ? "LOOSE" : freshRelease ? "RELEASED" : "OPEN"
    string trendText = bullTrend ? "BULL" : bearTrend ? "BEAR" : "MIXED"
    string momText = bullMomentum ? "ACCEL UP" : bearMomentum ? "ACCEL DOWN" : rising ? "UP / SLOW" : "DOWN / SLOW"
    table.cell(dash, 0, 0, "CANDLECHASERS", text_color=color.aqua, bgcolor=head)
    table.cell(dash, 1, 0, "SQZ ENGINE PRO", text_color=fg, bgcolor=head)
    table.cell(dash, 0, 1, "STYLE / MODE", text_color=fg, bgcolor=bg)
    table.cell(dash, 1, 1, tradeStyle + " / " + signalMode, text_color=fg, bgcolor=bg, text_size=size.tiny)
    table.cell(dash, 0, 2, "SQUEEZE", text_color=fg, bgcolor=bg)
    table.cell(dash, 1, 2, sqzText + " | " + str.tostring(inSqueeze ? squeezeDuration : lastSqueezeDuration) + " bars", text_color=dotColor, bgcolor=bg)
    table.cell(dash, 0, 3, "TREND (" + (htfActive ? htf : "local") + ")", text_color=fg, bgcolor=bg)
    table.cell(dash, 1, 3, trendText, text_color=bullTrend ? bullBright : bearTrend ? bearBright : color.silver, bgcolor=bg)
    table.cell(dash, 0, 4, "MOMENTUM", text_color=fg, bgcolor=bg)
    table.cell(dash, 1, 4, momText, text_color=histColor, bgcolor=bg)
    table.cell(dash, 0, 5, "ADX / RVOL", text_color=fg, bgcolor=bg)
    table.cell(dash, 1, 5, str.tostring(adx, "#.0") + " / " + (hasVolume ? str.tostring(rvol, "#.00") : "N/A"), text_color=fg, bgcolor=bg)
    table.cell(dash, 0, 6, "LONG / SHORT", text_color=fg, bgcolor=bg)
    table.cell(dash, 1, 6, classicMode ? "NOT USED IN CLASSIC" : str.tostring(longScore) + " / " + str.tostring(shortScore), text_color=fg, bgcolor=bg)
    table.cell(dash, 0, 7, "STATUS", text_color=fg, bgcolor=bg)
    table.cell(dash, 1, 7, lifecycle, text_color=buy ? bullBright : sell ? bearBright : fg, bgcolor=bg)
    table.cell(dash, 0, 8, "TRADE MAP", text_color=fg, bgcolor=bg)
    table.cell(dash, 1, 8, not showTradeMap ? "OFF" : direction == 0 ? "FLAT" : (direction == 1 ? "LONG " : "SHORT ") + "S:" + str.tostring(stop, format.mintick) + " T:" + str.tostring(target, format.mintick), text_color=fg, bgcolor=bg, text_size=size.tiny)
    table.cell(dash, 0, 9, "ENGINE", text_color=fg, bgcolor=bg)
    table.cell(dash, 1, 9, engineMode, text_color=color.aqua, bgcolor=bg, text_size=size.tiny)
    table.cell(dash, 0, 10, "LAST EXIT", text_color=fg, bgcolor=bg)
    table.cell(dash, 1, 10, lastExitReason, text_color=color.yellow, bgcolor=bg, text_size=size.tiny)
if not showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 10)

// ───── Alert conditions: use Once Per Bar Close for confirmation ─────
alertcondition(buy, "CandleChasers BUY", "CandleChasers Squeeze Engine PRO BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sell, "CandleChasers SELL", "CandleChasers Squeeze Engine PRO SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(release and candleOK, "CandleChasers squeeze release", "CandleChasers Squeeze RELEASE on {{ticker}} {{interval}}")
alertcondition(earlyLongSignal, "CandleChasers early bullish setup", "CandleChasers EARLY BULL setup on {{ticker}} {{interval}}")
alertcondition(earlyShortSignal, "CandleChasers early bearish setup", "CandleChasers EARLY BEAR setup on {{ticker}} {{interval}}")
alertcondition(bullDiv and candleOK, "CandleChasers bullish divergence", "CandleChasers confirmed BULL divergence on {{ticker}} {{interval}}")
alertcondition(bearDiv and candleOK, "CandleChasers bearish divergence", "CandleChasers confirmed BEAR divergence on {{ticker}} {{interval}}")
alertcondition(exitLong or exitShort, "CandleChasers virtual exit", "CandleChasers virtual trade exit on {{ticker}} {{interval}}")

alertcondition(exitLong, "CandleChasers exit long", "CandleChasers EXIT LONG on {{ticker}} {{interval}}")
alertcondition(exitShort, "CandleChasers exit short", "CandleChasers EXIT SHORT on {{ticker}} {{interval}}")
````
