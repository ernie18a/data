//+------------------------------------------------------------------+
//|                                                    i_Sampler.mq5 |
//|                                        Copyright 2012, her.human |
//|                                              her.human@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, her.human"
#property link      "her.human@gmail.com"
#property version   "1.00"

#property indicator_separate_window
#property indicator_minimum -1
#property indicator_maximum 1
#property indicator_buffers 3
#property indicator_plots   2
//--- plot analog
#property indicator_label1  "analog"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSpringGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot discrete
#property indicator_label2  "discrete"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrDeepSkyBlue,clrCoral
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input int      bars_future=10;
input int      max_bars=10000;
input int      discrete_metod=1;
input double   porog=0.5;
input int      tp=500;
input int      sl=200;
input bool     show_arrow=true;
input bool     save_file=false;
//--- indicator buffers
double         analogBuffer[];
double         discreteBuffer[];
double         discreteColors[];
//--- global variable
double point;
string name;
int timesignal[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,analogBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,discreteBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,discreteColors,INDICATOR_COLOR_INDEX);

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Bars(_Symbol,_Period)-max_bars);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,Bars(_Symbol,_Period)-max_bars);

   point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   name=MQL5InfoString(MQL5_PROGRAM_NAME);

   return(0);
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
   int i;
   int start=MathMax(rates_total-max_bars,prev_calculated);
   for(i=start; i<rates_total-bars_future; i++)
     {
      analogBuffer[i+bars_future]=EMPTY_VALUE;
      discreteBuffer[i+bars_future]=EMPTY_VALUE;

      //--- calculation of analog buffer 0     
      //--- highest price (bars_future bars forward)
      double price_high=high[ArrayMaximum(high,i,bars_future)];
      //--- lowest price (bars_future bars forward)
      double price_low=low[ArrayMinimum(low,i,bars_future)];

      //--- positive price change, relative to 0th bar
      double deviation_plus=price_high-open[i];
      //--- negative price change, relative to 0th bar
      double deviation_minus=open[i]-price_low;

      double value=(2.0*deviation_plus)/(deviation_plus+deviation_minus)-1;
      analogBuffer[i]=value;

      //--- calculation of discrete buffer 1
      switch(discrete_metod)
        {
         case 1:
         if(value>porog) { discreteBuffer[i]=1; discreteColors[i]=0; }
         else if(value<-porog) { discreteBuffer[i]=-1; discreteColors[i]=1; }
         else { discreteBuffer[i]=0; }
         break;
         case 2:
            if(deviation_plus>tp*point && deviation_minus<sl*point)
              { discreteBuffer[i]=1; discreteColors[i]=0;}
            else if(deviation_plus<sl*point && deviation_minus>tp*point)
              { discreteBuffer[i]=-1; discreteColors[i]=1;}
            else { discreteBuffer[i]=0; }
            break;
        }
      //--- рисуем стрелки
      if(show_arrow) SetArrow(discreteBuffer[i],time[i],open[i]);

      //--- записываем время сигналов в файл      
      if(save_file && i==rates_total-bars_future-1) SaveBuffer(rates_total,time,discreteBuffer);
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete arrows
   NameObjectDelete(name);
  }
//+------------------------------------------------------------------+
//| SetArrow                                                         |
//+------------------------------------------------------------------+
void SetArrow(double signal,datetime timebar,double price)
  {
   if(signal==0) return;
   string name_arrow;
   if(signal>0)
     {
      StringConcatenate(name_arrow,name," Buy "," ",timebar);
      ObjectCreate(0,name_arrow,OBJ_ARROW_BUY,0,timebar,price);
     }
   if(signal<0)
     {
      StringConcatenate(name_arrow,name," Buy "," ",timebar);
      ObjectCreate(0,name_arrow,OBJ_ARROW_SELL,0,timebar,price);
     }
  }
//+------------------------------------------------------------------+
//| Delete object by name                                            |
//+------------------------------------------------------------------+
void NameObjectDelete(string namedelet)
  {
   int totalobject=ObjectsTotal(0,0,-1);
   for(int i=totalobject-1; i>=0; i--)
     {
      string nameobj=ObjectName(0,i,0,-1);
      if(StringFind(nameobj,namedelet)>=0)
        {
         ObjectDelete(0,nameobj);
        }
     }
  }
//+------------------------------------------------------------------+
//| Save signals to file                                             |
//+------------------------------------------------------------------+
void SaveBuffer(const int rates_total,const datetime &time[],const double &Buffer[])
  {
   uint n=0,ne;
   for(int i=0; i<rates_total; i++) { if(Buffer[i]==1 || Buffer[i]==-1) n++; }
   ArrayResize(timesignal,n);
   n=0;
   for(int i=0; i<rates_total; i++)
     {
      if(Buffer[i]==1 || Buffer[i]==-1) { timesignal[n]=(int)time[i]*(int)Buffer[i]; n++; }
     }

   ResetLastError();
   string namefile;
   StringConcatenate(namefile,_Symbol,"_Sampler.BIN");
   int filehandle=FileOpen(namefile,FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(filehandle!=INVALID_HANDLE)
     {
      ne=FileWriteArray(filehandle,timesignal,0,WHOLE_ARRAY);
      FileClose(filehandle);
      //      Print(namefile," FileWrite OK. The number of elements - ",ne);
     }
   else Print(namefile," FileWrite failed, error ",GetLastError());
  }
//--------------------------------------------------------------------+
