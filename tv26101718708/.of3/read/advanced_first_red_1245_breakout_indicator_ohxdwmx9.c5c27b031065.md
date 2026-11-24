Calculation: First qualifying bearish-bar range = high and low of the first T1 bar within the session, except at the excluded-time parameter, where close < open; reset at each new T2 bar, calculate on T1 bars using the still-forming bar, and sample onto chart bars with lookahead off.
Calculation: Timed range = maximum high and minimum low of T1 bars from the start-time parameter inclusive to the end-time parameter exclusive; reset at each new T2 bar, accumulate on T1 bars through the end-time parameter using the still-forming bar, and sample onto chart bars with lookahead off.
Calculation: Ratio level(high, low, ratio) = low + ((high - low) * ratio)
Calculation: Bullish EMA alignment = EMA(close, shorter lookback) > EMA(close, longer lookback) AND EMA(close, intermediate lookback) > EMA(close, longer lookback)
Calculation: Bearish EMA alignment = EMA(close, longer lookback) > EMA(close, shorter lookback) AND EMA(close, longer lookback) > EMA(close, intermediate lookback)
Calculation: Bullish breakout impulse = close > high[1] AND close > highest(high, breakout-strength lookback)[1]
Calculation: Bearish breakout impulse = close < low[1] AND close < lowest(low, breakout-strength lookback)[1]
Long: Bullish EMA alignment
Short: Bearish EMA alignment
Long: close crosses above (First qualifying bearish-bar range high + breakout-buffer parameter) AND bullish EMA alignment AND (no prior main long breakout signal OR chart bars since the prior main long breakout signal >= signal-cooldown parameter)
Long: close crosses above (Timed range high + breakout-buffer parameter) AND bullish EMA alignment AND (no prior main long breakout signal OR chart bars since the prior main long breakout signal >= signal-cooldown parameter)
Short: close crosses below (First qualifying bearish-bar range low - breakout-buffer parameter) AND bearish EMA alignment AND (no prior main short breakout signal OR chart bars since the prior main short breakout signal >= signal-cooldown parameter)
Short: close crosses below (Timed range low - breakout-buffer parameter) AND bearish EMA alignment AND (no prior main short breakout signal OR chart bars since the prior main short breakout signal >= signal-cooldown parameter)
Long: close crosses above Ratio level(First qualifying bearish-bar range high, First qualifying bearish-bar range low, lower-ratio parameter) AND this range-level long signal has not occurred since the new T2 bar
Long: close crosses above Ratio level(First qualifying bearish-bar range high, First qualifying bearish-bar range low, higher-ratio parameter) AND this range-level long signal has not occurred since the new T2 bar
Long: close crosses above Ratio level(Timed range high, Timed range low, lower-ratio parameter) AND this range-level long signal has not occurred since the new T2 bar
Long: close crosses above Ratio level(Timed range high, Timed range low, higher-ratio parameter) AND this range-level long signal has not occurred since the new T2 bar
Short: close crosses below Ratio level(First qualifying bearish-bar range high, First qualifying bearish-bar range low, lower-ratio parameter)
Short: close crosses below Ratio level(First qualifying bearish-bar range high, First qualifying bearish-bar range low, higher-ratio parameter)
Short: close crosses below Ratio level(Timed range high, Timed range low, lower-ratio parameter)
Short: close crosses below Ratio level(Timed range high, Timed range low, higher-ratio parameter)
Long: previous chart bar close < previous chart bar open AND Bullish breakout impulse AND bullish EMA alignment AND current bar time is within the session
Short: previous chart bar close > previous chart bar open AND Bearish breakout impulse AND bearish EMA alignment AND current bar time is within the session
Exit: long, while armed by a main long breakout or either fib long signal from the first qualifying bearish-bar range and before a first-range main short breakout or new T2 bar, close < low of the most recent arming bar
Exit: long, while armed by a main long breakout or either fib long signal from the timed range and before a timed-range main short breakout or new T2 bar, close < low of the most recent arming bar
Exit: short, while armed by a first-range main short breakout and before a main long breakout or fib long signal from the first qualifying bearish-bar range, or a new T2 bar, close > high of the most recent arming bar
Exit: short, while armed by a timed-range main short breakout and before a main long breakout or fib long signal from the timed range, or a new T2 bar, close > high of the most recent arming bar