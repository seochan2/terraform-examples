# Initializing
## 1. 작업 폴더 설정
### 1.1 작업 폴더 이동
```
PS D:\> mkdir D:\Terraform

PS D:\> cd D:\Terraform
```
### 1.2 작업 tf 파일 다운로드
```
PS D:\Terraform> git config --global http.sslVerify false

PS D:\Terraform> git clone https://github.com/seochan2/terraform-examples.git tf-sample

PS D:\Terraform> cd tf-aws-3tier-web
```
## 2. terraform workspace 생성 및 설정
### 2.1 stg / prod workspace 생성
```
PS D:\Terraform\tf-sample\tf-aws-3tier-web> terraform workspace new stg

PS D:\Terraform\tf-sample\tf-aws-3tier-web> terraform workspace new prod
```
### 2.2 작업 workspace 확인(stg)
```
PS D:\Terraform\tf-sample\tf-aws-3tier-web> terraform workspace new list
  default
* prod
  stg
```
```  
 PS D:\Terraform\tf-sample\tf-aws-3tier-web> terraform workspace select stg
 Switched to workspace "stg".
``` 
```
 PS D:\Terraform\tf-sample\tf-aws-3tier-web> terraform workspace show
 stg
```
