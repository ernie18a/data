Calculation: Signal score = sign(short-lookback moving average − long-lookback moving average) + sign(short-lookback RSI − long-lookback RSI), calculated on the configured indicator timeframe from aggregated backtest bars when needed; use completed bars.
Long: Signal score > 0 AND previous completed bar's Signal score <= 0
Short: Signal score < 0 AND previous completed bar's Signal score >= 0
Exit: long, Signal score < 0
Exit: short, Signal score > 0