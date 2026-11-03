Calculation: Confirmed swing high/low = a bar’s high/low is the highest/lowest across equal lookback windows on both sides; use only after the right-side bars complete
Calculation: ATR = average true range over the configured lookback
Calculation: Bullish/bearish sweep = the first untaken confirmed swing low/high within the configured validity window where low < swing low and close > swing low / high > swing high and close < swing high; a close beyond the level marks it taken
Long: low < an untaken confirmed swing low and close > that swing low
Short: high > an untaken confirmed swing high and close < that swing high
Calculation: Bullish/bearish MSS = close > the latest confirmed pivot high / close < the latest confirmed pivot low, using the configured pivot lookback
Calculation: Bullish/bearish displacement = close > open / close < open, and high − low ≥ ATR × configured displacement threshold, and (if enabled) absolute(close − open) ÷ (high − low) × 100 ≥ configured minimum body percentage
Calculation: Strong volume = volume > 0 and volume ≥ simple moving average of volume over the configured lookback × configured volume multiplier
Calculation: Higher-timeframe bias = close of the last completed higher-timeframe bar > / < EMA of that bar; use the last completed higher-timeframe bar
Calculation: Discount/premium = close ≤ / ≥ midpoint of the highest high and lowest low over the configured lookback
Calculation: Bullish/bearish FVG = current low > high two bars earlier / current high < low two bars earlier; valid for the configured number of bars after formation
Calculation: Bullish sweep score = min(100, (swing low − low) ÷ ATR × 100); bearish sweep score = min(100, (high − swing high) ÷ ATR × 100)
Calculation: Directional signal score = min(100, 0.25 × sweep score + 0.20 × displacement score + 0.20 × MSS score + 0.10 × volume score + 0.10 × higher-timeframe score + 0.10 × premium/discount score + 0.05 × FVG score); applicable score is 100 when its condition holds, otherwise 20 for displacement, volume, higher-timeframe, premium/discount, or FVG and 15 for MSS; sweep score is 0 when no sweep
Calculation: Long stop = lower of (swept swing low − ATR × configured stop buffer) and (entry price − ATR × configured minimum risk); short stop = higher of (swept swing high + ATR × configured stop buffer) and (entry price + ATR × configured minimum risk)
Calculation: Long target 3 = entry price + (entry price − long stop) × configured target-3 risk multiple; short target 3 = entry price − (short stop − entry price) × configured target-3 risk multiple
Long: bullish sweep and bullish signal score ≥ configured minimum score and cooldown elapsed and (displacement filter disabled or bullish displacement) and (MSS filter disabled or bullish MSS) and bar confirmed and flat position and ATR > 0
Short: bearish sweep and bearish signal score ≥ configured minimum score and cooldown elapsed and (displacement filter disabled or bearish displacement) and (MSS filter disabled or bearish MSS) and bar confirmed and flat position and ATR > 0
Exit: long, after the entry bar on a confirmed bar, low ≤ active stop or (TP3 closing enabled and high ≥ long target 3)
Exit: short, after the entry bar on a confirmed bar, high ≥ active stop or (TP3 closing enabled and low ≤ short target 3)