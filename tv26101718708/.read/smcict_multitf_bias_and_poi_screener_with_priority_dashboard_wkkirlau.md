# SMC/ICT Multi-TF Bias and POI Screener with Priority Dashboard

- url: https://www.tradingview.com/script/wkkirLau/
- type: indicator
- pine_id: PUB;1bb5297479f34771a26226880c5c8af0
- version: 1.0

## Description

Overview
This indicator is a comprehensive Smart Money Concepts (SMC) / ICT-based multi-timeframe bias and Point of Interest (POI) screener. It evaluates market direction across three timeframes simultaneously — Anchor (HTF), Primary (MTF), and Local (LTF) — and identifies the most relevant POI (Fair Value Gap or Order Block) that price is approaching. A priority dashboard (S / A / B / C / D) tells the trader exactly whether to act now, prepare, wait, or stand aside, removing subjectivity from the decision process.
The core idea is that Smart Money moves in a top-down structure: higher timeframe bias defines the directional edge, and a trader should only look for entries at POIs that are aligned with that bias. This script automates that entire top-down filtering process.

How It Works
1. Multi-Timeframe Bias Engine
Bias is computed independently on each of three timeframes using a combination of two sub-signals:

・EMA Crossover: Fast EMA vs. Slow EMA relationship determines trend direction. An optional slope filter (Use slow EMA slope for Neutral filter) suppresses bias signals when the slow EMA slope is below a minimum threshold relative to ATR, preventing false signals during ranging conditions.
・Market Structure (HH/HL / LH/LL): Pivot-based swing structure is tracked using ta.pivothigh / ta.pivotlow. The script classifies each timeframe as Bullish (HH+HL), Bearish (LH+LL), Breaking Up (CHoCH bullish), Breaking Down (CHoCH bearish), or Unclear.

The two sub-signals are combined according to the Bias Logic setting:

・EMA only: Uses EMA crossover alone
・HH/HL only: Uses structure alone
・EMA + HH/HL agreement: Requires both signals to agree; outputs Neutral if they conflict
・EMA primary + HH/HL filter: EMA is the primary signal, but structure acting against EMA suppresses the bias to Neutral

The three timeframe bias values (Anchor, Primary, Local) are then combined according to Bias Mode:

・Anchor + Primary Aligned: Both must agree for a bias to be declared
・Primary + Anchor Filter: Primary is the main bias; Anchor acting against it raises a COUNTER_ANCHOR warning
・Primary Only / Anchor Only: Single-timeframe bias

2. POI Detection — Fair Value Gap (FVG) and Order Block (OB)
FVGs are detected on each of the three timeframes using a three-candle imbalance pattern (low[0] > high[2] for bullish, high[0] < low[2] for bearish). Optional filters include:

・Close confirmation: Requires the middle candle to close beyond the imbalance gap
・Auto threshold: Compares the middle candle's body size against a 100-bar average to eliminate small, low-quality imbalances
・Minimum FVG size / ATR: Rejects gaps below a minimum size relative to ATR
・Invalidation: A bullish FVG is invalidated when price closes (or wicks) below its lower boundary; bearish FVG when price closes (or wicks) above its upper boundary
・Max age: FVGs older than a preset bar count are discarded

OBs are detected using a range-breakout approach: the highest high / lowest low over a lookback window defines the boundary. A breakout above (below) triggers an Order Block from the most recent bearish (bullish) candle. High-volatility candles are parsed inversely (body is treated as shadow). OBs are invalidated when price closes back through the block.

3. POI Priority Selection
For both long and short directions, the script selects the single most relevant POI using a distance-to-price scoring system:

・Anchor FVG vs. Primary FVG: The closer one to current price is selected as the "HTF POI"
・HTF POI vs. Local FVG vs. OB: The closest of the three to price becomes the Active POI

This ensures the dashboard always displays the POI with the highest immediate relevance.

4. Priority Classification (S / A / B / C / D)
The priority code is the central output of the indicator:
Code   | Meaning                                              | Condition
-------|------------------------------------|----------------------------------
S         | Act now — price inside POI                | POI exists, bias aligned, inside
A         | Prepare — price approaching            | POI exists, bias aligned, near
B         | Wait — setup valid, price far              | POI exists, bias aligned, far
C         | Low confidence — anchor opposes  | COUNTER_ANCHOR active
D         | Stand aside — no valid setup             | No POI, no bias, or bias conflict

5. Warning System
Six independent warning flags are evaluated and displayed:

・LOCAL_CHOCH — Local timeframe is showing a Change of Character (CHoCH) against the primary bias, indicating a possible pullback or reversal
・HTF_DISTANCE_FAR — The HTF POI is far from current price (beyond max ATR threshold), suggesting the structural POI may be out of immediate reach
・COUNTER_TRADE — The active POI direction is opposite to the main bias (e.g., a bearish POI is selected while bias is bullish)
・PD_WARNING — Price is in an unfavorable Premium/Discount zone (bullish bias in premium zone, or bearish bias in discount zone)
・LATE_TREND — The trend has potentially extended too far: bias is bullish but HTF P/D shows Premium, with price outside the HTF POI
・COUNTER_ANCHOR — Primary bias is active but Anchor timeframe opposes it

6. Premium / Discount Range
Three separate P/D ranges are computed across Anchor, Primary, and Local timeframes using ta.highest / ta.lowest over configurable lookback periods. The midpoint of each range defines the equilibrium level. Price above midpoint = Premium (potential shorting area for bearish bias); price below = Discount (potential buying area for bullish bias). P/D levels are plotted as lines on the chart.

7. Alert System
Alerts fire at bar close when the priority code meets the configured threshold (S only, S or A, S A B). The alert payload is a structured JSON message containing all dashboard fields, suitable for use with external webhook receivers.

Originality
Most SMC/ICT indicators address only one aspect of the framework — bias, or FVGs, or OBs — and require the trader to manually combine them across timeframes. This indicator is original in the following ways:

1.Unified three-timeframe bias engine: EMA and market structure signals are combined with configurable logic, giving the trader full control over how confluence is defined

2.Distance-based POI priority selection: Rather than displaying all zones, the script automatically selects the single most actionable POI by ranking FVGs (Anchor, Primary, Local) and OBs by their distance to current price

3.Priority classification with Warning overlay: A structured S/A/B/C/D priority system, combined with six distinct warning flags, provides a single actionable output per bar rather than requiring the trader to interpret multiple indicators simultaneously

4.Preset system (Swing / Daytrade / Scalp / Custom): All timeframe and parameter combinations are driven by a single preset selector. This allows the indicator to behave consistently across different trading styles without manual reconfiguration

5.JSON alert payload: The alert message is structured JSON, enabling integration with external tools for multi-symbol scanning or automated notification workflows

Credits: Order Block and Premium/Discount concepts referenced from Smart Money Concepts (SMC) [LuxAlgo]. Market Structure (BOS/CHoCH) logic referenced from Market Structures + ZigZag [TradingFinder]. FVG detection structure referenced from Fair Value Gap [LuxAlgo]. All logic in this script has been substantially rewritten and extended with original multi-timeframe coordination, priority classification, and alert architecture.

How to Use
Step 1 — Select a Preset
Open the "Bias" group and choose one of the four presets:
Preset      | Anchor | Primary | Local | Suited for
----------|--------|---------|-------|------------------
Swing       | Daily    | 4H         | 1H      | Multi-day swings
Daytrade  | 4H       | 1H         | 15M   | Intraday sessions
Scalp        | 1H       | 15M      | 5M      | Short-term scalps
Custom    | User    | User      | User   | Any configuration

Step 2 — Set Bias Logic
Choose how EMA and market structure signals are combined. The default EMA primary + HH/HL filter is recommended for most use cases: it uses the EMA crossover as the primary directional signal, but suppresses it when market structure is acting against that direction.

Step 3 — Monitor the Dashboard
The dashboard shows 16 rows of information. The most important rows are:
・Priority: The S/A/B/C/D code tells you immediately whether to act or wait
・Active Plan: "Long Watch" or "Short Watch" — the direction the indicator is currently tracking
・Action: A plain-language instruction (e.g., "Check Local TF now", "Wait for POI approach")
・Warning: Any active risk flags. If warnings are present, verify each condition before acting
・Active POI: The timeframe, type (FVG or OB), and direction of the current POI
・価格帯 (Price Range): The upper and lower boundary of the active POI zone
・現在位置 (Location): Whether price is inside the POI, approaching (WATCH distance), or still far

Step 4 — Read the POI Zone on the Chart
The active POI is drawn as an orange box by default. When price enters or approaches the zone and Priority S or A appears, switch to the Local timeframe chart and look for entry confirmation patterns (e.g., displacement candles, engulfing, CHoCH on even lower timeframes).

Step 5 — Set Alerts
In the "Alerts" group, select the minimum priority level for alerts (S only recommended for high-confidence entries). Enable Alert once per zone to avoid repeated alerts for the same POI. The alert message contains a complete JSON payload for webhook integration.

Parameter Reference
Bias Group
・Bias preset: Swing / Daytrade / Scalp / Custom. Drives all three timeframe selections and most default values simultaneously
・Custom only: anchor/primary/local TF: Active only when preset is Custom
・Bias mode: How the three TF biases are combined (see "How It Works")
・Bias logic: How EMA and structure sub-signals interact
・Anchor fast/slow EMA: EMA lengths for the Anchor timeframe bias
・Primary/Local fast/slow EMA: EMA lengths for Primary and Local timeframes (shared)
・Use slow EMA slope for Neutral filter: When enabled, a flat slow EMA suppresses the bias signal
・Slope lookback bars: Number of bars over which the EMA slope is measured
・Min slow EMA slope / ATR: Minimum slope-to-ATR ratio required to maintain a trend bias signal
・HH/HL pivot override: Override the pivot length for structure detection. - uses the preset value

Zones Group
・Track FVG / Track OB: Enable or disable each zone type
・Context mode: Fast uses only the Primary TF for context zones; Balanced adds Anchor TF FVGs
・Sync OB/PD timeframes with Bias preset: When enabled, OB and P/D timeframes follow the preset automatically
・Custom OB timeframe: Active when sync is disabled
・Max zone age override: Maximum bar age for any zone to remain active (- = preset)
・Anchor/Primary/Local FVG age override: Per-timeframe FVG age limits
・Min FVG size / ATR override: Minimum gap size as a ratio of ATR
・Require FVG close confirmation: Requires middle candle to close through the gap
・Use FVG auto threshold: Filters small FVGs relative to the 100-bar average candle body
・FVG invalidation source: Close uses closing price; Wick uses the high/low wick for invalidation
・OB pivot override: Pivot length for OB range calculation
・WATCH distance / ATR: Distance from POI at which Priority upgrades from B to A
・Max active POI distance / ATR: POIs farther than this from price are flagged with HTF_DISTANCE_FAR

Premium / Discount Group
・Custom PD range timeframe: Timeframe for the main P/D range (active when sync is off)
・PD lookback override: Lookback for the main P/D high/low range
・Custom HTF PD timeframe / lookback: Anchor-level P/D range
・Custom LTF PD timeframe / lookback: Local-level P/D range

Alerts Group
・Send priority alerts: Master enable for dynamic alerts
・Alert priority: Minimum code level to trigger (S only, S or A, S A B)
・Alert once per zone: Prevents repeated alerts for the same POI

Visuals Group
・Show active zone: Draws the active POI box on the chart
・Show long/short scenario zones: Draws both long and short POI boxes simultaneously (for reviewing both scenarios)
・Show context zones: Draws the HTF FVG and OB zones separately for reference
・Show PD high/low/mid levels: Plots P/D range boundaries and midpoint as lines
・Show dashboard: Enables or disables the dashboard table
・Dashboard position: Corner of the chart for the dashboard
・POI label offset bars: Number of bars to the right of the POI label


Preset Default Values Reference
Parameter                        |  Swing   |  Daytrade |  Scalp
------------------------|---------|-----------|------
Anchor TF                        | D           | 4H             | 1H
Primary TF                       | 4H         | 1H             | 15M
Local TF                           | 1H         | 15M          | 5M
Structure pivot                | 9            | 7               | 5
Max zone age (bars)      | 180        | 120          | 80
Min FVG size / ATR         | 0.08       | 0.10         | 0.12
OB pivot length               | 4            | 3               | 2
WATCH distance / ATR   | 0.75.     | 0.50         | 0.35
Max POI distance / ATR | 5.00       | 3.00         | 2.00
PD lookback (bars)        | 60          | 50             | 40

All override fields default to -, which applies the preset value. To customize individual parameters without changing the preset, enter a numeric value in the corresponding override field.

Important Limitations

This indicator is a decision-support tool. It does not guarantee future price behavior. All signals should be confirmed with price action analysis on the local timeframe before any trade is taken.
Backtest results from strategy tools do not apply to this indicator, which is an overlay indicator with no automated trade execution.
FVG and OB detection is based on the most recent valid zone per timeframe. In strongly trending markets, zones may be invalidated quickly and re-established at new levels.
The P/D range is calculated using a fixed lookback window. In trending markets, the midpoint may not represent a meaningful equilibrium.


説明文（日本語）

概要
　このインジケーターは、スマートマネーコンセプト（SMC）/ ICTの手法をベースに、3つの時間軸（アンカー・プライマリ・ローカル）のバイアスを同時に評価し、最も優先度の高いPOI（ポイント・オブ・インタレスト：FVGまたはオーダーブロック）を特定するマルチタイムフレーム・スクリーナーです。
　ダッシュボードに表示される優先度コード（S / A / B / C / D）が、「今すぐ確認」「接近中・準備」「待機」「見送り」をトレーダーに明確に伝えます。複数の指標を目視で組み合わせる作業を自動化し、トップダウン分析の判断プロセスをシンプルにすることが目的です。

ロジックの説明
1. マルチタイムフレーム・バイアスエンジン
　バイアスは3つの時間軸それぞれで、2つのサブシグナルを組み合わせて計算されます。

・EMAクロス: ファストEMAとスローEMAの位置関係でトレンド方向を判定。オプションのスロープフィルター（スローEMAスロープでニュートラルフィルター）を有効にすると、スローEMAの傾きがATR比で閾値を下回る局面ではバイアスをニュートラルに抑制し、レンジ相場でのダマシを減らします。
・市場構造（HH/HL / LH/LL）: ta.pivothigh / ta.pivotlowを使ってスウィング構造を追跡。各時間軸をBullish（HH+HL）・Bearish（LH+LL）・上昇転換（Bullish CHoCH）・下降転換（Bearish CHoCH）・不明確のいずれかに分類します。

この2つのサブシグナルはバイアスロジック設定により組み合わせ方が変わります。

・EMA only: EMAクロスのみ使用
・HH/HL only: 市場構造のみ使用
・EMA + HH/HL agreement: 両方が一致する場合のみバイアス確定、不一致はニュートラル
・EMA primary + HH/HL filter（推奨）: EMAを主軸とし、市場構造が逆を示す場合はニュートラルに切り替え

3時間軸のバイアスはバイアスモードで最終的に合算されます。

・Anchor + Primary Aligned: アンカーとプライマリが一致する場合のみバイアス確定
・Primary + Anchor Filter: プライマリを主軸、アンカーが逆の場合はCOUNTER_ANCHOR警告
・Primary Only / Anchor Only: 単一時間軸バイアス

2. POI検出 — FVGとオーダーブロック（OB）
　FVGは3時間軸それぞれで3本足のインバランスパターンから検出されます（low[0] > high[2]でBullish、high[0] < low[2]でBearish）。以下のフィルターを組み合わせて高品質のFVGのみを残します。

・クローズ確認: 中間足が必ずギャップを抜けてクローズすることを要求
・自動閾値: 中間足のボディサイズを100本平均と比較し、小さすぎるFVGを除外
・最小FVGサイズ / ATR比: ATR対比で一定以上の大きさのFVGのみ採用
・無効化: BullishFVGは下限を割り込むと消滅、BearishFVGは上限を上抜けると消滅
・最大バー数: 指定バー数を超えた古いFVGは自動的に破棄

　OBは、ルックバック期間の最高値・最安値を基準にしたレンジブレイクアウトで検出。上抜け時は直近の陰線をBullish OBとして、下抜け時は直近の陽線をBearish OBとして記録。高ボラティリティ足はボディとヒゲを逆に処理します。

3. POI優先度選択（距離スコアリング）
ロング・ショートそれぞれについて、以下の順序で「最も現在値に近いPOI」を自動選択します。

・アンカーFVG vs. プライマリFVG → 近い方を「HTF POI」として採用
・HTF POI vs. ローカルFVG vs. OB → 3者のうち最も近いものをアクティブPOIとして採用

これにより、ダッシュボードには常に「今最も価格が向かいやすいPOI」が一つだけ表示されます。

4. 優先度コード（S / A / B / C / D）
コード | 意味                                                   | 条件
-------|-----------------------------------|----------------------------------
S          | 即監視：価格がPOI内にある.          | POIあり・バイアス一致・POI内
A          | 高優先：POIに接近中                      | POIあり・バイアス一致・WATCH距離内
B          | 通常監視：価格は遠い                     | POIあり・バイアス一致・WATCH距離外
C          | 低優先：アンカーが逆方向             | COUNTER_ANCHOR状態
D          | 見送り：有効なセットアップなし  | POIなし・バイアスなし・競合

5. 警告システム

6種類の独立した警告フラグが評価・表示されます。
・LOCAL_CHOCH: ローカル足がプライマリバイアスに逆らうCHoCH（転換シグナル）を発生。押し目または反転の可能性を示唆
・HTF_DISTANCE_FAR: HTF POIが現在値から遠すぎる（ATR閾値超過）。即座にPOIに到達する可能性が低い
・COUNTER_TRADE: アクティブPOIの方向がメインバイアスと逆。逆張り的なセットアップを監視中
・PD_WARNING: 価格が不利なPremium/Discountゾーンにある（Bullishバイアスなのにプレミアム、など）
・LATE_TREND: トレンドが延びすぎている可能性。BullishバイアスなのにHTF P/DがPremiumで、HTF POI外に位置
・COUNTER_ANCHOR: プライマリバイアスが有効だがアンカーTFが逆方向

6. Premium / Discountレンジ
　アンカー・プライマリ・ローカルの3つの時間軸で、それぞれta.highest / ta.lowestを使って価格レンジを計算。各レンジの中間点（ミッドポイント）が均衡価格の目安となります。中間点より上がPremium（高値圏）、下がDiscount（安値圏）。P/Dの高値・安値・中間点はチャートにラインとして表示されます。

7. アラートシステム
　優先度コードが設定した閾値（S only、S or A、S A B）を満たす場合、バークローズ時にアラートが発火します。アラートメッセージはJSON形式で、ダッシュボードの全フィールドを含んでいます。Webhookを使った外部ツール連携に対応しています。

オリジナリティ
　SMC/ICTに関するインジケーターの多くは、バイアス・FVG・OBのいずれか一側面のみを扱うか、複数の概念を並列表示するだけで、トレーダー自身が手動で組み合わせる必要があります。本インジケーターは以下の点でオリジナルな設計を持ちます。

1.統合された3時間軸バイアスエンジン: EMAと市場構造の2シグナルを設定可能なロジックで組み合わせることで、「コンフルエンスの定義」をトレーダーが制御できる
2.距離スコアリングによるPOI自動選択: 全ゾーンを表示するのではなく、価格からの距離を基準に最もアクション優先度の高い単一POIを自動的に選択する
3.優先度コード + 6種類の警告フラグの統合: 複数の指標を目視で解釈する代わりに、S/A/B/C/Dという単一の判断コードと詳細な警告情報を出力する
4.プリセットシステム（Swing / Daytrade / Scalp / Custom）: 1つのプリセット選択で全時間軸とパラメーターが一括で最適化される
5.JSON形式のアラートペイロード: Webhook対応の構造化されたアラートで、複数銘柄スクリーニングや外部通知ワークフローへの統合が可能

クレジット: オーダーブロック・Premium/Discountの概念はSmart Money Concepts (SMC) [LuxAlgo]を、市場構造（BOS/CHoCH）ロジックはMarket Structures + ZigZag [TradingFinder]を、FVG検出構造はFair Value Gap [LuxAlgo]を参考にしています。本スクリプト内のすべてのロジックは実質的に独自に再設計・拡張されています。

使い方
ステップ1 ： プリセットを選ぶ
「Bias」グループで取引スタイルに合ったプリセットを選択します。

プリセット  | アンカー | プライマリ | ローカル | 用途
------------|----------|------------|----------|------------------
Swing          | 日足         | 4時間          | 1時間      | 複数日のスウィング
Daytrade     | 4時間      | 1時間          | 15分        | 日中トレード
Scalp           | 1時間      | 15分           | 5分          | 短期スキャルプ
Custom       | 任意         | 任意           | 任意         | カスタム構成

ステップ2 ： バイアスロジックを確認する
デフォルトのEMA primary + HH/HL filterは、EMAクロスを主軸としながら市場構造のフィルターが逆行時に安全弁として機能します。明確なトレンド相場ではほとんどの状況で適切に動作します。

ステップ3 ： ダッシュボードを読む
ダッシュボードは16行の情報を表示します。最重要項目は以下です。
・Priority（優先度）: S/A/B/C/Dコード。これだけ見れば即座に行動基準がわかります
・Active Plan: "Long Watch"または"Short Watch" — 現在どちらの方向を監視しているか
・Action: 平易な日本語での推奨行動（「今すぐローカルTF確認」「POI接近まで待つ」など）
・Warning（警告）: 有効な警告フラグ。警告がある場合は各内容を確認してからエントリーを判断
・Active POI: アクティブなPOIの時間軸・種類（FVG/OB）・方向
・価格帯: アクティブPOIの上限・下限
・現在位置: POI内 / POI接近 / 通過注意 / POI待ち のいずれか

ステップ4 ： チャート上のPOIゾーンを確認する
アクティブPOIはデフォルトでオレンジのボックスとして描画されます。価格がゾーン内に入りPriorityがSまたはAになったら、ローカル足チャートに切り替えてエントリー根拠（ディスプレイスメント、エンゲルフィング、下位足CHoCHなど）を確認します。

ステップ5 ： アラートを設定する
「Alerts」グループで優先度閾値を選択します（高確度エントリーのみ追うならS onlyを推奨）。Alert once per zoneを有効にすると、同一POIでのアラートの重複を防ぎます。

パラメーター解説
Biasグループ
パラメーター                                 | 内容
--------------------------------|------------------------------------------
Bias preset                                    | Swing/Daytrade/Scalp/Custom
                                                       | 選択するだけで全TFとデフォルト値が一括設定
Custom only: anchor/primary/    | Custom選択時のみ有効
  local TF                                       | 任意の時間軸を指定
Bias mode                                    | 3時間軸バイアスの合算方法
Bias logic                                      | EMAと市場構造の組み合わせ方
Anchor fast/slow EMA                 | アンカーTFのEMA期間
Primary/Local fast/slow EMA      | プライマリ・ローカル共通のEMA期間
Use slow EMA slope for              | スローEMAの傾きが小さい場合に
  Neutral filter                               | バイアスをニュートラルに抑制
Slope lookback bars                    | EMAスロープを計算するバー数
Min slow EMA slope / ATR          | バイアス維持に必要な最小スロープ比率
HH/HL pivot override                  | 市場構造検出のピボット長を上書き
                                                      | "-"でプリセット値を使用

Zonesグループ
パラメーター                                  | 内容
---------------------------------|------------------------------------------
Track FVG / Track OB                    | 各ゾーンタイプの有効/無効
Context mode                                | Fast=プライマリTFのみ
                                                         | Balanced=アンカーTFのFVGも追加
Sync OB/PD timeframes               | ONにするとOB・P/DのTFがプリセットに連動
Max zone age override                  | ゾーンの最大バー数（古いゾーンを無効化）
Min FVG size / ATR override         | FVGの最小サイズ（ATR倍率）
Require FVG close confirmation  | FVG中間足クローズ確認を要求
Use FVG auto threshold               | 100本平均対比で小さいFVGを除外
FVG invalidation source                | 無効化判定：Close=終値 / Wick=ヒゲ
WATCH distance / ATR                  | 優先度BからAに格上げされる距離
Max active POI distance / ATR     | 超過でHTF_DISTANCE_FAR警告が発動

Premium / Discountグループ
パラメーター                                 ｜内容
---------------------------------|-----------------------------------------
PD lookback override.                   |メインP/Dレンジの計算期間
HTF / LTF PD lookback override.  |アンカー・ローカルP/Dレンジの計算期間

Alertsグループ
パラメーター                 | 内容
-----------------------|--------------------------------
Send priority alerts       | アラート送信のマスタースイッチ
Alert priority                  | 発火させる最低優先度コード
Alert once per zone     | 同一POIへの重複アラートを防止

Visualsグループ
パラメーター                             | 内容
------------------------------|------------------------------------------
Show active zone                      | アクティブPOIのボックスを描画
Show long/short scenario        | ロング・ショット両シナリオのゾーンを同時表示
Show context zones                 | HTF FVGとOBのゾーンを別途描画（参考用）
Show PD high/low/mid levels   | P/Dレンジの高値・安値・中間点をラインで表示
Dashboard position                  | ダッシュボードの表示位置（4隅から選択）
POI label offset bars                 | POIラベルの右オフセット（バー数）

プリセット別デフォルト値一覧
パラメーター                    | Swing   | Daytrade  | Scalp
-------------------------|--------|-----------|------
アンカーTF                       | 日足.     | 4時間       | 1時間
プライマリTF                   | 4時間.   | 1時間       | 15分
ローカルTF                       | 1時間    | 15分        | 5分
構造ピボット長                | 9           | 7               | 5
ゾーン最大バー数             | 180      | 120           | 80
最小FVGサイズ / ATR       | 0.08.    | 0.10.        | 0.12
OBピボット長                   | 4           | 3               | 2
WATCH距離 / ATR             | 0.75.   | 0.50          | 0.35
最大POI距離 / ATR            | 5.00    | 3.00          | 2.00
PDルックバック（バー） | 60       | 50             | 40

　各オーバーライドフィールドのデフォルトは-で、プリセット値がそのまま適用されます。プリセットを変えずに個別パラメーターだけ調整したい場合は、対応するフィールドに数値を入力してください。

注意事項

　本インジケーターは意思決定支援ツールです。将来の価格動向を保証するものではありません。すべてのシグナルはローカル足でのプライスアクション確認後に判断してください。
　FVGとOBの検出は、各時間軸ごとに「最も新しい有効ゾーン1件」を追跡します。強いトレンド相場では、ゾーンが短時間で無効化・再設定されることがあります。
　P/Dレンジは固定のルックバック期間で計算されるため、強いトレンド相場では中間点が必ずしも有効な均衡水準を示さない場合があります。

## Source Code

````pine
//@version=6
indicator("SMC/ICT Multi-TF Bias and POI Screener with Priority Dashboard v3", overlay=true, max_boxes_count=20, max_labels_count=20, dynamic_requests=true)

// Credits:
// Order Block / Premium-Discount concepts referenced from:
//   Smart Money Concepts (SMC) [LuxAlgo] by LuxAlgo
//   https://www.tradingview.com/script/CnB3fSph-Smart-Money-Concepts-SMC-LuxAlgo/
//
// Market Structure (HH/HL/LH/LL, BOS, CHoCH) concepts referenced from:
//   Market Structures + ZigZag [TradingFinder] by TFlab
//   https://www.tradingview.com/script/v2IhxlWK-Market-Structures-ZigZag-TradingFinder-CHoCH-BOS-MSS-MSB/
//
// Fair Value Gap detection logic referenced from:
//   Fair Value Gap [LuxAlgo] by LuxAlgo
//   https://www.tradingview.com/script/jWY4Uiez-Fair-Value-Gap-LuxAlgo/

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
groupBias = "Bias"
biasPreset = input.string("Swing", "Bias preset", options=["Swing", "Daytrade", "Scalp", "Custom"], group=groupBias)
customAnchorTf = input.timeframe("D", "Custom only: anchor TF", group=groupBias)
customPrimaryTf = input.timeframe("240", "Custom only: primary TF", group=groupBias)
customLocalTf = input.timeframe("60", "Custom only: local TF", group=groupBias)
biasMode = input.string("Primary + Anchor Filter", "Bias mode", options=["Anchor + Primary Aligned", "Primary + Anchor Filter", "Primary Only", "Anchor Only"], group=groupBias)
biasLogic = input.string("EMA primary + HH/HL filter", "Bias logic", options=["EMA only", "HH/HL only", "EMA + HH/HL agreement", "EMA primary + HH/HL filter"], group=groupBias)
anchorFastLen = input.int(20, "Anchor fast EMA", minval=1, group=groupBias)
anchorSlowLen = input.int(50, "Anchor slow EMA", minval=1, group=groupBias)
primaryFastLen = input.int(20, "Primary/Local fast EMA", minval=1, group=groupBias)
primarySlowLen = input.int(50, "Primary/Local slow EMA", minval=1, group=groupBias)
useSlopeNeutral = input.bool(false, "Use slow EMA slope for Neutral filter", group=groupBias)
slopeLookback = input.int(5, "Slope lookback bars", minval=1, group=groupBias)
minSlopeAtr = input.float(0.05, "Min slow EMA slope / ATR", minval=0.0, step=0.01, group=groupBias)
structurePivotOverride = input.string("-", "HH/HL pivot override (- = preset)", group=groupBias)

groupZones = "Zones"
scanFvg = input.bool(true, "Track FVG", group=groupZones)
scanOb = input.bool(true, "Track OB", group=groupZones)
contextMode = input.string("Balanced", "Context mode", options=["Fast", "Balanced"], group=groupZones)
syncContextTfWithPreset = input.bool(true, "Sync OB/PD timeframes with Bias preset", group=groupZones)
obTf = input.timeframe("240", "Custom OB timeframe", group=groupZones)
maxZoneAgeOverride = input.string("-", "Max zone age override (- = preset)", group=groupZones)
anchorFvgMaxAgeOverride = input.string("-", "Anchor FVG age override (- = preset)", group=groupZones)
primaryFvgMaxAgeOverride = input.string("-", "Primary FVG age override (- = preset)", group=groupZones)
localFvgMaxAgeOverride = input.string("-", "Local FVG age override (- = preset)", group=groupZones)
minFvgAtrOverride = input.string("-", "Min FVG size / ATR override (- = preset)", group=groupZones)
fvgCloseConfirmation = input.bool(true, "Require FVG close confirmation", group=groupZones)
fvgAutoThreshold = input.bool(true, "Use FVG auto threshold", group=groupZones)
fvgInvalidationSource = input.string("Close", "FVG invalidation source", options=["Close", "Wick"], group=groupZones)
obPivotLenOverride = input.string("-", "OB pivot override (- = preset)", group=groupZones)
watchDistanceAtrOverride = input.string("-", "WATCH distance / ATR override (- = preset)", group=groupZones)
maxActivePoiDistanceAtrOverride = input.string("-", "Max active POI distance / ATR override (- = preset)", group=groupZones)

groupPd = "Premium / Discount"
pdTf = input.timeframe("240", "Custom PD range timeframe", group=groupPd)
pdLookbackOverride = input.string("-", "PD lookback override (- = preset)", group=groupPd)
htfPdTf = input.timeframe("D", "Custom HTF PD timeframe", group=groupPd)
htfPdLookbackOverride = input.string("-", "HTF PD lookback override (- = preset)", group=groupPd)
ltfPdTf = input.timeframe("60", "Custom LTF PD timeframe", group=groupPd)
ltfPdLookbackOverride = input.string("-", "LTF PD lookback override (- = preset)", group=groupPd)

groupAlerts = "Alerts"
sendPriorityAlerts = input.bool(true, "Send priority alerts", group=groupAlerts)
alertPriority = input.string("S or A", "Alert priority", options=["S only", "S or A", "S A B"], group=groupAlerts)
oncePerZone = input.bool(true, "Alert once per zone", group=groupAlerts)

groupVisual = "Visuals"
showZones = input.bool(true, "Show active zone", group=groupVisual)
showScenarioZones = input.bool(false, "Show long/short scenario zones", group=groupVisual)
showContextZones = input.bool(false, "Show context zones", group=groupVisual)
showKeyLevels = input.bool(true, "Show PD high/low/mid levels", group=groupVisual)
showDashboard = input.bool(true, "Show dashboard", group=groupVisual)
dashboardPosition = input.string("Top Right", "Dashboard position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupVisual)
dashboardTextSizeInput = input.string("Small", "Dashboard text size", options=["Tiny", "Small", "Normal", "Large"], group=groupVisual)
dashboardBgColor = input.color(color.new(color.black, 15), "Dashboard background", group=groupVisual)
dashboardFrameColor = input.color(color.new(color.white, 70), "Dashboard frame", group=groupVisual)
dashboardFrameWidth = input.int(1, "Dashboard frame width", minval=0, maxval=5, group=groupVisual)
dashboardTextColor = input.color(color.white, "Dashboard text", group=groupVisual)
dashboardMutedTextColor = input.color(color.gray, "Dashboard muted text", group=groupVisual)
dashboardWarningColor = input.color(color.orange, "Dashboard warning text", group=groupVisual)
dashboardHeaderBgColor = input.color(color.new(color.gray, 65), "Dashboard header background", group=groupVisual)
dashboardLabelBgColor = input.color(color.new(color.black, 35), "Dashboard label background", group=groupVisual)
showPoiLabel = input.bool(true, "Show POI text label", group=groupVisual)
poiLabelColor = input.color(color.white, "POI label text color", group=groupVisual)
poiLabelSizeInput = input.string("Small", "POI label text size", options=["Tiny", "Small", "Normal", "Large"], group=groupVisual)
poiLabelOffsetBars = input.int(2, "POI label offset bars", minval=0, maxval=100, group=groupVisual)
activeZoneFillColor = input.color(color.new(color.orange, 84), "Active POI fill", group=groupVisual)
activeZoneBorderColor = input.color(color.new(color.orange, 0), "Active POI border", group=groupVisual)
longScenarioFillColor = input.color(color.new(color.teal, 90), "Long scenario fill", group=groupVisual)
longScenarioBorderColor = input.color(color.new(color.teal, 35), "Long scenario border", group=groupVisual)
shortScenarioFillColor = input.color(color.new(color.red, 90), "Short scenario fill", group=groupVisual)
shortScenarioBorderColor = input.color(color.new(color.red, 35), "Short scenario border", group=groupVisual)
fvgFillColor = input.color(color.new(color.aqua, 88), "FVG fill", group=groupVisual)
fvgBorderColor = input.color(color.new(color.aqua, 25), "FVG border", group=groupVisual)
obFillColor = input.color(color.new(color.purple, 88), "OB fill", group=groupVisual)
obBorderColor = input.color(color.new(color.purple, 25), "OB border", group=groupVisual)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_bias(int fastLen, int slowLen, bool useSlope, int slopeBars, float minSlopeRatio) =>
    fast = ta.ema(close, fastLen)
    slow = ta.ema(close, slowLen)
    atr = ta.atr(14)
    slope = slow - slow[slopeBars]
    slopeOkLong = not useSlope or slope > atr * minSlopeRatio
    slopeOkShort = not useSlope or slope < -atr * minSlopeRatio
    fast > slow and slopeOkLong ? 1 : fast < slow and slopeOkShort ? -1 : 0

f_structure_state(int pivotLen) =>
    pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
    pivotLow = ta.pivotlow(low, pivotLen, pivotLen)
    var float lastHigh = na
    var float prevHigh = na
    var float lastLow = na
    var float prevLow = na
    if not na(pivotHigh)
        prevHigh := lastHigh
        lastHigh := pivotHigh
    if not na(pivotLow)
        prevLow := lastLow
        lastLow := pivotLow
    hasLastSwing = not na(lastHigh) and not na(lastLow)
    hasStructure = not na(lastHigh) and not na(prevHigh) and not na(lastLow) and not na(prevLow)
    higherHigh = hasStructure and lastHigh > prevHigh
    higherLow = hasStructure and lastLow > prevLow
    lowerHigh = hasStructure and lastHigh < prevHigh
    lowerLow = hasStructure and lastLow < prevLow
    establishedBull = higherHigh and higherLow
    establishedBear = lowerHigh and lowerLow
    breakUp = hasLastSwing and close > lastHigh
    breakDown = hasLastSwing and close < lastLow
    not hasLastSwing ? 9 : establishedBull and not breakDown ? 1 : establishedBear and not breakUp ? -1 : breakUp ? 2 : breakDown ? -2 : hasStructure ? 3 : 9

f_structure_dir(int state) =>
    state == 1 or state == 2 ? 1 : state == -1 or state == -2 ? -1 : 0

f_combine_bias(int emaBias, int structureBias, string logic) =>
    structureDir = f_structure_dir(structureBias)
    logic == "EMA only" ? emaBias : logic == "HH/HL only" ? structureDir : logic == "EMA + HH/HL agreement" ? (emaBias != 0 and emaBias == structureDir ? emaBias : 0) : structureDir != 0 and emaBias != structureDir ? 0 : emaBias

f_fvg_state(float minAtrRatio, bool closeConfirmation, bool autoThreshold, string invalidationSource, int maxAgeBars) =>
    atr = ta.atr(14)
    bull = low > high[2]
    bear = high < low[2]
    bullTopNow = low
    bullBotNow = high[2]
    bearTopNow = low[2]
    bearBotNow = high
    barDeltaPercent = (close[1] - open[1]) / open[1] * 100.0
    threshold = autoThreshold ? ta.sma(math.abs((close - open) / open * 100.0), 100) * 2.0 : 0.0
    bullCloseOk = not closeConfirmation or close[1] > high[2]
    bearCloseOk = not closeConfirmation or close[1] < low[2]
    bullThresholdOk = not autoThreshold or barDeltaPercent > threshold
    bearThresholdOk = not autoThreshold or -barDeltaPercent > threshold
    bullOk = bull and bullCloseOk and bullThresholdOk and (bullTopNow - bullBotNow) >= atr * minAtrRatio
    bearOk = bear and bearCloseOk and bearThresholdOk and (bearTopNow - bearBotNow) >= atr * minAtrRatio

    var float bullTop = na
    var float bullBot = na
    var int bullBorn = na
    var int bullBornIndex = na
    var float bearTop = na
    var float bearBot = na
    var int bearBorn = na
    var int bearBornIndex = na

    if bullOk
        bullTop := bullTopNow
        bullBot := bullBotNow
        bullBorn := time[2]
        bullBornIndex := bar_index - 2
    if bearOk
        bearTop := bearTopNow
        bearBot := bearBotNow
        bearBorn := time[2]
        bearBornIndex := bar_index - 2

    bullHi = math.max(bullTop, bullBot)
    bullLo = math.min(bullTop, bullBot)
    bearHi = math.max(bearTop, bearBot)
    bearLo = math.min(bearTop, bearBot)
    bullAge = not na(bullBornIndex) ? bar_index - bullBornIndex : 999999
    bearAge = not na(bearBornIndex) ? bar_index - bearBornIndex : 999999
    bullInvalid = not na(bullTop) and bar_index > bullBornIndex and (invalidationSource == "Close" ? close < bullLo : low < bullLo)
    bearInvalid = not na(bearTop) and bar_index > bearBornIndex and (invalidationSource == "Close" ? close > bearHi : high > bearHi)

    if bullInvalid or bullAge > maxAgeBars
        bullTop := na
        bullBot := na
        bullBorn := na
        bullBornIndex := na
        bullAge := 999999
    if bearInvalid or bearAge > maxAgeBars
        bearTop := na
        bearBot := na
        bearBorn := na
        bearBornIndex := na
        bearAge := 999999

    [not na(bullTop) ? 1 : 0, bullTop, bullBot, bullBorn, bullAge, not na(bearTop) ? -1 : 0, bearTop, bearBot, bearBorn, bearAge]

f_ob_state(int pivotLen, int maxAgeBars) =>
    atr = ta.atr(14)
    volatilityMeasure = ta.atr(200)
    highVolatilityBar = (high - low) >= 2.0 * volatilityMeasure
    parsedHigh = highVolatilityBar ? low : high
    parsedLow = highVolatilityBar ? high : low
    lookback = pivotLen * 2 + 1
    rangeHigh = ta.highest(high, lookback)[1]
    rangeLow = ta.lowest(low, lookback)[1]
    brokeUp = close > rangeHigh
    brokeDown = close < rangeLow
    bullTopNow = ta.valuewhen(close < open, parsedHigh, 0)
    bullBotNow = ta.valuewhen(close < open, parsedLow, 0)
    bullBornNow = ta.valuewhen(close < open, time, 0)
    bullBornIndexNow = ta.valuewhen(close < open, bar_index, 0)
    bearTopNow = ta.valuewhen(close > open, parsedHigh, 0)
    bearBotNow = ta.valuewhen(close > open, parsedLow, 0)
    bearBornNow = ta.valuewhen(close > open, time, 0)
    bearBornIndexNow = ta.valuewhen(close > open, bar_index, 0)
    newDir = brokeUp ? 1 : brokeDown ? -1 : 0
    newTop = brokeUp ? bullTopNow : brokeDown ? bearTopNow : na
    newBot = brokeUp ? bullBotNow : brokeDown ? bearBotNow : na
    newBorn = brokeUp ? bullBornNow : brokeDown ? bearBornNow : na
    newBornIndex = brokeUp ? bullBornIndexNow : brokeDown ? bearBornIndexNow : na
    sizeOk = not na(newTop) and not na(newBot) and math.abs(newTop - newBot) > atr * 0.05

    var int dir = 0
    var float top = na
    var float bot = na
    var int born = na
    var int bornIndex = na
    if sizeOk and newDir != 0
        dir := newDir
        top := newTop
        bot := newBot
        born := newBorn
        bornIndex := newBornIndex

    age = not na(bornIndex) ? bar_index - bornIndex : 999999
    hi = math.max(top, bot)
    lo = math.min(top, bot)
    invalid = dir == 1 ? close < lo : dir == -1 ? close > hi : false
    if invalid or age > maxAgeBars
        dir := 0
        top := na
        bot := na
        born := na
        bornIndex := na
        age := 999999
    [dir, top, bot, born, age]

f_inside(float top, float bot) =>
    hi = math.max(top, bot)
    lo = math.min(top, bot)
    close <= hi and close >= lo

f_distance(float top, float bot) =>
    hi = math.max(top, bot)
    lo = math.min(top, bot)
    close > hi ? close - hi : close < lo ? lo - close : 0.0

f_fmt(float value) =>
    str.tostring(value, format.mintick)

f_table_position(string value) =>
    value == "Top Left" ? position.top_left : value == "Bottom Right" ? position.bottom_right : value == "Bottom Left" ? position.bottom_left : position.top_right

f_label_size(string value) =>
    value == "Tiny" ? size.tiny : value == "Normal" ? size.normal : value == "Large" ? size.large : size.small

f_table_text_size(string value) =>
    value == "Tiny" ? size.tiny : value == "Normal" ? size.normal : value == "Large" ? size.large : size.small

f_tf_name(string value) =>
    value == "5" ? "5M" : value == "15" ? "15M" : value == "60" ? "1H" : value == "240" ? "4H" : value == "D" ? "D" : value == "W" ? "W" : value

f_dir_text(int value) =>
    value == 1 ? "買い" : value == -1 ? "売り" : "中立"

f_trend_text(int value) =>
    value == 1 ? "Bull" : value == -1 ? "Bear" : "Neutral"

f_structure_text(int value) =>
    value == 1 ? "上昇" : value == -1 ? "下降" : value == 2 ? "上昇転換" : value == -2 ? "下降転換" : value == 3 ? "調整中" : "未確定"

f_poi_dir_text(int value) =>
    value == 1 ? "Bullish" : value == -1 ? "Bearish" : "Neutral"

f_line_style() =>
    line.style_solid

f_overlap(float topA, float botA, float topB, float botB) =>
    hiA = math.max(topA, botA)
    loA = math.min(topA, botA)
    hiB = math.max(topB, botB)
    loB = math.min(topB, botB)
    math.max(loA, loB) <= math.min(hiA, hiB)

f_warning_join(string current, string item) =>
    item == "" ? current : current == "" ? item : current + "," + item

f_zone_range_text(bool valid, float top, float bot) =>
    valid ? f_fmt(math.min(top, bot)) + " - " + f_fmt(math.max(top, bot)) : "-"

f_zone_location_text(bool valid, float top, float bot, float distance, float atr, float watchAtr) =>
    valid ? (f_inside(top, bot) ? "POI内" : distance <= atr * watchAtr ? "POI接近" : "POI待ち") : "-"

f_override_float(string value, float preset) =>
    parsed = str.tonumber(value)
    value == "-" or na(parsed) ? preset : parsed

f_override_int(string value, int preset) =>
    parsed = str.tonumber(value)
    value == "-" or na(parsed) ? preset : int(math.round(parsed))

//------------------------------------------------------------------------------
// Bias timeframe preset
//------------------------------------------------------------------------------
anchorTf = biasPreset == "Swing" ? "D" : biasPreset == "Daytrade" ? "240" : biasPreset == "Scalp" ? "60" : customAnchorTf
primaryTf = biasPreset == "Swing" ? "240" : biasPreset == "Daytrade" ? "60" : biasPreset == "Scalp" ? "15" : customPrimaryTf
localTf = biasPreset == "Swing" ? "60" : biasPreset == "Daytrade" ? "15" : biasPreset == "Scalp" ? "5" : customLocalTf
anchorTfText = f_tf_name(anchorTf)
primaryTfText = f_tf_name(primaryTf)
localTfText = f_tf_name(localTf)

contextObTf = syncContextTfWithPreset ? primaryTf : obTf
contextPdTf = syncContextTfWithPreset ? primaryTf : pdTf
contextHtfPdTf = syncContextTfWithPreset ? anchorTf : htfPdTf
contextLtfPdTf = syncContextTfWithPreset ? localTf : ltfPdTf
contextObTfText = f_tf_name(contextObTf)
contextPdTfText = f_tf_name(contextPdTf)
contextHtfPdTfText = f_tf_name(contextHtfPdTf)
contextLtfPdTfText = f_tf_name(contextLtfPdTf)

presetStructurePivotLen = biasPreset == "Swing" ? 9 : biasPreset == "Scalp" ? 5 : 7
presetMaxZoneAge = biasPreset == "Swing" ? 180 : biasPreset == "Scalp" ? 80 : 120
presetAnchorFvgMaxAge = biasPreset == "Swing" ? 180 : biasPreset == "Scalp" ? 80 : 120
presetPrimaryFvgMaxAge = biasPreset == "Swing" ? 220 : biasPreset == "Scalp" ? 120 : 180
presetLocalFvgMaxAge = biasPreset == "Swing" ? 200 : biasPreset == "Scalp" ? 100 : 160
presetMinFvgAtr = biasPreset == "Swing" ? 0.08 : biasPreset == "Scalp" ? 0.12 : 0.10
presetObPivotLen = biasPreset == "Swing" ? 4 : biasPreset == "Scalp" ? 2 : 3
presetWatchDistanceAtr = biasPreset == "Swing" ? 0.75 : biasPreset == "Scalp" ? 0.35 : 0.50
presetMaxActivePoiDistanceAtr = biasPreset == "Swing" ? 5.00 : biasPreset == "Scalp" ? 2.00 : 3.00
presetPdLookback = biasPreset == "Swing" ? 60 : biasPreset == "Scalp" ? 40 : 50
presetHtfPdLookback = biasPreset == "Swing" ? 60 : biasPreset == "Scalp" ? 40 : 50
presetLtfPdLookback = biasPreset == "Swing" ? 50 : biasPreset == "Scalp" ? 30 : 50

structurePivotLen = f_override_int(structurePivotOverride, presetStructurePivotLen)
maxZoneAge = f_override_int(maxZoneAgeOverride, presetMaxZoneAge)
anchorFvgMaxAge = f_override_int(anchorFvgMaxAgeOverride, presetAnchorFvgMaxAge)
primaryFvgMaxAge = f_override_int(primaryFvgMaxAgeOverride, presetPrimaryFvgMaxAge)
localFvgMaxAge = f_override_int(localFvgMaxAgeOverride, presetLocalFvgMaxAge)
minFvgAtr = f_override_float(minFvgAtrOverride, presetMinFvgAtr)
obPivotLen = f_override_int(obPivotLenOverride, presetObPivotLen)
watchDistanceAtr = f_override_float(watchDistanceAtrOverride, presetWatchDistanceAtr)
maxActivePoiDistanceAtr = f_override_float(maxActivePoiDistanceAtrOverride, presetMaxActivePoiDistanceAtr)
pdLookback = f_override_int(pdLookbackOverride, presetPdLookback)
htfPdLookback = f_override_int(htfPdLookbackOverride, presetHtfPdLookback)
ltfPdLookback = f_override_int(ltfPdLookbackOverride, presetLtfPdLookback)

//------------------------------------------------------------------------------
// HTF bias
//------------------------------------------------------------------------------
[anchorEmaBias, anchorStructureBias] = request.security(syminfo.tickerid, anchorTf, [f_bias(anchorFastLen, anchorSlowLen, useSlopeNeutral, slopeLookback, minSlopeAtr), f_structure_state(structurePivotLen)], barmerge.gaps_off, barmerge.lookahead_off)
[primaryEmaBias, primaryStructureBias] = request.security(syminfo.tickerid, primaryTf, [f_bias(primaryFastLen, primarySlowLen, useSlopeNeutral, slopeLookback, minSlopeAtr), f_structure_state(structurePivotLen)], barmerge.gaps_off, barmerge.lookahead_off)
[localEmaBias, localStructureBias] = request.security(syminfo.tickerid, localTf, [f_bias(primaryFastLen, primarySlowLen, useSlopeNeutral, slopeLookback, minSlopeAtr), f_structure_state(structurePivotLen)], barmerge.gaps_off, barmerge.lookahead_off)
anchorBias = f_combine_bias(anchorEmaBias, anchorStructureBias, biasLogic)
primaryBias = f_combine_bias(primaryEmaBias, primaryStructureBias, biasLogic)
localBias = f_combine_bias(localEmaBias, localStructureBias, biasLogic)

alignedLong = anchorBias == 1 and primaryBias == 1
alignedShort = anchorBias == -1 and primaryBias == -1
anchorPrimaryConflict = anchorBias != 0 and primaryBias != 0 and anchorBias != primaryBias
biasDir = biasMode == "Anchor + Primary Aligned" ? (alignedLong ? 1 : alignedShort ? -1 : 0) : biasMode == "Anchor Only" ? anchorBias : primaryBias
biasConflict = biasMode == "Anchor + Primary Aligned" and anchorPrimaryConflict
counterAnchor = biasMode == "Primary + Anchor Filter" and anchorPrimaryConflict

//------------------------------------------------------------------------------
// State-based POI tracking
//------------------------------------------------------------------------------
[anchorBullFvgDir, anchorBullFvgTop, anchorBullFvgBot, anchorBullFvgBorn, anchorBullFvgAge, anchorBearFvgDir, anchorBearFvgTop, anchorBearFvgBot, anchorBearFvgBorn, anchorBearFvgAge] = request.security(syminfo.tickerid, anchorTf, f_fvg_state(minFvgAtr, fvgCloseConfirmation, fvgAutoThreshold, fvgInvalidationSource, anchorFvgMaxAge), barmerge.gaps_off, barmerge.lookahead_off)
[primaryBullFvgDir, primaryBullFvgTop, primaryBullFvgBot, primaryBullFvgBorn, primaryBullFvgAge, primaryBearFvgDir, primaryBearFvgTop, primaryBearFvgBot, primaryBearFvgBorn, primaryBearFvgAge] = request.security(syminfo.tickerid, primaryTf, f_fvg_state(minFvgAtr, fvgCloseConfirmation, fvgAutoThreshold, fvgInvalidationSource, primaryFvgMaxAge), barmerge.gaps_off, barmerge.lookahead_off)
[localBullFvgDir, localBullFvgTop, localBullFvgBot, localBullFvgBorn, localBullFvgAge, localBearFvgDir, localBearFvgTop, localBearFvgBot, localBearFvgBorn, localBearFvgAge] = request.security(syminfo.tickerid, localTf, f_fvg_state(minFvgAtr, fvgCloseConfirmation, fvgAutoThreshold, fvgInvalidationSource, localFvgMaxAge), barmerge.gaps_off, barmerge.lookahead_off)
[obDirRaw, obTopRaw, obBotRaw, obBornRaw, obAgeRaw] = request.security(syminfo.tickerid, contextObTf, f_ob_state(obPivotLen, maxZoneAge), barmerge.gaps_off, barmerge.lookahead_off)

atrCurrent = ta.atr(14)

anchorBullFvgValid = contextMode == "Balanced" and scanFvg and anchorBullFvgDir == 1 and not na(anchorBullFvgTop) and not na(anchorBullFvgBot)
anchorBearFvgValid = contextMode == "Balanced" and scanFvg and anchorBearFvgDir == -1 and not na(anchorBearFvgTop) and not na(anchorBearFvgBot)
primaryBullFvgValid = scanFvg and primaryBullFvgDir == 1 and not na(primaryBullFvgTop) and not na(primaryBullFvgBot)
primaryBearFvgValid = scanFvg and primaryBearFvgDir == -1 and not na(primaryBearFvgTop) and not na(primaryBearFvgBot)
localBullFvgValid = scanFvg and localBullFvgDir == 1 and not na(localBullFvgTop) and not na(localBullFvgBot)
localBearFvgValid = scanFvg and localBearFvgDir == -1 and not na(localBearFvgTop) and not na(localBearFvgBot)
obLongValid = scanOb and obDirRaw == 1 and obAgeRaw <= maxZoneAge and not na(obTopRaw) and not na(obBotRaw)
obShortValid = scanOb and obDirRaw == -1 and obAgeRaw <= maxZoneAge and not na(obTopRaw) and not na(obBotRaw)
obValid = obLongValid or obShortValid

anchorBullDistance = anchorBullFvgValid ? f_distance(anchorBullFvgTop, anchorBullFvgBot) : na
anchorBearDistance = anchorBearFvgValid ? f_distance(anchorBearFvgTop, anchorBearFvgBot) : na
primaryBullDistance = primaryBullFvgValid ? f_distance(primaryBullFvgTop, primaryBullFvgBot) : na
primaryBearDistance = primaryBearFvgValid ? f_distance(primaryBearFvgTop, primaryBearFvgBot) : na
localBullDistance = localBullFvgValid ? f_distance(localBullFvgTop, localBullFvgBot) : na
localBearDistance = localBearFvgValid ? f_distance(localBearFvgTop, localBearFvgBot) : na
obDistance = obLongValid or obShortValid ? f_distance(obTopRaw, obBotRaw) : na

useAnchorLongHtfPoi = anchorBullFvgValid and (not primaryBullFvgValid or anchorBullDistance <= primaryBullDistance)
usePrimaryLongHtfPoi = primaryBullFvgValid and not useAnchorLongHtfPoi
longHtfValid = useAnchorLongHtfPoi or usePrimaryLongHtfPoi
longHtfTop = useAnchorLongHtfPoi ? anchorBullFvgTop : usePrimaryLongHtfPoi ? primaryBullFvgTop : na
longHtfBot = useAnchorLongHtfPoi ? anchorBullFvgBot : usePrimaryLongHtfPoi ? primaryBullFvgBot : na
longHtfDir = longHtfValid ? 1 : 0
longHtfBorn = useAnchorLongHtfPoi ? anchorBullFvgBorn : usePrimaryLongHtfPoi ? primaryBullFvgBorn : na
longHtfAge = useAnchorLongHtfPoi ? anchorBullFvgAge : usePrimaryLongHtfPoi ? primaryBullFvgAge : na
longHtfTf = useAnchorLongHtfPoi ? anchorTf : usePrimaryLongHtfPoi ? primaryTf : ""
longHtfDistance = longHtfValid ? f_distance(longHtfTop, longHtfBot) : na

useAnchorShortHtfPoi = anchorBearFvgValid and (not primaryBearFvgValid or anchorBearDistance <= primaryBearDistance)
usePrimaryShortHtfPoi = primaryBearFvgValid and not useAnchorShortHtfPoi
shortHtfValid = useAnchorShortHtfPoi or usePrimaryShortHtfPoi
shortHtfTop = useAnchorShortHtfPoi ? anchorBearFvgTop : usePrimaryShortHtfPoi ? primaryBearFvgTop : na
shortHtfBot = useAnchorShortHtfPoi ? anchorBearFvgBot : usePrimaryShortHtfPoi ? primaryBearFvgBot : na
shortHtfDir = shortHtfValid ? -1 : 0
shortHtfBorn = useAnchorShortHtfPoi ? anchorBearFvgBorn : usePrimaryShortHtfPoi ? primaryBearFvgBorn : na
shortHtfAge = useAnchorShortHtfPoi ? anchorBearFvgAge : usePrimaryShortHtfPoi ? primaryBearFvgAge : na
shortHtfTf = useAnchorShortHtfPoi ? anchorTf : usePrimaryShortHtfPoi ? primaryTf : ""
shortHtfDistance = shortHtfValid ? f_distance(shortHtfTop, shortHtfBot) : na

longHtfScore = longHtfValid ? longHtfDistance : 999999.0
longLocalScore = localBullFvgValid ? localBullDistance : 999999.0
longObScore = obLongValid ? obDistance : 999999.0
useLongHtfActive = longHtfValid and longHtfScore <= longLocalScore and longHtfScore <= longObScore
useLongLocalActive = localBullFvgValid and not useLongHtfActive and longLocalScore <= longObScore
useLongObActive = obLongValid and not useLongHtfActive and not useLongLocalActive
hasLongSetup = useLongHtfActive or useLongLocalActive or useLongObActive
longTop = useLongHtfActive ? longHtfTop : useLongLocalActive ? localBullFvgTop : useLongObActive ? obTopRaw : na
longBot = useLongHtfActive ? longHtfBot : useLongLocalActive ? localBullFvgBot : useLongObActive ? obBotRaw : na
longBorn = useLongHtfActive ? longHtfBorn : useLongLocalActive ? localBullFvgBorn : useLongObActive ? obBornRaw : na
longAge = useLongHtfActive ? longHtfAge : useLongLocalActive ? localBullFvgAge : useLongObActive ? obAgeRaw : na
longTf = useLongHtfActive ? longHtfTf : useLongLocalActive ? localTf : useLongObActive ? contextObTf : ""
longType = useLongObActive ? "OB" : hasLongSetup ? "FVG" : "NONE"
longDistance = hasLongSetup ? f_distance(longTop, longBot) : na
longInside = hasLongSetup and f_inside(longTop, longBot)
longNear = hasLongSetup and not longInside and longDistance <= atrCurrent * watchDistanceAtr
longDistanceAtrText = hasLongSetup and atrCurrent > 0 ? str.tostring(longDistance / atrCurrent, "#.##") + " ATR" : "-"

shortHtfScore = shortHtfValid ? shortHtfDistance : 999999.0
shortLocalScore = localBearFvgValid ? localBearDistance : 999999.0
shortObScore = obShortValid ? obDistance : 999999.0
useShortHtfActive = shortHtfValid and shortHtfScore <= shortLocalScore and shortHtfScore <= shortObScore
useShortLocalActive = localBearFvgValid and not useShortHtfActive and shortLocalScore <= shortObScore
useShortObActive = obShortValid and not useShortHtfActive and not useShortLocalActive
hasShortSetup = useShortHtfActive or useShortLocalActive or useShortObActive
shortTop = useShortHtfActive ? shortHtfTop : useShortLocalActive ? localBearFvgTop : useShortObActive ? obTopRaw : na
shortBot = useShortHtfActive ? shortHtfBot : useShortLocalActive ? localBearFvgBot : useShortObActive ? obBotRaw : na
shortBorn = useShortHtfActive ? shortHtfBorn : useShortLocalActive ? localBearFvgBorn : useShortObActive ? obBornRaw : na
shortAge = useShortHtfActive ? shortHtfAge : useShortLocalActive ? localBearFvgAge : useShortObActive ? obAgeRaw : na
shortTf = useShortHtfActive ? shortHtfTf : useShortLocalActive ? localTf : useShortObActive ? contextObTf : ""
shortType = useShortObActive ? "OB" : hasShortSetup ? "FVG" : "NONE"
shortDistance = hasShortSetup ? f_distance(shortTop, shortBot) : na
shortInside = hasShortSetup and f_inside(shortTop, shortBot)
shortNear = hasShortSetup and not shortInside and shortDistance <= atrCurrent * watchDistanceAtr
shortDistanceAtrText = hasShortSetup and atrCurrent > 0 ? str.tostring(shortDistance / atrCurrent, "#.##") + " ATR" : "-"

longScore = hasLongSetup ? longDistance : 999999.0
shortScore = hasShortSetup ? shortDistance : 999999.0
useLongAsActive = hasLongSetup and (not hasShortSetup or longScore <= shortScore)
useShortAsActive = hasShortSetup and not useLongAsActive

activeType = useLongAsActive ? longType : useShortAsActive ? shortType : "NONE"
activeTf = useLongAsActive ? longTf : useShortAsActive ? shortTf : ""
activeTop = useLongAsActive ? longTop : useShortAsActive ? shortTop : na
activeBot = useLongAsActive ? longBot : useShortAsActive ? shortBot : na
activeBorn = useLongAsActive ? longBorn : useShortAsActive ? shortBorn : na
activeAge = useLongAsActive ? longAge : useShortAsActive ? shortAge : na
activeDir = useLongAsActive ? 1 : useShortAsActive ? -1 : 0
hasActiveZone = activeDir != 0 and not na(activeTop) and not na(activeBot)

insideZone = hasActiveZone and f_inside(activeTop, activeBot)
distanceToZone = hasActiveZone ? f_distance(activeTop, activeBot) : na
nearZone = hasActiveZone and not insideZone and distanceToZone <= atrCurrent * watchDistanceAtr
activeDistanceFar = hasActiveZone and atrCurrent > 0 and distanceToZone > atrCurrent * maxActivePoiDistanceAtr

hasHtfPoi = biasDir == 1 ? longHtfValid : biasDir == -1 ? shortHtfValid : longHtfValid or shortHtfValid
htfPoiTop = biasDir == 1 ? longHtfTop : biasDir == -1 ? shortHtfTop : longHtfValid ? longHtfTop : shortHtfTop
htfPoiBot = biasDir == 1 ? longHtfBot : biasDir == -1 ? shortHtfBot : longHtfValid ? longHtfBot : shortHtfBot
htfPoiDir = biasDir == 1 ? longHtfDir : biasDir == -1 ? shortHtfDir : longHtfValid ? longHtfDir : shortHtfDir
htfPoiBorn = biasDir == 1 ? longHtfBorn : biasDir == -1 ? shortHtfBorn : longHtfValid ? longHtfBorn : shortHtfBorn
htfPoiAge = biasDir == 1 ? longHtfAge : biasDir == -1 ? shortHtfAge : longHtfValid ? longHtfAge : shortHtfAge
htfPoiTf = biasDir == 1 ? longHtfTf : biasDir == -1 ? shortHtfTf : longHtfValid ? longHtfTf : shortHtfTf
insideHtfPoi = hasHtfPoi and f_inside(htfPoiTop, htfPoiBot)

localFvgValid = biasDir == 1 ? localBullFvgValid : biasDir == -1 ? localBearFvgValid : localBullFvgValid or localBearFvgValid
localFvgTop = biasDir == 1 ? localBullFvgTop : biasDir == -1 ? localBearFvgTop : localBullFvgValid ? localBullFvgTop : localBearFvgTop
localFvgBot = biasDir == 1 ? localBullFvgBot : biasDir == -1 ? localBearFvgBot : localBullFvgValid ? localBullFvgBot : localBearFvgBot
insideLtfPoi = localFvgValid and f_inside(localFvgTop, localFvgBot)
nearLtfPoi = localFvgValid and f_distance(localFvgTop, localFvgBot) <= atrCurrent * watchDistanceAtr
localConflict = biasDir != 0 and localBias != 0 and localBias != biasDir

trendReady = biasDir != 0 and localFvgValid and insideLtfPoi and not localConflict and not biasConflict
retraceWatch = biasDir != 0 and hasHtfPoi and not insideHtfPoi and localConflict and not biasConflict
reversalCandidate = biasDir != 0 and hasHtfPoi and insideHtfPoi and localConflict and not biasConflict
ltfReady = biasDir != 0 and localFvgValid and (insideLtfPoi or nearLtfPoi) and not biasConflict
ready = trendReady or reversalCandidate
watch = retraceWatch or ltfReady or (biasDir != 0 and hasActiveZone and not ready and not biasConflict)
avoid = biasDir == 0 or biasConflict or not hasActiveZone

//------------------------------------------------------------------------------
// Premium / Discount flag
//------------------------------------------------------------------------------
[pdHigh, pdLow] = request.security(syminfo.tickerid, contextPdTf, [ta.highest(high, pdLookback), ta.lowest(low, pdLookback)], barmerge.gaps_off, barmerge.lookahead_off)
pdMid = (pdHigh + pdLow) * 0.5
[htfPdHigh, htfPdLow] = request.security(syminfo.tickerid, contextHtfPdTf, [ta.highest(high, htfPdLookback), ta.lowest(low, htfPdLookback)], barmerge.gaps_off, barmerge.lookahead_off)
htfPdMid = (htfPdHigh + htfPdLow) * 0.5
[ltfPdHigh, ltfPdLow] = request.security(syminfo.tickerid, contextLtfPdTf, [ta.highest(high, ltfPdLookback), ta.lowest(low, ltfPdLookback)], barmerge.gaps_off, barmerge.lookahead_off)
ltfPdMid = (ltfPdHigh + ltfPdLow) * 0.5

isPremium = close > pdMid
isDiscount = close < pdMid
pdWarning = biasDir == 1 and isPremium or biasDir == -1 and isDiscount
pdText = isPremium ? "PREMIUM" : isDiscount ? "DISCOUNT" : "MID"
htfPdText = close > htfPdMid ? "PREMIUM" : close < htfPdMid ? "DISCOUNT" : "MID"
ltfPdText = close > ltfPdMid ? "PREMIUM" : close < ltfPdMid ? "DISCOUNT" : "MID"

//------------------------------------------------------------------------------
// Decision, alert and text
//------------------------------------------------------------------------------
zoneKey = syminfo.tickerid + "|" + activeType + "|" + activeTf + "|" + str.tostring(activeBorn) + "|" + str.tostring(activeDir)
var string lastPriorityKey = ""

directionText = biasDir == 1 ? "LONG" : biasDir == -1 ? "SHORT" : "NEUTRAL"
lateTrendWarning = not ready and ((biasDir == 1 and htfPdText == "PREMIUM") or (biasDir == -1 and htfPdText == "DISCOUNT")) and not insideHtfPoi
activeTfText = f_tf_name(activeTf)

zoneHi = hasActiveZone ? math.max(activeTop, activeBot) : na
zoneLo = hasActiveZone ? math.min(activeTop, activeBot) : na
distanceAtrText = hasActiveZone and atrCurrent > 0 ? str.tostring(distanceToZone / atrCurrent, "#.##") + " ATR" : "-"
priceRangeText = hasActiveZone ? f_fmt(zoneLo) + " - " + f_fmt(zoneHi) : "-"
waitingTowardPoi = hasActiveZone and ((activeDir == 1 and close > zoneHi) or (activeDir == -1 and close < zoneLo))
passedPoi = hasActiveZone and ((activeDir == 1 and close < zoneLo) or (activeDir == -1 and close > zoneHi))
locationText = not hasActiveZone ? "-" : insideZone ? "POI内" : nearZone ? "POI接近" : passedPoi ? "通過注意" : waitingTowardPoi ? "POI待ち" : "POI遠い"
localHtfOverlap = localFvgValid and hasHtfPoi and f_overlap(localFvgTop, localFvgBot, htfPoiTop, htfPoiBot)
poiRankText = not hasActiveZone ? "" : localHtfOverlap and activeTf == localTf and activeType == "FVG" ? "P1 " : activeTf == localTf and activeType == "FVG" ? "P3 " : activeType == "OB" ? "P4 " : (activeTf == anchorTf or activeTf == primaryTf) ? "HTF " : ""
poiDisplayText = hasActiveZone ? poiRankText + activeTfText + " " + f_poi_dir_text(activeDir) + " " + activeType : "NO POI"
pdDisplayText = contextHtfPdTfText + " " + htfPdText + " / " + contextLtfPdTfText + " " + ltfPdText

localStructureDir = f_structure_dir(localStructureBias)
localChochWarning = (biasDir == 1 and localStructureBias == -2) or (biasDir == -1 and localStructureBias == 2)
counterTrade = biasDir != 0 and activeDir != 0 and activeDir != biasDir
htfPoiDistance = hasHtfPoi ? f_distance(htfPoiTop, htfPoiBot) : na
htfDistanceFar = hasHtfPoi and atrCurrent > 0 and htfPoiDistance > atrCurrent * maxActivePoiDistanceAtr

longSetupText = hasLongSetup ? f_tf_name(longTf) + " Bullish " + longType + " / " + f_zone_location_text(hasLongSetup, longTop, longBot, longDistance, atrCurrent, watchDistanceAtr) + " / " + longDistanceAtrText : "No Long POI"
shortSetupText = hasShortSetup ? f_tf_name(shortTf) + " Bearish " + shortType + " / " + f_zone_location_text(hasShortSetup, shortTop, shortBot, shortDistance, atrCurrent, watchDistanceAtr) + " / " + shortDistanceAtrText : "No Short POI"
mainBiasText = (counterTrade ? "Bg " : "") + f_trend_text(biasDir) + " (" + anchorTfText + "/" + primaryTfText + ")"
localStateText = localStructureBias == 2 ? localTfText + " Bullish CHoCH" : localStructureBias == -2 ? localTfText + " Bearish CHoCH" : localStructureDir == 1 ? localTfText + " Bullish" : localStructureDir == -1 ? localTfText + " Bearish" : localTfText + " Neutral"
activePlanText = not hasActiveZone ? "No Active Plan" : activeDir == 1 ? "Long Watch" : "Short Watch"
backgroundPoiText = not hasHtfPoi ? "No HTF POI" : f_tf_name(htfPoiTf) + " " + f_poi_dir_text(htfPoiDir) + " FVG / " + (atrCurrent > 0 ? str.tostring(htfPoiDistance / atrCurrent, "#.##") + " ATR" : "-")

priorityAllowed = hasActiveZone and biasDir != 0 and not biasConflict
priorityCode = not priorityAllowed ? "D" : counterAnchor ? "C" : insideZone ? "S" : nearZone ? "A" : "B"
statusText = insideZone ? "ACTIVE_POI_INSIDE" : nearZone ? "ACTIVE_POI_NEAR" : hasActiveZone ? "ACTIVE_POI_WAIT" : biasConflict ? "BIAS_CONFLICT" : "AVOID"

warningRaw = ""
warningRaw := f_warning_join(warningRaw, localChochWarning ? "LOCAL_CHOCH" : "")
warningRaw := f_warning_join(warningRaw, htfDistanceFar ? "HTF_DISTANCE_FAR" : "")
warningRaw := f_warning_join(warningRaw, counterTrade ? "COUNTER_TRADE" : "")
warningRaw := f_warning_join(warningRaw, pdWarning ? "PD_WARNING" : "")
warningRaw := f_warning_join(warningRaw, lateTrendWarning ? "LATE_TREND" : "")
warningRaw := f_warning_join(warningRaw, counterAnchor ? "COUNTER_ANCHOR" : "")
warningText = warningRaw == "" ? "OK" : warningRaw
warningDisplayRaw = ""
warningDisplayRaw := f_warning_join(warningDisplayRaw, localChochWarning ? localTfText + "転換" : "")
warningDisplayRaw := f_warning_join(warningDisplayRaw, htfDistanceFar ? "HTF遠い" : "")
warningDisplayRaw := f_warning_join(warningDisplayRaw, counterTrade ? "逆方向" : "")
warningDisplayRaw := f_warning_join(warningDisplayRaw, pdWarning ? "PD" : "")
warningDisplayRaw := f_warning_join(warningDisplayRaw, lateTrendWarning ? "Late" : "")
warningDisplayRaw := f_warning_join(warningDisplayRaw, counterAnchor ? "Anchor逆風" : "")
warningDisplayText = warningDisplayRaw == "" ? "OK" : str.replace_all(warningDisplayRaw, ",", " / ")
hasWarning = warningText != "OK"

priorityBaseText = priorityCode == "S" ? "S：即監視" : priorityCode == "A" ? "A：高優先" : priorityCode == "B" ? "B：通常監視" : priorityCode == "C" ? "C：低優先" : "D：見送り"
priorityText = priorityBaseText + (hasWarning and priorityCode != "D" ? " ⚠" : "")
scenarioText = priorityCode == "S" ? activePlanText + " / POI反応待ち" : priorityCode == "A" ? activePlanText + " / POI接近" : priorityCode == "B" ? activePlanText + " / POI待ち" : priorityCode == "C" ? "条件弱い" : "方向不明"
actionBaseText = priorityCode == "S" ? "今すぐ" + localTfText + "確認" : priorityCode == "A" ? localTfText + "確認準備" : priorityCode == "B" ? "近いPOI到達を待つ" : priorityCode == "C" ? "慎重に監視" : "触らない"
actionText = actionBaseText + (hasWarning and priorityCode != "D" ? "・警告確認" : "")

localPullback = biasDir != 0 and localBias != 0 and localBias != biasDir
localAligned = biasDir != 0 and localBias == biasDir
phaseText = biasDir == 0 or biasConflict ? "Unclear" : localPullback and biasDir == 1 ? "押し目ゾーンへ調整中" : localPullback and biasDir == -1 ? "戻り売りゾーンへ調整中" : anchorBias == 0 and primaryBias == biasDir ? "Early Trend" : localAligned and lateTrendWarning ? "Extending / Late" : localAligned ? "Extending" : lateTrendWarning ? "Late Trend" : "Unclear"
structureText = anchorTfText + "=" + f_structure_text(anchorStructureBias) + " / " + primaryTfText + "=" + f_structure_text(primaryStructureBias) + " / " + localTfText + "=" + f_structure_text(localStructureBias)
biasViewText = biasConflict ? anchorTfText + "/" + primaryTfText + "不一致" : counterAnchor ? anchorTfText + "逆風、" + primaryTfText + "主軸は慎重" : biasDir == 0 ? "Bias不明確" : localPullback ? primaryTfText + "主軸" + f_trend_text(biasDir) + "、" + localTfText + "は調整" : localAligned ? anchorTfText + "追い風、" + localTfText + "も同方向" : anchorBias == 0 ? primaryTfText + "主軸" + f_trend_text(biasDir) + "、" + anchorTfText + "中立" : primaryTfText + "主軸" + f_trend_text(biasDir)
tfViewText = anchorTfText + ">" + primaryTfText + ">" + localTfText + " / OB " + contextObTfText + " / PD " + contextPdTfText

message = '{"layer":"L1","version":"two-sided-scenario-v3","preset":"' + biasPreset + '","status":"' + statusText + '","priority":"' + priorityCode + '","priorityText":"' + priorityText + '","activePlan":"' + activePlanText + '","mainBias":"' + mainBiasText + '","localState":"' + localStateText + '","longSetup":"' + longSetupText + '","shortSetup":"' + shortSetupText + '","backgroundPoi":"' + backgroundPoiText + '","symbol":"' + syminfo.ticker + '","direction":"' + directionText + '","trend":"' + f_trend_text(biasDir) + '","phase":"' + phaseText + '","poi":"' + poiDisplayText + '","range":"' + priceRangeText + '","location":"' + locationText + '","distance":"' + distanceAtrText + '","pd":"' + pdDisplayText + '","warning":"' + warningText + '","warningDisplay":"' + warningDisplayText + '","localChochWarning":' + str.tostring(localChochWarning) + ',"htfDistanceFar":' + str.tostring(htfDistanceFar) + ',"counterTrade":' + str.tostring(counterTrade) + ',"pdWarning":' + str.tostring(pdWarning) + ',"lateTrendWarning":' + str.tostring(lateTrendWarning) + ',"zoneAge":' + str.tostring(activeAge) + '}'

priorityAlertOk = alertPriority == "S only" ? priorityCode == "S" : alertPriority == "S or A" ? (priorityCode == "S" or priorityCode == "A") : (priorityCode == "S" or priorityCode == "A" or priorityCode == "B")
priorityAlertKey = zoneKey + "|" + priorityCode
priorityTrigger = sendPriorityAlerts and priorityAlertOk and (not oncePerZone or priorityAlertKey != lastPriorityKey)

if priorityTrigger
    alert(message, alert.freq_once_per_bar_close)
    lastPriorityKey := priorityAlertKey

alertcondition(priorityCode == "S", "L1 Priority S", "SMC/ICT Layer 1 Priority S")
alertcondition(priorityCode == "A", "L1 Priority A", "SMC/ICT Layer 1 Priority A")
alertcondition(priorityCode == "B", "L1 Priority B", "SMC/ICT Layer 1 Priority B")
alertcondition(priorityCode == "S" or priorityCode == "A", "L1 Priority S or A", "SMC/ICT Layer 1 Priority S or A")
alertcondition(priorityCode == "S" or priorityCode == "A" or priorityCode == "B", "L1 Priority S A B", "SMC/ICT Layer 1 Priority S A B")

//------------------------------------------------------------------------------
// Visuals
//------------------------------------------------------------------------------
drawRightTime = not na(time_close) ? time_close : time
activeLeftTime = hasActiveZone and not na(activeBorn) ? activeBorn : time
htfLeftTime = hasHtfPoi and not na(htfPoiBorn) ? htfPoiBorn : time
obLeftTime = obValid and not na(obBornRaw) ? obBornRaw : time

var box activeBox = na
if showZones and hasActiveZone
    if na(activeBox) or zoneKey != zoneKey[1]
        if not na(activeBox)
            box.delete(activeBox)
        activeBox := box.new(left=activeLeftTime, top=zoneHi, right=drawRightTime, bottom=zoneLo, xloc=xloc.bar_time, bgcolor=activeZoneFillColor, border_color=activeZoneBorderColor, border_width=1, border_style=f_line_style())
    else
        box.set_right(activeBox, drawRightTime)
        box.set_top(activeBox, zoneHi)
        box.set_bottom(activeBox, zoneLo)
else if not na(activeBox)
    box.delete(activeBox)
    activeBox := na

var box longScenarioBox = na
if showScenarioZones and hasLongSetup
    longLeftTime = not na(longBorn) ? longBorn : time
    if na(longScenarioBox) or longBorn != longBorn[1]
        if not na(longScenarioBox)
            box.delete(longScenarioBox)
        longScenarioBox := box.new(left=longLeftTime, top=math.max(longTop, longBot), right=drawRightTime, bottom=math.min(longTop, longBot), xloc=xloc.bar_time, bgcolor=longScenarioFillColor, border_color=longScenarioBorderColor, border_width=1, border_style=f_line_style())
    else
        box.set_right(longScenarioBox, drawRightTime)
        box.set_top(longScenarioBox, math.max(longTop, longBot))
        box.set_bottom(longScenarioBox, math.min(longTop, longBot))
else if not na(longScenarioBox)
    box.delete(longScenarioBox)
    longScenarioBox := na

var box shortScenarioBox = na
if showScenarioZones and hasShortSetup
    shortLeftTime = not na(shortBorn) ? shortBorn : time
    if na(shortScenarioBox) or shortBorn != shortBorn[1]
        if not na(shortScenarioBox)
            box.delete(shortScenarioBox)
        shortScenarioBox := box.new(left=shortLeftTime, top=math.max(shortTop, shortBot), right=drawRightTime, bottom=math.min(shortTop, shortBot), xloc=xloc.bar_time, bgcolor=shortScenarioFillColor, border_color=shortScenarioBorderColor, border_width=1, border_style=f_line_style())
    else
        box.set_right(shortScenarioBox, drawRightTime)
        box.set_top(shortScenarioBox, math.max(shortTop, shortBot))
        box.set_bottom(shortScenarioBox, math.min(shortTop, shortBot))
else if not na(shortScenarioBox)
    box.delete(shortScenarioBox)
    shortScenarioBox := na

var box htfBox = na
if showContextZones and hasHtfPoi
    if na(htfBox) or htfPoiBorn != htfPoiBorn[1] or htfPoiDir != htfPoiDir[1]
        if not na(htfBox)
            box.delete(htfBox)
        htfBox := box.new(left=htfLeftTime, top=math.max(htfPoiTop, htfPoiBot), right=drawRightTime, bottom=math.min(htfPoiTop, htfPoiBot), xloc=xloc.bar_time, bgcolor=fvgFillColor, border_color=fvgBorderColor, border_width=1, border_style=f_line_style())
    else
        box.set_right(htfBox, drawRightTime)
        box.set_top(htfBox, math.max(htfPoiTop, htfPoiBot))
        box.set_bottom(htfBox, math.min(htfPoiTop, htfPoiBot))
else if not na(htfBox)
    box.delete(htfBox)
    htfBox := na

var box obBox = na
if showContextZones and obValid
    if na(obBox) or obBornRaw != obBornRaw[1] or obDirRaw != obDirRaw[1]
        if not na(obBox)
            box.delete(obBox)
        obBox := box.new(left=obLeftTime, top=math.max(obTopRaw, obBotRaw), right=drawRightTime, bottom=math.min(obTopRaw, obBotRaw), xloc=xloc.bar_time, bgcolor=obFillColor, border_color=obBorderColor, border_width=1, border_style=f_line_style())
    else
        box.set_right(obBox, drawRightTime)
        box.set_top(obBox, math.max(obTopRaw, obBotRaw))
        box.set_bottom(obBox, math.min(obTopRaw, obBotRaw))
else if not na(obBox)
    box.delete(obBox)
    obBox := na

var label poiLabel = na
if showPoiLabel and hasActiveZone and barstate.islast
    if not na(poiLabel)
        label.delete(poiLabel)
    labelText = "POI " + activeTfText + " " + activeType + " " + f_poi_dir_text(activeDir) + "\n" + priceRangeText
    labelY = math.avg(zoneHi, zoneLo)
    poiLabel := label.new(bar_index + poiLabelOffsetBars, labelY, labelText, color=color.new(color.black, 100), textcolor=poiLabelColor, style=label.style_label_left, size=f_label_size(poiLabelSizeInput))
else if (not showPoiLabel or not hasActiveZone) and not na(poiLabel)
    label.delete(poiLabel)
    poiLabel := na

var table dashboard = na
var string lastDashboardPosition = ""
if showDashboard and barstate.islast
    if na(dashboard) or dashboardPosition != lastDashboardPosition
        if not na(dashboard)
            table.delete(dashboard)
        dashboard := table.new(f_table_position(dashboardPosition), 2, 16, bgcolor=dashboardBgColor, frame_color=dashboardFrameColor, frame_width=dashboardFrameWidth)
        lastDashboardPosition := dashboardPosition
    dashboardTextSize = f_table_text_size(dashboardTextSizeInput)
    priorityColor = priorityCode == "S" ? color.new(color.fuchsia, 0) : priorityCode == "A" ? color.new(color.orange, 0) : priorityCode == "B" ? color.new(color.blue, 0) : priorityCode == "C" ? color.new(color.purple, 10) : color.new(color.gray, 45)
    dirColor = biasDir == 1 ? color.new(color.teal, 0) : biasDir == -1 ? color.new(color.red, 0) : color.new(color.gray, 20)
    mutedHeaderColor = dashboardHeaderBgColor
    labelColor = dashboardLabelBgColor
    activePlanColor = activeDir == 1 ? color.new(color.teal, 72) : activeDir == -1 ? color.new(color.red, 72) : color.new(color.gray, 45)
    mainBiasColor = counterTrade ? labelColor : dirColor
    table.cell(dashboard, 0, 0, "Priority", text_color=dashboardTextColor, bgcolor=priorityColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 0, priorityText, text_color=dashboardTextColor, bgcolor=priorityColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 1, "Active Plan", text_color=dashboardTextColor, bgcolor=activePlanColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 1, activePlanText, text_color=dashboardTextColor, bgcolor=activePlanColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 2, "Action", text_color=dashboardTextColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 2, actionText, text_color=dashboardTextColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 3, "環境", text_color=dashboardTextColor, bgcolor=mutedHeaderColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 3, biasPreset + " / " + contextMode, text_color=dashboardTextColor, bgcolor=mutedHeaderColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 4, "TF", text_color=dashboardTextColor, bgcolor=labelColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 4, tfViewText, text_color=dashboardTextColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 5, "Main Bias", text_color=dashboardTextColor, bgcolor=labelColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 5, mainBiasText, text_color=dashboardTextColor, bgcolor=mainBiasColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 6, "Local State", text_color=dashboardTextColor, bgcolor=labelColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 6, localStateText, text_color=localChochWarning ? dashboardWarningColor : dashboardTextColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 7, "Long Setup", text_color=dashboardTextColor, bgcolor=labelColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 7, longSetupText, text_color=hasLongSetup ? dashboardTextColor : dashboardMutedTextColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 8, "Short Setup", text_color=dashboardTextColor, bgcolor=labelColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 8, shortSetupText, text_color=hasShortSetup ? dashboardTextColor : dashboardMutedTextColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 9, "Background POI", text_color=dashboardTextColor, bgcolor=labelColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 9, backgroundPoiText, text_color=htfDistanceFar ? dashboardWarningColor : dashboardTextColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 10, "Warning", text_color=dashboardTextColor, bgcolor=labelColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 10, warningDisplayText, text_color=hasWarning ? dashboardWarningColor : dashboardTextColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 11, "Active POI", text_color=dashboardTextColor, bgcolor=mutedHeaderColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 11, poiDisplayText, text_color=dashboardTextColor, bgcolor=mutedHeaderColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 12, "価格帯", text_color=dashboardTextColor, bgcolor=labelColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 12, priceRangeText, text_color=dashboardTextColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 13, "現在位置", text_color=dashboardTextColor, bgcolor=labelColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 13, locationText, text_color=dashboardTextColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 14, "PD/距離", text_color=dashboardTextColor, bgcolor=labelColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 14, pdDisplayText + " / " + distanceAtrText, text_color=(pdWarning or activeDistanceFar) ? dashboardWarningColor : dashboardTextColor, text_size=dashboardTextSize)
    table.cell(dashboard, 0, 15, "構造", text_color=dashboardTextColor, bgcolor=labelColor, text_size=dashboardTextSize)
    table.cell(dashboard, 1, 15, structureText, text_color=dashboardTextColor, text_size=dashboardTextSize)
else if not showDashboard and not na(dashboard)
    table.delete(dashboard)
    dashboard := na

plot(showKeyLevels ? pdHigh : na, "PD high", color=color.new(color.gray, 55), linewidth=1, style=plot.style_linebr)
plot(showKeyLevels ? pdLow : na, "PD low", color=color.new(color.gray, 55), linewidth=1, style=plot.style_linebr)
plot(showKeyLevels ? pdMid : na, "PD midpoint", color=color.new(color.yellow, 20), linewidth=1, style=plot.style_linebr)
````
