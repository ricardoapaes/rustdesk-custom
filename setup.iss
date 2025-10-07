; Script Inno Setup para RustDesk - Instalação com MSI
; Gerado automaticamente para trabalhar com downloads do GitHub

[Setup]
; --- Informações Básicas do Instalador ---
AppId={#GetEnv("APP_ID") != "" ? GetEnv("APP_ID") : "RustDeskCustom"}
AppName={#GetEnv("APP_NAME") != "" ? GetEnv("APP_NAME") : "RustDesk - Acesso Remoto"}
AppVersion={#GetEnv("APP_VERSION") != "" ? GetEnv("APP_VERSION") : "1.0.0"}
DefaultDirName={autopf}\{#GetEnv("APP_PUBLISHER") != "" ? GetEnv("APP_PUBLISHER") : "Instalador Customizado"}\{#GetEnv("APP_NAME") != "" ? GetEnv("APP_NAME") : "RustDesk - Acesso Remoto"}
DefaultGroupName={#GetEnv("APP_NAME") != "" ? GetEnv("APP_NAME") : "RustDesk - Acesso Remoto"}
UninstallDisplayIcon={app}\rustdesk.exe
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
; Inclui o arquivo MSI baixado automaticamente
Source: "{#MSI_FILE}"; DestDir: "{tmp}"; DestName: "rustdesk.msi"; Flags: ignoreversion

[Run]
; 1. Instala o RustDesk MSI na pasta escolhida pelo usuário
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\rustdesk.msi"" INSTALLFOLDER=""{app}"" /quiet"; StatusMsg: "Instalando RustDesk na pasta personalizada..."; Flags: waituntilterminated; Check: IsConfigValid()
; 2. Configura o servidor e chave usando o método testado
Filename: "{app}\rustdesk.exe"; Parameters: "--config ""host={#ID_SERVER_HOST},key={#ENCRYPTION_KEY}"""; WorkingDir: "{app}"; StatusMsg: "Configurando servidor personalizado..."; Flags: runhidden waituntilterminated; Check: IsConfigValid()
; 3. Configura senha fixa
Filename: "{app}\rustdesk.exe"; Parameters: "--password ""{#DEFAULT_PASSWORD}"""; WorkingDir: "{app}"; StatusMsg: "Configurando senha fixa..."; Flags: runhidden waituntilterminated; Check: IsPasswordValid()
; 5. Inicia o serviço RustDesk automaticamente
Filename: "net"; Parameters: "start RustDesk"; StatusMsg: "Iniciando serviço RustDesk..."; Flags: runhidden waituntilterminated; Check: IsConfigValid()

[UninstallRun]
; Para o serviço antes da desinstalação
Filename: "net"; Parameters: "stop RustDesk"; Flags: runhidden waituntilterminated; RunOnceId: "StopRustDeskService"
; Desinstala o RustDesk usando o próprio executável
Filename: "{app}\rustdesk.exe"; Parameters: "--uninstall"; WorkingDir: "{app}"; Flags: runhidden waituntilterminated; RunOnceId: "UninstallRustDesk"

[Code]
function IsConfigValid(): Boolean;
begin
  Result := ('{#ID_SERVER_HOST}' <> '') and ('{#ENCRYPTION_KEY}' <> '');
end;

function IsPasswordValid(): Boolean;
begin
  Result := ('{#DEFAULT_PASSWORD}' <> '');
end;