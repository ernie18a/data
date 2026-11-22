# Morning VIX Bias PRO v2 (5m tuned)

- url: https://www.tradingview.com/script/ekm6oWFX-Morning-VIX-Bias-PRO-v2-5m-tuned/
- type: indicator
- pine_id: PUB;5458d760fbb649d7aa6bac590ad4b6bc
- version: 1.0

## Description

I use this to help me identify tops and bottoms using volatility. try charting this on VIXY, UVXY, VXZ, SVXy and others. It's an interesting concept using vix to help detect when volatility is turning. 
[b]
What It's Measuring[/b]
This indicator builds a composite volatility bias score by combining three normalized signals:
1. VIX Momentum (vixMom × 1.4)
Measures whether implied volatility is rising or falling, normalized against its 30-bar history. Rising VIX = bearish pressure on equities.
2. VX1 Futures Confirmation (vxMom × 1.2)
VX1 is the front-month VIX futures contract. When it confirms VIX spot movement, the signal has more conviction. Divergence between VIX and VX1 often signals noise rather than a real vol regime shift.
3. SPX Realized Volatility Expansion (rvNorm × 1.8)
The highest-weighted component. Tracks whether actual SPX price movement is accelerating. This grounds the signal in real price action, not just fear gauges.
The three are summed into a score, then smoothed with a 5-period EMA to reduce noise.

[b]The Normalization Engine[/b]
Every component uses (value - mean) / stdev over 30 bars — a Z-score. This means:

The indicator is self-adjusting to current vol regimes
A reading of +1.5 means the same thing whether VIX is at 15 or 45
Prevents high-vol environments from permanently dominating the signal

[b]The EXIT VOL Triangle (Orange ▼)[/b]
This fires when all three conditions align simultaneously:
ConditionWhat It MeansvixStretchVIX is >1.6 Z-scores above its 50-bar mean — stretched, exhaustedmomFadeVIX 2-bar change < 6-bar change — momentum deceleratingspxFadeSPX realized vol acceleration is below its own 10-bar average
This is essentially a vol exhaustion signal — the fear spike is losing energy.

[b]Best Uses[/b]
Strongest applications:

SVXY / UVXY entry timing — The EXIT VOL triangle on a red→green transition is a natural SVXY re-entry signal after a vol spike
0DTE / short-dated options — Morning session on 5m bars tells you whether to sell premium or expect continued expansion
SPX directional bias filter — Use as a regime filter: only take long SPX setups when bias is green
Hedging decisions — Red columns = keep hedges on; green = reduce hedge cost

## Source Code

````pine
//@version=6
indicator("Morning VIX Bias PRO v2 (5m tuned)", overlay=false)

// SYMBOLS (use CBOE versions for reliability)
vixSymbol = input.symbol("CBOE:VIX", "VIX")
vx1Symbol = input.symbol("CBOE:VX1!", "VX1")
spxSymbol = input.symbol("SP:SPX", "SPX")

// DATA
vix = request.security(vixSymbol, timeframe.period, close)
vx1 = request.security(vx1Symbol, timeframe.period, close)
spx = request.security(spxSymbol, timeframe.period, close)

// === NORMALIZATION FUNCTION ===
normalize(src, len)=>
    mean = ta.sma(src,len)
    dev = ta.stdev(src,len)
    dev == 0 ? 0 : (src-mean)/dev

// === COMPONENTS ===

// VIX momentum normalized
vixMom = normalize(ta.change(vix), 30)

// VX1 confirmation normalized
vxMom  = normalize(ta.change(vx1), 30)

// SPX realized volatility expansion
spxMove = math.abs(ta.change(spx))
rvNorm = normalize(spxMove, 30)

// COMBINED BIAS SCORE
score = vixMom*1.4 + vxMom*1.2 + rvNorm*1.8
bias = ta.ema(score,5)

// ===== VIX PEAK DETECTOR =====

// 1) VIX stretched above normal intraday range
vixStretch = normalize(vix,50) > 1.6

// 2) Momentum fading after rise
momFade = ta.change(vix,2) < ta.change(vix,6)

// 3) SPX downside losing acceleration
spxAccel = ta.change(spxMove)
spxFade = spxAccel < ta.sma(spxAccel,10)

// COMBINED EXIT SIGNAL
exitVol = vixStretch and momFade and spxFade

// ===== PLOTS =====
col =
 bias > 0 ? color.rgb(0,180,0) :
 bias < 0 ? color.rgb(200,0,0) :
 color.gray

plot(bias, style=plot.style_columns, color=col, linewidth=2)
hline(0,color=color.gray)

// EXIT TRIANGLE
plotshape(exitVol,
 title="EXIT VOL",
 location=location.top,
 style=shape.triangledown,
 color=color.orange,
 size=size.small)
````
