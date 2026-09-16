<!-- tradingview-pine-id: PUB;6ed41737753f4e43bacf9adb3838b89e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# TradingFlow: Gold Macro Bias (GMB) v2.0.4

Source: https://www.tradingview.com/script/67tZNXUn-TF-Gold-Macro-Bias-GMB/

## Description

TradingFlow: Gold Macro Bias (GMB)

GMB is a macro model that reads the broader environment for gold using volatility, dollar strength, and real yields. It normalizes VIX, GVZ, DXY, and real yield data into a composite score, then uses a MACD-style momentum histogram to show whether the macro backdrop is improving or deteriorating for gold. Its purpose is to give a structured macro context so gold-related decisions can be made with a clearer view of the underlying drivers.

The indicator is not based on gold's price and does not predict price direction. It describes the macro conditions that tend to support or restrict gold, and how quickly those conditions are changing.

Core Concept

GMB combines four macro inputs:
• VIX: broad equity risk aversion. Higher VIX usually reflects stronger demand for protection.
• GVZ: implied volatility in gold. Shows whether gold itself is responding to macro stress.
• DXY: U.S. dollar strength. A stronger dollar is typically a headwind for gold.
• Real Yield: 10-year, 30-year, or a blended rate. Higher real yields increase the opportunity cost of holding gold.

The core comparison is between GVZ and VIX. When broad market stress (VIX) is elevated but gold volatility (GVZ) is relatively calm, the model reads this as a potentially supportive backdrop — equity stress may eventually drive catch-up demand for gold. When gold volatility is elevated relative to VIX, the model reads this as less favorable.

Dual-Speed Architecture: Regime and Tactical

GMB runs two parallel scores:
• Regime: the slow-moving macro trend. This is the primary line for reading the overall backdrop and drives the zone logic and alerts.
• Tactical: a faster-responsive overlay for entry timing. It reacts more quickly to sudden policy shifts or market shocks.

Momentum Histogram (MACD-style)

The histogram shows the difference between Tactical and Regime scores. It works like a MACD histogram:
• Positive bars: Tactical above Regime — macro backdrop is improving.
• Negative bars: Tactical below Regime — macro backdrop is deteriorating.
• Growing bars: momentum is accelerating.
• Shrinking bars: momentum is decelerating — possible inflection point.

The histogram uses four colors to distinguish these states:
• Bright gold — improving, accelerating
• Light gold — improving, decelerating
• Bright red — deteriorating, accelerating
• Light red — deteriorating, decelerating

The background shading follows the same logic, using transparent versions of these colors.

Z-Score Normalization and Capping

All inputs are converted to Z-Scores over their respective normalization windows. This puts VIX, GVZ, DXY, and real yield on a common scale so they can be combined into a single composite.

Z-Scores are capped at plus or minus 3.5. This prevents extreme black-swan outliers from distorting the normalized composite. During events like a VIX spike, uncapped Z-Scores could reach 5 or beyond, which would pull the entire model out of proportion. The cap keeps the composite stable under stress.

Adjustable Component Weights

Each component has an independent weight:
• VIX-GVZ Gap weight
• DXY weight
• Real Yield weight

Weights are kept fixed and manual for transparency. Adaptive auto-weighting can reduce interpretability — it becomes harder to understand why the model changed its behavior. Fixed weights let you see exactly how each factor contributes.

Real Yield Modes

The real yield input can be set to:
• 10Y: only the 10-year real yield (FRED:DFII10).
• 30Y: only the 30-year real yield (FRED:DFII30). More sensitive to fiscal dominance and long-end liquidity events.
• Blended: a weighted combination of both.

The 30Y option captures long-end dynamics that the 10Y alone may miss, particularly during periods of fiscal expansion or Treasury buyback operations.

Contribution Table

An optional table in the top-right corner shows each component's current Z-Score:
• VIX-GVZ Gap
• DXY
• Real Yield

This helps identify which factor is driving the composite at any given moment — whether the score is being pushed by the dollar, real yields, or the volatility gap.

How to Read

1. The Regime Composite Score is the primary read. Sustained positive readings (with invert ON) suggest a supportive macro backdrop for gold.
2. The Tactical Score can signal earlier shifts when the Regime line is slow to react.
3. The histogram shows the direction and acceleration of change. A shift from negative to positive histogram bars suggests the backdrop is improving.
4. Background shading follows the histogram — gold-tinted means improving, red-tinted means deteriorating.
5. The contribution table shows which factor is dominant.

Use the composite as a backdrop filter, not a trade signal. Supportive readings confirm tailwinds for gold; restrictive readings suggest caution or the need for stronger price confirmation.

Alerts

Eight alerts across three categories:
• Momentum Shifts: histogram crosses above or below zero — earliest signal that the macro backdrop is changing direction.
• Acceleration Starts: improvement or deterioration begins to gain strength.
• Regime Level: Regime score enters the gold-friendly or headwind zone, or crosses the neutral line.

All alerts trigger at bar close. For live use, "Once Per Bar Close" is recommended.

Important

GMB is a macro context tool. It reads the structural environment for gold — volatility dynamics, dollar pressure, and real yield conditions — and presents them as a single composite with a momentum overlay. It does not predict price, generate trade signals, or replace chart analysis.

Settings may behave differently across instruments and timeframes. The model inputs (VIX, GVZ, DXY, real yields) are daily-frequency data, so on intraday charts the script falls back to daily resolution. Minimum practical timeframe is 1h; 4h or Daily is recommended.

Always combine the output with broader market analysis, price structure, and risk management.

---

TradingFlow: Gold Macro Bias (GMB)

GMB 是一個宏觀模型，用於判斷黃金所處的宏觀環境。它將 VIX、GVZ、DXY 和實際收益率數據標準化為一個綜合分數，再透過 MACD 風格的動量柱狀圖顯示宏觀背景正在改善還是惡化。目的是提供結構化的宏觀脈絡，讓黃金相關的判讀能在更清楚的背景下進行。

此指標並非以黃金價格為依據，也不預測價格方向。它描述的是傾向支持或限制黃金的宏觀條件，以及這些條件變化的速度。

核心概念

GMB 結合四項宏觀輸入：
• VIX：整體股票市場的風險規避程度。VIX 越高，通常代表避險需求越強。
• GVZ：黃金的隱含波動率。顯示黃金本身是否正在對宏觀壓力作出反應。
• DXY：美元強度。美元越強，通常對黃金越不利。
• 實際收益率：10 年期、30 年期或混合利率。實際收益率越高，持有黃金的機會成本越大。

核心比較在於 GVZ 與 VIX 之間。當整體市場壓力（VIX）偏高但黃金波動率（GVZ）相對平靜時，模型解讀為可能有利於黃金——股票壓力 eventually 可能帶動黃金的追漲需求。當黃金波動率相對於 VIX 偏高時，模型解讀為較不利。

雙速度架構：Regime 與 Tactical

GMB 同時運行兩條分數：
• Regime：慢線，反映宏觀大趨勢。這是判讀整體背景的主要線條，驅動區域邏輯和警報。
• Tactical：快線，用於尋找進場時機。對突發政策衝擊或市場變化的反應更快。

動量柱狀圖（MACD 風格）

柱狀圖顯示 Tactical 與 Regime 分數之間的差值，運作方式類似 MACD 柱狀圖：
• 正柱：Tactical 在 Regime 上方——宏觀背景正在改善。
• 負柱：Tactical 在 Regime 下方——宏觀背景正在惡化。
• 柱子變高：動量正在加速。
• 柱子變矮：動量正在減速——可能接近轉折點。

柱狀圖使用四種顏色區分以上狀態：
• 亮金色——改善中、加速中
• 淺金色——改善中、減速中
• 亮紅色——惡化中、加速中
• 淺紅色——惡化中、減速中

背景底色使用相同邏輯的半透明版本。

Z-Score 標準化與截斷

所有輸入在各自的標準化窗口內轉換為 Z-Score，讓 VIX、GVZ、DXY 和實際收益率能在同一尺度上組合成單一綜合分數。

Z-Score 截斷在正負 3.5 之內。這防止極端黑天鵝事件的離群值扭曲綜合分數。在 VIX 飆升等事件中，未截斷的 Z-Score 可能達到 5 或更高，會把整個模型拉偏。截斷確保模型在壓力環境下仍保持穩定。

可調組件權重

每個組件有獨立的權重：
• VIX-GVZ Gap 權重
• DXY 權重
• 實際收益率權重

權重保持固定且手動設定，以確保透明度。自動適應權重會降低可解釋性——難以理解模型為何改變行為。固定權重讓你清楚看到每個因子的貢獻。

實際收益率模式

實際收益率輸入可設定為：
• 10Y：僅使用 10 年期實際收益率（FRED:DFII10）。
• 30Y：僅使用 30 年期實際收益率（FRED:DFII30）。對財政主導和長端流動性事件更敏感。
• Blended：兩者的加權組合。

30Y 選項能捕捉 10Y 單獨可能遺漏的長端動態，特別是在財政擴張或國債回購操作期間。

貢獻度面板

右上角的可選面板顯示各組件的當前 Z-Score：
• VIX-GVZ Gap
• DXY
• 實際收益率

這能幫助你一眼看出是哪個因子在驅動綜合分數——是美元、實際收益率還是波動率缺口。

判讀方式

1. Regime 綜合分數是主要依據。持續的正讀數（invert 開啟時）代表宏觀背景有利於黃金。
2. Tactical 分數可以在 Regime 線反應較慢時，提前信號顯示環境轉變。
3. 柱狀圖顯示變化的方向和加速度。柱狀圖從負轉正，代表背景正在改善。
4. 背景底色跟隨柱狀圖——金色調代表改善，紅色調代表惡化。
5. 貢獻度面板顯示哪個因子占主導。

將綜合分數作為背景過濾器，而非交易信號。有利的讀數確認黃金的順風；不利的讀數代表需要謹慎或要求更強的價格確認。

警報

共八個警報，分為三類：
• 動量轉向：柱狀圖穿越零軸——宏觀背景方向改變的最早信號。
• 加速啟動：改善或惡化開始增強。
• Regime 區域：Regime 分數進入有利或不利區域，或穿越中性線。

所有警報在 K 線收盤後觸發。即時使用時，建議選擇「Once Per Bar Close」。

重要說明

GMB 是一個宏觀背景工具。它讀取黃金的結構性環境——波動率動態、美元壓力和實際收益率條件——並以單一綜合分數搭配動量疊加呈現。它不預測價格，不產生交易信號，也不取代圖表分析。

不同市場和時間週期的表現可能不同。模型輸入（VIX、GVZ、DXY、實際收益率）均為日頻數據，因此在日內圖表上會自動回落至日線解析度。最低建議時間框架為 1h，推薦使用 4h 或日線。

使用時仍要結合更廣泛的市場分析、價格結構和風險管理。

---

TradingFlow: Gold Macro Bias (GMB)

GMBは、金を取り巻くマクロ環境を読み取るためのモデルです。ボラティリティ、ドルの強さ、実質利回りを組み合わせ、VIX・GVZ・DXY・実質利回りのデータをZ-Scoreで正規化した上で一つのコンポジットスコアにまとめます。MACDスタイルのモメンタムヒストグラムにより、マクロ環境が金にとって改善方向なのか悪化方向なのかを視覚的に示します。金に関する判断に、背景となるマクロ構造をより明確に把握できるようにすることが目的です。

このインジケーターは金の価格を基盤とせず、価格を予測もしません。金を支援したり制限したりするマクロ条件と、その変化の速度を示すものです。

コンセプト

GMBは4つのマクロ入力を組み合わせます：
• VIX：株式市場全体のリスク回避度。VIXが高いほど、 Safe-haven需要が強くならないこともあります。
• GVZ：金の Implied Volatility。金自体がマクロのストレスに反応しているかどうかを示します。
• DXY：米ドルの強さ。ドルが強くなると、通常は金の追い風ではなくなります。
• 実質利回り：10年国債、30年国債、またはそれらのブレンド。実質利回りが高いほど、金を保有する機会コストが大きくなります。

中心となるのはGVZとVIXの比較です。市場全体のストレス（VIX）が高まっているにもかかわらず、金のボラティリティ（GVZ）が比較的落ち着いている場合、モデルはこれを金にとって好材料と読みます。株式市場のストレスが金への追加需要につながる可能性があるためです。逆に、GVZがVIXに対して高水準にある場合、モデルはこれをやや不利と読みます。

デュアルスピードアーキテクチャ：Regime と Tactical

GMBは2つのスコアを並行して算出します：
• Regime：スローなマクロトレンド。全体的な環境を読むための主要なラインで、ゾーンロジックとアラートを駆動します。
• Tactical：高速なオーバーレイ。エントリータイミングの把握に活用します。突然の政策変更や市場の衝突にもより早く反応します。

モメンタムヒストグラム（MACDスタイル）

ヒストグラムはTacticalとRegimeのスコア差を表示し、MACDのヒストグラムと同じように機能します：
• 正のバー：TacticalがRegimeを上回る — マクロ環境が改善方向にあることを示します。
• 負のバー：TacticalがRegimeを下回る — マクロ環境が悪化方向にあることを示します。
• バーが伸びる：モメンタムが加速中。
• バーが縮む：モメンタムが減速中 — 転換点に近づいている可能性があります。

ヒストグラムは4色で状態を区別します：
• 明るいゴールド — 改善・加速中
• 薄いゴールド — 改善・減速中
• 明るい赤 — 悪化・加速中
• 薄い赤 — 悪化・減速中

背景の塗りつぶしは同じロジックの半透明版を使用します。

Z-Scoreの正規化とキャップ

すべての入力はそれぞれの正規化期間においてZ-Scoreに変換されます。これにより、VIX・GVZ・DXY・実質利回りが同じスケールで比較可能となり、一つのコンポジットスコアにまとめることができます。

Z-Scoreは±3.5にキャップされます。これにより、ブラックスワンイベントによる極端な外れ値がコンポジットを歪めるのを防ぎます。VIXの急騰などでは、キャップなしのZ-Scoreは5を超えることもあり、モデル全体のバランスを崩す可能性があります。キャップにより、ストレス環境下でもモデルは安定した動作を保ちます。

コンポーネント重みの調整

各コンポーネントには独立した重みが設定できます：
• VIX-GVZ Gap 重み
• DXY 重み
• 実質利回り 重み

重みは透明性を保つため、固定で手動設定とします。適応的な自動重み付けは解釈性を損なう可能性があります — モデルの挙動がなぜ変化したかが分かりにくくなるためです。固定重みにより、各因子がどのように寄与しているかを明確に把握できます。

実質利回りモード

実質利回りの入力は以下から選択できます：
• 10Y：10年国債の実質利回りのみ（FRED:DFII10）。
• 30Y：30年国債の実質利回りのみ（FRED:DFII30）。フィッスカル・ドミナンスや長端の流動性イベントにより敏感です。
• Blended：両者の加重平均。

30年国債を選択することで、財政拡大やTreasuryリパッチェス（買戻し）オペレーションの時期など、10年国債だけでは捉えきれない長端の動向を把握できるようになります。

コンポーネント寄与テーブル

右上に表示されるオプションのテーブルは、各コンポーネントの現在のZ-Scoreを一覧で示します：
• VIX-GVZ Gap
• DXY
• 実質利回り

これにより、コンポジットスコアをどの因子が駆動しているかを一目で把握できます — ドルなのか、実質利回りなのか、ボラティリティギャップなのか。

読み方

1. Regimeコンポジットスコアが主要な判断材料です。持続的な正の値（invert ON時）は、マクロ環境が金にとって好環境であることを示します。
2. Tacticalスコアは、Regimeが反応に遅れがちな場面で、環境の変化を先行して捉えることができます。
3. ヒストグラムは変化の方向と加速度を示します。負から正への転換は、環境が改善途上にあることを示します。
4. 背景の塗りつぶしはヒストグラムに連動します — ゴールド系は改善、レッド系は悪化。
5. 寄与テーブルは、どの因子が支配的かを示します。

コンポジットスコアはバックグラウンドフィルターとしてお使いください。トレードシグナルではありません。好材料の読みは金の追い風を確認し、不利な読みは慎重さを求めたり、より強い価格の確認を要求したりします。

アラート

3カテゴリ、計8つのアラートがあります：
• モメンタムシフト：ヒストグラムがゼロラインをクロス — マクロ環境の方向転換に関する最も早いシグナル。
• 加速開始：改善または悪化の勢いが増し始めたことを示します。
• Regimeゾーン：Regimeスコアがゴールドフレンドリー圏またはヘッドウインド圏に入侵、またはニュートラルラインをクロスします。

すべてのアラートはバーの確定時に発火します。リアルタイムで使用する場合は「Once Per Bar Close」の選択を推奨します。

重要な注意

GMBはマクロのコンテキストを読むためのツールです。金の構造的な環境 — ボラティリティの動向、ドルの圧力、実質利回りの状況 — を一つのコンポジットスコアとモメンタムオーバーレイとして表示します。価格を予測したり、トレードシグナルを生成したり、チャート分析の代わりになるものではありません。

銘柄や時間足によって挙動が異なる場合があります。モデルの入力（VIX、GVZ、DXY、実質利回り）は日足データであるため、インtradayチャートでは日足解像度にフォールバックします。最低推奨時間足は1hで、4hまたは日足が推奨されます。

より広範な市場分析、価格構造、適切なリスク管理と組み合わせてご使用ください。

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © realanthonyc https://www.tradingview.com/u/realanthonyc

//@version=6
// ------------------------------------------------------------------------------
//  TradingFlow: Gold Macro Bias
//  VIX / GVZ / DXY + Real Yield Filter (10Y / 30Y / Blended)
//  Z-Score cap ±3.5 | Dual-speed Regime/Tactical
// ------------------------------------------------------------------------------
indicator("TradingFlow: Gold Macro Bias (GMB) v2.0.4", shorttitle="TF: GMB", overlay=false, precision=2, max_bars_back=500)

// ===================================
// INPUTS
// ===================================

grp_display = "Display"
showSmoothedScore = input.bool(true, "Show Regime Composite Score", group=grp_display, tooltip="The primary line for reading the overall macro backdrop. This is the Regime (slow) composite.")
showTactical      = input.bool(true, "Show Tactical Score", group=grp_display, tooltip="A faster-responsive overlay that can help with entry timing.\nUses a shorter normalization window (default 21 bars).")
showHistogram     = input.bool(true, "Show Momentum Histogram", group=grp_display, tooltip="MACD-style histogram showing the difference between Tactical and Regime scores.\n\nPositive bars = Tactical above Regime → macro backdrop improving.\nNegative bars = Tactical below Regime → macro backdrop deteriorating.\n\nGrowing bars = momentum accelerating.\nShrinking bars = momentum decelerating (possible inflection).")
showSpread        = input.bool(false, "Show VIX vs GVZ Response Gap", group=grp_display, tooltip="Secondary context line. Shows whether gold volatility is responding more or less aggressively than broader market fear.\nThis is not the final decision line — use the Regime score for direction.")
showBackground    = input.bool(true, "Show background zones", group=grp_display, tooltip="Colors the background based on the momentum histogram:\nGold = improving backdrop.\nRed = deteriorating backdrop.\nBright = accelerating, Muted = decelerating.")
showTable         = input.bool(true, "Show Contribution Table", group=grp_display, tooltip="Displays a panel showing each component's value and weighted contribution to the Regime score.\nHelps identify which factor (dollar, yields, or volatility gap) is driving the model.")
invertScore       = input.bool(true, "Invert Composite Score Line", group=grp_display, tooltip="When enabled, gold-friendly conditions appear above zero and headwind conditions below zero.\n\nThis changes the display direction only. It does not change model inputs, scoring, or signal logic.")

grp_symbols = "Data Sources"
vixSymbol    = input.symbol("CBOE:VIX", "VIX symbol", group=grp_symbols, tooltip="VIX measures equity risk aversion. Higher VIX usually reflects stronger demand for protection.")
gvzSymbol    = input.symbol("CBOE:GVZ", "GVZ symbol", group=grp_symbols, tooltip="GVZ measures implied volatility in gold. It helps show whether gold itself is responding to macro stress.")
dxySymbol    = input.symbol("TVC:DXY", "DXY symbol", group=grp_symbols, tooltip="DXY measures U.S. dollar strength. A stronger dollar often acts as a headwind for gold.")
realYield10y = input.symbol("FRED:DFII10", "Real Yield 10Y", group=grp_symbols, tooltip="10-year real yield. Higher real yields are usually a macro headwind for gold.")
realYield30y = input.symbol("FRED:DFII30", "Real Yield 30Y", group=grp_symbols, tooltip="30-year real yield. Captures long-end dynamics and fiscal dominance risk.\nIf DFII30 is unavailable on your data feed, use a suitable long-end real yield proxy.")
srcTf        = input.timeframe("", "Source timeframe (Chart = Auto)", group=grp_symbols, tooltip="Select 'Chart' (the default) for automatic timeframe selection.\n\nThe script uses the chart timeframe on daily-or-higher charts and automatically falls back to D on intraday charts.\n\nSet a fixed timeframe here if you want all external inputs sampled from one specific resolution.")

grp_model = "Model Settings"
zLenRegime        = input.int(63, "Regime normalization length", minval=20, group=grp_model, tooltip="Lookback for Regime (slow) Z-Score normalization. 63 bars ≈ one trading quarter.\nDetermines the macro trend context. Z-Scores are capped at ±3.5 to prevent black-swan outliers from distorting the composite.")
zLenTactical      = input.int(21, "Tactical normalization length", minval=10, group=grp_model, tooltip="Lookback for Tactical (fast) Z-Score normalization. 21 bars ≈ one trading month.\nProvides shorter-term entry/exit timing signals relative to the Regime line.")
smoothLen         = input.int(5, "Score smoothing (Regime)", minval=1, group=grp_model, tooltip="EMA smoothing applied to the Regime Composite Score. Higher values reduce noise but slow response.\nSet to 1 to disable smoothing.")
smoothLenTactical = input.int(3, "Score smoothing (Tactical)", minval=1, group=grp_model, tooltip="EMA smoothing applied to the Tactical Score. Keep low (1–3) to preserve responsiveness.\nSet to 1 to disable smoothing.")

grp_weights = "Component Weights"
weightGap       = input.float(1.0, "VIX-GVZ Gap weight", step=0.1, minval=0.0, group=grp_weights, tooltip="Controls how strongly the VIX–GVZ volatility gap affects the composite score.\n\nThe gap measures gold's volatility response relative to broad market stress.\nA positive gap (GVZ > VIX) typically signals gold-specific stress.")
weightDXY       = input.float(1.0, "DXY weight", step=0.1, minval=0.0, group=grp_weights, tooltip="Controls how strongly the U.S. dollar index affects the composite score.\n\nA stronger dollar is typically a headwind for gold.")
weightRealYield = input.float(0.85, "Real Yield weight", step=0.1, minval=0.0, group=grp_weights, tooltip="Controls how strongly the real yield affects the composite score.\n\nHigher real yields increase the opportunity cost of holding gold.")

grp_ry = "Real Yield Settings"
ryMode     = input.string("Blended", "Real Yield Mode", options=["10Y", "30Y", "Blended"], group=grp_ry, tooltip="'10Y' uses only the 10-year real yield.\n'30Y' uses only the 30-year real yield.\n'Blended' combines both with configurable weights.\n\nThe 30Y is more sensitive to fiscal dominance and long-end liquidity events.")
ryBlend10y = input.float(0.60, "Blended: 10Y weight", step=0.05, minval=0.0, maxval=1.0, group=grp_ry, tooltip="Weight for the 10Y real yield in Blended mode. The 30Y weight is 1 minus this value.\nExample: 0.60 means 60% 10Y + 40% 30Y.")

grp_filter = "Real Yield Filter"
useRealYieldFilter = input.bool(true, "Use real yield filter", group=grp_filter, tooltip="When enabled, the model includes the normalized real yield level.\nHigher real yields are usually less supportive for gold.\n\nDisable to remove real yield from the composite entirely.")

grp_levels = "Threshold Settings"
upperLevel = input.float(1.0, "Upper threshold", step=0.1, group=grp_levels, tooltip="Upper guide threshold for the Composite Score.\n\nWith invert ON: this is the gold-friendly threshold.\nWith invert OFF: this is the headwind threshold.")
lowerLevel = input.float(-1.0, "Lower threshold", step=0.1, group=grp_levels, tooltip="Lower guide threshold for the Composite Score.\n\nWith invert ON: this is the headwind threshold.\nWith invert OFF: this is the gold-friendly threshold.")

// ===================================
// COLORS
// ===================================

colVIX       = color.new(color.rgb(21, 78, 237), 0)   // blue-purple
colGVZ       = color.new(color.rgb(200, 150, 55), 0)  // gold
colDXY       = color.new(color.rgb(42, 165, 73), 0)   // green
colRealYield = color.new(color.rgb(255, 140, 0), 0)   // orange
colGap       = color.new(color.teal, 50)
colScore     = colGVZ
colTactical  = color.new(color.rgb(250, 165, 75), 0)
// Histogram colors: 4 states (accel/decel × bull/bear)
colHistBullAccel = color.new(color.rgb(220, 180, 50), 0)   // bright gold — improving, accelerating
colHistBullDecel = color.new(color.rgb(235, 210, 120), 10) // light gold — improving, decelerating
colHistBearAccel = color.new(color.rgb(220, 70, 70), 0)    // bright red — deteriorating, accelerating
colHistBearDecel = color.new(color.rgb(235, 140, 140), 10) // light red — deteriorating, decelerating
// Background versions (high transparency)
colHistBullAccelBg = color.new(color.rgb(220, 180, 50), 90)
colHistBullDecelBg = color.new(color.rgb(235, 210, 120), 93)
colHistBearAccelBg = color.new(color.rgb(220, 70, 70), 90)
colHistBearDecelBg = color.new(color.rgb(235, 140, 140), 93)

// ===================================
// HELPERS
// ===================================

resolvedSourceTf = srcTf != "" ? srcTf : timeframe.isintraday ? "D" : timeframe.period

f_getSeries(sym, tf) =>
    request.security(sym, tf, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

f_zscore(src, len) =>
    mean = ta.sma(src, len)
    dev  = ta.stdev(src, len)
    raw  = na(src) or na(mean) or na(dev) or dev == 0 ? na : (src - mean) / dev
    // Cap extreme values for robustness against black-swan outliers
    na(raw) ? na : raw < -3.5 ? -3.5 : raw > 3.5 ? 3.5 : raw

// ===================================
// DATA
// ===================================

vix  = f_getSeries(vixSymbol, resolvedSourceTf)
gvz  = f_getSeries(gvzSymbol, resolvedSourceTf)
dxy  = f_getSeries(dxySymbol, resolvedSourceTf)
ry10 = f_getSeries(realYield10y, resolvedSourceTf)
ry30 = f_getSeries(realYield30y, resolvedSourceTf)

// Real Yield selection
realYield = ry10
if ryMode == "30Y"
    realYield := ry30
else if ryMode == "Blended"
    realYield := ry10 * ryBlend10y + ry30 * (1.0 - ryBlend10y)

// ===================================
// NORMALIZED COMPONENTS (Regime + Tactical)
// ===================================

// Regime (slow — macro trend)
vixZ_r = f_zscore(vix, zLenRegime)
gvzZ_r = f_zscore(gvz, zLenRegime)
dxyZ_r = f_zscore(dxy, zLenRegime)
ryZ_r  = f_zscore(realYield, zLenRegime)

// Tactical (fast — entry timing)
vixZ_t = f_zscore(vix, zLenTactical)
gvzZ_t = f_zscore(gvz, zLenTactical)
dxyZ_t = f_zscore(dxy, zLenTactical)
ryZ_t  = f_zscore(realYield, zLenTactical)

//─────────────────────────────────────────────────────────────────────────────
// CORE MODEL
//
// Concept:
// 1) VIX represents broad risk aversion.
// 2) GVZ represents implied volatility in gold.
// 3) DXY represents U.S. dollar pressure.
// 4) Real yield (10Y / 30Y / Blended) adds a macro valuation filter for gold.
//
// Model interpretation:
// - `gvzZ - vixZ` compares gold's own volatility response with broader market stress.
// - A relatively low reading means equity stress is elevated versus gold's response,
//   which can imply a more supportive backdrop for gold if catch-up demand develops.
// - A relatively high reading means gold volatility is already elevated relative to
//   VIX, which is less favorable on this framework.
// - Strong DXY and high real yields both push the score toward a more restrictive
//   gold backdrop.
//─────────────────────────────────────────────────────────────────────────────

// Regime composite
gap_r       = gvzZ_r - vixZ_r
base_r      = gap_r * weightGap + dxyZ_r * weightDXY
ryAdj_r     = useRealYieldFilter ? ryZ_r * weightRealYield : 0.0
composite_r = base_r + ryAdj_r

// Tactical composite
gap_t       = gvzZ_t - vixZ_t
base_t      = gap_t * weightGap + dxyZ_t * weightDXY
ryAdj_t     = useRealYieldFilter ? ryZ_t * weightRealYield : 0.0
composite_t = base_t + ryAdj_t

// Apply invert
scoreBase_r = invertScore ? -composite_r : composite_r
scoreBase_t = invertScore ? -composite_t : composite_t

// Smoothing
score_r = smoothLen > 1 ? ta.ema(scoreBase_r, smoothLen) : scoreBase_r
score_t = smoothLenTactical > 1 ? ta.ema(scoreBase_t, smoothLenTactical) : scoreBase_t

// Spread for display
spreadBase = invertScore ? (vixZ_r - gvzZ_r) : (gvzZ_r - vixZ_r)

//─────────────────────────────────────────────────────────────────────────────
// MOMENTUM HISTOGRAM
//
// Histogram = Tactical − Regime
// - Positive: Tactical above Regime → macro backdrop improving
// - Negative: Tactical below Regime → macro backdrop deteriorating
// - Growing magnitude: momentum accelerating
// - Shrinking magnitude: momentum decelerating (possible inflection)
//─────────────────────────────────────────────────────────────────────────────

histogram   = score_t - score_r
histGrowing = na(histogram[1]) ? false : math.abs(histogram) > math.abs(histogram[1])
histColor   = histogram > 0 ? (histGrowing ? colHistBullAccel : colHistBullDecel) : (histGrowing ? colHistBearAccel : colHistBearDecel)
histBgColor = histogram > 0 ? (histGrowing ? colHistBullAccelBg : colHistBullDecelBg) : (histGrowing ? colHistBearAccelBg : colHistBearDecelBg)

//─────────────────────────────────────────────────────────────────────────────
// ZONE INTERPRETATION
//
// Inverted display (invert ON):
// - Higher score = more gold-friendly
// - Lower score = more gold headwind
//
// Default display (invert OFF):
// - Lower score = more gold-friendly
// - Higher score = more gold headwind
//─────────────────────────────────────────────────────────────────────────────

goldFriendly = invertScore ? score_r > upperLevel : score_r < lowerLevel
goldHeadwind = invertScore ? score_r < lowerLevel : score_r > upperLevel

//─────────────────────────────────────────────────────────────────────────────
// SIGNALS & EVENT TRIGGERS
//
// All alerts are single-bar discrete events — no multi-bar spam.
//─────────────────────────────────────────────────────────────────────────────

// Momentum histogram — zero-line crossings
histImproving     = ta.crossover(histogram, 0.0)
histDeteriorating = ta.crossunder(histogram, 0.0)

// Acceleration STARTS only (prevents multi-bar spam)
histAccelBullStart = histogram > 0 and histGrowing and not histGrowing[1]
histAccelBearStart = histogram < 0 and histGrowing and not histGrowing[1]

// Regime Zone Entry (absolute level)
enterFriendly = invertScore ? ta.crossover(score_r, upperLevel) : ta.crossunder(score_r, lowerLevel)
enterHeadwind = invertScore ? ta.crossunder(score_r, lowerLevel) : ta.crossover(score_r, upperLevel)

// Regime Neutral Line Crosses
zeroCrossUp = ta.crossover(score_r, 0.0)
zeroCrossDn = ta.crossunder(score_r, 0.0)

// ===================================
// PLOTS
// ===================================

hline(0.0, "Neutral line", color=color.new(color.gray, 45), linestyle=hline.style_solid)
hline(upperLevel, "Upper threshold", color=color.new(color.gray, 70))
hline(lowerLevel, "Lower threshold", color=color.new(color.gray, 70))

plot(showHistogram ? histogram : na, "Momentum", color=histColor, style=plot.style_columns, linewidth=2, display=showHistogram ? display.all : display.none)
plot(showSpread ? spreadBase : na, "VIX vs GVZ Response Gap", color=colGap, linewidth=1, display=showSpread ? display.all : display.none)
plot(showTactical ? score_t : na, "Tactical Score", color=colTactical, linewidth=1, display=showTactical ? display.all : display.none)
plot(showSmoothedScore ? score_r : na, "Regime Composite Score", color=colScore, linewidth=2, display=showSmoothedScore ? display.all : display.none)

// Hidden diagnostic plots
plot(invertScore ? -vixZ_r : vixZ_r, "VIX (R)", color=colVIX, display=display.none)
plot(invertScore ? -gvzZ_r : gvzZ_r, "GVZ (R)", color=colGVZ, display=display.none)
plot(invertScore ? -dxyZ_r : dxyZ_r, "DXY (R)", color=colDXY, display=display.none)
plot(useRealYieldFilter ? (invertScore ? -ryZ_r : ryZ_r) : na, "Real Yield (R)", color=colRealYield, display=display.none)

bgcolor(showBackground ? histBgColor : na)

// ===================================
// CONTRIBUTION TABLE
// ===================================

var table infoTable = table.new(position.top_right, 2, 4, border_width=1, bgcolor=color.new(color.black, 20))

if showTable and barstate.islast
    _hdrBg = color.new(color.gray, 30)
    _rowBg = color.new(color.black, 50)
    _ts    = size.tiny

    // Header
    table.cell(infoTable, 0, 0, "Component", text_color=color.white, bgcolor=_hdrBg, text_size=_ts)
    table.cell(infoTable, 1, 0, "Z-Score",   text_color=color.white, bgcolor=_hdrBg, text_size=_ts)

    // VIX-GVZ Gap (difference of Z-Scores)
    table.cell(infoTable, 0, 1, "VIX-GVZ Gap", text_color=color.white, bgcolor=_rowBg, text_size=_ts)
    table.cell(infoTable, 1, 1, str.tostring(gap_r, "#.##"), text_color=color.white, bgcolor=_rowBg, text_size=_ts)

    // DXY (Z-Score)
    table.cell(infoTable, 0, 2, "DXY", text_color=color.white, bgcolor=_rowBg, text_size=_ts)
    table.cell(infoTable, 1, 2, str.tostring(dxyZ_r, "#.##"), text_color=color.white, bgcolor=_rowBg, text_size=_ts)

    // Real Yield (Z-Score)
    table.cell(infoTable, 0, 3, "Real Yield", text_color=color.white, bgcolor=_rowBg, text_size=_ts)
    table.cell(infoTable, 1, 3, str.tostring(ryZ_r, "#.##"), text_color=color.white, bgcolor=_rowBg, text_size=_ts)

// ===================================
// ALERTS
// ===================================

// 1. Primary Momentum Shifts
alertcondition(histImproving,
     "Macro Backdrop: Improving",
     "Momentum histogram crossed above zero — Tactical moved above Regime. Macro backdrop is shifting to improving.")
alertcondition(histDeteriorating,
     "Macro Backdrop: Deteriorating",
     "Momentum histogram crossed below zero — Tactical moved below Regime. Macro backdrop is shifting to deteriorating.")

// 2. Acceleration Starts (impulse confirmation)
alertcondition(histAccelBullStart,
     "Momentum: Bullish Acceleration Started",
     "Macro improvement is now accelerating (histogram positive and expanding).")
alertcondition(histAccelBearStart,
     "Momentum: Bearish Acceleration Started",
     "Macro deterioration is now accelerating (histogram negative and expanding).")

// 3. Regime Absolute Zone Entries
alertcondition(enterFriendly,
     "Regime: Entered Gold-Friendly Zone",
     "Regime Composite Score has entered the gold-friendly zone.")
alertcondition(enterHeadwind,
     "Regime: Entered Gold-Headwind Zone",
     "Regime Composite Score has entered the gold-headwind zone.")

// 4. Regime Neutral Line
alertcondition(zeroCrossUp,
     "Regime: Crossed Above Neutral",
     "Regime Composite Score crossed above the neutral line (0.0).")
alertcondition(zeroCrossDn,
     "Regime: Crossed Below Neutral",
     "Regime Composite Score crossed below the neutral line (0.0).")
````
