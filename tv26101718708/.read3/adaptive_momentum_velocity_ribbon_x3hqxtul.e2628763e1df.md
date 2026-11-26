Calculation: HMA velocity(HMA lookback, velocity lookback) = Momentum(HMA(close, HMA lookback), velocity lookback)
Long: HMA velocity(short HMA lookback, velocity lookback) > 0
Short: HMA velocity(short HMA lookback, velocity lookback) <= 0
Long: HMA velocity(middle HMA lookback, velocity lookback) > 0
Short: HMA velocity(middle HMA lookback, velocity lookback) <= 0
Long: HMA velocity(long HMA lookback, velocity lookback) > 0
Short: HMA velocity(long HMA lookback, velocity lookback) <= 0
Long: HMA velocity(short HMA lookback, velocity lookback) > HMA velocity(middle HMA lookback, velocity lookback)
Short: HMA velocity(short HMA lookback, velocity lookback) <= HMA velocity(middle HMA lookback, velocity lookback)
Long: HMA velocity(middle HMA lookback, velocity lookback) > HMA velocity(long HMA lookback, velocity lookback)
Short: HMA velocity(middle HMA lookback, velocity lookback) <= HMA velocity(long HMA lookback, velocity lookback)
Long: HMA velocity(short HMA lookback, velocity lookback) > 0 AND HMA velocity(middle HMA lookback, velocity lookback) > 0 AND HMA velocity(long HMA lookback, velocity lookback) > 0
Short: HMA velocity(short HMA lookback, velocity lookback) < 0 AND HMA velocity(middle HMA lookback, velocity lookback) < 0 AND HMA velocity(long HMA lookback, velocity lookback) < 0
Long: HMA velocity(short HMA lookback, velocity lookback) crosses above velocity threshold AND at least cooldown bars have elapsed since the prior long or short signal
Short: HMA velocity(short HMA lookback, velocity lookback) crosses below velocity threshold AND at least cooldown bars have elapsed since the prior long or short signal
Long: On chart bars using HMA velocity values from the still-forming T1 bar in real time and the last completed T1 bar on historical bars, with lookahead off, HMA velocity(shared higher-timeframe HMA lookback, velocity lookback) > 0
Short: On chart bars using HMA velocity values from the still-forming T1 bar in real time and the last completed T1 bar on historical bars, with lookahead off, HMA velocity(shared higher-timeframe HMA lookback, velocity lookback) <= 0
Long: On chart bars using HMA velocity values from the still-forming T2 bar in real time and the last completed T2 bar on historical bars, with lookahead off, HMA velocity(shared higher-timeframe HMA lookback, velocity lookback) > 0
Short: On chart bars using HMA velocity values from the still-forming T2 bar in real time and the last completed T2 bar on historical bars, with lookahead off, HMA velocity(shared higher-timeframe HMA lookback, velocity lookback) <= 0