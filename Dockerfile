FROM node:lts-buster-slim AS base
RUN apt-get update && apt-get install libssl-dev ca-certificates git -y
WORKDIR /app
RUN git clone https://github.com/tovyblox/tovy /app

FROM base as build
RUN export NODE_ENV=production
RUN yarn

RUN yarn run prisma:generate
RUN yarn build

FROM base as prod-build

RUN yarn install --production
RUN yarn run prisma:generate
RUN cp -R node_modules prod_node_modules

FROM base as prod

COPY --from=prod-build /app/prod_node_modules /app/node_modules
COPY --from=build  /app/.next /app/.next
COPY --from=build  /app/public /app/public
COPY --from=build  /app/prisma /app/prisma

EXPOSE 80
CMD ["yarn", "start"]
