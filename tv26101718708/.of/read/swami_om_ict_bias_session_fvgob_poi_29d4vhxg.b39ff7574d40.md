Calculation: Weekly bias = bullish if the current, still-forming weekly bar's high is above the previous completed weekly high and its low is at least the previous weekly low; bearish if its high is at most the previous weekly high and its low is below the previous weekly low; otherwise bullish if its current close is above the midpoint of the previous weekly high and low, bearish otherwise
Calculation: Daily bias = bullish if the current, still-forming daily bar's high is above the previous completed daily high and its low is at least the previous daily low; bearish if its high is at most the previous daily high and its low is below the previous daily low; otherwise bullish if its current close is above the midpoint of the previous daily high and low, bearish otherwise
Calculation: ICT bias = Weekly bias if non-neutral; otherwise Daily bias
Calculation: Two-days-prior high/low = high/low of the daily bar two completed bars before the current daily bar
Calculation: TTrades bias = bullish if yesterday's close is above the two-days-prior high; bearish if below the two-days-prior low; otherwise, if yesterday swept both levels, bearish if yesterday's high-to-close distance is less than its close-to-low distance, bullish if greater; otherwise bearish if only yesterday's high swept its corresponding level, bullish if only its low swept; neutral otherwise
Calculation: Final bias = ICT bias if non-neutral; otherwise TTrades bias
Calculation: Average candle body = moving average of absolute close-minus-open over a lookback
Long: Final bias is bullish
Long: TTrades bias is bullish
Long: Current daily close <= midpoint of current daily high and low
Long: Current close > current open AND current candle body > average candle body multiplied by a factor AND current low > high two chart bars ago AND Final bias is bullish AND current bar is in a configured session
Short: Final bias is bearish
Short: TTrades bias is bearish
Short: Current daily close > midpoint of current daily high and low
Short: Current close < current open AND current candle body > average candle body multiplied by a factor AND current high < low two chart bars ago AND Final bias is bearish AND current bar is in a configured session