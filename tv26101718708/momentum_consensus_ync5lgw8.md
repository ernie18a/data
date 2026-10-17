# Momentum Consensus

- url: https://www.tradingview.com/script/YnC5lgW8/
- type: indicator
- pine_id: PUB;9fbb8475730d4507926ac0e84a0023ca
- version: 1.0

## Description

Momentum Consensus reduces three momentum readings to a single agreement view. Each of DI-Power, BBP and the MACD-V histogram is reduced to its sign (above zero, below zero, or exactly zero), and the pane shows the net as one column: its height is the count above zero minus the count below zero (range -3 to +3), green and pointing up when bulls lead, red and pointing down when bears lead, and nothing when the two sides cancel. Only one side is ever drawn, so the column itself is the net stance. All three inputs are momentum or trend readings - DI-Power is (DI+ minus DI-) weighted by ADX, BBP is Elder Bull Bear Power over ATR, and MACD-V is the ATR-normalized MACD histogram - so the tally is a clean read of momentum agreement rather than a mix of different dimensions. Each reading is divided by its own rolling maxAbs; that scaling never subtracts a baseline, so each keeps its true zero and sign, and since the tally reads sign only, the scaling does not change the count, it just keeps each reading matching its source. When exactly one reading is on a side, a one-letter badge marks the lone reading (D for DI-Power, B for BBP, M for MACD-V) in its own colour, pinned to the top edge for a lone bull and the bottom edge for a lone bear so it never overlaps the column. Two alerts are available for when the net flips sides (its sign crosses zero), one for each direction. Everything is inferred from OHLCV. Built on public, well-documented concepts, implemented from scratch in original Pine. Descriptive context only, not a signal and not financial advice.

## Source Code

````pine
//@version=6
// =============================================================================
// Momentum Consensus - vote tally of three momentum readings
// -----------------------------------------------------------------------------
// Publish name : Momentum Consensus - DI-Power / BBP / MACD-V
// Short title  : MomConsensus
// Category     : Trend Analysis
//
// Three momentum readings are each reduced to a single sign (above zero, below
// zero, or exactly zero) and tallied into one consensus pane. Instead of plotting
// three lines, this shows the net agreement as a single column: its height is the
// count above zero minus the count below zero (range -3..+3), green and pointing
// up when bulls lead, red and pointing down when bears lead, and nothing when the
// two sides cancel. Only one side is ever drawn. The readings are not plotted.
//
// The three readings, each computed like its standalone source indicator:
//   DI-Power : (DI+ - DI-) * (ADX/100), from "Directional Power + BBP".
//   BBP      : Elder Bull Bear Power ((H-EMA)+(L-EMA)) / ATR, same source.
//   MACD-V   : MACD-V histogram (MACD-V minus its signal).
// All three are momentum / trend readings (direction, force, acceleration), so
// the tally is a clean read of momentum agreement. Each is divided by its own
// rolling maxAbs (dividing never subtracts a baseline, so the true zero and sign
// are kept). Scaling does not affect the tally, which reads sign only - it is
// kept so each reading matches its source.
//
// Badges: when exactly one reading is on a side, a one-letter badge marks the
// lone reading next to its column (D = DI-Power, B = BBP, M = MACD-V), each on
// its own colour. Both sides are judged independently.
//
// Alerts: when the net flips from one side to the other (its sign crosses zero),
// an alert can fire, with a separate condition for each direction.
//
// Descriptive context only - not a signal, not financial advice.
// =============================================================================
indicator("Momentum Consensus", shorttitle = "MomConsensus", overlay = false, max_labels_count = 500)

// ----------------------------- Inputs --------------------------------
string GRP_SHOW = "Display"
color colUp    = input.color(#26A69A, "Net column when bulls lead", group = GRP_SHOW)
color colDn    = input.color(#EF5350, "Net column when bears lead", group = GRP_SHOW)
bool  showBadges = input.bool(true, "Badge the lone reading when a side has exactly 1", group = GRP_SHOW)
color colDi    = input.color(#26C6DA, "DI-Power badge (D)",  group = GRP_SHOW)
color colBbp   = input.color(#FF9800, "BBP badge (B)",       group = GRP_SHOW)
color colMacdv = input.color(#EC407A, "MACD-V badge (M)",    group = GRP_SHOW)

string GRP_DI = "DI-Power + BBP (same as source)"
int dmiLength    = input.int(14, "DMI length", minval = 1, group = GRP_DI)
int adxSmooth    = input.int(14, "ADX smoothing", minval = 1, group = GRP_DI)
int bbpEmaLen    = input.int(13, "BBP EMA (Elder-Ray)", minval = 1, group = GRP_DI)
int bbpAtrLen    = input.int(14, "BBP ATR length", minval = 1, group = GRP_DI)
int diNormLook   = input.int(100, "DI-Power display scale lookback (maxAbs)", minval = 10, group = GRP_DI)
int bbpNormLook  = input.int(100, "BBP display scale lookback (maxAbs)", minval = 10, group = GRP_DI)

string GRP_MV = "MACD-V (same as source)"
int mvFast = input.int(12, "Fast EMA", minval = 1, group = GRP_MV)
int mvSlow = input.int(26, "Slow EMA", minval = 1, group = GRP_MV)
int mvAtr  = input.int(26, "ATR length", minval = 1, group = GRP_MV)
int mvSig  = input.int(9,  "Signal EMA", minval = 1, group = GRP_MV)
int mvNormLook = input.int(100, "MACD-V display scale lookback (maxAbs)", minval = 10, group = GRP_MV)

// ====================== 1. DI-Power (maxAbs-scaled, true sign) ===============
// (DI+ - DI-) weighted by ADX scaled to 0..1, identical to the source, then
// divided by its own rolling maxAbs to bring it onto the shared -1..+1 scale.
// maxAbs only divides (never subtracts), so the true sign and zero are kept.
[diPlus, diMinus, adxValue] = ta.dmi(dmiLength, adxSmooth)
float diPowerRaw = (diPlus - diMinus) * (adxValue / 100.0)
float diMaxAbs   = ta.highest(math.abs(diPowerRaw), diNormLook)
float diPower    = diMaxAbs != 0 ? diPowerRaw / diMaxAbs : 0.0

// ====================== 2. BBP (Elder, ATR-normalised, maxAbs-scaled) ========
// Elder Bull Bear Power on its EMA divided by ATR, identical to the source, then
// divided by its own rolling maxAbs onto the shared -1..+1 scale (sign/zero kept).
float bbpEma     = ta.ema(close, bbpEmaLen)
float bbpAtr     = ta.atr(bbpAtrLen)
float bbpPowerRaw = bbpAtr > 0 ? ((high - bbpEma) + (low - bbpEma)) / bbpAtr : 0.0
float bbpMaxAbs  = ta.highest(math.abs(bbpPowerRaw), bbpNormLook)
float bbpPower   = bbpMaxAbs != 0 ? bbpPowerRaw / bbpMaxAbs : 0.0

// ====================== 3. MACD-V histogram (maxAbs-scaled) ==================
// MACD (ATR-normalised, the "MACD-V" form) minus its signal = the histogram,
// then divided by its own rolling maxAbs onto the shared -1..+1 scale. maxAbs
// only divides (never subtracts), so the histogram's sign and zero are kept.
float emaFast = ta.ema(close, mvFast)
float emaSlow = ta.ema(close, mvSlow)
float mvAtrVal = ta.atr(mvAtr)
float macdv   = mvAtrVal > 0 ? (emaFast - emaSlow) / mvAtrVal * 100.0 : 0.0
float mvSignal = ta.ema(macdv, mvSig)
float macdvHistRaw = macdv - mvSignal
float mvMaxAbs  = ta.highest(math.abs(macdvHistRaw), mvNormLook)
float macdvHist = mvMaxAbs != 0 ? macdvHistRaw / mvMaxAbs : 0.0

// --------------------------- Consensus tally -------------------------
// Count how many of the three readings are above / below zero at this bar (a
// reading sitting exactly at zero counts for neither side). These two counts
// feed the single net column below; the readings themselves are not plotted.
int upCount = (diPower > 0 ? 1 : 0) + (bbpPower > 0 ? 1 : 0) + (macdvHist > 0 ? 1 : 0)
int dnCount = (diPower < 0 ? 1 : 0) + (bbpPower < 0 ? 1 : 0) + (macdvHist < 0 ? 1 : 0)

// Net tally = count above zero minus count below zero (range -3..+3). A single
// column shows the net: green up when net > 0, red down when net < 0, nothing
// when net is 0. Only one side is ever drawn, so the column itself is the net
// stance and there is no separate net line.
int netCount = upCount - dnCount
color netColor = netCount > 0 ? colUp : colDn
plot(netCount != 0 ? netCount : na, "Net (bull - bear)", style = plot.style_columns, color = netColor)
hline(0, "Zero", color = color.new(color.gray, 40), linestyle = hline.style_solid)

// Alerts on the net tally crossing zero (a flip in which side leads). After
// adding the indicator, create an alert in TradingView and pick one condition.
bool netCrossUp   = ta.crossover(netCount, 0)
bool netCrossDown = ta.crossunder(netCount, 0)
alertcondition(netCrossUp,   title = "Net crossed above zero (turned bullish)", message = "Momentum Consensus: net crossed above zero - bulls now hold the majority.")
alertcondition(netCrossDown, title = "Net crossed below zero (turned bearish)", message = "Momentum Consensus: net crossed below zero - bears now hold the majority.")

// When exactly one reading is on a side, a one-letter badge names that lone
// reading: D = DI-Power, B = BBP, M = MACD-V, each on its own colour with white
// text. Badges are pinned to the top / bottom edge of the pane (outside the
// -3..+3 column range) so they never overlap the net column: a lone bull badge
// sits at the top, a lone bear badge at the bottom. Each side is judged
// independently, so a one-up / one-down bar can show a badge on both edges. Pine
// has no true circular text label, so this uses a filled coloured box (closest).
string upLetter = diPower > 0 ? "D" : bbpPower > 0 ? "B" : "M"
color  upBadge  = diPower > 0 ? colDi : bbpPower > 0 ? colBbp : colMacdv
string dnLetter = diPower < 0 ? "D" : bbpPower < 0 ? "B" : "M"
color  dnBadge  = diPower < 0 ? colDi : bbpPower < 0 ? colBbp : colMacdv

if showBadges and upCount == 1
    label.new(bar_index, 4, upLetter, color = upBadge, textcolor = color.white, style = label.style_label_center, size = size.tiny)
if showBadges and dnCount == 1
    label.new(bar_index, -4, dnLetter, color = dnBadge, textcolor = color.white, style = label.style_label_center, size = size.tiny)
````
