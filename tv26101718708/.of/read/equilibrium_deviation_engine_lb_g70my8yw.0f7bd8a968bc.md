Calculation: Basis = cumulative sum(source price * volume) / cumulative sum(volume), accumulated from the first chart bar of each higher-timeframe period (accumulators reset when a new higher-timeframe bar begins); source price = (high+low+close)/3
Long: close >= Basis
Short: close < Basis