# Lemorei Buy Sell (w table)

- url: https://www.tradingview.com/script/cGg28sn4-Lemorei-Buy-Sell-w-table/
- type: indicator
- pine_id: PUB;07914d1ed756473e9cc2530ffd4550b4
- version: 1.0

## Description

[b]Lemorei Buy Sell — 1-Minute Heikin Ashi Scalping Assistant[/b]

[b]Lemorei Buy Sell[/b] is a discretionary intraday scalping indicator designed for the [b]1-minute Heikin Ashi chart[/b][i][/i], with a focus on momentum continuation, pullback entries, opening-drive setups, and controlled risk management.

The script combines multiple confirmation layers, including EMA alignment, VWAP position, MACD direction, RSI strength, ADX trend regime, relative volume, opening range behavior, and ATR-based risk levels. It is built to help traders visually identify higher-quality long-side momentum opportunities while avoiding late, extended, or low-quality entries.

Key features include:

[list]
[*] [b]BUY[/b] signals based on momentum, MACD confirmation, RSI strength, VWAP alignment, and trend conditions
[*] [b]BUY (OPEN)[/b] logic for early-session momentum during the opening window
[*] [b]BUY (BURST)[/b] logic for volume expansion and range breakout candles
[*] [b]BUY more reminders[/b] for potential scaling opportunities after an initial entry
[*] [b]Late entry warning[/b] when price may be extended, parabolic, or overheated
[*] [b]Dynamic stop-loss line[/b] using ATR and trailing EMA logic
[*] [b]Take-profit alerts[/b] when momentum turns down while the position is in profit
[*] [b]Risk-based position sizing[/b] using a configurable cost basis per entry
[*] [b]Clean dashboard table[/b] showing VWAP status, MACD, ADX, market state, regime, RSI, EMA alignment, and relative volume
[*] [b]Alert conditions[/b] for buy, burst buy, buy more, sell, stop loss, max loss, take profit, and late-entry warnings
[/list]


This indicator is tuned specifically for [b]1-minute charts[/b] and is intended to support fast decision-making during active market sessions. It is not a fully automated trading system and should be used together with personal judgment, chart context, liquidity, news awareness, and strict risk management.

[i]Important:[/i] This script is for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any security. Always test thoroughly, use proper risk controls, and make trading decisions at your own discretion.

## Source Code

````pine
// © lemorei — v1.0

//@version=6
indicator("Lemorei Buy Sell (w table)", overlay=true)

// =====================================================
// INPUTS
// =====================================================

// --- Core ---
emaFastLen = input.int(5,        "Fast EMA",               minval=1,   group="Core")
emaSlowLen = input.int(13,       "Slow EMA",               minval=1,   group="Core")
atrLen     = input.int(14,       "ATR Period",             minval=1,   group="Core")
atrMultSL  = input.float(0.5,    "SL Multiplier (ATR)",   minval=0.1, step=0.1, group="Core")
costBasis  = input.float(20000.0,"Cost Basis per BUY ($)", minval=100.0, step=100.0, group="Core")

// --- Scaling / Pullback ---
cooldownBars       = input.int(5,    "Cooldown between BUYs (bars)", minval=0, group="Scaling")
pullbackLookback   = input.int(12,   "Pullback lookback (bars)",     minval=2, group="Scaling")
requirePullbackDip = input.bool(true,"PB requires dip below EMA fast in lookback", group="Scaling")

// --- Late Entry Warning v2 ---
lateGroup         = "⚠️ Late Entry Warning v2"
showLateWarning   = input.bool(true, "Show LATE entry warnings", group=lateGroup)
lateMinConditions = input.int(2,     "Min conditions required to warn (1-4)", minval=1, maxval=4, group=lateGroup,
     tooltip="2 = balanced. 1 = many warnings. 3-4 = very rare.")
lateEmaDistPct    = input.float(1.2, "E: EMA fast distance % (stretch)",   minval=0.1, step=0.05, group=lateGroup)
lateRsiLevel      = input.float(78.0,"RD: RSI extreme level",              minval=60.0, step=1.0,  group=lateGroup)
lateParabolicATR  = input.float(3.0, "P: ATRs above slow EMA (parabolic)", minval=1.0,  step=0.25, group=lateGroup)
lateConsecBars    = input.int(4,     "C: Consecutive strong bars count",   minval=2, maxval=8,     group=lateGroup)
lateSuppressInOpen  = input.bool(true,"Suppress during opening window",         group=lateGroup)
lateSuppressAdxRise = input.bool(true,"Suppress when ADX is rising",            group=lateGroup)
lateSuppressPBEntry = input.bool(true,"Suppress on fresh EMA pullback reclaim", group=lateGroup)
lateSuppressHistUp  = input.bool(true,"Suppress when MACD hist rising",         group=lateGroup)

// --- Opening Window (1m) ---
openGroup             = "Opening Window (1m)"
rthSession            = input.session("0930-1600","RTH Session",                       group=openGroup)
openMinutes           = input.int(12,   "Opening window minutes after 9:30", minval=1, maxval=60, group=openGroup)
openRelaxRsiSlope     = input.bool(true, "Open: relax RSI-MA rising requirement",      group=openGroup)
openIgnoreRegimeADX   = input.bool(true, "Open: ignore ADX regime gate",               group=openGroup)
openIgnoreGreenCandle = input.bool(true, "Open: ignore green candle confirmation",      group=openGroup)
openEnableMomentumBuy = input.bool(true, "Open: enable OPEN MOMENTUM entry",           group=openGroup)
openNeedEmaAlign      = input.bool(true, "Open: require EMA fast > EMA slow",          group=openGroup)
openRequireHistRising = input.bool(true, "Open: require MACD hist rising",             group=openGroup)
openMinRelVol   = input.float(1.2, "Open: min RelVol (volume filter)", minval=0.5, step=0.1, group=openGroup,
     tooltip="OPEN entry requires relative volume >= this. 1.2 = 20% above average.")
openMaxGapPct   = input.float(2.5, "Open: max gap % (gap filter)",     minval=0.0, step=0.1, group=openGroup,
     tooltip="Suppress OPEN entry if overnight gap > this %.")
openGapFilterOn = input.bool(true, "Open: enable gap filter",          group=openGroup)

// --- Opening Range Break ---
orbGroup     = "Opening Range Break (Optional)"
useORB       = input.bool(true,   "Use ORB filter for OPEN entry",             group=orbGroup)
orbMinutes   = input.int(3,       "ORB minutes",              minval=1, maxval=15, group=orbGroup)
orbBreakType = input.string("High","ORB break type", options=["High","High+Close"], group=orbGroup)

// --- BURST Entry ---
burstGroup             = "BURST Entry (Range + Volume Breakout)"
enableBurstBuy         = input.bool(true,  "Enable BUY (BURST)",                               group=burstGroup)
burstVolLen            = input.int(20,     "Volume SMA length",          minval=5,              group=burstGroup)
burstVolMult           = input.float(2.0,  "RelVol multiplier",          minval=1.0, step=0.1,  group=burstGroup)
burstAtrMult           = input.float(1.1,  "Range multiplier (ATR * X)", minval=0.5, step=0.05, group=burstGroup)
burstBreakLookback     = input.int(20,     "Breakout lookback (bars)",   minval=5,              group=burstGroup)
burstNeedBreakout      = input.bool(true,  "Require breakout above prior high",                 group=burstGroup)
burstNeedCloseNearHigh = input.bool(true,  "Require close near high (quality candle)",          group=burstGroup)
burstCloseNearHighPct  = input.float(0.70, "Close-near-high %",          minval=0.5, maxval=0.95, step=0.05, group=burstGroup)
burstNeedEmaAlign      = input.bool(false, "Require EMA fast > EMA slow",                       group=burstGroup)
burstBypassRegimeGate  = input.bool(true,  "Allow BURST even if ADX regime says NO",            group=burstGroup)

// --- BUY More ---
enableBuyMore       = input.bool(true, "Enable 'BUY more' reminders",                    group="BUY more")
buyMoreMinBarsAfter = input.int(6,     "BUY more: min bars after last BUY", minval=1,     group="BUY more")
buyMoreCooldownBars = input.int(12,    "BUY more: cooldown between reminders", minval=1,  group="BUY more")
buyMoreNeedsHistFlip= input.bool(true, "BUY more: require MACD hist rising again",        group="BUY more")
buyMoreNeedsAdxUp   = input.bool(true, "BUY more: require ADX rising",                   group="BUY more")

// --- Candle Confirmation ---
confirmTrendCandle    = input.bool(true,  "Trend Mode: require green candle",                       group="Signals")
confirmIgnitionCandle = input.bool(false, "Ignition Mode: require green candle (recommended OFF)",  group="Signals")

// --- Risk / Exits ---
maxLossDollars     = input.float(-20.0,"MAX LOSS $ (exit when P/L <= this)",  step=1.0, group="Risk")
useMacdExit        = input.bool(true,  "Exit on MACD Death Cross",                      group="Risk")
macdExitOnlyProfit = input.bool(false, "MACD exit: only if in profit",                  group="Risk",
     tooltip="If ON, MACD death cross only exits when P/L > 0.")
tpOnTurnDown       = input.bool(true,  "TP only when chart turns down (profit only)",   group="Risk")
slTrigger          = input.string("Close","Stop Loss triggers on", options=["Close","Wick"], group="Risk")
useTrailingStop    = input.bool(true,  "Use Trailing Stop (follow EMA fast)",           group="Risk")
trailAtrMult       = input.float(0.5,  "Trailing SL: ATR offset below EMA", minval=0.1, step=0.05, group="Risk")

// --- Regime (ADX) ---
useRegimeSwitch  = input.bool(true,  "ADX Regime Switching ON",                    group="Regime")
adxMinToTrade    = input.float(25.0, "Trend Mode: Min ADX to allow BUYs",          group="Regime", step=0.5)
useIgnition      = input.bool(true,  "Ignition Mode ON (ADX rising below threshold)", group="Regime")
ignitionRiseBars = input.int(3,      "Ignition: ADX rising bars", minval=2, maxval=6,  group="Regime")
ignitionNeedsVWAP= input.bool(true,  "Ignition extra filter: price ABOVE VWAP",    group="Regime")

// --- RSI ---
rsiLen      = input.int(6,    "RSI Length",           group="RSI")
rsiMaType   = input.string("SMA","RSI-based MA Type", options=["SMA","EMA","RMA","WMA"], group="RSI")
rsiMaLen    = input.int(14,   "RSI-based MA Length",  minval=1, group="RSI")
useRsiCap   = input.bool(false,"Require RSI < max",   group="RSI")
rsiMaxEntry = input.float(60.0,"RSI max (if enabled)", step=0.5, group="RSI")

// --- ADX ---
adxSmoothing = input.int(14,    "ADX Smoothing",      minval=1, group="ADX")
diLen        = input.int(14,    "DI Length",          minval=1, group="ADX")
adxWeak      = input.float(20.0,"Weak/Choppy below",  minval=5, step=0.5, group="ADX")
adxTrend     = input.float(25.0,"Trending above",     minval=5, step=0.5, group="ADX")
adxStrong    = input.float(40.0,"Strong trend above", minval=5, step=0.5, group="ADX")

// --- MACD ---
macdFastLen   = input.int(12,"MACD Fast",   group="MACD")
macdSlowLen   = input.int(26,"MACD Slow",   group="MACD")
macdSignalLen = input.int(9, "MACD Signal", group="MACD")

macdCol0 = input.color(color.rgb(76, 175, 160),  "Color 0 (above 0, rising)",  group="MACD Colors")
macdCol1 = input.color(color.rgb(195, 230, 224), "Color 1 (above 0, falling)", group="MACD Colors")
macdCol2 = input.color(color.rgb(246, 208, 214), "Color 2 (below 0, rising)",  group="MACD Colors")
macdCol3 = input.color(color.rgb(239, 83, 80),   "Color 3 (below 0, falling)", group="MACD Colors")

// --- Visuals ---
showEmaFast  = input.bool(true,         "Show Fast EMA", group="Visuals")
emaFastColor = input.color(color.green, "Fast EMA Color",group="Visuals")
showEmaSlow  = input.bool(true,         "Show Slow EMA", group="Visuals")
emaSlowColor = input.color(color.orange,"Slow EMA Color",group="Visuals")

// --- TP Label ---
tpBigLabel   = input.bool(true,  "TP label: bigger size",           group="TP Label")
tpHalo       = input.bool(true,  "TP label: add outline/halo",      group="TP Label")
tpOffsetATR  = input.float(0.25, "TP label: vertical offset (ATR)", group="TP Label", step=0.05)
showTpTarget = input.bool(true,  "Show TP target line at entry",    group="TP Label",
     tooltip="Draws a dashed line at your R:R target price when you enter.")
tpRRatio     = input.float(2.0,  "TP target R:R ratio",             group="TP Label", minval=0.5, step=0.5)

// --- Debug ---
debugMarkers = input.bool(false,"Debug markers (why entry was blocked)", group="Debug")

// =====================================================
// 1-MIN CHART CHECK
// =====================================================
is1m = timeframe.isminutes and timeframe.multiplier == 1

// =====================================================
// HELPER FUNCTION
// =====================================================
fmtPnl(_p) =>
    sign = _p >= 0 ? "+$" : "-$"
    sign + str.tostring(math.abs(_p), "#.##")

// =====================================================
// CORE CALCULATIONS
// =====================================================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
atr     = ta.atr(atrLen)

// =====================================================
// RTH SESSION + OPENING WINDOW DETECTION
// NOTE: barsFromOpen counts bars, not wall-clock minutes.
// On 1-min charts these are equal. On higher timeframes
// openMinutes acts as a bar count — the script warns you
// via the "tuned for 1-min" label if not on a 1m chart.
// =====================================================
inRth     = not na(time("1", rthSession))
newRthBar = inRth and not inRth[1]

var int rthOpenBarIndex = na
if newRthBar
    rthOpenBarIndex := bar_index

barsFromOpen = (inRth and not na(rthOpenBarIndex)) ? (bar_index - rthOpenBarIndex) : na
inOpenWindow = inRth and not na(barsFromOpen) and (barsFromOpen <= openMinutes)

// =====================================================
// GAP DETECTION
// =====================================================
var float sessionGapPct = 0.0
if newRthBar and not na(close[1]) and close[1] > 0
    sessionGapPct := math.abs((open - close[1]) / close[1] * 100)

openGapOK = not openGapFilterOn or (sessionGapPct <= openMaxGapPct)

// =====================================================
// OPENING RANGE BREAK (ORB)
// =====================================================
var float orbHigh   = na
var float orbLow    = na
var bool  orbLocked = false

if newRthBar
    orbHigh   := high
    orbLow    := low
    orbLocked := false

if inRth and not orbLocked and not na(barsFromOpen)
    if barsFromOpen < orbMinutes
        orbHigh := math.max(orbHigh, high)
        orbLow  := math.min(orbLow,  low)
    else
        orbLocked := true

orbBreakOK = true
if useORB
    orbBreakOK := (orbBreakType == "High") ? (high > orbHigh) : (close > orbHigh)

// =====================================================
// VWAP
// =====================================================
vwap1m         = ta.vwap(hlc3)
priceAboveVWAP = close >= vwap1m
buyNotifyOK    = close > vwap1m

// =====================================================
// ADX + REGIME
// =====================================================
[diPlus, diMinus, adxVal] = ta.dmi(diLen, adxSmoothing)

adxIsRising = adxVal > adxVal[1]

string marketState =
     adxVal < adxWeak   ? "CHOPPY/SIDEWAYS" :
     adxVal < adxTrend  ? "WEAK TREND" :
     adxVal < adxStrong ? "TRENDING" :
     "STRONG TREND"

color adxBgColor =
     adxVal < adxWeak   ? color.rgb(243, 156, 18) :
     adxVal < adxTrend  ? color.rgb(241, 196, 15) :
     adxVal < adxStrong ? color.rgb(46, 204, 113) :
     color.rgb(39, 174, 96)

adxRisingN(n) =>
    bool ok = true
    for k = 0 to n - 2
        ok := ok and (adxVal[k] > adxVal[k + 1])
    ok

trendModeOK      = adxVal >= adxMinToTrade
ignitionModeOK   = useIgnition and (adxVal < adxMinToTrade) and adxRisingN(ignitionRiseBars) and (not ignitionNeedsVWAP or priceAboveVWAP)
tradeRegimeOK    = not useRegimeSwitch or trendModeOK or ignitionModeOK
tradeRegimeFinal = (inOpenWindow and openIgnoreRegimeADX) ? true : tradeRegimeOK

// =====================================================
// MACD
// =====================================================
[macdLine, signalLine, hist] = ta.macd(close, macdFastLen, macdSlowLen, macdSignalLen)

histRising = hist > hist[1]
aboveZero  = hist >= 0

macdDir   = macdLine > signalLine ? "UP" : "DOWN"
histState = histRising ? "rising" : "falling"

color macdBgColor = na
if aboveZero and histRising
    macdBgColor := macdCol0
else if aboveZero and not histRising
    macdBgColor := macdCol1
else if not aboveZero and histRising
    macdBgColor := macdCol2
else
    macdBgColor := macdCol3

macdText      = macdDir + " | " + histState
goldenCross   = ta.crossover(macdLine, signalLine)
deathCross    = ta.crossunder(macdLine, signalLine)
macdBullish   = macdLine > signalLine
macdImproving = (macdLine > macdLine[1]) and histRising

// =====================================================
// RSI + RSI-MA
// =====================================================
rsiVal = ta.rsi(close, rsiLen)

rsiMa = switch rsiMaType
    "SMA" => ta.sma(rsiVal, rsiMaLen)
    "EMA" => ta.ema(rsiVal, rsiMaLen)
    "RMA" => ta.rma(rsiVal, rsiMaLen)
    => ta.wma(rsiVal, rsiMaLen)

rsiUp    = rsiVal > rsiVal[1]
rsiMaUp  = rsiMa  > rsiMa[1]
rsiAbove = rsiVal > rsiMa
rsiCapOK = not useRsiCap or (rsiVal < rsiMaxEntry)

rsiFilterOK     = rsiUp and rsiMaUp and rsiAbove and rsiCapOK
rsiFilterOpenOK = rsiUp and rsiAbove and rsiCapOK
rsiFilterFinal  = (inOpenWindow and openRelaxRsiSlope) ? rsiFilterOpenOK : rsiFilterOK

// =====================================================
// LATE ENTRY WARNING v2
// =====================================================
lateTrendContext = (emaFast > emaSlow) and priceAboveVWAP

lateSuppressedByOpen = lateSuppressInOpen and inOpenWindow
adxRising2           = (adxVal > adxVal[1]) and (adxVal[1] > adxVal[2])
lateSuppressedByAdx  = lateSuppressAdxRise and adxRising2
lateSuppressedByPB   = lateSuppressPBEntry and ta.crossover(close, emaFast)
lateSuppressedByHist = lateSuppressHistUp and histRising
lateAnySuppressor    = lateSuppressedByOpen or lateSuppressedByAdx or lateSuppressedByPB or lateSuppressedByHist

emaDistPct       = not na(emaFast) and emaFast > 0 ? ((close - emaFast) / emaFast * 100) : 0.0
lateByEma        = emaDistPct >= lateEmaDistPct
lateByRsiDiverge = (rsiVal >= lateRsiLevel) and (rsiVal < rsiVal[1])
slowEmaDist      = not na(emaSlow) and atr > 0 ? ((close - emaSlow) / atr) : 0.0
lateByParab      = slowEmaDist >= lateParabolicATR

strongBar(offset) =>
    (close[offset] > open[offset]) and (close[offset] > high[offset + 1])

int lateConsecCount = 0
for i = 0 to lateConsecBars - 1
    if strongBar(i)
        lateConsecCount += 1
lateByConsec = lateConsecCount >= lateConsecBars

lateCondCount     = (lateByEma ? 1 : 0) + (lateByRsiDiverge ? 1 : 0) + (lateByParab ? 1 : 0) + (lateByConsec ? 1 : 0)
lateConditionsMet = lateCondCount >= lateMinConditions

// =====================================================
// BURST ENTRY sub-conditions
// =====================================================
volSma        = ta.sma(volume, burstVolLen)
relVol        = volSma > 0 ? (volume / volSma) : na
burstVolumeOK = enableBurstBuy and (not na(relVol)) and (relVol >= burstVolMult)

barRange      = high - low
burstRangeOK  = enableBurstBuy and (barRange >= atr * burstAtrMult)

priorHigh     = ta.highest(high, burstBreakLookback)[1]
breakoutOK    = not burstNeedBreakout or (close > priorHigh)

closeNearHigh  = barRange > 0 ? ((close - low) / barRange) : 0.0
burstQualityOK = not burstNeedCloseNearHigh or (closeNearHigh >= burstCloseNearHighPct)

emaAlignBurstOK = (not burstNeedEmaAlign) or (emaFast > emaSlow)

// =====================================================
// CANDLE CONFIRMATION
// =====================================================
bullCandle    = close > open
needGreenBase = trendModeOK ? confirmTrendCandle : ignitionModeOK ? confirmIgnitionCandle : confirmTrendCandle
needGreen     = (inOpenWindow and openIgnoreGreenCandle) ? false : needGreenBase

// =====================================================
// ENTRY SIGNALS
// =====================================================
buyGC_raw = goldenCross and rsiFilterFinal

dipBelowEmaFast = ta.lowest(close - emaFast, pullbackLookback) < 0
reclaimEmaFast  = ta.crossover(close, emaFast)
buyPB_raw = macdBullish and rsiFilterFinal and reclaimEmaFast and (not requirePullbackDip or dipBelowEmaFast)

emaAlignOK = (not openNeedEmaAlign) or (emaFast > emaSlow)
histOkOpen = (not openRequireHistRising) or histRising
openVolOK  = not na(relVol) and relVol >= openMinRelVol

buyOPEN_raw =
     openEnableMomentumBuy and
     inOpenWindow          and
     priceAboveVWAP        and
     orbBreakOK            and
     (close > emaFast)     and
     emaAlignOK            and
     macdBullish           and
     histOkOpen            and
     rsiFilterFinal        and
     openVolOK             and
     openGapOK

buyBURST_raw =
     enableBurstBuy  and
     priceAboveVWAP  and
     burstVolumeOK   and
     burstRangeOK    and
     breakoutOK      and
     burstQualityOK  and
     emaAlignBurstOK and
     rsiUp and rsiAbove and rsiCapOK and
     macdImproving

// =====================================================
// REGIME GATE
// =====================================================
buyBaseOK = tradeRegimeFinal and priceAboveVWAP

buyGC    = buyGC_raw    and buyBaseOK
buyPB    = buyPB_raw    and buyBaseOK
buyOPEN  = buyOPEN_raw  and buyBaseOK
buyBURST = buyBURST_raw and (burstBypassRegimeGate ? true : tradeRegimeFinal)

buyGC_sig    = needGreen ? (buyGC    and bullCandle) : buyGC
buyPB_sig    = needGreen ? (buyPB    and bullCandle) : buyPB
buyOPEN_sig  = needGreen ? (buyOPEN  and bullCandle) : buyOPEN
buyBURST_sig = needGreen ? (buyBURST and bullCandle) : buyBURST

// =====================================================
// COOLDOWN
// =====================================================
var int lastBuyBar = na
cooldownOK = na(lastBuyBar) ? true : (bar_index - lastBuyBar >= cooldownBars)

// =====================================================
// SIGNAL PRIORITY
// =====================================================
buySignal = cooldownOK and (buyBURST_sig or buyOPEN_sig or buyGC_sig or buyPB_sig)

buyTag =
     buyBURST_sig ? "BUY (BURST)" :
     buyOPEN_sig  ? "BUY (OPEN)"  :
     buyGC_sig    ? (ignitionModeOK ? "BUY (IGN)"    : "BUY") :
     buyPB_sig    ? (ignitionModeOK ? "BUY (PB+IGN)" : "BUY (PB)") :
     "BUY"

// =====================================================
// TP TURN-DOWN TRIGGER
// =====================================================
emaFastDown = emaFast < emaFast[1]
turnDown    = emaFastDown and close < emaFast

// =====================================================
// POSITION STATE VARIABLES
// =====================================================
var bool   inPosition     = false
var float  avgEntry       = na
var float  stopLoss       = na
var int    shares         = 0
var int    buyCount       = 0
var string lastSignalType = "-"

var float  lastExitPnl    = na
var string lastExitReason = ""
var bool   tpPrinted      = false
var bool   lossPrinted    = false

var float lastBuyPrice  = na
var int   lastBuyIdx    = na
var int   lastBuyShares = na
var float lastTpPrice   = na
var int   lastTpIdx     = na

// =====================================================
// LATE ENTRY WARNING — FINAL GATE
// =====================================================
lateEntryWarning = showLateWarning
     and lateTrendContext
     and not lateAnySuppressor
     and lateConditionsMet
     and not inPosition

// Per-bar event booleans
showBuySignal     = false
showBuyMoreSignal = false
showSellSignal    = false
tpHit             = false
slHit             = false
maxLossHit        = false
isScaleEntry      = false

// =====================================================
// ENTRY EXECUTION
// =====================================================
if buySignal
    addShF    = math.floor(costBasis / close)
    addShares = addShF < 1 ? 1 : int(addShF)
    newStop   = low - atr * atrMultSL

    if not inPosition
        avgEntry     := close
        shares       := addShares
        stopLoss     := newStop
        inPosition   := true
        tpPrinted    := false
        lossPrinted  := false
        buyCount     := 1
        isScaleEntry := false
    else
        newTotal     = shares + addShares
        avgEntry    := (avgEntry * shares + close * addShares) / newTotal
        shares      := newTotal
        stopLoss    := math.max(stopLoss, newStop)
        buyCount    := buyCount + 1
        isScaleEntry := true

    lastBuyBar     := bar_index
    showBuySignal  := true
    lastBuyPrice   := close
    lastBuyIdx     := bar_index
    lastBuyShares  := addShares
    lastSignalType := buyTag

// =====================================================
// BUY MORE REMINDER
// =====================================================
var int lastBuyMoreBar = na

suggestShF    = math.floor(costBasis / close)
suggestShares = suggestShF < 1 ? 1 : int(suggestShF)

histGood = aboveZero and histRising
adxUpNow = adxVal > adxVal[1]

buyMoreBaseOK =
     enableBuyMore    and
     inPosition       and
     buyBaseOK        and
     (close > emaFast) and
     macdBullish      and
     rsiFilterFinal   and
     (not buyMoreNeedsHistFlip or histGood) and
     (not buyMoreNeedsAdxUp   or adxUpNow)

enoughAfterLastBuy = na(lastBuyBar) ? false : (bar_index - lastBuyBar >= buyMoreMinBarsAfter)
buyMoreCooldownOK  = na(lastBuyMoreBar) ? true : (bar_index - lastBuyMoreBar >= buyMoreCooldownBars)

buyMoreSignal = buyMoreBaseOK and enoughAfterLastBuy and buyMoreCooldownOK and not buySignal

if buyMoreSignal
    showBuyMoreSignal := true
    lastBuyMoreBar    := bar_index

// =====================================================
// CURRENT P/L
// =====================================================
pnl = inPosition and shares > 0 and not na(avgEntry) ? (close - avgEntry) * shares : na

// =====================================================
// TRAILING STOP
// =====================================================
if inPosition and useTrailingStop and not na(emaFast)
    trailedStop = emaFast - atr * trailAtrMult
    stopLoss   := math.max(stopLoss, trailedStop)

// =====================================================
// EXIT LOGIC
// =====================================================
if inPosition
    slCondition = slTrigger == "Wick" ? (low <= stopLoss) : (close <= stopLoss)
    if slCondition
        slHit          := true
        lastExitPnl    := pnl
        lastExitReason := "SL"
        inPosition     := false
        avgEntry       := na
        stopLoss       := na
        shares         := 0
        buyCount       := 0
        showSellSignal := true
        lastBuyBar     := na

    if not slHit and not na(pnl) and pnl <= maxLossDollars and not lossPrinted
        maxLossHit     := true
        lossPrinted    := true
        tpPrinted      := true
        lastExitPnl    := pnl
        lastExitReason := fmtPnl(pnl)
        inPosition     := false
        avgEntry       := na
        stopLoss       := na
        shares         := 0
        buyCount       := 0
        showSellSignal := true
        lastBuyBar     := na

    if not slHit and not maxLossHit and tpOnTurnDown and not tpPrinted and not na(pnl) and pnl > 0 and turnDown
        tpHit          := true
        tpPrinted      := true
        lastExitPnl    := pnl
        lastExitReason := "TP (TurnDown)"
        lastTpPrice    := close
        lastTpIdx      := bar_index
        inPosition     := false
        avgEntry       := na
        stopLoss       := na
        shares         := 0
        buyCount       := 0
        showSellSignal := true
        lastBuyBar     := na

    if not slHit and not maxLossHit and not tpHit and useMacdExit and deathCross
        macdExitAllowed = not macdExitOnlyProfit or (not na(pnl) and pnl > 0)
        if macdExitAllowed
            lastExitPnl    := pnl
            lastExitReason := "SELL"
            inPosition     := false
            avgEntry       := na
            stopLoss       := na
            shares         := 0
            buyCount       := 0
            showSellSignal := true
            lastBuyBar     := na

// =====================================================
// VISUALS: EMAs
// =====================================================
plot(emaFast, "Fast EMA", color=color.new(emaFastColor, 0), linewidth=1, display=showEmaFast ? display.all : display.none)
plot(emaSlow, "Slow EMA", color=color.new(emaSlowColor, 0), linewidth=1, display=showEmaSlow ? display.all : display.none)

// =====================================================
// COLOR PALETTE
// =====================================================
appleGreen  = color.rgb(141, 182, 0)
tpPink      = color.rgb(255, 105, 180)
lossOrange  = color.rgb(255, 149, 0)
openCyan    = color.rgb(0, 180, 255)
burstPurple = color.rgb(155, 89, 182)
lateYellow  = color.rgb(255, 200, 0)

tpSize = tpBigLabel ? size.normal : size.small

// =====================================================
// 1-MIN WARNING LABEL
// =====================================================
var bool warned = false
if barstate.islast and not is1m and not warned
    label.new(bar_index, high, "⚠️ Script is tuned for 1-minute charts",
         style=label.style_label_down, color=color.new(color.orange, 0),
         textcolor=color.black, size=size.small)
    warned := true

// =====================================================
// LATE ENTRY WARNING LABEL
// =====================================================
if lateEntryWarning
    reasonParts = ""
    if lateByEma
        reasonParts := "E"
    if lateByRsiDiverge
        reasonParts := reasonParts + (str.length(reasonParts) > 0 ? "+" : "") + "RD"
    if lateByParab
        reasonParts := reasonParts + (str.length(reasonParts) > 0 ? "+" : "") + "P"
    if lateByConsec
        reasonParts := reasonParts + (str.length(reasonParts) > 0 ? "+" : "") + "C"
    if lateCondCount >= 4
        reasonParts := "ALL"

    lateLabelTxt = "⚠️LATE " + reasonParts
    label.new(bar_index, high, lateLabelTxt,
         style=label.style_label_down, color=color.new(lateYellow, 10),
         textcolor=color.black, size=size.small, yloc=yloc.abovebar)

// =====================================================
// BUY LABEL
// =====================================================
if showBuySignal
    buyBg =
         buyTag == "BUY (OPEN)"  ? openCyan    :
         buyTag == "BUY (BURST)" ? burstPurple :
         buyTag == "BUY"         ? appleGreen  :
         color.lime

    string labelTxt = ""
    if isScaleEntry
        labelTxt := "ADD #" + str.tostring(buyCount) + "  " + str.tostring(lastBuyShares) + "sh"
    else
        labelTxt := buyTag + "  " + str.tostring(lastBuyShares) + "sh"

    label.new(bar_index, low, labelTxt,
         style=label.style_label_up, color=buyBg,
         textcolor=color.white, size=tpSize, yloc=yloc.belowbar)

// =====================================================
// BUY MORE LABEL
// =====================================================
if showBuyMoreSignal
    avgEntryStr = not na(avgEntry) ? " | avg $" + str.tostring(avgEntry, "#.##") : ""
    pnlStr      = not na(pnl)      ? " | P/L: " + fmtPnl(pnl) : ""
    buyMoreTxt  = "BUY more " + str.tostring(suggestShares) + "sh" + avgEntryStr + pnlStr
    label.new(bar_index, low, buyMoreTxt,
         style=label.style_label_up, color=appleGreen,
         textcolor=color.white, size=tpSize, yloc=yloc.belowbar)

// =====================================================
// SELL LABELS
// =====================================================
if showSellSignal
    if lastExitReason == "TP (TurnDown)" and not na(lastExitPnl)
        yTp = high + atr * tpOffsetATR
        txt = "TP $" + str.tostring(lastExitPnl, "#.##")
        if tpHalo
            label.new(bar_index, yTp, txt,
                 style=label.style_label_down, color=color.black,
                 textcolor=color.white, size=tpSize, yloc=yloc.price)
        label.new(bar_index, yTp, txt,
             style=label.style_label_down, color=tpPink,
             textcolor=color.white, size=tpSize, yloc=yloc.price)
    else
        isLossValue = str.substring(lastExitReason, 0, 1) == "-"
        sellBgColor = isLossValue ? lossOrange : color.red
        label.new(bar_index, high, lastExitReason,
             style=label.style_label_down, color=sellBgColor,
             textcolor=color.white, size=tpSize, yloc=yloc.abovebar)

// =====================================================
// STOP LOSS LINE + LABEL
// =====================================================
var line  slLine  = na
var label slLabel = na

if inPosition and not na(stopLoss)
    slDistPct  = not na(avgEntry) and avgEntry > 0 ? ((stopLoss - avgEntry) / avgEntry * 100) : 0.0
    slLabelTxt = "SL $" + str.tostring(stopLoss, "#.##") + " (" + str.tostring(slDistPct, "#.##") + "%)"
    if na(slLine)
        slLine  := line.new(bar_index, stopLoss, bar_index + 3, stopLoss,
             color=color.new(color.red, 0), width=2)
        slLabel := label.new(bar_index + 3, stopLoss, slLabelTxt,
             style=label.style_label_left, color=color.new(color.red, 70),
             textcolor=color.white, size=size.tiny)
    else
        line.set_xy1(slLine,  bar_index,     stopLoss)
        line.set_xy2(slLine,  bar_index + 3, stopLoss)
        label.set_xy(slLabel, bar_index + 3, stopLoss)
        label.set_text(slLabel, slLabelTxt)
else
    if not na(slLine)
        line.delete(slLine)
        slLine := na
    if not na(slLabel)
        label.delete(slLabel)
        slLabel := na

// =====================================================
// TP TARGET LINE
// =====================================================
var line  tpTargetLine  = na
var label tpTargetLabel = na

if inPosition and not na(avgEntry) and not na(stopLoss) and showTpTarget
    riskPerShare  = avgEntry - stopLoss
    tpTargetPrice = avgEntry + riskPerShare * tpRRatio
    tpTargetTxt   = "Target $" + str.tostring(tpTargetPrice, "#.##") + "  (" + str.tostring(tpRRatio, "#.#") + "R)"
    if na(tpTargetLine)
        tpTargetLine  := line.new(bar_index, tpTargetPrice, bar_index + 3, tpTargetPrice,
             color=color.new(tpPink, 20), width=1, style=line.style_dashed)
        tpTargetLabel := label.new(bar_index + 3, tpTargetPrice, tpTargetTxt,
             style=label.style_label_left, color=color.new(tpPink, 60),
             textcolor=color.white, size=size.tiny)
    else
        line.set_xy1(tpTargetLine,  bar_index,     tpTargetPrice)
        line.set_xy2(tpTargetLine,  bar_index + 3, tpTargetPrice)
        label.set_xy(tpTargetLabel, bar_index + 3, tpTargetPrice)
        label.set_text(tpTargetLabel, tpTargetTxt)
else
    if not na(tpTargetLine)
        line.delete(tpTargetLine)
        tpTargetLine := na
    if not na(tpTargetLabel)
        label.delete(tpTargetLabel)
        tpTargetLabel := na

// =====================================================
// DEBUG MARKERS
// =====================================================
blockedByRegime = debugMarkers and (buyGC_raw or buyPB_raw or buyOPEN_raw) and not buyBaseOK
blockedByRSI    = debugMarkers and (goldenCross or reclaimEmaFast or buyOPEN_raw or buyBURST_raw) and not rsiFilterFinal
blockedByCandle = debugMarkers and (buyGC or buyPB or buyOPEN or buyBURST) and needGreen and not bullCandle
blockedByCD     = debugMarkers and (buyOPEN_sig or buyGC_sig or buyPB_sig or buyBURST_sig) and not cooldownOK
blockedByORB    = debugMarkers and buyOPEN_raw and useORB and not orbBreakOK

burstBlockedByVol   = debugMarkers and enableBurstBuy and burstRangeOK  and priceAboveVWAP and breakoutOK and burstQualityOK and emaAlignBurstOK and rsiUp and rsiAbove and rsiCapOK and macdImproving and not burstVolumeOK
burstBlockedByRange = debugMarkers and enableBurstBuy and burstVolumeOK and priceAboveVWAP and breakoutOK and burstQualityOK and emaAlignBurstOK and rsiUp and rsiAbove and rsiCapOK and macdImproving and not burstRangeOK
burstBlockedByBreak = debugMarkers and enableBurstBuy and burstVolumeOK and burstRangeOK   and priceAboveVWAP and burstQualityOK and emaAlignBurstOK and rsiUp and rsiAbove and rsiCapOK and macdImproving and not breakoutOK

plotshape(blockedByRegime,    title="Missed: Regime/VWAP", style=shape.triangleup, location=location.belowbar, size=size.tiny, color=color.gray,  text="REG")
plotshape(blockedByRSI,       title="Missed: RSI",         style=shape.triangleup, location=location.belowbar, size=size.tiny, color=color.gray,  text="RSI")
plotshape(blockedByCandle,    title="Missed: Candle",      style=shape.triangleup, location=location.belowbar, size=size.tiny, color=color.gray,  text="CNDL")
plotshape(blockedByCD,        title="Missed: Cooldown",    style=shape.triangleup, location=location.belowbar, size=size.tiny, color=color.gray,  text="CD")
plotshape(blockedByORB,       title="Missed: ORB",         style=shape.triangleup, location=location.belowbar, size=size.tiny, color=color.gray,  text="ORB")
plotshape(burstBlockedByVol,  title="BURST: Volume low",   style=shape.circle,     location=location.belowbar, size=size.tiny, color=burstPurple, text="VOL")
plotshape(burstBlockedByRange,title="BURST: Range small",  style=shape.circle,     location=location.belowbar, size=size.tiny, color=burstPurple, text="RNG")
plotshape(burstBlockedByBreak,title="BURST: No breakout",  style=shape.circle,     location=location.belowbar, size=size.tiny, color=burstPurple, text="BRK")

// =====================================================
// INFO TABLE — 8 rows, clean and focused
// Row 0: VWAP
// Row 1: MACD
// Row 2: ADX (with ↑/↓)
// Row 3: Market State
// Row 4: Regime
// Row 5: RSI
// Row 6: EMA alignment
// Row 7: Volume
// =====================================================
var table infoTable = table.new(position.top_right, 2, 8,
     bgcolor=color.new(color.black, 0), border_width=1, border_color=color.white)

if barstate.islast

    // Row 0: VWAP
    vwapBgColor = priceAboveVWAP ? color.new(color.green, 0) : color.new(color.red, 0)
    vwapText    = priceAboveVWAP ? "ABOVE VWAP" : "BELOW VWAP"
    table.cell(infoTable, 0, 0, "VWAP:",  text_color=color.white, bgcolor=color.black)
    table.cell(infoTable, 1, 0, vwapText, text_color=color.white, bgcolor=vwapBgColor)

    // Row 1: MACD
    table.cell(infoTable, 0, 1, "MACD:",  text_color=color.white, bgcolor=color.black)
    table.cell(infoTable, 1, 1, macdText, text_color=color.white, bgcolor=macdBgColor)

    // Row 2: ADX with direction arrow
    adxArrow   = adxIsRising ? " ↑" : " ↓"
    adxDisplay = str.tostring(adxVal, "#.##") + adxArrow
    table.cell(infoTable, 0, 2, "ADX:",     text_color=color.white, bgcolor=color.black)
    table.cell(infoTable, 1, 2, adxDisplay, text_color=color.black, bgcolor=adxBgColor)

    // Row 3: Market State
    table.cell(infoTable, 0, 3, "State:",    text_color=color.white, bgcolor=color.black)
    table.cell(infoTable, 1, 3, marketState, text_color=color.black, bgcolor=adxBgColor)

    // Row 4: Regime
    string regimeStr = trendModeOK ? "TREND" : ignitionModeOK ? "IGNITION" : "NO"
    color  regimeBg  = trendModeOK ? color.new(color.green,0) : ignitionModeOK ? color.new(color.orange,0) : color.new(color.red,0)
    if inOpenWindow
        regimeStr := "OPEN"
        regimeBg  := color.new(openCyan, 0)
    table.cell(infoTable, 0, 4, "Regime:", text_color=color.white, bgcolor=color.black)
    table.cell(infoTable, 1, 4, regimeStr, text_color=color.white, bgcolor=regimeBg)

    // Row 5: RSI
    rsiDisplay = str.tostring(rsiVal, "#.##") + " / MA:" + str.tostring(rsiMa, "#.##")
    rsiBgColor = rsiAbove ? color.new(color.green, 30) : color.new(color.red, 30)
    table.cell(infoTable, 0, 5, "RSI:",     text_color=color.white, bgcolor=color.black)
    table.cell(infoTable, 1, 5, rsiDisplay, text_color=color.white, bgcolor=rsiBgColor)

    // Row 6: EMA alignment
    emaAligned  = emaFast > emaSlow
    emaAlignStr = emaAligned ? "ALIGNED ✅" : "CROSSED ❌"
    emaAlignBg  = emaAligned ? color.new(color.green, 30) : color.new(color.red, 30)
    table.cell(infoTable, 0, 6, "EMA:",      text_color=color.white, bgcolor=color.black)
    table.cell(infoTable, 1, 6, emaAlignStr, text_color=color.white, bgcolor=emaAlignBg)

    // Row 7: Volume
    relVolTxt = not na(relVol) ? str.tostring(relVol, "#.##") + "x" : "-"
    volTxt    = str.tostring(volume, format.volume) + " | " + relVolTxt
    volBg     = (not na(relVol) and relVol >= burstVolMult) ? color.new(burstPurple, 0) : color.new(color.black, 0)
    table.cell(infoTable, 0, 7, "Vol:",  text_color=color.white, bgcolor=color.black)
    table.cell(infoTable, 1, 7, volTxt, text_color=color.white, bgcolor=volBg)

// =====================================================
// ALERTS
// =====================================================
alertcondition(
     showBuySignal and buyNotifyOK,
     "🟢 BUY Signal",
     "BUY | {{ticker}} @ {{close}}")

alertcondition(
     showBuySignal and buyBURST_sig and buyNotifyOK,
     "⚡ BUY (BURST) Signal",
     "BUY (BURST) | {{ticker}} @ {{close}} | Volume spike + range expansion")

alertcondition(
     showBuyMoreSignal and buyNotifyOK,
     "➕ BUY MORE Reminder",
     "BUY MORE | {{ticker}} @ {{close}} — add to existing position")

alertcondition(showSellSignal, "🔴 SELL Signal",     "SELL/EXIT | {{ticker}} @ {{close}}")
alertcondition(maxLossHit,     "🛑 Max Loss Hit",    "EXIT: Max loss | {{ticker}} @ {{close}}")
alertcondition(tpHit,          "🎯 TP on Turn Down", "TP: Turn-down in profit | {{ticker}} @ {{close}}")
alertcondition(slHit,          "❌ Stop Loss",        "SL triggered | {{ticker}} @ {{close}}")

alertcondition(
     lateEntryWarning,
     "⚠️ LATE Entry Warning",
     "LATE ENTRY WARNING | {{ticker}} @ {{close}} — trend up but price extended")
````
