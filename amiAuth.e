OPT LARGE,STACK=35000,OSVERSION=37
   MODULE 'dos/dos','dos/datetime','timezone'

   MODULE '*sha256','*amiAuthPrefs','*amiAuthTotp','*amiAuthTime'
   
#ifdef UI_GAD
   MODULE '*amiAuthUI'
#elifdef UI_MUI
   MODULE '*amiAuthMUI'
#elifdef UI_REACTION
   MODULE '*amiAuthReaction'
#endif

DEF prefs:PTR TO prefs
DEF items:PTR TO LONG
DEF masterPass:PTR TO CHAR

PROC save(filename:PTR TO CHAR)
  DEF tempstr[255]:STRING
  DEF item:PTR TO totp
  DEF fh,i
  
  fh:=Open(filename,NEWFILE)
  IF fh<>0
    StringF(tempstr,'PREFS=\d\d\r\z\h[4]\n',prefs.readNtpTime,prefs.useTimezone,prefs.userOffset)
    Write(fh,tempstr,EstrLen(tempstr))
    StringF(tempstr,'PWD=\s\n',masterPass)
    Write(fh,tempstr,EstrLen(tempstr))
    FOR i:=0 TO ListLen(items)-1
      item:=items[i]
      StringF(tempstr,'\s|\s|\d\n',item.secret,item.name,item.type)
      Write(fh,tempstr,EstrLen(tempstr))
    ENDFOR
    Close(fh)
  ENDIF
ENDPROC

PROC load(filename:PTR TO CHAR)
  DEF list:PTR TO LONG
  DEF t:PTR TO totp
  DEF fh,count=0,p
  DEF tempstr[255]:STRING
  DEF offsetVal[10]:STRING

  list:=0

  StrCopy(masterPass,'')

  fh:=Open(filename,OLDFILE)
  IF fh<>0
    WHILE(ReadStr(fh,tempstr)<>-1) OR (StrLen(tempstr)>0) DO IF StrCmp(tempstr,'PREFS=',6)=FALSE THEN count++
    
    Seek(fh,0,OFFSET_BEGINNING)
    list:=List(count+10)
    WHILE(ReadStr(fh,tempstr)<>-1) OR (StrLen(tempstr)>0)
      IF StrCmp(tempstr,'PREFS=',6)
        prefs.readNtpTime:=tempstr[6]-48
        prefs.useTimezone:=tempstr[7]-48
        StrCopy(offsetVal,'$')
        StrAdd(offsetVal,tempstr+8,4)
        prefs.userOffset:=Val(offsetVal)
        CONT TRUE
      ELSEIF StrCmp(tempstr,'PWD=',4)
        StrCopy(masterPass,tempstr+4)
        CONT TRUE
      ENDIF
      IF StrLen(tempstr)>0
        NEW t.create()
        IF (p:=InStr(tempstr,'|'))>=0
          StrCopy(t.secret,tempstr,p)
          StrCopy(t.name,tempstr+p+1)
          IF (p:=InStr(t.name,'|'))>=0
            t.type:=Val(t.name+p+1)
            SetStr(t.name,p)
          ENDIF
        ELSE
          StrCopy(t.secret,tempstr,100)
          StrCopy(t.name,'')
        ENDIF
      ENDIF
      
      ListAddItem(list,t)
    ENDWHILE
    Close(fh)
  ENDIF
ENDPROC list

PROC main() HANDLE
  DEF i
  DEF item:PTR TO totp
  DEF timedata:PTR TO timedata     
  NEW prefs
  prefs.readNtpTime:=1
  prefs.useTimezone:=1
  prefs.userOffset:=0

  NEW timedata
  
  masterPass:=String(64)

  items:=load('PROGDIR:totp.cfg')
  
  calcUTCOffset(timedata,prefs)
  timedata.oldtime:=0

  showMain(timedata,prefs,masterPass,{items})

  save('PROGDIR:totp.cfg')
EXCEPT DO 
  FOR i:=0 TO ListLen(items)-1
    item:=items[i]
    END item
  ENDFOR
  DisposeLink(items)
  
  END prefs
  END timedata
  DisposeLink(masterPass)
ENDPROC
