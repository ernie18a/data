//------------------------------------------------------------------------------------
//                                                            'PairsTrade_Light_v2.mq5'
//                             is a simpler version of the indicator 'Ind_2_Linep1.mq5'
//                                                         victorg, www.mql5.com, 2013
//------------------------------------------------------------------------------------
#property copyright   "Copyright 2013, Leonid Borsky ( leonid553 )."
#property link        "https://www.mql5.com/ru/users/leonid553"
#property version     "2.01"
#property description "This is a simpler version of the indicator 'Ind_2_Linep1.mq5'."
#property description "It can be used for a pairs trade, but the volume"
                      "of transactions is calculated only for Forex."
#property description "victorg, www.mql5.com, 2013."

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_color1  clrLime
#property indicator_width1  2
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_SOLID
#property indicator_color2  clrDodgerBlue
#property indicator_width2  2
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_style3  STYLE_SOLID
#property indicator_color3  clrRed,clrLightSeaGreen
#property indicator_width3  1

input string inpSymbol1_Name = "EURJPY";     //Main symbol
input bool   Symbol1_Reverse = false;        //Reverse correlation
input string inpSymbol2_Name = "USDJPY";     //Auxiliary symbol
input bool   Symbol2_Reverse = false;        //Reverse correlation
input bool   ATREnable       = true;         //Draw considering ATR
input int    inpEMA_Slow     = 42;           //Slow EMA period
input int    inpEMA_Fast     = 5;            //Fast 2xEМА period
input int    inpN_ATR        = 180;          //ATR period
input int    inpNumBars      = 5000;         //Drawing interval
input color  ColInf      = clrDarkSlateGray; //Color of "<" and "=" pointers
input color  ColInfAct   = clrDarkGoldenrod; //Colr of ">" pointer
input color  ColMode     = clrDarkGreen;     //Color of mode drawing
input color  ColWarning  = clrChocolate;     //Color of warnings
input color  ColLine     = clrDarkSlateGray; //Lines color

double Buf1[],Buf2[],Dif[],DifCol[];         // Indicator buffers for drawing
int    EMA_Slow,EMA_Fast,N_ATR,NumBars;
string Symbol1_Name,Symbol2_Name,ShortName,ObjName[];
//------------------------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------------------------
int OnInit(void)
  {
  int i,n;

  Symbol1_Name=inpSymbol1_Name;
  StringToUpper(Symbol1_Name);               // Convert the string to uppercase
  n=SymbolsTotal(false);            // Total number of available symbols in the terminal
  for(i=0;i<n;i++)if(SymbolName(i,false)==Symbol1_Name)break;
  if(i==n)                                   // If there is no such symbol
    {
    Alert("''"+Symbol1_Name,"'' - Incorrect symbol name!\n"+
                            "No such symbol in the general list.");
    return(INIT_PARAMETERS_INCORRECT);       // There is no the symbol in the general list 
    }
  Symbol2_Name=inpSymbol2_Name;
  StringToUpper(Symbol2_Name);               // Convert the string to uppercase
  for(i=0;i<n;i++)if(SymbolName(i,false)==Symbol2_Name)break;
  if(i==n)                                   // If there is no such symbol in the list
    {
    Alert("''"+Symbol2_Name,"'' - Incorrect symbol name!\n"+
                            "No such symbol in the general list.");
    return(INIT_PARAMETERS_INCORRECT);
    }
//-------  
  if(inpEMA_Slow<1)EMA_Slow=1;
  else EMA_Slow=inpEMA_Slow;                 // Slow EMA period
  if(inpEMA_Fast<1)EMA_Fast=1;
  else EMA_Fast=inpEMA_Fast;                 // Fast 2xEМА period
  if(inpN_ATR<1)N_ATR=1;
  else N_ATR=inpN_ATR;                       // ATR period
  if(inpNumBars<200)NumBars=200;
  else NumBars=inpNumBars;           // Indicator drawing interval (not less than 200) бар
//-------
  SetIndexBuffer(0,Buf1,INDICATOR_DATA);
  PlotIndexSetString(0,PLOT_LABEL,Symbol1_Name);
  PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
  SetIndexBuffer(1,Buf2,INDICATOR_DATA);
  PlotIndexSetString(1,PLOT_LABEL,Symbol2_Name);
  PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
  SetIndexBuffer(2,Dif,INDICATOR_DATA);
  PlotIndexSetString(2,PLOT_LABEL,"Dif");
  PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
  SetIndexBuffer(3,DifCol,INDICATOR_COLOR_INDEX);
  IndicatorSetInteger(INDICATOR_DIGITS,4);
//-------
  SymbolSelect(Symbol1_Name,true);   // Add used symbols in MarketWatch
  SymbolSelect(Symbol2_Name,true);   // Add used symbols in MarketWatch
//-------
  create_objects(ObjName);//Create objects and store their names in the ObjName[] array
  return(0);
  }
//------------------------------------------------------------------------------------
// Custom indicator deinitialization function
//------------------------------------------------------------------------------------
void OnDeinit(const int reason)
  {
  int i,n;
  
  GlobalVariableDel(ShortName);            // Delete the terminal global variable
  n=ArraySize(ObjName);                      // Number of created objects
  for(i=0;i<n;i++)ObjectDelete(0,ObjName[i]);// Delete objects
  return;
  }
//------------------------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------------------------
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
  int i,k,start;
  double a,b,tr1,tr2,pr1,pr2,kval,ratio;
  datetime tim;
  string str;
  MqlRates rat[2];               // Array to copy values of the selected symbol
  static int r1,r2;                          // Attribute of inverse relationship
  static double as,bs,af,bf,aa,ba;           // EMA smoothing ratio
  static double sy1_s,sy1_f,sy1_ff,sy1_atr;  // Smoothed values for the symbol 1
  static double sy2_s,sy2_f,sy2_ff,sy2_atr;  // Smoothed values for the symbol 2

  static double kpr1,c1,c2,val_enable=-1;

//-------
  a=volume_info(Symbol1_Name);               // The cost of one tick on the Symbol1
  b=volume_info(Symbol2_Name);               //  The cost of one tick on the Symbol2
  if(a>0&&b>0)kval=a/b;                      // Information about volumes is available
  else                                       // Information about volumes is not available
    {
    kval=-1;               // Is not the Forex or the data is not available. Volumes are not calculated
    if(val_enable!=0)                        // Volume information is not removed?
      {
      val_enable=0;                          // Save the state of volume availability
      str=Symbol1_Name;                      // Display without information of volumes
      if(Symbol1_Reverse==true)str+=" (rev)";
      ObjectSetString(0,ObjName[0],OBJPROP_TEXT,str);
      str=Symbol2_Name;
      if(Symbol2_Reverse==true)str+=" (rev)";
      ObjectSetString(0,ObjName[1],OBJPROP_TEXT,str);
      }
    }
//-------
  if(prev_calculated<=0)            // in case of a first call
    {
    if(rates_total<10+N_ATR+N_ATR+200)return(0); // Not enough bars on the chart
    start=rates_total-NumBars; if(start<10)start=10;
    val_enable=-1;                 // Flag of the state of volume information availability
    ArrayInitialize(Buf1,EMPTY_VALUE);       // Clear the indicator buffers
    ArrayInitialize(Buf2,EMPTY_VALUE);       // Clear the indicator buffers
    ArrayInitialize(Dif,EMPTY_VALUE);        // Clear the indicator buffers
    ArrayInitialize(DifCol,0);               // Clear the indicator buffers
    show_status("",0);                       // Clear the warning line
//-------
    as=2.0/(1+EMA_Slow); bs=1.0-as;          // Slow EMA coefficients
    af=2.0/(1+EMA_Fast); bf=1.0-af;          // Fast EMA coefficients
    aa=2.0/(1+N_ATR);    ba=1.0-aa;          // ATR smoothing coefficients
    c1=af*af-as; c2=af*bf;
//------- initialization of smoothed values
    tim=time[start];                         // Time of the chart start bar
    if(CopyRates(Symbol1_Name,_Period,tim,2,rat)<2) // Copy two values
      {
      show_status(Symbol1_Name);             // Show warning
      return(0);                  // Failed to copy the first symbol value
      }
    sy1_s=rat[1].close; sy1_f=sy1_s; sy1_ff=sy1_s;// Initialize the smoothed values
    sy1_atr=MathMax(rat[1].high,rat[0].close)-MathMin(rat[1].low,rat[0].close);
    if(CopyRates(Symbol2_Name,_Period,tim,2,rat)<2) // Copy two values
      {
      show_status(Symbol2_Name);             // Show warning
      return(0);                    // Failed to copy the second symbol value
      }
    sy2_s=rat[1].close; sy2_f=sy2_s; sy2_ff=sy2_s;// Initialize the smoothed values
    sy2_atr=MathMax(rat[1].high,rat[0].close)-MathMin(rat[1].low,rat[0].close);
//-------
    r1=1; r2=1;
    if(Symbol1_Reverse==true)r1=-1;// Change the sign to display the inverse relationship
    if(Symbol2_Reverse==true)r2=-1;// Change the sign to display the inverse relationship
    kpr1=100.0/sy1_s;                        // Total chart scale
    }
  else start=prev_calculated-1;              // if it's not the first run
//----------------- Main loop. Without incompleted bar.
  for(i=start;i<rates_total-1&&!IsStopped();i++)
    {
    tim=time[i];                             // Time of the current bar on the chart
    if(CopyRates(Symbol1_Name,_Period,tim,2,rat)<2) // Copy two values
      {
      show_status(Symbol1_Name);             // Show warning
      return(0);                  // Failed to copy the first symbol value
      }
    pr1=(rat[1].high+rat[1].low+rat[1].close+rat[1].close)/4.0; // HLCC/4
    tr1=MathMax(rat[1].high,rat[0].close)-MathMin(rat[1].low,rat[0].close); // TR
    sy1_s=as*pr1+bs*sy1_s;                   // Slow EMA
    sy1_f=af*pr1+bf*sy1_f;                   // Fast EMA
    sy1_ff=af*sy1_f+bf*sy1_ff;               // Repeated fast EMA from the previous
    sy1_atr=aa*tr1+ba*sy1_atr;               // ATR with using EMA
    if(CopyRates(Symbol2_Name,_Period,tim,2,rat)<2) // Copy two values
      {
      show_status(Symbol2_Name);             // Show warning
      return(0);                    // Failed to copy the second symbol value
      }
    pr2=(rat[1].high+rat[1].low+rat[1].close+rat[1].close)/4.0; // HLCC/4
    tr2=MathMax(rat[1].high,rat[0].close)-MathMin(rat[1].low,rat[0].close); // TR
    sy2_s=as*pr2+bs*sy2_s;                   // Slow EMA
    sy2_f=af*pr2+bf*sy2_f;                   // Fast EMA
    sy2_ff=af*sy2_f+bf*sy2_ff;               // Repeated fast EMA from the previous
    sy2_atr=aa*tr2+ba*sy2_atr;               // ATR with using EMA
//-------
    a=pr1/pr2;
    if(ATREnable==true&&sy2_atr>0)ratio=sy1_atr/sy2_atr; // Drawing considering the ATR
    else ratio=a;                            // Drawing excluding the ATR
//-------
    Buf1[i]=r1*kpr1*(sy1_ff-sy1_s);          // First symbol line
    Buf2[i]=r2*kpr1*(sy2_ff-sy2_s)*ratio;    // Second symbol line
    Dif[i]=Buf1[i]-Buf2[i];                  // Difference line
    if(MathAbs(Dif[i])<MathAbs(Dif[i-1]))DifCol[i]=0; // Color of difference line
    else DifCol[i]=1;
//-------
    if(i==rates_total-2)                     // For the last completed bar
      {
      k=rates_total-NumBars;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,k); // Beginning of drawing of the indicator lines
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,k); // Beginning of drawing of the indicator lines
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,k); // Beginning of drawing of the indicator lines
//------- Set the horizontal lines
      a=sy1_atr*kpr1;                     // Calculation of levels. ATR is used
      ObjectMove(0,ObjName[6],0,0,a);        // Set the level of first line
      ObjectMove(0,ObjName[7],0,0,-a);       // Set the level of second line
      }
    }
//----------------- Processing of last incompleted bar.
  i=rates_total-1;
  tim=time[i];                               // Time of the last bar on the chart
  if(CopyRates(Symbol1_Name,_Period,tim,2,rat)<2) // Copy two values
    {
    show_status(Symbol1_Name);               // Show warning
    return(0);                    // Failed to copy the first symbol value
    }
  pr1=(rat[1].high+rat[1].low+rat[1].close+rat[1].close)/4.0; // HLCC/4
  tr1=MathMax(rat[1].high,rat[0].close)-MathMin(rat[1].low,rat[0].close); // TR
  if(CopyRates(Symbol2_Name,_Period,tim,2,rat)<2) // Copy two values
    {
    show_status(Symbol2_Name);               // Show warning
    return(0);                      // Failed to copy the second symbol value
    }
  pr2=(rat[1].high+rat[1].low+rat[1].close+rat[1].close)/4.0; // HLCC/4
  tr2=MathMax(rat[1].high,rat[0].close)-MathMin(rat[1].low,rat[0].close); // TR
//-------
  a=pr1/pr2;
  if(kval>0&&val_enable!=1)  // If the volume information is appeared then display it
      {
      val_enable=1;                          // Save the state of volume availability
      str=Symbol1_Name+" 1.00";
      if(Symbol1_Reverse==true)str+=" (rev)";
      ObjectSetString(0,ObjName[0],OBJPROP_TEXT,str);
      str=Symbol2_Name+" "+DoubleToString(kval*a,2);
      if(Symbol2_Reverse==true)str+=" (rev)";
      ObjectSetString(0,ObjName[1],OBJPROP_TEXT,str);
      }
  if(ATREnable==true&&sy2_atr>0)ratio=sy1_atr/sy2_atr; // Drawing considering the ATR
  else ratio=a;                              // Drawing excluding the ATR
//-------
  Buf1[i]=r1*kpr1*(pr1*c1+sy1_f*c2+bf*sy1_ff-bs*sy1_s);      // First symbol line
  Buf2[i]=r2*kpr1*(pr2*c1+sy2_f*c2+bf*sy2_ff-bs*sy2_s)*ratio;// Second symbol line
  Dif[i]=Buf1[i]-Buf2[i];                                    // Difference line
  if(MathAbs(Dif[i])<MathAbs(Dif[i-1]))DifCol[i]=0;          // Color of difference line
  else DifCol[i]=1;
//------- display the state
//  if(MQL5InfoInteger(MQL5_OPTIMIZATION)) return(rates_total);
  if(DifCol[i]>0&&DifCol[i-1]>0)             // Symbols lines divergence
    {
    ObjectSetString(0,ObjName[2],OBJPROP_TEXT,"Divergence");
    ObjectSetInteger(0,ObjName[2],OBJPROP_COLOR,ColInf);
    ObjectSetString(0,ObjName[3],OBJPROP_TEXT,"<");
    ObjectSetInteger(0,ObjName[3],OBJPROP_COLOR,ColInf);
    }
  else if(DifCol[i]<1&&DifCol[i-1]<1)        // Symbol lines convergence
    {
    ObjectSetString(0,ObjName[2],OBJPROP_TEXT,"Convergence");
    ObjectSetInteger(0,ObjName[2],OBJPROP_COLOR,ColInfAct);
    ObjectSetString(0,ObjName[3],OBJPROP_TEXT,">");
    ObjectSetInteger(0,ObjName[3],OBJPROP_COLOR,ColInfAct);
    }
  else                                       // Undefined stateе
    {
    ObjectSetString(0,ObjName[2],OBJPROP_TEXT,"Flat");
    ObjectSetInteger(0,ObjName[2],OBJPROP_COLOR,ColInf);
    ObjectSetString(0,ObjName[3],OBJPROP_TEXT,"=");
    ObjectSetInteger(0,ObjName[3],OBJPROP_COLOR,ColInf);
    }
  return(rates_total);
  }
//------------------------------------------------------------------------------------
// Create objects and store their names in the onam[] array.
// Create and set an unique short name of the indicator,
// which used for creating objects names.
// Uses the global indicator variables: Symbol1_Name, Symbol1_Name and ShortName
//------------------------------------------------------------------------------------
void create_objects(string &onam[])
  {
  int i,x,y,wnum;
  string s,str;
  
  for(i=0;i<100;i++)               // Maximum number of simultaneously running indicators is 100
    {                              // (up to one hundred unique names on one chart)
    str="PaitsTradeL"+(string)i;   // Add the serial number to the base name
    if(GlobalVariableCheck(str)==false)
      {
      GlobalVariableTemp(str);     // Set the terminal global variable
      break;
      }
    }
  ShortName=str;
  IndicatorSetString(INDICATOR_SHORTNAME,str); // Set the indicator short name
  
  wnum=ChartWindowFind();          // Subwindow number in which the indicator is worked
  x=137;                           // Set the objects horizontal shift
  y=5;                             // Set the objects vertical shift
  i=8;                             // Set the number of created objects
  ArrayResize(onam,i);             // Array of objects names (i units)
  s="Name1"+ShortName;             // Objecte name
  onam[0]=s;                       // Save the name of the object in the names array
  if(ObjectFind(0,s)<0)ObjectCreate(0,s,OBJ_LABEL,wnum,0,0);
  ObjectSetInteger(0,s,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
  ObjectSetInteger(0,s,OBJPROP_XDISTANCE,x);
  ObjectSetInteger(0,s,OBJPROP_YDISTANCE,y);
  ObjectSetString(0,s,OBJPROP_FONT,"Verdana");
  ObjectSetInteger(0,s,OBJPROP_FONTSIZE,10);
  ObjectSetInteger(0,s,OBJPROP_COLOR,(color)PlotIndexGetInteger(0,PLOT_LINE_COLOR));
  str=Symbol1_Name; if(Symbol1_Reverse==true)str+=" (rev)";
  ObjectSetString(0,s,OBJPROP_TEXT,str);

  s="Name2"+ShortName;             // Objecte name
  onam[1]=s;                       // Save the name of the object in the names array
  if(ObjectFind(0,s)<0)ObjectCreate(0,s,OBJ_LABEL,wnum,0,0);
  ObjectSetInteger(0,s,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
  ObjectSetInteger(0,s,OBJPROP_XDISTANCE,x);
  ObjectSetInteger(0,s,OBJPROP_YDISTANCE,y+16);
  ObjectSetString(0,s,OBJPROP_FONT,"Verdana");
  ObjectSetInteger(0,s,OBJPROP_FONTSIZE,10);
  ObjectSetInteger(0,s,OBJPROP_COLOR,(color)PlotIndexGetInteger(1,PLOT_LINE_COLOR));
  str=Symbol2_Name; if(Symbol2_Reverse==true)str+=" (rev)";
  ObjectSetString(0,s,OBJPROP_TEXT,str);

  s="Info"+ShortName;              // Objecte name
  onam[2]=s;                       // Save the name of the object in the names array
  if(ObjectFind(0,s)<0)ObjectCreate(0,s,OBJ_LABEL,wnum,0,0);
  ObjectSetInteger(0,s,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
  ObjectSetInteger(0,s,OBJPROP_XDISTANCE,x);
  ObjectSetInteger(0,s,OBJPROP_YDISTANCE,y+32);
  ObjectSetString(0,s,OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,s,OBJPROP_FONTSIZE,10);
  ObjectSetInteger(0,s,OBJPROP_COLOR,ColInf);
  ObjectSetString(0,s,OBJPROP_TEXT," ");

  s="Triang"+ShortName;            // Objecte name
  onam[3]=s;                       // Save the name of the object in the names array
  if(ObjectFind(0,s)<0)ObjectCreate(0,s,OBJ_LABEL,wnum,0,0);
  ObjectSetInteger(0,s,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
  ObjectSetInteger(0,s,OBJPROP_XDISTANCE,x);
  ObjectSetInteger(0,s,OBJPROP_YDISTANCE,y+38);
  ObjectSetString(0,s,OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,s,OBJPROP_FONTSIZE,38);
  ObjectSetInteger(0,s,OBJPROP_COLOR,ColInf);
  ObjectSetString(0,s,OBJPROP_TEXT," ");
  
  s="Mode"+ShortName;              // Objecte name
  onam[4]=s;                       // Save the name of the object in the names array
  if(ObjectFind(0,s)<0)ObjectCreate(0,s,OBJ_LABEL,wnum,0,0);
  ObjectSetInteger(0,s,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
  ObjectSetInteger(0,s,OBJPROP_XDISTANCE,x);
  ObjectSetInteger(0,s,OBJPROP_YDISTANCE,y+84);
  ObjectSetString(0,s,OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,s,OBJPROP_FONTSIZE,8);
  ObjectSetInteger(0,s,OBJPROP_COLOR,ColMode);
  if(ATREnable==true)str="''The ATR mode enabled''"; // ATR values are considered
  else str=" ";                                      // Excluding the ATR values
  ObjectSetString(0,s,OBJPROP_TEXT,str);
  
  s="Warning"+ShortName;           // Objecte name
  onam[5]=s;                       // Save the name of the object in the names array
  if(ObjectFind(0,s)<0)ObjectCreate(0,s,OBJ_LABEL,wnum,0,0);
  ObjectSetInteger(0,s,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
  ObjectSetInteger(0,s,OBJPROP_XDISTANCE,x);
  ObjectSetInteger(0,s,OBJPROP_YDISTANCE,y+98);
  ObjectSetString(0,s,OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,s,OBJPROP_FONTSIZE,8);
  ObjectSetInteger(0,s,OBJPROP_COLOR,ColWarning);
  ObjectSetString(0,s,OBJPROP_TEXT," ");
  
  s="Line1"+ShortName;             // Objecte name
  onam[6]=s;                       // Save the name of the object in the names array
  ObjectCreate(0,s,OBJ_HLINE,wnum,0,0);
  ObjectSetInteger(0,s,OBJPROP_COLOR,ColLine);
  ObjectSetInteger(0,s,OBJPROP_WIDTH,1);
  ObjectSetInteger(0,s,OBJPROP_STYLE,STYLE_DOT);
  ObjectMove(0,s,0,0,0.1);
  
  s="Line2"+ShortName;             // Objecte name
  onam[7]=s;                       // Save the name of the object in the names array
  ObjectCreate(0,s,OBJ_HLINE,wnum,0,0);
  ObjectSetInteger(0,s,OBJPROP_COLOR,ColLine);
  ObjectSetInteger(0,s,OBJPROP_WIDTH,1);
  ObjectSetInteger(0,s,OBJPROP_STYLE,STYLE_DOT);
  ObjectMove(0,s,0,0,-0.1);
  
  ChartRedraw();
  }
//------------------------------------------------------------------------------------
// Returns the price of one tick. In case of failure or if not the 'Forex', returns zero.
// If the symbol is not in the 'Market Watch', the it is added there.
//------------------------------------------------------------------------------------
double volume_info(string symb)
  {
  long mode;
  double a,b;
  
  if(SymbolInfoInteger(symb,SYMBOL_TRADE_CALC_MODE,mode)==false)
    {
    SymbolSelect(symb,true);
    return(0);
    }
  if(mode!=SYMBOL_CALC_MODE_FOREX)return(0);
  if(SymbolInfoDouble(symb,SYMBOL_TRADE_TICK_VALUE,a)==false)
    {
    SymbolSelect(symb,true);
    return(0);
    }
  if(SymbolInfoDouble(symb,SYMBOL_TRADE_TICK_SIZE,b)==false)
    {
    SymbolSelect(symb,true);
    return(0);
    }
  if(a==0.0||b==0.0) return(0);
  return(a/b);
  }
//------------------------------------------------------------------------------------
// Display or delete a warning row.
// Uses the global variables of indicator: ObjName[]
//------------------------------------------------------------------------------------
void show_status(string s,int mod=1)
  {
  string str;
  
  if(mod<1)str=" ";                          // Clear the warning row
  else str="Wait data from '"+s+"'";         // Waiting for "str" symbol data
  ObjectSetString(0,ObjName[5],OBJPROP_TEXT,str);
  return;
  }
//------------------------------------------------------------------------------------