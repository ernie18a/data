Calculation: Opening range high/low = high/low of the first regular-session chart bar; hold fixed for the session
Calculation: Opening range midpoint = (opening range high + opening range low) / 2
Calculation: Opening range percentage = (opening range high − opening range low) / opening range midpoint × 100
Calculation: Long entry stop = opening range high + breakout buffer
Calculation: Short entry stop = opening range low − breakout buffer
Calculation: Long risk = long entry stop − opening range low
Calculation: Short risk = opening range high − short entry stop
Calculation: Long target = long entry stop + long risk × reward/risk multiple
Calculation: Short target = short entry stop − short risk × reward/risk multiple
Long: During the entry window AND opening range percentage is within the allowed range AND no trade has been taken this session AND flat AND long risk exceeds one tick AND close > session VWAP AND (retest is not required OR a prior entry-window low <= opening range high) AND high >= long entry stop
Short: During the entry window AND opening range percentage is within the allowed range AND no trade has been taken this session AND flat AND short risk exceeds one tick AND close < session VWAP AND (retest is not required OR a prior entry-window high >= opening range low) AND low <= short entry stop
Exit: Long, low <= opening range low OR high >= long target OR in the force-flat window OR outside the regular session
Exit: Short, high >= opening range high OR low <= short target OR in the force-flat window OR outside the regular session