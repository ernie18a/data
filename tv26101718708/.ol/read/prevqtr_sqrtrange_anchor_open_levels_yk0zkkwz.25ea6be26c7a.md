Calculation: Anchor open = open of the first bar of the selected RTH session, ETH session, week, or quarter
Calculation: Previous-quarter range = high minus low of the last completed quarter on a timeframe higher than the chart timeframe
Calculation: Sqrt-range step = square root of the previous-quarter range multiplied by a configurable multiplier
Calculation: Upper levels = anchor open + n × sqrt-range step, for each configured positive integer level index n
Calculation: Lower levels = anchor open − n × sqrt-range step, for each configured positive integer level index n
Long: (close > an upper level AND prior-bar close <= that same upper level) OR (close > anchor open AND prior-bar close <= anchor open)
Short: (close < a lower level AND prior-bar close >= that same lower level) OR (close < anchor open AND prior-bar close >= anchor open)