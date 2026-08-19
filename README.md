# 1 
fork `https://github.com/jenkins-docs/simple-java-maven-app.git`
clone the repo 
```bash
git clone https://github.com/TomerBahar22/simple-java-maven-app.git
```

# 2 
```bash
mkdir .github/workflows
touch .github/workflows/github_hosted.yml
```
inside
```yaml
name: Docker

on:
  push:
    branches: [ master ]

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Patch version # in the commit : fix = patch , feat = minor , BREAKING CHANGE = major
        id: patch
        uses: mathieudutour/github-tag-action@v6.2
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          default_bump: patch

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ vars.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_HUB }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ vars.DOCKER_USERNAME }}/simple-java-maven-app:${{ steps.patch.outputs.new_version }}
            ${{ vars.DOCKER_USERNAME }}/simple-java-maven-app:latest
```
rm jenkins folder
```bash
rm -fr jenkins
```
```bash
touch Dockerfile
```
inside 
```Dockerfile
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q dependency:go-offline   
COPY src ./src
RUN mvn -q clean package

FROM eclipse-temurin:21-jre-alpine AS Runner
WORKDIR /app
COPY --from=build /app/target/my-app-*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```
# 3 
add the deploy part as the last step in the `github_hosted.yml` file 
```yaml
      - name: deploy 
        run: |
         docker run ${{ vars.DOCKER_USERNAME }}/simple-java-maven-app:${{ steps.patch.outputs.new_version }}
```
# 4 
create an `ec2` and enter it 
```bash
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/.../actions-runner-linux-x64-....tar.gz
tar xzf actions-runner-linux-x64.tar.gz
./config.sh --url https://github.com/TomerBahar22/simple-java-maven-app --token <TOKEN_FROM_GITHUB>
```
```bash
sudo apt-get update && sudo apt-get install -y docker.io
sudo usermod -aG docker $USER 
```
run
```bash
./run.sh
```
create a `IAM user` and attach to it the policiy `AmazonEC2ContainerRegistryPowerUser`   
now in github go to settings then go to secrets -> action and add `AWS_ACCESS_KEY_ID` , `AWS_ACCOUNT_ID` , `AWS_SECRET_ACCESS_KEY`