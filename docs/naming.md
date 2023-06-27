# Naming conventions

## 1. 일반 규칙
### 1.1 리소스, 데이터 소스, 변수, 아웃풋등에 "-" (dash) 대신 "_" (underscore) 사용
- Good
```
resource "aws_instance" "web_server" {}
```
- Bad
```
resource "aws_instance" "web-server" {}
```
	
### 1.2 소문자와 숫자만 사용
- Good
```
resource "aws_instance" "web_server" {}
```
- Bad
```
resource "Aws_Instance" "web-server" {}
```
	
## 2. 리소스 및 데이터 소스
### 2.1 리소스 이름에 리소스 유형 반복 금지
- Good
```
resource "aws_route_table" "public" {}
```
- Bad
```
resource "aws_route_table" "public_route_table" {}
resource "aws_route_table" "public_aws_route_table" {}
```
	
### 2.2 리소스 모듈이 단일 타입의 리소스를 생성하거나, 리소스가 더 이상 설명할 수 없는 일반적인 리소스일 경우, 이름을 "this" 사용
- Good
```
resource "aws_route53_health_check" "this" {}
```
- Bad
```
resource "aws_route53_health_check" "health_check" {}
```
 	
### 2.3 이름은 단수형 사용
- Good
```
resource "aws_subnet" "subnetwork"
```
- Bad
```
resource "aws_subnet" "subnetworks"
```	
	
### 2.4 사용자가 확인하는 내부 인자 값은 "-" (dash) 사용
- Good
```
resource "aws_instance" "web_server" {
  name = "web-server"
}
```
- Bad
```
resource "aws_instance" "web-server" {
  name = "web_server"
}
```
	
### 2.5 count / for_each 인자는 내부 리소스나 데이터 소스 블록의 첫번째 인자로 표시후, 줄 바꿈으로 구분
- Good
```
resource "aws_route_table" "public" {
  count = 2

  vpc_id = "vpc-12345678"
  ...
}
```
```
resource "aws_route_table" "private" {
  for_each = toset(["one", "two"])

  vpc_id = "vpc-12345678"
  ...
}
```
- Bad
```
resource "aws_route_table" "public" {
  vpc_id = "vpc-12345678"
  count  = 2

  ...
}
```
	
### 2.6 tags 인자는 depends_on과 lifecycle를 제외하고, 가장 마지막 인자로 포함. 필요시 빈줄로 나머지 인자들과 구분
- Good
```
resource "aws_nat_gateway" "this" {
  count = 2

  allocation_id = "..."
  subnet_id     = "..."

  tags = {
    Name = "..."
  }

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    create_before_destroy = true
  }
}  
```
- Bad
```
resource "aws_nat_gateway" "this" {
  count = 2

  tags = "..."

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    create_before_destroy = true
  }

  allocation_id = "..."
  subnet_id     = "..."
}
```
	
### 2.7 count / for_each 인자에 condition 사용시, length나 다른 expression 대신 boolean 사용
- Good
```
resource "aws_nat_gateway" "that" {    
  count = var.create_public_subnets ? 1 : 0
}
```
- Good
```
resource "aws_nat_gateway" "this" {    
  count = length(var.public_subnets) > 0 ? 1 : 0
}
```
		
## 변수
### 3.1 name, description, default 값은 인수 참조내 정의된 값을 사용
### 3.2 변수의 유효성 검사는 제한적이므로 적절하게 사용
### 3.3 list(...)나 map(...) 타입 이름은 복수형 사용
- Good
```
variable "internal_ranges" { 
  description = "IP CIDR ranges for intra-VPC rules."
  type        = list(string)
  default     = []
}
```
- Bad
```
variable "internal_range" { 
  description = "IP CIDR ranges for intra-VPC rules."
  type        = list(string)
  default     = []
}
```

### 3.4 변수 블럭 키 순서 : description > type > default > validation
- Good
```
variable "groups" { 
  description = "Contain the details of the Groups to be created."
  type = object({
    ...
  })
  default = {
    ...
  }
  validation {
    ....
  }
}
```
		
### 3.5 가능한 모든 변수에 description 포함
- Good
```
variable "internal_ranges" { 
  description = "IP CIDR ranges for intra-VPC rules."
  type        = list(string)
  default     = []
}
```
- Bad
```
variable "internal_ranges" { 
  type        = list(string)
  default     = []
}
```
		
### 3.6 복잡한 object() 타입 대신 단순한 number, string, list(...), map(...), any 타입 사용
- Best
```
variable "peer_external_gateway" { # Object Type variable
  description = "Configuration of an external VPN gateway to which this VPN is connected."
  type = object({
    redundancy_type = string
    interfaces = list(object({
      id         = number
      ip_address = string
    }))
  })
  default = null
}
```
	
### 3.7 동일한 type(ex. string)이거나 동일한 type으로 변환 가능하다면, ex. map(map(string)) type 사용
### 3.8 "any" 사용시, 유효성 검사 비활성화
### 3.9 map을 만들기 위해서는 "{}" 대신 tomap(...) 사용
 - Best
```
locals {
  restart_policy_enum = tomap({
  "onfailure" : "OnFailure"
  "unlessstopped" : "UnlessStopped"
  "always" : "Always"
  "never" : "Never"
})
```
	
## 아웃풋
### 4.1 아웃풋의 이름은 항상 포함하고 있는 속성을 명확하게 설명
- Good
```
output "password" { 
  description = "Auto-generated password, if no password was set as a variable."
  sensitive   = true
  value       = local.use_kms && var.password == "" ? "" : local.password
}
```
- Bad
```
output "sensitive_value" { 
  description = "Auto-generated password, if no password was set as a variable."
  sensitive   = true
  value       = local.use_kms && var.password == "" ? "" : local.password
}
```
	
### 4.2 {name}_{type}_{attribute} 형태의 아웃풋 이름 구조 추천
### 4.3 아웃풋이 여러 리소스들로 반환된다면, this 대신 일반적인 이름 사용
- Good
```
output "additional_users" { 
  description = "List of maps of additional users and passwords"
  value = [for r in google_sql_user.additional_users :
    {
      name     = r.name
      password = r.password
    }
    ]
  sensitive = true
}
```
- Bad
```
output "additional_users_name_and_password" { 
  description = "List of maps of additional users and passwords"
  value = [for r in google_sql_user.additional_users :
    {
      name     = r.name
      password = r.password
    }
    ]
  sensitive = true
}
```
	
### 4.4 아웃풋이 list 값을 반환한다면, 복수형 사용
- Good
```
output "names" { 
  description = "Bucket names."
  value = { for name, bucket in google_storage_bucket.buckets :
    name => bucket.name
  }
}
```
- Bad
```
output "name" { 
  description = "Bucket names."
  value = { for name, bucket in google_storage_bucket.buckets :
    name => bucket.name
  }
}
```
	
### 4.5 모든 아웃풋에 description 명시
- Good
```
output "bucket" { 
  description = "Bucket resource (for single use)."
  value       = local.first_bucket
}
```
- Bad
```
output "bucket" { 
  value       = local.first_bucket
}
```
	
### 4.6 아웃풋에 대한 전체 권한을 가지고 있지 않다면, sensitive 인자 사용 지양
### 4.7 element(concat(...)) 대신 try() 사용
- Good
```
output "bigquery_destination_name" { 
  description = "The resource name for the destination BigQuery."
  value       = try(module.destination_bigquery[0].resource_name, "")
}
```
- Bad
```
output "bigquery_destination_name" { 
  description = "The resource name for the destination BigQuery."
  value       = element(concat(module.destination_bigquery[0].resource_name, ""),0)
}
```

### 4.8 Secret은 아웃풋의 반환값으로 사용하지 말고, 만약 사용할 경우 Sensitive를 True로 설정
- Good
```
output "generated_user_password" { 
  description = "The auto generated default user password if not input password was provided"
  value       = random_password.user-password.result
  sensitive   = true
}
```
- Bad
```
output "generated_user_password" { 
  description = "The auto generated default user password if not input password was provided"
  value       = random_password.user-password.result  
}
```
				
## 모듈
### 5.1 "terraform-{provider}-{name}" 형태의 모듈명 사용
### 5.2 모듈 버전은 Semantic Versioning 준수
```
X.Y.Z 형태 버전명
```
		 
### 5.3 모든 변수는 variables.tf 파일에 description과 type을 포함하여 사용
### 5.4 모든 아웃풋은 outputs.tf 파일에 description을 포함하여 사용
### 5.5 참조할때 항상 상대 경로(relative path)와 file() 사용
- Best
```
provider "google-beta" { 
  credentials = file(var.credentials_path)
  region      = var.region
}
module "base_env" { 
  source = "../../modules/base_env"
  ...
}
```
	
### 5.6 모든 모듈과 프로바이더의 버전은 특정한 버전으로 고정하여 사용
### 5.7 모듈의 리소스는 큰 단위보다는 작은 단위의 리소스로 정의하여 사용
### 5.8 default 값 정의시, terraform.tfvars 보다는 variables.tf 사용
	
## 6. 스테이트
### 6.1 리모트 스테이트 사용
### 6.2 state locking을 위해 backend 사용
### 6.3 스테이트를 저장하는 오브젝트 스토리지는 Versioning과 Encryption, IAM 폴리시 사용	

### refs
[GCP에서 Terraform을 사용하기 위한 Best Practice](https://nangman14.tistory.com/84)

[Terraform Best Practices](https://www.terraform-best-practices.com/naming)
