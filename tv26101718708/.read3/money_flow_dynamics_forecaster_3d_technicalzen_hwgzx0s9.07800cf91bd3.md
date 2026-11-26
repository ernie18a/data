Calculation: MomentumOsc = clamp(momentum scale * (HMA(MFI(high, low, close, volume, MFI lookback), MFI middle-layer HMA lookback) - 50), -100, 100)
Calculation: SignedADX = ADX(ADX lookback) * (1 if +DI(ADX lookback) >= -DI(ADX lookback), otherwise -1)
Calculation: PriceCurrent = if oscillator type is VWMA-based: clamp(price scale * ROC(HMA(VWMA(close, volume, VWMA lookback), price middle-layer HMA lookback), price change lag), -100, 100); otherwise HMA(SignedADX, ADX middle-layer HMA lookback)
Long: MomentumOsc > MomentumOsc[n] AND PriceCurrent > PriceCurrent[n]
Short: MomentumOsc < MomentumOsc[n] AND PriceCurrent < PriceCurrent[n]
Exit: long, (MomentumOsc <= MomentumOsc[n] OR PriceCurrent <= PriceCurrent[n]) AND (MomentumOsc >= MomentumOsc[n] OR PriceCurrent >= PriceCurrent[n])
Exit: short, (MomentumOsc <= MomentumOsc[n] OR PriceCurrent <= PriceCurrent[n]) AND (MomentumOsc >= MomentumOsc[n] OR PriceCurrent >= PriceCurrent[n])