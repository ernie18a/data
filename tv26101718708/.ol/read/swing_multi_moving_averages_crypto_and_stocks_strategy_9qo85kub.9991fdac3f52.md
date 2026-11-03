Calculation: Configured moving average = selected moving-average type applied to the selected source series
Long: close > configured moving average AND previous bar close < configured moving average AND day of week(datetime) = Monday
Short: close < configured moving average AND previous bar close > configured moving average AND day of week(datetime) = Monday
Exit: long, low <= entry price × (1 − long stop percentage) OR high >= entry price × (1 + long take-profit percentage) OR day of week(datetime) = Sunday
Exit: short, high >= entry price × (1 + short stop percentage) OR low <= entry price × (1 − short take-profit percentage) OR day of week(datetime) = Sunday