FROM node:14
WORKDIR /usr/src/app
ENV API_Key = 1234 
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD [ "npm", "start" ]