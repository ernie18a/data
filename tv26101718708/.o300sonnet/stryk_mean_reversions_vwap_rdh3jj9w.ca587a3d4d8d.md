【共用指標】典型價tp=(high+low+close)/3。VWAP用最近N根(預設23根)滾動窗：vw=Σ(tp×volume)/Σvolume；sd=sqrt(max(0, Σ(tp²×volume)/Σvolume − vw²))。帶：上k=vw+k×sd，下k=vw−k×sd，k=1,2,3。sd>0且窗內至少12根才判斷。tick=最小跳動。以下皆在已收K判斷，進場價=收盤價，多空皆可，停損先於停利檢查，持倉滿100根以收盤價出場。

【A 均值回歸(主訊號)】
做空：近20根內曾有 high≥上2帶(武裝，並記錄武裝期間最高high)；當根 close<上1帶，且前一根close≥前一根的上1帶，且 close>vw → 做空。停損=武裝期間最高high+1tick；停利=進場當根的vw。做空後武裝清除。
做多：近20根內曾有 low≤下2帶(記錄最低low)；當根 close>下1帶，且前一根close≤前一根的下1帶，且 close<vw → 做多。停損=最低low−1tick；停利=進場當根的vw。
出場：多單 low≤停損出場，high≥停利出場；空單 high≥停損，low≤停利。(另有CE三角形，條件同上但不要求close與vw的位置關係。)

【B 突破(break)，順勢；同一根先判突破，無突破才判reclaim】
做多：由高到低找第一條被向上穿越的線：前收≤前一根該線且收盤>該線，線序為上3帶、上2帶、上1帶、vw。做空：下3帶、下2帶、下1帶、vw向下穿越的鏡像。多單停損=該K low−1tick；空單停損=high+1tick。停利：穿上3→上3+1×sd；穿上2→上3；穿上1→上2；穿vw→上1(空單鏡像向下)。

【C 收復(reclaim)，回歸】
做多：close<vw，且前收≤前一根下k帶、當根收盤>下k帶，依序檢查k=3,2,1；停利分別為下2帶、下1帶、vw。做空：close>vw，且前收≥前一根上k帶、當根收盤<上k帶，k=3,2,1；停利分別為上2帶、上1帶、vw。停損：多=近5根最低low−1tick，空=近5根最高high+1tick。

【B、C共用過濾：五項閘門至少通過3項，且停利方向正確(多單停利>close>停損)】
1 收盤確認：多單close≥穿越線+2tick且(close−low)/(high−low)≥0.6；空單close≤穿越線−2tick且(high−close)/(high−low)≥0.6。
2 量能：volume≥1.2×近期平均量(約近一段時間的volume簡單平均，20~300根)。
3 單根delta：多單需收紅(close>open；平盤時close>前收)，空單需收黑，視為delta占比100%≥10%。
4 壓力：近期(同VWAP窗)的有號量總和(紅K+volume、黑K−volume)方向與訊號同向。
5 趨勢：多單vw>12根前的vw；空單vw<12根前的vw。

【D 顏色多空】收盤>vw偏多、<vw偏空；(close−vw)/sd>1偏多、<−1偏空，介於之間中性。