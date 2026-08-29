<!-- tradingview-pine-id: PUB;b78b851c8e024910a68e2e9065d685bd -->
<!-- tradingviewscripts-format: 1 -->
# NQ ICT Matrix 15S Revised Score Dynamic TP SL30

Source: https://www.tradingview.com/script/bjvYIxwO/

## Description

NQ ICT Matrix (Beta)

An integrated trading indicator designed for Nasdaq (NQ) Futures 1–5 minute scalping, combining multiple ICT and price action concepts into a single scoring system.

Features

100-point weighted scoring model
Liquidity Sweeps (BSL/SSL)
BOS / CHoCH
Fair Value Gap (FVG)
Order Block (OB)
Premium / Discount Zones
Higher Timeframe Bias
Trendline Breaks
Volume & Momentum Confirmation
B-grade or higher signal arrows
TP / SL tracking and trade statistics

This indicator is currently in public beta and is intended for testing and educational purposes. The scoring model, filters, and trade logic will continue to evolve based on live market validation and user feedback.

Best suited for: Nasdaq (NQ) Futures • 1m–5m Timeframes

---

## Source Code

````pine
//@version=6
indicator(
     "NQ ICT Matrix 15S Revised Score Dynamic TP SL30",
     shorttitle = "NQICT 15S RS",
     overlay = true,
     format = format.price,
     precision = 2,
     max_bars_back = 5000,
     max_labels_count = 500,
     max_lines_count = 500,
     max_boxes_count = 200
)

// ============================================================================
// 1. INPUTS (승률 중심의 고품질 세팅)
// ============================================================================
groupGeneral = "1. General"
signalSymbol = input.symbol("CME_MINI:NQ1!", "Signal Symbol", group = groupGeneral, tooltip = "예: CME_MINI:NQU2026, CME_MINI:MNQU2026")
useChartSymbol = input.bool(false, "Use Current Chart Symbol", group = groupGeneral, tooltip = "켜면 현재 차트 종목을 사용하고, 끄면 Signal Symbol을 사용합니다.")
selectedSymbol = useChartSymbol ? syminfo.tickerid : signalSymbol

// 선택한 심볼의 현재 차트 주기 OHLCV
srcOpen   = request.security(selectedSymbol, timeframe.period, open,   gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
srcHigh   = request.security(selectedSymbol, timeframe.period, high,   gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
srcLow    = request.security(selectedSymbol, timeframe.period, low,    gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
srcClose  = request.security(selectedSymbol, timeframe.period, close,  gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
srcVolume = request.security(selectedSymbol, timeframe.period, volume, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
srcMintick = request.security(selectedSymbol, timeframe.period, syminfo.mintick, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// 전용 설정: 15초 차트에서만 신호를 생성합니다.
// 수정 점수: A+ 15점 이상 / A 13점 이상 / B 11점 이상 / C 11점 미만
// 실제 신호 최소점수는 10.5점이므로 C 신호는 기본 설정상 10.5점입니다.
// 동적 손익 설정: Score에 따라 TP +5 / +8 / +12 points, SL -30 points
signalTimeframeOnly = input.bool(true, "Signals only on 15-second chart", group = groupGeneral)
minimumScore        = input.float(10.5, "Minimum signal score", minval = 8, maxval = 20, step = 0.5, group = groupGeneral)
minimumDifference   = input.float(1.0, "Minimum Long/Short score difference", minval = 0, maxval = 10, step = 0.5, group = groupGeneral)
cooldownBars        = input.int(12, "Cooldown bars after exit", minval = 0, maxval = 100, group = groupGeneral)
useMandatoryFilters = input.bool(false, "Use strict mandatory ICT filters", group = groupGeneral)

groupRisk = "2. Trade Management"
useDynamicTP = input.bool(true, "Use Dynamic TP by Signal Score", group = groupRisk)
tpLowPoints  = input.float(5.0, "C/B Grade TP Points", minval = 0.25, step = 0.25, group = groupRisk)
tpMidPoints  = input.float(8.0, "A Grade TP Points", minval = 0.25, step = 0.25, group = groupRisk)
tpHighPoints = input.float(12.0, "A+ Grade TP Points", minval = 0.25, step = 0.25, group = groupRisk)
stopLossPoints   = input.float(30.0, "Stop Loss Points", minval = 0.25, step = 0.25, group = groupRisk)

groupStructure = "3. Structure"
pivotLength     = input.int(5, "Swing pivot length", minval = 2, maxval = 20, group = groupStructure)
htfLookback     = input.int(12, "5M structure lookback", minval = 5, maxval = 50, group = groupStructure)
rangeLength     = input.int(100, "Premium/Discount range", minval = 20, maxval = 500, group = groupStructure)

groupZones = "4. FVG / OB / S&R"
obSearchBars  = input.int(10, "Order Block search bars", minval = 2, maxval = 30, group = groupZones)
srAtrMult     = input.float(0.25, "S/R reaction width (ATR)", minval = 0.05, maxval = 2, step = 0.05, group = groupZones)
fvgMaxAge     = input.int(50, "Maximum FVG age", minval = 5, maxval = 500, group = groupZones)
obMaxAge      = input.int(100, "Maximum OB age", minval = 5, maxval = 500, group = groupZones)

groupTrend = "5. Trend / Momentum"
emaFastLength   = input.int(9, "Fast EMA", minval = 2, group = groupTrend)
emaSlowLength   = input.int(21, "Slow EMA", minval = 3, group = groupTrend)
trendlineLength = input.int(20, "Trendline proxy length", minval = 5, maxval = 100, group = groupTrend)
rsiLength       = input.int(14, "RSI length", minval = 2, group = groupTrend)
rsiBullLevel    = input.float(52, "Bullish RSI threshold", minval = 40, maxval = 70, group = groupTrend)
rsiBearLevel    = input.float(48, "Bearish RSI threshold", minval = 30, maxval = 60, group = groupTrend)
displacementAtr = input.float(0.8, "Displacement body / ATR", minval = 0.2, maxval = 3, step = 0.1, group = groupTrend)

groupVolume = "6. Volume"
deltaSmooth = input.int(5, "Signed-volume smoothing", minval = 1, maxval = 50, group = groupVolume)
vpLookback  = input.int(100, "Volume node lookback", minval = 20, maxval = 500, group = groupVolume)
vpTolerance = input.float(0.35, "Volume node tolerance (ATR)", minval = 0.05, maxval = 2, step = 0.05, group = groupVolume)

groupSession = "7. Session / ORB"
asiaSession   = input.session("0900-1600", "Asia Session (Seoul)", group = groupSession)
londonSession = input.session("0800-1630", "London Session", group = groupSession)
orbSession    = input.session("0930-0945", "Opening Range (New York)", group = groupSession)
rthSession    = input.session("0930-1600", "RTH Session (New York)", group = groupSession)
showORB       = input.bool(true, "Show ORB High/Low", group = groupSession)

groupDisplay = "8. Display"
showStructure = input.bool(true, "Show BOS / CHOCH / Sweeps", group = groupDisplay)
showZones     = input.bool(true, "Show latest FVG / OB", group = groupDisplay)
showTradeLines= input.bool(true, "Show Entry / TP / SL", group = groupDisplay)
showDashboard = input.bool(true, "Show score dashboard", group = groupDisplay)
showEMAs      = input.bool(false, "Show EMA 9 / 21", group = groupDisplay)

// ─────────────────────────────────────────────────────────────────────────────
// 2. 15-SECOND TIMEFRAME FILTER
// ─────────────────────────────────────────────────────────────────────────────
validChartTimeframe = timeframe.isseconds and timeframe.multiplier == 15
timeframeValid = not signalTimeframeOnly or validChartTimeframe

// 한국 사용시간을 고려한 균형형 세션 가중치
inAsiaSession   = not na(time(timeframe.period, asiaSession, "Asia/Seoul"))
inLondonSession = not na(time(timeframe.period, londonSession, "Europe/London"))
inNewYorkSession = not na(time(timeframe.period, rthSession, "America/New_York"))
inLondonNewYorkOverlap = inLondonSession and inNewYorkSession

float sessionScore = inLondonNewYorkOverlap ? 2.0 :
     inLondonSession ? 1.5 :
     inNewYorkSession ? 1.5 :
     inAsiaSession ? 1.0 : 0.5

string currentSession = inLondonNewYorkOverlap ? "LON+NY" :
     inLondonSession ? "LONDON" :
     inNewYorkSession ? "NEW YORK" :
     inAsiaSession ? "ASIA" : "OTHER"

// ─────────────────────────────────────────────────────────────────────────────
// 3. BASIC CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────
atr = ta.atr(14)
emaFast = ta.ema(srcClose, emaFastLength)
emaSlow = ta.ema(srcClose, emaSlowLength)
rsiValue = ta.rsi(srcClose, rsiLength)
[plusDI, minusDI, adxValue] = ta.dmi(14, 14)

barRange = math.max(srcHigh - srcLow, srcMintick)
bodySize = math.abs(srcClose - srcOpen)
bullDisplacement = srcClose > srcOpen and bodySize >= atr * displacementAtr and bodySize / barRange >= 0.60
bearDisplacement = srcClose < srcOpen and bodySize >= atr * displacementAtr and bodySize / barRange >= 0.60

bullTrend = emaFast > emaSlow and emaFast > emaFast[1] and plusDI >= minusDI
bearTrend = emaFast < emaSlow and emaFast < emaFast[1] and minusDI >= plusDI

// ─────────────────────────────────────────────────────────────────────────────
// 4. CONFIRMED 5-MINUTE BIAS
// ─────────────────────────────────────────────────────────────────────────────
close5 = request.security(selectedSymbol, "5", srcClose[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
emaFast5 = request.security(selectedSymbol, "5", ta.ema(srcClose, emaFastLength)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
emaSlow5 = request.security(selectedSymbol, "5", ta.ema(srcClose, emaSlowLength)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
previousHigh5 = request.security(selectedSymbol, "5", ta.highest(srcHigh, htfLookback)[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
previousLow5 = request.security(selectedSymbol, "5", ta.lowest(srcLow, htfLookback)[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

htfBullBias = close5 > emaSlow5 and emaFast5 > emaSlow5
htfBearBias = close5 < emaSlow5 and emaFast5 < emaSlow5
htfBullBreak = close5 > previousHigh5
htfBearBreak = close5 < previousLow5

// ─────────────────────────────────────────────────────────────────────────────
// 5. MARKET STRUCTURE
// ─────────────────────────────────────────────────────────────────────────────
pivotHigh = ta.pivothigh(srcHigh, pivotLength, pivotLength)
pivotLow  = ta.pivotlow(srcLow, pivotLength, pivotLength)

var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    lastSwingHighBar := bar_index - pivotLength

if not na(pivotLow)
    lastSwingLow := pivotLow
    lastSwingLowBar := bar_index - pivotLength

bullBOS = not na(lastSwingHigh) and srcClose > lastSwingHigh and srcClose[1] <= lastSwingHigh
bearBOS = not na(lastSwingLow) and srcClose < lastSwingLow and srcClose[1] >= lastSwingLow

var int structureDirection = 0
bullCHOCH = bullBOS and structureDirection == -1
bearCHOCH = bearBOS and structureDirection == 1

if bullBOS
    structureDirection := 1
if bearBOS
    structureDirection := -1

// ─────────────────────────────────────────────────────────────────────────────
// 6. LIQUIDITY SWEEPS
// ─────────────────────────────────────────────────────────────────────────────
sellSideSweep = not na(lastSwingLow) and srcLow < lastSwingLow and srcClose > lastSwingLow
buySideSweep = not na(lastSwingHigh) and srcHigh > lastSwingHigh and srcClose < lastSwingHigh

lowerWick = math.min(srcOpen, srcClose) - srcLow
upperWick = srcHigh - math.max(srcOpen, srcClose)

bullSFP = sellSideSweep and lowerWick > bodySize * 1.25
bearSFP = buySideSweep and upperWick > bodySize * 1.25

// ─────────────────────────────────────────────────────────────────────────────
// 7. SESSION LEVELS
// ─────────────────────────────────────────────────────────────────────────────
inRTH = not na(time(timeframe.period, rthSession, "America/New_York"))
newRTH = inRTH and not inRTH[1]

var float sessionHigh = na
var float sessionLow = na
var float priorSessionHigh = na
var float priorSessionLow = na

if newRTH
    priorSessionHigh := sessionHigh
    priorSessionLow := sessionLow
    sessionHigh := srcHigh
    sessionLow := srcLow
else if inRTH
    sessionHigh := na(sessionHigh) ? srcHigh : math.max(sessionHigh, srcHigh)
    sessionLow := na(sessionLow) ? srcLow : math.min(sessionLow, srcLow)

bullSessionSweep = not na(priorSessionLow) and srcLow < priorSessionLow and srcClose > priorSessionLow
bearSessionSweep = not na(priorSessionHigh) and srcHigh > priorSessionHigh and srcClose < priorSessionHigh

// ─────────────────────────────────────────────────────────────────────────────
// 8. OPENING RANGE BREAKOUT
// ─────────────────────────────────────────────────────────────────────────────
inORB = not na(time(timeframe.period, orbSession, "America/New_York"))
newORB = inORB and not inORB[1]

var float orbHigh = na
var float orbLow = na
var bool orbReady = false

if newRTH
    orbHigh := na
    orbLow := na
    orbReady := false

if newORB
    orbHigh := srcHigh
    orbLow := srcLow
else if inORB
    orbHigh := na(orbHigh) ? srcHigh : math.max(orbHigh, srcHigh)
    orbLow := na(orbLow) ? srcLow : math.min(orbLow, srcLow)

if not inORB and inORB[1]
    orbReady := true

bullORB = orbReady and not na(orbHigh) and ((srcClose > orbHigh and srcClose[1] <= orbHigh) or (srcLow < orbLow and srcClose > orbLow))
bearORB = orbReady and not na(orbLow) and ((srcClose < orbLow and srcClose[1] >= orbLow) or (srcHigh > orbHigh and srcClose < orbHigh))

// ─────────────────────────────────────────────────────────────────────────────
// 9. FVG (Fair Value Gaps)
// ─────────────────────────────────────────────────────────────────────────────
newBullFVG = srcLow > srcHigh[2]
newBearFVG = srcHigh < srcLow[2]

var float bullFvgTop = na
var float bullFvgBottom = na
var int bullFvgBar = na
var float bearFvgTop = na
var float bearFvgBottom = na
var int bearFvgBar = na

if newBullFVG
    bullFvgTop := srcLow
    bullFvgBottom := srcHigh[2]
    bullFvgBar := bar_index

if newBearFVG
    bearFvgTop := srcLow[2]
    bearFvgBottom := srcHigh
    bearFvgBar := bar_index

bullFvgActive = not na(bullFvgBar) and bar_index - bullFvgBar <= fvgMaxAge and srcClose >= bullFvgBottom
bearFvgActive = not na(bearFvgBar) and bar_index - bearFvgBar <= fvgMaxAge and srcClose <= bearFvgTop

bullFvgReaction = bullFvgActive and srcLow <= bullFvgTop and srcClose >= bullFvgBottom
bearFvgReaction = bearFvgActive and srcHigh >= bearFvgBottom and srcClose <= bearFvgTop

// ─────────────────────────────────────────────────────────────────────────────
// 10. ORDER BLOCKS
// ─────────────────────────────────────────────────────────────────────────────
var float bullObTop = na
var float bullObBottom = na
var int bullObBar = na
var float bearObTop = na
var float bearObBottom = na
var int bearObBar = na

if bullBOS
    for i = 1 to obSearchBars
        if srcClose[i] < srcOpen[i]
            bullObTop := srcHigh[i]
            bullObBottom := srcLow[i]
            bullObBar := bar_index - i
            break

if bearBOS
    for i = 1 to obSearchBars
        if srcClose[i] > srcOpen[i]
            bearObTop := srcHigh[i]
            bearObBottom := srcLow[i]
            bearObBar := bar_index - i
            break

bullObActive = not na(bullObBar) and bar_index - bullObBar <= obMaxAge and srcClose >= bullObBottom
bearObActive = not na(bearObBar) and bar_index - bearObBar <= obMaxAge and srcClose <= bearObTop

bullObReaction = bullObActive and srcLow <= bullObTop and srcClose > bullObBottom
bearObReaction = bearObActive and srcHigh >= bearObBottom and srcClose < bearObTop

// ─────────────────────────────────────────────────────────────────────────────
// 11. PREMIUM / DISCOUNT AND S/R
// ─────────────────────────────────────────────────────────────────────────────
rangeHigh = ta.highest(srcHigh, rangeLength)
rangeLow = ta.lowest(srcLow, rangeLength)
equilibrium = math.avg(rangeHigh, rangeLow)

inDiscount = srcClose < equilibrium
inPremium = srcClose > equilibrium

srWidth = atr * srAtrMult
bullSupportReaction = not na(lastSwingLow) and srcLow <= lastSwingLow + srWidth and srcClose > lastSwingLow
bearResistanceReaction = not na(lastSwingHigh) and srcHigh >= lastSwingHigh - srWidth and srcClose < lastSwingHigh

// ─────────────────────────────────────────────────────────────────────────────
// 12. TRENDLINE BREAKOUT
// ─────────────────────────────────────────────────────────────────────────────
trendlineUpper = ta.linreg(srcHigh, trendlineLength, 0)
trendlineLower = ta.linreg(srcLow, trendlineLength, 0)

bullTrendlineBreak = srcClose > trendlineUpper and srcClose[1] <= trendlineUpper[1]
bearTrendlineBreak = srcClose < trendlineLower and srcClose[1] >= trendlineLower[1]

// ─────────────────────────────────────────────────────────────────────────────
// 13. VOLUME PROXIES
// ─────────────────────────────────────────────────────────────────────────────
signedVolume = srcClose > srcOpen ? srcVolume : srcClose < srcOpen ? -srcVolume : 0.0
volumeDeltaProxy = ta.ema(signedVolume, deltaSmooth)
bullDelta = volumeDeltaProxy > 0 and volumeDeltaProxy >= volumeDeltaProxy[1]
bearDelta = volumeDeltaProxy < 0 and volumeDeltaProxy <= volumeDeltaProxy[1]

highestVolumeOffset = math.abs(ta.highestbars(srcVolume, vpLookback))
volumeNodePrice = srcClose[highestVolumeOffset]
nearVolumeNode = math.abs(srcClose - volumeNodePrice) <= atr * vpTolerance

bullVolumeNode = nearVolumeNode and srcClose >= volumeNodePrice and srcClose > srcOpen
bearVolumeNode = nearVolumeNode and srcClose <= volumeNodePrice and srcClose < srcOpen

// ─────────────────────────────────────────────────────────────────────────────
// 14. SCORE MATRIX
// ─────────────────────────────────────────────────────────────────────────────
float longScore = 0.0
float shortScore = 0.0

longScore  += htfBullBias ? 1.5 : 0.0
shortScore += htfBearBias ? 1.5 : 0.0
longScore  += htfBullBreak ? 1.0 : 0.0
shortScore += htfBearBreak ? 1.0 : 0.0
longScore  += bullBOS ? 1.5 : 0.0
shortScore += bearBOS ? 1.5 : 0.0
longScore  += bullCHOCH ? 1.0 : 0.0
shortScore += bearCHOCH ? 1.0 : 0.0
longScore  += sellSideSweep ? 2.0 : 0.0
shortScore += buySideSweep ? 2.0 : 0.0
longScore  += bullSFP ? 0.5 : 0.0
shortScore += bearSFP ? 0.5 : 0.0
longScore  += bullSessionSweep ? 0.5 : 0.0
shortScore += bearSessionSweep ? 0.5 : 0.0
longScore  += (newBullFVG or bullFvgReaction) ? 1.5 : 0.0
shortScore += (newBearFVG or bearFvgReaction) ? 1.5 : 0.0
longScore  += bullObReaction ? 1.5 : 0.0
shortScore += bearObReaction ? 1.5 : 0.0
longScore  += inDiscount ? 1.0 : 0.0
shortScore += inPremium ? 1.0 : 0.0
longScore  += bullSupportReaction ? 1.0 : 0.0
shortScore += bearResistanceReaction ? 1.0 : 0.0
longScore  += bullTrend ? 1.0 : 0.0
shortScore += bearTrend ? 1.0 : 0.0
longScore  += bullTrendlineBreak ? 0.5 : 0.0
shortScore += bearTrendlineBreak ? 0.5 : 0.0
longScore  += bullORB ? 1.0 : 0.0
shortScore += bearORB ? 1.0 : 0.0
longScore  += bullDelta ? 1.0 : 0.0
shortScore += bearDelta ? 1.0 : 0.0
longScore  += bullVolumeNode ? 1.0 : 0.0
shortScore += bearVolumeNode ? 1.0 : 0.0
longScore  += bullDisplacement ? 1.0 : 0.0
shortScore += bearDisplacement ? 1.0 : 0.0
longScore  += rsiValue >= rsiBullLevel ? 0.5 : 0.0
shortScore += rsiValue <= rsiBearLevel ? 0.5 : 0.0

// 세션은 방향이 아니라 시장 활성도 점수로 LONG/SHORT에 동일 적용
longScore  += sessionScore
shortScore += sessionScore

maxScore = 20.0

// ─────────────────────────────────────────────────────────────────────────────
// 15. SIGNAL GRADES AND FILTERS
// ─────────────────────────────────────────────────────────────────────────────
grade(float score) =>
    string g = "WAIT"
    if score >= 15.0
        g := "A+"
    else if score >= 13.0
        g := "A"
    else if score >= 11.0
        g := "B"
    else
        g := "C"
    g

dynamicTpPoints(float score) =>
    float selectedTp = tpLowPoints
    if score >= 15.0
        selectedTp := tpHighPoints
    else if score >= 13.0
        selectedTp := tpMidPoints
    else
        selectedTp := tpLowPoints
    selectedTp

// 승률을 지키기 위한 필수 ICT 필터 (상위 추세 + 유동성 스윕 + 구조 변화 + FVG/디스플레이 중 하나 이상)
longMandatory = htfBullBias and sellSideSweep and (bullBOS or bullCHOCH) and (bullDisplacement or newBullFVG or bullFvgReaction)
shortMandatory = htfBearBias and buySideSweep and (bearBOS or bearCHOCH) and (bearDisplacement or newBearFVG or bearFvgReaction)

longFiltersValid = not useMandatoryFilters or longMandatory
shortFiltersValid = not useMandatoryFilters or shortMandatory

// ─────────────────────────────────────────────────────────────────────────────
// 16. POSITION STATE, SIGNALS (15S / NON-REPAINTING)
// ─────────────────────────────────────────────────────────────────────────────
var int positionState = 0
var float entryPrice = na
var float targetPrice = na
var float stopPrice = na
var float activeTpPoints = na
var int entryBar = na
var int lastExitBar = na
var string entryGrade = "-"

isFlat = positionState == 0
cooldownComplete = na(lastExitBar) or bar_index - lastExitBar > cooldownBars

// 현재 봉이 완전히 마감된 순간 신호를 확정합니다.
// 기존 버전의 longSignal[1] / shortSignal[1] 추가 지연을 제거했습니다.
longCandidate = timeframeValid and isFlat and cooldownComplete and longFiltersValid and longScore >= minimumScore and (longScore - shortScore) >= minimumDifference and barstate.isconfirmed
shortCandidate = timeframeValid and isFlat and cooldownComplete and shortFiltersValid and shortScore >= minimumScore and (shortScore - longScore) >= minimumDifference and barstate.isconfirmed

longSignal = longCandidate and not shortCandidate
shortSignal = shortCandidate and not longCandidate

// 캔들 마감가를 진입가로 사용합니다. 리페인팅 없이 신호 마감 직후 전송됩니다.
if longSignal
    positionState := 1
    entryPrice := srcClose
    activeTpPoints := useDynamicTP ? dynamicTpPoints(longScore) : tpLowPoints
    targetPrice := entryPrice + activeTpPoints
    stopPrice := entryPrice - stopLossPoints
    entryBar := bar_index
    entryGrade := grade(longScore)

    longAlertMessage = '{"signal":"LONG","ticker":"' + selectedSymbol + '","timeframe":"' + timeframe.period + '","entry":"' + str.tostring(entryPrice, format.mintick) + '","tp":"' + str.tostring(targetPrice, format.mintick) + '","sl":"' + str.tostring(stopPrice, format.mintick) + '","tp_points":"' + str.tostring(activeTpPoints) + '","score":"' + str.tostring(longScore, "#.0") + '/20","grade":"' + entryGrade + '","bias":"' + (htfBullBias ? "BULLISH" : "NEUTRAL") + '","session":"' + currentSession + '","session_score":"' + str.tostring(sessionScore, "#.0") + '","time":"' + str.format_time(time_close, "yyyy-MM-dd HH:mm:ss", "Asia/Seoul") + '"}'
    alert(longAlertMessage, alert.freq_once_per_bar_close)

if shortSignal
    positionState := -1
    entryPrice := srcClose
    activeTpPoints := useDynamicTP ? dynamicTpPoints(shortScore) : tpLowPoints
    targetPrice := entryPrice - activeTpPoints
    stopPrice := entryPrice + stopLossPoints
    entryBar := bar_index
    entryGrade := grade(shortScore)

    shortAlertMessage = '{"signal":"SHORT","ticker":"' + selectedSymbol + '","timeframe":"' + timeframe.period + '","entry":"' + str.tostring(entryPrice, format.mintick) + '","tp":"' + str.tostring(targetPrice, format.mintick) + '","sl":"' + str.tostring(stopPrice, format.mintick) + '","tp_points":"' + str.tostring(activeTpPoints) + '","score":"' + str.tostring(shortScore, "#.0") + '/20","grade":"' + entryGrade + '","bias":"' + (htfBearBias ? "BEARISH" : "NEUTRAL") + '","session":"' + currentSession + '","session_score":"' + str.tostring(sessionScore, "#.0") + '","time":"' + str.format_time(time_close, "yyyy-MM-dd HH:mm:ss", "Asia/Seoul") + '"}'
    alert(shortAlertMessage, alert.freq_once_per_bar_close)

canExit = positionState != 0 and not na(entryBar) and bar_index > entryBar

longTargetTouched = canExit and positionState == 1 and srcHigh >= targetPrice
longStopTouched = canExit and positionState == 1 and srcLow <= stopPrice
shortTargetTouched = canExit and positionState == -1 and srcLow <= targetPrice
shortStopTouched = canExit and positionState == -1 and srcHigh >= stopPrice

stopSignal = longStopTouched or shortStopTouched
tpSignal = (longTargetTouched and not longStopTouched) or (shortTargetTouched and not shortStopTouched)

var int totalTrades = 0
var int winningTrades = 0
var int losingTrades = 0
var int longTrades = 0
var int shortTrades = 0
var string lastResult = "-"

if tpSignal
    totalTrades += 1
    winningTrades += 1
    if positionState == 1
        longTrades += 1
        lastResult := "LONG TP +" + str.tostring(activeTpPoints)
    else
        shortTrades += 1
        lastResult := "SHORT TP +" + str.tostring(activeTpPoints)

if stopSignal
    totalTrades += 1
    losingTrades += 1
    if positionState == 1
        longTrades += 1
        lastResult := "LONG SL -" + str.tostring(stopLossPoints)
    else
        shortTrades += 1
        lastResult := "SHORT SL -" + str.tostring(stopLossPoints)

// TP/SL 결과도 텔레그램으로 전송합니다.
if tpSignal
    tpDirection = positionState == 1 ? "LONG" : "SHORT"
    tpAlertMessage = '{"signal":"TP","side":"' + tpDirection + '","ticker":"' + selectedSymbol + '","timeframe":"' + timeframe.period + '","entry":"' + str.tostring(entryPrice, format.mintick) + '","exit":"' + str.tostring(targetPrice, format.mintick) + '","result":"WIN","time":"' + str.format_time(time_close, "yyyy-MM-dd HH:mm:ss", "Asia/Seoul") + '"}'
    alert(tpAlertMessage, alert.freq_once_per_bar_close)

if stopSignal
    slDirection = positionState == 1 ? "LONG" : "SHORT"
    slAlertMessage = '{"signal":"SL","side":"' + slDirection + '","ticker":"' + selectedSymbol + '","timeframe":"' + timeframe.period + '","entry":"' + str.tostring(entryPrice, format.mintick) + '","exit":"' + str.tostring(stopPrice, format.mintick) + '","result":"LOSS","time":"' + str.format_time(time_close, "yyyy-MM-dd HH:mm:ss", "Asia/Seoul") + '"}'
    alert(slAlertMessage, alert.freq_once_per_bar_close)

if tpSignal or stopSignal
    positionState := 0
    entryPrice := na
    targetPrice := na
    stopPrice := na
    activeTpPoints := na
    entryBar := na
    lastExitBar := bar_index
    entryGrade := "-"

winRate = totalTrades > 0 ? winningTrades * 100.0 / totalTrades : na

// ─────────────────────────────────────────────────────────────────────────────
// 17. VISUALS
// ─────────────────────────────────────────────────────────────────────────────
plot(showEMAs ? emaFast : na, "EMA Fast", color = color.aqua, linewidth = 1)
plot(showEMAs ? emaSlow : na, "EMA Slow", color = color.orange, linewidth = 1)

plot(showORB ? orbHigh : na, "ORB High", color = color.new(color.green, 25), style = plot.style_linebr)
plot(showORB ? orbLow : na, "ORB Low", color = color.new(color.red, 25), style = plot.style_linebr)

plot(showTradeLines and positionState != 0 ? entryPrice : na, "Entry", color = color.yellow, linewidth = 2, style = plot.style_linebr)
plot(showTradeLines and positionState != 0 ? targetPrice : na, "TP", color = color.lime, linewidth = 2, style = plot.style_linebr)
plot(showTradeLines and positionState != 0 ? stopPrice : na, "SL", color = color.red, linewidth = 2, style = plot.style_linebr)

signalOffset = atr * 0.35
structureOffset1 = atr * 0.18
structureOffset2 = atr * 0.34
liquidityOffset = atr * 0.52

if longSignal
    label.new(bar_index, srcLow - signalOffset, "BUY " + grade(longScore) + " TP" + str.tostring(useDynamicTP ? dynamicTpPoints(longScore) : tpLowPoints), yloc = yloc.price, style = label.style_label_up, color = color.lime, textcolor = color.black, size = size.small)

if shortSignal
    label.new(bar_index, srcHigh + signalOffset, "SELL " + grade(shortScore) + " TP" + str.tostring(useDynamicTP ? dynamicTpPoints(shortScore) : tpLowPoints), yloc = yloc.price, style = label.style_label_down, color = color.red, textcolor = color.white, size = size.small)

if tpSignal
    label.new(bar_index, srcHigh + signalOffset, "TP", yloc = yloc.price, style = label.style_label_down, color = color.green, textcolor = color.white, size = size.tiny)

if stopSignal
    label.new(bar_index, srcHigh + signalOffset, "SL", yloc = yloc.price, style = label.style_label_down, color = color.maroon, textcolor = color.white, size = size.tiny)

if showStructure and bullBOS
    label.new(bar_index, srcLow - structureOffset1, "BOS↑", yloc = yloc.price, style = label.style_label_up, color = color.new(color.green, 72), textcolor = color.green, size = size.tiny)

if showStructure and bearBOS
    label.new(bar_index, srcHigh + structureOffset1, "BOS↓", yloc = yloc.price, style = label.style_label_down, color = color.new(color.red, 72), textcolor = color.red, size = size.tiny)

if showStructure and bullCHOCH
    label.new(bar_index, srcLow - structureOffset2, "CHOCH↑", yloc = yloc.price, style = label.style_label_up, color = color.new(color.teal, 70), textcolor = color.teal, size = size.tiny)

if showStructure and bearCHOCH
    label.new(bar_index, srcHigh + structureOffset2, "CHOCH↓", yloc = yloc.price, style = label.style_label_down, color = color.new(color.orange, 70), textcolor = color.orange, size = size.tiny)

if showStructure and sellSideSweep
    label.new(bar_index, srcLow - liquidityOffset, "SSL", yloc = yloc.price, style = label.style_none, color = color.new(color.blue, 100), textcolor = color.blue, size = size.tiny)

if showStructure and buySideSweep
    label.new(bar_index, srcHigh + liquidityOffset, "BSL", yloc = yloc.price, style = label.style_none, color = color.new(color.purple, 100), textcolor = color.purple, size = size.tiny)

var box bullFvgBox = na
var box bearFvgBox = na
var box bullObBox = na
var box bearObBox = na

if showZones and newBullFVG
    box.delete(bullFvgBox)
    bullFvgBox := box.new(bar_index - 2, bullFvgTop, bar_index, bullFvgBottom, bgcolor = color.new(color.green, 88), border_color = color.new(color.green, 45), extend = extend.right)

if showZones and newBearFVG
    box.delete(bearFvgBox)
    bearFvgBox := box.new(bar_index - 2, bearFvgTop, bar_index, bearFvgBottom, bgcolor = color.new(color.red, 88), border_color = color.new(color.red, 45), extend = extend.right)

if showZones and bullBOS and not na(bullObBar)
    box.delete(bullObBox)
    bullObBox := box.new(bullObBar, bullObTop, bar_index, bullObBottom, bgcolor = color.new(color.teal, 90), border_color = color.new(color.teal, 50), extend = extend.right)

if showZones and bearBOS and not na(bearObBar)
    box.delete(bearObBox)
    bearObBox := box.new(bearObBar, bearObTop, bar_index, bearObBottom, bgcolor = color.new(color.orange, 90), border_color = color.new(color.orange, 50), extend = extend.right)

// ─────────────────────────────────────────────────────────────────────────────
// 18. DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
var table dashboard = table.new(position.bottom_right, 3, 11, border_width = 1, frame_width = 1)

if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, "NQ ICT", text_color = color.white, bgcolor = color.rgb(35, 80, 145), text_size = size.tiny)
    table.cell(dashboard, 0, 10, "TF/SYM", text_color = color.white, bgcolor = color.rgb(45,45,45), text_size = size.tiny)
    table.cell(dashboard, 1, 0, "LONG", text_color = color.white, bgcolor = color.new(color.green, 20), text_size = size.tiny)
    table.cell(dashboard, 2, 0, "SHORT", text_color = color.white, bgcolor = color.new(color.red, 20), text_size = size.tiny)

    table.cell(dashboard, 0, 1, "SCORE", text_color = color.white, bgcolor = color.rgb(45,45,45), text_size = size.tiny)
    table.cell(dashboard, 1, 1, str.tostring(longScore, "#.0") + "/20", text_color = color.white, bgcolor = color.new(color.green, 70), text_size = size.tiny)
    table.cell(dashboard, 2, 1, str.tostring(shortScore, "#.0") + "/20", text_color = color.white, bgcolor = color.new(color.red, 70), text_size = size.tiny)

    table.cell(dashboard, 0, 2, "GRADE", text_color = color.white, bgcolor = color.rgb(45,45,45), text_size = size.tiny)
    table.cell(dashboard, 1, 2, grade(longScore), text_color = color.white, bgcolor = color.new(color.green, 75), text_size = size.tiny)
    table.cell(dashboard, 2, 2, grade(shortScore), text_color = color.white, bgcolor = color.new(color.red, 75), text_size = size.tiny)

    table.cell(dashboard, 0, 3, "5M BIAS", text_color = color.white, bgcolor = color.rgb(45,45,45), text_size = size.tiny)
    table.cell(dashboard, 1, 3, htfBullBias ? "UP" : "-", text_color = color.white, bgcolor = htfBullBias ? color.new(color.green, 30) : color.new(color.gray, 60), text_size = size.tiny)
    table.cell(dashboard, 2, 3, htfBearBias ? "DOWN" : "-", text_color = color.white, bgcolor = htfBearBias ? color.new(color.red, 30) : color.new(color.gray, 60), text_size = size.tiny)

    table.cell(dashboard, 0, 4, "STRUCT", text_color = color.white, bgcolor = color.rgb(45,45,45), text_size = size.tiny)
    table.cell(dashboard, 1, 4, bullCHOCH ? "CHOCH" : bullBOS ? "BOS" : "-", text_color = color.white, bgcolor = color.new(color.green, 65), text_size = size.tiny)
    table.cell(dashboard, 2, 4, bearCHOCH ? "CHOCH" : bearBOS ? "BOS" : "-", text_color = color.white, bgcolor = color.new(color.red, 65), text_size = size.tiny)

    table.cell(dashboard, 0, 5, "LIQ", text_color = color.white, bgcolor = color.rgb(45,45,45), text_size = size.tiny)
    table.cell(dashboard, 1, 5, sellSideSweep ? "SSL" : "-", text_color = color.white, bgcolor = color.new(color.blue, 60), text_size = size.tiny)
    table.cell(dashboard, 2, 5, buySideSweep ? "BSL" : "-", text_color = color.white, bgcolor = color.new(color.purple, 60), text_size = size.tiny)

    table.cell(dashboard, 0, 6, "FVG/OB", text_color = color.white, bgcolor = color.rgb(45,45,45), text_size = size.tiny)
    table.cell(dashboard, 1, 6, (bullFvgReaction or bullObReaction) ? "YES" : "-", text_color = color.white, bgcolor = color.new(color.green, 70), text_size = size.tiny)
    table.cell(dashboard, 2, 6, (bearFvgReaction or bearObReaction) ? "YES" : "-", text_color = color.white, bgcolor = color.new(color.red, 70), text_size = size.tiny)

    table.cell(dashboard, 0, 7, "POSITION", text_color = color.white, bgcolor = color.rgb(45,45,45), text_size = size.tiny)
    table.cell(dashboard, 1, 7, positionState == 1 ? "LONG " + entryGrade : positionState == -1 ? "SHORT " + entryGrade : "WAIT", text_color = color.white, bgcolor = positionState == 1 ? color.new(color.green, 25) : positionState == -1 ? color.new(color.red, 25) : color.new(color.gray, 55), text_size = size.tiny)
    table.cell(dashboard, 2, 7, lastResult, text_color = color.white, bgcolor = color.new(color.gray, 55), text_size = size.tiny)

    table.cell(dashboard, 0, 8, "WIN", text_color = color.white, bgcolor = color.rgb(45,45,45), text_size = size.tiny)
    table.cell(dashboard, 1, 8, totalTrades > 0 ? str.tostring(winRate, "#.0") + "%" : "-", text_color = color.white, bgcolor = not na(winRate) and winRate >= 67 ? color.new(color.green, 25) : color.new(color.gray, 55), text_size = size.tiny)
    table.cell(dashboard, 2, 8, str.tostring(totalTrades) + " T", text_color = color.white, bgcolor = color.new(color.gray, 55), text_size = size.tiny)

    table.cell(dashboard, 0, 9, "SESSION", text_color = color.white, bgcolor = color.rgb(45,45,45), text_size = size.tiny)
    table.cell(dashboard, 1, 9, currentSession, text_color = color.white, bgcolor = color.new(color.blue, 55), text_size = size.tiny)
    table.cell(dashboard, 2, 9, "+" + str.tostring(sessionScore, "#.0"), text_color = color.white, bgcolor = color.new(color.blue, 65), text_size = size.tiny)

    table.cell(dashboard, 0, 10, "TF/SYM", text_color = color.white, bgcolor = color.rgb(45,45,45), text_size = size.tiny)
    table.cell(dashboard, 1, 10, validChartTimeframe ? "15S OK" : "15S ONLY", text_color = color.white, bgcolor = validChartTimeframe ? color.new(color.green, 35) : color.new(color.red, 30), text_size = size.tiny)
    table.cell(dashboard, 2, 10, selectedSymbol, text_color = color.white, bgcolor = color.new(color.gray, 55), text_size = size.tiny)

if barstate.islast and not showDashboard
    table.clear(dashboard, 0, 0, 2, 10)

// ─────────────────────────────────────────────────────────────────────────────
// 19. ALERTS
// ─────────────────────────────────────────────────────────────────────────────
// TradingView 얼러트 생성 시 조건을 "Any alert() function call"로 선택합니다.
// 동적 진입가/TP/SL은 위의 alert() 메시지로 전송됩니다.
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(longSignal, title = "NQ ICT LONG", message = "NQ ICT LONG")
alertcondition(shortSignal, title = "NQ ICT SHORT", message = "NQ ICT SHORT")
alertcondition(tpSignal, title = "NQ ICT TP", message = "NQ ICT TP")
alertcondition(stopSignal, title = "NQ ICT SL", message = "NQ ICT SL")


// ============================================================================
// SYMBOL SELECTION
// ============================================================================
// 설정 > Inputs > 1. General
// - Signal Symbol: 계산할 계약물 선택 (예: CME_MINI:NQU2026)
// - Use Current Chart Symbol:
//      OFF = Signal Symbol 기준으로 계산
//      ON  = 현재 차트 종목 기준으로 계산
// ============================================================================
````
