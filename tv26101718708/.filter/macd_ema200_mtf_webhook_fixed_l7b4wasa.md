# MACD + EMA200 MTF - WEBHOOK FIXED

- url: https://www.tradingview.com/script/l7B4WaSa-MACD-EMA200-MTF-WEBHOOK-FIXED/
- type: strategy
- pine_id: PUB;74a16309dbbb4b80ac90562628f9d872
- version: 61.0

## Description

Hi guys, works best with USDCHF

Default settings fit for me, you can tweak how much you want.

With default settings works well for 15min and 1min time-frame, for other time-frames, you need to tweak.

## Source Code

````pine
//@version=6
strategy(
  'MACD + EMA200 MTF - DAYTRADING OPTIMIZED [NO REPAINT]',
  overlay                 = true,
  initial_capital         = 10000,
  default_qty_value       = 100,
  commission_type         = strategy.commission.percent,
  commission_value        = 0,
  process_orders_on_close = true,
  calc_on_every_tick      = true,
  max_labels_count        = 500
)

// ═══════════════════════════════════════════════════════════
//  TABLE OF CONTENTS
// ═══════════════════════════════════════════════════════════
//   1.  Inputs
//   2.  Per-pair resolution (trading hours / pip value / spread)
//   3.  Shared functions
//   4.  State variables
//   5.  Time & calendar filters
//   6.  Indicators
//   7.  Entry conditions
//   8.  Trade entry execution
//   9.  Breakeven trigger + exit monitoring
//  10.  EOD forced close (Friday / optional daily)
//  11.  Position reset
//  12.  Chart line management
//  13.  Info table
// ═══════════════════════════════════════════════════════════
// Supports USDCHF and AUDJPY only.


// ═══════════════════════════════════════════════════════════
//  1. INPUTS
// ═══════════════════════════════════════════════════════════

// ── Pip values (update weekly via myfxbook pip calculator) ─
pipValUSDCHF = input.float(10.899, "USDCHF Pip Value (€/pip, 1 lot)", group="Pip Values", step=0.001)
pipValAUDJPY = input.float(5.414,  "AUDJPY Pip Value (€/pip, 1 lot)", group="Pip Values", step=0.001)

// ── Spread (avg, pips) — sizes the live SL/BE stop offset, not lot sizing ──
spreadAUDJPY = input.float(2.2, "AUDJPY Avg Spread (pips)", group="Spread", step=0.1, minval=0.0)
spreadUSDCHF = input.float(1.6, "USDCHF Avg Spread (pips)", group="Spread", step=0.1, minval=0.0)

// ── Webhook ───────────────────────────────────────────────
webhookUsername = input.string("",       "Webhook Username", group="Webhook", inline="wh1")
webhookApiKey   = input.string("",       "API Key",          group="Webhook", inline="wh1", display=display.none)
tradingPair     = input.string("USDCHF", "Trading Pair",     group="Webhook", options=["USDCHF", "AUDJPY"])

// ── Strategy ──────────────────────────────────────────────
cooldownBars = input.int(5,  "Cooldown After Exit (bars)", minval=1, maxval=20, group="Strategy")

// ── Position sizing ───────────────────────────────────────
sizingMode      = input.string("Fixed Risk Amount", "Sizing Mode", group="Position Sizing",
  options=["Dynamic %", "Fixed Risk Amount", "Fixed Lots"])
accountBalance  = input.float(10000, "Account Balance",   group="Position Sizing", minval=100, maxval=1000000, step=100)
accountCurrency = input.string("EUR", "Account Currency", group="Position Sizing", options=["EUR", "USD"],
  tooltip="USD accounts apply a 0.85 conversion factor to the EUR-based lot calculation.")
riskPercent     = input.float(1.5,   "Risk % per Trade",      group="Position Sizing", minval=0.1, maxval=10, step=0.1)
riskAmount      = input.float(150.0, "Risk Amount per Trade", group="Position Sizing", minval=1, maxval=100000, step=10)
fixedLotSize    = input.float(0.40,  "Fixed Lot Size",        group="Position Sizing", minval=0.01, maxval=100, step=0.01)

// ── Trend ─────────────────────────────────────────────────
emaLength       = input.int(200,  "EMA Length",                          minval=1,             group="Trend")

// ── MACD ──────────────────────────────────────────────────
macdFast   = input.int(12, "MACD Fast",   minval=1, group="MACD")
macdSlow   = input.int(26, "MACD Slow",   minval=1, group="MACD")
macdSignal = input.int(9,  "MACD Signal", minval=1, group="MACD")

// ── Multi-timeframe ───────────────────────────────────────
minTFAlign = input.int(3, "Min Timeframes Aligned", minval=3, maxval=6, group="MTF")

// ── Risk ──────────────────────────────────────────────────
atrLen       = input.int(14,       "ATR Period",                   minval=1,             group="Risk")
atrSmooth    = input.string("RMA", "ATR Smoothing",                options=["RMA","SMA","EMA","WMA"], group="Risk")
atrMult      = input.float(1.5,    "ATR Multiplier",               minval=0.5, maxval=3.0, step=0.1, group="Risk")
minSlPips    = input.float(10.0,   "Min SL Distance (Pips)",       minval=5,   maxval=30, step=1, group="Risk")
tpRatio      = input.float(2.0,    "Take Profit (R:R)",            minval=1.0, maxval=6.0, step=0.25, group="Risk")
beAtR        = input.float(1.0,    "Move SL to Breakeven at (R)",  minval=0.5, maxval=4.0, step=0.25, group="Risk")
enableBE     = input.bool(true,    "Enable Breakeven Move",                               group="Risk")

// ── Trading hours ──────────────────────────────────────────
usdchfStartHour  = input.int(7,  "USDCHF Start Hour", minval=0, maxval=23, group="Hours")
usdchfEndHour    = input.int(21, "USDCHF End Hour",   minval=0, maxval=23, group="Hours")
audjpyStartHour  = input.int(7,  "AUDJPY Start Hour", minval=0, maxval=23, group="Hours",
  tooltip="Wide window: AUDJPY trends from both Tokyo and London/NY sessions — narrowing to Tokyo-only hurt PF in testing.")
audjpyEndHour    = input.int(21, "AUDJPY End Hour",   minval=0, maxval=23, group="Hours")
skip0800to0900   = input.bool(true, "Skip 08:00–09:00 Vienna Entries", group="Hours")

// ── Choppiness filter ─────────────────────────────────────
chopLength    = input.int(14,     "Choppiness Length",                   minval=1,               group="Choppiness Filter")
chopUpperBand = input.float(65.0, "CI Upper Threshold (no trade above)", minval=55.0, maxval=80.0, step=1.0, group="Choppiness Filter")
chopLowerBand = input.float(35.0, "CI Lower Threshold (no trade below)", minval=20.0, maxval=45.0, step=1.0, group="Choppiness Filter")


// ═══════════════════════════════════════════════════════════
//  2. PER-PAIR RESOLUTION (trading hours / pip value / spread)
// ═══════════════════════════════════════════════════════════

string pairUpper = str.upper(tradingPair)
bool   isAudjpy  = pairUpper == "AUDJPY"

int resolvedStartMins = isAudjpy ? audjpyStartHour * 60 : usdchfStartHour * 60
int resolvedEndMins   = isAudjpy ? audjpyEndHour   * 60 : usdchfEndHour   * 60
int resolvedEodMins   = 21 * 60  // Friday-only forced close, both pairs

getPipValue() =>
    isAudjpy ? pipValAUDJPY : pipValUSDCHF

getSpreadPips() =>
    isAudjpy ? spreadAUDJPY : spreadUSDCHF


// ═══════════════════════════════════════════════════════════
//  3. SHARED FUNCTIONS
// ═══════════════════════════════════════════════════════════

calcMA(float src, int len) =>
    atrSmooth == "RMA" ? ta.rma(src, len) :
     atrSmooth == "SMA" ? ta.sma(src, len) :
     atrSmooth == "EMA" ? ta.ema(src, len) :
     ta.wma(src, len)

calculateLotSize(float entry, float sl) =>
    float pipValueEUR = getPipValue()
    float pipFactor   = isAudjpy ? 100.0 : 10000.0
    float slPips      = math.abs(sl - entry) * pipFactor
    float currencyAdj = accountCurrency == "USD" ? 0.85 : 1.0
    if sizingMode == "Dynamic %"
        float riskEUR = accountBalance * (riskPercent / 100) * currencyAdj
        math.max(0.01, math.round((riskEUR / (slPips * pipValueEUR)) * 100) / 100)
    else if sizingMode == "Fixed Risk Amount"
        math.max(0.01, math.round(((riskAmount * currencyAdj) / (slPips * pipValueEUR)) * 100) / 100)
    else
        math.max(0.01, math.round(fixedLotSize * 100) / 100)

buildAlert(string action, float size, float slVal, float tpVal, float beVal) =>
    string header = '{"username":"' + webhookUsername + '","api_key":"' + webhookApiKey +
      '","broker":"metatrader","account_type":"real","symbol":"' + tradingPair + '"'

    string body = ''
    if action == "close buy" or action == "close sell"
        body := header + ',"action":"' + action + '","execution_mode":"mt_native"}'
    else
        string bePart = ''
        if enableBE and not na(beVal)
            bePart := ',"breakeven_price":' + str.tostring(beVal, format.mintick)
        body := header + ',"action":"' + action + '","size":' + str.tostring(size, '#.##') +
          ',"stop_loss":' + str.tostring(slVal, format.mintick) +
          ',"take_profit":' + str.tostring(tpVal, format.mintick) +
          bePart + ',"execution_mode":"mt_native"}'

    body

calcEntryLevels(bool isLong, float atrVal, float pipSizeVal) =>
    int   dir          = isLong ? 1 : -1
    float candidateSL  = isLong
      ? math.min(low[0], low[1]) - atrVal * atrMult
      : math.max(high[0], high[1]) + atrVal * atrMult
    float slDist       = math.abs(close - candidateSL)
    float riskDistPips = slDist / pipSizeVal
    bool  slValid      = riskDistPips >= minSlPips

    float candTP = close + dir * riskDistPips * tpRatio * pipSizeVal
    float candBE = close + dir * riskDistPips * beAtR   * pipSizeVal
    [slValid, candidateSL, candTP, candBE]

easterMonthDay(int y) =>
    int a = y % 19
    int b = y / 100
    int c = y % 100
    int d = b / 4
    int e = b % 4
    int f = (b + 8) / 25
    int g = (b - f + 1) / 3
    int h = (19 * a + b - d - g + 15) % 30
    int i = c / 4
    int k = c % 4
    int l = (32 + 2 * e + 2 * i - h - k) % 7
    int m = (a + 11 * h + 22 * l) / 451
    int easterMonth = (h + l - 7 * m + 114) / 31
    int easterDay   = ((h + l - 7 * m + 114) % 31) + 1
    [easterMonth, easterDay]


// ═══════════════════════════════════════════════════════════
//  4. STATE VARIABLES
// ═══════════════════════════════════════════════════════════

var float  entryPrice       = na
var float  slPrice          = na
var float  tpPrice          = na
var float  beTriggerPrice   = na
var float  totalLots        = na
var int    tradeEntryBar    = na
var int    lastExitBar      = na
var string currentDirection = na
var bool   exitAlertSent    = false

var bool   beTriggered      = false
var float  preBeSlPrice     = na   // original SL saved at BE-trigger, before slPrice is overwritten

var bool   slHitToday = false
var int    lastSlDay  = na

var int easterYear      = na
var int easterDayOfYear = na

var int countWins = 0
var int countBE   = 0
var int countSL   = 0

var line entryLine = na
var line slLine    = na
var line tpLine    = na
var line beLine    = na

var table tradeTable = table.new(
  position.top_right, 2, 8,
  border_width=2, border_color=color.blue,
  frame_color=color.blue, frame_width=2
)


// ═══════════════════════════════════════════════════════════
//  5. TIME & CALENDAR FILTERS
// ═══════════════════════════════════════════════════════════

int  vTime      = hour(time,       "Europe/Vienna") * 60 + minute(time,       "Europe/Vienna")
int  vTimeClose = hour(time_close, "Europe/Vienna") * 60 + minute(time_close, "Europe/Vienna")
bool validTime  = vTimeClose >= resolvedStartMins and vTimeClose <= resolvedEndMins
bool inCooldown = not na(lastExitBar) and (bar_index - lastExitBar) < cooldownBars

bool skip0800to0900Vienna = skip0800to0900 and vTime >= 8 * 60 and vTime < 9 * 60

int  curYear   = year(time)
int  curMonth  = month(time)
int  curDay    = dayofmonth(time)
int  curDow    = dayofweek(time)
bool isFriday  = curDow == dayofweek.friday

if curYear != easterYear
    [eMonth, eDay] = easterMonthDay(curYear)
    easterYear      := curYear
    easterDayOfYear := (timestamp(curYear, eMonth, eDay, 0, 0) - timestamp(curYear, 1, 1, 0, 0)) / 86400000

int curDayOfYear   = (timestamp(curYear, curMonth, curDay, 0, 0) - timestamp(curYear, 1, 1, 0, 0)) / 86400000
int daysFromEaster = curDayOfYear - easterDayOfYear

bool avoidNewYear      = curMonth == 1  and curDay <= 3
bool avoidChristmas    = curMonth == 12 and curDay >= 24
bool avoidSummer       = curMonth == 8  and curDay >= 10 and curDay <= 25
bool avoidMayDay       = (curMonth == 4 and curDay >= 29) or (curMonth == 5 and curDay <= 5)
bool avoidEasterWide   = daysFromEaster >= -3 and daysFromEaster <= 4
bool avoidThanksgiving = curMonth == 11 and curDay >= 22 and curDay <= 29 and (curDow == dayofweek.thursday or curDow == dayofweek.friday)
bool avoidMemorialDay  = curMonth == 5  and curDay >= 25 and curDow == dayofweek.monday
bool avoidLaborDay     = curMonth == 9  and curDay <= 7  and curDow == dayofweek.monday
bool avoidQuarterEnd   = (curMonth == 3 or curMonth == 6 or curMonth == 9 or curMonth == 12) and curDay >= 29
bool avoidNFP          = isFriday and curDay <= 7 and vTime >= 14 * 60 and vTime <= 16 * 60
bool avoidJPYFiscalYearEnd = curMonth == 3 and curDay >= 29

bool avoidPeriodAUDJPY = avoidNewYear or avoidChristmas or avoidSummer or avoidMayDay or avoidJPYFiscalYearEnd
bool avoidPeriodUSDCHF = avoidEasterWide or avoidThanksgiving or avoidMemorialDay or avoidLaborDay or avoidChristmas or avoidNewYear or avoidNFP or avoidQuarterEnd

bool avoidPeriod = isAudjpy ? avoidPeriodAUDJPY : avoidPeriodUSDCHF

int todayKey = year(time) * 10000 + curMonth * 100 + curDay
if not na(lastSlDay) and todayKey != lastSlDay
    slHitToday := false


// ═══════════════════════════════════════════════════════════
//  6. INDICATORS
// ═══════════════════════════════════════════════════════════

float chopRange    = ta.highest(chopLength) - ta.lowest(chopLength)
float ci           = chopRange > 0 ? 100 * math.log10(math.sum(ta.atr(1), chopLength) / chopRange) / math.log10(chopLength) : na
bool  chopFilterOK = not na(ci) and ci >= chopLowerBand and ci <= chopUpperBand

float ema        = ta.ema(close, emaLength)
bool  priceAbove = close > ema

bool consistentUp   = true
bool consistentDown = true
int[] lookbackPeriods = array.from(5, 10, 15, 20, 30, 40, 50)
for i = 0 to 6
    int lb         = array.get(lookbackPeriods, i)
    consistentUp   := consistentUp   and close[lb] > ema[lb]
    consistentDown := consistentDown and close[lb] < ema[lb]

color emaColor = consistentUp   and     priceAbove ? color.green :
                 consistentDown and not priceAbove ? color.red   :
                 color.blue

plot(ema, "EMA 200", emaColor, 2)

getTrend(simple string tf) =>
    request.security(syminfo.tickerid, tf, close > ta.ema(close, emaLength),
      lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

int bullTFs =
  (close > ema      ? 1 : 0) + (getTrend("30")  ? 1 : 0) +
  (getTrend("60")   ? 1 : 0) + (getTrend("120") ? 1 : 0) +
  (getTrend("240")  ? 1 : 0) + (getTrend("D")   ? 1 : 0)
int bearTFs = 6 - bullTFs

[macdLine, signalLine, _] = ta.macd(close, macdFast, macdSlow, macdSignal)
bool macdBullCross = ta.crossover(macdLine,  signalLine)
bool macdBearCross = ta.crossunder(macdLine, signalLine)

float atr     = calcMA(ta.tr(true), atrLen)
float pipSize = syminfo.mintick * 10

float spreadPips  = getSpreadPips()
float spreadPrice = spreadPips * pipSize


// ═══════════════════════════════════════════════════════════
//  7. ENTRY CONDITIONS
// ═══════════════════════════════════════════════════════════

bool baseCondition = validTime and strategy.position_size == 0 and not inCooldown and not avoidPeriod and not slHitToday and not skip0800to0900Vienna

bool buySetup  = macdBullCross and macdLine < 0 and emaColor == color.green and     priceAbove and bullTFs >= minTFAlign and baseCondition and chopFilterOK
bool sellSetup = macdBearCross and macdLine > 0 and emaColor == color.red   and not priceAbove and bearTFs >= minTFAlign and baseCondition and chopFilterOK


// ═══════════════════════════════════════════════════════════
//  8. TRADE ENTRY EXECUTION
// ═══════════════════════════════════════════════════════════

if (buySetup or sellSetup) and barstate.isconfirmed
    bool isLong = buySetup

    // atr[1]: previous bar's ATR, avoiding inflation from the crossover
    // candle's own spike range → tighter, more representative SL distance.
    [valid, candSL, candTP, candBE] = calcEntryLevels(isLong, atr[1], pipSize)

    if valid
        entryPrice       := close
        slPrice          := candSL
        tpPrice          := candTP
        beTriggerPrice   := candBE
        totalLots        := calculateLotSize(close, candSL)
        tradeEntryBar    := bar_index
        currentDirection := isLong ? "buy" : "sell"
        exitAlertSent    := false
        beTriggered      := false
        preBeSlPrice     := na

        entryLine := line.new(bar_index, entryPrice, bar_index + 1, entryPrice, color=color.blue,  width=1)
        slLine    := line.new(bar_index, slPrice,    bar_index + 1, slPrice,    color=color.red,    width=1)
        tpLine    := line.new(bar_index, tpPrice,    bar_index + 1, tpPrice,    color=color.green,  width=1)
        beLine    := enableBE ? line.new(bar_index, beTriggerPrice, bar_index + 1, beTriggerPrice, color=color.orange, width=1, style=line.style_dashed) : na

        // Alert/live SL & TP stay raw (candidateSL/candTP), untouched by
        // spread. The NATIVE backtest stop order below IS spread-adjusted
        // (toward entry, one spread) — this simulates the real fill price
        // Pine's broker emulator gives intrabar. Must be a single order:
        // a second strategy.exit() would have nothing left to reserve.
        string tradeId = isLong ? "Long" : "Short"

        strategy.entry(tradeId, isLong ? strategy.long : strategy.short, qty=totalLots)
        strategy.exit("Exit_" + tradeId, tradeId,
          stop           = isLong ? slPrice + spreadPrice : slPrice - spreadPrice,
          limit          = tpPrice,
          comment_loss   = "SL (spread-adj)",
          comment_profit = "TP")

        alert(buildAlert(isLong ? "buy" : "sell", totalLots, slPrice, tpPrice, beTriggerPrice), alert.freq_once_per_bar)

        label.new(bar_index + 1, isLong ? low : high,
          (isLong ? "BUY\n" : "SELL\n") + str.tostring(totalLots, '#.##'),
          style     = isLong ? label.style_label_up : label.style_label_down,
          color     = isLong ? color.green : color.red,
          textcolor = color.white, size=size.normal,
          yloc      = isLong ? yloc.belowbar : yloc.abovebar)


// ═══════════════════════════════════════════════════════════
//  9. BREAKEVEN TRIGGER + EXIT MONITORING
// ═══════════════════════════════════════════════════════════
// Spread model (sizing/alerts untouched, only affects simulated stops):
//   Original SL: native stop order = origSL ± 1×spreadPrice toward entry.
//   BE stop (post-1R): native stop order = entryPrice ± 2×spreadPrice
//   (doubled buffer for breathing room around entry). Detection thresholds
//   below mirror these exact offsets so labels/counters track the real fill.

if not na(currentDirection) and not na(entryPrice) and not exitAlertSent

    float origSlPrice    = beTriggered ? preBeSlPrice : slPrice

    float longSLDetect  = origSlPrice + spreadPrice
    float shortSLDetect = origSlPrice - spreadPrice

    bool longOrigSLHit  = currentDirection == "buy"  and not beTriggered and low  <= longSLDetect
    bool shortOrigSLHit = currentDirection == "sell" and not beTriggered and high >= shortSLDetect

    if longOrigSLHit or shortOrigSLHit
        slHitToday := true
        lastSlDay  := todayKey
        countSL    += 1
        label.new(bar_index, high, "🚫 DAILY LIMIT\n1 Loss",
          style=label.style_label_down, color=color.new(color.orange, 0),
          textcolor=color.white, size=size.normal)
        exitAlertSent := true

        // Backup only — native stop order (Section 8) should already have
        // closed the position intrabar. No-op if already flat.
        strategy.close(currentDirection == "buy" ? "Long" : "Short", comment="SL Hit (spread-adj)")

    else
        bool beHit =
          enableBE and not beTriggered and
          ((currentDirection == "buy"  and high >= beTriggerPrice) or
           (currentDirection == "sell" and low  <= beTriggerPrice))

        if beHit
            beTriggered    := true
            preBeSlPrice   := slPrice
            slPrice        := entryPrice

            float beSlOffset = 2.0 * spreadPrice
            if currentDirection == "buy"
                strategy.exit("Exit_Long",  "Long",  stop=slPrice + beSlOffset, limit=tpPrice,
                  comment_loss="BE Stop", comment_profit="TP")
            else
                strategy.exit("Exit_Short", "Short", stop=slPrice - beSlOffset, limit=tpPrice,
                  comment_loss="BE Stop", comment_profit="TP")

            alert(buildAlert(currentDirection, totalLots, slPrice, tpPrice, beTriggerPrice), alert.freq_once_per_bar)

            if not na(slLine)
                line.set_y1(slLine, slPrice)
                line.set_y2(slLine, slPrice)
                line.set_color(slLine, color.new(color.purple, 0))

            label.new(bar_index,
              currentDirection == "buy" ? low : high,
              "BE ✓\nSL→Entry",
              style     = currentDirection == "buy" ? label.style_label_up : label.style_label_down,
              color     = color.new(color.purple, 0),
              textcolor = color.white,
              size      = size.small,
              yloc      = currentDirection == "buy" ? yloc.belowbar : yloc.abovebar)

        bool longTPHit  = currentDirection == "buy"  and high >= tpPrice
        bool shortTPHit = currentDirection == "sell" and low  <= tpPrice

        float beStopDetectLong  = entryPrice + 2 * spreadPrice
        float beStopDetectShort = entryPrice - 2 * spreadPrice

        bool longBEStopHit  = currentDirection == "buy"  and beTriggered and not longTPHit and
          (beHit ? low <= entryPrice : low <= beStopDetectLong)
        bool shortBEStopHit = currentDirection == "sell" and beTriggered and not shortTPHit and
          (beHit ? high >= entryPrice : high >= beStopDetectShort)

        if longTPHit or shortTPHit
            countWins += 1
            label.new(bar_index, currentDirection == "buy" ? high : low, "TP✓",
              style=currentDirection == "buy" ? label.style_label_down : label.style_label_up,
              color=color.green, textcolor=color.white, size=size.tiny)
            exitAlertSent := true

        else if longBEStopHit or shortBEStopHit
            countBE += 1
            label.new(bar_index,
              currentDirection == "buy" ? high : low,
              "BE Stop\n(neutral)",
              style     = currentDirection == "buy" ? label.style_label_down : label.style_label_up,
              color     = color.new(color.purple, 40),
              textcolor = color.white,
              size      = size.normal)
            exitAlertSent := true


// ═══════════════════════════════════════════════════════════
//  10. EOD FORCED CLOSE — PER-PAIR RULE
// ═══════════════════════════════════════════════════════════
// AUDJPY: forced close every day (JPY-side carry/overnight gap risk).
// USDCHF: Friday-only close (standard weekend-gap protection).
// isNewDay is a safety net: on higher TFs the bar spanning the EOD
// trigger minute can otherwise skip the close entirely, carrying the
// position silently into the next day.

bool isNewDay        = ta.change(curDayOfYear) != 0
bool eodEveryDayPair = isAudjpy

bool eodTrigger =
  (isFriday or eodEveryDayPair) and
  (vTimeClose >= resolvedEodMins or (isNewDay and strategy.position_size != 0)) and
  strategy.position_size != 0 and not exitAlertSent and barstate.isconfirmed

if eodTrigger
    string tradeId = currentDirection == "buy" ? "Long" : "Short"
    strategy.close(tradeId, comment="EOD Close")
    alert(buildAlert(currentDirection == "buy" ? "close buy" : "close sell", na, na, na, na), alert.freq_once_per_bar)

    label.new(bar_index, currentDirection == "buy" ? low : high, "EOD\nClose",
      style     = currentDirection == "buy" ? label.style_label_up : label.style_label_down,
      color     = color.orange, textcolor=color.white, size=size.small,
      yloc      = currentDirection == "buy" ? yloc.belowbar : yloc.abovebar)

    exitAlertSent := true


// ═══════════════════════════════════════════════════════════
//  11. POSITION RESET
// ═══════════════════════════════════════════════════════════

if strategy.position_size == 0 and strategy.position_size[1] != 0
    lastExitBar      := bar_index
    currentDirection := na
    beTriggered      := false
    preBeSlPrice     := na
    exitAlertSent    := false


// ═══════════════════════════════════════════════════════════
//  12. CHART LINE MANAGEMENT
// ═══════════════════════════════════════════════════════════

bool inTrade = strategy.position_size != 0

if inTrade and bar_index > tradeEntryBar
    if not na(entryLine)
        line.set_x2(entryLine, bar_index + 1)
    if not na(slLine)
        line.set_x2(slLine,    bar_index + 1)
    if not na(tpLine)
        line.set_x2(tpLine,    bar_index + 1)
    if not na(beLine)
        line.set_x2(beLine,    bar_index + 1)

if not inTrade and strategy.position_size[1] != 0
    if not na(entryLine)
        line.set_x2(entryLine, bar_index)
    if not na(slLine)
        line.set_x2(slLine,    bar_index)
    if not na(tpLine)
        line.set_x2(tpLine,    bar_index)
    if not na(beLine)
        line.set_x2(beLine,    bar_index)
    entryPrice     := na
    slPrice        := na
    tpPrice        := na
    beTriggerPrice := na

plot(inTrade ? slPrice : na, "sl", display=display.none)
plot(inTrade ? tpPrice : na, "tp", display=display.none)


// ═══════════════════════════════════════════════════════════
//  13. INFO TABLE
// ═══════════════════════════════════════════════════════════

displayTable(bool isActive, float entry, float sl, float tp, float be, float lots, string direction) =>
    color borderCol = direction == "buy" ? color.green : direction == "sell" ? color.red : color.blue
    table.set_border_color(tradeTable, borderCol)
    table.set_frame_color(tradeTable,  borderCol)

    int   alpha   = isActive ? 80 : 90
    color textCol = isActive ? color.white : color.gray

    table.cell(tradeTable, 0, 0, "Level", bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.small)
    table.cell(tradeTable, 1, 0, "Value", bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.small)

    table.cell(tradeTable, 0, 1, "Entry", bgcolor=color.new(isActive ? color.blue : color.gray, alpha), text_color=textCol, text_size=size.normal)
    table.cell(tradeTable, 1, 1, isActive ? str.tostring(entry, format.mintick) : "-",
      bgcolor=color.new(isActive ? color.blue : color.gray, alpha), text_color=textCol, text_size=size.normal)

    table.cell(tradeTable, 0, 2, "SL", bgcolor=color.new(isActive ? color.red : color.gray, alpha), text_color=textCol, text_size=size.normal)
    table.cell(tradeTable, 1, 2, isActive ? str.tostring(sl, format.mintick) : "-",
      bgcolor=color.new(isActive ? color.red : color.gray, alpha), text_color=textCol, text_size=size.normal)

    table.cell(tradeTable, 0, 3, "BE @ " + str.tostring(beAtR, '#.#') + "R", bgcolor=color.new(isActive ? color.orange : color.gray, alpha), text_color=textCol, text_size=size.normal)
    table.cell(tradeTable, 1, 3, isActive and enableBE ? str.tostring(be, format.mintick) : "-",
      bgcolor=color.new(isActive ? color.orange : color.gray, alpha), text_color=textCol, text_size=size.normal)

    table.cell(tradeTable, 0, 4, "TP (" + str.tostring(tpRatio, '#.#') + "R)", bgcolor=color.new(isActive ? color.green : color.gray, alpha), text_color=textCol, text_size=size.normal)
    table.cell(tradeTable, 1, 4, isActive ? str.tostring(tp, format.mintick) : "-",
      bgcolor=color.new(isActive ? color.green : color.gray, alpha), text_color=textCol, text_size=size.normal)

    int totalClosed = countWins + countBE + countSL
    table.cell(tradeTable, 0, 5, "Wins (TP)", bgcolor=color.new(color.green, 75), text_color=color.white, text_size=size.small)
    table.cell(tradeTable, 1, 5, str.tostring(countWins), bgcolor=color.new(color.green, 75), text_color=color.white, text_size=size.small)

    table.cell(tradeTable, 0, 6, "Breakeven", bgcolor=color.new(color.purple, 75), text_color=color.white, text_size=size.small)
    table.cell(tradeTable, 1, 6, str.tostring(countBE), bgcolor=color.new(color.purple, 75), text_color=color.white, text_size=size.small)

    table.cell(tradeTable, 0, 7, "Losses (SL)", bgcolor=color.new(color.red, 75), text_color=color.white, text_size=size.small)
    table.cell(tradeTable, 1, 7, str.tostring(countSL) + " / " + str.tostring(totalClosed), bgcolor=color.new(color.red, 75), text_color=color.white, text_size=size.small)

displayTable(
  inTrade,
  inTrade ? entryPrice     : na,
  inTrade ? slPrice        : na,
  inTrade ? tpPrice        : na,
  inTrade ? beTriggerPrice : na,
  inTrade ? totalLots      : na,
  currentDirection)
````
