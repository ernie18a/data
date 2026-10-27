# UK BoE Policy Pressure - GB02Y vs Bank Rate

- url: https://www.tradingview.com/script/2AK5WNtN-UK-BoE-Policy-Pressure-GB02Y-vs-Bank-Rate/
- type: indicator
- pine_id: PUB;635af1bddf0947608389444c40ff7ee1
- version: 1.0

## Description

Why the 2-Year Matters — Does the Central Bank Follow the Market?

One of the ideas behind this indicator is a simple observation:

The 2-year government bond yield often appears to move before the central bank changes its official policy rate.

Looking at long historical charts can therefore create the impression that the Federal Reserve follows the US 2-year Treasury and that the Bank of England follows the UK 2-year gilt.

There is genuine evidence behind part of that observation, but the causal story is more interesting than simply saying “the central bank follows the 2-year.”

The 2-year yield is heavily influenced by expectations for where short-term interest rates will be over the coming couple of years. Investors continuously process inflation, employment, growth, central-bank speeches and anticipated policy decisions. Consequently, the 2-year yield can reprice long before an official rate decision occurs.

Federal Reserve Governor Christopher Waller has been particularly explicit about this relationship. In a 2023 speech he described the 2-year Treasury yield as “a good proxy for the stance of monetary policy” and used the 2021–22 tightening cycle as his example. The 2-year Treasury rose from roughly 0.25% in September 2021 to around 2% by the March 2022 FOMC meeting, even though the Fed had not yet begun raising its policy rate.

That is extremely relevant to what this indicator is attempting to measure.

The important twist: who is following whom?

Waller's explanation suggests something subtler than the Fed simply watching the 2-year Treasury and subsequently moving rates toward it.

The causal chain can operate like this:

Economic information → expected Fed/BoE reaction → central-bank communication → market repricing → 2-year yield moves → eventual policy decision

In other words, the bond market is attempting to anticipate the central bank's reaction function.

But central-bank communication simultaneously influences the bond market.

Waller has subsequently made this point very clearly. Discussing 2021–22, he explained that the Fed communicated that rate increases were coming, market rates responded, and the 2-year Treasury increased roughly 200 bp before the Fed had actually lifted rates from the effective lower bound. He argues that this meant financial tightening began before the official rate increases themselves.

So there is a feedback loop, rather than a simple leader/follower relationship:

Central bank → 2-year yield → financial conditions → economy → central bank

and simultaneously:

Economy → market expectations → 2-year yield → central bank

That helps explain why plotting the two series together can look remarkably like the policy rate is following the 2-year yield.

The Bank of England evidence

There is similar evidence in Bank of England communications, although the Bank generally discusses market-implied policy rates and OIS curves rather than claiming that it follows the 2-year gilt.

MPC member Catherine Mann has repeatedly discussed this relationship. In 2023 she explained that changes in market-implied policy curves represent investors' expectations about the path the MPC may need to take to achieve its inflation target. Those market curves are also important because they enter the Bank's forecasts as conditioning assumptions.

That creates another feedback mechanism:

Markets anticipate the MPC → the yield curve moves → those financial conditions affect the economy and the Bank's forecast → the MPC reacts to the resulting economic outlook.

Mann made the complication particularly clear in February 2025. She noted that the market-implied Bank Rate path had loosened by about 30 bp at the two-year horizon between the forecast conditioning window and the policy vote. But she cautioned that the move did not necessarily represent information about the UK economy: Bank analysis suggested that US spillovers had been an important driver of that repricing.

That qualification is very important for this indicator.

A large GB02Y–Bank Rate gap can contain useful information about expected policy, but it cannot automatically be interpreted as the market telling the MPC what to do.

The US can also move UK rates

There is another reason the relationship becomes particularly interesting.

Mann showed in 2022 that there can be a persistent difference between the UK market curve and surveyed expectations for Bank Rate. Market participants attributed part of that difference to expectations about international influences on UK monetary policy, alongside domestic factors and liquidity effects.

More recently, MPC member Megan Greene has explicitly examined 2-year yields when studying international monetary-policy spillovers. She describes surprise changes in US 2-year Treasury yields as a proxy for surprises in the Fed Funds rate and analyses how those shocks subsequently affect UK GDP and inflation.

This gives us another possible chain:

US data / Fed expectations → US 2Y → global rates → UK 2Y → UK financial conditions → UK economy/inflation → BoE decision

So sometimes the UK 2-year gilt may be telling us about expected Bank of England policy.

At other times it may partly be transmitting US/global financial conditions.

The Bank itself has recently emphasized the importance of this distinction. For example, its June 2026 policy minutes noted a substantial rise in UK two-year OIS rates alongside similar moves in US and euro-area rates, with rapid pass-through into borrowing costs for UK households and businesses.

What this indicator is testing

That leads directly to the purpose of the BoE Policy Pressure indicator.

Rather than assuming:

“GB02Y moved, therefore the BoE must follow.”

the script asks an empirical question:

When the UK 2-year yield becomes unusually far above or below Bank Rate, what has historically happened next?

The indicator therefore measures the current:

GB02Y − Bank Rate spread

and then asks four separate questions.

Magnitude: Is the gap large enough to matter — for example ±50 bp or ±100 bp?

Abnormality: Is the gap unusual relative to its own history, measured using the Z-score?

Persistence: Has the divergence remained in place rather than appearing for only a few days?

Historical response: Following comparable historical episodes, how often did Bank Rate subsequently move in the same direction, and what was the typical change?

That distinction is fundamental.

The indicator is not built on the claim that the MPC mechanically follows the gilt market. It tests whether unusually large and persistent divergences between market rates and Bank Rate have historically contained useful information about subsequent policy adjustments.

A useful way to think about the chart

When the orange UK 2-year yield moves substantially above the Bank Rate, the market may be pricing a higher future path for short-term rates than the current policy setting.

When it moves substantially below Bank Rate, markets may be pricing a lower future path.

The indicator then asks whether that difference is sufficiently large, statistically unusual and persistent to deserve attention. Your Pine script calculates the spread directly as gb02y - boe, measures its Z-score against a 252-day history by default, and applies persistence requirements before generating its UP/DOWN signals.

This is why the historical markers are useful. They allow the chart to show visually whether previous extreme divergences tended to precede actual BoE hikes or cuts rather than merely assuming that relationship exists.

The key takeaway

Perhaps the best description of the hypothesis is therefore:

The 2-year yield is not the central bank's boss. It is a real-time market estimate of where investors believe short-term rates are heading, incorporating both expected central-bank behaviour and information affecting that behaviour. Because markets can reprice immediately while official policy rates change only at scheduled meetings, the 2-year yield can appear to lead the policy rate.

There is unusually strong support for that interpretation from Waller's description of the US 2-year Treasury as a proxy for the stance of monetary policy. There is also substantial Bank of England discussion showing that market-implied short rates contain information about expected MPC policy and transmit rapidly into UK financial conditions.

At the same time, Bank of England policymakers have explicitly warned that UK market rates can be moved by US and international spillovers, so a divergence should not automatically be interpreted as a prediction of the next MPC decision.

That is ultimately what makes the indicator useful: instead of asserting that the BoE follows the 2-year gilt, it lets the historical data test how informative that apparent lead has actually been.

BoE Policy Pressure — UK 2-Year Gilt vs Bank Rate

This indicator compares the UK 2-Year Government Bond Yield (TVC:GB02Y) with the Bank of England Bank Rate (ECONOMICS:GBINTR) to show when market pricing moves materially away from the current policy rate. The script plots the 2-year gilt yield and Bank Rate on the main chart, then calculates the difference between them as:

$$ \text{Policy Gap} = \text{UK 2Y Yield} - \text{BoE Bank Rate} $$

A positive gap means the 2-year gilt is trading above Bank Rate. A negative gap means it is trading below Bank Rate. The indicator also plots a 20-day EMA of the gap to show whether the divergence is becoming persistent rather than being a short-lived move.

The script calculates a Z-score of the spread using a configurable lookback period, set to 252 trading days by default. This shows how unusual the current gap is relative to its own recent history. A Z-score near zero is relatively normal, while readings beyond approximately ±2 indicate a much more unusual divergence.

Policy-pressure signals

A live UP or DOWN pressure signal is only generated when several conditions agree:

the spread exceeds the selected minimum gap;
the Z-score exceeds the selected threshold;
the spread is moving on the correct side of its 20-day EMA;
the condition persists for the required number of trading days.

This is designed to reduce signals caused by brief market spikes. The default settings use a 50 bp minimum gap, an absolute Z-score of 1.0, and 10 trading days of persistence.

The chart distinguishes between STATE and SIGNAL. STATE describes the current raw divergence, such as a strong upward or downward gap. SIGNAL only confirms once the full persistence rules have been satisfied.

Historical comparison

The indicator also studies previous periods when the gap reached approximately:

+50 bp
+100 bp
−50 bp
−100 bp

A reset band is used so repeated movement around the same threshold is not counted as a large number of separate historical events.

For each comparable historical episode, the script checks whether the Bank of England subsequently moved Bank Rate in the same direction within 20 trading days and 60 trading days. It also records the median actual 60-day Bank Rate change following those comparable episodes.

These results are displayed as historical evidence only. A historical hit rate such as 80% means that 80% of the comparable historical cases contained a same-direction BoE move within that period. It should not be interpreted as an 80% probability of a future move.

Dashboard

An optional colour-coded dashboard can be displayed on the main price chart. It shows:

current UK 2-year yield;
current BoE Bank Rate;
current policy gap;
spread Z-score;
current market state;
live pressure signal;
signal persistence;
comparable historical regime;
number of historical episodes;
20-day and 60-day historical same-direction hit rates;
median 60-day Bank Rate change;
median historical 60-day rate level.

The dashboard is placed on the main chart even though the spread indicator itself is displayed in a separate lower pane. It can be switched on or off from the indicator settings.

Chart colours

Orange: UK 2-Year Gilt Yield
Black: Bank of England Bank Rate
Blue: UK 2-Year Yield minus Bank Rate
Orange line in lower pane: 20-day EMA of the policy gap
Red zones/signals: upward-rate pressure
Green zones/signals: downward-rate pressure

Actual historical BoE hikes and cuts can also be displayed on the lower chart for visual comparison with the spread signal.

How to interpret it

The purpose of the indicator is not to assume that the Bank of England mechanically follows the 2-year gilt. Instead, it measures the degree of tension between market-implied short-rate pricing and the current policy rate.

A simple way to read it is:

Gap above +50 bp: meaningful upward divergence.
Gap above +100 bp: large upward divergence.
Gap below −50 bp: meaningful downward divergence.
Gap below −100 bp: large downward divergence.
|Z| above 1: notable relative to recent history.
|Z| above 2: unusually large divergence.
UP/DOWN pressure: gap, Z-score, trend and persistence conditions all agree.

The historical statistics provide context about what the Bank of England did after similar past divergences, while the live signal focuses on whether the current divergence is large, unusual and persistent.

Important note

This is a market-policy pressure and historical comparison tool, not a guaranteed interest-rate forecast. The UK 2-year gilt yield reflects expectations about future policy, inflation, growth, risk premia, liquidity and other market factors. Small historical samples can also make percentage hit rates appear more precise than they really are.

The indicator is therefore best used as a framework for identifying and studying periods when the bond market and Bank Rate become unusually far apart.

## Source Code

````pine
//@version=6
indicator(
     "UK BoE Policy Pressure - GB02Y vs Bank Rate",
     shorttitle="BoE Policy Pressure",
     overlay=false,
     max_labels_count=500,
     max_bars_back=1500)

//=====================================================================
// 1. INPUTS
//=====================================================================

yieldSymbol = input.symbol(
     "TVC:GB02Y",
     "UK 2-Year Government Bond Yield",
     group="Data")

boeSymbol = input.symbol(
     "ECONOMICS:GBINTR",
     "Bank of England Bank Rate",
     group="Data")

startYear = input.int(
     2000,
     "Historical test start year",
     minval=1980,
     maxval=2035,
     group="Historical Test")

resetBandBp = input.int(
     15,
     "Episode reset distance (bp)",
     minval=5,
     maxval=40,
     step=5,
     group="Historical Test")

spreadEmaLen = input.int(
     20,
     "Spread persistence EMA",
     minval=2,
     group="Signal")

zLookback = input.int(
     252,
     "Z-score lookback",
     minval=60,
     group="Signal")

signalThresholdBp = input.int(
     50,
     "Minimum gap for live signal (bp)",
     options=[25, 50, 75, 100],
     group="Signal")

zThreshold = input.float(
     1.0,
     "Minimum absolute Z-score",
     minval=0.0,
     step=0.1,
     group="Signal")

persistenceDays = input.int(
     10,
     "Required persistence (trading days)",
     minval=1,
     maxval=60,
     group="Signal")

//---------------------------------------------------------------------
// DISPLAY
//---------------------------------------------------------------------

showMainRates = input.bool(
     true,
     "Show GB02Y + BoE on top chart",
     group="Display")

showMainDashboard = input.bool(
     true,
     "Show Policy Pressure table on TOP chart",
     group="Display")

showHowToRead = input.bool(
     false,
     "Show How To Read / Cheat Sheet",
     group="Display")

showSpreadEMA = input.bool(
     true,
     "Show 20-day spread average",
     group="Display")

showThresholds = input.bool(
     true,
     "Show +/-50 and +/-100bp levels",
     group="Display")

showActualMoves = input.bool(
     true,
     "Show actual BoE hikes/cuts",
     group="Display")

showSignals = input.bool(
     true,
     "Show UP/DOWN pressure signals",
     group="Display")

//=====================================================================
// 2. COLOUR PALETTE
//=====================================================================

// Structural colours
headerBg  = color.rgb(27, 48, 66)
sectionBg = color.rgb(33, 75, 105)

neutralBg   = color.rgb(55, 55, 55)
neutralSoft = color.rgb(72, 72, 72)

// Upward / hike pressure
upSoft   = color.rgb(145, 62, 62)
upStrong = color.rgb(110, 24, 24)

// Downward / cut pressure
downSoft   = color.rgb(45, 105, 65)
downStrong = color.rgb(17, 82, 38)

// Caution
amberBg     = color.rgb(150, 108, 32)
amberStrong = color.rgb(120, 78, 18)

textCol = color.white

//=====================================================================
// 3. DAILY DATA
//=====================================================================

gb02y = request.security(
     yieldSymbol,
     "D",
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

boe = request.security(
     boeSymbol,
     "D",
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

//=====================================================================
// 4. RAW RATE LINES ON TOP PRICE CHART
//=====================================================================

plot(
     showMainRates ? gb02y : na,
     title="UK 2Y Gilt Yield",
     color=color.orange,
     linewidth=2,
     force_overlay=true)

plot(
     showMainRates ? boe : na,
     title="BoE Bank Rate",
     color=color.black,
     linewidth=2,
     style=plot.style_stepline,
     force_overlay=true)

//=====================================================================
// 5. CORE POLICY GAP
//
// Positive:
// GB02Y > BoE Bank Rate
//
// Negative:
// GB02Y < BoE Bank Rate
//=====================================================================

spread = gb02y - boe

spreadEMA = ta.ema(
     spread,
     spreadEmaLen)

//=====================================================================
// 6. Z-SCORE
//
// Measures how unusual the CURRENT gap is relative to the
// previous approximately one trading year.
//=====================================================================

spreadMean = ta.sma(
     spread,
     zLookback)

spreadSD = ta.stdev(
     spread,
     zLookback)

float zScore = na

if not na(spreadSD) and spreadSD > 0
    zScore := (
         spread - spreadMean
         ) / spreadSD

//=====================================================================
// 7. ACTUAL BOE MOVES
//=====================================================================

rateChange = boe - boe[1]

actualHike =
     rateChange > 0

actualCut =
     rateChange < 0

inSample =
     year >= startYear

//=====================================================================
// 8. HISTORICAL EPISODE LOGIC
//
// We retain two meaningful gap regimes:
//
// +/-50bp
// +/-100bp
//
// Hysteresis stops repeated threshold wiggles being counted as
// multiple independent episodes.
//=====================================================================

resetBand =
     resetBandBp / 100.0

var bool up50Armed  = true
var bool up100Armed = true

var bool dn50Armed  = true
var bool dn100Armed = true

//---------------------------------------------------------------------
// REARM POSITIVE
//---------------------------------------------------------------------

if spread <= 0.50 - resetBand
    up50Armed := true

if spread <= 1.00 - resetBand
    up100Armed := true

//---------------------------------------------------------------------
// REARM NEGATIVE
//---------------------------------------------------------------------

if spread >= -0.50 + resetBand
    dn50Armed := true

if spread >= -1.00 + resetBand
    dn100Armed := true

//---------------------------------------------------------------------
// +50BP EPISODE
//---------------------------------------------------------------------

up50Episode =
     inSample and
     up50Armed and
     spread >= 0.50

if up50Episode
    up50Armed := false

//---------------------------------------------------------------------
// +100BP EPISODE
//---------------------------------------------------------------------

up100Episode =
     inSample and
     up100Armed and
     spread >= 1.00

if up100Episode
    up100Armed := false

//---------------------------------------------------------------------
// -50BP EPISODE
//---------------------------------------------------------------------

dn50Episode =
     inSample and
     dn50Armed and
     spread <= -0.50

if dn50Episode
    dn50Armed := false

//---------------------------------------------------------------------
// -100BP EPISODE
//---------------------------------------------------------------------

dn100Episode =
     inSample and
     dn100Armed and
     spread <= -1.00

if dn100Episode
    dn100Armed := false

//=====================================================================
// 9. HISTORICAL FORWARD WINDOWS
//
// Every comparable episode receives a full 60-trading-day
// observation window.
//=====================================================================

boeHigh20 =
     ta.highest(
         boe,
         20)

boeHigh60 =
     ta.highest(
         boe,
         60)

boeLow20 =
     ta.lowest(
         boe,
         20)

boeLow60 =
     ta.lowest(
         boe,
         60)

// BoE rate when the episode began 60 bars ago
signalBoE =
     boe[60]

// First 20 trading days following episode
futureHigh20 =
     boeHigh20[40]

futureLow20 =
     boeLow20[40]

// Full 60-day period following episode
futureHigh60 =
     boeHigh60

futureLow60 =
     boeLow60

// Exact change after 60 trading days
change60 =
     boe - signalBoE

//=====================================================================
// 10. HISTORICAL STORAGE
//=====================================================================

//---------------------------------------------------------------------
// +50
//---------------------------------------------------------------------

var int up50N = 0

var int up50Hit20 = 0
var int up50Hit60 = 0

var float[] up50Changes60 =
     array.new_float()

//---------------------------------------------------------------------
// +100
//---------------------------------------------------------------------

var int up100N = 0

var int up100Hit20 = 0
var int up100Hit60 = 0

var float[] up100Changes60 =
     array.new_float()

//---------------------------------------------------------------------
// -50
//---------------------------------------------------------------------

var int dn50N = 0

var int dn50Hit20 = 0
var int dn50Hit60 = 0

var float[] dn50Changes60 =
     array.new_float()

//---------------------------------------------------------------------
// -100
//---------------------------------------------------------------------

var int dn100N = 0

var int dn100Hit20 = 0
var int dn100Hit60 = 0

var float[] dn100Changes60 =
     array.new_float()

//=====================================================================
// 11. MATURE HISTORICAL EPISODES
//=====================================================================

matureUp50 =
     up50Episode[60]

matureUp100 =
     up100Episode[60]

matureDn50 =
     dn50Episode[60]

matureDn100 =
     dn100Episode[60]

//=====================================================================
// 12. UPDATE +50 STATISTICS
//=====================================================================

if matureUp50 and not na(signalBoE)

    up50N += 1

    if futureHigh20 > signalBoE
        up50Hit20 += 1

    if futureHigh60 > signalBoE
        up50Hit60 += 1

    if not na(change60)
        array.push(
             up50Changes60,
             change60)

//=====================================================================
// 13. UPDATE +100 STATISTICS
//=====================================================================

if matureUp100 and not na(signalBoE)

    up100N += 1

    if futureHigh20 > signalBoE
        up100Hit20 += 1

    if futureHigh60 > signalBoE
        up100Hit60 += 1

    if not na(change60)
        array.push(
             up100Changes60,
             change60)

//=====================================================================
// 14. UPDATE -50 STATISTICS
//=====================================================================

if matureDn50 and not na(signalBoE)

    dn50N += 1

    if futureLow20 < signalBoE
        dn50Hit20 += 1

    if futureLow60 < signalBoE
        dn50Hit60 += 1

    if not na(change60)
        array.push(
             dn50Changes60,
             change60)

//=====================================================================
// 15. UPDATE -100 STATISTICS
//=====================================================================

if matureDn100 and not na(signalBoE)

    dn100N += 1

    if futureLow20 < signalBoE
        dn100Hit20 += 1

    if futureLow60 < signalBoE
        dn100Hit60 += 1

    if not na(change60)
        array.push(
             dn100Changes60,
             change60)

//=====================================================================
// 16. HELPER FUNCTIONS
//=====================================================================

f_pct(int hits, int n) =>
    n > 0
     ? 100.0 * hits / n
     : na

f_median(float[] data) =>
    array.size(data) > 0
     ? array.median(data)
     : na

f_pctText(float v) =>
    na(v)
     ? "n/a"
     : str.tostring(v, "#") + "%"

f_bpText(float v) =>
    na(v)
     ? "n/a"
     : str.tostring(
         v * 100.0,
         "#") + " bp"

f_rateText(float v) =>
    na(v)
     ? "n/a"
     : str.tostring(
         v,
         "#.##") + "%"

//=====================================================================
// 17. HISTORICAL RESULTS
//=====================================================================

//---------------------------------------------------------------------
// +50
//---------------------------------------------------------------------

up50Pct20 =
     f_pct(
         up50Hit20,
         up50N)

up50Pct60 =
     f_pct(
         up50Hit60,
         up50N)

up50Median60 =
     f_median(
         up50Changes60)

//---------------------------------------------------------------------
// +100
//---------------------------------------------------------------------

up100Pct20 =
     f_pct(
         up100Hit20,
         up100N)

up100Pct60 =
     f_pct(
         up100Hit60,
         up100N)

up100Median60 =
     f_median(
         up100Changes60)

//---------------------------------------------------------------------
// -50
//---------------------------------------------------------------------

dn50Pct20 =
     f_pct(
         dn50Hit20,
         dn50N)

dn50Pct60 =
     f_pct(
         dn50Hit60,
         dn50N)

dn50Median60 =
     f_median(
         dn50Changes60)

//---------------------------------------------------------------------
// -100
//---------------------------------------------------------------------

dn100Pct20 =
     f_pct(
         dn100Hit20,
         dn100N)

dn100Pct60 =
     f_pct(
         dn100Hit60,
         dn100N)

dn100Median60 =
     f_median(
         dn100Changes60)

//=====================================================================
// 18. CURRENT COMPARABLE HISTORICAL REGIME
//=====================================================================

string activeRegime =
     "NEUTRAL"

int activeN =
     0

float activeHit20 =
     na

float activeHit60 =
     na

float activeMedian60 =
     na

//---------------------------------------------------------------------
// STRONG UP
//---------------------------------------------------------------------

if spread >= 1.00

    activeRegime :=
         "+100bp"

    activeN :=
         up100N

    activeHit20 :=
         up100Pct20

    activeHit60 :=
         up100Pct60

    activeMedian60 :=
         up100Median60

//---------------------------------------------------------------------
// MODERATE UP
//---------------------------------------------------------------------

else if spread >= 0.50

    activeRegime :=
         "+50bp"

    activeN :=
         up50N

    activeHit20 :=
         up50Pct20

    activeHit60 :=
         up50Pct60

    activeMedian60 :=
         up50Median60

//---------------------------------------------------------------------
// STRONG DOWN
//---------------------------------------------------------------------

else if spread <= -1.00

    activeRegime :=
         "-100bp"

    activeN :=
         dn100N

    activeHit20 :=
         dn100Pct20

    activeHit60 :=
         dn100Pct60

    activeMedian60 :=
         dn100Median60

//---------------------------------------------------------------------
// MODERATE DOWN
//---------------------------------------------------------------------

else if spread <= -0.50

    activeRegime :=
         "-50bp"

    activeN :=
         dn50N

    activeHit20 :=
         dn50Pct20

    activeHit60 :=
         dn50Pct60

    activeMedian60 :=
         dn50Median60

//=====================================================================
// 19. LIVE SIGNAL
//
// A signal requires:
//
// 1. Sufficient spread
// 2. Sufficient Z-score
// 3. Spread moving beyond its 20-day average
// 4. Persistence for X trading days
//=====================================================================

liveThreshold =
     signalThresholdBp / 100.0

rawUp =
     spread >= liveThreshold and
     not na(zScore) and
     zScore >= zThreshold and
     spread > spreadEMA

rawDown =
     spread <= -liveThreshold and
     not na(zScore) and
     zScore <= -zThreshold and
     spread < spreadEMA

//=====================================================================
// 20. PERSISTENCE COUNTERS
//=====================================================================

var int upDays = 0
var int downDays = 0

if rawUp
    upDays += 1
else
    upDays := 0

if rawDown
    downDays += 1
else
    downDays := 0

upPressure =
     upDays >= persistenceDays

downPressure =
     downDays >= persistenceDays

newUpPressure =
     upPressure and
     not upPressure[1]

newDownPressure =
     downPressure and
     not downPressure[1]

//=====================================================================
// 21. STATE
//
// STATE tells us what the raw market divergence looks like NOW.
//=====================================================================

string stateText =
     "BALANCED"

if spread >= 1.00

    stateText :=
         "STRONG UPWARD DIVERGENCE"

else if spread >= 0.50

    stateText :=
         "UPWARD DIVERGENCE"

else if spread <= -1.00

    stateText :=
         "STRONG DOWNWARD DIVERGENCE"

else if spread <= -0.50

    stateText :=
         "DOWNWARD DIVERGENCE"

//=====================================================================
// 22. SIGNAL
//
// SIGNAL tells us whether all confirmation conditions have completed.
//=====================================================================

string signalText =
     "WAITING"

if upPressure

    signalText :=
         "UP PRESSURE"

else if downPressure

    signalText :=
         "DOWN PRESSURE"

//=====================================================================
// 23. MEDIAN HISTORICAL RESPONSE
//=====================================================================

float medianModel60 =
     na

if not na(activeMedian60)

    medianModel60 :=
         boe + activeMedian60

nearest25 =
     not na(medianModel60)
     ? math.round(
         medianModel60 * 4.0
         ) / 4.0
     : na

//=====================================================================
// 24. PLAIN-ENGLISH GAP INTERPRETATION
//=====================================================================

string gapMeaning =
     "Close to Bank Rate"

if spread >= 1.00

    gapMeaning :=
         "Large upward separation"

else if spread >= 0.50

    gapMeaning :=
         "Meaningful upward separation"

else if spread <= -1.00

    gapMeaning :=
         "Large downward separation"

else if spread <= -0.50

    gapMeaning :=
         "Meaningful downward separation"

//=====================================================================
// 25. PLAIN-ENGLISH Z-SCORE INTERPRETATION
//=====================================================================

string zMeaning =
     "Normal"

if not na(zScore)

    if zScore >= 2.0

        zMeaning :=
             "Very unusual HIGH"

    else if zScore >= 1.0

        zMeaning :=
             "Notable HIGH"

    else if zScore <= -2.0

        zMeaning :=
             "Very unusual LOW"

    else if zScore <= -1.0

        zMeaning :=
             "Notable LOW"

//=====================================================================
// 26. SAMPLE QUALITY
//=====================================================================

string sampleText =
     "Very small"

if activeN >= 10

    sampleText :=
         "Better"

else if activeN >= 5

    sampleText :=
         "Small"

//=====================================================================
// 27. PERSISTENCE TEXT
//=====================================================================

string persistenceText =
     "-"

if upPressure

    persistenceText :=
         str.tostring(
             upDays
             ) + "d"

else if downPressure

    persistenceText :=
         str.tostring(
             downDays
             ) + "d"

else if rawUp

    persistenceText :=
         str.tostring(
             upDays
             ) + "/" +
         str.tostring(
             persistenceDays
             )

else if rawDown

    persistenceText :=
         str.tostring(
             downDays
             ) + "/" +
         str.tostring(
             persistenceDays
             )

//=====================================================================
// 28. COLOUR LOGIC
//=====================================================================

//---------------------------------------------------------------------
// GAP
//---------------------------------------------------------------------

gapBg =
     spread >= 1.00
     ? upStrong
     : spread >= 0.50
     ? upSoft
     : spread <= -1.00
     ? downStrong
     : spread <= -0.50
     ? downSoft
     : neutralBg

//---------------------------------------------------------------------
// Z
//---------------------------------------------------------------------

zBg =
     not na(zScore) and zScore >= 2.0
     ? upStrong
     : not na(zScore) and zScore >= 1.0
     ? amberBg
     : not na(zScore) and zScore <= -2.0
     ? downStrong
     : not na(zScore) and zScore <= -1.0
     ? amberBg
     : neutralBg

//---------------------------------------------------------------------
// STATE
//---------------------------------------------------------------------

stateBg =
     spread >= 1.00
     ? upStrong
     : spread >= 0.50
     ? upSoft
     : spread <= -1.00
     ? downStrong
     : spread <= -0.50
     ? downSoft
     : neutralBg

//---------------------------------------------------------------------
// SIGNAL
//---------------------------------------------------------------------

signalBg =
     upPressure
     ? upStrong
     : downPressure
     ? downStrong
     : rawUp or rawDown
     ? amberStrong
     : neutralBg

//---------------------------------------------------------------------
// SAMPLE SIZE
//---------------------------------------------------------------------

sampleBg =
     activeN >= 10
     ? downSoft
     : activeN >= 5
     ? amberBg
     : upSoft

//---------------------------------------------------------------------
// HIT RATE
//---------------------------------------------------------------------

hit20Bg =
     na(activeHit20)
     ? neutralBg
     : activeHit20 >= 75
     ? (
         spread >= 0
         ? upSoft
         : downSoft
       )
     : activeHit20 >= 50
     ? amberBg
     : neutralBg

hit60Bg =
     na(activeHit60)
     ? neutralBg
     : activeHit60 >= 75
     ? (
         spread >= 0
         ? upStrong
         : downStrong
       )
     : activeHit60 >= 50
     ? amberBg
     : neutralBg

//---------------------------------------------------------------------
// MEDIAN HISTORICAL MOVE
//---------------------------------------------------------------------

medianMoveBg =
     na(activeMedian60)
     ? neutralBg
     : activeMedian60 > 0
     ? upSoft
     : activeMedian60 < 0
     ? downSoft
     : neutralBg

//=====================================================================
// 29. LOWER PANE - CORE INDICATOR
//=====================================================================

plot(
     spread,
     title="GB02Y minus BoE Bank Rate",
     color=color.blue,
     linewidth=2)

plot(
     showSpreadEMA
     ? spreadEMA
     : na,
     title="20-Day Spread Average",
     color=color.orange,
     linewidth=2)

hline(
     0,
     title="GB02Y = BoE",
     color=color.gray,
     linestyle=hline.style_dashed)

//=====================================================================
// 30. THRESHOLD LINES
//=====================================================================

plot(
     showThresholds
     ? 0.50
     : na,
     title="+50bp",
     color=color.new(
         color.red,
         60),
     linewidth=1)

plot(
     showThresholds
     ? 1.00
     : na,
     title="+100bp",
     color=color.red,
     linewidth=2)

plot(
     showThresholds
     ? -0.50
     : na,
     title="-50bp",
     color=color.new(
         color.green,
         60),
     linewidth=1)

plot(
     showThresholds
     ? -1.00
     : na,
     title="-100bp",
     color=color.green,
     linewidth=2)

//=====================================================================
// 31. ACTUAL BOE MOVES
//=====================================================================

plotshape(
     showActualMoves and actualHike,
     title="Actual BoE Hike",
     style=shape.circle,
     location=location.bottom,
     color=color.red,
     size=size.tiny,
     text="H")

plotshape(
     showActualMoves and actualCut,
     title="Actual BoE Cut",
     style=shape.circle,
     location=location.top,
     color=color.green,
     size=size.tiny,
     text="C")

//=====================================================================
// 32. LIVE SIGNAL MARKERS
//=====================================================================

plotshape(
     showSignals and newUpPressure,
     title="New Up Pressure",
     style=shape.labelup,
     location=location.bottom,
     color=color.red,
     textcolor=color.white,
     size=size.small,
     text="UP")

plotshape(
     showSignals and newDownPressure,
     title="New Down Pressure",
     style=shape.labeldown,
     location=location.top,
     color=color.green,
     textcolor=color.white,
     size=size.small,
     text="DOWN")

//=====================================================================
// 33. LOWER-PANE BACKGROUND
//=====================================================================

bgcolor(
     upPressure
     ? color.new(
         color.red,
         94)
     : downPressure
     ? color.new(
         color.green,
         94)
     : na)

//=====================================================================
// 34. ALERTS
//=====================================================================

alertcondition(
     newUpPressure,
     title="BoE Upward Policy Pressure",
     message=
         "GB02Y-BoE spread entered a persistent upward policy-pressure regime.")

alertcondition(
     newDownPressure,
     title="BoE Downward Policy Pressure",
     message=
         "GB02Y-BoE spread entered a persistent downward policy-pressure regime.")

//=====================================================================
// 35. DATA WINDOW
//=====================================================================

plot(
     zScore,
     title="Spread Z-Score",
     display=display.data_window)

plot(
     activeMedian60,
     title="Historical Median 60D BoE Change",
     display=display.data_window)

plot(
     medianModel60,
     title="Median Historical 60D Model Rate",
     display=display.data_window)

//=====================================================================
// 36. MAIN POLICY TABLE
//
// IMPORTANT:
//
// force_overlay=true
//
// This moves THIS table to the TOP PRICE CHART even though the
// indicator itself lives in the lower pane.
//=====================================================================

var table dash =
     table.new(
         position.top_right,
         5,
         12,
         bgcolor=color.new(
             color.black,
             5),
         frame_color=color.gray,
         frame_width=1,
         border_color=color.rgb(
             90,
             90,
             90),
         border_width=1,
         force_overlay=true)

//=====================================================================
// 37. CLEAR MAIN TABLE
//=====================================================================

if barstate.islast

    table.clear(
         dash,
         0,
         0,
         4,
         11)

//=====================================================================
// 38. MAIN TABLE CONTENT
//=====================================================================

if barstate.islast and showMainDashboard

    //-------------------------------------------------------------
    // TITLE
    //-------------------------------------------------------------

    table.cell(
         dash,
         0,
         0,
         "BOE POLICY PRESSURE",
         bgcolor=headerBg,
         text_color=textCol)

    table.cell(
         dash,
         1,
         0,
         "",
         bgcolor=headerBg)

    table.cell(
         dash,
         2,
         0,
         "",
         bgcolor=headerBg)

    table.cell(
         dash,
         3,
         0,
         "",
         bgcolor=headerBg)

    table.cell(
         dash,
         4,
         0,
         "",
         bgcolor=headerBg)

    //-------------------------------------------------------------
    // CURRENT MARKET SECTION
    //-------------------------------------------------------------

    table.cell(
         dash,
         0,
         1,
         "CURRENT MARKET",
         bgcolor=sectionBg,
         text_color=textCol)

    table.cell(
         dash,
         1,
         1,
         "",
         bgcolor=sectionBg)

    table.cell(
         dash,
         2,
         1,
         "",
         bgcolor=sectionBg)

    table.cell(
         dash,
         3,
         1,
         "",
         bgcolor=sectionBg)

    table.cell(
         dash,
         4,
         1,
         "",
         bgcolor=sectionBg)

    //-------------------------------------------------------------
    // RATES
    //-------------------------------------------------------------

    table.cell(
         dash,
         0,
         2,
         "GB02Y",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         1,
         2,
         f_rateText(
             gb02y),
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         2,
         2,
         "BoE Rate",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         3,
         2,
         f_rateText(
             boe),
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         4,
         2,
         "",
         bgcolor=neutralBg)

    //-------------------------------------------------------------
    // GAP
    //-------------------------------------------------------------

    table.cell(
         dash,
         0,
         3,
         "Gap",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         1,
         3,
         f_bpText(
             spread),
         bgcolor=gapBg,
         text_color=textCol)

    table.cell(
         dash,
         2,
         3,
         "Meaning",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         3,
         3,
         gapMeaning,
         bgcolor=gapBg,
         text_color=textCol)

    table.cell(
         dash,
         4,
         3,
         "",
         bgcolor=gapBg)

    //-------------------------------------------------------------
    // Z-SCORE
    //-------------------------------------------------------------

    table.cell(
         dash,
         0,
         4,
         "Z-score",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         1,
         4,
         na(zScore)
         ? "n/a"
         : str.tostring(
             zScore,
             "#.##"),
         bgcolor=zBg,
         text_color=textCol)

    table.cell(
         dash,
         2,
         4,
         "Meaning",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         3,
         4,
         zMeaning,
         bgcolor=zBg,
         text_color=textCol)

    table.cell(
         dash,
         4,
         4,
         "",
         bgcolor=zBg)

    //-------------------------------------------------------------
    // STATE / SIGNAL
    //-------------------------------------------------------------

    table.cell(
         dash,
         0,
         5,
         "STATE",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         1,
         5,
         stateText,
         bgcolor=stateBg,
         text_color=textCol)

    table.cell(
         dash,
         2,
         5,
         "SIGNAL",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         3,
         5,
         signalText,
         bgcolor=signalBg,
         text_color=textCol)

    table.cell(
         dash,
         4,
         5,
         persistenceText,
         bgcolor=signalBg,
         text_color=textCol)

    //-------------------------------------------------------------
    // HISTORICAL EVIDENCE HEADER
    //-------------------------------------------------------------

    table.cell(
         dash,
         0,
         7,
         "HISTORICAL EVIDENCE",
         bgcolor=sectionBg,
         text_color=textCol)

    table.cell(
         dash,
         1,
         7,
         "",
         bgcolor=sectionBg)

    table.cell(
         dash,
         2,
         7,
         "",
         bgcolor=sectionBg)

    table.cell(
         dash,
         3,
         7,
         "",
         bgcolor=sectionBg)

    table.cell(
         dash,
         4,
         7,
         "",
         bgcolor=sectionBg)

    //-------------------------------------------------------------
    // COMPARABLE EPISODES
    //-------------------------------------------------------------

    table.cell(
         dash,
         0,
         8,
         "Comparable",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         1,
         8,
         activeRegime,
         bgcolor=stateBg,
         text_color=textCol)

    table.cell(
         dash,
         2,
         8,
         "Episodes",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         3,
         8,
         str.tostring(
             activeN),
         bgcolor=sampleBg,
         text_color=textCol)

    table.cell(
         dash,
         4,
         8,
         sampleText,
         bgcolor=sampleBg,
         text_color=textCol)

    //-------------------------------------------------------------
    // HISTORICAL DIRECTIONAL HITS
    //-------------------------------------------------------------

    table.cell(
         dash,
         0,
         9,
         "Move within 20d",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         1,
         9,
         f_pctText(
             activeHit20),
         bgcolor=hit20Bg,
         text_color=textCol)

    table.cell(
         dash,
         2,
         9,
         "Move within 60d",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         3,
         9,
         f_pctText(
             activeHit60),
         bgcolor=hit60Bg,
         text_color=textCol)

    table.cell(
         dash,
         4,
         9,
         "Historical",
         bgcolor=neutralBg,
         text_color=textCol)

    //-------------------------------------------------------------
    // MEDIAN RESPONSE
    //-------------------------------------------------------------

    table.cell(
         dash,
         0,
         10,
         "Median 60d change",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         1,
         10,
         f_bpText(
             activeMedian60),
         bgcolor=medianMoveBg,
         text_color=textCol)

    table.cell(
         dash,
         2,
         10,
         "Median 60d level",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         dash,
         3,
         10,
         f_rateText(
             medianModel60),
         bgcolor=medianMoveBg,
         text_color=textCol)

    table.cell(
         dash,
         4,
         10,
         "Hist. estimate",
         bgcolor=neutralBg,
         text_color=textCol)

    //-------------------------------------------------------------
    // SETTINGS
    //-------------------------------------------------------------

    table.cell(
         dash,
         0,
         11,
         "Trigger",
         bgcolor=headerBg,
         text_color=textCol)

    table.cell(
         dash,
         1,
         11,
         str.tostring(
             signalThresholdBp
             ) + "bp",
         bgcolor=headerBg,
         text_color=textCol)

    table.cell(
         dash,
         2,
         11,
         "Required Z",
         bgcolor=headerBg,
         text_color=textCol)

    table.cell(
         dash,
         3,
         11,
         str.tostring(
             zThreshold,
             "#.0"),
         bgcolor=headerBg,
         text_color=textCol)

    table.cell(
         dash,
         4,
         11,
         "1D",
         bgcolor=headerBg,
         text_color=textCol)

//=====================================================================
// 39. OPTIONAL "HOW TO READ" TABLE
//
// This stays in the LOWER indicator pane.
//
// Default setting is OFF.
//
// Settings -> Display -> Show How To Read / Cheat Sheet
//=====================================================================

var table cheat =
     table.new(
         position.bottom_right,
         4,
         12,
         bgcolor=color.new(
             color.black,
             5),
         frame_color=color.gray,
         frame_width=1,
         border_color=color.rgb(
             90,
             90,
             90),
         border_width=1)

//=====================================================================
// 40. CLEAR CHEAT SHEET
//=====================================================================

if barstate.islast

    table.clear(
         cheat,
         0,
         0,
         3,
         11)

//=====================================================================
// 41. OPTIONAL CHEAT SHEET CONTENT
//=====================================================================

if barstate.islast and showHowToRead

    //-------------------------------------------------------------
    // HEADER
    //-------------------------------------------------------------

    table.cell(
         cheat,
         0,
         0,
         "HOW TO READ",
         bgcolor=headerBg,
         text_color=textCol)

    table.cell(
         cheat,
         1,
         0,
         "MEANING",
         bgcolor=headerBg,
         text_color=textCol)

    table.cell(
         cheat,
         2,
         0,
         "FOCUS",
         bgcolor=headerBg,
         text_color=textCol)

    table.cell(
         cheat,
         3,
         0,
         "READ",
         bgcolor=headerBg,
         text_color=textCol)

    //-------------------------------------------------------------
    // GAP
    //-------------------------------------------------------------

    table.cell(
         cheat,
         0,
         1,
         "Gap",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         cheat,
         1,
         1,
         "GB02Y - BoE",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         cheat,
         2,
         1,
         "Direction",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         cheat,
         3,
         1,
         "+ up / - down",
         bgcolor=neutralBg,
         text_color=textCol)

    //-------------------------------------------------------------
    // +/-50
    //-------------------------------------------------------------

    table.cell(
         cheat,
         0,
         2,
         "+/-50bp",
         bgcolor=amberBg,
         text_color=textCol)

    table.cell(
         cheat,
         1,
         2,
         "Meaningful gap",
         bgcolor=amberBg,
         text_color=textCol)

    table.cell(
         cheat,
         2,
         2,
         "WATCH",
         bgcolor=amberBg,
         text_color=textCol)

    table.cell(
         cheat,
         3,
         2,
         "Gap matters",
         bgcolor=amberBg,
         text_color=textCol)

    //-------------------------------------------------------------
    // +100
    //-------------------------------------------------------------

    table.cell(
         cheat,
         0,
         3,
         "+100bp",
         bgcolor=upStrong,
         text_color=textCol)

    table.cell(
         cheat,
         1,
         3,
         "Large upward gap",
         bgcolor=upStrong,
         text_color=textCol)

    table.cell(
         cheat,
         2,
         3,
         "HIGH FOCUS",
         bgcolor=upStrong,
         text_color=textCol)

    table.cell(
         cheat,
         3,
         3,
         "Upward pressure",
         bgcolor=upStrong,
         text_color=textCol)

    //-------------------------------------------------------------
    // -100
    //-------------------------------------------------------------

    table.cell(
         cheat,
         0,
         4,
         "-100bp",
         bgcolor=downStrong,
         text_color=textCol)

    table.cell(
         cheat,
         1,
         4,
         "Large downward gap",
         bgcolor=downStrong,
         text_color=textCol)

    table.cell(
         cheat,
         2,
         4,
         "HIGH FOCUS",
         bgcolor=downStrong,
         text_color=textCol)

    table.cell(
         cheat,
         3,
         4,
         "Downward pressure",
         bgcolor=downStrong,
         text_color=textCol)

    //-------------------------------------------------------------
    // NORMAL Z
    //-------------------------------------------------------------

    table.cell(
         cheat,
         0,
         5,
         "|Z| < 1",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         cheat,
         1,
         5,
         "Normal",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         cheat,
         2,
         5,
         "LOW",
         bgcolor=neutralBg,
         text_color=textCol)

    table.cell(
         cheat,
         3,
         5,
         "Common",
         bgcolor=neutralBg,
         text_color=textCol)

    //-------------------------------------------------------------
    // NOTABLE Z
    //-------------------------------------------------------------

    table.cell(
         cheat,
         0,
         6,
         "|Z| 1-2",
         bgcolor=amberBg,
         text_color=textCol)

    table.cell(
         cheat,
         1,
         6,
         "Notable",
         bgcolor=amberBg,
         text_color=textCol)

    table.cell(
         cheat,
         2,
         6,
         "WATCH",
         bgcolor=amberBg,
         text_color=textCol)

    table.cell(
         cheat,
         3,
         6,
         "Unusual",
         bgcolor=amberBg,
         text_color=textCol)

    //-------------------------------------------------------------
    // EXTREME Z
    //-------------------------------------------------------------

    table.cell(
         cheat,
         0,
         7,
         "|Z| > 2",
         bgcolor=upStrong,
         text_color=textCol)

    table.cell(
         cheat,
         1,
         7,
         "Very unusual",
         bgcolor=upStrong,
         text_color=textCol)

    table.cell(
         cheat,
         2,
         7,
         "HIGH FOCUS",
         bgcolor=upStrong,
         text_color=textCol)

    table.cell(
         cheat,
         3,
         7,
         "Extreme gap",
         bgcolor=upStrong,
         text_color=textCol)

    //-------------------------------------------------------------
    // SAMPLE <5
    //-------------------------------------------------------------

    table.cell(
         cheat,
         0,
         8,
         "Episodes <5",
         bgcolor=upSoft,
         text_color=textCol)

    table.cell(
         cheat,
         1,
         8,
         "Very small sample",
         bgcolor=upSoft,
         text_color=textCol)

    table.cell(
         cheat,
         2,
         8,
         "CAUTION",
         bgcolor=upSoft,
         text_color=textCol)

    table.cell(
         cheat,
         3,
         8,
         "Weak evidence",
         bgcolor=upSoft,
         text_color=textCol)

    //-------------------------------------------------------------
    // SAMPLE 5-9
    //-------------------------------------------------------------

    table.cell(
         cheat,
         0,
         9,
         "Episodes 5-9",
         bgcolor=amberBg,
         text_color=textCol)

    table.cell(
         cheat,
         1,
         9,
         "Small sample",
         bgcolor=amberBg,
         text_color=textCol)

    table.cell(
         cheat,
         2,
         9,
         "CARE",
         bgcolor=amberBg,
         text_color=textCol)

    table.cell(
         cheat,
         3,
         9,
         "Useful context",
         bgcolor=amberBg,
         text_color=textCol)

    //-------------------------------------------------------------
    // SAMPLE 10+
    //-------------------------------------------------------------

    table.cell(
         cheat,
         0,
         10,
         "Episodes 10+",
         bgcolor=downSoft,
         text_color=textCol)

    table.cell(
         cheat,
         1,
         10,
         "Better sample",
         bgcolor=downSoft,
         text_color=textCol)

    table.cell(
         cheat,
         2,
         10,
         "MORE USEFUL",
         bgcolor=downSoft,
         text_color=textCol)

    table.cell(
         cheat,
         3,
         10,
         "More evidence",
         bgcolor=downSoft,
         text_color=textCol)

    //-------------------------------------------------------------
    // HISTORICAL HIT RATE
    //-------------------------------------------------------------

    table.cell(
         cheat,
         0,
         11,
         "20d / 60d",
         bgcolor=sectionBg,
         text_color=textCol)

    table.cell(
         cheat,
         1,
         11,
         "Past same-way move",
         bgcolor=sectionBg,
         text_color=textCol)

    table.cell(
         cheat,
         2,
         11,
         "HISTORICAL",
         bgcolor=sectionBg,
         text_color=textCol)

    table.cell(
         cheat,
         3,
         11,
         "NOT probability",
         bgcolor=sectionBg,
         text_color=textCol)
````
