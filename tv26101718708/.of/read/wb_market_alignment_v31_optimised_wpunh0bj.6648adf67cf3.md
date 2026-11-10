Calculation: Pullback zone = low <= short-term close EMA + ATR × tolerance AND high >= short-term close EMA - ATR × tolerance.
Calculation: Long score = sum of one point each for (close > long-term close EMA AND short-term close EMA > long-term close EMA), (higher-timeframe filter disabled OR last completed higher-timeframe close > its close EMA), (VWAP filter disabled OR close > session VWAP of typical price), (RSI filter disabled OR RSI >= long threshold), (pullback zone AND close > short-term close EMA), (slope filter disabled OR short-term close EMA > its previous-bar value), ATR pass, and volume pass.
Calculation: Short score = sum of one point each for (close < long-term close EMA AND short-term close EMA < long-term close EMA), (higher-timeframe filter disabled OR last completed higher-timeframe close < its close EMA), (VWAP filter disabled OR close < session VWAP of typical price), (RSI filter disabled OR RSI <= short threshold), (pullback zone AND close < short-term close EMA), (slope filter disabled OR short-term close EMA < its previous-bar value), ATR pass, and volume pass.
Calculation: ATR pass = ATR filter disabled OR (ATR / SMA of ATR >= minimum ratio AND ATR / SMA of ATR <= maximum ratio), with a positive ATR baseline.
Calculation: Volume pass = volume filter disabled OR volume or its SMA unavailable OR volume SMA <= 0 OR volume / volume SMA >= minimum relative volume.
Calculation: Signal cooldown pass = no earlier long or short signal exists OR bars elapsed since the most recent long or short signal >= cooldown length.
Long: Close > long-term close EMA AND short-term close EMA > long-term close EMA.
Short: Close < long-term close EMA AND short-term close EMA < long-term close EMA.
Long: Last completed higher-timeframe close > its close EMA.
Short: Last completed higher-timeframe close < its close EMA.
Long: Close > session VWAP of typical price.
Short: Close < session VWAP of typical price.
Long: RSI >= long threshold.
Short: RSI < long threshold AND RSI <= short threshold.
Long: Long score >= minimum score.
Short: Short score >= minimum score.
Long: Bar closed AND (session filter disabled OR bar opens within the configured session in its configured time zone) AND manual news blackout disabled AND signal cooldown pass AND long score >= minimum score AND close > long-term close EMA AND short-term close EMA > long-term close EMA AND pullback zone AND close > short-term close EMA AND (directional candle filter disabled OR close > open).
Short: Bar closed AND (session filter disabled OR bar opens within the configured session in its configured time zone) AND manual news blackout disabled AND signal cooldown pass AND short score >= minimum score AND close < long-term close EMA AND short-term close EMA < long-term close EMA AND pullback zone AND close < short-term close EMA AND (directional candle filter disabled OR close < open).