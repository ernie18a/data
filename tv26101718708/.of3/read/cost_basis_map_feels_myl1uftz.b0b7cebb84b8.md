Calculation: position units = positive volume or fallback volume unit, multiplied by HLC3 for quote units and otherwise left in base units
Calculation: position decay = max(full-retention fraction − current position units / (SMA(position units, long lookback) × position memory), zero floor), or full-retention fraction when prior ledger weight or the SMA is nonpositive
Calculation: open-position ledger = prior logarithmic price-bin weights after position decay, plus current position units at the close price; retain positions within the processing window and use the configured bin resolution
Calculation: market cost basis = weighted mean of the open-position ledger's bin prices
Calculation: underwater share = percentage of open-position ledger weight at bin prices above close
Calculation: realized-loss volume = prior ledger weight × (full-retention fraction − position decay) × prior underwater share / percentage scale, or zero when prior ledger weight is nonpositive or prior underwater share is undefined
Long: crosses above market cost basis
Long: within the processing window AND on a confirmed bar AND standard deviation(realized-loss volume, long lookback) is positive AND realized-loss volume > SMA(realized-loss volume, long lookback) + capitulation sensitivity × standard deviation(realized-loss volume, long lookback) AND close < market cost basis AND at least marker cooldown bars since the previous capitulation marker
Short: crosses below market cost basis
Short: underwater share reaches or exceeds the majority-underwater threshold after being below it on the prior bar
Short: underwater share falls to or below the near-all-in-profit threshold after being above it on the prior bar
Short: within the processing window AND underwater share is defined AND underwater share ≤ the euphoria threshold AND position units > SMA(position units, shorter lookback) × elevated-turnover multiplier AND at least marker cooldown bars since the previous euphoria marker