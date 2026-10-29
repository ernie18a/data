Calculation: Upper base = highest high over the lookback beginning the specified offset before the evaluated bar, minus ATR multiplied by a factor; use the indicator timeframe, which may be higher or lower than the chart timeframe, and the last completed bar.
Calculation: Lower base = lowest low over the same lookback and timeframe, plus ATR multiplied by the same factor.
Calculation: Up and down bands = recursively assign bands using the prior direction: when prior direction is nonnegative, if close < upper base set direction negative, Up = lower base, and Down = upper base; otherwise Up = upper base and Down = lower base. When prior direction is negative, if close > lower base set direction positive, Down = lower base, and Up = upper base; otherwise Up = lower base and Down = upper base.
Long: previous Down <= previous Up AND current Down > current Up
Short: previous Down >= previous Up AND current Down < current Up
Exit: long, previous Down >= previous Up AND current Down < current Up
Exit: short, previous Down <= previous Up AND current Down > current Up