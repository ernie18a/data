Calculation: Swing high/low = a pivot high/low confirmed after the configured bars on both sides
Calculation: Bullish/bearish FVG = current low above the high two bars earlier / current high below the low two bars earlier, with gap at least the configured minimum size
Calculation: Bullish/bearish iFVG = a bullish/bearish FVG whose close crosses below its lower boundary / above its upper boundary
Calculation: ATR = average true range over its configured lookback
Calculation: Displacement = absolute candle body greater than ATR times the configured multiplier
Calculation: Not in chop = ATR greater than ATR’s longer-lookback average times the configured minimum ratio
Calculation: Confirmed bullish sweep = low below the latest confirmed swing low, close back above it, and lower wick greater than the configured fraction of candle range
Calculation: Confirmed bearish sweep = high above the latest confirmed swing high, close back below it, and upper wick greater than the configured fraction of candle range
Calculation: Bullish order block = prior bar’s open-to-close range when current close exceeds prior high and bullish body exceeds ATR
Calculation: Bearish order block = prior bar’s open-to-close range when current close falls below prior low and bearish body exceeds ATR
Calculation: Bullish/bearish confluence = one point each for a confirmed bullish/bearish sweep or iFVG reversal; recent same-direction SMT; same-direction CHoCH or trend; price overlapping a same-direction FVG or iFVG; and a same-direction CISD label
Long: current low below latest confirmed swing low and current low <= bullish iFVG upper boundary and current high >= its lower boundary, OR confirmed bullish sweep or bullish iFVG overlap AND close > open AND displacement; for confirmed setup markers, bullish confluence >= B minimum, session gate open, not in chop, and more than cooldown bars since the prior bullish setup; A++ requires confluence >= A++ minimum, while B requires confluence < A++ minimum
Long: close > close[1] AND close[1] > close[2] AND (close[2] > close[3] OR the configured C2/C3 rule is satisfied), last CISD direction is not bullish, and the configured minimum bars have elapsed since its prior label
Long: close > latest confirmed swing high AND trend direction is not bullish
Long: low < latest confirmed swing low AND close > latest confirmed swing low AND lower wick / candle range > configured wick fraction
Long: low > high two bars earlier AND gap >= configured minimum size
Long: close > prior bar high AND close - open > ATR
Short: current high above latest confirmed swing high and current low <= bearish iFVG upper boundary and current high >= its lower boundary, OR confirmed bearish sweep or bearish iFVG overlap AND close < open AND displacement; for confirmed setup markers, bearish confluence >= B minimum, session gate open, not in chop, and more than cooldown bars since the prior bearish setup; A++ requires confluence >= A++ minimum, while B requires confluence < A++ minimum
Short: close < close[1] AND close[1] < close[2] AND (close[2] < close[3] OR the configured C2/C3 rule is satisfied), last CISD direction is not bearish, and the configured minimum bars have elapsed since its prior label
Short: close < latest confirmed swing low AND trend direction is not bearish
Short: high > latest confirmed swing high AND close < latest confirmed swing high AND upper wick / candle range > configured wick fraction
Short: high < low two bars earlier AND gap >= configured minimum size
Short: close < prior bar low AND open - close > ATR