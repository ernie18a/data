Calculation: Price deviation = configured price source minus its configured simple or exponential moving average, calculated on the chart timeframe or a higher timeframe; a higher-timeframe calculation uses its still-forming bar.
Calculation: Channel width = configured multiplier times the average bar range over its configured lookback. Bar range is high minus low, or max(high, previous close) minus min(low, previous close) in ATR mode; this uses the same timeframe as the price deviation.
Long: Price deviation > Channel width
Short: Price deviation < -Channel width