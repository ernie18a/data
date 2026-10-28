Calculation: Bullish liquidity sweep = a confirmed pivot low from the prior swing-length bars, not previously taken and no older than the liquidity-validity lookback, is crossed by the current low and the current close is above it; use the most recently stored qualifying pivot low. Mark a pivot taken when a bar closes below it or sweeps it.
Calculation: Bearish liquidity sweep = a confirmed pivot high from the prior swing-length bars, not previously taken and no older than the liquidity-validity lookback, is crossed by the current high and the current close is below it; use the most recently stored qualifying pivot high. Mark a pivot taken when a bar closes above it or sweeps it.
Calculation: Bullish displacement = close > open AND (high − low) ≥ ATR × displacement multiplier AND (body filter disabled OR |close − open| ÷ (high − low) × 100 ≥ minimum body percentage).
Calculation: Bearish displacement = close < open AND (high − low) ≥ ATR × displacement multiplier AND (body filter disabled OR |close − open| ÷ (high − low) × 100 ≥ minimum body percentage).
Calculation: Bullish MSS = close > the latest confirmed pivot high, using the MSS pivot lookback.
Calculation: Bearish MSS = close < the latest confirmed pivot low, using the MSS pivot lookback.
Calculation: Bullish FVG valid = within 10 bars of the latest bar where low > high two bars earlier.
Calculation: Bearish FVG valid = within 10 bars of the latest bar where high < low two bars earlier.
Calculation: Discount = close ≤ (highest high − lowest low) ÷ 2 over the premium/discount lookback, including the current bar.
Calculation: Premium = close ≥ (highest high − lowest low) ÷ 2 over the premium/discount lookback, including the current bar.
Calculation: Higher-timeframe bullish bias = close > EMA on the last completed higher-timeframe bar; calculate the EMA on that timeframe.
Calculation: Higher-timeframe bearish bias = close < EMA on the last completed higher-timeframe bar; calculate the EMA on that timeframe.
Calculation: Volume strong = volume > 0 AND volume ≥ average volume over the volume lookback × volume multiplier.
Calculation: Bullish signal score = min(100, 0.25 × min(100, bullish sweep depth ÷ ATR × 100) + 0.20 × (bullish displacement ? 100 : 20) + 0.20 × (MSS disabled or bullish MSS ? 100 : 15) + 0.10 × (volume filter disabled ? 100 : volume strong ? 100 : 35) + 0.10 × (higher-timeframe filter disabled ? 100 : bullish bias ? 100 : 20) + 0.10 × (premium/discount filter disabled ? 100 : discount ? 100 : 20) + 0.05 × (FVG filter disabled ? 100 : bullish FVG valid ? 100 : 20)).
Calculation: Bearish signal score = min(100, 0.25 × min(100, bearish sweep depth ÷ ATR × 100) + 0.20 × (bearish displacement ? 100 : 20) + 0.20 × (MSS disabled or bearish MSS ? 100 : 15) + 0.10 × (volume filter disabled ? 100 : volume strong ? 100 : 35) + 0.10 × (higher-timeframe filter disabled ? 100 : bearish bias ? 100 : 20) + 0.10 × (premium/discount filter disabled ? 100 : premium ? 100 : 20) + 0.05 × (FVG filter disabled ? 100 : bearish FVG valid ? 100 : 20)).
Calculation: Long stop = lower of (bullish swept pivot low − ATR × stop buffer) and (entry price − ATR × minimum risk multiplier).
Calculation: Short stop = higher of (bearish swept pivot high + ATR × stop buffer) and (entry price + ATR × minimum risk multiplier).
Calculation: Long third target = entry price + (entry price − long stop) × third risk/reward multiplier.
Calculation: Short third target = entry price − (short stop − entry price) × third risk/reward multiplier.
Long: bullish liquidity sweep OR (flat position AND ATR > 0 AND confirmed bar AND bullish liquidity sweep AND bullish signal score ≥ minimum score AND cooldown elapsed AND (displacement requirement disabled OR bullish displacement) AND (MSS requirement disabled OR bullish MSS)).
Short: bearish liquidity sweep OR (flat position AND ATR > 0 AND confirmed bar AND bearish liquidity sweep AND bearish signal score ≥ minimum score AND cooldown elapsed AND (displacement requirement disabled OR bearish displacement) AND (MSS requirement disabled OR bearish MSS)).
Exit: long, confirmed bar after entry bar AND (low ≤ current stop OR (close-at-third-target enabled AND high ≥ long third target)).
Exit: short, confirmed bar after entry bar AND (high ≥ current stop OR (close-at-third-target enabled AND low ≤ short third target)).