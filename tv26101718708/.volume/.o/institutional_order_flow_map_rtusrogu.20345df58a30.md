Calculation: Lower/upper wick percentage = lower/upper wick ÷ (high − low) × 100, where lower wick = min(open, close) − low and upper wick = high − max(open, close)
Calculation: Institutional volume = volume > moving average(volume, lookback) × volume multiplier
Calculation: Flow value = sum over the flow lookback of ((close − open) ÷ (high − low) × volume), normalized by the highest absolute flow value over a longer lookback and multiplied by 100
Calculation: Zone score = min(volume score + rejection score + trend score, 100), where volume score = min(round(pivot-bar volume ÷ max(current volume moving average, 1) × 25), 40), rejection score = min(round(pivot-bar wick percentage × 0.4), 30), and trend score = 30 when a buy zone is above the long-term EMA or a sell zone is below it, otherwise 10
Long: Institutional volume AND lower wick percentage >= wick threshold AND close > open
Short: Institutional volume AND upper wick percentage >= wick threshold AND close < open
Long: Normalized flow value > positive threshold
Short: Normalized flow value < negative threshold
Long: A confirmed pivot low has a zone score >= minimum score
Short: A confirmed pivot high has a zone score >= minimum score
Long: Highest score among active buy zones > highest score among active sell zones
Short: Highest score among active sell zones > highest score among active buy zones