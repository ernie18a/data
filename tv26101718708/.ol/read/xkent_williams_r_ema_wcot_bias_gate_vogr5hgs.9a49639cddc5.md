Calculation: Williams %R = 100 × (close − highest high over its lookback) / (highest high − lowest low over its lookback); 0 if the range is zero
Calculation: Bias index = the configured source’s position from its rolling low to high, scaled to 0–100; 50 if the range is zero
Calculation: Confirmed %R pivot low/high = a local %R low/high confirmed using bars on both sides; pair it with the price low/high on that pivot bar
Long: (%R crosses above −80 OR (%R crosses above its EMA while %R < −50)) AND (EMA confirmation disabled OR %R ≥ %R EMA) AND (regime filter disabled OR %R EMA > −50) AND (bias gate disabled OR manual bias is bullish OR auto bias index ≥ 80)
Long: Current confirmed %R pivot low > previous confirmed %R pivot low AND its paired price low < the previous paired price low
Short: (%R crosses below −20 OR (%R crosses below its EMA while %R > −50)) AND (EMA confirmation disabled OR %R ≤ %R EMA) AND (regime filter disabled OR %R EMA < −50) AND (bias gate disabled OR manual bias is bearish OR auto bias index ≤ 20)
Short: Current confirmed %R pivot high < previous confirmed %R pivot high AND its paired price high > the previous paired price high