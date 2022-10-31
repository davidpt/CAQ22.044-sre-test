output "Network" {
  value = [aws_vpc.my_vpc, aws_subnet.my_subnet]
}
