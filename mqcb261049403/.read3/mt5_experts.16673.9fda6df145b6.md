Calculation: JJRSX color state = 4 if JJRSX(close, parameters) is rising and above the upper threshold; 3 if rising otherwise; 0 if falling and below the lower threshold; 1 if falling otherwise; 2 if unchanged
Long: JJRSX color state > 2
Short: JJRSX color state < 2
Long: X2MA(close, parameters) falls on chart bars using the selected T1 bar value; the signal-bar offset selects completed or forming data
Short: X2MA(close, parameters) rises on chart bars using the selected T1 bar value; the signal-bar offset selects completed or forming data
Long: X2MA(close, parameters) rises on T1 bars AND the preceding JJRSX color state > 2 AND the current JJRSX color state < 3; the signal-bar offset selects completed or forming data
Short: X2MA(close, parameters) falls on T1 bars AND the preceding JJRSX color state < 2 AND the current JJRSX color state > 1; the signal-bar offset selects completed or forming data
Exit: long, X2MA(close, parameters) falls on T1 bars OR the preceding JJRSX color state < 2; the signal-bar offset selects completed or forming data
Exit: short, X2MA(close, parameters) rises on T1 bars OR the preceding JJRSX color state > 2; the signal-bar offset selects completed or forming data