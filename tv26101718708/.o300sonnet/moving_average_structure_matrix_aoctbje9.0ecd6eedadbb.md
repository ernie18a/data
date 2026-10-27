【共用計算】全部用收盤價。MA：EMA5、EMA10、EMA20、SMA50、SMA100、SMA200，由快到慢排名 1~6。ATR=ATR(14)。D(x)=x/ATR。快組=前 4 條，慢組=SMA100 與 SMA200。MA 中心=6 條平均。束上緣、下緣=6 條 MA 的最大、最小值。前 250 根以上資料備齊後才算有效。
1) 排列分數 order：對 15 組 (快 i、慢 j) 算 g=D(MA_i−MA_j)。g>0.03 記 +1，g<−0.03 記 −1，其餘記 0。權重=|排名差|。order=100×Σ(權重×記號)/Σ權重。
2) 斜率：s_k=D(MA_k−MA_k[5])。slopeCoh=100×Σs/Σ|s|，分母為 0 時取 0。slowSlope 的算法同 slopeCoh，只取 SMA100 與 SMA200。slopeEnergy=min(100,100×mean|s|/0.3)。
3) 快慢價差：cohortScore=clamp(100×D(快組平均−慢組平均)/0.3, −100, 100)。
4) bias 分數=0.45×order+0.30×slopeCoh+0.25×cohortScore。分數≥22 則 bias=+1，≤−22 則 bias=−1，其餘為 0。
5) widthNorm=D(束上緣−束下緣)。widthRank=widthNorm 在 250 根內的 percentrank。幾何寬度變化 geo=(束寬[現在]−束寬[3 根前])/現在 ATR。重排率 reorderRate：對各 MA 組取最近一次非 0 的 g 記號，記號與前次相反就算 1 次重排。reorderRate=100×近 50 根重排總數/(15×50)。
6) 壓縮 compression：widthRank≤18 且 slopeEnergy≤32 且 |order|≤35 且 reorderRate<5。
7) 狀態優先序：壓縮 > 釋放 > 回測 > 減速 > 擴張。
- 釋放：bias≠0，且前 1~3 根內出現過壓縮，且 bias×order≥48，且 widthNorm−widthNorm[3]≥0.005，且 geo≥0.005（兩者都要成立）。另外，centroidSlope=D(中心−中心[5])，加速度=centroidSlope−centroidSlope[5]，bias×加速度≥0。
- 回測：bias≠0，收盤在束下緣與上緣之間，bias×order≥25，bias×slowSlope≥15，且不是釋放。
- 減速：bias≠0，bias×order≥25，且 (slopeEnergy≤5 根前的值−8，或 |slopeCoh|≤5 根前的值−10，或 widthNorm−widthNorm[3]≤−0.005 且 geo≤−0.005)，且不是釋放與回測。
- 擴張：bias≠0，bias×order≥62，bias×slopeCoh≥45，多方收盤≥中心、空方收盤≤中心，且不是釋放、回測、減速。
狀態以 (bias, 狀態類別) 為準，與上一根不同才算進入新狀態。

【進場判斷】
A. 釋放：進入釋放狀態那根收盤，bias=+1 做多，bias=−1 做空。
B. 擴張：進入擴張狀態那根收盤，bias=+1 做多，bias=−1 做空。擴張只在目前沒有循環、bias 與循環方向不同，或循環已完成回收時，才會開新循環。
C. 循環：釋放與（符合條件的）擴張進入時，開一個方向=bias 的循環。
D. 首次觸碰（方向標示）：循環開啟後的下一根起，若尚未觸碰、bias=循環方向，且 low≤前一根束上緣、high≥前一根束下緣，記為首次觸碰，方向=循環方向（多方循環指向做多，空方循環指向做空）。同時凍結當時的前一根束上緣 H 與下緣 L。
E. 回測回收：觸碰之後的那些根，若尚未回收、bias=循環方向，且 循環方向×order≥25，則：
- 多方循環：收盤>H 且前一根收盤≤H，做多。
- 空方循環：收盤<L 且前一根收盤≥L，做空。
觸碰與回收不可同一根。回收價 R=H（多）或 L（空）。
F. 伸展：extGap=D(收盤−快組平均)。bias×extGap≥2，且前一根不符合同方向，則 bias=+1 做多，bias=−1 做空。

【出場判斷】
1. 循環失敗：循環存續中，下一根起檢查，符合任一項就出場，方向與循環相反。
- bias=−循環方向。
- 多方循環：收盤<前一根慢組平均，且 (order<10 或 slowSlope≤−5)。
- 空方循環：收盤>前一根慢組平均，且 (order>−10 或 slowSlope≥5)。
失敗後循環結束（超過 500 根也結束）。
2. 回收檢查點失守：回收後 20 根內，多單任一根收盤<R、空單任一根收盤>R，就平倉。