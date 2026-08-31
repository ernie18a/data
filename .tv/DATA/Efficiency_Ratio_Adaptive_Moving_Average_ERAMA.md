<!-- tradingview-pine-id: PUB;79bd3db441c64338815212bc4123a457 -->
<!-- tradingviewscripts-format: 1 -->
# Efficiency Ratio Adaptive Moving Average (ERAMA)

Source: https://www.tradingview.com/script/NSGvTF3X-Efficiency-Ratio-Adaptive-Moving-Average-ERAMA/

## Description

Efficiency Ratio Adaptive Moving Average (ERAMA)

Efficiency Ratio Adaptive Moving Average (ERAMA) is a smooth adaptive moving average that uses Kaufman's Efficiency Ratio to shift between fast and slow EMA behavior. It then applies WMA and EMA smoothing followed by length-adjusted lag reduction.

The objective is to combine three useful properties in one line: adapt to the directional efficiency of recent price movement, maintain a visually stable baseline, and recover part of the delay introduced by smoothing. ERAMA adjusts the balance between smoothness and responsiveness using current and historical data.

How ERAMA Is Calculated

1. Efficiency Ratio

ERAMA first measures how efficiently the selected Source has moved over the ER Length:

Change = |Source − Source from ER Length bars ago|
Volatility = Sum of |Source − Previous Source| over the ER Length
ER = Change ÷ Volatility

The Efficiency Ratio is bounded between 0 and 1:

• ER near 1 — most movement contributed to net progress in one direction
• ER near 0 — price traveled back and forth with little net progress

Because both Change and Volatility scale with price movement, ER is independent of the instrument's nominal price level.

2. Efficiency-Adaptive EMA Blend

The Fast and Slow lengths create two conventional EMAs of the selected Source:

Fast EMA = EMA(Source, Fast Length)
Slow EMA = EMA(Source, Slow Length)

ERAMA blends these two lines using the current Efficiency Ratio:

Adaptive = Slow EMA + ER × (Fast EMA − Slow EMA)

When ER is high, Adaptive moves closer to the Fast EMA. When ER is low, it stays closer to the Slow EMA. Intermediate ER values produce a proportional blend between the two.

This construction uses Kaufman's Efficiency Ratio as an adaptive weight, but it is not the standard recursive Kaufman Adaptive Moving Average (KAMA) formula.

3. WMA and EMA Smoothing

The adaptive blend passes through two smoothing stages:

WMA Base = WMA(Adaptive, WMA Smooth Length)
Smoothed = EMA(WMA Base, EMA Smooth Length)

The WMA gives greater weight to recent observations. The following EMA softens residual variation and determines the main output horizon. Higher values create a steadier line but also introduce more delay.

4. Length-Adjusted Lag Reduction

ERAMA compares the Smoothed line with an EMA-smoothed version of itself:

Responsiveness Scale = Min(1, 50 ÷ EMA Length)^Responsiveness Length Decay
Effective Responsiveness = Responsiveness × Responsiveness Scale
ERAMA = Smoothed + Effective Responsiveness × [Smoothed − EMA(Smoothed, EMA Length)]

The difference between Smoothed and EMA(Smoothed) acts as a DEMA-style lag correction. A Responsiveness value of 0 disables this correction. A value of 1 applies the full correction before length scaling.

For EMA lengths of 50 or less, Responsiveness Scale equals 1. Above 50, the scale decreases gradually according to Responsiveness Length Decay. This keeps one Responsiveness setting practical across short and long EMA lengths. A decay value of 0 disables length-based scaling.

The Mathematical Idea

ERAMA separates adaptation, smoothing, and lag reduction into distinct stages.

The Efficiency Ratio controls the position between two already-defined EMA responses. WMA and EMA then create a stable output baseline. Finally, a partial DEMA-style correction restores part of the response lost to smoothing. The correction is reduced progressively for longer EMA lengths, where the distance between a line and its second EMA can otherwise become disproportionately large.

This is a causal construction: every stage uses only current and past data. The lag-reduction term can increase turning sensitivity and may create overshoot at aggressive settings, but the Responsiveness and Responsiveness Length Decay controls make that tradeoff explicit.

Characteristics and Advantages

• Efficiency-based adaptation using a bounded 0-to-1 ratio
• Interpretable Fast and Slow EMA anchors
• WMA and EMA smoothing for a stable visual baseline
• Adjustable partial-DEMA lag reduction
• Automatic responsiveness scaling for longer EMA lengths

How to Read ERAMA

Read ERAMA through its slope, its position relative to price, and the behavior of price around the line.

Slope

A rising ERAMA indicates that the smoothed adaptive baseline is moving higher. A falling ERAMA indicates that it is moving lower. A flattening line suggests weaker directional progress or a transition between trend phases.

Price Position

Price holding above a rising ERAMA supports a bullish directional interpretation. Price holding below a falling ERAMA supports a bearish interpretation. Repeated crossings often occur when price is rotating around the adaptive baseline or directional control is weak.

Distance and Reversals

A widening distance between price and ERAMA can reflect strong momentum or extension from the baseline. The lag-reduction stage helps ERAMA respond sooner when the smoothed path turns.

Understanding the Settings

Source
Selects the price series used by ERAMA. The default is HLCC4: the average of High, Low, Close, and Close.

ER Length
Controls the period used to measure directional efficiency. Lower values react to recent path changes sooner. Higher values evaluate efficiency over a broader window.

Fast Length
Sets the Fast EMA used by the adaptive blend. Lower values make the high-efficiency response faster. Fast Length must be lower than Slow Length.

Slow Length
Sets the Slow EMA used by the adaptive blend. Higher values make the low-efficiency response more conservative. Slow Length must be higher than Fast Length.

Responsiveness
Controls the strength of the lag-reduction term. A value of 0 uses the fully smoothed line. Higher values reduce more lag but can increase turning sensitivity and overshoot.

Responsiveness Length Decay
Controls how strongly Responsiveness decreases for EMA lengths above 50. Higher values apply more reduction to long-period lines. A value of 0 uses the same Responsiveness at every EMA length.

WMA Smooth Length
Controls the first smoothing stage. Higher values produce a steadier line with more delay.

EMA Smooth Length
Controls the primary output horizon and the period used by the lag-reduction EMA. Higher values create a smoother, slower baseline.

Default Configuration

Source: HLCC4
ER Length: 10
Fast Length: 2
Slow Length: 30
Responsiveness: 0.88
Responsiveness Length Decay: 0.15
WMA Smooth Length: 12
EMA Smooth Length: 20

Practical Use

ERAMA can serve as an adaptive trend baseline, directional filter, pullback reference, or trade-management guide. It is intended for traders who prefer to interpret slope and price structure directly.

Responsiveness can be tuned to emphasize steadier trend tracking or earlier reactions to short-term changes. The settings can be adapted to the instrument, timeframe, and intended holding period.

---

Efficiency Ratio Adaptive Moving Average (ERAMA)

Efficiency Ratio Adaptive Moving Average（效率比率自適應移動平均線）是一條平滑的自適應移動平均線。它利用考夫曼效率比率（Efficiency Ratio），在快速與慢速 EMA 之間調整，再依次套用 WMA、EMA 平滑及按長度調整的延遲縮減。

ERAMA 的目標，是在一條線內結合三項特性：根據近期價格移動的方向效率作出適應、維持視覺穩定的基準，以及追回部分平滑所造成的延遲。ERAMA 使用目前及歷史資料，調整平滑度與反應速度之間的平衡。

ERAMA 如何計算

1. 效率比率

ERAMA 先衡量所選 Source 在 ER Length 期間內的移動效率：

變化 = |目前 Source − ER Length 之前的 Source|
波動 = ER Length 內每根 K 線之 |Source − 前一個 Source| 總和
ER = 變化 ÷ 波動

效率比率保持在 0 至 1 之間：

• ER 接近 1 — 大部分移動形成單一方向的淨進展
• ER 接近 0 — 價格反覆來回，總路徑較長但淨進展有限

由於變化與波動都會隨價格移動幅度同比例改變，因此 ER 不受商品名義價格水平影響。

2. 效率自適應 EMA 混合

Fast 與 Slow 長度會從所選 Source 建立兩條傳統 EMA：

Fast EMA = EMA（Source，Fast Length）
Slow EMA = EMA（Source，Slow Length）

ERAMA 使用目前的效率比率混合兩條線：

Adaptive = Slow EMA + ER ×（Fast EMA − Slow EMA）

ER 偏高時，Adaptive 會靠近 Fast EMA；ER 偏低時，則靠近 Slow EMA。介乎兩者之間的 ER 會按比例混合兩條 EMA。

這個結構使用考夫曼效率比率作為自適應權重，但並不是標準的遞迴考夫曼自適應移動平均線（KAMA）公式。

3. WMA 與 EMA 平滑

自適應混合結果會通過兩層平滑：

WMA Base = WMA（Adaptive，WMA Smooth Length）
Smoothed = EMA（WMA Base，EMA Smooth Length）

WMA 對較近期數值給予更高權重，後續 EMA 則柔化剩餘變化，並決定主要輸出週期。較高數值會令線條更穩定，但亦會增加延遲。

4. 按長度調整的延遲縮減

ERAMA 會比較 Smoothed 與其 EMA 平滑版本：

Responsiveness Scale = Min（1，50 ÷ EMA Length）^Responsiveness Length Decay
Effective Responsiveness = Responsiveness × Responsiveness Scale
ERAMA = Smoothed + Effective Responsiveness × [Smoothed − EMA（Smoothed，EMA Length）]

Smoothed 與 EMA（Smoothed）之間的差值形成 DEMA 式延遲修正。Responsiveness 設為 0 會停用修正；設為 1 則代表在長度縮放前套用完整修正。

EMA Length 為 50 或以下時，Responsiveness Scale 等於 1。高於 50 後，縮放值會按照 Responsiveness Length Decay 逐步下降，令同一組 Responsiveness 設定可以較合理地跨越短期及長期 EMA 使用。Decay 設為 0 會停用按長度縮放。

數學設計

ERAMA 把自適應、平滑及延遲縮減分成三個獨立階段。

效率比率控制結果在兩條既定 EMA 反應之間的位置；WMA 與 EMA 形成穩定輸出基準；最後的部分 DEMA 式修正，追回一部分因平滑而失去的反應速度。對較長 EMA 而言，線條與其第二層 EMA 之間的差距可能較大，因此修正會隨長度逐步降低。

整個結構只使用目前及過往資料。延遲縮減可提高轉向靈敏度，較進取的設定亦可能產生超調；Responsiveness 與 Responsiveness Length Decay 讓這項取捨可以直接調整。

特性與優點

• 使用 0 至 1 有界效率比率作出適應
• Fast 與 Slow EMA 具有清晰可解釋的反應界線
• WMA 與 EMA 平滑形成穩定視覺基準
• 可調整的部分 DEMA 式延遲縮減
• 長週期 EMA 自動降低反應修正

如何閱讀 ERAMA

閱讀 ERAMA 時，應觀察線條斜率、價格相對位置，以及價格在線條附近的行為。

斜率

ERAMA 上升表示平滑後的自適應基準正在提高；ERAMA 下跌表示基準正在降低。線條逐漸走平，通常代表方向進展減弱，或市場正處於趨勢轉換階段。

價格位置

價格維持在上升 ERAMA 之上，可支持偏多方向判斷；價格維持在下降 ERAMA 之下，可支持偏空判斷。價格反覆穿越 ERAMA，通常出現在價格圍繞自適應基準旋轉，或方向控制偏弱的市況。

距離與轉向

價格與 ERAMA 的距離擴大，可能反映動能增強或價格已偏離基準。延遲縮減讓 ERAMA 在平滑路徑轉向時較早反應。

設定說明

Source
選擇 ERAMA 使用的價格序列。預設為 HLCC4，即 High、Low、Close、Close 的平均值。

ER Length
控制衡量方向效率的期間。較低數值會更快反映近期路徑變化；較高數值則在較廣時間範圍內評估效率。

Fast Length
設定自適應混合使用的 Fast EMA。較低數值會加快高效率市況下的反應。Fast Length 必須低於 Slow Length。

Slow Length
設定自適應混合使用的 Slow EMA。較高數值會令低效率市況下的反應更保守。Slow Length 必須高於 Fast Length。

Responsiveness
控制延遲縮減項的強度。設為 0 時使用完整平滑後的線條；較高數值會追回更多延遲，但亦可能提高轉向靈敏度及超調。

Responsiveness Length Decay
控制 EMA Length 高於 50 後，Responsiveness 隨長度下降的幅度。較高數值會對長週期線條施加更大降幅；設為 0 則所有 EMA Length 使用相同 Responsiveness。

WMA Smooth Length
控制第一層平滑。較高數值會形成更穩定但延遲更多的線條。

EMA Smooth Length
控制主要輸出週期，以及延遲縮減 EMA 所使用的週期。較高數值會形成更平滑、較慢的基準。

預設設定

Source：HLCC4
ER Length：10
Fast Length：2
Slow Length：30
Responsiveness：0.88
Responsiveness Length Decay：0.15
WMA Smooth Length：12
EMA Smooth Length：20

實際應用

ERAMA 可作為自適應趨勢基準、方向過濾器、回調參考或交易管理線，適合希望直接解讀斜率及價格結構的交易者。

Responsiveness 可用來偏向更穩定的趨勢跟隨，或更早反映短期變化。設定可按商品、時間週期及預計持倉時間調整。

---

Efficiency Ratio Adaptive Moving Average (ERAMA)

Efficiency Ratio Adaptive Moving Average（効率比適応型移動平均線）は、カウフマンの効率比（Efficiency Ratio）を利用して速いEMAと遅いEMAの挙動を動的に切り替える、滑らかな適応型移動平均線です。WMA（加重移動平均）とEMA（指数移動平均）による平滑化を行った後、期間長に連動したラグ（遅延）削減処理を適用します。

ERAMAの目的は、3つの有用な特性を1本のラインに統合することです。すなわち、近年の価格値動きの方向性効率に適応すること、視覚的に安定したベースラインを維持すること、そして平滑化によって生じる遅延の一部を取り戻すことです。ERAMAは、現在および過去のデータを用いて平滑性と応答性のバランスを調整します。

ERAMA の計算方法

1. 効率比（Efficiency Ratio）

ERAMAはまず、選択された Source が ER Length 期間内にどれほど効率的に動いたかを測定します。

変化量 = |現在の Source − ER Length 本前の Source|
変動量 = ER Length 期間内の各バーにおける |Source − 前回の Source| の総和
効率比（ER）= 変化量 ÷ 変動量

効率比（ER）は 0 から 1 の範囲に収まります。

• ERが 1 に近い — 値動きの大半が一定方向への純粋な推進に寄与している
• ERが 0 に近い — 価格が反覆移動を繰り返し、総移動距離に対して純推進がほとんどない

変化量と変動量の双方が価格の移動規模に応じてスケールするため、ERは銘柄固有の価格水準（呼び値）に依存しません。

2. 効率適応型 EMA ブレンド

Fast Length と Slow Length のパラメータにより、選択した Source から2つの従来の EMA を作成します。

Fast EMA = EMA（Source, Fast Length）
Slow EMA = EMA（Source, Slow Length）

ERAMAは、現在の効率比（ER）を用いてこれら2つのラインをブレンドします。

Adaptive = Slow EMA + ER ×（Fast EMA − Slow EMA）

ERが高いとき、Adaptiveは Fast EMA に近づきます。ERが低いとき、Slow EMA の近くにとどまります。中間のER値では、2つのEMA間で比例的なブレンドが行われます。

この構造はカウフマンの効率比を適応型ウェイトとして使用していますが、標準的な再帰型カウフマン自適応移動平均線（KAMA）の計算式とは異なります。

3. WMA および EMA による平滑化

自適応ブレンド（Adaptive）は、2段階の平滑化処理を通過します。

WMA Base = WMA（Adaptive, WMA Smooth Length）
Smoothed = EMA（WMA Base, EMA Smooth Length）

WMAは直近のデータに高い重みを置きます。続くEMAは残留変動をなめらかにし、主要な出力周期（時間軸）を決定します。数値を高く設定するほどラインは安定しますが、遅延も大きくなります。

4. 期間長に応じたラグ（遅延）削減

ERAMAは、Smoothed ラインと、それをさらにEMA平滑化したラインを比較します。

Responsiveness Scale = Min（1, 50 ÷ EMA Length）^Responsiveness Length Decay
Effective Responsiveness = Responsiveness × Responsiveness Scale
ERAMA = Smoothed + Effective Responsiveness × [Smoothed − EMA（Smoothed, EMA Length）]

Smoothed と EMA（Smoothed）の差分は、DEMA（二重指数移動平均）スタイルのラグ補正として機能します。Responsiveness を 0 に設定するとこの補正は無効になり、1 に設定すると期間長のスケーリングが適用される前の完全な補正が行われます。

EMA Length が 50 以下のケースでは、Responsiveness Scale は 1 となります。50 を超えると、Responsiveness Length Decay に従ってスケーリング値が徐々に低下します。これにより、短期から長期のEMA期間まで同一の Responsiveness 設定を合理的に運用できます。Decay を 0 に設定すると、期間長に基づくスケーリングが無効になります。

数学的概念と設計思想

ERAMAは「適応」「平滑化」「ラグ削減」を独立した段階として明確に分離しています。

効率比（ER）が、あらかじめ定義された2つのEMA応答の間の位置を制御します。次にWMAとEMAが安定した出力ベースラインを形成します。最後に、部分的なDEMAスタイル補正によって、平滑化で失われた応答速度の一部を取り戻します。長期間のEMAでは、ラインとその2次EMAの間の乖離が過大になる可能性があるため、補正量は長さに応じて段階的に削減されます。

これは完全な因果的構造であり、すべての段階で現在および過去のデータのみを使用します。ラグ削減機能は転換の感度を高める一方で、アグレッシブな設定ではオーバーシュートを引き起こす可能性がありますが、Responsiveness と Responsiveness Length Decay のコントロールにより、このトレードオフを明示的に調整できます。

特徴とメリット

• 0〜1 の有界な効率比に基づく自適応性
• 明確に解釈可能な Fast および Slow EMA アンカー
• 安定した視覚的ベースラインを形成する WMA および EMA 平滑化
• 調整可能な部分 DEMA スタイル・ラグ削減
• 長期 EMA 期間におけるレスポンス補正の自動スケーリング

ERAMA の読み方・分析方法

ERAMAを読み解く際は、ラインの傾き、価格の相対位置、そしてライン周辺での価格の挙動に着目します。

傾き（スロープ）

ERAMAの上昇は、平滑化された自適応ベースラインが切り上がっていることを示します。ERAMAの下降は、ベースラインが切り下がっていることを示します。ラインの平坦化は、方向性の勢いの減衰、またはトレンドの移行期を示唆します。

価格の位置関係

価格が上昇するERAMAの上方で推移している場合は強気（ブル）の方向性を支持し、下降するERAMAの下方で推移している場合は弱気（ベア）の方向性を支持します。ERAMAとの頻繁な交差（クロスオーバー）は、価格がベースライン付近で保ち合いを形成しているか、方向性の主導権が弱い状態によく見られます。

乖離と反転

価格とERAMAとの距離が拡大している場合は、強力なモメンタムまたはベースラインからの乖離を反映しています。ラグ削減ステージにより、平滑化された軌跡が反転する際、ERAMAはより早期に反応することができます。

設定パラメータの理解

Source
ERAMAで使用する価格シリーズを選択します。デフォルトは HLCC4（High, Low, Close, Close の平均値）です。

ER Length
方向性の効率（Efficiency Ratio）を測定する期間を制御します。値が小さいほど直近の値動きの変化に素早く反応し、値が大きいほど広い期間で効率性を評価します。

Fast Length
適応ブレンドで使用する Fast EMA を設定します。値が小さいほど、高効率相場での反応が速くなります。Fast Length は Slow Length より小さく設定する必要があります。

Slow Length
適応ブレンドで使用する Slow EMA を設定します。値が大きいほど、低効率相場での反応が控えめになります。Slow Length は Fast Length より大きく設定する必要があります。

Responsiveness
ラグ削減項の強度を制御します。0 に設定すると完全に平滑化されたラインを使用します。高い値を設定するほどラグが解消されますが、転換時の感度やオーバーシュートが増加する場合があります。

Responsiveness Length Decay
EMA Length が 50 を超えた際に、Responsiveness が減衰する度合いを制御します。高い値を設定するほど長期ラインへの減衰が強く適用されます。0 に設定すると、すべての EMA Length で同じ Responsiveness が適用されます。

WMA Smooth Length
第1段階の平滑化期間を制御します。値が大きいほど、より遅延のある安定したラインを生成します。

EMA Smooth Length
主要な出力周期およびラグ削減用 EMA の期間を制御します。値が大きいほど、より平滑で緩やかなベースラインを生成します。

デフォルト設定

Source: HLCC4
ER Length: 10
Fast Length: 2
Slow Length: 30
Responsiveness: 0.88
Responsiveness Length Decay: 0.15
WMA Smooth Length: 12
EMA Smooth Length: 20

実戦での活用方法

ERAMAは、自適応型のトレンドベースライン、方向性フィルター、押し目・戻りの参照線、あるいはトレード管理ガイドとして活用できます。ラインの傾きや価格構造を直接解釈することを好むトレーダーに適しています。

Responsiveness をチューニングすることで、安定したトレンド追従を重視するか、短期的な変化への早期反応を重視するかを調整できます。設定は取引銘柄、時間軸、および想定する保有期間に応じて最適化することが可能です。

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © realanthonyc https://www.tradingview.com/u/realanthonyc

//@version=6
// ------------------------------------------------------------------------------
//  Efficiency Ratio Adaptive Moving Average
//
//  ERAMA balances smoothness and responsiveness across EMA lengths.
//  It uses the Efficiency Ratio to shift between fast and slow EMAs,
//  then smooths the blended result and applies length-adjusted lag reduction.
//
//  ER          = |source - source[ER length]| / sum(|change(source)|, ER length)
//  Adaptive    = slow EMA + ER * (fast EMA - slow EMA)
//  Smoothed    = EMA(WMA(Adaptive, WMA length), EMA length)
//  R effective = Responsiveness * min(1, 50 / EMA length)^Length Decay
//  ERAMA       = Smoothed + R effective * (Smoothed - EMA(Smoothed, EMA length))
// ------------------------------------------------------------------------------
indicator("Efficiency Ratio Adaptive Moving Average (ERAMA)", "ERAMA", true, timeframe = "", timeframe_gaps = true)

// ERAMA Inputs
float sourceInput  = input.source(hlcc4, "Source")
int   erLenInput   = input.int(10, "ER Length", 2)
int   fastLenInput = input.int(2,  "Fast Length", 1, tooltip = "Must be lower than Slow Length to preserve the intended adaptive response.")
int   slowLenInput = input.int(30, "Slow Length", 2, tooltip = "Must be higher than Fast Length to preserve the intended adaptive response.")
float responsivenessInput = input.float(0.88, "Responsiveness", minval = 0.00, maxval = 2.00, step = 0.01, tooltip = "Responsiveness at EMA lengths up to 50. It is reduced gradually for longer EMA lengths to control overshoot.")
float responsivenessDecayInput = input.float(0.15, "Responsiveness Length Decay", minval = 0.00, maxval = 1.00, step = 0.01, tooltip = "Controls how strongly responsiveness decreases above EMA 50. Set to 0 to disable length-based scaling.")
int   wmaLenInput  = input.int(12, "WMA Smooth Length", 1)
int   emaLenInput  = input.int(20, "EMA Smooth Length", 1)

if fastLenInput >= slowLenInput
    runtime.error("Fast Length must be lower than Slow Length.")

// 1. Adapt between the slow and fast EMAs using Kaufman's Efficiency Ratio.
float priceChange = math.abs(sourceInput - sourceInput[erLenInput])
float volatility = ta.sma(math.abs(ta.change(sourceInput)), erLenInput) * erLenInput
float efficiencyRatio = volatility == 0.0 ? 0.0 : priceChange / volatility
float fastEma = ta.ema(sourceInput, fastLenInput)
float slowEma = ta.ema(sourceInput, slowLenInput)
float adaptiveMa = slowEma + efficiencyRatio * (fastEma - slowEma)

// 2. Apply WMA and EMA smoothing, then lag reduction.
float wmaBase = ta.wma(adaptiveMa, wmaLenInput)
float smoothed = ta.ema(wmaBase, emaLenInput)
float responsivenessScale = math.pow(math.min(1.0, 50.0 / emaLenInput), responsivenessDecayInput)
float effectiveResponsiveness = responsivenessInput * responsivenessScale
float erama = smoothed + effectiveResponsiveness * (smoothed - ta.ema(smoothed, emaLenInput))

// Plot
plot(erama, "ERAMA", color = color.aqua, linewidth = 1)
````
