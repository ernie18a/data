//+---------------------------------------------------------------------+
//|                                Trailing Only with Button Close All  |
//|                              Copyright © 2022, risyadi noor         |
//|                                                                     |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2022, risyadi noor"
#property link      "#"
#property version   "1.0"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
CMoneyFixedMargin *m_money;
CArrayLong     m_arr_tickets;// array tickets

//--- input parameters
enum ENUM_CLOSE_MODE
  { 
   CLOSE_MODE_POSITIONS,     // Open Orders Only
   CLOSE_MODE_ALL,           // Open and Pending Orders
   CLOSE_MODE_ORDERS         // Pending Orders Only
  };
enum ENUM_CLOSE_SYMBOL
  {
   CLOSE_SYMBOL_CHART,        // Current Chart Symbol
   CLOSE_SYMBOL_ALL         // All Symbols
  };
enum ENUM_CLOSE_PROFIT
  {
   CLOSE_PROFIT_ALL,         // All
   CLOSE_PROFIT_PROFITONLY,  // Close Profit Only
   CLOSE_PROFIT_LOSSONLY     // Close Losing Only
  };
  
input uint              RTOTAL         = 5;                // Retries
input uint              SLEEPTIME      = 500;             // Sleep Time (msec)
input bool              InpAsyncMode   = true;             // Asynchronous Mode
input bool              InpDisAlgo     = false;            // Disable AlgoTrading Button
 
//--- input parameters
input ENUM_CLOSE_MODE   InpCloseMode   = CLOSE_MODE_POSITIONS;   // Type
input ENUM_CLOSE_SYMBOL InpCloseSymbol = CLOSE_SYMBOL_CHART; // Symbols
input ENUM_CLOSE_PROFIT InpCloseProfit = CLOSE_PROFIT_PROFITONLY; // Profit / Loss

input double   InpLots           = 0.01; //Lots
input ulong   InpStopLoss       = 500;  //Stop Loss (1.00045-1.00055=1 pips/XAUUSD is x100)
input ulong   InpTakeProfit     = 1000; //Take Profit (1.00045-1.00055=1 pips/XAUUSD is x100)
input ulong   InpTrailingStop   = 200;  //Trail Stop (min distance from price to Stop Loss/XAUUSD x100)
input ulong   InpTrailingStep   = 50;   //Trail Step (1.00045-1.00055=1 pips /XAUUSD x100)

double ExtStopLoss=0.0;
double ExtTakeProfit=0.0;
double ExtTrailingStop=0.0;
double ExtTrailingStep=0.0;
double m_adjusted_point;                     // point value adjusted for 3 or 5 points

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(InpTrailingStop!=0 && InpTrailingStep==0)
     {
      string err_text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                      "Trailing Step!":
                      "Trailing is not possible: parameter \"Trailing Step\" is zero!";
      //--- when testing, we will only output to the log about incorrect input parameters
      if(MQLInfoInteger(MQL_TESTER))
        {
         Print(__FUNCTION__,", ERROR: ",err_text);
         return(INIT_FAILED);
        }
      else // if the Expert Advisor is run on the chart, tell the user about the error
        {
         Alert(__FUNCTION__,", ERROR: ",err_text);
         return(INIT_PARAMETERS_INCORRECT);
        }
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStopLoss       = InpStopLoss        * m_adjusted_point;
   ExtTakeProfit     = InpTakeProfit      * m_adjusted_point;
   ExtTrailingStop   = InpTrailingStop    * m_adjusted_point;
   ExtTrailingStep   = InpTrailingStep    * m_adjusted_point;
   
   
   // Button Create
   ObjectCreate(0,"CLOSEALL",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"CLOSEALL",OBJPROP_XDISTANCE,350);       // distance from border
   ObjectSetInteger(0,"CLOSEALL",OBJPROP_XSIZE,200);           // width
   ObjectSetInteger(0,"CLOSEALL",OBJPROP_YDISTANCE,50);       // distance from border
   ObjectSetInteger(0,"CLOSEALL",OBJPROP_YSIZE,50);            // height
   ObjectSetInteger(0,"CLOSEALL",OBJPROP_CORNER,0);            // chart corner
   ObjectSetString(0,"CLOSEALL",OBJPROP_TEXT,"Close All");         // label
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      ObjectDelete(0,"CLOSEALL");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  /*
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
   if(!RefreshRates())
     {
      PrevBars=0;
      return;
     }
   */  
   Trailing();

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
//| Trailing                                                         |
//|   InpTrailingStop: min distance from price to Stop Loss          |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(InpTrailingStop==0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() )//&& m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               // Set SL if 0
               if(m_position.StopLoss()==0 || m_position.TakeProfit()==0)
               {
                  m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceOpen()-ExtStopLoss),
                        m_position.PriceOpen()+ExtTakeProfit);
               }
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
               {
                  if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     
                     
                     //RefreshRates();
                     m_position.SelectByIndex(i);
                     PrintResultModify(m_trade,m_symbol,m_position);
                     continue;
                    }
                 }
              }
            else
              {
               // Set SL if 0
               if(m_position.StopLoss()==0 || m_position.TakeProfit()==0)
               {
                  m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceOpen()+ExtStopLoss),
                        m_position.PriceOpen()-ExtTakeProfit);
               }
               double open;
               double current;
               open = m_position.PriceOpen();
               current = m_position.PriceCurrent();
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
               {
                  if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) || 
                     (m_position.StopLoss()==0))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     //RefreshRates();
                     m_position.SelectByIndex(i);
                     PrintResultModify(m_trade,m_symbol,m_position);
                    }
                }
              }

           }
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultModify(CTrade &trade,CSymbolInfo &symbol,CPositionInfo &position)
  {
   Print("File: ",__FILE__,", symbol: ",m_symbol.Name());
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
   Print("Price of position opening: "+DoubleToString(position.PriceOpen(),symbol.Digits()));
   Print("Price of position's Stop Loss: "+DoubleToString(position.StopLoss(),symbol.Digits()));
   Print("Price of position's Take Profit: "+DoubleToString(position.TakeProfit(),symbol.Digits()));
   Print("Current price by position: "+DoubleToString(position.PriceCurrent(),symbol.Digits()));
  }
 //+------------------------------------------------------------------+
 // BUTTON ACTION CLOSE 
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   MqlTradeResult result;
   MqlTradeRequest request;
   ZeroMemory(request);
   ZeroMemory(result);

   if(ObjectGetInteger(0,"CLOSEALL",OBJPROP_STATE)!=0)
     {
      ObjectSetInteger(0,"CLOSEALL",OBJPROP_STATE,0);
      ClosePositions();
      return;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| FUNCTION CLOSE ALL                                               |
//+------------------------------------------------------------------+
void ClosePositions()
  {
//---
   for(uint retry=0; retry<RTOTAL && !IsStopped(); retry++)
     {
      bool result = true;
      //--- Collect and Close Method (FIFO-Compliant, for US brokers)
      //--- Tickets are processed starting with the oldest one.
      m_arr_tickets.Shutdown();
      for(int i=0; i<PositionsTotal() && !IsStopped(); i++)
        {
         ResetLastError();
         if(!m_position.SelectByIndex(i))
           {
            PrintFormat("> Error: selecting position with index #%d failed. Error Code: %d",i,GetLastError());
            result = false;
            continue;
           }
         if(InpCloseSymbol==CLOSE_SYMBOL_CHART && m_position.Symbol()!=Symbol())
           {
            continue;
           }
         if(InpCloseProfit==CLOSE_PROFIT_PROFITONLY && (m_position.Swap()+m_position.Profit()<=0))
           {
            continue;
           }
         if(InpCloseProfit==CLOSE_PROFIT_LOSSONLY && (m_position.Swap()+m_position.Profit()>=0))
           {
            continue;
           }
         //--- build array of position tickets to be processed
         if(!m_arr_tickets.Add(m_position.Ticket()))
           {
            PrintFormat("> Error: adding position ticket #%I64u failed.",m_position.Ticket());
            result = false;
           }
        }

      //--- now process the list of tickets stored in the array
      for(int i=0; i<m_arr_tickets.Total() && !IsStopped(); i++)
        {
         ResetLastError();
         ulong m_curr_ticket = m_arr_tickets.At(i);
         if(!m_position.SelectByTicket(m_curr_ticket))
           {
            PrintFormat("> Error: selecting position ticket #%I64u failed. Error Code: %d",m_curr_ticket,GetLastError());
            result = false;
            continue;
           }
         //--- check freeze level
         int freeze_level = (int)SymbolInfoInteger(m_position.Symbol(),SYMBOL_TRADE_FREEZE_LEVEL);
         double point = SymbolInfoDouble(m_position.Symbol(),SYMBOL_POINT);
         bool TP_check = (MathAbs(m_position.PriceCurrent() - m_position.TakeProfit()) > freeze_level * point);
         bool SL_check = (MathAbs(m_position.PriceCurrent() - m_position.StopLoss()) > freeze_level * point);
         if(!TP_check || !SL_check)
           {
            PrintFormat("> Error: closing position ticket #%I64u on %s is prohibited. Position TP or SL is too close to activation price.",m_position.Ticket(),m_position.Symbol());
            result = false;
            continue;
           }
         //--- trading object
         m_trade.SetExpertMagicNumber(m_position.Magic());
         m_trade.SetTypeFillingBySymbol(m_position.Symbol());
         //--- close positions
         if(m_trade.PositionClose(m_position.Ticket()) && (m_trade.ResultRetcode()==TRADE_RETCODE_DONE || m_trade.ResultRetcode()==TRADE_RETCODE_PLACED))
           {
            PrintFormat("Position ticket #%I64u on %s to be closed.",m_position.Ticket(),m_position.Symbol());
            //PlaySound("expert.wav");
           }
         else
           {
            PrintFormat("> Error: closing position ticket #%I64u on %s failed. Retcode=%u (%s)",m_position.Ticket(),m_position.Symbol(),m_trade.ResultRetcode(),m_trade.ResultComment());
            result = false;
           }
        }

      if(result)
         break;
      Sleep(SLEEPTIME);
      //PlaySound("timeout.wav");
     }
  }