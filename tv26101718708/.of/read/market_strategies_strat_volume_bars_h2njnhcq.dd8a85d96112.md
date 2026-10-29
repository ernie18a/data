Calculation: average volume = simple moving average of volume
Calculation: body strength (%) = absolute value of close minus open divided by high minus low, multiplied by 100; if high equals low, 0
Calculation: close position (%) = close minus low divided by high minus low, multiplied by 100; if high equals low, 50
Long: volume >= average volume × volume multiplier AND close > open AND close position >= close position threshold AND body strength >= minimum body strength threshold
Short: volume >= average volume × volume multiplier AND close < open AND close position <= 100% minus close position threshold AND body strength >= minimum body strength threshold