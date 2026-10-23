指標：
- 動能：取最近20根最高價最高值hi、最低價最低值lo，chMid=(hi+lo)/2；smaMid=SMA((high+low)/2,20)；chanRng=hi-lo，chanTR=max(chanRng,|hi-前收|,|lo-前收|)（無前收則用chanRng，若<1e-10改用當根真實波幅）；momRaw=(close-(chMid+smaMid)/2)/chanTR*100；mom=linreg(momRaw,20,0)；sig=SMA(mom,3)。
- Flux：up=RMA(max(high-前high,0),30)，dn=RMA(max(前low-low,0),30)；ratio=(up+dn<1e-10)?0:(up-dn)/(up+dn)；flux=RMA(ratio,15)*100。
- 成交量過濾：volAvg=SMA(volume,20)；若volume>0且volAvg>0則需volume>volAvg，否則視為通過。

做多：
1. mom 由下往上穿越 sig（前一根mom<=sig、本根mom>sig），且 mom<-40、flux<0、成交量過濾通過。
2. 常規看多背離：mom 由下往上穿越 sig 且 mom<-25；同類（mom<-25的上穿）上一次記錄點的最低價為P、當時sig為M；若本根low<P 且本根sig>M，做多（成立後清除記錄點；不成立則以本根low與sig覆蓋記錄點）。
3. 隱藏看多背離（續勢做多）：任何 mom 上穿 sig 的K線都記錄其low與sig；若本根為上穿，且上一次上穿記錄的low為P、sig為M，本根low>P 且本根sig<M，做多（成立後清除記錄點，否則覆蓋）。
4. 擠壓釋放方向預測：擠壓定義為 Welford樣本標準差(close,20)（除以n-1）< ATR(RMA真實波幅,20)*1.0（長度為20時倍數1.0）；前一根處於擠壓、本根不再擠壓即釋放；若 mom - mom[3根前] > 5 偏多。

做空：
1. mom 由上往下穿越 sig，且 mom>40、flux>0、成交量過濾通過。
2. 常規看空背離：mom 下穿 sig 且 mom>25；上一次同類記錄點的最高價為P、當時sig為M；本根high>P 且本根sig<M，做空（成立後清除記錄點，否則以本根high與sig覆蓋）。
3. 隱藏看空背離（續勢做空）：任何 mom 下穿 sig 的K線記錄其high與sig；本根為下穿，且上次記錄high為P、sig為M，本根high<P 且本根sig>M，做空（成立後清除，否則覆蓋）。
4. 擠壓釋放方向預測：釋放時 mom - mom[3根前] < -5 偏空。

出場：READ無獨立出場條件；原文提示 mom 下穿 sig 可作為多單出場、mom 上穿 sig 可作為空單出場。

方向傾向（僅標示偏多/偏空，非進場）：mom>0 且 flux>0 強多；mom<0 且 flux<0 強空；mom>0 但 flux<=0 弱多；mom<0 但 flux>=0 弱空。mom 上穿0偏多、下穿0偏空；flux 上穿0偏多、下穿0偏空；mom>sig 偏多、mom<sig 偏空。