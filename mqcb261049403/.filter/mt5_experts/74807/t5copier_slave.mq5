//+------------------------------------------------------------------+
//|                                               T5Copier_Slave.mq5 |
//|                        Copyright 2026, Amarnath Kondiyan Mohan . |
//|     https://www.linkedin.com/in/amarnath-kondiyan-mohan-546293a/ |
//+------------------------------------------------------------------+
#property copyright "Amarnath Kondiyan Mohan"
#property link      "https://www.linkedin.com/in/amarnath-kondiyan-mohan-546293a/"
#property version   "1.00"

#include <Trade/Trade.mqh>

//--- Copy Modes
enum ENUM_LOT_MODE
  {
   LOT_MODE_FULL = 0,    // Full Copy (Match Master Lots)
   LOT_MODE_RATIO = 1,   // Ratio Copy (Multiplier)
   LOT_MODE_FIXED = 2    // Fixed Lot Size
  };

//--- Input Parameters
input string         InpBackendAddr      = "127.0.0.1";            // Go Bridge TCP IP
input int            InpBackendPort      = 5580;                   // Go Bridge TCP Port
input ENUM_LOT_MODE  InpLotMode          = LOT_MODE_FULL;          // Copy Mode
input double         InpLotMultiplier    = 1.0;                    // Lot Multiplier (For Ratio Mode)
input double         InpFixedLotSize     = 0.1;                    // Lot Size (For Fixed Mode)
input bool           InpReverseCopy      = false;                  // Reverse Copying (BUY <--> SELL)
input ulong          InpSlippage         = 3;                      // Slippage in points
input int            InpMaxSpreadPoints  = 50;                     // Max allowed spread (in points) to open trade
input ulong          InpMagicNumber      = 654321;                 // Magic Number for local orders

//--- Global Variables
int      socket_handle = INVALID_HANDLE;
string   socket_buffer = "";
CTrade   trade;

//+------------------------------------------------------------------+
//| Connect/Reconnect TCP Socket                                     |
//+------------------------------------------------------------------+
void ConnectSocket()
  {
   if(MQLInfoInteger(MQL_TESTER)) return;

   if(socket_handle != INVALID_HANDLE)
     {
      if(SocketIsConnected(socket_handle)) return;
      SocketClose(socket_handle);
     }

   static datetime last_connect_error = 0;
   socket_handle = SocketCreate();
   if(socket_handle == INVALID_HANDLE)
     {
      if(TimeCurrent() - last_connect_error > 10)
        {
         Print("Slave Copier (MT5): Socket creation failed. Error: ", GetLastError());
         last_connect_error = TimeCurrent();
        }
      return;
     }

   if(!SocketConnect(socket_handle, InpBackendAddr, InpBackendPort, 1000))
     {
      if(TimeCurrent() - last_connect_error > 10)
        {
         Print("Slave Copier (MT5): Socket connection failed. Error: ", GetLastError());
         last_connect_error = TimeCurrent();
        }
      SocketClose(socket_handle);
      socket_handle = INVALID_HANDLE;
      return;
     }

   // Send registration handshake
   string handshake = "ROLE|SLAVE\n";
   uchar buf[];
   StringToCharArray(handshake, buf);
   int sent = SocketSend(socket_handle, buf, ArraySize(buf) - 1);
   if(sent <= 0)
     {
      Print("Slave Copier (MT5): Handshake send failed.");
      SocketClose(socket_handle);
      socket_handle = INVALID_HANDLE;
      return;
     }

   Print("Slave Copier (MT5): Connected to Go TCP Bridge on ", InpBackendAddr, ":", InpBackendPort);
  }

//+------------------------------------------------------------------+
//| Read Socket Events                                               |
//+------------------------------------------------------------------+
void ReadSocketEvents()
  {
   if(MQLInfoInteger(MQL_TESTER)) return;

   if(socket_handle == INVALID_HANDLE || !SocketIsConnected(socket_handle))
     {
      ConnectSocket();
      return;
     }

   if(!SocketIsReadable(socket_handle)) return;

   uchar buf[1024];
   int read_len = SocketRead(socket_handle, buf, 1024, 10);
   if(read_len <= 0)
     {
      Print("Slave Copier (MT5): Connection lost, closing socket.");
      SocketClose(socket_handle);
      socket_handle = INVALID_HANDLE;
      return;
     }

   string received = CharArrayToString(buf, 0, read_len);
   socket_buffer += received;

   // Process complete newline-delimited lines
   int idx;
   while((idx = StringFind(socket_buffer, "\n")) >= 0)
     {
      string line = StringSubstr(socket_buffer, 0, idx);
      socket_buffer = StringSubstr(socket_buffer, idx + 1);
      
      StringTrimLeft(line);
      StringTrimRight(line);
      if(line != "")
        {
         ProcessEvent(line);
        }
     }
  }

//+------------------------------------------------------------------+
//| Parse and execute copier events                                  |
//+------------------------------------------------------------------+
void ProcessEvent(string eventStr)
  {
   string parts[];
   int count = StringSplit(eventStr, '|', parts);
   if(count < 2)
      return;

   string action = parts[0];
   ulong masterTicket = (ulong)StringToInteger(parts[1]);

   if(action == "OPEN")
     {
      if(count < 9)
         return;
      string symbol      = parts[2];
      int masterType     = (int)StringToInteger(parts[3]);
      double masterLots  = StringToDouble(parts[4]);
      double masterPrice = StringToDouble(parts[5]);
      double masterSL    = StringToDouble(parts[6]);
      double masterTP    = StringToDouble(parts[7]);

      HandleOpen(masterTicket, symbol, masterType, masterLots, masterPrice, masterSL, masterTP);
     }
   else if(action == "MODIFY")
     {
      if(count < 5)
         return;
      double masterLots = StringToDouble(parts[2]);
      double masterSL   = StringToDouble(parts[3]);
      double masterTP   = StringToDouble(parts[4]);

      HandleModify(masterTicket, masterLots, masterSL, masterTP);
     }
   else if(action == "CLOSE")
     {
      HandleClose(masterTicket);
     }
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(MQLInfoInteger(MQL_TESTER))
     {
      Print("Slave Copier (MT5): Running in Strategy Tester. Disabling socket operations.");
      return(INIT_SUCCEEDED);
     }

   Print("Slave Copier (MT5): Initializing native TCP socket...");
   ConnectSocket();

   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippage);

   EventSetMillisecondTimer(10); // Polling every 10ms
   Print("Slave Copier (MT5): Initialized. Polling active.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(socket_handle != INVALID_HANDLE)
     {
      SocketClose(socket_handle);
      socket_handle = INVALID_HANDLE;
     }
   Print("Slave Copier (MT5): Deinitialized.");
  }

//+------------------------------------------------------------------+
//| Expert timer function                                            |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ReadSocketEvents();
  }

//+------------------------------------------------------------------+
//| Execute OPEN command                                             |
//+------------------------------------------------------------------+
void HandleOpen(ulong masterTicket, string symbol, int masterType, double masterLots, double masterPrice, double masterSL, double masterTP)
  {
   string gvName = StringFormat("Copier_Map_%d", masterTicket);
   if(gvCheckAndMap(masterTicket))
     {
      return;
     }

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

   if(bid <= 0.0 || ask <= 0.0)
     {
      PrintFormat("Slave Copier (MT5): Symbol %s is not available.", symbol);
      return;
     }

   // Max Spread check
   double spread = (ask - bid) / point;
   if(spread > InpMaxSpreadPoints)
     {
      PrintFormat("Slave Copier (MT5): Spread %.1f exceeds limit %d.", spread, InpMaxSpreadPoints);
      return;
     }

   // Determine Lot Size
   double lots = 0.1;
   if(InpLotMode == LOT_MODE_FULL)
      lots = masterLots;
   else if(InpLotMode == LOT_MODE_RATIO)
      lots = NormalizeDouble(masterLots * InpLotMultiplier, 2);
   else if(InpLotMode == LOT_MODE_FIXED)
      lots = InpFixedLotSize;

   double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

   if(lots < minLot) lots = minLot;
   if(lots > maxLot) lots = maxLot;
   lots = NormalizeDouble(MathRound(lots / lotStep) * lotStep, 2);

   ENUM_POSITION_TYPE localType = (masterType == 0) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
   double entryPrice = 0.0;
   double stopLoss = 0.0;
   double takeProfit = 0.0;

   if(!InpReverseCopy)
     {
      entryPrice = (localType == POSITION_TYPE_BUY) ? ask : bid;
      if(masterSL > 0) stopLoss = entryPrice + (masterSL - masterPrice);
      if(masterTP > 0) takeProfit = entryPrice + (masterTP - masterPrice);
     }
   else
     {
      localType = (localType == POSITION_TYPE_BUY) ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
      entryPrice = (localType == POSITION_TYPE_BUY) ? ask : bid;
      if(masterSL > 0) stopLoss = entryPrice - (masterSL - masterPrice);
      if(masterTP > 0) takeProfit = entryPrice - (masterTP - masterPrice);
     }

   bool success = false;
   if(localType == POSITION_TYPE_BUY)
      success = trade.Buy(lots, symbol, entryPrice, stopLoss, takeProfit, StringFormat("Copied:%d", masterTicket));
   else
      success = trade.Sell(lots, symbol, entryPrice, stopLoss, takeProfit, StringFormat("Copied:%d", masterTicket));

   if(!success)
     {
      PrintFormat("Slave Copier (MT5): Trade failed. Code: %d", trade.ResultRetcode());
     }
   else
     {
      ulong localTicket = trade.ResultDeal();
      if(localTicket == 0) localTicket = trade.ResultOrder();
      GlobalVariableSet(gvName, (double)localTicket);
      PrintFormat("Slave Copier (MT5): Master trade %d copied as %d", masterTicket, localTicket);
     }
  }

//+------------------------------------------------------------------+
//| Check if GlobalVariable or Cache already maps this trade        |
//+------------------------------------------------------------------+
bool gvCheckAndMap(ulong masterTicket)
  {
   string gvName = StringFormat("Copier_Map_%d", masterTicket);
   if(GlobalVariableCheck(gvName)) return(true);

   // Sync with existing positions by comment match
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong posTicket = PositionGetTicket(i);
      if(posTicket > 0)
        {
         if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
           {
            string expectedComment = StringFormat("Copied:%d", masterTicket);
            if(PositionGetString(POSITION_COMMENT) == expectedComment)
              {
               GlobalVariableSet(gvName, (double)posTicket);
               return(true);
              }
           }
        }
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Execute MODIFY command                                           |
//+------------------------------------------------------------------+
void HandleModify(ulong masterTicket, double masterLots, double masterSL, double masterTP)
  {
   string gvName = StringFormat("Copier_Map_%d", masterTicket);
   if(!GlobalVariableCheck(gvName)) return;

   ulong localTicket = (ulong)GlobalVariableGet(gvName);
   if(!PositionSelectByTicket(localTicket)) return;

   string symbol = PositionGetString(POSITION_SYMBOL);
   double entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   double stopLoss = 0.0;
   double takeProfit = 0.0;

   if(!InpReverseCopy)
     {
      stopLoss = masterSL;
      takeProfit = masterTP;
     }
   else
     {
      if(masterSL > 0) stopLoss = entryPrice - (masterSL - entryPrice);
      if(masterTP > 0) takeProfit = entryPrice - (masterTP - entryPrice);
     }

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   stopLoss = NormalizeDouble(stopLoss, digits);
   takeProfit = NormalizeDouble(takeProfit, digits);

   if(stopLoss != PositionGetDouble(POSITION_SL) || takeProfit != PositionGetDouble(POSITION_TP))
     {
      trade.PositionModify(localTicket, stopLoss, takeProfit);
     }

   double currentLots = PositionGetDouble(POSITION_VOLUME);
   if(InpLotMode == LOT_MODE_FULL || InpLotMode == LOT_MODE_RATIO)
     {
      double expectedLots = masterLots;
      if(InpLotMode == LOT_MODE_RATIO)
         expectedLots = NormalizeDouble(masterLots * InpLotMultiplier, 2);

      if(expectedLots < currentLots)
        {
         double closeLots = NormalizeDouble(currentLots - expectedLots, 2);
         if(closeLots > 0.0 && closeLots < currentLots)
           {
            trade.PositionClosePartial(localTicket, closeLots);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Execute CLOSE command                                            |
//+------------------------------------------------------------------+
void HandleClose(ulong masterTicket)
  {
   string gvName = StringFormat("Copier_Map_%d", masterTicket);
   if(!GlobalVariableCheck(gvName)) return;

   ulong localTicket = (ulong)GlobalVariableGet(gvName);
   if(!PositionSelectByTicket(localTicket))
     {
      GlobalVariableDel(gvName);
      return;
     }

   if(trade.PositionClose(localTicket))
     {
      GlobalVariableDel(gvName);
     }
  }
//+------------------------------------------------------------------+
