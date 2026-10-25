//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Recursive Median Oscillator"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "RMO"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//
//

input int                inpPeriod     = 12;          // Low pass period
input int                inpPeriod2    = 30;          // High pass period
input int                inpPeriod3    = 5;           // Median period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price
enum enColorOn
{
   clr_onSlope, // Color change on slope change
   clr_onZero   // Color change on zero cross
};
input enColorOn inpColorOn = clr_onZero; // Color change mode

//
//---
//

double val[],valc[],prices[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val   ,INDICATOR_DATA);
         SetIndexBuffer(1,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,prices,INDICATOR_CALCULATIONS);
            iRmo.init(inpPeriod,inpPeriod2,inpPeriod3);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"RMO ("+(string)inpPeriod+","+(string)inpPeriod2+","+(string)inpPeriod3+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
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

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);
         val[i]  =  iRmo.calculate(prices,i);
         if (inpColorOn==clr_onSlope)
               valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
         else  valc[i] = (val[i]>0) ? 1 :(val[i]<0) ? 2 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

class CRmo
{
   private :
      int    m_lowPass_period;
      int    m_highPass_period;
      int    m_median_period;
      int    m_arraySize;
      int    m_1;
      int    m_2;
      double m_alpha1;
      double m_alpha2;
      double m_sort[];
      struct sRmoStruct
      {
         double rm;
         double rmo;
      };
      sRmoStruct m_array[];

   public :
      CRmo(void) { init(1,1,1);                           return; }
     ~CRmo(void) { ArrayFree(m_array); ArrayFree(m_sort); return; }
    
      //
      //
      //

      bool init(int lowPassPeriod, int highPassPeriod, int medianPeriod)
      {
         m_lowPass_period  = (lowPassPeriod>1)  ? lowPassPeriod  : 1;
         m_highPass_period = (highPassPeriod>1) ? highPassPeriod : 1;
         m_median_period   = (medianPeriod>1)   ? medianPeriod   : 1;
         m_alpha1          = (MathCos(      2*M_PI/m_lowPass_period ) + MathSin(      2*M_PI/m_lowPass_period )-1.0)/MathCos(      2*M_PI/m_lowPass_period );
         m_alpha2          = (MathCos(0.707*2*M_PI/m_highPass_period) + MathSin(0.707*2*M_PI/m_highPass_period)-1.0)/MathCos(0.707*2*M_PI/m_highPass_period);
         m_1               = int(m_median_period/2.0);
         m_2               = (2*m_1==m_median_period) ? m_1-1 : m_1;
         
            //
            //---
            //
               
            m_arraySize = 32;
               if (ArrayResize(m_array,m_arraySize)!=m_arraySize)         return(false);
               if (ArrayResize(m_sort ,m_median_period)!=m_median_period) return(false);
                                                                          return(true);
      }
      
      double calculate(double& values[], int i) 
      {       
         int _indC = (i)%m_arraySize;
         if (i>2)
         {
            int _indP  = (i-1)%m_arraySize;
            int _indS  = (i-2)%m_arraySize;
            int _start = i-m_median_period+1; if (_start<0) _start=0;
               ArrayCopy(m_sort,values,0,_start,m_median_period);
               ArraySort(m_sort);

               m_array[_indC].rm  = m_alpha1*(m_sort[m_1]+m_sort[m_2])/2.0+(1-m_alpha1)*m_array[_indP].rm;
               m_array[_indC].rmo = (1-m_alpha2/2.0)*(1-m_alpha2/2.0)*(m_array[_indC].rm-2.0*m_array[_indP].rm+m_array[_indS].rm) + 2.0*(1-m_alpha2)*m_array[_indP].rmo-(1-m_alpha2)*(1-m_alpha2)*m_array[_indS].rmo;
         }
         else m_array[_indC].rm = m_array[_indC].rmo = 0;
         return(m_array[_indC].rmo);
      }
};
CRmo iRmo;