Calculation: Estimated bar delta = volume × clamp(2 × (close − low) / (high − low) − 1, −1, 1); use zero when high = low.
Calculation: Session volume and session delta = cumulative volume and estimated bar delta, respectively, over bars in the current analysis session; reset both to zero at the first session bar and retain their values outside the session. The analysis session is defined by bar opening time in the exchange timezone.
Calculation: Session buy volume and session sell volume = cumulative max(0, (volume + estimated bar delta) / 2) and max(0, (volume − estimated bar delta) / 2), respectively, over the current analysis session; reset at the first session bar and retain outside the session.
Calculation: Imbalance = session buy volume / session sell volume if session sell volume > 0; otherwise 99 if session buy volume > 0, else 1.
Calculation: Momentum score = clamp(100 × (shorter-period close EMA − longer-period close EMA) / adjusted ATR, −100, 100), where adjusted ATR is the maximum of ATR and the minimum price increment.
Calculation: Large-volume score = clamp(15 × (count of large positive-delta bars − count of large negative-delta bars), −100, 100), with counts over a rolling lookback including the current bar. A bar is large when volume / max(1, volume SMA) is at least a positive multiple; use current volume in place of the SMA when the SMA is unavailable. Rolling calculations include bars outside the session.
Calculation: Flow score = clamp(0.35 × delta score + 0.25 × momentum score + 0.25 × VWAP score + 0.15 × large-volume score, −100, 100). Delta score is clamp(100 × session delta / session volume, −100, 100), or zero when session volume is zero. VWAP score is clamp(65 × (close − session VWAP) / adjusted ATR, −100, 100), or zero when session VWAP is unavailable. Session VWAP uses typical price weighted by volume over the current session and retains its last value outside the session.
Long: Bar is in the analysis session AND flow score >= positive threshold.
Short: Bar is in the analysis session AND flow score <= negative threshold, equal in magnitude to the positive threshold.
Long: Session delta >= 0.
Short: Session delta < 0.
Long: Imbalance >= 1.
Short: Imbalance < 1.
Long: Momentum score >= 0.
Short: Momentum score < 0.