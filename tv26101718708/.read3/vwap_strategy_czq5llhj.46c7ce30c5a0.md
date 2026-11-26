Calculation: session VWAP = cumulative(source × volume) / cumulative(volume) on chart bars, reset each T1 boundary
Calculation: VWAP deviation = sqrt(cumulative(source² × volume) / cumulative(volume) − session VWAP²) on chart bars, reset each T1 boundary
Calculation: bullish strength = IF high > low THEN (close − low) / (high − low) ELSE 0
Calculation: bearish strength = IF high > low THEN (high − close) / (high − low) ELSE 0
Long: open < session VWAP − VWAP deviation × entry deviation multiplier AND close > session VWAP − VWAP deviation × entry deviation multiplier AND bullish strength ≥ minimum signal strength
Long: long trades enabled AND no open position AND open < session VWAP − VWAP deviation × entry deviation multiplier AND close > session VWAP − VWAP deviation × entry deviation multiplier AND bullish strength ≥ minimum signal strength AND VWAP deviation × minimum-width deviation multiplier ≥ ATR(ATR lookback) × minimum-width ATR multiplier
Short: open > session VWAP + VWAP deviation × entry deviation multiplier AND close < session VWAP + VWAP deviation × entry deviation multiplier AND bearish strength ≥ minimum signal strength
Short: short trades enabled AND no open position AND open > session VWAP + VWAP deviation × entry deviation multiplier AND close < session VWAP + VWAP deviation × entry deviation multiplier AND bearish strength ≥ minimum signal strength AND VWAP deviation × minimum-width deviation multiplier ≥ ATR(ATR lookback) × minimum-width ATR multiplier
Exit: Long, low ≤ low of long signal bar − stop buffer
Exit: Short, high ≥ high of short signal bar + stop buffer
Exit: Long, long exit mode selects VWAP AND high ≥ session VWAP OR long exit mode selects deviation band AND high ≥ session VWAP + VWAP deviation × long target deviation
Exit: Short, short exit mode selects VWAP AND low ≤ session VWAP OR short exit mode selects deviation band AND low ≤ session VWAP − VWAP deviation × short target deviation
Exit: Long, safety exit enabled AND each of the last opposing-bars-lookback chart bars closes below its open
Exit: Short, safety exit enabled AND each of the last opposing-bars-lookback chart bars closes above its open