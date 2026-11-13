Calculation: HTF = most recent completed bar of a timeframe higher than the chart timeframe, aggregated from chart bars; levels are refreshed each time a new HTF bar completes and stay fixed until the next one. R = HTF high - HTF low. HTF is up if HTF close >= HTF open, otherwise down. d1<d2<d3 are three retracement fractions of R (between 0 and 1, measured from the HTF extreme). e is an extension fraction of R (>0).
Long: HTF is up AND chart bar low <= HTF high - dk*R for any k in {1,2,3}
Short: HTF is down AND chart bar high >= HTF low + dk*R for any k in {1,2,3}
Exit: long, chart bar high >= HTF high + e*R
Exit: short, chart bar low <= HTF low - e*R