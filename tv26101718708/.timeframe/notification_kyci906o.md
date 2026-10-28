# Notification

- url: https://www.tradingview.com/script/kYcI906O/
- type: indicator
- pine_id: PUB;97b0d7b4b5394312be5f31b4766f4f2e
- version: 11.0

## Description

「お知らせ 」は、マルチタイムフレームで相場を確認し、分析すべきタイミングを知らせる裁量補助インジです。

4時間足と1時間足の20SMA、1時間足のフィボゾーン・FVG、15分足のプライスアクションや構造変化を組み合わせて、ロング候補・ショート候補を表示します。
このインジは売買を自動で決めるものではなく、
「今、分析する価値がある場面」を知らせるためのツールです。
最終判断は、上位足の流れ、サポート・レジスタンス、経済指標、リスク管理を含めて行ってください。


“Oshirase” is a discretionary trading support indicator that uses multi-timeframe analysis to notify you when the market may be worth analyzing.

It combines 4H and 1H 20 SMA conditions, 1H Fibonacci zones, FVG zones, and 15-minute price action / structure changes to display potential long and short opportunities.

This indicator does not automatically decide entries or exits.
It is designed to alert you to situations worth analyzing.
Final decisions should be made together with higher-timeframe context, support/resistance, news events, and proper risk management.

## Source Code

````pine
//@version=5
indicator("お知らせ", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

// =====================
// 入力
// =====================
tfH4 = input.timeframe("240", "環境認識足（4時間足）")
tfZone = input.timeframe("60", "中位足（ゾーン判定）")

h4MaLen = input.int(20, "4時間足SMA期間", minval=1)
h1MaLen = input.int(20, "1時間足SMA期間", minval=1)
h4SlopeBars = input.int(1, "4時間足SMAの向き判定本数", minval=1)
h1SlopeBars = input.int(1, "1時間足SMAの向き判定本数", minval=1)

zoneLookback = input.int(24, "1時間足 高値安値の参照本数", minval=5)
fvgSearchBars = input.int(30, "1時間足 FVG探索本数", minval=5, maxval=100)

scoreThreshold = input.int(3, "通知スコア", minval=1)
strongThreshold = input.int(5, "強通知スコア", minval=1)
cooldownBars = input.int(10, "同方向通知クールダウン", minval=1)

atrLen = input.int(14, "SL余白 ATR期間", minval=1)
atrMult = input.float(0.2, "SL余白 ATR倍率", minval=0.0, step=0.1)
slLookback = input.int(10, "SL用 直近安値/高値参照本数", minval=2)

rangeAtrLen = input.int(14, "レンジ判定ATR期間", minval=1)
rangeAtrMult = input.float(3.0, "レンジ判定ATR倍率", minval=0.5, step=0.1)

// ATRトレールSL
useAtrTrail = input.bool(true, "ATRトレールSLを使う")
trailAtrLen = input.int(14, "ATRトレール期間", minval=1)
trailAtrMult = input.float(2.0, "ATRトレール倍率", minval=0.1, step=0.1)

bosLookback = input.int(20, "BOS/CHoCH判定本数", minval=5)
rangeLen = input.int(12, "レンジブレイク判定本数", minval=5)
dbTolerance = input.float(0.15, "ダブルボトム/トップ許容率（%）", minval=0.01, step=0.01)
pinbarAtrMult = input.float(0.3, "ピンバー最低ヒゲ長（ATR倍率）", minval=0.1, step=0.05)
engulfAtrMult = input.float(0.2, "包み足 最低実体サイズ（ATR倍率）", minval=0.05, step=0.05)
rangeBreakMargin = input.float(0.1, "レンジブレイク 最低超過幅（ATR倍率）", minval=0.0, step=0.05)
rsiLen = input.int(14, "通常RSI期間", minval=2)

zoneExtendBars = input.int(50, "ゾーン右延長本数", minval=5)
showStatusBoard = input.bool(true, "ステータスボードを表示")
showScoreDetails = input.bool(true, "構造変化の内訳ボードを表示")
usePcLayout = input.bool(true, "PC用レイアウトを使う")

showSL = input.bool(true, "SLラインを表示")
showZones = input.bool(true, "ゾーン表示")

colLong = input.color(color.lime, "L？ 色")
colShort = input.color(color.red, "S？ 色")
colAddLong = input.color(color.green, "L+？ 色")
colAddShort = input.color(color.maroon, "S+？ 色")
colPartial = input.color(color.white, "部分利確 ＊ 色")
colFull = input.color(color.rgb(244, 248, 13), "全利確 ⭐︎ 色")
colSL = input.color(color.red, "SLライン 色")

showH4Ma = input.bool(true, "4時間足20SMAを表示")
colH4MaUp = input.color(color.lime, "4時間足20SMA 上向き色")
colH4MaDown = input.color(color.red, "4時間足20SMA 下向き色")
colH4MaFlat = input.color(color.gray, "4時間足20SMA 横向き色")

// =====================
// 強化機能 入力
// =====================
groupPower = "強化機能"

useScadosTP = input.bool(true, "スキャどす式 利確ロジックを使う", group=groupPower)
tpMaType = input.string("EMA", "利確用MAタイプ", options=["EMA", "SMA"], group=groupPower)
tpPeriod1 = input.int(13, "利確用 短期MA期間", minval=1, group=groupPower)
tpPeriod2 = input.int(100, "利確用 長期MA期間", minval=1, group=groupPower)
tpRsiExtremeHigh = input.int(90, "買われすぎ判定", minval=50, maxval=100, group=groupPower)
tpRsiExtremeLow = input.int(10, "売られすぎ判定", minval=0, maxval=50, group=groupPower)

useStrongPinbar = input.bool(true, "統計ヒゲで反転ピンバーを強化", group=groupPower)
wickSensitivity = input.float(2.0, "ヒゲ感度", minval=0.5, step=0.1, group=groupPower)

showTrendTable = input.bool(true, "1H/4H/D/W 環境認識テーブルを表示", group=groupPower)
showHTFLevels = input.bool(true, "1H/4H/D 高値安値ラインを表示", group=groupPower)

levelTextColor = input.color(color.white, "高値安値ラベル文字色", group=groupPower)
level1hColor = input.color(color.fuchsia, "1H高安ライン色", group=groupPower)
level4hColor = input.color(color.orange, "4H高安ライン色", group=groupPower)
levelDColor = input.color(color.aqua, "日足高安ライン色", group=groupPower)

// =====================
// ダブルボトム/トップ 入力 ★修正
// =====================
groupDouble = "ダブルボトム/トップ"
dbPivotLeft = input.int(5, "ピボット左確認本数", minval=2, group=groupDouble)
dbPivotRight = input.int(5, "ピボット右確認本数", minval=2, group=groupDouble)
dbMinDistance = input.int(10, "谷/山の最小間隔（本数）", minval=5, group=groupDouble)

// =====================
// BOS 入力 ★修正
// =====================
groupBOS = "BOS（構造転換）"
bosPivotLeft = input.int(5, "BOS ピボット左確認本数", minval=2, group=groupBOS)
bosPivotRight = input.int(5, "BOS ピボット右確認本数", minval=2, group=groupBOS)

// =====================
// STOCH RSI 入力
// =====================
groupStoch = "STOCH RSI"

useStochScore = input.bool(true, "STOCH RSI反転をスコア加点", group=groupStoch)
stochRsiLen = input.int(14, "RSI期間", minval=2, group=groupStoch)
stochLen = input.int(14, "STOCH期間", minval=2, group=groupStoch)
stochKSmooth = input.int(3, "K平滑化", minval=1, group=groupStoch)
stochDSmooth = input.int(3, "D平滑化", minval=1, group=groupStoch)
stochUpper = input.float(70, "買われすぎ水準", minval=50, maxval=100, group=groupStoch)
stochLower = input.float(30, "売られすぎ水準", minval=0, maxval=50, group=groupStoch)
stochLookback = input.int(10, "水準到達の有効本数", minval=1, group=groupStoch)

// =====================
// 関数
// =====================
f_pinbarLong(_atr, _atrMult) =>
    body = math.abs(close - open)
    lowerWick = math.min(open, close) - low
    upperWick = high - math.max(open, close)
    lowerWick > body * 2 and lowerWick > upperWick and close > open and lowerWick >= _atr * _atrMult

f_pinbarShort(_atr, _atrMult) =>
    body = math.abs(close - open)
    lowerWick = math.min(open, close) - low
    upperWick = high - math.max(open, close)
    upperWick > body * 2 and upperWick > lowerWick and close < open and upperWick >= _atr * _atrMult

f_engulfLong(_atr, _atrMult) =>
    engulfBody = math.abs(close - open)
    close > open and close[1] < open[1] and close >= open[1] and open <= close[1] and engulfBody >= _atr * _atrMult

f_engulfShort(_atr, _atrMult) =>
    engulfBody = math.abs(close - open)
    close < open and close[1] > open[1] and close <= open[1] and open >= close[1] and engulfBody >= _atr * _atrMult

f_deepBullFvg(_lookback, _search) =>
    h = ta.highest(high, _lookback)
    l = ta.lowest(low, _lookback)
    r = h - l
    fibHalf = h - r * 0.5
    float foundTop = na
    float foundBot = na
    for i = 0 to _search
        bull = high[i + 2] < low[i]
        top = low[i]
        bot = high[i + 2]
        qualified = bull and top <= fibHalf
        if na(foundTop) and qualified
            foundTop := top
            foundBot := bot
    [foundTop, foundBot]

f_deepBearFvg(_lookback, _search) =>
    h = ta.highest(high, _lookback)
    l = ta.lowest(low, _lookback)
    r = h - l
    fibHalf = l + r * 0.5
    float foundTop = na
    float foundBot = na
    for i = 0 to _search
        bear = low[i + 2] > high[i]
        top = low[i + 2]
        bot = high[i]
        qualified = bear and bot >= fibHalf
        if na(foundTop) and qualified
            foundTop := top
            foundBot := bot
    [foundTop, foundBot]

f_ma(_src, _len, _type) =>
    _type == "EMA" ? ta.ema(_src, _len) : ta.sma(_src, _len)

// =====================
// 環境認識
// =====================
h4Ma = request.security(syminfo.tickerid, tfH4, ta.sma(close, h4MaLen), barmerge.gaps_off, barmerge.lookahead_off)
h4MaPast = request.security(syminfo.tickerid, tfH4, ta.sma(close, h4MaLen)[h4SlopeBars], barmerge.gaps_off, barmerge.lookahead_off)

h1Ma = request.security(syminfo.tickerid, tfZone, ta.sma(close, h1MaLen), barmerge.gaps_off, barmerge.lookahead_off)
h1MaPast = request.security(syminfo.tickerid, tfZone, ta.sma(close, h1MaLen)[h1SlopeBars], barmerge.gaps_off, barmerge.lookahead_off)

h4MaUp = h4Ma > h4MaPast
h4MaDown = h4Ma < h4MaPast
h1MaDown = h1Ma < h1MaPast

longEnv = close > h4Ma or h4MaUp
shortEnv = h4Ma > h1Ma and h1Ma > close and h4MaDown and h1MaDown
envDir = longEnv ? 1 : shortEnv ? -1 : 0

h4MaColor = h4MaUp ? colH4MaUp : h4MaDown ? colH4MaDown : colH4MaFlat
plot(showH4Ma ? h4Ma : na, title="4時間足20SMA", color=h4MaColor, linewidth=2)

// =====================
// 1時間足ゾーン
// =====================
h1HighFixed = request.security(syminfo.tickerid, tfZone, ta.highest(high, zoneLookback), barmerge.gaps_off, barmerge.lookahead_off)
h1LowFixed = request.security(syminfo.tickerid, tfZone, ta.lowest(low, zoneLookback), barmerge.gaps_off, barmerge.lookahead_off)

var float runningHigh = na
var float runningLow = na
var int prevEnvDir = 0

envChanged = envDir != prevEnvDir

if envChanged
    runningHigh := h1HighFixed
    runningLow := h1LowFixed
    prevEnvDir := envDir
else
    if longEnv
        runningHigh := na(runningHigh) ? h1HighFixed : math.max(runningHigh, high)
    if shortEnv
        runningLow := na(runningLow) ? h1LowFixed : math.min(runningLow, low)

zoneHigh = longEnv ? runningHigh : shortEnv ? h1HighFixed : h1HighFixed
zoneLow = longEnv ? h1LowFixed : shortEnv ? runningLow : h1LowFixed

swingRange = zoneHigh - zoneLow

longFibTop = zoneHigh - swingRange * 0.5
longFibBot = zoneHigh - swingRange * 0.618

shortFibBot = zoneLow + swingRange * 0.5
shortFibTop = zoneLow + swingRange * 0.618

[bullFvgTop, bullFvgBot] = request.security(syminfo.tickerid, tfZone, f_deepBullFvg(zoneLookback, fvgSearchBars), barmerge.gaps_off, barmerge.lookahead_off)
[bearFvgTop, bearFvgBot] = request.security(syminfo.tickerid, tfZone, f_deepBearFvg(zoneLookback, fvgSearchBars), barmerge.gaps_off, barmerge.lookahead_off)

deepBullFvg = not na(bullFvgTop) and not na(bullFvgBot)
deepBearFvg = not na(bearFvgTop) and not na(bearFvgBot)

inLongFib = longEnv and low <= longFibTop and high >= longFibBot
inShortFib = shortEnv and high >= shortFibBot and low <= shortFibTop

inLongFvg = longEnv and deepBullFvg and low <= bullFvgTop and high >= bullFvgBot
inShortFvg = shortEnv and deepBearFvg and high >= bearFvgBot and low <= bearFvgTop

inLongZone = inLongFib or inLongFvg
inShortZone = inShortFib or inShortFvg

longZoneType = inLongFib and inLongFvg ? "Fibo+FVG" : inLongFib ? "Fibo" : inLongFvg ? "FVG" : "なし"
shortZoneType = inShortFib and inShortFvg ? "Fibo+FVG" : inShortFib ? "Fibo" : inShortFvg ? "FVG" : "なし"
zoneType = longEnv ? longZoneType : shortEnv ? shortZoneType : "なし"

// =====================
// 15分足 構造変化
// =====================
ema5 = ta.ema(close, 5)
ema13 = ta.ema(close, 13)

gc = ta.crossover(ema5, ema13)
dc = ta.crossunder(ema5, ema13)

pinbarAtr = ta.atr(14)
pinL = f_pinbarLong(pinbarAtr, pinbarAtrMult)
pinS = f_pinbarShort(pinbarAtr, pinbarAtrMult)
engulfL = f_engulfLong(pinbarAtr, engulfAtrMult)
engulfS = f_engulfShort(pinbarAtr, engulfAtrMult)

rangeHigh = ta.highest(high, rangeLen)[1]
rangeLow = ta.lowest(low, rangeLen)[1]
rangeWidth = rangeHigh - rangeLow
rangeAtr = ta.atr(rangeAtrLen)

isRange = rangeWidth <= rangeAtr * rangeAtrMult

rangeBreakL = isRange and close > rangeHigh and (close - rangeHigh) >= pinbarAtr * rangeBreakMargin
rangeBreakS = isRange and close < rangeLow and (rangeLow - close) >= pinbarAtr * rangeBreakMargin

// =====================
// ★修正：BOS — スイング構造ベース
// =====================
// ピボットでスイングハイ/ローを検出
bosPivotHi = ta.pivothigh(high, bosPivotLeft, bosPivotRight)
bosPivotLo = ta.pivotlow(low, bosPivotLeft, bosPivotRight)

// 直近のスイングハイ/ローを追跡
var float lastSwingHigh = na
var float lastSwingLow = na

if not na(bosPivotHi)
    lastSwingHigh := bosPivotHi
if not na(bosPivotLo)
    lastSwingLow := bosPivotLo

// BOS = 直近スイングハイ/ローを終値で突破
// レンジブレイクとの排他制御：レンジブレイクが同時に出ている場合はBOSを抑制
bosL = not na(lastSwingHigh) and close > lastSwingHigh and not rangeBreakL
bosS = not na(lastSwingLow) and close < lastSwingLow and not rangeBreakS

// BOS発火後、同じスイングポイントで連続発火しないようにリセット
if bosL
    lastSwingHigh := high
if bosS
    lastSwingLow := low

// =====================
// ★修正：ダブルボトム/ダブルトップ — ピボットベース
// =====================
dbPivotLo = ta.pivotlow(low, dbPivotLeft, dbPivotRight)
dbPivotHi = ta.pivothigh(high, dbPivotLeft, dbPivotRight)

// --- ダブルボトム ---
var float dbLow1 = na        // 古い方の谷
var int   dbLow1Bar = na
var float dbLow2 = na        // 新しい方の谷
var int   dbLow2Bar = na
var float dbNeckHigh = na    // 谷2確定後の最高値
var float dbNeckFromPivot = na // 谷1〜谷2の間のピボット高値
var bool  dbTriggered = false // 同じペアで1回だけ発火

// 新しいピボットローが確定したら谷をシフト
if not na(dbPivotLo)
    dbLow1 := dbLow2
    dbLow1Bar := dbLow2Bar
    dbLow2 := dbPivotLo
    dbLow2Bar := bar_index - dbPivotRight
    dbNeckHigh := na
    dbNeckFromPivot := na
    dbTriggered := false

// ネックライン追跡：谷2が確定した後、バー毎に最高値を更新
if not na(dbLow2Bar) and bar_index > dbLow2Bar
    dbNeckHigh := na(dbNeckHigh) ? high : math.max(dbNeckHigh, high)

// 2つの谷の間にも山があるはずなので、谷1→谷2の間のhighも考慮
// （ピボットが確定した時点でdbNeckHighをリセットしているので、
//   谷2以降の高値のみを追跡。谷1-谷2間の山はピボットハイで代用）
// 簡易ネックライン：谷2確定後の最高値 or 直前のピボットハイ

if not na(dbPivotHi) and not na(dbLow1Bar) and not na(dbLow2Bar)
    // ピボットハイが谷1と谷2の間に位置するなら、それをネックラインに採用
    hiBar = bar_index - dbPivotRight
    if hiBar > nz(dbLow1Bar) and hiBar < nz(dbLow2Bar)
        dbNeckFromPivot := dbPivotHi

// 最終ネックライン：ピボットハイベースのネックラインがあればそちら優先
dbFinalNeck = not na(dbNeckFromPivot) ? dbNeckFromPivot : dbNeckHigh

dbSeparation = not na(dbLow2Bar) and not na(dbLow1Bar) ? dbLow2Bar - dbLow1Bar : 0

doubleBottom = not na(dbLow1) and not na(dbLow2) and not dbTriggered and dbSeparation >= dbMinDistance and math.abs(dbLow1 - dbLow2) / close * 100 <= dbTolerance and not na(dbFinalNeck) and close > dbFinalNeck

if doubleBottom
    dbTriggered := true

// --- ダブルトップ ---
var float dtHigh1 = na
var int   dtHigh1Bar = na
var float dtHigh2 = na
var int   dtHigh2Bar = na
var float dtNeckLow = na
var float dtNeckFromPivot = na
var bool  dtTriggered = false

if not na(dbPivotHi)
    dtHigh1 := dtHigh2
    dtHigh1Bar := dtHigh2Bar
    dtHigh2 := dbPivotHi
    dtHigh2Bar := bar_index - dbPivotRight
    dtNeckLow := na
    dtNeckFromPivot := na
    dtTriggered := false

if not na(dtHigh2Bar) and bar_index > dtHigh2Bar
    dtNeckLow := na(dtNeckLow) ? low : math.min(dtNeckLow, low)

if not na(dbPivotLo) and not na(dtHigh1Bar) and not na(dtHigh2Bar)
    loBar = bar_index - dbPivotRight
    if loBar > nz(dtHigh1Bar) and loBar < nz(dtHigh2Bar)
        dtNeckFromPivot := dbPivotLo

dtFinalNeck = not na(dtNeckFromPivot) ? dtNeckFromPivot : dtNeckLow

dtSeparation = not na(dtHigh2Bar) and not na(dtHigh1Bar) ? dtHigh2Bar - dtHigh1Bar : 0

doubleTop = not na(dtHigh1) and not na(dtHigh2) and not dtTriggered and dtSeparation >= dbMinDistance and math.abs(dtHigh1 - dtHigh2) / close * 100 <= dbTolerance and not na(dtFinalNeck) and close < dtFinalNeck

if doubleTop
    dtTriggered := true

// =====================
// スキャどす式：ヒゲ・鈍化・過熱
// =====================
tpShortMA = f_ma(close, tpPeriod1, tpMaType)
tpLongMA = f_ma(close, tpPeriod2, tpMaType)

tpMACD = tpShortMA - tpLongMA
tpSIG = f_ma(tpMACD, tpPeriod1, tpMaType)
tpHIST = tpMACD - tpSIG

tpRSIShortMA = ta.rsi(tpShortMA, math.max(2, math.round(tpPeriod1 * 0.3)))
tpRSILongMA = ta.rsi(tpLongMA, math.max(2, math.round(tpPeriod2 * 0.3)))

uHige = high - math.max(open, close)
sHige = math.min(open, close) - low

uHigeAvg = ta.sma(uHige, tpPeriod2)
sHigeAvg = ta.sma(sHige, tpPeriod2)
higeAvg = math.avg(uHigeAvg, sHigeAvg)
higeStd = ta.stdev(higeAvg, tpPeriod2)

longUpperWick = higeStd != 0 ? ((uHige - higeAvg) / higeStd * wickSensitivity / 20 > 1) : false
longLowerWick = higeStd != 0 ? ((sHige - higeAvg) / higeStd * wickSensitivity / 20 > 1) : false

upDonka = ta.crossunder(tpHIST, tpHIST[1])
downDonka = ta.crossover(tpHIST, tpHIST[1])

tpBuyOverheat = tpRSIShortMA > tpRsiExtremeHigh and tpRSILongMA > tpRsiExtremeHigh
tpSellOverheat = tpRSIShortMA < tpRsiExtremeLow and tpRSILongMA < tpRsiExtremeLow

scadosCloseBuy = useScadosTP and tpBuyOverheat and (longUpperWick or upDonka)
scadosCloseSell = useScadosTP and tpSellOverheat and (longLowerWick or downDonka)

scadosStrongCloseBuy = useScadosTP and tpBuyOverheat and longUpperWick and upDonka
scadosStrongCloseSell = useScadosTP and tpSellOverheat and longLowerWick and downDonka

// =====================
// STOCH RSI
// =====================
rsiForStoch = ta.rsi(close, stochRsiLen)
rsiLowest = ta.lowest(rsiForStoch, stochLen)
rsiHighest = ta.highest(rsiForStoch, stochLen)
stochRange = rsiHighest - rsiLowest
stochRaw = stochRange != 0 ? 100 * (rsiForStoch - rsiLowest) / stochRange : 50
stochK = ta.sma(stochRaw, stochKSmooth)
stochD = ta.sma(stochK, stochDSmooth)

stochWasOversold = ta.lowest(stochK, stochLookback) <= stochLower
stochWasOverbought = ta.highest(stochK, stochLookback) >= stochUpper

stochLongRev = useStochScore and stochWasOversold and ta.crossover(stochK, stochLower) and stochK > stochK[1]
stochShortRev = useStochScore and stochWasOverbought and ta.crossunder(stochK, stochUpper) and stochK < stochK[1]

// =====================
// スコア
// =====================
reversalPinbarLongScore = pinL ? (useStrongPinbar and longLowerWick ? 2 : 1) : 0
reversalPinbarShortScore = pinS ? (useStrongPinbar and longUpperWick ? 2 : 1) : 0

longScore = 0
longScore += reversalPinbarLongScore
longScore += engulfL ? 1 : 0
longScore += doubleBottom ? 2 : 0
longScore += rangeBreakL ? 2 : 0
longScore += bosL ? 2 : 0
longScore += gc ? 1 : 0
longScore += stochLongRev ? 1 : 0

shortScore = 0
shortScore += reversalPinbarShortScore
shortScore += engulfS ? 1 : 0
shortScore += doubleTop ? 2 : 0
shortScore += rangeBreakS ? 2 : 0
shortScore += bosS ? 2 : 0
shortScore += dc ? 1 : 0
shortScore += stochShortRev ? 1 : 0

longHasStructure = longScore > 0
shortHasStructure = shortScore > 0

zoneBonusLong = inLongZone and longHasStructure ? 1 : 0
zoneBonusShort = inShortZone and shortHasStructure ? 1 : 0

longTotalScore = longScore + zoneBonusLong
shortTotalScore = shortScore + zoneBonusShort

// =====================
// エントリー候補
// =====================
var int lastLongSignalBar = na
var int lastShortSignalBar = na

canLong = na(lastLongSignalBar) or bar_index - lastLongSignalBar > cooldownBars
canShort = na(lastShortSignalBar) or bar_index - lastShortSignalBar > cooldownBars

longSignal = longEnv and longTotalScore >= scoreThreshold and canLong
shortSignal = shortEnv and shortTotalScore >= scoreThreshold and canShort

if longSignal
    lastLongSignalBar := bar_index

if shortSignal
    lastShortSignalBar := bar_index

// =====================
// SL + ATRトレールSL
// =====================
atr1h = request.security(syminfo.tickerid, tfZone, ta.atr(atrLen), barmerge.gaps_off, barmerge.lookahead_off)

recentLowForSL = ta.lowest(low, slLookback)
recentHighForSL = ta.highest(high, slLookback)

slLong = recentLowForSL - atr1h * atrMult
slShort = recentHighForSL + atr1h * atrMult

trailAtr = ta.atr(trailAtrLen)
trailLongCandidate = close - trailAtr * trailAtrMult
trailShortCandidate = close + trailAtr * trailAtrMult

var line slLine = na
var label slLabel = na
var bool inLongTrade = false
var bool inShortTrade = false

var float activeLongSL = na
var float activeShortSL = na

var bool longChochSeen = false
var bool shortChochSeen = false
var bool longAddDone = false
var bool shortAddDone = false
var float longChochHigh = na
var float shortChochLow = na
var int longChochBar = na
var int shortChochBar = na

if longSignal
    inLongTrade := true
    inShortTrade := false
    // SL切り下げ防止：既にロングトレード中なら、現在のSLと新しいSLの高い方を採用
    activeLongSL := not na(activeLongSL) ? math.max(activeLongSL, slLong) : slLong
    activeShortSL := na

    longChochSeen := false
    shortChochSeen := false
    longAddDone := false
    shortAddDone := false
    longChochHigh := na
    shortChochLow := na
    longChochBar := na
    shortChochBar := na

    if showSL
        line.delete(slLine)
        label.delete(slLabel)
        slLine := line.new(bar_index, activeLongSL, bar_index + 1, activeLongSL, extend=extend.right, color=colSL, width=2)
        slLabel := label.new(bar_index, activeLongSL, "SL", style=label.style_label_left, textcolor=color.white, color=colSL)

if shortSignal
    inShortTrade := true
    inLongTrade := false
    // SL切り上げ防止：既にショートトレード中なら、現在のSLと新しいSLの低い方を採用
    activeShortSL := not na(activeShortSL) ? math.min(activeShortSL, slShort) : slShort
    activeLongSL := na

    longChochSeen := false
    shortChochSeen := false
    longAddDone := false
    shortAddDone := false
    longChochHigh := na
    shortChochLow := na
    longChochBar := na
    shortChochBar := na

    if showSL
        line.delete(slLine)
        label.delete(slLabel)
        slLine := line.new(bar_index, activeShortSL, bar_index + 1, activeShortSL, extend=extend.right, color=colSL, width=2)
        slLabel := label.new(bar_index, activeShortSL, "SL", style=label.style_label_left, textcolor=color.white, color=colSL)

// ATRトレールSL
if useAtrTrail and inLongTrade and not na(activeLongSL)
    newLongSL = trailLongCandidate
    activeLongSL := math.max(activeLongSL, newLongSL)

    if showSL and not na(slLine)
        line.set_y1(slLine, activeLongSL)
        line.set_y2(slLine, activeLongSL)
        label.set_y(slLabel, activeLongSL)

if useAtrTrail and inShortTrade and not na(activeShortSL)
    newShortSL = trailShortCandidate
    activeShortSL := math.min(activeShortSL, newShortSL)

    if showSL and not na(slLine)
        line.set_y1(slLine, activeShortSL)
        line.set_y2(slLine, activeShortSL)
        label.set_y(slLabel, activeShortSL)

// =====================
// 追撃シグナル：CHoCH → BOS
// =====================
// 追撃用のBOSは元のシンプル版を使用（排他制御なし）
bosLforChase = close > ta.highest(high, bosLookback)[1]
bosSforChase = close < ta.lowest(low, bosLookback)[1]

if inLongTrade and not longChochSeen and bosLforChase
    longChochSeen := true
    longChochHigh := high
    longChochBar := bar_index

if inShortTrade and not shortChochSeen and bosSforChase
    shortChochSeen := true
    shortChochLow := low
    shortChochBar := bar_index

longAddSignal = inLongTrade and longChochSeen and not longAddDone and bar_index > longChochBar and close > longChochHigh
shortAddSignal = inShortTrade and shortChochSeen and not shortAddDone and bar_index > shortChochBar and close < shortChochLow

if longAddSignal
    longAddDone := true

if shortAddSignal
    shortAddDone := true

// =====================
// 利確判定
// =====================
tpLongStructure = high >= zoneHigh
tpShortStructure = low <= zoneLow

rsi = ta.rsi(close, rsiLen)

overHeatLong = inLongTrade and rsi > 75 and close < open
overHeatShort = inShortTrade and rsi < 25 and close > open

reversePALong = inLongTrade and (pinS or engulfS)
reversePAShort = inShortTrade and (pinL or engulfL)

partialLong = inLongTrade and (tpLongStructure or dc or scadosCloseBuy)
partialShort = inShortTrade and (tpShortStructure or gc or scadosCloseSell)

fullLong = inLongTrade and (bosSforChase or reversePALong or overHeatLong or scadosStrongCloseBuy)
fullShort = inShortTrade and (bosLforChase or reversePAShort or overHeatShort or scadosStrongCloseSell)

if fullLong or fullShort
    inLongTrade := false
    inShortTrade := false
    activeLongSL := na
    activeShortSL := na
    longChochSeen := false
    shortChochSeen := false
    longAddDone := false
    shortAddDone := false
    line.delete(slLine)
    label.delete(slLabel)

// =====================
// 表示：背景透明の文字
// =====================
plotshape(longSignal, title="L？", text="L？", style=shape.labelup, location=location.belowbar, color=color.new(color.black, 100), textcolor=colLong, size=size.small)
plotshape(shortSignal, title="S？", text="S？", style=shape.labeldown, location=location.abovebar, color=color.new(color.black, 100), textcolor=colShort, size=size.small)

plotshape(longAddSignal, title="L+？", text="L+？", style=shape.labelup, location=location.belowbar, color=color.new(color.black, 100), textcolor=colAddLong, size=size.small)
plotshape(shortAddSignal, title="S+？", text="S+？", style=shape.labeldown, location=location.abovebar, color=color.new(color.black, 100), textcolor=colAddShort, size=size.small)

plotshape(partialLong, title="L部分利確", text="＊", style=shape.labeldown, location=location.abovebar, color=color.new(color.black, 100), textcolor=colPartial, size=size.normal)
plotshape(partialShort, title="S部分利確", text="＊", style=shape.labelup, location=location.belowbar, color=color.new(color.black, 100), textcolor=colPartial, size=size.normal)

plotshape(fullLong, title="L全利確", text="⭐︎", style=shape.labeldown, location=location.abovebar, color=color.new(color.black, 100), textcolor=colFull, size=size.normal)
plotshape(fullShort, title="S全利確", text="⭐︎", style=shape.labelup, location=location.belowbar, color=color.new(color.black, 100), textcolor=colFull, size=size.normal)

// =====================
// ゾーン表示：現在の有効ゾーンだけ box 表示
// =====================
var box fibBox = na
var box fvgBox = na

if barstate.islast
    box.delete(fibBox)
    box.delete(fvgBox)

    if showZones and longEnv
        fibBox := box.new(left=bar_index, top=longFibTop, right=bar_index + zoneExtendBars, bottom=longFibBot, bgcolor=color.new(color.green, 85), border_color=color.new(color.green, 70))
        if deepBullFvg
            fvgBox := box.new(left=bar_index, top=bullFvgTop, right=bar_index + zoneExtendBars, bottom=bullFvgBot, bgcolor=color.new(color.green, 80), border_color=color.new(color.green, 60))

    if showZones and shortEnv
        fibBox := box.new(left=bar_index, top=shortFibTop, right=bar_index + zoneExtendBars, bottom=shortFibBot, bgcolor=color.new(color.red, 85), border_color=color.new(color.red, 70))
        if deepBearFvg
            fvgBox := box.new(left=bar_index, top=bearFvgTop, right=bar_index + zoneExtendBars, bottom=bearFvgBot, bgcolor=color.new(color.red, 80), border_color=color.new(color.red, 60))

// =====================
// 1H / 4H / D 高値安値ライン
// =====================
h1HighLineVal = request.security(syminfo.tickerid, "60", ta.highest(high, zoneLookback), barmerge.gaps_off, barmerge.lookahead_off)
h1LowLineVal = request.security(syminfo.tickerid, "60", ta.lowest(low, zoneLookback), barmerge.gaps_off, barmerge.lookahead_off)
h4HighLineVal = request.security(syminfo.tickerid, "240", ta.highest(high, zoneLookback), barmerge.gaps_off, barmerge.lookahead_off)
h4LowLineVal = request.security(syminfo.tickerid, "240", ta.lowest(low, zoneLookback), barmerge.gaps_off, barmerge.lookahead_off)
dHighLineVal = request.security(syminfo.tickerid, "D", ta.highest(high, 10), barmerge.gaps_off, barmerge.lookahead_off)
dLowLineVal = request.security(syminfo.tickerid, "D", ta.lowest(low, 10), barmerge.gaps_off, barmerge.lookahead_off)

var line h1HighLine = na
var line h1LowLine = na
var line h4HighLine = na
var line h4LowLine = na
var line dHighLine = na
var line dLowLine = na

var label h1HighLabel = na
var label h1LowLabel = na
var label h4HighLabel = na
var label h4LowLabel = na
var label dHighLabel = na
var label dLowLabel = na

if barstate.islast
    line.delete(h1HighLine)
    line.delete(h1LowLine)
    line.delete(h4HighLine)
    line.delete(h4LowLine)
    line.delete(dHighLine)
    line.delete(dLowLine)

    label.delete(h1HighLabel)
    label.delete(h1LowLabel)
    label.delete(h4HighLabel)
    label.delete(h4LowLabel)
    label.delete(dHighLabel)
    label.delete(dLowLabel)

    if showHTFLevels
        h1HighLine := line.new(bar_index, h1HighLineVal, bar_index + 30, h1HighLineVal, extend=extend.right, color=level1hColor, width=1, style=line.style_dashed)
        h1LowLine := line.new(bar_index, h1LowLineVal, bar_index + 30, h1LowLineVal, extend=extend.right, color=level1hColor, width=1, style=line.style_dashed)
        h4HighLine := line.new(bar_index, h4HighLineVal, bar_index + 30, h4HighLineVal, extend=extend.right, color=level4hColor, width=1, style=line.style_dashed)
        h4LowLine := line.new(bar_index, h4LowLineVal, bar_index + 30, h4LowLineVal, extend=extend.right, color=level4hColor, width=1, style=line.style_dashed)
        dHighLine := line.new(bar_index, dHighLineVal, bar_index + 30, dHighLineVal, extend=extend.right, color=levelDColor, width=1, style=line.style_dashed)
        dLowLine := line.new(bar_index, dLowLineVal, bar_index + 30, dLowLineVal, extend=extend.right, color=levelDColor, width=1, style=line.style_dashed)

        h1HighLabel := label.new(bar_index + 30, h1HighLineVal, "1H高値", style=label.style_label_left, textcolor=levelTextColor, color=color.new(color.black, 100), size=size.small)
        h1LowLabel := label.new(bar_index + 30, h1LowLineVal, "1H安値", style=label.style_label_left, textcolor=levelTextColor, color=color.new(color.black, 100), size=size.small)
        h4HighLabel := label.new(bar_index + 30, h4HighLineVal, "4H高値", style=label.style_label_left, textcolor=levelTextColor, color=color.new(color.black, 100), size=size.small)
        h4LowLabel := label.new(bar_index + 30, h4LowLineVal, "4H安値", style=label.style_label_left, textcolor=levelTextColor, color=color.new(color.black, 100), size=size.small)
        dHighLabel := label.new(bar_index + 30, dHighLineVal, "D高値", style=label.style_label_left, textcolor=levelTextColor, color=color.new(color.black, 100), size=size.small)
        dLowLabel := label.new(bar_index + 30, dLowLineVal, "D安値", style=label.style_label_left, textcolor=levelTextColor, color=color.new(color.black, 100), size=size.small)

// =====================
// ステータスボード + 構造変化内訳ボード
// PC用 / スマホ用 切替対応
// =====================
var table dashboard = table.new(position.top_right, 11, 13, border_width=0)

dirText = envDir == 1 ? "ロング目線" : envDir == -1 ? "ショート目線" : "見送り"
scoreValue = envDir == 1 ? longTotalScore : envDir == -1 ? shortTotalScore : 0
scoreText = str.tostring(scoreValue) + "点"

detailPinbarScore = envDir == 1 ? reversalPinbarLongScore : envDir == -1 ? reversalPinbarShortScore : 0
detailPinbar = detailPinbarScore > 0
detailEngulf = envDir == 1 ? engulfL : envDir == -1 ? engulfS : false
detailDouble = envDir == 1 ? doubleBottom : envDir == -1 ? doubleTop : false
detailRangeBreak = envDir == 1 ? rangeBreakL : envDir == -1 ? rangeBreakS : false
detailBos = envDir == 1 ? bosL : envDir == -1 ? bosS : false
detailEma = envDir == 1 ? gc : envDir == -1 ? dc : false
detailStoch = envDir == 1 ? stochLongRev : envDir == -1 ? stochShortRev : false
detailZone = envDir == 1 ? zoneBonusLong > 0 : envDir == -1 ? zoneBonusShort > 0 : false

doubleName = envDir == 1 ? "ダブルボトム" : envDir == -1 ? "ダブルトップ" : "ダブル"
emaName = envDir == 1 ? "EMA GC" : envDir == -1 ? "EMA DC" : "EMA"
stochName = envDir == 1 ? "STOCH上抜け" : envDir == -1 ? "STOCH下抜け" : "STOCH反転"

mark(_cond) =>
    _cond ? "〇" : "×"

pointText(_cond, _pt) =>
    _cond ? "+" + str.tostring(_pt) : "0"

pointTextVal(_pt) =>
    _pt > 0 ? "+" + str.tostring(_pt) : "0"

markColor(_cond) =>
    _cond ? color.lime : color.rgb(130, 138, 155)

rowBg(_cond) =>
    _cond ? color.new(color.rgb(22, 101, 52), 78) : color.new(color.rgb(30, 41, 59), 72)

// =====================
// 色設定
// =====================
panelBg = color.new(color.rgb(8, 15, 30), 8)
cardTitleBg = color.new(color.rgb(30, 41, 59), 18)
cardValueBg = color.new(color.rgb(15, 23, 42), 6)
listTitleBg = color.new(color.rgb(22, 34, 54), 10)
gapBg = color.new(color.black, 100)

activeLongBg = color.new(color.rgb(34, 197, 94), 58)
activeShortBg = color.new(color.rgb(239, 68, 68), 58)
neutralBg = color.new(color.rgb(71, 85, 105), 45)

dirBg = envDir == 1 ? activeLongBg : envDir == -1 ? activeShortBg : neutralBg

scoreBg = scoreValue >= 8 ? color.new(color.rgb(168, 85, 247), 25) :
          scoreValue >= 6 ? color.new(color.rgb(249, 115, 22), 18) :
          scoreValue >= 4 ? color.new(color.rgb(34, 197, 94), 45) :
          cardValueBg

scoreTextColor = scoreValue >= 8 ? color.white :
                 scoreValue >= 6 ? color.white :
                 scoreValue >= 4 ? color.rgb(220, 255, 220) :
                 color.white

// PC用は少し大きめ、スマホ用は小さめ
boardTextSize = usePcLayout ? size.small : size.tiny

if barstate.islast
    // 全体初期化
    for r = 0 to 12
        for c = 0 to 10
            table.cell(dashboard, c, r, "", bgcolor=color.new(color.black, 100), text_size=boardTextSize)

    // =====================
    // PC用レイアウト
    // =====================
    if showStatusBoard and usePcLayout
        table.cell(dashboard, 6, 0, "現在の方向", text_color=color.white, bgcolor=cardTitleBg, text_size=boardTextSize)
        table.cell(dashboard, 7, 0, "", bgcolor=cardTitleBg, text_size=boardTextSize)
        table.cell(dashboard, 6, 1, dirText, text_color=color.white, bgcolor=dirBg, text_size=boardTextSize)
        table.cell(dashboard, 7, 1, "", bgcolor=dirBg, text_size=boardTextSize)

        table.cell(dashboard, 8, 0, "", bgcolor=gapBg, text_size=boardTextSize)
        table.cell(dashboard, 8, 1, "", bgcolor=gapBg, text_size=boardTextSize)

        table.cell(dashboard, 9, 0, "構造変化スコア", text_color=color.white, bgcolor=cardTitleBg, text_size=boardTextSize)
        table.cell(dashboard, 10, 0, "", bgcolor=cardTitleBg, text_size=boardTextSize)

        table.cell(dashboard, 9, 1, scoreText, text_color=scoreTextColor, bgcolor=scoreBg, text_size=boardTextSize)
        table.cell(dashboard, 10, 1, "", bgcolor=scoreBg, text_size=boardTextSize)

    // PC用：内訳チェックリスト
    if showScoreDetails and usePcLayout
        table.cell(dashboard, 6, 3, "内訳チェックリスト", text_color=color.white, bgcolor=listTitleBg, text_size=boardTextSize)
        table.cell(dashboard, 7, 3, "", bgcolor=listTitleBg, text_size=boardTextSize)
        table.cell(dashboard, 8, 3, "", bgcolor=listTitleBg, text_size=boardTextSize)
        table.cell(dashboard, 9, 3, "", bgcolor=listTitleBg, text_size=boardTextSize)
        table.cell(dashboard, 10, 3, "", bgcolor=listTitleBg, text_size=boardTextSize)

        table.cell(dashboard, 6, 4, "反転ピンバー", text_color=color.white, bgcolor=rowBg(detailPinbar), text_size=boardTextSize)
        table.cell(dashboard, 7, 4, "", bgcolor=rowBg(detailPinbar), text_size=boardTextSize)
        table.cell(dashboard, 8, 4, "", bgcolor=rowBg(detailPinbar), text_size=boardTextSize)
        table.cell(dashboard, 9, 4, mark(detailPinbar), text_color=markColor(detailPinbar), bgcolor=rowBg(detailPinbar), text_size=boardTextSize)
        table.cell(dashboard, 10, 4, pointTextVal(detailPinbarScore), text_color=color.white, bgcolor=rowBg(detailPinbar), text_size=boardTextSize)

        table.cell(dashboard, 6, 5, "包み足", text_color=color.white, bgcolor=rowBg(detailEngulf), text_size=boardTextSize)
        table.cell(dashboard, 7, 5, "", bgcolor=rowBg(detailEngulf), text_size=boardTextSize)
        table.cell(dashboard, 8, 5, "", bgcolor=rowBg(detailEngulf), text_size=boardTextSize)
        table.cell(dashboard, 9, 5, mark(detailEngulf), text_color=markColor(detailEngulf), bgcolor=rowBg(detailEngulf), text_size=boardTextSize)
        table.cell(dashboard, 10, 5, pointText(detailEngulf, 1), text_color=color.white, bgcolor=rowBg(detailEngulf), text_size=boardTextSize)

        table.cell(dashboard, 6, 6, doubleName, text_color=color.white, bgcolor=rowBg(detailDouble), text_size=boardTextSize)
        table.cell(dashboard, 7, 6, "", bgcolor=rowBg(detailDouble), text_size=boardTextSize)
        table.cell(dashboard, 8, 6, "", bgcolor=rowBg(detailDouble), text_size=boardTextSize)
        table.cell(dashboard, 9, 6, mark(detailDouble), text_color=markColor(detailDouble), bgcolor=rowBg(detailDouble), text_size=boardTextSize)
        table.cell(dashboard, 10, 6, pointText(detailDouble, 2), text_color=color.white, bgcolor=rowBg(detailDouble), text_size=boardTextSize)

        table.cell(dashboard, 6, 7, "レンジブレイク", text_color=color.white, bgcolor=rowBg(detailRangeBreak), text_size=boardTextSize)
        table.cell(dashboard, 7, 7, "", bgcolor=rowBg(detailRangeBreak), text_size=boardTextSize)
        table.cell(dashboard, 8, 7, "", bgcolor=rowBg(detailRangeBreak), text_size=boardTextSize)
        table.cell(dashboard, 9, 7, mark(detailRangeBreak), text_color=markColor(detailRangeBreak), bgcolor=rowBg(detailRangeBreak), text_size=boardTextSize)
        table.cell(dashboard, 10, 7, pointText(detailRangeBreak, 2), text_color=color.white, bgcolor=rowBg(detailRangeBreak), text_size=boardTextSize)

        table.cell(dashboard, 6, 8, "BOS", text_color=color.white, bgcolor=rowBg(detailBos), text_size=boardTextSize)
        table.cell(dashboard, 7, 8, "", bgcolor=rowBg(detailBos), text_size=boardTextSize)
        table.cell(dashboard, 8, 8, "", bgcolor=rowBg(detailBos), text_size=boardTextSize)
        table.cell(dashboard, 9, 8, mark(detailBos), text_color=markColor(detailBos), bgcolor=rowBg(detailBos), text_size=boardTextSize)
        table.cell(dashboard, 10, 8, pointText(detailBos, 2), text_color=color.white, bgcolor=rowBg(detailBos), text_size=boardTextSize)

        table.cell(dashboard, 6, 9, emaName, text_color=color.white, bgcolor=rowBg(detailEma), text_size=boardTextSize)
        table.cell(dashboard, 7, 9, "", bgcolor=rowBg(detailEma), text_size=boardTextSize)
        table.cell(dashboard, 8, 9, "", bgcolor=rowBg(detailEma), text_size=boardTextSize)
        table.cell(dashboard, 9, 9, mark(detailEma), text_color=markColor(detailEma), bgcolor=rowBg(detailEma), text_size=boardTextSize)
        table.cell(dashboard, 10, 9, pointText(detailEma, 1), text_color=color.white, bgcolor=rowBg(detailEma), text_size=boardTextSize)

        table.cell(dashboard, 6, 10, stochName, text_color=color.white, bgcolor=rowBg(detailStoch), text_size=boardTextSize)
        table.cell(dashboard, 7, 10, "", bgcolor=rowBg(detailStoch), text_size=boardTextSize)
        table.cell(dashboard, 8, 10, "", bgcolor=rowBg(detailStoch), text_size=boardTextSize)
        table.cell(dashboard, 9, 10, mark(detailStoch), text_color=markColor(detailStoch), bgcolor=rowBg(detailStoch), text_size=boardTextSize)
        table.cell(dashboard, 10, 10, pointText(detailStoch, 1), text_color=color.white, bgcolor=rowBg(detailStoch), text_size=boardTextSize)

        table.cell(dashboard, 6, 11, "ゾーン反応", text_color=color.white, bgcolor=rowBg(detailZone), text_size=boardTextSize)
        table.cell(dashboard, 7, 11, "", bgcolor=rowBg(detailZone), text_size=boardTextSize)
        table.cell(dashboard, 8, 11, "", bgcolor=rowBg(detailZone), text_size=boardTextSize)
        table.cell(dashboard, 9, 11, mark(detailZone), text_color=markColor(detailZone), bgcolor=rowBg(detailZone), text_size=boardTextSize)
        table.cell(dashboard, 10, 11, pointText(detailZone, 1), text_color=color.white, bgcolor=rowBg(detailZone), text_size=boardTextSize)

    // =====================
    // スマホ用レイアウト
    // =====================
    if showStatusBoard and not usePcLayout
        table.cell(dashboard, 8, 0, "方向", text_color=color.white, bgcolor=cardTitleBg, text_size=boardTextSize)
        table.cell(dashboard, 9, 0, dirText, text_color=color.white, bgcolor=dirBg, text_size=boardTextSize)
        table.cell(dashboard, 10, 0, "", bgcolor=dirBg, text_size=boardTextSize)

        table.cell(dashboard, 8, 1, "スコア", text_color=color.white, bgcolor=cardTitleBg, text_size=boardTextSize)
        table.cell(dashboard, 9, 1, scoreText, text_color=scoreTextColor, bgcolor=scoreBg, text_size=boardTextSize)
        table.cell(dashboard, 10, 1, "", bgcolor=scoreBg, text_size=boardTextSize)

    // スマホ用：内訳チェックリスト
    if showScoreDetails and not usePcLayout
        table.cell(dashboard, 8, 3, "内訳", text_color=color.white, bgcolor=listTitleBg, text_size=boardTextSize)
        table.cell(dashboard, 9, 3, "", bgcolor=listTitleBg, text_size=boardTextSize)
        table.cell(dashboard, 10, 3, "", bgcolor=listTitleBg, text_size=boardTextSize)

        table.cell(dashboard, 8, 4, "ピンバー", text_color=color.white, bgcolor=rowBg(detailPinbar), text_size=boardTextSize)
        table.cell(dashboard, 9, 4, mark(detailPinbar), text_color=markColor(detailPinbar), bgcolor=rowBg(detailPinbar), text_size=boardTextSize)
        table.cell(dashboard, 10, 4, pointTextVal(detailPinbarScore), text_color=color.white, bgcolor=rowBg(detailPinbar), text_size=boardTextSize)

        table.cell(dashboard, 8, 5, "包み足", text_color=color.white, bgcolor=rowBg(detailEngulf), text_size=boardTextSize)
        table.cell(dashboard, 9, 5, mark(detailEngulf), text_color=markColor(detailEngulf), bgcolor=rowBg(detailEngulf), text_size=boardTextSize)
        table.cell(dashboard, 10, 5, pointText(detailEngulf, 1), text_color=color.white, bgcolor=rowBg(detailEngulf), text_size=boardTextSize)

        table.cell(dashboard, 8, 6, doubleName, text_color=color.white, bgcolor=rowBg(detailDouble), text_size=boardTextSize)
        table.cell(dashboard, 9, 6, mark(detailDouble), text_color=markColor(detailDouble), bgcolor=rowBg(detailDouble), text_size=boardTextSize)
        table.cell(dashboard, 10, 6, pointText(detailDouble, 2), text_color=color.white, bgcolor=rowBg(detailDouble), text_size=boardTextSize)

        table.cell(dashboard, 8, 7, "レンジ", text_color=color.white, bgcolor=rowBg(detailRangeBreak), text_size=boardTextSize)
        table.cell(dashboard, 9, 7, mark(detailRangeBreak), text_color=markColor(detailRangeBreak), bgcolor=rowBg(detailRangeBreak), text_size=boardTextSize)
        table.cell(dashboard, 10, 7, pointText(detailRangeBreak, 2), text_color=color.white, bgcolor=rowBg(detailRangeBreak), text_size=boardTextSize)

        table.cell(dashboard, 8, 8, "BOS", text_color=color.white, bgcolor=rowBg(detailBos), text_size=boardTextSize)
        table.cell(dashboard, 9, 8, mark(detailBos), text_color=markColor(detailBos), bgcolor=rowBg(detailBos), text_size=boardTextSize)
        table.cell(dashboard, 10, 8, pointText(detailBos, 2), text_color=color.white, bgcolor=rowBg(detailBos), text_size=boardTextSize)

        table.cell(dashboard, 8, 9, emaName, text_color=color.white, bgcolor=rowBg(detailEma), text_size=boardTextSize)
        table.cell(dashboard, 9, 9, mark(detailEma), text_color=markColor(detailEma), bgcolor=rowBg(detailEma), text_size=boardTextSize)
        table.cell(dashboard, 10, 9, pointText(detailEma, 1), text_color=color.white, bgcolor=rowBg(detailEma), text_size=boardTextSize)

        table.cell(dashboard, 8, 10, "STOCH", text_color=color.white, bgcolor=rowBg(detailStoch), text_size=boardTextSize)
        table.cell(dashboard, 9, 10, mark(detailStoch), text_color=markColor(detailStoch), bgcolor=rowBg(detailStoch), text_size=boardTextSize)
        table.cell(dashboard, 10, 10, pointText(detailStoch, 1), text_color=color.white, bgcolor=rowBg(detailStoch), text_size=boardTextSize)

        table.cell(dashboard, 8, 11, "ゾーン", text_color=color.white, bgcolor=rowBg(detailZone), text_size=boardTextSize)
        table.cell(dashboard, 9, 11, mark(detailZone), text_color=markColor(detailZone), bgcolor=rowBg(detailZone), text_size=boardTextSize)
        table.cell(dashboard, 10, 11, pointText(detailZone, 1), text_color=color.white, bgcolor=rowBg(detailZone), text_size=boardTextSize)
    
// =====================
// MTF環境認識テーブル
// =====================
sma20_1h = request.security(syminfo.tickerid, "60", ta.sma(close, 20), barmerge.gaps_off, barmerge.lookahead_off)
sma20_4h = request.security(syminfo.tickerid, "240", ta.sma(close, 20), barmerge.gaps_off, barmerge.lookahead_off)
sma20_d = request.security(syminfo.tickerid, "D", ta.sma(close, 20), barmerge.gaps_off, barmerge.lookahead_off)
sma20_w = request.security(syminfo.tickerid, "W", ta.sma(close, 20), barmerge.gaps_off, barmerge.lookahead_off)

close_1h = request.security(syminfo.tickerid, "60", close, barmerge.gaps_off, barmerge.lookahead_off)
close_4h = request.security(syminfo.tickerid, "240", close, barmerge.gaps_off, barmerge.lookahead_off)
close_d = request.security(syminfo.tickerid, "D", close, barmerge.gaps_off, barmerge.lookahead_off)
close_w = request.security(syminfo.tickerid, "W", close, barmerge.gaps_off, barmerge.lookahead_off)

stdev_1h = request.security(syminfo.tickerid, "60", ta.stdev(close, 20), barmerge.gaps_off, barmerge.lookahead_off)
stdev_4h = request.security(syminfo.tickerid, "240", ta.stdev(close, 20), barmerge.gaps_off, barmerge.lookahead_off)
stdev_d = request.security(syminfo.tickerid, "D", ta.stdev(close, 20), barmerge.gaps_off, barmerge.lookahead_off)
stdev_w = request.security(syminfo.tickerid, "W", ta.stdev(close, 20), barmerge.gaps_off, barmerge.lookahead_off)

bbu_1h = sma20_1h + stdev_1h * 2
bbl_1h = sma20_1h - stdev_1h * 2
bbu_4h = sma20_4h + stdev_4h * 2
bbl_4h = sma20_4h - stdev_4h * 2
bbu_d = sma20_d + stdev_d * 2
bbl_d = sma20_d - stdev_d * 2
bbu_w = sma20_w + stdev_w * 2
bbl_w = sma20_w - stdev_w * 2

trend_1h = close_1h > bbu_1h ? "▲▲" : close_1h > sma20_1h ? "▲" : close_1h > bbl_1h ? "▼" : "▼▼"
trend_4h = close_4h > bbu_4h ? "▲▲" : close_4h > sma20_4h ? "▲" : close_4h > bbl_4h ? "▼" : "▼▼"
trend_d = close_d > bbu_d ? "▲▲" : close_d > sma20_d ? "▲" : close_d > bbl_d ? "▼" : "▼▼"
trend_w = close_w > bbu_w ? "▲▲" : close_w > sma20_w ? "▲" : close_w > bbl_w ? "▼" : "▼▼"

var table trendTable = table.new(position.bottom_right, 4, 1, border_width=1)

f_cell(_col, _txt, _isBull) =>
    bg = _isBull ? color.new(color.green, 75) : color.new(color.red, 75)
    tc = _isBull ? color.lime : color.red
    table.cell(trendTable, _col, 0, _txt, text_color=tc, bgcolor=bg)

if showTrendTable and barstate.islast
    f_cell(0, trend_1h + " 1H", trend_1h == "▲" or trend_1h == "▲▲")
    f_cell(1, trend_4h + " 4H", trend_4h == "▲" or trend_4h == "▲▲")
    f_cell(2, trend_d + " D", trend_d == "▲" or trend_d == "▲▲")
    f_cell(3, trend_w + " W", trend_w == "▲" or trend_w == "▲▲")

// =====================
// アラート
// =====================
anyEntrySignal = longSignal or shortSignal or longAddSignal or shortAddSignal
anyTakeProfitSignal = partialLong or partialShort or fullLong or fullShort
anySignal = anyEntrySignal or anyTakeProfitSignal

alertcondition(anyEntrySignal, title="分析してみてください", message="分析してみてください")
alertcondition(anyTakeProfitSignal, title="利確確認してください", message="利確確認してください")
alertcondition(anySignal, title="お知らせ", message="お知らせ")
````
