Calculation: Currency strength = mean of the signed log returns against the other currencies in the basket, each return = return scale × ln(chart-timeframe pair close / T1 pair close at anchor offset), with cross rates derived from USD exchange rates
Calculation: Currency strength momentum = linear-regression slope of currency strength over the momentum lookback, optionally Z-score normalized over the normalization lookback, using the current or last closed chart bar
Calculation: Maximum absolute currency strength momentum = greatest absolute currency strength momentum among the currencies in the basket
Calculation: Positive trigger = fixed positive threshold in fixed mode, otherwise standard deviation of maximum absolute currency strength momentum over the automatic lookback × automatic multiplier
Calculation: Negative trigger = fixed negative threshold in fixed mode, otherwise −standard deviation of maximum absolute currency strength momentum over the automatic lookback × automatic multiplier
Long: a currency's strength momentum crosses above the positive trigger
Short: a currency's strength momentum crosses below the negative trigger