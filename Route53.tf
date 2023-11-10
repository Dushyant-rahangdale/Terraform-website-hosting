resource "aws_route53_zone" "aws_zone53" {
name = "dushyant-demo-project.ml"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.aws_zone53.zone_id
  name    = "dushyant-demo-project.ml"
  type    = "A"
  ttl     = 10
}