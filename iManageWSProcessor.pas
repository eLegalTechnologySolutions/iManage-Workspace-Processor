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
    Button1: TButton;
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
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    CurrentWSID: string;
    Log_WSID, Log_WSID_Exist : string;
    Log_Client_ID, Log_Matter_ID : string;
    Log_Custom1, Log_Custom2, Log_Custom3, Log_Custom5, Log_Custom6, Log_Custom8 : string;
    Log_Workspace_ID, Log_WS_MetaData, Log_Permissions : string;
    Log_WSRootFolders, Log_Extra_Data : string;

    Function CheckWSExists(fWSID : string; fDB : string):boolean;
    Function CheckClientID(fClientID : string; fDB : string):boolean;
    Function CheckEntity(fEntityID : string; fDB : string):boolean;
    Function CreateCustomAlias(fCTable : string; fCAlias : string; fDescript : string):boolean;
    Function CreateClientWS():boolean;
    Function UpdateClientWS():boolean;
    Function SetWSPerms(fDBID : string; fPermGroup : string):boolean;
    Function CreateWSRootFolders(fDBID : string):boolean;
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
//    function testfoldercreate():boolean;
  public
    { Public declarations }
    AuthToken: string;
//    AuthTokenType: string;
//    AuthTokenExpire: integer;
  end;

var
  fiManWSProcessor: TfiManWSProcessor;

const
  v2APIBase = 'work/api/v2/customers/100/libraries/';

implementation
uses
  system.json;
//  REST.Types,
//  REST.Utils;
{$R *.dfm}

procedure TfiManWSProcessor.Button1Click(Sender: TObject);
//var
//  DBConn : TUniConnection;
//  AuthExpireText : string;
//  obj, data: TJSONObject;
//  response : TclJSONObject;
begin

//  OAuth2Auth1.
//  RESTRQiManWS_Login.Execute;

//  obj := RESTRSWS1.JSONValue as TJSONObject;
//  response := RESTRSWS1.ParseObject(responseBody.DataString);
//  data := obj.Values[''] as TJSONObject;
//  RESTRSWS1.GetSimpleValue('access_token');
//  Edit1.Text := data.ToString;
//RESTRSWS1.JSONText('access_token');
//OAuth2Auth1.AccessToken := Edit1.Text;
{  With RESTRequest1 do
  begin
    AddAuthParameter('grant_type', 'Password', pkGETorPOST);
//    AddAuthParameter(');
  end;
}
{
  RESTRSWS_Login.GetSimpleValue('access_token', AuthToken);
  RESTRSWS_Login.GetSimpleValue('token_type', AuthTokenType);
  RESTRSWS_Login.GetSimpleValue('expires_in', AuthExpireText);
  AuthTokenExpire := AuthExpireText.ToInteger;

  RESTrequest1.AddAuthParameter('x-auth-token',AuthToken, pkHTTPHEADER);
  RESTrequest1.AddAuthParameter('token_type',AuthTokenType, pkHTTPHEADER);
  RESTrequest1.AddAuthParameter('expires_in',AuthExpireText, pkHTTPHEADER);
}
//  qNewWSClients.Open;
  //rRequestLogin.Execute;

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
      //CurrentWSID := '';
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
          CreateWSRootFolders(qNewWSClients.FieldByName('DBId').AsString);
        end
      End
      else
      begin
        //Client Workspace already exists
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

//  rRequestLogin.Execute;
//  rResponseLogin.GetSimpleValue('X-Auth-token', AuthToken);

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
      end;
      Close;
    end;
  except on E: Exception do
    begin
      Result := False;
      Log_WSID_Exist := 'Error';
    end;
  end
End;

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
      {ParamByName('CUSTOMTABLE').AsString := fCTable;
      ParamByName('CUSTOM_ALIAS').AsString := fCAlias;
      ParamByName('DESCRIPT').AsString := fDescript; }
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
  ClientJSONObject : tjsonobject;
Begin
  try
    Result := False;
    rResponseCreate.Content.Empty;

    rRequestCreate.Params.Clear;
    rRequestCreate.Resource := v2APIBase + qNewWSClients.FieldByName('DBId').AsString + '/workspaces';
    rBody := '{"author": "wsadmin","class": "WEBDOC","default_security": "' +
            LowerCase(qNewWSClients.FieldByName('DefaultVisibility').AsString) +
            '","description": "' + qNewWSClients.FieldByName('Description').AsString +
            '","name": "' + qNewWSClients.FieldByName('Name').AsString +
            '","owner": "wsadmin"}';

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
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
//    ClientJSONObject.Free;

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
    ///work/api/v2/customers/{customerId}/libraries/{libraryId}/workspaces/{workspaceId}
    rBody := '{"custom1": "' +  qNewWSClients.FieldByName('C1Alias').AsString +
              '","custom5": "' + qNewWSClients.FieldByName('C5Alias').AsString +
              '","custom25": "' + rProspective  +
              '","sub_class": "CLIENT' +
 //             '","subclass": "CLIENT' +
              '","project_custom1": "' + qNewWSClients.FieldByName('C1Alias').AsString +
              '","project_custom2": "' + qNewWSClients.FieldByName('TemplateId').AsString +
              '","project_custom3": "Worksite"}';

    {
    '{"author": "epmsdev","class": "WEBDOC","default_security": "' + qNewWSClients.FieldByName('DefaultVisibility').AsString +
            '","description": "' + qNewWSClients.FieldByName('Description').AsString +
            '","name": "' + qNewWSClients.FieldByName('Name').AsString +
            '","owner": "epmsdev"}
            //';  }

    //{"author": "epmsdev","class": "WEBDOC","default_security": "public","description": "JR Test Workspace",
    //"name": "001 - JR Test Workspace","owner": "epmsdev"}
  //  rRequestUpdate.AddParameter('body', rBody, TRESTRequestParameterKind.pkREQUESTBODY);
    rRequestUpdate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestUpdate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestUpdate.Execute;
    if rResponseUpdate.StatusCode = 200 then
    begin
      //update staging with folder id
   {   rResponseCreate.GetSimpleValue('workspace_id', rWSID);
      rFolderID := rWSID.Substring(pos(rWSID,'!')+1);
      qUpdateWSID.ParamByName('UniqueID').AsString := rFolderID;
      qUpdateWSID.Execute;    }
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
  //  rRequestSetWSPerms.AddParameter('body', rBody, TRESTRequestParameterKind.pkREQUESTBODY);
    rRequestSetWSPerms.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
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

Function TfiManWSProcessor.CreateWSRootFolders(fDBID : string):boolean;
var
  rBody, rProspective : string;
  rClientProfile, rMatterProfile : string;
//  rC1Alias, rC5Alias,  : string;
Begin
  Result := False;

  rClientProfile :=  '';
  rMatterProfile := '';
  if qNewWSClients.FieldByName('Category').AsString = 'MATTER' then
  begin
    rMatterProfile := '';
  end
  else
  begin
    if qNewWSClients.FieldByName('CBool1').AsBoolean = True then
      rProspective := 'true'
    else
      rProspective := 'false';
  //  rC1Alias := qNewWSClients.FieldByName('C1Alias').AsString;
  //  rC5Alias := qNewWSClients.FieldByName('C5Alias').AsString;
    rClientProfile :=  '"profile": { "custom1": "' + qNewWSClients.FieldByName('C1Alias').AsString +
                                  //'","custom1_description": "' + qNewWSClients.FieldByName('C1Desc').AsString +
                                  '","custom5": "' + qNewWSClients.FieldByName('C5Alias').AsString +
                                  //'","custom5_description": "' + qNewWSClients.FieldByName('C5Desc').AsString +
                                  '","custom25": "' + rProspective + '"}';
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
              rClientProfile + rMatterProfile +
              '}';

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
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
              '"email": "' + qNewWSClients.FieldByName('WSID').AsString + '",' +
              rClientProfile + rMatterProfile +
              '}';

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
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
              rClientProfile + rMatterProfile +
              '}';

  //  rRequestCreate.AddParameter('body', rBody, TRESTRequestParameterKind.pkREQUESTBODY);
    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
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
  rClientProfile, rMatterProfile : string;
Begin
  qtest.open;
  rRequestLogin.Execute;
  //Remember to update this and the test query
  CurrentWSID := 'EU_GDG_OPEN!967529';
  fDBID := 'EU_GDG_OPEN';
  rClientProfile :=  '';
  rMatterProfile := '';
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

  if qtest.FieldByName('Category').AsString = 'MATTER' then
  begin
    rMatterProfile := '';
  end
  else
  begin
    if qtest.FieldByName('CBool1').AsBoolean = True then
      rProspective := 'true'
    else
      rProspective := 'false';

    rRequestUpdate.Params.Clear;
    rRequestUpdate.Resource := v2APIBase + qtest.FieldByName('DBId').AsString + '/workspaces/' + CurrentWSID;
    ///work/api/v2/customers/{customerId}/libraries/{libraryId}/workspaces/{workspaceId}
    rBody := '{"custom1": "' +  qtest.FieldByName('C1Alias').AsString +
              '","custom5": "' + qtest.FieldByName('C5Alias').AsString +
              '","custom25": "' + rProspective  +
              '","sub_class": "CLIENT' +
              '","project_custom1": "' + qtest.FieldByName('C1Alias').AsString +
              '","project_custom2": "' + qtest.FieldByName('TemplateId').AsString +
              '","project_custom3": "Worksite"}';

    {
    '{"author": "epmsdev","class": "WEBDOC","default_security": "' + qNewWSClients.FieldByName('DefaultVisibility').AsString +
            '","description": "' + qNewWSClients.FieldByName('Description').AsString +
            '","name": "' + qNewWSClients.FieldByName('Name').AsString +
            '","owner": "epmsdev"}
            //';  }

    //{"author": "epmsdev","class": "WEBDOC","default_security": "public","description": "JR Test Workspace",
    //"name": "001 - JR Test Workspace","owner": "epmsdev"}
  //  rRequestUpdate.AddParameter('body', rBody, TRESTRequestParameterKind.pkREQUESTBODY);
    rRequestUpdate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestUpdate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestUpdate.Execute;
    if rResponseUpdate.StatusCode = 200 then
    begin
      //update staging with folder id
   {   rResponseCreate.GetSimpleValue('workspace_id', rWSID);
      rFolderID := rWSID.Substring(pos(rWSID,'!')+1);
      qUpdateWSID.ParamByName('UniqueID').AsString := rFolderID;
      qUpdateWSID.Execute;    }
      result := True;
      Log_WS_MetaData := 'Y';
    end
    else
    begin
      //record failure
      result := False;
      Log_WS_MetaData := 'Status = ' + IntToStr(rResponseUpdate.StatusCode);
    end;

{  except on E: Exception do
    begin
      result := False;
      Log_WS_MetaData := 'Status = ' + IntToStr(rResponseUpdate.StatusCode);
    end;
}  end;

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
      //CurrentWSID := '';
      Log_WSID := qNewWSMatters.FieldByName('WSID').AsString;
      If not CheckWSExists(qNewWSMatters.FieldByName('C1Alias').AsString, qNewWSMatters.FieldByName('DBId').AsString) Then
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

        //Create new Matter workspace
        rRequestLogin.Execute;
        If CreateMatterWS then
        begin
          UpdateMatterWS;
          SetWSPerms(qNewWSMatters.FieldByName('DBId').AsString, qNewWSMatters.FieldByName('Default_Security_Group').AsString);
          CreateWSRootFolders(qNewWSMatters.FieldByName('DBId').AsString);
        end
      End
      else
      begin
        //Matter Workspace already exists
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

//  rRequestLogin.Execute;
//  rResponseLogin.GetSimpleValue('X-Auth-token', AuthToken);

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
      Result := False;
      Log_Custom3 := 'Error';
    end;
  end;
End;


Function TfiManWSProcessor.CreateMatterWS():boolean;
var
  rBody, rFolderID, rLongDB : string;
  MatterJSONObject : TJsonObject;
Begin
  try
    Result := False;
    rResponseCreate.Content.Empty;

    rRequestCreate.Params.Clear;
    rRequestCreate.Resource := v2APIBase + qNewWSMatters.FieldByName('DBId').AsString + '/workspaces';
    rBody := '{"author": "wsadmin","class": "WEBDOC","default_security": "' +
            LowerCase(qNewWSMatters.FieldByName('DefaultVisibility').AsString) +
            '","description": "' + qNewWSMatters.FieldByName('Description').AsString +
            '","name": "' + qNewWSMatters.FieldByName('Name').AsString +
            '","owner": "wsadmin"}';

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
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
//    ClientJSONObject.Free;

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
    ///work/api/v2/customers/{customerId}/libraries/{libraryId}/workspaces/{workspaceId}
    rBody := '{"custom1": "' +  qNewWSMatters.FieldByName('C1Alias').AsString +
              '","custom2": "' + qNewWSMatters.FieldByName('C2Alias').AsString +
              '","custom3": "' + qNewWSMatters.FieldByName('C3Alias').AsString +
              '","custom5": "' + qNewWSMatters.FieldByName('C5Alias').AsString +
              '","custom6": "' + qNewWSMatters.FieldByName('C6Alias').AsString +
              '","custom8": "' + qNewWSMatters.FieldByName('C8Alias').AsString +
              '","custom23": "' + qNewWSMatters.FieldByName('CDate3').AsString +
              '","custom25": "' + rProspective  +
              '","sub_class": "MATTER' +
//              '","subclass": "MATTER' +
              '","project_custom1": "' + qNewWSMatters.FieldByName('C2Alias').AsString +
              '","project_custom2": "' + qNewWSMatters.FieldByName('TemplateId').AsString +
              '","project_custom3": "Worksite"}';


    rRequestUpdate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestUpdate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestUpdate.Execute;
    if rResponseUpdate.StatusCode = 200 then
    begin
      //update staging with folder id
   {   rResponseCreate.GetSimpleValue('workspace_id', rWSID);
      rFolderID := rWSID.Substring(pos(rWSID,'!')+1);
      qUpdateWSID.ParamByName('UniqueID').AsString := rFolderID;
      qUpdateWSID.Execute;    }
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
