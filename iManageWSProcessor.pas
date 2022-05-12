unit iManageWSProcessor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, DBAccess, Uni, UniProvider,
  SQLServerUniProvider, IPPeerClient, Vcl.StdCtrls, REST.Client, REST.Types,
  REST.Authenticator.OAuth, Data.Bind.Components, Data.Bind.ObjectScope, MemDS,
  System.Rtti, System.Bindings.Outputs, Vcl.Bind.Editors, Data.Bind.EngExt,
  Vcl.Bind.DBEngExt, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  REST.Response.Adapter, Data.Bind.DBScope, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfiManWSProcessor = class(TForm)
    iManageSQLServer: TSQLServerUniProvider;
    iManageSQLConn: TUniConnection;
    iManageTargetDB: TUniConnection;
    qNewWSClients: TUniQuery;
    qNewWSMatters: TUniQuery;
    bCreateClientWS: TButton;
    BindingsList1: TBindingsList;
    RESTClient3: TRESTClient;
    rRequestLogin: TRESTRequest;
    rResponseLogin: TRESTResponse;
    rRequestCheckWSExists: TRESTRequest;
    rResponseCheckWSExists: TRESTResponse;
    qCheckClientID: TUniQuery;
    qCheckMatterID: TUniQuery;
    qCheckEntity: TUniQuery;
    qCheckDept: TUniQuery;
    qDBList: TUniQuery;
    rRequestCreate: TRESTRequest;
    rResponseCreate: TRESTResponse;
    qUpdateWSID: TUniQuery;
    qCreateCUSTOMAlias: TUniQuery;
    qCreateCustom2Alias: TUniQuery;
    rRequestUpdate: TRESTRequest;
    rResponseUpdate: TRESTResponse;
    rRequestSetWSPerms: TRESTRequest;
    rResponseSetWSPerms: TRESTResponse;
    qCheckWSExists: TUniQuery;
    RESTRequest1test: TRESTRequest;
    RESTResponse1test: TRESTResponse;
    Button2: TButton;
    qtest: TUniQuery;
    qWriteLog: TUniQuery;
    bCreateMatterWS: TButton;
    qCheckPrevRef: TUniQuery;
    procedure bCreateClientWSClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure bCreateMatterWSClick(Sender: TObject);
  private
    { Private declarations }
    CurrentWSID: string;
    Log_WSID, Log_WSID_Exist : string;
    Log_Client_ID, Log_Matter_ID : string;
    Log_Custom1, Log_Custom2, Log_Custom3, Log_Custom5, Log_Custom6, Log_Custom8 : string;
    Log_Workspace_ID, Log_WS_MetaData, Log_Permissions : string;
    Log_WSRootFolders, Log_Extra_Data : string;
    ExistingFolderID : string;

    Function CheckWSExists(fWSID : string; fDB : string):boolean;
    Function CheckClientID(fClientID : string; fDB : string):boolean;
    Function CheckEntity(fEntityID : string; fDB : string):boolean;
    Function CreateCustomAlias(fCTable : string; fCAlias : string; fDescript : string):boolean;
    Function CreateClientWS():boolean;
    Function UpdateClientWS():boolean;
    Function SetWSPerms(fDBID : string; fPermGroup : string):boolean;
    Function CreateWSRootFolders(fDBID : string; fWSType : string):boolean;
    Function test():boolean;
    Procedure InitialiseVars();
    Procedure WriteLog();
    Procedure CreateClient();
    Procedure CreateMatter();
    Function CreateMatterWS():boolean;
    Function CheckMatterID(fMatterID : string; fDB : string):boolean;
    Function CreateCustom2Alias(fCTable : string):boolean;
    Function CheckDept(fDept : string; fDB : string):boolean;
    Function UpdateMatterWS():boolean;
    Function CheckPrevRef(fPrevRef : string; fDB : string):boolean;
//    function testfoldercreate():boolean;
  public
    { Public declarations }
    AuthToken: string;

  end;

var
  fiManWSProcessor: TfiManWSProcessor;

const
  v2APIBase = 'work/api/v2/customers/100/libraries/';

implementation
uses
  system.json;

{$R *.dfm}

procedure TfiManWSProcessor.bCreateClientWSClick(Sender: TObject);

begin

    CreateClient;

End;

Procedure TfiManWSProcessor.CreateClient();
Begin
  qNewWSClients.Open;
  qNewWSClients.First;
  while not qNewWSClients.Eof do
  begin
  try
      InitialiseVars;
      Log_WSID := qNewWSClients.FieldByName('WSID').AsString;
      If not CheckWSExists(qNewWSClients.FieldByName('C1Alias').AsString, qNewWSClients.FieldByName('DBId').AsString) Then
      Begin
        If Not CheckClientID(qNewWSClients.FieldByName('C1Alias').AsString, qNewWSClients.FieldByName('DBId').AsString) Then
        begin
          //Create New Custom1
          CreateCustomAlias(qNewWSClients.FieldByName('DBId').AsString + '.MHGROUP.CUSTOM1', qNewWSClients.FieldByName('C1Alias').AsString,
                            qNewWSClients.FieldByName('C1Desc').AsString);
        end;

        If Not CheckEntity(qNewWSClients.FieldByName('C5Alias').AsString, qNewWSClients.FieldByName('DBId').AsString) Then
        begin
          //Create New Custom5
          CreateCustomAlias(qNewWSClients.FieldByName('DBId').AsString + '.MHGROUP.CUSTOM5', qNewWSClients.FieldByName('C5Alias').AsString,
                            qNewWSClients.FieldByName('C5Desc').AsString);
        end;

        //Create new client workspace
        rRequestLogin.Execute;
        If CreateClientWS then
        begin
          UpdateClientWS;
          SetWSPerms(qNewWSClients.FieldByName('DBId').AsString, qNewWSClients.FieldByName('Default_Security_Group').AsString);
          CreateWSRootFolders(qNewWSClients.FieldByName('DBId').AsString, 'CLIENT');
        end
      End
      else
      begin
        //Client Workspace already exists - update folderid in staging table (Probably will only be for workspaces created between WSC db backup and the 'incident')
        if ExistingFolderID <> '' then
        begin
          qUpdateWSID.Close;
          qUpdateWSID.ParamByName('FolderID').AsString := ExistingFolderID;
          qUpdateWSID.ParamByName('UniqueID').AsString := qNewWSClients.FieldByName('C1Alias').AsString;
          qUpdateWSID.Execute;

          Log_Workspace_ID := qNewWSClients.FieldByName('DBId').AsString + '!' + ExistingFolderID;
        end;
      end;

  except on E: Exception do
    Log_Extra_Data := 'Create Workspace failed at top level';
  end;
  try
    WriteLog;
  except on E: Exception do
  end;

    qNewWSClients.Next;
  end;

  qNewWSClients.Close;

end;

Function TfiManWSProcessor.CheckWSExists(fWSID : string; fDB : string):boolean;
Begin
  Result := False;
  try
  ;
    With qCheckWSExists do
    begin
      Close;
      SQL.Clear;
      SQL.Text := 'select top 1 * from ' + fDB + '.MHGROUP.PROJECTS ' +
                  'where CUSTOM1 = ' + QuotedStr(fWSID);
      Open;
      if IsEmpty then
      begin
        Result := False;
        Log_WSID_Exist := 'N';
      end
      else
      begin
        Result := True;
        Log_WSID_Exist := 'Y';
        ExistingFolderID := FieldByName('PRJ_ID').AsString;
        Close;
      end;
    end;
  except on E: Exception do
    begin
      Result := False;
      Log_WSID_Exist := 'Error';
    end;
  end
End;

procedure TfiManWSProcessor.bCreateMatterWSClick(Sender: TObject);
begin
  CreateMatter;
end;

procedure TfiManWSProcessor.Button2Click(Sender: TObject);
begin
  test;
end;

Function TfiManWSProcessor.CheckClientID(fClientID : string; fDB : string):boolean;
Begin
  try

    Result := False;
    With qCheckClientID Do
    Begin
      Close;
      SQL.Clear;
      SQL.Text := 'select * from ' + fDB + '.MHGROUP.CUSTOM1 ' +
                  'where CUSTOM_ALIAS = ' + QuotedStr(fClientID);
      Open;
      if IsEmpty then
      begin
        Result := False;
        Log_Client_ID := 'N';
      end
      else
      begin
        Result := True;
        Log_Client_ID := 'Exists';
      end;
      Close;
    End;

  except on E: Exception do
    begin
      Result := False;
      Log_Client_ID := 'Error';
    end;
  end;
End;

Function TfiManWSProcessor.CheckEntity(fEntityID : string; fDB : string):boolean;
Begin
  try


    Result := False;
    With qCheckEntity Do
    Begin
      Close;
      SQL.Clear;
      SQL.Text := 'select * from ' + fDB + '.MHGROUP.CUSTOM5 ' +
                  'where CUSTOM_ALIAS = ' + QuotedStr(fEntityID);
      Open;
      if IsEmpty then
      begin
        Result := False;
        Log_Custom5 := 'N';
      end
      else
      begin
        Result := True;
        Log_Custom5 := 'Exists';
      end;
      Close;

    End;
  except on E: Exception do
    begin
      Result := False;
      Log_Custom5 := 'Error';
    end;
  end;
End;

Function TfiManWSProcessor.CreateCustomAlias(fCTable : string; fCAlias : string; fDescript : string):boolean;
Begin

  try
    Result := False;
    With qCreateCUSTOMAlias do
    begin
      Close;
      SQL.Clear;
      SQL.Text := 'INSERT INTO ' + fCTable +'(CUSTOM_ALIAS, C_DESCRIPT, ENABLED, EDITWHEN, IS_HIPAA) ' +
                  'VALUES (' + quotedstr(fCAlias) + ', ' + quotedstr(fDescript) + ', ''Y'', GETDATE(), ''N'')';
      Execute;
    end;
    Result := True;
  except on E: Exception do
    begin
    Result := False;
    end;
  end;
End;

Function TfiManWSProcessor.CreateCustom2Alias(fCTable : string):boolean;
Begin

  try
    Result := False;
    With qCreateCUSTOMAlias do
    begin
      Close;
      SQL.Clear;
      SQL.Text := 'INSERT INTO ' + fCTable +'(CPARENT_ALIAS, CUSTOM_ALIAS, C_DESCRIPT, ENABLED, EDITWHEN, IS_HIPAA) ' +
                  'VALUES (' + quotedstr(qNewWSMatters.FieldByName('C1Alias').AsString) + ', ' +
                  quotedstr(qNewWSMatters.FieldByName('C2Alias').AsString) + ', ' +
                  quotedstr(qNewWSMatters.FieldByName('C2Desc').AsString) + ', ''Y'', GETDATE(), ''N'')';
      Execute;
    end;
    Result := True;
  except on E: Exception do
    begin
    Result := False;
    end;
  end;
End;

Function TfiManWSProcessor.CreateClientWS():boolean;
var
  rBody, rFolderID, rLongDB : string;
  rWSName, rWSDescription : string;
  ClientJSONObject : tjsonobject;
Begin
  try
    Result := False;
    rResponseCreate.Content.Empty;

    rRequestCreate.Params.Clear;
    //Remove double quotes from name and description
    rWSName := StringReplace(qNewWSClients.FieldByName('Name').AsString,'"','''',[rfReplaceAll]);
    rWSDescription := StringReplace(qNewWSClients.FieldByName('Description').AsString,'"','''',[rfReplaceAll]);

    rRequestCreate.Resource := v2APIBase + qNewWSClients.FieldByName('DBId').AsString + '/workspaces';
    rBody := '{"author": "wsadmin","class": "WEBDOC","default_security": "' +
            LowerCase(qNewWSClients.FieldByName('DefaultVisibility').AsString) +
            '","description": "' + rWSDescription +
            '","name": "' + rWSName +
            '","owner": "wsadmin"}';

    rBody := StringReplace(rBody,#$A,'',[rfReplaceAll]);
    rBody := StringReplace(rBody,#$D,'',[rfReplaceAll]);

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY); //, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;

    rRequestCreate.Execute;
    if rResponseCreate.StatusCode = 201 then
    begin
      //update staging table with folder id
      ClientJSONObject := rResponseCreate.JSONValue as TJSONObject;
      CurrentWSID := ClientJSONObject.GetValue('workspace_id').Value;

      rLongDB := qNewWSClients.FieldByName('DBId').AsString + '!';
      rFolderID := StringReplace(CurrentWSID, rLongDB, '', [rfIgnoreCase]);
      qUpdateWSID.ParamByName('FolderID').AsString := rFolderID;
      qUpdateWSID.ParamByName('UniqueID').AsString := qNewWSClients.FieldByName('C1Alias').AsString;
      qUpdateWSID.Execute;
      result := True;
      Log_Workspace_ID := CurrentWSID;
    end
    else
    begin
      //record failure
      result := False;
      Log_Workspace_ID := 'Response = ' + IntToStr(rResponseCreate.StatusCode);
    end;

  except on E: Exception do
    begin
      result := False;
      Log_Workspace_ID := 'Response = ' + IntToStr(rResponseCreate.StatusCode);
    end;
  end;
End;

Function TfiManWSProcessor.UpdateClientWS():boolean;
var
  rBody, rWSID, rFolderID, rProspective: string;
Begin
  try
    Result := False;
    rResponseUpdate.Content.Empty;
    //update workspace with extra metadata
    if qNewWSClients.FieldByName('CBool1').AsBoolean = True then
    rProspective := 'true'
    else
      rProspective := 'false';
    rRequestUpdate.Params.Clear;
    rRequestUpdate.Resource := v2APIBase + qNewWSClients.FieldByName('DBId').AsString + '/workspaces/' + CurrentWSID;
    rBody := '{"custom1": "' +  qNewWSClients.FieldByName('C1Alias').AsString +
              '","custom5": "' + qNewWSClients.FieldByName('C5Alias').AsString +
              '","custom25": "' + rProspective  +
              '","sub_class": "CLIENT' +
              '","project_custom1": "' + qNewWSClients.FieldByName('C1Alias').AsString +
              '","project_custom2": "' + qNewWSClients.FieldByName('TemplateId').AsString +
              '","project_custom3": "Worksite"}';

    rRequestUpdate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY); //, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestUpdate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestUpdate.Execute;
    if rResponseUpdate.StatusCode = 200 then
    begin
      result := True;
      Log_WS_MetaData := 'Y';
    end
    else
    begin
      //record failure
      result := False;
      Log_WS_MetaData := 'Status = ' + IntToStr(rResponseUpdate.StatusCode);
    end;

  except on E: Exception do
    begin
      result := False;
      Log_WS_MetaData := 'Status = ' + IntToStr(rResponseUpdate.StatusCode);
    end;
  end;
End;

Function TfiManWSProcessor.SetWSPerms(fDBID : string; fPermGroup : string):boolean;
var
  rBody : string;
Begin
  try
    Result := False;
    rResponseSetWSPerms.Content.Empty;
    rRequestSetWSPerms.Params.Clear;
    rRequestSetWSPerms.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/security';
    rBody := '{"default_security": "private", ' +
              '"include": [{ "id" : "WSADMIN", "access_level" : "full_access", "type": "user" },' +
              '{ "id" : "' + fPermGroup + '", "access_level" : "full_access", "type" : "group" }]}';
    rRequestSetWSPerms.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY); //, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestSetWSPerms.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestSetWSPerms.Execute;
    if rResponseSetWSPerms.StatusCode = 200 then
    begin
      result := True;
      Log_Permissions := 'Y';
    end
    else
    begin
      //record failure
      result := False;
      Log_Permissions := 'Status = ' + IntToStr(rResponseSetWSPerms.StatusCode);
    end;

    except on E: Exception do
      begin
      result := False;
      Log_Permissions := 'Status = ' + IntToStr(rResponseSetWSPerms.StatusCode);
      end;
  end;
End;

Function TfiManWSProcessor.CreateWSRootFolders(fDBID : string; fWSType : string):boolean;
var
  rBody, rProspective, rEmail : string;
  rWSProfile : string;
Begin
  Result := False;

  rWSProfile :=  '';
  if fWSType = 'MATTER' then
  begin
    if qNewWSMatters.FieldByName('CBool1').AsBoolean = True then
    rProspective := 'true'
  else
    rProspective := 'false';
    rWSProfile := '"profile": {"custom1": "' +  qNewWSMatters.FieldByName('C1Alias').AsString +
              '","custom2": "' + qNewWSMatters.FieldByName('C2Alias').AsString +
              '","custom3": "' + qNewWSMatters.FieldByName('C3Alias').AsString +
              '","custom5": "' + qNewWSMatters.FieldByName('C5Alias').AsString +
              '","custom6": "' + qNewWSMatters.FieldByName('C6Alias').AsString +
              '","custom8": "' + qNewWSMatters.FieldByName('C8Alias').AsString +
              '","custom23": "' + qNewWSMatters.FieldByName('F_CDate3').AsString + '"}';
    rEmail := qNewWSMatters.FieldByName('WSID').AsString;
  end
  else
  begin
  if qNewWSClients.FieldByName('CBool1').AsBoolean = True then
    rProspective := 'true'
  else
    rProspective := 'false';
    rWSProfile :=  '"profile": { "custom1": "' + qNewWSClients.FieldByName('C1Alias').AsString +
                                '","custom5": "' + qNewWSClients.FieldByName('C5Alias').AsString + '"}';
    rEmail := qNewWSClients.FieldByName('WSID').AsString;
  end;
  try

    rRequestCreate.ClearBody;

    rResponseCreate.Content.Empty;
    rRequestCreate.Params.Clear;
    rRequestCreate.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/folders';
    rBody := '{"name": "Accounts/Compliance", ' +
              '"description" : "Accounts/Compliance",' +
              '"default_security": "inherit",' +
              '"view_type": "document",' +
              rWSProfile +
              '}';

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY); //, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestCreate.Execute;
    if rResponseCreate.StatusCode = 201 then
    begin
      result := True;
      Log_WSRootFolders := '[Acc/Comp = Y]';
    end
    else
    begin
      //record failure
      result := False;
      Log_WSRootFolders := '[Acc/Comp = ' + IntToStr(rResponseCreate.StatusCode) + ']';
    end;
  except on E: Exception do
    begin
      result := False;
      Log_WSRootFolders := 'Acc/Comp = ' + IntToStr(rResponseCreate.StatusCode) + ']';
    end;
  end;

  try
    rResponseCreate.Content.Empty;
    rRequestCreate.Params.Clear;
    rRequestCreate.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/folders';
    rBody := '{"name": "Correspondence", ' +
              '"description" : "Correspondence",' +
              '"default_security": "inherit",' +
              '"view_type": "email",' +
              '"email": "' + rEmail + '",' +
              rWSProfile +
              '}';

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY); //, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestCreate.Execute;

    if rResponseCreate.StatusCode = 201 then
      begin
        result := True;
        Log_WSRootFolders := Log_WSRootFolders + ' [Correspondence = Y]';
      end
      else
      begin
        //record failure
        result := False;
        Log_WSRootFolders := '[Acc/Comp = ' + IntToStr(rResponseCreate.StatusCode) + ']';
      end;
    except on E: Exception do
      begin
        result := False;
        Log_WSRootFolders := '[Acc/Comp = ' + IntToStr(rResponseCreate.StatusCode) + ']';
      end;
    end;

  try
    rResponseCreate.Content.Empty;
    rRequestCreate.Params.Clear;
    rRequestCreate.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/folders';
    rBody := '{"name": "Documents", ' +
              '"description" : "Documents",' +
              '"default_security": "inherit",' +
              '"view_type": "document",' +
              rWSProfile +
              '}';

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY); //, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestCreate.Execute;

    if rResponseCreate.StatusCode = 201 then
    begin
      result := True;
      Log_WSRootFolders := Log_WSRootFolders + ' [Documents = Y]';
    end
    else
    begin
      //record failure
      result := False;
      Log_WSRootFolders := '[Documents = ' + IntToStr(rResponseCreate.StatusCode) + ']';
    end;

  except on E: Exception do
    begin
      result := False;
      Log_WSRootFolders := '[Documents = ' + IntToStr(rResponseCreate.StatusCode) + ']';
    end;
  end;
End;

Function TfiManWSProcessor.test():boolean;
var
  rBody, rWSID, rFolderID, rProspective, fDBID, fPermGroup: string;
  rWSProfile, rEmail : string;
Begin
  qtest.open;
  rRequestLogin.Execute;
  //Remember to update this and the test query
  CurrentWSID := 'EU_GDG_OPEN!968363';
  fDBID := 'EU_GDG_OPEN';
  rWSProfile :=  '';
  rprospective := 'true';
{
  rRequestUpdate.Params.Clear;
  rRequestUpdate.Resource := v2APIBase + qtest.FieldByName('DBId').AsString + '/folders/EU_GDG_OPEN!966292';
  rBody := '{"view_type": "email", ' +
           '"email": "' + qtest.FieldByName('WSID').AsString + '"}{';


  rRequestUpdate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
  rRequestUpdate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
  rRequestUpdate.Execute;

end;

function TfiManWSProcessor.testfoldercreate():boolean;                  }

   if 'MATTER' = 'MATTER' then
  begin
    if qNewWSMatters.FieldByName('CBool1').AsBoolean = True then
    rProspective := 'true'
  else
    rProspective := 'false';
    rWSProfile := '"profile": {"custom1": "' +  qtest.FieldByName('C1Alias').AsString +
              '","custom2": "' + qtest.FieldByName('C2Alias').AsString +
              '","custom3": "' + qtest.FieldByName('C3Alias').AsString +
              '","custom5": "' + qtest.FieldByName('C5Alias').AsString +
              '","custom6": "' + qtest.FieldByName('C6Alias').AsString +
              '","custom8": "' + qtest.FieldByName('C8Alias').AsString +
              '","custom23": "' + qtest.FieldByName('F_CDate3').AsString + '"}';
//              '","custom25": "' + rProspective  + '"}';
    rEmail := qtest.FieldByName('WSID').AsString;
  end
  else
  begin
  if qNewWSClients.FieldByName('CBool1').AsBoolean = True then
    rProspective := 'true'
  else
    rProspective := 'false';
//  rC1Alias := qNewWSClients.FieldByName('C1Alias').AsString;
//  rC5Alias := qNewWSClients.FieldByName('C5Alias').AsString;
    rWSProfile :=  '"profile": { "custom1": "' + qNewWSClients.FieldByName('C1Alias').AsString +
                                //'","custom1_description": "' + qNewWSClients.FieldByName('C1Desc').AsString +
                                '","custom5": "' + qNewWSClients.FieldByName('C5Alias').AsString + '"}';
                                //'","custom5_description": "' + qNewWSClients.FieldByName('C5Desc').AsString +
//                                 '","custom25": "' + rProspective + '"}';
    rEmail := qNewWSClients.FieldByName('WSID').AsString;
  end;
  try

    rRequestCreate.ClearBody;

    rResponseCreate.Content.Empty;
    rRequestCreate.Params.Clear;
    rRequestCreate.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/folders';
    rBody := '{"name": "Accounts/Compliance", ' +
              '"description" : "Accounts/Compliance",' +
              '"default_security": "inherit",' +
              '"view_type": "document",' +
              rWSProfile +
              '}';

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY); //, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestCreate.Execute;
    if rResponseCreate.StatusCode = 201 then
    begin
      result := True;
      Log_WSRootFolders := '[Acc/Comp = Y]';
    end
    else
    begin
      //record failure
      result := False;
      Log_WSRootFolders := '[Acc/Comp = ' + IntToStr(rResponseCreate.StatusCode) + ']';
    end;
  except on E: Exception do
    begin
      result := False;
      Log_WSRootFolders := 'Acc/Comp = ' + IntToStr(rResponseCreate.StatusCode) + ']';
    end;
  end;

  try
    rResponseCreate.Content.Empty;
    rRequestCreate.Params.Clear;
    rRequestCreate.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/folders';
    rBody := '{"name": "Correspondence", ' +
              '"description" : "Correspondence",' +
              '"default_security": "inherit",' +
              '"view_type": "email",' +
              '"email": "' + rEmail + '",' +
              rWSProfile +
              '}';

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY); //, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestCreate.Execute;

    if rResponseCreate.StatusCode = 201 then
      begin
        result := True;
        Log_WSRootFolders := Log_WSRootFolders + ' [Correspondence = Y]';
      end
      else
      begin
        //record failure
        result := False;
        Log_WSRootFolders := '[Acc/Comp = ' + IntToStr(rResponseCreate.StatusCode) + ']';
      end;
    except on E: Exception do
      begin
        result := False;
        Log_WSRootFolders := '[Acc/Comp = ' + IntToStr(rResponseCreate.StatusCode) + ']';
      end;
    end;

  try
    rResponseCreate.Content.Empty;
    rRequestCreate.Params.Clear;
    rRequestCreate.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/folders';
    rBody := '{"name": "Documents", ' +
              '"description" : "Documents",' +
              '"default_security": "inherit",' +
              '"view_type": "document",' +
              rWSProfile +
              '}';

  //  rRequestCreate.AddParameter('body', rBody, TRESTRequestParameterKind.pkREQUESTBODY);
    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY); //, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestCreate.Execute;

    if rResponseCreate.StatusCode = 201 then
    begin
      result := True;
      Log_WSRootFolders := Log_WSRootFolders + ' [Documents = Y]';
    end
    else
    begin
      //record failure
      result := False;
      Log_WSRootFolders := '[Documents = ' + IntToStr(rResponseCreate.StatusCode) + ']';
    end;
  finally
  end;

//  end;

End;

Procedure TfiManWSProcessor.InitialiseVars();
Begin
  CurrentWSID := '';
  Log_WSID := '';
  Log_WSID_Exist := '';
  Log_Client_ID := '';
  Log_Matter_ID := '';
  Log_Custom1 := '';
  Log_Custom2 := '';
  Log_Custom3 := '';
  Log_Custom5 := '';
  Log_Custom6 := '';
  Log_Custom8 := '';
  Log_Workspace_ID := '';
  Log_WS_MetaData := '';
  Log_Permissions := '';
  Log_WSRootFolders := '';
  Log_Extra_Data := '';
  ExistingFolderID := '';
End;

Procedure TfiManWSProcessor.WriteLog();
Begin
  With qWriteLog do
  begin
    Close;
    ParamByName('Log_WSID').AsString := Log_WSID;
    ParamByName('Log_WSID_Exist').AsString := Log_WSID_Exist;
    ParamByName('Log_Client_ID').AsString := Log_Client_ID;
    ParamByName('Log_Matter_ID').AsString := Log_Matter_ID;
    ParamByName('Log_Custom1').AsString := Log_Custom1;
    ParamByName('Log_Custom2').AsString := Log_Custom2;
    ParamByName('Log_Custom3').AsString := Log_Custom3;
    ParamByName('Log_Custom5').AsString := Log_Custom5;
    ParamByName('Log_Custom6').AsString := Log_Custom6;
    ParamByName('Log_Custom8').AsString := Log_Custom8;
    ParamByName('Log_Workspace_ID').AsString := Log_Workspace_ID;
    ParamByName('Log_WS_MetaData').AsString := Log_WS_MetaData;
    ParamByName('Log_Permissions').AsString := Log_Permissions;
    ParamByName('Log_WSRootFolders').AsString := Log_WSRootFolders;
    ParamByName('Log_Extra_Data').AsString := Log_Extra_Data;
    ParamByName('Log_Date').AsDateTime := Now;

    Execute;
    Close;
  end;

End;

Procedure TfiManWSProcessor.CreateMatter();
Begin
  qNewWSMatters.Open;
  qNewWSMatters.First;
  while not qNewWSMatters.Eof do
  begin
  try
      InitialiseVars;
      Log_WSID := qNewWSMatters.FieldByName('WSID').AsString;
      If not CheckWSExists(qNewWSMatters.FieldByName('C2Alias').AsString, qNewWSMatters.FieldByName('DBId').AsString) Then
      Begin
        If Not CheckClientID(qNewWSMatters.FieldByName('C1Alias').AsString, qNewWSMatters.FieldByName('DBId').AsString) Then
        begin
          //Create New Custom1
          CreateCustomAlias(qNewWSMatters.FieldByName('DBId').AsString + '.MHGROUP.CUSTOM1', qNewWSMatters.FieldByName('C1Alias').AsString,
                            qNewWSMatters.FieldByName('C1Desc').AsString);
        end;

        If Not CheckMatterID(qNewWSMatters.FieldByName('C2Alias').AsString, qNewWSMatters.FieldByName('DBId').AsString) Then
        begin
          //Create New Custom2
          CreateCustom2Alias(qNewWSMatters.FieldByName('DBId').AsString + '.MHGROUP.CUSTOM2');
        end;

        If Not CheckEntity(qNewWSMatters.FieldByName('C5Alias').AsString, qNewWSMatters.FieldByName('DBId').AsString) Then
        begin
          //Create New Custom5
          CreateCustomAlias(qNewWSMatters.FieldByName('DBId').AsString + '.MHGROUP.CUSTOM5', qNewWSMatters.FieldByName('C5Alias').AsString,
                            qNewWSMatters.FieldByName('C5Desc').AsString);
        end;

        If Not CheckDept(qNewWSMatters.FieldByName('C3Alias').AsString, qNewWSMatters.FieldByName('DBId').AsString) Then
        begin
          //Create New Custom3
          CreateCustomAlias(qNewWSMatters.FieldByName('DBId').AsString + '.MHGROUP.CUSTOM3', qNewWSMatters.FieldByName('C3Alias').AsString,
                            qNewWSMatters.FieldByName('C3Desc').AsString);
        end;

        If Not CheckPrevRef(qNewWSMatters.FieldByName('C6Alias').AsString, qNewWSMatters.FieldByName('DBId').AsString) Then
        begin
          //Create New Custom6
          CreateCustomAlias(qNewWSMatters.FieldByName('DBId').AsString + '.MHGROUP.CUSTOM6', qNewWSMatters.FieldByName('C6Alias').AsString, '');
        end;

        //Create new Matter workspace
        rRequestLogin.Execute;
        If CreateMatterWS then
        begin
          UpdateMatterWS;
          SetWSPerms(qNewWSMatters.FieldByName('DBId').AsString, qNewWSMatters.FieldByName('Default_Security_Group').AsString);
          CreateWSRootFolders(qNewWSMatters.FieldByName('DBId').AsString, 'MATTER');
        end
      End
      else
      begin
        //Matter Workspace already exists - update folderid in staging table (Probably will only be for workspaces created between WSC db backup and the 'incident')
        if ExistingFolderID <> '' then
        begin
          qUpdateWSID.Close;
          qUpdateWSID.ParamByName('FolderID').AsString := ExistingFolderID;
          qUpdateWSID.ParamByName('UniqueID').AsString := qNewWSMatters.FieldByName('C2Alias').AsString;
          qUpdateWSID.Execute;

          Log_Workspace_ID := qNewWSMatters.FieldByName('DBId').AsString + '!' + ExistingFolderID;
        end;
      end;

  except on E: Exception do
    Log_Extra_Data := 'Create Workspace failed at top level';
  end;
  try
    WriteLog;
  except on E: Exception do
  end;

    qNewWSMatters.Next;
  end;

  qNewWSMatters.Close;

end;

Function TfiManWSProcessor.CheckMatterID(fMatterID : string; fDB : string):boolean;
Begin
  try

    Result := False;
    With qCheckMatterID Do
    Begin
      Close;
      SQL.Clear;
      SQL.Text := 'select * from ' + fDB + '.MHGROUP.CUSTOM2 ' +
                  'where CUSTOM_ALIAS = ' + QuotedStr(fMatterID);
      Open;
      if IsEmpty then
      begin
        Result := False;
        Log_Matter_ID := 'N';
      end
      else
      begin
        Result := True;
        Log_Matter_ID := 'Exists';
      end;
      Close;
    End;

  except on E: Exception do
    begin
      Result := False;
      Log_Matter_ID := 'Error';
    end;
  end;
End;

Function TfiManWSProcessor.CheckDept(fDept : string; fDB : string):boolean;
Begin
  try

    Result := False;
    With qCheckDept Do
    Begin
      Close;
      SQL.Clear;
      SQL.Text := 'select * from ' + fDB + '.MHGROUP.CUSTOM3 ' +
                  'where CUSTOM_ALIAS = ' + QuotedStr(fDept);
      Open;
      if IsEmpty then
      begin
        Result := False;
        Log_Custom3 := 'N';
      end
      else
      begin
        Result := True;
        Log_Custom3 := 'Exists';
      end;
      Close;
    End;

  except on E: Exception do
    begin
      result := False;
      Log_WS_MetaData := 'Status = ' + IntToStr(rResponseUpdate.StatusCode);
    end;
  end;
End;

Function TfiManWSProcessor.CheckPrevRef(fPrevRef : string; fDB : string) : boolean;
Begin
  try
    Result := False;
    With qCheckPrevRef Do
    Begin
      Close;
      SQL.Clear;
      SQL.Text := 'select * from ' + fDB + '.MHGROUP.CUSTOM6 ' +
                  'where CUSTOM_ALIAS = ' + QuotedStr(fPrevRef);
      Open;
      if IsEmpty then
      begin
        Result := False;
        Log_Custom6 := 'N';
      end
      else
      begin
        Result := True;
        Log_Custom6 := 'Exists';
      end;
      Close;
    End;

  except on E: Exception do
    begin
      Result := False;
      Log_Custom6 := 'Error';
    end;
  end;
End;


Function TfiManWSProcessor.CreateMatterWS():boolean;
var
  rBody, rFolderID, rLongDB : string;
  rWSName, rWSDescription : string;
  MatterJSONObject : TJsonObject;
Begin
  try
    Result := False;
    rResponseCreate.Content.Empty;

    rRequestCreate.Params.Clear;
    //Remove double quotes from name and description
    rWSName := StringReplace(qNewWSMatters.FieldByName('Name').AsString,'"','''',[rfReplaceAll]);
    rWSDescription := StringReplace(qNewWSMatters.FieldByName('Description').AsString,'"','''',[rfReplaceAll]);

    rRequestCreate.Resource := v2APIBase + qNewWSMatters.FieldByName('DBId').AsString + '/workspaces';
    rBody := '{"author": "wsadmin","class": "WEBDOC","default_security": "' +
            LowerCase(qNewWSMatters.FieldByName('DefaultVisibility').AsString) +
            '","description": "' + rWSDescription +
            '","name": "' + rWSName +
            '","owner": "wsadmin"}';

    rBody := StringReplace(rBody,#$A,'',[rfReplaceAll]);
    rBody := StringReplace(rBody,#$D,'',[rfReplaceAll]);

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY); //, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;


    rRequestCreate.Execute;
    if rResponseCreate.StatusCode = 201 then
    begin
      //update staging table with folder id
      MatterJSONObject := rResponseCreate.JSONValue as TJSONObject;
      CurrentWSID := MatterJSONObject.GetValue('workspace_id').Value;

      rLongDB := qNewWSMatters.FieldByName('DBId').AsString + '!';
      rFolderID := StringReplace(CurrentWSID, rLongDB, '', [rfIgnoreCase]);
      qUpdateWSID.ParamByName('FolderID').AsString := rFolderID;
      qUpdateWSID.ParamByName('UniqueID').AsString := qNewWSMatters.FieldByName('C2Alias').AsString;
      qUpdateWSID.Execute;
      result := True;
      Log_Workspace_ID := CurrentWSID;

    end
    else
    begin
      //record failure
      result := False;
      Log_Workspace_ID := 'Response = ' + IntToStr(rResponseCreate.StatusCode);
    end;

  except on E: Exception do
    begin
      result := False;
      Log_Workspace_ID := 'Response = ' + IntToStr(rResponseCreate.StatusCode);
    end;
  end;
End;

Function TfiManWSProcessor.UpdateMatterWS():boolean;
var
  rBody, rWSID, rFolderID, rProspective: string;
Begin
  try
    Result := False;
    rResponseUpdate.Content.Empty;
    //update workspace with extra metadata
    if qNewWSMatters.FieldByName('CBool1').AsBoolean = True then
    rProspective := 'true'
    else
      rProspective := 'false';
    rRequestUpdate.Params.Clear;
    rRequestUpdate.Resource := v2APIBase + qNewWSMatters.FieldByName('DBId').AsString + '/workspaces/' + CurrentWSID;
    rBody := '{"custom1": "' +  qNewWSMatters.FieldByName('C1Alias').AsString +
              '","custom2": "' + qNewWSMatters.FieldByName('C2Alias').AsString +
              '","custom3": "' + qNewWSMatters.FieldByName('C3Alias').AsString +
              '","custom5": "' + qNewWSMatters.FieldByName('C5Alias').AsString +
              '","custom6": "' + qNewWSMatters.FieldByName('C6Alias').AsString +
              '","custom8": "' + qNewWSMatters.FieldByName('C8Alias').AsString +
              '","custom23": "' + qNewWSMatters.FieldByName('F_CDate3').AsString +
              '","custom25": "' + rProspective  +
              '","sub_class": "MATTER' +
              '","project_custom1": "' + qNewWSMatters.FieldByName('C2Alias').AsString +
              '","project_custom2": "' + qNewWSMatters.FieldByName('TemplateId').AsString +
              '","project_custom3": "Worksite"}';


    rRequestUpdate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY); //, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestUpdate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestUpdate.Execute;
    if rResponseUpdate.StatusCode = 200 then
    begin
      result := True;
      Log_WS_MetaData := 'Y';
    end
    else
    begin
      //record failure
      result := False;
      Log_WS_MetaData := 'Status = ' + IntToStr(rResponseUpdate.StatusCode);
    end;

  except on E: Exception do
    begin
      result := False;
      Log_WS_MetaData := 'Status = ' + IntToStr(rResponseUpdate.StatusCode);
    end;
  end;
End;


end.
