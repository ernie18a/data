Calculation: Buy absorption strength = volume / (abs(close − open) × close) on up bars, otherwise 0; sell absorption strength = the same ratio on down bars, otherwise 0.
Calculation: Buy/sell absorption index = the corresponding absorption strength divided by its rolling standard deviation over a lookback period.
Long: Current low > high two bars ago AND high two bars ago >= previous bar open AND current low <= previous bar close
Short: Current low two bars ago > current high AND low two bars ago <= previous bar open AND current high >= previous bar close
Long: Absorption index for an up bar >= the configured threshold
Short: Absorption index for a down bar >= the configured threshold
Calculation: Structure high/low = highest high / lowest low over the structure lookback, excluding the current bar.
Long: Close > structure high
Short: Close < structure low
Long: On the primary scan timeframe, low three bars ago > high one bar ago AND high three bars ago differs from its value on the preceding chart bar; use completed timeframe bars.
Short: On the primary scan timeframe, high three bars ago < low one bar ago AND low three bars ago differs from its value on the preceding chart bar; use completed timeframe bars