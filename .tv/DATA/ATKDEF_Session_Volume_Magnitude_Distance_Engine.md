<!-- tradingview-pine-id: PUB;01084de875384b62ad1cf8acf405814c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ATK/DEF — Session Volume Magnitude & Distance Engine

Source: https://www.tradingview.com/script/pwi02F79/

## Description

ATK/DEF - Session Volume Magnitude & Distance Engine is a session-based volume analysis framework designed to observe  activity across three defined market sessions: Asian, European, and US.

The script calculates the accumulated volume of each session independently and compares the completed session volumes within the same daily cycle. This creates a relative session-volume structure that allows the volume magnitude of each session to be observed within the same framework.

### Core Framework

* **Three-Session Volume Structure**
  Separate volume calculations for the Asian, European, and US sessions.

* **Session Volume Acmulation**
  Each session independently accumulates the volume of its confirmed bars.

* **Relative Session Volume Magnitude**
  Completed session volume is normalized against the highest completed session volume within the daily cycle.

* **Session Open / Close Structure**
  Each session records its opening and closing prices alongside its accumulated volume.

* **Session Volume Visualization**
  Relative volume magnitude is displayed through proportional session bars with corresponding volume values.

* **Independent Session Calculation**
  Asian, European, and US sessions are calculated separately using their defined session windows and time zones.

### Quantitative Session Analysis

The framework focuses specifically on the relationship between **session activity and session volume magnitude**.

Each session is treated as an independent calculation layer, while the completed sessions are compared within the same daily sequence.

The displayed volume values and relative magnitudes are derived directly from the volume data and calculation rules defined in the script.

### Analytical Purpose

This script is intended for **market observation, quantitative analysis, and -defined decision-making**.

The displayed session volume data and relative volume structure are analytical references only.

**Market observation, quantitative analysis, and -defined decision-making only.**

---

## Source Code

````pine
//@version=6
indicator("ATK/DEF — Session Volume Magnitude & Distance Engine", overlay=true, max_boxes_count=1000, max_labels_count=500)

// ── Inputs ────────────────────────────────
asiaColor   = input.color(color.new(color.blue, 40),  "Asia")
europeColor = input.color(color.new(color.green, 40), "Europe")
usColor     = input.color(color.new(color.red, 40),   "US")
barLenMax   = input.int(30, "Max Bar Length (bars)", minval=5, maxval=200)
maxQueue    = input.int(300, "FIFO Max Length", minval=50, maxval=5000)
rightOffset = input.int(10, "Right Offset", minval=1, maxval=100)

// ── Session Definitions (IANA timezones auto-handle DST) ──
asiaSess   = input.session("0800-1700", "Asia Kuala Lumpur 08-17")
europeSess = input.session("0800-1700", "Europe London 08-17")
usSess     = input.session("0900-1700", "US New York 09-17")

inAsia   = not na(time(timeframe.period, asiaSess,   "Asia/Kuala_Lumpur"))
inEurope = not na(time(timeframe.period, europeSess, "Europe/London"))
inUS     = not na(time(timeframe.period, usSess,     "America/New_York"))

// ── FIFO: independent per-bar management ──
// Queue elements: bar_index, high, low, close, volume, session type (0=Asia/1=Europe/2=US/-1=none)
var array<int>   qBar   = array.new_int()
var array<float> qHigh  = array.new_float()
var array<float> qLow   = array.new_float()
var array<float> qClose = array.new_float()
var array<float> qVol   = array.new_float()
var array<int>   qSess  = array.new_int()

if barstate.isconfirmed
    int sessType = inAsia ? 0 : inEurope ? 1 : inUS ? 2 : -1
    array.push(qBar,   bar_index)
    array.push(qHigh,  high)
    array.push(qLow,   low)
    array.push(qClose, close)
    array.push(qVol,   volume)
    array.push(qSess,  sessType)

    // FIFO overflow dequeue
    while array.size(qBar) > maxQueue
        array.shift(qBar)
        array.shift(qHigh)
        array.shift(qLow)
        array.shift(qClose)
        array.shift(qVol)
        array.shift(qSess)

// ── Daily reset at 08:00 Kuala Lumpur ─────
isReset = hour(time, "Asia/Kuala_Lumpur") == 8 and minute(time, "Asia/Kuala_Lumpur") == 0

var float volAsia   = 0.0
var float volEurope = 0.0
var float volUS     = 0.0

var float openAsia   = na
var float openEurope = na
var float openUS     = na

var float closeAsia   = na
var float closeEurope = na
var float closeUS     = na

// Track whether each session already ended, to avoid double drawing
var bool asiaDone   = false
var bool europeDone = false
var bool usDone     = false

if isReset
    volAsia := 0.0, volEurope := 0.0, volUS := 0.0
    openAsia := na, openEurope := na, openUS := na
    closeAsia := na, closeEurope := na, closeUS := na
    asiaDone := false, europeDone := false, usDone := false

// ── Session accumulation ──────────────────
if inAsia
    volAsia += volume
    openAsia := na(openAsia) ? open : openAsia
    closeAsia := close

if inEurope
    volEurope += volume
    openEurope := na(openEurope) ? open : openEurope
    closeEurope := close

if inUS
    volUS += volume
    openUS := na(openUS) ? open : openUS
    closeUS := close

// ── Session end detection (via FIFO queue) ──
// Currently outside session, previous bar inside → session just ended
isAsiaEnd   = not inAsia   and inAsia[1]   and not asiaDone
isEuropeEnd = not inEurope and inEurope[1] and not europeDone
isUSEnd     = not inUS     and inUS[1]     and not usDone

// ── Daily max session volume (for normalization) ──
var float maxSessionVol = 0.0
if isAsiaEnd
    maxSessionVol := math.max(maxSessionVol, volAsia)
if isEuropeEnd
    maxSessionVol := math.max(maxSessionVol, volEurope)
if isUSEnd
    maxSessionVol := math.max(maxSessionVol, volUS)

// ── Drawing: right-side progress bar at each session end ──
if isAsiaEnd and volAsia > 0
    int rightBar = bar_index + rightOffset
    float yPos = low
    float step = (high - low) * 0.2
    if step == 0
        step := syminfo.mintick * 10
    int len = maxSessionVol > 0 ? int((volAsia / maxSessionVol) * barLenMax) : barLenMax
    color c = closeAsia >= openAsia ? asiaColor : color.new(asiaColor, 20)
    box.new(rightBar, yPos, rightBar + len, yPos - step,
             bgcolor=c, border_color=color.new(c, 100))
    label.new(rightBar + len + 1, yPos - step / 2,
              "Asia " + str.tostring(volAsia / 1000, "#.#") + "K",
              style=label.style_label_left,
              color=color.new(asiaColor, 20),
              textcolor=color.white, size=size.small)
    asiaDone := true

if isEuropeEnd and volEurope > 0
    int rightBar = bar_index + rightOffset
    float yPos = (high + low) / 2
    float step = (high - low) * 0.2
    if step == 0
        step := syminfo.mintick * 10
    int len = maxSessionVol > 0 ? int((volEurope / maxSessionVol) * barLenMax) : barLenMax
    color c = closeEurope >= openEurope ? europeColor : color.new(europeColor, 20)
    box.new(rightBar, yPos, rightBar + len, yPos - step,
             bgcolor=c, border_color=color.new(c, 100))
    label.new(rightBar + len + 1, yPos - step / 2,
              "Europe " + str.tostring(volEurope / 1000, "#.#") + "K",
              style=label.style_label_left,
              color=color.new(europeColor, 20),
              textcolor=color.white, size=size.small)
    europeDone := true

if isUSEnd and volUS > 0
    int rightBar = bar_index + rightOffset
    float yPos = high
    float step = (high - low) * 0.2
    if step == 0
        step := syminfo.mintick * 10
    int len = maxSessionVol > 0 ? int((volUS / maxSessionVol) * barLenMax) : barLenMax
    color c = closeUS >= openUS ? usColor : color.new(usColor, 20)
    box.new(rightBar, yPos, rightBar + len, yPos - step,
             bgcolor=c, border_color=color.new(c, 100))
    label.new(rightBar + len + 1, yPos - step / 2,
              "US " + str.tostring(volUS / 1000, "#.#") + "K",
              style=label.style_label_left,
              color=color.new(usColor, 20),
              textcolor=color.white, size=size.small)
    usDone := true

// ── Clear maxSessionVol on daily reset ────
if isReset
    maxSessionVol := 0.0
````
