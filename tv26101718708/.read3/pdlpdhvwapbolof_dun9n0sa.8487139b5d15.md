Calculation: prior day high = high(T1 bars, last completed bar)
Calculation: prior day low = low(T1 bars, last completed bar)
Calculation: prior week high = high(T2 bars, last completed bar)
Calculation: prior week low = low(T2 bars, last completed bar)
Calculation: VWAP = VWAP(typical price)
Calculation: VWAP slope = ROC(VWAP, VWAP slope lookback)
Calculation: closed below VWAP over setup bars = close[i] < VWAP[i] for every i from 1 to VWAP setup bars
Calculation: closed above VWAP over setup bars = close[i] > VWAP[i] for every i from 1 to VWAP setup bars
Long: close crosses above prior day high
Long: close crosses above prior day low
Long: close crosses above prior day low AND BARSSINCE(close crosses below prior day low) <= sweep window bars
Long: close crosses above prior week high
Long: close crosses above prior week low
Long: closed below VWAP over setup bars AND close > VWAP AND close > open AND close < prior day high
Long: close > prior day high AND VWAP slope > VWAP slope threshold AND close > VWAP
Short: high >= prior day high AND close < prior day high AND high[1] < prior day high
Short: close crosses below prior day low
Short: close crosses below prior day high AND BARSSINCE(close crosses above prior day high) <= sweep window bars
Short: high >= prior week high AND close < prior week high AND high[1] < prior week high
Short: close crosses below prior week low
Short: closed above VWAP over setup bars AND close < VWAP AND close < open AND close > prior day low
Short: close < prior day low AND VWAP slope < negative VWAP slope threshold AND close < VWAP
Exit: long, close > prior day high AND VWAP slope <= VWAP slope threshold