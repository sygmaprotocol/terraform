locals {
  lb_names = tomap({ for i in var.relayers_name : i => null })
}

resource "local_file" "dns" {
  for_each = local.lb_names
  content  = aws_lb.main[each.key].dns_name
  filename = "${path.module}/dns/dns.${each.key}"
}

resource "null_resource" "dns" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    working_dir = "${path.module}/dns/"
    command     = <<EOF
      rm dns_address
      for i in dns.*; do (cat $i; echo '') >> dns_address; done
      rm dns.*
    EOF
  }
  depends_on = [
    local_file.dns
  ]
}