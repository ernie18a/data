# BOS + Displacement

- url: https://www.tradingview.com/script/U6qMGi8l-BOS-Displacement/
- type: indicator
- pine_id: PUB;fee8642b7f664f3bb2e4bed1bac34231
- version: 1.0

## Description

BOS + Displacement

This indicator does two things: it draws a line every time price breaks a local high or low (Break of Structure), and it highlights candles that move more than a set number of points (displacement candles).

Break of Structure lines

The script marks every local swing high and swing low. A swing low is a candle whose low is lower than the lows of the candles on both sides; a swing high is the reverse.
When a later candle closes beyond one of those levels, a horizontal line is drawn from the swing point to the candle that broke it.
Breaks to the upside are teal, breaks to the downside are fuchsia.
All unbroken levels are tracked at the same time (up to 50 per side), so an older level can still produce a line when price finally reaches it.
Signals only appear on closed candles, so lines do not repaint.

Displacement candles

A candle is recolored when its move is at least the point threshold that applies at that moment. Up candles turn green, down candles turn red.
The move is measured either as the body (open to close) or as the full range (high to low).
Thresholds are set through up to 8 rules. Each rule has a time window, a timeframe and a number of points, so every session can have its own threshold.
A rule only applies when the chart is on the rule’s timeframe. Set the timeframe to “Chart” to make a rule apply on every timeframe.
If several rules match the same candle, the lowest rule number wins.

Settings

Setting	What it does
Swing length	Number of candles on each side needed to confirm a swing. 1 marks every small turn; higher values give fewer, larger levels.
Max. number of lines	How many BOS lines stay on the chart. The oldest is removed when the limit is reached.
Break requires a close	On: only a close beyond the level counts. Off: a wick through the level also counts.
Show bullish / bearish breaks	Turn each direction on or off.
Measure move as	Body or full range for displacement candles.
Session time zone	Time zone used for the rule time windows. Includes the exchange time zone and a free-text option.
Points if no rule matches	Fallback threshold outside all rules. 0 means no coloring.
Rules 1–8	On/off, time window, timeframe and points for each rule.

Default rules (New York time, 1-minute chart)

Rule	Time	Points
1	09:30–12:00	30
2	20:00–00:00	14
3	02:00–05:00	14

Alerts

Three alert conditions are available: Bullish BOS, Bearish BOS and Displacement candle.

Limitations

A swing is only confirmed after the candles to its right have closed, so levels appear with a delay equal to the swing length.
With swing length 1 the script marks every minor break in both directions. It does not filter by trend and does not separate BOS from CHoCH.
The line limit hides older lines; it does not filter out weak signals.
Point thresholds are fixed values. They fit one instrument, one timeframe and the current volatility, and need to be adjusted when any of those change.
The indicator shows structure and momentum that have already happened. It does not predict direction and is not a trading signal on its own.

## Source Code

````pine
//@version=6
indicator("BOS + Displacement", "BOS+DISP", overlay = true, max_lines_count = 500)

// ================= BOS-instellingen =================
gBos = "Break of Structure"
pivotLen = input.int(1, "Swinglengte (candles links/rechts)", minval = 1, group = gBos, tooltip = "1 = elk lokaal hoogte-/dieptepunt. Hoger = minder lijnen.")
maxLines = input.int(10, "Max. aantal lijnen op de chart", minval = 1, maxval = 400, group = gBos)
useClose = input.bool(true, "Break vereist een close voorbij het niveau", group = gBos, tooltip = "Uit = een wick door het niveau telt ook.")
showBull = input.bool(true, "Toon bullish breaks", group = gBos)
showBear = input.bool(true, "Toon bearish breaks", group = gBos)
bullCol  = input.color(color.teal, "Kleur bullish", group = gBos)
bearCol  = input.color(color.fuchsia, "Kleur bearish", group = gBos)

// ================= Displacement-instellingen =================
gDisp = "Displacement candles"
dispOn      = input.bool(true, "Kleur displacement candles", group = gDisp)
dispMode    = input.string("Body (open-close)", "Meet beweging als", options = ["Body (open-close)", "Range (high-low)"], group = gDisp)
dispTzSel   = input.string("America/New_York", "Tijdzone van de sessies", group = gDisp, options = ["Beurs (van het instrument)", "Eigen invoer", "UTC", "Europe/Amsterdam", "Europe/London", "Europe/Berlin", "Europe/Paris", "Europe/Zurich", "Europe/Madrid", "Europe/Athens", "Europe/Istanbul", "Europe/Moscow", "America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "America/Toronto", "America/Mexico_City", "America/Sao_Paulo", "Africa/Johannesburg", "Asia/Dubai", "Asia/Kolkata", "Asia/Singapore", "Asia/Hong_Kong", "Asia/Shanghai", "Asia/Tokyo", "Asia/Seoul", "Australia/Sydney", "Pacific/Auckland"])
dispTzOwn   = input.string("UTC", "Eigen tijdzone (alleen bij 'Eigen invoer')", group = gDisp, tooltip = "IANA-naam, bijv. America/Bogota of Asia/Bangkok")
dispTz      = dispTzSel == "Beurs (van het instrument)" ? syminfo.timezone : dispTzSel == "Eigen invoer" ? dispTzOwn : dispTzSel
dispBullCol = input.color(#4CD964, "Kleur omhoog", group = gDisp)
dispBearCol = input.color(#E53935, "Kleur omlaag", group = gDisp)
defPts      = input.float(0, "Punten als geen regel past (0 = niet kleuren)", minval = 0, group = gDisp)

gR = "Displacement-regels: tijd, timeframe, punten (timeframe 'Chart' = elke timeframe)"
on1 = input.bool(true,  "1", inline = "r1", group = gR)
se1 = input.session("0930-1200", "", inline = "r1", group = gR)
tf1 = input.timeframe("1", "", inline = "r1", group = gR)
pt1 = input.float(30, "pt", minval = 0, inline = "r1", group = gR)
on2 = input.bool(true,  "2", inline = "r2", group = gR)
se2 = input.session("2000-0000", "", inline = "r2", group = gR)
tf2 = input.timeframe("1", "", inline = "r2", group = gR)
pt2 = input.float(14, "pt", minval = 0, inline = "r2", group = gR)
on3 = input.bool(true,  "3", inline = "r3", group = gR)
se3 = input.session("0200-0500", "", inline = "r3", group = gR)
tf3 = input.timeframe("1", "", inline = "r3", group = gR)
pt3 = input.float(14, "pt", minval = 0, inline = "r3", group = gR)
on4 = input.bool(false, "4", inline = "r4", group = gR)
se4 = input.session("0000-0000", "", inline = "r4", group = gR)
tf4 = input.timeframe("", "", inline = "r4", group = gR)
pt4 = input.float(20, "pt", minval = 0, inline = "r4", group = gR)
on5 = input.bool(false, "5", inline = "r5", group = gR)
se5 = input.session("0000-0000", "", inline = "r5", group = gR)
tf5 = input.timeframe("", "", inline = "r5", group = gR)
pt5 = input.float(20, "pt", minval = 0, inline = "r5", group = gR)
on6 = input.bool(false, "6", inline = "r6", group = gR)
se6 = input.session("0000-0000", "", inline = "r6", group = gR)
tf6 = input.timeframe("", "", inline = "r6", group = gR)
pt6 = input.float(20, "pt", minval = 0, inline = "r6", group = gR)
on7 = input.bool(false, "7", inline = "r7", group = gR)
se7 = input.session("0000-0000", "", inline = "r7", group = gR)
tf7 = input.timeframe("", "", inline = "r7", group = gR)
pt7 = input.float(20, "pt", minval = 0, inline = "r7", group = gR)
on8 = input.bool(false, "8", inline = "r8", group = gR)
se8 = input.session("0000-0000", "", inline = "r8", group = gR)
tf8 = input.timeframe("", "", inline = "r8", group = gR)
pt8 = input.float(20, "pt", minval = 0, inline = "r8", group = gR)

// ================= BOS-logica =================
maxPending = 50

var array<float> hiLvl = array.new<float>()
var array<int>   hiBar = array.new<int>()
var array<float> loLvl = array.new<float>()
var array<int>   loBar = array.new<int>()
var array<line>  bosLines = array.new<line>()

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

if not na(ph)
    hiLvl.push(ph)
    hiBar.push(bar_index - pivotLen)
    if hiLvl.size() > maxPending
        hiLvl.shift()
        hiBar.shift()

if not na(pl)
    loLvl.push(pl)
    loBar.push(bar_index - pivotLen)
    if loLvl.size() > maxPending
        loLvl.shift()
        loBar.shift()

addLine(float level, int fromBar, color col) =>
    bosLines.push(line.new(fromBar, level, bar_index, level, color = col, width = 1))
    if bosLines.size() > maxLines
        line.delete(bosLines.shift())

bullBos = false
bearBos = false

if barstate.isconfirmed
    if hiLvl.size() > 0
        for i = hiLvl.size() - 1 to 0
            lvl = hiLvl.get(i)
            if (useClose ? close > lvl : high > lvl)
                if showBull
                    addLine(lvl, hiBar.get(i), bullCol)
                bullBos := true
                hiLvl.remove(i)
                hiBar.remove(i)
    if loLvl.size() > 0
        for i = loLvl.size() - 1 to 0
            lvl = loLvl.get(i)
            if (useClose ? close < lvl : low < lvl)
                if showBear
                    addLine(lvl, loBar.get(i), bearCol)
                bearBos := true
                loLvl.remove(i)
                loBar.remove(i)

// ================= Displacement-logica =================
// Geeft de puntendrempel van een regel terug als die nu van toepassing is, anders na
ruleThr(bool isOn, string sess, string tf, float pts) =>
    inSession = not na(time(timeframe.period, sess, dispTz))
    tfMatch   = tf == "" or timeframe.in_seconds(tf) == timeframe.in_seconds()
    isOn and inSession and tfMatch ? pts : na

t1 = ruleThr(on1, se1, tf1, pt1)
t2 = ruleThr(on2, se2, tf2, pt2)
t3 = ruleThr(on3, se3, tf3, pt3)
t4 = ruleThr(on4, se4, tf4, pt4)
t5 = ruleThr(on5, se5, tf5, pt5)
t6 = ruleThr(on6, se6, tf6, pt6)
t7 = ruleThr(on7, se7, tf7, pt7)
t8 = ruleThr(on8, se8, tf8, pt8)

// Laagste regelnummer dat past wint
float thr = defPts > 0 ? defPts : na
thr := not na(t8) ? t8 : thr
thr := not na(t7) ? t7 : thr
thr := not na(t6) ? t6 : thr
thr := not na(t5) ? t5 : thr
thr := not na(t4) ? t4 : thr
thr := not na(t3) ? t3 : thr
thr := not na(t2) ? t2 : thr
thr := not na(t1) ? t1 : thr

move   = dispMode == "Body (open-close)" ? math.abs(close - open) : high - low
isDisp = dispOn and barstate.isconfirmed and not na(thr) and move >= thr

barcolor(isDisp ? (close >= open ? dispBullCol : dispBearCol) : na)

// ================= Alerts =================
alertcondition(bullBos, "Bullish BOS", "Bullish break of structure")
alertcondition(bearBos, "Bearish BOS", "Bearish break of structure")
alertcondition(isDisp, "Displacement candle", "Displacement candle")
````
