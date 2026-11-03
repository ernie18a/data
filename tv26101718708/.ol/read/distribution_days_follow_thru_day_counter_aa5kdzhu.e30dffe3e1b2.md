Calculation: Price change = (close - previous chart-bar close) / previous chart-bar close
Calculation: Close position = (close - low) / (high - low)
Calculation: Rally low = lowest low tracked during Correction; hold fixed during Rally Attempt
Calculation: Rally day = count chart bars since Rally Day 1, starting at 1
Calculation: Active selling-pressure count = count of Distribution and Stalling events since the latest Follow-Through Day that have not reached their configured age limit and have not been negated by a close at or above the event close plus the configured recovery percentage; clear at Rally Day 1, Follow-Through Day, or Correction reset
Long: state is Correction AND close > previous close AND low >= Rally low
Long: state is Rally Attempt AND rally day >= configured minimum AND price change >= configured gain threshold AND volume > previous bar volume
Short: state is Confirmed Uptrend AND price change <= -configured decline threshold AND volume > previous bar volume
Short: state is Confirmed Uptrend AND 0 < price change <= configured maximum stalling gain AND close position < configured maximum close position AND volume > previous bar volume AND at least one of the prior two chart bars had price change >= configured prior-progress threshold
Exit: long, state is Rally Attempt AND (low < Rally low, or close < Rally low when close-based failure is selected)
Exit: long, state is Confirmed Uptrend AND (active selling-pressure count >= configured correction threshold, or a later bar's low < the Follow-Through Day low when that reset option is enabled)