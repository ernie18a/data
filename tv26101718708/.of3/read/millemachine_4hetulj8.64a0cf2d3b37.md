Calculation: ATR stop fraction = ATR(lookback) × multiplier / (close + ATR(lookback) × multiplier)
Calculation: Long stop = entry price × (1 − ATR stop fraction) at entry; when trailing is enabled, update each bar to max(current stop, configured trailing indicator(low, long trailing lookback) × (1 − ATR stop fraction))
Calculation: Short stop = entry price × (1 + ATR stop fraction) at entry; when trailing is enabled, update each bar to min(current stop, configured trailing indicator(high, short trailing lookback) × (1 + ATR stop fraction))
Long: configured entry indicator(source, lookback) crosses above its one-bar lag AND position is flat AND configured mode permits long AND (baseline filter is disabled OR configured baseline indicator(source, lookback) / its one-bar lag > 1) AND (confirmation filter is disabled OR configured confirmation indicator(source, lookback) > its one-bar lag)
Short: configured entry indicator(source, lookback) crosses below its one-bar lag AND position is flat AND configured mode permits short AND (baseline filter is disabled OR configured baseline indicator(source, lookback) / its one-bar lag < 1) AND (confirmation filter is disabled OR configured confirmation indicator(source, lookback) < its one-bar lag)
Long: configured entry indicator(source, lookback) > its one-bar lag
Short: configured entry indicator(source, lookback) ≤ its one-bar lag
Exit: long, configured entry indicator(source, lookback) crosses below its one-bar lag
Exit: short, configured entry indicator(source, lookback) crosses above its one-bar lag
Exit: long, low ≤ long stop
Exit: short, high ≥ short stop
Exit: long, previous bar was in a long position AND low crosses long stop AND previous low > current long stop AND entry price > current long stop
Exit: short, previous bar was in a short position AND high crosses short stop AND previous high < current short stop AND entry price < current short stop