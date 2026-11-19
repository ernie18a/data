Long: an enabled external asset has positive configured correlation AND its Rate of Change over P1 bars on T1 is > 0 OR it has negative configured correlation AND its Rate of Change over P1 bars on T1 is < 0
Short: an enabled external asset has positive configured correlation AND its Rate of Change over P1 bars on T1 is < 0 OR it has negative configured correlation AND its Rate of Change over P1 bars on T1 is > 0
Calculation: intermarket bias = sum over enabled external assets of 1 when (positive configured correlation AND Rate of Change over P1 bars on T1 > 0) OR (negative configured correlation AND Rate of Change over P1 bars on T1 < 0), otherwise −1
Long: at least one enabled external asset AND intermarket bias ≥ 0
Short: at least one enabled external asset AND intermarket bias < 0