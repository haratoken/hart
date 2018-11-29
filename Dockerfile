FROM juwitaw/truffle-base-image:beta
MAINTAINER Juwita Winadwiastuti <juwita.winadwiastuti@dattabot.io>
ADD . /code/
RUN npm install