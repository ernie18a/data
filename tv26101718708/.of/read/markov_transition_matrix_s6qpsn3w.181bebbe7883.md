Calculation: Analysis return = (close / close N bars earlier - 1) on the last completed analysis-timeframe bar; the analysis timeframe is higher than or equal to the chart timeframe.
Calculation: Observation = an analysis return evaluated after N prior analysis bars exist and the earlier close is nonzero. In rolling mode, evaluate every analysis bar. In isolated mode, after an observation whose absolute return exceeds the positive threshold, wait until N analysis bars have elapsed before evaluating again; neutral observations do not reset the wait. In non-overlapping mode, wait until N analysis bars have elapsed after every observation before evaluating again.
Calculation: State = bullish if observation return > positive threshold, bearish if observation return < negative threshold, and neutral otherwise.
Calculation: Transition bias = the cumulative count of transitions from the latest completed observation's state to bullish minus the count from that state to bearish, divided by the total count of transitions from that state; use zero if that total is zero. Each transition connects observations separated by a configurable number of observation steps.
Long: A new completed observation has return > positive threshold.
Short: A new completed observation has return < negative threshold.
Long: Transition bias > 0.
Short: Transition bias < 0.