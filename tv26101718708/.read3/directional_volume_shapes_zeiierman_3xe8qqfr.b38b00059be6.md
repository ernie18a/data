Calculation: Triangular candle score(o,h,l,c) = with r=h-l, o'=min(max(o,l),h), c'=min(max(c,l),h): if r=0, c>o ? 0 : c<o ? 1 : 0.5; else if c'=l, o'<=l ? 1 : ((h-o')/r)^2; else if c'=h, o'>=h ? 0 : 1-((o'-l)/r)^2; else if o'<=l, 1; else if o'<=c', 1-(o'-l)^2/(r*(c'-l)); else if o'<h, (h-o')^2/(r*(h-c')); else 0
Calculation: Directional pressure(open,high,low,close) = 2*Triangular candle score(open,high,low,close)-1
Long: EMA(Directional pressure, polarity smoothing) >= 0
Short: EMA(Directional pressure, polarity smoothing) < 0