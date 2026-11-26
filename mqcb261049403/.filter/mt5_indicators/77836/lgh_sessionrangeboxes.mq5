//+------------------------------------------------------------------+
//|                                        LGH_SessionRangeBoxes.mq5 |
//|                                            Lona Gold Hunter      |
//+------------------------------------------------------------------+
#property copyright   "Lona Gold Hunter"
#property version     "1.00"
#property description "Session Range Boxes with ICT killzone shading,"
#property description "breakout alerts and a session statistics panel."
#property description "Draws Asian, London and New York high/low boxes"
#property description "in server time. Original code, no copied parts."
#property indicator_chart_window

#define PREFIX "LGH_SRB_"

//--- Session inputs (server time, HH:MM, 24h)
input group "Asian Session"
input string InpAsiaStart = "00:00";
input string InpAsiaEnd   = "07:00";
input bool   InpShowAsia  = true;
input color  InpAsiaColor = clrDodgerBlue;

input group "London Session"
input string InpLondonStart = "07:00";
input string InpLondonEnd   = "12:00";
input bool   InpShowLondon  = true;
input color  InpLondonColor = clrOrange;

input group "New York Session"
input string InpNewYorkStart = "12:00";
input string InpNewYorkEnd   = "17:00";
input bool   InpShowNewYork  = true;
input color  InpNewYorkColor = clrCrimson;

input group "ICT Killzones (background shading)"
input bool   InpShowKillzones  = true;
input string InpLondonKZStart  = "07:00";
input string InpLondonKZEnd    = "10:00";
input string InpNewYorkKZStart = "12:00";
input string InpNewYorkKZEnd   = "15:00";
input color  InpKZColor        = clrDimGray;

input group "Appearance"
input bool   InpShowMidline  = true;
input color  InpMidlineColor = clrWhite;
input bool   InpFillBoxes    = true;
input int    InpDaysBack     = 5;      // Days to draw (1-30)

input group "Breakout Alerts (once per session per side)"
input bool   InpPopupAlert = true;
input bool   InpPushAlert  = false;

input group "Statistics Panel"
input bool   InpShowPanel  = true;
input int    InpPanelDays  = 10;      // Days for average (1-60)
input ENUM_BASE_CORNER InpPanelCorner = CORNER_LEFT_UPPER;
input int    InpPanelX     = 10;
input int    InpPanelY     = 20;

input group "Liquidity Sweep Markers"
input bool   InpShowSweeps         = true;
input int    InpSweepWindowMinutes = 60;   // Scan window after London open
input color  InpSweepColor         = clrYellow;

//--- today session boxes (for live breakout alerts)
struct SessionBox
  {
   string            name;
   datetime          t1,t2;
   double            hi,lo;
   bool              valid;
  };
SessionBox todayBoxes[3];

datetime lastM1Bar  = 0;
string   lastAlertKey = "";

//+------------------------------------------------------------------+
//| Parse "HH:MM" into hours/minutes                                 |
//+------------------------------------------------------------------+
bool ParseHM(const string s,int &h,int &m)
  {
   int p=StringFind(s,":");
   if(p<0) return false;
   h=(int)StringToInteger(StringSubstr(s,0,p));
   m=(int)StringToInteger(StringSubstr(s,p+1));
   return(h>=0 && h<24 && m>=0 && m<60);
  }

//+------------------------------------------------------------------+
//| Session start/end datetimes for a given day (00:00 server)        |
//+------------------------------------------------------------------+
bool SessionTimes(const datetime dayStart,const string sStart,const string sEnd,
                  datetime &t1,datetime &t2)
  {
   int h1,m1,h2,m2;
   if(!ParseHM(sStart,h1,m1) || !ParseHM(sEnd,h2,m2)) return false;
   t1=dayStart+h1*3600+m1*60;
   t2=dayStart+h2*3600+m2*60;
   if(t2<=t1) t2+=86400;               // overnight session support
   return true;
  }

//+------------------------------------------------------------------+
//| High/low of a time range from M1 data                            |
//+------------------------------------------------------------------+
bool SessionRange(const datetime t1,const datetime t2,double &hi,double &lo)
  {
   double highs[],lows[];
   if(CopyHigh(_Symbol,PERIOD_M1,t1,t2,highs)<=0) return false;
   if(CopyLow(_Symbol,PERIOD_M1,t1,t2,lows)<=0)   return false;
   hi=highs[ArrayMaximum(highs)];
   lo=lows[ArrayMinimum(lows)];
   return(hi>lo);
  }

//+------------------------------------------------------------------+
//| Draw one session box + optional 50% midline                       |
//+------------------------------------------------------------------+
void DrawBox(const string id,const datetime t1,const datetime t2,
             const double hi,const double lo,const color clr)
  {
   string n=PREFIX+"BOX_"+id;
   if(!ObjectCreate(0,n,OBJ_RECTANGLE,0,t1,hi,t2,lo)) return;
   ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,n,OBJPROP_FILL,InpFillBoxes);
   ObjectSetInteger(0,n,OBJPROP_BACK,true);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_WIDTH,1);

   if(InpShowMidline)
     {
      string mn=PREFIX+"MID_"+id;
      double mid=(hi+lo)*0.5;
      if(ObjectCreate(0,mn,OBJ_TREND,0,t1,mid,t2,mid))
        {
         ObjectSetInteger(0,mn,OBJPROP_COLOR,InpMidlineColor);
         ObjectSetInteger(0,mn,OBJPROP_STYLE,STYLE_DOT);
         ObjectSetInteger(0,mn,OBJPROP_RAY,false);
         ObjectSetInteger(0,mn,OBJPROP_BACK,true);
         ObjectSetInteger(0,mn,OBJPROP_SELECTABLE,false);
        }
     }
  }

//+------------------------------------------------------------------+
//| Draw killzone background shading for one day                      |
//+------------------------------------------------------------------+
void DrawKillzone(const string id,const datetime dayStart,
                  const string ks,const string ke,
                  const double dayHi,const double dayLo)
  {
   datetime t1,t2;
   if(!SessionTimes(dayStart,ks,ke,t1,t2)) return;
   string n=PREFIX+"KZ_"+id;
   if(!ObjectCreate(0,n,OBJ_RECTANGLE,0,t1,dayHi,t2,dayLo)) return;
   ObjectSetInteger(0,n,OBJPROP_COLOR,InpKZColor);
   ObjectSetInteger(0,n,OBJPROP_FILL,true);
   ObjectSetInteger(0,n,OBJPROP_BACK,true);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
  }

//+------------------------------------------------------------------+
//| Draw a sweep arrow marker                                         |
//+------------------------------------------------------------------+
void DrawArrow(const string id,const datetime t,const double price,const bool upSweep)
  {
//--- upSweep = wick ABOVE Asia high (buy-side sweep) -> arrow down
   string n=PREFIX+"SW_"+id;
   ENUM_OBJECT type=upSweep ? OBJ_ARROW_DOWN : OBJ_ARROW_UP;
   if(!ObjectCreate(0,n,type,0,t,price)) return;
   ObjectSetInteger(0,n,OBJPROP_COLOR,InpSweepColor);
   ObjectSetInteger(0,n,OBJPROP_WIDTH,2);
   ObjectSetInteger(0,n,OBJPROP_ANCHOR,upSweep ? ANCHOR_BOTTOM : ANCHOR_TOP);
   ObjectSetInteger(0,n,OBJPROP_BACK,false);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
  }

//+------------------------------------------------------------------+
//| Mark liquidity sweeps of the Asian range in early London          |
//+------------------------------------------------------------------+
void MarkSweeps(const string dayId,const datetime londonT1,
                const double asiaHi,const double asiaLo)
  {
   if(!InpShowSweeps) return;
   int need=InpSweepWindowMinutes;
   datetime tm[];
   double   hh[],ll[],cc[];
   int n=CopyTime(_Symbol,PERIOD_M1,londonT1,need,tm);
   if(n<=0) return;
   if(CopyHigh(_Symbol,PERIOD_M1,londonT1,need,hh)<=0)  return;
   if(CopyLow(_Symbol,PERIOD_M1,londonT1,need,ll)<=0)   return;
   if(CopyClose(_Symbol,PERIOD_M1,londonT1,need,cc)<=0) return;

   bool upDone=false,dnDone=false;
   for(int i=0;i<n && !(upDone && dnDone);i++)
     {
      if(!upDone && hh[i]>asiaHi && cc[i]<asiaHi)
        { DrawArrow(dayId+"U",tm[i],hh[i],true);  upDone=true; }
      if(!dnDone && ll[i]<asiaLo && cc[i]>asiaLo)
        { DrawArrow(dayId+"D",tm[i],ll[i],false); dnDone=true; }
     }
  }

//+------------------------------------------------------------------+
//| Fire breakout alert                                               |
//+------------------------------------------------------------------+
void FireAlert(const string msg)
  {
   string full="LGH SessionBox: "+msg+" ("+_Symbol+")";
   if(InpPopupAlert) Alert(full);
   if(InpPushAlert)  SendNotification(full);
  }

//+------------------------------------------------------------------+
//| Live breakout check on every tick (today's boxes)                 |
//+------------------------------------------------------------------+
void CheckBreakoutsLive()
  {
   if(!InpPopupAlert && !InpPushAlert) return;
   double bid;
   if(!SymbolInfoDouble(_Symbol,SYMBOL_BID,bid)) return;
   string dayKey=TimeToString(iTime(_Symbol,PERIOD_D1,0),TIME_DATE);

   for(int s=0;s<3;s++)
     {
      if(!todayBoxes[s].valid) continue;
      string base=dayKey+"_"+todayBoxes[s].name;
      if(bid>todayBoxes[s].hi && lastAlertKey!=base+"_H")
        {
         lastAlertKey=base+"_H";
         FireAlert(todayBoxes[s].name+" HIGH broken at "+DoubleToString(bid,_Digits));
        }
      else if(bid<todayBoxes[s].lo && lastAlertKey!=base+"_L")
        {
         lastAlertKey=base+"_L";
         FireAlert(todayBoxes[s].name+" LOW broken at "+DoubleToString(bid,_Digits));
        }
     }
  }

//+------------------------------------------------------------------+
//| Panel label helper                                                |
//+------------------------------------------------------------------+
void PanelLabel(const string id,const string txt,const int line,const color clr)
  {
   string n=PREFIX+"PNL_"+id;
   if(ObjectFind(0,n)<0)
     {
      if(!ObjectCreate(0,n,OBJ_LABEL,0,0,0)) return;
      ObjectSetInteger(0,n,OBJPROP_CORNER,InpPanelCorner);
      ObjectSetInteger(0,n,OBJPROP_XDISTANCE,InpPanelX);
      ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
     }
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,InpPanelY+line*18);
   ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);
   ObjectSetString(0,n,OBJPROP_TEXT,txt);
   ObjectSetString(0,n,OBJPROP_FONT,"Arial");
  }

//+------------------------------------------------------------------+
//| Update statistics panel (average session range in pips)           |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
   if(!InpShowPanel) return;

   string sessName[3]= {"Asia","London","NewYork"};
   string sessS[3]   = {InpAsiaStart,InpLondonStart,InpNewYorkStart};
   string sessE[3]   = {InpAsiaEnd,InpLondonEnd,InpNewYorkEnd};
   color  sessC[3]   = {InpAsiaColor,InpLondonColor,InpNewYorkColor};

   double pipDiv=(_Digits==3 || _Digits==5) ? 10.0 : 1.0;

   PanelLabel("T","LGH Sessions | avg range ("+IntegerToString(InpPanelDays)+"d)",0,clrWhite);

   for(int s=0;s<3;s++)
     {
      double sum=0;
      int    cnt=0;
      for(int d=0;d<InpPanelDays;d++)
        {
         datetime dayStart=iTime(_Symbol,PERIOD_D1,d);
         if(dayStart==0) continue;
         datetime t1,t2;
         if(!SessionTimes(dayStart,sessS[s],sessE[s],t1,t2)) continue;
         double hi,lo;
         if(!SessionRange(t1,t2,hi,lo)) continue;
         sum+=(hi-lo)/_Point/pipDiv;
         cnt++;
        }
      string txt=sessName[s]+": "+(cnt>0 ? DoubleToString(sum/cnt,1)+" pips" : "n/a");
      PanelLabel("S"+IntegerToString(s),txt,s+1,sessC[s]);
     }
  }

//+------------------------------------------------------------------+
//| Build / rebuild all drawings                                      |
//+------------------------------------------------------------------+
void BuildAll()
  {
   ObjectsDeleteAll(0,PREFIX);
//--- reset today's boxes (explicit loop: ArrayInitialize doesn't support struct arrays)
   for(int s=0;s<3;s++) todayBoxes[s].valid=false;

   string sessName[3]= {"Asia","London","NewYork"};
   string sessS[3]   = {InpAsiaStart,InpLondonStart,InpNewYorkStart};
   string sessE[3]   = {InpAsiaEnd,InpLondonEnd,InpNewYorkEnd};
   bool   sessOn[3]  = {InpShowAsia,InpShowLondon,InpShowNewYork};
   color  sessC[3]   = {InpAsiaColor,InpLondonColor,InpNewYorkColor};

   for(int d=0;d<InpDaysBack;d++)
     {
      datetime dayStart=iTime(_Symbol,PERIOD_D1,d);
      if(dayStart==0) continue;
      string dayId=TimeToString(dayStart,TIME_DATE);

      double dayHi=iHigh(_Symbol,PERIOD_D1,d);
      double dayLo=iLow(_Symbol,PERIOD_D1,d);

      double asiaHi=0,asiaLo=0;
      bool   asiaOk=false;
      datetime londonT1=0;

      for(int s=0;s<3;s++)
        {
         if(!sessOn[s]) continue;
         datetime t1,t2;
         if(!SessionTimes(dayStart,sessS[s],sessE[s],t1,t2)) continue;
         double hi,lo;
         if(!SessionRange(t1,t2,hi,lo)) continue;   // no data (weekend) -> skip

         DrawBox(dayId+"_"+sessName[s],t1,t2,hi,lo,sessC[s]);

         if(s==0) { asiaHi=hi; asiaLo=lo; asiaOk=true; }
         if(s==1) londonT1=t1;

         if(d==0)  // remember today's boxes for live alerts
           {
            todayBoxes[s].name =sessName[s];
            todayBoxes[s].t1   =t1;
            todayBoxes[s].t2   =t2;
            todayBoxes[s].hi   =hi;
            todayBoxes[s].lo   =lo;
            todayBoxes[s].valid=true;
           }
        }

      //--- killzone shading (uses day range for vertical extent)
      if(InpShowKillzones && dayHi>dayLo)
        {
         DrawKillzone(dayId+"_LKZ",dayStart,InpLondonKZStart,InpLondonKZEnd,dayHi,dayLo);
         DrawKillzone(dayId+"_NKZ",dayStart,InpNewYorkKZStart,InpNewYorkKZEnd,dayHi,dayLo);
        }

      //--- sweep markers need Asia range + London open
      if(asiaOk && londonT1>0)
         MarkSweeps(dayId,londonT1,asiaHi,asiaLo);
     }

   UpdatePanel();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDaysBack<1 || InpDaysBack>30)
     { Print("InpDaysBack must be 1-30"); return(INIT_PARAMETERS_INCORRECT); }
   if(InpPanelDays<1 || InpPanelDays>60)
     { Print("InpPanelDays must be 1-60"); return(INIT_PARAMETERS_INCORRECT); }

   int h,m;
   string all[10]= {InpAsiaStart,InpAsiaEnd,InpLondonStart,InpLondonEnd,
                    InpNewYorkStart,InpNewYorkEnd,InpLondonKZStart,InpLondonKZEnd,
                    InpNewYorkKZStart,InpNewYorkKZEnd};
   for(int i=0;i<10;i++)
      if(!ParseHM(all[i],h,m))
        { Print("Bad time format (use HH:MM): ",all[i]); return(INIT_PARAMETERS_INCORRECT); }

   for(int s=0;s<3;s++) todayBoxes[s].valid=false;
   BuildAll();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,PREFIX);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration                                        |
//+------------------------------------------------------------------+
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
//--- rebuild drawings on a new M1 bar (cheap enough, keeps boxes fresh)
   datetime curM1=iTime(_Symbol,PERIOD_M1,0);
   if(curM1!=lastM1Bar)
     {
      lastM1Bar=curM1;
      BuildAll();
     }
//--- breakout alerts on every tick
   CheckBreakoutsLive();
   return(rates_total);
  }
//+------------------------------------------------------------------+
