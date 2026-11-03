Calculation: PUT profile VAH/VAL = upper/lower boundaries of the value area built from chart bars over a longer lookback; distribute each bar’s volume uniformly over its high–low range, divide the full price range into rows, start at the maximum-volume row, then add the adjacent row with greater volume until the target value-area volume is reached.
Calculation: CALL profile VAH/VAL = same value-area calculation over a shorter lookback than the PUT profile.
Long: HLC3 >= the shorter-lookback EMA of close OR HLC3 >= the longer-lookback EMA of close.
Short: HLC3 < the shorter-lookback EMA of close OR HLC3 < the longer-lookback EMA of close.
Exit: long, low <= PUT profile VAL OR high >= CALL profile VAH
Exit: short, high >= PUT profile VAH OR low <= CALL profile VAL