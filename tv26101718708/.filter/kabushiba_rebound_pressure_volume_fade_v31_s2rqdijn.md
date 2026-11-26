# Kabushiba Rebound Pressure & Volume Fade V3.1

- url: https://www.tradingview.com/script/S2RqDIJN/
- type: indicator
- pine_id: PUB;2e79b9d0030b4453bb338322a9e56a23
- version: 3.0

## Description

出来高変化追加版

## Source Code

````pine
//@version=6
indicator(
     "Rebound Pressure with Volume Fade",
     overlay=false,
     max_bars_back=500)

// ==================================================
// 基本設定
// ==================================================

dropLen =
     input.int(
          20,
          "直近下落幅を見る本数",
          minval=5)

decayJump =
     input.float(
          0.90,
          "急戻り累積 減衰",
          minval=0.50,
          maxval=0.99,
          step=0.01)

jumpAddWeight =
     input.float(
          1.00,
          "急戻り累積 加算係数",
          minval=0.10,
          step=0.10)

speedThreshold1 =
     input.float(
          8.0,
          "急戻り判定1",
          minval=0.0,
          step=1.0)

speedThreshold2 =
     input.float(
          15.0,
          "急戻り判定2",
          minval=0.0,
          step=1.0)

speedThreshold3 =
     input.float(
          25.0,
          "急戻り判定3",
          minval=0.0,
          step=1.0)

eventAdd1 =
     input.float(
          10.0,
          "急戻り1 加点",
          minval=0.0,
          step=1.0)

eventAdd2 =
     input.float(
          20.0,
          "急戻り2 加点",
          minval=0.0,
          step=1.0)

eventAdd3 =
     input.float(
          35.0,
          "急戻り3 加点",
          minval=0.0,
          step=1.0)

// ==================================================
// 白線設定
// ==================================================

basisLen =
     input.int(
          20,
          "急戻り累積圧力 平均期間",
          minval=5)

// ==================================================
// 背景表示設定
// ==================================================
// 早期警戒：
// 急戻り累積圧力が80以上
// かつ
// 白線が横ばい以上
//
// 本警戒：
// 白線が100以上
// かつ
// 白線が上向き
//
// 紫線・出来高細り指数は、
// 背景色の条件に使用しない。

showEarlyBg =
     input.bool(
          true,
          "早期警戒背景を表示")

showMainBg =
     input.bool(
          true,
          "本警戒背景を表示")

earlyJumpLevel =
     input.float(
          80.0,
          "早期警戒 急戻り累積圧力基準",
          minval=0.0,
          step=5.0)

mainBasisLevel =
     input.float(
          100.0,
          "本警戒 白線基準",
          minval=0.0,
          step=5.0)

earlyBgTransp =
     input.int(
          92,
          "早期警戒 背景透明度",
          minval=0,
          maxval=100)

mainBgTransp =
     input.int(
          86,
          "本警戒 背景透明度",
          minval=0,
          maxval=100)

// ==================================================
// 紫線設定
// ==================================================
// 紫線：
// 直近15本の15ポイント以上パルス加重値
// −
// その20本平均
//
// 表示時に100を加えて、
// 100基準の線として表示する。
//
// 黄色線は計算・表示ともに使用しない。

pulseRollingLen =
     input.int(
          15,
          "パルスを見る直近本数",
          minval=1,
          maxval=120)

pulseValleyLookback =
     input.int(
          5,
          "直前谷を探す最大本数",
          minval=1,
          maxval=20)

largePulseAmplitude =
     input.float(
          15.0,
          "大パルス 最低振幅（急戻り累積圧力ポイント）",
          minval=0.0,
          step=1.0)

pulseOscSmaLen =
     input.int(
          20,
          "大パルス加重値 平均期間",
          minval=1,
          maxval=100)

purpleVisualScale =
     input.float(
          5.0,
          "紫線の表示倍率",
          minval=1.0,
          step=1.0)

purpleLineWidth =
     input.int(
          1,
          "紫線の太さ",
          minval=1,
          maxval=4)

// ==================================================
// 出来高細り指数設定
// ==================================================
// 出来高細り指数：
// 出来高WMA5
// ÷
// 出来高WMA20
// × 100
//
// 100より上：
// 直近出来高が基準より多い。
//
// 100より下：
// 直近出来高が基準より細っている。
//
// 表示色はオレンジ。
// 初期状態では細線。

showVolumeThinLine =
     input.bool(
          true,
          "出来高細り指数を表示")

volumeShortLen =
     input.int(
          5,
          "出来高短期WMA期間",
          minval=1,
          maxval=60)

volumeBaseLen =
     input.int(
          20,
          "出来高基準WMA期間",
          minval=2,
          maxval=120)

volumeThinLineWidth =
     input.int(
          1,
          "出来高細り指数の太さ",
          minval=1,
          maxval=4)

// ==================================================
// 急戻り累積圧力の色分け設定
// ==================================================
// 出来高細り指数が105より上：赤
// 出来高細り指数が95より下 ：緑
// 95以上105以下               ：灰
//
// 出来高細り指数の傾きは使わない。
// 現在の水準だけで色を切り替える。

volumeHighLevel =
     input.float(
          105.0,
          "出来高増加判定水準",
          minval=0.0,
          step=1.0)

volumeLowLevel =
     input.float(
          95.0,
          "出来高細り判定水準",
          minval=0.0,
          step=1.0)

// ==================================================
// 直近下落幅
// ==================================================

recentHigh =
     ta.highest(
          high,
          dropLen)

recentLow =
     ta.lowest(
          low,
          dropLen)

dropWidth =
     recentHigh - recentLow

// ==================================================
// 1分陽線戻し速度
// ==================================================

bullBody =
     math.max(
          close - open,
          0.0)

bullReboundSpeed =
     dropWidth > 0.0
     ? bullBody / dropWidth * 100.0
     : 0.0

bullReboundSpeed :=
     math.max(
          0.0,
          bullReboundSpeed)

// ==================================================
// 急戻りイベント
// ==================================================

jumpEventScore =
     bullReboundSpeed >= speedThreshold3
     ? bullReboundSpeed + eventAdd3
     : bullReboundSpeed >= speedThreshold2
     ? bullReboundSpeed + eventAdd2
     : bullReboundSpeed >= speedThreshold1
     ? bullReboundSpeed + eventAdd1
     : 0.0

jumpEventScore :=
     math.max(
          0.0,
          jumpEventScore)

// ==================================================
// 急戻り累積圧力
// ==================================================

var float jumpPressure = 0.0

jumpPressure :=
     jumpPressure * decayJump
     + jumpEventScore * jumpAddWeight

jumpPressure :=
     math.max(
          0.0,
          jumpPressure)

// ==================================================
// 白線：急戻り累積圧力の平均
// ==================================================

jumpBasis =
     ta.sma(
          jumpPressure,
          basisLen)

// ==================================================
// 背景警戒条件
// ==================================================

basisFlatOrUp =
     jumpBasis >= jumpBasis[1]

basisUp =
     jumpBasis > jumpBasis[1]

earlyWarning =
     jumpPressure >= earlyJumpLevel
     and basisFlatOrUp

mainWarning =
     jumpBasis >= mainBasisLevel
     and basisUp

color bgColor = na

if showMainBg and mainWarning
    bgColor :=
         color.new(
              color.blue,
              mainBgTransp)

else if showEarlyBg and earlyWarning
    bgColor :=
         color.new(
              color.blue,
              earlyBgTransp)

bgcolor(
     bgColor)

// ==================================================
// 急戻り累積圧力の局所頂点とパルス振幅
// ==================================================
// 局所頂点は1本遅れて確定する。
//
// 例：
// 40 → 60 → 50
//
// 60を頂点として認識する。
// 頂点より前の最大5本から最低値を探し、
// 頂点との差をパルス振幅とする。

enoughBars =
     bar_index >= pulseValleyLookback + 2

localPeak =
     enoughBars
     and jumpPressure[1] > jumpPressure[2]
     and jumpPressure[1] >= jumpPressure

priorValley =
     ta.lowest(
          jumpPressure[2],
          pulseValleyLookback)

pulseAmplitude =
     localPeak
     ? jumpPressure[1] - priorValley
     : 0.0

// ==================================================
// 大パルス判定
// ==================================================

largePulseEvent =
     localPeak
     and pulseAmplitude >= largePulseAmplitude

largePulseValue =
     largePulseEvent
     ? 1.0
     : 0.0

// ==================================================
// 日付またぎ防止
// ==================================================
// デイトレ用。
// 前日と当日のパルスを同じ窓へ混在させない。

validPulseWindow =
     bar_index >= pulseRollingLen - 1
     and time("D") == time("D")[pulseRollingLen - 1]

// ==================================================
// 直近15本のパルス線形加重集計
// ==================================================
// 現在足の重み：15
// 1本前の重み ：14
// ...
// 14本前の重み：1
//
// 平均重みで割って、
// パルス数換算値にする。

f_weightedPulseCount(
     _pulseValue,
     _length) =>

    float weightedSum = 0.0

    float averageWeight =
         (_length + 1.0) / 2.0

    for offset = 0 to _length - 1
        float weight =
             _length - offset

        weightedSum +=
             _pulseValue[offset] * weight

    weightedSum / averageWeight

largePulseWeightedCount =
     validPulseWindow
     ? f_weightedPulseCount(
          largePulseValue,
          pulseRollingLen)
     : na

// ==================================================
// 紫オシレーター
// ==================================================
// 15ポイント以上の大パルス加重値
// −
// その20本平均
//
// 表示時だけ、
// 100 ＋ 生値 × 表示倍率
// とする。

largePulseWeightedSma =
     ta.sma(
          largePulseWeightedCount,
          pulseOscSmaLen)

largePulseOsc =
     not na(largePulseWeightedCount)
     and not na(largePulseWeightedSma)
     ? largePulseWeightedCount - largePulseWeightedSma
     : na

purpleLine =
     not na(largePulseOsc)
     ? 100.0 + largePulseOsc * purpleVisualScale
     : na

// ==================================================
// 出来高細り指数
// ==================================================
// 出来高WMA5
// ÷
// 出来高WMA20
// × 100

volumeShortWma =
     ta.wma(
          volume,
          volumeShortLen)

volumeBaseWma =
     ta.wma(
          volume,
          volumeBaseLen)

volumeThinIndex =
     not na(volumeShortWma)
     and not na(volumeBaseWma)
     and volumeBaseWma > 0.0
     ? volumeShortWma / volumeBaseWma * 100.0
     : na

// ==================================================
// 急戻り累積圧力線の表示色
// ==================================================
// 出来高細り指数が105より上：赤
// 出来高細り指数が95より下 ：緑
// 95以上105以下               ：灰
//
// 傾きではなく、現在の水準だけを見る。

volumeExpanded =
     not na(volumeThinIndex)
     and volumeThinIndex > volumeHighLevel

volumeThinned =
     not na(volumeThinIndex)
     and volumeThinIndex < volumeLowLevel

color jumpPressureColor =
     color.new(
          color.gray,
          0)

if volumeExpanded
    jumpPressureColor :=
         color.new(
              color.red,
              0)

else if volumeThinned
    jumpPressureColor :=
         color.new(
              color.lime,
              0)

else
    jumpPressureColor :=
         color.new(
              color.gray,
              0)

// ==================================================
// Plot
// ==================================================

// 急戻り累積圧力
//
// 赤：
// 出来高細り指数が105より上
//
// 緑：
// 出来高細り指数が95より下
//
// 灰：
// 出来高細り指数が95以上105以下

plot(
     jumpPressure,
     title="急戻り累積圧力",
     color=jumpPressureColor,
     linewidth=3)

// 白線：急戻り累積圧力の平均

plot(
     jumpBasis,
     title="急戻り累積圧力 平均",
     color=color.new(
          color.white,
          0),
     linewidth=2)

// 紫線：大パルス転換指数
// 100基準。
// 初期状態では細線。

plot(
     purpleLine,
     title="大パルス転換指数 15ポイント以上（100基準）",
     color=color.new(
          color.purple,
          0),
     linewidth=purpleLineWidth)

// オレンジ線：出来高細り指数
// 100基準。
// 初期状態では細線。

plot(
     showVolumeThinLine
     ? volumeThinIndex
     : na,
     title="出来高細り指数 WMA5 ÷ WMA20 × 100",
     color=color.new(
          color.orange,
          0),
     linewidth=volumeThinLineWidth)

// ==================================================
// 基準線
// ==================================================
// 80：
// 急戻り累積圧力の早期警戒基準
//
// 100：
// 白線の本警戒基準
// 紫線の基準
// 出来高細り指数の通常水準

hline(
     80,
     "急戻り累積圧力 早期警戒 80",
     color=color.new(
          color.black,
          0),
     linestyle=hline.style_solid,
     linewidth=1)

hline(
     100,
     "基準 100",
     color=color.new(
          color.black,
          0),
     linestyle=hline.style_solid,
     linewidth=1)

// ==================================================
// Data Window 用の生値
// ==================================================

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
     title="直近確定パルス振幅（急戻り累積圧力ポイント）",
     display=display.data_window)

plot(
     volumeShortWma,
     title="出来高 短期WMA（生値）",
     display=display.data_window)

plot(
     volumeBaseWma,
     title="出来高 基準WMA（生値）",
     display=display.data_window)

plot(
     volumeThinIndex,
     title="出来高細り指数 WMA5 ÷ WMA20 × 100（生値）",
     display=display.data_window)

plot(
     volumeExpanded
     ? 1.0
     : 0.0,
     title="出来高増加水準 105より上",
     display=display.data_window)

plot(
     volumeThinned
     ? 1.0
     : 0.0,
     title="出来高細り水準 95より下",
     display=display.data_window)
````
