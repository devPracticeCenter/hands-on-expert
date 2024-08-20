# node 버전 명시
FROM node:21.7.1 as base 

# dockerfile의 첫 단락, builder 스테이지
# 하나의 리눅스 서버를 의미
# image build 전 패키지 설치
FROM base as builder

# WORKDIR 아래로 두 개의 json 파일을 컨테이너 내부 디렉토리로 복사
# Dockerfile 위치 기준
# copy - run - copy - run 하는 이유
# └ Docker image layer caching → 변동 사항이 없는 package install는 skip 가능
WORKDIR /usr/src/app
COPY package.json package-lock.json ./
RUN npm install

# 모든 파일을 컨테이너 내부로 복사
COPY . .

# html, css, img, node server 등 실행에 필요한 파일들을 빌드하는 명령어
RUN npm run build

# FROM으로 이미지 생성 단락 구분

# dockerfile의 다음 단락, build 스테이지
# 실제 production을 배포할 영역
FROM base as production

WORKDIR /usr/src/app
ENV NODE_ENV=production

COPY --from=builder /usr/src/app/public ./public
COPY --from=builder /usr/src/app/.next/standalone ./
COPY --from=builder /usr/src/app/.next/static ./.next/static

EXPOSE 3000
ENV PORT=3000

CMD ["node", "server.js"]