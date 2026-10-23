//+------------------------------------------------------------------+
//|                      CloseProfit v2(barabashkakvn's edition).mq5 |
//|                               Copyright © 2012, Vladimir Hlystov |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, http://cmillion.narod.ru"
#property link      "cmillion@narod.ru"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CAccountInfo   m_account;                    // account info wrapper
COrderInfo     m_order;                      // pending orders object
//--- input parameters
input double   ProfitClose    = 10;    // Profit Close
input double   LossClose      = 1000;  // Loss Close
input bool     AllSymbols     = false; // All Symbols
input ulong    m_magic        = 0;     // magic number (0 - all magics)
//---
ulong          m_slippage=10;          // slippage
//---
string txt="";
string language="";
bool bln_close_all=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(Symbol());
   m_trade.SetDeviationInPoints(m_slippage);
//---
   if(!LabelCreate(0,"Balance",0,5,15,CORNER_LEFT_LOWER,"Balance"))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Equity",0,5,25,CORNER_LEFT_LOWER,"Equity"))
      return(INIT_FAILED);
   if(!LabelCreate(0,"Profit",0,5,35,CORNER_LEFT_LOWER,"Profit"))
      return(INIT_FAILED);
//---
   language=TerminalInfoString(TERMINAL_LANGUAGE);
   if(AllSymbols)
     {
      txt=(language=="Russian")?"По всем инструментам счета":"For all symbols";
     }
   if(m_magic==0)
     {
      string temp_txt=(language=="Russian")?"По всем magic":"For all magics";
      StringConcatenate(txt,txt,"\n",temp_txt);
     }
   else
      StringConcatenate(txt,txt,"\n","magic number = ",m_magic);

   bln_close_all=false;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   LabelDelete(0,"Balance");
   LabelDelete(0,"Equity");
   LabelDelete(0,"Profit");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(MQLInfoInteger(MQL_DEBUG) || MQLInfoInteger(MQL_PROFILER) || 
      MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_OPTIMIZATION))
     {
      if(!bln_close_all)
        {
         if(!IsPositionExists())
            m_trade.Buy(1.0);
         if(!IsPendingOrdersExists())
           {
            MqlTick tick;
            if(SymbolInfoTick(Symbol(),tick))
               m_trade.BuyLimit(1.0,tick.ask-100*Point());
           }
        }
     }
//---
   if(bln_close_all)
     {
      if(IsPendingOrdersExists() || IsPositionExists())
        {
         DeleteAllPendingOrders();
         CloseAllPositions();
         return;
        }
      else
         bln_close_all=false;
     }
//---
   double positions_profit=0.0,buys_volume=0.0,sells_volume=0.0,positions_volume=0.0;
   int count_buys=0,count_sells=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if((m_position.Symbol()==Symbol() || AllSymbols) && (m_position.Magic()==m_magic || m_magic==0))
           {
            positions_volume=m_position.Volume();
            positions_profit+=m_position.Commission()+m_position.Swap()+m_position.Profit();

            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               count_buys++;
               buys_volume+=positions_volume;
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               count_sells++;
               sells_volume+=positions_volume;
              }
           }
//---
   Comment(txt,"\n","Buy ",count_buys,"\n","Sell ",count_sells);
//--- 
   if(positions_profit>=ProfitClose)
     {
      string temp_text=(language=="Russian")?"Достигнут уровень прибыли = ":"Profit level = ";
      Alert(temp_text+DoubleToString(positions_profit,2));
      bln_close_all=true;
     }
   if(positions_profit<=-LossClose)
     {
      string temp_text=(language=="Russian")?"Достигнут уровень максимального убытка ":"Level of maximum loss reached ";
      Alert(temp_text+DoubleToString(positions_profit,2));
      bln_close_all=true;
     }
   LabelTextChange(0,"Balance","Balance: "+DoubleToString(m_account.Balance(),2));
   LabelTextChange(0,"Equity","Equity: "+DoubleToString(m_account.Equity(),2));

   string txt2="";
   if(buys_volume>0 || sells_volume>0)
     {
      if(AllSymbols)
        {
         string temp_text=(language=="Russian")?"Прибыль по всем символам ":"Profit for all symbols";
         StringConcatenate(txt2,temp_text,DoubleToString(positions_profit,2));
        }
      else
        {
         string temp_text=(language=="Russian")?"Прибыль ":"Profit ";
         StringConcatenate(txt2,temp_text,Symbol()," ",DoubleToString(positions_profit,2));
        }
     }
   if(buys_volume>0)
      StringConcatenate(txt2,txt2,"  Lot Buy = ",DoubleToString(buys_volume,2));
   if(sells_volume>0)
      StringConcatenate(txt2,txt2,"  Lot Sell = ",DoubleToString(sells_volume,2));
   LabelTextChange(0,"Profit",txt2);
//---
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
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
                 const string            font="Courier New",       // font 
                 const int               font_size=10,             // font size 
                 const color             clr=clrBlueViolet,        // color 
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
//| Delete a text label                                              | 
//+------------------------------------------------------------------+ 
bool LabelDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="Label") // label name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete the label 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a text label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//| Is position exists                                               |
//+------------------------------------------------------------------+
bool IsPositionExists(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if((m_position.Symbol()==Symbol() || AllSymbols) && (m_position.Magic()==m_magic || m_magic==0))
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Is pending orders exists                                         |
//+------------------------------------------------------------------+
bool IsPendingOrdersExists(void)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if((m_order.Symbol()==Symbol() || AllSymbols) && (m_order.Magic()==m_magic || m_magic==0))
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Delete all pending orders                                        |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders(void)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if((m_order.Symbol()==Symbol() || AllSymbols) && (m_order.Magic()==m_magic || m_magic==0))
            m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if((m_position.Symbol()==Symbol() || AllSymbols) && (m_position.Magic()==m_magic || m_magic==0))
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
