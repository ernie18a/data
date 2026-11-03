Calculation: bullish wick reversal = lower wick (min(open, close) − low) is at least body size (absolute close − open) times a wick multiplier AND upper wick (high − max(open, close)) is no greater than body size AND close is in the upper body-position fraction of the bar’s range
Calculation: bearish wick reversal = upper wick is at least body size times a wick multiplier AND lower wick is no greater than body size AND close is in the lower body-position fraction of the bar’s range
Calculation: bullish extreme reversal = low < previous bar’s low AND close > previous bar’s high
Calculation: bearish extreme reversal = high > previous bar’s high AND close < previous bar’s low
Calculation: bullish outside reversal = high > previous bar’s high AND low < previous bar’s low AND close > open AND close > (high + low) / 2
Calculation: bearish outside reversal = high > previous bar’s high AND low < previous bar’s low AND close < open AND close < (high + low) / 2
Calculation: bullish doji reversal = high > low AND absolute(close − open) / (high − low) is at most the doji-body fraction AND close > previous bar’s close
Calculation: bearish doji reversal = high > low AND absolute(close − open) / (high − low) is at most the doji-body fraction AND close < previous bar’s close
Long: bullish wick reversal OR bullish extreme reversal OR bullish outside reversal OR bullish doji reversal
Short: bearish wick reversal OR bearish extreme reversal OR bearish outside reversal OR bearish doji reversal