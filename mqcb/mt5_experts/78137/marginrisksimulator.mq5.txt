//+------------------------------------------------------------------+
//|                                          MarginRiskSimulator.mq5 |
//|                             Copyright 2026, Radoslaw Karol Lubas |
//|                                            https://www.mql5.com  |
//+------------------------------------------------------------------+
// Draws the prices of the current symbol at which the account would reach
// the broker's margin call and stop out levels. A what-if mode adds a
// hypothetical position, a calculator finds the largest extra volume that
// keeps a safety margin level, and pending orders that would trigger on the
// way can be included. Levels assume that positions on other symbols and
// the margin already held stay unchanged.
// It is an Expert Advisor only because OrderCalcProfit/OrderCalcMargin are
// not allowed in indicators; it never sends, modifies or closes orders.
#property copyright "Copyright 2026, Radoslaw Karol Lubas"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Margin call and stop out price lines, what-if volume and max extra volume for the current symbol."

#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>

//--- object name prefix: every chart object starts with it, cleanup is one call
#define MRS_PREFIX       "MRS_"
#define MRS_ROWS         16       // 8 account rows + up to 8 level rows
#define MRS_LINES        8
#define MRS_SCAN_STEPS   400
#define MRS_BISECT_ITERS 50
#define MRS_MIN_CALC_MS  200      // at most one full pass per 200 ms
#define MRS_MARGIN_PX    10       // panel distance from the chart corner
#define MRS_TEXT_X       8        // text indent inside the panel
#define MRS_TEXT_Y       6        // first row offset inside the panel
#define MRS_ROW_PAD      8        // row height = font size + pad
#define MRS_PANEL_PAD    10       // extra panel height below the last row
#define MRS_EPS          1e-9     // tolerance when converting volumes to steps
#define MRS_MARGIN_CACHE 64       // margin results kept per pass (few distinct volumes)
#define MRS_SLOPE_DELTA  0.01     // price step for the profit slope, fraction of price
#define MRS_CHAR_WIDTH   0.8      // fallback text width per character, x font size
#define MRS_BORDER_COLOR clrSilver

//--- side of the hypothetical position
enum ENUM_MRS_SIDE
  {
   MRS_SIDE_BUY=0,  // Buy
   MRS_SIDE_SELL=1  // Sell
  };

//--- outcome of a level search in one direction
enum ENUM_MRS_FOUND
  {
   MRS_FOUND_NONE=0,  // no level inside the search range
   MRS_FOUND_PRICE=1, // level found at a price
   MRS_FOUND_NOW=2    // level is already reached at the current price
  };

//--- one exposure leg on this symbol: open position, pending order or hypothetical
struct MrsLeg
  {
   double            volume;  // signed lots: + buy, - sell (0 = no leg)
   double            open;    // price the leg's profit is measured from
   double            trigger; // bid that activates a pending leg, 0 = already active
  };

//--- search results, index = level*4 + scenario*2 + direction
//--- level: 0 margin call, 1 stop out; scenario: 0 now, 1 what-if; direction: 0 down, 1 up
struct MrsResult
  {
   double            price[MRS_LINES];
   int               found[MRS_LINES];
   double            level_after;  // margin level % after the what-if position, 0 = n/a
   double            max_volume;   // largest extra volume that fits, -1 = already below, -2 = no step
  };

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "What-if"
input double           InpWhatIfLots      = 0.0;               // Hypothetical extra volume, lots (0 = off)
input ENUM_MRS_SIDE    InpWhatIfSide      = MRS_SIDE_BUY;      // Hypothetical position side
input double           InpSafetyLevel     = 0.0;               // Safety margin level for max volume, % (0 = broker margin call)
input group "Scenario"
input bool             InpIncludePending  = true;              // Include pending orders that trigger on the way
input double           InpSearchRangePct  = 50.0;              // Search range around current price, %
input group "Display"
input bool             InpShowMarginCall  = true;              // Show margin call line
input bool             InpShowStopOut     = true;              // Show stop out line
input color            InpColorMarginCall = clrDarkOrange;     // Margin call line color
input color            InpColorStopOut    = clrRed;            // Stop out line color
input ENUM_BASE_CORNER InpCorner          = CORNER_LEFT_UPPER; // Panel corner
input int              InpFontSize        = 9;                 // Panel font size
input color            InpTextColor       = clrBlack;          // Panel text color
input color            InpPanelColor      = clrWhiteSmoke;     // Panel background color
input int              InpRefreshSec      = 1;                 // Refresh interval, seconds

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
CAccountInfo          g_account;
CSymbolInfo           g_symbol;
CChartObjectRectLabel g_panel;
CChartObjectLabel     g_rows[MRS_ROWS];
CChartObjectHLine     g_lines[MRS_LINES];
MrsLeg                g_legs[];          // open positions and pending orders of this symbol
MrsLeg                g_whatif;          // hypothetical leg, volume 0 = off
MrsLeg                g_none;            // empty leg for the "now" scenario
double g_bid=0.0,g_ask=0.0,g_spread=0.0;
double g_equity0=0.0,g_margin0=0.0;
double g_slope_lot=0.0;                  // account money per 1.0 price move for 1 lot long
double g_net0=0.0;                       // signed net lots of open positions on this symbol
double g_pos_buy=0.0,g_pos_sell=0.0;     // lots of open buy / sell positions on this symbol
double g_other_margin=0.0;               // margin held by everything except this symbol
double g_cache_buy[MRS_MARGIN_CACHE];    // symbol margin cache: buy lots,
double g_cache_sell[MRS_MARGIN_CACHE];   // sell lots
double g_cache_value[MRS_MARGIN_CACHE];  // and the margin for them
int    g_cache_count=0;
bool   g_margin_failed=false;          // an OrderCalcMargin call failed in this pass
bool   g_legs_failed=false;            // a leg could not be stored (out of memory)
double g_side_buy=0.0,g_side_sell=0.0;   // lots of positions + orders per side (volume limit)
double g_range_pct=50.0;
double g_last_signature=-1.0;            // state of the previous pass, skips idle redraws
bool   g_hedging=true;
bool   g_exchange=false;
bool   g_inverse_quote=false;            // profit converted at this symbol's own rate
int    g_pending_count=0;
ulong  g_last_calc_ms=0;
string g_error="";

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpWhatIfLots<0.0 || InpSafetyLevel<0.0 || InpSearchRangePct<=0.0 ||
      InpSearchRangePct>100.0 || InpRefreshSec<1 || InpFontSize<6)
     {
      Print("MarginRiskSimulator: invalid inputs (lots >= 0, range 0-100 %, refresh >= 1 s, font >= 6)");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(!g_symbol.Name(_Symbol))
      return(INIT_FAILED);
   g_range_pct=InpSearchRangePct;
   ClearLeg(g_none);
   ClearLeg(g_whatif);
   g_last_calc_ms=0;
   g_last_signature=-1.0;
//--- get notified when one of our objects is deleted, to draw it again
   ChartSetInteger(0,CHART_EVENT_OBJECT_DELETE,true);
   if(!EventSetTimer(InpRefreshSec))
     {
      Print("MarginRiskSimulator: timer failed, error ",GetLastError());
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0,MRS_PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| New tick of this symbol                                          |
//+------------------------------------------------------------------+
void OnTick()
  {
   Recalculate();
  }

//+------------------------------------------------------------------+
//| Positions or orders changed: refresh at once, not on next tick   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   g_last_calc_ms=0;
   Recalculate();
  }

//+------------------------------------------------------------------+
//| One of our objects was deleted (e.g. by the user): draw again    |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_DELETE && StringFind(sparam,MRS_PREFIX)==0)
     {
      g_last_signature=-1.0;
      g_last_calc_ms=0;
      Recalculate();
     }
  }

//+------------------------------------------------------------------+
//| Timer: positions on other symbols change equity without a tick   |
//| on this chart                                                    |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Recalculate();
  }

//+------------------------------------------------------------------+
//| Full refresh: throttled, and skipped when nothing has changed    |
//+------------------------------------------------------------------+
void Recalculate()
  {
   ulong now=GetTickCount64();
   if(g_last_calc_ms>0 && now-g_last_calc_ms<MRS_MIN_CALC_MS)
      return;
   g_last_calc_ms=now;
   if(!LoadMarketState())
     {
      g_last_signature=-1.0;
      DrawError();
      return;
     }
   if(!LoadLegs())
     {
      g_last_signature=-1.0;
      DrawError();
      return;
     }
   BuildWhatIf();
   double signature=StateSignature();
   if(signature==g_last_signature)
      return;
   g_last_signature=signature;
   MrsResult res;
   ComputeResults(res);
   DrawLines(res);
   DrawPanel(res);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| One number that changes whenever an input of the calculation     |
//| changes: quotes, equity, margin and every leg                    |
//+------------------------------------------------------------------+
double StateSignature()
  {
   double sig=g_bid*7.0+g_ask*11.0+g_equity0*13.0+g_margin0*17.0;
   int n=ArraySize(g_legs);
   for(int i=0;i<n;i++)
      sig+=(i+19.0)*(g_legs[i].volume*23.0+g_legs[i].open*29.0+g_legs[i].trigger*31.0);
   sig+=g_side_buy*43.0+g_side_sell*47.0+g_account.Balance()*53.0;
   sig+=g_account.MarginCall()*59.0+g_account.MarginStopOut()*61.0+(int)g_account.StopoutMode()*67.0;
   return(sig+n*37.0+g_pending_count*41.0);
  }

//+------------------------------------------------------------------+
//| Reset a leg to "no leg"                                          |
//+------------------------------------------------------------------+
void ClearLeg(MrsLeg &leg)
  {
   leg.volume=0.0;
   leg.open=0.0;
   leg.trigger=0.0;
  }

//+------------------------------------------------------------------+
//| Quotes, account state, profit slope and margin per lot           |
//+------------------------------------------------------------------+
bool LoadMarketState()
  {
   if(!g_symbol.RefreshRates() || g_symbol.Bid()<=0.0 || g_symbol.Ask()<=0.0)
     {
      g_error="Waiting for quotes";
      return(false);
     }
   g_bid=g_symbol.Bid();
   g_ask=g_symbol.Ask();
   g_spread=g_ask-g_bid;
   g_equity0=g_account.Equity();
   g_margin0=g_account.Margin();
   g_hedging=(g_account.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
   g_exchange=(g_account.MarginMode()==ACCOUNT_MARGIN_MODE_EXCHANGE);
//--- e.g. EURUSD on a EUR account: profit in USD is converted at EURUSD itself
   string ccy=g_account.Currency();
   g_inverse_quote=(g_symbol.CurrencyBase()==ccy && g_symbol.CurrencyProfit()!=ccy);
   double delta=MathMax(g_bid*MRS_SLOPE_DELTA,g_symbol.Point());
   double profit=0.0;
   ResetLastError();
   if(!OrderCalcProfit(ORDER_TYPE_BUY,_Symbol,1.0,g_bid,g_bid+delta,profit) || profit<=0.0)
     {
      g_error="OrderCalcProfit failed, error "+IntegerToString(GetLastError());
      return(false);
     }
   g_slope_lot=profit/delta;
//--- OrderCalcProfit converts at the close price; bring the slope back to
//--- the current price, LegProfit then converts at the simulated one
   if(g_inverse_quote)
      g_slope_lot*=(g_bid+delta)/g_bid;
   g_cache_count=0;
   g_margin_failed=false;
   double test=0.0;
   ResetLastError();
   if(!OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,1.0,g_ask,test))
     {
      g_error="OrderCalcMargin failed, error "+IntegerToString(GetLastError());
      return(false);
     }
   g_error="";
   return(true);
  }

//+------------------------------------------------------------------+
//| Append one leg                                                   |
//+------------------------------------------------------------------+
void AddLeg(const double volume,const double open,const double trigger)
  {
   int n=ArraySize(g_legs);
   if(ArrayResize(g_legs,n+1,16)!=n+1)
     {
      g_legs_failed=true;
      return;
     }
   g_legs[n].volume=volume;
   g_legs[n].open=open;
   g_legs[n].trigger=trigger;
  }

//+------------------------------------------------------------------+
//| Open positions and pending orders of this symbol                 |
//+------------------------------------------------------------------+
bool LoadLegs()
  {
   ArrayResize(g_legs,0,16);
   g_legs_failed=false;
   g_net0=0.0;
   g_pos_buy=0.0;
   g_pos_sell=0.0;
   CPositionInfo pos;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      if(!pos.SelectByIndex(i) || pos.Symbol()!=_Symbol)
         continue;
      bool buy=(pos.PositionType()==POSITION_TYPE_BUY);
      double vol=buy ? pos.Volume() : -pos.Volume();
      //--- equity already holds the current profit, so a position's change is
      //--- measured from the price it would close at right now
      AddLeg(vol,buy ? g_bid : g_ask,0.0);
      g_net0+=vol;
      if(buy)
         g_pos_buy+=pos.Volume();
      else
         g_pos_sell+=pos.Volume();
     }
   g_side_buy=g_pos_buy;
   g_side_sell=g_pos_sell;
   LoadOrders();
   if(g_legs_failed)
     {
      g_error="Out of memory while reading positions";
      return(false);
     }
   double own=SymbolMarginFor(g_pos_buy,g_pos_sell);
   if(own<0.0)
     {
      g_error="OrderCalcMargin failed, error "+IntegerToString(GetLastError());
      return(false);
     }
   g_other_margin=MathMax(0.0,g_margin0-own);
   return(true);
  }

//+------------------------------------------------------------------+
//| Pending orders: all count toward the volume limit, limit/stop    |
//| orders become legs when enabled; stop-limit orders are skipped   |
//| as legs because their fill depends on the price path             |
//+------------------------------------------------------------------+
void LoadOrders()
  {
   g_pending_count=0;
   COrderInfo ord;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(!ord.SelectByIndex(i) || ord.Symbol()!=_Symbol)
         continue;
      ENUM_ORDER_TYPE type=ord.OrderType();
      //--- market and close-by orders in execution are not pending orders
      if(type<ORDER_TYPE_BUY_LIMIT || type>ORDER_TYPE_SELL_STOP_LIMIT)
         continue;
      double vol=ord.VolumeCurrent();
      bool buy=(type==ORDER_TYPE_BUY_LIMIT || type==ORDER_TYPE_BUY_STOP || type==ORDER_TYPE_BUY_STOP_LIMIT);
      if(buy)
         g_side_buy+=vol;
      else
         g_side_sell+=vol;
      if(!InpIncludePending || type==ORDER_TYPE_BUY_STOP_LIMIT || type==ORDER_TYPE_SELL_STOP_LIMIT)
         continue;
      double price=ord.PriceOpen();
      //--- a buy order fills when the ask reaches its price, a sell order on the bid
      AddLeg(buy ? vol : -vol,price,buy ? price-g_spread : price);
      g_pending_count++;
     }
  }

//+------------------------------------------------------------------+
//| Round a volume to the symbol's volume step and limits            |
//+------------------------------------------------------------------+
double NormalizeVolume(const double volume)
  {
   double step=g_symbol.LotsStep();
   if(step<=0.0)
      return(volume);
   double v=MathRound(volume/step)*step;
   v=MathMax(v,g_symbol.LotsMin());
   v=MathMin(v,g_symbol.LotsMax());
   return(NormalizeDouble(v,8));
  }

//+------------------------------------------------------------------+
//| Hypothetical position opened at the current price                |
//+------------------------------------------------------------------+
void MakeLeg(MrsLeg &leg,const double signed_volume)
  {
   bool buy=(signed_volume>0.0);
   leg.volume=signed_volume;
   leg.open=buy ? g_ask : g_bid;
   leg.trigger=0.0;
  }

//+------------------------------------------------------------------+
//| What-if leg from the inputs                                      |
//+------------------------------------------------------------------+
void BuildWhatIf()
  {
   ClearLeg(g_whatif);
   if(InpWhatIfLots<=0.0)
      return;
   double vol=NormalizeVolume(InpWhatIfLots);
   MakeLeg(g_whatif,(InpWhatIfSide==MRS_SIDE_BUY) ? vol : -vol);
  }

//+------------------------------------------------------------------+
//| Profit of a leg when the bid is at the given price               |
//+------------------------------------------------------------------+
double LegProfit(const MrsLeg &leg,const double bid)
  {
//--- longs close at the bid, shorts at the ask (current spread assumed)
   double close_price=(leg.volume>0.0) ? bid : bid+g_spread;
   double profit=g_slope_lot*leg.volume*(close_price-leg.open);
//--- the slope uses today's conversion rate; when that rate is this symbol,
//--- convert at the simulated price instead
   if(g_inverse_quote && bid>0.0)
      profit*=g_bid/bid;
   return(profit);
  }

//+------------------------------------------------------------------+
//| Is the leg active when the bid moves from now to the given price |
//+------------------------------------------------------------------+
bool LegActive(const MrsLeg &leg,const double bid)
  {
   if(leg.trigger<=0.0)
      return(true);
   if(bid<=g_bid)
      return(leg.trigger<=g_bid && leg.trigger>=bid);
   return(leg.trigger>=g_bid && leg.trigger<=bid);
  }

//+------------------------------------------------------------------+
//| Native margin of one side for the whole volume (brokers can tier |
//| leverage by volume, so 10 lots may cost more than 10 x 1 lot)    |
//+------------------------------------------------------------------+
bool SideMargin(const ENUM_ORDER_TYPE type,const double volume,double &margin)
  {
   margin=0.0;
   if(volume<=MRS_EPS)
      return(true);
   double price=(type==ORDER_TYPE_BUY) ? g_ask : g_bid;
   ResetLastError();
   return(OrderCalcMargin(type,_Symbol,NormalizeDouble(volume,8),price,margin));
  }

//+------------------------------------------------------------------+
//| Margin of this symbol for given buy/sell lots, cached per pass:  |
//| the searches ask for only a few distinct volume combinations.    |
//| Returns -1 when the terminal cannot calculate it (not cached)    |
//+------------------------------------------------------------------+
double SymbolMarginFor(const double buy_vol,const double sell_vol)
  {
   for(int i=0;i<g_cache_count;i++)
      if(MathAbs(g_cache_buy[i]-buy_vol)<MRS_EPS && MathAbs(g_cache_sell[i]-sell_vol)<MRS_EPS)
         return(g_cache_value[i]);
//--- hedging: both sides are charged in full, without the hedged-margin
//--- discount, which keeps the estimate on the safe side
   double m_buy=0.0,m_sell=0.0;
   if(!SideMargin(ORDER_TYPE_BUY,buy_vol,m_buy) || !SideMargin(ORDER_TYPE_SELL,sell_vol,m_sell))
     {
      g_margin_failed=true;
      return(-1.0);
     }
   double margin=m_buy+m_sell;
   if(g_cache_count<MRS_MARGIN_CACHE)
     {
      g_cache_buy[g_cache_count]=buy_vol;
      g_cache_sell[g_cache_count]=sell_vol;
      g_cache_value[g_cache_count]=margin;
      g_cache_count++;
     }
   return(margin);
  }

//+------------------------------------------------------------------+
//| Account margin for given lots of this symbol (netting: only the  |
//| net position is charged); -1 when it cannot be calculated        |
//+------------------------------------------------------------------+
double MarginFor(const double buy_vol,const double sell_vol)
  {
   double own=0.0;
   if(g_hedging)
      own=SymbolMarginFor(buy_vol,sell_vol);
   else
     {
      double net=buy_vol-sell_vol;
      own=SymbolMarginFor(MathMax(net,0.0),MathMax(-net,0.0));
     }
   return(own<0.0 ? -1.0 : g_other_margin+own);
  }

//+------------------------------------------------------------------+
//| Equity and margin when the bid is at the given price             |
//+------------------------------------------------------------------+
void Evaluate(const double bid,const MrsLeg &extra,double &equity,double &margin)
  {
   equity=g_equity0;
   double buy_vol=g_pos_buy,sell_vol=g_pos_sell;
   int n=ArraySize(g_legs);
   for(int i=0;i<n;i++)
     {
      if(!LegActive(g_legs[i],bid))
         continue;
      equity+=LegProfit(g_legs[i],bid);
      if(g_legs[i].trigger<=0.0)
         continue;
      if(g_legs[i].volume>0.0)
         buy_vol+=g_legs[i].volume;
      else
         sell_vol-=g_legs[i].volume;
     }
   if(extra.volume!=0.0)
     {
      equity+=LegProfit(extra,bid);
      if(extra.volume>0.0)
         buy_vol+=extra.volume;
      else
         sell_vol-=extra.volume;
     }
   margin=MarginFor(buy_vol,sell_vol);
  }

//+------------------------------------------------------------------+
//| Broker rule: % of margin, or free margin in money mode. A margin |
//| that could not be calculated (-1) counts as breached, so a       |
//| failure never makes the account look safer than it is            |
//+------------------------------------------------------------------+
bool IsBreached(const double level,const double equity,const double margin)
  {
   if(margin<0.0)
      return(true);
   if(margin==0.0)
      return(false);
   if(g_account.StopoutMode()==ACCOUNT_STOPOUT_MODE_PERCENT)
      return(equity/margin*100.0<=level);
   return(equity-margin<=level);
  }

//+------------------------------------------------------------------+
//| Is the level reached when the bid is at the given price          |
//+------------------------------------------------------------------+
bool BreachedAt(const double bid,const double level,const MrsLeg &extra)
  {
   double equity=0.0,margin=0.0;
   Evaluate(bid,extra,equity,margin);
   return(IsBreached(level,equity,margin));
  }

//+------------------------------------------------------------------+
//| Narrow [ok, bad] down to the first price that reaches the level  |
//+------------------------------------------------------------------+
double Bisect(double ok,double bad,const double level,const MrsLeg &extra)
  {
   for(int i=0;i<MRS_BISECT_ITERS;i++)
     {
      double mid=(ok+bad)*0.5;
      if(BreachedAt(mid,level,extra))
         bad=mid;
      else
         ok=mid;
     }
   return(NormalizeDouble(bad,_Digits));
  }

//+------------------------------------------------------------------+
//| Prices to test in one direction: an even grid plus every pending |
//| trigger and the price just before it, so a narrow breach right   |
//| before an order fills is never stepped over                      |
//+------------------------------------------------------------------+
int ScanPoints(const int dir,const double limit,double &pts[])
  {
   int n=ArraySize(g_legs);
   if(ArrayResize(pts,MRS_SCAN_STEPS+2*n)<0)
      return(0);
   int m=0;
   double step=(limit-g_bid)/MRS_SCAN_STEPS;
   for(int i=1;i<=MRS_SCAN_STEPS;i++)
      pts[m++]=g_bid+step*i;
   double lo=MathMin(g_bid,limit),hi=MathMax(g_bid,limit);
   for(int i=0;i<n;i++)
     {
      double t=g_legs[i].trigger;
      if(t<=0.0 || t<=lo || t>=hi)
         continue;
      if((dir<0 && t>=g_bid) || (dir>0 && t<=g_bid))
         continue;
      pts[m++]=t;
      double before=t-dir*g_symbol.Point();
      if(before>lo && before<hi)
         pts[m++]=before;
     }
   ArrayResize(pts,m);
   ArraySort(pts);
   return(m);
  }

//+------------------------------------------------------------------+
//| Walk from the current price in one direction until the level is  |
//| reached, then bisect between the last safe and first bad point   |
//+------------------------------------------------------------------+
ENUM_MRS_FOUND FindLevel(const double level,const MrsLeg &extra,const int dir,double &price)
  {
   price=0.0;
   if(BreachedAt(g_bid,level,extra))
      return(MRS_FOUND_NOW);
   double range=g_bid*g_range_pct/100.0;
   double limit=(dir<0) ? MathMax(g_symbol.Point(),g_bid-range) : g_bid+range;
   double pts[];
   int m=ScanPoints(dir,limit,pts);
   double prev=g_bid;
   for(int k=0;k<m;k++)
     {
      double p=(dir>0) ? pts[k] : pts[m-1-k];  // walk outward from the current price
      if(BreachedAt(p,level,extra))
        {
         price=Bisect(prev,p,level,extra);
         return(MRS_FOUND_PRICE);
        }
      prev=p;
     }
   return(MRS_FOUND_NONE);
  }

//+------------------------------------------------------------------+
//| Does an extra position of this signed volume keep the safety     |
//| level and a non-negative free margin right after opening         |
//+------------------------------------------------------------------+
bool VolumeFits(const double signed_volume)
  {
   MrsLeg leg;
   MakeLeg(leg,signed_volume);
   double equity=0.0,margin=0.0;
   Evaluate(g_bid,leg,equity,margin);
   if(margin<0.0 || equity-margin<0.0)
      return(false);
   if(InpSafetyLevel>0.0)
      return(margin<=0.0 || equity/margin*100.0>=InpSafetyLevel);
   return(!IsBreached(g_account.MarginCall(),equity,margin));
  }

//+------------------------------------------------------------------+
//| Largest extra volume (in volume steps) that still fits. At a     |
//| fixed price equity falls and margin rises with the added volume, |
//| so the fitting volumes form one interval from the minimum up;    |
//| when even the minimum volume does not fit, -1 is returned        |
//| (netting reversals are not searched further out: conservative)   |
//+------------------------------------------------------------------+
double MaxExtraVolume(const double side_sign)
  {
   double step=g_symbol.LotsStep();
   if(step<=0.0)
      return(-2.0);   // volume step unknown
   double cap=g_symbol.LotsMax();
//--- the volume limit covers positions and orders already open on this side
   if(g_symbol.LotsLimit()>0.0)
      cap=MathMin(cap,g_symbol.LotsLimit()-((side_sign>0.0) ? g_side_buy : g_side_sell));
   long k_min=(long)MathMax(1.0,MathCeil(g_symbol.LotsMin()/step-MRS_EPS));
   long k_max=(long)MathFloor(MathMax(0.0,cap)/step+MRS_EPS);
   if(k_max<k_min)
      return(0.0);
   if(!VolumeFits(side_sign*(double)k_min*step))
      return(-1.0);
   long lo=k_min,hi=k_max;
   while(lo<hi)
     {
      long mid=lo+(hi-lo+1)/2;
      if(VolumeFits(side_sign*(double)mid*step))
         lo=mid;
      else
         hi=mid-1;
     }
   return(NormalizeDouble((double)lo*step,8));
  }

//+------------------------------------------------------------------+
//| All level searches, the what-if margin level and max volume      |
//+------------------------------------------------------------------+
void ComputeResults(MrsResult &res)
  {
   double levels[2];
   levels[0]=g_account.MarginCall();
   levels[1]=g_account.MarginStopOut();
   for(int idx=0;idx<MRS_LINES;idx++)
     {
      int lv=idx/4,sc=(idx/2)%2,dir=(idx%2==0) ? -1 : 1;
      res.price[idx]=0.0;
      res.found[idx]=MRS_FOUND_NONE;
      if(sc==0)
         res.found[idx]=FindLevel(levels[lv],g_none,dir,res.price[idx]);
      else
         if(g_whatif.volume!=0.0)
            res.found[idx]=FindLevel(levels[lv],g_whatif,dir,res.price[idx]);
     }
   res.level_after=0.0;
   if(g_whatif.volume!=0.0)
     {
      double equity=0.0,margin=0.0;
      Evaluate(g_bid,g_whatif,equity,margin);
      if(margin>0.0)
         res.level_after=equity/margin*100.0;
     }
   res.max_volume=MaxExtraVolume((InpWhatIfSide==MRS_SIDE_BUY) ? 1.0 : -1.0);
  }

//+------------------------------------------------------------------+
//| Create, move or remove one horizontal level line                 |
//+------------------------------------------------------------------+
void SetLine(const int idx,const double price,const color clr,
             const ENUM_LINE_STYLE style,const string text)
  {
   string name=MRS_PREFIX+"line_"+IntegerToString(idx);
   if(g_lines[idx].ChartId()!=-1 && ObjectFind(0,name)<0)
      g_lines[idx].Detach();   // removed by the user: recreate below
   if(price<=0.0)
     {
      if(g_lines[idx].ChartId()!=-1)
         g_lines[idx].Delete();
      return;
     }
   if(g_lines[idx].ChartId()==-1)
     {
      if(!g_lines[idx].Create(0,name,0,price))
         return;
      g_lines[idx].Selectable(false);
      g_lines[idx].Background(false);
      g_lines[idx].SetInteger(OBJPROP_HIDDEN,true);
     }
   g_lines[idx].Price(0,price);
   g_lines[idx].Color(clr);
   g_lines[idx].Style(style);
   g_lines[idx].Width(style==STYLE_SOLID ? 2 : 1);
   g_lines[idx].Description(text);
   g_lines[idx].Tooltip(text+" "+DoubleToString(price,_Digits));
  }

//+------------------------------------------------------------------+
//| Draw every found level as a line (both directions)               |
//+------------------------------------------------------------------+
void DrawLines(const MrsResult &res)
  {
   for(int idx=0;idx<MRS_LINES;idx++)
     {
      bool is_mc=(idx<4);
      bool whatif=((idx/2)%2==1);
      bool show=is_mc ? InpShowMarginCall : InpShowStopOut;
      double price=(show && res.found[idx]==MRS_FOUND_PRICE) ? res.price[idx] : 0.0;
      string text=(is_mc ? "Margin call" : "Stop out")+(whatif ? " (what-if)" : "");
      SetLine(idx,price,is_mc ? InpColorMarginCall : InpColorStopOut,
              whatif ? STYLE_DASH : STYLE_SOLID,text);
     }
  }

//+------------------------------------------------------------------+
//| Broker level as text: percent or account money                   |
//+------------------------------------------------------------------+
string LevelValueText(const double level)
  {
   if(g_account.StopoutMode()==ACCOUNT_STOPOUT_MODE_PERCENT)
      return(DoubleToString(level,0)+" %");
   return(DoubleToString(level,2)+" "+g_account.Currency());
  }

//+------------------------------------------------------------------+
//| Nearest level of one scenario: price, distance in points and %   |
//+------------------------------------------------------------------+
string LevelText(const MrsResult &res,const int base,const bool exposed)
  {
   if(res.found[base]==MRS_FOUND_NOW || res.found[base+1]==MRS_FOUND_NOW)
      return("REACHED NOW");
   if(!exposed)
      return("no exposure on this symbol");
   int pick=-1;
   double best=DBL_MAX;
   for(int d=0;d<2;d++)
      if(res.found[base+d]==MRS_FOUND_PRICE && MathAbs(res.price[base+d]-g_bid)<best)
        {
         best=MathAbs(res.price[base+d]-g_bid);
         pick=base+d;
        }
   if(pick<0)
      return(StringFormat("none within +/-%.0f%%",g_range_pct));
   double dist=res.price[pick]-g_bid;
   return(StringFormat("%s  %+.0f pts  %+.1f%%",DoubleToString(res.price[pick],_Digits),
                       dist/g_symbol.Point(),dist/g_bid*100.0));
  }

//+------------------------------------------------------------------+
//| Append one panel row, never past the array                       |
//+------------------------------------------------------------------+
void AddRow(string &rows[],int &n,const string text)
  {
   if(n<ArraySize(rows))
      rows[n++]=text;
  }

//+------------------------------------------------------------------+
//| Rows describing the account                                      |
//+------------------------------------------------------------------+
void AccountRows(string &rows[],int &n)
  {
   string ccy=g_account.Currency();
   double level=g_account.MarginLevel();
   AddRow(rows,n,"Margin Risk Simulator  "+_Symbol);
   AddRow(rows,n,StringFormat("Balance       %.2f %s",g_account.Balance(),ccy));
   AddRow(rows,n,StringFormat("Equity        %.2f",g_equity0));
   AddRow(rows,n,StringFormat("Margin        %.2f   Free %.2f",g_margin0,g_account.FreeMargin()));
   AddRow(rows,n,"Margin level  "+(g_margin0>0.0 ? DoubleToString(level,1)+" %" : "-"));
   AddRow(rows,n,"Broker MC/SO  "+LevelValueText(g_account.MarginCall())+" / "+
          LevelValueText(g_account.MarginStopOut()));
   AddRow(rows,n,StringFormat("Net %s  %+.2f lots (%s)",_Symbol,g_net0,
                              g_hedging ? "hedging" : "netting"));
   AddRow(rows,n,"Pending       "+(InpIncludePending ? IntegerToString(g_pending_count)+" included" : "off"));
  }

//+------------------------------------------------------------------+
//| Max extra volume as text                                         |
//+------------------------------------------------------------------+
string MaxVolumeText(const double max_volume)
  {
   if(max_volume<-1.5)
      return("n/a, volume step unknown");
   if(max_volume<0.0)
      return("n/a, below safety level");
   string safety=(InpSafetyLevel>0.0) ? DoubleToString(InpSafetyLevel,0)+" %" :
                 "MC "+LevelValueText(g_account.MarginCall());
   return(StringFormat("%.2f lots (%s)",max_volume,safety));
  }

//+------------------------------------------------------------------+
//| Rows with levels, what-if and max volume                         |
//+------------------------------------------------------------------+
void LevelRows(const MrsResult &res,string &rows[],int &n)
  {
   string side=(InpWhatIfSide==MRS_SIDE_BUY) ? "BUY" : "SELL";
   bool exposed=(ArraySize(g_legs)>0);
   AddRow(rows,n,"Margin call   "+LevelText(res,0,exposed));
   AddRow(rows,n,"Stop out      "+LevelText(res,4,exposed));
   if(g_whatif.volume!=0.0)
     {
      AddRow(rows,n,StringFormat("What-if %s %.2f lots -> %s",side,MathAbs(g_whatif.volume),
                                 res.level_after>0.0 ? DoubleToString(res.level_after,1)+" %" : "-"));
      AddRow(rows,n,"  MC after    "+LevelText(res,2,true));
      AddRow(rows,n,"  SO after    "+LevelText(res,6,true));
     }
   AddRow(rows,n,"Max extra "+side+" "+MaxVolumeText(res.max_volume));
   if(g_margin_failed)
     {
      //--- some volumes could not be priced: those cases were treated as breached
      AddRow(rows,n,"Margin n/a for some volumes:");
      AddRow(rows,n,"levels shown on the safe side.");
      return;
     }
   AddRow(rows,n,"Other symbols and held margin");
   AddRow(rows,n,g_exchange ? "assumed unchanged (exchange: rough)" : "are assumed unchanged.");
  }

//+------------------------------------------------------------------+
//| Panel coordinates for the chosen corner (labels anchored at the  |
//| upper-left point, so right/lower corners are mirrored)           |
//+------------------------------------------------------------------+
int CornerX(const int local_x,const int width)
  {
   bool right=(InpCorner==CORNER_RIGHT_UPPER || InpCorner==CORNER_RIGHT_LOWER);
   return(right ? MRS_MARGIN_PX+width-local_x : MRS_MARGIN_PX+local_x);
  }

//+------------------------------------------------------------------+
//| Vertical counterpart of CornerX                                  |
//+------------------------------------------------------------------+
int CornerY(const int local_y,const int height)
  {
   bool lower=(InpCorner==CORNER_LEFT_LOWER || InpCorner==CORNER_RIGHT_LOWER);
   return(lower ? MRS_MARGIN_PX+height-local_y : MRS_MARGIN_PX+local_y);
  }

//+------------------------------------------------------------------+
//| Background rectangle of the panel                                |
//+------------------------------------------------------------------+
void DrawBackground(const int width,const int height)
  {
   string name=MRS_PREFIX+"panel";
   if(g_panel.ChartId()!=-1 && ObjectFind(0,name)<0)
      g_panel.Detach();
   if(g_panel.ChartId()==-1)
     {
      if(!g_panel.Create(0,name,0,0,0,width,height))
         return;
      g_panel.BorderType(BORDER_FLAT);
      g_panel.Selectable(false);
      g_panel.SetInteger(OBJPROP_HIDDEN,true);
     }
   g_panel.Corner(InpCorner);
   g_panel.X_Distance(CornerX(0,width));
   g_panel.Y_Distance(CornerY(0,height));
   g_panel.X_Size(width);
   g_panel.Y_Size(height);
   g_panel.BackColor(InpPanelColor);
   g_panel.Color(MRS_BORDER_COLOR);
  }

//+------------------------------------------------------------------+
//| One text row of the panel                                        |
//+------------------------------------------------------------------+
void DrawRow(const int row,const string text,const color clr,const int width,const int height)
  {
   string name=MRS_PREFIX+"row_"+IntegerToString(row);
   if(g_rows[row].ChartId()!=-1 && ObjectFind(0,name)<0)
      g_rows[row].Detach();
   if(g_rows[row].ChartId()==-1)
     {
      if(!g_rows[row].Create(0,name,0,0,0))
         return;
      g_rows[row].Font("Consolas");
      g_rows[row].Anchor(ANCHOR_LEFT_UPPER);
      g_rows[row].Selectable(false);
      g_rows[row].SetInteger(OBJPROP_HIDDEN,true);
     }
   g_rows[row].Corner(InpCorner);
   g_rows[row].FontSize(InpFontSize);
   g_rows[row].X_Distance(CornerX(MRS_TEXT_X,width));
   g_rows[row].Y_Distance(CornerY(MRS_TEXT_Y+row*(InpFontSize+MRS_ROW_PAD),height));
   g_rows[row].Color(clr);
   g_rows[row].Description(text);
  }

//+------------------------------------------------------------------+
//| Widest row in pixels, measured with the panel font               |
//+------------------------------------------------------------------+
int TextWidth(const string &rows[],const int n)
  {
   int width=0;
   bool measured=TextSetFont("Consolas",-InpFontSize*10);
   for(int i=0;i<n;i++)
     {
      uint w=0,h=0;
      if(measured && TextGetSize(rows[i],w,h))
         width=MathMax(width,(int)w);
      else
         width=MathMax(width,(int)(StringLen(rows[i])*InpFontSize*MRS_CHAR_WIDTH));
     }
   return(width);
  }

//+------------------------------------------------------------------+
//| Size the panel to its text and draw it; unused rows are removed  |
//+------------------------------------------------------------------+
void RenderPanel(const string &rows[],const int n,const bool alarm)
  {
   int width=TextWidth(rows,n)+2*MRS_TEXT_X;
   int height=n*(InpFontSize+MRS_ROW_PAD)+MRS_PANEL_PAD;
   DrawBackground(width,height);
   for(int i=0;i<MRS_ROWS;i++)
     {
      if(i<n)
        {
         bool warn=alarm && StringFind(rows[i],"REACHED")>=0;
         DrawRow(i,rows[i],warn ? clrRed : InpTextColor,width,height);
        }
      else
         if(g_rows[i].ChartId()!=-1)
            g_rows[i].Delete();
     }
  }

//+------------------------------------------------------------------+
//| Full panel                                                       |
//+------------------------------------------------------------------+
void DrawPanel(const MrsResult &res)
  {
   string rows[MRS_ROWS];
   int n=0;
   AccountRows(rows,n);
   LevelRows(res,rows,n);
   RenderPanel(rows,n,true);
  }

//+------------------------------------------------------------------+
//| Panel with an error message, no lines                            |
//+------------------------------------------------------------------+
void DrawError()
  {
   for(int idx=0;idx<MRS_LINES;idx++)
      SetLine(idx,0.0,clrNONE,STYLE_SOLID,"");
   string rows[2];
   rows[0]="Margin Risk Simulator  "+_Symbol;
   rows[1]=g_error;
   RenderPanel(rows,2,false);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
