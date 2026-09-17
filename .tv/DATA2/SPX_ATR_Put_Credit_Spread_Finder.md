<!-- tradingview-pine-id: PUB;5060362c7bd047ae8a11c38bee4e93e3 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# SPX ATR Put Credit Spread Finder

Source: https://www.tradingview.com/script/jLbpxvs4-Volatility-Scaled-Range-Level-with-Term-Structure-Filter/

## Description

WHAT IT DOES

This indicator plots a single volatility-scaled price level and evaluates three independent market-condition filters against it. The level sits one Average True Range below the prior period's close, so it widens automatically when realized volatility expands and tightens when volatility contracts. A summary table reports the level, its distance from current price as a percentage, and the state of each filter.

It is a reference and condition-monitoring tool. It does not generate buy or sell orders, does not connect to a broker, and takes no position on whether any particular trade should be placed.

HOW IT WORKS

The level is computed on a higher timeframe than the chart:

level = close[1] of higher timeframe − ATR(14) of higher timeframe

ATR here is Wilder's RMA of True Range, which is what ta.atr() returns. Both components are pulled with request.security(..., lookahead = barmerge.lookahead_off) and referenced at index [1], so the value is drawn from the last completed higher timeframe bar and does not repaint. Setting the timeframe input to W produces a weekly-anchored level; D produces a daily-anchored one.

The level is then floored to a user-defined increment (default 5). This is optional rounding for users who want the level snapped to a round number rather than an arbitrary decimal.

Three filters are evaluated independently:

Term structure. The ratio of a short-dated volatility index to a longer-dated one (default CBOE:VIX over CBOE:VIX3M). A ratio below the threshold indicates contango, the normal state. A ratio above it indicates backwardation, which historically coincides with volatility clustering and trending decline. Both symbols are user inputs and can be swapped for other instruments.
Absolute volatility floor. A minimum level on the short-dated volatility index. Below this, the distance implied by ATR is small in absolute terms.
Optional trend filter. Price above its 21-period EMA.

The table reads GATES PASS only when all enabled filters are satisfied. An alert() call fires on the first bar of each new higher-timeframe period, with the level, the distance, and the filter states embedded in the message text.

HOW TO USE IT

Add to a daily chart. Set the ATR timeframe input to match the horizon you care about: W for a weekly-anchored level, D for a daily one. Confirm your data plan resolves both volatility symbols; substitute alternatives in the Symbols group if not.

The panel position is adjustable through the "Panel offset right of centre (%)" input, from 0 for centred through 45 for the right edge.

For notifications: right-click the chart, Add alert, select this indicator as the condition, choose "Any alert() function call", and set the frequency to Once Per Bar so it fires at the start of a new period rather than at its close.

The "Anchor on forming period" input switches the level to use the in-progress higher-timeframe bar rather than the last completed one. This produces a value that updates continuously through the period. It is intended as a preview of where the next period's level is forming, not as a signal, and it will change intrabar.

ORIGINALITY

Prior-close-minus-ATR levels are a well-established concept and several published indicators plot them, most notably Saty Mahajan's ATR Levels, which plots a full Fibonacci ladder of them across six timeframe modes. This script is not a republication of that work and does not reuse its code. It differs in scope and purpose:

It plots one level rather than a ladder, to keep the chart readable when the level is the only thing being monitored.
It adds volatility term structure and absolute volatility as explicit gating conditions, which existing ATR level indicators do not evaluate.
It rounds the level to a user-defined increment.
It emits a dynamic alert message containing the computed values, so the notification is self-contained and requires no chart lookup.

The arithmetic that produces the level is standard and deliberately matches the conventional definition so that values are comparable with other implementations.

LIMITATIONS AND SHORTCOMINGS

The level is descriptive, not predictive. It describes a distance in volatility units. Price reaching or not reaching it carries no guarantee of any kind.
The term structure filter depends on external symbols. If your data plan does not provide them, the filter cannot be evaluated and the table will not populate correctly. Verify both symbols resolve before relying on it.
Volatility index data is daily. The filter therefore updates on a slower cadence than the chart and can be stale relative to fast intraday moves.
The absolute volatility floor is a coarse proxy. It says nothing about the actual pricing of any instrument.
On index CFD feeds, the underlying value can differ slightly from the cash index. Where the level is near a rounding boundary, the rounded output may differ between feeds.
The forming-period preview mode updates continuously and is not a fixed reference.
No backtest or performance statistics are presented, because this is an indicator and not a strategy. Nothing here has been tested as a system.

CREDITS

The prior-close-minus-ATR level concept is widely used. Saty Mahajan's open-source ATR Levels indicator is the best-known implementation on TradingView and is worth reviewing for a fuller treatment of the concept across multiple timeframe modes and Fibonacci ratios.

DISCLAIMER

This script is provided for educational and analytical purposes. It is not financial, investment, or trading advice, and it is not a recommendation to buy or sell anything. Volatility-based levels describe historical range behaviour and carry no predictive guarantee. Any use of this tool is at your own risk.# TradingView publication description

---

## Source Code

````pine
//@version=6
// SPX ATR Put Credit Spread Finder - TradingView port
//
// Signal layer only. TradingView cannot see the options chain and cannot route
// SPX options orders. Credit floor is enforced by YOU at the ToS ticket.
//
// Run on a DAILY chart of SPX.
// Weekly cadence: Trading mode = Multiday  (matches Saty "Multiday" -1 ATR)
// 1DTE cadence:   Trading mode = Day, use_current_close = true
//
// Alert setup: right-click chart > Add alert > Condition = this indicator >
//   "Any alert() function call" > Once Per Bar > Notify on app.
//   Fires on the first tick of the new period, ~9:30 ET Monday.

indicator("SPX ATR Put Credit Spread Finder", "SPX ATR PCS", overlay = true)

// ---------------- inputs ----------------
trading_type      = input.string("Multiday", "Trading mode",
                     options = ["Day", "Multiday", "Swing", "Position", "Long-term"])

// same mode-to-timeframe mapping Saty ATR Levels uses
tf_func() =>
    tf = "W"
    if trading_type == "Day"
        tf := "D"
    else if trading_type == "Multiday"
        tf := "W"
    else if trading_type == "Swing"
        tf := "M"
    else if trading_type == "Position"
        tf := "3M"
    else if trading_type == "Long-term"
        tf := "12M"
    tf

atr_tf            = tf_func()
atr_length        = input.int(14,         "ATR length", minval = 1)
spread_width      = input.float(50,       "Spread width (points)", minval = 5)
strike_increment  = input.float(5,        "Strike increment", minval = 1)
min_credit_pct    = input.float(6.0,      "Min credit as % of width", minval = 0)
use_current_close = input.bool(false,     "Anchor on forming period (live preview)")

vix_ratio_max     = input.float(0.95,     "Max VIX/VIX3M (above = no trade)", group = "Gates")
vix_min           = input.float(14.0,     "Min VIX (credit proxy)",           group = "Gates")
use_trend_filter  = input.bool(false,     "Require close > 21 EMA",           group = "Gates")

vix_sym           = input.symbol("CBOE:VIX",   "VIX symbol",   group = "Symbols")
vix3m_sym         = input.symbol("CBOE:VIX3M", "VIX3M symbol", group = "Symbols")

// Panel sits centred, then gets pushed right by a transparent spacer column.
// 0 = dead centre. Raise it to slide the card further right.
panel_offset      = input.float(8.0, "Panel offset right of centre (%)",
                     minval = 0, maxval = 45, step = 1, group = "Panel")

// ---------------- level: mirrors Saty ATR Levels exactly ----------------
// Saty uses [period_index] together with lookahead_on. That pairing is the
// standard non-repainting idiom: both the anchor close and the ATR lock to the
// last COMPLETED period and stay fixed for its whole duration, rather than
// recomputing off the forming bar.
//
// He also forces the EXTENDED session on the ticker, which changes the
// higher-timeframe OHLC and therefore the ATR value itself.

period_index = use_current_close ? 0 : 1
satyTicker   = ticker.new(syminfo.prefix, syminfo.ticker, session = session.extended)

pc = request.security(satyTicker, atr_tf, close[period_index],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

patr = request.security(satyTicker, atr_tf, ta.atr(atr_length)[period_index],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

level = pc - patr

shortStrike = math.floor(level / strike_increment) * strike_increment   // round DOWN
longStrike  = shortStrike - spread_width
minCredit   = spread_width * min_credit_pct / 100
otmPct      = (close - shortStrike) / close * 100

// ---------------- gates ----------------
vix      = request.security(vix_sym,   "D", close, lookahead = barmerge.lookahead_off)
vix3m    = request.security(vix3m_sym, "D", close, lookahead = barmerge.lookahead_off)
tsRatio  = vix / vix3m
contango = tsRatio <= vix_ratio_max
ivOK     = vix >= vix_min
trendOK  = not use_trend_filter or close > ta.ema(close, 21)
go       = contango and ivOK and trendOK

// ---------------- level line ----------------
// preview mode leaks on history, so only draw it in realtime
plotLevel = use_current_close and not barstate.isrealtime ? na : level
plot(plotLevel, "ATR -1 level", color = color.new(color.white, 0),
     style = plot.style_linebr, linewidth = 1)

// ---------------- trade card ----------------
// col 0 = invisible spacer that shoves the card right of centre, col 1 = content
var table t = table.new(position.top_center, 2, 6, border_width = 0)

if barstate.islast
    okBg  = color.new(color.green, 25)
    badBg = color.new(color.red, 25)

    for r = 0 to 5
        table.cell(t, 0, r, "", width = panel_offset * 2, bgcolor = color.new(color.black, 100))

    // verification row: compare directly against the Saty info label
    table.cell(t, 1, 5,
         "anchor close " + str.tostring(pc, "#.##") + "   |   ATR " + str.tostring(patr, "#.##"),
         text_color = color.white, bgcolor = color.new(color.blue, 60))

    table.cell(t, 1, 0, go ? "GO" : "NO TRADE",
         text_color = color.white, bgcolor = go ? okBg : badBg, text_size = size.normal)

    table.cell(t, 1, 1,
         "SELL " + str.tostring(shortStrike, "#") + "P / BUY " + str.tostring(longStrike, "#") + "P",
         text_color = color.white, bgcolor = color.new(color.gray, 40))

    table.cell(t, 1, 2,
         str.tostring(otmPct, "#.#") + "% OTM   |   -1 ATR " + str.tostring(level, "#.##"),
         text_color = color.white, bgcolor = color.new(color.gray, 60))

    table.cell(t, 1, 3,
         "VIX/VIX3M " + str.tostring(tsRatio, "#.##") + (contango ? " contango" : "  BACKWARDATION"),
         text_color = color.white, bgcolor = contango ? okBg : badBg)

    table.cell(t, 1, 4,
         "VIX " + str.tostring(vix, "#.#") + (ivOK ? "" : " LOW") +
         "   |   floor $" + str.tostring(minCredit, "#.00") + " at ticket",
         text_color = color.white, bgcolor = ivOK ? color.new(color.orange, 40) : badBg)

// ---------------- alerts ----------------
newPeriod = timeframe.change(atr_tf)

msg = "SPX ATR PCS: SELL " + str.tostring(shortStrike, "#") + "P / BUY " +
      str.tostring(longStrike, "#") + "P  (" + str.tostring(otmPct, "#.#") + "% OTM)" +
      "  | VIX/VIX3M " + str.tostring(tsRatio, "#.##") +
      "  | min credit $" + str.tostring(minCredit, "#.00") +
      "  | exit alert @ " + str.tostring(shortStrike, "#")

if newPeriod and go
    alert(msg, alert.freq_once_per_bar)

if newPeriod and not go
    alert("SPX ATR PCS: NO TRADE this period. VIX/VIX3M " +
          str.tostring(tsRatio, "#.##") + ", VIX " + str.tostring(vix, "#.#"),
          alert.freq_once_per_bar)

// static-message fallback if you prefer alertcondition()
alertcondition(newPeriod and go, "SPX ATR PCS: GO", "New ATR spread signal")
````
