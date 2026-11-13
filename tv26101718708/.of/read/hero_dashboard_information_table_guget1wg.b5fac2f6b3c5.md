Calculation: VWAP = daily-reset cumulative sum(close*volume)/sum(volume)
Calculation: PrevDayHigh/PrevDayLow = high/low of the last completed bar of a higher (daily) timeframe
Calculation: OpeningRange = highest high and lowest low of the bars in the first part of each session (the opening range); stays fixed after the opening range ends and is unset until the first opening-range bar of each day
Calculation: HeroScore = sum of weighted binary flags, using this weight order: (close > VWAP) largest; (close > PrevDayHigh OR close < PrevDayLow) and (close > OpeningRange high OR close < OpeningRange low), both mid-sized; (volume > multiple of its simple moving average over a longer lookback) smaller; (ATR > simple moving average of ATR, with the average using a longer lookback than the ATR) smallest
Long: HeroScore >= high threshold AND close > EMA AND close > VWAP
Short: HeroScore >= same high threshold AND close < EMA AND close < VWAP