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

target "image-platform" {
  platforms = [
    "linux/amd64",
    "linux/386",
    "linux/arm64",
    "linux/arm",
  ]
}

target "bin-platform" {
  platforms = [
    "linux/amd64",
    "linux/386",
    "linux/arm64",
    "linux/arm",
    "freebsd/amd64",
    "freebsd/386",
    "freebsd/arm64",
    "freebsd/arm",
    "windows/amd64",
    "freebsd/386",
    "windows/arm64",
    "windows/arm",
    "darwin/amd64",
    "windows/386",
    "darwin/arm64",
    "darwin/arm",
  ]
}

group "default" {
  targets = ["image-local"]
}

target "image-local" {
  inherits = ["_common"]
  target   = "slim"
  tags     = ["local-image/rover:edge"]
  output   = ["type=docker"]
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
  inherits = ["_common", "image-platform"]
  target   = "fat"
}

target "image-slim-all-arch" {
  inherits = ["_common", "image-platform"]
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
  inherits = ["artifact-all", "bin-platform"]
  target   = "artifact-all"
  output   = ["./dist"]
}
