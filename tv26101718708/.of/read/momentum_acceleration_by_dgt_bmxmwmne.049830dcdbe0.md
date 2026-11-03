Calculation: Momentum acceleration = velocity minus (velocity minus velocity one acceleration period ago) divided by the acceleration period; velocity is the simple moving average of (source minus source one acceleration period ago) divided by the acceleration period. Source is selectable as close or on-balance volume.
Long: Momentum acceleration > 0
Short: Momentum acceleration < 0
Long: Momentum acceleration one bar ago > 0 AND momentum acceleration two bars ago <= 0
Short: Momentum acceleration one bar ago < 0 AND momentum acceleration two bars ago >= 0
Long: Position side is not long AND momentum acceleration one bar ago > 0 AND momentum acceleration two bars ago <= 0 AND momentum acceleration is not crossing below 0
Short: Position side is not short AND momentum acceleration one bar ago < 0 AND momentum acceleration two bars ago >= 0 AND momentum acceleration is not crossing above 0
Long: Momentum acceleration crossed above 0 one bar ago AND (long candle confirmation disabled OR close > open)
Long: Momentum acceleration crossed above 0 two bars ago AND (long candle confirmation disabled OR previous close > previous open)
Short: Momentum acceleration crossed below 0 one bar ago AND (short candle confirmation disabled OR close < open)
Short: Momentum acceleration crossed below 0 two bars ago AND (short candle confirmation disabled OR previous close < previous open)
Exit: long, momentum acceleration crossed below 0 one bar ago AND (short candle confirmation disabled OR close < open)
Exit: long, momentum acceleration crossed below 0 two bars ago AND (short candle confirmation disabled OR previous close < previous open)
Exit: short, momentum acceleration crossed above 0 one bar ago AND (long candle confirmation disabled OR close > open)
Exit: short, momentum acceleration crossed above 0 two bars ago AND (long candle confirmation disabled OR previous close > previous open)
Exit: long, stop loss enabled AND low <= entry price * (1 - stop loss fraction)
Exit: short, stop loss enabled AND high >= entry price * (1 + stop loss fraction)