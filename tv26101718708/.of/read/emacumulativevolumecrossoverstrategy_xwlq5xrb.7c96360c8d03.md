Calculation: Rolling VWAP = sum of volume × (high + low + close) / 3 over a lookback divided by sum of volume over the same lookback
Long: EMA crosses above Rolling VWAP
Short: close < Rolling VWAP AND close < open AND previous chart bar close < Rolling VWAP AND previous chart bar close < previous chart bar open AND close < previous chart bar close AND EMA >= Rolling VWAP
Exit: Long, EMA crosses below Rolling VWAP
Exit: Long, close < entry price × (1 − stop-loss percentage)
Exit: Long, close > entry price × (1 + stop-loss percentage) AND close crosses below EMA
Exit: Short, (EMA < Rolling VWAP AND close > Rolling VWAP AND open > Rolling VWAP AND close > open) OR EMA crosses above Rolling VWAP
Exit: Short, close > entry price × (1 + stop-loss percentage)
Exit: Short, close < entry price × (1 − stop-loss percentage)