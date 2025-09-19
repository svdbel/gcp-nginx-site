variable "project_id" {
  description = "GCP Project ID"
  type        = string
  #project  = "my-resume-472320"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "VM instance name"
  type        = string
  default     = "nginx-ansible-vm"
}

variable "machine_type" {
  description = "Machine type"
  type        = string
  default     = "e2-micro"
}
