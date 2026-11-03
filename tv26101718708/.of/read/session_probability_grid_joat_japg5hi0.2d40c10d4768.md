Calculation: Session = bars whose timestamps fall within the configured daily session; session open is the open of its first bar, and session high and low are the highest high and lowest low so far in that session.
Calculation: Ladder base = the session high minus session low until the configured opening-range bar count is reached; thereafter, the highest high minus the lowest low of those opening bars. Floor each range at the minimum price increment.
Calculation: Upper and lower ladder levels = session open plus or minus ladder base multiplied by the corresponding step. Use an inner, a middle, and an outer step, respectively increasing in distance from the open.
Calculation: Hit probability = (hits + 1) / (samples + 2), calculated separately for the upper and lower inner levels. Starting with the first completed session, count each completed session as a sample until the sample cap is reached; a hit occurs if any confirmed bar in that session reaches its then-current corresponding inner level. Do not update the counts after the cap is reached.
Calculation: Session VWAP = cumulative sum of typical price times volume divided by cumulative volume since the start of the latest session; retain the last value outside the session.
Long: In session AND close > upper inner level AND previous close <= current upper inner level AND upper inner-level hit probability >= probability gate.
Short: In session AND close < lower inner level AND previous close >= current lower inner level AND lower inner-level hit probability >= probability gate.
Short: In session AND high >= upper outer level AND close < upper middle level AND session range / ATR > anomaly threshold.
Long: In session AND low <= lower outer level AND close > lower middle level AND session range / ATR > anomaly threshold.
Short: In session AND close > upper inner level.
Long: In session AND close < lower inner level AND close <= upper inner level.
Long: No expansion or exhaustion condition is true AND close >= session VWAP.
Short: No expansion or exhaustion condition is true AND close < session VWAP.
Long: No expansion or exhaustion condition is true AND close > session open.
Short: No expansion or exhaustion condition is true AND close < session open.