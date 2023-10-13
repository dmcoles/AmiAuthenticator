OPT MODULE,OSVERSION=37,LARGE

  MODULE 'reaction/reaction_macros','window','classes/window','gadgets/layout','layout','intuition/intuition','reaction/reaction_lib'
  MODULE 'label','images/label','scroller','gadgets/scroller','string','bevel','amigalib/boopsi','gadtools','libraries/gadtools'
  MODULE 'checkbox','gadgets/checkbox','space','button','gadgets/button','images/bevel','listbrowser','gadgets/listbrowser','chooser','gadgets/chooser'
  MODULE 'gadgets/string'
  

  ->MODULE 'tools/boopsi','tools/installhook','libraries/gadtools'
  ->MODULE 'utility/tagitem','intuition/classusr','utility/hooks'

  MODULE 'images/led','intuition/gadgetclass','intuition/imageclass'->'intuition/icclass','intuition/intuition','intuition/imageclass'

   MODULE '*amiAuthTotp','*amiAuthPrefs','*amiAuthTime','*sha256'

#date verstring '$VER: AmiAuthenticator (Reaction) 0.1.0 (%d.%aM.%Y)' 

OBJECT passwordForm
	winMain               :	PTR TO LONG
	strOldMasterPass      :	PTR TO LONG
	strNewMasterPass      :	PTR TO LONG
	strConfirmMasterPass  :	PTR TO LONG
	lblOldMasterPass      :	PTR TO LONG
	lblNewMasterPass      :	PTR TO LONG
	lblConfirmMasterPass  :	PTR TO LONG
  btnOk                 :	PTR TO LONG
  btnCancel             :	PTR TO LONG
ENDOBJECT

OBJECT itemForm
	winMain         :	PTR TO LONG
  labels          :	PTR TO LONG
	strName         :	PTR TO LONG
	strSecret       :	PTR TO LONG
	cycType         :	PTR TO LONG
	btnOk           :	PTR TO LONG
	btnCancel       :	PTR TO LONG
ENDOBJECT

OBJECT itemsForm
	winMain       :	PTR TO LONG
  listItems     :	PTR TO LONG
	lvItems       :	PTR TO LONG
	btnMoveUp     :	PTR TO LONG
	btnMoveDown   :	PTR TO LONG
	btnAdd        :	PTR TO LONG
	btnEdit       :	PTR TO LONG
	btnDelete     :	PTR TO LONG
	btnOk         :	PTR TO LONG
	btnCancel     :	PTR TO LONG
ENDOBJECT

OBJECT prefsForm
  winMain                :	PTR TO LONG
  chkUseNtp              :	PTR TO LONG
  chkUseTzLib            :	PTR TO LONG
  sldManualOffset        :	PTR TO LONG
  txtManualOffset        :	PTR TO LONG
  btnOk                  :	PTR TO LONG
  btnCancel              :	PTR TO LONG
  tzLabelText            :	PTR TO CHAR
ENDOBJECT

OBJECT reactionUI
  winMain                :	PTR TO LONG
  timeLabel              :	PTR TO LONG
  timeText               :	PTR TO LONG
  itemScroll             :	PTR TO LONG
  itemBevel              :	PTR TO LONG
  noItemsText            :	PTR TO LONG
  menus                  :	PTR TO LONG
  masterpass1: PTR TO CHAR
  masterpass2: PTR TO CHAR
  lastscroll: INT
ENDOBJECT

DEF totpItems:PTR TO LONG
DEF uiPrefs:PTR TO prefs
DEF uiTimedata:PTR TO timedata
DEF newitems:PTR TO LONG
DEF timeVal:PTR TO CHAR
DEF reactionUI:PTR TO reactionUI
DEF forceRefresh

CONST YSIZE=44

PROC create(type,ver45) OF passwordForm
  DEF height

  IF type=1
    self.strOldMasterPass:=StringObject,
            GA_ID, 0,
            GA_RELVERIFY, TRUE,
            GA_TABCYCLE, TRUE,
            STRINGA_MAXCHARS, 80,
            IF ver45 THEN STRINGA_HOOKTYPE ELSE TAG_IGNORE,IF ver45 THEN SHK_PASSWORD ELSE TAG_IGNORE,
          StringEnd
    self.lblOldMasterPass:=LabelObject,
            LABEL_TEXT, 'Old Password',
          LabelEnd
  ENDIF

  self.strNewMasterPass:=StringObject,
				  GA_ID, 1,
				  GA_RELVERIFY, TRUE,
				  GA_TABCYCLE, TRUE,
				  STRINGA_MAXCHARS, 80,
          IF ver45 THEN STRINGA_HOOKTYPE ELSE TAG_IGNORE,IF ver45 THEN SHK_PASSWORD ELSE TAG_IGNORE,
				StringEnd
  self.lblNewMasterPass:=LabelObject,
				LabelEnd

  IF type<>2
    self.strConfirmMasterPass:=StringObject,
            GA_ID, 2,
            GA_RELVERIFY, TRUE,
            GA_TABCYCLE, TRUE,
            STRINGA_MAXCHARS, 80,
            IF ver45 THEN STRINGA_HOOKTYPE ELSE TAG_IGNORE,IF ver45 THEN SHK_PASSWORD ELSE TAG_IGNORE,
          StringEnd
    self.lblConfirmMasterPass:=LabelObject,
            LABEL_TEXT, 'Confirm Password',
          LabelEnd
  ENDIF

  SELECT type
    CASE 0
      height:=75
    CASE 1
      height:=100
    CASE 2
      height:=50
  ENDSELECT
  
  self.winMain:=WindowObject,
    WA_TITLE, '',
    WA_LEFT, 100,
    WA_TOP, 100,
    WA_WIDTH, 350,
    WA_HEIGHT, height,
		WA_MINWIDTH, 350,
		WA_MAXWIDTH, 8192,
		WA_MINHEIGHT, height,
		WA_MAXHEIGHT, 8192,
    WA_PUBSCREEN, NIL,
    WA_CLOSEGADGET, TRUE,
    WA_DEPTHGADGET, TRUE,
    WA_SIZEGADGET, TRUE,
    WA_DRAGBAR, TRUE,
    WA_NOCAREREFRESH, TRUE,
    WA_ACTIVATE,TRUE,
    WA_IDCMP, IDCMP_GADGETDOWN OR IDCMP_GADGETUP OR IDCMP_CLOSEWINDOW, 

		WINDOW_PARENTGROUP, VLayoutObject,
		LAYOUT_DEFERLAYOUT, TRUE,
      LAYOUT_ADDCHILD, LayoutObject,
				LAYOUT_DEFERLAYOUT, FALSE,
				LAYOUT_SPACEOUTER, FALSE,
				LAYOUT_BOTTOMSPACING, 2,
				LAYOUT_TOPSPACING, 2,
				LAYOUT_LEFTSPACING, 2,
				LAYOUT_RIGHTSPACING, 2,
				LAYOUT_ORIENTATION, LAYOUT_ORIENT_VERT,
				LAYOUT_HORIZALIGNMENT, LALIGN_LEFT,
				LAYOUT_VERTALIGNMENT, LALIGN_TOP,
				LAYOUT_BEVELSTATE, IDS_SELECTED,
				LAYOUT_FIXEDHORIZ, TRUE,
				LAYOUT_FIXEDVERT, TRUE,
				LAYOUT_SPACEINNER, TRUE,

/*type=2 = verify (newmasterpass only)
type=0 = set (newmasterpass,confirmmaster pass)
type=1 = update(all)*/



				IF type=1 THEN LAYOUT_ADDCHILD ELSE TAG_IGNORE,  IF type=1 THEN self.strOldMasterPass ELSE TAG_IGNORE,
        IF type=1 THEN CHILD_LABEL ELSE TAG_IGNORE,  IF type=1 THEN self.lblOldMasterPass ELSE TAG_IGNORE,
				LAYOUT_ADDCHILD,self.strNewMasterPass,
        CHILD_LABEL, self.lblNewMasterPass,
				IF type<>2 THEN LAYOUT_ADDCHILD ELSE TAG_IGNORE,  IF type<>2 THEN self.strConfirmMasterPass ELSE TAG_IGNORE,
        IF type<>2 THEN CHILD_LABEL ELSE TAG_IGNORE,  IF type<>2 THEN self.lblConfirmMasterPass ELSE TAG_IGNORE,

				LAYOUT_ADDCHILD, LayoutObject,
					LAYOUT_DEFERLAYOUT, FALSE,
					LAYOUT_SPACEOUTER, FALSE,
					LAYOUT_BOTTOMSPACING, 2,
					LAYOUT_TOPSPACING, 2,
					LAYOUT_LEFTSPACING, 2,
					LAYOUT_RIGHTSPACING, 2,
					LAYOUT_ORIENTATION, LAYOUT_ORIENT_HORIZ,
					LAYOUT_HORIZALIGNMENT, LALIGN_LEFT,
					LAYOUT_VERTALIGNMENT, LALIGN_TOP,
					LAYOUT_BEVELSTATE, IDS_SELECTED,
					LAYOUT_FIXEDHORIZ, TRUE,
					LAYOUT_FIXEDVERT, TRUE,
					LAYOUT_SPACEINNER, TRUE,

					LAYOUT_ADDCHILD, SpaceObject,
					SpaceEnd,

					LAYOUT_ADDCHILD,  self.btnOk:=ButtonObject,
					  GA_ID, 3,
					  GA_TEXT, 'Ok',
					  GA_RELVERIFY, TRUE,
					  GA_TABCYCLE, TRUE,
					  BUTTON_TEXTPEN, 1,
					  BUTTON_BACKGROUNDPEN, 0,
					  BUTTON_FILLTEXTPEN, 1,
					  BUTTON_FILLPEN, 3,
					  BUTTON_BEVELSTYLE, BVS_BUTTON,
					  BUTTON_JUSTIFICATION, BCJ_CENTER,
					ButtonEnd,

					LAYOUT_ADDCHILD,  self.btnCancel:=ButtonObject,
					  GA_ID, 4,
					  GA_TEXT, 'Cancel',
					  GA_RELVERIFY, TRUE,
					  GA_TABCYCLE, TRUE,
					  BUTTON_TEXTPEN, 1,
					  BUTTON_BACKGROUNDPEN, 0,
					  BUTTON_FILLTEXTPEN, 1,
					  BUTTON_FILLPEN, 3,
					  BUTTON_BEVELSTYLE, BVS_BUTTON,
					  BUTTON_JUSTIFICATION, BCJ_CENTER,
					ButtonEnd,

				LayoutEnd,
			CHILD_WEIGHTMINIMUM, TRUE,
			LayoutEnd,
		LayoutEnd,
	WindowEnd
ENDPROC

PROC end() OF passwordForm
  DisposeObject(self.winMain)
ENDPROC

PROC setMasterPass() OF passwordForm
  DEF running=TRUE
  DEF win:PTR TO window,wsig,code,result,tmp,sig
  DEF v1,v2,cancel=FALSE

  Sets(self.winMain,WA_TITLE,'Set your master password')
  Sets(self.lblNewMasterPass,LABEL_TEXT,'Master password')
  
  IF (win:=RA_OpenWindow(self.winMain))


    GetAttr( WINDOW_SIGMASK, self.winMain, {wsig} )

    WHILE running
      sig:=Wait(wsig)
      IF (sig AND (wsig))
        WHILE ((result:=RA_HandleInput(self.winMain,{code})) <> WMHI_LASTMSG)
          tmp:=(result AND WMHI_CLASSMASK)

          SELECT tmp
            CASE WMHI_GADGETUP
              SELECT result AND $FFFF
                CASE 3  ->btnOk
                  v1:=Gets(self.strNewMasterPass,STRINGA_TEXTVAL)
                  v2:=Gets(self.strConfirmMasterPass,STRINGA_TEXTVAL)
                  IF StrLen(v1)=0
                    EasyRequestArgs(NIL,[20,0,'Error','You have not entered a master password','Ok'],NIL,NIL) 
                  ELSEIF StrLen(v2)=0
                    EasyRequestArgs(NIL,[20,0,'Error','You have not confirmed your master password','Ok'],NIL,NIL) 
                  ELSEIF StrCmp(v1,v2)=0
                    EasyRequestArgs(NIL,[20,0,'Error','You have not correctly confirmed your master password','Ok'],NIL,NIL) 
                  ELSE
                    calcSha256hex(v1,reactionUI.masterpass1)
                    calcSha1base32(v1,reactionUI.masterpass2)
                    running:=FALSE
                  ENDIF
                CASE 4  ->btnCancel
                  cancel:=TRUE
              ENDSELECT
            CASE WMHI_CLOSEWINDOW
              cancel:=TRUE
          ENDSELECT
          
          IF cancel
            cancel:=FALSE
            IF EasyRequestArgs(NIL,[20,0,'Warning','Not setting a master password will leave your secrets unsecured.\nDo you wish to continue?','Yes|No'],NIL,NIL)=1
              StrCopy(reactionUI.masterpass1,'#')
              running := FALSE
            ENDIF
          ENDIF
        ENDWHILE
      ENDIF
    ENDWHILE
    RA_CloseWindow(self.winMain)
  ELSE
    Raise("WIN")
  ENDIF
ENDPROC

PROC updateMasterPass() OF passwordForm
DEF running=TRUE
  DEF win:PTR TO window,wsig,code,result,tmp,sig
  DEF v1,v2,cancel=FALSE
  DEF tempStr[255]:STRING

  Sets(self.winMain,WA_TITLE,'Set your new master password')
  Sets(self.lblNewMasterPass,LABEL_TEXT,'New Password')
  Sets(self.strOldMasterPass,GA_DISABLED,StrCmp(reactionUI.masterpass1,'#'))
  
  IF (win:=RA_OpenWindow(self.winMain))


    GetAttr( WINDOW_SIGMASK, self.winMain, {wsig} )

    WHILE running
      sig:=Wait(wsig)
      IF (sig AND (wsig))
        WHILE ((result:=RA_HandleInput(self.winMain,{code})) <> WMHI_LASTMSG)
          tmp:=(result AND WMHI_CLASSMASK)

          SELECT tmp
            CASE WMHI_GADGETUP
              SELECT result AND $FFFF
                CASE 3  ->btnOk
                  v1:=Gets(self.strOldMasterPass,STRINGA_TEXTVAL)
                  IF (StrLen(v1)=0) AND (StrCmp(reactionUI.masterpass1,'#')=FALSE)
                    EasyRequestArgs(NIL,[20,0,'Error','You have not entered the old master password','Ok'],NIL,NIL) 
                  ELSE
                    calcSha256hex(v1,tempStr)
                    IF StrCmp(reactionUI.masterpass1,'#') OR StrCmp(reactionUI.masterpass1,tempStr)
                      v1:=Gets(self.strNewMasterPass,STRINGA_TEXTVAL)
                      v2:=Gets(self.strConfirmMasterPass,STRINGA_TEXTVAL)
                      IF StrLen(v1)=0
                        EasyRequestArgs(NIL,[20,0,'Error','You have not entered a new master password','Ok'],NIL,NIL) 
                      ELSEIF StrLen(v2)=0
                        EasyRequestArgs(NIL,[20,0,'Error','You have not confirmed your new master password','Ok'],NIL,NIL) 
                      ELSEIF StrCmp(v1,v2)=0
                        EasyRequestArgs(NIL,[20,0,'Error','You have not correctly confirmed your new master password','Ok'],NIL,NIL) 
                      ELSE
                        calcSha256hex(v1,reactionUI.masterpass1)
                        calcSha1base32(v1,reactionUI.masterpass2)
                        running:=FALSE
                      ENDIF          
                    ELSE
                      EasyRequestArgs(NIL,[20,0,'Error','Incorrect master password','Ok'],NIL,NIL) 
                    ENDIF
                  ENDIF
                CASE 4  ->btnCancel
                  running := FALSE
              ENDSELECT
            CASE WMHI_CLOSEWINDOW
              running := FALSE
          ENDSELECT
        ENDWHILE
      ENDIF
    ENDWHILE
    RA_CloseWindow(self.winMain)
  ELSE
    Raise("WIN")
  ENDIF
ENDPROC

PROC verifyMasterPass() OF passwordForm
  DEF running=TRUE
  DEF win:PTR TO window,wsig,code,result,tmp,sig
  DEF v1,v2,cancel=FALSE
  DEF tempStr[255]:STRING
    
  Sets(self.winMain,WA_TITLE,'Enter your master password')
  Sets(self.lblNewMasterPass,LABEL_TEXT,'Master password')
  
  IF (win:=RA_OpenWindow(self.winMain))

    GetAttr( WINDOW_SIGMASK, self.winMain, {wsig} )

    WHILE running
      sig:=Wait(wsig)
      IF (sig AND (wsig))
        WHILE ((result:=RA_HandleInput(self.winMain,{code})) <> WMHI_LASTMSG)
          tmp:=(result AND WMHI_CLASSMASK)

          SELECT tmp
            CASE WMHI_GADGETUP
              SELECT result AND $FFFF
                CASE 3  ->btnOk

                  v1:=Gets(self.strNewMasterPass,STRINGA_TEXTVAL)
                  IF StrLen(v1)=0
                    EasyRequestArgs(NIL,[20,0,'Error','You have not entered a master password','Ok'],NIL,NIL) 
                  ELSE
                    calcSha256hex(v1,tempStr)
                    
                    IF StrCmp(reactionUI.masterpass1,tempStr)
                      calcSha1base32(v1,reactionUI.masterpass2)
                      running:=FALSE
                    ELSE
                      EasyRequestArgs(NIL,[20,0,'Error','Incorrect master password','Ok'],NIL,NIL) 
                    ENDIF
                  ENDIF
                CASE 4  ->btnCancel
                  RA_CloseWindow(self.winMain)
                  Raise(-1)
              ENDSELECT
            CASE WMHI_CLOSEWINDOW
              RA_CloseWindow(self.winMain)
              Raise(-1)
          ENDSELECT
        ENDWHILE
      ENDIF
    ENDWHILE
    RA_CloseWindow(self.winMain)
  ELSE
    Raise("WIN")
  ENDIF
ENDPROC

PROC create() OF itemForm
  self.labels:=chooserLabelsA(['SHA1','SHA256',0])

  self.winMain:=WindowObject,
    WA_TITLE, 'Edit Items',
    WA_LEFT, 100,
    WA_TOP, 100,
    WA_WIDTH, 350,
    WA_HEIGHT, 100,
		WA_MINWIDTH, 350,
		WA_MAXWIDTH, 8192,
		WA_MINHEIGHT, 150,
		WA_MAXHEIGHT, 8192,
    WA_PUBSCREEN, NIL,
    WA_CLOSEGADGET, TRUE,
    WA_DEPTHGADGET, TRUE,
    WA_SIZEGADGET, TRUE,
    WA_DRAGBAR, TRUE,
    WA_NOCAREREFRESH, TRUE,
    WA_ACTIVATE,TRUE,
    WA_IDCMP, IDCMP_GADGETDOWN OR IDCMP_GADGETUP OR IDCMP_CLOSEWINDOW, 

		WINDOW_PARENTGROUP, VLayoutObject,
		LAYOUT_DEFERLAYOUT, TRUE,
			LAYOUT_ADDCHILD, LayoutObject,
				LAYOUT_DEFERLAYOUT, FALSE,
				LAYOUT_SPACEOUTER, FALSE,
				LAYOUT_BOTTOMSPACING, 2,
				LAYOUT_TOPSPACING, 2,
				LAYOUT_LEFTSPACING, 2,
				LAYOUT_RIGHTSPACING, 2,
				LAYOUT_ORIENTATION, LAYOUT_ORIENT_VERT,
				LAYOUT_HORIZALIGNMENT, LALIGN_LEFT,
				LAYOUT_VERTALIGNMENT, LALIGN_TOP,
				LAYOUT_BEVELSTATE, IDS_SELECTED,
				LAYOUT_FIXEDHORIZ, TRUE,
				LAYOUT_FIXEDVERT, TRUE,
				LAYOUT_SPACEINNER, TRUE,

				LAYOUT_ADDCHILD,  self.strName:= StringObject,
				  GA_ID, 0,
				  GA_RELVERIFY, TRUE,
				  GA_TABCYCLE, TRUE,
				  STRINGA_MAXCHARS, 80,
				StringEnd,
				CHILD_LABEL, LabelObject,
					LABEL_TEXT, 'Name',
				LabelEnd,

				LAYOUT_ADDCHILD,  self.strSecret:= StringObject,
				  GA_ID, 1,
				  GA_RELVERIFY, TRUE,
				  GA_TABCYCLE, TRUE,
				  STRINGA_MAXCHARS, 80,
				StringEnd,
				CHILD_LABEL, LabelObject,
					LABEL_TEXT, 'Secret',
				LabelEnd,

				LAYOUT_ADDCHILD, self.cycType:= ChooserObject,
				  GA_ID, 2,
				  GA_RELVERIFY, TRUE,
				  GA_TABCYCLE, TRUE,
				  CHOOSER_POPUP, TRUE,
				  CHOOSER_MAXLABELS, 12,
				  CHOOSER_ACTIVE, 0,
				  CHOOSER_WIDTH, -1,
				  CHOOSER_LABELS, self.labels,
				ChooserEnd,
				CHILD_LABEL, LabelObject,
					LABEL_TEXT, 'Type',
				LabelEnd,

				LAYOUT_ADDCHILD, LayoutObject,
					LAYOUT_DEFERLAYOUT, FALSE,
					LAYOUT_SPACEOUTER, FALSE,
					LAYOUT_BOTTOMSPACING, 2,
					LAYOUT_TOPSPACING, 2,
					LAYOUT_LEFTSPACING, 2,
					LAYOUT_RIGHTSPACING, 2,
					LAYOUT_ORIENTATION, LAYOUT_ORIENT_HORIZ,
					LAYOUT_HORIZALIGNMENT, LALIGN_LEFT,
					LAYOUT_VERTALIGNMENT, LALIGN_TOP,
					LAYOUT_BEVELSTATE, IDS_SELECTED,
					LAYOUT_FIXEDHORIZ, TRUE,
					LAYOUT_FIXEDVERT, TRUE,
					LAYOUT_SPACEINNER, TRUE,

					LAYOUT_ADDCHILD, SpaceObject,
					SpaceEnd,

					LAYOUT_ADDCHILD,  self.btnOk:= ButtonObject,
					  GA_ID, 3,
					  GA_TEXT, 'Ok',
					  GA_RELVERIFY, TRUE,
					  GA_TABCYCLE, TRUE,
					  BUTTON_TEXTPEN, 1,
					  BUTTON_BACKGROUNDPEN, 0,
					  BUTTON_FILLTEXTPEN, 1,
					  BUTTON_FILLPEN, 3,
					  BUTTON_BEVELSTYLE, BVS_BUTTON,
					  BUTTON_JUSTIFICATION, BCJ_CENTER,
					ButtonEnd,

					LAYOUT_ADDCHILD,  self.btnCancel:=ButtonObject,
					  GA_ID, 4,
					  GA_TEXT, 'Cancel',
					  GA_RELVERIFY, TRUE,
					  GA_TABCYCLE, TRUE,
					  BUTTON_TEXTPEN, 1,
					  BUTTON_BACKGROUNDPEN, 0,
					  BUTTON_FILLTEXTPEN, 1,
					  BUTTON_FILLPEN, 3,
					  BUTTON_BEVELSTYLE, BVS_BUTTON,
					  BUTTON_JUSTIFICATION, BCJ_CENTER,
					ButtonEnd,

				LayoutEnd,
				CHILD_WEIGHTEDHEIGHT, 0,
			LayoutEnd,
		LayoutEnd,
	WindowEnd
ENDPROC

PROC end() OF itemForm
  freeChooserLabels(self.labels)
  DisposeObject(self.winMain)
ENDPROC

PROC addItem() OF itemForm
  DEF running=TRUE,runResult=TRUE
  DEF t:PTR TO totp
  DEF win:PTR TO window,wsig,code,result,tmp,sig,v
  DEF newnewitems:PTR TO LONG
  DEF tmpItem:PTR TO totp

  Sets(self.winMain,WA_TITLE,'Add New Item')
    

  IF (win:=RA_OpenWindow(self.winMain))
    SetGadgetAttrsA(self.strName,win,0,[STRINGA_TEXTVAL,'',0])
    SetGadgetAttrsA(self.strSecret,win,0,[STRINGA_TEXTVAL,'',0])
    SetGadgetAttrsA(self.cycType,win,0,[CHOOSER_SELECTED,0,0])

    GetAttr( WINDOW_SIGMASK, self.winMain, {wsig} )

    WHILE running
      sig:=Wait(wsig)
      IF (sig AND (wsig))
        WHILE ((result:=RA_HandleInput(self.winMain,{code})) <> WMHI_LASTMSG)
          tmp:=(result AND WMHI_CLASSMASK)

          SELECT tmp
            CASE WMHI_GADGETUP
              SELECT result AND $FFFF
                CASE 3
                  
                  v:=Gets(self.strName,STRINGA_TEXTVAL)
                  IF StrLen(v)=0
                    EasyRequestArgs(NIL,[20,0,'Error','You must enter a name','Ok'],NIL,NIL) 
                  ELSE
                    v:=Gets(self.strSecret,STRINGA_TEXTVAL)
                    IF StrLen(v)=0
                      EasyRequestArgs(NIL,[20,0,'Error','You must enter a secret','Ok'],NIL,NIL) 
                    ELSE
                      NEW tmpItem.create()
                      StrCopy(tmpItem.secret,v)
                      IF tmpItem.makeKey()=0
                        EasyRequestArgs(NIL,[20,0,'Error','The secret is not valid','Ok'],NIL,NIL) 
                      ELSE
                        running:=FALSE
                        runResult:=TRUE
                      ENDIF
                    ENDIF
                  ENDIF
                  ->btnok
                CASE 4
                  ->btncancel
                  running:=FALSE
                  runResult:=FALSE
              ENDSELECT
            CASE WMHI_CLOSEWINDOW
                  running:=FALSE
                  runResult:=FALSE
          ENDSELECT
        ENDWHILE
      ENDIF
    ENDWHILE
    RA_CloseWindow(self.winMain)
  ELSE
    Raise("WIN")
  ENDIF

  IF runResult
    NEW t.create()
    v:=Gets(self.strName,STRINGA_TEXTVAL)
    StrCopy(t.name,v)
    v:=Gets(self.strSecret,STRINGA_TEXTVAL)
    StrCopy(t.secret,v)
    t.type:=Gets(self.cycType,CHOOSER_SELECTED)
    IF ListLen(newitems)=ListMax(newitems)
      newnewitems:=List(ListMax(newitems)+10)
      ListAdd(newnewitems,newitems)
      DisposeLink(newitems)
      newitems:=newnewitems
    ENDIF
    ListAddItem(newitems,t)
  ENDIF
ENDPROC runResult

PROC editItem(item:PTR TO totp) OF itemForm
  DEF running=TRUE,runResult=TRUE
  DEF t:PTR TO totp
  DEF win:PTR TO window,wsig,code,result,tmp,sig,v
  DEF newnewitems:PTR TO LONG
  DEF tmpItem:PTR TO totp

  Sets(self.winMain,WA_TITLE,'Edit Item')

  IF (win:=RA_OpenWindow(self.winMain))
    SetGadgetAttrsA(self.strName,win,0,[STRINGA_TEXTVAL,item.name,0])
    SetGadgetAttrsA(self.strSecret,win,0,[STRINGA_TEXTVAL,item.secret,0])
    SetGadgetAttrsA(self.cycType,win,0,[CHOOSER_SELECTED,item.type,0])

    GetAttr( WINDOW_SIGMASK, self.winMain, {wsig} )

    WHILE running
      sig:=Wait(wsig)
      IF (sig AND (wsig))
        WHILE ((result:=RA_HandleInput(self.winMain,{code})) <> WMHI_LASTMSG)
          tmp:=(result AND WMHI_CLASSMASK)

          SELECT tmp
            CASE WMHI_GADGETUP
              SELECT result AND $FFFF
                CASE 3
                  ->btnok                 
                  v:=Gets(self.strName,STRINGA_TEXTVAL)
                  IF StrLen(v)=0
                    EasyRequestArgs(NIL,[20,0,'Error','You must enter a name','Ok'],NIL,NIL) 
                  ELSE
                    v:=Gets(self.strSecret,STRINGA_TEXTVAL)
                    IF StrLen(v)=0
                      EasyRequestArgs(NIL,[20,0,'Error','You must enter a secret','Ok'],NIL,NIL) 
                    ELSE
                      NEW tmpItem.create()
                      StrCopy(tmpItem.secret,v)
                      IF tmpItem.makeKey()=0
                        EasyRequestArgs(NIL,[20,0,'Error','The secret is not valid','Ok'],NIL,NIL) 
                      ELSE
                        running:=FALSE
                        runResult:=TRUE
                      ENDIF
                    ENDIF
                  ENDIF
                CASE 4
                  ->btncancel
                  running:=FALSE
                  runResult:=FALSE
              ENDSELECT
            CASE WMHI_CLOSEWINDOW
                  running:=FALSE
                  runResult:=FALSE
          ENDSELECT
        ENDWHILE
      ENDIF
    ENDWHILE
    RA_CloseWindow(self.winMain)
  ELSE
    Raise("WIN")
  ENDIF

  IF runResult
    v:=Gets(self.strName,STRINGA_TEXTVAL)
    StrCopy(item.name,v)
    v:=Gets(self.strSecret,STRINGA_TEXTVAL)
    StrCopy(item.secret,v)
    item.type:=Gets(self.cycType,CHOOSER_SELECTED)
  ENDIF
ENDPROC runResult

PROC create() OF itemsForm
  self.listItems:=browserNodesA([0])

  self.winMain:=WindowObject,
  
    WA_TITLE, 'Edit Items',
    WA_LEFT, 100,
    WA_TOP, 100,
    WA_WIDTH, 350,
    WA_HEIGHT, 200,
		WA_MINWIDTH, 350,
		WA_MAXWIDTH, 8192,
		WA_MINHEIGHT, 150,
		WA_MAXHEIGHT, 8192,
    WA_PUBSCREEN, NIL,
    WA_CLOSEGADGET, TRUE,
    WA_DEPTHGADGET, TRUE,
    WA_SIZEGADGET, TRUE,
    WA_DRAGBAR, TRUE,
    WA_NOCAREREFRESH, TRUE,
    WA_ACTIVATE,TRUE,
    WA_IDCMP, IDCMP_GADGETDOWN OR IDCMP_GADGETUP OR IDCMP_CLOSEWINDOW, 

		WINDOW_PARENTGROUP, VLayoutObject,
		LAYOUT_DEFERLAYOUT, TRUE,
			LAYOUT_ADDCHILD, LayoutObject,
				LAYOUT_DEFERLAYOUT, FALSE,
				LAYOUT_SPACEOUTER, FALSE,
				LAYOUT_BOTTOMSPACING, 2,
				LAYOUT_TOPSPACING, 2,
				LAYOUT_LEFTSPACING, 2,
				LAYOUT_RIGHTSPACING, 2,
				LAYOUT_ORIENTATION, LAYOUT_ORIENT_VERT,
				LAYOUT_HORIZALIGNMENT, LALIGN_LEFT,
				LAYOUT_VERTALIGNMENT, LALIGN_TOP,
				LAYOUT_BEVELSTATE, IDS_SELECTED,
				LAYOUT_FIXEDHORIZ, TRUE,
				LAYOUT_FIXEDVERT, TRUE,
				LAYOUT_SPACEINNER, TRUE,

				LAYOUT_ADDCHILD, LayoutObject,
					LAYOUT_DEFERLAYOUT, FALSE,
					LAYOUT_SPACEOUTER, FALSE,
					LAYOUT_BOTTOMSPACING, 2,
					LAYOUT_TOPSPACING, 2,
					LAYOUT_LEFTSPACING, 2,
					LAYOUT_RIGHTSPACING, 2,
					LAYOUT_ORIENTATION, LAYOUT_ORIENT_HORIZ,
					LAYOUT_HORIZALIGNMENT, LALIGN_LEFT,
					LAYOUT_VERTALIGNMENT, LALIGN_TOP,
					LAYOUT_BEVELSTATE, IDS_SELECTED,
					LAYOUT_FIXEDHORIZ, TRUE,
					LAYOUT_FIXEDVERT, TRUE,
					LAYOUT_SPACEINNER, TRUE,

					LAYOUT_ADDCHILD, self.lvItems:=ListBrowserObject,
					  GA_ID, 0,
					  GA_RELVERIFY, TRUE,
					  LISTBROWSER_POSITION, 0,
					  LISTBROWSER_SHOWSELECTED, TRUE,
					  LISTBROWSER_VERTSEPARATORS, TRUE,
					  LISTBROWSER_SEPARATORS, TRUE,
					  LISTBROWSER_LABELS, self.listItems,
					ListBrowserEnd,
          CHILD_MINWIDTH,100,
          CHILD_MINHEIGHT,100,


					LAYOUT_ADDCHILD, LayoutObject,
						LAYOUT_DEFERLAYOUT, FALSE,
						LAYOUT_SPACEOUTER, FALSE,
						LAYOUT_BOTTOMSPACING, 2,
						LAYOUT_TOPSPACING, 2,
						LAYOUT_LEFTSPACING, 2,
						LAYOUT_RIGHTSPACING, 2,
						LAYOUT_ORIENTATION, LAYOUT_ORIENT_VERT,
						LAYOUT_HORIZALIGNMENT, LALIGN_LEFT,
						LAYOUT_VERTALIGNMENT, LALIGN_TOP,
						LAYOUT_BEVELSTATE, IDS_SELECTED,
						LAYOUT_FIXEDHORIZ, TRUE,
						LAYOUT_FIXEDVERT, TRUE,
						LAYOUT_SPACEINNER, TRUE,

						LAYOUT_ADDCHILD, self.btnMoveUp:=ButtonObject,
						  GA_ID, 1,
						  GA_TEXT, 'Move Up',
						  GA_RELVERIFY, TRUE,
						  GA_TABCYCLE, TRUE,
						  BUTTON_TEXTPEN, 1,
						  BUTTON_BACKGROUNDPEN, 0,
						  BUTTON_FILLTEXTPEN, 1,
						  BUTTON_FILLPEN, 3,
						  BUTTON_BEVELSTYLE, BVS_BUTTON,
						  BUTTON_JUSTIFICATION, BCJ_CENTER,
						ButtonEnd,

						LAYOUT_ADDCHILD,  self.btnMoveDown:=ButtonObject,
						  GA_ID, 2,
						  GA_TEXT, 'Move Down',
						  GA_RELVERIFY, TRUE,
						  GA_TABCYCLE, TRUE,
						  BUTTON_TEXTPEN, 1,
						  BUTTON_BACKGROUNDPEN, 0,
						  BUTTON_FILLTEXTPEN, 1,
						  BUTTON_FILLPEN, 3,
						  BUTTON_BEVELSTYLE, BVS_BUTTON,
						  BUTTON_JUSTIFICATION, BCJ_CENTER,
						ButtonEnd,

						LAYOUT_ADDCHILD,  self.btnAdd:= ButtonObject,
						  GA_ID, 3,
						  GA_TEXT, 'Add',
						  GA_RELVERIFY, TRUE,
						  GA_TABCYCLE, TRUE,
						  BUTTON_TEXTPEN, 1,
						  BUTTON_BACKGROUNDPEN, 0,
						  BUTTON_FILLTEXTPEN, 1,
						  BUTTON_FILLPEN, 3,
						  BUTTON_BEVELSTYLE, BVS_BUTTON,
						  BUTTON_JUSTIFICATION, BCJ_CENTER,
						ButtonEnd,

						LAYOUT_ADDCHILD,  self.btnEdit:=ButtonObject,
						  GA_ID, 4,
						  GA_TEXT, 'Edit',
						  GA_RELVERIFY, TRUE,
						  GA_TABCYCLE, TRUE,
						  BUTTON_TEXTPEN, 1,
						  BUTTON_BACKGROUNDPEN, 0,
						  BUTTON_FILLTEXTPEN, 1,
						  BUTTON_FILLPEN, 3,
						  BUTTON_BEVELSTYLE, BVS_BUTTON,
						  BUTTON_JUSTIFICATION, BCJ_CENTER,
						ButtonEnd,

						LAYOUT_ADDCHILD,  self.btnDelete:=ButtonObject,
						  GA_ID, 5,
						  GA_TEXT, 'Delete',
						  GA_RELVERIFY, TRUE,
						  GA_TABCYCLE, TRUE,
						  BUTTON_TEXTPEN, 1,
						  BUTTON_BACKGROUNDPEN, 0,
						  BUTTON_FILLTEXTPEN, 1,
						  BUTTON_FILLPEN, 3,
						  BUTTON_BEVELSTYLE, BVS_BUTTON,
						  BUTTON_JUSTIFICATION, BCJ_CENTER,
						ButtonEnd,

				  LayoutEnd,

					CHILD_WEIGHTMINIMUM, TRUE,

				LayoutEnd,

				LAYOUT_ADDCHILD, LayoutObject,
					LAYOUT_DEFERLAYOUT, FALSE,
					LAYOUT_SPACEOUTER, FALSE,
					LAYOUT_BOTTOMSPACING, 2,
					LAYOUT_TOPSPACING, 2,
					LAYOUT_LEFTSPACING, 2,
					LAYOUT_RIGHTSPACING, 2,
					LAYOUT_ORIENTATION, LAYOUT_ORIENT_HORIZ,
					LAYOUT_HORIZALIGNMENT, LALIGN_LEFT,
					LAYOUT_VERTALIGNMENT, LALIGN_TOP,
					LAYOUT_BEVELSTATE, IDS_SELECTED,
					LAYOUT_FIXEDHORIZ, TRUE,
					LAYOUT_FIXEDVERT, TRUE,
					LAYOUT_SPACEINNER, TRUE,

					LAYOUT_ADDCHILD, SpaceObject,
					SpaceEnd,

					LAYOUT_ADDCHILD, self.btnOk:= ButtonObject,
					  GA_ID, 6,
					  GA_TEXT, 'Ok',
					  GA_RELVERIFY, TRUE,
					  GA_TABCYCLE, TRUE,
					  BUTTON_TEXTPEN, 1,
					  BUTTON_BACKGROUNDPEN, 0,
					  BUTTON_FILLTEXTPEN, 1,
					  BUTTON_FILLPEN, 3,
					  BUTTON_BEVELSTYLE, BVS_BUTTON,
					  BUTTON_JUSTIFICATION, BCJ_CENTER,
					ButtonEnd,
					CHILD_WEIGHTMINIMUM, TRUE,

					LAYOUT_ADDCHILD,  self.btnCancel:= ButtonObject,
					  GA_ID, 7,
					  GA_TEXT, 'Cancel',
					  GA_RELVERIFY, TRUE,
					  GA_TABCYCLE, TRUE,
					  BUTTON_TEXTPEN, 1,
					  BUTTON_BACKGROUNDPEN, 0,
					  BUTTON_FILLTEXTPEN, 1,
					  BUTTON_FILLPEN, 3,
					  BUTTON_BEVELSTYLE, BVS_BUTTON,
					  BUTTON_JUSTIFICATION, BCJ_CENTER,
					ButtonEnd,
					CHILD_WEIGHTMINIMUM, TRUE,

				LayoutEnd,
					CHILD_WEIGHTMINIMUM, TRUE,
			LayoutEnd,
		LayoutEnd,
	WindowEnd
ENDPROC

PROC end() OF itemsForm
  freeBrowserNodes( self.listItems )
  DisposeObject(self.winMain)
ENDPROC

PROC makeList(items:PTR TO LONG,win,newpos) OF itemsForm
  DEF item:PTR TO totp
  DEF i,n

  IF newpos=-1 THEN newpos:=Gets(self.lvItems,LISTBROWSER_SELECTED)

  SetGadgetAttrsA(self.lvItems,win,0,[LISTBROWSER_LABELS, 0,0])
  freeBrowserNodes( self.listItems )
  
  self.listItems:=browserNodesA([0])
 
  FOR i:=0 TO ListLen(items)-1
    item:=items[i]
    IF (n:=AllocListBrowserNodeA(1, [LBNCA_COPYTEXT, TRUE, LBNCA_TEXT, item.name, TAG_END])) THEN AddTail(self.listItems, n) ELSE Raise("MEM")
  ENDFOR
-> Reattach the list

  SetGadgetAttrsA(self.lvItems,win,0,[LISTBROWSER_LABELS, self.listItems,0])
  SetGadgetAttrsA(self.lvItems,win,0,[LISTBROWSER_SELECTED, newpos,0])
  self.updateSel(win,newpos)
ENDPROC

PROC updateSel(win,sel) OF itemsForm
  IF sel=-1
    SetGadgetAttrsA(self.btnMoveUp,win,0,[GA_DISABLED,TRUE,0])
    SetGadgetAttrsA(self.btnMoveDown,win,0,[GA_DISABLED,TRUE,0])
    SetGadgetAttrsA(self.btnDelete,win,0,[GA_DISABLED,TRUE,0])
    SetGadgetAttrsA(self.btnEdit,win,0,[GA_DISABLED,TRUE,0])
  ELSE
    SetGadgetAttrsA(self.btnMoveUp,win,0,[GA_DISABLED,IF sel=0 THEN TRUE ELSE FALSE,0])
    SetGadgetAttrsA(self.btnMoveDown,win,0,[GA_DISABLED,IF sel=(ListLen(newitems)-1) THEN TRUE ELSE FALSE,0])
    SetGadgetAttrsA(self.btnEdit,win,0,[GA_DISABLED,FALSE,0])
    SetGadgetAttrsA(self.btnDelete,win,0,[GA_DISABLED,FALSE,0])
  ENDIF
ENDPROC

PROC editItems() OF itemsForm
  DEF running=TRUE,runResult=TRUE
  DEF win:PTR TO window,wsig,code,result,tmp,sig,i,j,found
  DEF itemForm:PTR TO itemForm
  DEF item:PTR TO totp
  DEF v,nd

  SetList(newitems,0)
  ListAdd(newitems,totpItems)

  
  IF (win:=RA_OpenWindow(self.winMain))
  
    self.makeList(newitems,win,-1)
    self.updateSel(win,-1)

    GetAttr( WINDOW_SIGMASK, self.winMain, {wsig} )

    WHILE running
      sig:=Wait(wsig)
      IF (sig AND (wsig))
        WHILE ((result:=RA_HandleInput(self.winMain,{code})) <> WMHI_LASTMSG)
          tmp:=(result AND WMHI_CLASSMASK)

          SELECT tmp
            CASE WMHI_GADGETUP
              SELECT result AND $FFFF
                CASE 0
                  v:=Gets(self.lvItems,LISTBROWSER_SELECTED)
                  self.updateSel(win,v)
                CASE 1
                  -> Move up
                  v:=Gets(self.lvItems,LISTBROWSER_SELECTED)
                  IF v>=1
                    tmp:=newitems[v-1]
                    newitems[v-1]:=newitems[v]
                    newitems[v]:=tmp
                    self.makeList(newitems,win,v-1)
                  ENDIF
                CASE 2
                  -> Move Down
                  v:=Gets(self.lvItems,LISTBROWSER_SELECTED)
                  IF v<(ListLen(newitems)-1)
                    tmp:=newitems[v]
                    newitems[v]:=newitems[v+1]
                    newitems[v+1]:=tmp
                    self.makeList(newitems,win,v+1)
                  ENDIF
                CASE 3
                  -> Add
                  NEW itemForm.create()
                  IF itemForm.addItem() THEN self.makeList(newitems,win,-1)
                  END itemForm
                CASE 4
                  -> Edit
                  v:=Gets(self.lvItems,LISTBROWSER_SELECTED)
                  IF v>=0
                    NEW itemForm.create()
                    IF itemForm.editItem(newitems[v]) THEN self.makeList(newitems,win,-1)
                    END itemForm
                  ENDIF
                CASE 5
                  -> Delete
                  v:=Gets(self.lvItems,LISTBROWSER_SELECTED)
                  IF (v>=0) AND (v<ListLen(newitems))
                    FOR i:=v+1 TO ListLen(newitems)-1
                      newitems[i-1]:=newitems[i]
                    ENDFOR
                    SetList(newitems,ListLen(newitems)-1)
                    self.makeList(newitems,win,-1)
                  ENDIF
                CASE 6
                  ->btnok
                  running:=FALSE
                  runResult:=TRUE
                CASE 7
                  ->btncancel
                  running:=FALSE
                  runResult:=FALSE
              ENDSELECT
            CASE WMHI_CLOSEWINDOW
                  running:=FALSE
                  runResult:=FALSE
          ENDSELECT
        ENDWHILE
      ENDIF
    ENDWHILE
    RA_CloseWindow(self.winMain)
  ELSE
    Raise("WIN")
  ENDIF

  IF runResult

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
ENDPROC

PROC create() OF prefsForm

self.chkUseNtp:=CheckBoxObject,
				  GA_ID, 0,
				  GA_RELVERIFY, TRUE,
				  GA_TABCYCLE, TRUE,
				  GA_TEXT, 'Get time from internet',
				  CHECKBOX_TEXTPEN, 1,
				  CHECKBOX_BACKGROUNDPEN, 0,
				  CHECKBOX_FILLTEXTPEN, 1,
				  CHECKBOX_TEXTPLACE, PLACETEXT_LEFT,
				CheckBoxEnd

self.chkUseTzLib:=CheckBoxObject,
				  GA_ID, 1,
				  GA_RELVERIFY, TRUE,
				  GA_TABCYCLE, TRUE,
				  GA_TEXT, 'Use tz library to get time',
				  CHECKBOX_TEXTPEN, 1,
				  CHECKBOX_BACKGROUNDPEN, 0,
				  CHECKBOX_FILLTEXTPEN, 1,
				  CHECKBOX_TEXTPLACE, PLACETEXT_LEFT,
				CheckBoxEnd

self.txtManualOffset:= StringObject,
              GA_ID, 0,
              GA_RELVERIFY, TRUE,
              GA_TABCYCLE, TRUE,
              STRINGA_MAXCHARS, 80,
              GA_READONLY,TRUE,
            StringEnd

self.sldManualOffset:=ScrollerObject,
				  GA_ID, 2,
				  GA_TEXT, 'xxxxx',
				  GA_RELVERIFY, TRUE,
				  GA_TABCYCLE, TRUE,
				  SCROLLER_TOP, 0,
				  SCROLLER_VISIBLE, 0,
				  SCROLLER_TOTAL, 1441,
				  SCROLLER_ARROWDELTA, 30,
				  SCROLLER_ORIENTATION, SORIENT_HORIZ,
				ScrollerEnd
        
  self.winMain:=WindowObject,
    WA_TITLE, 'Edit Settings',
    WA_LEFT, 100,
    WA_TOP, 100,
    WA_WIDTH, 320,
    WA_HEIGHT, 110,
		WA_MINWIDTH, 350,
		WA_MAXWIDTH, 8192,
		WA_MINHEIGHT, 150,
		WA_MAXHEIGHT, 8192,
    WA_PUBSCREEN, NIL,
    WA_CLOSEGADGET, TRUE,
    WA_DEPTHGADGET, TRUE,
    WA_SIZEGADGET, FALSE,
    WA_DRAGBAR, TRUE,
    WA_NOCAREREFRESH, TRUE,
    WA_ACTIVATE,TRUE,
    WA_IDCMP, IDCMP_GADGETDOWN OR IDCMP_GADGETUP OR IDCMP_CLOSEWINDOW, 
    
    WINDOW_PARENTGROUP, VLayoutObject,
    LAYOUT_DEFERLAYOUT, TRUE,
		LAYOUT_DEFERLAYOUT, TRUE,
			LAYOUT_ADDCHILD, LayoutObject,
				LAYOUT_DEFERLAYOUT, FALSE,
				LAYOUT_SPACEOUTER, FALSE,
				LAYOUT_BOTTOMSPACING, 2,
				LAYOUT_TOPSPACING, 2,
				LAYOUT_LEFTSPACING, 2,
				LAYOUT_RIGHTSPACING, 2,
				LAYOUT_ORIENTATION, LAYOUT_ORIENT_VERT,
				LAYOUT_HORIZALIGNMENT, LALIGN_LEFT,
				LAYOUT_VERTALIGNMENT, LALIGN_TOP,
				LAYOUT_BEVELSTATE, IDS_SELECTED,
				LAYOUT_FIXEDHORIZ, TRUE,
				LAYOUT_FIXEDVERT, TRUE,
				LAYOUT_SPACEINNER, TRUE,

				LAYOUT_ADDCHILD, self.chkUseNtp,

				LAYOUT_ADDCHILD, self.chkUseTzLib,

				LAYOUT_ADDCHILD, self.txtManualOffset,

				LAYOUT_ADDCHILD, self.sldManualOffset,
					CHILD_MINHEIGHT, 14,
					CHILD_WEIGHTEDHEIGHT, 0,

          LAYOUT_ADDCHILD, LayoutObject,
					LAYOUT_DEFERLAYOUT, FALSE,
					LAYOUT_SPACEOUTER, FALSE,
					LAYOUT_BOTTOMSPACING, 2,
					LAYOUT_TOPSPACING, 2,
					LAYOUT_LEFTSPACING, 2,
					LAYOUT_RIGHTSPACING, 2,
					LAYOUT_ORIENTATION, LAYOUT_ORIENT_HORIZ,
					LAYOUT_HORIZALIGNMENT, LALIGN_LEFT,
					LAYOUT_VERTALIGNMENT, LALIGN_TOP,
					LAYOUT_BEVELSTATE, IDS_SELECTED,
					LAYOUT_FIXEDHORIZ, TRUE,
					LAYOUT_FIXEDVERT, TRUE,
					LAYOUT_SPACEINNER, TRUE,

					LAYOUT_ADDCHILD, SpaceObject,
					SpaceEnd,

					LAYOUT_ADDCHILD,  self.btnOk:=ButtonObject,
					  GA_ID, 3,
					  GA_TEXT, 'Ok',
					  GA_RELVERIFY, TRUE,
					  GA_TABCYCLE, TRUE,
					  BUTTON_TEXTPEN, 1,
					  BUTTON_BACKGROUNDPEN, 0,
					  BUTTON_FILLTEXTPEN, 1,
					  BUTTON_FILLPEN, 3,
					  BUTTON_BEVELSTYLE, BVS_BUTTON,
					  BUTTON_JUSTIFICATION, BCJ_CENTER,
					ButtonEnd,

					LAYOUT_ADDCHILD,  self.btnCancel:=ButtonObject,
					  GA_ID, 4,
					  GA_TEXT, 'Cancel',
					  GA_RELVERIFY, TRUE,
					  GA_TABCYCLE, TRUE,
					  BUTTON_TEXTPEN, 1,
					  BUTTON_BACKGROUNDPEN, 0,
					  BUTTON_FILLTEXTPEN, 1,
					  BUTTON_FILLPEN, 3,
					  BUTTON_BEVELSTYLE, BVS_BUTTON,
					  BUTTON_JUSTIFICATION, BCJ_CENTER,
					ButtonEnd,

				LayoutEnd,
			LayoutEnd,
		LayoutEnd,
  WindowEnd

ENDPROC

PROC end() OF prefsForm
  DisposeObject(self.winMain)
ENDPROC

PROC editPrefs() OF prefsForm
  DEF running=TRUE
  DEF win:PTR TO window,wsig,code,result,tmp,sig
  DEF s[255]:STRING
  DEF v

  self.tzLabelText:=s
  Sets(self.chkUseNtp,CHECKBOX_CHECKED,IF uiPrefs.readNtpTime THEN TRUE ELSE FALSE) 
  Sets(self.chkUseTzLib,CHECKBOX_CHECKED,IF uiPrefs.useTimezone THEN TRUE ELSE FALSE) 
  
  IF (win:=RA_OpenWindow(self.winMain))
    SetGadgetAttrsA(self.sldManualOffset,win,0,[SCROLLER_TOP,uiPrefs.userOffset+720,0]) 


    StringF(self.tzLabelText,'Manual timezone offset(hh:mm): \c\r\z\d[2]:\r\z\d[2]',IF uiPrefs.userOffset<0 THEN "-" ELSE " ",Div(Abs(uiPrefs.userOffset),60),Mod(Abs(uiPrefs.userOffset),60))
    SetGadgetAttrsA(self.txtManualOffset,win,0,[STRINGA_TEXTVAL,self.tzLabelText,0]) 

    GetAttr( WINDOW_SIGMASK, self.winMain, {wsig} )

    WHILE running
      sig:=Wait(wsig)
      IF (sig AND (wsig))
        WHILE ((result:=RA_HandleInput(self.winMain,{code})) <> WMHI_LASTMSG)
          tmp:=(result AND WMHI_CLASSMASK)

          SELECT tmp
            CASE WMHI_GADGETUP
              SELECT result AND $FFFF
                CASE 2
                  v:=Gets(self.sldManualOffset,SCROLLER_TOP)-720
                  StringF(self.tzLabelText,'Manual timezone offset(hh:mm): \c\r\z\d[2]:\r\z\d[2]',IF v<0 THEN "-" ELSE " ",Div(Abs(v),60),Mod(Abs(v),60))
                  SetGadgetAttrsA(self.txtManualOffset,win,0,[STRINGA_TEXTVAL,self.tzLabelText,0]) 
                CASE 3
                  v:=Gets(self.chkUseNtp,CHECKBOX_CHECKED)
                  uiPrefs.readNtpTime:=IF v THEN 1 ELSE 0
                  v:=Gets(self.chkUseTzLib,CHECKBOX_CHECKED)
                  uiPrefs.useTimezone:=IF v THEN 1 ELSE 0
                  v:=Gets(self.sldManualOffset,SCROLLER_TOP)-720
                  uiPrefs.userOffset:=v
                  calcUTCOffset(uiTimedata,uiPrefs)
                  running:=FALSE
                CASE 4
                  running:=FALSE
              ENDSELECT
            CASE WMHI_CLOSEWINDOW
                  running:=FALSE
          ENDSELECT
        ENDWHILE
      ENDIF
    ENDWHILE
    RA_CloseWindow(self.winMain)
  ELSE
    Raise("WIN")
  ENDIF

  ->Dispose(self.tzLabelText)
ENDPROC

PROC create() OF reactionUI
  DEF menuData:PTR TO newmenu,scr,visInfo

  NEW menuData[9]
  menuData[0].type:=NM_TITLE
  menuData[0].label:='Project'
  menuData[1].type:=NM_ITEM
  menuData[1].label:='Edit Items'
  menuData[2].type:=NM_ITEM
  menuData[2].label:='Edit Settings'
  menuData[3].type:=NM_ITEM
  menuData[3].label:='Change Master Password'
  menuData[4].type:=NM_ITEM
  menuData[4].label:=NM_BARLABEL
  menuData[5].type:=NM_ITEM
  menuData[5].label:='About'
  menuData[6].type:=NM_ITEM
  menuData[6].label:=NM_BARLABEL
  menuData[7].type:=NM_ITEM
  menuData[7].label:='Quit'
  menuData[8].type:=NM_END
            
  self.winMain:=WindowObject,
      WA_TITLE, 'Ami-Authenticator',
      WA_LEFT, 100,
      WA_TOP, 100,
      WA_WIDTH, 280,
      WA_HEIGHT, 280,
      WA_MINWIDTH, 350,
      WA_MAXWIDTH, 8192,
      WA_MINHEIGHT, 150,
      WA_MAXHEIGHT, 8192,
      WA_PUBSCREEN, NIL,
      WA_NEWLOOKMENUS, TRUE,
      ->WINDOW_NEWMENU, menuData,
      WA_CLOSEGADGET, TRUE,
      WA_DEPTHGADGET, TRUE,
      WA_SIZEGADGET, TRUE,
      WA_DRAGBAR, TRUE,
      WA_NOCAREREFRESH, TRUE,
      WA_ACTIVATE,TRUE,
      WA_IDCMP, IDCMP_GADGETDOWN OR IDCMP_GADGETUP OR IDCMP_CLOSEWINDOW OR IDCMP_MENUPICK OR IDCMP_INTUITICKS,
      WINDOW_PARENTGROUP, VLayoutObject,
      LAYOUT_DEFERLAYOUT, TRUE,
        LAYOUT_ADDCHILD, LayoutObject,
          LAYOUT_DEFERLAYOUT, FALSE,
          LAYOUT_SPACEOUTER, FALSE,
          LAYOUT_BOTTOMSPACING, 2,
          LAYOUT_TOPSPACING, 2,
          LAYOUT_LEFTSPACING, 2,
          LAYOUT_RIGHTSPACING, 2,
          LAYOUT_ORIENTATION, LAYOUT_ORIENT_VERT,
          LAYOUT_HORIZALIGNMENT, LALIGN_LEFT,
          LAYOUT_VERTALIGNMENT, LALIGN_TOP,
          LAYOUT_BEVELSTATE, IDS_SELECTED,
          LAYOUT_FIXEDHORIZ, TRUE,
          LAYOUT_FIXEDVERT, TRUE,
          LAYOUT_SPACEINNER, TRUE,

          LAYOUT_ADDCHILD,  self.timeText:= StringObject,
            GA_ID, 0,
            GA_RELVERIFY, TRUE,
            GA_TABCYCLE, TRUE,
            STRINGA_MAXCHARS, 80,
            GA_READONLY,TRUE,
          StringEnd,
          CHILD_LABEL,  self.timeLabel:= LabelObject,
            LABEL_TEXT, 'UTC Time',
          LabelEnd,

          LAYOUT_ADDCHILD, LayoutObject,
            LAYOUT_DEFERLAYOUT, FALSE,
            LAYOUT_SPACEOUTER, FALSE,
            LAYOUT_BOTTOMSPACING, 2,
            LAYOUT_TOPSPACING, 2,
            LAYOUT_LEFTSPACING, 2,
            LAYOUT_RIGHTSPACING, 2,
            LAYOUT_ORIENTATION, LAYOUT_ORIENT_HORIZ,
            LAYOUT_HORIZALIGNMENT, LALIGN_LEFT,
            LAYOUT_VERTALIGNMENT, LALIGN_TOP,
            LAYOUT_BEVELSTATE, IDS_SELECTED,
            LAYOUT_FIXEDHORIZ, TRUE,
            LAYOUT_FIXEDVERT, TRUE,
            LAYOUT_SPACEINNER, TRUE,

            LAYOUT_ADDIMAGE, self.itemBevel:= BevelObject,
              ->GA_DrawInfo, gDrinfo,
              IA_TOP, 0,
              IA_LEFT, 0,
              IA_WIDTH, 100,
              IA_HEIGHT, 100,
            BevelEnd,

            LAYOUT_ADDCHILD, self.itemScroll:= ScrollerObject,
              GA_ID, 2,
              GA_RELVERIFY, TRUE,
              GA_TABCYCLE, TRUE,
              SCROLLER_TOP, 0,
              SCROLLER_VISIBLE, 1,
              SCROLLER_TOTAL, 4,
              SCROLLER_ARROWDELTA, 9,
              SCROLLER_ORIENTATION, SORIENT_VERT,
              
            ScrollerEnd,
            CHILD_WEIGHTMINIMUM, TRUE,
            CHILD_MINHEIGHT, 100,

          LayoutEnd,

        LayoutEnd,
      LayoutEnd,
    WindowEnd

  self.menus:=CreateMenusA(menuData,[GTMN_FRONTPEN,1,TAG_END])

  scr:=LockPubScreen(NIL)
  visInfo:=GetVisualInfoA(scr, [TAG_END])
  UnlockPubScreen(NIL,scr)
  LayoutMenusA(reactionUI.menus,visInfo,[TAG_END])
  FreeVisualInfo(visInfo)
  self.lastscroll:=-1

ENDPROC

PROC end() OF reactionUI
  FreeMenus(self.menus)
  DisposeObject(reactionUI.winMain)
ENDPROC

PROC tickAction(win:PTR TO window) OF reactionUI
  DEF ticks,i
  DEF item:PTR TO totp
  DEF timeStr[100]:STRING
  DEF systime,x,y,xs,ys
  DEF newtime,newticks
  DEF led,idx,wid,scr,visInfo,tot
  DEF topscroll

  systime,ticks:=getSystemTime(uiTimedata.utcOffset)
  
  IF systime<>uiTimedata.oldtime
    uiTimedata.oldtime:=systime

    GetAttr( IA_LEFT, self.itemBevel, {x} )
    GetAttr( IA_TOP, self.itemBevel, {y} )
    GetAttr( IA_WIDTH, self.itemBevel, {xs} )
    GetAttr( IA_HEIGHT, self.itemBevel, {ys} )

/*    x:=Gets(self.itemBevel,IA_LEFT)
    y:=Gets(self.itemBevel,IA_TOP)
    xs:=Gets(self.itemBevel,IA_WIDTH)
    ys:=Gets(self.itemScroll,GA_HEIGHT)*/

    scr:=LockPubScreen(NIL)
    visInfo:=GetVisualInfoA(scr, [TAG_END])
    UnlockPubScreen(NIL,scr)

    tot:=ListLen(totpItems)-(ys/YSIZE)+1
    IF tot<0 THEN tot:=0
    SetGadgetAttrsA(self.itemScroll,win,0,[SCROLLER_TOTAL,tot,0])
    IF Gets(self.itemScroll,SCROLLER_TOP)>tot
      SetGadgetAttrsA(self.itemScroll,win,0,[SCROLLER_TOP,tot,0])
    ENDIF
    

    SetAPen(win.rport,1)

    led:=NewObjectA( NIL, 'led.image',[
                    IA_FGPEN,             2,
                    IA_BGPEN,             0,
                    IA_WIDTH,        xs-2,
                    IA_HEIGHT,       28,
                    LED_PAIRS,            3,
                    LED_TIME,             FALSE,
                    LED_COLON,            FALSE,
                    LED_RAW,              FALSE,
                TAG_DONE])
    IF led=NIL THEN Throw("OBJ","led")

    IF ListLen(totpItems)=0
      SetAPen(win.rport,0)
      RectFill(win.rport,x+2,y+2,x+xs-2,y+2+ys-4)
      xs:=xs-2
      Move(win.rport,x+2,y+8+2)
      SetAPen(win.rport,1)
      wid:=29
      IF wid>(xs/8) THEN wid:=(xs/8)
      Text(win.rport,'Add some items using the menu',wid)
    ENDIF

    topscroll:=Gets(self.itemScroll,SCROLLER_TOP)
    FOR i:=0 TO (ys/YSIZE)-1
      idx:=topscroll+i
      

      IF idx<ListLen(totpItems)
        Move(win.rport,x+2,y+(i*YSIZE)+8+2)
        item:=totpItems[idx]

        newtime:=Div(systime,item.interval)
        newticks:=ticks
        newticks:=newticks+Mul(systime-Mul(newtime,item.interval),50)

        IF (item.updateValues(0,newtime,newticks,forceRefresh)) OR (topscroll<>self.lastscroll)
          SetAPen(win.rport,0)
          RectFill(win.rport,x+2,y+2+(i*YSIZE),x+xs-4,y+2+(i*YSIZE)+YSIZE-4)
          SetAPen(win.rport,1)
          wid:=StrLen(item.name)
          IF wid>(xs/8) THEN wid:=xs/8
        
          IF item.ticks>1250
            Sets(led,IA_FGPEN,(Div(item.ticks,50) AND 1)+1)
          ELSE
            Sets(led,IA_FGPEN,1)
          ENDIF
          Text(win.rport,item.name,wid)
          Sets(led,LED_PAIRS,Shr(item.digits,1))
          Sets(led,LED_VALUES,item.ledvalues)
          DrawImage(win.rport,led,x+2,y+2+(i*YSIZE)+10)
          DrawBevelBoxA(win.rport,x+2,y+(i*YSIZE)+(YSIZE-2),xs-4,2,[GTBB_RECESSED, TRUE, GTBB_FRAMETYPE, BBFT_BUTTON, GT_VISUALINFO, visInfo,TAG_END])     
        ENDIF
      ENDIF
      
    ENDFOR
    forceRefresh:=FALSE
    self.lastscroll:=topscroll
    FreeVisualInfo(visInfo)
    DisposeObject(led)
    formatCDateTime(getSystemTime(uiTimedata.utcOffset),timeStr)
    StrCopy(timeVal,timeStr)
    SetGadgetAttrsA(self.timeText,win,0,[STRINGA_TEXTVAL, timeVal,0])
  ENDIF
ENDPROC

EXPORT PROC showMain(timedata,prefs,masterPass,itemsPtr:PTR TO LONG) HANDLE
  DEF running=TRUE
  DEF ledbase=0
  DEF item:PTR TO totp
  DEF i
  DEF items
  DEF win:PTR TO window,wsig,code,result,tmp,sig
  DEF menuitem
  DEF editPrefs:PTR TO prefsForm
  DEF editItems:PTR TO itemsForm
  DEF s[255]:STRING
  DEF enteredPass[100]:STRING
  DEF passwordForm : PTR TO passwordForm
  DEF decrypted=FALSE
  DEF string45=FALSE

  forceRefresh:=FALSE
  timeVal:=s
  reactionUI:=0
  
  uiPrefs:=prefs
  totpItems:=itemsPtr[]
  uiTimedata:=timedata
  newitems:=List(ListLen(totpItems)+10)

  IF (gadtoolsbase:=OpenLibrary('gadtools.library',0))=NIL THEN Throw("LIB","gadt")
  IF (windowbase:=OpenLibrary('window.class',0))=NIL THEN Throw("LIB","win")
  IF (listbrowserbase:=OpenLibrary('gadgets/listbrowser.gadget',0))=NIL THEN Throw("LIB","list")
  IF (labelbase:=OpenLibrary('images/label.image',0))=NIL THEN Throw("LIB","lbl")
  IF (bevelbase:=OpenLibrary('images/bevel.image',0))=NIL THEN Throw("LIB","bvl")
  IF (stringbase:=OpenLibrary('gadgets/string.gadget',45))=NIL 
    IF (stringbase:=OpenLibrary('gadgets/string.gadget',0))=NIL 
      Throw("LIB","str")
    ENDIF
  ELSE
    string45:=TRUE
  ENDIF
  IF (scrollerbase:=OpenLibrary('gadgets/scroller.gadget',0))=NIL THEN Throw("LIB","scrl")
  IF (checkboxbase:=OpenLibrary('gadgets/checkbox.gadget',0))=NIL THEN Throw("LIB","cbox")
  IF (spacebase:=OpenLibrary('gadgets/space.gadget',0))=NIL THEN Throw("LIB","spc")
  IF (chooserbase:=OpenLibrary('gadgets/chooser.gadget',0))=NIL THEN Throw("LIB","choo")
  IF (buttonbase:=OpenLibrary('gadgets/button.gadget',0))=NIL THEN Throw("LIB","btn")
  IF (layoutbase:=OpenLibrary('gadgets/layout.gadget',0))=NIL THEN Throw("LIB","layo")
  IF (ledbase:=OpenLibrary('images/led.image',0))=NIL THEN Throw("LIB","led")

  NEW reactionUI.create()
  reactionUI.masterpass1:=masterPass
  reactionUI.masterpass2:=enteredPass
  
  IF (win:=RA_OpenWindow(reactionUI.winMain))
    SetMenuStrip(win,reactionUI.menus)

    IF EstrLen(masterPass)=0
      NEW passwordForm.create(0,string45)
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
      NEW passwordForm.create(2,string45)
      passwordForm.verifyMasterPass()
      END passwordForm

      FOR i:=0 TO ListLen(totpItems)-1
        item:=totpItems[i]
        item.decrypt(enteredPass)
      ENDFOR
    ENDIF
    decrypted:=TRUE

    reactionUI.tickAction(win)

    GetAttr( WINDOW_SIGMASK, reactionUI.winMain, {wsig} )

    WHILE running
      sig:=Wait(wsig)
      IF (sig AND (wsig))
        WHILE ((result:=RA_HandleInput(reactionUI.winMain,{code})) <> WMHI_LASTMSG)
          tmp:=(result AND WMHI_CLASSMASK)

          SELECT tmp
            CASE WMHI_CLOSEWINDOW
                             running:=FALSE
            CASE WMHI_INTUITICK
              reactionUI.tickAction(win)
            CASE WMHI_MENUPICK
              menuitem:=(Shr((result),5) AND $3F)
              SELECT menuitem
                CASE 0
                  NEW editItems.create()
                  editItems.editItems()
                  END editItems
                CASE 1
                  NEW editPrefs.create()
                  editPrefs.editPrefs()
                  END editPrefs
                CASE 2
                  NEW passwordForm.create(1,string45)
                  passwordForm.updateMasterPass()
                  END passwordForm
                CASE 4
                  EasyRequestArgs(NIL,[20,0,'About Ami-Authenticator','Ami-Authenticator - Version 0.1\n\nA 2FA code generator application for the Amiga\nWritten by Darren Coles for the Amiga Tool Jam 2023\n(Reaction Version)','Ok'],NIL,NIL) 
                CASE 6
                 running:=FALSE
              ENDSELECT
          ENDSELECT
        ENDWHILE
      ENDIF
    ENDWHILE
  ELSE
    Raise("WIN")
  ENDIF
    
EXCEPT DO
  IF reactionUI THEN RA_CloseWindow(reactionUI.winMain)
  IF decrypted
    FOR i:=0 TO ListLen(totpItems)-1
      item:=totpItems[i]
      item.encrypt(enteredPass)
    ENDFOR
  ENDIF

  SELECT exception
    CASE "LIB"
      SELECT exceptioninfo
        CASE "led"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open led.image','Ok'],NIL,NIL) 
        CASE "gadt"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open gadtools.library','Ok'],NIL,NIL) 
        CASE "win"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open window.class','Ok'],NIL,NIL) 
        CASE "layo"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open layout.gadget','Ok'],NIL,NIL) 
        CASE "list"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open listbrowser.gadget','Ok'],NIL,NIL) 
        CASE "lbl"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open label.image','Ok'],NIL,NIL) 
        CASE "bvl"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open bevel.image','Ok'],NIL,NIL) 
        CASE "str"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open string.gadget','Ok'],NIL,NIL) 
        CASE "scrl"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open scroller.gadget','Ok'],NIL,NIL) 
        CASE "btn"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open button.gadget','Ok'],NIL,NIL) 
        CASE "cbox"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open checkbox.gadget','Ok'],NIL,NIL) 
        CASE "spc"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open space.gadget','Ok'],NIL,NIL) 
        CASE "choo"
          EasyRequestArgs(NIL,[20,0,'Error','Unable to open chooser.gadget','Ok'],NIL,NIL) 
      ENDSELECT
    CASE "OBJ"
      SELECT exceptioninfo
        CASE "led"
          EasyRequestArgs(NIL,[20,0,'Error','Error creating led.image object','Ok'],NIL,NIL) 
      ENDSELECT
    CASE "MEM"
      EasyRequestArgs(NIL,[20,0,'Error','Not enough memory','Ok'],NIL,NIL) 
    CASE "WIN"
      EasyRequestArgs(NIL,[20,0,'Error','Error opening window','Ok'],NIL,NIL) 
  ENDSELECT

  IF reactionUI THEN END reactionUI
  IF ledbase THEN CloseLibrary(ledbase)
  IF labelbase THEN CloseLibrary(labelbase)
  IF stringbase THEN CloseLibrary(stringbase)
  IF scrollerbase THEN CloseLibrary(scrollerbase)
  IF layoutbase THEN CloseLibrary(layoutbase)
  IF windowbase THEN CloseLibrary(windowbase)
  IF bevelbase THEN CloseLibrary(bevelbase)
  IF buttonbase THEN CloseLibrary(buttonbase)
  IF checkboxbase THEN CloseLibrary(checkboxbase)
  IF spacebase THEN CloseLibrary(spacebase) 
  IF gadtoolsbase THEN CloseLibrary(gadtoolsbase)
  IF listbrowserbase THEN CloseLibrary(listbrowserbase)
  IF chooserbase THEN CloseLibrary(chooserbase)
  DisposeLink(newitems)
  ->DisposeLink(timeVal)
  ->DisposeLink(timeVal)
  itemsPtr[]:=totpItems
ENDPROC

CHAR verstring