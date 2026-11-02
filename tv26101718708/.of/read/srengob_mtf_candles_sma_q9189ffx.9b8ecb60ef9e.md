Calculation: Swing levels = Maintain a state initialized to high. At each bar, if the high a swing-lookback bars ago is greater than the highest high of the most recent swing-lookback bars including the current bar, set state to high; otherwise, if the low a swing-lookback bars ago is less than the lowest low of those bars, set state to low; otherwise retain state. On a change to high, replace the latest swing high with that earlier high; on a change to low, replace the latest swing low with that earlier low. Each new swing level starts uncrossed.
Calculation: Order blocks = Choose body bounds or full candle bounds as a parameter. When close first rises above an uncrossed swing high, mark that swing crossed and create a bullish block from the selected bounds of the candle with the lowest lower bound between the swing bar and current bar, excluding both; ties select the oldest candle. Initialize the candidate lower bound to the previous candle's upper bound and its upper bound to the previous candle's lower bound. When close first falls below an uncrossed swing low, mark that swing crossed and create a bearish block from the selected bounds of the candle with the highest upper bound in the same interval; ties select the oldest candle. Initialize the candidate bounds to the previous candle's selected bounds. On every bar, delete bullish blocks whose lower bound exceeds the lower body bound and bearish blocks whose upper bound is below the upper body bound. Use the most recently created surviving block of each side.
Calculation: Divergence = Bullish when short-lookback close rate of change > long-lookback close rate of change AND short-lookback rate of change > its previous value AND close < previous close; bearish when all three inequalities are reversed.
Calculation: Acceleration = The current change in close minus twice the previous change in close plus the change in close before that.
Calculation: Early bullish momentum = Acceleration > 0 AND close > previous close AND (bullish divergence OR (volume > a parameter multiple of its SMA AND close > open) OR (close - low > a parameter multiple of high - close AND volume > its SMA)).
Calculation: Early bearish momentum = Acceleration < 0 AND close < previous close AND (bearish divergence OR (volume > a parameter multiple of its SMA AND close < open) OR (high - close > a parameter multiple of close - low AND volume > its SMA)).
Calculation: Normalized momentum = (close - close a momentum-lookback bars ago) / longer-lookback ATR.
Calculation: Bullish impulse = (early bullish momentum OR normalized momentum > a positive threshold) AND (close > latest swing high OR bullish divergence).
Calculation: Bearish impulse = (early bearish momentum OR normalized momentum < the negative of that threshold) AND (close < latest swing low OR bearish divergence).
Long: Low < bullish block lower bound AND close > bullish block lower bound.
Short: High > bearish block upper bound AND close < bearish block upper bound.
Long: Close > latest swing high.
Short: Close < latest swing low AND close <= latest swing high.
Long: Close >= bullish block lower bound AND close <= bullish block upper bound.
Short: Close >= bearish block lower bound AND close <= bearish block upper bound AND (close < bullish block lower bound OR close > bullish block upper bound OR no bullish block exists).
Long: Close > open AND high - max(open, close) > a parameter multiple of abs(close - open) AND high - max(open, close) >= a parameter fraction of high - low.
Short: Close < open AND min(open, close) - low > a parameter multiple of abs(close - open) AND min(open, close) - low >= a parameter fraction of high - low.
Long: Bullish divergence.
Short: Bearish divergence.
Long: Early bullish momentum.
Short: Early bearish momentum.
Long: Bullish impulse.
Short: Bearish impulse AND bullish impulse is false.
Long: Normalized momentum > 0.
Short: Normalized momentum <= 0.