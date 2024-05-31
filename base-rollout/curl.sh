#!/bin/bash

# 요청을 보낼 URL을 지정합니다.
URL="http://34.64.165.19"

# 무한 루프를 통해 1초마다 curl 요청을 보냅니다.
while true; do
# curl 명령어를 사용하여 요청을 보냅니다.
  curl -s $URL

  # 1초 대기합니다.
  sleep 1
done
