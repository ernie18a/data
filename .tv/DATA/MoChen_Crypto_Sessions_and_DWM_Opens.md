<!-- tradingview-pine-id: PUB;f83c545c8b614539a74e377ea209883d -->
<!-- tradingviewscripts-format: 1 -->
# MoChen - Crypto Sessions and D/W/M Opens

Source: https://www.tradingview.com/script/HXS36GJU/

## Description

OVERVIEW

MoChen Crypto Sessions and DWM Opens is an overlay indicator designed for continuously traded cryptocurrency markets.

The script combines three configurable regional market sessions with UTC-based Daily, Weekly, and Monthly opening levels. Its purpose is to provide a consistent time-and-price framework for intraday analysis without requiring traders to redraw the same sessions and period-opening levels manually.

The indicator does not generate buy or sell signals. It provides contextual reference levels that can be combined with market structure, liquidity analysis, support and resistance, or the trader's own execution model.

SESSION FRAMEWORK

The default sessions are:

- Asian: 09:00-13:30 in Asia/Taipei
- London: 08:00-16:30 in Europe/London
- New York: 09:30-16:00 in America/New_York

These are configurable analysis windows for cryptocurrency trading. They should not be interpreted as official cryptocurrency exchange opening or closing hours because cryptocurrency markets trade continuously.

Each session uses its own IANA time zone. Europe/London and America/New_York automatically follow their respective daylight-saving-time rules, so users do not need to switch manually between summer and winter offsets.

While a session is active, the script tracks:

- Session open
- Developing session high
- Developing session low
- Latest session close

The session range updates as new bars form. When the session ends, its completed range stops updating.

Users can independently control:

- Session visibility
- Session time
- Session name
- Color and background opacity
- Open, close, high, and low visibility
- Line style and width
- Session labels
- Number of completed sessions retained

DAILY, WEEKLY, AND MONTHLY OPENS

The indicator also calculates three UTC-based period-opening references:

- D: Daily open at 00:00 UTC
- W: Weekly open at Monday 00:00 UTC
- M: Monthly open on the first calendar day at 00:00 UTC

These levels represent the opening price of the first available chart bar belonging to the corresponding UTC period.

The default visual hierarchy is:

- Daily Open: blue solid line, width 1
- Weekly Open: cyan solid line, width 2
- Monthly Open: yellow solid line, width 3

OVERLAPPING DWM LEVELS

A key feature of the script is its handling of overlapping Daily, Weekly, and Monthly opens.

When two or more periods begin from the same price, the indicator does not draw several identical lines on top of one another. It displays one consolidated level and uses the higher-timeframe visual style.

The priority is:

Monthly > Weekly > Daily

Examples:

- A Monday Daily Open that matches the Weekly Open is initially displayed as W/D.
- After that Daily period ends, the same higher-timeframe level is displayed as W.
- If a new month begins on Monday, the combined level is initially displayed as M/W/D.
- After the Daily period ends, it becomes M/W.
- After the Weekly period ends, the remaining higher-timeframe reference is displayed as M.

The underlying Daily, Weekly, and Monthly period states remain separate. Only their visual presentation is consolidated to reduce chart clutter and avoid making one price appear to be several different levels.

HOW TO USE THE INDICATOR

The session ranges can help traders observe:

- Expansion from an established regional range
- Breakouts above or below a completed session
- Reactions around a session open
- Continuation or reversal between Asian, London, and New York participation
- Whether price is trading above or below the Daily, Weekly, or Monthly open

One possible analysis sequence is:

1. Identify the current position relative to the Weekly and Monthly Open.
2. Observe the range formed during the Asian session.
3. Evaluate whether London expands, rejects, or remains inside that range.
4. Observe how New York reacts to the completed Asian and London ranges.
5. Use market structure and risk management to determine whether a trade is justified.

The indicator itself does not define an entry, stop loss, take profit, or directional forecast.

ORIGINAL IMPLEMENTATION

This script uses an independently implemented session and period-level architecture.

Its main distinguishing elements are:

- Three separately managed session states
- IANA-based daylight-saving-time handling
- Developing session ranges that freeze after completion
- Independent historical-object retention for each session
- UTC-based Daily, Weekly, and Monthly period detection
- Consolidated DWM display with higher-timeframe priority
- Dynamic removal of lower-timeframe labels after their periods expire
- Controlled line, label, and box lifecycle management

The DWM consolidation system is intended to preserve the meaning of each period while displaying only the most relevant higher-timeframe reference when multiple levels occupy the same price.

TIMEFRAME AND DATA LIMITATIONS

The session component is intended primarily for intraday charts.

Recommended chart timeframes include:

- 1 minute
- 3 minutes
- 5 minutes
- 15 minutes
- 30 minutes

On higher chart timeframes, a bar may span across a session boundary. In that case, the first or last chart bar detected inside a session may not represent the exact minute-level opening or closing price.

For example, a New York session beginning at 09:30 cannot always be represented precisely on a 1-hour or 4-hour chart.

The Daily, Weekly, and Monthly levels are based on UTC calendar boundaries. Users who require exchange-specific daily candles should verify whether their selected symbol's data feed aligns with the UTC period definition used by this script.

REAL-TIME BEHAVIOR

The developing high and low of an active session change as new price information becomes available. This is expected real-time behavior.

After a session ends, its completed high, low, open, and close references no longer update.

The script is designed without future-looking or lookahead calculations. It does not use completed future bars to alter earlier session results.

DISCLAIMER

This script is intended for educational, analytical, and informational purposes only.

It does not constitute financial advice, an investment recommendation, or a guarantee of future results. Users remain responsible for their own analysis, trading decisions, position sizing, and risk management.

繁體中文說明

MoChen Crypto Sessions and DWM Opens 是一套為 24 小時加密貨幣市場設計的圖表指標。

它整合三個主要市場時段，以及依 UTC 計算的日開、週開與月開，協助交易者建立一致的時間與價格參考架構，減少每天重複標記時段與開盤價的工作。

本指標不提供自動買賣訊號。

一、三大市場時段

預設時段為：

- Asian：09:00-13:30，Asia/Taipei
- London：08:00-16:30，Europe/London
- New York：09:30-16:00，America/New_York

這些是加密貨幣盤面分析使用的時間區間，不代表加密貨幣交易所的官方開盤或收盤。

倫敦與紐約使用 IANA 當地時區，因此會自動依日期處理夏令與冬令時間，不需要使用者手動切換 UTC 偏移。

時段進行中，指標會持續更新：

- 時段開盤價
- 時段最高價
- 時段最低價
- 最新時段收盤價

時段結束後，已完成區間停止更新。

二、日開、週開與月開

三個週期基準固定為：

- D：每日 UTC 00:00
- W：每週一 UTC 00:00
- M：每月第一天 UTC 00:00

預設樣式：

- D：藍色實線，線寬 1
- W：青色實線，線寬 2
- M：黃色實線，線寬 3

三、D／W／M 重疊處理

當日開、週開或月開位於同一個價格時，指標不會重複畫出多條完全相同的線。

顯示優先級為：

M > W > D

例如：

- 星期一的日開與週開相同時，建立當下顯示 W/D。
- 當日結束後，該高週期位置只顯示 W。
- 月初剛好是星期一時，建立當下顯示 M/W/D。
- 日線週期結束後顯示 M/W。
- 週線週期結束後只保留 M。

日、週、月的內部計算仍然彼此獨立，只有圖表上的顯示會進行整合。

四、使用方式

可以用來觀察：

- 亞洲時段建立的區間
- 倫敦是否延續或突破亞洲區間
- 紐約是否掃取或突破先前時段高低點
- 價格位於日開、週開與月開上方或下方
- 價格對時段開盤價及高週期開盤價的反應

建議搭配市場結構、流動性、支撐壓力與風險管理使用。

本指標不會自動提供進場、停損、止盈或方向預測。

五、週期限制

建議使用：

- 1 分鐘
- 3 分鐘
- 5 分鐘
- 15 分鐘
- 30 分鐘

在 1 小時或 4 小時等較高週期中，一根 K 棒可能橫跨時段邊界，因此時段開盤價與收盤價未必能精準對應到分鐘級時間。

六、即時更新與重繪說明

時段尚未結束時，最高價與最低價會隨即時價格更新，這是正常的進行中計算。

時段完成後，已完成區間不再更新。

本指標不使用未來資料產生歷史訊號。

免責聲明

本指標僅供教育、研究與盤面分析使用，不構成任何投資建議，也不保證任何交易結果。

使用者應自行完成交易判斷並做好風險管理。

---

## Source Code

````pine
//@version=6
indicator(
     title = "MoChen - Crypto Sessions and D/W/M Opens",
     shorttitle = "MoChen - Sessions+D/W/M",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 200,
     max_bars_back = 1500)

// ============================================================================
// MoChen - Crypto Sessions and D/W/M Opens
// Independent Pine Script v6 implementation for 24/7 cryptocurrency markets.
//
// Design goals:
// 1) Track Asian, London and New York market windows with independent IANA zones.
// 2) Update each active window's range in real time without future data.
// 3) Plot UTC Daily, Weekly and Monthly opening references.
// 4) Merge overlapping UTC D/W/M opens into one visible level using M > W > D priority.
//    Lower-timeframe initials are temporary: W/D becomes W after that UTC day,
//    while M/W/D becomes M/W after the day and M after the overlapping week.
// 5) Keep chart objects bounded through explicit history queues.
// 6) Offer optional "session handoff" context: the next window can be classified
//    as opening above, below or inside the preceding completed session range.
//
// The script does not use request.security(), lookahead or future bars.
// Session boundaries are exact only when the chart timeframe aligns with them.
// ============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// Input groups
// ─────────────────────────────────────────────────────────────────────────────
string G_GENERAL = "1. General"
string G_ASIAN   = "2. Asian Session"
string G_LONDON  = "3. London Session"
string G_NEWYORK = "4. New York Session"
string G_DAILY   = "5. Daily Open"
string G_WEEKLY  = "6. Weekly Open"
string G_MONTHLY = "7. Monthly Open"
string G_LABELS  = "8. Labels and Context"

// ─────────────────────────────────────────────────────────────────────────────
// General
// ─────────────────────────────────────────────────────────────────────────────
bool sessionsEnabled = input.bool(true, "Enable market sessions", group = G_GENERAL, display = display.none)
int maxSessionMinutes = input.int(60, "Show sessions up to timeframe", options = [1, 3, 5, 15, 30, 60, 120, 240], group = G_GENERAL, tooltip = "Session drawings are hidden above this chart timeframe. D/W/M levels remain independent.", display = display.none)
string sessionLineEndMode = input.string("End at session close", "Session line extension", options = ["End at session close", "Extend right"], group = G_GENERAL, display = display.none)
bool mergeOverlappingDwm = input.bool(true, "Merge overlapping D/W/M opens", group = G_GENERAL, tooltip = "When UTC Daily, Weekly and Monthly opens begin on the same bar, only one visible line is drawn. Priority: Monthly > Weekly > Daily. Combined labels only show references that are still current: W/D becomes W after that UTC day, and M/W/D becomes M/W after the day and M after the overlapping week.", display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// Asian session
// ─────────────────────────────────────────────────────────────────────────────
bool asianEnabled = input.bool(true, "Enable", inline = "A1", group = G_ASIAN, display = display.none)
string asianName = input.string("Asian", "Name", inline = "A1", group = G_ASIAN, display = display.none)
string asianHours = input.session("0900-1330", "Hours (Asia/Taipei)", group = G_ASIAN, tooltip = "Uses Asia/Taipei. Default: 09:00-13:30.", display = display.none)
color asianColor = input.color(color.new(color.rgb(225, 180, 45), 90), "Color and range opacity", inline = "A2", group = G_ASIAN, display = display.none)
int asianWidth = input.int(1, "Width", minval = 1, maxval = 4, inline = "A2", group = G_ASIAN, display = display.none)
string asianStyle = input.string("Dotted", "Line style", options = ["Solid", "Dashed", "Dotted"], group = G_ASIAN, display = display.none)
bool asianRange = input.bool(true, "Range fill", inline = "A3", group = G_ASIAN, display = display.none)
bool asianOpen = input.bool(true, "Open", inline = "A4", group = G_ASIAN, display = display.none)
bool asianClose = input.bool(false, "Close", inline = "A4", group = G_ASIAN, display = display.none)
bool asianHigh = input.bool(false, "High", inline = "A4", group = G_ASIAN, display = display.none)
bool asianLow = input.bool(false, "Low", inline = "A4", group = G_ASIAN, display = display.none)
bool asianNameLabel = input.bool(true, "Session name", inline = "A5", group = G_ASIAN, display = display.none)
bool asianPriceLabels = input.bool(false, "Price labels", inline = "A5", group = G_ASIAN, display = display.none)
int asianHistoryLimit = input.int(5, "Completed sessions to keep", minval = 1, maxval = 20, group = G_ASIAN, display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// London session
// ─────────────────────────────────────────────────────────────────────────────
bool londonEnabled = input.bool(true, "Enable", inline = "L1", group = G_LONDON, display = display.none)
string londonName = input.string("London", "Name", inline = "L1", group = G_LONDON, display = display.none)
string londonHours = input.session("0800-1630", "Hours (Europe/London)", group = G_LONDON, tooltip = "Uses Europe/London and automatically follows UK daylight-saving rules.", display = display.none)
color londonColor = input.color(color.new(color.rgb(40, 155, 215), 90), "Color and range opacity", inline = "L2", group = G_LONDON, display = display.none)
int londonWidth = input.int(1, "Width", minval = 1, maxval = 4, inline = "L2", group = G_LONDON, display = display.none)
string londonStyle = input.string("Dotted", "Line style", options = ["Solid", "Dashed", "Dotted"], group = G_LONDON, display = display.none)
bool londonRange = input.bool(true, "Range fill", inline = "L3", group = G_LONDON, display = display.none)
bool londonOpen = input.bool(true, "Open", inline = "L4", group = G_LONDON, display = display.none)
bool londonClose = input.bool(false, "Close", inline = "L4", group = G_LONDON, display = display.none)
bool londonHigh = input.bool(false, "High", inline = "L4", group = G_LONDON, display = display.none)
bool londonLow = input.bool(false, "Low", inline = "L4", group = G_LONDON, display = display.none)
bool londonNameLabel = input.bool(true, "Session name", inline = "L5", group = G_LONDON, display = display.none)
bool londonPriceLabels = input.bool(false, "Price labels", inline = "L5", group = G_LONDON, display = display.none)
int londonHistoryLimit = input.int(5, "Completed sessions to keep", minval = 1, maxval = 20, group = G_LONDON, display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// New York session
// ─────────────────────────────────────────────────────────────────────────────
bool newYorkEnabled = input.bool(true, "Enable", inline = "N1", group = G_NEWYORK, display = display.none)
string newYorkName = input.string("New York", "Name", inline = "N1", group = G_NEWYORK, display = display.none)
string newYorkHours = input.session("0930-1600", "Hours (America/New_York)", group = G_NEWYORK, tooltip = "Uses America/New_York and automatically follows US daylight-saving rules.", display = display.none)
color newYorkColor = input.color(color.new(color.rgb(225, 85, 75), 90), "Color and range opacity", inline = "N2", group = G_NEWYORK, display = display.none)
int newYorkWidth = input.int(1, "Width", minval = 1, maxval = 4, inline = "N2", group = G_NEWYORK, display = display.none)
string newYorkStyle = input.string("Dotted", "Line style", options = ["Solid", "Dashed", "Dotted"], group = G_NEWYORK, display = display.none)
bool newYorkRange = input.bool(true, "Range fill", inline = "N3", group = G_NEWYORK, display = display.none)
bool newYorkOpen = input.bool(true, "Open", inline = "N4", group = G_NEWYORK, display = display.none)
bool newYorkClose = input.bool(false, "Close", inline = "N4", group = G_NEWYORK, display = display.none)
bool newYorkHigh = input.bool(false, "High", inline = "N4", group = G_NEWYORK, display = display.none)
bool newYorkLow = input.bool(false, "Low", inline = "N4", group = G_NEWYORK, display = display.none)
bool newYorkNameLabel = input.bool(true, "Session name", inline = "N5", group = G_NEWYORK, display = display.none)
bool newYorkPriceLabels = input.bool(false, "Price labels", inline = "N5", group = G_NEWYORK, display = display.none)
int newYorkHistoryLimit = input.int(5, "Completed sessions to keep", minval = 1, maxval = 20, group = G_NEWYORK, display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// Daily / Weekly / Monthly opens
// ─────────────────────────────────────────────────────────────────────────────
bool dailyEnabled = input.bool(true, "Show Daily Open", group = G_DAILY, display = display.none)
string dailyText = input.string("D", "Label", group = G_DAILY, display = display.none)
color dailyColor = input.color(color.rgb(41, 98, 255), "Color", inline = "D1", group = G_DAILY, display = display.none)
int dailyWidth = input.int(1, "Width", minval = 1, maxval = 4, inline = "D1", group = G_DAILY, display = display.none)
string dailyStyle = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = G_DAILY, display = display.none)
string dailyEndMode = input.string("End with period", "Extension", options = ["End with period", "Extend right"], group = G_DAILY, display = display.none)
bool dailyLabel = input.bool(true, "Show label", inline = "D2", group = G_DAILY, display = display.none)
bool dailyPrice = input.bool(false, "Show price", inline = "D2", group = G_DAILY, display = display.none)
int dailyKeep = input.int(1, "Periods to keep", minval = 1, maxval = 30, group = G_DAILY, display = display.none)

bool weeklyEnabled = input.bool(true, "Show Weekly Open", group = G_WEEKLY, display = display.none)
string weeklyText = input.string("W", "Label", group = G_WEEKLY, display = display.none)
color weeklyColor = input.color(color.rgb(0, 188, 212), "Color", inline = "W1", group = G_WEEKLY, display = display.none)
int weeklyWidth = input.int(2, "Width", minval = 1, maxval = 4, inline = "W1", group = G_WEEKLY, display = display.none)
string weeklyStyle = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = G_WEEKLY, display = display.none)
string weeklyEndMode = input.string("End with period", "Extension", options = ["End with period", "Extend right"], group = G_WEEKLY, display = display.none)
bool weeklyLabel = input.bool(true, "Show label", inline = "W2", group = G_WEEKLY, display = display.none)
bool weeklyPrice = input.bool(false, "Show price", inline = "W2", group = G_WEEKLY, display = display.none)
int weeklyKeep = input.int(1, "Periods to keep", minval = 1, maxval = 30, group = G_WEEKLY, display = display.none)

bool monthlyEnabled = input.bool(true, "Show Monthly Open", group = G_MONTHLY, display = display.none)
string monthlyText = input.string("M", "Label", group = G_MONTHLY, display = display.none)
color monthlyColor = input.color(color.rgb(255, 235, 59), "Color", inline = "M1", group = G_MONTHLY, display = display.none)
int monthlyWidth = input.int(3, "Width", minval = 1, maxval = 4, inline = "M1", group = G_MONTHLY, display = display.none)
string monthlyStyle = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = G_MONTHLY, display = display.none)
string monthlyEndMode = input.string("End with period", "Extension", options = ["End with period", "Extend right"], group = G_MONTHLY, display = display.none)
bool monthlyLabel = input.bool(true, "Show label", inline = "M2", group = G_MONTHLY, display = display.none)
bool monthlyPrice = input.bool(false, "Show price", inline = "M2", group = G_MONTHLY, display = display.none)
int monthlyKeep = input.int(1, "Periods to keep", minval = 1, maxval = 30, group = G_MONTHLY, display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// Labels and original session-handoff context
// ─────────────────────────────────────────────────────────────────────────────
string labelSizeInput = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = G_LABELS, display = display.none)
int labelBgTransparency = input.int(100, "Label background transparency", minval = 0, maxval = 100, group = G_LABELS, display = display.none)
bool showHandoffContext = input.bool(false, "Show session handoff context", group = G_LABELS, tooltip = "At London and New York opens, classify the opening price as Above, Inside or Below the preceding completed session range.", display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
f_style(string value) =>
    switch value
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Normal" => size.normal
        "Large" => size.large
        => size.small

f_text(string prefix, float value, bool showValue) =>
    showValue ? prefix + "  " + str.tostring(value, format.mintick) : prefix

f_opaque(color source) =>
    color.rgb(color.r(source), color.g(source), color.b(source))

f_handoff(float openingPrice, float previousHigh, float previousLow, string previousName) =>
    string result = ""
    if not na(previousHigh) and not na(previousLow)
        result := openingPrice > previousHigh ? "Above " + previousName : openingPrice < previousLow ? "Below " + previousName : "Inside " + previousName
    result

// ─────────────────────────────────────────────────────────────────────────────
// Drawing records and bounded queues
// ─────────────────────────────────────────────────────────────────────────────
type WindowRuntime
    float openValue = na
    float highValue = na
    float lowValue = na
    float closeValue = na
    int leftTime = na
    int rightTime = na
    line openGuide = na
    line closeGuide = na
    line highGuide = na
    line lowGuide = na
    line rangeTop = na
    line rangeBottom = na
    box rangeFill = na
    label titleTag = na
    label openTag = na
    label closeTag = na
    label highTag = na
    label lowTag = na
    label handoffTag = na


type WindowArchive
    line openGuide = na
    line closeGuide = na
    line highGuide = na
    line lowGuide = na
    line rangeTop = na
    line rangeBottom = na
    box rangeFill = na
    label titleTag = na
    label openTag = na
    label closeTag = na
    label highTag = na
    label lowTag = na
    label handoffTag = na


type PeriodArchive
    line guide = na
    label tag = na

f_delete_window(WindowArchive item) =>
    if not na(item.openGuide)
        line.delete(item.openGuide)
    if not na(item.closeGuide)
        line.delete(item.closeGuide)
    if not na(item.highGuide)
        line.delete(item.highGuide)
    if not na(item.lowGuide)
        line.delete(item.lowGuide)
    if not na(item.rangeTop)
        line.delete(item.rangeTop)
    if not na(item.rangeBottom)
        line.delete(item.rangeBottom)
    if not na(item.rangeFill)
        box.delete(item.rangeFill)
    if not na(item.titleTag)
        label.delete(item.titleTag)
    if not na(item.openTag)
        label.delete(item.openTag)
    if not na(item.closeTag)
        label.delete(item.closeTag)
    if not na(item.highTag)
        label.delete(item.highTag)
    if not na(item.lowTag)
        label.delete(item.lowTag)
    if not na(item.handoffTag)
        label.delete(item.handoffTag)

f_store_window(WindowRuntime runtime, array<WindowArchive> queue, int capacity) =>
    WindowArchive item = WindowArchive.new()
    item.openGuide := runtime.openGuide
    item.closeGuide := runtime.closeGuide
    item.highGuide := runtime.highGuide
    item.lowGuide := runtime.lowGuide
    item.rangeTop := runtime.rangeTop
    item.rangeBottom := runtime.rangeBottom
    item.rangeFill := runtime.rangeFill
    item.titleTag := runtime.titleTag
    item.openTag := runtime.openTag
    item.closeTag := runtime.closeTag
    item.highTag := runtime.highTag
    item.lowTag := runtime.lowTag
    item.handoffTag := runtime.handoffTag
    array.push(queue, item)
    while array.size(queue) > capacity
        WindowArchive oldest = array.shift(queue)
        f_delete_window(oldest)

f_delete_period(PeriodArchive item) =>
    if not na(item.guide)
        line.delete(item.guide)
    if not na(item.tag)
        label.delete(item.tag)

f_trim_periods(array<PeriodArchive> queue, int capacity) =>
    while array.size(queue) > capacity
        PeriodArchive oldest = array.shift(queue)
        f_delete_period(oldest)

// ─────────────────────────────────────────────────────────────────────────────
// Session engine
// ─────────────────────────────────────────────────────────────────────────────
method startWindow(
     WindowRuntime self,
     string windowName,
     color baseColor,
     int guideWidth,
     string guideStyle,
     bool drawRange,
     bool drawOpen,
     bool drawHigh,
     bool drawLow,
     bool drawName,
     bool drawPriceLabels,
     string handoffText) =>

    int barEnd = na(time_close) ? time : time_close
    color ink = f_opaque(baseColor)
    color labelBg = color.new(color.black, labelBgTransparency)
    selectedStyle = f_style(guideStyle)

    self.openValue := open
    self.highValue := high
    self.lowValue := low
    self.closeValue := close
    self.leftTime := time
    self.rightTime := barEnd

    self.openGuide := na
    self.closeGuide := na
    self.highGuide := na
    self.lowGuide := na
    self.rangeTop := na
    self.rangeBottom := na
    self.rangeFill := na
    self.titleTag := na
    self.openTag := na
    self.closeTag := na
    self.highTag := na
    self.lowTag := na
    self.handoffTag := na

    if drawRange
        self.rangeFill := box.new(self.leftTime, self.highValue, barEnd, self.lowValue, xloc = xloc.bar_time, border_color = color.new(baseColor, 100), bgcolor = baseColor)
        self.rangeTop := line.new(self.leftTime, self.highValue, barEnd, self.highValue, xloc = xloc.bar_time, color = color.new(ink, 15), width = 1)
        self.rangeBottom := line.new(self.leftTime, self.lowValue, barEnd, self.lowValue, xloc = xloc.bar_time, color = color.new(ink, 15), width = 1)

    if drawOpen
        self.openGuide := line.new(self.leftTime, self.openValue, barEnd, self.openValue, xloc = xloc.bar_time, color = ink, style = selectedStyle, width = guideWidth)
        if drawPriceLabels
            self.openTag := label.new(barEnd, self.openValue, f_text(windowName + " O", self.openValue, true), xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = labelBg, textcolor = ink, size = f_size(labelSizeInput))

    if drawHigh
        self.highGuide := line.new(self.leftTime, self.highValue, barEnd, self.highValue, xloc = xloc.bar_time, color = ink, style = selectedStyle, width = guideWidth)
        if drawPriceLabels
            self.highTag := label.new(barEnd, self.highValue, f_text(windowName + " H", self.highValue, true), xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = labelBg, textcolor = ink, size = f_size(labelSizeInput))

    if drawLow
        self.lowGuide := line.new(self.leftTime, self.lowValue, barEnd, self.lowValue, xloc = xloc.bar_time, color = ink, style = selectedStyle, width = guideWidth)
        if drawPriceLabels
            self.lowTag := label.new(barEnd, self.lowValue, f_text(windowName + " L", self.lowValue, true), xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = labelBg, textcolor = ink, size = f_size(labelSizeInput))

    if drawName
        self.titleTag := label.new(self.leftTime, self.highValue, windowName, xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_down, color = labelBg, textcolor = ink, size = f_size(labelSizeInput))

    if showHandoffContext and str.length(handoffText) > 0
        self.handoffTag := label.new(self.leftTime, self.openValue, handoffText, xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_up, color = labelBg, textcolor = ink, size = size.tiny)

method updateWindow(WindowRuntime self, string windowName, bool drawPriceLabels) =>
    int barEnd = na(time_close) ? time : time_close
    self.highValue := math.max(self.highValue, high)
    self.lowValue := math.min(self.lowValue, low)
    self.closeValue := close
    self.rightTime := barEnd

    if not na(self.rangeFill)
        box.set_top(self.rangeFill, self.highValue)
        box.set_bottom(self.rangeFill, self.lowValue)
        box.set_right(self.rangeFill, barEnd)
    if not na(self.rangeTop)
        line.set_xy1(self.rangeTop, self.leftTime, self.highValue)
        line.set_xy2(self.rangeTop, barEnd, self.highValue)
    if not na(self.rangeBottom)
        line.set_xy1(self.rangeBottom, self.leftTime, self.lowValue)
        line.set_xy2(self.rangeBottom, barEnd, self.lowValue)
    if not na(self.openGuide)
        line.set_x2(self.openGuide, barEnd)
    if not na(self.highGuide)
        line.set_xy1(self.highGuide, self.leftTime, self.highValue)
        line.set_xy2(self.highGuide, barEnd, self.highValue)
    if not na(self.lowGuide)
        line.set_xy1(self.lowGuide, self.leftTime, self.lowValue)
        line.set_xy2(self.lowGuide, barEnd, self.lowValue)
    if not na(self.titleTag)
        label.set_x(self.titleTag, int(math.avg(self.leftTime, barEnd)))
        label.set_y(self.titleTag, self.highValue)
    if drawPriceLabels and not na(self.openTag)
        label.set_x(self.openTag, barEnd)
        label.set_text(self.openTag, f_text(windowName + " O", self.openValue, true))
    if drawPriceLabels and not na(self.highTag)
        label.set_x(self.highTag, barEnd)
        label.set_y(self.highTag, self.highValue)
        label.set_text(self.highTag, f_text(windowName + " H", self.highValue, true))
    if drawPriceLabels and not na(self.lowTag)
        label.set_x(self.lowTag, barEnd)
        label.set_y(self.lowTag, self.lowValue)
        label.set_text(self.lowTag, f_text(windowName + " L", self.lowValue, true))

method finishWindow(
     WindowRuntime self,
     string windowName,
     color baseColor,
     int guideWidth,
     string guideStyle,
     bool drawClose,
     bool drawPriceLabels,
     bool extendRight,
     array<WindowArchive> queue,
     int capacity) =>

    int endTime = na(time_close[1]) ? time[1] : time_close[1]
    color ink = f_opaque(baseColor)
    color labelBg = color.new(color.black, labelBgTransparency)
    self.closeValue := close[1]
    self.rightTime := endTime

    if not na(self.rangeFill)
        box.set_right(self.rangeFill, endTime)
    if not na(self.rangeTop)
        line.set_x2(self.rangeTop, endTime)
    if not na(self.rangeBottom)
        line.set_x2(self.rangeBottom, endTime)
    if not na(self.openGuide)
        line.set_x2(self.openGuide, endTime)
    if not na(self.highGuide)
        line.set_x2(self.highGuide, endTime)
    if not na(self.lowGuide)
        line.set_x2(self.lowGuide, endTime)

    if drawClose
        self.closeGuide := line.new(self.leftTime, self.closeValue, endTime, self.closeValue, xloc = xloc.bar_time, color = ink, style = f_style(guideStyle), width = guideWidth)
        if drawPriceLabels
            self.closeTag := label.new(endTime, self.closeValue, f_text(windowName + " C", self.closeValue, true), xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = labelBg, textcolor = ink, size = f_size(labelSizeInput))

    if extendRight
        if not na(self.openGuide)
            line.set_extend(self.openGuide, extend.right)
        if not na(self.closeGuide)
            line.set_extend(self.closeGuide, extend.right)
        if not na(self.highGuide)
            line.set_extend(self.highGuide, extend.right)
        if not na(self.lowGuide)
            line.set_extend(self.lowGuide, extend.right)

    f_store_window(self, queue, capacity)

// ─────────────────────────────────────────────────────────────────────────────
// Session state detection
// ─────────────────────────────────────────────────────────────────────────────
float chartMinutes = timeframe.in_seconds() / 60.0
bool sessionTfAllowed = timeframe.isintraday and chartMinutes <= maxSessionMinutes
bool sessionEngineOn = sessionsEnabled and sessionTfAllowed
bool extendSessionRight = sessionLineEndMode == "Extend right"

string asianSessionSpec = asianHours + ":1234567"
string londonSessionSpec = londonHours + ":1234567"
string newYorkSessionSpec = newYorkHours + ":1234567"

bool inAsian = sessionEngineOn and asianEnabled and not na(time(timeframe.period, asianSessionSpec, "Asia/Taipei"))
bool inLondon = sessionEngineOn and londonEnabled and not na(time(timeframe.period, londonSessionSpec, "Europe/London"))
bool inNewYork = sessionEngineOn and newYorkEnabled and not na(time(timeframe.period, newYorkSessionSpec, "America/New_York"))

bool asianStarts = inAsian and not inAsian[1]
bool londonStarts = inLondon and not inLondon[1]
bool newYorkStarts = inNewYork and not inNewYork[1]
bool asianEnds = not inAsian and inAsian[1]
bool londonEnds = not inLondon and inLondon[1]
bool newYorkEnds = not inNewYork and inNewYork[1]

var WindowRuntime asianWindow = WindowRuntime.new()
var WindowRuntime londonWindow = WindowRuntime.new()
var WindowRuntime newYorkWindow = WindowRuntime.new()
var array<WindowArchive> asianQueue = array.new<WindowArchive>()
var array<WindowArchive> londonQueue = array.new<WindowArchive>()
var array<WindowArchive> newYorkQueue = array.new<WindowArchive>()

var float lastAsianHigh = na
var float lastAsianLow = na
var float lastLondonHigh = na
var float lastLondonLow = na

string londonContext = f_handoff(open, lastAsianHigh, lastAsianLow, asianName)
string newYorkContext = f_handoff(open, lastLondonHigh, lastLondonLow, londonName)

if asianStarts
    asianWindow.startWindow(asianName, asianColor, asianWidth, asianStyle, asianRange, asianOpen, asianHigh, asianLow, asianNameLabel, asianPriceLabels, "")
if inAsian
    asianWindow.updateWindow(asianName, asianPriceLabels)
if asianEnds
    asianWindow.finishWindow(asianName, asianColor, asianWidth, asianStyle, asianClose, asianPriceLabels, extendSessionRight, asianQueue, asianHistoryLimit)
    lastAsianHigh := asianWindow.highValue
    lastAsianLow := asianWindow.lowValue

if londonStarts
    londonWindow.startWindow(londonName, londonColor, londonWidth, londonStyle, londonRange, londonOpen, londonHigh, londonLow, londonNameLabel, londonPriceLabels, londonContext)
if inLondon
    londonWindow.updateWindow(londonName, londonPriceLabels)
if londonEnds
    londonWindow.finishWindow(londonName, londonColor, londonWidth, londonStyle, londonClose, londonPriceLabels, extendSessionRight, londonQueue, londonHistoryLimit)
    lastLondonHigh := londonWindow.highValue
    lastLondonLow := londonWindow.lowValue

if newYorkStarts
    newYorkWindow.startWindow(newYorkName, newYorkColor, newYorkWidth, newYorkStyle, newYorkRange, newYorkOpen, newYorkHigh, newYorkLow, newYorkNameLabel, newYorkPriceLabels, newYorkContext)
if inNewYork
    newYorkWindow.updateWindow(newYorkName, newYorkPriceLabels)
if newYorkEnds
    newYorkWindow.finishWindow(newYorkName, newYorkColor, newYorkWidth, newYorkStyle, newYorkClose, newYorkPriceLabels, extendSessionRight, newYorkQueue, newYorkHistoryLimit)

// ─────────────────────────────────────────────────────────────────────────────
// Period-open engine. All period boundaries are anchored to UTC.
// ─────────────────────────────────────────────────────────────────────────────
f_process_period(
     bool enabled,
     bool permitted,
     bool begins,
     bool renderAtStart,
     string tagText,
     color guideColor,
     int guideWidth,
     string guideStyle,
     string endMode,
     bool showTag,
     bool showPrice,
     int keepCount,
     float currentValue,
     line currentGuide,
     label currentTag,
     array<PeriodArchive> queue) =>

    float nextValue = currentValue
    line nextGuide = currentGuide
    label nextTag = currentTag

    if enabled and permitted
        int barEnd = na(time_close) ? time : time_close
        if begins
            nextValue := open
            nextGuide := na
            nextTag := na

            // Lower-priority D/W objects are intentionally not created when the
            // same UTC opening price is represented by a higher timeframe.
            if renderAtStart
                bool extendRight = endMode == "Extend right"
                nextGuide := line.new(time, nextValue, barEnd, nextValue, xloc = xloc.bar_time, extend = extendRight ? extend.right : extend.none, color = guideColor, style = f_style(guideStyle), width = guideWidth)
                if showTag
                    nextTag := label.new(barEnd, nextValue, f_text(tagText, nextValue, showPrice), xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, labelBgTransparency), textcolor = guideColor, size = f_size(labelSizeInput))

            // Push one record for every completed period, including merged periods.
            // This keeps each period's retention count correct without duplicating
            // visible lines at the same price.
            PeriodArchive saved = PeriodArchive.new()
            saved.guide := nextGuide
            saved.tag := nextTag
            array.push(queue, saved)
            f_trim_periods(queue, keepCount)
        else
            if not na(nextGuide) and endMode == "End with period"
                line.set_x2(nextGuide, barEnd)
            if not na(nextTag)
                label.set_x(nextTag, barEnd)
                label.set_y(nextTag, nextValue)
                // Keep merged labels synchronized with the references that are
                // still active. For example, W/D automatically becomes W on
                // the next UTC day without recreating the weekly line.
                label.set_text(nextTag, f_text(tagText, nextValue, showPrice))

    [nextValue, nextGuide, nextTag]

string PERIOD_TZ = "UTC"
int utcDateKey = year(time, PERIOD_TZ) * 10000 + month(time, PERIOD_TZ) * 100 + dayofmonth(time, PERIOD_TZ)
int utcMonthKey = year(time, PERIOD_TZ) * 100 + month(time, PERIOD_TZ)
int utcMidnight = timestamp(PERIOD_TZ, year(time, PERIOD_TZ), month(time, PERIOD_TZ), dayofmonth(time, PERIOD_TZ), 0, 0)
int daysAfterMonday = (dayofweek(time, PERIOD_TZ) - dayofweek.monday + 7) % 7
int utcWeekKey = utcMidnight - daysAfterMonday * 86400000

bool dailyPermitted = timeframe.isintraday or timeframe.isdaily
bool weeklyPermitted = timeframe.isintraday or timeframe.isdaily or timeframe.isweekly
bool monthlyPermitted = timeframe.isintraday or timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly

// Do not invent a period open from an arbitrary first historical bar. A new
// period is recognized only when its UTC calendar key actually changes.
bool dailyBegins = dailyPermitted and not na(utcDateKey[1]) and utcDateKey != utcDateKey[1]
bool weeklyBegins = weeklyPermitted and not na(utcWeekKey[1]) and utcWeekKey != utcWeekKey[1]
bool monthlyBegins = monthlyPermitted and not na(utcMonthKey[1]) and utcMonthKey != utcMonthKey[1]

var float dailyValue = na
var line dailyGuide = na
var label dailyTag = na
var array<PeriodArchive> dailyQueue = array.new<PeriodArchive>()

var float weeklyValue = na
var line weeklyGuide = na
var label weeklyTag = na
var array<PeriodArchive> weeklyQueue = array.new<PeriodArchive>()

var float monthlyValue = na
var line monthlyGuide = na
var label monthlyTag = na
var array<PeriodArchive> monthlyQueue = array.new<PeriodArchive>()

// D/W/M overlap policy:
// - Draw one visible line when multiple UTC opens start on the same bar.
// - Use the larger timeframe's style: Monthly > Weekly > Daily.
// - Keep all period engines active internally so retention remains correct.
// - A merged suffix remains visible only while that lower period is current.
//   Examples:
//     W/D   -> W on the next UTC day.
//     M/D   -> M on the next UTC day.
//     M/W/D -> M/W on the next UTC day, then M on the next UTC week.
bool monthlyStartsVisible = monthlyEnabled and monthlyPermitted and monthlyBegins
bool weeklyStartsVisible = weeklyEnabled and weeklyPermitted and weeklyBegins
bool dailyStartsVisible = dailyEnabled and dailyPermitted and dailyBegins

bool renderMonthly = true
bool renderWeekly = not (mergeOverlappingDwm and weeklyBegins and monthlyStartsVisible)
bool renderDaily = not (mergeOverlappingDwm and dailyBegins and (monthlyStartsVisible or weeklyStartsVisible))

// Track which lower-timeframe references are currently represented by the
// higher-timeframe visible line. These flags control label text only; the
// underlying D/W/M period values remain independent.
var bool monthlyCarriesWeekly = false
var bool monthlyCarriesDaily = false
var bool weeklyCarriesDaily = false

if monthlyBegins
    monthlyCarriesWeekly := mergeOverlappingDwm and monthlyStartsVisible and weeklyStartsVisible
    monthlyCarriesDaily := mergeOverlappingDwm and monthlyStartsVisible and dailyStartsVisible
else
    // A new UTC week makes the week that originally overlapped the monthly
    // open historical, so the monthly label no longer carries W.
    if weeklyBegins
        monthlyCarriesWeekly := false
    // A new UTC day makes the day that originally overlapped the monthly open
    // historical, so the monthly label no longer carries D.
    if dailyBegins
        monthlyCarriesDaily := false

if weeklyBegins
    // When Monthly owns the visible line, Weekly has no separate merged label.
    weeklyCarriesDaily := mergeOverlappingDwm and weeklyStartsVisible and not monthlyStartsVisible and dailyStartsVisible
else if dailyBegins
    weeklyCarriesDaily := false

string monthlyDisplayText = monthlyText
if monthlyCarriesWeekly
    monthlyDisplayText := monthlyDisplayText + "/" + weeklyText
if monthlyCarriesDaily
    monthlyDisplayText := monthlyDisplayText + "/" + dailyText

string weeklyDisplayText = weeklyText
if weeklyCarriesDaily
    weeklyDisplayText := weeklyDisplayText + "/" + dailyText

[dailyValueNext, dailyGuideNext, dailyTagNext] = f_process_period(dailyEnabled, dailyPermitted, dailyBegins, renderDaily, dailyText, dailyColor, dailyWidth, dailyStyle, dailyEndMode, dailyLabel, dailyPrice, dailyKeep, dailyValue, dailyGuide, dailyTag, dailyQueue)
dailyValue := dailyValueNext
dailyGuide := dailyGuideNext
dailyTag := dailyTagNext

[weeklyValueNext, weeklyGuideNext, weeklyTagNext] = f_process_period(weeklyEnabled, weeklyPermitted, weeklyBegins, renderWeekly, weeklyDisplayText, weeklyColor, weeklyWidth, weeklyStyle, weeklyEndMode, weeklyLabel, weeklyPrice, weeklyKeep, weeklyValue, weeklyGuide, weeklyTag, weeklyQueue)
weeklyValue := weeklyValueNext
weeklyGuide := weeklyGuideNext
weeklyTag := weeklyTagNext

[monthlyValueNext, monthlyGuideNext, monthlyTagNext] = f_process_period(monthlyEnabled, monthlyPermitted, monthlyBegins, renderMonthly, monthlyDisplayText, monthlyColor, monthlyWidth, monthlyStyle, monthlyEndMode, monthlyLabel, monthlyPrice, monthlyKeep, monthlyValue, monthlyGuide, monthlyTag, monthlyQueue)
monthlyValue := monthlyValueNext
monthlyGuide := monthlyGuideNext
monthlyTag := monthlyTagNext
````
