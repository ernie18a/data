<!-- tradingview-pine-id: PUB;b69158e328e94d5b8c736296106b97cf -->
<!-- tradingviewscripts-format: 1 -->
# Vector Coherence Moving Average (VCMA)

Source: https://www.tradingview.com/script/vD9FawwE-Vector-Coherence-Moving-Average-VCMA/

## Description

Vector Coherence Moving Average (VCMA)

Vector Coherence Moving Average (VCMA) is an adaptive moving average based on the directional alignment of recent price-change vectors. It is intentionally presented as a thin, fixed-color line.

VCMA adjusts its smoothing speed according to two questions: Are recent price changes pointing in a consistent direction? Is that consistency supported by several meaningful moves rather than one isolated event? Strong, well-supported alignment makes the average more responsive. Weak or poorly supported alignment keeps it closer to its slow response.

How VCMA Is Calculated

1. Delay-Coordinate Price Path
VCMA first calculates the bar-to-bar change in the selected Source:

d(t) = Source(t) - Source(t-1)

It then represents price as a point on a two-dimensional delay-coordinate path:

X(t) = [Source(t), Source(t-1)]

Moving from X(t-1) to X(t) creates the lag vector:

z(t) = X(t) - X(t-1) = [d(t), d(t-1)]
Magnitude(t) = sqrt[d(t)^2 + d(t-1)^2]

During persistent movement, these vectors tend to point in similar directions. During back-and-forth movement, they point in conflicting directions and cancel when summed.

2. Vector Coherence
Over the selected Coherence Length, VCMA compares the straight-line displacement of this path with the total distance it traveled. Equivalently, it compares the length of the summed vector with the sum of all individual vector lengths:

rho = sqrt[(Sum d(t))^2 + (Sum d(t-1))^2] / Sum sqrt[d(t)^2 + d(t-1)^2]

In this form, rho is a two-dimensional path-efficiency, or straightness, ratio.

The triangle inequality keeps rho between 0 and 1:

• rho near 1 - recent lag vectors are strongly aligned
• rho near 0 - vector directions largely cancel

Both parts of the ratio scale with price movement, so vector coherence is independent of the instrument's nominal price level.

3. Effective-Move Support
A single large move can produce high coherence simply because little else opposes it. VCMA therefore calculates an effective sample size from vector magnitudes:

Effective Moves = (Sum Magnitude)^2 / Sum Magnitude^2

This is a participation measure rather than a literal count of bars. It is low when one move dominates and rises when several moves contribute meaningful magnitude.

Support = Clamp[(Effective Moves - 1) / (Move Target - 1), 0, 1]

With the default target of 3, VCMA requires broader support before using the full coherence signal. This reduces immediate maximum-speed reactions to an isolated gap, spike, or wick.

4. Adaptive Alpha
The Fast and Slow periods define the response limits of the recursive average. The script automatically treats the shorter input as Fast and the longer input as Slow:

Fast Alpha = 2 / (Fast Period + 1)
Slow Alpha = 2 / (Slow Period + 1)

Speed Gate = rho^Coherence Power x Support
Adaptive Alpha = Slow Alpha + (Fast Alpha - Slow Alpha) x Speed Gate

Raw VCMA = Previous Raw VCMA + Adaptive Alpha x (Source - Previous Raw VCMA)

Alpha always remains between the selected Slow and Fast values. Coherence Power shapes the transition: higher values require rho to move closer to 1 before VCMA accelerates substantially.

5. Output WMA
The displayed line is a weighted moving average of the raw adaptive result:

VCMA = WMA(Raw VCMA, Output WMA Length)

The default 3-period WMA reduces small residual turns while adding only modest lag. Set the length to 1 to display the unsmoothed adaptive core.

The Mathematical Idea

VCMA introduces a distinctive adaptive-moving-average construction that extends one-dimensional price-path efficiency into a two-dimensional delay-coordinate path and adds an effective-move gate to reduce acceleration caused by isolated shocks.

The delayed price points X(t) = [Source(t), Source(t-1)] form a path whose steps are the vectors [d(t), d(t-1)]. The coherence ratio is the path's net displacement divided by its total traveled distance. It therefore measures how straight and directionally consistent the recent delayed path has been. Unlike a one-dimensional ratio, it can also respond to irregular relationships between adjacent price changes, even when those changes share the same sign.

The effective-move gate adds an additional test for concentration. Vector coherence measures directional agreement; effective-move support measures whether that agreement is distributed across enough movement. VCMA accelerates only when both conditions support the change.

This gives VCMA a causal, scale-free, and bounded adaptive core. It does not project price forward, and the final WMA uses only positive weights. Like every moving average, VCMA still has lag. Its purpose is to vary that lag according to the observed structure of the price path.

Characteristics and Advantages

• Clean fixed-color presentation with no embedded trend classification
• Scale-free vector-coherence measurement
• Bounded response between interpretable Fast and Slow periods
• Reduced sensitivity to isolated high-coherence shocks
• Adjustable nonlinear response through Coherence Power
• Optional short WMA for a steadier final line
• Internal diagnostics available in TradingView's Data Window

How to Read VCMA

VCMA uses one fixed color; color carries no directional or regime meaning. Read the line through its slope, its position relative to price, and the way price behaves around it.

Slope
A rising VCMA indicates that the adaptive baseline is moving higher. A falling VCMA indicates that it is moving lower. A flattening line suggests that recent directional progress is weakening or becoming less consistent.

Price Position
Price holding above a rising VCMA supports a bullish trend interpretation. Price holding below a falling VCMA supports a bearish interpretation. The combination of price position and slope is more informative than either observation alone.

Distance and Crossings
A widening distance between price and VCMA can reflect strong momentum, but it may also indicate extension from the adaptive baseline. Pullbacks toward VCMA can provide trend context when market structure remains intact. Repeated crossings usually indicate unsettled or range-bound movement where a moving-average baseline has less value.

Data Window Diagnostics

• VCMA Coherence Score - raw vector coherence multiplied by move support
• VCMA Raw Vector Coherence - directional alignment before the support gate
• VCMA Effective-Move Support - how broadly vector magnitude is distributed
• VCMA Adaptive Alpha - the smoothing coefficient used by the raw core

High raw coherence with low support often means that one dominant event has not yet received enough support from other moves. High coherence and high support allow alpha to move toward its Fast limit.

Understanding the Settings

Source
Selects the price series used by VCMA. The default is Close.

Coherence Length
Controls the window used to measure vector alignment. Shorter values adapt sooner; longer values evaluate a broader path and usually change more gradually.

Fast Period and Slow Period
Define the fastest and slowest possible responses. A shorter Fast Period increases maximum responsiveness. A longer Slow Period makes VCMA more conservative when coherence or support is weak.

Coherence Power
Higher values suppress medium coherence more strongly and reserve fast responses for readings closer to 1. Lower values produce a softer, earlier acceleration.

Effective Moves for Full Speed
Sets how much distributed movement is required for full support. Higher values reject isolated movement more strongly but may delay acceleration at the beginning of a genuine trend.

Output WMA Length
Controls final smoothing. Higher values produce a steadier line with more lag. A value of 1 disables this stage.

Practical Use

VCMA can serve as an adaptive trend baseline, a pullback reference, a directional filter, or a mathematical building block beside other indicators. Its minimal presentation is useful when the trader wants to interpret the average directly rather than rely on built-in state colors or crossover logic.

VCMA does not predict future price or eliminate whipsaws. Settings should be matched to the instrument, timeframe, and intended holding period, with price structure, volatility, volume, and higher-timeframe context used as additional evidence.

---

Vector Coherence Moving Average (VCMA)

Vector Coherence Moving Average (向量一致性移動平均線) 是以近期價格變化向量之方向一致性為基礎的自適應移動平均線。它刻意保持簡潔，使用固定顏色的細線。

VCMA 會根據兩個問題調整平滑速度：近期價格變化是否朝向一致方向？這種一致性是否得到多個具實質幅度的移動支持，而不是只來自單一事件？方向一致而且支持充分時，VCMA 會提高反應速度；任何一項偏弱，反應便會靠近 Slow 設定。

VCMA 如何計算

1. 延遲座標價格路徑
VCMA 先計算所選 Source 每根 K 線的價格變化：

d(t) = Source(t) - Source(t-1)

然後把價格表示為二維延遲座標路徑上的一個點：

X(t) = [Source(t), Source(t-1)]

由 X(t-1) 移動至 X(t) 時，便會形成滯後向量：

z(t) = X(t) - X(t-1) = [d(t), d(t-1)]
Magnitude(t) = sqrt[d(t)^2 + d(t-1)^2]

方向持續時，這些向量通常朝向相近方向；價格來回移動時，向量方向互相矛盾，加總後便會抵消。

2. 向量一致性
在 Coherence Length 所設定的週期內，VCMA 比較這條路徑的直線位移與實際行走總距離。等價地說，就是比較「向量總和的長度」與「所有個別向量長度的總和」：

rho = sqrt[(Sum d(t))^2 + (Sum d(t-1))^2] / Sum sqrt[d(t)^2 + d(t-1)^2]

以這種形式理解，rho 就是二維路徑效率，亦即路徑直線度的比率。

根據三角不等式，rho 會保持在 0 至 1 之間：

• rho 接近 1 - 近期滯後向量方向高度一致
• rho 接近 0 - 向量方向大部分互相抵消

分子與分母都會隨價格變化幅度按比例改變，因此向量一致性不受商品名義價格水平影響。

3. 有效移動支持度
單一大幅移動也可能產生偏高的一致性，因為沒有其他向量與它抵消。VCMA 因此利用向量幅度計算有效樣本數：

Effective Moves = (Sum Magnitude)^2 / Sum Magnitude^2

這是參與程度的量度，不是 K 線數量的直接計數。當一個移動佔據大部分幅度時，數值偏低；當多個移動都有實質貢獻時，數值便會上升。

Support = Clamp[(Effective Moves - 1) / (Move Target - 1), 0, 1]

預設目標為 3，VCMA 需要較廣泛的支持才會完整採用一致性訊號。這可減少單一裂口、急升急跌或影線令平均線立即切換至最高速度的情況。

4. 自適應 Alpha
Fast 與 Slow 週期定義遞迴平均線的反應上下限。程式會自動把較短輸入視為 Fast，較長輸入視為 Slow：

Fast Alpha = 2 / (Fast Period + 1)
Slow Alpha = 2 / (Slow Period + 1)

Speed Gate = rho^Coherence Power x Support
Adaptive Alpha = Slow Alpha + (Fast Alpha - Slow Alpha) x Speed Gate

Raw VCMA = Previous Raw VCMA + Adaptive Alpha x (Source - Previous Raw VCMA)

Alpha 始終保持在所選的 Slow 與 Fast 數值之間。Coherence Power 控制轉換曲線；數值越高，rho 越需要接近 1，VCMA 才會明顯加速。

5. 輸出 WMA
圖表上的線條是原始自適應結果的加權移動平均：

VCMA = WMA(Raw VCMA, Output WMA Length)

預設的 3 週期 WMA 可減少細微轉折，同時只加入有限延遲。設為 1，即可顯示未經額外平滑的自適應核心。

數學設計

VCMA 採用一種具辨識度的自適應移動平均線結構：把一維價格路徑效率延伸為二維延遲座標路徑，並加入有效移動閘門，以降低孤立價格衝擊造成的加速。

延遲價格點 X(t) = [Source(t), Source(t-1)] 形成一條路徑，而 [d(t), d(t-1)] 就是路徑上的每一步。向量一致性比率等於路徑的淨位移除以實際行走總距離，因此可衡量近期延遲路徑有多筆直，以及方向有多一致。與一維比率不同，即使價格變化方向相同，若相鄰變化之間的關係反覆而不規則，這個二維比率仍可作出區分。

有效移動閘門再加入集中度檢查。向量一致性衡量方向是否配合；有效移動支持度則衡量這種配合是否分布於足夠的移動。只有兩項條件同時成立，VCMA 才會加快。

這個自適應核心只使用當前及過往資料，不受價格尺度影響，而且 Alpha 有明確上下限。它不會向前投射價格，最後的 WMA 亦只使用正權重。VCMA 仍然是移動平均線，因此必然存在延遲；它的作用是根據已觀察到的價格路徑結構調整延遲。

特性與優點

• 固定顏色的簡潔顯示，不加入內置趨勢分類
• 不受價格尺度影響的向量一致性量度
• 反應速度受具體 Fast 與 Slow 週期限制
• 降低孤立而高一致性的價格衝擊所造成的影響
• 可用 Coherence Power 調整非線性反應
• 可選用短週期 WMA 整理最終線條
• 在 TradingView Data Window 提供內部診斷數值

如何閱讀 VCMA

VCMA 使用單一固定顏色，顏色不代表方向或市場狀態。閱讀時應觀察線條斜率、價格相對位置，以及價格在 VCMA 附近的行為。

斜率
VCMA 上升，表示自適應基準正在提高；VCMA 下跌，表示基準正在降低。線條逐漸走平，通常代表近期方向進展正在減弱，或價格移動的一致性下降。

價格位置
價格維持在上升 VCMA 之上，可支持多頭趨勢判斷；價格維持在下降 VCMA 之下，可支持空頭判斷。價格位置與線條斜率配合使用，比單獨觀察任何一項更有參考價值。

距離與穿越
價格與 VCMA 的距離擴大，可能反映動能增強，也可能表示價格已偏離自適應基準。當市場結構仍然完整，回調至 VCMA 附近可提供趨勢背景。價格反覆穿越 VCMA，通常表示市況反覆或橫行，此時移動平均線基準的參考價值會下降。

Data Window 診斷數值

• VCMA Coherence Score - 原始向量一致性乘以移動支持度
• VCMA Raw Vector Coherence - 未加入支持閘門前的方向一致性
• VCMA Effective-Move Support - 向量幅度的分布廣度
• VCMA Adaptive Alpha - 原始核心實際使用的平滑係數

Raw Vector Coherence 偏高但 Support 偏低，通常代表一次主導事件尚未得到其他移動充分配合。一致性與支持度同時偏高時，Alpha 才可向 Fast 上限移動。

設定說明

Source
選擇 VCMA 使用的價格序列，預設為 Close。

Coherence Length
控制衡量向量一致性的週期。較短數值適應更快；較長數值會評估更廣的價格路徑，變化通常較慢。

Fast Period 與 Slow Period
定義最快及最慢反應。較短的 Fast Period 會提高最大靈敏度；較長的 Slow Period 則會在一致性或支持度偏弱時令 VCMA 更保守。

Coherence Power
較高數值會更強地壓低中等一致性的作用，只在 rho 接近 1 時採用較快反應。較低數值會較早及較平順地提高速度。

Effective Moves for Full Speed
設定完整支持所需的分布程度。較高數值能更強地抑制孤立移動，但也可能延遲真實趨勢初段的加速。

Output WMA Length
控制最終平滑程度。數值越高，線條越穩定，但延遲亦會增加。設為 1 可停用這一層。

實際應用

VCMA 可作為自適應趨勢基準、回調參考、方向過濾器，亦可配合其他指標作為數學基礎線。它不提供內置狀態顏色或交叉邏輯，適合希望直接判讀平均線本身的交易者。

VCMA 不會預測未來價格，也不能消除所有來回穿越。設定應配合商品、時間週期與預計持倉時間，並以價格結構、波動性、成交量及較高時間週期背景作為補充證據。

---

Vector Coherence Moving Average（VCMA）

Vector Coherence Moving Average（ベクトル・コヒーレンス移動平均線、VCMA）は、直近の価格変化ベクトルがどの程度同じ方向にそろっているかを基準に、反応速度を調整する適応型移動平均線です。チャート上では、細い単色ラインでシンプルに表示されます。

VCMAは、次の2点をもとに平滑化の速度を調整します。直近の価格変化は一貫した方向を向いているか。その一貫性は単発の値動きではなく、複数の意味のある変動によって支えられているか。方向がそろい、かつ十分な裏付けがあるときは反応を速め、どちらかが弱いときはSlow側の穏やかな反応に近づきます。

VCMAの計算方法

1. 遅延座標上の価格経路
VCMAはまず、選択したSourceについて、各バー間の価格変化を計算します。

d(t) = Source(t) - Source(t-1)

次に、価格を2次元の遅延座標上にある点として表します。

X(t) = [Source(t), Source(t-1)]

X(t-1)からX(t)への移動によって、次の遅延ベクトルが得られます。

z(t) = X(t) - X(t-1) = [d(t), d(t-1)]
Magnitude(t) = sqrt[d(t)^2 + d(t-1)^2]

方向性のある値動きが続くと、これらのベクトルは似た方向を向く傾向があります。一方、価格が往復するとベクトルの方向が食い違い、合計したときに互いを打ち消します。

2. ベクトル・コヒーレンス
設定したCoherence Lengthの範囲で、VCMAはこの経路の直線変位と、実際にたどった総距離を比較します。これは、合成ベクトルの長さと、各ベクトルの長さの合計を比較することと同じです。

rho = sqrt[(Sum d(t))^2 + (Sum d(t-1))^2] / Sum sqrt[d(t)^2 + d(t-1)^2]

この形で見ると、rhoは2次元の経路効率、つまり経路の直進性を表す比率です。

三角不等式により、rhoは0から1の範囲に収まります。

• rhoが1に近い - 直近の遅延ベクトルが高い精度で同じ方向にそろっている
• rhoが0に近い - ベクトルの方向が互いに大きく打ち消し合っている

分子と分母はどちらも価格変動の大きさに比例するため、ベクトル・コヒーレンスは銘柄の名目価格水準に左右されません。

3. 有効変動の支持度
単発の大きな変動は、それに逆らう動きがほとんどないだけで、高いコヒーレンスを生む場合があります。そこでVCMAは、ベクトルの大きさから有効サンプルサイズを計算します。

Effective Moves = (Sum Magnitude)^2 / Sum Magnitude^2

これはバー数そのものではなく、どれだけ多くの値動きが実質的に寄与しているかを表す指標です。1つの変動が全体を支配していると低くなり、複数の変動が十分な大きさで寄与すると高くなります。

Support = Clamp[(Effective Moves - 1) / (Move Target - 1), 0, 1]

初期設定の目標値は3です。VCMAがコヒーレンス信号を完全に反映するには、複数の値動きによる十分な裏付けが必要になります。これにより、単発のギャップ、急騰・急落、長いヒゲに反応して、ただちに最高速度へ切り替わる動きを抑えます。

4. 適応型Alpha
Fast PeriodとSlow Periodは、再帰型平均線の反応速度の上限と下限を定めます。入力順が逆でも、短い方をFast、長い方をSlowとして自動的に扱います。

Fast Alpha = 2 / (Fast Period + 1)
Slow Alpha = 2 / (Slow Period + 1)

Speed Gate = rho^Coherence Power x Support
Adaptive Alpha = Slow Alpha + (Fast Alpha - Slow Alpha) x Speed Gate

Raw VCMA = Previous Raw VCMA + Adaptive Alpha x (Source - Previous Raw VCMA)

Alphaは常に、選択したSlowとFastの範囲内に収まります。Coherence Powerは速度変化のカーブを調整します。値を大きくするほど、rhoが1に近づかない限り、VCMAは大きく加速しにくくなります。

5. 出力WMA
チャートに表示されるラインは、生の適応結果に加重移動平均を適用したものです。

VCMA = WMA(Raw VCMA, Output WMA Length)

初期設定の3期間WMAは、わずかな追加遅延に抑えながら、小さな折り返しを滑らかにします。Output WMA Lengthを1に設定すると、この追加平滑化を無効にし、生の適応コアを表示できます。

数学的な考え方

VCMAは、1次元の価格経路効率を2次元の遅延座標経路へ拡張し、さらに単発のショックによる過度な加速を抑える有効変動ゲートを組み合わせた、特徴的な適応型移動平均線です。

遅延価格点 X(t) = [Source(t), Source(t-1)] が1本の経路を形成し、その各ステップがベクトル [d(t), d(t-1)] になります。コヒーレンス比率は、経路の正味変位を実際に移動した総距離で割ったものです。これにより、直近の遅延経路がどれだけ直線的で、方向がどれだけ一貫しているかを測定します。1次元の比率とは異なり、価格変化の符号が同じであっても、隣り合う変化の関係が不規則なら、その違いを捉えることができます。

有効変動ゲートは、さらに寄与の集中度を確認します。ベクトル・コヒーレンスは方向の整合性を測り、有効変動の支持度は、その整合性が十分な数の値動きに分散しているかを評価します。VCMAが加速するのは、両方の条件がそろった場合だけです。

その結果、VCMAの適応コアは現在および過去のデータだけで計算され、価格尺度に依存せず、反応速度にも明確な上下限があります。将来の価格を先取りして投影することはなく、最後のWMAも正の重みだけを使用します。VCMAも移動平均線である以上、遅延そのものは残ります。その目的は、観測された価格経路の構造に応じて、反応遅延の度合いを調整することです。

特徴と利点

• トレンド分類を組み込まない、シンプルな単色表示
• 価格尺度に依存しないベクトル・コヒーレンス測定
• 解釈しやすいFast PeriodとSlow Periodの範囲内で反応
• 単発の価格ショックによる過度な加速を抑制
• Coherence Powerによる非線形反応の調整
• 短期WMAによる任意の最終平滑化
• TradingViewのデータウィンドウで内部診断値を確認可能

チャート上でのVCMAの見方

VCMAは常に1つの固定色で表示され、色そのものに方向や相場状態の意味はありません。ラインの傾き、価格との位置関係、そしてVCMA付近での価格の動きを読み取ります。

傾き
VCMAが上昇している場合は、適応型の基準線が切り上がっていることを示します。下降している場合は、基準線が切り下がっていることを示します。ラインが横ばいに近づく場合は、直近の方向性が弱まっているか、値動きの一貫性が低下している可能性があります。

価格との位置関係
上向きのVCMAより上で価格が推移していれば、強気トレンドの解釈を補強します。下向きのVCMAより下で価格が推移していれば、弱気トレンドの解釈を補強します。価格の位置とラインの傾きを組み合わせる方が、どちらか一方だけを見るよりも有用です。

距離とクロス
価格とVCMAの距離が広がる動きは、強いモメンタムを表す一方で、適応型の基準線から価格が行き過ぎている可能性も示します。市場構造が維持されている場合、VCMA付近への押し目や戻りはトレンド判断の参考になります。価格がVCMAを何度も往復する場合は、方向感が定まっていないかレンジ相場であることが多く、移動平均線を基準にする有効性は低下します。

データウィンドウの診断値

• VCMA Coherence Score - 生のベクトル・コヒーレンスに変動支持度を掛けた値
• VCMA Raw Vector Coherence - 支持ゲートを適用する前の方向整合性
• VCMA Effective-Move Support - ベクトルの大きさがどの程度広く分散しているか
• VCMA Adaptive Alpha - 生の適応コアが実際に使用した平滑化係数

Raw Vector Coherenceが高くてもSupportが低い場合、1つの支配的なイベントに対して、ほかの値動きによる裏付けがまだ不足していることが多いと考えられます。コヒーレンスと支持度がともに高くなると、AlphaはFast側の上限へ近づくことができます。

設定項目

Source
VCMAの計算に使用する価格系列を選択します。初期設定はCloseです。

Coherence Length
ベクトルの整合性を測定する期間を設定します。短くすると適応が速くなり、長くするとより広い価格経路を評価するため、通常は変化が緩やかになります。

Fast PeriodとSlow Period
最速時と最遅時の反応を定めます。Fast Periodを短くすると最大反応速度が上がります。Slow Periodを長くすると、コヒーレンスまたは支持度が弱い場面でVCMAがより慎重に反応します。

Coherence Power
値を大きくすると、中程度のコヒーレンスによる影響をより強く抑え、rhoが1に近い場合にだけ速い反応を許します。値を小さくすると、より早い段階から滑らかに加速します。

Effective Moves for Full Speed
完全な支持度に達するために必要な、値動きの分散度を設定します。値を大きくすると単発の変動をより強く抑えられますが、本物のトレンドが始まった直後の加速も遅れる可能性があります。

Output WMA Length
最終平滑化の強さを設定します。値を大きくするとラインは安定しますが、遅延も増えます。1に設定すると、この平滑化を無効にできます。

実践的な使い方

VCMAは、適応型のトレンド基準線、押し目・戻りの参考線、方向フィルター、またはほかのインジケーターと組み合わせる数学的なベースラインとして利用できます。状態ごとの色分けやクロス判定を内蔵しないため、移動平均線そのものを直接読み取りたい場合に適しています。

VCMAは将来の価格を予測するものではなく、頻繁な往復やダマシを完全に排除することもできません。設定は銘柄、時間足、想定する保有期間に合わせて調整し、価格構造、ボラティリティ、出来高、上位時間足の状況も補足材料として利用してください。

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © realanthonyc https://www.tradingview.com/u/realanthonyc

//@version=6
// ------------------------------------------------------------------------------
//  Vector Coherence Moving Average
// ------------------------------------------------------------------------------
indicator("Vector Coherence Moving Average (VCMA)", shorttitle = "VCMA", overlay = true, max_bars_back = 1000)

// ------------------------------------
// Inputs
// ------------------------------------

const string MAIN_GROUP = "Main VCMA"
const string FILTER_GROUP = "Coherence Filter"

float src       = input.source(close, "Source", group = MAIN_GROUP)
int length      = input.int(14, "Coherence Length", minval = 2, maxval = 500, group = MAIN_GROUP)
int fastLen     = input.int(3, "Fast Period", minval = 1, maxval = 500, group = MAIN_GROUP, tooltip = "The shorter of the Fast and Slow periods is always treated as fast.")
int slowLen     = input.int(30, "Slow Period", minval = 2, maxval = 500, group = MAIN_GROUP, tooltip = "The longer of the Fast and Slow periods is always treated as slow.")
float gamma     = input.float(2.0, "Coherence Power", minval = 0.5, maxval = 5.0, step = 0.1, group = MAIN_GROUP, tooltip = "Higher values require stronger directional coherence before the average accelerates.")

int minMoves    = input.int(3, "Effective Moves for Full Speed", minval = 2, maxval = 10, group = FILTER_GROUP, tooltip = "Reduces false acceleration from a single price shock. The speed gate reaches full strength after this many effective contributing moves.")
int outputSmoothLen = input.int(3, "Output WMA Length", minval = 1, maxval = 10, group = FILTER_GROUP, tooltip = "Applies a final WMA to the VCMA. Set to 1 to disable output smoothing.")

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
// Calculation
// ------------------------------------

[vcmaRaw, coherenceScore, rawCoherence, moveSupport, adaptiveAlpha] = vcma(src, length, fastLen, slowLen, gamma, minMoves)

// Smooth only the displayed output.
// Coherence and adaptive alpha continue to use the unsmoothed VCMA core.
float vcmaValue = ta.wma(vcmaRaw, outputSmoothLen)

// ------------------------------------
// Visuals
// ------------------------------------

plot(vcmaValue, "VCMA", color = #00BCD4, linewidth = 1)

// Keep diagnostics available without changing the chart scale.
plot(coherenceScore, "VCMA Coherence Score", display = display.data_window)
plot(rawCoherence, "VCMA Raw Vector Coherence", display = display.data_window)
plot(moveSupport, "VCMA Effective-Move Support", display = display.data_window)
plot(adaptiveAlpha, "VCMA Adaptive Alpha", display = display.data_window)
````
