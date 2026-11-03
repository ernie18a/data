Calculation: Higher-timeframe Parabolic SAR = Parabolic SAR on a higher-timeframe bar still forming
Calculation: Lower-timeframe Parabolic SAR = Parabolic SAR on a lower-timeframe bar still forming
Calculation: Stop-loss price = average entry price adjusted against the position by a configurable percentage
Calculation: Take-profit price = average entry price adjusted in favor of the position by a configurable percentage
Long: close > higher-timeframe Parabolic SAR OR close > current-timeframe Parabolic SAR OR (close > higher-timeframe Parabolic SAR AND close > current-timeframe Parabolic SAR); optionally require close > lower-timeframe Parabolic SAR
Short: close < higher-timeframe Parabolic SAR OR close < current-timeframe Parabolic SAR OR (close < higher-timeframe Parabolic SAR AND close < current-timeframe Parabolic SAR); optionally require close < lower-timeframe Parabolic SAR
Exit: long, close <= stop-loss price OR close >= take-profit price OR short-entry condition
Exit: short, close >= stop-loss price OR close <= take-profit price OR long-entry condition