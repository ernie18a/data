【共用定義】日線由回測資料彙整：PDH/PDL=前一日最高/最低；PDH2/PDL2=前二日最高/最低；dATR=日線ATR(14)。VWAP=當日累計(hlc3×量)/累計量。rvol=volume/SMA(volume,20)。收盤位置=(close-low)/(high-low)。EMA一律用hl2。只在前一日為內包日(PDH<PDH2且PDL>PDL2)時評估，限常規交易時段，開盤前15分鐘及收盤前不評估；每個交易日每方向最多進場一次，兩次進場至少間隔6根。

【做多】以下全部在同一根收盤成立：
1. 觸發價=PDH，確認價=PDH+0.15×dATR。接受條件：連續2根收盤>PDH，或(收盤>確認價 且 rvol≥1.10 且 收盤位置≥0.65)。
2. 進場形態(任一)：(a)收盤上穿PDH後8根內，某根low≤PDH+0.12×dATR且收盤>PDH；(b)8根內K棒曾觸及[PDL,PDH]區間；(c)rvol≥1.55且收盤位置≥0.65；(d)上述確認價接受條件成立。
3. 收盤>VWAP。
4. 雲帶：EMA9>EMA21且收盤≥兩者較大者；EMA21>EMA55且收盤≥兩者平均；較高週期(1分→5、5分→15、15分→60、60分→240、更大→日)的EMA9>EMA21，且再高一級週期(≤5分→60、≤15分→240、≤4小時→日)的EMA21>EMA55。
5. RSI(收盤；週期≤1分用7、≤5分用9、其餘14)≥52且(高於前一根或≥56)，且<78。
6. EMA動能：EMA9>EMA21，兩線均不低於前一根，且(EMA9上穿EMA21後30根內，或收盤>EMA21)。
7. rvol≥1.10。
8. 預期R：(PDH+0.5×dATR−PDH)/(PDH−PDL)≥1.25，即0.5×dATR/(PDH−PDL)≥1.25。
9. 不追價：收盤−PDH≤0.45×dATR。
10. Strat：當日最高>PDH且當日最低≥PDL，或當日最高>PDH且最低<PDL，或收盤>PDH。

【做空】完全對稱：觸發價=PDL，確認價=PDL−0.15×dATR；連續2根收盤<PDL，或(收盤<確認價且rvol≥1.10且收盤位置≤0.35)；回測為收盤下破PDL後8根內high≥PDL−0.12×dATR且收盤<PDL，或8根內曾觸及[PDL,PDH]區間(12根內)，或rvol≥1.55且收盤位置≤0.35；收盤<VWAP；EMA9<EMA21且收盤≤兩者較小者、EMA21<EMA55且收盤≤兩者平均、兩個較高週期EMA皆空頭排列；RSI≤48且(低於前一根或≤44)且>22；EMA9<EMA21且兩線不高於前一根，且(下穿後30根內或收盤<EMA21)；rvol≥1.10；0.5×dATR/(PDH−PDL)≥1.25；PDL−收盤≤0.45×dATR；當日最低<PDL且最高≤PDH，或內外包皆破，或收盤<PDL。

【出場】進場價=entry，多單：T1=PDH+0.5×dATR，T2=PDH+1.0×dATR，T3=PDH+1.5×dATR，停損=PDL。T1前low≤PDL即停損出場；high≥T1後停損移到entry，之後任一根(T1之後的K棒)low≤entry出場；high≥T2後續抱，high≥T3全部出場。空單：T1=PDL−0.5×dATR，T2=PDL−1.0×dATR，T3=PDL−1.5×dATR，停損=PDH；T1前high≥PDH出場；T1後之後的K棒high≥entry出場；low≤T3全部出場。