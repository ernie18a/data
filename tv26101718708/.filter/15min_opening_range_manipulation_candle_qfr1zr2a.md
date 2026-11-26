# 15Min Opening RANGE - Manipulation Candle

- url: https://www.tradingview.com/script/QFR1Zr2a/
- type: indicator
- pine_id: PUB;08376bea61af467abbfcd6e03f6cd820
- version: 1.0

## Description

Opening Range Manipulation Candle [Custom]

This indicator automatically marks the opening range of the trading session and tells you at a glance whether that candle qualifies as a genuine "manipulation candle" — a fast, aggressive opening move that is more likely to reverse than continue.

How it works

Opening Range detection – The script tracks the high and low of the first 15-minute period of the session (default 09:30–09:45 New York time, fully configurable session window and timezone), regardless of what chart timeframe you are actually trading on (works the same on a 1-, 5-, or 15-minute chart).
Daily ATR filter – Once that opening range closes, its size (high − low) is compared to the prior day's completed 14-period Daily ATR (both length and lookback are configurable). If the range is equal to or greater than a chosen percentage of the Daily ATR (default 20%, adjustable), it is flagged as a confirmed manipulation candle.
Visual box – A box is drawn around the opening range and extended a configurable number of minutes to the right (default 105 minutes: the classic 90-minute reaction window plus a buffer). The box, its border, and its text turn green when the ATR condition is met, and red when it is not — so you instantly see whether the move is statistically significant enough to trust.
On-chart stats – A label attached to each box shows the exact Daily ATR value, the range size, and the resulting percentage, so you never have to calculate it by hand.
History for backtesting – The script keeps a configurable number of past sessions' boxes on the chart (default 10, adjustable up to several hundred) so you can scroll back and visually backtest how often the opening range actually qualified as a manipulation candle.
Alert – An optional alert fires the moment a session's opening range is confirmed as a valid manipulation candle (box turns green), so you can be notified without watching the chart.

Why it matters

The idea (popularized in retail ORB/liquidity-sweep strategies) is that large institutions often need to generate liquidity at the open by triggering stop-losses in one direction before reversing price in the other. A fast, oversized opening candle relative to the asset's normal daily volatility (ATR) is one practical way to filter for "real" institutional participation versus routine opening noise. This script does not predict direction or generate trade signals — it purely automates the range-marking and ATR-qualification steps, leaving pattern/entry confirmation (e.g. candlestick reversal signals) to the trader's own method or additional tools.

Inputs

Opening Range session & timezone
Box length after opening (minutes)
Number of past sessions to keep visible
Daily ATR length & threshold percentage
Box/border/text colors, border width & style, label size
Alert on/off

This script does not repaint the Daily ATR value: it always references the prior day's fully closed ATR, so the comparison is stable throughout the session.

## Source Code

````pine
// Custom Indicator – Opening Range Manipulationskerze (ATR-Check)
// Logik: Erste 15-Minuten-Kerze der Session (Opening Range) wird gegen den Daily ATR
// geprüft. Passt die Range zum ATR-Schwellenwert, wird die Box grün (bestätigte
// Manipulationskerze), sonst rot, inklusive ATR/Range/Prozent-Zahlen direkt an der Box.

//@version=6
indicator("ORB Manipulationskerze [Custom]", shorttitle="ORB Manipulation [Custom]", overlay=true, max_boxes_count=500, max_labels_count=500)

// ---------------------------------------------------------------------------------------------------------------------}
// 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎
// ---------------------------------------------------------------------------------------------------------------------{

// Opening Range
string orbSession   = input.session("0930-0945", "Opening Range Sitzung (15 Min)", group="Opening Range", tooltip="Zeitfenster der ersten 15-Minuten-Kerze. Standard 09:30–09:45.")
string sessTz       = input.string("America/New_York", "Zeitzone der Sitzung", group="Opening Range", tooltip="Zeitzone, in der die Sitzung definiert ist (Standard: New York = US-Marktöffnung).")
int    windowMinutes = input.int(105, "Box-Länge nach Opening (Minuten)", minval=15, step=15, group="Opening Range", tooltip="Wie weit die Box nach rechts über die 15-Minuten-Kerze hinaus verlängert wird. Standard 105 = 90 Min + 15 Min Puffer.")
int    keepSessions = input.int(10, "Anzahl anzuzeigender Sessions (Boxen)", minval=1, maxval=490, group="Opening Range", tooltip="Wie viele vergangene Opening-Range-Boxen gleichzeitig im Chart sichtbar bleiben sollen (fürs Backtesting).")

// ATR Filter
int   atrLen          = input.int(14, "Daily ATR Länge", minval=1, group="ATR Filter")
float atrThresholdPct  = input.float(20.0, "ATR Schwellenwert (%)", minval=1, maxval=100, step=1, group="ATR Filter", tooltip="Die 15-Minuten-Range muss mindestens X% des Daily ATR betragen, um als bestätigte Manipulationskerze zu gelten.")

// Box Darstellung
color  boxColorBull     = input.color(color.new(color.lime, 85), "Box Füllfarbe (bestätigt / grün)", group="Box Darstellung")
color  boxColorBear     = input.color(color.new(color.red, 85), "Box Füllfarbe (nicht bestätigt / rot)", group="Box Darstellung")
color  borderColorBull  = input.color(color.lime, "Rahmenfarbe (bestätigt / grün)", group="Box Darstellung")
color  borderColorBear  = input.color(color.red, "Rahmenfarbe (nicht bestätigt / rot)", group="Box Darstellung")
int    borderWidth      = input.int(2, "Rahmenbreite", minval=1, maxval=5, group="Box Darstellung")
string borderStyleStr   = input.string("Solid", "Rahmenstil", options=["Solid", "Dashed", "Dotted"], group="Box Darstellung")
color  textColorBull    = input.color(color.lime, "Textfarbe (bestätigt / grün)", group="Box Darstellung")
color  textColorBear    = input.color(color.red, "Textfarbe (nicht bestätigt / rot)", group="Box Darstellung")
string labelSizeStr     = input.string("Normal", "Info-Label Textgröße", options=["Winzig", "Klein", "Normal", "Groß"], group="Box Darstellung")

// Alarme
bool enableBoxAlert = input.bool(true, "Alarm bei bestätigter Manipulationskerze (Box grün)", group="Alarme")

// }
// ---------------------------------------------------------------------------------------------------------------------}
// 𝙄𝙉𝘿𝙄𝙆𝘼𝙏𝙊𝙍 𝘽𝙀𝙍𝙀𝘾𝙃𝙉𝙐𝙉𝙂𝙀𝙉
// ---------------------------------------------------------------------------------------------------------------------{

// ── Daily ATR (Wert des letzten vollständig geschlossenen Tages, kein Intrabar-Verzerren) ──
float dailyATR = request.security(syminfo.tickerid, "D", ta.atr(atrLen)[1], lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

// ── Sitzungs-Erkennung ──
sessionTimeVal       = time(timeframe.period, orbSession, sessTz)
bool inSession        = not na(sessionTimeVal)
bool newSessionBar    = inSession and na(sessionTimeVal[1])
bool sessionEndedBar  = not inSession and inSession[1]

int barsForWindow = math.max(1, int(math.round(windowMinutes * 60 / timeframe.in_seconds(timeframe.period))))

// ── Opening Range Tracking Variablen ──
var float orbHigh        = na
var float orbLow         = na
var int   orbStartBar    = na
var bool  orbActive      = false

var float dailyATRToday  = na
var float rangeSizeToday = na
var float rangePctToday  = na
var bool  passATRToday   = false

var box          rangeBox = na
var label        infoLabel = na
var array<box>   boxHist   = array.new<box>()
var array<label> lblHist   = array.new<label>()

if newSessionBar
    orbHigh     := high
    orbLow      := low
    orbStartBar := bar_index
    orbActive   := true
else if inSession and orbActive
    orbHigh := math.max(orbHigh, high)
    orbLow  := math.min(orbLow, low)

if sessionEndedBar
    orbActive      := false

    dailyATRToday  := dailyATR
    rangeSizeToday := orbHigh - orbLow
    rangePctToday  := dailyATRToday != 0 ? (rangeSizeToday / dailyATRToday) * 100 : na
    passATRToday   := rangeSizeToday >= dailyATRToday * (atrThresholdPct / 100)

    // ── Box + Info-Label zeichnen (alte Boxen bleiben für Backtesting erhalten) ──
    color borderCol = passATRToday ? borderColorBull : borderColorBear
    color bgCol     = passATRToday ? boxColorBull    : boxColorBear
    color txtCol    = passATRToday ? textColorBull   : textColorBear

    line_style_val = switch borderStyleStr
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

    int rightBar = orbStartBar + barsForWindow
    rangeBox := box.new(left=orbStartBar, top=orbHigh, right=rightBar, bottom=orbLow, border_color=borderCol, border_width=borderWidth, border_style=line_style_val, bgcolor=bgCol, extend=extend.none)

    label_size_val = switch labelSizeStr
        "Winzig" => size.tiny
        "Klein"  => size.small
        "Groß"   => size.large
        =>          size.normal

    string infoText = "ATR: " + str.tostring(dailyATRToday, format.mintick) + "\nRange: " + str.tostring(rangeSizeToday, format.mintick) + "\n= " + str.tostring(rangePctToday, "#.#") + "%"
    infoLabel := label.new(x=orbStartBar, y=orbHigh, text=infoText, style=label.style_label_down, color=color.new(color.black, 100), textcolor=txtCol, size=label_size_val, xloc=xloc.bar_index, textalign=text.align_left)

    // ── Nur die letzten "keepSessions" Boxen/Labels behalten, ältere entfernen ──
    array.push(boxHist, rangeBox)
    array.push(lblHist, infoLabel)
    if array.size(boxHist) > keepSessions
        box.delete(array.shift(boxHist))
        label.delete(array.shift(lblHist))

    if enableBoxAlert and passATRToday
        alert("Manipulationskerze bestätigt (Range " + str.tostring(rangePctToday, "#.#") + "% des Daily ATR) auf " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

// }
// ---------------------------------------------------------------------------------------------------------------------}
// 𝘼𝙇𝘼𝙍𝙈𝙀
// ---------------------------------------------------------------------------------------------------------------------{

alertcondition(sessionEndedBar and passATRToday, title="Opening Range ATR bestätigt", message="Opening Range bestätigt (Manipulationskerze) auf {{ticker}} ({{interval}})")
// }
````
