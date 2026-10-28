//+------------------------------------------------------------------+
//|                                             LiquidityLibrary.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"


//--- Enumeration for liquidity types
enum ENUM_LIQUIDITY_TYPE
{
   LIQUIDITY_SWING_HIGH,        // Swing High (Buy Side Liquidity)
   LIQUIDITY_SWING_LOW,         // Swing Low (Sell Side Liquidity)
   LIQUIDITY_EQUAL_HIGHS,       // Equal/Relative Equal Highs
   LIQUIDITY_EQUAL_LOWS,        // Equal/Relative Equal Lows
   LIQUIDITY_SESSION_HIGH,      // Session High
   LIQUIDITY_SESSION_LOW,       // Session Low
   LIQUIDITY_PDH,               // Previous Day High
   LIQUIDITY_PDL,               // Previous Day Low
   LIQUIDITY_PWH,               // Previous Week High
   LIQUIDITY_PWL                // Previous Week Low
};

//--- Enumeration for session types
enum ENUM_SESSION_TYPE
{
   SESSION_SYDNEY,              // Sydney Session
   SESSION_TOKYO,               // Tokyo Session
   SESSION_LONDON,              // London Session
   SESSION_NEW_YORK,            // New York Session
   SESSION_SILVER_BULLET_1,     // Silver Bullet 1 (3-4am)
   SESSION_SILVER_BULLET_2,     // Silver Bullet 2 (10-11am)
   SESSION_SILVER_BULLET_3      // Silver Bullet 3 (2-3pm)
};

//--- Structure for liquidity levels
struct LiquidityInfo
{
   int liquidity_id;            // Unique ID
   ENUM_LIQUIDITY_TYPE type;    // Type of liquidity
   datetime time_created;       // When it was created
   double price_level;          // Price level
   bool is_swept;               // Has been swept/taken
   bool is_active;              // Still active
   datetime sweep_time;         // When it was swept
   string session_origin;       // Which session created it
   bool is_equal_level;         // Is part of equal highs/lows
   int equal_count;             // How many times price hit this level
   double tolerance;            // Price tolerance for equal levels
};

//--- Structure for session data
struct SessionData
{
   ENUM_SESSION_TYPE session_type;
   datetime session_start;
   datetime session_end;
   double session_high;
   double session_low;
   bool is_active;
   string session_name;
};

//--- Structure for daily bias
struct DailyBiasInfo
{
   datetime bias_date;
   double pdh_level;            // Previous Day High
   double pdl_level;            // Previous Day Low
   double pwh_level;            // Previous Week High
   double pwl_level;            // Previous Week Low
   string current_dol;          // Current Draw On Liquidity
   string daily_bias;           // BULLISH/BEARISH/NEUTRAL
   bool pdh_failure_to_displace; // PDH failed to displace
   bool pdl_failure_to_displace; // PDL failed to displace
};

//--- Callback function type for liquidity events
typedef void (*LiquidityCallback)(LiquidityInfo& liq, string event_type);

//+------------------------------------------------------------------+
//| Liquidity Library Class                                         |
//+------------------------------------------------------------------+
class CLiquidityLibrary
{
private:
   LiquidityInfo     m_liquidity_list[];    // Array of liquidity levels
   SessionData       m_sessions[];          // Session data array
   DailyBiasInfo     m_daily_bias;          // Current daily bias
   int               m_liquidity_count;     // Current liquidity count
   int               m_next_liq_id;         // Next liquidity ID
   string            m_symbol;              // Symbol to monitor
   ENUM_TIMEFRAMES   m_timeframe;           // Main timeframe
   int               m_gmt_offset;          // GMT offset for sessions
   LiquidityCallback m_callback;            // Callback function
   bool              m_draw_objects;        // Draw visual objects
   double            m_equal_tolerance;     // Tolerance for equal levels (pips)
   
   // Swing detection variables
   int               m_swing_lookback;      // Bars to look back for swings
   
public:
   // Constructor
   CLiquidityLibrary(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_M5,
                    int gmt_offset = 0, bool draw_objects = true,
                    double equal_tolerance = 5.0);
   
   // Destructor
   ~CLiquidityLibrary();
   
   // Core functions
   bool              Init();
   void              Deinit();
   void              OnTick();
   void              OnNewBar();
   
   // Configuration
   void              SetCallback(LiquidityCallback callback) { m_callback = callback; }
   void              SetEqualTolerance(double tolerance) { m_equal_tolerance = tolerance; }
   void              SetDrawObjects(bool draw) { m_draw_objects = draw; }
   
   // Swing detection
   void              DetectSwingPoints();
   bool              IsSwingHigh(int bar_index);
   bool              IsSwingLow(int bar_index);
   
   // Session management
   void              UpdateSessions();
   bool              IsInSession(ENUM_SESSION_TYPE session_type);
   SessionData       GetSessionData(ENUM_SESSION_TYPE session_type);
   void              CalculateSessionHighLow(ENUM_SESSION_TYPE session_type);
   
   // Daily bias functions
   void              UpdateDailyBias();
   void              CalculatePreviousDayHighLow();
   void              CalculatePreviousWeekHighLow();
   string            DetermineDOL();
   bool              CheckFailureToDisplace(double level, bool is_high);
   
   // Liquidity management
   bool              CreateLiquidity(ENUM_LIQUIDITY_TYPE type, double price, datetime time, string session = "");
   void              CheckLiquiditySweeps();
   void              DetectEqualLevels();
   void              UpdateLiquidityStatus();
   
   // Utility functions
   int               GetLiquidityCount() const { return m_liquidity_count; }
   int               GetActiveLiquidityCount() const;
   LiquidityInfo     GetLiquidityByIndex(int index);
   LiquidityInfo     GetNearestLiquidity(bool above_price);
   string            GetCurrentDOL() const { return m_daily_bias.current_dol; }
   string            GetDailyBias() const { return m_daily_bias.daily_bias; }
   
   // Visual functions
   void              PlotLiquidityLevel(LiquidityInfo& liq);
   void              PlotSweptLevel(LiquidityInfo& liq);
   void              CleanupObjects();
   
   // Priority list for Silver Bullet
   string            GetSilverBulletPriority(ENUM_SESSION_TYPE session, int priority_index);
   double            GetPriorityLevel(string priority_type);
   
   // Statistics
   void              PrintLiquidityStats() const;
   void              PrintDailyBias() const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CLiquidityLibrary::CLiquidityLibrary(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_M5,
                                   int gmt_offset = 0, bool draw_objects = true,
                                   double equal_tolerance = 5.0)
{
   m_symbol = (symbol == "") ? _Symbol : symbol;
   m_timeframe = timeframe;
   m_gmt_offset = gmt_offset;
   m_draw_objects = draw_objects;
   m_equal_tolerance = equal_tolerance;
   m_liquidity_count = 0;
   m_next_liq_id = 1;
   m_swing_lookback = 3;
   m_callback = NULL;
   
   ArrayResize(m_liquidity_list, 200);
   ArrayResize(m_sessions, 7); // 7 session types
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CLiquidityLibrary::~CLiquidityLibrary()
{
   Deinit();
}

//+------------------------------------------------------------------+
//| Initialize the library                                           |
//+------------------------------------------------------------------+
bool CLiquidityLibrary::Init()
{
   Print("=== Liquidity Library Initialized ===");
   Print("Symbol: ", m_symbol);
   Print("Timeframe: ", EnumToString(m_timeframe));
   Print("GMT Offset: ", m_gmt_offset);
   Print("Equal Level Tolerance: ", m_equal_tolerance, " pips");
   
   if(m_draw_objects)
      CleanupObjects();
   
   // Initialize sessions
   UpdateSessions();
   
   // Calculate initial daily bias
   UpdateDailyBias();
   
   return true;
}

//+------------------------------------------------------------------+
//| Deinitialize the library                                         |
//+------------------------------------------------------------------+
void CLiquidityLibrary::Deinit()
{
   if(m_draw_objects)
      CleanupObjects();
   
   Print("=== Liquidity Library Deinitialized ===");
   Print("Total Liquidity Levels: ", m_liquidity_count);
}

//+------------------------------------------------------------------+
//| Main tick function                                               |
//+------------------------------------------------------------------+
void CLiquidityLibrary::OnTick()
{
   UpdateSessions();
   CheckLiquiditySweeps();
   UpdateLiquidityStatus();
}

//+------------------------------------------------------------------+
//| New bar event                                                    |
//+------------------------------------------------------------------+
void CLiquidityLibrary::OnNewBar()
{
   DetectSwingPoints();
   DetectEqualLevels();
   UpdateDailyBias();
   CalculateSessionHighLow(SESSION_SYDNEY);
   CalculateSessionHighLow(SESSION_TOKYO);
   CalculateSessionHighLow(SESSION_LONDON);
}

//+------------------------------------------------------------------+
//| Detect swing points                                              |
//+------------------------------------------------------------------+
void CLiquidityLibrary::DetectSwingPoints()
{
   int bars_available = iBars(m_symbol, m_timeframe);
   if(bars_available < m_swing_lookback * 2 + 1) return;
   
   // Check for swing high at bar 1 (most recent completed bar)
   if(IsSwingHigh(1))
   {
      double high_price = iHigh(m_symbol, m_timeframe, 1);
      datetime high_time = iTime(m_symbol, m_timeframe, 1);
      CreateLiquidity(LIQUIDITY_SWING_HIGH, high_price, high_time);
   }
   
   // Check for swing low at bar 1
   if(IsSwingLow(1))
   {
      double low_price = iLow(m_symbol, m_timeframe, 1);
      datetime low_time = iTime(m_symbol, m_timeframe, 1);
      CreateLiquidity(LIQUIDITY_SWING_LOW, low_price, low_time);
   }
}

//+------------------------------------------------------------------+
//| Check if bar is a swing high                                     |
//+------------------------------------------------------------------+
bool CLiquidityLibrary::IsSwingHigh(int bar_index)
{
   if(bar_index < m_swing_lookback || bar_index >= iBars(m_symbol, m_timeframe) - m_swing_lookback)
      return false;
   
   double center_high = iHigh(m_symbol, m_timeframe, bar_index);
   
   // Check left side
   for(int i = 1; i <= m_swing_lookback; i++)
   {
      if(iHigh(m_symbol, m_timeframe, bar_index + i) >= center_high)
         return false;
   }
   
   // Check right side
   for(int i = 1; i <= m_swing_lookback; i++)
   {
      if(iHigh(m_symbol, m_timeframe, bar_index - i) >= center_high)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if bar is a swing low                                      |
//+------------------------------------------------------------------+
bool CLiquidityLibrary::IsSwingLow(int bar_index)
{
   if(bar_index < m_swing_lookback || bar_index >= iBars(m_symbol, m_timeframe) - m_swing_lookback)
      return false;
   
   double center_low = iLow(m_symbol, m_timeframe, bar_index);
   
   // Check left side
   for(int i = 1; i <= m_swing_lookback; i++)
   {
      if(iLow(m_symbol, m_timeframe, bar_index + i) <= center_low)
         return false;
   }
   
   // Check right side  
   for(int i = 1; i <= m_swing_lookback; i++)
   {
      if(iLow(m_symbol, m_timeframe, bar_index - i) <= center_low)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Update session information                                        |
//+------------------------------------------------------------------+
void CLiquidityLibrary::UpdateSessions()
{
   datetime current_time = TimeCurrent() + (m_gmt_offset * 3600);
   MqlDateTime time_struct;
   TimeToStruct(current_time, time_struct);
   
   int current_hour = time_struct.hour;
   
   // Reset all sessions
   for(int i = 0; i < ArraySize(m_sessions); i++)
      m_sessions[i].is_active = false;
   
   // Sydney: 9pm-6am (GMT+0)
   if((current_hour >= 21) || (current_hour < 6))
   {
      m_sessions[SESSION_SYDNEY].is_active = true;
      m_sessions[SESSION_SYDNEY].session_name = "Sydney";
   }
   
   // Tokyo: 12am-9am (GMT+0)
   if(current_hour >= 0 && current_hour < 9)
   {
      m_sessions[SESSION_TOKYO].is_active = true;
      m_sessions[SESSION_TOKYO].session_name = "Tokyo";
   }
   
   // London: 7am-4pm (GMT+0)
   if(current_hour >= 7 && current_hour < 16)
   {
      m_sessions[SESSION_LONDON].is_active = true;
      m_sessions[SESSION_LONDON].session_name = "London";
   }
   
   // New York: 12pm-9pm (GMT+0)
   if(current_hour >= 12 && current_hour < 21)
   {
      m_sessions[SESSION_NEW_YORK].is_active = true;
      m_sessions[SESSION_NEW_YORK].session_name = "New York";
   }
   
   // Silver Bullet Sessions (GMT+0)
   if(current_hour >= 7 && current_hour < 8)
   {
      m_sessions[SESSION_SILVER_BULLET_1].is_active = true;
      m_sessions[SESSION_SILVER_BULLET_1].session_name = "Silver Bullet 1";
   }
   
   if(current_hour >= 14 && current_hour < 15)
   {
      m_sessions[SESSION_SILVER_BULLET_2].is_active = true;
      m_sessions[SESSION_SILVER_BULLET_2].session_name = "Silver Bullet 2";
   }
   
   if(current_hour >= 18 && current_hour < 19)
   {
      m_sessions[SESSION_SILVER_BULLET_3].is_active = true;
      m_sessions[SESSION_SILVER_BULLET_3].session_name = "Silver Bullet 3";
   }
}

//+------------------------------------------------------------------+
//| Calculate session high/low                                       |
//+------------------------------------------------------------------+
void CLiquidityLibrary::CalculateSessionHighLow(ENUM_SESSION_TYPE session_type)
{
   // Implementation for calculating session highs and lows
   // This would track the highest high and lowest low during each session
   // For now, basic structure - full implementation would be more complex
   
   if(m_sessions[session_type].is_active)
   {
      double current_high = iHigh(m_symbol, m_timeframe, 0);
      double current_low = iLow(m_symbol, m_timeframe, 0);
      
      if(m_sessions[session_type].session_high < current_high || m_sessions[session_type].session_high == 0)
         m_sessions[session_type].session_high = current_high;
         
      if(m_sessions[session_type].session_low > current_low || m_sessions[session_type].session_low == 0)
         m_sessions[session_type].session_low = current_low;
   }
}

//+------------------------------------------------------------------+
//| Update daily bias                                                |
//+------------------------------------------------------------------+
void CLiquidityLibrary::UpdateDailyBias()
{
   CalculatePreviousDayHighLow();
   CalculatePreviousWeekHighLow();
   m_daily_bias.current_dol = DetermineDOL();
   
   // Determine overall bias based on DOL
   if(StringFind(m_daily_bias.current_dol, "HIGH") != -1)
      m_daily_bias.daily_bias = "BULLISH";
   else if(StringFind(m_daily_bias.current_dol, "LOW") != -1)
      m_daily_bias.daily_bias = "BEARISH";
   else
      m_daily_bias.daily_bias = "NEUTRAL";
}

//+------------------------------------------------------------------+
//| Calculate Previous Day High/Low                                  |
//+------------------------------------------------------------------+
void CLiquidityLibrary::CalculatePreviousDayHighLow()
{
   m_daily_bias.pdh_level = iHigh(m_symbol, PERIOD_D1, 1);
   m_daily_bias.pdl_level = iLow(m_symbol, PERIOD_D1, 1);
   
   // Create liquidity levels for PDH/PDL
   datetime yesterday = iTime(m_symbol, PERIOD_D1, 1);
   CreateLiquidity(LIQUIDITY_PDH, m_daily_bias.pdh_level, yesterday);
   CreateLiquidity(LIQUIDITY_PDL, m_daily_bias.pdl_level, yesterday);
}

//+------------------------------------------------------------------+
//| Calculate Previous Week High/Low                                 |
//+------------------------------------------------------------------+
void CLiquidityLibrary::CalculatePreviousWeekHighLow()
{
   m_daily_bias.pwh_level = iHigh(m_symbol, PERIOD_W1, 1);
   m_daily_bias.pwl_level = iLow(m_symbol, PERIOD_W1, 1);
   
   // Create liquidity levels for PWH/PWL
   datetime last_week = iTime(m_symbol, PERIOD_W1, 1);
   CreateLiquidity(LIQUIDITY_PWH, m_daily_bias.pwh_level, last_week);
   CreateLiquidity(LIQUIDITY_PWL, m_daily_bias.pwl_level, last_week);
}

//+------------------------------------------------------------------+
//| Determine Draw On Liquidity                                      |
//+------------------------------------------------------------------+
string CLiquidityLibrary::DetermineDOL()
{
   double current_price = iClose(m_symbol, m_timeframe, 0);
   double current_open = iOpen(m_symbol, PERIOD_D1, 0); // Today's open
   
   // Simple logic: if opened near PDH, DOL is likely PDH, vice versa
   double pdh_distance = MathAbs(current_open - m_daily_bias.pdh_level);
   double pdl_distance = MathAbs(current_open - m_daily_bias.pdl_level);
   
   if(pdh_distance < pdl_distance)
      return "PDH";
   else
      return "PDL";
}

//+------------------------------------------------------------------+
//| Create liquidity level                                           |
//+------------------------------------------------------------------+
bool CLiquidityLibrary::CreateLiquidity(ENUM_LIQUIDITY_TYPE type, double price, datetime time, string session = "")
{
   if(m_liquidity_count >= ArraySize(m_liquidity_list))
   {
      ArrayResize(m_liquidity_list, ArraySize(m_liquidity_list) + 100);
   }
   
   // Check if similar level already exists (prevent duplicates)
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   double tolerance = m_equal_tolerance * point;
   
   for(int i = 0; i < m_liquidity_count; i++)
   {
      if(m_liquidity_list[i].type == type && 
         MathAbs(m_liquidity_list[i].price_level - price) < tolerance)
      {
         return false; // Similar level exists
      }
   }
   
   // Create new liquidity level
   m_liquidity_list[m_liquidity_count].liquidity_id = m_next_liq_id;
   m_liquidity_list[m_liquidity_count].type = type;
   m_liquidity_list[m_liquidity_count].time_created = time;
   m_liquidity_list[m_liquidity_count].price_level = price;
   m_liquidity_list[m_liquidity_count].is_swept = false;
   m_liquidity_list[m_liquidity_count].is_active = true;
   m_liquidity_list[m_liquidity_count].session_origin = session;
   m_liquidity_list[m_liquidity_count].equal_count = 1;
   m_liquidity_list[m_liquidity_count].tolerance = tolerance;
   
   if(m_draw_objects)
      PlotLiquidityLevel(m_liquidity_list[m_liquidity_count]);
   
   if(m_callback != NULL)
      m_callback(m_liquidity_list[m_liquidity_count], "LIQUIDITY_CREATED");
   
   Print("Liquidity created: ID=", m_next_liq_id, " Type=", EnumToString(type), 
         " Price=", DoubleToString(price, _Digits));
   
   m_liquidity_count++;
   m_next_liq_id++;
   
   return true;
}

//+------------------------------------------------------------------+
//| Check for liquidity sweeps                                       |
//+------------------------------------------------------------------+
void CLiquidityLibrary::CheckLiquiditySweeps()
{
   double current_high = iHigh(m_symbol, m_timeframe, 0);
   double current_low = iLow(m_symbol, m_timeframe, 0);
   
   for(int i = 0; i < m_liquidity_count; i++)
   {
      if(!m_liquidity_list[i].is_active || m_liquidity_list[i].is_swept)
         continue;
      
      bool swept = false;
      
      // Check if liquidity was swept
      if((m_liquidity_list[i].type == LIQUIDITY_SWING_HIGH || 
          m_liquidity_list[i].type == LIQUIDITY_EQUAL_HIGHS ||
          m_liquidity_list[i].type == LIQUIDITY_SESSION_HIGH ||
          m_liquidity_list[i].type == LIQUIDITY_PDH ||
          m_liquidity_list[i].type == LIQUIDITY_PWH) && 
         current_high > m_liquidity_list[i].price_level)
      {
         swept = true;
      }
      else if((m_liquidity_list[i].type == LIQUIDITY_SWING_LOW ||
               m_liquidity_list[i].type == LIQUIDITY_EQUAL_LOWS ||
               m_liquidity_list[i].type == LIQUIDITY_SESSION_LOW ||
               m_liquidity_list[i].type == LIQUIDITY_PDL ||
               m_liquidity_list[i].type == LIQUIDITY_PWL) && 
              current_low < m_liquidity_list[i].price_level)
      {
         swept = true;
      }
      
      if(swept)
      {
         m_liquidity_list[i].is_swept = true;
         m_liquidity_list[i].sweep_time = TimeCurrent();
         
         if(m_draw_objects)
            PlotSweptLevel(m_liquidity_list[i]);
         
         if(m_callback != NULL)
            m_callback(m_liquidity_list[i], "LIQUIDITY_SWEPT");
         
         Print("Liquidity SWEPT: ID=", m_liquidity_list[i].liquidity_id, 
               " Type=", EnumToString(m_liquidity_list[i].type));
      }
   }
}

//+------------------------------------------------------------------+
//| Get Silver Bullet priority for session                          |
//+------------------------------------------------------------------+
string CLiquidityLibrary::GetSilverBulletPriority(ENUM_SESSION_TYPE session, int priority_index)
{
   string priorities[];
   
   if(session == SESSION_SILVER_BULLET_1)
   {
      string sb1_priorities[] = {"SYDNEY_HH", "SYDNEY_LL", "IN_RANGE_LIQ", "PDH", "PDL", "PWH", "PWL"};
      ArrayCopy(priorities, sb1_priorities);
   }
   else if(session == SESSION_SILVER_BULLET_2)
   {
      string sb2_priorities[] = {"TOKYO_HH", "TOKYO_LL", "IN_RANGE_LIQ", "PDH", "PDL", "PWH", "PWL"};
      ArrayCopy(priorities, sb2_priorities);
   }
   else if(session == SESSION_SILVER_BULLET_3)
   {
      string sb3_priorities[] = {"LONDON_HH", "LONDON_LL", "IN_RANGE_LIQ", "PDH", "PDL", "PWH", "PWL"};
      ArrayCopy(priorities, sb3_priorities);
   }
   
   if(priority_index >= 0 && priority_index < ArraySize(priorities))
      return priorities[priority_index];
   
   return "";
}

//+------------------------------------------------------------------+
//| Plot liquidity level                                             |
//+------------------------------------------------------------------+
void CLiquidityLibrary::PlotLiquidityLevel(LiquidityInfo& liq)
{
   if(!m_draw_objects) return;
   
   string obj_name = "LIQ_" + IntegerToString(liq.liquidity_id);
   color line_color = clrWhite;
   
   // Different colors for different types
   switch(liq.type)
   {
      case LIQUIDITY_SWING_HIGH:
      case LIQUIDITY_EQUAL_HIGHS:
         line_color = clrRed;
         break;
      case LIQUIDITY_SWING_LOW:
      case LIQUIDITY_EQUAL_LOWS:
         line_color = clrLimeGreen;
         break;
      case LIQUIDITY_PDH:
      case LIQUIDITY_PWH:
         line_color = clrOrange;
         break;
      case LIQUIDITY_PDL:
      case LIQUIDITY_PWL:
         line_color = clrAqua;
         break;
      case LIQUIDITY_SESSION_HIGH:
         line_color = clrMagenta;
         break;
      case LIQUIDITY_SESSION_LOW:
         line_color = clrYellow;
         break;
   }
   
   ObjectCreate(0, obj_name, OBJ_HLINE, 0, 0, liq.price_level);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, line_color);
   ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
}

//+------------------------------------------------------------------+
//| Plot swept level                                                 |
//+------------------------------------------------------------------+
void CLiquidityLibrary::PlotSweptLevel(LiquidityInfo& liq)
{
   if(!m_draw_objects) return;
   
   string obj_name = "LIQ_" + IntegerToString(liq.liquidity_id);
   
   // Change color to gray and style to dotted when swept
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clrGray);
   ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_DOT);
}

//+------------------------------------------------------------------+
//| Clean up all objects                                             |
//+------------------------------------------------------------------+
void CLiquidityLibrary::CleanupObjects()
{
   ObjectsDeleteAll(0, "LIQ_");
}

//+------------------------------------------------------------------+
//| Get active liquidity count                                       |
//+------------------------------------------------------------------+
int CLiquidityLibrary::GetActiveLiquidityCount() const
{
   int active_count = 0;
   for(int i = 0; i < m_liquidity_count; i++)
   {
      if(m_liquidity_list[i].is_active && !m_liquidity_list[i].is_swept)
         active_count++;
   }
   return active_count;
}

//+------------------------------------------------------------------+
//| Get liquidity by index                                           |
//+------------------------------------------------------------------+
LiquidityInfo CLiquidityLibrary::GetLiquidityByIndex(int index)
{
   LiquidityInfo empty_liq = {0};
   if(index >= 0 && index < m_liquidity_count)
      return m_liquidity_list[index];
   return empty_liq;
}

//+------------------------------------------------------------------+
//| Print liquidity statistics                                       |
//+------------------------------------------------------------------+
void CLiquidityLibrary::PrintLiquidityStats() const
{
   int active_liq = GetActiveLiquidityCount();
   int swept_liq = 0;
   
   for(int i = 0; i < m_liquidity_count; i++)
      if(m_liquidity_list[i].is_swept) swept_liq++;
   
   Print("=== LIQUIDITY LIBRARY STATISTICS ===");
   Print("Total Liquidity Levels: ", m_liquidity_count);
   Print("Active Liquidity: ", active_liq);
   Print("Swept Liquidity: ", swept_liq);
   if(m_liquidity_count > 0)
      Print("Sweep Rate: ", DoubleToString((double)swept_liq/m_liquidity_count*100, 1), "%");
   Print("====================================");
}

//+------------------------------------------------------------------+
//| Print daily bias information                                     |
//+------------------------------------------------------------------+
void CLiquidityLibrary::PrintDailyBias() const
{
   Print("=== DAILY BIAS ANALYSIS ===");
   Print("Current DOL: ", m_daily_bias.current_dol);
   Print("Daily Bias: ", m_daily_bias.daily_bias);
   Print("PDH Level: ", DoubleToString(m_daily_bias.pdh_level, _Digits));
   Print("PDL Level: ", DoubleToString(m_daily_bias.pdl_level, _Digits));
   Print("PWH Level: ", DoubleToString(m_daily_bias.pwh_level, _Digits));
   Print("PWL Level: ", DoubleToString(m_daily_bias.pwl_level, _Digits));
   Print("PDH Failure to Displace: ", (m_daily_bias.pdh_failure_to_displace ? "YES" : "NO"));
   Print("PDL Failure to Displace: ", (m_daily_bias.pdl_failure_to_displace ? "YES" : "NO"));
   Print("===========================");
}

//+------------------------------------------------------------------+
//| Check failure to displace                                        |
//+------------------------------------------------------------------+
bool CLiquidityLibrary::CheckFailureToDisplace(double level, bool is_high)
{
   double current_high = iHigh(m_symbol, m_timeframe, 0);
   double current_low = iLow(m_symbol, m_timeframe, 0);
   double current_close = iClose(m_symbol, m_timeframe, 0);
   
   if(is_high)
   {
      // Check if price reached above level but closed below it
      if(current_high > level && current_close < level)
         return true;
   }
   else
   {
      // Check if price reached below level but closed above it  
      if(current_low < level && current_close > level)
         return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Detect equal levels                                              |
//+------------------------------------------------------------------+
void CLiquidityLibrary::DetectEqualLevels()
{
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   double tolerance = m_equal_tolerance * point;
   
   // Group similar levels together as equal levels
   for(int i = 0; i < m_liquidity_count - 1; i++)
   {
      if(!m_liquidity_list[i].is_active) continue;
      
      for(int j = i + 1; j < m_liquidity_count; j++)
      {
         if(!m_liquidity_list[j].is_active) continue;
         
         // Check if levels are similar and same type category
         if(MathAbs(m_liquidity_list[i].price_level - m_liquidity_list[j].price_level) < tolerance)
         {
            bool same_category = false;
            
            // Check if both are highs or both are lows
            if((m_liquidity_list[i].type == LIQUIDITY_SWING_HIGH || m_liquidity_list[i].type == LIQUIDITY_EQUAL_HIGHS) &&
               (m_liquidity_list[j].type == LIQUIDITY_SWING_HIGH || m_liquidity_list[j].type == LIQUIDITY_EQUAL_HIGHS))
            {
               same_category = true;
               m_liquidity_list[i].type = LIQUIDITY_EQUAL_HIGHS;
               m_liquidity_list[j].type = LIQUIDITY_EQUAL_HIGHS;
            }
            else if((m_liquidity_list[i].type == LIQUIDITY_SWING_LOW || m_liquidity_list[i].type == LIQUIDITY_EQUAL_LOWS) &&
                    (m_liquidity_list[j].type == LIQUIDITY_SWING_LOW || m_liquidity_list[j].type == LIQUIDITY_EQUAL_LOWS))
            {
               same_category = true;
               m_liquidity_list[i].type = LIQUIDITY_EQUAL_LOWS;
               m_liquidity_list[j].type = LIQUIDITY_EQUAL_LOWS;
            }
            
            if(same_category)
            {
               m_liquidity_list[i].is_equal_level = true;
               m_liquidity_list[j].is_equal_level = true;
               m_liquidity_list[i].equal_count++;
               m_liquidity_list[j].equal_count = m_liquidity_list[i].equal_count;
               
               Print("Equal levels detected: ID ", m_liquidity_list[i].liquidity_id, 
                     " and ID ", m_liquidity_list[j].liquidity_id);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Update liquidity status                                          |
//+------------------------------------------------------------------+
void CLiquidityLibrary::UpdateLiquidityStatus()
{
   // Check for failure to displace on key levels
   m_daily_bias.pdh_failure_to_displace = CheckFailureToDisplace(m_daily_bias.pdh_level, true);
   m_daily_bias.pdl_failure_to_displace = CheckFailureToDisplace(m_daily_bias.pdl_level, false);
   
   // Update DOL based on failures
   if(m_daily_bias.pdh_failure_to_displace)
      m_daily_bias.current_dol = "PDL"; // Reverse to PDL
   else if(m_daily_bias.pdl_failure_to_displace)
      m_daily_bias.current_dol = "PDH"; // Reverse to PDH
}

//+------------------------------------------------------------------+
//| Get nearest liquidity level                                      |
//+------------------------------------------------------------------+
LiquidityInfo CLiquidityLibrary::GetNearestLiquidity(bool above_price)
{
   LiquidityInfo empty_liq = {0};
   LiquidityInfo nearest_liq = {0};
   double current_price = iClose(m_symbol, m_timeframe, 0);
   double min_distance = 999999;
   
   for(int i = 0; i < m_liquidity_count; i++)
   {
      if(!m_liquidity_list[i].is_active || m_liquidity_list[i].is_swept)
         continue;
      
      double distance = 0;
      bool valid_direction = false;
      
      if(above_price && m_liquidity_list[i].price_level > current_price)
      {
         distance = m_liquidity_list[i].price_level - current_price;
         valid_direction = true;
      }
      else if(!above_price && m_liquidity_list[i].price_level < current_price)
      {
         distance = current_price - m_liquidity_list[i].price_level;
         valid_direction = true;
      }
      
      if(valid_direction && distance < min_distance)
      {
         min_distance = distance;
         nearest_liq = m_liquidity_list[i];
      }
   }
   
   return (nearest_liq.liquidity_id != 0) ? nearest_liq : empty_liq;
}

//+------------------------------------------------------------------+
//| Get priority level price                                         |
//+------------------------------------------------------------------+
double CLiquidityLibrary::GetPriorityLevel(string priority_type)
{
   if(priority_type == "PDH") return m_daily_bias.pdh_level;
   else if(priority_type == "PDL") return m_daily_bias.pdl_level;
   else if(priority_type == "PWH") return m_daily_bias.pwh_level;
   else if(priority_type == "PWL") return m_daily_bias.pwl_level;
   else if(priority_type == "SYDNEY_HH") return m_sessions[SESSION_SYDNEY].session_high;
   else if(priority_type == "SYDNEY_LL") return m_sessions[SESSION_SYDNEY].session_low;
   else if(priority_type == "TOKYO_HH") return m_sessions[SESSION_TOKYO].session_high;
   else if(priority_type == "TOKYO_LL") return m_sessions[SESSION_TOKYO].session_low;
   else if(priority_type == "LONDON_HH") return m_sessions[SESSION_LONDON].session_high;
   else if(priority_type == "LONDON_LL") return m_sessions[SESSION_LONDON].session_low;
   
   return 0.0;
}

//+------------------------------------------------------------------+
//| Check if currently in session                                    |
//+------------------------------------------------------------------+
bool CLiquidityLibrary::IsInSession(ENUM_SESSION_TYPE session_type)
{
   if(session_type < 0 || session_type >= ArraySize(m_sessions))
      return false;
   
   return m_sessions[session_type].is_active;
}

//+------------------------------------------------------------------+
//| Get session data                                                 |
//+------------------------------------------------------------------+
SessionData CLiquidityLibrary::GetSessionData(ENUM_SESSION_TYPE session_type)
{
   SessionData empty_session = {0};
   if(session_type < 0 || session_type >= ArraySize(m_sessions))
      return empty_session;
   
   return m_sessions[session_type];
}