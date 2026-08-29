<!-- tradingview-pine-id: PUB;e201b0dce939408d99faaed6c4b3e358 -->
<!-- tradingviewscripts-format: 1 -->
# TradingFlow: VCMA Trend (VCT) v1.0.0

Source: https://www.tradingview.com/script/8zJGL9ge-TF-VCMA-Trend-VCT/

## Description

TradingFlow: VCMA Trend (VCT)

TradingFlow: VCMA Trend (VCT) is a trend-visualization indicator built on the [Vector Coherence Moving Average](https://www.tradingview.com/script/vD9FawwE-Vector-Coherence-Moving-Average-VCMA/) (VCMA). It changes speed according to the directional consistency of recent price movement, then adds a confirmed low-coherence state, two display modes, and optional low-coherence visuals. The default Dual VCMA Lines mode shows separate Fast and Slow averages, while VCMA Trend Line mode presents one adaptive line with slope colors.

The purpose of VCMA Trend is to make the adaptive line easier to use as trend context without giving every price shock the same importance as a sustained move. When recent vectors point in a consistent direction and several price changes contribute to that result, the VCMA core becomes more responsive. When the path is irregular, oscillatory, or dominated by too little supporting movement, it slows down. A final WMA softens residual movement before the trend visuals are applied.

How the VCMA Core Is Calculated

1. Delay-Coordinate Price Path
VCMA begins with the bar-to-bar change in the selected Source:

d(t) = Source(t) - Source(t-1)

It then represents price as a point on a two-dimensional delay-coordinate path:

X(t) = [Source(t), Source(t-1)]

Moving from X(t-1) to X(t) creates the lag vector:

z(t) = X(t) - X(t-1) = [d(t), d(t-1)]
Magnitude(t) = sqrt[d(t)^2 + d(t-1)^2]

This representation contains information about both the current price increment and the immediately preceding increment. Persistent movement tends to produce vectors pointing in a similar direction. Back-and-forth movement produces vectors whose directions disagree and cancel when added together.

2. Vector Coherence
Over the selected Coherence Length, VCMA compares the straight-line displacement of this path with the total distance it traveled. Equivalently, it compares the length of the summed vector with the sum of all individual vector lengths:

Sum Vector = [Sum d(t), Sum d(t-1)]
Vector Coherence (rho) = Length of Sum Vector / Sum Magnitude(t)

In expanded form:

rho = sqrt[(Sum d(t))^2 + (Sum d(t-1))^2] / Sum sqrt[d(t)^2 + d(t-1)^2]

In this form, rho is a two-dimensional path-efficiency, or straightness, ratio.

The triangle inequality keeps rho between 0 and 1. A reading near 1 means the lag vectors are strongly aligned. A reading near 0 means their directions largely cancel. Because both parts of the ratio scale with price movement, the measurement is scale-free and can be used across instruments with different price levels.

3. Effective-Move Support
A coherence ratio alone can become high after one isolated jump because a single large vector has nothing opposing it. VCMA addresses this with an effective-move calculation based on vector magnitudes:

Effective Moves = (Sum Magnitude)^2 / Sum Magnitude^2

This is an effective sample-size measure, not a literal count of bars. It is low when one move dominates the window and increases when several moves make meaningful contributions.

Support = Clamp[(Effective Moves - 1) / (Move Target - 1), 0, 1]

The Effective Moves for Full Speed setting controls the target. With the default value of 3, one dominant move receives little support, while a direction backed by several contributing moves can use the full coherence signal. This reduces the tendency to jump immediately to maximum speed after an isolated gap or wick.

4. Coherence-Adaptive Smoothing
The Fast and Slow periods define VCMA's fastest and slowest available EMA-style responses. If the inputs are reversed, the script automatically treats the shorter period as Fast and the longer period as Slow:

Fast Alpha = 2 / (Fast Period + 1)
Slow Alpha = 2 / (Slow Period + 1)

Speed Gate = rho^Coherence Power x Support
Adaptive Alpha = Slow Alpha + (Fast Alpha - Slow Alpha) x Speed Gate

Raw VCMA = Previous Raw VCMA + Adaptive Alpha x (Source - Previous Raw VCMA)

When vector coherence and support are high, Adaptive Alpha moves toward Fast Alpha. When either component is weak, it remains closer to Slow Alpha. Coherence Power controls how demanding this transition is. Higher values reserve fast responses for stronger coherence.

5. Final Output Smoothing
VCMA applies a weighted moving average to the raw adaptive line:

VCMA = WMA(Raw VCMA, Output WMA Length)

The default 3-period WMA gives more weight to recent values and removes small residual turns with modest added lag. Set Output WMA Length to 1 to use the unsmoothed adaptive output.

6. Low-Coherence State
The chart state uses a supported coherence score:

Coherence Score = rho x Support

The main VCMA enters its low-coherence state when this score falls below the Low-Coherence Threshold. It leaves only after the score rises above Threshold x Exit Multiplier. This hysteresis reduces rapid switching near the boundary. State changes occur on confirmed bars.

This state is always calculated from the main VCMA coherence score, including when Dual VCMA Lines is selected. It controls the optional gray Trend Line color, the gray fill between the Dual VCMA Lines, and background shading in either mode.

The low-coherence state describes the structure of recent price movement. It does not simply mean that a plotted line has zero slope. When gray coloring is enabled, a gray VCMA can still drift while the underlying vector evidence remains weak.

The Mathematical Idea Behind the VCMA Core

VCMA introduces a distinctive adaptive-moving-average construction that extends one-dimensional price-path efficiency into a two-dimensional delay-coordinate path and adds an effective-move gate to reduce acceleration caused by isolated shocks.

The delayed price points X(t) = [Source(t), Source(t-1)] form a path whose steps are the vectors [d(t), d(t-1)]. The coherence ratio is the path's net displacement divided by its total traveled distance. It therefore measures how straight and directionally consistent the recent delayed path has been. Unlike a one-dimensional ratio, it can also respond to irregular relationships between adjacent price changes, even when those changes share the same sign.

The second part of the design is the effective-move support gate. Vector alignment answers, "Do the recent moves point together?" Effective-move support asks, "Is that alignment backed by several meaningful moves, or mostly by one event?" Alpha accelerates only when both tests provide support.

This produces a causal and bounded adaptive core. Alpha remains between the selected Slow and Fast values, while the final WMA uses positive weights and does not introduce projection-based overshoot. VCMA is still a moving average and therefore retains lag; the goal is to allocate that lag according to the quality of the observed path.

Why Use VCT?

VCMA Trend is designed for traders who want the VCMA mathematics combined with direct chart interpretation. Its practical characteristics include:
• Scale-free measurement of directional vector alignment
• Adaptive speed bounded by interpretable Fast and Slow periods
• Reduced maximum-speed reactions to isolated price shocks
• Smoother output through a short final WMA
• Confirmed low-coherence states with hysteresis
• VCMA Trend Line and Dual VCMA Lines display modes
• Optional low-coherence line color, dual-line fill, and background shading

How to Read VCT

VCMA Trend Line
This mode displays the main VCMA with colors derived from slope and, optionally, its confirmed low-coherence state.

Green Line - Rising VCT
In VCMA Trend Line mode, green means the smoothed VCMA is rising and is not currently in its low-coherence state. Price holding above a rising green VCMA supports a bullish trend interpretation. Pullbacks toward the line may provide an adaptive reference when price structure remains constructive.

Red Line - Falling VCT
Red means the smoothed VCMA is falling and is not currently in its low-coherence state. Price holding below a falling red VCMA supports a bearish trend interpretation. Rallies toward the line may help frame bearish continuation when market structure agrees.

Gray Line - Low Vector Coherence
When Gray Trend Line in Low-Coherence Regimes is enabled, gray means supported vector coherence is below the active threshold. This commonly appears during sideways movement, irregular transitions, compression, or periods where a recent move lacks broader participation. Gray is a warning that directional evidence is weak; it is not automatically a reversal signal.

Slope, Price Position, and Distance
A steeper VCMA indicates that its adaptive baseline is changing more quickly. A flattening line suggests that directional progress is weakening. Price staying on one side of a consistently sloped VCMA is more informative than a single touch or crossover.

A rapidly widening distance between price and VCMA can reflect strong momentum, but it can also indicate extension from the adaptive baseline. Repeated crossings usually point to unsettled or range-bound conditions.

Price Crossings as Entry and Exit References
During an established trend, a confirmed crossing between price and the VCMA Trend Line, or between price and the Fast VCMA in Dual VCMA Lines mode, can provide a rule-based entry or exit reference. In a rising trend, price reclaiming the line after a pullback can mark an entry or re-entry, while a confirmed cross below it can mark a reduction or exit. In a falling trend, the interpretation is reversed: price falling back below the line after a rally can mark an entry or re-entry, while a confirmed cross above it can mark a reduction or exit.

Dual VCMA Lines
This mode replaces the color-changing Trend Line with two clean reference lines:
• Cyan - Fast VCMA
• Orange - Slow VCMA

Fast VCMA above Slow VCMA indicates that the shorter adaptive structure is leading the longer one. Fast below Slow indicates the opposite. Expanding separation suggests strengthening directional structure; convergence suggests that the difference between short- and longer-horizon estimates is narrowing. Crossovers mark a change in their relative ordering, not a complete trade signal by themselves.

When Fill Between Dual Lines in Low-Coherence Regimes is enabled, a light transparent gray fill appears between the two lines during the confirmed low-coherence state. The fill is based on the main VCMA coherence score, not on a separate low-coherence calculation for the Fast or Slow line.

Data Window Diagnostics

VCMA Trend exposes four values from its underlying VCMA core in TradingView's Data Window:
• VCMA Coherence Score - raw coherence multiplied by effective-move support
• VCMA Raw Vector Coherence - vector alignment before the support gate
• VCMA Effective-Move Support - how broadly recent vector magnitude is distributed
• VCMA Adaptive Alpha - the smoothing coefficient used by the raw VCMA core

These values help explain why the adaptive core is moving quickly, slowly, or entering its low-coherence state. For example, high raw coherence with low support often means that one dominant move has not yet received enough confirmation from other moves.

Understanding the Settings

Mode
Selects Dual VCMA Lines or VCMA Trend Line. The default is Dual VCMA Lines.

Low-Coherence Display Options
• Fill Between Dual Lines in Low-Coherence Regimes - enabled by default and visible only in Dual VCMA Lines mode
• Gray Trend Line in Low-Coherence Regimes - enabled by default and visible only in VCMA Trend Line mode
• Shade Background in Low-Coherence Regimes - disabled by default and available in either mode

All three options use the same confirmed low-coherence state derived from the main VCMA coherence score.

Source
Selects the price series used by all VCMA calculations. The default is Close.

Coherence Length
The Coherence Length under VCMA Trend Line controls the main VCMA and the low-coherence state used by all display options. Shorter values respond more quickly to changes in vector alignment. Longer values evaluate the path over a broader sample and usually change more gradually. Fast VCMA and Slow VCMA have separate Coherence Length settings under Dual VCMA Lines.

Fast Period and Slow Period
Define the fastest and slowest EMA-style responses available to the adaptive core. Shorter Fast values increase maximum responsiveness. Longer Slow values make VCMA more conservative when coherence or support is weak.

Coherence Power
Shapes how raw coherence affects speed. Higher values suppress medium coherence more strongly and require rho to move closer to 1 before alpha accelerates substantially. Lower values create a softer and earlier response.

Effective Moves for Full Speed
Controls how much participation is required before the support gate reaches 1. Higher values demand broader support and reject isolated movement more strongly, but they can delay acceleration at the beginning of a genuine trend.

Output WMA Length
Controls final line smoothing. Higher values create a steadier line with more lag. A value of 1 disables this stage.

Low-Coherence Threshold and Exit Multiplier
The threshold determines when the main VCMA enters its low-coherence state. The multiplier sets the higher level required to leave it. A larger gap between the entry and exit levels produces more stable but slower regime transitions.

Alerts

VCMA Trend Line mode provides confirmed-bar alerts for VCT turning up, turning down, entering low coherence, and leaving low coherence. Dual VCMA Lines mode is intended as a visual fast/slow framework and does not issue those main-line alerts.

Practical Use

VCMA Trend can be used as a directional-bias filter, an adaptive pullback reference, a trend-management baseline, or a way to separate coherent movement from less organized price action. It is most useful when read together with price structure, support and resistance, volatility, volume, and higher-timeframe context.

---

TradingFlow：VCMA Trend (VCT)

TradingFlow：VCMA Trend (VCT) 是以向量一致性移動平均線 ([VCMA](https://www.tradingview.com/script/vD9FawwE-Vector-Coherence-Moving-Average-VCMA/)) 為核心的趨勢視覺指標。它會根據近期價格移動的方向一致性調整反應速度，再加入經確認的低一致性狀態、兩種顯示模式，以及可選的低一致性視覺效果。預設的 Dual VCMA Lines 模式會顯示獨立的 Fast 與 Slow 平均線；VCMA Trend Line 模式則以斜率顏色顯示一條自適應線。

VCMA Trend 的用途，是把自適應數學轉化成較容易閱讀的趨勢背景，同時避免把單一價格衝擊誤當成已獲持續支持的走勢。當近期向量方向一致，而且有多個價格變化共同支持該結果時，VCMA 核心會提高反應速度；當路徑反覆、雜亂，或主要由少數變化主導時，它會放慢。最後一層 WMA 先整理細微波動，然後才套用趨勢視覺。

VCMA 核心如何計算

1. 延遲座標價格路徑
VCMA 先計算所選 Source 每根 K 線的價格變化：

d(t) = Source(t) - Source(t-1)

然後把價格表示為二維延遲座標路徑上的一個點：

X(t) = [Source(t), Source(t-1)]

由 X(t-1) 移動至 X(t) 時，便會形成滯後向量：

z(t) = X(t) - X(t-1) = [d(t), d(t-1)]
Magnitude(t) = sqrt[d(t)^2 + d(t-1)^2]

持續的方向移動通常會產生方向相近的向量。來回震盪時，向量方向互相矛盾，相加後便會抵消。

2. 向量一致性
在 Coherence Length 所設定的週期內，VCMA 比較這條路徑的直線位移與實際行走總距離。等價地說，就是比較「向量總和的長度」與「所有個別向量長度的總和」：

Sum Vector = [Sum d(t), Sum d(t-1)]
Vector Coherence（rho）= Sum Vector 的長度 / Sum Magnitude(t)

完整公式為：

rho = sqrt[(Sum d(t))^2 + (Sum d(t-1))^2] / Sum sqrt[d(t)^2 + d(t-1)^2]

以這種形式理解，rho 就是二維路徑效率，亦即路徑直線度的比率。

根據三角不等式，rho 會保持在 0 至 1 之間。接近 1 表示滯後向量大致朝向相同方向；接近 0 表示它們大部分互相抵消。分子與分母都會隨價格變化幅度按比例改變，因此這個比率不受商品價格尺度影響。

3. 有效移動支持度
單靠一致性比率仍有一個問題：如果視窗內只有一次孤立的大幅移動，由於沒有其他向量與它抵消，rho 也可能偏高。VCMA 使用向量幅度計算有效移動數，以減少這種情況：

Effective Moves = (Sum Magnitude)^2 / Sum Magnitude^2

這是有效樣本數的概念，不是 K 線數量的直接計數。當一個移動佔據大部分向量幅度時，數值會偏低；當多個移動都有實質貢獻時，數值便會上升。

Support = Clamp[(Effective Moves - 1) / (Move Target - 1), 0, 1]

Effective Moves for Full Speed 設定支持度達到 1 所需的目標。預設值為 3，因此單一主導移動只會得到有限支持；當同一方向獲得多個價格變化配合後，完整的一致性訊號才會投入速度計算。這可減少 VCMA 因單一裂口或影線而立即切換至最高速度的情況。

4. 一致性自適應平滑
Fast 與 Slow 週期定義 VCMA 可使用的最快及最慢 EMA 式反應。即使輸入次序相反，程式仍會把較短週期視為 Fast，較長週期視為 Slow：

Fast Alpha = 2 / (Fast Period + 1)
Slow Alpha = 2 / (Slow Period + 1)

Speed Gate = rho^Coherence Power x Support
Adaptive Alpha = Slow Alpha + (Fast Alpha - Slow Alpha) x Speed Gate

Raw VCMA = Previous Raw VCMA + Adaptive Alpha x (Source - Previous Raw VCMA)

當向量一致性與支持度同時偏高，Adaptive Alpha 會接近 Fast Alpha；任何一項偏弱，Alpha 便會靠近 Slow Alpha。Coherence Power 控制速度轉換的要求。數值越高，VCMA 越需要接近完整一致性才會明顯加速。

5. 最終輸出平滑
VCMA 會對原始自適應線套用一層加權移動平均：

VCMA = WMA(Raw VCMA, Output WMA Length)

預設的 3 週期 WMA 對近期數值給予較高權重，可減少細微轉折，同時只增加有限延遲。把 Output WMA Length 設為 1，即可停用這層平滑。

6. 低一致性狀態
圖表狀態使用經支持度調整的一致性分數：

Coherence Score = rho x Support

當分數低於 Low-Coherence Threshold，主 VCMA 會進入低一致性狀態。分數其後必須升穿 Threshold x Exit Multiplier，低一致性狀態才會結束。兩個不同門檻形成遲滯，可減少狀態在邊界附近反覆切換。狀態只會在 K 線確認後更新。

即使選擇 Dual VCMA Lines，這個狀態仍然由主 VCMA 的一致性分數計算。它會控制可選的 Trend Line 灰色顯示、Dual VCMA Lines 之間的灰色填充，以及兩種模式都可使用的背景陰影。

低一致性描述的是近期價格路徑結構，不等於圖表線條的斜率必須為零。啟用灰色顯示後，灰色 VCMA 仍可能緩慢上升或下降，但其背後的向量證據仍然偏弱。

VCMA 核心的數學設計

VCMA 採用一種具辨識度的自適應移動平均線結構：把一維價格路徑效率延伸為二維延遲座標路徑，並加入有效移動閘門，以降低孤立價格衝擊造成的加速。

延遲價格點 X(t) = [Source(t), Source(t-1)] 形成一條路徑，而 [d(t), d(t-1)] 就是路徑上的每一步。向量一致性比率等於路徑的淨位移除以實際行走總距離，因此可衡量近期延遲路徑有多筆直，以及方向有多一致。與一維比率不同，即使價格變化方向相同，若相鄰變化之間的關係反覆而不規則，這個二維比率仍可作出區分。

第二部分是有效移動支持閘門。向量一致性回答「近期移動是否大致朝向同一方向」；有效移動支持度則判斷「這個結果是否有多個具實質幅度的移動支持，還是主要來自單一事件」。只有兩項條件同時成立，Alpha 才會明顯提高。

這個自適應核心只使用當前及過往資料，而且 Alpha 保持在所選的 Slow 與 Fast 範圍內。最後的 WMA 只使用正權重，不會加入價格投射造成的過衝。VCMA 仍然是移動平均線，因此一定存在延遲；它的目標是根據已觀察到的路徑品質分配反應速度。

為何使用 VCT？

VCMA Trend 適合希望把 VCMA 數學與直接圖表判讀結合的交易者。它有以下實用特點：
• 以不受價格尺度影響的比率衡量向量方向一致性
• 反應速度受具體的 Fast 與 Slow 週期限制
• 降低單一價格衝擊觸發最高速度的機會
• 使用短週期 WMA 整理最終輸出
• 以確認 K 線及遲滯機制管理低一致性狀態
• 提供 VCMA Trend Line 與 Dual VCMA Lines 兩種顯示模式
• 可選用低一致性線條顏色、雙線填充及背景陰影

如何閱讀 VCT

VCMA Trend Line
此模式會顯示主 VCMA，線條顏色由斜率及可選的經確認低一致性狀態決定。

綠線 - VCT 上升
在 VCMA Trend Line 模式下，綠色表示平滑後的 VCMA 正在上升，而且目前不處於低一致性狀態。價格維持在上升綠線之上，可支持多頭趨勢判斷。若價格結構仍然穩健，回調至 VCMA 附近可作為觀察趨勢延續的自適應參考。

紅線 - VCT 下跌
紅色表示平滑後的 VCMA 正在下降，而且目前不處於低一致性狀態。價格維持在下降紅線之下，可支持空頭趨勢判斷。若市場結構同樣偏弱，反彈至 VCMA 附近可作為觀察空頭延續的參考。

灰線 - 向量一致性偏低
啟用 Gray Trend Line in Low-Coherence Regimes 後，灰色表示經支持度調整的向量一致性低於有效門檻。這種情況常見於橫行、方向轉換、波幅壓縮，或近期移動尚未得到較廣泛支持的階段。灰色代表方向證據偏弱，並不等於趨勢必然反轉。

斜率、價格位置與距離
VCMA 越陡，表示自適應基準變化越快；線條逐漸走平，則代表方向進展正在減弱。相比一次觸碰或穿越，價格持續位於有明確斜率的 VCMA 同一側更具參考價值。

價格與 VCMA 的距離快速擴大，可能反映動能增強，也可能表示價格已偏離自適應基準。價格反覆穿越 VCMA，通常代表市況仍然反覆或缺乏穩定方向。

價格交叉作為進出場依據
在趨勢已建立時，價格與 VCMA Trend Line 的確認交叉，或在 Dual VCMA Lines 模式下價格與 Fast VCMA 的確認交叉，可作為規則化的進出場依據。在上升趨勢中，價格回調後重新升穿線條，可視為入場或重新入場參考；確認跌穿線條，則可作為減倉或離場依據。在下跌趨勢中，邏輯相反：價格反彈後重新跌穿線條，可作為入場或重新入場參考；確認升穿線條，則可作為減倉或離場依據。

Dual VCMA Lines
此模式會以兩條固定顏色的參考線取代會轉色的 Trend Line：
• 青色 - Fast VCMA
• 橙色 - Slow VCMA

Fast VCMA 位於 Slow VCMA 之上，表示較短期的自適應結構領先較長期結構；Fast 位於 Slow 之下則相反。兩線距離擴大，代表短期與較長期估算的方向差異正在增強；兩線收窄，代表差異正在減少。交叉只表示兩者的相對次序改變，不能單獨視為完整交易訊號。

啟用 Fill Between Dual Lines in Low-Coherence Regimes 後，在經確認的低一致性狀態期間，兩線之間會出現淺灰色半透明填充。填充以主 VCMA 的一致性分數為基礎，不會分別根據 Fast 或 Slow 線計算低一致性狀態。

Data Window 診斷數值

VCMA Trend 在 TradingView 的 Data Window 提供四項底層 VCMA 核心數值：
• VCMA Coherence Score - 原始一致性乘以有效移動支持度
• VCMA Raw Vector Coherence - 未加入支持閘門前的向量一致性
• VCMA Effective-Move Support - 近期向量幅度的分布廣度
• VCMA Adaptive Alpha - 原始 VCMA 核心實際使用的平滑係數

這些數值可解釋自適應核心為何加快、減慢或進入低一致性狀態。例如，Raw Vector Coherence 偏高但 Support 偏低，通常代表一次主導移動尚未獲得其他移動充分配合。

設定說明

Mode
選擇 Dual VCMA Lines 或 VCMA Trend Line。預設為 Dual VCMA Lines。

低一致性顯示選項
• Fill Between Dual Lines in Low-Coherence Regimes - 預設啟用，只會在 Dual VCMA Lines 模式顯示
• Gray Trend Line in Low-Coherence Regimes - 預設啟用，只會在 VCMA Trend Line 模式顯示
• Shade Background in Low-Coherence Regimes - 預設停用，兩種模式都可使用

三個選項均使用主 VCMA 一致性分數所產生的同一個經確認低一致性狀態。

Source
選擇所有 VCMA 計算使用的價格序列，預設為 Close。

Coherence Length
VCMA Trend Line 下的 Coherence Length 會控制主 VCMA，以及所有顯示選項使用的低一致性狀態。較短數值能更快反映向量方向變化；較長數值會在較廣的樣本內評估價格路徑，變化通常較慢。Fast VCMA 與 Slow VCMA 在 Dual VCMA Lines 下各有獨立的 Coherence Length 設定。

Fast Period 與 Slow Period
定義自適應核心可使用的最快及最慢 EMA 式反應。較短的 Fast Period 會提高最大靈敏度；較長的 Slow Period 則會在一致性或支持度偏弱時令 VCMA 更保守。

Coherence Power
控制原始一致性如何影響速度。較高數值會更強地壓低中等一致性的作用，要求 rho 更接近 1 才明顯加速；較低數值則會較早及較平順地提高反應速度。

Effective Moves for Full Speed
控制支持度達到 1 所需的參與程度。較高數值要求更廣泛支持，能更強地抑制孤立移動，但也可能延遲真實趨勢初段的加速。

Output WMA Length
控制最終線條的平滑程度。數值越高，線條越穩定，但延遲亦會增加。設為 1 可停用這一層。

Low-Coherence Threshold 與 Exit Multiplier
Threshold 決定主 VCMA 何時進入低一致性狀態；Multiplier 設定離開該狀態所需的較高門檻。進出門檻距離越大，狀態越穩定，但轉換也會較慢。

警報功能

VCMA Trend Line 模式提供 K 線確認後的警報，包括 VCT 轉為上升、轉為下降、進入低一致性，以及離開低一致性。Dual VCMA Lines 模式主要用作快慢線視覺框架，不會發出上述主線警報。

實際應用

VCMA Trend 可作為方向偏向過濾器、自適應回調參考、趨勢管理基準，亦可協助區分方向一致的走勢與較欠組織的價格行為。使用時可配合價格結構、支撐阻力、波動性、成交量及較高時間週期背景。

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © realanthonyc https://www.tradingview.com/u/realanthonyc

//@version=6
// ------------------------------------------------------------------------------
//  TradingFlow: VCMA Trend (VCT)
// ------------------------------------------------------------------------------
indicator("TradingFlow: VCMA Trend (VCT) v1.0.0", shorttitle = "TF: VCT", overlay = true, max_bars_back = 1000)

// ------------------------------------
// Inputs
// ------------------------------------

const string DISPLAY_GROUP = "Display"
const string MAIN_GROUP = "VCMA Trend Line"
const string DUAL_GROUP = "Dual VCMA Lines"
const string FILTER_GROUP = "Coherence Filter"
const string LOW_COHERENCE_GROUP = "Low-Coherence"

string mode = input.string("Dual VCMA Lines", "Mode", options = ["Dual VCMA Lines", "VCMA Trend Line"], group = DISPLAY_GROUP)
bool showLowCoherenceFill = input.bool(true, "Fill Between Dual Lines in Low-Coherence Regimes", group = DISPLAY_GROUP)
bool colorByRho = input.bool(true, "Gray Trend Line in Low-Coherence Regimes", group = DISPLAY_GROUP)
bool showBg     = input.bool(false, "Shade Background in Low-Coherence Regimes", group = DISPLAY_GROUP)

bool showDual = mode == "Dual VCMA Lines"

float src       = input.source(close, "Source", group = MAIN_GROUP)
int length      = input.int(14, "Coherence Length", minval = 2, maxval = 500, group = MAIN_GROUP)
int fastLen     = input.int(3, "Fast Period", minval = 1, maxval = 500, group = MAIN_GROUP, tooltip = "The shorter of the Fast and Slow periods is always treated as fast.")
int slowLen     = input.int(30, "Slow Period", minval = 2, maxval = 500, group = MAIN_GROUP, tooltip = "The longer of the Fast and Slow periods is always treated as slow.")
float gamma     = input.float(2.0, "Coherence Power", minval = 0.5, maxval = 5.0, step = 0.1, group = MAIN_GROUP, tooltip = "Higher values require stronger directional coherence before the average accelerates.")

int minMoves    = input.int(3, "Effective Moves for Full Speed", minval = 2, maxval = 10, group = FILTER_GROUP, tooltip = "Reduces false acceleration from a single price shock. The speed gate reaches full strength after this many effective contributing moves.")
int outputSmoothLen = input.int(3, "Output WMA Length", minval = 1, maxval = 10, group = FILTER_GROUP, tooltip = "Applies a final WMA to the displayed lines. Set to 1 to disable output smoothing.")

int fastLength2 = input.int(12, "Fast VCMA - Coherence Length", minval = 2, maxval = 500, group = DUAL_GROUP)
int fastFast    = input.int(2, "Fast VCMA - Fast Period", minval = 1, maxval = 500, group = DUAL_GROUP)
int fastSlow    = input.int(20, "Fast VCMA - Slow Period", minval = 2, maxval = 500, group = DUAL_GROUP)
float fastGamma = input.float(1.8, "Fast VCMA - Coherence Power", minval = 0.5, maxval = 5.0, step = 0.1, group = DUAL_GROUP)

int slowLength2 = input.int(18, "Slow VCMA - Coherence Length", minval = 2, maxval = 500, group = DUAL_GROUP)
int slowFast    = input.int(5, "Slow VCMA - Fast Period", minval = 1, maxval = 500, group = DUAL_GROUP)
int slowSlow    = input.int(50, "Slow VCMA - Slow Period", minval = 2, maxval = 500, group = DUAL_GROUP)
float slowGamma = input.float(2.2, "Slow VCMA - Coherence Power", minval = 0.5, maxval = 5.0, step = 0.1, group = DUAL_GROUP)

float flatThresh = input.float(0.100, "Low-Coherence Threshold", minval = 0.005, maxval = 0.600, step = 0.005, group = LOW_COHERENCE_GROUP)
float exitMult   = input.float(1.125, "Low-Coherence Exit Multiplier", minval = 1.000, maxval = 3.000, step = 0.005, group = LOW_COHERENCE_GROUP, tooltip = "Adds hysteresis: coherence must rise above Threshold × Multiplier before the low-coherence state ends.")

// ------------------------------------
// Core VCMA Function
// ------------------------------------

vcma(float source, int n, int fastPeriodInput, int slowPeriodInput, float power, int moveTargetInput) =>
    // Normalize reversed period inputs so alpha always accelerates with coherence.
    int fastPeriod = math.min(fastPeriodInput, slowPeriodInput)
    int slowPeriod = math.max(fastPeriodInput, slowPeriodInput)
    float alphaFast = 2.0 / (fastPeriod + 1.0)
    float alphaSlow = 2.0 / (slowPeriod + 1.0)

    // Each increment is embedded in a two-dimensional lag plane: z = (ΔP, ΔP[1]).
    // Coherence is the resultant vector length divided by total path length, so it is scale-free and bounded to [0, 1].
    float d = source - source[1]
    float d1 = source[1] - source[2]
    float magnitude = math.sqrt(d * d + d1 * d1)

    float sumX = math.sum(d, n)
    float sumY = math.sum(d1, n)
    float sumMagnitude = math.sum(magnitude, n)
    float sumMagnitudeSq = math.sum(magnitude * magnitude, n)

    bool coherenceReady = not na(sumX) and not na(sumY) and not na(sumMagnitude) and sumMagnitude > 0.0
    float rho = coherenceReady ? math.sqrt(sumX * sumX + sumY * sumY) / sumMagnitude : 0.0
    rho := math.min(math.max(rho, 0.0), 1.0)

    // Effective sample size detects whether coherence comes from several moves or one dominant shock.
    // This preserves normal behavior while reducing false maximum-speed responses to isolated gaps and wicks.
    bool supportReady = not na(sumMagnitude) and not na(sumMagnitudeSq) and sumMagnitudeSq > 0.0
    float effectiveMoves = supportReady ? sumMagnitude * sumMagnitude / sumMagnitudeSq : 0.0
    effectiveMoves := math.min(math.max(effectiveMoves, 0.0), n)
    int moveTarget = math.max(2, math.min(moveTargetInput, n))
    float support = math.min(math.max((effectiveMoves - 1.0) / (moveTarget - 1.0), 0.0), 1.0)

    float coherenceScore = rho * support
    float speedGate = math.pow(rho, power) * support
    float alpha = alphaSlow + (alphaFast - alphaSlow) * speedGate

    var float ma = na
    ma := na(ma[1]) ? source : alpha * source + (1.0 - alpha) * ma[1]

    [ma, coherenceScore, rho, support, alpha]

// ------------------------------------
// Calculations and confirmed regime states
// ------------------------------------

[vcmaMainRaw, scoreMain, rhoMain, supportMain, alphaMain] = vcma(src, length, fastLen, slowLen, gamma, minMoves)
[vcmaFastRaw, _, _, _, _] = vcma(src, fastLength2, fastFast, fastSlow, fastGamma, minMoves)
[vcmaSlowRaw, _, _, _, _] = vcma(src, slowLength2, slowFast, slowSlow, slowGamma, minMoves)

// Smooth only the displayed outputs.
// Coherence and adaptive alpha continue to use the unsmoothed VCMA core.
float vcmaMain = ta.wma(vcmaMainRaw, outputSmoothLen)
float vcmaFast = ta.wma(vcmaFastRaw, outputSmoothLen)
float vcmaSlow = ta.wma(vcmaSlowRaw, outputSmoothLen)

float exitThresh = math.min(flatThresh * exitMult, 1.0)
var bool mainIsFlat = false

if barstate.isconfirmed
    if not mainIsFlat and scoreMain < flatThresh
        mainIsFlat := true
    else if mainIsFlat and scoreMain > exitThresh
        mainIsFlat := false

// ------------------------------------
// Visuals
// ------------------------------------

color colMain = colorByRho and mainIsFlat ? color.new(color.gray, 20) : vcmaMain > vcmaMain[1] ? color.new(#00E676, 0) : color.new(#FF5252, 0)

plot(vcmaMain, "VCT", color = colMain, linewidth = 2, display = showDual ? display.none : display.all)
fastPlot = plot(vcmaFast, "Fast VCMA", color = #00BCD4, linewidth = 2, display = showDual ? display.all : display.none)
slowPlot = plot(vcmaSlow, "Slow VCMA", color = #FF9800, linewidth = 2, display = showDual ? display.all : display.none)

fill(fastPlot, slowPlot, color = showDual and showLowCoherenceFill and mainIsFlat ? color.new(color.gray, 78) : na, title = "Dual VCMA Lines Low-Coherence Fill")

bgcolor(showBg and mainIsFlat ? color.new(color.gray, 92) : na, title = "Low-Coherence Regime")

// Keep diagnostics available without changing the chart scale.
plot(scoreMain, "VCMA Coherence Score", display = display.data_window)
plot(rhoMain, "VCMA Raw Vector Coherence", display = display.data_window)
plot(supportMain, "VCMA Effective-Move Support", display = display.data_window)
plot(alphaMain, "VCMA Adaptive Alpha", display = display.data_window)

// ------------------------------------
// Confirmed alerts (VCMA Trend Line mode)
// ------------------------------------

bool turnedUp = ta.crossover(vcmaMain, vcmaMain[1])
bool turnedDown = ta.crossunder(vcmaMain, vcmaMain[1])
bool enteredFlat = mainIsFlat and not mainIsFlat[1]
bool leftFlat = not mainIsFlat and mainIsFlat[1]

alertcondition(barstate.isconfirmed and not showDual and turnedUp and not mainIsFlat, "VCT Turning Up", "VCT started rising with sufficient coherence")
alertcondition(barstate.isconfirmed and not showDual and turnedDown and not mainIsFlat, "VCT Turning Down", "VCT started falling with sufficient coherence")
alertcondition(barstate.isconfirmed and not showDual and enteredFlat, "Entered Low Coherence", "Market entered a low-coherence regime")
alertcondition(barstate.isconfirmed and not showDual and leftFlat, "Left Low Coherence", "Market left the low-coherence regime - trend may be starting")
````
