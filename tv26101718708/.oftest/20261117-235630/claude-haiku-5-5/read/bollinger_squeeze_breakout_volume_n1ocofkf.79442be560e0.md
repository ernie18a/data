Calculation: Squeeze = BBW(close, bbLen, bbMult) < SMA(BBW(close, bbLen, bbMult), squeezeLen) * squeezePct
Long: Squeeze[1] AND close crosses above BollingerUpper(close, bbLen, bbMult) AND volume > SMA(volume, volLen) AND position side is flat
Short: Squeeze[1] AND close crosses below BollingerLower(close, bbLen, bbMult) AND volume > SMA(volume, volLen) AND position side is flat
Exit: long, low <= entry price - ATR(high, low, close, atrLen) at entry bar * slMult OR high >= entry price + ATR(high, low, close, atrLen) at entry bar * tpMult
Exit: short, high >= entry price + ATR(high, low, close, atrLen) at entry bar * slMult OR low <= entry price - ATR(high, low, close, atrLen) at entry bar * tpMult