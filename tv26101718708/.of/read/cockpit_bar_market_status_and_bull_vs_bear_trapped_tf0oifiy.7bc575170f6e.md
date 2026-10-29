Calculation: Fast EMA = EMA with a shorter lookback than the slow EMA; both use chart-timeframe closes.
Calculation: Session pressure = 100 × (bullish pain − bearish pain) / (bullish pain + bearish pain), or 0 if the denominator is 0. For each price bin, bullish pain is accumulated buy volume × (bin price − close) for bins above close; bearish pain is accumulated sell volume × (close − bin price) for bins below close. Accumulate from the start of the New York regular session, resetting at its start. Estimate each bar’s buy volume as volume × (close − low) / (high − low), or half the volume if high = low; sell volume is the remainder. Assign volume to the bin of the bar’s typical price (high + low + close) / 3. Use lower-timeframe bars (lower than the chart timeframe) within each confirmed chart bar when the chart is intraday and above one minute; otherwise use chart-timeframe bars. Use completed bars only.
Long: ADX >= trend-strength threshold AND fast EMA > slow EMA
Short: ADX >= trend-strength threshold AND fast EMA < slow EMA
Short: Session pressure > positive-pressure cutoff
Long: Session pressure < negative-pressure cutoff
Short: Within New York regular session, session pressure >= pain threshold AND prior-bar session pressure < pain threshold
Long: Within New York regular session, session pressure <= −pain threshold AND prior-bar session pressure > −pain threshold