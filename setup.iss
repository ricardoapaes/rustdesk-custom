; Script Inno Setup para RustDesk - Instalação Automática com MSI
; Gerado automaticamente para trabalhar com downloads do GitHub

[Setup]
; --- Informações Básicas do Instalador ---
AppName={#GetEnv("APP_NAME") != "" ? GetEnv("APP_NAME") : "RustDesk - Acesso Remoto"}
AppVersion={#GetEnv("APP_VERSION") != "" ? GetEnv("APP_VERSION") : "1.0.0"}
DefaultDirName={pf}\RustDesk
DefaultGroupName=RustDesk
UninstallDisplayIcon={app}\rustdesk.exe
Compression=lzma
SolidCompression=yes
OutputDir=Output
OutputBaseFilename=RustDesk_Instalador_Customizado_{#GetEnv("RUSTDESK_VERSION")}
AppPublisher={#GetEnv("APP_PUBLISHER") != "" ? GetEnv("APP_PUBLISHER") : "Instalador Customizado"}
; Arquivo MSI será incluído automaticamente

; --- Configurações de Instalação ---
; Instala para todos os usuários (necessita de privilégios de administrador)
PrivilegesRequired=admin
; Desativa as páginas desnecessárias para uma instalação mais limpa/silenciosa
DisableProgramGroupPage=yes
DisableFinishedPage=no
AllowCancelIfInstallStarted=no
; Configuração para instalação silenciosa padrão
SilentInstall=yes
SilentUninstall=yes

; --- Variáveis Personalizadas ---
; Valores obtidos das variáveis de ambiente
#define ID_SERVER_HOST GetEnv("ID_SERVER_HOST")
#define ENCRYPTION_KEY GetEnv("ENCRYPTION_KEY")
#define MSI_FILE GetEnv("MSI_FILE")

[Files]
; Inclui o arquivo MSI baixado automaticamente
Source: "{#MSI_FILE}"; DestDir: "{tmp}"; Flags: ignoreversion deleteafterinstall
; Arquivos de configuração opcionais
Source: "config.toml"; DestDir: "{app}"; Flags: ignoreversion; Check: FileExists('config.toml')

[Icons]
; Cria um atalho no Menu Iniciar
Name: "{group}\RustDesk Acesso Remoto"; Filename: "{app}\rustdesk.exe"
; Cria um atalho na Área de Trabalho (Desktop)
Name: "{commondesktop}\RustDesk Acesso Remoto"; Filename: "{app}\rustdesk.exe"

[Run]
; 1. Primeiro executa o MSI original do RustDesk de forma silenciosa
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\{#MSI_FILE}"" /quiet /norestart"; WorkingDir: "{tmp}"; StatusMsg: "Instalando RustDesk..."; Flags: waituntilterminated

; 2. Aguarda um momento para garantir que a instalação foi concluída
Filename: "cmd.exe"; Parameters: "/c timeout /t 3 /nobreak"; WorkingDir: "{tmp}"; StatusMsg: "Aguardando conclusão..."; Flags: runhidden waituntilterminated

; 3. Configura o servidor ID/Relay e a Chave (se fornecidos)
Filename: "{pf}\RustDesk\rustdesk.exe"; Parameters: "--config id={#ID_SERVER_HOST} key={#ENCRYPTION_KEY}"; WorkingDir: "{pf}\RustDesk"; StatusMsg: "Configurando cliente..."; Flags: runhidden waituntilterminated; Check: IsConfigValid()

; 4. Instala como serviço para inicialização automática  
Filename: "{pf}\RustDesk\rustdesk.exe"; Parameters: "--install-service"; WorkingDir: "{pf}\RustDesk"; StatusMsg: "Configurando serviço..."; Flags: runhidden waituntilterminated

[UninstallRun]
; Remove o serviço antes da desinstalação
Filename: "{pf}\RustDesk\rustdesk.exe"; Parameters: "--uninstall-service"; WorkingDir: "{pf}\RustDesk"; Flags: runhidden waituntilterminated; Check: FileExists(ExpandConstant('{pf}\RustDesk\rustdesk.exe'))
; Desinstala o MSI
Filename: "msiexec.exe"; Parameters: "/x {#MSI_FILE} /quiet"; WorkingDir: "{tmp}"; Flags: runhidden waituntilterminated

[Code]
function IsConfigValid(): Boolean;
begin
  Result := ('{#ID_SERVER_HOST}' <> '') and ('{#ENCRYPTION_KEY}' <> '');
end;

function FileExists(FileName: String): Boolean;
begin
  Result := FileExists(FileName);
end;