Calculation: Maximum opposing-candle volume = highest volume among the previous lookback bars whose close is lower than the close of the immediately older bar
Calculation: Minimum opposing-candle volume = highest volume among the previous lookback bars whose close is higher than the close of the immediately older bar
Calculation: Net buying pressure = volume × ((close − low) − (high − close)) / max(high − low, minimum tick size)
Long: close > previous bar close AND volume > maximum opposing-candle volume AND net buying pressure > its EMA
Short: close < previous bar close AND volume > minimum opposing-candle volume AND net buying pressure < its EMA