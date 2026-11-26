# YH / YL / YC (Live) - Improved

- url: https://www.tradingview.com/script/1D9tDBHa-YH-YL-YC-Live-Improved/
- type: indicator
- pine_id: PUB;3084e10d49bd4a46967cd9c723d94bb1
- version: 2.0

## Description

This is an enhanced version of the original **“YH / YL / YC (Live)”** script by **Ilse Filippo** (`Ilse_Filippo` on TradingView).

The indicator automatically plots the previous completed trading session’s:

* **YH** — Yesterday High
* **YL** — Yesterday Low
* **YC** — Yesterday Close

It supports stocks, ADRs, ETFs, indices, futures, forex, and metals.

### Improvements in v1.2

* Migrated to **Pine Script v6**
* Added weekend-aware handling so **Friday’s YH / YL / YC are already available on Saturday and Sunday**
* Friday remains the reference while Monday’s session is still active
* Replaced the original manual stock RTH tracking with TradingView’s native **regular-session data**
* Fixed missing **YH / YL** levels on stock charts
* Stocks, ADRs, and ETFs now use their exchange-defined regular trading session
* Preserved the original line and label presentation

### Credits

Original script: **YH / YL / YC (Live)**
Original author: **Ilse Filippo**
TradingView: **Ilse_Filippo**

This modified version retains the open-source distribution model of the original script.

## Source Code

````pine
//@version=6
//=============================================================================
// YH / YL / YC (Live)
// Weekend-aware version
//
// Version: 1.3
// Revision date: 2026-09-26
// JKnappers
//
// DESCRIPTION
// Displays the previous completed trading session's:
//   YH = Yesterday High
//   YL = Yesterday Low
//   YC = Yesterday Close
//
// For indices/futures, values are derived from the daily timeframe.
// For stocks, ADRs, and ETFs on intraday charts, the regular US trading
// session (09:30-16:00 New York time) is tracked separately.
//
// WEEKEND / CLOSED-SESSION HANDLING
// While the latest daily/session bar is still active, the indicator uses the
// previous completed trading session.
// Once the latest daily/session bar has closed, that completed session becomes
// the new YH / YL / YC reference.
//
// This means:
//   - Friday values are already available on Saturday and Sunday.
//   - Friday remains the reference when the Monday session starts.
//   - There is no need to wait for a new Monday daily candle simply to expose
//     Friday's completed high, low, and close.
//
// ORIGINAL SCRIPT
//   "YH / YL / YC (Live)"
//   Original author: Ilse Filippo
//   TradingView: Ilse_Filippo
//   Published on TradingView as an open-source script.
//
// REVISION HISTORY
//   v1.1 - 2026-08-23
//   - Migrated to Pine Script v6.
//   - Added completed-daily-bar detection for weekend handling.
//   - Preserved the original stock RTH handling and drawing logic.
//
//   v1.2 - 2026-09-26
//   - Corrected the weekend/closed-session daily-source logic for indices/futures.
//   - Current daily OHLC is requested with lookahead_on, while time_close/timenow
//     explicitly gates whether the current daily bar is allowed to become YH/YL/YC.
//   - During an active daily session, YH/YL/YC still use the previous completed day.
//   - After the daily session closes, the just-completed day becomes the reference,
//     so Friday remains visible on Saturday/Sunday and into Monday before Monday closes.
//   - Updated default YH/YL/YC colors to the user's current chart defaults.
//   - No changes to stock RTH tracking, line placement, or label placement.
//
//   v1.3 - 2026-09-26
//   - Added optional price display to YH / YL / YC labels.
//   - Added "Show Price in Labels" configuration option.
//   - Label format uses one space between level name and price.
//   - Prices below 10,000 are displayed with maximum 1 decimal.
//   - Prices at or above 10,000 are rounded to integer.
//   - Increased default label offset from 15 to 45 bars.
//   - No changes to YH/YL/YC source logic, weekend handling, or line placement.
//
// LICENSING
//   This modified version retains the open-source distribution model of the
//   original TradingView publication. No additional software license is imposed.
//=============================================================================
indicator(
     "YH / YL / YC (Live) v1.3",
     overlay=true,
     max_lines_count=10,
     max_labels_count=10
     )
//=============================================================================
// INPUTS
//=============================================================================
colYH = input.color(
     color.rgb(240, 51, 73),
     "YH Color"
     )
colYL = input.color(
     color.rgb(240, 51, 73),
     "YL Color"
     )
colYC = input.color(
     color.rgb(253, 151, 33),
     "YC Color"
     )
lineWidth = input.int(
     1,
     "Line Width",
     minval=1,
     maxval=5
     )
showLabelPrices = input.bool(
     true,
     "Show Price in Labels"
     )
labelOffset = input.int(
     45,
     "Label Offset (bars)",
     minval=1,
     maxval=50
     )
labelSize = input.string(
     "small",
     "Label Size",
     options=["tiny", "small", "normal", "large"]
     )
labelBgColor = input.color(
     color.white,
     "Label Background Color"
     )
labelTxtColor = input.color(
     color.black,
     "Label Text Color"
     )
labelTransp = input.int(
     0,
     "Label Background Transparency",
     minval=0,
     maxval=100
     )
//=============================================================================
// LABEL STYLE
//=============================================================================
lblSize =
     labelSize == "tiny"   ? size.tiny :
     labelSize == "normal" ? size.normal :
     labelSize == "large"  ? size.large :
     size.small
lblBg =
     color.new(
          labelBgColor,
          labelTransp
          )
//=============================================================================
// LABEL PRICE FORMATTING
//=============================================================================
f_priceText(float price) =>
     price >= 10000.0
     ? str.tostring(math.round(price))
     : str.tostring(
          math.round(price * 10.0) / 10.0,
          "#.#"
          )
f_labelText(string levelName, float levelPrice) =>
     showLabelPrices
     ? levelName + " " + f_priceText(levelPrice)
     : levelName
//=============================================================================
// INSTRUMENT DETECTION
//=============================================================================
// stock = ordinary shares
// dr    = ADRs
// fund  = ETFs
//=============================================================================
isStock =
     syminfo.type == "stock" or
     syminfo.type == "dr" or
     syminfo.type == "fund"
isIntraday =
     timeframe.isintraday
//=============================================================================
// INDICES / FUTURES
//=============================================================================
// Both the current and previous daily bars are requested.
// During an active daily bar:
//   previous daily bar = YH / YL / YC.
// After the latest daily bar has completed:
//   that completed bar becomes YH / YL / YC.
// This is what allows Friday to become the reference during the weekend.
//=============================================================================
dHighCurrent =
     request.security(
          syminfo.tickerid,
          "D",
          high,
          lookahead=barmerge.lookahead_on
          )
dLowCurrent =
     request.security(
          syminfo.tickerid,
          "D",
          low,
          lookahead=barmerge.lookahead_on
          )
dCloseCurrent =
     request.security(
          syminfo.tickerid,
          "D",
          close,
          lookahead=barmerge.lookahead_on
          )
dCloseTimeCurrent =
     request.security(
          syminfo.tickerid,
          "D",
          time_close,
          lookahead=barmerge.lookahead_off
          )
dHighPrevious =
     request.security(
          syminfo.tickerid,
          "D",
          high[1],
          lookahead=barmerge.lookahead_on
          )
dLowPrevious =
     request.security(
          syminfo.tickerid,
          "D",
          low[1],
          lookahead=barmerge.lookahead_on
          )
dClosePrevious =
     request.security(
          syminfo.tickerid,
          "D",
          close[1],
          lookahead=barmerge.lookahead_on
          )
// Latest daily bar is still active while its scheduled close is in the future.
dailyBarIsOpen =
     not na(dCloseTimeCurrent) and
     timenow < dCloseTimeCurrent
dHigh =
     dailyBarIsOpen ?
     dHighPrevious :
     dHighCurrent
dLow =
     dailyBarIsOpen ?
     dLowPrevious :
     dLowCurrent
dClose =
     dailyBarIsOpen ?
     dClosePrevious :
     dCloseCurrent
//=============================================================================
// STOCKS INTRADAY — MANUAL RTH TRACKING
//=============================================================================
rthSession = "0930-1600"
nyTz = "America/New_York"
inRTH =
     isIntraday ?
     not na(
          time(
               timeframe.period,
               rthSession,
               nyTz
               )
          ) :
     false
var float curRthHigh = na
var float curRthLow = na
var float curRthClose = na
var float prevRthHigh = na
var float prevRthLow = na
var float prevRthClose = na
// Start of a new RTH session.
// Store the completed previous session and reset current-session tracking.
if inRTH and not inRTH[1]
    prevRthHigh := curRthHigh
    prevRthLow := curRthLow
    prevRthClose := curRthClose
    curRthHigh := high
    curRthLow := low
    curRthClose := close
// Track current RTH session.
if inRTH
    curRthHigh :=
         na(curRthHigh) ?
         high :
         math.max(
              curRthHigh,
              high
              )
    curRthLow :=
         na(curRthLow) ?
         low :
         math.min(
              curRthLow,
              low
              )
    curRthClose :=
         close
// During an active RTH bar, use the previous completed RTH session.
// After the session has completed, the just-completed session becomes the
// reference. This preserves the behavior needed for after-hours/weekend prep.
rthBarIsOpen =
     inRTH and
     not na(time_close) and
     timenow < time_close
sHighI =
     rthBarIsOpen ?
     prevRthHigh :
     curRthHigh
sLowI =
     rthBarIsOpen ?
     prevRthLow :
     curRthLow
sCloseI =
     rthBarIsOpen ?
     prevRthClose :
     curRthClose
//=============================================================================
// STOCKS — DAILY AND HIGHER TIMEFRAMES
//=============================================================================
currentBarIsOpen =
     not na(time_close) and
     timenow < time_close
sHighD =
     currentBarIsOpen ?
     high[1] :
     high
sLowD =
     currentBarIsOpen ?
     low[1] :
     low
sCloseD =
     currentBarIsOpen ?
     close[1] :
     close
//=============================================================================
// SELECT SOURCE
//=============================================================================
yHigh =
     isStock ?
     (
          isIntraday ?
          sHighI :
          sHighD
          ) :
     dHigh
yLow =
     isStock ?
     (
          isIntraday ?
          sLowI :
          sLowD
          ) :
     dLow
yClose =
     isStock ?
     (
          isIntraday ?
          sCloseI :
          sCloseD
          ) :
     dClose
//=============================================================================
// DRAW
//=============================================================================
var line lineYH = na
var line lineYL = na
var line lineYC = na
var label labelYH = na
var label labelYL = na
var label labelYC = na
if barstate.islast and
   not na(yHigh) and
   not na(yLow) and
   not na(yClose)
    //-------------------------------------------------------------------------
    // YH
    //-------------------------------------------------------------------------
    line.delete(lineYH)
    lineYH :=
         line.new(
              bar_index,
              yHigh,
              bar_index + 1,
              yHigh,
              extend=extend.both,
              color=colYH,
              width=lineWidth
              )
    //-------------------------------------------------------------------------
    // YL
    //-------------------------------------------------------------------------
    line.delete(lineYL)
    lineYL :=
         line.new(
              bar_index,
              yLow,
              bar_index + 1,
              yLow,
              extend=extend.both,
              color=colYL,
              width=lineWidth
              )
    //-------------------------------------------------------------------------
    // YC
    //-------------------------------------------------------------------------
    line.delete(lineYC)
    lineYC :=
         line.new(
              bar_index,
              yClose,
              bar_index + 1,
              yClose,
              extend=extend.both,
              color=colYC,
              width=lineWidth
              )
    //-------------------------------------------------------------------------
    // YH LABEL
    //-------------------------------------------------------------------------
    label.delete(labelYH)
    labelYH :=
         label.new(
              bar_index + labelOffset,
              yHigh,
              f_labelText("YH", yHigh),
              color=lblBg,
              textcolor=labelTxtColor,
              style=label.style_label_center,
              size=lblSize
              )
    //-------------------------------------------------------------------------
    // YL LABEL
    //-------------------------------------------------------------------------
    label.delete(labelYL)
    labelYL :=
         label.new(
              bar_index + labelOffset,
              yLow,
              f_labelText("YL", yLow),
              color=lblBg,
              textcolor=labelTxtColor,
              style=label.style_label_center,
              size=lblSize
              )
    //-------------------------------------------------------------------------
    // YC LABEL
    //-------------------------------------------------------------------------
    label.delete(labelYC)
    labelYC :=
         label.new(
              bar_index + labelOffset,
              yClose,
              f_labelText("YC", yClose),
              color=lblBg,
              textcolor=labelTxtColor,
              style=label.style_label_center,
              size=lblSize
              )
````
