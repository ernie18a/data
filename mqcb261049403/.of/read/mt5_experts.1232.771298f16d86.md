Calculation: Smoothed regression line = least-squares linear regression of the smoothed applied-price series over a configurable lookback, evaluated at a configurable offset.
Calculation: Trigger line = twice the smoothed regression line minus its value at a configurable number of earlier bars.
Long: On the configured signal timeframe, using the last completed bar and the preceding completed bar, trigger line > smoothed regression line AND trigger line on the preceding bar <= smoothed regression line on the preceding bar
Short: On the configured signal timeframe, using the last completed bar and the preceding completed bar, smoothed regression line > trigger line AND smoothed regression line on the preceding bar <= trigger line on the preceding bar
Exit: long, On the configured signal timeframe, using the last completed bar, smoothed regression line > trigger line
Exit: short, On the configured signal timeframe, using the last completed bar, trigger line > smoothed regression line