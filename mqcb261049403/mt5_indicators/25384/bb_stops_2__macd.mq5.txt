//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Bollinger bands stops - MACD based with multiple stops"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   8
#property indicator_label1  "Bollinger bands stops up stop line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  3
#property indicator_label2  "Bollinger bands stops down stop line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSandyBrown
#property indicator_width2  3
#property indicator_label3  "Bollinger bands stops up first stop line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_label4  "Bollinger bands stops down first stop line"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSandyBrown
#property indicator_label5  "Bollinger bands stops up second stop line"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDodgerBlue
#property indicator_label6  "Bollinger bands stops down second stop line"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrSandyBrown
#property indicator_label7  "MACD"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrOrangeRed
#property indicator_style7  STYLE_DOT
#property indicator_label8  "Macd signal"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrDimGray
#property indicator_style8  STYLE_DOT

//
//--- input parameters
//

input int                inpMacdFastPeriod  = 12;          // Fast MACD period
input int                inpMacdSlowPeriod  = 26;          // Slow MACD period
input int                inpMacdSignPeriod  =  9;          // Signal MACD period
input ENUM_APPLIED_PRICE inpPrice           = PRICE_CLOSE; // MACD Price
input int                inpDevPeriod       = 0;           // Deviation period (<=1 for same as fast MACD period)
input double             inpDeviation       = 2;           // Deviation multiplier
input string             __º__01_00         = "";          // .
input string             __º__01_01         = "";          // Risk settings
input string             __º__01_02         = "";          // .
input double             inpRisk            = 0.75;        // Risk multiplier
input double             inpRisk2           = 1.5;         // Risk 2 multiplier
input double             inpRisk3           = 2.5;         // Risk 3 multiplier

//
//--- indicator buffers
//

double lineup[],linedn[],lineup2[],linedn2[],lineup3[],linedn3[],macd[],signal[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,lineup ,INDICATOR_DATA);
   SetIndexBuffer(1,linedn ,INDICATOR_DATA);
   SetIndexBuffer(2,lineup2,INDICATOR_DATA);
   SetIndexBuffer(3,linedn2,INDICATOR_DATA);
   SetIndexBuffer(4,lineup3,INDICATOR_DATA);
   SetIndexBuffer(5,linedn3,INDICATOR_DATA);
   SetIndexBuffer(6,macd   ,INDICATOR_DATA);
   SetIndexBuffer(7,signal ,INDICATOR_DATA);
         double _risks[3];
                _risks[0] = inpRisk;
                _risks[1] = inpRisk2;
                _risks[2] = inpRisk3; ArraySort(_risks);
         int _devPeriod = inpDevPeriod>1 ? inpDevPeriod : (int)inpMacdFastPeriod;
         iEmaFast.init(inpMacdFastPeriod);
         iEmaSlow.init(inpMacdSlowPeriod);
         iEmaSignal.init(inpMacdSignPeriod);
         iBbStops.init(_devPeriod,inpDeviation,_risks[0],_risks[1],_risks[2]);
   IndicatorSetString(INDICATOR_SHORTNAME,"BB stops 1 MACD ("+(string)inpMacdFastPeriod+","+(string)inpMacdSlowPeriod+","+(string)inpMacdSignPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   static double _results[8] = {EMPTY_VALUE,EMPTY_VALUE,EMPTY_VALUE,EMPTY_VALUE,EMPTY_VALUE,EMPTY_VALUE,EMPTY_VALUE,EMPTY_VALUE};
   
   //
   //
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price  = getPrice(inpPrice,open,high,low,close,i);
      macd[i]   = iEmaFast.calculate(_price,i,rates_total)-iEmaSlow.calculate(_price,i,rates_total);
      signal[i] = iEmaSignal.calculate(macd[i],i,rates_total);
         iBbStops.calculate(macd[i],signal[i],i,_results);
               lineup[i]  = _results[4];
               linedn[i]  = _results[5];
               lineup2[i] = _results[0];
               linedn2[i] = _results[1];
               lineup3[i] = _results[2];
               linedn3[i] = _results[3];
   }          
   return(i);
}
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
//

class CEma
{
   private :
         double m_period;
         double m_alpha;
         double m_array[];
         int    m_arraySize;
   public :
      CEma() : m_period(1), m_alpha(1), m_arraySize(-1) { return; }
     ~CEma()                                            { return; }
     
     //
     //---
     //
     
     void init(int period)
         {
            m_period = (period>1) ? period : 1;
            m_alpha  = 2.0/(1.0+m_period);
         }
      double calculate(double value, int i, int bars)
         {
            if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
            
            //
            //
            //
             
            m_array[i]=value;
               if (i>0)
                    m_array[i] = m_array[i-1]+m_alpha*(value-m_array[i-1]); 
               else m_array[i] = value;
            return (m_array[i]);
         }   
};
CEma iEmaFast,iEmaSlow,iEmaSignal;
//
//---
//

class CEmaDeviation
{
   #define _ringSize 32
   private :
      double m_period;
      double m_divisor;
      double m_alpha;
      int    m_workSize;
      struct sEmaDeviationStruct
      {
         double ema0;
         double ema1;
      };
      sEmaDeviationStruct m_work[_ringSize];
   
   public : 
      CEmaDeviation() { init(1); }
     ~CEmaDeviation() { }
     
     ///
     ///
     ///
     
     bool init(double period)
     {
         m_period  = (period>1) ? period : 1;
         m_divisor = (m_period>2) ? m_period-1 : 1;
         m_alpha   = (2.0/(2.0+(period-1.0)/2.0));
         return(true);
     }
     
     double calculate(double price, int i)
     {
         int _indC = (i)%_ringSize;
         if (i>0)
         {
            int _indP  = (i-1)%_ringSize;
               m_work[_indC].ema0 = m_work[_indP].ema0+m_alpha*(price      -m_work[_indP].ema0);
               m_work[_indC].ema1 = m_work[_indP].ema1+m_alpha*(price*price-m_work[_indP].ema1);
         }         
         else m_work[_indC].ema0 = m_work[_indC].ema1 = price;
   
         return(MathSqrt(m_period*(m_work[_indC].ema1-m_work[_indC].ema0*m_work[_indC].ema0)/m_divisor));
      }      
   #undef _ringSize
};

//
//
//

class CBbStops
{
   #define _ringSize 32
   private :
      int            m_devPeriod;
      double         m_devMultiplier;
      double         m_risk1;
      double         m_risk2;
      double         m_risk3;
      CEmaDeviation* m_emaDeviation;
      struct sBbStopsStruct
      {
         double amax;
         double amin;
         double bmax;
         double bmin;
         double cmax;
         double cmin;
         double dmax;
         double dmin;
         double trend;
      };  
      sBbStopsStruct m_work[_ringSize];
   
   public : 
      CBbStops() { init(1,1,1,1,1); };
     ~CBbStops() { if (CheckPointer(m_emaDeviation)==POINTER_DYNAMIC) delete(m_emaDeviation); };
      
      ///
      ///
      ///
      
      bool init(int devPeriod, double devMultiplier, double risk1, double risk2, double risk3)
      {
         if (CheckPointer(m_emaDeviation) != POINTER_DYNAMIC)
                          m_emaDeviation  = new CEmaDeviation;
         if (CheckPointer(m_emaDeviation) != POINTER_DYNAMIC) return(false);
            
            //
            //
            //
            
            m_devPeriod     = (devPeriod>1) ? devPeriod : 1;
            m_devMultiplier = (devMultiplier>0) ? devMultiplier : 0;
            m_emaDeviation.init(m_devPeriod);
               m_risk1 = risk1;
               m_risk2 = risk2;
               m_risk3 = risk3;
            return(true);
      }

      void calculate(double value, double average, int i, double& result[])
      {
         int _indC = (i  )%_ringSize;
         int _indP = (i-1)%_ringSize;
   
         //
         //---
         //
   
         double deviation = m_emaDeviation.calculate(value,i);
            m_work[_indC].amax  = average + m_devMultiplier*deviation;
            m_work[_indC].amin  = average - m_devMultiplier*deviation;
            m_work[_indC].bmax  = average + m_risk1        *deviation;
            m_work[_indC].bmin  = average - m_risk1        *deviation;
            m_work[_indC].cmax  = average + m_risk2        *deviation;
            m_work[_indC].cmin  = average - m_risk2        *deviation;
            m_work[_indC].dmax  = average + m_risk3        *deviation;
            m_work[_indC].dmin  = average - m_risk3        *deviation;
            if (i>0)
            {
               m_work[_indC].trend = (value > m_work[_indP].amax) ? 1 : (value < m_work[_indP].amin) ? -1 : m_work[_indP].trend;
               if (m_work[_indC].trend==-1)
               {
                  if (m_work[_indC].amax > m_work[_indP].amax) m_work[_indC].amax = m_work[_indP].amax;
                  if (m_work[_indC].bmax > m_work[_indP].bmax) m_work[_indC].bmax = m_work[_indP].bmax;
                  if (m_work[_indC].cmax > m_work[_indP].cmax) m_work[_indC].cmax = m_work[_indP].cmax;
                  if (m_work[_indC].dmax > m_work[_indP].dmax) m_work[_indC].dmax = m_work[_indP].dmax;
                     result[0] = result[2] = result[4] = EMPTY_VALUE;
                     result[1] = m_work[_indC].bmax;
                     result[3] = m_work[_indC].cmax;
                     result[5] = m_work[_indC].dmax;
               }         
               if (m_work[_indC].trend==1)
               {
                  if (m_work[_indC].amin < m_work[_indP].amin) m_work[_indC].amin = m_work[_indP].amin;
                  if (m_work[_indC].bmin < m_work[_indP].bmin) m_work[_indC].bmin = m_work[_indP].bmin;
                  if (m_work[_indC].cmin < m_work[_indP].cmin) m_work[_indC].cmin = m_work[_indP].cmin;
                  if (m_work[_indC].dmin < m_work[_indP].dmin) m_work[_indC].dmin = m_work[_indP].dmin;
                     result[1] = result[3] = result[5] = EMPTY_VALUE;
                     result[0] = m_work[_indC].bmin;
                     result[2] = m_work[_indC].cmin;
                     result[4] = m_work[_indC].dmin;
               }
               result[6] = (m_work[_indC].trend != m_work[_indP].trend);
            }                  
            else m_work[_indC].trend = result[6] = 0;

         //
         //---
         //
      
         result[7] =  m_work[_indC].trend;
      }
   #undef _ringSize
};
CBbStops iBbStops;

//
//---
//

template <typename T>
double getPrice(ENUM_APPLIED_PRICE tprice, T& open[], T& high[],T& low[], T& close[], int i)
{
   switch(tprice)
   {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
   }
   return(0);
}