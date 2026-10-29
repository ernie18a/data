Long: no open positions AND current hour is within the configured opening window AND close > TEMA(50, close) on the entry timeframe's still-forming bar
Short: no open positions AND current hour is within the configured opening window AND close < TEMA(50, close) on the entry timeframe's still-forming bar
Long: position count < maximum averaging orders AND (AverageDown mode AND ask <= lowest long entry price - grid multiplier × ATR OR AverageUp mode AND ask >= highest long entry price + grid multiplier × ATR); use the last completed ATR-timeframe bar
Short: position count < maximum averaging orders AND (AverageDown mode AND bid >= highest short entry price + grid multiplier × ATR OR AverageUp mode AND bid <= lowest short entry price - grid multiplier × ATR); use the last completed ATR-timeframe bar
Exit: long, price <= stop loss OR price >= take profit
Exit: short, price >= stop loss OR price <= take profit