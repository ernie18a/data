Calculation: Chart RMACD histogram = RVI(fast chart lookback, chart applied-volume selection) - TRVI(slow chart lookback, chart applied-volume selection), on chart bars
Calculation: Entry RMACD histogram = RVI(fast entry lookback, entry applied-volume selection) - TRVI(slow entry lookback, entry applied-volume selection), on T1 bars at the configured signal-bar offset, which may select a completed or forming bar
Calculation: Chart signal line = configured chart smoothing method(chart RMACD histogram, chart signal lookback, chart signal phase)
Calculation: Entry signal line = configured entry smoothing method(entry RMACD histogram, entry signal lookback, entry signal phase)
Long: Chart RMACD histogram > 0
Short: Chart RMACD histogram < 0
Long: Chart RMACD histogram on a chart bar > chart signal line on the immediately older chart bar
Short: Chart RMACD histogram on a chart bar < chart signal line on the immediately older chart bar
Long: Chart RMACD histogram on the most recent completed chart bar < chart signal line on the immediately older chart bar AND chart RMACD histogram on the preceding completed chart bar > chart signal line on the next older chart bar
Short: Chart RMACD histogram on the most recent completed chart bar > chart signal line on the immediately older chart bar AND chart RMACD histogram on the preceding completed chart bar < chart signal line on the next older chart bar
Long: Entry RMACD histogram crosses above zero on the selected T1 bar
Short: Entry RMACD histogram crosses below zero on the selected T1 bar
Long: Entry RMACD histogram on the selected T1 bar > its value on the immediately older T1 bar AND its value on the immediately older T1 bar < its value on the next older T1 bar
Short: Entry RMACD histogram on the selected T1 bar < its value on the immediately older T1 bar AND its value on the immediately older T1 bar > its value on the next older T1 bar
Long: Entry signal line on the selected T1 bar > its value on the immediately older T1 bar AND its value on the immediately older T1 bar < its value on the next older T1 bar
Short: Entry signal line on the selected T1 bar < its value on the immediately older T1 bar AND its value on the immediately older T1 bar > its value on the next older T1 bar
Long: Entry RMACD histogram crosses above the entry signal line on T1 at the selected signal-bar offset
Short: Entry RMACD histogram crosses below the entry signal line on T1 at the selected signal-bar offset
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance