FROM python:3.10-slim

RUN apt-get update >/dev/null && \
    apt-get upgrade -y >/dev/null && \
    apt-get install -y git advancecomp optipng imagemagick

RUN pip install pillow~=9.0

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
