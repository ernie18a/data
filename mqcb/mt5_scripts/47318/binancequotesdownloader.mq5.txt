//+------------------------------------------------------------------+
//|                                      BinanceQuotesDownloader.mq5 |
//+------------------------------------------------------------------+
#property script_show_inputs

input string url="https://api.binance.com";
input uint marketViewUpdateInterval = 30000; // every n milliseconds must read marketView and check if symbols deleted or added
input uint quotesUpdateInterval = 5000; // every n milliseconds must update custom symbols quotes
input uint servicePauseInterval = 2500; // every n milliseconds service is sleeping 
input datetime downloadHistoryFrom = D'2023.01.01 00:00'; // max number of bars that will be downloaded from Binance server for Every Custom symbol
input bool  isForceReloadHistory = false;

uint LastTimeMarketViewRead = 0;
uint LastTimeQuotesUpdate = 0;
string binanceMarketViewSymbols[];
int marketViewSymbolsSize = 0;
bool forceReloaded = false;

void OnStart() {
   // check if passed interval and run code
   long currBarsHistory, seriesLastDate, seriesFirstDate;
   uint currTime;
   string symbolName, binanceSymbolName, customSymbolName, symbolPath;
   MqlRates rates[];
   string cookie=NULL,headers;
   char   post[],result[];
   
   checkSymbols();

   CBinanceClient client(url); 
   while(!_StopFlag){
      
      currTime = GetTickCount();
      if( (currTime-LastTimeMarketViewRead) > marketViewUpdateInterval ){
         LastTimeMarketViewRead = currTime;
         //Print("Read list of Binance Custom symbols that are in MarketView");
         marketViewSymbolsSize = 0;
         for(int i=0;i<SymbolsTotal(true);i++) { 
            symbolName = SymbolName(i,true);
            if(StringGetCharacter(symbolName,0) =='b'){
               Print(symbolName);
               marketViewSymbolsSize+=1;
               ArrayResize(binanceMarketViewSymbols, marketViewSymbolsSize, 10);
               binanceMarketViewSymbols[marketViewSymbolsSize-1] = symbolName;
            }
         }
      }
      
      if( currTime-LastTimeQuotesUpdate >= quotesUpdateInterval ){
         LastTimeQuotesUpdate = currTime;
         // update Binance custom Symbols history that presented in marketView
         for(int i=0; i<marketViewSymbolsSize;i++){
            customSymbolName = binanceMarketViewSymbols[i];
            binanceSymbolName = StringSubstr(customSymbolName, 1);            
            // download history
            long t = downloadHistoryFrom*1000;
            int s = 0;
            seriesFirstDate = CCustomSymbol::getCustomSymbolBarOldestDate(customSymbolName);
            currBarsHistory = CCustomSymbol::getCustomSymbolBarsCount(customSymbolName);
            // download all history from historyOldest daytime
            if( (currBarsHistory == 0 || t<seriesFirstDate*1000 || isForceReloadHistory)&&(forceReloaded == false) ){
               Print("Need to download/reDownload all history");               
               do{
                  client.requestQuotes(binanceSymbolName, t, NULL, 1000, rates);
                  CustomRatesUpdate(customSymbolName, rates);
                  s = ArraySize(rates);
                  PrintFormat("download history RequestQuotes for '%s' from date:%s. Downloaded:%d, time:%s", binanceSymbolName, TimeToString(t/1000), s, TimeToString(rates[s-1].time) );

                  if(s>0){ t = rates[s-1].time*1000; }
               }while(s>=1000);
            }
            // update recent last bars
            seriesLastDate = CCustomSymbol::getCustomSymbolBarRecentDate(customSymbolName);
            client.requestQuotes(binanceSymbolName, seriesLastDate, NULL, NULL, rates);
            CustomRatesUpdate(customSymbolName, rates);
            PrintFormat("Request %d Quotes for '%s' from %s", ArraySize(rates), binanceSymbolName, TimeToString(seriesLastDate/1000) );
         }
         forceReloaded = true;
      }   
      Sleep(servicePauseInterval);
   }   
}

void checkSymbols(){
   string symbolPath = SymbolInfoString("bBTCUSDT",SYMBOL_PATH);
   if(StringFind(symbolPath,"BINANCE") >= 0) return;

   string binanceSymbols[];
   int binanceSymbolsSize = 0;
   string cookie=NULL,headers;
   char   post[],result[];

   Print("Update List of Symbols from Binance is started ...");

   // 1. get list of all SYMBOLS that you can find in binance.com
   CBinanceClient client(url); 
   client.webRequest("GET","/api/v3/ticker/price",cookie,NULL,500,post, 0);
   string jsonStr = client.getResultAsString();

   CJsonParser parser(jsonStr);
   parser.toNextArray();
   while( parser.toNextObject()!=-1){
      ArrayResize(binanceSymbols, ++binanceSymbolsSize, 20);
      binanceSymbols[binanceSymbolsSize-1] = parser.getValueAsString("symbol");
   }
   // 2. get array of symbols and create custom symbols in mt5
   for(int i = 0; i<binanceSymbolsSize;i++){
      CCustomSymbol::createCustomSymbol( "b"+binanceSymbols[i] );
   }
   
   for(int i=0; i<SymbolsTotal(true); i++){
      if(SymbolSelect(SymbolName(i,true),false)) i--;
   }

   Print("Update List of Symbols from Binance is finished.");
}


//+------------------------------------------------------------------+
#include <Object.mqh>

class CBinanceClient : public CObject {
protected:
   string serverUrl;
   char result[];
   string resultHeaders;
   int res;

public:
   CBinanceClient(string serverUrl);
   ~CBinanceClient(void);
   int webRequest(const string      method,           // метод HTTP  
                  const string      apiUrl,              // url-адрес 
                  const string      cookie,           // cookie 
                  const string      referer,          // referer 
                  int               timeout,          // таймаут 
                  const char        &data[],          // массив тела HTTP-сообщения 
                  int               data_size);      // размер массива data[] в байтах 
   void saveResultAndHeadersInCommonTxtFile(string fileName);
   void printResultAndHeadersInConsole(void);
   void printResponceStatusInConsole(void);
   string getResultAsString();
   int requestQuotes(string binanceSymbolName, long startTime, long endTime, int limits, MqlRates &rates[]);

};
      
CBinanceClient::CBinanceClient(string srvUrl) {
   this.serverUrl = srvUrl;
}

CBinanceClient::~CBinanceClient(void) {
   
}

   
int CBinanceClient::webRequest(
   const string      method,           // метод HTTP  
   const string      apiUrl,              // url-адрес 
   const string      cookie,           // cookie 
   const string      referer,          // referer 
   int               timeout,          // таймаут 
   const char        &data[],          // массив тела HTTP-сообщения 
   int               data_size) {      // размер массива data[] в байтах 

   ResetLastError();
   res = WebRequest( "GET",serverUrl + apiUrl,
                     cookie,referer,timeout,
                     data,data_size,
                     this.result,this.resultHeaders);
   if(res==-1) {
      Print("Ошибка в WebRequest. Код ошибки  =",GetLastError());
      //--- возможно, URL отсутствует в списке, выводим сообщение о необходимости его добавления
      MessageBox("Необходимо добавить адрес '"+serverUrl+"' в список разрешенных URL во вкладке 'Советники'","Ошибка",MB_ICONINFORMATION);
   } else {
      if(res==200) {
         PrintFormat("запрос успешен, размер %d байт.",ArraySize(this.result));
      }
   }   
   return res;
}

void CBinanceClient::saveResultAndHeadersInCommonTxtFile(string fileName) {
   int filehandle=FileOpen(fileName,FILE_COMMON|FILE_TXT|FILE_WRITE);
   if(filehandle!=INVALID_HANDLE) {
      FileWriteString(filehandle, resultHeaders);
      FileWriteString(filehandle,CharArrayToString(result));
      //--- закрываем файл
      FileClose(filehandle);
   } else Print("Ошибка в FileOpen. Код ошибки =",GetLastError());
}

void CBinanceClient::printResultAndHeadersInConsole(void){
   if(res==200) {
      //--- успешная загрузка
      PrintFormat("запрос успешен, размер %d байт.",ArraySize(this.result));
      PrintFormat("%s", CharArrayToString(this.result) );
      PrintFormat("Заголовки сервера: %s",this.resultHeaders);
   }
}

void CBinanceClient::printResponceStatusInConsole(void){
      PrintFormat("responce status: %d.", this.res);
}

string CBinanceClient::getResultAsString(){
   return CharArrayToString(this.result);
}

/*
example of rest api web request
string jsonStr = "[
                   [1616362800000,\"0.03114900\",\"0.03114900\",\"0.03112200\",\"0.03112200\",\"321.55400000\",1616362859999,\"10.01102136\",357,\"104.64600000\",\"3.25810478\",\"0\"],
                   [1616362860000,\"0.03112200\",\"0.03113500\",\"0.03109300\",\"0.03112500\",\"244.69400000\",1616362919999,\"7.61258577\",365,\"29.91200000\",\"0.93052366\",\"0\"]
                  ]";
https://api.binance.com/api/v3/klines?symbol=ETHBTC&interval=1m&endTime=1616362860000&limit=2   
*/
int CBinanceClient::requestQuotes(string binanceSymbolName, long startTime, long endTime, int limits, MqlRates &rates[]){
   double d;
   long l;
   string cookie=NULL;
   char post[];
   string strSymbol, strStartTime, strEndTime, strLimits;  
   
   strSymbol = "?symbol=" + binanceSymbolName;
   if( startTime!=NULL){ strStartTime = "&startTime=" + (string)startTime; }
   else{ strStartTime =""; }
   if( endTime!=NULL){ strEndTime = "&endTime=" + (string)endTime; }
   else{ strEndTime =""; }
   if( limits!=NULL){ strLimits = "&limit=" + (string)limits; }
   else{ strLimits =""; }
   res = this.webRequest("GET","/api/v3/klines" + strSymbol + "&interval=1m" + strStartTime + strEndTime + strLimits, cookie,NULL,500,post, 0);
   string jsonStr = this.getResultAsString();
   
   CJsonParser parser(jsonStr);
   parser.toNextArray();
   
   int n = 0;
   while( parser.toNextArray()!=-1){
      ArrayResize(rates, n+1, 1000);
      l = parser.getValueAsLong();
      rates[n].time = l/1000;

      parser.toNextComma();
      d = parser.getValueAsDouble(8);
      rates[n].open = d;
   
      parser.toNextComma();
      d = parser.getValueAsDouble(8);
      rates[n].high = d;

      parser.toNextComma();
      d = parser.getValueAsDouble(8);
      rates[n].low = d;

      parser.toNextComma();
      d = parser.getValueAsDouble(8);
      rates[n].close = d;

      parser.toNextComma();
      d = parser.getValueAsDouble(8);
      rates[n].real_volume = d;

      parser.toNextComma();
      l = parser.getValueAsLong();

      parser.toNextComma();
      d = parser.getValueAsDouble(8);

      parser.toNextComma();
      l = parser.getValueAsLong();
      rates[n].tick_volume = l;

      parser.toNextComma();
      d = parser.getValueAsDouble(8);

      parser.toNextComma();
      d = parser.getValueAsDouble(8);

      parser.toNextComma();
      d = parser.getValueAsDouble(8);

      rates[n].spread = 1; // set spread

      n+=1;
   }
   ArrayResize(rates, n);
   return this.res;
}

//+------------------------------------------------------------------+

class CCustomSymbol : public CObject {

public:
   static void createCustomSymbol(string customSymbolName);
   static long getCustomSymbolBarsCount(string customSymbolName);
   static long getCustomSymbolBarRecentDate(string customSymbolName);
   static long getCustomSymbolBarOldestDate(string customSymbolName);

};

// create custom symbol int metatrader5 if symbol with that name not exists yet
// with no data quotes downloaded.
// Data quotes must be downloaded separately
static void CCustomSymbol::createCustomSymbol(string customSymbolName){
   bool isCustom = false;
   bool isCreated = false;
   bool isExist = false;
   isExist = SymbolExist(customSymbolName, isCustom);

   if(isExist==false || isCustom==false){
      isCreated = CustomSymbolCreate(customSymbolName, "BINANCE", "EURUSD");
      if(isCreated == false){ Print(GetLastError()); }
      else {
         CustomSymbolSetInteger(customSymbolName,SYMBOL_DIGITS,8);
      }
   }
}

// return number of all downloaded bars for current symbol
static long CCustomSymbol::getCustomSymbolBarsCount(string customSymbolName){
   return SeriesInfoInteger(customSymbolName,PERIOD_M1,SERIES_BARS_COUNT);
}

// return long datetime number of milliseconds for custom symbol most recent bar
static long CCustomSymbol::getCustomSymbolBarRecentDate(string customSymbolName){
   return SeriesInfoInteger(customSymbolName,PERIOD_M1,SERIES_LASTBAR_DATE)*1000;
}

// return long datetime number of milliseconds for custom symbol most old bar
static long CCustomSymbol::getCustomSymbolBarOldestDate(string customSymbolName){
   return SeriesInfoInteger(customSymbolName,PERIOD_M1,SERIES_FIRSTDATE)*1000;
}

//+------------------------------------------------------------------+

class CJsonParser : public CObject {
protected:
   string json;
   int currPointer;

public:
   CJsonParser(string str);
   ~CJsonParser(void);
   int CJsonParser::toNextArray(); // move to next '[' return -1 no more
   int CJsonParser::toEndOfArray(); // move to next ']' return -1 no more
   int CJsonParser::toNextObject(); // move to next '{' return -1 no more
   int CJsonParser::toEndOfObject(); // move to next '}' return -1 no more
   int CJsonParser::toKey(string key);  // move to string key "key" : "value" return -1 no more
   int CJsonParser::toNextComma(); // move to next ',' return -1 no more
   
   string CJsonParser::getValueAsString(string key); // find key and read value
   double CJsonParser::getValueAsDouble(string key, int digits); // find key and read value
   long CJsonParser::getValueAsLong(string key); // find key and read value
   
   string CJsonParser::getValueAsString(); //read value where no key
   double CJsonParser::getValueAsDouble(int digits); //read value where no key
   long CJsonParser::getValueAsLong(); //read value where no key

   void CJsonParser::printCurrentPointerChar(); 
};

CJsonParser::CJsonParser(string str) {
   this.json = str;
   this.currPointer = 0;
}

CJsonParser::~CJsonParser(void) {
   
}

int CJsonParser::toNextArray(){
   int pos = StringFind(this.json, "[", this.currPointer);
   if( pos!=-1){
      this.currPointer = pos+1;
   } 
   return pos; 
}

int CJsonParser::toEndOfArray(){
   int pos = StringFind(this.json, "]", this.currPointer);
   if( pos!=-1){
      this.currPointer = pos+1;
   } 
   return pos; 
}


int CJsonParser::toNextObject(){
   int pos = StringFind(this.json, "{", this.currPointer);
   if( pos!=-1){
      this.currPointer = pos+1;
   } 
   return pos; 
}

int CJsonParser::toEndOfObject(){
   int pos = StringFind(this.json, "}", this.currPointer);
   if( pos!=-1){
      this.currPointer = pos+1;
   } 
   return pos;
}

int CJsonParser::toKey(string key){
   int pos = StringFind(this.json, key, this.currPointer);
   if( pos!=-1){
      this.currPointer = pos;
   } 
   return pos; 
}

int CJsonParser::toNextComma(){
   int pos = StringFind(this.json, ",", this.currPointer);
   if( pos!=-1){
      this.currPointer = pos+1;
   } 
   return pos; 
}

string CJsonParser::getValueAsString(string key){
   int pos;
   int posKey=-1;
   int posDelimiter=-1;
   int posValueBegin=-1;
   int posValueEnd=-1;
   string value = NULL;
   
   pos = StringFind(this.json, key, this.currPointer);
   if( pos!=-1){
      posKey = pos;
   }else return value;

   pos = StringFind(this.json, ":", posKey);
   if( pos!=-1){
      posDelimiter = pos;
   }else return value;

   pos = StringFind(this.json, "\"", posDelimiter);
   if( pos!=-1){
      posValueBegin = pos+1;
   }else return value;

   pos = StringFind(this.json, "\"", posValueBegin);
   if( pos!=-1){
      posValueEnd = pos;
   }else return value;
   
   value = StringSubstr(this.json, posValueBegin, posValueEnd-posValueBegin);
   
   return value;
}

long CJsonParser::getValueAsLong(string key){
   int pos;
   int posKey=-1;
   int posDelimiter=-1;
   int posValueBegin=-1;
   int posValueEnd=-1;
   int value = NULL;
   string strValue = NULL;
   
   pos = StringFind(this.json, key, this.currPointer);
   if( pos!=-1){
      posKey = pos;
   }else return value;

   pos = StringFind(this.json, ":", posKey);
   if( pos!=-1){
      posDelimiter = pos;
   }else return value;

   strValue = StringSubstr(this.json, posValueBegin, 20);

   return (long)NormalizeDouble(StringToDouble(strValue), 0);
}

double CJsonParser::getValueAsDouble(string key, int digits){
   string value = this.getValueAsString(key);
   if(value!=NULL){
      return NormalizeDouble(StringToDouble(value), digits);
   }else return NULL;
}

string CJsonParser::getValueAsString(){
   int pos;
   int posValueBegin=-1;
   int posValueEnd=-1;
   string strValue = NULL;

   pos = StringFind(this.json, "\"", this.currPointer);
   if( pos!=-1){
      posValueBegin = pos+1;
   }else return strValue;

   pos = StringFind(this.json, "\"", posValueBegin);
   if( pos!=-1){
      posValueEnd = pos;
   }else return strValue;
   
   strValue = StringSubstr(this.json, posValueBegin, posValueEnd-posValueBegin);
   return strValue;   
}

double CJsonParser::getValueAsDouble(int digits){
   string value = NULL;
   value = this.getValueAsString();
   if(value!=NULL){
      return NormalizeDouble(StringToDouble(value), digits);
   }else return NULL;
}

long CJsonParser::getValueAsLong(){
   string strValue = NULL;
   strValue = StringSubstr(this.json, this.currPointer, 20);
   if(strValue!=NULL){
      return (long)NormalizeDouble(StringToDouble(strValue), 0);
   }else return NULL;
}


void CJsonParser::printCurrentPointerChar(){
   string currPointerStr = StringSubstr(this.json, this.currPointer, 20);
   Print(currPointerStr);
}
