Calculation: ChartCCIProduct = MA(CCI(applied price, CCI lookback) * selected volume source, smoothing method, smoothing lookback, smoothing phase), on chart bars including the current forming bar
Calculation: ChartSmoothedVolume = MA(selected volume source, same smoothing settings), on chart bars including the current forming bar
Calculation: T1CCIProduct = MA(CCI(applied price, CCI lookback) * selected volume source, smoothing method, smoothing lookback, smoothing phase), on T1 bars including the still-forming bar; T1 values are copied to chart bars
Calculation: T1SmoothedVolume = MA(selected volume source, same smoothing settings), on T1 bars including the still-forming bar; T1 values are copied to chart bars
Long: ChartCCIProduct > HighLevel2 * ChartSmoothedVolume
Long: ChartCCIProduct <= HighLevel2 * ChartSmoothedVolume AND ChartCCIProduct > HighLevel1 * ChartSmoothedVolume
Short: ChartCCIProduct < LowLevel2 * ChartSmoothedVolume
Short: ChartCCIProduct >= LowLevel2 * ChartSmoothedVolume AND ChartCCIProduct < LowLevel1 * ChartSmoothedVolume
Long: T1CCIProduct > HighLevel2 * T1SmoothedVolume
Long: T1CCIProduct <= HighLevel2 * T1SmoothedVolume AND T1CCIProduct > HighLevel1 * T1SmoothedVolume
Short: T1CCIProduct < LowLevel2 * T1SmoothedVolume
Short: T1CCIProduct >= LowLevel2 * T1SmoothedVolume AND T1CCIProduct < LowLevel1 * T1SmoothedVolume