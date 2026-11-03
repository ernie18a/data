Calculation: EMA source = a selectable price series: open, high, low, close, (high + low) / 2, (high + low + close) / 3, or (open + high + low + close) / 4; fast, middle, and slow EMAs use successively longer periods.
Calculation: Ribbon width = absolute value of fast EMA minus slow EMA; a squeeze exists when ribbon width is less than its simple moving average multiplied by a squeeze ratio.
Calculation: Timeframe trend counts = counts of bullish and bearish EMA stacks across the chart timeframe and four successively longer selected timeframes. A selected timeframe may be lower than, equal to, or higher than the chart timeframe; use the last intrabar for a lower timeframe, the chart bar for an equal timeframe, and the last completed higher-timeframe bar historically or the forming higher-timeframe bar in real time.
Long: Any one of the fast, middle, or slow EMAs is greater than its previous-bar value.
Short: Any one of the fast, middle, or slow EMAs is less than or equal to its previous-bar value.
Long: Fast EMA > middle EMA AND middle EMA > slow EMA.
Short: Fast EMA < middle EMA AND middle EMA < slow EMA.
Long: Close > maximum of fast, middle, and slow EMAs.
Short: Close < minimum of fast, middle, and slow EMAs.
Long: Fast EMA crosses above middle EMA OR fast EMA crosses above slow EMA OR middle EMA crosses above slow EMA.
Short: Fast EMA crosses below middle EMA OR fast EMA crosses below slow EMA OR middle EMA crosses below slow EMA.
Long: Previous bar was in a squeeze AND current bar is not in a squeeze AND fast EMA > middle EMA AND middle EMA > slow EMA.
Short: Previous bar was in a squeeze AND current bar is not in a squeeze AND fast EMA < middle EMA AND middle EMA < slow EMA.
Long: Any selected timeframe has fast EMA > middle EMA AND middle EMA > slow EMA.
Short: Any selected timeframe has fast EMA < middle EMA AND middle EMA < slow EMA.
Long: Bullish timeframe trend count >= confluence threshold.
Short: Bullish timeframe trend count < confluence threshold AND bearish timeframe trend count >= confluence threshold.