; Inno Setup script for TKK EyeGuard (Windows installer).
; Build the app first:  flutter build windows --release
; Then compile:         iscc installers\windows\eyeguard.iss

#define AppName "TKK EyeGuard"
#define AppVersion "1.0.0"
#define AppPublisher "Techie Krishna Kayaking"
#define AppURL "https://www.techiekrishnakayaking.com"
#define AppExeName "tkk_eyeguard.exe"
#define BuildDir "..\..\build\windows\x64\runner\Release"

[Setup]
AppId={{B7B2F2A0-2F2E-4D6C-9E2E-EYEGUARD000001}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputBaseFilename=TKK-EyeGuard-Setup-{#AppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
UninstallDisplayIcon={app}\{#AppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"
Name: "startupicon"; Description: "Start {#AppName} when I sign in"; GroupDescription: "Startup:"

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon
Name: "{userstartup}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: startupicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent
