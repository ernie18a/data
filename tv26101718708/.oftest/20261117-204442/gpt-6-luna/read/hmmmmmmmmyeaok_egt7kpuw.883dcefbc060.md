Calculation: A open = open series from one aggregated timeframe, including its bar still forming
Calculation: Prior A open = A open from its last completed bar
Calculation: Prior B open = open from the last completed bar of a second aggregated timeframe
Calculation: C open = open series from a third aggregated timeframe, including its bar still forming
Calculation: Prior B momentum = prior B open minus its value at the momentum lookback bars earlier
Long: Prior A open < EMA of A open AND prior B momentum < 0 AND shorter-lookback EMA of input-bar open crosses below longer-lookback EMA of input-bar open AND shorter-lookback EMA of C open > longer-lookback EMA of C open
Short: Prior A open > EMA of A open AND prior B momentum > 0 AND shorter-lookback EMA of input-bar open crosses above longer-lookback EMA of input-bar open AND shorter-lookback EMA of C open > longer-lookback EMA of C open