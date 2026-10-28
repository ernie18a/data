Calculation: For each of 4-hour, daily, weekly, monthly, quarterly, and half-yearly bars, strong demand zone upper boundary = rounded current period open − σ + rounded(σ/4)/2; weak demand zone upper boundary = rounded current period open − σ/(2√2) + rounded(σ/(4×1.618034))/2; weak supply zone lower boundary = rounded current period open + σ/(2√2) − rounded(σ/(4×1.618034))/2; strong supply zone lower boundary = rounded current period open + σ − rounded(σ/4)/2. σ is rounded current period open × ATR slope × ATR percentage annualized from the last completed bar ÷ annualization factor; ATR percentage uses last completed ATR divided by last completed close for daily/weekly and by current period open for the other periods. Annualization factors: √252 (daily), √52 (weekly), √12 (monthly), √4 (quarterly), √2 (half-yearly), √504 (4-hour). Use the current period's open, including while that period is forming.
Calculation: Weekly point of control = current weekly open + 8.
Calculation: Volume z-score = (current volume − 50-bar average volume) ÷ 50-bar volume standard deviation.
Calculation: Bullish FVG = current low − high two bars ago; bearish FVG = low two bars ago − current high; compare each gap with 14-bar ATR × sensitivity.
Long: Current low ≤ strong or weak demand zone upper boundary AND previous bar low > the corresponding previous-bar boundary, on any of the six timeframes.
Long: Volume z-score ≥ threshold AND close > open.
Long: Close crosses above the most recently confirmed pivot high (pivot requires the configured number of bars on each side).
Long: Current low > high two bars ago AND current low − high two bars ago > 14-bar ATR × sensitivity.
Long: Two confirmed pivot lows are within the configured equality threshold percentage.
Long: Close > weekly point of control.
Short: Current high ≥ strong or weak supply zone lower boundary AND previous bar high < the corresponding previous-bar boundary, on any of the six timeframes.
Short: Volume z-score ≥ threshold AND close ≤ open.
Short: Close crosses below the most recently confirmed pivot low (pivot requires the configured number of bars on each side).
Short: Current high < low two bars ago AND low two bars ago − current high > 14-bar ATR × sensitivity.
Short: Two confirmed pivot highs are within the configured equality threshold percentage.
Short: Close < weekly point of control.