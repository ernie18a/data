Calculation: Session VWAP = cumulative sum of close × volume divided by cumulative volume, reset at the start of each higher-timeframe session and including the current chart bar of the still-forming session.
Calculation: Session bands = session VWAP ± a multiplier × sqrt(max(0, cumulative sum of close² × volume / cumulative volume − session VWAP²)); use the same session and bars as the session VWAP.
Calculation: Signal spacing = number of chart bars since the most recent upper-band or lower-band reversal signal; before any signal, treat the spacing requirement as met.
Long: Session VWAP >= previous chart bar's session VWAP.
Short: Session VWAP < previous chart bar's session VWAP.
Long: Confirmed chart bar's low < lower session band AND close > lower session band AND signal spacing >= minimum spacing.
Short: Confirmed chart bar's high > upper session band AND close < upper session band AND signal spacing >= minimum spacing.