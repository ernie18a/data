Calculation: Spot reference = Coinbase Bitcoin spot close when spot anchors are enabled and available, otherwise Kraken Bitcoin spot close when spot anchors are enabled and available, otherwise Binance Bitcoin spot close
Calculation: Safe spot reference = P1 when the spot reference is missing or zero, otherwise the spot reference
Calculation: CME futures premium = CME Bitcoin futures close − spot reference when CME data is enabled and available
Calculation: Binance perpetual premium = Binance Bitcoin perpetual close − spot reference
Calculation: Institutional divergence = CME futures premium − Binance perpetual premium when CME data is enabled and both premiums are available
Calculation: Annualized CME basis = ((CME Bitcoin futures close − safe spot reference) / safe spot reference) × P2 / P3 × P4 / CME days to expiry when CME data is enabled and available
Calculation: Normalized funding rate = Binance perpetual funding rate in raw funding mode, otherwise Binance perpetual funding rate / P5
Calculation: Open-interest change = change in Binance Bitcoin perpetual open interest
Calculation: Perpetual price change = change in Binance Bitcoin perpetual close
Calculation: Weak ATR threshold = ATR(chart timeframe, P6) × P7
Calculation: Strong ATR threshold = ATR(chart timeframe, P6) × P8
Calculation: CME premium score = 0 when the premium is unavailable; otherwise P9 if the premium > strong ATR threshold, P10 if > weak ATR threshold, P11 if < −strong ATR threshold, P12 if < −weak ATR threshold, otherwise 0
Calculation: Institutional divergence score = 0 when the divergence is unavailable; otherwise P13 if the divergence > strong ATR threshold, −P13 if < −strong ATR threshold, otherwise 0
Calculation: Open-interest/price score = 0 when either change is unavailable or either equals zero; otherwise P14 when open-interest change > 0 or < 0 and perpetual price change > 0, −P15 when open-interest change > 0 or < 0 and perpetual price change < 0, otherwise 0
Calculation: Funding score = 0 when the normalized funding rate is unavailable; otherwise −P16 if the rate > P17, −P18 if > P19, P20 if < P21, P22 if < P23, otherwise 0
Calculation: Basis score = 0 when the annualized CME basis is unavailable; otherwise −P24 if the basis > P25, −P26 if > P27, P28 if < 0, otherwise 0
Calculation: Total score = CME premium score + institutional divergence score + open-interest/price score + funding score + basis score
Long: CME futures premium > weak ATR threshold OR CME futures premium > strong ATR threshold
Short: CME futures premium < −weak ATR threshold OR CME futures premium < −strong ATR threshold
Long: Binance perpetual premium > weak ATR threshold OR Binance perpetual premium > strong ATR threshold
Short: Binance perpetual premium < −weak ATR threshold OR Binance perpetual premium < −strong ATR threshold
Long: Institutional divergence > weak ATR threshold OR Institutional divergence > strong ATR threshold
Short: Institutional divergence < −weak ATR threshold OR Institutional divergence < −strong ATR threshold
Long: Open-interest change > 0 AND perpetual price change > 0 OR open-interest change < 0 AND perpetual price change > 0
Short: Open-interest change > 0 AND perpetual price change < 0 OR open-interest change < 0 AND perpetual price change < 0
Long: Normalized funding rate < P23 OR Normalized funding rate < P21
Short: Normalized funding rate > P19 OR Normalized funding rate > P17
Long: Annualized CME basis < 0
Short: Annualized CME basis > P27 OR Annualized CME basis > P25
Long: Total score > 0
Short: Total score < 0