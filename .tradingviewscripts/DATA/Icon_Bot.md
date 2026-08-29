<!-- tradingview-pine-id: PUB;fb4fc79c7ad247a8b7923065fcabbe0c -->
<!-- tradingviewscripts-format: 1 -->
# Icon Bot⚡

Source: https://www.tradingview.com/script/SGjdTzTm-Icon-Bot/

## Description

Changing privacy settingsThe Icon Bot⚡ is your automated trade-tracking companion built for killzone-based execution. It watches your session windows around the clock, tags entries the moment your setups trigger — complete with signed contract sizing based on your own risk-per-trade — and never lets a trade close without a verdict: Take Profit or Stop Loss, clearly marked, every time.

Under the hood, it's built to scale with you. Risk, reward ratio, stop distance, and position sizing are all fully adjustable and automatically recalculate for whatever instrument you're trading — jump from MNQ to Gold and your risk math stays exact, no manual re-tuning. A live multi-timeframe trend dashboard keeps you oriented across six timeframes at a glance, while a customizable session map highlights your active killzones in real time.

Every visual — entry badges, exit markers, borders, backgrounds, text — is yours to style, so the chart looks the way you want it to, not the way it shipped. And when you're ready to go hands-off, the bot speaks fluent webhook: structured alerts fire the instant a trade is confirmed, ready to plug straight into your automation stack.

Built to watch the clock, track the trade, and call the outcome — so you don't have to babysit the chart to know how you did.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("Icon Bot⚡", "Icon Bot⚡", true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 500)
disp = display.all - display.status_line
kzGR = "Killzones"
asSH = input(true, "", inline = "asia", group = kzGR)
asST = input.string("Asian", "", inline = "asia", group = kzGR, display = disp)
asS = input.session("2000-0000", "", inline = "asia", group = kzGR, display = disp)
asC = input.color(color.new(#e91e63, 90), "", inline = "asia", group = kzGR)
ldnOSH = input(true, "", inline = "ldno", group = kzGR)
ldnOST = input.string("London", "", inline = "ldno", group = kzGR, display = disp)
ldnOS = input.session("0200-0500", "", inline = "ldno", group = kzGR, display = disp)
ldnOC = input.color(color.new(#00bcd4, 90), "", inline = "ldno", group = kzGR)
nySH = input(true, "", inline = "nyam", group = kzGR)
nyST = input.string("New York AM", "", inline = "nyam", group = kzGR, display = disp)
nyS = input.session("0830-1100", "", inline = "nyam", group = kzGR, display = disp)
nyC = input.color(color.new(#ff5d00, 90), "", inline = "nyam", group = kzGR)
ldnCSH = input(true, "", inline = "nypm", group = kzGR)
ldnCST = input.string("New York PM", "", inline = "nypm", group = kzGR, display = disp)
ldnCS = input.session("1330-1600", "", inline = "nypm", group = kzGR, display = disp)
ldnCC = input.color(color.new(#2157f3, 90), "", inline = "nypm", group = kzGR)
kzMML = input(true, "Killzone Lines : Top/Bottom", inline = "LN", group = kzGR)
kzML = input(false, "Mean", inline = "LN", group = kzGR)
kzLE = input(true, "Extend Top/Bottom", inline = "LN", group = kzGR)
kzLB = input(true, "Killzone Labels", group = kzGR)
kzSH = input.int(15, "Display Killzones within Timeframes Up To", options = [1, 3, 5, 15, 30, 45, 60], group = kzGR, display = disp)
dwmO = input.string("None", "Open Price of", options = ["Killzones", "the Day", "the Week", "the Month", "None"], inline = "OP", group = kzGR, display = disp)
dwmS = input.bool(true, "Separator", inline = "OP", group = kzGR)
dwmC = input(color.new(color.gray, 89), "", inline = "OP", group = kzGR)
dwmL = input.bool(true, "Label", inline = "OP", group = kzGR)
obbGR = "Order Blocks & Breaker Blocks"
obSH = input.bool(true, "Order Blocks | Breaker Blocks", inline = "OB", group = obbGR)
bbSH = input.bool(false, "", inline = "OB", group = obbGR)
obbLN = input.int(5, "Swing Detection Length", minval = 3, group = obbGR, display = disp)
obbMT = input.string("Closing Price", "Mitigation Price", options = ["Closing Price", "Wick"], group = obbGR, display = disp)
obbMP = obbMT == "Closing Price"
useBody = input(false, "Use Candle Body in Detection", group = obbGR)
obbR = input.bool(true, "Remove Mitigated Order Blocks & Breaker Blocks", group = obbGR)
extTT = "In this context, \"extend\" refers to the action of projecting or elongating the visual objects beyond the boundaries of the killzones."
obbEX = input.bool(true, "Extend Order Blocks & Breaker Blocks", group = obbGR, tooltip = extTT)
obbSH = input.string("First", "Display Order Blocks & Breaker Blocks", options = ["All", "First", "Last"], group = obbGR, display = disp)
bullOC = input(color.new(#2157f3, 80), "Order Blocks  : Bullish", inline = "OBC", group = obbGR)
bearOC = input(color.new(#ff5d00, 80), "Bearish", inline = "OBC", group = obbGR)
obBullBorderC = input.color(#2157f3, "Bullish Outline", inline = "OBL", group = obbGR)
obBearBorderC = input.color(#ff5d00, "Bearish Outline", inline = "OBL", group = obbGR)
obBorderW = input.int(1, "Outline Weight", minval = 1, maxval = 4, inline = "OBL", group = obbGR, display = disp)
bullBC = input(color.new(#ff1100, 80), "Breaker Blocks : Bullish", inline = "BBC", group = obbGR)
bearBC = input(color.new(#0cb51a, 80), "Bearish", inline = "BBC", group = obbGR)
obbTX = input.bool(true, "Show Order Blocks & Breaker Blocks Text", group = obbGR)
obSigSH = input.bool(true, "Show Buy/Sell Signals", group = obbGR, tooltip = "Shows BUY at the beginning of visible bullish Order Blocks and SELL at the beginning of visible bearish Order Blocks. Breaker Blocks do not generate signals.")
obBuyC = input.color(#089981, "Buy", inline = "OBS", group = obbGR)
obSellC = input.color(#f23645, "Sell", inline = "OBS", group = obbGR)

rrGR = "Risk / Reward Visuals"
rrSH = input.bool(true, "Show Risk / Reward Visuals", group = rrGR, tooltip = "Draws the entry, stop-loss and take-profit areas for visible Order Blocks. The stop is placed at the outer edge of the Order Block.")
rrRatio = input.float(2.0, "Risk / Reward Ratio", minval = 0.1, step = 0.1, group = rrGR, display = disp, tooltip = "Sets the take-profit distance as a multiple of the Order Block risk.")
slSizePoints = input.float(10.0, "Stop Loss Size (Points)", minval = 0.0, step = 0.1, group = rrGR, display = disp, tooltip = "Sets the stop-loss distance in price points from the entry line. The stop is placed below bullish Order Blocks and above bearish Order Blocks.")
riskPerTrade = input.float(100.0, "Risk per Trade ($)", minval = 0.0, step = 1.0, group = rrGR, display = disp, tooltip = "Dollar amount allocated to the risk area for each displayed Order Block. Contract quantity is calculated using this instrument's actual point value (syminfo.pointvalue), so switching symbols keeps risk and R:R accurate automatically.")
rrDays = input.int(5, "Show Risk / Reward Visuals for Last (Days)", minval = 0, group = rrGR, display = disp, tooltip = "Only Order Blocks formed within this many days show Risk/Reward boxes, to save chart space. Set to 0 to show Risk/Reward on all visible Order Blocks regardless of age.")
rrRiskC = input.color(color.new(#f23645, 78), "Risk Area", inline = "RRC", group = rrGR)
rrRewardC = input.color(color.new(#089981, 78), "Reward Area", inline = "RRC", group = rrGR)
rrEntryC = input.color(#5b9cf6, "Entry", inline = "RRL", group = rrGR)
rrStopC = input.color(#f23645, "Stop", inline = "RRL", group = rrGR)
rrTargetC = input.color(#089981, "Target", inline = "RRL", group = rrGR)
bool rrTX = false

teGR = "Trade Execution Labels"
teSH = input.bool(true, "Show Exit Execution Labels (SL/TP)", group = teGR, tooltip = "Displays SL HIT / TP HIT for trades whose Order Block actually printed and kept a visible BUY/SELL signal. No entry marker is drawn - it would overlap the BUY/SELL signal label.")
teDays = input.int(10, "Show Trade Labels for Last (Days)", minval = 1, group = teGR, tooltip = "Only trades entered within this many days are labeled.")
teOnePerDirection = input.bool(true, "Limit to One Active Trade per Direction", group = teGR, tooltip = "While a bullish (or bearish) trade is still open, new signals in that same direction are tracked for the Order Block drawing but skipped for labeling.")
teOneLabelPerSession = input.bool(true, "Limit to One Label per Killzone Session (Each Direction)", group = teGR, tooltip = "Only one buy label and one sell label can be created per killzone occurrence (e.g. one NYAM session), even if the previous trade in that direction already closed. This is the strongest lever if you're seeing multiple markers in the same session.")
teMinGapBars = input.int(5, "Minimum Bars Between New Trade Labels (Same Direction)", minval = 0, group = teGR, tooltip = "A new trade in the same direction won't be eligible for labeling until at least this many bars have passed since the last one was created.")
teLabelOffset = input.int(3, "Label Horizontal Offset (Bars)", minval = 0, group = teGR, tooltip = "Shifts exit labels this many bars to the right of the triggering candle so they don't sit on top of price action.")
teSize = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal"], group = teGR, display = disp)
teSLC = input.color(#f23645, "Stop Loss Background", inline = "TEC1", group = teGR)
teSLTextC = input.color(color.white, "Text", inline = "TEC1", group = teGR)
teTPC = input.color(#089981, "Take Profit Background", inline = "TEC2", group = teGR)
teTPTextC = input.color(color.white, "Text", inline = "TEC2", group = teGR)
teLblSize = teSize == "Tiny" ? size.tiny : teSize == "Normal" ? size.normal : size.small

autoGR = "Automation (Ghost / QuantCrawler Webhooks)"
autoWebhooksOn = input.bool(false, "Enable Ghost Webhook JSON Alerts", group = autoGR, tooltip = "When on, entry and exit alert() calls send JSON payloads formatted for Ghost's webhook (https://quantcrawler.com/api/ghost/webhook/<ticker-id>?secret=<your-secret>). Entries only fire once a trade has passed ALL throttles below and is genuinely being tracked - never on a raw unthrottled signal. Exits only fire on mitigation-cancellation; real SL/TP hits are left to Ghost's own broker-side bracket order, which you configure with the sl/tp sent at entry. Daily loss/profit limits are managed in Ghost's own GhostGuard dashboard, not this script.")

f_isoTime() =>
    str.format_time(time, "yyyy-MM-dd'T'HH:mm:ss'Z'", "UTC")

dashGR = "Trend Dashboard"
dashSH = input.bool(true, "Show Trend Dashboard", group = dashGR)
dashSize = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = dashGR, display = disp)
dashPos = input.string("Top Right", "Dashboard Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = dashGR)
dashHeaderC = input.color(#5b9cf6, "Header Background", inline = "DASHC", group = dashGR)
dashBgC = input.color(color.new(color.gray, 85), "Dashboard Background", inline = "DASHC", group = dashGR)
dashBorderC = input.color(color.new(color.gray, 35), "Border", inline = "DASHC", group = dashGR)
dashTextC = input.color(color.white, "Text", inline = "DASHC", group = dashGR)
dashBullC = input.color(#089981, "Bullish", inline = "DASHC2", group = dashGR)
dashBearC = input.color(#f23645, "Bearish", inline = "DASHC2", group = dashGR)
dashEmaLen = input.int(20, "Trend EMA Length", minval = 1, group = dashGR, display = disp, tooltip = "Trend is Bullish when that timeframe's close is above this EMA, Bearish when below.")
dashTf1 = input.timeframe("1", "Slot 1 Timeframe", group = dashGR)
dashTf2 = input.timeframe("5", "Slot 2 Timeframe", group = dashGR)
dashTf3 = input.timeframe("15", "Slot 3 Timeframe", group = dashGR)
dashTf4 = input.timeframe("60", "Slot 4 Timeframe", group = dashGR)
dashTf5 = input.timeframe("240", "Slot 5 Timeframe", group = dashGR)
dashTf6 = input.timeframe("D", "Slot 6 Timeframe", group = dashGR)
dashTextSize = dashSize == "Tiny" ? size.tiny : dashSize == "Small" ? size.small : dashSize == "Large" ? size.large : size.normal

f_trendCalc(_tf) =>
    [c, e] = request.security(syminfo.tickerid, _tf, [close, ta.ema(close, dashEmaLen)], lookahead = barmerge.lookahead_off)
    c > e ? "Bullish" : "Bearish"

trend1 = f_trendCalc(dashTf1)
trend2 = f_trendCalc(dashTf2)
trend3 = f_trendCalc(dashTf3)
trend4 = f_trendCalc(dashTf4)
trend5 = f_trendCalc(dashTf5)
trend6 = f_trendCalc(dashTf6)

mssGR = "Market Structure Shifts"
mssSH = input.bool(false, "Market Structure Shifts", group = mssGR)
mssLN = input.int(7, "Detection Length", minval = 1, group = mssGR, display = disp)
mssDO = input.string("First", "Display Market Structure Shifts", options = ["All", "First", "Last"], group = mssGR, display = disp)
ppLCB = input.color(color.new(color.teal, 0), "Market Structure Shifts : Bullish", inline = "MSS", group = mssGR)
ppLCS = input.color(color.new(color.red, 0), "Bearish", inline = "MSS", group = mssGR)
mssTX = input.bool(true, "Show Market Structure Shifts Text", group = mssGR)
fvgGR = "Fair Value Gaps"
fvgSH = input.bool(true, "Fair Value Gaps", group = fvgGR)
fvgTT = "The script showcases fair value gaps that exceed a predetermined length calculated by multiplying the fixed-average true range (ATR) value by the option's value.\n\n" + "The option value set to 0 means no filtering is applied.\n\n" + "Remark: No filtering will be implemented for the initial 144 candles based on the fixed-length ATR, as the ATR value won't be available during this period."
fvgTH = input.float(1.2, "Fair Value Gap Width Filter", minval = 0, step = 0.1, tooltip = fvgTT, group = fvgGR, display = disp)
fvgR = input.bool(true, "Remove Mitigated Fair Value Gaps", group = fvgGR)
fvgE = input.bool(true, "Extend Fair Value Gaps", group = fvgGR, tooltip = extTT)
fvgDO = input.string("First", "Display Fair Value Gaps", options = ["All", "First", "Last"], group = fvgGR, display = disp)
fvgBC = input.color(color.new(#4caf50, 80), "Bullish Imbalance", group = fvgGR)
fvgSC = input.color(color.new(color.red, 80), "Bearish Imbalance", group = fvgGR)
fvgTX = input.bool(true, "Show Fair Value Gaps Text", group = fvgGR)

type bar
    float o = open
    float h = high
    float l = low
    float c = close
    int t = time
    int i = bar_index
type OB
    float top = na
    float btm = na
    int obI = bar_index
    box bxOB
    bool ext = true
    bool hasSignal = false
    label sig = na
    box rrRisk = na
    box rrReward = na
    line rrEntry = na
    line rrStop = na
    line rrTarget = na
type BB
    box bxOB
    box bxBB
    bool ext = true
    bool bb = false
    int bbI = na
    int lst = na
type swing
    float y = na
    int i = na
    bool x = false
type pivotPoint
    float h
    int hi
    bool hx
    float l
    int li
    bool lx
type KZ
    line lnT
    line lnM
    line lnB
    line lnO
    label lb
    label lbO
type DWM
    line ln
    label lb
type MSS
    line ln
    box bx
type FVG
    box bx
    bool e
type Trade
    bool isBull
    float entry
    float stop
    float target
    int entryTime
    int obI = na
    int qty = na
    bool hasSignal = false
    int entryBar = na
    int tradeId = na

bar b = bar.new()
tfM = timeframe.multiplier
nyam = not na(time(timeframe.period, nyS, "UTC-5")) and nySH and tfM <= kzSH
ldnO = not na(time(timeframe.period, ldnOS, "UTC-5")) and ldnOSH and tfM <= kzSH
ldnC = not na(time(timeframe.period, ldnCS, "UTC-5")) and ldnCSH and tfM <= kzSH
asian = not na(time(timeframe.period, asS, "UTC-5")) and asSH and tfM <= kzSH
inKZ = nyam or ldnO or ldnC or asian
var int kzSessionId = 0
if inKZ and not inKZ[1]
    kzSessionId += 1
var KZ kz = KZ.new()
var DWM dwm = DWM.new()
var bOB = array.new<OB>(0)
var aOB = array.new<OB>(0)
var bBB = array.new<BB>(0)
var aBB = array.new<BB>(0)
var bLS = array.new_int()
var aLS = array.new_int()
var bMSS = array.new<MSS>(0)
var aMSS = array.new<MSS>(0)
var pivotPoint pp = pivotPoint.new()
var shift = 0
var bFVG = array.new<FVG>(0)
var aFVG = array.new<FVG>(0)
var array<Trade> openTrades = array.new<Trade>(0)
// Permanent OB IDs prevent the same signaled Order Block from creating more
// than one tracked trade, even if its signal is recalculated more than once.
var array<int> tradeObIds = array.new_int()
// Completed-trade registries are permanent for the lifetime of the script.
// They are independent of the visual OB arrays and survive OB reconstruction.
var array<int> completedTradeIds = array.new_int()
var array<int> completedObIds = array.new_int()
var int nextTradeId = 0
var int lastBuyLabelBar = na
var int lastSellLabelBar = na
var int lastBuySessionId = na
var int lastSellSessionId = na
fvgATR = nz(ta.atr(144)) * fvgTH

swings(_l) =>
    var os = 0
    var swing top = swing.new(na, na)
    var swing btm = swing.new(na, na)
    upper = ta.highest(_l)
    lower = ta.lowest(_l)
    os := high[_l] > upper ? 0 : low[_l] < lower ? 1 : os
    if os == 0 and os[1] != 0
        top := swing.new(high[_l], bar_index[_l])
    if os == 1 and os[1] != 1
        btm := swing.new(low[_l], bar_index[_l])
    [top, btm]

method killzones(KZ _id, _s, _kz, _o, _h, _l, _c, _t, _cr, _tx, _mml, _ml, _lb, _le, _ol, _olC, _olL, areaCss) =>
    var float max = na
    var float mid = na
    var float min = na
    var int sbT = na
    var bool xt = false
    var bool xb = false
    var box area = na
    var tC = color.rgb(color.r(_cr), color.g(_cr), color.b(_cr))
    if _s and not _s[1]
        max := _h
        sbT := _t
        min := _l
        mid := math.avg(max, min)
        area := box.new(bar_index, max, bar_index, min, na, bgcolor = areaCss)
        if _mml
            _id.lnT := line.new(sbT, max, sbT, max, xloc.bar_time, color = tC)
            _id.lnB := line.new(sbT, min, sbT, min, xloc.bar_time, color = tC)
        if _ml
            _id.lnM := line.new(sbT, mid, sbT, mid, xloc.bar_time, color = tC, style = line.style_dotted)
        if _ol
            _id.lnO := line.new(sbT, _o, sbT, _o, xloc.bar_time, color = color.new(_olC, 0), style = line.style_dotted)
            if _olL
                _id.lbO := label.new(sbT, _o, "KZO(" + str.tostring(_o, format.mintick) + ")", xloc.bar_time, color = color(na), style = label.style_label_left, textcolor = color.new(_olC, 0), size = size.tiny)
        if _lb
            _id.lb := label.new(sbT, max, _tx, xloc.bar_time, color = #ffffff00, style = label.style_label_down, textcolor = tC, size = size.small)
    if _s
        max := math.max(_h, max)
        min := math.min(_l, min)
        mid := math.avg(max, min)
        xt := true
        xb := true
        area.set_top(max)
        area.set_rightbottom(bar_index, min)
        if _lb
            label.set_x(_id.lb, int(math.avg(_t, sbT)))
            label.set_y(_id.lb, max)
        if _mml
            _id.lnT.set_y1(max), _id.lnT.set_xy2(_t, max)
            _id.lnB.set_y1(min), _id.lnB.set_xy2(_t, min)
        if _ml
            _id.lnM.set_y1(mid), _id.lnM.set_xy2(_t, mid)
        if _ol
            _id.lnO.set_x2(_t)
            if _olL
                _id.lbO.set_x(_t)
    if not _s and _le and not _kz
        if _mml
            if xt
                if _h < _id.lnT.get_y1()
                    _id.lnT.set_x2(_t)
                else
                    _id.lnT.set_x2(_t), xt := false
            if xb
                if _l > _id.lnB.get_y1()
                    _id.lnB.set_x2(_t)
                else
                    _id.lnB.set_x2(_t), xb := false
        if _ml
            _id.lnM.set_x2(_t)

method pDWM(DWM _id, _tC, _t, _o, _cl, _lbTX, _olL) =>
    if _tC
        _id.lb.delete()
        _id.ln := line.new(_t, _o, _t, _o, xloc.bar_time, extend.none, color.new(_cl, 0), line.style_dotted, 1)
        if _olL
            _id.lb := label.new(_t, _o, _lbTX + "(" + str.tostring(_o, format.mintick) + ")", xloc.bar_time, yloc.price, color(na), label.style_label_left, color.new(_cl, 0), size.tiny)
        0
    else
        _id.ln.set_x2(_t)
        if _olL
            _id.lb.set_x(_t)
        0

rrVisual(OB _ob, bool _bull, bool _show, float _rr, float _riskPct, color _riskC, color _rewardC, color _entryC, color _stopC, color _targetC, bool _showText, int _right) =>
    float entry = _bull ? _ob.btm : _ob.top
    float stopDistance = math.max(slSizePoints, syminfo.mintick)
    float stop = _bull ? entry - stopDistance : entry + stopDistance
    float risk = math.abs(entry - stop)
    float target = _bull ? entry + risk * _rr : entry - risk * _rr
    float riskTop = _bull ? _ob.btm : stop
    float riskBottom = _bull ? stop : _ob.top
    float rewardTop = math.max(entry, target)
    float rewardBottom = math.min(entry, target)
    if _show and risk > 0
        if na(_ob.rrRisk)
            _ob.rrRisk := box.new(left = _ob.obI, top = riskTop, right = _right, bottom = riskBottom, xloc = xloc.bar_time, border_color = _riskC, bgcolor = _riskC)
        else
            _ob.rrRisk.set_lefttop(_ob.obI, riskTop)
            _ob.rrRisk.set_rightbottom(_right, riskBottom)
            _ob.rrRisk.set_border_color(_riskC)
            _ob.rrRisk.set_bgcolor(_riskC)
        if na(_ob.rrReward)
            _ob.rrReward := box.new(left = _ob.obI, top = rewardTop, right = _right, bottom = rewardBottom, xloc = xloc.bar_time, border_color = _rewardC, bgcolor = _rewardC)
        else
            _ob.rrReward.set_lefttop(_ob.obI, rewardTop)
            _ob.rrReward.set_rightbottom(_right, rewardBottom)
            _ob.rrReward.set_border_color(_rewardC)
            _ob.rrReward.set_bgcolor(_rewardC)
        _ob.rrRisk.set_text("")
        _ob.rrReward.set_text("")
        if na(_ob.rrEntry)
            _ob.rrEntry := line.new(_ob.obI, entry, _right, entry, xloc = xloc.bar_time, color = _entryC, style = line.style_dotted)
        else
            _ob.rrEntry.set_xy1(_ob.obI, entry)
            _ob.rrEntry.set_xy2(_right, entry)
            _ob.rrEntry.set_color(_entryC)
        if na(_ob.rrStop)
            _ob.rrStop := line.new(_ob.obI, stop, _right, stop, xloc = xloc.bar_time, color = _stopC, style = line.style_solid)
        else
            _ob.rrStop.set_xy1(_ob.obI, stop)
            _ob.rrStop.set_xy2(_right, stop)
            _ob.rrStop.set_color(_stopC)
        if na(_ob.rrTarget)
            _ob.rrTarget := line.new(_ob.obI, target, _right, target, xloc = xloc.bar_time, color = _targetC, style = line.style_dashed)
        else
            _ob.rrTarget.set_xy1(_ob.obI, target)
            _ob.rrTarget.set_xy2(_right, target)
            _ob.rrTarget.set_color(_targetC)
    else
        if not na(_ob.rrRisk)
            _ob.rrRisk.delete()
            _ob.rrRisk := na
        if not na(_ob.rrReward)
            _ob.rrReward.delete()
            _ob.rrReward := na
        if not na(_ob.rrEntry)
            _ob.rrEntry.delete()
            _ob.rrEntry := na
        if not na(_ob.rrStop)
            _ob.rrStop.delete()
            _ob.rrStop := na
        if not na(_ob.rrTarget)
            _ob.rrTarget.delete()
            _ob.rrTarget := na
    0

pOBB(_s, _o, _h, _l, _c, _i, _t, _st, _sb, _mx, _mn, _cOBb, _cBBb, _cOBa, _cBBa, _obS, _bbS, _obbM, _obbTX, _obbE, _obbD, _obbR, _sigS, _buyC, _sellC) =>
    var int sbI = 0
    var bool xb = false
    var bool xa = false
    bool buySignal = false
    bool sellSignal = false
    rrWindowMs = rrDays * 86400000
    if _s and not _s[1]
        sbI := _i, xb := true, xa := true
        if _obbE
            if bOB.size() > 0
                for i = bOB.size() - 1 to 0
                    bOB.remove(i)
            if aOB.size() > 0
                for i = aOB.size() - 1 to 0
                    aOB.remove(i)
            if bBB.size() > 0
                for i = bBB.size() - 1 to 0
                    bBB.remove(i)
            if aBB.size() > 0
                for i = aBB.size() - 1 to 0
                    aBB.remove(i)
    if _s
        if _c[1] > _st.y and not _st.x and _st.i >= sbI
            _st.x := true
            minima = _mx[1]
            maxima = _mn[1]
            sBT = _t[1]
            for i = 1 to (_i - _st.i) - 1
                minima := math.min(_mn[i], minima)
                maxima := minima == _mn[i] ? _mx[i] : maxima
                sBT := minima == _mn[i] ? _t[i] : sBT
            bOB.unshift(OB.new(maxima, minima, sBT, box.new(na, na, na, na, color(na), xloc = xloc.bar_time, text = _obbTX ? "OB\nBullish" : "", text_size = size.tiny, text_halign = text.align_center, text_valign = text.align_center, text_color = color.new(_cOBb, 0))))
            if _sigS and _obS and (_obbD == "All" or _obbD == "Last" or bOB.size() == 1)
                newOb = bOB.get(0)
                newOb.hasSignal := true
                newOb.sig := label.new(x = newOb.obI, y = newOb.btm, text = "BUY", xloc = xloc.bar_time, yloc = yloc.price, color = color.new(_buyC, 0), style = label.style_label_up, textcolor = color.white, size = size.small)
                buySignal := true
            bBB.unshift(BB.new(box.new(na, na, na, na, color(na), xloc = xloc.bar_time), box.new(na, na, na, na, color(na), xloc = xloc.bar_time, text = _obbTX ? "BB" : "", text_size = size.tiny, text_halign = text.align_center, text_valign = text.align_center, text_color = color.new(_cBBb, 0))))
        if _c[1] < _sb.y and not _sb.x and _st.i >= sbI
            _sb.x := true
            minima = _mn[1]
            maxima = _mx[1]
            sBT = _t[1]
            for i = 1 to (_i - _sb.i) - 1
                maxima := math.max(_mx[i], maxima)
                minima := maxima == _mx[i] ? _mn[i] : minima
                sBT := maxima == _mx[i] ? _t[i] : sBT
            aOB.unshift(OB.new(maxima, minima, sBT, box.new(na, na, na, na, color(na), xloc = xloc.bar_time, text = _obbTX ? "OB\nBearish" : "", text_size = size.tiny, text_halign = text.align_center, text_valign = text.align_center, text_color = color.new(_cOBa, 0))))
            if _sigS and _obS and (_obbD == "All" or _obbD == "Last" or aOB.size() == 1)
                newOb = aOB.get(0)
                newOb.hasSignal := true
                newOb.sig := label.new(x = newOb.obI, y = newOb.top, text = "SELL", xloc = xloc.bar_time, yloc = yloc.price, color = color.new(_sellC, 0), style = label.style_label_down, textcolor = color.white, size = size.small)
                sellSignal := true
            aBB.unshift(BB.new(box.new(na, na, na, na, color(na), xloc = xloc.bar_time), box.new(na, na, na, na, color(na), xloc = xloc.bar_time, text = _obbTX ? "BB" : "", text_size = size.tiny, text_halign = text.align_center, text_valign = text.align_center, text_color = color.new(_cBBa, 0))))
    if _obbE ? true : _s
        if bOB.size() > 0
            for i = bOB.size() - 1 to 0
                ob = bOB.get(i), bb = bBB.get(i)
                showSignal = _sigS and _obS and (_obbD == "All" or (_obbD == "First" ? i == bOB.size() - 1 : i == 0)) and (not _obbR or ob.ext)
                showRR = rrSH and _obS and (_obbD == "All" or (_obbD == "First" ? i == bOB.size() - 1 : i == 0)) and (not _obbR or ob.ext) and (rrDays <= 0 or (timenow - ob.obI) <= rrWindowMs)
                rrVisual(ob, true, showRR, rrRatio, riskPerTrade, rrRiskC, rrRewardC, rrEntryC, rrStopC, rrTargetC, rrTX, _t)
                if showSignal
                    if na(ob.sig)
                        ob.sig := label.new(x = ob.obI, y = ob.btm, text = "BUY", xloc = xloc.bar_time, yloc = yloc.price, color = color.new(_buyC, 0), style = label.style_label_up, textcolor = color.white, size = size.small)
                    else
                        ob.sig.set_xy(ob.obI, ob.btm), ob.sig.set_color(color.new(_buyC, 0)), ob.sig.set_textcolor(color.white), ob.sig.set_style(label.style_label_up)
                else if not na(ob.sig)
                    ob.sig.delete(), ob.sig := na
                if _obbR
                    if not ob.ext
                        ob.bxOB.delete()
                        if not na(ob.sig)
                            ob.sig.delete(), ob.sig := na
                    if not bb.ext
                        bb.bxOB.delete(), bb.bxBB.delete()
                if not bb.bb
                    if _obS and (_obbD == "First" ? i == bOB.size() - 1 : true)
                        ob.bxOB.set_lefttop(ob.obI, ob.top), ob.bxOB.set_rightbottom(_t, ob.btm)
                        ob.bxOB.set_bgcolor(_obbD == "Last" ? i == 0 ? _cOBb : color(na) : _cOBb)
                        ob.bxOB.set_border_color(_obbD == "Last" ? i == 0 ? obBullBorderC : color(na) : obBullBorderC)
                        ob.bxOB.set_border_width(obBorderW)
                        ob.bxOB.set_text_color(_obbD == "Last" ? i == 0 ? color.new(_cOBb, 0) : color(na) : color.new(_cOBb, 0))
                    if math.min((_obbM ? _c[1] : _l[1]), _o[1]) < ob.btm
                        bb.bb := true
                        if _obS
                            ob.bxOB.set_right(_t[1]), ob.ext := false
                        if _bbS and xb
                            bb.bbI := _t[1]
                            bb.bxBB.set_lefttop(bb.bbI, ob.top), bb.bxBB.set_rightbottom(_t, ob.btm), bb.bxBB.set_bgcolor(_cBBb)
                            if not _obS or _obbR or not (_obbD == "First" ? i == bOB.size() - 1 : true)
                                bb.bxOB.set_lefttop(ob.obI, ob.top), bb.bxOB.set_rightbottom(bb.bbI, ob.btm), bb.bxOB.set_bgcolor(color(na)), bb.bxOB.set_border_color(_cBBb)
                            if _obbD == "First"
                                xb := false
                            if _obbD == "Last"
                                bLS.push(bb.bbI)
                else
                    if (_obbM ? _c[1] : _h[1]) > ob.top
                        bb.ext := false
                    if _obS
                        ob.bxOB.set_bgcolor(_obbD == "Last" ? i == 0 ? _cOBb : color(na) : _cOBb)
                        ob.bxOB.set_border_color(_obbD == "Last" ? i == 0 ? obBullBorderC : color(na) : obBullBorderC)
                        ob.bxOB.set_border_width(obBorderW)
                        ob.bxOB.set_text_color(_obbD == "Last" ? i == 0 ? color.new(_cOBb, 0) : color(na) : color.new(_cOBb, 0))
                    if _bbS and bb.ext
                        bb.bxBB.set_right(_t)
                    if _bbS and _obbD == "Last"
                        if i != 0
                            bb.bxOB.set_lefttop(ob.obI, ob.top), bb.bxOB.set_rightbottom(bb.bbI, ob.btm), bb.bxOB.set_bgcolor(color(na)), bb.bxOB.set_border_color(_cBBb)
                        if bLS.max() != bb.bxBB.get_left()
                            bb.bxBB.set_bgcolor(color(na)), bb.bxBB.set_text_color(color(na)), bb.bxOB.set_border_color(color(na))
        if aOB.size() > 0
            for i = aOB.size() - 1 to 0
                ob = aOB.get(i), bb = aBB.get(i)
                showSignal = _sigS and _obS and (_obbD == "All" or (_obbD == "First" ? i == aOB.size() - 1 : i == 0)) and (not _obbR or ob.ext)
                showRR = rrSH and _obS and (_obbD == "All" or (_obbD == "First" ? i == aOB.size() - 1 : i == 0)) and (not _obbR or ob.ext) and (rrDays <= 0 or (timenow - ob.obI) <= rrWindowMs)
                rrVisual(ob, false, showRR, rrRatio, riskPerTrade, rrRiskC, rrRewardC, rrEntryC, rrStopC, rrTargetC, rrTX, _t)
                if showSignal
                    if na(ob.sig)
                        ob.sig := label.new(x = ob.obI, y = ob.top, text = "SELL", xloc = xloc.bar_time, yloc = yloc.price, color = color.new(_sellC, 0), style = label.style_label_down, textcolor = color.white, size = size.small)
                    else
                        ob.sig.set_xy(ob.obI, ob.top), ob.sig.set_color(color.new(_sellC, 0)), ob.sig.set_textcolor(color.white), ob.sig.set_style(label.style_label_down)
                else if not na(ob.sig)
                    ob.sig.delete(), ob.sig := na
                if _obbR
                    if not ob.ext
                        ob.bxOB.delete()
                        if not na(ob.sig)
                            ob.sig.delete(), ob.sig := na
                    if not bb.ext
                        bb.bxOB.delete(), bb.bxBB.delete()
                if not bb.bb
                    if _obS and (_obbD == "First" ? i == aOB.size() - 1 : true)
                        ob.bxOB.set_lefttop(ob.obI, ob.top), ob.bxOB.set_rightbottom(_t, ob.btm)
                        ob.bxOB.set_bgcolor(_obbD == "Last" ? i == 0 ? _cOBa : color(na) : _cOBa)
                        ob.bxOB.set_border_color(_obbD == "Last" ? i == 0 ? obBearBorderC : color(na) : obBearBorderC)
                        ob.bxOB.set_border_width(obBorderW)
                        ob.bxOB.set_text_color(_obbD == "Last" ? i == 0 ? color.new(_cOBa, 0) : color(na) : color.new(_cOBa, 0))
                    if math.max((_obbM ? _c[1] : _h[1]), _o[1]) > ob.top
                        bb.bb := true
                        if _obS
                            ob.bxOB.set_right(_t[1]), ob.ext := false
                        if _bbS and xa
                            bb.bbI := _t[1]
                            bb.bxBB.set_lefttop(bb.bbI, ob.top), bb.bxBB.set_rightbottom(_t, ob.btm), bb.bxBB.set_bgcolor(_cBBa)
                            if not _obS or _obbR or not (_obbD == "First" ? i == aOB.size() - 1 : true)
                                bb.bxOB.set_lefttop(ob.obI, ob.top), bb.bxOB.set_rightbottom(bb.bbI, ob.btm), bb.bxOB.set_bgcolor(color(na)), bb.bxOB.set_border_color(_cBBa)
                            if _obbD == "First"
                                xa := false
                            if _obbD == "Last"
                                aLS.push(bb.bbI)
                else
                    if (_obbM ? _c[1] : _l[1]) < ob.btm
                        bb.ext := false
                    if _obS
                        ob.bxOB.set_bgcolor(_obbD == "Last" ? i == 0 ? _cOBa : color(na) : _cOBa)
                        ob.bxOB.set_border_color(_obbD == "Last" ? i == 0 ? obBearBorderC : color(na) : obBearBorderC)
                        ob.bxOB.set_border_width(obBorderW)
                        ob.bxOB.set_text_color(_obbD == "Last" ? i == 0 ? color.new(_cOBa, 0) : color(na) : color.new(_cOBa, 0))
                    if _bbS and bb.ext
                        bb.bxBB.set_right(_t)
                    if _bbS and _obbD == "Last"
                        if i != 0
                            bb.bxOB.set_lefttop(ob.obI, ob.top), bb.bxOB.set_rightbottom(bb.bbI, ob.btm), bb.bxOB.set_bgcolor(color(na)), bb.bxOB.set_border_color(_cBBa)
                        if aLS.max() != bb.bxBB.get_left()
                            bb.bxBB.set_bgcolor(color(na)), bb.bxBB.set_text_color(color(na)), bb.bxOB.set_border_color(color(na))
        [buySignal, sellSignal]
    else if not _obbE
        if bOB.size() > 0
            for i = bOB.size() - 1 to 0
                bOB.remove(i)
        if aOB.size() > 0
            for i = aOB.size() - 1 to 0
                aOB.remove(i)
        if bBB.size() > 0
            for i = bBB.size() - 1 to 0
                bBB.remove(i)
        if aBB.size() > 0
            for i = aBB.size() - 1 to 0
                aBB.remove(i)
        [false, false]

pFVG(_s, _h, _l, _c, _i, _atr, _fR, _fE, _fD, _fTX, _fbC, _faC) =>
    var bool xb = false
    var bool xa = false
    if _s and not _s[1]
        xb := true, xa := true
        if _fE
            if bFVG.size() > 0
                for i = bFVG.size() - 1 to 0
                    bFVG.remove(i)
            if aFVG.size() > 0
                for i = aFVG.size() - 1 to 0
                    aFVG.remove(i)
    bullG = _l > _h[1]
    bearG = _h < _l[1]
    if _s
        bull = (_l - _h[2]) > _atr and _l > _h[2] and _c[1] > _h[2] and not (bullG or bullG[1])
        if bull and xb
            bFVG.unshift(FVG.new(box.new(_i - 1, _l, _i, _h[2], na, bgcolor = _fbC, text = _fTX ? "FVG" : "", text_size = size.tiny, text_halign = text.align_center, text_valign = text.align_center, text_color = color.new(_fbC, 0)), true))
            if _fD == "First"
                xb := false
            if bFVG.size() > 1 and _fD == "Last"
                fvg = bFVG.pop(), fvg.bx.delete()
        bear = (_l[2] - _h) > _atr and _h < _l[2] and _c[1] < _l[2] and not (bearG or bearG[1])
        if bear and xa
            aFVG.unshift(FVG.new(box.new(_i - 1, _l[2], _i, _h, na, bgcolor = _faC, text = _fTX ? "FVG" : "", text_size = size.tiny, text_halign = text.align_center, text_valign = text.align_center, text_color = color.new(_faC, 0)), true))
            if _fD == "First"
                xa := false
            if aFVG.size() > 1 and _fD == "Last"
                fvg = aFVG.pop(), fvg.bx.delete()
    if _fE ? true : _s
        if bFVG.size() > 0
            for i = bFVG.size() - 1 to 0
                fvg = bFVG.get(i), fvgB = fvg.bx.get_bottom()
                if fvg.e
                    if _l < fvgB
                        fvg.bx.set_right(_i)
                        if _fR
                            fvg.bx.delete()
                        fvg.e := false
                    else
                        fvg.bx.set_right(_i)
        if aFVG.size() > 0
            for i = aFVG.size() - 1 to 0
                fvg = aFVG.get(i), fvgT = fvg.bx.get_top()
                if fvg.e
                    if _h > fvgT
                        fvg.bx.set_right(_i)
                        if _fR
                            fvg.bx.delete()
                        fvg.e := false
                    else
                        fvg.bx.set_right(_i)
        0
    else if not _fE
        if bFVG.size() > 0
            for i = bFVG.size() - 1 to 0
                bFVG.remove(i)
        if aFVG.size() > 0
            for i = aFVG.size() - 1 to 0
                aFVG.remove(i)
        0

kzO = dwmO == "Killzones"
kz.killzones(nyam and timeframe.isintraday, inKZ, b.o, b.h, b.l, b.c, b.t, nyC, nyST, kzMML, kzML, kzLB, kzLE, kzO, dwmC, dwmL, nyC)
kz.killzones(ldnO and timeframe.isintraday, inKZ, b.o, b.h, b.l, b.c, b.t, ldnOC, ldnOST, kzMML, kzML, kzLB, kzLE, kzO, dwmC, dwmL, ldnOC)
kz.killzones(ldnC and timeframe.isintraday, inKZ, b.o, b.h, b.l, b.c, b.t, ldnCC, ldnCST, kzMML, kzML, kzLB, kzLE, kzO, dwmC, dwmL, ldnCC)
kz.killzones(asian and timeframe.isintraday, inKZ, b.o, b.h, b.l, b.c, b.t, asC, asST, kzMML, kzML, kzLB, kzLE, kzO, dwmC, dwmL, asC)
bool xChg = dwmO == "the Day" ? timeframe.change("D") : dwmO == "the Week" ? timeframe.change("W") : dwmO == "the Month" ? timeframe.change("M") : false
string xTxt = dwmO == "the Day" ? "DO" : dwmO == "the Week" ? "WO" : dwmO == "the Month" ? "MO" : ""
if not kzO and timeframe.isintraday and tfM <= kzSH
    dwm.pDWM(xChg, b.t, b.o, dwmC, xTxt, dwmL)
bgcolor(dwmS and not kzO and timeframe.isintraday and tfM <= kzSH ? xChg ? dwmC : na : na)
[top, btm] = swings(obbLN)
max = useBody ? math.max(b.c, b.o) : b.h
min = useBody ? math.min(b.c, b.o) : b.l
[obBuySignal, obSellSignal] = if obSH or bbSH
    pOBB(inKZ, b.o, b.h, b.l, b.c, b.i, b.t, top, btm, max, min, bullOC, bullBC, bearOC, bearBC, obSH, bbSH, obbMP, obbTX, obbEX, obbSH, obbR, obSigSH, obBuyC, obSellC)
else
    [false, false]

// A signal is valid only while its source Order Block is still unmitigated.
// pOBB() evaluates the previous candle for mitigation, so the current candle
// is also checked here to prevent a same-bar mitigated OB from alerting.
buyObCurrentlyMitigated = bOB.size() > 0 and math.min((obbMP ? close : low), open) < bOB.get(0).btm
sellObCurrentlyMitigated = aOB.size() > 0 and math.max((obbMP ? close : high), open) > aOB.get(0).top
bool validObBuySignal = obBuySignal and bOB.size() > 0 and bOB.get(0).hasSignal and bOB.get(0).ext and not buyObCurrentlyMitigated
bool validObSellSignal = obSellSignal and aOB.size() > 0 and aOB.get(0).hasSignal and aOB.get(0).ext and not sellObCurrentlyMitigated

// These stay as chart-only notifications (Condition dropdown in Create Alert).
// They are NOT what Ghost should be pointed at - they fire on every raw signal
// regardless of teOnePerDirection/teMinGapBars/teOneLabelPerSession, which would
// send far more live entries than the chart actually tracks. The real webhook
// JSON alerts fire further down, only once a trade has passed every throttle.
alertcondition(validObBuySignal, "Order Block BUY (raw, unthrottled - chart notification only)", "BUY Order Block on {{ticker}} {{interval}}")
alertcondition(validObSellSignal, "Order Block SELL (raw, unthrottled - chart notification only)", "SELL Order Block on {{ticker}} {{interval}}")

// --- Trade Execution Tracking -------------------------------------------------
// No entry marker is drawn because it would overlap the BUY/SELL signal label.
// A trade is created only when pOBB() returns a qualifying Order Block signal.
// After creation, the trade is tracked independently of the Order Block display
// arrays. Display filters, mitigation cleanup, killzone resets, and First/Last
// selection can remove an Order Block visually before its trade reaches SL or TP.
// Those visual changes must never cancel the trade or its outcome label.
// Labels are offset teLabelOffset bars to the right of the triggering candle.
//
// GHOST WEBHOOK JSON: entry alerts fire here, immediately after a trade passes
// every throttle and is genuinely pushed to openTrades - never on the raw
// validObBuySignal/validObSellSignal above. sl/tp are sent as absolute prices,
// so on the Ghost ticker settings you need "Use Stop Loss and Take Profit" AND
// "Use Webhook SL/TP" both on. qty uses this instrument's own syminfo.pointvalue,
// so risk/R:R stays correct automatically when switching symbols (MNQ vs MGC,
// etc.) - no manual point-value input needed. "Webhook Controls Contracts"
// should be on in Ghost if you want position size to follow riskPerTrade.
teWindowMs = teDays * 86400000
if teSH
    hasActiveBull = false
    hasActiveSell = false
    if teOnePerDirection and openTrades.size() > 0
        for i = 0 to openTrades.size() - 1
            tt = openTrades.get(i)
            if tt.isBull
                hasActiveBull := true
            else
                hasActiveSell := true

    gapOkBuy = na(lastBuyLabelBar) or (bar_index - lastBuyLabelBar) >= teMinGapBars
    gapOkSell = na(lastSellLabelBar) or (bar_index - lastSellLabelBar) >= teMinGapBars
    sessionOkBuy = not teOneLabelPerSession or na(lastBuySessionId) or lastBuySessionId != kzSessionId
    sessionOkSell = not teOneLabelPerSession or na(lastSellSessionId) or lastSellSessionId != kzSessionId

    if validObBuySignal and bOB.size() > 0 and (not teOnePerDirection or not hasActiveBull) and gapOkBuy and sessionOkBuy
        buyOb = bOB.get(0)
        if array.indexof(tradeObIds, buyOb.obI) == -1 and array.indexof(completedObIds, buyOb.obI) == -1
            buyEntry = buyOb.btm
            buyStopDist = math.max(slSizePoints, syminfo.mintick)
            buyStop = buyEntry - buyStopDist
            buyTarget = buyEntry + math.abs(buyEntry - buyStop) * rrRatio
            buyQty = math.max(1, math.round(riskPerTrade / (buyStopDist * syminfo.pointvalue)))
            tradeObIds.push(buyOb.obI)
            nextTradeId += 1
            openTrades.push(Trade.new(true, buyEntry, buyStop, buyTarget, time, buyOb.obI, buyQty, buyOb.hasSignal, bar_index, nextTradeId))
            lastBuyLabelBar := bar_index
            lastBuySessionId := kzSessionId
            if autoWebhooksOn
                buyJson = '{"action":"buy","price":' + str.tostring(buyEntry, format.mintick) + ',"sl":' + str.tostring(buyStop, format.mintick) + ',"tp":' + str.tostring(buyTarget, format.mintick) + ',"qty":' + str.tostring(buyQty) + ',"time":"' + f_isoTime() + '"}'
                alert(buyJson, alert.freq_once_per_bar_close)
    if validObSellSignal and aOB.size() > 0 and (not teOnePerDirection or not hasActiveSell) and gapOkSell and sessionOkSell
        sellOb = aOB.get(0)
        if array.indexof(tradeObIds, sellOb.obI) == -1 and array.indexof(completedObIds, sellOb.obI) == -1
            sellEntry = sellOb.top
            sellStopDist = math.max(slSizePoints, syminfo.mintick)
            sellStop = sellEntry + sellStopDist
            sellTarget = sellEntry - math.abs(sellStop - sellEntry) * rrRatio
            sellQty = -math.max(1, math.round(riskPerTrade / (sellStopDist * syminfo.pointvalue)))
            tradeObIds.push(sellOb.obI)
            nextTradeId += 1
            openTrades.push(Trade.new(false, sellEntry, sellStop, sellTarget, time, sellOb.obI, sellQty, sellOb.hasSignal, bar_index, nextTradeId))
            lastSellLabelBar := bar_index
            lastSellSessionId := kzSessionId
            if autoWebhooksOn
                sellJson = '{"action":"sell","price":' + str.tostring(sellEntry, format.mintick) + ',"sl":' + str.tostring(sellStop, format.mintick) + ',"tp":' + str.tostring(sellTarget, format.mintick) + ',"qty":' + str.tostring(math.abs(sellQty)) + ',"time":"' + f_isoTime() + '"}'
                alert(sellJson, alert.freq_once_per_bar_close)

    // Evaluate trades only after their entry bar. The entry candle cannot also
    // resolve the newly created trade.
    if openTrades.size() > 0
        for i = openTrades.size() - 1 to 0
            t = openTrades.get(i)
            if not t.hasSignal
                openTrades.remove(i)
            else if bar_index > t.entryBar
                currentTradeMitigation = t.isBull ? math.min((obbMP ? close : low), open) < t.entry : math.max((obbMP ? close : high), open) > t.entry
                bool obMitigated = currentTradeMitigation
                if t.isBull
                    if bOB.size() > 0
                        for j = 0 to bOB.size() - 1
                            candidateBullOb = bOB.get(j)
                            currentBullMitigation = math.min((obbMP ? close : low), open) < candidateBullOb.btm
                            if candidateBullOb.obI == t.obI and (not candidateBullOb.ext or currentBullMitigation)
                                obMitigated := true
                else
                    if aOB.size() > 0
                        for j = 0 to aOB.size() - 1
                            candidateBearOb = aOB.get(j)
                            currentBearMitigation = math.max((obbMP ? close : high), open) > candidateBearOb.top
                            if candidateBearOb.obI == t.obI and (not candidateBearOb.ext or currentBearMitigation)
                                obMitigated := true
                if obMitigated
                    // GHOST WEBHOOK JSON: the broker bracket has no way to know
                    // about a mitigation-cancellation - it only reacts to real
                    // sl/tp price touches. Without this exit call, a mitigated
                    // trade would stay open at the broker even though the chart
                    // shows it closed.
                    if autoWebhooksOn
                        alert('{"action":"exit"}', alert.freq_once_per_bar_close)
                    openTrades.remove(i)
                else
                    withinWindow = (timenow - t.entryTime) <= teWindowMs
                    labelX = bar_index + teLabelOffset
                    if t.isBull
                        // Conservative tie rule: if one candle hits both levels,
                        // SL is recorded because it is checked before TP.
                        if low <= t.stop
                            if array.indexof(completedTradeIds, t.tradeId) == -1
                                if withinWindow and array.indexof(completedObIds, t.obI) == -1
                                    label.new(labelX, t.stop, "SL HIT", xloc.bar_index, yloc.price, color = color.new(teSLC, 82), style = label.style_label_right, textcolor = teSLTextC, size = teLblSize)
                                completedTradeIds.push(t.tradeId)
                                completedObIds.push(t.obI)
                            openTrades.remove(i)
                        else if high >= t.target
                            if array.indexof(completedTradeIds, t.tradeId) == -1
                                if withinWindow and array.indexof(completedObIds, t.obI) == -1
                                    label.new(labelX, t.target, "TP HIT", xloc.bar_index, yloc.price, color = color.new(teTPC, 82), style = label.style_label_right, textcolor = teTPTextC, size = teLblSize)
                                completedTradeIds.push(t.tradeId)
                                completedObIds.push(t.obI)
                            openTrades.remove(i)
                    else
                        if high >= t.stop
                            if array.indexof(completedTradeIds, t.tradeId) == -1
                                if withinWindow and array.indexof(completedObIds, t.obI) == -1
                                    label.new(labelX, t.stop, "SL HIT", xloc.bar_index, yloc.price, color = color.new(teSLC, 82), style = label.style_label_right, textcolor = teSLTextC, size = teLblSize)
                                completedTradeIds.push(t.tradeId)
                                completedObIds.push(t.obI)
                            openTrades.remove(i)
                        else if low <= t.target
                            if array.indexof(completedTradeIds, t.tradeId) == -1
                                if withinWindow and array.indexof(completedObIds, t.obI) == -1
                                    label.new(labelX, t.target, "TP HIT", xloc.bar_index, yloc.price, color = color.new(teTPC, 82), style = label.style_label_right, textcolor = teTPTextC, size = teLblSize)
                                completedTradeIds.push(t.tradeId)
                                completedObIds.push(t.obI)
                            openTrades.remove(i)
// --------------------------------------------------------------------------

dashTablePos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Left" ? position.bottom_left : dashPos == "Bottom Right" ? position.bottom_right : position.top_right
var table dashTable = table.new(dashTablePos, 2, 7, bgcolor = dashBgC, frame_color = dashBorderC, frame_width = 1, border_color = dashBorderC, border_width = 1)
if barstate.islast
    if dashSH
        table.cell(dashTable, 0, 0, "TF", bgcolor = dashHeaderC, text_color = dashTextC, text_size = dashTextSize)
        table.cell(dashTable, 1, 0, "TREND", bgcolor = dashHeaderC, text_color = dashTextC, text_size = dashTextSize)
        table.cell(dashTable, 0, 1, dashTf1, bgcolor = dashBgC, text_color = dashTextC, text_size = dashTextSize)
        table.cell(dashTable, 1, 1, trend1, bgcolor = trend1 == "Bullish" ? dashBullC : dashBearC, text_color = dashTextC, text_size = dashTextSize)
        table.cell(dashTable, 0, 2, dashTf2, bgcolor = dashBgC, text_color = dashTextC, text_size = dashTextSize)
        table.cell(dashTable, 1, 2, trend2, bgcolor = trend2 == "Bullish" ? dashBullC : dashBearC, text_color = dashTextC, text_size = dashTextSize)
        table.cell(dashTable, 0, 3, dashTf3, bgcolor = dashBgC, text_color = dashTextC, text_size = dashTextSize)
        table.cell(dashTable, 1, 3, trend3, bgcolor = trend3 == "Bullish" ? dashBullC : dashBearC, text_color = dashTextC, text_size = dashTextSize)
        table.cell(dashTable, 0, 4, dashTf4, bgcolor = dashBgC, text_color = dashTextC, text_size = dashTextSize)
        table.cell(dashTable, 1, 4, trend4, bgcolor = trend4 == "Bullish" ? dashBullC : dashBearC, text_color = dashTextC, text_size = dashTextSize)
        table.cell(dashTable, 0, 5, dashTf5, bgcolor = dashBgC, text_color = dashTextC, text_size = dashTextSize)
        table.cell(dashTable, 1, 5, trend5, bgcolor = trend5 == "Bullish" ? dashBullC : dashBearC, text_color = dashTextC, text_size = dashTextSize)
        table.cell(dashTable, 0, 6, dashTf6, bgcolor = dashBgC, text_color = dashTextC, text_size = dashTextSize)
        table.cell(dashTable, 1, 6, trend6, bgcolor = trend6 == "Bullish" ? dashBullC : dashBearC, text_color = dashTextC, text_size = dashTextSize)
    else
        table.clear(dashTable, 0, 0, 1, 6)

pp_h = ta.pivothigh(mssLN, mssLN)
pp_l = ta.pivotlow(mssLN, mssLN)
if not na(pp_h)
    pp.h := pp_h, pp.hx := false, pp.hi := b.i - mssLN
if not na(pp_l)
    pp.l := pp_l, pp.lx := false, pp.li := b.i - mssLN
if not inKZ
    pp.l := 0, pp.h := 10e8, shift := 0
    if bMSS.size() > 0
        for i = bMSS.size() - 1 to 0
            bMSS.remove(i)
    if aMSS.size() > 0
        for i = aMSS.size() - 1 to 0
            aMSS.remove(i)
if mssSH and inKZ
    if (b[1]).c > pp.h and not pp.hx
        pp.hx := true
        if shift == -1 or shift == 0
            if (mssDO == "First" ? bMSS.size() < 1 : true)
                bMSS.unshift(MSS.new(line.new(pp.hi, pp.h, b.i - 1, pp.h, color = ppLCB), box.new(pp.hi, pp.h, b.i - 1, pp.h, text = "CHoCH", text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_bottom, text_color = mssTX ? ppLCB : color(na), bgcolor = color(na), border_color = color(na))))
            if bMSS.size() > 1 and mssDO == "Last"
                mss = bMSS.pop(), mss.ln.delete(), mss.bx.delete()
        shift := 1
    if (b[1]).c < pp.l and not pp.lx
        pp.lx := true
        if shift == 1 or shift == 0
            if (mssDO == "First" ? aMSS.size() < 1 : true)
                aMSS.unshift(MSS.new(line.new(pp.li, pp.l, b.i - 1, pp.l, color = ppLCS), box.new(pp.li, pp.l, b.i - 1, pp.l, text = "CHoCH", text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top, text_color = mssTX ? ppLCS : color(na), bgcolor = color(na), border_color = color(na))))
            if aMSS.size() > 1 and mssDO == "Last"
                mss = aMSS.pop(), mss.ln.delete(), mss.bx.delete()
        shift := -1
if fvgSH
    pFVG(inKZ, b.h, b.l, b.c, b.i, fvgATR, fvgR, fvgE, fvgDO, fvgTX, fvgBC, fvgSC)
````
