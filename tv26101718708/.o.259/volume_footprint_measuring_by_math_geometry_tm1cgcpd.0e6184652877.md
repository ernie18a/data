買賣量估算（只用回測資料）：range=high-low；buy=volume*(close-low)/range，range為0時buy=volume/2；sell=volume-buy。

1. 單根多空：buy>=sell判做多，buy<sell判做空（等同close在high-low中點之上或之下）。lead%=|buy-sell|/volume*100。

2. 區間失衡方向（取最近23根）：
- tilt=100*(Σbuy-Σsell)/(Σbuy+Σsell)。
- 每根有range的K線，buy分量是以mu_B=low+(close-low)/2為中心的常態分布，sell分量是以mu_S=close+(high-close)/2為中心的常態分布。sigma=range/3，兩者都截斷在[low,high]並正規化為總量等於該根buy或sell。
- range為0的K線，buy與sell全部放在close一點。
- 各根相加得到buy曲線與sell曲線，各自除以自己的總量後正規化。
- OVL=兩條正規化曲線逐價取較小值的積分（含兩側在同一價的點質量取小值）。
- OVL<0.75（失衡）且tilt>=5判做多；OVL<0.75且tilt<=-5判做空；OVL>=0.75或|tilt|<5不判方向。

3. 窗口量價偏向（取最近5根，須與當前價所在±5個最小跳動單位的價格範圍重疊）：
- 每根的buy、sell依上述常態分布，按每格一個最小跳動單位分配到各價格列。
- 各列把5根的buy與sell分別加總。
- 買方失衡：某列buy總和>0且大於下一列（低一格）sell總和*3，判做多。
- 賣方失衡：某列sell總和>0且大於上一列（高一格）buy總和*3，判做空。
- 以buy加sell總量最大的列為中心（POC），向上與向下各取第一個出現失衡的列。
- POC列的buy總和>sell總和偏做多，反之偏做空，相等不判方向。