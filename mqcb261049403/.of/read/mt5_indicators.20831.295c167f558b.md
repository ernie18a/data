Calculation: Anchored momentum = 100 × (EMA of selected applied price / SMA of the same applied price − 1), with equal EMA and SMA periods; undefined when the SMA is zero. Applied price is a configurable OHLC-derived price.
Long: Chart-timeframe anchored momentum > upper threshold.
Short: Chart-timeframe anchored momentum < lower threshold AND anchored momentum <= upper threshold.
Long: Anchored momentum of the last completed bar of a selected higher or lower timeframe > upper threshold AND anchored momentum >= lower threshold.
Short: Anchored momentum of the last completed bar of a selected higher or lower timeframe < lower threshold.