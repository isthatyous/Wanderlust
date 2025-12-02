 # ------------------- STAGE 1 --------------------------------
 # Base image
 FROM node:21 AS frontend-builder

 # working directory
 WORKDIR /app

 # copy depencies
 COPY package*.json ./

 # Intsall deps
 RUN npm install 

 # copy rest of code
 COPY . .

 # --------------------- STAGE 2 ----------------------------
 FROM node:21-slim

 WORKDIR /app

 COPY --from=frontend-builder /app .

 COPY .env.sample .env.local

 EXPOSE 5173

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]


