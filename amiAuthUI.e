OPT MODULE

   MODULE 'tools/easygui','libraries/gadtools','intuition/intuition',
   'images/led','intuition/imageclass','gadtools','dos/dos','plugins/ticker','exec/nodes','exec/lists',
   'dos/datetime','socket','net/netdb','net/in','net/socket','timezone','tools/constructors','plugins/password'
   
   MODULE '*amiAuthTotp','*amiAuthPrefs','*amiAuthTime','*sha256'

#date verstring '$VER: AmiAuthenticator (GadTools) 0.1.0 (%d.%aM.%Y)' 

CONST YSIZE=44

OBJECT scrollArea OF plugin
  scrollTop:INT
  ledbase:LONG
  gadtoolsbase:LONG
  visInfo:LONG
ENDOBJECT

DEF sa:PTR TO scrollArea
DEF maingh,itemsgh:PTR TO guihandle,prefsgh,itemaddgh,passwdgh:PTR TO guihandle,timegad,scrgad
DEF prefsgad1,prefsgad2,prefsgad3,prefstxt1
DEF listgad:PTR TO LONG
DEF lvsel
DEF totpItems:PTR TO LONG
DEF uiPrefs:PTR TO prefs
DEF uiTimedata:PTR TO timedata
DEF newitems:PTR TO LONG
DEF l:PTR TO lh
DEF btnMoveUp,btnMoveDown,btnEdit,btnDel
DEF masterPass1,masterPass2
DEF forceRefresh

PROC scrollArea() OF scrollArea
  DEF scr
  self.scrollTop:=0
  self.ledbase:=OpenLibrary('images/led.image',37)
  IF self.ledbase=NIL THEN self.ledbase:=OpenLibrary('PROGDIR:led.image',37)
  IF self.ledbase=NIL THEN Throw("LIB","led")
  
  self.gadtoolsbase:=OpenLibrary('gadtools.library',0)
  IF self.gadtoolsbase=NIL THEN Throw("LIB","gadt")
  
  scr:=LockPubScreen(NIL)
  gadtoolsbase:=self.gadtoolsbase
  self.visInfo:=GetVisualInfoA(scr, [TAG_END])
  UnlockPubScreen(NIL,scr)
ENDPROC

PROC end() OF scrollArea
  IF self.visInfo THEN FreeVisualInfo(self.visInfo)
  IF self.ledbase THEN CloseLibrary(self.ledbase)
  IF self.gadtoolsbase THEN CloseLibrary(self.gadtoolsbase)
ENDPROC

PROC scroll(newTop) OF scrollArea
  self.scrollTop:=newTop
  self.redisplay()
ENDPROC

PROC updateValues(systime,systicks,force) OF scrollArea
  DEF i
  DEF item:PTR TO totp
  DEF newtime,newticks
  DEF updated=FALSE
  FOR i:=0 TO ListLen(totpItems)-1
    item:=totpItems[i]
    newtime:=Div(systime,item.interval)
    newticks:=systicks
    newticks:=newticks+Mul(systime-Mul(newtime,item.interval),50)

    IF item.updateValues(0,newtime,newticks,force)
      updated:=TRUE
    ENDIF
  ENDFOR
  IF force OR updated THEN sa.redisplay()
ENDPROC

PROC min_size(ta,fh) OF scrollArea IS 170,72

PROC will_resize() OF scrollArea IS RESIZEX OR RESIZEY

PROC render(ta,x,y,xs,ys,w:PTR TO window) OF scrollArea 
  DEF i,idx,wid
  DEF item:PTR TO totp
  DEF led,tot
  
  SetAPen(w.rport,0)
  RectFill(w.rport,x,y,x+xs,y+ys)
  SetAPen(w.rport,1)

  tot:=ListLen(totpItems)-(ys/YSIZE)
  IF tot<0 THEN tot:=0
  IF tot=1 THEN tot:=2
  setscrolltotal(self.gh,scrgad,tot)
  IF self.scrollTop>tot
    setscrolltop(self.gh,scrgad,tot)
    self.scrollTop:=tot
  ENDIF

  led:=NewObjectA( NIL, 'led.image',[
                IA_FGPEN,             2,
                IA_BGPEN,             0,
                IA_WIDTH,        xs,
                IA_HEIGHT,       30,
                LED_PAIRS,            3,
                LED_TIME,             FALSE,
                LED_COLON,            FALSE,
                LED_RAW,              FALSE,
            TAG_DONE])
  IF led=NIL THEN Throw("OBJ","led")

  IF ListLen(totpItems)=0
    xs:=xs-2
    Move(w.rport,x+2,y+8+2)
    SetAPen(w.rport,1)
    wid:=29
    IF wid>(xs/8) THEN wid:=(xs/8)
    Text(w.rport,'Add some items using the menu',wid)
  ELSE
  
    FOR i:=0 TO (ys/YSIZE)-1
      idx:=self.scrollTop+i
      IF idx<ListLen(totpItems)
        Move(w.rport,x,y+(i*YSIZE)+8)
        item:=totpItems[idx]
        wid:=StrLen(item.name)
        IF wid>(xs/8) THEN wid:=xs/8
      
        IF item.ticks>1250
          Sets(led,IA_FGPEN,(Div(item.ticks,50) AND 1)+1)
        ELSE
          Sets(led,IA_FGPEN,1)
        ENDIF
        SetAPen(w.rport,1)
        Text(w.rport,item.name,wid)
        Sets(led,LED_PAIRS,Shr(item.digits,1))
        Sets(led,LED_VALUES,item.ledvalues)
        DrawImage(w.rport,led,x+2,y+2+(i*YSIZE)+10)
        gadtoolsbase:=self.gadtoolsbase
        DrawBevelBoxA(w.rport,x,y+(i*YSIZE)+(YSIZE-2),xs,2,[GTBB_RECESSED, TRUE, GTBB_FRAMETYPE, BBFT_BUTTON, GT_VISUALINFO, self.visInfo,TAG_END])     
      ENDIF
    ENDFOR
  ENDIF
  DisposeObject(led)
ENDPROC

PROC redisplay() OF scrollArea 
  IF self.gh.wnd THEN self.render(NIL,self.x,self.y,self.xs,self.ys,self.gh.wnd)
ENDPROC

PROC scrollAction(qual,data,info,curtop)
  sa.scroll(curtop)
ENDPROC

PROC dummyaction() IS 0

PROC tickaction(n,t)
  DEF newtime,ticks,i
  DEF item:PTR TO totp
  DEF timeStr[100]:STRING
  DEF systime

  systime,ticks:=getSystemTime(uiTimedata.utcOffset)
  
  IF forceRefresh OR (systime<>uiTimedata.oldtime)
    uiTimedata.oldtime:=systime
    sa.updateValues(systime,ticks,forceRefresh)
    forceRefresh:=FALSE
    formatCDateTime(getSystemTime(uiTimedata.utcOffset),timeStr)
    settext(maingh,timegad,timeStr)
  ENDIF
ENDPROC


PROC upd(gad,newprefs:PTR TO prefs,val)
  DEF tempstr[255]:STRING
  IF gad=prefsgad1
    newprefs.readNtpTime:=IF val THEN 1 ELSE 0
  ENDIF
  IF gad=prefsgad2
    newprefs.useTimezone:=IF val THEN 1 ELSE 0
  ENDIF
  IF gad=prefsgad3
    newprefs.userOffset:=val
    StringF(tempstr,'Manual timezone offset (hh:mm): \c\r\z\d[2]:\r\z\d[2]',IF val<0 THEN "-" ELSE " ",Div(Abs(val),60),Mod(Abs(val),60))
    settext(prefsgh,prefstxt1,tempstr)
  ENDIF
ENDPROC

PROC editPrefs()
  DEF gui,gui2
  DEF newprefs:prefs
  DEF tempstr[255]:STRING
  
  newprefs.readNtpTime:=uiPrefs.readNtpTime
  newprefs.useTimezone:=uiPrefs.useTimezone
  newprefs.userOffset:=uiPrefs.userOffset

  StringF(tempstr,'Manual timezone offset (hh:mm): \c\r\z\d[2]:\r\z\d[2]',IF uiPrefs.userOffset<0 THEN "-" ELSE " ",Div(Abs(uiPrefs.userOffset),60),Mod(Abs(uiPrefs.userOffset),60))


  gui:=[ROWS, [BEVELR, [EQROWS,
          prefsgad1:=[CHECK,{upd},'Get time from internet',newprefs.readNtpTime,TRUE],
          prefsgad2:=[CHECK,{upd},'Use tz.library to get time',newprefs.useTimezone,TRUE],
          prefstxt1:=[TEXT,tempstr,'',FALSE,10],
          prefsgad3:=[SLIDE,{upd},'',FALSE,-12*60,12*60,newprefs.userOffset,10,'']
          ]],
       [COLS,[SPACEH],[BUTTON,1,'Ok'],[BUTTON,0,'Cancel']]
       ]

  gui2:=[EG_GHVAR, {prefsgh}, EG_INFO,newprefs,0]

  IF easyguiA('Edit Settings', gui,gui2)=1
    uiPrefs.readNtpTime:=newprefs.readNtpTime
    uiPrefs.useTimezone:=newprefs.useTimezone
    uiPrefs.userOffset:=newprefs.userOffset
    calcUTCOffset(uiTimedata,uiPrefs)
  ENDIF

ENDPROC

PROC lvaction(qual,data,info,num_selected)
  lvsel:=num_selected
  IF lvsel=-1
    setdisabled(itemsgh,btnMoveUp,TRUE)
    setdisabled(itemsgh,btnMoveDown,TRUE)
    setdisabled(itemsgh,btnEdit,TRUE)
    setdisabled(itemsgh,btnDel,TRUE)
  ELSE
    setdisabled(itemsgh,btnMoveUp,IF lvsel=0 THEN TRUE ELSE FALSE)
    setdisabled(itemsgh,btnMoveDown,IF lvsel=(ListLen(newitems)-1) THEN TRUE ELSE FALSE)
    setdisabled(itemsgh,btnEdit,FALSE)
    setdisabled(itemsgh,btnDel,FALSE)
  ENDIF
  
ENDPROC

PROC itemaddok(data:PTR TO LONG,info)
  DEF v:PTR TO CHAR
  DEF tmpItem:PTR TO totp
  
  v:=getstr(itemaddgh,data[0])
  IF EstrLen(v)=0
    EasyRequestArgs(NIL,[20,0,'Error','You must enter a name','Ok'],NIL,NIL) 
    RETURN
  ENDIF

  v:=getstr(itemaddgh,data[1])
  IF EstrLen(v)=0
    EasyRequestArgs(NIL,[20,0,'Error','You must enter a secret','Ok'],NIL,NIL) 
    RETURN
  ENDIF
  
  NEW tmpItem.create()
  StrCopy(tmpItem.secret,v)
  IF tmpItem.makeKey()=0
    EasyRequestArgs(NIL,[20,0,'Error','The secret is not valid','Ok'],NIL,NIL) 
    END tmpItem
    RETURN
  ENDIF
  END tmpItem

  quitgui(1)
ENDPROC

PROC v(qual,data:PTR TO LONG,info,val)
  data[3]:=val
ENDPROC

PROC moveup()
  DEF t
  IF lvsel>0
    setlistvlabels(itemsgh,listgad,-1)
    freeExecList(newitems)
    t:=newitems[lvsel-1]
    newitems[lvsel-1]:=newitems[lvsel]
    newitems[lvsel]:=t
    
    makeExecList(newitems)
    setlistvlabels(itemsgh,listgad,l)
    setlistvselected(itemsgh,listgad,lvsel-1)
    lvaction(0,0,0,lvsel-1)
  ENDIF
ENDPROC

PROC movedown()
  DEF t
  IF (lvsel>=0) AND (lvsel<(ListLen(newitems)-1))
    setlistvlabels(itemsgh,listgad,-1)
    freeExecList(newitems)
    t:=newitems[lvsel+1]
    newitems[lvsel+1]:=newitems[lvsel]
    newitems[lvsel]:=t
    
    makeExecList(newitems)
    setlistvlabels(itemsgh,listgad,l)
    setlistvselected(itemsgh,listgad,lvsel+1)
    lvaction(0,0,0,lvsel+1)
  ENDIF
ENDPROC

PROC itemdel()
  DEF i
  IF (lvsel>=0) AND (lvsel<ListLen(newitems))
    setlistvselected(itemsgh,listgad,lvsel)
    setlistvlabels(itemsgh,listgad,-1)
    freeExecList(newitems)
    FOR i:=lvsel+1 TO ListLen(newitems)-1
      newitems[i-1]:=newitems[i]
    ENDFOR
    SetList(newitems,ListLen(newitems)-1)
    makeExecList(newitems)
    setlistvlabels(itemsgh,listgad,l)
    IF (lvsel>=ListLen(newitems))
      setlistvselected(itemsgh,listgad,lvsel-1)
      lvaction(0,0,0,lvsel-1)
    ENDIF
  ENDIF
ENDPROC

PROC itemedit()
  DEF i
  DEF gui
  DEF d:PTR TO LONG,gad1,gad2,gad3:PTR TO gadget
  DEF newnewitems:PTR TO LONG
  DEF name[100]:STRING
  DEF secret[100]:STRING
  DEF item:PTR TO totp
  DEF type
  
  IF (lvsel>=0) AND (lvsel<ListLen(newitems))
    setlistvselected(itemsgh,listgad,lvsel)
    item:=newitems[lvsel]
    StrCopy(name,item.name)
    StrCopy(secret,item.secret)
    type:=item.type
    d:=[0,0,0,0]
    gui:=[EQROWS,
            gad1:=[STR,{dummyaction},'Name',name,100,20],
            gad2:=[STR,{dummyaction},'Secret',secret,100,20],
            gad3:=[CYCLE,{v},'Type',['SHA1','SHA256',NIL],type,d],
            [BAR],
          [COLS,[SPACEH],[BUTTON,{itemaddok},'Ok',d],[BUTTON,0,'Cancel',d]]
         ]
    d[0]:=gad1
    d[1]:=gad2
    d[2]:=gad3

    IF easyguiA('Edit Item', gui,[EG_GHVAR, {itemaddgh},0])=1
      StrCopy(item.name,name)
      StrCopy(item.secret,secret)
      item.type:=d[3]
      
      setlistvlabels(itemsgh,listgad,-1)
      freeExecList(newitems)
      makeExecList(newitems)
      setlistvlabels(itemsgh,listgad,l)
    ENDIF
  ENDIF

ENDPROC

PROC itemadd()
  DEF gui
  DEF d:PTR TO LONG,gad1,gad2,gad3:PTR TO gadget
  DEF newnewitems:PTR TO LONG
  DEF name[100]:STRING
  DEF secret[100]:STRING
  DEF t:PTR TO totp
  
  d:=[0,0,0,0]
  gui:=[EQROWS,
          gad1:=[STR,{dummyaction},'Name',name,100,20],
          gad2:=[STR,{dummyaction},'Secret',secret,100,20],
          gad3:=[CYCLE,{v},'Type',['SHA1','SHA256',NIL],0,d],
          [BAR],
        [COLS,[SPACEH],[BUTTON,{itemaddok},'Ok',d],[BUTTON,0,'Cancel',d]]
       ]
  d[0]:=gad1
  d[1]:=gad2
  d[2]:=gad3

  IF easyguiA('Add Item', gui,[EG_GHVAR, {itemaddgh},0])=1
    NEW t.create()
    StrCopy(t.name,name)
    StrCopy(t.secret,secret)
    t.type:=d[3]
    IF ListLen(newitems)=ListMax(newitems)
      newnewitems:=List(ListMax(newitems)+10)
      ListAdd(newnewitems,newitems)
      DisposeLink(newitems)
      newitems:=newnewitems
    ENDIF
    setlistvlabels(itemsgh,listgad,-1)
    freeExecList(newitems)
    ListAddItem(newitems,t)
    makeExecList(newitems)
    setlistvlabels(itemsgh,listgad,l)
  ENDIF
ENDPROC

PROC freeExecList(items:PTR TO LONG)
  DEF item:PTR TO totp
  DEF i
  DEF node:PTR TO ln

  FOR i:=0 TO ListLen(items)-1
    item:=items[i]
    node:=item.node
    END node
    item.node:=NIL
  ENDFOR
  END l
ENDPROC

PROC makeExecList(items:PTR TO LONG)
  DEF item:PTR TO totp
  DEF i
  DEF node:PTR TO ln
  
  l:=newlist()
  FOR i:=0 TO ListLen(items)-1
    item:=items[i]
    AddTail(l,item.node:=newnode(NIL,item.name))
  ENDFOR
ENDPROC

PROC editList()
  DEF gui,i,j,found,item:PTR TO totp
  
  SetList(newitems,0)
  ListAdd(newitems,totpItems)
  makeExecList(totpItems)
  IF ListLen(newitems)>0 THEN lvsel:=0 ELSE lvsel:=-1

  gui:=[ROWS,[BEVELR, [EQROWS,
         [TEXT,'Items List',0,FALSE,3],
         [COLS,listgad:=[LISTV,{lvaction},0,15,15,l,FALSE,1,lvsel],[EQROWS,btnMoveUp:=[BUTTON,{moveup},'Move Up',0,0,0,lvsel<=0],btnMoveDown:=[BUTTON,{movedown},'Move Down',0,0,0,ListLen(newitems)<2],[BUTTON,{itemadd},'Add'],btnEdit:=[BUTTON,{itemedit},'Edit',0,0,0,lvsel=-1],btnDel:=[BUTTON,{itemdel},'Delete',0,0,0,lvsel=-1],[SPACEV]]]
         ]],
        [COLS,[SPACEH],[BUTTON,1,'Ok'],[BUTTON,0,'Cancel']]
       ]      
  IF easyguiA('Edit List', gui,[EG_GHVAR, {itemsgh},0])=1
    FOR i:=ListLen(totpItems)-1 TO 0 STEP -1
      found:=FALSE
      FOR j:=0 TO ListLen(newitems)-1
        IF totpItems[i]=newitems[j] THEN found:=TRUE
      ENDFOR
      IF found=0
        item:=totpItems[i]
        END item
      ENDIF
    ENDFOR
    DisposeLink(totpItems)
    totpItems:=List(ListLen(newitems))
    ListAdd(totpItems,newitems)
    SetList(newitems,0)
    forceRefresh:=TRUE
  ELSE
    FOR i:=ListLen(newitems)-1 TO 0 STEP -1
      found:=FALSE
      FOR j:=0 TO ListLen(totpItems)-1
        IF newitems[i]=totpItems[j] THEN found:=TRUE
      ENDFOR
      IF found=0
        item:=newitems[i]
        END item
      ENDIF
    ENDFOR
    SetList(newitems,0)
  ENDIF

  freeExecList(totpItems)
ENDPROC

PROC showAbout()
  EasyRequestArgs(NIL,[20,0,'About Ami-Authenticator','Ami-Authenticator - Version 0.1\n\nA 2FA code generator application for the Amiga\nWritten by Darren Coles for the Amiga Tool Jam 2023\n(Gadtools Version)','Ok'],NIL,NIL) 
ENDPROC

PROC createpass(data:PTR TO LONG,info)
  DEF v1,v2
  DEF gad1:PTR TO password
  DEF gad2:PTR TO password
  gad1:=data[0]
  gad2:=data[1]

  v1:=gad1.estr
  v2:=gad2.estr
  IF StrLen(v1)=0
    EasyRequestArgs(NIL,[20,0,'Error','You have not entered a master password','Ok'],NIL,NIL) 
  ELSEIF StrLen(v2)=0
    EasyRequestArgs(NIL,[20,0,'Error','You have not confirmed your master password','Ok'],NIL,NIL) 
  ELSEIF StrCmp(v1,v2)=0
    EasyRequestArgs(NIL,[20,0,'Error','You have not correctly confirmed your master password','Ok'],NIL,NIL) 
  ELSE
   quitgui(1)
  ENDIF

ENDPROC

PROC cancelcreatepass()
 IF EasyRequestArgs(NIL,[20,0,'Warning','Not setting a master password will leave your secrets unsecured.\nDo you wish to continue?','Yes|No'],NIL,NIL)=1
   StrCopy(masterPass1,'#')
   quitgui(0)
 ENDIF
ENDPROC

PROC setMasterPass()
  DEF gui
  DEF newPass[100]:STRING
  DEF confirmPass[100]:STRING
  DEF d:PTR TO LONG
  DEF p1=NIL:PTR TO password
  DEF p2=NIL:PTR TO password

  NEW p1.password(newPass,'Master Password',TRUE,10)
  NEW p2.password(confirmPass,'Confirm Password',TRUE,10)
  
  d:=[p1,p2]
	
  gui:=[EQROWS,
          [PLUGIN,{dummyaction},p1,TRUE],
          [PLUGIN,{dummyaction},p2,TRUE],
          [BAR],
        [COLS,[SPACEH],[BUTTON,{createpass},'Ok',d],[BUTTON,{cancelcreatepass},'Cancel',d]]
       ]
      
  IF easyguiA('Set Your Master password', gui,[EG_GHVAR, {passwdgh},0])=1
    calcSha256hex(newPass,masterPass1)
    calcSha1base32(newPass,masterPass2)
  ENDIF
  
  END p1
  END p2
ENDPROC

PROC updatepass(data:PTR TO LONG,info)
  DEF v1,v2,v3
  DEF tempStr[255]:STRING
  DEF gad1:PTR TO password
  DEF gad2:PTR TO password
  DEF gad3:PTR TO password
  gad1:=data[0]
  gad2:=data[1]
  gad3:=data[2]

  v1:=gad1.estr
  v2:=gad2.estr
  v3:=gad3.estr

  IF (StrLen(v1)=0) AND (StrCmp(masterPass1,'#')=FALSE)
    EasyRequestArgs(NIL,[20,0,'Error','You have not entered the old master password','Ok'],NIL,NIL) 
  ELSE    
    calcSha256hex(v1,tempStr)
    IF (StrCmp(masterPass1,'#')=FALSE) AND (StrCmp(masterPass1,tempStr)=FALSE)
      EasyRequestArgs(NIL,[20,0,'Error','Incorrect master password','Ok'],NIL,NIL) 
    ELSEIF StrLen(v2)=0
      EasyRequestArgs(NIL,[20,0,'Error','You have not entered a new master password','Ok'],NIL,NIL) 
    ELSEIF StrLen(v3)=0
      EasyRequestArgs(NIL,[20,0,'Error','You have not confirmed your new master password','Ok'],NIL,NIL) 
    ELSEIF StrCmp(v2,v3)=0
      EasyRequestArgs(NIL,[20,0,'Error','You have not correctly confirmed your new master password','Ok'],NIL,NIL) 
    ELSE
     quitgui(1)
    ENDIF
  ENDIF
ENDPROC

PROC updateMasterPass()
  DEF gui
  DEF oldPass[100]:STRING
  DEF newPass[100]:STRING
  DEF confirmPass[100]:STRING
  DEF d:PTR TO LONG
  DEF gad1,gad2,gad3
  DEF p1=NIL:PTR TO password
  DEF p2=NIL:PTR TO password
  DEF p3=NIL:PTR TO password
  
  NEW p1.password(oldPass,'Old Password',TRUE,10,StrCmp(masterPass1,'#'))
  NEW p2.password(newPass,'New Password',TRUE,10)
  NEW p3.password(confirmPass,'Confirm Password',TRUE,10)

  d:=[p1,p2,p3]
	
  gui:=[EQROWS,
          [PLUGIN,{dummyaction},p1,TRUE],
          [PLUGIN,{dummyaction},p2,TRUE],
          [PLUGIN,{dummyaction},p3,TRUE],
          [BAR],
        [COLS,[SPACEH],[BUTTON,{updatepass},'Ok',d],[BUTTON,0,'Cancel',d]]
       ]
       
  IF easyguiA('Set your new master password', gui,[EG_GHVAR, {passwdgh},0])=1
    calcSha256hex(newPass,masterPass1)
    calcSha1base32(newPass,masterPass2)
  ENDIF

  END p1
  END p2
  END p3
ENDPROC

PROC itementerpass(data:PTR TO LONG,info)
  DEF v1,tempStr[255]:STRING
  DEF gad1:PTR TO password
  gad1:=data[0]
  v1:=gad1.estr
  IF StrLen(v1)=0
    EasyRequestArgs(NIL,[20,0,'Error','You have not entered a master password','Ok'],NIL,NIL) 
  ELSE
    calcSha256hex(v1,tempStr)
    IF StrCmp(masterPass1,tempStr)
      quitgui(1)
    ELSE
      EasyRequestArgs(NIL,[20,0,'Error','Incorrect master password','Ok'],NIL,NIL) 
    ENDIF
  ENDIF
ENDPROC

PROC verifyMasterPass()
  DEF v1,v2
  DEF gui
  DEF newPass[100]:STRING
  DEF d:PTR TO LONG
  DEF p=NIL:PTR TO password
  
  NEW p.password(newPass,'Master Password',TRUE,10)
  
  d:=[0]
	
  gui:=[EQROWS,
          [PLUGIN,{dummyaction},p,TRUE],
          [BAR],
        [COLS,[SPACEH],[BUTTON,{itementerpass},'Ok',d],[BUTTON,0,'Cancel',d]]
       ]
       
  d[0]:=p
       
  IF easyguiA('Enter your master password', gui,[EG_GHVAR, {passwdgh},0])=1
    calcSha1base32(newPass,masterPass2)
    END p
  ELSE
    END p
    Raise(-1)
  ENDIF
ENDPROC


EXPORT PROC showMain(timedata,prefs,masterPass,itemsPtr:PTR TO LONG) HANDLE
  DEF gui,menu
  DEF ticker=NIL:PTR TO ticker
  DEF enteredPass[100]:STRING
  DEF i,item:PTR TO totp
  DEF decrypted=FALSE
  
  forceRefresh:=FALSE  
  sa:=0
  
  uiPrefs:=prefs
  totpItems:=itemsPtr[]
  uiTimedata:=timedata
  newitems:=List(ListLen(totpItems)+10)
  NEW ticker 
  NEW sa.scrollArea()

  masterPass1:=masterPass
  masterPass2:=enteredPass

  IF EstrLen(masterPass)=0
    setMasterPass()
    FOR i:=0 TO ListLen(totpItems)-1
      item:=totpItems[i]
      item.decrypt('')
    ENDFOR
  ELSEIF StrCmp(masterPass,'#')
    FOR i:=0 TO ListLen(totpItems)-1
      item:=totpItems[i]
      item.decrypt('')
    ENDFOR
  ELSE
    verifyMasterPass()
    FOR i:=0 TO ListLen(totpItems)-1
      item:=totpItems[i]
      item.decrypt(enteredPass)
    ENDFOR
  ENDIF
  decrypted:=TRUE
  gui:=[ EQROWS,
          [COLS,
            timegad:=[TEXT,'','UTC Time',TRUE,16]
          ],
          [COLS,
            [BEVELR,
              [PLUGIN,{dummyaction},sa]
            ],
            scrgad:=[SCROLL,{scrollAction},TRUE,3,0,0,18]
          ],
          [PLUGIN,{tickaction},ticker]
        ]
  menu:=
          [ EG_GHVAR, {maingh},
            EG_MENU,[NM_TITLE,0,'Project',0,  0,0,0,
               NM_ITEM,0,'Edit Items','i',0,0,{editList},
               NM_ITEM,0,'Edit Settings','s',0,0,{editPrefs},
               NM_ITEM,0,'Change Master Password','c',0,0,{updateMasterPass},
               NM_ITEM, 0, NM_BARLABEL, 0, 0, 0, 0, 
               NM_ITEM,0,'About',0,0,0,{showAbout},
               NM_ITEM, 0, NM_BARLABEL, 0, 0, 0, 0,
               NM_ITEM,0,'Quit','q',0,0,0,
              0,0,0,0,0,0,0]:newmenu,NIL]
       

  easyguiA('Ami-Authenticator', gui,menu)
EXCEPT DO
  IF decrypted
    FOR i:=0 TO ListLen(totpItems)-1
      item:=totpItems[i]
      item.encrypt(enteredPass)
    ENDFOR
  ENDIF
  
  SELECT exception
    CASE "GUI"
       EasyRequestArgs(NIL,[20,0,'Error','Unknown error','Ok'],NIL,NIL) 
    CASE "GT"
      EasyRequestArgs(NIL,[20,0,'Error','Unable to open gadtools.library','Ok'],NIL,NIL) 
    CASE "LIB"
      SELECT exceptioninfo
        CASE "led"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open led.image','Ok'],NIL,NIL) 
        CASE "gadt"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open gadtools.library','Ok'],NIL,NIL) 
      ENDSELECT
    CASE "OBJ"
      SELECT exceptioninfo
        CASE "led"
          EasyRequestArgs(NIL,[20,0,'Error','Error creating led.image object','Ok'],NIL,NIL) 
      ENDSELECT
    CASE "MEM"
      EasyRequestArgs(NIL,[20,0,'Error','Not enough memory','Ok'],NIL,NIL) 
  ENDSELECT

  END ticker
  END sa
  DisposeLink(newitems)
  itemsPtr[]:=totpItems
ENDPROC

CHAR verstring