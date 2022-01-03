variable "GO_VERSION" {
  default = "1.17"
}

variable "NODE_VERSION" {
  default = "16"
}

variable "TF_VERSION" {
  default = "1.1.0"
}

target "_common" {
  args = {
    GO_VERSION   = GO_VERSION
    NODE_VERSION = NODE_VERSION
    TF_VERSION   = TF_VERSION
  }
}

target "platform" {
  platforms = [
    "linux/386",
    "linux/amd64",
    "linux/arm64",
    "linux/arm/v7",
    "linux/arm/v6",
  ]
}

group "default" {
  targets = ["image-fat"]
}

target "image-fat" {
  inherits = ["_common"]
  target   = "fat"
}

target "image-slim" {
  inherits = ["_common"]
  target   = "slim"
}

target "image-fat-all-arch" {
  inherits = ["_common", "platform"]
  target   = "fat"
}

target "image-slim-all-arch" {
  inherits = ["_common", "platform"]
  target   = "slim"
}

target "artifact" {
  inherits = ["_common"]
  target   = "artifact"
  output   = ["./dist"]
}

target "artifact-slim" {
  inherits = ["_common"]
  target   = "artifact-slim"
  output   = ["./dist"]
}

# Creating all full, slim artifact with arm and amd platform
target "artifact-all" {
  inherits = ["artifact-all", "platform"]
  target   = "artifact-all"
  output   = ["./dist"]
}
