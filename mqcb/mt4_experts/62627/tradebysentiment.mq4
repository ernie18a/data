//+------------------------------------------------------------------+
//|                       ZIWOX Sentiment and Technical Strategy.mq4 |
//|                                        Copyright 2024, ssabbaghi |
//|                          https://www.mql5.com/en/users/ssabbaghi |
//+------------------------------------------------------------------+
#property copyright "Sara Sabbaghi"
#property link      "https://www.mql5.com/en/users/ssabbaghi"
#property version   "1.00"
#property strict


//---- input parameters
input    bool        AutoTrade      =  false;   // Trade Automatically
input    string      APIKey         =  "";      // Your Ziwox API key
input    string      SymbolPrefix   =  "";      // Your Broker symbol Prefix
input    string      SymbolSuffiex  =  "";      // Your Broker symbol Suffiex
input    int         shortMAPeriod  =  9;       // Slow MA Period
input    int         longMAPeriod   =  50;      // Fast MA Period
input    double      Lots           =  0.01;    // Order volume

#include <JAson.mqh> 
CJAVal JsonValue;

string   OBJPREFIX      =  "ZX_API",
         SymbolRequest  =  "",
         APIJSON[];
bool     APIOK =  false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//----
   EventSetTimer(10);
   ArrayResize(APIJSON,15);
   SymbolRequest  =  PureSymbol(Symbol(),SymbolSuffiex,SymbolPrefix); // Prepair real symbol name is it has suffiex or prefix
   Comment("Updating data from Ziwox API...");
//----
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
   EventKillTimer();
  }


//+------------------------------------------------------------------+
//| Expert tick function    OnTick()                                 |
//+------------------------------------------------------------------+
void OnTick()
  {
   if (!APIOK) return;
   
   double   shortMA, longMA;
   long     ticket = -1;
   
   if (AutoTrade)
   if(IsNewCandle())
     {
      shortMA  = iMA(Symbol(), 0, shortMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
      longMA   = iMA(Symbol(), 0, longMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
      
      // Check for crossover signals
      if ( int(APIJSON[6])>=60 ) // if Retails are selling, we will buy (Long < 40 and short > 60)
         if (shortMA > longMA)   // BUY trend 
         { 
            if (OrdersTotal() == 0) {
               ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, 0, 0, "Buy Order", 0, 0, Green);
               if (ticket < 0) Print("Error opening buy order: ", GetLastError());
            }
         }
      if ( int(APIJSON[5])>=60 ) // if Retails are buying, we will sell (Long > 60 and short < 40)
         if (shortMA < longMA)   // Sell trend
         {
            if (OrdersTotal() == 0) 
            {
               ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, 3, 0, 0, "Sell Order", 0, 0, Red);
               if (ticket < 0) Print("Error opening sell order: ", GetLastError());
            }
         } 
     }
  }
//+------------------------------------------------------------------+
//| Expert OnTimer function                                          |
//+------------------------------------------------------------------+
void OnTimer()
 {
   string   APIfilename    =  SymbolRequest+"_API_Data.json"; // API store file name
   APIOK = GetAPI(SymbolRequest, APIKey,  APIfilename);  // Get the API data and save it to  APIfilename
   if ( APIOK ) JsonDataParse( APIfilename,APIJSON);     // read the JSON data and store them into the API_DATA array
   Comment((APIOK ? "API OK":"API FAILED"),
            "\nSentiment:",
            "\nRetail traders Long: ",APIJSON[5],
            "\nRetail traders Short: ",APIJSON[6],
            "\nMarket Risk: ",APIJSON[14]
            );
   DrawSentiment(OBJPREFIX,SymbolRequest,APIJSON[5],APIJSON[6]);
 }
//+------------------------------------------------------------------+
//| New candle check function                                        |
//+------------------------------------------------------------------+
datetime NewCandleTime=TimeCurrent();
bool IsNewCandle()
  {
   if(NewCandleTime==iTime(Symbol(),0,0))
      return false;
   else
     {
      NewCandleTime=iTime(Symbol(),0,0);
      return true;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PureSymbol(string symbol, string suffiex, string prefix)
  {
   string   puresymbol =  symbol;
   if(prefix!="" || suffiex!="")
     {
      StringReplace(symbol,suffiex,"");
      StringReplace(symbol,suffiex,"");
     }
   return(puresymbol);
  }





//+------------------------------------------------------------------+
//|  Get Fund data from ziwox                                        |
//+------------------------------------------------------------------+
datetime LastWebRequest = 0; // use this datetime var for limit failed request API
bool GetAPI(string symbolname, string apikey, string filename)
  {
   Print("Get API Update");
   bool NeedToUpdate =   false;
   
   // Check if the API data file available
   if(FileGetInteger(filename,FILE_EXISTS,true)>=0)
     {
      // Check the latest update time from file modify date time
      if(TimeLocal()-(datetime)FileGetInteger(filename,FILE_MODIFY_DATE,true)>900) // update data every 15 min becasue of API call rate limitation
         NeedToUpdate  = true;
     }
   else
      NeedToUpdate  =  true;
      
   if(NeedToUpdate && TimeLocal()-LastWebRequest>300)   // retry failed API request every 5 min to avoid firewall IP block
     {
      string   cookie=NULL,headers;
      char     post[],result[];
      int      res;
      string   URL   =  "https://www.ziwox.com/terminal/services/API/V1/fulldata.php?expn=ziwoxuser&apikey="+apikey+"&apitype=json&pair="+symbolname;
      ResetLastError();
      int timeout=5000;
      res=WebRequest("GET",URL,cookie,NULL,timeout,post,0,result,headers);
      if(res==-1)
        {
         LastWebRequest    =  TimeLocal();
         int error         =  GetLastError();
         if(error==4060)
            Print("API data Webrequest Error ",error, " Check your webrequest on Metatrader Expert option.");
         else  if(error==5203)
               Print("HTTP request for "+symbolname+" Data failed!");
            else
               Print("Unknow HTTP request error("+string(error)+")! "+symbolname+" Data");
         return(false);
        }
      else
         if(res==200)
           {
            LastWebRequest =  TimeLocal();
            string HTTPString = CharArrayToString(result, 0, 0, CP_UTF8);
            Print("HTTP request for "+symbolname+" Data successful!");
            Print(HTTPString);
            if (StringFind(HTTPString,"invalid api key",0)!=-1) {
               Alert("invalid api key");
               return(false);
            }
            // Store the API data into a common folder file
            int filehandle=FileOpen(filename,FILE_READ|FILE_SHARE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_BIN|FILE_COMMON);
            if(filehandle!=INVALID_HANDLE)
              {
               FileWriteArray(filehandle,result,0,ArraySize(result));
               FileClose(filehandle);
              }
           }
     }
   return(true);
  }
//+------------------------------------------------------------------+



void JsonDataParse(string filename, string &_APIJSON[])
  {
   bool     UpdateData =   false;
   for (int arraIn=0; arraIn<ArraySize(APIJSON); arraIn++) APIJSON[arraIn]="";

   if(FileGetInteger(filename,FILE_EXISTS,true)>=0)
     {
      int   FileHandle =FileOpen(filename,FILE_READ|FILE_SHARE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_BIN|FILE_COMMON);
      char  jsonarray[];
      FileReadArray(FileHandle,jsonarray);
      FileClose(FileHandle);

      JsonValue.Clear();
      JsonValue.Deserialize(CharArrayToString(jsonarray, 0, 0, CP_UTF8));

      _APIJSON[0]   =   JsonValue[0]["Symbol"].ToStr();
      _APIJSON[1]   =   JsonValue[0]["Fundamental Bias"].ToStr();
      _APIJSON[2]   =   JsonValue[0]["Fundamental Power"].ToStr();
      _APIJSON[3]   =   JsonValue[0]["AI Bullish Forecast"].ToStr();
      _APIJSON[4]   =   JsonValue[0]["AI Bearish Forecast"].ToStr();
      _APIJSON[5]   =   JsonValue[0]["Retail Long Ratio"].ToStr();
      _APIJSON[6]   =   JsonValue[0]["Retail Short Ratio"].ToStr();
      _APIJSON[7]   =   JsonValue[0]["Retail Short Lot"].ToStr();
      _APIJSON[8]   =   JsonValue[0]["Retail Short pos"].ToStr();
      _APIJSON[9]   =   JsonValue[0]["Base COT NET"].ToStr();
      _APIJSON[10]  =   JsonValue[0]["Base COT change"].ToStr();
      _APIJSON[11]  =   JsonValue[0]["Quote COT NET"].ToStr();
      _APIJSON[12]  =   JsonValue[0]["Quote COT change"].ToStr();
      _APIJSON[13]  =   JsonValue[0]["COT chng Ratio"].ToStr();
      _APIJSON[14]  =   JsonValue[0]["Risk Sentiment"].ToStr();
     }
  }
//+------------------------------------------------------------------+


void DrawSentiment(string OBJPREF, string symb, string longp, string shortp) {
   int x=10,y=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-30, space=5;
   ButtonCreate(0,OBJPREF+".SentimentBox",0,x,y,100,20,CORNER_LEFT_UPPER,symb,"Arial Black",10,clrWhiteSmoke,clrDimGray,clrDimGray,false,false,false,true,100,"S ENTIMENT");
   x+=100+space;
   ButtonCreate(0,OBJPREF+".SentimentLong",0,x,y,int(longp)+20,20,CORNER_LEFT_UPPER,longp,"Arial",8,clrWhiteSmoke,clrSeaGreen,clrSeaGreen,false,false,false,true,100,"S ENTIMENT");
   x+=18+int(longp);
   ButtonCreate(0,OBJPREF+".SentimentShort",0,x,y,int(shortp)+20,20,CORNER_LEFT_UPPER,shortp,"Arial",8,clrWhiteSmoke,clrIndianRed,clrIndianRed,false,false,false,true,100,"S ENTIMENT");
}

//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=0,                // priority for mouse click
                  const string            tooltip="\n")             // tooltip for mouse hover
  {
//--- reset the error value
   ResetLastError();
//---
   if(ObjectFind(chart_ID,name)<0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create the button! Error code = ",_LastError);
         return(false);
        }
      //--- SetObjects
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
     }
   else
     {
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
     }
//---
   return(true);
  }
