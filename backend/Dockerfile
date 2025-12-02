# ------------------- STAGE 1 --------------------------------
# Base image
FROM node:21 AS backend-builder

# working directory
WORKDIR /app

# copy rest of code
COPY . .


# Intsall deps
RUN npm install 
# run tests

RUN npm run test




# --------------------- STAGE 2 ----------------------------
FROM node:21-slim

WORKDIR /app

COPY --from=backend-builder /app .

COPY .env.sample .env

EXPOSE 8080

CMD ["npm", "start"]


