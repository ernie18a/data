Calculation: break high = high or close, selected by a parameter
Calculation: break low = low or close, selected by a parameter
Calculation: anchor high = high of the bar containing anchor time
Calculation: anchor low = low of the bar containing anchor time
Long: top ray enabled AND time > anchor time AND break high > anchor high AND Highest(break high, anchor bar to previous bar) <= anchor high
Short: bottom ray enabled AND time > anchor time AND break low < anchor low AND Lowest(break low, anchor bar to previous bar) >= anchor low