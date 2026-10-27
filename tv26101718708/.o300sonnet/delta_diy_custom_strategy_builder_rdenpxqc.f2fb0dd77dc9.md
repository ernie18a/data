做多與做空都要「主訊號」和下列所有過濾同時成立才進場。沒有獨立的出場判斷，反向訊號成立時即反向。

主訊號用 Hull 均線：HMA = WMA(2*WMA(close,27) - WMA(close,55), 7)。HMA > 2 根前的 HMA 為多，HMA < 2 根前的 HMA 為空。主訊號必須已連續成立不超過 5 根，也就是主訊號出現後最多再等 5 根其他條件才會成立，過期就作廢。

做多的過濾：
1. close > EMA(close,200)。
2. EMA(close,50) 在本根向上穿越 EMA(close,200)，也就是上一根 EMA50 <= EMA200，本根 EMA50 > EMA200。
3. RQK 核回歸值上升。核回歸值 yhat = Σ(close[i]*w_i)/Σw_i，i 取 0 到 26，w_i = (1 + i²/(2*8*8²))^(-8)。條件是本根 yhat > 上一根 yhat。
4. CCI > 100。CCI = (hlc3 - SMA(hlc3,20)) / (0.015 * 20 期平均絕對離差)。
5. DMI：+DI = 100*RMA(上升動能,10)/RMA(TR,10)，-DI 同理用下降動能，ADX = 100*RMA(|+DI - -DI|/(+DI + -DI),5)。上升動能是 high 的變化量，且該變化量須大於 low 下降量與 0。需 +DI > -DI 且 ADX >= 20。再依 ADX 週期狀態加條件。ADX 上穿 20 設為週期 1，下穿 20 設為週期 -1，其餘沿用前值。週期 -1 時另需 +DI - -DI > 1。週期 1 時另需 +DI - -DI > 1、ADX < 55，且 ADX 大於前一根，或 +DI 上升且 -DI 下降。
6. 隨機指標：K = SMA(stoch(close,high,low,14),3)，D = SMA(K,3)，需 K > D。
7. CMF > 0。CMF = Σ20 期[(2*close - low - high)/(high - low)*volume] / Σ20 期 volume，high 等於 low 時該項為 0。

做空的條件是上述的鏡像，過濾全部反向：
- 主訊號為 HMA < 2 根前的 HMA。
- close < EMA200。
- EMA50 在本根向下穿越 EMA200。
- RQK 核回歸值下降，即 yhat < 上一根 yhat。
- CCI < -100。
- DMI 需 -DI > +DI 且 ADX >= 20。週期 -1 時另需 -DI - +DI > 1。週期 1 時另需 -DI - +DI > 1、ADX < 55，且 ADX 大於前一根，或 +DI 下降且 -DI 上升。
- K < D。
- CMF < 0。