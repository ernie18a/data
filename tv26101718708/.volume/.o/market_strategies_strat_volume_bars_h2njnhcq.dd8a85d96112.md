Calculation: Average volume = simple moving average of volume over a lookback
Calculation: Body strength = absolute difference between close and open divided by high minus low, expressed as a percentage; use 0 when high equals low
Calculation: Close position = close minus low divided by high minus low, expressed as a percentage; use 50% when high equals low
Long: volume >= average volume × a multiplier AND close > open AND close position >= a threshold AND body strength >= a threshold
Short: volume >= average volume × the same multiplier as Long AND close < open AND close position <= 100% minus the Long close-position threshold AND body strength >= the Long body-strength threshold