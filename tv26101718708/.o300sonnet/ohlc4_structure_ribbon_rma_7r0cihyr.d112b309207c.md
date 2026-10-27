【指標】ohlc4=(open+high+low+close)/4。Rn=ohlc4 的 Wilder RMA（alpha=1/n），n=5,8,13,20,34,50,75,110。ATR14=TR 的 Wilder RMA。

【多空交叉】對下列每一組 (快,慢)：(R5,R8)、(R8,R20)、(R13,R34)、(R20,R50)、(R75,R110)。快線上穿慢線（前一根快<=慢、這根快>慢）為做多。快線下穿慢線（前一根快>=慢、這根快<慢）為做空。

【收盤價對各均線】對每條 Rn：close>Rn 為偏多，close<Rn 為偏空，相等時維持上一次的方向。

【長結構方向】R75>R110 為偏多，否則為偏空。

【完整堆疊】多頭堆疊：R5>R8>R13>R20>R34>R50（嚴格）。空頭堆疊：R5<R8<R13<R20<R34<R50。

【CORE 強度，範圍 -100 到 100】
1. 令 lag=(4,7,12,19,33,49)，分別對應 R5,R8,R13,R20,R34,R50。
2. spread = -45 × Σ((lag_i − 20.6667) × R_i) / 1497.3333。spread 為正代表快線整體在慢線之上。
3. raw = spread / ATR14。
4. CORE = sign(raw) × f(|raw|)。f 為分段線性：0→0、0.7→34、1.25→55、2.5→65、4→75、7→89、12→95、20→100，超過 20 取 100。

【全域狀態，逐根更新，保留上一根的 lineage（多/空/無）與 activeSide（多/空/無）】
- 頂部 Exceptional：多頭堆疊且 CORE>=95。若上一根已是此狀態，則多頭堆疊且 CORE>=89 即維持。
- 底部 Exceptional：空頭堆疊且 CORE<=-95。若上一根已是此狀態，則空頭堆疊且 CORE<=-89 即維持。
- 頂部 Extreme：多頭堆疊且 CORE>=89。若上一根已是 Extreme 多方（含 Exceptional），則多頭堆疊且 CORE>=75 即維持。
- 底部 Extreme：空頭堆疊且 CORE<=-89。若上一根已是 Extreme 空方（含 Exceptional），則空頭堆疊且 CORE<=-75 即維持。
- Bull Rise：多頭堆疊，且不是 Extreme 或 Exceptional，並符合下列任一條件：
  - 上一根 activeSide=多（持續）。
  - lineage=多 且 CORE>=34。
  - lineage≠多 且 CORE>=55。
- Bear Fall：空頭堆疊，且不是 Extreme 或 Exceptional，並符合下列任一條件：
  - 上一根 activeSide=空（持續）。
  - lineage=空 且 CORE<=-34。
  - lineage≠空 且 CORE<=-55。
- Bull Resistance：上述各狀態都不成立，且 lineage=多。
- Bear Support：上述各狀態都不成立，且 lineage=空。
- 狀態判定後更新：
  - 若為 Rise、頂部 Extreme 或頂部 Exceptional，則 lineage 與 activeSide 設為多。
  - 若為 Fall、底部 Extreme 或底部 Exceptional，則 lineage 與 activeSide 設為空。
  - 其餘情況，若 activeSide=多 且不再是多頭堆疊，或 activeSide=空 且不再是空頭堆疊，則 activeSide 設為無。

【狀態指向的方向】
- 偏多：Bull Rise、頂部 Extreme、頂部 Exceptional。
- 偏空：Bear Fall、底部 Extreme、底部 Exceptional。
- Bull Resistance 表示多頭 lineage 被削弱（堆疊亂了但尚未轉向）。Bear Support 表示空頭 lineage 被削弱。
- 由偏多轉為 Bull Resistance，是多方堆疊失序但尚未被空方接手。由 Bull Resistance 轉為 Bear Fall，需要空頭堆疊且 CORE<=-55。Bear Support 反向同理，需多頭堆疊且 CORE>=55 才轉為 Bull Rise。

【快緣轉向】R5>=R8 為偏多，R5<R8 為偏空。從 5/8 起依序檢查相鄰各組，連續符合同方向的組數為 x/5。5/5 即完整堆疊成形。