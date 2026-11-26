Calculation: Net gravity = 100 × (upper ranked pull − lower ranked pull) / (upper ranked pull + lower ranked pull), or 0 when total ranked pull is 0
Calculation: Each side's ranked pull = sum of up to three eligible pool gravity scores multiplied by separate primary, secondary, and tertiary rank weights
Calculation: Pool gravity score = clamp(0, 100, liquidity strength × distance factor × freshness factor × trend modifier × regime modifier)
Long: Net gravity ≥ 0 and an upper primary magnet exists
Short: Net gravity < 0 and a lower primary magnet exists
Long: On a confirmed chart bar, net gravity crosses above 0
Short: On a confirmed chart bar, net gravity crosses below 0
Long: On a confirmed chart bar, net gravity crosses above the strong-gravity threshold
Short: On a confirmed chart bar, net gravity crosses below the negative strong-gravity threshold
Long: On a confirmed chart bar, upper primary magnet gravity crosses above the high-primary-gravity threshold
Short: On a confirmed chart bar, lower primary magnet gravity crosses above the high-primary-gravity threshold
Long: On a confirmed chart bar, the upper primary magnet enters the approaching state
Short: On a confirmed chart bar, the lower primary magnet enters the approaching state
Long: On a confirmed chart bar, an upper pool in the forming, active, or approaching state is swept when high ≥ its zone high + ATR(lookback) × sweep-buffer parameter
Short: On a confirmed chart bar, a lower pool in the forming, active, or approaching state is swept when low ≤ its zone low − ATR(lookback) × sweep-buffer parameter
Short: On a confirmed chart bar, an upper pool sweep is rejected when close < its zone low within the rejection window after the sweep
Long: On a confirmed chart bar, a lower pool sweep is rejected when close > its zone high within the rejection window after the sweep
Long: On a confirmed chart bar, an upper pool sweep is accepted when the required consecutive closes are above its zone high
Short: On a confirmed chart bar, a lower pool sweep is accepted when the required consecutive closes are below its zone low
Long: Net gravity > 15
Short: Net gravity < −15