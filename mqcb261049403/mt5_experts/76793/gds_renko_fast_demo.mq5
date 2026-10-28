//+------------------------------------------------------------------+
//|                    GDS Renko Fast Demo EA                        |
//|              Educational CodeBase Renko example                  |
//+------------------------------------------------------------------+
#property copyright "Golden Delta"
#property link      "https://goldendeltaea.com/"
#property version   "2.10"
#property strict
#property description "Educational multi-scale Renko Expert Advisor for MetaTrader 5."
#property description "Uses a slow Renko trend and fast Renko entries with short exits."
#property description "No external libraries, DLLs or offline charts are required."
#property description "Default settings are a historical demonstration, not a profit promise."

input double InpFastBrickSize      = 21.0;  // Fast Renko brick size in price units
input double InpSlowBrickSize      = 39.0;  // Slow Renko brick size in price units
input int    InpEntryRunBricks     = 1;     // Fast bricks required for entry
input double InpTakeProfitBricks   = 1.4;   // Take profit in fast bricks
input double InpStopLossBricks     = 2.1;   // Stop loss in fast bricks
input int    InpMaxHoldMinutes     = 200;   // Maximum holding time
input int    InpCooldownBricks     = 3;     // Fast bricks to wait after an exit
input double InpMaxSpreadFraction  = 0.570; // Max spread as fraction of fast brick
input double InpLots               = 0.01;  // Fixed lot size

const ulong GDS_MAGIC = 26083120;

struct SRenkoBrick
  {
   double close;
   int    direction; // +1 up, -1 down
   int    run;       // consecutive bricks in current direction
  };

class CRenkoBuilder
  {
private:
   double m_size;
   bool   m_has_anchor;
   double m_anchor;
   double m_last_close;
   int    m_last_dir;
   int    m_run;

   void AddBrick(SRenkoBrick &out[],const double close_price,const int direction)
     {
      if(direction==m_last_dir)
         m_run++;
      else
        {
         m_last_dir=direction;
         m_run=1;
        }

      const int n=ArraySize(out);
      ArrayResize(out,n+1);
      out[n].close=NormalizeDouble(close_price,_Digits);
      out[n].direction=direction;
      out[n].run=m_run;
     }

public:
   void Init(const double brick_size)
     {
      m_size=brick_size;
      m_has_anchor=false;
      m_anchor=0.0;
      m_last_close=0.0;
      m_last_dir=0;
      m_run=0;
     }

   int PushPrice(const double price,SRenkoBrick &out[])
     {
      ArrayResize(out,0);
      if(m_size<=0.0 || price<=0.0)
         return 0;

      if(!m_has_anchor)
        {
         m_anchor=price;
         m_has_anchor=true;
         return 0;
        }

      int added=0;

      // First direction: one full brick from the starting anchor.
      if(m_last_dir==0)
        {
         while(price>=m_anchor+m_size)
           {
            m_anchor+=m_size;
            m_last_close=m_anchor;
            AddBrick(out,m_last_close,+1);
            added++;
           }

         while(price<=m_anchor-m_size)
           {
            m_anchor-=m_size;
            m_last_close=m_anchor;
            AddBrick(out,m_last_close,-1);
            added++;
           }
         return added;
        }

      bool changed=true;
      while(changed)
        {
         changed=false;

         if(m_last_dir>0)
           {
            if(price>=m_last_close+m_size)
              {
               m_last_close+=m_size;
               AddBrick(out,m_last_close,+1);
               added++;
               changed=true;
              }
            else if(price<=m_last_close-2.0*m_size)
              {
               m_last_close-=2.0*m_size;
               AddBrick(out,m_last_close,-1);
               added++;
               changed=true;
              }
           }
         else
           {
            if(price<=m_last_close-m_size)
              {
               m_last_close-=m_size;
               AddBrick(out,m_last_close,-1);
               added++;
               changed=true;
              }
            else if(price>=m_last_close+2.0*m_size)
              {
               m_last_close+=2.0*m_size;
               AddBrick(out,m_last_close,+1);
               added++;
               changed=true;
              }
           }
        }

      return added;
     }
  };

CRenkoBuilder g_fast;
CRenkoBuilder g_slow;

int g_fast_dir=0;
int g_fast_run=0;
int g_slow_dir=0;
int g_slow_run=0;
int g_cooldown_left=0;

//+------------------------------------------------------------------+
double NormalizeVolume(const double requested)
  {
   double vmin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double vmax=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   if(step<=0.0)
      step=vmin;
   if(step<=0.0)
      return requested;

   double volume=MathRound(requested/step)*step;
   volume=MathMax(vmin,MathMin(vmax,volume));
   return volume;
  }

//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING FillingMode(void)
  {
   const long flags=SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);
   if((flags & SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK)
      return ORDER_FILLING_FOK;
   if((flags & SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC)
      return ORDER_FILLING_IOC;
   return ORDER_FILLING_RETURN;
  }

//+------------------------------------------------------------------+
bool FindOurPosition(ulong &ticket,long &type,double &volume,double &open_price,datetime &open_time)
  {
   ticket=0;
   type=-1;
   volume=0.0;
   open_price=0.0;
   open_time=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      const ulong t=PositionGetTicket(i);
      if(t==0)
         continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol)
         continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=GDS_MAGIC)
         continue;

      ticket=t;
      type=PositionGetInteger(POSITION_TYPE);
      volume=PositionGetDouble(POSITION_VOLUME);
      open_price=PositionGetDouble(POSITION_PRICE_OPEN);
      open_time=(datetime)PositionGetInteger(POSITION_TIME);
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
bool AnyPositionOnSymbol(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      const ulong t=PositionGetTicket(i);
      if(t==0)
         continue;
      if(PositionGetString(POSITION_SYMBOL)==_Symbol)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
bool SpreadIsAcceptable(const MqlTick &tick)
  {
   if(tick.ask<=0.0 || tick.bid<=0.0)
      return false;
   const double spread=tick.ask-tick.bid;
   return (spread<=InpFastBrickSize*InpMaxSpreadFraction);
  }

//+------------------------------------------------------------------+
bool SendMarket(const int direction)
  {
   if(direction!=1 && direction!=-1)
      return false;
   if(AnyPositionOnSymbol())
      return false;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return false;
   if(!SpreadIsAcceptable(tick))
      return false;

   MqlTradeRequest request={};
   MqlTradeResult  result={};

   request.action=TRADE_ACTION_DEAL;
   request.magic=GDS_MAGIC;
   request.symbol=_Symbol;
   request.volume=NormalizeVolume(InpLots);
   request.deviation=50;
   request.type_filling=FillingMode();
   request.comment="GDS Renko Fast Demo";

   if(direction>0)
     {
      request.type=ORDER_TYPE_BUY;
      request.price=tick.ask;
     }
   else
     {
      request.type=ORDER_TYPE_SELL;
      request.price=tick.bid;
     }

   ResetLastError();
   if(!OrderSend(request,result))
     {
      Print("GDS Renko Fast Demo: entry OrderSend failed. Error ",GetLastError());
      return false;
     }

   if(result.retcode!=TRADE_RETCODE_DONE &&
      result.retcode!=TRADE_RETCODE_DONE_PARTIAL &&
      result.retcode!=TRADE_RETCODE_PLACED)
     {
      Print("GDS Renko Fast Demo: entry rejected. Retcode ",result.retcode," ",result.comment);
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
bool CloseOurPosition(const string reason)
  {
   ulong ticket=0;
   long type=-1;
   double volume=0.0;
   double open_price=0.0;
   datetime open_time=0;
   if(!FindOurPosition(ticket,type,volume,open_price,open_time))
      return false;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return false;

   MqlTradeRequest request={};
   MqlTradeResult  result={};

   request.action=TRADE_ACTION_DEAL;
   request.magic=GDS_MAGIC;
   request.position=ticket;
   request.symbol=_Symbol;
   request.volume=volume;
   request.deviation=50;
   request.type_filling=FillingMode();
   request.comment="GDS Renko Fast exit";

   if(type==POSITION_TYPE_BUY)
     {
      request.type=ORDER_TYPE_SELL;
      request.price=tick.bid;
     }
   else
     {
      request.type=ORDER_TYPE_BUY;
      request.price=tick.ask;
     }

   ResetLastError();
   if(!OrderSend(request,result))
     {
      Print("GDS Renko Fast Demo: close failed. Error ",GetLastError());
      return false;
     }

   if(result.retcode!=TRADE_RETCODE_DONE &&
      result.retcode!=TRADE_RETCODE_DONE_PARTIAL &&
      result.retcode!=TRADE_RETCODE_PLACED)
     {
      Print("GDS Renko Fast Demo: close rejected. Retcode ",result.retcode," ",result.comment);
      return false;
     }

   Print("GDS Renko Fast Demo exit: ",reason);
   g_cooldown_left=InpCooldownBricks;
   return true;
  }

//+------------------------------------------------------------------+
void CheckPriceExit(const MqlTick &tick)
  {
   ulong ticket=0;
   long type=-1;
   double volume=0.0;
   double open_price=0.0;
   datetime open_time=0;
   if(!FindOurPosition(ticket,type,volume,open_price,open_time))
      return;

   const int direction=(type==POSITION_TYPE_BUY ? +1 : -1);
   const double executable=(direction>0 ? tick.bid : tick.ask);
   if(executable<=0.0)
      return;

   const double move=direction*(executable-open_price);
   const double tp=InpTakeProfitBricks*InpFastBrickSize;
   const double sl=InpStopLossBricks*InpFastBrickSize;

   if(move>=tp)
     {
      CloseOurPosition("TP");
      return;
     }

   if(move<=-sl)
     {
      CloseOurPosition("SL");
      return;
     }

   if(InpMaxHoldMinutes>0 && open_time>0)
     {
      const long held_seconds=(long)(TimeCurrent()-open_time);
      if(held_seconds>=InpMaxHoldMinutes*60)
         CloseOurPosition("TIME");
     }
  }

//+------------------------------------------------------------------+
void UpdateSlow(const double price)
  {
   SRenkoBrick bricks[];
   const int n=g_slow.PushPrice(price,bricks);
   if(n<=0)
      return;

   // Only the final completed slow brick represents the state after this tick.
   g_slow_dir=bricks[n-1].direction;
   g_slow_run=bricks[n-1].run;
  }

//+------------------------------------------------------------------+
void UpdateFastAndTrade(const double price)
  {
   SRenkoBrick bricks[];
   const int n=g_fast.PushPrice(price,bricks);
   if(n<=0)
      return;

   if(g_cooldown_left>0)
     {
      g_cooldown_left-=n;
      if(g_cooldown_left<0)
         g_cooldown_left=0;
     }

   g_fast_dir=bricks[n-1].direction;
   g_fast_run=bricks[n-1].run;

   ulong ticket=0;
   long type=-1;
   double volume=0.0;
   double open_price=0.0;
   datetime open_time=0;
   const bool have_position=FindOurPosition(ticket,type,volume,open_price,open_time);

   if(have_position)
     {
      const int position_dir=(type==POSITION_TYPE_BUY ? +1 : -1);
      if(g_fast_dir!=position_dir)
         CloseOurPosition("FAST REVERSAL");
      return;
     }

   if(AnyPositionOnSymbol())
      return;
   if(g_cooldown_left>0)
      return;
   if(g_slow_dir==0 || g_fast_dir==0)
      return;
   if(g_slow_run<1)
      return;
   if(g_fast_dir!=g_slow_dir)
      return;
   if(g_fast_run<InpEntryRunBricks)
      return;

   SendMarket(g_fast_dir);
  }

//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(InpFastBrickSize<=0.0 ||
      InpSlowBrickSize<=InpFastBrickSize ||
      InpEntryRunBricks<1 ||
      InpTakeProfitBricks<=0.0 ||
      InpStopLossBricks<=0.0 ||
      InpMaxHoldMinutes<0 ||
      InpCooldownBricks<0 ||
      InpMaxSpreadFraction<=0.0 ||
      InpLots<=0.0)
     {
      Print("GDS Renko Fast Demo: invalid inputs.");
      return INIT_PARAMETERS_INCORRECT;
     }

   g_fast.Init(InpFastBrickSize);
   g_slow.Init(InpSlowBrickSize);
   g_fast_dir=0;
   g_fast_run=0;
   g_slow_dir=0;
   g_slow_run=0;
   g_cooldown_left=0;

   Print("GDS Renko Fast Demo v2.10 started. Fast=",DoubleToString(InpFastBrickSize,_Digits),
         ", Slow=",DoubleToString(InpSlowBrickSize,_Digits),
         ", EntryRun=",InpEntryRunBricks,
         ", TP=",DoubleToString(InpTakeProfitBricks,2),
         ", SL=",DoubleToString(InpStopLossBricks,2),
         ", HoldMin=",InpMaxHoldMinutes,
         ", Lots=",DoubleToString(InpLots,2));
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
void OnTick(void)
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return;
   if(tick.bid<=0.0 || tick.ask<=0.0)
      return;

   // Fast price exits are checked on every real tick.
   CheckPriceExit(tick);

   // Renko state itself is built from BID, as in the companion indicator.
   UpdateSlow(tick.bid);
   UpdateFastAndTrade(tick.bid);
  }
//+------------------------------------------------------------------+
