Calculation: Session range = the highest high and lowest low of chart bars in a configured New York time session; retain the range from the first chart bar after the session ends until the next regular session starts.
Calculation: Session close-half value = the close of the first chart bar after the session ends, compared with the midpoint of that session range.
Calculation: Initial balance first extreme = the final initial balance high or low first reached by completed lower-timeframe bars within the initial balance; if both are first reached in the same lower-timeframe bar, the high is first. If the lower timeframe equals the chart timeframe, use the chart bars.
Calculation: Initial balance first break = the first completed lower-timeframe bar after the initial balance ends and during the regular session whose high is at least the initial balance high or whose low is at most the initial balance low; if both occur on that bar, the high is first. If the lower timeframe equals the chart timeframe or lower-timeframe data is unavailable, use the chart bars. Retain the result until the next initial balance starts.
Long: During the regular session, the shorter opening range is complete AND its close-half value is at least its range midpoint.
Short: During the regular session, the shorter opening range is complete AND its close-half value is below its range midpoint.
Long: During the regular session, the longer opening range is complete AND its close-half value is at least its range midpoint.
Short: During the regular session, the longer opening range is complete AND its close-half value is below its range midpoint.
Long: During the regular session, the initial balance is complete AND its first extreme is the low.
Short: During the regular session, the initial balance is complete AND its first extreme is the high.
Long: During the regular session, the initial balance is complete AND its close-half value is at least its range midpoint.
Short: During the regular session, the initial balance is complete AND its close-half value is below its range midpoint.
Long: During the regular session, the initial balance first break is the high.
Short: During the regular session, the initial balance first break is the low.