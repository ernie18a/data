//************************************************************************************************/
//*                             VR-Calculate-Martingale-Lite.mq4                                 */
//*                            Copyright 2019, Trading-go Project.                               */
//*            Author: Voldemar, Version: 10.10.2019, Site https://trading-go.ru                 */
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
//| Full version MetaTrader 4  https://www.mql5.com/ru/market/product/13628(open source)
//| Demo version MetaTrader 4  https://www.mql5.com/ru/market/product/13627
//| Lite version MetaTrader 4  https://www.mql5.com/ru/code/26873
//| Full version MetaTrader 5  https://www.mql5.com/ru/market/product/42860
//| Demo version MetaTrader 5  https://www.mql5.com/ru/market/product/42865
//| Lite version MetaTrader 5  https://www.mql5.com/ru/code/22382
//| Blog Russian               https://www.mql5.com/ru/blogs/post/730443
//| Blog English               https://www.mql5.com/en/blogs/post/730444
//************************************************************************************************/
//| All products of the Author https://www.mql5.com/ru/users/voldemar/seller
//************************************************************************************************/
#property strict
#property copyright     "Copyright 2019, Trading-go Project."
#property link          "https://trading-go.ru"
#property version       "19.101"
#property description   " "
#property description   " "
#property description   " "
#property indicator_chart_window
#property indicator_plots 0
#property indicator_buffers 0

input string iPrefix = "^$%#";
input double iLots   = 0.01;
struct str
  {
protected:
   string            m_name_orders;
   int               m_type_orders;
   double            m_lots_orders;
   double            m_cena_orders;
   MqlTick           tick;
public:
   string            GetName(void)         { return m_name_orders; }
   int               GetType(void)         { return m_type_orders; }
   double            GetLots(void)         { return m_lots_orders; }
   double            GetCena(void)         { return m_cena_orders; }

   void              SetName(string aName) { m_name_orders = aName;}
   void              SetType(int aType)    { m_type_orders = aType;}
   void              SetLots(double aLots) { m_lots_orders = aLots;}
   void              SetCena(double aCena) { m_cena_orders = aCena;}

   void              SetAWpr(string aName, datetime aTime, double aPrice)
     {
      ObjectSetInteger(0, iPrefix + "D" + aName, OBJPROP_TIME, 1, TimeCurrent() + PeriodSeconds() * 5);
      ObjectSetDouble(0, iPrefix + "D" + aName, OBJPROP_PRICE, 1, aPrice);
     }

   bool              CreateBuy(string aName)
     {
      if(!SymbolInfoTick(Symbol(), tick))
        {
         Print("SymbolInfoTick() failed, error = ", GetLastError());
         return false;
        }
      m_name_orders = aName;
      m_type_orders = 0;
      m_lots_orders = iLots;
      m_cena_orders = NormalizeDouble(tick.bid, Digits());
      ButtonCreate(0, iPrefix + "A" + aName, 0, 0, 0, 30, 18, CORNER_LEFT_UPPER, "Buy", "Arial", 10, clrWhite, clrBlue, clrBlue, false, false, false, true, 0);
      EditCreate(0, iPrefix + "B" + aName, 0, 10, 30, 36, 18, DoubleToString(m_lots_orders, 2), "Arial", 10, ALIGN_CENTER, false, CORNER_LEFT_UPPER, clrWhite, clrGray, clrBlue, false, false, true, 0);
      TrendCreate(0, iPrefix + "D" + aName, 0, TimeCurrent() - PeriodSeconds() * 10, m_cena_orders, TimeCurrent() + PeriodSeconds() * 10, m_cena_orders, clrBlue, STYLE_SOLID, 1, false, false, false, false, true, 0);

      ArrowCreate(0, iPrefix + "C" + aName, 0, TimeCurrent() + PeriodSeconds() * 10, m_cena_orders,   clrBlue, STYLE_SOLID, 2, false, true, true, 0);

      OrderDrag(aName);
      return true;
     }
   bool              CreateSel(string aName)
     {
      if(!SymbolInfoTick(Symbol(), tick))
        {
         Print("SymbolInfoTick() failed, error = ", GetLastError());
         return false;
        }
      m_name_orders = aName;
      m_type_orders = 1;
      m_lots_orders = iLots;
      m_cena_orders = NormalizeDouble(tick.bid, Digits());
      ButtonCreate(0, iPrefix + "A" + aName, 0, 0, 0, 30, 18, CORNER_LEFT_UPPER, "Sell", "Arial", 10, clrWhite, clrTomato, clrTomato, false, false, false, true, 0);
      EditCreate(0, iPrefix + "B" + aName, 0, 10, 30, 36, 18, DoubleToString(m_lots_orders, 2), "Arial", 10, ALIGN_CENTER, false, CORNER_LEFT_UPPER, clrWhite, clrGray, clrTomato, false, false, true, 0);
      TrendCreate(0, iPrefix + "D" + aName, 0, TimeCurrent() - PeriodSeconds() * 10, m_cena_orders, TimeCurrent() + PeriodSeconds() * 10, m_cena_orders, clrTomato, STYLE_SOLID, 1, false, false, false, false, true, 0);

      ArrowCreate(0, iPrefix + "C" + aName, 0, TimeCurrent() + PeriodSeconds() * 10, m_cena_orders,   clrTomato, STYLE_SOLID, 2, false, true, true, 0);
      OrderDrag(aName);
      return true;
     }

   void              OrderDrag(string aName)
     {
      datetime times = (datetime)ObjectGetInteger(0, iPrefix + "C" + aName, OBJPROP_TIME, 0);
      double   price = ObjectGetDouble(0, iPrefix + "C" + aName, OBJPROP_PRICE, 0);

      string    text = ObjectGetString(0, iPrefix + "B" + aName, OBJPROP_TEXT);
      m_lots_orders  = StringToDouble(text);
      m_cena_orders  = price;
      int x = 0, y = 0;
      if(ChartTimePriceToXY(0, 0, times, price, x, y))
        {
         ObjectSetInteger(0, iPrefix + "A" + aName, OBJPROP_XDISTANCE, x + 2 - 72);
         ObjectSetInteger(0, iPrefix + "A" + aName, OBJPROP_YDISTANCE, y + 2 - 10);

         ObjectSetInteger(0, iPrefix + "B" + aName, OBJPROP_XDISTANCE, x + 32 - 72);
         ObjectSetInteger(0, iPrefix + "B" + aName, OBJPROP_YDISTANCE, y + 2 - 10);

         ObjectSetInteger(0, iPrefix + "D" + aName, OBJPROP_TIME, 0, times);
         ObjectSetDouble(0, iPrefix + "D" + aName, OBJPROP_PRICE, 0, price);

        }
     }
  };
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
struct structura
  {
protected:

public:
   str               orders[];
   bool              MenuCreate(void)
     {
      EditCreate(0, iPrefix + "Menu", 0, 10, 30, 64, 22, "", "Arial", 10, ALIGN_CENTER, false, CORNER_LEFT_UPPER, clrWhite, clrGray, clrNONE, false, true, true, 0);
      ButtonCreate(0, iPrefix + "Buy", 0, 0, 0, 30, 18, CORNER_LEFT_UPPER, "Buy", "Arial", 10, clrWhite, clrBlue, clrBlue, false, false, false, true, 0);
      ButtonCreate(0, iPrefix + "Sel", 0, 0, 0, 30, 18, CORNER_LEFT_UPPER, "Sell", "Arial", 10, clrWhite, clrTomato, clrTomato, false, false, false, true, 0);

      ArrowCreate(0, iPrefix + "AW", 0, TimeCurrent() + PeriodSeconds() * 10, 0,   clrGreen, STYLE_SOLID, 3, false, false, true, 0);

      MenuDrag();
      return true;
     }

   void              MenuDrag(void)
     {
      int x = (int)ObjectGetInteger(0, iPrefix + "Menu", OBJPROP_XDISTANCE);
      int y = (int)ObjectGetInteger(0, iPrefix + "Menu", OBJPROP_YDISTANCE);

      ObjectSetInteger(0, iPrefix + "Buy", OBJPROP_XDISTANCE, x + 2);
      ObjectSetInteger(0, iPrefix + "Buy", OBJPROP_YDISTANCE, y + 2);

      ObjectSetInteger(0, iPrefix + "Sel", OBJPROP_XDISTANCE, x + 32);
      ObjectSetInteger(0, iPrefix + "Sel", OBJPROP_YDISTANCE, y + +2);
     }

   bool              GetStateBuy(void) { return (bool)ObjectGetInteger(0, iPrefix + "Buy", OBJPROP_STATE);}
   void              SetStateBuy(void) { ObjectSetInteger(0, iPrefix + "Buy", OBJPROP_STATE, false);}
   bool              GetStateSel(void) { return (bool)ObjectGetInteger(0, iPrefix + "Sel", OBJPROP_STATE);}
   void              SetStateSel(void) { ObjectSetInteger(0, iPrefix + "Sel", OBJPROP_STATE, false);}
  };
structura st;

//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
int OnInit()
  {
   Comment("");
   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);

   st.MenuCreate();
   return(INIT_SUCCEEDED);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(st.GetStateBuy())
        {
         int u = ArraySize(st.orders);
         ArrayResize(st.orders, u + 1, 100);
         st.orders[u].CreateBuy(IntegerToString(u));

         st.SetStateBuy();
        }

      if(st.GetStateSel())
        {
         int u = ArraySize(st.orders);
         ArrayResize(st.orders, u + 1, 100);
         st.orders[u].CreateSel(IntegerToString(u));

         st.SetStateSel();
        }
     }

   if(id == CHARTEVENT_MOUSE_MOVE || id == CHARTEVENT_OBJECT_ENDEDIT)
      if(sparam == "1")
        {
         double buy_price = 0, sel_price = 0, buy_lot = 0, sel_lot = 0, price_aw = 0;
         int t = 0;
         for(int i = 0; i < ArraySize(st.orders); i++)
           {
            st.orders[i].OrderDrag(IntegerToString(i));

            if(st.orders[i].GetType() == 0)
              {
               buy_price += st.orders[i].GetCena() * st.orders[i].GetLots();
               buy_lot += st.orders[i].GetLots();

               t++;
              }
            if(st.orders[i].GetType() == 1)
              {
               sel_price += st.orders[i].GetCena() * st.orders[i].GetLots();
               sel_lot += st.orders[i].GetLots();
               t++;
              }
           }

         if(t >= 2 && (buy_lot - sel_lot) != 0)
           {
            price_aw = NormalizeDouble((buy_price - sel_price) / (buy_lot - sel_lot), Digits());

            if(price_aw > 0)
               for(int i = 0; i < ArraySize(st.orders); i++)
                  st.orders[i].SetAWpr(IntegerToString(i), TimeCurrent(), price_aw);

            ObjectSetDouble(0, iPrefix + "AW", OBJPROP_PRICE, 0, price_aw);
            ObjectSetInteger(0, iPrefix + "AW", OBJPROP_TIME, 0, TimeCurrent() + PeriodSeconds() * 5);

           }
         st.MenuDrag();
        }

   ChartRedraw();
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
               )
  {
   return(rates_total);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, iPrefix);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
bool ButtonCreate(const long              chart_ID = 0,             // chart's ID
                  const string            name = "Button",          // button name
                  const int               sub_window = 0,           // subwindow index
                  const int               x = 0,                    // X coordinate
                  const int               y = 0,                    // Y coordinate
                  const int               width = 50,               // button width
                  const int               height = 18,              // button height
                  const ENUM_BASE_CORNER  corner = CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text = "Button",          // text
                  const string            font = "Arial",           // font
                  const int               font_size = 10,           // font size
                  const color             clr = clrBlack,           // text color
                  const color             back_clr = C'236,233,216', // background color
                  const color             border_clr = clrNONE,     // border color
                  const bool              state = false,            // pressed/released
                  const bool              back = false,             // in the background
                  const bool              selection = false,        // highlight to move
                  const bool              hidden = true,            // hidden in the object list
                  const long              z_order = 0)              // priority for mouse click
  {
   ResetLastError();
   if(ObjectCreate(chart_ID, name, OBJ_BUTTON, sub_window, 0, 0))
     {
      ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
      ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
      ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
      ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
      ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
      ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
      ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
      ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
      ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
      ObjectSetInteger(chart_ID, name, OBJPROP_STATE, state);
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
      ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
      ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
      return(true);
     }
   Print(__FUNCTION__, ": failed to create the button! Error code = ", GetLastError());
   return(false);
  }
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID = 0,      // chart's ID
                 const string          name = "TrendLine", // line name
                 const int             sub_window = 0,    // subwindow index
                 datetime              time1 = 0,         // first point time
                 double                price1 = 0,        // first point price
                 datetime              time2 = 0,         // second point time
                 double                price2 = 0,        // second point price
                 const color           clr = clrRed,      // line color
                 const ENUM_LINE_STYLE style = STYLE_SOLID, // line style
                 const int             width = 1,         // line width
                 const bool            back = false,      // in the background
                 const bool            selection = true,  // highlight to move
                 const bool            ray_left = false,  // line's continuation to the left
                 const bool            ray_right = false, // line's continuation to the right
                 const bool            hidden = true,     // hidden in the object list
                 const long            z_order = 0)       // priority for mouse click
  {
   ResetLastError();
   if(ObjectCreate(chart_ID, name, OBJ_TREND, sub_window, time1, price1, time2, price2))
     {
      ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
      ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
      ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
      ObjectSetInteger(chart_ID, name, OBJPROP_RAY_LEFT, ray_left);
      ObjectSetInteger(chart_ID, name, OBJPROP_RAY_RIGHT, ray_right);
      ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
      ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
      return(true);
     }
   Print(__FUNCTION__, ": failed to create a trend line! Error code = ", GetLastError());
   return(false);
  }
//+------------------------------------------------------------------+
bool EditCreate(const long             chart_ID = 0,             // chart's ID
                const string           name = "Edit",            // object name
                const int              sub_window = 0,           // subwindow index
                const int              x = 0,                    // X coordinate
                const int              y = 0,                    // Y coordinate
                const int              width = 50,               // width
                const int              height = 18,              // height
                const string           text = "Text",            // text
                const string           font = "Arial",           // font
                const int              font_size = 10,           // font size
                const ENUM_ALIGN_MODE  align = ALIGN_CENTER,     // alignment type
                const bool             read_only = false,        // ability to edit
                const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER, // chart corner for anchoring
                const color            clr = clrBlack,           // text color
                const color            back_clr = clrWhite,      // background color
                const color            border_clr = clrNONE,     // border color
                const bool             back = false,             // in the background
                const bool             selection = false,        // highlight to move
                const bool             hidden = true,            // hidden in the object list
                const long             z_order = 0)              // priority for mouse click
  {
   ResetLastError();
   if(ObjectCreate(chart_ID, name, OBJ_EDIT, sub_window, 0, 0))
     {
      ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
      ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
      ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
      ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
      ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
      ObjectSetInteger(chart_ID, name, OBJPROP_ALIGN, align);
      ObjectSetInteger(chart_ID, name, OBJPROP_READONLY, read_only);
      ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
      ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
      ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
      ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
      ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
      ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
      return(true);
     }
   Print(__FUNCTION__, ": failed to create \"Edit\" object! Error code = ", GetLastError());
   return(false);

  }
//+------------------------------------------------------------------+
bool ArrowCreate(const long              chart_ID = 0,         // chart's ID
                 const string            name = "Arrow",       // arrow name
                 const int               sub_window = 0,       // subwindow index
                 datetime                time = 0,             // anchor point time
                 double                  price = 0,            // anchor point price
                 const color             clr = clrRed,         // arrow color
                 const ENUM_LINE_STYLE   style = STYLE_SOLID,  // border line style
                 const int               width = 3,            // arrow size
                 const bool              back = false,         // in the background
                 const bool              selection = true,     // highlight to move
                 const bool              hidden = true,        // hidden in the object list
                 const long              z_order = 0)          // priority for mouse click
  {
   ResetLastError();
   if(ObjectCreate(chart_ID, name, OBJ_ARROW_RIGHT_PRICE, sub_window, time, price))
     {
      ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
      ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
      ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
      ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
      ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
      return(true);
     }
   Print(__FUNCTION__, ": failed to create an arrow! Error code = ", GetLastError());
   return(false);
  }
//+------------------------------------------------------------------+
