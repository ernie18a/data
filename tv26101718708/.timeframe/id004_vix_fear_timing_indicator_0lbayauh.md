# ID004 VIX Fear Timing Indicator

- url: https://www.tradingview.com/script/0lbayaUH-ID004-VIX-Fear-Timing-Indicator/
- type: indicator
- pine_id: PUB;cca500c49c6545f49a9bcf80c43b923f
- version: 1.0

## Description

A volatility-aware staged dip-recovery indicator designed to help traders study pullback recovery conditions using price action, staged DCA logic, higher-timeframe context, and VIX fear timing.

---------------------------------------------------------------------------------------------------
## [b]1. [Must read as user] What this indicator is for 🧭[/b]
---------------------------------------------------------------------------------------------------


This indicator is designed to help traders study possible recovery zones after a meaningful market pullback. It does not try to buy every dip or react to every red candle. Instead, it waits for a more structured recovery setup where price has already dropped, then begins to show signs that downside pressure may be weakening.

The main idea is to help the user avoid random dip-buying. A market can look cheap and still continue falling. For that reason, the indicator checks price recovery behavior, market structure, and VIX fear conditions before showing staged labels.

[quote]The goal is not to catch the exact bottom. The goal is to identify structured recovery attempts after fear, weakness, or volatility stress has already appeared.[/quote]

This indicator should be used as a decision-support tool. It does not replace your own analysis, risk management, or trade plan.

---------------------------------------------------------------------------------------------------
## [b]2. [Must read as user] What the labels mean 🏷️[/b]
---------------------------------------------------------------------------------------------------

The indicator shows three staged recovery labels on the chart:
[list]
[*][b]Buy[/b]: the first recovery stage after price has made a meaningful pullback.
[*][b]DCA1[/b]: the first deeper recovery stage after a Buy label has already appeared.
[*][b]DCA2[/b]: the final deeper recovery stage after Buy and DCA1 have already appeared.
[/list]
These labels are not automatic trade instructions. They are visual signals for chart review. A label means the script found a specific recovery condition, but it does not mean the trade is guaranteed to work.

The DCA stages are not random extra buy signals. They belong to one structured sequence. DCA1 only matters after Buy. DCA2 only matters after Buy and DCA1.

[quote]Read the labels as staged recovery information, not as a complete trading system.[/quote]

---------------------------------------------------------------------------------------------------
## [b]3. [Must read as user] Simple workflow for using it ✅[/b]
---------------------------------------------------------------------------------------------------

A practical way to use the indicator:
[list=1]
[*]Start with the default settings.
[*]Use standard candlestick or OHLC charts.
[*]Wait for a Buy label before thinking about DCA1 or DCA2.
[*]Use DCA1 only if it appears after Buy and still fits your risk plan.
[*]Use DCA2 only if it appears after Buy and DCA1, especially when VIX fear has started to cool.
[*]Use alerts as reminders to review the chart, not as automatic trade commands.
[*]Check trend, support, resistance, volume, liquidity, earnings, news, macro events, and broader market risk before acting.
[/list]
This tool is usually easier to interpret on cleaner timeframes such as 1 hour, 4 hours, or 1 day. Very short timeframes can create more noise, especially during fast selloffs.

Before using staged entries, decide your maximum exposure, invalidation level, stop logic, profit-taking plan, and exit conditions.

---------------------------------------------------------------------------------------------------
## [b]4. [Must read as user] How to read VIX fear timing 🌡️[/b]
---------------------------------------------------------------------------------------------------

VIX is used as a market fear and volatility filter. The indicator does not only ask whether price has dropped. It also asks whether fear is elevated and whether fear may be starting to cool.

A high VIX condition does not automatically mean price will recover. It only means fear or volatility stress is elevated. Price still needs to show recovery behavior before the script can confirm a staged label.

The VIX logic is different for each stage:
[list]
[*][b]Buy[/b] can appear when price recovery and VIX stress conditions are acceptable.
[*][b]DCA1[/b] needs stricter fear confirmation when the VIX filter is active.
[*][b]DCA2[/b] is more selective and looks for VIX to have been very high recently, then cool lower.
[/list]
This helps reduce the risk of adding too early while panic is still expanding.

---------------------------------------------------------------------------------------------------
## [b]5. [Must read as user] Risk notes and correct expectations ⚠️[/b]
---------------------------------------------------------------------------------------------------

This indicator is not financial advice and does not guarantee future results. It does not open trades, close trades, manage stops, calculate position size, or decide how much money to risk.

DCA can increase losses if price continues falling. Every staged entry should be planned before the first signal appears. Do not use DCA1 or DCA2 only because a label appears. Use them only if the broader setup still fits your own risk plan.

Important user reminders:
[list]
[*]A Buy label is not proof that the bottom is in.
[*]DCA1 and DCA2 increase exposure and risk.
[*]High VIX can mean opportunity, but it can also mean danger.
[*]Alerts are review reminders, not trading instructions.
[*]Synthetic chart types may distort OHLC behavior and can make signals less reliable.
[/list]
[quote]Use the indicator to organize your chart review. Do not use it as a substitute for risk management.[/quote]

---------------------------------------------------------------------------------------------------
## [b]6. [Optional technical explanation] Script structure and originality[/b]
---------------------------------------------------------------------------------------------------

[pine]
This script is an overlay indicator, not a strategy.

It uses:

* indicator(..., overlay=true)
* plotshape() for Buy, DCA1, and DCA2 labels
* bgcolor() for VIX percentile background
* alertcondition() for monitoring alerts

It does not use:

* strategy.entry()
* strategy.exit()
* strategy.close()
* automated order placement
* position management logic

The originality of the script is in how the components are connected. The script does not simply display RSI, Bollinger Bands, MACD, VIX, and moving averages as separate tools. Instead, those components are used inside a staged recovery framework.

The integration works through:

1. A state machine that controls the sequence.
2. Price-drop requirements before a stage can qualify.
3. Recovery confirmation after weakness appears.
4. Quality scores that combine several technical clues.
5. Higher-timeframe danger filters.
6. Crash filters to avoid fast breakdowns.
7. VIX fear filters that change by stage.
8. Adaptive timing windows for DCA1 and DCA2.
9. Armed-zone logic before DCA confirmation.
10. Reset logic so old stages do not stay active forever.

The state model is central:

state = 0 means no active sequence.
state = 1 means Buy has triggered.
state = 2 means DCA1 has triggered.
state = 3 means DCA2 has triggered.

This is why DCA labels cannot appear randomly. DCA1 requires Buy first. DCA2 requires DCA1 first.

The script stores important stage references:
buyPrice
d1Price
d2Price
buyBar
d1Bar
d2Bar

These values are then used to calculate deeper zones, timing windows, basket average, and reset conditions.
[/pine]

---------------------------------------------------------------------------------------------------
## [b]7. [Optional technical explanation] Buy stage calculation[/b]
---------------------------------------------------------------------------------------------------

[pine]
The Buy stage is the first recovery stage. It requires a meaningful pullback and early recovery evidence.

The script calculates a recent lookback high:
lookbackHigh = ta.highest(high, lookbackBars)

Then it calculates the percentage drop from that high:
dropFromLookbackHighPct = (lookbackHigh - close) / lookbackHigh * 100

The Buy drop threshold is adjusted by the selected Signal preset:
Aggressive = lower required drop
Balanced = default required drop
Conservative = higher required drop

The effective Buy drop is:
effBuyDropPct = buyDropPct * dropMult

The core Buy setup uses:
meaningfulDrop
wasOversold
momentumRecovery
priceRecovery

meaningfulDrop:
Price must fall enough from the recent lookback high.

wasOversold:
The script checks whether RSI was recently weak:
ta.lowest(rsi, 10) < 35

momentumRecovery:
The script checks whether RSI is improving and recovering from weak conditions.

priceRecovery:
The script checks whether price is showing local recovery by closing above the fast EMA or above the previous bar high.

The script also builds a Buy quality score. The score can include:

* meaningful drop
* recent oversold behavior
* RSI improvement
* price recovery
* oversold reclaim
* Bollinger Band reclaim
* support reclaim
* bullish divergence
* strong lower wick
* MACD histogram improvement
* structure shift
* volume confirmation
* strong VIX stress
* rare VIX event
* VIX fear cooling

The final Buy signal requires all major gates:
state == 0
cooldownOk
buyRegimeOk
crashOk
vixBuyOk
buySetup
buyQualityOk

This means Buy is more selective than a simple RSI oversold label. It needs price weakness first, then recovery behavior, then context and quality confirmation.
[/pine]

---------------------------------------------------------------------------------------------------
## [b]8. [Optional technical explanation] DCA1 and DCA2 calculation[/b]
---------------------------------------------------------------------------------------------------

[pine]
DCA1 and DCA2 are staged deeper recovery zones. They depend on previously stored stage prices.

DCA1 uses the Buy price:
d1ZonePct = buyPrice * (1.0 - effD1DropPct / 100.0)

DCA2 uses the DCA1 price:
d2ZonePct = d1Price * (1.0 - effD2DropPct / 100.0)

In this version, the internal drop validation is set to "Percent only", so percentage-based validation is the active method.

DCA1 logic:
DCA1 requires state == 1.
This means Buy must already exist.

DCA1 must happen inside its timing window:
barsSinceBuy >= adaptiveD1Min
barsSinceBuy <= adaptiveD1Max

The DCA1 zone becomes armed when:

* state is 1
* price is below the Buy price
* price reaches the DCA1 zone
* the DCA1 timing window is valid

After the zone is armed, the script waits for a confirmation delay:
d1ConfirmDelay

DCA1 technical confirmation can come from:
B1 = bullish divergence and RSI improvement
B2 = Bollinger Band reclaim plus wick, candle, or MACD improvement
B3 = support reclaim or strong lower wick plus RSI or volume confirmation
Bscore = weighted recovery score

DCA1 also uses VIX score components:

* basic VIX stress
* strong VIX stress
* rare VIX event
* VIX fear cooling

The final DCA1 signal requires:
state == 1
d1Armed
d1ArmedLongEnough
inD1Window
recoveryCandleD1
dcaRegimeOk
crashOk
d1VixOk
d1TechnicalOk
d1QualityOk

DCA2 logic:
DCA2 requires state == 2.
This means Buy and DCA1 must already exist.

DCA2 must happen inside its timing window:
barsSinceD1 >= adaptiveD2Min
barsSinceD1 <= adaptiveD2Max

DCA2 also checks price against basket average:
basketAvg = average of active staged prices

The DCA2 zone becomes armed when:

* state is 2
* price reaches the DCA2 zone
* price is below basket average
* the DCA2 timing window is valid

DCA2 technical confirmation is stricter and can include:
C1 = higher-timeframe RSI or MACD improvement plus local recovery
C2 = capitulation-style volume spike, strong lower wick, and large range
C3 = structure shift plus RSI improvement
Cscore = weighted score using higher-timeframe improvement, capitulation evidence, structure shift, wick rejection, bullish engulfing, volume spike, and higher-timeframe MACD improvement

The final DCA2 signal requires:
state == 2
d2Armed
d2ArmedLongEnough
inD2Window
recoveryCandleD2
dcaRegimeOk
crashOk
d2VixOk
d2TechnicalOk
d2QualityOk

This explains why DCA1 and DCA2 are not only lower-price signals. A zone must be reached first, then recovery evidence must appear before confirmation.
[/pine]

---------------------------------------------------------------------------------------------------
## [b]9. [Optional technical explanation] VIX, timeframe, and regime filters[/b]
---------------------------------------------------------------------------------------------------

[pine]
The script requests VIX data from the selected VIX symbol:
vixSymbol = input.symbol("CBOE:VIX", "VIX symbol")

VIX uses the active chart timeframe:
vixTf = timeframe.period

The VIX function returns:

* VIX close
* VIX percentile
* VIX percentile jump
* whether VIX is falling
* whether VIX percentile is falling

The script builds several VIX conditions:

vixAbsoluteOk:
VIX close is above an internal stress level.

vixHighPercentileOk:
VIX percentile is above the selected stress percentile.

vixJumpOk:
VIX percentile jumped sharply.

vixRareEvent:
VIX percentile or absolute VIX level is extremely high.

vixStressBasic:
Basic fear condition is active.

vixStressStrong:
Stronger fear condition is active.

vixFearCooling:
Fear is elevated and VIX or VIX percentile is falling.

For DCA2, the script uses a special cooling model:
vixRecentPeakPercentile = recent highest VIX percentile
vixWasTooHighRecently = VIX percentile was very high recently
vixCooledFromPeak = VIX percentile cooled by the selected cooling amount
vixCoolingButStillElevated = VIX is still high but falling

DCA2 can pass VIX cooling when:

* VIX cooled enough from a recent high peak
* a rare VIX event is active and fear is cooling
* VIX is still elevated but percentile is falling

The stage-specific VIX design is important:
Buy can use basic VIX stress or fear cooling.
DCA1 requires stricter stress confirmation.
DCA2 requires recent high fear followed by cooling.

The script also adapts to chart profiles:
15 minutes
30 minutes
1 hour
4 hours
1 day

The profile affects:

* price lookback
* VIX lookback
* DCA timing windows
* confirmation delays
* higher-timeframe reference
* crash detection window

Higher-timeframe regime logic checks:

* higher-timeframe close
* higher-timeframe EMA 50
* higher-timeframe EMA 200
* higher-timeframe RSI
* higher-timeframe RSI direction
* higher-timeframe MACD histogram improvement

The danger regime blocks normal recovery signals when higher-timeframe trend and momentum are too weak, unless rare fear and local recovery behavior justify an exception.

The crash filter checks for fast, high-volume selloffs and helps avoid triggering recovery labels during active breakdown pressure.
[/pine]

---------------------------------------------------------------------------------------------------
## [b]10. [Optional technical explanation] Inputs, alerts, background, and resets[/b]
---------------------------------------------------------------------------------------------------

[pine]
The script uses 10 visible inputs to keep the user interface focused:

1. Signal preset
   Controls strictness:
   Aggressive, Balanced, Conservative

2. Buy drop from recent high %
   Controls the minimum pullback before Buy can qualify.

3. DCA1 drop below Buy %
   Controls how far price must move below Buy before DCA1 can arm.

4. DCA2 drop below DCA1 %
   Controls how far price must move below DCA1 before DCA2 can arm.

5. Rejection wick %
   Controls the minimum lower-wick rejection requirement.

6. VIX mode
   Off, Conservative, Very Strict

7. VIX symbol
   Default VIX source is CBOE:VIX.

8. VIX stress percentile
   Main percentile threshold for elevated fear.

9. DCA2 VIX cooling drop
   Required cooling from the recent VIX percentile peak.

10. Low VIX color percentile
    Defines unusually low VIX percentile conditions.

Hidden internal defaults include:

* RSI length
* fast EMA length
* ATR length
* Bollinger Band length and multiplier
* volume average length
* swing length
* cooldown bars
* profile-based lookbacks
* adaptive timing sample rules
* VIX rare-event thresholds
* VIX background transparency
* reset timing

Alerts:
The script includes seven alert conditions:

1. Buy confirmed
2. DCA1 zone armed
3. DCA1 confirmed
4. DCA2 zone armed
5. DCA2 confirmed
6. VIX cooled after high
7. VIX too low percentile

Alert meaning:

* Armed alerts mean price reached a DCA zone, but confirmation is not complete.
* Confirmed alerts mean the full stage logic is complete.
* VIX alerts describe fear-regime behavior.

Background:
The script calculates high and low VIX percentile background conditions. In the current plotted version, the visible green background marks very high VIX percentile. This means elevated fear or volatility stress, not automatic bullishness.

Reset logic:
The script resets the active sequence when:

* DCA2 has completed and enough bars have passed.
* DCA1 did not appear inside the valid window after Buy.
* DCA2 did not appear inside the valid window after DCA1.

This prevents old signals from staying active forever and helps each staged sequence remain connected to the original recovery setup.

Publication note:
This description is written so users can understand the script without reading Pine code. It explains what the script does, why the components are combined, how the staged logic works, and how traders can use it responsibly.
[/pine]

[quote]Open-source transparency note: if any external open-source code, function, or logic was reused, the original author and source should be credited clearly in the publication.[/quote]

## Source Code

````pine
//@version=6
indicator("ID004 VIX Fear Timing Indicator", overlay=true, max_labels_count=500)

// =====================================================
// ID004 Level 1 Precision Dip Recovery
// Level 1 signal indicator. No orders. No strategy tester.
//
// Labels only:
// B  = BUY, red
// D1 = DCA1, yellow
// D2 = DCA2, green
//
// SELL is fully removed from this version.
// This indicator only identifies the staged entry waterfall:
// BUY -> optional DCA1 -> optional DCA2
//
// Conservative VIX logic:
// - VIX uses the currently open chart timeframe.
// - BUY uses conservative VIX stress.
// - DCA1 requires at least strict VIX stress.
// - DCA2 requires VIX to have been very high recently,
//   then cool/lower enough before allowing DCA2.
// - High VIX percentile background = green.
// - Low VIX percentile background = orange.
// =====================================================

// -------------------------
// 1. GUI inputs
// -------------------------
// Exactly 10 visible GUI inputs. Everything else uses internal defaults.
gSignal = "1. Signal Controls"
gVix = "2. VIX Precision"

// 1
signalPreset = input.string(
     "Balanced",
     "Signal preset",
     options=["Aggressive", "Balanced", "Conservative"],
     group=gSignal,
     tooltip="ⓘ Main strictness control. Aggressive gives earlier/more signals. Conservative waits for deeper and cleaner recovery setups."
)

// 2
buyDropPct = input.float(
     6.0,
     "BUY drop from recent high %",
     minval=0.1,
     step=0.1,
     group=gSignal,
     tooltip="ⓘ Minimum percentage drop from the recent lookback high before a BUY setup can qualify. The Signal preset adjusts the effective value."
)

// 3
d1DropPct = input.float(
     6.5,
     "DCA1 drop below BUY %",
     minval=0.1,
     step=0.1,
     group=gSignal,
     tooltip="ⓘ Adverse move below the BUY price before DCA1 can arm. The Signal preset adjusts the effective value."
)

// 4
d2DropPct = input.float(
     4.5,
     "DCA2 drop below DCA1 %",
     minval=0.1,
     step=0.1,
     group=gSignal,
     tooltip="ⓘ Further adverse move below the DCA1 price before DCA2 can arm. The Signal preset adjusts the effective value."
)

// 5
wickRejectPct = input.float(
     25.0,
     "Rejection wick %",
     minval=5,
     maxval=90,
     step=1,
     group=gSignal,
     tooltip="ⓘ Minimum lower-wick percentage used for DCA recovery/rejection confirmation. Higher values require stronger rejection."
)

// 6
vixPrecisionMode = input.string(
     "Conservative",
     "VIX mode",
     options=["Off", "Conservative", "Very Strict"],
     group=gVix,
     tooltip="ⓘ Off ignores VIX. Conservative makes BUY stricter and makes DCA1 at least strict. Very Strict requires stronger VIX evidence."
)

// 7
vixSymbol = input.symbol(
     "CBOE:VIX",
     "VIX symbol",
     group=gVix,
     tooltip="ⓘ Default is CBOE:VIX. Change only if your data provider uses a different VIX symbol."
)

// 8
vixStressPercentile = input.float(
     80.0,
     "VIX stress percentile >=",
     minval=50,
     maxval=99,
     step=1,
     group=gVix,
     tooltip="ⓘ Main VIX stress threshold. Higher values make VIX filtering more conservative. DCA1 uses strict stress, not just mild stress."
)

// 9
vixDca2CoolingDrop = input.float(
     12.0,
     "DCA2 VIX cooling drop",
     minval=1,
     maxval=50,
     step=1,
     group=gVix,
     tooltip="ⓘ DCA2 requires VIX percentile to have been very high recently, then cool by at least this many percentile points."
)

// 10
vixLowBgPercentile = input.float(
     15.0,
     "Low VIX color percentile <=",
     minval=1,
     maxval=40,
     step=1,
     group=gVix,
     tooltip="ⓘ Colors the chart background when VIX percentile is too low, which can indicate complacency/low-volatility risk."
)

// -------------------------
// Internal defaults hidden from GUI
// -------------------------
showWarning = true

dropSensitivity = signalPreset
dropValidation = "Percent only"

buyRecoveryRsi = 36.0

useAdaptiveTiming = true
minTimingSamples = 8
dcaMinPercentile = 20.0
dcaMaxPercentile = 92.0
cycleResetBars = 80

useVixForDca = true
allowIfVixMissing = true

vixHighPercentile = vixStressPercentile
vixJumpPercentile = 25.0
vixAbsoluteLevel = 28.0
vixRarePercentile = math.min(99.0, math.max(95.0, vixStressPercentile + 10.0))
vixRareAbsoluteLevel = 38.0
vixDca2WasHighPercentile = math.max(90.0, vixStressPercentile)

showVixExtremeBg = true
vixHighBgPercentile = math.max(90.0, vixStressPercentile)
vixBgTransparency = 88

// -------------------------
// 2. Constants
// -------------------------
rsiLen = 14
emaFastLen = 9
atrLen = 14
bbLen = 20
bbMult = 2.0
volLen = 20
swingLen = 8
cooldownBars = 8

// -------------------------
// 3. Timeframe profile
// -------------------------
is15 = timeframe.isminutes and timeframe.multiplier == 15
is30 = timeframe.isminutes and timeframe.multiplier == 30
is1h = timeframe.isminutes and timeframe.multiplier == 60
is4h = timeframe.isminutes and timeframe.multiplier == 240
is1d = timeframe.isdaily and timeframe.multiplier == 1
isSupportedTf = is15 or is30 or is1h or is4h or is1d

profile = is15 ? "15m" : is30 ? "30m" : is1h ? "1h" : is4h ? "4h" : is1d ? "1D" : "1h"

buyAtrDrop = profile == "15m" ? 1.2 : profile == "30m" ? 1.4 : profile == "1h" ? 1.8 : profile == "4h" ? 2.2 : 2.8
d1AtrDrop = profile == "15m" ? 0.8 : profile == "30m" ? 1.0 : profile == "1h" ? 1.2 : profile == "4h" ? 1.5 : 2.0
d2AtrDrop = profile == "15m" ? 1.0 : profile == "30m" ? 1.2 : profile == "1h" ? 1.5 : profile == "4h" ? 2.0 : 2.5

d1MinBase = profile == "15m" ? 10 : profile == "30m" ? 8 : profile == "1h" ? 6 : profile == "4h" ? 4 : 3
d1MaxBase = profile == "15m" ? 144 : profile == "30m" ? 120 : profile == "1h" ? 120 : profile == "4h" ? 90 : 60
d2MinBase = profile == "15m" ? 12 : profile == "30m" ? 10 : profile == "1h" ? 8 : profile == "4h" ? 5 : 4
d2MaxBase = profile == "15m" ? 168 : profile == "30m" ? 144 : profile == "1h" ? 168 : profile == "4h" ? 120 : 80

d1ConfirmDelay = profile == "15m" ? 3 : profile == "30m" ? 2 : profile == "1h" ? 2 : profile == "4h" ? 1 : 1
d2ConfirmDelay = profile == "15m" ? 5 : profile == "30m" ? 4 : profile == "1h" ? 3 : profile == "4h" ? 2 : 1

htf = profile == "15m" ? "60" : profile == "30m" ? "120" : profile == "1h" ? "240" : profile == "4h" ? "D" : "W"
fastDropBars = profile == "15m" ? 8 : profile == "30m" ? 6 : profile == "1h" ? 5 : profile == "4h" ? 4 : 3

// VIX uses the same timeframe currently open on the chart.
vixTf = timeframe.period

// Hidden profile-based lookbacks.
// Intraday charts use more VIX bars so percentile logic remains meaningful on the active timeframe.
lookbackBars = profile == "15m" ? 240 : profile == "30m" ? 200 : profile == "1h" ? 180 : profile == "4h" ? 120 : 90
vixLookback = profile == "15m" ? 1500 : profile == "30m" ? 1200 : profile == "1h" ? 1000 : profile == "4h" ? 504 : 252

dropMult = dropSensitivity == "Aggressive" ? 0.80 : dropSensitivity == "Conservative" ? 1.25 : 1.00
effBuyDropPct = buyDropPct * dropMult
effD1DropPct = d1DropPct * dropMult
effD2DropPct = d2DropPct * dropMult

// -------------------------
// 4. Helper functions
// -------------------------
f_percentile_int(int[] src, float p, int fallback) =>
    int n = array.size(src)
    if n == 0
        fallback
    else
        int[] tmp = array.copy(src)
        array.sort(tmp, order.ascending)
        int idx = int(math.round((p / 100.0) * (n - 1)))
        idx := math.max(0, math.min(idx, n - 1))
        array.get(tmp, idx)

f_push_sample(int[] arr, int value) =>
    if value > 0 and value < 5000
        array.push(arr, value)
        if array.size(arr) > 300
            array.shift(arr)

f_vix_pack() =>
    float _pct = ta.percentrank(close, vixLookback)
    float _jump = _pct - _pct[1]
    bool _vixFalling = close < close[1]
    bool _pctFalling = _pct < _pct[1]
    [close, _pct, _jump, _vixFalling, _pctFalling]

// -------------------------
// 5. Indicators
// -------------------------
rsi = ta.rsi(close, rsiLen)
emaFast = ta.ema(close, emaFastLen)
atr = ta.atr(atrLen)
atrPct = atr / close * 100.0
volMA = ta.sma(volume, volLen)
volOk = volume >= volMA
volSpike = volume > volMA * 1.5

[bbBasis, bbUpper, bbLower] = ta.bb(close, bbLen, bbMult)
macdLine = ta.ema(close, 12) - ta.ema(close, 26)
macdSignal = ta.ema(macdLine, 9)
macdHist = macdLine - macdSignal
macdImproving = macdHist > macdHist[1]

barRange = high - low
lowerWick = math.min(open, close) - low
lowerWickPct = barRange > 0 ? lowerWick / barRange * 100.0 : 0.0
bullCandle = close > open
strongLowerWick = lowerWickPct >= wickRejectPct
bullEngulf = close > open and close > high[1] and open <= close[1]

lookbackHigh = ta.highest(high, lookbackBars)
dropFromLookbackHighPct = lookbackHigh > 0 ? (lookbackHigh - close) / lookbackHigh * 100.0 : 0.0
dropFromLookbackHighAtr = atr > 0 ? (lookbackHigh - close) / atr : 0.0

supportLevel = ta.lowest(low, swingLen)[1]
supportReclaim = low < supportLevel and close > supportLevel
priceLowerLow = low < ta.lowest(low, swingLen)[1]
rsiHigherLow = rsi > ta.lowest(rsi, swingLen)[1]
bullDiv = priceLowerLow and rsiHigherLow and rsi < 58
bbReclaim = low < bbLower and close > bbLower
oversoldReclaim = ta.lowest(rsi, 8) < 32 and rsi > buyRecoveryRsi and rsi > rsi[1]
structureShift = (close > ta.highest(high, swingLen)[1] and close > emaFast and macdImproving) or (close > emaFast and low > low[1] and macdImproving)

// Higher-timeframe context.
htfClose = request.security(syminfo.tickerid, htf, close)
htfEMA50 = request.security(syminfo.tickerid, htf, ta.ema(close, 50))
htfEMA200 = request.security(syminfo.tickerid, htf, ta.ema(close, 200))
htfRSI = request.security(syminfo.tickerid, htf, ta.rsi(close, rsiLen))
htfBullCandle = request.security(syminfo.tickerid, htf, close > open)
htfRSIUp = htfRSI > htfRSI[1]
htfMacdHist = request.security(syminfo.tickerid, htf, (ta.ema(close, 12) - ta.ema(close, 26)) - ta.ema(ta.ema(close, 12) - ta.ema(close, 26), 9))
htfMacdImproving = htfMacdHist > htfMacdHist[1]
htfDanger = htfClose < htfEMA200 and htfEMA50 < htfEMA200 and htfRSI < 40 and not htfRSIUp
regimeOk = not htfDanger

fastDropPct = (ta.highest(high, fastDropBars) - close) / ta.highest(high, fastDropBars) * 100.0
crash = fastDropPct > math.max(effBuyDropPct * 2.0, atrPct * 4.5) and volume > volMA * 2.0 and close < emaFast
crashOk = not crash

// -------------------------
// 6. VIX precision logic
// -------------------------
[vixClose, vixPercentile, vixPercentileJump, vixFalling, vixPercentileFalling] = request.security(
     vixSymbol,
     vixTf,
     f_vix_pack(),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

vixModeOff = vixPrecisionMode == "Off"
vixModeConservative = vixPrecisionMode == "Conservative"
vixModeVeryStrict = vixPrecisionMode == "Very Strict"

vixDataOk = not na(vixClose) and not na(vixPercentile)
vixMissingOk = allowIfVixMissing and not vixDataOk

vixAbsoluteOk = vixDataOk and vixClose >= vixAbsoluteLevel
vixHighPercentileOk = vixDataOk and vixPercentile >= vixHighPercentile
vixJumpOk = vixDataOk and not na(vixPercentileJump) and vixPercentileJump >= vixJumpPercentile
vixRareEvent = vixDataOk and (vixPercentile >= vixRarePercentile or vixClose >= vixRareAbsoluteLevel)

vixStressBasic = vixAbsoluteOk or vixHighPercentileOk or vixJumpOk or vixRareEvent
vixStressStrong = vixRareEvent or (vixAbsoluteOk and vixHighPercentileOk) or (vixJumpOk and (vixAbsoluteOk or vixHighPercentileOk))

// This helps avoid buying too early into panic unless the local chart also confirms recovery.
vixFearCooling = vixDataOk and vixStressBasic and (vixFalling or vixPercentileFalling or vixRareEvent)

// DCA2 is intentionally different from DCA1:
// DCA1 must have strict VIX stress.
// DCA2 must show that VIX was very high recently and is now cooling/lower.
vixCoolingLookback = profile == "15m" ? 192 : profile == "30m" ? 160 : profile == "1h" ? 120 : profile == "4h" ? 60 : 30
vixRecentPeakPercentile = ta.highest(vixPercentile, vixCoolingLookback)
vixWasTooHighRecently = vixDataOk and vixRecentPeakPercentile >= vixDca2WasHighPercentile
vixCooledFromPeak = vixDataOk and vixWasTooHighRecently and vixPercentile <= vixRecentPeakPercentile - vixDca2CoolingDrop
vixCoolingButStillElevated = vixDataOk and vixWasTooHighRecently and vixPercentileFalling and vixPercentile >= vixHighPercentile
vixDca2CoolingOk = vixCooledFromPeak or (vixRareEvent and vixFearCooling) or vixCoolingButStillElevated

// VIX score is used to improve precision instead of acting as only a blunt filter.
vixScoreValue = 0
vixScoreValue += vixHighPercentileOk ? 1 : 0
vixScoreValue += vixAbsoluteOk ? 1 : 0
vixScoreValue += vixJumpOk ? 1 : 0
vixScoreValue += vixStressStrong ? 1 : 0
vixScoreValue += vixRareEvent ? 2 : 0
vixScoreValue += vixFearCooling ? 1 : 0
vixScoreValue += vixWasTooHighRecently ? 1 : 0
vixScoreValue += vixDca2CoolingOk ? 1 : 0

vixBuyOk = vixModeOff ? true : vixModeConservative ? (vixMissingOk or vixStressBasic or vixFearCooling) : (vixMissingOk or vixStressStrong or vixRareEvent)

// Rare VIX events can override the higher-timeframe danger filter,
// but only when the chart itself is showing recovery.
rareRecoveryRegimeOk = vixRareEvent and (htfRSIUp or htfMacdImproving) and (structureShift or bullCandle or close > emaFast)
buyRegimeOk = regimeOk or rareRecoveryRegimeOk
dcaRegimeOk = regimeOk or rareRecoveryRegimeOk

// Data Window only.
plot(vixClose, title="VIX Close", display=display.data_window)
plot(vixPercentile, title="VIX Percentile", display=display.data_window)
plot(vixPercentileJump, title="VIX Percentile Jump", display=display.data_window)
plot(vixRecentPeakPercentile, title="VIX Recent Peak Percentile", display=display.data_window)
plot(vixScoreValue, title="VIX Precision Score", display=display.data_window)

// -------------------------
// 7. Historical timing samples
// -------------------------
var int[] sampleBuyToD1 = array.new_int()
var int[] sampleD1ToD2 = array.new_int()

adaptiveD1MinRaw = useAdaptiveTiming and array.size(sampleBuyToD1) >= minTimingSamples ? f_percentile_int(sampleBuyToD1, dcaMinPercentile, d1MinBase) : d1MinBase
adaptiveD1Max = useAdaptiveTiming and array.size(sampleBuyToD1) >= minTimingSamples ? f_percentile_int(sampleBuyToD1, dcaMaxPercentile, d1MaxBase) : d1MaxBase
adaptiveD2MinRaw = useAdaptiveTiming and array.size(sampleD1ToD2) >= minTimingSamples ? f_percentile_int(sampleD1ToD2, dcaMinPercentile, d2MinBase) : d2MinBase
adaptiveD2Max = useAdaptiveTiming and array.size(sampleD1ToD2) >= minTimingSamples ? f_percentile_int(sampleD1ToD2, dcaMaxPercentile, d2MaxBase) : d2MaxBase

adaptiveD1Min = math.max(adaptiveD1MinRaw, d1MinBase)
adaptiveD2Min = math.max(adaptiveD2MinRaw, d2MinBase)
adaptiveD1Max := math.max(adaptiveD1Max, adaptiveD1Min + 1)
adaptiveD2Max := math.max(adaptiveD2Max, adaptiveD2Min + 1)

// -------------------------
// 8. Virtual state
// -------------------------
var int state = 0
var float buyPrice = na
var float d1Price = na
var float d2Price = na
var int buyBar = na
var int d1Bar = na
var int d2Bar = na
var int lastResetBar = na
var bool d1Armed = false
var bool d2Armed = false
var int d1ArmedBar = na
var int d2ArmedBar = na

inBasket = state > 0
barsSinceBuy = inBasket ? bar_index - buyBar : na
barsSinceD1 = state >= 2 ? bar_index - d1Bar : na
barsSinceD2 = state == 3 ? bar_index - d2Bar : na
cooldownOk = na(lastResetBar) or bar_index - lastResetBar > cooldownBars

basketAvg = state == 1 ? buyPrice : state == 2 ? (buyPrice + d1Price) / 2.0 : state == 3 ? (buyPrice + d1Price + d2Price) / 3.0 : na

resetAfterD2 = state == 3 and barsSinceD2 >= cycleResetBars
resetExpiredD1 = state == 1 and barsSinceBuy > adaptiveD1Max
resetExpiredD2 = state == 2 and barsSinceD1 > adaptiveD2Max
resetSignal = resetAfterD2 or resetExpiredD1 or resetExpiredD2

if resetSignal
    state := 0
    buyPrice := na
    d1Price := na
    d2Price := na
    buyBar := na
    d1Bar := na
    d2Bar := na
    d1Armed := false
    d2Armed := false
    d1ArmedBar := na
    d2ArmedBar := na
    lastResetBar := bar_index

// -------------------------
// 9. BUY signal
// -------------------------
buyDropPercentOk = dropFromLookbackHighPct >= effBuyDropPct
buyDropAtrOk = dropFromLookbackHighAtr >= buyAtrDrop
meaningfulDrop = dropValidation == "Percent only" ? buyDropPercentOk : dropValidation == "Percent or ATR" ? (buyDropPercentOk or buyDropAtrOk) : (buyDropPercentOk and buyDropAtrOk)

wasOversold = ta.lowest(rsi, 10) < 35
momentumRecovery = rsi > rsi[1] and (ta.crossover(rsi, 32) or rsi > buyRecoveryRsi)
priceRecovery = close > emaFast or close > high[1]

buySetup = meaningfulDrop and wasOversold and momentumRecovery and priceRecovery

buyScoreValue = 0
buyScoreValue += meaningfulDrop ? 1 : 0
buyScoreValue += wasOversold ? 1 : 0
buyScoreValue += momentumRecovery ? 1 : 0
buyScoreValue += priceRecovery ? 1 : 0
buyScoreValue += oversoldReclaim ? 1 : 0
buyScoreValue += bbReclaim ? 1 : 0
buyScoreValue += supportReclaim ? 2 : 0
buyScoreValue += bullDiv ? 2 : 0
buyScoreValue += strongLowerWick ? 1 : 0
buyScoreValue += macdImproving ? 1 : 0
buyScoreValue += structureShift ? 2 : 0
buyScoreValue += volOk ? 1 : 0
buyScoreValue += vixStressStrong ? 1 : 0
buyScoreValue += vixRareEvent ? 2 : 0
buyScoreValue += vixFearCooling ? 1 : 0

buyQualityMin = vixModeVeryStrict ? 8 : 7
buyQualityOk = vixModeOff ? true : buyScoreValue >= buyQualityMin

buySignal = state == 0 and cooldownOk and buyRegimeOk and crashOk and vixBuyOk and buySetup and buyQualityOk

if buySignal
    state := 1
    buyPrice := close
    d1Price := na
    d2Price := na
    buyBar := bar_index
    d1Bar := na
    d2Bar := na
    d1Armed := false
    d2Armed := false
    d1ArmedBar := na
    d2ArmedBar := na

// -------------------------
// 10. DCA1 signal
// -------------------------
d1ZonePct = state >= 1 ? buyPrice * (1.0 - effD1DropPct / 100.0) : na
d1ZoneAtr = state >= 1 ? buyPrice - atr * d1AtrDrop : na
d1Zone = state >= 1 ? (dropValidation == "Percent only" ? d1ZonePct : dropValidation == "Percent or ATR" ? math.max(d1ZonePct, d1ZoneAtr) : math.min(d1ZonePct, d1ZoneAtr)) : na

inD1Window = state == 1 and barsSinceBuy >= adaptiveD1Min and barsSinceBuy <= adaptiveD1Max
d1DropPercentOk = state == 1 and low <= d1ZonePct
d1DropAtrOk = state == 1 and low <= d1ZoneAtr
d1DropOk = dropValidation == "Percent only" ? d1DropPercentOk : dropValidation == "Percent or ATR" ? (d1DropPercentOk or d1DropAtrOk) : (d1DropPercentOk and d1DropAtrOk)
d1ZoneReached = state == 1 and inD1Window and close < buyPrice and d1DropOk

if d1ZoneReached and not d1Armed
    d1Armed := true
    d1ArmedBar := bar_index

if state == 1 and barsSinceBuy > adaptiveD1Max
    d1Armed := false
    d1ArmedBar := na

recoveryCandleD1 = bullCandle or close > high[1] or close > emaFast or close > d1Zone
B1 = bullDiv and rsi > rsi[1]
B2 = bbReclaim and (strongLowerWick or bullCandle or macdImproving)
B3 = (supportReclaim or strongLowerWick) and (rsi > rsi[1] or volOk)

BscoreValue = 0
BscoreValue += bullDiv ? 2 : 0
BscoreValue += bbReclaim ? 1 : 0
BscoreValue += supportReclaim ? 2 : 0
BscoreValue += strongLowerWick ? 1 : 0
BscoreValue += bullCandle ? 1 : 0
BscoreValue += macdImproving ? 1 : 0
BscoreValue += oversoldReclaim ? 1 : 0
Bscore = BscoreValue >= 3

d1TechnicalOk = B1 or B2 or B3 or Bscore

d1ScoreValue = BscoreValue
d1ScoreValue += vixStressBasic ? 1 : 0
d1ScoreValue += vixStressStrong ? 1 : 0
d1ScoreValue += vixRareEvent ? 2 : 0
d1ScoreValue += vixFearCooling ? 1 : 0

d1VixOk = not useVixForDca or vixModeOff ? true : vixModeConservative ? (vixMissingOk or vixStressStrong or vixRareEvent) : (vixMissingOk or vixRareEvent or (vixStressStrong and vixFearCooling))
d1QualityMin = vixModeVeryStrict ? 6 : 5
d1QualityOk = not useVixForDca or vixModeOff ? d1TechnicalOk : d1ScoreValue >= d1QualityMin

d1ArmedLongEnough = d1Armed and not na(d1ArmedBar) and bar_index - d1ArmedBar >= d1ConfirmDelay
d1Signal = state == 1 and d1Armed and d1ArmedLongEnough and inD1Window and recoveryCandleD1 and dcaRegimeOk and crashOk and d1VixOk and d1TechnicalOk and d1QualityOk

if d1Signal
    f_push_sample(sampleBuyToD1, barsSinceBuy)
    state := 2
    d1Price := close
    d1Bar := bar_index
    d1Armed := false
    d1ArmedBar := na
    d2Armed := false
    d2ArmedBar := na

// -------------------------
// 11. DCA2 signal
// -------------------------
d2ZonePct = state >= 2 ? d1Price * (1.0 - effD2DropPct / 100.0) : na
d2ZoneAtr = state >= 2 ? d1Price - atr * d2AtrDrop : na
d2Zone = state >= 2 ? (dropValidation == "Percent only" ? d2ZonePct : dropValidation == "Percent or ATR" ? math.max(d2ZonePct, d2ZoneAtr) : math.min(d2ZonePct, d2ZoneAtr)) : na

inD2Window = state == 2 and barsSinceD1 >= adaptiveD2Min and barsSinceD1 <= adaptiveD2Max
d2DropPercentOk = state == 2 and low <= d2ZonePct
d2DropAtrOk = state == 2 and low <= d2ZoneAtr
d2DropOk = dropValidation == "Percent only" ? d2DropPercentOk : dropValidation == "Percent or ATR" ? (d2DropPercentOk or d2DropAtrOk) : (d2DropPercentOk and d2DropAtrOk)
d2ZoneReached = state == 2 and inD2Window and close < basketAvg and d2DropOk

if d2ZoneReached and not d2Armed
    d2Armed := true
    d2ArmedBar := bar_index

if state == 2 and barsSinceD1 > adaptiveD2Max
    d2Armed := false
    d2ArmedBar := na

recoveryCandleD2 = bullCandle or close > high[1] or structureShift or close > d2Zone
C1 = ((htfRSI < 45 and htfRSIUp and htfBullCandle) or htfMacdImproving) and (bullCandle or close > emaFast)
capitulation = volSpike and strongLowerWick and barRange > atr * 1.1
C2 = capitulation or (capitulation[1] and bullCandle and close > (high[1] + low[1]) / 2.0)
C3 = structureShift and rsi > rsi[1]

CscoreValue = 0
CscoreValue += C1 ? 2 : 0
CscoreValue += C2 ? 2 : 0
CscoreValue += C3 ? 2 : 0
CscoreValue += strongLowerWick ? 1 : 0
CscoreValue += bullEngulf ? 1 : 0
CscoreValue += volSpike ? 1 : 0
CscoreValue += htfMacdImproving ? 1 : 0
Cscore = CscoreValue >= 4

d2TechnicalOk = C1 or C2 or C3 or Cscore

d2ScoreValue = CscoreValue
d2ScoreValue += vixStressBasic ? 1 : 0
d2ScoreValue += vixStressStrong ? 1 : 0
d2ScoreValue += vixRareEvent ? 2 : 0
d2ScoreValue += vixFearCooling ? 1 : 0
d2ScoreValue += vixWasTooHighRecently ? 1 : 0
d2ScoreValue += vixDca2CoolingOk ? 2 : 0

d2VixOk = not useVixForDca or vixModeOff ? true : vixModeConservative ? (vixMissingOk or vixDca2CoolingOk) : (vixMissingOk or (vixDca2CoolingOk and (vixRecentPeakPercentile >= vixRarePercentile or vixRareEvent)))
d2QualityMin = vixModeVeryStrict ? 7 : 6
d2QualityOk = not useVixForDca or vixModeOff ? d2TechnicalOk : d2ScoreValue >= d2QualityMin

d2ArmedLongEnough = d2Armed and not na(d2ArmedBar) and bar_index - d2ArmedBar >= d2ConfirmDelay
d2Signal = state == 2 and d2Armed and d2ArmedLongEnough and inD2Window and recoveryCandleD2 and dcaRegimeOk and crashOk and d2VixOk and d2TechnicalOk and d2QualityOk

if d2Signal
    f_push_sample(sampleD1ToD2, barsSinceD1)
    state := 3
    d2Price := close
    d2Bar := bar_index
    d2Armed := false
    d2ArmedBar := na

// -------------------------
// 12. Compact labels only
// -------------------------
plotshape(buySignal, title="BUY", text="BUY", style=shape.labelup, location=location.belowbar, color=color.red, textcolor=color.white, size=size.small)
plotshape(d1Signal, title="DCA1", text="DCA1", style=shape.labelup, location=location.belowbar, color=color.yellow, textcolor=color.black, size=size.small)
plotshape(d2Signal, title="DCA2", text="DCA2", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.small)



// -------------------------
// 14. VIX percentile background
// -------------------------
// Green background  = VIX percentile is very high, meaning fear/stress is elevated.
// Orange background = VIX percentile is very low, meaning complacency/low-volatility risk is elevated.
// The background is always enabled to keep the GUI limited to the 10 most important controls.
vixHighExtremeBg = showVixExtremeBg and vixDataOk and vixPercentile >= vixHighBgPercentile
vixLowExtremeBg = showVixExtremeBg and vixDataOk and vixPercentile <= vixLowBgPercentile

vixBgColor = vixHighExtremeBg ? color.new(color.rgb(108, 255, 82), vixBgTransparency) :
     na

bgcolor(vixBgColor, title="VIX Percentile Extreme Background")

// -------------------------
// 15. Seven useful alerts
// -------------------------
// These are designed to be practical:
// 1) confirmed staged-entry signals,
// 2) early DCA zone warnings,
// 3) VIX regime warnings that matter for this system.
//
// Pine v6 bool series are not nullable, so do not use nz() on bool values.
d1ArmedAlert = d1Armed and not d1Armed[1]
d2ArmedAlert = d2Armed and not d2Armed[1]
vixDca2CoolingAlert = vixDca2CoolingOk and not vixDca2CoolingOk[1]
vixLowExtremeAlert = vixLowExtremeBg and not vixLowExtremeBg[1]

alertcondition(buySignal, "01 BUY confirmed", "BUY confirmed: staged entry started after drop, recovery, regime, and VIX checks.")
alertcondition(d1ArmedAlert, "02 DCA1 zone armed", "DCA1 zone reached: waiting for recovery confirmation.")
alertcondition(d1Signal, "03 DCA1 confirmed", "DCA1 confirmed: recovery/rejection confirmed with strict VIX stress.")
alertcondition(d2ArmedAlert, "04 DCA2 zone armed", "DCA2 zone reached: deep adverse move, waiting for stronger recovery confirmation.")
alertcondition(d2Signal, "05 DCA2 confirmed", "DCA2 confirmed: final staged entry after deep drop and VIX cooling logic.")
alertcondition(vixDca2CoolingAlert, "06 VIX cooled after high", "VIX was very high recently and has now cooled/lowered enough for DCA2 logic.")
alertcondition(vixLowExtremeAlert, "07 VIX too low percentile", "VIX percentile is too low: complacency/low-volatility regime detected.")
````
