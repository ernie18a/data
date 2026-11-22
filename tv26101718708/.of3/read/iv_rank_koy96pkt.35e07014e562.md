Calculation: IV Rank = 100 × (V − Lowest(V, rank lookback)) / (Highest(V, rank lookback) − Lowest(V, rank lookback)), or neutral rank when the highest equals the lowest; V is the selected custom IV close or annualized historical volatility, 100 × sqrt(252) × StDev(log(close / close[1]), HV lookback).
Long: IV Rank < low-rank threshold
Short: IV Rank > high-rank threshold OR (crush signal enabled AND IV Rank − IV Rank[crush lookback] < −crush threshold AND IV Rank[crush lookback] > neutral rank)
Option: buy call, IV Rank < P1
Option: buy put, IV Rank < P1
Option: sell call, IV Rank > P2
Option: sell put, IV Rank > P2