//+------------------------------------------------------------------+
//|                                                    Close-All.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "9.300"
#property description "A script to close all market positions and/or pending orders."
#property script_show_inputs
//---
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Arrays\ArrayLong.mqh>
//---
CTrade         trade;        // trading object
CPositionInfo  position;     // position info object
COrderInfo     order;        // order info object
CArrayLong     arr_tickets;  // array tickets
//---
enum ENUM_CLOSE_MODE
  {
   CLOSE_MODE_ALL,           // Positions and Pending Orders
   CLOSE_MODE_POSITIONS,     // Positions Only
   CLOSE_MODE_ORDERS         // Pending Orders
  };
enum ENUM_CLOSE_SYMBOL
  {
   CLOSE_SYMBOL_ALL,         // All Symbols
   CLOSE_SYMBOL_CHART        // Current Chart Symbol
  };
enum ENUM_CLOSE_PROFIT
  {
   CLOSE_PROFIT_ALL,         // All Profitable and Losing Positions
   CLOSE_PROFIT_PROFITONLY,  // Profitable Positions Only
   CLOSE_PROFIT_LOSSONLY     // Losing Positions Only
  };
enum ENUM_CLOSE_TYPE
  {
   CLOSE_TYPE_ALL,           // All Buy and Sell Positions
   CLOSE_TYPE_BUY,           // Buy Positions Only
   CLOSE_TYPE_SELL           // Sell Positions Only
  };
enum ENUM_CLOSE_ORDERS
  {
   CLOSE_ORDERS_ALL,         // All Order Types
   CLOSE_ORDERS_LIMIT,       // Limit Orders Only
   CLOSE_ORDERS_STOP,        // Stop Orders Only
   CLOSE_ORDERS_STOPLIMIT    // Stop Limit Orders Only
  };
//--- input parameters
input ENUM_CLOSE_MODE   InpCloseMode   = CLOSE_MODE_ALL;   // Mode
input ENUM_CLOSE_SYMBOL InpCloseSymbol = CLOSE_SYMBOL_ALL; // Symbols
input ENUM_CLOSE_PROFIT InpCloseProfit = CLOSE_PROFIT_ALL; // Profit / Loss
input ENUM_CLOSE_TYPE   InpCloseType   = CLOSE_TYPE_ALL;   // Buy / Sell
input ENUM_CLOSE_ORDERS InpCloseOrders = CLOSE_ORDERS_ALL; // Pending Orders
input string            xx2;                               // ============
input uint              RTOTAL         = 5;                // Retries
input uint              SLEEPTIME      = 1000;             // Sleep Time (msec)
input bool              InpAsyncMode   = true;             // Asynchronous Mode
input bool              InpDisAlgo     = false;            // Disable AlgoTrading Button
//+------------------------------------------------------------------+
//| script start function                                            |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- preliminary checks for trading functions
   if(CheckTradingPermission()==false)
     {
      return;
     }
//--- initialize common information
   trade.SetDeviationInPoints(INT_MAX);
   trade.SetAsyncMode(InpAsyncMode);
   trade.SetMarginMode();
   trade.LogLevel(LOG_LEVEL_ERRORS);

//--- close positions and/or delete pending orders
   switch((ENUM_CLOSE_MODE)InpCloseMode)
     {
      case CLOSE_MODE_ALL:
         ClosePositions();
         DeletePendingOrders();
         break;

      case CLOSE_MODE_POSITIONS:
         ClosePositions();
         break;

      case CLOSE_MODE_ORDERS:
         DeletePendingOrders();
         break;
     }

//--- disable the 'algo-trading' button
   if(InpDisAlgo)
     {
      AlgoTradingStatus(false);
     }
  }
//+------------------------------------------------------------------+
//| Check for permission to perform automated trading                |
//+------------------------------------------------------------------+
bool CheckTradingPermission()
  {
   if(!MQLInfoInteger(MQL_TESTER))
     {
      //--- Terminal - internet connection
      if(!TerminalInfoInteger(TERMINAL_CONNECTED))
        {
         Alert("Error: No connection to the trade server!");
         return(false);
        }
      //--- Account - server connection
      if(!AccountInfoInteger(ACCOUNT_LOGIN))
        {
         Alert("Error: Trade information is not downloaded (not connected).");
         return(false);
        }
      //--- Terminal - Checking for permission to perform automated trading in the terminal
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
        {
         Alert("Error: Automated trading is not allowed in the terminal settings, or 'Algo Trading' button is disabled.");
         return(false);
        }
      //--- Expert - Checking if trading is allowed for a certain running Expert Advisor/script
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Error: Live trading is not allowed in the program properties of '", MQLInfoString(MQL_PROGRAM_NAME), "'");
         return(false);
        }
      //---
      if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
        {
         Alert("Error: Trading is not allowed for the account ", AccountInfoInteger(ACCOUNT_LOGIN), " [investor mode].");
         return(false);
        }
      //---
      if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
        {
         Alert("Error: Expert advisors are not allowed for the account ", AccountInfoInteger(ACCOUNT_LOGIN), " at the trade server.");
         return(false);
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Checks if the market is currently open for the specified symbol  |
//+------------------------------------------------------------------+
bool CheckSessionTrade(const string symbol)
  {
   MqlDateTime STime;
   datetime time = TimeTradeServer(STime);
   datetime time_sec = time % PeriodSeconds(PERIOD_D1);
//---
   datetime from,to;
   uint session_index=0;
   while(SymbolInfoSessionTrade(symbol,(ENUM_DAY_OF_WEEK)STime.day_of_week,session_index++,from,to))
      if(time_sec >=from && time_sec <= to)
         return true;
//---
   return false;
  }
//+------------------------------------------------------------------+
//| Close market positions                                           |
//+------------------------------------------------------------------+
void ClosePositions()
  {
//---
   for(uint retry=0; retry<RTOTAL && !IsStopped(); retry++)
     {
      bool result = true;
      //--- Collect and Close Method (FIFO-Compliant, for US brokers)
      //--- Tickets are processed starting with the oldest one.
      arr_tickets.Shutdown();
      for(int i=0; i<PositionsTotal() && !IsStopped(); i++)
        {
         ResetLastError();
         if(!position.SelectByIndex(i))
           {
            PrintFormat("> Error: selecting position with index #%d failed. Error Code: %d",i,GetLastError());
            result = false;
            continue;
           }
         if(InpCloseSymbol==CLOSE_SYMBOL_CHART && position.Symbol()!=Symbol())
           {
            continue;
           }
         if(InpCloseProfit==CLOSE_PROFIT_PROFITONLY && (position.Swap()+position.Profit()<=0))
           {
            continue;
           }
         if(InpCloseProfit==CLOSE_PROFIT_LOSSONLY && (position.Swap()+position.Profit()>=0))
           {
            continue;
           }
         if(InpCloseType==CLOSE_TYPE_BUY && position.PositionType()!=POSITION_TYPE_BUY)
           {
            continue;
           }
         if(InpCloseType==CLOSE_TYPE_SELL && position.PositionType()!=POSITION_TYPE_SELL)
           {
            continue;
           }
         //--- build array of position tickets to be processed
         if(!arr_tickets.Add(position.Ticket()))
           {
            PrintFormat("> Error: adding position ticket #%I64u failed.",position.Ticket());
            result = false;
           }
        }

      //--- now process the list of tickets stored in the array
      for(int i=0; i<arr_tickets.Total() && !IsStopped(); i++)
        {
         ResetLastError();
         ulong curr_ticket = arr_tickets.At(i);
         if(!position.SelectByTicket(curr_ticket))
           {
            PrintFormat("> Error: selecting position ticket #%I64u failed. Error Code: %d",curr_ticket,GetLastError());
            result = false;
            continue;
           }
         //--- check trading session
         if(!CheckSessionTrade(position.Symbol()))
           {
            PrintFormat("> Error: closing position ticket #%I64u on %s is prohibited [Market closed].",position.Ticket(),position.Symbol());
            continue;
           }
         //--- check freeze level
         int freeze_level = (int)SymbolInfoInteger(position.Symbol(),SYMBOL_TRADE_FREEZE_LEVEL);
         double point = SymbolInfoDouble(position.Symbol(),SYMBOL_POINT);
         bool TP_check = MathAbs(position.PriceCurrent() - position.TakeProfit()) > freeze_level * point;
         bool SL_check = MathAbs(position.PriceCurrent() - position.StopLoss()) > freeze_level * point;
         if(!TP_check || !SL_check)
           {
            PrintFormat("> Error: closing position ticket #%I64u on %s is prohibited. Position TP or SL is too close to activation price [FROZEN].",position.Ticket(),position.Symbol());
            result = false;
            continue;
           }
         //--- trading object
         trade.SetExpertMagicNumber(position.Magic());
         trade.SetTypeFillingBySymbol(position.Symbol());
         //--- close positions
         if(trade.PositionClose(position.Ticket()) && (trade.ResultRetcode()==TRADE_RETCODE_DONE || trade.ResultRetcode()==TRADE_RETCODE_PLACED))
           {
            PrintFormat("Position ticket #%I64u on %s to be closed.",position.Ticket(),position.Symbol());
            PlaySound("expert.wav");
           }
         else
           {
            PrintFormat("> Error: closing position ticket #%I64u on %s failed. Retcode=%u (%s)",position.Ticket(),position.Symbol(),trade.ResultRetcode(),trade.ResultComment());
            result = false;
           }
        }

      if(result)
         break;
      Sleep(SLEEPTIME);
      PlaySound("timeout.wav");
     }
  }
//+------------------------------------------------------------------+
//| Delete pending orders                                            |
//+------------------------------------------------------------------+
void DeletePendingOrders()
  {
//---
   for(uint retry=0; retry<RTOTAL && !IsStopped(); retry++)
     {
      bool result = true;
      //--- Collect and Close Method (FIFO-Compliant, for US brokers)
      //--- Tickets are processed starting with the oldest one.
      arr_tickets.Shutdown();
      for(int i=0; i<OrdersTotal() && !IsStopped(); i++)
        {
         ResetLastError();
         if(!order.SelectByIndex(i))
           {
            PrintFormat("> Error: selecting order with index #%d failed. Error Code: %d",i,GetLastError());
            result = false;
            continue;
           }
         if(InpCloseSymbol==CLOSE_SYMBOL_CHART && order.Symbol()!=Symbol())
           {
            continue;
           }
         if(InpCloseOrders==CLOSE_ORDERS_LIMIT && order.OrderType()!=ORDER_TYPE_BUY_LIMIT && order.OrderType()!=ORDER_TYPE_SELL_LIMIT)
           {
            continue;
           }
         if(InpCloseOrders==CLOSE_ORDERS_STOP && order.OrderType()!=ORDER_TYPE_BUY_STOP && order.OrderType()!=ORDER_TYPE_SELL_STOP)
           {
            continue;
           }
         if(InpCloseOrders==CLOSE_ORDERS_STOPLIMIT && order.OrderType()!=ORDER_TYPE_BUY_STOP_LIMIT && order.OrderType()!=ORDER_TYPE_SELL_STOP_LIMIT)
           {
            continue;
           }
         //--- build array of order tickets to be processed
         if(!arr_tickets.Add(order.Ticket()))
           {
            PrintFormat("> Error: adding order ticket #%I64u failed.",order.Ticket());
            result = false;
           }
        }

      //--- now process the list of tickets stored in the array
      for(int i=0; i<arr_tickets.Total() && !IsStopped(); i++)
        {
         ResetLastError();
         ulong curr_ticket = arr_tickets.At(i);
         if(!order.Select(curr_ticket))
           {
            PrintFormat("> Error: selecting order ticket #%I64u failed. Error Code: %d",curr_ticket,GetLastError());
            result = false;
            continue;
           }
         //--- check trading session
         if(!CheckSessionTrade(order.Symbol()))
           {
            PrintFormat("> Error: deleting order ticket #%I64u on %s is prohibited [Market closed].",order.Ticket(),order.Symbol());
            continue;
           }
         //--- check freeze level
         int freeze_level = (int)SymbolInfoInteger(order.Symbol(),SYMBOL_TRADE_FREEZE_LEVEL);
         double point = SymbolInfoDouble(order.Symbol(),SYMBOL_POINT);
         bool activ_check = MathAbs(order.PriceCurrent() - order.PriceOpen()) > freeze_level * point;
         if(!activ_check)
           {
            PrintFormat("> Error: deleting order ticket #%I64u on %s is prohibited. Order open price is too close to activation price [FROZEN].",order.Ticket(),order.Symbol());
            result = false;
            continue;
           }
         //--- delete orders
         if(trade.OrderDelete(order.Ticket()) && (trade.ResultRetcode()==TRADE_RETCODE_DONE || trade.ResultRetcode()==TRADE_RETCODE_PLACED))
           {
            PrintFormat("Order ticket #%I64u on %s to be deleted.",order.Ticket(),order.Symbol());
            PlaySound("expert.wav");
           }
         else
           {
            PrintFormat("> Error: deleting order ticket #%I64u on %s failed. Retcode=%u (%s)",order.Ticket(),order.Symbol(),trade.ResultRetcode(),trade.ResultComment());
            result = false;
           }
        }

      if(result)
         break;
      Sleep(SLEEPTIME);
      PlaySound("timeout.wav");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define MT_WMCMD_EXPERTS   32851
#define WM_COMMAND 0x0111
#define GA_ROOT    2
#include <WinAPI\winapi.mqh>
//+------------------------------------------------------------------+
//| Toggle auto-trading button                                       |
//+------------------------------------------------------------------+
void AlgoTradingStatus(bool Enable)
  {
   bool Status = (bool) TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);

   if(Enable != Status)
     {
      HANDLE hChart = (HANDLE) ChartGetInteger(ChartID(), CHART_WINDOW_HANDLE);
      PostMessageW(GetAncestor(hChart, GA_ROOT), WM_COMMAND, MT_WMCMD_EXPERTS, 0);
     }
  }
//+------------------------------------------------------------------+
