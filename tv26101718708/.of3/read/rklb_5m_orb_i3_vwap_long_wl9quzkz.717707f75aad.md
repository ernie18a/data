Calculation: opening range high = high of the first regular-session chart bar of each day
Calculation: opening range low = low of the first regular-session chart bar of each day
Calculation: opening range midpoint = (opening range high + opening range low) / 2
Calculation: opening range percentage = 100 * (opening range high - opening range low) / opening range midpoint
Calculation: long stop-entry price = opening range high + breakout buffer in ticks * minimum tick
Calculation: short stop-entry price = opening range low - breakout buffer in ticks * minimum tick
Calculation: long risk = long stop-entry price - opening range low
Calculation: short risk = opening range high - short stop-entry price
Calculation: long target = long stop-entry price + long risk * reward/risk
Calculation: short target = short stop-entry price - short risk * reward/risk
Long: trade-side setting permits long AND during the entry window AND opening range is ready AND minimum opening range percentage <= opening range percentage <= maximum opening range percentage AND long risk > minimum tick AND high >= long stop-entry price AND (VWAP filter is disabled OR close > VWAP(hlc3)) AND (retest entry is disabled OR low <= opening range high has occurred during the entry window since the opening range became ready) AND no trade has filled that day AND position is flat
Short: trade-side setting permits short AND during the entry window AND opening range is ready AND minimum opening range percentage <= opening range percentage <= maximum opening range percentage AND short risk > minimum tick AND low <= short stop-entry price AND (VWAP filter is disabled OR close < VWAP(hlc3)) AND (retest entry is disabled OR high >= opening range low has occurred during the entry window since the opening range became ready) AND no trade has filled that day AND position is flat
Exit: Long, low <= opening range low OR high >= long target OR during the flat window OR outside the regular session
Exit: Short, high >= opening range high OR low <= short target OR during the flat window OR outside the regular session