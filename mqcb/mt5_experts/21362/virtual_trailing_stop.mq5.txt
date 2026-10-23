//+------------------------------------------------------------------+
//|               Virtual Trailing Stop(barabashkakvn's edition).mq5 |
//|                                         Copyright 2015, cmillion |
//|                                               http://cmillion.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, cmillion@narod.ru"
#property link      "http://cmillion.ru"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input ushort            Stoploss       = 0;              // Стоп-лосс
input ushort            Takeprofit     = 0;              // Тейк-профит
input ushort            TrailingStop   = 5;              // Длина трала
input ushort            TrailingStart  = 5;              // Минимальная прибыль для старта
input ushort            TrailingStep   = 1;              // Шаг трала
//--- HLine
input string            InpNameBuy     = "SL Buy";       // BUY Line name 
input string            InpNameSell    = "SL Sell";      // SELL Line name 
input ENUM_LINE_STYLE   InpStyle=STYLE_DASHDOTDOT;       // Line style 
//---
ulong          m_slippage=10;                // slippage
double         TrallB = 0;
double         TrallS = 0;

double         ExtStoploss=0.0;
double         ExtTakeprofit=0.0;
double         ExtTrailingStop=0.0;
double         ExtTrailingStart=0.0;
double         ExtTrailingStep=0.0;

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
//---
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStoploss       = Stoploss        * m_adjusted_point;
   ExtTakeprofit     = Takeprofit      * m_adjusted_point;
   ExtTrailingStop   = TrailingStop    * m_adjusted_point;
   ExtTrailingStart  = TrailingStart   * m_adjusted_point;
   ExtTrailingStep   = TrailingStep    * m_adjusted_point;
//---
   if(!HLineCreate(0,InpNameBuy,0,0,clrBlue,InpStyle) || !HLineCreate(0,InpNameSell,0,0,clrRed,InpStyle))
      return(INIT_FAILED);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   HLineDelete(0,InpNameBuy);
   HLineDelete(0,InpNameSell);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int b=0,s=0;
   ulong TicketB=0,TicketS=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            if(!RefreshRates())
               return;
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               b++;
               if(Stoploss!=0 && m_symbol.Bid()<=m_position.PriceOpen()-ExtStoploss)
                 {
                  if(m_trade.PositionClose(m_position.Ticket()))
                     continue;
                 }
               if(Takeprofit!=0 && m_symbol.Bid()>=m_position.PriceOpen()+ExtTakeprofit)
                 {
                  if(m_trade.PositionClose(m_position.Ticket()))
                     continue;
                 }
               TicketB=m_position.Ticket();
               if(TrailingStop>0)
                 {
                  double SL=m_symbol.Bid()-ExtTrailingStop;
                  if(SL>=m_position.PriceOpen()+ExtTrailingStart && (TrallB==0 || TrallB+ExtTrailingStep<SL))
                     TrallB=SL;
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               s++;
               if(Stoploss!=0 && m_symbol.Ask()>=m_position.PriceOpen()+ExtStoploss)
                 {
                  if(m_trade.PositionClose(m_position.Ticket()))
                     continue;
                 }
               if(Takeprofit!=0 && m_symbol.Ask()<=m_position.PriceOpen()-ExtTakeprofit)
                 {
                  if(m_trade.PositionClose(m_position.Ticket()))
                     continue;
                 }
               TicketS=m_position.Ticket();
               if(TrailingStop>0)
                 {
                  double SL=m_symbol.Ask()+ExtTrailingStop;
                  if(SL<=m_position.PriceOpen()-ExtTrailingStart && (TrallS==0 || TrallS-ExtTrailingStep>SL))
                     TrallS=SL;
                 }
              }
           }
//---
   if(b!=0)
     {
      if(b>1)
         Comment("Трал корректно работает только с одной позицией");
      else
      if(TrallB!=0)
        {
         Comment("Тралим позицию ",TicketB);
         HLineMove(0,InpNameBuy,TrallB);
         if(m_symbol.Bid()<=TrallB)
           {
            if(m_position.SelectByTicket(TicketB))
               if(m_position.Profit()>0.0)
                  if(!m_trade.PositionClose(TicketB))
                     Comment("Ошибка закрытия позиции. Result Retcode: ",m_trade.ResultRetcode(),
                             ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
     }
   else
     {
      TrallB=0;
      HLineMove(0,InpNameBuy,0.1);
     }
//---
   if(s!=0)
     {
      if(s>1)
         Comment("Трал корректно работает только с одной позицией");
      else
      if(TrallS!=0)
        {
         Comment("Тралим позицию ",TicketS);
         HLineMove(0,InpNameSell,TrallS);
         if(m_symbol.Ask()>=TrallS)
           {
            if(m_position.SelectByTicket(TicketS))
               if(m_position.Profit()>0.0)
                  if(!m_trade.PositionClose(TicketS))
                     Comment("Ошибка закрытия позиции. Result Retcode: ",m_trade.ResultRetcode(),
                             ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
     }
   else
     {
      TrallS=0;
      HLineMove(0,InpNameSell,0.1);
     }
//---
/*
   MQL_PROFILER
   The flag, that indicates the program operating in the code profiling mode
   
   MQL_TESTER
   The flag, that indicates the tester process
   
   MQL_OPTIMIZATION
   The flag, that indicates the optimization process
   
   MQL_VISUAL_MODE
   The flag, that indicates the visual tester process
*/
   if((MQLInfoInteger(MQL_PROFILER) || MQLInfoInteger(MQL_TESTER) || 
      MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_VISUAL_MODE)) && !IsPositionExists())
     {
      m_trade.Buy(m_symbol.LotsMin(),m_symbol.Name());
      m_trade.Sell(m_symbol.LotsMin(),m_symbol.Name());
     }
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
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=false,   // highlight to move 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- if the price is not set, set it at the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
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
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="HLine", // line name 
               double       price=0)      // line price 
  {
//--- if the line price is not set, move it to the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete a horizontal line                                         | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="HLine") // line name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete a horizontal line 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Is position exists                                               |
//+------------------------------------------------------------------+
bool IsPositionExists(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
