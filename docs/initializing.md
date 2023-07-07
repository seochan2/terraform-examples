# Initializing
## 1. 작업 폴더 설정
### 1.1 작업 폴더 이동
```
PS D:\> mkdir D:\GSCP\Terraform

PS D:\> cd D:\GSCP\Terraform
```
### 1.2 작업 tf 파일 다운로드
```
PS D:\GSCP\Terraform> git config --global http.sslVerify false

PS D:\GSCP\Terraform> git clone https://github.com/seochan2/terraform-examples.git PangyoPortal

PS D:\GSCP\Terraform> cd tf-aws-3tier-web
```
## 2. terraform workspace 생성 및 설정
### 2.1 stg / prod workspace 생성
```
PS D:\GSCP\Terraform\PangyoPortal\tf-aws-3tier-web> terraform workspace new stg

PS D:\GSCP\Terraform\PangyoPortal\tf-aws-3tier-web> terraform workspace new prod
```
### 2.2 작업 workspace 확인(stg)
```
PS D:\GSCP\Terraform\PangyoPortal\tf-aws-3tier-web> terraform workspace new list
  default
* prod
  stg
```
```  
 PS D:\GSCP\Terraform\PangyoPortal\tf-aws-3tier-web> terraform workspace select stg
 Switched to workspace "stg".
``` 
```
 PS D:\GSCP\Terraform\PangyoPortal\tf-aws-3tier-web> terraform workspace show
 stg
```
