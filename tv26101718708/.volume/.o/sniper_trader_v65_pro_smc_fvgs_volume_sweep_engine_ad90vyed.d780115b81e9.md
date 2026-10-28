Calculation: Signed volume delta = volume when close > open, −volume when close < open, and 0 when close = open
Calculation: Cumulative volume delta = cumulative signed volume delta, reset at each configured session reset
Calculation: Confirmed pivot high/low = local high/low using a longer left lookback and shorter right lookback
Calculation: Bullish divergence = current low < latest confirmed pivot low AND current cumulative volume delta > cumulative volume delta at that pivot
Calculation: Bearish divergence = current high > latest confirmed pivot high AND current cumulative volume delta < cumulative volume delta at that pivot
Calculation: Divergence zone = for bullish divergence, low to the lower of open and close; for bearish divergence, the higher of open and close to high
Calculation: Valid bullish rejection = (min(open, close) − low) / (high − low) ≥ 0.3 AND (high − max(open, close)) / (high − low) ≤ 0.6
Calculation: Valid bearish rejection = (high − max(open, close)) / (high − low) ≥ 0.3 AND (min(open, close) − low) / (high − low) ≤ 0.6
Long: bullish divergence becomes true AND was false on the previous bar OR an active bullish divergence zone is old enough, low ≤ its top, close > its bottom, close > open, valid bullish rejection, and the bar is within the configured trading session if that filter is enabled OR close > the top of an active bearish divergence zone AND close > the longer-lookback SMA of close AND the bar is within the configured trading session if that filter is enabled
Short: bearish divergence becomes true AND was false on the previous bar OR an active bearish divergence zone is old enough, high ≥ its bottom, close < its top, close < open, valid bearish rejection, and the bar is within the configured trading session if that filter is enabled OR close < the bottom of an active bullish divergence zone AND close < the longer-lookback SMA of close AND the bar is within the configured trading session if that filter is enabled
Exit: long, close ≤ the bottom of the bearish divergence zone used for entry
Exit: short, close ≥ the top of the bullish divergence zone used for entry