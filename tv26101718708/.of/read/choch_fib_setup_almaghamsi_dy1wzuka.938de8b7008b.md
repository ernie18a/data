Calculation: Structure bias = Start at 0. On each bar, update the latest confirmed pivot high and pivot low using equal numbers of left and right bars. Using the bias before this bar, set bullish change when the selected bullish break price is above the latest pivot high and bias <= 0; set bearish change when the selected bearish break price is below the latest pivot low and bias >= 0. The bullish break price is either close or high, and the bearish break price is respectively close or low. Set bias to 1 on a bullish change and to -1 on a bearish change; if both occur on the same bar, set it to -1. Otherwise retain the previous bias.
Calculation: Higher-timeframe structure bias = Apply the same structure bias calculation and pivot length to higher-timeframe bars. Use the last completed higher-timeframe bar on historical bars and the still-forming higher-timeframe bar in real time.
Long: Bullish change = true
Short: Bearish change = true
Long: Structure bias = 1
Short: Structure bias = -1
Long: Higher-timeframe filter enabled AND higher-timeframe structure bias = 1
Short: Higher-timeframe filter enabled AND higher-timeframe structure bias = -1