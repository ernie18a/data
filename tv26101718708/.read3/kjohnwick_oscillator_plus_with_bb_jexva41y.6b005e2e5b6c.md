Calculation: Oscillator = HMA(RSI(source, RSI lookback), oscillator smoothing lookback)
Calculation: Signal = HMA(Oscillator, signal smoothing lookback)
Long: Triple Sniper confirms bullish trend AND ((Oscillator > Signal AND Oscillator <= ribbon color threshold) OR (Oscillator <= Signal AND Oscillator < ribbon color threshold)) AND Oscillator <= lower Bollinger Band(Oscillator, band lookback, band deviation)
Short: Triple Sniper confirms bearish trend AND ((Oscillator > Signal AND Oscillator > ribbon color threshold) OR (Oscillator <= Signal AND Oscillator >= ribbon color threshold)) AND Oscillator >= upper Bollinger Band(Oscillator, band lookback, band deviation)
Long: MFI(source, money flow lookback) > money flow background threshold
Short: MFI(source, money flow lookback) <= money flow background threshold
Long: Lowest(source, divergence lookback) < Lowest(source[1], divergence lookback) AND Lowest(Oscillator, divergence lookback) > Lowest(Oscillator[1], divergence lookback) AND Oscillator < oversold divergence threshold
Short: Highest(source, divergence lookback) > Highest(source[1], divergence lookback) AND Highest(Oscillator, divergence lookback) < Highest(Oscillator[1], divergence lookback) AND Oscillator > overbought divergence threshold
Long: Oscillator crosses above Signal
Short: Oscillator crosses below Signal
Long: Oscillator crosses below lower Bollinger Band(Oscillator, band lookback, band deviation)
Short: Oscillator crosses above upper Bollinger Band(Oscillator, band lookback, band deviation)