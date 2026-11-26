Calculation: Selected-timeframe Supertrend = Supertrend(factor, ATR lookback) on T1 bars, using the last completed T1 bar's value on each chart bar
Calculation: SMA cross recency = barssince(crossover(SMA(close, shorter lookback), SMA(close, longer lookback))) - barssince(crossunder(SMA(close, shorter lookback), SMA(close, longer lookback)))
Long: crossover(SMA(close, shorter lookback), SMA(close, longer lookback))
Short: crossunder(SMA(close, shorter lookback), SMA(close, longer lookback))
Long: chart close >= Selected-timeframe Supertrend
Short: chart close < Selected-timeframe Supertrend
Long: long orders enabled AND chart close >= Selected-timeframe Supertrend AND SMA cross recency < 0
Short: short orders enabled AND chart close <= Selected-timeframe Supertrend AND SMA cross recency > 0
Exit: long, long orders enabled AND crossunder(SMA(close, shorter lookback), SMA(close, longer lookback))
Exit: short, short orders enabled AND crossover(SMA(close, shorter lookback), SMA(close, longer lookback))