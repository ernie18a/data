//+------------------------------------------------------------------+
//|                 GDS Renko Zones Demo EA                          |
//|         Educational Renko support/resistance example             |
//+------------------------------------------------------------------+
#property copyright "Golden Delta"
#property link      "https://goldendeltaea.com/"
#property version   "1.10"
#property strict
#property description "Educational Renko support/resistance Expert Advisor for MetaTrader 5."
#property description "Creates simple zones from confirmed classic Renko reversals and trades retests."
#property description "Standalone example: no custom indicators, DLLs, libraries or offline charts."
#property description "Historical test settings are demonstrations, not a promise of future results."

input double InpBrickSize          = 18.0;  // Renko brick size in price units
input double InpZoneHalfBricks     = 1.65;  // Zone half-width in bricks
input double InpMinAwayBricks      = 0.90;  // Move away before a zone may be retested
input int    InpMaxZoneAgeBricks   = 53;    // Maximum zone age in completed bricks
input double InpTakeProfitBricks   = 5.50;  // Take profit in bricks
input double InpStopLossBricks     = 2.90;  // Stop loss in bricks
input int    InpMaxHoldMinutes     = 680;   // Maximum holding time
input double InpMaxSpreadFraction  = 0.30;  // Max spread as fraction of one brick
input double InpLots               = 0.01;  // Fixed lot size

const ulong GDS_MAGIC=26083130;
const int   GDS_MAX_ZONES=64;

struct SRenkoBrick
  {
   double close;
   int    direction;      // +1 up, -1 down
   int    run;
   long   serial;
   bool   reversal;
   double turn_level;     // previous Renko close before a two-brick reversal
  };

struct SZone
  {
   int    type;           // +1 support, -1 resistance
   double center;
   double low;
   double high;
   long   created_serial;
   bool   active;
   bool   armed;
   bool   touched;
   bool   traded;
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
   long   m_serial;

   void AddBrick(SRenkoBrick &out[],const double close_price,const int direction,
                 const bool reversal,const double turn_level)
     {
      if(direction==m_last_dir)
         m_run++;
      else
        {
         m_last_dir=direction;
         m_run=1;
        }

      m_serial++;
      const int n=ArraySize(out);
      ArrayResize(out,n+1);
      out[n].close=NormalizeDouble(close_price,_Digits);
      out[n].direction=direction;
      out[n].run=m_run;
      out[n].serial=m_serial;
      out[n].reversal=reversal;
      out[n].turn_level=NormalizeDouble(turn_level,_Digits);
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
      m_serial=0;
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

      // First direction: one full brick from the initial anchor.
      if(m_last_dir==0)
        {
         while(price>=m_anchor+m_size)
           {
            m_anchor+=m_size;
            m_last_close=m_anchor;
            AddBrick(out,m_last_close,+1,false,0.0);
            added++;
           }

         while(price<=m_anchor-m_size)
           {
            m_anchor-=m_size;
            m_last_close=m_anchor;
            AddBrick(out,m_last_close,-1,false,0.0);
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
               AddBrick(out,m_last_close,+1,false,0.0);
               added++;
               changed=true;
              }
            else if(price<=m_last_close-2.0*m_size)
              {
               const double turn=m_last_close;
               m_last_close-=2.0*m_size;
               AddBrick(out,m_last_close,-1,true,turn);
               added++;
               changed=true;
              }
           }
         else
           {
            if(price<=m_last_close-m_size)
              {
               m_last_close-=m_size;
               AddBrick(out,m_last_close,-1,false,0.0);
               added++;
               changed=true;
              }
            else if(price>=m_last_close+2.0*m_size)
              {
               const double turn=m_last_close;
               m_last_close+=2.0*m_size;
               AddBrick(out,m_last_close,+1,true,turn);
               added++;
               changed=true;
              }
           }
        }

      return added;
     }
  };

CRenkoBuilder g_renko;
SZone        g_zones[];
double       g_prev_bid=0.0;

//+------------------------------------------------------------------+
double NormalizeVolume(const double requested)
  {
   double vmin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double vmax=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   if(step<=0.0) step=vmin;
   if(step<=0.0) return requested;

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
      if(t==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=GDS_MAGIC) continue;

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
      if(t==0) continue;
      if(PositionGetString(POSITION_SYMBOL)==_Symbol)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
bool SpreadIsAcceptable(const MqlTick &tick)
  {
   if(tick.ask<=0.0 || tick.bid<=0.0) return false;
   return ((tick.ask-tick.bid)<=InpBrickSize*InpMaxSpreadFraction);
  }

//+------------------------------------------------------------------+
bool SendMarket(const int direction,const int zone_index)
  {
   if(direction!=1 && direction!=-1) return false;
   if(AnyPositionOnSymbol()) return false;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return false;
   if(!SpreadIsAcceptable(tick)) return false;

   MqlTradeRequest request={};
   MqlTradeResult  result={};
   request.action=TRADE_ACTION_DEAL;
   request.magic=GDS_MAGIC;
   request.symbol=_Symbol;
   request.volume=NormalizeVolume(InpLots);
   request.deviation=50;
   request.type_filling=FillingMode();
   request.comment=(direction>0 ? "GDS Zone Support" : "GDS Zone Resist");

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
      Print("GDS Renko Zones Demo: entry OrderSend failed. Error ",GetLastError());
      return false;
     }

   if(result.retcode!=TRADE_RETCODE_DONE &&
      result.retcode!=TRADE_RETCODE_DONE_PARTIAL &&
      result.retcode!=TRADE_RETCODE_PLACED)
     {
      Print("GDS Renko Zones Demo: entry rejected. Retcode ",result.retcode," ",result.comment);
      return false;
     }

   if(zone_index>=0 && zone_index<ArraySize(g_zones))
      g_zones[zone_index].traded=true;
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
   if(!SymbolInfoTick(_Symbol,tick)) return false;

   MqlTradeRequest request={};
   MqlTradeResult  result={};
   request.action=TRADE_ACTION_DEAL;
   request.magic=GDS_MAGIC;
   request.position=ticket;
   request.symbol=_Symbol;
   request.volume=volume;
   request.deviation=50;
   request.type_filling=FillingMode();
   request.comment="GDS Zone exit";

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
      Print("GDS Renko Zones Demo: close failed. Error ",GetLastError());
      return false;
     }

   if(result.retcode!=TRADE_RETCODE_DONE &&
      result.retcode!=TRADE_RETCODE_DONE_PARTIAL &&
      result.retcode!=TRADE_RETCODE_PLACED)
     {
      Print("GDS Renko Zones Demo: close rejected. Retcode ",result.retcode," ",result.comment);
      return false;
     }

   Print("GDS Renko Zones Demo exit: ",reason);
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
   if(!FindOurPosition(ticket,type,volume,open_price,open_time)) return;

   const int direction=(type==POSITION_TYPE_BUY ? +1 : -1);
   const double executable=(direction>0 ? tick.bid : tick.ask);
   if(executable<=0.0) return;

   const double move=direction*(executable-open_price);
   const double tp=InpTakeProfitBricks*InpBrickSize;
   const double sl=InpStopLossBricks*InpBrickSize;

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
void TrimZones(void)
  {
   int n=ArraySize(g_zones);
   if(n<=GDS_MAX_ZONES) return;

   const int remove=n-GDS_MAX_ZONES;
   for(int i=remove;i<n;i++)
      g_zones[i-remove]=g_zones[i];
   ArrayResize(g_zones,GDS_MAX_ZONES);
  }

//+------------------------------------------------------------------+
void AddZone(const int type,const double center,const long serial)
  {
   if(type!=1 && type!=-1) return;

   const double half=InpZoneHalfBricks*InpBrickSize;
   SZone z;
   z.type=type;
   z.center=NormalizeDouble(center,_Digits);
   z.low=NormalizeDouble(center-half,_Digits);
   z.high=NormalizeDouble(center+half,_Digits);
   z.created_serial=serial;
   z.active=true;
   z.armed=false;
   z.touched=false;
   z.traded=false;

   const int n=ArraySize(g_zones);
   ArrayResize(g_zones,n+1);
   g_zones[n]=z;
   TrimZones();
  }

//+------------------------------------------------------------------+
bool SegmentTouchesZone(const double a,const double b,const SZone &z)
  {
   const double lo=MathMin(a,b);
   const double hi=MathMax(a,b);
   return (hi>=z.low && lo<=z.high);
  }

//+------------------------------------------------------------------+
void UpdateZonesByTick(const double previous_price,const double price)
  {
   if(price<=0.0) return;

   const int n=ArraySize(g_zones);
   for(int i=0;i<n;i++)
     {
      if(!g_zones[i].active || g_zones[i].traded) continue;

      // A zone may only be touched if it was already armed before this tick.
      const bool was_armed=g_zones[i].armed;
      if(was_armed && !g_zones[i].touched && previous_price>0.0)
        {
         if(SegmentTouchesZone(previous_price,price,g_zones[i]))
            g_zones[i].touched=true;
        }

      if(!g_zones[i].armed)
        {
         if(g_zones[i].type>0)
           {
            if(price>=g_zones[i].high+InpMinAwayBricks*InpBrickSize)
               g_zones[i].armed=true;
           }
         else
           {
            if(price<=g_zones[i].low-InpMinAwayBricks*InpBrickSize)
               g_zones[i].armed=true;
           }
        }
     }
  }

//+------------------------------------------------------------------+
void UpdateZoneLifecycle(const SRenkoBrick &brick)
  {
   const int n=ArraySize(g_zones);
   for(int i=0;i<n;i++)
     {
      if(!g_zones[i].active) continue;

      if(InpMaxZoneAgeBricks>0 &&
         brick.serial-g_zones[i].created_serial>InpMaxZoneAgeBricks)
        {
         g_zones[i].active=false;
         continue;
        }

      // A completed brick closing beyond the far side invalidates the zone.
      if(g_zones[i].type>0 && brick.close<g_zones[i].low)
         g_zones[i].active=false;
      else if(g_zones[i].type<0 && brick.close>g_zones[i].high)
         g_zones[i].active=false;
     }
  }

//+------------------------------------------------------------------+
int BestEntryZone(const SRenkoBrick &brick)
  {
   int best=-1;
   long newest=-1;
   const int n=ArraySize(g_zones);

   for(int i=0;i<n;i++)
     {
      if(!g_zones[i].active || !g_zones[i].armed || !g_zones[i].touched || g_zones[i].traded)
         continue;
      if(g_zones[i].type!=brick.direction)
         continue;

      bool confirmed=false;
      if(g_zones[i].type>0)
         confirmed=(brick.direction>0 && brick.close>g_zones[i].high);
      else
         confirmed=(brick.direction<0 && brick.close<g_zones[i].low);

      if(!confirmed) continue;
      if(g_zones[i].created_serial>newest)
        {
         newest=g_zones[i].created_serial;
         best=i;
        }
     }
   return best;
  }

//+------------------------------------------------------------------+
void ProcessCompletedBrick(const SRenkoBrick &brick)
  {
   UpdateZoneLifecycle(brick);

   // A classic two-brick reversal defines a simple structural turning zone.
   // UP -> DOWN creates resistance at the old Renko high.
   // DOWN -> UP creates support at the old Renko low.
   if(brick.reversal && brick.turn_level>0.0)
     {
      const int new_zone_type=(brick.direction>0 ? +1 : -1);
      AddZone(new_zone_type,brick.turn_level,brick.serial);
     }

   // Close an open demo trade when Renko confirms an opposite reversal.
   ulong ticket=0;
   long type=-1;
   double volume=0.0;
   double open_price=0.0;
   datetime open_time=0;
   if(FindOurPosition(ticket,type,volume,open_price,open_time))
     {
      const int pos_dir=(type==POSITION_TYPE_BUY ? +1 : -1);
      if(brick.reversal && brick.direction!=pos_dir)
         CloseOurPosition("RENKO REVERSAL");
      return;
     }

   if(AnyPositionOnSymbol()) return;

   const int zone_index=BestEntryZone(brick);
   if(zone_index>=0)
      SendMarket(g_zones[zone_index].type,zone_index);
  }

//+------------------------------------------------------------------+
void UpdateRenko(const double price)
  {
   SRenkoBrick bricks[];
   const int n=g_renko.PushPrice(price,bricks);
   for(int i=0;i<n;i++)
      ProcessCompletedBrick(bricks[i]);
  }

//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(InpBrickSize<=0.0 ||
      InpZoneHalfBricks<=0.0 || InpZoneHalfBricks>2.0 ||
      InpMinAwayBricks<0.0 ||
      InpMaxZoneAgeBricks<1 ||
      InpTakeProfitBricks<=0.0 ||
      InpStopLossBricks<=0.0 ||
      InpMaxHoldMinutes<0 ||
      InpMaxSpreadFraction<=0.0 ||
      InpLots<=0.0)
     {
      Print("GDS Renko Zones Demo: invalid inputs.");
      return INIT_PARAMETERS_INCORRECT;
     }

   g_renko.Init(InpBrickSize);
   ArrayResize(g_zones,0);
   g_prev_bid=0.0;

   Print("GDS Renko Zones Demo v1.00 started. Brick=",DoubleToString(InpBrickSize,_Digits),
         ", ZoneHalf=",DoubleToString(InpZoneHalfBricks,2),
         ", Away=",DoubleToString(InpMinAwayBricks,2),
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
   if(!SymbolInfoTick(_Symbol,tick)) return;
   if(tick.bid<=0.0 || tick.ask<=0.0) return;

   CheckPriceExit(tick);

   // Existing zones see the real tick path before this tick is transformed
   // into any newly completed Renko bricks. This keeps retest detection causal.
   UpdateZonesByTick(g_prev_bid,tick.bid);
   UpdateRenko(tick.bid);
   g_prev_bid=tick.bid;
  }
//+------------------------------------------------------------------+
