【共用計算】pivot高=某根high比其左右各5根的high都高，第5根後確認；pivot低同理用low。波段高H、波段低L=最近一次確認的pivot高、低。swingPct=(close-L)/max(H-L,最小跳動)*100。

1. EMA判斷：EMA(close,9)。close>EMA偏多；close<EMA偏空。

2. 波段位置判斷，依序檢查：
(a) swingPct<0，收破波段低，偏空。
(b) swingPct>100，收破波段高，偏多。
(c) 掃低回收：自最近一次pivot低確認後曾有任一根low<L，且目前close>L，偏多。
(d) 掃高回收：自最近一次pivot高確認後曾有任一根high>H，且目前close<H，偏空。新pivot確認時重設對應的「曾突破」旗標。
(e) 其餘區間內：swingPct>=50偏空；<50偏多。

3. 結構判斷：新pivot高與前一個pivot高比較，較高記為1(HH)，否則-1(LH)；新pivot低與前一個pivot低比較，較高記為1(HL)，否則-1(LL)。高型、低型取最近一次的值。即時覆蓋：若close<前一個pivot低則低型視為-1；若close>前一個pivot高則高型視為1。高型與低型皆為1偏多；皆為-1偏空；其他為中性。

4. 最近Order Block方向：
- 看多突破：close>最近一個pivot高，且前一根close<=該值。取從突破棒往回最多50根且在該pivot棒之後的範圍內low最低的那根K棒，zone=[low,high]，為多方OB；用掉該pivot高。
- 看空突破：close<最近一個pivot低，且前一根close>=該值。取該範圍內high最高的那根K棒，zone=[low,high]，為空方OB。
- 同向且與既有OB區間重疊者不新增。最多保留6個，超過就丟最舊。
- 每根檢查：多方OB在close<zone下緣時移除；空方OB在close>zone上緣時移除。
- 距離：多方OB為(上緣-close)，空方OB為(下緣-close)。多方、空方各取絕對值最小者，再取絕對值較小的一方；相等取空方。其方向為多偏多、為空偏空，無OB則中性。

5. 最近FVG方向：
- 多方FVG：low[1]>high[3]，且low[1]<high[2]，且low[2]<high[3]，且K棒[2]為上漲棒(close>open或close>前收)。zone=[high[3],low[1]]。
- 空方FVG：high[1]<low[3]，且high[1]>low[2]，且high[2]>low[3]，且K棒[2]為下跌棒(close<open或close<前收)。zone=[high[1],low[3]]。
- 最多保留6個。每根檢查：多方在low<下緣時移除；空方在high>上緣時移除。
- 最近方向用與OB相同的距離規則。多偏多、空偏空。

6. 綜合偏向：score=結構方向(+1/0/-1)+OB方向+FVG方向+波段位置方向。波段位置方向：swingPct<0為-1；>100為+1；<30為+1；>70為-1；其餘0。biasPct=score/4*100。biasPct>20做多(>50為強多)；biasPct<-20做空(<-50為強空)；其餘中性不動作。