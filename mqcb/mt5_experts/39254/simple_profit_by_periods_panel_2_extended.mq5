//+------------------------------------------------------------------+
//|                    Simple Profit By Periods Panel 2 Extended.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "2.100"
//--- input parameters
input group             "Panel settings"
input int                  InpX                    = 50;                // X-axis distance
input int                  InpY                    = 112;               // Y-axis distance
input string               InpFont                 = "Lucida Console";  // Font
input int                  InpFontSize             = 12;                // Font size
input group             "Trading settings"
input string               InpSymbol               = "EURUSD";          // Symbol
input ulong                InpMagic                = 200;               // Magic number
//---
string   m_prefix="SPBPP_2_extended_";
string   m_dayly_profit_name  = m_prefix+"Daily Profit";       // Label "Daily Profit" name
string   m_weekly_profit_name = m_prefix+"Weekly Profit";      // Label "Weekly Profit" name
string   m_monthly_profit_name= m_prefix+"Monthly Profit";     // Label "Monthly Profit" name
string   m_dayly_deals_name   = m_prefix+"Daily Deals";        // Label "Daily Deals" name
string   m_weekly_deals_name  = m_prefix+"Weekly Deals";       // Label "Weekly Deals" name
string   m_monthly_deals_name = m_prefix+"Monthly Deals";      // Label "Monthly Deals" name
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(3);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
//---
   ObjectsDeleteAll(0,m_prefix,0,OBJ_LABEL);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   int gap_y=20;
   if(ObjectFind(0,m_dayly_profit_name)<0)
      LabelCreate(0,m_dayly_profit_name,0,InpX,InpY,CORNER_LEFT_UPPER,"Daily Profit: "+"(%)",InpFont,InpFontSize);
   if(ObjectFind(0,m_weekly_profit_name)<0)
      LabelCreate(0,m_weekly_profit_name,0,InpX,InpY+gap_y,CORNER_LEFT_UPPER,"Weekly Profit: "+"(%)",InpFont,InpFontSize);
   if(ObjectFind(0,m_monthly_profit_name)<0)
      LabelCreate(0,m_monthly_profit_name,0,InpX,InpY+gap_y*2,CORNER_LEFT_UPPER,"Monthly Profit: "+"(%)",InpFont,InpFontSize);
//---
   if(ObjectFind(0,m_dayly_deals_name)<0)
      LabelCreate(0,m_dayly_deals_name,0,InpX,InpY+gap_y*3,CORNER_LEFT_UPPER,"Daily Deals: "+"(%)",InpFont,InpFontSize);
   if(ObjectFind(0,m_weekly_deals_name)<0)
      LabelCreate(0,m_weekly_deals_name,0,InpX,InpY+gap_y*4,CORNER_LEFT_UPPER,"Weekly Deals: "+"(%)",InpFont,InpFontSize);
   if(ObjectFind(0,m_monthly_deals_name)<0)
      LabelCreate(0,m_monthly_deals_name,0,InpX,InpY+gap_y*5,CORNER_LEFT_UPPER,"Monthly Deals: "+"(%)",InpFont,InpFontSize);
//---
   ProfitForPeriod();
//---
  }
//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool LabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the label text                                            |
//+------------------------------------------------------------------+
bool LabelTextChange(const long   chart_ID=0,   // chart's ID
                     const string name="Label", // object name
                     const string text="Text")  // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Profit for the period                                            |
//+------------------------------------------------------------------+
void ProfitForPeriod(void)
  {
   datetime time_trade_server = TimeTradeServer();
   datetime from_date         = time_trade_server;
   datetime to_date           = time_trade_server+60*60*24*3;
   datetime from_date_day     = time_trade_server;
   datetime from_date_week    = time_trade_server;
   MqlDateTime STime;
   TimeToStruct(time_trade_server,STime);
//--- subtract time in seconds from the estimated time of the trade server - we get the time of day
   if(STime.day_of_week==0) // if it's Sunday - we subtract two days
      from_date_day=time_trade_server-60*60*24*2;
   if(STime.day_of_week==6) // if it's Saturday, we subtract the day
      from_date_day=time_trade_server-60*60*24;
   TimeToStruct(from_date_day,STime);
   STime.hour=0;
   STime.min=0;
   STime.sec=0;
   from_date_day=StructToTime(STime);           // start time of the last day (Monday to Friday)
//--- remember the current month
   TimeToStruct(from_date_day,STime);
   int curr_mon=STime.mon;
//--- takes time from the time of day in seconds - we get the time of the week
   if(STime.day_of_week==1)
      from_date_week=from_date_day;
   if(STime.day_of_week==2)
      from_date_week=from_date_day-60*60*24;    // minus day
   if(STime.day_of_week==3)
      from_date_week=from_date_day-60*60*24*2;  // minus two days
   if(STime.day_of_week==4)
      from_date_week=from_date_day-60*60*24*3;  // minus three days
   if(STime.day_of_week==5)
      from_date_week=from_date_day-60*60*24*4;  // minus four days
   TimeToStruct(from_date_week,STime);
//--- checking if we stayed in the current month (relative to the time of day)
   if(STime.mon!=curr_mon)
     {
      STime.mon=STime.mon+1;
      STime.day=1;
      from_date_week=StructToTime(STime);
      from_date=from_date_week;
     }
   else // remained in the current month
     {
      STime.day=1;
      from_date=StructToTime(STime);
     }
//--- request trade history
   HistorySelect(from_date,to_date);
//---
   uint     total=HistoryDealsTotal();
   ulong    ticket=0;
   long     position_id=0;
   double   profit_monthly=0.0,profit_weekly=0.0,profit_dayly=0.0;
   int      deals_monthly=0,deals_weekly=0,deals_dayly=0;
//--- for all deals
   for(uint i=0; i<total; i++) // for(uint i=0;i<total;i++) => i #0 - 2016, i #1045 - 2017
     {
      //--- try to get deals ticket
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         //--- get deals properties
         long     deal_time         = HistoryDealGetInteger(ticket,DEAL_TIME);
         long     deal_type         = HistoryDealGetInteger(ticket,DEAL_TYPE);
         long     deal_entry        = HistoryDealGetInteger(ticket,DEAL_ENTRY);
         long     deal_magic        = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         //---
         double   deal_commission   = HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         double   deal_swap         = HistoryDealGetDouble(ticket,DEAL_SWAP);
         double   deal_profit       = HistoryDealGetDouble(ticket,DEAL_PROFIT);
         //---
         string   deal_symbol       = HistoryDealGetString(ticket,DEAL_SYMBOL);
         //--- only for input symbol and magic
         if(deal_symbol==InpSymbol && deal_magic==InpMagic)
            if((ENUM_DEAL_TYPE)deal_type==DEAL_TYPE_BUY || (ENUM_DEAL_TYPE)deal_type==DEAL_TYPE_SELL)
              {
               double profit=deal_commission+deal_swap+deal_profit;
               profit_monthly+=profit;
               deals_monthly++;
               if(deal_time>=from_date_week)
                 {
                  profit_weekly+=profit;
                  deals_weekly++;
                 }
               if(deal_time>=from_date_day)
                 {
                  profit_dayly+=profit;
                  deals_dayly++;
                 }
              }
        }
     }
   double curr_balance=AccountInfoDouble(ACCOUNT_BALANCE);
   /*
   prev. balance                 - 100%
   prev. balance + profit        - x%

   dayly_prev_balance            - 100%
   curr_balance                  - x%
   x = 100.0-(curr_balance*100.0/dayly_prev_balance)
   */
   double dayly_prev_balance     = curr_balance-profit_dayly;
   double weekly_prev_balance    = curr_balance-profit_weekly;
   double monthly_prev_balance   = curr_balance-profit_monthly;
   string currency=AccountInfoString(ACCOUNT_CURRENCY);
//---
   LabelTextChange(0,m_dayly_profit_name,"Daily Profit:     "+currency+" "+DoubleToString(profit_dayly,2)+
                   " ("+DoubleToString((curr_balance*100.0/dayly_prev_balance)-100.0,2)+"%)");
   LabelTextChange(0,m_weekly_profit_name,"Weekly Profit:    "+currency+" "+DoubleToString(profit_weekly,2)+
                   " ("+DoubleToString((curr_balance*100.0/weekly_prev_balance)-100.0,2)+"%)");
   LabelTextChange(0,m_monthly_profit_name,"Monthly Profit:   "+currency+" "+DoubleToString(profit_monthly,2)+
                   " ("+DoubleToString((curr_balance*100.0/monthly_prev_balance)-100.0,2)+"%)");
//---
   LabelTextChange(0,m_dayly_deals_name,"Daily Deals:      "+IntegerToString(deals_dayly));
   LabelTextChange(0,m_weekly_deals_name,"Weekly Deals:     "+IntegerToString(deals_weekly));
   LabelTextChange(0,m_monthly_deals_name,"Monthly Deals:    "+IntegerToString(deals_monthly));
//---
   return;
  }
//+------------------------------------------------------------------+
