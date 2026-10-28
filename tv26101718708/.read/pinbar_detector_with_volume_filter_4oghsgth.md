# Pinbar Detector with Volume Filter 

- url: https://www.tradingview.com/script/4OGHsGTh/
- type: indicator
- pine_id: PUB;2c8769b28bf348dfa5d38b4fec8f0fb4
- version: 1.0

## Description

[b]Overview[/b]
This indicator detects bullish and bearish pin bars on any chart, classified by wick-to-body ratio (2× and 3×), with an optional volume filter to highlight high-conviction signals. Doji candles (exact open = close) are detected separately. Detected candles are redrawn with user-defined colors over the original chart, making them immediately visible without cluttering the price action.

[b]How it works[/b]
・[b]Wick ratio detection:[/b] A bullish pin bar is identified when the lower wick exceeds the upper wick AND the lower wick is at least 2× (or 3×) the body size. Bearish pin bars apply the same logic to the upper wick.
・[b]Minimum range filter: [/b]Candles with a total range smaller than syminfo.mintick × N are excluded, preventing false signals on ultra-thin bars common in low-volatility periods or wide-spread instruments.
・[b]Doji detection: [/b]Candles with open == close (exact match) are flagged separately from pin bars and displayed in a distinct color.
・[b]Volume confirmation:[/b] The indicator computes a simple moving average of volume over a configurable period (default: 20 bars). If the current bar's volume exceeds SMA × multiplier, it is marked as high-volume. This filter can be toggled off for volume-less instruments such as FX pairs.
・[b]Priority rule: [/b]When a candle qualifies as both 2× and 3×, the 3× classification takes priority. Color and wick transparency are adjusted to distinguish strength levels and volume presence.
・[b]Three independent plotcandle() streams: [/b]Bullish, bearish, and doji detections are rendered as separate candle series, each with fully customizable colors and transparency.

[b]Originality[/b]
While pin bar detection is a well-known concept, this script combines several refinements in a single, configurable tool:

・Simultaneous 2× / 3× tier classification with visual distinction
・Independent doji detection channel that does not interfere with pin bar logic
・A toggleable volume confirmation layer, making the script usable on both equities (where volume is meaningful) and FX/crypto spot (where volume data is unavailable or unreliable)
・Per-tier color customization with a wick transparency offset that makes high-volume signals stand out at a glance
・A minimum-range filter to avoid noisy false detections on tight-spread bars

[b]How to use[/b]

1.Add the indicator to any chart (overlay mode).
2.Under Pin Bar Settings, enable or disable 2× and 3× tiers individually, and set the minimum range threshold.
3.Under Volume Settings, toggle the volume filter on/off and adjust the SMA period and multiplier to suit your instrument.
4.Under Display Settings, assign colors for each combination (e.g., bullish 3× + high volume, bearish 2× without volume) and set candle transparency.
5.Set alerts using the built-in alert conditions (bullish/bearish 2×+, 3×+, any pin bar + high volume, doji) via TradingView's alert creation dialog.

Signal reading guide:

・Green tones = bullish pin bar; red/orange tones = bearish pin bar; yellow = doji
・A deeper/less-transparent color (combined with your volume multiplier setting) indicates the volume filter was triggered — treat these as higher-conviction candidates
・3× signals suggest a more dominant wick rejection relative to the body

Note: Pin bar signals indicate potential reversal areas, not guaranteed entries. Always use additional confirmation (support/resistance levels, trend context, etc.) before trading. Past detection of patterns does not guarantee future performance.


説明文（日本語）
[b]概要[/b]
このインジケーターは、あらゆるチャートでヒゲ対ボディ比率（2倍・3倍）によって分類された強気・弱気ピンバーを検出します。高出来高シグナルを強調するオプションの出来高フィルターも搭載しています。十字線（open == close が完全一致するローソク足）は独立した系統で検出されます。検出されたローソク足はユーザー定義のカラーで再描画されるため、プライスアクションを妨げることなく一目で識別できます。

[b]ロジック[/b]

[*][b]ヒゲ比率判定：[/b]下ヒゲが上ヒゲを上回り、かつ下ヒゲがボディの2倍（または3倍）以上の場合に強気ピンバーと判定します。弱気ピンバーは上ヒゲに対して同様のロジックを適用します。
[*][b]最小レンジフィルター：[/b]syminfo.mintick × N より小さい全体レンジのローソク足を除外し、低ボラティリティ時やスプレッドの広い銘柄における誤検出を防ぎます。
[*][b]十字線検出：[/b]open == close（完全一致）のローソク足はピンバーとは別系統で検出・表示されます。
[*][b]出来高確認：[/b]設定した期間（デフォルト20本）の出来高単純移動平均を計算し、当該バーの出来高が「SMA × 倍率」を超える場合を高出来高と判定します。FX等の出来高データが信頼できない銘柄向けにOFF切り替えが可能です。
[*][b]優先ルール：[/b]同一ローソク足が2倍・3倍の両条件を満たす場合、3倍の分類が優先されます。色とヒゲ透明度で強度レベルと出来高の有無を視覚的に区別します。
[*][b]3系統の独立した plotcandle()：[/b]強気・弱気・十字線の検出をそれぞれ独立したローソク足系列として描画し、色と透明度を個別にカスタマイズできます。

[b]オリジナリティ[/b]
ピンバー検出は広く知られた手法ですが、本スクリプトは以下の要素を1つの設定可能なツールにまとめています。

[*]2倍・3倍の同時ティア分類と視覚的区別
[*]ピンバーロジックに干渉しない独立した十字線検出チャンネル
[*]株式（出来高が有意な市場）と FX/暗号資産スポット（出来高データが不安定な市場）の両方に対応するトグル式出来高確認レイヤー
[*]ティアごとのカラーカスタマイズと、高出来高シグナルを一目で判別できるヒゲ透明度オフセット
[*]極小スプレッドのローソク足によるノイジーな誤検出を排除する最小レンジフィルター

[b]使い方[/b]

[*]1.インジケーターを任意のチャートに追加します（オーバーレイモード）。
[*][/list]2.ピンバー設定で2倍・3倍ティアをそれぞれ有効/無効にし、最小レンジの閾値を設定します。
[*]3.出来高設定で出来高フィルターのON/OFFを切り替え、MA期間と倍率を銘柄に合わせて調整します。
[*]4.表示設定で各組み合わせ（例：強気3倍＋高出来高、弱気2倍・出来高なし）の色とローソク足の透明度を設定します。
[*]5.TradingViewのアラート作成ダイアログから組み込みのアラート条件（強気/弱気2倍以上・3倍以上・ピンバー＋高出来高・十字線）を設定します。

シグナルの読み方：

[*]緑系 ＝ 強気ピンバー、赤/オレンジ系 ＝ 弱気ピンバー、黄色 ＝ 十字線
[*]より濃い（透明度の低い）色は出来高フィルターが発動したことを示し、より強い確信度の候補と捉えられます
[*]3倍シグナルはボディに対してより支配的なヒゲの拒絶を示します

注意：ピンバーシグナルは反転の可能性を示すものであり、エントリーを保証するものではありません。取引前にサポート・レジスタンス、トレンドコンテキスト等で追加確認を行ってください。過去のパターン検出は将来のパフォーマンスを保証しません。

## Source Code

````pine
//@version=6
indicator("Pinbar Detector", shorttitle="PinBar", overlay=true)

// ============================================================
// グループ定数
// ============================================================
var string GRP_PIN = "ピンバー設定"
var string GRP_VOL = "出来高設定"
var string GRP_VIS = "表示設定"

// ============================================================
// 入力パラメーター
// ============================================================

// --- ピンバー設定 ---
i_show_2x       = input.bool(true,  "2倍ピンバーを表示",         group=GRP_PIN)
i_show_3x       = input.bool(true,  "3倍ピンバーを表示",         group=GRP_PIN)
i_min_range     = input.int(10,     "最小レンジ（mintick × N）", group=GRP_PIN, minval=1)
i_show_doji     = input.bool(true,  "十字線を表示",               group=GRP_PIN)

// --- 出来高設定 ---
i_use_vol       = input.bool(true,  "出来高フィルター ON/OFF",    group=GRP_VOL,
                  tooltip="OFFにすると出来高条件を無視してヒゲ比率のみで判定します（FX等向け）")
i_vol_period    = input.int(20,     "出来高 MA 期間",             group=GRP_VOL, minval=1)
i_vol_mult      = input.float(1.5,  "出来高閾値倍率",             group=GRP_VOL, minval=0.1, step=0.1,
                  tooltip="平均出来高 × N を超えると「高出来高」と判定します")

// --- 表示設定 ---
i_transp        = input.int(70,     "ローソク足の透明度（0=不透明）", group=GRP_VIS, minval=0, maxval=99)

i_bull_3x_vol   = input.color(color.new(#00c853, 0),  "強気 3倍 ＋ 出来高", group=GRP_VIS)
i_bull_3x       = input.color(color.new(#00c853, 0),  "強気 3倍",           group=GRP_VIS)
i_bull_2x_vol   = input.color(color.new(#00bcd4, 0),  "強気 2倍 ＋ 出来高", group=GRP_VIS)

i_bear_3x_vol   = input.color(color.new(#f44336, 0),  "弱気 3倍 ＋ 出来高", group=GRP_VIS)
i_bear_3x       = input.color(color.new(#f44336, 0),  "弱気 3倍",           group=GRP_VIS)
i_bear_2x_vol   = input.color(color.new(#ff9800, 0),  "弱気 2倍 ＋ 出来高", group=GRP_VIS)

i_doji_color    = input.color(color.new(#ffeb3b, 0),  "十字線",             group=GRP_VIS)

// ============================================================
// 基本計算
// ============================================================
body        = math.abs(close - open)
upper_wick  = high - math.max(open, close)
lower_wick  = math.min(open, close) - low
total_range = high - low

// ============================================================
// フィルター計算
// ============================================================

// 最小レンジフィルター（スプレッド相当の極小バーを除外）
min_range_ok = total_range > syminfo.mintick * i_min_range

// 十字線判定（open == close の完全一致のみ）
is_doji = (body == 0)

// 出来高フィルター
vol_ma   = ta.sma(volume, i_vol_period)
high_vol = i_use_vol ? (volume > vol_ma * i_vol_mult) : true

// ============================================================
// ピンバー判定
// ============================================================

// 強気ピンバー（下ヒゲが主役・下ヒゲ > 上ヒゲ）
is_bull_base = not is_doji and min_range_ok and (lower_wick > upper_wick)
is_bull_2x   = i_show_2x and is_bull_base and (lower_wick >= body * 2)
is_bull_3x   = i_show_3x and is_bull_base and (lower_wick >= body * 3)

// 弱気ピンバー（上ヒゲが主役・上ヒゲ > 下ヒゲ）
is_bear_base = not is_doji and min_range_ok and (upper_wick > lower_wick)
is_bear_2x   = i_show_2x and is_bear_base and (upper_wick >= body * 2)
is_bear_3x   = i_show_3x and is_bear_base and (upper_wick >= body * 3)

// 十字線（表示設定も考慮）
is_doji_valid = i_show_doji and is_doji and min_range_ok

// ============================================================
// 描画値の振り分け
// 優先順位：3x > 2x、十字線は独立系統
// ============================================================

// --- 強気ピンバー ---
// 3倍条件が成立している場合は2倍として扱わない
bull_active = is_bull_3x or is_bull_2x

bull_o = bull_active ? open  : na
bull_h = bull_active ? high  : na
bull_l = bull_active ? low   : na
bull_c = bull_active ? close : na

// 色：3倍優先、次に2倍（いずれも出来高で濃淡分岐）
bull_color = is_bull_3x and high_vol ? color.new(i_bull_3x_vol, i_transp) :
             is_bull_3x              ? color.new(i_bull_3x,     i_transp) :
             is_bull_2x and high_vol ? color.new(i_bull_2x_vol, i_transp) :
             color.new(i_bull_2x_vol, i_transp)  // フォールバック（実際は到達しない）

bull_wick_color = is_bull_3x and high_vol ? color.new(i_bull_3x_vol, math.max(i_transp - 20, 0)) :
                 is_bull_3x              ? color.new(i_bull_3x,     math.max(i_transp - 20, 0)) :
                                           color.new(i_bull_2x_vol, math.max(i_transp - 20, 0))

// --- 弱気ピンバー ---
bear_active = is_bear_3x or is_bear_2x

bear_o = bear_active ? open  : na
bear_h = bear_active ? high  : na
bear_l = bear_active ? low   : na
bear_c = bear_active ? close : na

bear_color = is_bear_3x and high_vol ? color.new(i_bear_3x_vol, i_transp) :
             is_bear_3x              ? color.new(i_bear_3x,     i_transp) :
             is_bear_2x and high_vol ? color.new(i_bear_2x_vol, i_transp) :
             color.new(i_bear_2x_vol, i_transp)

bear_wick_color = is_bear_3x and high_vol ? color.new(i_bear_3x_vol, math.max(i_transp - 20, 0)) :
                 is_bear_3x              ? color.new(i_bear_3x,     math.max(i_transp - 20, 0)) :
                                           color.new(i_bear_2x_vol, math.max(i_transp - 20, 0))

// --- 十字線 ---
doji_o = is_doji_valid ? open  : na
doji_h = is_doji_valid ? high  : na
doji_l = is_doji_valid ? low   : na
doji_c = is_doji_valid ? close : na

// ============================================================
// plotcandle() 描画（3系統）
// ============================================================
plotcandle(bull_o, bull_h, bull_l, bull_c,
           title="強気ピンバー",
           color=bull_color,
           wickcolor=bull_wick_color,
           bordercolor=bull_wick_color)

plotcandle(bear_o, bear_h, bear_l, bear_c,
           title="弱気ピンバー",
           color=bear_color,
           wickcolor=bear_wick_color,
           bordercolor=bear_wick_color)

plotcandle(doji_o, doji_h, doji_l, doji_c,
           title="十字線",
           color=color.new(i_doji_color, i_transp),
           wickcolor=color.new(i_doji_color, math.max(i_transp - 20, 0)),
           bordercolor=color.new(i_doji_color, math.max(i_transp - 20, 0)))

// ============================================================
// アラート条件
// ============================================================
alertcondition(is_bull_2x or is_bull_3x,
               title="強気ピンバー（2倍以上）",
               message="強気ピンバー検出（ヒゲ2倍以上）: {{ticker}} {{interval}}")

alertcondition(is_bull_3x,
               title="強気ピンバー（3倍以上）",
               message="強気ピンバー検出（ヒゲ3倍以上）: {{ticker}} {{interval}}")

alertcondition(is_bear_2x or is_bear_3x,
               title="弱気ピンバー（2倍以上）",
               message="弱気ピンバー検出（ヒゲ2倍以上）: {{ticker}} {{interval}}")

alertcondition(is_bear_3x,
               title="弱気ピンバー（3倍以上）",
               message="弱気ピンバー検出（ヒゲ3倍以上）: {{ticker}} {{interval}}")

alertcondition((is_bull_2x or is_bull_3x or is_bear_2x or is_bear_3x) and high_vol,
               title="ピンバー ＋ 高出来高",
               message="高出来高を伴うピンバー検出: {{ticker}} {{interval}}")

alertcondition(is_doji_valid,
               title="十字線検出",
               message="十字線検出: {{ticker}} {{interval}}")
````
