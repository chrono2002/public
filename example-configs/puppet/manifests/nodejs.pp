$host = "nodejs.local"
$ip = "${ipaddress}"

$email_send_only = 1
$vps = 1

$www_dir = "/www"

class { 'zloy::nodejs': }
