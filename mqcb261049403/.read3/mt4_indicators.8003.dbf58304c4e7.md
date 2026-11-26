Calculation: channel inset = (PriceChannelUpper(high, channel lookback parameter) − PriceChannelLower(low, channel lookback parameter)) × (channel offset parameter − channel narrowing factor parameter) / 100
Calculation: narrowed upper channel = PriceChannelUpper(high, channel lookback parameter) − channel inset
Calculation: narrowed lower channel = PriceChannelLower(low, channel lookback parameter) + channel inset
Calculation: trend state = short when the prior trend state was long and close < narrowed lower channel; long when the prior trend state was short and close > narrowed upper channel; otherwise the prior trend state
Long: trend state changes from short to long AND signal-display mode is enabled
Short: trend state changes from long to short AND signal-display mode is set to the down-signal mode
Long: trend state is long AND close > narrowed upper channel AND color-bar mode is enabled
Short: trend state is short AND close < narrowed lower channel AND color-bar mode is enabled
Long: trend state two bars ago was short AND trend state one bar ago is long AND current-bar volume > volume threshold parameter AND sound-alert mode is enabled
Short: trend state two bars ago was long AND trend state one bar ago is short AND current-bar volume > volume threshold parameter AND sound-alert mode is enabled