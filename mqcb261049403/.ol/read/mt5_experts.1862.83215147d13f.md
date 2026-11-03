Calculation: High-based Bollinger Bands = Bollinger Bands calculated from bar highs on the configured indicator timeframe, which may be higher or lower than the chart timeframe, using its still-forming bar.
Calculation: Low-based Bollinger Bands = Bollinger Bands calculated from bar lows on the configured indicator timeframe, which may be higher or lower than the chart timeframe, using its still-forming bar.
Long: close <= lower Low-based Bollinger Band AND NOT (close >= lower High-based Bollinger Band AND close <= upper Low-based Bollinger Band)
Short: close >= upper High-based Bollinger Band AND NOT (close >= lower High-based Bollinger Band AND close <= upper Low-based Bollinger Band)
Exit: long, close >= lower High-based Bollinger Band
Exit: short, close <= upper Low-based Bollinger Band