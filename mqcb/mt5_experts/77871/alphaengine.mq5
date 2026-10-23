//+------------------------------------------------------------------+
//|                                                  AlphaEngine.mq5 |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23814 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23814"
#property version   "1.00"
#property description "Coastline counter-trend trading model of Golub, Glattfelder & Olsen"
#property description "(The Alpha Engine, SSRN 2951348). Eight limit-order agents, long and short, at delta = 0.25/0.5/1/1.5%. Requires a hedging account."

#include <IntrinsicTime\AeLiveTrader.mqh>

//--- position sizing and risk.
input double InpLotPerUnit =0.02;       // lots per one abstract unit
input double InpMaxUnits   =30.0;       // per-agent inventory cap, units
input long   InpMagicBase  =990000;     // base magic; each agent gets a unique one

//--- which agents of the ensemble to run.
input bool   InpTradeLong  =true;       // run the four long-only agents
input bool   InpTradeShort =true;       // run the four short-only agents

//--- the paper's four base thresholds.
double   g_deltas[4]={0.0025,0.0050,0.0100,0.0150};

CAeLiveTrader g_traders[8];
int      g_count=0;

//+------------------------------------------------------------------+
//| Enforce a hedging account and build the requested agents.        |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   long mode=AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(mode!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Print("AlphaEngine: a hedging account is required "
            "(each cascade step must be its own position). Aborting.");
      return INIT_FAILED;
     }

   if(InpLotPerUnit<=0.0 || InpMaxUnits<=0.0)
     {
      Print("AlphaEngine: LotPerUnit and MaxUnits must be positive.");
      return INIT_FAILED;
     }

   g_count=0;
   for(int s=0;s<4;s++)
     {
      if(InpTradeLong)
        {
         g_traders[g_count].Init(_Symbol,InpMagicBase+s*2,1,
                                 g_deltas[s],InpLotPerUnit,InpMaxUnits);
         g_count++;
        }
      if(InpTradeShort)
        {
         g_traders[g_count].Init(_Symbol,InpMagicBase+s*2+1,-1,
                                 g_deltas[s],InpLotPerUnit,InpMaxUnits);
         g_count++;
        }
     }

   if(g_count==0)
     {
      Print("AlphaEngine: no agents enabled.");
      return INIT_FAILED;
     }
   PrintFormat("AlphaEngine: %d agents live on %s (hedging).",g_count,_Symbol);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Is the symbol inside a trading session right now.                |
//|  Order operations outside a session are rejected as "market      |
//|  closed"; gating on the session keeps the journal clean and the  |
//|  run fast. The runners also pause outside a session, which only  |
//|  matters if the feed keeps quoting while trading is closed.      |
//|  A symbol with no session table for the day is not blocked.      |
//+------------------------------------------------------------------+
bool InTradeSession(void)
  {
   MqlDateTime st;
   TimeToStruct(TimeCurrent(),st);
   ENUM_DAY_OF_WEEK dow=(ENUM_DAY_OF_WEEK)st.day_of_week;
   uint sod=(uint)(st.hour*3600+st.min*60+st.sec);
   datetime from,to;
   uint s=0;
   for(;SymbolInfoSessionTrade(_Symbol,dow,s,from,to);s++)
      if(sod>=(uint)from && sod<(uint)to)
         return true;
   return (s==0);
  }

//+------------------------------------------------------------------+
//| Drive every agent with the freshest quote.                       |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   if(!InTradeSession())
      return;

   MqlTick t;
   if(!SymbolInfoTick(_Symbol,t))
      return;
   if(t.bid<=0.0 || t.ask<=0.0)
      return;

   for(int i=0;i<g_count;i++)
      g_traders[i].OnTickUpdate(t.bid,t.ask,t.time);
  }

//+------------------------------------------------------------------+
//| Cancel resting orders on shutdown; open positions keep their     |
//| take-profits and unwind on their own.                            |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=0;i<g_count;i++)
      g_traders[i].Shutdown();
  }
//+------------------------------------------------------------------+
