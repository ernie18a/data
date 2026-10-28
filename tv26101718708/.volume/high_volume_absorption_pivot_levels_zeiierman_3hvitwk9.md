# High Volume Absorption Pivot Levels (Zeiierman)

- url: https://www.tradingview.com/script/3HViTWK9-High-Volume-Absorption-Pivot-Levels-Zeiierman/
- type: indicator
- pine_id: PUB;3bddfdcb88544e16a050adaf802160ba
- version: 1.0

## Description

█ [b]Overview[/b]
[b]High Volume Absorption Pivot Levels (Zeiierman)[/b] is a volume-based market structure indicator designed to identify significant pivot highs and lows where price shows signs of absorption during their formation.

Rather than plotting every swing point, the indicator filters pivots using two important characteristics:

• Elevated trading volume.
• Absorption candles that indicate a temporary balance between buyers and sellers.

Only pivots that satisfy these conditions become active support or resistance levels, allowing traders to focus on price levels that formed during periods of increased market participation.
[image]https://www.tradingview.com/x/DQLgrD2f/[/image]
⚪ [b]Absorption and High Participation[/b]
The indicator combines traditional pivot detection with volume analysis.

[b]A valid pivot requires:[/b]

• A confirmed swing high or swing low.
• Above-average volume on the pivot.
• An absorption candle occurring either around the pivot or directly on the pivot candle.

This helps remove many insignificant swing points while emphasizing areas where market participants were actively exchanging positions.
[image]https://www.tradingview.com/x/8qVRI5e7/[/image]
Once confirmed, these levels often serve as important reference points for future reactions, mitigation events, and retests.

█ [b]How It Works[/b]

⚪ [b]Pivot Structure Detection[/b]
The script continuously detects confirmed swing highs and swing lows using user-defined pivot lengths. These pivots become candidates for future support and resistance levels.

⚪ [b]High Volume Filter[/b]
Not every pivot is plotted.

The pivot candle must also trade with above-average volume.
[pine]volume > sma(volume) × multiplier[/pine]
This helps prioritize pivots that formed during periods of significantly higher participation than normal.

⚪ [b]Absorption Candle Detection[/b]
The indicator searches for absorption candles around each pivot.

[b]An absorption candle is defined as:[/b]

• Small candle body relative to the total range.
• Above-average trading volume.

█ [b]How to Use[/b]

⚪ [b]Identify Institutional Pivot Levels[/b]
Instead of displaying every swing point, the indicator focuses on pivots that formed during elevated participation.

This often highlights areas where larger market participants were active.
[image]https://www.tradingview.com/x/0xCrFxzu/[/image]

⚪ [b]Target These Levels for Liquidity Sweeps[/b]
High-volume absorption pivots often become attractive liquidity targets.

As the market trends, the price frequently returns to sweep these levels before continuing in the direction of the prevailing trend or, in some cases, initiating a reversal.
[image]https://www.tradingview.com/x/iuiUn7A8/[/image]
[b]These sweeps can represent:[/b]

• Liquidity collection before trend continuation.
• Stop-loss hunts around previous pivots.
• Profit-taking before the next market expansion.
• Potential reversal points if the sweep fails and strong opposing participation emerges.

Rather than treating these levels as fixed support or resistance, they should be viewed as important liquidity zones where market participants may become active.
[image]https://www.tradingview.com/x/pE9eN7nW/[/image]

█ [b]Settings[/b]
[list]
[*][b]Pivot Left / Right Length:[/b] Controls how swing highs and lows are confirmed.
[*][b]Maximum Active Levels:[/b] Sets the maximum number of pivot levels displayed simultaneously.
[*][b]Absorption Search Range:[/b] Defines how many candles around each pivot are searched for absorption.
[*][b]Absorption Body %:[/b] Controls how small the candle body must be relative to the full candle range.
[*][b]Absorption Volume Multiplier:[/b] Defines the minimum volume required for an absorption candle.
[*][b]Require Absorption On Pivot Candle:[/b] Restricts valid pivots to those where the absorption candle occurs exactly on the pivot.
[*][b]Pivot Volume Multiplier:[/b] Sets the minimum volume required for the pivot itself.
[/list]
-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
//@version=6
indicator("High Volume Absorption Pivot Levels (Zeiierman)", overlay = true, max_lines_count = 500, max_labels_count = 500)
//}

// ~~ Tooltips {
var string t1  = "Number of bars to the left required to confirm a pivot."
var string t2  = "Number of bars to the right required to confirm a pivot."
var string t3  = "Maximum number of active pivot levels kept on the chart."
var string t4  = "Number of bars around the pivot candle used to search for absorption candles."
var string t5  = "Maximum candle body size as a percentage of the full candle range."
var string t6  = "Absorption candle volume must be above the volume average multiplied by this value."
var string t7  = "When enabled, the absorption candle must be the exact same candle as the pivot."
var string t8  = "Volume moving average length."
var string t9  = "Pivot candle volume must be above the volume average multiplied by this value."
var string t10 = "Fade the level once price mitigates it."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
int lLen      = input.int(10, "Pivot Left Length", minval = 1, group = "Pivot Detection", tooltip = t1)
int rLen      = input.int(2, "Pivot Right Length", minval = 1, group = "Pivot Detection", tooltip = t2)
int maxLvls   = input.int(80, "Max Active Levels", minval = 1, maxval = 200, group = "Pivot Detection", tooltip = t3)

int aBars     = input.int(2, "Absorption Search Bars Around Pivot", minval = 1, group = "Absorption Candle Filter", tooltip = t4)
float aPct    = input.float(25.0, "Absorption Body %", minval = 1, maxval = 100, step = 1, group = "Absorption Candle Filter", tooltip = t5)
float aVol    = input.float(1.2, "Absorption Volume Multiplier", minval = 0.1, step = 0.1, group = "Absorption Candle Filter", tooltip = t6)
bool exactAbs = input.bool(false, "Require Absorption On Pivot Candle", group = "Absorption Candle Filter", tooltip = t7)

int vLen      = input.int(50, "Volume MA Length", minval = 1, group = "Volume Filter", tooltip = t8)
float vMult   = input.float(1.5, "Pivot Volume Multiplier", minval = 0.1, step = 0.1, group = "Volume Filter", tooltip = t9)

color hiCol   = input.color(#e94a58, "Pivot High Level", group = "Visuals", inline = "l")
color loCol   = input.color(#1dd1b3, "Pivot Low Level", group = "Visuals", inline = "l")
int lWidth    = input.int(1, "Width", minval = 1, maxval = 4, group = "Visuals", inline = "l")

bool showLbl  = input.bool(true, "Show Labels", group = "Visuals", inline = "s")
bool showVol  = input.bool(true, "Show Volume In Label", group = "Visuals", inline = "s")
string lblSize = input.string("Small", "", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Visuals", inline = "s")

bool showBub  = input.bool(true, "Show Pivot Bubbles", group = "Visuals", inline = "t")
int bubTrans  = input.int(10, "- Transparency", minval = 0, maxval = 100, group = "Visuals", inline = "t")
string bubSize = input.string("Normal", "", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Visuals", inline = "t")

bool showAbs  = input.bool(true, "Show Absorption Candles Around Valid Pivots", group = "Visuals", inline = "a")
color absCol  = input.color(#ffb74d, "", group = "Visuals", inline = "a")
string absSize = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Visuals", inline = "a")

bool fade     = input.bool(true, "Fade Level After Sweep", group = "Visuals", tooltip = t10)

bool alertPivots = input.bool(true, "Alert On New Pivots", group = "Alerts")
bool alertAbs    = input.bool(true, "Alert On Absorption Candles", group = "Alerts")
bool alertSweep  = input.bool(true, "Alert On Level Mitigation", group = "Alerts")
bool alertRetest = input.bool(true, "Alert On Level Retest", group = "Alerts")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Types {
type Lvl
    line ln
    label lb
    label bub
    float y
    int x
    bool hi
    bool swept
    bool retested
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Storage {
var lvls = array.new<Lvl>()

bool newHiPivotAlert = false
bool newLoPivotAlert = false
bool newHiAbsAlert   = false
bool newLoAbsAlert   = false
bool sweepHiAlert    = false
bool sweepLoAlert    = false
bool retestHiAlert   = false
bool retestLoAlert   = false
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Helpers {
fmtVol(float v) =>
    string res = ""
    if v >= 1000000
        res := str.format("{0,number,#.#}M", v / 1000000)
    else if v >= 1000
        res := str.format("{0,number,#.#}K", v / 1000)
    else
        res := str.tostring(v, "#")
    res

getSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

lvlColor(bool hi) =>
    hi ? hiCol : loCol

lvlText(bool hi) =>
    hi ? "High Volume Pivot High" : "High Volume Pivot Low"
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Drawing Functions {
newLine(float y, int x, color col) =>
    line.new(
         x1 = x,
         y1 = y,
         x2 = bar_index,
         y2 = y,
         color = col,
         width = lWidth,
         style = line.style_solid
     )

newInfoLabel(float y, bool hi, float vol, color col) =>
    string txt = lvlText(hi)
    string vTxt = showVol ? " · " + fmtVol(vol) : ""

    label.new(
         x = bar_index,
         y = y,
         text = txt + vTxt,
         style = label.style_label_left,
         color = #00000000,
         textcolor = col,
         size = getSize(lblSize)
     )

newBubble(float y, int x, color col) =>
    label.new(
         x = x,
         y = y,
         text = "",
         style = label.style_circle,
         color = color.new(col, bubTrans),
         textcolor = color.new(col, 100),
         size = getSize(bubSize)
     )

newAbsMark(int x, float y) =>
    label.new(
         x = x,
         y = y,
         text = "",
         style = label.style_circle,
         color = color.new(absCol, 0),
         textcolor = color.white,
         size = getSize(absSize)
     )

deleteLabel(label lb) =>
    if not na(lb)
        label.delete(lb)

fadeLabel(label lb) =>
    if not na(lb)
        label.set_color(lb, color.new(chart.fg_color, 85))

fadeLine(line ln) =>
    line.set_color(ln, color.new(chart.fg_color, 80))
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Level Functions {
newLvl(float y, int x, bool hi, float vol) =>
    color col = lvlColor(hi)

    line ln = newLine(y, x, col)
    label lb = showLbl ? newInfoLabel(y, hi, vol, col) : na
    label bub = showBub ? newBubble(y, x, col) : na

    lvls.push(Lvl.new(ln, lb, bub, y, bar_index, hi, false, false))

method upd(Lvl l) =>
    bool swpAlert = false
    bool retAlert = false

    if not l.swept
        line.set_x2(l.ln, bar_index)

        if not na(l.lb)
            label.set_x(l.lb, bar_index)

        bool swp = l.hi ? high > l.y : low < l.y

        if swp and bar_index > l.x
            l.swept := true
            swpAlert := true

            if fade
                fadeLine(l.ln)
                deleteLabel(l.lb)
                l.lb := na
                fadeLabel(l.bub)

    if l.swept and not l.retested
        bool ret = l.hi ? low <= l.y and close < l.y : high >= l.y and close > l.y

        if ret and bar_index > l.x
            l.retested := true
            retAlert := true

    [swpAlert, retAlert]

deleteLvl(Lvl l) =>
    line.delete(l.ln)
    deleteLabel(l.lb)
    deleteLabel(l.bub)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Core Calculations {
float ph = ta.pivothigh(lLen, rLen)
float pl = ta.pivotlow(lLen, rLen)
float vAvg = ta.sma(volume, vLen)

bool vOk = volume[rLen] > vAvg[rLen] * vMult

bool absExact  = false
bool absWindow = false

float rngExact  = high[rLen] - low[rLen]
float bodyExact = math.abs(close[rLen] - open[rLen])

bool smallExact = rngExact > 0 and bodyExact / rngExact * 100 <= aPct
bool volExact   = volume[rLen] > vAvg[rLen] * aVol

absExact := smallExact and volExact

for i = -aBars to aBars
    int o = rLen + i

    if o >= 0
        float rng  = high[o] - low[o]
        float body = math.abs(close[o] - open[o])

        bool smallBody  = rng > 0 and body / rng * 100 <= aPct
        bool highVol    = volume[o] > vAvg[o] * aVol
        bool absorption = smallBody and highVol

        if absorption
            absWindow := true

bool aOk = exactAbs ? absExact : absWindow
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Pivot High Logic {
if not na(ph)
    int x = bar_index - rLen

    if aOk and vOk
        newLvl(ph, x, true, volume[rLen])
        newHiPivotAlert := alertPivots

        if showAbs
            if exactAbs
                newAbsMark(bar_index - rLen, high[rLen])
                newHiAbsAlert := alertAbs
            else
                for i = -aBars to aBars
                    int o = rLen + i

                    if o >= 0
                        float rng  = high[o] - low[o]
                        float body = math.abs(close[o] - open[o])

                        bool smallBody  = rng > 0 and body / rng * 100 <= aPct
                        bool highVol    = volume[o] > vAvg[o] * aVol
                        bool absorption = smallBody and highVol

                        if absorption
                            newAbsMark(bar_index - o, high[o])
                            newHiAbsAlert := alertAbs
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Pivot Low Logic {
if not na(pl)
    int x = bar_index - rLen

    if aOk and vOk
        newLvl(pl, x, false, volume[rLen])
        newLoPivotAlert := alertPivots

        if showAbs
            if exactAbs
                newAbsMark(bar_index - rLen, low[rLen])
                newLoAbsAlert := alertAbs
            else
                for i = -aBars to aBars
                    int o = rLen + i

                    if o >= 0
                        float rng  = high[o] - low[o]
                        float body = math.abs(close[o] - open[o])

                        bool smallBody  = rng > 0 and body / rng * 100 <= aPct
                        bool highVol    = volume[o] > vAvg[o] * aVol
                        bool absorption = smallBody and highVol

                        if absorption
                            newAbsMark(bar_index - o, low[o])
                            newLoAbsAlert := alertAbs
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Manage Levels {
if lvls.size() > 0
    for i = lvls.size() - 1 to 0
        Lvl l = lvls.get(i)
        [swp, ret] = l.upd()

        if swp
            if l.hi
                sweepHiAlert := alertSweep
            else
                sweepLoAlert := alertSweep

        if ret
            if l.hi
                retestHiAlert := alertRetest
            else
                retestLoAlert := alertRetest

        lvls.set(i, l)

    while lvls.size() > maxLvls
        Lvl old = lvls.shift()
        deleteLvl(old)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alerts {
alertcondition(newHiPivotAlert, "New Pivot High", "New high-volume absorption pivot high detected.")
alertcondition(newLoPivotAlert, "New Pivot Low", "New high-volume absorption pivot low detected.")

alertcondition(newHiAbsAlert, "Absorption Near Pivot High", "Absorption candle detected around a valid pivot high.")
alertcondition(newLoAbsAlert, "Absorption Near Pivot Low", "Absorption candle detected around a valid pivot low.")

alertcondition(sweepHiAlert, "Pivot High Mitigated", "A pivot high level has been mitigated.")
alertcondition(sweepLoAlert, "Pivot Low Mitigated", "A pivot low level has been mitigated.")

alertcondition(retestHiAlert, "Pivot High Retest", "A mitigated pivot high level has been retested.")
alertcondition(retestLoAlert, "Pivot Low Retest", "A mitigated pivot low level has been retested.")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
