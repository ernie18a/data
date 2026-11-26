Calculation: bar delta = sum of footprint-row delta for the chart bar
Calculation: window cumulative delta = sum of bar delta over the delta-window lookback
Long: window cumulative delta >= 0
Short: window cumulative delta < 0
Long: bar delta >= 0
Short: bar delta < 0
Long: The highest-volume footprint row with volume >= the bar's highest footprint-row volume × the volume-gate parameter, |row delta| / row volume <= the absorption-balance threshold, and midpoint in the lower third of the bar
Short: The highest-volume footprint row with volume >= the bar's highest footprint-row volume × the volume-gate parameter, |row delta| / row volume <= the absorption-balance threshold, and midpoint in the upper third of the bar
Long: The positive-delta footprint row with the greatest delta among rows with volume >= the bar's highest footprint-row volume × the volume-gate parameter and |row delta| / row volume > the absorption-balance threshold
Short: The negative-delta footprint row with the greatest absolute delta among rows with volume >= the bar's highest footprint-row volume × the volume-gate parameter and |row delta| / row volume > the absorption-balance threshold
Long: At bar close, an unbroken supply shelf is touched (low <= shelf top AND high >= shelf bottom) and close < shelf bottom
Short: At bar close, an unbroken demand shelf is touched (low <= shelf top AND high >= shelf bottom) and close > shelf top
Long: At bar close, an unbroken supply shelf has close > shelf top + ATR(lookback) × break-buffer parameter
Short: At bar close, an unbroken demand shelf has close < shelf bottom - ATR(lookback) × break-buffer parameter
Long: At bar close, an unflipped broken supply shelf is touched (low <= shelf top AND high >= shelf bottom) and close > shelf top
Short: At bar close, an unflipped broken demand shelf is touched (low <= shelf top AND high >= shelf bottom) and close < shelf bottom