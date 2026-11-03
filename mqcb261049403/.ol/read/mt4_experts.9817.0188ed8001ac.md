Long: previous completed higher-timeframe candle close > open AND hour(datetime) < 1 AND no open position
Short: previous completed higher-timeframe candle close < open AND hour(datetime) < 1 AND no open position
Exit: long, hour(datetime) > market-close-hour - 1
Exit: short, hour(datetime) > market-close-hour - 1