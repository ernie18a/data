Calculation: Anchored VWAP = volume-weighted average of HLC3 from the start of the selected anchor period through the current bar
Calculation: VWAP standard deviation = volume-weighted standard deviation of HLC3 from the start of the selected anchor period through the current bar
Calculation: Inner bands = Anchored VWAP ± VWAP standard deviation × inner multiplier; outer bands = Anchored VWAP ± VWAP standard deviation × outer multiplier, where the outer multiplier is greater
Calculation: Upper excursion state = reset at each anchor-period start; while inactive, a close crossing above the inner upper band activates the state as outer if that close is above the outer upper band, otherwise inner; while active, any close above the outer upper band sets it to outer
Calculation: Lower excursion state = reset at each anchor-period start; while inactive, a close crossing below the inner lower band activates the state as outer if that close is below the outer lower band, otherwise inner; while active, any close below the outer lower band sets it to outer
Long: On a confirmed bar, lower excursion state is inner and close crosses above the inner lower band, OR lower excursion state is outer and close crosses above the outer lower band
Short: On a confirmed bar, upper excursion state is inner and close crosses below the inner upper band, OR upper excursion state is outer and close crosses below the outer upper band
Exit: Long, after the signal bar, high reaches or exceeds the anchored VWAP
Exit: Short, after the signal bar, low reaches or falls below the anchored VWAP