Long: close > short-term SMA of close
Short: close <= short-term SMA of close
Long: medium-term SMA of close > its previous value
Short: medium-term SMA of close <= its previous value
Long: medium-term SMA of close > long-term SMA of close AND abs(close - long-term SMA of close) / long-term SMA of close >= range threshold
Short: medium-term SMA of close < long-term SMA of close AND abs(close - long-term SMA of close) / long-term SMA of close >= range threshold
Long: high - low > ATR × range multiplier AND abs(close - open) / (high - low) > body ratio threshold AND close > open
Short: high - low > ATR × range multiplier AND abs(close - open) / (high - low) > body ratio threshold AND close < open
Long: low > high two bars ago
Short: high < low two bars ago
Long: close > higher-timeframe EMA of close using the last completed higher-timeframe bar AND previous close <= previous chart-bar value of that EMA
Short: close < higher-timeframe EMA of close using the last completed higher-timeframe bar AND previous close >= previous chart-bar value of that EMA