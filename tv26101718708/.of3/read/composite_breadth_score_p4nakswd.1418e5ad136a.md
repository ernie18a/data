Calculation: Leadership breadth = if new 52-week highs and new 52-week lows, each set to zero when unavailable, sum to more than zero, then new 52-week highs divided by their sum times 100; otherwise neutral leadership score parameter
Calculation: Composite Breadth Score = if the percentage of stocks above their 200-day moving average is unavailable, (McClellan Summation Index percentile rank over the percentile lookback parameter, using the fast EMA period parameter and slow EMA period parameter, with unavailable rank set to zero, times the momentum weight parameter + Leadership breadth times the leadership weight parameter) divided by the sum of the momentum and leadership weight parameters; otherwise (percentage of stocks above their 200-day moving average times the participation weight parameter + McClellan Summation Index percentile rank over the percentile lookback parameter, using the fast EMA period parameter and slow EMA period parameter, with unavailable rank set to zero, times the momentum weight parameter + Leadership breadth times the leadership weight parameter) divided by the sum of the participation, momentum, and leadership weight parameters, or 100 if that sum is zero
Long: Composite Breadth Score crosses above composite midpoint parameter
Short: Composite Breadth Score crosses below composite midpoint parameter
Short: Composite Breadth Score crosses above overbought threshold parameter
Long: Composite Breadth Score crosses below oversold threshold parameter
Long: McClellan Summation Index crosses above its neutral level parameter
Short: McClellan Summation Index crosses below its neutral level parameter
Long: Leadership breadth crosses above leadership midpoint parameter
Short: Leadership breadth crosses below leadership midpoint parameter
Short: Percentage of stocks above their 200-day moving average crosses below participation warning threshold parameter