Calculation: Candidate candle = immediately preceding completed bar of the higher detection timeframe, evaluated when a new detection-timeframe bar begins
Calculation: Candle range = high − low
Calculation: Upper wick = high − max(open, close); lower wick = min(open, close) − low
Calculation: Upper/lower wick percentage = respective wick ÷ candle range × 100 (0 when range is 0)
Calculation: Prior high/low = highest high / lowest low of the lookback bars preceding the candidate candle, using completed detection-timeframe bars
Long: Candidate low < prior low AND lower wick ≥ minimum wick size AND lower wick percentage > minimum wick percentage AND upper wick < lower wick × maximum opposite-wick percentage
Short: Candidate high > prior high AND upper wick ≥ minimum wick size AND upper wick percentage > minimum wick percentage AND lower wick < upper wick × maximum opposite-wick percentage