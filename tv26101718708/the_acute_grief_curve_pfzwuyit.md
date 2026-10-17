# The Acute Grief Curve

- url: https://www.tradingview.com/script/PfZWuYit-The-Acute-Grief-Curve/
- type: indicator
- pine_id: PUB;7291ae0391b84c6ca2159c792981ec67
- version: 1.0

## Description

[b]ACUTE GRIEF CURVE[/b] - a momentum oscillator for a market in mourning, for crypto

Price action is just is a grief chart. It's a running tally of how a few
million strangers feel about money they no longer have. 

[b]WHERE IT COMES FROM[/b]

In 1962 a technician named Edwin Coppock got hired by the Episcopal Church to
tell them when to buy after a crash. He decided a market clawing out of a bear
feels like a person clawing out of mourning - same shock, same numbness, same
long stupid crawl back - so he asked the clergy how long grief lasts. 

They said 11 to 14 months. He typed those two numbers into a rate-of-change formula and
called it a day. That is the Coppock Curve. 

[b]WHY THE ORIGINAL DIES ON CRYPTO[/b]

Point standard Coppock at the total crypto market cap and it flatlines. Crypto went from three billion to four trillion. Early on it printed 16,000% moves; lately it prints 50% and calls it a bull run. On raw percentages the toddler years bury everything that came after, so the curve pins itself above zero for eight straight years and only dips under in 2022, once, like a smoke detector that exclusively activates during cremation. 

An indicator that signals once a decade is just a commemorative plate.

So I rebuilt it. 

[b]HOW IT'S DIFFERENT[/b]

1. The Yale Bereavement Study (JAMA 2007) tracked grieving people month by month and found yearning peaks around month 4 and depression bottoms out around month 6. That's the wound. Coppock's 11–14 months is the part where the widow has already repainted the kitchen. This curve uses the 6- and 4-month rate-of-change - the actual bottom of the despair - smoothed over 5 periods, because a crowd of leveraged strangers speedruns the five stages of grief in about a long weekend, and you want the indicator watching the screaming, not the kitchen.

2. Log price, because crypto has no sense of scale. Comparing a 16,000% move to
a 50% move on a normal axis is like comparing a supernova to a birthday candle
and concluding they're both fire. Log pricing makes the math behave so the
curve oscillates around zero like a functioning adult across every cycle. You
can switch it off and watch it relapse into the classic version if you enjoy
that sort of thing.

3. A volatility filter that knows hope is a liar. This comes from the Dual
Process Model of grieving (Stroebe & Schut), which says recovery isn't a line,
it's a flailing back-and-forth nightmare, and the tell that you're really healing is
that the flailing gets quieter. Volatility is a market's flailing. So every
time the curve turns up, the indicator checks whether the shaking is calming
down or just catching its breath.

[b]THE TWO SIGNALS[/b]

ACCEPTANCE ONSET (green): the curve turns up from below zero [i]AND[/i] volatility is
contracting. The thrashing is subsiding. Acceptance is winning. In a market
this is the closest thing to good news, which is to say you've stopped
screaming and you're choosing to interpret that optimistically.

FALSE REPRIEVE (amber): same turn up, but volatility is still expanding. This
is the corpse twitching. You see the twitch, you call it a recovery, you re-
long with conviction, and the corpse remains, professionally, a corpse. Every
bear-market rally that ever ruined someone lives here.

Telling those two apart is the whole job. It's the difference between "the
worst is over" and "the worst would like a word."

[b]HOW TO READ IT[/b]

Blue line is the curve. The shaded bit below zero is the acute grief zone, aka
where your timeline goes silent and the inspirational posters come out.
Background tint shows the volatility type - teal means contracting (healing),
red means expanding (don't). Signals print in the pane and on price. Optional
comparison curves let you plot the original 11–14 month clergy Coppock and the
useless-for-crypto 12–24 month integration version, so you can see, in public,
why the slow one would still be holding bags.


[b]INPUTS[/b]

Periods are defined in MONTHS and auto-scale to your timeframe, so the grief
stays the same length whether you're on monthly, weekly, or daily. Everything's
adjustable - the peaks, the smoothing, the volatility window, the log toggle,
the filter, the shading. Alerts included, in case you want to be notified the
exact moment the market accepts its fate.


[b]OMG USE YOUR HEAD, THIS IS A WORK IN PROGRESS[/b]

This is a context gauge, not a trade trigger. The filter is conservative - it distrusts sharp V-bottoms, because on those the volatility never calms down, which means it flagged the COVID low as suspicious. The COVID low was the buy of the decade. So yes, it's cautious the way a man on his third divorce is cautious about second dates: not always right, but you
understand where it's coming from. Volatility can also fake the green light
mid-bounce. Use it next to real market structure and your own judgment, both
of which are also flawed, but at least they're free.

It describes the emotional state of a market. It does not predict the future.
Neither do you. Neither do I (well, privately to myself I do). Now you have company.

This is an original reworking of the Coppock Curve - different periods, a log
construction, and a volatility-regime classifier bolted on from grief research,
not a stock indicator with the inputs nudged. Credit where due: Edwin Coppock
(1962), Maciejewski et al. (JAMA, 2007), and Stroebe & Schut.

Not financial advice. If you lose money using a grief indicator... I have nothing.

## Source Code

````pine
//@version=6
// ============================================================================
//  ACUTE GRIEF CURVE  ·  Cryptotwits  ·  Jon Morgan
//  A grief-recalibrated Coppock Curve.
//  Coppock (1962) priced market mourning at 11-14 months on the clergy's guess.
//  The Yale Bereavement Study (JAMA, 2007) measured acute grief peaking far
//  earlier: yearning ~4mo, depression ~6mo. A crowd grieves faster than a person,
//  so crypto bottoms map to the ACUTE phase, not the slow integration tail.
//    Acute Grief Curve = WMA5( logROC6 + logROC4 )
//  Signals (Dual Process Model, Stroebe & Schut):
//    ACCEPTANCE ONSET - curve turns up from below zero with volatility
//      CONTRACTING. Oscillation is damping: acceptance overtakes acute grief.
//    FALSE REPRIEVE - same turn-up but volatility is still EXPANDING. The
//      dead-cat bounce / pseudo-remission that feels like a bottom and isn't.
//  Not financial advice.
// ============================================================================
indicator("Acute Grief Curve [Cryptotwits]", "AGC", overlay = false)

// ----------------------------- Inputs --------------------------------------
grpP = "Grief periods (in months)"
depM  = input.int(6, "Depression peak  (long ROC)",  minval = 1, group = grpP, tooltip = "Yale 2007: depression peaks ~6 months after loss.")
yrnM  = input.int(4, "Yearning peak  (short ROC)",   minval = 1, group = grpP, tooltip = "Yearning peaks ~4 months after loss.")
smoM  = input.int(5, "Smoothing  (WMA = acute window)", minval = 1, group = grpP, tooltip = "Width of the acute-grief window.")
autoScale = input.bool(true, "Auto-scale periods to chart timeframe", group = grpP, tooltip = "Periods are defined in MONTHS and converted to bars for the current timeframe (≈×4.35 on weekly, ≈×30.4 on daily). Turn off to treat the numbers above as raw bar counts.")

grpM = "Method"
useLog = input.bool(true, "Use log price (recommended for crypto)", group = grpM, tooltip = "Rate-of-change on log price so multi-order-of-magnitude growth doesn't pin the curve above zero. Off = standard percentage Coppock.")

grpV = "Reprieve filter  (Dual Process Model)"
useFilter = input.bool(true, "Enable reprieve filter", group = grpV, tooltip = "Splits each turn-up into Acceptance Onset (volatility contracting) vs False Reprieve (volatility expanding).")
volM     = input.int(3, "Volatility window (months)",   minval = 1, group = grpV)
volLagM  = input.int(3, "Volatility lookback (months)", minval = 1, group = grpV, tooltip = "Compares current volatility to its level this many months ago. Contracting = acceptance.")
shadeVol = input.bool(true, "Shade background by volatility regime", group = grpV)

grpC = "Comparison curves"
showStd = input.bool(false, "Show Standard Coppock (11-14mo 'clergy')", group = grpC)
showInt = input.bool(false, "Show Integration curve (12-24mo, too slow for crypto)", group = grpC)

grpS = "Signals"
showOnPrice = input.bool(true, "Show signals on price chart", group = grpS, tooltip = "Plots signal markers on price via force_overlay.")

// --------------------------- Period scaling --------------------------------
secPerMonth  = 30.4375 * 24.0 * 60.0 * 60.0
barsPerMonth = timeframe.in_seconds() > 0 ? secPerMonth / timeframe.in_seconds() : 1.0
scale = autoScale ? barsPerMonth : 1.0
f_p(months) => math.max(2, int(math.round(months * scale)))

depLen = f_p(depM)
yrnLen = f_p(yrnM)
smoLen = f_p(smoM)
volWin = f_p(volM)
volLag = f_p(volLagM)

// ------------------------------ Core math ----------------------------------
f_roc(src, len) => useLog ? 100.0 * (math.log(src) - math.log(src[len])) : ta.roc(src, len)
f_cop(src, longLen, shortLen, wmaLen) => ta.wma(f_roc(src, longLen) + f_roc(src, shortLen), wmaLen)

agc      = f_cop(close, depLen, yrnLen, smoLen)
stdCurve = showStd ? f_cop(close, f_p(14), f_p(11), f_p(10)) : na
intCurve = showInt ? f_cop(close, f_p(24), f_p(12), f_p(10)) : na

// ------------------------- Reprieve filter ---------------------------------
lr  = math.log(close / close[1])
vol = ta.stdev(lr, volWin)
contracting = vol < vol[volLag]

// ---------------------------- Signal logic ---------------------------------
dNow  = agc - agc[1]
dPrev = agc[1] - agc[2]
turnedUp  = dNow > 0 and dPrev <= 0            // local trough on the curve
belowZero = agc[1] < 0
rawTurn   = turnedUp and belowZero and not na(agc) and not na(agc[2])

acceptanceOnset = rawTurn and (not useFilter or contracting)
falseReprieve   = rawTurn and useFilter and not contracting

// ------------------------------- Plots -------------------------------------
hline(0, "Zero", color = color.new(color.gray, 0))

cBlue  = color.new(#2563EB, 0)
pCurve = plot(agc, "Acute Grief Curve", color = cBlue, linewidth = 2)
pZero  = plot(0, "", display = display.none)
fill(pCurve, pZero, color = agc < 0 ? color.new(#2563EB, 88) : na, title = "Acute grief territory")

plot(stdCurve, "Standard Coppock", color = color.new(#9AA4B2, 0), linewidth = 1)
plot(intCurve, "Integration",      color = color.new(#64748B, 0), linewidth = 1)

bgcolor(shadeVol and useFilter ? (contracting ? color.new(color.teal, 90) : color.new(color.red, 92)) : na, title = "Volatility regime")

// signals in the oscillator pane
plotshape(acceptanceOnset, "Acceptance Onset", style = shape.triangleup, location = location.bottom, color = color.new(#16A34A, 0), size = size.small)
plotshape(falseReprieve,   "False Reprieve",   style = shape.triangleup, location = location.bottom, color = color.new(#EA8C00, 0), size = size.tiny)

// signals forced onto price
plotshape(showOnPrice and acceptanceOnset, "Acceptance Onset (price)", style = shape.triangleup, location = location.belowbar, color = color.new(#16A34A, 0), size = size.small, text = "Acceptance Onset", force_overlay = true)
plotshape(showOnPrice and falseReprieve,   "False Reprieve (price)",   style = shape.circle,     location = location.belowbar, color = color.new(#EA8C00, 0), size = size.tiny,  text = "False Reprieve",   force_overlay = true)

// ------------------------------ Alerts -------------------------------------
alertcondition(acceptanceOnset, "AGC: Acceptance Onset", "Acute Grief Curve turned up from below zero with volatility contracting — acceptance overtaking acute grief.")
alertcondition(falseReprieve,   "AGC: False Reprieve",   "Acute Grief Curve turned up from below zero but volatility is still expanding — pseudo-remission / suspect bounce.")
alertcondition(rawTurn,         "AGC: Acute trough turn-up", "Acute Grief Curve turned up from below zero.")
````
