#!/usr/bin/env bats

@test "created a python virtualenv" {
    [ -d "/opt/leeroy/env" ]
    [ -f "/opt/leeroy/env/bin/activate" ]
}

@test "starts gunicorn" {
  run pgrep -f ^.*python.*gunicorn.*$
  [ $status -eq 0 ]
}

@test "gunicorn is available on port 3399" {
  run nc -z 0.0.0.0 3399
  [ $status -eq 0 ]
}

@test "installed crontab for leeroy-cron" {
  [ -f "/etc/cron.d/leeroy-cron" ]
}
