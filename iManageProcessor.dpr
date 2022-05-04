program iManageProcessor;

uses
  Vcl.Forms,
  iManageWSProcessor in 'iManageWSProcessor.pas' {fiManWSProcessor};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfiManWSProcessor, fiManWSProcessor);
  Application.Run;
end.
