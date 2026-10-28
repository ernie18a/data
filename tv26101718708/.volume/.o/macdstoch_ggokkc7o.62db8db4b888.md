Calculation: 14-period %K = stochastic %K from close, high, and low
Calculation: %D = 3-period simple moving average of 14-period %K
Calculation: Weighted %K = (14-period %K + 3 × 42-period %K + 9 × 126-period %K + 18 × 378-period %K) / 31
Calculation: Smoothed weighted %K = 30-period simple moving average of weighted %K
Calculation: MACD histogram = fast moving average of close minus slow moving average of close, minus a moving average of that difference; the slow lookback is longer than the fast lookback
Long: 50-bars-ago MACD histogram < 0 AND current MACD histogram is greater than or equal to its values 30, 20, 10, 5, 3, and 1 bars ago AND %D < 20 AND volume > prior-bar volume AND smoothed weighted %K > its prior-bar value AND smoothed weighted %K < 80 AND the long-entry eligibility latch is set (it is set by bearish MACD-histogram alignment, or by specified long exits, and cleared on long entry)
Exit: long, %D > 80
Exit: long, close < long entry price × (1 − stop-loss percentage) OR (smoothed weighted %K < 20 AND its prior-bar value > 20)
Exit: long, close > long entry price × (1 + profit-target percentage)
Exit: short, %D < 20
Exit: short, close > short entry price × (1 + stop-loss percentage) OR (smoothed weighted %K > 80 AND its prior-bar value < 80)
Exit: short, close < short entry price × (1 − profit-target percentage)