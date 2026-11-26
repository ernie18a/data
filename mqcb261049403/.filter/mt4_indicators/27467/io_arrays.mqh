//+------------------------------------------------------------------+
//|                                                    io_arrays.mqh |
//|                        Copyright 2017, NetrillioN Software Corp. |
//|                                       https://www.netrillion.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, NetrillioN Software Corp."
#property link      "https://www.netrillion.com"
#property strict
#include <BreakPoint.mqh>
string kumotempfile="ichimoku2_kumo_data.txt";
int kumofilepos=1;
//+------------------------------------------------------------------+
//| ArrayToString
//+------------------------------------------------------------------+
//this is will convert an array to a delimited string.
string ArrayToString(string& TwoDimensionArray[][])
  {
   string str;
   int i=0;
   int j=0;
   int arrsz_row=ArrayRange(TwoDimensionArray,0);
   int arrsz_colum=ArrayRange(TwoDimensionArray,1);
   for(i=0; i<arrsz_row; i++)
     {
      for(j=0;j<arrsz_colum-1;j++)
        {
         //str="index "+IntegerToString(i)+": "; 
         str+=TwoDimensionArray[i][j]+",";
         //Print("\n TwoDimensionArray "+str);
        }
      if(i<arrsz_row-1)
        {
         str+=TwoDimensionArray[i][arrsz_colum -1]+">";
        }
      else
        {
         str+=TwoDimensionArray[i][arrsz_colum -1];
        }
     }
   return str;
  }
//+------------------------------------------------------------------+
//| End of ArrayToString 
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| WriteStringToPosition 
//+------------------------------------------------------------------+
// this will insert a string into a master string at a specified position in a file.
void WriteStringToPosition(string AnyString,int Position_In_File)
  {
   string astr,str,b_str,delim="|";
   string row[];
   string ostr_arr[][2];
   int arrsz=0,pos=0,dpos=-1,op=0;

//read file into string
   astr=FileReader(kumotempfile);

//break string into array
   arrsz=BreakString(astr,delim,row);
   pos=arrsz;
   
//calculate the original position within the string structure in relation to the delimiter
  ArrayResize(ostr_arr,arrsz);  
   while(pos>0)
   {  
    pos--;   
    dpos = StringFind(astr,row[pos],0);
       if(dpos>=0)
       { 
           if(dpos>0)
           {  
           b_str = StringSubstr(astr,0,(dpos) );//this is the part of the file's string coming before the data
           op = StringCount(b_str,delim);// count number times delimiter appears before the data.
           ostr_arr[pos][0] = row[pos];
           ostr_arr[pos][1] = IntegerToString(op);
           }
           else
           {
            op = 0;
            ostr_arr[pos][0] = row[pos];
            ostr_arr[pos][1] = IntegerToString(op);
           }
       } 
   }
  
 //place data in the same order as in when it was in the file  
ArrayResize(row,0);
ArrayResize(row,6);
 pos=0;
   while(pos<arrsz)
   {  
    op = StrToInteger(ostr_arr[pos][1]);
    row[op] = ostr_arr[pos][0];
    pos++;
   }   
   
//derive big string from all elements and marker to the end except last.
   if(arrsz==6)
     {
    
      //assign string to array at index specified as position.
      if(Position_In_File<6)row[Position_In_File]=AnyString;
      str+=row[0]+"|";
      str+=row[1]+"|";
      str+=row[2]+"|";
      str+=row[3]+"|";
      str+=row[4]+"|";
      str+=row[5];
     }
   else
     {
      //assign string to array at index specified as position.
      if(Position_In_File>=0 && Position_In_File<6)row[Position_In_File]=AnyString;
      str+=row[0]+"|";
      str+=row[1]+"|";
      str+=row[2]+"|";
      str+=row[3]+"|";
      str+=row[4]+"|";
      str+=row[5];      
      /*
      str+=row[0]+"|";
      str+=row[1]+"|";
      str+=row[2]+"|";
      str+=row[3]+"|";
      str+=row[4]+"|";
      str+=row[5];
      */
     } 
     if(Position_In_File>=0 && Position_In_File<6)FileWriter(kumotempfile,str,1);
  }
//+------------------------------------------------------------------+
//|  End of WriteStringToPosition  
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|  SaveArrayToFilePosition  
//+------------------------------------------------------------------+
// This will write a 2D array to file in a specified position.
// The first position is 0 and the last is 5.
void SaveArrayToFilePosition(string& TwoDimensionArray[][],int Position_In_File)
  {
//convert array to a string
   string array_str=ArrayToString(TwoDimensionArray);

//write array to file in the specified position.
   WriteStringToPosition(array_str,Position_In_File);
  }
//+------------------------------------------------------------------+
//|  End of SaveArrayToFilePosition  
//+------------------------------------------------------------------+





//+------------------------------------------------------------------+
//|  FileWriter  
//+------------------------------------------------------------------+
//FileWriter writes a string to a file
int FileWriter(string filename,string line,int line_number)
  {
   int fp=FileOpen(filename,FILE_WRITE);
   if(fp!=INVALID_HANDLE)
     {
      FileSeek(fp,0,SEEK_SET);
      FileWriteString(fp,line);
      FileClose(fp);
     }
   return(fp);
  }
//+------------------------------------------------------------------+
//|  End of FileWriter  
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| FileReader 
//+------------------------------------------------------------------+
//FileReader reads a string from a file. the entire last line of the file is returned.
string FileReader(string filename)
  {
   string str= "";
   int count = 1;
   int line=0;
   int fp=FileOpen(filename,FILE_READ);
   if(fp!=INVALID_HANDLE)
     {
      FileSeek(fp,0,SEEK_SET);
      while(!FileIsEnding(fp) && line<count)
        {
         str=FileReadString(fp,0);
         line++;
        }
     }
   FileClose(fp);
   return str;
  }
//+------------------------------------------------------------------+
//|  End of FileReader   
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|  LoadArrayFromFilePosition  
//+------------------------------------------------------------------+
void LoadArrayFromFilePosition(string& TwoDimensionArray[][],int Position_In_File)
  {
   string astr,arraystr,b_str,delim="|";
   string row[];
   string ostr_arr[][2];
   int arrsz=0,pos=0,dpos=-1,op=0;

//read file position to a string
   astr=FileReader(kumotempfile);

//break string into array
   arrsz=BreakString(astr,delim,row);
   pos=arrsz;
   
   //calculate the original position within the string structure in relation to the delimiter
     ArrayResize(ostr_arr,arrsz);  
      while(pos>0)
      {  
       pos--;   
       dpos = StringFind(astr,row[pos],0);
          if(dpos>=0)
          { 
              if(dpos>0)
              {  
              b_str = StringSubstr(astr,0,(dpos) );//this is the part of the file's string coming before the data
              op = StringCount(b_str,delim);// count number times delimiter appears before the data.
              ostr_arr[pos][0] = row[pos];
              ostr_arr[pos][1] = IntegerToString(op);
              }
              else
              {
               op = 0;
               ostr_arr[pos][0] = row[pos];
               ostr_arr[pos][1] = IntegerToString(op);
              }
          } 
      }
     
    //place data in the same order as in when it was in the file  
   ArrayResize(row,0);
   ArrayResize(row,6);
    pos=0;
      while(pos<arrsz)
      {  
       op = StrToInteger(ostr_arr[pos][1]);
       row[op] = ostr_arr[pos][0];
       pos++;
      }    
     if(arrsz>Position_In_File && Position_In_File>=0 && Position_In_File<6 )
     {
      arraystr=row[Position_In_File];
      LoadStringToArray(arraystr,TwoDimensionArray);
     // BreakPoint("","","",true,"arrsz",IntegerToString(arrsz),"arraystr",arraystr,"astr",astr);
     }
  }
//+------------------------------------------------------------------+
//|  End of LoadArrayFromFilePosition  
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| LoadStringToArray 
//+------------------------------------------------------------------+
void LoadStringToArray(string Delimited_String, string& TwoDimensionArray[][])
  {
   int i=0,j=0,colsize=0;
   string colum[];
   string row[];
   string to_split=Delimited_String;   // A string to split into substrings
   string sep=">";                // A separator as a character
   ushort u_sep;                  // The code of the separator character 

   int arrsz_row=ArrayRange(TwoDimensionArray,0);
   int arrsz_colum=ArrayRange(TwoDimensionArray,1);

//--- Get the separator code
   u_sep=StringGetCharacter(sep,0);
//--- Split the string to substrings
   //int k=StringSplit(to_split,u_sep,row);
   int k = BreakString(to_split,sep,row);
      if(k==0)
      {
       k=1;
       ArrayResize(row,k);
       row[0] = to_split;
      }
   ArrayResize(TwoDimensionArray,k);
   int l=0;
//PrintFormat("Strings obtained: %d. Used separator '%s' with the code %d",k,sep,u_sep);
   if(k>0)
     {

      for(i=0;i<k;i++)
        {
         to_split=row[i];
         sep=",";
         u_sep=StringGetCharacter(sep,0);

         //l=StringSplit(to_split,u_sep,colum);
         l=BreakString(to_split,sep,colum);
         colsize=ArrayRange(colum,0);
         j=0;
            while(i<k && j<colsize)
            {            
             TwoDimensionArray[i][j]=colum[j];
             j++;
            } 
           /*
           for(int j=0; j<l; j++)
           {
            TwoDimensionArray[i][j]=colum[j];
           }
          */ 
        }
     }
  }
//+------------------------------------------------------------------+
//| End of LoadStringToArray 
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|  BreakString  
//+------------------------------------------------------------------+
// this will break a delimited string into a two dimension array.
int BreakString(string to_split, string delimiter_character, string& AnArray[])
  {
   int dpos=-1,asize=-1,dlength=StringLen(delimiter_character);
   string subtracted_str,remaining_str;
   ArrayResize(AnArray,0);//empty array contents
   
   //get delimiter position in string
   dpos = StringFind(to_split,delimiter_character,0);
      if(dpos>=0)
      {
          if(dpos>0)
          { 
           //get substrings  
           subtracted_str = StringSubstr(to_split,0,dpos); 
           remaining_str = StringSubstr(to_split,(dpos+dlength) );
          
           asize = ArrayRange(AnArray,0);
           ArrayResize(AnArray,(asize+1) );//increase size for substring
           AnArray[asize] = subtracted_str;
          }
          else
          {
           remaining_str = StringSubstr(to_split,(dpos+dlength) );
          }
      }
      else
      {
       //asize = ArrayRange(AnArray,0);
       //ArrayResize(AnArray,(asize+1) );//increase size for substring
       //AnArray[asize] = to_split;           
      }       
      while(dpos>=0)
      {  
       //get delimiter position in string
       dpos = StringFind(remaining_str,delimiter_character,0);            
          if(dpos>=0)
          {
              if(dpos>0)
              {           
               //get substrings  
               subtracted_str = StringSubstr(remaining_str,0,dpos); 
               remaining_str = StringSubstr(remaining_str,(dpos+dlength));   
               asize = ArrayRange(AnArray,0);
               ArrayResize(AnArray,(asize+1) );//increase size for substring
               AnArray[asize] = subtracted_str;  
              }
              else
              {
               remaining_str = StringSubstr(remaining_str,(dpos+dlength) );
              }              
          } 
          else
          {
              if(remaining_str!="")
              {
               asize = ArrayRange(AnArray,0);
               ArrayResize(AnArray,(asize+1) );//increase size for substring
               AnArray[asize] = remaining_str; 
              }          
          }    
      }
   asize = ArrayRange(AnArray,0);   
   return asize;
  }
//+------------------------------------------------------------------+
//|  End of BreakString  
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|  StringCount  
//+------------------------------------------------------------------+
// This will count the number of occurrencies of a substring.
int StringCount(string SourceString, string Substring)
  {
   int cnt=0,dpos=-1,Substringlength=StringLen(Substring);
   string search_str = SourceString;
   
   //get substring position in string
   dpos = StringFind(search_str,Substring,0);
      if(dpos>=0)
      {
       cnt++;
       search_str = StringSubstr(search_str,(dpos+Substringlength) );
          while(dpos>=0)
          { 
           //get substring position in string
           dpos = StringFind(search_str,Substring,0);          
              if(dpos>=0)
              {
               cnt++;
               search_str = StringSubstr(search_str,(dpos+Substringlength) );
              }
          }
      }
   return cnt;
  }
//+------------------------------------------------------------------+
//|  End of StringCount  
//+------------------------------------------------------------------+



