Calculation: Exponential moving average = exponential moving average of close over the lookback
Calculation: Upper envelope = exponential moving average × (1 + deviation / 100)
Calculation: Lower envelope = exponential moving average × (1 − deviation / 100)
Long: previous completed chart bar close > current forming chart bar exponential moving average AND previous completed chart bar close < current forming chart bar upper envelope AND hour(datetime) > start hour AND hour(datetime) < end hour
Short: previous completed chart bar close < current forming chart bar exponential moving average AND previous completed chart bar close > current forming chart bar lower envelope AND hour(datetime) > start hour AND hour(datetime) < end hour
Exit: long, low <= lower envelope at entry signal OR high >= upper envelope at entry signal + target offset
Exit: short, high >= upper envelope at entry signal OR low <= lower envelope at entry signal − target offset