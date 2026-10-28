Calculation: Estimated volume delta = volume when close > open, negative volume when close < open, otherwise 0
Calculation: Delta moving average = simple moving average of estimated volume delta
Calculation: High volume = volume > its longer-lookback simple moving average × a threshold
Calculation: Bullish imbalance = close > open AND volume > 0 AND (close − open) / (high − low + a small range adjustment) > an imbalance threshold
Calculation: Bearish imbalance = close < open AND volume > 0 AND (open − close) / (high − low + a small range adjustment) > an imbalance threshold
Calculation: Bullish imbalance streak = bullish imbalance on this bar and the previous two bars
Calculation: Bearish imbalance streak = bearish imbalance on this bar and the previous two bars
Calculation: Confirmed price pivot high/low and volume-delta pivot high/low = pivot high/low using equal left and right lookback widths
Long: bullish imbalance streak OR (confirmed price pivot low AND confirmed volume-delta pivot high AND close five bars ago < close ten bars ago) OR estimated volume delta > 0 OR estimated volume delta > Delta moving average × a pressure threshold OR (bullish imbalance streak OR (estimated volume delta > Delta moving average × a larger threshold AND high volume)) OR estimated volume delta > Delta moving average × an extreme-pressure threshold
Short: bearish imbalance streak OR (confirmed price pivot high AND confirmed volume-delta pivot low AND close five bars ago > close ten bars ago) OR estimated volume delta < 0 OR estimated volume delta < −Delta moving average × a pressure threshold OR (bearish imbalance streak OR (estimated volume delta < −Delta moving average × a larger threshold AND high volume)) OR estimated volume delta < −Delta moving average × an extreme-pressure threshold
