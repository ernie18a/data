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