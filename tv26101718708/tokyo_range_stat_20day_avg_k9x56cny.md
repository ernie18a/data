# Tokyo Range Stat [20-Day Avg]

- url: https://www.tradingview.com/script/K9X56cNY/
- type: indicator
- pine_id: PUB;1b933491592f4e13a1fe1550bb93dd67
- version: 1.0

## Description

English Version Overview
[Overview] Tokyo Range Stat [20-Day Avg]
This Pine Script (v5) indicator tracks the Tokyo Session Range (09:00 - 15:00 JST) in real time and compares today's range with the historical average range over a customizable period (default: 20 days).

[Key Features]
- Real-time Range Calculation: Continuously calculates today's session high-to-low range in pips as the market moves.

- Historical Average Comparison: Stores completed session ranges using dynamic arrays to measure today's performance against the multi-day average.

- Dynamic Visual Alert:

     - Green: Today's range is within the normal statistical threshold (0.5x to 1.5x of the average).

     - Red: Today's range is out of the normal threshold (unusually quiet or high volatility).

- Bilingual Support: Toggle between Japanese and English text seamlessly via the script settings.

- Flexible Chart Placement: Easily adjust text position (bar offset), font sizes, and alert colors directly from the input panel.


日本語版概要
【概要】Tokyo Range Stat [20-Day Avg]
本インジケーターは、FX市場における東京セッション（09:00〜15:00 JST）の値幅（レンジ幅）をリアルタイムで追跡し、過去指定日数（デフォルト: 20日間）の平均値幅と比較表示するPine Script（v5）インジケーターです。

【主な特徴】
- リアルタイムレンジ計算: 当日の東京セッションの高値と安値からリアルタイムにレンジ幅（pips）を計算します。

- 20日移動平均値幅との比較: 過去20日間の確定レンジを配列で保持し、平均値と本日の値幅を同一ラベル内に表示します。

- 動的ステータスカラー:

  -   今日のレンジが過去平均の 0.5倍〜1.5倍以内（正常範囲） の場合: 緑色

   -  それ以外（ボラティリティ低下または急拡大）の場合: 赤色

- 多言語対応: 設定画面から「日本語」と「English」をワンタップで切り替え可能です。

- 位置オフセット調整: チャート右端のバーからの位置（X軸オフセット）や文字サイズを自由にカスタマイズ可能です。

## Source Code

````pine
//@version=6
indicator('Tokyo Range Stat [20-Day Avg]', overlay = true)

// --- 入力パラメータ (Input Parameters) ---
var string G_TIME = '=== 東京時間設定 / Session Config ==='
i_timeFrame = input.session('0900-1500:23456', '東京時間セッション / Session Time', group = G_TIME, tooltip = '日本時間9:00〜15:00 (平日) / JST 09:00-15:00 (Weekdays)')
i_daysCount = input.int(20, '平均計算日数 / Average Days', minval = 1, group = G_TIME)

var string G_STYLE = '=== 表示・言語設定 / Display & Language Settings ==='
i_language = input.string('日本語', '表示言語 / Language', options = ['日本語', 'English'], group = G_STYLE)
i_xOffset = input.int(5, '右からのバー数オフセット / Bar Offset X', group = G_STYLE, tooltip = '最新バーから何本右(+)/左(-)にずらすか')
i_textSize = input.string(size.normal, '文字サイズ / Text Size', options = [size.small, size.normal, size.large], group = G_STYLE)
i_colorNorm = input.color(color.green, '正常範囲(0.5~1.5倍)の色 / Normal Range Color', group = G_STYLE)
i_colorAlert = input.color(color.red, '範囲外の色 / Out of Range Color', group = G_STYLE)

// --- 変数定義 (Variable Definitions) ---
var float todayHigh = na
var float todayLow = na
var float todayRange = na
var array<float> pastRanges = array.new_float(0)

// 1pipの価格幅を取得 (クロス円・ドルストレート自動判定)
pipSize = syminfo.mintick * (syminfo.type == 'forex' and syminfo.mintick == 0.001 ? 10 : syminfo.mintick == 0.00001 ? 10 : 1)

// セッション内判定
inSession = not na(time(timeframe.period, i_timeFrame))
isNewSession = inSession and not inSession[1]
isSessionEnd = not inSession and inSession[1]

// --- セッション高値・安値の更新 ---
if isNewSession
    todayHigh := high
    todayLow := low
    todayLow
else if inSession
    todayHigh := math.max(todayHigh, high)
    todayLow := math.min(todayLow, low)
    todayLow

if inSession and not na(todayHigh) and not na(todayLow)
    todayRange := (todayHigh - todayLow) / pipSize
    todayRange

// --- セッション終了時の確定処理 ---
if isSessionEnd and not na(todayHigh) and not na(todayLow)
    finalRange = (todayHigh - todayLow) / pipSize
    array.unshift(pastRanges, finalRange)
    if array.size(pastRanges) > i_daysCount
        array.pop(pastRanges)

// --- 過去N日間の平均値計算 ---
var float avgRange = na
if array.size(pastRanges) > 0
    sum = 0.0
    for i = 0 to array.size(pastRanges) - 1 by 1
        sum := sum + array.get(pastRanges, i)
        sum
    avgRange := sum / array.size(pastRanges)
    avgRange

// --- 表示テキストと言語切替ロジック (Language Selection Logic) ---
validCount = array.size(pastRanges)

var string labelText = ''
var color textColor = i_colorAlert

isJP = i_language == '日本語'

if not na(avgRange)
    todayStr = not na(todayRange) ? str.tostring(todayRange, '#.#') + ' pips' : isJP ? '未開始/データなし' : 'Not Started/No Data'

    if isJP
        labelText := '東京レンジ 今日: ' + todayStr + ' / ' + str.tostring(validCount) + '日平均: ' + str.tostring(avgRange, '#.#') + ' pips'
        labelText
    else
        labelText := 'Tokyo Range Today: ' + todayStr + ' / ' + str.tostring(validCount) + '-Day Avg: ' + str.tostring(avgRange, '#.#') + ' pips'
        labelText

    if not na(todayRange)
        ratio = todayRange / avgRange
        if ratio >= 0.5 and ratio <= 1.5
            textColor := i_colorNorm
            textColor
        else
            textColor := i_colorAlert
            textColor
else
    labelText := isJP ? 'データ計算中...' : 'Calculating Data...'
    labelText

// --- ラベルオブジェクト描画 ---
var label statsLabel = na

if barstate.islast
    label.delete(statsLabel)

    targetBarIndex = bar_index + i_xOffset

    statsLabel := label.new(x = targetBarIndex, y = high + syminfo.mintick * 50, text = labelText, color = color.new(color.black, 100), textcolor = textColor, style = label.style_label_left, size = i_textSize)
    statsLabel
````
