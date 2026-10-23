input bool TradeEnabled = false;  // Breakout trade option
input double Lots = 1.0;          // Trade Lots
input int TargetProfit = 50;      // Target Profit 
input int StopLoss = 50;          // Stop Loss
input int Slippage = 50;          // Slippage


input bool AlertPopup = true;   // Popup breakout notification
input bool Sound = true;        // Sound breakout notification
input bool EmailAlert = true;   // Email breakout notification
input bool MobileAlert = false;  // MT4 mobile notification

input int PriceDelta = 0;  // More points for breakout threshold

input int HourStart = 0;   // EA working hour starts
input int HourEnd = 24;    // EA working hour ends

input bool TrailingStop = false;        // TrailingStop trade options
input bool TrailingStopMoved = false;
input int TrailingStopPoint = 5; 

input bool DisplayQuote = true;             // Option of display realtime price
input bool DisplayTrendLineStatus = true;   // Option of display trendline breakout status

input bool AddPosition = false;     /// Add position trade option
input int PositionStepPoint = 10;
input int PositionStepNumber = 1;
 
double dLastPrice; 
string strTrendLineName, strUpward, strDownward, strAlerted; 
int iTp, iSl, iSp, iTs, iDigiExtend, iPd, iPsp;
int iArrowRightFontSize = 8, iLineCount=0;
color colorAlerted = C'249,236,255';
int XAxis = 50, YAxis = 50, FontSize=20;


int OnInit()
{

      string strTrendlineExist="";
      
     
      ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_CREATE,true);
      ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_DELETE,true);
      
      strTrendLineName = ""; 
      
      
      for(int i=0;i<ObjectsTotal();i++)   
      {                                       
         strTrendlineExist = ObjectName(i);
         
         if (ObjectType(strTrendlineExist)==OBJ_TREND) {
         
             if (ObjectGetInteger(ChartID(),strTrendlineExist+"_ArrowLeft",OBJPROP_COLOR,0)==colorAlerted) // if the existing arrow left color = colorAlerted
               strTrendLineName += StringConcatenate("1",strTrendlineExist,";");  ///"1" for alerted trendline 
            else
            {   strTrendLineName += StringConcatenate("0",strTrendlineExist,";");  ///"0" for pending trendline 
                SetArrowLeftLabel(strTrendlineExist,DoubleToStr(ObjectGetValueByShift(strTrendlineExist,0),Digits),ObjectGetInteger(ChartID(),strTrendlineExist,OBJPROP_COLOR,0));
            }
            }
      }
      
      if (Digits==3 || Digits==5) 
         { iTp=TargetProfit*10; iSl=StopLoss*10; iSp=Slippage*10; iPd=PriceDelta*10; iTs=TrailingStopPoint*10; iDigiExtend=10; iPsp=PositionStepPoint*10; }
      else 
         { iTp=TargetProfit; iSl=StopLoss; iSp=Slippage; iPd=PriceDelta; iTs=TrailingStopPoint; iDigiExtend=1; iPsp=PositionStepPoint; }
         
      strUpward="for upward breakout"; strDownward="for downward breakout"; strAlerted="Alerted"; 
         
      dLastPrice = iClose(Symbol(),Period(),0);    
      
      DisplayTrendlineStatus();
         
   return(INIT_SUCCEEDED);

}

void OnDeinit(const int reason)
{
    int i=0;
     
    ObjectDelete("QuoteTrendline");
    ObjectDelete("SymbolTrendline");
    ObjectDelete("TimeTrendline"); 
      
    if (iLineCount!=0) { for(i=iLineCount;i>=0;i--) ObjectDelete(StringConcatenate("TrendlineStatus_",i)); } 
         
    if (reason<=1)  /// Delete trendlines & left arrows  ONLY IF this EA is removed; 
    {               /// OnDeinit reasons listed at - http://docs.mql4.com/cn/constants/namedconstants/uninit
      
   
      for(i=ObjectsTotal();i>=0;i--) /// reverse loop for any MQL4 delete functions as total quantity keep changing
      { 
        if (ObjectType(ObjectName(i))==OBJ_ARROW)//OBJ_ARROW
           ObjectDelete(ObjectName(i)); 
        if (ObjectType(ObjectName(i))==OBJ_TREND)//OBJ_TREND 
           ObjectDelete(ObjectName(i));    
      }
      }
 
}

/// EA Main function

void OnTick()
{
   
   if ( TimeHour(TimeLocal()) < HourStart || TimeHour(TimeLocal())>= HourEnd ) return;
   
   ProcessTrendlineAlert();
   
   dLastPrice = iClose(Symbol(),Period(),0); 
   
   DisplayTrendlineStatus();
   
   if (TrailingStop) ProcessTrailingStop();
    
   
}


void ProcessTrendlineAlert()
{

   ushort u_sep = StringGetCharacter(";",0);
   string strTrendlineArray[];
   
   int iTrendlineTotal=StringSplit(strTrendLineName,u_sep,strTrendlineArray);
   int i=0, j=0, ticket = 0;
   string strCurrentTrendline="";
   
   if (iTrendlineTotal<=0) return;
   
   for (i=0;i<iTrendlineTotal;i++)
      {
         strCurrentTrendline = StringSubstr(strTrendlineArray[i],1);
          
         if (StringSubstr(strTrendlineArray[i],0,1)=="1" || strCurrentTrendline=="")
            continue;
      
         if (StringSubstr(strTrendlineArray[i],0,1)=="0") {
            double dTrendlineCurrentPrice = ObjectGetValueByShift(strCurrentTrendline,0);  
            
            /// upward breakout detected
            if (dTrendlineCurrentPrice<iClose(Symbol(),Period(),0)+iPd*Point && 
                  dTrendlineCurrentPrice>dLastPrice+iPd*Point)
               {
                  StringReplace(strTrendLineName,"0"+strCurrentTrendline,"1"+strCurrentTrendline);
                  
                   if (TradeEnabled)
                    { ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,iSp,Bid-iSl*Point,Ask+iTp*Point,strCurrentTrendline,0,0,Aqua);
                      if ( AddPosition && PositionStepNumber > 0 && PositionStepPoint > 0)
                      { for (j=0;j<PositionStepNumber;j++)
                         ticket = OrderSend(Symbol(),OP_BUYSTOP,Lots,Ask+iPsp*(j+1)*Point,iSp,Bid-(iSl-iPsp*(j+1))*Point,Ask+(iTp+iPsp*(j+1))*Point,strCurrentTrendline,0,0,Aqua);   
                      }   
                    }
                    
                  if (AlertPopup) Alert(strCurrentTrendline," Breakout - UP ", Symbol(),"_",PeriodToString(Period())," ",DoubleToStr(iClose(Symbol(),Period(),0),Digits));
                  if (AlertPopup&&Sound) PlaySound("alert.wav");
                  if (MobileAlert) SendNotification(strCurrentTrendline+" Breakout " +Symbol()+" UP " + PeriodToString(Period()) + " " + DoubleToStr(iClose(Symbol(),Period(),0),Digits) );
                  if (EmailAlert) SendMail(strCurrentTrendline+" Breakout " +Symbol()+ " UP " + " " + PeriodToString(Period()) + " " + DoubleToStr(iClose(Symbol(),Period(),0),Digits),
                     Symbol()+ "_" + PeriodToString(Period()) + ": UP" + "\nCurrent Price: " + DoubleToStr(iClose(Symbol(),Period(),0),Digits) 
                     + "\nTrendline Price: " + DoubleToStr(dTrendlineCurrentPrice,Digits)  
                     + "\nServer Time: " + TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
                     
                 
               }
            
            /// downward breakout detected
            if (dTrendlineCurrentPrice>iClose(Symbol(),Period(),0)-iPd*Point &&
                  dTrendlineCurrentPrice<dLastPrice-iPd*Point)
               {
                  StringReplace(strTrendLineName,"0"+strCurrentTrendline,"1"+strCurrentTrendline);
                  
                    if (TradeEnabled)
                    { ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,iSp,Ask+iSl*Point,Bid-iTp*Point,strCurrentTrendline,0,0,Pink);
                     if ( AddPosition && PositionStepNumber > 0 && PositionStepPoint > 0)
                      { for (j=0;j<PositionStepNumber;j++)
                         ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,Bid-iPsp*(j+1)*Point,iSp,Ask+(iSl-iPsp*(j+1))*Point,Bid-(iTp+iPsp*(j+1))*Point,strCurrentTrendline,0,0,Pink);   
                      }  
                    }
                  
                  if (AlertPopup) Alert(strCurrentTrendline," Breakout - DOWN ", Symbol(),"_",PeriodToString(Period())," ",DoubleToStr(iClose(Symbol(),Period(),0),Digits));
                  if (AlertPopup&&Sound) PlaySound("alert.wav");
                  if (MobileAlert) SendNotification(strCurrentTrendline+" Breakout " +Symbol()+" DOWN " + PeriodToString(Period()) + " " + DoubleToStr(iClose(Symbol(),Period(),0),Digits) );
                  if (EmailAlert) SendMail(strCurrentTrendline+" Breakout " +Symbol()+ " DOWN " + " " + PeriodToString(Period()) + " " + DoubleToStr(iClose(Symbol(),Period(),0),Digits),
                     Symbol()+ "_" + PeriodToString(Period()) + ": DOWN" + "\nCurrent Price: " + DoubleToStr(iClose(Symbol(),Period(),0),Digits) 
                     + "\nTrendline Price: " + DoubleToStr(dTrendlineCurrentPrice,Digits)  
                     + "\nServer Time: " + TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
                     
                
               }
      }}
  
}


void DisplayTrendlineStatus()
{
   int YAxisTrendlineStatus;
   
   /// display the current symbol, period, server time and price
   if (DisplayQuote)
   {
      SetTextLabel("SymbolTrendline",Symbol()+"-"+PeriodToString(Period()), XAxis,YAxis,"Arial",FontSize,White);
      SetTextLabel("TimeTrendline",TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS), XAxis,YAxis+FontSize*1.5,"Arial",FontSize-5,White);
      SetTextLabel("QuoteTrendline",DoubleToStr(Close[0],Digits),XAxis,YAxis+FontSize*2.5,"Arial Bold",FontSize+8,Aqua);
      //YAxisTrendlineStatus=YAxis+FontSize*5.5;
   }
   //else YAxisTrendlineStatus=YAxis;
   
   YAxisTrendlineStatus=YAxis+FontSize*5.5;
   
   if (!DisplayTrendLineStatus) return;
   
   ushort u_sep = StringGetCharacter(";",0);
   string strTrendlineArray[];
   
   int iTrendlineTotal=StringSplit(strTrendLineName,u_sep,strTrendlineArray);
   int i=0;
   string strCurrentTrendline="";
   color cr;
   double dTrendlineCurrentPrice; 
   
   if (iLineCount!=0) { for(i=0;i<iLineCount;i++) ObjectDelete(StringConcatenate("TrendlineStatus_",i)); } 
   
   if (iTrendlineTotal<=0) return;
   
   iLineCount=0;
   
   for (i=0;i<iTrendlineTotal;i++)
      {
         strCurrentTrendline = StringSubstr(strTrendlineArray[i],1);
         
         if (StringSubstr(strTrendlineArray[i],0,1)=="1")  /// status display & left arrow label for alerted trendline 
            {  
               dTrendlineCurrentPrice = ObjectGetValueByShift(strCurrentTrendline,0);  /// retrieve the current trendline value 
               if (iLineCount%2==0) cr = White; else cr = Aqua;
               SetTextLabel(StringConcatenate("TrendlineStatus_",iLineCount),
                        StringConcatenate(strCurrentTrendline," - ",strAlerted),
                        XAxis,YAxisTrendlineStatus+(FontSize-5)*iLineCount,"Arial",FontSize-10,cr);
               /// arrow left label process for alerted trenline
               ObjectSetInteger(ChartID(),strCurrentTrendline+"_ArrowLeft",OBJPROP_COLOR,colorAlerted);
               ObjectSetInteger(ChartID(),strCurrentTrendline+"_ArrowLeft",OBJPROP_STYLE,STYLE_DASHDOT);
               ObjectSetInteger(ChartID(),strCurrentTrendline+"_ArrowLeft",OBJPROP_WIDTH,2);
               iLineCount++;
            }
      
         if (StringSubstr(strTrendlineArray[i],0,1)=="0") {  /// status display & left arrow label for pending trendline
            dTrendlineCurrentPrice = ObjectGetValueByShift(strCurrentTrendline,0);   
            if (dTrendlineCurrentPrice>iClose(Symbol(),Period(),0)+iPd*Point){ /// for upward breakout
               if (iLineCount%2==0) cr = White; else cr = Aqua;
               SetTextLabel(StringConcatenate("TrendlineStatus_",iLineCount),
                        StringConcatenate(strCurrentTrendline," - ",DoubleToStr(dTrendlineCurrentPrice,Digits)," ",strUpward),
                        XAxis,YAxisTrendlineStatus+(FontSize-5)*iLineCount,"Arial",FontSize-10,cr); 
               iLineCount++;         
               }
            if (dTrendlineCurrentPrice<iClose(Symbol(),Period(),0)+iPd*Point){ /// for downward breakout
               if (iLineCount%2==0) cr = White; else cr = Aqua;
               SetTextLabel(StringConcatenate("TrendlineStatus_",iLineCount),
                        StringConcatenate(strCurrentTrendline," - ",DoubleToStr(dTrendlineCurrentPrice,Digits)," ",strDownward),
                        XAxis,YAxisTrendlineStatus+(FontSize-5)*iLineCount,"Arial",FontSize-10,cr); 
               iLineCount++;         
               }
            /// arrow left label process
            ObjectSetText(strCurrentTrendline+"_ArrowLeft",DoubleToStr(dTrendlineCurrentPrice,Digits),iArrowRightFontSize,"Arial",0);
            ObjectSetInteger(ChartID(),strCurrentTrendline+"_ArrowLeft",OBJPROP_COLOR,ObjectGetInteger(ChartID(),strCurrentTrendline,OBJPROP_COLOR,0));
            ObjectMove(ChartID(),strCurrentTrendline+"_ArrowLeft",0,Time[0],dTrendlineCurrentPrice);
          }
         }
 
 
 }


void ProcessTrailingStop()
{

   double dStoploss=OrderStopLoss();
   double dTakeProfit=OrderTakeProfit();
   double dOpenPrice=OrderOpenPrice();
   bool bOrderSelect, bOrderModify;
   
   for (int i=0; i < OrdersTotal(); i++) 
      {
         bOrderSelect = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol()) continue;
      
         if (OrderType() == OP_BUY){
            if ( (dStoploss == 0.0 || dTakeProfit == 0.0) && iTp != 0 && iSl != 0) 
               bOrderModify = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask - Point * (double)iSl, Digits), NormalizeDouble(Ask + Point * (double)iTp, Digits), 0);
            if ( TrailingStopMoved && iTs>0 )  
              {                 
               if(Bid-OrderOpenPrice()>=Point*iTs && OrderStopLoss()<Bid-Point*iTs)
                  bOrderModify = OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*(iTs-iDigiExtend),OrderTakeProfit(),0);
              }
            if (!TrailingStopMoved && iTs>0)  
              {                 
               if (Bid - OrderOpenPrice() >= iTs*Point && OrderStopLoss() < OrderOpenPrice()) 
                  bOrderModify = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + iDigiExtend , OrderTakeProfit(), 0); 
              }             
         }
         
         if (OrderType() == OP_SELL){
            if ( (dStoploss == 0.0 || dTakeProfit == 0.0) && iTp != 0 && iSl != 0) 
               bOrderModify = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid + Point * (double)iSl, Digits), NormalizeDouble(Bid - Point * (double)iTp, Digits), 0);
            if ( TrailingStopMoved && iTs>0 )  
              {                 
               if(OrderOpenPrice()-Ask >= iTs*Point && OrderStopLoss()>Ask+Point*iTs)
                  bOrderModify = OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*(iTs-iDigiExtend),OrderTakeProfit(),0);
              }
            if (!TrailingStopMoved && iTs>0)  
              {                 
               if (OrderOpenPrice()-Ask >= iTs*Point && OrderStopLoss() > OrderOpenPrice()) 
                  bOrderModify = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - iDigiExtend , OrderTakeProfit(), 0); 
              }             
         }
}}




void SetArrowLeftLabel(string strTrendLineSet, string strText, color cr)
{
   ObjectCreate(ChartID(),strTrendLineSet+"_ArrowLeft",OBJ_ARROW_LEFT_PRICE,0,Time[0],ObjectGetValueByShift(strTrendLineSet,0));
   ObjectSetText(strTrendLineSet+"_ArrowLeft",strText,iArrowRightFontSize,"Arial",0);
   ObjectSetInteger(ChartID(),strTrendLineSet+"_ArrowLeft",OBJPROP_COLOR,cr);
   ObjectSetInteger(ChartID(),strTrendLineSet+"_ArrowLeft",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(ChartID(),strTrendLineSet+"_ArrowLeft",OBJPROP_WIDTH,1);
}



void SetTextLabel(string nm,string tx,int xd,int yd,string fn,int fs,color ct)
{
   
   if(ObjectFind(nm)<0)
      ObjectCreate(nm,OBJ_LABEL,0,0,0);  //--- create the Label object
   
   ObjectSet(nm,OBJPROP_STYLE,STYLE_SOLID);                
   ObjectSet(nm,OBJPROP_XDISTANCE,xd);                 
   ObjectSet(nm,OBJPROP_YDISTANCE,yd);                    
   ObjectSet(nm,OBJPROP_COLOR,ct);               
   ObjectSetText(nm,tx,fs,fn,ct);                    

}

void OnChartEvent(const int id,         // Event identifier  
                  const long& lparam,   // Event parameter of long type
                  const double& dparam, // Event parameter of double type
                  const string& sparam) // Event parameter of string type
{

   string strTrendLine;
   
   if(id==CHARTEVENT_OBJECT_DELETE)  // once the object is deleted, the object type become missing.
     {
         strTrendLine=sparam; 
      
         StringReplace(strTrendLineName,StringConcatenate("0",strTrendLine,";"),"");
         StringReplace(strTrendLineName,StringConcatenate("1",strTrendLine,";"),"");
         ObjectDelete(ChartID(),strTrendLine+"_ArrowLeft");
         
     }
     
   if(id==CHARTEVENT_OBJECT_CREATE)
     {
      strTrendLine=sparam;
      if (ObjectType(strTrendLine)==OBJ_TREND)
      {
          strTrendLineName+=StringConcatenate("0",strTrendLine,";");
          /// Add the Arrow Left Label 
          SetArrowLeftLabel(strTrendLine,DoubleToStr(ObjectGetValueByShift(strTrendLine,0),Digits),ObjectGetInteger(ChartID(),strTrendLine,OBJPROP_COLOR,0));
          
      }
     }
     
   if(id==CHARTEVENT_OBJECT_DRAG)
     {
      strTrendLine=sparam;
      if (ObjectType(strTrendLine)==OBJ_TREND)
      {
         ObjectMove(ChartID(),strTrendLine+"_ArrowLeft",0,Time[0],ObjectGetValueByShift(strTrendLine,0));
         
      }
     }  
     
}
   
  

  
string PeriodToString (int imin)
{

   string strprd;

   switch (imin)
   {

   case (1):  
   strprd="M1"; 
   break;
   case (2):  
   strprd="M2"; 
   break;
   case (3):  
   strprd="M3"; 
   break;
   case (5):  
   strprd="M5"; 
   break;
   case (15):  
   strprd="M15"; 
   break;
   case (30):  
   strprd="M30"; 
   break;
   case (60):  
   strprd="H1"; 
   break;
   case (60*4):  
   strprd="H4"; 
   break;
   case (60*24):  
   strprd="D1"; 
   break;
   case (60*24*7):  
   strprd="W1"; 
   break;
   }

   return (strprd);

}
