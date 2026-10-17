# CRT - Candle Range Theory

- url: https://www.tradingview.com/script/PiQhZpUB-CRT-Candle-Range-Theory/
- type: indicator
- pine_id: PUB;476d3c0ab71b459d8540b2cfae3e09bc
- version: 1.0

## Description

CRT - Candle Range Theory (CRH/CRL Marker)

This indicator automatically marks the High (CRH) and Low (CRL) of a higher-timeframe "range candle" once the next HTF candle sweeps it. It does not mark every candle, only valid CRT setups.

HOW IT WORKS
1. Candle 1 (range candle): the previous HTF candle (default 4H).
2. Candle 2 (sweep candle): the following HTF candle that takes out the high OR low of Candle 1.
3. Valid CRT: Candle 2 closes back INSIDE the range of Candle 1.
   - Bullish: sweeps below CRL, closes back inside. Target is CRH.
   - Bearish: sweeps above CRH, closes back inside. Target is CRL.
4. If Candle 2 closes outside the range (a breakout), or sweeps both sides, the setup is invalid and the CRH/CRL marks are removed.

FEATURES
- CRH/CRL drawn wick to wick on the range candle
- Live mode: marks the range as soon as price sweeps it, and removes it if the candle closes as a breakout
- Confirmed mode: marks only after the sweep candle closes inside the range
- Alerts for confirmed bullish and bearish CRT setups
- Customizable HTF timeframe and line/label color

HOW TO USE
Set the chart to a lower timeframe than the CRT timeframe (for example 5m chart with 4H CRT). Once CRH/CRL appear, look for entry confirmation on the lower timeframe (MSS/CHoCH, FVG, order block) rather than entering on the mark alone. The opposite end of the range is the potential target.

IMPORTANT NOTES
- Live mode is preliminary by design. Marks can appear and later disappear when the HTF candle closes outside the range. Use Confirmed mode (Live mode off) for non-repainting marks.
- Alerts fire only on confirmed setups.
- HTF candle times depend on the chart's timezone/exchange session.

DISCLAIMER
This tool is for educational and informational purposes only and is not financial advice. CRT is a discretionary concept and no setup is guaranteed. Always use proper risk management.

## Source Code

````pine
//@version=6
indicator("CRT - Candle Range Theory", overlay=true, max_lines_count=500, max_labels_count=500)

// ===== Settings =====
htf      = input.timeframe("240", "CRT Timeframe (HTF)")
liveMode = input.bool(true, "Live mode (lalabas agad pag nag-sweep)")
crColor  = input.color(color.white, "Kulay ng crh / crl")

// ===== Helpers =====
mkLine(t1, t2, y) =>
    line.new(t1, y, t2, y, xloc=xloc.bar_time, color=crColor)

mkLbl(t1, t2, y, txt, up) =>
    label.new(math.round((t1 + t2) / 2), y, txt, xloc=xloc.bar_time, style=up ? label.style_label_up : label.style_label_down, color=color.new(color.white, 100), textcolor=crColor, size=size.small)

// ===== State =====
var float prevH     = na   // Candle 1 (range)
var float prevL     = na
var int   prevStart = na
var float curH      = na   // Candle 2 (current / sweep)
var float curL      = na
var int   curStart  = na

var line  crhLine = na
var line  crlLine = na
var label crhLbl  = na
var label crlLbl  = na

bool bearConf = false
bool bullConf = false

newHTF = ta.change(time(htf)) != 0

if newHTF
    // I-finalize ang katatapos na 4H candle
    if not na(curH) and not na(prevH)
        cClose = close[1]
        bearValid = curH > prevH and cClose < prevH and cClose > prevL and not (curL < prevL)
        bullValid = curL < prevL and cClose > prevL and cClose < prevH and not (curH > prevH)

        if bearValid or bullValid
            bearConf := bearValid
            bullConf := bullValid

            // Siguraduhing may crh/crl (kung hindi live mode)
            if na(crhLine)
                crhLine := mkLine(prevStart, curStart, prevH)
                crlLine := mkLine(prevStart, curStart, prevL)
                crhLbl  := mkLbl(prevStart, curStart, prevH, "crh", false)
                crlLbl  := mkLbl(prevStart, curStart, prevL, "crl", true)
        else
            // INVALID: burahin ang minarkahang crh/crl
            line.delete(crhLine)
            line.delete(crlLine)
            label.delete(crhLbl)
            label.delete(crlLbl)

    // I-detach ang handles (nananatili sa chart ang valid na marks)
    crhLine := na
    crlLine := na
    crhLbl  := na
    crlLbl  := na

    // Roll: ang katatapos na candle ang bagong Candle 1
    prevH     := curH
    prevL     := curL
    prevStart := curStart
    curH      := high
    curL      := low
    curStart  := time
else
    curH := math.max(curH, high)
    curL := math.min(curL, low)

// ===== LIVE MODE: mark agad pag nag-sweep =====
if liveMode and not na(prevH)
    bearLive = curH > prevH and not (curL < prevL)
    bullLive = curL < prevL and not (curH > prevH)

    if (bearLive or bullLive) and na(crhLine)
        crhLine := mkLine(prevStart, curStart, prevH)
        crlLine := mkLine(prevStart, curStart, prevL)
        crhLbl  := mkLbl(prevStart, curStart, prevH, "crh", false)
        crlLbl  := mkLbl(prevStart, curStart, prevL, "crl", true)

    // Nag-sweep sa magkabilang side (outside bar) = hindi valid
    if not (bearLive or bullLive) and not na(crhLine)
        line.delete(crhLine)
        line.delete(crlLine)
        label.delete(crhLbl)
        label.delete(crlLbl)
        crhLine := na
        crlLine := na
        crhLbl  := na
        crlLbl  := na

// ===== Alerts (confirmed lang) =====
alertcondition(bullConf, "CRT Buy", "Bullish CRT setup")
alertcondition(bearConf, "CRT Sell", "Bearish CRT setup")
````
