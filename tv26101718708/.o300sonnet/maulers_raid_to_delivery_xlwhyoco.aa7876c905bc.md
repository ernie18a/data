【C2 方向，高週期 K 棒收盤後判斷，高週期由資料聚合，prev 為前一根高週期 K 棒】
看多 C2：low<prev.low 且 close>prev.low。看空 C2：high>prev.high 且 close<prev.high。
同時 high>prev.high 且 low<prev.low 的雙邊 K 棒不算 C2。變體（預設關）：向下掃破 prev.low 後 close>prev.high 算看多 C2，向上掃破 prev.high 後 close<prev.low 算看空 C2。

【CISD 進場，在配對的低週期上逐根算，低週期約為高週期的 1/15 到 1/12。1m 對 15m、5m 對 1h、15m 對 4h、1h 對 1D】
向下 run 錨：陰線（close<open）且前面最近的是陽線時，錨=該陰線 open。每當有 K 棒 open>錨，錨改成該 open。向上 run 錨：陽線且前面最近的是陰線時，錨=該陽線 open。每當有 K 棒 open<錨，錨改成該 open。
當根高週期 K 棒進行中，若 low<prev.low 且 low<=當根累計最低，記下看多 CISD 位=向下 run 錨。若 high>prev.high 且 high>=當根累計最高，記下看空 CISD 位=向上 run 錨。有新的低或高就覆蓋舊值。
高週期 K 棒收盤時若為看多 C2 且已記下 CISD 位，則看多武裝。若為看空 C2 且已記下 CISD 位，則看空武裝。
做多：武裝後，C2 之後的低週期 K 棒 close>CISD 位。若 C2 收盤價本身已 >CISD 位，則收盤當下即成立。
做空：武裝後，C2 之後的低週期 K 棒 close<CISD 位。若 C2 收盤價本身已 <CISD 位，則收盤當下即成立。
進場價=確認的那根收盤價。
武裝後尚未確認時，若 low<C2.low（多）或 high>C2.high（空），該次作廢，不進場。

【出場，持倉方向與 C2 極值】
多單：C2 之後第一根高週期 K 棒（C3）期間 low<C2.low，則失敗出場。
空單：C3 期間 high>C2.high，則失敗出場。
C3 結束後不再因此失敗。停損參考=C2 極值（多為 C2.low，空為 C2.high）。
選用停損：CISD 位，或 CISD 位往不利方向加緩衝。

【停利目標，預設關】
0 點=武裝時記下的最近 3 根 K 棒擺動點。多單取擺動高 H，空單取擺動低 L。1 點=C2 極值（多為 C2.low，空為 C2.high）。
多單目標=H+m*(H−C2.low)。空單目標=L−m*(C2.high−L)。m 取 1、2、2.5、3、4。價格觸及即到價。

【回測進場】
確認後價格先完全離開 CISD 位：多單 low>CISD 位，空單 high<CISD 位。之後再回碰：多單 low<=CISD 位，空單 high>=CISD 位。回碰為第二進場點。

【日線偏向過濾】
以昨日日線對前日日線比較（PDH 為前日高、PDL 為前日低）。
偏多：昨日 close>PDH，或昨日 low<PDL 且 close 回到 PDL 與 PDH 之間。
偏空：昨日 close<PDL，或昨日 high>PDH 且 close 回到區間內。
其餘中性：內包日，或同時掃破 PDH 與 PDL 且收在區間內。