Calculation: estimated buy volume = if bar high > bar low then bar volume * ((bar close - bar low) / (bar high - bar low)) else bar volume if bar close >= bar open, otherwise zero
Calculation: estimated sell volume = bar volume - estimated buy volume
Calculation: delta = estimated buy volume - estimated sell volume
Calculation: recent sell-to-buy volume ratio = sum(estimated sell volume, order-book lookback) / sum(estimated buy volume, order-book lookback), or fallback ratio if the denominator is zero
Calculation: order-book score = score A if the ratio is below cutoff A; score A minus slope A times (ratio - cutoff A) if below cutoff B; score B minus slope B times (ratio - cutoff B) if below cutoff C; otherwise max(zero, score C minus slope C times (ratio - cutoff C))
Calculation: delta score = min(abs(delta) / volume * delta-score multiplier, score ceiling) when volume is positive, otherwise zero
Calculation: market pressure score = order-book score * order-book weight + delta score * delta weight + max(zero, min((volume / SMA(volume, volume lookback) - one) * volume-score slope, score ceiling)) * volume weight + (bar close location as a percentage of its range, or midpoint score if the range is zero) * price-action weight + (trend points if chart-bar EMA(close, shorter lookback) > EMA(close, longer lookback), plus trend points if EMA(close, shorter lookback, T2 current still-forming bar) > EMA(close, longer lookback, T2 current still-forming bar)) * trend weight
Calculation: gap probability = min(probability scale * (volume-spike weight if volume > SMA(volume, volume lookback) * volume-spike multiplier, plus delta weight if delta > volume * gap-delta strength, plus breakout weight if close > highest(high[1], breakout lookback), plus chart-trend weight if EMA(close, shorter lookback) > EMA(close, longer lookback), plus T2-trend weight if EMA(close, shorter lookback, T2 current still-forming bar) > EMA(close, longer lookback, T2 current still-forming bar), plus RSI weight if RSI(close, RSI lookback) > RSI threshold), probability cap)
Long: delta > zero
Short: delta <= zero
Long: T1 current still-forming bar return, (close - open) / open, >= strong-return threshold AND (close - low) / (high - low) > near-high threshold
Long: estimated buy volume(T1 current still-forming bar) - estimated sell volume(T1 current still-forming bar) > T1 current still-forming bar volume * T1-delta threshold
Long: chart bar range > zero AND (close - low) / (high - low) > near-high threshold, or close >= open when the range is zero, AND delta > volume * intraday-delta threshold AND volume > SMA(volume, volume lookback) * high-volume multiplier AND close > highest(high[1], breakout lookback)
Long: gap probability >= setup probability threshold
Long: RSI(close, RSI lookback) > bullish RSI threshold AND RSI(close, RSI lookback) <= bearish RSI threshold
Short: RSI(close, RSI lookback) > bearish RSI threshold
Long: EMA(close, shorter lookback, T2 current still-forming bar) > EMA(close, longer lookback, T2 current still-forming bar), using T2 values on chart bars
Short: EMA(close, shorter lookback, T2 current still-forming bar) <= EMA(close, longer lookback, T2 current still-forming bar), using T2 values on chart bars
Long: order-book filter disabled OR recent sell-to-buy volume ratio < maximum sell-to-buy ratio
Short: order-book filter enabled AND recent sell-to-buy volume ratio >= maximum sell-to-buy ratio
Long: market-pressure score >= bullish pressure-color threshold
Short: market-pressure score < bearish pressure-color threshold
Long: order-book score >= bullish score-color threshold
Long: delta score >= bullish score-color threshold
Long: chart bar is intraday and its hour equals the configured close hour and its minute is at or after close time minus the end-of-day window and at or before close time; gap probability >= setup probability threshold AND delta > zero AND ((T1 current still-forming bar return >= strong-return threshold AND (T1 close - T1 low) / (T1 high - T1 low) > near-high threshold AND estimated buy volume(T1 current still-forming bar) - estimated sell volume(T1 current still-forming bar) > T1 volume * T1-delta threshold) OR the chart-bar limit-pressure condition) AND (Thursday filter disabled OR chart date is not Thursday) AND T1 volume >= minimum T1 volume threshold AND (T1 open is nonzero AND (T1 high - T1 low) / T1 open >= T1 range threshold, or T1 close >= T1 open when T1 open is zero) AND (previous-gap filter disabled OR previous completed T1 close is zero OR (T1 open - previous completed T1 close) / previous completed T1 close <= previous-gap threshold) AND order-book filter disabled OR recent sell-to-buy volume ratio < maximum sell-to-buy ratio AND pressure-score filter disabled OR market-pressure score >= minimum pressure score
Exit: long, stop loss enabled AND close < entry price reduced by the stop-loss percentage
Exit: long, chart bar is intraday AND its hour equals the market-open hour parameter AND its minute is below the market-open minute cutoff AND the long gap setup was active on the previous chart bar