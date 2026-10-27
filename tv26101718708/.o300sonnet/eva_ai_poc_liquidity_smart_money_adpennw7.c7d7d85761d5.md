做多：收盤價由下往上穿越 VAH（前一根 close<=VAH，本根 close>VAH）。收盤價在 VAH 之上時，方向維持偏多（價格發現向上）。
做空：收盤價由上往下穿越 VAL（前一根 close>=VAL，本根 close<VAL）。收盤價在 VAL 之下時，方向維持偏空（價格發現向下）。
中性：VAL<=close<=VAH 為價值區內的平衡，不指向多空。從價值區外回到區內（前一根收盤在 VAH 之上或 VAL 之下，本根收在 [VAL,VAH] 內）是回到價值區的事件，不指向方向。
只用已收盤的 K 棒判斷。

VAH 與 VAL 的算法（以回測資料所有 K 棒為一個區間）：
1. 取區間內 volume>0 的 K 棒，rawHigh=最高 high，rawLow=最低 low。
2. 價格列數 N 依樣本數決定：<300 根為 36，<900 為 48，<2400 為 60，<6000 為 72，其餘為 80。列高 step=ceil(((rawHigh-rawLow)/(N-1))/mintick)*mintick，起點 low0=floor(rawLow/step)*step，列數=min(N, ceil((rawHigh-low0)/step))。
3. 每根 K 棒的 volume 依 high-low 範圍與各列的價格重疊比例分配到各列：該列分到的量=volume*重疊長度/(high-low)。若 high-low 近乎 0，整根量放在 close 所在列。
4. 各列加總為 rowVol。POC 列是 rowVol 最大的列，平手時取最靠近中間的列。
5. 價值區從 POC 列起算，累積量=POC 列量，目標=總量*70%。每次比較上方相鄰列與下方相鄰列的量，取較大者；相等時取距 POC 較近的列，距離也相等就取上方。若加入該列後累積量超過目標就停止，否則併入並繼續，直到累積量>=目標或已到邊界。
6. VAH=價值區最上列的上緣=low0+(上列索引+1)*step。VAL=價值區最下列的下緣=low0+下列索引*step。