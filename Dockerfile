FROM python:3.10

RUN apt-get update >/dev/null && \
    apt-get upgrade -y >/dev/null && \
    apt-get install -y git advancecomp optipng imagemagick

RUN pip install pillow==9.0.0

RUN git clone \
    --depth 1 \
    --filter=blob:none \
    --sparse \
    https://github.com/wesnoth/wesnoth \
    /wesnoth
WORKDIR /wesnoth
RUN git sparse-checkout set utils/woptipng.py

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
