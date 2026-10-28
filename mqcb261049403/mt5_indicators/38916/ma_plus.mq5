#property copyright    "Alexandr Sokolov"
#property link         "https://www.mql5.com/en/users/asokolov7"
#property version      "1.00"

#property indicator_chart_window
#property indicator_buffers  18
#property indicator_plots    1

#property indicator_type1   DRAW_COLOR_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_color1  clrLime, clrRed


//-------------------------------------------------------------------------------------------------
//   Indicator arrays                                                                             |
//-------------------------------------------------------------------------------------------------
double  MA[],        //Main array
        MA_color[],  //Array to store color index
        v_open[],    //Array to store virtual price open
        v_high[],    //Array to store virtual price high
        v_low[],     //Array to store virtual price low
        Price[],     //Array to store prices
        OEMA[],      //auxiliary arrays ...
        DEMA[],
        TEMA[],
        H_FV[],
        H_DV[],
        Hull_Value[],
        H_OEMA[],
        H_DEMA[],
        H_TEMA[],
        H_OEMA2[],
        H_DEMA2[],
        H_TEMA2[];


//-------------------------------------------------------------------------------------------------
//   Global variables                                                                             |
//-------------------------------------------------------------------------------------------------
typedef bool ( *Calculation )( const int, const int );
Calculation  calculation;  //Calculation type


//--- Averaging methods ---------------------------------------------
enum METHODS
  {
   MODE_SIMPLE,              //Simple
   MODE_EXPONENTIAL,         //Exponential
   MODE_DOUBLE_EXPONENTIAL,  //Double Exponential
   MODE_TRIPLE_EXPONENTIAL,  //Triple Exponential
   MODE_SMOOTHED,            //Smoothed
   MODE_LINEAR_WEIGHTED      //Linear Weighted
  };

//--- "on/off" ------------------------------------------------------
enum UNU
  {
   u,  //Use
   nu  //Not use
  };

//--- Input parameters ----------------------------------------------
input uint                ma_period   = 25;                //Period
input METHODS             ma_method   = MODE_EXPONENTIAL;  //Method
input ENUM_APPLIED_PRICE  ma_ap       = PRICE_CLOSE;       //Applied price
input UNU                 ma_hm       = u;                 //Hull method
input int                 ma_shift    = 0;                 //Shift
input UNU                 vb          = nu;                //Virtual bars
input uint                vb_period   = 3;                 //Period of virtual bars


//-------------------------------------------------------------------------------------------------
//   Initialization                                                                               |
//-------------------------------------------------------------------------------------------------
int OnInit()
  {
   
  //--- 0.0) Validation of input parameters
   if( ma_period == 0 )
     {
      Print("Period error - it must be greater than 0");
      return INIT_FAILED;
     };
   
   if( vb == u && vb_period < 2 )
     Print("Virtual bars are not formed - their period must be greater than 1");
   
  //--- 0.1) Getting the calculation type
   if( ma_hm == u )
     calculation = Hull;
   else
     calculation = Simple;
   
  //--- 0.2) Nuances
   string label = ( ma_hm == u ? "Hull MA " : "MA " );
   
   switch( ma_method )
     {
      case MODE_SIMPLE:              label += "Si";  break;
      case MODE_EXPONENTIAL:         label += "E";   break;
      case MODE_DOUBLE_EXPONENTIAL:  label += "DE";  break;
      case MODE_TRIPLE_EXPONENTIAL:  label += "TE";  break;
      case MODE_SMOOTHED:            label += "Sm";  break;
      default:                       label += "LW";  break;
     };
   
   label += " P" + (string)ma_period + " AP";
   
   switch(ma_ap)
     {
      case PRICE_CLOSE:    label += "C"; break;
      case PRICE_HIGH:     label += "H"; break;
      case PRICE_LOW:      label += "L"; break;
      case PRICE_OPEN:     label += "O"; break;
      case PRICE_MEDIAN:   label += "M"; break;
      case PRICE_TYPICAL:  label += "T"; break;
      default:             label += "W"; break;
     };
   
   label += " Sh" + (string)ma_shift;
   if( vb == u ) label += " PoVB" + (string)vb_period;
   
   PlotIndexSetInteger( 0, PLOT_SHIFT, ma_shift );
   PlotIndexSetString( 0, PLOT_LABEL, label );
   IndicatorSetInteger( INDICATOR_DIGITS, _Digits );
   
  //--- 0.3) Array types
   SetIndexBuffer( 0, MA, INDICATOR_DATA );                SetIndexBuffer( 1, MA_color, INDICATOR_COLOR_INDEX );
   SetIndexBuffer( 2, v_open, INDICATOR_CALCULATIONS );    SetIndexBuffer( 3, v_high, INDICATOR_CALCULATIONS );
   SetIndexBuffer( 4, v_low, INDICATOR_CALCULATIONS );     SetIndexBuffer( 5, Price, INDICATOR_CALCULATIONS );
   SetIndexBuffer( 6, OEMA, INDICATOR_CALCULATIONS );      SetIndexBuffer( 7, DEMA, INDICATOR_CALCULATIONS );
   SetIndexBuffer( 8, TEMA, INDICATOR_CALCULATIONS );      SetIndexBuffer( 9, H_FV, INDICATOR_CALCULATIONS );
   SetIndexBuffer( 10, H_DV, INDICATOR_CALCULATIONS );     SetIndexBuffer( 11, Hull_Value, INDICATOR_CALCULATIONS );
   SetIndexBuffer( 12, H_OEMA, INDICATOR_CALCULATIONS );   SetIndexBuffer( 13, H_DEMA, INDICATOR_CALCULATIONS );
   SetIndexBuffer( 14, H_TEMA, INDICATOR_CALCULATIONS );   SetIndexBuffer( 15, H_OEMA2, INDICATOR_CALCULATIONS );
   SetIndexBuffer( 16, H_DEMA2, INDICATOR_CALCULATIONS );  SetIndexBuffer( 17, H_TEMA2, INDICATOR_CALCULATIONS );
   
  //--- 0.4) Setting the direction of array indexing
   ArraySetAsSeries( MA, true );       ArraySetAsSeries( MA_color, true );
   ArraySetAsSeries( v_open, true );   ArraySetAsSeries( v_high, true );
   ArraySetAsSeries( v_low, true );    ArraySetAsSeries( Price, true );
   ArraySetAsSeries( OEMA, true );     ArraySetAsSeries( DEMA, true );
   ArraySetAsSeries( TEMA, true );     ArraySetAsSeries( H_FV, true );
   ArraySetAsSeries( H_DV, true );     ArraySetAsSeries( Hull_Value, true );
   ArraySetAsSeries( H_OEMA, true );   ArraySetAsSeries( H_DEMA, true );
   ArraySetAsSeries( H_TEMA, true );   ArraySetAsSeries( H_OEMA2, true );
   ArraySetAsSeries( H_DEMA2, true );  ArraySetAsSeries( H_TEMA2, true );
   
  //-----------------------------------------------------------------
   return(INIT_SUCCEEDED);
  }


//-------------------------------------------------------------------------------------------------
//   Tick handler                                                                                 |
//-------------------------------------------------------------------------------------------------
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime  &time[],
                const double    &open[],
                const double    &high[],
                const double    &low[],
                const double    &close[],
                const long      &tick_volume[],
                const long      &volume[],
                const int       &spread[])
  {
   
  //--- 1.0) Changing the indexing direction of standard arrays
   ArraySetAsSeries( open, true );  ArraySetAsSeries( high, true );
   ArraySetAsSeries( low, true );   ArraySetAsSeries( close, true );
   
  //--- 1.1) First initialization of indicator arrays
   if( prev_calculated == 0 )
     {
      ArrayInitialize( MA, EMPTY_VALUE );       ArrayInitialize( MA_color, EMPTY_VALUE );
      ArrayInitialize( v_open, EMPTY_VALUE );   ArrayInitialize( v_high, EMPTY_VALUE );
      ArrayInitialize( v_low, EMPTY_VALUE );    ArrayInitialize( Price, EMPTY_VALUE );
      ArrayInitialize( OEMA, EMPTY_VALUE );     ArrayInitialize( DEMA, EMPTY_VALUE );
      ArrayInitialize( TEMA, EMPTY_VALUE );     ArrayInitialize( H_FV, EMPTY_VALUE );
      ArrayInitialize( H_DV, EMPTY_VALUE );     ArrayInitialize( Hull_Value, EMPTY_VALUE );
      ArrayInitialize( H_OEMA, EMPTY_VALUE );   ArrayInitialize( H_DEMA, EMPTY_VALUE );
      ArrayInitialize( H_TEMA, EMPTY_VALUE );   ArrayInitialize( H_OEMA2, EMPTY_VALUE );
      ArrayInitialize( H_DEMA2, EMPTY_VALUE );  ArrayInitialize( H_TEMA2, EMPTY_VALUE );
     };
   
  //--- 1.2) Getting prices of virtual bars
   if( vb == u && vb_period > 1 && vb_period <= (uint)rates_total )
     {
      int limit = rates_total - prev_calculated - (int)vb_period;
        if( limit < 0 ) limit = 0;
      
      for( int a = limit; a >= 0; a-- )
        {
         
         v_open[a]  = open[ a + (int)vb_period - 1 ];
         v_high[a]  = low[a];
         v_low[a]   = high[a];
         
         for( int b = a + (int)vb_period - 1; b >= a; b-- )
           {
            if( high[b] > v_high[a] )  v_high[a]  = high[b];
            if( low[b] < v_low[a] )    v_low[a]   = low[b];
           };
         
        };
     }
   else if( vb == u && vb_period > (uint)rates_total )
     {
      PrintFormat("Period of virtual bars exceeds the number of available bars - %u (Current period of virtual bars - %u)",rates_total,vb_period);
      return 0;
     };
   
  //--- 1.3) Getting a price
   int limit = rates_total - prev_calculated - 1;
     if( vb == u && vb_period > 1 ) limit -= (int)vb_period + 1;
     if( limit < 0 ) limit = 0;
   
   for( int i = limit; i >= 0; i-- )
     {
      if( vb == u && vb_period > 1 )
        Price[i] = GetPrice( i, v_open, v_high, v_low, close );
      else
        Price[i] = GetPrice( i, open, high, low, close );
     };
   
  //--- 1.4) Indicator calculation
   bool result;
   
   if( vb == u && vb_period > 1 )
     result = calculation( rates_total, prev_calculated );
   else
     result = calculation( rates_total, prev_calculated );
   
  //-----------------------------------------------------------------
   return result ? rates_total : 0;
  }


//-------------------------------------------------------------------------------------------------
//   Get price                                                                                    |
//-------------------------------------------------------------------------------------------------
double GetPrice(const int     index,
                const double  &open[],
                const double  &high[],
                const double  &low[],
                const double  &close[])
  {
   
  //--- 1.3.1
   switch( ma_ap )
     {
      case PRICE_OPEN:      return( open[index] );
      case PRICE_HIGH:      return( high[index] );
      case PRICE_LOW:       return( low[index] );
      case PRICE_MEDIAN:    return( ( high[index] + low[index] ) / 2.0 );
      case PRICE_TYPICAL:   return( ( high[index] + low[index] + close[index] ) / 3.0 );
      case PRICE_WEIGHTED:  return( ( high[index] + low[index] + close[index] + close[index] ) / 4.0 );
     };
   
  //-----------------------------------------------------------------
   return( close[index] );
  }


//-------------------------------------------------------------------------------------------------
//   Simple                                                                                       |
//-------------------------------------------------------------------------------------------------
bool Simple(const int     rates_total,
            const int     prev_calculated)
  {
   
  //--- 1.4.1 (or Hull)
   int limit = rates_total - prev_calculated - 1;
     
     switch( ma_method )
       {
        case MODE_DOUBLE_EXPONENTIAL:  limit -= (int)ma_period * 2 - 2;  break;
        case MODE_TRIPLE_EXPONENTIAL:  limit -= (int)ma_period * 4 - 4;  break;
        default:                       limit -= (int)ma_period - 1;      break;
       };
   
     if( vb == u && vb_period > 1 ) limit -= (int)vb_period - 1;
   
     if( prev_calculated == 0 && limit < 0 )
       {
        Print("The current averaging period does not allow the indicator to be calculated due to an insufficient number of bars");
        return false;
       };
   
     if( limit < 0 ) limit = 0;
   
   for( int i = limit; i >= 0; i-- )
     {
      Averaging( i, ma_method, ma_period, Price, MA, OEMA, DEMA, TEMA );
      MA_color[i] = ( MA[ i + 1 ] == EMPTY_VALUE ? 0 : ( MA[i] >= MA[ i + 1 ] ? 0 : 1 ) );
     };
   
  //-----------------------------------------------------------------
   return true;
  }


//-------------------------------------------------------------------------------------------------
//   Hull                                                                                         |
//-------------------------------------------------------------------------------------------------
bool Hull(const int     rates_total,
          const int     prev_calculated)
  {
   
  //--- 1.4.1 (or Simple)
   int limit = rates_total - prev_calculated - 1;
     
     switch( ma_method )
       {
        case MODE_DOUBLE_EXPONENTIAL:  limit -= (int)ma_period * 2 - 2;  break;
        case MODE_TRIPLE_EXPONENTIAL:  limit -= (int)ma_period * 4 - 4;  break;
        default:                       limit -= (int)ma_period - 1;      break;
       };
   
     if( vb == u && vb_period > 1 ) limit -= (int)vb_period - 1;
     
     if( prev_calculated == 0 && limit < 0 )
       {
        Print("The current averaging period does not allow the indicator to be calculated due to an insufficient number of bars");
        return false;
       };
   
     if( limit < 0 ) limit = 0;
   
   int period_d  = (int)MathFloor( (double)( ma_period > 1 ? ma_period : 1.0 ) / 2.0 ),
       period_r  = (int)MathFloor( MathSqrt( (double)( ma_period > 1 ? ma_period : 1.0 ) ) );
       if( period_d < 1 ) period_d = 1;
       if( period_r < 1 ) period_r = 1;
   
   int hull_limit = limit;
     
     switch( ma_method )
         {
          case MODE_DOUBLE_EXPONENTIAL: hull_limit -= period_r * 2 - 2;  break;
          case MODE_TRIPLE_EXPONENTIAL: hull_limit -= period_r * 4 - 4;  break;
          default:                      hull_limit -= period_r - 1;      break;
         };
     
     if( prev_calculated == 0 && hull_limit < 0 )
       {
        Print("The current averaging period does not allow the indicator to be calculated due to an insufficient number of bars");
        return false;
       };
     
     if( hull_limit < 0 ) hull_limit = 0;
   
   for( int i = limit; i >= 0; i-- )
     {
      
      Averaging( i, ma_method, ma_period, Price, H_FV, OEMA, DEMA, TEMA );
      Averaging( i, ma_method, period_d, Price, H_DV, H_OEMA, H_DEMA, H_TEMA );
      Hull_Value[i] = 2.0 * H_DV[i] - H_FV[i];
      
      if( i <= hull_limit )
        {
         if( period_r > 1 )
           Averaging( i, ma_method, period_r, Hull_Value, MA, H_OEMA2, H_DEMA2, H_TEMA2 );
         else
           MA[i] = Hull_Value[i];
         MA_color[i] = ( MA[ i + 1 ] == EMPTY_VALUE ? 0 : ( MA[i] >= MA[ i + 1 ] ? 0 : 1 ) );
        };
      
     };
   
  //-----------------------------------------------------------------
   return true;
  }


//-------------------------------------------------------------------------------------------------
//   Averaging                                                                                    |
//-------------------------------------------------------------------------------------------------
void Averaging(const int      index,
               const METHODS  method,
               const int      period,
               const double   &values_from[],
                     double   &value_to[],
                     double   &oe[],
                     double   &de[],
                     double   &te[])
  {
   
  //--- 1.4.1.1
   double  sum        = 0.0,
           coef;
   int     limit,
           lw_period  = period,
           lw_sum     = 0;
   
  //--- simple averaging
   if( method == MODE_SIMPLE )
     {
      limit = index + period;
      for( int i = index; i < limit; i++ )
        sum += values_from[i];
      value_to[index] = sum / (double)period;
     }
   
  //--- exponential averaging
   else if( method == MODE_EXPONENTIAL )
     {
      if( value_to[ index + 1 ] == EMPTY_VALUE )
        {
         Averaging( index, MODE_SIMPLE, period, values_from, value_to, oe, de, te );
         return;
        };
      coef = 2.0 / (double)( period + 1 );
      value_to[index] = coef * values_from[index] + (1.0 - coef) * value_to[ index + 1 ];
     }
   
  //--- double exponential averaging
   else if( method == MODE_DOUBLE_EXPONENTIAL )
     {
      if( oe[ index + 1 ] == EMPTY_VALUE )
        {
         limit = index + period;
         for( int i = limit - 1; i >= index; i-- )
           Averaging( i, MODE_EXPONENTIAL, period, values_from, oe, oe, de, te );
        }
      else
        Averaging( index, MODE_EXPONENTIAL, period, values_from, oe, oe, de, te );
      
      Averaging( index, MODE_EXPONENTIAL, period, oe, de, oe, de, te );
      
      value_to[index] = 2.0 * oe[index] - de[index];
     }
   
  //--- triple exponential averaging
   else if( method == MODE_TRIPLE_EXPONENTIAL )
     {
      int o_start = index + period * 2 - 2;
      if( oe[ o_start + 1 ] == EMPTY_VALUE )
        {
         limit = o_start + period - 1;
         for( int i = limit; i >= index; i-- )
           Averaging( i, MODE_EXPONENTIAL, period, values_from, oe, oe, de, te );
        }
      else
        Averaging( index, MODE_EXPONENTIAL, period, values_from, oe, oe, de, te );
      
      int d_start = index + period - 1;
      if( de[ d_start + 1 ] == EMPTY_VALUE )
        {
         limit = d_start + period - 1;
         for( int i = limit; i >= index; i-- )
           Averaging( i, MODE_EXPONENTIAL, period, oe, de, oe, de, te );
        }
      else
        Averaging( index, MODE_EXPONENTIAL, period, oe, de, oe, de, te );
      
      Averaging( index, MODE_EXPONENTIAL, period, de, te, oe, de, te );
      
      value_to[index] = 3.0 * oe[index] - 3.0 * de[index] + te[index];
     }
   
  //--- smoothed averaging
   else if( method == MODE_SMOOTHED )
     {
      if( value_to[ index + 1 ] == EMPTY_VALUE )
        {
         Averaging( index, MODE_SIMPLE, period, values_from, value_to, oe, de, te );
         return;
        }
      else if( value_to[ index + 1 ] != EMPTY_VALUE && value_to[ index + 2 ] == EMPTY_VALUE )
        {
         limit = index + period;
         for( int i = index; i < limit; i++ )
           sum += values_from[i];
         value_to[index] = ( sum - value_to[ index + 1 ] + values_from[index] ) / (double)period;
         return;
        };
      sum = value_to[ index + 1 ] * (double)period;
      value_to[index] = ( sum - value_to[ index + 1 ] + values_from[index] ) / (double)period;
     }
   
  //--- linearly weighted averaging
   else
     {
      limit = index + period;
      for( int i = index; i < limit; i++ )
        {
         sum += values_from[i] * (double)lw_period;
         lw_sum += lw_period; lw_period--;
        };
      value_to[index] = sum / (double)lw_sum;
     };
   
  }