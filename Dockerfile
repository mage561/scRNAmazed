FROM debian:bullseye-slim

LABEL image.author.name "Pitou"
LABEL image.author.email "pan-navarro@outlook.fr"

RUN apt-get update && apt-get install -y curl cowsay

ENV PATH=$PATH:/usr/games/
