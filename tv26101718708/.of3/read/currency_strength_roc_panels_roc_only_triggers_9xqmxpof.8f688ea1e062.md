Calculation: Currency strength(c) = mean over the other seven currencies x in {EUR, USD, JPY, CHF, GBP, AUD, CAD, NZD} of 10000 × ln(current chart-bar close of c/x ÷ T1 close[anchor bars back] of c/x), using the last completed T1 bar.
Calculation: Currency momentum(c) = Linear Regression Slope(Currency strength(c), RoC lookback), optionally z-scored over the normalization lookback.
Calculation: Selected momentum(c) = Currency momentum(c) on the current chart bar, or its previous chart-bar value when last-closed is enabled.
Calculation: Auto threshold = auto multiplier × StDev(maximum absolute Selected momentum across the eight currencies, auto lookback), calculated on chart bars.
Long: On chart bars, any of EUR, USD, JPY, CHF, GBP, AUD, CAD, or NZD Selected momentum crosses above the positive trigger, which is either the fixed positive trigger parameter or Auto threshold.
Short: On chart bars, any of EUR, USD, JPY, CHF, GBP, AUD, CAD, or NZD Selected momentum crosses below the negative trigger, which is either the fixed negative trigger parameter or negative Auto threshold.
Calculation: Currency strength = mean of the signed log returns against the other currencies in the basket, each return = return scale × ln(chart-timeframe pair close / T1 pair close at anchor offset), with cross rates derived from USD exchange rates
Calculation: Currency strength momentum = linear-regression slope of currency strength over the momentum lookback, optionally Z-score normalized over the normalization lookback, using the current or last closed chart bar
Calculation: Maximum absolute currency strength momentum = greatest absolute currency strength momentum among the currencies in the basket
Calculation: Positive trigger = fixed positive threshold in fixed mode, otherwise standard deviation of maximum absolute currency strength momentum over the automatic lookback × automatic multiplier
Calculation: Negative trigger = fixed negative threshold in fixed mode, otherwise −standard deviation of maximum absolute currency strength momentum over the automatic lookback × automatic multiplier
Long: a currency's strength momentum crosses above the positive trigger
Short: a currency's strength momentum crosses below the negative trigger