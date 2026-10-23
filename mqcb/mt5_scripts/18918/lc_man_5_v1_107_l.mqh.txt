//======================================================================================================
//    LibreConver Main_5 v1.007 MQL5
//    Модуль обработки событий
//    LibreCoin (c)2014-2017      
//======================================================================================================
#property strict
//======================================================================================================
//    EVENT PROCESSING MODULE
//------------------------------------------------------------------------------------------------------
//
//======================================================================================================
//    On_Start() - Script program start function                                    
//======================================================================================================
void On_Start(){
//-----
   string StringBuff="";
   ResetLastError(); 
   if(!NormalizeFile(InFileName,TempFileName))return;//Нормализация файла
   Print("done.....");
   int InFileHandle = FileOpen(TempFileName,FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON,',');
   {if ((InFileHandle!=INVALID_HANDLE)&&(FileSize(InFileHandle)!=0))
   {
      int ConverterMode=0;//Преобразование невозможно
      ResetLastError(); 
      int OutFileHandle=FileOpen(OutFileName,FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_COMMON,';'); 
      {if(OutFileHandle!=INVALID_HANDLE) 
      { 
         //Цикл идентификации формата
         {while(!FileIsEnding(InFileHandle))
         {
            ResetLastError(); 
            StringBuff=FileReadString(InFileHandle);
            {if((StringFind(StringBuff,"Economic Calendar - Investing.com",0)>=0)&&(ConverterMode==0))
            {
               ConverterMode=4;//Календарь investing
               Print("*********** MODE4 investing parsing ***********");
               //continue;
            }}//if(StringFind(StringBuff,"Date,Event,Impact",0)>=0) 
            //Конвертация и запись строки MODE1-3 преобразование CSV файлов
            //----- MODE4 investing parsing
            {if(ConverterMode==4)
            {
               FileConverter4(InFileHandle,OutFileHandle);
            }}//if(StringConverter(StringBuff,StringBuff))
         }}//while(!FileIsEnding(file_handle))
         //Закрытие выходного файла
         ResetLastError(); 
         FileClose(OutFileHandle); 
         //Закрытие входного файла
         ResetLastError(); 
         FileClose(InFileHandle); 
      }else{
         Print("Операция FileOpen Write неудачна, ошибка ",GetLastError()); 
      }}//if(OutFileHandle!=INVALID_HANDLE)
   }else{
      Print("Операция FileOpen Read неудачна, ошибка ",GetLastError()); 
   }}//if ((InFileHandle!=INVALID_HANDLE)&&(FileSize(InFileHandle)!=0))
}//On_Start()
