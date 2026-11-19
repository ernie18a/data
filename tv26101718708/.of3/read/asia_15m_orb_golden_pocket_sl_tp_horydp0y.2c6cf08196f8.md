Calculation: Opening-range high = maximum high of chart bars in the configured opening-range window
Calculation: Opening-range low = minimum low of chart bars in the configured opening-range window
Calculation: Body percentage = if high > low then 100 * abs(close - open) / (high - low) else 0
Calculation: HTF fast EMA = EMA(close, fast lookback, T1, last completed or still-forming T1 bar as configured), sampled on chart bars
Calculation: HTF slow EMA = EMA(close, slow lookback, T1, last completed or still-forming T1 bar as configured), sampled on chart bars
Calculation: HTF bullish trend = HTF fast EMA > HTF slow EMA AND (HTF VWAP filter disabled OR close(T1, selected T1 bar) > VWAP(hlc3, T1, selected T1 bar))
Calculation: HTF bearish trend = HTF fast EMA < HTF slow EMA AND (HTF VWAP filter disabled OR close(T1, selected T1 bar) < VWAP(hlc3, T1, selected T1 bar))
Long: HTF fast EMA > HTF slow EMA
Long: HTF bullish trend
Long: opening range complete AND chart bar is within the configured entry session in the configured timezone AND close crosses above opening-range high + breakout buffer AND close > open AND body percentage >= minimum body percentage AND (entry VWAP filter disabled OR close > VWAP(hlc3)) AND (HTF trend match disabled OR HTF bullish trend)
Short: HTF fast EMA <= HTF slow EMA
Short: HTF bearish trend
Short: opening range complete AND chart bar is within the configured entry session in the configured timezone AND close crosses below opening-range low - breakout buffer AND close < open AND body percentage >= minimum body percentage AND (entry VWAP filter disabled OR close < VWAP(hlc3)) AND (HTF trend match disabled OR HTF bearish trend)