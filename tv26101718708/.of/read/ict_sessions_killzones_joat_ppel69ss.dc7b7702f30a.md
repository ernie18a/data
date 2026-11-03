Calculation: Session reference high and low = Track the high and low of chart bars in each enabled session. On each bar, select the most recent tracked range for the first eligible session in this priority order: New York AM, London, Asia; a session is eligible when it is inactive and has a tracked range. If none is eligible, retain the previous reference. Track the high and low separately; each is rearmed at the start of a new exchange day or when that reference value changes. A high or low sweep consumes its respective armed state even if no BUY or SELL condition is met.
Calculation: Midnight open = Open of the chart bar in the midnight session in the configured session timezone, captured when no prior value exists or when that bar also starts a new exchange day; otherwise retain the previous value.
Long: Close > midnight open.
Short: Close < midnight open.
Long: Low < armed session reference low AND close > session reference low.
Short: High > armed session reference high AND close < session reference high.
Long: Low < armed session reference low AND close > session reference low AND close > midnight open AND close > open.
Short: High > armed session reference high AND close < session reference high AND close < midnight open AND close < open.