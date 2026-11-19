Calculation: band volatility = standard deviation(close, volatility lookback) / square root(volatility lookback) × volatility importance × (1 + restrictiveness / restrictiveness divisor)
Calculation: fast center = EMA(close, fast channel lookback)
Calculation: fast upper band = fast center × (1 + fast channel margin / fast margin divisor) + band volatility
Calculation: fast lower band = fast center × (1 - fast channel margin / fast margin divisor) - band volatility
Calculation: slow center = EMA(EMA(close, slow channel lookback), slow channel lookback)
Calculation: slow upper band = slow center × (1 + slow channel margin / slow margin divisor) + band volatility
Calculation: slow lower band = slow center × (1 - slow channel margin / slow margin divisor) - band volatility
Calculation: fast average = HMA(close, fast HMA lookback)
Calculation: adjusted stop-loss percentage = stop-loss percentage × (1 + standard deviation(close, stop-loss volatility lookback) × (1 + stop-loss flexibility / flexibility divisor) / close)
Long: position side is not short AND fast average < fast upper band AND fast lower band < slow lower band AND correlation(close, OBV, OBV lookback) > OBV correlation threshold
Short: position side is not long AND fast average > fast upper band AND fast upper band > slow upper band AND correlation(close, OBV, OBV lookback) > OBV correlation threshold
Exit: long, fast average > fast upper band AND fast lower band > slow upper band OR low <= entry price × (1 - adjusted stop-loss percentage / stop-loss percentage divisor)
Exit: short, fast average < fast lower band AND fast upper band < slow lower band OR high >= entry price × (1 + adjusted stop-loss percentage / stop-loss percentage divisor)