FROM node:16-alpine

WORKDIR /app
COPY . .
RUN npm ci --omit=dev

EXPOSE 3000

USER node

CMD ["npm", "start"]