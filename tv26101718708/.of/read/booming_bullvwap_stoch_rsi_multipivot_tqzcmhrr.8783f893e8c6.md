Calculation: Daily pivot P = (previous completed higher-timeframe daily high + low + close) / 3
Calculation: R1 = 2 × P − previous daily low; S1 = 2 × P − previous daily high
Calculation: R2 = P + (previous daily high − low); S2 = P − (previous daily high − low)
Calculation: R3 = previous daily high + 2 × (P − previous daily low); S3 = previous daily low − 2 × (previous daily high − P)
Calculation: Stoch RSI %K = smoothed stochastic of RSI(close); %D = smoothed %K
Long: flat position AND within the configured entry session AND close > VWAP AND ((efficiency filter enabled AND %K > %D) OR (efficiency filter disabled AND %K crosses above %D)) AND (close crosses above the configured pivot level: P only, or any of P, R1–R3, S1–S3)
Short: flat position AND within the configured entry session AND close < VWAP AND ((efficiency filter enabled AND %K < %D) OR (efficiency filter disabled AND %K crosses below %D)) AND (close crosses below the configured pivot level: P only, or any of P, R1–R3, S1–S3)
Exit: long, low ≤ entry candle low OR high ≥ configured fixed-percentage target OR high ≥ entry price + configured reward-risk multiple × (entry price − entry candle low) OR bar time ≥ configured session end
Exit: short, high ≥ entry candle high OR low ≤ configured fixed-percentage target OR low ≤ entry price − configured reward-risk multiple × (entry candle high − entry price) OR bar time ≥ configured session end