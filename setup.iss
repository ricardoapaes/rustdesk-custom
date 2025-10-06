; Script Inno Setup para RustDesk - Instalação com Executável
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
; Arquivo EXE será incluído automaticamente

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
#define EXE_FILE GetEnv("EXE_FILE")

[Files]
; Inclui o arquivo EXE baixado automaticamente
Source: "{#EXE_FILE}"; DestDir: "{app}"; DestName: "rustdesk.exe"; Flags: ignoreversion

[Icons]
; Cria um atalho no Menu Iniciar
Name: "{group}\RustDesk Acesso Remoto"; Filename: "{app}\rustdesk.exe"
; Cria um atalho na Área de Trabalho (Desktop)
Name: "{commondesktop}\RustDesk Acesso Remoto"; Filename: "{app}\rustdesk.exe"

[Run]
; 1. Cria diretório de configuração
Filename: "cmd.exe"; Parameters: "/c md ""%APPDATA%\RustDesk\config"""; StatusMsg: "Criando diretório de configuração..."; Flags: runhidden
; 2. Cria arquivo de configuração temporário para importação
Filename: "cmd.exe"; Parameters: "/c echo custom-rendezvous-server = ""{#ID_SERVER_HOST}"" > ""{tmp}\rustdesk_config.toml"""; StatusMsg: "Preparando configuração..."; Flags: runhidden; Check: IsConfigValid()
Filename: "cmd.exe"; Parameters: "/c echo key = ""{#ENCRYPTION_KEY}"" >> ""{tmp}\rustdesk_config.toml"""; StatusMsg: "Preparando chave..."; Flags: runhidden; Check: IsConfigValid()
; 3. Instala como serviço
Filename: "{app}\rustdesk.exe"; Parameters: "--install-service"; WorkingDir: "{app}"; StatusMsg: "Instalando serviço RustDesk..."; Flags: runhidden waituntilterminated
; 4. Importa a configuração usando --import-config
Filename: "{app}\rustdesk.exe"; Parameters: "--import-config ""{tmp}\rustdesk_config.toml"""; WorkingDir: "{app}"; StatusMsg: "Importando configuração..."; Flags: runhidden waituntilterminated; Check: IsConfigValid()
; 5. Inicia o serviço
Filename: "net"; Parameters: "start RustDesk"; StatusMsg: "Iniciando serviço RustDesk..."; Flags: runhidden waituntilterminated

[UninstallRun]
; Para o serviço antes da desinstalação
Filename: "net"; Parameters: "stop RustDesk"; Flags: runhidden waituntilterminated; RunOnceId: "StopRustDeskService"
; Remove o serviço
Filename: "{app}\rustdesk.exe"; Parameters: "--uninstall-service"; WorkingDir: "{app}"; Flags: runhidden waituntilterminated; RunOnceId: "UninstallRustDeskService"

[Code]
function IsConfigValid(): Boolean;
begin
  Result := ('{#ID_SERVER_HOST}' <> '') and ('{#ENCRYPTION_KEY}' <> '');
end;