variable "sops_source_file" {
  type        = string
  description = "The relative path to the SOPS file which is consumed as the source for creating parameter resources."
  default     = ""
}

variable "params_prefix" {
  type        = string
  description = "Params prefix"
  default     = ""
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags"
}