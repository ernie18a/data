//+------------------------------------------------------------------+
//| MarginCallRadar.mq5                                              |
//| Copyright 2026, Serhii Semenov                                   |
//| https://www.mql5.com/en/users/ssemenov                           |
//+------------------------------------------------------------------+
#property copyright "Serhii Semenov"
#property link      "https://www.mql5.com/en/users/ssemenov"
#property version   "1.03"
#property description "Margin Call Radar - read-only account risk panel."
#property description "Shows the distance to margin call and stop out in money,"
#property description "percent of equity and points, plus adverse shock scenarios."
#property description "Does not open, modify or close any orders."
#property indicator_chart_window
#property indicator_plots 0

#include "RadarCore.mqh"

input group "Panel"
input ENUM_BASE_CORNER InpCorner = CORNER_LEFT_UPPER; // Panel corner
input int    InpX              = 12;                // Horizontal offset, pixels
input int    InpY              = 20;                // Vertical offset, pixels
input int    InpFontSize       = 9;                 // Font size
input color  InpTextColor      = clrWhiteSmoke;     // Text color
input color  InpOkColor        = clrLightGreen;     // Color: safe
input color  InpWarnColor      = clrGold;           // Color: below margin call
input color  InpDangerColor    = clrTomato;         // Color: below stop out
input bool   InpShowBackground = true;              // Show panel background
input color  InpBgColor        = C'25,25,25';       // Background color
input color  InpBorderColor    = C'90,90,90';       // Border color
input int    InpRefreshSeconds = 1;                 // Refresh interval, seconds

input group "Scenarios"
input double InpPriceMove1     = 1.0;               // Scenario 1: adverse price move, %
input double InpPriceMove2     = 3.0;               // Scenario 2: adverse price move, %
input double InpEquityShock    = 5.0;               // Scenario 3: equity drop, %

input group "Positions"
input bool   InpShowPositions  = true;              // Show positions table
input int    InpMaxPositions   = 8;                 // Maximum positions in the table

const string G_PREFIX="MCR_";

string g_text[];
color  g_color[];
int    g_count=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpRefreshSeconds<1)
     {
      Print("MarginCallRadar: refresh interval must be at least 1 second");
      return(INIT_PARAMETERS_INCORRECT);
     }
   EventSetTimer(InpRefreshSeconds);
   Render();
   Print("MarginCallRadar report:");
   for(int i=0;i<g_count;i++)
      if(StringLen(g_text[i])>0)
         Print(g_text[i]);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0,G_PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function (panel is refreshed by timer)|
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[])
  {
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function: refreshes the panel                              |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Render();
  }

//+------------------------------------------------------------------+
//| Appends a panel line to the buffer                               |
//+------------------------------------------------------------------+
void Emit(const string text,const color clr)
  {
   ArrayResize(g_text,g_count+1);
   ArrayResize(g_color,g_count+1);
   g_text[g_count]=text;
   g_color[g_count]=clr;
   g_count++;
  }

//+------------------------------------------------------------------+
//| Creates or updates a text label of the panel                     |
//+------------------------------------------------------------------+
void SetLine(const int index,const string text,const color clr)
  {
   int    step=InpFontSize+5;
   string name=G_PREFIX+"t"+IntegerToString(index);
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,100);
      ObjectSetString(0,name,OBJPROP_FONT,"Consolas");
     }
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpX);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpY+index*step);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,InpFontSize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }

//+------------------------------------------------------------------+
//| Draws the panel background sized to the text                     |
//+------------------------------------------------------------------+
void DrawBackground(const int lines)
  {
   string name=G_PREFIX+"bg";
   if(!InpShowBackground)
     {
      if(ObjectFind(0,name)>=0)
         ObjectDelete(0,name);
      return;
     }
   int max_len=0;
   for(int i=0;i<lines;i++)
     {
      int len=StringLen(g_text[i]);
      if(len>max_len)
         max_len=len;
     }
   int step=InpFontSize+5;
   int pad =8;
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,50);
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
     }
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpX-pad);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpY-pad);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,(int)(max_len*InpFontSize*0.82)+2*pad);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,lines*step+2*pad);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,InpBgColor);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpBorderColor);
  }

//+------------------------------------------------------------------+
//| Color of a scenario line by the level after the loss             |
//+------------------------------------------------------------------+
color ScenarioColor(const double equity,const double margin,const double loss,
                    const double call_level,const double so_level,const bool money_mode)
  {
   if(margin<=0.0)
      return(InpTextColor);
   double level =LevelAfterLoss(equity,margin,loss);
   double callPct=LevelTargetPercent(call_level,margin,money_mode);
   double soPct  =LevelTargetPercent(so_level,margin,money_mode);
   if(level<=soPct)
      return(InpDangerColor);
   if(level<=callPct)
      return(InpWarnColor);
   return(InpOkColor);
  }

//+------------------------------------------------------------------+
//| Collects account data and redraws the panel                      |
//+------------------------------------------------------------------+
void Render()
  {
   //--- account state
   double equity  =AccountInfoDouble(ACCOUNT_EQUITY);
   double balance =AccountInfoDouble(ACCOUNT_BALANCE);
   double margin  =AccountInfoDouble(ACCOUNT_MARGIN);
   double free_m  =AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double call_lvl=AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);
   double so_lvl  =AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
   bool   money_mode=(AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_MONEY);
   string currency=AccountInfoString(ACCOUNT_CURRENCY);

   //--- netted book and current level
   int    total =PositionsTotal();
   double book  =BookLossPerPoint();
   bool   pts_ok=(book>0.0);
   double level =LevelPercent(equity,margin);
   double callPct=LevelTargetPercent(call_lvl,margin,money_mode);
   double soPct  =LevelTargetPercent(so_lvl,margin,money_mode);

   //--- rebuild the line buffer
   g_count=0;
   ArrayResize(g_text,0);
   ArrayResize(g_color,0);

   Emit("MARGIN CALL RADAR",InpTextColor);
   Emit(StringFormat("Equity %s   Balance %s",FormatMoney(equity,currency),FormatMoney(balance,currency)),InpTextColor);
   Emit(StringFormat("Margin %s   Free %s",FormatMoney(margin,currency),FormatMoney(free_m,currency)),InpTextColor);

   if(margin<=0.0)
     {
      Emit(StringFormat("Margin level: no open positions (%d)",total),InpTextColor);
     }
   else
     {
      color level_color=(level<=soPct)?InpDangerColor:((level<=callPct)?InpWarnColor:InpOkColor);
      Emit(StringFormat("Margin level %.2f %%   Positions %d",level,total),level_color);

      //--- distances to margin call and stop out
      double d_call=MoneyToTarget(equity,margin,call_lvl,money_mode);
      double d_so  =MoneyToTarget(equity,margin,so_lvl,money_mode);
      color  c_call=(d_call<=0.0)?InpDangerColor:InpOkColor;
      color  c_so  =(d_so<=0.0)?InpDangerColor:InpOkColor;

      Emit(StringFormat("To margin call %.2f %s (%.2f %% of equity, %s)",
           d_call,currency,PercentToTarget(equity,margin,call_lvl,money_mode),
           FormatPoints(PointsForMoney(d_call,book),pts_ok)),c_call);
      Emit(StringFormat("To stop out %.2f %s (%.2f %% of equity, %s)",
           d_so,currency,PercentToTarget(equity,margin,so_lvl,money_mode),
           FormatPoints(PointsForMoney(d_so,book),pts_ok)),c_so);

      //--- shock scenarios
      double loss_p1=LossForPriceMovePercent(InpPriceMove1);
      double loss_p2=LossForPriceMovePercent(InpPriceMove2);
      double loss_eq=equity*InpEquityShock/100.0;

      Emit(StringFormat("Shock prices -%.1f %% (%s) -> level %.2f %%",
           InpPriceMove1,FormatMoney(loss_p1,currency),LevelAfterLoss(equity,margin,loss_p1)),
           ScenarioColor(equity,margin,loss_p1,call_lvl,so_lvl,money_mode));
      Emit(StringFormat("Shock prices -%.1f %% (%s) -> level %.2f %%",
           InpPriceMove2,FormatMoney(loss_p2,currency),LevelAfterLoss(equity,margin,loss_p2)),
           ScenarioColor(equity,margin,loss_p2,call_lvl,so_lvl,money_mode));
      Emit(StringFormat("Shock equity -%.1f %% (%s) -> level %.2f %%",
           InpEquityShock,FormatMoney(loss_eq,currency),LevelAfterLoss(equity,margin,loss_eq)),
           ScenarioColor(equity,margin,loss_eq,call_lvl,so_lvl,money_mode));
     }

   if(InpShowPositions && total>0)
     {
      //--- positions table
      Emit("",InpTextColor);
      Emit("Positions",InpTextColor);
      int shown=0;
      for(int i=0;i<total && shown<InpMaxPositions;i++)
        {
         ulong ticket=PositionGetTicket(i);
         if(ticket==0)
            continue;
         string symbol=PositionGetString(POSITION_SYMBOL);
         double volume=PositionGetDouble(POSITION_VOLUME);
         double profit=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
         ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         color  pos_color=(profit>=0.0)?InpOkColor:InpDangerColor;
         Emit(StringFormat("%s %s %.2f  P/L %.2f %s",
              symbol,(type==POSITION_TYPE_BUY?"buy":"sell"),volume,profit,currency),
              pos_color);
         shown++;
        }
      if(total>InpMaxPositions)
         Emit(StringFormat("... and %d more",total-InpMaxPositions),InpTextColor);
     }

   //--- draw lines, empty lines have no object
   DrawBackground(g_count);
   for(int i=0;i<g_count;i++)
     {
      string name=G_PREFIX+"t"+IntegerToString(i);
      if(StringLen(g_text[i])>0)
         SetLine(i,g_text[i],g_color[i]);
      else
         if(ObjectFind(0,name)>=0)
            ObjectDelete(0,name);
     }
   //--- delete labels left from a longer previous render
   for(int i=g_count;i<g_count+64;i++)
     {
      string name=G_PREFIX+"t"+IntegerToString(i);
      if(ObjectFind(0,name)>=0)
         ObjectDelete(0,name);
     }
   ChartRedraw();
  }
