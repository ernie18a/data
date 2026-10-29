Calculation: Bar midpoint = (bar high + bar low) / 2
Calculation: Bar range = bar high - bar low
Calculation: Daily bullish bias = at least one of: (open ≤ low + 0.33 × range AND close ≥ low + 0.66 × range AND volume > previous bar volume); (low < previous low AND close > open AND close > low + 0.625 × range AND volume > previous bar volume); (close - open ≤ 250 points AND close > open AND volume > previous bar volume); (low < previous low AND high > previous high AND close ≥ previous high AND volume > previous bar volume); (absolute(close - prior bar open) < 100 points AND prior bar open > prior bar close). Use completed chart-timeframe bars.
Calculation: Daily bearish bias = at least one of: (close ≤ low + 0.33 × range AND open ≥ low + 0.66 × range AND volume > previous bar volume); (high > previous high AND close < open AND close < high - 0.625 × range AND volume > previous bar volume); (open - close ≤ 250 points AND close < open AND volume > previous bar volume); (low < previous low AND high > previous high AND close ≤ previous low AND volume > previous bar volume); (absolute(close - prior bar open) < 100 points AND prior bar open < prior bar close). Use completed chart-timeframe bars.
Calculation: Hourly bullish failure = at least one of: (low < previous low AND close > open AND close > low + 0.625 × range AND volume > previous bar volume); (close - open ≤ 40 points AND close > open AND volume > previous bar volume); (low < previous low AND high > previous high AND close ≥ previous high AND volume > previous bar volume); (absolute(close - prior bar open) < 40 points AND prior bar open > prior bar close). Use the last completed lower-timeframe bar.
Calculation: Hourly bearish failure = at least one of: (high > previous high AND close < open AND close < high - 0.625 × range AND volume > previous bar volume); (open - close ≤ 40 points AND close < open AND volume > previous bar volume); (low < previous low AND high > previous high AND close ≤ previous low AND volume > previous bar volume); (absolute(close - prior bar open) < 40 points AND prior bar open < prior bar close). Use the last completed lower-timeframe bar.
Long: Daily bullish bias AND NOT daily bearish bias AND hourly bullish failure AND NOT hourly bearish failure
Short: Daily bearish bias AND (hourly bearish failure OR (hourly bullish failure AND NOT hourly bearish failure))
Long: close > open AND close > bar midpoint AND volume > previous bar volume
Long: close = open AND close > bar midpoint AND volume > previous bar volume
Long: close < open AND close > bar midpoint AND volume > previous bar volume
Long: close = open AND close < bar midpoint AND volume > previous bar volume
Short: close < open AND close < bar midpoint AND volume > previous bar volume
Short: close = open AND close < bar midpoint AND volume > previous bar volume
Short: close > open AND close < bar midpoint AND volume > previous bar volume
Exit: long, close > entry price + take-profit offset
Exit: short, close < entry price - take-profit offset