【做多】
先算 WVF 觸發 W：hc=近18根close最高；wvf=(hc-low)/hc*100；上緣=sma(wvf,16)+2*stdev(wvf,16)；區間=近40根wvf最高*0.85。W 同時成立：前一根 wvf>=前一根上緣 或 >=前一根區間；本根 wvf<上緣 且 <區間；low>前一根low；close>前一根high；close>close[2]；close<close[30] 或 close<close[12]。
設 W 最近一次發生在 a 根前，a 必須在 0 到 3 之間，才算武裝。
武裝後算分數：
- EMA：ema9>ema21 在最近 a+2 根內任一根成立，+1。
- VIDYA：close>vidya 在最近 a+2 根內任一根成立，+1。vidya：cmo=100*(20根上漲量和-20根下跌量和)/(兩者之和)，上漲量和與下跌量和取 close 逐根變動的正負部分；k=|cmo|/100；alpha=2/11；vidya=alpha*k*close+(1-alpha*k)*前值，首值為 close。
- OBV：obv 為累計值，close>=open 加 volume，否則減 volume。obv>obv[8]，+1。
- DELTA：ema(close>=open?volume:-volume,14)>0 在最近 a+2 根內任一根成立，+1。
- TQI>=0.35，+1。TQI=(ER+volQ+strQ+momQ)/4。ER=|close-close[20]|/近20根|逐根close變動|之和；volQ=clamp((atr20/sma(atr20,40)-0.5)/1,0,1)；strQ=clamp(((close-sma(close,50))/atr20+2)/4,0,1)；momQ=clamp(((close-close[14])/close[14]*100+5)/10,0,1)。
- 波動偏高：percentrank(atr10,100)>=66.7，+1。
分數>=1 即做多。分數>=2 且 ADX(14)<25 為 FULL，分數>=2 為 SCALE，其餘為 BASE。
降級：若最近 a+2 根內任一根 close<=sma(close,20)-2*stdev(close,20)，且等級大於 BASE，則等級降一級。降級後仍>=BASE 就做多。
只在等級由 0 變成大於 0 的那根進場。
其他偏多標示：
- 動量震盪：ema(close,3) 上穿 sma(close,20)，close>sma(close,20)，AO=sma(hl2,5)-sma(hl2,34)>=0 且 AO>前值。
- CVI 低點：cvi=(close-最低3根low)/(最高3根high-最低3根low)。cvi 前值<=0.57 且本根>0.57。
- MBI 偏多：mom=close-close[10]；norm=mom/ema(high-low,10)*100。up=max(norm,0)，dn=min(norm,0)。upB=max(hma(sum(up,5),10),0)，dnB=max(hma(-sum(dn,5),10),0)。bound=ema(avg(upB,dnB),30)+3*stdev(avg(upB,dnB),30)。dnB 轉為下降（crossunder 自己前值）且 dnB>bound 且 dnB>upB。

【做空】
沒有獨立的進場流程，只有偏空標示：
- 動量震盪：ema(close,3) 下穿 sma(close,20)，close<sma(close,20)，AO<0 且 AO<前值。
- CVI 高點：cvi 前值>=0.43 且本根<0.43。
- MBI 偏空：upB 轉為下降（crossunder 自己前值）且 upB>bound 且 upB>dnB。

【出場（針對多單）】
三種出場訊號，持倉須超過 6 根才計入：
1. 布林跌破：close<=sma(close,20)-2*stdev(close,20)。
2. WVF 頂：t=(最低18根close-high)/最低18根close*100；下緣=sma(t,16)-2*stdev(t,16)；區間=最低40根t*0.85。前一根 t<=前一根下緣 或 t<=前一根區間，且本根 t>下緣 且 t>區間。
3. CVI 頂：cvi 前值>=0.43 且本根<0.43。
出場規則：
- 單一種訊號出現，減半出場。
- 3 根內出現兩種不同訊號，全部出場。
- 進場後 12 根視為持倉中。