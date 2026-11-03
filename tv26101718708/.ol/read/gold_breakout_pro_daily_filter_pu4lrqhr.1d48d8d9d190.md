Calculation: Long stop = lowest low over a chart-timeframe lookback including the current bar
Calculation: Long target = entry price + (entry price − long stop) × reward/risk multiple
Calculation: Short stop = highest high over a chart-timeframe lookback including the current bar
Calculation: Short target = entry price − (short stop − entry price) × reward/risk multiple
Long: close > the prior chart bar's rolling highest high AND close > open AND (high − low) > a fraction of (rolling highest high − rolling lowest low) over the chart-timeframe lookback including the current bar AND higher-timeframe close > higher-timeframe EMA
Short: close < the prior chart bar's rolling lowest low AND close < open AND (high − low) > a fraction of (rolling highest high − rolling lowest low) over the chart-timeframe lookback including the current bar AND higher-timeframe close < higher-timeframe EMA
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target