# Modern Adaptive Supertrend [GBB]

- url: https://www.tradingview.com/script/Wagz8RF1-Modern-Adaptive-Supertrend-GBB/
- type: indicator
- pine_id: PUB;31912fd52c67457f8559a3a5e15f0cad
- version: 1.0

## Description

[b]Modern Adaptive Supertrend [GBB][/b]

Supertrend is probably the most copied trend indicator on TradingView. Most of the copies inherit the same handful of weaknesses so this is my attempt to fix the ones worth fixing, test the result properly, and be straight about the fix that didn't pan out.

If you have used the classic Supertrend you already know the idea. It is a volatility-based trailing line. It sits below price in an uptrend, above price in a downtrend, and it flips when price closes through it. Simple, fast to read, works on any chart. That simplicity is why it spread everywhere, and it is also where the trouble starts.


[b]WHAT GOES WRONG WITH THE CLASSIC VERSION[/b]

Three things. The distance from price never adapts, so a clean trend and a sideways mess get treated exactly the same. The lookback never changes speed. And it flips on a single touch, so one wick through the line flips your bias and the next bar flips it back. That last one is the whipsaw everyone complains about. Run the classic as an always-in system on the 1h or below and in my testing it bleeds out. It only really holds up at 4h and above, where the trends are big enough to pay for all the flipping.


[b]WHAT THIS VERSION DOES DIFFERENTLY[/b]

Two changes that work (and one that didn't but I left in place for you to experiment with)

[i]The commit filter[/i]. This is the one that did the real work. Instead of flipping the moment price tags the line, price now has to close past it by a margin, about half an ATR by default, and optionally hold for a bar before the flip counts. That single change cut false flips by roughly 60% across the timeframes I tested. Same trend read, far less noise.

[i]The adaptive distance[/i]. The band widens when the market is trending cleanly so it holds the move instead of shaking you out, and it also widens in chop, because a tight band in a range is a whipsaw machine. The only place it tightens is the transition, when a new move is just starting and you actually want it responsive. It judges trend versus chop against the market's own recent behaviour rather than a fixed threshold, because fixed thresholds do not travel well on crypto. I found that out the hard way.

[i]The one that didn't work[/i]. I also built an adaptive lookback that was meant to let the indicator change speed with the market's rhythm. It added nothing. On crypto the rhythm turned out stable enough that adaptive just gave me a slower copy of the same line. It is still in the settings as an experimental toggle, switched off by default. Maybe you can find a tweak to make this feature work? If yes send me a DM :-)

One thing to be clear about before the settings. This is a trend filter, not a trading system. On raw direction it is right about 48% of the time, which is a coin flip, because Supertrend follows trend, it does not predict it. The value is in a cleaner trend read and lower drawdown, not in calling tops and bottoms. More on that at the bottom.


[b]SETTINGS[/b]

Preset
Classic, Modern, or Custom. Classic is the textbook indicator, unchanged, so you can put it side by side. Modern is the default and what I recommend. It is timeframe aware: on 1h and below it runs both the adaptive distance and the commit filter, and above 1h it runs the commit filter only, because the adaptive distance did not add anything at higher timeframes in testing. Custom lets you toggle the layers yourself.

Commit filter (hysteresis)
- Commit buffer: how far past the line price has to close before a flip counts, measured in ATR. Default 0.5. Higher means fewer flips and slower turns.
- Persistence: how many closed bars the break has to hold before it flips. Default 1.

Adaptive distance (regime multiplier)
- Trend gain: how much wider the band gets in a clean trend. Default 0.8.
- Chop gain: how much wider it gets in a range. Default 0.5.
- Percentile window: how much recent history it uses to judge trend versus chop. Default 500 bars. Shorter reacts faster but is jumpier.

Adaptive period (experimental, off by default)
Turns on the adaptive lookback described above, with min and max clamps on the range. The defaults are in there, but as I said, it did not improve results. Leave it off unless you want to poke at it yourself.

Classic settings
ATR period and multiplier. Used by the Classic preset and as the base the other layers build on. Defaults 10 and 3.

Display
Direction-coloured line, an optional fill between price and the line, and flip markers. There is also an optional regime readout that shows whether the engine currently sees trend or chop. Off by default to keep the chart clean. Turn it on if you want to see what it is "thinking".

Alerts
Separate flip-up and flip-down conditions, plus an optional JSON payload if you want to wire it into a webhook.


HOW TO USE IT

As one input, not the whole decision. It answers a single question, which way is the trend leaning right now, with less noise than the classic gives you. It does not tell you where to enter or where price goes next. Use it to set your bias, then bring your own levels, structure, or entry trigger for the rest. Treating a trend filter as an entry system is how people lose money with a tool that is working exactly as designed.

## Source Code

````pine
// © The Good, the Bad and the Bitcoin
//@version=6

indicator("Modern Adaptive Supertrend [GBB]", overlay = true, max_labels_count = 100)

tfSec = timeframe.in_seconds()

// ----------------------------------------------------------------------------
// Mode
//   Modern (auto): TF-aware confluence preset. L2(percentile)+L3 at <=1h where
//     whipsaw dominates; L3 only above 1h where trends are cleaner. L1 stays an
//     experimental opt-in (it did not earn its place OOS).
//   Classic: textbook Supertrend, bar-for-bar (all layers off).
//   Custom: drive each layer from its own toggle (for ablation / power users).
// ----------------------------------------------------------------------------
gMode = "Mode"
preset = input.string("Modern (auto, TF-aware)", "Preset", options = ["Modern (auto, TF-aware)", "Classic (textbook)", "Custom"], group = gMode, tooltip = "Modern auto-tunes per timeframe. Classic = textbook. Custom = use the layer toggles.")

// ----------------------------------------------------------------------------
// Inputs
// ----------------------------------------------------------------------------
gBase = "Base (L0)"
atrPeriodInput = input.int(10, "ATR Period (L0 fallback)", minval = 1, group = gBase, tooltip = "Used when Adaptive Period (L1) is off.")
multInput      = input.float(3.0, "Multiplier (L0 fallback)", minval = 0.1, step = 0.1, group = gBase, tooltip = "Used when Regime Multiplier (L2) is off.")

gL1 = "L1 - Adaptive ATR period (experimental; Custom mode only)"
useL1c    = input.bool(false, "Enable adaptive period", group = gL1, tooltip = "Ehlers homodyne dominant cycle. Off by default: did not earn its place OOS (on 1h BTC the cycle is near-stable, so it just runs slower than fixed-10). Only active in Custom mode.")
minPeriod = input.int(5,  "Min period", minval = 2, group = gL1)
maxPeriod = input.int(50, "Max period", minval = 3, group = gL1)

gL2 = "L2 - Regime-scaled multiplier"
useL2c      = input.bool(false, "Enable regime multiplier (Custom)", group = gL2, tooltip = "Convex KER hinge. In Modern mode this auto-enables at <=1h. Only this toggle applies in Custom mode.")
kerLen      = input.int(20, "KER lookback", minval = 2, group = gL2)
kerPctileIn = input.bool(true, "Rank KER vs its own distribution", group = gL2, tooltip = "Recommended: raw KER on crypto sits below the pivot almost always, collapsing the hinge to a constant wide band. Modern mode forces this on.")
kerPctWin   = input.int(500, "KER percentile window", minval = 20, group = gL2)
pivot       = input.float(0.5, "Hinge pivot", minval = 0.05, maxval = 0.95, step = 0.05, group = gL2)
trendGain   = input.float(0.8, "Trend gain", minval = 0.0, step = 0.1, group = gL2)
chopGain    = input.float(0.5, "Chop gain",  minval = 0.0, step = 0.1, group = gL2)
multMin     = input.float(1.0, "Mult min", minval = 0.1, step = 0.1, group = gL2)
multMax     = input.float(6.0, "Mult max", minval = 0.1, step = 0.1, group = gL2)

gL3 = "L3 - Hysteresis flip filter"
useL3c   = input.bool(true, "Enable hysteresis (Custom)", group = gL3, tooltip = "In Modern mode this is always on. Only this toggle applies in Custom mode.")
hystAtr  = input.float(0.5, "Penetration buffer (xATR)", minval = 0.0, step = 0.1, group = gL3, tooltip = "Close must clear the opposing band by this many ATRs to flip.")
hystBars = input.int(1, "Persistence bars", minval = 0, group = gL3, tooltip = "Penetration must hold this many confirmed bars. 0 = buffer only.")

// --- Preset resolution -------------------------------------------------------
isModern  = preset == "Modern (auto, TF-aware)"
isCustom  = preset == "Custom"
useL1 = isCustom and useL1c
useL2 = isModern ? (tfSec <= 3600) : (isCustom and useL2c)   // L2 only <=1h in Modern
useL3 = isModern ? true            : (isCustom and useL3c)
kerPctile = isModern ? true : kerPctileIn

gDisp = "Display"
showLabel = input.bool(false, "Show regime readout", group = gDisp, tooltip = "Off by default. The on-chart label showing trend / regime / band state.")
mode      = input.string("Beginner", "Readout mode", options = ["Beginner", "Pro"], group = gDisp, tooltip = "Only applies when the regime readout is shown.")
showFill  = input.bool(true, "Fill price to line", group = gDisp)
showFlips = input.bool(true, "Flip markers", group = gDisp)
txtSize   = input.string("Normal", "UI text size", options = ["Small", "Normal", "Large"], group = gDisp)


src = hl2
var float period = 0.0
var float smoothPeriod = 0.0

quad(s, pPrev) => (0.0962 * s + 0.5769 * s[2] - 0.5769 * s[4] - 0.0962 * s[6]) * (0.075 * pPrev + 0.54)

smooth    = (4 * src + 3 * src[1] + 2 * src[2] + src[3]) / 10.0
detrender = quad(smooth, nz(period[1]))
q1        = quad(detrender, nz(period[1]))
i1        = detrender[3]
jI        = quad(i1, nz(period[1]))
jQ        = quad(q1, nz(period[1]))
i2raw     = i1 - jQ
q2raw     = q1 + jI
var float i2 = 0.0
var float q2 = 0.0
i2 := 0.2 * i2raw + 0.8 * nz(i2[1])
q2 := 0.2 * q2raw + 0.8 * nz(q2[1])
reRaw = i2 * nz(i2[1]) + q2 * nz(q2[1])
imRaw = i2 * nz(q2[1]) - q2 * nz(i2[1])
var float re = 0.0
var float im = 0.0
re := 0.2 * reRaw + 0.8 * nz(re[1])
im := 0.2 * imRaw + 0.8 * nz(im[1])
float pRaw = (im != 0.0 and re != 0.0) ? 360.0 / math.todegrees(math.atan(im / re)) : nz(period[1])
pPrev = nz(period[1])
pLim  = pPrev > 0 ? math.max(math.min(pRaw, 1.5 * pPrev), 0.67 * pPrev) : pRaw
pClamp = math.min(math.max(pLim, 6.0), 50.0)
period := 0.2 * pClamp + 0.8 * pPrev
smoothPeriod := bar_index < 1 ? period : 0.33 * period + 0.67 * nz(smoothPeriod[1])

// Clamp + round the adaptive period; fall back to the fixed base period early.
adaptPeriod = math.min(math.max(math.round(smoothPeriod), minPeriod), maxPeriod)
periodUsed  = useL1 and bar_index >= 6 ? adaptPeriod : atrPeriodInput

// ----------------------------------------------------------------------------
// ATR - fixed (ta.atr) or adaptive (hand-rolled Wilder, per-bar alpha).
//   NOTE: ta.rma cannot take a series length, so the adaptive ATR is a manual
//   Wilder recursion atr := atr[1] + (1/len)*(tr - atr[1]). Seeded with the
//   fixed ATR so the two paths agree at the seam.
// ----------------------------------------------------------------------------
tr = ta.tr(true)
atrFixed = ta.atr(atrPeriodInput)
var float atrAdaptive = na
atrAdaptive := na(atrAdaptive[1]) ? atrFixed : atrAdaptive[1] + (1.0 / periodUsed) * (tr - atrAdaptive[1])
atr = useL1 ? atrAdaptive : atrFixed

// ----------------------------------------------------------------------------
// L2 - regime-scaled multiplier (convex hinge on KER)
// ----------------------------------------------------------------------------
kerDir = math.abs(close - close[kerLen])
kerVol = math.sum(math.abs(close - close[1]), kerLen)
ker    = kerVol > 0 ? kerDir / kerVol : 0.0
// Optional percentile rank of KER vs its own rolling window.
kerRank = ta.percentrank(ker, kerPctWin) / 100.0
kerSig  = kerPctile ? kerRank : ker
fTrend  = math.max(0.0, (kerSig - pivot) / (1.0 - pivot))
fChop   = math.max(0.0, (pivot - kerSig) / pivot)
multHinge = multInput * (1.0 + trendGain * fTrend + chopGain * fChop)
multEff   = useL2 ? math.min(math.max(multHinge, multMin), multMax) : multInput

// ----------------------------------------------------------------------------
// Bands + direction (shared L0 math). L3 only gates the flip.
// ----------------------------------------------------------------------------
upperBasic = hl2 + multEff * atr
lowerBasic = hl2 - multEff * atr

var float upperBand = na
var float lowerBand = na
var int   dir = 1
var int   candDir = 0
var int   candCount = 0

ubPrev = nz(upperBand[1], upperBasic)
lbPrev = nz(lowerBand[1], lowerBasic)
upperBand := (upperBasic < ubPrev or close[1] > ubPrev) ? upperBasic : ubPrev
lowerBand := (lowerBasic > lbPrev or close[1] < lbPrev) ? lowerBasic : lbPrev

prevDir = nz(dir[1], 1)
int newDir = prevDir
if not useL3
    newDir := close > ubPrev ? 1 : close < lbPrev ? -1 : prevDir
else
    buf = hystAtr * atr
    if prevDir == 1
        if close < lbPrev - buf
            candCount := candDir == -1 ? candCount + 1 : 1
            candDir := -1
            if candCount >= hystBars
                newDir := -1
                candDir := 0
                candCount := 0
        else
            candDir := 0
            candCount := 0
    else
        if close > ubPrev + buf
            candCount := candDir == 1 ? candCount + 1 : 1
            candDir := 1
            if candCount >= hystBars
                newDir := 1
                candDir := 0
                candCount := 0
        else
            candDir := 0
            candCount := 0
dir := newDir

float supertrend = dir == 1 ? lowerBand : upperBand
flip = dir != prevDir

// ----------------------------------------------------------------------------
// Display
// ----------------------------------------------------------------------------
upCol   = color.new(color.teal, 0)
downCol = color.new(color.red, 0)
stCol   = dir == 1 ? upCol : downCol

stPlot   = plot(supertrend, "Supertrend", color = stCol, linewidth = 2, style = plot.style_linebr)
priceAnchor = plot(close, "", color = color.new(color.gray, 100))   // scale anchor; not display.none
fill(priceAnchor, stPlot, color = showFill ? color.new(stCol, 88) : na)

plotshape(showFlips and flip and dir == 1  ? supertrend : na, "Flip Up",   style = shape.triangleup,   location = location.absolute, color = upCol,   size = size.tiny)
plotshape(showFlips and flip and dir == -1 ? supertrend : na, "Flip Down", style = shape.triangledown, location = location.absolute, color = downCol, size = size.tiny)

// Regime readout (Beginner = plain language, Pro = raw numbers).
tSize = txtSize == "Small" ? size.small : txtSize == "Large" ? size.large : size.normal
atrRank = ta.percentrank(atr, 100) / 100.0
trendingTxt = kerSig >= pivot ? "strong / wide for trend hold" : "weak / wide to suppress whipsaw"
quadrant = (kerSig >= pivot and atrRank >= 0.5) ? "strong trend, high vol" : (kerSig >= pivot ? "quiet trend" : (atrRank >= 0.5 ? "volatile chop" : "quiet chop"))
dirTxt = dir == 1 ? "UP" : "DOWN"

var label tag = na
if barstate.islast and showLabel
    label.delete(tag)
    txt = mode == "Beginner" ? "Trend: " + dirTxt + "\nRegime: " + quadrant + "\nBand: " + trendingTxt : "Dir: " + dirTxt + "  KER: " + str.tostring(kerSig, "#.00") + "\nMult: " + str.tostring(multEff, "#.00") + "  Period: " + str.tostring(periodUsed, "#") + "\nATR%ile: " + str.tostring(atrRank, "#.00") + (useL3 ? "  L3:on" : "  L3:off")
    tag := label.new(bar_index, supertrend, txt, style = dir == 1 ? label.style_label_up : label.style_label_down, color = color.new(stCol, 20), textcolor = color.white, size = tSize)

// ----------------------------------------------------------------------------
// Alerts (named conditions, per the OIPQ pattern) + optional JSON payload.
// ----------------------------------------------------------------------------
alertcondition(flip and dir == 1,  "Flip to uptrend",   "Modern Supertrend flipped UP")
alertcondition(flip and dir == -1, "Flip to downtrend", "Modern Supertrend flipped DOWN")
if flip
    payload = '{"indicator":"ModernSupertrend","dir":"' + dirTxt + '","price":' + str.tostring(close) + ',"ker":' + str.tostring(kerSig, "#.000") + ',"mult":' + str.tostring(multEff, "#.00") + '}'
    alert(payload, alert.freq_once_per_bar_close)
````
