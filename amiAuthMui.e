OPT MODULE,OSVERSION=37,LARGE

  MODULE 'muimaster' , 'libraries/mui','libraries/gadtools'
  MODULE 'tools/boopsi','tools/installhook'
  MODULE 'utility/tagitem','intuition/classusr','utility/hooks','exec/memory'

  MODULE 'images/led','intuition/gadgetclass','intuition/icclass','intuition/intuition','intuition/imageclass','graphics','graphics/gfx','graphics/rastport'

   MODULE '*amiAuthTotp','*amiAuthPrefs','*amiAuthTime','*sha256'

#date verstring '$VER:AmiAuthenticator (MUI) 1.0.0 (%d.%aM.%Y)' 

OBJECT passwordForm
  app                   :	PTR TO LONG
	winMasterPass         :	PTR TO LONG
  grpMasterPass_Top     :	PTR TO LONG
  stR_lblNewMasterPass  : PTR TO LONG
	lblOldMasterPass      :	PTR TO LONG
	strOldMasterPass      :	PTR TO LONG
	lblNewMasterPass      :	PTR TO LONG
	strNewMasterPass      :	PTR TO LONG
	lblConfirmMasterPass  :	PTR TO LONG
	strConfirmMasterPass  :	PTR TO LONG
	btnMasterPassOk       :	PTR TO LONG
	btnMasterPassCancel   :	PTR TO LONG
ENDOBJECT

OBJECT itemForm
  app             :	PTR TO LONG
	winEditItem     :	PTR TO LONG
	lblName         :	PTR TO LONG
	strName         :	PTR TO LONG
	lblSecret       :	PTR TO LONG
	strSecret       :	PTR TO LONG
	lvlType         :	PTR TO LONG
	cycType         :	PTR TO LONG
	btnItemOk       :	PTR TO LONG
	btnItemCancel   :	PTR TO LONG
	stR_lblName     :	PTR TO CHAR
	stR_lblSecret   :	PTR TO CHAR
	stR_lvlType     :	PTR TO CHAR
	cycTypeContent  :	PTR TO LONG
ENDOBJECT

OBJECT itemsForm
  app           :	PTR TO LONG
	winItems      :	PTR TO LONG
	lvItems       :	PTR TO LONG
	btnMoveUp     :	PTR TO LONG
	btnMoveDown   :	PTR TO LONG
	btnAdd        :	PTR TO LONG
	btnEdit       :	PTR TO LONG
	btnDelete     :	PTR TO LONG
	btnOk         :	PTR TO LONG
	btnCancel     :	PTR TO LONG
  itemAddHook   :	PTR TO hook
  itemEditHook   :	PTR TO hook
  itemDeleteHook   :	PTR TO hook
  changeSelectedHook:	PTR TO hook
  moveUpButtonHook:	PTR TO hook
  moveDownButtonHook:	PTR TO hook
ENDOBJECT

OBJECT prefsForm
	app             :	PTR TO LONG
	winMain         :	PTR TO LONG
	tx_label_0      :	PTR TO LONG
	ch_label_0      :	PTR TO LONG
	tx_label_1      :	PTR TO LONG
	ch_label_1      :	PTR TO LONG
	tx_label_2      :	PTR TO LONG
	pr_label_0      :	PTR TO LONG
	bt_label_0      :	PTR TO LONG
	bt_label_1      :	PTR TO LONG
	stR_TX_label_0  :	PTR TO CHAR
	stR_TX_label_1  :	PTR TO CHAR
	stR_TX_label_2  :	PTR TO CHAR
ENDOBJECT

OBJECT uiItem
  textItem: LONG
  rastport:PTR TO rastport
  bitmapItem: LONG
  bitmap:PTR TO bitmap
  planes:LONG
  barItem:LONG
  oldInterval:LONG
ENDOBJECT

OBJECT muiUI
	app                    :	PTR TO LONG
	winMain                :	PTR TO LONG
  timeLabel              :	PTR TO LONG
  timeText               :	PTR TO LONG
  timeVal                :	PTR TO LONG
  timeGroup              :	PTR TO LONG
  noItemsText            :	PTR TO LONG
  menu                   :	PTR TO LONG
  windowMainGroupVirt    :	PTR TO LONG
  menuEditItems          :	PTR TO LONG
  menuEditPrefs          :	PTR TO LONG
  menuChangePassword     :	PTR TO LONG
  menuAbout              :	PTR TO LONG
  menuAboutMui           :	PTR TO LONG
  menuQuit               :	PTR TO LONG
  aboutwin               :	PTR TO LONG

  menuPrefsHook: PTR TO hook
  menuEditItemsHook: PTR TO hook
  menuChangePasswordHook: PTR TO hook
  menuAboutHook: PTR TO hook
  menuAboutMuiHook: PTR TO hook
  
  masterpass1: PTR TO CHAR
  masterpass2: PTR TO CHAR
ENDOBJECT

DEF totpItems:PTR TO LONG
DEF uiItems:PTR TO LONG
DEF uiPrefs:PTR TO prefs
DEF uiTimedata:PTR TO timedata
DEF newitems:PTR TO LONG
DEF led
DEF timeVal:PTR TO CHAR
DEF muiUI:PTR TO muiUI
DEF forceRefresh

CONST YSIZE=44

PROC create(app) OF passwordForm
	DEF grpMasterPass_Root , grpMasterPass_Buttons , space_MP
  
  self.app:=app
  
  self.stR_lblNewMasterPass:= 'New Password'
	self.lblOldMasterPass := Label( 'Old Password' )

	self.strOldMasterPass := StringObject ,
		MUIA_Frame , MUIV_Frame_String ,
		MUIA_HelpNode , 'strOldMasterPass' ,
		MUIA_String_Secret , MUI_TRUE ,
	End

	self.lblNewMasterPass := TextObject ,
		MUIA_Weight , 0 ,
		MUIA_Background , MUII_WindowBack ,
		MUIA_Text_Contents , self.stR_lblNewMasterPass ,
		MUIA_Text_SetMin , MUI_TRUE ,
	End

	self.strNewMasterPass := StringObject ,
		MUIA_Frame , MUIV_Frame_String ,
		MUIA_HelpNode , 'strNewMasterPass' ,
		MUIA_String_Secret , MUI_TRUE ,
	End

	self.lblConfirmMasterPass := Label( 'Confirm Password' )

	self.strConfirmMasterPass := StringObject ,
		MUIA_Frame , MUIV_Frame_String ,
		MUIA_HelpNode , 'strConfirmMasterPass' ,
		MUIA_String_Secret , MUI_TRUE ,
	End

	self.grpMasterPass_Top := GroupObject ,
		MUIA_HelpNode , 'grpMasterPass_Top' ,
		MUIA_Group_Columns , 2 ,
		Child , self.lblOldMasterPass ,
		Child , self.strOldMasterPass ,
		Child , self.lblNewMasterPass ,
		Child , self.strNewMasterPass ,
		Child , self.lblConfirmMasterPass ,
		Child , self.strConfirmMasterPass ,
	End

	space_MP := HVSpace

	self.btnMasterPassOk := SimpleButton( 'Ok' )

	self.btnMasterPassCancel := SimpleButton( 'Cancel' )

	grpMasterPass_Buttons := GroupObject ,
		MUIA_HelpNode , 'grpMasterPass_Buttons' ,
		MUIA_Group_Horiz , MUI_TRUE ,
		Child , space_MP ,
		Child , self.btnMasterPassOk ,
		Child , self.btnMasterPassCancel ,
	End

	grpMasterPass_Root := GroupObject ,
		Child , self.grpMasterPass_Top ,
		Child , grpMasterPass_Buttons ,
	End

	self.winMasterPass := WindowObject ,
		MUIA_Window_Title , 'Change Master Password' ,
		MUIA_Window_ID , "ATH4" ,
		WindowContents , grpMasterPass_Root ,
	End

	domethod( self.winMasterPass , [
		MUIM_Window_SetCycleChain , self.strOldMasterPass ,
		self.strNewMasterPass ,
		self.strConfirmMasterPass ,
		self.btnMasterPassOk ,
		self.btnMasterPassCancel ,
		0 ] )

ENDPROC

PROC end() OF passwordForm
  Mui_DisposeObject(self.winMasterPass)
ENDPROC

PROC setMasterPass() OF passwordForm
  DEF v1,v2,running=TRUE,result_domethod,signal,cancel=FALSE
	
  domethod(self.app,[OM_ADDMEMBER,self.winMasterPass])

  domethod( self.winMasterPass , [
		MUIM_Notify , MUIA_Window_CloseRequest , MUI_TRUE ,
		self.app,
		2 ,
		MUIM_Application_ReturnID , MUIA_Window_CloseRequest ] )

	domethod( self.btnMasterPassCancel , [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		2 ,
    MUIM_Application_ReturnID , MUIV_Application_ReturnID_Quit ])

	domethod( self.btnMasterPassOk, [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		2 ,
    MUIM_Application_ReturnID , 1 ])

    domethod(self.grpMasterPass_Top,[OM_REMMEMBER,self.lblOldMasterPass])
    domethod(self.grpMasterPass_Top,[OM_REMMEMBER,self.strOldMasterPass])
    set( self.lblNewMasterPass ,MUIA_Text_Contents , 'Master password' )
    
    set( self.winMasterPass ,MUIA_Window_Title , 'Set your master password' )
    set( self.winMasterPass ,MUIA_Window_Open , MUI_TRUE )
    get( self.winMasterPass ,MUIA_Window_Open , {v1} )
    IF v1=FALSE THEN Raise("WIN")

  WHILE running
  
    result_domethod := domethod( self.app, [ MUIM_Application_Input , {signal} ] )
    SELECT result_domethod

      CASE 1
        get( self.strNewMasterPass ,MUIA_String_Contents , {v1} )
        get( self.strConfirmMasterPass ,MUIA_String_Contents , {v2} )
        IF StrLen(v1)=0
          Mui_RequestA(0,self.winMasterPass,0,'Error' ,'Ok','You have not entered a master password',0)
        ELSEIF StrLen(v2)=0
          Mui_RequestA(0,self.winMasterPass,0,'Error' ,'Ok','You have not confirmed your master password',0)
        ELSEIF StrCmp(v1,v2)=0
          Mui_RequestA(0,self.winMasterPass,0,'Error' ,'Ok','You have not correctly confirmed your master password',0)
        ELSE
          calcSha256hex(v1,muiUI.masterpass1)
          calcSha1base32(v1,muiUI.masterpass2)
          running:=FALSE
        ENDIF
      CASE MUIA_Window_CloseRequest
        cancel:=TRUE
      CASE MUIV_Application_ReturnID_Quit
        cancel:=TRUE
    ENDSELECT

    IF cancel
      cancel:=FALSE
      IF Mui_RequestA(0,self.winMasterPass,0,'Warning' ,'Yes|No','Not setting a master password will leave your secrets unsecured.\nDo you wish to continue?',0)=1
        StrCopy(muiUI.masterpass1,'#')
        running := FALSE
      ENDIF
    ENDIF

		IF ( signal AND running ) THEN Wait( signal )
  ENDWHILE

  set( self.winMasterPass ,MUIA_Window_Open , FALSE )
  domethod(self.winMasterPass,[MUIM_KillNotify,MUIA_Window_CloseRequest]) 
  domethod(self.btnMasterPassCancel,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.btnMasterPassOk,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.grpMasterPass_Top,[OM_ADDMEMBER,self.lblOldMasterPass])
  domethod(self.grpMasterPass_Top,[OM_ADDMEMBER,self.strOldMasterPass])
  domethod(self.app,[OM_REMMEMBER,self.winMasterPass])
ENDPROC

PROC updateMasterPass() OF passwordForm
  DEF v1,v2,running=TRUE,result_domethod,signal
  DEF tempStr[255]:STRING

  domethod(self.app,[OM_ADDMEMBER,self.winMasterPass])

	domethod( self.winMasterPass , [
		MUIM_Notify , MUIA_Window_CloseRequest , MUI_TRUE ,
		self.app,
		2 ,
		MUIM_Application_ReturnID , MUIA_Window_CloseRequest ] )

	domethod( self.btnMasterPassCancel , [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		2 ,
    MUIM_Application_ReturnID , MUIV_Application_ReturnID_Quit ])

	domethod( self.btnMasterPassOk, [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		2 ,
    MUIM_Application_ReturnID , 1 ])

    set( self.lblNewMasterPass,MUIA_Text_Contents , 'New Password' )
    set( self.winMasterPass ,MUIA_Window_Title , 'Set your new master password' )
    set( self.strOldMasterPass , MUIA_Disabled , StrCmp(muiUI.masterpass1,'#'))

    set( self.winMasterPass ,MUIA_Window_Open , MUI_TRUE )
    get( self.winMasterPass ,MUIA_Window_Open , {v1} )
    IF v1=FALSE THEN Raise("WIN")

  WHILE running
  
    result_domethod := domethod( self.app, [ MUIM_Application_Input , {signal} ] )
    SELECT result_domethod

      CASE 1
        get( self.strOldMasterPass ,MUIA_String_Contents , {v1} )
        IF (StrLen(v1)=0) AND (StrCmp(muiUI.masterpass1,'#')=FALSE)
          Mui_RequestA(0,self.winMasterPass,0,'Error' ,'Ok','You have not entered the old master password',0)
        ELSE
          calcSha256hex(v1,tempStr)
          
          IF StrCmp(muiUI.masterpass1,'#') OR StrCmp(muiUI.masterpass1,tempStr)
            get( self.strNewMasterPass ,MUIA_String_Contents , {v1} )
            get( self.strConfirmMasterPass ,MUIA_String_Contents , {v2} )
            IF StrLen(v1)=0
              Mui_RequestA(0,self.winMasterPass,0,'Error' ,'Ok','You have not entered a new master password',0)
            ELSEIF StrLen(v2)=0
              Mui_RequestA(0,self.winMasterPass,0,'Error' ,'Ok','You have not confirmed your new master password',0)
            ELSEIF StrCmp(v1,v2)=0
              Mui_RequestA(0,self.winMasterPass,0,'Error' ,'Ok','You have not correctly confirmed your new master password',0)
            ELSE
              calcSha256hex(v1,muiUI.masterpass1)
              calcSha1base32(v1,muiUI.masterpass2)
              running:=FALSE
            ENDIF          
          ELSE
            Mui_RequestA(0,self.winMasterPass,0,'Error' ,'Ok','Incorrect master password',0)
          ENDIF
        ENDIF
      CASE MUIA_Window_CloseRequest
        running := FALSE
      CASE MUIV_Application_ReturnID_Quit
        running := FALSE
    ENDSELECT
		IF ( signal AND running ) THEN Wait( signal )
  ENDWHILE

  set( self.winMasterPass ,MUIA_Window_Open , FALSE )
  domethod(self.winMasterPass,[MUIM_KillNotify,MUIA_Window_CloseRequest])
  domethod(self.btnMasterPassCancel,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.btnMasterPassOk,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.app,[OM_REMMEMBER,self.winMasterPass])
ENDPROC

PROC verifyMasterPass() OF passwordForm
  DEF v1,v2,running=TRUE,result_domethod,signal,cancel=FALSE
  DEF tempStr[255]:STRING

  domethod(self.app,[OM_ADDMEMBER,self.winMasterPass])

	domethod( self.winMasterPass , [
		MUIM_Notify , MUIA_Window_CloseRequest , MUI_TRUE ,
		self.app,
		2 ,
		MUIM_Application_ReturnID , MUIA_Window_CloseRequest ] )

	domethod( self.btnMasterPassCancel , [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		2 ,
    MUIM_Application_ReturnID , MUIV_Application_ReturnID_Quit ])

	domethod( self.btnMasterPassOk, [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		2 ,
    MUIM_Application_ReturnID , 1 ])

    domethod(self.grpMasterPass_Top,[OM_REMMEMBER,self.lblOldMasterPass])
    domethod(self.grpMasterPass_Top,[OM_REMMEMBER,self.strOldMasterPass])
    domethod(self.grpMasterPass_Top,[OM_REMMEMBER,self.lblConfirmMasterPass])
    domethod(self.grpMasterPass_Top,[OM_REMMEMBER,self.strConfirmMasterPass])
    set( self.lblNewMasterPass ,MUIA_Text_Contents , 'Master password' )
    
    set( self.winMasterPass ,MUIA_Window_Title , 'Enter your master password' )
    set( self.winMasterPass ,MUIA_Window_Open , MUI_TRUE )
    get( self.winMasterPass ,MUIA_Window_Open , {v1} )
    IF v1=FALSE THEN Raise("WIN")

  WHILE running
  
    result_domethod := domethod( self.app, [ MUIM_Application_Input , {signal} ] )
    SELECT result_domethod

      CASE 1
        get( self.strNewMasterPass ,MUIA_String_Contents , {v1} )
        IF StrLen(v1)=0
          Mui_RequestA(0,self.winMasterPass,0,'Error' ,'Ok','You have not entered a master password',0)
        ELSE
          calcSha256hex(v1,tempStr)
          
          IF StrCmp(muiUI.masterpass1,tempStr)
            calcSha1base32(v1,muiUI.masterpass2)
            running:=FALSE
          ELSE
            Mui_RequestA(0,self.winMasterPass,0,'Error' ,'Ok','Incorrect master password',0)
          ENDIF
        ENDIF
      CASE MUIA_Window_CloseRequest
        Raise(-1)
      CASE MUIV_Application_ReturnID_Quit
        Raise(-1)
    ENDSELECT

		IF ( signal AND running ) THEN Wait( signal )
  ENDWHILE

  set( self.winMasterPass ,MUIA_Window_Open , FALSE )
  domethod(self.winMasterPass,[MUIM_KillNotify,MUIA_Window_CloseRequest])
  domethod(self.btnMasterPassCancel,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.btnMasterPassOk,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.grpMasterPass_Top,[OM_ADDMEMBER,self.lblOldMasterPass])
  domethod(self.grpMasterPass_Top,[OM_ADDMEMBER,self.strOldMasterPass])
  domethod(self.grpMasterPass_Top,[OM_ADDMEMBER,self.lblConfirmMasterPass])
  domethod(self.grpMasterPass_Top,[OM_ADDMEMBER,self.strConfirmMasterPass])
  domethod(self.app,[OM_REMMEMBER,self.winMasterPass])
ENDPROC

PROC create(app) OF itemForm

	DEF grOUP_ROOT_0 , gr_grp_0 , gr_grp_1 , space_0

  self.app:=app

	self.stR_lblName     := 'Name'
	self.stR_lblSecret   := 'Secret'
	self.stR_lvlType     := 'Type'
	self.cycTypeContent  := [
		'SHA1' ,
		'SHA256' ,
		NIL ]

	self.lblName := TextObject ,
		MUIA_Weight , 0 ,
		MUIA_Background , MUII_WindowBack ,
		MUIA_Text_Contents , self.stR_lblName ,
		MUIA_Text_SetMin , MUI_TRUE ,
	End

	self.strName := StringObject ,
		MUIA_Frame , MUIV_Frame_String ,
		MUIA_HelpNode , 'strName' ,
	End

	self.lblSecret := TextObject ,
		MUIA_Weight , 0 ,
		MUIA_Background , MUII_WindowBack ,
		MUIA_Text_Contents , self.stR_lblSecret ,
		MUIA_Text_SetMin , MUI_TRUE ,
	End

	self.strSecret := StringObject ,
		MUIA_Frame , MUIV_Frame_String ,
		MUIA_HelpNode , 'strSecret' ,
	End

	self.lvlType := TextObject ,
		MUIA_Weight , 0 ,
		MUIA_Background , MUII_WindowBack ,
		MUIA_Text_Contents , self.stR_lvlType ,
		MUIA_Text_SetMin , MUI_TRUE ,
	End

	self.cycType := CycleObject ,
		MUIA_HelpNode , 'cycType' ,
		MUIA_Frame , MUIV_Frame_Button ,
		MUIA_Cycle_Entries , self.cycTypeContent ,
	End

	gr_grp_0 := GroupObject ,
		MUIA_HelpNode , 'GR_grp_0' ,
		MUIA_Group_Columns , 2 ,
		Child , self.lblName ,
		Child , self.strName ,
		Child , self.lblSecret ,
		Child , self.strSecret ,
		Child , self.lvlType ,
		Child , self.cycType ,
	End

	space_0 := HSpace( 0 )

	self.btnItemOk := SimpleButton( 'Ok' )

	self.btnItemCancel := SimpleButton( 'Cancel' )

	gr_grp_1 := GroupObject ,
		MUIA_HelpNode , 'GR_grp_1' ,
		MUIA_Group_Horiz , MUI_TRUE ,
		Child , space_0 ,
		Child , self.btnItemOk ,
		Child , self.btnItemCancel ,
	End

	grOUP_ROOT_0 := GroupObject ,
		Child , gr_grp_0 ,
		Child , gr_grp_1 ,
	End

	self.winEditItem := WindowObject ,
		MUIA_Window_Title , 'Edit Item' ,
		MUIA_Window_ID , "ATH0" ,
		WindowContents , grOUP_ROOT_0 ,
	End

	domethod( self.winEditItem , [
		MUIM_Window_SetCycleChain , self.strName ,
		self.strSecret ,
		self.cycType ,
		self.btnItemOk ,
		self.btnItemCancel ,
		0 ] )
ENDPROC self.winEditItem

PROC end() OF itemForm
  IF self.winEditItem THEN Mui_DisposeObject( self.winEditItem )
ENDPROC

PROC addItem(lvItems) OF itemForm
  DEF running=TRUE,signal,result_domethod,result,v
  DEF t:PTR TO totp
  DEF newnewitems:PTR TO LONG
  DEF tmpItem:PTR TO totp

  domethod(self.app,[OM_ADDMEMBER,self.winEditItem])

  set( self.winEditItem, MUIA_Window_Title,'Add New Item')
  
  set(self.strName, MUIA_String_Contents,'')
  set(self.strSecret, MUIA_String_Contents,'')
  set(self.cycType, MUIA_Cycle_Active,0)

	domethod( self.btnItemOk , [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		3,
    MUIM_Application_ReturnID , 1 ])

	domethod( self.btnItemCancel , [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		3,
    MUIM_Application_ReturnID , 2 ])

	domethod( self.winEditItem , [
		MUIM_Notify , MUIA_Window_CloseRequest , MUI_TRUE ,
		self.app,
		2 ,
		MUIM_Application_ReturnID , MUIA_Window_CloseRequest ] )

  set( self.winEditItem ,MUIA_Window_Open , MUI_TRUE )
  get( self.winEditItem ,MUIA_Window_Open , {v} )
  IF v=FALSE THEN Raise("WIN")

  set( self.winEditItem ,MUIA_Window_ActiveObject,self.strName)

  WHILE running
  
    result_domethod := domethod( self.app, [ MUIM_Application_Input , {signal} ] )
    SELECT result_domethod
      CASE 1
        get(self.strName, MUIA_String_Contents,{v})
        IF StrLen(v)=0
          Mui_RequestA(0,self.winEditItem,0,'Error' ,'Ok','You must enter a name',0)
        ELSE
          get(self.strSecret, MUIA_String_Contents,{v})
          IF StrLen(v)=0
            Mui_RequestA(0,self.winEditItem,0,'Error' ,'Ok','You must enter a secret',0)
          ELSE
            NEW tmpItem.create()
            StrCopy(tmpItem.secret,v)
            IF tmpItem.makeKey()=0
              Mui_RequestA(0,self.winEditItem,0,'Error' ,'Ok','The secret is not valid',0)
            ELSE
              running := FALSE
              result:=TRUE
            ENDIF
            END tmpItem
          ENDIF
        ENDIF
      CASE 2
        running := FALSE
        result:=FALSE
      CASE MUIA_Window_CloseRequest
        running := FALSE
        result:=FALSE
      CASE MUIV_Application_ReturnID_Quit
        running := FALSE
        result:=FALSE
    ENDSELECT

		IF ( signal AND running ) THEN Wait( signal )
  ENDWHILE

  IF result
    NEW t.create()
    get(self.strName, MUIA_String_Contents,{v})
    StrCopy(t.name,v)
    get(self.strSecret, MUIA_String_Contents,{v})
    StrCopy(t.secret,v)
    get(self.cycType,MUIA_Cycle_Active,{v})
    t.type:=v
    IF ListLen(newitems)=ListMax(newitems)
      newnewitems:=List(ListMax(newitems)+10)
      ListAdd(newnewitems,newitems)
      DisposeLink(newitems)
      newitems:=newnewitems
    ENDIF
    ListAddItem(newitems,t)
    domethod( lvItems , [ MUIM_List_InsertSingle , t.name , MUIV_List_Insert_Bottom ] )
  ENDIF

  set( self.winEditItem ,MUIA_Window_Open , FALSE )

  domethod(self.winEditItem,[MUIM_KillNotify,MUIA_Window_CloseRequest])
  domethod(self.btnItemOk,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.btnItemCancel,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.app,[OM_REMMEMBER,self.winEditItem])
ENDPROC

PROC editItem(lvItems,itemnum) OF itemForm
  DEF running=TRUE,signal,result_domethod,result,v
  DEF item:PTR TO totp
  DEF tmpItem:PTR TO totp

  domethod(self.app,[OM_ADDMEMBER,self.winEditItem])

  set( self.winEditItem, MUIA_Window_Title,'Edit Item')
  
  item:=newitems[itemnum]
  
  set(self.strName, MUIA_String_Contents,item.name)
  set(self.strSecret, MUIA_String_Contents,item.secret)
  set(self.cycType,MUIA_Cycle_Active,item.type)

	domethod( self.btnItemOk , [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		3,
    MUIM_Application_ReturnID , 1 ])

	domethod( self.btnItemCancel , [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		3,
    MUIM_Application_ReturnID , 2 ])

	domethod( self.winEditItem , [
		MUIM_Notify , MUIA_Window_CloseRequest , MUI_TRUE ,
		self.app,
		2 ,
		MUIM_Application_ReturnID , MUIA_Window_CloseRequest ] )

  set(self.winEditItem ,MUIA_Window_Open , MUI_TRUE )
  get(self.winEditItem ,MUIA_Window_Open,{v})
  IF v=FALSE THEN Raise("WIN")

  set( self.winEditItem ,MUIA_Window_ActiveObject,self.strName)

  WHILE running
  
    result_domethod := domethod( self.app, [ MUIM_Application_Input , {signal} ] )
    SELECT result_domethod
      CASE 1
        get(self.strName, MUIA_String_Contents,{v})
        IF StrLen(v)=0
          Mui_RequestA(0,self.winEditItem,0,'Error' ,'Ok','You must enter a name',0)
        ELSE
          get(self.strSecret, MUIA_String_Contents,{v})
          IF StrLen(v)=0
            Mui_RequestA(0,self.winEditItem,0,'Error' ,'Ok','You must enter a secret',0)
          ELSE
            NEW tmpItem.create()
            StrCopy(tmpItem.secret,v)
            IF tmpItem.makeKey()=0
              Mui_RequestA(0,self.winEditItem,0,'Error' ,'Ok','The secret is not valid',0)
            ELSE
              running := FALSE
              result:=TRUE
            ENDIF
          ENDIF
        ENDIF
      CASE 2
        running := FALSE
        result:=FALSE
      CASE MUIA_Window_CloseRequest
        running := FALSE
        result:=FALSE
      CASE MUIV_Application_ReturnID_Quit
        running := FALSE
        result:=FALSE
    ENDSELECT

		IF ( signal AND running ) THEN Wait( signal )
  ENDWHILE

  IF result
    get(self.strName, MUIA_String_Contents,{v})
    StrCopy(item.name,v)
    get(self.strSecret, MUIA_String_Contents,{v})
    StrCopy(item.secret,v)
    get(self.cycType,MUIA_Cycle_Active,{v})
    item.type:=v
    domethod( lvItems , [ MUIM_List_Remove , itemnum ] )
    domethod( lvItems , [ MUIM_List_InsertSingle , item.name , itemnum ] )
    set(lvItems,MUIA_List_Active,itemnum)

  ENDIF

  set( self.winEditItem ,MUIA_Window_Open , FALSE )
  domethod(self.winEditItem,[MUIM_KillNotify,MUIA_Window_CloseRequest])
  domethod(self.btnItemOk,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.btnItemCancel,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.app,[OM_REMMEMBER,self.winEditItem])
ENDPROC

PROC create(app) OF itemsForm

	DEF grOUP_ROOT_1 , gr_grp_2 , gr_grp_4 , gr_grp_3 , space_1

  self.app:=app

	self.lvItems := ListObject ,
		MUIA_Frame , MUIV_Frame_InputList ,
	End

	self.lvItems := ListviewObject ,
		MUIA_HelpNode , 'lvItems' ,
		MUIA_Listview_MultiSelect , MUIV_Listview_MultiSelect_Default ,
		MUIA_Listview_List , self.lvItems ,
	End

	self.btnMoveUp := TextObject ,
		ButtonFrame ,
		MUIA_Weight , 0 ,
		MUIA_Background , MUII_ButtonBack ,
		MUIA_Text_Contents , 'Move Up' ,
		MUIA_Text_PreParse , '\ec' ,
		MUIA_HelpNode , 'btnMoveUp' ,
		MUIA_InputMode , MUIV_InputMode_RelVerify ,
	End

	self.btnMoveDown := TextObject ,
		ButtonFrame ,
		MUIA_Weight , 0 ,
		MUIA_Background , MUII_ButtonBack ,
		MUIA_Text_Contents , 'Move Down' ,
		MUIA_Text_PreParse , '\ec' ,
		MUIA_HelpNode , 'btnMoveDown' ,
		MUIA_InputMode , MUIV_InputMode_RelVerify ,
	End

	self.btnAdd := TextObject ,
		ButtonFrame ,
		MUIA_Weight , 0 ,
		MUIA_Background , MUII_ButtonBack ,
		MUIA_Text_Contents , 'Add' ,
		MUIA_Text_PreParse , '\ec' ,
		MUIA_HelpNode , 'btnAdd' ,
		MUIA_InputMode , MUIV_InputMode_RelVerify ,
	End

	self.btnEdit := TextObject ,
		ButtonFrame ,
		MUIA_Weight , 0 ,
		MUIA_Background , MUII_ButtonBack ,
		MUIA_Text_Contents , 'Edit' ,
		MUIA_Text_PreParse , '\ec' ,
		MUIA_HelpNode , 'btnEdit' ,
		MUIA_InputMode , MUIV_InputMode_RelVerify ,
	End

	self.btnDelete := TextObject ,
		ButtonFrame ,
		MUIA_Weight , 0 ,
		MUIA_Background , MUII_ButtonBack ,
		MUIA_Text_Contents , 'Delete' ,
		MUIA_Text_PreParse , '\ec' ,
		MUIA_HelpNode , 'btnDelete' ,
		MUIA_InputMode , MUIV_InputMode_RelVerify ,
	End

	gr_grp_4 := GroupObject ,
		MUIA_HelpNode , 'GR_grp_4' ,
		Child , self.btnMoveUp ,
		Child , self.btnMoveDown ,
		Child , self.btnAdd ,
		Child , self.btnEdit ,
		Child , self.btnDelete ,
	End

	gr_grp_2 := GroupObject ,
		MUIA_HelpNode , 'GR_grp_2' ,
		MUIA_Group_Horiz , MUI_TRUE ,
		Child , self.lvItems ,
		Child , gr_grp_4 ,
	End

	space_1 := HSpace( 0 )

	self.btnOk := SimpleButton( 'Ok' )

	self.btnCancel := SimpleButton( 'Cancel' )

	gr_grp_3 := GroupObject ,
		MUIA_HelpNode , 'GR_grp_3' ,
		MUIA_Group_Horiz , MUI_TRUE ,
		Child , space_1 ,
		Child , self.btnOk ,
		Child , self.btnCancel ,
	End

	grOUP_ROOT_1 := GroupObject ,
		Child , gr_grp_2 ,
		Child , gr_grp_3 ,
	End

	self.winItems := WindowObject ,
		MUIA_Window_Title , 'Items List' ,
		MUIA_Window_ID , "ATH1" ,
		WindowContents , grOUP_ROOT_1 ,
	End


	domethod( self.winItems , [
		MUIM_Window_SetCycleChain , self.lvItems ,
		self.btnMoveUp ,
		self.btnMoveDown ,
		self.btnAdd ,
		self.btnEdit ,
		self.btnDelete ,
		self.btnOk ,
		self.btnCancel ,
		0 ] )

ENDPROC self.winItems

PROC end() OF itemsForm IS ( IF self.winItems THEN Mui_DisposeObject( self.winItems ) ELSE NIL )

PROC itemAdd() OF itemsForm
  DEF editItem:PTR TO itemForm
  MOVE.L (A1),self
  GetA4()
  NEW editItem.create(self.app)
  editItem.addItem(self.lvItems)
  END editItem
ENDPROC

PROC itemEdit() OF itemsForm
  DEF editItem:PTR TO itemForm
  DEF entry
  MOVE.L (A1),self
  GetA4()

  get(self.lvItems,MUIA_List_Active,{entry})
  NEW editItem.create(self.app)
  editItem.editItem(self.lvItems,entry)
  END editItem
ENDPROC

PROC makeList(items:PTR TO LONG) OF itemsForm
  DEF item:PTR TO totp
  DEF i
  
  domethod( self.lvItems , [ MUIM_List_Clear ] )
  FOR i:=0 TO ListLen(items)-1
    item:=items[i]
    domethod( self.lvItems , [ MUIM_List_InsertSingle , item.name , MUIV_List_Insert_Bottom ] )
  ENDFOR
ENDPROC

PROC itemDelete() OF itemsForm
  DEF entry,i
  MOVE.L (A1),self
  GetA4()

  get(self.lvItems,MUIA_List_Active,{entry})

  domethod( self.lvItems , [ MUIM_List_Remove , entry ] )
  set(self.lvItems,MUIA_List_Active,entry-1)

  FOR i:=entry+1 TO ListLen(newitems)-1
    newitems[i-1]:=newitems[i]
  ENDFOR
  SetList(newitems,ListLen(newitems)-1)
ENDPROC


PROC moveUpAction() OF itemsForm
  DEF entry,tmp
  MOVE.L (A1),self
  GetA4()

  get(self.lvItems,MUIA_List_Active,{entry})

  domethod( self.lvItems , [ MUIM_List_Move , entry , entry-1 ] )
  set(self.lvItems,MUIA_List_Active,entry-1)

  tmp:=newitems[entry-1]
  newitems[entry-1]:=newitems[entry]
  newitems[entry]:=tmp
ENDPROC

PROC moveDownAction() OF itemsForm
  DEF entry,tmp,i,item:PTR TO totp
  MOVE.L (A1),self
  GetA4()

  get(self.lvItems,MUIA_List_Active,{entry})

  domethod( self.lvItems , [ MUIM_List_Move , entry , entry+1 ] )
  set(self.lvItems,MUIA_List_Active,entry+1)

  tmp:=newitems[entry+1]
  newitems[entry+1]:=newitems[entry]
  newitems[entry]:=tmp

ENDPROC

PROC updateSelectedItem() OF itemsForm
  DEF entry,dis
  get(self.lvItems,MUIA_List_Active,{entry})

  set( self.btnEdit , MUIA_Disabled , IF entry=MUIV_List_Active_Off THEN MUI_TRUE ELSE FALSE)
  set( self.btnDelete , MUIA_Disabled , IF entry=MUIV_List_Active_Off THEN MUI_TRUE ELSE FALSE)
  
  IF (entry=MUIV_List_Active_Off) OR (entry=0) THEN dis:=MUI_TRUE ELSE dis:=FALSE
  set( self.btnMoveUp , MUIA_Disabled , dis)
  IF (entry=MUIV_List_Active_Off) OR (entry=(ListLen(newitems)-1)) THEN dis:=MUI_TRUE ELSE dis:=FALSE
  set( self.btnMoveDown , MUIA_Disabled , dis)
ENDPROC

PROC changeSelectedItem() OF itemsForm
  MOVE.L (A1),self
  GetA4()
  self.updateSelectedItem()
ENDPROC

PROC editItems() OF itemsForm
  DEF running=TRUE,signal,result_domethod,result,i,j,found
  DEF item:PTR TO totp
  DEF hook:PTR TO hook
  DEF uiItem:PTR TO uiItem
  DEF v

  SetList(newitems,0)
  ListAdd(newitems,totpItems)

  domethod(self.app,[OM_ADDMEMBER,self.winItems])

	domethod( self.btnOk , [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		3,
    MUIM_Application_ReturnID , 1 ])

	domethod( self.btnCancel , [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		3,
    MUIM_Application_ReturnID , 2 ])

	domethod( self.winItems , [
		MUIM_Notify , MUIA_Window_CloseRequest , MUI_TRUE ,
		self.app,
		2 ,
		MUIM_Application_ReturnID , MUIA_Window_CloseRequest ] )

  NEW hook
  self.itemAddHook:=hook

	domethod( self.btnAdd, [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.btnAdd,
		3,
    MUIM_CallHook , self.itemAddHook, self ] )
  
  installhook( self.itemAddHook, {itemAdd} )

  NEW hook
  self.itemEditHook:=hook

	domethod( self.btnEdit, [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.btnEdit,
		3,
    MUIM_CallHook , self.itemEditHook, self ] )
  
  installhook( self.itemEditHook, {itemEdit} )

  NEW hook
  self.itemDeleteHook:=hook

	domethod( self.btnDelete, [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.btnDelete,
		3,
    MUIM_CallHook , self.itemDeleteHook, self ] )
  
  installhook( self.itemDeleteHook, {itemDelete} )

  NEW hook
  self.changeSelectedHook:=hook
  domethod( self.lvItems , [
    MUIM_Notify ,  MUIA_List_Active , MUIV_EveryTime ,
    self.app,
    3 ,
        MUIM_CallHook , self.changeSelectedHook, self] )
  installhook( self.changeSelectedHook, {changeSelectedItem})

  NEW hook
  self.moveUpButtonHook:=hook
  domethod( self.btnMoveUp , [
		MUIM_Notify , MUIA_Pressed , FALSE ,
    self.app,
    3 ,
        MUIM_CallHook , self.moveUpButtonHook, self] )
  installhook( self.moveUpButtonHook, {moveUpAction})

  NEW hook
  self.moveDownButtonHook:=hook
  domethod( self.btnMoveDown , [
		MUIM_Notify , MUIA_Pressed , FALSE ,
    self.app,
    3 ,
        MUIM_CallHook , self.moveDownButtonHook, self] )
  installhook( self.moveDownButtonHook, {moveDownAction})

  self.makeList(totpItems)
  self.updateSelectedItem()

  set( self.winItems ,MUIA_Window_Open , MUI_TRUE )
  get( self.winItems ,MUIA_Window_Open ,{v} )
  IF v=FALSE THEN Raise("WIN")

  WHILE running
  
    result_domethod := domethod( self.app, [ MUIM_Application_Input , {signal} ] )
    SELECT result_domethod
      CASE 1
        running := FALSE
        result:=TRUE
      CASE 2
        running := FALSE
        result:=FALSE
      CASE MUIA_Window_CloseRequest
        running := FALSE
        result:=FALSE
      CASE MUIV_Application_ReturnID_Quit
        running := FALSE
        result:=FALSE
    ENDSELECT

		IF ( signal AND running ) THEN Wait( signal )
  ENDWHILE

  IF result

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
    WHILE ListLen(uiItems)>ListLen(totpItems)
      uiItem:=uiItems[ListLen(uiItems)-1]
      uiItem.removeFromGroup(muiUI.windowMainGroupVirt)
      END uiItem
      SetList(uiItems,ListLen(uiItems)-1)
    ENDWHILE
    WHILE ListLen(uiItems)<ListLen(totpItems)
      NEW uiItem.create('')
      ListAddItem(uiItems,uiItem)
    ENDWHILE
    FOR i:=0 TO ListLen(totpItems)-1
      uiItem:=uiItems[i]
      item:=totpItems[i]
      set(uiItem.textItem,MUIA_Text_Contents , item.name)
    ENDFOR
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

  set( self.winItems ,MUIA_Window_Open , FALSE )
  domethod(self.winItems,[MUIM_KillNotify,MUIA_Window_CloseRequest])
  domethod(self.btnOk,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.btnCancel,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.btnAdd,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.app,[OM_REMMEMBER,self.winItems])
  END self.itemAddHook
  END self.itemEditHook
  END self.itemDeleteHook
  END self.changeSelectedHook
  END self.moveUpButtonHook
  END self.moveDownButtonHook
ENDPROC

PROC create(app) OF prefsForm
	DEF grOUP_ROOT_0 , gr_grp_1 , gr_grp_0 , space_0

  self.app:=app

	self.stR_TX_label_0  := 'Get time from internet'
	self.stR_TX_label_1  := 'Use tz.library to get time'
	self.stR_TX_label_2  := String(255)
  StrCopy(self.stR_TX_label_2,'Manual timezone offset(hh:mm): -00:00')

	self.tx_label_0 := TextObject ,
		MUIA_Background , MUII_WindowBack ,
		MUIA_Text_Contents , self.stR_TX_label_0 ,
		MUIA_Text_SetMin , MUI_TRUE ,
	End

	self.ch_label_0 := CheckMark( FALSE )

	self.tx_label_1 := TextObject ,
		MUIA_Background , MUII_WindowBack ,
		MUIA_Text_Contents , self.stR_TX_label_1 ,
		MUIA_Text_SetMin , MUI_TRUE ,
	End

	self.ch_label_1 := CheckMark( FALSE )

	gr_grp_1 := GroupObject ,
		MUIA_HelpNode , 'GR_grp_1' ,
		MUIA_Group_Columns , 2 ,
		Child , self.tx_label_0 ,
		Child , self.ch_label_0 ,
		Child , self.tx_label_1 ,
		Child , self.ch_label_1 ,
	End

	self.tx_label_2 := TextObject ,
		MUIA_Background , MUII_WindowBack ,
		MUIA_Text_Contents , self.stR_TX_label_2 ,
		MUIA_Text_SetMin , MUI_TRUE ,
	End

	self.pr_label_0 := SliderObject ,
		PropFrame ,
		MUIA_HelpNode , 'PR_label_0' ,
		MUIA_Slider_Max , 720 ,
		MUIA_Slider_Min , -720 ,
		MUIA_Slider_Horiz , MUI_TRUE ,
		MUIA_Slider_Quiet , 10 ,
		MUIA_FixHeight , 8 ,
	End

	space_0 := HSpace( 0 )

	self.bt_label_0 := SimpleButton( 'Ok' )

	self.bt_label_1 := SimpleButton( 'Cancel' )

	gr_grp_0 := GroupObject ,
		MUIA_HelpNode , 'GR_grp_0' ,
		MUIA_Group_Horiz , MUI_TRUE ,
		Child , space_0 ,
		Child , self.bt_label_0 ,
		Child , self.bt_label_1 ,
	End

	grOUP_ROOT_0 := GroupObject ,
		Child , gr_grp_1 ,
		Child , self.tx_label_2 ,
		Child , self.pr_label_0 ,
		Child , gr_grp_0 ,
	End

	self.winMain := WindowObject ,
		MUIA_Window_Title , 'Edit Settings' ,
		MUIA_Window_ID , "ATH2" ,
		WindowContents , grOUP_ROOT_0 ,
	End

	domethod( self.winMain , [
		MUIM_Window_SetCycleChain , 
    self.ch_label_0,
    self.ch_label_1,
    self.pr_label_0,
    self.bt_label_0,
    self.bt_label_1,
		0 ] )

ENDPROC

PROC end() OF prefsForm
  DisposeLink(self.stR_TX_label_2)
  Mui_DisposeObject(self.winMain)
ENDPROC

PROC sliderChange() OF prefsForm
  DEF v
  MOVE.L (A1),self
  GetA4()

  get(self.pr_label_0,MUIA_Slider_Level,{v})
  StringF(self.stR_TX_label_2,'Manual timezone offset(hh:mm): \c\r\z\d[2]:\r\z\d[2]',IF v<0 THEN "-" ELSE " ",Div(Abs(v),60),Mod(Abs(v),60))
  set(self.tx_label_2,MUIA_Text_Contents,self.stR_TX_label_2)

ENDPROC

PROC editPrefs() OF prefsForm
  DEF running=TRUE,signal,result_domethod,result,v
  DEF sliderChangeHook:PTR TO hook

  domethod(self.app,[OM_ADDMEMBER,self.winMain])

	domethod( self.bt_label_0 , [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		3,
    MUIM_Application_ReturnID , 1 ])

	domethod( self.bt_label_1 , [
		MUIM_Notify , MUIA_Pressed , FALSE ,
		self.app,
		3,
    MUIM_Application_ReturnID , 2 ])

	domethod( self.winMain , [
		MUIM_Notify , MUIA_Window_CloseRequest , MUI_TRUE ,
		self.app,
		2 ,
		MUIM_Application_ReturnID , MUIA_Window_CloseRequest ] )

   domethod(self.ch_label_0,[MUIM_NoNotifySet,MUIA_Selected,IF uiPrefs.readNtpTime THEN MUI_TRUE ELSE FALSE])
   domethod(self.ch_label_1,[MUIM_NoNotifySet,MUIA_Selected,IF uiPrefs.useTimezone THEN MUI_TRUE ELSE FALSE])
    set(self.pr_label_0,MUIA_Slider_Level,uiPrefs.userOffset)
    StringF(self.stR_TX_label_2,'Manual timezone offset(hh:mm): \c\r\z\d[2]:\r\z\d[2]',IF uiPrefs.userOffset<0 THEN "-" ELSE " ",Div(Abs(uiPrefs.userOffset),60),Mod(Abs(uiPrefs.userOffset),60))
    set(self.tx_label_2,MUIA_Text_Contents,self.stR_TX_label_2)

  NEW sliderChangeHook

	domethod( self.pr_label_0 , [
		MUIM_Notify , MUIA_Slider_Level , MUIV_EveryTime ,
		self.app,
		3,
    MUIM_CallHook , sliderChangeHook, self ] )
  installhook( sliderChangeHook, {sliderChange})


  set( self.winMain ,MUIA_Window_Open , MUI_TRUE )
  get( self.winMain ,MUIA_Window_Open , {v})
  IF v=FALSE THEN Raise("WIN") 

  WHILE running
  
    result_domethod := domethod( self.app, [ MUIM_Application_Input , {signal} ] )
    SELECT result_domethod
      CASE 1
        running := FALSE
        result:=TRUE
      CASE 2
        running := FALSE
        result:=FALSE
      CASE MUIA_Window_CloseRequest
        running := FALSE
        result:=FALSE
      CASE MUIV_Application_ReturnID_Quit
        running := FALSE
        result:=FALSE
    ENDSELECT

		IF ( signal AND running ) THEN Wait( signal )
  ENDWHILE

  IF result
    get(self.ch_label_0,MUIA_Selected,{result})
    uiPrefs.readNtpTime:=IF result THEN 1 ELSE 0
    get(self.ch_label_1,MUIA_Selected,{result})
    uiPrefs.useTimezone:=IF result THEN 1 ELSE 0
    get(self.pr_label_0,MUIA_Slider_Level,{result})
    uiPrefs.userOffset:=result
    calcUTCOffset(uiTimedata,uiPrefs)
  ENDIF

  set( self.winMain ,MUIA_Window_Open , FALSE )
  domethod(self.winMain,[MUIM_KillNotify,MUIA_Window_CloseRequest])
  domethod(self.bt_label_0,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.bt_label_1,[MUIM_KillNotify,MUIA_Pressed])
  domethod(self.app,[OM_REMMEMBER,self.winMain])
  END sliderChangeHook
ENDPROC

PROC create(name:PTR TO CHAR) OF uiItem
  DEF rp:PTR TO rastport
  DEF bm:PTR TO bitmap

  self.oldInterval:=-1

  NEW bm
  InitBitMap(bm,2,128,30)
  self.bitmap:=bm 
  self.planes:=NewM(16*30*2,MEMF_CHIP OR MEMF_CLEAR)
  bm.planes[0]:=self.planes
  bm.planes[1]:=self.planes+(16*30)
  NEW rp
  self.rastport:=rp
  InitRastPort(self.rastport)
  self.rastport.bitmap:=self.bitmap

  self.textItem:=TextObject,
		MUIA_Weight , 0 ,
		MUIA_Text_Contents , name ,
		MUIA_Text_PreParse , '\el' ,
		MUIA_InputMode , MUIV_InputMode_RelVerify ,
  End
  
  self.bitmapItem:=BitmapObject,
      MUIA_FixHeight,30,
      MUIA_Bitmap_Height,30,
      MUIA_Bitmap_Width,128,
      MUIA_Bitmap_Transparent,0,
      MUIA_Bitmap_Bitmap,self.bitmap,
      End

  self.barItem:=RectangleObject,
      MUIA_Rectangle_HBar,MUI_TRUE,
      MUIA_FixHeight,8,
      End
  
ENDPROC

PROC end() OF uiItem
  IF self.textItem THEN Mui_DisposeObject(self.textItem)
  IF self.bitmapItem THEN Mui_DisposeObject(self.bitmapItem)
  IF self.barItem THEN Mui_DisposeObject(self.barItem)
  IF self.rastport THEN END self.rastport
  IF self.bitmap THEN END self.bitmap
  IF self.planes THEN Dispose(self.planes)
ENDPROC

PROC addToGroup(group) OF uiItem
  domethod(group,[OM_ADDMEMBER,self.textItem])
  domethod(group,[OM_ADDMEMBER,self.bitmapItem])
  domethod(group,[OM_ADDMEMBER,self.barItem])
ENDPROC

PROC removeFromGroup(group)  OF uiItem
  domethod(group,[OM_REMMEMBER,self.textItem])
  domethod(group,[OM_REMMEMBER,self.bitmapItem])
  domethod(group,[OM_REMMEMBER,self.barItem])
ENDPROC

PROC menuPrefsAction() OF muiUI
  DEF prefs:PTR TO prefsForm

  MOVE.L (A1),self
  GetA4()
  
  NEW prefs.create(self.app)
  prefs.editPrefs()
  END prefs
ENDPROC

PROC menuEditItemsAction() OF muiUI
  DEF items:PTR TO itemsForm

  MOVE.L (A1),self
  GetA4()
  
  NEW items.create(self.app)
  items.editItems()

  END items
  self.tickAction()
ENDPROC

PROC menuChangePasswordAction() OF muiUI
  DEF passwordForm : PTR TO passwordForm
  MOVE.L (A1),self
  GetA4()
  NEW passwordForm.create(self.app)
  passwordForm.updateMasterPass()
  END passwordForm
ENDPROC

PROC menuAboutAction() OF muiUI
  MOVE.L (A1),self
  GetA4()
  Mui_RequestA(0,self.winMain,0,'About Ami-Authenticator' ,'Ok','Ami-Authenticator - Version 1.0\n\nA 2FA code generator application for the Amiga\nWritten by Darren Coles for the Amiga Tool Jam 2023\n(MUI Version)',0)
ENDPROC

PROC menuAboutMuiAction() OF muiUI
  MOVE.L (A1),self
  GetA4()
  IF (self.aboutwin=0)
    self.aboutwin:=AboutmuiObject,
            MUIA_Window_RefWindow, self.winMain,
            MUIA_Aboutmui_Application, self.app,
            End
  ENDIF
  IF (self.aboutwin) THEN set(self.aboutwin,MUIA_Window_Open,TRUE)
ENDPROC

PROC create() OF muiUI
  DEF menuProject,menuBarLabel0,menuBarLabel1
  DEF windowGroupRoot,windowTopGroup,windowMainGroup,windowMainGroupScroll
  DEF hook:PTR TO hook
  
  self.aboutwin:=0
  
	self.timeLabel := Label( 'UTC Time' )

	self.timeText := TextObject ,
		MUIA_Background , MUII_TextBack ,
		MUIA_Frame , MUIV_Frame_Text ,
		MUIA_Text_Contents , timeVal ,
		MUIA_Text_SetMin , MUI_TRUE ,
	End
	
  self.timeGroup := GroupObject ,
		MUIA_HelpNode , 'GR_grp_1' ,
		MUIA_Group_Horiz , MUI_TRUE ,
		Child , self.timeLabel ,
		Child , self.timeText, 
	End  

	self.menuEditItems := MenuitemObject ,
		MUIA_Menuitem_Title , 'Edit Items' ,
	End

	self.menuEditPrefs := MenuitemObject ,
		MUIA_Menuitem_Title , 'Edit Settings' ,
	End

	self.menuChangePassword := MenuitemObject ,
		MUIA_Menuitem_Title , 'Change Master Password' ,
	End

  menuBarLabel0 := Mui_MakeObjectA( MUIO_Menuitem , [NM_BARLABEL , 0 , 0 , 0 ])

	self.menuAbout := MenuitemObject ,
		MUIA_Menuitem_Title , 'About' ,
	End

	self.menuAboutMui := MenuitemObject ,
		MUIA_Menuitem_Title , 'About Mui' ,
	End

  menuBarLabel1 := Mui_MakeObjectA( MUIO_Menuitem , [NM_BARLABEL , 0 , 0 , 0 ])

	self.menuQuit := MenuitemObject ,
		MUIA_Menuitem_Title , 'Quit' ,
	End

	menuProject := MenuitemObject ,
		MUIA_Menuitem_Title , 'Project' ,
		MUIA_Family_Child , self.menuEditItems ,
		MUIA_Family_Child , self.menuEditPrefs ,
		MUIA_Family_Child , self.menuChangePassword ,
		MUIA_Family_Child , menuBarLabel0 ,
		MUIA_Family_Child , self.menuAbout ,
		MUIA_Family_Child , self.menuAboutMui ,
		MUIA_Family_Child , menuBarLabel1 ,
		MUIA_Family_Child , self.menuQuit ,
	End

	self.menu := MenustripObject ,
		MUIA_Family_Child , menuProject ,
	End

	windowTopGroup := GroupObject ,
		MUIA_HelpNode , 'topGroup' ,
		MUIA_Group_Horiz , MUI_TRUE ,
		Child , self.timeLabel,
		Child , self.timeText,
	End

	self.windowMainGroupVirt := VirtgroupObject ,
		VirtualFrame ,
    Child, self.noItemsText := TextObject ,
      MUIA_Background , MUII_WindowBack ,
      MUIA_Frame , MUIV_Frame_None ,
      MUIA_Text_Contents , 'Add some items using the menu' ,
      MUIA_Text_SetMin , MUI_TRUE ,
    End,
    Child, HVSpace,
		MUIA_HelpNode , 'GR_grp_0' ,
		MUIA_Frame , MUIV_Frame_Button ,
	End

	windowMainGroupScroll := ScrollgroupObject ,
		MUIA_Scrollgroup_Contents , self.windowMainGroupVirt ,
	End

	windowMainGroup := GroupObject ,
		MUIA_HelpNode , 'topGroup' ,
		MUIA_Group_Horiz , MUI_TRUE ,
		Child , windowMainGroupScroll,
	End

	windowGroupRoot := GroupObject ,
		Child , windowTopGroup ,
		Child , windowMainGroup ,
	End

	self.winMain := WindowObject ,
		MUIA_Window_Title , 'Ami-Authenticator' ,
		MUIA_Window_Menustrip , self.menu ,
		MUIA_Window_ID , "ATH3" ,
    ->MUIA_Window_Width,100,
		WindowContents , windowGroupRoot ,
	End

  NEW hook
  self.menuPrefsHook:=hook

	domethod( self.menuEditPrefs, [
		MUIM_Notify , MUIA_Menuitem_Trigger, MUIV_EveryTime,
		self.menuEditPrefs,
		3,
    MUIM_CallHook , self.menuPrefsHook, self ] )
    
  NEW hook
  self.menuEditItemsHook:=hook

	domethod( self.menuEditItems, [
		MUIM_Notify , MUIA_Menuitem_Trigger, MUIV_EveryTime,
		self.menuEditItems,
		3,
    MUIM_CallHook , self.menuEditItemsHook, self ] )

  NEW hook
  self.menuChangePasswordHook:=hook

	domethod( self.menuChangePassword, [
		MUIM_Notify , MUIA_Menuitem_Trigger, MUIV_EveryTime,
		self.menuChangePassword,
		3,
    MUIM_CallHook , self.menuChangePasswordHook, self ] )

  NEW hook
  self.menuAboutHook:=hook

	domethod( self.menuAbout, [
		MUIM_Notify , MUIA_Menuitem_Trigger, MUIV_EveryTime,
		self.menuAbout,
		3,
    MUIM_CallHook , self.menuAboutHook, self ] )

  NEW hook
  self.menuAboutMuiHook:=hook

	domethod( self.menuAboutMui, [
		MUIM_Notify , MUIA_Menuitem_Trigger, MUIV_EveryTime,
		self.menuAboutMui,
		3,
    MUIM_CallHook , self.menuAboutMuiHook, self ] )
 
  installhook( self.menuPrefsHook, {menuPrefsAction})
  installhook( self.menuEditItemsHook, {menuEditItemsAction})
  installhook( self.menuChangePasswordHook, {menuChangePasswordAction})
  installhook( self.menuAboutHook, {menuAboutAction})
  installhook( self.menuAboutMuiHook, {menuAboutMuiAction})
  
	self.app := ApplicationObject ,
		//( IF icon THEN MUIA_Application_DiskObject ELSE TAG_IGNORE ) , icon ,
		//( IF arexx THEN MUIA_Application_Commands ELSE TAG_IGNORE ) , ( IF arexx THEN arexx.commands ELSE NIL ) ,
		//( IF arexx THEN MUIA_Application_RexxHook ELSE TAG_IGNORE ) , ( IF arexx THEN arexx.error ELSE NIL ) ,
		( IF self.menu THEN MUIA_Application_Menu ELSE TAG_IGNORE ) , self.menu ,
		MUIA_Application_Author , 'Darren Coles' ,
		MUIA_Application_Base , 'NONE' ,
		MUIA_Application_Title , 'Ami-Authenticator' ,
		MUIA_Application_Version , verstring,
		MUIA_Application_Copyright , 'Darren Coles' ,
		MUIA_Application_Description , 'N/A' ,
		SubWindow , self.winMain ,
	End
ENDPROC

PROC end() OF muiUI 
	domethod( self.menuEditPrefs,[MUIM_KillNotify,MUIA_Menuitem_Trigger])
  END self.menuPrefsHook
  END self.menuEditItemsHook
  END self.menuChangePasswordHook
  END self.menuAboutHook
  END self.menuAboutMuiHook
  IF self.app THEN Mui_DisposeObject( self.app )
ENDPROC

PROC updateUIItem(uiItem:PTR TO uiItem,item:PTR TO totp,led) OF muiUI 
   uiItem.removeFromGroup(muiUI.windowMainGroupVirt)

    Sets(led,LED_VALUES,item.ledvalues)
    IF item.ticks>1250
      Sets(led,IA_FGPEN,(Div(item.ticks,50) AND 1)+1)
    ELSE
      Sets(led,IA_FGPEN,1)
    ENDIF
    Sets(led,LED_PAIRS,Shr(item.digits,1))
    DrawImage(uiItem.rastport,led,0,0)   
    set(uiItem.bitmapItem, MUIA_Bitmap_Bitmap,uiItem.bitmap)
    uiItem.addToGroup(muiUI.windowMainGroupVirt)
ENDPROC

PROC tickAction() OF muiUI
  DEF newtime,newticks,ticks,i
  DEF item:PTR TO totp
  DEF uiItem:PTR TO uiItem
  DEF timeStr[100]:STRING
  DEF systime
  DEF initchange=FALSE
  DEF updated=FALSE

  systime,ticks:=getSystemTime(uiTimedata.utcOffset)
  
  IF systime<>uiTimedata.oldtime
    uiTimedata.oldtime:=systime

    set(self.noItemsText,MUIA_ShowMe,ListLen(totpItems)=0)

    FOR i:=0 TO ListLen(totpItems)-1
      item:=totpItems[i]
      uiItem:=uiItems[i]
      newtime:=Div(systime,item.interval)
      newticks:=ticks
      newticks:=newticks+Mul(systime-Mul(newtime,item.interval),50)
      IF item.updateValues(0,newtime,newticks,forceRefresh) OR updated
        updated:=TRUE
        IF initchange=FALSE
          domethod(self.windowMainGroupVirt,[MUIM_Group_InitChange])
          initchange:=TRUE
        ENDIF
        self.updateUIItem(uiItem,item,led)
      ENDIF
    ENDFOR
    IF initchange THEN domethod(self.windowMainGroupVirt,[MUIM_Group_ExitChange])
    forceRefresh:=FALSE
    formatCDateTime(getSystemTime(uiTimedata.utcOffset),timeStr)
    StrCopy(timeVal,timeStr)
    set(muiUI.timeText, MUIA_Text_Contents , timeVal)
  ENDIF
ENDPROC

EXPORT PROC showMain(timedata,prefs,masterPass,itemsPtr:PTR TO LONG) HANDLE
  DEF running=TRUE
  DEF result_domethod
  DEF signal
  DEF ledbase=0
  DEF item:PTR TO totp
  DEF i,v
  DEF uiItem:PTR TO uiItem
  DEF items
  DEF enteredPass[100]:STRING
  DEF passwordForm : PTR TO passwordForm
  DEF decrypted=FALSE

  forceRefresh:=FALSE
  muiUI:=0
  uiPrefs:=prefs
  totpItems:=itemsPtr[]
  uiTimedata:=timedata
  newitems:=List(ListLen(totpItems)+10)
  uiItems:=List(ListLen(totpItems)+10)

  timeVal:=String(255)

  IF ( muimasterbase := OpenLibrary( 'muimaster.library' , MUIMASTER_VMIN ) ) = NIL THEN Throw( "LIB" , "muim" )

  ledbase:=OpenLibrary('images/led.image',37)
  IF ledbase=NIL THEN ledbase:=OpenLibrary('PROGDIR:led.image',37)
  IF ledbase=NIL THEN Throw("LIB","led")

  NEW muiUI.create()
  muiUI.masterpass1:=masterPass
  muiUI.masterpass2:=enteredPass

	domethod( muiUI.winMain , [
		MUIM_Notify , MUIA_Window_CloseRequest , MUI_TRUE ,
		muiUI.app,
		2 ,
		MUIM_Application_ReturnID , MUIA_Window_CloseRequest ] )

  domethod( muiUI.menuQuit, [
		MUIM_Notify , MUIA_Menuitem_Trigger, MUIV_EveryTime,
		muiUI.app,
		2,
		MUIM_Application_ReturnID , MUIV_Application_ReturnID_Quit ] )

 
  led:=NewObjectA( NIL, 'led.image',[
                IA_FGPEN,             1,
                IA_BGPEN,             0,
                IA_WIDTH,        128,
                IA_HEIGHT,       30,
                LED_PAIRS,            3,
                LED_TIME,             FALSE,
                LED_COLON,            FALSE,
                LED_RAW,              FALSE,
            TAG_DONE])
  IF led=NIL THEN Throw("OBJ","led")
  
  
  FOR i:=0 TO ListLen(totpItems)-1
    item:=totpItems[i]
    NEW uiItem.create(item.name)
    ListAddItem(uiItems,uiItem)
    
    uiItem.addToGroup(muiUI.windowMainGroupVirt)
  ENDFOR
   
  set( muiUI.winMain ,MUIA_Window_Open , MUI_TRUE )
  get( muiUI.winMain ,MUIA_Window_Open , {v} )
  IF v=FALSE THEN Raise("WIN")

  IF EstrLen(masterPass)=0
    NEW passwordForm.create(muiUI.app)
    passwordForm.setMasterPass()
    END passwordForm
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
    NEW passwordForm.create(muiUI.app)
    passwordForm.verifyMasterPass()
    END passwordForm
  
    FOR i:=0 TO ListLen(totpItems)-1
      item:=totpItems[i]
      item.decrypt(enteredPass)
    ENDFOR
  ENDIF
  decrypted:=TRUE

  muiUI.tickAction()

  WHILE running
  
    result_domethod := domethod( muiUI.app, [ MUIM_Application_Input , {signal} ] )
    muiUI.tickAction()
    SELECT result_domethod

      CASE MUIA_Window_CloseRequest
        running := FALSE
      CASE MUIV_Application_ReturnID_Quit
        running := FALSE
    ENDSELECT

		IF ( signal AND running ) THEN Wait( signal )
  ENDWHILE

  set( muiUI.winMain ,MUIA_Window_Open , FALSE )
  domethod(muiUI.winMain,[MUIM_KillNotify,MUIA_Window_CloseRequest])


EXCEPT DO
  IF decrypted
    FOR i:=0 TO ListLen(totpItems)-1
      item:=totpItems[i]
      item.encrypt(enteredPass)
    ENDFOR
  ENDIF

  SELECT exception
    CASE "WIN"
      Mui_RequestA(0,IF muiUI THEN muiUI.winMain ELSE 0,0,'Error' ,'Ok','Unable to open window',0)
    CASE "LIB"
      SELECT exceptioninfo
        CASE "led"
          Mui_RequestA(0,IF muiUI THEN muiUI.winMain ELSE 0,0,'Error' ,'Ok','Unable to open led.image',0)
        CASE "muim"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open muimaster.library','Ok'],NIL,NIL) 
      ENDSELECT
    CASE "OBJ"
      SELECT exceptioninfo
        CASE "led"
          Mui_RequestA(0,IF muiUI THEN muiUI.winMain ELSE 0,0,'Error' ,'Ok','Error creating led.image object',0)
      ENDSELECT
    CASE "MEM"
      IF muimasterbase
        Mui_RequestA(0,IF muiUI THEN muiUI.winMain ELSE 0,0,'Error' ,'Ok','Not enough memory',0)
      ELSE
        EasyRequestArgs(NIL,[20,0,'Error','Not enough memory','Ok'],NIL,NIL) 
      ENDIF
  ENDSELECT

  FOR i:=0 TO ListLen(uiItems)-1
    uiItem:=uiItems[i]
    uiItem.removeFromGroup(muiUI.windowMainGroupVirt)
    END uiItem
  ENDFOR
  DisposeLink(uiItems)
  IF led THEN DisposeObject(led)
  IF muiUI
    END muiUI
  ENDIF
  IF muimasterbase  THEN CloseLibrary( muimasterbase )
  IF ledbase THEN CloseLibrary(ledbase)
  DisposeLink(newitems)
  DisposeLink(timeVal)
  itemsPtr[]:=totpItems
ENDPROC
