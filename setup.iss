; Script Inno Setup para RustDesk - Instalação com MSI
; Gerado automaticamente para trabalhar com downloads do GitHub

[Setup]
; --- Informações Básicas do Instalador ---
AppId={#GetEnv("APP_ID") != "" ? GetEnv("APP_ID") : "RustDeskCustom"}
AppName={#GetEnv("APP_NAME") != "" ? GetEnv("APP_NAME") : "RustDesk - Acesso Remoto"}
AppVersion={#GetEnv("APP_VERSION") != "" ? GetEnv("APP_VERSION") : "1.0.0"}
DefaultDirName={autopf}\{#GetEnv("APP_PUBLISHER") != "" ? GetEnv("APP_PUBLISHER") : "Instalador Customizado"}\{#GetEnv("APP_NAME") != "" ? GetEnv("APP_NAME") : "RustDesk - Acesso Remoto"}
DefaultGroupName={#GetEnv("APP_NAME") != "" ? GetEnv("APP_NAME") : "RustDesk - Acesso Remoto"}
UninstallDisplayIcon={app}\app\rustdesk.exe
Compression=lzma
SolidCompression=yes
OutputDir=.
OutputBaseFilename=RustDesk_Instalador_Customizado_{#GetEnv("RUSTDESK_VERSION")}
AppPublisher={#GetEnv("APP_PUBLISHER") != "" ? GetEnv("APP_PUBLISHER") : "Instalador Customizado"}
; Arquivo MSI será incluído automaticamente

; --- Configurações de Instalação ---
; Instala para todos os usuários (necessita de privilégios de administrador)
PrivilegesRequired=admin
; Desativa as páginas desnecessárias para uma instalação mais limpa/silenciosa
DisableProgramGroupPage=yes
DisableFinishedPage=no
; Configurações para arquitetura 64-bit
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; --- Variáveis Personalizadas ---
; Valores obtidos das variáveis de ambiente
#define ID_SERVER_HOST GetEnv("ID_SERVER_HOST")
#define ENCRYPTION_KEY GetEnv("ENCRYPTION_KEY")
#define DEFAULT_PASSWORD GetEnv("DEFAULT_PASSWORD")
#define MSI_FILE GetEnv("MSI_FILE")

[Files]
Source: "{#MSI_FILE}"; DestDir: "{tmp}"; DestName: "rustdesk.msi"; Flags: ignoreversion

[Icons]
Name: "{autodesktop}\{#GetEnv("APP_NAME") != "" ? GetEnv("APP_NAME") : "RustDesk - Acesso Remoto"}"; Filename: "{app}\app\rustdesk.exe"; Tasks: desktopicon
Name: "{autoprograms}\{#GetEnv("APP_NAME") != "" ? GetEnv("APP_NAME") : "RustDesk - Acesso Remoto"}"; Filename: "{app}\app\rustdesk.exe"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Run]
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\rustdesk.msi"" INSTALLFOLDER=""{app}\app"" CREATESTARTMENUSHORTCUTS=""N"" CREATEDESKTOPSHORTCUTS=""N"" INSTALLPRINTER=""N"" /quiet"; StatusMsg: "Instalando RustDesk na pasta personalizada..."; Flags: waituntilterminated; Check: IsConfigValid()
Filename: "cmd.exe"; Parameters: "/c if exist ""{autodesktop}\RustDesk.lnk"" del ""{autodesktop}\RustDesk.lnk"""; StatusMsg: "Removendo atalhos indesejados..."; Flags: runhidden waituntilterminated
Filename: "{app}\app\rustdesk.exe"; Parameters: "--config ""host={#ID_SERVER_HOST},key={#ENCRYPTION_KEY}"""; WorkingDir: "{app}\app"; StatusMsg: "Configurando servidor personalizado..."; Flags: runhidden waituntilterminated; Check: IsConfigValid()
Filename: "{app}\app\rustdesk.exe"; Parameters: "--password ""{#DEFAULT_PASSWORD}"""; WorkingDir: "{app}\app"; StatusMsg: "Configurando senha fixa..."; Flags: runhidden waituntilterminated; Check: IsPasswordValid()
Filename: "net"; Parameters: "start RustDesk"; StatusMsg: "Iniciando serviço RustDesk..."; Flags: runhidden waituntilterminated; Check: IsConfigValid()

[UninstallRun]
Filename: "net"; Parameters: "stop RustDesk"; Flags: runhidden waituntilterminated; RunOnceId: "StopRustDeskService"
Filename: "{app}\app\rustdesk.exe"; Parameters: "--uninstall"; WorkingDir: "{app}\app"; Flags: runhidden waituntilterminated; RunOnceId: "UninstallRustDesk"

[Code]
function IsConfigValid(): Boolean;
begin
  Result := ('{#ID_SERVER_HOST}' <> '') and ('{#ENCRYPTION_KEY}' <> '');
end;

function IsPasswordValid(): Boolean;
begin
  Result := ('{#DEFAULT_PASSWORD}' <> '');
end;