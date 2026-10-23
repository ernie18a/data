//+------------------------------------------------------------------+
//|                                            CoensioTrader1V06.mqh |
//|                                                          Coensio |
//|                                           http://www.Coensio.com |
//|                                                                  |
//| This library contains a collection of freely available MQL4/MQL5 |
//| functions from many different sources                            |      
//+------------------------------------------------------------------+

//Web connection functions
#import "wininet.dll"
int InternetAttemptConnect(int x);
int InternetOpenW(string sAgent,int lAccessType,
                  string sProxyName="",string sProxyBypass="",
                  int lFlags=0);
int InternetOpenUrlW(int hInternetSession,string sUrl,
                     string sHeaders="",int lHeadersLength=0,
                     int lFlags=0,int lContext=0);
int InternetReadFile(int hFile,uchar &sBuffer[],int lNumBytesToRead,
                     int &lNumberOfBytesRead[]);
int HttpQueryInfoW(int hRequest,int dwInfoLevel,
                   uchar &lpvBuffer[],int &lpdwBufferLength,int &lpdwIndex);
int InternetCloseHandle(int hInet);
#import
#define HTTP_QUERY_CONTENT_LENGTH      5
#define FLAG_PRAGMA_NOCACHE            0x00000100  //No cashing of the page
#define FLAG_RELOAD                    0x80000000  //Receive the page from the server when accessing it

//Declaration of constants
#define OP_BUY 0           //Buy 
#define OP_SELL 1          //Sell
#define OP_BUYLIMIT 2      //BUY LIMIT pending order 
#define OP_SELLLIMIT 3     //SELL LIMIT pending order  
#define OP_BUYSTOP 4       //BUY STOP pending order  
#define OP_SELLSTOP 5      //SELL STOP pending order  
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_SWAPTYPE 26
#define MODE_PROFITCALCMODE 27
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33

// Conversion Functions
#define CharToStr CharToString
#define DoubleToStr DoubleToString
#define StrToDouble StringToDouble
#define StrToInteger (int)StringToInteger
#define StrToTime StringToTime
#define TimeToStr TimeToString 
#define StringGetChar StringGetCharacter
#define StringSetChar StringSetCharacter

double iAsk()
{
   MqlTick last_tick;
   SymbolInfoTick(_Symbol,last_tick);
   return last_tick.ask; 
}  
double iBid()
{
   MqlTick last_tick;
   SymbolInfoTick(_Symbol,last_tick);
   return last_tick.bid;
}  

int iBars(string symbol,ENUM_TIMEFRAMES timeframe)
{
   int ibars;
   ibars=Bars(symbol,timeframe);
   return(ibars);
}

double iOpen(string symbol,ENUM_TIMEFRAMES timeframe,int index)
{   
   if(index < 0) return(-1);
   double array[];
   if(CopyOpen(symbol,timeframe, index, 1, array)>0) return(array[0]);
   else return(-1);
}
double iLow(string symbol,ENUM_TIMEFRAMES timeframe,int index)
{
   if(index < 0) return(-1);
   double array[];
   if(CopyLow(symbol,timeframe, index, 1, array)>0) return(array[0]);
   else return(-1);
}
double iHigh(string symbol,ENUM_TIMEFRAMES timeframe,int index)
{
   if(index < 0) return(-1);
   double array[];
   if(CopyHigh(symbol,timeframe, index, 1, array)>0) return(array[0]);
   else return(-1);
}
double iClose(string symbol,ENUM_TIMEFRAMES timeframe,int index)
{
   if(index < 0) return(-1);
   double array[];
   if(CopyClose(symbol,timeframe, index, 1, array)>0) return(array[0]);
   else return(-1);
}

datetime iTime(string symbol,ENUM_TIMEFRAMES timeframe,int index)
{
   if(index < 0) return(-1);
   datetime array[];
   if(CopyTime(symbol, timeframe, index, 1, array)>0) return(array[0]);
   else return(-1);
}

//Standard mql4 vars 
int Digits=_Digits;
double Point=_Point;

//Common Functions
double MarketInfo(string symbol, int type)
// With hacks to match integer type into double.
  {
   switch(type)
     {
      case MODE_LOW:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTLOW));
      case MODE_HIGH:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTHIGH));
      case MODE_TIME:
         return((double)  SymbolInfoInteger(symbol,SYMBOL_TIME));
      case MODE_BID:
         return(iBid());
      case MODE_ASK:
         return(iAsk());
      case MODE_POINT:
         return(SymbolInfoDouble(symbol,SYMBOL_POINT));
      case MODE_DIGITS:
         return((double) SymbolInfoInteger(symbol,SYMBOL_DIGITS));
      case MODE_SPREAD:
         return((double) SymbolInfoInteger(symbol,SYMBOL_SPREAD));
      case MODE_STOPLEVEL:
         return((double) SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL));
      case MODE_LOTSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE));
      case MODE_TICKVALUE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE));
      case MODE_TICKSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE));
      case MODE_SWAPLONG:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_LONG));
      case MODE_SWAPSHORT:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_SHORT));
      case MODE_STARTING:
         return(0);
      case MODE_EXPIRATION:
         return(0);
      case MODE_TRADEALLOWED:
         return(0);
      case MODE_MINLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN));
      case MODE_LOTSTEP:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP));
      case MODE_MAXLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX));
      case MODE_SWAPTYPE:
         return((double) SymbolInfoInteger(symbol,SYMBOL_SWAP_MODE));
      case MODE_PROFITCALCMODE:
         return((double) SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE));
      case MODE_MARGINCALCMODE:
         return(0);
      case MODE_MARGININIT:
         return(0);
      case MODE_MARGINMAINTENANCE:
         return(0);
      case MODE_MARGINHEDGED:
         return(0);
      case MODE_MARGINREQUIRED:
         return(0);
      case MODE_FREEZELEVEL:
         return((double) SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL));

      default: return(0);
     }
   return(0);
}
double AccountEquity()
{
 	return(AccountInfoDouble(ACCOUNT_EQUITY));
}

string WindowExpertName()
{
   return MQL5InfoString(MQL5_PROGRAM_NAME);
}

double AccountBalance()
{
   return AccountInfoDouble(ACCOUNT_BALANCE);
}

bool IsVisualMode()
{
   return MQL5InfoInteger(MQL5_VISUAL_MODE);
}

bool ObjectCreate( string name, ENUM_OBJECT type, int window, datetime time1, double price1, datetime time2=0, double price2=0, datetime time3=0, double price3=0) 
{
   return(ObjectCreate(0, name, type, window, time1, price1, time2, price2,time3, price3));   
}

bool ObjectSet( string name, ENUM_OBJECT_PROPERTY_INTEGER index, double value) 
{
   return(ObjectSetInteger(0, name, index, (long)value));
}

int ObjectFind( string name)
{
   return(ObjectFind(0,name));
}

bool ObjectSetText( string name, string text, int font_size, string font="", color text_color=CLR_NONE) 
{
   int tmpObjType=ObjectType(name);
   if(tmpObjType != OBJ_LABEL && tmpObjType != OBJ_TEXT) return(false);
   if(StringLen(text) > 0 && font_size > 0)
   {
      if(ObjectSetString(0,name,OBJPROP_TEXT,text)==true && ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size)==true)
      {
         if((StringLen(font)>0) && ObjectSetString(0,name,OBJPROP_FONT,font)==false) return(false);
         if((text_color!=CLR_NONE) && (ObjectSetInteger(0,name,OBJPROP_COLOR,text_color)==false)) return(false);
         return(true);
      }
      return(false);
   }
   return(false);
}

int ObjectType( string name) 
{
   return((int)ObjectGetInteger(0,name,OBJPROP_TYPE));
}

void DrawDot(string Name, int Bar, double Level, color Color)
{
      ObjectCreate(Name, OBJ_ARROW, 0, TimeCurrent(), Level, 0);
      ObjectSet(Name, OBJPROP_ARROWCODE, 160);
      ObjectSet(Name, OBJPROP_WIDTH, 1);
      ObjectSet(Name, OBJPROP_COLOR, Color); 
      return;
}

void UpArrow(string Name, datetime TIME, double Level, color Color)
{
   ObjectCreate(Name, OBJ_ARROW, 0, TIME, Level, 0);
   ObjectSet(Name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(Name, OBJPROP_ARROWCODE, 241);
   ObjectSet(Name, OBJPROP_WIDTH, 4);
   ObjectSet(Name, OBJPROP_COLOR, Color); 
   return;
}

void DownArrow(string Name, datetime TIME, double Level, color Color)
{
   ObjectCreate(Name, OBJ_ARROW, 0, TIME, Level, 0);
   ObjectSet(Name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(Name, OBJPROP_ARROWCODE, 242);
   ObjectSet(Name, OBJPROP_WIDTH, 4);
   ObjectSet(Name, OBJPROP_COLOR, Color);
   return;
}

void DrawText(string Name, string Text="", datetime TIME=0, double Level=0)
{
   if(ObjectFind(Name) == -1) ObjectCreate(Name, OBJ_TEXT, 0, TIME, Level);
   ObjectSetText(Name,Text,6,"",Yellow);
   return;
}

void DrawLabel(string Str="",string Text="",int X=0, int Y=0,color Color=Blue,int FontSize=5)
{
   ObjectCreate(Str,OBJ_LABEL,0,0,0);
   ObjectSetText(Str,Text,FontSize,"",Color);
   ObjectSet(Str,OBJPROP_CORNER, 0); 
   ObjectSet(Str,OBJPROP_XDISTANCE,X);
   ObjectSet(Str,OBJPROP_YDISTANCE,Y);
   return;
}

void DrawObjectLabel(string Str="",string Text="",int X=0, int Y=0,color Color=Blue,int FontSize=5)
{
   //Create object Label
   ObjectCreate(Str,OBJ_LABEL,0,0,0);
   //Set color of the text
   ObjectSetInteger(0,Str,OBJPROP_COLOR,Color);
   //Set text for the Label object
   ObjectSetString(0,Str,OBJPROP_TEXT,Text);
   //Set font size
   ObjectSetInteger(0,Str,OBJPROP_FONTSIZE,FontSize);
   //Bind to the upper right corner
   ObjectSetInteger(0,Str,OBJPROP_CORNER, 0); 
   ObjectSetInteger(0,Str,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(0,Str,OBJPROP_YDISTANCE,Y);
   //Rotate 90 degrees counter-clockwise
   ObjectSetDouble(0,Str,OBJPROP_ANGLE,0);
   //Forbid the selection of the object by mouse
   ObjectSetInteger(0,Str,OBJPROP_SELECTABLE,false);
   ChartRedraw(0);
}
bool ChartColorSet()
{
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,Red);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,Lime);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,Red);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,Lime);
   ChartSetInteger(0,CHART_SHOW_GRID,0);
   ChartSetInteger(0,CHART_MODE,1);
   return(true);
}

bool ChartColorChange(const color COLOR)
{
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,COLOR);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,COLOR);
   return(true);
}

double ChartPriceMin(const long chart_ID=0,const int sub_window=0)
{
   double result=EMPTY_VALUE;
   ChartGetDouble(chart_ID,CHART_PRICE_MIN,sub_window,result);
   return(result);
}

double ChartPriceMax(const long chart_ID=0,const int sub_window=0)
{
   double result=EMPTY_VALUE;
   ChartGetDouble(chart_ID,CHART_PRICE_MAX,sub_window,result);
   return(result);
}

int ChartVisibleBars(const long chart_ID=0)
{
   long result=-1;
   ChartGetInteger(chart_ID,CHART_VISIBLE_BARS,0,result);
   return((int)result);
   
}

void DrawTrend(bool Direction)
{
   double Offset;
   Offset=0.04*(ChartPriceMax(0,0)-ChartPriceMin(0,0));
   string Name=IntegerToString(iBars(Symbol(),Period()));
   ObjectCreate(Name, OBJ_ARROW, 0, TimeCurrent(), ChartPriceMin(0,0), 0);
   ObjectSet(Name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(Name, OBJPROP_WIDTH, 1);
   ObjectSet(Name, OBJPROP_PERIOD, PERIOD_H1);
   ObjectSet(Name, OBJPROP_ARROWCODE, 110);
   if(Direction==true)
   {
      ObjectSet(Name, OBJPROP_COLOR, Lime);
   }
   if(Direction==false)
   {
      ObjectSet(Name, OBJPROP_COLOR, Red);
   }
   
   for(int i=0; i<=ChartVisibleBars(0); i++)
   {
      ObjectMove(0,IntegerToString(iBars(Symbol(),Period())-i),0,iTime(Symbol(),Period(),i),ChartPriceMin(0,0)+Offset);
   }
   return;
}

void MoveTrend()
{
   double Offset;
   Offset=0.04*(ChartPriceMax(0,0)-ChartPriceMin(0,0));
   for(int i=0; i<=ChartVisibleBars(0); i++)
   {
      ObjectMove(0,IntegerToString(iBars(Symbol(),Period())-i),0,iTime(Symbol(),Period(),i),ChartPriceMin(0,0)+Offset);
   }
   return;
}