//+------------------------------------------------------------------+
//|              GDS Renko SuperTrend Demo EA                        |
//|       Educational Renko + SuperTrend example for MT5             |
//+------------------------------------------------------------------+
#property copyright "Golden Delta"
#property link      "https://goldendeltaea.com/"
#property version   "1.11"
#property strict
#property description "Educational Renko + SuperTrend Expert Advisor for MetaTrader 5."
#property description "Builds classic fixed-size Renko internally from BID ticks."
#property description "SuperTrend is calculated from completed Renko bricks, not time candles."
#property description "No external indicators, DLLs, custom symbols or offline charts are required."

input double InpBrickSize          = 18.0;  // Renko brick size in price units
input int    InpSTPeriod           = 44;     // SuperTrend ATR period in Renko bricks
input double InpSTMultiplier       = 1.30;  // SuperTrend ATR multiplier
input int    InpEntryRunBricks     = 1;     // Renko run required for entry
input double InpTakeProfitBricks   = 12.5;   // Take profit in Renko bricks
input double InpStopLossBricks     = 6.1;   // Stop loss in Renko bricks
input int    InpMaxHoldMinutes     = 860;   // Maximum holding time
input int    InpCooldownBricks     = 6;     // Completed bricks to wait after exit
input double InpMaxSpreadFraction  = 0.35;  // Max spread as fraction of brick size
input double InpLots               = 0.01;  // Fixed lot size

const ulong GDS_MAGIC = 26090131;

struct SRenkoBrick
  {
   double open;
   double close;
   int    direction; // +1 up, -1 down
   int    run;       // consecutive bricks in current direction
  };

//+------------------------------------------------------------------+
//| Classic fixed-size Renko builder, two-brick reversal             |
//+------------------------------------------------------------------+
class CRenkoBuilder
  {
private:
   double m_size;
   bool   m_has_anchor;
   double m_anchor;
   double m_last_close;
   int    m_last_dir;
   int    m_run;

   void AddBrick(SRenkoBrick &out[],const double open_price,
                 const double close_price,const int direction)
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
      out[n].open=NormalizeDouble(open_price,_Digits);
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
            const double brick_open=m_anchor;
            m_anchor+=m_size;
            m_last_close=m_anchor;
            AddBrick(out,brick_open,m_last_close,+1);
            added++;
           }

         while(price<=m_anchor-m_size)
           {
            const double brick_open=m_anchor;
            m_anchor-=m_size;
            m_last_close=m_anchor;
            AddBrick(out,brick_open,m_last_close,-1);
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
               const double brick_open=m_last_close;
               m_last_close+=m_size;
               AddBrick(out,brick_open,m_last_close,+1);
               added++;
               changed=true;
              }
            else if(price<=m_last_close-2.0*m_size)
              {
               // Classic two-brick reversal: the new opposite brick begins
               // one brick beyond the old close and closes two bricks beyond it.
               const double brick_open=m_last_close-m_size;
               m_last_close-=2.0*m_size;
               AddBrick(out,brick_open,m_last_close,-1);
               added++;
               changed=true;
              }
           }
         else
           {
            if(price<=m_last_close-m_size)
              {
               const double brick_open=m_last_close;
               m_last_close-=m_size;
               AddBrick(out,brick_open,m_last_close,-1);
               added++;
               changed=true;
              }
            else if(price>=m_last_close+2.0*m_size)
              {
               const double brick_open=m_last_close+m_size;
               m_last_close+=2.0*m_size;
               AddBrick(out,brick_open,m_last_close,+1);
               added++;
               changed=true;
              }
           }
        }

      return added;
     }
  };

//+------------------------------------------------------------------+
//| SuperTrend state calculated on completed Renko bricks            |
//| ATR uses Wilder smoothing after the initial arithmetic average.  |
//+------------------------------------------------------------------+
class CRenkoSuperTrend
  {
private:
   int    m_period;
   double m_multiplier;
   int    m_tr_count;
   double m_tr_sum;
   double m_atr;
   double m_prev_close;
   double m_final_upper;
   double m_final_lower;
   double m_line;
   int    m_trend;
   bool   m_ready;

public:
   void Init(const int period,const double multiplier)
     {
      m_period=period;
      m_multiplier=multiplier;
      m_tr_count=0;
      m_tr_sum=0.0;
      m_atr=0.0;
      m_prev_close=0.0;
      m_final_upper=0.0;
      m_final_lower=0.0;
      m_line=0.0;
      m_trend=0;
      m_ready=false;
     }

   bool Ready(void) const { return m_ready; }
   int Trend(void) const { return m_trend; }
   double Line(void) const { return m_line; }
   double ATR(void) const { return m_atr; }

   void PushBrick(const SRenkoBrick &brick)
     {
      const double high=MathMax(brick.open,brick.close);
      const double low =MathMin(brick.open,brick.close);

      double tr=high-low;
      if(m_prev_close>0.0)
        {
         tr=MathMax(tr,MathAbs(high-m_prev_close));
         tr=MathMax(tr,MathAbs(low-m_prev_close));
        }

      if(!m_ready)
        {
         m_tr_sum+=tr;
         m_tr_count++;
         m_prev_close=brick.close;

         if(m_tr_count<m_period)
            return;

         m_atr=m_tr_sum/(double)m_period;
         const double mid=(high+low)*0.5;
         m_final_upper=mid+m_multiplier*m_atr;
         m_final_lower=mid-m_multiplier*m_atr;
         m_trend=brick.direction;
         m_line=(m_trend>0 ? m_final_lower : m_final_upper);
         m_ready=true;
         return;
        }

      // Wilder ATR update on each completed Renko brick.
      m_atr=(m_atr*(m_period-1)+tr)/(double)m_period;

      const double mid=(high+low)*0.5;
      const double basic_upper=mid+m_multiplier*m_atr;
      const double basic_lower=mid-m_multiplier*m_atr;

      double new_upper=m_final_upper;
      double new_lower=m_final_lower;

      if(basic_upper<m_final_upper || m_prev_close>m_final_upper)
         new_upper=basic_upper;
      if(basic_lower>m_final_lower || m_prev_close<m_final_lower)
         new_lower=basic_lower;

      int new_trend=m_trend;
      double new_line=m_line;

      if(m_trend>0)
        {
         if(brick.close<new_lower)
           {
            new_trend=-1;
            new_line=new_upper;
           }
         else
           {
            new_trend=+1;
            new_line=new_lower;
           }
        }
      else
        {
         if(brick.close>new_upper)
           {
            new_trend=+1;
            new_line=new_lower;
           }
         else
           {
            new_trend=-1;
            new_line=new_upper;
           }
        }

      m_final_upper=new_upper;
      m_final_lower=new_lower;
      m_trend=new_trend;
      m_line=new_line;
      m_prev_close=brick.close;
     }
  };

CRenkoBuilder    g_renko;
CRenkoSuperTrend g_st;
int g_renko_dir=0;
int g_renko_run=0;
int g_st_dir=0;
int g_cooldown_left=0;

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
bool FindOurPosition(ulong &ticket,long &type,double &volume,
                     double &open_price,datetime &open_time)
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
   const double spread=tick.ask-tick.bid;
   return (spread<=InpBrickSize*InpMaxSpreadFraction);
  }

//+------------------------------------------------------------------+
int SecondsOfDay(const datetime value)
  {
   MqlDateTime part={};
   if(!TimeToStruct(value,part))
      return -1;
   return part.hour*3600+part.min*60+part.sec;
  }

//+------------------------------------------------------------------+
bool TradingSessionIsOpen(void)
  {
   const datetime now=TimeCurrent();
   MqlDateTime current={};
   if(!TimeToStruct(now,current))
      return true; // Do not block trading if terminal time cannot be decoded.

   const int current_seconds=current.hour*3600+current.min*60+current.sec;
   const ENUM_DAY_OF_WEEK day=(ENUM_DAY_OF_WEEK)current.day_of_week;
   bool session_info_found=false;

   for(uint session=0; session<24; session++)
     {
      datetime from=0;
      datetime to=0;
      ResetLastError();
      if(!SymbolInfoSessionTrade(_Symbol,day,session,from,to))
         break;

      session_info_found=true;
      const int from_seconds=SecondsOfDay(from);
      const int to_seconds=SecondsOfDay(to);
      if(from_seconds<0 || to_seconds<0)
         continue;

      // Equal endpoints are treated as a full-day session.
      if(from_seconds==to_seconds)
         return true;

      if(from_seconds<to_seconds)
        {
         if(current_seconds>=from_seconds && current_seconds<to_seconds)
            return true;
        }
      else
        {
         // Session crosses midnight.
         if(current_seconds>=from_seconds || current_seconds<to_seconds)
            return true;
        }
     }

   // Some brokers do not publish session metadata. In that case preserve
   // normal EA behaviour instead of blocking all trading.
   if(!session_info_found)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
bool SendMarket(const int direction)
  {
   if(direction!=1 && direction!=-1) return false;
   if(AnyPositionOnSymbol()) return false;
   if(!TradingSessionIsOpen()) return false;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return false;
   if(!SpreadIsAcceptable(tick)) return false;

   MqlTradeRequest request={};
   MqlTradeResult result={};

   request.action=TRADE_ACTION_DEAL;
   request.magic=GDS_MAGIC;
   request.symbol=_Symbol;
   request.volume=NormalizeVolume(InpLots);
   request.deviation=50;
   request.type_filling=FillingMode();
   request.comment="GDS Renko ST Demo";

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
      Print("GDS Renko SuperTrend Demo: entry OrderSend failed. Error ",GetLastError());
      return false;
     }

   if(result.retcode!=TRADE_RETCODE_DONE &&
      result.retcode!=TRADE_RETCODE_DONE_PARTIAL &&
      result.retcode!=TRADE_RETCODE_PLACED)
     {
      Print("GDS Renko SuperTrend Demo: entry rejected. Retcode ",
            result.retcode," ",result.comment);
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

   // If the broker has a daily maintenance break, keep the position and
   // retry naturally on the first tick of the next tradable session.
   // This avoids repeated TRADE_RETCODE_MARKET_CLOSED requests.
   if(!TradingSessionIsOpen())
      return false;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return false;

   MqlTradeRequest request={};
   MqlTradeResult result={};
   request.action=TRADE_ACTION_DEAL;
   request.magic=GDS_MAGIC;
   request.position=ticket;
   request.symbol=_Symbol;
   request.volume=volume;
   request.deviation=50;
   request.type_filling=FillingMode();
   request.comment="GDS Renko ST exit";

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
      Print("GDS Renko SuperTrend Demo: close failed. Error ",GetLastError());
      return false;
     }

   if(result.retcode!=TRADE_RETCODE_DONE &&
      result.retcode!=TRADE_RETCODE_DONE_PARTIAL &&
      result.retcode!=TRADE_RETCODE_PLACED)
     {
      Print("GDS Renko SuperTrend Demo: close rejected. Retcode ",
            result.retcode," ",result.comment);
      return false;
     }

   Print("GDS Renko SuperTrend Demo exit: ",reason);
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
void UpdateRenkoAndTrade(const double price)
  {
   SRenkoBrick bricks[];
   const int n=g_renko.PushPrice(price,bricks);
   if(n<=0) return;

   if(g_cooldown_left>0)
     {
      g_cooldown_left-=n;
      if(g_cooldown_left<0) g_cooldown_left=0;
     }

   // Feed every completed brick to SuperTrend in the exact Renko order.
   for(int i=0;i<n;i++)
      g_st.PushBrick(bricks[i]);

   g_renko_dir=bricks[n-1].direction;
   g_renko_run=bricks[n-1].run;
   g_st_dir=(g_st.Ready() ? g_st.Trend() : 0);

   ulong ticket=0;
   long type=-1;
   double volume=0.0;
   double open_price=0.0;
   datetime open_time=0;
   const bool have_position=FindOurPosition(ticket,type,volume,open_price,open_time);

   if(have_position)
     {
      const int position_dir=(type==POSITION_TYPE_BUY ? +1 : -1);
      if(g_st_dir!=0 && g_st_dir!=position_dir)
         CloseOurPosition("SUPERTREND FLIP");
      return;
     }

   if(AnyPositionOnSymbol()) return;
   if(g_cooldown_left>0) return;
   if(!g_st.Ready()) return;
   if(g_st_dir==0 || g_renko_dir==0) return;
   if(g_renko_dir!=g_st_dir) return;
   if(g_renko_run<InpEntryRunBricks) return;

   SendMarket(g_st_dir);
  }

//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(InpBrickSize<=0.0 ||
      InpSTPeriod<2 ||
      InpSTMultiplier<=0.0 ||
      InpEntryRunBricks<1 ||
      InpTakeProfitBricks<=0.0 ||
      InpStopLossBricks<=0.0 ||
      InpMaxHoldMinutes<0 ||
      InpCooldownBricks<0 ||
      InpMaxSpreadFraction<=0.0 ||
      InpLots<=0.0)
     {
      Print("GDS Renko SuperTrend Demo: invalid inputs.");
      return INIT_PARAMETERS_INCORRECT;
     }

   g_renko.Init(InpBrickSize);
   g_st.Init(InpSTPeriod,InpSTMultiplier);
   g_renko_dir=0;
   g_renko_run=0;
   g_st_dir=0;
   g_cooldown_left=0;

   Print("GDS Renko SuperTrend Demo v1.11 started. Brick=",
         DoubleToString(InpBrickSize,_Digits),
         ", ST Period=",InpSTPeriod,
         ", ST Mult=",DoubleToString(InpSTMultiplier,2),
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
   if(!SymbolInfoTick(_Symbol,tick)) return;
   if(tick.bid<=0.0 || tick.ask<=0.0) return;

   // Price-based exits use executable BID/ASK on every tester tick.
   CheckPriceExit(tick);

   // Renko and SuperTrend state are updated only from completed BID bricks.
   UpdateRenkoAndTrade(tick.bid);
  }
//+------------------------------------------------------------------+
