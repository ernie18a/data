<!-- tradingview-pine-id: PUB;2700a00c2fb042e892308fb94ebbe3e7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# BBMA Trend & Momentum

Source: https://www.tradingview.com/script/eteZZ3pv-BBMA-Trend-Momentum/

## Description

BBMA Trend & Momentum

The BBMA structure read as one running sequence rather than a handful of separate signals.

Most tools built on Bollinger Bands and moving averages draw the lines and leave the reading to
you. This one keeps a memory. It knows that momentum came first, that a reversal candle followed it, that the pullback target has already been reached, and it will not report the next step until the ones before it have happened. Each label on the chart is a position in that sequence, not an isolated condition that happened to be true.

Two of those steps are level touches rather than candle patterns, and they are treated
differently from the rest. That distinction is explained below and it matters.

THE LINES

Four families are drawn. Seven individual lines carry every rule in the script.

Bollinger Bands  SMA 20 with deviation 2, giving Upper, Mid and Lower
LW MA on the HIGH weighted averages of the candle HIGH, drawn in the upper colour
LW MA on the LOW weighted averages of the candle LOW, drawn in the lower colour
EMA 50 on Close, drawn as a slower reference

The High averages sit above price and the Low averages below it, because of what they are
averaging. That is what forms the two bands the price runs between.

The seven lines every rule is written against are the three Bollinger Bands and the 5 and 10
period LW MAs on each side. Those four averages are drawn SOLID. Periods 6 to 9 are drawn DASHED, exist only to show the shape of the band, and sit on their own switch so you can take them off and see for yourself that nothing is calculated from them. Within each band the 5 sits nearer to price and the 10 further out.

The EMA 50 is drawn and nothing is measured from it either. It is there as background context for your own reading, and it can be switched off without changing a single label.

THE SEQUENCE

Upper and Lower name the band an event belongs to. Every rule below has an exact mirror on the other side, so only the Upper form is spelled out.

CSM - Candlestick Momentum
LW MA 5 High is above the Upper BB, and the candle CLOSES above LW MA 5 High.
The close is therefore beyond the outer band as well, without needing to be tested for it.

EX - Extreme
A CSM has already happened and its Extreme has not been taken yet. LW MA 5 High is still
outside the Upper BB, but a candle now CLOSES back below it. That candle must not reach down to LW MA 5 Low, LW MA 10 Low, or the Mid BB. Touching any one of the three disqualifies it. Exactly one Extreme belongs to one CSM. For another Extreme, a new CSM has to come first.

MTP - Mandatory Take Profit
After an Extreme, the first time price reaches LW MA 5 Low or LW MA 10 Low.
If a new CSM or a new MTM arrives before that touch, the MTP is cancelled and a fresh Extreme
has to form before it can be looked for again.

MLV - Market Volume Lost
After the MTP has been reached, a candle rises to the Upper BB but cannot CLOSE beyond it, and closes at or above the Mid BB. The band was tested and refused.

CSD - Candlestick Direction
A candle that opens on one side of the Mid BB and CLOSES through it, and in the same candle
closes beyond BOTH LW MA 5 and LW MA 10 on the side it broke into. An Upper CSD breaks upward through the Mid BB and both High averages; a Lower CSD breaks downward through the Mid BB and both Low averages. CSD is named by the direction it broke, not by which cycle it interrupted.

MTM - Momentum Push
After a CSM, price falls back below the Upper BB without ever CLOSING below the Mid BB, then
closes above the Upper BB again. That renewed push is the MTM candle. It is not itself a CSM,
which is what separates the two - and because it is not a CSM, it does not open the door to a
new Extreme either. It only clears whatever the previous CSM had left waiting.

RE - Re-Entry
The touch that follows CSM, MTM or CSD. An upper-band sequence looks for LW MA 5 Low or LW MA 10 Low; a lower-band sequence looks for LW MA 5 High or LW MA 10 High. Three kinds are marked separately, because they arrive from three different places:

CSM RE   a pullback that was followed by a full CSM
MTM RE   a pullback that was followed by an MTM push
CSD RE   the pullback after a CSD

WHAT IS READ WHEN

This is the part worth being precise about.

CSM, EX, MLV, CSD and MTM are structure. They are decided on the CLOSE of a candle, and once
decided they never change.

MTP and RE are not patterns, they are level touches. A touch happens at the moment price reaches the level, not when the candle finishes, so both are read on the RUNNING candle. Waiting for the close would report the touch after the level had already been passed, which would describe something other than what happened.

When a running-candle label and a closing label land on the same bar, the running one is
removed and its text is folded into the closing label, so the two never sit on top of each other.

WHAT MAKES THIS DIFFERENT

1. It is a sequence, not a checklist.

An Extreme is not reported unless a CSM came first. An MTP is not looked for until an Extreme has been confirmed, and an MLV not until the MTP has been reached. The same candle shape means different things depending on what came before it, and the script keeps track of that.

2. A step can be cancelled, not only completed.

If momentum resumes with a new CSM or an MTM while an MTP is still waiting for its touch, that MTP is dropped. The market changed its mind, so the sequence restarts rather than reporting a target that no longer belongs to anything.

3. One Extreme per CSM.

An Extreme is the answer to a particular CSM, so it is reported once and then that CSM is spent.
Price can keep closing back inside the band for the next ten candles and none of them will be
called an Extreme. A new CSM has to arrive first. An MTM push does not substitute for one.

4. The Extreme test is deliberately narrow.

Closing back inside the band is not enough. The candle also has to stay clear of the opposite LW
MA 5 and 10 and of the Mid BB. A candle that reaches any of them has done more than fail at the edge, and it is not reported as an Extreme.

5. CSD is named by what it did.

A downward break through the Mid BB and both Low averages is a Lower CSD, wherever it happens to appear. Naming it after the cycle it interrupted would put the wrong word on the chart.

6. Touches are read as touches.

The two events that are levels rather than candle patterns are handled as levels, on the running candle, and the script says so plainly rather than pretending everything is close-based.

READING THE CHART

Each event prints a small label at the candle it belongs to. Upper-band events sit above the
candle, lower-band events below it, and where several land on the same candle they are stacked into one label instead of overlapping.

CSM momentum push beyond the outer band
MTM renewed push after a pullback
EX the reversal candle
MTP  first touch of the opposite LW MA 5/10 after an Extreme
MLV  the outer band tested and refused
CSD  Mid BB and both same-side LW MAs broken together
CSM RE / MTM RE / CSD RE    the re-entry touch, named after what preceded it

SETTINGS

Lines
- BB Period and BB Deviations for the Bollinger Bands.
- BB Shift: moves the drawn bands only. The values every rule is measured against are not
moved.
- LW MA 5 to 10 Low and LW MA 5 to 10 High: the twelve weighted average periods. Only 5 and 10 are used by any rule.
- EMA Period.

Pattern Types
- A switch for each of the seven: CSM, MTM, EX, MTP, MLV, CSD and RE.

Line Style
- Show LW MAs: the 5 and 10 period averages, the ones every rule is measured against.
- Show LW MA 6-9 Band: the four decorative periods on each side, on their own switch. Turning
them off is the quickest way to check the claim above - the chart gets simpler and not a single
label moves.
- Show or hide the Bollinger Bands and the EMA.
- Colours for the Bollinger Bands, the LW MA High band, the LW MA Low band and the EMA.

Labels
- Label Size.

ALERTS

Fourteen alert conditions, one for each event on each side:

CSM Upper / CSM Lower
MTM Upper / MTM Lower
EX Upper / EX Lower
MTP Upper / MTP Lower
MLV Upper / MLV Lower
CSD Upper / CSD Lower
Re-Entry Upper / Re-Entry Lower

The structural ones fire once per bar close. MTP and Re-Entry fire once per bar, because they are touches and are read on the running candle.

The same events are also sent through the alert function, so the "Any alert() function call"
alert type can deliver all of them through a single alert. Those messages name the exact
Re-Entry kind - CSM, MTM or CSD - which a fixed alert condition cannot.

REPAINTING

This script does not repaint.

CSM, MTM, EX, MLV and CSD are structure. They are evaluated only after a candle has fully closed and the state memory they drive is updated only on closes, so price moving inside an open candle cannot change the sequence.

MTP and Re-Entry are read on the running candle, and that deserves a straight answer rather than a disclaimer, because a label that can appear mid-candle usually can vanish mid-candle too. Here it cannot, and the reason is in the arithmetic of the level being watched.

A weighted average of the LOW gives the candle still forming a weight of one third at length 5,
and about one fifth at length 10. The running low of that candle falls three to five times faster
than the average it is being compared against. So the moment the low reaches the average, the gap between them can only keep closing. It can never reopen inside that candle. The high side is the exact mirror.

Which means:

- Once an MTP or Re-Entry label is drawn, it stays. It cannot un-touch before the candle closes.
- Reloading the chart gives the same result, because a closed candle is evaluated once using its
final low and high, and those are the most extreme values the candle ever had.
- The only thing that changes at the close is presentation: a running-candle label is folded into
the closing label for that bar so the two do not sit on top of each other. The event itself is
not re-decided.

When you create an alert, TradingView may show a caution banner saying the indicator can repaint.
That banner appears automatically for any script that uses the built in bar state variables, no
matter how they are used, because the platform cannot check the intent behind them. For the
structural alerts, choosing "Once Per Bar Close" is still recommended.

NOTES AND LIMITATIONS

- CSD is the strong form only: the Mid BB and BOTH same-side LW MAs have to be broken by the same candle. A Mid BB break on its own is not reported.
- An Extreme always needs a CSM before it. A reversal candle appearing without that history is
not an Extreme here, whatever it looks like.
- The 6, 7, 8 and 9 period LW MAs and the EMA 50 are drawn but never measured. Changing them, or hiding them, changes the picture and nothing else.
- BB Shift is visual only. Shifting the bands does not shift the rules.
- TradingView caps a script at 500 labels and the oldest are dropped once that cap is reached, so on a long history the earliest labels leave the chart.
- Detection is purely structural. It reports where each step of the sequence occurred and nothing more. It does not rank setups by quality, measure what happened next, or produce entries, targets or stops.

HOW TO USE IT

Read the labels in order rather than one at a time. A CSM on its own says momentum arrived. The same CSM followed by an Extreme says the move ran out of room. That Extreme followed by an MTP and then an MLV says the band was tested again and refused. Each label narrows what the previous one meant.

The two bands are the working area. Price spends most of its time between the LW MA High band and the LW MA Low band, and the Re-Entry marks are where it came back to one of them after a push.

A CSD is the point where the picture changes side. It is the only event in the set that breaks
the Mid BB and both same-side averages in one candle, and everything after it belongs to the new direction.

These are reference points, not entry signals on their own. Use them alongside your own analysis, your own entry method and proper risk management.

DISCLAIMER

This indicator is a pattern detection tool. It is not financial advice and it makes no claim
about profitability. Trading involves risk. Always apply your own analysis and risk management.

---

## Source Code

````pine
//@version=6
indicator("BBMA Trend & Momentum", overlay = true, max_labels_count = 500)

// ==========================================================
// BBMA Trend & Momentum
//
// The BBMA structure drawn as one running sequence rather than a set of
// separate signals. Three families of lines carry the whole system:
//
//   Bollinger Bands   upper, mid and lower, from SMA 20 with deviation 2
//   LW MA High        weighted averages of the HIGH - the upper band
//   LW MA Low         weighted averages of the LOW  - the lower band
//   EMA 50            the slower trend reference
//
// The 5 and 10 period LW MAs are the ones every rule is written against and
// are drawn solid. The 6 to 9 periods are drawn dashed and are there to show
// the shape of the band; nothing is measured from them.
//
// THE SEQUENCE
//
//   CSM    momentum - LW MA 5 pushes past the outer band and the candle
//          closes even further out
//   EX     the reversal candle that closes back inside the band while
//          LW MA 5 is still outside it
//   MTP    the mandatory target - the opposite side LW MA 5/10
//   MLV    price tries the outer band again and cannot close beyond it
//   CSD    direction change - a close through the Mid BB
//   MTM    a pullback that pushes back out through the outer band
//   RE     the re-entry touch that follows CSM, MTM or CSD
//
// WHAT IS READ WHEN
//
// CSM, EX, MLV, CSD and MTM are structure. They are decided on the CLOSE of a
// candle and never change afterwards.
//
// MTP and RE are touches, not structure. They are decided the moment price
// reaches a LW MA 5/10 level, on the running candle, because that is when the
// level is actually reached. A label from a running candle is merged into the
// closing label for that bar.
// ==========================================================

// ============================ INPUTS ============================
gLine  = "Lines"
gType  = "Pattern Types"
gStyle = "Line Style"
gLabel = "Labels"

bbLen   = input.int(20,  "BB Period", minval = 1, group = gLine)
bbDev   = input.float(2, "BB Deviations", step = 0.1, minval = 0.1, group = gLine)
bbShift = input.int(0,   "BB Shift (visual)", minval = -500, maxval = 500, group = gLine,
     tooltip = "Visual offset of the Bollinger Bands only. It does not move the values the rules are measured against.")

// LW MA periods on the LOW. Only 5 and 10 are used by any rule; 6 to 9 are
// drawn to show the shape of the band.
lwMa5LowLen   = input.int(5,  "LW MA 5 Low",  minval = 1, group = gLine)
lwMa6LowLen   = input.int(6,  "LW MA 6 Low",  minval = 1, group = gLine)
lwMa7LowLen   = input.int(7,  "LW MA 7 Low",  minval = 1, group = gLine)
lwMa8LowLen   = input.int(8,  "LW MA 8 Low",  minval = 1, group = gLine)
lwMa9LowLen   = input.int(9,  "LW MA 9 Low",  minval = 1, group = gLine)
lwMa10LowLen  = input.int(10, "LW MA 10 Low", minval = 1, group = gLine)

// LW MA periods on the HIGH.
lwMa5HighLen  = input.int(5,  "LW MA 5 High",  minval = 1, group = gLine)
lwMa6HighLen  = input.int(6,  "LW MA 6 High",  minval = 1, group = gLine)
lwMa7HighLen  = input.int(7,  "LW MA 7 High",  minval = 1, group = gLine)
lwMa8HighLen  = input.int(8,  "LW MA 8 High",  minval = 1, group = gLine)
lwMa9HighLen  = input.int(9,  "LW MA 9 High",  minval = 1, group = gLine)
lwMa10HighLen = input.int(10, "LW MA 10 High", minval = 1, group = gLine)

emaLen = input.int(50, "EMA Period", minval = 1, group = gLine)

showCSM = input.bool(true, "CSM - Candlestick Momentum",  group = gType)
showMTM = input.bool(true, "MTM - Momentum Push",         group = gType)
showEX  = input.bool(true, "EX - Extreme",                group = gType)
showMTP = input.bool(true, "MTP - Mandatory Take Profit", group = gType,
     tooltip = "Decided on the running candle, the moment a LW MA 5/10 level is reached.")
showMLV = input.bool(true, "MLV - Market Volume Lost",    group = gType)
showCSD = input.bool(true, "CSD - Candlestick Direction", group = gType)
showRE  = input.bool(true, "RE - Re-Entry",               group = gType,
     tooltip = "Decided on the running candle, the moment a LW MA 5/10 level is reached.")

showBB   = input.bool(true, "Show Bollinger Bands", group = gStyle)
showMA   = input.bool(true, "Show LW MAs",          group = gStyle,
     tooltip = "The 5 and 10 period averages on each side. These are the ones every rule is measured against.")
showBand = input.bool(true, "Show LW MA 6-9 Band",  group = gStyle,
     tooltip = "The 6, 7, 8 and 9 period averages. They fill in the shape of the band and nothing is calculated from them - switch them off and not a single label changes.")
showEMA  = input.bool(true, "Show EMA",             group = gStyle)

bbColor     = input.color(#00008b, "Bollinger Band Color", group = gStyle)
maHighColor = input.color(#ff0000, "LW MA High Color",     group = gStyle)
maLowColor  = input.color(#008000, "LW MA Low Color",      group = gStyle)
emaColor    = input.color(#ffeb3b, "EMA Color",            group = gStyle)

labelSizeStr = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabel)

// ============================ STYLE CONSTANTS ============================
labelSize = labelSizeStr == "Tiny" ? size.tiny : labelSizeStr == "Small" ? size.small : labelSizeStr == "Large" ? size.large : size.normal

// ============================ BOLLINGER BANDS ============================
bbBasis = ta.sma(close, bbLen)
bbStd   = ta.stdev(close, bbLen)
bbUpper = bbBasis + bbDev * bbStd
bbLower = bbBasis - bbDev * bbStd

plot(showBB ? bbUpper : na, "BB Upper", color = bbColor, linewidth = 3, offset = bbShift)
plot(showBB ? bbBasis : na, "BB Basis", color = bbColor, linewidth = 3, offset = bbShift)
plot(showBB ? bbLower : na, "BB Lower", color = bbColor, linewidth = 3, offset = bbShift)

// ============================ LINEAR WEIGHTED MOVING AVERAGES (LWMA) ============================
// Low Calculations
lwMa5Low   = ta.wma(low, lwMa5LowLen)
lwMa6Low   = ta.wma(low, lwMa6LowLen)
lwMa7Low   = ta.wma(low, lwMa7LowLen)
lwMa8Low   = ta.wma(low, lwMa8LowLen)
lwMa9Low   = ta.wma(low, lwMa9LowLen)
lwMa10Low  = ta.wma(low, lwMa10LowLen)

// High Calculations
lwMa5High  = ta.wma(high, lwMa5HighLen)
lwMa6High  = ta.wma(high, lwMa6HighLen)
lwMa7High  = ta.wma(high, lwMa7HighLen)
lwMa8High  = ta.wma(high, lwMa8HighLen)
lwMa9High  = ta.wma(high, lwMa9HighLen)
lwMa10High = ta.wma(high, lwMa10HighLen)

// LW MAs on the LOW. 5 and 10 are solid and carry the rules; 6 to 9 are
// dashed, are pure shape, and have their own switch.
plot(showMA ? lwMa5Low   : na, "LW MA 5 Low",   color = maLowColor, linewidth = 2) // Solid
plot(showMA and showBand ? lwMa6Low   : na, "LW MA 6 Low",   color = maLowColor, linewidth = 2, linestyle=plot.linestyle_dashed) // Dash
plot(showMA and showBand ? lwMa7Low   : na, "LW MA 7 Low",   color = maLowColor, linewidth = 2, linestyle=plot.linestyle_dashed) // Dash
plot(showMA and showBand ? lwMa8Low   : na, "LW MA 8 Low",   color = maLowColor, linewidth = 2, linestyle=plot.linestyle_dashed) // Dash
plot(showMA and showBand ? lwMa9Low   : na, "LW MA 9 Low",   color = maLowColor, linewidth = 2, linestyle=plot.linestyle_dashed) // Dash
plot(showMA ? lwMa10Low  : na, "LW MA 10 Low",  color = maLowColor, linewidth = 2) // Solid

// LW MAs on the HIGH - the exact mirror.
plot(showMA ? lwMa5High  : na, "LW MA 5 High",  color = maHighColor, linewidth = 2) // Solid
plot(showMA and showBand ? lwMa6High  : na, "LW MA 6 High",  color = maHighColor, linewidth = 2, linestyle=plot.linestyle_dashed) // Dash
plot(showMA and showBand ? lwMa7High  : na, "LW MA 7 High",  color = maHighColor, linewidth = 2, linestyle=plot.linestyle_dashed) // Dash
plot(showMA and showBand ? lwMa8High  : na, "LW MA 8 High",  color = maHighColor, linewidth = 2, linestyle=plot.linestyle_dashed) // Dash
plot(showMA and showBand ? lwMa9High  : na, "LW MA 9 High",  color = maHighColor, linewidth = 2, linestyle=plot.linestyle_dashed) // Dash
plot(showMA ? lwMa10High : na, "LW MA 10 High", color = maHighColor, linewidth = 2) // Solid

// ============================ EMA 50 (EXPONENTIAL, CLOSE) ============================
emaClose = ta.ema(close, emaLen)
plot(showEMA ? emaClose : na, "EMA 50", color = emaColor, linewidth = 2)

// ============================ BAR STATE ============================
isClosed = barstate.isconfirmed

// ============================ BBMA PATTERN DETECTION & STATE MACHINE ============================
// Basic States
var int stateUP = 0 // 0=None, 1=CSM, 2=Extreme, 3=MTP, 4=MLV
var int stateDN = 0 // 0=None, 1=CSM, 2=Extreme, 3=MTP, 4=MLV

// Tick triggers (prevent multiple labels per cycle)
var bool mtpTriggeredUP = false
var bool mtpTriggeredDN = false
var bool csdReTriggeredUP = false
var bool csdReTriggeredDN = false
var bool mtmReTriggeredUP = false
var bool mtmReTriggeredDN = false
var bool csmReTriggeredUP = false
var bool csmReTriggeredDN = false

// Label tracking for deletion on close
var label lblMtpUP = na
var label lblMtpDN = na
var label lblCsdReUP = na
var label lblCsdReDN = na
var label lblMtmReUP = na
var label lblMtmReDN = na
var label lblCsmReUP = na
var label lblCsmReDN = na

var int barMtpUP = -1
var int barMtpDN = -1
var int barCsdReUP = -1
var int barCsdReDN = -1
var int barMtmReUP = -1
var int barMtmReDN = -1
var int barCsmReUP = -1
var int barCsmReDN = -1

// Independent tracking for MTM & CSD Re-entry
var bool hasCsmUP = false
var bool inPullbackUP = false
var bool waitMtmReUP = false
var bool waitCsmReUP = false
var bool waitSellReentry = false

var bool hasCsmDN = false
var bool inPullbackDN = false
var bool waitMtmReDN = false
var bool waitCsmReDN = false
var bool waitBuyReentry = false

// ============================ SIGNALS AND COUNTS ============================
// One flag per event, so every pattern can carry its own alert. Upper and
// Lower name the side the event belongs to - the one that began at the Upper
// or the Lower Bollinger Band.
bool sigCsmUp   = false
bool sigCsmDn   = false
bool sigMtmUp   = false
bool sigMtmDn   = false
bool sigExUp    = false
bool sigExDn    = false
bool sigMtpUp   = false
bool sigMtpDn   = false
bool sigMlvUp   = false
bool sigMlvDn   = false
bool sigCsdUp   = false
bool sigCsdDn   = false
bool sigCsdReUp = false
bool sigCsdReDn = false
bool sigMtmReUp = false
bool sigMtmReDn = false
bool sigCsmReUp = false
bool sigCsmReDn = false


// ============================ RUNNING CANDLE TRIGGERS ============================
// MTP and RE are level touches, so they are read on the running candle - the
// moment a LW MA 5/10 level is reached. A label drawn here is merged into the
// closing label for the same bar by the section below.

// Upper MTP - the Sell side closes out on a LW MA 5/10 Low touch
if stateUP == 2 and not mtpTriggeredUP and (low <= lwMa5Low or low <= lwMa10Low)
    if showMTP
        lblMtpUP := label.new(bar_index, low, "MTP", color=color.orange, style=label.style_label_up, textcolor=color.white, size = labelSize)
    sigMtpUp   := true
    mtpTriggeredUP := true
    barMtpUP := bar_index

// Lower MTP - the Buy side closes out on a LW MA 5/10 High touch
if stateDN == 2 and not mtpTriggeredDN and (high >= lwMa5High or high >= lwMa10High)
    if showMTP
        lblMtpDN := label.new(bar_index, high, "MTP", color=color.orange, style=label.style_label_down, textcolor=color.white, size = labelSize)
    sigMtpDn   := true
    mtpTriggeredDN := true
    barMtpDN := bar_index

// CSD Re-entry, upper side - waits for a LW MA 5/10 High touch
if waitSellReentry and not csdReTriggeredUP and (high >= lwMa5High or high >= lwMa10High)
    if showRE
        lblCsdReUP := label.new(bar_index, high, "CSD RE", color=color.maroon, style=label.style_label_down, textcolor=color.white, size = labelSize)
    sigCsdReDn := true
    csdReTriggeredUP := true
    barCsdReUP := bar_index

// CSD Re-entry, lower side - waits for a LW MA 5/10 Low touch
if waitBuyReentry and not csdReTriggeredDN and (low <= lwMa5Low or low <= lwMa10Low)
    if showRE
        lblCsdReDN := label.new(bar_index, low, "CSD RE", color=color.teal, style=label.style_label_up, textcolor=color.white, size = labelSize)
    sigCsdReUp := true
    csdReTriggeredDN := true
    barCsdReDN := bar_index

// MTM Re-entry, upper cycle - waits for a LW MA 5/10 Low touch
if waitMtmReUP and not mtmReTriggeredUP and (low <= lwMa5Low or low <= lwMa10Low)
    if showRE
        lblMtmReUP := label.new(bar_index, low, "MTM RE", color=color.yellow, style=label.style_label_up, textcolor=color.black, size = labelSize)
    sigMtmReUp := true
    mtmReTriggeredUP := true
    barMtmReUP := bar_index

// MTM Re-entry, lower cycle - waits for a LW MA 5/10 High touch
if waitMtmReDN and not mtmReTriggeredDN and (high >= lwMa5High or high >= lwMa10High)
    if showRE
        lblMtmReDN := label.new(bar_index, high, "MTM RE", color=color.aqua, style=label.style_label_down, textcolor=color.black, size = labelSize)
    sigMtmReDn := true
    mtmReTriggeredDN := true
    barMtmReDN := bar_index

// CSM Re-entry, upper cycle - waits for a LW MA 5/10 Low touch
if waitCsmReUP and not csmReTriggeredUP and (low <= lwMa5Low or low <= lwMa10Low)
    if showRE
        lblCsmReUP := label.new(bar_index, low, "CSM RE", color=color.yellow, style=label.style_label_up, textcolor=color.black, size = labelSize)
    sigCsmReUp := true
    csmReTriggeredUP := true
    barCsmReUP := bar_index

// CSM Re-entry, lower cycle - waits for a LW MA 5/10 High touch
if waitCsmReDN and not csmReTriggeredDN and (high >= lwMa5High or high >= lwMa10High)
    if showRE
        lblCsmReDN := label.new(bar_index, high, "CSM RE", color=color.aqua, style=label.style_label_down, textcolor=color.black, size = labelSize)
    sigCsmReDn := true
    csmReTriggeredDN := true
    barCsmReDN := bar_index

// ============================ CLOSED CANDLE STATE UPDATES ============================
// Everything structural is decided here, on the close, so ticks can never move
// the sequence. Any running-candle label from this bar is folded into one
// closing label to stop them stacking on top of each other.
if isClosed
    string topStr = ""
    color  topClr = na
    string botStr = ""
    color  botClr = na

    // --- OVERLAP FIX: MERGE TICK LABELS ---
    // If a tick label was drawn on THIS bar, delete it and add its text to the string builder

    // Upper MTP (drawn at Low -> botStr)
    if barMtpUP == bar_index
        label.delete(lblMtpUP)
        if showMTP
            botStr := botStr == "" ? "MTP" : botStr + "\nMTP"
            if na(botClr)
                botClr := color.orange

    // Lower MTP (drawn at High -> topStr)
    if barMtpDN == bar_index
        label.delete(lblMtpDN)
        if showMTP
            topStr := topStr == "" ? "MTP" : topStr + "\nMTP"
            if na(topClr)
                topClr := color.orange

    // CSD Sell RE (drawn at High -> topStr)
    if barCsdReUP == bar_index
        label.delete(lblCsdReUP)
        if showRE
            topStr := topStr == "" ? "CSD RE" : topStr + "\nCSD RE"
            if na(topClr)
                topClr := color.maroon

    // CSD Buy RE (drawn at Low -> botStr)
    if barCsdReDN == bar_index
        label.delete(lblCsdReDN)
        if showRE
            botStr := botStr == "" ? "CSD RE" : botStr + "\nCSD RE"
            if na(botClr)
                botClr := color.teal

    // MTM Sell RE (drawn at Low -> botStr)
    if barMtmReUP == bar_index
        label.delete(lblMtmReUP)
        if showRE
            botStr := botStr == "" ? "MTM RE" : botStr + "\nMTM RE"
            if na(botClr)
                botClr := color.yellow

    // MTM Buy RE (drawn at High -> topStr)
    if barMtmReDN == bar_index
        label.delete(lblMtmReDN)
        if showRE
            topStr := topStr == "" ? "MTM RE" : topStr + "\nMTM RE"
            if na(topClr)
                topClr := color.aqua

    // CSM Sell RE (drawn at Low -> botStr)
    if barCsmReUP == bar_index
        label.delete(lblCsmReUP)
        if showRE
            botStr := botStr == "" ? "CSM RE" : botStr + "\nCSM RE"
            if na(botClr)
                botClr := color.yellow

    // CSM Buy RE (drawn at High -> topStr)
    if barCsmReDN == bar_index
        label.delete(lblCsmReDN)
        if showRE
            topStr := topStr == "" ? "CSM RE" : topStr + "\nCSM RE"
            if na(topClr)
                topClr := color.aqua

    bool wasPullbackUP = inPullbackUP
    bool wasPullbackDN = inPullbackDN

    // ============================ UPPER CYCLE ============================

    // 1. Upper CSM
    isUpperCSM = lwMa5High > bbUpper and close > lwMa5High
    if isUpperCSM
        sigCsmUp := true
        stateUP := 1
        hasCsmUP := true
        inPullbackUP := false
        if wasPullbackUP // If it pushed from a pullback, arm RE
            waitCsmReUP := true
            csmReTriggeredUP := false
        if showCSM
            topStr := topStr == "" ? "CSM" : topStr + "\nCSM"
            if na(topClr)
                topClr := color.green

    // 2. Upper Extreme (Sell Extreme)
    // State 1 means a CSM has happened and its Extreme has not been taken yet.
    // Exactly 1, not 1 or more - one Extreme per CSM, and a new CSM is the only
    // thing that can open the door again.
    isUpperExt = stateUP == 1 and close < bbUpper and lwMa5High > bbUpper
    if isUpperExt
        // The Extreme candle may not reach down to the opposite LW MAs, and it
        // may not reach the Mid BB either. Touching any of them disqualifies it.
        isNeutralUP = low <= lwMa5Low or low <= lwMa10Low or low <= bbBasis
        if not isNeutralUP
            sigExUp := true
            stateUP := 2
            mtpTriggeredUP := false // arm MTP tick trigger
            if showEX
                topStr := topStr == "" ? "EX" : topStr + "\nEX"
                if na(topClr)
                    topClr := color.red

    // 3. Upper MTP
    if stateUP == 2 and (low <= lwMa5Low or low <= lwMa10Low)
        stateUP := 3
        // Label is drawn by Tick Trigger

    // 4. Upper MLV
    isUpperMLV = stateUP >= 3 and high >= bbUpper and close <= bbUpper and close >= bbBasis
    if isUpperMLV
        sigMlvUp := true
        stateUP := 4
        if showMLV
            topStr := topStr == "" ? "MLV" : topStr + "\nMLV"
            if na(topClr)
                topClr := color.fuchsia

    // 5. Sell Strong CSD (Downside breakout)
    isSellStrongCSD = open > bbBasis and close < bbBasis and close < lwMa5Low and close < lwMa10Low
    // Breaks the Mid BB and both LW MA Lows downward -> LOWER CSD
    if isSellStrongCSD
        sigCsdDn := true
        stateUP := 0
        hasCsmUP := false
        inPullbackUP := false
        waitMtmReUP := false
        waitCsmReUP := false
        waitSellReentry := true
        csdReTriggeredUP := false
        if showCSD
            topStr := topStr == "" ? "CSD" : topStr + "\nCSD"
            if na(topClr)
                topClr := color.red
    else if csdReTriggeredUP // Disarm CSD RE after it triggers and bar closes
        waitSellReentry := false

    if mtmReTriggeredUP // Disarm MTM RE after it triggers and bar closes
        waitMtmReUP := false

    if csmReTriggeredUP // Disarm CSM RE after it triggers and bar closes
        waitCsmReUP := false

    // MTM Push
    if wasPullbackUP and close > bbUpper and not isUpperCSM
        sigMtmUp := true
        // Momentum has resumed, so an MTP that never got its LW MA 5/10 touch is
        // cancelled. MTM is a push, not a CSM, so the state is cleared rather than
        // set to 1 - the next Extreme still has to wait for a real CSM.
        stateUP := 0
        inPullbackUP := false
        hasCsmUP := true
        waitMtmReUP := true
        mtmReTriggeredUP := false
        if showMTM
            topStr := topStr == "" ? "MTM" : topStr + "\nMTM"
            if na(topClr)
                topClr := color.blue

    // Upper Pullback Detection
    if hasCsmUP and close < bbUpper and close >= bbBasis
        inPullbackUP := true
        hasCsmUP := false

    // Upper Invalidation (if pullback breaks Mid BB)
    if close < bbBasis
        hasCsmUP := false
        inPullbackUP := false

    // ============================ LOWER CYCLE ============================

    // 1. Lower CSM
    isLowerCSM = lwMa5Low < bbLower and close < lwMa5Low
    if isLowerCSM
        sigCsmDn := true
        stateDN := 1
        hasCsmDN := true
        inPullbackDN := false
        if wasPullbackDN
            waitCsmReDN := true
            csmReTriggeredDN := false
        if showCSM
            botStr := botStr == "" ? "CSM" : botStr + "\nCSM"
            if na(botClr)
                botClr := color.red

    // 2. Lower Extreme (Buy Extreme)
    // Mirror of the upper side - exactly one Extreme per CSM.
    isLowerExt = stateDN == 1 and close > bbLower and lwMa5Low < bbLower
    if isLowerExt
        // Mirror of the upper side - the opposite LW MAs and the Mid BB are all
        // out of bounds for the Extreme candle.
        isNeutralDN = high >= lwMa5High or high >= lwMa10High or high >= bbBasis
        if not isNeutralDN
            sigExDn := true
            stateDN := 2
            mtpTriggeredDN := false // arm MTP tick trigger
            if showEX
                botStr := botStr == "" ? "EX" : botStr + "\nEX"
                if na(botClr)
                    botClr := color.green

    // 3. Lower MTP
    if stateDN == 2 and (high >= lwMa5High or high >= lwMa10High)
        stateDN := 3
        // Label is drawn by Tick Trigger

    // 4. Lower MLV
    isLowerMLV = stateDN >= 3 and low <= bbLower and close >= bbLower and close <= bbBasis
    if isLowerMLV
        sigMlvDn := true
        stateDN := 4
        if showMLV
            botStr := botStr == "" ? "MLV" : botStr + "\nMLV"
            if na(botClr)
                botClr := color.fuchsia

    // 5. Buy Strong CSD (Upside breakout)
    isBuyStrongCSD = open < bbBasis and close > bbBasis and close > lwMa5High and close > lwMa10High
    // Breaks the Mid BB and both LW MA Highs upward -> UPPER CSD
    if isBuyStrongCSD
        sigCsdUp := true
        stateDN := 0
        hasCsmDN := false
        inPullbackDN := false
        waitMtmReDN := false
        waitCsmReDN := false
        waitBuyReentry := true
        csdReTriggeredDN := false
        if showCSD
            botStr := botStr == "" ? "CSD" : botStr + "\nCSD"
            if na(botClr)
                botClr := color.green
    else if csdReTriggeredDN
        waitBuyReentry := false

    if mtmReTriggeredDN
        waitMtmReDN := false

    if csmReTriggeredDN
        waitCsmReDN := false

    // MTM Push
    if wasPullbackDN and close < bbLower and not isLowerCSM
        sigMtmDn := true
        // Mirror of the upper side - the push cancels a waiting MTP and clears the
        // state, so the next Extreme still needs a real CSM first.
        stateDN := 0
        inPullbackDN := false
        hasCsmDN := true
        waitMtmReDN := true
        mtmReTriggeredDN := false
        if showMTM
            botStr := botStr == "" ? "MTM" : botStr + "\nMTM"
            if na(botClr)
                botClr := color.blue

    // Lower Pullback Detection
    if hasCsmDN and close > bbLower and close <= bbBasis
        inPullbackDN := true
        hasCsmDN := false

    // Lower Invalidation (if pullback breaks Mid BB)
    if close > bbBasis
        hasCsmDN := false
        inPullbackDN := false

    // ============================ DRAW CLOSED-CANDLE LABELS ============================
    if topStr != ""
        label.new(bar_index, high, topStr, color=topClr, style=label.style_label_down, textcolor=color.white, size = labelSize)
    if botStr != ""
        label.new(bar_index, low, botStr, color=botClr, style=label.style_label_up, textcolor=color.white, size = labelSize)

// ============================ ALERTS ============================
// CSM, MTM, EX, MLV and CSD are structure and are read on the candle close.
// MTP and RE are level touches and are read on the running candle, which is
// why they use the once-per-bar frequency rather than once-per-bar-close.
sigReUp = sigCsdReUp or sigMtmReUp or sigCsmReUp
sigReDn = sigCsdReDn or sigMtmReDn or sigCsmReDn

alertcondition(sigCsmUp, title = "CSM Upper", message = "BBMA CSM Upper | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigCsmDn, title = "CSM Lower", message = "BBMA CSM Lower | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigMtmUp, title = "MTM Upper", message = "BBMA MTM Upper | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigMtmDn, title = "MTM Lower", message = "BBMA MTM Lower | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigExUp,  title = "EX Upper",  message = "BBMA EX Upper | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigExDn,  title = "EX Lower",  message = "BBMA EX Lower | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigMlvUp, title = "MLV Upper", message = "BBMA MLV Upper | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigMlvDn, title = "MLV Lower", message = "BBMA MLV Lower | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigCsdUp, title = "CSD Upper", message = "BBMA CSD Upper | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigCsdDn, title = "CSD Lower", message = "BBMA CSD Lower | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigMtpUp, title = "MTP Upper", message = "BBMA MTP Upper | {{ticker}} {{interval}} | Price {{close}}")
alertcondition(sigMtpDn, title = "MTP Lower", message = "BBMA MTP Lower | {{ticker}} {{interval}} | Price {{close}}")
alertcondition(sigReUp,  title = "Re-Entry Upper", message = "BBMA Re-Entry Upper | {{ticker}} {{interval}} | Price {{close}}")
alertcondition(sigReDn,  title = "Re-Entry Lower", message = "BBMA Re-Entry Lower | {{ticker}} {{interval}} | Price {{close}}")

// Dynamic message for the "Any alert() function call" alert type. This one can
// name the exact Re-Entry type, which a static alertcondition cannot.
alertMsg(string tag) =>
    tag + " | " + syminfo.ticker + " " + timeframe.period + " | " + str.tostring(close, format.mintick)

if isClosed
    if sigCsmUp
        alert(alertMsg("BBMA CSM Upper"), alert.freq_once_per_bar_close)
    if sigCsmDn
        alert(alertMsg("BBMA CSM Lower"), alert.freq_once_per_bar_close)
    if sigMtmUp
        alert(alertMsg("BBMA MTM Upper"), alert.freq_once_per_bar_close)
    if sigMtmDn
        alert(alertMsg("BBMA MTM Lower"), alert.freq_once_per_bar_close)
    if sigExUp
        alert(alertMsg("BBMA EX Upper"), alert.freq_once_per_bar_close)
    if sigExDn
        alert(alertMsg("BBMA EX Lower"), alert.freq_once_per_bar_close)
    if sigMlvUp
        alert(alertMsg("BBMA MLV Upper"), alert.freq_once_per_bar_close)
    if sigMlvDn
        alert(alertMsg("BBMA MLV Lower"), alert.freq_once_per_bar_close)
    if sigCsdUp
        alert(alertMsg("BBMA CSD Upper"), alert.freq_once_per_bar_close)
    if sigCsdDn
        alert(alertMsg("BBMA CSD Lower"), alert.freq_once_per_bar_close)

// Touch events, reported as soon as the level is reached.
if sigMtpUp
    alert(alertMsg("BBMA MTP Upper"), alert.freq_once_per_bar)
if sigMtpDn
    alert(alertMsg("BBMA MTP Lower"), alert.freq_once_per_bar)
if sigCsdReUp
    alert(alertMsg("BBMA CSD Re-Entry Upper"), alert.freq_once_per_bar)
if sigCsdReDn
    alert(alertMsg("BBMA CSD Re-Entry Lower"), alert.freq_once_per_bar)
if sigMtmReUp
    alert(alertMsg("BBMA MTM Re-Entry Upper"), alert.freq_once_per_bar)
if sigMtmReDn
    alert(alertMsg("BBMA MTM Re-Entry Lower"), alert.freq_once_per_bar)
if sigCsmReUp
    alert(alertMsg("BBMA CSM Re-Entry Upper"), alert.freq_once_per_bar)
if sigCsmReDn
    alert(alertMsg("BBMA CSM Re-Entry Lower"), alert.freq_once_per_bar)
````
