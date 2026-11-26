Calculation: FootprintHeatmap = clamp(FootprintDelta / HMA(abs(FootprintDelta + epsilon), normalization lookback) * midpoint + midpoint, 0, maximum)
Calculation: FlowMomentum = sum((HMA(FootprintHeatmap, each consecutive lookback from shorter to longer) / midpoint) - 1)
Calculation: PriceMomentum = (RSI(close, lookback) - midpoint) * scale
Long: FlowMomentum > 0 OR (EMA(FlowMomentum, smoothing lookback) > EMA(FlowMomentum, smoothing lookback)[1] AND EMA(PriceMomentum, smoothing lookback) < EMA(PriceMomentum, smoothing lookback)[1] AND FlowMomentum > PriceMomentum)
Short: FlowMomentum < 0 OR (EMA(FlowMomentum, smoothing lookback) < EMA(FlowMomentum, smoothing lookback)[1] AND EMA(PriceMomentum, smoothing lookback) > EMA(PriceMomentum, smoothing lookback)[1] AND FlowMomentum < PriceMomentum)