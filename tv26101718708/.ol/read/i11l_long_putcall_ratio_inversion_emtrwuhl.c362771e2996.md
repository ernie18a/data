Calculation: Put/call ratio moving average = simple moving average of daily put/call ratio closes, using the last completed higher-timeframe bar
Calculation: Upper deviation band = longer-lookback simple moving average of the put/call ratio moving average + deviation multiple × its standard deviation over that same lookback
Calculation: Lower deviation band = longer-lookback simple moving average of the put/call ratio moving average − deviation multiple × its standard deviation over that same lookback
Long: Put/call ratio moving average crosses below the upper deviation band
Short: Put/call ratio moving average crosses above the lower deviation band
Exit: short, Put/call ratio moving average > its longer-lookback simple moving average
Exit: long, low < entry price × (1 − stop-loss fraction)
Exit: short, high > entry price × (1 + stop-loss fraction)
Exit: long, high > entry price × (1 + stop-loss fraction × reward-risk multiple)