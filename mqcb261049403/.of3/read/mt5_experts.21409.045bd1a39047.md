Calculation: Trend color on bars of T = rising when round_to_increment(JMA(FATL(applied price, FATL lookback), JMA lookback, phase) + vertical shift in points × instrument point size, instrument point size × 10^rounding digits) is greater than its value on the prior T bar, falling when less, otherwise its previous color.
Long: Trend color on the last completed T1 bar is rising AND its color on the preceding T1 bar was not rising.
Short: Trend color on the last completed T1 bar is falling AND its color on the preceding T1 bar was not falling.
Long: Trend color on the last completed T2 bar is rising AND its color on the preceding T2 bar was not rising.
Short: Trend color on the last completed T2 bar is falling AND its color on the preceding T2 bar was not falling.
Long: Trend color on the last completed T3 bar is rising AND its color on the preceding T3 bar was not rising.
Short: Trend color on the last completed T3 bar is falling AND its color on the preceding T3 bar was not falling.