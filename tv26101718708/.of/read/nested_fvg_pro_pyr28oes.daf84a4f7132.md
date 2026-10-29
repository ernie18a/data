Calculation: Bullish FVG = a completed bar’s low > the high two bars earlier; gap is between those prices. On the higher timeframe, use only the last completed bars; on the chart timeframe, use confirmed bars.
Calculation: Bearish FVG = a completed bar’s high < the low two bars earlier; gap is between those prices. On the higher timeframe, use only the last completed bars; on the chart timeframe, use confirmed bars.
Long: A chart-timeframe bullish FVG meets its minimum size AND its gap lies within an active, matching higher-timeframe bullish FVG zone expanded by the configured proximity tolerance; the zone meets its minimum size and is either unviolated or an eligible inverted zone; datetime passes the configured session and enabled windows; daily loss is below its limit; cooldown has elapsed; and there is no open or pending trade.
Short: A chart-timeframe bearish FVG meets its minimum size AND its gap lies within an active, matching higher-timeframe bearish FVG zone expanded by the configured proximity tolerance; the zone meets its minimum size and is either unviolated or an eligible inverted zone; datetime passes the configured session and enabled windows; daily loss is below its limit; cooldown has elapsed; and there is no open or pending trade.
Exit: Long, low <= initial stop before partial target is reached.
Exit: Short, high >= initial stop before partial target is reached.
Exit: Long, high >= partial target; close the configured partial quantity and, if enabled, move the stop to the entry fill.
Exit: Short, low <= partial target; close the configured partial quantity and, if enabled, move the stop to the entry fill.
Exit: Long, high >= main target after partial; close the configured quantity.
Exit: Short, low <= main target after partial; close the configured quantity.
Exit: Long, high >= extended target after main target; close the configured quantity.
Exit: Short, low <= extended target after main target; close the configured quantity.
Exit: Long, high >= runner target after extended target; close the remaining runner quantity.
Exit: Short, low <= runner target after extended target; close the remaining runner quantity.
Exit: Long, low <= moved stop after partial, on a later bar than the partial; close the remaining position.
Exit: Short, high >= moved stop after partial, on a later bar than the partial; close the remaining position.
Exit: Long, close-price unrealized loss on the remaining position exceeds the configured per-trade dollar limit.
Exit: Short, close-price unrealized loss on the remaining position exceeds the configured per-trade dollar limit.