//+------------------------------------------------------------------+
//|                                      Hon-NewsTrader-COMPLETE.mqh |
//|                                    Copyright 2025,KSQUANTITATIVE |
//|                                                 WWW.ksquants.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025,KSQUANTITATIVE"
#property link      "www.ksquants.com"
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>

//--- FIXED: Renamed all conflicting input parameters
input group "=== News Trading Settings ==="
input bool     EnableNewsTrading = true;               
input bool     EnableNewsFilter = true;                
input bool     UseInternalCalendar = true;             
input string   NewsSymbols = "USD,EUR,GBP,JPY,CAD,AUD,NZD,CHF"; 
input bool     EnableHighImpact = true;                
input bool     EnableMediumImpact = true;              
input bool     EnableLowImpact = false;                

input group "=== News Trading Timing ==="
input int      NewsLookAheadMin = 60;                  
input int      StopBeforeNewsMin = 15;                 
input int      StopAfterNewsMin = 30;                  
input int      NewsTradeWindowMin = 5;                 
input int      MaxNewsTradesPerEvent = 2;              

input group "=== News Order Settings ==="
input double   MinDistanceFromSR = 10.0;               
input double   MaxDistanceFromSR = 50.0;               
input double   PendingOrderBuffer = 5.0;               
input int      NewsOrderExpiry = 120;                 
input double   MinRiskRewardRatio = 1.5;               
input int      MaxNewsOrders = 4;                      

input group "=== News Trade Management ==="
input bool     UseBreakEven = true;                    
input double   BreakEvenTriggerR = 1.0;                
input double   BreakEvenOffset = 5.0;                  
input bool     UseTrailingStop = true;                 
input double   TrailingStartR = 1.5;                   
input double   TrailingStepPips = 10.0;                
input bool     UseVolatilityTrailing = true;           

input group "=== News Risk Management ==="
input double   NewsRiskPercent = 2.0;                  
input double   MaxDailyNewsRisk = 6.0;                 
input int      MaxNewsPositions = 3;                   
input double   NewsLotMin = 0.01;                      
input double   NewsLotMax = 5.0;                       

input group "=== Visual Settings ==="
input bool     DrawNewsLines = false;                   
input bool     DrawSRLevels = false;                    
input bool     ShowNewsInfo = true;                    
input color    HighImpactColor = clrRed;               
input color    MediumImpactColor = clrOrange;          
input color    LowImpactColor = clrYellow;             
input color    SupportColor = clrGreen;                
input color    ResistanceColor = clrRed;               

//--- Complete Structures
struct NewsWebData {
    string time_str;
    string currency;
    string impact;
    string title;
};

struct NewsEvent {
    datetime time;
    string currency;
    string title;
    int impact;  // 1=Low, 2=Medium, 3=High
    bool processed;
    bool trades_placed;
    int trades_count;
    
    // Default constructor
    NewsEvent() {
        time = 0;
        currency = "";
        title = "";
        impact = 0;
        processed = false;
        trades_placed = false;
        trades_count = 0;
    }
    
    // Copy constructor
    NewsEvent(const NewsEvent &other) {
        time = other.time;
        currency = other.currency;
        title = other.title;
        impact = other.impact;
        processed = other.processed;
        trades_placed = other.trades_placed;
        trades_count = other.trades_count;
    }
};
struct SupportResistanceLevel {
    double price;
    int touches;
    datetime last_touch;
    bool is_support;
    double strength;
    
    // Default constructor
    SupportResistanceLevel() {
        price = 0.0;
        touches = 0;
        last_touch = 0;
        is_support = false;
        strength = 0.0;
    }
    
    // Copy constructor
    SupportResistanceLevel(const SupportResistanceLevel &other) {
        price = other.price;
        touches = other.touches;
        last_touch = other.last_touch;
        is_support = other.is_support;
        strength = other.strength;
    }
};
struct NewsTradeSetup {
    ulong buy_ticket;
    ulong sell_ticket;
    datetime news_time;
    string news_title;
    double support_level;
    double resistance_level;
    bool active;
    bool break_even_moved;
    datetime created_time;
};

// Dashboard integration structure
struct NewsDataForDashboard {
    bool is_active;
    bool trading_halted;
    string next_news_currency;
    string next_news_title;
    int minutes_to_next_news;
    int news_impact_level;
    double daily_risk_used_pct;
    int active_news_positions;
    int pending_news_orders;
    string trading_status;
};

//+------------------------------------------------------------------+
//| COMPLETE Advanced News Trading System Class                     |
//+------------------------------------------------------------------+
class CAdvancedNewsTrader {
private:
    // Core objects
    CTrade m_trade;
    CPositionInfo m_position;
    COrderInfo m_order;
    CSymbolInfo m_symbol;
    CAccountInfo m_account;
    
    // News data
    NewsEvent m_news_events[];
    int m_news_count;
    datetime m_last_news_update;
    
    // Support/Resistance data
    SupportResistanceLevel m_sr_levels[];
    int m_sr_count;
    datetime m_last_sr_update;
    
    // Trade management
    NewsTradeSetup m_news_trades[];
    int m_news_trades_count;
    double m_daily_news_risk_used;
    datetime m_last_daily_reset;
    
    // Web request data
    NewsWebData m_web_news_records[];
    int m_web_news_count;
    
    // Filtered symbols
    string m_filtered_symbols[];
    
    // ATR handle for volatility
    int m_atr_handle;
    
    // Dashboard data cache
    NewsDataForDashboard m_dashboard_data;
    
public:
    CAdvancedNewsTrader() : m_news_count(0), m_sr_count(0), m_news_trades_count(0),
                           m_daily_news_risk_used(0), m_last_daily_reset(0),
                           m_last_news_update(0), m_last_sr_update(0),
                           m_web_news_count(0) {
        ResetDashboardData();
    }
    
   //+------------------------------------------------------------------+
//| FIXED: Initialize the news trading system                        |
//+------------------------------------------------------------------+
bool Initialize(string symbol, long magic_number) {
    if(!EnableNewsTrading) {
        m_dashboard_data.is_active = false;
        Print("News Trader: News trading disabled");
        return true;
    }
    
    Print("News Trader: Initializing for ", symbol);
    
    // Initialize symbol
    if(!m_symbol.Name(symbol)) {
        Print("News Trader: Failed to initialize symbol ", symbol);
        return false;
    }
    
    // Set magic number
    m_trade.SetExpertMagicNumber(magic_number);
    m_trade.SetDeviationInPoints(10);
    m_trade.SetTypeFilling(ORDER_FILLING_FOK);
    m_trade.SetTypeFillingBySymbol(symbol);
    
    // Initialize ATR
    m_atr_handle = iATR(symbol, PERIOD_CURRENT, 14);
    if(m_atr_handle == INVALID_HANDLE) {
        Print("News Trader: Failed to create ATR indicator");
        return false;
    }
    
    // Parse filtered symbols
    ParseFilteredSymbols();
    
    // FIX 13: Force immediate data updates
    Print("News Trader: Loading initial news data...");
    UpdateNewsData();
    UpdateSupportResistance();
    
    // Reset daily risk tracking
    ResetDailyRiskTracking();
    
    m_dashboard_data.is_active = true;
    
    // FIX 14: Final status check
    Print("News Trader: Initialized successfully. Events loaded: ", m_news_count);
    Print("News Trader: Next news: ", GetNextNewsInfo());
    
    return true;
}
    //+------------------------------------------------------------------+
    //| Main processing function - call from OnTick                     |
    //+------------------------------------------------------------------+
    void OnTick() {
        if(!EnableNewsTrading) return;
        
        // Update data periodically
        UpdateDataIfNeeded();
        
        // Reset daily risk if new day
        CheckDailyRiskReset();
        
        // Process upcoming news events
        ProcessUpcomingNews();
        
        // Manage existing news trades
        ManageNewsTrades();
        
        // Clean up expired setups
        CleanupExpiredSetups();
        
        // Update dashboard data
        UpdateDashboardData();
    }
    
private:
    //+------------------------------------------------------------------+
    //| Parse filtered symbols from input string                         |
    //+------------------------------------------------------------------+
    void ParseFilteredSymbols() {
        string symbols = NewsSymbols;
        StringReplace(symbols, " ", "");
        
        string parts[];
        int total = StringSplit(symbols, ',', parts);
        
        ArrayResize(m_filtered_symbols, total);
        for(int i = 0; i < total; i++) {
            m_filtered_symbols[i] = parts[i];
            StringToUpper(m_filtered_symbols[i]);
        }
    }
    
    //+------------------------------------------------------------------+
    //| Check if currency should be filtered                             |
    //+------------------------------------------------------------------+
    bool IsSymbolFiltered(string currency) {
        StringToUpper(currency);
        for(int i = 0; i < ArraySize(m_filtered_symbols); i++) {
            if(m_filtered_symbols[i] == currency) return true;
        }
        return false;
    }
    
    //+------------------------------------------------------------------+
    //| Update data if needed                                            |
    //+------------------------------------------------------------------+
    void UpdateDataIfNeeded() {
        datetime current_time = TimeCurrent();
        
        // Update news data every 30 minutes
        if(current_time - m_last_news_update > 1800) {
            UpdateNewsData();
            m_last_news_update = current_time;
        }
        
        // Update S/R levels every 5 minutes
        if(current_time - m_last_sr_update > 300) {
            UpdateSupportResistance();
            m_last_sr_update = current_time;
        }
    }
    
    //+------------------------------------------------------------------+
//| FIXED: Update news data from calendar and web sources            |
//+------------------------------------------------------------------+
void UpdateNewsData() {
    Print("News Trader: Starting news data update...");
    
    m_news_count = 0;
    
    if(UseInternalCalendar) {
        Print("News Trader: Using internal calendar");
        LoadFromInternalCalendar();
    } else {
        Print("News Trader: Using web source");
        LoadFromWebSource();
    }
    
    SortNewsByTime();
    
    if(DrawNewsLines) {
        DrawNewsVerticalLines();
    }
    
    Print("News Trader: Update complete - ", m_news_count, " events loaded");
    
    // FIX 8: Force dashboard update after loading news
    UpdateDashboardData();
}
//===========================
string GetErrorDescription(int error_code) {
    switch(error_code) {
        case 0: return "No error";
        case 4001: return "Function not confirmed";
        case 4002: return "Array index out of range";
        case 4003: return "No memory for function call stack";
        case 4004: return "Recursive stack overflow";
        case 4005: return "Not enough stack for parameter";
        case 4006: return "No memory for parameter string";
        case 4007: return "No memory for temp string";
        case 4008: return "Not initialized string";
        case 4009: return "Not initialized string in array";
        case 4010: return "No memory for array string";
        case 4011: return "Too long string";
        case 4012: return "Remainder from zero divide";
        case 4013: return "Zero divide";
        case 4014: return "Unknown command";
        case 4015: return "Wrong jump";
        case 4016: return "Not initialized array";
        case 4017: return "DLL calls are not allowed";
        case 4018: return "Cannot load library";
        case 4019: return "Cannot call function";
        case 4020: return "Expert function calls are not allowed";
        case 4021: return "Not enough memory for temp string returned from function";
        case 4022: return "System is busy";
        case 4050: return "Invalid function parameters count";
        case 4051: return "Invalid function parameter value";
        case 4052: return "String function internal error";
        case 4053: return "Some array error";
        case 4054: return "Incorrect series array using";
        case 4055: return "Custom indicator error";
        case 4056: return "Arrays are incompatible";
        case 4057: return "Global variables processing error";
        case 4058: return "Global variable not found";
        case 4059: return "Function is not allowed in testing mode";
        case 4060: return "Function is not confirmed";
        case 4061: return "Send mail error";
        case 4062: return "String parameter expected";
        case 4063: return "Integer parameter expected";
        case 4064: return "Double parameter expected";
        case 4065: return "Array as parameter expected";
        case 4066: return "History data request error";
        case 4067: return "Trade error";
        case 4068: return "Resource not found";
        case 4069: return "Resource not supported";
        case 4070: return "Duplicate resource";
        case 4071: return "Custom indicator cannot initialize";
        case 4072: return "Cannot load custom indicator";
        case 4073: return "No history data";
        case 4074: return "No memory for history data";
        case 4075: return "No memory for indicator calculation";
        default: return "Unknown error " + IntegerToString(error_code);
    }
}

//=====================
 //+------------------------------------------------------------------+
//| FIXED: Load news from MQL5 internal calendar                     |
//+------------------------------------------------------------------+
void LoadFromInternalCalendar() {
    MqlCalendarValue calendar_values[];
    
    // FIX 1: Use TimeTradeServer() instead of TimeCurrent()
    datetime from_time = TimeTradeServer();
    datetime to_time = from_time + 7 * 24 * 3600; // Always look 7 days ahead
    
    // FIX 2: Add comprehensive debugging
    Print("News Trader: Requesting calendar data from ", 
          TimeToString(from_time), " to ", TimeToString(to_time));
    
    ResetLastError();
    
    // FIX 3: Use proper error handling
    int total = CalendarValueHistory(calendar_values, from_time, to_time);
    
    // FIX 4: Better error checking and debugging
    if(total <= 0) {
        int error_code = GetLastError();
        Print("News Trader: CalendarValueHistory failed. Total: ", total, 
      ", Error: ", error_code, " (", GetErrorDescription(error_code), ")");
        
        // FIX 5: Try with extended time range if no data
        if(total == 0) {
            Print("News Trader: Trying extended time range...");
            to_time = from_time + (7 * 24 * 3600); // Try 7 days
            total = CalendarValueHistory(calendar_values, from_time, to_time);
            Print("News Trader: Extended range result: ", total, " events");
        }
        
        if(total <= 0) return;
    }
    
    Print("News Trader: Retrieved ", total, " calendar values");
    
    ArrayResize(m_news_events, total);
    
    for(int i = 0; i < total && m_news_count < total; i++) {
        MqlCalendarEvent event_info;
        MqlCalendarCountry country_info;
        
        // FIX 6: Add error checking for event details
        if(!CalendarEventById(calendar_values[i].event_id, event_info)) {
            Print("News Trader: Failed to get event info for ID: ", calendar_values[i].event_id);
            continue;
        }
        if(!CalendarCountryById(event_info.country_id, country_info)) {
            Print("News Trader: Failed to get country info for ID: ", event_info.country_id);
            continue;
        }
        
        // FIX 7: Add debugging for filtering
        if(!ShouldProcessImpact(event_info.importance)) {
            Print("News Trader: Skipping event (impact filter): ", event_info.name, 
                  ", Importance: ", (int)event_info.importance);
            continue;
        }
        if(!IsSymbolFiltered(country_info.currency)) {
            Print("News Trader: Skipping event (currency filter): ", country_info.currency);
            continue;
        }
        
        // Store the news event
        m_news_events[m_news_count].time = calendar_values[i].time;
        m_news_events[m_news_count].currency = country_info.currency;
        m_news_events[m_news_count].title = event_info.name;
        m_news_events[m_news_count].impact = (int)event_info.importance;
        m_news_events[m_news_count].processed = false;
        m_news_events[m_news_count].trades_placed = false;
        m_news_events[m_news_count].trades_count = 0;
        
        Print("News Trader: Added event - ", country_info.currency, " ", 
              event_info.name, " at ", TimeToString(calendar_values[i].time), 
              " (Impact: ", (int)event_info.importance, ")");
        
        m_news_count++;
    }
}
    
    //+------------------------------------------------------------------+
    //| Load news from web source                                        |
    //+------------------------------------------------------------------+
    void LoadFromWebSource() {
        string html_content = FetchWebNewsData();
        if(StringLen(html_content) == 0) return;
        
        ParseWebNewsData(html_content);
        
        ArrayResize(m_news_events, m_web_news_count);
        for(int i = 0; i < m_web_news_count; i++) {
            m_news_events[i].time = ParseWebTime(m_web_news_records[i].time_str);
            m_news_events[i].currency = m_web_news_records[i].currency;
            m_news_events[i].title = m_web_news_records[i].title;
            m_news_events[i].impact = ParseWebImpact(m_web_news_records[i].impact);
            m_news_events[i].processed = false;
            m_news_events[i].trades_placed = false;
            m_news_events[i].trades_count = 0;
        }
        m_news_count = m_web_news_count;
    }
    
   //+------------------------------------------------------------------+
//| FIXED: Fetch news data from forexprostools.com with fallback    |
//+------------------------------------------------------------------+
string FetchWebNewsData() {
    string result_data = "";
    
    // Primary source: Forexprostools.com (like Matrix system)
    result_data = FetchFromForexprostools();
    
    if(StringLen(result_data) > 0) {
        Print("News Trader: Successfully fetched from Forexprostools.com");
        return result_data;
    }
    
    // Fallback 1: Forex Factory JSON API
    result_data = FetchFromForexFactory();
    
    if(StringLen(result_data) > 0) {
        Print("News Trader: Using Forex Factory fallback");
        return result_data;
    }
    
    // Fallback 2: Alternative source
    result_data = FetchFromFairEconomy();
    
    if(StringLen(result_data) > 0) {
        Print("News Trader: Using FairEconomy fallback");
        return result_data;
    }
    
    Print("News Trader: All web sources failed");
    return "";
}

//+------------------------------------------------------------------+
//| Fetch from Forexprostools.com (Primary source like Matrix)      |
//+------------------------------------------------------------------+
string FetchFromForexprostools() {
    string cookie = NULL, headers;
    string reqheaders = "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36\r\n";
    char post[], result[];
    
    // Forexprostools.com URL with parameters
    string news_url = "http://ec.forexprostools.com/?columns=exc_currency,exc_importance,exc_actual,exc_forecast,exc_previous&importance=1,2,3&calType=week&timeZone=15&lang=1";
    
    Print("News Trader: Fetching from Forexprostools.com...");
    
    ResetLastError();
    int timeout = 10000;
    int res = WebRequest("GET", news_url, reqheaders, timeout, post, result, headers);
    
    if(res == -1) {
        int error_code = GetLastError();
        Print("News Trader: Forexprostools WebRequest failed. Error: ", error_code);
        if(error_code == 4060) {
            Print("News Trader: Please add 'http://ec.forexprostools.com/' to allowed URLs in Tools->Options->Expert Advisors->WebRequest");
        }
        return "";
    }
    
    string html_content = CharArrayToString(result);
    
    if(StringLen(html_content) < 100) {
        Print("News Trader: Forexprostools returned insufficient data");
        return "";
    }
    
    return html_content;
}

//+------------------------------------------------------------------+
//| Fetch from Forex Factory JSON (Fallback 1)                     |
//+------------------------------------------------------------------+
string FetchFromForexFactory() {
    string cookie = NULL, headers;
    string reqheaders = "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36\r\n";
    char post[], result[];
    
    string news_url = "https://cdn-nfs.faireconomy.media/ff_calendar_thisweek.json";
    
    Print("News Trader: Trying Forex Factory fallback...");
    
    ResetLastError();
    int timeout = 10000;
    int res = WebRequest("GET", news_url, reqheaders, timeout, post, result, headers);
    
    if(res == -1) {
        int error_code = GetLastError();
        Print("News Trader: Forex Factory WebRequest failed. Error: ", error_code);
        return "";
    }
    
    return CharArrayToString(result);
}

//+------------------------------------------------------------------+
//| Fetch from FairEconomy (Fallback 2)                            |
//+------------------------------------------------------------------+
string FetchFromFairEconomy() {
    string cookie = NULL, headers;
    string reqheaders = "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36\r\n";
    char post[], result[];
    
    string news_url = "https://nfs.faireconomy.media/ff_calendar_thisweek.json";
    
    Print("News Trader: Trying FairEconomy fallback...");
    
    ResetLastError();
    int timeout = 10000;
    int res = WebRequest("GET", news_url, reqheaders, timeout, post, result, headers);
    
    if(res == -1) {
        int error_code = GetLastError();
        Print("News Trader: FairEconomy WebRequest failed. Error: ", error_code);
        return "";
    }
    
    return CharArrayToString(result);
}

//+------------------------------------------------------------------+
//| FIXED: Parse web news data with multiple source support         |
//+------------------------------------------------------------------+
void ParseWebNewsData(string content) {
    m_web_news_count = 0;
    ArrayResize(m_web_news_records, 200);
    
    // Detect source type and parse accordingly
    if(StringFind(content, "economicCalendarData") >= 0) {
        // Forexprostools.com HTML format
        ParseForexprostoolsData(content);
    } else if(StringFind(content, "[{") >= 0 && StringFind(content, "}]") >= 0) {
        // JSON format (Forex Factory or FairEconomy)
        ParseJSONNewsData(content);
    } else {
        Print("News Trader: Unknown web data format");
    }
    
    Print("News Trader: Parsed ", m_web_news_count, " events from web source");
}

//+------------------------------------------------------------------+
//| Parse Forexprostools.com HTML data - FIXED VERSION              |
//+------------------------------------------------------------------+
void ParseForexprostoolsData(string html_content) {
    // Debug: Save content to file to analyze
    int debug_handle = FileOpen("news_debug.html", FILE_WRITE|FILE_TXT|FILE_ANSI);
    if(debug_handle != INVALID_HANDLE) {
        FileWrite(debug_handle, html_content);
        FileClose(debug_handle);
        Print("News Trader: Debug HTML saved to news_debug.html");
    }
    
    // Look for the calendar table
    int table_start = StringFind(html_content, "<table");
    int table_end = StringFind(html_content, "</table>", table_start);
    
    if(table_start == -1 || table_end == -1) {
        Print("News Trader: No table found in HTML");
        return;
    }
    
    // Extract table rows
    int pos = table_start;
    while(pos < table_end && pos != -1 && m_web_news_count < 200) {
        // Find next row
        int row_start = StringFind(html_content, "<tr", pos);
        if(row_start == -1 || row_start > table_end) break;
        
        int row_end = StringFind(html_content, "</tr>", row_start);
        if(row_end == -1) break;
        
        string row = StringSubstr(html_content, row_start, row_end - row_start);
        
        // Parse the row for news data
        if(ParseForexprostoolsRow(row)) {
            m_web_news_count++;
        }
        
        pos = row_end + 5;
    }
}

//+------------------------------------------------------------------+
//| Parse individual row from Forexprostools                         |
//+------------------------------------------------------------------+
bool ParseForexprostoolsRow(string row) {
    // Skip header rows
    if(StringFind(row, "<th") >= 0) return false;
    
    // Extract time
    string time_str = "";
    int time_pos = StringFind(row, "class=\"time\"");
    if(time_pos >= 0) {
        int start = StringFind(row, ">", time_pos) + 1;
        int end = StringFind(row, "<", start);
        if(start > 0 && end > start) {
            time_str = StringSubstr(row, start, end - start);
        }
    }
    
    // Extract currency
    string currency = "";
    int flag_pos = StringFind(row, "class=\"flag\"");
    if(flag_pos >= 0) {
        int title_pos = StringFind(row, "title=\"", flag_pos);
        if(title_pos >= 0) {
            int start = title_pos + 7;
            int end = StringFind(row, "\"", start);
            if(end > start) {
                currency = StringSubstr(row, start, end - start);
                // Extract currency code (first 3 letters)
                if(StringLen(currency) >= 3) {
                    currency = StringSubstr(currency, 0, 3);
                    StringToUpper(currency);
                }
            }
        }
    }
    
    // Extract event title
    string title = "";
    int event_pos = StringFind(row, "class=\"event\"");
    if(event_pos >= 0) {
        int start = StringFind(row, ">", event_pos) + 1;
        int end = StringFind(row, "<", start);
        if(start > 0 && end > start) {
            title = StringSubstr(row, start, end - start);
            // Clean up HTML entities
            StringReplace(title, "&nbsp;", " ");
            StringReplace(title, "&amp;", "&");
        }
    }
    
    // Extract impact
    string impact = "2"; // Default medium
    if(StringFind(row, "grayFullBullishIcon") >= 0 || StringFind(row, "redFullBullishIcon") >= 0) {
        impact = "3"; // High
    } else if(StringFind(row, "orangeFullBullishIcon") >= 0) {
        impact = "2"; // Medium
    } else if(StringFind(row, "yellowFullBullishIcon") >= 0) {
        impact = "1"; // Low
    }
    
    // Validate and store
    if(time_str != "" && currency != "" && title != "") {
        if(m_web_news_count < ArraySize(m_web_news_records)) {
            // Convert time to proper format
            // Forexprostools uses format like "08:30"
            MqlDateTime current_dt;
            TimeToStruct(TimeCurrent(), current_dt);
            
            // Parse hour and minute
            string time_parts[];
            int parts = StringSplit(time_str, ':', time_parts);
            if(parts == 2) {
                int hour = (int)StringToInteger(time_parts[0]);
                int minute = (int)StringToInteger(time_parts[1]);
                
                // Create datetime string
                string date_str = StringFormat("%04d.%02d.%02d %02d:%02d:00",
                                             current_dt.year, current_dt.mon, current_dt.day,
                                             hour, minute);
                
                m_web_news_records[m_web_news_count].time_str = date_str;
                m_web_news_records[m_web_news_count].currency = currency;
                m_web_news_records[m_web_news_count].title = title;
                m_web_news_records[m_web_news_count].impact = impact;
                
                return true;
            }
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Extract individual event from Forexprostools HTML              |
//+------------------------------------------------------------------+
bool ExtractForexprostoolsEvent(string line, int index) {
    // Extract timestamp
    string timestamp = ExtractBetween(line, "data-event-datetime=\"", "\"");
    if(timestamp == "") {
        timestamp = ExtractBetween(line, "event_timestamp:", ",");
    }
    
    // Extract currency
    string currency = ExtractBetween(line, "data-currency=\"", "\"");
    if(currency == "") {
        currency = ExtractBetween(line, "currency\":\"", "\"");
    }
    
    // Extract title/event name
    string title = ExtractBetween(line, "title=\"", "\"");
    if(title == "") {
        title = ExtractBetween(line, "event\":\"", "\"");
    }
    
    // Extract importance
    string importance = ExtractBetween(line, "data-importance=\"", "\"");
    if(importance == "") {
        importance = ExtractBetween(line, "importance\":", ",");
    }
    
    // Validate required fields
    if(timestamp == "" || currency == "" || title == "") {
        return false;
    }
    
    // Store event
    m_web_news_records[index].time_str = timestamp;
    m_web_news_records[index].currency = currency;
    m_web_news_records[index].title = title;
    m_web_news_records[index].impact = importance;
    
    return true;
}
//+------------------------------------------------------------------+
//| Custom string trimming functions                                 |
//+------------------------------------------------------------------+
string StringTrimLeft(string str) {
    while(StringLen(str) > 0 && (StringGetCharacter(str, 0) == ' ' || 
          StringGetCharacter(str, 0) == '\t' || StringGetCharacter(str, 0) == '\r' || 
          StringGetCharacter(str, 0) == '\n')) {
        str = StringSubstr(str, 1);
    }
    return str;
}

string StringTrimRight(string str) {
    int len = StringLen(str);
    while(len > 0 && (StringGetCharacter(str, len-1) == ' ' || 
          StringGetCharacter(str, len-1) == '\t' || StringGetCharacter(str, len-1) == '\r' || 
          StringGetCharacter(str, len-1) == '\n')) {
        len--;
        str = StringSubstr(str, 0, len);
    }
    return str;
}

string StringTrim(string str) {
    return StringTrimLeft(StringTrimRight(str));
}
//+------------------------------------------------------------------+
//| Parse JSON format data (Forex Factory/FairEconomy)             |
//+------------------------------------------------------------------+
void ParseJSONNewsData(string json_content) {
    // Simple JSON parsing for news data
    string lines[];
    int line_count = StringSplit(json_content, '\n', lines);
    
    bool in_event = false;
    string current_event = "";
    
    for(int i = 0; i < line_count && m_web_news_count < 200; i++) {
        string line = StringTrim(lines[i]); // FIXED: Use custom trim function
        
        if(StringFind(line, "{") >= 0) {
            in_event = true;
            current_event = "";
        }
        
        if(in_event) {
            current_event += line + " ";
        }
        
        if(StringFind(line, "}") >= 0 && in_event) {
            if(ExtractJSONEvent(current_event, m_web_news_count)) {
                m_web_news_count++;
            }
            in_event = false;
        }
    }
}


//+------------------------------------------------------------------+
//| Extract individual event from JSON                              |
//+------------------------------------------------------------------+
bool ExtractJSONEvent(string json_event, int index) {
    // Extract fields from JSON event
    string title = ExtractJSONValue(json_event, "title");
    if(title == "") title = ExtractJSONValue(json_event, "event");
    
    string currency = ExtractJSONValue(json_event, "currency");
    if(currency == "") currency = ExtractJSONValue(json_event, "country");
    
    string impact = ExtractJSONValue(json_event, "impact");
    if(impact == "") impact = ExtractJSONValue(json_event, "importance");
    
    string time_str = ExtractJSONValue(json_event, "date");
    if(time_str == "") time_str = ExtractJSONValue(json_event, "time");
    
    // Validate required fields
    if(title == "" || currency == "" || time_str == "") {
        return false;
    }
    
    // Store event
    m_web_news_records[index].title = title;
    m_web_news_records[index].currency = currency;
    m_web_news_records[index].impact = impact;
    m_web_news_records[index].time_str = time_str;
    
    return true;
}

//+------------------------------------------------------------------+
//| Helper function to extract text between delimiters              |
//+------------------------------------------------------------------+
string ExtractBetween(string source, string start_delimiter, string end_delimiter) {
    int start_pos = StringFind(source, start_delimiter);
    if(start_pos == -1) return "";
    
    start_pos += StringLen(start_delimiter);
    int end_pos = StringFind(source, end_delimiter, start_pos);
    if(end_pos == -1) return "";
    
    return StringSubstr(source, start_pos, end_pos - start_pos);
}

//+------------------------------------------------------------------+
//| ENHANCED: Extract JSON value with better parsing                |
//+------------------------------------------------------------------+
string ExtractJSONValue(string json_line, string key) {
    // Try different JSON patterns
    string patterns[] = {
        "\"" + key + "\":\"",     // "key":"value"
        "\"" + key + "\":",       // "key":value
        key + ":\"",              // key:"value"
        key + ":"                 // key:value
    };
    
    for(int p = 0; p < ArraySize(patterns); p++) {
        int start_pos = StringFind(json_line, patterns[p]);
        if(start_pos == -1) continue;
        
        start_pos += StringLen(patterns[p]);
        
        // Find end delimiter
        string end_delim = "\"";
        if(StringFind(patterns[p], "\":") >= 0 && StringFind(patterns[p], "\":\"") == -1) {
            end_delim = ","; // For non-string values
        }
        
        int end_pos = StringFind(json_line, end_delim, start_pos);
        if(end_pos == -1) {
            // Try end of object
            end_pos = StringFind(json_line, "}", start_pos);
            if(end_pos == -1) continue;
        }
        
        string value = StringSubstr(json_line, start_pos, end_pos - start_pos);
        StringReplace(value, "\\\"", "\""); // Unescape quotes
        return StringTrim(value); // FIXED: Use custom trim function
    }
    
    return "";
}
//+------------------------------------------------------------------+
//| ENHANCED: Parse web time with multiple formats                  |
//+------------------------------------------------------------------+
datetime ParseWebTime(string time_str) {
    datetime result = 0;
    
    // Try different time formats
    
    // Unix timestamp
    if(StringLen(time_str) == 10 && StringFind(time_str, "-") == -1) {
        result = (datetime)StringToInteger(time_str);
        if(result > 0) return result;
    }
    
    // ISO format: 2025-06-26T18:30:00
    if(StringFind(time_str, "T") >= 0) {
        StringReplace(time_str, "T", " ");
        StringReplace(time_str, "Z", "");
        result = StringToTime(time_str);
        if(result > 0) return result;
    }
    
    // Standard format: 2025-06-26 18:30:00
    result = StringToTime(time_str);
    if(result > 0) return result;
    
    // Date only: 2025-06-26
    if(StringFind(time_str, ":") == -1) {
        result = StringToTime(time_str + " 00:00:00");
        if(result > 0) return result;
    }
    
    Print("News Trader: Failed to parse time: ", time_str);
    return 0;
}

//+------------------------------------------------------------------+
//| ENHANCED: Parse web impact with multiple formats                |
//+------------------------------------------------------------------+
int ParseWebImpact(string impact_str) {
    StringToUpper(impact_str);
    
    // Numeric format
    if(impact_str == "3" || impact_str == "HIGH") return 3;
    if(impact_str == "2" || impact_str == "MEDIUM" || impact_str == "MODERATE") return 2;
    if(impact_str == "1" || impact_str == "LOW") return 1;
    
    // Color/symbol format (some sources use these)
    if(StringFind(impact_str, "RED") >= 0 || StringFind(impact_str, "BULL") >= 0) return 3;
    if(StringFind(impact_str, "ORANGE") >= 0 || StringFind(impact_str, "YELLOW") >= 0) return 2;
    if(StringFind(impact_str, "GREEN") >= 0) return 1;
    
    return 2; // Default to medium if unclear
}
  //====================================================================  
   
    
    //+------------------------------------------------------------------+
    //| Update support and resistance levels                             |
    //+------------------------------------------------------------------+
    void UpdateSupportResistance() {
        ArrayResize(m_sr_levels, 0);
        m_sr_count = 0;
        
        double high[], low[], close[];
        ArraySetAsSeries(high, true);
        ArraySetAsSeries(low, true);
        ArraySetAsSeries(close, true);
        
        int bars = 100;
        if(CopyHigh(m_symbol.Name(), PERIOD_CURRENT, 0, bars, high) != bars) return;
        if(CopyLow(m_symbol.Name(), PERIOD_CURRENT, 0, bars, low) != bars) return;
        if(CopyClose(m_symbol.Name(), PERIOD_CURRENT, 0, bars, close) != bars) return;
        
        // Find significant highs and lows
        for(int i = 5; i < bars - 5; i++) {
            // Check for resistance levels (local highs)
            if(IsLocalHigh(high, i, 3)) {
                AddSRLevel(high[i], false, i);
            }
            
            // Check for support levels (local lows)
            if(IsLocalLow(low, i, 3)) {
                AddSRLevel(low[i], true, i);
            }
        }
        
        // Remove weak levels and consolidate nearby levels
        ConsolidateSRLevels();
        
        // Draw S/R levels if enabled
        if(DrawSRLevels) {
            DrawSupportResistanceLevels();
        }
        
        Print("News Trader: Updated S/R levels - ", m_sr_count, " levels found");
    }
    
    //+------------------------------------------------------------------+
    //| Add support/resistance level                                     |
    //+------------------------------------------------------------------+
    void AddSRLevel(double price, bool is_support, int bar_index) {
        // Check if level already exists nearby
        for(int i = 0; i < m_sr_count; i++) {
            if(MathAbs(m_sr_levels[i].price - price) < MinDistanceFromSR * m_symbol.Point() * 10) {
                m_sr_levels[i].touches++;
                m_sr_levels[i].last_touch = iTime(m_symbol.Name(), PERIOD_CURRENT, bar_index);
                return;
            }
        }
        
        // Add new level
        ArrayResize(m_sr_levels, m_sr_count + 1);
        m_sr_levels[m_sr_count].price = price;
        m_sr_levels[m_sr_count].is_support = is_support;
        m_sr_levels[m_sr_count].touches = 1;
        m_sr_levels[m_sr_count].last_touch = iTime(m_symbol.Name(), PERIOD_CURRENT, bar_index);
        m_sr_levels[m_sr_count].strength = CalculateLevelStrength(price, is_support);
        m_sr_count++;
    }
    
//+------------------------------------------------------------------+
//| Calculate level strength                                         |
//+------------------------------------------------------------------+
double CalculateLevelStrength(double price, bool is_support) {
    double current_price = m_symbol.Bid();

    // VVV THIS IS THE FIX VVV
    // If the current price is zero, we can't do the calculation, so return a strength of 0.
    if(current_price <= 0) {
        return 0.0;
    }
    // ^^^ END OF FIX ^^^

    double distance = MathAbs(current_price - price) / current_price;

    // Closer levels are stronger
    double strength = 1.0 - (distance * 100); // Base strength

    return MathMax(0.1, MathMin(1.0, strength));
}
    
    //+------------------------------------------------------------------+
    //| Consolidate nearby S/R levels                                    |
    //+------------------------------------------------------------------+
    void ConsolidateSRLevels() {
    double min_distance = MinDistanceFromSR * m_symbol.Point() * 10;
    
    // Sort levels by price using individual field swapping
    for(int i = 0; i < m_sr_count - 1; i++) {
        for(int j = 0; j < m_sr_count - i - 1; j++) {
            if(m_sr_levels[j].price > m_sr_levels[j + 1].price) {
                // Swap using individual fields
                double temp_price = m_sr_levels[j].price;
                int temp_touches = m_sr_levels[j].touches;
                datetime temp_last_touch = m_sr_levels[j].last_touch;
                bool temp_is_support = m_sr_levels[j].is_support;
                double temp_strength = m_sr_levels[j].strength;
                
                m_sr_levels[j].price = m_sr_levels[j + 1].price;
                m_sr_levels[j].touches = m_sr_levels[j + 1].touches;
                m_sr_levels[j].last_touch = m_sr_levels[j + 1].last_touch;
                m_sr_levels[j].is_support = m_sr_levels[j + 1].is_support;
                m_sr_levels[j].strength = m_sr_levels[j + 1].strength;
                
                m_sr_levels[j + 1].price = temp_price;
                m_sr_levels[j + 1].touches = temp_touches;
                m_sr_levels[j + 1].last_touch = temp_last_touch;
                m_sr_levels[j + 1].is_support = temp_is_support;
                m_sr_levels[j + 1].strength = temp_strength;
            }
        }
    }
    
    // Rest of the function remains the same...
    int new_count = 0;
    for(int i = 0; i < m_sr_count; i++) {
        if(m_sr_levels[i].touches >= 1) {
            if(new_count == 0 || MathAbs(m_sr_levels[i].price - m_sr_levels[new_count-1].price) >= min_distance) {
                if(new_count != i) {
                    m_sr_levels[new_count].price = m_sr_levels[i].price;
                    m_sr_levels[new_count].touches = m_sr_levels[i].touches;
                    m_sr_levels[new_count].last_touch = m_sr_levels[i].last_touch;
                    m_sr_levels[new_count].is_support = m_sr_levels[i].is_support;
                    m_sr_levels[new_count].strength = m_sr_levels[i].strength;
                }
                new_count++;
            }
        }
    }
    
    ArrayResize(m_sr_levels, new_count);
    m_sr_count = new_count;
}

    //+------------------------------------------------------------------+
    //| Process upcoming news events                                     |
    //+------------------------------------------------------------------+
    void ProcessUpcomingNews() {
        datetime current_time = TimeCurrent();
        
        for(int i = 0; i < m_news_count; i++) {
            // FIXED: Remove pointer syntax error
            if(m_news_events[i].processed || m_news_events[i].trades_placed) continue;
            if(m_news_events[i].time <= current_time) continue;
            
            // Check if we're in the setup window (5-15 minutes before news)
            int minutes_to_news = (int)((m_news_events[i].time - current_time) / 60);
            
            if(minutes_to_news <= StopBeforeNewsMin && minutes_to_news >= 5) {
                if(ShouldTradeThisNews(m_news_events[i])) {
                    PlaceNewsTradeSetup(m_news_events[i]);
                    m_news_events[i].trades_placed = true;
                }
            }
        }
    }
    
    //+------------------------------------------------------------------+
    //| Check if we should trade this news event                         |
    //+------------------------------------------------------------------+
    bool ShouldTradeThisNews(const NewsEvent &news) {
        // Check if symbol contains this currency
        if(!DoesSymbolContainCurrency(news.currency)) return false;
        
        // Check impact level settings
        if(!ShouldProcessImpact((ENUM_CALENDAR_EVENT_IMPORTANCE)news.impact)) return false;
        
        // Check daily risk limits
        if(m_daily_news_risk_used >= MaxDailyNewsRisk) {
            Print("News Trader: Daily risk limit reached");
            return false;
        }
        
        // Check maximum positions
        if(GetNewsPositionsCount() >= MaxNewsPositions) {
            Print("News Trader: Maximum news positions reached");
            return false;
        }
        
        // Check if we already have trades for this news
        if(HasTradesForNews(news.time)) return false;
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Place news trade setup                                           |
    //+------------------------------------------------------------------+
    void PlaceNewsTradeSetup(const NewsEvent &news) {
        Print("News Trader: Setting up trades for ", news.currency, " ", news.title);
        
        // Find best support and resistance levels
        double support_level = FindBestSupportLevel();
        double resistance_level = FindBestResistanceLevel();
        
        if(support_level == 0 || resistance_level == 0) {
            Print("News Trader: No suitable S/R levels found");
            return;
        }
        
        double current_price = m_symbol.Bid();
        
        // Validate S/R levels distance
        double sr_distance = resistance_level - support_level;
        double min_distance = MinDistanceFromSR * m_symbol.Point() * 10;
        double max_distance = MaxDistanceFromSR * m_symbol.Point() * 10;
        
        if(sr_distance < min_distance || sr_distance > max_distance) {
            Print("News Trader: S/R levels too close or too far apart");
            return;
        }
        
        // Calculate trade parameters
        double buffer = PendingOrderBuffer * m_symbol.Point() * 10;
        double buy_entry = resistance_level + buffer;
        double sell_entry = support_level - buffer;
        
        // Calculate stops and targets
        double buy_stop = support_level - buffer;
        double sell_stop = resistance_level + buffer;
        
        // Validate risk/reward ratio
        double buy_risk = buy_entry - buy_stop;
        double sell_risk = sell_stop - sell_entry;
        double target_distance = sr_distance * 1.5; // 1.5x the S/R range
        
        double buy_target = buy_entry + target_distance;
        double sell_target = sell_entry - target_distance;
        
        double buy_rr = target_distance / buy_risk;
        double sell_rr = target_distance / sell_risk;
        
        if(buy_rr < MinRiskRewardRatio || sell_rr < MinRiskRewardRatio) {
            Print("News Trader: Risk/reward ratio too low - Buy RR: ", buy_rr, ", Sell RR: ", sell_rr);
            return;
        }
        
        // Calculate lot size
        double lot_size = CalculateNewsLotSize(buy_risk);
        if(lot_size <= 0) return;
        
        // Place pending orders
        datetime expiry = news.time + NewsOrderExpiry * 60;
        
        ulong buy_ticket = 0, sell_ticket = 0;
        
        // Place buy stop order
        if(m_trade.BuyStop(lot_size, buy_entry, m_symbol.Name(), buy_stop, buy_target, 
                          ORDER_TIME_SPECIFIED, expiry, "News_" + news.currency)) {
            buy_ticket = m_trade.ResultOrder();
            Print("News Trader: Buy stop placed at ", buy_entry, " Ticket: ", buy_ticket);
        }
        
        // Place sell stop order
        if(m_trade.SellStop(lot_size, sell_entry, m_symbol.Name(), sell_stop, sell_target,
                           ORDER_TIME_SPECIFIED, expiry, "News_" + news.currency)) {
            sell_ticket = m_trade.ResultOrder();
            Print("News Trader: Sell stop placed at ", sell_entry, " Ticket: ", sell_ticket);
        }
        
        // Store trade setup
        if(buy_ticket > 0 || sell_ticket > 0) {
            ArrayResize(m_news_trades, m_news_trades_count + 1);
            m_news_trades[m_news_trades_count].buy_ticket = buy_ticket;
            m_news_trades[m_news_trades_count].sell_ticket = sell_ticket;
            m_news_trades[m_news_trades_count].news_time = news.time;
            m_news_trades[m_news_trades_count].news_title = news.title;
            m_news_trades[m_news_trades_count].support_level = support_level;
            m_news_trades[m_news_trades_count].resistance_level = resistance_level;
            m_news_trades[m_news_trades_count].active = true;
            m_news_trades[m_news_trades_count].break_even_moved = false;
            m_news_trades[m_news_trades_count].created_time = TimeCurrent();
            m_news_trades_count++;
            
            // Update daily risk usage
            double risk_amount = lot_size * buy_risk / m_symbol.Point() * m_symbol.TickValue();
            double risk_percent = (risk_amount / m_account.Balance()) * 100;
            m_daily_news_risk_used += risk_percent;
        }
    }
    
    //+------------------------------------------------------------------+
    //| Find best support level                                          |
    //+------------------------------------------------------------------+
    double FindBestSupportLevel() {
        double current_price = m_symbol.Bid();
        double best_level = 0;
        double best_strength = 0;
        
        for(int i = 0; i < m_sr_count; i++) {
            if(!m_sr_levels[i].is_support) continue;
            if(m_sr_levels[i].price >= current_price) continue;
            
            double distance = current_price - m_sr_levels[i].price;
            double distance_pips = distance / (m_symbol.Point() * 10);
            
            if(distance_pips < MinDistanceFromSR || distance_pips > MaxDistanceFromSR) continue;
            
            if(m_sr_levels[i].strength > best_strength) {
                best_strength = m_sr_levels[i].strength;
                best_level = m_sr_levels[i].price;
            }
        }
        
        return best_level;
    }
    
    //+------------------------------------------------------------------+
    //| Find best resistance level                                       |
    //+------------------------------------------------------------------+
    double FindBestResistanceLevel() {
        double current_price = m_symbol.Ask();
        double best_level = 0;
        double best_strength = 0;
        
        for(int i = 0; i < m_sr_count; i++) {
            if(m_sr_levels[i].is_support) continue;
            if(m_sr_levels[i].price <= current_price) continue;
            
            double distance = m_sr_levels[i].price - current_price;
            double distance_pips = distance / (m_symbol.Point() * 10);
            
            if(distance_pips < MinDistanceFromSR || distance_pips > MaxDistanceFromSR) continue;
            
            if(m_sr_levels[i].strength > best_strength) {
                best_strength = m_sr_levels[i].strength;
                best_level = m_sr_levels[i].price;
            }
        }
        
        return best_level;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate lot size for news trades                               |
    //+------------------------------------------------------------------+
    double CalculateNewsLotSize(double risk_distance) {
        double risk_amount = m_account.Balance() * NewsRiskPercent / 100.0;
        double tick_value = m_symbol.TickValue();
        double tick_size = m_symbol.TickSize();
        
        if(risk_distance <= 0 || tick_value <= 0 || tick_size <= 0) return 0;
        
        double lot_size = (risk_amount * tick_size) / (risk_distance * tick_value);
        
        // Apply limits with renamed variables
        lot_size = MathMax(NewsLotMin, lot_size);
        lot_size = MathMin(NewsLotMax, lot_size);
        
        // Normalize
        double lot_step = m_symbol.LotsStep();
        lot_size = MathRound(lot_size / lot_step) * lot_step;
        
        return NormalizeDouble(lot_size, 2);
    }
    
    //+------------------------------------------------------------------+
    //| Manage existing news trades                                      |
    //+------------------------------------------------------------------+
    void ManageNewsTrades() {
        for(int i = 0; i < m_news_trades_count; i++) {
            if(!m_news_trades[i].active) continue;
            
            ManageNewsTradeSetup(m_news_trades[i]);
        }
    }
    
    //+------------------------------------------------------------------+
    //| Manage individual news trade setup                               |
    //+------------------------------------------------------------------+
    void ManageNewsTradeSetup(NewsTradeSetup &setup) {
        bool buy_filled = false, sell_filled = false;
        ulong active_ticket = 0;
        
        // Check if orders were filled
        if(setup.buy_ticket > 0) {
            if(!m_order.Select(setup.buy_ticket)) {
                // Order might be filled, check positions
                for(int i = 0; i < PositionsTotal(); i++) {
                    if(m_position.SelectByIndex(i) && m_position.Identifier() == setup.buy_ticket) {
                        buy_filled = true;
                        active_ticket = setup.buy_ticket;
                        break;
                    }
                }
            }
        }
        
        if(setup.sell_ticket > 0) {
            if(!m_order.Select(setup.sell_ticket)) {
                // Order might be filled, check positions
                for(int i = 0; i < PositionsTotal(); i++) {
                    if(m_position.SelectByIndex(i) && m_position.Identifier() == setup.sell_ticket) {
                        sell_filled = true;
                        active_ticket = setup.sell_ticket;
                        break;
                    }
                }
            }
        }
        
        // If one order filled, cancel the other
        if(buy_filled && setup.sell_ticket > 0) {
            if(m_order.Select(setup.sell_ticket)) {
                m_trade.OrderDelete(setup.sell_ticket);
            }
            setup.sell_ticket = 0;
        }
        
        if(sell_filled && setup.buy_ticket > 0) {
            if(m_order.Select(setup.buy_ticket)) {
                m_trade.OrderDelete(setup.buy_ticket);
            }
            setup.buy_ticket = 0;
        }
        
        // Manage active position
        if(active_ticket > 0 && m_position.SelectByTicket(active_ticket)) {
            ManageNewsPosition(setup, active_ticket);
        }
        
        // Check if setup should be deactivated
        if(TimeCurrent() - setup.news_time > NewsTradeWindowMin * 60) {
            CleanupNewsSetup(setup);
        }
    }
    
    //+------------------------------------------------------------------+
    //| Manage news position with break-even and trailing stops         |
    //+------------------------------------------------------------------+
    void ManageNewsPosition(NewsTradeSetup &setup, ulong ticket) {
        if(!m_position.SelectByTicket(ticket)) return;
        
        double entry_price = m_position.PriceOpen();
        double stop_loss = m_position.StopLoss();
        double current_price = m_position.PositionType() == POSITION_TYPE_BUY ? 
                              m_symbol.Bid() : m_symbol.Ask();
        
        double risk_distance = MathAbs(entry_price - stop_loss);
        if(risk_distance == 0) return;
        
        double profit_distance = m_position.PositionType() == POSITION_TYPE_BUY ?
                                current_price - entry_price : entry_price - current_price;
        
        double profit_r = profit_distance / risk_distance;
        
        // Move to break-even
        if(UseBreakEven && !setup.break_even_moved && profit_r >= BreakEvenTriggerR) {
            double new_stop = entry_price + (m_position.PositionType() == POSITION_TYPE_BUY ? 
                             BreakEvenOffset : -BreakEvenOffset) * m_symbol.Point() * 10;
            
            if(m_trade.PositionModify(ticket, new_stop, m_position.TakeProfit())) {
                Print("News Trader: Break-even set for ticket ", ticket);
                setup.break_even_moved = true;
            }
        }
        
        // Apply trailing stop
        if(UseTrailingStop && profit_r >= TrailingStartR) {
            ApplyAdaptiveTrailingStop(ticket, setup);
        }
    }
    
    //+------------------------------------------------------------------+
    //| Apply adaptive trailing stop                                     |
    //+------------------------------------------------------------------+
    void ApplyAdaptiveTrailingStop(ulong ticket, NewsTradeSetup &setup) {
        if(!m_position.SelectByTicket(ticket)) return;
        
        double atr_value = GetCurrentATR();
        double trailing_distance = TrailingStepPips * m_symbol.Point() * 10;
        
        // Adapt trailing distance to volatility
        if(UseVolatilityTrailing && atr_value > 0) {
            trailing_distance = atr_value * 0.5; // Use 50% of ATR
        }
        
        double current_price = m_position.PositionType() == POSITION_TYPE_BUY ? 
                              m_symbol.Bid() : m_symbol.Ask();
        double current_stop = m_position.StopLoss();
        double new_stop = 0;
        
        if(m_position.PositionType() == POSITION_TYPE_BUY) {
            new_stop = current_price - trailing_distance;
            if(new_stop > current_stop && new_stop < current_price) {
                if(m_trade.PositionModify(ticket, new_stop, m_position.TakeProfit())) {
                    Print("News Trader: Trailing stop updated for BUY ticket ", ticket, " to ", new_stop);
                }
            }
        } else {
            new_stop = current_price + trailing_distance;
            if(new_stop < current_stop && new_stop > current_price) {
                if(m_trade.PositionModify(ticket, new_stop, m_position.TakeProfit())) {
                    Print("News Trader: Trailing stop updated for SELL ticket ", ticket, " to ", new_stop);
                }
            }
        }
    }
    
    //+------------------------------------------------------------------+
    //| Get current ATR value                                            |
    //+------------------------------------------------------------------+
    double GetCurrentATR() {
        double atr[];
        ArraySetAsSeries(atr, true);
        
        if(CopyBuffer(m_atr_handle, 0, 0, 1, atr) > 0) {
            return atr[0];
        }
        
        return 0;
    }
    
    //+------------------------------------------------------------------+
    //| Helper functions                                                 |
    //+------------------------------------------------------------------+
    bool IsLocalHigh(const double &high[], int index, int range) {
        if(index < range || index >= ArraySize(high) - range) return false;
        
        for(int i = index - range; i <= index + range; i++) {
            if(i != index && high[i] >= high[index]) return false;
        }
        return true;
    }
    
    bool IsLocalLow(const double &low[], int index, int range) {
        if(index < range || index >= ArraySize(low) - range) return false;
        
        for(int i = index - range; i <= index + range; i++) {
            if(i != index && low[i] <= low[index]) return false;
        }
        return true;
    }
    
    bool ShouldProcessImpact(ENUM_CALENDAR_EVENT_IMPORTANCE importance) {
        switch(importance) {
            case CALENDAR_IMPORTANCE_LOW: return EnableLowImpact;
            case CALENDAR_IMPORTANCE_MODERATE: return EnableMediumImpact;
            case CALENDAR_IMPORTANCE_HIGH: return EnableHighImpact;
            default: return false;
        }
    }
    
    void SortNewsByTime() {
    for(int i = 0; i < m_news_count - 1; i++) {
        for(int j = 0; j < m_news_count - i - 1; j++) {
            if(m_news_events[j].time > m_news_events[j + 1].time) {
                // Use individual field swapping instead of struct assignment
                datetime temp_time = m_news_events[j].time;
                string temp_currency = m_news_events[j].currency;
                string temp_title = m_news_events[j].title;
                int temp_impact = m_news_events[j].impact;
                bool temp_processed = m_news_events[j].processed;
                bool temp_trades_placed = m_news_events[j].trades_placed;
                int temp_trades_count = m_news_events[j].trades_count;
                
                m_news_events[j].time = m_news_events[j + 1].time;
                m_news_events[j].currency = m_news_events[j + 1].currency;
                m_news_events[j].title = m_news_events[j + 1].title;
                m_news_events[j].impact = m_news_events[j + 1].impact;
                m_news_events[j].processed = m_news_events[j + 1].processed;
                m_news_events[j].trades_placed = m_news_events[j + 1].trades_placed;
                m_news_events[j].trades_count = m_news_events[j + 1].trades_count;
                
                m_news_events[j + 1].time = temp_time;
                m_news_events[j + 1].currency = temp_currency;
                m_news_events[j + 1].title = temp_title;
                m_news_events[j + 1].impact = temp_impact;
                m_news_events[j + 1].processed = temp_processed;
                m_news_events[j + 1].trades_placed = temp_trades_placed;
                m_news_events[j + 1].trades_count = temp_trades_count;
            }
        }
    }
}

   
    
    
    
    bool DoesSymbolContainCurrency(string currency) {
        string symbol = m_symbol.Name();
        return (StringFind(symbol, currency) >= 0);
    }
    
    int GetNewsPositionsCount() {
        int count = 0;
        for(int i = 0; i < PositionsTotal(); i++) {
            if(m_position.SelectByIndex(i) && 
               m_position.Magic() == m_trade.RequestMagic() &&
               StringFind(m_position.Comment(), "News_") >= 0) {
                count++;
            }
        }
        return count;
    }
    
    int GetPendingNewsOrdersCount() {
        int count = 0;
        for(int i = 0; i < OrdersTotal(); i++) {
            if(m_order.SelectByIndex(i) && 
               m_order.Magic() == m_trade.RequestMagic() &&
               StringFind(m_order.Comment(), "News_") >= 0) {
                count++;
            }
        }
        return count;
    }
    
    bool HasTradesForNews(datetime news_time) {
        for(int i = 0; i < m_news_trades_count; i++) {
            if(m_news_trades[i].news_time == news_time && m_news_trades[i].active) {
                return true;
            }
        }
        return false;
    }
    
    void CleanupNewsSetup(NewsTradeSetup &setup) {
        // Cancel any remaining pending orders
        if(setup.buy_ticket > 0 && m_order.Select(setup.buy_ticket)) {
            m_trade.OrderDelete(setup.buy_ticket);
        }
        if(setup.sell_ticket > 0 && m_order.Select(setup.sell_ticket)) {
            m_trade.OrderDelete(setup.sell_ticket);
        }
        
        setup.active = false;
    }
    
    void CleanupExpiredSetups() {
        datetime current_time = TimeCurrent();
        
        for(int i = 0; i < m_news_trades_count; i++) {
            if(m_news_trades[i].active && 
               current_time - m_news_trades[i].created_time > 2 * 3600) { // 2 hours
                CleanupNewsSetup(m_news_trades[i]);
            }
        }
    }
    
    void CheckDailyRiskReset() {
        MqlDateTime dt;
        TimeToStruct(TimeCurrent(), dt);
        
        MqlDateTime last_reset_dt;
        TimeToStruct(m_last_daily_reset, last_reset_dt);
        
        if(dt.day != last_reset_dt.day) {
            ResetDailyRiskTracking();
        }
    }
    
    void ResetDailyRiskTracking() {
        m_daily_news_risk_used = 0;
        m_last_daily_reset = TimeCurrent();
        Print("News Trader: Daily risk tracking reset");
    }
    
    void ResetDashboardData() {
        m_dashboard_data.is_active = EnableNewsTrading;
        m_dashboard_data.trading_halted = false;
        m_dashboard_data.next_news_currency = "";
        m_dashboard_data.next_news_title = "";
        m_dashboard_data.minutes_to_next_news = 0;
        m_dashboard_data.news_impact_level = 0;
        m_dashboard_data.daily_risk_used_pct = 0.0;
        m_dashboard_data.active_news_positions = 0;
        m_dashboard_data.pending_news_orders = 0;
        m_dashboard_data.trading_status = "Disabled";
    }
    
   //+------------------------------------------------------------------+
//| FIXED: Update dashboard data                                     |
//+------------------------------------------------------------------+
void UpdateDashboardData() {
    if(!EnableNewsTrading) {
        ResetDashboardData();
        return;
    }
    
    m_dashboard_data.is_active = true;
    m_dashboard_data.trading_halted = !IsTradingAllowed();
    m_dashboard_data.daily_risk_used_pct = m_daily_news_risk_used;
    m_dashboard_data.active_news_positions = GetNewsPositionsCount();
    m_dashboard_data.pending_news_orders = GetPendingNewsOrdersCount();
    
    // FIX 10: Reset values before searching
    m_dashboard_data.minutes_to_next_news = 9999;
    m_dashboard_data.next_news_currency = "";
    m_dashboard_data.next_news_title = "";
    m_dashboard_data.news_impact_level = 0;
    
    // Find next news event
    datetime current_time = TimeTradeServer(); // FIX 11: Use TimeTradeServer()
    
    for(int i = 0; i < m_news_count; i++) {
        if(m_news_events[i].time > current_time) {
            int minutes = (int)((m_news_events[i].time - current_time) / 60);
            if(minutes < m_dashboard_data.minutes_to_next_news) {
                m_dashboard_data.minutes_to_next_news = minutes;
                m_dashboard_data.next_news_currency = m_news_events[i].currency;
                m_dashboard_data.next_news_title = m_news_events[i].title;
                m_dashboard_data.news_impact_level = m_news_events[i].impact;
                break; // Take the first (earliest) upcoming event
            }
        }
    }
    
    // FIX 12: Better status determination
    if(m_dashboard_data.trading_halted) {
        m_dashboard_data.trading_status = "HALTED";
    } else if(m_dashboard_data.active_news_positions > 0) {
        m_dashboard_data.trading_status = "TRADING";
    } else if(m_dashboard_data.minutes_to_next_news < 9999) {
        m_dashboard_data.trading_status = "WAITING";
    } else {
        m_dashboard_data.trading_status = "NO NEWS";
    }
    
    Print("News Trader: Dashboard updated - Status: ", m_dashboard_data.trading_status, 
          ", Next: ", m_dashboard_data.next_news_currency);
}
    //+------------------------------------------------------------------+
    //| Drawing functions                                                |
    //+------------------------------------------------------------------+
   void DrawNewsVerticalLines() {
    ObjectsDeleteAll(0, "NewsLine_");
    
    for(int i = 0; i < m_news_count; i++) {
        datetime news_time = m_news_events[i].time;
        if(news_time < TimeCurrent()) continue;
        
        color line_color = GetImpactColor(m_news_events[i].impact);
        string obj_name = "NewsLine_" + IntegerToString((int)news_time);
        
        ObjectCreate(0, obj_name, OBJ_VLINE, 0, news_time, 0);
        ObjectSetInteger(0, obj_name, OBJPROP_COLOR, line_color);
        ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_DOT);
        ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 2);
        ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
        ObjectSetInteger(0, obj_name, OBJPROP_ZORDER, 1);  // ADD THIS LINE - Low priority
        
        string tooltip = StringFormat("%s\n%s - %s", 
                                    TimeToString(news_time), 
                                    m_news_events[i].currency,
                                    m_news_events[i].title);
        ObjectSetString(0, obj_name, OBJPROP_TOOLTIP, tooltip);
    }
}
    
void DrawSupportResistanceLevels() {
    ObjectsDeleteAll(0, "SR_");
    
    for(int i = 0; i < m_sr_count; i++) {
        string obj_name = "SR_" + IntegerToString(i);
        color line_color = m_sr_levels[i].is_support ? SupportColor : ResistanceColor;
        
        ObjectCreate(0, obj_name, OBJ_HLINE, 0, 0, m_sr_levels[i].price);
        ObjectSetInteger(0, obj_name, OBJPROP_COLOR, line_color);
        ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 2);
        ObjectSetInteger(0, obj_name, OBJPROP_ZORDER, 1);  // ADD THIS LINE - Low priority
        
        string tooltip = StringFormat("%s Level: %.5f\nTouches: %d\nStrength: %.2f", 
                                    m_sr_levels[i].is_support ? "Support" : "Resistance",
                                    m_sr_levels[i].price,
                                    m_sr_levels[i].touches,
                                    m_sr_levels[i].strength);
        ObjectSetString(0, obj_name, OBJPROP_TOOLTIP, tooltip);
    }
}
    
    color GetImpactColor(int impact) {
        switch(impact) {
            case 3: return HighImpactColor;
            case 2: return MediumImpactColor;
            case 1: return LowImpactColor;
            default: return clrGray;
        }
    }
    
public:
    //+------------------------------------------------------------------+
    //| Public interface functions                                       |
    //+------------------------------------------------------------------+
    bool IsTradingAllowed() {
        if(!EnableNewsFilter) return true;
        
        datetime current_time = TimeCurrent();
        
        for(int i = 0; i < m_news_count; i++) {
            datetime news_time = m_news_events[i].time;
            datetime start_halt = news_time - StopBeforeNewsMin * 60;
            datetime end_halt = news_time + StopAfterNewsMin * 60;
            
            if(current_time >= start_halt && current_time <= end_halt) {
                return false;
            }
        }
        
        return true;
    }
    //+------------------------------------------------------------------+
//| FIXED: Get next news info for dashboard                          |
//+------------------------------------------------------------------+
string GetNextNewsInfo() {
    if(m_news_count == 0) {
        Print("News Trader: No news events loaded");
        return "No upcoming news";
    }
    
    // FIX 9: Use TimeTradeServer() for consistency
    datetime current_time = TimeTradeServer();
    
    for(int i = 0; i < m_news_count; i++) {
        if(m_news_events[i].time > current_time) {
            int minutes_to_news = (int)((m_news_events[i].time - current_time) / 60);
            
            string result = StringFormat("%s %s in %d min", 
                                      m_news_events[i].currency,
                                      m_news_events[i].title,
                                      minutes_to_news);
            
            Print("News Trader: Next news - ", result);
            return result;
        }
    }
    
    Print("News Trader: No upcoming news found");
    return "No upcoming news today";
}
    
    string GetTradingStatus() {
        string status = "News Trading: ";
        
        if(!EnableNewsTrading) {
            return status + "DISABLED";
        }
        
        if(!IsTradingAllowed()) {
            return status + "HALTED - " + GetNextNewsInfo();
        }
        
        status += StringFormat("ACTIVE | Risk Used: %.1f%%/%.1f%% | Positions: %d/%d",
                             m_daily_news_risk_used, MaxDailyNewsRisk,
                             GetNewsPositionsCount(), MaxNewsPositions);
        
        return status;
    }
    
    NewsDataForDashboard GetDashboardData() const {
        return m_dashboard_data;
    }
    
    void Cleanup() {
    // Delete news lines
    ObjectsDeleteAll(0, "NewsLine_");
    
    // Delete S/R levels  
    ObjectsDeleteAll(0, "SR_");
    
    // Cancel any pending news orders
    for(int i = 0; i < m_news_trades_count; i++) {
        if(m_news_trades[i].buy_ticket > 0 && m_order.Select(m_news_trades[i].buy_ticket)) {
            m_trade.OrderDelete(m_news_trades[i].buy_ticket);
        }
        if(m_news_trades[i].sell_ticket > 0 && m_order.Select(m_news_trades[i].sell_ticket)) {
            m_trade.OrderDelete(m_news_trades[i].sell_ticket);
        }
    }
    
    // Release ATR handle
    if(m_atr_handle != INVALID_HANDLE) {
        IndicatorRelease(m_atr_handle);
        m_atr_handle = INVALID_HANDLE;
    }
    
    Print("News Trader: All objects and handles cleaned up");
}
};

// Global news trader instance
CAdvancedNewsTrader g_news_trader;