Calculation: Bullish inside bar = high < previous bar high AND low > previous bar low AND close >= open
Calculation: Bearish inside bar = high < previous bar high AND low > previous bar low AND close < open
Long: bullish inside bar occurred in the current bar or previous N bars AND close > high N bars ago AND close > EMA AND (ADX > threshold if the ADX filter is enabled)
Short: bearish inside bar occurred in the current bar or previous N bars AND close < low N bars ago AND close < EMA AND (ADX > threshold if the ADX filter is enabled)
Exit: Long, close < entry price × (1 − configured stop percentage) OR high >= entry price × (1 + each configured take-profit percentage)
Exit: Short, close > entry price × (1 + configured stop percentage) OR low <= entry price × (1 − each configured take-profit percentage)