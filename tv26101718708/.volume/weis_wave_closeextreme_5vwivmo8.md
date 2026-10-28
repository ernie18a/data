# Weis Wave, Close-Extreme

- url: https://www.tradingview.com/script/5VWIvMO8-Weis-Wave-Close-Extreme/
- type: indicator
- pine_id: PUB;3a722bc6375f4b338beef02e8d1cb5a8
- version: 4.0

## Description

Weis Wave Volume, Close-Extreme


█ [b]OVERVIEW[/b]

This indicator plots cumulative wave volume in a separate pane, using the wave construction rules that David Weis gives in chapters 9 and 10 of his book "Trades About to Happen". The script divides price into alternating up-waves and down-waves from bar closes, and it assigns the volume of each bar to the wave that the bar belongs to. The thesis is that volume totaled over a price wave shows the effort behind a move more clearly than volume totaled over equal periods of time.

The script can also draw the wave line and turning-point labels on the price chart, flag shortening of thrust, compare each wave with earlier waves in the same direction, and send alerts. These options are off by default, except the wave reversal alert.


█ [b]HISTORY / BACKGROUND[/b]

Richard Wyckoff recorded intraday trading on a tape reading chart. This chart was a point and figure grid with the volume of each price change written in the squares. Wyckoff also kept a wave chart of leading stocks. The wave chart divided each session into buying waves and selling waves, and Wyckoff compared the length, duration and volume of these waves to find changes in trend.

David Weis applied the wave chart to single instruments. His book "Trades About to Happen" (2013) describes the development. Weis changed the tape reading chart into a continuous line. He then filtered the line with a minimum reversal, in the same way that a point and figure chart with a reversal larger than its box size removes small reactions. Because it is not practical to record each trade in a modern market, Weis builds the waves from the closing prices of time bars or tick bars. He totals the volume on each wave and plots the totals as a histogram below the price movement.

The conceptual basis is that price moves in waves of unequal duration. Volume divided into equal time periods hides the force of the buying and the selling. Volume totaled per wave lets the reader compare effort (volume) with reward (price progress) and with duration from one wave to the next.


█ [b]HOW IT WORKS[/b]

[b]Reversal size[/b]
On each bar the script calculates a candidate reversal size from the selected [i]Mode[/i]:
 • [i]Auto (Weis table)[/i] reads `syminfo.root` and `syminfo.type` and selects a fixed price amount that Weis published for intraday study: ES and MES 0.75, NQ and MNQ 2.0, YM and MYM 5.0, RTY and M2K 0.40, ZB 3/32, ZN and ZF 0.015625, GC and MGC 5.0, SI and SIL 0.05, HG 0.0025, ZS, ZC and ZW 1.0, SB and CT 0.10, CC 2.0, KC 0.25, the currency futures 6E, 6B, 6A, 6C, 6S, 6N and M6E 0.0003, forex symbols 3 pips, and stocks, funds and depositary receipts 0.10. The script multiplies the preset by [i]Preset multiplier[/i]. If no preset applies to the symbol, the mode uses the ATR calculation.
 • [i]Ticks[/i] multiplies the input by `syminfo.mintick`.
 • [i]Price[/i] uses the input as a price amount.
 • [i]Percent[/i] uses a percentage of the current close.
 • [i]ATR (frozen)[/i] multiplies an ATR value by one of two multipliers. On intraday charts the ATR is the daily ATR of the previous completed day, which the script gets through `request.security()` with a one-bar offset and lookahead. This value is constant during the session. On daily and higher charts the ATR is the ATR of the previous bar on the chart timeframe.
The script rounds the candidate to a whole number of ticks, with a minimum of one tick. The script stores the reversal size when a wave starts and does not change it until the next wave starts.

[b]Wave state machine[/b]
All changes of state occur only when `barstate.isconfirmed` is true.
1. The first bar that has a valid reversal size becomes the anchor. The anchor close is the reference price. The direction is undetermined.
2. While the direction is undetermined, the first close that is the reversal amount or more above the anchor starts an up-wave. The first close that is the reversal amount or more below the anchor starts a down-wave.
3. In an up-wave, a close that is equal to or higher than the extreme close of the wave continues the wave. That close becomes the new extreme. In a down-wave, a close that is equal to or lower than the extreme close continues the wave.
4. A close that is the reversal amount or more from the extreme close, against the wave, ends the wave. The ended wave stops at its extreme bar. The new wave starts at that extreme and runs to the current bar. The comparison uses "greater than or equal" with a tolerance of 1% of a tick for floating-point error.
5. A bar that does not continue the wave and does not reverse it is an untotaled bar. The script adds its volume to a pending total.

[b]Volume attribution[/b]
When a bar continues the wave, the script adds the pending total and the volume of that bar to the wave, and sets the pending total to zero. When a bar reverses the wave, the pending total and the volume of that bar become the first volume of the new wave. Thus the volume of the bars after the extreme bar belongs to the new wave, as in the worksheet procedure in the book.

[b]Volume source[/b]
The script uses the `volume` of the chart. If the symbol supplies no volume and [i]Use true range instead of volume[/i] is "Auto", the script uses true range as the measure of activity. "Always" uses true range on all symbols.

[b]Wave analytics[/b]
The script keeps each wave in an array of a user-defined type with direction, start and end bar, start and end price, start and end time, volume, highest high and lowest low.
 • [i]Rank[/i]. The script compares the volume of a wave with the prior N waves of the same direction. If the volume is larger than all N, the wave is ranked high. When the wave is complete and its volume is smaller than all N, the wave is ranked low. No rank is given until N prior waves exist.
 • [i]Shortening of thrust[/i]. When a wave is complete, the script examines it and the two prior waves of the same direction. For up-waves, the flag is set when the three highest highs rise and the last increase is smaller than the increase before it. For down-waves, the same test applies to the lowest lows. The high and low of a wave include the bars after its extreme close, up to the bar that reverses it.


█ [b]HOW TO USE[/b]

Read the height of the last column of a wave, or the height of its box, as the total effort on that wave. Compare that total with the price progress and the duration of the wave, and with the earlier waves in the same direction. Weis reads conditions such as these: large volume with small progress, small volume on a pullback, and decreasing length and volume on successive waves in a trend.

[b]Visual elements[/b]
 • [i]Running columns[/i] (default). On each bar that continues or starts a wave, a column shows the cumulative volume of that wave in the up or down color. On an untotaled bar, a gray column shows the pending total. The last colored column of a sequence is the total for the wave. A column is drawn solid when the wave is ranked high.
 • [i]Wave boxes[/i]. One box per wave extends from the extreme bar of the prior wave to the extreme bar of this wave. The height of the box is the volume of the wave. A solid box is a wave ranked high, and a faint box is a wave ranked low. A gray box shows the pending total until the subsequent closes resolve it.
 • [i]Wave line[/i]. A line on the price chart connects the extreme closes of successive waves.
 • [i]Labels[/i]. A label at each turning point gives the wave volume. Optionally it gives the length in ticks, the duration in bars, and the text "SOT" for shortening of thrust. The tooltip of the label gives volume, length, duration in bars and minutes, volume per tick, and rank.
 • [i]Zero line and scale plot[/i]. A horizontal line marks zero. In Wave boxes mode an invisible plot sets the vertical scale of the pane, because drawing objects do not set the scale.
 • [i]Status table[/i]. The table shows the active reversal size in price and in ticks, the source of the reversal size, the number of waves started in the current day on intraday charts, a note when true range is in use, and the start date and count of the waves held in memory.

[b]Timeframe[/b]
The logic operates on the closes of any chart timeframe. The preset table contains the amounts that Weis published for intraday study, and his examples use closes of one to five minutes, so the [i]Auto[/i] mode is designed for intraday charts of one to five minutes. On a daily or higher chart, select [i]ATR (frozen)[/i], [i]Percent[/i] or [i]Price[/i], because a preset for intraday study causes a reversal on almost every daily bar for most symbols. For each symbol and timeframe, adjust the reversal size until the number of waves is neither too large nor too small to read. On intraday charts the status table gives the count for the current day.


█ [b]SETTINGS[/b]

[b]Reversal size[/b]
 • [i]Mode[/i]: the method that sets the reversal size. Default: Auto (Weis table).
 • [i]Preset multiplier[/i]: a multiplier for the Auto preset. The presets date from approximately 2011, when most of these markets traded at lower prices. Default: 1.0.
 • [i]Ticks[/i]: the reversal in ticks for the Ticks mode. Default: 3.
 • [i]Price[/i]: the reversal as a price amount for the Price mode. Default: 0.75.
 • [i]Percent of price[/i]: the reversal as a percentage of the close for the Percent mode. Default: 0.05.
 • [i]ATR length[/i]: the period of the ATR. Default: 14.
 • [i]ATR multiplier, intraday[/i]: the multiplier for the prior daily ATR on intraday charts. Default: 0.05.
 • [i]ATR multiplier, daily and higher[/i]: the multiplier for the ATR of the previous bar on daily and higher charts. Default: 1.0.

[b]Volume[/b]
 • [i]Use true range instead of volume[/i]: Auto, Always or Never. Default: Auto.
 • [i]Auto format volume (K, M)[/i]: formats volume text with K, M and B suffixes. Default: on.
 • [i]Volume divisor when auto format is off[/i]: divides volume in text output. Default: 1000.

[b]Display[/b]
 • [i]Histogram[/i]: Running columns or Wave boxes. Default: Running columns.
 • [i]Volume text inside boxes[/i]: writes the wave volume in each box. Default: off.
 • [i]Wave line on price chart[/i]: draws the wave line on the main chart. Default: off.
 • [i]Wave line width[/i]: Default: 1.
 • [i]Labels at turning points[/i]: draws the volume labels on the main chart. Default: off.
 • [i]Label: wave length in ticks[/i]: Default: off.
 • [i]Label: wave duration in bars[/i]: Default: off.
 • [i]Label size[/i]: Tiny, Small or Normal. Default: Small.
 • [i]Up wave[/i], [i]Down wave[/i], [i]Untotaled volume[/i]: the colors for up-waves, down-waves and pending volume. Defaults: teal, red and gray.
 • [i]Status table[/i]: shows the table in the top right corner of the pane. Default: on.
 • [i]Waves kept[/i]: the number of waves held in memory and drawn. Range: 20 to 500. Default: 400.
 • [i]Pane scale cap, multiple of median wave volume[/i]: for Wave boxes only. Limits the vertical scale of the pane to this multiple of the median volume of the last 30 completed waves. A box above the limit extends beyond the top of the pane. The value 0 disables the limit. Default: 3.0.

[b]Analytics and alerts[/b]
 • [i]Compare against prior N same-direction waves[/i]: the N for the rank. Default: 3.
 • [i]Flag shortening of thrust[/i]: adds "SOT" to the label of a flagged wave. Default: on.
 • [i]Alert: wave reversal[/i]: calls `alert()` when a wave reverses. The message gives the volume, length and duration of the completed wave. Default: on.
 • [i]Alert: largest volume in N waves[/i]: Default: off.
 • [i]Alert: shortening of thrust[/i]: Default: off.
The script also supplies four `alertcondition()` items: wave turned up, wave turned down, largest volume in N waves, and shortening of thrust. The `alert()` calls use the once-per-bar-close frequency, and all alert events are set only on confirmed bars.


█ [b]WHAT MAKES IT ORIGINAL[/b]

Public wave volume scripts commonly find the wave direction by one of two methods: a comparison of successive closes through a trend length, or the level of a Renko brick. These scripts add volume to the current wave until the bar that confirms the change of direction. This script uses a different method in four respects.
1. [b]Reference price[/b]. The reversal is measured from the extreme close of the current wave. A brick-level reference moves only in steps of the brick size, so the effective reversal varies between one and two times the setting. The extreme-close reference keeps the effective reversal equal to the setting.
2. [b]Continuation and reversal tests[/b]. A close equal to the extreme continues the wave, and a move equal to the reversal amount reverses the wave. Both tests agree with the procedure that Weis describes ("a reversal of 3/32nds or more").
3. [b]Volume attribution[/b]. The volume of the bars between the extreme bar and the confirming bar goes to the new wave. The wave boundary is the extreme bar. In the Wave boxes display, the script draws each wave as a box that it can move and resize, so this attribution is exact for completed waves.
4. [b]Constant reversal within a wave[/b]. The reversal size is rounded to whole ticks and is stored when a wave starts. The ATR option uses the ATR of the previous completed day, so the threshold does not change during a session or during a wave.
The script also measures shortening of thrust on bar highs and lows, as the book specifies, and not on the closing turning points of the waves.


█ [b]NOTES / LIMITATIONS[/b]

 • [b]Repainting[/b]. The state of the waves changes only on confirmed bars, and completed waves do not change. The current wave is provisional by nature: its extreme and its volume increase until a reversal is confirmed, and a reversal is known only one or more bars after the extreme. In Running columns mode, the open realtime bar shows a provisional column that can change until the bar closes. In Wave boxes mode, the open bar is not drawn until it closes.
 • [b]Higher-timeframe request[/b]. On intraday charts, the ATR calculation requests the daily timeframe with lookahead and a one-bar offset. This supplies the ATR of the previous completed day and does not use future data. No output occurs until that value exists, so a symbol needs more daily bars of history than the ATR length. The other modes do not have this requirement.
 • [b]Running columns attribution[/b]. A plotted column cannot be changed after its bar closes. On untotaled bars, the gray columns show the pending total. The total for each wave is correct at its last colored column.
 • [b]Object limits[/b]. The platform permits 500 lines, 500 labels and 500 boxes per script. The script holds a maximum of 500 waves ([i]Waves kept[/i]), and removes the oldest wave and its drawings above that number. Thus the Wave boxes display, the wave line and the labels cover only the most recent waves. If the reversal size is small, this can be a short period. Running columns have no such limit and extend through the full chart history. Rank and shortening of thrust use only the waves held in memory.
 • [b]Timeframe sensitivity[/b]. The Auto presets are fixed price amounts for intraday study from approximately 2011. The script applies them on all timeframes. At present prices they can be too small, and on daily and higher charts they are usually too small. Use [i]Preset multiplier[/i] or a different mode. The default ATR multipliers are starting values of the author and are not from the book.
 • [b]Symbol class[/b]. Presets exist only for the futures roots in the list above, for forex symbols, and for stocks, funds and depositary receipts. All other symbols, including crypto, energy and cash indices, use the ATR calculation in Auto mode. The pip calculation for forex assumes that a quote with an odd number of decimals has a fractional pip digit.
 • [b]Volume data[/b]. The output depends on the volume that the data feed supplies. Forex and CFD volume is usually tick volume. The volume of a cash index can be a composite of its constituents with large values on the first and last bars of the session, and these values dominate the waves that include those bars. If a symbol has no volume and the true range setting is "Never", all columns are zero.
 • [b]Sessions[/b]. A wave continues through session boundaries and gaps, as in the book. A gap larger than the reversal size reverses the wave on the first close after the gap.
 • [b]Percent mode[/b]. The reversal size is calculated from the close on the bar that starts each wave and stays constant for that wave, so successive waves can have different sizes.
 • [b]Scope[/b]. The script is a tool for the analysis of price and volume. It does not give buy or sell signals.

## Source Code

````pine
//@version=6
// Weis Wave, close-extreme engine.
// Rules from David Weis, "Trades About to Happen", chapters 9 and 10:
//   1. Waves are built from bar closes.
//   2. A wave continues on any close at or beyond its extreme close.
//   3. A wave reverses when a close is the reversal amount or more off the extreme close.
//   4. Volume after the extreme stays untotaled. If the wave reverses, that volume belongs to the new wave.
// State changes only on confirmed bars, so completed waves do not repaint.
// The Calibrated reversal mode and the E>R flag are additions of this script, not rules from the book.
indicator("Weis Wave Volume, Close-Extreme", shorttitle = "WWV-CE", overlay = false, format = format.volume, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ───────────────────────── Inputs
string GRP_R = "Reversal size"
string M_CAL = "Calibrated"
string M_AUTO = "Auto (Weis table)"
string M_TICK = "Ticks"
string M_PRICE = "Price"
string M_PCT = "Percent"
string M_ATR = "ATR (frozen)"
string revMode = input.string(M_CAL, "Mode", options = [M_CAL, M_AUTO, M_TICK, M_PRICE, M_PCT, M_ATR], group = GRP_R, tooltip = "Calibrated picks the ATR multiple that makes waves last the target number of bars on average, on any timeframe. Auto uses Weis's published reversal for the symbol and falls back to frozen ATR when he published none (crypto, energy, indices). In every mode the size is latched when a wave starts and never changes inside a wave.")
float calTarget = input.float(3.0, "Target bars per wave", minval = 2.5, step = 0.5, group = GRP_R, tooltip = "Calibrated mode. The average wave length to aim for, in bars. Below 2.5 nearly every close against the wave reverses it, and the reversal size is poorly defined.")
int calLen = input.int(250, "Calibration length, bars", minval = 50, group = GRP_R, tooltip = "Calibrated mode. The number of recent bars the calibration averages over. 250 is about one year of daily bars. Longer is steadier, shorter adapts faster.")
float presetMult = input.float(1.0, "Preset multiplier", minval = 0.1, step = 0.5, group = GRP_R, tooltip = "Scales the Auto preset. Weis's figures date from about 2011. ES traded near 1300 then, so 0.75 points today is a much smaller fraction of price.")
int revTicks = input.int(3, "Ticks", minval = 1, group = GRP_R)
float revPrice = input.float(0.75, "Price", minval = 0.0, step = 0.01, group = GRP_R)
float revPct = input.float(0.05, "Percent of price", minval = 0.001, step = 0.01, group = GRP_R)
int atrLen = input.int(14, "ATR length", minval = 1, group = GRP_R, tooltip = "Used by ATR (frozen), by Calibrated, and by Auto when no preset applies.")
float atrMult = input.float(0.05, "ATR multiplier, intraday", minval = 0.001, step = 0.01, group = GRP_R, tooltip = "ATR (frozen) and the Auto fallback. Applied to the prior day's ATR on intraday charts. ATR sizing is not in the book.")
float atrMultHtf = input.float(1.0, "ATR multiplier, daily and higher", minval = 0.001, step = 0.1, group = GRP_R, tooltip = "ATR (frozen) and the Auto fallback. Applied to the prior bar's ATR when the chart is daily or higher.")

string GRP_V = "Volume"
string useTR = input.string("Auto", "Use true range instead of volume", options = ["Auto", "Always", "Never"], group = GRP_V, tooltip = "Auto uses true range until the first bar with volume and volume from then on, so a feed without volume gets true range and a feed with scattered missing bars does not switch back and forth. Weis uses range as the activity proxy in forex.")
bool autoFmt = input.bool(true, "Auto format volume (K, M)", group = GRP_V)
float volDiv = input.float(1000.0, "Volume divisor when auto format is off", minval = 1.0, group = GRP_V)

string GRP_D = "Display"
string H_BOX = "Wave boxes"
string H_COL = "Running columns"
string histMode = input.string(H_COL, "Histogram", options = [H_BOX, H_COL], group = GRP_D, tooltip = "Wave boxes: one block per wave with exact volume attribution, limited to the last 499 waves. Running columns: unlimited history, cumulative per bar, untotaled bars shown in gray.")
bool showPaneTxt = input.bool(false, "Volume text inside boxes", group = GRP_D)
bool showZig = input.bool(false, "Wave line on price chart", group = GRP_D)
int zigWidth = input.int(1, "Wave line width", minval = 1, maxval = 4, group = GRP_D)
bool showLbl = input.bool(false, "Labels at turning points", group = GRP_D)
bool lblLen = input.bool(false, "Label: wave length in ticks", group = GRP_D)
bool lblDur = input.bool(false, "Label: wave duration in bars", group = GRP_D)
string lblSizeIn = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = GRP_D)
color upCol = input.color(color.new(#26a69a, 0), "Up wave", group = GRP_D)
color dnCol = input.color(color.new(#ef5350, 0), "Down wave", group = GRP_D)
color limboCol = input.color(color.new(color.gray, 40), "Untotaled volume", group = GRP_D)
bool showTbl = input.bool(true, "Status table", group = GRP_D)
// 499 leaves one box for the untotaled block within the 500-box limit.
int maxWaves = input.int(400, "Waves kept", minval = 20, maxval = 499, group = GRP_D)
float scaleCap = input.float(3.0, "Pane scale cap, multiple of median wave volume", minval = 0.0, step = 0.5, group = GRP_D, tooltip = "Box mode only. Stops one outlier wave, such as a closing-auction bar, from flattening every other wave. Taller boxes run off the top of the pane and their true volume stays in the chart label. 0 disables the cap.")

string GRP_A = "Analytics and alerts"
int lookN = input.int(3, "Compare against prior N same-direction waves", minval = 1, maxval = 20, group = GRP_A, tooltip = "A wave with more volume than all N is drawn solid. A completed wave with less volume than all N is drawn faint.")
bool showSot = input.bool(true, "Flag shortening of thrust", group = GRP_A, tooltip = "Three successive same-direction waves making new highs (or lows) where the last gain is smaller than the one before. Measured on bar highs and lows, as the book specifies.")
bool showEr = input.bool(true, "Flag large effort, small result", group = GRP_A, tooltip = "A completed wave with more volume than each of the prior N same-direction waves, more volume per tick of progress than each of them, and a length in ticks shorter than the longest of them.")
bool alFlip = input.bool(true, "Alert: wave reversal", group = GRP_A)
bool alBig = input.bool(false, "Alert: largest volume in N waves", group = GRP_A)
bool alSot = input.bool(false, "Alert: shortening of thrust", group = GRP_A)
bool alEr = input.bool(false, "Alert: large effort, small result", group = GRP_A)

// ───────────────────────── Reversal size
// Weis's reversal sizes. The stock value is the 10-cent wave of his daily stock charts. na when he published none.
f_weisPreset() =>
    string t = syminfo.type
    // syminfo.root equals the ticker on stocks and funds, so match roots on futures only.
    string r = t == "futures" ? syminfo.root : ""
    float p = na
    if r == "ES" or r == "MES"
        p := 0.75
    if r == "NQ" or r == "MNQ"
        p := 2.0
    if r == "YM" or r == "MYM"
        p := 5.0
    if r == "RTY" or r == "M2K"
        p := 0.40
    if r == "ZB"
        p := 0.09375
    if r == "ZN" or r == "ZF"
        p := 0.015625
    if r == "GC" or r == "MGC"
        p := 5.0
    if r == "SI" or r == "SIL"
        p := 0.05
    if r == "HG"
        p := 0.0025
    if r == "ZS" or r == "ZC" or r == "ZW"
        p := 1.0
    if r == "SB" or r == "CT"
        p := 0.10
    if r == "CC"
        p := 2.0
    if r == "KC"
        p := 0.25
    if r == "6E" or r == "6B" or r == "6A" or r == "6C" or r == "6S" or r == "6N" or r == "M6E"
        p := 0.0003
    if na(p) and t == "forex"
        // 3 pips. A pip is 10 minticks when the quote carries a fractional pip digit.
        int decimals = int(math.round(-math.log10(syminfo.mintick)))
        float pip = decimals % 2 == 1 ? syminfo.mintick * 10.0 : syminfo.mintick
        p := 3.0 * pip
    if na(p) and (t == "stock" or t == "fund" or t == "dr")
        p := 0.10
    p

float preset = f_weisPreset()
bool presetFound = not na(preset)

// Prior completed ATR, so the value is fixed for the whole session on intraday charts.
string atrTf = timeframe.isintraday ? "D" : timeframe.period
float frozenAtr = request.security(syminfo.tickerid, atrTf, ta.atr(atrLen)[1], lookahead = barmerge.lookahead_on)

float EPS = syminfo.mintick * 0.01

// Whole ticks, minimum one tick.
f_quant(float x) =>
    na(x) ? na : math.max(math.round(x / syminfo.mintick) * syminfo.mintick, syminfo.mintick)

// Calibration. A ladder of shadow wave engines, each with the reversal CAL_M0 * CAL_G^k times the frozen ATR.
// Each tracks how often it reverses over the last calLen bars. The chosen multiple is the one whose
// average wave length equals the target, interpolated between ladder rungs on a log scale.
int CAL_K = 36
float CAL_M0 = 0.001
float CAL_G = 1.3
var array<int> calDir = array.new<int>(CAL_K, 0)
var array<float> calExt = array.new<float>(CAL_K, na)
var array<float> calRev = array.new<float>(CAL_K, na)
var array<float> calFreq = array.new<float>(CAL_K, 0.0)
var int calN = 0
var float calMult = na

f_calSelect() =>
    float res = na
    float prevM = na
    float prevB = na
    for k = 0 to CAL_K - 1
        float mk = CAL_M0 * math.pow(CAL_G, k)
        float fk = calFreq.get(k)
        // Average bars per wave on this rung. na means the rung has not reversed at all.
        float bk = fk > 0 ? 1.0 / fk : na
        if na(bk) or bk >= calTarget
            if na(prevB) or na(bk)
                res := mk
            else
                float t = (math.log(calTarget) - math.log(prevB)) / (math.log(bk) - math.log(prevB))
                res := prevM * math.pow(CAL_G, t)
            break
        prevM := mk
        prevB := bk
    na(res) ? CAL_M0 * math.pow(CAL_G, CAL_K - 1) : res

float atrM = timeframe.isintraday ? atrMult : atrMultHtf
float rawRev = na
if revMode == M_CAL
    // Multiple chosen through the prior bar.
    rawRev := calMult * frozenAtr
else if revMode == M_TICK
    rawRev := revTicks * syminfo.mintick
else if revMode == M_PRICE
    rawRev := revPrice
else if revMode == M_PCT
    rawRev := close * revPct / 100.0
else if revMode == M_ATR
    rawRev := frozenAtr * atrM
else
    rawRev := presetFound ? preset * presetMult : frozenAtr * atrM

float revNow = f_quant(rawRev)

// ───────────────────────── Volume source
// Auto uses true range until the first bar with volume, then volume for good. A per-bar test would switch
// back and forth on feeds with scattered missing bars, and syminfo.volumetype is "n/a" on most non-crypto symbols.
var bool volSeen = false
var int volStartTime = na
if not volSeen and volume > 0
    volSeen := true
    if bar_index > 0
        volStartTime := time
bool trActive = useTR == "Always" or (useTR == "Auto" and not volSeen)
float trv = ta.tr(true)
float v = trActive ? nz(trv) : nz(volume)

// ───────────────────────── Wave storage
type Wave
    int dir
    int startBar
    float startPrice
    int startTime
    int endBar
    float endPrice
    int endTime
    float vol
    float hi
    float lo
    int rank = 0
    bool sot = false
    bool er = false
    line zz
    label lb
    box bx

string lblSize = lblSizeIn == "Tiny" ? size.tiny : lblSizeIn == "Small" ? size.small : size.normal
bool useBoxes = histMode == H_BOX

f_volStr(float x) =>
    trActive ? str.tostring(math.round(x / syminfo.mintick)) + "t" : autoFmt ? str.tostring(x, format.volume) : str.tostring(x / volDiv, "#,##0.#")

f_ticks(Wave w) =>
    int(math.round(math.abs(w.endPrice - w.startPrice) / syminfo.mintick))

// 1 when the wave's volume exceeds all of the prior n same-direction waves.
// -1 when a completed wave's volume is below all of them. 0 otherwise or when history is short.
f_rank(array<Wave> ws, int idx, int n, bool isFinal) =>
    Wave w = ws.get(idx)
    float mx = na
    float mn = na
    int cnt = 0
    int i = idx - 2
    while i >= 0 and cnt < n
        Wave p = ws.get(i)
        mx := na(mx) ? p.vol : math.max(mx, p.vol)
        mn := na(mn) ? p.vol : math.min(mn, p.vol)
        cnt += 1
        i -= 2
    int res = 0
    if cnt == n
        if w.vol > mx
            res := 1
        else if isFinal and w.vol < mn
            res := -1
    res

f_sot(array<Wave> ws, int idx) =>
    bool res = false
    if idx >= 4
        Wave a = ws.get(idx - 4)
        Wave b = ws.get(idx - 2)
        Wave c = ws.get(idx)
        if c.dir == 1
            res := c.hi > b.hi and b.hi > a.hi and (c.hi - b.hi) < (b.hi - a.hi)
        else
            res := c.lo < b.lo and b.lo < a.lo and (b.lo - c.lo) < (a.lo - b.lo)
    res

// Large effort, small result: more volume than each of the prior n same-direction waves, more volume per tick
// of progress than each of them, and a length shorter than the longest of them. The last test only excludes
// the wave that made the largest move, so the flag means small progress for the volume.
f_er(array<Wave> ws, int idx, int n) =>
    Wave w = ws.get(idx)
    int wt = f_ticks(w)
    float mxVol = na
    float mxVpt = na
    int mxLen = 0
    int cnt = 0
    int i = idx - 2
    while i >= 0 and cnt < n
        Wave p = ws.get(i)
        int pt = f_ticks(p)
        mxVol := na(mxVol) ? p.vol : math.max(mxVol, p.vol)
        mxLen := math.max(mxLen, pt)
        if pt > 0
            float pv = p.vol / pt
            mxVpt := na(mxVpt) ? pv : math.max(mxVpt, pv)
        cnt += 1
        i -= 2
    cnt == n and wt > 0 and not na(mxVpt) and w.vol > mxVol and w.vol / wt > mxVpt and wt < mxLen

method render(Wave w) =>
    color c = w.dir == 1 ? upCol : dnCol
    int transp = w.rank == 1 ? 0 : w.rank == -1 ? 80 : 45
    string vs = f_volStr(w.vol)
    int ticks = f_ticks(w)
    int bars = w.endBar - w.startBar
    if showZig
        if na(w.zz)
            w.zz := line.new(w.startBar, w.startPrice, w.endBar, w.endPrice, xloc = xloc.bar_index, color = c, width = zigWidth, force_overlay = true)
        w.zz.set_xy2(w.endBar, w.endPrice)
    if showLbl
        string txt = vs + (lblLen ? "\n" + str.tostring(ticks) + "t" : "") + (lblDur ? "\n" + str.tostring(bars) + "b" : "") + (w.sot and showSot ? "\nSOT" : "") + (w.er and showEr ? "\nE>R" : "")
        float perTick = ticks > 0 ? w.vol / ticks : na
        float mins = (w.endTime - w.startTime) / 60000.0
        string durTxt = timeframe.isintraday ? str.tostring(mins, "#.#") + " min" : str.tostring(math.round(mins / 1440.0)) + " calendar days"
        string tip = (w.dir == 1 ? "Up wave" : "Down wave") + "\nVolume: " + vs + "\nLength: " + str.tostring(ticks) + " ticks" + "\nDuration: " + str.tostring(bars) + " bars, " + durTxt + "\nVolume per tick: " + (na(perTick) ? "n/a" : f_volStr(perTick)) + (w.rank == 1 ? "\nLargest volume in " + str.tostring(lookN) + " same-direction waves" : w.rank == -1 ? "\nSmallest volume in " + str.tostring(lookN) + " same-direction waves" : "") + (w.sot ? "\nShortening of thrust" : "") + (w.er ? "\nLarge effort, small result" : "")
        if na(w.lb)
            w.lb := label.new(w.endBar, w.endPrice, txt, xloc = xloc.bar_index, yloc = w.dir == 1 ? yloc.abovebar : yloc.belowbar, color = color(na), style = label.style_none, textcolor = c, size = lblSize, tooltip = tip, force_overlay = true)
        w.lb.set_x(w.endBar)
        w.lb.set_text(txt)
        w.lb.set_tooltip(tip)
    if useBoxes
        if na(w.bx)
            w.bx := box.new(w.startBar, w.vol, w.endBar, 0.0, border_color = c, border_width = 1, xloc = xloc.bar_index, bgcolor = color.new(c, transp), text_size = size.small, text_color = chart.fg_color, text_valign = text.align_top)
        w.bx.set_right(w.endBar)
        w.bx.set_top(w.vol)
        w.bx.set_bgcolor(color.new(c, transp))
        w.bx.set_border_width(w.er and showEr ? 3 : 1)
        w.bx.set_text(showPaneTxt ? vs : "")
    true

method erase(Wave w) =>
    w.zz.delete()
    w.lb.delete()
    w.bx.delete()
    true

// ───────────────────────── State
var array<Wave> waves = array.new<Wave>()
var int dir = 0
var float extPrice = na
var int extBar = na
var int extTime = na
var float rev = na
// Calibrated multiple behind rev, for the status table.
var float revMult = na
var float pendVol = 0.0
var float pendHi = na
var float pendLo = na
var box pendBox = na
var int wavesToday = 0
var float medVol = na

if timeframe.change("D")
    wavesToday := 0

bool evFlipUp = false
bool evFlipDn = false
bool evBig = false
bool evSot = false
bool evEr = false
float plotVol = na
color plotCol = na

if barstate.isconfirmed and not na(revNow)
    if na(extPrice)
        // Anchor. Direction is undetermined until price moves a full reversal from here.
        extPrice := close
        extBar := bar_index
        extTime := time
        rev := revNow
        revMult := calMult
    else
        bool newExt = dir == 1 ? close >= extPrice : dir == -1 ? close <= extPrice : false
        bool flipUp = dir != 1 and close - extPrice >= rev - EPS
        bool flipDn = dir != -1 and extPrice - close >= rev - EPS
        if newExt
            Wave w = waves.last()
            w.vol := w.vol + pendVol + v
            w.endBar := bar_index
            w.endPrice := close
            w.endTime := time
            w.hi := math.max(w.hi, nz(pendHi, high), high)
            w.lo := math.min(w.lo, nz(pendLo, low), low)
            int prevRank = w.rank
            w.rank := f_rank(waves, waves.size() - 1, lookN, false)
            evBig := w.rank == 1 and prevRank != 1
            extPrice := close
            extBar := bar_index
            extTime := time
            pendVol := 0.0
            pendHi := na
            pendLo := na
            w.render()
            plotVol := w.vol
            plotCol := color.new(dir == 1 ? upCol : dnCol, w.rank == 1 ? 0 : 45)
        else if flipUp or flipDn
            int nd = flipUp ? 1 : -1
            if waves.size() > 0
                Wave o = waves.last()
                // The thrust extreme can print on a bar after the extreme close, including this one.
                o.hi := math.max(o.hi, nz(pendHi, high), high)
                o.lo := math.min(o.lo, nz(pendLo, low), low)
                o.rank := f_rank(waves, waves.size() - 1, lookN, true)
                o.sot := f_sot(waves, waves.size() - 1)
                o.er := f_er(waves, waves.size() - 1, lookN)
                evSot := o.sot
                evEr := o.er
                o.render()
                // Median volume of the last 30 completed waves, used only to cap the pane scale.
                array<float> recent = array.new<float>()
                int k = waves.size() - 1
                while k >= 0 and recent.size() < 30
                    Wave q = waves.get(k)
                    recent.push(q.vol)
                    k -= 1
                medVol := recent.median()
            // Drop the oldest wave before adding one, so wave boxes plus the untotaled box never exceed 500.
            if waves.size() >= maxWaves
                Wave old = waves.shift()
                old.erase()
            Wave n = Wave.new(nd, extBar, extPrice, extTime, bar_index, close, time, pendVol + v, math.max(nz(pendHi, high), high), math.min(nz(pendLo, low), low))
            waves.push(n)
            n.rank := f_rank(waves, waves.size() - 1, lookN, false)
            evBig := n.rank == 1
            n.render()
            dir := nd
            evFlipUp := flipUp
            evFlipDn := flipDn
            wavesToday += 1
            extPrice := close
            extBar := bar_index
            extTime := time
            rev := revNow
            revMult := calMult
            pendVol := 0.0
            pendHi := na
            pendLo := na
            plotVol := n.vol
            plotCol := color.new(nd == 1 ? upCol : dnCol, n.rank == 1 ? 0 : 45)
        else
            pendVol += v
            pendHi := math.max(nz(pendHi, high), high)
            pendLo := math.min(nz(pendLo, low), low)
            plotVol := pendVol
            plotCol := limboCol

    // Untotaled volume block. It is absorbed by the current wave or becomes the next wave.
    if useBoxes and pendVol > 0
        if na(pendBox)
            pendBox := box.new(extBar, pendVol, bar_index, 0.0, border_color = limboCol, border_width = 1, xloc = xloc.bar_index, bgcolor = color.new(limboCol, 70))
        pendBox.set_left(extBar)
        pendBox.set_right(bar_index)
        pendBox.set_top(pendVol)
    if pendVol == 0 and not na(pendBox)
        pendBox.delete()
        pendBox := na

    if alFlip and (evFlipUp or evFlipDn) and waves.size() > 1
        Wave done = waves.get(waves.size() - 2)
        alert(syminfo.ticker + " Weis wave turned " + (evFlipUp ? "up" : "down") + ". Completed " + (done.dir == 1 ? "up" : "down") + " wave: volume " + f_volStr(done.vol) + ", " + str.tostring(f_ticks(done)) + " ticks, " + str.tostring(done.endBar - done.startBar) + " bars.", alert.freq_once_per_bar_close)
    if alBig and evBig
        alert(syminfo.ticker + " " + (dir == 1 ? "up" : "down") + " wave volume is the largest of the last " + str.tostring(lookN) + " same-direction waves.", alert.freq_once_per_bar_close)
    if alSot and evSot
        alert(syminfo.ticker + " shortening of thrust on the completed " + (dir == 1 ? "down" : "up") + " wave.", alert.freq_once_per_bar_close)
    if alEr and evEr
        alert(syminfo.ticker + " large effort, small result on the completed " + (dir == 1 ? "down" : "up") + " wave.", alert.freq_once_per_bar_close)

// ───────────────────────── Calibration update
// Runs after the main engine, so the multiple chosen on this bar first applies on the next bar.
if revMode == M_CAL and barstate.isconfirmed and not na(frozenAtr)
    calN += 1
    float alpha = 1.0 / math.min(calN, calLen)
    for k = 0 to CAL_K - 1
        float rk = f_quant(CAL_M0 * math.pow(CAL_G, k) * frozenAtr)
        float ek = calExt.get(k)
        int dk = calDir.get(k)
        int fl = 0
        if na(ek)
            calExt.set(k, close)
            calRev.set(k, rk)
        else if (dk == 1 and close >= ek) or (dk == -1 and close <= ek)
            calExt.set(k, close)
        else
            float rv = calRev.get(k)
            bool up = dk != 1 and close - ek >= rv - EPS
            bool dn = dk != -1 and ek - close >= rv - EPS
            if up or dn
                calDir.set(k, up ? 1 : -1)
                calExt.set(k, close)
                calRev.set(k, rk)
                fl := 1
        float fk = calFreq.get(k)
        calFreq.set(k, fk + (fl - fk) * alpha)
    // Wait for about ten waves' worth of bars before trusting the estimate.
    if calN >= math.max(20, int(10 * calTarget))
        calMult := f_calSelect()

// Volume of the live wave through its extreme bar.
float liveVol = na
if waves.size() > 0
    Wave lw = waves.last()
    liveVol := lw.vol

// Provisional column for the open realtime bar. Nothing is committed until the bar closes.
if not barstate.isconfirmed and dir != 0 and waves.size() > 0
    bool pExt = dir == 1 ? close >= extPrice : close <= extPrice
    bool pFlip = dir == 1 ? extPrice - close >= rev - EPS : close - extPrice >= rev - EPS
    plotVol := pExt ? liveVol + pendVol + v : pendVol + v
    plotCol := pExt ? color.new(dir == 1 ? upCol : dnCol, 45) : pFlip ? color.new(dir == 1 ? dnCol : upCol, 45) : limboCol

// ───────────────────────── Output
plot(useBoxes ? na : plotVol, "Wave volume", color = plotCol, style = plot.style_columns)
// Drawing objects do not drive autoscale, so an invisible plot carries the scale in box mode.
float rawScale = math.max(liveVol, pendVol)
float capVal = scaleCap > 0 and not na(medVol) ? medVol * scaleCap : rawScale
float scaleVal = useBoxes and not na(liveVol) ? math.min(rawScale, capVal) : na
plot(scaleVal, "Scale anchor", color = color.new(color.gray, 100), editable = false, display = display.pane)
hline(0, "Zero", color = color.new(color.gray, 60), linestyle = hline.style_solid)

alertcondition(evFlipUp, "Wave turned up", "Weis wave turned up")
alertcondition(evFlipDn, "Wave turned down", "Weis wave turned down")
alertcondition(evBig, "Largest volume in N waves", "Weis wave volume is the largest of the last N same-direction waves")
alertcondition(evSot, "Shortening of thrust", "Shortening of thrust on the completed Weis wave")
alertcondition(evEr, "Large effort, small result", "Large effort, small result on the completed Weis wave")

var table info = table.new(position.top_right, 1, 1)
if showTbl and barstate.islast
    string src = revMode
    if revMode == M_CAL
        src := "calibrated\n" + str.tostring(revMult, "#.####") + " x ATR for this wave, target " + str.tostring(calTarget) + " bars per wave"
    else if revMode == M_AUTO
        src := presetFound ? "Weis preset x" + str.tostring(presetMult) : "no Weis preset, ATR fallback"
    string txt = na(rev) ? (revMode == M_CAL ? "Calibrating, " + str.tostring(calN) + " of " + str.tostring(math.max(20, int(10 * calTarget))) + " bars" : "Waiting for enough history to set the reversal") : "Reversal " + str.tostring(rev, format.mintick) + " = " + str.tostring(math.round(rev / syminfo.mintick)) + " ticks, " + src
    if timeframe.isintraday
        txt := txt + "\nWaves today: " + str.tostring(wavesToday)
    int nb = math.min(waves.size() - 1, 50)
    if nb >= 2
        Wave wNew = waves.last()
        Wave wOld = waves.get(waves.size() - 1 - nb)
        float bpw = float(wNew.startBar - wOld.startBar) / nb
        txt := txt + "\nBars per wave, last " + str.tostring(nb) + " waves: " + str.tostring(bpw, "#.#")
    if trActive
        txt := txt + "\nTrue range used as volume"
    else if useTR == "Auto" and not na(volStartTime)
        txt := txt + "\nVolume from " + str.format_time(volStartTime, "yyyy-MM-dd", syminfo.timezone) + ", true range before"
    if syminfo.volumetype == "tick"
        txt := txt + "\nVolume is a tick count"
    if waves.size() > 0
        Wave firstKept = waves.first()
        txt := txt + "\nDrawn since " + str.format_time(firstKept.startTime, "yyyy-MM-dd", syminfo.timezone) + ", " + str.tostring(waves.size()) + " waves"
    table.cell(info, 0, 0, txt, text_color = chart.fg_color, text_size = size.small, text_halign = text.align_right, bgcolor = color.new(chart.bg_color, 20))
````
