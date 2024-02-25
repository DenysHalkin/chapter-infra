variable "ecs" {
  description = "ECS vars"
  type = object({
    container = object({
      image         = string
      cpu           = number
      memory        = number
      secrets       = any
      desired_count = number
    })
  })
}