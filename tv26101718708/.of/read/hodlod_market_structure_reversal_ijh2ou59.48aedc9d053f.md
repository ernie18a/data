Calculation: Fast swing high = confirmed pivot high, with the configured lookback number of bars on each side
Calculation: Fast swing low = confirmed pivot low, with the configured lookback number of bars on each side
Calculation: Close position = (close - low) / (high - low), or 0.5 when high = low
Long: low < previous session low AND the first fast swing high whose pivot bar is after that low is active AND close > fast swing high + 2 minimum ticks AND bar index <= pivot bar + configured line duration AND volume > previous bar volume AND close position >= configured close threshold
Short: high > previous session high AND the first fast swing low whose pivot bar is after that high is active AND close < fast swing low - 2 minimum ticks AND bar index <= pivot bar + configured line duration AND volume > previous bar volume AND close position <= 1 - configured close threshold
Exit: long, bar index = long signal bar + 1 AND close < open
Exit: short, bar index = short signal bar + 1 AND close > open