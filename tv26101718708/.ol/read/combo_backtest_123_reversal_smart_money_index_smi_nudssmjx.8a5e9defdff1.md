Calculation: Fast stochastic = Stochastic oscillator of close, high, and low using prior completed chart-timeframe bars, smoothed over a short lookback
Calculation: Slow stochastic = Fast stochastic smoothed over a longer lookback
Calculation: Smart money index = prior index − (open − close) + (open − close) from the last completed higher-timeframe bar
Long: Close[3] < Close[2] AND Close[1] > Close[2] AND Fast stochastic < Slow stochastic AND Fast stochastic > level
Short: Close[3] > Close[2] AND Close[1] < Close[2] AND Fast stochastic > Slow stochastic AND Fast stochastic < level
Long: Smart money index < its moving average
Short: Smart money index > its moving average
Long: Close[3] < Close[2] AND Close[1] > Close[2] AND Fast stochastic < Slow stochastic AND Fast stochastic > level AND Smart money index < its moving average
Short: Close[3] > Close[2] AND Close[1] < Close[2] AND Fast stochastic > Slow stochastic AND Fast stochastic < level AND Smart money index > its moving average
Exit: long or short, NOT (Close[3] < Close[2] AND Close[1] > Close[2] AND Fast stochastic < Slow stochastic AND Fast stochastic > level AND Smart money index < its moving average) AND NOT (Close[3] > Close[2] AND Close[1] < Close[2] AND Fast stochastic > Slow stochastic AND Fast stochastic < level AND Smart money index > its moving average)