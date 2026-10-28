Calculation: Flow score = clamp(0.35 × session delta score + 0.25 × momentum score + 0.25 × session VWAP score + 0.15 × large-volume score, −100, 100)
Calculation: Session delta score = clamp(100 × cumulative estimated bar delta / cumulative volume for the current analysis session, −100, 100)
Calculation: Estimated bar delta = volume × clamp(2 × (close − low) / (high − low) − 1, −1, 1); use 0 when high = low
Calculation: Momentum score = clamp(100 × (shorter-lookback close EMA − longer-lookback close EMA) / ATR, −100, 100)
Calculation: Session VWAP score = clamp(65 × (close − current analysis-session VWAP) / ATR, −100, 100)
Calculation: Large-volume score = clamp(15 × (rolling count of large positive-delta bars − rolling count of large negative-delta bars), −100, 100)
Calculation: A large positive- or negative-delta bar has volume / longer-lookback average volume ≥ the large-volume threshold and estimated bar delta > 0 or < 0, respectively.
Long: In the analysis session AND flow score ≥ the strong-flow threshold
Short: In the analysis session AND flow score ≤ −the strong-flow threshold