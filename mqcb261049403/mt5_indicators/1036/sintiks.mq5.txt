#property copyright "LoopXor"
#property link      "Skype: Loopxor for communication" 
#property description ""
#property description "Signals:"
#property description "Mode 0 = MathSin(tick_volume[i])"
#property description "Mode 1 = MathSin(tick_volume[i-1])"


#property indicator_separate_window        //show the indicator in a separate window 
#property indicator_buffers 2
#property indicator_plots 2

//Signal type
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_type2 DRAW_LINE

//the color for the signal
#property indicator_color1 Red
#property indicator_color2 Orange
               
// line style
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID

// width
#property indicator_width1 2
#property indicator_width2 2

string    indName="0";                     // Indicator Name
//---- buffers
double ExtMapBuffer0[];
double ExtMapBuffer1[];


//--- input parameters
//min bars needed to calculate the indicator
input int Min_Bars= 80; 

//Indicator inputs



// indicator handles

//Constants
#define SYMBOL_THUMBSDOWN 68
#define SYMBOL_THUMBSUP 67
#define SYMBOL_ARROWDOWN 242
#define SYMBOL_ARROWUP 241
#define SYMBOL_STOPSIGN 251
#define SYMBOL_CHECKSIGN 252


int OnInit()
  {
//---- indicators setup


SetIndexBuffer(0,ExtMapBuffer0,INDICATOR_DATA);

SetIndexBuffer(1,ExtMapBuffer1,INDICATOR_DATA);


// Arrows


//--- set accuracy
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits+1);   
	
	Print("",indName,"");  
    Print("",indName," starts running at: Server Time=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)," Terminal Time=",TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS)); 
    Comment("THIS INDICATOR IS MADE: LoopXor ");
   //----
   return(0);
  } 

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Print("M-",_Symbol," Custom Indicator deinit");
   Print(__FUNCTION__,"_Uninitalization reason code =",reason);

   Print(__FUNCTION__,"_UninitReason =",getUnitReasonText(_UninitReason));

   Comment("");	
   
 //Indicator Release
//----
   
  }
  

int OnCalculate (const int rates_total,      // size of input timeseries
                 const int prev_calculated,  // bars handled in previous call
                 const datetime& time[],     // Time
                 const double& open[],       // Open
                 const double& high[],       // High
                 const double& low[],        // Low
                 const double& close[],      // Close
                 const long& tick_volume[],  // Tick Volume
                 const long& volume[],       // Real Volume
                 const int& spread[]         // Spread
   )                      
  {

   if(rates_total<Min_Bars) {
   	  Print("Indicator Warning: A minimum of ",Min_Bars," is required to show the Indicator.");
      return(0);
   }
   int limit;
   
   limit = prev_calculated; 
   if (prev_calculated < Min_Bars) 
      limit = Min_Bars;
   if (prev_calculated == rates_total) 
       limit = rates_total -1; 
   
//--- main loop
double sum=0; //For average calculation if any

for(int i=limit;i<rates_total;i++) {
   	  //Calculations;
      ExtMapBuffer0[i]=MathSin(tick_volume[i]);

ExtMapBuffer1[i]=MathSin(tick_volume[i-1]);

  
      	
   }   
 
     
//--------------------------------------------------------------------
   
   //--- return value of prev_calculated for next call
   return(rates_total);
                             
  }
//--------------------------------------------------------------------

//Additional functions
string getUnitReasonText(int reasonCode)
  {
   string text="";

   switch(reasonCode)
     {
      case REASON_ACCOUNT:
         text="Account was changed";break;
      case REASON_CHARTCHANGE:
         text="Symbol or timeframe was changed";break;
      case REASON_CHARTCLOSE:
         text="Chart was closed";break;
      case REASON_PARAMETERS:
         text="Input-parameter was changed";break;
      case REASON_RECOMPILE:
         text="Program "+__FILE__+" was recompiled";break;
      case REASON_REMOVE:
         text="Program "+__FILE__+" was removed from chart";break;
      case REASON_TEMPLATE:
         text="New template was applied to chart";break;
      default:text="Unknow reason";
     }

   return text;
  }