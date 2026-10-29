Calculation: Relative volume = current bar volume divided by the mean volume over the selected one-week baseline.
Calculation: Surge count = rolling-window count of bars whose relative volume reaches the selected tier.
Calculation: Up surge count = rolling-window count of bars reaching the selected tier with close > open; down surge count = rolling-window count reaching it with close < open.
Calculation: Window price change = percentage change from the close at the rolling-window lookback to the current close.
Calculation: Bias score = sign of window price change + sign of up surge count minus down surge count.
Long: surge count >= the minimum required hits AND Bias score > 0
Short: surge count >= the minimum required hits AND Bias score < 0