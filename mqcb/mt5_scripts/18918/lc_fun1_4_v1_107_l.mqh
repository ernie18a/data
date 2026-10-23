//======================================================================================================
//    LibreConver Function1_4 v1.107 MQL4
//    Основные функции алгоритма
//    Librecoin (c)2014-2017     
//======================================================================================================
#property strict
//======================================================================================================
//    MAIN FUNCTIONS
//------------------------------------------------------------------------------------------------------
//
//======================================================================================================
//    StringConverter() - Script program start function                                    
//======================================================================================================
bool StringConverter(   int      iMode,
                        string   iInpStr,
                        string   &iOutStr){
int
   n;
bool 
   iResult=true;
   iOutStr="";
   {if((StringFind(iInpStr,",",0)<0)&&(iMode<=3))
   {
      iResult=false;
      return(iResult);
   }}//if(StringFind(iInpStr,",",0)<0)
//-----
string   iDateTim="";
string   iDate=gDat;
string   iYear=gYear;
string   iMou=gMoun;
string   iDay=gDay;
string   iTim=gTim;
string   iEvent="";
string   iCountry="";
string   iCouN="";
string   iCur="";
string   iVolatility="";
string   iForecast="";
string   iImpact="";
string   iImpN="";
string   iActual="";
string   iPrevious="";
int      nCountry=0;
int      nnCountry=0;
//----- Календарь investing html
   {if(iMode==4)
   {
      //Строка даты нового дня - заносим дату в глобал, для установки дат недатированных событий
      string iTheDay="";
      int posDay=StringFind(iInpStr,"<td colspan=\"8\" class=\"theDay\" id=\"theDay");
      {if(posDay<0)
      {
         posDay=StringFind(iInpStr,"<td colspan=\"9\" class=\"theDay\" id=\"theDay");
      }}//if(posDay<0)
      {if((posDay>=0)&&(TagContent(iInpStr,"id=\"theDay","/td>",iTheDay)))
      {
         iResult=TagContent(iTheDay,", ","<",iTheDay);
         gMoun=StringSubstr(iTheDay,0,StringFind(iTheDay," "));
         gMoun=StringSubstr(iMounthN,StringFind(iMounthN,gMoun,2)-2,2);
         iResult=TagContent(iTheDay," ",",",gDay);
         gYear=StringSubstr(iTheDay,StringFind(iTheDay,", ")+2);
         iTheDay=gYear+"."+gMoun+"."+gDay+" 00:00:00";
         TimeToStruct(StringToTime(iTheDay),gDateTime);
         iResult=TagDelete(iInpStr,"<tr>","</tr>");
         return(false);
      }}//if(TagContent(InpStrBuff,"id=\"theDay","/td>",iTheDay))

      int dFormat=0;
      dFormat=(TagContent(iInpStr,"event_timestamp=\"","\">",iDate))
               ?(1)
               :(
                  (TagContent(iInpStr,"data-event-datetime=\"","\">",iDate))
                  ?(2)
                  :(0)
                  );
      {if((dFormat==1)||(dFormat==2))                                         //если один из распознаваемых форматов
      {
         //----- Date Time
         if(dFormat==2)StringReplace(iDate,"/",".");//в формате апреля 2016
         if(dFormat==1)StringReplace(iDate,"-",".");//в формате ранее апреля 2016
         iDateTim=TimeToString(StringToTime(iDate),TIME_DATE|TIME_MINUTES);
         TimeToStruct(StringToTime(iDate),gDateTime);
         iResult=TagDelete(iInpStr,"<tr id=\"eventRowId_","\">");                     
         iResult=TagDelete(iInpStr,"<td class=","</td>");                         
         iInpStr=StringSubstr(iInpStr,StringFind(iInpStr,"<td"));
         //----- Country
         iResult=TagContent(iInpStr,"<span title=\"","\" class=\"",iCountry);
         //----- Currency
         iResult=TagContent(iInpStr,"</span>","</td>",iCouN);
         iResult=TagDelete(iInpStr,"<td class=","</td>");                           
         iInpStr=StringSubstr(iInpStr,StringFind(iInpStr,"<td"));
         //----- Impact
         iResult=TagContent(iInpStr,"noWrap\" title=\"","\" data-img_key",iVolatility);
         {if(!iResult){iResult=TagContent(iInpStr,"title=\"","\">",iVolatility);}}
         //----- Impact N
         iImpN=StringSubstr(iImpactMN,StringFind(iImpactMN,iVolatility,1)-1,1);
         iResult=TagDelete(iInpStr,"<td class=","</td>");                            
         iInpStr=StringSubstr(iInpStr,StringFind(iInpStr,"<td"));
         //----- Тип события
         iResult=TagDelete(iInpStr,"<span","</span>");                              //Удаляем тип события
         //----- Event
         iResult=TagContent(iInpStr,"target=\"_blank\">","</a>",iEvent);
         {if(!iResult){iResult=TagContent(iInpStr,"event\">","</td",iEvent);}}
         iResult=TagDelete(iInpStr,"<td class=","</td>");                              //Удаляем дату
         n=StringReplace(iEvent,"&amp;","");
         iInpStr=StringSubstr(iInpStr,StringFind(iInpStr,"<td"));
         //----- Actual
         iResult=TagContent(iInpStr,"id=\"eventActual_","/td>",iActual);
         iResult=TagContent(iActual,"\">","<",iActual);
         n=StringReplace(iActual,"&nbsp;","");
         iResult=TagDelete(iInpStr,"<td class=","</td>");                              //Удаляем дату
         iInpStr=StringSubstr(iInpStr,StringFind(iInpStr,"<td"));
         //----- Forecast
         iResult=TagContent(iInpStr,"id=\"eventForecast_","/td>",iForecast);
         iResult=TagContent(iForecast,"\">","<",iForecast);
         n=StringReplace(iForecast,"&nbsp;","");
         iResult=TagDelete(iInpStr,"<td class=","</td>");                              //Удаляем дату
         iInpStr=StringSubstr(iInpStr,StringFind(iInpStr,"<td"));
         //----- Previous &amp;
         iResult=TagContent(iInpStr,"id=\"eventPrevious_","/td>",iPrevious);
         iResult=TagContent(iPrevious,"\">","<",iPrevious);
         n=StringReplace(iPrevious,"&nbsp;","");
       }else{//Если даты нет но возможно "All Day"
         {if(TagContent(iInpStr,"<td class=\"first left\">","</td>",iDate)&&(iDate=="All Day"))                         //если есть дата тэг
         {
            //----- Date Time
            iDateTim=TimeToString(StructToTime(gDateTime),TIME_DATE|TIME_MINUTES);
            iResult=TagDelete(iInpStr,"<tr id=\"eventRowId_","</td>");                        
            iInpStr=StringSubstr(iInpStr,StringFind(iInpStr,"<td"));
            //----- Country
            iResult=TagContent(iInpStr,"<span title=\"","\" class=\"",iCountry);
            //----- Currency
            iCouN=StringSubstr(iCountryN,StringFind(iCountryN,iCountry,3)-3,3); 
            iResult=TagDelete(iInpStr,"<td class=","</td>");                       
            iInpStr=StringSubstr(iInpStr,StringFind(iInpStr,"<td"));
            //----- Impact
            iResult=TagContent(iInpStr,"<span class=","</td>",iVolatility);
            iResult=TagContent(iVolatility,"\">","</span>",iVolatility);
            //----- Impact N
            iImpN=StringSubstr(iImpactMN,StringFind(iImpactMN,iVolatility,1)-1,1);
            iResult=TagDelete(iInpStr,"<td class=","</td>");                             
            iInpStr=StringSubstr(iInpStr,StringFind(iInpStr,"<td"));
         //----- Event
            iResult=TagContent(iInpStr,"class=\"","td>",iEvent);
            iResult=TagContent(iInpStr,"\">","</",iEvent);
            //----- Previous
            iPrevious="";
            //----- Forecast
            iForecast="";
            //----- Actual
            iActual="";                        
            //Print("4. iDate=",iDate," iDateTim=",iDateTim," iStr=",iInpStr);
         }else{//Если даты нет и нет "All Day"
            iOutStr="";
            return(false);
         }}//if(TagContent(iInpStr,"<span class=\"date\">","</td>",iMouDay))
      }}//if(TagContent(iInpStr,"<span class=\"date\">","</td>",iMouDay))
      iOutStr=iDateTim+";"+iEvent+";"+iCountry+";"+iCouN+";"+iImpN+";"+iPrevious+";"+iForecast+";"+iActual+";";//
      //Print("iOutStr=",iOutStr);
      //Print("3. iRes=",iResult," iPrevious=",iPrevious," iStr=",iInpStr);
      return(true);
   }}//if(iMode==4)
//-----
   return(false);
}//StringConverter()
//
//======================================================================================================
//    StringNormal() - удаление из строки не цифровых символов                                    
//======================================================================================================
void StringNormal(string &iInpStr){
string
   Cifr="0123456789.-KMBT$|%";
   StringTrimLeft(iInpStr);
   StringTrimRight(iInpStr);
   StringToUpper(iInpStr);
   //Print(iInpStr);
   {for(int i=StringLen(iInpStr)-1;i>=0;i--)
   {
      {if(StringFind(Cifr,StringSubstr(iInpStr,i,1),0)<0)
      {
         //Print(StringSubstr(iInpStr,i,1));
         iInpStr=StringSetChar(iInpStr,i,'#');
      }}//if(StringFind(Cifr,StringSubstr(iInpStr,i,1),0)<0)
   }}//for(int i=StringLen(iInpStr)-1;i>=0;i--)
   //Print(StringReplace(iInpStr,"#",""));
   StringReplace(iInpStr,"#","");
   return;
}//StringNormal()
//
//======================================================================================================
//    NormalizeFile() - Удаление из файла повторов и косяков                                
//======================================================================================================
bool NormalizeFile(string iInFileName,string iTmpFileName){
string
   OutStr="";
uchar
   LastChar=char(0),
   InpChar=char(0);   
int
   n=0,
   CharOperation=0;//   0/1/2/3 - без изменений/пропустить/заменить/конец строки      
//-----    
   //int InFileHandle = FileOpen(iInFileName,FILE_READ|FILE_BIN|FILE_TXT|FILE_ANSI|FILE_COMMON,',');
   int InFileHandle = FileOpen(iInFileName,FILE_READ|FILE_BIN|FILE_COMMON,',');
   {if ((InFileHandle!=INVALID_HANDLE)&&(FileSize(InFileHandle)!=0))
   {
      ResetLastError(); 
      int OutFileHandle=FileOpen(iTmpFileName,FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_COMMON,','); 
      {if(OutFileHandle!=INVALID_HANDLE) 
      { 
         bool NewString=true;
         {while(!FileIsEnding(InFileHandle))
         {
            CharOperation=0;//Передать на выход по умолчанию
            ResetLastError(); 
            InpChar=(uchar)FileReadInteger(InFileHandle,1);
            //Print(InpChar,"=",CharToString(InpChar));
            {if(CharToString(InpChar)==">")//Конец тега - конец строки
            {
               CharOperation=3;
            }}//if(CharToString(InpChar)==">")
            {if(CharToString(InpChar)==" ")//Пробел...
            {
               {if(CharToString(LastChar)==" ")//... после пробела
               {
                  CharOperation=1;//Пропустить
               }else{
                  CharOperation=0;//Передать на выход
               }}//if(CharToString(LastChar)==" ") 
            }}//if(CharToString(InpChar)==" ")
            LastChar=InpChar;
            {switch(CharOperation)
            { 
               case 1://Пропустить 
                  //Просто ничего не делать
                  break; 
               case 2://Заменить
                  //Пока не известно, что можно сразу заменять
                  break; 
               case 3://Конец строки - запись строки в файл 
                  ResetLastError(); 
                  OutStr=OutStr+CharToString(InpChar);
                  //Подчистка
                  n=StringReplace(OutStr,"\t","");//Удаляем табуляции
                  n=StringReplace(OutStr,"\n","");//удаляем возвраты каретки
                  n=StringReplace(OutStr,"\r","");//удаляем переводы строк
                  n=StringReplace(OutStr,"\0","");
                  n=StringReplace(OutStr,"&nbsp;","");//&nbsp;
                  n=StringReplace(OutStr,"&amp;","");//&amp;
                  n=StringReplace(OutStr,"&lt;","");//&lt;
                  n=StringReplace(OutStr,"&#039;","");//&#039;
                  n=StringReplace(OutStr," <","<");//удаляем пробел перед тегом
                  n=StringReplace(OutStr,"  "," ");//удаляем двойные пробелы
                  OutStr=((StringGetChar(OutStr,0)==StringGetChar(" ",0))?(StringSubstr(OutStr,1)):(OutStr));//удаляем пробел в начале строки
                  //OutStr=OutStr+"\n\r";//<ВК><ПС>
                  OutStr=OutStr+"\n";//<ВК>
                  //Print("OutStr=",OutStr);
                  if(FileWriteString(OutFileHandle,OutStr)==0)return(false);
                  OutStr="";
                  break; 
               default://0 - Передать без изменений на выход 
                  OutStr=OutStr+CharToString(InpChar);
                  //Print("OutStr=",OutStr);
                  break; 
            }}//switch(CharOperation)
         }}//while(!FileIsEnding(file_handle))
         //Закрытие выходного файла
         ResetLastError(); 
         FileClose(OutFileHandle); 
         //Закрытие входного файла
         ResetLastError(); 
         FileClose(InFileHandle); 
      }else{
         Print("NormalizeFile>> Операция FileOpen Write неудачна, ошибка ",GetLastError()); 
         return(false);
      }}//if(OutFileHandle!=INVALID_HANDLE)
   }else{
      Print("NormalizeFile>> Операция FileOpen Read неудачна, ошибка ",GetLastError()); 
      return(false);
   }}//if ((InFileHandle!=INVALID_HANDLE)&&(FileSize(InFileHandle)!=0))
//-----
   return(true);
}//NormalizeFile()
