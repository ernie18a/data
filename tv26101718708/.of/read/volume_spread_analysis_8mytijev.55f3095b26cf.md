Calculation: Average volume = 40-bar simple moving average of volume, on the chart timeframe.
Calculation: Average spread = 80-bar simple moving average of high minus low, on the chart timeframe.
Calculation: Wide-range bar = high minus low > 1.5 × average spread.
Calculation: Short-term range scores = for each of the shorter minimum and maximum lookbacks n, (high − low n bars ago) ÷ (ATR(n) × √n) and (high n bars ago − low) ÷ (ATR(n) × √n); take the maximum of each pair as the upward and downward scores.
Calculation: Long-term range scores = the same calculations using minimum and maximum lookbacks longer than the corresponding short-term lookbacks; take the maximum of each pair as the upward and downward scores.
Calculation: Upward trend state = 1 if short-term upward score minus short-term downward score > 1; −1 if it is < −1; otherwise 0.
Calculation: Minor upward trend state = 1 if long-term upward score > 1; otherwise −1.
Calculation: Bullish reversal thrust = upward trend state < 0 AND minor upward trend state < 0 AND close > prior close AND close ≥ low + 0.7 × (high − low) AND volume > prior volume AND volume > average volume AND wide-range bar AND prior bar closed below its low + 0.3 × its spread.
Calculation: Low-volume test = low equals the lowest low of the current and prior 4 bars AND close ≥ low + 0.7 × (high − low) AND volume < each of the prior 2 bars.
Calculation: Upthrust bar = wide-range bar AND close is in the bottom 40% of the bar AND minor upward trend state > 0 AND high > prior high AND (upward score > 1 OR upward trend state > 0) AND volume > average volume.
Calculation: True upthrust bar = wide-range bar AND close is in the bottom 20% of the bar AND upward trend state > 0 AND high > prior high AND volume > average volume.
Calculation: Effort up = high > prior high AND low > prior low AND close > prior close AND close ≥ low + 0.7 × (high − low) AND high − low > average spread AND volume > average volume.
Calculation: Effort down = high < prior high AND low < prior low AND close < prior close AND close ≤ low + 0.25 × (high − low) AND wide-range bar AND volume > prior volume.
Calculation: Trend change = prior close > prior close from 2 bars ago AND high equals the highest high of the current and prior 4 bars AND close < prior close AND (close ≤ low + 0.3 × spread OR close is between the bottom 30% and 70% of the bar) AND volume > average volume AND upward trend state > 0 AND upward score > 1 AND NOT wide-range bar.
Calculation: Effort up failure = prior bar was an effort up bar AND (upthrust bar OR prior upthrust bar followed by a down bar that is not narrow-range OR prior upthrust bar followed by a down bar with volume > 1.3 × average volume OR current upthrust bar with volume > 2 × average volume OR down bar with spread > average spread).
Calculation: Effort down failure = prior bar was an effort down bar AND ((up bar with spread > average spread) OR bullish reversal thrust OR (volume > average volume AND (volume > 1.5 × average volume OR (prior down bar AND current up bar AND close in the top 40% of the bar AND minor upward trend state < 0 AND upward score ≤ 1))).
Long: (close > prior close AND prior bar was a bullish reversal thrust) OR (current bar is preceded by a low-volume test and close > prior close) OR (current bar is a low-volume test) OR effort up OR effort down failure.
Short: upthrust bar OR true upthrust bar OR trend change OR effort up failure OR effort down.
Exit: long, true upthrust bar.