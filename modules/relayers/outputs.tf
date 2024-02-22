data "aws_lb" "dns" {
  for_each = toset(var.relayers_name)
  name = "${var.project_name}-${each.value}-lb-${var.env_sufix}"
}

output "lb_names_arns" {
  value = {
    for lb in data.aws_lb.dns : lb.id => {
      name = lb.name
      arn  = lb.arn
    }
  }
}