Calculation: EMA stack = five close EMAs ordered by increasing lookback: fast, second, trend, fourth, and long.
Calculation: Bull pairs = count of adjacent EMA pairs in which the shorter EMA is greater than the longer EMA; bear pairs = count in which the shorter EMA is less than the longer EMA. A bull or bear stack is aligned when its pair count reaches the alignment threshold.
Calculation: Above count = number of stack EMAs below close; below count = number of stack EMAs at or above close.
Calculation: Trend slope = percentage change in the trend EMA over the dynamics lookback, or zero if its earlier value is zero. Gap = percentage difference between the fast EMA and trend EMA relative to the trend EMA, or zero if the trend EMA is zero. Gap momentum = current absolute gap minus its absolute value at the same dynamics lookback.
Calculation: Bull score = above count times the price weight plus bull pairs times the pair weight, plus the slope bonus when trend slope is positive and its absolute value reaches the flat threshold, plus the gap bonus when gap momentum exceeds its expansion threshold and the bull stack is aligned. Bear score = below count times the price weight plus bear pairs times the pair weight, plus the slope bonus when trend slope is negative and its absolute value reaches the flat threshold, plus the gap bonus when gap momentum exceeds its expansion threshold and the bear stack is aligned. Pair weight, slope bonus, and gap bonus are equal and greater than the price weight.
Calculation: Strong long = bull score reaches the strong threshold AND bull stack is aligned. Strong short = bear score reaches the strong threshold AND bear stack is aligned. Normal long = bull score reaches the normal threshold AND above count reaches the price-count threshold AND strong long is false. Normal short = bear score reaches the normal threshold AND below count reaches the price-count threshold AND strong short is false. The strong threshold is greater than the normal threshold.
Calculation: Bull touch = bull stack is aligned AND low <= second EMA. Bear touch = bear stack is aligned AND high >= second EMA. Raw long pullback = bull stack is aligned AND ((close crosses above fast EMA AND a bull touch occurred within the pullback lookback, including the current bar) OR (bull touch AND close > fast EMA AND close >= open)). Raw short pullback = bear stack is aligned AND ((close crosses below fast EMA AND a bear touch occurred within the pullback lookback, including the current bar) OR (bear touch AND close < fast EMA AND close <= open)).
Calculation: Last aligned direction = direction of the most recent bar with an aligned bull or bear stack; initially neither. Bias = long when bull score >= bear score, otherwise short. Bias score = score for the bias direction.
Long: bull score >= bear score.
Short: bull score < bear score.
Long: close > any stack EMA.
Short: close <= any stack EMA.
Long: fast EMA > trend EMA OR fast EMA > second EMA OR trend EMA > long EMA.
Short: fast EMA <= trend EMA OR fast EMA <= second EMA OR trend EMA <= long EMA.
Long: bull stack is aligned AND above count reaches the price-count threshold AND trend slope is positive AND its absolute value reaches the flat threshold.
Short: bear stack is aligned AND below count reaches the price-count threshold AND trend slope is negative AND its absolute value reaches the flat threshold.
Long: the preceding trend condition holds on an enabled higher timeframe, using either its last completed bar or its still-forming bar according to the selected mode.
Short: the preceding trend condition holds on an enabled higher timeframe, using either its last completed bar or its still-forming bar according to the selected mode.
Long: strong long OR normal long OR (bull score > bear score AND bull score reaches the weak threshold AND strong long is false AND normal long is false). The weak threshold is below the normal threshold.
Short: strong long is false AND normal long is false AND (strong short OR normal short OR (bear score > bull score AND bear score reaches the weak threshold AND strong short is false AND normal short is false)). The weak threshold is below the normal threshold.
Long: strong long is true AND was false on the previous bar OR normal long is true AND was false on the previous bar.
Short: strong short is true AND was false on the previous bar OR normal short is true AND was false on the previous bar.
Long: raw long pullback is true AND was false on the previous bar.
Short: raw short pullback is true AND was false on the previous bar.
Long: trend EMA crosses above long EMA OR fast EMA crosses above second EMA.
Short: trend EMA crosses below long EMA OR fast EMA crosses below second EMA.
Long: neither stack is aligned AND last aligned direction is not long AND bias is long AND bias score reaches the weak threshold.
Short: neither stack is aligned AND last aligned direction is not short AND bias is short AND bias score reaches the weak threshold.
Exit: long, bull stack is aligned OR bear stack is aligned, AND gap momentum is below the negative compression threshold AND bias is long.
Exit: short, bull stack is aligned OR bear stack is aligned, AND gap momentum is below the negative compression threshold AND bias is short.
Exit: long, neither stack is aligned AND last aligned direction is long AND bias is long AND bias score reaches the weak threshold AND bias score is below the normal threshold.
Exit: short, neither stack is aligned AND last aligned direction is short AND bias is short AND bias score reaches the weak threshold AND bias score is below the normal threshold.