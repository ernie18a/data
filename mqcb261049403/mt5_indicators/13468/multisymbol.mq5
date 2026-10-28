//+------------------------------------------------------------------+
//|                                                  MultiSymbol.mq5 |
//|                                          Copyright 2018, pipPod. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright  "Copyright 2018, pipPod."
#property link       "https://www.mql5.com/en/users/pippod"
#property description"Multi Symbol"
#property version    "1.10"
#property strict
#property indicator_separate_window
#property indicator_buffers 20            //Inc/dec by factor 5
#property indicator_plots   4             
//---
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrRoyalBlue,clrLimeGreen,clrFireBrick
//---
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrSilver,clrLimeGreen,clrFireBrick
//---
#property indicator_type3   DRAW_COLOR_CANDLES
#property indicator_color3  clrLimeGreen,clrFireBrick,clrYellow
//---
#property indicator_type4   DRAW_COLOR_CANDLES
#property indicator_color4  clrLimeGreen,clrYellow,clrFireBrick
//---
//+------------------------------------------------------------------+
//| Class for indicator and index buffers                            |
//+------------------------------------------------------------------+
class CSymbol
  {
private:
   int               m_handle;
   //---             buffers
   double            m_open[];
   double            m_high[];
   double            m_low[];
   double            m_close[];
   double            m_color[];
public:
   //---             constructor
                     CSymbol(void):m_handle(INVALID_HANDLE) {  this.ArraySetAsSeries(true); }
   //---             destructor
                    ~CSymbol(void) { IndicatorRelease(m_handle); }
   //---             indicator handle
   int               Handle(int handle) {  return(m_handle=handle);   }
   //---             copy symbol/indicator data
   int               CopyBuffer(const int start,const int count)
     {
      int copied;
      if((copied=::CopyBuffer(m_handle,0,start,count,m_open))<1 ||
         (copied=::CopyBuffer(m_handle,1,start,count,m_high))<1 ||
         (copied=::CopyBuffer(m_handle,2,start,count,m_low))<1 ||
         (copied=::CopyBuffer(m_handle,3,start,count,m_close))<1 ||
         (copied=::CopyBuffer(m_handle,4,start,count,m_color))<1)
         return(-1);
      return(copied);
     }
   //---             previously calculated bars
   int               BarsCalculated(void) {  return(BarsCalculated(m_handle));   }
   //---             assign index buffers
   bool              SetIndexBuffer(int index)
     {
      return(SetIndexBuffer(index,m_open) &&
             SetIndexBuffer(index+1,m_high) && 
             SetIndexBuffer(index+2,m_low) && 
             SetIndexBuffer(index+3,m_close) && 
             SetIndexBuffer(index+4,m_color,INDICATOR_COLOR_INDEX));
     }
   //---             index buffer series flag
   bool              ArraySetAsSeries(bool flag)
     {
      return(ArraySetAsSeries(m_open,flag) &&
             ArraySetAsSeries(m_high,flag) && 
             ArraySetAsSeries(m_low,flag) && 
             ArraySetAsSeries(m_close,flag) && 
             ArraySetAsSeries(m_color,flag));
     }
   //---             initialize index buffers 
   bool              ArrayInitialize(double value)
     {
      return(ArrayInitialize(m_open,value) &&
             ArrayInitialize(m_high,value) && 
             ArrayInitialize(m_low,value) && 
             ArrayInitialize(m_close,value) && 
             ArrayInitialize(m_color,value));
     }
   //---             detach index buffers
   void              ArrayFree(void)
     {
      ArrayFree(m_open);
      ArrayFree(m_high);
      ArrayFree(m_low);
      ArrayFree(m_close);
      ArrayFree(m_color);
     }
  };
//+------------------------------------------------------------------+
//| Symbols to display                                               |
//+------------------------------------------------------------------+
input string Symbol1="EURUSD";   //Symbol 1         
input string Symbol2="GBPUSD";   //Symbol 2      
input string Symbol3="USDCHF";   //Symbol 3         
input string Symbol4="USDJPY";   //Symbol 4      
//--- indicator and index objects                            
CSymbol *symbol[indicator_plots];
//--- chart properties
long chartID;
short window;
int toCopy;
//--- symbols for indicators
string Symbol[indicator_plots];
//int Handle[indicator_plots];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetInteger(0,INDICATOR_DIGITS,4);
   chartID=ChartID();
//--- set indicator symbols
   Symbol[0]=Symbol1;
   Symbol[1]=Symbol2;
   Symbol[2]=Symbol3;
   Symbol[3]=Symbol4;
   for(int i=0;i<indicator_plots;i++)
     {
      if(!SymbolSelect(Symbol[i],true))
        {
         Alert(Symbol[i]," not available in Market Watch.\nInitialization Failed.");
         return(INIT_FAILED);
        }
      PlotIndexSetString(i,PLOT_LABEL,Symbol[i]+" Open;"+Symbol[i]+" High;"+Symbol[i]+" Low;"+Symbol[i]+" Close;");
      //--- set indicator handlers
      if(!CheckPointer(symbol[i]=new CSymbol) || 
         symbol[i].Handle(::iCustom(Symbol[i],PERIOD_CURRENT,"PercentChange.ex5",chartID,i))==INVALID_HANDLE/* ||
        (Handle[i]=iCustom(Symbol[i],PERIOD_CURRENT,"OnTick.ex5",chartID,i))==INVALID_HANDLE/*/)
         return(INIT_FAILED);
     }
//--- set name & create labels
   string shortName="Multi Symbol";
   IndicatorSetString(INDICATOR_SHORTNAME,shortName);
   window=(short)ChartWindowFind(chartID,shortName);
   CreateLabels();
//--- indicator buffers mapping and series flag
   for(int i=0,buf_num=0;i<indicator_plots;i++,buf_num+=5)
      symbol[i].SetIndexBuffer(buf_num);
//--- index buffers show data flag
   for(int i=0;i<indicator_buffers;i++)
     { 
      //PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
      PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,EMPTY_VALUE);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   int limit=rates_total-prev_calculated;
//--- set initial bars to count and get bars/indicator calculated
   if(rates_total!=prev_calculated)
     {
      int barsWindow=(int)ChartGetInteger(chartID,CHART_VISIBLE_BARS)+20;
      if(rates_total<barsWindow)
         return(0);
      for(int a=0;a<indicator_plots;a++)
         if(!CheckPointer(symbol[a]) || symbol[a].BarsCalculated()<barsWindow)
            return(0);
      for(int a=0;a<indicator_plots;a++)
         symbol[a].ArrayInitialize(EMPTY_VALUE);
      /*int drawBegin=rates_total-barsWindow;
      for(int i=0;i<indicator_buffers;i++)
         PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,drawBegin);*/
      limit=barsWindow-1;
     }
   else
      return(rates_total);
   toCopy=limit+1;
//--- fill indicator buffers and assign to index buffers
   for(int a=0;a<indicator_plots;a++)
      if(OnTick(a,toCopy)<1)
         return(0);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete labels
   ObjectsDeleteAll(chartID,window,OBJ_LABEL);
//--- release indicator handlers
   for(int a=0;a<indicator_plots;a++)
      if(CheckPointer(symbol[a]))
         delete symbol[a];
//symbol[a].ArrayFree();
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnTick(int index,int to_copy)
  {
//--- check pointer and copy data
   if(!CheckPointer(symbol[index]))
      return(-1);
   return(symbol[index].CopyBuffer(0,to_copy));
//---
  }
//+------------------------------------------------------------------+
//| On chart event function                                          |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID 
                  const long& lparam,   // Parameter of type long event 
                  const double& dparam, // Parameter of type double event 
                  const string& sparam) // Parameter of type string events 
  {
//--- check for incoming ticks
   if(id>=CHARTEVENT_CUSTOM)
      OnTick((int)lparam,(bool)dparam?toCopy:1);
//---
  }
//+-------------------------------------------------------------------+
//| Create coloured symbol labels                                     |
//+-------------------------------------------------------------------+
void CreateLabels()
  {
//---names to show
   string Label[indicator_plots*2];
   color  Color[indicator_plots*2]={clrNONE};
   for(int i=0,j=0,k=1;i<indicator_plots;i++,j+=2,k+=2)
     {
      Label[j]=StringSubstr(Symbol[i],0,3);  //Base currency name
      Color[j]=(color)PlotIndexGetInteger(i,PLOT_LINE_COLOR,0);
      Label[k]=StringSubstr(Symbol[i],3,3);  //Quote currency name
      Color[k]=(color)PlotIndexGetInteger(i,PLOT_LINE_COLOR,1);
     }
//--- x coordinates
   int xStart=4,xStart2=26;
   int xIncrement=0;
//--- y coordinates
   int yStart=16;
   int yIncrement=16;
//--- create all labels
   for(int i=0,k=1;k<indicator_plots*2;i+=2,k+=2)
     {
      string name1=string(window+i);
      string name2=string(window+k);
      ObjectCreate(name1,Label[i],xStart,yStart,Color[i]);
      ObjectCreate(name2,Label[k],xStart2,yStart,Color[k]);
      xStart+=xIncrement;
      yStart+=yIncrement;
     }
  }
//+------------------------------------------------------------------+
//| Create label objects at coordinates                              |
//+------------------------------------------------------------------+
void ObjectCreate(string name,string label,int x,int y,int clr)
  {
   ObjectCreate(chartID,name,OBJ_LABEL,window,0,0);
   ObjectSetString(chartID,name,OBJPROP_TEXT,label);
   ObjectSetString(chartID,name,OBJPROP_FONT,"Arial Bold");
   ObjectSetInteger(chartID,name,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(chartID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chartID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartID,name,OBJPROP_YDISTANCE,y);
  }
//+------------------------------------------------------------------+
