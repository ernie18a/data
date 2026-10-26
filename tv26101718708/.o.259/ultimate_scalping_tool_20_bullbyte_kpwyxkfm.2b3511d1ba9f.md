【指標計算】
1. DER：net=close-close[14]；path=近14根 |close[i]-close[i+1]| 加總；ER=|net|/max(path,0.0001)，net>=0 取正號、否則取負號；DER=EMA3(ER)。持續計數 p：DER>0 加1、DER<0 減1、DER=0 歸0，限制在±30。normDER=DER*(0.6+0.4*min(|p|/15,1))。
2. AMVS：atr=ATR14(RMA)；vr=atr/max(SMA50(atr),0.0001)。rsi 取值：vr>1.5 用RSI8，vr>1.0 用RSI14，其餘用RSI21。AMVS=tanh((rsi-50)/50/clamp(vr,0.5,2.5)*1.5)。
3. VRI：
- A=(ATR14/close - 近100根最小值)/max(最大值-最小值,0.0001)*2-1，最大值與最小值取 ATR14/close 近100根。
- B=tanh(3*(ATR5-ATR20)/max(ATR20,0.0001))。
- bbw=4*stdev20(close)/max(SMA20(close),0.0001)；C=(bbw-近100根最小)/max(近100根最大-最小,0.0001)*2-1。
- VRI=tanh(1.2*(0.4A+0.35B+0.25C))。
4. COFP：
- cp=(close-low)/max(high-low,0.0001)；c1=tanh(2*EMA3(2cp-1))。
- c2=tanh(200*((close-close[3])/max(close[3],0.0001))*volume/max(SMA20(volume),1))。
- abs=(volume/max(SMA14(volume),1)>1.5) 且 (|close-open|/max(high-low,0.0001)<0.35)。c3：abs 且 close>open 為-0.3；abs 且 close<=open 為+0.3；非abs 為0。
- COFP=EMA2(0.5c1+0.35c2+0.15c3)。
5. 狀態：
- COIL = |DER|<0.2 且 VRI<-0.2 且 |COFP|>0.2。
- TREND UP = 非COIL 且 DER>0.3 且 AMVS>0 且 VRI>-0.1。
- TREND DOWN = 非COIL 且 DER<-0.3 且 AMVS<0 且 VRI>-0.1。
- 其餘為 RANGE。
6. 權重(wDER,wAMVS,wVRI,wCOFP)：COIL=(0.15,0.20,0.30,0.35)；TREND=(0.40,0.30,0.20,0.10)；RANGE=(0.15,0.35,0.15,0.35)。
7. osc=100*(wDER*normDER+wAMVS*AMVS+wVRI*VRI+wCOFP*COFP)。FM=osc/100*(1+(min(volume/max(SMA20(volume),1),2)-1)*0.3)。fscMA=EMA10(FM)。ma1=EMA5(FM)，ma2=EMA10(FM)，ma3=EMA21(FM)。

【做多判斷】（任一成立即指向做多）
- FM>fscMA（翻多為FM由下穿越fscMA）。若當根為abs（量能吸收），該根標為紫色，不標示多空。
- ma1>ma2>ma3（多頭排列）。
- 狀態為 TREND UP。
- 看漲背離 DIV+：osc 的 pivot low（左5右2，於右側2根後確認）高於前一個 osc pivot low，且該 pivot 的 low 低於前一個 pivot 的 low；兩 pivot 相距5~60根；同類訊號至少間隔10根。
- 隱藏看漲背離 H+：條件同上，但該 pivot 的 low 高於前一個 pivot 的 low，且 osc 低於前一個 osc pivot low。

【做空判斷】（任一成立即指向做空）
- FM<fscMA（翻空為FM由上穿越fscMA）。若當根為abs，標紫色，不標示多空。
- ma1<ma2<ma3（空頭排列）。
- 狀態為 TREND DOWN。
- 看跌背離 DIV-：osc 的 pivot high（左5右2，於右側2根後確認）低於前一個 osc pivot high，且該 pivot 的 high 高於前一個 pivot 的 high；兩 pivot 相距5~60根；同類訊號至少間隔10根。
- 隱藏看跌背離 H-：條件同上，但該 pivot 的 high 低於前一個 pivot 的 high，且 osc 高於前一個 osc pivot high。

【出場判斷】
- 持多時，出現上述任一做空判斷即為反向訊號，可視為出場。
- 持空時，出現上述任一做多判斷即為反向訊號，可視為出場。