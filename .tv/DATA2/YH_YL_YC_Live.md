<!-- tradingview-pine-id: PUB;3084e10d49bd4a46967cd9c723d94bb1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# YH / YL / YC (Live)

Source: https://www.tradingview.com/script/1D9tDBHa-YH-YL-YC-Live-Improved/

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

---

## Source Code

````pine
//@version=6

//=============================================================================
// YH / YL / YC (Live)
// Weekend-aware and regular-session stock version
//
// Version: 1.2
// Revision date: 2026-08-23
// JKnappers
//
// DESCRIPTION
// Displays the previous completed trading session's:
//
//   YH = Yesterday High
//   YL = Yesterday Low
//   YC = Yesterday Close
//
// For stocks, ADRs, and ETFs, values are derived from the symbol's native
// regular trading session.
//
// For indices, futures, forex, metals, and other instruments, values are
// derived from the symbol's normal daily session.
//
// WEEKEND / CLOSED-SESSION HANDLING
// While the latest daily/session bar is still active, the indicator uses the
// previous completed trading session.
//
// Once the latest daily/session bar has closed, that completed session becomes
// the new YH / YL / YC reference.
//
// This means:
//   - Friday values are already available on Saturday and Sunday.
//   - Friday remains the reference while Monday's session is active.
//   - After Monday's session closes, Monday becomes the new reference.
//
// ORIGINAL SCRIPT
//   "YH / YL / YC (Live)"
//   Original author: Ilse Filippo
//   TradingView: Ilse_Filippo
//   Published on TradingView as an open-source script.
//
// MODIFICATIONS
//   - Migrated to Pine Script v6.
//   - Added completed-daily-bar detection for correct weekend handling.
//   - Fixed the weekend case where Thursday values could remain displayed
//     while Friday was already the latest completed trading day.
//   - Replaced manual stock RTH tracking with TradingView's native
//     regular-session data.
//   - Stocks, ADRs, and ETFs now use their exchange-defined regular session.
//   - Fixed missing YH / YL levels on stock charts.
//   - Preserved the original line and label presentation.
//
// LICENSING
//   This modified version retains the open-source distribution model of the
//   original TradingView publication. No additional software license is imposed.
//=============================================================================

indicator(
     "YH / YL / YC (Live)",
     overlay=true,
     max_lines_count=10,
     max_labels_count=10
     )

//=============================================================================
// INPUTS
//=============================================================================

colYH = input.color(
     color.green,
     "YH Color"
     )

colYL = input.color(
     color.green,
     "YL Color"
     )

colYC = input.color(
     color.orange,
     "YC Color"
     )

lineWidth = input.int(
     1,
     "Line Width",
     minval=1,
     maxval=5
     )

labelOffset = input.int(
     15,
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

lblBg = color.new(
     labelBgColor,
     labelTransp
     )

//=============================================================================
// INSTRUMENT DETECTION
//=============================================================================
//
// stock = ordinary shares
// dr    = ADRs
// fund  = ETFs
//
// These instruments use their native exchange-defined regular session.
//=============================================================================

isStock =
     syminfo.type == "stock" or
     syminfo.type == "dr" or
     syminfo.type == "fund"

//=============================================================================
// SESSION-SPECIFIC SOURCE
//=============================================================================
//
// For stocks, ADRs, and ETFs:
//
//   ticker.new(..., session.regular)
//
// requests the instrument's native regular trading session rather than using
// a manually hard-coded intraday RTH tracker.
//
// Other instruments continue to use their normal symbol feed.
//=============================================================================

regularTicker = ticker.new(
     syminfo.prefix,
     syminfo.ticker,
     session.regular
     )

sourceTicker =
     isStock ?
     regularTicker :
     syminfo.tickerid

//=============================================================================
// CURRENT DAILY BAR
//=============================================================================
//
// These values represent the latest daily bar available from the selected
// source.
//
// On a live trading day this is the still-forming daily bar.
//
// After the session has closed, and during the weekend, this is the latest
// completed daily bar.
//=============================================================================

dHighCurrent = request.security(
     sourceTicker,
     "D",
     high,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
     )

dLowCurrent = request.security(
     sourceTicker,
     "D",
     low,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
     )

dCloseCurrent = request.security(
     sourceTicker,
     "D",
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
     )

dCloseTimeCurrent = request.security(
     sourceTicker,
     "D",
     time_close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
     )

//=============================================================================
// PREVIOUS COMPLETED DAILY BAR
//=============================================================================
//
// During an active trading day, these are the values that should be used for
// YH / YL / YC.
//=============================================================================

dHighPrevious = request.security(
     sourceTicker,
     "D",
     high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on
     )

dLowPrevious = request.security(
     sourceTicker,
     "D",
     low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on
     )

dClosePrevious = request.security(
     sourceTicker,
     "D",
     close[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on
     )

//=============================================================================
// IS THE LATEST DAILY BAR STILL ACTIVE?
//=============================================================================
//
// Friday after close:
//   Friday time_close < timenow
//   -> Friday is complete
//   -> use Friday.
//
// Saturday / Sunday:
//   Friday remains the latest completed daily bar
//   -> use Friday.
//
// Monday while the daily session is active:
//   Monday time_close > timenow
//   -> Monday is still forming
//   -> use Friday.
//
// Monday after close:
//   Monday time_close < timenow
//   -> Monday is complete
//   -> use Monday.
//=============================================================================

dailyBarIsOpen =
     not na(dCloseTimeCurrent) and
     timenow < dCloseTimeCurrent

//=============================================================================
// SELECT YH / YL / YC
//=============================================================================

yHigh =
     dailyBarIsOpen ?
     dHighPrevious :
     dHighCurrent

yLow =
     dailyBarIsOpen ?
     dLowPrevious :
     dLowCurrent

yClose =
     dailyBarIsOpen ?
     dClosePrevious :
     dCloseCurrent

//=============================================================================
// DRAW OBJECTS
//=============================================================================

var line lineYH = na
var line lineYL = na
var line lineYC = na

var label labelYH = na
var label labelYL = na
var label labelYC = na

//=============================================================================
// DRAW
//=============================================================================

if barstate.islast and
   not na(yHigh) and
   not na(yLow) and
   not na(yClose)

    //-------------------------------------------------------------------------
    // YH
    //-------------------------------------------------------------------------

    line.delete(lineYH)

    lineYH := line.new(
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

    lineYL := line.new(
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

    lineYC := line.new(
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

    labelYH := label.new(
         bar_index + labelOffset,
         yHigh,
         "YH",
         color=lblBg,
         textcolor=labelTxtColor,
         style=label.style_label_center,
         size=lblSize
         )

    //-------------------------------------------------------------------------
    // YL LABEL
    //-------------------------------------------------------------------------

    label.delete(labelYL)

    labelYL := label.new(
         bar_index + labelOffset,
         yLow,
         "YL",
         color=lblBg,
         textcolor=labelTxtColor,
         style=label.style_label_center,
         size=lblSize
         )

    //-------------------------------------------------------------------------
    // YC LABEL
    //-------------------------------------------------------------------------

    label.delete(labelYC)

    labelYC := label.new(
         bar_index + labelOffset,
         yClose,
         "YC",
         color=lblBg,
         textcolor=labelTxtColor,
         style=label.style_label_center,
         size=lblSize
         )
````
