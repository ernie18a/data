Calculation: BarBody(n) = close[n × P] − open[n × P] on chart bars, including the bar still forming
Calculation: LongImpulse(n) = −BarBody(n) if BarBody(n) < 0 and BarBody(n+1) > 0; otherwise 0
Calculation: ShortImpulse(n) = BarBody(n) if BarBody(n) > 0 and BarBody(n+1) < 0; otherwise 0
Calculation: LongImpulseMean = arithmetic mean of LongImpulse(n) for n=0 through N−1, including zeros
Calculation: ShortImpulseMean = arithmetic mean of ShortImpulse(n) for n=0 through N−1, including zeros
Calculation: LongSuccessMean = arithmetic mean of LongImpulse(n) values greater than the current quote spread; 0 if there are none
Calculation: ShortSuccessMean = arithmetic mean of ShortImpulse(n) values greater than the current quote spread; 0 if there are none
Calculation: LongImpulseQuality = count of n from 0 through N−1 where LongImpulse(n) > 0
Calculation: ShortImpulseQuality = count of n from 0 through N−1 where ShortImpulse(n) > 0
Calculation: LongSuccessQuality = count of n from 0 through N−1 where LongImpulse(n) exceeds the current quote spread
Calculation: ShortSuccessQuality = count of n from 0 through N−1 where ShortImpulse(n) exceeds the current quote spread
Calculation: LongWeight = LongImpulseMean × LongImpulseQuality
Calculation: ShortWeight = ShortImpulseMean × ShortImpulseQuality
Calculation: LongSuccessWeight = LongSuccessMean × LongSuccessQuality
Calculation: ShortSuccessWeight = ShortSuccessMean × ShortSuccessQuality
Long: LongImpulse(0) > 0
Short: ShortImpulse(0) > 0
Long: LongImpulse(0) > 0 AND LongImpulse(0) ≥ LongSuccessMean AND, when Cyberia logic is active, P > previous P AND LongWeight > ShortWeight AND LongSuccessWeight ≥ ShortSuccessWeight AND (LongSuccessMean = 0 OR LongImpulse(0) ≤ LongSuccessMean × reversal-block multiplier)
Short: ShortImpulse(0) > 0 AND ShortImpulse(0) ≥ ShortSuccessMean AND, when Cyberia logic is active, P > previous P AND ShortWeight > LongWeight AND ShortSuccessWeight ≤ LongSuccessWeight AND (ShortSuccessMean = 0 OR ShortImpulse(0) ≤ ShortSuccessMean × reversal-block multiplier)
Long: ShortImpulse(0) > 0 AND (close[0] − close[P]) / money-train level ≥ ShortSuccessMean AND ShortSuccessMean > 0
Short: LongImpulse(0) > 0 AND (close[P] − close[0]) / money-train level ≥ LongSuccessMean AND LongSuccessMean > 0
Long: For some i from 0 through P−1, close[i+1] − close[0] > LongSuccessMean × (i+1) AND LongSuccessMean > 0
Short: For some i from 0 through P−1, close[0] − close[i+1] > ShortSuccessMean × (i+1) AND ShortSuccessMean > 0
Long: When the MA filter is active, EMA(close, lookback)[0] ≥ EMA(close, lookback)[1]
Short: When the MA filter is active, EMA(close, lookback)[0] ≤ EMA(close, lookback)[1]
Long: When the ADX filter is active, +DI(ADX lookback, high)[0] ≥ −DI(ADX lookback, high)[0]
Short: When the ADX filter is active, +DI(ADX lookback, high)[0] ≤ −DI(ADX lookback, high)[0]
Long: When the CCI filter is active, CCI(typical price, lookback)[0] ≤ upper CCI threshold
Short: When the CCI filter is active, CCI(typical price, lookback)[0] ≥ lower CCI threshold
Long: When the fractal filter is active, the most recent nonzero fractal is not an upper fractal
Short: When the fractal filter is active, the most recent nonzero fractal is not a lower fractal
Calculation: Rising MACD score = sum of current MACD(main, fast lookback, slow lookback, signal lookback) values on chart bars taking values from each progressively longer timeframe T where the current value is greater than the preceding value on that timeframe; compare the bar still forming with the last completed bar
Calculation: Falling MACD score = sum of current MACD(main, fast lookback, slow lookback, signal lookback) values on chart bars taking values from each progressively longer timeframe T where the current value is less than the preceding value on that timeframe; compare the bar still forming with the last completed bar
Long: When the MACD filter is active, Falling MACD score ≤ Rising MACD score
Short: When the MACD filter is active, Falling MACD score ≥ Rising MACD score
Long: When the reverse detector is active and (LongImpulse(0) > LongImpulseMean × reversal index OR ShortImpulse(0) > ShortImpulseMean × reversal index), invert the long permission established by preceding direction filters
Short: When the reverse detector is active and (LongImpulse(0) > LongImpulseMean × reversal index OR ShortImpulse(0) > ShortImpulseMean × reversal index), invert the short permission established by preceding direction filters
Exit: long, current bid ≤ the position's entry-time protective stop price when shadow-stop closing is enabled OR (entry price < current bid AND (current bid − entry price ≥ ShortSuccessMean > 0 OR current bid − entry price ≥ LongSuccessMean > 0 OR LongSuccessMean = 0 AND ShortSuccessMean = 0) AND NOT (close[0] − close[1] ≥ ShortSuccessMean × continuation multiplier AND ShortSuccessMean > 0)
Exit: short, current ask ≥ the position's entry-time protective stop price when shadow-stop closing is enabled OR (entry price > current ask AND (entry price − current ask ≥ LongSuccessMean > 0 OR entry price − current ask ≥ ShortSuccessMean > 0 OR LongSuccessMean = 0 AND ShortSuccessMean = 0) AND NOT (close[1] − close[0] ≥ LongSuccessMean × continuation multiplier AND LongSuccessMean > 0)