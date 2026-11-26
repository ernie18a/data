# VWRSI Crossovers & Extremes [The AI Trading Desk]

- url: https://www.tradingview.com/script/DLxyp3Vv-VWRSI-Crossovers-Extremes-The-AI-Trading-Desk/
- type: indicator
- pine_id: PUB;16932ce1f69b476ca0ef1dd7e606e708
- version: 1.0

## Description

VWRSI Crossovers & Extremes
 
By integrating real volume into the RSI calculation, this engine surfaces only the moves that have money behind them. The hype-driven wiggles get filtered. The conviction moves stand out.
 
And then it tells you exactly what to do.
 
Two clear ways to act — no guesswork:
 
🔥 Extreme Release Signals — the RSI mistake most traders make
 
Most traders are taught RSI wrong. They sell the second it crosses 70 and buy the second it crosses 30 — and then they watch the market keep ripping in the same direction without them, or worse, against them. Here's the truth: RSI can stay in extreme zones far longer than you expect. Selling overbought into a strong trend is how accounts bleed.
 
This indicator doesn't fire when RSI enters an extreme zone. It fires when VWRSI comes back out of one. An orange flash and a labeled Up or Dn triangle mark the exact bar where momentum returns to normal range — meaning the extreme is resolving, not building. You're not fighting the trend. You're acting once the move has cooled and momentum has rotated back to your side.
 
How to use it:
 

Wait for the orange flash + triangle — don't act when VWRSI hits 70 or 30, act when it leaves
Down triangle (Dn) at the top — overbought is resolving, momentum cooling, look for short setups or trim longs
Up triangle (Up) at the bottom — oversold is resolving, momentum reviving, look for long setups or cover shorts
Best paired with structure — confluence with key levels, prior swing points, or trendlines tightens the edge

 
🌊 Crossover Confirmation — the answer to chop and fake-outs
 
Raw VWRSI crosses happen all day. Most are noise. The trick is waiting for the VWRSI to cross its signal moving average — that's the moment when short-term momentum has shifted decisively against the smoothed average, not just twitched.
 
The fill color flips with the cross — green for bullish momentum, red for bearish. By waiting for this confirmed cross instead of acting on every wiggle, you skip the chop, dodge the fake-outs, and only enter when the regime has actually changed. It's slower, on purpose. That's the point.
 
How to use it:
 

Watch the cloud color — green means VWRSI is above its MA (bullish bias); red means below (bearish bias)
Enter on the flip — when the color changes, momentum has rotated. Trend traders take entries with the new direction.
Stay in until it flips back — exits trigger when the cloud color reverses, signaling the regime has changed again
Skip the in-between — when VWRSI is hugging the MA closely (thin cloud), the market is undecided. Wait for separation.

 
Why this hits different:
 

Volume integrated into momentum calculation — high-volume bars influence momentum more than low-volume drift. Real moves stand out.
Both tops AND bottoms flagged — most VWRSI tools only catch one side. This catches both, with equal clarity.
No mystery readings — every signal has a name and a job. If you can't explain what your indicator is telling you, you can't trust it.
Calm when the market is calm — no constant red clouds during chop. The line stays quiet so you don't overtrade.

 
Built for traders who are tired of:
 

Selling tops too early and watching the trend keep running
Buying every dip into oversold and getting steamrolled
Indicators that fire constantly but rarely matter
Beautiful clouds that look great in screenshots but trick you into bad entries

 
Two trade types. Three visual cues. Zero guesswork.
 
Defaults: VWRSI 14, MA 9, OB 70, OS 30 — fully customizable.
 
Built by The AI Trading Desk.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  The AI Trading Desk | VWRSI Crossover & Extremes
//
//  This is a foundational momentum engine utilizing Volume-Weighted RSI (VWRSI).
//  It plots the VWRSI and its EMA to visualize momentum shifts.
//  Includes OB/OS release signals for potential trend exhaustion/reversals.
// ════════════════════════════════════════════════════════════════════════════
indicator(title="VWRSI Crossovers & Extremes [The AI Trading Desk]", shorttitle="VWRSI", format=format.price, precision=2, overlay=false)

// ============================================================================
// I. INPUTS
// ============================================================================
grp_core = "Engine Settings"
rsiLen   = input.int(14, "VWRSI Length", minval=1, group=grp_core)
maLen    = input.int(9,  "MA Length", minval=1, group=grp_core)

grp_levels = "OB/OS Thresholds"
i_obLevel  = input.int(70, "Overbought Level", minval=60, maxval=90, group=grp_levels)
i_osLevel  = input.int(30, "Oversold Level", minval=10, maxval=40, group=grp_levels)

// ============================================================================
// II. CORE CALCULATIONS
// ============================================================================

// Volume-Weighted Relative Moving Average
vwrma(src, len) => 
    ta.rma(src * volume, len) / ta.rma(volume, len)

// VWRSI Calculation
vwUp   = vwrma(math.max(ta.change(close), 0.0), rsiLen)
vwDown = vwrma(math.max(-ta.change(close), 0.0), rsiLen)
rsi    = vwDown == 0.0 ? 100.0 : vwUp == 0.0 ? 0.0 : 100.0 - 100.0 / (1.0 + vwUp / vwDown)

// Signal Line
rsiMA  = ta.ema(rsi, maLen)

// OB/OS Release Logic (Price coming back inside the bands)
releaseUp = rsi[1] <= i_osLevel and rsi > i_osLevel
releaseDn = rsi[1] >= i_obLevel and rsi < i_obLevel

// ============================================================================
// III. PLOTS & VISUALS
// ============================================================================

// VWRSI and Signal Line
rsiPlot = plot(rsi,   title="VWRSI", color=color.new(color.blue, 0), linewidth=2)
maPlot  = plot(rsiMA, title="MA", color=color.new(color.gray, 20), linewidth=1, linestyle=plot.linestyle_dotted)

// Dynamic Momentum Fill
fill(rsiPlot, maPlot,
     color = rsi > rsiMA ? color.new(color.green, 50) : color.new(color.red, 50),
     title = "Momentum Spread Fill")

plot(50, title="Mid", color=color.new(color.yellow, 0), linewidth=1)
hline(i_obLevel,  "OB Level", color=color.new(color.red, 40), linestyle=hline.style_dashed)
hline(i_osLevel,  "OS Level", color=color.new(color.green, 40), linestyle=hline.style_dashed)

// OB/OS Release Shapes & Flashes
bgcolor(releaseUp or releaseDn ? color.new(color.orange, 40) : na, title="Release Flash")

plotshape(releaseDn, title="OB Release", location=location.top,    
          style=shape.triangledown, size=size.small, color=color.red, text="Dn")
plotshape(releaseUp, title="OS Release", location=location.bottom, 
          style=shape.triangleup,   size=size.small, color=color.green, text="Up")
````
