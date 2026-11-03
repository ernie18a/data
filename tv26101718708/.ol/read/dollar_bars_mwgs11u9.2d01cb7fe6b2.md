Calculation: Dollar bars = consecutive chart bars grouped until selected price basis × volume reaches a fixed dollar-notional threshold; aggregate their OHLC, and evaluate decisions only when a dollar bar completes.
Calculation: EMA = exponential moving average of a configurable dollar-bar OHLC source, updated on completed dollar bars only.
Long: Current completed dollar-bar close > selected EMA AND previous dollar-bar close <= previous selected EMA
Short: Current completed dollar-bar close < selected EMA AND previous dollar-bar close >= previous selected EMA
Long: Shorter-lookback EMA > longer-lookback EMA AND previous shorter-lookback EMA <= previous longer-lookback EMA
Short: Shorter-lookback EMA < longer-lookback EMA AND previous shorter-lookback EMA >= previous longer-lookback EMA