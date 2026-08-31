<!-- tradingview-pine-id: PUB;e62011c6c49b435b80659f158bf05fab -->
<!-- tradingviewscripts-format: 1 -->
# Advanced RVOL Timed Buy Candidate

Source: https://www.tradingview.com/script/oqW8Eo13/

## Description

## Advanced RVOL Timed Buy Candidate

このインジケーターは、日足を対象に、通常よりも出来高が増えている銘柄を検出するための相対出来高（RVOL）インジケーターです。

単純に当日の出来高を見るだけではなく、指定時刻までの出来高進捗率から1日の推定出来高を計算し、引け前や午前中など、ユーザーが設定した時刻に購入候補を通知できます。

### 主な特徴

#### 1. 現在足を除外した平均出来高

現在進行中の日足を平均計算に含めず、過去の確定済み出来高と比較します。

これにより、当日の大きな出来高によって平均値そのものが上昇し、出来高増加の検出が遅れる問題を軽減します。

平均期間は以下から選択できます。

* 任意の日数
* 月初から
* 四半期初から
* 年初来
* 決算発表後

データ数が不足している場合は、任意日数の移動平均へ自動的に切り替えることもできます。

#### 2. 相対出来高（RVOL）の表示

当日の出来高を平均出来高で割り、通常時と比較して何倍の出来高が発生しているかを表示します。

例：

* RVOL 1.00倍：平均と同程度
* RVOL 1.50倍：平均の1.5倍
* RVOL 2.00倍：平均の2倍

オシレーターでは、平均出来高を0％として表示します。

* 0％：平均と同じ
* ＋50％：平均の1.5倍
* ＋100％：平均の2倍

#### 3. 指定時刻での推定RVOL判定

最大2つの途中判定時刻を設定できます。

例：

* 10:00時点
* 15:24時点

それぞれの時刻について、「通常はその時刻までに1日の出来高の何％が消化されるか」を設定します。

例として、平均1日出来高が100万株、10:00までの通常進捗率を30％と設定し、10:00時点で45万株の出来高がある場合、推定RVOLは次のようになります。

45万株 ÷（100万株 × 30％）＝1.50倍

この機能により、日足の確定を待たずに、出来高ペースが通常より速い銘柄を検出できます。

#### 4. 決算フィルター

決算発表日や決算直後は、通常とは異なる大きな出来高が発生しやすいため、購入候補から除外できます。

除外する営業日数は設定可能です。

* 0：決算日のみ除外
* 1：決算日と翌営業日を除外
* 2：決算日とその後2営業日を除外

決算日には「E」マークを表示でき、除外期間の背景色も設定できます。

#### 5. 価格条件フィルター

出来高だけでは、買いによる上昇と売りによる急落を区別できません。

そのため、以下の価格条件を任意で追加できます。

* 陽線であること
* 終値が当日の値幅上部にあること
* 直近高値を終値で突破していること

「終値位置」は、その日の安値から高値までの範囲内で、終値がどこにあるかを表します。

70％に設定した場合、終値が当日の値幅の上位30％以内にあることが必要です。

#### 6. アラート

以下のアラートを利用できます。

* 途中判定1の購入候補
* 途中判定2の購入候補
* 日足確定時の購入候補

途中判定アラートを使用する場合、TradingViewのアラート頻度は「バーにつき1回」に設定してください。

スクリプトや設定を変更した場合は、既存のアラートを削除して再作成する必要があります。

### 推奨初期設定

* チャート：日足
* 平均出来高：過去20日
* 購入候補基準：平均の150％
* 特大出来高基準：平均の200％
* 陽線条件：オン
* 終値位置：70％
* 高値突破条件：オフ
* 決算後の除外日数：1営業日
* 途中判定1：10:00
* 10:00までの出来高進捗率：30％
* 途中判定2：15:24
* 15:24までの出来高進捗率：90％

出来高の時間帯別分布は銘柄によって異なるため、進捗率は対象銘柄や市場に合わせて調整してください。

### 注意事項

このインジケーターは日足での使用を前提としています。

指定時刻のアラートは、時刻だけで自動実行されるものではありません。TradingViewが新しい価格または出来高データを受信した時点でスクリプトが再計算されます。

そのため、売買が少ない銘柄では、指定時刻ちょうどに通知されない場合があります。

また、途中判定で使用する当日の価格、出来高、ローソク足は未確定です。その後の取引によって、陽線・終値位置・高値突破などの条件が変化する可能性があります。

本インジケーターは、出来高と価格条件に基づいて銘柄候補を抽出するための補助ツールです。売買を推奨するものではなく、利益を保証するものでもありません。実際の投資判断は、価格帯別出来高、VWAP、トレンド、企業業績、流動性、リスク管理などと併せて行ってください。

## Advanced RVOL Timed Buy Candidate

This indicator is a daily-chart Relative Volume tool designed to identify stocks experiencing unusually strong volume activity.

In addition to comparing the current volume with historical average volume, it can estimate full-day relative volume from the volume accumulated by a user-defined time. This allows users to receive potential buy-candidate alerts during the morning session or shortly before the market close.

### Main Features

#### 1. Average volume excluding the current bar

The current daily bar is excluded from the average-volume calculation.

This prevents unusually high current-day volume from raising the reference average and delaying the detection of a potential volume expansion.

The following averaging periods are available:

* Custom number of days
* Month to date
* Quarter to date
* Year to date
* Since the latest earnings release

When insufficient data is available, the indicator can automatically fall back to the custom moving-average period.

#### 2. Relative Volume display

Relative Volume is calculated by dividing the current volume by the selected average volume.

Examples:

* RVOL 1.00x: volume is equal to the average
* RVOL 1.50x: volume is 1.5 times the average
* RVOL 2.00x: volume is twice the average

The oscillator uses average volume as the zero line.

* 0%: equal to average volume
* +50%: 1.5 times average volume
* +100%: twice average volume

#### 3. Time-based projected RVOL

The indicator provides two configurable intraday evaluation times.

Examples:

* 10:00
* 15:24

For each evaluation time, users can define the percentage of normal daily volume that is typically completed by that time.

For example, assume:

* Average daily volume: 1,000,000 shares
* Expected volume progress by 10:00: 30%
* Actual volume at 10:00: 450,000 shares

The projected RVOL is:

450,000 ÷ (1,000,000 × 30%) = 1.50x

This feature helps identify stocks whose volume is developing faster than normal without waiting for the daily bar to close.

#### 4. Earnings filter

Earnings announcements and the sessions immediately following them often produce unusually high volume that may not represent normal accumulation.

The earnings filter can exclude the earnings session and a configurable number of subsequent trading days.

Examples:

* 0: Exclude the earnings session only
* 1: Exclude the earnings session and the next trading day
* 2: Exclude the earnings session and the following two trading days

An “E” marker can be displayed on earnings sessions, and the excluded period can be highlighted with a background color.

#### 5. Price-action filters

High volume alone cannot distinguish strong buying pressure from heavy selling.

Optional price-action filters are therefore included:

* Require a bullish candle
* Require the close to finish in the upper portion of the daily range
* Require a closing-price breakout above a recent high

The close-location value measures where the close is positioned between the session low and high.

For example, a setting of 70% requires the close to finish within the upper 30% of the session’s range.

#### 6. Alerts

The following alert conditions are available:

* Timed evaluation 1 buy candidate
* Timed evaluation 2 buy candidate
* Daily-close buy candidate

For timed alerts, set the TradingView alert frequency to “Once Per Bar.”

After changing the script or its input settings, existing alerts must be deleted and recreated because TradingView alerts use a server-side snapshot of the script and settings from the time the alert was created.

### Suggested Starting Settings

* Chart timeframe: Daily
* Average-volume period: 20 days
* Buy-candidate threshold: 150% of average
* Mega-volume threshold: 200% of average
* Bullish candle filter: Enabled
* Minimum close location: 70%
* Breakout filter: Disabled
* Earnings exclusion: Earnings day plus one trading day
* Timed evaluation 1: 10:00
* Expected volume progress by 10:00: 30%
* Timed evaluation 2: 15:24
* Expected volume progress by 15:24: 90%

Intraday volume distribution varies by stock and market, so the expected volume-progress settings should be adjusted for the instruments being monitored.

### Important Notes

This indicator is designed primarily for use on the daily timeframe.

Timed alerts are not triggered by an independent clock. Pine Script recalculates when TradingView receives a new price or volume update.

As a result, thinly traded stocks may not generate an alert at the exact selected time.

Price, volume, candle direction, close location, and breakout status remain provisional before the daily bar closes. A timed signal may therefore differ from the final daily-close result.

This indicator is a screening and decision-support tool based on volume and price conditions. It is not financial advice, does not recommend any security, and does not guarantee future performance. Users should combine its signals with additional analysis, including VWAP, volume profile, trend structure, company fundamentals, liquidity, position sizing, and risk management.

---

## Source Code

````pine
//@version=6
indicator('Advanced RVOL Timed Buy Candidate', shorttitle = 'RVOL Timed', overlay = false)

//==================================================
// 1. 平均出来高
//==================================================

group_average = '1. 平均出来高'

period_type = input.string('任意の日数', title = '平均の計算期間', options = ['任意の日数', '月単位', '四半期', '年初来 (YTD)', '決算から (自動)'], group = group_average)
len_custom = input.int(20, title = '任意の日数', minval = 1, group = group_average)
min_samples = input.int(5, title = '累積平均に必要な最低本数', minval = 1, group = group_average)
use_fallback = input.bool(true, title = 'データ不足時は任意日数平均を使用', group = group_average)
include_earnings_day = input.bool(false, title = '決算日の出来高を決算後平均に含める', group = group_average)

//==================================================
// 2. 出来高条件
//==================================================

group_volume = '2. 出来高条件'

buy_pct = input.float(150.0, title = '購入候補の推定出来高（平均比％）', minval = 100.0, step = 10.0, group = group_volume)
mega_pct = input.float(200.0, title = '特大出来高（平均比％）', minval = 100.0, step = 10.0, group = group_volume)

//==================================================
// 3. 価格条件
//==================================================

group_price = '3. 価格条件'

require_bullish = input.bool(true, title = '陽線を必須にする', group = group_price)
use_close_location = input.bool(true, title = '終値位置を確認する', group = group_price)
min_close_location_pct = input.float(70.0, title = '終値位置の最低値（％）', minval = 0.0, maxval = 100.0, step = 5.0, group = group_price)
use_breakout = input.bool(false, title = '直近高値の突破を必須にする', group = group_price)
breakout_length = input.int(20, title = '高値突破の確認期間', minval = 2, group = group_price)

//==================================================
// 4. 決算フィルター
//==================================================

group_earnings = '4. 決算フィルター'

use_earnings_filter = input.bool(true, title = '決算日と決算後を除外する', group = group_earnings)
exclude_days_after_earnings = input.int(1, title = '決算後に除外する営業日数', minval = 0, maxval = 10, group = group_earnings)
show_earnings_marker = input.bool(true, title = '決算日にEを表示する', group = group_earnings)
shade_excluded_days = input.bool(true, title = '決算除外期間の背景を表示する', group = group_earnings)

//==================================================
// 5. 途中判定1
//==================================================

group_time1 = '5. 途中判定1'

enable_time1 = input.bool(true, title = '途中判定1を有効にする', group = group_time1)
time1_hour = input.int(10, title = '判定時刻・時', minval = 0, maxval = 23, group = group_time1)
time1_minute = input.int(0, title = '判定時刻・分', minval = 0, maxval = 59, group = group_time1)
time1_window = input.int(5, title = '判定受付時間（分）', minval = 1, maxval = 30, group = group_time1)
time1_volume_progress = input.float(30.0, title = '指定時刻までの通常出来高進捗率（％）', minval = 1.0, maxval = 100.0, step = 1.0, group = group_time1)

//==================================================
// 6. 途中判定2
//==================================================

group_time2 = '6. 途中判定2'

enable_time2 = input.bool(true, title = '途中判定2を有効にする', group = group_time2)
time2_hour = input.int(15, title = '判定時刻・時', minval = 0, maxval = 23, group = group_time2)
time2_minute = input.int(24, title = '判定時刻・分', minval = 0, maxval = 59, group = group_time2)
time2_window = input.int(1, title = '判定受付時間（分）', minval = 1, maxval = 30, group = group_time2)
time2_volume_progress = input.float(90.0, title = '指定時刻までの通常出来高進捗率（％）', minval = 1.0, maxval = 100.0, step = 1.0, group = group_time2)

//==================================================
// 7. 日足確定通知
//==================================================

group_close = '7. 日足確定通知'

enable_close_alert = input.bool(false, title = '日足確定時にも通知する', group = group_close)

//==================================================
// 8. 表示色
//==================================================

group_color = '8. 表示色'

col_mega = input.color(color.new(color.yellow, 0), title = '特大出来高', group = group_color)
col_up = input.color(color.new(color.teal, 30), title = '平均以上', group = group_color)
col_dn = input.color(color.new(color.red, 30), title = '平均未満', group = group_color)
col_wait = input.color(color.new(color.gray, 70), title = '平均計算待ち', group = group_color)
col_time1 = input.color(color.new(color.aqua, 0), title = '途中判定1', group = group_color)
col_time2 = input.color(color.new(color.orange, 0), title = '途中判定2', group = group_color)
col_close = input.color(color.new(color.lime, 0), title = '日足確定候補', group = group_color)

//==================================================
// 9. 日足判定
//==================================================

is_daily_chart = timeframe.isdaily

//==================================================
// 10. 任意日数平均
// 現在足を平均から除外
//==================================================

vol_avg_custom = ta.sma(volume[1], len_custom)

//==================================================
// 11. 月初からの平均
// 完了済みの日足だけを使用
//==================================================

month_key = year * 100 + month
is_new_month = na(month_key[1]) or month_key != month_key[1]

var float sum_vol_month = 0.0
var int count_vol_month = 0

if barstate.isnew
    if is_new_month
        sum_vol_month := 0.0
        count_vol_month := 0
        count_vol_month
    else
        sum_vol_month := sum_vol_month + nz(volume[1], 0)
        count_vol_month := count_vol_month + 1
        count_vol_month

vol_avg_month_raw = count_vol_month >= min_samples ? sum_vol_month / count_vol_month : na

//==================================================
// 12. 四半期初からの平均
//==================================================

quarter_number = int(math.floor((month - 1) / 3.0)) + 1
quarter_key = year * 10 + quarter_number
is_new_quarter = na(quarter_key[1]) or quarter_key != quarter_key[1]

var float sum_vol_quarter = 0.0
var int count_vol_quarter = 0

if barstate.isnew
    if is_new_quarter
        sum_vol_quarter := 0.0
        count_vol_quarter := 0
        count_vol_quarter
    else
        sum_vol_quarter := sum_vol_quarter + nz(volume[1], 0)
        count_vol_quarter := count_vol_quarter + 1
        count_vol_quarter

vol_avg_quarter_raw = count_vol_quarter >= min_samples ? sum_vol_quarter / count_vol_quarter : na

//==================================================
// 13. 年初来平均
//==================================================

is_new_year = na(year[1]) or year != year[1]

var float sum_vol_ytd = 0.0
var int count_vol_ytd = 0

if barstate.isnew
    if is_new_year
        sum_vol_ytd := 0.0
        count_vol_ytd := 0
        count_vol_ytd
    else
        sum_vol_ytd := sum_vol_ytd + nz(volume[1], 0)
        count_vol_ytd := count_vol_ytd + 1
        count_vol_ytd

vol_avg_ytd_raw = count_vol_ytd >= min_samples ? sum_vol_ytd / count_vol_ytd : na

//==================================================
// 14. 決算イベント
//==================================================

earnings_value = request.earnings(syminfo.tickerid, earnings.actual, gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off)
is_earnings = not na(earnings_value)

//==================================================
// 15. 決算後平均
//==================================================

var float sum_vol_earnings = 0.0
var int count_vol_earnings = 0
var bool earnings_seen = false
varip bool earnings_reset_this_bar = false

if barstate.isnew
    earnings_reset_this_bar := false

    if not is_earnings and earnings_seen
        if include_earnings_day or not is_earnings[1]
            sum_vol_earnings := sum_vol_earnings + nz(volume[1], 0)
            count_vol_earnings := count_vol_earnings + 1
            count_vol_earnings

if is_earnings and not earnings_reset_this_bar
    earnings_seen := true
    sum_vol_earnings := 0.0
    count_vol_earnings := 0
    earnings_reset_this_bar := true
    earnings_reset_this_bar

vol_avg_earnings_raw = earnings_seen and count_vol_earnings >= min_samples ? sum_vol_earnings / count_vol_earnings : na

//==================================================
// 16. 決算からの経過営業日
//==================================================

var int days_since_earnings = na

if is_earnings
    days_since_earnings := 0
    days_since_earnings
else if barstate.isnew and not na(days_since_earnings)
    days_since_earnings := days_since_earnings + 1
    days_since_earnings

earnings_blocked = use_earnings_filter and not na(days_since_earnings) and days_since_earnings <= exclude_days_after_earnings
earnings_filter_ok = not earnings_blocked

//==================================================
// 17. 使用する平均
//==================================================

float selected_average = na

if period_type == '決算から (自動)'
    selected_average := vol_avg_earnings_raw
    selected_average
else if period_type == '年初来 (YTD)'
    selected_average := vol_avg_ytd_raw
    selected_average
else if period_type == '四半期'
    selected_average := vol_avg_quarter_raw
    selected_average
else if period_type == '月単位'
    selected_average := vol_avg_month_raw
    selected_average
else
    selected_average := vol_avg_custom
    selected_average

vol_average = use_fallback and na(selected_average) ? vol_avg_custom : selected_average

//==================================================
// 18. 実際の相対出来高
//==================================================

has_average = not na(vol_average) and vol_average > 0
actual_rvol = has_average ? volume / vol_average : na
volume_oscillator = has_average ? (actual_rvol - 1.0) * 100.0 : na

buy_ratio = buy_pct / 100.0
mega_ratio = mega_pct / 100.0

is_mega = has_average and actual_rvol >= mega_ratio
is_above_average = has_average and actual_rvol >= 1.0

color bar_color = col_wait

if has_average
    if is_mega
        bar_color := col_mega
        bar_color
    else if is_above_average
        bar_color := col_up
        bar_color
    else
        bar_color := col_dn
        bar_color

//==================================================
// 19. 価格条件
//==================================================

candle_range = high - low
close_location = candle_range > 0 ? (close - low) / candle_range : 0.5

bullish_ok = not require_bullish or close > open
close_location_ok = not use_close_location or close_location >= min_close_location_pct / 100.0

previous_high = ta.highest(high, breakout_length)[1]
breakout_ok = not use_breakout or not na(previous_high) and close > previous_high

price_filters_ok = bullish_ok and close_location_ok and breakout_ok

//==================================================
// 20. 途中判定時の推定RVOL
//==================================================

time1_progress_ratio = time1_volume_progress / 100.0
time2_progress_ratio = time2_volume_progress / 100.0

time1_projected_rvol = has_average ? volume / (vol_average * time1_progress_ratio) : na
time2_projected_rvol = has_average ? volume / (vol_average * time2_progress_ratio) : na

//==================================================
// 21. 指定時刻
//==================================================

one_minute_ms = 60 * 1000

time1_target = timestamp(syminfo.timezone, year, month, dayofmonth, time1_hour, time1_minute)
time2_target = timestamp(syminfo.timezone, year, month, dayofmonth, time2_hour, time2_minute)

time1_window_end = time1_target + time1_window * one_minute_ms
time2_window_end = time2_target + time2_window * one_minute_ms

time1_is_window = enable_time1 and is_daily_chart and barstate.isrealtime and timenow >= time1_target and timenow < time1_window_end
time2_is_window = enable_time2 and is_daily_chart and barstate.isrealtime and timenow >= time2_target and timenow < time2_window_end

//==================================================
// 22. 途中判定
//==================================================

time1_candidate_raw = earnings_filter_ok and price_filters_ok and not na(time1_projected_rvol) and time1_projected_rvol >= buy_ratio
time2_candidate_raw = earnings_filter_ok and price_filters_ok and not na(time2_projected_rvol) and time2_projected_rvol >= buy_ratio

varip bool time1_alerted_today = false
varip bool time2_alerted_today = false

if barstate.isnew
    time1_alerted_today := false
    time2_alerted_today := false
    time2_alerted_today

time1_buy_signal = time1_is_window and time1_candidate_raw and not time1_alerted_today
time2_buy_signal = time2_is_window and time2_candidate_raw and not time2_alerted_today

if time1_buy_signal
    time1_alerted_today := true
    time1_alerted_today

if time2_buy_signal
    time2_alerted_today := true
    time2_alerted_today

//==================================================
// 23. 日足確定候補
//==================================================

close_candidate_raw = is_daily_chart and earnings_filter_ok and price_filters_ok and has_average and actual_rvol >= buy_ratio
close_buy_signal = enable_close_alert and close_candidate_raw and barstate.isconfirmed

//==================================================
// 24. 描画
//==================================================

plot(is_daily_chart ? volume_oscillator : na, title = '相対出来高オシレーター（％）', style = plot.style_columns, color = bar_color)
hline(0, title = '平均出来高', color = color.gray, linestyle = hline.style_dashed)

plot(buy_pct - 100.0, title = '購入候補ライン', color = color.new(color.aqua, 40), linewidth = 1)
plot(mega_pct - 100.0, title = '特大出来高ライン', color = color.new(color.yellow, 30), linewidth = 1)

historical_close_candidate = close_candidate_raw and barstate.isconfirmed

plotshape(historical_close_candidate, title = '日足確定購入候補', style = shape.triangleup, location = location.bottom, color = col_close, size = size.tiny, text = '候補', textcolor = color.white)
plotshape(time1_alerted_today and barstate.isrealtime, title = '途中判定1通知済み', style = shape.diamond, location = location.bottom, color = col_time1, size = size.small, text = '時1', textcolor = color.white)
plotshape(time2_alerted_today and barstate.isrealtime, title = '途中判定2通知済み', style = shape.diamond, location = location.bottom, color = col_time2, size = size.small, text = '時2', textcolor = color.white)
plotshape(show_earnings_marker and is_earnings, title = '決算日', style = shape.circle, location = location.top, color = color.orange, size = size.tiny, text = 'E', textcolor = color.white)

bgcolor(shade_excluded_days and earnings_blocked ? color.new(color.orange, 88) : na)

//==================================================
// 25. 情報パネル
//==================================================

var table info_table = table.new(position.top_right, 2, 9, border_width = 1)

average_text = has_average ? str.tostring(math.round(vol_average)) : '計算待ち'
volume_text = str.tostring(math.round(volume))
actual_rvol_text = has_average ? str.tostring(actual_rvol, '#.00') + '倍' : '計算待ち'
time1_rvol_text = not na(time1_projected_rvol) ? str.tostring(time1_projected_rvol, '#.00') + '倍' : '計算待ち'
time2_rvol_text = not na(time2_projected_rvol) ? str.tostring(time2_projected_rvol, '#.00') + '倍' : '計算待ち'
close_location_text = str.tostring(close_location * 100.0, '#.0') + '%'
days_text = not na(days_since_earnings) ? str.tostring(days_since_earnings) + '営業日' : '未取得'

time1_hour_text = time1_hour < 10 ? '0' + str.tostring(time1_hour) : str.tostring(time1_hour)
time1_minute_text = time1_minute < 10 ? '0' + str.tostring(time1_minute) : str.tostring(time1_minute)
time2_hour_text = time2_hour < 10 ? '0' + str.tostring(time2_hour) : str.tostring(time2_hour)
time2_minute_text = time2_minute < 10 ? '0' + str.tostring(time2_minute) : str.tostring(time2_minute)

time1_panel_text = time1_hour_text + ':' + time1_minute_text + ' / ' + time1_rvol_text
time2_panel_text = time2_hour_text + ':' + time2_minute_text + ' / ' + time2_rvol_text

string signal_text = '対象外'
color signal_color = color.new(color.gray, 60)

if not is_daily_chart
    signal_text := '日足専用'
    signal_color := color.new(color.red, 20)
    signal_color
else if earnings_blocked
    signal_text := '決算期間を除外'
    signal_color := color.new(color.orange, 30)
    signal_color
else if time2_alerted_today
    signal_text := '途中判定2 通知済'
    signal_color := color.new(color.orange, 20)
    signal_color
else if time1_alerted_today
    signal_text := '途中判定1 通知済'
    signal_color := color.new(color.aqua, 30)
    signal_color
else if historical_close_candidate
    signal_text := '日足確定候補'
    signal_color := color.new(color.green, 20)
    signal_color
else if is_mega
    signal_text := '特大出来高'
    signal_color := color.new(color.orange, 20)
    signal_color
else if is_above_average
    signal_text := '平均以上'
    signal_text
else if has_average
    signal_text := '平均未満'
    signal_text
else
    signal_text := '計算待ち'
    signal_text

if barstate.islast
    table.cell(info_table, 0, 0, '使用期間', text_color = color.white, bgcolor = color.new(color.gray, 50))
    table.cell(info_table, 1, 0, period_type, text_color = color.white, bgcolor = color.new(color.gray, 70))
    table.cell(info_table, 0, 1, '平均出来高', text_color = color.white, bgcolor = color.new(color.gray, 50))
    table.cell(info_table, 1, 1, average_text, text_color = color.white, bgcolor = color.new(color.gray, 70))
    table.cell(info_table, 0, 2, '現在出来高', text_color = color.white, bgcolor = color.new(color.gray, 50))
    table.cell(info_table, 1, 2, volume_text, text_color = color.white, bgcolor = color.new(color.gray, 70))
    table.cell(info_table, 0, 3, '実際RVOL', text_color = color.white, bgcolor = color.new(color.gray, 50))
    table.cell(info_table, 1, 3, actual_rvol_text, text_color = color.white, bgcolor = color.new(color.gray, 70))
    table.cell(info_table, 0, 4, '終値位置', text_color = color.white, bgcolor = color.new(color.gray, 50))
    table.cell(info_table, 1, 4, close_location_text, text_color = color.white, bgcolor = color.new(color.gray, 70))
    table.cell(info_table, 0, 5, '決算から', text_color = color.white, bgcolor = color.new(color.gray, 50))
    table.cell(info_table, 1, 5, days_text, text_color = color.white, bgcolor = earnings_blocked ? color.new(color.orange, 30) : color.new(color.gray, 70))
    table.cell(info_table, 0, 6, '途中判定1', text_color = color.white, bgcolor = color.new(color.gray, 50))
    table.cell(info_table, 1, 6, time1_panel_text, text_color = color.white, bgcolor = color.new(color.gray, 70))
    table.cell(info_table, 0, 7, '途中判定2', text_color = color.white, bgcolor = color.new(color.gray, 50))
    table.cell(info_table, 1, 7, time2_panel_text, text_color = color.white, bgcolor = color.new(color.gray, 70))
    table.cell(info_table, 0, 8, '現在の判定', text_color = color.white, bgcolor = color.new(color.gray, 50))
    table.cell(info_table, 1, 8, signal_text, text_color = color.white, bgcolor = signal_color)

//==================================================
// 26. アラート
//==================================================

alertcondition(time1_buy_signal, title = '【途中判定1】推定出来高＋価格条件', message = '{{ticker}}：途中判定1で購入候補です。現在値={{close}}、現在出来高={{volume}}')
alertcondition(time2_buy_signal, title = '【途中判定2】推定出来高＋価格条件', message = '{{ticker}}：途中判定2で購入候補です。現在値={{close}}、現在出来高={{volume}}')
alertcondition(close_buy_signal, title = '【日足確定】出来高＋価格条件', message = '{{ticker}}：日足確定時に購入候補です。終値={{close}}、出来高={{volume}}')
````
