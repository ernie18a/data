【共用計算】VWAP：典型價 hlc3，每個交易日重置，累計 sumPV=Σ(hlc3×volume)、sumV=Σvolume、sumP2V=Σ(hlc3²×volume)。VWAP=sumPV/sumV。dev=sqrt(max(sumP2V/sumV−VWAP²,0))。上下軌 1 與 2 為 VWAP±1×dev 與 VWAP±2×dev。ATR14 為一般 14 期 ATR。

1) K 棒顏色多空（每根都判斷）：close>=open 為多，否則為空。

2) 趨勢棒（只在棒收盤後判斷，顏色同上，close>=open 標多，否則標空）。全部條件須同時成立：
- 實體 |close−open| >= 1.10×SMA20(實體)。
- volume >= SMA20(volume)。
- 實體大於一個最小跳動單位，且 max(上影,下影) <= 0.2×實體。上影=high−max(open,close)，下影=min(open,close)−low。
- 該棒觸及 VWAP 或 ±1、±2 軌之一。觸及指 high >= 線−tol 且 low <= 線+tol，tol=max(0.12×ATR14, 8 個最小跳動單位)。
- 與上一根趨勢棒相隔至少 8 根。

3) Doji（收盤後判斷，且不是趨勢棒）：range>最小跳動單位，|close−open|/(high−low) <= 0.25，且 volume >= 0.9×SMA20(volume)。close>=open 標多，否則標空。

4) 當日偏向多空：每日重置後，累計 close>=VWAP 的根數與 close<VWAP 的根數，各自取佔比（四捨五入到整數百分比）。上方佔比較大偏多，下方佔比較大偏空，相等為中性。

5) VWAP 觸及型 FVG：
- 多方 FVG：low > high[2]。
- 空方 FVG：high < low[2]。
- 兩者都要求中間那根（前一根）的 high/low 範圍觸及前一根的 VWAP 或 ±1、±2 軌，容差為半個最小跳動單位。
- 多方 FVG 指向做多，空方 FVG 指向做空。
- 此 FVG 之後只要多方 FVG 下緣 high[2] 被 low 碰到，或空方 FVG 上緣 low[2] 被 high 碰到，即失效。

6) Big Trade 買賣量：
- range=max(high−low, 最小跳動單位)。
- 收在區間位置 closePos=clamp((close−low)/range,0,1)。
- buyRange=volume×closePos，sellRange=volume×(1−closePos)。
- bodyBias=(clamp((close−open)/range,−1,1)+1)/2。buyBody=volume×bodyBias，sellBody=volume×(1−bodyBias)。
- buyBase=(buyRange+buyBody)/2，sellBase=(sellRange+sellBody)/2。
- dirBoost=clamp((close−close[1])/range,−1,1)。
- wickBias=clamp((下影−上影)/range,−1,1)。
- flow=clamp(0.65×dirBoost+0.35×wickBias,−1,1)。flowBuy=(flow+1)/2，flowSell=1−flowBuy。
- buyVol=0.78×buyBase+0.22×volume×flowBuy。sellVol=0.78×sellBase+0.22×volume×flowSell。
- 過濾：|buyVol−sellVol|/volume×100 >= 2。
- 門檻 threshold=max(1, 0.8×SMA20(volume))。
- 做多：收盤後 buyVol>=threshold，且該棒為陽線（close>open）或平盤（close==open）。若為陰線，須 buyVol/volume×100 >= 26 才算。
- 做空：收盤後 sellVol>=threshold，且該棒為陰線或平盤。若為陽線，須 sellVol/volume×100 >= 26 才算。

7) CISD（收盤後判斷）：
- 以 3 根左右各看的 pivot high、pivot low 維護兩個清單，分別存波段高點與低點，每個 pivot 在確認後才加入。
- 掃高：當根 high 大於清單中任一波段高點（由最新往前找，找到一個即移除並視為掃高）。
- 掃低：當根 low 小於清單中任一波段低點（同樣由最新往前找，找到即移除）。
- 連續同色序列：連續陽線稱多序列，起點是該序列第一根的 open。連續陰線稱空序列，起點同理。遇到反色棒，序列歸零。
- 掃高且有進行中的多序列時，記下多序列起點 open 並進入等待。之後出現陰線且 close 低於該起點 open，即 CISD−，指向做空。
- 掃低且有進行中的空序列時，記下空序列起點 open 並進入等待。之後出現陽線且 close 高於該起點 open，即 CISD+，指向做多。
- 等待中不再接受新的掃高或掃低。等待超過序列起點之後 20 根即取消。