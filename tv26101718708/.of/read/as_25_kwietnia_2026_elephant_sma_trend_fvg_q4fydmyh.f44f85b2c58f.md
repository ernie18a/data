Long: Close > short-term SMA of close
Short: Close <= short-term SMA of close
Long: medium-term SMA of close > its previous-bar value
Short: medium-term SMA of close <= its previous-bar value
Long: medium-term SMA of close > long-term SMA of close AND abs(close - long-term SMA of close) / long-term SMA of close >= distance threshold
Short: medium-term SMA of close < long-term SMA of close AND abs(close - long-term SMA of close) / long-term SMA of close >= distance threshold
Long: high - low > ATR multiplied by range multiplier AND high - low > 0 AND abs(close - open) / (high - low) > body-ratio threshold AND close > open
Short: high - low > ATR multiplied by range multiplier AND high - low > 0 AND abs(close - open) / (high - low) > body-ratio threshold AND close < open
Long: low > high two bars earlier
Short: high < low two bars earlier
Long: close crosses above the higher-timeframe EMA of close, using the last completed higher-timeframe bar on historical bars and the still-forming higher-timeframe bar in real time
Short: close crosses below the higher-timeframe EMA of close, using the last completed higher-timeframe bar on historical bars and the still-forming higher-timeframe bar in real time