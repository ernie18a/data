Calculation: Oscillator = TSI(source, shorter lookback, longer lookback) − selected moving average(TSI(source, shorter lookback, longer lookback), signal lookback), on chart bars
Calculation: Bullish chart state = oscillator >= 0 AND (oscillator > oscillator[1] OR oscillator is its first valid value)
Calculation: Bearish chart state = oscillator < 0 AND (oscillator < oscillator[1] OR oscillator is its first valid value)
Calculation: Bullish weakening state = oscillator >= 0 AND oscillator < oscillator[1]
Calculation: Bearish weakening state = oscillator < 0 AND oscillator > oscillator[1]
Calculation: Requested bullish state(T) = oscillator(T) >= 0 AND (oscillator(T) > oscillator[1](T) OR oscillator(T) is its first valid value), computed on T bars and returned on chart bars using the current T bar in real time and the completed T bar historically
Calculation: Requested bearish state(T) = oscillator(T) < 0 AND (oscillator(T) <= oscillator[1](T) OR oscillator(T) is its first valid value), computed on T bars and returned on chart bars using the current T bar in real time and the completed T bar historically
Calculation: Bullish alignment = bullish chart state AND requested bullish state(T1) AND requested bullish state(T2), AND requested bullish state(T3) when the selected alignment mode uses three timeframes
Calculation: Bearish alignment = bearish chart state AND requested bearish state(T1) AND requested bearish state(T2), AND requested bearish state(T3) when the selected alignment mode uses three timeframes
Long: (bullish chart state AND NOT bullish chart state[1]) OR (bullish alignment AND NOT bullish alignment[1])
Short: (bearish chart state AND NOT bearish chart state[1]) OR (bearish alignment AND NOT bearish alignment[1])
Exit: long, bullish weakening state AND NOT bullish weakening state[1]
Exit: short, bearish weakening state AND NOT bearish weakening state[1]