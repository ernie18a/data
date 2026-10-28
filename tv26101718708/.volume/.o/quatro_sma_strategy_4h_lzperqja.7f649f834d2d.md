Calculation: Short-term SMAs = simple moving averages of close over three successively longer lookbacks
Calculation: Long-term SMA = simple moving average of close over a lookback longer than each short-term SMA
Calculation: Average volume = simple moving average of volume over a longer lookback
Long: shortest-lookback SMA > middle-lookback SMA AND middle-lookback SMA > longest-lookback SMA AND close > long-term SMA AND volume > average volume multiplied by a threshold
Short: shortest-lookback SMA < middle-lookback SMA AND middle-lookback SMA < longest-lookback SMA AND close < long-term SMA AND volume > average volume multiplied by a threshold
Exit: Long, longest-lookback SMA > middle-lookback SMA AND middle-lookback SMA > shortest-lookback SMA AND close > long-term SMA
Exit: Short, shortest-lookback SMA > middle-lookback SMA AND middle-lookback SMA > longest-lookback SMA AND close < long-term SMA
Exit: Long, low <= entry price minus the stop-loss percentage of entry price OR high >= entry price plus the first take-profit percentage of entry price OR high >= entry price plus the second take-profit percentage of entry price OR high >= entry price plus the third take-profit percentage of entry price
Exit: Short, high >= entry price plus the stop-loss percentage of entry price OR low <= entry price minus the first take-profit percentage of entry price OR low <= entry price minus the second take-profit percentage of entry price OR low <= entry price minus the third take-profit percentage of entry price