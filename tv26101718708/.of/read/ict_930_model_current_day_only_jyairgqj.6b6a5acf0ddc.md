Calculation: Previous weekday high and low = high and low of the most recently completed weekday in the configured time zone; retain them across non-weekdays.
Calculation: Session high and low = highest high and lowest low among chart bars in the configured reference session on the current date, accumulated through the current bar and reset at each new date.
Calculation: Midnight open = open of the latest chart bar whose opening time is midnight in the configured time zone.
Calculation: Bullish rejection = within the configured trading window AND neither bullish nor bearish sweep is active AND, for either the previous weekday low or session low, previous close > level AND open > level AND low < level AND close > level.
Calculation: Bearish rejection = within the configured trading window AND neither bullish nor bearish sweep is active AND, for either the previous weekday high or session high, previous close < level AND open < level AND high > level AND close < level.
Calculation: Sweep state = reset both sweep states at each new date. A bullish or bearish rejection activates its corresponding sweep and records its bar. If the one-gap-per-sweep option is enabled, the first qualifying gap after that sweep deactivates it; otherwise it remains active until the date reset. Evaluate rejection and gap decisions before applying a gap's deactivation.
Calculation: Bullish displacement = previous close > previous open AND previous high minus previous low > previous bar's ATR multiplied by a configurable factor.
Calculation: Bearish displacement = previous close < previous open AND previous high minus previous low > previous bar's ATR multiplied by a configurable factor.
Long: Bullish rejection OR bullish sweep active after gap-state updates.
Short: Bearish rejection OR bearish sweep active after gap-state updates.
Long: Close > midnight open.
Short: Close < midnight open.
Long: Bullish displacement.
Short: Bearish displacement.
Long: Low > high two bars ago.
Short: High < low two bars ago.
Long: Low < (session high + session low) / 2.
Short: High > (session high + session low) / 2.
Long: Within the configured trading window AND bullish sweep active AND current bar later than the bullish rejection bar AND low > high two bars ago AND (displacement filter disabled OR bullish displacement) AND (premium/discount filter disabled OR low < (session high + session low) / 2) AND (one-gap-per-sweep option disabled OR no qualifying bullish gap has occurred since the sweep).
Short: Within the configured trading window AND bearish sweep active AND current bar later than the bearish rejection bar AND high < low two bars ago AND (displacement filter disabled OR bearish displacement) AND (premium/discount filter disabled OR high > (session high + session low) / 2) AND (one-gap-per-sweep option disabled OR no qualifying bearish gap has occurred since the sweep).