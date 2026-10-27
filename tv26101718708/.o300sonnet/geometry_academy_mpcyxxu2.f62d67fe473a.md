【共用定義】
- 一般 pivot：pivothigh(high,8,8)、pivotlow(low,8,8)，右側 8 根收完才確認。
- 一般 ATR：ATR(14)。

【1 一雲帶區間判斷（Ichimoku）】
- tenkan=(最近9根最高high+最近9根最低low)/2；kijun=同法取26根；senkouA=(tenkan+kijun)/2；senkouB=同法取52根。
- 當根雲帶採用26根前的 senkouA、senkouB：雲頂=max，雲底=min。
- 做多：close>雲頂。做空：close<雲底。close 在雲內為不交易。
- 事件式進場：做多為 close 由下往上穿越雲頂；做空為 close 由上往下穿越雲底，均以收盤確認。

【2 Tenkan/Kijun】
- tenkan>kijun 指向做多；tenkan<kijun 指向做空；相等不動作。
- 事件式：tenkan 上穿 kijun 做多；tenkan 下穿 kijun 做空。
- READ 提示此交叉在雲內是雜訊，與雲帶方向同向時品質較高。可將其與判斷1的方向一致作為過濾。

【3 價值區（Volume Profile）】
- 取最近250根，區間 [最低low, 最高high] 切24格。
- 每根 K 的 volume 依其 high-low 與各格的重疊比例分配到各格；high=low 的 K 整筆放在 close 所在格。
- POC 為量最大格。從 POC 起，每次向上或向下擴一格（取量較大者，相等取上），直到累計量≥總量70%。
- VAH=區域最高格的上緣，VAL=區域最低格的下緣。
- close>VAH（溢價）指向做空；close<VAL（折價）指向做多；介於其間為公平區。

【4 Andrews Pitchfork 中線】
- 用 pivot 建立交替的高低錨點：同類型連續出現時，高點取較高者、低點取較低者來取代前一個。
- 取最近三個交替錨點 P0、P1、P2（時間順序，bar 位置 b、價格 p）。
- 中線斜率=((p1+p2)/2 - p0)/((b1+b2)/2 - b0)。
- 當根中線值=(p1+p2)/2 + 斜率×(當根bar - (b1+b2)/2)。
- close>中線值指向做多；close<中線值指向做空。

【5 雙頂/雙底（頸線突破）】
- 最近三個錨點為 高-低-高：若 |高2-高1|≤0.6×ATR（取第二高確認前 8 根的 ATR），且頸線（中間低點）<兩高中較小者，則登錄為待確認雙頂。
- 最近三個錨點為 低-高-低：若 |低2-低1|≤0.6×ATR，且頸線（中間高點）>兩低中較大者，則登錄為待確認雙底。
- 做空：待確認雙頂且 close 下穿頸線（收盤確認）。
- 做多：待確認雙底且 close 上穿頸線（收盤確認）。
- 觸發後待確認狀態清除。
- 取消雙頂：close>max(兩高)+0.6×ATR。取消雙底：close<min(兩低)-0.6×ATR。
- 目標價：頸線 ∓ (兩峰平均與頸線的距離)，可作為出場。