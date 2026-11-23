Calculation: Last pivot high = PivotHigh(T1 high, pivot strength, pivot strength) if not NA, else Last pivot high[1]
Calculation: Last pivot low = PivotLow(T1 low, pivot strength, pivot strength) if not NA, else Last pivot low[1]
Calculation: Running high = T1 high if Running high[1] is NA OR (Structure trend[1] = -1 AND Structure trend = 1), else max(Running high[1], T1 high)
Calculation: Running low = T1 low if Running low[1] is NA OR (Structure trend[1] = 1 AND Structure trend = -1), else min(Running low[1], T1 low)
Calculation: Bull level = Last pivot high if Structure trend[1] = 0 OR PivotHigh(T1 high, pivot strength, pivot strength) is not NA, else Bull break level[1]
Calculation: Bull break level = Bull level if Structure trend[1] = 1 AND Structure trend = 1 AND T1 close <= Bull level, else NA
Calculation: Bear level = Last pivot low if Structure trend[1] = 0 OR PivotLow(T1 low, pivot strength, pivot strength) is not NA, else Bear break level[1]
Calculation: Bear break level = Bear level if Structure trend[1] = -1 AND Structure trend = -1 AND T1 close >= Bear level, else NA
Calculation: Bull MSS low = Running low if Structure trend[1] = -1 AND Structure trend = 1; (Last pivot low, or Running low if Last pivot low is NA) if Structure trend = 1 AND T1 close > Bull level; Bull MSS low[1] if Structure trend = 1; NA otherwise
Calculation: Bear MSS high = Running high if Structure trend[1] = 1 AND Structure trend = -1; (Last pivot high, or Running high if Last pivot high is NA) if Structure trend = -1 AND T1 close < Bear level; Bear MSS high[1] if Structure trend = -1; NA otherwise
Calculation: Structure trend = if Structure trend[1] is NA or 0: 1 if T1 close > Last pivot high, else -1 if T1 close < Last pivot low, else 0; if Structure trend[1] = 1: -1 if T1 close < Bull MSS low[1], else 1; if Structure trend[1] = -1: 1 if T1 close > Bear MSS high[1], else -1
Calculation: Bull gap formed = T1 low > T1 high[2] AND T1 low - T1 high[2] >= min FVG size * ATR(T1, ATR lookback)
Calculation: Bear gap formed = T1 high < T1 low[2] AND T1 low[2] - T1 high >= min FVG size * ATR(T1, ATR lookback)
Calculation: Open bull gaps = the most recent max tracked gaps of (Open bull gaps[1] minus gaps with T1 low <= their lower edge, plus a new gap with upper edge T1 low and lower edge T1 high[2] if Bull gap formed)
Calculation: Open bear gaps = the most recent max tracked gaps of (Open bear gaps[1] minus gaps with T1 high >= their upper edge, plus a new gap with upper edge T1 low[2] and lower edge T1 high if Bear gap formed)
Calculation: Bull retest = some gap in Open bull gaps[1] has lower edge < T1 low <= upper edge
Calculation: Bear retest = some gap in Open bear gaps[1] has lower edge <= T1 high < upper edge
Calculation: FVG event = 1 if Bull gap formed; else -1 if Bear gap formed OR Bear retest; else 1 if Bull retest; else FVG event[1]
Calculation: FVG event age = 0 if Bull gap formed OR Bear gap formed OR Bull retest OR Bear retest; else FVG event age[1] + 1
Long: Structure trend = 1 (last completed T1 bar)
Short: Structure trend = -1 (last completed T1 bar)
Long: FVG event = 1 AND FVG event age <= FVG freshness (last completed T1 bar)
Short: FVG event = -1 AND FVG event age <= FVG freshness (last completed T1 bar)