Calculation: Base model price = scaling factor × (simple moving average of mining difficulty over a configurable lookback, raised to a configurable power) ÷ rolling sum of daily issuance over a configurable lookback. Daily issuance is 144 times the block subsidy: 50 BTC before the first halving, then halved every 210,000 blocks.
Calculation: Upper band = base model price × [floor multiplier + (start multiplier − floor multiplier) × exp(−decay rate × days elapsed since the configured start year)].
Long: BTC close ≤ base model price
Short: BTC close ≥ upper band