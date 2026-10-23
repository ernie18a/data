//+==================================================================+
//|                                                 Spread_Write.mq4 |
//|                                 Copyright © 2011, Yevgeny Getman |
//+==================================================================+
#property copyright "Yevgeny Getman"
#property indicator_chart_window

extern string csv_filename="my_spread_data";
//+------------------------------------------------------------------+
int init()
  {
   DrawFxLbl("msg"+csv_filename,"Waiting for next bar...",0,4,25,10,"Times New Roman",White,false);
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   int handle;
   double Spread=MarketInfo(Symbol(),MODE_SPREAD);
   double AdjSpread=Spread/(0.0001/MathPow(10,-Digits));
   DrawFxLbl("spread","Current Spread: "+DoubleToStr(AdjSpread,1)+" pip",0,4,12,10,"Times New Roman",White,false);
//--------------------------------------------------+
   if(Volume[0]==1)
     {
      handle=FileOpen(csv_filename+".csv",FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
      if(handle>0)
        {
         DrawFxLbl("msg"+csv_filename,"Writing data to file...",0,4,26,10,"Times New Roman",White,false);
         DrawFxLbl("file"+csv_filename,"terminal/experts/files/",0,3,40,8,"Courier",White,false);
         DrawFxLbl("file2"+csv_filename,csv_filename+".csv",0,187,40,8,"Courier",DeepSkyBlue,false);
         //-----------------------------------------------------------------------------------------+
         FileSeek(handle,0,SEEK_END);
         FileWrite(handle,Time[0],AdjSpread);
         FileClose(handle);
        }
      else if(handle<1)
        {
         DrawFxLbl("error","error: "+DoubleToStr(GetLastError(),0),0,4,25,10,"Times New Roman",Red,false);
         Print("error",GetLastError());
         return(0);
        }
     }
//--------------------------------------------------+    
   return(0);
  }
//------------------- Draw Fixed Label Function ------------------------|
void DrawFxLbl(string OName,string Capt,int Corner,int DX,int DY,int FSize,string Font,color FColor,bool BG)
  {
   if(ObjectFind(OName)<0)
      ObjectCreate(OName,OBJ_LABEL,0,0,0);
   ObjectSet(OName,OBJPROP_CORNER,Corner);
   ObjectSet(OName,OBJPROP_XDISTANCE,DX);
   ObjectSet(OName,OBJPROP_YDISTANCE,DY);
   ObjectSet(OName,OBJPROP_BACK,BG);
   ObjectSetText(OName,Capt,FSize,Font,FColor);
  }
//----------------------------------------------------------------------|

//+-------------------+
int deinit()
  {
   ObjectsDeleteAll();
   return(0);
  }
//+-------------------+
