//------------------------------------------------------------------
#property copyright   "© mladen, 2016, MetaQuotes Software Corp."
#property link        "www.forex-tsd.com, forge.mql5.io"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   5
#property indicator_label1  "CCI Ob/Os zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrLimeGreen,clrDeepPink
#property indicator_label2  "CCI level up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellowGreen
#property indicator_style2  STYLE_DOT
#property indicator_label3  "CCI middle level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DOT
#property indicator_label4  "CCI level down"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrHotPink
#property indicator_style4  STYLE_DOT
#property indicator_label5  "CCI"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrSilver,clrLimeGreen,clrHotPink
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2

//
//
//
//
//

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
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};
enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
};
enum chgColor
{
   chg_onSlope,  // change color on slope change
   chg_onLevel,  // Change color on outer levels cross
   chg_onMiddle  // Change color on middle level cross
};
enum enLevelType
{
   lvl_floa,  // Floating levels
   lvl_quan   // Quantile levels
};
enum enAdapting
{
   ada_vhf, // VHF adaptive 
   ada_noa  // Regular (no adapting)
};

input ENUM_TIMEFRAMES TimeFrame         = PERIOD_CURRENT; // Time frame
input int             CciPeriod         = 50;             // CCI calculating period
input enPrices        CciPrice          = pr_close;       // Price
input enAdapting      CciAdapting       = ada_vhf;        // Adapting type 
input int             PriceSmooth       = 32;             // Price smoothing
input enMaTypes       PriceSmoothMethod = ma_ema;         // Price smoothing method
input int             LevelsPeriod      = 25;             // Levels period (<0 no levels, 0 same as CCI period)
input double          LevelsUp          = 90;             // Levels up level %
input double          LevelsDown        = 10;             // Levels down level %
input enLevelType     LevelType         = lvl_floa;       // Levels type
input chgColor        ColorOn           = chg_onLevel;    // Color change on :
input bool            AlertsOn          = false;          // Turn alerts on?
input bool            AlertsOnCurrent   = true;           // Alert on current bar?
input bool            AlertsMessage     = true;           // Display messageas on alerts?
input bool            AlertsSound       = false;          // Play sound on alerts?
input bool            AlertsEmail       = false;          // Send email on alerts?
input bool            AlertsNotify      = false;          // Send push notification on alerts?
input bool            Interpolate       = true;           // Interpolate in multi time frame mode?

double val[],fillup[],filldn[],levelup[],levelmi[],leveldn[],colorBuffer[],count[],prices[];
int     _mtfHandle = INVALID_HANDLE; ENUM_TIMEFRAMES timeFrame;
#define _mtfCall iCustom(_Symbol,timeFrame,getIndicatorName(),PERIOD_CURRENT,CciPeriod,CciPrice,CciAdapting,PriceSmooth,PriceSmoothMethod,LevelsPeriod,LevelsUp,LevelsDown,LevelType,ColorOn,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,AlertsNotify)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,fillup     ,INDICATOR_DATA);
   SetIndexBuffer(1,filldn     ,INDICATOR_DATA);
   SetIndexBuffer(2,levelup    ,INDICATOR_DATA);
   SetIndexBuffer(3,levelmi    ,INDICATOR_DATA);
   SetIndexBuffer(4,leveldn    ,INDICATOR_DATA);
   SetIndexBuffer(5,val        ,INDICATOR_DATA);
   SetIndexBuffer(6,colorBuffer,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(7,count      ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,prices     ,INDICATOR_CALCULATIONS);
      for (int i=0; i<4; i++) PlotIndexSetInteger(i,PLOT_SHOW_DATA,false); 
      timeFrame = MathMax(_Period,TimeFrame);
         if (timeFrame != _Period) _mtfHandle = _mtfCall;
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(timeFrame)+" CCI ("+string(CciPeriod)+","+string(PriceSmooth)+")");
   return(INIT_SUCCEEDED);
}

//
//
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (Bars(_Symbol,_Period)<rates_total) return(-1);

      //
      //
      //
      //
      //

      if (timeFrame!=_Period)
      {
         double result[]; datetime currTime[],nextTime[]; 
            if (_mtfHandle==INVALID_HANDLE) _mtfHandle = _mtfCall;
            if (_mtfHandle==INVALID_HANDLE)              return(0);
            if (CopyBuffer(_mtfHandle,7,0,1,result)==-1) return(0); 
      
                //
                //
                //
                //
                //
              
                #define _mtfRatio PeriodSeconds(timeFrame)/PeriodSeconds(_Period)
                int i,k,n,limit = MathMin(MathMax(prev_calculated-1,0),MathMax(rates_total-(int)result[0]*_mtfRatio-1,0));
                for (i=limit; i<rates_total && !_StopFlag; i++ )
                {
                  #define _mtfCopy(_buff,_buffNo) if (CopyBuffer(_mtfHandle,_buffNo,time[i],1,result)==-1) break; _buff[i] = result[0]
                          _mtfCopy(fillup     ,0);
                          _mtfCopy(filldn     ,1);
                          _mtfCopy(levelup    ,2);
                          _mtfCopy(levelmi    ,3);
                          _mtfCopy(leveldn    ,4);
                          _mtfCopy(val        ,5);
                          _mtfCopy(colorBuffer,6);
                   
                          //
                          //
                          //
                          //
                          //
                   
                          if (!Interpolate) continue;  CopyTime(_Symbol,timeFrame,time[i  ],1,currTime); 
                              if (i<(rates_total-1)) { CopyTime(_Symbol,timeFrame,time[i+1],1,nextTime); if (currTime[0]==nextTime[0]) continue; }
                              for(n=1; (i-n)> 0 && time[i-n] >= currTime[0]; n++) continue;	
                              for(k=1; (i-k)>=0 && k<n; k++)
                              {
                                 #define _mtfInterpolate(_buff) _buff[i-k] = _buff[i]+(_buff[i-n]-_buff[i])*k/n
                                 _mtfInterpolate(fillup );
                                 _mtfInterpolate(filldn );
                                 _mtfInterpolate(levelup);
                                 _mtfInterpolate(leveldn);
                                 _mtfInterpolate(levelmi);
                                 _mtfInterpolate(val    );
                              }                              
                }
                return(i);
      }

   //
   //
   //
   //
   //
   
   int levelsPeriod = (LevelsPeriod<0) ? 1 : (LevelsPeriod==0) ? (int)CciPeriod : LevelsPeriod;
   int colorOn      = (levelsPeriod>1) ? ColorOn : chg_onSlope;
   int i; for (i=(int)MathMax(prev_calculated-1,0); i<rates_total  && !_StopFlag; i++)
   {
      double price = getPrice(CciPrice,open,close,high,low,i,rates_total);
         double vhf       = (CciAdapting==ada_vhf) ? iVhf(price,CciPeriod,i,rates_total) : 0;
         double period    = (vhf!=0) ? MathCeil(CciPeriod*(-MathLog(vhf))) : CciPeriod;
                prices[i] = iCustomMa(PriceSmoothMethod,price,PriceSmooth,i,rates_total);
               double avg = 0; for(int k=0; k<(int)period && (i-k)>=0; k++) avg +=         prices[i-k];      avg /= (int)period;
               double dev = 0; for(int k=0; k<(int)period && (i-k)>=0; k++) dev += MathAbs(prices[i-k]-avg); dev /= (int)period;
               if (dev!=0)
                     val[i] = (prices[i]-avg)/(0.015*dev);
               else  val[i] = 0;          

         //
         //
         //
         //
         //
               
         if (LevelType==lvl_floa)
         {
               int    start = MathMax(i-levelsPeriod+1,0);
               double min   = val[ArrayMinimum(val,start,levelsPeriod)];
               double max   = val[ArrayMaximum(val,start,levelsPeriod)];
               double range = max-min;
                  levelup[i] = min+LevelsUp  *range/100.0;
                  leveldn[i] = min+LevelsDown*range/100.0;
                  levelmi[i] = min+0.5*range;
         }
         else
         {
                  levelup[i] = iQuantile(val[i],levelsPeriod, LevelsUp                ,i,rates_total);
                  leveldn[i] = iQuantile(val[i],levelsPeriod, LevelsDown              ,i,rates_total);
                  levelmi[i] = iQuantile(val[i],levelsPeriod,(LevelsUp+LevelsDown)/2.0,i,rates_total);
         }
         switch (colorOn)
         {
            case chg_onLevel :  colorBuffer[i] = (val[i]>levelup[i]) ? 1 : (val[i]<leveldn[i]) ? 2 : (val[i]<levelup[i] && val[i]>leveldn[i]) ? 0 : (i>0) ? colorBuffer[i-1]: 0; break;
            case chg_onMiddle : colorBuffer[i] = (val[i]>levelmi[i]) ? 1 : (val[i]<levelmi[i]) ? 2 : (i>0) ? colorBuffer[i-1] : 0; break;
            default :           colorBuffer[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : colorBuffer[i-1] : 0;
         }                  
         fillup[i]  = val[i];
         filldn[i]  = MathMin(MathMax(val[i],leveldn[i]),levelup[i]);
   }      
   count[rates_total-1] = MathMax(rates_total-prev_calculated+1,1);
   manageAlerts(time,colorBuffer,rates_total);
   return(i);
}


//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

#define _vhfInstances 1
double  _workVhf[][_vhfInstances];

double iVhf(double value, int period, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(_workVhf,0)!=bars) ArrayResize(_workVhf,bars);
                  _workVhf[i][instanceNo]=value;
                  
   //
   //
   //
   //
   //

      double noise = 0, vhf = 0;
      double max = value, min = value;
         for (int k=0; k<period && (i-k-1)>=0; k++)
         {
            noise += MathAbs(_workVhf[i-k][instanceNo]-_workVhf[i-k-1][instanceNo]);
            max    = MathMax(_workVhf[i-k][instanceNo],max);   
            min    = MathMin(_workVhf[i-k][instanceNo],min);   
         }      
         if (noise>0) vhf = (max-min)/noise;
   return(vhf);
}                        

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

#define _quantileInstances 1
double _sortQuant[];
double _workQuant[][_quantileInstances];

double iQuantile(double value, int period, double qp, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(_workQuant,0)!=bars) ArrayResize(_workQuant,bars);   _workQuant[i][instanceNo]=value; if (period<1) return(value);
   if (ArraySize(_sortQuant)!=period)  ArrayResize(_sortQuant,period); 
            int k=0; for (; k<period && (i-k)>=0; k++) _sortQuant[k] = _workQuant[i-k][instanceNo];
                     for (; k<period            ; k++) _sortQuant[k] = 0;
                     ArraySort(_sortQuant);

   //
   //
   //
   //
   //
   
   double index = (period-1.0)*qp/100.00;
   int    ind   = (int)index;
   double delta = index - ind;
   if (ind == NormalizeDouble(index,5))
         return(            _sortQuant[ind]);
   else  return((1.0-delta)*_sortQuant[ind]+delta*_sortQuant[ind+1]);
}   

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 3
#define _maWorkBufferx1 1*_maInstances
double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); int k=1;

   workSma[r][instanceNo+0] = price;
   double avg = price; for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  avg /= (double)k;
   return(avg);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<1) return(price);
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void manageAlerts(const datetime& time[], double& trend[], int bars)
{
   if (!AlertsOn) return;
      int whichBar = bars-1; if (!AlertsOnCurrent) whichBar = bars-2; datetime time1 = time[whichBar];
      if (trend[whichBar] != trend[whichBar-1])
      {
         if (trend[whichBar] == 1) doAlert(time1,"up");
         if (trend[whichBar] == 2) doAlert(time1,"down");
      }         
}   

//
//
//
//
//

void doAlert(datetime forTime, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != forTime) 
   {
      previousAlert  = doWhat;
      previousTime   = forTime;

      //
      //
      //
      //
      //

      message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToString(TimeLocal(),TIME_SECONDS)+" CCI state changed to "+doWhat;
         if (AlertsMessage) Alert(message);
         if (AlertsEmail)   SendMail(_Symbol+" CCI",message);
         if (AlertsNotify)  SendNotification(message);
         if (AlertsSound)   PlaySound("alert2.wav");
   }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define _pricesInstances 3
#define _pricesSize      4
double workHa[][_pricesInstances*_pricesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); instanceNo*=_pricesSize;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (i>0)
                haOpen  = (workHa[i-1][instanceNo+2] + workHa[i-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[i][instanceNo+0] = haLow;  workHa[i][instanceNo+1] = haHigh; } 
         else                 { workHa[i][instanceNo+0] = haHigh; workHa[i][instanceNo+1] = haLow;  } 
                                workHa[i][instanceNo+2] = haOpen;
                                workHa[i][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
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
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
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
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string getIndicatorName()
{
   string path = MQL5InfoString(MQL5_PROGRAM_PATH);
   string data = TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Indicators\\";
   string name = StringSubstr(path,StringLen(data));
      return(name);
}

//
//
//
//
//

int    _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};
string timeFrameToString(int period)
{
   if (period==PERIOD_CURRENT) 
       period = _Period;   
         int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);   
}