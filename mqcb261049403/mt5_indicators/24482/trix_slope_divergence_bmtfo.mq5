//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Trix"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_width1  2

//
//---
//

enum enTimeFrames
{
   tf_cu  = PERIOD_CURRENT, // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m2  = PERIOD_M2,      // 2 minutes
   tf_m3  = PERIOD_M3,      // 3 minutes
   tf_m4  = PERIOD_M4,      // 4 minutes
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m6  = PERIOD_M6,      // 6 minutes
   tf_m10 = PERIOD_M10,     // 10 minutes
   tf_m12 = PERIOD_M12,     // 12 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m20 = PERIOD_M20,     // 20 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h2  = PERIOD_H2,      // 2 hours
   tf_h3  = PERIOD_H3,      // 3 hours
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_h6  = PERIOD_H6,      // 6 hours
   tf_h8  = PERIOD_H8,      // 8 hours
   tf_h12 = PERIOD_H12,     // 12 hours
   tf_d1  = PERIOD_D1,      // daily
   tf_w1  = PERIOD_W1,      // weekly
   tf_mn  = PERIOD_MN1,     // monthly
   tf_cp1 = -1,             // Next higher time frame
   tf_cp2 = -2,             // Second higher time frame
   tf_cp3 = -3              // Third higher time frame
};
input enTimeFrames       inpTimeFrame            = tf_cu;         // Time frame
input int                inpPeriod               = 14;            // TRiX period
input ENUM_APPLIED_PRICE inpPrice                = PRICE_CLOSE;   // Price
input int                inpLrPeriod             = 50;            // Linear regression period
input double             inpLrWidth              = 2.0;           // Linear regression channel width
input color              inpClrDiverging         = clrRed;        // Color of middle liones when there is divergence
input color              inpChartLineColor       = clrDarkGray;   // On chart channel color
input color              inpChartBackColor       = clrGainsboro;  // On chart channel back color
input ENUM_LINE_STYLE    inpChartLineMiddleStyle = STYLE_DOT;     // On chart channel middle line style
input ENUM_LINE_STYLE    inpChartLineStyle       = STYLE_SOLID;   // On chart channel outer lines style
input color              inpIndLineColor         = clrDarkGray;   // On macd channel color
input color              inpIndBackColor         = clrGainsboro;  // On macd channel back color
input ENUM_LINE_STYLE    inpIndLineMiddleStyle   = STYLE_DOT;     // On macd channel middle line style
input ENUM_LINE_STYLE    inpIndLineStyle         = STYLE_SOLID;   // On macd channel outer lines style
input string             inpUniqueID             = "TRiXSlopeDiv1";// Unique ID for objects 
enum enIterpolate
{
   interolate_yes=(int)true, // Interpolate data when in multi time frame
   interolate_no =(int)false // Do not interpolate data when in multi time frame
};
input enIterpolate inpInterpolate = interolate_yes; // Interpolation

//
//---
//

double val[],prices[],count[];
int  ª_mtfHandle; 

ENUM_TIMEFRAMES _indicatorTimeFrame; string _indicatorName,_indicatorShortName;
#define _mtfCall iCustom(_Symbol,_indicatorTimeFrame,_indicatorName,0,inpPeriod,inpPrice,inpLrPeriod,inpLrWidth,inpClrDiverging,inpChartLineColor,inpChartBackColor,inpChartLineMiddleStyle,inpChartLineStyle,inpIndLineColor,inpIndBackColor,inpIndLineMiddleStyle,inpIndLineStyle,inpUniqueID)

//------------------------------------------------------------------ 
//  Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,val   ,INDICATOR_DATA);
         SetIndexBuffer(1,prices,INDICATOR_CALCULATIONS);
         SetIndexBuffer(2,count ,INDICATOR_CALCULATIONS);
         
         //
         //---
         //
         
         _indicatorTimeFrame  = MathMax(_Period,timeFrameGet(inpTimeFrame)); 
         if (_indicatorTimeFrame != _Period) 
            { 
               _indicatorName = getIndicatorName();
               ª_mtfHandle    = _mtfCall; 
                     if (!_checkHandle(ª_mtfHandle,"Target "+timeFrameToString(_indicatorTimeFrame)+" time frame instance")) return(INIT_FAILED); 
            }
         iTrix.init(inpPeriod);            
   //            
   //----
   //
   
   _indicatorShortName = "("+inpUniqueID+") "+timeFrameToString(_indicatorTimeFrame)+"TRiX slope divergence ("+(string)inpPeriod+")("+(string)inpLrPeriod+")";
   IndicatorSetString(INDICATOR_SHORTNAME,_indicatorShortName);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { ObjectsDeleteAll(0,inpUniqueID+":"); }

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}
   
//
//---
//

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
   //
   //---
   //
         if(_indicatorTimeFrame!=_Period)
         {
            double result[1]; if (CopyBuffer(ª_mtfHandle,2,0,1,result)<0) result[0] = rates_total;

            //
            //---
            //
      
            #define _mtfRatio (double)PeriodSeconds((ENUM_TIMEFRAMES)_indicatorTimeFrame)/PeriodSeconds(_Period)
            
               int n,k,i=MathMin(MathMax(prev_calculated-1,0),MathMax(rates_total-int(result[0]*_mtfRatio)-1,0)),_prevMark=-99; datetime _prevTime;
               for(; i<rates_total && !_StopFlag; i++)
               {
                  int _currMark = iBarShift(_Symbol,_indicatorTimeFrame,time[i]); if (_currMark<0) continue;
                  if (_currMark!=_prevMark)
                  {
                     _prevMark =_currMark;
                     _prevTime = time[i];
                     #define _mtfCopy(_buff,_buffNo) { if(CopyBuffer(ª_mtfHandle,_buffNo,_currMark,1,result)<1) break; _buff[i]=result[0]; }
                             _mtfCopy(val ,0);
                  }
                  else 
                  {
                     #define _mtfCopyValue(_buff) _buff[i] = _buff[i-1]; 
                             _mtfCopyValue(val);
                  }                  
               
                  //
                  //---
                  //

                  if(!inpInterpolate) continue;
                     int _nextMark = (i<rates_total-1) ? iBarShift(_Symbol,_indicatorTimeFrame,time[i+1]) : _prevMark+1; if(_nextMark==_prevMark) continue;               
                     for (n=1; (i-n)> 0 && time[i-n] >= _prevTime; n++) continue;
                     for (k=1; (i-k)>=0 && k<n; k++)
                     {
                        #define _mtfInterpolate(_buff) _buff[i-k]=_buff[i]+(_buff[i-n]-_buff[i])*k/n
                                _mtfInterpolate(val);
                     }               
            }
            return(i);
         }

   //
   //
   //---
   //
   //
   
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i); val[i] = iTrix.calculate(prices[i],i,rates_total);
   }      
      double indError; double indSlope; double lrInd = iLrValue(val   ,inpLrPeriod,indSlope,indError,rates_total-1);
      double prcError; double prcSlope; double lrPrc = iLrValue(prices,inpLrPeriod,prcSlope,prcError,rates_total-1);
      bool _isThereDivergence = (indSlope*prcSlope<0);
         int window = ChartWindowFind(0,_indicatorShortName);
            createChannel(window,lrInd,lrInd-(inpLrPeriod-1.0)*indSlope,"rsiLine",inpIndLineColor  ,_isThereDivergence?inpClrDiverging:inpIndLineColor  ,inpIndLineStyle  ,inpIndLineMiddleStyle  ,inpIndBackColor  ,indError*inpLrWidth);
            createChannel(0     ,lrPrc,lrPrc-(inpLrPeriod-1.0)*prcSlope,"prcLine",inpChartLineColor,_isThereDivergence?inpClrDiverging:inpChartLineColor,inpChartLineStyle,inpChartLineMiddleStyle,inpChartBackColor,prcError*inpLrWidth);

            //
            //---
            //
            
            count[rates_total-1]=MathMax(i-prev_calculated+1,1);
   return(rates_total);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

void createChannel(int window, double price1, double price2, string addName, color theColor,color middleColor, int theStyle, int theMiddleStyle, color backColor, double error)
{
   string name = inpUniqueID+":"+addName;
      if (ObjectFind(0,name)==-1)
           ObjectCreate(0,name,OBJ_TREND,window,0,0,0,0);
              ObjectSetDouble(0,name,OBJPROP_PRICE,0,price1);
              ObjectSetDouble(0,name,OBJPROP_PRICE,1,price2);
              ObjectSetInteger(0,name,OBJPROP_TIME,0,iTime(NULL,_Period,0)+PeriodSeconds(_Period)-1);
              ObjectSetInteger(0,name,OBJPROP_TIME,1,iTime(NULL,_Period,inpLrPeriod-1));
              ObjectSetInteger(0,name,OBJPROP_RAY,false);
              ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
              ObjectSetInteger(0,name,OBJPROP_COLOR,middleColor);
              ObjectSetInteger(0,name,OBJPROP_STYLE,theMiddleStyle);
                  if (error<=0) return;
      name = inpUniqueID+":"+addName+"up";
      if (ObjectFind(0,name)==-1)
           ObjectCreate(0,name,OBJ_TREND,window,0,0,0,0);
              ObjectSetDouble(0,name,OBJPROP_PRICE,0,price1+error);
              ObjectSetDouble(0,name,OBJPROP_PRICE,1,price2+error);
              ObjectSetInteger(0,name,OBJPROP_TIME,0,iTime(NULL,_Period,0)+PeriodSeconds(_Period)-1);
              ObjectSetInteger(0,name,OBJPROP_TIME,1,iTime(NULL,_Period,inpLrPeriod-1));
              ObjectSetInteger(0,name,OBJPROP_RAY,false);
              ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
              ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
              ObjectSetInteger(0,name,OBJPROP_COLOR,theColor);
              ObjectSetInteger(0,name,OBJPROP_STYLE,theStyle);
      name = inpUniqueID+":"+addName+"down";
      if (ObjectFind(0,name)==-1)
           ObjectCreate(0,name,OBJ_TREND,window,0,0,0,0);
              ObjectSetDouble(0,name,OBJPROP_PRICE,0,price1-error);
              ObjectSetDouble(0,name,OBJPROP_PRICE,1,price2-error);
              ObjectSetInteger(0,name,OBJPROP_TIME,0,iTime(NULL,_Period,0)+PeriodSeconds(_Period)-1);
              ObjectSetInteger(0,name,OBJPROP_TIME,1,iTime(NULL,_Period,inpLrPeriod-1));
              ObjectSetInteger(0,name,OBJPROP_RAY,false);
              ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
              ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
              ObjectSetInteger(0,name,OBJPROP_COLOR,theColor);
              ObjectSetInteger(0,name,OBJPROP_STYLE,theStyle);
              
   //
   //
   //
   
   if (backColor!=clrNONE)
   {
      name = inpUniqueID+":"+addName+"tup";
      if (ObjectFind(0,name)==-1)
           ObjectCreate(0,name,OBJ_TRIANGLE,window,0,0,0,0);
              ObjectSetInteger(0,name,OBJPROP_TIME,0,iTime(NULL,_Period,0)+PeriodSeconds(_Period)-1);
              ObjectSetInteger(0,name,OBJPROP_TIME,1,iTime(NULL,_Period,0)+PeriodSeconds(_Period)-1);
              ObjectSetInteger(0,name,OBJPROP_TIME,2,iTime(NULL,_Period,inpLrPeriod-1));
              ObjectSetInteger(0,name,OBJPROP_COLOR,backColor);
              ObjectSetInteger(0,name,OBJPROP_BACK,true);
              ObjectSetInteger(0,name,OBJPROP_FILL,true);
              ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
              ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
               ObjectSetDouble(0,name,OBJPROP_PRICE,0,price1+error);
               ObjectSetDouble(0,name,OBJPROP_PRICE,1,price1-error);
               ObjectSetDouble(0,name,OBJPROP_PRICE,2,price2-error);
      name = inpUniqueID+":"+addName+"tdn";
      if (ObjectFind(0,name)==-1)
           ObjectCreate(0,name,OBJ_TRIANGLE,window,0,0,0,0);
              ObjectSetInteger(0,name,OBJPROP_TIME,0,iTime(NULL,_Period,0)+PeriodSeconds(_Period)-1);
              ObjectSetInteger(0,name,OBJPROP_TIME,1,iTime(NULL,_Period,inpLrPeriod-1));
              ObjectSetInteger(0,name,OBJPROP_TIME,2,iTime(NULL,_Period,inpLrPeriod-1));
              ObjectSetInteger(0,name,OBJPROP_COLOR,backColor);
              ObjectSetInteger(0,name,OBJPROP_BACK,true);
              ObjectSetInteger(0,name,OBJPROP_FILL,true);
              ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
              ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
               ObjectSetDouble(0,name,OBJPROP_PRICE,0,price1+error);
               ObjectSetDouble(0,name,OBJPROP_PRICE,1,price2-error);
               ObjectSetDouble(0,name,OBJPROP_PRICE,2,price2+error);
           
   }                    
}

//
//---
//

template <typename T> 
double iLrValue(T& values[], int period, double& slope, double& error, int i)
{
   double sumx=0, sumxx=0, sumxy=0, sumy=0, sumyy=0;
   for (int k=0; k<period && i>=k; k++)
   {
         double price = values[i-k];
                   sumx  += k;
                   sumxx += k*k;
                   sumxy += k*price;
                   sumy  +=   price;
                   sumyy +=   price*price;
   }
   slope = (period*sumxy-sumx*sumy)/(sumx*sumx-period*sumxx);
   error = MathSqrt((period*sumyy-sumy*sumy-slope*slope*(period*sumxx-sumx*sumx))/(period*(period-2)));

   //
   //---
   //
         
   return((sumy + slope*sumx)/period);
}

//
//---
//

class CTrix
{
   private :
      double m_period;
      double m_alpha;
      int    m_arraySize;
      struct sTrixStruct
      {
         double price;
         double ema1;
         double ema2;
         double ema3;
      };
      sTrixStruct m_array[];
   
   public :
      CTrix() : m_arraySize(-1), m_alpha(1) {}
     ~CTrix() { ArrayFree(m_array); };
      
      //
      //
      //
      
      bool init(int period)
      {
         m_period = (period>1) ? period : 1;
         m_alpha  = (2.0/(2.0+(m_period-1.0)/2.0));
            return(true);
      }
      
      double calculate(double price, int i, int bars)
      {
          if (m_arraySize<bars)
            { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }

         //
         //---
         //
      
         if (i>0)
         {
            m_array[i].ema1 = m_array[i-1].ema1 + m_alpha*(price          -m_array[i-1].ema1);
            m_array[i].ema2 = m_array[i-1].ema2 + m_alpha*(m_array[i].ema1-m_array[i-1].ema2);
            m_array[i].ema3 = m_array[i-1].ema3 + m_alpha*(m_array[i].ema2-m_array[i-1].ema3);
               return((m_array[i].ema3-m_array[i-1].ema3)/m_array[i].ema3);
         }
         else m_array[i].ema1 = m_array[i].ema2 = m_array[i].ema3 = price;
               return(0);
      }
};
CTrix iTrix;


//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//---
//

ENUM_TIMEFRAMES _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string          _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};
//
//---
//

string timeFrameToString(int period)
{
   if(period==PERIOD_CURRENT)
      period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);
}
//
//---
//

ENUM_TIMEFRAMES timeFrameGet(int period)
{
   int _shift = (period<0 ? MathAbs(period) : 0); if (period<=0) period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
      return(_tfsPer[(int)MathMin(i+_shift,ArraySize(_tfsPer)-1)]);
}

//
//---
//

string getIndicatorName()
{
   string _path=MQL5InfoString(MQL5_PROGRAM_PATH); StringToLower(_path);
   string _partsA[];
   int    _partsN = StringSplit(_path,StringGetCharacter("\\",0),_partsA);
   string name=_partsA[_partsN-1]; for(int n=_partsN-2; n>=0 && _partsA[n]!="indicators"; n--) name=_partsA[n]+"\\"+name;
   return(name);
}

//
//---
//  

bool _checkHandle(int _handle, string _description)
{
   static int  _chandles[];
          int  _size   = ArraySize(_chandles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_chandles,_size+1); _chandles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_chandles[i]); ArrayResize(_chandles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}  
//------------------------------------------------------------------
