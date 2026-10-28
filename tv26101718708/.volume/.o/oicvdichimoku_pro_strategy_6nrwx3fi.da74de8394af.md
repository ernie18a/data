Calculation: CVD = EMA of volume when close > open, otherwise negative volume
Calculation: Ichimoku cloud top = higher of the Ichimoku leading spans calculated on the bar one displacement period earlier
Calculation: Ichimoku cloud bottom = lower of the Ichimoku leading spans calculated on the bar one displacement period earlier
Calculation: Stop level = signal-bar close minus (ATR × stop multiplier) for long positions, or plus it for short positions; alternatively, signal-bar close minus/plus the configured percentage of that close
Calculation: Take-profit levels = signal-bar close plus (ATR × target multiplier) for long positions, or minus it for short positions
Long: fast EMA crosses above slow EMA AND CVD > 0 AND (Ichimoku filter disabled OR close > Ichimoku cloud top)
Short: fast EMA crosses below slow EMA AND CVD < 0 AND (Ichimoku filter disabled OR close < Ichimoku cloud bottom)
Exit: long, low <= stop level OR high >= first take-profit level OR high >= second take-profit level
Exit: short, high >= stop level OR low <= first take-profit level OR low <= second take-profit level