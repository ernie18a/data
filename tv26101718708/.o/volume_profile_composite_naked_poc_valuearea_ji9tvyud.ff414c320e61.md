【成交量買賣拆分】dP=close−前一根close；sigma=sqrt(SMA20(volume·dP²)/SMA20(volume))，若無值或為0則改用dP的20根標準差；buyFrac=1/(1+exp(−1.702·clamp(dP/sigma,−8,8)))，sigma無效時改用 close>=open 為1、否則為0。CVD=累計加總((2·buyFrac−1)·volume)。

【做多／做空判斷1：CVD背離】priceRising = close>20根前close；cvdRising = CVD>20根前CVD。
- 做空：priceRising 且 非cvdRising（價漲、CVD未跟漲，看空背離）。
- 做多：非priceRising 且 cvdRising（價未漲、CVD上升，看多背離）。
- 以背離剛成立的那一根為訊號。

【做多／做空判斷2：趨勢狀態】
- ER=|close−close[14]|/最近14根|close−前一根close|之和（和為0時ER=0）。
- ADX為DMI(14,14)的ADX。
- 趨勢成立 = ADX>20 且 ER>0.35。
- 做多：趨勢成立且 close>EMA50（順勢做多）。
- 做空：趨勢成立且 close<=EMA50（順勢做空）。
- 過濾：波動叢集（hawk=hawk[1]·exp(−0.2)+|ln(close/前一根close)|；hawk對100根的z分數>1.5）且趨勢不成立時，視為震盪劇烈，不做單。

【做多／做空判斷3：VWAP位置】
- VWAP的價格取hlc3；遇到新的擺動低點或高點（pivot左右各21根）就重新錨定，兩次錨定至少間隔10根。
- 做多：close>=VWAP。
- 做空：close<VWAP。

【做多／做空判斷4：前日價值區翻轉】
- 每日以日內各根high-low區間，把該根成交量平均分配到最多16個價格點，累積成量分布，取量最大處為POC。
- 從POC向外擴張，每次加入量較大的那一側，直到涵蓋70%總量，得到前一日VAH與VAL。
- 做多：連續2根收盤 close>前日VAH·1.003，之後視為支撐偏多；收盤跌回前日VAH以下，多方判斷失效。
- 做空：連續2根收盤 close<前日VAL·0.997，之後視為壓力偏空；收盤站回前日VAL以上，空方判斷失效。

【出場】以上各判斷的反向條件成立，或失效條件出現時，視為出場。