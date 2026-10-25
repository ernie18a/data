//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Rocket RSI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//---
//

enum enCalcMode
{
   calc_fisher  = 0, // Calculate fisher transform of "rocket" rsi
   calc_regular = 1  // Calculate "rocket" rsi only
};
enum enColorMode
{
   col_onSlope,  // Color change on slope change
   col_onZero,   // Color change on zero cross
   col_onLevels  // Color change on levels cross
};
input int                inpPeriod    = 10;           // Period
input int                inpSmooth    = 10;           // Smoothing
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE;  // Price
input double             inpLevel     = 2;            // Levels (will be used as +- level)
input enColorMode        inpColorMode = col_onLevels; // Color change mode
input enCalcMode         inpCalcMode  = calc_fisher;  // Calculating mode

//
//---
//

double val[],valc[]; string ª_names[] = {"Fisher transform of ",""};
int  ª_smoothPeriod,ª_rsiPeriod; 

//------------------------------------------------------------------ 
//  Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
            ª_smoothPeriod = (inpSmooth>0) ? inpSmooth : 1;
            ª_rsiPeriod    = (inpPeriod>0) ? inpPeriod : 1;
            IndicatorSetInteger(INDICATOR_LEVELS,2);
               IndicatorSetDouble(INDICATOR_LEVELVALUE,0, inpLevel);
               IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-inpLevel);
   //            
   //----
   //
   IndicatorSetString(INDICATOR_SHORTNAME,ª_names[inpCalcMode]+"Rocket RSI ("+(string)ª_rsiPeriod+","+(string)ª_smoothPeriod+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_where,_index) { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _where = close[_index];                                              break; \
      case PRICE_OPEN:     _where = open[_index];                                               break; \
      case PRICE_HIGH:     _where = high[_index];                                               break; \
      case PRICE_LOW:      _where = low[_index];                                                break; \
      case PRICE_MEDIAN:   _where = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _where = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _where = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _where = 0; \
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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      val[i] = iRocketRsi(_price,ª_rsiPeriod,ª_smoothPeriod,inpCalcMode,i,rates_total);
      switch (inpColorMode)
      {
         case col_onSlope :  valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1]: 0 ; break;
         case col_onZero  :  valc[i] = (val[i]>0) ? 1 : (val[i]<0) ? 2 : 0;                                   break;
         default :           valc[i] = (val[i]>inpLevel) ? 1 : (val[i]<-inpLevel) ? 2 : 0;
      }
   }
   return(i);
}

//------------------------------------------------------------------
//  Custom function(s)
//------------------------------------------------------------------
//
//---
//

double iRocketRsi(double price, int period, double smooth, int mode, int i, int bars, int instance=0)
{
   #define ¤ instance
   #define _functionInstances 1

      //
      //---
      //
      
      struct sRocketRsiCoeffs
      {
         int    initKey;
         double originalPeriod;
         double period;
         double coeff1;
         double coeff2;
         double coeff3;
      };
      struct sRocketRsiStruct
      {
         double price;
         double momentum;
         double filter;
         double diffp;
         double diffn;
         double sump;
         double sumn;
      };
      static sRocketRsiCoeffs m_coeffs[_functionInstances];
      static sRocketRsiStruct m_array[][_functionInstances];
      static int              m_arraySize=0;
         if (m_arraySize<bars)
         {
            int _res = ArrayResize(m_array,bars+500);
            if (_res<bars) return(0);
                        m_arraySize = _res;
         }
         if (m_coeffs[¤].originalPeriod!=smooth || m_coeffs[¤].initKey!=-99)
         {
            m_coeffs[¤].initKey        = -99;
            m_coeffs[¤].originalPeriod =  smooth;
            m_coeffs[¤].period         = (smooth>1) ? smooth : 1;
         
               //
               //---
               //
            
                  double a = MathExp(-1.414*M_PI/m_coeffs[¤].period);
            
               //
               //---
               //
            
            m_coeffs[¤].coeff2 = 2*a*MathCos(1.414*M_PI/m_coeffs[¤].period);;
            m_coeffs[¤].coeff3 = -a*a;
            m_coeffs[¤].coeff1 = 1-m_coeffs[¤].coeff2-m_coeffs[¤].coeff3;      
         }

   //
   //---
   //

      m_array[i][¤].price = price;
      if (i>period)
      {
         m_array[i][¤].momentum = m_array[i][¤].price-m_array[i-period+1][¤].price;
         m_array[i][¤].filter   = m_coeffs[¤].coeff1*((m_array[i][¤].momentum+m_array[i-1][¤].momentum)/2.0)+m_coeffs[¤].coeff2*m_array[i-1][¤].filter+m_coeffs[¤].coeff3*m_array[i-2][¤].filter;
         m_array[i][¤].diffp    = (m_array[i][¤].filter>m_array[i-1][¤].filter) ? m_array[i][¤].filter-m_array[i-1][¤].filter : 0;
         m_array[i][¤].diffn    = (m_array[i][¤].filter<m_array[i-1][¤].filter) ? m_array[i-1][¤].filter-m_array[i][¤].filter : 0;
         m_array[i][¤].sump     =  m_array[i-1][¤].sump+m_array[i][¤].diffp-m_array[i-period][¤].diffp;
         m_array[i][¤].sumn     =  m_array[i-1][¤].sumn+m_array[i][¤].diffn-m_array[i-period][¤].diffn;
      }
      else
      {
         m_array[i][¤].momentum = m_array[i][¤].price-m_array[0][¤].price;
         m_array[i][¤].filter   = (i>1) ? m_coeffs[¤].coeff1*((m_array[i][¤].momentum+m_array[i-1][¤].momentum)/2)+m_coeffs[¤].coeff2*m_array[i-1][¤].filter+m_coeffs[¤].coeff3*m_array[i-2][¤].filter : m_array[i][¤].momentum;
         m_array[i][¤].diffp    = (i>0) ? (m_array[i][¤].filter>m_array[i-1][¤].filter) ? m_array[i][¤].filter-m_array[i-1][¤].filter : 0 : 0;
         m_array[i][¤].diffn    = (i>0) ? (m_array[i][¤].filter<m_array[i-1][¤].filter) ? m_array[i-1][¤].filter-m_array[i][¤].filter : 0 : 0;
         m_array[i][¤].sump     = m_array[i][¤].diffp;
         m_array[i][¤].sumn     = m_array[i][¤].diffn;
         for (int k=1; k<period && i>=k; k++)
         {
            m_array[i][¤].sump += m_array[i-k][¤].diffp;
            m_array[i][¤].sumn += m_array[i-k][¤].diffn;
         }
      }

   //
   //---
   //
   
      double denom = m_array[i][¤].sump+m_array[i][¤].sumn;
      double rsi   = (denom!=0) ? (m_array[i][¤].sump-m_array[i][¤].sumn)/denom : 0;
      if (mode==0)
      {
         if (rsi >  0.999) rsi =  0.999;
         if (rsi < -0.999) rsi = -0.999;

         return(0.5*MathLog((1+rsi)/(1-rsi)));
      }         
      else return(rsi);
}
//------------------------------------------------------------------