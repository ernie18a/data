# Svopex FVG

- url: https://www.tradingview.com/script/8sqZRgHO-Svopex-FVG/
- type: indicator
- pine_id: PUB;9c871f4acdee48189af7c4d848068e47
- version: 1.0

## Description

Svopex FVG — multi-timeframe Fair Value Gaps with flexible mitigation                                                                                                  
                                                         
  Detects and plots Fair Value Gaps (3-candle price imbalances) from any timeframe you choose, with full control over when a gap is considered "closed". Built on        
  @twingall's original FVG indicator (MPL 2.0), extended for higher-timeframe detection and more granular fill logic.
                                                                                                                                                                         
  How FVGs are detected                                                                                                                                                  
                                                                                                                                                                         
  A bullish (Up) FVG forms when high[3] < low[1] — i.e. candle −3's high is below candle −1's low, leaving an unfilled gap between them. A bearish (Down) FVG is the     
  mirror case: low[3] > high[1]. Detection happens on the Zone timeframe you pick, not the chart timeframe, so you can view HTF gaps while trading a lower timeframe.    
  Detection is non-repainting — only closed HTF candles are used (via request.security with lookahead_off and a 1-bar shift).                                            
                                                         
  Zone timeframe

  Two ways to control which timeframe drives detection. Either set the Zone timeframe explicitly (default 1H), or flip the "Use chart timeframe" toggle — when on, the   
  indicator automatically follows the chart's current timeframe, so switching your chart from 1H to 15M also switches the displayed FVGs. The Zone timeframe input is
  ignored while the toggle is on, but stays available as a fallback.                                                                                                     
                                                         
  Fill threshold

  Controls when a gap stops extending to the right. A single slider (0–100%) replaces the older "Use CE vs Full Fill" toggle. Set it to 100 and the FVG remains active   
  until price fully closes the gap. Set it to 50 and it closes at the midline (equivalent to a CE / Consequent Encroachment touch). Set it to 0 and any penetration of
  the gap's near edge counts as a hit. Any value in between works — e.g. 70 means the FVG ends when price has filled 70% of its height.                                  
                                                         
  Include wick                                                                                                                                                           
   
  Decides what price data drives the fill check. When off (default, body-only), the gap only closes if the candle's body (max/min of open/close) crosses the threshold — 
  intrabar wicks are ignored. When on, wicks count too (strict mode): a long shadow through the gap is enough to close it.
                                                                                                                                                                         
  Visuals                                                

  Up FVGs render in green, Down FVGs in red, both at 80% transparency by default — matching the Svopex Supply & Demand Zones indicator for visual consistency if you use 
  both. Colors are user-configurable. Optional "delete filled boxes" fully hides mitigated gaps instead of just freezing them. A lookback (in days) controls how far back
   fresh FVGs are allowed to be drawn.                                                                                                                                   
                                                         
  Alerts

  Six alert conditions are exposed. "ABOVE/BELOW threshold" fires when price crosses the fill threshold of the latest active FVG in each direction — useful for CE       
  rejections or full-fill confirmations. "IOFED into latest active Up/Down FVG" fires when price first enters the gap at its near edge, regardless of the fill threshold
  setting. "Simple alert: Up/Down FVG (confirmed)" fires the moment a fresh FVG forms on the chosen HTF.                                                                 
                                                         
  Settings summary

  Lookback in days, Use chart timeframe toggle, Zone timeframe (default 60), Up/Down FVG visibility and colors, Delete filled boxes, Fill threshold percent (default 50),
   Include wick.
                                                                                                                                                                         
  Based on the original FVG indicator by @twingall (MPL 2.0). Extensions by Petr Svoboda: removed legacy CE display, replaced the CE-vs-Full-Fill toggle with a          
  continuous fill percent, added HTF detection via request.security, added the chart-TF auto-follow toggle, aligned default colors with Svopex Supply & Demand Zones.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//FVG indicator: Paints FVGs from Zone timeframe (or chart TF). Non-repainting HTF detection via request.security.
//Big thank you to @Bjorgum for his fantastic extendAndRemove method.
//29th June'23 added IOFED alerts (price merely enters FVG above or below)
//5th Nov'23 added simple 'FVG confirmed' alerts
//14th Dec'23 added simple alerts for UN-Confirmed FVGs too
//19th Apr'26 v10: removed CE display + CE-vs-FullFill toggle, replaced with Fill threshold (%) slider
//19th Apr'26 v11: flipped body/wick toggle to "Include wick"; default colors aligned with Svopex S&D
//19th Apr'26 v12: added "Zone timeframe" — FVG detection runs on chosen HTF via request.security, non-repainting ([1]-shifted)
//19th Apr'26 v13: added "Use chart timeframe" toggle — when ON, FVG detection follows chart TF (switching chart TF switches FVG TF)
// © twingall

//@version=5
indicator("Svopex FVG", overlay = true, max_boxes_count = 5000)
numDays = input.int(7, "number of days lookback")
useChartTF = input.bool(false, "Use chart timeframe", group="Zone timeframe", tooltip="ON = FVG detection follows chart TF (switch chart TF → switches FVG TF). OFF = use the 'Zone timeframe' setting below.")
htf = input.timeframe("60", "Zone timeframe", group="Zone timeframe", tooltip="Timeframe used for FVG detection. Ignored when 'Use chart timeframe' is ON. Example: on 15M chart with Zone TF=60, 1H FVGs are displayed.")
showUP = input.bool(true, "'UP' FVGs:", inline='1')
colUp = input.color(color.new(color.green, 80), "", inline='1')
showDN = input.bool(true, "'DOWN' FVGs:", inline='2')
colDn = input.color(color.new(color.red, 80), "", inline='2')
deleteFilledBoxes = input.bool(false, "delete filled boxes")
fillPct = input.int(50, "Fill threshold (%)", minval=0, maxval=100, group='conditions', tooltip="FVG ends when price fills it by this % of its height. 100 = full fill, 50 = midline (CE equivalent), 0 = any touch. Threshold used for 'threshold' alerts (does NOT affect IOFED alerts).")
useWicks = input.bool(false, "Include wick", group='conditions', tooltip="ON = use candle highs/lows (wicks) for penetration check. OFF = use body extremes (max/min of open/close).")

effectiveTf = useChartTF ? timeframe.period : htf

colorNone = color.new(color.white, 100)
_day = 24*3600*1000
var array<box> bxUpArr = array.new<box>(0)
var array<box> bxDnArr = array.new<box>(0)

// HTF FVG detection: sig 0=none, 1=Up, 2=Down. tp/bt = gap top/bottom. t0 = time of leftmost candle (bar[-3]).
f_detect() =>
    bool isUp = high[3] < low[1]
    bool isDn = low[3] > high[1]
    int sig = isUp ? 1 : (isDn ? 2 : 0)
    float tp = isUp ? low[1] : (isDn ? low[3] : na)
    float bt = isUp ? high[3] : (isDn ? high[1] : na)
    int t0 = (isUp or isDn) ? time[3] : na
    [sig, tp, bt, t0]

// [1]-shift on HTF bars so we only act on closed HTF candles (non-repainting).
f_detect_prev() =>
    [s, tp, bt, t0] = f_detect()
    [s[1], tp[1], bt[1], t0[1]]

[htfSig, htfTop, htfBot, htfTime0] = request.security(syminfo.tickerid, effectiveTf, f_detect_prev(), lookahead=barmerge.lookahead_off)

freshSig = htfSig != 0 and not na(htfTime0) and nz(htfTime0, 0) != nz(htfTime0[1], 0) and time > timenow - numDays*_day

if freshSig and htfSig == 2 and showDN
    bxDnArr.push(box.new(htfTime0, htfTop, time, htfBot, bgcolor=colDn, border_color=colorNone, xloc=xloc.bar_time))
if freshSig and htfSig == 1 and showUP
    bxUpArr.push(box.new(htfTime0, htfTop, time, htfBot, bgcolor=colUp, border_color=colorNone, xloc=xloc.bar_time))

var array<int> _countArr = array.new<int>(0)
var array<int> _countArrIOFED = array.new<int>(0)

    //modified form of @Bjorgum's looping function. Stops boxes painting when price passes user-defined fill threshold
extendAndRemoveBx(array<box> boxArray, array<int> countArr1, array<int> countArr2, simple bool isBull, int maxSize) =>
    if boxArray.size() > 0
        for i = boxArray.size() -1 to 0
            box bx = boxArray.get(i)
            bx.set_right(time)
            float top = bx.get_top()
            float bot = bx.get_bottom()
            float hgt = top - bot
            float pct = fillPct / 100.0
            float price = isBull ? (bot + hgt * pct) : (top - hgt * pct)
            float price_IOFED = isBull ? bot : top
            int m = isBull ? 1 : -1
            float hiLo = isBull ? (useWicks ? high : math.max(open, close)) : (useWicks ? low : math.min(open, close))
            if hiLo * m > price * m
                boxArray.remove(i)
                countArr1.push(isBull?1:-1)
                if deleteFilledBoxes
                    bx.set_bgcolor(colorNone)
            if hiLo * m > price_IOFED * m
                countArr2.push(isBull?1:-1)

    if boxArray.size() > maxSize
        box.delete(boxArray.shift())

extendAndRemoveBx(bxDnArr, _countArr, _countArrIOFED, true, 12)
extendAndRemoveBx(bxUpArr, _countArr, _countArrIOFED, false, 12)

upThresholdLst = array.sum(_countArr) > array.sum(_countArr)[1]
dnThresholdLst = array.sum(_countArr) < array.sum(_countArr)[1]
upIOFEDlast = array.sum(_countArrIOFED) > array.sum(_countArrIOFED)[1]
dnIOFEDlast = array.sum(_countArrIOFED) < array.sum(_countArrIOFED)[1]

alertcondition(upThresholdLst, "ABOVE threshold of latest active Up FVG", "price has crossed fill threshold of latest active Up FVG")
alertcondition(dnThresholdLst, "BELOW threshold of latest active Down FVG", "price has crossed fill threshold of latest active Down FVG")

alertcondition(upIOFEDlast, "IOFED into latest active Up FVG", "price has entered latest active UP FVG")
alertcondition(dnIOFEDlast, "IOFED into latest active Down FVG", "price has entered latest active Down FVG")

alertcondition(freshSig and htfSig == 2, "Simple alert: Down FVG (confirmed)", "Down FVG has formed on HTF (confirmed)")
alertcondition(freshSig and htfSig == 1, "Simple alert: Up FVG (confirmed)", "Up FVG has formed on HTF (confirmed)")
````
