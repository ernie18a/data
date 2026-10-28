Calculation: Demand top = low of the last completed higher-timeframe bar
Calculation: Demand bottom = low of the higher-timeframe bar immediately before the last completed bar
Calculation: Supply top = high of the higher-timeframe bar immediately before the last completed bar
Calculation: Supply bottom = high of the last completed higher-timeframe bar
Long: close >= demand bottom AND close <= demand top AND close > open AND previous close < previous open AND close > previous high AND (BOS filter disabled OR current high > highest high of the preceding lookback bars, excluding the current bar) AND (volume filter disabled OR volume > volume SMA)
Short: close <= supply top AND close >= supply bottom AND close < open AND previous close > previous open AND close < previous low AND (BOS filter disabled OR current low < lowest low of the preceding lookback bars, excluding the current bar) AND (volume filter disabled OR volume > volume SMA)