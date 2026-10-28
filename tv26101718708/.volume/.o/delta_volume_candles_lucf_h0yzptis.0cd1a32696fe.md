Calculation: Intrabar up/down volume = sum volume from lower-timeframe bars within the current chart bar, assigning each intrabar by close versus open; if equal, by close versus the previous intrabar close; if still equal, by the last known polarity. Sum up-polarity volume as up volume and down-polarity volume as down volume.
Calculation: Bar Balance = up volume − down volume.
Calculation: Average Balance = EMA(up volume) − EMA(down volume), using the same lookback for both EMAs.
Calculation: Momentum Balance = RSI((EMA(up volume) − SMA(up volume)) − (EMA(down volume) − SMA(down volume))) − 50; both SMAs use twice the EMA lookback.
Calculation: Relative Balance = ALMA(max(0, up volume − EMA(up volume)) − max(0, down volume − EMA(down volume))). The EMAs use the Average Balance lookback.
Calculation: Percent Balance = ALMA(100 × Bar Balance ÷ chart-bar volume).
Calculation: Combined Balances = sum of the signs of Bar, Average, Momentum, Relative, and Percent Balance; zero values contribute zero.
Calculation: Up bump = close > open AND close > previous close AND Bar Balance > 0 AND up volume > EMA(up volume) AND up volume > previous bar's up volume.
Calculation: Down bump = close < open AND close < previous close AND Bar Balance < 0 AND down volume > EMA(down volume) AND down volume > previous bar's down volume. The EMAs use the Average Balance lookback.
Calculation: Up double bump = current and previous bar both meet Up bump.
Calculation: Down double bump = current and previous bar both meet Down bump.
Calculation: Balance divergence = sign of the selected balance differs from sign of close − open.
Calculation: Bullish divergence confirmation = previous bar had Balance divergence AND current close > open AND current bar has no Balance divergence. Bearish divergence confirmation = previous bar had Balance divergence AND current close < open AND current bar has no Balance divergence. The selected balance is one of Bar, Average, Momentum, Relative, Percent, or Combined Balance.
Calculation: Bullish balance shift = selected balance crosses from at or below zero to above zero. Bearish balance shift = selected balance crosses from at or above zero to below zero. The selected balance is one of Average, Momentum, Relative, Percent, or Combined Balance.
Calculation: Marker Bias = rolling sum over the selected lookback of the up occurrences minus down occurrences of Up bump, Up double bump, Bullish divergence confirmation, Bullish balance shift, Down bump, Down double bump, Bearish divergence confirmation, and Bearish balance shift.
Long: Up bump OR Up double bump OR Bullish divergence confirmation OR bullish balance shift OR Marker Bias crosses from at or below zero to above zero OR Combined Balances = 5
Short: Down bump OR Down double bump OR Bearish divergence confirmation OR bearish balance shift OR Marker Bias crosses from at or above zero to below zero OR Combined Balances = −5