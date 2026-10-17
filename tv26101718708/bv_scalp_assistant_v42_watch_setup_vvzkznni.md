# BV Scalp Assistant v4.2 Watch Setup

- url: https://www.tradingview.com/script/VVzKZNNi/
- type: indicator
- pine_id: PUB;06082b70e0674de88e61cb94923e4477
- version: 2.0

## Description

BV Scalp Assistant v4.2

【日本語】
ボブ・ボルマンの「Build-up（圧縮）」概念をベースにしたスキャルピング補助インジケーターです。
EMA、Build-up、パワーバー、失敗ブレイク、Triple Test、キリ番、スイングラインなどを組み合わせ、ブレイク前の“溜め”やエントリーチャンスを視覚化します。

WATCH → SETUP → GO の3段階構成で、
「圧縮形成 → ブレイク準備 → エントリー」
の流れを分かりやすく表示します。

主にロンドン〜NY時間の短期トレード向け。
5分足推奨

【English】
A scalping assistant indicator inspired by Bob Volman’s “Build-up” concept.
It combines EMA, Build-up detection, Power Bars, Failed Breaks, Triple Tests, Round Numbers, and Swing Levels to visualize compression phases and breakout opportunities before entry.

The indicator uses a 3-step structure:

WATCH → SETUP → GO

to help identify:
“compression → breakout preparation → entry trigger”.

Designed mainly for short-term trading during the London and New York sessions.

## Source Code

````pine
//@version=5
indicator("BV Scalp Assistant v4.5 Clean Labels", shorttitle="BV v4.5", overlay=true, max_lines_count=300, max_labels_count=150, max_boxes_count=50)

// ============================================================
// INPUT PARAMETERS
// ============================================================

grp_ema = "▼ EMA"
emaLen = input.int(25, "EMA Length", group=grp_ema)
emaColUp = input.color(color.new(#00bcd4, 0), "上昇色", group=grp_ema)
emaColDn = input.color(color.new(#ff5252, 0), "下降色", group=grp_ema)
emaDivLight = input.float(0.8, "乖離警告（ATR倍率）軽度", minval=0.1, step=0.1, group=grp_ema)
emaDivHeavy = input.float(1.4, "乖離警告（ATR倍率）強度", minval=0.1, step=0.1, group=grp_ema)
emaDivStrong = input.float(0.6, "Strong用EMA乖離（ATR倍率）", minval=0.1, step=0.1, group=grp_ema)
emaSlopeMult = input.float(0.015, "EMA傾き判定（ATR倍率）", minval=0.001, step=0.001, group=grp_ema)

grp_round = "▼ キリ番"
roundPips = input.int(50, "キリ番間隔（pips）", minval=10, maxval=200, group=grp_round)
showRounds = input.bool(true, "キリ番表示", group=grp_round)

grp_swing = "▼ スイングライン"
swingLen = input.int(10, "スイング検出期間", minval=3, maxval=50, group=grp_swing)
showSwings = input.bool(true, "スイング表示", group=grp_swing)

grp_pattern = "▼ パターン判定"
powerMult = input.float(1.8, "パワーバー（ATR倍率）", minval=1.0, maxval=5.0, group=grp_pattern)
powerBodyR = input.float(0.6, "パワーバー実体比率", minval=0.3, maxval=1.0, group=grp_pattern)
clusterBars = input.int(4, "ビルドアップ判定足数", minval=3, maxval=12, group=grp_pattern)
clusterMult = input.float(0.65, "収縮幅（ATR倍率）", minval=0.1, maxval=2.0, group=grp_pattern)
wickNoiseMax = input.float(0.55, "ヒゲ許容率", minval=0.1, maxval=0.9, step=0.05, group=grp_pattern)
showIBBg = input.bool(false, "はらみ足背景", group=grp_pattern)
showBuildBg = input.bool(true, "Build-up背景", group=grp_pattern)

grp_watch = "▼ Watch / Setup"
showWatchSignal = input.bool(true, "WATCH表示", group=grp_watch)
showSetupSignal = input.bool(true, "SETUP表示", group=grp_watch)
watchRecentBars = input.int(5, "EMA横向き化の有効本数", minval=1, maxval=20, group=grp_watch)
useContracting = input.bool(true, "前より値幅縮小を要求", group=grp_watch)
useCenterCompress = input.bool(true, "中心収束を要求", group=grp_watch)

grp_session = "▼ セッション（JST）"
showSession = input.bool(false, "セッション表示", group=grp_session)
jstLondonS = input.int(16, "ロンドン開始（JST）", minval=0, maxval=23, group=grp_session)
jstLondonE = input.int(25, "ロンドン終了（JST）※25=翌1時", minval=0, maxval=30, group=grp_session)
jstNYS = input.int(21, "NY開始（JST）", minval=0, maxval=30, group=grp_session)
jstNYE = input.int(27, "NY終了（JST）※27=翌3時", minval=0, maxval=30, group=grp_session)

grp_trade = "▼ トレード判定"
useFailBreak = input.bool(true, "失敗ブレイクをトリガーに含める", group=grp_trade)
tpPips = input.int(20, "TP目安（pips）", minval=5, maxval=100, group=grp_trade)
liteMinPips = input.int(10, "Lite最低余地（pips）", minval=3, maxval=50, group=grp_trade)

grp_rr = "▼ TP / SL / RR"
showRiskBox = input.bool(true, "TP/SLボックス表示", group=grp_rr)
riskBoxBars = input.int(30, "ボックス右方向の長さ", minval=5, maxval=100, group=grp_rr)
slPips = input.int(10, "SL pips", minval=3, maxval=100, group=grp_rr)
rrTpPips = input.int(20, "TP pips", minval=5, maxval=200, group=grp_rr)
showRRLabel = input.bool(true, "RRラベル表示", group=grp_rr)
showObstacleTP = input.bool(true, "途中利確候補表示", group=grp_rr)
obstacleBufferPips = input.int(2, "障害物手前pips", minval=0, maxval=20, group=grp_rr)

grp_exit = "▼ Exit Management"
showExitSignals = input.bool(true, "決済注意マーク表示", group=grp_exit)
breakevenBars = input.int(6, "建値逃げ判定本数", minval=2, maxval=20, group=grp_exit)
breakevenBufferPips = input.int(3, "建値付近許容(pips)", minval=1, maxval=10, group=grp_exit)
breakevenMaxProfitRate = input.float(0.35, "伸びない判定：TP到達率", minval=0.1, maxval=0.8, step=0.05, group=grp_exit)
reversalClusterBars = input.int(4, "反転クラスター本数", minval=3, maxval=10, group=grp_exit)
reversalClusterATR = input.float(0.45, "反転クラスターATR倍率", minval=0.1, maxval=1.0, step=0.05, group=grp_exit)
reversalPressureRate = input.float(0.6, "反転圧力比率", minval=0.5, maxval=1.0, step=0.05, group=grp_exit)

grp_tt = "▼ Triple Test"
showTripleTest = input.bool(true, "Triple Test判定を使う", group=grp_tt)
ttTolerancePips = input.int(5, "Triple Test許容幅(pips)", minval=1, maxval=20, group=grp_tt)
ttReactionPips = input.int(3, "反応確認幅(pips)", minval=1, maxval=10, group=grp_tt)
ttRequireBuildUp = input.bool(true, "TT強にBuild-upを要求", group=grp_tt)

grp_info = "▼ 表示"
showStatusBox = input.bool(true, "右上ステータス表示", group=grp_info)
showSkipInfo = input.bool(true, "見送り理由表示", group=grp_info)

// ============================================================
// CORE
// ============================================================

atrVal = ta.atr(14)
emaVal = ta.ema(close, emaLen)
emaSlope = emaVal - emaVal[3]

isJPY = syminfo.currency == "JPY" or syminfo.basecurrency == "JPY"
pipSize = isJPY ? 0.01 : 0.0001

roundStep = roundPips * pipSize
ttTol = ttTolerancePips * pipSize
ttReact = ttReactionPips * pipSize

emaBull = emaSlope > 0
emaBear = emaSlope < 0
emaColor = emaBull ? emaColUp : emaColDn
plot(emaVal, "25 EMA", color=emaColor, linewidth=2)

// ============================================================
// SESSION
// ============================================================

jstHour = hour(time, "Asia/Tokyo")

f_inSession(_start, _end) =>
    _end <= 24 ? (jstHour >= _start and jstHour < _end) : (jstHour >= _start or jstHour < (_end - 24))

inLondon = f_inSession(jstLondonS, jstLondonE)
inNY = f_inSession(jstNYS, jstNYE)
inOverlap = inLondon and inNY
inActive = inLondon or inNY

sessionBg = inOverlap ? color.new(#1a237e, 88) : inLondon ? color.new(#1565c0, 93) : inNY ? color.new(#004d40, 93) : na
bgcolor(showSession ? sessionBg : na, title="セッション")

// ============================================================
// ROUND NUMBER
// ============================================================

roundBase = math.floor(close / roundStep) * roundStep

isDouble(lvl) =>
    remainder = math.round(math.abs(lvl / pipSize) % 100)
    remainder == 0

var line[] rLines = array.new_line()

if barstate.islast and showRounds
    while array.size(rLines) > 0
        line.delete(array.pop(rLines))
    for i = -2 to 2
        lvl = roundBase + i * roundStep
        w = isDouble(lvl) ? 2 : 1
        st = isDouble(lvl) ? line.style_solid : line.style_dashed
        ln = line.new(bar_index - 30, lvl, bar_index + 8, lvl, color=color.new(#ffeb3b, 50), style=st, width=w)
        array.push(rLines, ln)

// ============================================================
// SWING LINES
// ============================================================

swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow = ta.pivotlow(low, swingLen, swingLen)

var float lastH1 = na
var float lastH2 = na
var float lastL1 = na
var float lastL2 = na

if not na(swingHigh)
    if na(lastH1) or swingHigh != lastH1
        lastH2 := lastH1
        lastH1 := swingHigh

if not na(swingLow)
    if na(lastL1) or swingLow != lastL1
        lastL2 := lastL1
        lastL1 := swingLow

var line swHL1 = na
var line swHL2 = na
var line swLL1 = na
var line swLL2 = na

if barstate.islast and showSwings
    if not na(swHL1)
        line.delete(swHL1)
    if not na(swHL2)
        line.delete(swHL2)
    if not na(swLL1)
        line.delete(swLL1)
    if not na(swLL2)
        line.delete(swLL2)
    if not na(lastH1)
        swHL1 := line.new(bar_index - 40, lastH1, bar_index + 8, lastH1, color=color.new(#ef5350, 20), style=line.style_solid, width=1)
    if not na(lastH2)
        swHL2 := line.new(bar_index - 40, lastH2, bar_index + 8, lastH2, color=color.new(#ef5350, 55), style=line.style_dotted, width=1)
    if not na(lastL1)
        swLL1 := line.new(bar_index - 40, lastL1, bar_index + 8, lastL1, color=color.new(#26a69a, 20), style=line.style_solid, width=1)
    if not na(lastL2)
        swLL2 := line.new(bar_index - 40, lastL2, bar_index + 8, lastL2, color=color.new(#26a69a, 55), style=line.style_dotted, width=1)

// ============================================================
// INSIDE BAR / POWER BAR
// ============================================================

isInsideBar = high <= high[1] and low >= low[1]
bgcolor(showIBBg and isInsideBar ? color.new(#9c27b0, 84) : na, title="はらみ足")

barSize = high - low
bodySize = math.abs(close - open)
isBull = close > open
isBear = close < open

bodyRatio = barSize > 0 ? bodySize / barSize : 0.0
closeNearTop = barSize > 0 ? (high - close) / barSize < 0.25 : false
closeNearBot = barSize > 0 ? (close - low) / barSize < 0.25 : false

isPowerBull = barSize > atrVal * powerMult and bodyRatio >= powerBodyR and isBull and closeNearTop and emaBull
isPowerBear = barSize > atrVal * powerMult and bodyRatio >= powerBodyR and isBear and closeNearBot and emaBear

// ============================================================
// BUILD-UP
// ============================================================

cHigh = ta.highest(high, clusterBars)
cLow = ta.lowest(low, clusterBars)
cRange = cHigh - cLow
isTight = cRange < atrVal * clusterMult

rangePast = ta.highest(high, clusterBars)[clusterBars] - ta.lowest(low, clusterBars)[clusterBars]
isContracting = not na(rangePast) ? cRange < rangePast : false

bodyHigh = math.max(open, close)
bodyLow = math.min(open, close)
bodyRange = ta.highest(bodyHigh, clusterBars) - ta.lowest(bodyLow, clusterBars)
wickNoiseRatio = cRange > 0 ? (cRange - bodyRange) / cRange : 0.0
wickNoiseOK = wickNoiseRatio <= wickNoiseMax

rangeMid = (cHigh + cLow) / 2.0
distNowCenter = math.abs(close - rangeMid)
distPastCenter = math.abs(close[clusterBars - 1] - rangeMid)
isCompressingToCenter = not na(distPastCenter) ? distNowCenter <= distPastCenter : false

lowTrendUp = ta.linreg(low, clusterBars, 0) > ta.linreg(low, clusterBars, 1)
highTrendDn = ta.linreg(high, clusterBars, 0) < ta.linreg(high, clusterBars, 1)

emaDistNow = math.abs(close - emaVal)
emaDistPast = math.abs(close[clusterBars - 1] - emaVal[clusterBars - 1])
emaCompress = emaDistNow <= emaDistPast

buildCore = isTight and wickNoiseOK and (not useContracting or isContracting) and (not useCenterCompress or isCompressingToCenter)

bullBuildWeak = buildCore and close >= emaVal
bearBuildWeak = buildCore and close <= emaVal
bullBuildStrong = bullBuildWeak and lowTrendUp and emaCompress
bearBuildStrong = bearBuildWeak and highTrendDn and emaCompress

buildStrong = bullBuildStrong or bearBuildStrong
buildWeak = (bullBuildWeak or bearBuildWeak) and not buildStrong

bgcolor(showBuildBg and buildWeak ? color.new(#ffb300, 86) : na, title="Build-up弱")
bgcolor(showBuildBg and bullBuildStrong ? color.new(#00c853, 80) : na, title="Build-up強（買い）")
bgcolor(showBuildBg and bearBuildStrong ? color.new(#d50000, 80) : na, title="Build-up強（売り）")

// ============================================================
// WATCH / SETUP
// ============================================================

emaDist = math.abs(close - emaVal)
emaDistOK = emaDist < atrVal * emaDivLight
emaDistBad = emaDist >= atrVal * emaDivHeavy
emaDistStrongOK = emaDist < atrVal * emaDivStrong
emaAngled = math.abs(emaSlope) > atrVal * emaSlopeMult
emaFlatNow = math.abs(emaSlope) <= atrVal * emaSlopeMult

trendBull = emaSlope > atrVal * emaSlopeMult
trendBear = emaSlope < -(atrVal * emaSlopeMult)

emaWasBear = emaSlope[3] < -(atrVal[3] * emaSlopeMult)
emaWasBull = emaSlope[3] > atrVal[3] * emaSlopeMult

bearToFlat = emaWasBear and emaFlatNow
bullToFlat = emaWasBull and emaFlatNow

barsBearToFlat = ta.barssince(bearToFlat)
barsBullToFlat = ta.barssince(bullToFlat)

bearToFlatRecent = not na(barsBearToFlat) and barsBearToFlat <= watchRecentBars
bullToFlatRecent = not na(barsBullToFlat) and barsBullToFlat <= watchRecentBars

nearEMA = emaDistOK

buyWatch = inActive and bearToFlatRecent and nearEMA and buildCore
sellWatch = inActive and bullToFlatRecent and nearEMA and buildCore

buySetup = inActive and nearEMA and bullBuildWeak and not trendBear
sellSetup = inActive and nearEMA and bearBuildWeak and not trendBull

plotshape(showWatchSignal and buyWatch, style=shape.labelup, location=location.belowbar, color=color.new(#1976d2, 0), textcolor=color.white, text="WATCH BUY", size=size.tiny, title="WATCH BUY")
plotshape(showWatchSignal and sellWatch, style=shape.labeldown, location=location.abovebar, color=color.new(#7b1fa2, 0), textcolor=color.white, text="WATCH SELL", size=size.tiny, title="WATCH SELL")

plotshape(showSetupSignal and buySetup and not buyWatch, style=shape.labelup, location=location.belowbar, color=color.new(#29b6f6, 0), textcolor=color.white, text="SETUP BUY", size=size.tiny, title="SETUP BUY")
plotshape(showSetupSignal and sellSetup and not sellWatch, style=shape.labeldown, location=location.abovebar, color=color.new(#ec407a, 0), textcolor=color.white, text="SETUP SELL", size=size.tiny, title="SETUP SELL")

// ============================================================
// FAILED BREAK / OBSTACLE
// ============================================================

failBreakBear = not na(lastH1) and high[1] > lastH1 and close < lastH1 and isBear
failBreakBull = not na(lastL1) and low[1] < lastL1 and close > lastL1 and isBull

upperRound = math.ceil(close / roundStep) * roundStep
lowerRound = math.floor(close / roundStep) * roundStep

distUpRoundPips = math.round((upperRound - close) / pipSize)
distDownRoundPips = math.round((close - lowerRound) / pipSize)

distToH1 = not na(lastH1) and lastH1 > close ? math.round((lastH1 - close) / pipSize) : 100000
distToH2 = not na(lastH2) and lastH2 > close ? math.round((lastH2 - close) / pipSize) : 100000
distToL1 = not na(lastL1) and lastL1 < close ? math.round((close - lastL1) / pipSize) : 100000
distToL2 = not na(lastL2) and lastL2 < close ? math.round((close - lastL2) / pipSize) : 100000

nearestUpObstaclePips = math.min(distUpRoundPips, math.min(distToH1, distToH2))
nearestDownObstaclePips = math.min(distDownRoundPips, math.min(distToL1, distToL2))

obstacleLongStrongOK = nearestUpObstaclePips >= tpPips
obstacleShortStrongOK = nearestDownObstaclePips >= tpPips
obstacleLongLiteOK = nearestUpObstaclePips >= liteMinPips
obstacleShortLiteOK = nearestDownObstaclePips >= liteMinPips

// ============================================================
// SIGNAL LABELS
// ============================================================

plotshape(isPowerBull, style=shape.labelup, location=location.belowbar, color=color.new(#00c853, 0), textcolor=color.white, text="PB BUY", size=size.tiny, title="PB BUY")
plotshape(isPowerBear, style=shape.labeldown, location=location.abovebar, color=color.new(#d50000, 0), textcolor=color.white, text="PB SELL", size=size.tiny, title="PB SELL")

// ============================================================
// READY / TRIGGER
// ============================================================

baseLongReady = inActive and emaDistOK and emaAngled and close > emaVal and trendBull
baseShortReady = inActive and emaDistOK and emaAngled and close < emaVal and trendBear

baseLongReadyStrong = inActive and emaDistStrongOK and emaAngled and close > emaVal and trendBull
baseShortReadyStrong = inActive and emaDistStrongOK and emaAngled and close < emaVal and trendBear

longTriggerCore = isPowerBull or (useFailBreak and failBreakBull)
shortTriggerCore = isPowerBear or (useFailBreak and failBreakBear)

triggerLongStrong = baseLongReadyStrong and bullBuildStrong and obstacleLongStrongOK and longTriggerCore
triggerShortStrong = baseShortReadyStrong and bearBuildStrong and obstacleShortStrongOK and shortTriggerCore

triggerLongLite = baseLongReady and (bullBuildWeak or bullBuildStrong) and obstacleLongLiteOK and longTriggerCore and not triggerLongStrong
triggerShortLite = baseShortReady and (bearBuildWeak or bearBuildStrong) and obstacleShortLiteOK and shortTriggerCore and not triggerShortStrong

// ============================================================
// TRIPLE TEST
// ============================================================

buyLine = not na(lastL1) and lastL1 < close and not na(lastL2) and lastL2 < close ? (math.abs(close - lastL1) <= math.abs(close - lastL2) ? lastL1 : lastL2) : not na(lastL1) and lastL1 < close ? lastL1 : not na(lastL2) and lastL2 < close ? lastL2 : na
sellLine = not na(lastH1) and lastH1 > close and not na(lastH2) and lastH2 > close ? (math.abs(close - lastH1) <= math.abs(close - lastH2) ? lastH1 : lastH2) : not na(lastH1) and lastH1 > close ? lastH1 : not na(lastH2) and lastH2 > close ? lastH2 : na

roundBelow = math.floor(close / roundStep) * roundStep
roundAbove = math.ceil(close / roundStep) * roundStep

tripleBuyZone = not na(buyLine) and math.abs(emaVal - buyLine) <= ttTol and math.abs(emaVal - roundBelow) <= ttTol and math.abs(buyLine - roundBelow) <= ttTol
tripleSellZone = not na(sellLine) and math.abs(emaVal - sellLine) <= ttTol and math.abs(emaVal - roundAbove) <= ttTol and math.abs(sellLine - roundAbove) <= ttTol

buyTripleCenter = not na(buyLine) ? (emaVal + buyLine + roundBelow) / 3.0 : na
sellTripleCenter = not na(sellLine) ? (emaVal + sellLine + roundAbove) / 3.0 : na

buyTested = tripleBuyZone and not na(buyTripleCenter) and low <= buyTripleCenter + ttTol and close > buyTripleCenter - ttReact
sellTested = tripleSellZone and not na(sellTripleCenter) and high >= sellTripleCenter - ttTol and close < sellTripleCenter + ttReact

lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)

buyWickReversal = barSize > 0 ? lowerWick / barSize > 0.4 : false
sellWickReversal = barSize > 0 ? upperWick / barSize > 0.4 : false

buyReversal = close > open or buyWickReversal or isPowerBull or failBreakBull
sellReversal = close < open or sellWickReversal or isPowerBear or failBreakBear

ttBuildOKBuy = not ttRequireBuildUp or bullBuildStrong or bullBuildWeak
ttBuildOKSell = not ttRequireBuildUp or bearBuildStrong or bearBuildWeak

tripleBuyStrong = showTripleTest and tripleBuyZone and buyTested and buyReversal and trendBull and inActive and obstacleLongLiteOK and ttBuildOKBuy
tripleSellStrong = showTripleTest and tripleSellZone and sellTested and sellReversal and trendBear and inActive and obstacleShortLiteOK and ttBuildOKSell

// ============================================================
// ENTRY FLAGS / CLEAN GO LABELS
// ============================================================

entryLong = triggerLongStrong or triggerLongLite or tripleBuyStrong
entryShort = triggerShortStrong or triggerShortLite or tripleSellStrong

mainEntryLong = triggerLongStrong or tripleBuyStrong
mainEntryShort = triggerShortStrong or tripleSellStrong

entryAnyMain = mainEntryLong or mainEntryShort
entryAnyAll = entryLong or entryShort

watchAny = buyWatch or sellWatch
setupAny = buySetup or sellSetup
preEntryAny = watchAny or setupAny

newEntry = entryAnyAll and not entryAnyAll[1]

plotshape(newEntry and entryLong, style=shape.labelup, location=location.belowbar, color=color.new(#00c853, 0), textcolor=color.white, text="BUY GO", size=size.small, title="BUY GO")
plotshape(newEntry and entryShort, style=shape.labeldown, location=location.abovebar, color=color.new(#d50000, 0), textcolor=color.white, text="SELL GO", size=size.small, title="SELL GO")

// ============================================================
// TP / SL / RR BOX
// ============================================================

var box tpBox = na
var box slBox = na
var label rrLabel = na
var line entryLine = na
var line tpLine = na
var line slLine = na
var label obstacleLabel = na

var bool tradeActive = false
var bool tradeLong = false
var float activeEntry = na
var float activeTP = na
var float activeSL = na
var float activeObstacleTP = na
var int activeEntryBar = na

if newEntry
    tradeLong := entryLong
    activeEntry := close
    activeTP := tradeLong ? activeEntry + rrTpPips * pipSize : activeEntry - rrTpPips * pipSize
    activeSL := tradeLong ? activeEntry - slPips * pipSize : activeEntry + slPips * pipSize
    activeEntryBar := bar_index

    float obstaclePrice = na
    float nearestObstaclePips = tradeLong ? nearestUpObstaclePips : nearestDownObstaclePips

    if tradeLong
        obstaclePrice := nearestObstaclePips < rrTpPips ? activeEntry + math.max(nearestObstaclePips - obstacleBufferPips, 1) * pipSize : na
    else
        obstaclePrice := nearestObstaclePips < rrTpPips ? activeEntry - math.max(nearestObstaclePips - obstacleBufferPips, 1) * pipSize : na

    activeObstacleTP := obstaclePrice
    tradeActive := true

    if not na(tpBox)
        box.delete(tpBox)
    if not na(slBox)
        box.delete(slBox)
    if not na(rrLabel)
        label.delete(rrLabel)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(tpLine)
        line.delete(tpLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(obstacleLabel)
        label.delete(obstacleLabel)

    if showRiskBox
        tpTop = tradeLong ? activeTP : activeEntry
        tpBot = tradeLong ? activeEntry : activeTP
        slTop = tradeLong ? activeEntry : activeSL
        slBot = tradeLong ? activeSL : activeEntry

        tpBox := box.new(bar_index, tpTop, bar_index + riskBoxBars, tpBot, bgcolor=color.new(#00c853, 82), border_color=color.new(#00c853, 35))
        slBox := box.new(bar_index, slTop, bar_index + riskBoxBars, slBot, bgcolor=color.new(#d50000, 82), border_color=color.new(#d50000, 35))

        entryLine := line.new(bar_index, activeEntry, bar_index + riskBoxBars, activeEntry, color=color.new(color.white, 20), style=line.style_dotted)
        tpLine := line.new(bar_index, activeTP, bar_index + riskBoxBars, activeTP, color=color.new(#00e676, 0), style=line.style_solid)
        slLine := line.new(bar_index, activeSL, bar_index + riskBoxBars, activeSL, color=color.new(#ff1744, 0), style=line.style_solid)

        rr = rrTpPips / slPips
        txt = (tradeLong ? "LONG" : "SHORT") + "\nTP +" + str.tostring(rrTpPips) + "p\nSL -" + str.tostring(slPips) + "p\nRR 1:" + str.tostring(rr, "#.##")

        if showRRLabel
            rrLabel := label.new(bar_index + riskBoxBars, activeEntry, txt, style=label.style_label_left, textcolor=color.white, color=color.new(#263238, 0), size=size.small)

        if showObstacleTP and not na(activeObstacleTP)
            obstacleLabel := label.new(bar_index + riskBoxBars, activeObstacleTP, "TP CAUTION", style=label.style_label_left, textcolor=color.white, color=color.new(#ff9800, 0), size=size.small)

if tradeActive and showRiskBox
    if not na(tpBox)
        box.set_right(tpBox, bar_index + riskBoxBars)
    if not na(slBox)
        box.set_right(slBox, bar_index + riskBoxBars)
    if not na(entryLine)
        line.set_x2(entryLine, bar_index + riskBoxBars)
    if not na(tpLine)
        line.set_x2(tpLine, bar_index + riskBoxBars)
    if not na(slLine)
        line.set_x2(slLine, bar_index + riskBoxBars)
    if not na(rrLabel)
        label.set_x(rrLabel, bar_index + riskBoxBars)
    if not na(obstacleLabel)
        label.set_x(obstacleLabel, bar_index + riskBoxBars)

// ============================================================
// EXIT MANAGEMENT
// ============================================================

tpHit = tradeActive and ((tradeLong and high >= activeTP) or (not tradeLong and low <= activeTP))
slHit = tradeActive and ((tradeLong and low <= activeSL) or (not tradeLong and high >= activeSL))

obstacleTPHit = tradeActive and not na(activeObstacleTP) and ((tradeLong and high >= activeObstacleTP) or (not tradeLong and low <= activeObstacleTP))

oppositePower = tradeActive and ((tradeLong and isPowerBear) or (not tradeLong and isPowerBull))
oppositeFailBreak = tradeActive and ((tradeLong and failBreakBear) or (not tradeLong and failBreakBull))
oppositeTT = tradeActive and ((tradeLong and tripleSellStrong) or (not tradeLong and tripleBuyStrong))

barsFromEntry = tradeActive and not na(activeEntryBar) ? bar_index - activeEntryBar : na

longNotMoving = tradeActive and tradeLong and not na(barsFromEntry) and barsFromEntry >= breakevenBars and high < activeEntry + (rrTpPips * breakevenMaxProfitRate) * pipSize and math.abs(close - activeEntry) <= breakevenBufferPips * pipSize
shortNotMoving = tradeActive and not tradeLong and not na(barsFromEntry) and barsFromEntry >= breakevenBars and low > activeEntry - (rrTpPips * breakevenMaxProfitRate) * pipSize and math.abs(close - activeEntry) <= breakevenBufferPips * pipSize

breakevenExit = longNotMoving or shortNotMoving

clusterRange = ta.highest(high, reversalClusterBars) - ta.lowest(low, reversalClusterBars)
smallReversalRange = clusterRange < atrVal * reversalClusterATR

bearCount = math.sum(close < open ? 1 : 0, reversalClusterBars)
bullCount = math.sum(close > open ? 1 : 0, reversalClusterBars)

bearPressure = bearCount >= reversalClusterBars * reversalPressureRate
bullPressure = bullCount >= reversalClusterBars * reversalPressureRate

reversalClusterLong = tradeActive and tradeLong and smallReversalRange and bearPressure
reversalClusterShort = tradeActive and not tradeLong and smallReversalRange and bullPressure
reversalCluster = reversalClusterLong or reversalClusterShort

exitCaution = tradeActive and (obstacleTPHit or oppositePower or oppositeFailBreak or oppositeTT or breakevenExit or reversalCluster)
reverseCaution = tradeActive and (oppositePower or oppositeFailBreak or oppositeTT or reversalCluster)

plotshape(showExitSignals and obstacleTPHit, style=shape.labeldown, location=location.abovebar, color=color.new(#ff9800, 0), textcolor=color.white, text="TP CAUTION", size=size.tiny, title="TP CAUTION")
plotshape(showExitSignals and breakevenExit, style=shape.labeldown, location=location.abovebar, color=color.new(#fbc02d, 0), textcolor=color.black, text="BE EXIT", size=size.tiny, title="BE EXIT")
plotshape(showExitSignals and reversalClusterLong, style=shape.labeldown, location=location.abovebar, color=color.new(#8e24aa, 0), textcolor=color.white, text="REV EXIT", size=size.tiny, title="REV EXIT Long")
plotshape(showExitSignals and reversalClusterShort, style=shape.labelup, location=location.belowbar, color=color.new(#8e24aa, 0), textcolor=color.white, text="REV EXIT", size=size.tiny, title="REV EXIT Short")

if tpHit or slHit
    tradeActive := false

// ============================================================
// SKIP REASON
// ============================================================

string skipReason = ""
if not inActive
    skipReason := "時間帯外"
else if emaDistBad
    skipReason := "EMA乖離大"
else if not emaDistOK
    skipReason := "EMA乖離中"
else if close > emaVal and not obstacleLongLiteOK
    skipReason := "上障害物近い"
else if close < emaVal and not obstacleShortLiteOK
    skipReason := "下障害物近い"
else if not buildCore
    skipReason := "BU不足"

// ============================================================
// STATUS BOX
// ============================================================

var table statusBox = table.new(position.top_right, 2, 12, bgcolor=color.new(#1a1a2e, 15), border_color=color.new(#ffffff, 70), border_width=1, frame_color=color.new(#ffffff, 60), frame_width=1)

if barstate.islast and showStatusBox
    table.cell(statusBox, 0, 0, "BV Scalp v4.5", text_color=color.white, text_size=size.small, bgcolor=color.new(#0d47a1, 20), text_halign=text.align_center)
    table.cell(statusBox, 1, 0, "", bgcolor=color.new(#0d47a1, 20))

    sessText = inOverlap ? "OVERLAP ◎" : inLondon ? "LONDON ○" : inNY ? "NY ○" : "DEAD ✕"
    sessColor = inOverlap ? color.new(#00e5ff, 0) : inActive ? color.new(#69f0ae, 0) : color.new(#ff5252, 0)
    table.cell(statusBox, 0, 1, "Session", text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(statusBox, 1, 1, sessText, text_color=sessColor, text_size=size.small)

    trendText = trendBull ? "BULL ↑" : trendBear ? "BEAR ↓" : "FLAT →"
    trendColor = trendBull ? color.new(#69f0ae, 0) : trendBear ? color.new(#ff5252, 0) : color.new(#ffd740, 0)
    table.cell(statusBox, 0, 2, "Trend", text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(statusBox, 1, 2, trendText, text_color=trendColor, text_size=size.small)

    emaText = emaDistBad ? "STRETCHED ✕" : not emaDistOK ? "WARNING △" : emaFlatNow ? "FLAT ○" : "GOOD ○"
    emaColor2 = emaDistBad ? color.new(#ff5252, 0) : not emaDistOK ? color.new(#ffd740, 0) : color.new(#69f0ae, 0)
    table.cell(statusBox, 0, 3, "EMA", text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(statusBox, 1, 3, emaText, text_color=emaColor2, text_size=size.small)

    buText = buildStrong ? "STRONG ◎" : buildWeak ? "WEAK △" : buildCore ? "CORE ○" : "NONE ✕"
    buColor = buildStrong ? color.new(#69f0ae, 0) : buildWeak ? color.new(#ffd740, 0) : buildCore ? color.new(#29b6f6, 0) : color.new(#ff5252, 0)
    table.cell(statusBox, 0, 4, "Build-up", text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(statusBox, 1, 4, buText, text_color=buColor, text_size=size.small)

    watchText = buyWatch ? "WATCH BUY" : sellWatch ? "WATCH SELL" : buySetup ? "SETUP BUY" : sellSetup ? "SETUP SELL" : "none"
    watchColor = buyWatch or buySetup ? color.new(#29b6f6, 0) : sellWatch or sellSetup ? color.new(#ab47bc, 0) : color.new(#78909c, 0)
    table.cell(statusBox, 0, 5, "Watch", text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(statusBox, 1, 5, watchText, text_color=watchColor, text_size=size.small)

    obsTextLong = "▲" + str.tostring(nearestUpObstaclePips) + "p"
    obsTextShort = "▼" + str.tostring(nearestDownObstaclePips) + "p"
    table.cell(statusBox, 0, 6, "Obstacle", text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(statusBox, 1, 6, obsTextLong + " " + obsTextShort, text_color=color.new(#eceff1, 0), text_size=size.small)

    tradeText = not tradeActive ? "none" : tradeLong ? "LONG active" : "SHORT active"
    tradeColor = not tradeActive ? color.new(#78909c, 0) : tradeLong ? color.new(#00e676, 0) : color.new(#ff1744, 0)
    table.cell(statusBox, 0, 7, "Trade", text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(statusBox, 1, 7, tradeText, text_color=tradeColor, text_size=size.small)

    exitText = breakevenExit ? "BE EXIT" : reversalCluster ? "REV EXIT" : obstacleTPHit ? "TP CAUTION" : exitCaution ? "EXIT注意" : "none"
    exitColor = exitCaution ? color.new(#ff9800, 0) : color.new(#78909c, 0)
    table.cell(statusBox, 0, 8, "Exit", text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(statusBox, 1, 8, exitText, text_color=exitColor, text_size=size.small)

    ttText = tripleBuyStrong ? "BUY strong" : tripleSellStrong ? "SELL strong" : tripleBuyZone ? "BUY zone" : tripleSellZone ? "SELL zone" : "none"
    ttColor = tripleBuyStrong ? color.new(#00e676, 0) : tripleSellStrong ? color.new(#ff1744, 0) : tripleBuyZone ? color.new(#81c784, 0) : tripleSellZone ? color.new(#e57373, 0) : color.new(#78909c, 0)
    table.cell(statusBox, 0, 9, "TT", text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(statusBox, 1, 9, ttText, text_color=ttColor, text_size=size.small)

    biasText = newEntry and entryLong ? "BUY GO" : newEntry and entryShort ? "SELL GO" : buyWatch ? "WATCH BUY" : sellWatch ? "WATCH SELL" : buySetup ? "SETUP BUY" : sellSetup ? "SETUP SELL" : "WAIT"
    biasColor = newEntry and entryLong ? color.new(#00e676, 0) : newEntry and entryShort ? color.new(#ff1744, 0) : buyWatch or buySetup ? color.new(#29b6f6, 0) : sellWatch or sellSetup ? color.new(#ab47bc, 0) : color.new(#78909c, 0)
    table.cell(statusBox, 0, 10, "Bias", text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(statusBox, 1, 10, biasText, text_color=biasColor, text_size=size.small)

    infoText = showSkipInfo and skipReason != "" ? skipReason : "ATR:" + str.tostring(atrVal, format.mintick)
    infoColor = skipReason != "" ? color.new(#ff8a65, 0) : color.new(#b0bec5, 0)
    table.cell(statusBox, 0, 11, "Info", text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(statusBox, 1, 11, infoText, text_color=infoColor, text_size=size.small)

// ============================================================
// ALERTS
// ============================================================

entryAlert = preEntryAny or entryAnyAll or entryAnyMain
exitAlert = tpHit or exitCaution

alertcondition(preEntryAny, title="① 準備通知 WATCH/SETUP", message="【BV v4.5】準備通知：WATCHまたはSETUP発生")
alertcondition(entryAnyAll, title="② エントリー候補", message="【BV v4.5】エントリー候補：BUY GO / SELL GO")
alertcondition(entryAnyMain, title="③ 本命エントリー", message="【BV v4.5】本命エントリー：Strong or TT強")
alertcondition(tpHit, title="④ TP到達", message="【BV v4.5】TP到達")
alertcondition(exitCaution, title="⑤ 手仕舞い注意", message="【BV v4.5】手仕舞い注意：TP CAUTION / BE EXIT / REV EXIT")

alertcondition(entryAlert, title="エントリー系まとめ", message="【BV v4.5】エントリー系：準備 / 候補 / 本命")
alertcondition(exitAlert, title="決済系まとめ", message="【BV v4.5】決済系：TP到達 / 手仕舞い注意")
````
