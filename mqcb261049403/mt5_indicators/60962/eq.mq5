//+------------------------------------------------------------------+
//|                                                           EQ.mq5 |
//|                                    Copyright 2025, by Ivan Butko |
//|                        https://www.mql5.com/ru/users/capitalplus |
//+------------------------------------------------------------------+
//|            Historical equity of virtual positions                |
//|------------------------------------------------------------------+
//| PURPOSE:                                                         |
//| Calculate virtual equity of a portfolio for:                     |
//| - identification of volatile-flat structures                     |
//| - Analyzing spread trading efficiency                            |
//| - Determining entry/exit points for equity trading               |
//|                                                                  |
//| OPERATION PRINCIPLE:                                             |
//| - For each active pair, set volume, direction, and activation    |
//| - Cumulative profit/loss from all positions is calculated        |
//| - Result displayed as equity line in subwindow                   |
//|                                                                  |
//| HOW TO USE:                                                      |
//| 1. Configure volumes, directions, and activation for pairs       |
//| 2. Specify symbol suffix (if required)                           |
//| 3. Set history depth for drawing (in bars)                       |
//| 4. Set initial balance (optional)                                |
//+------------------------------------------------------------------+

//--- Indicator description ------------------------------------------
#property description "Historical virtual equity indicator"
#property description ""
#property description "Purpose:"
#property description "- Modeling (simulate) portfolio behavior with selected symbols"
#property description "- Visualizing combined instrument movements"
#property description ""
#property description "Applications:"
#property description "- Identifying volatility-flat patterns for spread/equity trading"
#property description "- Visual analysis of 'channel boundary' flat strategy effectiveness"

//--- Indicator display directives (internal settings)
#property indicator_separate_window                   // Display in separate window
#property indicator_buffers 1                         // One data buffer
#property indicator_plots   1                         // Connect drawing to buffer (equal to buffer count)
#property indicator_type1   DRAW_LINE                 // Drawing type: line graph 
#property indicator_color1  clrDodgerBlue             // Indicator line color
#property indicator_width1  1                         // Line width
#property indicator_label1  "Virtual Equity"          // Line label

//--- Trade direction enumeration (defines virtual position type per instrument)
// Later in code: DIR_BUY = 1, DIR_SELL = -1
enum ENUM_TRADE_DIRECTION 
  {
    DIR_BUY,    // BUY
    DIR_SELL    // SELL
  };            

// ------------ Position volume (lot) parameters ------------

input group "==== Volume ===="
// Majors
input double Lot_EURUSD = 1.0;   // EURUSD
input double Lot_GBPUSD = 1.0;   // GBPUSD
input double Lot_USDJPY = 1.0;   // USDJPY
input double Lot_USDCHF = 1.0;   // USDCHF
input double Lot_AUDUSD = 1.0;   // AUDUSD
input double Lot_USDCAD = 1.0;   // USDCAD
input double Lot_NZDUSD = 1.0;   // NZDUSD

// Euro crosses
input double Lot_EURGBP = 1.0;   // EURGBP
input double Lot_EURJPY = 1.0;   // EURJPY
input double Lot_EURCHF = 1.0;   // EURCHF
input double Lot_EURAUD = 1.0;   // EURAUD
input double Lot_EURCAD = 1.0;   // EURCAD
input double Lot_EURNZD = 1.0;   // EURNZD

// Pound crosses
input double Lot_GBPJPY = 1.0;   // GBPJPY
input double Lot_GBPCHF = 1.0;   // GBPCHF
input double Lot_GBPAUD = 1.0;   // GBPAUD
input double Lot_GBPCAD = 1.0;   // GBPCAD
input double Lot_GBPNZD = 1.0;   // GBPNZD

// Yen crosses
input double Lot_CHFJPY = 1.0;   // CHFJPY
input double Lot_AUDJPY = 1.0;   // AUDJPY
input double Lot_CADJPY = 1.0;   // CADJPY
input double Lot_NZDJPY = 1.0;   // NZDJPY

// Other crosses
input double Lot_AUDCHF = 1.0;   // AUDCHF
input double Lot_AUDCAD = 1.0;   // AUDCAD
input double Lot_AUDNZD = 1.0;   // AUDNZD
input double Lot_CADCHF = 1.0;   // CADCHF
input double Lot_NZDCHF = 1.0;   // NZDCHF
input double Lot_NZDCAD = 1.0;   // NZDCAD

// ------------ Position direction parameters ------------

input group "==== Direction ===="
// Majors
input ENUM_TRADE_DIRECTION Dir_EURUSD = DIR_BUY;   // EURUSD
input ENUM_TRADE_DIRECTION Dir_GBPUSD = DIR_SELL;  // GBPUSD
input ENUM_TRADE_DIRECTION Dir_USDJPY = DIR_BUY;   // USDJPY
input ENUM_TRADE_DIRECTION Dir_USDCHF = DIR_SELL;  // USDCHF
input ENUM_TRADE_DIRECTION Dir_AUDUSD = DIR_SELL;  // AUDUSD
input ENUM_TRADE_DIRECTION Dir_USDCAD = DIR_BUY;   // USDCAD
input ENUM_TRADE_DIRECTION Dir_NZDUSD = DIR_BUY;   // NZDUSD

// Euro crosses
input ENUM_TRADE_DIRECTION Dir_EURGBP = DIR_SELL;  // EURGBP
input ENUM_TRADE_DIRECTION Dir_EURJPY = DIR_BUY;   // EURJPY
input ENUM_TRADE_DIRECTION Dir_EURCHF = DIR_SELL;  // EURCHF
input ENUM_TRADE_DIRECTION Dir_EURAUD = DIR_BUY;   // EURAUD
input ENUM_TRADE_DIRECTION Dir_EURCAD = DIR_SELL;  // EURCAD
input ENUM_TRADE_DIRECTION Dir_EURNZD = DIR_SELL;  // EURNZD

// Pound crosses
input ENUM_TRADE_DIRECTION Dir_GBPJPY = DIR_SELL;  // GBPJPY
input ENUM_TRADE_DIRECTION Dir_GBPCHF = DIR_BUY;   // GBPCHF
input ENUM_TRADE_DIRECTION Dir_GBPAUD = DIR_BUY;   // GBPAUD
input ENUM_TRADE_DIRECTION Dir_GBPCAD = DIR_SELL;  // GBPCAD
input ENUM_TRADE_DIRECTION Dir_GBPNZD = DIR_BUY;   // GBPNZD

// Yen crosses
input ENUM_TRADE_DIRECTION Dir_CHFJPY = DIR_BUY;   // CHFJPY
input ENUM_TRADE_DIRECTION Dir_AUDJPY = DIR_SELL;  // AUDJPY
input ENUM_TRADE_DIRECTION Dir_CADJPY = DIR_BUY;   // CADJPY
input ENUM_TRADE_DIRECTION Dir_NZDJPY = DIR_SELL;  // NZDJPY

// Other crosses
input ENUM_TRADE_DIRECTION Dir_AUDCHF = DIR_BUY;   // AUDCHF
input ENUM_TRADE_DIRECTION Dir_AUDCAD = DIR_SELL;  // AUDCAD
input ENUM_TRADE_DIRECTION Dir_AUDNZD = DIR_BUY;   // AUDNZD
input ENUM_TRADE_DIRECTION Dir_CADCHF = DIR_BUY;   // CADCHF
input ENUM_TRADE_DIRECTION Dir_NZDCHF = DIR_SELL;  // NZDCHF
input ENUM_TRADE_DIRECTION Dir_NZDCAD = DIR_BUY;   // NZDCAD

// ------------ Symbol selection parameters for basket inclusion ------------

input group "==== Activation ===="
// Majors
input bool Enable_EURUSD = true;   // EURUSD
input bool Enable_GBPUSD = false;   // GBPUSD
input bool Enable_USDJPY = false;   // USDJPY
input bool Enable_USDCHF = false;   // USDCHF
input bool Enable_AUDUSD = false;   // AUDUSD
input bool Enable_USDCAD = false;   // USDCAD
input bool Enable_NZDUSD = false;   // NZDUSD

// Euro crosses
input bool Enable_EURGBP = false;   // EURGBP
input bool Enable_EURJPY = false;   // EURJPY
input bool Enable_EURCHF = false;   // EURCHF
input bool Enable_EURAUD = false;   // EURAUD
input bool Enable_EURCAD = false;   // EURCAD
input bool Enable_EURNZD = false;   // EURNZD

// Pound crosses
input bool Enable_GBPJPY = false;   // GBPJPY
input bool Enable_GBPCHF = false;   // GBPCHF
input bool Enable_GBPAUD = false;   // GBPAUD
input bool Enable_GBPCAD = false;   // GBPCAD
input bool Enable_GBPNZD = false;   // GBPNZD

// Yen crosses
input bool Enable_CHFJPY = false;   // CHFJPY
input bool Enable_AUDJPY = false;   // AUDJPY
input bool Enable_CADJPY = false;   // CADJPY
input bool Enable_NZDJPY = false;   // NZDJPY

// Other crosses
input bool Enable_AUDCHF = false;   // AUDCHF
input bool Enable_AUDCAD = false;   // AUDCAD
input bool Enable_AUDNZD = false;   // AUDNZD
input bool Enable_CADCHF = false;   // CADCHF
input bool Enable_NZDCHF = false;   // NZDCHF
input bool Enable_NZDCAD = false;   // NZDCAD

// ------------ Additional parameters ------------

input group "==== Other settings ===="
input string Symbo_suffix   = "";     // Symbol suffix 
input int Bars_to_calculate   = 1000; // Drawing depth in bars (should be < available symbol history) 
input double Initial_balance = 0;     // Initial virtual balance (optional)
enum ENUM_OUTPUT_MODE {
    OUTPUT_NONE,        // Do not output
    OUTPUT_PRINT,       // Only to journal
    OUTPUT_COMMENT,     // Only on chart
    OUTPUT_BOTH         // To journal and chart
};
input ENUM_OUTPUT_MODE InfoOutput = OUTPUT_BOTH;  // Information output mode


// ------------ Internal variables ------------

//--- List of tracked currency pairs
string currency_symbol[] = 
  {
    // Majors (7)
    "EURUSD", "GBPUSD", "USDJPY", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD",
    
    // Euro crosses (6)
    "EURGBP", "EURJPY", "EURCHF", "EURAUD", "EURCAD", "EURNZD",
    
    // Pound crosses (6)
    "GBPJPY", "GBPCHF", "GBPAUD", "GBPCAD", "GBPNZD",
    
    // Yen crosses (4)
    "CHFJPY", "AUDJPY", "CADJPY", "NZDJPY",
    
    // Other crosses (5)
    "AUDCHF", "AUDCAD", "AUDNZD", "CADCHF", "NZDCHF", "NZDCAD"
  };

// Buffers
double Equity_buffer[];               // main buffer for equity values

// Global variables
double initial_prices[];              // prices on starting bar for change calculation
int directions[];                     // converted directions (1/-1)
int bars_count[];                     // available history for each symbol
string settings_info = "";            // storage for settings information
int total_symbols = 0;                // symbol count

bool start_flag = true;
bool start_chart_flag = true;




//+------------------------------------------------------------------+
//|                    Indicator initialization                      |
//+------------------------------------------------------------------+
int OnInit()
  {
    // Determine total number of symbols
    total_symbols = ArraySize(currency_symbol);
    
    // Initialize data arrays
    ArrayResize(initial_prices, total_symbols);
    ArrayResize(directions, total_symbols);
    ArrayResize(bars_count, total_symbols);
    
    // Initialize data buffer
    SetIndexBuffer(0, Equity_buffer, INDICATOR_DATA);  // bind to indicator
    ArraySetAsSeries(Equity_buffer, true);             // reverse order (new data at array start)
    
    // Number of decimal places (will express cents)
    IndicatorSetInteger(INDICATOR_DIGITS, 2);
    
    // Set timer to 1 second
    EventSetTimer(1);
    
    return INIT_SUCCEEDED;
  }



//+------------------------------------------------------------------+
//|                          Execution blocks                         |
//+------------------------------------------------------------------+
void OnTimer() {Main();}
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {Main(); return rates_total;}




//+------------------------------------------------------------------+
//|                     MAIN CODE BLOCK                              |
//+------------------------------------------------------------------+
void Main()
  {
    int start = 0;
    
    // First run (historical pass) 
    if (start_flag)
      {
        ArrayInitialize(Equity_buffer, EMPTY_VALUE);
        
        datetime start_time = iTime(_Symbol, _Period, Bars_to_calculate); // determine start bar time in history
    
          // Initialize data for each symbol
          for (int i = 0; i < total_symbols; i++)  
          {
              string pair = currency_symbol[i];           // select symbol from array
              if (!Is_Pair_Enabled(pair)) 
                continue;                                 // skip inactive symbols              
              string symbol = Get_Full_Symbol_Name(pair); // get full symbol name (check for suffix)
               
              // Check symbol availability both in Market Watch and sufficient history
              bool symbol_check = Check_symbols(symbol);
              if (!symbol_check)
                return; 
                  
              directions[i] = Get_Direction_By_Pair(pair); // get symbol direction and fill array
          }
          
          // Initialize starting prices
          for(int i = 0; i < total_symbols; i++) 
            {
              if (!Is_Pair_Enabled(currency_symbol[i])) continue;
              string symbol = Get_Full_Symbol_Name(currency_symbol[i]);
              initial_prices[i] = iOpen(symbol, _Period, Bars_to_calculate);
            }

          Print_Settings(); // Output settings information          
          start = Bars_to_calculate;          
          start_flag = false;
      }
    else
      { 
        start = 0;
        if (start_chart_flag) ChartRedraw();
        start_chart_flag = false;
      }

    // Main loop
    for (int i = start; i >= 0; i--)
      {
        double EQ = Initial_balance;             // set initial balance per settings
        for (int j = 0; j < total_symbols; j++)  // loop through symbols
          {
            string pair = currency_symbol[j];
            if (!Is_Pair_Enabled(pair)) continue;
            string symbol = Get_Full_Symbol_Name(pair);
            double current_close = iClose(symbol, _Period, i);  // get close price on each bar and compare to start
            if (current_close == 0) continue;

            double initial_price = initial_prices[j];
            double price_change_in_points = (current_close - initial_price) / SymbolInfoDouble(symbol, SYMBOL_POINT); // difference between current (iterative) price and start

            double point_value = Calculate_point_value(symbol);                 // calculate point value
            double lot = Get_Lot_By_Symbol(pair);                               // get volume
            int direction = directions[j];                                      // get direction

            double eq = price_change_in_points * direction * lot * point_value; // calculate virtual equity
            EQ += eq;                                                           // sum into total equity
          }

        Equity_buffer[i] = EQ;                                                  // draw
      }
  }



//+--------------------------------------------------------------------------------+
//|                         Get full symbol name                                   |
//+--------------------------------------------------------------------------------+
string Get_Full_Symbol_Name(string baseSymbol)     {return baseSymbol + Symbo_suffix;}

//+------------------------------------------------------------------+
//|                   Check symbol availability                      |
//+------------------------------------------------------------------+
bool Check_symbols(string sym)
  {
    if (!SymbolSelect(sym, true))     
      { 
        Print(sym + " - error: symbol not found in Market Watch!");        
        return false; 
      }
    
    // Commented out code block for loading all TFs from start date.
    // If performance is needed - activate entire block.
    // If memory saving is needed - use only current TF 
    if (
        iClose(sym, PERIOD_CURRENT, Bars_to_calculate) <= 0
        )     
      { 
        Comment("LOADING HISTORY: " + sym);             
        return false;           
      }
    
    return true;
  }

//+------------------------------------------------------------------------------+
//|       Calculate point value in standard deposit currency (USD)               |
//+------------------------------------------------------------------------------+
double Calculate_point_value(string symbol)
  {
    double tick_value  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
    double tick_size   = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    double point       = SymbolInfoDouble(symbol, SYMBOL_POINT);
    
    return tick_value * (point / tick_size);
  }

//+------------------------------------------+
//|         Get lot by symbol                |
//+------------------------------------------+
double Get_Lot_By_Symbol(string pair)
  {
    if (pair == "EURUSD") return Lot_EURUSD;
    if (pair == "GBPUSD") return Lot_GBPUSD;
    if (pair == "USDJPY") return Lot_USDJPY;
    if (pair == "USDCHF") return Lot_USDCHF;
    if (pair == "AUDUSD") return Lot_AUDUSD;
    if (pair == "USDCAD") return Lot_USDCAD;
    if (pair == "NZDUSD") return Lot_NZDUSD;
    if (pair == "EURGBP") return Lot_EURGBP;
    if (pair == "EURJPY") return Lot_EURJPY;
    if (pair == "EURCHF") return Lot_EURCHF;
    if (pair == "EURAUD") return Lot_EURAUD;
    if (pair == "EURCAD") return Lot_EURCAD;
    if (pair == "EURNZD") return Lot_EURNZD;
    if (pair == "GBPJPY") return Lot_GBPJPY;
    if (pair == "GBPCHF") return Lot_GBPCHF;
    if (pair == "GBPAUD") return Lot_GBPAUD;
    if (pair == "GBPCAD") return Lot_GBPCAD;
    if (pair == "GBPNZD") return Lot_GBPNZD;
    if (pair == "CHFJPY") return Lot_CHFJPY;
    if (pair == "AUDJPY") return Lot_AUDJPY;
    if (pair == "CADJPY") return Lot_CADJPY;
    if (pair == "NZDJPY") return Lot_NZDJPY;
    if (pair == "AUDCHF") return Lot_AUDCHF;
    if (pair == "AUDCAD") return Lot_AUDCAD;
    if (pair == "AUDNZD") return Lot_AUDNZD;
    if (pair == "CADCHF") return Lot_CADCHF;
    if (pair == "NZDCHF") return Lot_NZDCHF;
    if (pair == "NZDCAD") return Lot_NZDCAD;
    return 0;
  }

//+------------------------------------------------------------------+
//|                 Get direction by symbol                          |
//+------------------------------------------------------------------+
int Get_Direction_By_Pair(string pair)
  {
    if (pair == "EURUSD") return (Dir_EURUSD == DIR_BUY) ? 1 : -1;
    if (pair == "GBPUSD") return (Dir_GBPUSD == DIR_BUY) ? 1 : -1;
    if (pair == "USDJPY") return (Dir_USDJPY == DIR_BUY) ? 1 : -1;
    if (pair == "USDCHF") return (Dir_USDCHF == DIR_BUY) ? 1 : -1;
    if (pair == "AUDUSD") return (Dir_AUDUSD == DIR_BUY) ? 1 : -1;
    if (pair == "USDCAD") return (Dir_USDCAD == DIR_BUY) ? 1 : -1;
    if (pair == "NZDUSD") return (Dir_NZDUSD == DIR_BUY) ? 1 : -1;
    if (pair == "EURGBP") return (Dir_EURGBP == DIR_BUY) ? 1 : -1;
    if (pair == "EURJPY") return (Dir_EURJPY == DIR_BUY) ? 1 : -1;
    if (pair == "EURCHF") return (Dir_EURCHF == DIR_BUY) ? 1 : -1;
    if (pair == "EURAUD") return (Dir_EURAUD == DIR_BUY) ? 1 : -1;
    if (pair == "EURCAD") return (Dir_EURCAD == DIR_BUY) ? 1 : -1;
    if (pair == "EURNZD") return (Dir_EURNZD == DIR_BUY) ? 1 : -1;
    if (pair == "GBPJPY") return (Dir_GBPJPY == DIR_BUY) ? 1 : -1;
    if (pair == "GBPCHF") return (Dir_GBPCHF == DIR_BUY) ? 1 : -1;
    if (pair == "GBPAUD") return (Dir_GBPAUD == DIR_BUY) ? 1 : -1;
    if (pair == "GBPCAD") return (Dir_GBPCAD == DIR_BUY) ? 1 : -1;
    if (pair == "GBPNZD") return (Dir_GBPNZD == DIR_BUY) ? 1 : -1;
    if (pair == "CHFJPY") return (Dir_CHFJPY == DIR_BUY) ? 1 : -1;
    if (pair == "AUDJPY") return (Dir_AUDJPY == DIR_BUY) ? 1 : -1;
    if (pair == "CADJPY") return (Dir_CADJPY == DIR_BUY) ? 1 : -1;
    if (pair == "NZDJPY") return (Dir_NZDJPY == DIR_BUY) ? 1 : -1;
    if (pair == "AUDCHF") return (Dir_AUDCHF == DIR_BUY) ? 1 : -1;
    if (pair == "AUDCAD") return (Dir_AUDCAD == DIR_BUY) ? 1 : -1;
    if (pair == "AUDNZD") return (Dir_AUDNZD == DIR_BUY) ? 1 : -1;
    if (pair == "CADCHF") return (Dir_CADCHF == DIR_BUY) ? 1 : -1;
    if (pair == "NZDCHF") return (Dir_NZDCHF == DIR_BUY) ? 1 : -1;
    if (pair == "NZDCAD") return (Dir_NZDCAD == DIR_BUY) ? 1 : -1;
    return 0;
  }

//+-------------------------------------------+
//|          Check pair activation            |
//+-------------------------------------------+
bool Is_Pair_Enabled(string pair)
  {
    if (pair == "EURUSD") return Enable_EURUSD;
    if (pair == "GBPUSD") return Enable_GBPUSD;
    if (pair == "USDJPY") return Enable_USDJPY;
    if (pair == "USDCHF") return Enable_USDCHF;
    if (pair == "AUDUSD") return Enable_AUDUSD;
    if (pair == "USDCAD") return Enable_USDCAD;
    if (pair == "NZDUSD") return Enable_NZDUSD;
    if (pair == "EURGBP") return Enable_EURGBP;
    if (pair == "EURJPY") return Enable_EURJPY;
    if (pair == "EURCHF") return Enable_EURCHF;
    if (pair == "EURAUD") return Enable_EURAUD;
    if (pair == "EURCAD") return Enable_EURCAD;
    if (pair == "EURNZD") return Enable_EURNZD;
    if (pair == "GBPJPY") return Enable_GBPJPY;
    if (pair == "GBPCHF") return Enable_GBPCHF;
    if (pair == "GBPAUD") return Enable_GBPAUD;
    if (pair == "GBPCAD") return Enable_GBPCAD;
    if (pair == "GBPNZD") return Enable_GBPNZD;
    if (pair == "CHFJPY") return Enable_CHFJPY;
    if (pair == "AUDJPY") return Enable_AUDJPY;
    if (pair == "CADJPY") return Enable_CADJPY;
    if (pair == "NZDJPY") return Enable_NZDJPY;
    if (pair == "AUDCHF") return Enable_AUDCHF;
    if (pair == "AUDCAD") return Enable_AUDCAD;
    if (pair == "AUDNZD") return Enable_AUDNZD;
    if (pair == "CADCHF") return Enable_CADCHF;
    if (pair == "NZDCHF") return Enable_NZDCHF;
    if (pair == "NZDCAD") return Enable_NZDCAD;
    return false;
  }

//+------------------------------------------------------------+
//|          Print detailed indicator settings                 |
//+------------------------------------------------------------+
void Print_Settings()
  {
    Print("");
    
    // Clear previous information
    settings_info = "";
    string print_info = "";  // For journal only
    string comment_info = ""; // For chart only
    string new_line = "\n";
    
    // Calculate number of active instruments
    int active_count = 0;
    for (int i = 0; i < total_symbols; i++)  // Replaced 28 with total_symbols
        if (Is_Pair_Enabled(currency_symbol[i])) active_count++;
    
    // === JOURNAL PART (full information) ===
    // Form header for journal only
    string header = "=== VIRTUAL EQUITY SETTINGS ===";
    
    print_info += new_line;
    print_info += header + new_line;
    
    // Determine max symbol name length
    int max_symbol_len = 0;
    for (int i = 0; i < total_symbols; i++)
      {
        if (!Is_Pair_Enabled(currency_symbol[i])) continue;
        int len = StringLen(currency_symbol[i]);
        if (len > max_symbol_len) max_symbol_len = len;
      }
    int field_width = max_symbol_len;
    
    // Active instruments block (for both outputs)
    string common_info = new_line + "Active symbols:" + new_line;
    
    for (int i = 0; i < total_symbols; i++)
      {
        if (!Is_Pair_Enabled(currency_symbol[i])) continue;
        
        string dir_str = (Get_Direction_By_Pair(currency_symbol[i]) == 1) ? "BUY" : "SELL";
        string arrow = (dir_str == "BUY") ? "▲" : "▼";
        
        // Form aligned string
        string symbol_field = StringFormat("%-" + IntegerToString(field_width) + "s", currency_symbol[i]);
        string entry = StringFormat("%s %s %-4s %.2f", symbol_field, arrow, dir_str, Get_Lot_By_Symbol(currency_symbol[i]));
        
        common_info += entry + new_line;
      }
    
    // Common parameters block (journal only)
    print_info += common_info + new_line;
    print_info += "General parameters:" + new_line;
    print_info += "Symbol suffix: " + (Symbo_suffix == "" ? "not specified" : Symbo_suffix) + new_line;
    print_info += "Bars to calculate: " + IntegerToString(Bars_to_calculate) + new_line;
    print_info += "Initial balance: " + DoubleToString(Initial_balance, 2) + new_line;
    
    // Warnings block (journal only)
    bool warning = false;
    string warn_text = new_line + "WARNINGS:";
   
    // Check active instruments
    if (active_count == 0)
      {
        warn_text += new_line + "• No active instruments! Indicator won't work";
        warning = true;
      }
    
    // Add warnings if necessary
    if (warning)
      {
        print_info += warn_text + new_line;
        print_info += "Recommendation: Check activation settings and data availability" + new_line;
      }
    
    // === CHART PART (active instruments only) ===
    comment_info = "Active symbols:" + new_line;
    for(int i = 0; i < total_symbols; i++)
      {
        if (!Is_Pair_Enabled(currency_symbol[i])) continue;
        
        string dir_str = (Get_Direction_By_Pair(currency_symbol[i]) == 1) ? "BUY" : "SELL";
        string arrow = (dir_str == "BUY") ? "▲" : "▼";
        
        // Form short string for chart
        comment_info += StringFormat("%s %s %.1f", currency_symbol[i], arrow, Get_Lot_By_Symbol(currency_symbol[i])) + new_line;
      }
    
    // If no active instruments - show warning
    if (active_count == 0)
        comment_info = "WARNING!\nNo active\ninstruments";
    
    // Final output per mode
    switch(InfoOutput)
      {
        case OUTPUT_PRINT:
            Print(print_info);
            break;
        case OUTPUT_COMMENT:
            Comment(comment_info);
            break;
        case OUTPUT_BOTH:
            Print(print_info);
            Comment(comment_info);
            break;
        case OUTPUT_NONE:
        default:
            // No output
            break;
      }
  }

//+------------------------------------------------------------------+
//| Clear comment on deinitialization                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
    if (InfoOutput == OUTPUT_COMMENT || InfoOutput == OUTPUT_BOTH)
    {
        Comment("");
    }
    
    // Disable timer
    EventKillTimer();
  }