Calculation: Rolling VWAP = sum(((high + low + close) / 3) × volume) / sum(volume) over a lookback
Calculation: Short EMA of Rolling VWAP = EMA of Rolling VWAP using the base EMA lookback
Calculation: Long EMA of Rolling VWAP = EMA of Rolling VWAP using twice the base EMA lookback
Calculation: Historical EMA of Rolling VWAP = EMA of Rolling VWAP shifted back by the base EMA lookback
Long: Flat position AND close crosses above the EMA of close OR (EMA of close > Short EMA of Rolling VWAP AND low ≤ Historical EMA of Rolling VWAP AND close > Historical EMA of Rolling VWAP)
Long: Long position AND EMA of close > Short EMA of Rolling VWAP AND Short EMA of Rolling VWAP > Long EMA of Rolling VWAP AND close crosses above Long EMA of Rolling VWAP AND close > open
Long: Long position AND EMA of close > Short EMA of Rolling VWAP AND Short EMA of Rolling VWAP > Historical EMA of Rolling VWAP AND close crosses above Historical EMA of Rolling VWAP AND close > open
Short: EMA of close crosses below Short EMA of Rolling VWAP
Exit: Long, EMA of close crosses below Short EMA of Rolling VWAP
Exit: Long, close < entry price × (1 − stop-loss percentage)
Exit: Long, close ≥ entry price × (1 + profit-target percentage) AND RSI(5) crosses below 90
Exit: Short, RSI(5) crosses above 15
Exit: Short, EMA of close crosses above Short EMA of Rolling VWAP