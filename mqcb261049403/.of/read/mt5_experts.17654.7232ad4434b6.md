Calculation: Trend state = On the configurable indicator timeframe, calculate Heikin-Ashi close as (open + high + low + close) / 4 and Heikin-Ashi open as the average of the preceding bar's Heikin-Ashi open and close, initialized with the first bar's open. If both current Heikin-Ashi open and close lie within the Heikin-Ashi open-to-close range of any bar in the lookback, inherit the state of the most recent such bar. Otherwise, the state is up if Heikin-Ashi close differs from Heikin-Ashi open AND open <= close, down if Heikin-Ashi close differs from Heikin-Ashi open AND open > close, and neutral if Heikin-Ashi close equals Heikin-Ashi open. The indicator timeframe may be higher or lower than the chart timeframe; use its last completed bar, or its still-forming bar if configured.
Long: Trend state = up AND previous indicator bar's trend state != up
Short: Trend state = down AND previous indicator bar's trend state != down
Exit: short, trend state = up
Exit: long, trend state = down
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance