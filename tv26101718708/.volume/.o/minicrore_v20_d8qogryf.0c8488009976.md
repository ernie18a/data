Calculation: Supply zone = current high exceeds the highest high of the preceding lookback bars
Calculation: Demand zone = current low is below the lowest low of the preceding lookback bars
Calculation: Recent range = the greater of the lookback high minus the lookback low and a minimum range floor
Calculation: Large candle body = absolute difference between close and open exceeds a configurable fraction of the recent range
Calculation: Volume spike = current volume exceeds its moving average multiplied by a configurable factor
Calculation: Fast and slow moving averages = moving averages of close, with the fast lookback shorter than the slow lookback
Long: (Demand zone AND volume spike AND close > open AND (large candle body OR (close > fast moving average AND fast moving average >= slow moving average))) OR (current low < previous bar low AND close > open AND candle body exceeds a configurable fraction of recent range AND volume > volume moving average)
Short: (Supply zone AND volume spike AND close < open AND (large candle body OR (close < fast moving average AND fast moving average <= slow moving average))) OR (current high > previous bar high AND close < open AND candle body exceeds a configurable fraction of recent range AND volume > volume moving average)