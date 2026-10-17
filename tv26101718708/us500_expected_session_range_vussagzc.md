# US500 Expected Session Range

- url: https://www.tradingview.com/script/vUssaGzC-US500-Expected-Session-Range/
- type: indicator
- pine_id: PUB;5cd458db0d6a483a93cdda17a6c7dc9d
- version: 1.0

## Description

US500 Session Expected Range (Asia / London / US)

Draws forecast boxes for the Asia, London and US trading sessions showing how far price is likely to travel. It does not predict direction. It only tells you how big the session is likely to be.

HOW IT WORKS
Thirty minutes after each session opens, the script forecasts the range (high minus low) for the rest of the session from four things:
1. The average range of the last 14 sessions of the same type.
2. The range of the previous session.
3. The range of the 6 hours before the open.
4. The range of the first 30 minutes.
Each session has its own fitted weights. On news days the forecast is scaled up: FOMC x1.7 (US session), CPI x1.8 and jobs report x1.6 (London session, where the 08:30 ET release lands). No news effect was found in Asia.

Sessions: Asia = Tokyo 09:00-15:00, London = 03:00-09:30 New York, US = 09:30-16:00 New York. Each one can be switched on or off.

FOUR OPTIONAL BOXES (same sizes for every session)
Centred on the price 30 minutes after the open and drawn to the end of the session.
- Range 50% (solid): price stayed inside it for the whole rest of the session on about 50% of days.
- Range 80% (solid, larger): about 80% of days.
- Close 50% (dashed): only the session close landed inside it, about 50% of days.
- Close 80% (dashed, off by default): same, about 80% of days.
Range boxes cover every tick. Close boxes only cover where the session ends, so they are tighter. Pick whichever matches how you trade.
Colour shows the mood: blue = calm, yellow = normal, orange = wild, purple = news day.

HOW OFTEN THE BOXES HELD
Tested on US500 1-minute data, Jan 2023 to Sep 2026, about 860 to 950 sessions per session type. Each year was forecast using weights fitted on the other years (leave-one-year-out).
Asia (862 sessions): Range 50% 51% | Range 80% 82% | Close 50% 51% | Close 80% 80%
London (954): 50% | 80% | 53% | 81%
US (917): 51% | 80% | 48% | 80%
Single years moved around: the 50% boxes ranged from about 41% to 61%, the 80% boxes from about 73% to 87%. Half of all sessions land within about -25% / +28% of the forecast.

HOW IT COMPARES WITH ATR
Share of the session-to-session variation in range that is explained (higher is better), against ATR(14) on the 1-hour chart, with ATR given its own best scaling:
- Asia: 50% vs 37% (ATR 15m: 42%). Closer than ATR in about 58% of sessions. Clear win.
- London: 45% vs 36%. Level once ATR also gets the same CPI/jobs multipliers (44%).
- US: 40% vs 38%. A properly scaled ATR with the FOMC multiplier is slightly ahead (42%).
So outside Asia this is not a more accurate forecast than a well-scaled ATR. What it adds is ready-made boxes with measured hit rates, news handling and all three sessions in one tool.

LIMITS
- No direction, no entry signals. Half of all sessions break the 50% boxes by design.
- Fitted on a US500 CFD feed. Futures and other markets are untested.
- Weights were fitted on the same period shown above. Expect live results to be a little worse.
- Pine cannot read the economic calendar, so news dates are typed in (to Dec 2026). Update them in settings.

USE
- Chart: 1m to 30m. Needs about 15 sessions of history loaded.
- Table: expected range, news flag and how much of the range is used so far, one column per session.
- Settings: toggle each session, each box and the tags. Weights, box sizes and news dates are editable.

For information only. Not financial advice.

## Source Code

````pine
//@version=6
indicator('US500 Expected Range Sessions v4', shorttitle = 'ExpSessionRange', overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// =====================================================================
// Predicts HOW FAR US500 will move (high-low) in each trading session, using only what is
// known 30 minutes after the session opens. It does NOT predict direction.
//   Asia   : Tokyo 09:00-15:00   (Perth 08:00-14:00, no daylight saving)
//   London : 03:00-09:30 New York (Perth 15:00-21:30 in US summer time)
//   US     : 09:30-16:00 New York (Perth 21:30-04:00 in US summer time)
// Each session is optional (settings > Which sessions to show) and has its own fitted weights.
// Fitted on US500 1-minute data Jan 2023 - Sep 2026 and tested year by year:
//   share of variation explained  Asia ~50%, London ~45%, US ~40%.
//   Compared with a plain ATR(14) on the 1-hour chart: clearly better in Asia, about equal in
//   London and the US once ATR is given the same news multipliers.
// FOUR OPTIONAL BOXES, centred on the price 30 minutes after the open, same sizes for every session:
//   RANGE boxes (solid, filled): price stays inside the box for the WHOLE rest of the session.
//       Range 50% = 0.75 x expected range, Range 80% = 1.15 x expected range.
//   CLOSE boxes (dashed, no fill): only the session CLOSE lands inside the box.
//       Close 50% = 0.43 x expected range, Close 80% = 0.85 x expected range.
//   (Tested on 860-950 days per session: boxes held 49-53% / 78-82% of days; single years moved +-5-8 points.)
// News days (Pine cannot read the calendar, so dates are typed in below):
//   US session   : FOMC days ran ~1.7x the forecast -> box x1.7. CPI / jobs: flag only.
//   London session: CPI days ran ~1.8x and jobs days ~1.6x (the 08:30 release lands inside the window).
//   Asia session : no news effect found.
// Use a 15m or 5m chart (needs ~15 sessions of history loaded; 1m-5m charts are best).
// =====================================================================

grpS = 'Which sessions to show'
showA = input.bool(true, 'Asia session (Tokyo 09:00-15:00 = Perth 08:00-14:00)', group = grpS)
showL = input.bool(true, 'London session (03:00-09:30 New York)', group = grpS)
showU = input.bool(true, 'US session (09:30-16:00 New York)', group = grpS)

grpX = 'Which boxes to show'
showR50 = input.bool(true, 'Range 50% box (solid): price stays inside ALL session on ~50% of days', group = grpX)
showC50 = input.bool(true, 'Close 50% box (dashed): the session close lands inside on ~50% of days', group = grpX)
showR80 = input.bool(true, 'Range 80% box (solid, big): price stays inside ALL session on ~80% of days', group = grpX)
showC80 = input.bool(false, 'Close 80% box (dashed): the session close lands inside on ~80% of days', group = grpX)
showTags = input.bool(true, 'Tag each box with its name and size', group = grpX)
showTable = input.bool(true, 'Show info table', group = grpX)

grpB = 'Box sizes and colours'
kR50 = input.float(0.75, 'Range 50% size (x expected range)', group = grpB, step = 0.01)
kC50 = input.float(0.43, 'Close 50% size (x expected range)', group = grpB, step = 0.01)
kR80 = input.float(1.15, 'Range 80% size (x expected range)', group = grpB, step = 0.01)
kC80 = input.float(0.85, 'Close 80% size (x expected range)', group = grpB, step = 0.01)
calmCut = input.float(0.76, 'Calm if expected / 14-session avg below', group = grpB, step = 0.01)
wildCut = input.float(0.95, 'Wild if expected / 14-session avg above', group = grpB, step = 0.01)

grpA_ = 'Asia model weights (fitted on US500 data)'
A_b0 = input.float(0.4456, 'Intercept', group = grpA_, step = 0.01)
A_bAtr = input.float(0.2149, 'Weight: 14-session average range', group = grpA_, step = 0.01)
A_bPrv = input.float(0.1300, 'Weight: previous session range', group = grpA_, step = 0.01)
A_bPre = input.float(0.1594, 'Weight: range of the 6 hours before the open', group = grpA_, step = 0.01)
A_bF = input.float(0.4197, 'Weight: first 30-minute range', group = grpA_, step = 0.01)

grpL_ = 'London model weights (fitted on US500 data)'
L_b0 = input.float(0.7250, 'Intercept', group = grpL_, step = 0.01)
L_bAtr = input.float(0.2829, 'Weight: 14-session average range', group = grpL_, step = 0.01)
L_bPrv = input.float(0.1096, 'Weight: previous session range', group = grpL_, step = 0.01)
L_bPre = input.float(0.2408, 'Weight: range of the 6 hours before the open', group = grpL_, step = 0.01)
L_bF = input.float(0.2749, 'Weight: first 30-minute range', group = grpL_, step = 0.01)

grpU_ = 'US model weights (fitted on US500 data)'
U_b0 = input.float(0.9088, 'Intercept', group = grpU_, step = 0.01)
U_bAtr = input.float(0.2074, 'Weight: 14-session average range', group = grpU_, step = 0.01)
U_bPrv = input.float(0.2020, 'Weight: previous session range', group = grpU_, step = 0.01)
U_bPre = input.float(0.2023, 'Weight: range of the 6 hours before the open', group = grpU_, step = 0.01)
U_bF = input.float(0.2421, 'Weight: first 30-minute range', group = grpU_, step = 0.01)

grpN = 'News days (typed in - Pine cannot read the calendar)'
fomcMult = input.float(1.7, 'US session, FOMC days: box size multiplier', group = grpN, step = 0.05)
cpiMult = input.float(1.8, 'London session, CPI days: box size multiplier', group = grpN, step = 0.05)
nfpMult = input.float(1.6, 'London session, jobs-report days: box size multiplier', group = grpN, step = 0.05)
fomcDates = input.string('2023-02-01,2023-03-22,2023-05-03,2023-06-14,2023-07-26,2023-09-20,2023-11-01,2023-12-13,2024-01-31,2024-03-20,2024-05-01,2024-06-12,2024-07-31,2024-09-18,2024-11-07,2024-12-18,2025-01-29,2025-03-19,2025-05-07,2025-06-18,2025-07-30,2025-09-17,2025-10-29,2025-12-10,2026-01-28,2026-03-18,2026-04-29,2026-06-17,2026-07-29,2026-09-16,2026-10-28,2026-12-09', 'FOMC decision dates (YYYY-MM-DD, comma separated)', group = grpN)
cpiDates = input.string('2023-01-12,2023-02-14,2023-03-14,2023-04-12,2023-05-10,2023-06-13,2023-07-12,2023-08-10,2023-09-13,2023-10-12,2023-11-14,2023-12-12,2024-01-11,2024-02-13,2024-03-12,2024-04-10,2024-05-15,2024-06-12,2024-07-11,2024-08-14,2024-09-11,2024-10-10,2024-11-13,2024-12-11,2025-01-15,2025-02-12,2025-03-12,2025-04-10,2025-05-13,2025-06-11,2025-07-15,2025-08-12,2025-09-11,2025-10-24,2025-12-18,2026-01-13,2026-02-13,2026-03-11,2026-04-10,2026-05-12,2026-06-10,2026-07-14,2026-08-12,2026-09-11,2026-10-14,2026-11-10,2026-12-10', 'CPI release dates', group = grpN)
nfpDates = input.string('2023-01-06,2023-02-03,2023-03-10,2023-04-07,2023-05-05,2023-06-02,2023-07-07,2023-08-04,2023-09-01,2023-10-06,2023-11-03,2023-12-08,2024-01-05,2024-02-02,2024-03-08,2024-04-05,2024-05-03,2024-06-07,2024-07-05,2024-08-02,2024-09-06,2024-10-04,2024-11-01,2024-12-06,2025-01-10,2025-02-07,2025-03-07,2025-04-04,2025-05-02,2025-06-06,2025-07-03,2025-08-01,2025-09-05,2025-11-20,2025-12-16,2026-01-09,2026-02-11,2026-03-06,2026-04-03,2026-05-08,2026-06-05,2026-07-02,2026-08-07,2026-09-04,2026-10-02,2026-11-06,2026-12-04', 'Jobs report dates', group = grpN)

tfMin = timeframe.in_seconds() / 60.0

lnBps(x, base) =>
    math.log(math.max(x, 0.01) / base * 10000)

// draws one box centred on the price 30 minutes after the open; "filled" = range box (solid), otherwise close box (dashed, no fill)
drawBox(k, filled, t0, t1, ctr, hat, col, tag, tagOn) =>
    float up = ctr + k * hat
    float dn = ctr - k * hat
    if filled
        box.new(t0, up, t1, dn, xloc = xloc.bar_time, border_color = color.new(col, 45), border_style = line.style_solid, bgcolor = color.new(col, 90))
    else
        box.new(t0, up, t1, dn, xloc = xloc.bar_time, border_color = color.new(col, 20), border_style = line.style_dashed, bgcolor = color.new(col, 100))
    if tagOn
        label.new(t0, up, tag + ' +/-' + str.tostring(k * hat, '#'), xloc = xloc.bar_time, style = label.style_label_upper_left, color = color.new(col, 85), textcolor = color.white, size = size.tiny)
    true

// ====================================================================
// Asia session
// ====================================================================
A_mod = hour(time, 'Asia/Tokyo') * 60 + minute(time, 'Asia/Tokyo')
A_inS = A_mod >= 540 and A_mod < 900
A_inPre = (A_mod - 180 + 1440) % 1440 < 360
A_sStart = A_inS and not A_inS[1]
A_sEnd = not A_inS and A_inS[1]

var float A_sOpen = na
var float A_sH = na
var float A_sL = na
var float A_preH = na
var float A_preL = na
var float A_preRng = na
var float A_prevRng = na
var float A_fH = na
var float A_fL = na
var float A_fRng = na
var float A_c = na
var int A_cTime = na
var float A_rH = na
var float A_rL = na
var float A_hat = na
var float A_atr = na
var float A_mult = 1.0
var string A_newsTag = 'none'
var bool A_pred = false
var bool A_seen = false
var array<float> A_ranges = array.new_float()
var int A_nbPre = 0
var int A_nbF = 0
var int A_nbT = 0
var bool A_preOk = false

// 6 hours before the open (a gap of more than 2 hours, e.g. the weekend, starts a fresh window)
if A_inPre and (not A_inPre[1] or time - time[1] > 7200000)
    A_preH := high
    A_preL := low
    A_nbPre := 1
    A_nbPre
else if A_inPre
    A_preH := math.max(A_preH, high)
    A_preL := math.min(A_preL, low)
    A_nbPre := A_nbPre + 1
    A_nbPre

// session end: store its full range, but only if the session had enough data (skips holidays and half days)
if A_sEnd
    if not na(A_sH) and A_preOk and A_nbF * tfMin >= 20 and A_nbT * tfMin >= 0.7 * 330
        array.push(A_ranges, A_sH - A_sL)
        A_prevRng := A_sH - A_sL
        A_prevRng

// session start and first 30 minutes
if A_sStart
    A_sOpen := open
    A_sH := high
    A_sL := low
    A_preRng := na(A_preH) ? na : A_preH - A_preL
    A_preOk := A_nbPre * tfMin >= 100
    A_nbPre := 0
    A_preH := na
    A_preL := na
    A_nbF := 1
    A_nbT := 0
    A_fH := high
    A_fL := low
    A_fRng := na
    A_seen := false
    A_pred := false
    A_rH := na
    A_rL := na
    A_rL
else if A_inS
    A_sH := math.max(A_sH, high)
    A_sL := math.min(A_sL, low)
    if A_mod < 570
        A_fH := math.max(A_fH, high)
        A_fL := math.min(A_fL, low)
        A_nbF := A_nbF + 1
        A_nbF
    else
        A_nbT := A_nbT + 1
        A_nbT

// 30 minutes after the open: make the prediction and draw the boxes
A_tenBar = A_inS and A_mod >= 570 and not A_seen and not na(A_sOpen)
if A_tenBar
    A_seen := true
    A_fRng := A_fH - A_fL
    A_c := open
    A_cTime := time
    A_rH := high
    A_rL := low
    if showA and array.size(A_ranges) >= 14 and not na(A_prevRng) and A_preOk and A_nbF * tfMin >= 20 and A_fRng > 0
        A_cnt = array.size(A_ranges)
        float A_sum = 0.0
        for i = A_cnt - 14 to A_cnt - 1 by 1
            A_sum := A_sum + array.get(A_ranges, i)
            A_sum
        A_atr := A_sum / 14
        lnR = A_b0 + A_bAtr * lnBps(A_atr, A_sOpen) + A_bPrv * lnBps(A_prevRng, A_sOpen) + A_bPre * lnBps(A_preRng, A_sOpen) + A_bF * lnBps(A_fRng, A_sOpen)
        mult = 1.0
        A_newsTag := 'none'
        newsLbl = ''
        A_mult := mult
        A_hat := math.exp(lnR) * A_sOpen / 10000 * mult
        A_pred := true
        rho = A_hat / mult / A_atr
        stateTxt = rho < calmCut ? 'calm' : rho > wildCut ? 'wild' : 'normal'
        col = mult > 1.0 ? color.purple : rho < calmCut ? color.blue : rho > wildCut ? color.orange : color.yellow
        endT = A_cTime + 330 * 60 * 1000
        topK = math.max(showR80 ? kR80 : 0.0, showC80 ? kC80 : 0.0, showR50 ? kR50 : 0.0, showC50 ? kC50 : 0.0)
        if showR80
            drawBox(kR80, true, A_cTime, endT, A_c, A_hat, col, 'Asia Range 80%', showTags)
        if showC80
            drawBox(kC80, false, A_cTime, endT, A_c, A_hat, col, 'Asia Close 80%', showTags)
        if showR50
            drawBox(kR50, true, A_cTime, endT, A_c, A_hat, col, 'Asia Range 50%', showTags)
        if showC50
            drawBox(kC50, false, A_cTime, endT, A_c, A_hat, col, 'Asia Close 50%', showTags)
        line.new(A_cTime, A_c, endT, A_c, xloc = xloc.bar_time, color = color.new(col, 20), style = line.style_dotted)
        label.new(A_cTime, A_c + topK * A_hat, 'Asia exp. range ' + str.tostring(A_hat, '#') + ' pts (' + stateTxt + ')' + newsLbl, xloc = xloc.bar_time, style = label.style_label_lower_left, color = color.new(col, 70), textcolor = color.white, size = size.small)
else if A_pred and A_inS
    A_rH := math.max(A_rH, high)
    A_rL := math.min(A_rL, low)
    A_rL

// ====================================================================
// London session
// ====================================================================
L_mod = hour(time, 'America/New_York') * 60 + minute(time, 'America/New_York')
L_inS = L_mod >= 180 and L_mod < 570
L_inPre = (L_mod - 1260 + 1440) % 1440 < 360
L_sStart = L_inS and not L_inS[1]
L_sEnd = not L_inS and L_inS[1]

var float L_sOpen = na
var float L_sH = na
var float L_sL = na
var float L_preH = na
var float L_preL = na
var float L_preRng = na
var float L_prevRng = na
var float L_fH = na
var float L_fL = na
var float L_fRng = na
var float L_c = na
var int L_cTime = na
var float L_rH = na
var float L_rL = na
var float L_hat = na
var float L_atr = na
var float L_mult = 1.0
var string L_newsTag = 'none'
var bool L_pred = false
var bool L_seen = false
var array<float> L_ranges = array.new_float()
var int L_nbPre = 0
var int L_nbF = 0
var int L_nbT = 0
var bool L_preOk = false

// 6 hours before the open (a gap of more than 2 hours, e.g. the weekend, starts a fresh window)
if L_inPre and (not L_inPre[1] or time - time[1] > 7200000)
    L_preH := high
    L_preL := low
    L_nbPre := 1
    L_nbPre
else if L_inPre
    L_preH := math.max(L_preH, high)
    L_preL := math.min(L_preL, low)
    L_nbPre := L_nbPre + 1
    L_nbPre

// session end: store its full range, but only if the session had enough data (skips holidays and half days)
if L_sEnd
    if not na(L_sH) and L_preOk and L_nbF * tfMin >= 20 and L_nbT * tfMin >= 0.7 * 360
        array.push(L_ranges, L_sH - L_sL)
        L_prevRng := L_sH - L_sL
        L_prevRng

// session start and first 30 minutes
if L_sStart
    L_sOpen := open
    L_sH := high
    L_sL := low
    L_preRng := na(L_preH) ? na : L_preH - L_preL
    L_preOk := L_nbPre * tfMin >= 100
    L_nbPre := 0
    L_preH := na
    L_preL := na
    L_nbF := 1
    L_nbT := 0
    L_fH := high
    L_fL := low
    L_fRng := na
    L_seen := false
    L_pred := false
    L_rH := na
    L_rL := na
    L_rL
else if L_inS
    L_sH := math.max(L_sH, high)
    L_sL := math.min(L_sL, low)
    if L_mod < 210
        L_fH := math.max(L_fH, high)
        L_fL := math.min(L_fL, low)
        L_nbF := L_nbF + 1
        L_nbF
    else
        L_nbT := L_nbT + 1
        L_nbT

// 30 minutes after the open: make the prediction and draw the boxes
L_tenBar = L_inS and L_mod >= 210 and not L_seen and not na(L_sOpen)
if L_tenBar
    L_seen := true
    L_fRng := L_fH - L_fL
    L_c := open
    L_cTime := time
    L_rH := high
    L_rL := low
    if showL and array.size(L_ranges) >= 14 and not na(L_prevRng) and L_preOk and L_nbF * tfMin >= 20 and L_fRng > 0
        L_cnt = array.size(L_ranges)
        float L_sum = 0.0
        for i = L_cnt - 14 to L_cnt - 1 by 1
            L_sum := L_sum + array.get(L_ranges, i)
            L_sum
        L_atr := L_sum / 14
        lnR = L_b0 + L_bAtr * lnBps(L_atr, L_sOpen) + L_bPrv * lnBps(L_prevRng, L_sOpen) + L_bPre * lnBps(L_preRng, L_sOpen) + L_bF * lnBps(L_fRng, L_sOpen)
        dStr = str.format_time(L_cTime, 'yyyy-MM-dd', 'America/New_York')
        isCpi = str.contains(cpiDates, dStr)
        isNfp = str.contains(nfpDates, dStr)
        mult = isCpi ? cpiMult : isNfp ? nfpMult : 1.0
        L_newsTag := isCpi ? 'CPI (box x' + str.tostring(cpiMult, '#.##') + ')' : isNfp ? 'Jobs (box x' + str.tostring(nfpMult, '#.##') + ')' : 'none'
        newsLbl = isCpi ? ' | CPI' : isNfp ? ' | Jobs' : ''
        L_mult := mult
        L_hat := math.exp(lnR) * L_sOpen / 10000 * mult
        L_pred := true
        rho = L_hat / mult / L_atr
        stateTxt = rho < calmCut ? 'calm' : rho > wildCut ? 'wild' : 'normal'
        col = mult > 1.0 ? color.purple : rho < calmCut ? color.blue : rho > wildCut ? color.orange : color.yellow
        endT = L_cTime + 360 * 60 * 1000
        topK = math.max(showR80 ? kR80 : 0.0, showC80 ? kC80 : 0.0, showR50 ? kR50 : 0.0, showC50 ? kC50 : 0.0)
        if showR80
            drawBox(kR80, true, L_cTime, endT, L_c, L_hat, col, 'London Range 80%', showTags)
        if showC80
            drawBox(kC80, false, L_cTime, endT, L_c, L_hat, col, 'London Close 80%', showTags)
        if showR50
            drawBox(kR50, true, L_cTime, endT, L_c, L_hat, col, 'London Range 50%', showTags)
        if showC50
            drawBox(kC50, false, L_cTime, endT, L_c, L_hat, col, 'London Close 50%', showTags)
        line.new(L_cTime, L_c, endT, L_c, xloc = xloc.bar_time, color = color.new(col, 20), style = line.style_dotted)
        label.new(L_cTime, L_c + topK * L_hat, 'London exp. range ' + str.tostring(L_hat, '#') + ' pts (' + stateTxt + ')' + newsLbl, xloc = xloc.bar_time, style = label.style_label_lower_left, color = color.new(col, 70), textcolor = color.white, size = size.small)
else if L_pred and L_inS
    L_rH := math.max(L_rH, high)
    L_rL := math.min(L_rL, low)
    L_rL

// ====================================================================
// US session
// ====================================================================
U_mod = hour(time, 'America/New_York') * 60 + minute(time, 'America/New_York')
U_inS = U_mod >= 570 and U_mod < 960
U_inPre = (U_mod - 210 + 1440) % 1440 < 360
U_sStart = U_inS and not U_inS[1]
U_sEnd = not U_inS and U_inS[1]

var float U_sOpen = na
var float U_sH = na
var float U_sL = na
var float U_preH = na
var float U_preL = na
var float U_preRng = na
var float U_prevRng = na
var float U_fH = na
var float U_fL = na
var float U_fRng = na
var float U_c = na
var int U_cTime = na
var float U_rH = na
var float U_rL = na
var float U_hat = na
var float U_atr = na
var float U_mult = 1.0
var string U_newsTag = 'none'
var bool U_pred = false
var bool U_seen = false
var array<float> U_ranges = array.new_float()
var int U_nbPre = 0
var int U_nbF = 0
var int U_nbT = 0
var bool U_preOk = false

// 6 hours before the open (a gap of more than 2 hours, e.g. the weekend, starts a fresh window)
if U_inPre and (not U_inPre[1] or time - time[1] > 7200000)
    U_preH := high
    U_preL := low
    U_nbPre := 1
    U_nbPre
else if U_inPre
    U_preH := math.max(U_preH, high)
    U_preL := math.min(U_preL, low)
    U_nbPre := U_nbPre + 1
    U_nbPre

// session end: store its full range, but only if the session had enough data (skips holidays and half days)
if U_sEnd
    if not na(U_sH) and U_preOk and U_nbF * tfMin >= 20 and U_nbT * tfMin >= 0.7 * 360
        array.push(U_ranges, U_sH - U_sL)
        U_prevRng := U_sH - U_sL
        U_prevRng

// session start and first 30 minutes
if U_sStart
    U_sOpen := open
    U_sH := high
    U_sL := low
    U_preRng := na(U_preH) ? na : U_preH - U_preL
    U_preOk := U_nbPre * tfMin >= 100
    U_nbPre := 0
    U_preH := na
    U_preL := na
    U_nbF := 1
    U_nbT := 0
    U_fH := high
    U_fL := low
    U_fRng := na
    U_seen := false
    U_pred := false
    U_rH := na
    U_rL := na
    U_rL
else if U_inS
    U_sH := math.max(U_sH, high)
    U_sL := math.min(U_sL, low)
    if U_mod < 600
        U_fH := math.max(U_fH, high)
        U_fL := math.min(U_fL, low)
        U_nbF := U_nbF + 1
        U_nbF
    else
        U_nbT := U_nbT + 1
        U_nbT

// 30 minutes after the open: make the prediction and draw the boxes
U_tenBar = U_inS and U_mod >= 600 and not U_seen and not na(U_sOpen)
if U_tenBar
    U_seen := true
    U_fRng := U_fH - U_fL
    U_c := open
    U_cTime := time
    U_rH := high
    U_rL := low
    if showU and array.size(U_ranges) >= 14 and not na(U_prevRng) and U_preOk and U_nbF * tfMin >= 20 and U_fRng > 0
        U_cnt = array.size(U_ranges)
        float U_sum = 0.0
        for i = U_cnt - 14 to U_cnt - 1 by 1
            U_sum := U_sum + array.get(U_ranges, i)
            U_sum
        U_atr := U_sum / 14
        lnR = U_b0 + U_bAtr * lnBps(U_atr, U_sOpen) + U_bPrv * lnBps(U_prevRng, U_sOpen) + U_bPre * lnBps(U_preRng, U_sOpen) + U_bF * lnBps(U_fRng, U_sOpen)
        dStr = str.format_time(U_cTime, 'yyyy-MM-dd', 'America/New_York')
        isFomc = str.contains(fomcDates, dStr)
        isCpi = str.contains(cpiDates, dStr)
        isNfp = str.contains(nfpDates, dStr)
        mult = isFomc ? fomcMult : 1.0
        U_newsTag := isFomc ? 'FOMC (box x' + str.tostring(fomcMult, '#.##') + ')' : isCpi ? 'CPI day (flag only)' : isNfp ? 'Jobs report (flag only)' : 'none'
        newsLbl = isFomc ? ' | FOMC' : isCpi ? ' | CPI' : isNfp ? ' | Jobs' : ''
        U_mult := mult
        U_hat := math.exp(lnR) * U_sOpen / 10000 * mult
        U_pred := true
        rho = U_hat / mult / U_atr
        stateTxt = rho < calmCut ? 'calm' : rho > wildCut ? 'wild' : 'normal'
        col = mult > 1.0 ? color.purple : rho < calmCut ? color.blue : rho > wildCut ? color.orange : color.yellow
        endT = U_cTime + 360 * 60 * 1000
        topK = math.max(showR80 ? kR80 : 0.0, showC80 ? kC80 : 0.0, showR50 ? kR50 : 0.0, showC50 ? kC50 : 0.0)
        if showR80
            drawBox(kR80, true, U_cTime, endT, U_c, U_hat, col, 'US Range 80%', showTags)
        if showC80
            drawBox(kC80, false, U_cTime, endT, U_c, U_hat, col, 'US Close 80%', showTags)
        if showR50
            drawBox(kR50, true, U_cTime, endT, U_c, U_hat, col, 'US Range 50%', showTags)
        if showC50
            drawBox(kC50, false, U_cTime, endT, U_c, U_hat, col, 'US Close 50%', showTags)
        line.new(U_cTime, U_c, endT, U_c, xloc = xloc.bar_time, color = color.new(col, 20), style = line.style_dotted)
        label.new(U_cTime, U_c + topK * U_hat, 'US exp. range ' + str.tostring(U_hat, '#') + ' pts (' + stateTxt + ')' + newsLbl, xloc = xloc.bar_time, style = label.style_label_lower_left, color = color.new(col, 70), textcolor = color.white, size = size.small)
else if U_pred and U_inS
    U_rH := math.max(U_rH, high)
    U_rL := math.min(U_rL, low)
    U_rL

// ---------- info table: one column per session ----------
var table tbl = table.new(position.top_right, 4, 10, bgcolor = color.new(color.black, 25), border_width = 1)
if barstate.islast and showTable
    table.cell(tbl, 0, 0, 'US500 expected range', text_color = color.white, text_size = size.small)
    table.cell(tbl, 1, 0, 'Asia', text_color = color.gray, text_size = size.small)
    table.cell(tbl, 2, 0, 'London', text_color = color.gray, text_size = size.small)
    table.cell(tbl, 3, 0, 'US', text_color = color.gray, text_size = size.small)
    if timeframe.in_seconds() > 1800
        table.cell(tbl, 0, 1, 'Use a 30m or lower chart', text_color = color.red, text_size = size.small)
    else
        table.cell(tbl, 0, 1, 'Expected range', text_color = color.white, text_size = size.small)
        table.cell(tbl, 0, 2, 'News day', text_color = color.white, text_size = size.small)
        table.cell(tbl, 0, 3, 'Range used so far', text_color = color.white, text_size = size.small)
        table.cell(tbl, 1, 1, not showA ? 'off' : not A_pred ? 'waiting' : str.tostring(A_hat, '#.#') + ' pts', text_color = color.white, text_size = size.small)
        table.cell(tbl, 2, 1, not showL ? 'off' : not L_pred ? 'waiting' : str.tostring(L_hat, '#.#') + ' pts', text_color = color.white, text_size = size.small)
        table.cell(tbl, 3, 1, not showU ? 'off' : not U_pred ? 'waiting' : str.tostring(U_hat, '#.#') + ' pts', text_color = color.white, text_size = size.small)
        table.cell(tbl, 1, 2, showA and A_pred ? A_newsTag : '-', text_color = color.white, text_size = size.small)
        table.cell(tbl, 2, 2, showL and L_pred ? L_newsTag : '-', text_color = color.white, text_size = size.small)
        table.cell(tbl, 3, 2, showU and U_pred ? U_newsTag : '-', text_color = color.white, text_size = size.small)
        table.cell(tbl, 1, 3, showA and A_pred ? A_inS ? str.tostring((A_rH - A_rL) / A_hat * 100, '#') + '%' : 'finished' : '-', text_color = color.white, text_size = size.small)
        table.cell(tbl, 2, 3, showL and L_pred ? L_inS ? str.tostring((L_rH - L_rL) / L_hat * 100, '#') + '%' : 'finished' : '-', text_color = color.white, text_size = size.small)
        table.cell(tbl, 3, 3, showU and U_pred ? U_inS ? str.tostring((U_rH - U_rL) / U_hat * 100, '#') + '%' : 'finished' : '-', text_color = color.white, text_size = size.small)
        int r = 4
        if showC50
            table.cell(tbl, 0, r, 'Close 50% (+/-)', text_color = color.white, text_size = size.small)
            table.cell(tbl, 1, r, showA and A_pred ? str.tostring(kC50 * A_hat, '#.#') : '-', text_color = color.white, text_size = size.small)
            table.cell(tbl, 2, r, showL and L_pred ? str.tostring(kC50 * L_hat, '#.#') : '-', text_color = color.white, text_size = size.small)
            table.cell(tbl, 3, r, showU and U_pred ? str.tostring(kC50 * U_hat, '#.#') : '-', text_color = color.white, text_size = size.small)
            r := r + 1
            r
        if showR50
            table.cell(tbl, 0, r, 'Range 50% (+/-)', text_color = color.white, text_size = size.small)
            table.cell(tbl, 1, r, showA and A_pred ? str.tostring(kR50 * A_hat, '#.#') : '-', text_color = color.white, text_size = size.small)
            table.cell(tbl, 2, r, showL and L_pred ? str.tostring(kR50 * L_hat, '#.#') : '-', text_color = color.white, text_size = size.small)
            table.cell(tbl, 3, r, showU and U_pred ? str.tostring(kR50 * U_hat, '#.#') : '-', text_color = color.white, text_size = size.small)
            r := r + 1
            r
        if showC80
            table.cell(tbl, 0, r, 'Close 80% (+/-)', text_color = color.white, text_size = size.small)
            table.cell(tbl, 1, r, showA and A_pred ? str.tostring(kC80 * A_hat, '#.#') : '-', text_color = color.white, text_size = size.small)
            table.cell(tbl, 2, r, showL and L_pred ? str.tostring(kC80 * L_hat, '#.#') : '-', text_color = color.white, text_size = size.small)
            table.cell(tbl, 3, r, showU and U_pred ? str.tostring(kC80 * U_hat, '#.#') : '-', text_color = color.white, text_size = size.small)
            r := r + 1
            r
        if showR80
            table.cell(tbl, 0, r, 'Range 80% (+/-)', text_color = color.white, text_size = size.small)
            table.cell(tbl, 1, r, showA and A_pred ? str.tostring(kR80 * A_hat, '#.#') : '-', text_color = color.white, text_size = size.small)
            table.cell(tbl, 2, r, showL and L_pred ? str.tostring(kR80 * L_hat, '#.#') : '-', text_color = color.white, text_size = size.small)
            table.cell(tbl, 3, r, showU and U_pred ? str.tostring(kR80 * U_hat, '#.#') : '-', text_color = color.white, text_size = size.small)
            r := r + 1
            r
        table.cell(tbl, 0, r, 'News dates typed in to', text_color = color.gray, text_size = size.small)
        table.cell(tbl, 1, r, 'Dec 2026', text_color = color.gray, text_size = size.small)
````
