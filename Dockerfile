FROM node:alpine AS base
RUN apk add --no-cache openssl-dev ca-certificates
WORKDIR /app

FROM base as builder-base
RUN apk add --no-cache git
RUN git clone https://github.com/tovyblox/tovy /app

FROM builder-base as build
RUN export NODE_ENV=production
RUN yarn install --production=true
RUN yarn add @tiptap/pm
RUN yarn run prisma:generate
RUN yarn build

FROM builder-base as prod-build

RUN yarn install
RUN yarn add @tiptap/pm
RUN yarn run prisma:generate
RUN cp -R node_modules prod_node_modules

FROM base as prod

COPY --from=prod-build /app/prod_node_modules /app/node_modules
COPY --from=build  /app/.next /app/.next
COPY --from=build  /app/public /app/public
COPY --from=build  /app/prisma /app/prisma

ARG PORT=3000
EXPOSE 3000
CMD ["node_modules/.bin/next", "start"]
