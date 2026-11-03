Calculation: Inside bar = high < previous high AND low > previous low
Calculation: Upward run qualifies = the number of consecutive non-inside bars with a low higher than the previous bar’s low reaches the configured consecutive-bars threshold minus one; inside bars pause the count, and any other non-inside bar resets it
Calculation: Downward run qualifies = the number of consecutive non-inside bars with a high lower than the previous bar’s high reaches the configured consecutive-bars threshold minus one; inside bars pause the count, and any other non-inside bar resets it
Calculation: Bullish inside-bar reversal = an unexpired, unconsumed latest inside bar exists AND current bar is not inside AND close > that inside bar’s high AND low > previous low
Calculation: Bearish inside-bar reversal = an unexpired, unconsumed latest inside bar exists AND current bar is not inside AND close < that inside bar’s low AND high < previous high
Long: (active trend is not up AND bullish inside-bar reversal) OR (active trend is flat AND upward run qualifies)
Short: (active trend is not down AND bearish inside-bar reversal) OR (active trend is flat AND downward run qualifies)
Exit: Long, active trend is up AND current bar is not inside AND upward run does not qualify AND bearish inside-bar reversal is false
Exit: Short, active trend is down AND current bar is not inside AND downward run does not qualify AND bullish inside-bar reversal is false