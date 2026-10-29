Calculation: Reference high/low = high/low of the higher-timeframe bar starting at 05:30 IST, using its last completed bar
Calculation: Long retracement level = Reference high - 0.25 × (Reference high - Reference low)
Calculation: Short retracement level = Reference high - 0.75 × (Reference high - Reference low)
Calculation: Long stop = Short retracement level; short stop = Long retracement level
Calculation: Long target = Long entry price + 2 × abs(Long entry price - Long stop); short target = Short entry price - 2 × abs(Short stop - Short entry price)
Long: After the first close above Reference high of the day, before any trade that day, low <= Long retracement level AND close > open
Short: After the first close below Reference low of the day, before any trade that day, high >= Short retracement level AND close < open
Exit: Long, high >= Long target OR (high < Long target AND low <= Long stop)
Exit: Short, low <= Short target OR (low > Short target AND high >= Short stop)