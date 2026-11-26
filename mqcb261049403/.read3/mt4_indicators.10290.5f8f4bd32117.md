Calculation: Average spread = sum(high - low over the evaluated bar and the preceding spread-lookback bars) / spread lookback
Calculation: Spread deviation = abs(high - low - average spread) * sqrt((spread lookback + 1) / spread lookback)
Calculation: Spread class = narrow, average, or wide by comparing high - low with average spread and spread deviation using separate class thresholds
Calculation: Average volume = sum(volume over the evaluated bar and the preceding volume-lookback bars) / volume lookback
Calculation: Volume deviation = sqrt(sum((volume - average volume)^2 over the evaluated bar and the preceding volume-lookback bars) / volume lookback)
Calculation: Volume class = low, average, high, or excessive by comparing volume with average volume and volume deviation using separate class thresholds
Calculation: Close position = (close - low) / (high - low)
Calculation: Close class = lower, middle, or upper by comparing close position with separate lower and upper thresholds
Calculation: Local high = high equals the highest high over the evaluated bar and the preceding lookback bars
Calculation: Local low = low equals the lowest low over the evaluated bar and the preceding lookback bars
Long: (spread class is narrow OR spread class is average) AND (close class is middle OR close class is upper) AND volume class is low AND volume[0] < volume[1] AND volume[1] < volume[2] AND close[0] < close[1]
Long: (spread class is narrow OR spread class is average) AND close class is upper AND volume class is excessive AND local low
Long: close class is upper AND volume class is low
Long: (spread class is wide OR spread class is average) AND close class is upper AND close[0] > close[1] AND volume[0] > volume[1] AND volume[0] > volume[2]
Long: close class is upper AND (volume class is high OR volume class is excessive) AND close[0] < close[1]
Long: spread class is wide AND close class is upper AND local low AND (volume class is high OR volume class is excessive)
Long: close position[1] >= a parameter AND close[1] < close[2] AND volume[1] >= average volume[1] + a parameter * volume deviation[1] AND close[0] > close[1]
Long: spread class is wide AND close class is lower
Short: (spread class is narrow OR spread class is average) AND close[0] > close[1] AND volume class is low
Short: spread class is wide AND close[0] < close[1] AND close class is lower AND volume class is low
Short: (spread class is narrow OR spread class is average) AND volume class is excessive AND close class is upper AND local high
Short: close[1] > close[2] AND volume[1] >= average volume[1] + a parameter * volume deviation[1] AND local high[1] AND close[0] <= close[1]
Short: (spread class is wide OR spread class is average) AND close[0] < close[1] AND volume[0] > volume[1] AND volume[0] > volume[2] AND close class is lower
Short: volume[1] >= average volume[1] + a parameter * volume deviation[1] AND close position[1] <= a parameter AND (close[0] < close[1] OR (spread class is narrow AND close[0] > close[1]))
Short: spread class is wide AND close class is lower