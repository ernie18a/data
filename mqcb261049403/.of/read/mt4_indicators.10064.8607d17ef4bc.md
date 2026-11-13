Calculation: SMMA_slow = Smoothed Moving Average (Wilder) of close, long lookback, computed on bars of a timeframe higher than the chart timeframe, using the still-forming bar
Calculation: SMMA_fast = Smoothed Moving Average (Wilder) of close, shorter lookback than SMMA_slow, same timeframe and bar as SMMA_slow
Calculation: Stoch = slow Stochastic main line (%K, 0-100 scale), computed on bars of a timeframe higher than the SMMA timeframe, using the still-forming bar
Long: SMMA_fast > SMMA_slow AND Stoch > 50
Short: SMMA_fast < SMMA_slow AND Stoch < 50