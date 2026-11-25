Calculation: AO(T) = FX-AO output 0 on T's still-forming bar, sampled on chart bars
Calculation: AOprev(T) = FX-AO output 0 on T's immediately preceding completed bar, sampled on chart bars
Calculation: BAR(T) = FX-BAR output 0 on T's still-forming bar, sampled on chart bars
Calculation: BARprev(T) = FX-BAR output 0 on T's immediately preceding completed bar, sampled on chart bars
Calculation: Z(T) = zzf output 0 on T's still-forming bar, sampled on chart bars
Calculation: I(condition) = 1 if condition is true, otherwise 0
Calculation: FastTF(k) = [T1,T2,T3,T1,T2,T3,T1][k]; OtherTF(k) = [T1,T1,T1,T2,T2,T3,T3][k], for k=1..7 configured chart slots
Calculation: AOGroupUp(x,y) = 3×I(x>y) + 2×I(x≥y)
Calculation: AOGroupTotal(x,y) = 3×I(x≠y) + 2
Calculation: BARGroupUp(x,y) = 2×I(x<y) + 3×I(x>y) + 2×I(x≥y)
Calculation: BARGroupTotal(x,y) = 5×I(x≠y) + 2
Calculation: AOUpVotes = Σ(k=1..7)[I(AO(FastTF(k))<AOprev(FastTF(k))) + I(AO(OtherTF(k))<AOprev(OtherTF(k))) + AOGroupUp(AO(OtherTF(k)),AOprev(OtherTF(k)))]
Calculation: BARUpVotes = Σ(k=1..6)BARGroupUp(BAR(OtherTF(k)),BARprev(OtherTF(k))) + 2×I(BAR(T3)<BARprev(T3)) + 2×I(BAR(T3)>BARprev(T3)) + 2×I(BAR(T3)≥BARprev(T3)) + I(close of current chart bar>Z(T2))
Calculation: UpVotes = AOUpVotes + BARUpVotes
Calculation: TotalVotes = Σ(k=1..7)[I(AO(FastTF(k))≠AOprev(FastTF(k))) + I(AO(OtherTF(k))≠AOprev(OtherTF(k))) + AOGroupTotal(AO(OtherTF(k)),AOprev(OtherTF(k)))] + Σ(k=1..6)BARGroupTotal(BAR(OtherTF(k)),BARprev(OtherTF(k))) + 4×I(BAR(T3)≠BARprev(T3)) + 2 + I(close of current chart bar≠Z(T2))
Calculation: UpPercent = round(100×UpVotes/TotalVotes)
Long: UpPercent≥50
Short: UpPercent<50