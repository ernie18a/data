Calculation: Bullish fair value gap = current bar low > high two bars earlier AND previous bar close > previous bar open
Calculation: Daily open = open of the current higher-timeframe daily bar, still forming
Calculation: Short target = signal bar close − (the greater of signal bar high − signal bar close and the minimum stop distance) × configured reward-to-risk ratio
Short: A bullish fair value gap has been detected since the last short entry, close < its lower boundary (high two bars earlier), close < daily open AND time is within the configured session when the session filter is enabled
Exit: Short, high >= signal bar high (initial stop, moved to entry price minus configured offset after low < entry price minus configured trigger distance) OR low <= short target