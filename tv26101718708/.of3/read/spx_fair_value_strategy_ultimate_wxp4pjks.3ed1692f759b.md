Calculation: Fair-value deviation = T1 close of the still-forming bar, sampled on chart bars - (net liquidity / liquidity scale / valuation divisor - valuation offset)
Calculation: Upper crossing = net liquidity > 0 AND Fair-value deviation[1] < upper threshold AND Fair-value deviation[0] > upper threshold
Calculation: Lower crossing = net liquidity > 0 AND Fair-value deviation[1] > lower threshold AND Fair-value deviation[0] < lower threshold
Calculation: After start date = datetime >= start date at 00:00 in the instrument timezone
Calculation: On close date = datetime's year, month, and day equal the corresponding close-date parameters
Long: Lower crossing OR (inverse enabled AND After start date AND Upper crossing AND strategy mode permits both sides or short entries only)
Short: Upper crossing OR (inverse enabled AND After start date AND Lower crossing AND strategy mode permits both sides or long entries only) OR (inverse enabled AND strategy mode permits both sides AND use-close-date enabled AND On close date AND NOT (After start date AND Upper crossing))
Exit: short, strategy mode permits short entries only AND inverse disabled AND ((After start date AND Lower crossing) OR (use-close-date enabled AND On close date))
Exit: long, strategy mode permits short entries only AND inverse enabled AND ((After start date AND Lower crossing) OR (use-close-date enabled AND On close date))
Exit: long, strategy mode permits long entries only AND inverse disabled AND ((After start date AND Upper crossing) OR (use-close-date enabled AND On close date))
Exit: short, strategy mode permits long entries only AND inverse enabled AND ((After start date AND Upper crossing) OR (use-close-date enabled AND On close date))
Exit: long, strategy mode permits both sides AND inverse disabled AND On close date AND NOT (After start date AND Upper crossing) AND NOT (After start date AND Lower crossing)
Exit: short, strategy mode permits both sides AND inverse disabled AND On close date AND NOT (After start date AND Upper crossing) AND NOT (After start date AND Lower crossing)
Exit: long, strategy mode permits both sides AND inverse enabled AND On close date AND use-close-date disabled AND NOT (After start date AND Upper crossing) AND NOT (After start date AND Lower crossing)
Exit: short, strategy mode permits both sides AND inverse enabled AND On close date AND use-close-date disabled AND NOT (After start date AND Upper crossing) AND NOT (After start date AND Lower crossing)
Calculation: Net liquidity = Federal Reserve balance sheet - Treasury General Account - reverse repo balance
Calculation: SPX fair value = net liquidity / parameter 1 / parameter 2 - parameter 3
Calculation: SPX deviation = SPX closing price on T1 - SPX fair value
Short: net liquidity > parameter 4 AND previous SPX deviation < upper threshold AND current SPX deviation > upper threshold
Long: net liquidity > parameter 4 AND previous SPX deviation > lower threshold AND current SPX deviation < lower threshold
Long: direction reversal enabled AND long entries enabled AND net liquidity > parameter 4 AND previous SPX deviation < upper threshold AND current SPX deviation > upper threshold AND on or after the start date
Short: direction reversal enabled AND short entries enabled AND net liquidity > parameter 4 AND previous SPX deviation > lower threshold AND current SPX deviation < lower threshold AND on or after the start date
Short: direction reversal enabled AND both directions enabled AND (net liquidity > parameter 4 AND previous SPX deviation > lower threshold AND current SPX deviation < lower threshold AND on or after the start date OR close-date option enabled AND on the close date)
Exit: Short, net liquidity > parameter 4 AND ((previous SPX deviation > lower threshold AND current SPX deviation < lower threshold AND normal direction AND only short entries enabled) OR (previous SPX deviation < upper threshold AND current SPX deviation > upper threshold AND reversed direction AND only long entries enabled)) OR on the close date when date-based closing is enabled
Exit: Long, net liquidity > parameter 4 AND ((previous SPX deviation < upper threshold AND current SPX deviation > upper threshold AND normal direction AND only long entries enabled) OR (previous SPX deviation > lower threshold AND current SPX deviation < lower threshold AND reversed direction AND only short entries enabled)) OR on the close date when date-based closing is enabled