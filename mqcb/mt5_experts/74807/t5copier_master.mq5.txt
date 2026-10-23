//+------------------------------------------------------------------+
//|                                              T5Copier_Master.mq5 |
//|                        Copyright 2026, Amarnath Kondiyan Mohan . |
//|     https://www.linkedin.com/in/amarnath-kondiyan-mohan-546293a/ |
//+------------------------------------------------------------------+
#property copyright "Amarnath Kondiyan Mohan"
#property link      "https://www.linkedin.com/in/amarnath-kondiyan-mohan-546293a/"
#property version   "1.00"

//--- Input Parameters
input string InpServerAddr = "127.0.0.1";           // Go Bridge TCP IP
input int    InpServerPort = 5580;                  // Go Bridge TCP Port
input int    InpPollIntervalMs = 100;                // Position polling interval in milliseconds

//--- Global Variables
int socket_handle = INVALID_HANDLE;

// Cache structure to track active positions in MT5
struct PositionCache
  {
   ulong             ticket;
   string            symbol;
   int               type;
   double            lots;
   double            openPrice;
   double            sl;
   double            tp;
   long              magic;
  };

PositionCache ExtCache[];
int           ExtCacheSize = 0;

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
         Print("Master Copier (MT5): Socket creation failed. Error: ", GetLastError());
         last_connect_error = TimeCurrent();
        }
      return;
     }
     
   if(!SocketConnect(socket_handle, InpServerAddr, InpServerPort, 1000))
     {
      if(TimeCurrent() - last_connect_error > 10)
        {
         Print("Master Copier (MT5): Socket connection failed. Error: ", GetLastError());
         last_connect_error = TimeCurrent();
        }
      SocketClose(socket_handle);
      socket_handle = INVALID_HANDLE;
      return;
     }
     
   // Send registration handshake
   string handshake = "ROLE|MASTER\n";
   uchar buf[];
   StringToCharArray(handshake, buf);
   int sent = SocketSend(socket_handle, buf, ArraySize(buf) - 1);
   if(sent <= 0)
     {
      Print("Master Copier (MT5): Handshake send failed.");
      SocketClose(socket_handle);
      socket_handle = INVALID_HANDLE;
      return;
     }
     
   Print("Master Copier (MT5): Connected to Go TCP Bridge on ", InpServerAddr, ":", InpServerPort);
  }

//+------------------------------------------------------------------+
//| Send Socket Message Helper                                       |
//+------------------------------------------------------------------+
bool SendSocketMessage(string msg)
  {
   if(MQLInfoInteger(MQL_TESTER)) return(false);

   ConnectSocket();
   if(socket_handle == INVALID_HANDLE || !SocketIsConnected(socket_handle))
     {
      return(false);
     }
     
   string line = msg + "\n";
   uchar buf[];
   StringToCharArray(line, buf);
   int sent = SocketSend(socket_handle, buf, ArraySize(buf) - 1);
   if(sent <= 0)
     {
      Print("Master Copier (MT5): Socket send failed, closing connection.");
      SocketClose(socket_handle);
      socket_handle = INVALID_HANDLE;
      return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(MQLInfoInteger(MQL_TESTER))
     {
      Print("Master Copier (MT5): Running in Strategy Tester. Disabling socket operations.");
      return(INIT_SUCCEEDED);
     }

   Print("Master Copier (MT5): Initializing native TCP socket...");
   ConnectSocket();

   // Initialize Cache with currently open positions
   SyncCacheOnStartup();

   EventSetMillisecondTimer(InpPollIntervalMs);
   Print("Master Copier (MT5): Initialized. Polling active every ", InpPollIntervalMs, "ms.");
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
   Print("Master Copier (MT5): Deinitialized.");
  }

//+------------------------------------------------------------------+
//| Expert timer function                                            |
//+------------------------------------------------------------------+
void OnTimer()
  {
   PollAndSyncPositions();
  }

//+------------------------------------------------------------------+
//| Sync Cache on Startup to avoid copying historical trades         |
//+------------------------------------------------------------------+
void SyncCacheOnStartup()
  {
   ArrayFree(ExtCache);
   ExtCacheSize = 0;

   int total = PositionsTotal();
   for(int i = 0; i < total; i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
        {
         int type = (int)PositionGetInteger(POSITION_TYPE);

         ExtCacheSize++;
         ArrayResize(ExtCache, ExtCacheSize);
         int idx = ExtCacheSize - 1;
         ExtCache[idx].ticket    = ticket;
         ExtCache[idx].symbol    = PositionGetString(POSITION_SYMBOL);
         ExtCache[idx].type      = type;
         ExtCache[idx].lots      = PositionGetDouble(POSITION_VOLUME);
         ExtCache[idx].openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         ExtCache[idx].sl        = PositionGetDouble(POSITION_SL);
         ExtCache[idx].tp        = PositionGetDouble(POSITION_TP);
         ExtCache[idx].magic     = PositionGetInteger(POSITION_MAGIC);

         PrintFormat("Master Copier (MT5): Cached existing trade %d (%s, %s, %.2f lots)",
                     ticket, ExtCache[idx].symbol, type == POSITION_TYPE_BUY ? "BUY" : "SELL", ExtCache[idx].lots);
        }
     }
  }

//+------------------------------------------------------------------+
//| Poll active MT5 positions and broadcast changes                 |
//+------------------------------------------------------------------+
void PollAndSyncPositions()
  {
   // 1. Gather all currently open positions
   int currentTotal = PositionsTotal();
   ulong currentTickets[];
   int currentCount = 0;

   for(int i = 0; i < currentTotal; i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
        {
         int type = (int)PositionGetInteger(POSITION_TYPE);

         currentCount++;
         ArrayResize(currentTickets, currentCount);
         currentTickets[currentCount - 1] = ticket;

         // Check if this ticket is in our cache
         int cacheIdx = FindCacheIndex(ticket);
         if(cacheIdx == -1)
           {
            // NEW POSITION! Open detected.
            BroadcastOpen(ticket);

            // Add to cache
            ExtCacheSize++;
            ArrayResize(ExtCache, ExtCacheSize);
            int idx = ExtCacheSize - 1;
            ExtCache[idx].ticket    = ticket;
            ExtCache[idx].symbol    = PositionGetString(POSITION_SYMBOL);
            ExtCache[idx].type      = type;
            ExtCache[idx].lots      = PositionGetDouble(POSITION_VOLUME);
            ExtCache[idx].openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            ExtCache[idx].sl        = PositionGetDouble(POSITION_SL);
            ExtCache[idx].tp        = PositionGetDouble(POSITION_TP);
            ExtCache[idx].magic     = PositionGetInteger(POSITION_MAGIC);
           }
         else
           {
            // EXISTING POSITION: Check for modification
            double lots = PositionGetDouble(POSITION_VOLUME);
            double sl   = PositionGetDouble(POSITION_SL);
            double tp   = PositionGetDouble(POSITION_TP);

            if(lots != ExtCache[cacheIdx].lots || sl != ExtCache[cacheIdx].sl || tp != ExtCache[cacheIdx].tp)
              {
               BroadcastModify(ticket, lots, sl, tp);
               ExtCache[cacheIdx].lots = lots;
               ExtCache[cacheIdx].sl   = sl;
               ExtCache[cacheIdx].tp   = tp;
              }
           }
        }
     }

   // 2. Identify closed positions
   for(int i = ExtCacheSize - 1; i >= 0; i--)
     {
      ulong cachedTicket = ExtCache[i].ticket;
      if(!ContainsTicket(currentTickets, cachedTicket))
        {
         // CLOSED POSITION!
         BroadcastClose(cachedTicket);

         // Remove from cache
         RemoveFromCache(i);
        }
     }
  }

//+------------------------------------------------------------------+
//| Find index of a ticket in cache                                  |
//+------------------------------------------------------------------+
int FindCacheIndex(ulong ticket)
  {
   for(int i = 0; i < ExtCacheSize; i++)
     {
      if(ExtCache[i].ticket == ticket)
         return(i);
     }
   return(-1);
  }

//+------------------------------------------------------------------+
//| Helper to check if array contains a ticket                       |
//+------------------------------------------------------------------+
bool ContainsTicket(ulong &arr[], ulong ticket)
  {
   int size = ArraySize(arr);
   for(int i = 0; i < size; i++)
     {
      if(arr[i] == ticket)
         return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Remove element from cache array                                  |
//+------------------------------------------------------------------+
void RemoveFromCache(int idx)
  {
   if(idx < 0 || idx >= ExtCacheSize)
      return;
   for(int i = idx; i < ExtCacheSize - 1; i++)
     {
      ExtCache[i] = ExtCache[i + 1];
     }
   ExtCacheSize--;
   ArrayResize(ExtCache, ExtCacheSize);
  }

//+------------------------------------------------------------------+
//| Broadcast position OPEN event                                    |
//+------------------------------------------------------------------+
void BroadcastOpen(ulong ticket)
  {
   if(!PositionSelectByTicket(ticket))
      return;

   // Format: OPEN|ticket|symbol|type|lots|price|sl|tp|magic
   string msg = StringFormat("OPEN|%d|%s|%d|%.2f|%.5f|%.5f|%.5f|%d",
                             ticket, PositionGetString(POSITION_SYMBOL), PositionGetInteger(POSITION_TYPE),
                             PositionGetDouble(POSITION_VOLUME), PositionGetDouble(POSITION_PRICE_OPEN), PositionGetDouble(POSITION_SL),
                             PositionGetDouble(POSITION_TP), PositionGetInteger(POSITION_MAGIC));

   if(SendSocketMessage(msg))
     {
      Print("Master Copier (MT5): Broadcast OPEN for trade ", ticket);
     }
  }

//+------------------------------------------------------------------+
//| Broadcast position MODIFY event                                  |
//+------------------------------------------------------------------+
void BroadcastModify(ulong ticket, double lots, double sl, double tp)
  {
   // Format: MODIFY|ticket|lots|sl|tp
   string msg = StringFormat("MODIFY|%d|%.2f|%.5f|%.5f", ticket, lots, sl, tp);
   if(SendSocketMessage(msg))
     {
      PrintFormat("Master Copier (MT5): Broadcast MODIFY for trade %d (lots=%.2f, sl=%.5f, tp=%.5f)", ticket, lots, sl, tp);
     }
  }

//+------------------------------------------------------------------+
//| Broadcast position CLOSE event                                   |
//+------------------------------------------------------------------+
void BroadcastClose(ulong ticket)
  {
   // Format: CLOSE|ticket
   string msg = StringFormat("CLOSE|%d", ticket);
   if(SendSocketMessage(msg))
     {
      Print("Master Copier (MT5): Broadcast CLOSE for trade ", ticket);
     }
  }
//+------------------------------------------------------------------+
