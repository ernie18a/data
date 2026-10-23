方向標示來自「確認後的轉折反應」：轉折低點標示為支撐型反應（指向做多），轉折高點標示為壓力型反應（指向做空）。判斷在轉折確認那根 K 棒收盤時計算。令 t 為當根，轉折棒為 t-3，a=第 t-3 根的 ATR（Wilder 平均，週期 14，須大於 0）。

共同定義：
- 轉折棒的 body=max(|close-open|, 最小跳動單位)。
- 轉折低點：第 t-3 根的 low 是第 t-6 到 t 根（共 7 根）中最低。
- 轉折高點：第 t-3 根的 high 是這 7 根中最高。

做多（支撐型反應）須同時成立：
1. 第 t-3 根是轉折低點，P=low[t-3]。
2. 反應強度 strength 至少 0.2。其中 strength=0.65*(最近 3 根（t、t-1、t-2）最高 high - P)/a + 0.35*max(0,(close_t - P)/a)。
3. 下影線比 lw=(min(open,close)[t-3] - low[t-3])/body，須 ≥0.5。
4. 轉折突出度 prom=max(0,(min(low[t-4], low[t-2]) - P)/a)，須 ≥0.10。
5. 事件品質 eq ≥35。
   - eq=100*(0.45*min(1,strength/1.5) + 0.20*min(1,lw/2) + 0.20*min(1,max(0,(close_t-P)/a)/1.5) + 0.15*min(1,prom))。

做空（壓力型反應）須同時成立：
1. 第 t-3 根是轉折高點，P=high[t-3]。
2. 反應強度 strength 至少 0.2。其中 strength=0.65*(P - 最近 3 根最低 low)/a + 0.35*max(0,(P - close_t)/a)。
3. 上影線比 uw=(high[t-3] - max(open,close)[t-3])/body，須 ≥0.5。
4. 轉折突出度 prom=max(0,(P - max(high[t-4], high[t-2]))/a)，須 ≥0.10。
5. 事件品質 eq ≥35。
   - eq=100*(0.45*min(1,strength/1.5) + 0.20*min(1,uw/2) + 0.20*min(1,max(0,(P-close_t)/a)/1.5) + 0.15*min(1,prom))。

暖機過濾：bar_index 須大於 6，且 ATR 有值並大於 0。