variable "region" {
  # This should be provided when the module is used, as TF_VAR_REGION - See Doppler
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "profile" {
  # This should be provided when the module is used, as TF_VAR_PROFILE - See Doppler
  description = "AWS CLI profile to use"
  type        = string
  default     = "default" 
}
