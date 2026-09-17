<!-- tradingview-pine-id: PUB;b24619fc43404bf68a5ff0f7802e8f16 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 5-Day Rolling SMA 1m + Trend Alignment Band

Source: https://www.tradingview.com/script/8Ib8rzyc/

## Description

5-Day Rolling SMA 1m + Trend Alignment Band

This indicator displays a rolling multi-day Simple Moving Average calculated from 1-minute closing prices, together with a three-state Trend Alignment Band.

It is designed to provide a continuous view of short-term market direction across intraday chart timeframes.

Concept

A conventional 5-day SMA calculated on a daily chart averages only five daily closing prices.

This indicator uses a different approach. It calculates the average from all 1-minute closing prices contained in approximately five regular trading sessions.

For a U.S. stock or ETF with a 390-minute regular trading session:

390 minutes x 5 trading days = 1,950 one-minute bars

The default 5-day calculation is therefore approximately equivalent to:

SMA = Sum of the last 1,950 one-minute closes / 1,950

However, the script does not assume that every market has exactly 390 one-minute bars per trading day.

Instead, it measures the actual number of 1-minute bars in recent completed trading sessions. It then uses the median session length to estimate the typical number of bars per day.

The rolling window is calculated as:

Rolling Window = Typical 1-minute bars per session x Rolling Days

Using the median helps reduce the influence of shortened or unusual trading sessions.

Why use 1-minute data?

Using 1-minute data allows the multi-day average to move continuously instead of behaving like a daily moving average projected onto an intraday chart.

On a 1-minute chart, the rolling SMA can update every minute as:

one new 1-minute close enters the calculation;
the oldest observation leaves the rolling window.

On higher chart timeframes, the same internally calculated 1-minute rolling SMA is sampled onto the selected chart timeframe.

The purpose is not to reproduce a conventional 5-period daily SMA. It is to represent the average location of intraday prices over approximately the most recent five trading sessions.

Trend Alignment Band

The area between price and the rolling SMA is colored according to the relationship between price and the direction of the SMA.

Green - Bullish Alignment

Green appears when:

Price is above the rolling SMA.
The rolling SMA is rising.

Condition:

Price > SMA AND SMA(t) > SMA(t-1)

This indicates that price location and short-term trend direction are aligned upward.

Red - Bearish Alignment

Red appears when:

Price is below the rolling SMA.
The rolling SMA is falling.

Condition:

Price < SMA AND SMA(t) < SMA(t-1)

This indicates that price location and short-term trend direction are aligned downward.

Yellow - Transition / Conflict

Yellow appears when the two conditions are not aligned.

Examples include:

Price moves above the SMA while the SMA is still falling.
Price moves below the SMA while the SMA is still rising.
The SMA is flat.

Yellow should therefore not automatically be interpreted as a ranging market. It represents disagreement between current price location and the direction of the rolling average, which can occur during transitions, pullbacks, reversals, or consolidation.

Intended Use

The indicator is intended primarily as a short-term market-regime and directional context tool rather than as a standalone entry signal.

Possible uses include:

Identifying short-term directional bias.
Distinguishing aligned trends from transition phases.
Providing context for pullbacks and rallies.
Comparing current price with the average intraday price location of recent trading sessions.
Maintaining a consistent short-term reference when moving between intraday chart timeframes.

The three band states can be interpreted as:

Green = bullish alignment
Red = bearish alignment
Yellow = transition or directional conflict

These states are descriptive, not predictive, and should not be treated as automatic buy or sell signals.

Original Features

The script differs from a standard daily SMA or a fixed-length intraday SMA in several ways:

The moving average is calculated internally from 1-minute closing prices.
The script automatically measures the typical number of 1-minute bars in recent completed sessions.
The median session length is used to reduce sensitivity to shortened or irregular trading days.
The rolling period is automatically constructed from the detected session length and selected number of trading days.
The Trend Alignment Band combines both price position and SMA direction instead of using a simple price/SMA crossover alone.

This allows the indicator to adapt its multi-day rolling window to different symbols and trading-session structures without relying on a permanently fixed 1,950-bar setting.

Settings

Show 5-Day Rolling SMA
Shows or hides the rolling SMA line.

Show Trend Alignment Band
Shows or hides the colored area between price and the rolling SMA. Enabled by default.

SMA Line Width
Adjusts the thickness of the SMA.

SMA Color
Default: orange.

Band Transparency
Controls the transparency of the colored trend band.

Bullish Band / Bearish Band / Transition Band
Allows customization of the green, red, and yellow states.

Rolling Days
Default: 5 trading days.

Session Detection Days
Controls how many completed sessions are used when estimating the typical number of 1-minute bars per trading day.

Session

Regular: Uses the symbol's regular trading session.

All: Uses the available session data for the symbol.

For U.S. stocks and ETFs, Regular is the intended default.

Limitations

This is not the same calculation as a conventional 5-period SMA on a daily chart.

The indicator averages 1-minute closing-price observations, so it is better interpreted as a rolling intraday time-sampled price average over approximately the selected number of trading days.

Results can vary depending on:

the symbol's trading-session structure;
Regular versus All session selection;
holidays and shortened trading sessions;
the amount of 1-minute historical data available from the data provider;
the chart timeframe on which the internally calculated series is sampled.

A sufficient amount of historical intraday data is required before the script can determine the normal session length and calculate the full rolling window.

This indicator does not predict future prices and does not generate guaranteed trading signals. It should be used together with price structure, support/resistance, volume analysis, risk management, or other independent forms of analysis.

日本語説明

このインジケーターは、**直近の複数営業日相当の1分足終値から計算するローリングSMA（単純移動平均線）**と、価格とSMAの状態を3色で表すTrend Alignment Bandを表示します。

一般的な日足5SMAとは計算方法が異なります。

通常の日足5SMAは、

直近5本の日足終値の平均

ですが、本インジケーターは直近約5営業日に含まれる1分足終値を連続的に平均します。

米国株・ETFの通常取引時間が1日390分の場合、

390分 × 5営業日 = 1,950本

となるため、デフォルト設定では概ね1分足1950期間SMAに相当します。

1日のバー数を自動判定

このインジケーターでは、1日のバー数を390本と固定していません。

過去の完了した取引日について実際の1分足本数を計測し、その中央値から通常の1営業日あたりのバー数を推定します。

計算期間は、

ローリング本数 = 1営業日の代表的な1分足本数 × ローリング日数

として自動的に決定されます。

中央値を使用することで、短縮取引日などの特殊なセッションの影響を受けにくくしています。

1分足を使用する理由

日足5SMAをそのままイントラデイチャートへ表示すると、日ごとに値が切り替わるため階段状になります。

本インジケーターでは内部計算を1分足で行うため、1分足チャートでは新しい1分足が形成されるごとにローリング平均が更新されます。

したがって、通常の日足5SMAよりも連続的に、直近数営業日における価格の平均的な位置を表現できます。

上位時間足では、この1分足で計算されたRolling SMAを各チャート時間足へサンプリングして表示します。

Trend Alignment Band

価格とRolling SMAとの間を、価格の位置とSMAの方向に応じて3色に分類します。

緑 - Bullish Alignment

以下の2条件が同時に成立した状態です。

価格がSMAより上
SMAが上向き

Price > SMA かつ SMA(t) > SMA(t-1)

価格と短期トレンドの方向が上方向に一致している状態を示します。

赤 - Bearish Alignment

以下の2条件が同時に成立した状態です。

価格がSMAより下
SMAが下向き

Price < SMA かつ SMA(t) < SMA(t-1)

価格と短期トレンドの方向が下方向に一致している状態を示します。

黄 - Transition / Conflict

価格とSMAの方向が一致していない状態です。

代表例：

価格はSMAを上回ったが、SMAはまだ下降している
価格はSMAを下回ったが、SMAはまだ上昇している
SMAが横ばい

したがって黄色は単純な「レンジ」を意味するものではありません。

価格の位置と短期平均の方向に不一致が生じている状態であり、転換、押し・戻し、反転、持ち合いなどで発生します。

基本的な使い方

本インジケーターは直接的な売買シグナルではなく、短期的な相場環境と方向性を把握するためのツールとして設計しています。

基本的には、

緑 = 上昇方向への整合
赤 = 下降方向への整合
黄 = 移行状態または方向の不一致

として使用します。

価格が単にSMAの上か下かだけではなく、SMA自体の方向も同時に判定することが特徴です。

本インジケーター独自の特徴

一般的な日足SMAや固定期間のイントラデイSMAと比較して、以下の特徴があります。

1分足終値を内部計算に使用
1営業日の実際の1分足本数を自動計測
過去セッションの中央値によって通常のセッション長を推定
セッション長 × 日数からローリング期間を自動設定
価格のSMAに対する位置とSMAの方向を組み合わせて3色の状態を表示

これにより、1950本などの固定値をすべての銘柄に適用するのではなく、銘柄ごとの取引セッションに応じた複数日Rolling SMAを構成します。

設定

Show 5-Day Rolling SMA
Rolling SMAの表示・非表示。

Show Trend Alignment Band
Trend Bandの表示・非表示。デフォルトはON。

SMA Line Width
SMAの太さ。

SMA Color
デフォルトはオレンジ。

Band Transparency
帯の透明度。

Bullish / Bearish / Transition Band
緑・赤・黄色を個別に変更できます。

Rolling Days
デフォルト5営業日。

Session Detection Days
通常の1営業日の1分足本数を判定するために使用する過去セッション数。

Session

Regular：通常取引時間のみ
All：取得可能なセッションデータを使用

米国株・ETFではRegularを基本設定として想定しています。

通常の日足5SMAとの違い

通常の日足5SMAは、5本の日足終値を平均します。

本インジケーターは、直近約5営業日に含まれる大量の1分足終値を平均します。

したがって、両者は「5日」という時間範囲を扱っていても同じ指標ではありません。

本インジケーターは、直近数営業日において価格が平均的にどの水準に滞在していたかを連続的に表現することを目的としています。

制約・注意事項

計算結果は以下の要因によって変化する場合があります。

銘柄ごとの取引時間
Regular / All の選択
祝日や短縮取引
TradingView側で利用可能な1分足履歴
表示しているチャート時間足

十分な1分足履歴が存在しない場合、通常のセッション長および完全なローリング期間を計算できるまでSMAが表示されない場合があります。

また、本インジケーターは将来の価格を予測するものではなく、売買結果を保証するものでもありません。価格構造、支持抵抗、出来高、リスク管理など、他の分析と組み合わせて使用してください。

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © Ginzo

//@version=6
indicator(
     "5-Day Rolling SMA 1m + Trend Alignment Band",
     shorttitle="5D-SMA1m",
     overlay=true
     )

//====================================================
// DISPLAY SETTINGS
//====================================================

showSMA = input.bool(
     true,
     "Show 5-Day Rolling SMA",
     group="Display"
     )

showBand = input.bool(
     true,
     "Show Trend Alignment Band",
     group="Display",
     tooltip="Fills the area between price and the rolling SMA according to trend alignment."
     )

lineWidth = input.int(
     3,
     "SMA Line Width",
     minval=1,
     maxval=5,
     group="Display"
     )

smaColor = input.color(
     #FF9800,
     "SMA Color",
     group="Display"
     )

//====================================================
// BAND SETTINGS
//====================================================

bandTransparency = input.int(
     82,
     "Band Transparency",
     minval=0,
     maxval=100,
     group="Band",
     tooltip="Higher values make the band more transparent."
     )

greenBand = input.color(
     #4CAF50,
     "Bullish Band",
     group="Band"
     )

redBand = input.color(
     #F44336,
     "Bearish Band",
     group="Band"
     )

yellowBand = input.color(
     #FFC107,
     "Transition Band",
     group="Band"
     )

//====================================================
// CALCULATION SETTINGS
//====================================================

// Internal calculation timeframe is fixed at 1 minute.
string calcTF = "1"

rollingDays = input.int(
     5,
     "Rolling Days",
     minval=1,
     maxval=20,
     group="Calculation",
     tooltip="Number of trading days represented by the rolling SMA."
     )

detectDays = input.int(
     10,
     "Session Detection Days",
     minval=5,
     maxval=30,
     group="Calculation",
     tooltip="Number of completed trading days used to estimate the typical number of 1-minute bars per session."
     )

sessionMode = input.string(
     "Regular",
     "Session",
     options=["Regular", "All"],
     group="Calculation",
     tooltip="Regular uses the symbol's regular trading session. All uses the available session data for the symbol."
     )

//====================================================
// CALCULATION TICKER
//====================================================

string regularTicker = ticker.new(
     syminfo.prefix,
     syminfo.ticker,
     session.regular
     )

string calcTicker =
     sessionMode == "Regular"
     ? regularTicker
     : syminfo.tickerid

//====================================================
// 1-MINUTE ROLLING SMA CALCULATION
//====================================================

f_calc(int _rollingDays, int _detectDays) =>

    int tradingDay = time_tradingday

    var int activeDay = na
    var int barsToday = 0

    var array<int> dayCounts = array.new_int()

    var int barsPerDay = na

    // ------------------------------------------------
    // Count actual 1-minute bars in each completed
    // trading session.
    // ------------------------------------------------

    if na(activeDay)

        activeDay := tradingDay
        barsToday := 1

    else if tradingDay == activeDay

        barsToday += 1

    else

        // Store the completed session's bar count.
        array.push(
             dayCounts,
             barsToday
             )

        // Keep only the requested detection sample.
        if array.size(dayCounts) > _detectDays
            array.shift(dayCounts)

        // Use the median to reduce the influence of
        // shortened or unusual trading sessions.
        if array.size(dayCounts) >= 5

            barsPerDay :=
                 int(
                     math.round(
                         array.median(dayCounts)
                         )
                     )

        // Start counting the new trading session.
        activeDay := tradingDay
        barsToday := 1

    // ------------------------------------------------
    // Dynamic rolling window
    // ------------------------------------------------

    int windowBars = na

    if not na(barsPerDay)

        windowBars :=
             barsPerDay *
             _rollingDays

    // ------------------------------------------------
    // Rolling SMA calculated from 1-minute closes
    // ------------------------------------------------

    float rollingAverage = na

    if not na(windowBars)

        rollingAverage :=
             ta.sma(
                 close,
                 windowBars
                 )

    [
         rollingAverage,
         barsPerDay,
         windowBars
     ]

//====================================================
// REQUEST 1-MINUTE CALCULATION
//====================================================

[rollingSMA, detectedBars, rollingWindow] = request.security(
     calcTicker,
     calcTF,
     f_calc(
         rollingDays,
         detectDays
         ),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
     )

//====================================================
// TREND ALIGNMENT LOGIC
//====================================================

// SMA direction
bool smaRising =
     rollingSMA > rollingSMA[1]

bool smaFalling =
     rollingSMA < rollingSMA[1]

// Price position relative to SMA
bool priceAbove =
     close > rollingSMA

bool priceBelow =
     close < rollingSMA

// Bullish alignment:
// Price above SMA + SMA rising
bool bullishAlignment =
     priceAbove and
     smaRising

// Bearish alignment:
// Price below SMA + SMA falling
bool bearishAlignment =
     priceBelow and
     smaFalling

// All other combinations are treated as
// transition / directional conflict.
color bandColor =
     bullishAlignment
     ? color.new(
         greenBand,
         bandTransparency
         )
     : bearishAlignment
     ? color.new(
         redBand,
         bandTransparency
         )
     : color.new(
         yellowBand,
         bandTransparency
         )

//====================================================
// SMA PLOT
//====================================================

plot(
     showSMA ? rollingSMA : na,
     title="5-Day 1m Rolling SMA",
     color=smaColor,
     linewidth=lineWidth
     )

//====================================================
// HIDDEN PLOTS USED ONLY FOR BAND FILL
//====================================================

// Separate hidden plots allow the band and SMA line
// to be enabled or disabled independently.

bandSMAPlot = plot(
     rollingSMA,
     title="SMA Band Reference",
     display=display.none
     )

priceBandPlot = plot(
     close,
     title="Price Band Reference",
     display=display.none
     )

//====================================================
// TREND ALIGNMENT BAND
//====================================================

fill(
     priceBandPlot,
     bandSMAPlot,
     color=showBand ? bandColor : na,
     title="Trend Alignment Band"
     )

//====================================================
// DATA WINDOW DIAGNOSTICS
//====================================================

plot(
     detectedBars,
     title="Detected 1m Bars Per Day",
     display=display.data_window
     )

plot(
     rollingWindow,
     title="Rolling Window Bars",
     display=display.data_window
     )
````
