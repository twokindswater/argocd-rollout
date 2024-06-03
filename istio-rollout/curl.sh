#!/bin/bash

# 요청을 보낼 URL을 지정합니다.
URL="http://rollouts-demo-vsvc1.local"

# 무한 루프를 통해 1초마다 curl 요청을 보냅니다.
v2_count=0
v3_count=0
while true; do
# curl 명령어를 사용하여 요청을 보냅니다.
  res=$(curl -s $URL)

  v2=$(echo $res | grep -o "v2.0" | wc -l)
  v3=$(echo $res | grep -o "v3.0" | wc -l)

  v2_count=$((v2_count+v2))
  v3_count=$((v3_count+v3))

  v2_per=$(echo "scale=2; $v2_count/($v2_count+$v3_count)*100" | bc)
  v3_per=$(echo "scale=2; $v3_count/($v2_count+$v3_count)*100" | bc)

  echo "v2.0 count: $v2_count($v2_per%), v3.0 count: $v3_count($v3_per%)"

  # 1초 대기합니다.
  sleep 1
done
