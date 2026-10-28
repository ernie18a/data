Calculation: Opening range high = high of the first completed regular-session bar
Calculation: Opening range low = low of the first completed regular-session bar
Calculation: Opening range midpoint = (opening range high + opening range low) / 2
Calculation: Opening range percentage = (opening range high - opening range low) / opening range midpoint × 100
Long: opening range percentage is within the configured minimum and maximum AND during the entry window AND no trade has been taken this session AND no position is open AND opening range high + breakout buffer - opening range low exceeds one minimum tick AND close > session VWAP AND high >= opening range high + breakout buffer
Short: opening range percentage is within the configured minimum and maximum AND during the entry window AND no trade has been taken this session AND no position is open AND opening range high - (opening range low - breakout buffer) exceeds one minimum tick AND close < session VWAP AND low <= opening range low - breakout buffer
Exit: Long, low <= opening range low OR high >= entry price + (entry price - opening range low) × reward/risk multiple OR during the force-flat window OR outside the regular session
Exit: Short, high >= opening range high OR low <= entry price - (opening range high - entry price) × reward/risk multiple OR during the force-flat window OR outside the regular session