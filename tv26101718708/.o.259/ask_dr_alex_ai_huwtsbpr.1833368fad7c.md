皆用已收盤K線計算，沒有出場判斷。
指標：ATR為14期Wilder ATR；EMA9、EMA21為收盤價指數均線。
單根K線量值：body=|close-open|；range=high-low；上影=high-max(open,close)；下影=min(open,close)-low。以下各條件成立時指向該方向，不成立則不指向。

做多（任一成立）：
1. 結構突破：close>open，body>=0.12*ATR，且close大於前20根K線的最高high。
2. 多頭吞噬：close>open，前一根close<open，且本根body上緣(max(open,close))>=前根body上緣、body下緣(min(open,close))<=前根body下緣。
3. 多頭光頭光腳大陽線：close>open，body/range>=0.75，上影/range<=0.12，下影/range<=0.12。
4. 多頭旗形突破：close>close[8]且close-close[8]>1.5*ATR，close大於前8根K線的最高high，close>EMA9，EMA9>EMA21，close>open，body>=0.12*ATR。

做空（任一成立，與做多鏡像）：
1. 結構跌破：close<open，body>=0.12*ATR，且close小於前20根K線的最低low。
2. 空頭吞噬：close<open，前一根close>open，且本根body上緣>=前根body上緣、body下緣<=前根body下緣。
3. 空頭光頭光腳大陰線：close<open，body/range>=0.75，上影/range<=0.12，下影/range<=0.12。
4. 空頭旗形跌破：close[8]-close>1.5*ATR，close小於前8根K線的最低low，close<EMA9，EMA9<EMA21，close<open，body>=0.12*ATR。

同一根K線同時出現多空條件時不判斷方向。