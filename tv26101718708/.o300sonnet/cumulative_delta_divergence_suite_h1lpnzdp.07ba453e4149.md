【指標】
1. 每根 K 棒的 delta：上影=high-max(open,close)，下影=min(open,close)-low，實體=|close-open|，分母=上影+下影+實體。rate=分母>0 ? 0.5*(上影+下影+2*實體)/分母 : 0.5。delta=volume*rate*(close>=open ? +1 : -1)。cumdelta=delta 的累計和。
2. CDV 蠟燭：o=前一根 cumdelta，c=本根 cumdelta，h=max(c,o)，l=min(c,o)。再做 Heikin-Ashi：haclose=(o+h+l+c)/4。haopen 第一根=(o+c)/2，之後=(前一根 haopen+前一根 haclose)/2。osc=haclose。
3. 樞紐：osc 的低點樞紐（左 5 根、右 7 根都不低於它）和高點樞紐（左 5 根、右 7 根都不高於它）。要等右側 7 根收完才確認，確認那根 K 棒收盤才能進場。樞紐 K 棒是確認棒往前數第 7 根，其價格取該根的 low（低點樞紐）或 high（高點樞紐）。「前一個樞紐」是上一個同類樞紐的 osc 值與同根價格。

【做多】在低點樞紐確認的那根，符合下列任一條件就做多：
- 常規多頭背離：樞紐 K 棒的 low < 前一低點樞紐的 low，且 osc > 前一低點樞紐的 osc。
- 隱藏多頭背離：樞紐 K 棒的 low > 前一低點樞紐的 low，且 osc < 前一低點樞紐的 osc。
- 多頭吸收：同時滿足以下全部條件，且最近 20 根內（含本根）曾出現上述任一多頭背離確認：
  - delta < -(|delta| 的 20 根 SMA)*1.4。
  - volume > volume 的 20 根 SMA*1.10。
  - 本根 high-low（下限為最小跳動）<= (high-low 的 20 根 SMA)*2.0。
  - |close-open|/(high-low) <= 0.70。

【做空】在高點樞紐確認的那根，符合下列任一條件就做空：
- 常規空頭背離：樞紐 K 棒的 high > 前一高點樞紐的 high，且 osc < 前一高點樞紐的 osc。
- 隱藏空頭背離：樞紐 K 棒的 high < 前一高點樞紐的 high，且 osc > 前一高點樞紐的 osc。
- 空頭吸收：同時滿足以下全部條件，且最近 20 根內（含本根）曾出現上述任一空頭背離確認：
  - delta > (|delta| 的 20 根 SMA)*1.4。
  - volume > volume 的 20 根 SMA*1.10。
  - 本根 high-low（下限為最小跳動）<= (high-low 的 20 根 SMA)*2.0。
  - |close-open|/(high-low) <= 0.70。