Calculation: Schaff TriX Trend Cycle = On the configured indicator timeframe, calculate fast TriX minus slow TriX (fast lookback shorter than slow); normalize over a cycle lookback to 0–100 and smooth with factor 0.5; normalize that result over the same cycle lookback to −100–100 and smooth with factor 0.5. Use completed bars.
Calculation: Upper state = Schaff TriX Trend Cycle > 0 AND (Schaff TriX Trend Cycle > upper level OR its change from the preceding completed bar < 0)
Calculation: Lower state = Schaff TriX Trend Cycle < 0 AND Schaff TriX Trend Cycle < lower level
Long: Current completed bar is in Upper state AND preceding completed bar is not in Upper state
Short: Current completed bar is in Lower state AND preceding completed bar is not in Lower state
Exit: Long, current completed bar is in Lower state
Exit: Short, current completed bar is in Upper state