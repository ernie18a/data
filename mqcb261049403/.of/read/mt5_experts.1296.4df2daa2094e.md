Calculation: Non-lag average N(L) = Apply a configurable moving-average method and applied price over length L. Let P=L-1, K=4L+P, t=0, and for i=0 through K-1 set g=1 when t<=0.5, otherwise g=1/(3πt+1); set w[i]=g*cos(πt). After each weight, increase t by 1/(P-1) if t<1, otherwise by 7/(4L-1) if t<K-1. N=(1+deviation/100)*sum(w[i]*moving_average[i bars ago])/sum(w[i]). Use the unfiltered calculation; the optional filter references the next bar.
Calculation: Oscillator M = N(shorter length) minus N(longer length); signal S = configurable moving average of M. For the trading decisions, calculate M and S on a configurable higher or lower timeframe, using either its last completed bar or its forming bar according to the signal-bar setting; indices 0, 1 and 2 denote the selected bar and its two predecessors. For the indicator markings, use the chart timeframe.
Calculation: Non-lag trend T = +1 when N[0]-N[1] exceeds the configurable filter distance, -1 when N[1]-N[0] exceeds that distance, otherwise retain the preceding trend; initialize to 0. Filter distance is a configurable price distance.
Long: T=+1
Short: T=-1
Long: M[0]!=0 AND M[0]>M[1]
Short: M[0]!=0 AND M[0]<M[1]
Long: M[0]>S[1]
Short: M[0]<S[1]
Long: M[0]>0 AND M[1]<=0
Short: M[0]<0 AND M[1]>=0
Long: M[0]>M[1] AND M[1]<M[2]
Short: M[0]<M[1] AND M[1]>M[2]
Long: S[0]>S[1] AND S[1]<S[2]
Short: S[0]<S[1] AND S[1]>S[2]
Long: M[0]>S[0] AND M[1]<=S[1]
Short: M[0]<S[0] AND M[1]>=S[1]
Exit: long, M[0]<0 OR M[0]<M[1] OR S[0]<S[1] OR M[0]<S[0], according to the selected trading mode
Exit: short, M[0]>0 OR M[0]>M[1] OR S[0]>S[1] OR M[0]>S[0], according to the selected trading mode
Exit: long, low<=entry price minus the configured stop-loss distance OR high>=entry price plus the configured take-profit distance
Exit: short, high>=entry price plus the configured stop-loss distance OR low<=entry price minus the configured take-profit distance