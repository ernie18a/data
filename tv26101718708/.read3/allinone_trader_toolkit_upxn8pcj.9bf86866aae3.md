Calculation: CandleBody = abs(Close - Open)
Calculation: ImpulseCandle = CandleBody > impulse multiple * ATR(lookback)
Calculation: BasingBarCount = largest k, not above maximum basing bars, such that High[i] - Low[i] < ATR(lookback) for every i from 1 to k
Calculation: BasingSpan = highest High[i] minus lowest Low[i], for i from 1 to BasingBarCount
Calculation: ZoneScore = round(CandleBody / BasingSpan), clamped to the score range, with the ratio set to the top of the score range when BasingSpan is not positive
Long: ImpulseCandle AND Close > Open AND BasingBarCount > 0 AND ZoneScore >= minimum zone score
Short: ImpulseCandle AND Close < Open AND BasingBarCount > 0 AND ZoneScore >= minimum zone score
Calculation: OpeningRangeHigh = highest High over the bars within the opening range length after the most recent regular session open
Calculation: OpeningRangeLow = lowest Low over the bars within the opening range length after the most recent regular session open
Calculation: PostRange = current bar is at or after the opening range length has elapsed since the most recent regular session open and before the next regular session open
Calculation: CloseOutsideRange = Close > OpeningRangeHigh OR Close < OpeningRangeLow
Long: PostRange AND Close > OpeningRangeHigh AND no earlier bar in PostRange had CloseOutsideRange
Short: PostRange AND Close < OpeningRangeLow AND no earlier bar in PostRange had CloseOutsideRange