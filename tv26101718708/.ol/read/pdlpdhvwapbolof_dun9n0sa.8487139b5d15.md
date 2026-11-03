Calculation: PDH = high of the last completed daily bar (higher timeframe)
Calculation: PDL = low of the last completed daily bar (higher timeframe)
Calculation: PWH = high of the last completed weekly bar (higher timeframe)
Calculation: PWL = low of the last completed weekly bar (higher timeframe)
Calculation: VWAP slope (%) = (current chart-timeframe VWAP − VWAP from the longer lookback ago) / that earlier VWAP × 100
Long: close > PDH AND previous close <= PDH
Long: close > PDL AND previous close <= PDL
Long: close > VWAP AND close > open AND close < PDH AND each of the shorter setup-lookback prior bars closed below its corresponding VWAP
Long: close > PWH AND previous close <= PWH
Long: close > PWL AND previous close <= PWL
Short: high >= PDH AND close < PDH AND previous high < PDH
Short: close < PDH AND previous close > PDH AND a PDH breakout occurred within the recent sweep window
Short: close < PDL AND previous close >= PDL
Short: close < VWAP AND close < open AND close > PDL AND each of the shorter setup-lookback prior bars closed above its corresponding VWAP
Short: high >= PWH AND close < PWH AND previous high < PWH
Short: close < PWL AND previous close >= PWL
Exit: long, close > PDH AND VWAP slope (%) <= the slope threshold