Calculation: Previous day high/low = high/low of the last completed daily bar
Calculation: Monday high/low = high/low of the current week's completed Monday daily bar
Long: Close > Monday high AND prior close <= Monday high AND Monday is complete AND current week is not complete
Short: Close < Monday low AND prior close >= Monday low AND Monday is complete AND current week is not complete
Long: Close > previous day high AND prior close <= previous day high AND intraday bar AND not the first bar of the day AND no earlier long signal this day
Short: Close < previous day low AND prior close >= previous day low AND intraday bar AND not the first bar of the day AND no earlier short signal this day