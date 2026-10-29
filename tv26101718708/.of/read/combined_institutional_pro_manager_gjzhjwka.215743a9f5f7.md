Calculation: Bullish FVG = high two bars ago < current low AND previous close > high two bars ago; recent bullish FVG = a bullish FVG occurred within the shorter lookback
Calculation: Bearish FVG = low two bars ago > current high AND previous close < low two bars ago; recent bearish FVG = a bearish FVG occurred within the shorter lookback
Calculation: Bullish BOS = close crosses above the latest confirmed swing high
Calculation: Bearish BOS = close crosses below the latest confirmed swing low
Calculation: Swing high/low = confirmed pivot high/low using equal left and right lookbacks
Calculation: Volume confirmation = volume > its moving average × volume multiplier
Calculation: Long entry price = low of the signal bar; short entry price = high of the signal bar
Calculation: Initial stop = entry price minus the stop distance for long positions, or plus the stop distance for short positions
Calculation: Target = entry price plus the initial risk × target risk/reward ratio for long positions, or minus it for short positions
Calculation: Break-even trigger = entry price plus the initial risk × break-even ratio for long positions, or minus it for short positions; after price reaches this trigger, stop moves to entry price
Long: (flat AND (trend filter disabled OR (close > long-term simple moving average of close AND close > shorter-term exponential moving average of close)) AND bullish BOS AND recent bullish FVG AND volume confirmation) OR (pending long AND low <= long entry price minus execution buffer AND bars since signal <= pending-order expiry)
Short: (flat AND (trend filter disabled OR (close < long-term simple moving average of close AND close < shorter-term exponential moving average of close)) AND bearish BOS AND recent bearish FVG AND volume confirmation) OR (pending short AND high >= short entry price plus execution buffer AND bars since signal <= pending-order expiry)
Exit: long, low <= current stop OR high >= target plus take-profit buffer
Exit: short, high >= current stop OR low <= target minus take-profit buffer