Calculation: Prior lookback high/low = highest high / lowest low over the configured lookback, excluding the current bar
Calculation: Pool tolerance = configured multiple of ATR
Calculation: Hann FIR average = weighted average of current and prior closes using Hann-window weights; fast and medium versions use shorter lookbacks than the slow version
Long: low < prior lookback low − a configured fraction of pool tolerance AND close > prior lookback low OR fast Hann FIR average crosses above medium Hann FIR average
Short: high > prior lookback high + a configured fraction of pool tolerance AND close < prior lookback high OR fast Hann FIR average crosses below medium Hann FIR average