Calculation: Camarilla H5 = T1 last completed bar high / T1 last completed bar low * T1 last completed bar close, evaluated on chart bars
Calculation: Camarilla H4 = T1 last completed bar close + range multiplier * (T1 last completed bar high - T1 last completed bar low) / 2, evaluated on chart bars
Calculation: Camarilla H3 = T1 last completed bar close + range multiplier * (T1 last completed bar high - T1 last completed bar low) / 4, evaluated on chart bars
Calculation: Camarilla L3 = T1 last completed bar close - range multiplier * (T1 last completed bar high - T1 last completed bar low) / 4, evaluated on chart bars
Calculation: Camarilla L4 = T1 last completed bar close - range multiplier * (T1 last completed bar high - T1 last completed bar low) / 2, evaluated on chart bars
Calculation: Camarilla L5 = T1 last completed bar close - (Camarilla H5 - T1 last completed bar close), evaluated on chart bars
Long: high >= Camarilla H4 OR low <= Camarilla L3
Short: high >= Camarilla H3 OR low <= Camarilla L4
Exit: long, high >= Camarilla H5
Exit: short, low <= Camarilla L5