Calculation: Signed volume flow = volume when (low + 2 × close)/3 is greater than the previous bar’s (high + low + close)/3; negative volume when lower; zero when equal.
Calculation: KVO = shorter-lookback moving average of signed volume flow minus longer-lookback moving average of signed volume flow.
Calculation: Signal line = moving average of KVO.
Long: KVO < 0 AND KVO > Signal line AND previous bar’s KVO <= previous bar’s Signal line
Short: KVO > 0 AND KVO < Signal line AND previous bar’s KVO >= previous bar’s Signal line