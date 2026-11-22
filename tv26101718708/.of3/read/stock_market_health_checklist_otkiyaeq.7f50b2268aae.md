Long: For each market MA crossover pair, EMA or SMA(market close, fast lookback, pair MA type) > EMA or SMA(market close, slow lookback, same pair MA type), using that pair's separately parameterized fast and slow lookbacks; calculate on T1 bars and map to chart bars with lookahead off, using the current T1 bar in real time and the last completed T1 bar historically.
Short: For each market MA crossover pair, EMA or SMA(market close, fast lookback, pair MA type) <= EMA or SMA(market close, slow lookback, same pair MA type), using that pair's separately parameterized fast and slow lookbacks; calculate on T1 bars and map to chart bars with lookahead off, using the current T1 bar in real time and the last completed T1 bar historically.
Long: For each of four separately parameterized market MA lengths and types, EMA or SMA(market close, MA lookback, selected type) > that MA's value slope lookback bars ago; the slope lookback is shared by all four; calculate on T1 bars and map to chart bars with lookahead off, using the current T1 bar in real time and the last completed T1 bar historically.
Short: For each of four separately parameterized market MA lengths and types, EMA or SMA(market close, MA lookback, selected type) <= that MA's value slope lookback bars ago; the slope lookback is shared by all four; calculate on T1 bars and map to chart bars with lookahead off, using the current T1 bar in real time and the last completed T1 bar historically.
Long: For either of the two separately parameterized market MA lengths and types, market close > EMA or SMA(market close, MA lookback, selected type); calculate on T1 bars and map to chart bars with lookahead off, using the current T1 bar in real time and the last completed T1 bar historically.
Short: For either of the two separately parameterized market MA lengths and types, market close <= EMA or SMA(market close, MA lookback, selected type); calculate on T1 bars and map to chart bars with lookahead off, using the current T1 bar in real time and the last completed T1 bar historically.
Long: VIX close on T2 < VIX threshold; calculate on T2 bars and map to chart bars with lookahead on, using the current/forming T2 bar.
Short: VIX close on T2 >= VIX threshold; calculate on T2 bars and map to chart bars with lookahead on, using the current/forming T2 bar.
Long: T2108 close on T2 <= oversold threshold; calculate on T2 bars and map to chart bars with lookahead on, using the current/forming T2 bar.
Short: T2108 close on T2 >= overbought threshold; calculate on T2 bars and map to chart bars with lookahead on, using the current/forming T2 bar.
Long: RSI(market close, market RSI lookback) on T1 <= RSI oversold threshold; calculate on T1 bars and map to chart bars with lookahead off, using the current T1 bar in real time and the last completed T1 bar historically.
Short: RSI(market close, market RSI lookback) on T1 >= RSI overbought threshold; calculate on T1 bars and map to chart bars with lookahead off, using the current T1 bar in real time and the last completed T1 bar historically.
Long: For each of four separately parameterized chart MA lengths and types, chart close > EMA or SMA(chart close, MA lookback, selected type); calculate on T3 bars and map to chart bars with lookahead on, using the current/forming T3 bar.
Short: For each of four separately parameterized chart MA lengths and types, chart close <= EMA or SMA(chart close, MA lookback, selected type); calculate on T3 bars and map to chart bars with lookahead on, using the current/forming T3 bar.
Long: For each of four separately parameterized chart MA lengths and types, EMA or SMA(chart close, MA lookback, selected type) > that MA's value chart slope lookback bars ago; the slope lookback is shared by all four; calculate on T3 bars and map to chart bars with lookahead on, using the current/forming T3 bar.
Short: For each of four separately parameterized chart MA lengths and types, EMA or SMA(chart close, MA lookback, selected type) <= that MA's value chart slope lookback bars ago; the slope lookback is shared by all four; calculate on T3 bars and map to chart bars with lookahead on, using the current/forming T3 bar.
Long: RSI(chart close, chart RSI lookback) on T3 <= RSI oversold threshold; calculate on T3 bars and map to chart bars with lookahead on, using the current/forming T3 bar.
Short: RSI(chart close, chart RSI lookback) on T3 >= RSI overbought threshold; calculate on T3 bars and map to chart bars with lookahead on, using the current/forming T3 bar.
Long: EMA/SMA(close of the market signal ticker at T1, first crossover fast period) > EMA/SMA(close of the market signal ticker at T1, first crossover slow period), using the first crossover MA type
Short: EMA/SMA(close of the market signal ticker at T1, first crossover fast period) <= EMA/SMA(close of the market signal ticker at T1, first crossover slow period), using the first crossover MA type
Long: EMA/SMA(close of the market signal ticker at T1, second crossover fast period) > EMA/SMA(close of the market signal ticker at T1, second crossover slow period), using the second crossover MA type
Short: EMA/SMA(close of the market signal ticker at T1, second crossover fast period) <= EMA/SMA(close of the market signal ticker at T1, second crossover slow period), using the second crossover MA type
Long: EMA/SMA(close of the market signal ticker at T1, third crossover fast period) > EMA/SMA(close of the market signal ticker at T1, third crossover slow period), using the third crossover MA type
Short: EMA/SMA(close of the market signal ticker at T1, third crossover fast period) <= EMA/SMA(close of the market signal ticker at T1, third crossover slow period), using the third crossover MA type
Long: EMA/SMA(close of the market signal ticker at T1, fourth crossover fast period) > EMA/SMA(close of the market signal ticker at T1, fourth crossover slow period), using the fourth crossover MA type
Short: EMA/SMA(close of the market signal ticker at T1, fourth crossover fast period) <= EMA/SMA(close of the market signal ticker at T1, fourth crossover slow period), using the fourth crossover MA type
Long: EMA/SMA(close of the market signal ticker at T1, first slope period) > its value at the slope lookback
Short: EMA/SMA(close of the market signal ticker at T1, first slope period) <= its value at the slope lookback
Long: EMA/SMA(close of the market signal ticker at T1, second slope period) > its value at the slope lookback
Short: EMA/SMA(close of the market signal ticker at T1, second slope period) <= its value at the slope lookback
Long: EMA/SMA(close of the market signal ticker at T1, third slope period) > its value at the slope lookback
Short: EMA/SMA(close of the market signal ticker at T1, third slope period) <= its value at the slope lookback
Long: EMA/SMA(close of the market signal ticker at T1, fourth slope period) > its value at the slope lookback
Short: EMA/SMA(close of the market signal ticker at T1, fourth slope period) <= its value at the slope lookback
Long: close of the market signal ticker at T1 > EMA/SMA(close of the market signal ticker at T1, first price-check period), using the first price-check MA type
Short: close of the market signal ticker at T1 <= EMA/SMA(close of the market signal ticker at T1, first price-check period), using the first price-check MA type
Long: close of the market signal ticker at T1 > EMA/SMA(close of the market signal ticker at T1, second price-check period), using the second price-check MA type
Short: close of the market signal ticker at T1 <= EMA/SMA(close of the market signal ticker at T1, second price-check period), using the second price-check MA type
Long: VIX close at T2 < VIX threshold
Short: VIX close at T2 >= VIX threshold
Long: T2108 breadth value at T2 <= oversold threshold
Short: T2108 breadth value at T2 >= overbought threshold
Long: RSI(close of the market signal ticker at T1, RSI period) <= oversold threshold
Short: RSI(close of the market signal ticker at T1, RSI period) >= overbought threshold