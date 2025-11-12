# 1. Start from an official base "image" that already has Node.js installed
FROM node:18-slim

# 2. Set the "working directory" inside the container
WORKDIR /usr/src/app

# 3. Copy our package.json file into the container
# We copy this first to use Docker's caching.
COPY package*.json ./

# 4. Install all the "ingredients" (dependencies) listed in package.json
RUN npm install

# 5. Copy the rest of our application code (app.js) into the container
COPY . .

# 6. Tell the world that our app runs on port 8080
EXPOSE 8080

# 7. The command to run when the container starts
CMD [ "npm", "start" ]