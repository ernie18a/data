Calculation: Raw movement = (current median price - previous median price) * current median price / (2 * volume), or 0 when volume is 0; median price = (high + low) / 2.
Calculation: Main movement = moving average of raw movement using a selectable smoothing method and lookback.
Calculation: Signal movement = moving average of main movement using a separately selectable smoothing method and shorter lookback.
Calculation: Higher-timeframe movements = main movement and signal movement calculated on higher-timeframe bars, using the still-forming higher-timeframe bar at the first chart bar of each higher-timeframe period and holding those values until the next higher-timeframe period; compare the main movement with its previous higher-timeframe bar for histogram conditions.
Long: Main movement > signal movement OR (main movement > 0 AND main movement != previous bar's main movement).
Short: Main movement < signal movement OR (main movement < 0 AND main movement != previous bar's main movement).
Long: Higher-timeframe main movement > higher-timeframe signal movement OR (higher-timeframe main movement > 0 AND higher-timeframe main movement != previous higher-timeframe bar's main movement).
Short: Higher-timeframe main movement < higher-timeframe signal movement OR (higher-timeframe main movement < 0 AND higher-timeframe main movement != previous higher-timeframe bar's main movement).