Calculation: TMA = Close-based triangular weighted moving average, with weights increasing from 1 to the midpoint and then decreasing symmetrically; calculated on a timeframe that may be higher or lower than the chart timeframe, using completed bars.
Long: On the latest completed bar, Close > TMA + long breakout offset AND on the preceding completed bar, Close <= TMA + long breakout offset
Short: On the latest completed bar, Close < TMA - short breakout offset AND on the preceding completed bar, Close >= TMA - short breakout offset
Exit: short, latest completed bar Close > TMA + long breakout offset
Exit: long, latest completed bar Close < TMA - short breakout offset