Calculation: score = sum, over MACD line > its signal line, stochastic %K > %D, momentum > 0, RSI > 50, Vortex positive > negative, +DI > −DI, MFI > 50, and Fisher Transform > its signal line, adding 1 when each condition is true and −1 otherwise; MACD uses a shorter-lookback EMA minus a longer-lookback EMA, with an EMA signal line; %D is a smoothing average of %K
Calculation: Fisher Transform = 0.5 × ln(x / (1 − x)), where x is the normalized close within its lookback range, clamped to (0, 1); use 0.5 when the range is zero
Long: score ≥ long-entry threshold AND RSI < long RSI limit AND position is flat or short
Short: score ≤ short-entry threshold AND RSI > short RSI limit AND position is flat or long
Exit: long, score ≤ long-exit threshold OR PSAR > close
Exit: short, score ≥ short-exit threshold OR PSAR < close