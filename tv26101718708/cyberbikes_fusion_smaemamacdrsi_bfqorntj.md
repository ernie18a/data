# Cyberbikes Fusion (SMAEMA+MACD+RSI)

- url: https://www.tradingview.com/script/bFQorntj-Cyberbikes-Fusion-SMAEMA-MACD-RSI/
- type: indicator
- pine_id: PUB;e69a56fb8dd14de3bbaa24b1880714cf
- version: 4.0

## Description

## Cyberbikes Fusion (SMAEMA+MACD+RSI)

### What it is
A **trend + momentum fusion** indicator. Instead of watching three separate tools, it folds them into one signal:

1. **SMA+EMA blend** — your 8 moving averages (4 EMAs + 4 SMAs at 9/21/80/200) are merged into one combined line, then smoothed into its own SMA and EMA. This is the **trend** backbone.
2. **MACD histogram** — the **momentum** of the trend (is it accelerating or fading).
3. **RSI** — **overbought/oversold** pressure (0–100).

All three are normalized to the same 0–100 scale and weighted-averaged into a single "universal" reading. A light-blue **EMA (thick)** and **SMA (thin)** are drawn from that, and the gap between them is painted **green when bullish / rising** and **red when bearish / falling**.

### What each piece tells you
| Component | Answers the question |
|---|---|
| Combined SMA+EMA | *Which way is the broader trend leaning?* |
| MACD | *Is momentum building or stalling?* |
| RSI | *Is price stretched (overbought/oversold)?* |
| **Green/red color** | *Are all of the above agreeing right now?* |

The whole point is **confluence** — the signal only commits to green or red strongly when trend, momentum, and RSI **agree**. When they disagree, they partially cancel and it sits neutral. That agreement-filter is what reduces false signals versus reading any one indicator alone.

### How to use it
**The green/red flip is the primary signal:**
- **Red → green** = bullish shift (trend + momentum turning up together). Look for **long** setups.
- **Green → red** = bearish shift. Look for **exits or shorts**.

**Best practice — treat it as confirmation, not a standalone trigger:**
1. **Direction first** — only take longs while it's green, shorts while it's red. Don't fight the color.
2. **Confirm your entries** — when your own setup (support bounce, breakout, pullback) lines up *and* the color agrees, that's a higher-probability entry.
3. **Watch for the EMA/SMA cross** — the thick EMA crossing the thin SMA marks the momentum turn; the alerts (`Bullish`/`Bearish`) fire there.
4. **Stay out of chop** — if the color is flickering green/red rapidly, the market is ranging and signals are unreliable. Wait for a clean, sustained color.

### Timeframe behavior
The smoothing length **auto-adjusts to your chart timeframe** (shorter on higher timeframes), so it stays responsive without re-tuning. Higher timeframes (4h/Daily) give cleaner, fewer signals; lower timeframes (1–15m) give more signals but more noise.

### Honest limitations
- It's a **blend of lagging + momentum** tools — it confirms moves, it doesn't predict tops/bottoms.
- In **sideways/low-volume** markets it will whipsaw like any MA-based system. Size down or stand aside.
- Best used **with** price-action and a risk plan (stops/position sizing), never as a sole auto-trade trigger.

---

Want me to **bake this description into the script as a header comment block** (so it travels with the code), or write it up as a short `.md` doc saved next to the `.pine` file?

## Source Code

````pine
//@version=6
indicator("Cyberbikes Fusion (SMAEMA+MACD+RSI)", shorttitle="CB Universal", overlay=true)

// === Price-following ribbon ===
GRP_R = "Price-Following Ribbon"
ribEmaLen = input.int(9,  minval=1, title="EMA Length (thick)", group=GRP_R)
ribSmaLen = input.int(21, minval=1, title="SMA Length (thin)",  group=GRP_R)

// === Combined MAs + MACD + RSI (alerts) ===
GRP_P = "Combined MAs"
emaLen1 = input.int(9,"EMA #1",group=GRP_P), emaLen2 = input.int(21,"EMA #2",group=GRP_P)
emaLen3 = input.int(80,"EMA #3",group=GRP_P), emaLen4 = input.int(200,"EMA #4",group=GRP_P)
smaLen1 = input.int(9,"SMA #1",group=GRP_P), smaLen2 = input.int(21,"SMA #2",group=GRP_P)
smaLen3 = input.int(80,"SMA #3",group=GRP_P), smaLen4 = input.int(200,"SMA #4",group=GRP_P)
GRP_M = "MACD + RSI"
fastLen = input.int(12,"MACD Fast",group=GRP_M), slowLen = input.int(26,"MACD Slow",group=GRP_M)
sigLen  = input.int(9,"MACD Signal",group=GRP_M), rsiLen = input.int(14,"RSI Length",group=GRP_M)
GRP_U = "Blend"
normLen   = input.int(100,"Normalization Lookback", minval=2, group=GRP_U)
wPrice    = input.float(1.0,"Price Weight", minval=0, step=0.1, group=GRP_U)
wMom      = input.float(1.0,"Momentum Weight", minval=0, step=0.1, group=GRP_U)
autoByTf  = input.bool(true,"Auto length by timeframe", group=GRP_U)
manualLen = input.int(14,"Manual Length", minval=1, group=GRP_U)

// === Whipsaw control ===
confirmBars = input.int(0, "Confirmation Bars", minval=0, group="Signal Filter", tooltip="Bars the cross must hold before color flips. 0 = instant crossover.")

// === Colors (USER-CONTROLLED) ===
GRP_C = "Colors"
invertColors = input.bool(false, "Invert color scheme", group=GRP_C, tooltip="OFF: EMA above SMA = Bullish color. ON: EMA above SMA = Bearish color (flips everything).")
bullCol = input.color(color.green, "Bullish color", group=GRP_C, tooltip="Color used when EMA is above SMA (unless inverted).")
bearCol = input.color(color.red,   "Bearish color", group=GRP_C, tooltip="Color used when SMA is above EMA (unless inverted).")
fillTransp = input.int(70, "Fill Transparency", minval=0, maxval=100, group=GRP_C)

// === CALCULATIONS ===
src = close
ribEma = ta.ema(src, ribEmaLen)
ribSma = ta.sma(src, ribSmaLen)

// --- COLOR LOGIC: EMA vs SMA crossover ---
rawBull = ribEma > ribSma                 // EMA above SMA = bullish (logical)
var int  held   = 0
held := rawBull == rawBull[1] ? held + 1 : 0
var bool isBull = rawBull
if held >= confirmBars
    isBull := rawBull

// Apply the user's color choice. XOR with invert flips the whole scheme.
showBull = isBull != invertColors
trendCol = showBull ? bullCol : bearCol

// --- Combined signal (alerts only) ---
ema1=ta.ema(src,emaLen1),ema2=ta.ema(src,emaLen2),ema3=ta.ema(src,emaLen3),ema4=ta.ema(src,emaLen4)
sma1=ta.sma(src,smaLen1),sma2=ta.sma(src,smaLen2),sma3=ta.sma(src,smaLen3),sma4=ta.sma(src,smaLen4)
combinedLine = (ema1+ema2+ema3+ema4+sma1+sma2+sma3+sma4)/8
norm(s,ln) =>
    lo=ta.lowest(s,ln), hi=ta.highest(s,ln)
    hi==lo?50.0:100.0*(s-lo)/(hi-lo)
macd=ta.ema(src,fastLen)-ta.ema(src,slowLen)
hist=macd-ta.ema(macd,sigLen)
up=ta.rma(math.max(ta.change(src),0),rsiLen), down=ta.rma(-math.min(ta.change(src),0),rsiLen)
rsi=down==0?100:up==0?0:100-(100/(1+up/down))
composite=(rsi+norm(hist,normLen))/2
autoLen() =>
    s=timeframe.in_seconds()
    s<=60?50:s<=300?34:s<=900?21:s<=3600?14:s<=14400?10:9
len=autoByTf?autoLen():manualLen
priceSma=ta.sma(combinedLine,len), priceEma=ta.ema(combinedLine,len)
wSum=wPrice+wMom
uniEma=wSum==0?50.0:(norm(priceEma,normLen)*wPrice+ta.ema(composite,len)*wMom)/wSum
uniSma=wSum==0?50.0:(norm(priceSma,normLen)*wPrice+ta.sma(composite,len)*wMom)/wSum

// === PLOTS (all driven by the single trendCol → never inconsistent) ===
smaPlot = plot(ribSma, "SMA", color=trendCol, linewidth=1)
emaPlot = plot(ribEma, "EMA", color=trendCol, linewidth=3)
fill(smaPlot, emaPlot, color=color.new(trendCol, fillTransp), title="EMA/SMA Cross Fill")

// Triangles use the same chosen colors (respect invert too)
upCross = isBull and not isBull[1]
dnCross = not isBull and isBull[1]
plotshape(upCross, title="Bullish Cross", style=shape.triangleup,   location=location.belowbar, color=invertColors ? bearCol : bullCol, size=size.tiny)
plotshape(dnCross, title="Bearish Cross", style=shape.triangledown, location=location.abovebar, color=invertColors ? bullCol : bearCol, size=size.tiny)
alertcondition(upCross, title="Bullish Cross", message="EMA crossed above SMA")
alertcondition(dnCross, title="Bearish Cross", message="SMA crossed above EMA")
````
