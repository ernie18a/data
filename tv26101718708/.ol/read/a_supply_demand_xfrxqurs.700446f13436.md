Calculation: Displacement = absolute(close − open) > ATR × displacement threshold AND volume / simple moving average of volume over a lookback >= minimum volume ratio
Calculation: Demand zone = preceding bar’s high-to-low range when a displacement bar closes above its open
Calculation: Supply zone = preceding bar’s high-to-low range when a displacement bar closes below its open
Long: low <= top of an unmitigated demand zone AND high >= bottom of that zone AND this is the zone’s first price intersection AND close > EMA
Short: low <= top of an unmitigated supply zone AND high >= bottom of that zone AND this is the zone’s first price intersection AND close < EMA
Exit: long, high >= entry price + risk distance × risk/reward ratio OR low <= demand zone bottom − ATR × stop buffer
Exit: short, low <= entry price − risk distance × risk/reward ratio OR high >= supply zone top + ATR × stop buffer