Calculation: Exposure = (close − session VWAP of (high + low + close) / 3) / rolling standard deviation of (close − session VWAP), using the same lookback as average volume.
Calculation: Relative volume = volume / simple moving average of volume.
Calculation: Estimated buy volume = volume × (close − low) / (high − low), or volume / 2 when high = low; estimated sell volume = volume − estimated buy volume.
Calculation: Bullish bubble = volume >= highest volume over the climax lookback AND relative volume >= its threshold AND exposure <= negative exposure threshold AND bars since the most recent bullish or bearish bubble >= cooldown AND (session filter disabled OR bar is in the configured UTC session) AND (trend filter disabled OR close > chart-timeframe EMA of close). Initialize the most recent bubble's bar index to zero.
Calculation: Bearish bubble = volume >= highest volume over the climax lookback AND relative volume >= its threshold AND exposure >= exposure threshold AND bars since the most recent bullish or bearish bubble >= cooldown AND (session filter disabled OR bar is in the configured UTC session) AND (trend filter disabled OR close < chart-timeframe EMA of close). Initialize the most recent bubble's bar index to zero.
Calculation: Bullish absorption = relative volume >= its threshold AND estimated buy volume > estimated sell volume × absorption ratio AND close <= open.
Calculation: Bearish absorption = relative volume >= its threshold AND estimated sell volume > estimated buy volume × absorption ratio AND close >= open.
Calculation: Bubble zone = the range from min(open, close) to max(open, close) of a bubble bar; its midpoint is the average of those bounds. Retain only the most recent configured maximum number of zones. A zone is eligible after its bubble bar through its configured expiry bar, inclusive; subsequent price breaches do not end eligibility.
Long: Bullish bubble.
Short: Bearish bubble.
Long: Bullish absorption AND NOT bullish bubble.
Short: Bearish absorption AND NOT bearish bubble.
Long: low = lowest low over the divergence lookback AND exposure > lowest exposure over the same lookback AND exposure < negative divergence threshold AND NOT bullish bubble AND NOT bullish absorption.
Short: high = highest high over the divergence lookback AND exposure < highest exposure over the same lookback AND exposure > divergence threshold AND NOT bearish bubble AND NOT bearish absorption.
Long: An eligible bullish bubble zone exists AND low <= its midpoint AND close > its midpoint.
Short: An eligible bearish bubble zone exists AND high >= its midpoint AND close < its midpoint.
Long: exposure > positive sentiment threshold.
Short: exposure < negative sentiment threshold.