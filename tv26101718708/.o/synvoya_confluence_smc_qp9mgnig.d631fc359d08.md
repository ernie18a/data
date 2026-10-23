【共用】ATR=ATR(14)。

【1. 結構突破（BOS／CHoCH）】
- 擺動高低點：用左右各 10 根的 pivot high／pivot low。第 i 根要等到第 i+10 根收盤後才確認。
- 追蹤最新「未被突破」的 pivot 高 PH 與 pivot 低 PL，並記錄各自的 bar 位置。bias 初始為 0，多方突破後為 1，空方突破後為 -1。
- 母 K 區間：若當根 high<=前根 high 且 low>=前根 low（內包線），且目前沒有母 K 區間，就把前根 high／low 存成母 K 區間。收盤 close 突破該區間任一側後清除。
- 做多（突破向上），須同時滿足：
  1. 目標價為 PH。若 bias==-1 且有「保護高點」，目標價改用保護高點。
  2. close > 目標價 + 0.03×ATR。
  3. 目標高點之後已出現一個新確認的 pivot 低（該 pivot 低的 bar 位置在目標高點的 bar 位置之後）。
  4. |目標價 − 最新 PL| >= 0.25×ATR。
  5. 若有母 K 區間，close 要大於母 K 高。
  6. 同一根 K 不可同時符合多空突破條件。
  - 若 bias==-1（用保護高點為目標）則為 CHoCH 多，否則為 BOS 多；兩者都指向做多。
  - 突破後 bias=1，PH 清空。把當時的 PL 記為多方保護低點，並清掉保護高點。
- 做空（突破向下）：以上全部鏡像。close < 目標價 − 0.03×ATR，目標為 PL（bias==1 時用保護低點），其後須有新的 pivot 高，|最新 PH − 目標價| >= 0.25×ATR，close < 母 K 低。若 bias==1 則為 CHoCH 空，否則為 BOS 空；兩者都指向做空。突破後 bias=-1，PL 清空。把當時的 PH 記為空方保護高點，並清掉保護低點。
- 內部層級（左右各 5 根的 pivot）的 iBOS／iCHoCH 用同樣邏輯，但最小波段改為 0.125×ATR，且須先通過外部層級的判斷。

【2. FVG（三根 K 缺口）】
- 多方 FVG：low > high[2]，且缺口 low−high[2] >= 0.1×ATR。
- 空方 FVG：high < low[2]，且缺口 low[2]−high >= 0.1×ATR。
- 多方 FVG 之後若 close 跌破缺口下緣（先有 close 低於缺口中點），會翻成看空的反轉缺口 iFVG。空方 FVG 之後若 close 站上缺口上緣（先有 close 高於中點），會翻成看多的 iFVG。

【3. 訂單塊 OB】
- 多方突破（做多）時，往回 50 根內找最近一根收黑 K（close<open），區間為 [low, open]，標為看多 OB。
- 空方突破（做空）時，往回找最近一根收紅 K（close>open），區間為 [open, high]，標為看空 OB。
- 看多 OB 若 close 跌破區間中點，轉為看空的 breaker；之後若 close 跌破其下緣則失效。
- 看空 OB 若 close 站上區間中點，轉為看多的 breaker；之後若 close 站上其上緣則失效。

【4. CRT】
- 條件：high>high[1] 且 low<low[1]。
- close>open 為看多 CRT，close<open 為看空 CRT。
- 過濾：週期須為 15 分以上。

【5. 流動性掃蕩】
- 兩個外部 pivot 高（左右各 10 根）的價差 <= 0.1×ATR，視為等高點 EQH，水平位置取兩者平均。
- 兩個外部 pivot 低的價差 <= 0.1×ATR，視為等低點 EQL，水平位置取兩者平均。
- 掃蕩高點（指向空方）：high > EQH 且 close < EQH。
- 掃蕩低點（指向多方）：low < EQL 且 close > EQL。
- 每個位置只觸發一次。

【6. EMA 偏向】
- 多：close > EMA9 且 close > EMA21。
- 空：close < EMA9 且 close < EMA21。
- 其餘為中性。

【7. 蠟燭著色（選用）】
- close>open 為多，close<open 為空。
- 結構模式下，bias==1 為多，bias==-1 為空。