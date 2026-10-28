Calculation: FlowScale = HMA of normalized cumulative PVT, where cumulative PVT is the cumulative sum of ((close − previous close) / previous close) × volume, and normalized cumulative PVT is 200 × (cumulative PVT − lookback low) / (lookback high − lookback low) − 100; use 0 when the lookback range is zero
Long: FlowScale > positive balance buffer
Short: FlowScale < negative balance buffer