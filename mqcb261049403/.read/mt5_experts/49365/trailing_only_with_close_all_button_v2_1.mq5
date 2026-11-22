//+----------------------------------------------------------------------+
//|                                Trailing Only with Button Close All V2|
//|                              Copyright © 2024, risyadi noor          |
//|                                                                      |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2022, risyadi noor"
#property link      "#"
#property version   "2.0"
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
enum ENUM_CLOSE_SYMBOL
  {
   CLOSE_SYMBOL_CHART,        // Current Chart Symbol
   CLOSE_SYMBOL_ALL         // All Symbols
  };

  
input uint              RTOTAL         = 5;                // Retries
input uint              SLEEPTIME      = 500;             // Sleep Time (msec)
input bool              InpAsyncMode   = true;             // Asynchronous Mode
input bool              InpDisAlgo     = false;            // Disable AlgoTrading Button

//--- input parameters
input ENUM_CLOSE_SYMBOL InpCloseSymbol = CLOSE_SYMBOL_CHART; // Symbols

input ulong   InpStopLoss       = 500;  //Stop Loss (1.00045-1.00055=1 pips/XAUUSD is x100)
input ulong   InpTakeProfit     = 1000; //Take Profit (1.00045-1.00055=1 pips/XAUUSD is x100)
input ulong   InpTrailingStop   = 200;  //Trail Stop (min distance from price to Stop Loss/XAUUSD x100)
input ulong   InpTrailingStep   = 50;   //Trail Step (1.00045-1.00055=1 pips /XAUUSD x100)

input double closeProfitThreshold = 500.0; //CLOSE IF PROFIT-fill with Above 0 (1.0)
input double closeLossThreshold = 0.0;  //CLOSE IF LOSS-fill with Below 0 (minus : -1.0)


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
  
  
  // Button for closing all positions
   ObjectCreate(0, "CLOSEALL", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "CLOSEALL", OBJPROP_XDISTANCE, 400);    // X position
   ObjectSetInteger(0, "CLOSEALL", OBJPROP_XSIZE, 150);        // width
   ObjectSetInteger(0, "CLOSEALL", OBJPROP_YDISTANCE, 50);    // Y position
   ObjectSetInteger(0, "CLOSEALL", OBJPROP_YSIZE, 50);        // height
   ObjectSetInteger(0, "CLOSEALL", OBJPROP_CORNER, 0);        // chart corner
   ObjectSetString(0, "CLOSEALL", OBJPROP_TEXT, "Close All"); // label
   
   // Button Create - Close Profitable
   ObjectCreate(0, "CLOSEPROFITABLE", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "CLOSEPROFITABLE", OBJPROP_XDISTANCE, 600);    // X position
   ObjectSetInteger(0, "CLOSEPROFITABLE", OBJPROP_XSIZE, 150);        // width
   ObjectSetInteger(0, "CLOSEPROFITABLE", OBJPROP_YDISTANCE, 50);    // Y position
   ObjectSetInteger(0, "CLOSEPROFITABLE", OBJPROP_YSIZE, 50);        // height
   ObjectSetInteger(0, "CLOSEPROFITABLE", OBJPROP_CORNER, 0);        // chart corner
   ObjectSetString(0, "CLOSEPROFITABLE", OBJPROP_TEXT, "Close Profit"); // label
   // Set color for Close Profit button (green)
   ObjectSetInteger(0, "CLOSEPROFITABLE", OBJPROP_COLOR, clrGreen);
    
   // Button Create - Close Losing
   ObjectCreate(0, "CLOSELOSING", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "CLOSELOSING", OBJPROP_XDISTANCE, 800);    // X position
   ObjectSetInteger(0, "CLOSELOSING", OBJPROP_XSIZE, 150);        // width
   ObjectSetInteger(0, "CLOSELOSING", OBJPROP_YDISTANCE, 50);    // Y position
   ObjectSetInteger(0, "CLOSELOSING", OBJPROP_YSIZE, 50);        // height
   ObjectSetInteger(0, "CLOSELOSING", OBJPROP_CORNER, 0);        // chart corner
   ObjectSetString(0, "CLOSELOSING", OBJPROP_TEXT, "Close Losing"); // label
   // Set color for Close Loss button (red)
   ObjectSetInteger(0, "CLOSELOSING", OBJPROP_COLOR, clrRed);

// Button Create - Close BUY
   ObjectCreate(0, "CLOSEBUY", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "CLOSEBUY", OBJPROP_XDISTANCE, 1000);    // X position
   ObjectSetInteger(0, "CLOSEBUY", OBJPROP_XSIZE, 150);        // width
   ObjectSetInteger(0, "CLOSEBUY", OBJPROP_YDISTANCE, 50);    // Y position
   ObjectSetInteger(0, "CLOSEBUY", OBJPROP_YSIZE, 50);        // height
   ObjectSetInteger(0, "CLOSEBUY", OBJPROP_CORNER, 0);        // chart corner
   ObjectSetString(0, "CLOSEBUY", OBJPROP_TEXT, "Close BUY"); // label
   ObjectSetInteger(0, "CLOSEBUY", OBJPROP_COLOR, clrDodgerBlue);

   // Button Create - Close SELL
   ObjectCreate(0, "CLOSESELL", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "CLOSESELL", OBJPROP_XDISTANCE, 1200);    // X position
   ObjectSetInteger(0, "CLOSESELL", OBJPROP_XSIZE, 150);        // width
   ObjectSetInteger(0, "CLOSESELL", OBJPROP_YDISTANCE, 50);    // Y position
   ObjectSetInteger(0, "CLOSESELL", OBJPROP_YSIZE, 50);        // height
   ObjectSetInteger(0, "CLOSESELL", OBJPROP_CORNER, 0);        // chart corner
   ObjectSetString(0, "CLOSESELL", OBJPROP_TEXT, "Close SELL"); // label
   ObjectSetInteger(0, "CLOSESELL", OBJPROP_COLOR, clrOrangeRed);

  
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
      ObjectDelete(0,"CLOSEPROFITABLE");
      ObjectDelete(0,"CLOSELOSING");
      ObjectDelete(0,"CLOSEBUY");
      ObjectDelete(0,"CLOSESELL");
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
   
   if (closeProfitThreshold > 0 || closeLossThreshold < 0)
    {
        double totalProfit = CalculateTotalProfit();
        double totalLoss = CalculateTotalLoss();
        if ((closeProfitThreshold > 0 && totalProfit >= closeProfitThreshold) || (closeLossThreshold < 0 && totalLoss <= closeLossThreshold))
        {
            CloseAllPositions();
        }
    }
    
   Trailing();

  }
  
 // Function to calculate the total profit of all open positions
double CalculateTotalProfit()
{
    double totalProfit = 0.0;
    for (int i = 0; i < PositionsTotal(); i++)
    {
        if (m_position.SelectByIndex(i))
        {
            totalProfit += m_position.Profit();
        }
    }
    return totalProfit;
}

// Function to calculate the total loss of all open positions
double CalculateTotalLoss()
{
    double totalLoss = 0.0;
    for (int i = 0; i < PositionsTotal(); i++)
    {
        if (m_position.SelectByIndex(i))
        {
            totalLoss += m_position.Profit();
        }
    }
    return totalLoss;
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
// BUTTON CLICKED
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   MqlTradeResult result;
   MqlTradeRequest request;
   ZeroMemory(request);
   ZeroMemory(result);

   if(ObjectGetInteger(0,"CLOSEALL",OBJPROP_STATE)!=0)
   {
      ObjectSetInteger(0,"CLOSEALL",OBJPROP_STATE,0);
      CloseAllPositions();
      return;
   }
   else if(ObjectGetInteger(0,"CLOSEPROFITABLE",OBJPROP_STATE)!=0)
   {
      ObjectSetInteger(0,"CLOSEPROFITABLE",OBJPROP_STATE,0);
      CloseProfitPositions();
      return;
   }
   else if(ObjectGetInteger(0,"CLOSELOSING",OBJPROP_STATE)!=0)
   {
      ObjectSetInteger(0,"CLOSELOSING",OBJPROP_STATE,0);
      CloseLossPositions();
      return;
   }
   else if(ObjectGetInteger(0,"CLOSEBUY",OBJPROP_STATE)!=0)
   {
      ObjectSetInteger(0,"CLOSEBUY",OBJPROP_STATE,0);
      CloseBuyPositions();
      return;
   }
   else if(ObjectGetInteger(0,"CLOSESELL",OBJPROP_STATE)!=0)
   {
      ObjectSetInteger(0,"CLOSESELL",OBJPROP_STATE,0);
      CloseSellPositions();
      return;
   }
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| FUNCTION CLOSE ALL                                               |
//+------------------------------------------------------------------+
// Close all positions
void CloseAllPositions()
{
    for(uint retry = 0; retry < RTOTAL && !IsStopped(); retry++)
    {
        for(int i = PositionsTotal() - 1; i >= 0 && !IsStopped(); i--)
        {
            if(m_position.SelectByIndex(i))
            {
                // Close position
                ClosePosition(m_position.Ticket());
            }
        }
        Sleep(SLEEPTIME);
    }
}

// Close only profitable positions
void CloseProfitPositions()
{
    for(uint retry = 0; retry < RTOTAL && !IsStopped(); retry++)
    {
        for(int i = PositionsTotal() - 1; i >= 0 && !IsStopped(); i--)
        {
            if(m_position.SelectByIndex(i) && (m_position.Swap() + m_position.Profit() > 0))
            {
                // Close position
                ClosePosition(m_position.Ticket());
            }
        }
        Sleep(SLEEPTIME);
    }
}

// Close only losing positions
void CloseLossPositions()
{
    for(uint retry = 0; retry < RTOTAL && !IsStopped(); retry++)
    {
        for(int i = PositionsTotal() - 1; i >= 0 && !IsStopped(); i--)
        {
            if(m_position.SelectByIndex(i) && (m_position.Swap() + m_position.Profit() < 0))
            {
                // Close position
                ClosePosition(m_position.Ticket());
            }
        }
        Sleep(SLEEPTIME);
    }
}

// Close a single position by ticket
void ClosePosition(ulong ticket)
{
    ResetLastError();
    if(m_position.SelectByTicket(ticket))
    {
        // Check freeze level
        int freeze_level = (int)SymbolInfoInteger(m_position.Symbol(), SYMBOL_TRADE_FREEZE_LEVEL);
        double point = SymbolInfoDouble(m_position.Symbol(), SYMBOL_POINT);
        bool TP_check = (MathAbs(m_position.PriceCurrent() - m_position.TakeProfit()) > freeze_level * point);
        bool SL_check = (MathAbs(m_position.PriceCurrent() - m_position.StopLoss()) > freeze_level * point);

        if(TP_check && SL_check)
        {
            // Close position
            if(m_trade.PositionClose(ticket))
            {
                PrintFormat("Position ticket #%I64u on %s has been closed.", ticket, m_position.Symbol());
            }
            else
            {
                PrintFormat("> Error: closing position ticket #%I64u on %s failed. Retcode=%u (%s)", ticket, m_position.Symbol(), m_trade.ResultRetcode(), m_trade.ResultComment());
            }
        }
        else
        {
            PrintFormat("> Error: closing position ticket #%I64u on %s is prohibited. Position TP or SL is too close to activation price.", ticket, m_position.Symbol());
        }
    }
}

// Close only BUY positions
void CloseBuyPositions()
{
    for(uint retry = 0; retry < RTOTAL && !IsStopped(); retry++)
    {
        for(int i = PositionsTotal() - 1; i >= 0 && !IsStopped(); i--)
        {
            if(m_position.SelectByIndex(i) && m_position.PositionType()==POSITION_TYPE_BUY)
            {
                ClosePosition(m_position.Ticket());
            }
        }
        Sleep(SLEEPTIME);
    }
}

// Close only SELL positions
void CloseSellPositions()
{
    for(uint retry = 0; retry < RTOTAL && !IsStopped(); retry++)
    {
        for(int i = PositionsTotal() - 1; i >= 0 && !IsStopped(); i--)
        {
            if(m_position.SelectByIndex(i) && m_position.PositionType()==POSITION_TYPE_SELL)
            {
                ClosePosition(m_position.Ticket());
            }
        }
        Sleep(SLEEPTIME);
    }
}

