# 1NQ/MNQ Super Scalper TREND

- url: https://www.tradingview.com/script/rVYbTf3i-1NQ-MNQ-Super-Scalper-TREND/
- type: indicator
- pine_id: PUB;9934435a8cf24e09820a743c88dc5a2a
- version: 2.0

## Description

The NQ/MNQ Super Scalper is a two-indicator mechanical scalping system for the NASDAQ futures — NQ and its micro contract, MNQ. Both indicators run on the same chart and are designed to complement each other: TREND looks for entries that go with the prevailing move — continuation, breakouts, defended zones — and FLOW+CT looks for entries that go against it — reversals at exhaustion, structure breaks, sweep fades. The system requires a TradingView Premium subscription to function as designed — the order-flow, delta, and tick-level data the confidence builders depend on, along with the lower-timeframe and intraday history the indicators reach back into, are not available on lower tiers. Without Premium data, large parts of the logic either degrade or return blank, and the trade fires lose their research backing. The system itself blends several research traditions under one roof: ICT concepts handle structure and zones, Wyckoff and Volume-Spread-Analysis inform the climax and absorption logic, classic technical analysis covers RSI and divergence work, and modern order-flow analytics drive the delta, aggressor, and volatility-zone reads. Each fire produces either a full trade ticket — a colored label with dashed take-profit and stop-loss lines — or, on weaker setups, a directional arrow. Every trade has its own research-backed confidence builder rather than a shared scoring model, and the system is stateless: no timers or cooldowns, only event-based gates. Together these indicators support full review and validation of every trade type against its underlying research, recalibration of per-trade confidence thresholds, tuning of visual tier thresholds and body filters, live diagnostics through the on-chart confidence and outcome readouts, and post-trade analysis using maximum-adverse-excursion data when those toggles are switched on — all within a no-fluff, no-scope-creep, push-back-with-research workflow.

TREND handles continuation and structure trades — entries taken in the direction the market is already moving, or on confirmed breaks of recent ranges. This is where the ICT model does most of its work: Optimal Trade Entry zones, Break-of-Structure, Order Blocks, Fair Value Gaps and their inverse, and liquidity-sweep traps all live here as their own trade types. Alongside the ICT layer, the indicator runs an opening-drive read on the 8:30 Central Time volume burst, a TTM Squeeze breakout paired with momentum from the classic Carter framework, and clean retests of broken levels for traders who prefer the second touch over the initial break. Underneath the trade logic, a regime-aware stop-loss buffer adapts to volatility, higher-timeframe regime gates filter certain setups, and a directional pulse score with statistical z-scoring scales confidence relative to recent market behavior rather than fixed cutoffs. This is the indicator to use when the question is "is the trend strong enough to ride, and where do I get on?"

## Source Code

````pine
//@version=6
indicator("1NQ/MNQ Super Scalper TREND", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=500, calc_bars_count=5000)
var g1 = "1 - Signal"
var g2 = "2 - Exits"
tpBuffer = input.float(1.0, "TP Buffer (pts)", group=g2)
minProfit = input.float(10.0, "Min Profit (pts)", group=g2)
var g3 = "3 - ICT Features"
useFVG = input.bool(true, "Fair Value Gaps", group=g3)
fvgMinPct= input.float(0.3, "FVG Min (xATR)", group=g3)
useOTE = input.bool(true, "OTE Zone (62-79%)", group=g3)
useBOS = input.bool(true, "BOS/MSS", group=g3)
bosLen = input.int(10, "BOS Lookback", group=g3)
useSweep = input.bool(true, "Liquidity Sweep", group=g3)
sweepLen = input.int(20, "Sweep Lookback", group=g3)
useOD = input.bool(true, "Opening Drive (8:30 CT)", group=g3)
var g5 = "5 - Liquidity"
minRelVol = input.float(1.2, "Min Relative Volume", group=g5)
minAtrPts = input.float(5.0, "Min ATR (points)", group=g5)
var g7a = "7a - Direction Pulse"
showSuperTrend = input.bool(true, "Show SuperTrend Line", group=g7a)
showDirPulse = input.bool(true, "Show Direction Pulse", group=g7a)
useDirBarColor = input.bool(true, "Color Candles by Score", group=g7a)
i_persistWindow = input.int(5, "Persistence window (bars)", minval=2, maxval=20, group=g7a, tooltip="Number of bars used to compute directional persistence for tick/delta/MFI/rawFlow factors in dirScoreFull. Higher = slower confirmation, more stable. Lower = faster but noisier.")
i_dirZLookback = input.int(50, "dirScoreFull EWMA lookback (bars)", minval=20, maxval=200, group=g7a, tooltip="Effective lookback for EWMA mean and variance of dirScoreFull. Translated internally to alpha = 2/(N+1). Half-life ~N/2.9 bars. Operates 24/7 with no session reset; older regime data decays exponentially as new regimes emerge. Longer = more stable baseline, slower adaptation. Shorter = more reactive to recent regime, noisier.")
i_dirZThresh = input.float(2.0, "Directional z-score threshold", minval=1.0, maxval=3.5, step=0.1, group=g7a, tooltip="Z-score saturation point for the confidence sum's dir factor. dir saturates at 1.0 when dirScoreFull is i_dirZThresh stdev above local mean. 2.0 ≈ 95th percentile under normal distribution (FTSE Russell factor winsorization standard).")
swingATRMult = input.float(1.0, "Swing pivot ATR multiplier", minval=0.3, maxval=3.0, step=0.1, group=g7a, tooltip="Min swing magnitude (in ATR multiples) for HL/LH pivot freshness check. Lower = more pivots count as fresh; higher = stricter. Replaces the prior dynamic helper — ATR already encodes recent volatility/regime.")
var g7b = "7b - Extra Levels"
showQQQLevels = input.bool(true, "QQQ Levels in TP/SR", group=g7b)
qqqIncrement = input.float(5.0, "QQQ Level Spacing", group=g7b, options=[2.5, 5.0, 10.0])
showORBMid = input.bool(true, "ORB Midline", group=g7b)
showONRange = input.bool(true, "Overnight Range", group=g7b)
showORBLines  = input.bool(true,  "Show ORB H/L lines",                  group=g7b)
showOTEBox    = input.bool(true,  "Show OTE zone box",                   group=g7b)
showPivots    = input.bool(true,  "Show Daily Pivots (PP/R1/S1/R2/S2)",  group=g7b)
showPrevDay   = input.bool(true,  "Show Prior Day H/L",                  group=g7b)
showONLevels  = input.bool(false, "Show Overnight H/L",                  group=g7b)
showVolProf   = input.bool(true,  "Show Volume Profile (POC/VAH/VAL)",   group=g7b)
showHvbZones  = input.bool(true,  "Show HVB zones",                      group=g7b)
showVWAP      = input.bool(true,  "Show VWAP",                           group=g7b)
showPivLabels = input.bool(true,  "Show pivot swing labels (BULL/BEAR)", group=g7b)
showHotZone   = input.bool(false, "Show Hot Zone bg",                    group=g7b)
var g7 = "7 - Overlays"
hvbLookback = input.int(50, "HVB Lookback (bars)", group=g7)
hvbBins = input.int(15, "HVB Price Bins", group=g7)
projFwd = input.int(10, "Projection Forward (bars)", group=g7)
var gNW = "10 - NWOG"
showNWOG  = input.bool(true, "Show NWOG Lines (weekly)", group=gNW)
nwogCount = input.int(4, "NWOGs to Show", minval=1, maxval=10, group=gNW)
atrFast = ta.atr(10)
atrMed = ta.atr(14)
atrSlow = ta.atr(20)
atr = atrMed
[_, _, adx] = ta.dmi(14, 14)
vwapVal = ta.vwap(hlc3)
var float fpPocMid = na
var float hvbZone1 = na
var float hvbZone2 = na
var float hvbZone3 = na
var float povLevel = na
var float vahLevel = na
var float valLevel = na
var float pocBuyPct = 50.0
var float pocRawBuy = 0.0
var float pocRawSell = 0.0
var float nodeStrength = 0.0
var float fvgBullHi = na
var float fvgBullLo = na
var float fvgBearHi = na
var float fvgBearLo = na
var float fvgBullFill = 0.0
var float fvgBearFill = 0.0
var int fvgBullAge = 0
var int fvgBearAge = 0
var int fvgBullTouch = 0
var int fvgBearTouch = 0
var float obBullMid = na
var float obBearMid = na
var float obBullStoredHi    = na
var float obBullStoredLo    = na
var int   obBullFormScore   = 0
var bool  obBullTouched     = false
var int   obBullDefenseCount = 0
var bool  obBullActive      = false
var float obBearStoredHi    = na
var float obBearStoredLo    = na
var int   obBearFormScore   = 0
var bool  obBearTouched     = false
var int   obBearDefenseCount = 0
var bool  obBearActive      = false
var float nearSup = na
var float nearRes = na
var int entryBar = na
var float onHigh = na
var float onLow = na
type TixEntry
    int eBar
    bool isLong
    float sl
    float tp
    line slLn
    line tpLn
    label lbl
    bool closed
    string kind
    float fireClose
    float mae
var array<TixEntry> activeTix = array.new<TixEntry>()
ema9 = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)
[macdLine, macdSig, macdHist] = ta.macd(close, 12, 26, 9)
macdBear = macdLine < macdSig and macdHist < 0
macdBull = macdLine > macdSig and macdHist > 0
spyClose = request.security("SPY", timeframe.period, close, lookahead=barmerge.lookahead_off)
[esHigh, esLow] = request.security("ES1!", timeframe.period, [high, low], lookahead=barmerge.lookahead_off)
rocNQ = close != 0 and close[10] != 0 ? (close - close[10]) / close[10] * 100 : 0.0
rocSPY = spyClose != 0 and spyClose[10] != 0 ? (spyClose - spyClose[10]) / spyClose[10] * 100 : 0.0
rsSpread = rocNQ - rocSPY
qqqClose = request.security("QQQ", timeframe.period, close, lookahead=barmerge.lookahead_off)
float qqqRatio = qqqClose > 0 ? close / qqqClose : na
float qqqLvlUp1 = na
float qqqLvlUp2 = na
float qqqLvlDn1 = na
float qqqLvlDn2 = na
if showQQQLevels and not na(qqqRatio) and not na(qqqClose)
    float qUp1 = qqqIncrement * math.ceil(qqqClose / qqqIncrement)
    float qUp2 = qUp1 + qqqIncrement
    float qDn1 = qqqIncrement * math.floor(qqqClose / qqqIncrement)
    float qDn2 = qDn1 - qqqIncrement
    qqqLvlUp1 := qUp1 * qqqRatio
    qqqLvlUp2 := qUp2 * qqqRatio
    qqqLvlDn1 := qDn1 * qqqRatio
    qqqLvlDn2 := qDn2 * qqqRatio
[prevDayH, prevDayL, prevDayC, prev2DayH, prev2DayL, dEma9, dEma21] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1], high[2], low[2], ta.ema(close[1], 9), ta.ema(close[1], 21)], lookahead=barmerge.lookahead_on)
pivotPP = (prevDayH + prevDayL + prevDayC) / 3
pivotR1 = 2 * pivotPP - prevDayL
pivotS1 = 2 * pivotPP - prevDayH
pivotR2 = pivotPP + (prevDayH - prevDayL)
pivotS2 = pivotPP - (prevDayH - prevDayL)
bool dailyBullCont = not na(prevDayC) and not na(prev2DayH) and prevDayC > prev2DayH
bool dailyBearCont = not na(prevDayC) and not na(prev2DayL) and prevDayC < prev2DayL
bool dailyBullRev = not na(prevDayL) and not na(prev2DayL) and not na(prevDayC) and prevDayL < prev2DayL and prevDayC > prev2DayL
bool dailyBearRev = not na(prevDayH) and not na(prev2DayH) and not na(prevDayC) and prevDayH > prev2DayH and prevDayC < prev2DayH
float dailyBias = dailyBullCont ? 1.0 : dailyBullRev ? 1.0 : dailyBearCont ? -1.0 : dailyBearRev ? -1.0 : 0.0
_nwWkOpen = request.security(syminfo.tickerid, "W", open, lookahead=barmerge.lookahead_on)
bool _newWeek = ta.change(time("W")) != 0
var array<int>   nwogBar   = array.new_int(0)
var array<float> nwogOpen  = array.new_float(0)
var array<float> nwogClose = array.new_float(0)
if showNWOG and _newWeek and not na(_nwWkOpen) and not na(close[1])
    array.push(nwogBar,   bar_index)
    array.push(nwogOpen,  _nwWkOpen)
    array.push(nwogClose, close[1])
    while array.size(nwogBar) > nwogCount
        array.shift(nwogBar)
        array.shift(nwogOpen)
        array.shift(nwogClose)
var float cumVol2 = 0.0
var float cumVolPr = 0.0
var float cumVolPr2 = 0.0
isNewDay2 = ta.change(dayofmonth(time)) != 0
if isNewDay2
    cumVol2 := 0.0
    cumVolPr := 0.0
    cumVolPr2 := 0.0
cumVol2 += volume
cumVolPr += hlc3 * volume
cumVolPr2 += hlc3 * hlc3 * volume
vwapCalc = cumVol2 > 0 ? cumVolPr / cumVol2 : close
vwapVar = cumVol2 > 0 ? (cumVolPr2 / cumVol2) - (vwapCalc * vwapCalc) : 0.0
vwapStd = math.sqrt(math.max(0.0, vwapVar))
vwapUp1 = vwapCalc + vwapStd
vwapDn1 = vwapCalc - vwapStd
vwapUp2 = vwapCalc + vwapStd * 2
vwapDn2 = vwapCalc - vwapStd * 2
rsiRaw = ta.rsi(close, 7)
[_, bbUpper, bbLower] = ta.bb(close, 20, 1.5)
kcMid = ta.ema(close, 20)
kcUpper = kcMid + ta.atr(20) * 1.5
kcLower = kcMid - ta.atr(20) * 1.5
sqzOn = bbUpper < kcUpper and bbLower > kcLower
sqzFired = sqzOn[1] and not sqzOn
sqzHL = ta.highest(high, 20)
sqzLL = ta.lowest(low, 20)
sqzMidRef = math.avg(math.avg(sqzHL, sqzLL), ta.sma(close, 20))
sqzMom = ta.linreg(close - sqzMidRef, 20, 0)
bool momRecentBull = sqzMom > 0 and (sqzMom[1] <= 0 or sqzMom[2] <= 0 or sqzMom[3] <= 0)
bool momRecentBear = sqzMom < 0 and (sqzMom[1] >= 0 or sqzMom[2] >= 0 or sqzMom[3] >= 0)
float bbWidth = bbUpper - bbLower
float bbPos = bbWidth > 0 ? (close - bbLower) / bbWidth : 0.5
stSrc = hlcc4
stAtrLen = 24
stMult = 1.4
stAtr = ta.atr(stAtrLen)
stUp = stSrc - stMult * stAtr
stDn = stSrc + stMult * stAtr
stUp := close[1] > stUp[1] ? math.max(stUp, stUp[1]) : stUp
stDn := close[1] < stDn[1] ? math.min(stDn, stDn[1]) : stDn
var int stTrend = 1
stTrend := stTrend == -1 and close > stDn[1] ? 1 : stTrend == 1 and close < stUp[1] ? -1 : stTrend
stPlot = stTrend == 1 ? stUp : stDn
stColor = stTrend == 1 ? color.new(color.teal, 30) : color.new(color.red, 30)
plot(showSuperTrend ? stPlot : na, title="SuperTrend", color=stColor, linewidth=2, style=plot.style_linebr)
aerLen = 10
aerBaseThresh= 0.25
aerMaxCap = 0.65
float aerDisplacement = math.abs(close - close[aerLen])
float aerPath = math.sum(math.abs(close - close[1]), aerLen)
float aerER = aerPath != 0 ? (aerDisplacement / aerPath) : 0.0
float aerMeanATR = ta.sma(atr, 50)
float aerATRatio = aerMeanATR != 0 ? (atr / aerMeanATR) : 1.0
float aerRawThresh = aerBaseThresh * aerATRatio
float aerDynThresh = math.min(aerRawThresh, aerMaxCap)
bool aerTrending = aerER > aerDynThresh
bool aerUptrend = aerTrending and (close > close[aerLen])
bool aerDowntrend = aerTrending and (close < close[aerLen])
bool aerNonTrending = aerER <= aerDynThresh
bool aerChoppy = aerNonTrending and (atr > aerMeanATR)
bool aerConsolidation = aerNonTrending and (atr <= aerMeanATR)
int hurstLen = 50
float hurstRet = close - close[1]
f_rs_seg(float ret, int start, int slen) =>
    float m = 0.0
    for i = 0 to slen - 1
        m += nz(ret[start + i])
    m /= slen
    float cum = 0.0
    float cmax = -1e10
    float cmin = 1e10
    float ss = 0.0
    for i = 0 to slen - 1
        float d = nz(ret[start + i]) - m
        cum += d
        cmax := math.max(cmax, cum)
        cmin := math.min(cmin, cum)
        ss += d * d
    float r = cmax - cmin
    float s = math.sqrt(ss / slen)
    s > 0 and r > 0 ? r / s : 0.0
f_hurst() =>
    int s1 = hurstLen
    int s2 = math.round(hurstLen / 2)
    int s3 = math.round(hurstLen / 4)
    int s4 = math.round(hurstLen / 8)
    float sx = 0.0
    float sy = 0.0
    float sxy = 0.0
    float sx2 = 0.0
    int np = 0
    float rs1 = f_rs_seg(hurstRet, 0, s1)
    if rs1 > 0
        float lx = math.log(s1)
        float ly = math.log(rs1)
        sx += lx, sy += ly, sxy += lx * ly, sx2 += lx * lx, np += 1
    float rs2a = f_rs_seg(hurstRet, 0, s2)
    float rs2b = f_rs_seg(hurstRet, s2, s2)
    float rsSum2 = (rs2a > 0 ? rs2a : 0.0) + (rs2b > 0 ? rs2b : 0.0)
    int v2 = (rs2a > 0 ? 1 : 0) + (rs2b > 0 ? 1 : 0)
    if v2 > 0
        float lx = math.log(s2)
        float ly = math.log(rsSum2 / v2)
        sx += lx, sy += ly, sxy += lx * ly, sx2 += lx * lx, np += 1
    float rs3a = f_rs_seg(hurstRet, 0, s3)
    float rs3b = f_rs_seg(hurstRet, s3, s3)
    float rs3c = f_rs_seg(hurstRet, s3 * 2, s3)
    float rsSum3 = (rs3a > 0 ? rs3a : 0.0) + (rs3b > 0 ? rs3b : 0.0) + (rs3c > 0 ? rs3c : 0.0)
    int v3 = (rs3a > 0 ? 1 : 0) + (rs3b > 0 ? 1 : 0) + (rs3c > 0 ? 1 : 0)
    if v3 > 0
        float lx = math.log(s3)
        float ly = math.log(rsSum3 / v3)
        sx += lx, sy += ly, sxy += lx * ly, sx2 += lx * lx, np += 1
    float rs4a = f_rs_seg(hurstRet, 0, s4)
    float rs4b = f_rs_seg(hurstRet, s4, s4)
    float rs4c = f_rs_seg(hurstRet, s4 * 2, s4)
    float rs4d = f_rs_seg(hurstRet, s4 * 3, s4)
    float rs4e = f_rs_seg(hurstRet, s4 * 4, s4)
    float rs4f = f_rs_seg(hurstRet, s4 * 5, s4)
    float rs4g = f_rs_seg(hurstRet, s4 * 6, s4)
    float rs4h = f_rs_seg(hurstRet, s4 * 7, s4)
    float rsSum4 = (rs4a > 0 ? rs4a : 0.0) + (rs4b > 0 ? rs4b : 0.0) + (rs4c > 0 ? rs4c : 0.0) + (rs4d > 0 ? rs4d : 0.0) + (rs4e > 0 ? rs4e : 0.0) + (rs4f > 0 ? rs4f : 0.0) + (rs4g > 0 ? rs4g : 0.0) + (rs4h > 0 ? rs4h : 0.0)
    int v4 = (rs4a > 0 ? 1 : 0) + (rs4b > 0 ? 1 : 0) + (rs4c > 0 ? 1 : 0) + (rs4d > 0 ? 1 : 0) + (rs4e > 0 ? 1 : 0) + (rs4f > 0 ? 1 : 0) + (rs4g > 0 ? 1 : 0) + (rs4h > 0 ? 1 : 0)
    if v4 > 0
        float lx = math.log(s4)
        float ly = math.log(rsSum4 / v4)
        sx += lx, sy += ly, sxy += lx * ly, sx2 += lx * lx, np += 1
    float h = 0.5
    if np >= 2
        float denom = np * sx2 - sx * sx
        if math.abs(denom) > 1e-10
            h := (np * sxy - sx * sy) / denom
    math.max(0.0, math.min(1.0, h))
_hurst = f_hurst()
float hurst = _hurst
avgVol = ta.sma(volume, 20)
relVol = avgVol > 0 ? volume / avgVol : 1.0
volOk = relVol >= minRelVol
atrOk = atr >= minAtrPts
liquidityOk = volOk and atrOk
float csBody = math.abs(close - open)
float csUpperWk = high - math.max(close, open)
float csLowerWk = math.min(close, open) - low
float csRange = high - low
float csAvgBody = ta.sma(csBody, 14)
float csBodyToRange = (high - low) > 0 ? csBody / (high - low) : 0.0
bool csBullBar = close > open
bool csBearBar = close < open
bool csBullEngulf = csBullBar and csBearBar[1] and csBody > csAvgBody and close > open[1] and open <= close[1]
bool csBearEngulf = csBearBar and csBullBar[1] and csBody > csAvgBody and close < open[1] and open >= close[1]
bool csHammer = csLowerWk > csBody * 2.0 and csUpperWk < csBody * 0.3 and csBody < csAvgBody and csBody > 0
bool csShootSt = csUpperWk > csBody * 2.0 and csLowerWk < csBody * 0.3 and csBody < csAvgBody and csBody > 0
float csDojiFactor = time(timeframe.period, "0830-0930", "America/Chicago") != 0 ? 0.08 : time(timeframe.period, "1700-0100", "America/Chicago") != 0 ? 0.03 : time(timeframe.period, "1100-1300", "America/Chicago") != 0 ? 0.04 : 0.05
bool csDoji = csRange > 0 and csBody < csRange * csDojiFactor
bool inRTH = time(timeframe.period, "0700-1600", "America/Chicago") != 0
bool inAsia = time(timeframe.period, "1600-0100", "America/Chicago") != 0
bool inLondon = time(timeframe.period, "0100-0400", "America/Chicago") != 0
bool inPreMkt = time(timeframe.period, "0400-0830", "America/Chicago") != 0
bool inETH = not inRTH
bool isOpen = time(timeframe.period, "0830-0930", "America/Chicago") != 0
bool isLunch = time(timeframe.period, "1100-1300", "America/Chicago") != 0
bool isLast = time(timeframe.period, "1500-1600", "America/Chicago") != 0
bool isMorning = time(timeframe.period, "0930-1100", "America/Chicago") != 0
bool isAfternoon = time(timeframe.period, "1300-1500", "America/Chicago") != 0
atr := isOpen ? atrFast : isMorning ? atrFast : isLunch ? atrMed : isAfternoon ? atrMed : isLast ? atrFast : inPreMkt ? atrSlow : inLondon ? atrSlow : inAsia ? atrSlow : atrMed
markerBodyAtr = input.float(1.2, "Marker body min (× ATR)", minval=0.1, maxval=3.0, step=0.1, group="10 - Diag Toggles (Calibration)", tooltip="Body size threshold for near-miss markers. Higher = stricter (only conviction candles trigger arrows). Lower = more markers.")
bool _bullCndl = close > open and (close - open) >= markerBodyAtr * atr
bool _bearCndl = close < open and (open - close) >= markerBodyAtr * atr
float adfDy = close - close[1]
float adfX = nz(close[1])
float adfXY = adfDy * adfX
float adfX2 = adfX * adfX
float adfDy2 = adfDy * adfDy
float sDy30 = ta.sma(adfDy, 30) * 30, sX30 = ta.sma(adfX, 30) * 30
float sXY30 = ta.sma(adfXY, 30) * 30, sX230 = ta.sma(adfX2, 30) * 30, sDy230 = ta.sma(adfDy2, 30) * 30
float d30 = 30 * sX230 - sX30 * sX30
float g30 = d30 != 0 ? (30 * sXY30 - sX30 * sDy30) / d30 : 0.0
float a30 = (sDy30 - g30 * sX30) / 30
float sse30 = math.max(0, sDy230 - 2*a30*sDy30 - 2*g30*sXY30 + a30*a30*30 + 2*a30*g30*sX30 + g30*g30*sX230)
float se30 = d30 != 0 ? math.sqrt(math.max(0, sse30 / 28 * 30 / d30)) : 1.0
float adfStat30 = se30 > 0 ? g30 / se30 : 0.0
float sDy50 = ta.sma(adfDy, 50) * 50, sX50 = ta.sma(adfX, 50) * 50
float sXY50 = ta.sma(adfXY, 50) * 50, sX250 = ta.sma(adfX2, 50) * 50, sDy250 = ta.sma(adfDy2, 50) * 50
float d50 = 50 * sX250 - sX50 * sX50
float g50 = d50 != 0 ? (50 * sXY50 - sX50 * sDy50) / d50 : 0.0
float a50 = (sDy50 - g50 * sX50) / 50
float sse50 = math.max(0, sDy250 - 2*a50*sDy50 - 2*g50*sXY50 + a50*a50*50 + 2*a50*g50*sX50 + g50*g50*sX250)
float se50 = d50 != 0 ? math.sqrt(math.max(0, sse50 / 48 * 50 / d50)) : 1.0
float adfStat50 = se50 > 0 ? g50 / se50 : 0.0
float sDy80 = ta.sma(adfDy, 80) * 80, sX80 = ta.sma(adfX, 80) * 80
float sXY80 = ta.sma(adfXY, 80) * 80, sX280 = ta.sma(adfX2, 80) * 80, sDy280 = ta.sma(adfDy2, 80) * 80
float d80 = 80 * sX280 - sX80 * sX80
float g80 = d80 != 0 ? (80 * sXY80 - sX80 * sDy80) / d80 : 0.0
float a80 = (sDy80 - g80 * sX80) / 80
float sse80 = math.max(0, sDy280 - 2*a80*sDy80 - 2*g80*sXY80 + a80*a80*80 + 2*a80*g80*sX80 + g80*g80*sX280)
float se80 = d80 != 0 ? math.sqrt(math.max(0, sse80 / 78 * 80 / d80)) : 1.0
float adfStat80 = se80 > 0 ? g80 / se80 : 0.0
float adfStat = isOpen ? adfStat30 : isMorning ? adfStat30 : isLunch ? adfStat50 : isAfternoon ? adfStat50 : isLast ? adfStat30 : inPreMkt ? adfStat80 : inLondon ? adfStat80 : inAsia ? adfStat80 : adfStat50
float adfN = isOpen ? 30.0 : isMorning ? 30.0 : isLunch ? 50.0 : isAfternoon ? 50.0 : isLast ? 30.0 : inPreMkt ? 80.0 : inLondon ? 80.0 : inAsia ? 80.0 : 50.0
float adfCrit95 = -2.86 - 2.74 / adfN
bool adfMeanRevert = adfStat < adfCrit95
bool adfTrending = adfStat > -1.0
bool hurstPersist = hurst > 0.55
bool hurstRevert = hurst < 0.45
float _aerERSma50 = ta.sma(aerER, 50)
float _aerERStd50 = ta.stdev(aerER, 50)
float _aerERZ = _aerERStd50 > 0.0 ? (aerER - _aerERSma50) / _aerERStd50 : 0.0
float _retPct          = close[1] > 0.0 ? (close - close[1]) / close[1] : 0.0
float _realizedVol     = ta.stdev(_retPct, 20)
float _realizedVolBase = ta.sma(_realizedVol, 100)
float _realizedVolRel  = _realizedVolBase > 0.0 ? _realizedVol / _realizedVolBase : 1.0
f_dyn(float b, float sO, float sL, float sA, float rT, float rC, float aH, float aL, float lo, float hi) =>
    math.max(lo, math.min(hi, b + (isOpen ? sO : isMorning ? -sO * 0.3 : isLunch ? sL : isAfternoon ? sL * 0.5 : isLast ? sO * 0.3 : inPreMkt ? sA : inLondon ? sA * 0.8 : inAsia ? sA : 0.0) + (aerTrending ? rT : aerChoppy ? rC : 0.0) + (adx >= 30 ? aH : adx < 20 ? aL : 0.0)))
_mfiWtHi = f_dyn(1.5, 0.3, -0.25, -0.3, 0.15, -0.1, 0.15, -0.1, 1.0, 2.2)
f_mfiWtLo() =>
    base = 1.0
    sessAdj = isOpen ? 0.2 : isMorning ? -0.06 : isLunch ? -0.15 : isAfternoon ? -0.075 : isLast ? 0.06 : inPreMkt ? -0.2 : inLondon ? -0.16 : inAsia ? -0.2 : 0.0
    regAdj = aerTrending ? 0.1 : aerChoppy ? -0.1 : 0.0
    math.max(0.6, math.min(1.5, base + sessAdj + regAdj))
_mfiWtLo = f_mfiWtLo()
_volatHi = f_dyn(1.30, 0.10, -0.05, -0.05, 0.05, -0.03, 0.05, -0.03, 1.15, 1.50)
_volatLo = f_dyn(0.70, -0.05, 0.05, 0.05, -0.03, 0.05, -0.03, 0.05, 0.55, 0.85)
f_dynV(float b, float sO, float sL, float sA, float rT, float rC, float aH, float aL, float vH, float vL, float uH, float uL, float lo, float hi) =>
    sessVal = isOpen ? sO : isMorning ? -sO * 0.3 : isLunch ? sL : isAfternoon ? sL * 0.5 : isLast ? sO * 0.3 : inPreMkt ? sA : inLondon ? sA * 0.8 : inAsia ? sA : 0.0
    regVal = aerTrending ? rT : aerChoppy ? rC : 0.0
    adxVal = adx >= 30 ? aH : adx < 20 ? aL : 0.0
    volatVal = atr > aerMeanATR * _volatHi ? vH : atr < aerMeanATR * _volatLo ? vL : 0.0
    volVal = relVol >= _mfiWtHi ? uH : relVol < _mfiWtLo ? uL : 0.0
    math.max(lo, math.min(hi, b + sessVal + regVal + adxVal + volatVal + volVal))
f_dynV35(float b, float sO, float sL, float sA, float rT, float rC, float aH, float aL, float vH, float vL, float uH, float uL, float lo, float hi) =>
    sessVal = isOpen ? sO : isMorning ? -sO * 0.3 : isLunch ? sL : isAfternoon ? sL * 0.5 : isLast ? sO * 0.3 : inPreMkt ? sA : inLondon ? sA * 0.8 : inAsia ? sA : 0.0
    regVal = aerTrending ? rT : aerChoppy ? rC : 0.0
    adxVal = adx >= 35 ? aH : adx < 20 ? aL : 0.0
    volatVal = atr > aerMeanATR * _volatHi ? vH : atr < aerMeanATR * _volatLo ? vL : 0.0
    volVal = relVol >= _mfiWtHi ? uH : relVol < _mfiWtLo ? uL : 0.0
    math.max(lo, math.min(hi, b + sessVal + regVal + adxVal + volatVal + volVal))
_csCommitMin = f_dynV(0.30, 0.15, -0.05, -0.10, 0.10, 0.05, 0.10, -0.05, 0.05, -0.03, -0.05, 0.05, 0.15, 0.55)
_closePosMin = f_dynV(0.60, 0.10, -0.05, -0.05, 0.05, -0.03, 0.05, -0.03, 0.05, -0.03, -0.03, 0.03, 0.50, 0.85)
bool csBullCommit = csBullBar and (close - low) >= (high - low) * _closePosMin and csBody > csAvgBody * _csCommitMin
bool csBearCommit = csBearBar and (high - close) >= (high - low) * _closePosMin and csBody > csAvgBody * _csCommitMin
_reMargin = f_dynV(0.10, 0.05, -0.03, -0.02, 0.05, -0.02, 0.05, -0.02, 0.05, -0.02, -0.03, 0.05, 0.05, 0.25)
float povDist = not na(povLevel) ? math.abs(close - povLevel) / atr : 99.0
bool nearPoV = povDist < (isOpen ? 0.8 : isMorning ? 0.9 : isLunch ? 1.2 : isAfternoon ? 1.0 : isLast ? 0.8 : inPreMkt ? 1.5 : inLondon ? 1.3 : inAsia ? 1.5 : 1.0)
f_vrzVolMult() =>
    base = 1.8
    sessAdj = isOpen ? 0.5 : isMorning ? -0.15 : isLunch ? -0.3 : isAfternoon ? -0.15 : isLast ? 0.2 : inPreMkt ? 0.3 : inLondon ? 0.24 : inAsia ? 0.3 : 0.0
    regAdj = aerTrending ? 0.2 : aerChoppy ? -0.2 : 0.0
    adxAdj = adx >= 30 ? 0.2 : adx < 20 ? -0.15 : 0.0
    math.max(1.2, math.min(2.8, base + sessAdj + regAdj + adxAdj))
_vrzVolMult = f_vrzVolMult()
bool isVrzBar = volume > avgVol * _vrzVolMult and atr > 0
var float[] vrzHighs = array.new_float(0)
var float[] vrzLows = array.new_float(0)
var float[] vrzMids = array.new_float(0)
if isVrzBar
    array.push(vrzHighs, high)
    array.push(vrzLows, low)
    array.push(vrzMids, (high + low) / 2.0)
    if array.size(vrzHighs) > 3
        array.shift(vrzHighs)
        array.shift(vrzLows)
        array.shift(vrzMids)
float vrzMid = array.size(vrzMids) > 0 ? array.get(vrzMids, array.size(vrzMids) - 1) : na
float vrzBias = not na(vrzMid) ? (close > vrzMid ? 1.0 : close < vrzMid ? -1.0 : 0.0) : 0.0
f_rsiBullFloor() =>
    base = 55.0
    sessAdj = isOpen ? -3.0 : isMorning ? 0.9 : isLunch ? 2.0 : isAfternoon ? 1.0 : isLast ? -0.9 : inPreMkt ? 3.0 : inLondon ? 2.4 : inAsia ? 3.0 : 0.0
    adxAdj = adx >= 30 ? -3.0 : adx < 20 ? 3.0 : 0.0
    regAdj = aerUptrend ? -2.0 : aerChoppy ? 3.0 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 1.0 : atr < aerMeanATR * _volatLo ? -0.5 : 0.0
    volAdj = relVol >= _mfiWtHi ? -1.5 : relVol < _mfiWtLo ? 1.5 : 0.0
    math.max(48.0, math.min(62.0, base + sessAdj + adxAdj + regAdj + volatAdj + volAdj))
_rsiBullFloor = f_rsiBullFloor()
f_rsiBullCap() =>
    base = 78.0
    sessAdj = isOpen ? 4.0 : isMorning ? -1.2 : isLunch ? -2.0 : isAfternoon ? -1.0 : isLast ? 1.2 : inPreMkt ? -3.0 : inLondon ? -2.4 : inAsia ? -3.0 : 0.0
    adxAdj = adx >= 35 ? 4.0 : adx >= 25 ? 2.0 : adx < 20 ? -3.0 : 0.0
    regAdj = aerUptrend ? 3.0 : aerChoppy ? -3.0 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? -1.0 : atr < aerMeanATR * _volatLo ? 0.5 : 0.0
    volAdj = relVol >= _mfiWtHi ? 1.5 : relVol < _mfiWtLo ? -1.5 : 0.0
    math.max(72.0, math.min(86.0, base + sessAdj + adxAdj + regAdj + volatAdj + volAdj))
_rsiBullCap = f_rsiBullCap()
f_rsiBearCap() =>
    base = 43.0
    sessAdj = isOpen ? 3.0 : isMorning ? -0.9 : isLunch ? -2.0 : isAfternoon ? -1.0 : isLast ? 0.9 : inPreMkt ? -3.0 : inLondon ? -2.4 : inAsia ? -3.0 : 0.0
    adxAdj = adx >= 30 ? 3.0 : adx < 20 ? -3.0 : 0.0
    regAdj = aerDowntrend ? 3.0 : aerChoppy ? -3.0 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? -1.0 : atr < aerMeanATR * _volatLo ? 0.5 : 0.0
    volAdj = relVol >= _mfiWtHi ? 1.5 : relVol < _mfiWtLo ? -1.5 : 0.0
    math.max(36.0, math.min(50.0, base + sessAdj + adxAdj + regAdj + volatAdj + volAdj))
_rsiBearCap = f_rsiBearCap()
f_rsiBearFloor() =>
    base = 22.0
    sessAdj = isOpen ? -4.0 : isMorning ? 1.2 : isLunch ? 2.0 : isAfternoon ? 1.0 : isLast ? -1.2 : inPreMkt ? 3.0 : inLondon ? 2.4 : inAsia ? 3.0 : 0.0
    adxAdj = adx >= 35 ? -4.0 : adx >= 25 ? -2.0 : adx < 20 ? 3.0 : 0.0
    regAdj = aerDowntrend ? -3.0 : aerChoppy ? 3.0 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 1.0 : atr < aerMeanATR * _volatLo ? -0.5 : 0.0
    volAdj = relVol >= _mfiWtHi ? -1.5 : relVol < _mfiWtLo ? 1.5 : 0.0
    math.max(14.0, math.min(28.0, base + sessAdj + adxAdj + regAdj + volatAdj + volAdj))
_rsiBearFloor = f_rsiBearFloor()
rsiBull = rsiRaw >= _rsiBullFloor and rsiRaw < _rsiBullCap
rsiBear = rsiRaw <= _rsiBearCap and rsiRaw > _rsiBearFloor
f_rsSpreadThresh() =>
    base = 0.1
    sessAdj = isOpen ? -0.03 : isMorning ? 0.009 : isLunch ? 0.03 : isAfternoon ? 0.015 : isLast ? -0.009 : inPreMkt ? 0.04 : inLondon ? 0.032 : inAsia ? 0.04 : 0.0
    regAdj = aerTrending ? -0.02 : aerChoppy ? 0.02 : 0.0
    adxAdj = adx >= 30 ? -0.02 : adx < 20 ? 0.02 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? -0.015 : atr < aerMeanATR * _volatLo ? 0.02 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.015 : relVol < _mfiWtLo ? 0.02 : 0.0
    math.max(0.04, math.min(0.20, base + sessAdj + regAdj + adxAdj + volatAdj + volAdj))
_rsSpreadThresh = f_rsSpreadThresh()
rsWeak = rsSpread < -_rsSpreadThresh
rsStrong = rsSpread > _rsSpreadThresh
f_divVolBear() =>
    base = 1.5
    sessAdj = isOpen ? 0.3 : isMorning ? -0.09 : isLunch ? -0.2 : isAfternoon ? -0.1 : isLast ? 0.09 : inPreMkt ? -0.3 : inLondon ? -0.24 : inAsia ? -0.3 : 0.0
    regAdj = aerTrending ? 0.15 : aerChoppy ? -0.1 : 0.0
    adxAdj = adx >= 30 ? 0.15 : adx < 20 ? -0.1 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.15 : atr < aerMeanATR * _volatLo ? -0.1 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.1 : relVol < _mfiWtLo ? 0.15 : 0.0
    math.max(0.8, math.min(2.2, base + sessAdj + regAdj + adxAdj + volatAdj + volAdj))
_divVolBear = f_divVolBear()
f_divVolBull() =>
    base = 1.0
    sessAdj = isOpen ? 0.2 : isMorning ? -0.06 : isLunch ? -0.15 : isAfternoon ? -0.075 : isLast ? 0.06 : inPreMkt ? -0.2 : inLondon ? -0.16 : inAsia ? -0.2 : 0.0
    regAdj = aerTrending ? 0.1 : aerChoppy ? -0.1 : 0.0
    adxAdj = adx >= 30 ? 0.1 : adx < 20 ? -0.1 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.1 : atr < aerMeanATR * _volatLo ? -0.07 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.07 : relVol < _mfiWtLo ? 0.1 : 0.0
    math.max(0.6, math.min(1.8, base + sessAdj + regAdj + adxAdj + volatAdj + volAdj))
_divVolBull = f_divVolBull()
_trapFpRatio = f_dyn(1.3, 0.3, -0.15, -0.2, 0.15, -0.1, 0.15, -0.1, 1.0, 2.0)
_bosVolThresh = f_dyn(1.3, 0.3, -0.2, -0.3, 0.1, -0.1, 0.15, -0.15, 0.9, 2.0)
f_oteSwingMin() =>
    base = 2.0
    sessAdj = isOpen ? -0.2 : isMorning ? 0.0 : isLunch ? 0.4 : isAfternoon ? 0.1 : isLast ? 0.0 : inPreMkt ? 0.3 : inLondon ? 0.2 : inAsia ? 0.3 : 0.0
    regAdj = aerTrending ? -0.2 : aerChoppy ? 0.4 : 0.0
    adxAdj = adx >= 30 ? -0.2 : adx < 20 ? 0.3 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.2 : atr < aerMeanATR * _volatLo ? -0.1 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.1 : relVol < _mfiWtLo ? 0.2 : 0.0
    hurstAdj = hurstPersist ? -0.1 : hurstRevert ? 0.2 : 0.0
    math.max(1.5, math.min(3.0, base + sessAdj + regAdj + adxAdj + volatAdj + volAdj + hurstAdj))
_oteSwingMin = f_oteSwingMin()
_exitVolClimax = f_dyn(2.0, 0.5, -0.3, -0.4, 0.2, -0.2, 0.2, -0.2, 1.3, 3.0)
f_confVolBounce() =>
    base = 1.2
    sessAdj = isOpen ? 0.3 : isMorning ? -0.09 : isLunch ? -0.2 : isAfternoon ? -0.1 : isLast ? 0.09 : inPreMkt ? -0.2 : inLondon ? -0.16 : inAsia ? -0.2 : 0.0
    regAdj = aerTrending ? 0.1 : aerChoppy ? -0.1 : 0.0
    math.max(0.8, math.min(1.8, base + sessAdj + regAdj))
_confVolBounce = f_confVolBounce()
_mfiExhBuyThresh = f_dynV35(80.0, 3.0, -2.0, -3.0, 2.0, -2.0, 2.0, -2.0, 1.0, -0.5, -2.0, 2.0, 72.0, 90.0)
_mfiExhSelThresh = f_dynV35(20.0, -3.0, 2.0, 3.0, -2.0, 2.0, -2.0, 2.0, -1.0, 0.5, 2.0, -2.0, 10.0, 28.0)
f_vixRiseThresh() =>
    base = 1.01
    sessAdj = isOpen ? 0.02 : isMorning ? -0.006 : isLunch ? -0.005 : isAfternoon ? -0.0025 : isLast ? 0.006 : inPreMkt ? -0.005 : inLondon ? -0.004 : inAsia ? -0.005 : 0.0
    regAdj = aerTrending ? 0.005 : aerChoppy ? -0.005 : 0.0
    math.max(1.005, math.min(1.05, base + sessAdj + regAdj))
_vixRiseThresh = f_vixRiseThresh()
f_vixFallThresh() =>
    base = 0.99
    sessAdj = isOpen ? -0.02 : isMorning ? 0.006 : isLunch ? 0.005 : isAfternoon ? 0.0025 : isLast ? -0.006 : inPreMkt ? 0.005 : inLondon ? 0.004 : inAsia ? 0.005 : 0.0
    regAdj = aerTrending ? -0.005 : aerChoppy ? 0.005 : 0.0
    math.max(0.95, math.min(0.995, base + sessAdj + regAdj))
_vixFallThresh = f_vixFallThresh()
_bosBreakMult = f_dynV(0.5, 0.15, -0.1, -0.1, 0.1, -0.05, 0.1, -0.05, 0.05, -0.03, -0.05, 0.05, 0.25, 0.8)
f_bosHoldBuffer() =>
    base = 0.0
    sessAdj = isOpen ? -0.02 : isMorning ? 0.0 : isLunch ? 0.05 : isAfternoon ? 0.02 : isLast ? 0.0 : inPreMkt ? 0.05 : inLondon ? 0.04 : inAsia ? 0.05 : 0.0
    regAdj = aerTrending ? -0.02 : aerChoppy ? 0.05 : 0.0
    adxAdj = adx >= 35 ? -0.02 : adx >= 30 ? -0.01 : adx < 15 ? 0.07 : adx < 20 ? 0.05 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.03 : atr < aerMeanATR * _volatLo ? -0.01 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.02 : relVol < _mfiWtLo ? 0.03 : 0.0
    hurstAdj = hurstPersist ? -0.02 : hurstRevert ? 0.04 : 0.0
    math.max(0.0, math.min(0.15, base + sessAdj + regAdj + adxAdj + volatAdj + volAdj + hurstAdj))
_bosHoldBuffer = f_bosHoldBuffer()
var float rthHigh = na
var float rthLow = na
var float rthDevH = na
var float rthDevL = na
if inRTH
    if not inRTH[1]
        rthDevH := high
        rthDevL := low
    else
        rthDevH := math.max(nz(rthDevH, high), high)
        rthDevL := math.min(nz(rthDevL, low), low)
if not inRTH and inRTH[1]
    rthHigh := rthDevH
    rthLow := rthDevL
var float asiaHigh = na
var float asiaLow = na
if inAsia
    if not inAsia[1]
        asiaHigh := high
        asiaLow := low
    else
        asiaHigh := math.max(nz(asiaHigh, high), high)
        asiaLow := math.min(nz(asiaLow, low), low)
var float londonHigh = na
var float londonLow = na
if inLondon
    if not inLondon[1]
        londonHigh := high
        londonLow := low
    else
        londonHigh := math.max(nz(londonHigh, high), high)
        londonLow := math.min(nz(londonLow, low), low)
[h5f, h5s, h5c, h5mid] = request.security(syminfo.tickerid, "5",
    [ta.ema(close[1], 9), ta.ema(close[1], 21), close[1], (ta.highest(high[1], 20) + ta.lowest(low[1], 20)) / 2],
    lookahead=barmerge.lookahead_on)
[h15f, h15s, h15c, h15mid] = request.security(syminfo.tickerid, "15",
    [ta.ema(close[1], 9), ta.ema(close[1], 21), close[1], (ta.highest(high[1], 20) + ta.lowest(low[1], 20)) / 2],
    lookahead=barmerge.lookahead_on)
[h60f, h60s, h60c, h60mid] = request.security(syminfo.tickerid, "60",
    [ta.ema(close[1], 9), ta.ema(close[1], 21), close[1], (ta.highest(high[1], 20) + ta.lowest(low[1], 20)) / 2],
    lookahead=barmerge.lookahead_on)
[h4f, h4s] = request.security(syminfo.tickerid, "240",
    [ta.ema(close[1], 9), ta.ema(close[1], 21)],
    lookahead=barmerge.lookahead_on)
h4sep = math.abs(h4f - h4s) / close * 100
h4notBear = h4f > h4s or h4sep < 0.5
h4notBull = h4f < h4s or h4sep < 0.5
htfBull = h15f > h15s and h60f > h60s and h4notBear
htfBear = h15f < h15s and h60f < h60s and h4notBull
float _h4Sep = na(h4f) or na(h4s) ? 0.0 : (h4f - h4s) / h4s
float h4Vote = math.max(-2.0, math.min(2.0, _h4Sep * 100.0))
float _dailyDev = na(dEma9) or na(dEma21) ? 0.0 : (dEma9 - dEma21) / dEma21
float dailyVote = math.max(-2.0, math.min(2.0, _dailyDev * 200.0))
f_tfVote(float c, float fEma, float sEma, float mid) =>
    v1 = c > sEma ? 0.5 : c < sEma ? -0.5 : 0.0
    v2 = fEma > sEma ? 1.0 : fEma < sEma ? -1.0 : 0.0
    v3 = c > mid ? 0.5 : c < mid ? -0.5 : 0.0
    v1 + v2 + v3
float h5Vote = f_tfVote(h5c, h5f, h5s, h5mid)
float h15Vote = f_tfVote(h15c, h15f, h15s, h15mid)
float h60Vote = f_tfVote(h60c, h60f, h60s, h60mid)
float htfConfScore = h5Vote * 1.0 + h15Vote * 1.5 + h60Vote * 2.0 + h4Vote * 1.0 + dailyVote * 1.5
float htfDivPenalty = 0.0
if h5Vote <= -1.0 and h15Vote >= 1.0 and h60Vote >= 1.0
    htfDivPenalty := -2.0
if h5Vote >= 1.0 and h15Vote <= -1.0 and h60Vote <= -1.0
    htfDivPenalty := 2.0
htfConfScore := htfConfScore + htfDivPenalty
f_obVolThresh() =>
    base = 1.2
    sessAdj = isOpen ? 0.3 : isMorning ? -0.09 : isLunch ? -0.15 : isAfternoon ? -0.075 : isLast ? 0.09 : inPreMkt ? -0.2 : inLondon ? -0.16 : inAsia ? -0.2 : 0.0
    regAdj = aerTrending ? 0.1 : aerChoppy ? -0.1 : 0.0
    adxAdj = adx >= 30 ? 0.15 : adx < 20 ? -0.10 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.10 : atr < aerMeanATR * _volatLo ? -0.05 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.10 : relVol < _mfiWtLo ? 0.15 : 0.0
    math.max(0.8, math.min(1.8, base + sessAdj + regAdj + adxAdj + volatAdj + volAdj))
_obVolThresh = f_obVolThresh()
trendUp = htfBull
trendDown = htfBear
var float orbHigh = na
var float orbLow = na
var bool orbLocked = false
var float pmHigh = na
var float pmLow = na
var float pmMid = na
var float orbMid = na
isNewDay = ta.change(dayofmonth(time)) != 0
if isNewDay
    orbHigh := na
    orbLow := na
    orbMid := na
    orbLocked := false
    pmHigh := na
    pmLow := na
    pmMid := na
    onHigh := na
    onLow := na
inPreMarket = time(timeframe.period, "0300-0830", "America/Chicago") != 0
inORBBuild = time(timeframe.period, "0830-0845", "America/Chicago") != 0
inOvernight = time(timeframe.period, "1500-0830", "America/Chicago") != 0
if inPreMarket
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow := na(pmLow) ? low : math.min(pmLow, low)
    pmMid := not na(pmHigh) and not na(pmLow) ? (pmHigh + pmLow) / 2.0 : na
if inOvernight
    onHigh := na(onHigh) ? high : math.max(onHigh, high)
    onLow := na(onLow) ? low : math.min(onLow, low)
if inORBBuild and not orbLocked
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)
var line  orbHighLine = na
var line  orbLowLine  = na
var label orbHighLbl  = na
var label orbLowLbl   = na
if time(timeframe.period, "0845-0846", "America/Chicago") != 0
    orbLocked := true
    orbMid := not na(orbHigh) and not na(orbLow) ? (orbHigh + orbLow) / 2.0 : na
    if showORBLines and not na(orbHigh) and not na(orbLow)
        line.delete(orbHighLine)
        line.delete(orbLowLine)
        label.delete(orbHighLbl)
        label.delete(orbLowLbl)
        orbHighLine := line.new(bar_index, orbHigh, bar_index + 1, orbHigh, color=color.new(color.aqua, 30), width=1, style=line.style_solid)
        orbLowLine  := line.new(bar_index, orbLow,  bar_index + 1, orbLow,  color=color.new(color.aqua, 30), width=1, style=line.style_solid)
        orbHighLbl  := label.new(bar_index + 1, orbHigh, "ORB H", color=color.new(color.white, 100), textcolor=color.new(color.aqua, 0), style=label.style_label_left, size=size.small)
        orbLowLbl   := label.new(bar_index + 1, orbLow,  "ORB L", color=color.new(color.white, 100), textcolor=color.new(color.aqua, 0), style=label.style_label_left, size=size.small)
bool _orbExtendOk = orbLocked and not na(orbHighLine) and (isOpen or isMorning or isLunch or isAfternoon)
if _orbExtendOk
    line.set_x2(orbHighLine, bar_index + 1)
    line.set_x2(orbLowLine,  bar_index + 1)
    label.set_xy(orbHighLbl, bar_index + 1, orbHigh)
    label.set_xy(orbLowLbl,  bar_index + 1, orbLow)
var bool _orbBullBrokenForBOS = false
var bool _orbBearBrokenForBOS = false
if isNewDay
    _orbBullBrokenForBOS := false
    _orbBearBrokenForBOS := false
f_retestProx() =>
    base = 0.002
    sessAdj = isOpen ? 0.001 : isMorning ? -0.0003 : isLunch ? 0.0 : isAfternoon ? 0.0 : isLast ? 0.0003 : inPreMkt ? 0.0 : inLondon ? 0.0 : inAsia ? 0.0 : 0.0
    regimeAdj = aerTrending ? 0.0005 : aerChoppy ? -0.0005 : 0.0
    math.max(0.001, math.min(0.004, base + sessAdj + regimeAdj))
_retestProx = f_retestProx()
float trndRefHigh = orbLocked and not na(orbHigh) ? orbHigh : rthHigh
float trndRefLow  = orbLocked and not na(orbLow)  ? orbLow  : rthLow
candleBody = math.abs(close - open)
candleRange = high - low
cleanCandle = candleRange > atr * 0.3 and candleBody > candleRange * 0.3
bool rejAboveRefShort = not na(trndRefHigh) and high > trndRefHigh and close < trndRefHigh
bool rejBelowRefLong  = not na(trndRefLow)  and low  < trndRefLow  and close > trndRefLow
var bool stratBFiredAboveRefLow  = false
var bool stratBFiredBelowRefHigh = false
bool _stratBLongEpisodeActive  = not na(trndRefLow)  and close > trndRefLow
bool _stratBShortEpisodeActive = not na(trndRefHigh) and close < trndRefHigh
if not _stratBLongEpisodeActive
    stratBFiredAboveRefLow := false
if not _stratBShortEpisodeActive
    stratBFiredBelowRefHigh := false
if isNewDay
    stratBFiredAboveRefLow := false
    stratBFiredBelowRefHigh := false
bool _stratBLongEligible  = rejBelowRefLong  and not stratBFiredAboveRefLow
bool _stratBShortEligible = rejAboveRefShort and not stratBFiredBelowRefHigh
stratB_Long  = _stratBLongEligible  and cleanCandle and not csDoji
stratB_Short = _stratBShortEligible and cleanCandle and not csDoji
if stratB_Long
    stratBFiredAboveRefLow := true
if stratB_Short
    stratBFiredBelowRefHigh := true
fvgMinSize = atr * fvgMinPct
bullFVG = useFVG and low > high[2] and (low - high[2]) >= fvgMinSize
bearFVG = useFVG and high < low[2] and (low[2] - high) >= fvgMinSize
bool _fvgBullDraw = bullFVG and (low - high[2]) >= atr * 0.6 and relVol >= 1.5
bool _fvgBearDraw = bearFVG and (low[2] - high) >= atr * 0.6 and relVol >= 1.5
var array<box> fvgBoxes = array.new<box>()
var box lastBullFvgBox = na
var box lastBearFvgBox = na
if array.size(fvgBoxes) > 300
    box.delete(array.shift(fvgBoxes))
if _fvgBullDraw
    color fvgBullBg = color.new(color.green, 70)
    lastBullFvgBox := box.new(bar_index - 2, low, bar_index + 1, high[2], border_color=color.new(color.green, 60), bgcolor=fvgBullBg, border_width=1)
    array.push(fvgBoxes, lastBullFvgBox)
if _fvgBearDraw
    color fvgBearBg = color.new(color.red, 70)
    lastBearFvgBox := box.new(bar_index - 2, low[2], bar_index + 1, high, border_color=color.new(color.red, 60), bgcolor=fvgBearBg, border_width=1)
    array.push(fvgBoxes, lastBearFvgBox)
if not na(lastBullFvgBox) and fvgBullFill < 1.0
    box.set_right(lastBullFvgBox, bar_index + 1)
if not na(lastBearFvgBox) and fvgBearFill < 1.0
    box.set_right(lastBearFvgBox, bar_index + 1)
if bullFVG
    fvgBullHi := low
    fvgBullLo := high[2]
    fvgBullFill := 0.0
    fvgBullAge := 0
    fvgBullTouch := 0
if bearFVG
    fvgBearHi := low[2]
    fvgBearLo := high
    fvgBearFill := 0.0
    fvgBearAge := 0
    fvgBearTouch := 0
if not na(fvgBullHi) and not na(fvgBullLo)
    fvgBullAge += 1
    fvgBullSize = fvgBullHi - fvgBullLo
    if fvgBullSize > 0 and low <= fvgBullHi and low >= fvgBullLo
        fvgBullFill := math.max(fvgBullFill, (fvgBullHi - low) / fvgBullSize)
        fvgBullTouch += 1
if not na(fvgBearHi) and not na(fvgBearLo)
    fvgBearAge += 1
    fvgBearSize = fvgBearHi - fvgBearLo
    if fvgBearSize > 0 and high >= fvgBearLo and high <= fvgBearHi
        fvgBearFill := math.max(fvgBearFill, (high - fvgBearLo) / fvgBearSize)
        fvgBearTouch += 1
f_fvgMaxAge() =>
    isOpen ? 80 : isMorning ? 100 : isLunch ? 280 : isAfternoon ? 200 : inAsia ? 150 : aerTrending ? 120 : 200
_fvgMaxAge = f_fvgMaxAge()
f_fvgMaxFill() =>
    aerTrending ? 0.80 : aerChoppy ? 0.65 : 0.75
_fvgMaxFill = f_fvgMaxFill()
f_fvgMaxTouch() =>
    aerTrending ? 5 : aerChoppy ? 3 : 4
_fvgMaxTouch = f_fvgMaxTouch()
int fvgMaxAge = _fvgMaxAge
float fvgMaxFill = _fvgMaxFill
int fvgMaxTouch = _fvgMaxTouch
if not na(fvgBullHi) and (fvgBullAge > fvgMaxAge or fvgBullFill > fvgMaxFill or fvgBullTouch > fvgMaxTouch)
    fvgBullHi := na
    fvgBullLo := na
if not na(fvgBearLo) and (fvgBearAge > fvgMaxAge or fvgBearFill > fvgMaxFill or fvgBearTouch > fvgMaxTouch)
    fvgBearHi := na
    fvgBearLo := na
f_updateFvgViolation(bool prev, float hi, float lo, bool isNewFvg, bool isLong) =>
    if isNewFvg or na(hi)
        false
    else if not na(hi) and (isLong ? close < lo : close > hi)
        true
    else
        prev
var bool fvgBullViolated = false
var bool fvgBearViolated = false
fvgBullViolated := f_updateFvgViolation(fvgBullViolated, fvgBullHi, fvgBullLo, bullFVG, true)
fvgBearViolated := f_updateFvgViolation(fvgBearViolated, fvgBearHi, fvgBearLo, bearFVG, false)
float fvgAgeDecay = isOpen ? 0.004 : isMorning ? 0.0035 : isLunch ? 0.001 : isAfternoon ? 0.002 : inAsia ? 0.003 : aerTrending ? 0.003 : 0.002
float fvgTouchPenalty = aerTrending ? 0.12 : aerChoppy ? 0.20 : 0.15
float fvgBullQuality = not na(fvgBullHi) ? math.max(0.0, 1.0 - fvgBullFill - fvgBullTouch * fvgTouchPenalty - fvgBullAge * fvgAgeDecay) : 0.0
float fvgBearQuality = not na(fvgBearHi) ? math.max(0.0, 1.0 - fvgBearFill - fvgBearTouch * fvgTouchPenalty - fvgBearAge * fvgAgeDecay) : 0.0
float fvgQualityGate = isOpen ? 0.20 : isMorning ? 0.25 : isLunch ? 0.40 : isAfternoon ? 0.30 : inAsia ? 0.35 : aerTrending and adx >= 25 ? 0.25 : aerChoppy ? 0.40 : 0.30
swingHigh = sqzHL
swingLow = sqzLL
swingRange = swingHigh - swingLow
inOTELong = useOTE and close >= (swingHigh - swingRange * 0.79) and close <= (swingHigh - swingRange * 0.50)
inOTEShort = useOTE and close <= (swingLow + swingRange * 0.79) and close >= (swingLow + swingRange * 0.50)
oteLongHi = swingHigh - swingRange * 0.62
oteLongLo = swingHigh - swingRange * 0.79
oteShortHi = swingLow + swingRange * 0.79
oteShortLo = swingLow + swingRange * 0.62
float oteMidLong = (oteLongHi + oteLongLo) / 2.0
float oteMidShort = (oteShortHi + oteShortLo) / 2.0
var box   oteBox = na
var label oteLbl = na
var float prevOteHi = na
var float prevOteLo = na
var int   oteAnchorBar = na
if showOTEBox and useOTE
    bool _trendDownNow = trendDown and swingRange > atr * _oteSwingMin
    bool _trendUpNow   = trendUp   and swingRange > atr * _oteSwingMin
    float curHi = _trendDownNow ? oteShortHi : _trendUpNow ? oteLongHi : na
    float curLo = _trendDownNow ? oteShortLo : _trendUpNow ? oteLongLo : na
    bool zoneChanged = curHi != prevOteHi or curLo != prevOteLo
    if zoneChanged and not na(curHi) and not na(curLo)
        box.delete(oteBox)
        label.delete(oteLbl)
        oteAnchorBar := bar_index
        oteBox := box.new(bar_index, curHi, bar_index + 30, curLo, border_color=color.new(#FFB3BA, 70), bgcolor=color.new(#FFB3BA, 92), border_width=1)
        oteLbl := label.new(bar_index, curHi, "OTE", color=color.new(color.white, 100), textcolor=color.new(#FFB3BA, 0), style=label.style_label_left, size=size.normal)
        prevOteHi := curHi
        prevOteLo := curLo
    else if not na(oteBox) and not na(oteAnchorBar)
        box.set_right(oteBox, bar_index + 30)
var g8 = "8 - Order Blocks"
obLookback = input.int(20, "OB Lookback", group=g8)
obMinMove = input.float(1.5, "OB Min Move (xATR)", group=g8)
obMaxBoxes = input.int(5, "Max OB Boxes", group=g8)
useOB = input.bool(true, "Show Order Blocks", group=g8)
useOBTrade = input.bool(true, "OB as Trade Signal", group=g8)
obMinRules = input.int(4, "OB Min Rules (trade)", group=g8, minval=0, maxval=10)
obDisplayMinScore = input.int(3, "OB Display Quality Floor", group=g8, minval=0, maxval=10)
var g9 = "9 - Sweep Clusters"
showSweepClusters    = input.bool(true,  "Show Sweep Cluster Zones",    group=g9)
sweepClusterMinQual  = input.float(2.5, "  Cluster Quality Floor",      group=g9, minval=0.0, maxval=5.0, step=0.25)
var gV  = "11 - Diag Toggles (Calibration)"
showConfInLabel = input.bool(false, "Show conf in label", group=gV, tooltip="When ON, fire labels include the trade's confidence value. Used for calibration to find empirical max conf per trade.")
showOutcomeOnLabel = input.bool(false, "Show outcome on labels", group=gV, tooltip="When ON, fire labels are appended with outcome (TP/SL ± pts / bars / MAE %) when the trade resolves. MAE is normalized to % of SL distance: 0% = clean win never threatened, 100% = stopped out.")
var array<box> obBoxes = array.new<box>()
var array<label> obLabels = array.new<label>()
if array.size(obBoxes) > obMaxBoxes * 2
    box.delete(array.shift(obBoxes))
    label.delete(array.shift(obLabels))
bool obBullTradeFire = false
bool obBearTradeFire = false
float obBullSl = na
float obBearSl = na
f_crowdScore(float lvl) =>
    if na(lvl) or atr <= 0.0
        0.0
    else
        score = 0.0
        d100 = math.abs(lvl - math.round(lvl / 100.0) * 100.0)
        score += d100 < 2.5 ? 2.0 * math.max(0.0, 1.0 - d100 / 2.5) : 0.0
        rd50 = math.abs(lvl - math.round(lvl / 50.0) * 50.0)
        score += rd50 < 1.5 and d100 > 2.5 ? 1.5 * math.max(0.0, 1.0 - rd50 / 1.5) : 0.0
        d25 = math.abs(lvl - math.round(lvl / 25.0) * 25.0)
        score += d25 < 1.0 and rd50 > 1.5 ? 0.7 * math.max(0.0, 1.0 - d25 / 1.0) : 0.0
        if not na(vwapCalc)
            d = math.abs(lvl - vwapCalc) / atr
            score += d < 0.15 ? 1.2 * math.max(0.0, 1.0 - d / 0.15) : 0.0
        if not na(vwapUp1)
            d = math.abs(lvl - vwapUp1) / atr
            score += d < 0.15 ? 0.8 * math.max(0.0, 1.0 - d / 0.15) : 0.0
        if not na(vwapDn1)
            d = math.abs(lvl - vwapDn1) / atr
            score += d < 0.15 ? 0.8 * math.max(0.0, 1.0 - d / 0.15) : 0.0
        if not na(pivotR1)
            d = math.abs(lvl - pivotR1) / atr
            score += d < 0.10 ? 1.0 * math.max(0.0, 1.0 - d / 0.10) : 0.0
        if not na(pivotS1)
            d = math.abs(lvl - pivotS1) / atr
            score += d < 0.10 ? 1.0 * math.max(0.0, 1.0 - d / 0.10) : 0.0
        if not na(pivotR2)
            d = math.abs(lvl - pivotR2) / atr
            score += d < 0.10 ? 0.8 * math.max(0.0, 1.0 - d / 0.10) : 0.0
        if not na(pivotS2)
            d = math.abs(lvl - pivotS2) / atr
            score += d < 0.10 ? 0.8 * math.max(0.0, 1.0 - d / 0.10) : 0.0
        if not na(pivotPP)
            d = math.abs(lvl - pivotPP) / atr
            score += d < 0.10 ? 0.7 * math.max(0.0, 1.0 - d / 0.10) : 0.0
        if not na(prevDayH)
            d = math.abs(lvl - prevDayH) / atr
            score += d < 0.10 ? 1.0 * math.max(0.0, 1.0 - d / 0.10) : 0.0
        if not na(prevDayL)
            d = math.abs(lvl - prevDayL) / atr
            score += d < 0.10 ? 1.0 * math.max(0.0, 1.0 - d / 0.10) : 0.0
        if orbLocked and not na(orbHigh)
            d = math.abs(lvl - orbHigh) / atr
            score += d < 0.10 ? 0.7 * math.max(0.0, 1.0 - d / 0.10) : 0.0
        if orbLocked and not na(orbLow)
            d = math.abs(lvl - orbLow) / atr
            score += d < 0.10 ? 0.7 * math.max(0.0, 1.0 - d / 0.10) : 0.0
        if not na(onHigh)
            d = math.abs(lvl - onHigh) / atr
            score += d < 0.10 ? 0.6 * math.max(0.0, 1.0 - d / 0.10) : 0.0
        if not na(onLow)
            d = math.abs(lvl - onLow) / atr
            score += d < 0.10 ? 0.6 * math.max(0.0, 1.0 - d / 0.10) : 0.0
        score
f_dynTpBuffer(float lvl) =>
    if na(lvl)
        tpBuffer
    else
        crowd = f_crowdScore(lvl)                        // unbounded sum of proximity bonuses (typical 0-6)
        crowdNorm = math.min(1.0, crowd / 5.0)           // normalize to [0, 1]; 5 = saturated cluster
        bufferMult = 0.5 + crowdNorm * 2.5               // [0.5, 3.0] — no clusters = half buffer, max cluster = 3x
        tpBuffer * bufferMult
f_dynSlBuffer(float lvl) =>
    if na(lvl)
        tpBuffer
    else
        crowd = f_crowdScore(lvl)                        // unbounded sum of proximity bonuses (typical 0-6)
        crowdNorm = math.min(1.0, crowd / 5.0)           // normalize to [0, 1]; 5 = saturated cluster
        bufferMult = 0.5 + crowdNorm * 2.5               // [0.5, 3.0] — no clusters = half buffer, max cluster = 3x
        crowdBuffer = tpBuffer * bufferMult
        wickSrc = math.max(csUpperWk, csLowerWk)
        wickP75 = ta.percentile_linear_interpolation(wickSrc, 50, 75)
        wickP80 = ta.percentile_linear_interpolation(wickSrc, 50, 80)
        wickP90 = ta.percentile_linear_interpolation(wickSrc, 50, 90)
        wickP = aerChoppy or adfMeanRevert ? wickP90 : aerConsolidation or adx < 20 ? wickP80 : wickP75
        math.max(crowdBuffer, wickP)
f_dynSlBufferWithSetup(float lvl, float setupWick) =>
    base = f_dynSlBuffer(lvl)
    not na(setupWick) ? math.max(base, setupWick + tpBuffer) : base
if useOB and bar_index > obLookback
    strongMoveUp = close > close[1] + atr * obMinMove and close > open and volume > avgVol * _obVolThresh and csBodyToRange >= 0.55
    strongMoveDown = close < close[1] - atr * obMinMove and close < open and volume > avgVol * _obVolThresh and csBodyToRange >= 0.55
    obFvgUp = low > high[2]
    obFvgDown = high < low[2]
    obInKZ = time(timeframe.period, "0200-0300", "America/Chicago") != 0 or time(timeframe.period, "0900-1000", "America/Chicago") != 0 or time(timeframe.period, "1300-1400", "America/Chicago") != 0
    if strongMoveUp
        for i = 1 to math.min(obLookback, bar_index - 1)
            if close[i] < open[i]
                fA = htfBull ? 1.0 : 0.0
                fB = close < vwapVal ? 1.0 : 0.0
                fC = obFvgUp ? 1.0 : 0.0
                fD = relVol >= _mfiWtHi ? math.min(1.5, 0.5 + 0.5 * relVol / _mfiWtHi) : 0.0
                fE = obInKZ ? 1.0 : 0.0
                fF = avgVol > 0.0 and volume >= avgVol * 2.0 ? 1.0 : avgVol > 0.0 and volume >= avgVol * 1.5 ? 0.5 : 0.0
                fG = _realizedVolRel >= 1.1 ? 0.7 : 0.0
                fH = (aerUptrend and macdBull) ? 1.0 : 0.0
                fI = close > close[1] and close > open ? math.min(1.0, 0.5 + 0.5 * math.min(2.0, relVol)) : 0.0
                fJ = atr > 0.0 and (high[i] - low[i]) / atr <= 1.5 ? 0.5 : 0.0
                obBullFormScore := int(math.round(fA + fB + fC + fD + fE + fF + fG + fH + fI + fJ))
                obBullStoredHi := high[i]
                obBullStoredLo := low[i]
                obBullTouched := false
                obBullDefenseCount := 0
                obBullActive := true
                obBullMid := (high[i] + low[i]) / 2.0
                if obBullFormScore >= obDisplayMinScore
                    array.push(obBoxes, box.new(bar_index - i, high[i], bar_index + 10, low[i], border_color=color.new(#FFD600, 40), bgcolor=color.new(#FFD600, 88), border_width=1))
                    array.push(obLabels, label.new(bar_index + 10, high[i], "▲ OB", color=color.new(color.white, 100), textcolor=color.new(#FFD600, 0), style=label.style_label_left, size=size.normal))
                break
    if strongMoveDown
        for i = 1 to math.min(obLookback, bar_index - 1)
            if close[i] > open[i]
                fA = htfBear ? 1.0 : 0.0
                fB = close > vwapVal ? 1.0 : 0.0
                fC = obFvgDown ? 1.0 : 0.0
                fD = relVol >= _mfiWtHi ? math.min(1.5, 0.5 + 0.5 * relVol / _mfiWtHi) : 0.0
                fE = obInKZ ? 1.0 : 0.0
                fF = avgVol > 0.0 and volume >= avgVol * 2.0 ? 1.0 : avgVol > 0.0 and volume >= avgVol * 1.5 ? 0.5 : 0.0
                fG = _realizedVolRel >= 1.1 ? 0.7 : 0.0
                fH = (aerDowntrend and macdBear) ? 1.0 : 0.0
                fI = close < close[1] and close < open ? math.min(1.0, 0.5 + 0.5 * math.min(2.0, relVol)) : 0.0
                fJ = atr > 0.0 and (high[i] - low[i]) / atr <= 1.5 ? 0.5 : 0.0
                obBearFormScore := int(math.round(fA + fB + fC + fD + fE + fF + fG + fH + fI + fJ))
                obBearStoredHi := high[i]
                obBearStoredLo := low[i]
                obBearTouched := false
                obBearDefenseCount := 0
                obBearActive := true
                obBearMid := (high[i] + low[i]) / 2.0
                if obBearFormScore >= obDisplayMinScore
                    array.push(obBoxes, box.new(bar_index - i, high[i], bar_index + 10, low[i], border_color=color.new(#6A1B9A, 40), bgcolor=color.new(#6A1B9A, 88), border_width=1))
                    array.push(obLabels, label.new(bar_index + 10, low[i], "▼ OB", color=color.new(color.white, 100), textcolor=color.new(#6A1B9A, 0), style=label.style_label_left, size=size.normal))
                break
    if obBullActive and not na(obBullStoredHi) and not na(obBullStoredLo)
        if close < obBullStoredLo
            obBullActive := false
            obBullMid    := na  // Mitigation: clear midpoint so pool walkers exclude this stale OB
        else
            wickedInBull = low <= obBullStoredHi
            wickRejectedBull = wickedInBull and close > obBullStoredHi
            if wickedInBull and not obBullTouched
                obBullTouched := true
                bullConfirm = csBullCommit and not csDoji and ((close > close[1] and close > open) or csBullEngulf or csHammer)
                if useOBTrade and bullConfirm and obBullFormScore >= obMinRules
                    obBullTradeFire := true
                    obBullSl := obBullStoredLo - f_dynSlBuffer(obBullStoredLo)
            if wickRejectedBull
                obBullDefenseCount := obBullDefenseCount + 1
    if obBearActive and not na(obBearStoredHi) and not na(obBearStoredLo)
        if close > obBearStoredHi
            obBearActive := false
            obBearMid    := na  // Mitigation: clear midpoint so pool walkers exclude this stale OB
        else
            wickedInBear = high >= obBearStoredLo
            wickRejectedBear = wickedInBear and close < obBearStoredLo
            if wickedInBear and not obBearTouched
                obBearTouched := true
                bearConfirm = csBearCommit and not csDoji and ((close < close[1] and close < open) or csBearEngulf or csShootSt)
                if useOBTrade and bearConfirm and obBearFormScore >= obMinRules
                    obBearTradeFire := true
                    obBearSl := obBearStoredHi + f_dynSlBuffer(obBearStoredHi)
            if wickRejectedBear
                obBearDefenseCount := obBearDefenseCount + 1
f_nearestResAbove() =>
    float best = 1e15
    if not na(pivotR1) and pivotR1 > close and pivotR1 < best
        best := pivotR1
    if not na(pivotR2) and pivotR2 > close and pivotR2 < best
        best := pivotR2
    if not na(pivotPP) and pivotPP > close and pivotPP < best
        best := pivotPP
    if not na(prevDayH) and prevDayH > close and prevDayH < best
        best := prevDayH
    if not na(prevDayC) and prevDayC > close and prevDayC < best
        best := prevDayC
    if not na(orbHigh) and orbLocked and orbHigh > close and orbHigh < best
        best := orbHigh
    if not na(pmHigh) and pmHigh > close and pmHigh < best
        best := pmHigh
    if not na(pmMid) and pmMid > close and pmMid < best
        best := pmMid
    if not na(vwapUp1) and vwapUp1 > close and vwapUp1 < best
        best := vwapUp1
    if not na(vwapUp2) and vwapUp2 > close and vwapUp2 < best
        best := vwapUp2
    if not na(vwapCalc) and vwapCalc > close and vwapCalc < best
        best := vwapCalc
    if not na(fpPocMid) and fpPocMid > close and fpPocMid < best
        best := fpPocMid
    if showORBMid and not na(orbMid) and orbLocked and orbMid > close and orbMid < best
        best := orbMid
    if showONRange and not na(onHigh) and onHigh > close and onHigh < best
        best := onHigh
    if showQQQLevels and not na(qqqLvlUp1) and qqqLvlUp1 > close and qqqLvlUp1 < best
        best := qqqLvlUp1
    if showQQQLevels and not na(qqqLvlUp2) and qqqLvlUp2 > close and qqqLvlUp2 < best
        best := qqqLvlUp2
    if not na(hvbZone1) and hvbZone1 > close and hvbZone1 < best
        best := hvbZone1
    if not na(hvbZone2) and hvbZone2 > close and hvbZone2 < best
        best := hvbZone2
    if not na(povLevel) and povLevel > close and povLevel < best
        best := povLevel
    if not na(vahLevel) and vahLevel > close and vahLevel < best
        best := vahLevel
    if not na(fvgBullLo) and fvgBullQuality > fvgQualityGate and fvgBullLo > close and fvgBullLo < best
        best := fvgBullLo
    if not na(fvgBearHi) and fvgBearQuality > fvgQualityGate and fvgBearHi > close and fvgBearHi < best
        best := fvgBearHi
    if not na(obBullMid) and obBullMid > close and obBullMid < best
        best := obBullMid
    if not na(obBearMid) and obBearMid > close and obBearMid < best
        best := obBearMid
    if trendDown and swingRange > atr * _oteSwingMin and oteMidShort > close and oteMidShort < best
        best := oteMidShort
    best == 1e15 ? na : best
_nearestResAbove = f_nearestResAbove()
f_nearestResAboveLevel(float thresh) =>
    float best = 1e15
    if not na(pivotR1) and pivotR1 > thresh and pivotR1 < best
        best := pivotR1
    if not na(pivotR2) and pivotR2 > thresh and pivotR2 < best
        best := pivotR2
    if not na(pivotPP) and pivotPP > thresh and pivotPP < best
        best := pivotPP
    if not na(prevDayH) and prevDayH > thresh and prevDayH < best
        best := prevDayH
    if not na(prevDayC) and prevDayC > thresh and prevDayC < best
        best := prevDayC
    if not na(orbHigh) and orbLocked and orbHigh > thresh and orbHigh < best
        best := orbHigh
    if not na(pmHigh) and pmHigh > thresh and pmHigh < best
        best := pmHigh
    if not na(pmMid) and pmMid > thresh and pmMid < best
        best := pmMid
    if not na(vwapUp1) and vwapUp1 > thresh and vwapUp1 < best
        best := vwapUp1
    if not na(vwapUp2) and vwapUp2 > thresh and vwapUp2 < best
        best := vwapUp2
    if not na(vwapCalc) and vwapCalc > thresh and vwapCalc < best
        best := vwapCalc
    if not na(fpPocMid) and fpPocMid > thresh and fpPocMid < best
        best := fpPocMid
    if showORBMid and not na(orbMid) and orbLocked and orbMid > thresh and orbMid < best
        best := orbMid
    if showONRange and not na(onHigh) and onHigh > thresh and onHigh < best
        best := onHigh
    if showQQQLevels and not na(qqqLvlUp1) and qqqLvlUp1 > thresh and qqqLvlUp1 < best
        best := qqqLvlUp1
    if showQQQLevels and not na(qqqLvlUp2) and qqqLvlUp2 > thresh and qqqLvlUp2 < best
        best := qqqLvlUp2
    if not na(hvbZone1) and hvbZone1 > thresh and hvbZone1 < best
        best := hvbZone1
    if not na(hvbZone2) and hvbZone2 > thresh and hvbZone2 < best
        best := hvbZone2
    if not na(povLevel) and povLevel > thresh and povLevel < best
        best := povLevel
    if not na(vahLevel) and vahLevel > thresh and vahLevel < best
        best := vahLevel
    if not na(fvgBullLo) and fvgBullQuality > fvgQualityGate and fvgBullLo > thresh and fvgBullLo < best
        best := fvgBullLo
    if not na(fvgBearHi) and fvgBearQuality > fvgQualityGate and fvgBearHi > thresh and fvgBearHi < best
        best := fvgBearHi
    if not na(obBullMid) and obBullMid > thresh and obBullMid < best
        best := obBullMid
    if not na(obBearMid) and obBearMid > thresh and obBearMid < best
        best := obBearMid
    best == 1e15 ? na : best
f_nearestSupBelow() =>
    float best = -1e15
    if not na(pivotS1) and pivotS1 < close and pivotS1 > best
        best := pivotS1
    if not na(pivotS2) and pivotS2 < close and pivotS2 > best
        best := pivotS2
    if not na(pivotPP) and pivotPP < close and pivotPP > best
        best := pivotPP
    if not na(prevDayL) and prevDayL < close and prevDayL > best
        best := prevDayL
    if not na(prevDayC) and prevDayC < close and prevDayC > best
        best := prevDayC
    if not na(orbLow) and orbLocked and orbLow < close and orbLow > best
        best := orbLow
    if not na(pmLow) and pmLow < close and pmLow > best
        best := pmLow
    if not na(pmMid) and pmMid < close and pmMid > best
        best := pmMid
    if not na(vwapDn1) and vwapDn1 < close and vwapDn1 > best
        best := vwapDn1
    if not na(vwapDn2) and vwapDn2 < close and vwapDn2 > best
        best := vwapDn2
    if not na(vwapCalc) and vwapCalc < close and vwapCalc > best
        best := vwapCalc
    if not na(fpPocMid) and fpPocMid < close and fpPocMid > best
        best := fpPocMid
    if showORBMid and not na(orbMid) and orbLocked and orbMid < close and orbMid > best
        best := orbMid
    if showONRange and not na(onLow) and onLow < close and onLow > best
        best := onLow
    if showQQQLevels and not na(qqqLvlDn1) and qqqLvlDn1 < close and qqqLvlDn1 > best
        best := qqqLvlDn1
    if showQQQLevels and not na(qqqLvlDn2) and qqqLvlDn2 < close and qqqLvlDn2 > best
        best := qqqLvlDn2
    if not na(hvbZone1) and hvbZone1 < close and hvbZone1 > best
        best := hvbZone1
    if not na(hvbZone2) and hvbZone2 < close and hvbZone2 > best
        best := hvbZone2
    if not na(povLevel) and povLevel < close and povLevel > best
        best := povLevel
    if not na(valLevel) and valLevel < close and valLevel > best
        best := valLevel
    if not na(fvgBullHi) and fvgBullQuality > fvgQualityGate and fvgBullHi < close and fvgBullHi > best
        best := fvgBullHi
    if not na(fvgBearLo) and fvgBearQuality > fvgQualityGate and fvgBearLo < close and fvgBearLo > best
        best := fvgBearLo
    if not na(obBullMid) and obBullMid < close and obBullMid > best
        best := obBullMid
    if not na(obBearMid) and obBearMid < close and obBearMid > best
        best := obBearMid
    if trendUp and swingRange > atr * _oteSwingMin and oteMidLong < close and oteMidLong > best
        best := oteMidLong
    best == -1e15 ? na : best
_nearestSupBelow = f_nearestSupBelow()
f_nearestSupBelowLevel(float thresh) =>
    float best = -1e15
    if not na(pivotS1) and pivotS1 < thresh and pivotS1 > best
        best := pivotS1
    if not na(pivotS2) and pivotS2 < thresh and pivotS2 > best
        best := pivotS2
    if not na(pivotPP) and pivotPP < thresh and pivotPP > best
        best := pivotPP
    if not na(prevDayL) and prevDayL < thresh and prevDayL > best
        best := prevDayL
    if not na(prevDayC) and prevDayC < thresh and prevDayC > best
        best := prevDayC
    if not na(orbLow) and orbLocked and orbLow < thresh and orbLow > best
        best := orbLow
    if not na(pmLow) and pmLow < thresh and pmLow > best
        best := pmLow
    if not na(pmMid) and pmMid < thresh and pmMid > best
        best := pmMid
    if not na(vwapDn1) and vwapDn1 < thresh and vwapDn1 > best
        best := vwapDn1
    if not na(vwapDn2) and vwapDn2 < thresh and vwapDn2 > best
        best := vwapDn2
    if not na(vwapCalc) and vwapCalc < thresh and vwapCalc > best
        best := vwapCalc
    if not na(fpPocMid) and fpPocMid < thresh and fpPocMid > best
        best := fpPocMid
    if showORBMid and not na(orbMid) and orbLocked and orbMid < thresh and orbMid > best
        best := orbMid
    if showONRange and not na(onLow) and onLow < thresh and onLow > best
        best := onLow
    if showQQQLevels and not na(qqqLvlDn1) and qqqLvlDn1 < thresh and qqqLvlDn1 > best
        best := qqqLvlDn1
    if showQQQLevels and not na(qqqLvlDn2) and qqqLvlDn2 < thresh and qqqLvlDn2 > best
        best := qqqLvlDn2
    if not na(hvbZone1) and hvbZone1 < thresh and hvbZone1 > best
        best := hvbZone1
    if not na(hvbZone2) and hvbZone2 < thresh and hvbZone2 > best
        best := hvbZone2
    if not na(povLevel) and povLevel < thresh and povLevel > best
        best := povLevel
    if not na(valLevel) and valLevel < thresh and valLevel > best
        best := valLevel
    if not na(fvgBullHi) and fvgBullQuality > fvgQualityGate and fvgBullHi < thresh and fvgBullHi > best
        best := fvgBullHi
    if not na(fvgBearLo) and fvgBearQuality > fvgQualityGate and fvgBearLo < thresh and fvgBearLo > best
        best := fvgBearLo
    if not na(obBullMid) and obBullMid < thresh and obBullMid > best
        best := obBullMid
    if not na(obBearMid) and obBearMid < thresh and obBearMid > best
        best := obBearMid
    best == -1e15 ? na : best
int[] _markerCounts = array.from(0, 0)
f_signalMarker(bool isLong, string entryType) =>
    int slot = isLong ? 0 : 1
    int idx = array.get(_markerCounts, slot)
    string mkTxt = (isLong ? "▲ " : "▼ ") + entryType
    color  mkCol = isLong ? color.green : color.red
    float  mkY   = isLong ? low - atr * (0.5 + idx * 0.6) : high + atr * (0.5 + idx * 0.6)
    label.new(bar_index, mkY, mkTxt, color=color.new(color.white, 100), textcolor=color.new(mkCol, 0), style=isLong ? label.style_label_up : label.style_label_down, size=size.normal)
    array.set(_markerCounts, slot, idx + 1)
f_openTicket(bool isLong, float _sl, float _tp, string kind, string entryType, float conf) =>
    safeSl = _sl
    typeSuffix = " [" + entryType + "]"
    int sameBarSameDir = 0
    if array.size(activeTix) > 0
        for i = 0 to array.size(activeTix) - 1
            t_existing = array.get(activeTix, i)
            if t_existing.eBar == bar_index and t_existing.isLong == isLong
                sameBarSameDir += 1
    float yMult = 1.0 + sameBarSameDir * 0.6
    lblY = isLong ? low - atr * yMult : high + atr * yMult
    string confSuffix = showConfInLabel ? "\nC: " + str.tostring(conf, "#.##") : ""
    line  slLn = line.new(bar_index, safeSl, bar_index + 15, safeSl, color=color.red,   width=1, style=line.style_dashed)
    line  tpLn = line.new(bar_index, _tp,    bar_index + 15, _tp,    color=color.green, width=1, style=line.style_dashed)
    string lblTxt = kind + typeSuffix + "\n@" + str.tostring(math.round(close)) + "\nTP: " + str.tostring(math.round(_tp)) + "\nSL: " + str.tostring(math.round(safeSl)) + confSuffix
    color  entryCol = isLong ? color.blue : color.red
    label  lb = label.new(bar_index, lblY, lblTxt, color=color.new(entryCol, 10), textcolor=color.white, style=isLong ? label.style_label_up : label.style_label_down, size=size.normal)
    t = TixEntry.new(bar_index, isLong, safeSl, _tp, slLn, tpLn, lb, false, kind, close, 0.0)
    array.push(activeTix, t)
footprint fp = request.footprint(50, 70)
float fpBuyVol = not na(fp) ? fp.buy_volume() : 0.0
float fpSellVol = not na(fp) ? fp.sell_volume() : 0.0
float fpDelta = not na(fp) ? fp.delta() : 0.0
float fpTotalVol= not na(fp) ? fp.total_volume() : volume
float fpVAH = na
float fpVAL = na
if not na(fp)
    volume_row pocRow = fp.poc()
    volume_row vahRow = fp.vah()
    volume_row valRow = fp.val()
    if not na(pocRow)
        fpPocMid := (pocRow.up_price() + pocRow.down_price()) / 2.0
    if not na(vahRow)
        fpVAH := vahRow.up_price()
    if not na(valRow)
        fpVAL := valRow.down_price()
var float cumFpDelta = 0.0
if ta.change(dayofmonth(time)) != 0
    cumFpDelta := 0.0
cumFpDelta += fpDelta
fpDeltaSlope = cumFpDelta - cumFpDelta[10]
fpDeltaBull = fpDeltaSlope > 0
fpDeltaBear = fpDeltaSlope < 0
float deltaMag = avgVol > 0 ? math.min(2.0, math.abs(fpDeltaSlope) / (avgVol * 0.1)) : 1.0
float _cumDeltaSma        = ta.sma(cumFpDelta, 10)
bool  _cumDeltaRising     = ta.rising(_cumDeltaSma, 3)
bool  _cumDeltaFalling    = ta.falling(_cumDeltaSma, 3)
float _cumDeltaContinuity = _cumDeltaRising ? 1.0 : _cumDeltaFalling ? -1.0 : 0.0
float _cumDeltaSlopeNow   = cumFpDelta - cumFpDelta[5]
float _cumDeltaSlopePrev  = cumFpDelta[5] - cumFpDelta[10]
float _cumDeltaSlopeAccel = _cumDeltaSlopeNow - _cumDeltaSlopePrev
float _accelMag = ta.sma(math.abs(_cumDeltaSlopeAccel), i_dirZLookback)
float _slopeAccelNorm = _accelMag > 0.0 ? math.max(-1.0, math.min(1.0, _cumDeltaSlopeAccel / (_accelMag * i_dirZThresh))) : 0.0
fpBuyRatio = fpSellVol > 0 ? fpBuyVol / fpSellVol : 99.0
fpSellRatio = fpBuyVol > 0 ? fpSellVol / fpBuyVol : 99.0
float _nearRes = _nearestResAbove
float _nearSup = _nearestSupBelow
f_marketVelocity() =>
    er = math.max(0.0, math.min(1.0, aerER))
    volMult = math.max(0.5, math.min(1.5, atr / math.max(aerMeanATR, 0.0001)))
    adxN = math.max(0.0, math.min(1.0, (adx - 15.0) / 25.0))
    hurstN = math.max(0.0, math.min(1.0, (hurst - 0.4) / 0.2))
    directionalQuality = (er + adxN + hurstN) / 3.0
    directionalQuality * volMult
float _marketVel    = f_marketVelocity()
float _marketVelAvg = ta.ema(_marketVel, 20)
float _volSma5      = ta.sma(volume, 5)
float _rangeSma5    = ta.sma(high - low, 5)
f_calcTpSlLongStruct(float baseTp, float slBase) =>
    [baseTp, slBase]
f_calcTpSlShortStruct(float baseTp, float slBase) =>
    [baseTp, slBase]
bosHighVal = ta.highest(high, bosLen)[1]
bosLowVal = ta.lowest(low, bosLen)[1]
bosBreakSize = atr * _bosBreakMult
bool _bosBullBrkPrev = useBOS and close[1] > bosHighVal[1] and close[1] > open[1]
bool _bosBearBrkPrev = useBOS and close[1] < bosLowVal[1] and close[1] < open[1]
bool _bosBullHold = close > bosHighVal[1]
bool _bosBearHold = close < bosLowVal[1]
bosBullRaw = _bosBullBrkPrev and _bosBullHold
bosBearRaw = _bosBearBrkPrev and _bosBearHold
var int lastBosBar = 0
bullBOS = bosBullRaw and csBodyToRange >= 0.40
bearBOS = bosBearRaw and csBodyToRange >= 0.40
if bullBOS or bearBOS
    lastBosBar := bar_index
var float bosBullLevel = na
var float bosBearLevel = na
var int bosBullBreakBar = na
var int bosBearBreakBar = na
bool _orbBullBreakNow = orbLocked and not na(orbHigh) and close > orbHigh and not _orbBullBrokenForBOS
bool _orbBearBreakNow = orbLocked and not na(orbLow)  and close < orbLow  and not _orbBearBrokenForBOS
if _orbBullBreakNow
    _orbBullBrokenForBOS := true
if _orbBearBreakNow
    _orbBearBrokenForBOS := true
if bullBOS or _orbBullBreakNow
    bosBullLevel := bullBOS ? bosHighVal[1] : orbHigh
    bosBullBreakBar := bar_index
if bearBOS or _orbBearBreakNow
    bosBearLevel := bearBOS ? bosLowVal[1] : orbLow
    bosBearBreakBar := bar_index
if not na(bosBullLevel) and close < bosBullLevel - atr * 0.2
    bosBullLevel := na
if not na(bosBearLevel) and close > bosBearLevel + atr * 0.2
    bosBearLevel := na
bool bosBullActive = not na(bosBullLevel)
bool bosBearActive = not na(bosBearLevel)
bool bosBullAtRetest = bosBullActive and bar_index - bosBullBreakBar >= 1 and low <= bosBullLevel + atr * 0.4 and close > bosBullLevel
bool bosBearAtRetest = bosBearActive and bar_index - bosBearBreakBar >= 1 and high >= bosBearLevel - atr * 0.4 and close < bosBearLevel
bool _bosLevelIsOrbBull = orbLocked and not na(orbHigh) and not na(bosBullLevel) and bosBullLevel == orbHigh
bool _bosLevelIsOrbBear = orbLocked and not na(orbLow)  and not na(bosBearLevel) and bosBearLevel == orbLow
bool _orbWickConfirmL = bosBullAtRetest and (math.min(open, close) - low) > math.abs(close - open) * 0.5
bool _orbWickConfirmS = bosBearAtRetest and (high - math.max(open, close)) > math.abs(close - open) * 0.5
bool _orbFlowConfirmL = bosBullAtRetest and close > open and volume > volume[1]
bool _orbFlowConfirmS = bosBearAtRetest and close < open and volume > volume[1]
bool bosBullRetestConfirm = bosBullAtRetest and (csBullEngulf or csHammer or (csBullBar and csBody > csAvgBody * 0.7) or (_bosLevelIsOrbBull and (_orbWickConfirmL or _orbFlowConfirmL))) and not csDoji
bool bosBearRetestConfirm = bosBearAtRetest and (csBearEngulf or csShootSt or (csBearBar and csBody > csAvgBody * 0.7) or (_bosLevelIsOrbBear and (_orbWickConfirmS or _orbFlowConfirmS))) and not csDoji
float bosTpLong = not na(bosBullLevel) ? f_nearestResAboveLevel(bosBullLevel) : na
float bosTpShort = not na(bosBearLevel) ? f_nearestSupBelowLevel(bosBearLevel) : na
float bosTpLongAdj = not na(bosTpLong) ? bosTpLong - f_dynTpBuffer(bosTpLong) : na
float bosTpShortAdj = not na(bosTpShort) ? bosTpShort + f_dynTpBuffer(bosTpShort) : na
swpHighVal = ta.highest(high, sweepLen)[1]
swpLowVal = ta.lowest(low, sweepLen)[1]
swpBody = math.abs(close - open)
swpRange = high - low
swpAvgRange= ta.sma(swpRange, 20)
f_swpWickMinMult() =>
    base = 0.6
    sessAdj = isOpen ? 0.15 : isMorning ? -0.045 : isLunch ? 0.1 : isAfternoon ? -0.05 : isLast ? 0.05 : inPreMkt ? 0.15 : inLondon ? 0.12 : inAsia ? 0.15 : 0.0
    regAdj = aerTrending ? 0.1 : aerChoppy ? -0.1 : 0.0
    adxAdj = adx >= 30 ? 0.08 : adx < 20 ? -0.08 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.1 : atr < aerMeanATR * _volatLo ? -0.05 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.05 : relVol < _mfiWtLo ? 0.08 : 0.0
    math.max(0.3, math.min(1.0, base + sessAdj + regAdj + adxAdj + volatAdj + volAdj))
_swpWickMinMult = f_swpWickMinMult()
f_swpWickBodyThresh() =>
    base = 1.2
    regAdj = aerTrending ? 0.2 : aerChoppy ? -0.2 : 0.0
    sessAdj = isOpen ? 0.1 : isMorning ? -0.03 : isLunch ? -0.1 : isAfternoon ? -0.05 : isLast ? 0.03 : inPreMkt ? 0.0 : inLondon ? 0.0 : inAsia ? 0.0 : 0.0
    adxAdj = adx >= 30 ? 0.1 : adx < 20 ? -0.1 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.1 : atr < aerMeanATR * _volatLo ? -0.05 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.05 : relVol < _mfiWtLo ? 0.08 : 0.0
    math.max(0.8, math.min(1.8, base + regAdj + sessAdj + adxAdj + volatAdj + volAdj))
_swpWickBodyThresh = f_swpWickBodyThresh()
f_swpVolThresh() =>
    base = 1.7
    sessAdj = isOpen ? 0.3 : isMorning ? -0.09 : isLunch ? -0.3 : isAfternoon ? -0.15 : isLast ? 0.1 : inPreMkt ? -0.4 : inLondon ? -0.32 : inAsia ? -0.4 : 0.0
    regAdj = aerTrending ? 0.15 : aerChoppy ? -0.15 : 0.0
    adxAdj = adx >= 30 ? 0.2 : adx < 20 ? -0.2 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.15 : atr < aerMeanATR * _volatLo ? -0.1 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.1 : relVol < _mfiWtLo ? 0.15 : 0.0
    math.max(1.0, math.min(2.8, base + sessAdj + regAdj + adxAdj + volatAdj + volAdj))
_swpVolThresh = f_swpVolThresh()
f_swpRangeThresh() =>
    base = 1.3
    sessAdj = isOpen ? 0.15 : isMorning ? -0.045 : isLunch ? -0.1 : isAfternoon ? -0.05 : isLast ? 0.045 : inPreMkt ? 0.15 : inLondon ? 0.12 : inAsia ? 0.15 : 0.0
    regAdj = aerTrending ? 0.1 : aerChoppy ? -0.1 : 0.0
    adxAdj = adx >= 30 ? 0.08 : adx < 20 ? -0.08 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.1 : atr < aerMeanATR * _volatLo ? -0.05 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.05 : relVol < _mfiWtLo ? 0.08 : 0.0
    math.max(0.9, math.min(1.8, base + sessAdj + regAdj + adxAdj + volatAdj + volAdj))
_swpRangeThresh = f_swpRangeThresh()
f_swpRejectFrac() =>
    base = 0.50
    sessAdj = isOpen ? -0.02 : isMorning ? 0.0 : isLunch ? 0.10 : isAfternoon ? 0.03 : isLast ? -0.01 : inPreMkt ? 0.08 : inLondon ? 0.06 : inAsia ? 0.08 : 0.0
    regAdj = aerTrending ? -0.03 : aerChoppy ? 0.08 : 0.0
    adxAdj = adx >= 30 ? -0.03 : adx < 20 ? 0.07 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? -0.02 : atr < aerMeanATR * _volatLo ? 0.05 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.03 : relVol < _mfiWtLo ? 0.05 : 0.0
    hurstAdj = hurstPersist ? -0.03 : hurstRevert ? 0.05 : 0.0
    math.max(0.45, math.min(0.75, base + sessAdj + regAdj + adxAdj + volatAdj + volAdj + hurstAdj))
_swpRejectFrac = f_swpRejectFrac()
f_swpHtfTol() =>
    base = 0.30
    sessAdj = isOpen ? 0.05 : isMorning ? 0.0 : isLunch ? -0.05 : isAfternoon ? -0.02 : isLast ? 0.0 : inPreMkt ? -0.03 : inLondon ? -0.03 : inAsia ? -0.05 : 0.0
    regAdj = aerTrending ? 0.05 : aerChoppy ? -0.05 : 0.0
    adxAdj = adx >= 30 ? 0.05 : adx < 20 ? -0.05 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.03 : atr < aerMeanATR * _volatLo ? -0.03 : 0.0
    volAdj = relVol >= _mfiWtHi ? 0.03 : relVol < _mfiWtLo ? -0.03 : 0.0
    hurstAdj = hurstPersist ? 0.03 : hurstRevert ? -0.03 : 0.0
    math.max(0.15, math.min(0.50, base + sessAdj + regAdj + adxAdj + volatAdj + volAdj + hurstAdj))
swpWickMin = atr * _swpWickMinMult
float swpMeanUpper = ta.sma(csUpperWk, 20)
float swpMeanLower = ta.sma(csLowerWk, 20)
float swpStdUpper = ta.stdev(csUpperWk, 20)
float swpStdLower = ta.stdev(csLowerWk, 20)
float swpStdevFactor = isOpen ? 1.2 : isMorning ? 1.3 : isLunch ? 1.8 : isAfternoon ? 1.5 : inAsia ? 1.8 : aerTrending and adx >= 30 ? 1.1 : aerTrending ? 1.3 : aerChoppy ? 1.7 : adx < 15 ? 1.7 : 1.5
bool swpStdevOkHigh = csUpperWk > swpMeanUpper + swpStdevFactor * swpStdUpper
bool swpStdevOkLow = csLowerWk > swpMeanLower + swpStdevFactor * swpStdLower
swpFakeHigh = high > swpHighVal and close < swpHighVal
swpFakeLow = low < swpLowVal and close > swpLowVal
swpWickOk = (high - math.max(open, close)) > swpWickMin or (math.min(open, close) - low) > swpWickMin
swpWickBody = swpBody > 0 ? math.max(high - math.max(open, close), math.min(open, close) - low) / swpBody >= _swpWickBodyThresh : true
swpVolOk = relVol >= _swpVolThresh
swpRangeOk = swpRange > swpAvgRange * _swpRangeThresh
float _swpRejFrac = _swpRejectFrac
bool swpBullRejectClose = swpRange > 0 and (high - close) / swpRange >= _swpRejFrac
bool swpBearRejectClose = swpRange > 0 and (close - low) / swpRange >= _swpRejFrac
swpBullRaw = useSweep and swpFakeHigh and swpWickOk and swpWickBody and swpVolOk and swpRangeOk and swpStdevOkHigh and swpBullRejectClose
swpBearRaw = useSweep and swpFakeLow and swpWickOk and swpWickBody and swpVolOk and swpRangeOk and swpStdevOkLow and swpBearRejectClose
bullSweep = swpBullRaw
bearSweep = swpBearRaw
var array<float> _bullSweepLvls = array.new<float>()
var array<int>   _bullSweepBars = array.new<int>()
var array<float> _bearSweepLvls = array.new<float>()
var array<int>   _bearSweepBars = array.new<int>()
while array.size(_bullSweepBars) > 0 and bar_index - array.get(_bullSweepBars, 0) > 50
    array.shift(_bullSweepLvls)
    array.shift(_bullSweepBars)
while array.size(_bearSweepBars) > 0 and bar_index - array.get(_bearSweepBars, 0) > 50
    array.shift(_bearSweepLvls)
    array.shift(_bearSweepBars)
if bullSweep and not bullSweep[1]
    array.push(_bullSweepLvls, high)
    array.push(_bullSweepBars, bar_index)
if bearSweep and not bearSweep[1]
    array.push(_bearSweepLvls, low)
    array.push(_bearSweepBars, bar_index)
float _sweepClusterTol = atr * 0.5
int _bullSweepClusterCount = 0
int _bearSweepClusterCount = 0
if array.size(_bullSweepLvls) > 0
    for i = 0 to array.size(_bullSweepLvls) - 1
        if math.abs(array.get(_bullSweepLvls, i) - close) <= _sweepClusterTol
            _bullSweepClusterCount += 1
if array.size(_bearSweepLvls) > 0
    for i = 0 to array.size(_bearSweepLvls) - 1
        if math.abs(array.get(_bearSweepLvls, i) - close) <= _sweepClusterTol
            _bearSweepClusterCount += 1
bool _bullSweepClustered = _bullSweepClusterCount >= 2
bool _bearSweepClustered = _bearSweepClusterCount >= 2
var array<box> _sweepClusterBoxes = array.new<box>()
maxSweepClusterBoxes = 4
f_sweepClusterQuality(int clusterCount, float clusterCenter) =>
    countScore = math.max(0.0, math.min(1.5, (clusterCount - 2.0) * 0.5))
    htfProx    = math.min(1.5, f_crowdScore(clusterCenter) * 0.5)
    sessScore  = isOpen or isMorning ? 0.5 : isLast ? 0.3 : isLunch ? 0.0 : isAfternoon ? 0.3 : inAsia ? 0.0 : inLondon ? 0.2 : 0.1
    regScore   = aerTrending ? 0.4 : aerChoppy ? 0.0 : 0.2
    volScore   = math.max(0.0, math.min(0.5, (relVol - 1.0) * 0.5))
    countScore + htfProx + sessScore + regScore + volScore
if showSweepClusters and _bullSweepClustered and not _bullSweepClustered[1] and atr > 0.0
    sumLvl = 0.0
    cnt = 0
    if array.size(_bullSweepLvls) > 0
        for i = 0 to array.size(_bullSweepLvls) - 1
            lvl = array.get(_bullSweepLvls, i)
            if math.abs(lvl - close) <= _sweepClusterTol
                sumLvl += lvl
                cnt += 1
    centerLvl = cnt > 0 ? sumLvl / cnt : close
    qual = f_sweepClusterQuality(cnt, centerLvl)
    if qual >= sweepClusterMinQual
        array.push(_sweepClusterBoxes, box.new(bar_index - 5, centerLvl + atr * 0.4, bar_index + 25, centerLvl - atr * 0.4, border_color=color.new(#00E5FF, 40), bgcolor=color.new(#00E5FF, 90), border_width=1, text="▼ BEAR SWP", text_size=size.normal, text_color=color.new(#00E5FF, 20), text_halign=text.align_left))
if showSweepClusters and _bearSweepClustered and not _bearSweepClustered[1] and atr > 0.0
    sumLvl = 0.0
    cnt = 0
    if array.size(_bearSweepLvls) > 0
        for i = 0 to array.size(_bearSweepLvls) - 1
            lvl = array.get(_bearSweepLvls, i)
            if math.abs(lvl - close) <= _sweepClusterTol
                sumLvl += lvl
                cnt += 1
    centerLvl = cnt > 0 ? sumLvl / cnt : close
    qual = f_sweepClusterQuality(cnt, centerLvl)
    if qual >= sweepClusterMinQual
        array.push(_sweepClusterBoxes, box.new(bar_index - 5, centerLvl + atr * 0.4, bar_index + 25, centerLvl - atr * 0.4, border_color=color.new(#FF6F00, 40), bgcolor=color.new(#FF6F00, 90), border_width=1, text="▲ BULL SWP", text_size=size.normal, text_color=color.new(#FF6F00, 20), text_halign=text.align_left))
while array.size(_sweepClusterBoxes) > maxSweepClusterBoxes
    box.delete(array.shift(_sweepClusterBoxes))
float _swpHtfTol = atr * f_swpHtfTol()
bool swpAtHTFLvlBullTrap = bullSweep and ((not na(prevDayH) and math.abs(high - prevDayH) <= _swpHtfTol) or (orbLocked and not na(orbHigh) and math.abs(high - orbHigh) <= _swpHtfTol) or (not na(pivotR1) and math.abs(high - pivotR1) <= _swpHtfTol) or (not na(pivotR2) and math.abs(high - pivotR2) <= _swpHtfTol) or (not na(onHigh) and math.abs(high - onHigh) <= _swpHtfTol))
bool swpAtHTFLvlBearTrap = bearSweep and ((not na(prevDayL) and math.abs(low - prevDayL) <= _swpHtfTol) or (orbLocked and not na(orbLow) and math.abs(low - orbLow) <= _swpHtfTol) or (not na(pivotS1) and math.abs(low - pivotS1) <= _swpHtfTol) or (not na(pivotS2) and math.abs(low - pivotS2) <= _swpHtfTol) or (not na(onLow) and math.abs(low - onLow) <= _swpHtfTol))
vizSigL = true
vizSigS = true
bool _oteRejLong  = inOTELong  and low  <= oteMidLong  and close > oteMidLong  and not csDoji
bool _oteRejShort = inOTEShort and high >= oteMidShort and close < oteMidShort and not csDoji
bool stratC_Long = _oteRejLong and swingRange > atr * _oteSwingMin
float _oteHalfBand    = swingRange > 0 ? swingRange * 0.085 : 0.0
bool _inOTESweetLong  = inOTELong  and _oteHalfBand > 0 and math.abs(close - oteMidLong)  <= _oteHalfBand
bool _inOTESweetShort = inOTEShort and _oteHalfBand > 0 and math.abs(close - oteMidShort) <= _oteHalfBand
float _oteSweetBonus  = (_inOTESweetLong or _inOTESweetShort) ? -0.155 : 0.0
bool stratC_Short = _oteRejShort and swingRange > atr * _oteSwingMin
int pivLenL = 3
int pivLenR = 3
float pivLow = ta.pivotlow(low, pivLenL, pivLenR)
float pivHigh = ta.pivothigh(high, pivLenL, pivLenR)
var float sl0 = na
var float sl1 = na
var float sh0 = na
var float sh1 = na
if not na(pivLow)
    sl1 := sl0
    sl0 := pivLow
if not na(pivHigh)
    sh1 := sh0
    sh0 := pivHigh
bool hlBullish = not na(sl0) and not na(sl1) and sl0 > sl1
bool llBearish = not na(sl0) and not na(sl1) and sl0 < sl1
bool hhBullish = not na(sh0) and not na(sh1) and sh0 > sh1
bool lhBearish = not na(sh0) and not na(sh1) and sh0 < sh1
f_revSupBelow() =>
    float best = na(_nearestSupBelow) ? -1e15 : _nearestSupBelow
    float recentLo = ta.lowest(low, 20)
    if not na(recentLo) and recentLo < close and recentLo > best
        best := recentLo
    if not na(sl0) and sl0 < close and sl0 > best
        best := sl0
    if not na(sl1) and sl1 < close and sl1 > best
        best := sl1
    best == -1e15 ? na : best
float obTpLong = _nearRes
float obTpShort = f_revSupBelow()
float obTpLongAdj = not na(obTpLong) ? obTpLong - f_dynTpBuffer(obTpLong) : na
float obTpShortAdj = not na(obTpShort) ? obTpShort + f_dynTpBuffer(obTpShort) : na
f_dynSwingATR() =>
    base = 1.0
    trendAdj = aerUptrend or aerDowntrend ? 0.5 : aerChoppy ? -0.2 : 0.0
    adxAdj = adx >= 35 ? 0.4 : adx >= 25 ? 0.2 : adx < 15 ? -0.2 : 0.0
    htfAdj = math.abs(htfConfScore) >= 6.0 ? 0.3 : math.abs(htfConfScore) >= 3.0 ? 0.15 : 0.0
    sessAdj = isOpen ? 0.3 : isMorning ? -0.09 : isLunch ? -0.15 : isAfternoon ? -0.075 : isLast ? 0.09 : inPreMkt ? -0.2 : inLondon ? -0.16 : inAsia ? -0.2 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.20 : atr < aerMeanATR * _volatLo ? -0.10 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.15 : relVol < _mfiWtLo ? 0.15 : 0.0
    math.max(0.3, base + trendAdj + adxAdj + htfAdj + sessAdj + volatAdj + volAdj)
_dynSwingATR = f_dynSwingATR()
var int lastLowKind  = 0
var int lastHighKind = 0
if showPivLabels and not na(pivLow) and not na(sl1)
    int thisKind = pivLow > sl1 ? 1 : -1
    bool sizeOk = math.abs(pivLow - sl1) >= _dynSwingATR * atr
    bool changed = thisKind != lastLowKind
    bool confirmed = (thisKind == 1 and hhBullish) or (thisKind == -1 and lhBearish)
    if sizeOk and changed and confirmed
        lblTxt = thisKind == 1 ? "▲ BULL" : "▼ BEAR"
        lblCol = thisKind == 1 ? color.new(color.green, 0) : color.new(color.red, 0)
        label.new(bar_index - pivLenR, pivLow - atr * 0.3, lblTxt, color=color.new(color.white, 100), textcolor=lblCol, style=label.style_label_up, size=size.normal)
    lastLowKind := thisKind
if showPivLabels and not na(pivHigh) and not na(sh1)
    int thisKind = pivHigh > sh1 ? 1 : -1
    bool sizeOk = math.abs(pivHigh - sh1) >= _dynSwingATR * atr
    bool changed = thisKind != lastHighKind
    bool confirmed = (thisKind == 1 and hlBullish) or (thisKind == -1 and llBearish)
    if sizeOk and changed and confirmed
        lblTxt = thisKind == 1 ? "▲ BULL" : "▼ BEAR"
        lblCol = thisKind == 1 ? color.new(color.green, 0) : color.new(color.red, 0)
        label.new(bar_index - pivLenR, pivHigh + atr * 0.3, lblTxt, color=color.new(color.white, 100), textcolor=lblCol, style=label.style_label_down, size=size.normal)
    lastHighKind := thisKind
f_nextLevelAbove(float refPrice) =>
    float result = na
    if not na(sh1) and sh1 > refPrice
        result := na(result) ? sh1 : math.min(result, sh1)
    if not na(sh0) and sh0 > refPrice
        result := na(result) ? sh0 : math.min(result, sh0)
    if not na(pivotR1) and pivotR1 > refPrice
        result := na(result) ? pivotR1 : math.min(result, pivotR1)
    if not na(pivotR2) and pivotR2 > refPrice
        result := na(result) ? pivotR2 : math.min(result, pivotR2)
    if not na(prevDayH) and prevDayH > refPrice
        result := na(result) ? prevDayH : math.min(result, prevDayH)
    if not na(prevDayC) and prevDayC > refPrice
        result := na(result) ? prevDayC : math.min(result, prevDayC)
    if not na(orbHigh) and orbLocked and orbHigh > refPrice
        result := na(result) ? orbHigh : math.min(result, orbHigh)
    result
f_nextLevelBelow(float refPrice) =>
    float result = na
    if not na(sl1) and sl1 < refPrice
        result := na(result) ? sl1 : math.max(result, sl1)
    if not na(sl0) and sl0 < refPrice
        result := na(result) ? sl0 : math.max(result, sl0)
    if not na(pivotS1) and pivotS1 < refPrice
        result := na(result) ? pivotS1 : math.max(result, pivotS1)
    if not na(pivotS2) and pivotS2 < refPrice
        result := na(result) ? pivotS2 : math.max(result, pivotS2)
    if not na(prevDayL) and prevDayL < refPrice
        result := na(result) ? prevDayL : math.max(result, prevDayL)
    if not na(prevDayC) and prevDayC < refPrice
        result := na(result) ? prevDayC : math.max(result, prevDayC)
    if not na(orbLow) and orbLocked and orbLow < refPrice
        result := na(result) ? orbLow : math.max(result, orbLow)
    result
bool fullBullStruct = hhBullish and hlBullish
bool fullBearStruct = llBearish and lhBearish
bool chochBull = fullBearStruct and not na(sh0) and close > sh0
bool chochBear = fullBullStruct and not na(sl0) and close < sl0
int smtPivLen = 5
float esPivH = ta.pivothigh(esHigh, smtPivLen, smtPivLen)
float esPivL = ta.pivotlow(esLow, smtPivLen, smtPivLen)
var float esSwHi1 = na, var float esSwHi2 = na
var float esSwLo1 = na, var float esSwLo2 = na
if not na(esPivH)
    esSwHi2 := esSwHi1
    esSwHi1 := esPivH
if not na(esPivL)
    esSwLo2 := esSwLo1
    esSwLo1 := esPivL
bool smtBearRaw = hhBullish and not na(esSwHi1) and not na(esSwHi2) and esSwHi1 <= esSwHi2
bool smtBullRaw = llBearish and not na(esSwLo1) and not na(esSwLo2) and esSwLo1 >= esSwLo2
f_smtLatch() =>
    adxAdj = adx >= 35 ? -3 : adx < 15 ? 5 : 0
    base = isOpen ? 10 : isMorning ? 12 : isLunch ? 20 : isAfternoon ? 16 : inAsia ? 25 : aerTrending ? 12 : 15
    volatAdj = atr > aerMeanATR * _volatHi ? -2 : atr < aerMeanATR * _volatLo ? 3 : 0
    volAdj = relVol >= _mfiWtHi ? -2 : relVol < _mfiWtLo ? 3 : 0
    regAdj = aerChoppy ? 4 : 0
    math.max(5, math.min(35, base + adxAdj + volatAdj + volAdj + regAdj))
_smtLatch = f_smtLatch()
var int smtBearBar = 0, var int smtBullBar = 0
if smtBearRaw
    smtBearBar := bar_index
if smtBullRaw
    smtBullBar := bar_index
int smtLatchLen = _smtLatch
bool smtBear = bar_index - smtBearBar <= smtLatchLen and smtBearBar > 0
bool smtBull = bar_index - smtBullBar <= smtLatchLen and smtBullBar > 0
float lowest30 = ta.lowest(low, 30)
float lowest90 = ta.lowest(low, 90)
float lowest180 = ta.lowest(low, 180)
float highest30 = ta.highest(high, 30)
float highest90 = ta.highest(high, 90)
float highest180= ta.highest(high, 180)
f_rangeLow() =>
    isOpen and adx >= 30 ? lowest30 : isMorning ? lowest90 : aerTrending and adx >= 25 ? lowest90 : isAfternoon ? lowest90 : isLast ? lowest90 : (isLunch or aerChoppy or inAsia or inPreMarket) ? lowest180 : lowest90
_rangeLow = f_rangeLow()
f_rangeHigh() =>
    isOpen and adx >= 30 ? highest30 : isMorning ? highest90 : aerTrending and adx >= 25 ? highest90 : isAfternoon ? highest90 : isLast ? highest90 : (isLunch or aerChoppy or inAsia or inPreMarket) ? highest180 : highest90
_rangeHigh = f_rangeHigh()
float rangeLoNow = _rangeLow
float rangeHiNow = _rangeHigh
float rangeLo = rangeLoNow[1]
float rangeHi = rangeHiNow[1]
float rangeSz = rangeHi - rangeLo
float rangePos = rangeSz > 0 ? (close - rangeLo) / rangeSz : 0.5
float bodySize = math.abs(close - open)
f_capitVolMult() =>
    aerChoppy ? 3.0 : (aerUptrend or aerDowntrend) ? 2.2 : 2.5
_capitVolMult = f_capitVolMult()
f_capitBodyAtrMult() =>
    aerChoppy ? 1.8 : (aerUptrend or aerDowntrend) ? 1.3 : 1.5
_capitBodyAtrMult = f_capitBodyAtrMult()
bool capitDown0 = close < open and relVol >= _capitVolMult and bodySize >= atr * _capitBodyAtrMult
bool capitDown1 = close[1] < open[1] and relVol[1] >= _capitVolMult and math.abs(close[1] - open[1]) >= atr * _capitBodyAtrMult
bool capitDown2 = close[2] < open[2] and relVol[2] >= _capitVolMult and math.abs(close[2] - open[2]) >= atr * _capitBodyAtrMult
bool capitDown3 = close[3] < open[3] and relVol[3] >= _capitVolMult and math.abs(close[3] - open[3]) >= atr * _capitBodyAtrMult
bool capitDown4 = close[4] < open[4] and relVol[4] >= _capitVolMult and math.abs(close[4] - open[4]) >= atr * _capitBodyAtrMult
bool capitUp0 = close > open and relVol >= _capitVolMult and bodySize >= atr * _capitBodyAtrMult
bool capitUp1 = close[1] > open[1] and relVol[1] >= _capitVolMult and math.abs(close[1] - open[1]) >= atr * _capitBodyAtrMult
bool capitUp2 = close[2] > open[2] and relVol[2] >= _capitVolMult and math.abs(close[2] - open[2]) >= atr * _capitBodyAtrMult
bool capitUp3 = close[3] > open[3] and relVol[3] >= _capitVolMult and math.abs(close[3] - open[3]) >= atr * _capitBodyAtrMult
bool capitUp4 = close[4] > open[4] and relVol[4] >= _capitVolMult and math.abs(close[4] - open[4]) >= atr * _capitBodyAtrMult
f_capitWindowDepth() =>
    adx >= 30 and (aerUptrend or aerDowntrend) ? 2 : isOpen ? 3 : isMorning ? 3 : isAfternoon ? 4 : (aerChoppy or inAsia or inPreMarket or isLunch) ? 5 : aerTrending ? 3 : 4
_capitWindowDepth = f_capitWindowDepth()
int capitDepth = _capitWindowDepth
bool capitulationDown = capitDepth >= 5 ? (capitDown0 or capitDown1 or capitDown2 or capitDown3 or capitDown4) : capitDepth >= 4 ? (capitDown0 or capitDown1 or capitDown2 or capitDown3) : capitDepth >= 3 ? (capitDown0 or capitDown1 or capitDown2) : (capitDown0 or capitDown1)
bool capitulationUp = capitDepth >= 5 ? (capitUp0 or capitUp1 or capitUp2 or capitUp3 or capitUp4) : capitDepth >= 4 ? (capitUp0 or capitUp1 or capitUp2 or capitUp3) : capitDepth >= 3 ? (capitUp0 or capitUp1 or capitUp2) : (capitUp0 or capitUp1)
float bodyLow = math.min(open, close)
float bodyHigh = math.max(open, close)
float lowerWick = bodyLow - low
float upperWick = high - bodyHigh
bool bigLowerWick = lowerWick >= atr * 0.8 and lowerWick > upperWick
bool bigUpperWick = upperWick >= atr * 0.8 and upperWick > lowerWick
bool bearRetest = aerDowntrend and high > ema21 and close < ema21 and not hlBullish
bool bullRetest = aerUptrend and low < ema21 and close > ema21 and not llBearish
bool bullRetestOk = bullRetest
bool bearRetestOk = bearRetest
bool shortHtfSlopeOk = h15s < h15s[5] and h60s < h60s[3]
bool shortVwapSlopeOk = vwapVal <= vwapVal[5]
bool shortRolledOver = close < ta.highest(high, 10) - atr * 1.0
int structGateCount = (shortHtfSlopeOk ? 1 : 0) + (shortVwapSlopeOk ? 1 : 0) + (shortRolledOver ? 1 : 0)
bool longHtfSlopeOk = h15s > h15s[5] and h60s > h60s[3]
bool longVwapSlopeOk = vwapVal >= vwapVal[5]
bool longRolledUp = close > ta.lowest(low, 10) + atr * 1.0
int longGateCount = (longHtfSlopeOk ? 1 : 0) + (longVwapSlopeOk ? 1 : 0) + (longRolledUp ? 1 : 0)
mfiVal = ta.mfi(hlc3, 14)
mfiBull = mfiVal > 50 and mfiVal < 80
mfiBear = mfiVal < 50 and mfiVal > 20
mfiExhBuy = mfiVal >= _mfiExhBuyThresh
mfiExhSel = mfiVal <= _mfiExhSelThresh
tickSma = request.security("USI:TICK", timeframe.period, ta.sma(close, 10), lookahead=barmerge.lookahead_off)
tickBull = not na(tickSma) and tickSma > 200
tickBear = not na(tickSma) and tickSma < -200
[vixClose, vixPrev] = request.security("CBOE:VX1!", timeframe.period,
    [close, close[10]], lookahead=barmerge.lookahead_off)
vixRising = not na(vixClose) and not na(vixPrev) and vixClose > vixPrev * _vixRiseThresh
vixFalling= not na(vixClose) and not na(vixPrev) and vixClose < vixPrev * _vixFallThresh
float _vixDaily  = request.security("CBOE:VX1!", "D", close, lookahead=barmerge.lookahead_off)
float _vixMedian = ta.percentile_linear_interpolation(_vixDaily, 252, 50)
float _vixAnchor = not na(_vixMedian) and _vixMedian > 0 ? _vixMedian : 17.84
vix9d = request.security("CBOE:VIX9D", timeframe.period, close, lookahead=barmerge.lookahead_off)
float _vixTermRatio = (not na(vix9d) and not na(vixClose) and vixClose > 0) ? vix9d / vixClose : 1.0
bool vixBackward = _vixTermRatio > 1.05
bool vixContango = _vixTermRatio < 0.95
xlkClose = request.security("AMEX:XLK", timeframe.period, close, lookahead=barmerge.lookahead_off)
float _xlkRet5 = not na(xlkClose) and not na(xlkClose[5]) and xlkClose[5] > 0 ? (xlkClose - xlkClose[5]) / xlkClose[5] : 0.0
float _nqRet5 = close[5] > 0 ? (close - close[5]) / close[5] : 0.0
bool xlkLeadsBull = _xlkRet5 > _nqRet5 + 0.001 and _xlkRet5 > 0
bool xlkLeadsBear = _xlkRet5 < _nqRet5 - 0.001 and _xlkRet5 < 0
bool xlkLagsNqBull = _nqRet5 > 0.002 and _xlkRet5 < _nqRet5 * 0.5
bool xlkLagsNqBear = _nqRet5 < -0.002 and _xlkRet5 > _nqRet5 * 0.5
regNow40 = ta.linreg(close, 40, 0)
regPrev40 = ta.linreg(close, 40, 1)
lrSlope = regNow40 - regPrev40
emaSlope = (ema9 - ema9[5]) / 5.0
vwapBias = close > vwapCalc ? 1.0 : close < vwapCalc ? -1.0 : 0.0
_h5Slope = h5f - h5s
f_aggRatioThresh(isBuy) =>
    base = 4.5
    regimeAdj = isBuy ? (aerDowntrend ? -0.5 : aerUptrend ? 0.5 : 0.0) : (aerUptrend ? -0.5 : aerDowntrend ? 0.5 : 0.0)
    adxAdj = adx >= 35 ? 0.3 : adx < 20 ? -0.3 : 0.0
    sessAdj = isOpen ? 0.5 : isMorning ? -0.15 : isLunch ? 0.0 : isAfternoon ? 0.0 : isLast ? 0.15 : inPreMkt ? 0.3 : inLondon ? 0.25 : inAsia ? 0.4 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.3 : atr < aerMeanATR * _volatLo ? -0.2 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.2 : relVol < _mfiWtLo ? 0.3 : 0.0
    htfFavors = isBuy ? htfConfScore : -htfConfScore
    htfAdj = htfFavors > 0 ? -math.min(0.3, math.max(0.0, (htfFavors - 2.0) * 0.15)) : math.min(0.3, math.max(0.0, (-htfFavors - 2.0) * 0.15))
    math.max(3.0, math.min(6.5, base + regimeAdj + adxAdj + sessAdj + volatAdj + volAdj + htfAdj))
f_aggVolThresh() =>
    base = 2.0
    sessAdj = isOpen ? 0.5 : isMorning ? -0.15 : isLunch ? 0.0 : isAfternoon ? 0.0 : isLast ? 0.15 : inPreMkt ? -0.3 : inLondon ? -0.24 : inAsia ? -0.3 : 0.0
    regimeAdj = aerTrending ? 0.3 : aerChoppy ? -0.3 : 0.0
    adxAdj = adx >= 35 ? 0.2 : adx < 20 ? -0.2 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.2 : atr < aerMeanATR * _volatLo ? -0.15 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.15 : relVol < _mfiWtLo ? 0.2 : 0.0
    math.max(1.3, math.min(3.0, base + sessAdj + regimeAdj + adxAdj + volatAdj + volAdj))
_aggVolThresh = f_aggVolThresh()
divLookback = input.int(5, "Div Pivot Lookback", group=g7)
divRsi = ta.rsi(close, 14)
phPrice = ta.pivothigh(high, divLookback, divLookback)
plPrice = ta.pivotlow(low, divLookback, divLookback)
phRsi = ta.pivothigh(divRsi, divLookback, divLookback)
plRsi = ta.pivotlow(divRsi, divLookback, divLookback)
var float prevPivotHigh = na
var float prevPivotHighRsi = na
var float prevPivotLow = na
var float prevPivotLowRsi = na
var float lastPH = na
var float lastPHRsi = na
var float lastPL = na
var float lastPLRsi = na
if not na(phPrice)
    prevPivotHigh := lastPH
    prevPivotHighRsi := lastPHRsi
    lastPH := phPrice
    lastPHRsi := phRsi
if not na(plPrice)
    prevPivotLow := lastPL
    prevPivotLowRsi := lastPLRsi
    lastPL := plPrice
    lastPLRsi := plRsi
absRange = high - low
absHighVol = fpTotalVol > avgVol * _exitVolClimax
absDeltaFlat = fpTotalVol > 0 ? math.abs(fpDelta) / fpTotalVol < 0.2 : false
absSmallMove = absRange <= 4.0 * syminfo.mintick
absSignal = absHighVol and absDeltaFlat and absSmallMove
absBull = absSignal and (not na(fpPocMid) ? close >= fpPocMid : close > open)
absBear = absSignal and (not na(fpPocMid) ? close < fpPocMid : close <= open)
aggBuy = fpBuyRatio >= f_aggRatioThresh(true) and fpTotalVol > avgVol * _aggVolThresh
aggSell = fpSellRatio >= f_aggRatioThresh(false) and fpTotalVol > avgVol * _aggVolThresh
fpDivBear = not na(phPrice) and not na(prevPivotHigh) and lastPH > prevPivotHigh and cumFpDelta < cumFpDelta[10] and fpTotalVol > avgVol * _divVolBear
fpDivBull = not na(plPrice) and not na(prevPivotLow) and lastPL < prevPivotLow and cumFpDelta > cumFpDelta[10] and fpTotalVol > avgVol * _divVolBull
bearDiv = not na(phPrice) and not na(prevPivotHigh) and not na(lastPHRsi) and not na(prevPivotHighRsi) and lastPH > prevPivotHigh and lastPHRsi < prevPivotHighRsi
bullDiv = not na(plPrice) and not na(prevPivotLow) and not na(lastPLRsi) and not na(prevPivotLowRsi) and lastPL < prevPivotLow and lastPLRsi > prevPivotLowRsi
bool hiddenBullDiv = not na(plPrice) and not na(prevPivotLow) and not na(lastPLRsi) and not na(prevPivotLowRsi) and lastPL > prevPivotLow and lastPLRsi < prevPivotLowRsi
bool hiddenBearDiv = not na(phPrice) and not na(prevPivotHigh) and not na(lastPHRsi) and not na(prevPivotHighRsi) and lastPH < prevPivotHigh and lastPHRsi > prevPivotHighRsi
float tickPersistBull    = math.sum(tickBull ? 1.0 : 0.0, i_persistWindow) / i_persistWindow
float tickPersistBear    = math.sum(tickBear ? 1.0 : 0.0, i_persistWindow) / i_persistWindow
float deltaPersistBull   = math.sum(fpDeltaBull ? 1.0 : 0.0, i_persistWindow) / i_persistWindow
float deltaPersistBear   = math.sum(fpDeltaBear ? 1.0 : 0.0, i_persistWindow) / i_persistWindow
float mfiPersistBull     = math.sum(mfiBull ? 1.0 : 0.0, i_persistWindow) / i_persistWindow
float mfiPersistBear     = math.sum(mfiBear ? 1.0 : 0.0, i_persistWindow) / i_persistWindow
bool  rawFlowDirBull     = (fpBuyVol - fpSellVol) > 0 and close > open
bool  rawFlowDirBear     = (fpBuyVol - fpSellVol) < 0 and close < open
float rawFlowPersistBull = math.sum(rawFlowDirBull ? 1.0 : 0.0, i_persistWindow) / i_persistWindow
float rawFlowPersistBear = math.sum(rawFlowDirBear ? 1.0 : 0.0, i_persistWindow) / i_persistWindow
float _sqzMomCapAtr = aerTrending and adx >= 30 ? 1.4 : aerChoppy ? 0.7 : 1.0
float _sqzMomNorm = atr > 0 and _sqzMomCapAtr > 0 ? math.min(1.0, math.abs(sqzMom) / (atr * _sqzMomCapAtr)) : 0.0
f_dirScoreAcc() =>
    score = 0.0
    score += lrSlope > 0 ? 1.0 : lrSlope < 0 ? -1.0 : 0.0
    score += emaSlope > 0 ? 1.0 : emaSlope < 0 ? -1.0 : 0.0
    score += vwapBias
    score += math.max(-1.0, math.min(1.0, htfConfScore / 5.5))
    score += tickPersistBull - tickPersistBear
    float vixMag = not na(vixClose) and _vixAnchor > 0 ? math.min(1.5, math.max(0.5, vixClose / _vixAnchor)) : 1.0
    score += vixFalling ? vixMag : vixRising ? -vixMag : 0.0
    score += xlkLeadsBull ? 1.0 : xlkLeadsBear ? -1.0 : 0.0
    float _donchianExtremeUp = highest30 > 0.0 and atr > 0.0 ? math.max(0.0, math.min(1.0, 1.0 - (highest30 - close) / (atr * 0.5))) : 0.0
    float _donchianExtremeDn = lowest30 > 0.0 and atr > 0.0 ? math.max(0.0, math.min(1.0, 1.0 - (close - lowest30) / (atr * 0.5))) : 0.0
    float _donchianBias = _donchianExtremeUp - _donchianExtremeDn
    score += aerTrending ? _donchianBias : aerChoppy ? -_donchianBias : 0.0
    score += deltaPersistBull - deltaPersistBear
    score += fpDeltaBull ? (0.5 + 0.5 * deltaMag) : fpDeltaBear ? -(0.5 + 0.5 * deltaMag) : 0.0
    score += mfiPersistBull - mfiPersistBear
    score += mfiExhBuy ? -1.0 : mfiExhSel ? 1.0 : 0.0
    score += rawFlowPersistBull - rawFlowPersistBear
    score += aerUptrend ? 1.0 : aerDowntrend ? -1.0 : 0.0
    score += dailyBias
    if hurstPersist
        score += aerUptrend ? 1.0 : aerDowntrend ? -1.0 : 0.0
    if hurstRevert
        score += aerUptrend ? -0.5 : aerDowntrend ? 0.5 : 0.0
    score += adfTrending and aerUptrend ? 1.0 : adfTrending and aerDowntrend ? -1.0 : 0.0
    score += adfMeanRevert and aerUptrend ? -1.0 : adfMeanRevert and aerDowntrend ? 1.0 : 0.0
    score += rsStrong ? 0.5 : rsWeak ? -0.5 : 0.0
    score += macdBull ? 0.5 : macdBear ? -0.5 : 0.0
    score += vrzBias
    score += close > ema200 ? 0.5 : close < ema200 ? -0.5 : 0.0
    float _strucMul = math.max(0.7, math.min(1.15, 0.7 + relVol * 0.3))
    score += _strucMul * (fullBullStruct ? 1.0 : fullBearStruct ? -1.0 : (hlBullish and hhBullish ? 0.5 : llBearish and lhBearish ? -0.5 : 0.0))
    score += smtBull ? 1.0 : smtBear ? -1.0 : 0.0
    score += chochBull ? 1.0 : chochBear ? -1.0 : 0.0
    float _candlePatternBull = (csBullEngulf or csHammer or bigLowerWick) and not csDoji ? 0.5 : 0.0
    float _candlePatternBear = (csBearEngulf or csShootSt or bigUpperWick) and not csDoji ? 0.5 : 0.0
    float _candleBodyBull = csBullBar and csBodyToRange >= 0.7 and not csDoji ? math.min(0.4, (csBodyToRange - 0.7) * 1.33) : 0.0
    float _candleBodyBear = csBearBar and csBodyToRange >= 0.7 and not csDoji ? math.min(0.4, (csBodyToRange - 0.7) * 1.33) : 0.0
    float _candleVolTier  = relVol >= 1.0 ? 0.1 : 0.0
    float _candleBullSum  = math.min(1.0, _candlePatternBull + _candleBodyBull + (_candlePatternBull > 0 or _candleBodyBull > 0 ? _candleVolTier : 0.0))
    float _candleBearSum  = math.min(1.0, _candlePatternBear + _candleBodyBear + (_candlePatternBear > 0 or _candleBodyBear > 0 ? _candleVolTier : 0.0))
    score += _candleBullSum - _candleBearSum
    float _pocStrengthMul = nodeStrength >= 15 ? 1.3 : nodeStrength >= 10 ? 1.0 : 0.7
    score += pocBuyPct > 60 ? _pocStrengthMul : pocBuyPct < 40 ? -_pocStrengthMul : 0.0
    float pocDelta = pocRawBuy - pocRawSell
    score += nodeStrength >= 10 ? (pocDelta > 0 ? 1.0 : pocDelta < 0 ? -1.0 : 0.0) : 0.0
    score += nearPoV and close > open ? 1.0 : nearPoV and close < open ? -1.0 : 0.0
    score += (bullBOS or _orbBullBreakNow) ? 1.0 : (bearBOS or _orbBearBreakNow) ? -1.0 : 0.0
    score += sqzFired and sqzMom > 0 ? 1.0 : sqzFired and sqzMom < 0 ? -1.0 : 0.0
    score += sqzMom > 0 ? _sqzMomNorm : sqzMom < 0 ? -_sqzMomNorm : 0.0
    score += bullRetestOk ? 1.0 : bearRetestOk ? -1.0 : 0.0
    score += momRecentBull ? 1.0 : momRecentBear ? -1.0 : 0.0
    score += (aerUptrend and not aerUptrend[1]) ? 1.0 : (aerDowntrend and not aerDowntrend[1]) ? -1.0 : 0.0
    score += absBull ? 1.0 : absBear ? -1.0 : 0.0
    score += bullDiv ? 1.0 : bearDiv ? -1.0 : 0.0
    score += hiddenBullDiv ? 1.0 : hiddenBearDiv ? -1.0 : 0.0
    score += fpDivBull ? 1.0 : fpDivBear ? -1.0 : 0.0
    score += aggBuy ? 1.0 : aggSell ? -1.0 : 0.0
    score += bearSweep ? (_bearSweepClustered ? 1.5 : 1.0) : bullSweep ? -(_bullSweepClustered ? 1.5 : 1.0) : 0.0
    score += capitulationDown ? 1.0 : capitulationUp ? -1.0 : 0.0
    float _aerERContrib = math.max(-1.0, math.min(1.0, _aerERZ / i_dirZThresh))
    bool  _aerERAligned = (aerUptrend and _aerERContrib > 0.0) or (aerDowntrend and _aerERContrib < 0.0)
    score += _aerERAligned ? _aerERContrib : 0.0
    score += _cumDeltaContinuity
    score += (_slopeAccelNorm > 0.0 and fpDeltaBull) ? _slopeAccelNorm : (_slopeAccelNorm < 0.0 and fpDeltaBear) ? _slopeAccelNorm : 0.0
    bool _velExhaust = _marketVel < _marketVel[3] and _marketVel[3] >= _marketVelAvg * 0.95
    score += (aerUptrend and _velExhaust) ? -1.0 : (aerDowntrend and _velExhaust) ? 1.0 : 0.0
    bool _volDivBearExhaust = close > close[5] and _volSma5 < _volSma5[5] * 0.85
    bool _volDivBullExhaust = close < close[5] and _volSma5 < _volSma5[5] * 0.85
    score += _volDivBearExhaust ? -1.0 : _volDivBullExhaust ? 1.0 : 0.0
    bool _rangeContractBullExhaust = _rangeSma5[5] > 0 and _rangeSma5 < _rangeSma5[5] * 0.75 and close > close[10]
    bool _rangeContractBearExhaust = _rangeSma5[5] > 0 and _rangeSma5 < _rangeSma5[5] * 0.75 and close < close[10]
    score += _rangeContractBullExhaust ? -1.0 : _rangeContractBearExhaust ? 1.0 : 0.0
    bool _momDecelBull_now = sqzMom > 0 and sqzMom < sqzMom[1] and sqzMom[1] < sqzMom[2]
    bool _momDecelBear_now = sqzMom < 0 and sqzMom > sqzMom[1] and sqzMom[1] > sqzMom[2]
    bool _freeBarAbove_now = low > bbUpper
    bool _freeBarBelow_now = high < bbLower
    float _bullExhaustPersist = math.sum((_momDecelBull_now or _freeBarAbove_now) ? 1.0 : 0.0, i_persistWindow) / i_persistWindow
    float _bearExhaustPersist = math.sum((_momDecelBear_now or _freeBarBelow_now) ? 1.0 : 0.0, i_persistWindow) / i_persistWindow
    score += _bearExhaustPersist - _bullExhaustPersist
    score
float dirScoreFull = f_dirScoreAcc()
float _alpha = 2.0 / (i_dirZLookback + 1.0)
var float dirScoreMean = na
var float dirScoreVar  = na
float _prevMean = na(dirScoreMean) ? dirScoreFull : dirScoreMean
float _diff     = dirScoreFull - _prevMean
dirScoreMean := na(dirScoreMean) ? dirScoreFull : _prevMean + _alpha * _diff
dirScoreVar  := na(dirScoreVar)  ? 0.0           : (1.0 - _alpha) * (dirScoreVar + _alpha * _diff * _diff)
float dirScoreStdev = math.sqrt(dirScoreVar)
float dirScoreZ     = dirScoreStdev > 0 ? (dirScoreFull - dirScoreMean) / dirScoreStdev : 0.0
float ema21DistAtr = (close - ema21) / atr
float vwapDistAtr = (close - vwapVal) / atr
float _meanDist     = math.max(math.abs(ema21DistAtr), math.abs(vwapDistAtr))
float _meanDistMean = ta.sma(_meanDist, 200)
float _meanDistStd  = ta.stdev(_meanDist, 200)
float _meanDistZ    = _meanDistStd > 0.0 ? (_meanDist - _meanDistMean) / _meanDistStd : 0.0
var int barsSinceBullStrong = 999
var int barsSinceBearStrong = 999
var int barsSinceBullWeak = 999
var int barsSinceBearWeak = 999
float _pivotMinSwing = atr * swingATRMult
bool _hlPivotFresh = hlBullish and (na(sl0[1]) or sl0 != sl0[1]) and (sl0 - sl1) > _pivotMinSwing
bool _lhPivotFresh = lhBearish and (na(sh0[1]) or sh0 != sh0[1]) and (sh1 - sh0) > _pivotMinSwing
bool _bullStrongNow = bullBOS or chochBull
bool _bearStrongNow = bearBOS or chochBear
bool _bullWeakNow = momRecentBull or smtBullRaw or _hlPivotFresh
bool _bearWeakNow = momRecentBear or smtBearRaw or _lhPivotFresh
if _bullStrongNow
    barsSinceBullStrong := 0
else
    barsSinceBullStrong := barsSinceBullStrong + 1
if _bearStrongNow
    barsSinceBearStrong := 0
else
    barsSinceBearStrong := barsSinceBearStrong + 1
if _bullWeakNow
    barsSinceBullWeak := 0
else
    barsSinceBullWeak := barsSinceBullWeak + 1
if _bearWeakNow
    barsSinceBearWeak := 0
else
    barsSinceBearWeak := barsSinceBearWeak + 1
int ctxWeakLB = math.max(2, math.min(8, 5 + (isOpen ? -2 : isMorning ? -1 : isLunch ? 3 : isAfternoon ? 0 : isLast ? 1 : inPreMkt ? 2 : inLondon ? 1 : inAsia ? 3 : 0) + (aerTrending ? 2 : aerChoppy ? -2 : 0) + (adx >= 30 ? 1 : adx < 20 ? -1 : 0) + (atr > aerMeanATR * _volatHi ? -1 : atr < aerMeanATR * _volatLo ? 1 : 0) + (relVol >= _mfiWtHi ? -1 : relVol < _mfiWtLo ? 1 : 0)))
int ctxStrongLB = math.max(8, math.min(18, ctxWeakLB + 7))
float ctxStrongW = math.max(1.5, math.min(3.0, 2.0 + (aerTrending ? 0.5 : aerChoppy ? -0.4 : 0.0) + (adx >= 30 ? 0.3 : adx < 20 ? -0.2 : 0.0) + (isOpen ? 0.2 : isMorning ? 0.1 : isLunch ? -0.2 : isLast ? -0.1 : inPreMkt ? -0.2 : inLondon ? 0.1 : inAsia ? -0.2 : 0.0) + (atr > aerMeanATR * _volatHi ? 0.2 : atr < aerMeanATR * _volatLo ? -0.1 : 0.0) + (relVol >= _mfiWtHi ? 0.2 : relVol < _mfiWtLo ? -0.1 : 0.0)))
float ctxWeakW = math.max(0.5, math.min(1.8, 1.0 + (aerTrending ? -0.2 : aerChoppy ? 0.3 : 0.0) + (adx >= 30 ? -0.1 : adx < 20 ? 0.2 : 0.0) + (isLunch ? 0.2 : isLast ? 0.1 : inPreMkt ? 0.2 : inAsia ? 0.2 : isOpen ? -0.1 : 0.0) + (atr > aerMeanATR * _volatHi ? -0.2 : atr < aerMeanATR * _volatLo ? 0.3 : 0.0) + (relVol >= _mfiWtHi ? -0.1 : relVol < _mfiWtLo ? 0.2 : 0.0)))
float ctxBlockThresh = math.max(1.2, math.min(3.5, 2.0 + (aerTrending ? 0.5 : aerChoppy ? -0.4 : 0.0) + (adx >= 30 ? 0.3 : adx < 20 ? -0.2 : 0.0) + (isOpen ? 0.4 : isMorning ? 0.2 : isLunch ? -0.3 : isLast ? 0.1 : inPreMkt ? -0.2 : inAsia ? -0.3 : 0.0) + (atr > aerMeanATR * _volatHi ? 0.2 : atr < aerMeanATR * _volatLo ? -0.2 : 0.0) + (relVol >= _mfiWtHi ? 0.2 : relVol < _mfiWtLo ? -0.2 : 0.0) + (hurstPersist ? 0.3 : hurstRevert ? -0.2 : 0.0)))
float ctxBullScore = (barsSinceBullStrong <= ctxStrongLB ? ctxStrongW : 0.0) + (barsSinceBullWeak <= ctxWeakLB ? ctxWeakW : 0.0)
float ctxBearScore = (barsSinceBearStrong <= ctxStrongLB ? ctxStrongW : 0.0) + (barsSinceBearWeak <= ctxWeakLB ? ctxWeakW : 0.0)
bool ctxBlocksLong = ctxBearScore >= ctxBlockThresh
bool ctxBlocksShort = ctxBullScore >= ctxBlockThresh
sigL = vizSigL and (stratB_Long or stratC_Long)
sigS = vizSigS and (stratB_Short or stratC_Short)
f_srProxDist() =>
    base = 0.5
    sessAdj = isOpen ? 0.2 : isMorning ? -0.06 : isLunch ? -0.1 : isAfternoon ? -0.05 : isLast ? 0.06 : inPreMkt ? -0.15 : inLondon ? -0.12 : inAsia ? -0.15 : 0.0
    regimeAdj= aerTrending ? 0.15 : aerChoppy ? -0.1 : 0.0
    adxAdj = adx >= 30 ? 0.1 : adx < 20 ? -0.1 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? 0.1 : atr < aerMeanATR * _volatLo ? -0.05 : 0.0
    volAdj = relVol >= _mfiWtHi ? 0.05 : relVol < _mfiWtLo ? -0.05 : 0.0
    htfAdj = math.abs(htfConfScore) >= 6.0 ? 0.10 : math.abs(htfConfScore) >= 3.0 ? 0.05 : 0.0
    math.max(0.2, math.min(0.9, base + sessAdj + regimeAdj + adxAdj + volatAdj + volAdj + htfAdj)) * atr
_srProxDist = f_srProxDist()
f_nearKeySupport() =>
    proxDist = _srProxDist
    nearPM = not na(pmLow) and math.abs(close - pmLow) < proxDist
    nearPMM = not na(pmMid) and math.abs(close - pmMid) < proxDist
    nearOR = orbLocked and not na(orbLow) and math.abs(close - orbLow) < proxDist
    nearORM = orbLocked and not na(orbMid) and math.abs(close - orbMid) < proxDist
    nearVW = math.abs(close - vwapVal) < proxDist and close > vwapVal
    nearPP = not na(pivotPP) and math.abs(close - pivotPP) < proxDist and close > pivotPP
    nearS1 = not na(pivotS1) and math.abs(close - pivotS1) < proxDist
    wickBounce = (math.min(open, close) - low) > math.abs(close - open) * 0.5
    flowBounce = close > open and fpDeltaBull
    volBounce = close > open and relVol >= _confVolBounce
    bounce = wickBounce or flowBounce or volBounce
    (nearPM or nearPMM or nearOR or nearORM or nearVW or nearPP or nearS1) and bounce
_nearKeySupport = f_nearKeySupport()
f_nearKeyResistance() =>
    proxDist = _srProxDist
    nearPM = not na(pmHigh) and math.abs(close - pmHigh) < proxDist
    nearPMM = not na(pmMid) and math.abs(close - pmMid) < proxDist
    nearOR = orbLocked and not na(orbHigh) and math.abs(close - orbHigh) < proxDist
    nearORM = orbLocked and not na(orbMid) and math.abs(close - orbMid) < proxDist
    nearVW = math.abs(close - vwapVal) < proxDist and close < vwapVal
    nearPP = not na(pivotPP) and math.abs(close - pivotPP) < proxDist and close < pivotPP
    nearR1 = not na(pivotR1) and math.abs(close - pivotR1) < proxDist
    wickReject = (high - math.max(open, close)) > math.abs(close - open) * 0.5
    flowReject = close < open and fpDeltaBear
    volReject = close < open and relVol >= _confVolBounce
    reject = wickReject or flowReject or volReject
    (nearPM or nearPMM or nearOR or nearORM or nearVW or nearPP or nearR1) and reject
_nearKeyResistance = f_nearKeyResistance()
f_hotZone() =>
    momNorm = math.abs(sqzMom) / atr
    momThresh = aerTrending ? 0.25 : aerChoppy ? 0.45 : 0.35
    sessAdj = isOpen ? -0.08 : isMorning ? 0.024 : isLunch ? 0.1 : isAfternoon ? 0.05 : isLast ? -0.024 : inPreMkt ? 0.1 : inLondon ? 0.08 : inAsia ? 0.1 : 0.0
    adxAdj = adx >= 30 ? -0.05 : adx < 20 ? 0.05 : 0.0
    volatAdj = atr > aerMeanATR * _volatHi ? -0.05 : atr < aerMeanATR * _volatLo ? 0.08 : 0.0
    volAdj = relVol >= _mfiWtHi ? -0.05 : relVol < _mfiWtLo ? 0.08 : 0.0
    htfAdj = math.abs(htfConfScore) >= 6.0 ? -0.06 : math.abs(htfConfScore) >= 3.0 ? -0.03 : 0.0
    adjThresh = math.max(0.1, momThresh + sessAdj + adxAdj + volatAdj + volAdj + htfAdj)
    momNorm >= adjThresh and atr >= aerMeanATR * 0.85
_hotZone = f_hotZone()
bool inHotZone = _hotZone
float _volAdj_floor   = math.max(-0.23, math.min(0.29, (1.0 - relVol) * 0.29))
float _adxAdj_floor   = math.max(-0.12, math.min(0.23, (22.5 - adx) * 0.023))
float _aerDev_floor   = aerER - aerDynThresh
float _hurstDev_floor = hurst - 0.5
float _sessFloorAdj = isOpen ? -0.16 : isMorning ? -0.20 : isLunch ? 0.24 : isAfternoon ? -0.08 : isLast ? -0.12 : inPreMkt ? 0.20 : inLondon ? 0.08 : inAsia ? 0.28 : 0.0
float _volatFloorAdj = atr > aerMeanATR * 1.5 ? 0.12 : atr > aerMeanATR * 1.2 ? -0.04 : atr < aerMeanATR * 0.8 ? 0.08 : 0.0
float _vixTermFloorAdj = vixBackward ? 0.20 : vixContango ? -0.08 : 0.0
float _ctxFloorAdj = _sessFloorAdj + _volatFloorAdj + _vixTermFloorAdj  // VIX/XLK/cluster removed: already in dirScoreFull. _regimeFloorAdj removed: regime in band/vol/dir factors.
f_longConfidence() =>
    dir = math.max(-1.0, math.min(1.0, dirScoreZ / i_dirZThresh))
    mean = 1.0 - math.max(0.0, _meanDistZ - 1.0) * 0.5
    mean := mean < 0.0 ? 0.0 : mean
    bandExtreme = aerUptrend ? 0.10 : aerChoppy ? 0.30 : 0.20
    bandFar     = aerUptrend ? 0.45 : aerChoppy ? 0.65 : 0.55
    float _longExt = math.max(bbPos, rangePos)
    band = _longExt <= bandExtreme ? 1.0 : _longExt <= bandFar ? (bandFar - _longExt) / (bandFar - bandExtreme) : 0.0
    srRaw = 0.0
    if _nearKeySupport
        srDistAtr = atr > 0 ? math.min(5.0, _srProxDist / atr) : 0.5
        srRaw := math.max(0.4, math.min(1.0, 1.0 - srDistAtr * 0.3))
    else if _nearKeyResistance
        srDistAtrR = atr > 0 ? math.min(5.0, _srProxDist / atr) : 0.5
        srRaw := math.max(-0.5, math.min(-0.2, -(1.0 - srDistAtrR * 0.3) * 0.5))
    sr = srRaw
    vol = aerTrending and _realizedVolRel >= 1.1 ? 0.5 : aerChoppy and _realizedVolRel >= 1.1 ? 0.3 : aerChoppy and _realizedVolRel <= 0.85 ? 0.4 : 0.0
    ctxBonus = 0.0
    ctxBonus += rsiBull ? 0.05 : rsiBear ? -0.05 : 0.0
    ctxBonus += ema21 > ema100 ? 0.05 : ema21 < ema100 ? -0.05 : 0.0
    ctxBonus += ema9 > ema21 ? 0.025 : ema9 < ema21 ? -0.025 : 0.0
    ctxBonus += csBullCommit ? 0.05 : 0.0
    ctxBonus += liquidityOk ? 0.05 : -0.05
    ctxBonus += ctxBlocksLong ? -0.05 : 0.0
    ctxBonus += _h5Slope > 0 ? 0.03 : _h5Slope < 0 ? -0.03 : 0.0
    ctxBonus += longGateCount >= 2 ? 0.05 : 0.0
    ctx = ctxBonus
    regimeAdj = -_ctxFloorAdj
    aerAdj    = math.max(-0.19, math.min(0.19, _aerDev_floor   * +0.38))
    adxAbs    = -_adxAdj_floor
    relVolAbs = -_volAdj_floor
    hurstAbs  = math.max(-0.14, math.min(0.14, _hurstDev_floor * +0.19))
    absorbed = regimeAdj + aerAdj + adxAbs + relVolAbs + hurstAbs
    factorCount = (dir > 0 ? 1 : 0) + (mean > 0 ? 1 : 0) + (band > 0 ? 1 : 0) + (sr > 0 ? 1 : 0) + (vol > 0 ? 1 : 0)
    activeRatio = factorCount / 5.0
    agreement = activeRatio - 0.5
    dir + mean + band + sr + vol + ctx + agreement + absorbed
_longConfidence = f_longConfidence()
f_shortConfidence() =>
    dir = math.max(-1.0, math.min(1.0, -dirScoreZ / i_dirZThresh))
    mean = 1.0 - math.max(0.0, _meanDistZ - 1.0) * 0.5
    mean := mean < 0.0 ? 0.0 : mean
    bandExtreme = aerDowntrend ? 0.90 : aerChoppy ? 0.70 : 0.80
    bandFar     = aerDowntrend ? 0.55 : aerChoppy ? 0.35 : 0.45
    float _shortExt = math.min(bbPos, rangePos)
    band = _shortExt >= bandExtreme ? 1.0 : _shortExt >= bandFar ? (_shortExt - bandFar) / (bandExtreme - bandFar) : 0.0
    srRaw = 0.0
    if _nearKeyResistance
        srDistAtr = atr > 0 ? math.min(5.0, _srProxDist / atr) : 0.5
        srRaw := math.max(0.4, math.min(1.0, 1.0 - srDistAtr * 0.3))
    else if _nearKeySupport
        srDistAtrS = atr > 0 ? math.min(5.0, _srProxDist / atr) : 0.5
        srRaw := math.max(-0.5, math.min(-0.2, -(1.0 - srDistAtrS * 0.3) * 0.5))
    sr = srRaw
    vol = aerTrending and _realizedVolRel >= 1.1 ? 0.5 : aerChoppy and _realizedVolRel >= 1.1 ? 0.3 : aerChoppy and _realizedVolRel <= 0.85 ? 0.4 : 0.0
    ctxBonus = 0.0
    ctxBonus += rsiBear ? 0.05 : rsiBull ? -0.05 : 0.0
    ctxBonus += ema21 < ema100 ? 0.05 : ema21 > ema100 ? -0.05 : 0.0
    ctxBonus += ema9 < ema21 ? 0.025 : ema9 > ema21 ? -0.025 : 0.0
    ctxBonus += csBearCommit ? 0.05 : 0.0
    ctxBonus += liquidityOk ? 0.05 : -0.05
    ctxBonus += ctxBlocksShort ? -0.05 : 0.0
    ctxBonus += _h5Slope < 0 ? 0.03 : _h5Slope > 0 ? -0.03 : 0.0
    ctxBonus += structGateCount >= 2 ? 0.05 : 0.0
    ctx = ctxBonus
    regimeAdj = -_ctxFloorAdj
    aerAdj    = math.max(-0.19, math.min(0.19, _aerDev_floor   * +0.38))
    adxAbs    = -_adxAdj_floor
    relVolAbs = -_volAdj_floor
    hurstAbs  = math.max(-0.14, math.min(0.14, _hurstDev_floor * +0.19))
    absorbed = regimeAdj + aerAdj + adxAbs + relVolAbs + hurstAbs
    factorCount = (dir > 0 ? 1 : 0) + (mean > 0 ? 1 : 0) + (band > 0 ? 1 : 0) + (sr > 0 ? 1 : 0) + (vol > 0 ? 1 : 0)
    activeRatio = factorCount / 5.0
    agreement = activeRatio - 0.5
    dir + mean + band + sr + vol + ctx + agreement + absorbed
_shortConfidence = f_shortConfidence()
float confLong = _longConfidence
float confShort = _shortConfidence
float _ptDir         = math.max(-1.0, math.min(1.0, dirScoreZ / i_dirZThresh))
float _ptDirShort    = math.max(-1.0, math.min(1.0, -dirScoreZ / i_dirZThresh))
float _ptMean        = math.max(0.0, 1.0 - math.max(0.0, _meanDistZ - 1.0) * 0.5)
float _ptBandExtL    = aerUptrend ? 0.10 : aerChoppy ? 0.30 : 0.20
float _ptBandFarL    = aerUptrend ? 0.45 : aerChoppy ? 0.65 : 0.55
float _ptLongExt     = math.max(bbPos, rangePos)
float _ptBandLong    = _ptLongExt <= _ptBandExtL ? 1.0 : _ptLongExt <= _ptBandFarL ? (_ptBandFarL - _ptLongExt) / (_ptBandFarL - _ptBandExtL) : 0.0
float _ptBandExtS    = aerDowntrend ? 0.90 : aerChoppy ? 0.70 : 0.80
float _ptBandFarS    = aerDowntrend ? 0.55 : aerChoppy ? 0.35 : 0.45
float _ptShortExt    = math.min(bbPos, rangePos)
float _ptBandShort   = _ptShortExt >= _ptBandExtS ? 1.0 : _ptShortExt >= _ptBandFarS ? (_ptShortExt - _ptBandFarS) / (_ptBandExtS - _ptBandFarS) : 0.0
float _ptSrLong = 0.0
if _nearKeySupport
    _ptSrLong := math.max(0.4, math.min(1.0, 1.0 - (atr > 0 ? math.min(5.0, _srProxDist / atr) : 0.5) * 0.3))
else if _nearKeyResistance
    _ptSrLong := math.max(-0.5, math.min(-0.2, -(1.0 - (atr > 0 ? math.min(5.0, _srProxDist / atr) : 0.5) * 0.3) * 0.5))
float _ptSrShort = 0.0
if _nearKeyResistance
    _ptSrShort := math.max(0.4, math.min(1.0, 1.0 - (atr > 0 ? math.min(5.0, _srProxDist / atr) : 0.5) * 0.3))
else if _nearKeySupport
    _ptSrShort := math.max(-0.5, math.min(-0.2, -(1.0 - (atr > 0 ? math.min(5.0, _srProxDist / atr) : 0.5) * 0.3) * 0.5))
float _ptVol         = aerTrending and _realizedVolRel >= 1.1 ? 0.5 : aerTrending and _realizedVolRel <= 0.85 ? 0.10 : aerChoppy and _realizedVolRel >= 1.1 ? 0.3 : aerChoppy and _realizedVolRel <= 0.85 ? 0.4 : not aerTrending and not aerChoppy and _realizedVolRel >= 1.1 ? 0.30 : not aerTrending and not aerChoppy and _realizedVolRel <= 0.85 ? 0.15 : 0.0
float _ptRegimeAdj   = -_ctxFloorAdj
float _ptAerAdj      = math.max(-0.19, math.min(0.19, _aerDev_floor * +0.38))
float _ptAdxAbs      = -_adxAdj_floor
float _ptRelVolAbs   = -_volAdj_floor
float _ptHurstAbs    = math.max(-0.14, math.min(0.14, _hurstDev_floor * +0.19))
float _ptHtfBiasL    = math.max(-0.10, math.min(0.10, htfConfScore *  0.0167))
float _ptHtfBiasS    = math.max(-0.10, math.min(0.10, htfConfScore * -0.0167))
float _ptHurstAbsMR  = math.max(-0.14, math.min(0.14, _hurstDev_floor * -0.19))
float _ptSqzMomNorm  = ta.sma(math.abs(sqzMom), 50)
float _ptSqzMomMag   = _ptSqzMomNorm > 0 ? math.min(1.0, math.abs(sqzMom) / (_ptSqzMomNorm * 2.0)) : 0.0
float _ptSqzBandPosL = bbPos > 0.85 ? math.max(-0.20, -(bbPos - 0.85) * 1.33) : 0.0
float _ptSqzBandPosS = bbPos < 0.15 ? math.max(-0.20, -(0.15 - bbPos) * 1.33) : 0.0
float _ptCtxRsiL     = rsiBull ? 0.05 : rsiBear ? -0.05 : 0.0
float _ptCtxEmaLongL = ema21 > ema100 ? 0.05 : ema21 < ema100 ? -0.05 : 0.0
float _ptCtxEmaShortL= ema9 > ema21 ? 0.025 : ema9 < ema21 ? -0.025 : 0.0
float _ptCtxCandleL  = csBullCommit ? 0.05 : csBearCommit ? -0.05 : 0.0
float _ptCtxLiquidL  = liquidityOk ? 0.05 : -0.05
float _ptCtxBlocksL  = ctxBlocksLong ? -0.05 : 0.0
float _ptCtxH5L      = _h5Slope > 0 ? 0.03 : _h5Slope < 0 ? -0.03 : 0.0
float _ptCtxGateL    = longGateCount >= 2 ? 0.05 : 0.0
float _ptCtxRsiS     = rsiBear ? 0.05 : rsiBull ? -0.05 : 0.0
float _ptCtxEmaLongS = ema21 < ema100 ? 0.05 : ema21 > ema100 ? -0.05 : 0.0
float _ptCtxEmaShortS= ema9 < ema21 ? 0.025 : ema9 > ema21 ? -0.025 : 0.0
float _ptCtxCandleS  = csBearCommit ? 0.05 : csBullCommit ? -0.05 : 0.0
float _ptCtxLiquidS  = liquidityOk ? 0.05 : -0.05
float _ptCtxBlocksS  = ctxBlocksShort ? -0.05 : 0.0
float _ptCtxH5S      = _h5Slope < 0 ? 0.03 : _h5Slope > 0 ? -0.03 : 0.0
float _ptCtxGateS    = structGateCount >= 2 ? 0.05 : 0.0
f_mainConfLong() =>
    ctx = _ptCtxRsiL + _ptCtxEmaLongL + _ptCtxEmaShortL + _ptCtxCandleL + _ptCtxLiquidL + _ptCtxBlocksL + _ptCtxH5L + _ptCtxGateL
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptAdxAbs + _ptRelVolAbs + _ptHurstAbs
    factorCount = (_ptDir > 0 ? 1 : 0) + (_ptMean > 0.5 ? 1 : 0) + (_ptBandLong > 0 ? 1 : 0) + (_ptSrLong > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 5.0 - 0.5
    _ptDir + _ptMean + _ptBandLong + _ptSrLong + _ptVol + ctx + agreement + absorbed
f_mainConfShort() =>
    ctx = _ptCtxRsiS + _ptCtxEmaLongS + _ptCtxEmaShortS + _ptCtxCandleS + _ptCtxLiquidS + _ptCtxBlocksS + _ptCtxH5S + _ptCtxGateS
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptAdxAbs + _ptRelVolAbs + _ptHurstAbs
    factorCount = (_ptDirShort > 0 ? 1 : 0) + (_ptMean > 0.5 ? 1 : 0) + (_ptBandShort > 0 ? 1 : 0) + (_ptSrShort > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 5.0 - 0.5
    _ptDirShort + _ptMean + _ptBandShort + _ptSrShort + _ptVol + ctx + agreement + absorbed
f_bosBreakConfLong() =>
    ctx = _ptCtxCandleL + _ptCtxLiquidL + _ptCtxH5L + _ptCtxGateL
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptHurstAbs + _ptRelVolAbs
    factorCount = (_ptDir > 0 ? 1 : 0) + (_ptSrLong > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 3.0 - 0.5
    _ptDir + _ptSrLong + _ptVol + ctx + agreement + absorbed
f_bosBreakConfShort() =>
    ctx = _ptCtxCandleS + _ptCtxLiquidS + _ptCtxH5S + _ptCtxGateS
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptHurstAbs + _ptRelVolAbs
    factorCount = (_ptDirShort > 0 ? 1 : 0) + (_ptSrShort > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 3.0 - 0.5
    _ptDirShort + _ptSrShort + _ptVol + ctx + agreement + absorbed
f_bosRetestConfLong() =>
    ctx = _ptCtxEmaLongL + _ptCtxRsiL + _ptCtxBlocksL + _ptCtxLiquidL + _ptCtxGateL
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptAdxAbs + _ptHtfBiasL
    factorCount = (_ptDir > 0 ? 1 : 0) + (_ptSrLong > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 3.0 - 0.5
    _ptDir + _ptSrLong + _ptVol + ctx + agreement + absorbed
f_bosRetestConfShort() =>
    ctx = _ptCtxEmaLongS + _ptCtxRsiS + _ptCtxBlocksS + _ptCtxLiquidS + _ptCtxGateS
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptAdxAbs + _ptHtfBiasS
    factorCount = (_ptDirShort > 0 ? 1 : 0) + (_ptSrShort > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 3.0 - 0.5
    _ptDirShort + _ptSrShort + _ptVol + ctx + agreement + absorbed
f_obConfLong() =>
    ctx = _ptCtxCandleL + _ptCtxLiquidL + _ptCtxBlocksL + _ptCtxH5L + _ptCtxGateL
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptRelVolAbs
    factorCount = (_ptSrLong > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 2.0 - 0.5
    _ptSrLong + _ptVol + ctx + agreement + absorbed
f_obConfShort() =>
    ctx = _ptCtxCandleS + _ptCtxLiquidS + _ptCtxBlocksS + _ptCtxH5S + _ptCtxGateS
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptRelVolAbs
    factorCount = (_ptSrShort > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 2.0 - 0.5
    _ptSrShort + _ptVol + ctx + agreement + absorbed
f_reConfLong() =>
    ctx = _ptCtxEmaLongL + _ptCtxEmaShortL + _ptCtxCandleL + _ptCtxLiquidL + _ptCtxBlocksL + _ptCtxH5L + _ptCtxGateL
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptAdxAbs + _ptRelVolAbs + _ptHurstAbs
    factorCount = (_ptDir > 0 ? 1 : 0) + (_ptSrLong > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 3.0 - 0.5
    _ptDir + _ptSrLong + _ptVol + ctx + agreement + absorbed
f_reConfShort() =>
    ctx = _ptCtxEmaLongS + _ptCtxEmaShortS + _ptCtxCandleS + _ptCtxLiquidS + _ptCtxBlocksS + _ptCtxH5S + _ptCtxGateS
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptAdxAbs + _ptRelVolAbs + _ptHurstAbs
    factorCount = (_ptDirShort > 0 ? 1 : 0) + (_ptSrShort > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 3.0 - 0.5
    _ptDirShort + _ptSrShort + _ptVol + ctx + agreement + absorbed
f_trapConfLong() =>
    ctx = _ptCtxRsiL + _ptCtxCandleL + _ptCtxLiquidL + _ptCtxBlocksL + _ptCtxH5L + _ptCtxGateL
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptRelVolAbs + _ptHurstAbsMR
    factorCount = (_ptMean > 0.5 ? 1 : 0) + (_ptBandLong > 0 ? 1 : 0) + (_ptSrLong > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 4.0 - 0.5
    _ptMean + _ptBandLong + _ptSrLong + _ptVol + ctx + agreement + absorbed
f_trapConfShort() =>
    ctx = _ptCtxRsiS + _ptCtxCandleS + _ptCtxLiquidS + _ptCtxBlocksS + _ptCtxH5S + _ptCtxGateS
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptRelVolAbs + _ptHurstAbsMR
    factorCount = (_ptMean > 0.5 ? 1 : 0) + (_ptBandShort > 0 ? 1 : 0) + (_ptSrShort > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 4.0 - 0.5
    _ptMean + _ptBandShort + _ptSrShort + _ptVol + ctx + agreement + absorbed
f_odConfLong() =>
    ctx = _ptCtxEmaLongL + _ptCtxEmaShortL + _ptCtxCandleL + _ptCtxLiquidL + _ptCtxBlocksL + _ptCtxH5L + _ptCtxGateL
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptAdxAbs + _ptRelVolAbs + _ptHurstAbs
    factorCount = (_ptDir > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 2.0 - 0.5
    _ptDir + _ptVol + ctx + agreement + absorbed
f_odConfShort() =>
    ctx = _ptCtxEmaLongS + _ptCtxEmaShortS + _ptCtxCandleS + _ptCtxLiquidS + _ptCtxBlocksS + _ptCtxH5S + _ptCtxGateS
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptAdxAbs + _ptRelVolAbs + _ptHurstAbs
    factorCount = (_ptDirShort > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 2.0 - 0.5
    _ptDirShort + _ptVol + ctx + agreement + absorbed
f_sqzConfLong() =>
    ctx = _ptCtxEmaLongL + _ptCtxEmaShortL + _ptCtxCandleL + _ptCtxLiquidL + _ptCtxBlocksL + _ptCtxH5L + _ptCtxGateL + _ptSqzBandPosL
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptAdxAbs + _ptRelVolAbs + _ptHurstAbs
    factorCount = (_ptDir > 0 ? 1 : 0) + (_ptSqzMomMag >= 0.30 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 3.0 - 0.5
    _ptDir + _ptSqzMomMag + _ptVol + ctx + agreement + absorbed
f_sqzConfShort() =>
    ctx = _ptCtxEmaLongS + _ptCtxEmaShortS + _ptCtxCandleS + _ptCtxLiquidS + _ptCtxBlocksS + _ptCtxH5S + _ptCtxGateS + _ptSqzBandPosS
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptAdxAbs + _ptRelVolAbs + _ptHurstAbs
    factorCount = (_ptDirShort > 0 ? 1 : 0) + (_ptSqzMomMag >= 0.30 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 3.0 - 0.5
    _ptDirShort + _ptSqzMomMag + _ptVol + ctx + agreement + absorbed
f_fvgConfLong() =>
    ctx = _ptCtxCandleL + _ptCtxLiquidL + _ptCtxBlocksL + _ptCtxH5L + _ptCtxGateL
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptRelVolAbs
    factorCount = (_ptSrLong > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 2.0 - 0.5
    _ptSrLong + _ptVol + ctx + agreement + absorbed
f_fvgConfShort() =>
    ctx = _ptCtxCandleS + _ptCtxLiquidS + _ptCtxBlocksS + _ptCtxH5S + _ptCtxGateS
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptRelVolAbs
    factorCount = (_ptSrShort > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 2.0 - 0.5
    _ptSrShort + _ptVol + ctx + agreement + absorbed
f_ifvgConfLong() =>
    ctx = _ptCtxRsiL + _ptCtxBlocksL + _ptCtxLiquidL + _ptCtxEmaLongL + _ptCtxGateL
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptAdxAbs + _ptHtfBiasL
    factorCount = (_ptDir > 0 ? 1 : 0) + (_ptSrLong > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 3.0 - 0.5
    _ptDir + _ptSrLong + _ptVol + ctx + agreement + absorbed
f_ifvgConfShort() =>
    ctx = _ptCtxRsiS + _ptCtxBlocksS + _ptCtxLiquidS + _ptCtxEmaLongS + _ptCtxGateS
    absorbed = _ptRegimeAdj + _ptAerAdj + _ptAdxAbs + _ptHtfBiasS
    factorCount = (_ptDirShort > 0 ? 1 : 0) + (_ptSrShort > 0 ? 1 : 0) + (_ptVol > 0 ? 1 : 0)
    agreement = factorCount / 3.0 - 0.5
    _ptDirShort + _ptSrShort + _ptVol + ctx + agreement + absorbed
f_mainConf()      => [f_mainConfLong(),      f_mainConfShort()]
f_bosBreakConf()  => [f_bosBreakConfLong(),  f_bosBreakConfShort()]
f_bosRetestConf() => [f_bosRetestConfLong(), f_bosRetestConfShort()]
f_obConf()        => [f_obConfLong(),        f_obConfShort()]
f_reConf()        => [f_reConfLong(),        f_reConfShort()]
f_trapConf()      => [f_trapConfLong(),      f_trapConfShort()]
f_odConf()        => [f_odConfLong(),        f_odConfShort()]
f_sqzConf()       => [f_sqzConfLong(),       f_sqzConfShort()]
f_fvgConf()       => [f_fvgConfLong(),       f_fvgConfShort()]
f_ifvgConf()      => [f_ifvgConfLong(),      f_ifvgConfShort()]
[confMainL,      confMainS]      = f_mainConf()
[confBosBreakL,  confBosBreakS]  = f_bosBreakConf()
[confBosRetestL, confBosRetestS] = f_bosRetestConf()
[confObL,        confObS]        = f_obConf()
[confReL,        confReS]        = f_reConf()
[confTrapL,      confTrapS]      = f_trapConf()
[confOdL,        confOdS]        = f_odConf()
[confSqzL,       confSqzS]       = f_sqzConf()
[confFvgL,       confFvgS]       = f_fvgConf()
[confIfvgL,      confIfvgS]      = f_ifvgConf()
var bool inLong = false
var bool inShort = false
bool bosBuyFired = false
bool bosSellFired = false
bool reBuyFired = false
bool reSellFired = false
bool trapBuyFired = false
bool trapSellFired = false
bool sqzBuyFired = false
bool sqzSellFired = false
bool fvgBuyFired = false
bool fvgSellFired = false
bool ifvgBuyFired = false
bool ifvgSellFired = false
bool obBuyFired = false
bool obSellFired = false
bool odRTHOpen   = time(timeframe.period, "0830-0836", "America/Chicago") != 0
bool odEconData  = time(timeframe.period, "0728-0733", "America/Chicago") != 0
bool odSecondWave= time(timeframe.period, "0900-0906", "America/Chicago") != 0
bool odWindow    = useOD and (odRTHOpen or odEconData or odSecondWave)
var float odImpulseOpen = na
var float odImpulseHi   = na
var float odImpulseLo   = na
var int   odImpulseBar  = 0
var bool  odImpulseLocked = false
if odWindow and not odWindow[1]
    odImpulseOpen := open
    odImpulseHi   := high
    odImpulseLo   := low
    odImpulseBar  := bar_index
    odImpulseLocked := false
if odWindow and not odImpulseLocked and not na(odImpulseOpen)
    odImpulseHi := math.max(nz(odImpulseHi, high), high)
    odImpulseLo := math.min(nz(odImpulseLo, low), low)
    if bar_index - odImpulseBar >= 2
        odImpulseLocked := true
f_odVolThresh() =>
    base = odRTHOpen ? 2.5 : odEconData ? 3.0 : odSecondWave ? 2.0 : 2.5
    regAdj = aerTrending ? -0.3 : aerChoppy ? 0.4 : 0.0
    adxAdj = adx >= 35 ? -0.3 : adx >= 25 ? -0.15 : adx < 15 ? 0.3 : 0.0
    hurstAdj = hurstPersist ? -0.2 : hurstRevert ? 0.2 : 0.0
    math.max(1.5, math.min(4.0, base + regAdj + adxAdj + hurstAdj))
_odVolThresh = f_odVolThresh()
bool odVolSpike = volume > avgVol * _odVolThresh
f_odBodyRatioMin() =>
    base = 0.50
    regAdj = aerTrending ? -0.05 : aerChoppy ? 0.08 : 0.0
    adxAdj = adx >= 35 ? -0.05 : adx < 15 ? 0.05 : 0.0
    volAdj = relVol >= 3.0 ? -0.05 : 0.0
    sessAdj = isOpen ? -0.03 : isMorning ? 0.0 : isLunch ? 0.05 : isAfternoon ? 0.02 : 0.0
    volatAdj = atr > aerMeanATR * 1.5 ? -0.03 : atr < aerMeanATR * 0.8 ? 0.04 : 0.0
    math.max(0.35, math.min(0.65, base + regAdj + adxAdj + volAdj + sessAdj + volatAdj))
_odBodyRatioMin = f_odBodyRatioMin()
float odBodyRatio = csRange > 0 ? csBody / csRange : 0.0
bool odStrongBull = close > open and odBodyRatio > _odBodyRatioMin and not csDoji
bool odStrongBear = close < open and odBodyRatio > _odBodyRatioMin and not csDoji
f_mainMinConf() => 2.87  // 65% of empirical max (theor 6.31 × 0.70 correlation discount = 4.42; 5-factor composite peaks ~70% of sum-of-ceilings per Fama-French/Barra factor-model literature)
f_bosMinConf()  => 1.49  // 45% of empirical max (theor 4.26 × 0.78 correlation discount = 3.32; aggressive diagnostic floor to rule out floor as blocker)
f_obMinConf()   => 1.90  // 65% of max 2.92 (level event per acy.com, liquidityfinder)
f_reMinConf()   => 1.49  // 45% of empirical max (theor 4.26 × 0.78 correlation discount = 3.32; aggressive diagnostic floor to rule out floor as blocker)
f_trapMinConf() => 3.58  // 70% of max 5.11 (reversal: high confluence)
f_odMinConf()   => 1.79  // 55% of max 3.255 (session momentum continuation)
float _mainMinConf = f_mainMinConf()
float _bosMinConf  = f_bosMinConf()
float _obMinConf   = f_obMinConf()
float _reMinConf   = f_reMinConf()
float _trapMinConf = f_trapMinConf()
float _odMinConf   = f_odMinConf()
float _mainMinConfL = stratC_Long  ? _mainMinConf + _oteSweetBonus : _mainMinConf
float _mainMinConfS = stratC_Short ? _mainMinConf + _oteSweetBonus : _mainMinConf
float _sqzMinConf = 2.34  // 55% of merged-trade max ~4.25 (squeeze + post-squeeze momentum unified)
float _fvgMinConf = 1.85  // HARD FLOOR. 63.4% of empirical max 2.92 (between research-target 65% and moderate 55%). LTF + HTF gates provide additional quality filtering.
float _ifvgMinConf = 1.60  // 45% of empirical max (theor 4.55 × 0.78 correlation discount = 3.55; 3-factor reversal class diagnostic floor)
float _maxMain  = 6.31   // 5 core (dir+mean+band+sr+vol = 4.5) + 8-ctx w/ RSI (0.305) + abs (1.00) + agree (0.5)
float _maxBos   = 4.26   // 3 core (dir+sr+vol = 2.5) + 7-ctx no RSI (0.255) + abs (1.00) + agree (0.5)
float _maxRe    = 4.26   // same structure as BOS — 3 core (dir+sr+vol) + 7-ctx no RSI + abs + agree
float _maxTrap  = 5.11   // 4 core (mean+band+sr+vol = 3.5) + 6-ctx w/ RSI no EMAs (0.23) + abs MR (0.88, no AdxAbs) + agree (0.5)
float _maxSqz   = 4.25   // merged trade, sqzMomMag replaces band
float _maxOd    = 3.26   // unchanged
float _maxOb    = 2.92   // _ptHtfBias removed May 2026 — replaced by HTF gate at fire site (3.02 - 0.10 = 2.92)
float _maxFvg   = 2.92   // baseline; was 3.02 with _ptHtfBias (now removed in favor of hard HTF gate)
float _maxIfvg  = 4.55   // 3-factor: Dir + SR + Vol + ctx (5) + agreement + absorbed (4 incl. HtfBias + Adx)
f_failTpPick(bool isLong) =>
    float midpoint = not na(trndRefHigh) and not na(trndRefLow) ? (trndRefHigh + trndRefLow) / 2 : na
    float result = na
    if isLong
        if not na(_nearestResAbove)
            result := _nearestResAbove
        if not na(midpoint) and midpoint > close
            result := na(result) ? midpoint : math.min(result, midpoint)
    else
        if not na(_nearestSupBelow)
            result := _nearestSupBelow
        if not na(midpoint) and midpoint < close
            result := na(result) ? midpoint : math.max(result, midpoint)
    result
float _failTpLong  = f_failTpPick(true)
float _failTpShort = f_failTpPick(false)
float _trndTpRawLPot = stratB_Long ? _failTpLong : oteLongHi
float trndTpLPot = not na(_trndTpRawLPot) and _trndTpRawLPot > close ? _trndTpRawLPot - f_dynTpBuffer(_trndTpRawLPot) : na
float trndSlLPot = stratB_Long ? low - f_dynSlBuffer(low) : (not na(sl0) ? sl0 - f_dynSlBuffer(sl0) : na)
float _trndTpRawSPot = stratB_Short ? _failTpShort : oteShortLo
float trndTpSPot = not na(_trndTpRawSPot) and _trndTpRawSPot < close ? _trndTpRawSPot + f_dynTpBuffer(_trndTpRawSPot) : na
float trndSlSPot = stratB_Short ? high + f_dynSlBuffer(high) : (not na(sh0) ? sh0 + f_dynSlBuffer(sh0) : na)
float bosBullStructSl = not na(bosBullLevel) ? bosBullLevel - f_dynSlBuffer(bosBullLevel) : na
float bosBearStructSl = not na(bosBearLevel) ? bosBearLevel + f_dynSlBuffer(bosBearLevel) : na
float reBullStructSl = not na(sl0) ? sl0 - f_dynSlBufferWithSetup(sl0, csLowerWk) : na
float reBearStructSl = not na(sh0) ? sh0 + f_dynSlBufferWithSetup(sh0, csUpperWk) : na
float trapBullSl = not na(sl0) ? sl0 - f_dynSlBufferWithSetup(sl0, csLowerWk) : na
float trapBearSl = not na(sh0) ? sh0 + f_dynSlBufferWithSetup(sh0, csUpperWk) : na
f_fvgPots() =>
    float tpL = not na(_nearestResAbove) ? _nearestResAbove - f_dynTpBuffer(_nearestResAbove) : na
    float tpS = not na(_nearestSupBelow) ? _nearestSupBelow + f_dynTpBuffer(_nearestSupBelow) : na
    float slL = not na(fvgBullLo) ? fvgBullLo - f_dynSlBuffer(fvgBullLo) : na
    float slS = not na(fvgBearHi) ? fvgBearHi + f_dynSlBuffer(fvgBearHi) : na
    [tpL, tpS, slL, slS]
f_ifvgPots() =>
    float tpL = not na(_nearestResAbove) ? _nearestResAbove - f_dynTpBuffer(_nearestResAbove) : na
    float tpS = not na(_nearestSupBelow) ? _nearestSupBelow + f_dynTpBuffer(_nearestSupBelow) : na
    float slL = not na(fvgBearLo) ? fvgBearLo - f_dynSlBuffer(fvgBearLo) : na
    float slS = not na(fvgBullHi) ? fvgBullHi + f_dynSlBuffer(fvgBullHi) : na
    [tpL, tpS, slL, slS]
[fvgTpLPot,  fvgTpSPot,  fvgSlLPot,  fvgSlSPot]  = f_fvgPots()
[ifvgTpLPot, ifvgTpSPot, ifvgSlLPot, ifvgSlSPot] = f_ifvgPots()
if sigL and confMainL >= _mainMinConfL and (not stratB_Long or htfConfScore > -5.0)
    string trndSubL = stratB_Long ? "FAIL" : "OTE"
    [tpCandL, slCandL] = f_calcTpSlLongStruct(trndTpLPot, trndSlLPot)
    if not na(slCandL) and not na(tpCandL) and (tpCandL - close) >= minProfit
        entryBar := bar_index
        inLong := true
        inShort := false
        f_openTicket(true, slCandL, tpCandL, "BUY", "TRND·" + trndSubL, confMainL)
else if sigL and _bullCndl
    f_signalMarker(true, "TRND")
if sigS and confMainS >= _mainMinConfS and (not stratB_Short or htfConfScore < 5.0)
    string trndSubS = stratB_Short ? "FAIL" : "OTE"
    [tpCandS, slCandS] = f_calcTpSlShortStruct(trndTpSPot, trndSlSPot)
    if not na(slCandS) and not na(tpCandS) and (close - tpCandS) >= minProfit
        entryBar := bar_index
        inShort := true
        inLong := false
        f_openTicket(false, slCandS, tpCandS, "SELL", "TRND·" + trndSubS, confMainS)
else if sigS and _bearCndl
    f_signalMarker(false, "TRND")
if ((bullBOS or _orbBullBreakNow) and confBosBreakL >= _bosMinConf) or (bosBullRetestConfirm and confBosRetestL >= _bosMinConf)
    bool _isBosBreakL = bullBOS or _orbBullBreakNow
    string _bosLabelL = _isBosBreakL ? "BOS BRK" : "BOS RT"
    float _confBosL = _isBosBreakL ? confBosBreakL : confBosRetestL
    [tpCandBoL, slCandBoL] = f_calcTpSlLongStruct(bosTpLongAdj, bosBullStructSl)
    if not na(slCandBoL) and (tpCandBoL - close) >= minProfit
        entryBar := bar_index
        inLong := true
        inShort := false
        f_openTicket(true, slCandBoL, tpCandBoL, "BUY", _bosLabelL, _confBosL)
        bosBuyFired := true
        bosBullLevel := na
else if (bullBOS or _orbBullBreakNow or bosBullRetestConfirm) and _bullCndl
    f_signalMarker(true, "BOS")
if ((bearBOS or _orbBearBreakNow) and confBosBreakS >= _bosMinConf) or (bosBearRetestConfirm and confBosRetestS >= _bosMinConf)
    bool _isBosBreakS = bearBOS or _orbBearBreakNow
    string _bosLabelS = _isBosBreakS ? "BOS BRK" : "BOS RT"
    float _confBosS = _isBosBreakS ? confBosBreakS : confBosRetestS
    [tpCandBoS, slCandBoS] = f_calcTpSlShortStruct(bosTpShortAdj, bosBearStructSl)
    if not na(slCandBoS) and (close - tpCandBoS) >= minProfit
        entryBar := bar_index
        inShort := true
        inLong := false
        f_openTicket(false, slCandBoS, tpCandBoS, "SELL", _bosLabelS, _confBosS)
        bosSellFired := true
        bosBearLevel := na
else if (bearBOS or _orbBearBreakNow or bosBearRetestConfirm) and _bearCndl
    f_signalMarker(false, "BOS")
if obBullTradeFire and confObL >= _obMinConf and htfConfScore > -5.0
    [tpCandObL, slCandObL] = f_calcTpSlLongStruct(obTpLongAdj, obBullSl)
    if not na(slCandObL) and (tpCandObL - close) >= minProfit
        entryBar := bar_index
        inLong := true
        inShort := false
        f_openTicket(true, slCandObL, tpCandObL, "BUY", "OB", confObL)
        obBuyFired := true
else if obBullTradeFire and _bullCndl
    f_signalMarker(true, "OB")
if obBearTradeFire and confObS >= _obMinConf and htfConfScore < 5.0
    [tpCandObS, slCandObS] = f_calcTpSlShortStruct(obTpShortAdj, obBearSl)
    if not na(slCandObS) and (close - tpCandObS) >= minProfit
        entryBar := bar_index
        inShort := true
        inLong := false
        f_openTicket(false, slCandObS, tpCandObS, "SELL", "OB", confObS)
        obSellFired := true
else if obBearTradeFire and _bearCndl
    f_signalMarker(false, "OB")
float reTpLong     = _nearRes
float reTpShort    = _nearSup
float reTpLongAdj  = not na(reTpLong)  ? reTpLong  - f_dynTpBuffer(reTpLong)  : na
float reTpShortAdj = not na(reTpShort) ? reTpShort + f_dynTpBuffer(reTpShort) : na
if bullRetestOk and confReL >= _reMinConf
    [reTpL, reSlL] = f_calcTpSlLongStruct(reTpLongAdj, reBullStructSl)
    if not na(reSlL) and (reTpL - close) >= minProfit
        entryBar := bar_index
        inLong := true
        inShort := false
        f_openTicket(true, reSlL, reTpL, "BUY", "RE", confReL)
        reBuyFired := true
else if bullRetestOk and _bullCndl
    f_signalMarker(true, "RE")
if bearRetestOk and confReS >= _reMinConf
    [reTpS, reSlS] = f_calcTpSlShortStruct(reTpShortAdj, reBearStructSl)
    if not na(reSlS) and (close - reTpS) >= minProfit
        entryBar := bar_index
        inShort := true
        inLong := false
        f_openTicket(false, reSlS, reTpS, "SELL", "RE", confReS)
        reSellFired := true
else if bearRetestOk and _bearCndl
    f_signalMarker(false, "RE")
float trapTpLong = na
if not na(vwapCalc) and vwapCalc > close
    trapTpLong := vwapCalc - f_dynTpBuffer(vwapCalc)
else if not na(_nearRes)
    trapTpLong := _nearRes - f_dynTpBuffer(_nearRes)
float trapTpShort = na
if not na(vwapCalc) and vwapCalc < close
    trapTpShort := vwapCalc + f_dynTpBuffer(vwapCalc)
else
    float _trapRevSup = f_revSupBelow()
    if not na(_trapRevSup)
        trapTpShort := _trapRevSup + f_dynTpBuffer(_trapRevSup)
if bearSweep and (fpDeltaBull or fpBuyRatio >= _trapFpRatio or swpAtHTFLvlBearTrap or _bearSweepClustered) and confTrapL >= _trapMinConf and htfConfScore > -5.0
    [trapTpL, trapSlL] = f_calcTpSlLongStruct(trapTpLong, trapBullSl)
    if not na(trapSlL) and not na(trapTpL) and (trapTpL - close) >= minProfit
        entryBar := bar_index
        inLong := true
        inShort := false
        f_openTicket(true, trapSlL, trapTpL, "BUY", "TRAP", confTrapL)
        trapBuyFired := true
else if bearSweep and _bullCndl
    f_signalMarker(true, "TRAP")
if bullSweep and (fpDeltaBear or fpSellRatio >= _trapFpRatio or swpAtHTFLvlBullTrap or _bullSweepClustered) and confTrapS >= _trapMinConf and htfConfScore < 5.0
    [trapTpS, trapSlS] = f_calcTpSlShortStruct(trapTpShort, trapBearSl)
    if not na(trapSlS) and not na(trapTpS) and (close - trapTpS) >= minProfit
        entryBar := bar_index
        inShort := true
        inLong := false
        f_openTicket(false, trapSlS, trapTpS, "SELL", "TRAP", confTrapS)
        trapSellFired := true
else if bullSweep and _bearCndl
    f_signalMarker(false, "TRAP")
bool odBuyFired = false
bool odSellFired = false
float odBuyConfBoost  = odWindow and odVolSpike and odStrongBull ? 0.7 : odWindow and odVolSpike and odStrongBear ? -0.5 : odWindow and odVolSpike ? -0.3 : 0.0
float odSellConfBoost = odWindow and odVolSpike and odStrongBear ? 0.7 : odWindow and odVolSpike and odStrongBull ? -0.5 : odWindow and odVolSpike ? -0.3 : 0.0
bool odBuyRaw  = odWindow and confOdL   >= (_odMinConf - odBuyConfBoost)
bool odSellRaw = odWindow and confOdS   >= (_odMinConf - odSellConfBoost)
float odTpLong     = _nearRes
float odTpShort    = f_revSupBelow()
float odTpLongAdj  = not na(odTpLong)  ? odTpLong  - f_dynTpBuffer(odTpLong)  : na
float odTpShortAdj = not na(odTpShort) ? odTpShort + f_dynTpBuffer(odTpShort) : na
float odBullStructSl = odBuyRaw  ? low  - f_dynSlBuffer(low)  : na
float odBearStructSl = odSellRaw ? high + f_dynSlBuffer(high) : na
if odBuyRaw and htfConfScore > -5.0
    [odTpL, odSlL] = f_calcTpSlLongStruct(odTpLongAdj, odBullStructSl)
    if not na(odSlL) and not na(odTpL) and (odTpL - close) >= minProfit
        entryBar := bar_index
        inLong := true
        inShort := false
        f_openTicket(true, odSlL, odTpL, "BUY", "OD", confOdL)
        odBuyFired := true
else if odBuyRaw and _bullCndl
    f_signalMarker(true, "OD")
if odSellRaw and htfConfScore < 5.0
    [odTpS, odSlS] = f_calcTpSlShortStruct(odTpShortAdj, odBearStructSl)
    if not na(odSlS) and not na(odTpS) and (close - odTpS) >= minProfit
        entryBar := bar_index
        inShort := true
        inLong := false
        f_openTicket(false, odSlS, odTpS, "SELL", "OD", confOdS)
        odSellFired := true
else if odSellRaw and _bearCndl
    f_signalMarker(false, "OD")
sqzVolAdj   = math.max(-0.20, math.min(0.16, (relVol - 1.0) * 0.20))
sqzAerDev   = aerER - aerDynThresh
sqzAerAdj   = math.max(-0.16, math.min(0.16, sqzAerDev * +0.24))
sqzAdxAdj   = math.max(-0.16, math.min(0.08, (adx - 22.5) * 0.016))
sqzHurstAdj = math.max(-0.12, math.min(0.12, (hurst - 0.5) * +0.16))
bool sqzPostWindow = sqzFired[1] or sqzFired[2] or sqzFired[3] or sqzFired[4]
bool sqzBullFire = sqzPostWindow and sqzMom > 0 and _ptSqzMomMag >= 0.30
bool sqzBearFire = sqzPostWindow and sqzMom < 0 and _ptSqzMomMag >= 0.45
float sqzTpLong     = _nearRes
float sqzTpShort    = f_revSupBelow()
float sqzTpLongAdj  = not na(sqzTpLong)  ? sqzTpLong  - f_dynTpBuffer(sqzTpLong)  : na
float sqzTpShortAdj = not na(sqzTpShort) ? sqzTpShort + f_dynTpBuffer(sqzTpShort) : na
float sqzBullStructSl = sqzBullFire and not na(sqzLL) ? sqzLL - f_dynSlBuffer(sqzLL) : na
float sqzBearStructSl = sqzBearFire and not na(sqzHL) ? sqzHL + f_dynSlBuffer(sqzHL) : na
if sqzBullFire and confSqzL >= _sqzMinConf and htfConfScore > -5.0
    [sqTpL, sqSlL] = f_calcTpSlLongStruct(sqzTpLongAdj, sqzBullStructSl)
    if not na(sqSlL) and not na(sqTpL) and (sqTpL - close) >= minProfit
        entryBar := bar_index
        inLong := true
        inShort := false
        f_openTicket(true, sqSlL, sqTpL, "BUY", "SQZ", confSqzL)
        sqzBuyFired := true
else if sqzBullFire and _bullCndl
    f_signalMarker(true, "SQZ")
if sqzBearFire and confSqzS >= _sqzMinConf and htfConfScore < 5.0
    [sqTpS, sqSlS] = f_calcTpSlShortStruct(sqzTpShortAdj, sqzBearStructSl)
    if not na(sqSlS) and not na(sqTpS) and (close - sqTpS) >= minProfit
        entryBar := bar_index
        inShort := true
        inLong := false
        f_openTicket(false, sqSlS, sqTpS, "SELL", "SQZ", confSqzS)
        sqzSellFired := true
else if sqzBearFire and _bearCndl
    f_signalMarker(false, "SQZ")
bool fvgBullValid = not na(fvgBullHi) and not na(fvgBullLo) and fvgBullAge <= 50 and fvgBullFill <= 0.85 and fvgBullTouch <= 5
bool fvgBearValid = not na(fvgBearHi) and not na(fvgBearLo) and fvgBearAge <= 50 and fvgBearFill <= 0.85 and fvgBearTouch <= 5
float fvgBullMid = na(fvgBullHi) or na(fvgBullLo) ? na : (fvgBullHi + fvgBullLo) / 2.0
float fvgBearMid = na(fvgBearHi) or na(fvgBearLo) ? na : (fvgBearHi + fvgBearLo) / 2.0
bool fvgBullRejection = not na(fvgBullHi) and low <= fvgBullHi and close > fvgBullHi
bool fvgBearRejection = not na(fvgBearLo) and high >= fvgBearLo and close < fvgBearLo
bool fvgBullFire = fvgBullValid and low >= fvgBullLo and fvgBullRejection
bool fvgBearFire = fvgBearValid and high <= fvgBearHi and fvgBearRejection
fvgVolAdj   = math.max(-0.20, math.min(0.16, (relVol - 1.0) * 0.20))
fvgAerDev   = aerER - aerDynThresh
fvgAerAdj   = math.max(-0.16, math.min(0.16, fvgAerDev * +0.24))
fvgAdxAdj   = math.max(-0.16, math.min(0.08, (adx - 22.5) * 0.016))
fvgHurstAdj = math.max(-0.12, math.min(0.12, (hurst - 0.5) * +0.20))
if fvgBullFire and confFvgL >= _fvgMinConf and htfConfScore > -5.0 and close > close[1]
    [fvTpL, fvSlL] = f_calcTpSlLongStruct(fvgTpLPot, fvgSlLPot)
    if not na(fvSlL) and not na(fvTpL) and (fvTpL - close) >= minProfit
        entryBar := bar_index
        inLong := true
        inShort := false
        f_openTicket(true, fvSlL, fvTpL, "BUY", "FVG", confFvgL)
        fvgBuyFired := true
else if fvgBullFire and _bullCndl
    f_signalMarker(true, "FVG")
if fvgBearFire and confFvgS >= _fvgMinConf and htfConfScore < 5.0 and close < close[1]
    [fvTpS, fvSlS] = f_calcTpSlShortStruct(fvgTpSPot, fvgSlSPot)
    if not na(fvSlS) and not na(fvTpS) and (close - fvTpS) >= minProfit
        entryBar := bar_index
        inShort := true
        inLong := false
        f_openTicket(false, fvSlS, fvTpS, "SELL", "FVG", confFvgS)
        fvgSellFired := true
else if fvgBearFire and _bearCndl
    f_signalMarker(false, "FVG")
bool ifvgBearFire = not na(fvgBullMid) and fvgBullViolated and high >= fvgBullMid and close < fvgBullMid and csBearBar
bool ifvgBullFire = not na(fvgBearMid) and fvgBearViolated and low <= fvgBearMid and close > fvgBearMid and csBullBar
if ifvgBullFire and confIfvgL >= _ifvgMinConf
    [ifTpL, ifSlL] = f_calcTpSlLongStruct(ifvgTpLPot, ifvgSlLPot)
    if not na(ifSlL) and not na(ifTpL) and (ifTpL - close) >= minProfit
        entryBar := bar_index
        inLong := true
        inShort := false
        f_openTicket(true, ifSlL, ifTpL, "BUY", "IFVG", confIfvgL)
        ifvgBuyFired := true
        fvgBearViolated := false
else if ifvgBullFire and _bullCndl
    f_signalMarker(true, "IFVG")
if ifvgBearFire and confIfvgS >= _ifvgMinConf
    [ifTpS, ifSlS] = f_calcTpSlShortStruct(ifvgTpSPot, ifvgSlSPot)
    if not na(ifSlS) and not na(ifTpS) and (close - ifTpS) >= minProfit
        entryBar := bar_index
        inShort := true
        inLong := false
        f_openTicket(false, ifSlS, ifTpS, "SELL", "IFVG", confIfvgS)
        ifvgSellFired := true
        fvgBullViolated := false
else if ifvgBearFire and _bearCndl
    f_signalMarker(false, "IFVG")
bool tpLongHit = false
bool tpShortHit = false
bool slLongHit = false
bool slShortHit = false
if array.size(activeTix) > 0
    _sz = array.size(activeTix)
    for i = 0 to _sz - 1
        t = array.get(activeTix, i)
        if not t.closed
            float adverseDist = t.isLong ? (t.fireClose - low) : (high - t.fireClose)
            if adverseDist > t.mae
                t.mae := adverseDist
            if not na(t.slLn)
                line.set_x2(t.slLn, bar_index + 15)
            if not na(t.tpLn)
                line.set_x2(t.tpLn, bar_index + 15)
            pastE = bar_index > t.eBar
            hitSl = t.isLong ? (low <= t.sl and pastE) : (high >= t.sl and pastE)
            hitTp = t.isLong ? (high >= t.tp) : (low <= t.tp)
            if hitSl or hitTp
                if not na(t.slLn)
                    line.delete(t.slLn)
                    t.slLn := na
                if not na(t.tpLn)
                    line.delete(t.tpLn)
                    t.tpLn := na
                t.closed := true
                array.set(activeTix, i, t)
                outcomeStr = hitTp ? "TP" : "SL"
                alert(outcomeStr + " HIT @ " + str.tostring(close, "#.##"), alert.freq_once_per_bar)
                if showOutcomeOnLabel and not na(t.lbl)
                    float pts = t.isLong ? (hitTp ? t.tp - t.fireClose : t.sl - t.fireClose) : (hitTp ? t.fireClose - t.tp : t.fireClose - t.sl)
                    float slDist = math.abs(t.fireClose - t.sl)
                    int maePct = slDist > 0 ? int(math.round(t.mae / slDist * 100)) : 0
                    int barsB = bar_index - t.eBar
                    string lblOutcomeStr = "\n" + (hitTp ? "TP +" : "SL ") + str.tostring(pts, "#") + "pt/" + str.tostring(barsB) + "b MAE " + str.tostring(maePct) + "%"
                    label.set_text(t.lbl, label.get_text(t.lbl) + lblOutcomeStr)
                if hitTp and t.isLong
                    tpLongHit := true
                if hitTp and not t.isLong
                    tpShortHit := true
                if hitSl and t.isLong
                    slLongHit := true
                if hitSl and not t.isLong
                    slShortHit := true
                if t.eBar == entryBar
                    inLong := false
                    inShort := false
                    entryBar := na
while array.size(activeTix) > 0 and array.get(activeTix, 0).closed
    array.shift(activeTix)
hvbHi = ta.highest(high, hvbLookback)
hvbLo = ta.lowest(low, hvbLookback)
nearSup := na
nearRes := na
float[] srLevels = array.new_float(0)
if not na(pivotS1) and pivotS1 < close
    array.push(srLevels, pivotS1)
if not na(pivotS2) and pivotS2 < close
    array.push(srLevels, pivotS2)
if not na(pivotPP) and pivotPP < close
    array.push(srLevels, pivotPP)
if not na(orbLow) and orbLocked and orbLow < close
    array.push(srLevels, orbLow)
if not na(pmLow) and pmLow < close
    array.push(srLevels, pmLow)
if not na(pmMid) and pmMid < close
    array.push(srLevels, pmMid)
if not na(vwapDn1) and vwapDn1 < close
    array.push(srLevels, vwapDn1)
if showORBMid and not na(orbMid) and orbLocked and orbMid < close
    array.push(srLevels, orbMid)
if showONRange and not na(onLow) and onLow < close
    array.push(srLevels, onLow)
if showQQQLevels and not na(qqqLvlDn1) and qqqLvlDn1 < close
    array.push(srLevels, qqqLvlDn1)
if not na(hvbZone1) and hvbZone1 < close
    array.push(srLevels, hvbZone1)
if not na(hvbZone2) and hvbZone2 < close
    array.push(srLevels, hvbZone2)
if not na(hvbZone3) and hvbZone3 < close
    array.push(srLevels, hvbZone3)
if not na(povLevel) and povLevel < close
    array.push(srLevels, povLevel)
if not na(valLevel) and valLevel < close
    array.push(srLevels, valLevel)
if not na(vahLevel) and vahLevel < close
    array.push(srLevels, vahLevel)
if not na(fvgBullHi) and fvgBullHi < close
    array.push(srLevels, fvgBullHi)
if not na(obBullMid) and obBullMid < close
    array.push(srLevels, obBullMid)
if not na(obBearMid) and obBearMid < close
    array.push(srLevels, obBearMid)
if not na(rthLow) and rthLow < close and (inETH or isOpen)
    array.push(srLevels, rthLow)
if not na(fpVAL) and fpVAL < close
    array.push(srLevels, fpVAL)
if ema200 < close
    array.push(srLevels, ema200)
float[] resLevels = array.new_float(0)
if not na(pivotR1) and pivotR1 > close
    array.push(resLevels, pivotR1)
if not na(pivotR2) and pivotR2 > close
    array.push(resLevels, pivotR2)
if not na(pivotPP) and pivotPP > close
    array.push(resLevels, pivotPP)
if not na(orbHigh) and orbLocked and orbHigh > close
    array.push(resLevels, orbHigh)
if not na(pmHigh) and pmHigh > close
    array.push(resLevels, pmHigh)
if not na(pmMid) and pmMid > close
    array.push(resLevels, pmMid)
if not na(vwapUp1) and vwapUp1 > close
    array.push(resLevels, vwapUp1)
if showORBMid and not na(orbMid) and orbLocked and orbMid > close
    array.push(resLevels, orbMid)
if showONRange and not na(onHigh) and onHigh > close
    array.push(resLevels, onHigh)
if showQQQLevels and not na(qqqLvlUp1) and qqqLvlUp1 > close
    array.push(resLevels, qqqLvlUp1)
if not na(hvbZone1) and hvbZone1 > close
    array.push(resLevels, hvbZone1)
if not na(hvbZone2) and hvbZone2 > close
    array.push(resLevels, hvbZone2)
if not na(hvbZone3) and hvbZone3 > close
    array.push(resLevels, hvbZone3)
if not na(povLevel) and povLevel > close
    array.push(resLevels, povLevel)
if not na(vahLevel) and vahLevel > close
    array.push(resLevels, vahLevel)
if not na(valLevel) and valLevel > close
    array.push(resLevels, valLevel)
if not na(fvgBearHi) and fvgBearHi > close
    array.push(resLevels, fvgBearHi)
if not na(obBullMid) and obBullMid > close
    array.push(resLevels, obBullMid)
if not na(obBearMid) and obBearMid > close
    array.push(resLevels, obBearMid)
if not na(rthHigh) and rthHigh > close and (inETH or isOpen)
    array.push(resLevels, rthHigh)
if not na(fpVAH) and fpVAH > close
    array.push(resLevels, fpVAH)
if ema200 > close
    array.push(resLevels, ema200)
if array.size(vrzHighs) > 0
    for i = 0 to array.size(vrzHighs) - 1
        float vH = array.get(vrzHighs, i)
        float vL = array.get(vrzLows, i)
        if vL < close
            array.push(srLevels, vL)
        if vH > close
            array.push(resLevels, vH)
        if vH < close
            array.push(srLevels, vH)
        if vL > close
            array.push(resLevels, vL)
if array.size(srLevels) > 0
    for i = 0 to array.size(srLevels) - 1
        float lvl = array.get(srLevels, i)
        if na(nearSup) or lvl > nearSup
            nearSup := lvl
if array.size(resLevels) > 0
    for i = 0 to array.size(resLevels) - 1
        float lvl = array.get(resLevels, i)
        if na(nearRes) or lvl < nearRes
            nearRes := lvl
float distToSup = not na(nearSup) ? (close - nearSup) / close * 100 : 99.0
float distToRes = not na(nearRes) ? (nearRes - close) / close * 100 : 99.0
_srNearThresh = f_dyn(0.1, 0.05, -0.02, -0.03, 0.02, -0.02, 0.02, -0.02, 0.04, 0.2)
f_srFarThresh() =>
    base = 0.3
    sessAdj = isOpen ? 0.1 : isMorning ? -0.03 : isLunch ? -0.05 : isAfternoon ? -0.025 : isLast ? 0.03 : inPreMkt ? -0.05 : inLondon ? -0.04 : inAsia ? -0.05 : 0.0
    regAdj = aerTrending ? 0.05 : aerChoppy ? -0.03 : 0.0
    math.max(0.15, math.min(0.5, base + sessAdj + regAdj))
_srFarThresh = f_srFarThresh()
float srNear = _srNearThresh
float srFar = _srFarThresh
float srBias = 0.0
if distToSup < srNear and distToRes > srFar
    srBias := 1.0
else if distToRes < srNear and distToSup > srFar
    srBias := -1.0
else if distToSup < distToRes * 0.5
    srBias := 0.5
else if distToRes < distToSup * 0.5
    srBias := -0.5
float dirScore = dirScoreFull + srBias
float dirNorm = math.max(-1.0, math.min(1.0, dirScore / 14.0))
color dirPulseCol = dirNorm >= 0.6 ? color.new(#00E676, 10) : dirNorm >= 0.3 ? color.new(#00BFA5, 20) : dirNorm >= 0.0 ? color.new(#78909C, 40) : dirNorm >= -0.3 ? color.new(#78909C, 40) : dirNorm >= -0.6 ? color.new(#FF6D00, 20) : color.new(#FF1744, 10)
plot(showDirPulse ? ema21 : na, title="Direction Pulse", color=dirPulseCol, linewidth=3, style=plot.style_linebr)
color dirBarCol = dirNorm >= 0.6 ? color.new(#00E676, 20) : dirNorm >= 0.3 ? color.new(#00BFA5, 30) : dirNorm >= 0.0 ? na : dirNorm >= -0.3 ? na : dirNorm >= -0.6 ? color.new(#FF6D00, 30) : color.new(#FF1744, 20)
barcolor(useDirBarColor ? dirBarCol : na, title="Dir Score Candles")
float slopeSign = 0.0
if dirScore >= 4
    slopeSign := 1.0
else if dirScore <= -4
    slopeSign := -1.0
else if dirScore >= 2
    slopeSign := 0.5
else if dirScore <= -2
    slopeSign := -0.5
else
    slopeSign := 0.0
float regimeMult = aerTrending ? 1.0 : aerConsolidation ? 0.5 : 0.2
regSlope = lrSlope * regimeMult * math.abs(slopeSign)
regSlope := slopeSign >= 0 ? math.abs(regSlope) : -math.abs(regSlope)
regNow = regNow40
regFwd = regNow + regSlope * projFwd
float hvbBinSize = hvbHi > hvbLo ? (hvbHi - hvbLo) / hvbBins : 0.0
var array<float> hvbBinCalc = array.new_float(0)
var array<float> hvbBinBuy = array.new_float(0)
var array<float> hvbBinSell = array.new_float(0)
if hvbBinSize > 0
    array.clear(hvbBinCalc)
    array.clear(hvbBinBuy)
    array.clear(hvbBinSell)
    for _i = 0 to hvbBins - 1
        array.push(hvbBinCalc, 0.0)
        array.push(hvbBinBuy, 0.0)
        array.push(hvbBinSell, 0.0)
    for i = 0 to hvbLookback - 1
        int bIdx = int(math.max(0, math.min(math.floor((close[i] - hvbLo) / hvbBinSize), hvbBins - 1)))
        float bVol = nz(volume[i])
        array.set(hvbBinCalc, bIdx, array.get(hvbBinCalc, bIdx) + bVol)
        if close[i] > open[i]
            array.set(hvbBinBuy, bIdx, array.get(hvbBinBuy, bIdx) + bVol)
        else if close[i] < open[i]
            array.set(hvbBinSell, bIdx, array.get(hvbBinSell, bIdx) + bVol)
        else
            array.set(hvbBinBuy, bIdx, array.get(hvbBinBuy, bIdx) + bVol * 0.5)
            array.set(hvbBinSell, bIdx, array.get(hvbBinSell, bIdx) + bVol * 0.5)
    float hvbTotalVol = 0.0
    int pocIdx = 0
    float pocVol = 0.0
    for j = 0 to hvbBins - 1
        float bv = array.get(hvbBinCalc, j)
        hvbTotalVol += bv
        if bv > pocVol
            pocVol := bv
            pocIdx := j
    hvbZone1 := hvbLo + pocIdx * hvbBinSize + hvbBinSize / 2.0
    float pocBuyVol = array.get(hvbBinBuy, pocIdx)
    float pocSellVol = array.get(hvbBinSell, pocIdx)
    pocBuyPct := pocVol > 0 ? pocBuyVol / pocVol * 100 : 50.0
    pocRawBuy := pocBuyVol
    pocRawSell := pocSellVol
    float vaTarget = hvbTotalVol * 0.70
    float vaVol = pocVol
    int vaLowIdx = pocIdx
    int vaHighIdx = pocIdx
    for _step = 0 to hvbBins - 1
        if vaVol >= vaTarget or (vaLowIdx <= 0 and vaHighIdx >= hvbBins - 1)
            break
        float volBelow = vaLowIdx > 0 ? array.get(hvbBinCalc, vaLowIdx - 1) : 0.0
        float volAbove = vaHighIdx < hvbBins - 1 ? array.get(hvbBinCalc, vaHighIdx + 1) : 0.0
        if volBelow >= volAbove and vaLowIdx > 0
            vaLowIdx -= 1
            vaVol += volBelow
        else if vaHighIdx < hvbBins - 1
            vaHighIdx += 1
            vaVol += volAbove
        else if vaLowIdx > 0
            vaLowIdx -= 1
            vaVol += volBelow
    vahLevel := hvbLo + (vaHighIdx + 1) * hvbBinSize
    valLevel := hvbLo + vaLowIdx * hvbBinSize
    int povIdx = pocIdx
    float povMinVol = pocVol
    for j = vaLowIdx to vaHighIdx
        if j != pocIdx and array.get(hvbBinCalc, j) < povMinVol
            povMinVol := array.get(hvbBinCalc, j)
            povIdx := j
    povLevel := hvbLo + povIdx * hvbBinSize + hvbBinSize / 2.0
    nodeStrength := hvbTotalVol > 0 ? pocVol / hvbTotalVol * 100 : 0.0
    array.set(hvbBinCalc, pocIdx, 0.0)
    for rank = 0 to 1
        int maxIdx = 0
        float maxVal = 0.0
        for j = 0 to array.size(hvbBinCalc) - 1
            if array.get(hvbBinCalc, j) > maxVal
                maxVal := array.get(hvbBinCalc, j)
                maxIdx := j
        if maxVal > 0
            float zMid = hvbLo + maxIdx * hvbBinSize + hvbBinSize / 2.0
            if rank == 0
                hvbZone2 := zMid
            else
                hvbZone3 := zMid
            array.set(hvbBinCalc, maxIdx, 0.0)
var line projMidLine = na
var line projHiLine = na
var line projLoLine = na
var linefill projFill = na
if barstate.islast
    line.delete(projMidLine)
    line.delete(projHiLine)
    line.delete(projLoLine)
    linefill.delete(projFill)
    float coneStartW = atr * 0.2
    float coneEndW = atr * math.sqrt(projFwd) * 0.5
    color pCol = slopeSign > 0 ? color.new(color.teal, 40) : slopeSign < 0 ? color.new(color.red, 40) : color.new(color.gray, 60)
    color pColEdge = slopeSign > 0 ? color.new(color.teal, 75) : slopeSign < 0 ? color.new(color.red, 75) : color.new(color.gray, 80)
    color pColFill = slopeSign > 0 ? color.new(color.teal, 90) : slopeSign < 0 ? color.new(color.red, 90) : color.new(color.gray, 92)
    projMidLine := line.new(bar_index, regNow, bar_index + projFwd, regFwd, color=pCol, width=1, style=line.style_dashed)
    projHiLine := line.new(bar_index, regNow + coneStartW, bar_index + projFwd, regFwd + coneEndW, color=pColEdge, width=1, style=line.style_dotted)
    projLoLine := line.new(bar_index, regNow - coneStartW, bar_index + projFwd, regFwd - coneEndW, color=pColEdge, width=1, style=line.style_dotted)
    projFill := linefill.new(projHiLine, projLoLine, pColFill)
var label lblST = na
var label lblDP = na
if barstate.islast
    label.delete(lblST)
    label.delete(lblDP)
    if showSuperTrend
        lblST := label.new(bar_index, stPlot, "ST", color=color.new(color.white, 100), textcolor=stTrend == 1 ? color.new(color.teal, 30) : color.new(color.red, 30), style=label.style_label_left, size=size.normal)
    if showDirPulse
        lblDP := label.new(bar_index, ema21, "DP", color=color.new(color.white, 100), textcolor=dirPulseCol, style=label.style_label_left, size=size.normal) 
var array<line>  nwogLines  = array.new_line(0)
var array<label> nwogLabels = array.new_label(0)
if barstate.islast
    if array.size(nwogLines) > 0
        for i = 0 to array.size(nwogLines) - 1
            line.delete(array.get(nwogLines, i))
        array.clear(nwogLines)
    if array.size(nwogLabels) > 0
        for i = 0 to array.size(nwogLabels) - 1
            label.delete(array.get(nwogLabels, i))
        array.clear(nwogLabels)
    if showNWOG and array.size(nwogBar) > 0
        color _nwCol   = color.new(#607D8B, 0)
        int   _nwRight = bar_index + 10
        for i = 0 to array.size(nwogBar) - 1
            int   b  = math.max(array.get(nwogBar, i), bar_index - 480)
            float op = array.get(nwogOpen, i)
            float cl = array.get(nwogClose, i)
            float hi = math.max(op, cl)
            float lo = math.min(op, cl)
            float ce = math.avg(op, cl)
            array.push(nwogLines, line.new(b, hi, _nwRight, hi, color=_nwCol, width=1))
            array.push(nwogLines, line.new(b, lo, _nwRight, lo, color=_nwCol, width=1))
            array.push(nwogLines, line.new(b, ce, _nwRight, ce, color=_nwCol, width=1, style=line.style_dashed))
            array.push(nwogLabels, label.new(_nwRight, hi, "NWOG", color=color.new(color.white, 100), textcolor=_nwCol, style=label.style_label_left, size=size.small))
            array.push(nwogLabels, label.new(_nwRight, ce, "CE", color=color.new(color.white, 100), textcolor=_nwCol, style=label.style_label_left, size=size.small))
bool allClear = liquidityOk and aerTrending
string statusTxt = allClear and aerUptrend ? "GO ▲ UPTREND" : allClear and aerDowntrend ? "GO ▼ DOWNTREND" : not liquidityOk ? "NO — LOW LIQ" : aerChoppy ? "NO — CHOPPY" : aerConsolidation ? "WAIT — CONSOL" : "NO — FLAT"
color statusCol = allClear ? color.new(color.green, 0) : aerConsolidation ? color.new(color.yellow, 0) : color.red
dirTxt = dirScore >= 5 ? "▲▲ STRONG BULL (" + str.tostring(dirScore, "#.0") + ")" : dirScore >= 2 ? "▲ LEAN BULL (" + str.tostring(dirScore, "#.0") + ")" : dirScore <= -5 ? "▼▼ STRONG BEAR (" + str.tostring(dirScore, "#.0") + ")" : dirScore <= -2 ? "▼ LEAN BEAR (" + str.tostring(dirScore, "#.0") + ")" : "— NO EDGE (" + str.tostring(dirScore, "#.0") + ")"
dirCol = dirScore >= 5 ? color.new(color.green, 0) : dirScore >= 2 ? color.new(color.teal, 0) : dirScore <= -5 ? color.red : dirScore <= -2 ? color.new(color.orange, 0) : color.gray
htfTxt = htfConfScore >= 5 ? "▲▲ HTF BULL (" + str.tostring(htfConfScore, "#.0") + ")" : htfConfScore >= 2 ? "▲ HTF BULL (" + str.tostring(htfConfScore, "#.0") + ")" : htfConfScore <= -5 ? "▼▼ HTF BEAR (" + str.tostring(htfConfScore, "#.0") + ")" : htfConfScore <= -2 ? "▼ HTF BEAR (" + str.tostring(htfConfScore, "#.0") + ")" : "◆ HTF MIXED (" + str.tostring(htfConfScore, "#.0") + ")"
htfCol = htfConfScore >= 5 ? color.new(color.green, 0) : htfConfScore >= 2 ? color.new(color.teal, 0) : htfConfScore <= -5 ? color.red : htfConfScore <= -2 ? color.new(color.orange, 0) : color.gray
flowInflTxt = _slopeAccelNorm >= 0.5 and fpDeltaBull ? "▲▲ ACCEL+" : _slopeAccelNorm >= 0.3 and fpDeltaBull ? "▲ accel" : _slopeAccelNorm <= -0.5 and fpDeltaBear ? "▼▼ ACCEL-" : _slopeAccelNorm <= -0.3 and fpDeltaBear ? "▼ accel" : "— flat"
flowInflCol = _slopeAccelNorm >= 0.5 and fpDeltaBull ? color.new(color.green, 0) : _slopeAccelNorm >= 0.3 and fpDeltaBull ? color.new(color.teal, 0) : _slopeAccelNorm <= -0.5 and fpDeltaBear ? color.red : _slopeAccelNorm <= -0.3 and fpDeltaBear ? color.new(color.orange, 0) : color.gray
var table dash = table.new(position.bottom_right, 1, 4, bgcolor=color.new(color.black, 60), border_width=1, border_color=color.new(color.gray, 70))
if barstate.islast
    table.cell(dash, 0, 0, dirTxt, text_color=dirCol, text_size=size.normal)
    table.cell(dash, 0, 1, htfTxt, text_color=htfCol, text_size=size.normal)
    table.cell(dash, 0, 2, statusTxt, text_color=statusCol, text_size=size.normal)
    table.cell(dash, 0, 3, flowInflTxt, text_color=flowInflCol, text_size=size.normal)
bool buyFired = inLong and entryBar == bar_index
bool sellFired = inShort and entryBar == bar_index
if buyFired
    alert("BUY @ " + str.tostring(close, "#.##"), alert.freq_once_per_bar)
if sellFired
    alert("SELL @ " + str.tostring(close, "#.##"), alert.freq_once_per_bar)
alertcondition(buyFired, title="BUY", message="BUY @ {{close}}")
alertcondition(sellFired, title="SELL", message="SELL @ {{close}}")
alertcondition(tpLongHit or tpShortHit, title="TP Hit", message="TP HIT @ {{close}}")
alertcondition(slLongHit or slShortHit, title="SL Hit", message="SL HIT @ {{close}}")
plot(showPivots and not na(pivotPP) ? pivotPP : na, title="PP", color=color.new(color.gray,    20), linewidth=1, style=plot.style_linebr)
plot(showPivots and not na(pivotR1) ? pivotR1 : na, title="R1", color=color.new(color.red,     20), linewidth=2, style=plot.style_linebr)
plot(showPivots and not na(pivotS1) ? pivotS1 : na, title="S1", color=color.new(color.green,   20), linewidth=2, style=plot.style_linebr)
plot(showPivots and not na(pivotR2) ? pivotR2 : na, title="R2", color=color.new(color.maroon,  40), linewidth=1, style=plot.style_linebr)
plot(showPivots and not na(pivotS2) ? pivotS2 : na, title="S2", color=color.new(#006400,       40), linewidth=1, style=plot.style_linebr)
plot(showPrevDay and not na(prevDayH) ? prevDayH : na, title="PDH", color=color.new(color.orange, 25), linewidth=1, style=plot.style_circles)
plot(showPrevDay and not na(prevDayL) ? prevDayL : na, title="PDL", color=color.new(color.orange, 25), linewidth=1, style=plot.style_circles)
plot(showONLevels and not na(onHigh) ? onHigh : na, title="ON H", color=color.new(color.purple, 35), linewidth=1, style=plot.style_circles)
plot(showONLevels and not na(onLow)  ? onLow  : na, title="ON L", color=color.new(color.purple, 35), linewidth=1, style=plot.style_circles)
plot(showVolProf and not na(fpPocMid) ? fpPocMid : na, title="POC", color=color.new(#FFC107, 20), linewidth=2, style=plot.style_linebr)
plot(showVolProf and not na(fpVAH)    ? fpVAH    : na, title="VAH", color=color.new(#5C6BC0, 50), linewidth=1, style=plot.style_linebr)
plot(showVolProf and not na(fpVAL)    ? fpVAL    : na, title="VAL", color=color.new(#5C6BC0, 50), linewidth=1, style=plot.style_linebr)
var box hvbBox = na
if showHvbZones and barstate.islast and not na(hvbZone1) and hvbBinSize > 0
    box.delete(hvbBox)
    hvbBox := box.new(bar_index - hvbLookback, hvbZone1 + hvbBinSize / 2.0, bar_index + 5, hvbZone1 - hvbBinSize / 2.0, border_color=color.new(#607D8B, 60), bgcolor=color.new(#607D8B, 90), border_width=1)
plot(showVWAP ? vwapVal : na, title="VWAP", color=color.new(color.yellow, 20), linewidth=1)
var label lblVW = na
if showVWAP and barstate.islast and not na(vwapVal)
    label.delete(lblVW)
    lblVW := label.new(bar_index, vwapVal, "VW", color=color.new(color.white, 100), textcolor=color.new(color.yellow, 20), style=label.style_label_left, size=size.normal)
var label lblPOC = na
var label lblVAH = na
var label lblVAL = na
if showVolProf and barstate.islast
    if not na(fpPocMid)
        label.delete(lblPOC)
        lblPOC := label.new(bar_index, fpPocMid, "POC", color=color.new(color.white, 100), textcolor=color.new(#FFC107, 20), style=label.style_label_left, size=size.normal)
    if not na(fpVAH)
        label.delete(lblVAH)
        lblVAH := label.new(bar_index, fpVAH, "VAH", color=color.new(color.white, 100), textcolor=color.new(#5C6BC0, 20), style=label.style_label_left, size=size.normal)
    if not na(fpVAL)
        label.delete(lblVAL)
        lblVAL := label.new(bar_index, fpVAL, "VAL", color=color.new(color.white, 100), textcolor=color.new(#5C6BC0, 20), style=label.style_label_left, size=size.normal)
var label lblPP = na
var label lblR1 = na
var label lblS1 = na
var label lblR2 = na
var label lblS2 = na
if showPivots and barstate.islast
    if not na(pivotPP)
        label.delete(lblPP)
        lblPP := label.new(bar_index, pivotPP, "PP", color=color.new(color.white, 100), textcolor=color.new(color.gray, 20), style=label.style_label_left, size=size.normal)
    if not na(pivotR1)
        label.delete(lblR1)
        lblR1 := label.new(bar_index, pivotR1, "R1", color=color.new(color.white, 100), textcolor=color.new(color.red, 20), style=label.style_label_left, size=size.normal)
    if not na(pivotS1)
        label.delete(lblS1)
        lblS1 := label.new(bar_index, pivotS1, "S1", color=color.new(color.white, 100), textcolor=color.new(color.green, 20), style=label.style_label_left, size=size.normal)
    if not na(pivotR2)
        label.delete(lblR2)
        lblR2 := label.new(bar_index, pivotR2, "R2", color=color.new(color.white, 100), textcolor=color.new(color.maroon, 20), style=label.style_label_left, size=size.normal)
    if not na(pivotS2)
        label.delete(lblS2)
        lblS2 := label.new(bar_index, pivotS2, "S2", color=color.new(color.white, 100), textcolor=color.new(#006400, 20), style=label.style_label_left, size=size.normal)
var label lblPDH = na
var label lblPDL = na
if showPrevDay and barstate.islast
    if not na(prevDayH)
        label.delete(lblPDH)
        lblPDH := label.new(bar_index, prevDayH, "PDH", color=color.new(color.white, 100), textcolor=color.new(color.orange, 20), style=label.style_label_left, size=size.normal)
    if not na(prevDayL)
        label.delete(lblPDL)
        lblPDL := label.new(bar_index, prevDayL, "PDL", color=color.new(color.white, 100), textcolor=color.new(color.orange, 20), style=label.style_label_left, size=size.normal)
var label lblONH = na
var label lblONL = na
if showONLevels and barstate.islast
    if not na(onHigh)
        label.delete(lblONH)
        lblONH := label.new(bar_index, onHigh, "ON H", color=color.new(color.white, 100), textcolor=color.new(color.purple, 20), style=label.style_label_left, size=size.normal)
    if not na(onLow)
        label.delete(lblONL)
        lblONL := label.new(bar_index, onLow, "ON L", color=color.new(color.white, 100), textcolor=color.new(color.purple, 20), style=label.style_label_left, size=size.normal)
var label lblHVB = na
if showHvbZones and barstate.islast and not na(hvbZone1)
    label.delete(lblHVB)
    lblHVB := label.new(bar_index, hvbZone1, "HVB", color=color.new(color.white, 100), textcolor=color.new(#607D8B, 20), style=label.style_label_left, size=size.normal)
bgcolor(showHotZone and inHotZone ? color.new(#FFA000, 92) : na, title="Hot Zone")
````
