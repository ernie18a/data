Calculation: Pivot = (high + low + close) / 3 of the previous completed bar of the higher daily timeframe
Calculation: BC = (high + low) / 2 of the previous completed bar of the higher daily timeframe
Calculation: TC = 2 × Pivot − BC
Calculation: CPR top = max(TC, BC)
Calculation: CPR bottom = min(TC, BC)
Long: close > TC AND low <= TC OR low <= BC OR close > CPR top AND previous close <= CPR top
Short: close < BC AND high >= BC OR high >= TC
Exit: long, close >= TC
Exit: short, close <= BC