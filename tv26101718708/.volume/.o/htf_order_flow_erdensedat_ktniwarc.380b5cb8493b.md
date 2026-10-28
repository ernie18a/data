Calculation: HTF VWAP = volume-weighted average of hlc3 for chart bars in the current, still-forming higher-timeframe period.
Calculation: HTF CVD = cumulative volume in the current, still-forming higher-timeframe period, added when a chart bar closes at or above its open and subtracted otherwise.
Calculation: Confirmed pivot high/low = the high/low of a chart bar that is a local extreme over equal lookbacks on both sides; use the latest confirmed pivot of each type, replacing it when a newer one confirms.
Long: close > HTF VWAP OR (close > latest confirmed pivot high and that pivot has not already been broken)
Short: close <= HTF VWAP OR (close < latest confirmed pivot low and that pivot has not already been broken)