Calculation: FVG threshold = configured percentage threshold, or in automatic mode cumulative sum of (high − low) / low divided by bar_index
Calculation: Bullish FVG = low > high[2] AND close[1] > high[2] AND (low − high[2]) / high[2] > FVG threshold
Calculation: Bearish FVG = high < low[2] AND close[1] < low[2] AND (low[2] − high) / high > FVG threshold
Calculation: Gap signal upper/lower = high/low in wick mode; otherwise max(open, close)/min(open, close)
Calculation: ATR-qualified gap = gap width > configured multiplier × 200-bar ATR, using cumulative mean high − low range if ATR is unavailable
Calculation: Bullish IFVG = a prior ATR-qualified bearish FVG is invalidated when gap signal upper > its top (low[2])
Calculation: Bearish IFVG = a prior ATR-qualified bullish FVG is invalidated when gap signal lower < its bottom (high[2])
Long: Bullish FVG OR Bullish IFVG
Short: Bearish FVG OR Bearish IFVG