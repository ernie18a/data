# MTF SMC Signal v2 - Ready/Fire & Confluence Score

- url: https://www.tradingview.com/script/c7xfeVLP/
- type: indicator
- pine_id: PUB;23bcf8f2458548f2bd5e66fede7cb743
- version: 1.0

## Description

[b]Overview[/b]
This indicator generates long/short signals by combining higher-timeframe directional bias with a two-stage confirmation process on the execution timeframe: a Fair Value Gap (FVG) retest ("Ready") followed by a reversal-pattern confirmation ("Fire"). It also computes a 0-100 confluence score from market structure, FVG quality, and premium/discount positioning, and displays everything in an on-chart dashboard with entry/stop/target levels.

[b]How it works
[/b]
・Bias (HTF/MTF only): Directional bias is derived exclusively from EMA slope/position on two higher timeframes (auto-selected as 1H/4H or 15M/1H depending on the execution mode, or manually overridden). The execution timeframe is intentionally excluded from bias calculation, since EMA-based readings on a fast timeframe tend to lag and produce false flips. Instead, the execution timeframe is reserved entirely for pattern confirmation.

・Structure events: Pivot-based swing highs/lows are tracked to detect Change of Character (CHoCH) and Break of Structure (BOS) events, which set/confirm the working bias and anchor a countdown window ("setup window") during which a trade idea remains valid.

・FVG detection and Ready state: Three-bar imbalances (Fair Value Gaps) are detected using the same bullish/bearish three-bar gap rule popularized by LuxAlgo's open-source "Fair Value Gap [LuxAlgo]" script (gaps above a minimum ATR-based size are plotted as boxes here, instead of that script's percentage-based threshold). When price returns to retest an untouched FVG in the direction of the current bias, the signal enters a "Ready" state.

・Fire confirmation: A "Ready" signal only fires once a reversal confirmation occurs - a bullish/bearish engulfing candle, a pin bar, a fresh micro CHoCH/BOS, or a breakout of the recent range on a lower confirmation timeframe (configurable). This two-step Ready→Fire sequence is designed to reduce premature entries on a bare FVG touch, which the original FVG script does not implement.

・FVG grading: Each FVG used as entry basis is graded S/A/B: Grade S if it overlaps a still-open daily-timeframe FVG, Grade A if price is on the correct side of the recent range's equilibrium (premium/discount), Grade B otherwise. This grade feeds into the confluence score.

・Confluence score (fs): A 0-100 score is calculated from a weighted combination of a "setup" sub-score (structure freshness, FVG proximity, premium/discount alignment) and an "exec" sub-score (recency of the triggering event, retest precision). A signal only reaches "entry candidate" status once the score clears a configurable (or auto-selected) threshold.

・Risk levels: On a confirmed fire, the script plots an entry line and two stop-loss references (most recent swing point, and the FVG boundary when available) along with two take-profit levels based on a user-defined risk-multiple, plus an approximate dollar-risk conversion using lot size and pip value inputs.

・Dashboard: An on-chart table shows current bias, the recommended action in plain language, the higher-timeframe directions, Ready/Fire state, the confluence score versus its threshold, FVG grade, and stop levels, in either a full or mobile-condensed layout with several color presets.

[b]Originality[/b]
The three-bar FVG detection rule used here (gap test plus close confirmation on the middle bar) follows the same bullish/bearish definition used in LuxAlgo's open-source script "Fair Value Gap [LuxAlgo]". Credit to LuxAlgo for that detection logic. Beyond that shared detection rule, everything else in this script is an original addition not present in the LuxAlgo script:

・An ATR-based size filter in place of the original's percentage-based threshold.

・A two-stage Ready→Fire workflow that separates "FVG retest" from "reversal confirmed" using candlestick patterns, micro structure breaks, or a lower-timeframe range break - the LuxAlgo script only tracks mitigation/fill, with no retest-and-confirm signal logic.

・An S/A/B grading system for FVGs based on daily-timeframe FVG overlap and premium/discount alignment, feeding into a weighted 0-100 confluence score - not present in the original.

・A bias model that deliberately restricts directional judgment to higher timeframes only, while delegating all execution-timeframe analysis to pattern/structure confirmation.

・A dual stop-loss reference (swing-based and FVG-based) with an approximate monetary-risk readout, automated entry/SL/TP line and label drawing, and a full on-chart decision dashboard - none of which exist in the original FVG script, which is a standalone FVG-plotting tool without a signal or risk-management layer.

This script is published open-source, in line with the reuse terms for the underlying open-source FVG concept.

[b]How to use[/b]
1.Choose the execution mode (5 or 15 minutes); higher timeframes for bias are auto-selected accordingly, or can be manually overridden.

2.Watch the dashboard's "Action" cell: it summarizes the current state in plain language (e.g., "waiting for setup," "Ready - waiting for reversal confirm," "check arrow - consider entry").

3.A triangle marker appears on the chart only when a signal reaches "entry candidate" status (bias aligned across higher timeframes, Ready→Fire confirmed or a sufficiently strong setup score, confluence score above threshold, no opposing FVG nearby, and outside the cooldown window).

4.When a marker appears, entry/stop/target lines and labels are drawn automatically; the dollar-risk figures depend on the lot size and pip value you configure for your broker/instrument.

5.The "FVG grade" and "fs" (confluence score) cells let you gauge signal quality even outside a firing bar, useful for anticipating upcoming setups.

6.Optional alerts can be configured to fire on "entry candidate" and "structure break" events via the alert() payload.

[i]Backtest/forward-test before live use. This is a signal/analysis tool, not financial advice, and past structure or score behavior does not guarantee future results.[/i]

[b]説明文（日本語版）[/b]
[b]概要[/b]
　本インジケーターは、上位タイムフレームで判定した方向性バイアスと、執行タイムフレーム上の2段階確認プロセス（FVG「リテスト=Ready」→ 反転パターン確認「Fire」）を組み合わせて売買シグナルを生成します。また、構造・FVG品質・プレミアム/ディスカウント位置から0〜100のコンフルエンス（複合）スコアを算出し、チャート上のダッシュボードにエントリー/ストップ/ターゲットのレベルとともに表示します。

[b]ロジックの説明[/b]
○[b]バイアス判定（HTF/MTFのみ）[/b]： 方向性バイアスは2つの上位タイムフレーム（執行モードに応じて1H/4Hまたは15M/1Hを自動選択、手動上書きも可）でのEMAの傾き・位置のみから判定します。執行タイムフレームでのEMA判定は遅行しやすく偽の反転を生みやすいため、意図的にバイアス判定から除外し、執行タイムフレームはパターン確認専用としています。

○[b]構造イベント[/b]： ピボットによるスイング高安からCHoCH（性質変化）とBOS（構造ブレイク）を検出し、これによりバイアスの確定/継続判定と、セットアップが有効とみなされる期間（setup window）の起点を設定します。

○[b]FVG検出とReady状態[/b]： LuxAlgoのオープンソーススクリプト「Fair Value Gap [LuxAlgo]」で広く知られるようになった、3本足での強気/弱気ギャップ判定ルールと同じ定義でFVGを検出します（サイズフィルターは、元スクリプトのパーセンテージ閾値の代わりにATRベースの最小サイズを使用）。未接触のFVGに現在のバイアス方向で価格が戻ってきた際に「Ready」状態に入ります。

○[b]Fire確認[/b]： Ready状態は、反転確認（包み足、ピンバー、新規ミニCHoCH/BOS、または設定可能な下位確認タイムフレームでの直近レンジブレイク）が成立した時点でのみ「Fire」します。この2段階フローにより、FVGへの単純な接触だけでの早すぎるエントリーを抑制する設計です（元のLuxAlgoスクリプトにはこのリテスト確認の仕組みはありません）。

○[b]FVGグレーディング[/b]： エントリーの根拠としたFVGをS/A/Bでグレード付けします。未決済の日足FVGと重なる場合はグレードS、価格が直近レンジの均衡点に対して正しい側（プレミアム/ディスカウント）にある場合はグレードA、それ以外はグレードBとし、このグレードがコンフルエンススコアに反映されます。

○[b]コンフルエンススコア(fs)[/b]： 「setup」サブスコア（構造の新鮮さ、FVGとの近接度、プレミアム/ディスカウント整合）と「exec」サブスコア（トリガーイベントの直近性、リテスト精度）を加重統合し、0〜100のスコアを算出します。このスコアが設定（または自動選択）された閾値を超えた場合のみ「エントリー候補」となります。

○[b]リスクレベル[/b]： Fire確定時、直近スイング点とFVG境界（利用可能な場合）の2種類のストップロス基準、ユーザー設定のリスク倍率に基づく2つのテイクプロフィットレベルをライン表示し、ロットサイズとpip価値の入力からおおよそのドル損失額も併記します。

○[b]ダッシュボード[/b]： 現在のバイアス、平易な表現での推奨アクション、上位タイムフレームの方向、Ready/Fire状態、閾値に対するコンフルエンススコア、FVGグレード、ストップレベルなどをテーブルで表示します。フル/モバイル簡易表示と複数のカラープリセットを選択可能です。

[b]オリジナリティ[/b]
　本スクリプトのFVG検出ルール（3本足でのギャップ判定＋中間バーの終値確認）は、LuxAlgoのオープンソーススクリプト「Fair Value Gap [LuxAlgo]」で使われている強気/弱気の定義をそのまま踏襲しています。この検出ロジックについてLuxAlgo氏にクレジットを表します。この共通の検出ルールを除き、本スクリプトの以下の要素はLuxAlgoのスクリプトには存在しない独自の追加部分です：

・元スクリプトのパーセンテージ閾値の代わりに、ATRベースのサイズフィルターを使用している点。

・「FVGリテスト」と「反転確認（ローソク足パターン、ミニ構造ブレイク、下位タイムフレームのレンジブレイク）」を分離した2段階のReady→Fireワークフロー。元のLuxAlgoスクリプトはミティゲーション（FVGの消化）の追跡のみで、リテスト確認やシグナルロジックは持っていません。

・日足FVGとの重なりおよびプレミアム/ディスカウント整合に基づくS/A/BのFVGグレーディングと、それを反映した加重0〜100のコンフルエンススコア（元スクリプトには存在しません）。

・方向判定を上位タイムフレームのみに意図的に限定し、執行タイムフレームの分析はすべてパターン/構造確認に委ねるバイアスモデル。

・スイング基準とFVG基準の2系統ストップロス参照、おおよその金額換算リスク表示、エントリー/SL/TPラインとラベルの自動描画、チャート上の総合判断ダッシュボード。これらは、シグナルやリスク管理機能を持たない単体のFVG描画ツールである元のLuxAlgoスクリプトには存在しません。

　本スクリプトはオープンソースで公開しており、これは元となるオープンソースのFVG検出概念の再利用条件にも準拠するものです。

[b]使い方[/b]

１．執行モード（5分または15分）を選択します。上位タイムフレームは自動的に対応するものが選ばれますが、手動上書きも可能です。

２．ダッシュボードの「Action」セルを確認してください。現在の状態が平易な表現で表示されます（例：「MTF整合済み・setup待ち」「反転確認待ち(Ready)」「矢印を確認・エントリー検討」など）。

３．チャート上の三角マーカーは、シグナルが「entry_candidate」状態に達したときのみ表示されます（上位タイムフレームでのバイアス整合、Ready→Fire確認または十分なセットアップスコア、コンフルエンススコアが閾値超え、反対側FVGが近接していない、クールダウン期間外であること、をすべて満たす場合）。

４．マーカー表示時、エントリー/ストップ/ターゲットのラインとラベルが自動描画されます。ドル損失額の表示は、ご自身のブローカー・銘柄に応じて設定するロットサイズとpip価値の入力値に依存します。

５．「FVG grade」「fs」セルは、シグナル発火前でも信号の質を把握する手がかりとなり、今後のセットアップを予測する際に活用できます。

６．alert()ペイロードにより、「entry_candidate」「structure_break」イベント発生時にアラートを設定できます。

　実運用前にバックテスト・フォワードテストを行ってください。本スクリプトはシグナル・分析ツールであり、投資助言ではありません。過去の構造やスコアの挙動が将来の結果を保証するものではありません。

## Source Code

````pine
// =====================================================================
//  MTF SMC Signal v2 - Structure Break, Ready->Fire FVG Retest & Confluence Score
//  v1からの変更点:
//   1) Bias判定をHTF/MTF(4H/1H等)のみに変更。LTFのEMA判定は遅行性のため除外し、
//      execTFの整合は構造ブレイク/反転確認パターンが担う設計に変更。
//   2) FVGリテストを「Ready」、反転確認パターン(包み足/ピンバー/ミニ構造ブレイク/
//      下位TFレンジブレイク)成立を「Fire」とする2段階フローに変更。
//   3) 構造ブレイク単独イベントを break_alert としてPhase A通知に独立。
//   4) 日足FVGとの重なりをFVGスコアリングのグレード(S/A/B)に反映。
//   5) SLをスイング安値とFVG底値の2段階表示+簡易$換算をペイロードに追加。
//   6) Entry/SL/TP1/TP2ラベル描画、根拠FVGのハイライト枠を追加。
//  v2.1からの変更点(ダッシュボード改修):
//   7) 情報テーブルの並び順を「Bias→Action」優先に変更し、銘柄行を削除、
//      モード行を末尾に移動。
//   8) カラープリセット(カスタム/ダーク/ライト/ターミナル/ハイコントラスト)を
//      追加。カスタム選択時はEntryマーカー色がBias/dir MTF/dir HTFの表示色と
//      連動する。
//  Pine v6への移行:
//   9) //@version=5 から //@version=6 に変更。本スクリプトはstrategy()ではなく
//      indicator()であり、strategy.*()関連の破壊的変更(margin既定値・when
//      パラメータ廃止・strategy.exit()評価順など)は対象外。
//   10) v6ではbool型がna値を取れなくなったため、CE10173エラーの原因となっていた
//       `var bool highlighted_fvg_was_bull = na` を `= false` に修正。この変数は
//       常に highlighted_fvg_cbar/highlighted_fvg_box のna判定でガードされた後に
//       しか参照されないため、初期値変更による判定ロジックへの影響はない。
//       他のbool/na関連の破壊的変更(switch/ifの不可避なna禁止、transp引数廃止、
//       linewidth最小値、timeframe.periodの乗数表記統一等)は該当コードがなく
//       修正不要であることを確認済み。
//       なおcolor.red/teal/yellowの内部RGB値がv6で変更されているため、配色が
//       わずかに変化する場合がある(機能には影響なし)。
// =====================================================================

//@version=6
indicator("MTF SMC Signal v2 - Ready/Fire & Confluence Score", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200)

// ---------------------------------------------------------------------
// 1. 入力パラメータ（inputs）
// ---------------------------------------------------------------------

exec_tf_mode = input.string("15", "執行モード(分)", options=["5", "15"], group="モード")

ctx_htf_in   = input.string("", "上書き: HTF (例 240 / D)",       group="コンテキスト足(空欄=自動)")
ctx_mtf_in   = input.string("", "上書き: MTF (例 60 / 15)",       group="コンテキスト足(空欄=自動)")
ctx_subtf_in = input.string("", "上書き: 確認用下位TF (例 5 / 1)", group="コンテキスト足(空欄=自動)")

ema_len = input.int(50, "方向判定EMAの長さ", minval=2, group="MTF方向判定")

fvg_atr_mult = input.float(0.20, "FVG最小サイズ(ATR倍数)", step=0.01, group="FVG(Phase2)")
fvg_lookback = input.int(50, "FVG探索バー数(Premium/Discount)", minval=5, group="FVG(Phase2)")

use_daily_fvg_grade = input.bool(true, "日足FVGとの重なりをスコアに加味(Grade S)", group="FVGスコアリング(HTF確認)")

fs_min_auto = input.bool(true, "fs_minをモード別に自動(15分=55/5分=65)", group="スコア(Phase3)")
fs_min      = input.int(55, "本発火スコア下限 fs_min(手動時)", group="スコア(Phase3)")

mtf_mode = input.string("strict", "MTF整合モード(HTF/MTFのみで判定)", options=["strict", "soft"], group="MTF整合(Phase4)")

use_session = input.bool(false, "セッション制限ON", group="セッション(Phase4)")
session_str = input.session("2045-2400", "取引時間帯", group="セッション(Phase4)")
tz_str      = input.string("Asia/Tokyo", "タイムゾーン", group="セッション(Phase4)")

rr_tp1 = input.float(1.0, "TP1のR倍数", step=0.1, group="リスク(Phase4)")
rr_tp2 = input.float(2.0, "TP2のR倍数", step=0.1, group="リスク(Phase4)")

lot_size          = input.float(0.1, "ロットサイズ(簡易$換算用)", step=0.01, group="リスク表示($簡易換算)")
pip_value_per_lot = input.float(1000.0, "1ロットの1pip価値(ブローカー値を確認)", group="リスク表示($簡易換算)")

cooldown_bars = input.int(3, "同方向クールダウン(バー)", minval=0, group="クールダウン(Phase4)")

ltf_lookback  = input.int(8, "下位TF レンジブレイク確認本数", minval=2, group="Ready/Fire確認")
use_ltf_break = input.bool(true, "下位TFレンジブレイクをFire確認に使用", group="Ready/Fire確認")

show_swing = input.bool(true, "スイング高安を表示", group="スイング(Phase2)")
swing_len  = input.int(5, "スイング検出の左右バー数", minval=1, group="スイング(Phase2)")

show_fvg   = input.bool(true, "FVGを表示", group="FVG(Phase2)")
fvg_extend = input.int(20, "FVG box 右延長バー数", minval=0, group="FVG(Phase2)")
max_fvg    = input.int(30, "FVG box 最大表示数", minval=1, group="FVG(Phase2)")

setup_window = input.int(10, "setup/Ready有効バー数(イベント後)", minval=1, group="構造/スコア(Phase3)")
w_setup      = input.float(0.6, "fs加重: setup", step=0.05, group="構造/スコア(Phase3)")
w_exec       = input.float(0.4, "fs加重: exec",  step=0.05, group="構造/スコア(Phase3)")
show_struct  = input.bool(true, "CHoCH/BOSを表示", group="構造/スコア(Phase3)")

show_table  = input.bool(true, "情報テーブルを表示", group="表示")
lang_mode   = input.string("日本語", "表示言語 / Display Language", options=["日本語", "English"], group="表示")
dashboard_mode = input.string("Full", "ダッシュボード表示モード", options=["Full", "Mobile"], group="表示")
show_levels = input.bool(true, "Entry/SL/TPラベルを表示", group="表示")

entry_buy_color        = input.color(color.new(color.green, 0), "Entryマーカー色(BUY/緑▲) ※カスタム時はBias/dir表示にも連動", group="描画カラー設定")
entry_sell_color       = input.color(color.new(color.red, 0), "Entryマーカー色(SELL/赤▼) ※カスタム時はBias/dir表示にも連動", group="描画カラー設定")
swing_high_color       = input.color(color.new(color.gray, 0), "スイング高 マーカー色", group="描画カラー設定")
swing_low_color        = input.color(color.new(color.blue, 0), "スイング安 マーカー色", group="描画カラー設定")
basis_fvg_border_color = input.color(color.new(color.yellow, 0), "根拠FVG 枠色", group="描画カラー設定")
basis_fvg_fill_color   = input.color(color.new(color.yellow, 70), "根拠FVG 塗り色", group="描画カラー設定")
entry_line_color       = input.color(color.new(color.white, 0), "Entryライン色", group="描画カラー設定")
sl_swing_line_color    = input.color(color.new(color.red, 0), "SL(swing)ライン色", group="描画カラー設定")
sl_fvg_line_color      = input.color(color.new(color.red, 50), "SL(FVG)ライン色", group="描画カラー設定")
tp1_line_color         = input.color(color.new(color.teal, 0), "TP1ライン色", group="描画カラー設定")
tp2_line_color         = input.color(color.new(color.teal, 30), "TP2ライン色", group="描画カラー設定")
entry_marker_size_in   = input.string("Small", "Entryマーカーサイズ(▲▼)", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="描画カラー設定")
f_dash_size(s) => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : size.small

entry_label_bg_color   = input.color(color.new(color.white, 80), "Entryラベル背景色", group="描画カラー設定")
entry_label_text_color = input.color(color.white, "Entryラベル文字色", group="描画カラー設定")
entry_label_size_in    = input.string("Small", "Entryラベルサイズ", options=["Tiny", "Small", "Normal", "Large"], group="描画カラー設定")
sl_label_bg_color      = input.color(color.new(color.red, 85), "SLラベル背景色", group="描画カラー設定")
sl_label_text_color    = input.color(color.red, "SLラベル文字色", group="描画カラー設定")
sl_label_size_in       = input.string("Tiny", "SLラベルサイズ", options=["Tiny", "Small", "Normal", "Large"], group="描画カラー設定")
tp_label_bg_color      = input.color(color.new(color.teal, 85), "TPラベル背景色", group="描画カラー設定")
tp_label_text_color    = input.color(color.teal, "TPラベル文字色", group="描画カラー設定")
tp_label_size_in       = input.string("Tiny", "TPラベルサイズ", options=["Tiny", "Small", "Normal", "Large"], group="描画カラー設定")

color_preset = input.string("カスタム", "カラープリセット", options=["カスタム", "ダーク", "ライト", "ターミナル(グリーン)", "ハイコントラスト(色弱対応)"], group="ダッシュボード設定")

dash_bg_color             = input.color(color.new(color.black, 20), "背景色(通常セル) ※カスタム時のみ", group="ダッシュボード設定")
dash_text_color           = input.color(color.white, "文字色(通常セル) ※カスタム時のみ", group="ダッシュボード設定")
dash_highlight_text_color = input.color(color.black, "文字色(色付きセル) ※カスタム時のみ", group="ダッシュボード設定")
dash_text_size_in         = input.string("Small", "ダッシュボード文字サイズ", options=["Tiny", "Small", "Normal", "Large"], group="ダッシュボード設定")

col_dir_flat = input.color(color.new(color.gray, 0), "色: 方向感flat(中立) ※カスタム時のみ", group="ダッシュボード設定")

col_entry_candidate = input.color(color.new(color.lime, 0), "色: entry_candidate ※カスタム時のみ", group="ダッシュボード設定")
col_ready            = input.color(color.new(color.yellow, 20), "色: ready ※カスタム時のみ", group="ダッシュボード設定")
col_break_alert       = input.color(color.new(color.orange, 0), "色: break_alert ※カスタム時のみ", group="ダッシュボード設定")
col_condition_wait    = input.color(color.new(color.olive, 0), "色: condition_wait ※カスタム時のみ", group="ダッシュボード設定")
col_momentum_follow   = input.color(color.new(color.gray, 30), "色: momentum_follow ※カスタム時のみ", group="ダッシュボード設定")
col_noise             = input.color(color.new(color.black, 20), "色: noise ※カスタム時のみ", group="ダッシュボード設定")

col_ltf_pass = input.color(color.new(color.teal, 30), "色: 下位TFbreak達成 ※カスタム時のみ", group="ダッシュボード設定")
col_fs_pass  = input.color(color.new(color.teal, 0),  "色: fs達成(閾値超え) ※カスタム時のみ", group="ダッシュボード設定")

// ---------------------------------------------------------------------
// 1.5 カラープリセット解決
// ---------------------------------------------------------------------
f_palette(preset) =>
    color p_bg = na
    color p_fg = na
    color p_hfg = na
    color p_up = na
    color p_down = na
    color p_flat = na
    color p_entry_candidate = na
    color p_ready = na
    color p_break_alert = na
    color p_condition_wait = na
    color p_momentum_follow = na
    color p_noise = na
    color p_ltf_pass = na
    color p_fs_pass = na

    if preset == "ダーク"
        p_bg := color.new(color.black, 20)
        p_fg := color.white
        p_hfg := color.black
        p_up := color.new(color.green, 0)
        p_down := color.new(color.red, 0)
        p_flat := color.new(color.gray, 0)
        p_entry_candidate := color.new(color.lime, 0)
        p_ready := color.new(color.yellow, 20)
        p_break_alert := color.new(color.orange, 0)
        p_condition_wait := color.new(color.olive, 0)
        p_momentum_follow := color.new(color.gray, 30)
        p_noise := color.new(color.black, 20)
        p_ltf_pass := color.new(color.teal, 30)
        p_fs_pass := color.new(color.teal, 0)
    else if preset == "ライト"
        p_bg := color.new(color.white, 0)
        p_fg := color.new(color.black, 0)
        p_hfg := color.black
        p_up := color.new(color.green, 0)
        p_down := color.new(color.red, 0)
        p_flat := color.new(color.gray, 20)
        p_entry_candidate := color.new(color.lime, 20)
        p_ready := color.new(color.yellow, 30)
        p_break_alert := color.new(color.orange, 10)
        p_condition_wait := color.new(color.olive, 20)
        p_momentum_follow := color.new(color.silver, 0)
        p_noise := color.new(color.gray, 70)
        p_ltf_pass := color.new(color.teal, 40)
        p_fs_pass := color.new(color.teal, 20)
    else if preset == "ターミナル(グリーン)"
        p_bg := color.black
        p_fg := color.new(color.lime, 20)
        p_hfg := color.black
        p_up := color.new(color.lime, 0)
        p_down := color.new(color.red, 0)
        p_flat := color.new(color.yellow, 30)
        p_entry_candidate := color.new(color.lime, 0)
        p_ready := color.new(color.yellow, 10)
        p_break_alert := color.new(color.orange, 0)
        p_condition_wait := color.new(color.aqua, 40)
        p_momentum_follow := color.new(color.gray, 50)
        p_noise := color.black
        p_ltf_pass := color.new(color.lime, 40)
        p_fs_pass := color.new(color.lime, 20)
    else if preset == "ハイコントラスト(色弱対応)"
        p_bg := color.black
        p_fg := color.white
        p_hfg := color.black
        p_up := color.new(#1E90FF, 0)
        p_down := color.new(#FF8C00, 0)
        p_flat := color.white
        p_entry_candidate := color.new(#FFFF00, 0)
        p_ready := color.new(color.white, 30)
        p_break_alert := color.new(#FF8C00, 0)
        p_condition_wait := color.new(#1E90FF, 40)
        p_momentum_follow := color.new(color.gray, 40)
        p_noise := color.black
        p_ltf_pass := color.new(#FFFF00, 20)
        p_fs_pass := color.new(#FFFF00, 0)
    else // カスタム
        p_bg := dash_bg_color
        p_fg := dash_text_color
        p_hfg := dash_highlight_text_color
        p_up := entry_buy_color
        p_down := entry_sell_color
        p_flat := col_dir_flat
        p_entry_candidate := col_entry_candidate
        p_ready := col_ready
        p_break_alert := col_break_alert
        p_condition_wait := col_condition_wait
        p_momentum_follow := col_momentum_follow
        p_noise := col_noise
        p_ltf_pass := col_ltf_pass
        p_fs_pass := col_fs_pass

    [p_bg, p_fg, p_hfg, p_up, p_down, p_flat, p_entry_candidate, p_ready, p_break_alert, p_condition_wait, p_momentum_follow, p_noise, p_ltf_pass, p_fs_pass]

[eff_bg, eff_fg, eff_hfg, eff_up, eff_down, eff_flat, eff_entry_candidate, eff_ready, eff_break_alert, eff_condition_wait, eff_momentum_follow, eff_noise, eff_ltf_pass, eff_fs_pass] = f_palette(color_preset)

// ---------------------------------------------------------------------
// 2. モードによる足の自動設定
// ---------------------------------------------------------------------
is15 = exec_tf_mode == "15"

auto_mtf   = is15 ? "60"  : "15"   // 1H or 15M
auto_htf   = is15 ? "240" : "60"   // 4H or 1H
auto_subtf = is15 ? "5"   : "1"    // 確認用下位TF(executionの1段下)

tf_mtf = str.length(ctx_mtf_in) > 0 ? ctx_mtf_in : auto_mtf
tf_htf = str.length(ctx_htf_in) > 0 ? ctx_htf_in : auto_htf
tf_sub = str.length(ctx_subtf_in) > 0 ? ctx_subtf_in : auto_subtf

// ---------------------------------------------------------------------
// 3. MTF方向判定 + 日足FVG状態 + 確認用下位TF生データ取得
// ---------------------------------------------------------------------
f_dir() =>
    e   = ta.ema(close, ema_len)
    up  = close > e and e > e[1]
    dn  = close < e and e < e[1]
    up ? 1 : dn ? -1 : 0

dir_mtf = request.security(syminfo.tickerid, tf_mtf, f_dir(), lookahead=barmerge.lookahead_off)[1]
dir_htf = request.security(syminfo.tickerid, tf_htf, f_dir(), lookahead=barmerge.lookahead_off)[1]

f_dirstr(d) => d > 0 ? "up" : d < 0 ? "down" : "flat"
f_dircol(d) => d > 0 ? eff_up : d < 0 ? eff_down : eff_flat

// 日足FVG(box型はrequest.securityを跨げないためプリミティブのみ返す)
f_daily_fvg_state() =>
    bull = low > high[2] and close[1] > high[2]
    bear = high < low[2] and close[1] < low[2]
    var float dBullTop = na
    var float dBullBot = na
    var float dBearTop = na
    var float dBearBot = na
    if bull
        dBullTop := low
        dBullBot := high[2]
    if bear
        dBearTop := low[2]
        dBearBot := high
    if not na(dBullBot) and close < dBullBot
        dBullTop := na
        dBullBot := na
    if not na(dBearTop) and close > dBearTop
        dBearTop := na
        dBearBot := na
    [dBullTop, dBullBot, dBearTop, dBearBot]

[d_bull_top, d_bull_bot, d_bear_top, d_bear_bot] = request.security(syminfo.tickerid, "D", f_daily_fvg_state(), barmerge.gaps_off, barmerge.lookahead_off)

// 確認用下位TFの生データ(CHoCH/FVGリトレースの簡易代替: レンジブレイク確認用)
[ltf_h, ltf_l, ltf_c] = request.security_lower_tf(syminfo.tickerid, tf_sub, [high, low, close])

// ---------------------------------------------------------------------
// 4. スイング検出（構造の素）
// ---------------------------------------------------------------------
ph = ta.pivothigh(high, swing_len, swing_len)
pl = ta.pivotlow(low,  swing_len, swing_len)

plotshape(show_swing and not na(ph) ? high[swing_len] : na, title="スイング高マーカー", style=shape.circle, location=location.abovebar, color=swing_high_color, size=size.tiny, offset=-swing_len, editable=false)
plotshape(show_swing and not na(pl) ? low[swing_len]  : na, title="スイング安マーカー",  style=shape.circle, location=location.belowbar, color=swing_low_color, size=size.tiny, offset=-swing_len, editable=false)

// ---------------------------------------------------------------------
// 5. FVG検出 & box描画 + Ready状態の捕捉
//
//    検出ルールはLuxAlgoのオープンソーススクリプト「Fair Value Gap [LuxAlgo]」
//    (https://www.tradingview.com/script/jWY4Uiez-Fair-Value-Gap-LuxAlgo/) の
//    3本足インバランス判定(bullish: low > high[2] and close[1] > high[2] /
//    bearish: high < low[2] and close[1] < low[2])に基づく。当該検出ロジック
//    についてLuxAlgo氏にクレジットを表する。
//
//    一方、サイズフィルター(元のパーセンテージ閾値の代わりにATR倍数を使用)、
//    本セクション以降で実装するReady→Fireの2段階確認フロー、日足FVGとの重なり
//    およびPremium/Discount整合によるS/A/Bグレーディング、加重コンフルエンス
//    スコア(fs)、2系統SL・TPの自動描画、根拠FVGのハイライト等は、元のLuxAlgo
//    スクリプト(ミティゲーション追跡のみのFVG描画ツール)には存在しない本
//    スクリプト独自の実装である。
// ---------------------------------------------------------------------
atr14 = ta.atr(14)

type FVG
    box   bx
    float top
    float bot
    bool  bull
    int   cbar
    bool  retested

var array<FVG> fvgs = array.new<FVG>()

fvg_created_buy  = false
fvg_created_sell = false
fvg_retest_buy   = false
fvg_retest_sell  = false

// Ready状態 & 根拠FVG(basis)の捕捉用変数(売買サイドごとに保持)
var bool  ready_buy  = false
var bool  ready_sell = false
var int   ready_bar_buy  = na
var int   ready_bar_sell = na
var float basis_fvg_top_buy  = na
var float basis_fvg_bot_buy  = na
var box   basis_fvg_box_buy  = na
var int   basis_fvg_cbar_buy = na
var float basis_fvg_top_sell = na
var float basis_fvg_bot_sell = na
var box   basis_fvg_box_sell = na
var int   basis_fvg_cbar_sell = na

// 現在ハイライト中のFVG box(色戻し処理&deleteされた場合の参照クリア用)
// box型同士は==で比較できないため、生成バー(cbar)とbull/bearの組み合わせを識別キーとして使う
var box  highlighted_fvg_box      = na
var int  highlighted_fvg_cbar     = na
var bool highlighted_fvg_was_bull = false

bull_fvg = low > high[2] and close[1] > high[2]
bear_fvg = high < low[2] and close[1] < low[2]

bull_size_ok = (low - high[2]) >= fvg_atr_mult * atr14
bear_size_ok = (low[2] - high) >= fvg_atr_mult * atr14

if barstate.isconfirmed and show_fvg
    if bull_fvg and bull_size_ok
        f = FVG.new(box.new(bar_index[2], low, bar_index + fvg_extend, high[2], border_color=color.new(color.green, 60), bgcolor=color.new(color.green, 85)), low, high[2], true, bar_index, false)
        array.push(fvgs, f)
        fvg_created_buy := true
    if bear_fvg and bear_size_ok
        f = FVG.new(box.new(bar_index[2], low[2], bar_index + fvg_extend, high, border_color=color.new(color.red, 60), bgcolor=color.new(color.red, 85)), low[2], high, false, bar_index, false)
        array.push(fvgs, f)
        fvg_created_sell := true

    if array.size(fvgs) > 0
        for i = array.size(fvgs) - 1 to 0
            f = array.get(fvgs, i)
            filled = f.bull ? close < f.bot : close > f.top
            if filled
                if not na(highlighted_fvg_cbar) and f.cbar == highlighted_fvg_cbar and f.bull == highlighted_fvg_was_bull
                    highlighted_fvg_box := na
                    highlighted_fvg_cbar := na
                box.delete(f.bx)
                array.remove(fvgs, i)
            else
                touched = high >= f.bot and low <= f.top
                if touched and bar_index > f.cbar and not f.retested
                    f.retested := true
                    if f.bull
                        fvg_retest_buy := true
                        basis_fvg_top_buy := f.top
                        basis_fvg_bot_buy := f.bot
                        basis_fvg_box_buy := f.bx
                        basis_fvg_cbar_buy := f.cbar
                        ready_buy := true
                        ready_bar_buy := bar_index
                    else
                        fvg_retest_sell := true
                        basis_fvg_top_sell := f.top
                        basis_fvg_bot_sell := f.bot
                        basis_fvg_box_sell := f.bx
                        basis_fvg_cbar_sell := f.cbar
                        ready_sell := true
                        ready_bar_sell := bar_index
                box.set_right(f.bx, bar_index + fvg_extend)

    while array.size(fvgs) > max_fvg
        old = array.shift(fvgs)
        if not na(highlighted_fvg_cbar) and old.cbar == highlighted_fvg_cbar and old.bull == highlighted_fvg_was_bull
            highlighted_fvg_box := na
            highlighted_fvg_cbar := na
        box.delete(old.bx)

// ---------------------------------------------------------------------
// 6. 構造イベント(CHoCH / BOS)
// ---------------------------------------------------------------------
var float upSwing = na
var float dnSwing = na
var int   upSwingBar = na
var int   dnSwingBar = na
var float lastSwingHi = na
var float lastSwingLo = na
var int   bias    = 0
var int   lastEvtBar  = na
var int   lastEvtType = 0
var int   lastEvtDir  = 0

bosUp   = false
bosDn   = false
chochUp = false
chochDn = false

f_draw_struct(level, fromBar, isUp, isChoch) =>
    col = isChoch ? color.orange : (isUp ? color.new(color.green, 0) : color.new(color.red, 0))
    line.new(fromBar, level, bar_index, level, color=col, style=line.style_solid, width=1)
    txt = isChoch ? "CHoCH" : "BOS"
    mid = math.round((fromBar + bar_index) / 2)
    label.new(mid, level, txt, style=label.style_none, textcolor=col, size=size.small)

if barstate.isconfirmed
    if not na(ph)
        upSwing := ph
        upSwingBar := bar_index - swing_len
        lastSwingHi := ph
    if not na(pl)
        dnSwing := pl
        dnSwingBar := bar_index - swing_len
        lastSwingLo := pl

    if not na(upSwing) and close > upSwing
        if bias <= 0
            chochUp := true
            bias := 1
        else
            bosUp := true
        lastEvtBar  := bar_index
        lastEvtType := chochUp ? 2 : 1
        lastEvtDir  := 1
        if show_struct
            f_draw_struct(upSwing, na(upSwingBar) ? bar_index - 1 : upSwingBar, true, chochUp)
        upSwing := na

    if not na(dnSwing) and close < dnSwing
        if bias >= 0
            chochDn := true
            bias := -1
        else
            bosDn := true
        lastEvtBar  := bar_index
        lastEvtType := chochDn ? 2 : 1
        lastEvtDir  := -1
        if show_struct
            f_draw_struct(dnSwing, na(dnSwingBar) ? bar_index - 1 : dnSwingBar, false, chochDn)
        dnSwing := na

// ---------------------------------------------------------------------
// 7. ゾーン距離(ATR正規化) + プレミアム/ディスカウント
// ---------------------------------------------------------------------
f_zone_dist(isBull) =>
    float best = na
    if array.size(fvgs) > 0
        for i = 0 to array.size(fvgs) - 1
            f = array.get(fvgs, i)
            if f.bull == isBull
                float d = close > f.top ? close - f.top : close < f.bot ? f.bot - close : 0.0
                best := na(best) or d < best ? d : best
    na(best) or atr14 == 0 ? na : best / atr14

zdist_buy  = f_zone_dist(true)
zdist_sell = f_zone_dist(false)

rangeHi = ta.highest(high, fvg_lookback)
rangeLo = ta.lowest(low,  fvg_lookback)
eq      = (rangeHi + rangeLo) / 2
inDiscount = close < eq
inPremium  = close > eq

// ---------------------------------------------------------------------
// 8. セットアップ判定(setup相当) + スコアリング(FVGグレード反映)
// ---------------------------------------------------------------------
side_is_buy  = bias > 0
side_is_sell = bias < 0
side_str = side_is_buy ? "BUY" : side_is_sell ? "SELL" : "none"

// サイドに応じた根拠FVG(basis)
basis_fvg_top = side_is_buy ? basis_fvg_top_buy : side_is_sell ? basis_fvg_top_sell : na
basis_fvg_bot = side_is_buy ? basis_fvg_bot_buy : side_is_sell ? basis_fvg_bot_sell : na
basis_fvg_box = side_is_buy ? basis_fvg_box_buy : side_is_sell ? basis_fvg_box_sell : na
basis_fvg_cbar = side_is_buy ? basis_fvg_cbar_buy : side_is_sell ? basis_fvg_cbar_sell : na

// 日足FVGとの重なり(Grade S=3) / Premium-Discount整合(Grade A=2) / それ以外(Grade B=1)
f_fvg_grade(top, bot, isBull) =>
    overlap_daily = isBull ? (not na(d_bull_bot) and bot <= d_bull_top and top >= d_bull_bot) : (not na(d_bear_top) and top >= d_bear_bot and bot <= d_bear_top)
    in_pd = isBull ? inDiscount : inPremium
    overlap_daily and use_daily_fvg_grade ? 3 : in_pd ? 2 : 1

fvg_grade = (not na(basis_fvg_top) and not na(basis_fvg_bot)) ? f_fvg_grade(basis_fvg_top, basis_fvg_bot, side_is_buy) : 0

evt_recent = not na(lastEvtBar) and (bar_index - lastEvtBar) <= setup_window
zdist_side = side_is_buy ? zdist_buy : side_is_sell ? zdist_sell : na
pulled_back = not na(zdist_side) and zdist_side <= 2.5

setup_ok = (side_is_buy or side_is_sell) and evt_recent and pulled_back and lastEvtDir == bias
setup_type = not setup_ok ? "none" : (lastEvtType == 2 ? "break_pullback" : "continuation")

sc_struct = evt_recent and lastEvtDir == bias ? 40 : 0
sc_fvg    = na(zdist_side) ? 0 : zdist_side == 0 ? (fvg_grade == 3 ? 40 : fvg_grade == 2 ? 30 : 20) : zdist_side <= 2.5 ? 15 : 0
sc_pd     = (side_is_buy and inDiscount) or (side_is_sell and inPremium) ? 30 : 0
s_setup   = (side_is_buy or side_is_sell) ? math.min(100, sc_struct + sc_fvg + sc_pd) : 0

bars_since = na(lastEvtBar) ? 9999 : bar_index - lastEvtBar
sc_fresh = bars_since <= 1 ? 50 : bars_since <= 3 ? 35 : bars_since <= setup_window ? 20 : 0
sc_retest = na(zdist_side) ? 0 : (zdist_side == 0 ? 50 : zdist_side <= 2.5 ? 30 : 10)
s_exec = (side_is_buy or side_is_sell) ? math.min(100, sc_fresh + sc_retest) : 0

fs = math.round(w_setup * s_setup + w_exec * s_exec)

fs_min_eff = fs_min_auto ? (is15 ? 55 : 65) : fs_min

// ---------------------------------------------------------------------
// 9. Ready -> Fire 反転確認(ローソク足パターン + 下位TFレンジブレイク)
// ---------------------------------------------------------------------
bar_range = high - low

bullish_engulf = close > open and open <= close[1] and close > open[1] and close > high[1]
bullish_pin    = bar_range > 0 and (close - low) > bar_range * 0.6 and (high - close) < bar_range * 0.25
bearish_engulf = close < open and open >= close[1] and close < open[1] and close < low[1]
bearish_pin    = bar_range > 0 and (high - close) > bar_range * 0.6 and (close - low) < bar_range * 0.25

sgn_side = side_is_buy ? 1 : side_is_sell ? -1 : 0

f_ltf_range_break(h_arr, l_arr, c_arr, lookback, sgn) =>
    n = array.size(h_arr)
    okLen = n >= lookback + 1
    rangeHiLtf = okLen ? array.max(array.slice(h_arr, math.max(0, n - lookback - 1), n - 1)) : na
    rangeLoLtf = okLen ? array.min(array.slice(l_arr, math.max(0, n - lookback - 1), n - 1)) : na
    lastC = okLen ? array.get(c_arr, n - 1) : na
    okLen and sgn == 1 ? lastC > rangeHiLtf : okLen and sgn == -1 ? lastC < rangeLoLtf : false

ltf_break_ok = use_ltf_break ? f_ltf_range_break(ltf_h, ltf_l, ltf_c, ltf_lookback, sgn_side) : false

reversal_confirm_buy  = bullish_engulf or bullish_pin or chochUp or bosUp or (ltf_break_ok and sgn_side == 1)
reversal_confirm_sell = bearish_engulf or bearish_pin or chochDn or bosDn or (ltf_break_ok and sgn_side == -1)

fire_buy  = side_is_buy  and ready_buy  and reversal_confirm_buy  and not na(ready_bar_buy)  and (bar_index - ready_bar_buy)  <= setup_window
fire_sell = side_is_sell and ready_sell and reversal_confirm_sell and not na(ready_bar_sell) and (bar_index - ready_bar_sell) <= setup_window

// Ready状態のリセット(発火 or タイムアウト)
if fire_buy or (ready_buy and not na(ready_bar_buy) and (bar_index - ready_bar_buy) > setup_window)
    ready_buy := false
if fire_sell or (ready_sell and not na(ready_bar_sell) and (bar_index - ready_bar_sell) > setup_window)
    ready_sell := false

// ---------------------------------------------------------------------
// 10. 発火条件の統合
// ---------------------------------------------------------------------

// (1) MTF整合 (HTF/MTFのみ。execTF側の整合はReady/Fireの構造確認が担う)
f_mtf_ok(sgn) =>
    a_htf = dir_htf == sgn
    a_mtf = dir_mtf == sgn
    mtf_mode == "strict" ? (a_htf and a_mtf) : (a_htf or a_mtf)

mtf_ok = (sgn_side != 0) and f_mtf_ok(sgn_side)

// (2) トリガー: Ready->Fire確定 or スコアベースsetup
trig_retest_confirmed = (side_is_buy and fire_buy) or (side_is_sell and fire_sell)
trig_setup  = setup_ok and s_setup >= 50
trigger     = trig_retest_confirmed or trig_setup

fvg_state = (side_is_buy and ready_buy) or (side_is_sell and ready_sell) ? "ready" : trig_retest_confirmed ? "fire" : (side_is_buy and fvg_created_buy) or (side_is_sell and fvg_created_sell) ? "created" : "none"

// (4) セッション
in_session = not use_session or not na(time(timeframe.period, session_str, tz_str))

// (5) クールダウン
var int lastFireBar = na
var int lastFireDir = 0
same_dir_recent = not na(lastFireBar) and lastFireDir == sgn_side and (bar_index - lastFireBar) <= cooldown_bars
cooled = not same_dir_recent

// (6) 降格条件(反対側FVGの内側にいる)
opp_inside = side_is_buy ? (not na(zdist_sell) and zdist_sell == 0) : side_is_sell ? (not na(zdist_buy) and zdist_buy == 0) : false

// --- entry_candidate(Fire) ---
fire_candidate = (sgn_side != 0) and mtf_ok and trigger and (fs >= fs_min_eff) and in_session and cooled and not opp_inside

// --- break_alert(Phase A: 構造ブレイク単独の即時通知) ---
break_alert_cond = barstate.isconfirmed and (sgn_side != 0) and mtf_ok and in_session and ((side_is_buy and (bosUp or chochUp)) or (side_is_sell and (bosDn or chochDn)))

// --- アラートランク ---
alert_mode = fire_candidate ? "entry_candidate" : ((side_is_buy and ready_buy) or (side_is_sell and ready_sell)) ? "ready" : break_alert_cond ? "break_alert" : (mtf_ok and not setup_ok) ? "condition_wait" : (sgn_side != 0 and not mtf_ok) ? "momentum_follow" : "noise"

// ---------------------------------------------------------------------
// 11. リスク計算(2段階SL: スイング/FVG) + 簡易$換算
// ---------------------------------------------------------------------
entryPrice = close

sl_swing = side_is_buy ? lastSwingLo : side_is_sell ? lastSwingHi : na
sl_fvg   = side_is_buy ? basis_fvg_bot : side_is_sell ? basis_fvg_top : na

sl   = sl_swing   // TP計算はスイングSL基準のまま(v1の挙動を維持)
risk = na(sl) ? na : math.abs(entryPrice - sl)
tp1  = na(risk) ? na : (side_is_buy ? entryPrice + risk * rr_tp1 : entryPrice - risk * rr_tp1)
tp2  = na(risk) ? na : (side_is_buy ? entryPrice + risk * rr_tp2 : entryPrice - risk * rr_tp2)

pip_size = syminfo.mintick * (str.contains(syminfo.ticker, "JPY") ? 100 : 10)

risk_pips_swing = na(sl_swing) ? na : math.abs(entryPrice - sl_swing) / pip_size
risk_pips_fvg   = na(sl_fvg)   ? na : math.abs(entryPrice - sl_fvg)   / pip_size
risk_usd_swing  = na(risk_pips_swing) ? na : risk_pips_swing * pip_value_per_lot * lot_size
risk_usd_fvg    = na(risk_pips_fvg)   ? na : risk_pips_fvg   * pip_value_per_lot * lot_size

// --- 利益方向の最寄り障壁POI（反対側FVG）---
f_nearest_poi(isBuy) =>
    float bestLv = na
    if array.size(fvgs) > 0
        for i = 0 to array.size(fvgs) - 1
            f = array.get(fvgs, i)
            if isBuy and not f.bull and f.bot > close
                bestLv := na(bestLv) or f.bot < bestLv ? f.bot : bestLv
            if not isBuy and f.bull and f.top < close
                bestLv := na(bestLv) or f.top > bestLv ? f.top : bestLv
    bestLv

poi_near = side_is_buy ? f_nearest_poi(true) : side_is_sell ? f_nearest_poi(false) : na
poi_type = na(poi_near) ? "none" : (side_is_buy ? "bear_fvg" : "bull_fvg")

// --- 確定足のみで発火（repaint防止）---
fire_confirmed = fire_candidate and barstate.isconfirmed

if fire_confirmed
    lastFireBar := bar_index
    lastFireDir := sgn_side

// ---------------------------------------------------------------------
// 12. 描画
// ---------------------------------------------------------------------
plotshape(fire_confirmed and side_is_buy and entry_marker_size_in == "Tiny"   ? low : na, title="Entryマーカー(BUY/Tiny)",   style=shape.triangleup, location=location.belowbar, color=eff_up, size=size.tiny, editable=false)
plotshape(fire_confirmed and side_is_buy and entry_marker_size_in == "Small"  ? low : na, title="Entryマーカー(BUY/Small)",  style=shape.triangleup, location=location.belowbar, color=eff_up, size=size.small, editable=false)
plotshape(fire_confirmed and side_is_buy and entry_marker_size_in == "Normal" ? low : na, title="Entryマーカー(BUY/Normal)", style=shape.triangleup, location=location.belowbar, color=eff_up, size=size.normal, editable=false)
plotshape(fire_confirmed and side_is_buy and entry_marker_size_in == "Large"  ? low : na, title="Entryマーカー(BUY/Large)",  style=shape.triangleup, location=location.belowbar, color=eff_up, size=size.large, editable=false)
plotshape(fire_confirmed and side_is_buy and entry_marker_size_in == "Huge"   ? low : na, title="Entryマーカー(BUY/Huge)",   style=shape.triangleup, location=location.belowbar, color=eff_up, size=size.huge, editable=false)
plotshape(fire_confirmed and side_is_sell and entry_marker_size_in == "Tiny"   ? high : na, title="Entryマーカー(SELL/Tiny)",   style=shape.triangledown, location=location.abovebar, color=eff_down, size=size.tiny, editable=false)
plotshape(fire_confirmed and side_is_sell and entry_marker_size_in == "Small"  ? high : na, title="Entryマーカー(SELL/Small)",  style=shape.triangledown, location=location.abovebar, color=eff_down, size=size.small, editable=false)
plotshape(fire_confirmed and side_is_sell and entry_marker_size_in == "Normal" ? high : na, title="Entryマーカー(SELL/Normal)", style=shape.triangledown, location=location.abovebar, color=eff_down, size=size.normal, editable=false)
plotshape(fire_confirmed and side_is_sell and entry_marker_size_in == "Large"  ? high : na, title="Entryマーカー(SELL/Large)",  style=shape.triangledown, location=location.abovebar, color=eff_down, size=size.large, editable=false)
plotshape(fire_confirmed and side_is_sell and entry_marker_size_in == "Huge"   ? high : na, title="Entryマーカー(SELL/Huge)",   style=shape.triangledown, location=location.abovebar, color=eff_down, size=size.huge, editable=false)

var label entryLbl = na
var label slLbl    = na
var label tp1Lbl   = na
var label tp2Lbl   = na

f_px(x) => na(x) ? "na" : str.tostring(x, format.mintick)

if fire_confirmed and not na(risk) and show_levels
    use_fvg_basis = trig_retest_confirmed and not na(sl_fvg)

    line.new(bar_index, close, bar_index + 12, close, color=entry_line_color, width=2, style=line.style_dashed)
    line.new(bar_index, sl_swing, bar_index + 12, sl_swing, color=sl_swing_line_color,  width=1)
    if use_fvg_basis
        line.new(bar_index, sl_fvg, bar_index + 12, sl_fvg, color=sl_fvg_line_color, width=1, style=line.style_dotted)
    line.new(bar_index, tp1, bar_index + 12, tp1, color=tp1_line_color,  width=1)
    line.new(bar_index, tp2, bar_index + 12, tp2, color=tp2_line_color, width=1)

    if not na(entryLbl)
        label.delete(entryLbl)
        label.delete(slLbl)
        label.delete(tp1Lbl)
        label.delete(tp2Lbl)

    entryLbl := label.new(bar_index, close, "Entry " + f_px(close), style=side_is_buy ? label.style_label_up : label.style_label_down, color=entry_label_bg_color, textcolor=entry_label_text_color, size=f_dash_size(entry_label_size_in))

    slText = "SL(swing) " + f_px(sl_swing) + (na(risk_usd_swing) ? "" : " (-" + str.tostring(risk_usd_swing, "#") + ")") + (use_fvg_basis ? "\nSL(FVG) " + f_px(sl_fvg) + (na(risk_usd_fvg) ? "" : " (-" + str.tostring(risk_usd_fvg, "#") + ")") : "\nSL(FVG) n/a(setup発火)")
    slLbl := label.new(bar_index + 12, sl_swing, slText, style=label.style_label_left, color=sl_label_bg_color, textcolor=sl_label_text_color, size=f_dash_size(sl_label_size_in))

    tp1Lbl := label.new(bar_index + 12, tp1, "TP1 " + f_px(tp1), style=label.style_label_left, color=tp_label_bg_color, textcolor=tp_label_text_color, size=f_dash_size(tp_label_size_in))
    tp2Lbl := label.new(bar_index + 12, tp2, "TP2 " + f_px(tp2), style=label.style_label_left, color=tp_label_bg_color, textcolor=tp_label_text_color, size=f_dash_size(tp_label_size_in))

    if use_fvg_basis and not na(basis_fvg_box)
        is_same_box = not na(highlighted_fvg_cbar) and highlighted_fvg_cbar == basis_fvg_cbar and highlighted_fvg_was_bull == side_is_buy
        if not na(highlighted_fvg_box) and not is_same_box
            box.set_border_color(highlighted_fvg_box, highlighted_fvg_was_bull ? color.new(color.green, 60) : color.new(color.red, 60))
            box.set_bgcolor(highlighted_fvg_box, highlighted_fvg_was_bull ? color.new(color.green, 85) : color.new(color.red, 85))
            box.set_border_width(highlighted_fvg_box, 1)
        box.set_border_color(basis_fvg_box, basis_fvg_border_color)
        box.set_bgcolor(basis_fvg_box, basis_fvg_fill_color)
        box.set_border_width(basis_fvg_box, 2)
        highlighted_fvg_box := basis_fvg_box
        highlighted_fvg_cbar := basis_fvg_cbar
        highlighted_fvg_was_bull := side_is_buy
    else if not na(highlighted_fvg_box)
        // setup発火など根拠FVGを伴わないFireの場合、前回の根拠FVGハイライトを解除する
        box.set_border_color(highlighted_fvg_box, highlighted_fvg_was_bull ? color.new(color.green, 60) : color.new(color.red, 60))
        box.set_bgcolor(highlighted_fvg_box, highlighted_fvg_was_bull ? color.new(color.green, 85) : color.new(color.red, 85))
        box.set_border_width(highlighted_fvg_box, 1)
        highlighted_fvg_box := na
        highlighted_fvg_cbar := na

f_mode_col(m) => m == "entry_candidate" ? eff_entry_candidate : m == "ready" ? eff_ready : m == "break_alert" ? eff_break_alert : m == "condition_wait" ? eff_condition_wait : m == "momentum_follow" ? eff_momentum_follow : eff_noise

f_action_text(m) => lang_mode == "English" ? (m == "entry_candidate" ? "Check arrow - consider entry" : m == "ready" ? "Waiting for reversal confirm (Ready)" : m == "break_alert" ? "Structure break - waiting for FVG retest" : m == "condition_wait" ? "MTF aligned - waiting for setup" : m == "momentum_follow" ? "Directional but MTF mismatch - reference only" : "Conditions not met - stand aside") : (m == "entry_candidate" ? "矢印を確認・エントリー検討" : m == "ready" ? "反転確認待ち(Ready)" : m == "break_alert" ? "構造ブレイク発生・FVG接近待ち" : m == "condition_wait" ? "MTF整合済み・setup待ち" : m == "momentum_follow" ? "方向ありMTF不整合・参考のみ" : "条件不足・見送り")

// ---------------------------------------------------------------------
// 13. Webhookペイロード送出 (alert)
// ---------------------------------------------------------------------
event = trig_retest_confirmed ? "fvg_retest_confirmed" : trig_setup ? "setup" : break_alert_cond ? "structure_break" : "none"

payload = "schema=oscar_layer2_v2" + ";sym=" + syminfo.ticker + ";exec_tf=" + exec_tf_mode + ";side=" + side_str + ";event=" + event + ";mtf_ok=" + (mtf_ok ? "true" : "false") + ";dir_mtf=" + f_dirstr(dir_mtf) + ";dir_htf=" + f_dirstr(dir_htf) + ";s_setup=" + str.tostring(s_setup, "#") + ";s_exec=" + str.tostring(s_exec, "#") + ";fs=" + str.tostring(fs, "#") + ";fvg_grade=" + str.tostring(fvg_grade, "#") + ";setup_ok=" + (setup_ok ? "true" : "false") + ";setup_type=" + setup_type + ";price=" + f_px(close) + ";sl_swing=" + f_px(sl_swing) + ";sl_fvg=" + f_px(sl_fvg) + ";risk_pips_swing=" + (na(risk_pips_swing) ? "na" : str.tostring(risk_pips_swing, "#.#")) + ";risk_pips_fvg=" + (na(risk_pips_fvg) ? "na" : str.tostring(risk_pips_fvg, "#.#")) + ";risk_usd_swing=" + (na(risk_usd_swing) ? "na" : str.tostring(risk_usd_swing, "#")) + ";risk_usd_fvg=" + (na(risk_usd_fvg) ? "na" : str.tostring(risk_usd_fvg, "#")) + ";tp1=" + f_px(tp1) + ";tp2=" + f_px(tp2) + ";atr=" + f_px(atr14) + ";fvg_state=" + fvg_state + ";alert_mode=" + alert_mode + ";poi_near=" + f_px(poi_near) + ";poi_type=" + poi_type

notify = (alert_mode == "entry_candidate" or alert_mode == "break_alert") and barstate.isconfirmed
if notify
    alert(payload, alert.freq_once_per_bar_close)

// ---------------------------------------------------------------------
// 14. 情報テーブル（右上）
// ---------------------------------------------------------------------
var table info = table.new(position.top_right, dashboard_mode == "Mobile" ? 1 : 2, dashboard_mode == "Mobile" ? 4 : 14, border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)

if show_table and barstate.islast
    bg = eff_bg
    fg = eff_fg
    hfg = eff_hfg
    ts = f_dash_size(dash_text_size_in)
    is_ready = (side_is_buy and ready_buy) or (side_is_sell and ready_sell)

    if dashboard_mode == "Mobile"
        table.cell(info, 0, 0, syminfo.ticker, bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 0, 1, f_action_text(alert_mode), bgcolor=f_mode_col(alert_mode), text_color=hfg, text_size=ts)
        table.cell(info, 0, 2, "Bias: " + side_str, bgcolor=f_dircol(bias), text_color=hfg, text_size=ts)
        table.cell(info, 0, 3, is_ready ? "Ready: YES" : "Ready: -", bgcolor=is_ready ? eff_ready : bg, text_color=is_ready ? hfg : fg, text_size=ts)
    else

        table.cell(info, 0, 0, "Bias", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 0, side_str, bgcolor=f_dircol(bias), text_color=hfg, text_size=ts)

        table.cell(info, 0, 1, "Action", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 1, f_action_text(alert_mode), bgcolor=f_mode_col(alert_mode), text_color=hfg, text_size=ts)

        table.cell(info, 0, 2, "Trigger", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 2, event, bgcolor=bg, text_color=fg, text_size=ts)

        table.cell(info, 0, 3, "dir MTF (" + tf_mtf + ")", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 3, f_dirstr(dir_mtf), bgcolor=f_dircol(dir_mtf), text_color=hfg, text_size=ts)

        table.cell(info, 0, 4, "dir HTF (" + tf_htf + ")", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 4, f_dirstr(dir_htf), bgcolor=f_dircol(dir_htf), text_color=hfg, text_size=ts)

        table.cell(info, 0, 5, "Ready", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 5, is_ready ? "YES" : "-", bgcolor=is_ready ? eff_ready : bg, text_color=is_ready ? hfg : fg, text_size=ts)

        table.cell(info, 0, 6, "下位TF(" + tf_sub + ")break", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 6, ltf_break_ok ? "YES" : "-", bgcolor=ltf_break_ok ? eff_ltf_pass : bg, text_color=ltf_break_ok ? hfg : fg, text_size=ts)

        table.cell(info, 0, 7, "s_setup / s_exec", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 7, str.tostring(s_setup, "#") + " / " + str.tostring(s_exec, "#"), bgcolor=bg, text_color=fg, text_size=ts)

        fs_ok = fs >= fs_min_eff
        table.cell(info, 0, 8, "fs", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 8, str.tostring(fs, "#") + " / " + str.tostring(fs_min_eff), bgcolor=fs_ok ? eff_fs_pass : bg, text_color=fs_ok ? hfg : fg, text_size=ts)

        table.cell(info, 0, 9, "FVG grade", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 9, fvg_grade == 3 ? "S(日足重複)" : fvg_grade == 2 ? "A(PD整合)" : fvg_grade == 1 ? "B" : "-", bgcolor=bg, text_color=fg, text_size=ts)

        table.cell(info, 0, 10, "setup_type", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 10, setup_type, bgcolor=bg, text_color=fg, text_size=ts)

        table.cell(info, 0, 11, "SL swing/FVG", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 11, f_px(sl_swing) + " / " + f_px(sl_fvg), bgcolor=bg, text_color=fg, text_size=ts)

        table.cell(info, 0, 12, "alert_mode(raw)", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 12, alert_mode, bgcolor=f_mode_col(alert_mode), text_color=hfg, text_size=ts)

        table.cell(info, 0, 13, "モード", bgcolor=bg, text_color=fg, text_size=ts)
        table.cell(info, 1, 13, exec_tf_mode + "分", bgcolor=bg, text_color=fg, text_size=ts)

// =====================================================================
//  v2: Bias=HTF/MTFのみ / Ready->Fire 2段階確認(包み足・ピンバー・
//      ミニ構造ブレイク・下位TFレンジブレイクのいずれか) / 日足FVGグレード
//      2段階SL($簡易換算) / Entry-SL-TPラベル描画 + 根拠FVGハイライト
// =====================================================================
````
