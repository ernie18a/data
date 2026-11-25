Calculation: Candle direction = 1 if close > open OR (close = open AND (AO > AO[1] OR AC > AC[1] OR (AO = AO[1] AND AC = AC[1]))); -1 if close < open OR (close = open AND AO <= AO[1] AND AC <= AC[1] AND (AO < AO[1] OR AC < AC[1]))
Long: Candle direction = 1 on chart bars
Short: Candle direction = -1 on chart bars
Long: Candle direction = 1 on chart bars taking values independently from the still-forming bar of each of T1–T10
Short: Candle direction = -1 on chart bars taking values independently from the still-forming bar of each of T1–T10