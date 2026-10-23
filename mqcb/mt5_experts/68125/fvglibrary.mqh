//+------------------------------------------------------------------+
//|                                                   FVGLibrary.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"

//--- Structure to store FVG information
struct FVGInfo
{
   int fvg_id;             // FVG unique ID
   int middle_candle_bar;  // Bar index of the middle candle (candle 2)
   datetime candle_time;   // Time of the middle candle
   double top_price;       // Top price of FVG gap
   double bottom_price;    // Bottom price of FVG gap
   double enc_point;       // Encroachment point (0.5 level of gap)
   double gap_size;        // Gap size in points
   bool is_bullish;        // True for bullish FVG, false for bearish
   bool is_active;         // True if FVG is still active (ENC not touched)
   bool enc_touched;       // True if encroachment point has been touched
   string directional_bias; // "BULLISH", "BEARISH", "PENDING", or "RESET"
   ulong trade_ticket;     // Ticket of the trade opened for this FVG
   bool trade_opened;      // True if trade has been opened for this FVG
   datetime enc_time;      // Time when encroachment occurred
   bool is_inverse;        // True if this was an inverse FVG (candle shot through)
   bool is_reset;          // True if FVG was reset by inverse candle
};

//--- Callback function type for FVG events
typedef void (*FVGCallback)(FVGInfo& fvg, string event_type);

//+------------------------------------------------------------------+
//| FVG Library Class                                                |
//+------------------------------------------------------------------+
class CFVGLibrary
{
private:
   FVGInfo           m_fvg_list[];        // Array of FVGs
   int               m_fvg_count;         // Current count of FVGs
   int               m_next_fvg_id;       // Next FVG ID to assign
   int               m_bars_total;        // Total bars for new bar detection
   string            m_symbol;            // Symbol to monitor
   ENUM_TIMEFRAMES   m_timeframe;         // Timeframe for FVG detection
   ENUM_TIMEFRAMES   m_accuracy_tf;       // Timeframe for accuracy mode
   double            m_min_gap_size;      // Minimum gap size in points
   bool              m_use_accuracy;      // Use accuracy mode
   FVGCallback       m_callback;          // Callback function
   bool              m_draw_objects;      // Draw visual objects on chart
   
public:
   // Constructor
   CFVGLibrary(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_M5, 
               ENUM_TIMEFRAMES accuracy_tf = PERIOD_M1, double min_gap_size = 50.0,
               bool use_accuracy = false, bool draw_objects = true);
   
   // Destructor
   ~CFVGLibrary();
   
   // Core functions
   bool              Init();
   void              Deinit();
   void              OnTick();
   void              OnNewBar();
   
   // Configuration functions
   void              SetCallback(FVGCallback callback) { m_callback = callback; }
   void              SetMinGapSize(double gap_size) { m_min_gap_size = gap_size; }
   void              SetAccuracy(bool use_accuracy) { m_use_accuracy = use_accuracy; }
   void              SetDrawObjects(bool draw) { m_draw_objects = draw; }
   
   // FVG management functions
   void              CheckForNewFVG();
   void              CheckFVGEncroachment();
   void              CheckFVGEncroachmentHighAccuracy();
   void              CheckForInverseFVG();
   bool              CreateFVG(int middle_bar, datetime candle_time, double top, 
                              double bottom, double gap_size, bool is_bullish);
   
   // Utility functions
   int               GetFVGCount() const { return m_fvg_count; }
   int               GetActiveFVGsCount() const;
   FVGInfo           GetFVGByIndex(int index);
   FVGInfo           GetFVGById(int fvg_id);
   void              DeactivateFVG(int fvg_id);
   void              AssociateTradeWithFVG(int fvg_id, ulong ticket);
   
   // Visual functions
   void              PlotFVGDot(int bar_index, datetime candle_time, bool is_bullish, int fvg_id);
   void              PlotEncroachmentDot(int fvg_id, string bias);
   void              CleanupObjects();
   
   // Statistics
   void              PrintFVGStats() const;
   double            GetFillRate() const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CFVGLibrary::CFVGLibrary(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_M5, 
                        ENUM_TIMEFRAMES accuracy_tf = PERIOD_M1, double min_gap_size = 50.0,
                        bool use_accuracy = false, bool draw_objects = true)
{
   m_symbol = (symbol == "") ? _Symbol : symbol;
   m_timeframe = timeframe;
   m_accuracy_tf = accuracy_tf;
   m_min_gap_size = min_gap_size;
   m_use_accuracy = use_accuracy;
   m_draw_objects = draw_objects;
   m_fvg_count = 0;
   m_next_fvg_id = 1;
   m_bars_total = 0;
   m_callback = NULL;
   
   ArrayResize(m_fvg_list, 100);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CFVGLibrary::~CFVGLibrary()
{
   Deinit();
}

//+------------------------------------------------------------------+
//| Initialize the library                                           |
//+------------------------------------------------------------------+
bool CFVGLibrary::Init()
{
   Print("=== FVG Library Initialized ===");
   Print("Symbol: ", m_symbol);
   Print("Timeframe: ", EnumToString(m_timeframe));
   Print("Minimum Gap Size: ", m_min_gap_size, " points");
   Print("Accuracy Mode: ", (m_use_accuracy ? "ON" : "OFF"));
   
   if(m_draw_objects)
      CleanupObjects();
   
   m_fvg_count = 0;
   m_next_fvg_id = 1;
   m_bars_total = iBars(m_symbol, m_timeframe);
   
   return true;
}

//+------------------------------------------------------------------+
//| Deinitialize the library                                         |
//+------------------------------------------------------------------+
void CFVGLibrary::Deinit()
{
   if(m_draw_objects)
      CleanupObjects();
   
   Print("=== FVG Library Deinitialized ===");
   Print("Total FVGs detected: ", m_fvg_count);
}

//+------------------------------------------------------------------+
//| Main tick function                                               |
//+------------------------------------------------------------------+
void CFVGLibrary::OnTick()
{
   // Check for new bars
   int current_bars = iBars(m_symbol, m_timeframe);
   if(current_bars > m_bars_total)
   {
      m_bars_total = current_bars;
      OnNewBar();
   }
   
   // Check for inverse FVGs (resets)
   CheckForInverseFVG();
   
   // Check encroachment
   if(m_use_accuracy)
      CheckFVGEncroachmentHighAccuracy();
   else
      CheckFVGEncroachment();
}

//+------------------------------------------------------------------+
//| New bar event                                                    |
//+------------------------------------------------------------------+
void CFVGLibrary::OnNewBar()
{
   CheckForNewFVG();
}

//+------------------------------------------------------------------+
//| Check for new FVG formation                                      |
//+------------------------------------------------------------------+
void CFVGLibrary::CheckForNewFVG()
{
   int bars_available = iBars(m_symbol, m_timeframe);
   if(bars_available < 4) return;
   
   // Get OHLC data for three consecutive bars
   double high1 = iHigh(m_symbol, m_timeframe, 3);   // First candle (oldest)
   double low1 = iLow(m_symbol, m_timeframe, 3);
   
   double high2 = iHigh(m_symbol, m_timeframe, 2);   // Middle candle (gap candle)
   double low2 = iLow(m_symbol, m_timeframe, 2);
   
   double high3 = iHigh(m_symbol, m_timeframe, 1);   // Third candle (newest completed)
   double low3 = iLow(m_symbol, m_timeframe, 1);
   
   datetime middle_candle_time = iTime(m_symbol, m_timeframe, 2);
   
   // Convert minimum gap size from points to price
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   double min_gap_price = m_min_gap_size * point;
   
   // Check for Bullish FVG (gap up - candle 1 high < candle 3 low)
   if(high1 < low3)
   {
      double gap_size = low3 - high1;
      if(gap_size >= min_gap_price)
      {
         CreateFVG(2, middle_candle_time, low3, high1, gap_size, true);
      }
   }
   // Check for Bearish FVG (gap down - candle 1 low > candle 3 high)
   else if(low1 > high3)
   {
      double gap_size = low1 - high3;
      if(gap_size >= min_gap_price)
      {
         CreateFVG(2, middle_candle_time, low1, high3, gap_size, false);
      }
   }
}

//+------------------------------------------------------------------+
//| Create new FVG                                                   |
//+------------------------------------------------------------------+
bool CFVGLibrary::CreateFVG(int middle_bar, datetime candle_time, double top, 
                           double bottom, double gap_size, bool is_bullish)
{
   if(m_fvg_count >= ArraySize(m_fvg_list))
   {
      ArrayResize(m_fvg_list, ArraySize(m_fvg_list) + 50);
   }
   
   // Calculate encroachment point (middle of the gap)
   double enc_point = (top + bottom) / 2.0;
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   
   // Store FVG information
   m_fvg_list[m_fvg_count].fvg_id = m_next_fvg_id;
   m_fvg_list[m_fvg_count].middle_candle_bar = middle_bar;
   m_fvg_list[m_fvg_count].candle_time = candle_time;
   m_fvg_list[m_fvg_count].top_price = top;
   m_fvg_list[m_fvg_count].bottom_price = bottom;
   m_fvg_list[m_fvg_count].enc_point = enc_point;
   m_fvg_list[m_fvg_count].gap_size = gap_size / point;  // Store as points
   m_fvg_list[m_fvg_count].is_bullish = is_bullish;
   m_fvg_list[m_fvg_count].is_active = true;
   m_fvg_list[m_fvg_count].enc_touched = false;
   m_fvg_list[m_fvg_count].directional_bias = "PENDING";
   m_fvg_list[m_fvg_count].trade_ticket = 0;
   m_fvg_list[m_fvg_count].trade_opened = false;
   m_fvg_list[m_fvg_count].enc_time = 0;
   m_fvg_list[m_fvg_count].is_inverse = false;
   m_fvg_list[m_fvg_count].is_reset = false;
   
   // Plot visual indicator if enabled
   if(m_draw_objects)
      PlotFVGDot(middle_bar, candle_time, is_bullish, m_next_fvg_id);
   
   // Call callback if set
   if(m_callback != NULL)
      m_callback(m_fvg_list[m_fvg_count], "FVG_FORMED");
   
   Print(">>> FVG ", m_next_fvg_id, " formed! Type: ", (is_bullish ? "BULLISH" : "BEARISH"));
   Print("Gap: ", DoubleToString(top, _Digits), " - ", DoubleToString(bottom, _Digits));
   Print("Size: ", DoubleToString(gap_size/point, 1), " points");
   
   m_fvg_count++;
   m_next_fvg_id++;
   
   return true;
}

//+------------------------------------------------------------------+
//| Check FVG encroachment (normal mode)                             |
//+------------------------------------------------------------------+
void CFVGLibrary::CheckFVGEncroachment()
{
   double current_high = iHigh(m_symbol, m_timeframe, 0);
   double current_low = iLow(m_symbol, m_timeframe, 0);
   double current_close = iClose(m_symbol, m_timeframe, 0);
   
   for(int i = 0; i < m_fvg_count; i++)
   {
      if(!m_fvg_list[i].is_active || m_fvg_list[i].enc_touched) continue;
      
      bool enc_touched_now = false;
      string bias = "PENDING";
      
      if(m_fvg_list[i].is_bullish)
      {
         // Bullish FVG: Check if candle touches ENC point
         if(current_low <= m_fvg_list[i].enc_point && current_high >= m_fvg_list[i].enc_point)
         {
            enc_touched_now = true;
            bias = (current_close > m_fvg_list[i].enc_point) ? "BULLISH" : "BEARISH";
         }
      }
      else
      {
         // Bearish FVG: Check if candle touches ENC point
         if(current_high >= m_fvg_list[i].enc_point && current_low <= m_fvg_list[i].enc_point)
         {
            enc_touched_now = true;
            bias = (current_close < m_fvg_list[i].enc_point) ? "BEARISH" : "BULLISH";
         }
      }
      
      if(enc_touched_now)
      {
         m_fvg_list[i].enc_touched = true;
         m_fvg_list[i].is_active = false;
         m_fvg_list[i].directional_bias = bias;
         m_fvg_list[i].enc_time = TimeCurrent();
         
         if(m_draw_objects)
            PlotEncroachmentDot(m_fvg_list[i].fvg_id, bias);
         
         if(m_callback != NULL)
            m_callback(m_fvg_list[i], "FVG_ENCROACHED");
         
         Print("*** FVG ", m_fvg_list[i].fvg_id, " ENCROACHED! Bias: ", bias);
      }
   }
}

//+------------------------------------------------------------------+
//| Check FVG encroachment (high accuracy mode)                      |
//+------------------------------------------------------------------+
void CFVGLibrary::CheckFVGEncroachmentHighAccuracy()
{
   double current_high = iHigh(m_symbol, m_accuracy_tf, 0);
   double current_low = iLow(m_symbol, m_accuracy_tf, 0);
   double current_close = iClose(m_symbol, m_accuracy_tf, 0);
   
   for(int i = 0; i < m_fvg_count; i++)
   {
      if(!m_fvg_list[i].is_active || m_fvg_list[i].enc_touched) continue;
      
      bool enc_touched_now = false;
      string bias = "PENDING";
      
      if(m_fvg_list[i].is_bullish)
      {
         if(current_low <= m_fvg_list[i].enc_point && current_high >= m_fvg_list[i].enc_point)
         {
            enc_touched_now = true;
            bias = (current_close > m_fvg_list[i].enc_point) ? "BULLISH" : "BEARISH";
         }
      }
      else
      {
         if(current_high >= m_fvg_list[i].enc_point && current_low <= m_fvg_list[i].enc_point)
         {
            enc_touched_now = true;
            bias = (current_close < m_fvg_list[i].enc_point) ? "BEARISH" : "BULLISH";
         }
      }
      
      if(enc_touched_now)
      {
         m_fvg_list[i].enc_touched = true;
         m_fvg_list[i].is_active = false;
         m_fvg_list[i].directional_bias = bias;
         m_fvg_list[i].enc_time = TimeCurrent();
         
         if(m_draw_objects)
            PlotEncroachmentDot(m_fvg_list[i].fvg_id, bias);
         
         if(m_callback != NULL)
            m_callback(m_fvg_list[i], "FVG_ENCROACHED_HA");
         
         Print("*** FVG ", m_fvg_list[i].fvg_id, " ENCROACHED (HA)! Bias: ", bias);
      }
   }
}

//+------------------------------------------------------------------+
//| Get active FVGs count                                            |
//+------------------------------------------------------------------+
int CFVGLibrary::GetActiveFVGsCount() const
{
   int active_count = 0;
   for(int i = 0; i < m_fvg_count; i++)
   {
      if(m_fvg_list[i].is_active && !m_fvg_list[i].enc_touched)
         active_count++;
   }
   return active_count;
}

//+------------------------------------------------------------------+
//| Get FVG by index                                                 |
//+------------------------------------------------------------------+
FVGInfo CFVGLibrary::GetFVGByIndex(int index)
{
   FVGInfo empty_fvg = {0};
   if(index >= 0 && index < m_fvg_count)
      return m_fvg_list[index];
   return empty_fvg;
}

//+------------------------------------------------------------------+
//| Get FVG by ID                                                    |
//+------------------------------------------------------------------+
FVGInfo CFVGLibrary::GetFVGById(int fvg_id)
{
   FVGInfo empty_fvg = {0};
   for(int i = 0; i < m_fvg_count; i++)
   {
      if(m_fvg_list[i].fvg_id == fvg_id)
         return m_fvg_list[i];
   }
   return empty_fvg;
}

//+------------------------------------------------------------------+
//| Deactivate FVG                                                   |
//+------------------------------------------------------------------+
void CFVGLibrary::DeactivateFVG(int fvg_id)
{
   for(int i = 0; i < m_fvg_count; i++)
   {
      if(m_fvg_list[i].fvg_id == fvg_id)
      {
         m_fvg_list[i].is_active = false;
         if(m_callback != NULL)
            m_callback(m_fvg_list[i], "FVG_DEACTIVATED");
         break;
      }
   }
}

//+------------------------------------------------------------------+
//| Associate trade with FVG                                         |
//+------------------------------------------------------------------+
void CFVGLibrary::AssociateTradeWithFVG(int fvg_id, ulong ticket)
{
   for(int i = 0; i < m_fvg_count; i++)
   {
      if(m_fvg_list[i].fvg_id == fvg_id)
      {
         m_fvg_list[i].trade_ticket = ticket;
         m_fvg_list[i].trade_opened = true;
         break;
      }
   }
}

//+------------------------------------------------------------------+
//| Plot FVG dot                                                     |
//+------------------------------------------------------------------+
void CFVGLibrary::PlotFVGDot(int bar_index, datetime candle_time, bool is_bullish, int fvg_id)
{
   if(!m_draw_objects) return;
   
   string obj_name = "FVG_DOT_" + IntegerToString(fvg_id);
   
   double candle_high = iHigh(m_symbol, m_timeframe, bar_index);
   double candle_low = iLow(m_symbol, m_timeframe, bar_index);
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   
   double dot_price = is_bullish ? candle_high + (10 * point) : candle_low - (10 * point);
   color dot_color = is_bullish ? clrLimeGreen : clrRed;
   
   ObjectCreate(0, obj_name, OBJ_ARROW, 0, candle_time, dot_price);
   ObjectSetInteger(0, obj_name, OBJPROP_ARROWCODE, 159);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, dot_color);
   ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 3);
   ObjectSetInteger(0, obj_name, OBJPROP_BACK, false);
   ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, obj_name, OBJPROP_SELECTED, false);
}

//+------------------------------------------------------------------+
//| Plot encroachment dot                                            |
//+------------------------------------------------------------------+
void CFVGLibrary::PlotEncroachmentDot(int fvg_id, string bias)
{
   if(!m_draw_objects) return;
   
   string obj_name = "ENC_DOT_" + IntegerToString(fvg_id);
   datetime current_time = iTime(m_symbol, m_timeframe, 0);
   
   double candle_high = iHigh(m_symbol, m_timeframe, 0);
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   double dot_price = candle_high + (15 * point);
   
   color dot_color = (bias == "BULLISH") ? clrOrange : clrBlue;
   
   ObjectCreate(0, obj_name, OBJ_ARROW, 0, current_time, dot_price);
   ObjectSetInteger(0, obj_name, OBJPROP_ARROWCODE, 159);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, dot_color);
   ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 3);
   ObjectSetInteger(0, obj_name, OBJPROP_BACK, false);
   ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, obj_name, OBJPROP_SELECTED, false);
}

//+------------------------------------------------------------------+
//| Check for Inverse FVGs (candles shooting through FVGs)          |
//+------------------------------------------------------------------+
void CFVGLibrary::CheckForInverseFVG()
{
   double current_open = iOpen(m_symbol, m_timeframe, 0);
   double current_close = iClose(m_symbol, m_timeframe, 0);
   double current_high = iHigh(m_symbol, m_timeframe, 0);
   double current_low = iLow(m_symbol, m_timeframe, 0);
   
   for(int i = 0; i < m_fvg_count; i++)
   {
      if(!m_fvg_list[i].is_active || m_fvg_list[i].enc_touched || m_fvg_list[i].is_reset) continue;
      
      bool is_inverse = false;
      
      // Check if candle opens outside FVG and closes on other side (shooting through)
      if(m_fvg_list[i].is_bullish)
      {
         // Bullish FVG: Check if candle opens below bottom and closes above top
         if(current_open < m_fvg_list[i].bottom_price && current_close > m_fvg_list[i].top_price)
         {
            is_inverse = true;
         }
      }
      else
      {
         // Bearish FVG: Check if candle opens above top and closes below bottom  
         if(current_open > m_fvg_list[i].top_price && current_close < m_fvg_list[i].bottom_price)
         {
            is_inverse = true;
         }
      }
      
      if(is_inverse)
      {
         // Reset the FVG
         m_fvg_list[i].is_reset = true;
         m_fvg_list[i].is_active = false;
         m_fvg_list[i].directional_bias = "RESET";
         m_fvg_list[i].enc_time = TimeCurrent();
         m_fvg_list[i].is_inverse = true;
         
         // Plot reset indicator
         //if(m_draw_objects)
            //PlotResetDot(m_fvg_list[i].fvg_id);
         
         // Call callback
         if(m_callback != NULL)
            m_callback(m_fvg_list[i], "FVG_RESET");
         
         Print("*** FVG ", m_fvg_list[i].fvg_id, " RESET by INVERSE CANDLE! ***");
         Print("Candle shot through FVG: Open=", DoubleToString(current_open, _Digits), 
               " Close=", DoubleToString(current_close, _Digits));
      }
   }
}
void CFVGLibrary::CleanupObjects()
{
   ObjectsDeleteAll(0, "FVG_DOT_");
   ObjectsDeleteAll(0, "ENC_DOT_");
   ObjectsDeleteAll(0, "RESET_DOT_");
}

//+------------------------------------------------------------------+
//| Print FVG statistics                                             |
//+------------------------------------------------------------------+
void CFVGLibrary::PrintFVGStats() const
{
   int active_fvgs = GetActiveFVGsCount();
   int filled_fvgs = m_fvg_count - active_fvgs;
   
   Print("=== FVG LIBRARY STATISTICS ===");
   Print("Total FVGs detected: ", m_fvg_count);
   Print("Active FVGs: ", active_fvgs);
   Print("Filled FVGs: ", filled_fvgs);
   if(m_fvg_count > 0)
      Print("Fill rate: ", DoubleToString(GetFillRate(), 1), "%");
   Print("===============================");
}

//+------------------------------------------------------------------+
//| Get fill rate                                                    |
//+------------------------------------------------------------------+
double CFVGLibrary::GetFillRate() const
{
   if(m_fvg_count == 0) return 0.0;
   
   int filled_count = 0;
   for(int i = 0; i < m_fvg_count; i++)
   {
      if(m_fvg_list[i].enc_touched)
         filled_count++;
   }
   
   return (double)filled_count / m_fvg_count * 100.0;
}