【共用計算】ATR=14期Wilder ATR。range=high-low，body=|close-open|，bodyPct=body/range，上影=high-max(open,close)，下影=min(open,close)-low，收盘位置=(close-low)/range。
多方反應K：(A)陽線且下影>=1.2*body且收盘位置>=0.65；(B)陽線且range>=0.8*ATR且bodyPct>=0.6；(C)close>max(high[1],high[2])。三者任一成立即可。
空方反應K：(A)陰線且上影>=1.2*body且收盘位置<=0.35；(B)陰線且range>=0.8*ATR且bodyPct>=0.6；(C)close<min(low[1],low[2])。三者任一成立即可。

【支撐/壓力箱（用同週期K線）】
支撐箱：出現樞紐低點（low[3]為前後各3根中的最低）時建立，下緣B=low[3]，上緣T=max(min(open[3],close[3]), B+0.1*ATR[3])。出現新樞紐低點即取代舊箱；close<B時箱消失。
壓力箱：出現樞紐高點（high[3]為前後各3根中的最高）時建立，上緣T=high[3]，下緣B=min(max(open[3],close[3]), T-0.1*ATR[3])。出現新樞紐高點即取代舊箱；close>T時箱消失。
以下判斷皆用收盘確認後的K線。

【做多】
用當前支撐箱(T,B)，touched=(high>=B 且 low<=T)。下列任一成立即為反應：
1) low<B 且 close>T 且為多方反應K；
2) touched 且 close>T 且 close[1]>T 且 close>open；
3) close>T 且 close[1]<=T 且為多方反應K；
4) touched 且 close>T 且為多方反應K(A)；
5) touched 且 close>T 且為多方反應K(B)或(C)。
同一個支撐箱只取第一次反應。若同一根K線也同時觸發壓力箱的做空反應，則兩邊都不做。

【做空】
用當前壓力箱(T,B)，touched同上。下列任一成立即為反應：
1) high>T 且 close<B 且為空方反應K；
2) touched 且 close<B 且 close[1]<B 且 close<open；
3) close<B 且 close[1]>=B 且為空方反應K；
4) touched 且 close<B 且為空方反應K(A)；
5) touched 且 close<B 且為空方反應K(B)或(C)。
同一個壓力箱只取第一次反應。若同一根K線也同時觸發支撐箱的做多反應，則兩邊都不做。

【出場】
多單：收盘<進場時那個支撐箱的下緣B，或出現做空訊號，或該支撐箱被新樞紐低點形成的新支撐箱取代，三者任一即出場。
空單：收盘>進場時那個壓力箱的上緣T，或出現做多訊號，或該壓力箱被新樞紐高點形成的新壓力箱取代，三者任一即出場。

【輔助方向標示（顏色/文字標示，方向同上）】
趨勢偏向：close[1]>=EMA50(close)[1] 為偏多，否則偏空。
結構AMD（只用上述同週期箱）：
- 偏多武裝：支撐箱出現第一次反應，或出現支撐箱掃破收回（做多反應1）；偏空武裝為壓力箱的對應情形，兩者互斥，新事件覆蓋舊事件。
- 偏多派發（指向多）：偏多武裝中，close 向上突破前一根的壓力箱上緣（close>T[1] 且 close[1]<=T[1]），且為陽線並符合多方反應K(B)，或為陽線且符合(C)。
- 偏空派發（指向空）：偏空武裝中，close 向下突破前一根的支撐箱下緣（close<B[1] 且 close[1]>=B[1]），且為陰線並符合空方反應K(B)，或為陰線且符合(C)。
- 掃破收回支撐箱=低位操縱，指向多；掃破收回壓力箱=高位操縱，指向空。
- 超過250根K線沒有新事件，或出現反向突破並伴隨反向動能，狀態重設為無方向。