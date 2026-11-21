Calculation: SAR_chart = PSAR(initial acceleration, acceleration step, maximum acceleration) on chart bars
Calculation: SAR_T1 = PSAR(initial acceleration, acceleration step, maximum acceleration) on T1 bars, read on chart bars from the still-forming T1 bar
Calculation: SAR_T2 = PSAR(initial acceleration, acceleration step, maximum acceleration) on T2 bars, read on chart bars from the still-forming T2 bar
Calculation: LongTrail = highest close since entry * (1 - trailing-stop offset percent)
Calculation: ShortTrail = lowest close since entry * (1 + trailing-stop offset percent)
Long: (higher-TF SAR not used for long OR close > SAR_T1) AND (chart-TF SAR not used for long OR close > SAR_chart) AND (lower-TF filter not enabled OR close > SAR_T2)
Short: (higher-TF SAR not used for short OR close < SAR_T1) AND (chart-TF SAR not used for short OR close < SAR_chart) AND (lower-TF filter not enabled OR close < SAR_T2)
Long: close > SAR_chart
Short: close <= SAR_chart
Long: close > SAR_T1
Short: close <= SAR_T1
Long: close >= SAR_chart
Short: close < SAR_chart
Exit: long, use stop loss AND (close <= entry price * (1 - stop-loss percent) OR use trailing stop AND close <= LongTrail)
Exit: long, use take profit AND close >= entry price * (1 + take-profit percent)
Exit: short, use stop loss AND (close >= entry price * (1 + stop-loss percent) OR use trailing stop AND close >= ShortTrail)
Exit: short, use take profit AND close <= entry price * (1 - take-profit percent)