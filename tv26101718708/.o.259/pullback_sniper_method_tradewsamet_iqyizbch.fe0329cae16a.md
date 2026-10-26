【指標】EMA(close,N)。ATR14=ta.atr(14)。實體=|close-open|。上影=high-max(open,close)，下影=min(open,close)-low。麥金利線：初值=EMA(close,100)，之後 M=M前+(close-M前)/(100*(close/M前)^4)。

【趨勢】多頭趨勢：EMA50>EMA200 且 close>EMA200 且 EMA50>EMA50[5]。空頭趨勢：EMA50<EMA200 且 close<EMA200 且 EMA50<EMA50[5]。

【突破建立 setup】只在沒有持倉、且沒有進行中 setup 時才建立。
- 多頭突破：多頭趨勢 且 close>前20根(不含當根)最高high 且 close>open 且 實體>=0.2*ATR14。建立做多 setup，記錄 start=當根，失效價=突破前12根(不含當根)最低low，pullback 旗標=假。
- 空頭突破：空頭趨勢 且 close<前20根(不含當根)最低low 且 close<open 且 實體>=0.2*ATR14。建立做空 setup，失效價=突破前12根最高high。

【setup 結束】每根先檢查，符合即取消 setup(之後可建立新 setup)：
- 距 start 超過60根。
- 做多 setup 時 close<失效價；做空 setup 時 close>失效價。

【回踩觸碰】距 start>=2根，且該 setup 尚未觸碰。
- 做多：low<=EMA21 且 close>失效價。
- 做空：high>=EMA21 且 close<失效價。
符合則 pullback 旗標=真(可與確認同一根)。

【做多進場】以下全部成立，於該根收盤進場，進場價=close：
1. 有進行中的做多 setup，且 pullback 旗標為真。
2. 當根為多頭趨勢。
3. 確認(預設Balanced)：close>EMA21 且 close>open 且 (close>前一根high 或 下影>=0.5*實體)。
   - Fast：只需 close>EMA21 且 close>open。
   - Strict：close>EMA21 且 close>前一根high 且 close>open 且 實體>=0.25*ATR14。
4. |close-EMA21|<=1.0*ATR14。
5. 麥金利過濾(預設開)：|close-麥金利線|>=0.25*ATR14。
6. RSI過濾(預設關，開啟時)：RSI(close,14)>=50。
7. 冷卻：距上次進場訊號>=20根(或從未有過)。
8. 無持倉，且當根沒有剛平倉。
9. 方向鎖：若上一筆是做多且以TP3出場，則在出現做空進場前不得再做多。
進場後 setup 結束。

【做空進場】鏡像：有進行中的做空 setup 且 pullback 旗標為真；空頭趨勢；Balanced 確認：close<EMA21 且 close<open 且 (close<前一根low 或 上影>=0.5*實體)(Fast：close<EMA21 且 close<open；Strict：close<EMA21 且 close<前一根low 且 close<open 且 實體>=0.25*ATR14)；|close-EMA21|<=1.0*ATR14；麥金利過濾同上；RSI過濾(開啟時)RSI<=50；冷卻20根；無持倉；方向鎖：上一筆是做空且以TP3出場，則在出現做多進場前不得再做空。

【出場】進場時 R=2*ATR14(進場時)。
- 做多：停損=進場價-R；TP1=進場價+0.5R；TP2=進場價+1R；TP3=進場價+2R。
- 做空：停損=進場價+R；TP1=進場價-0.5R；TP2=進場價-1R；TP3=進場價-2R。
從進場後下一根起逐根判斷(用high/low)：記錄已觸及的最高TP階段(1/2/3)。
- 當根觸及TP與停損(同一根)：視為停損出場，並不更新TP階段。
- 多單 high>=TP3(空單 low<=TP3)且當根未觸停損：TP3出場。
- 多單 low<=停損(空單 high>=停損)：出場；若先前已觸及TP1/TP2，則為保護出場(按已達TP階段)，否則為停損出場。
- 觸及TP1/TP2但未觸停損或TP3時繼續持倉，沒有其他出場條件。