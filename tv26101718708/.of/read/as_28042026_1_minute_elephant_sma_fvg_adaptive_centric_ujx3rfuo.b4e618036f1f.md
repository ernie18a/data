Calculation: Adaptive centric moving average = Let S be the SMA of the selected source, H the highest SMA of high, and L the lowest SMA of low, all using the same lookback. Let K = 100 * (S - lowest L over that lookback) / (highest H over that lookback - lowest L over that lookback), alpha = (abs(K - 50) / 100 / attenuation)^power, and target = (H + L) / 2 + (S - (H + L) / 2) / attenuation. On each bar, the average = previous average + alpha * (target - previous average), using zero when the previous average is unavailable.
Long: close > short-term SMA of close
Short: close <= short-term SMA of close
Long: high - low > ATR * multiplier AND abs(close - open) / (high - low) > minimum body fraction AND close > open
Short: high - low > ATR * multiplier AND abs(close - open) / (high - low) > minimum body fraction AND close < open
Long: medium-term SMA of close > its previous value
Short: medium-term SMA of close <= its previous value
Long: medium-term SMA of close > long-term SMA of close AND abs(close - long-term SMA of close) / long-term SMA of close >= range threshold
Short: medium-term SMA of close < long-term SMA of close AND abs(close - long-term SMA of close) / long-term SMA of close >= range threshold
Long: low > high two bars ago
Short: high < low two bars ago
Long: close > higher-timeframe EMA of the selected source using the last completed higher-timeframe bar AND previous close <= the previous chart bar's value of that EMA
Short: close < higher-timeframe EMA of the selected source using the last completed higher-timeframe bar AND previous close >= the previous chart bar's value of that EMA
Long: SMA of the selected source > adaptive centric moving average
Short: SMA of the selected source <= adaptive centric moving average