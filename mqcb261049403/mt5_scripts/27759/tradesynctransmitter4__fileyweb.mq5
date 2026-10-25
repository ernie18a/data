//+------------------------------------------------------------------+
//|                                         TradeSyncTransmitter.mq5 |
//|                                                         TheCoder |
//|                                                       nolinkHere |
//| Open Source Code for Transmitter                                 |
//| This Expert Advisor will Write all trades taken to a CSV file    |
//| The File Can be opened by another EA written in another          |
//| language, other platform to take the same trades on the other    |
//| platform.                                                        |
//| Trades requests are transmitted individually in real time.       |
//| Position Summary are transmitted regularly, according to the     |
//| interval specified on the settings.                              |
//| For Educational purposes only                                    |   
//|                                                                  |
//| 2020/02/20 Implemented Web Transmission to a free signal relay   |
//| service, where all signals are relayed to several free receivers |
//+------------------------------------------------------------------+
#property copyright "TheCoder"
#property link      "nolinkHere"
#define Revision "Prototype 3, Feb 4th, 2020"
#property version "3.44"
input int SyncTimer = 60; // How Often Should the Position Package be transmitted (in seconds)
input int ShowMessagesRanked = 3; // Messages Level / 1 = Coder , 3 = User
input string TransmitterLabelForReceiver = "TSR2"; // 4 Leters Label for this Transmission Session.
input string ServerURL = "http://thecoder1.pythonanywhere.com:80"; // Server Hub WebAddress
string PositionsFileName = "TradeSync-"+TransmitterLabelForReceiver+"\\Positions.csv";
string OrdersFileName = "TradeSync-"+TransmitterLabelForReceiver+"\\Orders.csv";
string LogFile = "TradeSync-"+TransmitterLabelForReceiver+"\\LogFile-MT5.txt";
string LogFileName;
datetime PositionsTransmissionTime = 0;
datetime OrdersTransmissionTime = 0;
datetime RequestTransmissionTime = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//TradeTransmit("Hello World");
   LogFileName = StringSubstr(LogFile,0,StringLen(LogFile)-4) +" - "+ TimeToString(TimeLocal(),TIME_DATE)+StringSubstr(LogFile,StringLen(LogFile)-4,4);
   TellUser("Initializing TradeSync Transmitter " + Revision,3);
   if(StringLen(TransmitterLabelForReceiver) > 4)
     {
      TellUser("Label for Receiver must be MAX 4 Characters, Leters and Numbers ONLY.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   EventSetTimer(SyncTimer);
   TellUser("Sync Timer is set to every " + IntegerToString(SyncTimer) + " seconds.",3);
   UserPanelUpdate();
   TransmitOrders();
   TransmitPositions();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   EventKillTimer();
   ObjectsDeleteAll(0);
  }

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//--- Includes the current trade and cycle through ALL open Positions and Pending Orders --
   TransmitTradeRequest(request);

  }

//+------------------------------------------------------------------+
//| Timer Event Handler                            |
//+------------------------------------------------------------------+
void OnTimer()
  {
   TransmitOrders();
   TransmitPositions();
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Read Current Pending Orders                                      |
//+------------------------------------------------------------------+
bool TransmitOrders()
  {
   ulong    OrderTicket;
   uint     total=OrdersTotal();
   double AccountEquity=AccountInfoDouble(ACCOUNT_EQUITY);
   string oTimeLocal=TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS);
   string oTimeGMT=TimeToString(TimeGMT(),TIME_DATE|TIME_SECONDS);
   string oStringExpiration;

// ------------- Creating transmission File and writing Header ----------------//
   TellUser("Initiating Transmission of "+IntegerToString(total)+" Orders.");
   int OrdersFileHandle=FileOpen(OrdersFileName,FILE_WRITE|FILE_COMMON|FILE_CSV);   //Criando Arquivo de transmissao das ordens
   FileWrite(OrdersFileHandle, total, " Total Orders in this file.");
   FileWrite(OrdersFileHandle, "Seq", "TimeLocal","TimeGMT","m_account.Equity","OrderTicket","OrderTime_setup","OrderType",
             "OrderTimeExpiration","OrderTypeFilling","OrderTypeTime","OrderPositionID","OrderPositionByID",
             "OrderVolumeCurrent","OrderOpenPrice","OrderSL","OrderTP", "OrderSymbol","OrderComment","End of Line C19");
// --------------End of Header Creation -----------------------------//

//------- go through orders in a loop
   for(uint i=0; i<total; i++)
     {
      //--------- return order ticket by its position in the list
      OrderTicket=OrderGetTicket(i);
      //TellUser("Step "+(i+1)+ " of "+total+", Packing info about Order "+OrderTicket);
      if(OrderTicket>0)
        {
         //-------- read and prepare order properties ------------//
         datetime OrderTime_setup    =(datetime)OrderGetInteger(ORDER_TIME_SETUP);
         int OrderType          =OrderGetInteger(ORDER_TYPE);
         oStringExpiration = TimeToString(OrderGetInteger(ORDER_TIME_EXPIRATION),TIME_DATE|TIME_SECONDS);
         if(oStringExpiration == "1970.01.01 00:00:00")
            oStringExpiration = NULL;
         string OrderTypeFilling=IntegerToString(OrderGetInteger(ORDER_TYPE_FILLING));
         string OrderTypeTime=IntegerToString(OrderGetInteger(ORDER_TYPE_TIME));
         long OrderPositionID=OrderGetInteger(ORDER_POSITION_ID);
         long OrderPositionByID=OrderGetInteger(ORDER_POSITION_BY_ID);
         double OrderVolumeCurrent=OrderGetDouble(ORDER_VOLUME_CURRENT);
         double OrderOpenPrice    =OrderGetDouble(ORDER_PRICE_OPEN);
         double OrderSL = OrderGetDouble(ORDER_SL);
         double OrderTP = OrderGetDouble(ORDER_TP);
         string OrderSymbol = OrderGetString(ORDER_SYMBOL);
         string OrderComment = OrderGetString(ORDER_COMMENT);
         // ---------- Write each Order info to 1 line on a csv file ------------------------//
         //FileWrite(OrdersFileHandle, i+1, oTimeLocal,oTimeGMT, AccountEquity,OrderTicket, OrderTime_setup,OrderType,OrderState,OrderTimeExpiration,OrderTimeDone,OrderTimeSetupMSC,OrderTimeDoneMSC,OrderTypeFilling,OrderTypeTime,OrderMagic,OrderReason,OrderPositionID,OrderPositionByID,OrderVolumeInitial,OrderVolumeCurrent,OrderOpenPrice,OrderSL,OrderTP,OrderPrice,OrderPriceStopLimit,OrderSymbol,OrderComment,OrderExtID,"End of Line");
         FileWrite(OrdersFileHandle, i+1, oTimeLocal,oTimeGMT, AccountEquity,OrderTicket, OrderTime_setup,OrderType,oStringExpiration,
                   OrderTypeFilling,OrderTypeTime, OrderPositionID,OrderPositionByID,OrderVolumeCurrent,OrderOpenPrice,OrderSL,OrderTP,OrderSymbol,
                   OrderComment,"End of Line C19");


        }

     }
   FileClose(OrdersFileHandle);   // ---------- Closing the transmission file, so its available for sending and or reading
   TellUser("Transmitted, info about "+IntegerToString(total)+" orders in the System.");
   OrdersTransmissionTime=TimeLocal();
   UserPanelUpdate();
   if(total>0)
     {
      return true;
     }
   else
     {
      return false;
     }
  }


//+-----------------------------------------------------------------------------------+
//| Read Current Positions and write all of them to a CSV File, 1 position per Line   |
//+-----------------------------------------------------------------------------------+
bool TransmitPositions()     // Funcao para ler as posicoes
  {
//--- number of current positions
   uint     PosTotal=PositionsTotal();
   ulong PositionTicket;
   double AccountEquity =AccountInfoDouble(ACCOUNT_EQUITY);
   string nTimeLocal = TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS);
   string nTimeGMT = TimeToString(TimeGMT(),TIME_DATE|TIME_SECONDS);
   TellUser("Initiating Transmission of "+IntegerToString(PosTotal)+" Position.");
// --------- Create CSV file and Write Header on the 1st Line  ------------ //
   int PositionsFileHandle=FileOpen(PositionsFileName,FILE_WRITE|FILE_COMMON|FILE_CSV);   //Criando Arquivo de transmissao das posicoes.
   FileWrite(PositionsFileHandle,PosTotal,"Position in this file.");
   FileWrite(PositionsFileHandle,"Seq","TimeLocal","TimeGMT","m_account.Equity","PositionTicket","PositionOpenTime",
             "PositionType","PositionID", "PositionVolume", "PositionPriceOpen","PositionSL","PositionTP",
             "PositionProfit", "PositionSymbol", "PositionComment","End of Line C16");

//--- go through positions in a loop
   for(uint i=0; i<PosTotal; i++)
     {
      //--- return order ticket by its position in the list
      PositionTicket=PositionGetTicket(i);
      //TellUser("Step "+(i+1)+ " of "+PosTotal+", Packing info about Position "+PositionTicket);
      if(PositionTicket>0)          //Meaning the position exists,
        {
         //--- Loading Position Information
         datetime PositionOpenTime = PositionGetInteger(POSITION_TIME);
         int PositionType=PositionGetInteger(POSITION_TYPE);    // type of the position
         long PositionID = PositionGetInteger(POSITION_IDENTIFIER);
         double PositionVolume=PositionGetDouble(POSITION_VOLUME);
         double PositionPriceOpen=PositionGetDouble(POSITION_PRICE_OPEN);
         double PositionSL = PositionGetDouble(POSITION_SL);
         double PositionTP=PositionGetDouble(POSITION_TP);
         double PositionProfit=PositionGetDouble(POSITION_PROFIT);
         string PositionSymbol = PositionGetString(POSITION_SYMBOL);
         string PositionComment = PositionGetString(POSITION_COMMENT);
         FileWrite(PositionsFileHandle, i+1, nTimeLocal, nTimeGMT, AccountEquity,PositionTicket,PositionOpenTime,PositionType,
                   PositionID, PositionVolume, PositionPriceOpen,PositionSL,PositionTP, PositionProfit, PositionSymbol, PositionComment,"End of Line C16");

        }
     }
   FileClose(PositionsFileHandle);
   TellUser("Transmitted, info about "+IntegerToString(PosTotal)+" positions in the system.");
   PositionsTransmissionTime=TimeLocal();
   UserPanelUpdate();
   return true;
  }

//+------------------------------------------------------------------+
//| Transmit Trade Requests in csv file with header               |
//+------------------------------------------------------------------+
bool TransmitTradeRequest(const MqlTradeRequest& request)   //Reads when something sends a TradeRequest
  {
   if(request.action != 0)
     {
      // -------- If File NOT exist, Create and Writing CSV File with header and info on the Trade request  --------- //
      string TradeRequestFileName = "TradeSync-"+TransmitterLabelForReceiver+"\\Request-"+TimeToString(TimeLocal(),TIME_DATE)+ ".csv";
      string reqExp;
      int TransmissionFileHandle;
      if(FileIsExist(TradeRequestFileName, FILE_COMMON))
        {
         TellUser("Transmission File " + TradeRequestFileName + " Already Exists, appending to it.");
         TransmissionFileHandle=FileOpen(TradeRequestFileName,FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_COMMON, '\t');   //Abrindo Arquivo de transmissao do Sinal.
         if(TransmissionFileHandle<0)
            TellUser("Error: "+IntegerToString(GetLastError()));
        }
      else
        {
         TellUser("Transmission File does not Exist, Creating "+TradeRequestFileName);
         TransmissionFileHandle=FileOpen(TradeRequestFileName,FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_COMMON, '\t');   //Abrindo Arquivo de transmissao do Sinal.
         if(TransmissionFileHandle<0)
            TellUser("Error: "+IntegerToString(GetLastError()));
         FileWrite(TransmissionFileHandle,"TimeLocal","TimeGMT","m_account.Equity","request.action", "request.magic",  "request.order",  "request.symbol","request.volume","request.price", "request.stoplimit",    "request.sl","request.tp","request.deviation","request.type",     "request.type_filling",             "request.type_time",            "request.position","request.position_by","request.comment","request.expiration", "End of Header");
        }

      // ---- Now, since file exists, one way or another, append and write trade request line after last line.
      if(! FileSeek(TransmissionFileHandle,0,SEEK_END))
         TellUser("Error Moving File Pointer "+IntegerToString(GetLastError()));
      if(request.expiration>0)
         reqExp = TimeToString(request.expiration,TIME_DATE|TIME_SECONDS);
      else
         reqExp = NULL;
      FileWrite(TransmissionFileHandle,TimeLocal(),TimeGMT(),AccountInfoDouble(ACCOUNT_EQUITY),EnumToString(request.action),  request.magic,    request.order,    request.symbol,request.volume,request.price,       request.stoplimit,      request.sl,request.tp,request.deviation,EnumToString(request.type),EnumToString(request.type_filling),EnumToString(request.type_time),request.position,  request.position_by, request.comment,  reqExp,     "End of Line");
      FileClose(TransmissionFileHandle);

      TradeWebTransmit(("TradeSyncRequest [{\"TR_ID\":"+ IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+
      ",\"ACTION\":"+EnumToString(request.action)+
      ",\"SYMBOL\":"+request.symbol+
      ",\"ORD_NUM\":"+IntegerToString(request.order)+
      ",\"POS\":" + IntegerToString(request.position) + 
      ",\"POS_BY\":" + IntegerToString(request.position_by) + 
      ",\"T_GMT\":"  + TimeToString(TimeGMT(),TIME_DATE|TIME_SECONDS) + 
      ",\"ORD_TYPE\":" + EnumToString(request.type)+ 
      ",\"ACC_EQ\":"+DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2)+
      ",\"VOLUME\":" + DoubleToString(request.volume,3)+
      ",\"PRICE\":"+DoubleToString(request.price,5)+
      ",\"STOP_LIMIT\":"+DoubleToString(request.stoplimit,5)+
      ",\"TP\":"+DoubleToString(request.tp,5)+
      ",\"SL\":" + DoubleToString(request.sl,5) + "}]"));


      // ------------- Showing Trade Request info on MT5 Console -------------//
      TellUser("Transmitted: "+ EnumToString(request.action)+ " Order: "+ IntegerToString(request.order) + " Position: " + IntegerToString(request.position) +" Position by: "+ IntegerToString(request.position_by) + " by magic: "+ IntegerToString(request.magic),3);
      RequestTransmissionTime=TimeLocal();
      UserPanelUpdate();
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Function to Print a message to the Console                       |
//+------------------------------------------------------------------+
void TellUser(string message, int ImportanceRank = 1)
  {
   bool WriteToLog = true;
   bool ShowOnScreen = true;
   if(WriteToLog)
     {
      WriteToLogFile(message);
     }
   if(ImportanceRank>=ShowMessagesRanked)
     {
      Print(TransmitterLabelForReceiver,": ",message);
     }
  }

//+-----------------------------------------------------------------+
// Function to Write a Log file
//+-----------------------------------------------------------------+
void WriteToLogFile(string LogMessage)
  {
   int fH = FileOpen(LogFileName,FILE_READ|FILE_WRITE|FILE_COMMON);
   FileSeek(fH,0,SEEK_END);
   string row = TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS) +" "+TransmitterLabelForReceiver+": "+ LogMessage + "\r\n";
   FileWriteString(fH, row, StringLen(row));
   FileClose(fH);
  }

//    \r\n is not delimiter. It's a control character to represent a newline. \r is carriage return, and \n is new line feed. In mql4 FileWrite (https://docs.mql4.com/files/FileWrite), the \n\r is added automatically.
//    \n = LF (Line Feed) used in UNIX,   \r = CR (Carriage Return) used in Mac,   \n\r = CR + LF used in Windows

//+------------------------------------------------------------------+
//| Creates and updates user panel label                             |
//+------------------------------------------------------------------+
void UserPanelUpdate()
  {
   string TextOnLabel0 = ("Transmitting Signals to " + ServerURL);
   string TextOnLabel1 = ("Latest Positions Transmission: "+TimeToString(PositionsTransmissionTime,TIME_DATE|TIME_SECONDS));
   string TextOnLabel2 = ("Latest Orders Transmission:"+TimeToString(OrdersTransmissionTime,TIME_DATE|TIME_SECONDS));
   string TextOnLabel3;
// Comment("Comment goes here /nLine2");
   if(RequestTransmissionTime != 0)
     {
      TextOnLabel3 = ("Latest Trade Request Transmission:" +TimeToString(RequestTransmissionTime,TIME_DATE|TIME_SECONDS));
     }
   else
     {
      TextOnLabel3 = ("No Requests Transmitted yet");
     }

   Comment(("TradeSync Transmitter "+TransmitterLabelForReceiver)+"\n"+
           Revision + "\n"+TextOnLabel0+"\n"+TextOnLabel1+"\n"+TextOnLabel2+"\n"+TextOnLabel3);


  }

//+------------------------------------------------------------------+
int TradeWebTransmit(string Message)
  {
   TellUser((" Transmitting via web " + Message),3);
   string cookie=NULL,headers;
   char   post[],result[];
   string url=ServerURL;
   StringToCharArray(Message, post);
//--- To enable access to the server, you should add URL "https://finance.yahoo.com"
//--- to the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"):
//--- Resetting the last error code
   ResetLastError();
//--- Downloading a html page from Yahoo Finance
   int res=WebRequest("POST",url,cookie,NULL,500,post,0,result,headers);
   if(res==-1)
     {
      Print("Error in WebRequest. Error code  =",GetLastError());
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address
      TellUser(("Add the address '"+StringSubstr(url,0,StringFind(url,":"))+"' to the list of allowed URLs on tab 'Expert Advisors'" + "Error"),3);
     }
   else
     {
      if(res==200)
        {
         //--- Successful download
         //PrintFormat("The server response was, File size %d byte.",ArraySize(result));
         //PrintFormat("Server headers: %s",headers);
         PrintFormat("Server Result: %s", CharArrayToString(result));
         //--- Saving the data to a file
         //int filehandle=FileOpen("url.htm",FILE_WRITE|FILE_BIN);
         //if(filehandle!=INVALID_HANDLE)
         //  {
            //--- Saving the contents of the result[] array to a file
         //   FileWriteArray(filehandle,result,0,ArraySize(result));
            //--- Closing the file
         //   FileClose(filehandle);
         //  }
         //   TellUser("Signal Transmission Successful.");
         //else
         //   Print("Error in FileOpen. Error code =",GetLastError());
        }
      else
         PrintFormat("Signal Transmission '%s' failed, error code %d",url,res);
     }
// fim da funcao...
   return 0;

  }
//+------------------------------------------------------------------+
