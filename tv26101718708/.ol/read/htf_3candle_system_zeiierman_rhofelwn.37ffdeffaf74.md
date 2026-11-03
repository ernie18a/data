Calculation: C1, C2, C3 = OHLC of three consecutive higher-timeframe bars: C1 is the second-last completed bar, C2 the last completed bar, and C3 the bar still forming.
Calculation: Rᵢ = Hᵢ − Lᵢ; Bᵢ = |Cᵢ − Oᵢ|; BRᵢ = Bᵢ/Rᵢ; CPᵢ = (Cᵢ − Lᵢ)/Rᵢ; M₁ = (O₁ + C₁)/2.
Calculation: A = higher-timeframe ATR, including the bar still forming; Q(x) = max(0, min(1, x)); N(x, y) = 1 − min(|x − y|/y, 1).
Calculation: Small₂ = Q((0.50 − BR₂)/0.35).
Calculation: Bullish sweep score = 10·[C₁<O₁] + 25·[L₂<L₁] + 10·[L₂≥L₁]·N(L₂,L₁ distance scaled by 0.5A) + 20·[C₂>L₁] + 10·[C₂≤L₁]·N(C₂,L₁ distance scaled by 0.5A) + 10·[C₂>O₂] + 10·[C₃>O₃] + 20·( [C₃>H₂] + [C₃≤H₂]·N(C₃,H₂ distance scaled by A) ) + 5·BR₁. Here [condition] is 1 when true, otherwise 0; N(x, level distance scaled by s) means 1 − min(|x−level|/max(s, minimum price increment), 1).
Calculation: Bearish sweep score = 10·[C₁>O₁] + 25·[H₂>H₁] + 10·[H₂≤H₁]·N(H₂,H₁ distance scaled by 0.5A) + 20·[C₂<H₁] + 10·[C₂≥H₁]·N(C₂,H₁ distance scaled by 0.5A) + 10·[C₂<O₂] + 10·[C₃<O₃] + 20·( [C₃<L₂] + [C₃≥L₂]·N(C₃,L₂ distance scaled by A) ) + 5·BR₁. Use the same distance definition as the bullish sweep score.
Calculation: Bullish FVG displacement score = 15·[C₂>O₂] + 20·Q(BR₂/0.65) + 15·Q(R₂/A) + 25·( [L₃>H₁] + 0.5·[L₃≤H₁]·N(L₃,H₁ distance scaled by 0.5A) ) + 10·[C₃>O₃] + 15·( [C₃>C₂] + [C₃≤C₂]·N(C₃,C₂ distance scaled by A) ).
Calculation: Bearish FVG displacement score = 15·[C₂<O₂] + 20·Q(BR₂/0.65) + 15·Q(R₂/A) + 25·( [H₃<L₁] + 0.5·[H₃≥L₁]·N(H₃,L₁ distance scaled by 0.5A) ) + 10·[C₃<O₃] + 15·( [C₃<C₂] + [C₃≥C₂]·N(C₃,C₂ distance scaled by A) ).
Calculation: Bullish PO3 score = 20·Q((1.25−R₁/A)/0.75) + 25·[L₂<L₁] + 15·[C₂>L₁] + 25·( [C₃>H₁] + [C₃≤H₁]·N(C₃,H₁ distance scaled by A) ) + 15·[C₃>O₃].
Calculation: Bearish PO3 score = 20·Q((1.25−R₁/A)/0.75) + 25·[H₂>H₁] + 15·[C₂<H₁] + 25·( [C₃<L₁] + [C₃≥L₁]·N(C₃,L₁ distance scaled by A) ) + 15·[C₃<O₃].
Calculation: Bullish expansion score = 15·[C₁>O₁] + 15·[C₂>O₂] + 15·[C₃>O₃] + 10·[C₂>C₁] + 10·[C₃>C₂] + 15·[B₂≥B₁] + 10·[B₃≥B₂] + 10·[H₃>H₂].
Calculation: Bearish expansion score = 15·[C₁<O₁] + 15·[C₂<O₂] + 15·[C₃<O₃] + 10·[C₂<C₁] + 10·[C₃<C₂] + 15·[B₂≥B₁] + 10·[B₃≥B₂] + 10·[L₃<L₂].
Calculation: Inside = H₂<H₁ AND L₂>L₁.
Calculation: Bullish compression score = 35·[Inside] + 15·[C₃>O₃] + 30·( [C₃>H₁] + [C₃≤H₁]·N(C₃,H₁ distance scaled by A) ) + 10·Q(BR₃/0.60) + 10·Q((CP₃−0.50)/0.30).
Calculation: Bearish compression score = 35·[Inside] + 15·[C₃<O₃] + 30·( [C₃<L₁] + [C₃≥L₁]·N(C₃,L₁ distance scaled by A) ) + 10·Q(BR₃/0.60) + 10·Q((0.50−CP₃)/0.30).
Calculation: Morning star score = 20·[C₁<O₁] + 15·Q(BR₁/0.60) + 20·Small₂ + 20·[C₃>O₃] + 20·( [C₃>M₁] + [C₃≤M₁]·N(C₃,M₁ distance scaled by A) ) + 5·[C₃>O₁].
Calculation: Evening star score = 20·[C₁>O₁] + 15·Q(BR₁/0.60) + 20·Small₂ + 20·[C₃<O₃] + 20·( [C₃<M₁] + [C₃≥M₁]·N(C₃,M₁ distance scaled by A) ) + 5·[C₃<O₁].
Long: The highest score among bullish sweep, bullish FVG displacement, bullish PO3, bullish expansion, bullish compression, and morning star is greater than the highest score among bearish sweep, bearish FVG displacement, bearish PO3, bearish expansion, bearish compression, and evening star.
Short: The highest score among bearish sweep, bearish FVG displacement, bearish PO3, bearish expansion, bearish compression, and evening star is greater than the highest score among bullish sweep, bullish FVG displacement, bullish PO3, bullish expansion, bullish compression, and morning star.