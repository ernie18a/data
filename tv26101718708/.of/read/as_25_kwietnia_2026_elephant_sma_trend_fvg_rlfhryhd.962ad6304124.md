Long: high - low > ATR multiplied by a threshold AND high - low > 0 AND abs(close - open) / (high - low) > a threshold AND close > open
Short: high - low > ATR multiplied by a threshold AND high - low > 0 AND abs(close - open) / (high - low) > a threshold AND close < open
Long: low > high two bars ago
Short: high < low two bars ago
Long: close > short-term SMA of close
Short: close <= short-term SMA of close
Long: medium-term SMA of close > its previous value
Short: medium-term SMA of close <= its previous value
Long: medium-term SMA of close > long-term SMA of close AND abs(close - long-term SMA of close) / long-term SMA of close >= a threshold
Short: medium-term SMA of close < long-term SMA of close AND abs(close - long-term SMA of close) / long-term SMA of close >= a threshold
Long: close crosses above an EMA of a selected price source on a higher timeframe, using the last completed higher-timeframe bar on historical bars and the forming higher-timeframe bar in real time
Short: close crosses below an EMA of a selected price source on a higher timeframe, using the last completed higher-timeframe bar on historical bars and the forming higher-timeframe bar in real time