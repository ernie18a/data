【做多】以下為逐根計算，參數 RSI 長度=14、通道長度 L=5、自適應長度 A=12（L/A 可依週期調整：秒~5分 8/18、<30分 6/14、<4小時 5/12、4小時~日線 4/10、更長 3/8）。
1. H=rma(high,L)，Lo=rma(low,L)，half=(H-Lo)/2，mid=Lo+half。half 為 0 或無值時本根不判斷。
2. rsiH=RSI((high-mid)/half,14)，rsiL=RSI((low-mid)/half,14)。mx=max(rsiH,rsiL)，mn=min(rsiH,rsiL)。
3. 選值 chosen：mx>50 且 mn>50 取 mx；mx<50 且 mn<50 取 mn；其餘情況，若 |mx-50|<|mn-50| 取 mx，否則取 mn。
4. 高點樞紐：chosen[3] >= 最近 8 根 chosen 的最高值（含當根），樞紐值為 chosen[3]。低點樞紐：chosen[3] <= 最近 8 根 chosen 的最低值，樞紐值為 chosen[3]。
5. alpha=2/(A+1)。出現高點樞紐且其值>51.5 時，highEma = alpha*樞紐值 + (1-alpha)*前一個 highEma；前一個 highEma 無值時以樞紐值代替。其餘根維持上一個值。
6. 做多條件：highEma 已有值且 chosen > highEma。

【做空】
1. 步驟 1~4 與做多相同。
2. 出現低點樞紐且其值<48.5 時，lowEma = alpha*樞紐值 + (1-alpha)*前一個 lowEma；前一個 lowEma 無值時以樞紐值代替。其餘根維持上一個值。
3. 做空條件：lowEma 已有值且 chosen < lowEma。