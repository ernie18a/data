Calculation: High volume = volume > SMA(volume, volume lookback) * volume multiplier
Calculation: Fear signal = High volume AND ((min(open, close) - low) >= abs(close - open) * wick-to-body ratio AND (high - max(open, close)) <= abs(close - open) AND high - low > 0 OR close > open AND open <= close[1] AND close >= open[1] AND close[1] < open[1])
Calculation: Greed signal = High volume AND ((high - max(open, close)) >= abs(close - open) * wick-to-body ratio AND (min(open, close) - low) <= abs(close - open) AND high - low > 0 OR close < open AND open >= close[1] AND close <= open[1] AND close[1] > open[1])
Calculation: Doji = abs(close - open) <= (high - low) * doji body-size parameter
Long: Fear signal OR (close > SMA(close, price lookback) AND High volume AND close > open AND NOT Greed signal AND Doji[1])
Short: Greed signal OR (close < SMA(close, price lookback) AND High volume AND close < open AND NOT Fear signal AND Doji[1])