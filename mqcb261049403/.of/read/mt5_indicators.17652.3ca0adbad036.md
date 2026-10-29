Calculation: Heikin-Ashi close = (open + high + low + close) / 4
Calculation: Heikin-Ashi open = (previous Heikin-Ashi open + previous Heikin-Ashi close) / 2; initialize the first Heikin-Ashi open to the bar open
Calculation: TTM-Trend direction = if the current Heikin-Ashi open and close both lie within the open-close range of any of the previous CompBars-1 bars, inherit the direction of the most recent such bar; otherwise bullish if Heikin-Ashi close > Heikin-Ashi open, bearish if Heikin-Ashi close < Heikin-Ashi open, and neutral if equal
Calculation: Higher-timeframe TTM-Trend direction = TTM-Trend direction calculated on higher-timeframe bars, using the still-forming higher-timeframe bar
Long: TTM-Trend direction is bullish OR higher-timeframe TTM-Trend direction is bullish
Short: TTM-Trend direction is bearish OR higher-timeframe TTM-Trend direction is bearish