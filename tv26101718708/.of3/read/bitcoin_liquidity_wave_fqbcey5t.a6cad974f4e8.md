Calculation: Log global liquidity = log10((Federal Reserve total assets − U.S. Treasury account balance − U.S. reverse repo balance + included ECB assets × EUR/USD + included BoJ assets ÷ USD/JPY + included PBoC assets ÷ USD/CNY + included BoE assets × GBP/USD) ÷ P14)
Calculation: Lagged smoothed liquidity impulse = simple moving average over the number of chart bars in P9 days of (log global liquidity − log global liquidity lagged by the number of chart bars in P8 days), lagged by the number of chart bars in P7 days
Calculation: Log liquidity wave = P1 + P2 × log global liquidity lagged by the number of chart bars in P6 days + P3 × log10(elapsed days since P15) + P4 × log10(elapsed days since P15)^2 + P5 × lagged smoothed liquidity impulse
Long: outer-level touch highlight enabled AND low <= 10^(log liquidity wave − P12 × (elapsed days since P15 ÷ P18)^P13) × P16
Short: outer-level touch highlight enabled AND high >= 10^(log liquidity wave + P10 × (elapsed days since P15 ÷ P18)^P11) × P17
Long: impulse reversal marks enabled AND lagged smoothed liquidity impulse crosses above zero
Short: impulse reversal marks enabled AND lagged smoothed liquidity impulse crosses below zero