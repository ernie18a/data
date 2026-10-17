# Bull Rebound Speed / Jump Pressure Pulse Oscillator + TOPIX v12

- url: https://www.tradingview.com/script/HEWPVExg/
- type: indicator
- pine_id: PUB;cda2377451024b669ad80493b215496e
- version: 1.0

## Description

テストスプリクト

## Source Code

````pine
//@version=5
indicator("Bull Rebound Speed / Jump Pressure Pulse Oscillator + TOPIX v12", overlay=false, max_bars_back=500, max_labels_count=500)

// ==================================================
// 基本設定
// ==================================================

dropLen = input.int(20, "直近下落幅を見る本数", minval=5)

decayJump = input.float(0.90, "急戻り累積 減衰", minval=0.50, maxval=0.99, step=0.01)

jumpAddWeight = input.float(1.00, "急戻り累積 加算係数", minval=0.10, step=0.10)

speedThreshold1 = input.float(8.0, "急戻り判定1", minval=0.0, step=1.0)

speedThreshold2 = input.float(15.0, "急戻り判定2", minval=0.0, step=1.0)

speedThreshold3 = input.float(25.0, "急戻り判定3", minval=0.0, step=1.0)

eventAdd1 = input.float(10.0, "急戻り1 加点", minval=0.0, step=1.0)

eventAdd2 = input.float(20.0, "急戻り2 加点", minval=0.0, step=1.0)

eventAdd3 = input.float(35.0, "急戻り3 加点", minval=0.0, step=1.0)

// ==================================================
// 白線設定
// ==================================================

basisLen = input.int(20, "青線平均期間", minval=5)

// ==================================================
// 背景表示設定
// ==================================================
// 元の背景判定を維持する。
//
// 早期警戒：
// 青線が80以上
// かつ
// 白線が横ばい以上
//
// 本警戒：
// 白線が100以上
// かつ
// 白線が上向き
//
// 黄色線・紫線・TOPIX方向線は、
// 背景色の条件に使用しない。

showEarlyBg = input.bool(true, "早期警戒背景を表示")

showMainBg = input.bool(true, "本警戒背景を表示")

earlyJumpLevel = input.float(80.0, "早期警戒 青線基準", minval=0.0, step=5.0)

mainBasisLevel = input.float(100.0, "本警戒 白線基準", minval=0.0, step=5.0)

earlyBgTransp = input.int(92, "早期警戒 背景透明度", minval=0, maxval=100)

mainBgTransp = input.int(86, "本警戒 背景透明度", minval=0, maxval=100)

// ==================================================
// パルス集計設定
// ==================================================
// 1分足で使用する。
//
// パルス幅は株価の円幅ではなく、
// 青線 jumpPressure の内部スコア差。
//
// 黄色線：
// 直近15本の5ポイント以上パルス加重値
// −
// その20本平均
//
// 紫線：
// 直近15本の15ポイント以上パルス加重値
// −
// その20本平均

pulseRollingLen = input.int(15, "パルスを見る直近本数", minval=1, maxval=120)

pulseValleyLookback = input.int(5, "直前谷を探す最大本数", minval=1, maxval=20)

smallPulseAmplitude = input.float(5.0, "小パルス 最低振幅（青線ポイント）", minval=0.0, step=1.0)

largePulseAmplitude = input.float(15.0, "大パルス 最低振幅（青線ポイント）", minval=0.0, step=1.0)

pulseOscSmaLen = input.int(20, "パルス加重値 平均期間", minval=1, maxval=100)

// 黄色線・紫線の見た目だけを拡大する。
// 計算値やピーク判定には影響しない。

pulseVisualScale = input.float(40.0, "パルス線の表示倍率", minval=1.0, step=1.0)

// ==================================================
// TOPIX短期方向線設定
// ==================================================
// 水色線：
// TOPIXの直近15本騰落率 × 表示倍率
//
// 朝の急変を一日中引きずらず、
// 現在の短期的な地合いだけを見る。
//
// 1分足で使用する場合、初期値15は直近15分。

showTopixLine = input.bool(true, "TOPIX短期方向線を表示")

topixSymbol = input.symbol("TSE:TOPIX", "TOPIX シンボル")

topixDirectionLen = input.int(15, "TOPIX方向線の比較本数", minval=1, maxval=120)

topixVisualScale = input.float(350.0, "TOPIX方向線の表示倍率", minval=1.0, step=1.0)

// ==================================================
// 黄色線ピークマーカー設定
// ==================================================
// 黄色線が直近高値から指定幅以上低下した場合、
// 直近高値をピークとして確定する。
//
// ピーク確定後は、その後の安値から指定幅以上
// 上昇するまで、次のピーク探索を再開しない。
//
// 判定には表示倍率前の生値を使用する。
// 黄色線の表示倍率を変更しても感度は変わらない。

showYellowPeakMarker = input.bool(true, "黄色線ピークマーカーを表示")

yellowPeakRetraceRaw = input.float(1.5, "黄色線ピーク確定 反落幅（生値）", minval=0.1, step=0.1)

// ==================================================
// 紫線底付近＋青線上昇マーカー設定
// ==================================================
// 紫線が過去10本より低い新安値を付けたら、
// 買い候補の待機状態へ入る。
//
// その後、青線が上向いた最初の1回だけ
// 緑色Bを表示する。
//
// 同じ安値では再表示しない。
// 紫線が新安値を更新した場合だけ、
// 次の買い候補を再び待機する。

showPurpleLowBuyMarker = input.bool(true, "紫線新安値後＋青線上昇マーカーを表示")

purpleLowLookback = input.int(10, "紫線の新安値を見る過去本数", minval=1, maxval=120)

// ==================================================
// 直近下落幅
// ==================================================

recentHigh = ta.highest(high, dropLen)

recentLow = ta.lowest(low, dropLen)

dropWidth = recentHigh - recentLow

// ==================================================
// 1分陽線戻し速度
// ==================================================

bullBody = math.max(close - open, 0.0)

bullReboundSpeed =
     dropWidth > 0.0
     ? bullBody / dropWidth * 100.0
     : 0.0

bullReboundSpeed := math.max(0.0, bullReboundSpeed)

// ==================================================
// 急戻りイベント
// ==================================================

jumpEventScore =
     bullReboundSpeed >= speedThreshold3 ? bullReboundSpeed + eventAdd3 :
     bullReboundSpeed >= speedThreshold2 ? bullReboundSpeed + eventAdd2 :
     bullReboundSpeed >= speedThreshold1 ? bullReboundSpeed + eventAdd1 :
     0.0

jumpEventScore := math.max(0.0, jumpEventScore)

// ==================================================
// 青線：急戻り累積圧力
// ==================================================

var float jumpPressure = 0.0

jumpPressure := jumpPressure * decayJump + jumpEventScore * jumpAddWeight

jumpPressure := math.max(0.0, jumpPressure)

// ==================================================
// 白線：青線平均
// ==================================================

jumpBasis = ta.sma(jumpPressure, basisLen)

// ==================================================
// 背景警戒条件
// ==================================================
// 青線・白線だけを使用する。

basisFlatOrUp = jumpBasis >= jumpBasis[1]

basisUp = jumpBasis > jumpBasis[1]

earlyWarning = jumpPressure >= earlyJumpLevel and basisFlatOrUp

mainWarning = jumpBasis >= mainBasisLevel and basisUp

color bgColor = na

if showMainBg and mainWarning
    bgColor := color.new(color.blue, mainBgTransp)
else if showEarlyBg and earlyWarning
    bgColor := color.new(color.blue, earlyBgTransp)

bgcolor(bgColor)

// ==================================================
// 青線の局所頂点とパルス振幅
// ==================================================
// 局所頂点は1本遅れて確定する。
//
// 例：
// 40 → 60 → 50
//
// 60の地点を頂点として認識する。
//
// 頂点より前の最大5本から最低値を探し、
// 頂点との差をパルス振幅とする。

enoughBars = bar_index >= pulseValleyLookback + 2

localPeak =
     enoughBars and
     jumpPressure[1] > jumpPressure[2] and
     jumpPressure[1] >= jumpPressure

priorValley = ta.lowest(jumpPressure[2], pulseValleyLookback)

pulseAmplitude =
     localPeak
     ? jumpPressure[1] - priorValley
     : 0.0

// ==================================================
// 小パルス・大パルス
// ==================================================

smallPulseEvent = localPeak and pulseAmplitude >= smallPulseAmplitude

largePulseEvent = localPeak and pulseAmplitude >= largePulseAmplitude

smallPulseValue = smallPulseEvent ? 1.0 : 0.0

largePulseValue = largePulseEvent ? 1.0 : 0.0

// ==================================================
// 日付またぎ防止
// ==================================================
// デイトレ用。
// 前日と当日のパルスを同じ窓へ混在させない。

validPulseWindow =
     bar_index >= pulseRollingLen - 1 and
     time("D") == time("D")[pulseRollingLen - 1]

// ==================================================
// 直近15本のパルス線形加重集計
// ==================================================
// 現在足の重み：15
// 1本前の重み ：14
// ...
// 14本前の重み：1
//
// 平均重みで割って、パルス数換算値にする。

f_weightedPulseCount(_pulseValue, _length) =>
    float weightedSum = 0.0

    float averageWeight = (_length + 1.0) / 2.0

    for offset = 0 to _length - 1
        float weight = _length - offset

        weightedSum += _pulseValue[offset] * weight

    weightedSum / averageWeight

smallPulseWeightedCount =
     validPulseWindow
     ? f_weightedPulseCount(smallPulseValue, pulseRollingLen)
     : na

largePulseWeightedCount =
     validPulseWindow
     ? f_weightedPulseCount(largePulseValue, pulseRollingLen)
     : na

// ==================================================
// 黄色オシレーター
// ==================================================
// 5ポイント以上の小パルス加重値
// −
// その20本平均

smallPulseWeightedSma = ta.sma(smallPulseWeightedCount, pulseOscSmaLen)

smallPulseOsc =
     not na(smallPulseWeightedCount) and
     not na(smallPulseWeightedSma)
     ? smallPulseWeightedCount - smallPulseWeightedSma
     : na

// ==================================================
// 紫オシレーター
// ==================================================
// 15ポイント以上の大パルス加重値
// −
// その20本平均

largePulseWeightedSma = ta.sma(largePulseWeightedCount, pulseOscSmaLen)

largePulseOsc =
     not na(largePulseWeightedCount) and
     not na(largePulseWeightedSma)
     ? largePulseWeightedCount - largePulseWeightedSma
     : na

// ==================================================
// TOPIX短期方向線
// ==================================================
// TOPIX短期方向線：
// （現在値 ÷ 指定本数前の値 − 1）× 100
//
// 朝の急変は、指定本数が経過すると窓から抜ける。
// 水色線の表示時だけ倍率を掛ける。
// Data Windowには倍率なしの騰落率を表示する。

topixClose =
     request.security(
          topixSymbol,
          timeframe.period,
          close,
          gaps=barmerge.gaps_off,
          lookahead=barmerge.lookahead_off)

validTopixWindow =
     bar_index >= topixDirectionLen and
     time("D") == time("D")[topixDirectionLen]

topixChangeShortPct =
     validTopixWindow and
     not na(topixClose) and
     not na(topixClose[topixDirectionLen]) and
     topixClose[topixDirectionLen] != 0.0
     ? (topixClose / topixClose[topixDirectionLen] - 1.0) * 100.0
     : na

topixDirectionPlot = topixChangeShortPct * topixVisualScale

// ==================================================
// 表示倍率
// ==================================================

smallPulseOscPlot = smallPulseOsc * pulseVisualScale

largePulseOscPlot = largePulseOsc * pulseVisualScale

// ==================================================
// 黄色線ピークマーカー
// ==================================================
// 判定には表示倍率前の smallPulseOsc を使う。
// 表示倍率を変更しても赤い▼の感度は変わらない。
//
// ヒステリシス判定：
//
// 探索中：
// ・黄色線が高値を更新している間は、
//   ピーク候補の値と位置を更新する。
// ・候補高値から指定幅以上低下したら、
//   その高値へ赤い▼を表示する。
//
// 待機中：
// ・ピーク確定後は、その後の安値を更新する。
// ・安値から指定幅以上上昇したら、
//   次のピーク探索を再開する。

var float yellowPeakCandidateRaw = na

var int yellowPeakCandidateBar = na

var float yellowResetValleyRaw = na

var bool yellowPeakSearching = true

if na(smallPulseOsc)
    yellowPeakCandidateRaw := na

    yellowPeakCandidateBar := na

    yellowResetValleyRaw := na

    yellowPeakSearching := true

else
    if yellowPeakSearching
        if na(yellowPeakCandidateRaw) or smallPulseOsc >= yellowPeakCandidateRaw
            yellowPeakCandidateRaw := smallPulseOsc

            yellowPeakCandidateBar := bar_index

        else if yellowPeakCandidateRaw - smallPulseOsc >= yellowPeakRetraceRaw
            if showYellowPeakMarker
                label.new(
                     yellowPeakCandidateBar,
                     yellowPeakCandidateRaw * pulseVisualScale,
                     "",
                     style=label.style_triangledown,
                     color=color.new(color.red, 0),
                     textcolor=color.new(color.red, 0),
                     size=size.tiny)

            yellowPeakSearching := false

            yellowResetValleyRaw := smallPulseOsc

    else
        if na(yellowResetValleyRaw) or smallPulseOsc <= yellowResetValleyRaw
            yellowResetValleyRaw := smallPulseOsc

        else if smallPulseOsc - yellowResetValleyRaw >= yellowPeakRetraceRaw
            yellowPeakSearching := true

            yellowPeakCandidateRaw := smallPulseOsc

            yellowPeakCandidateBar := bar_index

            yellowResetValleyRaw := na

// ==================================================
// 紫線新安値後＋青線上昇
// ==================================================
// 紫線が過去10本より低い新安値を付けたら、
// 買い候補の待機状態へ入る。
//
// その後、青線が上向いた最初の1回だけ
// 緑色Bを表示する。
//
// 同じ安値では再表示しない。
// 紫線が新安値を更新した場合だけ、
// 待機状態を再度ONにする。

purpleNewLow =
     not na(largePulseOsc) and
     not na(largePulseOsc[1]) and
     largePulseOsc < ta.lowest(largePulseOsc[1], purpleLowLookback)

blueRising =
     not na(jumpPressure[1]) and
     jumpPressure > jumpPressure[1]

var bool purpleLowBuyReady = false

if purpleNewLow
    purpleLowBuyReady := true

purpleLowBlueRisingSignal =
     purpleLowBuyReady and
     blueRising

if purpleLowBlueRisingSignal
    purpleLowBuyReady := false

// ==================================================
// 緑色Bマーカー表示位置
// ==================================================
// 条件成立時だけ、紫線より少し下へ表示する。
//
// 条件不成立時は必ずnaを渡す。
// location.absoluteでも、0付近へ大量表示されない。

buyMarkerY =
     showPurpleLowBuyMarker and
     purpleLowBlueRisingSignal
     ? largePulseOscPlot - 12.0
     : na

// ==================================================
// Plot
// ==================================================

// 青線：急戻り累積圧力

plot(
     jumpPressure,
     title="急戻り累積圧力",
     color=color.new(color.blue, 0),
     linewidth=3)

// 白線：青線平均

plot(
     jumpBasis,
     title="青線平均",
     color=color.new(color.white, 0),
     linewidth=2)

// 黄色線：5ポイント以上パルス加重値 − 20本平均

plot(
     smallPulseOscPlot,
     title="小パルス転換指数 5ポイント以上（表示倍率あり）",
     color=color.new(color.orange, 0),
     linewidth=3)

// 紫線：15ポイント以上パルス加重値 − 20本平均

plot(
     largePulseOscPlot,
     title="大パルス転換指数 15ポイント以上（表示倍率あり）",
     color=color.new(color.purple, 0),
     linewidth=3)

// 水色線：TOPIXの直近15本比

plot(
     showTopixLine ? topixDirectionPlot : na,
     title="TOPIX短期方向線 直近指定本数比（表示倍率あり）",
     color=color.new(color.aqua, 0),
     linewidth=2)

// 緑色B：紫線新安値後＋青線上昇
//
// location.absoluteを使用する。
// 条件不成立時はbuyMarkerYがnaなので表示しない。

plotshape(
     buyMarkerY,
     title="紫線新安値後＋青線上昇",
     style=shape.triangleup,
     location=location.absolute,
     color=color.new(color.lime, 0),
     text="B",
     textcolor=color.new(color.black, 0),
     size=size.small)

// ==================================================
// 基準線
// ==================================================
// 0   ：黄色線・紫線・TOPIX短期方向線の共通基準
// 80  ：青線の早期警戒基準
// 100 ：青線平均の本警戒基準
//
// 3本とも黒色の細線。

hline(
     0,
     "基準 0",
     color=color.new(color.black, 0),
     linestyle=hline.style_solid,
     linewidth=1)

hline(
     80,
     "青線 早期警戒 80",
     color=color.new(color.black, 0),
     linestyle=hline.style_solid,
     linewidth=1)

hline(
     100,
     "青線平均 本警戒 100",
     color=color.new(color.black, 0),
     linestyle=hline.style_solid,
     linewidth=1)

// ==================================================
// Data Window 用の生値
// ==================================================

plot(
     smallPulseWeightedCount,
     title="直近15本 小パルス加重値 5ポイント以上（生値）",
     display=display.data_window)

plot(
     smallPulseWeightedSma,
     title="小パルス加重値 20本平均（生値）",
     display=display.data_window)

plot(
     smallPulseOsc,
     title="小パルス転換指数 5ポイント以上（生値）",
     display=display.data_window)

plot(
     largePulseWeightedCount,
     title="直近15本 大パルス加重値 15ポイント以上（生値）",
     display=display.data_window)

plot(
     largePulseWeightedSma,
     title="大パルス加重値 20本平均（生値）",
     display=display.data_window)

plot(
     largePulseOsc,
     title="大パルス転換指数 15ポイント以上（生値）",
     display=display.data_window)

plot(
     pulseAmplitude,
     title="直近確定パルス振幅（青線ポイント）",
     display=display.data_window)

plot(
     topixChangeShortPct,
     title="TOPIX短期方向線 直近指定本数比 %（生値）",
     display=display.data_window)

plot(
     purpleNewLow ? 1.0 : 0.0,
     title="紫線 過去10本より低い新安値",
     display=display.data_window)

plot(
     blueRising ? 1.0 : 0.0,
     title="青線 上向き",
     display=display.data_window)

plot(
     purpleLowBlueRisingSignal ? 1.0 : 0.0,
     title="買い候補 B",
     display=display.data_window)
````
