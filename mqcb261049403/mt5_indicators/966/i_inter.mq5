//+------------------------------------------------------------------+
//|                                                      i_inter.mq5 |
//|                                        Copyright 2012, her.human |
//|                                              her.human@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, her.human"
#property link      "her.human@gmail.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   10

//--- plot in0
#property indicator_label10  "in0"
#property indicator_type10   DRAW_LINE
#property indicator_color10  clrDarkViolet
#property indicator_style10  STYLE_SOLID
#property indicator_width10  1
//--- plot in1
#property indicator_label1  "in1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot in2
#property indicator_label2  "in2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot in3
#property indicator_label3  "in3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrYellow
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot in4
#property indicator_label4  "in4"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot in5
#property indicator_label5  "in5"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrLime
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot in6
#property indicator_label6  "in6"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrLightBlue
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot in7
#property indicator_label7  "in7"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrBlue
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot in8
#property indicator_label8  "in8"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrViolet
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot in9
#property indicator_label9  "in9"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrFuchsia
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum variant
  {
   NONE,
   HLP,
   Op0_OpN,
   RSI,
   Stoch,
   Op0_Ma,
   Ma0_Ma1,
   Time
  };
enum instrument { CURRENT,EURUSD,GBPUSD,USDCHF,USDJPY,USDCAD,AUDUSD,NZDUSD,EURGBP,EURJPY,EURCAD,XAUUSD,XAGUSD };
//--- input parameters - buffer 0 ---------
input instrument      symbol0=EURUSD;		//----- Instrument 1 ------
input variant         var0=HLP;				//Variant 1
input ENUM_TIMEFRAMES tf0=PERIOD_CURRENT;	//Timeframe 1
input int             param0=5;				//Parametr 1
//--- input parameters - buffer 1 ---------
input instrument      symbol1=GBPUSD;		//----- Instrument 2 ------
input variant         var1=HLP;				//Variant 2
input ENUM_TIMEFRAMES tf1=PERIOD_CURRENT;	//Timeframe 2
input int             param1=5;				//Parametr 2
//--- input parameters - buffer 2 ---------
input instrument      symbol2=EURUSD;		//----- Instrument 3 ------
input variant         var2=HLP;				//Variant 3
input ENUM_TIMEFRAMES tf2=PERIOD_CURRENT;	//Timeframe 3
input int             param2=20;				//Parametr 3
//--- input parameters - buffer 3 ---------
input instrument      symbol3=GBPUSD;		//----- Instrument 4 ------
input variant         var3=HLP;				//Variant 4
input ENUM_TIMEFRAMES tf3=PERIOD_CURRENT;	//Timeframe 4
input int             param3=20;				//Parametr 4
//--- input parameters - buffer 4 ---------
input instrument      symbol4=EURUSD;		//----- Instrument 5 ------
input variant         var4=HLP;				//Variant 5
input ENUM_TIMEFRAMES tf4=PERIOD_CURRENT;	//Timeframe 5
input int             param4=50;				//Parametr 5
//--- input parameters - buffer 5 ---------
input instrument      symbol5=GBPUSD;		//----- Instrument 6 ------
input variant         var5=HLP;				//Variant 6
input ENUM_TIMEFRAMES tf5=PERIOD_CURRENT;	//Timeframe 6
input int             param5=50;				//Parametr 6
//--- input parameters - buffer 6 ---------
input instrument      symbol6=EURUSD;		//----- Instrument 7 ------
input variant         var6=NONE;				//Variant 7
input ENUM_TIMEFRAMES tf6=PERIOD_CURRENT;	//Timeframe 7
input int             param6=20;				//Parametr 7
//--- input parameters - buffer 7 ---------
input instrument      symbol7=GBPUSD;		//----- Instrument 8 ------
input variant         var7=NONE;				//Variant 8
input ENUM_TIMEFRAMES tf7=PERIOD_CURRENT;	//Timeframe 8
input int             param7=20;				//Parametr 8
//--- input parameters - buffer 8 ---------
input instrument      symbol8=CURRENT;		//----- Instrument 9 ------
input variant         var8=Time;				//Variant 9
input ENUM_TIMEFRAMES tf8=PERIOD_CURRENT;	//Timeframe 9
input int             param8=0;				//Parametr 9
//--- input parameters - buffer 9 ---------
input instrument      symbol9=CURRENT;		//----- Instrument 10 ------
input variant         var9=Time;				//Variant 10
input ENUM_TIMEFRAMES tf9=PERIOD_CURRENT;	//Timeframe 10
input int             param9=1;				//Parametr 10
//--- input other parameters --------------
input int             max_bars=100;       //Maximum Bars Calculate

//--- indicator buffers
double in0Buffer[];
double in1Buffer[];
double in2Buffer[];
double in3Buffer[];
double in4Buffer[];
double in5Buffer[];
double in6Buffer[];
double in7Buffer[];
double in8Buffer[];
double in9Buffer[];
//--- global variable
int 	 handle[10];
double h[],l[],c[];
double rsi[];
double stoch[];
double ma[];
double knorm[10];
double temp;
double point;
string name;
int 	 begin;
double value;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,in0Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,in1Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,in2Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,in3Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,in4Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,in5Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,in6Buffer,INDICATOR_DATA);
   SetIndexBuffer(7,in7Buffer,INDICATOR_DATA);
   SetIndexBuffer(8,in8Buffer,INDICATOR_DATA);
   SetIndexBuffer(9,in9Buffer,INDICATOR_DATA);
   
   SetBegin();
   
   PlotIndexSetString(0,PLOT_LABEL,EnumToString(symbol0)+" in0-"+EnumToString(var0)+" "+EnumToString(tf0));
   PlotIndexSetString(1,PLOT_LABEL,EnumToString(symbol1)+" in1-"+EnumToString(var1)+" "+EnumToString(tf1));
   PlotIndexSetString(2,PLOT_LABEL,EnumToString(symbol2)+" in2-"+EnumToString(var2)+" "+EnumToString(tf2));
   PlotIndexSetString(3,PLOT_LABEL,EnumToString(symbol3)+" in3-"+EnumToString(var3)+" "+EnumToString(tf3));
   PlotIndexSetString(4,PLOT_LABEL,EnumToString(symbol4)+" in4-"+EnumToString(var4)+" "+EnumToString(tf4));
   PlotIndexSetString(5,PLOT_LABEL,EnumToString(symbol5)+" in5-"+EnumToString(var5)+" "+EnumToString(tf5));
   PlotIndexSetString(6,PLOT_LABEL,EnumToString(symbol6)+" in6-"+EnumToString(var6)+" "+EnumToString(tf6));
   PlotIndexSetString(7,PLOT_LABEL,EnumToString(symbol7)+" in7-"+EnumToString(var7)+" "+EnumToString(tf7));
   PlotIndexSetString(8,PLOT_LABEL,EnumToString(symbol8)+" in8-"+EnumToString(var8)+" "+EnumToString(tf8));
   PlotIndexSetString(9,PLOT_LABEL,EnumToString(symbol9)+" in9-"+EnumToString(var9)+" "+EnumToString(tf9));

   IndicatorSetString(INDICATOR_SHORTNAME,"Inter");
   point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   name=MQL5InfoString(MQL5_PROGRAM_NAME);

   ArraySetAsSeries(h,true);
   ArraySetAsSeries(l,true);
   ArraySetAsSeries(c,true);
   ArraySetAsSeries(rsi,true);
   ArraySetAsSeries(ma,true);
   ArrayInitialize(handle,INVALID_HANDLE);
   ArrayInitialize(knorm,0.0000001);
   datetime time=TimeLocal();

   if(!SymbolInfoInteger(EnumToString(symbol0),SYMBOL_SELECT)) SymbolSelect(EnumToString(symbol0),true);
   if(!SymbolInfoInteger(EnumToString(symbol1),SYMBOL_SELECT)) SymbolSelect(EnumToString(symbol1),true);
   if(!SymbolInfoInteger(EnumToString(symbol2),SYMBOL_SELECT)) SymbolSelect(EnumToString(symbol2),true);
   if(!SymbolInfoInteger(EnumToString(symbol3),SYMBOL_SELECT)) SymbolSelect(EnumToString(symbol3),true);
   if(!SymbolInfoInteger(EnumToString(symbol4),SYMBOL_SELECT)) SymbolSelect(EnumToString(symbol4),true);
   if(!SymbolInfoInteger(EnumToString(symbol5),SYMBOL_SELECT)) SymbolSelect(EnumToString(symbol5),true);
   if(!SymbolInfoInteger(EnumToString(symbol6),SYMBOL_SELECT)) SymbolSelect(EnumToString(symbol6),true);
   if(!SymbolInfoInteger(EnumToString(symbol7),SYMBOL_SELECT)) SymbolSelect(EnumToString(symbol7),true);
   if(!SymbolInfoInteger(EnumToString(symbol8),SYMBOL_SELECT)) SymbolSelect(EnumToString(symbol8),true);
   if(!SymbolInfoInteger(EnumToString(symbol9),SYMBOL_SELECT)) SymbolSelect(EnumToString(symbol9),true);
   
   if(var0!=NONE) temp=fmetod(0,EnumToString(symbol0),tf0,var0,time,param0);
   if(var1!=NONE) temp=fmetod(1,EnumToString(symbol1),tf1,var1,time,param1);
   if(var2!=NONE) temp=fmetod(2,EnumToString(symbol2),tf2,var2,time,param2);
   if(var3!=NONE) temp=fmetod(3,EnumToString(symbol3),tf3,var3,time,param3);
   if(var4!=NONE) temp=fmetod(4,EnumToString(symbol4),tf4,var4,time,param4);
   if(var5!=NONE) temp=fmetod(5,EnumToString(symbol5),tf5,var5,time,param5);
   if(var6!=NONE) temp=fmetod(6,EnumToString(symbol6),tf6,var6,time,param6);
   if(var7!=NONE) temp=fmetod(7,EnumToString(symbol7),tf7,var7,time,param7);
   if(var8!=NONE) temp=fmetod(8,EnumToString(symbol8),tf8,var8,time,param8);
   if(var9!=NONE) temp=fmetod(9,EnumToString(symbol9),tf9,var9,time,param9);

//---
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=0; i<10; i++)
     {
      if(handle[i]>=0) IndicatorRelease(handle[i]);
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
   int i;
   bool error=false;
   string symerror="";
   ResetLastError();
   SetBegin();
   int start=MathMax(begin,prev_calculated-1);
   for(i=start; i<rates_total; i++)
     {
         if(var0!=NONE)
           {
            in0Buffer[i]=fmetod(0,EnumToString(symbol0),tf0,var0,time[i],param0);
            if(in0Buffer[i]==EMPTY_VALUE) { error=true; symerror=EnumToString(symbol0); }
           }
         else in0Buffer[i]=EMPTY_VALUE;  
         
         if(var1!=NONE)
           {
            in1Buffer[i]=fmetod(1,EnumToString(symbol1),tf1,var1,time[i],param1);
            if(in1Buffer[i]==EMPTY_VALUE) { error=true; symerror=EnumToString(symbol1); }
           }
         else in1Buffer[i]=EMPTY_VALUE;  
         
         if(var2!=NONE)
           {
            in2Buffer[i]=fmetod(2,EnumToString(symbol2),tf2,var2,time[i],param2);
            if(in2Buffer[i]==EMPTY_VALUE) { error=true; symerror=EnumToString(symbol2); }
           }
         else in2Buffer[i]=EMPTY_VALUE;  
         
         if(var3!=NONE)
           {
            in3Buffer[i]=fmetod(3,EnumToString(symbol3),tf3,var3,time[i],param3);
            if(in3Buffer[i]==EMPTY_VALUE) { error=true; symerror=EnumToString(symbol3); }
           }
         else in3Buffer[i]=EMPTY_VALUE;  
         
         if(var4!=NONE)
           {
            in4Buffer[i]=fmetod(4,EnumToString(symbol4),tf4,var4,time[i],param4);
            if(in4Buffer[i]==EMPTY_VALUE) { error=true; symerror=EnumToString(symbol4); }
           }
         else in4Buffer[i]=EMPTY_VALUE;  
         
         if(var5!=NONE)
           {
            in5Buffer[i]=fmetod(5,EnumToString(symbol5),tf5,var5,time[i],param5);
            if(in5Buffer[i]==EMPTY_VALUE) { error=true; symerror=EnumToString(symbol5); }
           }
         else in5Buffer[i]=EMPTY_VALUE;  
         
         if(var6!=NONE)
           {
            in6Buffer[i]=fmetod(6,EnumToString(symbol6),tf6,var6,time[i],param6);
            if(in6Buffer[i]==EMPTY_VALUE) { error=true; symerror=EnumToString(symbol6); }
           }
         else in6Buffer[i]=EMPTY_VALUE;  
         
         if(var7!=NONE)
           {
            in7Buffer[i]=fmetod(7,EnumToString(symbol7),tf7,var7,time[i],param7);
            if(in7Buffer[i]==EMPTY_VALUE) { error=true; symerror=EnumToString(symbol7); }
           }
         else in7Buffer[i]=EMPTY_VALUE;  
         
         if(var8!=NONE)
           {
            in8Buffer[i]=fmetod(8,EnumToString(symbol8),tf8,var8,time[i],param8);
            if(in8Buffer[i]==EMPTY_VALUE) { error=true; symerror=EnumToString(symbol8); }
           }
         else in8Buffer[i]=EMPTY_VALUE;  
         
         if(var9!=NONE)
           {
            in9Buffer[i]=fmetod(9,EnumToString(symbol9),tf9,var9,time[i],param9);
            if(in9Buffer[i]==EMPTY_VALUE) { error=true; symerror=EnumToString(symbol9); }
           }
         else in9Buffer[i]=EMPTY_VALUE;  
         
     }
//--- return value of prev_calculated for next call
   if(error) return(start);
   return(rates_total);
  }
//+------------------------------------------------------------------+
double fmetod(uchar n,string symbol=NULL,ENUM_TIMEFRAMES tf=PERIOD_CURRENT,variant var=NONE,datetime starttime=0,int param=10)
  {
   switch(var)
     {
      case HLP: 		value=fHLP(n,symbol,tf,starttime,param); 			break;
      case Op0_OpN: 	value=fOp0_OpN(n,symbol, tf, starttime, param); break;
      case RSI: 		value=fRSI(n,symbol, tf, starttime, param); 		break;
      case Stoch: 	value=fStoch(n,symbol,tf,starttime,param); 		break;
      case Op0_Ma: 	value=fOp0_Ma(n,symbol, tf, starttime, param); 	break;
      case Ma0_Ma1: 	value=fMa0_Ma1(n,symbol, tf, starttime, param);	break;
      case Time: 		value=fTimeDay(starttime,param); 					break;
      default: 		value=0.0; 													break;
     }
   return(value);
  }
//+------------------------------------------------------------------+
double fHLP(uchar n,string symbol=NULL,ENUM_TIMEFRAMES tf=PERIOD_CURRENT,datetime starttime=0,int param=10)
  {
   if(symbol=="CURRENT") symbol=_Symbol;

   if(CopyClose(symbol,tf,starttime,param,c)<param) return(EMPTY_VALUE);
   if(CopyLow(symbol,tf,starttime,param,l)<param) return(EMPTY_VALUE);
   if(CopyHigh(symbol,tf,starttime,param,h)<param) return(EMPTY_VALUE);
   
   double deviation_minus=h[ArrayMaximum(h,0,param)]-c[0];
   double deviation_plus=c[0]-l[ArrayMinimum(l,0,param)];

   value=(2.0*deviation_plus)/(deviation_plus+deviation_minus+0.000001)-1;
   return(value);
  }
//+------------------------------------------------------------------+
double fOp0_OpN(uchar n,string symbol=NULL,ENUM_TIMEFRAMES tf=PERIOD_CURRENT,datetime starttime=0,int param=10)
  {
   if(symbol=="CURRENT") symbol=_Symbol;
   if(CopyOpen(symbol,tf,starttime,param,c)<param) return(EMPTY_VALUE);
   double val=c[0]-c[param-1];
   knorm[n]=MathMax(MathAbs(val),knorm[n]);
   return(val/knorm[n]);
  }
//+------------------------------------------------------------------+
double fRSI(uchar n,string symbol=NULL,ENUM_TIMEFRAMES tf=PERIOD_CURRENT,datetime starttime=0,int param=10)
  {
   if(symbol=="CURRENT") symbol=_Symbol;
   if(handle[n]<0)
     {
      handle[n]=iRSI(symbol,tf,param,PRICE_CLOSE);
      if(handle[n]==INVALID_HANDLE) Print("Creat Handle Error RSI ",GetLastError());
      return(EMPTY_VALUE);
     }
   if(CopyBuffer(handle[n],0,starttime,1,rsi)<1) return(EMPTY_VALUE);
   return((rsi[0]-50.0)/50.0);
  }
//+------------------------------------------------------------------+
double fStoch(uchar n,string symbol=NULL,ENUM_TIMEFRAMES tf=PERIOD_CURRENT,datetime starttime=0,int param=10)
  {
   if(symbol=="CURRENT") symbol=_Symbol;
   if(handle[n]<0)
     {
      handle[n]=iStochastic(symbol,tf,param,3,3,MODE_SMMA,STO_LOWHIGH);
      if(handle[n]==INVALID_HANDLE) Print("Creat Handle Error iStochastic ",GetLastError());
      return(EMPTY_VALUE);
     }
   if(CopyBuffer(handle[n],0,starttime,1,stoch)<1) return(EMPTY_VALUE);
   return((stoch[0]-50.0)/50.0);
  }
//+------------------------------------------------------------------+
double fOp0_Ma(uchar n,string symbol=NULL,ENUM_TIMEFRAMES tf=PERIOD_CURRENT,datetime starttime=0,int param=10)
  {
   if(symbol=="CURRENT") symbol=_Symbol;
   if(handle[n]<0)
     {
      handle[n]=iMA(symbol,tf,param,0,MODE_SMA,PRICE_CLOSE);
      if(handle[n]==INVALID_HANDLE) Print("Creat Handle Error iMA ",GetLastError());
      return(EMPTY_VALUE);
     }
   if(CopyBuffer(handle[n],0,starttime,1,ma)<1) return(EMPTY_VALUE);
   if(CopyOpen(symbol,tf,starttime,1,c)<1) return(EMPTY_VALUE);
   double val=c[0]-ma[0];
   knorm[n]=MathMax(MathAbs(val),knorm[n]);
   return(val/knorm[n]);
  }
//+------------------------------------------------------------------+
double fMa0_Ma1(uchar n,string symbol=NULL,ENUM_TIMEFRAMES tf=PERIOD_CURRENT,datetime starttime=0,int param=10)
  {
   if(symbol=="CURRENT") symbol=_Symbol;
   if(handle[n]<0)
     {
      handle[n]=iMA(symbol,tf,param,0,MODE_SMA,PRICE_CLOSE);
      if(handle[n]==INVALID_HANDLE) Print("Creat Handle Error iMA ",GetLastError());
      return(EMPTY_VALUE);
     }
   if(CopyBuffer(handle[n],0,starttime,2,ma)<2) return(EMPTY_VALUE);
   double val=ma[0]-ma[1];
   knorm[n]=MathMax(MathAbs(val),knorm[n]);
   return(val/knorm[n]);
  }
//+------------------------------------------------------------------+
double fTimeDay(datetime starttime,int param)
  {
   double val;
   MqlDateTime dt;
   TimeToStruct(starttime,dt);
   if(param==0) val=1.0-MathAbs((dt.hour*60+dt.min-720)/720.0);
   if(param>0)
     {
      if(dt.hour<12) val=-1.0;
      else val=1.0;
     }
   return(val);
  }
//+------------------------------------------------------------------+
void SetBegin()
  {
   begin=MathMax(100,Bars(_Symbol,_Period)-max_bars);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(9,PLOT_DRAW_BEGIN,begin);
  }
//+------------------------------------------------------------------+

