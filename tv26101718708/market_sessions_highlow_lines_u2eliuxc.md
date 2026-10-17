# Market Sessions & High/Low Lines

- url: https://www.tradingview.com/script/u2EliuxC/
- type: indicator
- pine_id: PUB;7613b04017b143f59f63119145d8337f
- version: 1.0

## Description

English Version Overview
[Overview] Market Sessions & High/Low Lines
This Pine Script (v5) indicator visualizes the three primary trading sessions (Asia/Tokyo, London, and New York) directly on your TradingView chart. It highlights session timeframes using transparent background colors while dynamically tracking and plotting real-time High and Low lines for each active session.

[Key Features]
- Customizable Session Backgrounds: Easily distinguish between Tokyo, London, and NY sessions with individual background colors and opacity levels.

- Dynamic High/Low Tracking: Automatically creates and updates solid horizontal lines connecting the highest and lowest price points of the active session in real time.

- Time Zone Flexibility: Defaulted to UTC+9 (JST) for convenience, but fully customizable to any timezone (e.g., UTC, EST) to match your preferred market schedule.

- Bilingual Settings: Features input menus and labels formatted for seamless navigation in both Japanese and English.


日本語版概要
【概要】Market Sessions & High/Low Lines
本インジケーターは、FX市場における3大セッション（アジア/東京、ロンドン、ニューヨーク）の時間帯をチャート上に視覚化するPine Script（v5）インジケーターです。指定された時間帯の背景色を透過シェードで色分けるとともに、各セッション内の最高値（High）および最安値（Low）ラインをリアルタイムで自動追跡・描画します。

【主な特徴】
- 背景色の個別色分け: アジア、ロンドン、NYの各時間帯ごとに背景色を指定でき、重複する時間帯もスムーズに視覚化します。

- リアルタイム高安追跡ライン: セッション開始から終了まで、その期間内の最高値・最安値をリアルタイムで追跡し、実線ラインとして延長描画します。

- 柔軟なタイムゾーン対応: 標準で日本時間（UTC+9）に最適化されていますが、お使いの環境や指定したいセッション時間に応じて自由にタイムゾーンを設定可能です。

- 多言語（日本語/英語）対応: 設定画面上の言語選択から、パラメーターラベルや各種表記を日本語・英語併記でスムーズに操作できます。

## Source Code

````pine
//@version=6
indicator('Market Sessions & High/Low Lines', overlay = true, max_lines_count = 500)

// ==========================================
// 入力設定 (Inputs)
// ==========================================
var string G_LANG = '=== 表示・言語設定 / Display & Language Settings ==='
i_language = input.string('日本語', '表示言語 / Language', options = ['日本語', 'English'], group = G_LANG)
timeZone = input.string('UTC+9', 'タイムゾーン / Time Zone', group = G_LANG, tooltip = '例 / Example: UTC+9, UTC+0, America/New_York')

// --- アジア (Asia / Tokyo) ---
var string G_ASIA = 'アジア (Asia / Tokyo) セッション'
showAsia = input.bool(true, '表示する / Show', group = G_ASIA)
asiaSession = input.session('0900-1500', '時間帯 / Timeframe', group = G_ASIA)
asiaBgColor = input.color(color.new(color.blue, 88), '背景色 / Background Color', group = G_ASIA)
asiaHighColor = input.color(color.blue, '高値ライン色 / High Line Color', group = G_ASIA)
asiaLowColor = input.color(color.blue, '安値ライン色 / Low Line Color', group = G_ASIA)

// --- ロンドン (London) ---
var string G_LON = 'ロンドン (London) セッション'
showLondon = input.bool(true, '表示する / Show', group = G_LON)
londonSession = input.session('1600-0030', '時間帯 / Timeframe', group = G_LON)
londonBgColor = input.color(color.new(color.green, 88), '背景色 / Background Color', group = G_LON)
londonHighColor = input.color(color.green, '高値ライン色 / High Line Color', group = G_LON)
londonLowColor = input.color(color.green, '安値ライン色 / Low Line Color', group = G_LON)

// --- ニューヨーク (New York) ---
var string G_NY = 'ニューヨーク (NY / New York) セッション'
showNY = input.bool(true, '表示する / Show', group = G_NY)
nySession = input.session('2130-0500', '時間帯 / Timeframe', group = G_NY)
nyBgColor = input.color(color.new(color.red, 88), '背景色 / Background Color', group = G_NY)
nyHighColor = input.color(color.red, '高値ライン色 / High Line Color', group = G_NY)
nyLowColor = input.color(color.red, '安値ライン色 / Low Line Color', group = G_NY)

// ==========================================
// セッション判定と高値・安値追跡関数
// ==========================================
f_session_tracker(bool show, string sessStr, color bgColor, color hColor, color lColor) =>
    inSession = show and not na(time(timeframe.period, sessStr, timeZone))

    var float sessHigh = na
    var float sessLow = na
    var line highLine = na
    var line lowLine = na

    // セッション開始時
    if inSession and not inSession[1]
        sessHigh := high
        sessLow := low
        // ラインの新規作成
        highLine := line.new(bar_index, sessHigh, bar_index, sessHigh, color = hColor, width = 2)
        lowLine := line.new(bar_index, sessLow, bar_index, sessLow, color = lColor, width = 2)
        lowLine

    // セッション期間中
    else if inSession
        sessHigh := math.max(sessHigh, high)
        sessLow := math.min(sessLow, low)

        // 高値・安値の更新とラインの右方向へ延長
        line.set_y1(highLine, sessHigh)
        line.set_y2(highLine, sessHigh)
        line.set_x2(highLine, bar_index)

        line.set_y1(lowLine, sessLow)
        line.set_y2(lowLine, sessLow)
        line.set_x2(lowLine, bar_index)

    inSession ? bgColor : na

// ==========================================
// 実行・描画処理
// ==========================================
c_asia = f_session_tracker(showAsia, asiaSession, asiaBgColor, asiaHighColor, asiaLowColor)
c_london = f_session_tracker(showLondon, londonSession, londonBgColor, londonHighColor, londonLowColor)
c_ny = f_session_tracker(showNY, nySession, nyBgColor, nyHighColor, nyLowColor)

// 背景色の着色 (重ね合わせ対応)
bgcolor(c_asia)
bgcolor(c_london)
bgcolor(c_ny)
````
