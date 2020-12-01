terraform {
  backend "remote" {
    organization = "htn"

    workspaces {
      name = "gh-actions-demo"
    }
  }
}