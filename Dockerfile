FROM ubuntu:26.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl ca-certificates git openssh-client sudo bash jq iputils-ping

# non-root user
RUN useradd -m -s /bin/bash opencode_user \
  && echo "opencode_user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/opencode_user \
  && chmod 0440 /etc/sudoers.d/opencode_user

USER opencode_user
WORKDIR /home/opencode_user
ENV HOME=/home/opencode_user

RUN git config --global user.name "danielhammerl-ai-agent"
RUN git config --global user.email "aiagent@danielhammerl.de"
RUN git config --global credential.helper \
'!f() { echo username=x-access-token; echo password=$GITHUB_TOKEN; }; f'

RUN git config --global --add safe.directory /home/opencode_user/project

# install OpenCode (official installer)
RUN curl -fsSL https://opencode.ai/install | bash

# ensure opencode bin on PATH for non-login shells
ENV PATH=/home/opencode_user/.opencode/bin:$PATH

ENTRYPOINT ["opencode"]