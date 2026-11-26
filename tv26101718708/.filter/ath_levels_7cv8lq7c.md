# ATH Levels

- url: https://www.tradingview.com/script/7CV8Lq7c-ATH-Levels/
- type: indicator
- pine_id: PUB;a9b4b442c46d427d876842f7537b45f5
- version: 1.0

## Description

ATH Levels

All-time high distance tracker with dynamic tolerance zones, trend leg measurement, and precision alerts for SPY pullback and correction entries.

---

What it does:

ATH Levels automatically tracks the all-time high price and plots key percentage retracement levels below it. Each level represents a statistically significant support zone where SPY has historically shown mean reversion behavior — making them ideal reference points for swing and long term entry planning.

Key levels:
- ATH — current all-time high with days elapsed counter
- -3% / -4% — shallow pullback zones, first reaction levels
- -5% — standard pullback threshold, high probability bounce zone
- -10% — correction territory entry zone
- -15% / -20% — deep correction zones, high conviction long term entries
- -25% — bear market territory (disabled by default)

Dynamic tolerance zones:
Only the two nearest levels to current price show active tolerance bands — keeping the chart clean while highlighting exactly where price is most likely to react. Tolerance is tighter near ATH (-3%/-4% = 0.20%) and wider at deeper levels (0.30%).

Now label:
A floating label at current price shows exact distance from ATH in real time — instantly telling you where you stand in the pullback structure.

Trend Leg %:
Measures the current price move from the last weekly pivot low (when near ATH) or pivot high (when in correction). Displayed directly on the ATH label — showing how extended the current leg is and whether a continuation or reversal is more likely.

---

Key features:
- Analysis mode — reveals all colored level lines and tolerance boxes simultaneously for detailed review
- Anti-spam pivot engine — alerts fire once per confirmed pivot leg
- Individual and master alert system for every level
- Fully customizable colors, widths, and tolerances per level

---

Alert types (per level):
- Near — price approaching within tolerance zone
- Touch — price has intersected the level
- Over — price has broken above tolerance zone after a touch
- Under — price has broken below tolerance zone after a touch

---

How to use:
- On Daily chart — use levels for swing and long term entry planning with pyramiding
- On 1H chart — combine with Bias indicator verdicts for higher conviction entries
- Now label gives instant ATH distance context at a glance
- Trend Leg % on ATH label helps identify overextended moves before reversals

## Source Code

````pine
//@version=6
indicator("ATH Levels", shorttitle="ATH Lvls", overlay=true, max_labels_count=500, max_boxes_count=20)

// ╔══════════════════════════════════════════════════════════════════╗
// ║  SPY ATH LEVELS V1                                              ║
// ║  Levels: ATH, -3%, -4%, -5%, -10%, -15%, -20%, -25%            ║
// ║  Tolerance: -3%/-4% = 0.20%, others = 0.30%                    ║
// ║  Dynamic tolerance: active only for the 2 nearest levels        ║
// ║  Anti-spam: 1x per confirmed 15m pivot leg                      ║
// ╚══════════════════════════════════════════════════════════════════╝

// ── Label size ──
labelSizeOpt = input.string("Small", "Label size", options=["Tiny","Small","Normal","Large","Huge"])

labelSize = switch labelSizeOpt
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    =>          size.huge

// ── Mode ──
analysisMode = input.bool(false, "Analysis mode")

// ── Pivot L/R ──
pivotLR = input.int(3, "Pivot L/R bars", minval=1, maxval=10)

// ── ATH ──
showATH      = input.bool(true,  "ATH line",    inline="ath")
athColor     = input.color(color.new(color.purple, 0), "", inline="ath")
athWidth     = input.int(2, "",   minval=1, maxval=5,      inline="ath")
showATHLabel = input.bool(true,  "ATH label")
showNowLabel = input.bool(true,  "Now label")
showATHTol   = input.bool(true,  "ATH tolerance zone")
athTolPct    = input.float(0.20, "ATH tolerance %", minval=0.05, maxval=1.0, step=0.05)

// ── Trend Leg ──
showTrendLeg = input.bool(true,  "Trend leg % on ATH label")
trendLegLR   = input.int(3,      "Weekly Pivot L/R bars", minval=1, maxval=10)

// ── -3% ──
show3    = input.bool(true,  "-3% line",  inline="l3")
col3     = input.color(#A8D5A2, "",       inline="l3")
width3   = input.int(1, "",  minval=1, maxval=5, inline="l3")
showLbl3 = input.bool(true,  "-3% label")
tol3Pct  = input.float(0.20, "-3% tolerance %", minval=0.05, maxval=1.0, step=0.05)

// ── -4% ──
show4    = input.bool(true,  "-4% line",  inline="l4")
col4     = input.color(#A8D5A2, "",       inline="l4")
width4   = input.int(1, "",  minval=1, maxval=5, inline="l4")
showLbl4 = input.bool(true,  "-4% label")
tol4Pct  = input.float(0.20, "-4% tolerance %", minval=0.05, maxval=1.0, step=0.05)

// ── -5% ──
show5    = input.bool(true,  "-5% line",  inline="l5")
col5     = input.color(#4CAF50, "",       inline="l5")
width5   = input.int(1, "",  minval=1, maxval=5, inline="l5")
showLbl5 = input.bool(true,  "-5% label")
tol5Pct  = input.float(0.30, "-5% tolerance %", minval=0.05, maxval=1.0, step=0.05)

// ── -10% ──
show10    = input.bool(true,  "-10% line", inline="l10")
col10     = input.color(#90CAF9, "",       inline="l10")
width10   = input.int(1, "",  minval=1, maxval=5, inline="l10")
showLbl10 = input.bool(true,  "-10% label")
tol10Pct  = input.float(0.30, "-10% tolerance %", minval=0.05, maxval=1.0, step=0.05)

// ── -15% ──
show15    = input.bool(true,  "-15% line", inline="l15")
col15     = input.color(#2196F3, "",       inline="l15")
width15   = input.int(1, "",  minval=1, maxval=5, inline="l15")
showLbl15 = input.bool(true,  "-15% label")
tol15Pct  = input.float(0.30, "-15% tolerance %", minval=0.05, maxval=1.0, step=0.05)

// ── -20% ──
show20    = input.bool(true,  "-20% line", inline="l20")
col20     = input.color(#1565C0, "",       inline="l20")
width20   = input.int(1, "",  minval=1, maxval=5, inline="l20")
showLbl20 = input.bool(true,  "-20% label")
tol20Pct  = input.float(0.30, "-20% tolerance %", minval=0.05, maxval=1.0, step=0.05)

// ── -25% ──
show25    = input.bool(false, "-25% line", inline="l25")
col25     = input.color(#F44336, "",       inline="l25")
width25   = input.int(1, "",  minval=1, maxval=5, inline="l25")
showLbl25 = input.bool(false, "-25% label")
tol25Pct  = input.float(0.30, "-25% tolerance %", minval=0.05, maxval=1.0, step=0.05)

// ╔══════════════════════════════════════════════════════════════════╗
// ║ 11. ATH CALCULATION                                             ║
// ╚══════════════════════════════════════════════════════════════════╝
var float athVal = na
athVal := na(athVal[1]) ? high : math.max(athVal[1], high)

float level3  = athVal * 0.97
float level4  = athVal * 0.96
float level5  = athVal * 0.95
float level10 = athVal * 0.90
float level15 = athVal * 0.85
float level20 = athVal * 0.80
float level25 = athVal * 0.75

// ── ATH days since last ATH ──
// Skaičiuojame KALENDORINES DIENAS per Daily TF –
// veikia teisingai ant bet kokio chart timeframe.
// Daily ATH trackingas – atskiras nuo intraday athVal
float d_high_raw = request.security(syminfo.tickerid, "D",
     high, barmerge.gaps_off, barmerge.lookahead_off)

var float d_ath_track = na
var int   athBars     = 0

bool d_isNewDay = ta.change(time("D")) != 0

if na(d_ath_track)
    d_ath_track := d_high_raw
    athBars     := 0
else if d_high_raw > d_ath_track
    d_ath_track := d_high_raw
    athBars     := 0
else if d_isNewDay
    athBars += 1

// % from ATH
float pctFromAth = not na(athVal) and athVal != 0 ? (close / athVal - 1.0) * 100.0 : na

// ── Trend Leg % (Weekly pivot basis) ──
ethTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.extended)

float w_piv_low  = request.security(ethTicker, "W",
     ta.pivotlow(low,  trendLegLR, trendLegLR),
     barmerge.gaps_off, barmerge.lookahead_off)
float w_piv_high = request.security(ethTicker, "W",
     ta.pivothigh(high, trendLegLR, trendLegLR),
     barmerge.gaps_off, barmerge.lookahead_off)

var float last_w_piv_low  = na
var float last_w_piv_high = na
if not na(w_piv_low)
    last_w_piv_low  := w_piv_low
if not na(w_piv_high)
    last_w_piv_high := w_piv_high

float trendLegPct = na
if not na(pctFromAth)
    if pctFromAth > -5.0
        if not na(last_w_piv_low) and last_w_piv_low > 0
            trendLegPct := (close / last_w_piv_low - 1.0) * 100.0
    else
        if not na(last_w_piv_high) and last_w_piv_high > 0
            trendLegPct := (close / last_w_piv_high - 1.0) * 100.0

// ╔══════════════════════════════════════════════════════════════════╗
// ║ 12. DYNAMIC TOLERANCE ACTIVATION                                ║
// ╚══════════════════════════════════════════════════════════════════╝
l_3  = show3  ? level3  : na
l_4  = show4  ? level4  : na
l_5  = show5  ? level5  : na
l_10 = show10 ? level10 : na
l_15 = show15 ? level15 : na
l_20 = show20 ? level20 : na
l_25 = show25 ? level25 : na

var float nearestAbove = na
nearestAbove := na
if not na(l_3)  and l_3  > close
    nearestAbove := na(nearestAbove) or l_3  < nearestAbove ? l_3  : nearestAbove
if not na(l_4)  and l_4  > close
    nearestAbove := na(nearestAbove) or l_4  < nearestAbove ? l_4  : nearestAbove
if not na(l_5)  and l_5  > close
    nearestAbove := na(nearestAbove) or l_5  < nearestAbove ? l_5  : nearestAbove
if not na(l_10) and l_10 > close
    nearestAbove := na(nearestAbove) or l_10 < nearestAbove ? l_10 : nearestAbove
if not na(l_15) and l_15 > close
    nearestAbove := na(nearestAbove) or l_15 < nearestAbove ? l_15 : nearestAbove
if not na(l_20) and l_20 > close
    nearestAbove := na(nearestAbove) or l_20 < nearestAbove ? l_20 : nearestAbove
if not na(l_25) and l_25 > close
    nearestAbove := na(nearestAbove) or l_25 < nearestAbove ? l_25 : nearestAbove

var float nearestBelow = na
nearestBelow := na
if not na(l_3)  and l_3  < close
    nearestBelow := na(nearestBelow) or l_3  > nearestBelow ? l_3  : nearestBelow
if not na(l_4)  and l_4  < close
    nearestBelow := na(nearestBelow) or l_4  > nearestBelow ? l_4  : nearestBelow
if not na(l_5)  and l_5  < close
    nearestBelow := na(nearestBelow) or l_5  > nearestBelow ? l_5  : nearestBelow
if not na(l_10) and l_10 < close
    nearestBelow := na(nearestBelow) or l_10 > nearestBelow ? l_10 : nearestBelow
if not na(l_15) and l_15 < close
    nearestBelow := na(nearestBelow) or l_15 > nearestBelow ? l_15 : nearestBelow
if not na(l_20) and l_20 < close
    nearestBelow := na(nearestBelow) or l_20 > nearestBelow ? l_20 : nearestBelow
if not na(l_25) and l_25 < close
    nearestBelow := na(nearestBelow) or l_25 > nearestBelow ? l_25 : nearestBelow

tol3Active  = not na(l_3)  and (l_3  == nearestAbove or l_3  == nearestBelow)
tol4Active  = not na(l_4)  and (l_4  == nearestAbove or l_4  == nearestBelow)
tol5Active  = not na(l_5)  and (l_5  == nearestAbove or l_5  == nearestBelow)
tol10Active = not na(l_10) and (l_10 == nearestAbove or l_10 == nearestBelow)
tol15Active = not na(l_15) and (l_15 == nearestAbove or l_15 == nearestBelow)
tol20Active = not na(l_20) and (l_20 == nearestAbove or l_20 == nearestBelow)
tol25Active = not na(l_25) and (l_25 == nearestAbove or l_25 == nearestBelow)

// ╔══════════════════════════════════════════════════════════════════╗
// ║ 13. PIVOT ENGINE                                                ║
// ╚══════════════════════════════════════════════════════════════════╝
pivHigh = ta.pivothigh(high, pivotLR, pivotLR)
pivLow  = ta.pivotlow (low,  pivotLR, pivotLR)

var int pivLegId = 0
if not na(pivHigh) or not na(pivLow)
    pivLegId += 1

// ╔══════════════════════════════════════════════════════════════════╗
// ║ 14. HELPER FUNCTIONS                                            ║
// ╚══════════════════════════════════════════════════════════════════╝
f_upper(_lv, _t) => _lv * (1.0 + _t / 100.0)
f_lower(_lv, _t) => _lv * (1.0 - _t / 100.0)
f_near (_lv, _t) => high >= f_lower(_lv, _t) and low <= f_upper(_lv, _t)
f_touch(_lv)     => high >= _lv and low <= _lv

// ╔══════════════════════════════════════════════════════════════════╗
// ║ 15. ANTI-SPAM STATE                                             ║
// ╚══════════════════════════════════════════════════════════════════╝
var int  ath_nearLeg  = -1
var int  ath_touchLeg = -1
var bool ath_touched  = false

var int  l3_nearLeg  = -1,  l3_touchLeg  = -1,  l3_overLeg  = -1,  l3_underLeg  = -1
var bool l3_touched  = false
var int  l4_nearLeg  = -1,  l4_touchLeg  = -1,  l4_overLeg  = -1,  l4_underLeg  = -1
var bool l4_touched  = false
var int  l5_nearLeg  = -1,  l5_touchLeg  = -1,  l5_overLeg  = -1,  l5_underLeg  = -1
var bool l5_touched  = false
var int  l10_nearLeg = -1,  l10_touchLeg = -1,  l10_overLeg = -1,  l10_underLeg = -1
var bool l10_touched = false
var int  l15_nearLeg = -1,  l15_touchLeg = -1,  l15_overLeg = -1,  l15_underLeg = -1
var bool l15_touched = false
var int  l20_nearLeg = -1,  l20_touchLeg = -1,  l20_overLeg = -1,  l20_underLeg = -1
var bool l20_touched = false
var int  l25_nearLeg = -1,  l25_touchLeg = -1,  l25_overLeg = -1,  l25_underLeg = -1
var bool l25_touched = false

bool newPivot = not na(pivHigh) or not na(pivLow)
if newPivot
    ath_touched  := false
    l3_touched   := false
    l4_touched   := false
    l5_touched   := false
    l10_touched  := false
    l15_touched  := false
    l20_touched  := false
    l25_touched  := false

// ╔══════════════════════════════════════════════════════════════════╗
// ║ 16. ALERT FIRING                                                ║
// ╚══════════════════════════════════════════════════════════════════╝
bool ath_nearCond  = showATH and high >= f_lower(athVal, athTolPct) and low <= athVal and not f_touch(athVal)
bool ath_touchCond = showATH and f_touch(athVal)
bool ath_near  = ath_nearCond  and pivLegId != ath_nearLeg
bool ath_touch = ath_touchCond and pivLegId != ath_touchLeg
if ath_near
    ath_nearLeg := pivLegId
if ath_touch
    ath_touchLeg := pivLegId
    ath_touched  := true

f_alerts(_show, _lv, _t, _nL, _tL, _oL, _uL, _tched) =>
    bool _isNr = _show and f_near(_lv, _t) and not f_touch(_lv)
    bool _isTh = _show and f_touch(_lv)
    bool _isOv = _show and _tched and close > f_upper(_lv, _t) and not f_touch(_lv)
    bool _isUn = _show and _tched and close < f_lower(_lv, _t) and not f_touch(_lv)
    [_isNr and pivLegId != _nL,
     _isTh and pivLegId != _tL,
     _isOv and pivLegId != _oL,
     _isUn and pivLegId != _uL]

[l3_nr,  l3_th,  l3_ov,  l3_un ] = f_alerts(show3,  level3,  tol3Pct,  l3_nearLeg,  l3_touchLeg,  l3_overLeg,  l3_underLeg,  l3_touched)
[l4_nr,  l4_th,  l4_ov,  l4_un ] = f_alerts(show4,  level4,  tol4Pct,  l4_nearLeg,  l4_touchLeg,  l4_overLeg,  l4_underLeg,  l4_touched)
[l5_nr,  l5_th,  l5_ov,  l5_un ] = f_alerts(show5,  level5,  tol5Pct,  l5_nearLeg,  l5_touchLeg,  l5_overLeg,  l5_underLeg,  l5_touched)
[l10_nr, l10_th, l10_ov, l10_un] = f_alerts(show10, level10, tol10Pct, l10_nearLeg, l10_touchLeg, l10_overLeg, l10_underLeg, l10_touched)
[l15_nr, l15_th, l15_ov, l15_un] = f_alerts(show15, level15, tol15Pct, l15_nearLeg, l15_touchLeg, l15_overLeg, l15_underLeg, l15_touched)
[l20_nr, l20_th, l20_ov, l20_un] = f_alerts(show20, level20, tol20Pct, l20_nearLeg, l20_touchLeg, l20_overLeg, l20_underLeg, l20_touched)
[l25_nr, l25_th, l25_ov, l25_un] = f_alerts(show25, level25, tol25Pct, l25_nearLeg, l25_touchLeg, l25_overLeg, l25_underLeg, l25_touched)

if l3_nr
    l3_nearLeg  := pivLegId
if l3_th
    l3_touchLeg := pivLegId
    l3_touched  := true
if l3_ov
    l3_overLeg  := pivLegId
if l3_un
    l3_underLeg := pivLegId
if l4_nr
    l4_nearLeg  := pivLegId
if l4_th
    l4_touchLeg := pivLegId
    l4_touched  := true
if l4_ov
    l4_overLeg  := pivLegId
if l4_un
    l4_underLeg := pivLegId
if l5_nr
    l5_nearLeg  := pivLegId
if l5_th
    l5_touchLeg := pivLegId
    l5_touched  := true
if l5_ov
    l5_overLeg  := pivLegId
if l5_un
    l5_underLeg := pivLegId
if l10_nr
    l10_nearLeg  := pivLegId
if l10_th
    l10_touchLeg := pivLegId
    l10_touched  := true
if l10_ov
    l10_overLeg  := pivLegId
if l10_un
    l10_underLeg := pivLegId
if l15_nr
    l15_nearLeg  := pivLegId
if l15_th
    l15_touchLeg := pivLegId
    l15_touched  := true
if l15_ov
    l15_overLeg  := pivLegId
if l15_un
    l15_underLeg := pivLegId
if l20_nr
    l20_nearLeg  := pivLegId
if l20_th
    l20_touchLeg := pivLegId
    l20_touched  := true
if l20_ov
    l20_overLeg  := pivLegId
if l20_un
    l20_underLeg := pivLegId
if l25_nr
    l25_nearLeg  := pivLegId
if l25_th
    l25_touchLeg := pivLegId
    l25_touched  := true
if l25_ov
    l25_overLeg  := pivLegId
if l25_un
    l25_underLeg := pivLegId

// ╔══════════════════════════════════════════════════════════════════╗
// ║ 17. ALERT CONDITIONS                                            ║
// ╚══════════════════════════════════════════════════════════════════╝
string masterMsg = ""
if ath_near
    masterMsg := "Near ATH"
if ath_touch
    masterMsg := "ATH Touch"
if l3_nr
    masterMsg := masterMsg != "" ? masterMsg + " | Near ATH -3%" : "Near ATH -3%"
if l3_th
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -3% Touch" : "ATH -3% Touch"
if l3_ov
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -3% Over" : "ATH -3% Over"
if l3_un
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -3% Under" : "ATH -3% Under"
if l4_nr
    masterMsg := masterMsg != "" ? masterMsg + " | Near ATH -4%" : "Near ATH -4%"
if l4_th
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -4% Touch" : "ATH -4% Touch"
if l4_ov
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -4% Over" : "ATH -4% Over"
if l4_un
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -4% Under" : "ATH -4% Under"
if l5_nr
    masterMsg := masterMsg != "" ? masterMsg + " | Near ATH -5%" : "Near ATH -5%"
if l5_th
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -5% Touch" : "ATH -5% Touch"
if l5_ov
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -5% Over" : "ATH -5% Over"
if l5_un
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -5% Under" : "ATH -5% Under"
if l10_nr
    masterMsg := masterMsg != "" ? masterMsg + " | Near ATH -10%" : "Near ATH -10%"
if l10_th
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -10% Touch" : "ATH -10% Touch"
if l10_ov
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -10% Over" : "ATH -10% Over"
if l10_un
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -10% Under" : "ATH -10% Under"
if l15_nr
    masterMsg := masterMsg != "" ? masterMsg + " | Near ATH -15%" : "Near ATH -15%"
if l15_th
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -15% Touch" : "ATH -15% Touch"
if l15_ov
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -15% Over" : "ATH -15% Over"
if l15_un
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -15% Under" : "ATH -15% Under"
if l20_nr
    masterMsg := masterMsg != "" ? masterMsg + " | Near ATH -20%" : "Near ATH -20%"
if l20_th
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -20% Touch" : "ATH -20% Touch"
if l20_ov
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -20% Over" : "ATH -20% Over"
if l20_un
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -20% Under" : "ATH -20% Under"
if l25_nr
    masterMsg := masterMsg != "" ? masterMsg + " | Near ATH -25%" : "Near ATH -25%"
if l25_th
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -25% Touch" : "ATH -25% Touch"
if l25_ov
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -25% Over" : "ATH -25% Over"
if l25_un
    masterMsg := masterMsg != "" ? masterMsg + " | ATH -25% Under" : "ATH -25% Under"

bool masterTrigger = ath_near or ath_touch or
     l3_nr  or l3_th  or l3_ov  or l3_un  or
     l4_nr  or l4_th  or l4_ov  or l4_un  or
     l5_nr  or l5_th  or l5_ov  or l5_un  or
     l10_nr or l10_th or l10_ov or l10_un or
     l15_nr or l15_th or l15_ov or l15_un or
     l20_nr or l20_th or l20_ov or l20_un or
     l25_nr or l25_th or l25_ov or l25_un

if masterTrigger
    alert("SPY ATH Levels | " + masterMsg + " @ " + str.tostring(math.round(close, 2)), alert.freq_once_per_bar)

alertcondition(ath_near,  title="Near ATH",      message="SPY ATH Levels: Near ATH @ {{close}}")
alertcondition(ath_touch, title="ATH Touch",     message="SPY ATH Levels: ATH Touch @ {{close}}")
alertcondition(l3_nr,  title="Near ATH -3%",     message="SPY ATH Levels: Near ATH -3% @ {{close}}")
alertcondition(l3_th,  title="ATH -3% Touch",    message="SPY ATH Levels: ATH -3% Touch @ {{close}}")
alertcondition(l3_ov,  title="ATH -3% Over",     message="SPY ATH Levels: ATH -3% Over @ {{close}}")
alertcondition(l3_un,  title="ATH -3% Under",    message="SPY ATH Levels: ATH -3% Under @ {{close}}")
alertcondition(l4_nr,  title="Near ATH -4%",     message="SPY ATH Levels: Near ATH -4% @ {{close}}")
alertcondition(l4_th,  title="ATH -4% Touch",    message="SPY ATH Levels: ATH -4% Touch @ {{close}}")
alertcondition(l4_ov,  title="ATH -4% Over",     message="SPY ATH Levels: ATH -4% Over @ {{close}}")
alertcondition(l4_un,  title="ATH -4% Under",    message="SPY ATH Levels: ATH -4% Under @ {{close}}")
alertcondition(l5_nr,  title="Near ATH -5%",     message="SPY ATH Levels: Near ATH -5% @ {{close}}")
alertcondition(l5_th,  title="ATH -5% Touch",    message="SPY ATH Levels: ATH -5% Touch @ {{close}}")
alertcondition(l5_ov,  title="ATH -5% Over",     message="SPY ATH Levels: ATH -5% Over @ {{close}}")
alertcondition(l5_un,  title="ATH -5% Under",    message="SPY ATH Levels: ATH -5% Under @ {{close}}")
alertcondition(l10_nr, title="Near ATH -10%",    message="SPY ATH Levels: Near ATH -10% @ {{close}}")
alertcondition(l10_th, title="ATH -10% Touch",   message="SPY ATH Levels: ATH -10% Touch @ {{close}}")
alertcondition(l10_ov, title="ATH -10% Over",    message="SPY ATH Levels: ATH -10% Over @ {{close}}")
alertcondition(l10_un, title="ATH -10% Under",   message="SPY ATH Levels: ATH -10% Under @ {{close}}")
alertcondition(l15_nr, title="Near ATH -15%",    message="SPY ATH Levels: Near ATH -15% @ {{close}}")
alertcondition(l15_th, title="ATH -15% Touch",   message="SPY ATH Levels: ATH -15% Touch @ {{close}}")
alertcondition(l15_ov, title="ATH -15% Over",    message="SPY ATH Levels: ATH -15% Over @ {{close}}")
alertcondition(l15_un, title="ATH -15% Under",   message="SPY ATH Levels: ATH -15% Under @ {{close}}")
alertcondition(l20_nr, title="Near ATH -20%",    message="SPY ATH Levels: Near ATH -20% @ {{close}}")
alertcondition(l20_th, title="ATH -20% Touch",   message="SPY ATH Levels: ATH -20% Touch @ {{close}}")
alertcondition(l20_ov, title="ATH -20% Over",    message="SPY ATH Levels: ATH -20% Over @ {{close}}")
alertcondition(l20_un, title="ATH -20% Under",   message="SPY ATH Levels: ATH -20% Under @ {{close}}")
alertcondition(l25_nr, title="Near ATH -25%",    message="SPY ATH Levels: Near ATH -25% @ {{close}}")
alertcondition(l25_th, title="ATH -25% Touch",   message="SPY ATH Levels: ATH -25% Touch @ {{close}}")
alertcondition(l25_ov, title="ATH -25% Over",    message="SPY ATH Levels: ATH -25% Over @ {{close}}")
alertcondition(l25_un, title="ATH -25% Under",   message="SPY ATH Levels: ATH -25% Under @ {{close}}")

// ╔══════════════════════════════════════════════════════════════════╗
// ║ 18. PLOTTING                                                    ║
// ╚══════════════════════════════════════════════════════════════════╝
color blackCol = color.new(color.black, 0)

c3   = analysisMode ? col3   : blackCol
c4   = analysisMode ? col4   : blackCol
c5   = analysisMode ? col5   : blackCol
c10  = analysisMode ? col10  : blackCol
c15  = analysisMode ? col15  : blackCol
c20  = analysisMode ? col20  : blackCol
c25  = analysisMode ? col25  : blackCol

plot(showATH                 ? athVal  : na, title="ATH",  color=athColor, linewidth=athWidth)
plot(show3  and analysisMode ? level3  : na, title="-3%",  color=c3,  linewidth=width3)
plot(show4  and analysisMode ? level4  : na, title="-4%",  color=c4,  linewidth=width4)
plot(show5  and analysisMode ? level5  : na, title="-5%",  color=c5,  linewidth=width5)
plot(show10 and analysisMode ? level10 : na, title="-10%", color=c10, linewidth=width10)
plot(show15 and analysisMode ? level15 : na, title="-15%", color=c15, linewidth=width15)
plot(show20 and analysisMode ? level20 : na, title="-20%", color=c20, linewidth=width20)
plot(show25 and analysisMode ? level25 : na, title="-25%", color=c25, linewidth=width25)

// ── Tolerance boxes ──
var int todayStartBar = 0
if ta.change(time("D")) != 0
    todayStartBar := bar_index

f_box_update(_bx, _active, _show, _level, _tolPct, _col) =>
    var box _b = _bx
    _boxCol = analysisMode ? _col : color.black
    if _show and _active and not na(_level)
        float _up = f_upper(_level, _tolPct)
        float _dn = f_lower(_level, _tolPct)
        if na(_b)
            _b := box.new(todayStartBar, _up, bar_index + 1, _dn,
                 border_color=color.new(_boxCol, 70),
                 bgcolor=color.new(_boxCol, 88),
                 border_width=1)
        else
            box.set_top         (_b, _up)
            box.set_bottom      (_b, _dn)
            box.set_left        (_b, todayStartBar)
            box.set_right       (_b, bar_index + 1)
            box.set_border_color(_b, color.new(_boxCol, 70))
            box.set_bgcolor     (_b, color.new(_boxCol, 88))
    else
        if not na(_b)
            box.delete(_b)
            _b := na
    _b

var box bx_ath = na
var box bx_3   = na
var box bx_4   = na
var box bx_5   = na
var box bx_10  = na
var box bx_15  = na
var box bx_20  = na
var box bx_25  = na

bx_ath := f_box_update(bx_ath, showATHTol,  showATHTol, athVal,  athTolPct, athColor)
bx_3   := f_box_update(bx_3,   tol3Active,  show3,      level3,  tol3Pct,   col3)
bx_4   := f_box_update(bx_4,   tol4Active,  show4,      level4,  tol4Pct,   col4)
bx_5   := f_box_update(bx_5,   tol5Active,  show5,      level5,  tol5Pct,   col5)
bx_10  := f_box_update(bx_10,  tol10Active, show10,     level10, tol10Pct,  col10)
bx_15  := f_box_update(bx_15,  tol15Active, show15,     level15, tol15Pct,  col15)
bx_20  := f_box_update(bx_20,  tol20Active, show20,     level20, tol20Pct,  col20)
bx_25  := f_box_update(bx_25,  tol25Active, show25,     level25, tol25Pct,  col25)

// ╔══════════════════════════════════════════════════════════════════╗
// ║ 19. LABELS                                                      ║
// ╚══════════════════════════════════════════════════════════════════╝
fmt_pct(_p) => (_p >= 0 ? "+" : "") + str.tostring(math.round(_p, 2)) + "%"

var label lbl_ath = na
var label lbl_now = na
var label lbl_3   = na
var label lbl_4   = na
var label lbl_5   = na
var label lbl_10  = na
var label lbl_15  = na
var label lbl_20  = na
var label lbl_25  = na

f_lbl(_lbl, _show, _y, _txt, _col) =>
    if _show and not na(_y) and barstate.islast
        if na(_lbl)
            label.new(bar_index, _y, _txt,
                 style=label.style_label_left, color=_col,
                 textcolor=color.white, size=labelSize)
        else
            label.set_xy(_lbl, bar_index, _y)
            label.set_text(_lbl, _txt)
            label.set_color(_lbl, _col)
            _lbl
    else
        if not _show and not na(_lbl)
            label.delete(_lbl)
        na

if barstate.islast
    if showATH and showATHLabel and not na(athVal)
        _t = "ATH " + str.tostring(math.round(athVal, 2)) + "  " + str.tostring(athBars) + "d"
        if showTrendLeg and not na(trendLegPct)
            _t += "  |  Leg " + fmt_pct(trendLegPct)
        if na(lbl_ath)
            lbl_ath := label.new(bar_index, athVal, _t,
                 style=label.style_label_left, color=athColor,
                 textcolor=color.white, size=labelSize)
        else
            label.set_xy(lbl_ath, bar_index, athVal)
            label.set_text(lbl_ath, _t)
            label.set_color(lbl_ath, athColor)
    else if not (showATH and showATHLabel) and not na(lbl_ath)
        label.delete(lbl_ath), lbl_ath := na

    if showNowLabel and not na(pctFromAth)
        _nc = close >= open ? color.green : color.red
        _nt = "Now " + str.tostring(math.round(close, 2)) + "  " + fmt_pct(pctFromAth)
        if na(lbl_now)
            lbl_now := label.new(bar_index, close, _nt,
                 style=label.style_label_left, color=_nc,
                 textcolor=color.white, size=labelSize)
        else
            label.set_xy(lbl_now, bar_index, close)
            label.set_text(lbl_now, _nt)
            label.set_color(lbl_now, _nc)
    else if not showNowLabel and not na(lbl_now)
        label.delete(lbl_now), lbl_now := na

    _lblCol3  = analysisMode ? col3  : color.black
    _lblCol4  = analysisMode ? col4  : color.black
    _lblCol5  = analysisMode ? col5  : color.black
    _lblCol10 = analysisMode ? col10 : color.black
    _lblCol15 = analysisMode ? col15 : color.black
    _lblCol20 = analysisMode ? col20 : color.black
    _lblCol25 = analysisMode ? col25 : color.black

    lbl_3  := f_lbl(lbl_3,  showLbl3,  level3,  "-3%   " + str.tostring(math.round(level3,  2)), _lblCol3)
    lbl_4  := f_lbl(lbl_4,  showLbl4,  level4,  "-4%   " + str.tostring(math.round(level4,  2)), _lblCol4)
    lbl_5  := f_lbl(lbl_5,  showLbl5,  level5,  "-5%   " + str.tostring(math.round(level5,  2)), _lblCol5)
    lbl_10 := f_lbl(lbl_10, showLbl10, level10, "-10%  " + str.tostring(math.round(level10, 2)), _lblCol10)
    lbl_15 := f_lbl(lbl_15, showLbl15, level15, "-15%  " + str.tostring(math.round(level15, 2)), _lblCol15)
    lbl_20 := f_lbl(lbl_20, showLbl20, level20, "-20%  " + str.tostring(math.round(level20, 2)), _lblCol20)
    lbl_25 := f_lbl(lbl_25, showLbl25, level25, "-25%  " + str.tostring(math.round(level25, 2)), _lblCol25)
````
