# Quorum

- url: https://www.tradingview.com/script/a90XXJI0-Quorum/
- type: indicator
- pine_id: PUB;32f8a7b538af4284a02835d68df073b7
- version: 3.0

## Description

[b]Introduction[/b]

Quorum is a single TradingView overlay built to answer one question: do several independent reads agree right now? Most losses come from acting on a lone oscillator. Quorum withholds a full-stack entry until votes, trend, and stretch line up.

It is original work inspired by two public workflows. The vote-and-stack idea follows the IADSS demo (confluence, trend, optimised trend, mean reversion). The tight lime/magenta trail is a SuperTrend — the same family of tool as Ivan on Tech’s MoneyLine, not a copy of unpublished settings.

Nothing in Quorum uses fundamentals, on-chain data, or a vendor’s secret basket. Every input is visible in Settings. Style presets change thresholds only; they do not change the formulas.

[b]The four layers[/b]

[b]1. Confluence basket[/b]

Five named votes. A buy vote and a sell vote are counted separately each bar.

[list=1]
[*]RSI — turning up from an oversold threshold, or down from overbought.
[*]MACD histogram — rising while positive, or falling while negative.
[*]Stochastic — sitting in the same extreme band as RSI.
[*]EMA side — vote-EMA fast above or below vote-EMA slow (defaults 21 / 55).
[*]Bollinger %B — price in the lower or upper slice of the band.
[/list]

Unconfirmed flags need 3 of 5 votes this bar. Confirmed flags usually need 4 of 5 and a second hit inside the confirmation window (default 5 bars). Bias (Bullish / Neutral / Bearish) only shifts the RSI and Stochastic thresholds so you can overlay a macro view.

[b]2. Trend[/b]

Two engines, chosen in Settings → Trend.

SuperTrend (tight) — default. An ATR trailing stop. Lime line under price = uptrend. Magenta line over price = downtrend. It hugs swings the way MoneyLine does. ATR length default 10, multiplier default 2.0. Lower the multiplier (about 1.5) for a tighter trail and more flips; raise it (about 3.0) to ignore noise.

EMA Ribbon — slower two-line fill. Fast vs slow EMA with a style tightness multiplier. Teal fill = up, orange = down. Use the EMA preset (Scalp 8/21, Intraday 13/34, Swing 20/50, Daily 21/55, Weekly 10/30) or type lengths by hand. On a daily chart a length of 21 means 21 days.

[b]3. Optimized Trend[/b]

Six fixed EMAs (8, 13, 21, 34, 55, 89) are scored over the lookback (default 250 bars) with a simple return-to-volatility proxy. The winning pair is plotted blue / purple. Blue above purple = adaptive uptrend. This is a small stand-in for IADSS’s per-asset length search, not their unpublished table.

[b]4. Mean reversion[/b]

Z-score of close versus a rolling mean (default 50). A signal prints only when price was beyond ±σ and then turns back through that band — not on the first poke. Style sets σ from 1.0 (Very Aggressive) to 2.0 (Very Conservative). Noise suppression skips a new dot if another printed within N bars.

[b]What each signal means[/b]

[b]Unconfirmed vote[/b]

Tiny washed-out lime triangle up, or tiny washed-out red triangle down.

Enough votes this bar, not yet held across the confirmation window. Watch only.

[b]Confirmed BUY / SELL[/b]

Solid lime triangle with BUY, or solid red triangle with SELL.

The basket agreed and persisted. This is a vote signal only — trend and stretch may still disagree.

[b]MR buy[/b]

Tiny lime dot below the bar.

Z-score was stretched down and turned back up through −σ. Snap-back, not a trend entry.

[b]MR sell[/b]

Tiny red dot above the bar.

Z-score was stretched up and turned back down through +σ.

[b]Stack buy[/b]

Aqua diamond below the bar.

Full rule: confirmed BUY + trend up + optimized trend up + (MR buy or z still below 0). Intended long.

[b]Stack sell[/b]

Fuchsia diamond above the bar.

Full rule: confirmed SELL + both trends down + (MR sell or z still above 0). Intended exit / short bias.

[b]SuperTrend lime[/b]

Thick lime line under price.

Trail is below the close. Uptrend for the stack filter.

[b]SuperTrend magenta[/b]

Thick magenta line over price.

Trail is above the close. Downtrend for the stack filter.

[b]Trend ribbon[/b]

Teal or orange EMA fill.

Only when engine = EMA Ribbon. Teal = up, orange = down.

[b]Opt trend lines[/b]

[b]Blue and purple EMAs.[/b]

Winning adaptive pair. Used as the second trend filter on diamonds.
The mini backtest on the dashboard counts only stack diamonds: long on stack buy, flat on stack sell, one unit, no fees. It is a sanity check, not a broker report.

[b]How to read a chart[/b]

[list=1]
[*]Colour of the SuperTrend (or ribbon) sets allowed direction.
[*]Ignore faint triangles.
[*]Note a solid BUY or SELL as “the basket woke up.”
[*]Wait for a diamond in that same direction, or skip the bar.
[*]If SuperTrend and Optimized Trend disagree, Quorum will not print a diamond. That is by design.
[/list]

A confirmed SELL while the SuperTrend is still lime is a warning, not an automatic short. A stack sell is the actual “get out / flip” mark.

[b]Settings that change behaviour[/b]

[b]Trading style[/b] — Very Aggressive through Very Conservative. Moves RSI/Stoch bands, Bollinger extremes, MR σ, ribbon tightness, and votes needed for a confirmed flag.

[b]Bias[/b] — Bullish raises the buy threshold so longs come easier; Bearish does the opposite. Neutral leaves the map alone.

[b]Trend engine[/b] — SuperTrend vs EMA Ribbon.

[b]EMA preset [/b]— only used in Ribbon mode.

[b]SuperTrend ATR length / mult [/b]— tightness of the MoneyLine-style trail.

[b]Opt lookback [/b]— how many bars score the adaptive pair.

[b]MR mean length / noise suppression[/b] — stretch window and dot spacing.
Display toggles — hide any layer. Backtest start sets when the dashboard starts counting trades.

[b]Alerts[/b]

Confirmed buy / sell, Stack buy / sell, MR buy / sell turn, Trend flip up / down. Create the alert from the chart clock and pick the Quorum condition you want.

[b]Honest limits[/b]

Optimized Trend searches twelve fixed pairs, not a large historical grid. The dashboard ignores costs, slippage, and shorts. No indicator replaces position sizing or a written plan.

Suggested first pass: Neutral / Neutral style, SuperTrend on, ATR 10 × 2.0, start on the 4-hour chart, act only on diamonds

## Source Code

````pine
//@version=6
// Quorum — original decision overlay
// Combined: Confluence + Trend + Optimized Trend + Mean Reversion

indicator("Quorum", shorttitle="Quorum", overlay=true, max_labels_count=500, max_bars_back=5000)

grpS = "Style & Bias"
style = input.string("Neutral", "Trading style", options=["Very Aggressive", "Aggressive", "Neutral", "Conservative", "Very Conservative"], group=grpS,
     tooltip="Moves how extreme RSI / Stoch / Bollinger and mean-reversion need to be, and how many votes a confirmed flag needs. Start on Neutral. Aggressive = more signals. Conservative = fewer, cleaner flags.")
bias  = input.string("Neutral", "Bias", options=["Bullish", "Neutral", "Bearish"], group=grpS,
     tooltip="Shifts RSI and Stochastic thresholds only. Bullish makes longs easier to print. Bearish does the opposite. Neutral leaves the map alone. This is not a trend filter.")

grpC = "Confluence basket"
rsiLen    = input.int(14, "RSI length", minval=2, group=grpC,
     tooltip="Lookback for the RSI vote. 14 is standard. This vote fires when RSI turns up from the style oversold band or down from the overbought band.")
macdF     = input.int(12, "MACD fast", minval=2, group=grpC,
     tooltip="Fast EMA inside MACD. Leave at 12 unless you know why.")
macdS     = input.int(26, "MACD slow", minval=2, group=grpC,
     tooltip="Slow EMA inside MACD. Leave at 26 unless you know why.")
macdSig   = input.int(9,  "MACD signal", minval=2, group=grpC,
     tooltip="Signal smoothing of MACD. The vote uses the histogram: rising while positive = buy vote, falling while negative = sell vote.")
stochLen  = input.int(14, "Stochastic length", minval=2, group=grpC,
     tooltip="Stochastic lookback. Vote is on while %K sits in the same extreme band as RSI. It is a second momentum read, not a second trend.")
emaFast   = input.int(21, "Vote EMA fast", minval=2, group=grpC,
     tooltip="Fast EMA for the confluence vote only (fast above slow = buy vote). Separate from the Trend ribbon EMAs below.")
emaSlow   = input.int(55, "Vote EMA slow", minval=2, group=grpC,
     tooltip="Slow EMA for the confluence vote only. Defaults 21/55. Changing these does not change SuperTrend or the ribbon.")
bbLen     = input.int(20, "Bollinger length", minval=2, group=grpC,
     tooltip="Basis length for %B and for the optional cloud. Same bands either way.")
bbMult    = input.float(2.0, "Bollinger mult", step=0.1, group=grpC,
     tooltip="Width of the bands in standard deviations. 2.0 is classic. %B vote uses the lower/upper slice set by Trading style.")
confirmBars = input.int(5, "Confirmation window (bars)", minval=1, maxval=50, group=grpC,
     tooltip="Confirmed BUY/SELL needs enough votes this bar AND a second raw hit inside this many bars. Raise it to make solid triangles rarer.")

grpT = "Trend"
trendEngine = input.string("SuperTrend (tight)", "Trend engine", options=["SuperTrend (tight)", "EMA Ribbon"], group=grpT,
     tooltip="SuperTrend: one ATR trail under/over price. Lime = up, magenta = down. Best default. EMA Ribbon: two EMAs with a teal/orange fill. Slower, fewer flips. Use SuperTrend unless you specifically want a ribbon.")
tfPreset = input.string("Auto (this chart TF)", "EMA preset (Ribbon mode)", options=["Auto (this chart TF)", "Manual", "Scalp 8/21", "Intraday 13/34", "Swing 20/50", "Daily 21/55", "Weekly 10/30"], group=grpT,
     tooltip="Only used when Trend engine = EMA Ribbon. Auto picks lengths from this chart's timeframe: 5m→8/21, 1h→13/34, 4h→20/50, Daily→21/55, Weekly→10/30. Manual uses the two numbers below. Ignored when SuperTrend is on.")
tFastIn = input.int(20, "Trend fast EMA (Manual)", minval=2, group=grpT,
     tooltip="Shorter ribbon EMA. Used only if engine = EMA Ribbon and preset = Manual. Lower = tighter, more flips. Typical: 8 scalp, 13 intraday, 20 swing.")
tSlowIn = input.int(50, "Trend slow EMA (Manual)", minval=2, group=grpT,
     tooltip="Longer ribbon EMA. Used only if engine = EMA Ribbon and preset = Manual. Keep it about 2–3× the fast length (8/21, 13/34, 20/50).")
stAtrLen = input.int(10, "SuperTrend ATR length", minval=1, group=grpT,
     tooltip="How many bars ATR uses to size the trail. 10 is the usual default. Higher = smoother trail and later flips. Leave at 10 unless the line is too jumpy (raise) or too lazy (lower toward 7).")
stMult   = input.float(2.0, "SuperTrend ATR mult", minval=0.5, step=0.1, group=grpT,
     tooltip="Distance of the trail from price, in ATRs. This is the main tightness knob. 2.0 is balanced. ~1.5 hugs price (more flips, good on 1–5m). ~3.0 sits further away (fewer flips, swing).")

grpO = "Optimized Trend"
oLook = input.int(250, "Opt lookback (bars)", minval=50, group=grpO,
     tooltip="How many bars the adaptive EMA pair is scored over. 250 is a decent default. Shorter = the winning pair changes more often. Longer = more stable. Used only by the blue/purple lines.")

grpM = "Mean Reversion"
mrLen = input.int(50, "MR mean length", minval=5, group=grpM,
     tooltip="Window for the z-score mean. 50 is default. Dots fire when price was beyond ±σ and then turns back — not on the first poke. Higher = slower stretch, fewer dots.")
noiseSup = input.int(0, "Noise suppression (bars)", minval=0, maxval=100, group=grpM,
     tooltip="Minimum bars between mean-reversion dots. Stops a cluster of dots on the same swing. Raise it if dots are stacking.")

grpV = "Display"
showConf   = input.bool(true, "Show confluence triangles", group=grpV,
     tooltip="Solid BUY/SELL = confirmed basket. Faint triangles = enough votes this bar only. Watch faint, act on diamonds.")
showTrend  = input.bool(true, "Show trend ribbon / SuperTrend", group=grpV,
     tooltip="Draws whichever engine is selected above. Hiding it does not turn the trend filter off for stack diamonds.")
showOpt    = input.bool(true, "Show optimized trend", group=grpV,
     tooltip="Blue/purple adaptive EMA pair. Second trend filter on stack diamonds. Hiding it does not disable the filter.")
showMR     = input.bool(true, "Show MR dots on price", group=grpV,
     tooltip="Lime dot = stretch down then turn. Red dot = stretch up then turn. Snap-back marks, not trend entries.")
showBB     = input.bool(false, "Show Bollinger cloud", group=grpV,
     tooltip="Draws the same bands the %B vote already uses. Off by default. Hiding the cloud does not turn the vote off.")
showTable  = input.bool(true, "Show dashboard / mini backtest", group=grpV,
     tooltip="Votes, trend state, suggested ribbon lengths, and a no-fee stack-diamond count. Sanity check, not a broker report.")
btStart    = input.time(timestamp("2023-01-01"), "Backtest start", group=grpV,
     tooltip="Dashboard trade count starts on this date. Counts stack diamonds only: long on stack buy, flat on stack sell, one unit, no fees.")

rsiBuyBase  = style == "Very Aggressive" ? 40 : style == "Aggressive" ? 35 : style == "Neutral" ? 30 : style == "Conservative" ? 25 : 20
rsiSellBase = style == "Very Aggressive" ? 60 : style == "Aggressive" ? 65 : style == "Neutral" ? 70 : style == "Conservative" ? 75 : 80
bbBuyMax    = style == "Very Aggressive" ? 0.35 : style == "Aggressive" ? 0.25 : style == "Neutral" ? 0.20 : style == "Conservative" ? 0.12 : 0.08
bbSellMin   = 1.0 - bbBuyMax
mrSigma     = style == "Very Aggressive" ? 1.00 : style == "Aggressive" ? 1.25 : style == "Neutral" ? 1.50 : style == "Conservative" ? 1.75 : 2.00
tightMult   = style == "Very Aggressive" ? 0.70 : style == "Aggressive" ? 0.85 : style == "Neutral" ? 1.00 : style == "Conservative" ? 1.20 : 1.40
votesNeedUnc = 3
votesNeedCnf = style == "Very Aggressive" ? 3 : 4

rsiBuy  = bias == "Bullish" ? math.min(50, rsiBuyBase + 8) : bias == "Bearish" ? math.max(10, rsiBuyBase - 8) : rsiBuyBase
rsiSell = bias == "Bearish" ? math.max(50, rsiSellBase - 8) : bias == "Bullish" ? math.min(90, rsiSellBase + 8) : rsiSellBase
stochBuy  = rsiBuy
stochSell = rsiSell

rsi = ta.rsi(close, rsiLen)
[macdLine, macdSignal, macdHist] = ta.macd(close, macdF, macdS, macdSig)
stochK = ta.sma(ta.stoch(close, high, low, stochLen), 3)
emaF = ta.ema(close, emaFast)
emaS = ta.ema(close, emaSlow)
basis = ta.sma(close, bbLen)
dev   = bbMult * ta.stdev(close, bbLen)
bbUpper = basis + dev
bbLower = basis - dev
pctB  = dev == 0 ? 0.5 : (close - bbLower) / (2 * dev)

pBbBasis = plot(showBB ? basis : na, "BB basis", color=color.new(color.gray, 50), linewidth=1)
pBbUp    = plot(showBB ? bbUpper : na, "BB upper", color=color.new(color.teal, 70), linewidth=1)
pBbLo    = plot(showBB ? bbLower : na, "BB lower", color=color.new(color.orange, 70), linewidth=1)
fill(pBbUp, pBbLo, color=showBB ? color.new(color.silver, 85) : na, title="BB cloud")

voteRsiBuy  = rsi <= rsiBuy and rsi > rsi[1]
voteRsiSell = rsi >= rsiSell and rsi < rsi[1]
voteMacdBuy  = macdHist > 0 and macdHist > macdHist[1]
voteMacdSell = macdHist < 0 and macdHist < macdHist[1]
voteStoBuy  = stochK <= stochBuy
voteStoSell = stochK >= stochSell
voteEmaBuy  = emaF > emaS
voteEmaSell = emaF < emaS
voteBbBuy   = pctB <= bbBuyMax
voteBbSell  = pctB >= bbSellMin

buyVotes  = (voteRsiBuy ? 1 : 0) + (voteMacdBuy ? 1 : 0) + (voteStoBuy ? 1 : 0) + (voteEmaBuy ? 1 : 0) + (voteBbBuy ? 1 : 0)
sellVotes = (voteRsiSell ? 1 : 0) + (voteMacdSell ? 1 : 0) + (voteStoSell ? 1 : 0) + (voteEmaSell ? 1 : 0) + (voteBbSell ? 1 : 0)

rawBuy  = buyVotes  >= votesNeedUnc and buyVotes  > sellVotes
rawSell = sellVotes >= votesNeedUnc and sellVotes > buyVotes

buyCountWin  = math.sum(rawBuy ? 1 : 0, confirmBars)
sellCountWin = math.sum(rawSell ? 1 : 0, confirmBars)
confirmedBuy  = rawBuy  and buyCountWin  >= 2 and buyVotes  >= votesNeedCnf
confirmedSell = rawSell and sellCountWin >= 2 and sellVotes >= votesNeedCnf
unconfBuy  = rawBuy  and not confirmedBuy
unconfSell = rawSell and not confirmedSell

sec = timeframe.in_seconds()
autoFast = timeframe.ismonthly ? 8 : timeframe.isweekly ? 10 : timeframe.isdaily ? 21 : sec <= 5 * 60 ? 8 : sec <= 60 * 60 ? 13 : 20
autoSlow = timeframe.ismonthly ? 21 : timeframe.isweekly ? 30 : timeframe.isdaily ? 55 : sec <= 5 * 60 ? 21 : sec <= 60 * 60 ? 34 : 50
autoLabel = str.tostring(autoFast) + "/" + str.tostring(autoSlow)

tFast = tfPreset == "Auto (this chart TF)" ? autoFast : tfPreset == "Scalp 8/21" ? 8 : tfPreset == "Intraday 13/34" ? 13 : tfPreset == "Swing 20/50" ? 20 : tfPreset == "Daily 21/55" ? 21 : tfPreset == "Weekly 10/30" ? 10 : tFastIn
tSlow = tfPreset == "Auto (this chart TF)" ? autoSlow : tfPreset == "Scalp 8/21" ? 21 : tfPreset == "Intraday 13/34" ? 34 : tfPreset == "Swing 20/50" ? 50 : tfPreset == "Daily 21/55" ? 55 : tfPreset == "Weekly 10/30" ? 30 : tSlowIn

slowAdj = math.max(2, math.round(tSlow * tightMult))
trFast = ta.ema(close, tFast)
trSlow = ta.ema(close, int(slowAdj))
emaTrendUp = trFast > trSlow

atrST = ta.atr(stAtrLen)
srcST = hl2
upBand = srcST - stMult * atrST
dnBand = srcST + stMult * atrST

var float stLower = na
var float stUpper = na
var int   stDir = 1
stLower := na(stLower[1]) ? upBand : (close[1] > stLower[1] ? math.max(upBand, stLower[1]) : upBand)
stUpper := na(stUpper[1]) ? dnBand : (close[1] < stUpper[1] ? math.min(dnBand, stUpper[1]) : dnBand)
stDir := close > nz(stUpper[1]) ? 1 : close < nz(stLower[1]) ? -1 : nz(stDir[1], 1)
stLine = stDir == 1 ? stLower : stUpper
stTrendUp = stDir == 1

useST = trendEngine == "SuperTrend (tight)"
trendUp = useST ? stTrendUp : emaTrendUp
trendFlipUp   = trendUp and not trendUp[1]
trendFlipDown = not trendUp and trendUp[1]

pFast = plot(showTrend and not useST ? trFast : na, "Trend fast", color=color.new(color.teal, 40), linewidth=1)
pSlow = plot(showTrend and not useST ? trSlow : na, "Trend slow", color=color.new(color.orange, 40), linewidth=1)
fill(pFast, pSlow, color=showTrend and not useST ? (emaTrendUp ? color.new(color.teal, 80) : color.new(color.orange, 80)) : na, title="Trend fill")
plot(showTrend and useST ? stLine : na, "SuperTrend", color=stTrendUp ? color.new(color.lime, 0) : color.new(#ff00aa, 0), linewidth=3, style=plot.style_line)

ema8  = ta.ema(close, 8)
ema13 = ta.ema(close, 13)
ema21 = ta.ema(close, 21)
ema34 = ta.ema(close, 34)
ema55 = ta.ema(close, 55)
ema89 = ta.ema(close, 89)

scorePair(bool pos, int look) =>
    float rets = 0.0
    float sq = 0.0
    float n = 0.0
    for k = 1 to look
        r = (pos[k] ? 1.0 : 0.0) * (close[k-1] / close[k] - 1.0)
        rets += r
        sq += r * r
        n += 1.0
    mu = n == 0 ? 0.0 : rets / n
    vari = n == 0 ? 0.0 : math.max(sq / n - mu * mu, 0.0)
    vari == 0 ? mu * 100.0 : mu / math.sqrt(vari)

sc813  = scorePair(ema8  > ema13, oLook)
sc821  = scorePair(ema8  > ema21, oLook)
sc834  = scorePair(ema8  > ema34, oLook)
sc855  = scorePair(ema8  > ema55, oLook)
sc889  = scorePair(ema8  > ema89, oLook)
sc1321 = scorePair(ema13 > ema21, oLook)
sc1334 = scorePair(ema13 > ema34, oLook)
sc1355 = scorePair(ema13 > ema55, oLook)
sc1389 = scorePair(ema13 > ema89, oLook)
sc2134 = scorePair(ema21 > ema34, oLook)
sc2155 = scorePair(ema21 > ema55, oLook)
sc2189 = scorePair(ema21 > ema89, oLook)

bestScore = sc813
bestF = 8
bestS = 13
if sc821 > bestScore
    bestScore := sc821
    bestF := 8
    bestS := 21
if sc834 > bestScore
    bestScore := sc834
    bestF := 8
    bestS := 34
if sc855 > bestScore
    bestScore := sc855
    bestF := 8
    bestS := 55
if sc889 > bestScore
    bestScore := sc889
    bestF := 8
    bestS := 89
if sc1321 > bestScore
    bestScore := sc1321
    bestF := 13
    bestS := 21
if sc1334 > bestScore
    bestScore := sc1334
    bestF := 13
    bestS := 34
if sc1355 > bestScore
    bestScore := sc1355
    bestF := 13
    bestS := 55
if sc1389 > bestScore
    bestScore := sc1389
    bestF := 13
    bestS := 89
if sc2134 > bestScore
    bestScore := sc2134
    bestF := 21
    bestS := 34
if sc2155 > bestScore
    bestScore := sc2155
    bestF := 21
    bestS := 55
if sc2189 > bestScore
    bestScore := sc2189
    bestF := 21
    bestS := 89

optFast = bestF == 8 ? ema8 : bestF == 13 ? ema13 : ema21
optSlow = bestS == 13 ? ema13 : bestS == 21 ? ema21 : bestS == 34 ? ema34 : bestS == 55 ? ema55 : ema89
optUp = optFast > optSlow
optFlipUp   = optUp and not optUp[1]
optFlipDown = not optUp and optUp[1]

plot(showOpt ? optFast : na, "Opt fast", color=color.new(color.blue, 20), linewidth=2)
plot(showOpt ? optSlow : na, "Opt slow", color=color.new(color.purple, 30), linewidth=1)

mrMean = ta.sma(close, mrLen)
mrSd   = ta.stdev(close, mrLen)
z = mrSd == 0 ? 0.0 : (close - mrMean) / mrSd

mrBuyRaw  = z[1] <= -mrSigma and z > z[1] and z > -mrSigma
mrSellRaw = z[1] >=  mrSigma and z < z[1] and z <  mrSigma

var int barsSinceMrBuy = 999
var int barsSinceMrSell = 999
barsSinceMrBuy := mrBuyRaw[1] ? 0 : barsSinceMrBuy + 1
barsSinceMrSell := mrSellRaw[1] ? 0 : barsSinceMrSell + 1
mrBuy  = mrBuyRaw  and barsSinceMrBuy > noiseSup
mrSell = mrSellRaw and barsSinceMrSell > noiseSup

plotshape(showMR and mrBuy,  title="MR buy",  style=shape.circle, location=location.belowbar, color=color.new(color.lime, 0), size=size.tiny)
plotshape(showMR and mrSell, title="MR sell", style=shape.circle, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny)

plotshape(showConf and confirmedBuy,  title="Confirmed buy",  style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime, 0), size=size.small, text="BUY")
plotshape(showConf and unconfBuy,     title="Unconfirmed buy", style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime, 65), size=size.tiny)
plotshape(showConf and confirmedSell, title="Confirmed sell", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), size=size.small, text="SELL")
plotshape(showConf and unconfSell,    title="Unconfirmed sell",style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 65), size=size.tiny)

stackBuy  = confirmedBuy  and trendUp and optUp and (mrBuy or z < 0)
stackSell = confirmedSell and (not trendUp) and (not optUp) and (mrSell or z > 0)

plotshape(stackBuy,  title="Stack buy",  style=shape.diamond, location=location.belowbar, color=color.new(color.aqua, 0), size=size.small)
plotshape(stackSell, title="Stack sell", style=shape.diamond, location=location.abovebar, color=color.new(color.fuchsia, 0), size=size.small)

var float inPrice = na
var int   wins = 0
var int   losses = 0
var float pnlSum = 0.0
inTrade = not na(inPrice)
eligible = time >= btStart

if eligible and stackBuy and not inTrade
    inPrice := close
if eligible and stackSell and inTrade
    r = (close - inPrice) / inPrice
    pnlSum += r
    if r > 0
        wins += 1
    else
        losses += 1
    inPrice := na

closed = wins + losses
winPct = closed == 0 ? na : 100.0 * wins / closed
avgR   = closed == 0 ? na : 100.0 * pnlSum / closed

trendTxt = useST ? (trendUp ? "LIME up" : "MAGENTA dn") : (trendUp ? "TEAL up" : "ORANGE dn")
ribbonTxt = useST ? "ST " + str.tostring(stAtrLen) + "×" + str.tostring(stMult, "#.0") : str.tostring(tFast) + "/" + str.tostring(int(slowAdj)) + " (" + tfPreset + ")"

if barstate.islast and showTable
    t = table.new(position.top_right, 2, 14, bgcolor=color.new(color.black, 20), border_width=1)
    table.cell(t, 0, 0, "Quorum", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 0, style + " / " + bias, text_color=color.yellow, text_size=size.small)
    table.cell(t, 0, 1, "Buy votes", text_color=color.gray, text_size=size.tiny)
    table.cell(t, 1, 1, str.tostring(buyVotes) + " / 5", text_color=color.lime, text_size=size.tiny)
    table.cell(t, 0, 2, "Sell votes", text_color=color.gray, text_size=size.tiny)
    table.cell(t, 1, 2, str.tostring(sellVotes) + " / 5", text_color=color.red, text_size=size.tiny)
    table.cell(t, 0, 3, "Z-score", text_color=color.gray, text_size=size.tiny)
    table.cell(t, 1, 3, str.tostring(z, "#.00") + "  σ=" + str.tostring(mrSigma), text_color=color.white, text_size=size.tiny)
    table.cell(t, 0, 4, "Trend", text_color=color.gray, text_size=size.tiny)
    table.cell(t, 1, 4, trendTxt, text_color=trendUp ? color.teal : color.orange, text_size=size.tiny)
    table.cell(t, 0, 5, "Engine", text_color=color.gray, text_size=size.tiny)
    table.cell(t, 1, 5, ribbonTxt, text_color=color.white, text_size=size.tiny)
    table.cell(t, 0, 6, "TF suggest", text_color=color.gray, text_size=size.tiny)
    table.cell(t, 1, 6, autoLabel + " on " + timeframe.period, text_color=color.silver, text_size=size.tiny)
    table.cell(t, 0, 7, "Opt trend", text_color=color.gray, text_size=size.tiny)
    table.cell(t, 1, 7, optUp ? "BLUE up" : "PURPLE dn", text_color=optUp ? color.aqua : color.purple, text_size=size.tiny)
    table.cell(t, 0, 8, "Opt lens", text_color=color.gray, text_size=size.tiny)
    table.cell(t, 1, 8, str.tostring(bestF) + " / " + str.tostring(bestS), text_color=color.white, text_size=size.tiny)
    table.cell(t, 0, 9, "Stack longs", text_color=color.gray, text_size=size.tiny)
    table.cell(t, 1, 9, inTrade ? "IN @ " + str.tostring(inPrice, format.mintick) : "FLAT", text_color=inTrade ? color.aqua : color.gray, text_size=size.tiny)
    table.cell(t, 0, 10, "Closed trades", text_color=color.gray, text_size=size.tiny)
    table.cell(t, 1, 10, str.tostring(closed), text_color=color.white, text_size=size.tiny)
    table.cell(t, 0, 11, "Win %", text_color=color.gray, text_size=size.tiny)
    table.cell(t, 1, 11, na(winPct) ? "—" : str.tostring(winPct, "#.0") + "%", text_color=color.white, text_size=size.tiny)
    table.cell(t, 0, 12, "Avg trade", text_color=color.gray, text_size=size.tiny)
    table.cell(t, 1, 12, na(avgR) ? "—" : str.tostring(avgR, "#.20") + "%", text_color=color.white, text_size=size.tiny)
    table.cell(t, 0, 13, "Basket", text_color=color.gray, text_size=size.tiny)
    table.cell(t, 1, 13, "RSI MACD Stoch EMA BB", text_color=color.silver, text_size=size.tiny)

alertcondition(confirmedBuy,  "Confirmed buy",  "Quorum confirmed BUY")
alertcondition(confirmedSell, "Confirmed sell", "Quorum confirmed SELL")
alertcondition(stackBuy,  "Stack buy",  "Quorum STACK BUY (conf + trends up + MR/z support)")
alertcondition(stackSell, "Stack sell", "Quorum STACK SELL (conf + trends down + MR/z resistance)")
alertcondition(mrBuy,  "MR buy turn",  "Quorum mean-reversion buy turn")
alertcondition(mrSell, "MR sell turn", "Quorum mean-reversion sell turn")
alertcondition(trendFlipUp,   "Trend flip up",   "Quorum trend flipped UP")
alertcondition(trendFlipDown, "Trend flip down", "Quorum trend flipped DOWN")
````
