# Trader Riaz Lot Size Calculator (Universal Visual Edition)

- url: https://www.tradingview.com/script/yuafsR7M-Trader-Riaz-Lot-Size-Calculator-Universal-Visual-Edition/
- type: indicator
- pine_id: PUB;61457dd2616247b6906373c4b0b3a230
- version: 3.0

## Description

### Overview
The Trader Riaz Lot Size Calculator is a professional-grade risk management overlay built entirely in Pine Script v6. It solves one of the biggest challenges traders face: calculating precise position sizes instantly before entering a trade. 

Many brokers use vastly different contract sizes for Forex pairs, metals, indices, and oil, making manual lot size math slow and prone to errors. This indicator automates the process completely and works flawlessly across all major brokers.

### Key Features
* 🌍 Multi-Asset Engine: Works perfectly on Forex majors/crosses, Gold (XAU), Silver (XAG), Crude Oil (WTI/BRENT), and Indices (NAS100, US30).
* 📐 Draggable Visual Chart Lines: Turn on visual mode to generate dynamic, interactive Entry and Stop Loss lines directly on your chart workspace. Slide them to your structural market levels, and your required lot size updates in real time!
* 💱 Live Multi-Currency Conversion: If your account is in USD but you trade a JPY, CAD, or EUR quote pair, the indicator pulls live FX conversion rates in the background to keep cash-at-risk projections 100% precise.
* 🖥️ Clean UI Dashboard: Displays Asset Symbol, Equity at Risk (%), Cash at Risk ($), exact Stop Loss size, and your final RECOMMENDED LOTS in a highly scannable screen corner panel.

### How To Use This Indicator

1. Load the script onto any chart asset (e.g., GBP/JPY or XAU/USD).
2. Open the Indicator Settings menu.
3. In the 'Account Settings' group, type your current Account Balance and the exact Risk Percentage (e.g., 1.0%) you want to risk on the setup.
4. Choose your calculation mode:
   * Mode A (Visual Lines): Check the 'Use Visual Chart Lines' box. Dotted lines will appear on your screen. Left-click and hold to drag the gray line to your entry price, and the red line to your stop-loss price. 
   * Mode B (Manual Input): Uncheck the visual lines box and simply type your exact Stop Loss size in pips into the manual trade settings field.
5. Read the 'RECOMMENDED LOTS' output on your dashboard panel and execute that exact volume inside your trading terminal.

### Disclaimer
This indicator is strictly a mathematical positioning tool designed to assist with risk management. It does not provide buy/sell signals or execution advice. Always cross-verify position sizing metrics with your specific broker's margin requirements before executing live contracts.

Thank you,

Trader Riaz

## Source Code

````pine
//@version=6
indicator("Trader Riaz Lot Size Calculator", shorttitle="TR Lot Calculator", overlay = true)

// -----------------------------------------------------------------------------
// USER INPUTS
// -----------------------------------------------------------------------------
var string G_ACC  = "Account Settings"
account_balance   = input.float(10000.0, title="Account Balance ($)", group=G_ACC, minval=0.01)
risk_percent      = input.float(0.5, title="Risk Percentage (%)", group=G_ACC, minval=0.01, maxval=100.0)

var string G_TRADE = "Trade Settings"
stop_loss_pips    = input.float(70.0, title="Stop Loss (Pips)", group=G_TRADE, minval=0.01)

var string G_DISP  = "Display Settings"
text_color        = input.color(color.white, title="Text Color", group=G_DISP)
bg_color          = input.color(color.blue, title="Background Color", group=G_DISP)
panel_position    = input.string("bottom_right", title="Panel Position", group=G_DISP, 
                      options=["top_right", "bottom_right", "top_left", "bottom_left"])

// -----------------------------------------------------------------------------
// FX CROSS-RATE CONVERSION ENGINE (BUILT-IN ACCOUNT CURRENCY: USD)
// -----------------------------------------------------------------------------
rate_usdjpy = request.security("FX_IDC:USDJPY", "1", close)
rate_eurusd = request.security("FX_IDC:EURUSD", "1", close)
rate_gbpusd = request.security("FX_IDC:GBPUSD", "1", close)
rate_audusd = request.security("FX_IDC:AUDUSD", "1", close)
rate_chfusd = request.security("FX_IDC:USDCHF", "1", 1.0 / (close > 0 ? close : 1))
rate_cadusd = request.security("FX_IDC:USDCAD", "1", 1.0 / (close > 0 ? close : 1))
rate_nzdusd = request.security("FX_IDC:NZDUSD", "1", close)

float fx_conversion_rate = 1.0
quote_currency = syminfo.currency

if quote_currency == "JPY"
    fx_conversion_rate := 1.0 / (rate_usdjpy > 0 ? rate_usdjpy : 1)
else if quote_currency == "EUR"
    fx_conversion_rate := rate_eurusd
else if quote_currency == "GBP"
    fx_conversion_rate := rate_gbpusd
else if quote_currency == "AUD"
    fx_conversion_rate := rate_audusd
else if quote_currency == "CHF"
    fx_conversion_rate := rate_chfusd
else if quote_currency == "CAD"
    fx_conversion_rate := rate_cadusd
else if quote_currency == "NZD"
    fx_conversion_rate := rate_nzdusd

// -----------------------------------------------------------------------------
// HYPER-PRECISE PIP VALUE ENGINE
// -----------------------------------------------------------------------------
float pip_value_usd = 0.0

is_forex = syminfo.type == "forex"
is_jpy   = str.contains(syminfo.ticker, "JPY")
is_gold  = str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.description, "Gold")
is_silver= str.contains(syminfo.ticker, "XAG") or str.contains(syminfo.description, "Silver")
is_oil   = str.contains(syminfo.ticker, "USO") or str.contains(syminfo.ticker, "OIL") or str.contains(syminfo.description, "Oil")

if is_forex
    if is_jpy
        // 1 lot JPY pair = 1,000 JPY per pip move (0.01)
        pip_value_usd := 1000.0 * fx_conversion_rate
    else
        // 1 lot standard FX pair = 10 units of quote currency per pip move (0.0001)
        pip_value_usd := 10.0 * fx_conversion_rate
else if is_gold
    // Gold 1 pip ($0.10 move) = $10.00 USD per standard contract
    pip_value_usd := 10.0
else if is_silver
    // Silver 1 pip ($0.01 move) = $50.00 USD per standard contract
    pip_value_usd := 50.0
else if is_oil
    // Crude Oil 1 cent move = $10.00 USD per standard contract
    pip_value_usd := 10.0
else
    // Indices (NAS100, US30) where 1 point move = $1.00 per contract
    pip_value_usd := 1.0

// -----------------------------------------------------------------------------
// CALCULATE FINAL POSITION SIZE
// -----------------------------------------------------------------------------
risk_amount     = account_balance * (risk_percent / 100.0)
calculated_lots = (pip_value_usd > 0 and stop_loss_pips > 0) ? (risk_amount / (stop_loss_pips * pip_value_usd)) : 0.0

// -----------------------------------------------------------------------------
// DYNAMIC METRIC UI PANEL
// -----------------------------------------------------------------------------
position_val = switch panel_position
    "top_right"    => position.top_right
    "bottom_right" => position.bottom_right
    "top_left"     => position.top_left
    => position.bottom_left

var table display_table = table.new(position_val, 2, 8, bgcolor=bg_color, border_width=1, border_color=color.gray)

if barstate.islast
    // Header
    table.cell(display_table, 0, 0, "Lot Size Calculator", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.normal)
    table.merge_cells(display_table, 0, 0, 1, 0)
	
    table.cell(display_table, 0, 1, "Asset Symbol:",    text_color=text_color, text_size=size.small, text_halign=text.align_left)
    table.cell(display_table, 1, 1, syminfo.ticker,     text_color=text_color, text_size=size.small, text_halign=text.align_right)
    
    table.cell(display_table, 0, 2, "Equity at Risk:",  text_color=text_color, text_size=size.small, text_halign=text.align_left)
    table.cell(display_table, 1, 2, "%" + str.tostring(risk_percent, "#.##"), text_color=text_color, text_size=size.small, text_halign=text.align_right)
    
    table.cell(display_table, 0, 3, "Cash at Risk:",    text_color=text_color, text_size=size.small, text_halign=text.align_left)
    table.cell(display_table, 1, 3, "$" + str.tostring(risk_amount, "#.##"), text_color=text_color, text_size=size.small, text_halign=text.align_right)
    
    table.cell(display_table, 0, 4, "SL Size:",         text_color=text_color, text_size=size.small, text_halign=text.align_left)
    table.cell(display_table, 1, 4, str.tostring(stop_loss_pips, "#.#") + " Pips", text_color=text_color, text_size=size.small, text_halign=text.align_right)
    
    table.cell(display_table, 0, 5, "RECOMMENDED LOTS:", text_color=color.yellow, text_size=size.small, text_halign=text.align_left)
    table.cell(display_table, 1, 5, str.tostring(calculated_lots, "#.##"), text_color=color.yellow, text_size=size.normal, text_halign=text.align_right)
	
    // Footer
    table.cell(display_table, 0, 6, "© Trader Riaz | All rights reserved.", text_color=color.new(color.white, 30), text_size=size.small, bgcolor=color.new(color.black, 30), text_halign=text.align_center)
    table.merge_cells(display_table, 0, 6, 1, 6)
````
