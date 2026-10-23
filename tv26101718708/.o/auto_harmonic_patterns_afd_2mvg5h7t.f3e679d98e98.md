【共用定義】swing=8。高點樞紐=某根 high 為左右各8根內最高，低點樞紐=low 為左右各8根內最低，樞紐在其後第8根收盤才確認。把確認的樞紐串成高低交替鏈；連續同類樞紐只保留較極端者。每個樞紐在確認那根收盤才可使用，下面都在這根判斷，記為「確認棒」。

【腿規則】相鄰樞紐為一腿，且方向交替。允許一腿跨過一個小擺動：腿內兩個中間樞紐都嚴格落在腿的高低之內，且它們之間的反向小波動≤該腿幅度×0.382。

【比例】XA=|A-X|，AB=|B-A|，BC=|C-B|，CD=|D-C|，XC=|C-X|。比值為：AB/XA、BC/AB、CD/BC、AD/XA=|D-A|/XA、XC/XA、CD/XC。容許誤差 t=8%：值 v 符合區間[lo,hi]的條件是 lo×(1-t)≤v≤hi×(1+t)。

【五點型態】取最後5個樞紐 X,A,B,C,D，D 是剛確認的樞紐，且 X..D 都符合腿規則。符合下列比例之一就成立，同一組點依序取第一個符合者：
- Shark：BC/AB 1.13–1.618；CD/BC 1.618–2.24；AD/XA 0.886–1.13。
- Cypher：AB/XA 0.382–0.618；XC/XA 1.272–1.414；CD/XC 0.786。
- Nen Star：AB/XA 0.382–0.786；BC/AB 1.13–1.414；CD/BC 1.272–2；AD/XA 1.272。
- Deep Crab：AB/XA 0.886；BC/AB 0.382–0.886；CD/BC 2.24–3.618；AD/XA 1.618。
- Butterfly：AB/XA 0.786；BC/AB 0.382–0.886；CD/BC 1.618–2.618；AD/XA 1.272–1.618。
- Gartley：AB/XA 0.618；BC/AB 0.382–0.886；CD/BC 1.272–1.618；AD/XA 0.786。
- Alt Bat：AB/XA 0.382；BC/AB 0.382–0.886；CD/BC 2–3.618；AD/XA 1.13。
- Bat：AB/XA 0.382–0.5；BC/AB 0.382–0.886；CD/BC 1.618–2.618；AD/XA 0.886。
- Crab：AB/XA 0.382–0.618；BC/AB 0.382–0.886；CD/BC 2.24–3.618；AD/XA 1.618。

【其他型態】
- 5-0：取6個樞紐 P0,X,A,B,C,D，要求|X-A|≤|P0-X|，AB/XA 1.13–1.618，BC/AB 1.618–2.24，CD/BC 0.5。這裡的 X 是第2個樞紐。
- ABCD：取4個樞紐 A,B,C,D，BC/AB 0.382–0.886，CD/BC 1.13–2.618，CD/AB 1.0。若同一 C-D 腿已成立五點型態，就不算 ABCD。
- Three Drives：取6個樞紐 P0,D1,C1,D2,C2,D3，四個比值依序為 |C1-D1|/|D1-P0| 0.618–0.786、|D2-C1|/|C1-D1| 1.272–1.618、|C2-D2|/|D2-C1| 0.618–0.786、|D3-C2|/|C2-D2| 1.272–1.618。

【方向】D 是低點樞紐為看多型態（做多），D 是高點樞紐為看空型態（做空）。

【進場條件，Setup】在確認棒用該棒收盤價 Entry 判斷：
1. 做多要求 Entry>D，做空要求 Entry<D。
2. 做多要求 Entry 不大於 C（該棒收盤沒有突破 C），也不小於 D；做空反向。
3. D 在 PRZ 內：PRZ 為各投影價位的最低到最高。投影價位 = 錨點 + dir×比例×單位，dir 做多為-1、做空為+1；XA 投影的錨點是 A，單位是 XA；其餘投影的錨點是 C，BC 單位是 BC，ABCD 等距單位是 AB，XC 單位是 XC。投影比例如下：
   - Gartley：XA 0.786；BC 1.272–1.618；AB=CD 1.0。
   - Bat：XA 0.886；BC 1.618–2.618；AB=CD 1.0 與 1.27。
   - Alt Bat：XA 1.13；BC 2–3.618；AB=CD 1.618。
   - Butterfly：XA 1.272–1.618；BC 1.618–2.618；AB=CD 1.0 與 1.27。
   - Crab：XA 1.618；BC 2.24–3.618；AB=CD 1.27 與 1.618。
   - Deep Crab：XA 1.618；BC 2.24–3.618；AB=CD 1.27。
   - Cypher：XC 0.786。
   - Shark：XA 0.886–1.13；BC 1.618–2.24。
   - Nen Star：XA 1.272；BC 1.272–2。
   - 5-0：BC 0.5；AB=CD 1.0。
   - ABCD：BC 1.13–2.618；AB=CD 1.0。
   - Three Drives：BC 1.272–1.618。
   只有單一價位時，PRZ 上下各擴 8%×|該價位-錨點|。
4. Gartley、Bat、Cypher 另要求 D 沒越過 X：做多 D>X，做空 D<X。
5. 趨勢過濾（預設開）：取 X 之前最近同類樞紐 prevSame，以及 A 之前最近反類樞紐 prevOpp。對於 X 的同類樞紐，做多時它是低點，做空時它是高點。
   - 延續型（Gartley、Bat、Cypher、Shark、ABCD）：做多要求 X>prevSame 且 A>prevOpp，做空要求 X<prevSame 且 A<prevOpp。
   - 反轉型（Butterfly、Crab、Deep Crab、Alt Bat、Nen Star、5-0、Three Drives）：條件相反，做多要求 X<prevSame 且 A<prevOpp，做空要求 X>prevSame 且 A>prevOpp。
   - 前面樞紐不足就不成立。
   - 5-0 與 Three Drives 的 X、A 取各自第2、第3個點，prev 取往前一個與再往前的樞紐。
   - ABCD 的 X、A 取 A 之前的樞紐與 A，prev 往前再取。
全部成立才在確認棒收盤做多或做空。

【停損與目標】R=|C-D|。T1、T2、T3 = Entry±0.382R、0.618R、1.0R，做多加、做空減。停損 = D∓0.5×ATR(14)，ATR 為 true range 的14期簡單平均，做多減、做空加；停損距 Entry 至少0.1R。

【出場】確認棒的下一根起逐根判斷：
- 做多：收盤>C 價，或收盤<D 價，出場；low≤停損或 high≥T3 也出場。
- 做空：收盤<C 價，或收盤>D 價，出場；high≥停損或 low≤T3 也出場。
- 時間出場：持倉滿300根，或距 D 的根數達到 D 與 X 的間距，出場。