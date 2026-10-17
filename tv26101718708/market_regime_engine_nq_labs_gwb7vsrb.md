# Market Regime Engine [NQ Labs]

- url: https://www.tradingview.com/script/GWB7VsrB-Market-Regime-Engine-NQ-Labs/
- type: indicator
- pine_id: PUB;76a1a39db4414ad2b31571e1ef712050
- version: 1.0

## Description

[image]https://www.tradingview.com/x/GxrwBaYV/[/image]WHAT THIS ANSWERS
[url=https://www.tradingview.com/x/kqsyflBt/]https://www.tradingview.com/x/kqsyflBt/[/url]
Almost every indicator tells you WHAT the market is doing. Very few tell you
whether the current market has enough exploitable structure to be worth
risking money on at all. The Market Regime Engine is built for that second
question: should I be trading this right now, and if so, what style of
approach do current conditions actually favour?

It is not a signal generator. It produces no entries. It is a filter you run
underneath whatever you already trade.

[image]https://www.tradingview.com/x/okwVXLOL/[/image]
WHY IT IS BUILT THIS WAY

Two design decisions separate this from a conventional regime or trend filter.

1. EVERY AXIS IS PERCENTILE-RANKED AGAINST ITS OWN HISTORY.

Most regime tools use fixed thresholds - an ADX of 25, an ATR multiplier of 3.
Those numbers are calibrated to whatever the author tested on. They are the
reason a tool behaves sensibly on one instrument and nonsensically on the
next. Here, each axis is ranked against its own recent distribution on the
current symbol and timeframe, so a 65th-percentile reading carries the same
meaning on a crypto pair as it does on an FX major. Nothing needs retuning
per market.

2. THE THREE AXES ARE ORTHOGONAL BY DESIGN.

Many "confluence" tools stack three views of momentum and present the
agreement as confirmation. Correlated inputs agreeing is not evidence. These
three measure genuinely different properties:

  DIRECTIONAL EFFICIENCY - net distance travelled divided by the total path
  walked to get there. A value near 1 is a straight line. A value near 0 means
  price ended where it started after a great deal of work. This is the most
  direct available answer to "is there a trend here", and it is independent of
  direction.

  VOLATILITY STATE - ATR ranked against its own history. Not "is volatility
  high" in absolute terms, but "is volatility high for this instrument".

  RETURN PERSISTENCE - lag-1 autocorrelation of log returns. Positive means an
  up bar tends to be followed by an up bar, so momentum approaches have
  something to work with. Negative means the market reverts. Near zero means
  returns carry no usable memory.


THE SCORING LOGIC

The Tradeability Score (0-100) rests on one idea:

  Efficiency is the signal. Volatility is the cost of being wrong.
  Volatility only hurts you when there is no direction to exploit.

So the noise penalty is the product of how little direction exists and how
violent the market is. It approaches zero inside a strong trend no matter how
wild conditions get - because volatility inside a trend is opportunity, not
noise - and it peaks precisely where traders are most reliably ground down:
low efficiency combined with high volatility. That specific combination is
what the engine exists to flag.

[url=https://www.tradingview.com/x/GxrwBaYV/]https://www.tradingview.com/x/GxrwBaYV/[/url]

THE FIVE REGIMES

  TREND          Efficiency high. Directional. Follow it.
  VOLATILE CHOP  Efficiency low, volatility high. No direction, maximum cost
                 of being wrong. The state that does the damage.
  COIL           Efficiency low, volatility low. Compression. Wait.
  RANGE          Efficiency low, volatility middling. Edges are tradeable.
  TRANSITION     Efficiency mid-range. No clean read. Reduce size.

A raw regime read must hold for a configurable number of consecutive bars
before it is confirmed. Without that filter, readings that straddle a
threshold flip back and forth for single bars.

[url=https://www.tradingview.com/x/okwVXLOL/]https://www.tradingview.com/x/okwVXLOL/[/url]
REGIME MATURITY - THE PART I HAVE NOT SEEN ELSEWHERE

The engine records the length of every completed regime run on the current
chart and reports the current run against that learned baseline, together with
the sample size behind it.

A trend at 0.3x its typical duration and a trend at 2.4x are not the same
trade, even though every conventional indicator prints the identical reading
for both. A compression that has lasted three times longer than compressions
normally last on this instrument is a different proposition to one that
started six bars ago.

The sample size (n=) is shown deliberately. Below the configured threshold the
cell dims, because a baseline built from two observations is not evidence and
should not be dressed up as though it were.


HOW TO USE IT

The engine is a gate, not a trigger. The intended workflow:

1. Read the Verdict first. STAND DOWN means your edge, whatever it is, is
   probably not present. The most valuable output of this tool is the trades
   it talks you out of.

2. Read the Regime and Favoured Style. Trend-following systems belong in
   TREND. Mean-reversion belongs in RANGE, and only when Persistence confirms
   the market is actually reverting rather than merely quiet. COIL means the
   setup has not arrived yet. VOLATILE CHOP means nothing you own works here.

3. Read Persistence before choosing an approach. If it reads Random, the
   market has no memory to exploit in either direction, and both momentum and
   mean-reversion are coin flips.

4. Use vs Typical for position management, not entry. An extended regime is
   not a reversal signal. It is a reason to stop adding and to tighten what
   you already hold.

5. Let the ribbon and score do the work on the price chart. The dashboard can
   be forced onto the main pane so the engine occupies a pane without costing
   you chart real estate.


SETTINGS THAT ACTUALLY MATTER

RANKING LOOKBACK is the important one. It must span several complete regime
cycles on your timeframe or every axis will rank near the middle and
everything will read TRANSITION. 250 bars on a daily chart is roughly a year -
a real baseline. 250 bars on a 5-minute chart is under a day, and is not.
On intraday timeframes, raise it substantially.

MINIMUM REGIME RUN trades responsiveness for stability. Higher values give a
calmer read and a cleaner duration baseline at the cost of confirming changes
later. Set it to 1 to see the unfiltered classification.

CHOP PENALTY controls how hard low-efficiency volatility is punished. Set it
to 0 and the score becomes pure efficiency rank.

EFFICIENCY and VOLATILITY thresholds are percentiles, not raw values. They do
not need adjusting per instrument. That is the point.


LIMITATIONS - STATED PLAINLY

- This is a lagging, descriptive tool. It classifies conditions that have
  already formed. It does not forecast, and it cannot tell you a regime is
  about to end.

- Confirmation costs lag. A genuine regime change registers a few bars late by
  design. That is the price of not flickering.

- The maturity baseline is learned from visible chart history and rebuilds
  whenever settings, symbol, or timeframe change. It is not persistent memory.
  Early in a chart, or for a rarely-occurring regime, the sample is thin. The
  n= value tells you when to discount it.

- On intraday equity charts, overnight gaps inflate ATR and distort the
  persistence reading. Daily and above, or extended hours, handle this better.

- Autocorrelation is a weak statistic on short samples. Persistence readings
  close to zero should be read as "no information", not as a subtle signal.

- Efficiency is directionless. TREND tells you a trend exists, not which way
  it points. Pair it with something that reads direction.

- No regime classification is correct at the moment it matters most, which is
  the turn. Nothing here changes that.


This script is open-source. Read the code, disagree with it, improve it.

This is an analytical tool for studying market conditions. It is not financial
advice, and it does not generate trade recommendations. Trading involves risk
of loss.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NQ_Labs

//@version=6
indicator("Market Regime Engine [NQ Labs]", shorttitle="MRE [NQ]", overlay=false, max_bars_back=2000)

// ============================================================================
//  MARKET REGIME ENGINE - NQ Labs
//
//  Answers one question: SHOULD I BE TRADING THIS RIGHT NOW?
//
//  Most indicators tell you WHAT the market is doing. None of them tell you
//  whether the current market has enough exploitable structure to be worth
//  risking money on. This engine classifies the market state and scores how
//  tradeable it currently is.
//
//  THREE ORTHOGONAL AXES (deliberately measuring different things, not three
//  views of the same thing):
//    1. DIRECTIONAL EFFICIENCY - net travel vs total path. Is price going
//       somewhere, or covering the same ground repeatedly?
//    2. VOLATILITY STATE       - ATR relative to its own history. How
//       expensive is being wrong right now?
//    3. RETURN PERSISTENCE     - lag-1 autocorrelation of log returns.
//       Positive = this market follows through. Negative = it reverts.
//
//  EVERY AXIS IS PERCENTILE-RANKED AGAINST ITS OWN HISTORY on the current
//  instrument. Fixed thresholds are the reason most regime tools work on one
//  market and fail on the next. A 65th-percentile reading means the same
//  thing on BTC as it does on EURUSD.
//
//  SCORING LOGIC:
//    Efficiency is the signal. Volatility is the cost of being wrong.
//    Volatility only hurts you when there is no direction to exploit, so the
//    penalty scales with the ABSENCE of efficiency rather than being applied
//    flat. High volatility inside a strong trend is opportunity, not noise.
//
//  REGIME CONFIRMATION:
//    A raw regime read must hold for N consecutive bars before it is accepted.
//    Without this, readings near a threshold flip back and forth for single
//    bars, which both flickers the display and poisons the duration baseline
//    below with meaningless 1-bar runs.
//
//  REGIME MATURITY:
//    The engine records how long each CONFIRMED regime has historically
//    persisted on this chart and reports the current run against that
//    baseline, along with the sample size behind it. A trend at 0.3x its
//    typical duration and a trend at 2.4x are not the same trade.
//
//  Open-source - Educational - Pine Script v6
// ============================================================================


// ---------------------------------------------------------------------------
//  INPUTS
// ---------------------------------------------------------------------------
grpCore = "Regime Detection"
erLen   = input.int(20,  "Efficiency Length",  minval=2,  group=grpCore, tooltip="Lookback for directional efficiency (net move / total path). Shorter = more reactive, noisier.")
atrLen  = input.int(14,  "ATR Length",         minval=1,  group=grpCore, tooltip="Lookback for the volatility axis.")
persLen = input.int(50,  "Persistence Length", minval=10, group=grpCore, tooltip="Lookback for return autocorrelation. Positive readings mean the market follows through; negative means it reverts.")
rankLen = input.int(250, "Ranking Lookback",   minval=50, group=grpCore, tooltip="History used to percentile-rank each axis. This is what makes the thresholds instrument-agnostic. Should span several complete regime cycles on your timeframe.")
minRun  = input.int(3,   "Minimum Regime Run", minval=1, maxval=20, group=grpCore, tooltip="A new regime must hold this many consecutive bars before it is confirmed. Filters single-bar flips near thresholds and keeps the duration baseline honest. Set to 1 to disable.")

grpThr = "Thresholds (percentile ranks)"
erHi   = input.int(65, "Efficiency HIGH above", minval=51, maxval=99, group=grpThr)
erLo   = input.int(35, "Efficiency LOW below",  minval=1,  maxval=49, group=grpThr)
volHi  = input.int(65, "Volatility HIGH above", minval=51, maxval=99, group=grpThr)
volLo  = input.int(35, "Volatility LOW below",  minval=1,  maxval=49, group=grpThr)

grpScore = "Tradeability Score"
chopPen  = input.float(0.6, "Chop Penalty", minval=0.0, maxval=1.0, step=0.05, group=grpScore, tooltip="How hard to penalise volatility when efficiency is low. 0 = score is pure efficiency rank. 1 = maximum penalty for volatile chop.")
tradeThr = input.int(60, "Tradeable above",  minval=0, maxval=100, group=grpScore)
standThr = input.int(30, "Stand down below", minval=0, maxval=100, group=grpScore)

grpDisp  = "Display"
showDash = input.bool(true,  "Show Dashboard",              group=grpDisp)
dashPos  = input.string("Top Right", "Dashboard Position",  options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=grpDisp)
minSample = input.int(5, "Trust baseline after N runs", minval=1, group=grpDisp, tooltip="The 'vs Typical' reading is dimmed until the engine has seen this many completed runs of the current regime. Low sample sizes are not evidence.")
showRib  = input.bool(true,  "Show Regime Ribbon",          group=grpDisp)
colorBar = input.bool(false, "Colour Price Bars by Regime", group=grpDisp)

grpCol = "Colours"
cTrend = input.color(#00d9a3, "Trend",         group=grpCol)
cCoil  = input.color(#4d9fff, "Coil",          group=grpCol)
cRange = input.color(#8a94a6, "Range",         group=grpCol)
cChop  = input.color(#ff4d6d, "Volatile Chop", group=grpCol)
cTrans = input.color(#ffb84d, "Transition",    group=grpCol)

grpAlert = "Alerts"
aRegime  = input.bool(true, "Alert on regime change",            group=grpAlert)
aTrade   = input.bool(true, "Alert when market turns tradeable", group=grpAlert)
aStand   = input.bool(true, "Alert when conditions degrade",     group=grpAlert)


// ---------------------------------------------------------------------------
//  AXIS 1 - DIRECTIONAL EFFICIENCY
//  Net distance travelled divided by the total path walked to get there.
//  1.0 = a straight line. Near 0 = price ended where it started after a lot
//  of work. The single best answer to "is there a trend here".
// ---------------------------------------------------------------------------
netMove = math.abs(close - close[erLen])
pathLen = math.sum(math.abs(close - close[1]), erLen)
er      = pathLen > 0 ? netMove / pathLen : 0.0
erRank  = nz(ta.percentrank(er, rankLen), 50.0)


// ---------------------------------------------------------------------------
//  AXIS 2 - VOLATILITY STATE
//  ATR ranked against its own history. Not "is volatility high" in absolute
//  terms, but "is volatility high FOR THIS INSTRUMENT".
// ---------------------------------------------------------------------------
atrVal  = ta.atr(atrLen)
atrRank = nz(ta.percentrank(atrVal, rankLen), 50.0)


// ---------------------------------------------------------------------------
//  AXIS 3 - RETURN PERSISTENCE
//  Lag-1 autocorrelation of log returns. Positive means an up bar tends to be
//  followed by an up bar (momentum works here). Negative means reversion.
//  Near zero means returns are effectively random - no memory to exploit.
// ---------------------------------------------------------------------------
ret     = ta.change(math.log(close))
persist = nz(ta.correlation(ret, ret[1], persLen), 0.0)


// ---------------------------------------------------------------------------
//  RAW REGIME CLASSIFICATION
//    3 = TREND          efficiency high - directional, follow it
//    0 = VOLATILE CHOP  efficiency low + volatility high - the account killer
//    1 = COIL           efficiency low + volatility low - compression, wait
//    2 = RANGE          efficiency low, volatility middling - fade the edges
//    4 = TRANSITION     efficiency in the middle - no clean read
// ---------------------------------------------------------------------------
int rawRegime = erRank >= erHi ? 3 : erRank <= erLo and atrRank >= volHi ? 0 : erRank <= erLo and atrRank <= volLo ? 1 : erRank <= erLo ? 2 : 4


// ---------------------------------------------------------------------------
//  REGIME CONFIRMATION
//  Track how long the raw read has been stable. Only accept a new regime once
//  it has held for minRun consecutive bars. This is what stops threshold-
//  straddling readings from generating junk 1-bar runs.
// ---------------------------------------------------------------------------
var int rawRun = 1
if bar_index > 0
    rawRun := rawRegime == rawRegime[1] ? rawRun + 1 : 1

var int regime = 4
if rawRun >= minRun and rawRegime != regime
    regime := rawRegime


// ---------------------------------------------------------------------------
//  TRADEABILITY SCORE (0-100)
//  Efficiency is the signal; volatility is the cost of being wrong. The noise
//  cost is the product of "how little direction there is" and "how violent the
//  market is" - so it approaches zero inside a strong trend no matter how wild
//  the market gets, and peaks exactly where traders actually get destroyed.
// ---------------------------------------------------------------------------
noiseCost = ((100.0 - erRank) / 100.0) * (atrRank / 100.0) * 100.0
score     = math.max(0.0, math.min(100.0, erRank - noiseCost * chopPen))


// ---------------------------------------------------------------------------
//  REGIME MATURITY
//  Bank the length of every completed CONFIRMED run, then report the current
//  run against the historical average for that same regime. runs = the sample
//  size behind that average, surfaced in the dashboard so the number can be
//  weighed rather than trusted blindly.
// ---------------------------------------------------------------------------
var regSum   = array.new<float>(5, 0.0)
var regCount = array.new<float>(5, 0.0)
var int curDur = 1

if bar_index > 0
    if regime != regime[1]
        int prev = nz(regime[1], 4)
        array.set(regSum, prev, array.get(regSum, prev) + curDur)
        array.set(regCount, prev, array.get(regCount, prev) + 1.0)
        curDur := 1
    else
        curDur := curDur + 1

float runs   = array.get(regCount, regime)
float typDur = runs > 0 ? array.get(regSum, regime) / runs : na
float matur  = na(typDur) or typDur <= 0 ? na : curDur / typDur


// ---------------------------------------------------------------------------
//  LABELS AND VERDICT
// ---------------------------------------------------------------------------
regName = switch regime
    3 => "TREND"
    0 => "VOLATILE CHOP"
    1 => "COIL"
    2 => "RANGE"
    => "TRANSITION"

regCol = switch regime
    3 => cTrend
    0 => cChop
    1 => cCoil
    2 => cRange
    => cTrans

favoured = switch regime
    3 => "Trend-follow / hold winners"
    0 => "Nothing. Sit this one out."
    1 => "Wait for the breakout"
    2 => persist < -0.05 ? "Mean-revert / fade edges" : "Range edges, small size"
    => "Reduce size, wait for confirmation"

verdict = score >= tradeThr ? "TRADE" : score <= standThr ? "STAND DOWN" : "CAUTION"
vCol    = score >= tradeThr ? cTrend : score <= standThr ? cChop : cTrans
persTxt = persist > 0.05 ? "Follows through" : persist < -0.05 ? "Reverts" : "Random"


// ---------------------------------------------------------------------------
//  PLOTS
// ---------------------------------------------------------------------------
plot(score, "Tradeability", color=regCol, linewidth=2)
hline(tradeThr, "Tradeable", color=color.new(color.teal, 55), linestyle=hline.style_dashed)
hline(standThr, "Stand Down", color=color.new(color.red, 55), linestyle=hline.style_dashed)
bgcolor(showRib ? color.new(regCol, 88) : na, title="Regime Ribbon")
barcolor(colorBar ? regCol : na, title="Regime Bar Colour")


// ---------------------------------------------------------------------------
//  DASHBOARD
// ---------------------------------------------------------------------------
posMap = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : dashPos == "Middle Right" ? position.middle_right : position.top_right

var table dash = table.new(posMap, 2, 10, border_width=1, frame_width=1, frame_color=color.new(color.gray, 60), force_overlay=true)

hdrBg  = color.new(#0d2b45, 15)
rowBgA = color.new(color.black, 72)
rowBgB = color.new(color.black, 82)

if showDash and barstate.islast
    erCol  = erRank >= erHi ? cTrend : erRank <= erLo ? cChop : color.white
    volCol = atrRank >= volHi ? cTrans : atrRank <= volLo ? cCoil : color.white
    pCol   = math.abs(persist) > 0.05 ? cTrend : color.new(color.white, 30)
    thin   = runs < minSample
    matTxt = na(matur) ? "no history yet" : str.tostring(matur, "#.#") + "x typical (n=" + str.tostring(runs, "#") + ")"
    matCol = na(matur) ? color.new(color.white, 45) : thin ? color.new(color.white, 55) : matur >= 1.5 ? cTrans : color.white

    table.cell(dash, 0, 0, "NQ LABS", text_color=color.white, text_size=size.small, bgcolor=hdrBg)
    table.cell(dash, 1, 0, "REGIME ENGINE", text_color=#00d9a3, text_size=size.small, bgcolor=hdrBg)
    table.cell(dash, 0, 1, "Regime", text_color=color.white, text_size=size.small, bgcolor=rowBgA)
    table.cell(dash, 1, 1, regName, text_color=regCol, text_size=size.small, bgcolor=rowBgA)
    table.cell(dash, 0, 2, "Verdict", text_color=color.white, text_size=size.small, bgcolor=rowBgB)
    table.cell(dash, 1, 2, verdict, text_color=vCol, text_size=size.small, bgcolor=rowBgB)
    table.cell(dash, 0, 3, "Tradeability", text_color=color.white, text_size=size.small, bgcolor=rowBgA)
    table.cell(dash, 1, 3, str.tostring(score, "#") + " / 100", text_color=vCol, text_size=size.small, bgcolor=rowBgA)
    table.cell(dash, 0, 4, "Favoured style", text_color=color.white, text_size=size.small, bgcolor=rowBgB)
    table.cell(dash, 1, 4, favoured, text_color=color.white, text_size=size.small, bgcolor=rowBgB)
    table.cell(dash, 0, 5, "Efficiency", text_color=color.white, text_size=size.small, bgcolor=rowBgA)
    table.cell(dash, 1, 5, str.tostring(erRank, "#") + " pctl", text_color=erCol, text_size=size.small, bgcolor=rowBgA)
    table.cell(dash, 0, 6, "Volatility", text_color=color.white, text_size=size.small, bgcolor=rowBgB)
    table.cell(dash, 1, 6, str.tostring(atrRank, "#") + " pctl", text_color=volCol, text_size=size.small, bgcolor=rowBgB)
    table.cell(dash, 0, 7, "Persistence", text_color=color.white, text_size=size.small, bgcolor=rowBgA)
    table.cell(dash, 1, 7, persTxt + " (" + str.tostring(persist, "#.##") + ")", text_color=pCol, text_size=size.small, bgcolor=rowBgA)
    table.cell(dash, 0, 8, "Duration", text_color=color.white, text_size=size.small, bgcolor=rowBgB)
    table.cell(dash, 1, 8, str.tostring(curDur) + " bars", text_color=color.white, text_size=size.small, bgcolor=rowBgB)
    table.cell(dash, 0, 9, "vs Typical", text_color=color.white, text_size=size.small, bgcolor=rowBgA)
    table.cell(dash, 1, 9, matTxt, text_color=matCol, text_size=size.small, bgcolor=rowBgA)


// ---------------------------------------------------------------------------
//  ALERTS
// ---------------------------------------------------------------------------
bool xUp     = ta.crossover(score, tradeThr)
bool xDown   = ta.crossunder(score, standThr)
bool regFlip = bar_index > 0 and regime != regime[1]

if aRegime and regFlip
    alert("NQ Labs MRE: Regime changed to " + regName + " on " + syminfo.ticker, alert.freq_once_per_bar_close)
if aTrade and xUp
    alert("NQ Labs MRE: Conditions now tradeable (" + regName + ") on " + syminfo.ticker, alert.freq_once_per_bar_close)
if aStand and xDown
    alert("NQ Labs MRE: Conditions degraded - stand down on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
