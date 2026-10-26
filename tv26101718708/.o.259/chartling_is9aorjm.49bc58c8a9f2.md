【Wave 計算】先把 open、high、low、close 各自做 EMA(17)，得到 sO、sH、sL、sC。haC=(sO+sH+sL+sC)/4。haO 第一根=(sO+sC)/2，之後 haO=(前一根 haO+前一根 haC)/2。haH=max(sH,haO,haC)，haL=min(sL,haO,haC)。waveHigh=HMA(haH,150)，waveLow=HMA(haL,150)。
【Flow 計算】flowBase=2*(前一根open+前一根close)-high-low-open。若 flowBase<low，令 flowBase=(flowBase+low)/2。若 flowBase>high，令 flowBase=(flowBase+high)/2。flowLine=EMA(flowBase,200)。
【做多判斷】做多：Wave 旗為綠色，即 low>waveHigh 且 high>waveHigh（整根K棒在 Wave 上方）。Flow 偏多：close>=flowLine，腹部為藍色。close>=flowLine 時，若 (close-flowLine) 比前一根的大，為深藍（強），否則為淺藍（弱）。
【做空判斷】做空：Wave 旗為紅色，即 high<waveLow 且 low<waveLow（整根K棒在 Wave 下方）。Flow 偏空：close<flowLine，腹部為紅橘色。close<flowLine 時，若 (close-flowLine) 比前一根的小，為紅（強），否則為橘（弱）。
【中性】K棒與 [waveLow,waveHigh] 區間重疊時，Wave 沒有方向（無旗）。
【過濾】Wave 與 Flow 同向時最明確（Wave 多且 Flow 偏多，或 Wave 空且 Flow 偏空）。兩者方向相反時視為衝突，不進場。