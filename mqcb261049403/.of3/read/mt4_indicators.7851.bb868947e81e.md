Long: DeMarker(period) < lower DeMarker threshold
Short: DeMarker(period) > upper DeMarker threshold
Long: CCI(median price, period) < lower CCI threshold
Short: CCI(median price, period) > upper CCI threshold
Long: MFI(period) < lower MFI threshold
Short: MFI(period) > upper MFI threshold
Long: Williams %R(period) < lower Williams %R threshold
Short: Williams %R(period) > upper Williams %R threshold
Long: Stochastic %K(K-period, slowing; SMA, Low/High) > Stochastic %D(D-period; SMA, Low/High)
Short: Stochastic %K(K-period, slowing; SMA, Low/High) < Stochastic %D(D-period; SMA, Low/High)
Long: Momentum(close, period) crosses above threshold
Short: Momentum(close, period) crosses below threshold
Long: AC[n] > AC[n+1] and AC[n] < 0 for every n from 0 to trend window−1
Short: AC[n] < AC[n+1] and AC[n] > 0 for every n from 0 to trend window−1
Long: AC[n] >= AC[n+1] for every n from 0 to trend window−1 AND (AC[0] >= 0 OR AC[n] > AC[n+1] for at least one n from 0 to position window−1)
Short: AC[n] <= AC[n+1] for every n from 0 to position window−1 AND (AC[0] < 0 OR AC[n] < AC[n+1] for at least one n from 0 to trend window−1)