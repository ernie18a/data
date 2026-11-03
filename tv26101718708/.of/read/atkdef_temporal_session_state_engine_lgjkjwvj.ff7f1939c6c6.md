Calculation: Session range and prices = For each of three independently parameterized UTC session windows, reset at each exchange-timezone calendar-day boundary; accumulate the high, low, first open, and latest close of chart bars whose opening times fall within that session, including the current bar when applicable.
Calculation: Confirmed pivot high = A chart bar high that is a pivot high using specified left and right bar counts; recognize it only when the required right-hand bars have completed.
Calculation: Confirmed pivot low = A chart bar low that is a pivot low using specified left and right bar counts; recognize it only when the required right-hand bars have completed.
Long: Confirmed pivot low exists on the current chart bar.
Short: Confirmed pivot high exists on the current chart bar.
Long: For any of five ordered higher-timeframe layers, the close of the bar still forming > the high of the last completed bar.
Short: For any of five ordered higher-timeframe layers, the close of the bar still forming < the low of the last completed bar.
Long: For any of five ordered higher-timeframe layers, the last completed bar's close > its open multiplied by an upper threshold.
Short: For any of five ordered higher-timeframe layers, the last completed bar's close < its open multiplied by a lower threshold.
Long: For any session with at least one collected bar, the latest session close > the first session open.
Short: For any session with at least one collected bar, the latest session close < the first session open.
Long: For any session with at least one collected bar, the chart close > the accumulated session high.
Short: For any session with at least one collected bar, the chart close < the accumulated session low.