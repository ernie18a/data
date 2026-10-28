Calculation: Relative volume = current volume / average volume over the shared lookback
Calculation: Exposure Z-score = (close − VWAP of (high + low + close) / 3) / standard deviation of close minus that VWAP over the same lookback
Calculation: Volume peak = current volume >= highest volume over the climax lookback
Calculation: Zone midpoint = midpoint of the signal candle’s open and close
Calculation: Estimated buy volume = volume × (close − low) / (high − low); if high = low, use volume × 0.5
Calculation: Estimated sell volume = volume − estimated buy volume
Long: Volume peak AND relative volume >= threshold AND exposure Z-score <= −threshold AND cooldown elapsed since the last long or short signal AND (session filter disabled OR datetime is within the configured session) AND (trend filter disabled OR close > EMA of close) OR a bullish zone is active and low <= its midpoint AND close > its midpoint
Long: Relative volume >= threshold AND estimated buy volume > estimated sell volume × threshold AND close <= open AND NOT a long signal
Long: Current low = lowest low over the divergence lookback AND exposure Z-score > its lowest value over that lookback AND exposure Z-score < negative threshold AND NOT a long signal AND NOT a bullish absorption signal
Short: Volume peak AND relative volume >= threshold AND exposure Z-score >= threshold AND cooldown elapsed since the last long or short signal AND (session filter disabled OR datetime is within the configured session) AND (trend filter disabled OR close < EMA of close) OR a bearish zone is active and high >= its midpoint AND close < its midpoint
Short: Relative volume >= threshold AND estimated sell volume > estimated buy volume × threshold AND close >= open AND NOT a short signal
Short: Current high = highest high over the divergence lookback AND exposure Z-score < its highest value over that lookback AND exposure Z-score > threshold AND NOT a short signal AND NOT a bearish absorption signal