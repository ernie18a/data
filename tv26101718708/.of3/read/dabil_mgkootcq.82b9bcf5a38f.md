Calculation: Bullish candle(T) = close(T) > open(T) on T's current bar (still forming in realtime), mapped to chart bars
Calculation: Bearish candle(T) = close(T) < open(T) on T's current bar (still forming in realtime), mapped to chart bars
Long: close of the current T1 bar > close of the previous T1 bar (current T1 bar may still be forming; result mapped to chart bars) AND Bullish candle(T2) AND Bullish candle(T3) AND Bullish candle(T4) AND Bullish candle(T5), where T1 > T2 > T3 > T4 > T5 by timeframe duration
Short: close of the current T1 bar < close of the previous T1 bar (current T1 bar may still be forming; result mapped to chart bars) AND Bearish candle(T2) AND Bearish candle(T3) AND Bearish candle(T4) AND Bearish candle(T5)
Exit: long, low <= entry price - stop-loss price-offset parameter OR high >= entry price + take-profit price-offset parameter
Exit: short, high >= entry price + stop-loss price-offset parameter OR low <= entry price - take-profit price-offset parameter