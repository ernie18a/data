# GC Prime Logic

- url: https://www.tradingview.com/script/4SSEL5AX/
- type: strategy
- pine_id: PUB;59b782867e08457092c141850fb46357
- version: 2.0

## Description

■ 概要
GC Prime Logic は、COMEX（ニューヨーク商品取引所）の金先物市場における「真の需給」を可視化し、統計的な優位性に基づいて設計されたクオンツ・ストラテジーです。

多くの一般的な指標が価格の推移のみを追うのに対し、本戦略は「価格変動の質」を多角的に分析します。CME（シカゴ・マーカンタイル取引所）から提供される**公式の建玉データ（Open Interest）**を直接演算に組み込むことで、市場参加者の資金の流れを精緻に捉えます。

■ 必須データ環境
本ロジックは、情報の優位性を最大限に引き出すため、以下のCME公式データフィードの購読を前提としています。

対象資産: COMEX:GC1! (Gold Futures)

参照データ: COMEX:GC1!_OI (Official Open Interest)

この公式データが存在しない環境では、ロジックの核となる「建玉（OI）フィルタリング」が動作しません。市場の深層データを活用できる環境にある方のための、高度な解析ツールです。

■ ロジックの核心：3つのアプローチ
1. 統計的正規化 (Z-Score CVD)
価格の対数収益率と、正規化されたボリュームから算出される「累積出来高デルタ（CVD）」を組み合わせ、それらをZスコア（標準偏差）へと変換。直近のボラティリティに対して、現在の動きが統計的にどれほど有意かをリアルタイムで判定し、突発的なノイズと本質的なトレンドを分離します。

2. 資金流出入の解析 (CME OI Logic)
CMEが公表する公式の建玉データを用い、現在の価格変動の背景を以下の通り判別します。

蓄積（Accumulation）: 価格上昇と建玉増加が同期 ＝ 確信度の高いトレンドと判断。

解消（Liquidation）: 価格上昇に対して建玉が減少 ＝ 利益確定による一時的な動きとして排除。

3. 適応型マーケット・レジーム・フィルター
相場の「状態」を数学的に定義し、不利な局面でのエントリーを徹底的に抑制します。

NATR（正規化ATR）: 収益期待値の低い低ボラティリティ期間を自動回避。

Choppiness Index: フラクタル次元の概念を用い、方向感のないレンジ相場を検知。

Macro Sync: 日足レベルの長期EMAとの同期により、大きな時間軸の流れに逆らわない設計。

■ 資金管理と執行アルゴリズム
スケーリング・アウト: 最初のターゲット（TP1）でポジションの50%を決済し、同時にストップを建値へ移動。リスクを最小化しながら利益を最大化する設計です。

ATRトレイリング: 市場の変動幅に合わせ、出口戦略を動的に調整します。

プライス・クライマックス決済: 統計的な限界点（偏差）を超えた急変時、反転が起こる前に迅速に利益を確定させます。

■ 公開期間と運用上の注意
利用期限: 本ストラテジーはロジック保護のため、2026年4月30日までの期間限定公開です。期限を過ぎると動作が停止します。

リスク管理: 本アルゴリズムは数学的根拠に基づき設計されていますが、将来の成果を確約するものではありません。取引所のデータ遅延等の外的要因も考慮し、常に慎重な運用が求められます。

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KAZKAM

//@version=5
strategy("BTC1! オーダーフロー同調 [BTC専用・高耐久版]", overlay=true, initial_capital=1000000, default_qty_type=strategy.percent_of_equity, default_qty_value=10, commission_type=strategy.commission.cash_per_contract, commission_value=5.0)

// ==========================================
// 1. BTC専用パラメーター設定
// ==========================================
btc_ticker  = input.symbol("CME:BTC1!", "CMEビットコイン先物")
oi_ticker   = input.symbol("CME:BTC1!_OI", "BTC OI(未決済建玉)")

// BTCのノイズを回避するため、検知期間と閾値をゴールドより「重め」に設定
trend_len   = input.int(14, "オーダーフロー検知期間 (BTC向けに延長)")
smooth_len  = input.int(7,  "平滑化期間 (HMA)")
base_entry  = input.int(35, "エントリー閾値 (BTCは35以上推奨)")
tokyo_mult  = input.float(1.5, "東京時間ハードル倍率 (BTCは24時間動くため低め)")

use_macro   = input.bool(true, "レンジ回避フィルター(EMA)")
macro_len   = input.int(200, "マクロEMA期間")
band_mult   = input.float(1.5, "不感地帯のATR倍率 (BTCは広めが必要)", step=0.5)

atr_len     = input.int(14, "ATR期間")
sl_mult     = input.float(6.0, "安全装置ストップロス (BTCは6.0推奨)", step=0.5)

use_oi_filter = input.bool(true, "OI(未決済建玉)フィルターを使用")
oi_climax_z   = input.float(2.5, "OIクライマックス Zスコア (BTCは2.5推奨)", step=0.1)

// ==========================================
// 2. データ取得とスコア計算 (非リペイント)
// ==========================================
[b_open, b_high, b_low, b_close, b_vol] = request.security(btc_ticker, timeframe.period, [open, high, low, close, volume])

spread = b_high - b_low
delta  = spread != 0 ? ((b_close - b_open) / spread) * b_vol : 0
cvd    = ta.cum(delta)

price_change = ta.change(b_close, trend_len)
cvd_change   = ta.change(cvd, trend_len)

// スコア計算 (Z-Score)
price_z = ta.stdev(price_change, trend_len * 5) != 0 ? price_change / ta.stdev(price_change, trend_len * 5) : 0
cvd_z   = ta.stdev(cvd_change,   trend_len * 5) != 0 ? cvd_change   / ta.stdev(cvd_change,   trend_len * 5) : 0

score = math.max(-100, math.min(100, (ta.hma(price_z, smooth_len) + ta.hma(cvd_z, smooth_len)) * 25))

// ==========================================
// 3. OIデータ取得 (完全非リペイント)
// ==========================================
oi_daily    = request.security(oi_ticker, "D", close)
close_daily = request.security(btc_ticker, "D", close)
oi_prev     = request.security(oi_ticker, "D", close[1])
close_prev  = request.security(btc_ticker, "D", close[1])

oi_diff    = oi_daily - oi_prev
price_diff = close_daily - close_prev

// 判定ロジック
is_real_up   = price_diff > 0 and oi_diff > 0
is_fake_down = price_diff < 0 and oi_diff < 0 // 下落中のショートカバー（踏み上げ）

// OIクライマックス (過熱)
oi_ma     = ta.sma(oi_daily, 20)
oi_std    = ta.stdev(oi_daily, 20)
oi_z      = oi_std != 0 ? (oi_daily - oi_ma) / oi_std : 0
oi_climax = oi_z > oi_climax_z

// ==========================================
// 4. フィルター設定
// ==========================================
atr_val    = ta.atr(atr_len)
macro_ema  = ta.ema(close, macro_len)
upper_band = macro_ema + (atr_val * band_mult)
lower_band = macro_ema - (atr_val * band_mult)

// 東京時間のハードル (BTCは17時〜深夜に動くため、午前中は慎重に)
is_tokyo = (hour(time, "Asia/Tokyo") >= 8 and hour(time, "Asia/Tokyo") < 16)
dynamic_entry_level = is_tokyo ? base_entry * tokyo_mult : base_entry

// ==========================================
// 5. エントリー＆エグジット判定
// ==========================================
long_cond = ta.crossover(score, dynamic_entry_level) and (not use_macro or close > upper_band) and (not use_oi_filter or is_real_up or is_fake_down)
short_cond = ta.crossunder(score, -dynamic_entry_level) and (not use_macro or close < lower_band) and (not use_oi_filter or (price_diff < 0 and oi_diff > 0))

exit_long  = ta.crossunder(score, -base_entry) or ta.crossunder(close, lower_band) or (oi_climax and score < 0)
exit_short = ta.crossover(score, base_entry)   or ta.crossover(close, upper_band) or (oi_climax and score > 0)

// ==========================================
// 6. 戦略実行
// ==========================================
var float stop_p = na

if long_cond and strategy.position_size == 0
    strategy.entry("BTC_Long", strategy.long)
    stop_p := close - (atr_val * sl_mult)

if short_cond and strategy.position_size == 0
    strategy.entry("BTC_Short", strategy.short)
    stop_p := close + (atr_val * sl_mult)

if strategy.position_size > 0 and exit_long
    strategy.close("BTC_Long", comment="Logic Exit")
if strategy.position_size < 0 and exit_short
    strategy.close("BTC_Short", comment="Logic Exit")

strategy.exit("SL", stop=stop_p)

if strategy.position_size == 0
    stop_p := na

// ビジュアル表示
barcolor(strategy.position_size > 0 ? color.lime : strategy.position_size < 0 ? color.red : na)
plot(macro_ema, color=color.gray, title="200EMA")
````
