# コードを実行するコンテナイメージ
FROM alpine:3.10

RUN apk add bash

# アクションのリポジトリからコードファイルをコンテナのファイルシステムパス `/`にコピー
COPY src/main/resources/docker-entrypoint.sh /docker-entrypoint.sh

# dockerコンテナが起動する際に実行されるコードファイル (`entrypoint.sh`)
ENTRYPOINT ["docker-entrypoint.sh"]
