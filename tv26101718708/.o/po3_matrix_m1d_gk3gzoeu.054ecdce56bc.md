以下 K 線序號 0=最新已收盤，數字越大越舊；avgR=最近至多19根已收K的(high-low)平均。多空判斷在回測資料自身週期的K線上計算。

【真 swing】swing low：low[s]<low[s-1] 且 low[s]<low[s+1]，且((close[s]>open[s] 且 close[s+1]<open[s+1]) 或 (close[s]<open[s] 且 close[s-1]>open[s-1]))。swing high：high[s]>high[s-1] 且 high[s]>high[s+1]，且((close[s]<open[s] 且 close[s+1]>open[s+1]) 或 (close[s]>open[s] 且 close[s-1]<open[s-1]))。

【MSS 結構轉變】
- 做空：有 swing low(s)，找 j<=s-2 中最早（最舊）一根已收盤K，其 close<low[s]。
- 做多：有 swing high(s)，最早一根 j<=s-2 的 close>high[s]。
- 同一個 swing 只在第一根收破的K標示，之後的收破是延續，不再標示。
- 過濾（預設開）：突破K需位移，即(high[j]-low[j])>=0.5*avgR，或在轉變方向留下缺口。做空缺口為 high[j]<low[j+2]，做多缺口為 low[j]>high[j+2]。
- 可選過濾（預設關）：做空前要先有買方掃流動性（某K的 high 高過更舊的 pivot high），做多前要先有賣方掃流動性。

【流動性掃盪 sweep】pivot high p：high[p]>high[p-1] 且 high[p]>high[p+1]。
- 做空（買方掃盪，偏空）：存在 i<=p-2，high[i]>high[p] 且 close[i]<high[p]，且 i+1..p-1 的K都沒有 high 超過 high[p]。
- 做多（賣方掃盪，偏多）：pivot low p：low[p]<low[p-1] 且 low[p]<low[p+1]。存在 i<=p-2，low[i]<low[p] 且 close[i]>low[p]，且 i+1..p-1 的K都沒有 low 跌破 low[p]。
- 若 i 是 i-1 同時 i 到 p 間最近的符合者，取最靠近 i 的 p；每根K同時可有多空兩側。

【FVG BISI+/SIBI-】取 i（新）、i+1（中）、i+2（舊），i>=1。
- 多方缺口 BISI+：low[i]>high[i+2]，缺口高度>=0.15*avgR，且中間K為陽線(close>open)、實體>=0.5*avgR。區間為 [high[i+2], low[i]]，偏多。
- 空方缺口 SIBI-：high[i]<low[i+2]，缺口高度>=0.15*avgR，且中間K為陰線、實體>=0.5*avgR。區間為 [high[i], low[i+2]]，偏空。
- 區間可延伸吸收中間K兩側的實體缺口(volume imbalance)：多方 zBot=min(zBot,max(open[i+2],close[i+2])) 的條件是 min(open,close)[i+1]>max(open,close)[i+2] 且 low[i+1]<=high[i+2]。上緣條件對稱；空方鏡像處理。
- 之後依時間順序檢查比它新的K。多方缺口先有 close<zBot 即「反轉 inverted」，變成偏空（做空）；空方缺口先有 close>zTop 則變偏多（做多）。
- 反轉後若又有 close 收回原方向外側（多方缺口 close>zTop，空方缺口 close<zBot），則作廢，不再指向任何方向。
- 未反轉前，K線影線進入區間 70% 深度(active)就移除該缺口。

【Suspension Block SB+/SB-】（僅 Suspension Blocks 模式）連續>=3根同向K，每根開盤都越過前一根收盤。上漲：open[k]>close[k+1] 且皆陽線，為 SB+，偏多。下跌：open[k]<close[k+1] 且皆陰線，為 SB-，偏空。區間為最舊K的 close 到最新K的 open。反轉與作廢規則同 FVG，高度>=0.15*avgR。