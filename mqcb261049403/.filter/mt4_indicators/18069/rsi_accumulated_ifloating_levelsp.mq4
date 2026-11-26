//------------------------------------------------------------------
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrSilver
#property indicator_color3  clrPaleVioletRed
#property indicator_color4  clrSilver
#property indicator_color5  clrLimeGreen
#property indicator_color6  clrLimeGreen
#property indicator_color7  clrPaleVioletRed
#property indicator_color8  clrPaleVioletRed
#property indicator_width4  2
#property indicator_width5  3
#property indicator_width6  3
#property indicator_width7  3
#property indicator_width8  3
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enPrices
  {
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken Ashi close
   pr_haopen ,    // Heiken Ashi open
   pr_hahigh,     // Heiken Ashi high
   pr_halow,      // Heiken Ashi low
   pr_hamedian,   // Heiken Ashi median
   pr_hatypical,  // Heiken Ashi typical
   pr_haweighted, // Heiken Ashi weighted
   pr_haaverage,  // Heiken Ashi average
   pr_hamedianb,  // Heiken Ashi median body
   pr_hatbiased,  // Heiken Ashi trend biased price
   pr_hatbiased2  // Heiken Ashi trend biased (extreme) price
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enRsiTypes
  {
   rsi_rsi,  // Regular RSI
   rsi_slow, // Slow RSI
   rsi_rap,  // Rapid RSI
   rsi_har,  // Harris RSI
   rsi_rsx,  // RSX
   rsi_cut   // Cuttlers RSI
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enColorOn
  {
   cc_onSlope,   // Change color on slope change
   cc_onMiddle,  // Change color on middle line cross
   cc_onLevels   // Change color on outer levels cross
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enLevelType
  {
   lvl_floa,  // Floating levels
   lvl_quan   // Quantile levels
  };

extern ENUM_TIMEFRAMES    TimeFrame=PERIOD_CURRENT;       // Time frame to use
extern int                RsiPeriod       = 14;           // RSI period to use
extern enPrices           RsiPrice        = pr_close;     // Price to use
extern int                RsiPriceFilter  = 1;            // RSI price filter
extern ENUM_MA_METHOD     RsiPriceFilterType = MODE_EMA;  // RSI price filter type
extern enRsiTypes         RsiType         = rsi_rsi;      // RSI type to use
extern int                AccPeriod       = 5;            // Accumulate last n RSI values
extern enLevelType        LevelsType      = lvl_floa;     // Levels type
extern int                LevelsPeriod    = 25;           // Levels period
extern double             LevelsUp        = 80;           // Upper level %
extern double             LevelsDown      = 20;           // Lower level %
extern enColorOn          ColorOn=cc_onLevels;            // Color change on :
extern bool               alertsOn        = false;        // Turn alerts on
extern bool               alertsOnCurrent = false;        // Alerts on current (still opened) bar?
extern bool               alertsMessage   = true;         // Alerts should display a pop-up message
extern bool               alertsSound     = true;         // Alerts should play an alert sound?
extern bool               alertsEmail     = false;        // Alerts should send an email?
extern bool               Interpolate     = true;         // Interpolate in multi time frame mode?


double rsi[],rsic[],rsicDa[],rsicDb[],rsicUa[],rsicUb[],levup[],levmi[],levdn[],state[],prices[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,RsiPeriod,RsiPrice,RsiPriceFilter,RsiPriceFilterType,RsiType,AccPeriod,LevelsType,LevelsPeriod,LevelsUp,LevelsDown,ColorOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,_buff,_ind)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   for(int i=0; i<indicator_buffers; i++) SetIndexStyle(i,DRAW_LINE);
   IndicatorBuffers(12);
   SetIndexBuffer(0,levup);
   SetIndexBuffer(1,levmi);
   SetIndexBuffer(2,levdn);
   SetIndexBuffer(3,rsic);
   SetIndexBuffer(4,rsicUa);
   SetIndexBuffer(5,rsicUb);
   SetIndexBuffer(6,rsicDa);
   SetIndexBuffer(7,rsicDb);
   SetIndexBuffer(8,rsi);
   SetIndexBuffer(9,state);
   SetIndexBuffer(10,prices);
   SetIndexBuffer(11,count);
   indicatorFileName = WindowExpertName();
   TimeFrame         = MathMax(TimeFrame,_Period);
   RsiPriceFilter    = MathMax(RsiPriceFilter,1);
   IndicatorShortName(timeFrameToString(TimeFrame)+" "+"Accumulated "+getRsiName(RsiType)+" ("+(string)RsiPeriod+","+(string)RsiPriceFilter+","+(string)AccPeriod+")");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=MathMin(Bars-counted_bars,Bars-1); count[0]=limit;
   if(TimeFrame!=_Period)
     {
      limit=(int)MathMax(limit,MathMin(Bars-1,_mtfCall(11,0)*TimeFrame/Period()));
      if(state[limit] ==-1) CleanPoint(limit,rsicDa,rsicDb);
      if(state[limit] == 1) CleanPoint(limit,rsicUa,rsicUb);
      for(int i=limit;i>=0;i--)
        {
         int y=iBarShift(NULL,TimeFrame,Time[i]);
         levup[i]  = _mtfCall(0,y);
         levmi[i]  = _mtfCall(1,y);
         levdn[i]  = _mtfCall(2,y);
         rsic[i]   = _mtfCall(3,y);
         state[i]  = _mtfCall(9,y);
         rsicDa[i] = EMPTY_VALUE;
         rsicDb[i] = EMPTY_VALUE;
         rsicUa[i] = EMPTY_VALUE;
         rsicUb[i] = EMPTY_VALUE;


         if(!Interpolate ||(i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
#define _interpolate(buff) buff[i+k]=buff[i]+(buff[i+n]-buff[i])*k/n
         int n,k; datetime time=iTime(NULL,TimeFrame,y);
         for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;
         for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++)
           {
            _interpolate(levup);
            _interpolate(levmi);
            _interpolate(levdn);
            _interpolate(rsic);
           }
        }
      for(int i=limit;i>=0;i--)
        {
         if(state[i] == 1) PlotPoint(i,rsicUa,rsicUb,rsic);
         if(state[i] ==-1) PlotPoint(i,rsicDa,rsicDb,rsic);
        }
      return(0);
     }

   if(state[limit] ==-1) CleanPoint(limit,rsicDa,rsicDb);
   if(state[limit] == 1) CleanPoint(limit,rsicUa,rsicUb);
   for(int i=limit; i>=0; i--) prices[i] = getPrice(RsiPrice,Open,Close,High,Low,i);
   for(int i=limit; i>=0; i--)
     {
      rsi[i]    = iRsi(RsiType,iMAOnArray(prices,0,RsiPriceFilter,0,RsiPriceFilterType,i),RsiPeriod,i);
      rsic[i]   = 0;
      rsicDa[i] = EMPTY_VALUE;
      rsicDb[i] = EMPTY_VALUE;
      rsicUa[i] = EMPTY_VALUE;
      rsicUb[i] = EMPTY_VALUE;
      for(int k=0; k<AccPeriod && (i+k)<Bars; k++) rsic[i]+=rsi[i+k];
      double hi=rsic[i]; double lo=rsic[i];
      if(LevelsType==lvl_floa)
        {
         if(LevelsPeriod>0)
           {
            hi = rsic[ArrayMaximum(rsic,LevelsPeriod,i)];
            lo = rsic[ArrayMinimum(rsic,LevelsPeriod,i)];
            hi = lo+(hi-lo)*LevelsUp  /100.0;
            lo = lo+(hi-lo)*LevelsDown/100.0;
           }
         levup[i] = hi;
         levdn[i] = lo;
         levmi[i] = (levup[i]+levdn[i])/2.0;
        }
      else
        {
         levup[i] = iQuantile(rsic[i],LevelsPeriod, LevelsUp  ,i,Bars);
         levdn[i] = iQuantile(rsic[i],LevelsPeriod, LevelsDown,i,Bars);
         levmi[i] = iQuantile(rsic[i],LevelsPeriod,(LevelsDown+LevelsUp)/2,i,Bars);
        }


      switch(ColorOn)
        {
         case cc_onLevels:         state[i] = (rsic[i]>levup[i])  ? 1 : (rsic[i]<levdn[i])  ? -1 : 0; break;
         case cc_onMiddle:         state[i] = (rsic[i]>levmi[i])  ? 1 : (rsic[i]<levmi[i])  ? -1 : 0; break;
         default :  if(i<Bars-1) state[i]=(rsic[i]>rsic[i+1]) ? 1 :(rsic[i]<rsic[i+1]) ? -1 : state[i+1];
        }
      if(state[i] == 1) PlotPoint(i,rsicUa,rsicUb,rsic);
      if(state[i] ==-1) PlotPoint(i,rsicDa,rsicDb,rsic);
     }
   manageAlerts();
   return(0);
  }

string rsiMethodNames[]={"RSI","Slow RSI","Rapid RSI","Harris RSI","RSX","Cuttler RSI"};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getRsiName(int method)
  {
   int max=ArraySize(rsiMethodNames)-1;
   method=MathMax(MathMin(method,max),0); return(rsiMethodNames[method]);
  }

double workRsi[][13];
#define _price  0
#define _change 1
#define _changa 2
#define _rsival 1
#define _rsval  1
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iRsi(int rsiMode,double price,double period,int i,int instanceNo=0)
  {
   if(ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
   int z = instanceNo*13;
   int r = Bars-i-1;

   workRsi[r][z+_price]=price;
   period=MathMax(period,1);
   switch(rsiMode)
     {
      case rsi_rsi:
        {
         double alpha=1.0/period;
         if(r<period)
           {
            int k; double sum=0; for(k=0; k<period && (r-k-1)>=0; k++) sum+=MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
            workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
            workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
           }
         else
           {
            double change=workRsi[r][z+_price]-workRsi[r-1][z+_price];
            workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
            workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
           }
         if(workRsi[r][z+_changa]!=0)
            return(50.0*(workRsi[r][z+_change]/workRsi[r][z+_changa]+1));
         else  return(50.0);
        }


      case rsi_slow :
        {
         if(r<period) { workRsi[r][z+_rsival]=0; return(0); }
         double tup = 0;
         double tdn = 0;
         for(int k=0; k<(int)period && (r-k-1)>=0; k++)
           {
            double diff=workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
            if(diff>0)
               tup+=diff;
            else  tdn-=diff;
           }
         if(tup+tdn==0)
            workRsi[r][z+_rsival]=workRsi[r-1][z+_rsival]+(1/period)*(50               -workRsi[r-1][z+_rsival]);
         else  workRsi[r][z+_rsival]=workRsi[r-1][z+_rsival]+(1/period)*(100*tup/(tup+tdn)-workRsi[r-1][z+_rsival]);
         return(workRsi[r][z+_rsival]);
        }


      case rsi_rap :
        {
         double tup=0,tdn=0;
         for(int k=0; k<(int)period && (r-k-1)>=0; k++)
           {
            double diff=workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
            if(diff>0)
               tup+=diff;
            else  tdn-=diff;
           }
         if(tup+tdn==0)
            return(50);
         else  return(100 * tup / (tup + tdn));
        }



      case rsi_har :
        {
         double avgUp=0,avgDn=0,tup=0,tdn=0;
         for(int k=0; k<(int)period && (r-k-1)>=0; k++)
           {
            double diff=workRsi[r-k][instanceNo+_price]-workRsi[r-k-1][instanceNo+_price];
            if(diff>0)
              { avgUp+=diff; tup++; }
            else  { avgDn-=diff; tdn++; }
           }
         if(tup!=0) avgUp /= tup;
         if(tdn!=0) avgDn /= tdn;
         double rs=1;
         if(avgDn!=0) rs=avgUp/avgDn;
         return(100-100/(1.0+rs));
        }


      case rsi_rsx :
        {
         double Kg=(3.0)/(2.0+period),Hg=1.0-Kg;
         if(r<period) { for(int k=1; k<13; k++) workRsi[r][k+z]=0; return(50); }

         double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
         double moa = MathAbs(mom);
         for(int k=0; k<3; k++)
           {
            int kk=k*2;
            workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
            workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
            workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
            workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
           }
         if(moa!=0)
            return(MathMax(MathMin((mom/moa+1.0)*50.0,100.00),0.00));
         else return(50);
        }


      case rsi_cut :
        {
         double sump = 0;
         double sumn = 0;
         for(int k=0; k<(int)period && (r-k-1)>=0; k++)
           {
            double diff=workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
            if(diff > 0) sump += diff;
            if(diff < 0) sumn -= diff;
           }
         if(sumn>0)
            return(100.0-100.0/(1.0+sump/sumn));
         else  return(50);
        }
     }
   return(0);
  }

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
#define _quantileInstances 1
double _sortQuant[];
double _workQuant[][_quantileInstances];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iQuantile(double value,int period,double qp,int i,int bars,int instanceNo=0)
  {
   if(period<1) return(value);
   if(ArrayRange(_workQuant,0)!=bars) ArrayResize(_workQuant,bars);
   if(ArraySize(_sortQuant)!=period) ArrayResize(_sortQuant,period); ArrayInitialize(_sortQuant,0);
   i=bars-i-1; _workQuant[i][instanceNo]=value;
   for(int k=0; k<period && (i-k)>=0; k++) _sortQuant[k]=_workQuant[i-k][instanceNo];
   ArraySort(_sortQuant);

   double index = (period-1.0)*qp/100.00;
   int    ind   = (int)index;
   double delta = index - ind;
   if(ind==NormalizeDouble(index,5))
      return(            _sortQuant[ind]);
   else  return((1.0-delta)*_sortQuant[ind]+delta*_sortQuant[ind+1]);
  }

#define priceInstances     1
#define priceInstancesSize 4
double workHa[][priceInstances*priceInstancesSize];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPrice(int tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int instanceNo=0)
  {
   if(tprice>=pr_haclose)
     {
      if(ArrayRange(workHa,0)!=Bars) ArrayResize(workHa,Bars); instanceNo*=priceInstancesSize; int r=Bars-i-1;


      double haOpen;
      if(r>0)
         haOpen=(workHa[r-1][instanceNo+2]+workHa[r-1][instanceNo+3])/2.0;
      else   haOpen  = (open[i]+close[i])/2;
      double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      double haHigh  = fmax(high[i], fmax(haOpen,haClose));
      double haLow   = fmin(low[i] , fmin(haOpen,haClose));

      if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; }
      else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  }
      workHa[r][instanceNo+2] = haOpen;
      workHa[r][instanceNo+3] = haClose;


      switch(tprice)
        {
         case pr_haclose:     return(haClose);
         case pr_haopen:      return(haOpen);
         case pr_hahigh:      return(haHigh);
         case pr_halow:       return(haLow);
         case pr_hamedian:    return((haHigh+haLow)/2.0);
         case pr_hamedianb:   return((haOpen+haClose)/2.0);
         case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
         case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
         case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
         case pr_hatbiased:
            if(haClose>haOpen)
            return((haHigh+haClose)/2.0);
            else  return((haLow+haClose)/2.0);
         case pr_hatbiased2:
            if(haClose>haOpen)  return(haHigh);
            if(haClose<haOpen)  return(haLow);
            return(haClose);
        }
     }

   switch(tprice)
     {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:
         if(close[i]>open[i])
         return((high[i]+close[i])/2.0);
         else  return((low[i]+close[i])/2.0);
      case pr_tbiased2:
         if(close[i]>open[i]) return(high[i]);
         if(close[i]<open[i]) return(low[i]);
         return(close[i]);
     }
   return(0);
  }
//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
void CleanPoint(int i,double &first[],double &second[])
  {
   if(i>=Bars-3) return;
   if((second[i]!=EMPTY_VALUE) &&(second[i+1] !=EMPTY_VALUE))
      second[i+1]=EMPTY_VALUE;
   else
   if((first[i]!=EMPTY_VALUE) && (first[i+1]!=EMPTY_VALUE) && (first[i+2]==EMPTY_VALUE))
                 first[i+1]=EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PlotPoint(int i,double &first[],double &second[],double &from[])
  {
   if(i>=Bars-2) return;
   if(first[i+1]==EMPTY_VALUE)
      if(first[i+2]==EMPTY_VALUE)
        { first[i]=from[i];  first[i+1]=from[i+1]; second[i]=EMPTY_VALUE; }
   else  { second[i]=from[i]; second[i+1]=from[i+1]; first[i]=EMPTY_VALUE; }
   else     { first[i]=from[i];                           second[i]=EMPTY_VALUE; }
  }
//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
void manageAlerts()
  {
   if(alertsOn)
     {
      int whichBar=1; if(alertsOnCurrent) whichBar=0;
      if(state[whichBar]!=state[whichBar+1])
        {
         if(state[whichBar] ==  1)                            doAlert(whichBar," lower level broken down");
         if(state[whichBar] == -1)                            doAlert(whichBar," upper level broken up");
         if(state[whichBar] ==  0 && state[whichBar+1] ==  1) doAlert(whichBar," lower level broken up");
         if(state[whichBar] ==  0 && state[whichBar+1] == -1) doAlert(whichBar," upper level broken down");
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int forBar,string doWhat)
  {
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;

   if(previousAlert!=doWhat || previousTime!=Time[forBar])
     {
      previousAlert  = doWhat;
      previousTime   = Time[forBar];



      message=timeFrameToString(_Period)+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" RSI accumulated "+doWhat;
      if(alertsMessage) Alert(message);
      if(alertsEmail) SendMail(Symbol()+" RSI accumulated ",message);
      if(alertsSound) PlaySound("alert2.wav");
     }
  }

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
  {
   for(int i=ArraySize(iTfTable)-1; i>=0; i--)
      if(tf==iTfTable[i]) return(sTfTable[i]);
   return("");
  }
//+------------------------------------------------------------------+
