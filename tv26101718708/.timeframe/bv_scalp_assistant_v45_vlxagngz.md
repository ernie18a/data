# BV Scalp Assistant v4.5 

- url: https://www.tradingview.com/script/vlxaGngZ/
- type: indicator
- pine_id: PUB;44f811e488314784b822713db7a39bb3
- version: 4.0

## Description

Bob Volman氏の5分足スキャルピングの考え方をベースにした、短期トレード支援インジケーターです。

EMA・Build-up（圧縮）・パワーバー・Triple Test・キリ番・直近高安などを組み合わせ、
「準備段階 → セットアップ形成 → ブレイクエントリー → 手仕舞い警戒」までを視覚的にサポートします。

WATCH / SETUP / BUY GO / SELL GO などのラベル表示により、
エントリー前後の状況を分かりやすく確認可能。

さらに、TP・SL・RR表示、途中利確候補、建値逃げ候補、反転クラスター警戒など、
Bob Volman的な“逃げ方”や“利確判断”も取り入れています。

主にユーロドル。5分足〜短期スキャルピング向け。

A short-term scalping assistant inspired by Bob Volman’s 5-minute price action methodology.
This indicator combines EMA behavior, Build-up compression, Power Bars, Triple Tests, round numbers, and recent swing levels to help visualize the full trading process:
Preparation → Setup Formation → Breakout Entry → Exit Management.
Clear labels such as WATCH, SETUP, BUY GO, and SELL GO make it easy to understand market conditions before and after entry.
It also includes TP/SL/RR visualization, partial take-profit warnings, breakeven exit detection, and reversal-cluster cautions — reflecting Bob Volman-style trade management concepts.
Designed mainly for 5-minute chart scalping and short-term trading.

## Source Code

````pine
//@version=5
indicator("BV Build-up Detector v2.0", shorttitle="Build-up v2", overlay=true, max_lines_count=200, max_labels_count=200, max_boxes_count=50)

// ============================================================
// INPUT PARAMETERS
// ============================================================

grp_core = "▼ 基本設定 / 25EMA"
emaLen = input.int(25, "EMA期間", minval=1, group=grp_core)
emaSlopeMult = input.float(0.015, "EMA傾き判定 ATR倍率", minval=0.001, step=0.001, group=grp_core)
emaNearATR = input.float(0.80, "EMA付近判定 ATR倍率", minval=0.10, step=0.05, group=grp_core)
emaStretchATR = input.float(1.20, "25EMA乖離上限 ATR倍率", minval=0.30, maxval=3.00, step=0.05, group=grp_core)
showEMA = input.bool(true, "25EMAを表示", group=grp_core)
useHtfEmaFilter = input.bool(true, "1時間足25EMAフィルターを使う", group=grp_core)
htfTf = input.timeframe("60", "上位足時間軸", group=grp_core)
showHtfEMA = input.bool(true, "1時間足25EMAを表示", group=grp_core)
showH4SMA = input.bool(true, "4時間足20SMAを表示", group=grp_core)
h4SmaLen = input.int(20, "4時間足SMA期間", minval=1, group=grp_core)
h4SmaTf = input.timeframe("240", "4時間足SMA時間軸", group=grp_core)
htfEmaDivATR = input.float(2.0, "1時間足25EMA乖離判定 ATR倍率", minval=0.30, maxval=5.00, step=0.05, group=grp_core)

grp_build = "▼ ビルドアップ判定"
buildLen = input.int(6, "判定本数", minval=3, maxval=12, group=grp_build)
buildRangeATR = input.float(1.10, "値幅縮小 ATR倍率", minval=0.30, maxval=2.00, step=0.05, group=grp_build)
smallBarATR = input.float(0.85, "小さい足 ATR倍率", minval=0.20, maxval=2.00, step=0.05, group=grp_build)
noiseBarsAllowed = input.int(2, "許容ノイズ足数", minval=0, maxval=5, group=grp_build)
buildScoreMinFloat = input.float(4.0, "ビルドアップ最低点", minval=1.0, maxval=7.0, step=0.5, group=grp_build)

grp_overlap = "▼ 重なり率"
overlapThreshold = input.float(0.55, "重なり率閾値", minval=0.20, maxval=0.90, step=0.05, group=grp_overlap)

grp_noise = "▼ ノイズ耐性"
noiseBodyThreshold = input.float(0.40, "ノイズ足ヒゲ主体 実体比率", minval=0.20, maxval=0.60, step=0.05, group=grp_noise)
noiseRangeMargin = input.float(0.15, "レンジ内ノイズ許容 ATR倍率", minval=0.05, maxval=0.50, step=0.05, group=grp_noise)

grp_dir = "▼ 方向判定"
directionScoreMin = input.float(4.0, "直前シグナル必要方向点", minval=1.0, maxval=6.0, step=0.5, group=grp_dir)
directionGapMin = input.float(1.0, "買い売り方向点の最低差", minval=0.0, maxval=6.0, step=0.5, group=grp_dir)
closePosBuy = input.float(0.55, "買い直前 終値位置", minval=0.0, maxval=1.0, step=0.05, group=grp_dir)
closePosSell = input.float(0.45, "売り直前 終値位置", minval=0.0, maxval=1.0, step=0.05, group=grp_dir)
breakNearATR = input.float(0.35, "高値/安値接近 ATR倍率", minval=0.05, maxval=1.00, step=0.05, group=grp_dir)
htfPenaltyVal = input.float(1.0, "HTF逆方向ペナルティ", minval=0.0, maxval=3.0, step=0.5, group=grp_dir)

grp_range = "▼ レンジ対策"
useRangeFilter = input.bool(true, "レンジフィルターを使う", group=grp_range)
rangeLookback = input.int(30, "レンジ判定本数", minval=10, maxval=100, group=grp_range)
rangeWidthATR = input.float(4.00, "レンジ幅 ATR倍率", minval=1.00, maxval=10.00, step=0.25, group=grp_range)
rangeEmaFlatATR = input.float(0.60, "レンジEMA横向き ATR倍率", minval=0.10, maxval=2.00, step=0.05, group=grp_range)
rangeCrossMin = input.int(3, "EMAまたぎ回数", minval=1, maxval=20, group=grp_range)
rangeUpperPct = input.float(0.72, "レンジ上限ゾーン", minval=0.50, maxval=0.95, step=0.01, group=grp_range)
rangeLowerPct = input.float(0.28, "レンジ下限ゾーン", minval=0.05, maxval=0.50, step=0.01, group=grp_range)
rangeDirectionGapMin = input.float(2.0, "レンジ中の方向点差", minval=0.0, maxval=6.0, step=0.5, group=grp_range)

grp_overext = "▼ 伸び切り除外"
surgeLookback = input.int(5, "急騰/急落チェック本数", minval=2, maxval=12, group=grp_overext)
surgeATR = input.float(1.50, "急騰/急落判定 ATR倍率", minval=0.50, maxval=4.00, step=0.10, group=grp_overext)
powerLookback = input.int(3, "強すぎる足チェック本数", minval=1, maxval=8, group=grp_overext)
powerBarATR = input.float(1.20, "強すぎる足 ATR倍率", minval=0.50, maxval=4.00, step=0.10, group=grp_overext)
powerBodyRatio = input.float(0.55, "強すぎる足 実体比率", minval=0.30, maxval=1.00, step=0.05, group=grp_overext)

grp_barrier = "▼ ライン / キリ番"
swingLen = input.int(8, "スイング検出期間", minval=3, maxval=30, group=grp_barrier)
barrierLookback = input.int(36, "過去ライン参照本数", minval=10, maxval=100, group=grp_barrier)
barrierNearPips = input.int(6, "ライン付近判定 pips", minval=1, maxval=30, group=grp_barrier)
roundPips = input.int(50, "キリ番間隔 pips", minval=10, maxval=200, group=grp_barrier)
useRoundBarrier = input.bool(true, "キリ番をライン判定に含める", group=grp_barrier)
minRoomPips = input.int(8, "最低余地 pips", minval=1, maxval=50, group=grp_barrier)

grp_session = "▼ 時間帯 JST"
useSessionFilter = input.bool(false, "時間帯フィルターを使う", group=grp_session)
jstLondonS = input.int(16, "ロンドン開始 JST", minval=0, maxval=30, group=grp_session)
jstLondonE = input.int(25, "ロンドン終了 JST ※25=翌1時", minval=0, maxval=30, group=grp_session)
jstNYS = input.int(21, "NY開始 JST", minval=0, maxval=30, group=grp_session)
jstNYE = input.int(27, "NY終了 JST ※27=翌3時", minval=0, maxval=30, group=grp_session)

grp_display = "▼ 表示"
showMainLabels = input.bool(true, "Build-UP表示", group=grp_display)
showBuildBox = input.bool(true, "ビルドアップ範囲ボックス表示", group=grp_display)
showBreakLine = input.bool(true, "高値/安値ライン表示", group=grp_display)
showBoard = input.bool(true, "日本語ボード表示", group=grp_display)
showDetailBoard = input.bool(true, "点数内訳を表示", group=grp_display)
cooldownBars = input.int(8, "直前シグナルのクールダウン本数", minval=0, maxval=50, group=grp_display)

grp_alert = "▼ アラート"
alertOnWatch = input.bool(false, "ビルドアップ監視アラートを使う", group=grp_alert)

// ============================================================
// CORE CALCULATIONS
// ============================================================

atrVal = ta.atr(14)
emaVal = ta.ema(close, emaLen)
h4SmaVal = request.security(syminfo.tickerid, h4SmaTf, ta.sma(close, h4SmaLen), barmerge.gaps_off, barmerge.lookahead_off)
htfEmaVal = request.security(syminfo.tickerid, htfTf, ta.ema(close, emaLen), barmerge.gaps_off, barmerge.lookahead_off)
htfEmaDistance = math.abs(close - htfEmaVal)
htfEmaDiverged = htfEmaDistance >= atrVal * htfEmaDivATR
htfBuyOnly = htfEmaVal < emaVal
htfSellOnly = htfEmaVal > emaVal
emaSlope = emaVal - emaVal[3]
isJPY = syminfo.currency == "JPY" or syminfo.basecurrency == "JPY"
pipSize = isJPY ? 0.01 : 0.0001

emaBull = emaSlope > atrVal * emaSlopeMult
emaBear = emaSlope < -atrVal * emaSlopeMult
emaFlat = not emaBull and not emaBear
emaColor = emaBull ? color.new(#00bcd4, 0) : emaBear ? color.new(#ff5252, 0) : color.new(#ffd54f, 0)

plot(showEMA ? emaVal : na, "25 EMA", color=emaColor, linewidth=2)
plot(showHtfEMA ? htfEmaVal : na, "1時間足 25EMA", color=color.new(#ffd54f, 0), linewidth=2)
plot(showH4SMA ? h4SmaVal : na, "4時間足 20SMA", color=color.new(color.white, 0), linewidth=2)

// ============================================================
// SESSION
// ============================================================

jstHour = hour(time, "Asia/Tokyo")
f_inSession(_start, _end) => _end <= 24 ? (jstHour >= _start and jstHour < _end) : (jstHour >= _start or jstHour < (_end - 24))

inLondon = f_inSession(jstLondonS, jstLondonE)
inNY = f_inSession(jstNYS, jstNYE)
inOverlap = inLondon and inNY
inActiveSession = inLondon or inNY
timeOK = useSessionFilter ? inActiveSession : true

// ============================================================
// SWING / BARRIER
// ============================================================

swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow = ta.pivotlow(low, swingLen, swingLen)

var float lastH1 = na
var float lastH2 = na
var float lastL1 = na
var float lastL2 = na

if not na(swingHigh)
    lastH2 := lastH1
    lastH1 := swingHigh

if not na(swingLow)
    lastL2 := lastL1
    lastL1 := swingLow

roundStep = roundPips * pipSize
upperRound = math.ceil(close / roundStep) * roundStep
lowerRound = math.floor(close / roundStep) * roundStep

recentRes = ta.highest(high[buildLen], barrierLookback)
recentSup = ta.lowest(low[buildLen], barrierLookback)

bigUp = close + 100000.0 * pipSize
bigDn = close - 100000.0 * pipSize

targetUp1 = not na(lastH1) and lastH1 > close ? lastH1 : bigUp
targetUp2 = not na(lastH2) and lastH2 > close ? lastH2 : bigUp
targetUp3 = not na(recentRes) and recentRes > close ? recentRes : bigUp
targetUp4 = useRoundBarrier and upperRound > close ? upperRound : bigUp
nearestUpperRaw = math.min(math.min(targetUp1, targetUp2), math.min(targetUp3, targetUp4))
nearestUpper = nearestUpperRaw == bigUp ? na : nearestUpperRaw

targetDn1 = not na(lastL1) and lastL1 < close ? lastL1 : bigDn
targetDn2 = not na(lastL2) and lastL2 < close ? lastL2 : bigDn
targetDn3 = not na(recentSup) and recentSup < close ? recentSup : bigDn
targetDn4 = useRoundBarrier and lowerRound < close ? lowerRound : bigDn
nearestLowerRaw = math.max(math.max(targetDn1, targetDn2), math.max(targetDn3, targetDn4))
nearestLower = nearestLowerRaw == bigDn ? na : nearestLowerRaw

nearestUpPips = not na(nearestUpper) ? math.round((nearestUpper - close) / pipSize) : 100000
nearestDownPips = not na(nearestLower) ? math.round((close - nearestLower) / pipSize) : 100000

// ============================================================
// BUILD-UP RANGE (基本)
// ============================================================

cHigh = ta.highest(high, buildLen)
cLow = ta.lowest(low, buildLen)
cRange = cHigh - cLow

barRange = high - low
bodySize = math.abs(close - open)
bodyRatioNow = barRange > 0 ? bodySize / barRange : 0.0

avgBarNow = ta.sma(barRange, buildLen)
avgBarPrev = ta.sma(barRange, buildLen)[buildLen]
rangePast = ta.highest(high, buildLen)[buildLen] - ta.lowest(low, buildLen)[buildLen]

smallBarCount = ta.sma(barRange < atrVal * smallBarATR ? 1.0 : 0.0, buildLen) * buildLen
smallBarOK = smallBarCount >= buildLen - noiseBarsAllowed

narrowRange = cRange <= atrVal * buildRangeATR
momentumDrop = not na(avgBarPrev) and avgBarNow < avgBarPrev
rangeContract = not na(rangePast) and cRange < rangePast

emaNearCluster = emaVal >= cLow - atrVal * emaNearATR and emaVal <= cHigh + atrVal * emaNearATR
emaDistanceOK = math.abs(close - emaVal) <= atrVal * emaStretchATR

// ============================================================
// 改良① : 重なり率 (Weighted Overlap Score)
// ============================================================

weightedOverlap = 0.0
weightSum = 0.0
for i = 0 to buildLen - 2
    w = 1.0 + float(buildLen - 1 - i) * 0.5
    br_i = high[i] - low[i]
    br_i1 = high[i + 1] - low[i + 1]
    ov = math.max(0.0, math.min(high[i], high[i + 1]) - math.max(low[i], low[i + 1]))
    mx = math.max(br_i, br_i1)
    weightedOverlap += (mx > 0 ? ov / mx : 0.0) * w
    weightSum += w
avgOverlap = weightSum > 0 ? weightedOverlap / weightSum : 0.0
overlapOK = avgOverlap >= overlapThreshold

// ============================================================
// 改良③ : ノイズ耐性
// ============================================================

wickNoiseCount = 0
hardNoiseCount = 0
for i = 0 to buildLen - 1
    br_i = high[i] - low[i]
    if br_i >= atrVal * smallBarATR
        bdy_i = math.abs(close[i] - open[i])
        bodyR_i = br_i > 0 ? bdy_i / br_i : 0.0
        withinRange = high[i] <= cHigh + atrVal * noiseRangeMargin and low[i] >= cLow - atrVal * noiseRangeMargin
        if bodyR_i < noiseBodyThreshold
            wickNoiseCount += 1
        else if withinRange
            wickNoiseCount += 1
        else
            hardNoiseCount += 1

noiseQualityGood = wickNoiseCount > hardNoiseCount or hardNoiseCount == 0

// ============================================================
// 改良② : 段階的収束 (Progressive Compression)
// ============================================================

halfLen = math.max(2, int(math.floor(buildLen * 0.5)))
frontOffset = buildLen - halfLen
firstHalfRange = ta.highest(high[frontOffset], halfLen) - ta.lowest(low[frontOffset], halfLen)
secondHalfRange = ta.highest(high, halfLen) - ta.lowest(low, halfLen)
archCompression = not na(firstHalfRange) and secondHalfRange < firstHalfRange

thirdLen = math.max(2, int(math.floor(buildLen / 3.0)))
seg1End = buildLen - thirdLen
seg2End = buildLen - thirdLen * 2
seg1Offset = math.max(0, seg1End)
seg2Offset = math.max(0, seg2End)

seg1Range = ta.highest(high[seg1Offset], thirdLen) - ta.lowest(low[seg1Offset], thirdLen)
seg2Range = ta.highest(high[seg2Offset], thirdLen) - ta.lowest(low[seg2Offset], thirdLen)
seg3Range = ta.highest(high, thirdLen) - ta.lowest(low, thirdLen)
progressiveCompression = not na(seg1Range) and not na(seg2Range) and seg1Range > seg2Range and seg2Range > seg3Range

lowTrendUp = ta.linreg(low, buildLen, 0) > ta.linreg(low, buildLen, 1)
highTrendDn = ta.linreg(high, buildLen, 0) < ta.linreg(high, buildLen, 1)

directionalCompression = lowTrendUp or highTrendDn or archCompression or rangeContract
strongCompression = progressiveCompression or (archCompression and momentumDrop)

barrierNearUp = not na(nearestUpper) and math.abs(nearestUpper - cHigh) <= barrierNearPips * pipSize
barrierNearDown = not na(nearestLower) and math.abs(cLow - nearestLower) <= barrierNearPips * pipSize
barrierNearAny = barrierNearUp or barrierNearDown

closePos = cRange > 0 ? (close - cLow) / cRange : 0.5

lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)
lowerWickSum = ta.sma(lowerWick, buildLen) * buildLen
upperWickSum = ta.sma(upperWick, buildLen) * buildLen

bullBody = close > open ? close - open : 0.0
bearBody = close < open ? open - close : 0.0
bullBodyAvg = ta.sma(bullBody, buildLen)
bearBodyAvg = ta.sma(bearBody, buildLen)
bodyAvg = ta.sma(bodySize, buildLen)

sellPressureWeak = bodyAvg > 0 ? bearBodyAvg <= bodyAvg * 0.55 : true
buyPressureWeak = bodyAvg > 0 ? bullBodyAvg <= bodyAvg * 0.55 : true

// ============================================================
// RANGE FILTER
// ============================================================

rangeHigh = ta.highest(high, rangeLookback)
rangeLow = ta.lowest(low, rangeLookback)
rangeSize = rangeHigh - rangeLow
rangePos = rangeSize > 0 ? (close - rangeLow) / rangeSize : 0.5

rangeWidthOK = rangeSize <= atrVal * rangeWidthATR
rangeEmaFlat = math.abs(emaVal - emaVal[rangeLookback]) <= atrVal * rangeEmaFlatATR
emaCrossCount = ta.sma(ta.cross(close, emaVal) ? 1.0 : 0.0, rangeLookback) * rangeLookback
rangeCrossOK = emaCrossCount >= rangeCrossMin

isRange = useRangeFilter and rangeWidthOK and rangeEmaFlat and rangeCrossOK
rangeUpperZone = isRange and rangePos >= rangeUpperPct
rangeLowerZone = isRange and rangePos <= rangeLowerPct
rangeMiddleZone = isRange and not rangeUpperZone and not rangeLowerZone

rangeBuyAllowed = not useRangeFilter or not isRange or rangeUpperZone
rangeSellAllowed = not useRangeFilter or not isRange or rangeLowerZone

// ============================================================
// OVEREXTENSION FILTER
// ============================================================

recentRise = close - ta.lowest(low, surgeLookback)
recentDrop = ta.highest(high, surgeLookback) - close
notRecentSurgeUp = recentRise <= atrVal * surgeATR
notRecentSurgeDown = recentDrop <= atrVal * surgeATR

strongBullBar = close > open and barRange > atrVal * powerBarATR and bodyRatioNow >= powerBodyRatio
strongBearBar = close < open and barRange > atrVal * powerBarATR and bodyRatioNow >= powerBodyRatio

recentStrongBull = ta.highest(strongBullBar ? 1.0 : 0.0, powerLookback) > 0
recentStrongBear = ta.highest(strongBearBar ? 1.0 : 0.0, powerLookback) > 0

notAfterStrongBull = not recentStrongBull
notAfterStrongBear = not recentStrongBear

// ============================================================
// BUILD-UP SCORE (新体系: 7.0点満点・重み付き)
// ============================================================

scoreNarrow = narrowRange
scoreOverlap = overlapOK
scoreSmallBars = smallBarOK
scoreEMA = emaNearCluster
scoreCompression = strongCompression
scoreCompressionWeak = directionalCompression and not strongCompression
scoreBarrier = barrierNearAny
scoreNoise = noiseQualityGood

buildScoreFloat = (scoreNarrow ? 1.0 : 0.0) + (scoreOverlap ? 1.5 : 0.0) + (scoreSmallBars ? 1.0 : 0.0) + (scoreEMA ? 1.0 : 0.0) + (scoreCompression ? 1.5 : scoreCompressionWeak ? 0.75 : 0.0) + (scoreBarrier ? 0.5 : 0.0) + (scoreNoise ? 0.5 : 0.0)

isBuildUp = buildScoreFloat >= buildScoreMinFloat
newBuildUp = isBuildUp and not isBuildUp[1]

// ============================================================
// DIRECTION SCORE (改良④: 重み付き + HTFペナルティ)
// ============================================================

tradeRoomLong = nearestUpPips >= minRoomPips or barrierNearUp
tradeRoomShort = nearestDownPips >= minRoomPips or barrierNearDown

buyScoreTrend = emaBull or emaFlat
buyScoreEMA = close >= emaVal or emaNearCluster
buyScoreCompression = lowTrendUp or archCompression
buyScoreClosePos = closePos >= 0.45
buyScoreWickSupport = lowerWickSum >= upperWickSum
buyScoreBarrier = barrierNearUp or tradeRoomLong
buyScoreWeakOpp = sellPressureWeak

buyScoreRaw = (buyScoreTrend ? 1.5 : 0.0) + (buyScoreEMA ? 1.0 : 0.0) + (buyScoreCompression ? 1.5 : 0.0) + (buyScoreClosePos ? 1.0 : 0.0) + (buyScoreWickSupport ? 0.5 : 0.0) + (buyScoreBarrier and buyScoreWeakOpp ? 0.5 : 0.0)

sellScoreTrend = emaBear or emaFlat
sellScoreEMA = close <= emaVal or emaNearCluster
sellScoreCompression = highTrendDn or archCompression
sellScoreClosePos = closePos <= 0.55
sellScoreWickResistance = upperWickSum >= lowerWickSum
sellScoreBarrier = barrierNearDown or tradeRoomShort
sellScoreWeakOpp = buyPressureWeak

sellScoreRaw = (sellScoreTrend ? 1.5 : 0.0) + (sellScoreEMA ? 1.0 : 0.0) + (sellScoreCompression ? 1.5 : 0.0) + (sellScoreClosePos ? 1.0 : 0.0) + (sellScoreWickResistance ? 0.5 : 0.0) + (sellScoreBarrier and sellScoreWeakOpp ? 0.5 : 0.0)

// HTFペナルティ方式（完全ブロック → スコア減算に変更）
htfPenaltyBuy = useHtfEmaFilter and not htfBuyOnly ? htfPenaltyVal : 0.0
htfPenaltySell = useHtfEmaFilter and not htfSellOnly ? htfPenaltyVal : 0.0
buyScore = math.max(0.0, buyScoreRaw - htfPenaltyBuy)
sellScore = math.max(0.0, sellScoreRaw - htfPenaltySell)

// ============================================================
// PHASE DETECTION (改良②: 5段階フェーズ)
// ============================================================

// Phase 1: 形成初期 — 直近3本中2本以上が小さい足、かつEMA付近
recentSmallCount = 0
for i = 0 to math.min(2, buildLen - 1)
    if (high[i] - low[i]) < atrVal * smallBarATR
        recentSmallCount += 1

phase1Cond = recentSmallCount >= 2 and emaNearCluster

// Phase 2: 圧縮進行 — 重なり率が閾値の70%以上、かつスコアが最低点の60%以上
phase2Cond = avgOverlap >= overlapThreshold * 0.7 and buildScoreFloat >= buildScoreMinFloat * 0.6

// Phase 3: 成熟 — isBuildUp
phase3Cond = isBuildUp

// Phase 1 持続フィルター: 2本連続でPhase1条件を満たしている場合のみ
phase1Sustained = phase1Cond and phase1Cond[1]

// ============================================================
// BUILD-UP STATE
// ============================================================

buyBias = isBuildUp and buyScore > sellScore
sellBias = isBuildUp and sellScore > buyScore
neutralBias = isBuildUp and buyScore == sellScore

breakNearBuy = cRange > 0 and (cHigh - close) <= atrVal * breakNearATR
breakNearSell = cRange > 0 and (close - cLow) <= atrVal * breakNearATR

placeOKBuy = emaNearCluster or barrierNearUp
placeOKSell = emaNearCluster or barrierNearDown

normalBuyGapOK = buyScore - sellScore >= directionGapMin
normalSellGapOK = sellScore - buyScore >= directionGapMin
rangeBuyGapOK = not isRange or buyScore - sellScore >= rangeDirectionGapMin
rangeSellGapOK = not isRange or sellScore - buyScore >= rangeDirectionGapMin

buyHotRaw = timeOK and isBuildUp and buyScore >= directionScoreMin and buyScore > sellScore and normalBuyGapOK and rangeBuyGapOK and placeOKBuy and closePos >= closePosBuy and tradeRoomLong and emaDistanceOK and notRecentSurgeUp and notAfterStrongBull and rangeBuyAllowed
sellHotRaw = timeOK and isBuildUp and sellScore >= directionScoreMin and sellScore > buyScore and normalSellGapOK and rangeSellGapOK and placeOKSell and closePos <= closePosSell and tradeRoomShort and emaDistanceOK and notRecentSurgeDown and notAfterStrongBear and rangeSellAllowed

var int lastBuyHotBar = na
var int lastSellHotBar = na

buyCooldownOK = na(lastBuyHotBar) or bar_index - lastBuyHotBar > cooldownBars
sellCooldownOK = na(lastSellHotBar) or bar_index - lastSellHotBar > cooldownBars

buyHot = buyHotRaw and buyCooldownOK
sellHot = sellHotRaw and sellCooldownOK

if buyHot
    lastBuyHotBar := bar_index

if sellHot
    lastSellHotBar := bar_index

// Phase 4: 臨界 — buyHot or sellHot
phase4Cond = buyHot or sellHot

// 最終フェーズ決定
phase = phase4Cond ? 4 : phase3Cond ? 3 : phase2Cond ? 2 : phase1Sustained ? 1 : 0

// ============================================================
// OBJECTS
// ============================================================

var box buildBox = na
var line breakLine = na

if buyHot or sellHot
    if not na(buildBox)
        box.delete(buildBox)
    if not na(breakLine)
        line.delete(breakLine)
    if showBuildBox
        buildBoxColor = buyHot ? color.new(#00c853, 88) : color.new(#d50000, 88)
        buildBorderColor = buyHot ? color.new(#00c853, 35) : color.new(#d50000, 35)
        buildBox := box.new(bar_index - buildLen + 1, cHigh, bar_index + 3, cLow, bgcolor=buildBoxColor, border_color=buildBorderColor)
    if showBreakLine
        linePrice = buyHot ? cHigh : cLow
        lineColor = buyHot ? color.new(#00e676, 0) : color.new(#ff1744, 0)
        breakLine := line.new(bar_index - buildLen + 1, linePrice, bar_index + 3, linePrice, color=lineColor, style=line.style_dashed, width=2)

if not na(buildBox)
    box.set_right(buildBox, bar_index + 3)

if not na(breakLine)
    line.set_x2(breakLine, bar_index + 3)

// ============================================================
// CHART LABELS
// ============================================================
plotchar(showMainLabels and buyHot and not htfEmaDiverged, char="", location=location.belowbar, text="Build-UP↑", color=color.new(#00c853, 0), textcolor=color.new(#00c853, 0), size=size.small, title="Build-UP Buy")
plotchar(showMainLabels and sellHot and not htfEmaDiverged, char="", location=location.abovebar, text="Build-UP↓", color=color.new(#d50000, 0), textcolor=color.new(#d50000, 0), size=size.small, title="Build-UP Sell")

plotchar(showMainLabels and buyHot and htfEmaDiverged, char="", location=location.belowbar, text="△", color=color.new(#00c853, 0), textcolor=color.new(#00c853, 0), size=size.normal, title="Build-UP Buy Diverged")
plotchar(showMainLabels and sellHot and htfEmaDiverged, char="", location=location.abovebar, text="▽", color=color.new(#d50000, 0), textcolor=color.new(#d50000, 0), size=size.normal, title="Build-UP Sell Diverged")

// ============================================================
// STATUS BOARD (フェーズ対応の色変化)
// ============================================================

var table board = table.new(position.top_right, 3, 36, bgcolor=color.new(#111827, 8), frame_color=color.new(#ffffff, 65), frame_width=1, border_color=color.new(#ffffff, 80), border_width=1)

f_mark(_cond) => _cond ? "○" : "×"
f_markColor(_cond) => _cond ? color.new(#69f0ae, 0) : color.new(#78909c, 0)

// フェーズ対応のスコア色: スコアが上がるほど色が暖色に変化
f_buildScoreColor(_score, _min) =>
    ratio = _min > 0 ? _score / _min : 0.0
    ratio >= 1.3 ? color.new(#ff6d00, 0) : ratio >= 1.0 ? color.new(#ffd740, 0) : ratio >= 0.7 ? color.new(#fff176, 0) : ratio >= 0.4 ? color.new(#b0bec5, 0) : color.new(#546e7a, 0)

// 方向スコア色: 閾値との距離で色変化
f_dirScoreColor(_score, _min) =>
    _score >= _min + 1.0 ? color.new(#00e676, 0) : _score >= _min ? color.new(#69f0ae, 0) : _score >= _min - 1.0 ? color.new(#fff176, 0) : color.new(#78909c, 0)

f_section(_row, _title, _scoreText, _color) =>
    table.cell(board, 0, _row, _title, text_color=color.white, text_size=size.small, bgcolor=color.new(#0d47a1, 15))
    table.cell(board, 1, _row, _scoreText, text_color=_color, text_size=size.small, bgcolor=color.new(#0d47a1, 15))
    table.cell(board, 2, _row, "", bgcolor=color.new(#0d47a1, 15))

f_item(_row, _name, _cond, _memo) =>
    table.cell(board, 0, _row, _name, text_color=color.new(#cfd8dc, 0), text_size=size.tiny)
    table.cell(board, 1, _row, f_mark(_cond), text_color=f_markColor(_cond), text_size=size.tiny)
    table.cell(board, 2, _row, _memo, text_color=color.new(#b0bec5, 0), text_size=size.tiny)

f_itemFloat(_row, _name, _val, _thresh, _memo) =>
    ok = _val >= _thresh
    table.cell(board, 0, _row, _name, text_color=color.new(#cfd8dc, 0), text_size=size.tiny)
    table.cell(board, 1, _row, str.tostring(_val, "#.##"), text_color=ok ? color.new(#69f0ae, 0) : color.new(#78909c, 0), text_size=size.tiny)
    table.cell(board, 2, _row, _memo, text_color=color.new(#b0bec5, 0), text_size=size.tiny)

buildScoreColor = f_buildScoreColor(buildScoreFloat, buildScoreMinFloat)
buyDirColor = f_dirScoreColor(buyScore, directionScoreMin)
sellDirColor = f_dirScoreColor(sellScore, directionScoreMin)

phaseText = phase == 4 ? (buyHot ? "臨界↑" : "臨界↓") : phase == 3 ? "成熟" : phase == 2 ? "圧縮進行" : phase == 1 ? "形成初期" : "待機"
phaseColor = phase == 4 ? (buyHot ? color.new(#00e676, 0) : color.new(#ff5252, 0)) : phase == 3 ? color.new(#ff6d00, 0) : phase == 2 ? color.new(#ffd740, 0) : phase == 1 ? color.new(#fff176, 0) : color.new(#546e7a, 0)

marketText = isRange ? rangeUpperZone ? "レンジ上限" : rangeLowerZone ? "レンジ下限" : "レンジ中央" : "トレンド/通常"
marketColor = isRange ? rangeUpperZone or rangeLowerZone ? color.new(#ffd740, 0) : color.new(#ff9800, 0) : color.new(#69f0ae, 0)

nearText = breakNearBuy ? "高値付近" : breakNearSell ? "安値付近" : emaNearCluster ? "EMA付近" : barrierNearAny ? "ライン付近" : "なし"
nearColor = breakNearBuy or breakNearSell ? color.new(#ffd740, 0) : emaNearCluster or barrierNearAny ? color.new(#69f0ae, 0) : color.new(#90a4ae, 0)

sessText = not useSessionFilter ? "OFF" : inOverlap ? "重複" : inLondon ? "ロンドン" : inNY ? "NY" : "対象外"
sessColor = not useSessionFilter ? color.new(#90a4ae, 0) : inActiveSession ? color.new(#69f0ae, 0) : color.new(#ff5252, 0)

overlapText = str.tostring(avgOverlap, "#.##")
overlapColor = avgOverlap >= overlapThreshold ? color.new(#69f0ae, 0) : avgOverlap >= overlapThreshold * 0.7 ? color.new(#fff176, 0) : color.new(#78909c, 0)

noiseText = noiseQualityGood ? "良好" : "注意"
noiseColor = noiseQualityGood ? color.new(#69f0ae, 0) : color.new(#ff9800, 0)

if barstate.islast and showBoard
    table.clear(board, 0, 0, 2, 35)
    table.cell(board, 0, 0, "BV Build-up v2", text_color=color.white, text_size=size.small, bgcolor=color.new(#263238, 0))
    table.cell(board, 1, 0, "状態", text_color=color.white, text_size=size.small, bgcolor=color.new(#263238, 0))
    table.cell(board, 2, 0, "詳細", text_color=color.white, text_size=size.small, bgcolor=color.new(#263238, 0))

    f_section(1, "ビルドアップ", str.tostring(buildScoreFloat, "#.#") + "/7.0", buildScoreColor)
    f_section(2, "フェーズ", phaseText, phaseColor)
    f_section(3, "重なり率", overlapText, overlapColor)
    f_section(4, "ノイズ耐性", noiseText, noiseColor)
    f_section(5, "相場状態", marketText, marketColor)
    f_section(6, "買い方向", str.tostring(buyScore, "#.#") + "/6.0", buyDirColor)
    f_section(7, "売り方向", str.tostring(sellScore, "#.#") + "/6.0", sellDirColor)
    f_section(8, "接近", nearText, nearColor)
    f_section(9, "時間帯", sessText, sessColor)

    if showDetailBoard
        f_section(11, "ビルドアップ内訳", "", buildScoreColor)
        f_item(12, "値幅縮小 (1.0)", scoreNarrow, "狭い")
        f_itemFloat(13, "重なり率 (1.5)", avgOverlap, overlapThreshold, "≥" + str.tostring(overlapThreshold, "#.##"))
        f_item(14, "小さい足 (1.0)", scoreSmallBars, "多い")
        f_item(15, "EMA付近 (1.0)", scoreEMA, "近い")
        f_item(16, "段階的収束 (1.5)", scoreCompression, scoreCompressionWeak ? "弱圧縮" : "強圧縮")
        f_item(17, "ライン付近 (0.5)", scoreBarrier, "近い")
        f_item(18, "ノイズ耐性 (0.5)", scoreNoise, "ヒゲ" + str.tostring(wickNoiseCount) + " 実体" + str.tostring(hardNoiseCount))

        f_section(20, "買い方向内訳", str.tostring(buyScore, "#.#") + "/6.0", buyDirColor)
        f_item(21, "EMA上向き (1.5)", buyScoreTrend, "上/横")
        f_item(22, "EMA上/付近 (1.0)", buyScoreEMA, "近い")
        f_item(23, "安値切上げ (1.5)", buyScoreCompression, "あり")
        f_item(24, "上側維持 (1.0)", buyScoreClosePos, "終値")
        f_item(25, "下ヒゲ支え (0.5)", buyScoreWickSupport, "支え")
        f_item(26, "上方向余地 (0.5)", buyScoreBarrier and buyScoreWeakOpp, "余地")

        f_section(28, "売り方向内訳", str.tostring(sellScore, "#.#") + "/6.0", sellDirColor)
        f_item(29, "EMA下向き (1.5)", sellScoreTrend, "下/横")
        f_item(30, "EMA下/付近 (1.0)", sellScoreEMA, "近い")
        f_item(31, "高値切下げ (1.5)", sellScoreCompression, "あり")
        f_item(32, "下側維持 (1.0)", sellScoreClosePos, "終値")
        f_item(33, "上ヒゲ抵抗 (0.5)", sellScoreWickResistance, "抵抗")
        f_item(34, "下方向余地 (0.5)", sellScoreBarrier and sellScoreWeakOpp, "余地")

// ============================================================
// ALERTS
// ============================================================

alertcondition(alertOnWatch and newBuildUp, title="ビルドアップ監視", message="【Build-up v2】ビルドアップ監視：価格圧縮を検知")
alertcondition(buyHot, title="Build-UP↑", message="【Build-up v2】Build-UP↑：買い方向ビルドアップ")
alertcondition(sellHot, title="Build-UP↓", message="【Build-up v2】Build-UP↓：売り方向ビルドアップ")
alertcondition(buyHot or sellHot, title="ビルドアップ直前", message="【Build-up v2】ビルドアップ直前シグナル発生")
alertcondition(phase >= 2 and phase[1] < 2, title="圧縮進行開始", message="【Build-up v2】圧縮進行フェーズに移行")
````
