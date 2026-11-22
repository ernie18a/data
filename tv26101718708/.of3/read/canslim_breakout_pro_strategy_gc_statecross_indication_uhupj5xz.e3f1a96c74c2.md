Long: SMA(market-index close, shorter lookback) crosses above SMA(market-index close, longer lookback)
Long: sector gate enabled AND SMA(selected-sector close, shorter lookback) crosses above SMA(selected-sector close, longer lookback)
Long: close > Highest(high[1], pivot lookback) AND close <= Highest(high[1], pivot lookback) * (1 + buy-range percentage) AND volume >= SMA(volume, volume-average lookback) * volume multiplier AND (market gate disabled OR market-index data unavailable OR SMA(market-index close, shorter lookback) > SMA(market-index close, longer lookback)) AND (sector gate disabled OR selected-sector data unavailable OR SMA(selected-sector close, shorter lookback) > SMA(selected-sector close, longer lookback))
Exit: long, close <= entry price * (1 - hard-stop percentage)
Exit: long, close >= entry price * (1 + trail-activation percentage) AND close <= Highest(close from entry through current bar) * (1 - trailing distance percentage)
Exit: long, close >= entry price * (1 + target percentage)
Exit: long, elapsed bars since entry >= holding-period parameter
Short: SMA(market-index close, shorter lookback) crosses below SMA(market-index close, longer lookback)
Short: sector gate enabled AND SMA(selected-sector close, shorter lookback) crosses below SMA(selected-sector close, longer lookback)
Calculation: breakout level = highest traded instrument high over the prior pivot lookback bars
Long: (market gate off OR selected market index close unavailable OR SMA(selected market index close, fast SMA length) > SMA(selected market index close, slow SMA length)) AND (sector gate off OR selected sector index close unavailable OR SMA(selected sector index close, fast SMA length) > SMA(selected sector index close, slow SMA length)) AND traded instrument close > breakout level AND traded instrument close <= breakout level × (1 + maximum buy range / 100) AND traded instrument volume >= SMA(traded instrument volume, volume-average lookback) × volume threshold multiplier