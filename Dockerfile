FROM redhat/ubi9

COPY docker/ /

RUN <<DOCKERFILE_HERE_DOC
#!/bin/bash -ex

# パラメータ (将来的には実行時の環境変数で渡す)
USER_ID=1000
USER_NAME=testuser
USER_PASSWORD=testuser
GROUP_ID=1000
GROUP_NAME=testuser
PASSWORD_AUTHENTICATION=true
PUBLIC_KEY="ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBTAkMKQIN5ZDo63icfQafO/MQsDcWbiX2ApS0iEFiVzJgev5GUjAVe3rZKGt6DQ0RRJFTrt6EtbAjyVqS/GK3o= jaybanuan@devpc"

# 各種パッケージをインストール
dnf install -y sudo openssh-server python3.12 python3.12-pip
dnf clean all

# OpenSSH Serverの設定 (パスワード認証の有効化/無効化)
if [[ "$PASSWORD_AUTHENTICATION" == "true" ]]; then
    sed -i -E 's/^#?PasswordAuthentication .*$/PasswordAuthentication yes/' /etc/ssh/sshd_config
else
    sed -i -E 's/^PasswordAuthentication .*$/PasswordAuthentication no/' /etc/ssh/sshd_config
fi

# OpenSSH Serverの設定 (PAMを無効化)
sed -i -E 's/^#?UsePAM .*$/UsePAM no/' /etc/ssh/sshd_config

# OpenSSH Serverの設定 (ホスト鍵の生成)
# これを実行しないと「sshd: no hostkeys available -- exiting.」というエラーでsshdが終了する
ssh-keygen -A

# OpenSSH Serverの設定 (systemdのサービスを有効化)
#systemctl enable sshd

# ユーザの追加
groupadd -g ${GROUP_ID} ${GROUP_NAME}
useradd -m -u ${USER_ID} -g ${GROUP_NAME} ${USER_NAME}
printf "${USER_NAME}:${USER_PASSWORD}" | chpasswd

# ユーザの設定 (sshの公開鍵の登録)
mkdir -p /home/${USER_NAME}/.ssh/
echo ${PUBLIC_KEY} >> /home/${USER_NAME}/.ssh/authorized_keys

# ユーザの設定 (ディレクトリのパーミッションの調整)
chown -R ${USER_NAME}:${GROUP_NAME} /home/${USER_NAME}/ 
chmod 700 /home/${USER_NAME}/.ssh
chmod 600 /home/${USER_NAME}/.ssh/authorized_keys

# sudoersの設定
echo "${USER_NAME} ALL=(ALL:ALL) NOPASSWD:ALL" > "/tmp/${USER_NAME}"
visudo --check --file="/tmp/${USER_NAME}"
install -o root -g root -m 440 "/tmp/${USER_NAME}" /etc/sudoers.d/

DOCKERFILE_HERE_DOC

CMD ["/usr/sbin/sshd", "-D"]
#ENTRYPOINT [ "/docker-entrypoint.sh" ]
