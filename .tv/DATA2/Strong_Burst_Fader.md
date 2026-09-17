<!-- tradingview-pine-id: PUB;dcb5c75db63b40d3a4805109e2ea2f45 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Strong Burst Fader

Source: https://www.tradingview.com/script/VsFvGdYk-Strong-Burst-Fader-ProjectSyndicate/

## Description

Strong Burst Fader measures the one thing a mean-reversion trader actually needs — how far price has over-extended — and prints it as heat. Every bar that punches beyond a volatility envelope is a burst, and the further it stretches past the band, the taller and hotter the diamond column the indicator stacks at that bar. A quiet market prints nothing. A violent, over-cooked thrust prints a towering, red-hot column that says the move is running on fumes. Your chart stays clean — heat columns and nothing else — while the engine measures every burst underneath, across your entire history.

Most volatility tools draw a band and leave you to guess which touch matters. This one grades the burst.

GBPUSD

[image]https://www.tradingview.com/x/v41eGTQA/[/image]

🔥 The Burst Engine — the core. Around a configurable moving-average basis, the tool builds an ATR envelope (basis ± Band Width × ATR). The moment a bar's wick pokes past that envelope, it's a burst — an over-extension, not a normal bar. The engine measures exactly how far the wick travelled beyond the band and expresses it in ATR units, so a burst on gold and a burst on a quiet FX pair are scored on the same volatility-normalized scale. The bigger the stretch, the more oversized the move — and the stronger the fade case.

🌡️ Heatmap Stack — the signature read. Burst size is double-encoded so you can read it at a glance from across the room. Height: the column grows one diamond per step of ATR beyond the band, up to the cap. Heat: the colour ramps through a four-stop gradient — cool → warm → hot → extreme — as the stretch deepens. A one-diamond cool poke is a shrug. A six-high, white-hot tower is a market screaming that it has gone too far, too fast. Taller and hotter = more oversized, no interpretation required.

📏 The Volatility Basis — what "too far" is measured against. Choose the reference the burst is judged from: EMA, SMA, HMA, WMA, VWMA or RMA, any length, with an independent ATR length and band width. Widen the band in trending regimes so only real over-extensions register; tighten it in ranges to catch smaller exhaustion. The basis is also the natural first target when a burst fades back toward the mean.

📍 Peak Collapse — one clean vertical column per burst. A fast thrust fires the burst condition on several bars in a row. Instead of smearing a stack across every one of them, the engine collapses each run to its magnitude peak — the single bar where the stretch is greatest — and draws the whole column there, pinned to that one bar. Every diamond shares a single x-coordinate, so the column is dead-straight vertical with zero diagonal drift. One burst, one column, marking the exact climax you want to fade.

NQ

[image]https://www.tradingview.com/x/OVMyhODn/[/image]

🔻🔺 Fade Cues — direction, on demand. When a burst is oversized enough to clear your threshold, an arrow prints at the column: ▽ above an up-burst (over-extended high → fade short) and △ below a down-burst (over-extended low → fade long). Set the minimum stack height that earns an arrow, so only the genuinely stretched moves get flagged and minor pokes stay quiet.

♾️ Full-History Heat — no drawing-object limit. The entire heatmap is rendered through plot-shape symbols rather than chart objects, so it covers all of your history at once — no 500-object ceiling, no zones silently dropping off the left edge as you scroll back. Every burst your data holds is measured and coloured, from the first bar to the live one.

🧼 Clean-Chart Discipline — heat and nothing else. No moving-average spaghetti, no band lines cluttering price, no stat panel, no signal labels stamped across your candles. Just the heat columns and the optional fade arrows. An optional background tint flags only the most extreme bursts. Everything else lives in the alerts.

🎨 Fully Themed & Configurable. Custom mild / warm / hot / extreme heat colours; diamond spacing and offset from the wick; band width and ATR length; basis type and length; ATR-per-step (how fast the stack grows); heat-saturation point (where the colour maxes out); max stack height; the closing-burst filter; the confirm-on-close toggle; the fade-arrow threshold; and the extreme-burst background tint.

🔒 Honest, Non-Repainting Core. A burst peak is confirmed from the bar's neighbours, which — like any pivot-style read — settles a bar after the fact; that lag is inherent, not a defect. With Confirm on Bar Close enabled, columns are evaluated only on closed bars and are fixed once printed; disable it and the newest column can still update on the live forming bar until it closes, as any close-based read does. The height and heatmap are descriptive frameworks for ranking over-extension and directing attention — not a backtested edge and not a promise that any burst will reverse.

XTI

[image]https://www.tradingview.com/x/DtAydAps/[/image]

🔔 Native Alerts. Up burst (fade-short candidate), Down burst (fade-long candidate), and the two headline extremes — Extreme Up and Extreme Down — that fire only when a burst tops out at maximum stack. Wire them once and let the chart stay silent until a move is genuinely stretched.

🎯 Why this is different. A raw band is static — you eyeball a touch and guess whether it matters. An oscillator tells you overbought / oversold but caps out and loses all sense of scale exactly when a move goes parabolic. Strong Burst Fader keeps measuring past the extreme: it quantifies the over-extension itself in ATR, ranks it by height and heat, and marks the single climax bar of each thrust. You see not just that price is stretched, but how stretched — and where the stretch peaked.

🚀 Apply to Gold (XAUUSD), Silver, Forex, Crypto, Indices and Futures on any timeframe. Because bursts are measured in ATR beyond an adaptive band, the read travels across symbols and timeframes without re-tuning; volume-weighted bases (VWMA) sharpen it where a market carries clean volume.

💡 Cleanest setup: widen Band Width and raise ATR-per-step so only real over-extensions build tall columns; keep Confirm on Bar Close on for a non-repainting read; turn on the closing-burst filter when you want acceptance beyond the band rather than pure wick pokes; and lower the fade-arrow threshold only if you want cues on smaller stretches.

USDSGD

[image]https://www.tradingview.com/x/VH4fxWjP/[/image]

🎯 How To Trade It — Two Approaches

Everything hinges on one read: how oversized is this burst, and has it climaxed?

🔥 1) Fade the burst — trade the over-extension (the core thesis)

Use when a tall, hot column prints — a burst that has stretched well beyond the band.

Mark the extreme columns — five- and six-high, hot-to-extreme colour are the moves that have run too far, too fast; the taller and redder, the stronger the fade case.
Wait for the peak — the column marks the burst's climax bar, not a mid-move poke. That's your reference.
Trigger: take the fade in the reclaim direction — short an over-extended up-burst, long an over-extended down-burst — ideally on the fade arrow (▽ / △) and confirmed once the peak bar closes.
Stop: beyond the burst extreme (the wick that made the column). If price accepts further out, the "over-extension" was real trend expansion — stand aside.
Target: the basis / mean first, then the opposite band or the next unstretched level in your direction.

⚖️ The cleanest version: a six-high, white-hot up-burst tops out after a vertical thrust, a ▽ fade-short arrow prints, and the peak bar closes back inside the band. Too far, too fast, and now rolling over — the exact event this tool is built to frame.

✋ 2) Stand down — the heat says wait
Cool, short columns — one- or two-diamond pokes are minor stretches, not exhaustion. Nothing to fade.
A trend that keeps bursting — column after column in the same direction with the band riding along is acceptance, not over-extension; don't stand in front of it. Wait for the climax column and a close back inside.
No peak yet — a bar merely touching the band is not a burst that has topped out. Wait for the tall, hot column and its close.

Rule of thumb: 🔥 Tall + hot column + fade arrow + close back inside → fade the burst toward the basis. ❄️ Cool/short columns, a trend that keeps bursting, or no climax yet → stand down until the heat agrees.

---

## Source Code

````pine
//@version=6
indicator("Strong Burst Fader", overlay = true)

gM        = "Burst Measurement"
srcIn     = input.source(close, "Basis source",                                   group = gM)
basisType = input.string("EMA", "Basis type", options = ["EMA", "SMA", "HMA", "WMA", "VWMA", "RMA"], group = gM)
basisLen  = input.int(20, "Basis length", minval = 2, maxval = 400,               group = gM)
atrLen    = input.int(14, "ATR length",   minval = 2, maxval = 200,               group = gM)
bandMult  = input.float(2.0, "Band width (ATR beyond basis = burst starts)", minval = 0.2, maxval = 10.0, step = 0.1, group = gM, tooltip = "A bar counts as a burst when its high pokes above basis + this·ATR (or its low below basis − this·ATR).")
stepATR   = input.float(0.5, "ATR per stack step", minval = 0.1, maxval = 3.0, step = 0.05, group = gM, tooltip = "Each extra step of ATR beyond the band adds one diamond to the stack and one notch of heat.")
maxLevels = input.int(6, "Max stack height (diamonds)", minval = 1, maxval = 6,    group = gM, tooltip = "Hard cap on the stack. 6 is the physical maximum this script draws.")
heatSat   = input.float(3.0, "Heat saturates at (ATR beyond band)", minval = 0.5, maxval = 12.0, step = 0.5, group = gM, tooltip = "Burst magnitude (in ATR beyond the band) at which the colour reaches the hottest stop.")
needClose = input.bool(false, "Require closing burst (close beyond band)",        group = gM, tooltip = "ON: only count a burst when the CLOSE also finishes beyond the band, filtering pure-wick pokes. OFF: any wick beyond the band counts.")
confirmBar= input.bool(true, "Confirm on bar close (non-repaint)",                group = gM, tooltip = "ON: burst peaks are detected only on closed bars, so nothing repaints. OFF: the newest peak may update on the live bar.")

gV        = "Appearance"
baseGap   = input.float(0.6, "First diamond offset (× ATR from wick)", minval = 0.0, maxval = 4.0, step = 0.1, group = gV)
rowGap    = input.float(0.45, "Stack spacing (× ATR)", minval = 0.05, maxval = 2.0, step = 0.05, group = gV)
showBg    = input.bool(false, "Tint background on extreme bursts",                group = gV, tooltip = "Shades the peak bar's column with the heat colour once a burst reaches the max stack height.")

gC        = "Heatmap colours (cool → hot)"
cCold     = input.color(#26c6da, "Mild",    group = gC, inline = "h")
cWarm     = input.color(#ffd54a, "Warm",    group = gC, inline = "h")
cHot      = input.color(#ff7a1a, "Hot",     group = gC, inline = "h")
cExtreme  = input.color(#ff2b4e, "Extreme", group = gC, inline = "h")

gF        = "Fade cues"
showFade  = input.bool(true, "Show fade arrows on oversized bursts",              group = gF, tooltip = "▽ above an up-burst = fade short.  △ below a down-burst = fade long.")
fadeMin   = input.int(3, "Min stack height to flag a fade", minval = 1, maxval = 6, group = gF)

basis = switch basisType
    "SMA"  => ta.sma(srcIn, basisLen)
    "HMA"  => ta.hma(srcIn, basisLen)
    "WMA"  => ta.wma(srcIn, basisLen)
    "VWMA" => ta.vwma(srcIn, basisLen)
    "RMA"  => ta.rma(srcIn, basisLen)
    => ta.ema(srcIn, basisLen)

atr   = ta.atr(atrLen)
upper = basis + bandMult * atr
lower = basis - bandMult * atr

upExtP = high - upper
dnExtP = lower - low
upMag  = atr > 0 ? upExtP / atr : 0.0
dnMag  = atr > 0 ? dnExtP / atr : 0.0

upSpike = upExtP > 0 and (not needClose or close > upper)
dnSpike = dnExtP > 0 and (not needClose or close < lower)

okBar = confirmBar ? barstate.isconfirmed : true

heatCol(float t) =>
    tt = math.max(0.0, math.min(1.0, t))
    tt < 0.40 ? color.from_gradient(tt, 0.0, 0.40, cCold, cWarm) : tt < 0.75 ? color.from_gradient(tt, 0.40, 0.75, cWarm, cHot) : color.from_gradient(tt, 0.75, 1.0, cHot, cExtreme)

upM0 = upSpike ? math.max(0.0, upMag) : 0.0
dnM0 = dnSpike ? math.max(0.0, dnMag) : 0.0

upPeak = okBar and upM0[1] > 0 and upM0[1] >= upM0[2] and upM0[1] > upM0
dnPeak = okBar and dnM0[1] > 0 and dnM0[1] >= dnM0[2] and dnM0[1] > dnM0

upPk    = upM0[1]
dnPk    = dnM0[1]
upLvlPk = math.min(maxLevels, 1 + int(upPk / stepATR))
dnLvlPk = math.min(maxLevels, 1 + int(dnPk / stepATR))
upColPk = heatCol(upPk / heatSat)
dnColPk = heatCol(dnPk / heatSat)

aPk    = atr[1]
baseUp = high[1]
baseDn = low[1]
yU(int k) => baseUp + (baseGap + (k - 1) * rowGap) * aPk
yD(int k) => baseDn - (baseGap + (k - 1) * rowGap) * aPk

u1 = upPeak and upLvlPk >= 1 ? yU(1) : na
u2 = upPeak and upLvlPk >= 2 ? yU(2) : na
u3 = upPeak and upLvlPk >= 3 ? yU(3) : na
u4 = upPeak and upLvlPk >= 4 ? yU(4) : na
u5 = upPeak and upLvlPk >= 5 ? yU(5) : na
u6 = upPeak and upLvlPk >= 6 ? yU(6) : na
d1 = dnPeak and dnLvlPk >= 1 ? yD(1) : na
d2 = dnPeak and dnLvlPk >= 2 ? yD(2) : na
d3 = dnPeak and dnLvlPk >= 3 ? yD(3) : na
d4 = dnPeak and dnLvlPk >= 4 ? yD(4) : na
d5 = dnPeak and dnLvlPk >= 5 ? yD(5) : na
d6 = dnPeak and dnLvlPk >= 6 ? yD(6) : na

plotshape(u1, "Up 1", shape.diamond, location.absolute, upColPk, offset = -1, size = size.small)
plotshape(u2, "Up 2", shape.diamond, location.absolute, upColPk, offset = -1, size = size.small)
plotshape(u3, "Up 3", shape.diamond, location.absolute, upColPk, offset = -1, size = size.small)
plotshape(u4, "Up 4", shape.diamond, location.absolute, upColPk, offset = -1, size = size.small)
plotshape(u5, "Up 5", shape.diamond, location.absolute, upColPk, offset = -1, size = size.small)
plotshape(u6, "Up 6", shape.diamond, location.absolute, upColPk, offset = -1, size = size.small)
plotshape(d1, "Dn 1", shape.diamond, location.absolute, dnColPk, offset = -1, size = size.small)
plotshape(d2, "Dn 2", shape.diamond, location.absolute, dnColPk, offset = -1, size = size.small)
plotshape(d3, "Dn 3", shape.diamond, location.absolute, dnColPk, offset = -1, size = size.small)
plotshape(d4, "Dn 4", shape.diamond, location.absolute, dnColPk, offset = -1, size = size.small)
plotshape(d5, "Dn 5", shape.diamond, location.absolute, dnColPk, offset = -1, size = size.small)
plotshape(d6, "Dn 6", shape.diamond, location.absolute, dnColPk, offset = -1, size = size.small)

fadeUpY = showFade and upPeak and upLvlPk >= fadeMin ? baseUp + (baseGap + upLvlPk * rowGap) * aPk : na
fadeDnY = showFade and dnPeak and dnLvlPk >= fadeMin ? baseDn - (baseGap + dnLvlPk * rowGap) * aPk : na
plotshape(fadeUpY, "Fade short", shape.triangledown, location.absolute, color.new(cExtreme, 0), offset = -1, size = size.tiny)
plotshape(fadeDnY, "Fade long",  shape.triangleup,   location.absolute, color.new(#2b7bff, 0),  offset = -1, size = size.tiny)

bgCol = showBg and upPeak and upLvlPk >= maxLevels ? color.new(upColPk, 82) : showBg and dnPeak and dnLvlPk >= maxLevels ? color.new(dnColPk, 82) : na
bgcolor(bgCol, offset = -1, title = "Extreme-burst tint")

upXtreme = upPeak and upLvlPk >= maxLevels
dnXtreme = dnPeak and dnLvlPk >= maxLevels
alertcondition(upPeak,   "Burst Fader — Up burst (fade short)",  "Up burst peaked above the band — fade-short candidate.")
alertcondition(dnPeak,   "Burst Fader — Down burst (fade long)", "Down burst peaked below the band — fade-long candidate.")
alertcondition(upXtreme, "Burst Fader — Extreme up",   "Up burst peaked at max stack — heavily over-extended.")
alertcondition(dnXtreme, "Burst Fader — Extreme down", "Down burst peaked at max stack — heavily over-extended.")
````
