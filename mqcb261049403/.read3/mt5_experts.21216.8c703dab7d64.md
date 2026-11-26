Calculation: K = 33 - risk parameter
Calculation: Trend = 0 initially; on each bar retain the preceding Trend, set Trend to -1 if Williams %R < -100 + K, then set Trend to +1 if Williams %R > -K
Long: Trend > 0
Short: Trend < 0
Long: X2MA line value > its value on the preceding bar
Short: X2MA line value < its value on the preceding bar
Long: On each T1 indicator bar close, the preceding completed bar's indicator color code < 2 AND the just-completed bar's indicator color code > 1 AND first-system long-entry permission is enabled
Short: On each T1 indicator bar close, the preceding completed bar's indicator color code > 2 AND the just-completed bar's indicator color code < 3 AND first-system short-entry permission is enabled
Exit: short, On each T1 indicator bar close, the preceding completed bar's indicator color code < 2 AND (first-system long-entry permission is disabled OR the just-completed bar's indicator color code <= 1)
Exit: long, On each T1 indicator bar close, the preceding completed bar's indicator color code > 2 AND (first-system short-entry permission is disabled OR the just-completed bar's indicator color code >= 3)
Long: On each T2 indicator bar close, the preceding completed bar's indicator color code = 1 AND the just-completed bar's indicator color code != 1 AND second-system long-entry permission is enabled
Short: On each T2 indicator bar close, the preceding completed bar's indicator color code = 2 AND the just-completed bar's indicator color code != 2 AND second-system short-entry permission is enabled
Exit: short, On each T2 indicator bar close, second-system short-close permission is enabled AND the preceding completed bar's indicator color code = 1 AND (second-system long-entry permission is disabled OR the just-completed bar's indicator color code = 1)
Exit: long, On each T2 indicator bar close, second-system long-close permission is enabled AND the preceding completed bar's indicator color code = 2 AND (second-system short-entry permission is disabled OR the just-completed bar's indicator color code = 2)