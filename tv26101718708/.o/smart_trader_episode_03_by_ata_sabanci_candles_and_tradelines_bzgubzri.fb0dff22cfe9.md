以下判斷全部以收盤已確定的K棒計算（偏移1，即不含最新一根）。

【單根K棒方向】
- range=high-low，body=|close-open|，上影=high-max(open,close)，下影=min(open,close)-low。bodyR=body/range*100，upperR=上影/range*100，lowerR=下影/range*100，range為0時三者皆為0。bull=close>open。
- 依序判斷，第一個符合者生效：
 1. bodyR<10：lowerR>65且upperR<15 → 偏多（蜻蜓十字）；upperR>65且lowerR<15 → 偏空（墓碑十字）；其餘中性。
 2. bodyR<35且|upperR-lowerR|<20 → 中性（紡錘）。
 3. bodyR>80 → bull則偏多，否則偏空。
 4. bodyR<40：lowerR>55且upperR<20 → 偏多（錘子）；upperR>55且lowerR<20 → bull偏多、否則偏空（倒錘）；upperR>45 → 偏空（長上影）；lowerR>45 → 偏多（長下影）；其餘中性。
 5. 其餘（一般K棒）→ bull偏多，否則偏空。

【量能壓力方向】
- 買量=volume*(close-low)/(high-low)，賣量=volume*(high-close)/(high-low)；high==low時各取volume的一半。
- buyPct=買量/(買量+賣量)*100，總量為0視為中性。buyPct>55 → 偏多（買壓）；buyPct<45 → 偏空（賣壓）；其餘中性。

【區塊（合成K棒）方向】
- 每5根K棒為一區塊，區塊0為最新5根，區塊1為再往前5根，依此類推。區塊的open取區塊最舊那根的open，close取最新那根的close，high為區塊最高，low為區塊最低。
- 區塊關係（區塊0對區塊1）：
 - high0<=high1且low0>=low1 → 內包，中性。
 - high0>high1且low0<low1 → 外包，區塊0的close>open則偏多，否則偏空。
 - 否則若|close0-open0|>1.3*|close1-open1|（吞噬）→ close0>open0偏多，否則偏空。
 - 其餘中性。
- 區塊0自身的形態方向，用上面「單根K棒方向」的規則，套用區塊的open、high、low、close計算。

【趨勢方向】
- 區塊中點mid=(區塊high+區塊low)/2。較新區塊的mid大於相鄰較舊區塊的mid → 上升（HH/HL）；小於 → 下降（LH/LL）；相等 → 盤整。
- 從最新區塊起，連續同方向的區塊合併為一段趨勢，最新一段的方向即目前趨勢。
- 該段兩條通道線的中點變化，經Yang-Zhang波動度換算成角度：角度=atan(中點價差/(單根波動度*sqrt(跨越K棒數)))。角度絕對值<=10度則改判為盤整。
- 目前趨勢為上升偏多，下降偏空。

【背離（與趨勢相反的量能）】
- 趨勢段內各區塊的買量總和減賣量總和（沿用上述買賣量）為趨勢delta。
- 上升趨勢且delta<0，指向賣方主導（偏空警示）；下降趨勢且delta>0，指向買方主導（偏多警示）。

【影線變化提示】
- 趨勢段內，區塊平均下影線（區塊內各K棒下影之平均）從最舊區塊到最新區塊增加超過15% → 偏多（買方支撐增強）；減少超過15% → 偏空（支撐轉弱）。
- 平均上影線增加超過15% → 偏空（上方賣壓增強）。