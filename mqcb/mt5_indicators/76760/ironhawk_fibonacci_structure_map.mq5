//+------------------------------------------------------------------+
//| IronHawk_Fibonacci_Structure_Map.mq5                             |
//| IronHawk Capital                                                 |
//| IFSM - Fibonacci confluence and structure indicator              |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property version   "1.30"
#property description "IFSM - Multi-timeframe Fibonacci confluence, structure and historical reaction map."

enum ENUM_IH_VIEW_MODE
  {
   IH_VIEW_CLEAN=0,
   IH_VIEW_FULL=1,
   IH_VIEW_MINIMAL=2
  };

input group "=== Timeframes ==="
input ENUM_TIMEFRAMES InpTimeframe1 = PERIOD_M5;
input ENUM_TIMEFRAMES InpTimeframe2 = PERIOD_M15;
input ENUM_TIMEFRAMES InpTimeframe3 = PERIOD_H1;

input group "=== Swing Detection ==="
input int  InpLookbackBars     = 500;
input int  InpSwingDepth       = 4;
input int  InpMaxHistoryOffset = 5;

input group "=== Fibonacci Levels ==="
input bool InpShow236  = true;
input bool InpShow382  = true;
input bool InpShow500  = true;
input bool InpShow618  = true;
input bool InpShow786  = true;
input bool InpShow1272 = true;
input bool InpShow1618 = true;

input group "=== Confluence Engine ==="
input int    InpATRPeriod            = 14;
input double InpClusterATRMultiplier = 0.15;
input int    InpMinClusterTimeframes = 2;
input bool   InpShowClusters         = true;
input int    InpZoneHistoryBars      = 55;
input int    InpZoneFutureBars       = 12;

input group "=== Historical Map ==="
input bool InpShowHistoricalZones    = true;
input int  InpHistoricalSwingCount   = 3;
input int  InpReactionSearchBars     = 80;
input bool InpShowReactionMarkers    = true;

input group "=== Structure Context ==="
input bool InpShowStructure       = true;
input bool InpShowPremiumDiscount = true;

input group "=== Alerts ==="
input bool InpEnablePopupAlert = true;
input bool InpEnablePushAlert  = false;

input group "=== Interface ==="
input ENUM_IH_VIEW_MODE InpInitialViewMode = IH_VIEW_CLEAN;
input bool  InpShowPanel       = true;
input bool  InpShowButtons     = true;
input int   InpLabelShiftBars  = 5;
input color InpPrimaryFibColor   = clrDeepSkyBlue;
input color InpSecondaryFibColor = clrMediumPurple;
input color InpHigherFibColor    = clrOrange;
input color InpClusterColor      = clrGold;
input color InpHistoryColor      = clrDarkOrange;
input color InpBullColor         = clrLimeGreen;
input color InpBearColor         = clrTomato;
input color InpTextColor         = clrWhite;
input color InpMutedTextColor    = clrSilver;
input color InpPanelColor      = clrBlack;
input string InpObjectPrefix   = "IH_FIB_MAP";

struct SwingState
  {
   ENUM_TIMEFRAMES tf;
   bool            valid;
   bool            bullish;
   datetime        high_time;
   datetime        low_time;
   double          high;
   double          low;
  };

struct PivotPoint
  {
   int      index;
   datetime time;
   double   price;
   bool     is_high;
  };

struct FibPoint
  {
   ENUM_TIMEFRAMES tf;
   double          ratio;
   double          price;
   string          label;
  };

SwingState        g_swing[3];
SwingState        g_previous_primary;
FibPoint          g_fibs[];
ENUM_IH_VIEW_MODE g_view_mode=IH_VIEW_CLEAN;
int               g_history_offset=0;
datetime          g_last_chart_bar=0;
string            g_active_alert_zone="";

//+------------------------------------------------------------------+
//| Helpers                                                          |
//+------------------------------------------------------------------+
string TFName(const ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1:  return "M1";
      case PERIOD_M2:  return "M2";
      case PERIOD_M3:  return "M3";
      case PERIOD_M4:  return "M4";
      case PERIOD_M5:  return "M5";
      case PERIOD_M6:  return "M6";
      case PERIOD_M10: return "M10";
      case PERIOD_M12: return "M12";
      case PERIOD_M15: return "M15";
      case PERIOD_M20: return "M20";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H2:  return "H2";
      case PERIOD_H3:  return "H3";
      case PERIOD_H4:  return "H4";
      case PERIOD_H6:  return "H6";
      case PERIOD_H8:  return "H8";
      case PERIOD_H12: return "H12";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
     }
   return IntegerToString((int)tf);
  }

string ObjName(const string suffix)
  {
   return InpObjectPrefix+"_"+suffix;
  }

double NormalizeChartPrice(const double price)
  {
   return NormalizeDouble(price,(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
  }

void DeleteIndicatorObjects()
  {
   ObjectsDeleteAll(0,InpObjectPrefix);
  }

bool SameTimeframe(const ENUM_TIMEFRAMES a,const ENUM_TIMEFRAMES b)
  {
   return ((int)a==(int)b);
  }

color FibColorForTF(const ENUM_TIMEFRAMES tf)
  {
   if(SameTimeframe(tf,InpTimeframe1))
      return InpPrimaryFibColor;
   if(SameTimeframe(tf,InpTimeframe2))
      return InpSecondaryFibColor;
   return InpHigherFibColor;
  }

void SetObjectCommon(const string name,const bool selectable=false)
  {
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selectable);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

datetime NewerPivotTime(const SwingState &s)
  {
   if(!s.valid) return 0;
   return (s.high_time>s.low_time ? s.high_time : s.low_time);
  }

datetime OlderPivotTime(const SwingState &s)
  {
   if(!s.valid) return 0;
   return (s.high_time<s.low_time ? s.high_time : s.low_time);
  }

//+------------------------------------------------------------------+
//| Confirmed swing detection                                        |
//+------------------------------------------------------------------+
bool IsConfirmedHigh(const MqlRates &rates[],const int i,const int depth,const int total)
  {
   if(i-depth<1 || i+depth>=total) return false;

   double value=rates[i].high;
   for(int k=1;k<=depth;k++)
      if(rates[i-k].high>=value || rates[i+k].high>value)
         return false;

   return true;
  }

bool IsConfirmedLow(const MqlRates &rates[],const int i,const int depth,const int total)
  {
   if(i-depth<1 || i+depth>=total) return false;

   double value=rates[i].low;
   for(int k=1;k<=depth;k++)
      if(rates[i-k].low<=value || rates[i+k].low<value)
         return false;

   return true;
  }

void AddPivot(PivotPoint &pivots[],const PivotPoint &p)
  {
   int n=ArraySize(pivots);
   ArrayResize(pivots,n+1);
   pivots[n]=p;
  }

int BuildPivots(const ENUM_TIMEFRAMES tf,PivotPoint &pivots[])
  {
   ArrayResize(pivots,0);

   MqlRates rates[];
   ArraySetAsSeries(rates,true);

   int requested=MathMax(InpLookbackBars,InpSwingDepth*8+60);
   int copied=CopyRates(_Symbol,tf,0,requested,rates);
   if(copied<InpSwingDepth*2+20)
      return 0;

   for(int i=InpSwingDepth+1;i<copied-InpSwingDepth;i++)
     {
      if(IsConfirmedHigh(rates,i,InpSwingDepth,copied))
        {
         PivotPoint p;
         p.index=i; p.time=rates[i].time; p.price=rates[i].high; p.is_high=true;
         AddPivot(pivots,p);
        }

      if(IsConfirmedLow(rates,i,InpSwingDepth,copied))
        {
         PivotPoint p;
         p.index=i; p.time=rates[i].time; p.price=rates[i].low; p.is_high=false;
         AddPivot(pivots,p);
        }
     }

   return ArraySize(pivots);
  }

bool DetectSwingByOffset(const ENUM_TIMEFRAMES tf,const int offset,SwingState &state)
  {
   state.tf=tf;
   state.valid=false;

   PivotPoint pivots[];
   int total=BuildPivots(tf,pivots);
   if(total<2)
      return false;

   int leg=0;

   for(int i=0;i<total-1;i++)
     {
      PivotPoint newer=pivots[i];

      int opposite=-1;
      for(int j=i+1;j<total;j++)
        {
         if(pivots[j].is_high!=newer.is_high)
           {
            opposite=j;
            break;
           }
        }

      if(opposite<0)
         break;

      if(leg==offset)
        {
         PivotPoint older=pivots[opposite];

         if(newer.is_high)
           {
            state.high=newer.price;
            state.high_time=newer.time;
            state.low=older.price;
            state.low_time=older.time;
            state.bullish=true;
           }
         else
           {
            state.low=newer.price;
            state.low_time=newer.time;
            state.high=older.price;
            state.high_time=older.time;
            state.bullish=false;
           }

         state.valid=(state.high>state.low);
         return state.valid;
        }

      leg++;
      i=opposite-1;
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Fibonacci engine                                                 |
//+------------------------------------------------------------------+
void AddFibToArray(FibPoint &arr[],const SwingState &s,
                   const double ratio,const string label)
  {
   if(!s.valid) return;

   double range=s.high-s.low;
   double price=0.0;

   if(s.bullish)
     {
      if(ratio<=1.0) price=s.high-range*ratio;
      else           price=s.low+range*ratio;
     }
   else
     {
      if(ratio<=1.0) price=s.low+range*ratio;
      else           price=s.high-range*ratio;
     }

   int n=ArraySize(arr);
   ArrayResize(arr,n+1);
   arr[n].tf=s.tf;
   arr[n].ratio=ratio;
   arr[n].price=NormalizeChartPrice(price);
   arr[n].label=label;
  }

void BuildFibsForStates(const SwingState &states[],FibPoint &arr[])
  {
   ArrayResize(arr,0);

   for(int i=0;i<3;i++)
     {
      if(!states[i].valid) continue;

      if(InpShow236)  AddFibToArray(arr,states[i],0.236,"23.6");
      if(InpShow382)  AddFibToArray(arr,states[i],0.382,"38.2");
      if(InpShow500)  AddFibToArray(arr,states[i],0.500,"50.0");
      if(InpShow618)  AddFibToArray(arr,states[i],0.618,"61.8");
      if(InpShow786)  AddFibToArray(arr,states[i],0.786,"78.6");
      if(InpShow1272) AddFibToArray(arr,states[i],1.272,"127.2");
      if(InpShow1618) AddFibToArray(arr,states[i],1.618,"161.8");
     }
  }

void BuildFibonacciMap()
  {
   BuildFibsForStates(g_swing,g_fibs);
  }

double ATRAtPrimaryShift(const int shift)
  {
   int handle=iATR(_Symbol,InpTimeframe1,InpATRPeriod);
   if(handle==INVALID_HANDLE)
      return 0.0;

   double buffer[];
   ArraySetAsSeries(buffer,true);
   int copied=CopyBuffer(handle,0,MathMax(shift,1),1,buffer);
   IndicatorRelease(handle);

   if(copied!=1)
      return 0.0;

   return buffer[0];
  }

double ATRForPrimaryTimeframe()
  {
   return ATRAtPrimaryShift(1);
  }

double ATRForHistoricalTime(const datetime t)
  {
   int shift=iBarShift(_Symbol,InpTimeframe1,t,false);
   if(shift<1) shift=1;
   return ATRAtPrimaryShift(shift);
  }

//+------------------------------------------------------------------+
//| Drawing helpers                                                  |
//+------------------------------------------------------------------+
datetime FutureChartTime(const int bars)
  {
   int seconds=PeriodSeconds(_Period);
   if(seconds<=0) seconds=60;
   return TimeCurrent()+(datetime)(seconds*bars);
  }

datetime PastChartTime(const int bars)
  {
   int available=Bars(_Symbol,_Period);
   if(available<=1) return TimeCurrent();

   int shift=MathMin(bars,available-1);
   datetime t=iTime(_Symbol,_Period,shift);
   return (t>0 ? t : TimeCurrent());
  }

void DrawHorizontal(const string name,const double price,const color clr,
                    const ENUM_LINE_STYLE style,const int width)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_HLINE,0,0,price);

   ObjectSetDouble(0,name,OBJPROP_PRICE,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   SetObjectCommon(name);
  }

void DrawPriceText(const string name,const datetime time,const double price,
                   const string text,const color clr,const int size=8)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_TEXT,0,time,price);

   ObjectMove(0,name,0,time,price);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   SetObjectCommon(name);
  }

void DrawLivePriceText(const string name,const double price,const string text,
                       const color clr,const int size=8)
  {
   DrawPriceText(name,FutureChartTime(InpLabelShiftBars),price,text,clr,size);
  }

void DrawRectangle(const string name,const datetime t1,const datetime t2,
                   double low,double high,const color clr,
                   const bool fill,const ENUM_LINE_STYLE style,const int width)
  {
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   if(high<=low)
     {
      low-=point*2.0;
      high+=point*2.0;
     }

   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_RECTANGLE,0,t1,high,t2,low);

   ObjectMove(0,name,0,t1,high);
   ObjectMove(0,name,1,t2,low);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_FILL,fill);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   SetObjectCommon(name);
  }

//+------------------------------------------------------------------+
//| CLEAN / FULL Fib display                                         |
//+------------------------------------------------------------------+
bool IsKeyRatio(const double r)
  {
   return (MathAbs(r-0.382)<0.0001 ||
           MathAbs(r-0.500)<0.0001 ||
           MathAbs(r-0.618)<0.0001);
  }

int NearestKeyFibForTF(const ENUM_TIMEFRAMES tf,const double live_price)
  {
   double best=DBL_MAX;
   int best_index=-1;

   for(int i=0;i<ArraySize(g_fibs);i++)
     {
      if(!SameTimeframe(g_fibs[i].tf,tf)) continue;
      if(!IsKeyRatio(g_fibs[i].ratio)) continue;

      double d=MathAbs(g_fibs[i].price-live_price);
      if(d<best)
        {
         best=d;
         best_index=i;
        }
     }

   return best_index;
  }

bool IndexAlreadySelected(const int &selected[],const int count,const int index)
  {
   for(int i=0;i<count;i++)
      if(selected[i]==index)
         return true;
   return false;
  }

void DrawCleanFibLevels()
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return;

   double live=(tick.bid+tick.ask)/2.0;
   int selected[3];
   int count=0;

   ENUM_TIMEFRAMES tfs[3];
   tfs[0]=InpTimeframe1;
   tfs[1]=InpTimeframe2;
   tfs[2]=InpTimeframe3;

   for(int tf=0;tf<3;tf++)
     {
      int idx=NearestKeyFibForTF(tfs[tf],live);
      if(idx<0) continue;
      if(IndexAlreadySelected(selected,count,idx)) continue;
      selected[count++]=idx;
     }

   for(int k=0;k<count;k++)
     {
      int i=selected[k];
      color clr=FibColorForTF(g_fibs[i].tf);
      int width=SameTimeframe(g_fibs[i].tf,InpTimeframe1) ? 2 : 1;

      string id="CLEAN_"+TFName(g_fibs[i].tf)+"_"+IntegerToString(i);
      string label=TFName(g_fibs[i].tf)+" "+g_fibs[i].label+"%";

      DrawHorizontal(ObjName(id),g_fibs[i].price,clr,STYLE_DASH,width);
      DrawLivePriceText(ObjName(id+"_TXT"),g_fibs[i].price,label,clr,8);
     }
  }

void DrawFullFibLevels()
  {
   for(int i=0;i<ArraySize(g_fibs);i++)
     {
      color clr=FibColorForTF(g_fibs[i].tf);

      string id="FULL_"+TFName(g_fibs[i].tf)+"_"+IntegerToString(i);
      string label=TFName(g_fibs[i].tf)+" "+g_fibs[i].label+"%";

      DrawHorizontal(ObjName(id),g_fibs[i].price,clr,STYLE_DOT,1);
      DrawLivePriceText(ObjName(id+"_TXT"),g_fibs[i].price,label,clr,8);
     }
  }

void DrawFibLevels()
  {
   if(g_view_mode==IH_VIEW_MINIMAL)
      return;

   if(g_view_mode==IH_VIEW_CLEAN)
      DrawCleanFibLevels();
   else
      DrawFullFibLevels();
  }

//+------------------------------------------------------------------+
//| Structure                                                        |
//+------------------------------------------------------------------+
string StructureContext()
  {
   if(!InpShowStructure || !g_swing[0].valid)
      return "Structure unavailable";

   SwingState current=g_swing[0];
   SwingState previous=g_previous_primary;
   double close=iClose(_Symbol,InpTimeframe1,1);

   if(!previous.valid)
      return current.bullish ? "Bullish active leg" : "Bearish active leg";

   bool higher_high=(current.high>previous.high);
   bool higher_low =(current.low >previous.low);
   bool lower_high =(current.high<previous.high);
   bool lower_low  =(current.low <previous.low);

   if(higher_high && higher_low)
     {
      if(close<current.low) return "Bearish CHoCH";
      if(close>current.high) return "Bullish BOS";
      return "HH / HL";
     }

   if(lower_high && lower_low)
     {
      if(close>current.high) return "Bullish CHoCH";
      if(close<current.low) return "Bearish BOS";
      return "LH / LL";
     }

   if(close>current.high) return "Bullish break";
   if(close<current.low)  return "Bearish break";
   return "Mixed structure";
  }

color StructureColor()
  {
   string s=StructureContext();
   if(StringFind(s,"Bullish")>=0 || StringFind(s,"HH / HL")>=0)
      return InpBullColor;
   if(StringFind(s,"Bearish")>=0 || StringFind(s,"LH / LL")>=0)
      return InpBearColor;
   return InpTextColor;
  }

void DrawPremiumDiscount()
  {
   if(!InpShowPremiumDiscount || g_view_mode!=IH_VIEW_FULL || !g_swing[0].valid)
      return;

   SwingState s=g_swing[0];
   double mid=(s.high+s.low)/2.0;

   DrawHorizontal(ObjName("EQUILIBRIUM"),mid,InpPrimaryFibColor,STYLE_DASH,1);
   DrawLivePriceText(ObjName("PREMIUM"),(s.high+mid)/2.0,"PREMIUM",InpBearColor,8);
   DrawLivePriceText(ObjName("DISCOUNT"),(s.low+mid)/2.0,"DISCOUNT",InpBullColor,8);
  }

//+------------------------------------------------------------------+
//| Confluence helpers                                               |
//+------------------------------------------------------------------+
void SortFibIndicesByPrice(const FibPoint &arr[],int &idx[])
  {
   int n=ArraySize(idx);
   for(int i=0;i<n;i++) idx[i]=i;

   for(int i=0;i<n-1;i++)
      for(int j=i+1;j<n;j++)
         if(arr[idx[j]].price<arr[idx[i]].price)
           {
            int temp=idx[i];
            idx[i]=idx[j];
            idx[j]=temp;
           }
  }

int UniqueTimeframesInRange(const FibPoint &arr[],const int &idx[],
                            const int from,const int to)
  {
   bool tf0=false,tf1=false,tf2=false;

   for(int k=from;k<=to;k++)
     {
      ENUM_TIMEFRAMES tf=arr[idx[k]].tf;
      if(SameTimeframe(tf,InpTimeframe1)) tf0=true;
      if(SameTimeframe(tf,InpTimeframe2)) tf1=true;
      if(SameTimeframe(tf,InpTimeframe3)) tf2=true;
     }

   int result=0;
   if(tf0) result++;
   if(tf1 && !SameTimeframe(InpTimeframe2,InpTimeframe1)) result++;
   if(tf2 && !SameTimeframe(InpTimeframe3,InpTimeframe1) &&
             !SameTimeframe(InpTimeframe3,InpTimeframe2)) result++;
   return result;
  }

string ClusterMembers(const FibPoint &arr[],const int &idx[],
                      const int from,const int to)
  {
   string result="";
   for(int k=from;k<=to;k++)
     {
      string part=TFName(arr[idx[k]].tf)+" "+arr[idx[k]].label+"%";
      if(result!="") result+=", ";
      result+=part;
     }
   return result;
  }

//+------------------------------------------------------------------+
//| Live confluence zones                                            |
//+------------------------------------------------------------------+
void DrawLiveClustersAndAlerts()
  {
   if(!InpShowClusters)
      return;

   int total=ArraySize(g_fibs);
   if(total<2)
      return;

   double atr=ATRForPrimaryTimeframe();
   if(atr<=0.0)
      return;

   double tolerance=atr*InpClusterATRMultiplier;
   if(tolerance<=0.0)
      return;

   int idx[];
   ArrayResize(idx,total);
   SortFibIndicesByPrice(g_fibs,idx);

   MqlTick tick;
   bool have_tick=SymbolInfoTick(_Symbol,tick);
   double live_price=have_tick ? (tick.bid+tick.ask)/2.0 : 0.0;

   bool price_in_zone=false;
   string entered_zone="";
   int cluster_no=0;
   int i=0;

   while(i<total)
     {
      int best_end=i;

      for(int j=i+1;j<total;j++)
        {
         double width=g_fibs[idx[j]].price-g_fibs[idx[i]].price;
         if(width<=tolerance) best_end=j;
         else break;
        }

      int unique_tfs=UniqueTimeframesInRange(g_fibs,idx,i,best_end);

      if(best_end>i && unique_tfs>=InpMinClusterTimeframes)
        {
         cluster_no++;

         double low =g_fibs[idx[i]].price;
         double high=g_fibs[idx[best_end]].price;
         double mid =(low+high)/2.0;

         string key="LIVE_CLUSTER_"+IntegerToString(cluster_no);
         string label=IntegerToString(unique_tfs)+"TF CONFLUENCE";
         string price_range=DoubleToString(low,_Digits)+" - "+DoubleToString(high,_Digits);

         DrawRectangle(ObjName(key),PastChartTime(InpZoneHistoryBars),
                       FutureChartTime(InpZoneFutureBars),
                       low,high,InpClusterColor,true,STYLE_SOLID,1);

         DrawHorizontal(ObjName(key+"_MID"),mid,InpClusterColor,STYLE_SOLID,2);
         DrawLivePriceText(ObjName(key+"_TXT"),mid,label+" | "+price_range,InpClusterColor,8);

         if(have_tick && live_price>=low && live_price<=high)
           {
            price_in_zone=true;
            entered_zone=DoubleToString(low,_Digits)+"_"+DoubleToString(high,_Digits);

            if(g_active_alert_zone!=entered_zone)
              {
               string msg="IFSM: "+_Symbol+" entered "+label+
                          " ["+price_range+"] ("+
                          ClusterMembers(g_fibs,idx,i,best_end)+")";

               if(InpEnablePopupAlert) Alert(msg);
               if(InpEnablePushAlert)  SendNotification(msg);
              }
           }

         i=best_end+1;
        }
      else
         i++;
     }

   g_active_alert_zone=(price_in_zone ? entered_zone : "");
  }

//+------------------------------------------------------------------+
//| Historical confluence + first reaction                           |
//+------------------------------------------------------------------+
bool FindFirstReaction(const datetime start_time,const double low,const double high,
                       datetime &reaction_time,double &reaction_price)
  {
   int start_shift=iBarShift(_Symbol,InpTimeframe1,start_time,false);
   if(start_shift<1)
      return false;

   int end_shift=MathMax(0,start_shift-InpReactionSearchBars);

   for(int shift=start_shift-1;shift>=end_shift;shift--)
     {
      double bar_low=iLow(_Symbol,InpTimeframe1,shift);
      double bar_high=iHigh(_Symbol,InpTimeframe1,shift);

      if(bar_low<=high && bar_high>=low)
        {
         reaction_time=iTime(_Symbol,InpTimeframe1,shift);

         double close=iClose(_Symbol,InpTimeframe1,shift);
         reaction_price=MathMax(low,MathMin(high,close));
         return true;
        }
     }

   return false;
  }

void DrawReactionMarker(const string name,const datetime t,const double price)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_ARROW,0,t,price);

   ObjectMove(0,name,0,t,price);
   ObjectSetInteger(0,name,OBJPROP_ARROWCODE,159);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpHistoryColor);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   SetObjectCommon(name);
  }

void DrawHistoricalZones()
  {
   if(!InpShowHistoricalZones || InpHistoricalSwingCount<=0)
      return;

   int count=MathMin(InpHistoricalSwingCount,InpMaxHistoryOffset);

   for(int offset=1;offset<=count;offset++)
     {
      SwingState states[3];
      DetectSwingByOffset(InpTimeframe1,offset,states[0]);
      DetectSwingByOffset(InpTimeframe2,offset,states[1]);
      DetectSwingByOffset(InpTimeframe3,offset,states[2]);

      if(!states[0].valid && !states[1].valid && !states[2].valid)
         continue;

      FibPoint fibs[];
      BuildFibsForStates(states,fibs);
      int total=ArraySize(fibs);
      if(total<2)
         continue;

      datetime formation=0;
      for(int s=0;s<3;s++)
        {
         datetime t=NewerPivotTime(states[s]);
         if(t>formation) formation=t;
        }

      if(formation<=0)
         continue;

      double atr=ATRForHistoricalTime(formation);
      if(atr<=0.0)
         continue;

      double tolerance=atr*InpClusterATRMultiplier;
      int idx[];
      ArrayResize(idx,total);
      SortFibIndicesByPrice(fibs,idx);

      int cluster_no=0;
      int i=0;

      while(i<total)
        {
         int best_end=i;

         for(int j=i+1;j<total;j++)
           {
            double width=fibs[idx[j]].price-fibs[idx[i]].price;
            if(width<=tolerance) best_end=j;
            else break;
           }

         int unique_tfs=UniqueTimeframesInRange(fibs,idx,i,best_end);

         if(best_end>i && unique_tfs>=InpMinClusterTimeframes)
           {
            cluster_no++;

            double low=fibs[idx[i]].price;
            double high=fibs[idx[best_end]].price;
            double mid=(low+high)/2.0;

            datetime reaction_time=0;
            double reaction_price=0.0;
            bool reacted=FindFirstReaction(formation,low,high,reaction_time,reaction_price);

            datetime zone_end;
            if(reacted)
               zone_end=reaction_time;
            else
              {
               int sec=PeriodSeconds(InpTimeframe1);
               if(sec<=0) sec=60;
               zone_end=formation+(datetime)(sec*InpReactionSearchBars);
              }

            string key="HIST_"+IntegerToString(offset)+"_"+IntegerToString(cluster_no);
            DrawRectangle(ObjName(key),formation,zone_end,low,high,
                          InpHistoryColor,false,STYLE_DOT,1);

            string label="H"+IntegerToString(offset)+" "+
                         IntegerToString(unique_tfs)+"TF";
            DrawPriceText(ObjName(key+"_TXT"),formation,mid,label,InpHistoryColor,7);

            if(reacted && InpShowReactionMarkers)
               DrawReactionMarker(ObjName(key+"_REACTION"),reaction_time,reaction_price);

            i=best_end+1;
           }
         else
            i++;
        }
     }
  }

//+------------------------------------------------------------------+
//| Compact panel                                                    |
//+------------------------------------------------------------------+
string BiasText()
  {
   if(!g_swing[0].valid) return "n/a";
   return g_swing[0].bullish ? "Bullish" : "Bearish";
  }

color BiasColor()
  {
   if(!g_swing[0].valid) return InpMutedTextColor;
   return g_swing[0].bullish ? InpBullColor : InpBearColor;
  }

string NearestFibText()
  {
   int total=ArraySize(g_fibs);
   if(total==0) return "Nearest: n/a";

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return "Nearest: n/a";

   double price=(tick.bid+tick.ask)/2.0;
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   double best=DBL_MAX;
   int best_index=-1;

   for(int i=0;i<total;i++)
     {
      double d=MathAbs(g_fibs[i].price-price);
      if(d<best)
        {
         best=d;
         best_index=i;
        }
     }

   if(best_index<0) return "Nearest: n/a";

   string distance=(point>0.0) ? DoubleToString(best/point,0)+" pts" : "n/a";
   return "Nearest: "+TFName(g_fibs[best_index].tf)+" "+
          g_fibs[best_index].label+"% | "+distance;
  }

string TFState(const int index)
  {
   if(!g_swing[index].valid) return "n/a";
   return g_swing[index].bullish ? "Bull" : "Bear";
  }

string ViewModeText()
  {
   if(g_view_mode==IH_VIEW_CLEAN) return "CLEAN";
   if(g_view_mode==IH_VIEW_FULL)  return "FULL";
   return "MINIMAL";
  }

void PanelBackground()
  {
   string name=ObjName("PANEL_BG");

   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,12);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,14);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,300);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,104);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,InpPanelColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpClusterColor);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   SetObjectCommon(name);
  }

void PanelLabel(const string suffix,const int x,const int y,
                const string text,const color clr,const int size=9)
  {
   string name=ObjName("PNL_"+suffix);

   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   SetObjectCommon(name);
  }

void DrawPanel()
  {
   if(!InpShowPanel)
      return;

   PanelBackground();

   PanelLabel("TITLE",18,22,"IFSM",InpClusterColor,12);
   PanelLabel("SYMBOL",74,24,_Symbol+" | "+TFName(_Period),InpMutedTextColor,8);

   PanelLabel("BIAS_L",18,48,"Bias",InpMutedTextColor,8);
   PanelLabel("BIAS",52,47,BiasText(),BiasColor(),9);

   PanelLabel("STRUCT_L",116,48,"Structure",InpMutedTextColor,8);
   PanelLabel("STRUCT",180,47,StructureContext(),StructureColor(),9);

   PanelLabel("NEAREST",18,69,NearestFibText(),InpTextColor,8);

   string tfline=TFName(InpTimeframe1)+" "+TFState(0)+"   "+
                 TFName(InpTimeframe2)+" "+TFState(1)+"   "+
                 TFName(InpTimeframe3)+" "+TFState(2);

   PanelLabel("TF",18,89,tfline,InpMutedTextColor,8);
  }

void MakeButton(const string suffix,const int x,const int width,const string text)
  {
   string name=ObjName("BTN_"+suffix);

   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_BUTTON,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,123);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,19);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,InpPanelColor);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpTextColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,InpMutedTextColor);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,7);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,10);
  }

void DrawButtons()
  {
   if(!InpShowButtons)
      return;

   MakeButton("OLDER",12,72,"< OLDER");
   MakeButton("NEWER",90,72,"NEWER >");
   MakeButton("VIEW",168,124,"VIEW  "+ViewModeText());
  }

//+------------------------------------------------------------------+
//| Refresh                                                          |
//+------------------------------------------------------------------+
void RefreshAll()
  {
   DeleteIndicatorObjects();

   DetectSwingByOffset(InpTimeframe1,g_history_offset,g_swing[0]);
   DetectSwingByOffset(InpTimeframe2,g_history_offset,g_swing[1]);
   DetectSwingByOffset(InpTimeframe3,g_history_offset,g_swing[2]);
   DetectSwingByOffset(InpTimeframe1,g_history_offset+1,g_previous_primary);

   BuildFibonacciMap();

   DrawHistoricalZones();
   DrawFibLevels();
   DrawPremiumDiscount();
   DrawLiveClustersAndAlerts();
   DrawPanel();
   DrawButtons();

   ChartRedraw();
  }

bool InputsValid()
  {
   if(InpLookbackBars<100) return false;
   if(InpSwingDepth<2) return false;
   if(InpMaxHistoryOffset<0) return false;
   if(InpATRPeriod<2) return false;
   if(InpClusterATRMultiplier<=0.0) return false;
   if(InpMinClusterTimeframes<2 || InpMinClusterTimeframes>3) return false;
   if(InpZoneHistoryBars<1 || InpZoneFutureBars<1) return false;
   if(InpHistoricalSwingCount<0) return false;
   if(InpReactionSearchBars<1) return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Lifecycle                                                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!InputsValid())
      return INIT_PARAMETERS_INCORRECT;

   g_view_mode=InpInitialViewMode;
   g_history_offset=0;
   IndicatorSetString(INDICATOR_SHORTNAME,"IFSM");
   RefreshAll();
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   DeleteIndicatorObjects();
  }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   datetime chart_bar=iTime(_Symbol,_Period,0);

   if(chart_bar!=g_last_chart_bar)
     {
      g_last_chart_bar=chart_bar;
      RefreshAll();
     }
   else
     {
      DrawLiveClustersAndAlerts();
      DrawPanel();
     }

   return rates_total;
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_OBJECT_CLICK)
      return;

   if(sparam==ObjName("BTN_OLDER"))
     {
      if(g_history_offset<InpMaxHistoryOffset)
        {
         g_history_offset++;
         RefreshAll();
        }
     }
   else if(sparam==ObjName("BTN_NEWER"))
     {
      if(g_history_offset>0)
        {
         g_history_offset--;
         RefreshAll();
        }
     }
   else if(sparam==ObjName("BTN_VIEW"))
     {
      if(g_view_mode==IH_VIEW_CLEAN)
         g_view_mode=IH_VIEW_FULL;
      else if(g_view_mode==IH_VIEW_FULL)
         g_view_mode=IH_VIEW_MINIMAL;
      else
         g_view_mode=IH_VIEW_CLEAN;

      RefreshAll();
     }
  }
//+------------------------------------------------------------------+
