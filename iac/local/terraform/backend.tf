terraform {
  backend "local" {
    # This is an optional but good practice.
    # It specifies the path for the state file.
    # By default, it's 'terraform.tfstate' in the current directory.
    path = "terraform.tfstate"
  }
}
