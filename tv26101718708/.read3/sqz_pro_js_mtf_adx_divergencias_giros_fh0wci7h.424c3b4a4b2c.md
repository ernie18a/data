Calculation: Squeeze On(T) = lower Bollinger Bands(close, squeeze lookback, BB multiplier) > lower Keltner Channels(close, high, low, squeeze lookback, KC multiplier) AND upper Bollinger Bands(close, squeeze lookback, BB multiplier) < upper Keltner Channels(close, high, low, squeeze lookback, KC multiplier), calculated on T bars and requested on chart bars with lookahead off (historically using completed T bars; in real time using the still-forming T bar)
Calculation: Momentum(T) = Squeeze Momentum(close, high, low, squeeze lookback, momentum lookback), calculated on T bars and requested on chart bars with lookahead off (historically using completed T bars; in real time using the still-forming T bar)
Calculation: DMI(T) = DMI(high, low, close, DI lookback, ADX smoothing), calculated on T bars and requested on chart bars with lookahead off (historically using completed T bars; in real time using the still-forming T bar)
Calculation: Bullish MTF state(T) = Momentum(T) > 0 AND NOT Squeeze On(T) AND DMI(T).ADX > weak ADX threshold AND DMI(T).DI+ > DMI(T).DI-
Calculation: Bearish MTF state(T) = Momentum(T) < 0 AND NOT Squeeze On(T) AND DMI(T).ADX > weak ADX threshold AND DMI(T).DI- > DMI(T).DI+
Calculation: MTF buy event(T) = Momentum(T) crosses above 0 OR (Momentum(T) < 0 AND Momentum(T) > nz(Momentum(T)[1], 0) AND nz(Momentum(T)[1], 0) <= nz(Momentum(T)[2], 0)), evaluated on T bars and requested on chart bars with lookahead off (historically using completed T bars; in real time using the still-forming T bar)
Calculation: MTF sell event(T) = Momentum(T) crosses below 0 OR (Momentum(T) > 0 AND Momentum(T) < Momentum(T)[1] AND nz(Momentum(T)[1], 0) >= nz(Momentum(T)[2], 0)), evaluated on T bars and requested on chart bars with lookahead off (historically using completed T bars; in real time using the still-forming T bar)
Calculation: Bullish radar event(T) = Bullish MTF state(T) AND MTF buy event(T)
Calculation: Bearish radar event(T) = Bearish MTF state(T) AND MTF sell event(T)
Long: Momentum(chart) crosses above 0
Long: Momentum(chart) < 0 AND Momentum(chart) > nz(Momentum(chart)[1], 0) AND nz(Momentum(chart)[1], 0) <= nz(Momentum(chart)[2], 0)
Short: Momentum(chart) crosses below 0
Short: Momentum(chart) > 0 AND Momentum(chart) < Momentum(chart)[1] AND nz(Momentum(chart)[1], 0) >= nz(Momentum(chart)[2], 0)
Long: On chart timeframe T5 or higher (T1–T8 ordered shortest to longest), with divergence display and the corresponding divergence type enabled, both the current and preceding confirmed Squeeze Momentum pivot lows are below 0, their separation is at most the maximum pivot range, and either (regular bullish enabled AND current low at the oscillator pivot < preceding low at the oscillator pivot AND current oscillator pivot > preceding oscillator pivot) OR (hidden bullish enabled AND current low at the oscillator pivot > preceding low at the oscillator pivot AND current oscillator pivot < preceding oscillator pivot)
Short: On chart timeframe T5 or higher (T1–T8 ordered shortest to longest), with divergence display and the corresponding divergence type enabled, both the current and preceding confirmed Squeeze Momentum pivot highs are above 0, their separation is at most the maximum pivot range, and either (regular bearish enabled AND current high at the oscillator pivot > preceding high at the oscillator pivot AND current oscillator pivot < preceding oscillator pivot) OR (hidden bearish enabled AND current high at the oscillator pivot < preceding high at the oscillator pivot AND current oscillator pivot > preceding oscillator pivot)
Long: For any enabled timeframe T1–T8, Bullish MTF state(T)
Short: For any enabled timeframe T1–T8, Bearish MTF state(T)
Long: For any enabled timeframe T1–T8, MTF buy event(T)
Short: For any enabled timeframe T1–T8, MTF sell event(T)
Long: For any enabled timeframe T4–T8, Bullish radar event(T)
Short: No enabled timeframe T4–T8 has a Bullish radar event(T) AND at least one enabled timeframe T4–T8 has a Bearish radar event(T)
Long: No enabled timeframe T4–T8 has either radar event AND the count of enabled T1–T8 with Bullish MTF state(T) is at least the minimum count
Short: No enabled timeframe T4–T8 has either radar event AND the count of enabled T1–T8 with Bullish MTF state(T) is below the minimum count AND the count with Bearish MTF state(T) is at least the minimum count