Calculation: v(T1 through T10) = JCFBaux(source, depth) on each timeframe's bars, using its still-forming bar in real time and its last completed bar historically
Calculation: f(T1 through T10) = Jurik filter(JCFBaux(source, depth), signal period, phase) on each timeframe's bars, using its still-forming bar in real time and its last completed bar historically
Long: on chart bars, for any T1 through T10, v(Tn) crosses above f(Tn) using values returned from Tn
Long: for any enabled T1 through T10, v(Tn) >= f(Tn) using values returned from Tn
Short: for any enabled T1 through T10, v(Tn) < f(Tn) using values returned from Tn
Long: among enabled T1 through T10, more have v(Tn) >= f(Tn) than have v(Tn) < f(Tn)
Short: among enabled T1 through T10, more have v(Tn) < f(Tn) than have v(Tn) >= f(Tn)
Long: at least N enabled T1 through T10 have v(Tn) >= f(Tn)
Short: at least N enabled T1 through T10 have v(Tn) < f(Tn)