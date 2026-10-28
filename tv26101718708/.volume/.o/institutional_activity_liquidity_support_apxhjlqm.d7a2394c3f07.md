Calculation: Average volume = simple moving average of volume
Calculation: Average candle body = simple moving average of absolute close minus open, using the same lookback as average volume
Calculation: Previous monthly low = low of the last completed monthly bar aggregated from the backtest data
Calculation: Previous yearly low = low of the last completed yearly bar aggregated from the backtest data
Long: (volume > average volume × volume-spike threshold AND close > low + 0.3 × (high − low)) OR (close > open AND absolute close minus open > average candle body × expansion threshold AND volume > average volume × expansion-volume threshold) OR (low < previous yearly low AND close > previous yearly low) OR (low < previous monthly low AND close > previous monthly low)