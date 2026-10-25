//+------------------------------------------------------------------+
//|                                                    GridCore.mqh  |
//|                      BGC Grid Trading EA — Grid Engine           |
//|                      Bi-directional: buy+sell at every level     |
//+------------------------------------------------------------------+
#property copyright "Muhammad Minhas Qamar - MMQ"
#property strict

#ifndef __GRID_CORE_MQH__
#define __GRID_CORE_MQH__

#include "Defines.mqh"
#include "LotEngine.mqh"
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| CGridCore — grid initialisation, re-arming, and position mgmt   |
//+------------------------------------------------------------------+
class CGridCore
{
private:
   CTrade            m_trade;
   CLotEngine       *m_lotEngine;
   string            m_symbol;
   int               m_magic;
   int               m_digits;
   double            m_gridSpacing;    // cached grid spacing in price
   bool              m_buyBiasAboveAnchor; // BGT: skip sell orders above anchor (buy-biased instrument)
   int               m_ghostArmCount;     // counter for ticket=0 margin rejects (ghost arms)
   double            m_minFreeMargin;     // minimum free margin to place new orders (0=disabled)

   //--- Check if broker order limit reached (0 = no limit)
   bool IsOrderLimitReached()
   {
      int maxOrders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
      if(maxOrders > 0 && OrdersTotal() + PositionsTotal() >= maxOrders)
         return true;
      return false;
   }

   //--- Place a buy pending order at a level with TP
   bool PlaceBuyOrder(GridLevel &level)
   {
      if(IsOrderLimitReached()) return false;
      double price = level.price;
      double ask   = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
      double tp    = NormalizeDouble(price + m_gridSpacing, m_digits);
      double stopsLevel = SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL)
                          * SymbolInfoDouble(m_symbol, SYMBOL_POINT);

      if(price > ask)
      {
         //--- Level above ask → Buy Stop
         if(price - ask < stopsLevel) return false;


         if(m_trade.BuyStop(level.lotSize, price, m_symbol, 0, tp, ORDER_TIME_GTC, 0, EA_COMMENT))
         {
            level.buyPendingTicket = m_trade.ResultOrder();
            if(level.buyPendingTicket == 0)
            {
               m_ghostArmCount++;
               PrintFormat("[BGC Grid] BuyStop returned success but no ticket was recorded at level %d, lot=%.2f",
                           level.levelIndex, level.lotSize);
               return false;
            }
            level.buyArmed = true;
            return true;
         }
      }
      else
      {
         //--- Level below or at ask → Buy Limit
         if(ask - price < stopsLevel) return false;


         if(m_trade.BuyLimit(level.lotSize, price, m_symbol, 0, tp, ORDER_TIME_GTC, 0, EA_COMMENT))
         {
            level.buyPendingTicket = m_trade.ResultOrder();
            if(level.buyPendingTicket == 0)
            {
               m_ghostArmCount++;
               PrintFormat("[BGC Grid] BuyLimit returned success but no ticket was recorded at level %d, lot=%.2f",
                           level.levelIndex, level.lotSize);
               return false;
            }
            level.buyArmed = true;
            return true;
         }
      }

      PrintFormat("[BGC Grid] Failed to place Buy order at %.5f, level %d, lot=%.2f, error %d",
                  price, level.levelIndex, level.lotSize, GetLastError());
      return false;
   }

   //--- Place a sell pending order at a level with TP
   bool PlaceSellOrder(GridLevel &level)
   {
      if(IsOrderLimitReached()) return false;
      double price = level.price;
      double bid   = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      double tp    = NormalizeDouble(price - m_gridSpacing, m_digits);
      double stopsLevel = SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL)
                          * SymbolInfoDouble(m_symbol, SYMBOL_POINT);

      if(price < bid)
      {
         //--- Level below bid → Sell Stop
         if(bid - price < stopsLevel) return false;


         if(m_trade.SellStop(level.lotSize, price, m_symbol, 0, tp, ORDER_TIME_GTC, 0, EA_COMMENT))
         {
            level.sellPendingTicket = m_trade.ResultOrder();
            if(level.sellPendingTicket == 0)
            {
               m_ghostArmCount++;
               PrintFormat("[BGC Grid] SellStop returned success but no ticket was recorded at level %d, lot=%.2f",
                           level.levelIndex, level.lotSize);
               return false;
            }
            level.sellArmed = true;
            return true;
         }
      }
      else
      {
         //--- Level above or at bid → Sell Limit
         if(price - bid < stopsLevel) return false;


         if(m_trade.SellLimit(level.lotSize, price, m_symbol, 0, tp, ORDER_TIME_GTC, 0, EA_COMMENT))
         {
            level.sellPendingTicket = m_trade.ResultOrder();
            if(level.sellPendingTicket == 0)
            {
               m_ghostArmCount++;
               PrintFormat("[BGC Grid] SellLimit returned success but no ticket was recorded at level %d, lot=%.2f",
                           level.levelIndex, level.lotSize);
               return false;
            }
            level.sellArmed = true;
            return true;
         }
      }

      PrintFormat("[BGC Grid] Failed to place Sell order at %.5f, level %d, lot=%.2f, error %d",
                  price, level.levelIndex, level.lotSize, GetLastError());
      return false;
   }

   //--- Place a buy pending order at a level WITHOUT TP (for TGT basket close)
   bool PlaceBuyOrderNoTP(GridLevel &level)
   {
      if(IsOrderLimitReached()) return false;
      double price = level.price;
      double ask   = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
      double stopsLevel = SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL)
                          * SymbolInfoDouble(m_symbol, SYMBOL_POINT);

      if(price > ask)
      {
         if(price - ask < stopsLevel) return false;

         if(m_trade.BuyStop(level.lotSize, price, m_symbol, 0, 0, ORDER_TIME_GTC, 0, EA_COMMENT))
         {
            level.buyPendingTicket = m_trade.ResultOrder();
            if(level.buyPendingTicket == 0) return false;
            level.buyArmed = true;
            return true;
         }
      }
      else
      {
         if(ask - price < stopsLevel) return false;

         if(m_trade.BuyLimit(level.lotSize, price, m_symbol, 0, 0, ORDER_TIME_GTC, 0, EA_COMMENT))
         {
            level.buyPendingTicket = m_trade.ResultOrder();
            if(level.buyPendingTicket == 0) return false;
            level.buyArmed = true;
            return true;
         }
      }
      return false;
   }

   //--- Place a sell pending order at a level WITHOUT TP (for TGT basket close)
   bool PlaceSellOrderNoTP(GridLevel &level)
   {
      if(IsOrderLimitReached()) return false;
      double price = level.price;
      double bid   = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      double stopsLevel = SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL)
                          * SymbolInfoDouble(m_symbol, SYMBOL_POINT);

      if(price < bid)
      {
         if(bid - price < stopsLevel) return false;

         if(m_trade.SellStop(level.lotSize, price, m_symbol, 0, 0, ORDER_TIME_GTC, 0, EA_COMMENT))
         {
            level.sellPendingTicket = m_trade.ResultOrder();
            if(level.sellPendingTicket == 0) return false;
            level.sellArmed = true;
            return true;
         }
      }
      else
      {
         if(price - bid < stopsLevel) return false;

         if(m_trade.SellLimit(level.lotSize, price, m_symbol, 0, 0, ORDER_TIME_GTC, 0, EA_COMMENT))
         {
            level.sellPendingTicket = m_trade.ResultOrder();
            if(level.sellPendingTicket == 0) return false;
            level.sellArmed = true;
            return true;
         }
      }
      return false;
   }

   //--- BGT: Place both buy and sell at a level (bi-directional, original behavior)
   //    When m_buyBiasAboveAnchor is true, skip sells above anchor (levelIndex > 0)
   //    — assumes instrument has persistent upward bias, so above-anchor sells fight the trend.
   void PlaceLevelBGT(GridLevel &level)
   {
      if(!level.buyArmed && !level.buyOpen && !level.buyFilled)
         PlaceBuyOrder(level);
      if(m_buyBiasAboveAnchor && level.levelIndex > 0)
         return;
      if(!level.sellArmed && !level.sellOpen && !level.sellFilled)
         PlaceSellOrder(level);
   }

   //--- TGT: Stop orders in trend direction only, NO per-trade TP (basket close)
   //    Uptrend (+1): BUY_STOP at levels above anchor only
   //    Downtrend (-1): SELL_STOP at levels below anchor only
   void PlaceLevelTGT(GridLevel &level, int trendDir)
   {
      if(trendDir > 0 && level.levelIndex > 0)
      {
         //--- Uptrend: buy stops above anchor
         if(!level.buyArmed && !level.buyOpen && !level.buyFilled)
            PlaceBuyOrderNoTP(level);
      }
      else if(trendDir < 0 && level.levelIndex < 0)
      {
         //--- Downtrend: sell stops below anchor
         if(!level.sellArmed && !level.sellOpen && !level.sellFilled)
            PlaceSellOrderNoTP(level);
      }
   }

   //--- MGT: Limit orders only, counter-trend, fixed TP toward origin
   //    Above anchor: SELL_LIMIT only (counter-trend short), TP toward origin
   //    Below anchor: BUY_LIMIT only (counter-trend long), TP toward origin
   void PlaceLevelMGT(GridLevel &level)
   {
      if(level.levelIndex > 0)
      {
         //--- Above anchor: sell limit (counter-trend), TP = price - spacing
         if(!level.sellArmed && !level.sellOpen && !level.sellFilled)
            PlaceSellOrder(level);  // TP already set toward anchor (price - spacing)
      }
      else if(level.levelIndex < 0)
      {
         //--- Below anchor: buy limit (counter-trend), TP = price + spacing
         if(!level.buyArmed && !level.buyOpen && !level.buyFilled)
            PlaceBuyOrder(level);  // TP already set toward anchor (price + spacing)
      }
   }

   //--- Mode-dispatched level placement
   void PlaceLevel(GridLevel &level, ENUM_GRID_MODE mode = GRID_MODE_BGT, int trendDir = 0)
   {
      //--- Global free margin gate: skip all order placement when margin is thin
      if(m_minFreeMargin > 0 && AccountInfoDouble(ACCOUNT_MARGIN_FREE) < m_minFreeMargin)
         return;

      switch(mode)
      {
         case GRID_MODE_TGT: PlaceLevelTGT(level, trendDir); break;
         case GRID_MODE_MGT: PlaceLevelMGT(level);            break;
         default:            PlaceLevelBGT(level);             break;
      }
   }

   //--- Check if a pending order still exists
   bool OrderExists(ulong ticket)
   {
      if(ticket == 0) return false;
      return OrderSelect(ticket);
   }

   //--- Check if a position still exists
   bool PositionExists(ulong ticket)
   {
      if(ticket == 0) return false;
      return PositionSelectByTicket(ticket);
   }

   //--- Find the position that resulted from a filled pending order
   ulong FindPositionFromFilledOrder(ulong orderTicket)
   {
      if(orderTicket == 0) return 0;

      HistorySelect(0, TimeCurrent());

      if(HistoryOrderSelect(orderTicket))
      {
         long posId = HistoryOrderGetInteger(orderTicket, ORDER_POSITION_ID);
         if(posId > 0)
         {
            if(PositionSelectByTicket((ulong)posId))
               return (ulong)posId;
         }
      }

      return 0;
   }

   //--- Find an open position by magic, symbol, type and price proximity
   ulong FindPositionByLevel(double levelPrice, ENUM_POSITION_TYPE posType)
   {
      double tolerance = m_gridSpacing * 0.5;
      double gridPoint = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      if(tolerance <= 0) tolerance = 50 * gridPoint;

      int total = PositionsTotal();
      for(int i = 0; i < total; i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != m_magic) continue;
         if(PositionGetString(POSITION_SYMBOL) != m_symbol) continue;
         if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != posType) continue;

         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         if(MathAbs(openPrice - levelPrice) <= tolerance)
            return ticket;
      }
      return 0;
   }

   //--- Check if a pending order is within the freeze zone (too close to cancel)
   bool IsOrderFrozen(ulong ticket)
   {
      if(!OrderSelect(ticket)) return true;  // can't select → treat as frozen (don't attempt delete)
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
      double freezeLevel = SymbolInfoInteger(m_symbol, SYMBOL_TRADE_FREEZE_LEVEL)
                           * SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      double stopsLevel  = SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL)
                           * SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      double minDist = MathMax(freezeLevel, stopsLevel);

      //--- For buy orders, distance from ask; for sell orders, distance from bid
      ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      double dist;
      if(type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP)
         dist = MathAbs(orderPrice - ask);
      else
         dist = MathAbs(orderPrice - bid);

      return (dist < minDist);
   }

   //--- Cancel all pending (unfilled) orders across the grid to free margin.
   //    Clears armed flags so levels can be re-armed when margin recovers.
   //    Skips orders in the freeze zone (too close to market price to cancel).
   void CancelAllPendingOrders(GridSession &session)
   {
      int total = session.LevelCount();
      int cancelled = 0;
      for(int i = 0; i < total; i++)
      {
         if(session.levels[i].buyArmed && session.levels[i].buyPendingTicket > 0
            && OrderExists(session.levels[i].buyPendingTicket)
            && !IsOrderFrozen(session.levels[i].buyPendingTicket))
         {
            if(m_trade.OrderDelete(session.levels[i].buyPendingTicket))
            {
               session.levels[i].buyArmed = false;
               session.levels[i].buyPendingTicket = 0;
               cancelled++;
            }
         }
         if(session.levels[i].sellArmed && session.levels[i].sellPendingTicket > 0
            && OrderExists(session.levels[i].sellPendingTicket)
            && !IsOrderFrozen(session.levels[i].sellPendingTicket))
         {
            if(m_trade.OrderDelete(session.levels[i].sellPendingTicket))
            {
               session.levels[i].sellArmed = false;
               session.levels[i].sellPendingTicket = 0;
               cancelled++;
            }
         }
      }
      if(cancelled > 0)
         PrintFormat("[BGC Grid] Low margin guard: cancelled %d pending orders (FreeMargin=$%.2f < $%.2f)",
                     cancelled, AccountInfoDouble(ACCOUNT_MARGIN_FREE), m_minFreeMargin);
   }

public:
   //--- Initialise the grid core
   void Init(string symbol, int magic, int slippage, CLotEngine *lotEngine, double gridSpacing = 0,
             bool buyBiasAboveAnchor = false, double minFreeMargin = 0)
   {
      m_symbol              = symbol;
      m_magic               = magic;
      m_lotEngine           = lotEngine;
      m_gridSpacing         = gridSpacing;
      m_buyBiasAboveAnchor  = buyBiasAboveAnchor;
      m_ghostArmCount       = 0;
      m_minFreeMargin       = minFreeMargin;
      m_digits              = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

      m_trade.SetExpertMagicNumber(magic);
      m_trade.SetDeviationInPoints(slippage);

      //--- Detect best fill mode (prefer IOC for partial fill support)
      long fillMode = SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);
      if((fillMode & SYMBOL_FILLING_IOC) != 0)
         m_trade.SetTypeFilling(ORDER_FILLING_IOC);
      else if((fillMode & SYMBOL_FILLING_FOK) != 0)
         m_trade.SetTypeFilling(ORDER_FILLING_FOK);
      else
         m_trade.SetTypeFilling(ORDER_FILLING_RETURN);

      m_trade.SetAsyncMode(false);
   }

   //--- Set grid spacing dynamically (for ATR-dynamic spacing)
   void SetGridSpacing(double spacing) { m_gridSpacing = spacing; }

   //--- Ghost arm (ticket=0 / margin reject) counter
   int  GetGhostArmCount() const { return m_ghostArmCount; }
   int  ConsumeGhostArmCount()   { int c = m_ghostArmCount; m_ghostArmCount = 0; return c; }

   //--- Initialise a new grid around anchor price
   void InitGrid(GridSession &session, double ruinProximity = 0.0)
   {
      int total = session.LevelCount();

      //--- Compute lot sizes for all levels
      m_lotEngine.ComputeAllLots(session.levels, total, ruinProximity);

      //--- Place orders at every level using session's grid mode
      for(int i = 0; i < total; i++)
         PlaceLevel(session.levels[i], session.gridMode, session.trendDirection);

      string modeStr = "BGT";
      if(session.gridMode == GRID_MODE_TGT) modeStr = "TGT";
      else if(session.gridMode == GRID_MODE_MGT) modeStr = "MGT";

      PrintFormat("[BGC Grid] Grid ready [%s]: Anchor=%.5f, Levels=%d per side, "
                  "Spacing=%.5f, TrendDir=%d",
                  modeStr, session.anchorPrice, session.totalLevels,
                  session.gridSpacing, session.trendDirection);
   }

   //--- Synchronise level state with actual orders/positions
   void SyncLevelState(GridLevel &level)
   {
      //--- Check buy pending order
      if(level.buyArmed && level.buyPendingTicket > 0)
      {
         if(!OrderExists(level.buyPendingTicket))
         {
            level.buyArmed = false;

            ulong posTicket = FindPositionFromFilledOrder(level.buyPendingTicket);

            if(posTicket == 0 && PositionExists(level.buyPendingTicket))
               posTicket = level.buyPendingTicket;

            if(posTicket == 0)
               posTicket = FindPositionByLevel(level.price, POSITION_TYPE_BUY);

            if(posTicket > 0)
            {
               level.buyTicket = posTicket;
               level.buyOpen   = true;
            }
            level.buyFilled        = true;
            level.buyPendingTicket = 0;
         }
      }

      //--- Check buy position (may have been closed by TP)
      if(level.buyOpen && level.buyTicket > 0)
      {
         if(!PositionExists(level.buyTicket))
         {
            level.buyOpen   = false;
            level.buyTicket = 0;
            level.buyFilled = false;  // position gone, level can be re-armed
         }
      }

      //--- Check sell pending order
      if(level.sellArmed && level.sellPendingTicket > 0)
      {
         if(!OrderExists(level.sellPendingTicket))
         {
            level.sellArmed = false;

            ulong posTicket = FindPositionFromFilledOrder(level.sellPendingTicket);

            if(posTicket == 0 && PositionExists(level.sellPendingTicket))
               posTicket = level.sellPendingTicket;

            if(posTicket == 0)
               posTicket = FindPositionByLevel(level.price, POSITION_TYPE_SELL);

            if(posTicket > 0)
            {
               level.sellTicket = posTicket;
               level.sellOpen   = true;
            }
            level.sellFilled        = true;
            level.sellPendingTicket = 0;
         }
      }

      //--- Check sell position (may have been closed by TP)
      if(level.sellOpen && level.sellTicket > 0)
      {
         if(!PositionExists(level.sellTicket))
         {
            level.sellOpen    = false;
            level.sellTicket  = 0;
            level.sellFilled  = false;  // position gone, level can be re-armed
         }
      }

   }

   //--- Sync all levels and optionally re-arm — unified method ensures TP detection
   //    works correctly by snapshotting state before sync in the same pass.
   //    allowRearm: when false (PAUSED), sync runs but no new orders are placed.
   //    Returns number of TP closures detected.
   int SyncAndRearm(GridSession &session, double ruinProximity, double maxSpread,
                     bool recomputeLots = false, bool allowRearm = true)
   {
      double bid    = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      double ask    = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
      double spread = (ask - bid) / SymbolInfoDouble(m_symbol, SYMBOL_POINT);

      int total = session.LevelCount();
      int tpClosures = 0;

      //--- Low margin guard: if free margin is below threshold, cancel all pending
      //    orders to prevent "not enough money" errors when they try to fill.
      //    Also suppresses re-arming — no new orders until margin recovers.
      bool lowMargin = (m_minFreeMargin > 0
                        && AccountInfoDouble(ACCOUNT_MARGIN_FREE) < m_minFreeMargin);
      if(lowMargin)
         CancelAllPendingOrders(session);

      if(recomputeLots && allowRearm && !lowMargin)
         m_lotEngine.ComputeAllLots(session.levels, total, ruinProximity);

      for(int i = 0; i < total; i++)
      {
         //--- Snapshot open state before sync
         bool wasBuyOpen  = session.levels[i].buyOpen;
         bool wasSellOpen = session.levels[i].sellOpen;
         bool wasBuyFilled  = session.levels[i].buyFilled;
         bool wasSellFilled = session.levels[i].sellFilled;

         SyncLevelState(session.levels[i]);

         //--- Detect TP closures: position was open (or filled from a fast fill+TP),
         //    now gone with filled flag cleared
         if(wasBuyOpen && !session.levels[i].buyOpen && !session.levels[i].buyFilled)
            tpClosures++;
         if(wasSellOpen && !session.levels[i].sellOpen && !session.levels[i].sellFilled)
            tpClosures++;

         //--- Also detect fast fill+TP: order was armed (filled flag was false),
         //    now filled=true but no position exists (TP fired between syncs)
         if(!wasBuyOpen && !wasBuyFilled && session.levels[i].buyFilled
            && !session.levels[i].buyOpen)
         {
            tpClosures++;
            session.levels[i].buyFilled = false;
         }
         if(!wasSellOpen && !wasSellFilled && session.levels[i].sellFilled
            && !session.levels[i].sellOpen)
         {
            tpClosures++;
            session.levels[i].sellFilled = false;
         }

         //--- Clear stale filled flags: level marked filled but has no position,
         //    no pending order, not armed — the block is stale (e.g., warning close).
         if(session.levels[i].buyFilled && !session.levels[i].buyOpen
            && session.levels[i].buyTicket == 0 && !session.levels[i].buyArmed
            && session.levels[i].buyPendingTicket == 0)
         {
            session.levels[i].buyFilled = false;
         }
         if(session.levels[i].sellFilled && !session.levels[i].sellOpen
            && session.levels[i].sellTicket == 0 && !session.levels[i].sellArmed
            && session.levels[i].sellPendingTicket == 0)
         {
            session.levels[i].sellFilled = false;
         }

         //--- Only place new orders when allowed (ACTIVE state), spread OK, and margin OK
         if(allowRearm && !lowMargin && spread <= maxSpread)
            PlaceLevel(session.levels[i], session.gridMode, session.trendDirection);
      }

      return tpClosures;
   }

   //--- Close all open positions using CloseBy pairs first, then remainder
   //    outOrphans: number of orphaned positions found and closed
   int CloseAllPositions(GridSession &session, int &outOrphans)
   {
      outOrphans = 0;
      int closed = 0;
      int total  = session.LevelCount();

      double bid    = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      double ask    = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
      double spread = (ask - bid) / SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      PrintFormat("[BGC Grid] Closing positions. Current spread=%.1f points", spread);

      //--- Phase 1: Sync all level states
      for(int i = 0; i < total; i++)
         SyncLevelState(session.levels[i]);

      //--- Phase 2: Collect open buy and sell tickets for CloseBy pairing
      ulong buyTickets[];
      double buyLots[];
      int buyIdx[];
      ulong sellTickets[];
      double sellLots[];
      int sellIdx[];
      int buyCount = 0, sellCount = 0;

      for(int i = 0; i < total; i++)
      {
         if(session.levels[i].buyOpen && session.levels[i].buyTicket > 0)
         {
            ArrayResize(buyTickets, buyCount + 1);
            ArrayResize(buyLots, buyCount + 1);
            ArrayResize(buyIdx, buyCount + 1);
            buyTickets[buyCount] = session.levels[i].buyTicket;
            buyLots[buyCount]    = session.levels[i].lotSize;
            buyIdx[buyCount]     = i;
            buyCount++;
         }
         if(session.levels[i].sellOpen && session.levels[i].sellTicket > 0)
         {
            ArrayResize(sellTickets, sellCount + 1);
            ArrayResize(sellLots, sellCount + 1);
            ArrayResize(sellIdx, sellCount + 1);
            sellTickets[sellCount] = session.levels[i].sellTicket;
            sellLots[sellCount]    = session.levels[i].lotSize;
            sellIdx[sellCount]     = i;
            sellCount++;
         }
      }

      //--- CloseBy pairs with matching lot sizes
      for(int b = 0; b < buyCount; b++)
      {
         if(buyTickets[b] == 0) continue;
         for(int s = 0; s < sellCount; s++)
         {
            if(sellTickets[s] == 0) continue;
            if(MathAbs(buyLots[b] - sellLots[s]) > 0.00001) continue;

            if(PositionSelectByTicket(buyTickets[b]) &&
               PositionSelectByTicket(sellTickets[s]))
            {
               if(m_trade.PositionCloseBy(buyTickets[b], sellTickets[s]))
               {
                  session.levels[buyIdx[b]].buyOpen    = false;
                  session.levels[buyIdx[b]].buyTicket  = 0;
                  session.levels[sellIdx[s]].sellOpen   = false;
                  session.levels[sellIdx[s]].sellTicket = 0;
                  buyTickets[b]  = 0;
                  sellTickets[s] = 0;
                  closed += 2;
                  break;
               }
            }
         }
      }

      //--- Phase 3: Close remaining positions individually
      for(int i = 0; i < total; i++)
      {
         if(session.levels[i].buyOpen && session.levels[i].buyTicket > 0)
         {
            if(PositionSelectByTicket(session.levels[i].buyTicket))
            {
               if(m_trade.PositionClose(session.levels[i].buyTicket))
               {
                  session.levels[i].buyOpen   = false;
                  session.levels[i].buyTicket = 0;
                  closed++;
               }
            }
         }

         if(session.levels[i].sellOpen && session.levels[i].sellTicket > 0)
         {
            if(PositionSelectByTicket(session.levels[i].sellTicket))
            {
               if(m_trade.PositionClose(session.levels[i].sellTicket))
               {
                  session.levels[i].sellOpen   = false;
                  session.levels[i].sellTicket = 0;
                  closed++;
               }
            }
         }
      }

      //--- Phase 4: Delete any remaining pending orders
      DeletePendingOrders(session);

      //--- Phase 5: Sweep for any orphaned positions with our magic
      int orphansClosed = 0;
      int totalPos = PositionsTotal();
      for(int i = totalPos - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != m_magic) continue;
         if(PositionGetString(POSITION_SYMBOL) != m_symbol) continue;

         if(m_trade.PositionClose(ticket))
         {
            orphansClosed++;
         }
         else
         {
            PrintFormat("[BGC Grid] Could not close orphaned position #%I64u (error %d)",
                        ticket, GetLastError());
         }
      }

      outOrphans = orphansClosed;
      PrintFormat("[BGC Grid] Closed %d tracked positions and %d orphaned positions", closed, orphansClosed);
      return closed + orphansClosed;
   }

   //--- Delete all pending orders for this grid
   void DeletePendingOrders(GridSession &session)
   {
      int total = session.LevelCount();
      for(int i = 0; i < total; i++)
      {
         if(session.levels[i].buyPendingTicket > 0)
         {
            if(OrderSelect(session.levels[i].buyPendingTicket))
               m_trade.OrderDelete(session.levels[i].buyPendingTicket);
            session.levels[i].buyPendingTicket = 0;
            session.levels[i].buyArmed = false;
         }

         if(session.levels[i].sellPendingTicket > 0)
         {
            if(OrderSelect(session.levels[i].sellPendingTicket))
               m_trade.OrderDelete(session.levels[i].sellPendingTicket);
            session.levels[i].sellPendingTicket = 0;
            session.levels[i].sellArmed = false;
         }
      }
   }

   //--- Selective loss reduction: close the single worst losing position
   //    Paper 1, capability #2: "close one or a few losing trades to reduce risk"
   //    Returns true if a position was closed
   bool CloseWorstLoser(GridSession &session)
   {
      int total = session.LevelCount();
      double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);

      double worstLoss = 0;
      int    worstIdx  = -1;
      bool   worstIsBuy = false;

      for(int i = 0; i < total; i++)
      {
         SyncLevelState(session.levels[i]);

         //--- Check buy positions: losing when bid < open price
         if(session.levels[i].buyOpen && session.levels[i].buyTicket > 0)
         {
            double loss = (session.levels[i].price - bid) * session.levels[i].lotSize;
            if(loss > worstLoss)
            {
               worstLoss  = loss;
               worstIdx   = i;
               worstIsBuy = true;
            }
         }

         //--- Check sell positions: losing when ask > open price
         if(session.levels[i].sellOpen && session.levels[i].sellTicket > 0)
         {
            double loss = (ask - session.levels[i].price) * session.levels[i].lotSize;
            if(loss > worstLoss)
            {
               worstLoss   = loss;
               worstIdx    = i;
               worstIsBuy  = false;
            }
         }
      }

      if(worstIdx < 0 || worstLoss <= 0)
         return false;

      bool closed = false;
      if(worstIsBuy)
      {
         if(PositionSelectByTicket(session.levels[worstIdx].buyTicket))
         {
            if(m_trade.PositionClose(session.levels[worstIdx].buyTicket))
            {
               PrintFormat("[BGC Grid] Closed highest-loss BUY position at level %d, price %.5f, est loss=%.2f",
                           session.levels[worstIdx].levelIndex, session.levels[worstIdx].price, worstLoss);
               session.levels[worstIdx].buyOpen   = false;
               session.levels[worstIdx].buyTicket = 0;
               closed = true;
            }
         }
      }
      else
      {
         if(PositionSelectByTicket(session.levels[worstIdx].sellTicket))
         {
            if(m_trade.PositionClose(session.levels[worstIdx].sellTicket))
            {
               PrintFormat("[BGC Grid] Closed highest-loss SELL position at level %d, price %.5f, est loss=%.2f",
                           session.levels[worstIdx].levelIndex, session.levels[worstIdx].price, worstLoss);
               session.levels[worstIdx].sellOpen   = false;
               session.levels[worstIdx].sellTicket = 0;
               closed = true;
            }
         }
      }

      return closed;
   }

   //--- Recover positions after EA restart: scan open positions by magic
   //    and map them back to grid levels by open price proximity.
   void RecoverPositions(GridSession &session)
   {
      int totalPos = PositionsTotal();
      int recovered = 0;
      int totalLevels = session.LevelCount();

      for(int p = 0; p < totalPos; p++)
      {
         ulong ticket = PositionGetTicket(p);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != m_magic) continue;
         if(PositionGetString(POSITION_SYMBOL) != m_symbol) continue;

         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         long   posType   = PositionGetInteger(POSITION_TYPE);
         double posLot    = PositionGetDouble(POSITION_VOLUME);

         //--- Find the closest grid level
         double minDist   = DBL_MAX;
         int    bestLevel = -1;

         for(int i = 0; i < totalLevels; i++)
         {
            double dist = MathAbs(openPrice - session.levels[i].price);
            if(dist < minDist)
            {
               minDist   = dist;
               bestLevel = i;
            }
         }

         if(bestLevel < 0) continue;

         if(posType == POSITION_TYPE_BUY)
         {
            session.levels[bestLevel].buyTicket = ticket;
            session.levels[bestLevel].buyOpen   = true;
            session.levels[bestLevel].buyFilled = true;
            session.levels[bestLevel].lotSize   = posLot;
            recovered++;
         }
         else if(posType == POSITION_TYPE_SELL)
         {
            session.levels[bestLevel].sellTicket = ticket;
            session.levels[bestLevel].sellOpen   = true;
            session.levels[bestLevel].sellFilled = true;
            if(session.levels[bestLevel].lotSize == 0)
               session.levels[bestLevel].lotSize = posLot;
            recovered++;
         }
      }

      if(recovered > 0)
         PrintFormat("[BGC Grid] Restored %d positions from the saved session", recovered);
   }
};

#endif // __GRID_CORE_MQH__
//+------------------------------------------------------------------+
