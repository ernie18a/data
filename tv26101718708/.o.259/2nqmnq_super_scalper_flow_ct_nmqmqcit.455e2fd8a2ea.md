【通用】ATR=14根ATR；relVol=volume/20根均量；長箭頭需順向實體：做多要求close>open且close-open>=0.8*ATR，做空要求close<open且open-close>=0.8*ATR。均線EMA21=close的21期EMA。pivot=左右各N根的樞紐高/低，lastPL/prevPL為最近兩個樞紐低（lastPH/prevPH同理）。平均實體=實體|close-open|的14期SMA。多方吞噬=收陽且前一根收陰、實體>平均實體、close>open[1]且open<=close[1]（空方吞噬鏡像）；錘子=下影線>2*實體、上影線<0.3*實體、0<實體<平均實體（射擊之星為上下影線對調）。

【做多】滿足下列任一，且順向實體條件成立：
1. CHoCH：樞紐(3,3)的最近兩個高點遞減且最近兩個低點遞減（下降結構），且close>最近樞紐高點。
2. 一般RSI背離：RSI(14)；樞紐(2,2)，lastPL<prevPL且該兩樞紐處的RSI後者>前者。
3. 隱藏RSI背離：lastPL>prevPL且RSI在lastPL處<在prevPL處。
4. CAP投降反轉：最近3根內有一根陰線，relVol>=2.5且實體>=1.5*ATR，且close>close[1]。
5. VRZ-R：量能Bar=volume>1.8*均量20；取最近一根量能Bar的low為vrzLo、high為vrzHi、中點為vrzMid。條件：low<=vrzLo且close>vrzLo、(多方吞噬或錘子)、relVol>=1.5、|low-vrzLo|>=0.25*ATR、(close-low)>=0.55*(high-low)；若為趨勢市（10根效率比ER=|close-close[10]|/10根逐根漲跌絕對值和 > 0.25*ATR/ATR的50期SMA，上限0.65）則需多週期趨勢偏多。
6. VRZ-L：上升趨勢（ER>門檻且close>close[10]）、ADX(14)>=28、low<=vrzMid且close>vrzMid、(多方吞噬或收陽且實體>0.7*平均實體)、relVol>=1.2、close>EMA21。
7. CT TRAP（掃低反轉）：low<前20根最低價(不含本根)且close>該價；下影線>0.6*ATR；下影線/實體>=1.2；relVol>=1.7；本根range>1.3*range的20期SMA；下影線>其20期均值+1.5倍標準差；(high-close)... 對做多為(close-low)>=0.5*range。
8. CT DIV：同第2項一般RSI背離（多）。
9. CT VRZ回測：先前價格離所有近3個量能Bar中點都超過1.5*ATR後回來，low<=該Bar的low+0.5*ATR且close>該Bar的low。
CT類(7、8、9)額外過濾：ER判定為下降趨勢（ER>門檻且close<close[10]）或盤整（ER<=門檻且ATR<=ATR的50期SMA）；relVol>=0.5且ATR>=3點；ADX>=20或Hurst非持續；以及不是十字星。

【做空】鏡像：
1. CHoCH：樞紐高點與低點皆遞增，且close<最近樞紐低點。
2. 一般RSI背離：lastPH>prevPH且RSI在lastPH處<在prevPH處。
3. 隱藏RSI背離：lastPH<prevPH且RSI在lastPH處>在prevPH處。
4. CAP：最近3根內有陽線relVol>=2.0且實體>=1.5*ATR，且close<close[1]。
5. VRZ-R：high>=vrzHi且close<vrzHi、(空方吞噬或射擊之星)、relVol>=1.5、|high-vrzHi|>=0.25*ATR、(high-close)>=0.55*(high-low)；趨勢市需多週期偏空。
6. VRZ-L：下降趨勢、ADX>=28、high>=vrzMid且close<vrzMid、(空方吞噬或收陰且實體>0.7*平均實體)、relVol>=1.2、close<EMA21。
7. CT TRAP（掃高反轉）：high>前20根最高價(不含本根)且close<該價；上影線>0.6*ATR；上影線/實體>=1.2；relVol>=1.7；range>1.3*range20均；上影線>其20期均值+1.5倍標準差；(high-close)>=0.5*range。
8. CT DIV：同第2項（空）。
9. CT VRZ回測：先離開量能Bar中點區>1.5*ATR後，high>=該Bar的high-0.5*ATR且close<該Bar的high。
CT類過濾：上升趨勢或盤整，其餘同做多。

【出場】READ中的出場僅為進場時預設的固定止盈止損價位，無可由OHLCV與持倉方向逐根計算的比較條件。