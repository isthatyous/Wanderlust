locals {
  instance_config = {
    Jenkins-Master = {
      instance_type = "t3.micro"
      volume_size   = 15
    }
    Jenkins-Slave = {
      instance_type = "t2.medium"
      volume_size   = 30
    }
  }

  name = "wanderlust-cluster"
}
