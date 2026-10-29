Calculation: Higher-timeframe MA = EMA or SMA of close over a configurable lookback, using the developing higher-timeframe bar when lookahead is enabled and the last completed higher-timeframe bar otherwise.
Long: Close >= the selected higher-timeframe MA
Short: Close < the selected higher-timeframe MA
Long: Close crosses above either selected higher-timeframe MA (current close > current MA AND prior close <= prior MA)
Short: Close crosses below either selected higher-timeframe MA (current close < current MA AND prior close >= prior MA)
Long: Higher-timeframe MA > its prior value
Short: Higher-timeframe MA <= its prior value
Long: Shorter-lookback MA >= the next longer-lookback MA in an adjacent pair
Short: Shorter-lookback MA < the next longer-lookback MA in an adjacent pair