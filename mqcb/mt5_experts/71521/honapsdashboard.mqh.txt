//+------------------------------------------------------------------+
//|                         Hon-APS-Dashboard-COMPLETE-BEAUTIFUL.mqh |
//|                                    Copyright 2025,KSQUANTITATIVE |
//|                                                 WWW.ksquants.com |
//+------------------------------------------------------------------+

// --- Enhanced Data structure for beautiful dashboard ---
struct DashboardData
{
    // EA Status
    bool   is_trading_allowed;
    bool   is_paused;
    string symbol;
    bool   is_emergency_stop;
    double total_lots;
    
    // Account Information
    double balance;
    double equity;
    double free_margin;
    double margin_level;
    double floating_pl;
    double today_pl;
    double week_pl;

    // Market Analysis
    string market_regime;
    string kama_trend;
    int    spread_points;
    double volatility_level;
    int    active_patterns;
    string market_state;
    double trend_strength;

    // Performance Metrics
    double win_rate;
    double profit_factor;
    int    total_trades;
    double sharpe_ratio;
    double current_drawdown;
    double max_drawdown;
    double average_win;
    double average_loss;

    // Risk Management & Controls
    double daily_loss_pct;
    double max_daily_loss_pct;
    double weekly_loss_pct;
    double max_weekly_loss_pct;
    int    open_positions;
    int    max_positions;
    double adaptive_risk_pct;
    double risk_level;
    string risk_status;

    // News Trading Integration
    bool   news_trading_active;
    bool   news_trading_halted;
    string next_news_currency;
    string next_news_title;
    int    minutes_to_news;
    int    news_impact_level;
    double news_daily_risk_pct;
    int    news_positions;
    int    news_pending_orders;
    string news_status;
    MqlBookInfo dom_book[]; // DOM data
};

enum ENUM_DASHBOARD_ACTION
{
    DASH_ACTION_NONE = 0,
    DASH_ACTION_PAUSE_TOGGLE = 1,
    DASH_ACTION_CLOSE_ALL = 2,
    DASH_ACTION_EMERGENCY_STOP = 3,
    DASH_ACTION_RESET_RISK = 4,
    DASH_ACTION_SHOW_STATS = 5,
    DASH_ACTION_NEWS_TOGGLE = 6,
    DASH_ACTION_MINIMIZE = 7,
    DASH_ACTION_CLOSE_DASH = 8
};

//+------------------------------------------------------------------+
//| Beautiful Professional Dashboard Class                 |
//+------------------------------------------------------------------+
class BeautifulDashboard
{
private:
    string            m_prefix;
    long              m_chart_id;
    int               m_subwin;
    bool              m_visible;
    bool              m_objects_created;
    int               m_x_ofs;
    int               m_y_ofs;
    datetime          m_last_update;
    bool              m_is_minimized;
    int               m_update_interval;
    
    // Enhanced Modern Color Palette
    color             m_clr_bg_main;           // Main background
    color             m_clr_bg_secondary;      // Secondary panels
    color             m_clr_bg_header;         // Header background
    color             m_clr_accent_primary;    // Primary accent (blue)
    color             m_clr_accent_secondary;  // Secondary accent
    color             m_clr_success;           // Success/profit color
    color             m_clr_warning;           // Warning color
    color             m_clr_danger;            // Danger/loss color
    color             m_clr_info;              // Info color
    color             m_clr_text_primary;      // Primary text
    color             m_clr_text_secondary;    // Secondary text
    color             m_clr_text_muted;        // Muted text
    color             m_clr_border;            // Border color
    color             m_clr_shadow;            // Shadow color
    color             m_clr_gradient_start;    // Gradient start
    color             m_clr_gradient_end;      // Gradient end

    // Professional Icons (using safe ASCII)
    string            icon_trading, icon_pause, icon_stop, icon_chart;
    string            icon_account, icon_performance, icon_risk, icon_news;
    string            icon_settings, icon_minimize, icon_close, icon_refresh;
    string            icon_trend_up, icon_trend_down, icon_neutral;
    string            icon_warning, icon_success, icon_info, icon_emergency;

    void InitializeProfessionalTheme()
    {
        // Professional Dark Theme
        m_clr_bg_main = C'20,25,35';              // Deep dark blue
        m_clr_bg_secondary = C'30,35,45';         // Lighter dark blue
        m_clr_bg_header = C'40,50,65';            // Header blue-gray
        m_clr_accent_primary = C'0,150,255';      // Bright blue
        m_clr_accent_secondary = C'100,180,255';  // Light blue
        m_clr_success = C'40,200,80';             // Green
        m_clr_warning = C'255,165,0';             // Orange
        m_clr_danger = C'255,70,70';              // Red
        m_clr_info = C'70,180,255';               // Light blue
        m_clr_text_primary = C'245,245,250';      // Almost white
        m_clr_text_secondary = C'180,190,200';    // Light gray
        m_clr_text_muted = C'140,150,160';        // Muted gray
        m_clr_border = C'80,90,110';              // Border gray
        m_clr_shadow = C'10,15,25';               // Deep shadow
        m_clr_gradient_start = C'45,55,70';       // Gradient start
        m_clr_gradient_end = C'25,30,40';         // Gradient end
    }

    void InitializeProfessionalIcons()
    {
        // More compatible icons
        icon_trading = "▶";      // Trading
        icon_pause = "⏸";        // Pause
        icon_stop = "⏹";         // Stop
        icon_chart = "≡";        // Chart/Analysis
        icon_account = "💰";     // Account
        icon_performance = "↗";  // Performance
        icon_risk = "🛡";        // Risk/Shield
        icon_news = "ⓘ";         // News
        icon_settings = "⚙";     // Settings
        icon_minimize = "−";     // Minimize
        icon_close = "✕";        // Close
        icon_refresh = "↻";      // Refresh
        icon_trend_up = "↗";     // Up trend
        icon_trend_down = "↘";   // Down trend
        icon_neutral = "→";      // Neutral
        icon_warning = "⚠";      // Warning
        icon_success = "✓";      // Success
        icon_info = "ⓘ";         // Info
        icon_emergency = "⚠";    // Emergency
    }

    //+------------------------------------------------------------------+
    //| Separate and Sort DOM Data                               |
    //+------------------------------------------------------------------+
    void SeparateAndSortDOMData(const MqlBookInfo &dom_book[], MqlBookInfo &bids[], 
                               MqlBookInfo &asks[], double &max_volume)
    {
        ArrayResize(bids, 0);
        ArrayResize(asks, 0);
        max_volume = 0;
        
        // Separate bids and asks
        for(int i = 0; i < ArraySize(dom_book); i++) {
            if(dom_book[i].volume <= 0) continue;
            
            if(dom_book[i].volume > max_volume) max_volume = (double)dom_book[i].volume;
            
            if(dom_book[i].type == BOOK_TYPE_BUY || dom_book[i].type == BOOK_TYPE_BUY_MARKET) {
                int bid_size = ArraySize(bids);
                ArrayResize(bids, bid_size + 1);
                bids[bid_size] = dom_book[i];
            }
            else if(dom_book[i].type == BOOK_TYPE_SELL || dom_book[i].type == BOOK_TYPE_SELL_MARKET) {
                int ask_size = ArraySize(asks);
                ArrayResize(asks, ask_size + 1);
                asks[ask_size] = dom_book[i];
            }
        }
        
        // Sort bids (highest price first)
        for(int i = 0; i < ArraySize(bids) - 1; i++) {
            for(int j = 0; j < ArraySize(bids) - i - 1; j++) {
                if(bids[j].price < bids[j + 1].price) {
                    MqlBookInfo temp = bids[j];
                    bids[j] = bids[j + 1];
                    bids[j + 1] = temp;
                }
            }
        }
        
        // Sort asks (lowest price first)
        for(int i = 0; i < ArraySize(asks) - 1; i++) {
            for(int j = 0; j < ArraySize(asks) - i - 1; j++) {
                if(asks[j].price > asks[j + 1].price) {
                    MqlBookInfo temp = asks[j];
                    asks[j] = asks[j + 1];
                    asks[j + 1] = temp;
                }
            }
        }
    }

    //+------------------------------------------------------------------+
    //| FIXED: Format DOM Volume                                        |
    //+------------------------------------------------------------------+
    string FormatDOMVolume(double volume)
    {
        if(volume >= 10000000) return StringFormat("%.0fM", volume / 1000000);
        if(volume >= 1000000) return StringFormat("%.1fM", volume / 1000000);
        if(volume >= 10000) return StringFormat("%.0fK", volume / 1000);
        if(volume >= 1000) return StringFormat("%.1fK", volume / 1000);
        if(volume >= 100) return StringFormat("%.0f", volume);
        return StringFormat("%.1f", volume);
    }

    //+------------------------------------------------------------------+
    //| COMPLETE UpdateDOMSection - Enhanced DOM Display                |
    //+------------------------------------------------------------------+
  void UpdateDOMSection(const DashboardData &data)
{
    // Clear old DOM objects
    for(int i = 0; i < 5; i++) {
        ObjectDelete(m_chart_id, m_prefix + "dom_ask_price_" + IntegerToString(i));
        ObjectDelete(m_chart_id, m_prefix + "dom_ask_vol_" + IntegerToString(i));
        ObjectDelete(m_chart_id, m_prefix + "dom_bid_price_" + IntegerToString(i));
        ObjectDelete(m_chart_id, m_prefix + "dom_bid_vol_" + IntegerToString(i));
        ObjectDelete(m_chart_id, m_prefix + "dom_bar_" + IntegerToString(i));
    }
    ObjectDelete(m_chart_id, m_prefix + "dom_status");
    ObjectDelete(m_chart_id, m_prefix + "dom_spread");

    int book_size = ArraySize(data.dom_book);
    
    // Check if we have DOM data, if not show current prices
    if(book_size < 2) {
        // Show current bid/ask instead of "not available"
        double bid = SymbolInfoDouble(data.symbol, SYMBOL_BID);
        double ask = SymbolInfoDouble(data.symbol, SYMBOL_ASK);
        double spread = ask - bid;
        int spread_points = (int)(spread / SymbolInfoDouble(data.symbol, SYMBOL_POINT));
        
        if(bid > 0 && ask > 0) {
            // Display current market prices as fallback
            CreateLabelFixed("dom_bid_price_0", 345, 235, DoubleToString(bid, _Digits), m_clr_success, 8, "Consolas", ANCHOR_RIGHT);
            CreateLabelFixed("dom_ask_price_0", 385, 235, DoubleToString(ask, _Digits), m_clr_danger, 8, "Consolas");
            
            CreateLabelFixed("dom_spread", 387, 250, StringFormat("Spread: %d pts", spread_points), m_clr_warning, 7, "Consolas", ANCHOR_CENTER);
            CreateLabelFixed("dom_status", 387, 265, "Live Prices", m_clr_text_secondary, 7, "Segoe UI", ANCHOR_CENTER);
        } else {
            CreateLabelFixed("dom_status", 387, 245, "No Market Data", m_clr_warning, 9, "Segoe UI", ANCHOR_CENTER);
        }
        return;
    }

    // If we have DOM data, process it normally
    MqlBookInfo bids[], asks[];
    double max_volume = 0;
    SeparateAndSortDOMData(data.dom_book, bids, asks, max_volume);
    
    int bid_count = ArraySize(bids);
    int ask_count = ArraySize(asks);
    
    if(bid_count == 0 && ask_count == 0) {
        // Fallback to current prices if DOM parsing failed
        double bid = SymbolInfoDouble(data.symbol, SYMBOL_BID);
        double ask = SymbolInfoDouble(data.symbol, SYMBOL_ASK);
        
        CreateLabelFixed("dom_bid_price_0", 345, 235, DoubleToString(bid, _Digits), m_clr_success, 8, "Consolas", ANCHOR_RIGHT);
        CreateLabelFixed("dom_ask_price_0", 385, 235, DoubleToString(ask, _Digits), m_clr_danger, 8, "Consolas");
        CreateLabelFixed("dom_status", 387, 250, "Market Prices", m_clr_text_secondary, 7, "Segoe UI", ANCHOR_CENTER);
        return;
    }

    // DOM Display configuration (positioned for DOM card at x=265, y=185)
    int levels_to_show = MathMin(2, MathMax(bid_count, ask_count));
    int y_start = 235;
    int y_step = 12;
    
    // === DISPLAY ACTUAL DOM DATA ===
    for(int i = 0; i < levels_to_show; i++) {
        int y = y_start + (i * y_step);
        
        // BID SIDE (left side of DOM card)
        if(i < bid_count) {
            CreateLabelFixed("dom_bid_vol_" + IntegerToString(i), 295, y, 
                           FormatDOMVolume(bids[i].volume), m_clr_success, 7, "Consolas", ANCHOR_CENTER);
            CreateLabelFixed("dom_bid_price_" + IntegerToString(i), 345, y, 
                           DoubleToString(bids[i].price, _Digits), m_clr_success, 8, "Consolas", ANCHOR_RIGHT);
        }
        
        // ASK SIDE (right side of DOM card)
        int ask_index = ask_count - 1 - i;
        if(ask_index >= 0 && ask_index < ask_count) {
            CreateLabelFixed("dom_ask_price_" + IntegerToString(i), 385, y, 
                           DoubleToString(asks[ask_index].price, _Digits), m_clr_danger, 8, "Consolas");
            CreateLabelFixed("dom_ask_vol_" + IntegerToString(i), 455, y, 
                           FormatDOMVolume(asks[ask_index].volume), m_clr_danger, 7, "Consolas", ANCHOR_CENTER);
        }
    }

    // Status info (centered in DOM card)
    if(bid_count > 0 && ask_count > 0) {
        double spread = asks[ask_count-1].price - bids[0].price;
        CreateLabelFixed("dom_spread", 387, y_start + (levels_to_show * y_step) + 5, 
                        StringFormat("Spread: %.1f", spread / SymbolInfoDouble(data.symbol, SYMBOL_POINT)), 
                        m_clr_warning, 7, "Consolas", ANCHOR_CENTER);
    }
    
    CreateLabelFixed("dom_status", 387, y_start + (levels_to_show * y_step) + 18, 
                    StringFormat("%dB/%dA", bid_count, ask_count), 
                    m_clr_text_secondary, 7, "Segoe UI", ANCHOR_CENTER);
}

    // Enhanced UI Components
    void CreateGradientPanel(const string name, const int x, const int y, const int w, const int h, 
                           const color start_color, const color end_color, const bool shadow=true)
    {
        if(shadow) {
            CreateRectangleFixed(name + "_shadow", x+3, y+3, w, h, m_clr_shadow);
        }
        
        // Main panel
        CreateRectangleFixed(name + "_bg", x, y, w, h, start_color);
        
        // Gradient effect simulation
        for(int i = 0; i < 5; i++) {
            double ratio = (double)i / 4.0;
            color blend_color = BlendColors(start_color, end_color, ratio);
            CreateRectangleFixed(name + "_grad_" + IntegerToString(i), 
                               x, y + (int)(h * ratio / 5), w, (int)(h / 5), blend_color);
        }
        
        // Border
        CreateRectangleFixed(name + "_border", x, y, w, h, clrNONE, BORDER_RAISED);
    }

    color BlendColors(color color1, color color2, double ratio)
    {
        int r1 = (color1 >> 16) & 0xFF;
        int g1 = (color1 >> 8) & 0xFF;
        int b1 = color1 & 0xFF;
        
        int r2 = (color2 >> 16) & 0xFF;
        int g2 = (color2 >> 8) & 0xFF;
        int b2 = color2 & 0xFF;
        
        int r = (int)(r1 + (r2 - r1) * ratio);
        int g = (int)(g1 + (g2 - g1) * ratio);
        int b = (int)(b1 + (b2 - b1) * ratio);
        
        return (color)((r << 16) | (g << 8) | b);
    }

    void CreateStatusIndicator(const string name, const int x, const int y, const bool is_active, 
                             const string text, const color active_color, const color inactive_color)
    {
        color status_color = is_active ? active_color : inactive_color;
        string status_icon = is_active ? icon_success : icon_warning;
        
        // Status circle background
        CreateRectangleFixed(name + "_circle", x, y, 16, 16, status_color);
        
        // BETTER CENTERED ICON - using center anchor
        CreateLabelFixed(name + "_icon", x+8, y+8, status_icon, C'255,255,255', 10, "Segoe UI", ANCHOR_CENTER);
        
        // Status text
        CreateLabelFixed(name + "_text", x+22, y+2, text, status_color, 9, "Segoe UI");
    }

    void CreateProgressBar(const string name, const int x, const int y, const int w, const int h, 
                          const double percentage, const color bar_color, const string label="")
    {
        double p = MathMax(0, MathMin(100, percentage));
        int value_width = (int)(w * (p / 100.0));
        
        // Background track
        CreateRectangleFixed(name + "_track", x, y, w, h, C'40,45,55');
        
        // Progress fill
        if(value_width > 2) {
            CreateRectangleFixed(name + "_fill", x+1, y+1, value_width-2, h-2, bar_color);
        }
        
        // Highlight effect
        if(value_width > 4) {
            CreateRectangleFixed(name + "_highlight", x+2, y+2, value_width-4, 2, 
                               BlendColors(bar_color, C'255,255,255', 0.3));
        }
        
        // Border
        CreateRectangleFixed(name + "_border", x, y, w, h, m_clr_border, BORDER_SUNKEN);
        
        // Percentage text
        if(label != "") {
            CreateLabelFixed(name + "_label", x + w + 8, y + 2, 
                           StringFormat("%s %.1f%%", label, p), m_clr_text_secondary, 8);
        }
    }

    void CreateMetricDisplay(const string name, const int x, const int y, const string label, 
                           const string value, const color value_color, const string unit="")
    {
        // Label
        CreateLabelFixed(name + "_label", x, y, label + ":", m_clr_text_secondary, 8);
        
        // Value with unit
        string display_value = value + (unit != "" ? " " + unit : "");
        CreateLabelFixed(name + "_value", x + 120, y, display_value, value_color, 9, "Consolas");
    }

    void CreateModernCard(const string name, const int x, const int y, const int w, const int h, 
                         const string title, const string icon, const color accent_color)
    {
        // Card background with shadow
        CreateRectangleFixed(name + "_shadow", x+2, y+2, w, h, m_clr_shadow);
        CreateRectangleFixed(name + "_bg", x, y, w, h, m_clr_bg_secondary);
        
        // Header bar
        CreateRectangleFixed(name + "_header", x, y, w, 25, accent_color);
        
        // Better centered title with icon - IMPROVED POSITIONING
        CreateLabelFixed(name + "_title", x+w/2, y+12, icon + " " + title, m_clr_text_primary, 9, "Segoe UI", ANCHOR_CENTER);
        
        // Border
        CreateRectangleFixed(name + "_border", x, y, w, h, clrNONE, BORDER_FLAT);
    }

    //+------------------------------------------------------------------+
    //| CreateActionButton                                               |
    //+------------------------------------------------------------------+
    void CreateActionButton(const string name, const int x, const int y, const int w, const int h, 
                            const string text, const string icon, const color bg_color, 
                            const color text_color = clrNONE)
    {
        color button_text_color = (text_color == clrNONE) ? m_clr_text_primary : text_color;
        
        string obj_name = m_prefix + name;
        if(ObjectFind(m_chart_id, obj_name) == -1)
        {
            ObjectCreate(m_chart_id, obj_name, OBJ_BUTTON, m_subwin, 0, 0);
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_BORDER_COLOR, m_clr_border);
            ObjectSetString(m_chart_id, obj_name, OBJPROP_FONT, "Segoe UI");
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_FONTSIZE, 8);
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_STATE, false);
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_ZORDER, 120);
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_ALIGN, ALIGN_CENTER); // This helps center text
        }
        
        // Update properties
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_XDISTANCE, m_x_ofs + x);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_YDISTANCE, m_y_ofs + y);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_XSIZE, w);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_YSIZE, h);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_BGCOLOR, bg_color);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_COLOR, button_text_color);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_HIDDEN, !m_visible);
        
        // Better text formatting with consistent spacing
        string button_text = "";
        if(icon != "" && text != "") {
            button_text = icon + " " + text;
        } else if(icon != "") {
            button_text = icon;
        } else {
            button_text = text;
        }
        
        ObjectSetString(m_chart_id, obj_name, OBJPROP_TEXT, button_text);
    }

    //+------------------------------------------------------------------+
    //| CreateRectangleFixed                                             |
    //+------------------------------------------------------------------+
    bool CreateRectangleFixed(const string name, const int x, const int y, const int w, const int h, 
                              const color clr, const ENUM_BORDER_TYPE border=BORDER_FLAT)
    {
        string obj_name = m_prefix + name;
        
        if(ObjectFind(m_chart_id, obj_name) == -1)
        {
            if(!ObjectCreate(m_chart_id, obj_name, OBJ_RECTANGLE_LABEL, m_subwin, 0, 0))
            {
                return false;
            }
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_BACK, false);
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_BORDER_TYPE, border);
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_ZORDER, 100);   // KEEP ONLY THIS ONE
        }
        
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_XDISTANCE, m_x_ofs + x);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_YDISTANCE, m_y_ofs + y);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_XSIZE, w);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_YSIZE, h);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_BGCOLOR, clr);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_COLOR, m_clr_border);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_HIDDEN, !m_visible);
        
        return true;
    }

    //+------------------------------------------------------------------+
    //| CreateLabelFixed                                                 |
    //+------------------------------------------------------------------+
    bool CreateLabelFixed(const string name, const int x, const int y, const string text, 
                          const color clr, const int font_size=9, const string font="Segoe UI", 
                          const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT)
    {
        string obj_name = m_prefix + name;
        
        if(ObjectFind(m_chart_id, obj_name) == -1)
        {
            if(!ObjectCreate(m_chart_id, obj_name, OBJ_LABEL, m_subwin, 0, 0))
            {
                return false;
            }
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
            ObjectSetString(m_chart_id, obj_name, OBJPROP_FONT, font);
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_BACK, false);
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_ANCHOR, anchor);
            ObjectSetInteger(m_chart_id, obj_name, OBJPROP_ZORDER, 110);   // KEEP ONLY THIS ONE
        }
        
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_XDISTANCE, m_x_ofs + x);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_YDISTANCE, m_y_ofs + y);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_FONTSIZE, font_size);
        ObjectSetString(m_chart_id, obj_name, OBJPROP_TEXT, text);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_COLOR, clr);
        ObjectSetInteger(m_chart_id, obj_name, OBJPROP_HIDDEN, !m_visible);
        
        return true;
    }

    // Color helper functions
    color GetTrendColor(string trend) {
        if(trend == "BULLISH" || trend == "TRENDING_UP") return m_clr_success;
        if(trend == "BEARISH" || trend == "TRENDING_DOWN") return m_clr_danger;
        return m_clr_warning;
    }

    color GetPerformanceColor(double value, double good_threshold, double poor_threshold) {
        if(value >= good_threshold) return m_clr_success;
        if(value <= poor_threshold) return m_clr_danger;
        return m_clr_warning;
    }

    color GetRiskColor(double current, double max_value) {
        double percentage = (current / max_value) * 100;
        if(percentage >= 80) return m_clr_danger;
        if(percentage >= 60) return m_clr_warning;
        return m_clr_success;
    }

    string FormatNumber(double value, int decimals = 2) {
        if(MathAbs(value) >= 1000000) {
            return StringFormat("%.1fM", value / 1000000);
        } else if(MathAbs(value) >= 1000) {
            return StringFormat("%.1fK", value / 1000);
        } else {
            return StringFormat("%.*f", decimals, value);
        }
    }

public:
    bool Init(long expert_magic, int x_offset=15, int y_offset=15)
    {
        m_chart_id = ChartID();
        m_prefix = "beautiful_aps_" + IntegerToString(expert_magic) + "_";
        m_subwin = 0;
        m_visible = true;
        m_objects_created = false;
        m_x_ofs = x_offset;
        m_y_ofs = y_offset;
        m_last_update = 0;
        m_is_minimized = false;
        m_update_interval = 3; // Update every 3 seconds

        InitializeProfessionalTheme();
        InitializeProfessionalIcons();
        
        Deinit(); // Clean state
        
        return CreateBeautifulLayout();
    }

   bool CreateBeautifulLayout()
{
    if(m_objects_created) return true;
    
    // Main dashboard container (properly sized)
    CreateGradientPanel("main_panel", 0, 0, 760, 430, m_clr_bg_main, m_clr_bg_secondary, true);
    
    // Header section
    CreateRectangleFixed("header_bg", 5, 5, 750, 40, m_clr_bg_header);
    CreateLabelFixed("main_title", 15, 14, icon_chart + " Hon-APS Automated Pattern System", 
                    m_clr_accent_primary, 14, "Segoe UI");
    CreateLabelFixed("version", 15, 30, "Professional Edition v1.3.0", m_clr_text_secondary, 8);
    
    // System status indicator
    CreateStatusIndicator("system_status", 650, 15, true, "ONLINE", m_clr_success, m_clr_danger);
    
    // Window controls
    CreateActionButton("btn_minimize", 680, 10, 25, 25, "", icon_minimize, m_clr_info);
    CreateActionButton("btn_close", 710, 10, 25, 25, "", icon_close, m_clr_danger);

    // === ROW 1: ACCOUNT, TRADING, NEWS (Proper spacing) ===
    CreateModernCard("account_card", 10, 55, 245, 120, "Account Information", icon_account, m_clr_success);
    CreateModernCard("trading_card", 265, 55, 245, 120, "Trading Status", icon_trading, m_clr_accent_primary);
    CreateModernCard("news_card", 520, 55, 230, 120, "News Trading", icon_news, m_clr_warning);
    
    // Account metrics (proper internal spacing)
    CreateLabelFixed("acc_balance_lbl", 20, 85, "Balance:", m_clr_text_secondary, 8);
    CreateLabelFixed("acc_equity_lbl", 20, 100, "Equity:", m_clr_text_secondary, 8);
    CreateLabelFixed("acc_margin_lbl", 20, 115, "Free Margin:", m_clr_text_secondary, 8);
    CreateLabelFixed("acc_level_lbl", 20, 130, "Margin Level:", m_clr_text_secondary, 8);
    CreateLabelFixed("acc_floating_lbl", 20, 145, "Floating P&L:", m_clr_text_secondary, 8);
    CreateLabelFixed("acc_today_lbl", 20, 160, "Today P&L:", m_clr_text_secondary, 8);

    // Trading metrics (complete set with proper positioning)
    CreateLabelFixed("trading_active_lbl", 275, 85, "Active Positions:", m_clr_text_secondary, 8);
    CreateLabelFixed("trading_total_lbl", 275, 100, "Total Lots:", m_clr_text_secondary, 8);
    CreateLabelFixed("trading_symbol_lbl", 275, 115, "Symbol:", m_clr_text_secondary, 8);
    CreateLabelFixed("trading_regime_lbl", 275, 130, "Market Regime:", m_clr_text_secondary, 8);
    CreateLabelFixed("trading_kama_lbl", 275, 145, "KAMA Trend:", m_clr_text_secondary, 8);
    CreateLabelFixed("trading_patterns_lbl", 275, 160, "Active Patterns:", m_clr_text_secondary, 8);

    // News metrics (complete set)
    CreateLabelFixed("news_status_lbl", 530, 85, "Status:", m_clr_text_secondary, 8);
    CreateLabelFixed("news_next_lbl", 530, 100, "Next Event:", m_clr_text_secondary, 8);
    CreateLabelFixed("news_time_lbl", 530, 115, "Time:", m_clr_text_secondary, 8);
    CreateLabelFixed("news_impact_lbl", 530, 130, "Impact:", m_clr_text_secondary, 8);
    CreateLabelFixed("news_positions_lbl", 530, 145, "Positions:", m_clr_text_secondary, 8);
    CreateLabelFixed("news_risk_lbl", 530, 160, "Daily Risk:", m_clr_text_secondary, 8);

    // === ROW 2: MARKET ANALYSIS, DOM, PERFORMANCE (Better spacing) ===
    CreateModernCard("market_card", 10, 185, 245, 85, "Market Analysis", icon_performance, m_clr_warning);
    CreateModernCard("dom_card", 265, 185, 245, 85, "Depth of Market", icon_chart, m_clr_info);
    CreateModernCard("perf_card", 520, 185, 230, 85, "Performance", icon_performance, m_clr_success);
    
    // Market analysis labels
    CreateLabelFixed("market_vol_lbl", 20, 215, "Volatility:", m_clr_text_secondary, 8);
    CreateLabelFixed("market_trend_lbl", 20, 230, "Trend Strength:", m_clr_text_secondary, 8);
    CreateLabelFixed("market_state_lbl", 20, 245, "Market State:", m_clr_text_secondary, 8);
    CreateLabelFixed("market_session_lbl", 20, 260, "Session:", m_clr_text_secondary, 8);

    // DOM Headers (centered in DOM card)
    CreateLabelFixed("dom_header_vol", 285, 215, "VOLUME", m_clr_text_muted, 7, "Consolas", ANCHOR_CENTER);
    CreateLabelFixed("dom_header_price", 365, 215, "PRICE", m_clr_text_primary, 8, "Consolas", ANCHOR_CENTER);
    CreateLabelFixed("dom_header_vol2", 445, 215, "VOLUME", m_clr_text_muted, 7, "Consolas", ANCHOR_CENTER);
    
    // DOM Separator line
    CreateRectangleFixed("dom_separator", 275, 225, 225, 1, m_clr_border);

    // Performance labels  
    CreateLabelFixed("perf_trades_lbl", 530, 215, "Total Trades:", m_clr_text_secondary, 8);
    CreateLabelFixed("perf_winrate_lbl", 530, 230, "Win Rate:", m_clr_text_secondary, 8);
    CreateLabelFixed("perf_pf_lbl", 530, 245, "Profit Factor:", m_clr_text_secondary, 8);
    CreateLabelFixed("perf_sharpe_lbl", 530, 260, "Sharpe Ratio:", m_clr_text_secondary, 8);

    // === ROW 3: RISK CONTROLS (Full width with proper spacing) ===
    CreateModernCard("risk_card", 10, 280, 740, 65, "Risk & Controls", icon_risk, m_clr_danger);
    
    // Risk control labels (organized in columns)
    CreateLabelFixed("risk_adaptive_lbl", 20, 310, "Adaptive Risk:", m_clr_text_secondary, 8);
    CreateLabelFixed("risk_drawdown_lbl", 20, 325, "Drawdown:", m_clr_text_secondary, 8);
    
    CreateLabelFixed("risk_daily_lbl", 200, 310, "Daily Loss:", m_clr_text_secondary, 8);
    CreateLabelFixed("risk_weekly_lbl", 200, 325, "Weekly Loss:", m_clr_text_secondary, 8);
    
    CreateLabelFixed("risk_volatility_lbl", 400, 310, "Volatility:", m_clr_text_secondary, 8);
    CreateLabelFixed("risk_trend_lbl", 400, 325, "Trend Strength:", m_clr_text_secondary, 8);
    
    CreateLabelFixed("risk_spread_lbl", 580, 310, "Spread:", m_clr_text_secondary, 8);
    CreateLabelFixed("risk_margin_lbl", 580, 325, "Margin Level:", m_clr_text_secondary, 8);

    // === CONTROL BUTTONS (Bottom row with proper spacing) ===
    CreateActionButton("btn_pause", 20, 355, 85, 30, "PAUSE", icon_pause, m_clr_warning);
    CreateActionButton("btn_close_all", 115, 355, 85, 30, "CLOSE ALL", icon_stop, m_clr_danger);
    CreateActionButton("btn_emergency", 210, 355, 85, 30, "EMERGENCY", icon_emergency, m_clr_danger);
    CreateActionButton("btn_reset_risk", 305, 355, 85, 30, "RESET", icon_refresh, m_clr_success);
    CreateActionButton("btn_stats", 400, 355, 85, 30, "STATISTICS", icon_settings, m_clr_info);
    CreateActionButton("btn_news_toggle", 495, 355, 85, 30, "NEWS", icon_news, m_clr_warning);
    CreateActionButton("btn_optimize", 590, 355, 85, 30, "OPTIMIZE", icon_settings, m_clr_accent_primary);

    // Footer
    CreateLabelFixed("footer_shortcuts", 20, 395, 
                    "Shortcuts: [P]ause [C]lose All [E]mergency [R]eset [S]tats [N]ews [O]ptimize", 
                    m_clr_text_muted, 7);

    m_objects_created = true;
    ChartRedraw();
    return true;
}
    //+------------------------------------------------------------------+
    //| SEPARATE UpdateMarketSection - for Market Analysis only         |
    //+------------------------------------------------------------------+
  void UpdateMarketSection(const DashboardData &data)
{
    // Market analysis values (aligned with their labels at Y: 215, 230, 245, 260)
    color vol_color = GetPerformanceColor(data.volatility_level, 1.5, 0.5);
    CreateLabelFixed("market_vol_val", 130, 215, StringFormat("%.2f", data.volatility_level), vol_color, 9);
    
    color strength_color = GetPerformanceColor(data.trend_strength, 30, 20);
    CreateLabelFixed("market_trend_val", 130, 230, StringFormat("%.1f", data.trend_strength), strength_color, 9);
    
    CreateLabelFixed("market_state_val", 130, 245, data.market_state, m_clr_accent_primary, 9);
    
    // Session info
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    string session = GetTradingSession(dt.hour);
    CreateLabelFixed("market_session_val", 130, 260, session, m_clr_text_primary, 9);
}
   void Update(const DashboardData &data)
    {
        if(!m_visible || m_is_minimized || !m_objects_created) return;

        datetime current_time = TimeCurrent();
        if(current_time - m_last_update < m_update_interval) return;
        m_last_update = current_time;

        UpdateSystemStatus(data);
        UpdateAccountSection(data);
        UpdateTradingSection(data);
        UpdateNewsSection(data);
        
        // UPDATE BOTH SECTIONS SEPARATELY
        UpdateMarketSection(data);    // ← Market Analysis Section
        UpdateDOMSection(data);       // ← Depth of Market Section
        
        UpdatePerformanceSection(data);
        UpdateRiskSection(data);
        UpdateControlButtons(data);

        ChartRedraw();
    }

private:
    void UpdateSystemStatus(const DashboardData &data)
    {
        // System status indicator
        bool system_ok = data.is_trading_allowed && !data.is_emergency_stop;
        CreateStatusIndicator("system_status", 650, 15, system_ok, 
                            system_ok ? "ONLINE" : "HALTED", m_clr_success, m_clr_danger);
    }

  void UpdateAccountSection(const DashboardData &data)
{
    // Account values (aligned with labels at Y: 85, 100, 115, 130, 145, 160)
    CreateLabelFixed("acc_balance_val", 140, 85, FormatNumber(data.balance), m_clr_text_primary, 9, "Consolas");
    
    color equity_color = (data.equity >= data.balance) ? m_clr_success : m_clr_warning;
    CreateLabelFixed("acc_equity_val", 140, 100, FormatNumber(data.equity), equity_color, 9, "Consolas");
    
    CreateLabelFixed("acc_margin_val", 140, 115, FormatNumber(data.free_margin), m_clr_text_primary, 9, "Consolas");
    
    color level_color = GetPerformanceColor(data.margin_level, 200, 100);
    CreateLabelFixed("acc_level_val", 140, 130, StringFormat("%.0f%%", data.margin_level), level_color, 9, "Consolas");
    
    color floating_color = (data.floating_pl >= 0) ? m_clr_success : m_clr_danger;
    CreateLabelFixed("acc_floating_val", 140, 145, StringFormat("%+.2f", data.floating_pl), floating_color, 9, "Consolas");
    
    color today_color = (data.today_pl >= 0) ? m_clr_success : m_clr_danger;
    CreateLabelFixed("acc_today_val", 140, 160, StringFormat("%+.2f", data.today_pl), today_color, 9, "Consolas");
}

   void UpdateTradingSection(const DashboardData &data)
{
    // Trading values (aligned with labels at Y: 85, 100, 115, 130, 145, 160)
    CreateLabelFixed("trading_active_val", 420, 85, StringFormat("%d/%d", data.open_positions, data.max_positions), m_clr_text_primary, 9);
    CreateLabelFixed("trading_total_val", 420, 100, StringFormat("%.2f", data.total_lots), m_clr_text_primary, 9, "Consolas");
    CreateLabelFixed("trading_symbol_val", 420, 115, data.symbol, m_clr_accent_primary, 9);
    
    color regime_color = GetTrendColor(data.market_regime);
    CreateLabelFixed("trading_regime_val", 420, 130, data.market_regime, regime_color, 9);
    
    color kama_color = GetTrendColor(data.kama_trend);
    string kama_icon = (data.kama_trend == "BULLISH") ? icon_trend_up : 
                      (data.kama_trend == "BEARISH") ? icon_trend_down : icon_neutral;
    CreateLabelFixed("trading_kama_val", 420, 145, kama_icon + " " + data.kama_trend, kama_color, 9);
    
    color patterns_color = (data.active_patterns > 0) ? m_clr_info : m_clr_text_secondary;
    CreateLabelFixed("trading_patterns_val", 420, 160, IntegerToString(data.active_patterns), patterns_color, 9);
}

    
   void UpdateNewsSection(const DashboardData &data)
{
    if(data.news_trading_active) {
        // News status (aligned with labels at Y: 85, 100, 115, 130, 145, 160)
        color status_color = data.news_trading_halted ? m_clr_danger : m_clr_success;
        CreateLabelFixed("news_status_val", 650, 85, data.news_status, status_color, 9);
        
        // Next news event
        if(data.minutes_to_news < 9999) {
            CreateLabelFixed("news_next_val", 650, 100, data.next_news_currency, 
                           GetCurrencyColor(data.next_news_currency), 9);
            
            color time_color = (data.minutes_to_news <= 15) ? m_clr_danger :
                              (data.minutes_to_news <= 60) ? m_clr_warning : m_clr_info;
            CreateLabelFixed("news_time_val", 650, 115, StringFormat("%dm", data.minutes_to_news), time_color, 9);
            
            // Impact indicator
            CreateLabelFixed("news_impact_val", 650, 130, GetImpactText(data.news_impact_level), 
                           GetImpactColor(data.news_impact_level), 9);
        } else {
            CreateLabelFixed("news_next_val", 650, 100, "None", m_clr_text_secondary, 9);
            CreateLabelFixed("news_time_val", 650, 115, "--", m_clr_text_secondary, 9);
            CreateLabelFixed("news_impact_val", 650, 130, "--", m_clr_text_secondary, 9);
        }
        
        CreateLabelFixed("news_positions_val", 650, 145, 
                       StringFormat("%d/%d", data.news_positions, 3), m_clr_text_primary, 9);
        
        color risk_color = GetRiskColor(data.news_daily_risk_pct, 6.0);
        CreateLabelFixed("news_risk_val", 650, 160, 
                       StringFormat("%.1f%%", data.news_daily_risk_pct), risk_color, 9);
    } else {
        CreateLabelFixed("news_status_val", 650, 85, "DISABLED", m_clr_text_secondary, 9);
        CreateLabelFixed("news_next_val", 650, 100, "--", m_clr_text_secondary, 9);
        CreateLabelFixed("news_time_val", 650, 115, "--", m_clr_text_secondary, 9);
        CreateLabelFixed("news_impact_val", 650, 130, "--", m_clr_text_secondary, 9);
        CreateLabelFixed("news_positions_val", 650, 145, "--", m_clr_text_secondary, 9);
        CreateLabelFixed("news_risk_val", 650, 160, "--", m_clr_text_secondary, 9);
    }
}
    void UpdatePerformanceSection(const DashboardData &data)
{
    // Performance metrics (aligned with labels at Y: 215, 230, 245, 260)
    CreateLabelFixed("perf_trades_val", 650, 215, IntegerToString(data.total_trades), m_clr_text_primary, 9);
    
    color wr_color = GetPerformanceColor(data.win_rate, 0.6, 0.4);
    CreateLabelFixed("perf_winrate_val", 650, 230, StringFormat("%.1f%%", data.win_rate * 100), wr_color, 9);
    
    color pf_color = GetPerformanceColor(data.profit_factor, 1.5, 1.0);
    CreateLabelFixed("perf_pf_val", 650, 245, StringFormat("%.2f", data.profit_factor), pf_color, 9);
    
    color sr_color = GetPerformanceColor(data.sharpe_ratio, 1.0, 0.5);
    CreateLabelFixed("perf_sharpe_val", 650, 260, StringFormat("%.2f", data.sharpe_ratio), sr_color, 9);
}

    //+------------------------------------------------------------------+
    //| Updated UpdateRiskSection for full-width layout                 |
    //+------------------------------------------------------------------+
    void UpdateRiskSection(const DashboardData &data)
    {
        // Left column
        CreateLabelFixed("risk_adaptive_val", 130, 305, StringFormat("%.2f%%", data.adaptive_risk_pct), m_clr_info, 9);
        color dd_color = GetPerformanceColor(-data.current_drawdown, -5, -15);
        CreateLabelFixed("risk_drawdown_val", 130, 320, StringFormat("%.2f%%", data.current_drawdown), dd_color, 9);
        
        // Middle column
        double daily_pct = (data.max_daily_loss_pct > 0) ? (data.daily_loss_pct / data.max_daily_loss_pct) * 100 : 0;
        CreateLabelFixed("risk_daily_val", 310, 305, StringFormat("%.2f%%", data.daily_loss_pct), GetRiskColor(data.daily_loss_pct, data.max_daily_loss_pct), 9);
        
        double weekly_pct = (data.max_weekly_loss_pct > 0) ? (data.weekly_loss_pct / data.max_weekly_loss_pct) * 100 : 0;
        CreateLabelFixed("risk_weekly_val", 310, 320, StringFormat("%.2f%%", data.weekly_loss_pct), GetRiskColor(data.weekly_loss_pct, data.max_weekly_loss_pct), 9);
        
        // Right column
        color vol_color = GetPerformanceColor(data.volatility_level, 1.5, 0.5);
        CreateLabelFixed("risk_volatility_val", 510, 305, StringFormat("%.2f", data.volatility_level), vol_color, 9);
        
        color strength_color = GetPerformanceColor(data.trend_strength, 30, 20);
        CreateLabelFixed("risk_trend_val", 510, 320, StringFormat("%.1f", data.trend_strength), strength_color, 9);
        
        // Far right column
        CreateLabelFixed("risk_spread_val", 650, 305, StringFormat("%d pts", data.spread_points), m_clr_text_primary, 9);
        CreateLabelFixed("risk_margin_val", 650, 320, StringFormat("%.0f%%", data.margin_level), GetPerformanceColor(data.margin_level, 200, 100), 9);
        // Add visual risk bars
    double daily_risk_pct = (data.max_daily_loss_pct > 0) ? (data.daily_loss_pct / data.max_daily_loss_pct) * 100 : 0;
    CreateProgressBar("daily_risk_bar", 200, 335, 100, 8, daily_risk_pct, 
                     GetRiskColor(data.daily_loss_pct, data.max_daily_loss_pct));
    
    double weekly_risk_pct = (data.max_weekly_loss_pct > 0) ? (data.weekly_loss_pct / data.max_weekly_loss_pct) * 100 : 0;
    CreateProgressBar("weekly_risk_bar", 400, 335, 100, 8, weekly_risk_pct, 
                     GetRiskColor(data.weekly_loss_pct, data.max_weekly_loss_pct));
   
    }

    //+------------------------------------------------------------------+
    //| Helper function for trading session                             |
    //+------------------------------------------------------------------+
    string GetTradingSession(int hour)
    {
        if(hour >= 0 && hour < 9) return "ASIAN";
        if(hour >= 8 && hour < 17) return "LONDON";
        if(hour >= 13 && hour < 22) return "NY";
        return "OFF-HOURS";
    }

    void UpdateControlButtons(const DashboardData &data)
    {
        // Update pause button
        string pause_text = data.is_paused ? "RESUME" : "PAUSE";
        string pause_icon = data.is_paused ? icon_trading : icon_pause;
        color pause_color = data.is_paused ? m_clr_success : m_clr_warning;
        
        ObjectSetString(m_chart_id, m_prefix+"btn_pause", OBJPROP_TEXT, pause_icon + " " + pause_text);
        ObjectSetInteger(m_chart_id, m_prefix+"btn_pause", OBJPROP_BGCOLOR, pause_color);
        
        // Emergency button highlighting
        if(data.is_emergency_stop) {
            ObjectSetInteger(m_chart_id, m_prefix+"btn_emergency", OBJPROP_BGCOLOR, m_clr_danger);
        }
    }

    // Helper functions
    color GetCurrencyColor(string currency)
    {
        if(currency == "USD") return C'0,150,255';
        if(currency == "EUR") return C'255,215,0';
        if(currency == "GBP") return C'220,20,60';
        if(currency == "JPY") return C'255,69,0';
        if(currency == "CAD") return C'255,0,255';
        if(currency == "AUD") return C'0,255,127';
        if(currency == "NZD") return C'64,224,208';
        if(currency == "CHF") return C'255,165,0';
        return m_clr_text_primary;
    }

    string GetImpactText(int impact)
    {
        switch(impact) {
            case 3: return "HIGH";
            case 2: return "MEDIUM";
            case 1: return "LOW";
            default: return "--";
        }
    }

    color GetImpactColor(int impact)
    {
        switch(impact) {
            case 3: return m_clr_danger;
            case 2: return m_clr_warning;
            case 1: return m_clr_success;
            default: return m_clr_text_secondary;
        }
    }

public:
    ENUM_DASHBOARD_ACTION EventAction(const string &object_name)
    {
        if(StringFind(object_name, m_prefix) == -1) return DASH_ACTION_NONE;
        string clean_name = StringSubstr(object_name, StringLen(m_prefix));
        
        if(clean_name == "btn_pause") return DASH_ACTION_PAUSE_TOGGLE;
        if(clean_name == "btn_close_all") return DASH_ACTION_CLOSE_ALL;
        if(clean_name == "btn_emergency") return DASH_ACTION_EMERGENCY_STOP;
        if(clean_name == "btn_reset_risk") return DASH_ACTION_RESET_RISK;
        if(clean_name == "btn_stats") return DASH_ACTION_SHOW_STATS;
        if(clean_name == "btn_news_toggle") return DASH_ACTION_NEWS_TOGGLE;
        if(clean_name == "btn_minimize") {
            m_is_minimized = !m_is_minimized;
            SetVisibility(!m_is_minimized);
            return DASH_ACTION_MINIMIZE;
        }
        if(clean_name == "btn_close") return DASH_ACTION_CLOSE_DASH;
        
        return DASH_ACTION_NONE;
    }

    void SetVisibility(bool visible) 
    {
        m_visible = visible;
        
        if(!visible) {
            ObjectsDeleteAll(m_chart_id, m_prefix);
            m_objects_created = false;
            ChartRedraw();
            return;
        }
        
        if(!m_objects_created) {
            CreateBeautifulLayout();
        } else {
            int total = ObjectsTotal(m_chart_id, m_subwin, -1);
            for(int i = 0; i < total; i++) {
                string obj_name = ObjectName(m_chart_id, i, m_subwin, -1);
                if(StringFind(obj_name, m_prefix) >= 0) {
                    ObjectSetInteger(m_chart_id, obj_name, OBJPROP_HIDDEN, false);
                }
            }
            ChartRedraw();
        }
    }

    void Deinit()
    {
        ObjectsDeleteAll(m_chart_id, m_prefix);
        m_objects_created = false;
        ChartRedraw();
    }

    bool IsVisible() const { return m_visible && !m_is_minimized; }
    bool IsCreated() const { return m_objects_created; }
    void SetUpdateInterval(int seconds) { m_update_interval = seconds; }
};

// Global beautiful dashboard instance
BeautifulDashboard g_beautiful_dashboard;