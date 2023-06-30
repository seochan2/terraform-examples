# Setting
## 1. Chocolatey 설치 
### 1.1 Window Powershell 관리자 권환으로 실행
### 1.2 Powershell 파워쉘 실행정책 확인
```
Get-ExecutionPolicy
```
- Restricted가 아닐 경우 아래 명령어 실행 후 Y 입력
```
Set-ExecutionPolicy AllSigned
```
### 1.3 설치
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```
- 설치 확인
```
PS C:\Windows\system32> choco
Chocolatey v2.0.0
Please run 'choco -?' or 'choco <command> -?' for help menu.
```
## 2. AWS CLI 설치
```
choco install awscli -y
```
- 설치 확인
```
PS C:\Windows\system32> aws --version
aws-cli/2.12.4 Python/3.11.4 Windows/10 exe/AMD64 prompt/off
```

## 3. Terraform 설치
```
choco install terraform -y
```
- 설치 확인
```
PS C:\Windows\system32> terraform version
Terraform v1.5.1
on windows_amd64
```
