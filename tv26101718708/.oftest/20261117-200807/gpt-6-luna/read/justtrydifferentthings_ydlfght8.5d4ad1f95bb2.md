Calculation: Upper series = EMA(HIGHEST(current higher-timeframe bar open, upper lookback), upper smoothing)
Calculation: Lower series = EMA(LOWEST(current higher-timeframe bar open, lower lookback), lower smoothing)
Long: CROSSUNDER(SMA(Upper series, shorter lookback), SMA(Upper series, longer lookback))
Short: CROSSOVER(SMA(Lower series, shorter lookback), SMA(Lower series, longer lookback))