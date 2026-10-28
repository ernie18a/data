Calculation: CF proxy = rate of change of the average close of financial and real-estate assets over a lookback; optionally include a speculative-sector asset in the average if enabled
Calculation: Productive proxy = rate of change of the industrial asset close over the same lookback as the CF proxy
Calculation: CF momentum = rate of change of the CF proxy over a lookback
Calculation: Bubble score = percentile rank of CF proxy divided by productive proxy over a longer lookback, multiplied by 1.2 and capped to 0–100; if CF momentum is positive and broad-market volume exceeds its simple moving average times a volume multiplier, multiply the score by 1.25 and cap it to 100
Calculation: Minsky score = percentile rank of CF momentum over the same longer lookback as the bubble score; if the rate of change of CF momentum is positive and the bubble score exceeds 50, multiply the rank by 1.35 and cap it to 100
Long: Bubble score < 35 AND productive proxy crosses above zero
Short: Minsky score crosses above 75
Short: Bubble score > 80 AND CF proxy crosses below its exponential moving average
