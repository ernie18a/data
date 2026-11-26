Calculation: Fast MA = selected moving average(fast MA type, fast MA source, fast lookback)
Calculation: Slow MA = selected moving average(slow MA type, slow MA source, slow lookback)
Calculation: Momentum-adjusted EMA(source, lookback) = EMA(source + (change(source, round(lookback / φ)) + 0.5 * change(change(source, round(lookback / φ)), round(lookback / φ))) * SUM(change(source) > 0 ? 1 : 0, round(lookback / φ²)) / φ², lookback), where φ = (1 + sqrt(5)) / 2
Calculation: Bollinger basis = EMA(Bollinger source, Bollinger lookback) if EMA basis is selected, otherwise SMA(Bollinger source, Bollinger lookback)
Calculation: Bollinger deviation = STDEV(Bollinger source, Bollinger lookback)
Long: crossover(Fast MA, Slow MA) OR low-break source <= Bollinger basis - breakout multiplier * Bollinger deviation
Short: crossover(Slow MA, Fast MA) OR high-break source >= Bollinger basis + breakout multiplier * Bollinger deviation
Long: crossover(Fast MA, Slow MA) AND HLC3 < Bollinger basis + inner multiplier * Bollinger deviation
Long: Fast MA < fast MA source OR Slow MA < slow MA source OR Fast MA > Slow MA
Short: Fast MA > fast MA source OR Slow MA > slow MA source OR Fast MA < Slow MA
Exit: long, high > Fast MA