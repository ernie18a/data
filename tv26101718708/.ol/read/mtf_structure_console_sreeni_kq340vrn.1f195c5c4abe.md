Calculation: ATR = average true range over a lookback, using the last completed bar on the higher of the configured ATR timeframe and chart timeframe
Calculation: Long stop = inside-bar low − ATR buffer; short stop = inside-bar high + ATR buffer
Calculation: Initial risk = distance from the trigger to its stop
Long: An inside bar forms with initial risk / ATR ≤ the maximum risk threshold, then a completed chart-timeframe bar closes above the inside bar’s high
Short: An inside bar forms with initial risk / ATR ≤ the maximum risk threshold, then a completed chart-timeframe bar closes below the inside bar’s low
Exit: Long, low ≤ long stop OR (no target reached AND completed bar closes below the long trigger) OR high ≥ entry price + 3 × initial risk OR bars since entry ≥ tracking limit
Exit: Short, high ≥ short stop OR (no target reached AND completed bar closes above the short trigger) OR low ≤ entry price − 3 × initial risk OR bars since entry ≥ tracking limit