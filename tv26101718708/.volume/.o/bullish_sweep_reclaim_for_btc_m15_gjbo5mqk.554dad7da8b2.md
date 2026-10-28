Calculation: RSI = relative strength index of close
Calculation: VWAP = session volume-weighted average price of hlc3
Calculation: Bollinger basis = simple moving average of close
Calculation: Lowest C2 low = lowest low among bars after the Drop Candle and before the signal bar whose close is below the Drop Candle low
Long: The nearest prior Drop Candle candidate 2 through the lookback limit bars back and within the maximum age has close < open, RSI < its threshold, low < the simple moving average, close < session VWAP, and low < Bollinger basis; at least one later bar before the signal bar closes below the Drop Candle low; signal bar low <= Lowest C2 low AND signal bar close > Drop Candle low.