From ruby:2.7-alpine

RUN gem install ultrahook

ENV TARGET=http://localhost:32001
ENV KEY="M9OhWCCHfQcfSkC3GBYgUrMLwdPRBdTS"
ENV DOMAIN="github-push"

CMD ultrahook -k ${KEY} ${DOMAIN} ${TARGET}